import {scenePrompts, inspectNarrative} from './exam_regia17/edge/src/shared-scene/editorial.mjs';
import {editorialPrompt, EDITORIAL_VERSION} from './exam_regia17/edge/src/shared-scene/common.mjs';
import {digest, canonical} from './exam_regia17/edge/src/shared-scene/scene.mjs';
import {PROVIDER} from './exam_regia17/edge/src/contracts.mjs';
import {choiceContext, choiceRequest, choiceCommand, CHOICE_VERSION} from './mission-generic-choice.mjs';

export const RUNTIME_VERSION = 'mission-generic-runtime/1';
const object = x => x !== null && typeof x === 'object' && !Array.isArray(x);
const exact = (x, fields) => object(x) && Object.keys(x).length === fields.length && fields.every(k=>Object.hasOwn(x,k));
const uuid = x => typeof x === 'string' && /^[a-f0-9]{8}(?:-[a-f0-9]{4}){3}-[a-f0-9]{12}$/i.test(x);
const sha = x => typeof x === 'string' && /^[a-f0-9]{64}$/.test(x);
const text = x => typeof x === 'string' && x.trim().length > 0;
const positive = x => Number.isSafeInteger(x) && x > 0;
const bytes = x => new TextEncoder().encode(JSON.stringify(x)).length;
const unique = list => new Set(list).size === list.length;
const pending = phase => ({status:202,code:'MISSION_EVENT_UNCERTAIN',phase,retry:false,provider_retry_allowed:false});
const reject = code => ({status:409,code,retry:false,provider_retry_allowed:false});
const REQUEST_FIELDS = ['schema_version','master_session_id','event_id','request_key','expected_revision'];

export function validateRequest(q) {
  return exact(q,REQUEST_FIELDS) && q.schema_version === 'mission-generic-request/1'
    && uuid(q.master_session_id) && uuid(q.event_id) && uuid(q.request_key) && positive(q.expected_revision);
}

function bindingMatches(work,q) {
  return object(work) && work.schema_version === 'mission-generic-work/1' && uuid(work.work_id)
    && work.master_session_id === q.master_session_id && work.event_id === q.event_id
    && work.request_key === q.request_key && work.revision === q.expected_revision;
}

export function validateWork(work,q) {
  if (!bindingMatches(work,q) || !text(work.step_key) || !positive(work.run_control_version)
    || !sha(work.definition_sha256) || !(work.encounter_id === null || uuid(work.encounter_id))
    || !uuid(work.authority_receipt_id) || !['choice','narration'].includes(work.kind)
    || !uuid(work.lease_id) || !Number.isFinite(Date.parse(work.server_now))
    || !Number.isFinite(Date.parse(work.lease_expires_at)) || Date.parse(work.lease_expires_at) <= Date.parse(work.server_now)
    || !object(work.payload) || !sha(work.payload_sha256)) throw Error('MISSION_WORK_INVALID');
  const l = work.limits;
  if (!exact(l,['provider_calls_remaining','max_output_tokens','max_input_bytes','max_request_bytes','transport_max_chars','provider_timeout_ms'])
    || !positive(l.provider_calls_remaining) || !positive(l.max_output_tokens) || l.max_output_tokens > 9992
    || !positive(l.max_input_bytes) || l.max_input_bytes > 49152 || !positive(l.max_request_bytes) || l.max_request_bytes > 65536
    || l.max_request_bytes < l.max_input_bytes || !positive(l.transport_max_chars) || l.transport_max_chars > 5000
    || !positive(l.provider_timeout_ms) || l.provider_timeout_ms > PROVIDER.timeout_ms)
    throw Error('MISSION_LIMITS_INVALID');
  if (bytes(work.payload) > l.max_input_bytes) throw Error('MISSION_REQUIRED_CONTEXT_OVERFLOW');
  // payload_sha256 è l'impronta JSONB opaca della claim DB; mai ricalcolarla con JSON.stringify.
  return work;
}

async function missionPrompts(context,work) {
  if (!exact(context,['schema_version','master_session_id','step_key','run_control_version','definition_sha256',
    'authority_receipt_id','location','actors','sources','resolved_facts'])
    || context.schema_version !== 'mission-narrative-context/1' || context.master_session_id !== work.master_session_id
    || context.step_key !== work.step_key || context.run_control_version !== work.run_control_version
    || context.definition_sha256 !== work.definition_sha256 || context.authority_receipt_id !== work.authority_receipt_id
    || !text(context.location) || !object(context.resolved_facts) || !Array.isArray(context.actors) || !context.actors.length
    || !Array.isArray(context.sources)) throw Error('MISSION_NARRATIVE_CONTEXT_INVALID');
  const actors = new Set();
  for (const a of context.actors) {
    if (!exact(a,['id','name','kind','persona','may_speak']) || !text(a.id) || actors.has(a.id) || !text(a.name)
      || !['PG','PNG'].includes(a.kind) || !(a.persona === null || text(a.persona)) || typeof a.may_speak !== 'boolean'
      || (a.may_speak && (a.kind !== 'PNG' || !text(a.persona)))) throw Error('MISSION_ACTOR_INVALID');
    actors.add(a.id);
  }
  const ids = new Set();
  for (const s of context.sources) {
    if (!exact(s,['id','master_session_id','kind','actor_id','sequence','body','sha256','visibility','complete'])
      || !text(s.id) || ids.has(s.id) || s.master_session_id !== work.master_session_id
      || !['role','fato','setting','perception'].includes(s.kind) || !Number.isSafeInteger(s.sequence) || s.sequence < 0
      || !text(s.body) || !sha(s.sha256) || s.complete !== true || await digest(s.body) !== s.sha256
      || (['role','perception'].includes(s.kind) ? !actors.has(s.actor_id) : s.actor_id !== null)
      || s.visibility !== (s.kind === 'perception' ? 'narratable_perception' : 'public'))
      throw Error('MISSION_SOURCE_INVALID');
    ids.add(s.id);
  }
  return {sys:editorialPrompt('mission_fato') + '\nCapacità tecnica del messaggio: ' + work.limits.transport_max_chars
      + ' caratteri Unicode. Consegna un testo completo; il superamento viene segnalato, mai tagliato.',
    usr:JSON.stringify({luogo:context.location,attori:context.actors,fatti_definitivi_server:context.resolved_facts,
      fonti:context.sources.map(s=>({id:s.id,tipo:s.kind,autore:s.actor_id,sequenza:s.sequence,testo:s.body,
        autorita:s.kind==='role'?'tentativo_e_parlato':s.kind==='fato'?'continuita_non_meccanica':
          s.kind==='perception'?'percezione_del_solo_autore_narrabile_senza_nuove_permission_PG':'ambientazione_autorizzata'}))})};
}

export async function narrativeRequest(work,signal) {
  const p = work.payload, b = p.barrier;
  if (p.schema_version !== 'mission-generic-narration/1' || !['combat','mission'].includes(p.mode)
    || !exact(b,['closed','required_receipt_ids','receipt_ids']) || b.closed !== true
    || !Array.isArray(b.required_receipt_ids) || !b.required_receipt_ids.length || !Array.isArray(b.receipt_ids)
    || b.required_receipt_ids.some(id=>!uuid(id)) || b.receipt_ids.some(id=>!uuid(id))
    || !unique(b.required_receipt_ids) || !unique(b.receipt_ids) || !b.receipt_ids.includes(work.authority_receipt_id)
    || b.required_receipt_ids.some(id=>!b.receipt_ids.includes(id))) throw Error('MISSION_NARRATIVE_FACTS_INCOMPLETE');
  let prompts;
  if (p.mode === 'combat') {
    if (!uuid(work.encounter_id) || !object(p.scene_binding) || !uuid(p.scene_binding.session_id)
      || !uuid(p.scene_binding.round_id) || !sha(p.scene_binding.report_sha256)
      || p.scene_binding.hash_authority !== 'combat_v2_sha256/jsonb') throw Error('MISSION_COMBAT_BINDING_INVALID');
    prompts = await scenePrompts(p.scene,p.scene_binding,{transportMaxChars:work.limits.transport_max_chars,maxInputBytes:work.limits.max_input_bytes});
  } else prompts = await missionPrompts(p.context,work);
  const payload = {model:PROVIDER.model,reasoning:{effort:PROVIDER.reasoning_effort},store:false,max_output_tokens:work.limits.max_output_tokens,
    input:[{role:'system',content:[{type:'input_text',text:prompts.sys}]},{role:'user',content:[{type:'input_text',text:prompts.usr}]}],
    text:{format:{type:'json_schema',name:'mission_generic_narrative',strict:true,schema:{type:'object',additionalProperties:false,
      required:['testo'],properties:{testo:{type:'string'}}}}}};
  if (bytes(payload) > work.limits.max_request_bytes) throw Error('MISSION_NARRATIVE_REQUEST_OVERFLOW');
  return {payload,signal};
}

function usageOf(out) {
  const m = out?.metrics;
  if (!object(m) || ['input_tokens','output_tokens','reasoning_tokens','total_tokens'].some(k=>!Number.isSafeInteger(m[k]) || m[k] < 0)) return null;
  return Object.fromEntries(['input_tokens','output_tokens','reasoning_tokens','total_tokens'].map(k=>[k,m[k]]));
}

// db è un adapter server fidato: non accetta nomi RPC dal client. finalize deve
// salvare il risultato e applicare il comando/pubblicare atomicamente per work_id.
// Una finalize incerta si osserva con status: non viene ripetuta né rigenerata.
export async function runMissionEvent({request,db,provider,now=()=>performance.now()}) {
  if (!validateRequest(request)) return reject('MISSION_REQUEST_INVALID');
  if (!db || ['claim','status','reject','authorize','consume','finalize'].some(k=>typeof db[k] !== 'function')
    || typeof provider?.create !== 'function') return reject('MISSION_ADAPTER_UNAVAILABLE');
  const started = now();
  let leaseDeadline = Infinity;
  async function bounded(ms,fn) {
    const available = Math.min(ms,180000-(now()-started),leaseDeadline-now());
    if (available <= 0) throw Error('MISSION_DISPATCH_TIMEOUT');
    const ctl = new AbortController(); let timer;
    try { return await Promise.race([Promise.resolve().then(()=>fn(ctl.signal)),new Promise((_,rejectTimeout)=>{
      timer=setTimeout(()=>{ctl.abort();rejectTimeout(Error('MISSION_DISPATCH_TIMEOUT'));},available);
    })]); } finally {clearTimeout(timer);}
  }
  const observe = async phase => {
    try {
      const s = await bounded(5000,signal=>db.status(request,{signal}));
      if (s?.schema_version === 'mission-generic-status/1' && s.master_session_id === request.master_session_id
        && s.event_id === request.event_id && s.request_key === request.request_key && s.revision === request.expected_revision
        && ['completed','failed'].includes(s.state) && uuid(s.receipt_id))
        return {status:200,code:s.state==='completed'?'MISSION_EVENT_COMPLETE':'MISSION_EVENT_FAILED',receipt_id:s.receipt_id,replay:true,retry:false,provider_retry_allowed:false};
    } catch { /* Non si interpreta un timeout come fallimento certo della mutazione. */ }
    return pending(phase);
  };
  let claim,work;
  const rejectClaim = async code => {
    // Only a validated lease can authenticate a definite local pre-provider failure.
    // A malformed/uncertain claim never becomes evidence of zero provider calls.
    if (!uuid(claim?.work?.lease_id)) return observe('validation');
    leaseDeadline=Infinity;
    try {
      const s=await bounded(10000,signal=>db.reject(request,claim.work.lease_id,code,{signal}));
      if (s?.schema_version==='mission-generic-status/1'&&s.master_session_id===request.master_session_id
        &&s.event_id===request.event_id&&s.request_key===request.request_key&&s.revision===request.expected_revision
        &&s.state==='failed'&&uuid(s.receipt_id))
        return {status:200,code:'MISSION_EVENT_FAILED',receipt_id:s.receipt_id,provider_calls:0,
          failure_code:code,retry:false,provider_retry_allowed:false};
    } catch { /* Observe an uncertain acknowledgement; do not repeat the rejection. */ }
    return observe('pre_provider_failure');
  };
  try { claim = await bounded(10000,signal=>db.claim(request,{signal})); }
  catch { return observe('claim'); }
  if (claim?.state !== 'claimed' || claim.granted_now !== true) return observe('claim');
  try { work=validateWork(claim.work,request); }
  catch {return rejectClaim('work_validation_failed');}
  leaseDeadline = started + Date.parse(work.lease_expires_at)-Date.parse(work.server_now);
  let context,providerRequest;
  try {
    if (work.kind === 'choice') {context=choiceContext(work);providerRequest=choiceRequest(context,work.limits,undefined);}
    else providerRequest=await narrativeRequest(work,undefined);
  } catch { return rejectClaim('request_validation_failed'); }
  // Modello, budget e cap appartengono al server. Ogni consumo copre una sola HTTP provider.
  let permission,dispatch;
  try {
    permission=await bounded(5000,signal=>db.authorize(work,{model:PROVIDER.model,reasoning_effort:PROVIDER.reasoning_effort,
      max_output_tokens:work.limits.max_output_tokens,store:false,payload_sha256:work.payload_sha256},{signal}));
    if (permission?.work_id !== work.work_id || permission.granted_now !== true || !uuid(permission.authorization_id)
      || permission.model !== PROVIDER.model || permission.reasoning_effort !== PROVIDER.reasoning_effort || permission.store !== false
      || permission.max_output_tokens !== work.limits.max_output_tokens) throw Error('MISSION_PROVIDER_PERMISSION_INVALID');
    dispatch=await bounded(5000,signal=>db.consume(work,permission,{signal}));
    if (dispatch?.work_id !== work.work_id || dispatch.authorization_id !== permission.authorization_id
      || !uuid(dispatch.dispatch_id) || dispatch.granted_now !== true) throw Error('MISSION_PROVIDER_CONSUME_INVALID');
  } catch { return observe('authorization'); }
  let received,result,calls=0,outcomeUncertain=false;
  try {
    received=await bounded(work.limits.provider_timeout_ms,signal=>{
      if (calls !== 0) throw Error('MISSION_SECOND_PROVIDER_FORBIDDEN'); calls++;
      return provider.create({...providerRequest,signal});
    });
    if (received.status !== 'completed') throw Error('MISSION_PROVIDER_INCOMPLETE');
    if (work.kind === 'choice') result={ok:true,command:choiceCommand(received.realization,context,work.limits),text:null};
    else {
      if (!exact(received.realization,['testo'])) throw Error('MISSION_NARRATIVE_FORMAT_INVALID');
      const checked=inspectNarrative(received.realization.testo,{providerComplete:true,transportMaxChars:work.limits.transport_max_chars});
      result={ok:checked.codes.length===0,text:checked.text,command:null,failure_codes:checked.codes,advisories:checked.advisories};
    }
  } catch(error) {
    received=received??error?.provider_result;
    outcomeUncertain=error.message==='MISSION_DISPATCH_TIMEOUT'||!received;
    result={ok:false,text:null,command:null,failure_codes:[error.message==='MISSION_DISPATCH_TIMEOUT'?'provider_outcome_unknown':'provider_or_validation_failed']};
  }
  const usage=usageOf(received);
  const delivery={schema_version:'mission-generic-result/1',work_id:work.work_id,master_session_id:work.master_session_id,
    event_id:work.event_id,request_key:request.request_key,revision:work.revision,authority_receipt_id:work.authority_receipt_id,
    definition_sha256:work.definition_sha256,payload_sha256:work.payload_sha256,kind:work.kind,
    runtime_version:RUNTIME_VERSION,editorial_version:EDITORIAL_VERSION,choice_version:work.kind==='choice'?CHOICE_VERSION:null,
    authorization_id:permission.authorization_id,dispatch_id:dispatch.dispatch_id,provider_calls:calls,model:PROVIDER.model,
    usage,usage_unknown:usage===null,provider_status:received?.status??null,outcome_uncertain:outcomeUncertain,
    raw_sha256:typeof received?.raw_output==='string'?await digest(received.raw_output):null,
    request_sha256:await digest(JSON.stringify(providerRequest.payload)),...result};
  const resultSha=await digest(canonical(delivery));
  // Anche se il provider ha superato il lease, la ricevuta dei costi va depositata;
  // finalize server respinge il comando/testo scaduto ma conserva l'audit del tentativo.
  leaseDeadline=Infinity;
  try {
    const done=await bounded(10000,signal=>db.finalize(work,delivery,resultSha,{signal}));
    if (done?.schema_version !== 'mission-generic-status/1' || done.work_id !== work.work_id
      || done.master_session_id !== work.master_session_id || done.event_id !== work.event_id
      || done.request_key !== request.request_key || done.revision !== request.expected_revision
      || done.result_sha256 !== resultSha || !uuid(done.receipt_id)
      || !['completed','failed','uncertain'].includes(done.state)) throw Error('MISSION_FINALIZE_INVALID');
    if(done.state==='uncertain')return {...pending('provider'),receipt_id:done.receipt_id,provider_calls:calls,
      usage,usage_unknown:usage===null};
    return {status:200,code:done.state==='completed'?'MISSION_EVENT_COMPLETE':'MISSION_EVENT_FAILED',receipt_id:done.receipt_id,
      provider_calls:calls,usage,usage_unknown:usage===null,retry:false,provider_retry_allowed:false};
  } catch { return observe('finalize'); }
}
