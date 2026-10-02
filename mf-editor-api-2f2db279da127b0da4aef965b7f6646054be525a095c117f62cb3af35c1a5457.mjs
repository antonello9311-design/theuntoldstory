// Adapter di composizione: le RPC non ancora installate falliscono chiuse.
// Nessuna porta png_builder_* service-only è chiamata dal browser.
const MEDIA_RELEASE = 'mission-factory-context-media/1';
const UUID = /^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$/i;
const SHA = /^[0-9a-f]{64}$/;
const mediaHex = bytes => [...new Uint8Array(bytes)].map(x => x.toString(16).padStart(2, '0')).join('');
const EXPECTED = Object.freeze({
  catalog: 'mission-factory-catalog/1',
  createDraft: 'mission-factory-draft-created/1',
  openDraft: 'mission-factory-draft-state/1',
  save: 'mission-factory-draft-save/1',
  compile: 'mission-factory-compile-request/1',
  compileState: 'mission-factory-compile-state/1',
  npcCatalog: 'mission-factory-npc-catalog/1',
  npcVersion: 'mission-factory-npc-version/1',
  stageNpc: 'mission-factory-npc-stage/1',
  preview: 'mission-factory-preview/1',
  publish: 'mission-factory-publish-receipt/1',
  publishState: 'mission-factory-publish-state/1',
  requestState: 'mission-factory-request-state/1',
  sensitiveState: 'mission-factory-sensitive-review-state/1',
  variantNpcProjection: 'mission-factory-variant-npc-projection/1',
  npcAuthoringCheck: 'mission-factory-npc-authoring-check/1'
});
function requireResponse(value, schema) {
  if (!value || value.schema_version !== schema) throw Error(`Risposta server non valida: ${schema}`);
  return value;
}
export function validateScheduleCapability(value) {
  const keys=['schema_version','allowed','execution_context','target','revision_sha256','qualification_sha256'];
  if (!value || typeof value!=='object' || Array.isArray(value) ||
      Object.keys(value).sort().join()!==keys.sort().join() ||
      value.schema_version!=='mission-schedule-capability/1' || typeof value.allowed!=='boolean')
    throw Error('Capability di programmazione non valida.');
  if (!value.allowed) {
    if (keys.slice(2).some(key=>value[key]!==null)) throw Error('Capability negata non valida.');
  } else if (!['staff_simulation','public_real'].includes(value.execution_context) ||
      value.target!==(value.execution_context==='staff_simulation'?'staff':'public') ||
      !SHA.test(value.revision_sha256||'') || !SHA.test(value.qualification_sha256||''))
    throw Error('Binding della programmazione non valido.');
  return value;
}
export function createMissionFactoryApi(client, options = {}) {
  client=createEditorLifecycleTransport(client,{...options,namespace:'factory'});
  if (typeof client?.rpc !== 'function') throw Error('Client Supabase non disponibile.');
  async function rpc(name, args, schema) {
    const result = await client.rpc(name, args);
    if (result.error) throw Error(result.error.message || `${name} non disponibile.`);
    return requireResponse(result.data, schema);
  }
  return {
    setLifecycle:predicate=>client.setLifecycle(predicate),
    lifecycleEpoch:()=>client.lifecycleEpoch(),invalidateEpoch:()=>client.invalidateEpoch(),
    attestMedia: async ({draft_id,step_key,file,request_key = null}) => {
      if (!UUID.test(draft_id || '') || request_key!==null&&!UUID.test(request_key || '') || !/^[a-z][a-z0-9_]{1,63}$/.test(step_key || '') || !file || !['image/png','image/jpeg','image/webp'].includes(file.type) || file.size < 1 || file.size > 4194304) throw Error('Immagine o riferimento non valido.');
      if (typeof client.functions?.invoke !== 'function') throw Error('Porta media non disponibile.');
      const raw = await file.arrayBuffer();
      const sha256 = mediaHex(await crypto.subtle.digest('SHA-256',raw));
      request_key ||= client.mediaRequest({draft_id,step_key,sha256,type:file.type,bytes:file.size});
      const {data,error} = await client.functions.invoke('mission_factory_context_media_attest_v1', {
        body:new Blob([raw],{type:file.type}),
        headers:{'content-type':file.type,'x-mf-draft-id':draft_id,'x-mf-phase-key':step_key,'x-mf-request-key':request_key,'x-mf-sha256':sha256,'x-mf-expected-release':MEDIA_RELEASE}
      });
      if (error) throw Error(error.message || 'Attestazione media non disponibile.');
      if (data?.schema_version !== 'mission-factory-context-media-registration/1' || data.release !== MEDIA_RELEASE || !UUID.test(data.media_id || '') || data.request_key !== request_key || data.phase_key !== step_key || data.sha256 !== sha256 || data.bucket !== 'location-images' || data.state !== 'registered') throw Error('Ricevuta media non valida.');
      return data;
    },
    catalog: () => rpc('mission_factory_catalog_v1', {}, EXPECTED.catalog),
    createDraft: ({request_key,source,catalog_version}) => rpc('mission_factory_create_v1', {p_request:request_key,p_source:source,p_catalog_version:catalog_version}, EXPECTED.createDraft),
    openDraft: ({draft_id}) => rpc('mission_factory_open_v1', {p_draft:draft_id}, EXPECTED.openDraft),
    save: ({draft_id,expected_version,document,request_key}) => rpc('mission_factory_save_v1', {p_draft:draft_id,p_expected_version:expected_version,p_document:document,p_request:request_key}, EXPECTED.save),
    // Le funzioni seguenti sono porte candidate da comporre con Rapid/dual-controller.
    // Restano senza fallback a RPC legacy per non aprire accidentalmente una source pubblica.
    compile: ({draft_id,request_key}) => rpc('mission_factory_compile_v1', {p_draft:draft_id,p_request:request_key}, EXPECTED.compile),
    compileState: ({request_key}) => rpc('mission_factory_compile_state_v1', {p_request:request_key}, EXPECTED.compileState),
    npcCatalog: ({scope}) => rpc('mission_factory_npc_catalog_v1', {p_scope:scope}, EXPECTED.npcCatalog).then(x => x.items),
    npcVersion: ({npc_id,npc_version_id,scope}) => rpc('mission_factory_npc_version_v1', {p_npc:npc_id,p_version:npc_version_id,p_scope:scope}, EXPECTED.npcVersion),
    npcAuthoringCheck: ({draft_id,expected_version,actor_key}) => {
      if (!UUID.test(draft_id || '') || !Number.isSafeInteger(expected_version) || expected_version < 1 ||
          !/^[a-z][a-z0-9_]{1,63}$/.test(actor_key || '')) throw Error('Binding PNG non valido.');
      return rpc('mission_factory_npc_authoring_check_v1', {p_draft:draft_id,p_expected_version:expected_version,p_actor_key:actor_key}, EXPECTED.npcAuthoringCheck);
    },
    variantNpcProjection: async ({draft_id,expected_version}) => {
      if (!UUID.test(draft_id || '') || !Number.isSafeInteger(expected_version) || expected_version < 1) throw Error('Bozza o versione non valide.');
      const value = await rpc('mission_factory_variant_npc_projection_v1', {
        p_draft:draft_id,p_expected_version:expected_version,p_content_kind:'mission'
      }, EXPECTED.variantNpcProjection);
      if (value.draft_id !== draft_id || value.draft_control_version !== expected_version ||
          value.content_kind !== 'mission' || !SHA.test(value.reference_sha256 || '') ||
          !Array.isArray(value.items) || value.items.length > 12 ||
          value.items.some(x => !/^[a-z][a-z0-9_]{1,63}$/.test(x.actor_key || '') ||
            !UUID.test(x.npc_id || '') || !UUID.test(x.npc_version_id || '') ||
            !SHA.test(x.bundle_sha256 || '') || !UUID.test(x.narrative_version_id || '') ||
            !Array.isArray(x.phase_keys) || x.phase_keys.some(k => !/^[a-z][a-z0-9_]{1,63}$/.test(k)) ||
            !['alleati','avversari','civili'].includes(x.team) || typeof x.combat !== 'boolean' ||
            x.reference_version !== 'mission-factory-npc-reference/1' ||
            (x.combat ? !UUID.test(x.mechanical_binding_id || '') : x.mechanical_binding_id !== null)) ||
          new Set(value.items.map(x => x.actor_key)).size !== value.items.length)
        throw Error('Proiezione PNG nativa non valida.');
      return value;
    },
    nativeVariantOptions: async () => {
      const [catalog,profiles] = await Promise.all([
        rpc('mission_creation_catalog_v1', {}, 'mission-creation-catalog/1'),
        rpc('mission_generic_editor_v1', {p_plan_version:null}, 'mission-generic-editor/1')
      ]);
      if (!Array.isArray(catalog.locations) || !Array.isArray(catalog.modes) ||
          !Number.isInteger(catalog.team_min) || !Number.isInteger(catalog.team_max) ||
          catalog.team_min < 1 || catalog.team_max > 4 || catalog.team_min > catalog.team_max ||
          !Array.isArray(profiles.mechanical_profiles) || !Array.isArray(profiles.narrative_profiles))
        throw Error('Catalogo nativo delle varianti non valido.');
      return {catalog,profiles};
    },
    stageNpc: ({draft_id,request_key,proposal}) => rpc('mission_factory_npc_stage_v1', {p_draft:draft_id,p_request:request_key,p_proposal:proposal}, EXPECTED.stageNpc),
    preview: ({draft_id,expected_version}) => rpc('mission_factory_preview_v1', {p_draft:draft_id,p_expected_version:expected_version}, EXPECTED.preview),
    scheduleCapability: async ({draft_id,expected_version,preview_seal,due}) => {
      if (!UUID.test(draft_id||'') || !Number.isSafeInteger(expected_version) || expected_version<1 ||
          !SHA.test(preview_seal||'') || typeof due!=='string' || !Number.isFinite(Date.parse(due)))
        throw Error('Bozza, sigillo o data di programmazione non validi.');
      const result=await client.rpc('mission_factory_schedule_capability_v1',{
        p_draft:draft_id,p_expected_version:expected_version,p_preview_seal:preview_seal,p_due:due});
      if (result.error) throw Error(result.error.message||'Programmazione non disponibile.');
      return validateScheduleCapability(result.data);
    },
    publish: ({draft_id,expected_version,preview_seal,request_key,visibility,scheduled_at}) => rpc('mission_factory_publish_v1', {p_draft:draft_id,p_expected_version:expected_version,p_preview_seal:preview_seal,p_request:request_key,p_visibility:visibility,p_scheduled_at:scheduled_at}, EXPECTED.publish),
    publishState: ({request_key}) => rpc('mission_factory_publish_state_v1', {p_request:request_key}, EXPECTED.publishState),
    requestState: ({request_key}) => rpc('mission_factory_request_state_v1', {p_request:request_key}, EXPECTED.requestState),
    sensitiveState: ({draft_id}) => rpc('mission_factory_sensitive_review_state_v1', {p_draft:draft_id}, EXPECTED.sensitiveState),
    sensitiveRequest: ({draft_id,expected_version,request_key}) => rpc('mission_factory_sensitive_review_request_v1', {p_draft:draft_id,p_expected_version:expected_version,p_request:request_key}, EXPECTED.sensitiveState),
    sensitiveDecide: ({draft_id,request_key,expected_version,decision,decision_key}) => rpc('mission_factory_sensitive_review_decide_v1', {p_draft:draft_id,p_request:request_key,p_expected_version:expected_version,p_decision:decision,p_decision_key:decision_key}, EXPECTED.sensitiveState)
  };
}

// Principal-bound transport. Accepted in-flight replies are retained for the original actor;
// disposal prevents every subsequent network call, including chained continuations.
export function createEditorLifecycleTransport(client,{identity,isCurrent,namespace,storage=globalThis.sessionStorage}={}){
 const actor=typeof identity==='function'?identity():null;
 if(!UUID.test(actor||'')||typeof isCurrent!=='function'||!namespace||!client.auth?.getSession)throw Error('Contesto editoriale autenticato richiesto.');
 const version=namespace==='quest'?'2':'1';
 const receiptSchema={'mission_factory_create_v1':'mission-factory-draft-created/'+version,'mission_factory_save_v1':'mission-factory-draft-save/'+version,'mission_factory_compile_v1':'mission-factory-compile-request/1','mission_factory_compile_v2':'mission-factory-compile-request/2','mission_factory_npc_stage_v1':'mission-factory-npc-stage/1','mission_factory_publish_v1':'mission-factory-publish-receipt/'+version,'mission_factory_sensitive_review_request_v1':'mission-factory-sensitive-review-state/1','mission_factory_sensitive_review_decide_v1':'mission-factory-sensitive-review-state/1','mission_factory_sensitive_review_request_v2':'mission-factory-sensitive-review-state/2','mission_factory_sensitive_review_decide_v2':'mission-factory-sensitive-review-state/2','mission_factory_quest_roster_assign_v1':'mission-factory-quest-roster-assigned/1','mission_factory_quest_variant_commit_v1':'mission-factory-quest-variant/1','mission_factory_context_media_attest_v1':'mission-factory-context-media-registration/1','mission_factory_context_media_attest_v2':'mission-factory-context-media-registration/2'};
 const scopes=new Set();let epoch=0;
 const prefix='tus.editor-request/1/'+namespace+'/'+actor+'/',pointer=prefix+'pending';
 const locksSymbol=Symbol.for('tus.editor-request.locks/1'),locks=globalThis[locksSymbol]||(globalThis[locksSymbol]=new Set());
 const clone=x=>JSON.parse(JSON.stringify(x)),canonical=x=>Array.isArray(x)?'['+x.map(canonical).join(',')+']':x&&typeof x==='object'?'{'+Object.keys(x).sort().map(k=>JSON.stringify(k)+':'+canonical(x[k])).join(',')+'}':JSON.stringify(x);
 const fingerprint=async x=>mediaHex(await crypto.subtle.digest('SHA-256',new TextEncoder().encode(canonical(x))));
 const alive=()=>{if(identity()!==actor||!isCurrent()||[...scopes].some(scope=>!scope()))throw Error('Editor chiuso o accesso cambiato: nessuna nuova richiesta.');};
 async function authorize(){alive();const value=await client.auth.getSession();alive();if(value.error||value.data?.session?.user?.id!==actor)throw Error('Sessione editoriale cambiata.');}
 function pendingPointer(){const raw=storage?.getItem(pointer);if(!raw)return null;const key=JSON.parse(raw);if(typeof key!=='string'||!key.startsWith(prefix))throw Error('Indice journal non valido.');return key;}
 function put(key,value){if(!storage?.setItem||!storage?.getItem)throw Error('Journal non disponibile: invio bloccato.');const raw=JSON.stringify(value);storage.setItem(key,raw);if(storage.getItem(key)!==raw)throw Error('Journal non conservato: invio bloccato.');}
 async function prepare(operation,args,request){
  const original={operation,args:clone(args)},hash=await fingerprint(original),key=prefix+operation+'/'+request;alive();
  const pendingKey=pendingPointer();if(pendingKey){const raw=storage.getItem(pendingKey);if(!raw)throw Error('Journal incompleto: riconciliare la richiesta.');const pending=JSON.parse(raw);if(pending.actor!==actor||pending.schema_version!=='editor-request-journal/1'||pending.fingerprint!==await fingerprint({operation:pending.operation,args:pending.args}))throw Error('Journal alterato: invio bloccato.');if(pending.phase==='pending'&&(pendingKey!==key||pending.fingerprint!==hash))throw Error('Richiesta incerta '+pending.request_key+': conservare UUID e corpo prima di un nuovo invio.');}
  const previous=storage?.getItem(key);if(previous){const prior=JSON.parse(previous);if(prior.actor!==actor||prior.operation!==operation||prior.request_key!==request||prior.fingerprint!==hash)throw Error('UUID già usata con argomenti differenti.');}
  const record={schema_version:'editor-request-journal/1',actor,operation,request_key:request,args:original.args,fingerprint:hash,phase:'pending',response:null};put(key,record);put(pointer,key);return {key,record};
 }
 async function wire(operation,args,request,send){const stamp=epoch;await authorize();let journal=null;if(request){if(!UUID.test(request))throw Error('UUID della richiesta non valida.');if(locks.has(prefix))throw Error('Un invio editoriale è già in corso.');locks.add(prefix);}try{if(request)journal=await prepare(operation,args,request);await authorize();alive();if(stamp!==epoch)throw Error('Sezione editor cambiata: richiesta non inviata.');const result=await send();
   // A matching response is evidence for this request; errors/malformed replies retain pending.
   if(journal&&!result?.error&&result?.data?.schema_version===receiptSchema[operation.slice(operation.indexOf(':')+1)]&&(result.data.request_key===request||args.p_decision_key===request&&result.data.request_key===args.p_request&&result.data.status===args.p_decision)&&(!args.p_draft||result.data.draft_id===undefined||result.data.draft_id===args.p_draft))put(journal.key,{...journal.record,phase:'answered',response:clone(result.data)});
   if(!request&&!result?.error&&(result?.data?.state==='confirmed'&&/^mission-factory-(request-state|publish-state)\/[12]$/.test(result.data.schema_version||'')||result?.data?.state==='complete'&&nameOf(operation)==='mission_factory_compile_state_v2'&&result.data.schema_version==='mission-factory-compile-state/2'&&result.data.result?.schema_version==='mission-factory-quest-proposal/1'&&UUID.test(result.data.result.proposal_id||'')&&SHA.test(result.data.result.proposal_sha256||''))&&UUID.test(result.data.request_key||'')){const pendingKey=pendingPointer(),raw=pendingKey&&storage.getItem(pendingKey);if(raw){const record=JSON.parse(raw);const operationExpected={mission_factory_create_v1:'create',mission_factory_save_v1:'save',mission_factory_compile_v1:'compile',mission_factory_compile_v2:'compile',mission_factory_npc_stage_v1:'npc_stage',mission_factory_publish_v1:'publish',mission_factory_quest_roster_assign_v1:'roster_assign',mission_factory_quest_variant_commit_v1:'quest_variant'}[nameOf(record.operation)];const exactReadback=result.data.schema_version==='mission-factory-publish-state/'+version?operationExpected==='publish':result.data.schema_version==='mission-factory-request-state/'+version?namespace==='quest'?result.data.result?.schema_version===receiptSchema[nameOf(record.operation)]&&result.data.result?.request_key===record.request_key:operationExpected&&result.data.operation===operationExpected:operation==='rpc:mission_factory_compile_state_v2'&&record.operation==='edge:mission-factory-quest-compile';if(exactReadback&&record.actor===actor&&record.request_key===result.data.request_key&&record.fingerprint===await fingerprint({operation:record.operation,args:record.args}))put(pendingKey,{...record,phase:'answered',response:clone(result.data)});}}
   return result;
  }finally{if(request)locks.delete(prefix);}}
 const nameOf=operation=>operation.slice(4);
 const writers=new Set(['mission_factory_create_v1','mission_factory_save_v1','mission_factory_compile_v1','mission_factory_compile_v2','mission_factory_npc_stage_v1','mission_factory_publish_v1','mission_factory_sensitive_review_request_v1','mission_factory_sensitive_review_decide_v1','mission_factory_sensitive_review_request_v2','mission_factory_sensitive_review_decide_v2','mission_factory_quest_roster_assign_v1','mission_factory_quest_variant_commit_v1']);
 const transport={auth:client.auth,rpc:(name,args={})=>wire('rpc:'+name,args,writers.has(name)?args.p_decision_key||args.p_request:null,()=>client.rpc(name,args)),functions:{invoke:async(name,options={})=>{let body=options.body;if(body instanceof Blob){await authorize();const bytes=await body.arrayBuffer();body={type:body.type,bytes:bytes.byteLength,sha256:mediaHex(await crypto.subtle.digest('SHA-256',bytes))};}const args={body,headers:options.headers||{}},request=options.body?.request_key||options.headers?.['x-mf-request-key'];return wire('edge:'+name,args,request,()=>client.functions.invoke(name,options));}}};
 transport.mediaRequest=details=>{alive();const key=prefix+'media-key/'+canonical(details),previous=storage?.getItem(key);if(previous){const request=JSON.parse(previous);if(!UUID.test(request||''))throw Error('Request media non valida.');return request;}const request=crypto.randomUUID();put(key,request);return request;};
 transport.lifecycleEpoch=()=>epoch;transport.invalidateEpoch=()=>{epoch++;};
 transport.setLifecycle=predicate=>{if(typeof predicate!=='function')throw Error('Lifecycle mancante.');scopes.add(predicate);};
 return transport;
}
