// exam_genin_ai — contratto della Edge (NARRATORE-UNIFICATO-001)
//
// Il Narratore dell'Esame Genin sul modello editoriale delle Missioni IA:
// ricevuta autoritativa del server → piano narrativo → prosa → validatore per
// riferimenti → `esame_narrazione_apply`. Voce «Fato» in terza persona; lo
// sfidante parla dentro la narrazione. L'IA racconta, il server comanda.

export const FUNCTION_VERSION = "4.7.1-NU001-CANDIDATO";
export const PROMPT_VERSION = 30;
export const CONTRATTO_CICLO = 5;
export const MODELLO = "gpt-5.6-luna";
export const REASONING_EFFORT: "high" = "high";
export const TIMEOUT_MODELLO_MS = 200_000; // richiesta di Antonello (03/09): il ripiego del database è a 5 minuti

export const RUOLI = ["png_difende", "png_attacca", "png_esito", "png_finale"] as const;
export type Ruolo = typeof RUOLI[number];

/**
 * Tetto d'uscita comprensivo del reasoning. La diagnosi 4.6.6 ha escluso una
 * carenza numerica: le saturazioni nascevano dal percorso strict annidato.
 * Il protocollo vettoriale 4.7 usa quindi un margine uniforme di 1.024 token;
 * i limiti della prosa pubblica restano separati e invariati.
 */
export const TETTI_TOKEN: Record<Ruolo, number> = {
  png_difende: 1_024,
  png_attacca: 1_024,
  png_esito: 1_024,
  png_finale: 1_024,
};

/** Tetti di prosa (caratteri): i massimi sono quelli di `_esame_narrazione_valida`. */
export const TETTI_PROSA: Record<Ruolo, { azione: [number, number]; branca: [number, number] }> = {
  png_difende: { azione: [180, 744], branca: [260, 780] },
  png_attacca: { azione: [600, 1680], branca: [260, 780] },
  png_esito: { azione: [600, 1680], branca: [0, 0] },
  png_finale: { azione: [600, 1680], branca: [0, 0] },
};

export const ESITI_NOTI = [
  "copia_colpita", "originale_individuato", "sostituito", "colpito", "sfiorato",
  "parato", "schivato", "mancato",
] as const;

export const AMPIEZZE_NARRATIVE = ["nessuno", "un passo", "due passi", "tre o più passi"] as const;
export type AmpiezzaNarrativa = typeof AMPIEZZE_NARRATIVE[number] | `${Exclude<typeof AMPIEZZE_NARRATIVE[number], "nessuno">}, fino al bordo del tatami` | `${Exclude<typeof AMPIEZZE_NARRATIVE[number], "nessuno">}, fermato dal bordo del tatami`;
export type MovimentoAutoritativo = {
  attore_ref: "actor.candidate" | "actor.opponent";
  direzione: "guadagna terreno" | "cede terreno" | "resta sulla misura";
  ampiezza: AmpiezzaNarrativa;
};

export function ampiezzaNarrativaValida(x: unknown): x is AmpiezzaNarrativa {
  if (typeof x !== "string") return false;
  return /^(?:nessuno|un passo|due passi|tre o più passi)(?:, (?:fino al bordo del tatami|fermato dal bordo del tatami))?$/u.test(x)
    && !/^nessuno,/u.test(x);
}

export type PayloadV5 = {
  versione: number;
  replay?: boolean;
  ricevuta_id: string;
  ruolo: Ruolo;
  contesto_pg: string;
  esito_precedente: Record<string, unknown> | null;
  fatti_del_ciclo: Record<string, unknown>;
  stile_precedente: Array<{ voce: string; testo: string }>;
  scena: Record<string, unknown>;
  dossier: Record<string, unknown>;
  sensei: Record<string, unknown> | null;
  intenzioni: Array<{
    id: string;
    etichetta: string;
    genere: string;
    movimento?: string | null;
    ampiezza?: AmpiezzaNarrativa | null;
    esiti_possibili: string[];
  }>;
  originale?: Record<string, unknown>;
};

/**
 * Nei replay sanitizzati il referto autoritativo può essere conservato sulla
 * fotografia del ciclo senza lo scambio storico che, nel gioco vivo, lo
 * ricostruisce. Si completa soltanto quel campo già esistente. La fixture
 * finale sanitizzata non conserva l'identità del Sensei: nel solo replay la
 * Edge usa l'etichetta di ruolo «il Sensei», già implicata dal ciclo finale.
 * Nessuna identità o fatto meccanico viene dedotto e la dogana V5 valida tutto.
 */
export function completaPayloadReplay(x: unknown, refertoCiclo: unknown): unknown {
  if (!x || typeof x !== "object" || Array.isArray(x)) return x;
  const p = x as Record<string, unknown>;
  if (p.ruolo !== "png_esito" && p.ruolo !== "png_finale") return x;
  let completo = p;
  if (p.esito_precedente == null && refertoCiclo && typeof refertoCiclo === "object" && !Array.isArray(refertoCiclo)) {
    completo = { ...completo, esito_precedente: refertoCiclo };
  }
  if (p.ruolo === "png_finale" && completo.sensei == null) completo = { ...completo, sensei: { nome: "il Sensei" } };
  return completo;
}

/**
 * Il motore autoritativo indica talvolta il prossimo attore con il suo nome
 * esatto. La Edge traduce solo quei due alias già presenti nella scena verso
 * il vocabolario chiuso del contratto; nessun confronto parziale o fuzzy.
 */
function canonIniziativa(raw: unknown, p: Record<string, unknown>): string {
  const valore = String(raw ?? "").toLocaleLowerCase("it").trim();
  if (p.ruolo === "png_finale") return valore;
  const scena = p.scena as Record<string, unknown>;
  const nome = (chiave: "candidato" | "sfidante") => {
    const attore = scena?.[chiave] as Record<string, unknown> | undefined;
    return String(attore?.nome ?? "").toLocaleLowerCase("it").trim();
  };
  const candidato = nome("candidato");
  const sfidante = nome("sfidante");
  if (candidato && (valore === candidato || valore === `passa a ${candidato}`)) return "passa al candidato";
  if (sfidante && (valore === sfidante || valore === `passa a ${sfidante}`)) return "passa allo sfidante";
  return valore;
}

/** La dogana: la forma dichiarata o niente. Non si indovina, si degrada. */
export function verificaPayloadV5(x: unknown): PayloadV5 {
  const p = x as Record<string, unknown>;
  if (!p || typeof p !== "object") throw new Error("payload assente");
  if (p.versione !== CONTRATTO_CICLO) throw new Error(`versione del payload ${String(p.versione)}, attesa ${CONTRATTO_CICLO}`);
  if (typeof p.ricevuta_id !== "string" || !p.ricevuta_id.trim()) throw new Error("ricevuta_id assente");
  if (typeof p.ruolo !== "string" || !(RUOLI as readonly string[]).includes(p.ruolo)) throw new Error("ruolo sconosciuto");
  if (typeof p.contesto_pg !== "string") throw new Error("contesto_pg non è una stringa");
  if (!Array.isArray(p.stile_precedente)) throw new Error("stile_precedente non è un array");
  for (const e of p.stile_precedente as unknown[]) {
    const r = e as Record<string, unknown>;
    if (typeof r?.voce !== "string" || typeof r?.testo !== "string") throw new Error("stile_precedente malformato");
  }
  if (!p.scena || typeof p.scena !== "object" || Array.isArray(p.scena)) throw new Error("scena assente");
  if (!p.dossier || typeof p.dossier !== "object") throw new Error("dossier assente");
  if (!Array.isArray(p.intenzioni) || p.intenzioni.length === 0) throw new Error("intenzioni assenti");
  const visti = new Set<string>();
  for (const i of p.intenzioni as unknown[]) {
    const r = i as Record<string, unknown>;
    if (typeof r?.id !== "string" || !r.id.trim()) throw new Error("intenzione senza id");
    if (visti.has(r.id)) throw new Error("intenzione duplicata");
    visti.add(r.id);
    if (typeof r?.etichetta !== "string" || typeof r?.genere !== "string") throw new Error("intenzione malformata");
    if (r?.movimento != null && typeof r.movimento !== "string") throw new Error("movimento dell'intenzione malformato");
    if (r?.ampiezza != null && !ampiezzaNarrativaValida(r.ampiezza)) throw new Error("ampiezza dell'intenzione fuori vocabolario");
    if (r?.ampiezza != null) {
      if (!["guadagna terreno", "cede terreno", "resta sulla misura"].includes(String(r.movimento))) throw new Error("direzione dell'intenzione con ampiezza fuori vocabolario");
      if ((r.ampiezza === "nessuno") !== (r.movimento === "resta sulla misura")) throw new Error("direzione e ampiezza dell'intenzione sono incoerenti");
    }
    if (!Array.isArray(r?.esiti_possibili)) throw new Error("esiti_possibili assenti");
    if ((r.esiti_possibili as unknown[]).some((e) => typeof e !== "string" || !(ESITI_NOTI as readonly string[]).includes(e))) {
      throw new Error("esito possibile fuori vocabolario");
    }
    if (new Set(r.esiti_possibili as string[]).size !== (r.esiti_possibili as string[]).length) throw new Error("esito possibile duplicato");
    if ((p.ruolo === "png_esito" || p.ruolo === "png_finale") && (r.esiti_possibili as unknown[]).length) throw new Error("branche non ammesse per un ciclo chiuso");
  }
  const ref = p.esito_precedente;
  if (ref != null) {
    if (typeof ref !== "object" || Array.isArray(ref)) throw new Error("esito_precedente malformato");
    const movimenti = (ref as Record<string, unknown>).movimenti_autoritativi;
    if (typeof (ref as Record<string, unknown>).esito !== "string" || !(ESITI_NOTI as readonly string[]).includes(String((ref as Record<string, unknown>).esito))) {
      throw new Error("esito_precedente fuori vocabolario");
    }
    const conseguenza = (ref as Record<string, unknown>).conseguenza;
    if (typeof conseguenza !== "string" || !conseguenza.trim()) throw new Error("conseguenza autoritativa assente");
    if (conseguenza.length > 320) throw new Error("conseguenza autoritativa troppo lunga");
    if (/[\r\n\u0085\u2028\u2029]|[\u0000-\u0009\u000B-\u001F\u007F]/u.test(conseguenza)) throw new Error("conseguenza autoritativa contiene separatori o controlli");
    const iniziativa = canonIniziativa((ref as Record<string, unknown>).iniziativa, p);
    const iniziative = p.ruolo === "png_finale"
      ? ["la prova si chiude", "prova chiusa"]
      : ["candidato", "passa al candidato", "sfidante", "passa allo sfidante", "png", "passa al png"];
    if (!iniziative.includes(iniziativa)) throw new Error("iniziativa autoritativa fuori vocabolario");
    if (iniziativa !== (ref as Record<string, unknown>).iniziativa) {
      p.esito_precedente = { ...(ref as Record<string, unknown>), iniziativa };
    }
    const finale = (ref as Record<string, unknown>).finale_tipo;
    if (finale != null && !["sfinimento", "quattro_round"].includes(String(finale))) throw new Error("finale_tipo fuori vocabolario");
    if (movimenti != null) {
      if (!Array.isArray(movimenti)) throw new Error("movimenti_autoritativi del referto malformati");
      const attori = new Set<string>();
      for (const m of movimenti as unknown[]) {
        const r = m as Record<string, unknown>;
        if (!r || typeof r !== "object" || !["actor.candidate", "actor.opponent"].includes(String(r.attore_ref))) throw new Error("attore del movimento autoritativo malformato");
        if (attori.has(String(r.attore_ref))) throw new Error("movimento autoritativo duplicato per attore");
        attori.add(String(r.attore_ref));
        if (!["guadagna terreno", "cede terreno", "resta sulla misura"].includes(String(r.direzione))) throw new Error("direzione del movimento autoritativo malformata");
        if (!ampiezzaNarrativaValida(r.ampiezza)) throw new Error("ampiezza del movimento autoritativo fuori vocabolario");
        if ((r.ampiezza === "nessuno") !== (r.direzione === "resta sulla misura")) throw new Error("direzione e ampiezza del movimento autoritativo sono incoerenti");
      }
    }
    if (JSON.stringify(ref).match(/[0-9]/)) throw new Error("esito_precedente contiene una cifra");
  }
  if ((p.ruolo === "png_esito" || p.ruolo === "png_finale") && ref == null) {
    throw new Error("esito_precedente assente per un ciclo di esito");
  }
  if (p.ruolo === "png_finale" && !["sfinimento", "quattro_round"].includes(String((ref as Record<string, unknown> | null)?.finale_tipo ?? ""))) {
    throw new Error("finale_tipo assente per il ciclo finale");
  }
  if (p.ruolo === "png_finale") {
    if (!p.sensei || typeof p.sensei !== "object" || Array.isArray(p.sensei)) throw new Error("sensei assente per il ciclo finale");
    const nomeSensei = (p.sensei as Record<string, unknown>).nome;
    if (typeof nomeSensei !== "string" || !nomeSensei.trim()) {
      throw new Error("nome del sensei assente per il ciclo finale");
    }
    if (/[\r\n\u0085\u2028\u2029]|[\u0000-\u001F\u007F]/u.test(nomeSensei)) throw new Error("nome del sensei contiene separatori o controlli");
  }
  return p as unknown as PayloadV5;
}

/** Nessun numero di gioco nel payload, fuori da `scena.spazio` e `versione`. */
export function numeriNelPayload(x: unknown): string[] {
  const out: string[] = [];
  const cammina = (v: unknown, path: string) => {
    if (typeof v === "number") {
      if (path === "versione") return;
      if (/^scena\.spazio\./.test(path)) return;
      out.push(path);
    } else if (Array.isArray(v)) {
      v.forEach((e, i) => cammina(e, `${path}[${i}]`));
    } else if (v && typeof v === "object") {
      for (const [k, e] of Object.entries(v as Record<string, unknown>)) cammina(e, path ? `${path}.${k}` : k);
    }
  };
  cammina(x, "");
  return out;
}
