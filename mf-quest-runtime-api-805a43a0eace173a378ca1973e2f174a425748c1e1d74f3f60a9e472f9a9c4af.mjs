import {guardStaffAbortClient} from './mf-staff-simulation-abort-ui-690bd0bbb5f02971511480616c5b92b4d3e4d5eb5c3efa23cae1de4894f2298d.mjs';
// Consumer Quest runtime/1. Nessuna porta service, provider o autorità meccanica client.
export const QUEST_RUNTIME_BUILD='quest-runtime-ui/1';
export const QUEST_STAFF_LOCATION='0b85f354-9cdb-47e1-baf9-3d266bb7e06b';
const UUID=/^[0-9a-f]{8}-[0-9a-f]{4}-[1-8][0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}$/i;
const SHA=/^[0-9a-f]{64}$/i;
const phases=['enrollment_open','prepared','opening_pending','started','closing_pending','terminal','uncertain','unavailable'];
const fail=()=>{throw Error('Risposta Quest non coerente: rileggi lo stato.');};
const id=v=>{if(!UUID.test(v||''))fail();return v;};
const nullableId=v=>v===null?null:id(v);
const integer=v=>{if(!Number.isSafeInteger(v)||v<1)fail();return v;};
const bool=v=>{if(typeof v!=='boolean')fail();return v;};
const schema=(v,s)=>{if(!v||v.schema_version!==s)fail();return v;};
const pick=(v,keys)=>Object.fromEntries(keys.map(k=>[k,v[k]]));
const roster=v=>{if(!Array.isArray(v)||v.length<1||v.length>4||new Set(v).size!==v.length)fail();v.forEach(id);return [...v];};
function assignment(v){schema(v,'mission-factory-quest-roster/1');id(v.roster_assignment_id);id(v.draft_id);integer(v.roster_version);roster(v.member_character_ids);if(v.member_count!==v.member_character_ids.length||v.state!=='assigned')fail();return pick(v,['schema_version','roster_assignment_id','draft_id','roster_version','member_character_ids','member_count','state']);}
function participant(v,episode){schema(v,'quest-episode-participant-state/1');if(v.quest_episode_id!==episode||!phases.includes(v.phase))fail();id(v.character_id);bool(v.enrollment_open);bool(v.ready);if(![null,'joined','withdrawn'].includes(v.enrollment_state))fail();if(v.enrollment_control_version!==null)integer(v.enrollment_control_version);if(v.present_now!==null)bool(v.present_now);const actions={};for(const k of ['join','withdraw','ready'])actions[k]=bool(v.actions?.[k]);nullableId(v.native_session_id);if(['started','closing_pending','terminal'].includes(v.phase)){id(v.native_session_id);}else if(v.native_session_id!==null)fail();let terminal=null;if(v.phase==='terminal'){const t=schema(v.terminal,'quest-episode-terminal-public/1');if(t.quest_episode_id!==episode||!['success','failure'].includes(t.outcome)||t.reward_state!=='pending_staff'||t.next_episode_eligible!==false)fail();id(t.native_terminal_receipt_id);terminal=pick(t,['schema_version','quest_episode_id','native_terminal_receipt_id','outcome','reward_state','next_episode_eligible']);}else if(v.terminal!==null)fail();return {...pick(v,['schema_version','quest_episode_id','character_id','phase','enrollment_open','enrollment_state','ready','enrollment_control_version','present_now','native_session_id']),actions,terminal};}
export function episodeState(v,episode){const contextVersion=v?.schema_version==='quest-episode-runtime-state/4';schema(v,contextVersion?'quest-episode-runtime-state/4':'quest-episode-runtime-state/2');rewardKeys(v,['schema_version','quest_arc_id','quest_episode_id','episode_ordinal','source_sha256','previous_episode_terminal_receipt_id','native_session_id','prepare_request_key','start_request_key','state','enrollment_open','prepare_ready','assignment','actions','availability',...(contextVersion?['execution_context']:[])]);const availability=episodeAvailability(v.availability);const execution_context=contextVersion?executionContext(v.execution_context,'episode'):null;if(execution_context?.mode==='public_real'&&availability.scope!=='public')fail();if(v.quest_episode_id!==episode)fail();id(v.quest_arc_id);integer(v.episode_ordinal);if(!SHA.test(v.source_sha256||''))fail();nullableId(v.previous_episode_terminal_receipt_id);nullableId(v.native_session_id);nullableId(v.prepare_request_key);nullableId(v.start_request_key);bool(v.enrollment_open);bool(v.prepare_ready);if(!['source_only','published','prepared','opening_pending','started','closing_pending','terminal','uncertain','draft','cancelled','open','in_progress','completed','failed'].includes(v.state))fail();const actions={};for(const k of ['assign_roster','prepare','start'])actions[k]=bool(v.actions?.[k]);return {...pick(v,['schema_version','quest_arc_id','quest_episode_id','episode_ordinal','source_sha256','previous_episode_terminal_receipt_id','native_session_id','prepare_request_key','start_request_key','state','enrollment_open','prepare_ready']),assignment:assignment(v.assignment),actions,availability,...(contextVersion?{execution_context}:{})};}
function enrollment(v,p){schema(v,'quest-episode-enrollment/1');if(v.request_key!==p.p_request||v.quest_episode_id!==p.p_episode||!['joined','withdrawn'].includes(v.state))fail();id(v.character_id);id(v.roster_assignment_id);bool(v.ready);integer(v.control_version);if(!SHA.test(v.source_sha256||''))fail();if(p.p_operation==='withdraw'&&v.state!=='withdrawn'||p.p_operation!=='withdraw'&&v.state!=='joined'||p.p_operation==='ready'&&v.ready!==p.p_ready)fail();return pick(v,['schema_version','request_key','quest_episode_id','character_id','state','ready','control_version']);}
function prepare(v,p){schema(v,'quest-episode-prepare/1');if(v.request_key!==p.p_request||v.quest_arc_id!==p.p_arc||v.quest_episode_id!==p.p_episode||v.location_id!==p.p_location||v.state!=='prepared'||v.opening_publication_id!==null)fail();id(v.native_session_id);id(v.plan_version_id);integer(v.control_version);for(const k of ['source_sha256','plan_sha256','roster_snapshot_sha256','staff_release_sha256'])if(!SHA.test(v[k]||''))fail();return pick(v,['schema_version','request_key','quest_arc_id','quest_episode_id','native_session_id','location_id','state','control_version','opening_publication_id']);}
function start(v,p){schema(v,'quest-episode-start/1');if(v.request_key!==p.p_request||v.prepare_request_key!==p.p_prepare_request||!['opening_pending','started','uncertain'].includes(v.state))fail();id(v.native_session_id);id(v.start_event_id);nullableId(v.opening_publication_id);integer(v.run_control_version);if(!['not_authorized','authorized','started','success','unknown_billable','failed_no_call'].includes(v.provider_attempt_state))fail();if(v.state==='started')id(v.opening_publication_id);return pick(v,['schema_version','request_key','prepare_request_key','state','native_session_id','start_event_id','opening_publication_id','run_control_version','provider_attempt_state']);}
const mutations={
 enrollment:{rpc:'mission_factory_quest_enrollment_v1',validate:enrollment},
 prepare:{rpc:'mission_factory_quest_prepare_v1',validate:prepare},
 start:{rpc:'mission_factory_quest_start_v1',validate:start},
 assign:{rpc:'mission_factory_quest_episode_roster_assign_v1',validate:(v,p)=>{schema(v,'quest-episode-roster-assigned/1');if(v.request_key!==p.p_request||v.quest_episode_id!==p.p_episode)fail();id(v.quest_arc_id);const a=assignment(v.assignment);if(JSON.stringify([...a.member_character_ids].sort())!==JSON.stringify([...p.p_character_ids].sort()))fail();return {schema_version:v.schema_version,request_key:v.request_key,quest_arc_id:v.quest_arc_id,quest_episode_id:v.quest_episode_id,assignment:a};}}
};
function params(op,p,episode){id(p.p_request);const keys={enrollment:['p_episode','p_operation','p_ready','p_expected_version','p_request'],prepare:['p_arc','p_episode','p_location','p_roster','p_request'],start:['p_prepare_request','p_expected_control_version','p_request'],assign:['p_episode','p_character_ids','p_request']}[op];if(!keys||Object.keys(p).sort().join()!==[...keys].sort().join())fail();if(op!=='start'&&p.p_episode!==episode)fail();if(op==='enrollment'){if(!['join','withdraw','ready'].includes(p.p_operation))fail();if(p.p_operation==='join'){if(p.p_ready!==null||p.p_expected_version!==null)fail();}else{integer(p.p_expected_version);if(p.p_operation==='ready')bool(p.p_ready);else if(p.p_ready!==null)fail();}}if(op==='prepare'){id(p.p_arc);id(p.p_location);roster(p.p_roster);}if(op==='start'){id(p.p_prepare_request);integer(p.p_expected_control_version);}if(op==='assign')roster(p.p_character_ids);return JSON.parse(JSON.stringify(p));}

const rewardKeys=(v,keys)=>{if(!v||typeof v!=='object'||Array.isArray(v)||Object.keys(v).sort().join()!==[...keys].sort().join())fail();};
const rewardSha=v=>{if(!SHA.test(v||''))fail();return v;};
function rewardDecision(v){
 schema(v,'quest-arc-reward-receipt/2');rewardKeys(v,['schema_version','decision_id','arc_id','terminal_receipt_id','outcome','source_sha256','policy_id','policy_sha256','eligibility_sha256','recipient_count','state','effect_mode','computed_xp_per_recipient','effective_xp_per_recipient','ryo_per_recipient','items']);
 for(const k of ['decision_id','arc_id','terminal_receipt_id','policy_id'])id(v[k]);
 for(const k of ['source_sha256','policy_sha256','eligibility_sha256'])rewardSha(v[k]);integer(v.recipient_count);
 if(v.recipient_count>128||!['success','failure'].includes(v.outcome)||v.computed_xp_per_recipient!==30||v.ryo_per_recipient!==0||!Array.isArray(v.items)||v.items.length)fail();
 if(v.effect_mode==='simulation'){if(v.state!=='simulated'||v.effective_xp_per_recipient!==0)fail();}
 else if(v.effect_mode==='real'){if(v.state!=='applied'||v.effective_xp_per_recipient!==30)fail();}else fail();
 return JSON.parse(JSON.stringify(v));
}
function rewardAward(v){
 schema(v,'quest-recipient-reward/2');rewardKeys(v,['schema_version','award_id','decision_id','arc_id','character_id','effect_mode','computed_xp','effective_xp','ryo','items']);
 for(const k of ['award_id','decision_id','arc_id','character_id'])id(v[k]);
 if(v.computed_xp!==30||v.ryo!==0||!Array.isArray(v.items)||v.items.length||!['simulation','real'].includes(v.effect_mode)||v.effective_xp!==(v.effect_mode==='simulation'?0:30))fail();
 return JSON.parse(JSON.stringify(v));
}
function rewardAbortBinding(v,state){
 if(v===null)return null;
 schema(v,'quest-reward-abort-binding/1');rewardKeys(v,['schema_version','actor_auth_id','arc_id','terminal_receipt_id','decision_id','native_session_id','terminal_episode_id','arc_source_sha256','policy_sha256','native_master_control_version','native_run_control_version','effect_mode','qualification_sha256','binding_sha256']);
 for(const k of ['actor_auth_id','arc_id','terminal_receipt_id','native_session_id','terminal_episode_id'])id(v[k]);nullableId(v.decision_id);
 for(const k of ['arc_source_sha256','policy_sha256','qualification_sha256','binding_sha256'])rewardSha(v[k]);
 integer(v.native_master_control_version);integer(v.native_run_control_version);
 if(!['pending_award','simulated','applied'].includes(state.state)||!['simulation','real'].includes(v.effect_mode)||v.arc_id!==state.arc_id||v.terminal_receipt_id!==state.terminal_receipt_id||v.arc_source_sha256!==state.source_sha256||v.policy_sha256!==state.policy_sha256||!state.qualification.qualified||v.effect_mode!==state.qualification.effect_mode||v.decision_id!==(state.decision?.decision_id??null))fail();
 // Hash opaco del producer: il client verifica shape/pin, non ricostruisce autorità Native.
 return Object.freeze({...v});
}
function episodeAvailability(v){
 rewardKeys(v,['scope','release_sha256','location_policy']);if(!['staff','public'].includes(v.scope))fail();rewardSha(v.release_sha256);
 if(v.location_policy!==(v.scope==='staff'?'staff_test':'public_active_non_test_non_exam'))fail();return Object.freeze({...v});
}
function rewardAvailability(v){rewardKeys(v,['scope','release_sha256']);if(!['staff','public'].includes(v.scope))fail();if(v.scope==='public')rewardSha(v.release_sha256);else if(v.release_sha256!==null)rewardSha(v.release_sha256);return Object.freeze({...v});}
function rewardPublicBinding(v,state){
 if(v===null)return null;
 schema(v,'quest-reward-public-writer-binding/3');rewardKeys(v,['schema_version','actor_auth_id','arc_id','terminal_receipt_id','decision_id','native_session_id','terminal_episode_id','arc_source_sha256','policy_sha256','native_master_control_version','native_run_control_version','effect_mode','qualification_sha256','binding_sha256']);
 for(const k of ['actor_auth_id','arc_id','terminal_receipt_id','native_session_id','terminal_episode_id'])id(v[k]);nullableId(v.decision_id);
 for(const k of ['arc_source_sha256','policy_sha256','qualification_sha256','binding_sha256'])rewardSha(v[k]);integer(v.native_master_control_version);integer(v.native_run_control_version);
 if(state.availability?.scope!=='public'||!state.qualification.qualified||!state.qualification.real_qualified||!state.qualification.public_admitted||v.effect_mode!=='real'||state.qualification.effect_mode!=='real'||v.arc_id!==state.arc_id||v.terminal_receipt_id!==state.terminal_receipt_id||v.arc_source_sha256!==state.source_sha256||v.policy_sha256!==state.policy_sha256||v.decision_id!==(state.decision?.decision_id??null)||!['pending_award','applied'].includes(state.state))fail();
 // Opaque server proof binds the terminal Native session, never the displayed episode.
 return Object.freeze({...v});
}
export function executionContext(v,kind){
 rewardKeys(v,['mode','logical_visibility','public_general_available','qualification_sha256',...(kind==='episode'?['logical_due_at','location_id']:kind==='publish'?['logical_due_at']:[])]);
 if(!['staff_simulation','public_real'].includes(v.mode)||![null,'open','scheduled'].includes(v.logical_visibility)||(kind==='publish'||v.mode==='public_real')&&v.logical_visibility===null)fail();bool(v.public_general_available);if(v.qualification_sha256!==null)rewardSha(v.qualification_sha256);
 if(kind==='episode'||kind==='publish'){if(v.logical_due_at!==null&&(typeof v.logical_due_at!=='string'||!/^\d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2}(?:\.\d+)?(?:Z|[+-]\d{2}:\d{2})$/.test(v.logical_due_at)||!Number.isFinite(Date.parse(v.logical_due_at))))fail();if(v.logical_visibility==='scheduled'&&v.logical_due_at===null||v.logical_visibility!=='scheduled'&&v.logical_due_at!==null)fail();}
 if(v.mode==='staff_simulation'&&v.logical_visibility!==null&&v.qualification_sha256===null)fail();
 if(kind==='episode'&&(v.mode==='staff_simulation'?v.location_id!==QUEST_STAFF_LOCATION:v.location_id!==null))fail();
 return Object.freeze({...v});
}
const realExecution=v=>v.execution_context?v.execution_context.mode==='public_real':v.availability?.scope==='public';
function rewardStateShape(v,arc){
 const contextVersion=v?.schema_version==='quest-arc-reward-state/4',publicVersion=contextVersion||v?.schema_version==='quest-arc-reward-state/3';schema(v,contextVersion?'quest-arc-reward-state/4':publicVersion?'quest-arc-reward-state/3':'quest-arc-reward-state/2');const execution_context=contextVersion?executionContext(v.execution_context,'reward'):null;const real=contextVersion?execution_context.mode==='public_real':publicVersion&&v.availability?.scope==='public';const availability=publicVersion?rewardAvailability(v.availability):null;rewardKeys(v,['schema_version','arc_id','state','policy_id','policy_sha256','source_sha256','policy_schema_version','policy_document','terminal_receipt_id','eligibility_state','qualification','actions','decision','awards','abort_binding',...(publicVersion?['availability','public_writer_binding']:[]),...(contextVersion?['execution_context']:[])]);
 id(arc);if(v.arc_id!==arc||!['legacy','unqualified','pending_award','not_terminal','uncertain','simulated','applied'].includes(v.state))fail();
 id(v.policy_id);rewardSha(v.policy_sha256);rewardSha(v.source_sha256);nullableId(v.terminal_receipt_id);
 if(!['confirmed','unknown','not_terminal','not_evaluated'].includes(v.eligibility_state))fail();
 if(v.policy_schema_version==='mission-factory-quest-reward-policy/2'){
  const d=v.policy_document;rewardKeys(d,['schema_version','recipient_mode','xp_per_eligible_recipient','ryo_per_eligible_recipient','items','terminal_outcomes','award_scope']);
  if(d.schema_version!==v.policy_schema_version||d.recipient_mode!=='uniform'||d.xp_per_eligible_recipient!==30||d.ryo_per_eligible_recipient!==0||!Array.isArray(d.items)||d.items.length||JSON.stringify(d.terminal_outcomes)!=='["success","failure"]'||d.award_scope!=='arc_once_per_character'||v.state==='legacy')fail();
 }else if(v.policy_schema_version==='mission-factory-quest-reward-policy/1'){
  schema(v.policy_document,v.policy_schema_version);if(v.state!=='legacy'||v.decision!==null)fail();
 }else fail();
 const q=v.qualification;rewardKeys(q,['qualified','staff_admitted','effect_mode','real_qualified','reason_code',...(publicVersion?['public_admitted']:[])]);bool(q.qualified);bool(q.staff_admitted);bool(q.real_qualified);
 if(publicVersion)bool(q.public_admitted);
 if((!publicVersion&&q.real_qualified!==false)||![null,'simulation','real'].includes(q.effect_mode)||(q.reason_code!==null&&!/^MF_[A-Z0-9_]+$/.test(q.reason_code||'')))fail();
 if(q.qualified&&(q.reason_code!==null||v.eligibility_state!=='confirmed'))fail();
 if(real){if(!publicVersion||availability.scope!=='public')fail();if(q.real_qualified!==q.qualified||q.qualified&&(!q.public_admitted||!q.staff_admitted||q.effect_mode!=='real'))fail();}
 else if(q.real_qualified||publicVersion&&q.public_admitted||q.qualified&&(!q.staff_admitted||q.effect_mode!=='simulation'))fail();
 rewardKeys(v.actions,['base_recover','staff_extra']);bool(v.actions.base_recover);bool(v.actions.staff_extra);
 if((v.actions.base_recover||v.actions.staff_extra)&&!q.qualified)fail();
 if(v.actions.base_recover&&(v.state!=='pending_award'||v.decision!==null||v.terminal_receipt_id===null))fail();
 if(v.actions.staff_extra&&(v.decision===null||!['simulation',...(real?['real']:[])].includes(q.effect_mode)))fail();
 if(!Array.isArray(v.awards))fail();const awards=v.awards.map(rewardAward);if(new Set(awards.map(x=>x.character_id)).size!==awards.length)fail();
 const decision=v.decision===null?null:rewardDecision(v.decision);
 if(decision){if(decision.arc_id!==arc||decision.policy_id!==v.policy_id||decision.policy_sha256!==v.policy_sha256||decision.source_sha256!==v.source_sha256||decision.state!==v.state||decision.terminal_receipt_id!==v.terminal_receipt_id||awards.length>decision.recipient_count)fail();
  for(const a of awards)if(a.arc_id!==arc||a.decision_id!==decision.decision_id||a.effect_mode!==decision.effect_mode)fail();
 }else if(awards.length||!['legacy','unqualified','pending_award','not_terminal','uncertain'].includes(v.state))fail();
 const abort_binding=rewardAbortBinding(v.abort_binding,{...v,decision});
 const public_writer_binding=publicVersion?rewardPublicBinding(v.public_writer_binding,{...v,decision,availability}):null;
 if(real?abort_binding!==null:public_writer_binding!==null)fail();if(contextVersion){const expected=real?'real':'simulation';if(q.effect_mode!==null&&q.effect_mode!==expected||decision&&decision.effect_mode!==expected||awards.some(a=>a.effect_mode!==expected))fail();if(!real&&abort_binding&&abort_binding.effect_mode!=='simulation')fail();}
 if((v.actions.base_recover||v.actions.staff_extra)&&abort_binding===null&&public_writer_binding===null)fail();
 if(v.state==='legacy'&&(abort_binding!==null||public_writer_binding!==null))fail();
 return {...v,decision,awards,abort_binding,...(publicVersion?{availability,public_writer_binding}:{}),...(contextVersion?{execution_context}:{})};
}
function rewardByEpisodeShape(v,episode,character,terminal){
 const contextVersion=v?.schema_version==='quest-episode-reward-state/4',publicVersion=contextVersion||v?.schema_version==='quest-episode-reward-state/3';schema(v,contextVersion?'quest-episode-reward-state/4':publicVersion?'quest-episode-reward-state/3':'quest-episode-reward-state/2');rewardKeys(v,['schema_version','quest_episode_id','character_id','episode_terminal_receipt_id','reward']);
 id(episode);id(character);id(terminal);
 if(v.quest_episode_id!==episode||v.character_id!==character||v.episode_terminal_receipt_id!==terminal)fail();
 const reward=rewardStateShape(v.reward,id(v.reward?.arc_id));
 if((publicVersion&&reward.schema_version!==(contextVersion?'quest-arc-reward-state/4':'quest-arc-reward-state/3'))||reward.abort_binding!==null||(reward.public_writer_binding??null)!==null||reward.actions.base_recover||reward.actions.staff_extra||reward.awards.some(a=>a.character_id!==character))fail();
 return {...v,reward};
}
function rewardExtra(v,p,effect='simulation'){
 schema(v,'quest-staff-extra-receipt/2');rewardKeys(v,['schema_version','request_key','decision_id','arc_id','character_id','reward_kind','computed_xp','effective_xp','effect_mode']);
 if(v.request_key!==p.p_request||v.arc_id!==p.p_arc||v.character_id!==p.p_character||v.reward_kind!=='quest_staff_extra'||v.computed_xp!==p.p_amount)fail();id(v.decision_id);
 if(!['simulation','real'].includes(effect)||v.effect_mode!==effect||v.effective_xp!==(effect==='simulation'?0:p.p_amount))throw Error('Ricevuta extra non coerente con la disponibilità verificata.');
 return JSON.parse(JSON.stringify(v));
}
function rewardParams(op,p,arc){
 const keys=op==='base'?['p_arc','p_terminal_receipt','p_expected_arc_source_sha256','p_expected_policy_sha256','p_request']:op==='extra'?['p_arc','p_character','p_amount','p_reason','p_request']:null;
 if(!keys)fail();rewardKeys(p,keys);if(p.p_arc!==arc)fail();id(arc);id(p.p_request);
 if(op==='base'){id(p.p_terminal_receipt);rewardSha(p.p_expected_arc_source_sha256);rewardSha(p.p_expected_policy_sha256);}
 else {id(p.p_character);integer(p.p_amount);if(p.p_amount>2147483647||typeof p.p_reason!=='string'||p.p_reason!==p.p_reason.trim()||p.p_reason.length<1||p.p_reason.length>1000)fail();}
 return JSON.parse(JSON.stringify(p));
}
function rewardBase(v,p,effect='simulation'){const d=rewardDecision(v);if(d.arc_id!==p.p_arc||d.terminal_receipt_id!==p.p_terminal_receipt||d.source_sha256!==p.p_expected_arc_source_sha256||d.policy_sha256!==p.p_expected_policy_sha256)fail();
 if(!['simulation','real'].includes(effect)||d.effect_mode!==effect||d.effective_xp_per_recipient!==(effect==='simulation'?0:30))throw Error('Ricevuta premio non coerente con la disponibilità verificata.');return d;}
export function questRewardServerReason(error){return String(error?.message||'').match(/\bMF_[A-Z0-9_]+\b/)?.[0]||(['PGRST202','42883','42501','55000'].includes(error?.code)?error.code:null);}

export function createQuestRuntimeApi(client,{identity,isCurrent=()=>true,currentSession=()=>null,storage=globalThis.sessionStorage}={}){
 if(typeof client?.rpc!=='function'||typeof identity!=='function')fail();
 const authorityClient=client[Symbol.for('tus.staff-abort-guarded/1')]||client;
 const initialActor=id(identity());let disposed=false,generation=0;
 const invalidate=()=>{generation++;};
 const authSubscription=client.auth?.onAuthStateChange?.((_event,session)=>{if(session?.user?.id!==initialActor)invalidate();})?.data?.subscription;
 client=guardStaffAbortClient(client,{identity,session:currentSession});
 const owner=()=>{if(disposed||!isCurrent())throw Error('Contesto cambiato: riapri Quest.');const actor=id(identity());if(actor!==initialActor)throw Error('Accesso cambiato: riapri il pannello Quest.');return actor;};
 const same=actor=>{if(owner()!==actor)throw Error('Accesso cambiato: riapri il pannello Quest.');};
 async function call(name,p,binding=null){const actor=owner(),revision=generation;
   const live=()=>{same(actor);if(revision!==generation)throw Error('Contesto cambiato: rileggi lo stato Quest.');};
   if(typeof client.auth?.getSession!=='function')throw Error('Accesso Quest non verificabile.');const auth=await client.auth.getSession();live();
   if(auth.error||auth.data?.session?.user?.id!==actor)throw Error('Accedi nuovamente prima di usare Quest.');
   if(binding!==null){
    if(typeof client.auth?.getUser!=='function')throw Error('Soggetto Auth premio non verificabile.');
    const verified=await client.auth.getUser();live();
    if(verified.error||verified.data?.user?.id!==actor||binding.actor_auth_id!==actor)throw Error('QUEST_REWARD_ABORT_BINDING_MISMATCH');
   }
   // Closure separata per questa invocazione: mai un binding globale o currentSession.
   const publicWriter=binding?.schema_version==='quest-reward-public-writer-binding/3'&&binding.effect_mode==='real';
   if(publicWriter&&!['mission_factory_quest_reward_apply_v2','mission_factory_quest_reward_staff_extra_v2'].includes(name))fail();
   const invocation=publicWriter?authorityClient:binding===null?client:guardStaffAbortClient(client,{identity:()=>{live();return actor;},rewardBinding:()=>{live();return binding;}});
   live();const r=await invocation.rpc(name,p);live();if(r.error)throw r.error;return r.data;
 }
 const key=(actor,episode)=>`quest-runtime-journal/1/${actor}/${id(episode)}`;
 function read(episode){const actor=owner();let raw;try{raw=storage.getItem(key(actor,episode));}catch{throw Error('Recupero locale non disponibile: nessun comando inviato.');}if(!raw)return {schema_version:'quest-runtime-journal/1',actor,episode,pending:null,receipts:{}};let v;try{v=JSON.parse(raw);}catch{fail();}if(v.schema_version!=='quest-runtime-journal/1'||v.actor!==actor||v.episode!==episode||!v.receipts||typeof v.receipts!=='object')fail();if(v.pending){params(v.pending.operation,v.pending.params,episode);if(!mutations[v.pending.operation])fail();}return v;}
 function write(v){same(v.actor);const encoded=JSON.stringify(v);try{storage.setItem(key(v.actor,v.episode),encoded);if(storage.getItem(key(v.actor,v.episode))!==encoded)throw Error();}catch{throw Error('Richiesta conservata solo in memoria: recupero locale non disponibile. Nessun nuovo comando inviato.');}return v;}
 function confirm(episode,op,p,value){const v=read(episode);if(!v.pending||v.pending.operation!==op||JSON.stringify(v.pending.params)!==JSON.stringify(p))fail();v.receipts[op]={params:p,receipt:value};v.pending=null;write(v);return value;}
 async function runState(request){id(request);const v=schema(await call('mission_factory_quest_run_state_v1',{p_request:request}),'quest-episode-run-state/1');if(v.request_key!==request||!['unknown','prepared','opening_pending','started','closing_pending','terminal','uncertain'].includes(v.state))fail();if(v.state==='unknown'){if(v.operation!==null||v.receipt!==null||v.run_control_version!==null||v.opening_publication_id!==null)fail();}else{if(!['prepare','start','terminal'].includes(v.operation))fail();integer(v.run_control_version);nullableId(v.opening_publication_id);if(['started','closing_pending','terminal'].includes(v.state))id(v.opening_publication_id);}
 if(v.state!=='unknown'&&v.state!=='uncertain'){
 const expected=v.state==='terminal'?'quest-episode-terminal/1':`quest-episode-${v.operation}/1`;
 schema(v.receipt,expected);id(v.receipt.native_session_id);
 if(v.state!=='terminal'&&v.receipt.request_key!==request)fail();
 if(v.state==='terminal'){id(v.receipt.quest_episode_id);id(v.receipt.native_terminal_receipt_id);if(!['success','failure'].includes(v.receipt.outcome)||v.receipt.reward_state!=='pending_staff'||v.receipt.next_episode_eligible!==false)fail();}
 }
 // Private Staff receipt non è mai propagata al pannello partecipanti.
 return v;}
 async function recover(episode){const v=read(episode),pending=v.pending;if(!pending)return null;const {operation:op,params:p}=pending;if(op==='assign')return {state:'unknown',retry_explicit:true};if(op==='enrollment'){const r=schema(await call('mission_factory_quest_enrollment_request_state_v1',{p_request:p.p_request}),'quest-episode-enrollment-request-state/1');if(r.request_key!==p.p_request||!['committed','unknown'].includes(r.state)||r.state==='unknown'&&r.receipt!==null)fail();if(r.state==='committed')return {state:'committed',receipt:confirm(episode,op,p,enrollment(r.receipt,p))};return {state:'unknown',retry_explicit:true};}const r=await runState(p.p_request);if(r.state==='unknown'||r.state==='uncertain')return {state:r.state,retry_explicit:true};if(r.operation!==op)fail();if(r.receipt?.schema_version===`quest-episode-${op}/1`)confirm(episode,op,p,mutations[op].validate(r.receipt,p));else if(['closing_pending','terminal','started'].includes(r.state)){// La request resta recuperabile: receipt storica sostituita dal reader corrente.
 const j=read(episode);j.receipts[op]={params:p,receipt:null,confirmed_state:r.state};j.pending=null;write(j);
 }else fail();return {state:r.state,run:r};}
 async function send(episode,op,p,{replay=false}={}){id(episode);const original=params(op,p,episode);
 if(op==='prepare'&&!replay){const current=episodeState(await call('mission_factory_quest_episode_state_v4',{p_episode:episode}),episode);if(current.quest_arc_id!==original.p_arc||!current.actions.prepare||!current.prepare_ready)fail();const allowed=await locations(current.availability,current.execution_context);if(!allowed.some(x=>x.id===original.p_location))throw Error('Chat non disponibile per questa puntata. Rileggi lo stato.');}
 const journal=read(episode);if(replay){if(!journal.pending||journal.pending.operation!==op||JSON.stringify(journal.pending.params)!==JSON.stringify(original))fail();}else{if(journal.pending)throw Error('Una richiesta è da riconciliare: aggiorna prima il suo stato.');journal.pending={operation:op,params:original};write(journal);}try{return confirm(episode,op,original,mutations[op].validate(await call(mutations[op].rpc,original),original));}catch(error){
 // Solo rigetti iscrizione nominati dal contratto consentono liberare la richiesta.
 if(op==='enrollment'&&['MF_QUEST_ENROLLMENT_CLOSED','MF_QUEST_CHARACTER_BUSY','MF_QUEST_NOT_JOINED','MF_QUEST_ENROLLMENT_CAS','MF_QUEST_ENROLLMENT_SOURCE_DRIFT'].some(code=>String(error.message||'').includes(code))){const r=await recover(episode);if(r?.state==='committed')return r.receipt;const st=await call('mission_factory_quest_participant_state_v1',{p_episode:episode});participant(st,episode);const j=read(episode);if(j.pending&&JSON.stringify(j.pending.params)===JSON.stringify(original)){j.pending=null;write(j);throw Error('Iscrizione non eseguita: lo stato è stato riletto. Scegli nuovamente dopo aver verificato la squadra.');}}
 throw Error('Operazione non confermata. Usa Aggiorna stato; la stessa richiesta viene conservata.');}}

 const rewardKey=(actor,arc)=>`quest-reward-ui-journal/2/${actor}/${id(arc)}`;
 function readReward(arc){const actor=owner();let raw;try{raw=storage.getItem(rewardKey(actor,arc));}catch{throw Error('Recupero premi non disponibile: nessuna richiesta inviata.');}
   if(!raw)return {schema_version:'quest-reward-ui-journal/2',actor,arc,pending:null,receipts:{}};
   let v;try{v=JSON.parse(raw);}catch{fail();}if(v.schema_version!=='quest-reward-ui-journal/2'||v.actor!==actor||v.arc!==arc||!v.receipts||typeof v.receipts!=='object'||Array.isArray(v.receipts))fail();
   if(v.pending)rewardParams(v.pending.operation,v.pending.params,arc);return v;
 }
 function writeReward(v){same(v.actor);const encoded=JSON.stringify(v);try{storage.setItem(rewardKey(v.actor,v.arc),encoded);if(storage.getItem(rewardKey(v.actor,v.arc))!==encoded)throw Error();}catch{throw Error('Journal premi non verificabile: nessuna nuova richiesta può partire.');}return v;}
 function confirmReward(arc,op,p,value){const v=readReward(arc);if(!v.pending||v.pending.operation!==op||JSON.stringify(v.pending.params)!==JSON.stringify(p))fail();v.receipts[op]={params:p,receipt:value};v.pending=null;writeReward(v);return value;}
 async function sendReward(arc,op,p,{replay=false}={}){const actor=owner(),revision=generation,original=rewardParams(op,p,arc);
   const current=rewardStateShape(await call('mission_factory_quest_reward_state_v4',{p_arc:id(arc)}),arc);
   same(actor);if(revision!==generation)throw Error('Contesto cambiato: rileggi il premio.');
   const binding=realExecution(current)?current.public_writer_binding:current.abort_binding;
   if(binding===null)throw Error(current.qualification.reason_code||'QUEST_REWARD_ABORT_BINDING_REQUIRED');
   if(binding.actor_auth_id!==actor)throw Error('QUEST_REWARD_ABORT_BINDING_MISMATCH');
   if(!current.actions[op==='base'?'base_recover':'staff_extra'])throw Error(current.qualification.reason_code||'Operazione premio non offerta dal server.');
   const effect=realExecution(current)?'real':'simulation';
   if(current.qualification.effect_mode!==effect||effect==='real'&&!current.qualification.real_qualified)throw Error('Disponibilità premio non qualificata.');
   if(op==='base'&&(current.terminal_receipt_id!==original.p_terminal_receipt||current.source_sha256!==original.p_expected_arc_source_sha256||current.policy_sha256!==original.p_expected_policy_sha256))fail();
   if(op==='extra'&&!current.awards.some(a=>a.character_id===original.p_character))fail();
   const v=readReward(arc);
   if(replay){if(!v.pending||v.pending.operation!==op||JSON.stringify(v.pending.params)!==JSON.stringify(original))fail();}
   else {if(v.pending)throw Error('Premio da riconciliare: conserva UUID e payload.');v.pending={operation:op,params:original};writeReward(v);}
   const value=await call(op==='base'?'mission_factory_quest_reward_apply_v2':'mission_factory_quest_reward_staff_extra_v2',original,binding);
   if(op==='extra'&&value?.decision_id!==binding.decision_id)fail();
   return confirmReward(arc,op,original,op==='base'?rewardBase(value,original,effect):rewardExtra(value,original,effect));
 }
 async function recoverReward(arc){const pending=readReward(arc).pending;if(!pending)return null;const op=pending.operation,p=pending.params;
   const v=await call(op==='base'?'mission_factory_quest_reward_request_state_v2':'mission_factory_quest_reward_extra_request_state_v2',{p_request:p.p_request});
   schema(v,op==='base'?'quest-reward-request-state/2':'quest-staff-extra-request-state/2');
   rewardKeys(v,op==='base'?['schema_version','request_key','state','receipt','arc_id']:['schema_version','request_key','state','receipt']);
   if(v.request_key!==p.p_request||!['unknown','simulated','applied'].includes(v.state))fail();
   if(v.state==='unknown'){if(v.receipt!==null||(op==='base'&&v.arc_id!==null))fail();return v;}
   if(op==='base'&&v.arc_id!==arc)fail();const current=rewardStateShape(await call('mission_factory_quest_reward_state_v4',{p_arc:id(arc)}),arc);
   const effect=realExecution(current)?'real':'simulation';
   if(!current.qualification.qualified||current.qualification.effect_mode!==effect||effect==='real'&&!current.qualification.real_qualified)fail();
   const receipt=op==='base'?rewardBase(v.receipt,p,effect):rewardExtra(v.receipt,p,effect);
   confirmReward(arc,op,p,receipt);return {...v,receipt};
 }
 async function rewardCatalog(){const v=await call('mission_factory_quest_reward_catalog_v2',{});schema(v,'quest-reward-catalog/2');rewardKeys(v,['schema_version','reward_policies']);
   if(!Array.isArray(v.reward_policies))fail();for(const x of v.reward_policies){id(x.id);rewardSha(x.policy_sha256);if(x.scope!=='staff'||x.qualified!==true||!x.allowed_content_kinds?.includes('quest_ai'))fail();
     const d=x.document;rewardKeys(d,['schema_version','recipient_mode','xp_per_eligible_recipient','ryo_per_eligible_recipient','items','terminal_outcomes','award_scope']);
     if(d.schema_version!=='mission-factory-quest-reward-policy/2'||d.recipient_mode!=='uniform'||d.xp_per_eligible_recipient!==30||d.ryo_per_eligible_recipient!==0||!Array.isArray(d.items)||d.items.length||JSON.stringify(d.terminal_outcomes)!=='["success","failure"]'||d.award_scope!=='arc_once_per_character')fail();
   }return v;
 }

 async function locations(availability,context=null){
   const av=episodeAvailability(availability),actor=owner(),revision=generation;
   if(context){const ctx=executionContext(context,'episode');if(ctx.mode==='staff_simulation')return [{id:ctx.location_id,name:'Staff Test Room'}];}else if(av.scope==='staff')return [{id:QUEST_STAFF_LOCATION,name:'Staff Test Room'}];
   if(typeof authorityClient.from!=='function'||typeof authorityClient.auth?.getSession!=='function')throw Error('Chat pubbliche non verificabili.');
   const auth=await authorityClient.auth.getSession();same(actor);if(revision!==generation||auth.error||auth.data?.session?.user?.id!==actor)throw Error('Accesso cambiato: rileggi le chat.');
   // Native locations via ordinary Auth/RLS. Prepare locks and rechecks the same policy server-side.
   const out=await authorityClient.from('locations').select('id,name,is_active,is_test,is_exam_room').eq('is_active',true).eq('is_test',false).or('is_exam_room.is.null,is_exam_room.eq.false');
   same(actor);if(revision!==generation)throw Error('Contesto cambiato: rileggi le chat.');if(out.error)throw out.error;if(!Array.isArray(out.data))fail();
   const rows=out.data.map(x=>{rewardKeys(x,['id','name','is_active','is_test','is_exam_room']);id(x.id);if(typeof x.name!=='string'||!x.name.trim()||x.is_active!==true||x.is_test!==false||![false,null].includes(x.is_exam_room))fail();return {id:x.id,name:x.name};});
   if(new Set(rows.map(x=>x.id)).size!==rows.length)fail();return rows;
 }

 function d100ScopeShape(v,session){
  schema(v,'quest-d100-binding-scope/1');rewardKeys(v,['schema_version','master_session_id','current_step_key','run_control_version','master_control_version','source_sha256','phase_sha256','d100_binding','roster','support_required','assignment','can_bind','reason_code']);
  if(v.master_session_id!==session||typeof v.current_step_key!=='string'||!v.current_step_key)fail();id(session);integer(v.run_control_version);integer(v.master_control_version);rewardSha(v.source_sha256);bool(v.support_required);bool(v.can_bind);
  if(![null,'NOT_D100','DISABLED','ROSTER_INACTIVE','FATO_PENDING','ALREADY_BOUND'].includes(v.reason_code)||v.can_bind!==(v.reason_code===null))fail();
  if(!Array.isArray(v.roster)||v.roster.length>4||new Set(v.roster.map(x=>x.character_id)).size!==v.roster.length)fail();
  for(const x of v.roster){rewardKeys(x,['character_id','display_name','qualified']);id(x.character_id);if(typeof x.display_name!=='string'||!x.display_name.trim()||x.qualified!==true)fail();}
  rewardKeys(v.assignment,['guide_character_id','support_character_id']);nullableId(v.assignment.guide_character_id);nullableId(v.assignment.support_character_id);
  if(v.assignment.support_character_id!==null&&(!v.assignment.guide_character_id||v.assignment.support_character_id===v.assignment.guide_character_id))fail();
  if(v.reason_code==='NOT_D100'){if(v.phase_sha256!==null||v.d100_binding!==null||v.assignment.guide_character_id!==null||v.assignment.support_character_id!==null)fail();}
  else{rewardSha(v.phase_sha256);const b=v.d100_binding;schema(b,'quest-d100-phase-binding/1');rewardKeys(b,['schema_version','policy_mission_id','policy_step_key','native_policy_sha256','success_decision_key','complication_decision_key','role_assignment']);id(b.policy_mission_id);rewardSha(b.native_policy_sha256);if(typeof b.policy_step_key!=='string'||!b.policy_step_key||b.success_decision_key!=='d100.success'||b.complication_decision_key!=='d100.complication'||b.role_assignment!=='explicit_guide_support/1')fail();}
  if(v.can_bind||v.reason_code==='ALREADY_BOUND'){if(v.roster.length<1||v.support_required!==(v.roster.length>1))fail();}
  if(v.reason_code==='ALREADY_BOUND'){if(!v.roster.some(x=>x.character_id===v.assignment.guide_character_id)||(v.support_required?!v.roster.some(x=>x.character_id===v.assignment.support_character_id):v.assignment.support_character_id!==null))fail();}
  if(v.can_bind&&(v.assignment.guide_character_id!==null||v.assignment.support_character_id!==null))fail();return structuredClone(v);
 }
 const d100ScopeKey=v=>JSON.stringify([v.master_session_id,v.current_step_key,v.run_control_version,v.master_control_version,v.source_sha256,v.phase_sha256,...['schema_version','policy_mission_id','policy_step_key','native_policy_sha256','success_decision_key','complication_decision_key','role_assignment'].map(k=>v.d100_binding?.[k]??null),v.roster.map(x=>x.character_id),v.support_required]);
 async function d100Scope(session){return d100ScopeShape(await call('mission_factory_quest_d100_binding_scope_v1',{p_session:id(session)}),session);}
 function d100ScopeMeta(session,request){const actor=owner(),k=`quest-d100-bind-scope/1/${actor}/${id(session)}/${id(request)}`;let v;try{const s=storage.getItem(k);v=s?JSON.parse(s):null;}catch{throw Error('Recupero del contesto d100 non disponibile.');}if(v){rewardKeys(v,['actor','session','request','scope']);if(v.actor!==actor||v.session!==session||v.request!==request)fail();d100ScopeShape(v.scope,session);}return v;}
 function d100RememberScope(scope,request){const session=scope.master_session_id,actor=owner(),k=`quest-d100-bind-scope/1/${actor}/${session}/${request}`,value={actor,session,request,scope:structuredClone(scope)},old=d100ScopeMeta(session,request);if(old&&d100ScopeKey(old.scope)!==d100ScopeKey(scope))throw Error('Contesto originale del binding cambiato.');const text=JSON.stringify(old||value);try{storage.setItem(k,text);if(storage.getItem(k)!==text)fail();}catch{throw Error('Binding non inviato: contesto non persistito.');}}
 function d100ParamsForScope(scope,guide,support,request){d100ScopeShape(scope,scope.master_session_id);if(!scope.can_bind||!scope.roster.some(x=>x.character_id===guide)||(scope.support_required?(!scope.roster.some(x=>x.character_id===support)||support===guide):support!==null))throw Error('Rileggi la fase e scegli guida e supporto eleggibili.');const b=scope.d100_binding;return d100Params({p_session:scope.master_session_id,p_policy_mission:b.policy_mission_id,p_policy_step:b.policy_step_key,p_native_policy_sha256:b.native_policy_sha256,p_guide:guide,p_support:support,p_success_decision:b.success_decision_key,p_complication_decision:b.complication_decision_key,p_expected_run_version:scope.run_control_version,p_request:request},scope.master_session_id);}
 function d100Archive(j,state){same(j.actor);const k=`quest-d100-bind-history/1/${j.actor}/${j.session}/${j.params.p_request}`,v={...structuredClone(j),local_state:state};try{const raw=storage.getItem(k),old=raw?JSON.parse(raw):null;if(old){rewardKeys(old,['schema_version','actor','session','params','receipt','local_state']);if(old.schema_version!=='quest-d100-bind-journal/1'||old.actor!==j.actor||old.session!==j.session||JSON.stringify(d100Params(old.params,j.session))!==JSON.stringify(j.params)||!['committed','uncertain','not_found_stale'].includes(old.local_state))fail();if(old.receipt!==null){const receipt=d100Receipt(old.receipt,old.params);if(v.receipt!==null&&JSON.stringify(d100Receipt(v.receipt,v.params))!==JSON.stringify(receipt))fail();v.receipt=receipt;}}if(v.receipt!==null){v.receipt=d100Receipt(v.receipt,v.params);v.local_state='committed';}const text=JSON.stringify(v);storage.setItem(k,text);if(storage.getItem(k)!==text)fail();}catch{throw Error('Storico del binding non persistito: nessun nuovo comando.');}}
 async function d100RetireStale(session){const j=d100Journal(session);if(!j||j.receipt)throw Error('Nessuna richiesta incerta da conservare.');const receipt=await d100Recover(session);if(receipt.state!=='not_found')throw Error('La richiesta è già registrata: rileggi la fase.');const fresh=await d100Scope(session),meta=d100ScopeMeta(session,j.params.p_request);if(meta?d100ScopeKey(meta.scope)===d100ScopeKey(fresh):fresh.run_control_version===j.params.p_expected_run_version)throw Error('La fase è ancora la stessa: conserva e recupera la richiesta originale.');const second=await d100Recover(session);if(second.state!=='not_found')throw Error('La richiesta è stata registrata: rileggi i ruoli.');const latest=d100Journal(session);if(!latest||latest.receipt||JSON.stringify(latest.params)!==JSON.stringify(j.params))throw Error('Richiesta d100 cambiata: rileggi prima di proseguire.');d100Archive(j,'not_found_stale');const k=`quest-d100-bind/1/${j.actor}/${session}`,text=JSON.stringify({schema_version:'quest-d100-bind-idle/1',actor:j.actor,session,previous_request:j.params.p_request});try{storage.setItem(k,text);if(storage.getItem(k)!==text)fail();}catch{throw Error('Recupero d100 non persistito.');}return {state:'history_preserved'};}
 async function d100Wakeup(session){
  id(session);const actor=owner(),revision=generation,live=()=>{same(actor);if(revision!==generation)throw Error('Contesto Quest cambiato.');};
  if(typeof client.auth?.getSession!=='function'||typeof client.functions?.invoke!=='function')fail();
  const auth=await client.auth.getSession();live();if(auth.error||auth.data?.session?.user?.id!==actor)throw Error('Accesso Quest cambiato.');
  const r=await client.functions.invoke('mission_generic_ai',{body:{schema_version:'mission-generic-d100-wakeup/1',master_session_id:session}});live();
  // Error/network/uncertain never authorizes a new roll or an automatic provider retry.
  if(r.error)throw Error('Tiro conservato: wakeup non confermato. Rileggi la Regia senza rilanciare il dado.');
  const v=r.data;rewardKeys(v,['schema_version','master_session_id','state','progress','retry','provider_retry_allowed']);rewardKeys(v.progress,['code']);
  const code={idle:null,completed:'MISSION_EVENT_COMPLETE',failed:'MISSION_EVENT_FAILED',uncertain:'MISSION_EVENT_UNCERTAIN',rejected:null};
  if(v.schema_version!=='mission-generic-d100-wakeup/1'||v.master_session_id!==session||!Object.hasOwn(code,v.state)||(v.state==='uncertain'?![null,code.uncertain].includes(v.progress.code):v.progress.code!==code[v.state])||v.retry!==false||v.provider_retry_allowed!==false)fail();return Object.freeze({...v,progress:Object.freeze({...v.progress})});
 }
 function d100Journal(session){const actor=owner(),k=`quest-d100-bind/1/${actor}/${id(session)}`;let v;try{const s=storage.getItem(k);v=s?JSON.parse(s):null;}catch{throw Error('Recupero d100 non disponibile. Nessun binding inviato.');}if(v?.schema_version==='quest-d100-bind-idle/1'){rewardKeys(v,['schema_version','actor','session','previous_request']);if(v.actor!==actor||v.session!==session)fail();id(v.previous_request);return null;}if(v){rewardKeys(v,['schema_version','actor','session','params','receipt']);if(v.schema_version!=='quest-d100-bind-journal/1'||v.actor!==actor||v.session!==session)fail();d100Params(v.params,session);if(v.receipt!==null)d100Receipt(v.receipt,v.params);}return v;}
 function d100Params(p,session){rewardKeys(p,['p_session','p_policy_mission','p_policy_step','p_native_policy_sha256','p_guide','p_support','p_success_decision','p_complication_decision','p_expected_run_version','p_request']);if(p.p_session!==session)fail();for(const k of ['p_session','p_policy_mission','p_guide','p_request'])id(p[k]);nullableId(p.p_support);integer(p.p_expected_run_version);rewardSha(p.p_native_policy_sha256);if(typeof p.p_policy_step!=='string'||!p.p_policy_step||p.p_success_decision!=='d100.success'||p.p_complication_decision!=='d100.complication'||p.p_support===p.p_guide)fail();return structuredClone(p);}
 function d100Receipt(v,p){schema(v,'quest-d100-binding/1');rewardKeys(v,['schema_version','state','binding_id','request_key']);id(v.binding_id);if(v.state!=='bound'||v.request_key!==p.p_request)fail();return structuredClone(v);}
 function d100Store(j,{expected=null}={}){same(j.actor);const previous=d100Journal(j.session),sameParams=previous&&JSON.stringify(previous.params)===JSON.stringify(j.params);if(expected!==null){if(JSON.stringify(d100Params(expected,j.session))!==JSON.stringify(j.params)||j.receipt===null)fail();d100Receipt(j.receipt,j.params);if(!sameParams){d100Archive(j,'committed');return j;}}if(previous&&!sameParams){if(!previous.receipt)throw Error('Binding precedente da riconciliare.');d100Archive(previous,'committed');}if(sameParams&&previous.receipt){if(j.receipt!==null&&JSON.stringify(j.receipt)!==JSON.stringify(previous.receipt))fail();j.receipt=structuredClone(previous.receipt);}const k=`quest-d100-bind/1/${j.actor}/${j.session}`,s=JSON.stringify(j);try{storage.setItem(k,s);if(storage.getItem(k)!==s)fail();}catch{throw Error('Binding non inviato: journal non persistito.');}return j;}
 async function d100Recover(session){const j=d100Journal(session);if(!j)return {state:'none',receipt:null};const v=await call('mission_factory_quest_d100_bind_receipt_v1',{p_request:j.params.p_request});schema(v,'quest-d100-bind-operation/1');rewardKeys(v,['schema_version','request_key','state','receipt']);if(v.request_key!==j.params.p_request||!['not_found','committed'].includes(v.state)||v.state==='not_found'&&v.receipt!==null)fail();const latest=d100Journal(session);if(!latest||JSON.stringify(latest.params)!==JSON.stringify(j.params))throw Error('Richiesta d100 cambiata: rileggi la fase.');if(v.state==='committed'){const receipt=d100Receipt(v.receipt,j.params);if(latest.receipt&&JSON.stringify(latest.receipt)!==JSON.stringify(receipt))fail();if(j.receipt&&JSON.stringify(j.receipt)!==JSON.stringify(receipt))fail();j.receipt=receipt;d100Store(j);}return structuredClone(v);}
 async function d100Bind(session,p,{replay=false,scope=null}={}){const params=d100Params(p,session);let old=d100Journal(session);
  const expected=d100ScopeShape(scope,session),fresh=await d100Scope(session);if(d100ScopeKey(expected)!==d100ScopeKey(fresh)||!fresh.can_bind)throw Error('La fase è cambiata o non è disponibile: rileggi prima di inviare.');
  const derived=d100ParamsForScope(fresh,params.p_guide,params.p_support,params.p_request);if(Object.keys(derived).some(k=>derived[k]!==params[k]))fail();d100RememberScope(fresh,params.p_request);
old=d100Journal(session);if(old&&!old.receipt&&JSON.stringify(old.params)!==JSON.stringify(params))throw Error('Binding precedente da riconciliare.');if(replay&&(!old||JSON.stringify(old.params)!==JSON.stringify(params)))fail();const j=d100Store({schema_version:'quest-d100-bind-journal/1',actor:owner(),session,params,receipt:old&&JSON.stringify(old.params)===JSON.stringify(params)?old.receipt:null});if(j.receipt)return j.receipt;const receipt=d100Receipt(await call('mission_factory_quest_d100_bind_v1',params),params);j.receipt=receipt;d100Store(j,{expected:params});return receipt;}

 return {d100Scope,d100ScopeKey,d100ScopeMeta,d100ParamsForScope,d100RetireStale,d100Wakeup,d100Bind,d100Recover,d100Journal,build:QUEST_RUNTIME_BUILD,locations,invalidate,dispose:()=>{disposed=true;invalidate();authSubscription?.unsubscribe();},journal:read,send,recover,runState,
 rewardState:async arc=>rewardStateShape(await call('mission_factory_quest_reward_state_v4',{p_arc:id(arc)}),arc),
 rewardByEpisode:async (episode,character,terminal)=>rewardByEpisodeShape(await call('mission_factory_quest_reward_by_episode_v4',{p_episode:id(episode)}),episode,character,terminal),
 rewardCatalog,rewardJournal:readReward,rewardSend:sendReward,rewardRecover:recoverReward,
 rewardReplay:async arc=>{const p=readReward(arc).pending;if(!p)throw Error('Nessuna richiesta premio da ripetere.');return sendReward(arc,p.operation,p.params,{replay:true});},
 participant:async episode=>participant(await call('mission_factory_quest_participant_state_v1',{p_episode:id(episode)}),episode),
 episode:async episode=>episodeState(await call('mission_factory_quest_episode_state_v4',{p_episode:id(episode)}),episode),
 replay:async episode=>{const pending=read(episode).pending;if(!pending)throw Error('Nessuna richiesta da ripetere.');return send(episode,pending.operation,pending.params,{replay:true});}};
}
