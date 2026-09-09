// Solo ordinary. Abort interrompe l'attesa/HTTP locale, non prova rollback remoto.
export class OrdinaryTimeout extends Error {
  constructor(readonly phase: string) { super("ordinary_transport_timeout"); }
}
export type OrdinaryPhase = "auth" | "claim" | "model" | "audit" | "complete" | "status";
const caps: Record<OrdinaryPhase, number> = {
  auth: 3000, claim: 3000, model: 45000, audit: 3000,
  complete: 3000, status: 2000, // 5s riserva consegna = 3s invio + 2s riconciliazione.
};
export class OrdinaryBudget {
  private readonly deadline: number;
  constructor(private readonly now: () => number = () => performance.now(), durationMs = 50000) {
    this.deadline = now() + durationMs;
  }
  remaining(): number { return Math.max(0, this.deadline - this.now()); }
  async run<T>(phase: OrdinaryPhase, fn: (signal: AbortSignal) => PromiseLike<T>,
    options: { reserveMs?: number; leaseRemainingMs?: number; capMs?: number } = {}): Promise<T> {
    const reserve = options.reserveMs ?? 0;
    const ms = Math.min(caps[phase], options.capMs ?? Infinity,
      this.remaining() - reserve, (options.leaseRemainingMs ?? Infinity) - reserve);
    if (!Number.isFinite(ms) || ms <= 0) throw new OrdinaryTimeout(phase);
    const controller = new AbortController();
    let timer: ReturnType<typeof setTimeout> | undefined;
    const timeout = new Promise<never>((_, reject) => {
      timer = setTimeout(() => {
        controller.abort();
        reject(new OrdinaryTimeout(phase));
      }, ms);
    });
    try {
      // Il segnale deve essere passato a fetch/abortSignal del builder dal chiamante.
      // race dà un bound anche se il peer risponde dopo l'abort: nessun retry qui.
      return await Promise.race([Promise.resolve().then(() => fn(controller.signal)), timeout]);
    } finally {
      if (timer !== undefined) clearTimeout(timer);
    }
  }
}

// Lettura abortibile: il marker sceglie il ramo, non autorizza la richiesta.
export async function ordinaryBody(req: Request, signal: AbortSignal): Promise<unknown> {
  if (!req.body) return null;
  const reader = req.body.getReader();
  const abort = () => { void reader.cancel().catch(() => {}); };
  signal.addEventListener("abort", abort, { once: true });
  const decoder = new TextDecoder();
  let text = "";
  try {
    while (true) {
      if (signal.aborted) throw new OrdinaryTimeout("auth");
      const chunk = await reader.read();
      if (signal.aborted) throw new OrdinaryTimeout("auth");
      if (chunk.done) break;
      text += decoder.decode(chunk.value, { stream: true });
    }
    text += decoder.decode();
    return JSON.parse(text);
  } finally { signal.removeEventListener("abort", abort); reader.releaseLock(); }
}

export function ordinaryRest(url: string, key: string, fetcher: typeof fetch = fetch) {
  const request = async (path: string, method: string, payload: unknown, signal: AbortSignal) => {
    // Una fetch reale per operazione; nessun wrapper SDK o retry implicito.
    const response = await fetcher(url.replace(/\/$/, "") + "/rest/v1/" + path, {
      method, signal, headers: { apikey: key, Authorization: "Bearer " + key,
        "Content-Type": "application/json", Prefer: path.startsWith("rpc/") ? "return=representation" : "return=minimal" },
      body: payload === undefined ? undefined : JSON.stringify(payload),
    });
    if (!response.ok) return { data: null, error: "ordinary_http_" + response.status };
    const text = await response.text();
    return { data: text ? JSON.parse(text) : null, error: null };
  };
  return {
    async tickToken(signal: AbortSignal) {
      const r = await request("academy_ai_runtime?select=tick_token&id=eq.1", "GET", undefined, signal);
      return r.error || !Array.isArray(r.data) || r.data.length !== 1 ? null : r.data[0].tick_token;
    },
    rpc(name: string, args: Record<string, unknown>, signal: AbortSignal) {
      if (!["combat_consumer_narrative_claim_v1", "combat_consumer_narrative_complete_v1",
        "combat_consumer_narrative_status_v1", "combat_consumer_scene_acquire_v2", "combat_consumer_scene_permit_v2",
        "combat_consumer_scene_status_v2", "combat_consumer_scene_save_v2", "combat_consumer_scene_complete_v2", "combat_consumer_recovery_acquire_v1", "combat_consumer_recovery_permit_v1", "combat_consumer_recovery_status_v1", "combat_consumer_recovery_save_v1", "combat_consumer_recovery_complete_v1"].includes(name)) throw new Error("ordinary_rpc_not_allowed");
      return request("rpc/" + name, "POST", args, signal);
    },
    async audit(row: unknown, signal: AbortSignal) {
      const r = await request("ai_orchestra_audit", "POST", row, signal);
      if (r.error) throw new Error("ordinary_audit_uncertain");
    },
  };
}
