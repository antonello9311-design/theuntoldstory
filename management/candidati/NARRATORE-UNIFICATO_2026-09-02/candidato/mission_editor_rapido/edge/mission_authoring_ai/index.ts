import {createClient} from 'jsr:@supabase/supabase-js@2';
import {authoringCors,compileOnce,EDGE_REVISION} from './runtime.mjs';

const json=(body:unknown,status=200,cors:Record<string,string>={})=>new Response(JSON.stringify(body),{status,headers:{...cors,'content-type':'application/json; charset=utf-8','cache-control':'no-store','x-mission-authoring-build':EDGE_REVISION}});
const bearer=(req:Request)=>{const h=req.headers.get('authorization')??'';return /^Bearer\s+\S+$/i.test(h)?h:null};

Deno.serve(async(req:Request)=>{
  const access=authoringCors(req.headers.get('origin'));
  if(!access.allowed)return json({code:'ORIGIN_NOT_ALLOWED'},403,access.headers);
  if(req.method==='OPTIONS')return new Response(null,{status:204,headers:{...access.headers,'x-mission-authoring-build':EDGE_REVISION}});
  if(req.method!=='POST')return json({code:'METHOD_NOT_ALLOWED'},405,access.headers);
  const auth=bearer(req);if(!auth)return json({code:'AUTH_REQUIRED'},401,access.headers);
  const url=Deno.env.get('SUPABASE_URL')??'',publishable=Deno.env.get('SUPABASE_ANON_KEY')??'',service=Deno.env.get('SUPABASE_SERVICE_ROLE_KEY')??'',openai=Deno.env.get('OPENAI_API_KEY')??'';
  if(!url||!publishable||!service||!openai)return json({code:'SERVER_CONFIG_MISSING'},503,access.headers);
  const userClient=createClient(url,publishable,{global:{headers:{Authorization:auth}},auth:{persistSession:false}});
  const {data:userData,error:userError}=await userClient.auth.getUser();const user=userData?.user;
  if(userError||!user)return json({code:'AUTH_INVALID'},401,access.headers);
  let body:{request_key?:string};try{body=await req.json()}catch{return json({code:'INVALID_JSON'},400,access.headers)}
  if(typeof body?.request_key!=='string'||!/^[0-9a-f-]{36}$/i.test(body.request_key))return json({code:'REQUEST_KEY_INVALID'},400,access.headers);
  const admin=createClient(url,service,{auth:{persistSession:false}});
  const rpc=async(name:string,args:Record<string,unknown>)=>{const {data,error}=await admin.rpc(name,args);if(error)throw new Error(`${name.toUpperCase()}_${error.code??'FAILED'}`);return data};
  try{
    const result=await compileOnce({
      claim:()=>rpc('mission_rapid_compile_claim_v1',{p_user:user.id,p_request:body.request_key}),
      provider:{async create(input:unknown,{signal}:{signal?:AbortSignal}={}){const response=await fetch('https://api.openai.com/v1/responses',{method:'POST',signal,headers:{authorization:`Bearer ${openai}`,'content-type':'application/json'},body:JSON.stringify(input)});const data=await response.json();if(!response.ok)throw new Error(`AUTHORING_PROVIDER_${response.status}`);return data}},
      complete:({request_key,document,telemetry})=>rpc('mission_rapid_compile_complete_v1',{p_user:user.id,p_request:request_key,p_document:document,p_telemetry:telemetry}),
      reject:({request_key,code,provider_calls})=>rpc('mission_rapid_compile_reject_v1',{p_user:user.id,p_request:request_key,p_code:code,p_provider_calls:provider_calls}),
      signal:req.signal
    });
    return json(result,200,access.headers);
  }catch(error){const code=String((error as Error)?.message||'AUTHORING_FAILED').slice(0,160);return json({code,edge_revision:EDGE_REVISION},code.includes('AUTH')?403:422,access.headers)}
});
