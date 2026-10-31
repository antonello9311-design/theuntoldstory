# E75 — correzione aggregata25 e recupero tecnico dello stesso avvio

Baseline reale Edge140. La preview già accettata ha fallito prima di Count/Generation: il renderer ha passato la persona nativa a16campi al validator che richiede la proiezione canonica a10campi. La normale narrativeRequest applica già quella proiezione; il renderer nuovo la ometteva.

Riusa esattamente narrativeActorPersonaView sugli attori dello snapshot verificato. La medesima lista alimenta validateKnowledge e input.attori. Snapshot, hash e fonti non cambiano; proiettore e validator canonici restano byteidentici. Prompt e limiti invariati, nessuna shape sconosciuta accettata.

Il catch usa la diagnostica esistente logBuildDiagnostic (soli codici sicuri). Se il server conferma la stessa run failed, risponde con vista autorevole200/run_id, conservando il riferimento acquisito. Una lettura incerta resta409 e non concede retry provider.

Nel solo avvio failed5e338b9a-52e2-2e96-9c16-352e31751c3b, dopo aver costruito e validato il payload riparato, il normale handler chiede recover_preprovider con expected_failed_row_sha25647f123ee26d98e0008e638506adede3d240b54a34e7a23260e9c7692823aae9d e repair_refC1266_NARRATORE75_REVIEW.json. Solo il server prova0HTTP e concede il recupero auditato. Segue prepare con la medesima request_key e verifica dello stessoRunID/sourceSHA; soltanto ready permette il worker normale. Nessun nuovo run, campagna, parent, reset di costi/chiamate o proroga. Il failedoriginale resta nell’audit DB; la presenza del codice non dimostra il recupero eseguito.

Due moduli cambiano;14restano byteidentici. Sintassi15MJS/import, inversa interaEdge140 e rebuild20file esatto. Nessuna esecuzione di factory, gameplay, fixture, DB o provider. Qualità/live NOT_RUN. Fullflow privato in pausa e fuori dal delta.

PackageSHA: `168c98620122b2fd9ccfe2d460d99ee2e81e323dda5b3361827670321e65d403`.
BuilderSHA: `7c883895c658e23e62cd00429593c882eb335369e985c4462265fed8d36fa35a`.

```diff
--- Edge140/mission-generic-runtime.mjs
+++ agg25/mission-generic-runtime.mjs
@@ -4696,9 +4696,10 @@
  if(!Number.isSafeInteger(budget)||budget<=0||budget>limits.max_input_bytes)bad();
  // Existing scene verifier and fact projection; the inherited editorial system is not sent.
  const checked=await scenePrompts(p.scene,p.scene_binding,{transportMaxChars:limits.transport_max_chars,maxInputBytes:budget});
- const data=JSON.parse(checked.usr);
+ const actors=p.scene.snapshot.actors.map(narrativeActorPersonaView);
+ const data={...JSON.parse(checked.usr),attori:actors};
  validateDirector(p.director_context,p.scene.snapshot.location);
- validateKnowledge(p.knowledge_context,p.scene.snapshot.actors,'combat');
+ validateKnowledge(p.knowledge_context,actors,'combat');
  validateSourceCursor(p.source_cursor,'combat_declarations');
  const context=p.director_context===null?null:{...p.director_context,entry_public:undefined};
  const memory=continuityFields.length?narrativeMemoryFromPayload(p,undefined):null;
```

```diff
--- Edge140/mission-staff-editorial.mjs
+++ agg25/mission-staff-editorial.mjs
@@ -178,16 +178,32 @@
   ||body.campaign_id!==campaign||body.case_no!==1||!uuid(body.request_key))return respond({code:'REQUEST_INVALID'},400);
  if(typeof waitUntil!=='function'||typeof provider?.count!=='function'||typeof provider?.create!=='function')return respond({code:'COMBAT_REPORT_ASYNC_UNAVAILABLE',retry:false,provider_retry_allowed:false},503);
  let prepared,factory;
+ const prepareRun=()=>rpc('mission_staff_editorial_prepare_v1',{p_user:user,p_campaign:campaign,p_case:1,p_variant:'canary',p_request:body.request_key});
+ const checkedPrepared=value=>{
+  if(value.schema_version!=='staff-combat-report-work/1'||value.stage!=='narration'||value.prompt_revision!=='staff-combat-report-narrator/1'
+   ||value.source?.schema_version!=='staff-combat-report-source/1'||value.source.author_user_id!==user
+   ||!sha(value.source_sha256))throw Error('E75_SOURCE_BINDING');
+  view(value,value.replayed);return value;
+ };
  try{
-  prepared=await rpc('mission_staff_editorial_prepare_v1',{p_user:user,p_campaign:campaign,p_case:1,p_variant:'canary',p_request:body.request_key});
-  if(prepared.schema_version!=='staff-combat-report-work/1'||prepared.stage!=='narration'||prepared.prompt_revision!=='staff-combat-report-narrator/1'
-   ||prepared.source?.schema_version!=='staff-combat-report-source/1'||prepared.source.author_user_id!==user
-   ||!sha(prepared.source_sha256))throw Error('E75_SOURCE_BINDING');
-  view(prepared,prepared.replayed);
+  prepared=checkedPrepared(await prepareRun());
+  if(prepared.state==='failed'&&prepared.run_id==='5e338b9a-52e2-2e96-9c16-352e31751c3b'){
+   // Validate the repaired request first. Only the server can prove and recover zero HTTP.
+   factory=await createStaffCombatReportNarrator(prepared.source,prepared.policy);
+   const originalRun=prepared.run_id,originalSource=prepared.source_sha256;
+   await step(originalRun,{operation:'recover_preprovider',expected_failed_row_sha256:'47f123ee26d98e0008e638506adede3d240b54a34e7a23260e9c7692823aae9d',repair_ref:'C1266_NARRATORE75_REVIEW.json'});
+   prepared=checkedPrepared(await prepareRun());
+   if(prepared.run_id!==originalRun||prepared.source_sha256!==originalSource)throw Error('E75_RECOVERY_BINDING');
+  }
   if(prepared.state!=='ready')return respond(view(prepared,true),200);
-  factory=await createStaffCombatReportNarrator(prepared.source,prepared.policy);
- }catch{
-  if(prepared?.campaign_id===campaign&&prepared?.state==='ready'&&uuid(prepared.run_id)){try{await step(prepared.run_id,{operation:'reject',reason_code:'request_build_failed'});}catch{}}
+  if(!factory)factory=await createStaffCombatReportNarrator(prepared.source,prepared.policy);
+ }catch(error){
+  logBuildDiagnostic(prepared?.run_id,error);
+  if(prepared?.campaign_id===campaign&&uuid(prepared.run_id)){
+   if(prepared.state==='ready'){try{await step(prepared.run_id,{operation:'reject',reason_code:'request_build_failed'});}catch{}}
+   // A known failed run is a durable receipt, not a lost start or a reason to generate again.
+   try{const observed=await read(prepared.run_id);if(observed.state==='failed')return respond(view(observed,prepared.replayed,true),200);}catch{}
+  }
   return respond({code:'COMBAT_REPORT_PREPARE_UNCONFIRMED',retry:false,provider_retry_allowed:false},409);
  }
  let release;const gate=new Promise(resolve=>{release=resolve;});
```

