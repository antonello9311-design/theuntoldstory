// Adapter candidato del gateway PNG. Nessuna porta è installata o montata nell'Admin.
const UUID = /^[0-9a-f]{8}-[0-9a-f]{4}-[1-8][0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}$/i;
const SHA = /^[0-9a-f]{64}$/i;
const STATS = ['taijutsu','ninjutsu','genjutsu','forza','velocita','mente','resistenza','fuuinjutsu'];
const INT4_MAX = 2147483647;
const STATES = new Set(['absent','draft','review','approved','inactive']);
const REJECTED_WITHOUT_EFFECT = new Set([
  'NPC_MECH_STALE','NPC_MECH_REQUEST_MISMATCH','NPC_MECH_CATALOG_STALE',
  'NPC_MECH_REF_ILLEGAL','NPC_MECH_VALUE_UNREPRESENTABLE','NPC_MECH_REVIEW_REQUIRED',
  'NPC_MECH_AUTH'
]);
const CODES = Object.freeze({
  catalog:'NPC_MECH_CATALOG_INVALID',state:'NPC_MECH_STATE_INVALID',
  identity:'NPC_MECH_NARRATIVE_CHANGED',pending:'NPC_MECH_REQUEST_PENDING',
  receipt:'NPC_MECH_RECEIPT_INVALID',payload:'NPC_MECH_PAYLOAD_INVALID'
});
const fail = code => { throw Object.assign(new Error(code),{code}); };
const clone = value => structuredClone(value);
const isInt4 = value => Number.isInteger(value) && value >= 0 && value <= INT4_MAX;
const isRef = ref => ref && ['jutsu','clan_techniques'].includes(ref.source) && UUID.test(ref.id || '');

function identityOf(getIdentity) {
  const value = getIdentity?.();
  if (!value || !UUID.test(value.template_id || '') || !UUID.test(value.narrative_version_id || '')) fail(CODES.identity);
  return {template_id:value.template_id,narrative_version_id:value.narrative_version_id};
}
function sameIdentity(a,b) { return a?.template_id === b?.template_id && a?.narrative_version_id === b?.narrative_version_id; }
function validCatalog(value) {
  if (value?.schema_version !== 'npc-combat-catalog/1' || !SHA.test(value.catalog_digest || '') ||
      !['techniques','abilities','clans','elements'].every(key => Array.isArray(value[key]))) fail(CODES.catalog);
  return value;
}
function validState(value,identity) {
  if (value?.schema_version !== 'npc-combat-state/1' || !sameIdentity(value,identity) ||
      !Number.isSafeInteger(value.control_version) || value.control_version < 0 ||
      !STATES.has(value.review_state) || typeof value.combat !== 'boolean' ||
      value.mechanical_template_id != null && !UUID.test(value.mechanical_template_id) ||
      value.mechanical_version_id != null && !UUID.test(value.mechanical_version_id)) fail(CODES.state);
  if (value.review_state === 'absent' && (value.control_version !== 0 || value.mechanical_version_id !== null)) fail(CODES.state);
  if (value.combat && (!value.stats || STATS.some(key => !isInt4(value.stats[key])) ||
      !isInt4(value.vita_max) || value.vita_max === 0 || !isInt4(value.chakra_max))) fail(CODES.state);
  if (!value.combat && value.mechanical_template_id !== null) fail(CODES.state);
  return value;
}
function validSnapshot(value,catalog) {
  if (value?.combat === false && Object.keys(value).length === 1) return value;
  const required = ['combat','stats','vita_max','chakra_max','technique_refs','ability_refs','clan_ref','chakra_element_ref','catalog_digest'];
  if (value?.combat !== true || !catalog || Object.keys(value).length !== required.length ||
      required.some(key => !Object.hasOwn(value,key)) || value.catalog_digest !== catalog.catalog_digest ||
      !value.stats || Object.keys(value.stats).length !== STATS.length ||
      STATS.some(key => !isInt4(value.stats[key])) || !isInt4(value.vita_max) || value.vita_max === 0 ||
      !isInt4(value.chakra_max) || !Array.isArray(value.technique_refs) || !Array.isArray(value.ability_refs) ||
      [...value.technique_refs,...value.ability_refs].some(ref => !isRef(ref)) ||
      value.clan_ref !== null && typeof value.clan_ref !== 'string' ||
      value.chakra_element_ref !== null && typeof value.chakra_element_ref !== 'string') fail(CODES.payload);
  return value;
}
function validReceipt(value,request,identity,operation) {
  const receipt=value?.receipt;
  if (!receipt || receipt.request_key !== request || !sameIdentity(receipt,identity) ||
      typeof receipt.replayed !== 'boolean' || !Number.isSafeInteger(receipt.control_version) ||
      receipt.control_version !== value.control_version || !SHA.test(receipt.payload_sha256 || '')) fail(CODES.receipt);
  if (operation === 'save' && value.combat && !UUID.test(receipt.mechanical_template_id || '')) fail(CODES.receipt);
  if (operation === 'save' && !value.combat && receipt.mechanical_template_id !== null) fail(CODES.receipt);
  if (receipt.mechanical_template_id !== value.mechanical_template_id) fail(CODES.receipt);
  return value;
}

export function createNpcCombatAdapter({client,getIdentity,assertNarrativeSynced} = {}) {
  if (typeof client?.rpc !== 'function' || typeof getIdentity !== 'function') throw Error('Gateway PNG non configurato.');
  let identity=null, catalog=null, state=null, pending=null;
  const currentIdentity = () => {
    const next=identityOf(getIdentity);
    if (identity && !sameIdentity(identity,next)) {
      identity=next;catalog=state=pending=null;fail(CODES.identity);
    }
    return next;
  };
  const rpc = async (name,args) => {
    const result=await client.rpc(name,args);
    if (result?.error) throw result.error;
    return result?.data;
  };
  const load = async () => {
    const expected=currentIdentity();
    const [newCatalog,newState]=await Promise.all([
      rpc('npc_combat_catalog_v1',{p_template:expected.template_id}),
      rpc('npc_combat_read_v1',{p_template:expected.template_id})
    ]);
    if (!sameIdentity(expected,identityOf(getIdentity))) fail(CODES.identity);
    catalog=clone(validCatalog(newCatalog));state=clone(validState(newState,expected));identity=expected;
    if (pending && state.receipt?.request_key === pending.request_key) pending=null;
    return {choices:clone(catalog),initial:clone(state),pending:pending !== null};
  };
  const perform = async (operation,payload=null) => {
    const expected=currentIdentity();
    if (!state || !sameIdentity(state,expected)) fail(CODES.state);
    if (operation === 'save') validSnapshot(payload,catalog);
    if (operation !== 'save') {
      if (typeof assertNarrativeSynced !== 'function' || await assertNarrativeSynced(clone(state)) !== true) fail('NPC_MECH_NARRATIVE_UNSYNCED');
      if (operation === 'approve' && state.review_state !== 'review') fail(CODES.state);
      if (operation === 'submit' && state.review_state !== 'draft') fail(CODES.state);
    } else if (!['absent','draft'].includes(state.review_state)) fail(CODES.state);
    const serialized=JSON.stringify(payload);
    if (pending && (pending.operation !== operation || pending.serialized !== serialized ||
                    !sameIdentity(pending,expected))) fail(CODES.pending);
    pending ||= {operation,serialized,request_key:crypto.randomUUID(),identity:clone(expected),
                 control_version:state.control_version,payload:clone(payload)};
    const names={save:'npc_combat_save_v1',submit:'npc_combat_submit_review_v1',approve:'npc_combat_approve_v1'};
    const args={p_template:expected.template_id,p_narrative_version:expected.narrative_version_id,
      p_expected_control_version:pending.control_version,p_request_key:pending.request_key};
    if (operation === 'save') args.p_payload=clone(pending.payload);
    let result;
    try { result=await rpc(names[operation],args); }
    catch (error) {
      const code=String(error?.code || error?.message || '').match(/NPC_MECH_[A-Z_]+/)?.[0];
      if (REJECTED_WITHOUT_EFFECT.has(code)) { pending=null;state=null; }
      // Una risposta di rete o un errore non classificato conserva UUID e payload.
      throw error;
    }
    if (!sameIdentity(expected,identityOf(getIdentity))) fail(CODES.identity);
    const verified=validReceipt(validState(result,expected),pending.request_key,expected,operation);
    state=clone(verified);pending=null;
    return clone(verified);
  };
  return {
    load,save:snapshot => perform('save',snapshot),submitReview:() => perform('submit'),approve:() => perform('approve'),
    snapshot:() => state ? clone(state) : null,
    pending:() => pending ? {operation:pending.operation,request_key:pending.request_key} : null
  };
}
