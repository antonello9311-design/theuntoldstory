import { runSceneNarrative } from './lifecycle.mjs';
import { canonical } from './scene.mjs';
import { EDGE_REVISION, VALIDATOR_REVISION } from './editorial.mjs';

const caps: Record<string, number> = {claim: 10000, status: 3000, reserve: 4000, provider: 45000,
  persist: 6000, publish: 6000, audit: 1000};
const reserves: Record<string, number> = {claim: 18000, status: 0, reserve: 14000, provider: 13000,
  persist: 6000, publish: 3000, audit: 6000};
export class SceneBudget {
  deadline: number;
  leaseDeadline = Infinity;
  constructor(remainingMs = 50000) { this.deadline = performance.now() + remainingMs; }
  async run(phase: string, fn: (signal: AbortSignal) => Promise<any>) {
    const started = performance.now();
    const reserve = reserves[phase] ?? 0;
    const leaseBound = ['reserve', 'provider', 'persist'].includes(phase) ? this.leaseDeadline : Infinity;
    const ms = Math.min(caps[phase] ?? 0, this.deadline - started - reserve, leaseBound - started - reserve);
    if (!Number.isFinite(ms) || ms <= 0) throw new Error('scene_budget_exhausted');
    const controller = new AbortController();
    let timer: ReturnType<typeof setTimeout> | undefined;
    const timeout = new Promise<never>((_, reject) => { timer = setTimeout(() => {controller.abort(); reject(new Error('scene_phase_timeout'));}, ms); });
    try {
      const result = await Promise.race([Promise.resolve().then(() => fn(controller.signal)), timeout]);
      if (typeof result?.server_now === 'string' && typeof result?.expires_at === 'string') {
        const ttl = Date.parse(result.expires_at) - Date.parse(result.server_now);
        if (!Number.isFinite(ttl)) throw new Error('scene_lease_invalid');
        // L'intero RTT è sottratto: nessuna assunzione di orologi client/server sincronizzati.
        this.leaseDeadline = started + ttl;
      }
      return result;
    } finally { if (timer !== undefined) clearTimeout(timer); }
  }
}

export async function sceneOrdinary(body: any, channel: any, options: any) {
  const request = {round_id: body?.ordinary_round_id, report_sha256: body?.report_sha256, request_key: body?.request_key};
  const uuid = /^[a-f0-9]{8}-[a-f0-9]{4}-[a-f0-9]{4}-[a-f0-9]{4}-[a-f0-9]{12}$/i;
  if (!body || Object.keys(body).length !== 3 || !uuid.test(request.round_id) || !uuid.test(request.request_key))
    return {status: 400, data: {error: 'scene_request_invalid'}};
  const budget = new SceneBudget(50000 - (Date.now() - options.startedAt));
  const params = {p_round: request.round_id, p_report_sha256: request.report_sha256, p_request_key: request.request_key};
  const rpc = async (name: string, extra: any, signal: AbortSignal) => {
    const r = await channel.rpc(name, {...params, ...extra}, signal);
    if (r.error || !r.data) throw new Error('scene_rpc_uncertain');
    return r.data;
  };
  const limits = {transportMaxChars: 5000, maxInputBytes: 49152, maxRequestBytes: 65536, maxOutputTokens: 9992};
  const checkedRecord = (r: any) => {
    if (!r.limits || Object.keys(r.limits).length !== Object.keys(limits).length
      || Object.entries(limits).some(([k,v]) => r.limits[k] !== v)
      || r.scene?.snapshot?.selection?.max_input_bytes !== limits.maxInputBytes)
      throw new Error('scene_contract_incompatible');
    return r;
  };
  let aiUsage: any;
  const result = await runSceneNarrative(request, {
    limits, phase: (p: string, fn: any) => budget.run(p, fn),
    acquire: async (_: any, signal: AbortSignal) => {
      return checkedRecord(await rpc('combat_consumer_scene_acquire_v2', {}, signal));
    },
    status: async (_: any, signal: AbortSignal) => checkedRecord(await rpc('combat_consumer_scene_status_v2', {}, signal)),
    reserve: (_: any, b: any, signal: AbortSignal) => rpc('combat_consumer_scene_permit_v2', {p_scene_sha256: b.snapshot_sha256, p_control_version: b.control_version}, signal),
    persist: (_: any, p: any, _hash: string, signal: AbortSignal) => rpc('combat_consumer_scene_save_v2', {p_result_text: canonical(p)}, signal),
    publish: (_: any, signal: AbortSignal) => rpc('combat_consumer_scene_complete_v2', {}, signal),
    checkProviderBudget: async (p: any) => options.measure(p, limits),
    generate: async (p: any, signal: AbortSignal, onAttempt: any) => {
      const ai = await options.generate(p, signal, onAttempt, limits); aiUsage = ai;
      return {provider: ai.provider, model: ai.model, http_attempts: ai.tentativi_http, response_id: ai.provider_response_id,
        request_sha256: ai.provider_request_sha256, raw_sha256: ai.raw_output_sha256,
        input_tokens: ai.input_tokens, output_tokens: ai.output_tokens, text: ai.text,
        complete: ai.ok === true && ai.stop_reason === 'end_turn' && ai.troncato !== true};
    },
    mechanicalCodes: (raw: string, snapshot: any) => options.mechanicalCodes(raw, JSON.parse(snapshot.resolved_facts)),
    audit: (delivery: any, diagnostics: any, signal: AbortSignal) => options.audit(aiUsage, delivery, diagnostics, signal),
  });
  return {status: result.state === 'published' || result.state === 'failed' ? 200 : 503,
    data: {...result, edge_revision: EDGE_REVISION, validator_revision: VALIDATOR_REVISION}};
}
