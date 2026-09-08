import {generateEditorial} from './exam-editorial.mjs';
import {CYCLE_PROMPT} from './exam-cycle.mjs';
const uuid=x=>typeof x==='string'&&/^[0-9a-f]{8}-[0-9a-f]{4}-[1-8][0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}$/iu.test(x);
export async function runPreview({draftId,userId,db,provider}) {
 if(!userId||!uuid(draftId))return {status:400,ok:false,preview_ready:false,chiamate:0,retry:false};
 let claim;
 try{claim=await db.rpc('_esame_preview_claim',{p_draft:draftId,p_user:userId});}
 catch{return {status:409,ok:false,preview_ready:false,chiamate:0,retry:false};}
 if(!uuid(claim?.revision_id))return {status:500,ok:false,preview_ready:false,chiamate:0,retry:false};
 let requestSha=null;
 const measuredProvider={async create(request){
  const bytes=new TextEncoder().encode(JSON.stringify(request.payload));
  requestSha=Array.from(new Uint8Array(await crypto.subtle.digest('SHA-256',bytes)),b=>b.toString(16).padStart(2,'0')).join('');
  return provider.create(request);
 }};
 const generated=await generateEditorial(claim,measuredProvider);
 const result={...generated,cycle_prompt:CYCLE_PROMPT,request_sha:requestSha,
  source_chat_characters:typeof claim.payload?.contesto_pg==='string'?claim.payload.contesto_pg.length:null};
 try{
  const out=await db.rpc('_esame_preview_finish',{p_revision:claim.revision_id,p_user:userId,p_result:result});
  return {status:out.ok===true?200:409,ok:out.ok===true,preview_ready:out.preview_ready===true,chiamate:1,retry:false};
 }catch{return {status:500,ok:false,preview_ready:false,chiamate:1,retry:false};}
}
