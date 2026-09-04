// exam_genin_ai — il Narratore dell'Esame Genin (NARRATORE-UNIFICATO-001)
//
// FUNCTION_VERSION 4.7.1-NU001-CANDIDATO · payload del ciclo 5 · prompt 30.
// Sostituisce per intero la v106 (3.11.0-122): stessa porta (POST {prova_id} o
// {class_session_id}; `x-tick-token` del tick oppure JWT del candidato o dello
// staff), stesse risposte per la land ({pubblicato:true} / {ripiego:true}),
// stessa uscita al database (`esame_narrazione_apply`). Cambia tutto il resto:
//   · ingresso: `_esame_ciclo_payload` v5 (ricevuta arricchita, scena in terza
//     persona, dossier dello sfidante, aula per villaggio);
//   · dentro: piano narrativo in otto punti → una chiamata a gpt-5.6-luna →
//     validatore per riferimenti;
//   · niente gate V5 (147F), niente surface mode, niente innesti: il metodo
//     editoriale delle Missioni IA sta nel prompt e nel piano.
// Regole che non cambiano: l'IA racconta, il server comanda; una chiamata per
// ciclo LIVE; la prova non si blocca mai (ogni guasto → ripiego del database);
// nessuna chiave nel codice. Replay: `{replay_prova_id, ciclo_id?}` con il
// token del tick, mai in gioco, nessuna scrittura; può fare un solo secondo
// tentativo quando il primo è meccanicamente valido ma debole in qualità.

import "jsr:@supabase/functions-js/edge-runtime.d.ts";
import { createClient } from "jsr:@supabase/supabase-js@2";
import {
  CONTRATTO_CICLO, FUNCTION_VERSION, MODELLO, PROMPT_VERSION, REASONING_EFFORT,
  TETTI_TOKEN, TIMEOUT_MODELLO_MS, completaPayloadReplay, numeriNelPayload, verificaPayloadV5, type PayloadV5,
} from "./contratto.ts";
import { costruisciPiano } from "./piano.ts";
import { PROMPT_SISTEMA, costruisciUtente, decodificaVettoreCompatto, improntaPrompt, layoutCompatto } from "./prompt.ts";
import { chiamaModello, nomeChiave } from "./provider.ts";
import { materializzaProvenienzaAtomica } from "./provenienza.ts";
import { valida } from "./validatore.ts";

const CORS: Record<string, string> = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Headers": "authorization, x-client-info, apikey, content-type, x-tick-token",
  "Access-Control-Allow-Methods": "POST, OPTIONS",
};
function json(body: unknown, status = 200): Response {
  return new Response(JSON.stringify(body), { status, headers: { ...CORS, "Content-Type": "application/json" } });
}

async function sha256(t: string): Promise<string> {
  const h = await crypto.subtle.digest("SHA-256", new TextEncoder().encode(t));
  return [...new Uint8Array(h)].map((b) => b.toString(16).padStart(2, "0")).join("");
}

// deno-lint-ignore no-explicit-any
type Admin = any;

/** Il ripiego del database: `esame_narrazione_apply` con azione nulla ⇒ `_esame_ciclo_ripiego`. */
async function ripiegoDelDatabase(admin: Admin, prova: string, ricevuta: string, motivi: string[], ctx: Record<string, unknown>) {
  const { data, error } = await admin.rpc("esame_narrazione_apply", {
    p_prova: prova, p_ricevuta: ricevuta, p_intenzione_id: null, p_azione: null, p_esiti: null,
    p_model: MODELLO, p_prompt_version: PROMPT_VERSION, p_impronta_prompt: await improntaPrompt(),
    p_temperatura: null, p_input_tokens: null, p_output_tokens: null, p_stop_reason: null,
    p_errori: motivi.join(" · ") || null,
    p_ctx: { ...ctx, contratto_ciclo: CONTRATTO_CICLO, chiamate: 0, motivi },
  });
  return error ? { errore: error.message } : data;
}

/** Il ciclo: payload → piano → modello → validatore → uscita. Nessuna scrittura qui. */
async function eseguiCiclo(payload: PayloadV5, chiave: string, correzioniQualita: string[] = []) {
  const piano = costruisciPiano(payload);
  const sistema = PROMPT_SISTEMA;
  const baseUtente = costruisciUtente(payload, piano);
  const utente = correzioniQualita.length
    ? `${baseUtente}\n\nRIGENERAZIONE QUALITATIVA CONTROLLATA (non cambia alcun fatto):\n- ${correzioniQualita.join("\n- ")}`
    : baseUtente;
  try { layoutCompatto(payload, piano); } catch (e) {
    return {
      ok: false as const,
      motivi: [`contratto_schema_non_soddisfacibile: ${String((e as Error)?.message ?? e).slice(0, 240)}`],
      telemetria: { model: MODELLO, latency_ms: 0, stop_reason: null, input_tokens: null, output_tokens: null, reasoning_tokens: null,
        piano_sha256: await sha256(JSON.stringify(piano)), stato_sfidante: piano.stato_sfidante.voci_di_tattica_attive },
      piano,
    };
  }
  const risposta = await chiamaModello({
    chiave, modello: MODELLO, effort: REASONING_EFFORT, sistema, utente,
    maxTokens: TETTI_TOKEN[payload.ruolo], timeoutMs: TIMEOUT_MODELLO_MS,
  });
  const telemetria = {
    model: risposta.model, latency_ms: risposta.latency_ms, stop_reason: risposta.stop_reason ?? null,
    input_tokens: risposta.input_tokens ?? null, output_tokens: risposta.output_tokens ?? null,
    reasoning_tokens: risposta.reasoning_tokens ?? null, piano_sha256: await sha256(JSON.stringify(piano)),
    stato_sfidante: piano.stato_sfidante.voci_di_tattica_attive,
  };
  if (!risposta.ok) return { ok: false as const, motivi: [`modello: ${risposta.status ?? 0} ${risposta.detail ?? ""}`.trim()], telemetria, piano };
  if (risposta.stop_reason === "max_tokens") return { ok: false as const, motivi: ["tetto_token_raggiunto"], telemetria, piano, stop_reason: "max_tokens", testo: risposta.text ?? "" };
  let grezza: Record<string, unknown>;
  try { grezza = decodificaVettoreCompatto(risposta.text ?? "", payload, piano); } catch (e) {
    return { ok: false as const, motivi: [`protocollo_compatto: ${String((e as Error)?.message ?? e).slice(0, 240)}`], telemetria, piano };
  }
  const uscita = materializzaProvenienzaAtomica(grezza, payload, piano);
  const verdetto = valida(uscita, payload, piano);
  return {
    ok: verdetto.errori.length === 0,
    motivi: verdetto.errori,
    qualita: verdetto.qualita,
    avvisi: verdetto.avvisi,
    uscita, telemetria, piano,
  };
}

Deno.serve(async (req: Request) => {
  if (req.method === "OPTIONS") return new Response("ok", { headers: CORS });
  if (req.method !== "POST") return json({ error: "method_not_allowed" }, 405);
  try {
    const url = Deno.env.get("SUPABASE_URL")!;
    const svc = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!;
    const admin = createClient(url, svc, { auth: { persistSession: false } });
    const body = await req.json().catch(() => ({} as Record<string, unknown>));

    // ── l'impronta: senza autorizzazione, senza modello ─────────────────────
    if (body?.impronta) {
      return json({
        ok: true, function_version: FUNCTION_VERSION, contratto_ciclo: CONTRATTO_CICLO,
        prompt_version: PROMPT_VERSION, impronta_prompt: await improntaPrompt(),
        modello: MODELLO, reasoning: REASONING_EFFORT, tetti_token: TETTI_TOKEN, chiamate_per_ciclo: 1,
        gate_v5: "ritirato", metodo: "ricevuta → brief minimo → prosa → provenienza deterministica → validatore meccanico + qualità",
        replay_chiamate_massime: 1,
      });
    }

    // ── le due porte: il token del tick, o il JWT del candidato/staff ───────
    let authorized = false; let tickAuthorized = false;
    const tickHeader = req.headers.get("x-tick-token");
    if (tickHeader) {
      const { data: rt } = await admin.from("academy_ai_runtime").select("tick_token").eq("id", 1).maybeSingle();
      if (rt?.tick_token && tickHeader === rt.tick_token) { authorized = true; tickAuthorized = true; }
    }
    let callerUid: string | null = null;
    if (!authorized) {
      const token = (req.headers.get("Authorization") || "").replace(/^Bearer\s+/i, "").trim();
      if (token) { const { data: u } = await admin.auth.getUser(token); callerUid = u?.user?.id ?? null; }
    }
    const chiave = Deno.env.get(nomeChiave());

    if (body?.ping) {
      if (!tickAuthorized) return json({ error: "unauthorized" }, 403);
      if (!chiave) return json({ error: "missing_openai_key" }, 500);
      const p = await chiamaModello({ chiave, modello: MODELLO, effort: null, sistema: "Rispondi in italiano.", utente: "Rispondi con una sola parola: pong.", maxTokens: 16, timeoutMs: 30_000 });
      if (!p.ok) return json({ error: "openai_error", status: p.status, detail: p.detail }, 502);
      return json({ ok: true, modello: p.model, pong: p.text, function_version: FUNCTION_VERSION });
    }

    // ── il replay: una prova conclusa, un ciclo, nessuna scrittura ──────────
    if (typeof body?.replay_prova_id === "string") {
      if (!tickAuthorized) return json({ error: "unauthorized" }, 403);
      if (!chiave) return json({ error: "missing_openai_key" }, 500);
      const provaId = body.replay_prova_id as string;
      const { data: prova } = await admin.from("esame_prove").select("id, stato").eq("id", provaId).maybeSingle();
      if (!prova || prova.stato !== "conclusa") return json({ error: "replay_richiede_prova_conclusa" }, 409);
      let cicli: Array<{ id: string; ruolo: string; created_at: string; referto: unknown }> = [];
      if (typeof body?.ciclo_id === "string") {
        const { data: c } = await admin.from("esame_narrazione_cicli").select("id, ruolo, created_at, referto").eq("id", body.ciclo_id).eq("prova_id", provaId).maybeSingle();
        if (c) cicli = [c];
      } else {
        const { data: cs } = await admin.from("esame_narrazione_cicli").select("id, ruolo, created_at, referto").eq("prova_id", provaId)
          .in("ruolo", ["png_difende", "png_attacca", "png_esito", "png_finale"]).order("created_at", { ascending: true });
        cicli = cs ?? [];
      }
      const massimo = typeof body?.massimo === "number" ? Math.max(1, Math.min(20, body.massimo)) : 20;
      const esiti: unknown[] = [];
      for (const c of cicli.slice(0, massimo)) {
        const { data: grezzo, error: e } = await admin.rpc("_esame_replay_payload", { p_prova: provaId, p_ciclo: c.id });
        if (e || !grezzo) { esiti.push({ ciclo: c.id, ruolo: c.ruolo, errore: e?.message ?? "payload nullo" }); continue; }
        let payload: PayloadV5;
        try { payload = verificaPayloadV5(completaPayloadReplay(grezzo, c.referto)); } catch (err) { esiti.push({ ciclo: c.id, ruolo: c.ruolo, errore: `dogana: ${(err as Error).message}` }); continue; }
        const numeri = numeriNelPayload(payload).filter((x) => !/^originale\./.test(x));
        if (numeri.length) { esiti.push({ ciclo: c.id, ruolo: c.ruolo, errore: `numeri nel payload: ${numeri.join(",")}` }); continue; }
        const r = await eseguiCiclo(payload, chiave);
        const chiamate = 1;
        const primaQualita = (r as any).qualita ?? [];
        const primaTelemetria = r.telemetria;
        esiti.push({
          ciclo: c.id, ruolo: c.ruolo, ok: r.ok, motivi: r.motivi,
          qualita: (r as any).qualita ?? [], qualita_primo_tentativo: primaQualita,
          avvisi: (r as any).avvisi ?? [], chiamate,
          telemetria: r.telemetria, telemetria_primo_tentativo: primaTelemetria,
          perche: (r as any).uscita?.perche ?? null,
          azione_png: (r as any).uscita?.azione_png ?? (r as any).testo ?? null, esiti: (r as any).uscita?.esiti ?? null,
          player_reprise_ids: (r as any).uscita?.player_reprise_ids ?? [],
          fonti_azione: (r as any).uscita?.fonti_azione ?? [], fonti_esiti: (r as any).uscita?.fonti_esiti ?? {},
          originale: payload.originale ?? null,
          player_bridge: r.piano.player_bridge, esito_precedente: payload.esito_precedente, fatti_del_ciclo: payload.fatti_del_ciclo,
          piano: body?.con_piano ? r.piano : undefined,
        });
      }
      return json({ ok: true, replay: true, prova: provaId, cicli: esiti.length, esiti, function_version: FUNCTION_VERSION });
    }

    // ── la prova ────────────────────────────────────────────────────────────
    let provaId: string | null = typeof body?.prova_id === "string" ? body.prova_id : null;
    if (!provaId && typeof body?.class_session_id === "string") {
      const { data: p } = await admin.from("esame_prove").select("id").eq("class_session_id", body.class_session_id).eq("stato", "aperta").maybeSingle();
      provaId = p?.id ?? null;
    }
    if (!provaId) return json({ error: "missing_prova_id" }, 400);
    const { data: prova, error: pErr } = await admin.from("esame_prove").select("id, candidate_user, stato").eq("id", provaId).maybeSingle();
    if (pErr) return json({ error: "prova_error", detail: pErr.message }, 500);
    if (!prova) return json({ error: "prova_inesistente" }, 404);
    if (!authorized && callerUid) {
      if (prova.candidate_user === callerUid) authorized = true;
      else {
        const { data: prof } = await admin.from("profiles").select("role").eq("id", callerUid).maybeSingle();
        if (prof?.role === "admin" || prof?.role === "master") authorized = true;
      }
    }
    if (!authorized) return json({ error: "unauthorized" }, 403);

    // ── l'ingresso: il payload lo scrive il database, una lettura sola ──────
    const { data: grezzo, error: payErr } = await admin.rpc("_esame_ciclo_payload", { p_prova: provaId });
    if (payErr) return json({ error: "payload_error", detail: payErr.message }, 500);
    if (grezzo == null) return json({ skipped: true, reason: "nessun ciclo aperto per questa prova" });

    let payload: PayloadV5;
    try { payload = verificaPayloadV5(grezzo); } catch (err) {
      const ricevuta = String((grezzo as any)?.ricevuta_id ?? "");
      const esito = ricevuta ? await ripiegoDelDatabase(admin, provaId, ricevuta, [`payload_v5_non_conforme: ${(err as Error).message}`], {}) : null;
      return json({ error: "payload_v5_non_conforme", detail: (err as Error).message, ripiego: true, db: esito }, 500);
    }
    const numeri = numeriNelPayload(payload);
    if (numeri.length) {
      const esito = await ripiegoDelDatabase(admin, provaId, payload.ricevuta_id, [`numeri_nel_payload: ${numeri.join(",")}`], {});
      return json({ error: "numeri_nel_payload", numeri, ripiego: true, db: esito }, 500);
    }
    if (!chiave) {
      const esito = await ripiegoDelDatabase(admin, provaId, payload.ricevuta_id, ["chiave del provider assente"], {});
      return json({ error: "missing_openai_key", ripiego: true, db: esito }, 500);
    }

    const r = await eseguiCiclo(payload, chiave);
    const ctx = { ...r.telemetria, contratto_ciclo: CONTRATTO_CICLO, prompt_version: PROMPT_VERSION, function_version: FUNCTION_VERSION,
      qualita: (r as any).qualita ?? [], avvisi: (r as any).avvisi ?? [], perche: (r as any).uscita?.perche ?? null, chiamate: 1,
      provenienza: r.ok ? {
        player_reprise_ids: (r as any).uscita?.player_reprise_ids ?? [],
        fonti_azione: (r as any).uscita?.fonti_azione ?? [],
        fonti_esiti: (r as any).uscita?.fonti_esiti ?? {},
        player_bridge_sha256: await sha256(JSON.stringify(r.piano.player_bridge)),
      } : null };

    if (!r.ok) {
      const stop = (r as any).stop_reason ?? null;
      const { data, error } = await admin.rpc("esame_narrazione_apply", {
        p_prova: provaId, p_ricevuta: payload.ricevuta_id, p_intenzione_id: null,
        p_azione: (r as any).testo ?? null, p_esiti: null,
        p_model: r.telemetria.model, p_prompt_version: PROMPT_VERSION, p_impronta_prompt: await improntaPrompt(),
        p_temperatura: null, p_input_tokens: r.telemetria.input_tokens, p_output_tokens: r.telemetria.output_tokens,
        p_stop_reason: stop, p_errori: r.motivi.join(" · ") || null, p_ctx: { ...ctx, motivi: r.motivi },
      });
      return json({ ok: true, ripiego: true, non_pubblicato: true, motivi: r.motivi, db: error ? { errore: error.message } : data });
    }

    const u = r.uscita!;
    const { data, error } = await admin.rpc("esame_narrazione_apply", {
      p_prova: provaId, p_ricevuta: payload.ricevuta_id, p_intenzione_id: String(u.intenzione_id),
      p_azione: String(u.azione_png), p_esiti: u.esiti ?? {},
      p_model: r.telemetria.model, p_prompt_version: PROMPT_VERSION, p_impronta_prompt: await improntaPrompt(),
      p_temperatura: null, p_input_tokens: r.telemetria.input_tokens, p_output_tokens: r.telemetria.output_tokens,
      p_stop_reason: r.telemetria.stop_reason, p_errori: null, p_ctx: ctx,
    });
    if (error) return json({ ok: false, error: "apply_error", detail: error.message }, 500);
    const d = data as Record<string, unknown> | null;
    const ripiego = !!(d && (d.ripiego === true || d.scartato === true));
    return json({ ok: true, pubblicato: !ripiego && d?.ok !== false, ripiego, non_pubblicato: ripiego || d?.ok === false, db: d,
      qualita: (r as any).qualita ?? [], avvisi: (r as any).avvisi ?? [], function_version: FUNCTION_VERSION });
  } catch (e) {
    return json({ error: "server_error", detail: String((e as Error)?.message ?? e).slice(0, 400) }, 500);
  }
});
