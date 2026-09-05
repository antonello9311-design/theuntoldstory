// Ponte del giocatore: il testo libero è sempre non fidato. L'adapter estrae
// soltanto dettagli riprendibili e li confronta con i fatti del server prima
// di concedere la licenza player_reprise.

import type { PayloadV5 } from "./contratto.ts";

export const TIPI_PLAYER_CLAIM = [
  "manovra_tentata", "difesa_tentata", "postura", "traiettoria",
  "bersaglio_dichiarato", "battuta", "vincolo_autoimposto",
] as const;

export type TipoPlayerClaim = typeof TIPI_PLAYER_CLAIM[number];
export type PlayerClaim = {
  id: string;
  tipo: TipoPlayerClaim;
  status: "player_claim";
  actor_ref: "actor.candidate";
  action: string;
  surface_permissions: ["player_reprise"];
  verbatim: false;
};
export type PlayerClaimSoppresso = {
  tipo: TipoPlayerClaim | "auto_risoluzione" | "non_autorizzabile";
  motivo: "auto_risoluzione" | "conflitto_bersaglio" | "conflitto_movimento" | "voce_non_letterale" | "istruzione_operativa" | "vuoto";
};
export type PlayerBridge = {
  versione: "player_bridge/1.0";
  raw_action_text_available: false;
  licenza: "player_reprise";
  claims: PlayerClaim[];
  soppressi: PlayerClaimSoppresso[];
  ha_domanda: boolean;
};

const RE_BATTUTE = /«([^»]{2,240})»|“([^”]{2,240})”|"([^"\n]{2,240})"|<([^<>\n]{2,240})>/gu;
const RE_AUTO_ESITO = /\b(?:lo|la|li|le)?\s*(?:colpisc\w*|ferisc\w*|atterr\w*|stordisc\w*|raggiung\w*|manda\s+a\s+terra|fa\s+cadere|spezza\s+il\s+fiato|toglie\s+il\s+fiato)\b/iu;
const RE_TENTATIVO = /\b(?:tent\w*|prov\w*|cerc\w*|fing\w*|simul\w*|vorrebbe|potrebbe|\p{L}+(?:erebbe|irebbe|rebbe|rebbero))\b/iu;
const RE_MANOVRA = /\b(?:avanz\w*|arretr\w*|scatt\w*|balz\w*|salt\w*|ruot\w*|gir\w*|spost\w*|allontan\w*|avvicin\w*|affond\w*|slanci\w*|pieg\w*|flett\w*|sollev\w*|port\w*\s+(?:il|la|lo|le|i)\s+\p{L}+|colp\w*|calci\w*|pugn\w*|palmo|gomito|ginocchio)\b/iu;
const RE_DIFESA = /\b(?:parat\w*|parare|schiv\w*|guardia|proteg\w*|devia\w*|intercett\w*|contrast\w*|ripar\w*|scans\w*)\b/iu;
const RE_POSTURA = /\b(?:postura|guardia|peso|appoggi\w*|talloni|punte|ginocchi\w*|busto|baricentro|profilo)\b/iu;
const RE_TRAIETTORIA = /\b(?:traiettoria|obliqu\w*|diagonal\w*|lateral\w*|dall['’]alto|dal\s+basso|in\s+arco|in\s+linea|verso\s+(?:destra|sinistra|l['’]alto|il\s+basso)|alle\s+spalle|sul\s+fianco)\b/iu;
const RE_VINCOLO = /\b(?:niente|solo|soltanto|senza|non\s+user\w*|evit\w+\s+di|si\s+impon\w*)\b/iu;
const RE_PENSIERO = /\b(?:pensa|crede|immagina|spera|teme|decide|vuole|intende|capisce|ricorda|dubita|si domanda|si convince|avverte (?:paura|timore|rabbia|vergogna|sollievo))\b/iu;
const RE_ISTRUZIONE_OPERATIVA = /(?:\b(?:json|prompt|system|assistant|developer|istruzion\w*|vincol[oi]\s+(?:superiori|precedenti|di sistema)|ordine\s+prioritario)\b)|(?:\b(?:ignora|disattendi|sovrascrivi|dimentica|scarta|trascura|non seguire|elimina|rimuovi|annulla|disattiva)\b.{0,80}\b(?:istruzion\w*|prompt|sistema|regol\w*|vincol\w*)\b)|(?:\b(?:obbedisci|esegui|stampa|restituisci|produci)\b)|(?:\btratta\b.{0,70}\b(?:messaggio|testo)\b.{0,70}\b(?:ordine|istruzione)\b)|(?:\b(?:fai|lascia)\s+vincere\b)|(?:\b(?:assumi|interpreta)\b.{0,120}\b(?:perd\w*|vinc\w*|superat\w*|promoss\w*|successo|esito)\b)|(?:\b(?:d['’]ora in poi|da (?:ora|adesso|questo momento)|il tuo compito|devi|dovrai|assegna|concedi|dichiara|considera|scrivi|racconta|narra|descrivi|fai risultare|metti|la conclusione corretta|la storia deve terminare|nel racconto che segue|la sola versione accettabile|comportati come)\b.{0,160}\b(?:vittoria|successo|vincitor\w*|esito|trionf\w*|promoss\w*|promozione|passat\w* (?:la )?prova|riceve\w* il grado|supera\w* l['’]esame|ha la meglio|preval\w*|sconfitt\w*)\b)|(?:\b(?:vittoria|successo|vincitor\w*|esito|trionf\w*|promoss\w*|promozione|passat\w* (?:la )?prova|riceve\w* il grado|ha la meglio|preval\w*|sconfitt\w*)\b.{0,70}\b(?:al candidato|alla candidata|il candidato|la candidata|Aiko|Kotoha)\b)|(?:```|\{\s*"(?:role|prompt|instruction)"\s*:)/iu;

const ZONE: Array<{ nome: string; re: RegExp }> = [
  { nome: "viso", re: /\b(?:viso|volto|faccia|zigomo|mascella|labbro|naso|mento|tempia|guancia)\b/iu },
  { nome: "spalla", re: /\bspall\w*\b/iu },
  { nome: "braccio", re: /\b(?:braccio|avambraccio|gomito|bicipite|polso|mano)\b/iu },
  { nome: "torace", re: /\b(?:torace|petto|sterno|costato|costole)\b/iu },
  { nome: "ventre", re: /\b(?:ventre|stomaco|addome|pancia|diaframma)\b/iu },
  { nome: "fianco", re: /\bfianco\b/iu },
  { nome: "gamba", re: /\b(?:gamba|coscia|ginocchio|stinco|tibia|polpaccio|caviglia|piede)\b/iu },
];

function pulisci(t: string): string {
  return t
    .replace(/\b\d+(?:[.,]\d+)?\s*(?:m|metri?|cm|centimetri?|passi?)\b/giu, " una misura dichiarata ")
    .replace(/\b\d+\b/g, " ")
    .replace(/\s+/g, " ")
    .replace(/^[,;:\-–—\s]+|[,;:\-–—\s]+$/g, "")
    .trim()
    .slice(0, 260);
}

function segnale(re: RegExp, t: string): string {
  const m = t.match(re)?.[0] ?? "gesto dichiarato";
  return pulisci(m).slice(0, 80);
}

function zona(t: string): string | null {
  return ZONE.find((z) => z.re.test(t))?.nome ?? null;
}

function bersaglioDichiarato(t: string): string | null {
  // Solo verbi che governano davvero il bersaglio. Parti del corpo e
  // preposizioni generiche ("gomito contro il proprio fianco") non possono
  // cancellare una zona già governata da "mira/dirige/porta il colpo".
  const governo = /\b(?:mir\w*|punt\w*|dirig\w*|indirizz\w*|bersagli\w*|attacc\w*|colp\w*|sferr\w*|porta(?:re)?\s+(?:(?:il|lo|la|un|una)\s+)?(?:colpo|pugno|calcio|palmo|gomito|ginocchio))\b/giu;
  let scelto: string | null = null;
  for (const verbo of t.matchAll(governo)) {
    const inizio = (verbo.index ?? 0) + verbo[0].length;
    const dopo = t.slice(inizio, inizio + 120).split(/\s+e\s+(?:tiene|stringe|mantiene|piega|solleva)\w*\b/iu, 1)[0];
    if (/^punt/iu.test(verbo[0]) && /^\s+(?:il|lo)\s+sguardo\b/iu.test(dopo)) continue;
    const dopoBersaglio = dopo.replace(/^\s+(?:(?:con\s+(?:(?:il|lo|la|un|una)\s+)?(?:propri[oa]\s+)?|col\s+))(?:viso|volto|faccia|spalla|braccio|avambraccio|gomito|torace|petto|ventre|fianco|gamba|coscia|ginocchio|piede)\b/iu, " ");
    const candidati = ZONE.flatMap((z) => {
      const diretti = [...dopoBersaglio.matchAll(new RegExp(`\\b(?:verso|contro|alla|al|sulla|sul)\\s+(?:(?:il|lo|la|un|una)\\s+)?(${z.re.source.replace(/^\\b|\\b$/g, "")})`, "giu"))]
        .map((m) => ({ nome: z.nome, indice: m.index ?? 0 }));
      const diretto = dopoBersaglio.match(new RegExp(`^\\s+(?:(?:il|lo|la)\\s+)?(${z.re.source.replace(/^\\b|\\b$/g, "")})`, "iu"));
      return [...(diretto ? [{ nome: z.nome, indice: diretto.index ?? 0 }] : []), ...diretti];
    }).filter((m) => !/\b(?:sguardo|occhi)\b[^.;,]{0,50}$/iu.test(dopoBersaglio.slice(0, m.indice))).sort((a, b) => a.indice - b.indice);
    if (candidati.length) scelto = candidati.at(-1)!.nome;
  }
  if (!scelto) {
    const verso = t.match(/\bverso\s+(?:(?:il|lo|la|un|una)\s+)?(?:il\s+)?([\p{L}’']+)/iu)?.[0] ?? "";
    scelto = zona(verso);
  }
  return scelto;
}

function segnaleDialogo(t: string, domanda: boolean): string {
  if (!domanda) {
    const sfida = /\b(?:sfid\w*|provoc\w*|vinc\w*|perd\w*|prend\w*|ferm\w*|mostr\w*|vediamo|fammi\s+vedere|prova\w*)\b/iu.test(t);
    const resiste = /\b(?:non\s+(?:arretr\w*|ced\w*|moll\w*|ferm\w*)|rest\w*\s+(?:qui|in piedi)|continu\w*)\b/iu.test(t);
    if (sfida && resiste) return "il candidato sfida lo sfidante a mostrare una risposta migliore e dichiara che non intende cedere";
    if (sfida) return "il candidato chiede allo sfidante di mostrare concretamente una risposta migliore";
    if (resiste) return "il candidato dichiara che non intende cedere o arretrare";
    return "il candidato pronuncia una battuta generica";
  }
  if (/\b(?:paura|timore|dolore|male|stanc\w*|fiato|ferit\w*|senti|provi)\b/iu.test(t)) return "il candidato pone una domanda sulla condizione dello sfidante";
  if (/\b(?:dove|andar\w*|vai|va[di]?|avanz\w*|arretr\w*|muov\w*|spost\w*|distanza|vicin\w*|lontan\w*)\b/iu.test(t)) return "il candidato pone una domanda sul movimento o sulla distanza";
  if (/\b(?:perch[eé]|continu\w*|vuoi|intendi|scopo|piano|farai|fai)\b/iu.test(t)) return "il candidato pone una domanda sulle intenzioni dello sfidante";
  if (/\b(?:come|puoi|riesci|saprai|capace)\b/iu.test(t)) return "il candidato pone una domanda sulle capacità dello sfidante";
  return "il candidato pone una domanda generica";
}

function segnalePostura(t: string): string {
  if (/\b(?:abbass\w*|basso|pieg\w*)\b.{0,30}\b(?:baricentro|ginocchi\w*)\b|\b(?:baricentro|ginocchi\w*)\b.{0,30}\b(?:abbass\w*|basso|pieg\w*)\b/iu.test(t)) return "mantiene il baricentro basso";
  if (/\b(?:alz\w*|sollev\w*|alto)\b.{0,30}\bbaricentro\b|\bbaricentro\b.{0,30}\b(?:alz\w*|sollev\w*|alto)\b/iu.test(t)) return "mantiene il baricentro alto";
  if (/\bpeso\b.{0,24}\b(?:avanti|anteriore)\b/iu.test(t)) return "mantiene il peso in avanti";
  if (/\bpeso\b.{0,24}\b(?:indietro|posteriore)\b/iu.test(t)) return "mantiene il peso indietro";
  return `assume o cerca una postura centrata su ${segnale(RE_POSTURA, t)}`;
}

function segnaleManovra(t: string): string {
  if (/\bpugn\w*\b/iu.test(t)) return /\bfrontal\w*\b/iu.test(t) ? "porta un pugno frontale" : "porta un pugno";
  if (/\bcalci\w*|\bcalcio\b/iu.test(t)) return "porta un calcio";
  if (/\bpalmo\b/iu.test(t)) return "porta un colpo di palmo";
  if (/\bgomito\b/iu.test(t)) return "porta il gomito";
  if (/\bginocchiat\w*\b/iu.test(t)) return "porta il ginocchio";
  if (/\bavanz\w*|\bscatt\w*|\bslanci\w*/iu.test(t)) return "avanza di scatto";
  return `tenta una manovra di tipo ${segnale(RE_MANOVRA.test(t) ? RE_MANOVRA : RE_TENTATIVO, t)}`;
}

function segnaleTraiettoria(t: string): string {
  if (/\bfrontal\w*\b/iu.test(t)) return "segue una traiettoria frontale e stretta";
  if (/\bdiagonal\w*|\bobliqu\w*/iu.test(t)) return "segue una traiettoria diagonale";
  if (/\blateral\w*/iu.test(t)) return "segue una traiettoria laterale";
  if (/\bdall['’]alto/iu.test(t)) return "scende dall'alto";
  if (/\bdal basso/iu.test(t)) return "sale dal basso";
  return `dichiara una traiettoria ${segnale(RE_TRAIETTORIA, t)}`;
}

function segnaleVincolo(t: string): string {
  if (/\bchakra\b/iu.test(t)) return "rinuncia a usare chakra";
  if (/\b(?:armi?|kunai|shuriken|spada)\b/iu.test(t)) return "rinuncia a usare armi";
  if (/\btecnic\w*\b/iu.test(t)) return "rinuncia a usare tecniche";
  return "si impone un limite generico non quantificato";
}

function direzione(t: string): "avanti" | "indietro" | null {
  if (/\b(?:arretr\w*|allontan\w*|indietro|ritir\w*|cede\s+terreno)\b/iu.test(t)) return "indietro";
  if (/\b(?:avanz\w*|avvicin\w*|incontro|addosso|guadagna\s+terreno|verso\s+l['’]avversari\w*)\b/iu.test(t)) return "avanti";
  return null;
}

function compatibileZona(claim: string, server: string | null): boolean {
  if (!server) return true;
  const a = zona(claim);
  const b = zona(server);
  return !a || !b || a === b;
}

function fattoIn(record: Record<string, unknown>, chiavi: string[]): string | null {
  for (const k of chiavi) {
    const v = record[k];
    if (typeof v === "string" && v.trim()) return v;
  }
  return null;
}

export function costruisciPlayerBridge(p: PayloadV5): PlayerBridge {
  const testo = String(p.contesto_pg ?? "").slice(0, 8_000);
  const claims: PlayerClaim[] = [];
  const soppressi: PlayerClaimSoppresso[] = [];
  const visti = new Set<string>();
  let progressivo = 0;
  const ref = (p.esito_precedente ?? {}) as Record<string, unknown>;
  const fatti = (p.fatti_del_ciclo ?? {}) as Record<string, unknown>;
  // In png_difende il testo del candidato appartiene all'attacco corrente;
  // in png_attacca/png_esito appartiene invece all'esito precedente. Non si
  // possono fondere i due bersagli: descrivono attacchi di attori diversi.
  const bersaglioServer = p.ruolo === "png_difende"
    ? fattoIn(fatti, ["bersaglio_previsto"])
    : fattoIn(ref, ["bersaglio"]);
  const movimenti = Array.isArray(ref.movimenti_autoritativi) ? ref.movimenti_autoritativi as Array<Record<string, unknown>> : [];
  const movimentoCandidato = movimenti.find((m) => m.attore_ref === "actor.candidate");
  const movimentoServer = (typeof movimentoCandidato?.direzione === "string" ? movimentoCandidato.direzione : null)
    ?? fattoIn(ref, ["movimento_candidato", "movimento_eseguito_candidato"])
    ?? fattoIn(fatti, ["movimento_candidato", "movimento_eseguito_candidato"]);

  const aggiungi = (tipo: TipoPlayerClaim, action: string) => {
    const a = pulisci(action);
    if (!a) { soppressi.push({ tipo, motivo: "vuoto" }); return; }
    const firma = `${tipo}:${a.toLocaleLowerCase("it")}`;
    if (visti.has(firma) || claims.length >= 14) return;
    visti.add(firma);
    progressivo++;
    claims.push({
      id: `claim.${tipo}.${progressivo}`,
      tipo,
      status: "player_claim",
      actor_ref: "actor.candidate",
      action: a,
      surface_permissions: ["player_reprise"],
      verbatim: false,
    });
  };

  let senzaBattute = testo;
  let haDomanda = false;
  for (const m of testo.matchAll(RE_BATTUTE)) {
    const detta = pulisci(m[1] ?? m[2] ?? m[3] ?? m[4] ?? "");
    if (!detta) continue;
    if (RE_ISTRUZIONE_OPERATIVA.test(detta)) {
      soppressi.push({ tipo: "battuta", motivo: "istruzione_operativa" });
      continue;
    }
    const domanda = /\?|\b(?:chi|cosa|come|quando|dove|perché|perche|quale|quanto)\b/iu.test(detta);
    haDomanda ||= domanda;
    // La superficie libera non oltrepassa mai il ponte: al modello arriva
    // soltanto il tipo chiuso, sufficiente a scegliere se rispondere.
    aggiungi("battuta", segnaleDialogo(detta, domanda));
  }
  senzaBattute = senzaBattute.replace(RE_BATTUTE, " ");

  const parti = senzaBattute.split(/(?<=[.!?…;])\s+|\n+|\s+[—–]\s+/u).map(pulisci).filter((x) => x.length >= 5);
  for (const parteOriginale of parti) {
    if (RE_PENSIERO.test(parteOriginale)) {
      soppressi.push({ tipo: "non_autorizzabile", motivo: "voce_non_letterale" });
      continue;
    }

    const zonaOriginale = bersaglioDichiarato(parteOriginale);
    if (zonaOriginale && !compatibileZona(zonaOriginale, bersaglioServer)) {
      soppressi.push({ tipo: "bersaglio_dichiarato", motivo: "conflitto_bersaglio" });
    }

    let parte = parteOriginale;
    const esito = RE_AUTO_ESITO.exec(parte);
    if (esito && !RE_TENTATIVO.test(parte.slice(Math.max(0, esito.index - 45), esito.index + esito[0].length))) {
      soppressi.push({ tipo: "auto_risoluzione", motivo: "auto_risoluzione" });
      parte = pulisci(parte.slice(0, esito.index));
      if (parte.length < 5) continue;
    }

    const z = bersaglioDichiarato(parte);
    if (z) {
      if (compatibileZona(z, bersaglioServer)) aggiungi("bersaglio_dichiarato", `mira alla zona ${z}`);
      else if (z !== zonaOriginale) soppressi.push({ tipo: "bersaglio_dichiarato", motivo: "conflitto_bersaglio" });
    }

    const dir = direzione(parte);
    const dirServer = direzione(movimentoServer ?? "");
    const conflittoMovimento = !!dir && !!dirServer && dir !== dirServer;
    if (conflittoMovimento) {
      soppressi.push({ tipo: "manovra_tentata", motivo: "conflitto_movimento" });
    } else {
      if (RE_DIFESA.test(parte)) aggiungi("difesa_tentata", `tenta una difesa di tipo ${segnale(RE_DIFESA, parte)}`);
      else if (RE_MANOVRA.test(parte) || RE_TENTATIVO.test(parte)) aggiungi("manovra_tentata", segnaleManovra(parte));
      if (RE_TRAIETTORIA.test(parte) || /\bfrontal\w*\b/iu.test(parte)) aggiungi("traiettoria", segnaleTraiettoria(parte));
    }
    if (RE_POSTURA.test(parte)) aggiungi("postura", segnalePostura(parte));
    if (RE_VINCOLO.test(parte)) aggiungi("vincolo_autoimposto", segnaleVincolo(parte));
  }

  return {
    versione: "player_bridge/1.0",
    raw_action_text_available: false,
    licenza: "player_reprise",
    claims,
    soppressi,
    ha_domanda: haDomanda,
  };
}

export function claimUsabili(bridge: PlayerBridge): PlayerClaim[] {
  return bridge.claims.filter((c) => c.surface_permissions.includes("player_reprise"));
}
