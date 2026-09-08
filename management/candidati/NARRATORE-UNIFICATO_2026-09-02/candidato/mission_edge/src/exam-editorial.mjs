import {PROVIDER} from './contracts.mjs';
import {cycleContext,CYCLE_SYSTEM} from './exam-cycle.mjs';

export const EDITORIAL_VERSION='MISSION-EXAM-EDITORIAL-001';
const uuid=x=>typeof x==='string'&&/^[0-9a-f]{8}-[0-9a-f]{4}-[1-8][0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}$/iu.test(x);

export async function generateEditorial(claim,provider) {
  const start=Date.now(),ctl=new AbortController();
  const timer=setTimeout(()=>ctl.abort(),PROVIDER.timeout_ms);
  let received;
  try {
    const context=cycleContext(claim.payload,claim.opening);
    const fixed=claim.fixed_output;
    if(!fixed?.intenzione_id||!context.intenzioni.some(i=>i.id===fixed.intenzione_id))throw Error('EDITORIAL_FIXED_INTENTION_MISSING');
    context.intenzioni=context.intenzioni.filter(i=>i.id===fixed.intenzione_id);
    context.elementi_dopo_la_risoluzione=claim.resolved_elements;
    context.scelta_gia_pubblicata=fixed;
    received=await provider.create({signal:ctl.signal,payload:{
      model:PROVIDER.model,reasoning:{effort:PROVIDER.reasoning_effort},store:false,
      max_output_tokens:PROVIDER.max_output_tokens,
      input:[{role:'system',content:[{type:'input_text',text:CYCLE_SYSTEM+`\nQuesta è una revisione editoriale del solo testo già pubblicato: riscrivi azione_png applicando le note di redazione. Intenzione del PNG, bersagli, risultati, stato delle copie e contromossa sono già fissati e restano identici. Non scegliere una nuova mossa, non risolvere la difesa futura e non riscrivere le branche. La role descrive intenzioni; in caso di divergenza i referti decidono i fatti. Restituisci soltanto testo nel JSON richiesto.`}]},
        {role:'user',content:[{type:'input_text',text:JSON.stringify(context)}]}],
      text:{format:{type:'json_schema',name:'exam_editorial',strict:true,schema:{type:'object',additionalProperties:false,
        required:['testo'],properties:{testo:{type:'string'}}}}}
    }});
    const value=received.realization;
    if(received.status!=='completed'||!value||Object.keys(value).join(',')!=='testo'
      ||typeof value.testo!=='string'||!value.testo.trim())throw Error('EDITORIAL_OUTPUT_INCOMPLETE');
    return {ok:true,testo:value.testo.trim().replace(/\s+/gu,' '),prompt_id:EDITORIAL_VERSION,
      telemetria:{model:PROVIDER.model,latency_ms:Date.now()-start,...received.metrics},retry:false};
  } catch(error) {
    return {ok:false,code:received?'EDITORIAL_OUTPUT_INVALID':'EDITORIAL_GENERATION_FAILED',
      prompt_id:EDITORIAL_VERSION,telemetria:{latency_ms:Date.now()-start,...(received??error.provider_result)?.metrics},retry:false};
  } finally {clearTimeout(timer);}
}

export async function runEditorial({draftId,userId,db,provider}) {
  if(!userId||!uuid(draftId))return {status:400,ok:false,published:false,code:'EDITORIAL_IDENTITY_REQUIRED',chiamate:0,retry:false};
  let claim;
  try {claim=await db.rpc('_esame_editorial_claim',{p_draft:draftId,p_user:userId});}
  catch {return {status:409,ok:false,published:false,code:'EDITORIAL_UNAVAILABLE',chiamate:0,retry:false};}
  if(!uuid(claim?.revision_id))return {status:500,ok:false,published:false,code:'EDITORIAL_CLAIM_INVALID',chiamate:0,retry:false};
  const result=await generateEditorial(claim,provider);
  try {
    const published=await db.rpc('_esame_editorial_finish',{p_revision:claim.revision_id,p_user:userId,p_result:result});
    return {status:published.ok===true?200:409,...published,chiamate:1,retry:false};
  } catch {return {status:500,ok:false,published:false,code:'EDITORIAL_PUBLICATION_UNCERTAIN',chiamate:1,retry:false};}
}
