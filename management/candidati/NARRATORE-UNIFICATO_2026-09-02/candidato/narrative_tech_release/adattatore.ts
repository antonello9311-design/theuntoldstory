// ============================================================================
// adattatore.ts · AI-NARRATOR-HAIKU-LUNA-046 · SORGENTE CANONICO
// ----------------------------------------------------------------------------
// L'unica porta verso un modello per le Edge narrative del progetto.
//
// Perché esiste. Oggi `combat_narratore_ai` e `exam_genin_ai` chiamano
// modello arriva — nel combattimento — da una riga di database
// (`ai_agents.model`, letta da `combat_narratore_context`). Finché esiste un
// solo provider quella riga è innocua. Con due provider diventa un instradatore
// travestito da configurazione: basta scriverci uno slug OpenAI perché una
// punto dove nessuno sta guardando.
//
// La regola di questo file, in una riga:
//   ⛔ IL PROVIDER NON SI DEDUCE MAI DA UN DATO SCRIVIBILE.
//      Si legge da un registro chiuso, scritto qui, e uno slug che non è nel
//      registro NON PRODUCE NESSUNA CHIAMATA.
//
// La seconda regola:
//   ⛔ NESSUN RIPIEGO IMPLICITO FRA PROVIDER.
//      Un errore OpenAI è un errore, e finisce nel ripiego deterministico che
//      funzione `chiama` esegue AL PIÙ UNA `fetch`, sempre, per costruzione:
//      il contatore `tentativiHttp` lo dimostra al banco.
//
// La terza regola:
//   ⛔ NESSUN SEGRETO ESCE DA QUI.
//      La chiave si legge dall'ambiente Supabase al momento della chiamata, si
//      usa in un header e non entra in nessun ritorno, nessun `detail`, nessun
//      diario, nessuna telemetria. `detail` è troncato e passa da `spolpa()`.
//
// ⚠️ QUESTO FILE È UNO SOLO. Le copie depositate dentro i due candidati devono
//    avere lo STESSO sha256 di questo. Lo verifica `strumenti/verifica.py` e lo
//    riverifica il banco: due copie che divergono in silenzio sono esattamente
//    il difetto che la 084-A12 ha pagato fra guardia SQL e specchio TypeScript.
// ============================================================================

// ---------------------------------------------------------------------------
// 1 · L'uscita comune
// ---------------------------------------------------------------------------
// I primi sette campi sono, alla lettera, il tipo `EsitoChiamata` che
// `exam_genin_ai/validatore.ts` già dichiara (riga 827 del file vivo v11) e che
// il piano 046-A0 fissa come uscita comune. Tutto il resto è ADDITIVO: un
// consumer che non lo legge continua a funzionare identico.
export type UscitaModello = {
  ok: boolean;
  provider_response_id?: string | null;
  provider_request_sha256?: string;
  raw_output_sha256?: string;
  text?: string;
  stop_reason?: string | null;
  input_tokens?: number | null;
  output_tokens?: number | null;
  status?: number;
  detail?: string;

  // ---- additivi: telemetria confrontabile (046-A0 §3) ---------------------
  provider?: Provider;
  model?: string;
  braccio?: Braccio;
  reasoning_effort?: string | null;
  reasoning_tokens?: number | null;
  latency_ms?: number;
  tentativi_http?: number;
  troncato?: boolean;
};

export type Provider = "openai";

// ---------------------------------------------------------------------------
// 2 · Il registro chiuso modello → provider
// ---------------------------------------------------------------------------
// SEDE UNICA. Uno slug che non compare qui non ha provider, e senza provider
// non c'è chiamata. Non esiste un ramo «default».
export const REGISTRO_MODELLI: Readonly<Record<string, Provider>> = Object.freeze({
  "gpt-5.6-luna": "openai",
});

export function providerDi(modello: string | null | undefined): Provider | null {
  const m = String(modello ?? "").trim();
  if (!m) return null;
  return REGISTRO_MODELLI[m] ?? null;
}

// ---------------------------------------------------------------------------
// 3 · I bracci del confronto
// ---------------------------------------------------------------------------
// I bracci sono DUE, e uno solo è di Luna.
//
// 🔴 DECISIONE DI ANTONELLO del 21/08/2026: l'unico braccio Luna è
//    `reasoning.effort: "high"`. I due bracci `none` e `low` previsti dal piano
//    046-A0 §2 sono RITIRATI: non stanno in questo file, non stanno nei banchi e
//    non stanno nell'harness. Un braccio ritirato che sopravvive in un elenco è
//    un braccio che qualcuno rieseguirà.
//
// ⚠️ `modello: null` nel braccio di baseline NON è una dimenticanza: la
//    baseline conserva il comportamento vivo, cioè il modello che il consumer
//    l'Esame la costante `MODELLO` del contratto). Il braccio non lo riscrive.
export type Braccio = "openai_luna_high";

export type DefinizioneBraccio = {
  provider: Provider;
  /** `null` = si usa il modello che il consumer già dichiara (baseline). */
  modello: string | null;
  // 🔴 L'insieme è CHIUSO su un valore solo, e non è pigrizia: se restasse
  //    aperto (`string`), il giorno in cui qualcuno scrive `"medium"` per
  //    provare, il controllo dei tipi non direbbe niente e la differenza si
  //    non ha ragionamento.
  reasoning: "high" | null;
  /** `true` = la temperatura del consumer viene trasmessa. Vedi §5. */
  trasmetti_temperatura: boolean;
  /** Token aggiunti al tetto d'uscita per far posto al ragionamento. Vedi §6. */
  riserva_ragionamento: number;
};

export const BRACCI: Readonly<Record<Braccio, DefinizioneBraccio>> = Object.freeze({
  openai_luna_high: Object.freeze({
    provider: "openai",
    modello: "gpt-5.6-luna",
    // 🔴 L'unico braccio Luna, per decisione di Antonello del 21/08/2026.
    reasoning: "high",
    // ⚠️ FALSO PER SCELTA, non per svista. La documentazione OpenAI dichiara
    //    `temperature` supportato da `gpt-5.6-luna`, ma «supportato» non vuol
    //    dire «equivalente»: il piano 046-A0 §2 vieta di trascrivere la
    //    verificata. Finché il corpus non dice il contrario il parametro NON
    //    viene spedito, e resta OPEN-046-2.
    trasmetti_temperatura: false,
    // 🔴🔴 ZERO, e con `effort: "high"` questa riga è la più pericolosa del file.
    //
    //    Su Responses `max_output_tokens` limita TESTO PIÙ RAGIONAMENTO, e il
    //    ragionamento si spende per primo. Con `high` il modello ragiona molto:
    //    su un tetto largo non si nota, su un tetto stretto la prosa non nasce
    //    proprio. Il combattimento ha un tetto di 900 token e rifiuta i testi
    //    sotto i 500 caratteri: i due numeri insieme dicono che il margine è
    //    quasi nullo.
    //
    //    Zero resta il valore consegnato perché è l'unico fedele alla
    //    prescrizione «stessi tetti della baseline» del piano §2, e perché
    //    alzare un tetto è una decisione del PM, non dell'implementazione.
    //    L'harness misura che cosa succede a zero e che cosa succederebbe con
    //    una riserva (`--riserva N`), così la decisione si prende su due
    //    colonne di numeri invece che su un'impressione. OPEN-046-3.
    riserva_ragionamento: 8192,
  }),
});

// ---------------------------------------------------------------------------
// 4 · La chiave, e dove NON va
// ---------------------------------------------------------------------------
// Le chiavi stanno SOLO nell'ambiente Supabase. Questo file non ne scrive
// nessuna, non ne stampa nessuna e non ne mette nessuna nel ritorno.
export function nomeChiave(): "OPENAI_API_KEY" {
  return "OPENAI_API_KEY";
}

type LettoreAmbiente = (nome: string) => string | undefined;

const AMBIENTE_PREDEFINITO: LettoreAmbiente = (nome) => {
  // `Deno` non esiste quando questo file gira dentro il banco in Node: in quel
  // caso non c'è ambiente, non c'è chiave e non parte nessuna chiamata vera.
  // deno-lint-ignore no-explicit-any
  const d = (globalThis as any).Deno;
  return d?.env?.get ? d.env.get(nome) : undefined;
};

// ---------------------------------------------------------------------------
// 5 · La richiesta
// ---------------------------------------------------------------------------
export type RichiestaModello = {
  braccio: Braccio;
  /** Il modello che il consumer dichiara. Usato SOLO dal braccio di baseline. */
  modelloConsumer?: string | null;
  sistema: string;
  utente: string;
  /** Il tetto d'uscita del consumer, invariato. */
  maxTokens: number;
  /** La temperatura del consumer, se ne ha una. */
  temperatura?: number | null;
  signal?: AbortSignal;
  /** Iniettabile dal banco. In esercizio resta `undefined`. */
  fetchImpl?: typeof fetch;
  /** Iniettabile dal banco. In esercizio resta `undefined`. */
  ambiente?: LettoreAmbiente;
  /** Iniettabile dal banco per rendere la latenza misurabile e ripetibile. */
  orologio?: () => number;
};

const CAP_DETTAGLIO = 600;

/** Toglie da un testo destinato al referto qualunque cosa somigli a una chiave.
 *  Non è una promessa di sicurezza: è una rete in più su un campo che finisce
 *  in `p_ctx`, cioè a database. */
export function spolpa(s: unknown): string {
  // ⚠️ L'ORDINE CONTA. Prima si toglie l'intestazione INTERA fino a fine riga —
  //    altrimenti la regola sullo slug la spezza a metà e resta il contorno —
  //    e solo dopo si mascherano gli slug rimasti dentro il testo.
  return String(s ?? "")
    .replace(/(?:authorization|api[-_]?key)\s*[:=]\s*[^\n\r]+/gi, "«omessa»")
    .replace(/sk-[A-Za-z0-9_\-]{8,}/g, "sk-«omessa»")
    .slice(0, CAP_DETTAGLIO);
}

// ---------------------------------------------------------------------------
// 6 · La normalizzazione di `stop_reason` — il punto in cui si rompe tutto
// ---------------------------------------------------------------------------
// `'max_tokens'` NON è una parola descrittiva: è un VALORE DI CONTRATTO. Lo
// confronta `validatore.ts` (`if (LEVE.tetto_token && stopReason === "max_tokens")`)
// e lo confronta la funzione `public.esame_narrazione_apply` dentro la
// transazione. Le Responses API non dicono `max_tokens`: dicono
// `status: "incomplete"` con `incomplete_details.reason = "max_output_tokens"`.
//
// Se l'adattatore lasciasse passare la parola di OpenAI, il tetto raggiunto
// smetterebbe di essere rilevato da entrambe le guardie e una risposta troncata
// verrebbe pubblicata come se fosse intera. È il difetto peggiore possibile in
// questa migrazione, e sta tutto in questa funzione.
export function normalizzaStopOpenAI(d: {
  status?: string | null;
  incomplete_details?: { reason?: string | null } | null;
}): string | null {
  const st = String(d?.status ?? "").trim();
  if (st === "completed") return "end_turn";
  if (st === "incomplete") {
    const r = String(d?.incomplete_details?.reason ?? "").trim();
    if (r === "max_output_tokens") return "max_tokens";
    return r ? `incomplete:${r}` : "incomplete";
  }
  if (!st) return null;
  return st;
}

/** Estrae il testo da una risposta Responses. `output_text` è la comodità
 *  documentata; la passeggiata su `output[]` è la strada che regge anche
 *  quando in mezzo agli item c'è un blocco `reasoning`. */
export function testoDaResponses(d: unknown): string {
  const o = d as Record<string, unknown>;
  if (typeof o?.output_text === "string") return o.output_text.trim();
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
  return pezzi.join("").trim();
}

// ---------------------------------------------------------------------------
// 7 · La chiamata
// ---------------------------------------------------------------------------
export function responsePayload(r: RichiestaModello): Record<string, unknown> {
  if (!Object.hasOwn(BRACCI,r.braccio)) throw new Error('scene_provider_configuration_invalid');
  const def=BRACCI[r.braccio];
  const modello=def.modello ?? String(r.modelloConsumer ?? '').trim();
    const corpo: Record<string, unknown> = {
      model: modello,
      instructions: r.sistema,
      input: r.utente,
      max_output_tokens: r.maxTokens + def.riserva_ragionamento,
      // `store: false` — il testo di gioco non resta sui server del provider.
      // Non è una richiesta del piano: è la scelta prudente, ed è dichiarata.
      store: false,
    };
    if (def.reasoning) corpo.reasoning = { effort: def.reasoning };
    if (def.trasmetti_temperatura && typeof r.temperatura === "number") {
      corpo.temperature = r.temperatura;
    }
  return corpo;
}

export async function chiama(r: RichiestaModello): Promise<UscitaModello> {
  // 🔴 `Object.hasOwn`, non `r.braccio in BRACCI`. L'operatore `in` cammina sul
  //    prototipo: `"__proto__" in BRACCI` è VERO, e `BRACCI["__proto__"]`
  //    restituisce `Object.prototype`, che è un oggetto verissimo con
  //    `provider` e `modello` a `undefined`. Un insieme «chiuso» interrogato
  //    con `in` non è chiuso. Trovato dal banco del giunto, prova P10.
  const def = Object.hasOwn(BRACCI, r.braccio) ? BRACCI[r.braccio] : undefined;
  const ora = r.orologio ?? (() => Date.now());
  const partito = ora();

  // -- il braccio deve esistere. Non c'è un ramo «altrimenti fai la baseline».
  if (!def) {
    return {
      ok: false, status: 0, detail: `braccio sconosciuto: ${spolpa(r.braccio)}`,
      provider: undefined, braccio: r.braccio, tentativi_http: 0, latency_ms: 0,
    };
  }

  // -- il modello effettivo -------------------------------------------------
  const modello = def.modello ?? String(r.modelloConsumer ?? "").trim();
  const provRegistro = providerDi(modello);

  // 🔴 LA GUARDIA CHE GIUSTIFICA QUESTO FILE.
  //    Uno slug che non è nel registro non viene spedito da nessuna parte.
  if (provRegistro === null) {
    return {
      ok: false, status: 0,
      detail: `modello fuori registro: ${spolpa(modello) || "«vuoto»"}`,
      model: modello || undefined, braccio: r.braccio,
      reasoning_effort: def.reasoning, tentativi_http: 0, latency_ms: 0,
    };
  }
  //    E uno slug del provider sbagliato non viene spedito all'endpoint
  //    dell'altro. È il caso `ai_agents.model = 'gpt-5.6-luna'` con il braccio
  if (provRegistro !== def.provider) {
    return {
      ok: false, status: 0,
      detail: `instradamento rifiutato: il modello «${spolpa(modello)}» è di ${provRegistro}, il braccio ${r.braccio} è di ${def.provider}`,
      model: modello, provider: def.provider, braccio: r.braccio,
      reasoning_effort: def.reasoning, tentativi_http: 0, latency_ms: 0,
    };
  }

  const provider = def.provider;
  const leggi = r.ambiente ?? AMBIENTE_PREDEFINITO;
  const chiave = leggi(nomeChiave());
  if (!chiave) {
    return {
      ok: false, status: 0,
      detail: `chiave assente per ${provider} (${nomeChiave()})`,
      model: modello, provider, braccio: r.braccio,
      reasoning_effort: def.reasoning, tentativi_http: 0, latency_ms: 0,
    };
  }

  const comune = {
    provider, model: modello, braccio: r.braccio,
    reasoning_effort: def.reasoning,
  };

  // -- UNA sola `fetch`, e il contatore lo dimostra -------------------------
  let tentativi = 0;
  const eseguiFetch = r.fetchImpl ?? fetch;

  try {
    // ── Responses API · il percorso nuovo ─────────────────────────────────
    // `instructions` è la sede del sistema; `input` quella del turno utente.
    // La forma a stringa è quella documentata e basta a riprodurre l'unico
    // messaggio `user` che entrambi i consumer già mandano: nessun consumer
    // manda una conversazione a più turni.
    const corpo = responsePayload(r);
    tentativi += 1;
    const risp = await eseguiFetch("https://api.openai.com/v1/responses", {
      method: "POST",
      headers: {
        "content-type": "application/json",
        "authorization": `Bearer ${chiave}`,
      },
      body: JSON.stringify(corpo),
      signal: r.signal,
    });
    if (!risp.ok) {
      const t = await risp.text();
      //    ripiego deterministico: è quello, e si vede nel referto.
      return { ok: false, status: risp.status, detail: spolpa(t), ...comune,
               tentativi_http: tentativi, latency_ms: ora() - partito };
    }
    const d = await risp.json();
    if (String(d?.status ?? "") === "failed") {
      return {
        ok: false, status: 200,
        detail: spolpa(d?.error?.message ?? "risposta failed"),
        ...comune, tentativi_http: tentativi, latency_ms: ora() - partito,
      };
    }
    const stop = normalizzaStopOpenAI(d);
    // Provenienza additiva per il raccordo ordinary: solo corpo richiesta/risposta,
    // mai header, chiavi o segreti. Nessun identificativo inventato.
    const digest = async (value: string) => Array.from(new Uint8Array(
      await crypto.subtle.digest("SHA-256", new TextEncoder().encode(value)),
    )).map((n) => n.toString(16).padStart(2, "0")).join("");
    return {
      ok: true,
      provider_response_id: typeof d?.id === "string" ? d.id : null,
      provider_request_sha256: await digest(JSON.stringify(corpo)),
      raw_output_sha256: await digest(JSON.stringify(d)),
      text: testoDaResponses(d),
      stop_reason: stop,
      input_tokens: typeof d?.usage?.input_tokens === "number" ? d.usage.input_tokens : null,
      output_tokens: typeof d?.usage?.output_tokens === "number" ? d.usage.output_tokens : null,
      reasoning_tokens:
        typeof d?.usage?.output_tokens_details?.reasoning_tokens === "number"
          ? d.usage.output_tokens_details.reasoning_tokens
          : null,
      troncato: stop === "max_tokens",
      ...comune, tentativi_http: tentativi, latency_ms: ora() - partito,
    };
  } catch (e) {
    // Rete caduta, timeout, abort: dal punto di vista del consumer il modello
    // ha taciuto. È lo stesso caso che i due consumer già conoscono.
    return {
      ok: false, status: 0, detail: spolpa((e as Error)?.message ?? e),
      ...comune, tentativi_http: tentativi, latency_ms: ora() - partito,
    };
  }
}

// ---------------------------------------------------------------------------
// 8 · La telemetria, in una forma sola
// ---------------------------------------------------------------------------
// Quello che ogni referto di prova deve portare (046-A0 §3). Non contiene testo
// di gioco e non contiene segreti: è fatto per finire dentro un `jsonb`.
export function telemetria(u: UscitaModello, extra?: Record<string, unknown>) {
  return {
    provider: u.provider ?? null,
    modello: u.model ?? null,
    braccio: u.braccio ?? null,
    reasoning_effort: u.reasoning_effort ?? null,
    input_tokens: u.input_tokens ?? null,
    output_tokens: u.output_tokens ?? null,
    reasoning_tokens: u.reasoning_tokens ?? null,
    stop_reason: u.stop_reason ?? null,
    troncato: u.troncato ?? null,
    latenza_ms: u.latency_ms ?? null,
    tentativi_http: u.tentativi_http ?? null,
    esito_http: u.status ?? null,
    ...(extra ?? {}),
  };
}

// 🔴 La versione sale insieme all'insieme dei bracci, e non è cosmesi: un
//    referto vecchio dice `046-A1` e parla di un mondo in cui esistevano
//    `openai_luna_none` e `openai_luna_low`. Chi confronta due corse deve
//    vedere subito che non sono confrontabili.
export const ADATTATORE_VERSIONE = "046-A3 · solo OpenAI Responses Luna high";
