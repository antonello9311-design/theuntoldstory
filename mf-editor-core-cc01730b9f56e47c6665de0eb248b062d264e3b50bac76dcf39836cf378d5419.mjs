import {validateMissionD100Binding} from './mf-mission-native-bridge-2d2425cd4006f98ee4afa2bc61fbdb2fe4b8d34bd64b60d7c23e3ce8c549d978.mjs';
// Candidato isolato. Nessuna chiamata diretta alle porte Builder service-only.
export const EDITOR_SCHEMA = 'mission-factory-draft/1';
export const CATALOG_SCHEMA = 'mission-factory-catalog/1';
export const PREVIEW_SCHEMA = 'mission-factory-preview/1';
export const PUBLISH_SCHEMA = 'mission-factory-publish-receipt/1';
const UUID = /^[0-9a-f]{8}-[0-9a-f]{4}-[1-8][0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}$/i;
const SHA = /^[0-9a-f]{64}$/i;
const MODES = new Set(['ai', 'human']);
const VISIBILITIES = new Set(['staff', 'scheduled', 'open']);
const PUBLISH_STATES = new Set(['staff', 'scheduled', 'open', 'failed_review']);
const DELIVERY_STATES = new Set(['staff', 'scheduled', 'open', 'failed_review']);
const FORBIDDEN_PROPOSAL_KEYS = new Set(['stats', 'hp', 'pv', 'chakra', 'techniques', 'roll', 'dice', 'coordinates', 'reward_amount', 'result']);

function clone(value) { return structuredClone(value); }
function fail(code, detail = code) { const error = new Error(detail); error.code = code; throw error; }
function ensureUuid(value, code) { if (!UUID.test(value || '')) fail(code); return value; }
function publishReceipt(value, request) {
  if (value?.schema_version !== PUBLISH_SCHEMA || value.request_key !== request || !PUBLISH_STATES.has(value.state)) fail('MF_PUBLISH_RECEIPT');
  if (value.state === 'scheduled' && value.mission_id !== null) fail('MF_PUBLISH_SCHEDULE_SHAPE');
  if (['staff','open'].includes(value.state) && !UUID.test(value.mission_id || '')) fail('MF_PUBLISH_MISSION_ID');
  return value;
}
function deliveryState(value) {
  if (!value || !DELIVERY_STATES.has(value.state)) fail('MF_PUBLISH_DELIVERY_SHAPE');
  if (['staff','open'].includes(value.state) && !UUID.test(value.mission_id || '')) fail('MF_PUBLISH_DELIVERY_MISSION');
  return value;
}
function assertShape(result, expected, code) {
  if (!result || result.schema_version !== expected) fail(code);
  return result;
}
const MISSION_CAPABILITY_FIELDS = ['key','kind','family','usage','phase_allowed','allowed_content_kinds','producer','consumer','projection_version','event_keys','qualified','reason_code','qualification_basis'];
const MISSION_PHASE_CAPABILITY = {
  narrative:{key:'mission.narrative.scene',kind:'narrative'},
  combat:{key:'mission.combat.encounter',kind:'mechanical'},
  d100:{key:'mission.d100.native',kind:'mechanical'}
};
// C645: una sola proiezione Mission per selettore, validazione e pubblicabilità.
// C670: D100 è selezionabile solo dalla distinta proiezione Mission qualificata dal server.
export function missionCapabilitiesForPhase(catalog, phaseKind) {
  const expected = Object.hasOwn(MISSION_PHASE_CAPABILITY, phaseKind) ? MISSION_PHASE_CAPABILITY[phaseKind] : null;
  if (!expected || catalog?.event_projection_version !== 'mission-factory-native-event/1' ||
      !Array.isArray(catalog.phase_kinds) || !Array.isArray(catalog.events) || !Array.isArray(catalog.capabilities)) return [];
  const phaseKinds = catalog.phase_kinds.filter(x => x?.kind === phaseKind);
  if (phaseKinds.length !== 1 || phaseKinds[0].qualified !== true) return [];
  const phaseEvents = catalog.events.filter(x => x?.phase_kind === phaseKind);
  if (!phaseEvents.length || phaseEvents.some(x => typeof x.key !== 'string' || !x.key || x.qualified !== true ||
      !Array.isArray(x.direction_modes) || !x.direction_modes.includes('ai') || !x.direction_modes.includes('human'))) return [];
  const eventKeys = new Set(phaseEvents.map(x => x.key));
  if (eventKeys.size !== phaseEvents.length) return [];
  const entries = catalog.capabilities.filter(x => x?.key === expected.key);
  if (entries.length !== 1) return [];
  const entry = entries[0];
  if (!isPlainObject(entry) || Object.keys(entry).length !== MISSION_CAPABILITY_FIELDS.length ||
      MISSION_CAPABILITY_FIELDS.some(key => !Object.hasOwn(entry, key)) ||
      entry.kind !== expected.kind || entry.family !== phaseKind || entry.usage !== 'phase_transition' ||
      entry.phase_allowed !== true || entry.qualified !== true || entry.reason_code !== null ||
      !Array.isArray(entry.allowed_content_kinds) || entry.allowed_content_kinds.length !== 1 || entry.allowed_content_kinds[0] !== 'mission' ||
      entry.producer !== (phaseKind==='d100'?'mission_factory_owner.c655_projection_v1':'mission_factory_owner.event_projection_v1') ||
      entry.consumer !== 'mission_factory_owner.assert_native_source_equal_v1' ||
      entry.projection_version !== catalog.event_projection_version ||
      !(phaseKind==='d100'?entry.qualification_basis==='native_mission_source_policy_and_reviewed_staff_projection_not_gameplay_QA':['native_mission_source_and_staff_readiness_not_gameplay_QA','native_mission_source_policy_and_reviewed_staff_projection_not_gameplay_QA'].includes(entry.qualification_basis)) ||
      !Array.isArray(entry.event_keys) || entry.event_keys.length !== eventKeys.size ||
      new Set(entry.event_keys).size !== eventKeys.size || entry.event_keys.some(key => !eventKeys.has(key))) return [];
  return [entry];
}
function duplicate(values) { const seen = new Set(); return values.some(v => seen.has(v) || (seen.add(v), false)); }
function isPlainObject(value) { return value !== null && typeof value === 'object' && !Array.isArray(value); }
export function isVariantComplete(value, mode) {
  const doc = value?.document;
  return MODES.has(mode) && value?.mode === mode && value.state === 'complete' && isPlainObject(doc) &&
    doc.schema_version === 'mission-creation-document/1' && isPlainObject(doc.mission) &&
    doc.mission.direction_mode === mode && isPlainObject(doc.plan) &&
    isPlainObject(doc.editorial) && Array.isArray(doc.arenas);
}
function checks(document, catalog, forPublish) {
  const errors = [];
  const add = (code, path) => errors.push({code, path});
  if (!isPlainObject(document) || document.schema_version !== EDITOR_SCHEMA) return [{code:'MF_DOCUMENT_SHAPE', path:'document'}];
  if (document.catalog_version !== catalog.version) add('MF_CATALOG_STALE', 'catalog_version');
  const mission = document.mission || {};
  if (typeof mission.title !== 'string' || !mission.title.trim()) add('MF_TITLE', 'mission.title');
  if (typeof mission.plot_private !== 'string' || !mission.plot_private.trim()) add('MF_PLOT', 'mission.plot_private');
  if (!UUID.test(mission.gathering_location_id || '')) add('MF_LOCATION', 'mission.gathering_location_id');
  if (!Number.isInteger(mission.team_min) || !Number.isInteger(mission.team_max) || mission.team_min < 1 || mission.team_min > mission.team_max || mission.team_max > 4) add('MF_TEAM_NATIVE', 'mission.team_max');
  const limits = catalog.limits || {};
  if (Number.isInteger(limits.pg_min) && mission.team_min < limits.pg_min || Number.isInteger(limits.pg_max) && mission.team_max > limits.pg_max) add('MF_TEAM_UNQUALIFIED', 'mission.team_max');
  const phases = Array.isArray(document.phases) ? document.phases : [];
  if (!phases.length) add('MF_PHASE_REQUIRED', 'phases');
  if (duplicate(phases.map(x => x.step_key))) add('MF_PHASE_DUPLICATE', 'phases');
  const phaseKeys = new Set(phases.map(x => x.step_key));
  if (catalog.event_projection_version !== 'mission-factory-native-event/1' ||
      !Array.isArray(catalog.events) || !Array.isArray(catalog.phase_kinds) ||
      !Array.isArray(catalog.terminal_outcomes)) add('MF_EVENT_CATALOG_UNQUALIFIED', 'catalog.events');
  const kinds = Array.isArray(catalog.phase_kinds) ? catalog.phase_kinds : [];
  const events = Array.isArray(catalog.events) ? catalog.events : [];
  const outcomes = Array.isArray(catalog.terminal_outcomes) ? catalog.terminal_outcomes : [];
  const qualifiedKinds = new Set(kinds.filter(x => missionCapabilitiesForPhase(catalog, x.kind).length > 0).map(x => x.kind));
  const eventFor = key => events.find(x => x.key === key && x.qualified === true &&
    Array.isArray(x.direction_modes) && x.direction_modes.includes('ai') && x.direction_modes.includes('human'));
  const transitionKeys = new Set();
  for (const [index, phase] of phases.entries()) {
    if (!phase.step_key || !phaseKeys.has(phase.step_key)) add('MF_PHASE_KEY', `phases.${index}`);
    if (!qualifiedKinds.has(phase.kind)) add('MF_PHASE_KIND_UNQUALIFIED', `phases.${index}.kind`);
    if (!missionCapabilitiesForPhase(catalog, phase.kind).some(x => x.key === phase.capability_key)) add('MF_CAPABILITY_NOT_QUALIFIED', `phases.${index}.capability_key`);
    if (!Array.isArray(phase.transitions)) add('MF_TRANSITIONS_SHAPE', `phases.${index}.transitions`);
    const transitions = Array.isArray(phase.transitions) ? phase.transitions : [];
    if (transitions.length === 0) {
      if (phase.kind !== 'narrative' || !['success','failure'].includes(phase.terminal_outcome) ||
          !outcomes.includes(phase.terminal_outcome))
        add('MF_TERMINAL_OUTCOME_REQUIRED', `phases.${index}.terminal_outcome`);
    } else if (phase.terminal_outcome !== null) add('MF_TERMINAL_TRANSITIONS_CONFLICT', `phases.${index}.terminal_outcome`);
    for (const transition of transitions) {
      if (!/^[a-z][a-z0-9_]{0,63}$/.test(transition.transition_key || '') || transitionKeys.has(transition.transition_key))
        add('MF_TRANSITION_KEY', `phases.${index}.transitions`);
      transitionKeys.add(transition.transition_key);
      if (!phaseKeys.has(transition.to_step_key)) add('MF_TRANSITION_ORPHAN', `phases.${index}.transitions`);
      const event = eventFor(transition.event_key);
      if (!event || event.phase_kind !== phase.kind) add('MF_EVENT_UNQUALIFIED', `phases.${index}.transitions`);
    }
    if(phase.kind==='d100'){try{const b=validateMissionD100Binding(phase.d100_binding);if(transitions.length!==2||!transitions.some(t=>t.transition_key===b.success_transition_key&&t.event_key==='d100_success')||!transitions.some(t=>t.transition_key===b.complication_transition_key&&t.event_key==='d100_complication'))throw Error('D100transitions');}catch{add('MF_D100_NATIVE_BINDING_REQUIRED',`phases.${index}.d100_binding`);}}
    if (phase.kind === 'combat' && transitions.length) {
      const events = transitions.map(x => x.event_key);
      if (!(events.length === 1 && events[0] === 'combat_any') &&
          !(events.length === 3 && new Set(events).size === 3 &&
            ['combat_pg_win','combat_pg_loss','combat_draw'].every(x => events.includes(x))))
        add('MF_COMBAT_OUTCOME_COVERAGE', `phases.${index}.transitions`);
    }
  }
  const npcs = Array.isArray(document.npc_bindings) ? document.npc_bindings : [];
  if (npcs.length > 12 || Number.isInteger(limits.png_max) && npcs.length > limits.png_max) add('MF_NPC_LIMIT', 'npc_bindings');
  if (duplicate(npcs.map(x => x.actor_key))) add('MF_ACTOR_DUPLICATE', 'npc_bindings');
  for (const [index, npc] of npcs.entries()) {
    if (!UUID.test(npc.npc_id || '') || !UUID.test(npc.npc_version_id || '')) add('MF_NPC_CERTIFIED_VERSION', `npc_bindings.${index}`);
    if (!npc.actor_key || !Array.isArray(npc.phase_keys) || npc.phase_keys.some(key => !phaseKeys.has(key))) add('MF_NPC_PHASE', `npc_bindings.${index}`);
    if (!['alleati','avversari','civili'].includes(npc.team)) add('MF_NPC_TEAM_REQUIRED', `npc_bindings.${index}.team`);
    if (npc.persona || npc.stats || npc.techniques || npc.media) add('MF_NPC_SECOND_SHEET', `npc_bindings.${index}`);
  }
  for (const [index, phase] of phases.entries()) {
    const actors = Array.isArray(phase.actor_keys) ? phase.actor_keys : [];
    const bound = npcs.filter(x => Array.isArray(x.phase_keys) && x.phase_keys.includes(phase.step_key)).map(x => x.actor_key);
    if (!Array.isArray(phase.actor_keys) || duplicate(actors) || actors.length !== bound.length ||
        actors.some(key => !bound.includes(key))) add('MF_PHASE_ACTOR_BINDING', `phases.${index}.actor_keys`);
  }
  const maps = Array.isArray(document.maps) ? document.maps : [];
  for (const [index, map] of maps.entries()) {
    if (!phaseKeys.has(map.step_key)) add('MF_MAP_PHASE', `maps.${index}`);
    if (map.combat_map && (typeof map.combat_map.template_key !== 'string' || !map.combat_map.template_key.trim() || !Number.isInteger(map.combat_map.template_version) || map.combat_map.template_version < 1 || typeof map.combat_map.zone_key !== 'string' || !map.combat_map.zone_key.trim())) add('MF_ARENA_REFERENCE', `maps.${index}`);
  }
  for (const phase of phases.filter(x => x.kind === 'combat')) {
    if (!maps.some(x => x.step_key === phase.step_key && x.combat_map)) add('MF_ARENA_REQUIRED', `phases.${phase.step_key}`);
    for (const key of phase.actor_keys || []) if (!npcs.some(x => x.actor_key === key && x.combat === true)) add('MF_COMBAT_ACTOR', `phases.${phase.step_key}.actor_keys`);
  }
  if (!document.budget_policy_id || !catalog.budget_policies?.some(x => x.id === document.budget_policy_id)) add('MF_BUDGET_POLICY', 'budget_policy_id');
  const variants = document.variants || {};
  if (forPublish) for (const mode of MODES) {
    const variant = variants[mode];
    if (!isVariantComplete(variant, mode)) add('MF_DUAL_VARIANT_DRAFT_REQUIRED', `variants.${mode}`);
  }
  return errors;
}

export function createEmptyDocument(catalogVersion) {
  return {schema_version:EDITOR_SCHEMA, catalog_version:catalogVersion, mission:{title:'', plot_private:'', briefing:'', gathering_location_id:null, team_min:1, team_max:1}, phases:[], npc_bindings:[], maps:[], budget_policy_id:null, variants:{ai:{state:'missing'}, human:{state:'missing'}}};
}
export function localErrors(document, catalog, {forPublish = false} = {}) {
  assertShape(catalog, CATALOG_SCHEMA, 'MF_CATALOG_SHAPE');
  return checks(document, catalog, forPublish);
}
export function onlyEditorialProposal(proposal) {
  if (!isPlainObject(proposal)) fail('MF_PROPOSAL_SHAPE');
  const inspect = value => {
    if (Array.isArray(value)) return value.forEach(inspect);
    if (!isPlainObject(value)) return;
    for (const [key, nested] of Object.entries(value)) {
      if (FORBIDDEN_PROPOSAL_KEYS.has(key)) fail('MF_PROPOSAL_MECHANICS', key);
      inspect(nested);
    }
  };
  inspect(proposal);
  const allowed = ['title','plot_private','briefing','phase_hints','npc_hints','map_notes'];
  if (Object.keys(proposal).some(key => !allowed.includes(key))) fail('MF_PROPOSAL_UNKNOWN_FIELD');
  return clone(proposal);
}

export class MissionFactoryEditor {
  constructor(api, uuid = () => crypto.randomUUID()) {
    if (!api || typeof api !== 'object') fail('MF_API_REQUIRED');
    this.disposed=false;this.lifecycle=()=>true;this.checkpoint=()=>{};const instance=this;
    this.api=new Proxy(api,{get(target,key){const value=target[key];return typeof value==='function'?(...args)=>{instance.assertActive();return value.apply(target,args);}:value;}}); this.uuid = uuid; this.catalog = null; this.draftId = null;
    this.controlVersion = null; this.document = null; this.preview = null;
    this.pendingCreate = null; this.pendingSave = null; this.pendingNpc = null;
    this.pendingCompile = null; this.pendingPublish = null; this.receipt = null;
    this.publishedRequest = null; this.delivery = null;
    this.authoringChecks = new Map(); this.authoringEpoch = 0; this.authoringRequestSeq = 0; this.savedDocument = false;
  }
  setLifecycle(isCurrent,persist){this.lifecycle=isCurrent;this.checkpoint=persist;}
  assertActive(){if(this.disposed||!this.lifecycle())throw Error('Editor chiuso o accesso cambiato.');}
  dispose(){this.invalidateSchedule();this.disposed=true;this.authoringEpoch++;}
  recoverySnapshot() {
    return {schema_version:'mission-factory-recovery/1',draft_id:this.draftId,
      pending_create:this.pendingCreate?.key || null,pending_save:this.pendingSave?.key || null,
      pending_compile:this.pendingCompile || null,pending_npc:this.pendingNpc?.key || null,
      pending_publish:this.pendingPublish?.key || null,published_request:this.publishedRequest,
      pending_payloads:{pendingCreate:clone(this.pendingCreate),pendingSave:clone(this.pendingSave),pendingCompile:clone(this.pendingCompile),pendingNpc:clone(this.pendingNpc),pendingPublish:clone(this.pendingPublish)}};
  }
  restoreRecovery(snapshot) {this.invalidateSchedule();
    if (!snapshot || snapshot.schema_version !== 'mission-factory-recovery/1') fail('MF_RECOVERY_SHAPE');
    const key = value => value == null ? null : ensureUuid(value,'MF_RECOVERY_KEY');
    this.draftId = key(snapshot.draft_id);
    this.pendingCreate = key(snapshot.pending_create) ? {key:snapshot.pending_create,source:null,catalogVersion:null} : null;
    this.pendingSave = key(snapshot.pending_save) ? {key:snapshot.pending_save,expectedVersion:null,document:null} : null;
    this.pendingCompile = key(snapshot.pending_compile);
    this.pendingNpc = key(snapshot.pending_npc) ? {key:snapshot.pending_npc,proposal:null} : null;
    this.pendingPublish = key(snapshot.pending_publish) ? {key:snapshot.pending_publish,payload:null} : null;
    this.publishedRequest = key(snapshot.published_request);
    if(snapshot.pending_payloads){for(const property of ['pendingCreate', 'pendingSave', 'pendingCompile', 'pendingNpc', 'pendingPublish']){const original=this[property],saved=snapshot.pending_payloads[property];const a=typeof original==='string'?original:original?.key,b=typeof saved==='string'?saved:saved?.key;if((a||null)!==(b||null))throw Error('Journal recovery incoerente.');this[property]=clone(saved);}}
  }
  async recoverPending() {
    if (typeof this.api.requestState !== 'function') fail('MF_REQUEST_READBACK_UNAVAILABLE');
    const pending = [
      ['pendingCreate','create'],['pendingSave','save'],['pendingCompile','compile'],
      ['pendingNpc','npc_stage'],['pendingPublish','publish']
    ];
    const states = [];
    for (const [property,operation] of pending) {
      const value = this[property], request = typeof value === 'string' ? value : value?.key;
      if (!request) continue;
      const result = operation === 'publish'
        ? await this.api.publishState({request_key:request})
        : await this.api.requestState({request_key:request});
      const expectedSchema = operation === 'publish' ? 'mission-factory-publish-state/1' : 'mission-factory-request-state/1';
      if (result?.schema_version !== expectedSchema || result.request_key !== request || !['unknown','confirmed'].includes(result.state)) fail('MF_REQUEST_READBACK_SHAPE');
      states.push({operation,state:result.state});
      if (result.state !== 'confirmed') continue;
      if (operation !== 'publish' && result.operation !== operation) fail('MF_REQUEST_READBACK_OPERATION');
      if (operation === 'create') this.draftId = ensureUuid(result.result?.draft_id,'MF_DRAFT_RECEIPT');
      if (operation === 'publish') { this.receipt = clone(publishReceipt(result.result, request));
        this.publishedRequest = request; this.delivery = clone(deliveryState(result.delivery)); }
      this[property] = null;
    }
    if (this.draftId && !this.pendingCreate && !this.pendingSave && !this.pendingCompile && !this.pendingNpc && !this.pendingPublish) await this.open(this.draftId);
    if (this.publishedRequest && !this.receipt) {
      const r = await this.api.publishState({request_key:this.publishedRequest});
      if (r?.schema_version !== 'mission-factory-publish-state/1' || r.request_key !== this.publishedRequest || !['unknown','confirmed'].includes(r.state)) fail('MF_PUBLISH_STATE');
      states.push({operation:'publish_delivery',state:r.state});
      if (r.state === 'confirmed') { this.receipt = clone(publishReceipt(r.result,this.publishedRequest)); this.delivery = clone(deliveryState(r.delivery)); }
    }
    return states;
  }
  async loadCatalog() {this.invalidateSchedule();
    this.catalog = assertShape(await this.api.catalog(), CATALOG_SCHEMA, 'MF_CATALOG_SHAPE');
    if (!Array.isArray(this.catalog.capabilities) || !Array.isArray(this.catalog.budget_policies)) fail('MF_CATALOG_INCOMPLETE');
    return clone(this.catalog);
  }
  async create(source = {}) {this.invalidateSchedule();
    if (!this.catalog) await this.loadCatalog();
    this.assertActive();
    const clean = onlyEditorialProposal(source);
    if (this.pendingCreate && this.pendingCreate.source === null) fail('MF_RECOVERY_READBACK_REQUIRED');
    if (this.pendingCreate && JSON.stringify(clean) !== JSON.stringify(this.pendingCreate.source)) fail('MF_CREATE_REQUEST_PENDING');
    this.pendingCreate ||= {key:this.uuid(),source:clean,catalogVersion:this.catalog.version};
    const request = this.pendingCreate;
    this.assertActive();this.checkpoint(this.recoverySnapshot());
    const result = await this.api.createDraft({request_key:request.key, source:clone(request.source), catalog_version:request.catalogVersion});
    ensureUuid(result?.draft_id, 'MF_DRAFT_RECEIPT');
    if (result.request_key !== request.key) fail('MF_DRAFT_REQUEST_MISMATCH');
    this.pendingCreate = null;
    this.draftId = result.draft_id; this.controlVersion = result.control_version;
    this.document = result.document || createEmptyDocument(this.catalog.version);
    this.authoringChecks.clear(); this.authoringEpoch++; this.savedDocument = true;
    this.preview = null; return clone(this.document);
  }
  async open(draftId) {this.invalidateSchedule();
    ensureUuid(draftId, 'MF_DRAFT_ID');
    const result = await this.api.openDraft({draft_id:draftId});
    if (result?.draft_id !== draftId || !Number.isInteger(result.control_version)) fail('MF_DRAFT_STATE');
    this.draftId = draftId; this.controlVersion = result.control_version;
    this.document = clone(result.document); this.preview = null;
    this.authoringChecks.clear(); this.authoringEpoch++; this.savedDocument = true;
    this.pendingCompile = result.pending_compile_request || null;
    this.pendingPublish = result.pending_publish_request ? {key:result.pending_publish_request,payload:null} : null;
    if (result.state === 'published' && result.publish_request) this.publishedRequest = ensureUuid(result.publish_request,'MF_PUBLISH_REQUEST');
    return clone(this.document);
  }
  edit(mutator) {this.invalidateSchedule();
    this.assertActive();
    if (!this.document) fail('MF_DRAFT_NOT_LOADED');
    if (this.pendingSave || this.pendingCompile || this.pendingNpc || this.pendingPublish) fail('MF_REQUEST_UNCERTAIN');
    const next = clone(this.document); mutator(next);
    this.document = next; this.preview = null; this.receipt = null; this.delivery = null;
    this.authoringChecks.clear(); this.authoringEpoch++; this.savedDocument = false;
    return clone(next);
  }
  async compile() {
    if (!this.draftId) fail('MF_DRAFT_NOT_LOADED');
    this.pendingCompile ||= this.uuid();
    const request = this.pendingCompile;
    this.assertActive();this.checkpoint(this.recoverySnapshot());
    const result = await this.api.compile({draft_id:this.draftId, request_key:request});
    if (result?.request_key !== request) fail('MF_COMPILE_RECEIPT');
    if (result.state === 'complete') { this.pendingCompile = null; await this.open(this.draftId); }
    return clone(result);
  }
  async resumeCompile() {
    if (!this.pendingCompile) fail('MF_COMPILE_NOT_PENDING');
    const result = await this.api.compileState({request_key:this.pendingCompile});
    if (result?.state === 'complete') { this.pendingCompile = null; await this.open(this.draftId); }
    return clone(result);
  }
  async stageNpc(proposal) {
    if (!this.draftId) fail('MF_DRAFT_NOT_LOADED');
    // api.stageNpc è un endpoint Staff trusted; mai una porta Builder service-only.
    if (!isPlainObject(proposal) || Object.keys(proposal).some(key => !['name','history','voice','public_knowledge','private_knowledge','kind','portrait_media_id','marker_media_id','mechanical_request'].includes(key))) fail('MF_NPC_PROPOSAL_SHAPE');
    const inspect = value => {
      if (Array.isArray(value)) return value.forEach(inspect);
      if (!isPlainObject(value)) return;
      for (const [key, nested] of Object.entries(value)) {
        if (FORBIDDEN_PROPOSAL_KEYS.has(key)) fail('MF_NPC_MECHANICS_FROM_CLIENT', key);
        inspect(nested);
      }
    };
    inspect(proposal);
    if (this.pendingNpc && this.pendingNpc.proposal === null) fail('MF_RECOVERY_READBACK_REQUIRED');
    if (this.pendingNpc && JSON.stringify(proposal) !== JSON.stringify(this.pendingNpc.proposal)) fail('MF_NPC_REQUEST_PENDING');
    this.pendingNpc ||= {key:this.uuid(),proposal:clone(proposal)};
    this.assertActive();this.checkpoint(this.recoverySnapshot());
    const result = await this.api.stageNpc({draft_id:this.draftId, request_key:this.pendingNpc.key, proposal:clone(this.pendingNpc.proposal)});
    if (result.request_key !== this.pendingNpc.key) fail('MF_NPC_RECEIPT');
    this.pendingNpc = null; return clone(result);
  }
  async bindNpc({actor_key, npc_id, npc_version_id, phase_keys, combat = false, team, staff_authoring_candidate = false}) {
    if (!['alleati','avversari','civili'].includes(team)) fail('MF_NPC_TEAM_REQUIRED');
    ensureUuid(npc_id, 'MF_NPC_ID'); ensureUuid(npc_version_id, 'MF_NPC_VERSION');
    const bindEpoch = this.authoringEpoch;
    const certified = await this.api.npcVersion({npc_id, npc_version_id, scope:combat && !staff_authoring_candidate ? 'combat' : 'narrative'});
    if (bindEpoch !== this.authoringEpoch) fail('MF_NPC_BINDING_STALE');
    if (certified?.certified !== true || certified?.active !== true ||
        combat && !staff_authoring_candidate && certified.combat !== true) fail('MF_NPC_NOT_CERTIFIED');
    this.edit(doc => {
      doc.npc_bindings = (doc.npc_bindings || []).filter(x => x.actor_key !== actor_key);
      doc.npc_bindings.push({actor_key,npc_id,npc_version_id,phase_keys,combat,team});
      for (const phase of doc.phases || []) phase.actor_keys = doc.npc_bindings
        .filter(x => x.phase_keys?.includes(phase.step_key)).map(x => x.actor_key);
    });
    return clone(this.document);
  }
  async save() {this.invalidateSchedule();
    if (!this.draftId || !this.document) fail('MF_DRAFT_NOT_LOADED');
    this.pendingSave ||= {key:this.uuid(),expectedVersion:this.controlVersion,document:clone(this.document)};
    const pending = this.pendingSave;
    if (pending.document === null) fail('MF_RECOVERY_READBACK_REQUIRED');
    this.assertActive();this.checkpoint(this.recoverySnapshot());
    const result = await this.api.save({draft_id:this.draftId, expected_version:pending.expectedVersion, document:clone(pending.document), request_key:pending.key});
    if (result?.draft_id !== this.draftId || !Number.isInteger(result.control_version) || result.request_key !== pending.key) fail('MF_SAVE_RECEIPT');
    this.pendingSave = null; this.controlVersion = result.control_version; this.preview = null;
    this.authoringChecks.clear(); this.authoringEpoch++; this.savedDocument = true;
    return clone(result);
  }
  async checkNpcAuthoring(actor_key) {
    if (!this.draftId || !this.savedDocument || this.pendingSave) fail('MF_NPC_AUTHORING_SAVE_REQUIRED');
    const binding = this.document?.npc_bindings?.find(x => x.actor_key === actor_key);
    if (!binding || binding.combat !== true) fail('MF_NPC_AUTHORING_BINDING_INVALID');
    const epoch = this.authoringEpoch, request = ++this.authoringRequestSeq, version = this.controlVersion, draft = this.draftId;
    const value = await this.api.npcAuthoringCheck({draft_id:draft,expected_version:version,actor_key});
    if (epoch !== this.authoringEpoch || request !== this.authoringRequestSeq || draft !== this.draftId || version !== this.controlVersion || !this.savedDocument) fail('MF_NPC_AUTHORING_DRAFT_STALE');
    if (value?.schema_version !== 'mission-factory-npc-authoring-check/1' || value.draft_id !== draft ||
        value.draft_control_version !== version || value.content_kind !== 'mission' ||
        value.actor_key !== actor_key || !SHA.test(value.draft_sha256 || '') ||
        !['selectable','blocked'].includes(value.status) ||
        value.staff_selectable !== (value.status === 'selectable') ||
        !Array.isArray(value.phase_keys) || !Array.isArray(value.errors) ||
        value.errors.some(x => typeof x.code !== 'string' || typeof x.path !== 'string' ||
          x.phase_key !== null && typeof x.phase_key !== 'string') ||
        (value.staff_release_sha256 !== null && !SHA.test(value.staff_release_sha256 || ''))) fail('MF_NPC_AUTHORING_SHAPE');
    if (value.status === 'selectable' && (value.npc_id !== binding.npc_id ||
        value.npc_version_id !== binding.npc_version_id || !SHA.test(value.bundle_sha256 || '') ||
        JSON.stringify([...value.phase_keys].sort()) !== JSON.stringify([...binding.phase_keys].sort()) ||
        value.reason_code !== null || value.errors.length)) fail('MF_NPC_AUTHORING_BINDING_STALE');
    if (value.status === 'blocked' && (typeof value.reason_code !== 'string' || !value.reason_code ||
        !value.errors.length || value.npc_id !== null && !UUID.test(value.npc_id || '') ||
        value.npc_version_id !== null && !UUID.test(value.npc_version_id || ''))) fail('MF_NPC_AUTHORING_SHAPE');
    if (value.bundle_sha256 !== null && !SHA.test(value.bundle_sha256 || '')) fail('MF_NPC_AUTHORING_BUNDLE_SHAPE');
    this.authoringChecks.set(actor_key, clone(value)); return clone(value);
  }
  async requestPreview() {
    this.invalidateSchedule();
    if (!this.draftId) fail('MF_DRAFT_NOT_LOADED');
    if (this.pendingSave || this.pendingCompile || this.pendingNpc || this.pendingPublish) fail('MF_REQUEST_UNCERTAIN');
    const result = assertShape(await this.api.preview({draft_id:this.draftId, expected_version:this.controlVersion}), PREVIEW_SCHEMA, 'MF_PREVIEW_SHAPE');
    if (result.draft_id !== this.draftId || result.draft_version !== this.controlVersion || !Array.isArray(result.errors)) fail('MF_PREVIEW_STALE');
    this.preview = result; return clone(result);
  }
  canPublish() {
    return Boolean(!this.receipt && this.preview && this.preview.errors.length === 0 && SHA.test(this.preview.preview_seal || '') && this.preview.draft_version === this.controlVersion && this.preview.dual_validated === true &&
      Array.isArray(this.document?.phases) && this.document.phases.length > 0 &&
      this.document.phases.every(phase => missionCapabilitiesForPhase(this.catalog, phase.kind).some(x => x.key === phase.capability_key)));
  }
  invalidateSchedule(){this.scheduleCapability=null;this.scheduleRequestSeq=(this.scheduleRequestSeq||0)+1;}
  scheduleKey(due){
    if(!this.canPublish() || !this.savedDocument || this.disposed || !this.lifecycle() ||
       this.pendingCreate || this.pendingSave || this.pendingCompile || this.pendingNpc ||
       this.pendingRoster || this.pendingVariant || this.pendingRewardPolicy || this.pendingPublish ||
       typeof due!=='string' || !Number.isFinite(Date.parse(due))) return null;
    return JSON.stringify([this.draftId,this.controlVersion,this.preview.preview_seal,
      new Date(due).toISOString(),this.authoringEpoch,this.document]);
  }
  canSchedule(due){const key=this.scheduleKey(due);return key!==null &&
    this.scheduleCapability?.key===key && this.scheduleCapability.value.allowed===true;}
  async checkSchedule(due){
    this.assertActive();this.invalidateSchedule();const seq=this.scheduleRequestSeq,key=this.scheduleKey(due);
    if(key===null)throw Error('Salva la bozza e verifica l’anteprima prima di programmare.');
    const value=await this.api.scheduleCapability({draft_id:this.draftId,expected_version:this.controlVersion,
      preview_seal:this.preview.preview_seal,due:new Date(due).toISOString()});
    this.assertActive();
    if(seq!==this.scheduleRequestSeq || key!==this.scheduleKey(due))throw Error('Programmazione cambiata: ripeti la verifica.');
    this.scheduleCapability={key,value:structuredClone(value)};return structuredClone(value);
  }
  async publish(visibility, scheduledAt = null) {
    if (!VISIBILITIES.has(visibility)) fail('MF_VISIBILITY');
    if (visibility === 'open' && this.catalog?.public_open_qualified !== true)
      fail('MF_PUBLIC_OPEN_NOT_QUALIFIED');
    if (!this.canPublish()) fail('MF_PREVIEW_REQUIRED');
    if (visibility === 'scheduled' && (!scheduledAt || Number.isNaN(Date.parse(scheduledAt)))) fail('MF_SCHEDULE_REQUIRED');
    if (this.pendingSave || this.pendingCompile || this.pendingNpc) fail('MF_REQUEST_UNCERTAIN');
    if(visibility==='scheduled'){
      if(!this.canSchedule(scheduledAt))throw Error('Verifica la programmazione per questa data.');
      const capability=await this.checkSchedule(scheduledAt);
      if(capability.allowed!==true || !this.canSchedule(scheduledAt))throw Error('Programmazione non autorizzata dal server.');
    }
    const payload = {draft_id:this.draftId, expected_version:this.controlVersion, preview_seal:this.preview.preview_seal, visibility, scheduled_at:scheduledAt};
    if (this.pendingPublish && JSON.stringify(this.pendingPublish.payload) !== JSON.stringify(payload)) fail('MF_PUBLISH_REQUEST_PENDING');
    this.pendingPublish ||= {key:this.uuid(),payload};
    const request = this.pendingPublish.key;
    this.assertActive();this.checkpoint(this.recoverySnapshot());
    const result = await this.api.publish({...clone(this.pendingPublish.payload),request_key:request});
    publishReceipt(result, request);
    this.receipt = clone(result); this.delivery = clone(deliveryState({state:result.state,mission_id:result.mission_id}));
    this.publishedRequest = request; this.pendingPublish = null;
    return clone(result);
  }
  async refreshDelivery() {
    if (!this.publishedRequest) fail('MF_PUBLISH_NOT_CONFIRMED');
    const result = await this.api.publishState({request_key:this.publishedRequest});
    if (result?.schema_version !== 'mission-factory-publish-state/1' || result.request_key !== this.publishedRequest || !['unknown','confirmed'].includes(result.state)) fail('MF_PUBLISH_STATE');
    if (result.state === 'confirmed') {
      const receipt = publishReceipt(result.result, this.publishedRequest);
      if (this.receipt && JSON.stringify(receipt) !== JSON.stringify(this.receipt)) fail('MF_PUBLISH_RECEIPT_DRIFT');
      this.receipt = clone(receipt); this.delivery = clone(deliveryState(result.delivery));
    }
    return clone(result);
  }
  async resumePublish() {
    if (!this.pendingPublish) fail('MF_PUBLISH_NOT_PENDING');
    const result = await this.api.publishState({request_key:this.pendingPublish.key});
    if (result?.schema_version !== 'mission-factory-publish-state/1' || result.request_key !== this.pendingPublish.key || !['unknown','confirmed'].includes(result.state)) fail('MF_PUBLISH_STATE');
    if (result.state === 'confirmed') { const key=this.pendingPublish.key; this.receipt = clone(publishReceipt(result.result, key));
      this.delivery = clone(deliveryState(result.delivery)); this.publishedRequest = key; this.pendingPublish = null; }
    return clone(result);
  }
}
