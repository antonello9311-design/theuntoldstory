// Provenienza deterministica del contratto generativo 6.
// Il modello non emette identificatori, claim o fonti: la Edge li ricava dalla
// ricevuta e dall'intenzione scelta prima di eseguire i controlli meccanici.

import type { PayloadV5 } from "./contratto.ts";
import type { Piano } from "./piano.ts";

/**
 * Canonicalizza soltanto un singolo ritorno di riga tipografico fra due tratti
 * di prosa. Strutture ambigue (righe vuote, bordi, CR isolati) e ogni altro
 * carattere di controllo restano intatte, così il validatore le respinge.
 */
export function canonicalizzaParagrafoWire(testo: string): string {
  if (!/[\r\n]/u.test(testo)) return testo;
  if (/[\u0000-\u0009\u000B\u000C\u000E-\u001F\u007F]/u.test(testo)) return testo;
  if (/\r(?!\n)/u.test(testo)) return testo;
  const ritorni = testo.match(/\r\n|\n/gu) ?? [];
  if (ritorni.length !== 1) return testo;
  if (/^ *(?:\r\n|\n)|(?:\r\n|\n) *$/u.test(testo)) return testo;
  return testo.replace(/ *(?:\r\n|\n) */u, " ");
}

function numeroFrasi(testo: string): number {
  let n = 0;
  let corrente = "";
  for (let i = 0; i < testo.length; i++) {
    const ch = testo[i];
    corrente += ch;
    if (/[.!?…]/u.test(ch) && (i + 1 >= testo.length || /\s/u.test(testo[i + 1]))) {
      if (corrente.trim()) n++;
      corrente = "";
    }
  }
  if (corrente.trim()) n++;
  return Math.max(1, n);
}

function uniche(xs: string[]): string[] {
  return [...new Set(xs)];
}

function fontiComuni(p: PayloadV5, piano: Piano): string[] {
  return uniche([
    "server.scena",
    "persona.sfidante",
    ...(piano.riferimenti.memoria_stile.frasi.length ? ["memoria.stile"] : []),
  ]);
}

function fontiEsitoRisolto(p: PayloadV5): string[] {
  const ref = (p.esito_precedente ?? {}) as Record<string, unknown>;
  const movimenti = Array.isArray(ref.movimenti_autoritativi)
    ? ref.movimenti_autoritativi as Array<Record<string, unknown>>
    : [];
  return uniche([
    ...(p.esito_precedente ? ["server.esito"] : []),
    ...(typeof ref.tecnica_id === "string" ? ["server.scheda_tecnica"] : []),
    ...(ref.conseguenza || ((p.scena as Record<string, unknown>).segni as unknown[] | undefined)?.length
      ? ["server.conseguenza"] : []),
    ...(movimenti.some((x) => x.attore_ref === "actor.candidate")
      ? ["server.posizione.esito.candidato"] : []),
    ...(movimenti.some((x) => x.attore_ref === "actor.opponent")
      ? ["server.posizione.esito.sfidante"] : []),
  ]);
}

function fontiIntenzione(p: PayloadV5, intenzioneId: string): string[] {
  const intenzione = p.intenzioni.find((x) => x.id === intenzioneId);
  return uniche([
    ...(intenzione ? ["server.intenzione"] : []),
    ...(intenzione?.tecnica_id ? ["server.scheda_tecnica"] : []),
    ...(intenzione?.movimento || intenzione?.ampiezza ? ["server.posizione.intenzione"] : []),
  ]);
}

function fontiBranca(p: PayloadV5, piano: Piano, intenzioneId: string): string[] {
  // La manovra appartiene ad azione_png. Le branche partono dal suo assetto e
  // raccontano soltanto l'esito alternativo: non devono ripetere il movimento.
  return uniche([...fontiComuni(p, piano), ...(p.intenzioni.some((x) => x.id === intenzioneId) ? ["server.intenzione"] : [])]);
}

export const SEGMENTI_BRANCA = ["esito", "risposta_fisica", "assetto_finale"] as const;
export type SegmentoBranca = typeof SEGMENTI_BRANCA[number];
export type SegmentoAzione = "preparazione" | "esito_precedente" | "risposta_fisica" | "nuova_intenzione" | "intervento_sensei" | "assetto_finale";

/** Il keyset è funzione del ruolo e dei soli fatti già presenti nel payload. */
export function segmentiAzioneAttesi(p: PayloadV5): SegmentoAzione[] {
  if (p.ruolo === "png_attacca") return p.esito_precedente
    ? ["esito_precedente", "risposta_fisica", "nuova_intenzione", "assetto_finale"]
    : ["preparazione", "nuova_intenzione", "assetto_finale"];
  if (p.ruolo === "png_esito") return ["esito_precedente", "risposta_fisica", "assetto_finale"];
  if (p.ruolo === "png_finale") return ["esito_precedente", "risposta_fisica", "intervento_sensei", "assetto_finale"];
  return ["preparazione", "nuova_intenzione", "assetto_finale"];
}

type BloccoSegmenti = { testi: Record<string, string>; errori: string[] };

function normalizzaSegmento(testo: string): string {
  return testo.toLocaleLowerCase("it").normalize("NFKC").replace(/[^\p{L}\p{N}]+/gu, " ").trim();
}

function leggiSegmenti(grezzi: unknown, attesi: readonly string[], dove: string): BloccoSegmenti {
  const errori: string[] = [];
  if (!grezzi || typeof grezzi !== "object" || Array.isArray(grezzi)) {
    return { testi: {}, errori: [`${dove}: segmenti assenti o malformati`] };
  }
  const record = grezzi as Record<string, unknown>;
  const ricevuti = Object.keys(record).sort();
  const chiavi = [...attesi].sort();
  if (JSON.stringify(ricevuti) !== JSON.stringify(chiavi)) {
    errori.push(`${dove}: keyset segmenti diverso dalle attese: attesi {${chiavi.join(",")}}, ricevuti {${ricevuti.join(",")}}`);
  }
  const testi: Record<string, string> = {};
  for (const nome of attesi) {
    const valore = record[nome];
    if (typeof valore !== "string" || !valore.trim()) {
      errori.push(`${dove}.${nome}: segmento assente, vuoto o non testuale`);
      continue;
    }
    testi[nome] = valore;
    if (/[\r\n\u0085\u2028\u2029]/u.test(valore)) errori.push(`${dove}.${nome}: il segmento contiene un a capo o separatore di riga`);
    if (/[\u0000-\u0009\u000B-\u001F\u007F]/u.test(valore)) errori.push(`${dove}.${nome}: il segmento contiene un carattere di controllo`);
    if (/[«»"“”<>]/u.test(valore)) errori.push(`${dove}.${nome}: il segmento contiene dialogo diretto vietato dal contratto`);
    const voceEsplicita = /\b(?:mormora|sussurra|grida|urla)\b/iu.test(valore);
    const discorsoIndiretto = /\b(?:dice|dicono|racconta|fa\s+notare|ribatte|promette|avverte|ammette|sostiene|afferma|confessa|assicura|dichiara|annuncia|risponde|replica|spiega|aggiunge|conclude|ordina|chiede|domanda)\b(?:\s+\p{Lu}[\p{L}’'-]+)?\s+(?:che\b|di\b|dell['’]|a\s+\p{Lu}[\p{L}’'-]+\s+(?:il|lo|la|un|una)\b)/iu.test(valore);
    if (voceEsplicita || discorsoIndiretto) {
      errori.push(`${dove}.${nome}: il segmento contiene parole pronunciate o discorso indiretto vietati dal contratto`);
    }
  }
  const viste = new Map<string, string>();
  for (const nome of attesi) {
    if (!(nome in testi)) continue;
    const firma = normalizzaSegmento(testi[nome]);
    const prima = viste.get(firma);
    if (prima) errori.push(`${dove}: segmenti duplicati «${prima}» e «${nome}»`);
    else viste.set(firma, nome);
  }
  return { testi, errori };
}

function componi(testi: Record<string, string>, ordine: readonly string[]): string {
  return ordine.filter((nome) => nome in testi).map((nome) => testi[nome].trim()).join(" ");
}

function fontiSegmentoAzione(nome: SegmentoAzione, p: PayloadV5, piano: Piano, intenzioneId: string): string[] {
  const comuni = fontiComuni(p, piano);
  if (nome === "preparazione") return comuni;
  if (nome === "esito_precedente" || nome === "risposta_fisica" || nome === "intervento_sensei") {
    return uniche([...comuni, ...fontiEsitoRisolto(p)]);
  }
  if (nome === "nuova_intenzione") return uniche([...comuni, ...fontiIntenzione(p, intenzioneId)]);
  return p.ruolo === "png_attacca" || p.ruolo === "png_difende"
    ? uniche([...comuni, ...fontiIntenzione(p, intenzioneId)])
    : uniche([...comuni, ...fontiEsitoRisolto(p)]);
}

function tracciaSegmenti(testi: Record<string, string>, ordine: readonly string[], fonti: (nome: string) => string[]): string[][] {
  return ordine.flatMap((nome) => Array.from({ length: numeroFrasi(testi[nome] ?? "") }, () => fonti(nome)));
}

/**
 * Convalida e comprime l'output interno 4.5.0. I segmenti non oltrepassano
 * questo confine: al consumer resta la forma pubblica storica.
 */
export function materializzaProvenienzaSegmentata(
  grezza: Record<string, unknown>,
  p: PayloadV5,
  piano: Piano,
): Record<string, unknown> {
  const scelta = grezza.scelta && typeof grezza.scelta === "object" && !Array.isArray(grezza.scelta)
    ? grezza.scelta as Record<string, unknown>
    : {};
  const intenzioneId = typeof scelta.intenzione_id === "string" ? scelta.intenzione_id : "";
  const ordineAzione = segmentiAzioneAttesi(p);
  const bloccoAzione = leggiSegmenti(scelta.segmenti, ordineAzione, "azione");
  const intenzione = p.intenzioni.find((x) => x.id === intenzioneId);
  const attesiEsiti = [...new Set((intenzione?.esiti_possibili ?? []).map(String))].sort();
  const esitiRaw = scelta.esiti && typeof scelta.esiti === "object" && !Array.isArray(scelta.esiti)
    ? scelta.esiti as Record<string, unknown>
    : {};
  const errori = [...bloccoAzione.errori];
  const chiaviEsiti = Object.keys(esitiRaw).sort();
  if (JSON.stringify(attesiEsiti) !== JSON.stringify(chiaviEsiti)) {
    errori.push(`branche segmentate diverse dalle attese: attese {${attesiEsiti.join(",")}}, ricevute {${chiaviEsiti.join(",")}}`);
  }
  const blocchiBranca: Record<string, BloccoSegmenti> = {};
  for (const nome of attesiEsiti) {
    const branca = esitiRaw[nome];
    const contenuto = branca && typeof branca === "object" && !Array.isArray(branca)
      ? (branca as Record<string, unknown>).segmenti
      : null;
    const blocco = leggiSegmenti(contenuto, SEGMENTI_BRANCA, `branca «${nome}»`);
    blocchiBranca[nome] = blocco;
    errori.push(...blocco.errori);
  }
  const azione = canonicalizzaParagrafoWire(componi(bloccoAzione.testi, ordineAzione));
  const esiti = Object.fromEntries(attesiEsiti.map((nome) => [nome, canonicalizzaParagrafoWire(componi(blocchiBranca[nome]?.testi ?? {}, SEGMENTI_BRANCA))]));
  const fontiRamo = fontiBranca(p, piano, intenzioneId);
  return {
    intenzione_id: intenzioneId,
    azione_png: azione,
    esiti,
    versione: p.versione,
    ricevuta_id: p.ricevuta_id,
    provenienza_deterministica: true,
    contratto_segmenti_errori: errori,
    _segmenti_interni: {
      azione: bloccoAzione.testi,
      esiti: Object.fromEntries(attesiEsiti.map((nome) => [nome, blocchiBranca[nome]?.testi ?? {}])),
    },
    perche: "scelta narrativa segmentata entro un'intenzione offerta dal server",
    player_reprise_ids: [],
    fonti_azione: tracciaSegmenti(bloccoAzione.testi, ordineAzione, (nome) => fontiSegmentoAzione(nome as SegmentoAzione, p, piano, intenzioneId)),
    fonti_esiti: Object.fromEntries(attesiEsiti.map((nome) => [nome,
      tracciaSegmenti(blocchiBranca[nome]?.testi ?? {}, SEGMENTI_BRANCA, () => fontiRamo),
    ])),
  };
}

export type TipoAtomo = "esito" | "risposta_fisica" | "movimento" | "nuova_intenzione" | "intervento_sensei" | "assetto_finale";
export type AtomoMeccanico = {
  id: string;
  tipo: TipoAtomo;
  attore: string | null;
  bersaglio: string | null;
  risultato: string | null;
  risposta_fisica: string | null;
  posizione: string | null;
  iniziativa: string | null;
  testo: string;
  fonti: string[];
};
export type ScheletroCiclo = { azione: AtomoMeccanico[]; esiti: Record<string, AtomoMeccanico[]> };

function indiceVariante(seme: string, n: number): number {
  let h = 2166136261;
  for (const ch of seme) h = Math.imul(h ^ ch.codePointAt(0)!, 16777619);
  return Math.abs(h >>> 0) % n;
}

function variante(seme: string, xs: string[]): string {
  return xs[indiceVariante(seme, xs.length)];
}

/** La scelta resta nel dominio server: Luna non riceve né restituisce intenzioni. */
export function selezionaIntenzione(p: PayloadV5): string {
  const ids = p.intenzioni.map((i) => i.id).sort((a, b) => a.localeCompare(b, "it"));
  if (!ids.length) throw new Error("intenzioni assenti");
  return ids[indiceVariante(`${p.ricevuta_id}:${p.ruolo}:intenzione`, ids.length)];
}

function zonaConPreposizione(zona: string | null): string {
  const z = String(zona ?? "").trim();
  if (!z) return "sulla zona indicata";
  if (/^la\s+/iu.test(z)) return `sulla ${z.replace(/^la\s+/iu, "")}`;
  if (/^il\s+/iu.test(z)) return `sul ${z.replace(/^il\s+/iu, "")}`;
  if (/^lo\s+/iu.test(z)) return `sullo ${z.replace(/^lo\s+/iu, "")}`;
  if (/^l['’]/iu.test(z)) return `sull'${z.replace(/^l['’]/iu, "")}`;
  return `alla ${z}`;
}

function attoriEsito(ruolo: string, piano: Piano, branca: boolean): { attaccante: string; difensore: string } {
  const candidatoAttacca = branca ? ruolo === "png_difende" : ruolo === "png_attacca";
  return candidatoAttacca
    ? { attaccante: piano.riferimenti.candidato, difensore: piano.riferimenti.sfidante }
    : { attaccante: piano.riferimenti.sfidante, difensore: piano.riferimenti.candidato };
}

function testoEsito(esito: string, attaccante: string, difensore: string, zona: string | null, seme: string, ancora: string[]): string {
  const z = zonaConPreposizione(zona);
  if (esito === "colpito") return variante(seme, [
    `${difensore} subisce il colpo di ${attaccante} ${z}.`,
    `${difensore} riceve il colpo di ${attaccante} ${z}.`,
    `${difensore} incassa il colpo di ${attaccante} ${z}.`,
  ]);
  if (esito === "sfiorato") return variante(seme, [
    `${difensore} riceve di striscio l'attacco di ${attaccante} ${z}.`,
    `${difensore} subisce appena il passaggio dell'attacco di ${attaccante} ${z}.`,
  ]);
  if (esito === "parato") return variante(seme, [
    `${difensore} para e blocca l'attacco di ${attaccante}.`,
    `La guardia di ${difensore} intercetta e para l'attacco di ${attaccante}.`,
  ]);
  if (esito === "schivato") return variante(seme, [
    `${difensore} schiva l'attacco di ${attaccante} e resta fuori dalla traiettoria.`,
    `L'attacco di ${attaccante} passa mentre ${difensore} lo evita con una schivata.`,
  ]);
  if (esito === "mancato") return variante(seme, [
    `L'attacco di ${attaccante} manca ${difensore} e finisce nel vuoto.`,
    `${attaccante} porta l'attacco a vuoto senza raggiungere ${difensore}.`,
  ]);
  if (esito === "sostituito") {
    const a = ancora[0] ?? "ancora";
    return `${difensore} completa la Sostituzione e l'attacco di ${attaccante} raggiunge il ${a} al suo posto.`;
  }
  if (esito === "copia_colpita") return `L'attacco di ${attaccante} colpisce una copia di ${difensore}, non il corpo originale.`;
  if (esito === "originale_individuato") return `${attaccante} individua il corpo originale di ${difensore} fra le copie.`;
  throw new Error(`esito fuori vocabolario: ${esito}`);
}

function destinatarioIniziativa(raw: unknown, p: PayloadV5, piano: Piano): string {
  const valore = String(raw ?? ((p.scena as Record<string, any>).momento?.tocca_a ?? "")).toLocaleLowerCase("it");
  if (valore === "la prova si chiude" || valore === "prova chiusa") return "prova chiusa";
  if (valore.includes("candidat") || valore.includes(piano.riferimenti.candidato.toLocaleLowerCase("it"))) return piano.riferimenti.candidato;
  if (valore.includes("sfidant") || valore.includes("png") || valore.includes(piano.riferimenti.sfidante.toLocaleLowerCase("it"))) return piano.riferimenti.sfidante;
  throw new Error(`iniziativa fuori vocabolario: ${String(raw ?? "")}`);
}

function atomoEsito(p: PayloadV5, piano: Piano, esito: string, branca: boolean, id: string, intenzioneId = ""): AtomoMeccanico {
  const ref = (p.esito_precedente ?? {}) as Record<string, unknown>;
  const zona = branca ? String((p.fatti_del_ciclo as Record<string, unknown>).bersaglio_previsto ?? "") || null : String(ref.bersaglio ?? "") || null;
  const attori = attoriEsito(p.ruolo, piano, branca);
  return {
    id, tipo: "esito", attore: attori.attaccante, bersaglio: zona, risultato: esito,
    risposta_fisica: null, posizione: null, iniziativa: null,
    testo: testoEsito(esito, attori.attaccante, attori.difensore, zona, `${p.ricevuta_id}:${id}`, piano.riferimenti.ancora_parole),
    fonti: branca ? ["server.scena", "server.intenzione"] : uniche(["server.scena", ...fontiEsitoRisolto(p)]),
  };
}

function atomoRisposta(p: PayloadV5, piano: Piano, branca: boolean, id: string): AtomoMeccanico | null {
  const ref = (p.esito_precedente ?? {}) as Record<string, unknown>;
  const conseguenza = branca ? null : (typeof ref.conseguenza === "string" ? ref.conseguenza.trim() : "");
  if (!conseguenza) return null;
  const { difensore } = attoriEsito(p.ruolo, piano, branca);
  const esito = String(ref.esito ?? "");
  const zona = String(ref.bersaglio ?? "") || null;
  if (/^(?:nessun[ao]|nulla)$/iu.test(conseguenza)) {
    const testo = variante(`${p.ricevuta_id}:${id}`, testiRispostaChiusa(esito, difensore, zona));
    return { id, tipo: "risposta_fisica", attore: difensore, bersaglio: zona, risultato: esito, risposta_fisica: testo,
      posizione: null, iniziativa: null, testo, fonti: ["server.scena", "server.esito", "server.conseguenza"] };
  }
  return {
    id, tipo: "risposta_fisica", attore: difensore, bersaglio: zona,
    risultato: esito || null, risposta_fisica: conseguenza, posizione: null, iniziativa: null,
    testo: variante(`${p.ricevuta_id}:${id}`, [
      `Sul corpo di ${difensore} resta ${conseguenza}.`,
      `${difensore} porta sul corpo ${conseguenza}.`,
      `Il corpo di ${difensore} mostra ${conseguenza}.`,
    ]),
    fonti: uniche(["server.scena", "server.esito", "server.conseguenza"]),
  };
}

function testiRispostaChiusa(esito: string, difensore: string, zona: string | null): string[] {
  const z = zonaConPreposizione(zona);
  const testi: Record<string, string[]> = {
    colpito: [`Il corpo di ${difensore} assorbe l'urto ${z} e si raccoglie per un istante.`, `Su ${difensore}, ${z}, il contatto richiama subito il peso del corpo.`],
    sfiorato: [`La stoffa di ${difensore} vibra appena ${z}, seguendo il passaggio di striscio.`, `${difensore} raccoglie il corpo sotto il contatto leggero ${z}.`],
    parato: [`Gli avambracci di ${difensore} restano raccolti nella guardia che ha fermato l'attacco.`, `${difensore} conserva il peso dietro la guardia dopo la parata.`],
    schivato: [`Il peso di ${difensore} si ricompone dopo la schivata, senza contatto.`, `${difensore} ritrova l'equilibrio fuori dalla traiettoria evitata.`],
    mancato: [`${difensore} conserva l'equilibrio mentre l'attacco si perde nel vuoto.`, `Il corpo di ${difensore} resta intatto davanti al passaggio mancato.`],
    sostituito: [`Il corpo di ${difensore} non è più sulla traiettoria, lasciata all'ancora della Sostituzione.`, `${difensore} riappare con il peso già raccolto dopo la Sostituzione.`],
    copia_colpita: [`La copia di ${difensore} prende il contatto e perde consistenza.`, `Sul posto di ${difensore}, la copia colpita si disfa.`],
    originale_individuato: [`Il corpo originale di ${difensore} resta distinto dalle copie.`, `${difensore} non può più confondere il corpo autentico con le copie.`],
  };
  if (!testi[esito]) throw new Error(`esito fuori vocabolario: ${esito}`);
  return testi[esito];
}

function atomoRispostaBranca(p: PayloadV5, piano: Piano, esito: string, id: string): AtomoMeccanico {
  const { difensore } = attoriEsito(p.ruolo, piano, true);
  const zona = String((p.fatti_del_ciclo as Record<string, unknown>).bersaglio_previsto ?? "") || null;
  const testo = variante(`${p.ricevuta_id}:${id}`, testiRispostaChiusa(esito, difensore, zona));
  return { id, tipo: "risposta_fisica", attore: difensore, bersaglio: zona, risultato: esito, risposta_fisica: testo,
    posizione: null, iniziativa: null, testo, fonti: ["server.scena", "server.intenzione"] };
}

function atomiMovimento(p: PayloadV5, piano: Piano): AtomoMeccanico[] {
  const ref = (p.esito_precedente ?? {}) as Record<string, unknown>;
  const movimenti = Array.isArray(ref.movimenti_autoritativi) ? ref.movimenti_autoritativi as Array<Record<string, unknown>> : [];
  return movimenti.map((m, i) => {
    const attore = m.attore_ref === "actor.opponent" ? piano.riferimenti.sfidante : piano.riferimenti.candidato;
    const direzione = String(m.direzione ?? ""); const ampiezza = String(m.ampiezza ?? "");
    let testo = `${attore} resta sulla misura.`;
    if (direzione === "guadagna terreno") testo = `${attore} avanza di ${ampiezza}.`;
    if (direzione === "cede terreno") testo = `${attore} arretra di ${ampiezza}.`;
    return { id: `movimento_${i}`, tipo: "movimento" as const, attore, bersaglio: null, risultato: null, risposta_fisica: null,
      posizione: `${direzione} · ${ampiezza}`, iniziativa: null, testo,
      fonti: [m.attore_ref === "actor.opponent" ? "server.posizione.esito.sfidante" : "server.posizione.esito.candidato"] };
  });
}

function atomoIntenzione(p: PayloadV5, piano: Piano, intenzioneId: string): AtomoMeccanico {
  const i = p.intenzioni.find((x) => x.id === intenzioneId)!;
  const zona = String((p.fatti_del_ciclo as Record<string, unknown>).bersaglio_previsto ?? "") || null;
  const posizione = [i.movimento, i.ampiezza].filter(Boolean).join(" · ") || null;
  const movimento = i.movimento === "guadagna terreno" ? ` avanzando di ${i.ampiezza}` : i.movimento === "cede terreno" ? ` arretrando di ${i.ampiezza}` : i.movimento === "resta sulla misura" ? " restando sulla misura" : "";
  const testo = p.ruolo === "png_difende"
    ? variante(`${p.ricevuta_id}:${intenzioneId}:intenzione`, [
      `${piano.riferimenti.sfidante} prepara ${i.etichetta}${movimento} davanti all'azione di ${piano.riferimenti.candidato}, senza anticiparne il risultato.`,
      `Davanti all'azione di ${piano.riferimenti.candidato}, ${piano.riferimenti.sfidante} imposta ${i.etichetta}${movimento} e lascia aperto l'esito dello scambio.`,
    ])
    : variante(`${p.ricevuta_id}:${intenzioneId}:intenzione`, [
      `${piano.riferimenti.sfidante} prepara ${i.etichetta}${movimento} e dirige il gesto ${zonaConPreposizione(zona)}, senza chiuderne il risultato.`,
      `${piano.riferimenti.sfidante} apre ${i.etichetta}${movimento}, orientando il gesto ${zonaConPreposizione(zona)} e lasciando a ${piano.riferimenti.candidato} la risposta.`,
    ]);
  return {
    id: "nuova_intenzione", tipo: "nuova_intenzione", attore: piano.riferimenti.sfidante, bersaglio: zona,
    risultato: null, risposta_fisica: null, posizione, iniziativa: piano.riferimenti.candidato,
    testo,
    fonti: uniche(["server.scena", ...fontiIntenzione(p, intenzioneId)]),
  };
}

function atomoAssetto(p: PayloadV5, piano: Piano, branca: boolean, id: string, intenzioneId = ""): AtomoMeccanico {
  const ref = (p.esito_precedente ?? {}) as Record<string, unknown>;
  const misura = String(((p.scena as Record<string, any>).misura ?? {}).descrizione ?? "alla misura stabilita");
  const destinatario = branca
    ? (p.ruolo === "png_attacca" ? piano.riferimenti.candidato : piano.riferimenti.sfidante)
    : (p.ruolo === "png_attacca" ? piano.riferimenti.candidato : destinatarioIniziativa(ref.iniziativa, p, piano));
  const terminale = destinatario === "prova chiusa";
  return {
    id, tipo: "assetto_finale", attore: null, bersaglio: null, risultato: null, risposta_fisica: null,
    posizione: misura, iniziativa: destinatario,
    testo: variante(`${p.ricevuta_id}:${id}`, terminale ? [
      `${piano.riferimenti.candidato} e ${piano.riferimenti.sfidante} restano di fronte, ${misura}, mentre la prova si chiude.`,
      `Di fronte, ${piano.riferimenti.candidato} e ${piano.riferimenti.sfidante} conservano ${misura}; la prova è conclusa.`,
    ] : [
      `${piano.riferimenti.candidato} e ${piano.riferimenti.sfidante} restano di fronte, ${misura}; l'iniziativa torna a ${destinatario}.`,
      `Di fronte, ${piano.riferimenti.candidato} e ${piano.riferimenti.sfidante} conservano ${misura}, con l'iniziativa affidata a ${destinatario}.`,
      `${piano.riferimenti.candidato} e ${piano.riferimenti.sfidante} chiudono lo scambio di fronte, ${misura}, mentre l'iniziativa passa a ${destinatario}.`,
    ]),
    fonti: branca ? ["server.scena", "server.intenzione"] : uniche(["server.scena", ...(p.esito_precedente ? ["server.esito"] : []), ...fontiIntenzione(p, intenzioneId)]),
  };
}

function atomoSensei(p: PayloadV5, piano: Piano): AtomoMeccanico | null {
  if (p.ruolo !== "png_finale" || !piano.riferimenti.sensei) return null;
  const ref = (p.esito_precedente ?? {}) as Record<string, unknown>;
  const finale = String(ref.finale_tipo ?? "");
  const testo = finale === "quattro_round"
    ? `${piano.riferimenti.sensei} interviene e consegna il coprifronte da Genin a ${piano.riferimenti.candidato}.`
    : finale === "sfinimento"
    ? `${piano.riferimenti.sensei} interviene e ferma la prova, rinviando la consegna del coprifronte al momento dell'ingresso.`
    : (() => { throw new Error(`finale_tipo fuori vocabolario: ${finale}`); })();
  return { id: "intervento_sensei", tipo: "intervento_sensei", attore: piano.riferimenti.sensei, bersaglio: null,
    risultato: finale || null, risposta_fisica: null, posizione: null, iniziativa: "prova chiusa", testo,
    fonti: ["server.scena", "server.esito"] };
}

export function costruisciScheletroCiclo(p: PayloadV5, piano: Piano, intenzioneId: string): ScheletroCiclo {
  const intenzione = p.intenzioni.find((x) => x.id === intenzioneId);
  const azione: AtomoMeccanico[] = [];
  if (p.esito_precedente) {
    const ref = p.esito_precedente as Record<string, unknown>;
    azione.push(atomoEsito(p, piano, String(ref.esito ?? ""), false, "esito_precedente"));
    const risposta = atomoRisposta(p, piano, false, "risposta_fisica"); if (risposta) azione.push(risposta);
    azione.push(...atomiMovimento(p, piano));
  }
  if (p.ruolo === "png_attacca" || p.ruolo === "png_difende") azione.push(atomoIntenzione(p, piano, intenzioneId));
  const sensei = atomoSensei(p, piano); if (sensei) azione.push(sensei);
  azione.push(atomoAssetto(p, piano, false, "assetto_finale", intenzioneId));
  const esiti: Record<string, AtomoMeccanico[]> = {};
  for (const esito of [...new Set((intenzione?.esiti_possibili ?? []).map(String))].sort()) {
    const atomi = [atomoEsito(p, piano, esito, true, `branca_${esito}_esito`, intenzioneId)];
    atomi.push(atomoRispostaBranca(p, piano, esito, `branca_${esito}_risposta`));
    atomi.push(atomoAssetto(p, piano, true, `branca_${esito}_assetto`, intenzioneId));
    esiti[esito] = atomi;
  }
  return { azione, esiti };
}

export function chiaviRaccordi(atomi: readonly AtomoMeccanico[]): string[] {
  return atomi.map((_, i) => `r${i}`);
}

type BloccoRaccordi = { testi: Record<string, string>; errori: string[] };
/** Slot chiusi: Luna sceglie gli ID; soltanto la Edge possiede e compone la prosa. */
export const SLOT_RACCORDI = {
  fuoco: {
    luce: "La luce filtra lungo le pareti e lascia sul tatami un chiarore tenue",
    polvere: "La polvere resta sospesa nell'aria e disegna sul tatami una trama sottile",
    ombre: "Le ombre velano la superficie dell'aula e ne rendono più netti i contorni",
    silenzio: "Il silenzio si distende nell'aula e trattiene ogni suono sotto il soffitto",
  },
  contrappunto: {
    riflessi: "mentre i riflessi scorrono sulle pareti e sfumano nella luce più chiara, lasciando una cadenza tenue",
    eco: "mentre un eco breve attraversa l'aula e svanisce sotto il soffitto, dentro un silenzio più netto",
    aria: "mentre l'aria ferma trattiene un fruscio e la polvere torna a raccogliersi in una trama sottile",
    chiarore: "mentre il chiarore disegna una scia opaca e le ombre restano sulla superficie in un velo tenue",
  },
  chiusura: {
    tatami: "il tatami conserva una trama netta nella luce",
    pareti: "le pareti raccolgono riflessi in un velo sottile",
    soffitto: "sotto il soffitto ogni eco si spegne brevemente",
    aula: "nell'aula il silenzio torna fra luce e ombre",
  },
} as const;
type SlotRaccordo = { fuoco: keyof typeof SLOT_RACCORDI.fuoco; contrappunto: keyof typeof SLOT_RACCORDI.contrappunto; chiusura: keyof typeof SLOT_RACCORDI.chiusura; estensione: "breve" | "distesa" };

function componiSlotRaccordo(s: SlotRaccordo): string {
  const parti: string[] = [SLOT_RACCORDI.fuoco[s.fuoco]];
  if (s.estensione === "distesa") parti.push(SLOT_RACCORDI.contrappunto[s.contrappunto]);
  parti.push(SLOT_RACCORDI.chiusura[s.chiusura]);
  return `${parti.join(", ")}.`;
}

function leggiRaccordi(grezzi: unknown, atomi: readonly AtomoMeccanico[], dove: string, piano: Piano): BloccoRaccordi {
  const attesi = chiaviRaccordi(atomi); const errori: string[] = [];
  if (!Array.isArray(grezzi)) return { testi: {}, errori: [`${dove}: raccordi assenti o malformati`] };
  if (grezzi.length !== atomi.length) errori.push(`${dove}: cardinalità raccordi diversa dalle attese`);
  const testi: Record<string, string> = {}; const viste = new Set<string>();
  const keyset = ["chiusura", "contrappunto", "estensione", "fuoco"];
  for (let i = 0; i < atomi.length; i++) {
    const k = attesi[i]; const valore = grezzi[i];
    if (!valore || typeof valore !== "object" || Array.isArray(valore)) { errori.push(`${dove}.${k}: slot assente o malformato`); continue; }
    const slot = valore as Record<string, unknown>;
    if (JSON.stringify(Object.keys(slot).sort()) !== JSON.stringify(keyset)) { errori.push(`${dove}.${k}: keyset slot diverso dal contratto`); continue; }
    if (!(String(slot.fuoco) in SLOT_RACCORDI.fuoco) || !(String(slot.contrappunto) in SLOT_RACCORDI.contrappunto) || !(String(slot.chiusura) in SLOT_RACCORDI.chiusura) || !["breve", "distesa"].includes(String(slot.estensione))) {
      errori.push(`${dove}.${k}: valore slot fuori dominio`); continue;
    }
    const firma = JSON.stringify(slot);
    if (viste.has(firma)) errori.push(`${dove}: raccordo duplicato (${k})`); else viste.add(firma);
    testi[k] = componiSlotRaccordo(slot as unknown as SlotRaccordo);
  }
  return { testi, errori };
}

function componiAtomico(raccordi: Record<string, string>, atomi: readonly AtomoMeccanico[]): string {
  return atomi.flatMap((a, i) => [raccordi[`r${i}`]?.trim(), a.testo]).filter(Boolean).join(" ");
}

function tracciaAtomica(raccordi: Record<string, string>, atomi: readonly AtomoMeccanico[], comuni: string[]): string[][] {
  return atomi.flatMap((a, i) => [
    ...Array.from({ length: numeroFrasi(raccordi[`r${i}`] ?? "") }, () => comuni),
    ...Array.from({ length: numeroFrasi(a.testo) }, () => a.fonti),
  ]);
}

export function materializzaProvenienzaAtomica(grezza: Record<string, unknown>, p: PayloadV5, piano: Piano): Record<string, unknown> {
  const scelta = grezza.scelta && typeof grezza.scelta === "object" && !Array.isArray(grezza.scelta) ? grezza.scelta as Record<string, unknown> : {};
  const intenzioneId = selezionaIntenzione(p);
  const scheletro = costruisciScheletroCiclo(p, piano, intenzioneId);
  const errori: string[] = [];
  if (JSON.stringify(Object.keys(scelta).sort()) !== JSON.stringify(["esiti", "raccordi_azione"])) errori.push("scelta: keyset diverso dal contratto; intenzioni, atomi e campi pubblici non sono accettati dal modello");
  const azioneR = leggiRaccordi(scelta.raccordi_azione, scheletro.azione, "azione", piano); errori.push(...azioneR.errori);
  const rawEsiti = scelta.esiti && typeof scelta.esiti === "object" && !Array.isArray(scelta.esiti) ? scelta.esiti as Record<string, unknown> : {};
  if (JSON.stringify(Object.keys(rawEsiti).sort()) !== JSON.stringify(Object.keys(scheletro.esiti).sort())) errori.push("branche diverse dalle attese");
  const raccordiEsiti: Record<string, BloccoRaccordi> = {};
  for (const [esito, atomi] of Object.entries(scheletro.esiti)) {
    const ramo = rawEsiti[esito] && typeof rawEsiti[esito] === "object" && !Array.isArray(rawEsiti[esito]) ? rawEsiti[esito] as Record<string, unknown> : {};
    if (JSON.stringify(Object.keys(ramo).sort()) !== JSON.stringify(["raccordi"])) errori.push(`branca «${esito}»: keyset diverso dal contratto`);
    const b = leggiRaccordi(ramo.raccordi, atomi, `branca «${esito}»`, piano); raccordiEsiti[esito] = b; errori.push(...b.errori);
  }
  const comuni = fontiComuni(p, piano);
  const azione = componiAtomico(azioneR.testi, scheletro.azione);
  const esiti = Object.fromEntries(Object.entries(scheletro.esiti).map(([k, atomi]) => [k, componiAtomico(raccordiEsiti[k]?.testi ?? {}, atomi)]));
  return {
    intenzione_id: intenzioneId, azione_png: azione, esiti, versione: p.versione, ricevuta_id: p.ricevuta_id,
    provenienza_deterministica: true, contratto_atomico_errori: errori,
    _atomi_interni: scheletro, _raccordi_interni: { azione: azioneR.testi, esiti: Object.fromEntries(Object.entries(raccordiEsiti).map(([k, v]) => [k, v.testi])) },
    perche: "raccordi narrativi entro uno scheletro meccanico immutabile costruito dalla Edge", player_reprise_ids: [],
    fonti_azione: tracciaAtomica(azioneR.testi, scheletro.azione, comuni),
    fonti_esiti: Object.fromEntries(Object.entries(scheletro.esiti).map(([k, atomi]) => [k, tracciaAtomica(raccordiEsiti[k]?.testi ?? {}, atomi, comuni)])),
  };
}

/** Converte l'uscita minima del modello nella forma interna storica. */
export function materializzaProvenienza(
  grezza: Record<string, unknown>,
  p: PayloadV5,
  piano: Piano,
  corrispondeClaim?: (id: string, frase: string) => boolean,
): Record<string, unknown> {
  const scelta = grezza.scelta && typeof grezza.scelta === "object"
    ? grezza.scelta as Record<string, unknown>
    : grezza;
  const intenzioneId = String(scelta.intenzione_id ?? "");
  const azione = canonicalizzaParagrafoWire(String(scelta.azione_png ?? ""));
  const esitiGrezzi = scelta.esiti && typeof scelta.esiti === "object"
    ? scelta.esiti as Record<string, unknown>
    : {};
  const esiti = Object.fromEntries(Object.entries(esitiGrezzi).map(([k, v]) => [k, canonicalizzaParagrafoWire(String(v ?? ""))]));
  const comuni = fontiComuni(p, piano);
  const esitoRisolto = fontiEsitoRisolto(p);
  const intenzione = fontiIntenzione(p, intenzioneId);
  const brancaFonti = fontiBranca(p, piano, intenzioneId);
  const nAzione = numeroFrasi(azione);
  const claimDialogo = piano.player_bridge.claims.filter((c) => c.tipo === "battuta").map((c) => c.id);
  const claimUsati = new Set<string>();
  const fontiPerFrase = Array.from({ length: nAzione }, (_, i) => {
    const frase = azione.split(/(?<=[.!?…])\s+/u)[i] ?? "";
    const dialogo = corrispondeClaim
      ? piano.player_bridge.claims.filter((c) => c.surface_permissions.includes("player_reprise") && corrispondeClaim(c.id, frase)).map((c) => c.id)
      : /«[^»]+»/u.test(frase) ? claimDialogo : [];
    dialogo.forEach((id) => claimUsati.add(id));
    if (p.ruolo === "png_attacca") {
      // Il contratto assegna l'ultima frase al nuovo attacco; le precedenti
      // appartengono all'esito già risolto.
      if (nAzione === 1) return uniche([...comuni, ...esitoRisolto, ...intenzione, ...dialogo]);
      return i === nAzione - 1
        ? uniche([...comuni, ...intenzione, ...dialogo])
        : uniche([...comuni, ...esitoRisolto, ...dialogo]);
    }
    if (p.ruolo === "png_difende") return uniche([...comuni, ...intenzione, ...dialogo]);
    return uniche([...comuni, ...esitoRisolto, ...dialogo]);
  });
  return {
    ...scelta,
    azione_png: azione,
    esiti,
    versione: p.versione,
    ricevuta_id: p.ricevuta_id,
    provenienza_deterministica: true,
    perche: "scelta narrativa entro un'intenzione offerta dal server",
    player_reprise_ids: [...claimUsati],
    fonti_azione: fontiPerFrase,
    fonti_esiti: Object.fromEntries(Object.entries(esiti).map(([k, v]) => [
      k,
      Array.from({ length: numeroFrasi(String(v ?? "")) }, () => brancaFonti),
    ])),
  };
}
