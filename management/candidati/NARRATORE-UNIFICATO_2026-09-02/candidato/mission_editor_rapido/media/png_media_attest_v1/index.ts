import "jsr:@supabase/functions-js/edge-runtime.d.ts";
import {inspectRaster, isMissingObject, rapidHeaders, RAPID_RELEASE, validTicket, MAX_BYTES} from "../runtime.mjs";

const SCORTA_RELEASE="0dd44d7d0f7ff6379b5c716ee8660e4e11dfbb4f008a376bec97c1743788a8db";
const ASSETS={
 tetsuma:{path:"ninja-book/nb_ronda_tetsuma_iori/r1/assets/tetsuma_iori_canonical_v1.png",sha256:"ac0864854264ff7181f82cb66b943da7c41013067d0a46e0af9ce85fcfb14dbd",bytes:1289975},
 nao:{path:"ninja-book/nb_ronda_nao_sagiri/r1/assets/nao_sagiri_canonical_v1.png",sha256:"19653fee8d055e8cc4ec125dd342a53f8554491870aedb8c102ef3ab60a0fda3",bytes:1287951},
 genta:{path:"ninja-book/scorta_genin_genta/r1/assets/genta_sagoma_v1.png",sha256:"166144cb93e69b992c7b397c9d4f68ced36a91861ce44815244cac77a804c26c",bytes:1465345},
 ren:{path:"ninja-book/scorta_genin_ren/r1/assets/ren_sagoma_v1.png",sha256:"1d8722dd93093a2a0d23b9690f50e244016e7cf458e2539f745d21085e995d6b",bytes:1329128},
 suzu:{path:"ninja-book/scorta_genin_suzu/r1/assets/suzu_sagoma_v1.png",sha256:"8f5d9693a514e3d20e793097bdf3b1706daa897a07ac773d72aa3a30f50c9902",bytes:1473666},
 haruto:{path:"ninja-book/scorta_genin_haruto_sena/r1/assets/haruto_ritratto_v1.png",sha256:"fb93d4b5d67039771c0a66255b0c5e12b7f2997f43c4b287e6476781b796a1bd",bytes:1586515}
} as const;
const SCORTA_KEYS=new Set(["genta","ren","suzu","haruto"]),ALLOWED_ORIGIN="https://theuntoldstory.it";
const cors=(origin:string|null)=>origin===ALLOWED_ORIGIN?{"access-control-allow-origin":ALLOWED_ORIGIN,"access-control-allow-methods":"POST, OPTIONS","access-control-allow-headers":"authorization, apikey, content-type, x-client-info, x-mr-draft-id, x-mr-actor-key, x-mr-bundle-id, x-mr-request-key, x-mr-sha256, x-mr-expected-release","access-control-max-age":"86400","vary":"Origin"}:{};
const hex=(b:ArrayBuffer)=>[...new Uint8Array(b)].map(x=>x.toString(16).padStart(2,"0")).join("");
const out=(status:number,body:Record<string,unknown>,origin:string|null,release:string)=>new Response(JSON.stringify(body),{status,headers:{"content-type":"application/json","x-png-media-release":release,...cors(origin)}});
const call=async(base:string,key:string,token:string,name:string,body:Record<string,unknown>)=>{const r=await fetch(base+"/rest/v1/rpc/"+name,{method:"POST",headers:{authorization:"Bearer "+token,apikey:key,"content-type":"application/json"},body:JSON.stringify(body)});const data=await r.json().catch(()=>null);if(!r.ok)throw Object.assign(Error(name),{status:r.status,data});return data;};

async function rapid(req:Request,origin:string|null,base:string,key:string,token:string){
 let meta;try{meta=rapidHeaders(req.headers)}catch{return out(400,{error:"invalid_rapid_headers",release:RAPID_RELEASE},origin,RAPID_RELEASE)}
 const length=Number(req.headers.get("content-length")||0);if(length>MAX_BYTES)return out(413,{error:"file_too_large",release:RAPID_RELEASE},origin,RAPID_RELEASE);
 const bytes=await req.arrayBuffer();let raster;try{raster=inspectRaster(bytes,meta.mime)}catch{return out(400,{error:"invalid_raster",release:RAPID_RELEASE},origin,RAPID_RELEASE)}
 const sha=hex(await crypto.subtle.digest("SHA-256",bytes));if(sha!==meta.sha256)return out(409,{error:"digest_mismatch",release:RAPID_RELEASE},origin,RAPID_RELEASE);
 let ticket;try{ticket=validTicket(await call(base,key,token,"mission_rapid_media_ticket_v1",{p_draft:meta.draft_id,p_actor_key:meta.actor_key,p_bundle:meta.bundle_id,p_request:meta.request_key,p_sha256:sha,p_bytes:bytes.byteLength,p_mime:meta.mime}),meta)}catch(e){return out((e as {status?:number}).status||409,{error:"ticket_rejected",release:RAPID_RELEASE},origin,RAPID_RELEASE)}
 if(ticket.registered===true)return out(200,{...ticket,release:RAPID_RELEASE},origin,RAPID_RELEASE);
 const objectUrl=base+"/storage/v1/object/avatars/"+ticket.object_path;
 const existing=await fetch(objectUrl,{headers:{authorization:"Bearer "+key,apikey:key,"cache-control":"no-cache"}});
 const existingError=existing.ok?null:await existing.clone().json().catch(()=>null);
 if(existing.ok){const old=await existing.arrayBuffer(),oldSha=hex(await crypto.subtle.digest("SHA-256",old));if(old.byteLength!==bytes.byteLength||oldSha!==sha)return out(409,{error:"storage_conflict",release:RAPID_RELEASE},origin,RAPID_RELEASE);}
 else if(isMissingObject(existing.status,existingError)){const put=await fetch(objectUrl,{method:"POST",headers:{authorization:"Bearer "+key,apikey:key,"content-type":meta.mime,"x-upsert":"false"},body:bytes});if(!put.ok)return out(409,{error:"storage_upload_failed",release:RAPID_RELEASE},origin,RAPID_RELEASE);}
 else return out(409,{error:"storage_probe_failed",release:RAPID_RELEASE},origin,RAPID_RELEASE);
 try{const result=await call(base,key,key,"mission_rapid_media_register_v1",{p_request:meta.request_key,p_sha256:sha,p_bytes:bytes.byteLength,p_mime:meta.mime,p_width:raster.width,p_height:raster.height});return out(200,{...result,release:RAPID_RELEASE},origin,RAPID_RELEASE)}catch{return out(409,{error:"registration_failed",release:RAPID_RELEASE},origin,RAPID_RELEASE)}
}

Deno.serve(async(req)=>{
 const origin=req.headers.get("origin"),rapidMode=Boolean(req.headers.get("x-mr-draft-id")),release=rapidMode?RAPID_RELEASE:SCORTA_RELEASE;
 if(origin&&origin!==ALLOWED_ORIGIN)return out(403,{error:"origin_not_allowed"},origin,release);
 if(req.method==="OPTIONS")return new Response(null,{status:204,headers:{"x-png-media-release":release,...cors(origin)}});
 if(req.method!=="POST")return out(405,{error:"method_not_allowed"},origin,release);
 const token=(req.headers.get("authorization")||"").replace(/^Bearer\s+/i,"");const parts=token.split(".");if(parts.length!==3)return out(401,{error:"jwt_required"},origin,release);
 let claims:Record<string,unknown>={};try{claims=JSON.parse(atob(parts[1].replace(/-/g,"+").replace(/_/g,"/")))}catch{return out(401,{error:"jwt_invalid"},origin,release)}
 const base=Deno.env.get("SUPABASE_URL"),key=Deno.env.get("SUPABASE_SERVICE_ROLE_KEY");if(!base||!key)return out(503,{error:"server_config_missing",release},origin,release);
 if(rapidMode)return rapid(req,origin,base,key,token);
 const body=await req.json().catch(()=>null);if(body?.expected_release!==SCORTA_RELEASE)return out(409,{error:"release_mismatch",release:SCORTA_RELEASE},origin,SCORTA_RELEASE);
 const assetKey=typeof body?.asset_key==="string"?body.asset_key:"",asset=assetKey?ASSETS[assetKey as keyof typeof ASSETS]:undefined;if(!asset||!body?.request_key)return out(400,{error:"invalid_request",release:SCORTA_RELEASE},origin,SCORTA_RELEASE);
 if(claims.role!=="service_role"){if(!SCORTA_KEYS.has(assetKey))return out(403,{error:"service_role_required",release:SCORTA_RELEASE},origin,SCORTA_RELEASE);try{await call(base,key,token,"png_media_admin_ticket_scorta_v1",{p_asset_key:assetKey})}catch{return out(403,{error:"admin_required",release:SCORTA_RELEASE},origin,SCORTA_RELEASE)}}
 const response=await fetch(base+"/storage/v1/object/public/avatars/"+asset.path,{headers:{"cache-control":"no-cache"}});if(!response.ok)return out(409,{error:"storage_fetch_failed",release:SCORTA_RELEASE},origin,SCORTA_RELEASE);
 const bytes=await response.arrayBuffer(),sha=hex(await crypto.subtle.digest("SHA-256",bytes)),mime=(response.headers.get("content-type")||"").split(";")[0];if(bytes.byteLength!==asset.bytes||sha!==asset.sha256||mime!=="image/png")return out(409,{error:"byte_attestation_mismatch",release:SCORTA_RELEASE},origin,SCORTA_RELEASE);
 try{const result=await call(base,key,key,"png_media_attest_register_v1",{p_asset_key:assetKey,p_sha256:sha,p_bytes:bytes.byteLength,p_mime:mime,p_request_key:body.request_key});return out(200,{...result,release:SCORTA_RELEASE},origin,SCORTA_RELEASE)}catch{return out(409,{error:"registration_failed",release:SCORTA_RELEASE},origin,SCORTA_RELEASE)}
});
