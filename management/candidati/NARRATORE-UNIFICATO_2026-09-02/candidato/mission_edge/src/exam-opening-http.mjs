import {runOpening} from './exam-opening.mjs';

export async function handleOpening(req,{admin,provider,runner=runOpening}) {
  const origin=req.headers.get('origin');
  const allowed=['https://theuntoldstory.it','https://www.theuntoldstory.it'];
  const headers={'content-type':'application/json','cache-control':'no-store','vary':'Origin',
    ...(allowed.includes(origin)?{'access-control-allow-origin':origin}:{}),
    'access-control-allow-headers':'authorization, apikey, content-type, x-client-info',
    'access-control-allow-methods':'POST, OPTIONS'};
  const json=(body,status)=>new Response(JSON.stringify(body),{status,headers});
  if(origin&&!allowed.includes(origin))return json({code:'ORIGIN_NOT_ALLOWED',chiamate:0},403);
  if(req.method==='OPTIONS')return new Response(null,{status:204,headers});
  if(req.method!=='POST')return json({code:'METHOD_NOT_ALLOWED',chiamate:0},405);
  if(!admin||!provider)return json({code:'SERVER_CONFIG_MISSING',chiamate:0},503);
  try {
    const bearer=(req.headers.get('authorization')??'').replace(/^Bearer\s+/i,'').trim();
    if(!bearer)return json({code:'STAFF_JWT_REQUIRED',chiamate:0},401);
    const {data,error}=await admin.auth.getUser(bearer);
    if(error||!data?.user?.id)return json({code:'STAFF_JWT_REQUIRED',chiamate:0},401);
    let body;try{body=await req.json();}catch{return json({code:'INVALID_JSON',chiamate:0},400);}
    if(!body||Array.isArray(body)||Object.keys(body).length!==1||!Object.hasOwn(body,'draft_id'))
      return json({code:'DRAFT_ONLY_REQUEST',chiamate:0},400);
    const db={
      async row(table,columns,id){const r=await admin.from(table).select(columns).eq('id',id).maybeSingle();if(r.error)throw Error('SOURCE_READ_FAILED');return r.data;},
      async rpc(name,args){const r=await admin.rpc(name,args);if(r.error)throw Error('RPC_FAILED');return r.data;},
      async drafts(prova){const r=await admin.from('esame_supervisione_bozze').select('id,tipo,stato,claimed_at,payload,risultato').eq('prova',prova);if(r.error)throw Error('SOURCE_READ_FAILED');return r.data;}
    };
    const result=await runner({draftId:body.draft_id,userId:data.user.id,db,provider});
    return json(result,result.status);
  }catch{return json({code:'OPENING_REQUEST_FAILED',retry:false,chiamate:null},500);}
}
