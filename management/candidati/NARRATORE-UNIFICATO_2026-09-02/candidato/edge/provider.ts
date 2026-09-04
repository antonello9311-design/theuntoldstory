// exam_genin_ai — il provider (OpenAI Responses API, gpt-5.6-luna, reasoning high,
// store:false). UNA chiamata per ciclo, nessun retry: un guasto qualunque
// finisce nel ripiego deterministico del database. La chiave sta solo
// nell'ambiente (`OPENAI_API_KEY`): mai nel codice, mai nel ritorno.

export type UscitaModello = {
  ok: boolean;
  text?: string;
  status?: number;
  detail?: string;
  stop_reason?: string | null;
  input_tokens?: number | null;
  output_tokens?: number | null;
  reasoning_tokens?: number | null;
  latency_ms: number;
  model: string;
};

export const OUTPUT_VERBOSITY: "medium" = "medium";

export function nomeChiave(): "OPENAI_API_KEY" { return "OPENAI_API_KEY"; }

export function ripulisciTesto(t: unknown): string {
  // Niente escape \uXXXX nel sorgente: il canale di deploy li decodifica in
  // caratteri grezzi. I codici di controllo si filtrano per valore.
  const senzaFormato = String(t ?? "").replace(/\p{Cf}/gu, "");
  let out = "";
  for (const ch of senzaFormato) {
    const k = ch.codePointAt(0) ?? 0;
    const controllo = (k < 32 && k !== 9 && k !== 10 && k !== 13) || (k >= 127 && k <= 159);
    if (!controllo) out += ch;
  }
  return out.trim();
}

function testoDaResponses(d: unknown): string {
  const o = d as Record<string, unknown>;
  if (typeof o?.output_text === "string") return ripulisciTesto(o.output_text);
  const out = Array.isArray(o?.output) ? (o.output as unknown[]) : [];
  const pezzi: string[] = [];
  for (const item of out) {
    const it = item as Record<string, unknown>;
    if (it?.type !== "message") continue;
    const parti = Array.isArray(it?.content) ? (it.content as unknown[]) : [];
    for (const p of parti) {
      const pp = p as Record<string, unknown>;
      if (pp?.type === "output_text" && typeof pp?.text === "string") pezzi.push(pp.text);
    }
  }
  return ripulisciTesto(pezzi.join(""));
}

function stopDaResponses(d: unknown): string | null {
  const o = d as Record<string, unknown>;
  const status = String(o?.status ?? "");
  if (status === "incomplete") {
    const r = String((o?.incomplete_details as Record<string, unknown>)?.reason ?? "");
    if (r === "max_output_tokens") return "max_tokens";
    return r || "incomplete";
  }
  return status === "completed" ? "stop" : (status || null);
}

function spolpa(t: unknown): string {
  return String(t ?? "").replace(/sk-[A-Za-z0-9_-]{6,}/g, "sk-***").slice(0, 600);
}

export async function chiamaModello(r: {
  chiave: string; modello: string; effort: "low" | "high" | null;
  sistema: string; utente: string;
  maxTokens: number; timeoutMs: number;
}): Promise<UscitaModello> {
  const partito = Date.now();
  const corpo: Record<string, unknown> = {
    model: r.modello,
    instructions: r.sistema,
    input: r.utente,
    max_output_tokens: r.maxTokens,
    store: false,
    text: { verbosity: OUTPUT_VERBOSITY },
  };
  if (r.effort) corpo.reasoning = { effort: r.effort };
  const ctrl = new AbortController();
  const timer = setTimeout(() => ctrl.abort(), r.timeoutMs);
  try {
    const risp = await fetch("https://api.openai.com/v1/responses", {
      method: "POST",
      headers: { "content-type": "application/json", "authorization": `Bearer ${r.chiave}` },
      body: JSON.stringify(corpo),
      signal: ctrl.signal,
    });
    if (!risp.ok) {
      const t = await risp.text();
      return { ok: false, status: risp.status, detail: spolpa(t), latency_ms: Date.now() - partito, model: r.modello };
    }
    const d = await risp.json();
    if (String(d?.status ?? "") === "failed") {
      return { ok: false, status: 200, detail: spolpa(d?.error?.message ?? "risposta failed"), latency_ms: Date.now() - partito, model: r.modello };
    }
    return {
      ok: true,
      text: testoDaResponses(d),
      stop_reason: stopDaResponses(d),
      input_tokens: typeof d?.usage?.input_tokens === "number" ? d.usage.input_tokens : null,
      output_tokens: typeof d?.usage?.output_tokens === "number" ? d.usage.output_tokens : null,
      reasoning_tokens: typeof d?.usage?.output_tokens_details?.reasoning_tokens === "number"
        ? d.usage.output_tokens_details.reasoning_tokens : null,
      latency_ms: Date.now() - partito,
      model: typeof d?.model === "string" ? d.model : r.modello,
    };
  } catch (e) {
    return { ok: false, status: 0, detail: spolpa((e as Error)?.message ?? e), latency_ms: Date.now() - partito, model: r.modello };
  } finally {
    clearTimeout(timer);
  }
}
