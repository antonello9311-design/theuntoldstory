// exam_genin_ai — il piano narrativo (NARRATORE-UNIFICATO-001)
//
// Dalla ricevuta del server (fatti) e dal dossier dello sfidante (persona) si
// costruisce il piano in otto punti che il Narratore segue e che il validatore
// ricontrolla per riferimenti. Il piano NON contiene prosa: contiene fatti,
// licenze e vincoli. Sequenza (REGOLE_REDAZIONALI_COMBAT_R3 §6 + linee guida §3.3):
//   situazione → ripresa del giocatore → movimento/traiettoria → difesa e
//   risultato del motore → conseguenza fisica → reazione emotiva, tattica e
//   dialogo dello sfidante → ambiente → nuovo assetto e passaggio dell'iniziativa.

import type { PayloadV5 } from "./contratto.ts";
import { claimUsabili, costruisciPlayerBridge, type PlayerBridge } from "./player_bridge.ts";
import { costruisciMemoriaStile, type MemoriaStile } from "./memoria.ts";

export type Punto = { n: number; titolo: string; fatti: Record<string, unknown>; licenze: string[]; vincoli: string[] };
export type Riferimenti = {
  sfidante: string; candidato: string; sensei: string | null;
  bersaglio: string | null;              // zona in parole, se nota per questo ciclo
  zona_parole: string[];                 // sinonimi ammessi per la zona
  bersaglio_precedente: string | null;   // zona dell'esito già deciso (referto)
  zona_precedente_parole: string[];
  ancora_parole: string[];               // sostantivi dell'ancora della Sostituzione
  conseguenza: string | null;
  fiato_in_memoria: boolean;             // un segno già presente parla di fiato: «respiro corto» è continuità, non formula
  battute_gia_dette: string[];           // dagli estratti precedenti
  esempi_scheda: string[];               // frasi tipiche + esempi di voce: timbro, mai da recitare
  player_claim_ids: string[];            // sole licenze player_reprise autorizzate
  player_utterances: string[];           // soli segnali tematici chiusi: il testo letterale non attraversa il ponte
  player_ha_domanda: boolean;
  fonti_disponibili: string[];            // vocabolario chiuso della traccia frase-per-fonte
  memoria_stile: MemoriaStile;            // non autoritativa: serve solo all'esclusione
  esito_precedente: string | null;
  finale_tipo: string | null;
};
export type Piano = {
  versione: number;
  ruolo: string;
  punti: Punto[];
  riferimenti: Riferimenti;
  stato_sfidante: Record<string, unknown>;
  player_bridge: PlayerBridge;
};

const ZONE: Record<string, string[]> = {
  spalla: ["spalla"], braccio: ["braccio", "avambraccio", "gomito", "bicipite"], torace: ["torace", "petto", "sterno", "costato", "costole"],
  fianco: ["fianco", "costato"], ventre: ["ventre", "stomaco", "addome", "pancia", "diaframma"], gamba: ["gamba", "coscia", "ginocchio", "stinco", "polpaccio"],
  viso: ["viso", "volto", "faccia", "zigomo", "mascella", "labbro", "naso", "mento", "tempia", "guancia"], mente: ["mente", "sguardo", "occhi", "vista"],
};

export function zonaParole(bersaglio: string | null): string[] {
  if (!bersaglio) return [];
  const b = bersaglio.toLowerCase();
  for (const [k, v] of Object.entries(ZONE)) if (b.includes(k)) return v;
  return [];
}

export function ancoraParole(ancora: Record<string, unknown> | null | undefined): string[] {
  if (!ancora) return [];
  const id = String(ancora.id ?? "");
  const map: Record<string, string[]> = {
    palo_spirale: ["palo"], palo_corda: ["palo"], palo_alto: ["palo"],
    cassa_piccola: ["cassa"], cassa_grande: ["cassa"], cavalletto_ferro: ["cavalletto"],
    cavalletto_vicino: ["cavalletto"], cavalletto_secondo: ["cavalletto"], cilindro_blu: ["cilindro", "sacco"],
    rotoli_stuoia: ["rotol", "stuoia"],
  };
  return map[id] ?? [String(ancora.oggetto ?? "").split(" ").filter((w) => w.length > 4)[0] ?? "supporto"];
}

function battute(testo: string): string[] {
  return [...String(testo ?? "").matchAll(/«([^»]+)»/g)].map((m) => m[1].trim());
}

export function normalizzaBattuta(b: string): string {
  return b.toLowerCase().replace(/[^\p{L}\p{N}\s]/gu, "").replace(/\s+/g, " ").trim();
}

function esempiDalDossier(d: Record<string, unknown>): string[] {
  const out: string[] = [];
  const ft = d.frasi_tipiche;
  if (Array.isArray(ft)) for (const f of ft) if (typeof f === "string") out.push(...battute(`«${f}»`), f);
  const voce = d.voce as Record<string, unknown> | undefined;
  if (voce && typeof voce === "object") for (const v of Object.values(voce)) if (typeof v === "string") out.push(...battute(v));
  const tps = d.tattica_per_stato as Record<string, unknown> | undefined;
  if (tps && typeof tps === "object") for (const v of Object.values(tps)) if (typeof v === "string") out.push(...battute(v));
  return [...new Set(out.map(normalizzaBattuta).filter((x) => x.length >= 4))];
}

/** Lo stato dello sfidante letto dai fatti del server (R6). */
function statoSfidante(p: PayloadV5, sfidante: string, candidato: string): Record<string, unknown> {
  const scena = p.scena as Record<string, any>;
  const cond = scena.condizione ?? {};
  const segni = Array.isArray(scena.segni) ? scena.segni as Record<string, any>[] : [];
  const storia = Array.isArray(scena.storia) ? scena.storia as Record<string, any>[] : [];
  const suSfidante = segni.filter((s) => String(s.chi) === sfidante);
  const suCandidato = segni.filter((s) => String(s.chi) === candidato);
  const ultimoSegno = suSfidante.length ? suSfidante[suSfidante.length - 1] : null;
  const attacchiSfidante = storia.filter((s) => String(s.chi) === sfidante);
  const ultimiDue = attacchiSfidante.slice(-2);
  const pianoNonRende = ultimiDue.length === 2 && ultimiDue.every((s) => /a vuoto|di striscio/.test(String(s.esito)));
  const ultima = storia.length ? storia[storia.length - 1] : null;
  const copiaColpita = !!ultima && String(ultima.chi) === sfidante && /copia/.test(String(ultima.esito));
  const chiavi: string[] = [];
  if (ultimoSegno && /serio|grave|fuori/.test(String(ultimoSegno.gravita ?? ""))) chiavi.push("colpo_serio");
  if (pianoNonRende) chiavi.push("piano_che_non_rende");
  if (copiaColpita) chiavi.push("copia_colpita");
  return {
    fiato: cond.sfidante?.fiato ?? null, chakra: cond.sfidante?.chakra ?? null, copie: cond.sfidante?.copie ?? null,
    fiato_candidato: cond.candidato?.fiato ?? null, chakra_candidato: cond.candidato?.chakra ?? null,
    colpi_subiti: suSfidante, colpi_inflitti: suCandidato,
    ultimo_colpo_subito: ultimoSegno,
    voci_di_tattica_attive: chiavi,
    nota: chiavi.length
      ? "applica le voci di `dossier.tattica_per_stato` elencate in voci_di_tattica_attive; la prosa deve far leggere il perché della mossa"
      : "nessuno stato particolare: la condotta segue `dossier.condotta` (quando_e_avanti / quando_e_indietro secondo il bilancio di fiato e colpi) e lo scopo dello sfidante",
  };
}

export function costruisciPiano(p: PayloadV5): Piano {
  const scena = p.scena as Record<string, any>;
  const dossier = p.dossier as Record<string, any>;
  const sfidante = String(dossier.nome ?? scena.sfidante?.nome ?? "lo sfidante");
  const candidato = String(scena.candidato?.nome ?? "il candidato");
  const sensei = p.sensei && typeof p.sensei === "object" ? String((p.sensei as any).nome ?? "") || null : null;
  const ref = (p.esito_precedente ?? null) as Record<string, any> | null;
  const fatti = (p.fatti_del_ciclo ?? {}) as Record<string, any>;
  const luogo = scena.luogo ?? {};
  const misura = scena.misura ?? {};
  const momento = scena.momento ?? {};
  const stato = statoSfidante(p, sfidante, candidato);
  const memoria = costruisciMemoriaStile(p.stile_precedente);
  const battuteDette = memoria.battute.map(normalizzaBattuta);
  const playerBridge = costruisciPlayerBridge(p);
  const playerClaims = claimUsabili(playerBridge);
  const segnaliDialogoCandidato = playerClaims.filter((c) => c.tipo === "battuta").map((c) => c.action);
  const movimentiAutoritativi = Array.isArray(ref?.movimenti_autoritativi) ? ref.movimenti_autoritativi as Array<Record<string, unknown>> : [];
  const fontiDisponibili = [
    "server.scena", "server.intenzione", "persona.sfidante", "memoria.stile",
    ...(ref ? ["server.esito"] : []),
    ...(movimentiAutoritativi.some((m) => m.attore_ref === "actor.candidate") ? ["server.posizione.esito.candidato"] : []),
    ...(movimentiAutoritativi.some((m) => m.attore_ref === "actor.opponent") ? ["server.posizione.esito.sfidante"] : []),
    ...(p.intenzioni.some((i) => i.movimento || i.ampiezza) ? ["server.posizione.intenzione"] : []),
    ...((ref?.conseguenza || (Array.isArray(scena.segni) && scena.segni.length)) ? ["server.conseguenza"] : []),
    ...playerClaims.map((c) => c.id),
  ];

  const ruolo = p.ruolo;
  const bersaglio: string | null = (ruolo === "png_esito" || ruolo === "png_finale")
    ? (ref?.bersaglio ?? null)
    : (fatti.bersaglio_previsto ?? null);
  const ancora = (ruolo === "png_esito" || ruolo === "png_finale") ? (ref?.ancora ?? null) : (fatti.ancora_sostituzione ?? null);
  const conseguenza: string | null = ref?.conseguenza ?? null;

  const licenzaGiocatore = [
    "si può riprendere soltanto un claim con surface_permissions=player_reprise, dichiarandone l'id in player_reprise_ids e nella traccia frase-per-fonte",
    "ogni claim resta un gesto o tentativo del candidato: contatto, esito, movimento compiuto e conseguenza vengono soltanto dal server",
    "la ripresa usa parole proprie: non ricopia il claim e non cita il parlato del candidato; lo sfidante reagisce soltanto al tema chiuso del segnale dialogico con gesto, postura o scelta tattica, senza parole",
  ];

  const punti: Punto[] = [];
  punti.push({ n: 1, titolo: "situazione", fatti: {
    luogo: { dove: luogo.dove, luce: luogo.luce, suolo: luogo.suolo, aria: luogo.aria, pareti: luogo.pareti, bordo: luogo.bordo },
    misura: misura, momento: momento, iniziativa_prima: momento.tocca_a ?? null,
    segni_gia_presenti: scena.segni ?? [],
    sfidante_come_appare: dossier.aspetto ?? null,
  }, licenze: ["la scena è presente in ogni testo: la luce che taglia i corpi, il suolo sotto i piedi, un suono, l'aria — intrecciata al gesto, mai come catalogo", "lo sfidante si vede: un dettaglio fisico preso da sfidante_come_appare, scelto perché cambia con lo stato (sudore, capelli, mani, occhi, stoffa)"], vincoli: ["nessun numero, nessuna misura in metri: le distanze si dicono con il corpo (addosso, a un passo, dall'altra parte del tatami)"] });

  punti.push({ n: 2, titolo: "ripresa del giocatore", fatti: { player_bridge: playerBridge, segnali_dialogo_candidato: segnaliDialogoCandidato },
    licenze: [...licenzaGiocatore, segnaliDialogoCandidato.length ? "il candidato HA PARLATO: lo sfidante reagisce al tema chiuso del segnale (movimento/distanza, condizione, intenzioni, capacità o provocazione) esclusivamente con gesto, postura o scelta tattica, senza inventare il contenuto letterale" : "il candidato non ha parlato: lo sfidante agisce in silenzio raccontato"],
    vincoli: ["dialogo sospeso per tutti: nessuna battuta, parola pronunciata, caporale, virgoletta o discorso diretto o indiretto", "i claim elencati in soppressi non arrivano alla prosa"] });

  if (ruolo === "png_difende") {
    punti.push({ n: 3, titolo: "l'attacco del candidato e la scelta dello sfidante", fatti: {
      attacca: fatti.attacca, difende: fatti.difende, bersaglio_previsto: bersaglio, nota_bersaglio: fatti.nota_bersaglio,
      reazioni_offerte: p.intenzioni.map((i) => ({ id: i.id, etichetta: i.etichetta })),
    }, licenze: ["la reazione scelta nasce dalla tattica (R6): il piano lo dice, la prosa lo fa leggere in un gesto coerente e leggibile"], vincoli: ["azione_png racconta SOLO il tentativo dello sfidante, ancora irrisolto: nessun esito, nessun contatto compiuto"] });
    punti.push({ n: 4, titolo: "le branche: gli esiti dipendono dall'intenzione scelta", fatti: { esiti_per_intenzione: p.intenzioni.map((i) => ({ intenzione_id: i.id, esiti_possibili: i.esiti_possibili })), ancora_se_sostituzione: ancora },
      licenze: ["in «colpito» e «sfiorato» il colpo arriva sulla zona prevista, con una conseguenza coerente con la zona e non quantificata (niente «grave», niente «lieve» detti dal Narratore)", "in «sostituito» il colpo raggiunge l'ancora indicata, che si segna, e lo sfidante riappare dove l'ancora dice"],
      vincoli: ["ogni branca chiude lo scambio e restituisce l'iniziativa a chi tocca; nessuna branca apre un attacco nuovo"] });
  } else if (ruolo === "png_attacca") {
    punti.push(ref
      ? { n: 3, titolo: "l'esito dell'attacco del candidato (già deciso dal campo)", fatti: ref, licenze: ["si racconta per intero: difesa tentata dallo sfidante, risultato del motore, dove è arrivato il colpo, conseguenza, postura, movimento"], vincoli: ["l'esito è quello del referto e nessun altro; una ferita non nominata nel referto non esiste (R4)"] }
      : { n: 3, titolo: "nessun esito precedente", fatti: {}, licenze: ["si apre direttamente il nuovo attacco dello sfidante"], vincoli: ["non inventare né premettere un esito che il server non ha fornito"] });
    punti.push({ n: 4, titolo: "il nuovo attacco dello sfidante", fatti: {
      intenzioni_offerte: p.intenzioni.map((i) => ({
        id: i.id, etichetta: i.etichetta, genere: i.genere,
        movimento: i.movimento ?? null, ampiezza_autoritativa: i.ampiezza ?? null,
      })),
      bersaglio_dell_attacco: fatti.bersaglio_previsto ?? null, nota: fatti.nota_bersaglio,
    }, licenze: ["la mossa nasce dalla tattica e dallo stato (R6): dopo un colpo serio, un piano che non rende, una copia colpita — il dossier dice come cambia"], vincoli: ["l'attacco resta IRRISOLTO: la frase che lo apre dice arto, lato, traiettoria e dove mira; l'ultima frase non contiene verbi d'esito (colpisce, manca, para, schiva…)", "la difesa spetta al candidato: non si racconta"] });
  } else if (ruolo === "png_esito") {
    punti.push({ n: 3, titolo: "la difesa del candidato e l'esito (già deciso dal campo)", fatti: ref ?? {}, licenze: ["si riprende la difesa scritta dal candidato come gesto e la si porta all'esito del referto"], vincoli: ["nessun nuovo attacco dello sfidante; l'iniziativa torna al candidato"] });
    punti.push({ n: 4, titolo: "il corpo", fatti: { bersaglio, conseguenza, gravita: ref?.gravita ?? null, postura: ref?.postura_difensore ?? null }, licenze: ["la conseguenza si scrive dalla classe del referto e dalla zona: un segno sulla pelle o sulla stoffa, un livido che sale, un arto che pesa, il fiato solo per torace e ventre"], vincoli: ["mai la stessa chiusura di un esito precedente (R3)"] });
  } else {
    punti.push({ n: 3, titolo: "l'ultimo esito (già deciso dal campo)", fatti: ref ?? {}, licenze: ["si racconta per intero prima dell'intervento del Sensei"], vincoli: [] });
    punti.push({ n: 4, titolo: "il Sensei chiude la prova", fatti: { sensei: p.sensei, finale_tipo: ref?.finale_tipo ?? null, senza_forze: ref?.senza_forze ?? null, chiusura_richiesta: ref?.chiusura_richiesta ?? null },
      licenze: ["se finale_tipo è «sfinimento»: il Sensei ferma con un gesto chi non ha più forze e la consegna del coprifronte resta rinviata al momento dell'ingresso; se è «quattro_round»: il Sensei mostra di aver visto a sufficienza e consegna il coprifronte da Genin al candidato"],
      vincoli: ["il coprifronte compare SOLO qui, come consegna; nessun verdetto sul valore del candidato oltre il gesto del Sensei; lo sfidante chiude secondo la sua voce (al_congedo) soltanto con postura, sguardo o gesto, senza parole"] });
  }

  punti.push({ n: 5, titolo: "conseguenza fisica", fatti: {
    bersaglio, conseguenza, firma_fisica_sfidante: dossier.firma_fisica ?? null,
    regola: "chi incassa risponde col corpo secondo zona e gravità: lo sfidante con la sua firma fisica, il candidato con un gesto visibile e MAI con una voce",
  }, licenze: ["la reazione fisica dello sfidante dopo un colpo mostra persona e stato senza parole: ritmo, postura, sguardo e gesto conservano densità e carattere"], vincoli: ["«spezza il fiato» e simili solo se la conseguenza del referto parla di fiato", "nessuna formula già usata in questa prova", "nessun verso o parola pronunciata"] });

  punti.push({ n: 6, titolo: "reazione, tattica e voce dello sfidante", fatti: {
    scopo: dossier.scopo, stato: stato, tattica_per_stato: dossier.tattica_per_stato, condotta: dossier.condotta, reazioni: dossier.reazioni,
    voce: dossier.voce, registro: dossier.registro, ritmo: dossier.ritmo, tratti: dossier.tratti,
  }, licenze: ["la voce dello sfidante si rende senza dialogo: cadenza dei gesti, postura, sguardo, respiro e scelta tattica ne conservano carattere e intensità", "il silenzio, se è il suo, si racconta con la postura"], vincoli: ["dialogo sospeso: nessuna battuta, caporale, virgoletta o parola pronunciata", "niente sarcasmo, niente lezioni, niente verdetti sul candidato"] });

  punti.push({ n: 7, titolo: "ambiente", fatti: { ancore: luogo.ancore ?? [], ancora_di_questo_ciclo: ancora, luce: luogo.luce, pareti: luogo.pareti, bordo: luogo.bordo, movimenti_autoritativi: movimentiAutoritativi, non_esistono: luogo.non_esistono ?? [] },
    licenze: ["l'ambiente reagisce al gesto: polvere, luce, un attrezzo urtato; l'ancora della Sostituzione è quella indicata e resta segnata"], vincoli: ["nessun oggetto che non sia nell'elenco delle ancore o nella descrizione dell'aula", "il bordo del tatami è il limite: chi lo raggiunge lo sente sotto i piedi, nessuno lo oltrepassa"] });

  punti.push({ n: 8, titolo: "nuovo assetto, memoria e passaggio dell'iniziativa", fatti: { iniziativa: ref?.iniziativa ?? momento.tocca_a ?? null, postura_difensore: ref?.postura_difensore ?? null, misura_dopo: misura.descrizione ?? null, memoria_di_esclusione: memoria },
    licenze: ["l'ultima frase chiude sul quadro nuovo: mostra dove restano i due e a chi torna l'iniziativa, facendo vedere che cosa è cambiato nello spazio, nella pressione o nel controllo"], vincoli: ["nessun comando al candidato, nessuna domanda retorica, nessun verdetto", "nessun carattere numerico o nota di stesura, correzione, debug, errore o validazione", "non riusare formule, chiusure o immagini della memoria; la memoria non autorizza fatti"] });

  return {
    versione: 1, ruolo, punti,
    riferimenti: {
      sfidante, candidato, sensei, bersaglio, zona_parole: zonaParole(bersaglio),
      bersaglio_precedente: ref?.bersaglio ?? null, zona_precedente_parole: zonaParole(ref?.bersaglio ?? null),
      ancora_parole: ancoraParole(ancora),
      conseguenza, fiato_in_memoria: (Array.isArray(scena.segni) ? scena.segni as any[] : []).some((x) => /fiato/iu.test(String(x?.conseguenza ?? ""))),
      battute_gia_dette: battuteDette, esempi_scheda: esempiDalDossier(dossier),
      player_claim_ids: playerClaims.map((c) => c.id),
      player_utterances: segnaliDialogoCandidato,
      player_ha_domanda: playerBridge.ha_domanda,
      fonti_disponibili: fontiDisponibili,
      memoria_stile: memoria,
      esito_precedente: ref?.esito ?? null, finale_tipo: ref?.finale_tipo ?? null,
    },
    stato_sfidante: stato,
    player_bridge: playerBridge,
  };
}
