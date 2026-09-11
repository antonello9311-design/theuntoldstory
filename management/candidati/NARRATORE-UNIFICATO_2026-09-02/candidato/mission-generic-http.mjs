import {runMissionEvent,validateRequest} from './mission-generic-runtime.mjs';
import {canonical} from './exam_regia17/edge/src/shared-scene/scene.mjs';

const uuid=x=>typeof x==='string'&&/^[a-f0-9]{8}(?:-[a-f0-9]{4}){3}-[a-f0-9]{12}$/i.test(x);
const object=x=>x!==null&&typeof x==='object'&&!Array.isArray(x);
const exact=(x,keys)=>object(x)&&Object.keys(x).length===keys.length&&keys.every(k=>Object.hasOwn(x,k));
const RPC=Object.freeze({next:'mission_generic_dispatch_next_v1',progress:'mission_generic_progress_v1',reject:'mission_generic_dispatch_reject_v1',claim:'mission_generic_dispatch_claim_v1',
  status:'mission_generic_dispatch_status_v1',authorize:'mission_generic_dispatch_authorize_v1',
  consume:'mission_generic_dispatch_consume_v1',finalize:'mission_generic_dispatch_finalize_v1'});

async function bodyOf(req) {
  if (!req.body) throw Error('REQUEST_BODY_REQUIRED');
  const reader=req.body.getReader(),chunks=[];let total=0,timer;
  const expired=new Promise((_,reject)=>{timer=setTimeout(()=>{reader.cancel().catch(()=>{});reject(Error('REQUEST_TIMEOUT'));},10000);});
  try {
    for (;;) {const x=await Promise.race([reader.read(),expired]);if(x.done)break;total+=x.value.byteLength;
      if(total>8192){await reader.cancel();throw Error('REQUEST_TOO_LARGE');}chunks.push(x.value);}
  } finally {clearTimeout(timer);reader.releaseLock();}
  const joined=new Uint8Array(total);let at=0;for(const c of chunks){joined.set(c,at);at+=c.byteLength;}
  return JSON.parse(new TextDecoder('utf-8',{fatal:true}).decode(joined));
}

// This adapter is created anew after getUser. It never trusts a user id, token,
// RPC name or scene in the request body. Finalize token stays in invocation memory.
export function createMissionDbAdapter({admin,userId,workerToken}) {
  if (!uuid(userId)||!admin?.rpc||typeof workerToken!=='string'||!workerToken) throw Error('MISSION_HTTP_CONFIG');
  const finalizers=new Map();
  async function rpc(name,args,{signal}={}) {
    let pending=admin.rpc(name,args);
    if(signal&&typeof pending.abortSignal==='function')pending=pending.abortSignal(signal);
    const out=await pending;
    if(out.error||!object(out.data))throw Error('MISSION_RPC_REJECTED');
    return out.data;
  }
  return {
    next:(session,options)=>rpc(RPC.next,{p_session:session,p_user:userId},options),
    progress:(session,request,options)=>rpc(RPC.progress,{p_session:session,p_user:userId,p_request:request},options),
    claim:(request,options)=>rpc(RPC.claim,{p_user:userId,p_request:request},options),
    reject:(request,lease,code,options)=>rpc(RPC.reject,{p_user:userId,p_request:request,p_lease:lease,p_code:code},options),
    status:(request,options)=>rpc(RPC.status,{p_user:userId,p_request:request},options),
    authorize:(work,policy,options)=>rpc(RPC.authorize,{p_work:work.work_id,p_lease:work.lease_id,p_worker_token:workerToken,p_policy:policy},options),
    consume:async(work,permission,options)=>{
      const r=await rpc(RPC.consume,{p_work:work.work_id,p_lease:work.lease_id,p_worker_token:workerToken,
        p_authorization:permission.authorization_id,p_dispatch_token:permission.dispatch_token},options);
      if(typeof r.finalize_token!=='string'||!r.finalize_token)throw Error('MISSION_CONSUME_RECEIPT');
      finalizers.set(work.work_id,r.finalize_token);
      const {finalize_token,...publicReceipt}=r;return publicReceipt;
    },
    finalize:(work,result,hash,options)=>{
      const token=finalizers.get(work.work_id);if(!token)throw Error('MISSION_FINALIZE_TOKEN_MISSING');
      return rpc(RPC.finalize,{p_work:work.work_id,p_finalize_token:token,p_result_text:canonical(result),p_result_sha:hash},options);
    },
  };
}

export async function handleMissionGeneric(req,{admin,provider,workerToken,allowedOrigins=['https://theuntoldstory.it','https://www.theuntoldstory.it']}={}) {
  const origin=req.headers.get('origin');
  const headers={'content-type':'application/json','cache-control':'no-store','vary':'Origin'};
  const respond=(x,status=200)=>new Response(JSON.stringify(x),{status,headers});
  if(origin&&!allowedOrigins.includes(origin))return respond({code:'ORIGIN_FORBIDDEN'},403);
  if(origin){headers['access-control-allow-origin']=origin;headers['access-control-allow-headers']='authorization,apikey,content-type,x-client-info';headers['access-control-allow-methods']='POST,OPTIONS';}
  if(req.method==='OPTIONS')return new Response(null,{status:204,headers});
  if(req.method!=='POST')return respond({code:'METHOD_NOT_ALLOWED'},405);
  if(!admin?.auth?.getUser||!admin?.rpc||!provider?.create||typeof workerToken!=='string'||!workerToken)
    return respond({code:'MISSION_ADAPTER_UNAVAILABLE'},503);
  const authorization=req.headers.get('authorization')??'';
  if(!/^Bearer\s+\S+$/i.test(authorization))return respond({code:'UNAUTHORIZED'},401);
  let user,body;
  try {const r=await admin.auth.getUser(authorization.replace(/^Bearer\s+/i,''));if(r.error||!uuid(r.data?.user?.id))throw Error('AUTH');user=r.data.user.id;}
  catch{return respond({code:'UNAUTHORIZED'},401);}
  try{body=await bodyOf(req);}catch{return respond({code:'REQUEST_INVALID'},400);}
  let db;try{db=createMissionDbAdapter({admin,userId:user,workerToken});}catch{return respond({code:'MISSION_ADAPTER_UNAVAILABLE'},503);}
  // The next operation exposes only an event reference; it never starts provider work.
  if(exact(body,['operation','master_session_id'])&&body.operation==='next'&&uuid(body.master_session_id)){
    try{const r=await db.next(body.master_session_id);return respond(r);}catch{return respond({code:'MISSION_SCOPE_REJECTED'},403);}
  }
  if(exact(body,['schema_version','master_session_id','request_key'])&&body.schema_version==='mission-generic-tick/1'
    &&uuid(body.master_session_id)&&uuid(body.request_key)){
    let progress;
    try{progress=await db.progress(body.master_session_id,body.request_key);}catch{return respond({code:'MISSION_PROGRESS_REJECTED'},409);}
    if(progress.schema_version!=='mission-generic-progress/1'||progress.master_session_id!==body.master_session_id)
      return respond({code:'MISSION_PROGRESS_INVALID'},503);
    if(progress.dispatch===null)return respond(progress);
    if(!validateRequest(progress.dispatch)||progress.dispatch.master_session_id!==body.master_session_id)
      return respond({code:'MISSION_PROGRESS_INVALID'},503);
    const delivery=await runMissionEvent({request:progress.dispatch,db,provider});
    return respond({...progress,delivery},delivery.status??503);
  }
  if(!validateRequest(body))return respond({code:'REQUEST_INVALID'},400);
  const result=await runMissionEvent({request:body,db,provider});
  return respond(result,result.status??503);
}
