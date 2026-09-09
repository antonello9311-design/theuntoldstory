import {scenePrompts, inspectNarrative, EDGE_REVISION, VALIDATOR_REVISION} from './editorial.mjs';
import {canonical, digest} from './scene.mjs';

export const LIFECYCLE_VERSION = 'combat-narrative-lifecycle/1';
const uncertain = phase => ({state: 'uncertain', phase, provider_retry_allowed: false});
const known = new Set(['claimed', 'provider_reserved', 'generated', 'published', 'failed']);
function matches(record, request) {
  return record && record.schema_version === LIFECYCLE_VERSION
    && record.request_key === request.request_key && record.round_id === request.round_id
    && record.report_sha256 === request.report_sha256 && known.has(record.state);
}
// Adapter proposto: tutte le operazioni DB sono autenticate, bounded e atomiche.
// acquire non autorizza il provider; reserve concede un solo granted_now.
// persist è idempotente per chiave+hash; publish usa SOLO il risultato persistito.
export async function runSceneNarrative(request, d) {
  if (!request || Object.keys(request).length !== 3 || !['request_key', 'round_id', 'report_sha256'].every(k => typeof request[k] === 'string')
    || !/^[a-f0-9]{64}$/.test(request.report_sha256)) return {state: 'rejected', phase: 'ingress'};
  const observe = async () => {
    try { const r = await d.phase('status', signal => d.status(request, signal)); return matches(r, request) ? r : null; }
    catch (e) { if (e?.message === 'scene_contract_incompatible') return {incompatible: true}; return null; }
  };
  let record;
  try { record = await d.phase('claim', signal => d.acquire(request, signal)); }
  catch (e) { if (e?.message === 'scene_contract_incompatible') return {state: 'rejected', phase: 'contract'}; }
  if (!matches(record, request)) record = await observe();
  if (record?.incompatible) return {state: 'rejected', phase: 'contract'};
  if (!record) return uncertain('claim');
  if (record.state === 'published' || record.state === 'failed') return {state: record.state, completion: record.completion};
  if (record.state === 'provider_reserved') return uncertain('provider_authorization');
  async function publish() {
    try {
      const r = await d.phase('publish', signal => d.publish(request, signal));
      if (matches(r, request) && r.state === 'published') return {state: 'published', completion: r.completion};
    } catch { /* nessuna rigenerazione per una ricevuta persa */ }
    const r = await observe();
    return r?.state === 'published' ? {state: 'published', completion: r.completion, reconciled: true} : uncertain('publication');
  }
  if (record.state === 'generated') return publish();
  if (record.edge_revision !== EDGE_REVISION || record.validator_revision !== VALIDATOR_REVISION)
    return {state: 'rejected', phase: 'version'};
  let prompts;
  try {
    prompts = await scenePrompts(record.scene, record.binding, d.limits);
    if (record.binding.round_id !== request.round_id || record.binding.report_sha256 !== request.report_sha256)
      throw new Error('request_binding_changed');
    // Misura il payload EFFETTIVO dell'adattatore, incluse istruzioni e busta API.
    await d.checkProviderBudget(prompts);
  } catch { return {state: 'rejected', phase: 'context_or_budget'}; }
  let permission;
  try {
    permission = await d.phase('reserve', signal => d.reserve(request, {
      snapshot_sha256: record.scene.snapshot_sha256, control_version: record.binding.control_version,
    }, signal));
  } catch { return uncertain('provider_authorization'); }
  if (!matches(permission, request) || permission.state !== 'provider_reserved' || permission.granted_now !== true)
    return uncertain('provider_authorization');
  let attempts = 0;
  const onAttempt = () => { if (attempts !== 0) throw new Error('second_provider_forbidden'); attempts = 1; };
  let result;
  try {
    const ai = await d.phase('provider', signal => d.generate(prompts, signal, onAttempt));
    const provenance = ai && ai.provider === 'openai' && ai.model === 'gpt-5.6-luna'
      && attempts === 1 && ai.http_attempts === 1 && typeof ai.response_id === 'string' && ai.response_id.length > 0
      && /^[a-f0-9]{64}$/.test(ai.request_sha256) && /^[a-f0-9]{64}$/.test(ai.raw_sha256)
      && Number.isSafeInteger(ai.input_tokens) && ai.input_tokens >= 0 && Number.isSafeInteger(ai.output_tokens) && ai.output_tokens > 0;
    const inspection = inspectNarrative(ai?.text, {providerComplete: ai?.complete === true, ...d.limits,
      mechanicalCodes: await d.mechanicalCodes(ai?.text, record.scene.snapshot)});
    result = {status: provenance && inspection.text ? 'succeeded' : 'failed', text: provenance ? inspection.text : null,
      failure_codes: [...inspection.codes, ...(!provenance ? ['provider_provenance_invalid'] : [])],
      advisories: inspection.advisories, http_attempts: attempts,
      provider: 'openai', model: 'gpt-5.6-luna', response_id: provenance ? ai.response_id : null,
      request_sha256: provenance ? ai.request_sha256 : null, raw_sha256: provenance ? ai.raw_sha256 : null,
      input_tokens: provenance ? ai.input_tokens : null, output_tokens: provenance ? ai.output_tokens : null};
  } catch { result = {status: 'failed', text: null, failure_codes: ['provider_or_validation_uncertain'], http_attempts: attempts}; }
  const succeeded = result.status === 'succeeded';
  const delivery = {schema_version: 'ordinary-narrative-result/2', status: result.status,
    report_sha256: request.report_sha256, context_sha256: record.scene.snapshot_sha256,
    control_version: record.binding.control_version, edge_revision: EDGE_REVISION, validator_revision: VALIDATOR_REVISION,
    text: succeeded ? result.text : null, text_sha256: succeeded ? await digest(result.text) : null,
    validation_passed: succeeded, provider: 'openai', model: 'gpt-5.6-luna',
    provider_response_id: result.response_id ?? null, provider_request_sha256: result.request_sha256 ?? null,
    raw_output_sha256: result.raw_sha256 ?? null, input_tokens: result.input_tokens ?? null, output_tokens: result.output_tokens ?? null,
    http_attempts: result.http_attempts, failure_code: succeeded ? null : 'provider_error'};
  const resultHash = await digest(canonical(delivery));
  let stored;
  try { stored = await d.phase('persist', signal => d.persist(request, delivery, resultHash, signal)); } catch { /* status soltanto */ }
  if (!matches(stored, request) || stored.result_sha256 !== resultHash) stored = await observe();
  if (!stored || stored.result_sha256 !== resultHash) return {...uncertain('delivery'), result_sha256: resultHash};
  // Usage/provenienza sono già durevoli nel risultato; errore audit secondario non elimina il Fato.
  if (d.audit) { try { await d.phase('audit', signal => d.audit(delivery, result, signal)); } catch { /* nessuna rigenerazione */ } }
  if (stored.state === 'failed') return {state: 'failed', completion: stored.completion};
  if (stored.state === 'published') return {state: 'published', completion: stored.completion};
  return stored.state === 'generated' ? publish() : uncertain('delivery');
}
