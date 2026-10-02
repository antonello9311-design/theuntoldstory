import {createEditorLifecycleTransport,validateScheduleCapability} from './mf-editor-api-2f2db279da127b0da4aef965b7f6646054be525a095c117f62cb3af35c1a5457.mjs';
import {executionContext,episodeState as validateQuestEpisodeState,QUEST_STAFF_LOCATION} from './mf-quest-runtime-api-3cece36ec7e80e4e86831eaf81cf79671f331446d240be9a79cdf13122d92b2c.mjs';
// Consumer candidato del contratto Factory /2. Nessuna porta service-only nel browser.
const KIND = new Set(['mission', 'quest_ai']);
const UUID = /^[0-9a-f]{8}-[0-9a-f]{4}-[1-8][0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}$/i;
const SHA = /^[0-9a-f]{64}$/i;
const SOURCE = Object.freeze({mission: 'mission', quest_ai: 'quest_ai'});
const MEDIA_RELEASE = 'mission-factory-context-media/2';
const QUEST_COMPILE_EDGE = 'mission-factory-quest-compile';
const COMPILE_ATTEMPT_PREFIX = 'mf-quest-compile-edge-attempt/2/';
const PHASE = /^[a-z][a-z0-9_]{1,63}\/[a-z][a-z0-9_]{1,63}$/;
const mediaKeys = new Map();
const mediaHex = bytes => [...new Uint8Array(bytes)].map(x => x.toString(16).padStart(2,'0')).join('');
const SCHEMA = Object.freeze({
  catalog: 'mission-factory-catalog/4',
  created: 'mission-factory-draft-created/2',
  opened: 'mission-factory-draft-state/2',
  saved: 'mission-factory-draft-save/2',
  preview: 'mission-factory-preview/2',
  published: 'mission-factory-publish-receipt/2',
  delivery: 'mission-factory-delivery/2',
  request: 'mission-factory-request-state/2',
  publishState: 'mission-factory-publish-state/2'
});
function fail(code) { const error = new Error(code); error.code = code; throw error; }
function requireKind(kind) { if (!KIND.has(kind)) fail('MF_KIND'); return kind; }
function requireSchema(value, schema, kind) {
  if (!value || value.schema_version !== schema || value.content_kind !== kind) fail('MF_RESPONSE_SHAPE');
  return value;
}
function catalogExecutionContext(v){
 const keys=['protected_public_quest_available','mode','public_general_available','source_draft_id','source_draft_version','source_sha256','qualification_sha256','logical_visibilities','location_id'];
 if(!v||typeof v!=='object'||Array.isArray(v)||Object.keys(v).sort().join()!==keys.sort().join()||typeof v.protected_public_quest_available!=='boolean'||typeof v.public_general_available!=='boolean'||!Array.isArray(v.logical_visibilities))fail('MF_CATALOG_CONTEXT4');
 if(v.protected_public_quest_available){if(v.mode!=='staff_simulation'||!UUID.test(v.source_draft_id||'')||!Number.isSafeInteger(v.source_draft_version)||v.source_draft_version<1||!SHA.test(v.source_sha256||'')||!SHA.test(v.qualification_sha256||'')||JSON.stringify(v.logical_visibilities)!=='["open","scheduled"]'||v.location_id!==QUEST_STAFF_LOCATION)fail('MF_CATALOG_CONTEXT4');}
 else if(v.mode!==null||v.source_draft_id!==null||v.source_draft_version!==null||v.source_sha256!==null||v.qualification_sha256!==null||v.location_id!==null||v.logical_visibilities.length)fail('MF_CATALOG_CONTEXT4');
 return Object.freeze({...v});
}
function sensitiveShape(value, draftId) {
  if (value?.schema_version !== 'mission-factory-sensitive-review-state/2' ||
      value.content_kind !== SOURCE.quest_ai || value.draft_id !== draftId ||
      typeof value.required !== 'boolean' || !SHA.test(value.document_sha256 || '') ||
      (value.request_key !== null && !UUID.test(value.request_key || '')) ||
      !['not_requested','needs_request','requested','approved','rejected'].includes(value.status) ||
      typeof value.can_decide !== 'boolean') fail('MF_QUEST_SENSITIVE_SHAPE');
  return value;
}
function validateIds(value, kind, materialized) {
  const mission = value.mission_id, arc = value.quest_arc_id, episode = value.quest_episode_id;
  if (materialized) {
    if (kind === SOURCE.mission && (!UUID.test(mission || '') || arc !== null || episode !== null)) fail('MF_SOURCE_IDS');
    if (kind === SOURCE.quest_ai && (mission !== null || !UUID.test(arc || '') || !UUID.test(episode || ''))) fail('MF_SOURCE_IDS');
  } else if (mission !== null || arc !== null || episode !== null) fail('MF_SOURCE_IDS');
}
function validateReceipt(value, requestKey, kind, contextQuest=false) {
  requireSchema(value, SCHEMA.published, kind);
  if (value.request_key !== requestKey || !UUID.test(value.draft_id || '') ||
      !['staff', 'scheduled', 'open', 'failed_review'].includes(value.state) ||
      !['staff', 'scheduled', 'open'].includes(value.visibility)) fail('MF_PUBLISH_RECEIPT');
  if (kind === SOURCE.quest_ai ? !['one_shot', 'trama'].includes(value.quest_kind) : value.quest_kind !== null)
    fail('MF_QUEST_KIND');
  validateIds(value, kind, value.state === 'staff' || value.state === 'open' || contextQuest&&kind==='quest_ai'&&value.state==='scheduled');
  if (value.source_sha256 !== null && !SHA.test(value.source_sha256 || '')) fail('MF_SOURCE_HASH');
  return value;
}
function validateDelivery(value, kind, contextQuest=false) {
  requireSchema(value, SCHEMA.delivery, kind);
  if (!['staff', 'scheduled', 'open', 'failed_review'].includes(value.state)) fail('MF_DELIVERY_STATE');
  validateIds(value, kind, value.state === 'staff' || value.state === 'open' || contextQuest&&kind==='quest_ai'&&value.state==='scheduled');
  return value;
}

function fixed30Document(d){
 if(!d||d.schema_version!=='mission-factory-quest-reward-policy/2'
   ||Object.keys(d).sort().join()!==['schema_version','recipient_mode','xp_per_eligible_recipient','ryo_per_eligible_recipient','items','terminal_outcomes','award_scope'].sort().join()
   ||d.recipient_mode!=='uniform'||d.xp_per_eligible_recipient!==30||d.ryo_per_eligible_recipient!==0
   ||!Array.isArray(d.items)||d.items.length||JSON.stringify(d.terminal_outcomes)!=='["success","failure"]'
   ||d.award_scope!=='arc_once_per_character')fail('MF_QUEST_FIXED30_POLICY_SHAPE');
 return structuredClone(d);
}
function fixed30Qualification(v,request){
 if(v?.schema_version!=='quest-reward-policy-qualified/2'||v.request_key!==request
   ||!UUID.test(v.policy_id||'')||!SHA.test(v.policy_sha256||'')||v.scope!=='staff'
   ||typeof v.catalog_version!=='string'||!v.catalog_version||!SHA.test(v.catalog_sha256||''))fail('MF_QUEST_FIXED30_QUALIFICATION');
 fixed30Document(v.document);return structuredClone(v);
}

export function createQuestAwareFactoryApi(client, {identity,isCurrent} = {}) {
  client=createEditorLifecycleTransport(client,{identity,isCurrent,namespace:'quest'});
  if (typeof client?.rpc !== 'function') fail('MF_CLIENT_MISSING');
  let questCompileQualified = false;
  const attempted = new Set();
  const owner = () => {
    const value = typeof identity === 'function' ? identity() : null;
    if (!UUID.test(value || '')) fail('MF_QUEST_AUTH_IDENTITY');
    return value;
  };
  const assertOwner = actor => { if (owner() !== actor) fail('MF_QUEST_AUTH_CHANGED'); };
  const journalKey = request => `mf-quest-compile-request/3/${owner()}/${request}`;
  const rememberCompile = args => {
    const encoded = JSON.stringify(args), storageKey = journalKey(args.request_key);
    // La UUID e i tre argomenti originali devono essere persistiti prima della RPC.
    try {
      const previous = sessionStorage.getItem(storageKey);
      if (previous && previous !== encoded) fail('MF_QUEST_COMPILE_PAYLOAD_CHANGED');
      sessionStorage.setItem(storageKey, encoded);
      if (sessionStorage.getItem(storageKey) !== encoded) fail('MF_QUEST_RECOVERY_STORAGE');
    } catch (error) { if (error?.code) throw error; fail('MF_QUEST_RECOVERY_STORAGE'); }
  };
  const providerState = async request_key => {
    if (!UUID.test(request_key || '')) fail('MF_QUEST_COMPILE_INPUT');
    const actor = owner();
    const result = await client.rpc('mission_factory_provider_state_v1', {p_request:request_key});
    assertOwner(actor);
    if (result?.error) throw result.error;
    const value = result?.data;
    const statuses = ['unknown','claimed','reserved','authorized','provider_started','success','failed','unknown_billable'];
    if (value?.schema_version !== 'mission-factory-provider/1' || value.request_key !== request_key ||
        !statuses.includes(value.status) || value.provider_allowed !== false ||
        (value.receipt_id !== null && !UUID.test(value.receipt_id || '')) ||
        Object.keys(value).some(k => !['schema_version','request_key','receipt_id','status','provider_allowed'].includes(k)))
      fail('MF_QUEST_PROVIDER_STATE');
    return {schema_version:value.schema_version,request_key,receipt_id:value.receipt_id,
      status:value.status,provider_allowed:false};
  };
  const readCompile = async request_key => {
    const actor = owner();
    const editorial = await compileState(request_key);
    // Un errore contabile non diventa costo zero o successo; la lettura editoriale resta distinta.
    let provider=null;
    try { provider=await providerState(request_key); } catch {}
    assertOwner(actor);
    return {...editorial,provider_state:provider,provider_readback:provider?'confirmed':'unavailable'};
  };
  const compileState = async request_key => {
    if (!UUID.test(request_key || '')) fail('MF_QUEST_COMPILE_INPUT');
    const actor = owner();
    const value = await rpc('mission_factory_compile_state_v2', {p_request: request_key,
      p_content_kind: SOURCE.quest_ai}, 'mission-factory-compile-state/2', SOURCE.quest_ai);
    assertOwner(actor);
    if (value.request_key !== request_key || !['unknown','queued','running','complete','rejected'].includes(value.state)) fail('MF_QUEST_COMPILE_STATE');
    return value;
  };
  const wasAttempted = key => {
    if (attempted.has(key)) return true;
    try { return sessionStorage.getItem(COMPILE_ATTEMPT_PREFIX + owner() + '/' + key) === 'attempted'; } catch { return false; }
  };
  const markAttempted = key => {
    const storageKey = COMPILE_ATTEMPT_PREFIX + owner() + '/' + key;
    try {
      sessionStorage.setItem(storageKey, 'attempted');
      if (sessionStorage.getItem(storageKey) !== 'attempted') fail('MF_QUEST_RECOVERY_STORAGE');
    } catch { fail('MF_QUEST_RECOVERY_STORAGE'); }
    attempted.add(key);
  };
  const publishContexts=new Map();
  const readPublishedContext=async(receipt)=>{if(receipt.content_kind!=='quest_ai'||!receipt.quest_episode_id)return null;const r=await client.rpc('mission_factory_quest_episode_state_v4',{p_episode:receipt.quest_episode_id});if(r.error)throw r.error;const v=validateQuestEpisodeState(r.data,receipt.quest_episode_id);if(v.schema_version!=='quest-episode-runtime-state/4'||v.quest_arc_id!==receipt.quest_arc_id)fail('MF_PUBLISH_CONTEXT_READBACK');const ctx=executionContext(v.execution_context,'episode');publishContexts.set(receipt.request_key,ctx);return ctx;};
  const rpc = async (name, args, schema, kind) => {
    const result = await client.rpc(name, args);
    if (result?.error) throw result.error;
    return requireSchema(result?.data, schema, kind);
  };
  return {
    publishedExecutionContext:request=>publishContexts.get(request)??null,
    setLifecycle:predicate=>client.setLifecycle(predicate),
    lifecycleEpoch:()=>client.lifecycleEpoch(),invalidateEpoch:()=>client.invalidateEpoch(),
    catalog: async () => {
      const result = await client.rpc('mission_factory_catalog_v4', {});
      if (result?.error) throw result.error;
      const catalog = result?.data;
      if (catalog?.schema_version !== SCHEMA.catalog || !Array.isArray(catalog.content_kinds) ||
          (catalog.quest_compile_qualified !== undefined && typeof catalog.quest_compile_qualified !== 'boolean')||typeof catalog.public_open_qualified!=='boolean'||catalog.public_open_reason_code!==null&&!/^MF_[A-Z0-9_]+$/.test(catalog.public_open_reason_code||'')||catalog.public_open_qualified&&catalog.public_open_reason_code!==null) fail('MF_CATALOG_SHAPE');
      const catalogKeys=['schema_version','version','content_kinds','capabilities','map_references','budget_policies','reward_policies','limits','quest_compile_qualified','quest_compile_reason_code','public_open_qualified','public_open_reason_code','execution_context'];if(Object.keys(catalog).sort().join()!==catalogKeys.sort().join())fail('MF_CATALOG_CONTEXT4');
      catalog.execution_context=catalogExecutionContext(catalog.execution_context);
      if(catalog.public_open_qualified!==(catalog.execution_context.protected_public_quest_available||catalog.execution_context.public_general_available))fail('MF_CATALOG_CONTEXT4');
      if(!Array.isArray(catalog.reward_policies))fail('MF_QUEST_REWARD_CATALOG_SHAPE');
      for(const row of catalog.reward_policies){if(row?.document?.schema_version==='mission-factory-quest-reward-policy/2'){
        if(row.qualified!==true||!UUID.test(row.id||'')||!SHA.test(row.policy_sha256||'')||row.scope!=='staff'||!row.allowed_content_kinds?.includes('quest_ai'))fail('MF_QUEST_FIXED30_CATALOG_SHAPE');
        fixed30Document(row.document);
      }}
      questCompileQualified = catalog.quest_compile_qualified === true;
      return catalog;
    },
    qualifyRewardPolicy: async ({request_key}) => {
      if(!UUID.test(request_key||''))fail('MF_QUEST_REWARD_REQUEST_KEY');
      const response=await client.rpc('mission_factory_quest_reward_policy_qualify_v2',{p_request:request_key});
      if(response?.error)throw response.error;return fixed30Qualification(response?.data,request_key);
    },
    rewardPolicyRequestState: async ({request_key}) => {
      if(!UUID.test(request_key||''))fail('MF_QUEST_REWARD_REQUEST_KEY');
      const response=await client.rpc('mission_factory_quest_reward_policy_request_state_v2',{p_request:request_key});
      if(response?.error)throw response.error;const v=response?.data;
      if(v?.schema_version!=='quest-reward-policy-request-state/2'||v.request_key!==request_key||!['unknown','qualified'].includes(v.state))fail('MF_QUEST_REWARD_REQUEST_STATE');
      if(v.state==='unknown'){if(v.receipt!==null)fail('MF_QUEST_REWARD_REQUEST_STATE');}
      else fixed30Qualification(v.receipt,request_key);return structuredClone(v);
    },
    createDraft: async ({request_key, source, catalog_version}) => {
      const kind = requireKind(source?.content_kind);
      if (source?.schema_version !== 'mission-factory-create/2' || !UUID.test(request_key || '')) fail('MF_CREATE_INPUT');
      const value = await rpc('mission_factory_create_v1', {p_request: request_key, p_source: source, p_catalog_version: catalog_version}, SCHEMA.created, kind);
      if (value.request_key !== request_key || !UUID.test(value.draft_id || '') ||
          value.document?.schema_version !== 'mission-factory-draft/2' || value.document.content_kind !== kind) fail('MF_CREATE_RECEIPT');
      return value;
    },
    openDraft: async ({draft_id, content_kind}) => {
      const kind = requireKind(content_kind);
      if (!UUID.test(draft_id || '')) fail('MF_DRAFT_ID');
      const value = await rpc('mission_factory_open_v1', {p_draft: draft_id}, SCHEMA.opened, kind);
      if (value.draft_id !== draft_id || value.document?.schema_version !== 'mission-factory-draft/2' ||
          value.document.content_kind !== kind) fail('MF_OPEN_RECEIPT');
      return value;
    },
    save: async ({draft_id, expected_version, document, request_key}) => {
      const kind = requireKind(document?.content_kind);
      if (document?.schema_version !== 'mission-factory-draft/2' || !UUID.test(draft_id || '') || !UUID.test(request_key || '')) fail('MF_SAVE_INPUT');
      const value = await rpc('mission_factory_save_v1', {p_draft: draft_id, p_expected_version: expected_version, p_document: document, p_request: request_key}, SCHEMA.saved, kind);
      if (value.request_key !== request_key || value.draft_id !== draft_id) fail('MF_SAVE_RECEIPT');
      return value;
    },
    preview: async ({draft_id, expected_version, content_kind}) => {
      const kind = requireKind(content_kind);
      const value = await rpc('mission_factory_preview_v1', {p_draft: draft_id, p_expected_version: expected_version}, SCHEMA.preview, kind);
      if (value.draft_id !== draft_id || value.draft_version !== expected_version ||
          !Number.isSafeInteger(expected_version) || expected_version < 1 || !Array.isArray(value.errors) ||
          (value.preview_seal !== null && !SHA.test(value.preview_seal || '')) ||
          !Array.isArray(value.required_variants) || !Array.isArray(value.validated_variants) ||
          (kind === SOURCE.quest_ai ? value.validation_mode !== 'ai_only' : value.validation_mode !== 'dual')) fail('MF_PREVIEW_RECEIPT');
      return value;
    },
    scheduleCapability: async ({draft_id,expected_version,preview_seal,due}) => {
      if (!UUID.test(draft_id||'') || !Number.isSafeInteger(expected_version) || expected_version<1 ||
          !SHA.test(preview_seal||'') || typeof due!=='string' || !Number.isFinite(Date.parse(due)))
        throw Error('Bozza, sigillo o data di programmazione non validi.');
      const result=await client.rpc('mission_factory_schedule_capability_v1',{
        p_draft:draft_id,p_expected_version:expected_version,p_preview_seal:preview_seal,p_due:due});
      if (result.error) throw Error(result.error.message||'Programmazione non disponibile.');
      return validateScheduleCapability(result.data);
    },
    publish: async ({draft_id, expected_version, preview_seal, request_key, visibility, scheduled_at, content_kind}) => {
      const kind = requireKind(content_kind);
      if (!UUID.test(draft_id || '') || !UUID.test(request_key || '') || !SHA.test(preview_seal || '') ||
          !Number.isSafeInteger(expected_version) || expected_version < 1) fail('MF_PUBLISH_INPUT');
      const params={p_draft:draft_id,p_expected_version:expected_version,p_preview_seal:preview_seal,p_request:request_key,p_visibility:visibility,p_scheduled_at:scheduled_at};
      if(kind==='quest_ai'&&['open','scheduled'].includes(visibility)){
        const response=await client.rpc('mission_factory_quest_publish_context_v4',params);if(response.error)throw response.error;const wrapper=response.data;
        if(wrapper?.schema_version!=='quest-public-context-publish/4'||Object.keys(wrapper).sort().join()!==['schema_version','receipt','execution_context'].sort().join())fail('MF_PUBLISH_CONTEXT4');
        const ctx=executionContext(wrapper.execution_context,'publish');const receiptKeys=['schema_version','request_key','draft_id','content_kind','quest_kind','state','visibility','scheduled_at','mission_id','quest_arc_id','quest_episode_id','source_sha256','config_version','activation_id'];if(!wrapper.receipt||Object.keys(wrapper.receipt).sort().join()!==receiptKeys.sort().join())fail('MF_PUBLISH_CONTEXT4');const value=validateReceipt(wrapper.receipt,request_key,kind,true);if(!SHA.test(value.source_sha256||'')||value.config_version!==null||value.activation_id!==null||value.draft_id!==draft_id||value.scheduled_at!==null&&Date.parse(value.scheduled_at)!==Date.parse(scheduled_at)||value.scheduled_at===null&&scheduled_at!==null)fail('MF_PUBLISH_CONTEXT4');
        if(ctx.logical_visibility!==visibility||(ctx.logical_due_at===null?scheduled_at!==null:!Number.isFinite(Date.parse(scheduled_at))||Date.parse(ctx.logical_due_at)!==Date.parse(scheduled_at))||ctx.mode==='staff_simulation'&&value.visibility!==(visibility==='open'?'staff':'scheduled')||ctx.mode==='public_real'&&value.visibility!==visibility)fail('MF_PUBLISH_CONTEXT4');
        publishContexts.set(request_key,ctx);return value;
      }
      const value=await rpc('mission_factory_publish_v1',params,SCHEMA.published,kind);return validateReceipt(value,request_key,kind);
    },
    npcCatalog: async ({content_kind, require_combat = false}) => {
      const kind = requireKind(content_kind);
      const response = await client.rpc('mission_factory_npc_catalog_v2', {p_content_kind: kind, p_require_combat: require_combat});
      if (response?.error) throw response.error;
      const value = response?.data;
      if (value?.schema_version !== 'mission-factory-npc-catalog/2' || value.content_kind !== kind) fail('MF_NPC_CATALOG_SHAPE');
      if (value.require_combat !== require_combat || !Array.isArray(value.items) ||
          new Set(value.items.map(x => x.npc_version_id)).size !== value.items.length ||
          value.items.some(x => !Array.isArray(x.usage_scopes) || !x.usage_scopes.includes(kind) ||
            !UUID.test(x.npc_id || '') || !UUID.test(x.npc_version_id || '') || !SHA.test(x.bundle_sha256 || '') ||
            typeof x.combat !== 'boolean' ||
            (x.staff_authoring_candidate !== undefined && typeof x.staff_authoring_candidate !== 'boolean') ||
            require_combat && x.combat !== true)) fail('MF_NPC_CATALOG_SHAPE');
      return value.items;
    },
    npcAuthoringCheck: async ({draft_id,expected_version,actor_key}) => {
      if (!UUID.test(draft_id || '') || !Number.isSafeInteger(expected_version) || expected_version < 1 ||
          !/^[a-z][a-z0-9_]{1,63}$/.test(actor_key || '')) fail('MF_NPC_AUTHORING_INPUT');
      const response = await client.rpc('mission_factory_npc_authoring_check_v1',
        {p_draft:draft_id,p_expected_version:expected_version,p_actor_key:actor_key});
      if (response?.error) throw response.error;
      return response?.data;
    },
    npcVersion: async ({npc_id, npc_version_id, content_kind, require_combat = false}) => {
      const kind = requireKind(content_kind);
      const response = await client.rpc('mission_factory_npc_version_v2', {p_npc: npc_id, p_version: npc_version_id,
        p_content_kind: kind, p_require_combat: require_combat});
      if (response?.error) throw response.error;
      const value = response?.data;
      if (value?.schema_version !== 'mission-factory-npc-version/2') fail('MF_NPC_VERSION_SHAPE');
      if (value.npc_id !== npc_id || value.npc_version_id !== npc_version_id ||
          !Array.isArray(value.usage_scopes) || !value.usage_scopes.includes(kind) ||
          !SHA.test(value.bundle_sha256 || '') || require_combat && value.combat !== true) fail('MF_NPC_VERSION_SHAPE');
      return value;
    },
    attestQuestMedia: async ({draft_id,phase_key,file}) => {
      if (!UUID.test(draft_id || '') || !PHASE.test(phase_key || '') || !file ||
          !['image/png','image/jpeg','image/webp'].includes(file.type) ||
          !Number.isSafeInteger(file.size) || file.size < 1 || file.size > 4194304)
        fail('MF_QUEST_MEDIA_INPUT');
      if (typeof client.functions?.invoke !== 'function') fail('MF_QUEST_MEDIA_EDGE');
      const raw = await file.arrayBuffer();
      if (raw.byteLength !== file.size) fail('MF_QUEST_MEDIA_BYTES');
      const sha256 = mediaHex(await crypto.subtle.digest('SHA-256',raw));
      const storageKey = `mf-quest-media/2/${owner()}/${draft_id}/${phase_key}/${sha256}`;
      let request_key = mediaKeys.get(storageKey);
      if (!request_key) {
        try { const stored=sessionStorage.getItem(storageKey);if(UUID.test(stored || ''))request_key=stored; } catch {}
      }
      request_key ||= crypto.randomUUID();mediaKeys.set(storageKey,request_key);
      sessionStorage.setItem(storageKey,request_key);if(sessionStorage.getItem(storageKey)!==request_key)fail('MF_QUEST_RECOVERY_STORAGE');
      const {data,error,response} = await client.functions.invoke('mission_factory_context_media_attest_v2', {
        body:new Blob([raw],{type:file.type}),
        headers:{'content-type':file.type,'x-mf-draft-id':draft_id,'x-mf-phase-key':phase_key,
          'x-mf-request-key':request_key,'x-mf-sha256':sha256,'x-mf-expected-release':MEDIA_RELEASE}
      });
      if (error) throw error;
      const [episode_key,step_key]=phase_key.split('/');
      if (data?.schema_version !== 'mission-factory-context-media-registration/2' ||
          data.release !== MEDIA_RELEASE ||
          data.content_kind !== SOURCE.quest_ai || data.draft_id !== draft_id ||
          data.request_key !== request_key || data.phase_key !== phase_key ||
          data.episode_key !== episode_key || data.step_key !== step_key ||
          data.state !== 'registered' || data.bucket !== 'location-images' ||
          data.sha256 !== sha256 || data.mime_type !== file.type || !UUID.test(data.media_id || ''))
        fail('MF_QUEST_MEDIA_RECEIPT');
      const exposedRelease=response?.headers?.get?.('x-mission-factory-media-release');
      if (exposedRelease && exposedRelease !== MEDIA_RELEASE) fail('MF_QUEST_MEDIA_RELEASE');
      mediaKeys.delete(storageKey);try { sessionStorage.removeItem(storageKey); } catch {}
      return data;
    },
    questMediaCatalog: async ({draft_id}) => {
      if (!UUID.test(draft_id || '')) fail('MF_QUEST_MEDIA_DRAFT');
      const response = await client.rpc('mission_factory_context_media_catalog_v2',
        {p_draft: draft_id, p_content_kind: SOURCE.quest_ai});
      if (response?.error) throw response.error;
      const value = response?.data;
      if (value?.schema_version !== 'mission-factory-context-media-catalog/2' ||
          value.draft_id !== draft_id || value.content_kind !== SOURCE.quest_ai || !Array.isArray(value.items) ||
          value.items.some(x => x.schema_version !== 'mission-factory-context-media-registration/2' ||
            x.draft_id !== draft_id || x.content_kind !== SOURCE.quest_ai || x.state !== 'registered' ||
            !UUID.test(x.media_id || '') || !SHA.test(x.sha256 || '') ||
            x.phase_key !== `${x.episode_key}/${x.step_key}`)) fail('MF_QUEST_MEDIA_CATALOG');
      return value.items;
    },
    rosterCatalog: async ({draft_id}) => {
      const result = await client.rpc('mission_factory_quest_roster_catalog_v1', {p_draft: draft_id});
      if (result?.error) throw result.error;
      const value = result?.data;
      if (value?.schema_version !== 'mission-factory-quest-roster-catalog/1' || value.draft_id !== draft_id ||
          !Array.isArray(value.eligible) || value.eligible.some(x => !UUID.test(x.character_id || ''))) fail('MF_QUEST_ROSTER_CATALOG');
      return value;
    },
    rosterAssign: async ({draft_id, expected_version, character_ids, request_key}) => {
      if (!Array.isArray(character_ids) || character_ids.length < 1 || character_ids.length > 4 ||
          character_ids.some(x => !UUID.test(x)) || new Set(character_ids).size !== character_ids.length) fail('MF_QUEST_ROSTER_INPUT');
      const result = await client.rpc('mission_factory_quest_roster_assign_v1', {p_draft: draft_id,
        p_expected_version: expected_version, p_character_ids: character_ids, p_request: request_key});
      if (result?.error) throw result.error;
      const value = result?.data;
      if (value?.schema_version !== 'mission-factory-quest-roster-assigned/1' || value.request_key !== request_key ||
          value.draft_id !== draft_id || !UUID.test(value.assignment?.roster_assignment_id || '') ||
          value.assignment.draft_id !== draft_id || value.assignment.state !== 'assigned') fail('MF_QUEST_ROSTER_RECEIPT');
      return value;
    },
    rosterState: async ({draft_id}) => {
      const result = await client.rpc('mission_factory_quest_roster_state_v1', {p_draft: draft_id});
      if (result?.error) throw result.error;
      return result?.data;
    },
    sensitiveState: async ({draft_id}) => sensitiveShape(await rpc(
      'mission_factory_sensitive_review_state_v2',
      {p_draft:draft_id,p_content_kind:SOURCE.quest_ai},
      'mission-factory-sensitive-review-state/2',SOURCE.quest_ai),draft_id),
    sensitiveRequest: async ({draft_id,expected_version,request_key}) => {
      if (!UUID.test(draft_id || '') || !UUID.test(request_key || '') ||
          !Number.isSafeInteger(expected_version) || expected_version < 1) fail('MF_QUEST_SENSITIVE_INPUT');
      return sensitiveShape(await rpc('mission_factory_sensitive_review_request_v2',
        {p_draft:draft_id,p_expected_version:expected_version,p_request:request_key,
         p_content_kind:SOURCE.quest_ai},'mission-factory-sensitive-review-state/2',SOURCE.quest_ai),draft_id);
    },
    sensitiveDecide: async ({draft_id,request_key,expected_version,decision,decision_key}) => {
      if (!UUID.test(draft_id || '') || !UUID.test(request_key || '') ||
          !UUID.test(decision_key || '') || !['approved','rejected'].includes(decision) ||
          !Number.isSafeInteger(expected_version) || expected_version < 1) fail('MF_QUEST_SENSITIVE_INPUT');
      return sensitiveShape(await rpc('mission_factory_sensitive_review_decide_v2',
        {p_draft:draft_id,p_request:request_key,p_expected_version:expected_version,
         p_decision:decision,p_decision_key:decision_key,p_content_kind:SOURCE.quest_ai},
        'mission-factory-sensitive-review-state/2',SOURCE.quest_ai),draft_id);
    },
    compileQuest: async ({draft_id, expected_version, request_key}) => {
      if (!questCompileQualified) fail('MF_QUEST_COMPILE_UNQUALIFIED');
      if (!UUID.test(draft_id || '') || !UUID.test(request_key || '') ||
          !Number.isSafeInteger(expected_version) || expected_version < 1) fail('MF_QUEST_COMPILE_INPUT');
      const actor = owner();
      rememberCompile({draft_id,expected_version,request_key});
      const value = await rpc('mission_factory_compile_v2', {p_draft: draft_id, p_expected_version: expected_version,
        p_request: request_key}, 'mission-factory-compile-request/2', SOURCE.quest_ai);
      assertOwner(actor);
      if (value.request_key !== request_key || value.draft_id !== draft_id ||
          !['accepted','complete'].includes(value.state)) fail('MF_QUEST_COMPILE_RECEIPT');
      if (value.state === 'complete') return {...value,...await readCompile(request_key)};
      const before = await compileState(request_key);
      if (before.state === 'unknown') fail('MF_QUEST_COMPILE_UNCERTAIN');
      if (before.state !== 'queued' || wasAttempted(request_key))
        return {...value,worker_state:before.state,...await readCompile(request_key)};
      if (typeof client.functions?.invoke !== 'function') fail('MF_QUEST_COMPILE_EDGE_MISSING');
      assertOwner(actor);
      markAttempted(request_key);
      // La risposta Edge non e' autorita': anche un 422 o un timeout richiede readback sulla stessa request.
      try { await client.functions.invoke(QUEST_COMPILE_EDGE, {body:{request_key}}); } catch {}
      assertOwner(actor);
      const after = await readCompile(request_key);
      if (after.state === 'unknown') fail('MF_QUEST_COMPILE_UNCERTAIN');
      return {...value, worker_state: after.state,provider_state:after.provider_state,provider_readback:after.provider_readback};
    },
    compileQuestState: async ({request_key}) => readCompile(request_key),
    providerState: async ({request_key}) => providerState(request_key),
    commitQuestVariant: async ({draft_id, expected_version, proposal_request = null, document, request_key}) => {
      if (document?.schema_version !== 'quest-creation-document/1' || document.direction_mode !== 'ai' ||
          !['one_shot','trama'].includes(document.quest_kind)) fail('MF_QUEST_VARIANT_INPUT');
      const response = await client.rpc('mission_factory_quest_variant_commit_v1', {p_draft: draft_id,
        p_expected_version: expected_version, p_proposal_request: proposal_request,
        p_document: document, p_request: request_key});
      if (response?.error) throw response.error;
      const value = response?.data;
      if (value?.schema_version !== 'mission-factory-quest-variant/1' || value.content_kind !== SOURCE.quest_ai) fail('MF_QUEST_VARIANT_RECEIPT');
      if (value.request_key !== request_key || value.draft_id !== draft_id ||
          value.variant_state !== 'complete' || !SHA.test(value.document_sha256 || '')) fail('MF_QUEST_VARIANT_RECEIPT');
      return value;
    },
    requestState: async ({request_key, content_kind}) => {
      const kind = requireKind(content_kind);
      const value = await rpc('mission_factory_request_state_v2', {p_request: request_key, p_content_kind: kind}, SCHEMA.request, kind);
      if (value.request_key !== request_key || !['unknown', 'confirmed'].includes(value.state)) fail('MF_REQUEST_READBACK');
      return value;
    },
    publishState: async ({request_key, content_kind}) => {
      const kind = requireKind(content_kind);
      const value = await rpc('mission_factory_publish_state_v2', {p_request: request_key, p_content_kind: kind}, SCHEMA.publishState, kind);
      if (value.request_key !== request_key || !['unknown', 'confirmed'].includes(value.state)) fail('MF_PUBLISH_READBACK');
      if (value.state === 'confirmed') {
        const ctx=kind==='quest_ai'?await readPublishedContext(value.result):null;
        validateReceipt(value.result, request_key, kind,ctx!==null);
        validateDelivery(value.delivery, kind,ctx!==null);
      }
      return value;
    }
  };
}
