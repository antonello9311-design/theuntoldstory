import "jsr:@supabase/functions-js/edge-runtime.d.ts";
import {inspectContextRaster} from "./HUMAN_NPC_MEDIA_COMPLETION_EDGE_RASTER.mjs";
import {MAX_NPC_MEDIA_BYTES, NPC_MEDIA_RELEASE, missingNpcObject, npcMediaHeaders, npcMediaTicketRpc, validNpcRegistration, validNpcTicket} from "./HUMAN_NPC_MEDIA_COMPLETION_EDGE_RUNTIME.mjs";

const ORIGIN = "https://theuntoldstory.it";
const cors = (origin:string|null) => origin === ORIGIN ? {
  "access-control-allow-origin": ORIGIN,
  "access-control-allow-methods": "POST, OPTIONS",
  "access-control-allow-headers": "authorization, apikey, content-type, x-client-info, x-mf-template-id, x-mf-narrative-version-id, x-mf-kind, x-mf-request-key, x-mf-sha256, x-mf-expected-release",
  "access-control-max-age": "86400", "vary": "Origin"
} : {};
const digest = async(bytes:ArrayBuffer) => [...new Uint8Array(await crypto.subtle.digest("SHA-256",bytes))].map(x=>x.toString(16).padStart(2,"0")).join("");
const out = (status:number, result:Record<string,unknown>, origin:string|null) =>
  new Response(JSON.stringify({...result,release:NPC_MEDIA_RELEASE}), {
    status,headers:{"content-type":"application/json","x-mission-factory-npc-media-release":NPC_MEDIA_RELEASE,...cors(origin)}
  });
// Read the stream only up to the server limit, even when Content-Length is absent or false.
const readBoundedBody = async(stream:ReadableStream<Uint8Array>|null):Promise<ArrayBuffer> => {
  if (!stream) throw Error("empty_body");
  const reader=stream.getReader();
  const chunks:Uint8Array[]=[];
  let total=0;
  try {
    for (;;) {
      const {done,value}=await reader.read();
      if (done) break;
      total+=value.byteLength;
      if (total>MAX_NPC_MEDIA_BYTES) {
        await reader.cancel().catch(()=>{});
        throw Error("file_too_large");
      }
      chunks.push(value);
    }
  } finally { reader.releaseLock(); }
  const result=new Uint8Array(total);
  let offset=0;
  for (const chunk of chunks) { result.set(chunk,offset); offset+=chunk.byteLength; }
  return result.buffer;
};
const call = async(base:string,key:string,token:string,name:string,body:Record<string,unknown>) => {
  const response = await fetch(base+"/rest/v1/rpc/"+name,{
    method:"POST",headers:{authorization:"Bearer "+token,apikey:key,"content-type":"application/json"},
    body:JSON.stringify(body)
  });
  const data = await response.json().catch(()=>null);
  if (!response.ok) throw Object.assign(Error(name),{status:response.status});
  return data;
};

Deno.serve(async(req) => {
  const origin=req.headers.get("origin");
  if (origin && origin!==ORIGIN) return out(403,{error:"origin_not_allowed"},origin);
  if (req.method==="OPTIONS") return new Response(null,{status:204,headers:{"x-mission-factory-npc-media-release":NPC_MEDIA_RELEASE,...cors(origin)}});
  if (req.method!=="POST") return out(405,{error:"method_not_allowed"},origin);
  const token=(req.headers.get("authorization")||"").replace(/^Bearer\s+/i,"");
  if (token.split(".").length!==3) return out(401,{error:"jwt_required"},origin);
  let meta;
  try { meta=npcMediaHeaders(req.headers); }
  catch { return out(400,{error:"invalid_media_headers"},origin); }
  const declaredHeader=req.headers.get("content-length");
  const declared=declaredHeader===null?null:Number(declaredHeader);
  if (declared!==null && (!Number.isSafeInteger(declared) || declared<0))
    return out(400,{error:"invalid_content_length"},origin);
  if (declared!==null && declared>MAX_NPC_MEDIA_BYTES)
    return out(413,{error:"file_too_large"},origin);
  let bytes:ArrayBuffer;
  try { bytes=await readBoundedBody(req.body); }
  catch(e) { return out((e as Error).message==="file_too_large"?413:400,
    {error:(e as Error).message==="file_too_large"?"file_too_large":"invalid_body"},origin); }
  let raster;
  try { raster=inspectContextRaster(bytes,meta.mime); }
  catch { return out(400,{error:"invalid_raster"},origin); }
  const sha=await digest(bytes);
  if (sha!==meta.sha256) return out(409,{error:"digest_mismatch"},origin);
  const base=Deno.env.get("SUPABASE_URL"),key=Deno.env.get("SUPABASE_SERVICE_ROLE_KEY");
  if (!base||!key) return out(503,{error:"server_config_missing"},origin);
  let ticket;
  try {
    ticket=validNpcTicket(await call(base,key,token,npcMediaTicketRpc(meta),{
      p_template:meta.template_id,p_narrative_version:meta.narrative_version_id,
      p_kind:meta.kind,p_request:meta.request_key,p_sha256:sha,
      p_bytes:bytes.byteLength,p_mime:meta.mime
    }),meta,bytes.byteLength);
  } catch(e) { return out((e as {status?:number}).status||409,{error:"ticket_rejected"},origin); }
  if (ticket.state!=="pending") return out(200,{...ticket.registration,replayed:true},origin);
  const objectUrl=base+"/storage/v1/object/avatars/"+ticket.object_path;
  let existing;
  try { existing=await fetch(objectUrl,{headers:{authorization:"Bearer "+key,apikey:key,"cache-control":"no-cache"}}); }
  catch { return out(503,{error:"storage_probe_unavailable"},origin); }
  const existingError=existing.ok?null:await existing.clone().json().catch(()=>null);
  if (existing.ok) {
    let old:ArrayBuffer;
    try { old=await readBoundedBody(existing.body); }
    catch { return out(409,{error:"storage_conflict"},origin); }
    if (old.byteLength!==bytes.byteLength || await digest(old)!==sha)
      return out(409,{error:"storage_conflict"},origin);
  } else if (missingNpcObject(existing.status,existingError)) {
    const put=await fetch(objectUrl,{
      method:"POST",headers:{authorization:"Bearer "+key,apikey:key,
        "content-type":meta.mime,"x-upsert":"false"},body:bytes
    });
    if (!put.ok) return out(409,{error:"storage_upload_failed"},origin);
  } else return out(409,{error:"storage_probe_failed"},origin);
  try {
    const result=await call(base,key,key,"npc_media_register_v1",{
      p_request:meta.request_key,p_sha256:sha,p_bytes:bytes.byteLength,
      p_mime:meta.mime,p_width:raster.width,p_height:raster.height
    });
    if (!validNpcRegistration(result,ticket,meta,raster.width,raster.height))
      return out(409,{error:"registration_shape_invalid"},origin);
    return out(200,result,origin);
  } catch { return out(409,{error:"registration_failed"},origin); }
});
