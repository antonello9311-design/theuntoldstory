// Candidato OFFLINE: nessun ripiego legacy, una sola chiamata per claim.
import type { UscitaModello } from "./adattatore.ts";
import { OrdinaryBudget, OrdinaryTimeout } from "./transport.ts";
import { factsContext, FACTS_EDGE, FACTS_VALIDATOR } from './facts.ts';
import { rinunciaContext, RINUNCIA_EDGE, RINUNCIA_VALIDATOR } from "./rinuncia.ts";
import { diagnosticRecord, type TextInspection } from "./diagnostics.ts";

type Rpc = (name: string, args: Record<string, unknown>, signal: AbortSignal) => PromiseLike<{ data: any; error: unknown }>;
type Dependencies = {
  rpc: Rpc;
  prompts: (context: any) => { sys: string; usr: string };
  call: (sys: string, usr: string, signal: AbortSignal, onAttempt: () => void) => Promise<UscitaModello>;
  validate: (text: string, context: any) => TextInspection;
  audit: (ai: UscitaModello, reportId: string, signal: AbortSignal, diagnostics: Awaited<ReturnType<typeof diagnosticRecord>>) => Promise<void>;
  budget?: OrdinaryBudget;
};
const uuid = /^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$/i;
const sha = /^[a-f0-9]{64}$/;
const tokenCount = (n: unknown): n is number => Number.isSafeInteger(n) && (n as number) >= 0;
const digest = async (s: string) => Array.from(new Uint8Array(
  await crypto.subtle.digest("SHA-256", new TextEncoder().encode(s)),
)).map((n) => n.toString(16).padStart(2, "0")).join("");

export async function ordinary(body: any, d: Dependencies): Promise<{ status: number; data: Record<string, unknown> }> {
  const budget = d.budget ?? new OrdinaryBudget();
  const keys = ["ordinary_round_id", "report_sha256", "request_key"];
  if (!body || Object.keys(body).length !== keys.length || keys.some((k) => typeof body[k] !== "string")
    || !uuid.test(body.ordinary_round_id) || !uuid.test(body.request_key) || !sha.test(body.report_sha256)) {
    return { status: 400, data: { error: "ordinary_request_invalid" } };
  }
  async function status(claimId: string | null) {
    try {
      const r = await budget.run("status", signal => d.rpc("combat_consumer_narrative_status_v1", {
        p_round: body.ordinary_round_id, p_report_sha256: body.report_sha256,
        p_request_key: body.request_key, p_claim: claimId,
      }, signal));
      return r.error ? null : r.data;
    } catch { return null; }
  }
  let claimed;
  try {
    claimed = await budget.run("claim", signal => d.rpc("combat_consumer_narrative_claim_v1", {
      p_round: body.ordinary_round_id, p_report_sha256: body.report_sha256, p_request_key: body.request_key,
    }, signal), { reserveMs: 8000 });
  } catch { claimed = { data: null, error: "uncertain" }; }
  if (claimed.error || !claimed.data) {
    const observed = await status(null);
    return { status: 503, data: { error: "ordinary_claim_unavailable", state: observed?.state ?? "unknown" } };
  }
  const c = claimed.data;
  if (c.should_call_provider !== true) {
    return { status: 200, data: { skipped: true, state: c.state, completion: c.completion ?? null } };
  }
  // Il contesto viene soltanto dal claim autenticato. Una shape sconosciuta non autorizza HTTP.
  if (!uuid.test(c.claim_id) || !uuid.test(c.report_id) || c.round_id !== body.ordinary_round_id
    || c.report_sha256 !== body.report_sha256 || !sha.test(c.context_sha256)
    || !Number.isSafeInteger(c.control_version) || c.control_version < 1) {
    return { status: 503, data: { error: "ordinary_claim_contract_invalid" } };
  }
  const result: Record<string, any> = {
    schema_version: "ordinary-narrative-result/1", status: "failed",
    report_sha256: c.report_sha256, context_sha256: c.context_sha256, control_version: c.control_version,
    edge_revision: c.context?.genere === "rinuncia" ? RINUNCIA_EDGE : c.context?.genere === "azione_risolta" ? FACTS_EDGE : "ordinary-adapter/1",
    validator_revision: c.context?.genere === "rinuncia" ? RINUNCIA_VALIDATOR : c.context?.genere === "azione_risolta" ? FACTS_VALIDATOR : "combat-narratore-v18-existing/1",
    provider_response_id: null, provider_request_sha256: null, raw_output_sha256: null,
    text: null, text_sha256: null, validation_passed: false, provider: "openai", model: "gpt-5.6-luna",
    input_tokens: null, output_tokens: null, http_attempts: 0, failure_code: "configuration_mismatch",
  };
  const remaining = Date.parse(c.expires_at) - Date.now() - 8000;
  const allowed = c.edge_revision === result.edge_revision && c.validator_revision === result.validator_revision
    && c.provider === result.provider && c.model === result.model
    && c.context?.ordinary === true && (c.context?.genere === "confronto" || rinunciaContext(c.context) || factsContext(c.context))
    && c.context?.model === result.model && Number.isFinite(remaining) && remaining > 0;
  if (allowed) {
    try {
      const { sys, usr } = d.prompts(c.context);
      // Nessun ciclo o retry del provider: l'adattatore restituisce il contatore HTTP effettivo.
      const ai = await budget.run("model", signal => d.call(sys, usr, signal, () => {
        if (result.http_attempts !== 0) throw new Error("ordinary_second_attempt_forbidden");
        result.http_attempts = 1;
      }), { reserveMs: 8000, leaseRemainingMs: Date.parse(c.expires_at) - Date.now() });
      result.http_attempts = Math.max(result.http_attempts, ai.tentativi_http === 1 ? 1 : 0);
      result.input_tokens = tokenCount(ai.input_tokens) ? ai.input_tokens : null;
      result.output_tokens = tokenCount(ai.output_tokens) ? ai.output_tokens : null;
      result.provider_response_id = typeof ai.provider_response_id === "string"
        && ai.provider_response_id.length > 0 && ai.provider_response_id.length <= 200 ? ai.provider_response_id : null;
      result.provider_request_sha256 = sha.test(ai.provider_request_sha256 ?? "") ? ai.provider_request_sha256 : null;
      result.raw_output_sha256 = sha.test(ai.raw_output_sha256 ?? "") ? ai.raw_output_sha256 : null;
      result.failure_code = "provider_error";
      let inspection: TextInspection | null = null;
      let validationError: unknown;
      let validationThrew = false;
      if (ai.ok) {
        try { inspection = d.validate(ai.text ?? "", c.context); }
        catch (error) { validationThrew = true; validationError = error; }
      }
      const provenance = {
        response_id: Boolean(result.provider_response_id),
        request_sha: Boolean(result.provider_request_sha256),
        raw_sha: Boolean(result.raw_output_sha256),
        input_tokens: result.input_tokens !== null,
        output_tokens: result.output_tokens > 0,
        http_attempts: ai.tentativi_http === 1,
        provider: ai.provider === result.provider,
        model: ai.model === result.model,
      };
      const diagnostics = await diagnosticRecord(inspection, provenance,
        validationThrew ? "validator_exception" : ai.ok ? "evaluated" : "provider_not_ok", result.validator_revision);
      await budget.run("audit", signal => d.audit(ai, c.report_id, signal, diagnostics), { reserveMs: 5000 });
      if (validationThrew) throw validationError;
      if (ai.ok) {
        const text = inspection?.text ?? null;
        result.failure_code = "validation_rejected";
        if (text && result.provider_response_id && result.provider_request_sha256 && result.raw_output_sha256
          && result.input_tokens !== null && result.output_tokens > 0 && ai.tentativi_http === 1
          && ai.provider === result.provider && ai.model === result.model) {
          const textHash = await digest(text);
          result.status = "succeeded";
          result.text = text;
          result.text_sha256 = textHash;
          result.validation_passed = true;
          result.failure_code = null;
        }
      }
    } catch (error) {
      // Nessun testo/error detail/role restituito o pubblicato come ripiego.
      result.failure_code = error instanceof OrdinaryTimeout ? "timeout" : "configuration_mismatch";
    }
  } else if (Number.isFinite(remaining) && remaining <= 0) result.failure_code = "timeout";
  let completed;
  try {
    completed = await budget.run("complete", signal => d.rpc("combat_consumer_narrative_complete_v1", {
      p_claim: c.claim_id, p_result: result, p_request_key: body.request_key,
    }, signal), { reserveMs: 2000 });
  } catch { completed = { data: null, error: "uncertain" }; }
  // Esito incerto: non si riavvia il modello. Il DB mantiene il claim e rifiuta una seconda consegna.
  if (completed.error || !completed.data) {
    const observed = await status(c.claim_id);
    if (["completed", "failed"].includes(observed?.state) && observed?.completion) {
      return { status: 200, data: { claim_id: c.claim_id, completion: observed.completion, reconciled: true } };
    }
    return { status: 503, data: { error: "ordinary_completion_uncertain", claim_id: c.claim_id, state: observed?.state ?? "unknown" } };
  }
  return { status: 200, data: { claim_id: c.claim_id, completion: completed.data } };
}
