// Solo producer fidato/claim autenticato. Hash e flag non autorizzano input client.
export const SCENE_VERSION = 'combat-scene/1';
const object = x => x !== null && typeof x === 'object' && !Array.isArray(x);
const exact = (x, keys) => object(x) && Object.keys(x).length === keys.length && keys.every(k => Object.hasOwn(x, k));
const text = x => typeof x === 'string' && x.trim().length > 0;
const sha = x => typeof x === 'string' && /^[a-f0-9]{64}$/.test(x);
export const canonical = x => {
  if (x === null || typeof x === 'string' || typeof x === 'boolean') return JSON.stringify(x);
  if (typeof x === 'number' && Number.isSafeInteger(x)) return JSON.stringify(x);
  if (Array.isArray(x)) return '[' + x.map(canonical).join(',') + ']';
  if (object(x)) return '{' + Object.keys(x).sort().map(k => JSON.stringify(k) + ':' + canonical(x[k])).join(',') + '}';
  throw new Error('scene_noncanonical_value');
};
export async function digest(text) {
  return Array.from(new Uint8Array(await crypto.subtle.digest('SHA-256', new TextEncoder().encode(text))))
    .map(x => x.toString(16).padStart(2, '0')).join('');
}
const bytes = x => new TextEncoder().encode(canonical(x)).length;
function checkHeader(h) {
  if (!exact(h, ['session_id', 'round_id', 'report_sha256', 'control_version', 'location', 'actors', 'actions', 'resolved_facts'])
    || !text(h.session_id) || !text(h.round_id) || !sha(h.report_sha256)
    || !Number.isSafeInteger(h.control_version) || h.control_version < 1 || !text(h.location)
    || !text(h.resolved_facts) || !Array.isArray(h.actors) || !h.actors.length || !Array.isArray(h.actions) || !h.actions.length)
    throw new Error('scene_header_invalid');
  const ids = new Set();
  for (const a of h.actors) {
    if (!exact(a, ['id', 'name', 'kind', 'persona', 'may_speak']) || !text(a.id) || !text(a.name)
      || !['PG', 'PNG'].includes(a.kind) || typeof a.may_speak !== 'boolean'
      || !(a.persona === null || text(a.persona)) || ids.has(a.id)
      || (a.may_speak && (a.kind !== 'PNG' || !text(a.persona)))) throw new Error('scene_actor_invalid');
    ids.add(a.id);
  }
  const sources = new Set();
  for (const a of h.actions) {
    if (!exact(a, ['actor_id', 'role', 'source_id']) || !ids.has(a.actor_id)
      || !['azione', 'difesa'].includes(a.role) || !text(a.source_id) || sources.has(a.source_id))
      throw new Error('scene_action_invalid');
    sources.add(a.source_id);
  }
}
async function checkSource(s, h) {
  if (!exact(s, ['id', 'session_id', 'round_id', 'kind', 'actor_id', 'sequence', 'body', 'sha256', 'visibility', 'complete'])
    || !text(s.id) || s.session_id !== h.session_id || !text(s.round_id)
    || !['role', 'fato', 'setting', 'perception'].includes(s.kind) || !Number.isSafeInteger(s.sequence) || s.sequence < 0
    || !text(s.body) || !sha(s.sha256) || s.complete !== true
    || (s.kind === 'perception' ? s.visibility !== 'narratable_perception' : s.visibility !== 'public')
    || (['role', 'perception'].includes(s.kind) ? !h.actors.some(a => a.id === s.actor_id) : s.actor_id !== null)
    || await digest(s.body) !== s.sha256) throw new Error('scene_source_invalid');
}
export async function buildScene(header, rows, {maxInputBytes}) {
  checkHeader(header);
  if (!Number.isSafeInteger(maxInputBytes) || maxInputBytes <= 0 || !Array.isArray(rows)) throw new Error('scene_budget_invalid');
  const ids = new Set();
  for (const row of rows) {
    await checkSource(row, header);
    if (ids.has(row.id)) throw new Error('scene_source_duplicate');
    ids.add(row.id);
  }
  const required = header.actions.map(a => {
    const s = rows.find(s => s.id === a.source_id);
    if (!s || s.kind !== 'role' || s.actor_id !== a.actor_id || s.round_id !== header.round_id)
      throw new Error('scene_current_role_missing');
    return s;
  });
  // Il producer seleziona le fonti pubbliche pertinenti. Non si importa la chat intera.
  // I setting espliciti sono necessari; il passato è selezionato per unità complete.
  const settings = rows.filter(s => s.kind === 'setting' || s.kind === 'perception');
  const previous = rows.filter(s => s.kind === 'fato' && s.round_id !== header.round_id)
    .sort((a, b) => b.sequence - a.sequence || (a.id < b.id ? -1 : a.id > b.id ? 1 : 0));
  if (rows.some(s => s.kind === 'role' && !required.some(r => r.id === s.id))
    || rows.some(s => s.kind === 'fato' && s.round_id === header.round_id)) throw new Error('scene_unrelated_source');
  const snapshot = {schema_version: SCENE_VERSION, ...structuredClone(header), sources: structuredClone([...settings, ...required]),
    selection: {max_input_bytes: maxInputBytes, previous_available: previous.length, previous_included: 0}};
  if (bytes(snapshot) > maxInputBytes) throw new Error('scene_required_context_overflow');
  for (const s of previous) {
    const next = structuredClone(snapshot);
    next.sources.push(s); next.selection.previous_included++;
    if (bytes(next) <= maxInputBytes) { snapshot.sources = next.sources; snapshot.selection = next.selection; }
  }
  return {snapshot, snapshot_sha256: await digest(canonical(snapshot))};
}
export async function verifyScene(envelope, binding) {
  if (!exact(envelope, ['snapshot', 'snapshot_sha256']) || !sha(envelope.snapshot_sha256)) throw new Error('scene_envelope_invalid');
  const s = envelope.snapshot;
  if (!exact(s, ['schema_version', 'session_id', 'round_id', 'report_sha256', 'control_version', 'location', 'actors', 'actions', 'resolved_facts', 'sources', 'selection'])
    || s.schema_version !== SCENE_VERSION || !exact(s.selection, ['max_input_bytes', 'previous_available', 'previous_included']))
    throw new Error('scene_version_invalid');
  const {schema_version, sources, selection, ...header} = s;
  for (const k of ['session_id', 'round_id', 'report_sha256', 'control_version'])
    if (header[k] !== binding[k]) throw new Error('scene_binding_changed');
  if (binding.hash_authority === 'combat_v2_sha256/jsonb') {
    // Solo envelope della RPC autenticata. L'hash DB è opaco, non è JSON.stringify.
    if (binding.scene_sha256 !== envelope.snapshot_sha256) throw new Error('scene_hash_changed');
  } else if (await digest(canonical(s)) !== envelope.snapshot_sha256) throw new Error('scene_hash_changed');
  const rebuilt = await buildScene(header, sources, {maxInputBytes: selection.max_input_bytes});
  if (!Number.isSafeInteger(selection.previous_available) || selection.previous_available < selection.previous_included
    || selection.previous_included !== sources.filter(s => s.kind === 'fato').length
    || canonical(rebuilt.snapshot.sources) !== canonical(sources)) throw new Error('scene_selection_invalid');
  return structuredClone(s);
}
