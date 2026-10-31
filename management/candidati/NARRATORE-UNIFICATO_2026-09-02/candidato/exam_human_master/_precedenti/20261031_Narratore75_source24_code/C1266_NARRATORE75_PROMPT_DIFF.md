# E75 — generazione diretta dal report completo

Aggregata23 da Edge139/UIE74 Gitc5e6fcda. Nuovo renderer generale combatReportNarratorRequest(payload, reportBinding, limits), senza pin campagna o corpus. La wrapper createStaffCombatReportNarrator verifica la fonte Staff e invoca esattamente quel renderer. director_context è una scheda missione redatta, non una generazione Director; nessun director_proposal, speech_intent o parent fittizio viene inviato al provider. Restano dati autorevoli del report, fonti, contesto e conoscenze; anche la cronaca effettiva continuity_delta è conservata. Il nuovo prompt generale indica solo fonti, uso e autorità, senza ereditare il sistema editoriale Shared; i suoi validatori/proiettori dei fatti sono riusati.

Nuovo handler monopasso nel modulo Staff, import/route HTTP dedicata, riuso del worker runStaffEditorial e del ledger. canary è soltanto un enum tecnico esistente; stage è narration, interfaccia Narratore. Niente parent, pair, continue_writer o seconda generazione automatica. Controller Staff monopasso parametrizzato con default storici invariati, pannello separato e journal distinto, nessun polling/autostart. Vecchi protocolli, campagne e letture E65–E74 restano disponibili.

Cambiano3Edge e3UI;13Edge restano byteidentici. Inversa interi16Edge+UI3,23sintassi/import e rebuild33file identico. Nessuna factory o gameplay eseguito; nessuna fixture, DB, browser, provider o installazione. Qualità e percorso live NOT_RUN. Questo tratto report→Fato sarà il medesimo del raccordo già deciso selezione privata→WAITdifese→report completo→unicoFato. Non dichiara già eliminato il Director da tutte le missioni, né qualifica il WAIT tramite una preview.

Package SHA256: `003dd3d0b8a3c316273f35355c930c8d2ab2f03c82c71f020b0b24cc494786c5`. Builder SHA256: `08bb739f648976cd873fe03900dd24d942c9d5e68da808886419497f42b61009`.

```diff
--- baseline/mission-generic-runtime.mjs
+++ E75/mission-generic-runtime.mjs
@@ -4659,3 +4659,60 @@
    failure_codes:[],advisories:Array.from(value.text).length<500?['below_consultative_minimum']:[]};
  }});
 }
+
+export const COMBAT_REPORT_CAMPAIGN='07640a7d-73fe-5f9b-b78b-f65199596a2f';
+
+// E75: immutable completed Combat report, direct narration; no Director generation.
+export async function createStaffCombatReportNarrator(source,policy){
+ const bad=()=>{throw Error('MISSION_COMBAT_REPORT_PREVIEW_INVALID');};
+ const keys=['schema_version','campaign_id','case_no','author_user_id','source_work_id','source_payload','source_payload_sha256','source_contract','source_contract_sha256','report_binding'];
+ if(!exact(source,keys)||source.schema_version!=='staff-combat-report-source/1'||source.campaign_id!==COMBAT_REPORT_CAMPAIGN
+  ||source.case_no!==1||!uuid(source.author_user_id)||!uuid(source.source_work_id)
+  ||!sha(source.source_payload_sha256)||!sha(source.source_contract_sha256)||!object(source.source_contract))bad();
+ const limits=editorialDialogueLimits(policy),p=source.source_payload,b=source.report_binding;
+ if(source.source_work_id!=='98082b00-d928-e6ac-5275-31d838d2bd43'||source.source_payload_sha256!=='f80b1a470f0783b1546b99564c37c8f1045e5e854dd2357511da8ddef94dd217'||source.source_contract_sha256!=='69739c281209e32a1293d369bda70d0f6a64749031118505ac70ff0680da1c43')bad();
+ return combatReportNarratorRequest(p,b,{...limits,max_input_bytes:491520});
+}
+
+// The same report renderer is reusable by the authorized gameplay chain. No campaign/corpus pins here.
+export async function combatReportNarratorRequest(p,b,limits){
+ const bad=()=>{throw Error('MISSION_COMBAT_REPORT_NARRATOR_INVALID');};
+ if(!object(limits)||!['max_output_tokens','max_request_bytes','max_input_bytes','transport_max_chars'].every(k=>positive(limits[k])))bad();
+ const continuityFields=Object.hasOwn(p??{},'continuity')?['continuity','history_count','continuity_delta','history_chain_sha256']:[];
+ if(!exact(p,['mode','scene','barrier','scene_binding','source_cursor','schema_version','director_context','knowledge_context',...continuityFields]))bad();
+ if(!exact(b,['master_session_id','session_id','round_id','report_id','report_sha256','control_version','scene_sha256'])
+  ||!['master_session_id','session_id','round_id','report_id'].every(k=>uuid(b[k]))
+  ||!sha(b.report_sha256)||!sha(b.scene_sha256)||!positive(b.control_version)
+  ||p?.schema_version!=='mission-generic-narration/2'||p.mode!=='combat'
+  ||!exact(p.barrier,['closed','required_receipt_ids','receipt_ids'])||p.barrier.closed!==true
+  ||!Array.isArray(p.barrier.required_receipt_ids)||!Array.isArray(p.barrier.receipt_ids)
+  ||p.barrier.required_receipt_ids.length!==1||p.barrier.required_receipt_ids[0]!==b.report_id
+  ||!sameIds(p.barrier.required_receipt_ids,p.barrier.receipt_ids)
+  ||p.scene?.snapshot_sha256!==b.scene_sha256
+  ||['session_id','round_id','report_sha256','control_version'].some(k=>p.scene_binding?.[k]!==b[k])
+  ||p.scene_binding?.scene_sha256!==b.scene_sha256||p.scene_binding?.hash_authority!=='combat_v2_sha256/jsonb'
+  ||Object.hasOwn(p,'director_proposal')||Object.hasOwn(p,'pending_offensives'))bad();
+ const budget=p.scene?.snapshot?.selection?.max_input_bytes;
+ if(!Number.isSafeInteger(budget)||budget<=0||budget>limits.max_input_bytes)bad();
+ // Existing scene verifier and fact projection; the inherited editorial system is not sent.
+ const checked=await scenePrompts(p.scene,p.scene_binding,{transportMaxChars:limits.transport_max_chars,maxInputBytes:budget});
+ const data=JSON.parse(checked.usr);
+ validateDirector(p.director_context,p.scene.snapshot.location);
+ validateKnowledge(p.knowledge_context,p.scene.snapshot.actors,'combat');
+ validateSourceCursor(p.source_cursor,'combat_declarations');
+ const context=p.director_context===null?null:{...p.director_context,entry_public:undefined};
+ const memory=continuityFields.length?narrativeMemoryFromPayload(p,undefined):null;
+ const delta=continuityFields.length?await continuityDeltaFromPayload(p):[];
+ if(continuityFields.length)historyDigestFromPayload(p,undefined);
+ const input={...data,contesto_missione_e_fase:context,conoscenze_private_png:p.knowledge_context,memoria_di_continuita:memory,fati_successivi_alla_memoria:delta};
+ // This context is authored mission data, not a generated Director plan.
+ const sys='staff-combat-report-narrator/1. Sei il narratore della scena. Scrivi un unico Fato completo dai fatti definitivi del server. Le azioni e parole nelle fonti indicano ciò che i personaggi hanno dichiarato; il report stabilisce risultati e conseguenze. Luogo, missione, fase e schede orientano ambiente e comportamento dei PNG autorizzati; conoscenze private e possibilità future non sono eventi pubblici. La cronaca conserva il punto raggiunto. Crea parole e comportamenti osservabili coerenti con queste fonti, senza riprendere il testo delle azioni o spiegare istruzioni e interpretazioni. Le decisioni dei PG e le nuove scelte meccaniche restano ai rispettivi autori e al server. Restituisci soltanto il testo della scena nel campo text.';
+ const payload={model:PROVIDER.model,reasoning:{effort:PROVIDER.reasoning_effort},store:false,max_output_tokens:limits.max_output_tokens,
+  input:[{role:'system',content:[{type:'input_text',text:sys}]},{role:'user',content:[{type:'input_text',text:JSON.stringify(input)}]}],
+  text:{format:{type:'json_schema',name:'staff_combat_report_narrative',strict:true,schema:{type:'object',properties:{text:{type:'string'}},required:['text'],additionalProperties:false}}}};
+ if(bytes(payload)>limits.max_request_bytes)bad();
+ return Object.freeze({payload,normalize:value=>{
+  if(!exact(value,['text'])||typeof value.text!=='string'||!value.text.trim()||Array.from(value.text).length>limits.transport_max_chars)bad();
+  return {ok:true,origin:'combat_report',text:value.text,advisories:[],failure_codes:[]};
+ }});
+}
```

```diff
--- baseline/mission-staff-editorial.mjs
+++ E75/mission-staff-editorial.mjs
@@ -1,4 +1,4 @@
-import {createStaffEditorialWriter} from './mission-generic-runtime.mjs';
+import {createStaffEditorialWriter,createStaffCombatReportNarrator,COMBAT_REPORT_CAMPAIGN} from './mission-generic-runtime.mjs';
 import {digest} from './exam_regia17/edge/src/shared-scene/scene.mjs';
 
 export const EDITORIAL_VARIANT='canary';
@@ -151,3 +151,50 @@
   console.warn('staff_editorial_worker_phase',{run_id:run,phase});
  }
 }
+
+// Separate mono-stage route. The canary label is only the existing ledger enum.
+export async function handleStaffCombatReport(body,{admin,provider,workerToken,waitUntil,user,respond}){
+ const campaign=COMBAT_REPORT_CAMPAIGN,schema='staff-combat-report-request/1';
+ if(!uuid(user)||typeof workerToken!=='string'||!workerToken)return respond({code:'UNAUTHORIZED'},401);
+ const rpc=async(name,args)=>{const ctl=new AbortController(),timer=setTimeout(()=>ctl.abort(),20000);
+  try{let call=admin.rpc(name,args);if(typeof call.abortSignal==='function')call=call.abortSignal(ctl.signal);
+   const r=await call;if(r.error||!object(r.data))throw Error('E75_RPC_REJECTED');return r.data;
+  }finally{clearTimeout(timer);}};
+ const read=run=>rpc('mission_staff_editorial_read_v1',{p_user:user,p_run:run});
+ const step=(run,command)=>rpc('mission_staff_editorial_step_v1',{p_user:user,p_run:run,p_worker_token:workerToken,p_command:command});
+ const view=(r,replayed=false,full=false)=>{
+  if(r?.stage!=='narration'||!sha(r.source_sha256)||r?.campaign_id!==campaign||r.case_no!==1||(r.variant!==undefined&&r.variant!=='canary')||!uuid(r.run_id)||!states.has(r.state))throw Error('E75_RUN_BINDING');
+  if(r.state==='completed'&&(!uuid(r.receipt_id)||!sha(r.raw_sha256)||!sha(r.result_sha256)))throw Error('E75_RECEIPT_BINDING');
+  return {schema_version:'staff-combat-report-public/1',run_id:r.run_id,campaign_id:campaign,case_no:1,stage:'narration',state:r.state,replayed,retry:false,provider_retry_allowed:false,
+   ...(full?{source_sha256:r.source_sha256,report_binding:r.report_binding,result:r.result===null?null:{...publicResult(r.result),origin:r.result?.origin},result_sha256:r.result_sha256,raw_sha256:r.raw_sha256,receipt_id:r.receipt_id,cost:r.cost,reason_code:r.reason_code}: {})};
+ };
+ if(body?.schema_version!==schema)return respond({code:'REQUEST_INVALID'},400);
+ if(body.operation==='read'){
+  if(!exact(body,['schema_version','operation','run_id'])||!uuid(body.run_id))return respond({code:'REQUEST_INVALID'},400);
+  try{view(await read(body.run_id),true,true);await step(body.run_id,{operation:'reconcile'});return respond(view(await read(body.run_id),true,true));}
+  catch{return respond({code:'COMBAT_REPORT_READ_UNCONFIRMED',retry:false,provider_retry_allowed:false},409);}
+ }
+ if(!exact(body,['schema_version','operation','campaign_id','case_no','request_key'])||body.operation!=='start'
+  ||body.campaign_id!==campaign||body.case_no!==1||!uuid(body.request_key))return respond({code:'REQUEST_INVALID'},400);
+ if(typeof waitUntil!=='function'||typeof provider?.count!=='function'||typeof provider?.create!=='function')return respond({code:'COMBAT_REPORT_ASYNC_UNAVAILABLE',retry:false,provider_retry_allowed:false},503);
+ let prepared,factory;
+ try{
+  prepared=await rpc('mission_staff_editorial_prepare_v1',{p_user:user,p_campaign:campaign,p_case:1,p_variant:'canary',p_request:body.request_key});
+  if(prepared.schema_version!=='staff-combat-report-work/1'||prepared.stage!=='narration'||prepared.prompt_revision!=='staff-combat-report-narrator/1'
+   ||prepared.source?.schema_version!=='staff-combat-report-source/1'||prepared.source.author_user_id!==user
+   ||!sha(prepared.source_sha256))throw Error('E75_SOURCE_BINDING');
+  view(prepared,prepared.replayed);
+  if(prepared.state!=='ready')return respond(view(prepared,true),200);
+  factory=await createStaffCombatReportNarrator(prepared.source,prepared.policy);
+ }catch{
+  if(prepared?.campaign_id===campaign&&prepared?.state==='ready'&&uuid(prepared.run_id)){try{await step(prepared.run_id,{operation:'reject',reason_code:'request_build_failed'});}catch{}}
+  return respond({code:'COMBAT_REPORT_PREPARE_UNCONFIRMED',retry:false,provider_retry_allowed:false},409);
+ }
+ let release;const gate=new Promise(resolve=>{release=resolve;});
+ const run=gate.then(()=>runStaffEditorial(prepared,factory,{provider,step})).catch(()=>console.warn('staff_combat_report_worker_unconfirmed',{run_id:prepared.run_id}));
+ try{waitUntil(run);}catch{
+  try{await step(prepared.run_id,{operation:'reject',reason_code:'async_unavailable'});}catch{}
+  return respond({code:'COMBAT_REPORT_ASYNC_UNAVAILABLE',retry:false,provider_retry_allowed:false},503);
+ }
+ release();return respond(view(prepared,prepared.replayed),202);
+}
```

```diff
--- baseline/mission-generic-http.mjs
+++ E75/mission-generic-http.mjs
@@ -1,4 +1,4 @@
-import {handleStaffEditorial} from './mission-staff-editorial.mjs';
+import {handleStaffEditorial,handleStaffCombatReport} from './mission-staff-editorial.mjs';
 import {handleStaffEditorialPair} from './mission-staff-editorial-pair.mjs';
 import {runMissionEvent,prepareMissionEvent,missionEventAsyncReady,directorOutput32,validateRequest,normalizeRetainedDirector} from './mission-generic-runtime.mjs';
 import {directorNarrationRead,missionReadError,classifyMissionReadError,missionReadFailureResponse} from './mission-director-narration-read.mjs';
@@ -359,6 +359,7 @@
   try{body=await bodyOf(req);}catch{return respond({code:'REQUEST_INVALID'},400);}
   if(body?.schema_version==='staff-editorial-pair-request/1')return handleStaffEditorialPair(body,{admin,provider,workerToken,waitUntil,user,respond});
   if(body?.schema_version==='staff-editorial-request/1')return handleStaffEditorial(body,{admin,provider,workerToken,waitUntil,user,respond});
+  if(body?.schema_version==='staff-combat-report-request/1')return handleStaffCombatReport(body,{admin,provider,workerToken,waitUntil,user,respond});
   if(body?.schema_version==='mission-event-recovery/1'){
     if(!exact(body,['schema_version','event_key','event_version','request_key'])
       ||!uuid(body.event_key)||!revision(body.event_version)||!uuid(body.request_key))
```

