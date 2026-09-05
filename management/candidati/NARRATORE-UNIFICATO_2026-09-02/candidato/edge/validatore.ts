// exam_genin_ai — il validatore per riferimenti (NARRATORE-UNIFICATO-001)
//
// Controlla la prosa contro i FATTI della ricevuta e le regole di redazione,
// non contro un lessico di stile. Un errore blocca (ripiego del database);
// un avviso viaggia nella telemetria. Che cosa cade rispetto alla v106:
// la «reazione udibile obbligatoria» (R1/R3), il filtro «ferite/sangue/KO»
// (decisione 02/09), il lessico per similarità.

import { ESITI_NOTI, TETTI_PROSA, type PayloadV5, type Ruolo } from "./contratto.ts";
import { normalizzaBattuta, type Piano } from "./piano.ts";
import { normalizzaStile, similaritaStile } from "./memoria.ts";
import { costruisciScheletroCiclo, type AtomoMeccanico } from "./provenienza.ts";

export type Verdetto = { errori: string[]; qualita: string[]; avvisi: string[] };

const META = /\b(punti\s+vita|punti\s+ferita|punti|tiro\s+di\s+dado|dad[oi]|bonus|malus|pannell[oi]|pulsant[ei]|comand[oi]|menu|statistic\w*|turn[oi]|round|metr[oi]|percentual\w*|probabilit\w*|prompt|regol[ae] del gioco|il server|il campo ha deciso)\b/iu;
const PROMPT_LEAK = /\b(non posso|non mi è (?:consentito|permesso)|non è autorizzat\w+|non ho informazioni|secondo le regole|come da regolamento)\b/iu;
const NOTA_STESURA = /\b(?:(?:this|that|it)\s+(?:is|was|seems)\b|(?:i|we)\s+(?:accidentally|mistakenly|must|need)\b|need(?:s|ed)?\s+(?:to\s+)?(?:correct|fix|rewrite|revise|ensure|return|produce)\b|(?:malformed|invalid)\s+(?:json|output|response|text)\b|(?:devo|bisogna|serve)\s+(?:correggere|riscrivere|riformulare|verificare)\b|(?:testo|json|output|risposta)\s+(?:malformat\w*|non valid\w*|errat\w*))\b/iu;
const FIATO = /\b(spezza(?:no)?|mozza(?:no)?|toglie|taglia|rompe|ruba)\s+(?:il|lo)\s+(?:fiato|respiro)\b|\bfiato\s+(?:spezzato|mozzato|mozzo|corto|rotto)\b|\brespiro\s+(?:spezzato|mozzato|corto|rotto)\b/iu;
const ZONA_CORPO = "(?:viso|volto|faccia|spalla|braccio|avambraccio|gomito|torace|petto|sterno|costato|ventre|stomaco|addome|fianco|gamba|coscia|ginocchio|stinco|caviglia)";
const CODA_ESITO = new RegExp(`\\b(?:colpisc\\w*|colpit\\w*|raggiung\\w*|raggiunt\\w*|centr\\w*|invest\\w*|investit\\w*|tocc\\w*|abbatt\\w*|travolg\\w*|travolt\\w*|schiant\\w*|affond\\w*|impatt\\w*|croll\\w*|stramazz\\w*|si accascia|si affloscia|resta rivers\\w*|barcoll\\w*|vacill\\w*|va giù|(?:è|viene|resta) mess\\w*.{0,18}\\b(?:a terra|al tappeto)|cad\\w*.{0,18}\\b(?:in ginocchio|a terra)|finisc\\w*.{0,18}\\b(?:distes\\w*|bocconi)|ced\\w*.{0,24}\\bsotto l['’]urto|arriv\\w*.{0,28}\\b${ZONA_CORPO}\\b|trov\\w*.{0,28}\\b(?:${ZONA_CORPO}|bersaglio|corpo)\\b|si stampa|mette\\w* a segno|va a segno|manda\\w*.{0,24}\\ba terra|fa\\s+cadere|atterr\\w*|finisc\\w*\\s+contro|mord\\w*|incass\\w*|ricev\\w*|subisc\\w*|manca\\w*|mancat\\w*|para\\w*|parat\\w*|schiva\\w*|schivat\\w*|sostituit\\w*|sfiora\\w*|sfiorat\\w*|danno|danni|ferit\\w*|vince\\w*|vinto|perde\\w*|perso|riesce|riuscit\\w*|fallisce|fallit\\w*)\\b`, "iu");
const CONTATTO_COMPIUTO = new RegExp(`\\b(?:colpisc\\w*|colpit\\w*|raggiung\\w*|raggiunt\\w*|centr\\w*|invest\\w*|investit\\w*|tocc\\w*|abbatt\\w*|travolg\\w*|travolt\\w*|schiant\\w*|affond\\w*|impatt\\w*|croll\\w*|si accascia|barcoll\\w*|vacill\\w*|cad\\w*.{0,18}\\b(?:in ginocchio|a terra)|finisc\\w*.{0,18}\\bdistes\\w*|ced\\w*.{0,24}\\bsotto l['’]urto|arriv\\w*.{0,28}\\b${ZONA_CORPO}\\b|trov\\w*.{0,28}\\b(?:${ZONA_CORPO}|bersaglio|corpo)\\b|si stampa|mette\\w* a segno|va a segno|manda\\w*.{0,24}\\ba terra|fa\\s+cadere|atterr\\w*|finisc\\w*\\s+contro|mord\\w*|incass\\w*|ricev\\w*|subisc\\w*|sfiora\\w*|sfiorat\\w*|ferisc\\w*|ferit\\w*)\\b`, "iu");
const PENSIERO_PG = /(?:\b(?:pensa|crede|immagina|spera|teme|decide|vuole|intende|capisce|comprende|ricorda|sa|sapeva|sospetta|desidera|realizza|gioisce|dubita|presume|suppone|ritiene|considera|si augura|si illude|si domanda|si convince|si aspetta|si preoccupa|avverte (?:paura|timore|rabbia|vergogna|sollievo)|sente (?:paura|timore|rabbia|vergogna|sollievo)|si rende conto|si accorge|prova (?:paura|timore|rabbia|vergogna|sollievo)|ha paura)\b|(?:è|era) (?:convint\w*|cert\w*))/iu;
const MOVIMENTO_PG = /\b(?:avanza|arretra|scatta|balza|salta|si sposta|si allontana|si avvicina|ruota|si gira)\b/iu;
const SPOSTAMENTO_LINEARE = /(?:\b(?:avanz\w*|arretr\w*|retroced\w*|indietreggi\w*|ritir\w*|scatt\w*|scart\w*|sgusci\w*|si defila|vir\w*(?:\s+alle spalle)?|prende posto|compie (?:una\s+)?falcat\w*|corr\w*|balz\w*|salt\w*|cammin\w*|attravers\w*|guizz\w*|ricompar\w*|sbuc\w*(?:\s+alle spalle)?|aggir\w*|si dispone (?:alle spalle|davanti|di lato)|si ritrova (?:al bordo|alle spalle|davanti|lontano|vicino)|scivol\w*(?:\s+all['’]indietro|\s+indietro)?|(?:viene|è|resta) (?:proiettat\w*|sospint\w*)(?:\s+all['’]indietro|\s+indietro|\s+avanti|\s+verso il bordo)?|si sposta|si muove|si allontana|si avvicina|si ritira|si porta (?:alle spalle|avanti|indietro|addosso)|si fa (?:avanti|indietro)|si spinge (?:avanti|indietro)|si lancia (?:alle spalle|avanti|indietro|addosso)|si getta (?:alle spalle|avanti|indietro|addosso)|accorcia (?:la )?distanza|chiude le distanze|allunga (?:la )?distanza|prende le distanze|recupera terreno|guadagna (?:terreno|spazio)|cede terreno|perde terreno|fa (?:un|due|tre|più) pass[oi]|compie (?:un|due|tre|più) pass[oi]|copre (?:un|due|tre|più|diversi|molti) pass[oi])\b|(?:è|era) ora al bordo)/iu;
const VARIAZIONE_DISTANZA = /\b(?:fra|tra)\b.{0,90}\b(?:si aprono|si chiudono|restano|compaiono|corrono)\s+(?:un|due|tre|più|diversi|molti)\s+pass[oi]\b|\bla distanza\b.{0,35}\b(?:si apre|si chiude|aumenta|diminuisce|cambia)\b/iu;
const ESEMPIO_PROMPT_FRASI = [
  "Il Proiettile d'acqua squarcia la distanza fra Hime e l'uomo sulla strada con un sibilo crescente",
  "Per un istante le ginocchia cedono e il volto si contrae in una smorfia, ma gli stivali rimangono saldi nel terreno e la sua mole non arretra",
  "Tetsuma solleva il capo, espelle un colpo di tosse e cerca con lo sguardo la compagna nascosta sul margine opposto",
  "La parola è breve e ruvida",
];
const MOVIMENTO_TENTATO = /\b(?:tenta\w*|prova\w*|cerca\w*|vorrebbe|potrebbe)\b.{0,60}\b(?:avanz\w*|arretr\w*|indietreggi\w*|scatt\w*|scart\w*|sgusci\w*|corr\w*|balz\w*|salt\w*|cammin\w*|spostar\w*|muover\w*|allontanar\w*|avvicinar\w*)\b/iu;
const TONO_REFERTO = /\b(?:l'iniziativa (?:passa|resta)|la distanza (?:aumenta|diminuisce|resta)|il risultato è|l'esito è|il colpo è (?:riuscito|fallito)|la parata non chiude)\b/iu;

const CONTRADDIZIONI: Record<string, RegExp> = {
  colpito: /\b(non (?:lo|la) (?:tocca|raggiunge|sfiora)|non va a segno|a vuoto|la guardia regge|blocca il colpo|lascia intatt\w*|tutt['’]altro che riuscit\w*|illes[oa]|indenne|(?:lo|la) schiva|(?:lo|la) para|deviat[oa] del tutto)\b/iu,
  sfiorato: /\b(in pieno|a vuoto|illes[oa]|indenne|centr[oa] in pieno)\b/iu,
  parato: /\b(a segno|(?:lo|la) colpisce in pieno|in pieno|a vuoto|(?:lo|la) raggiunge in pieno|la guardia (?:lascia passare|manca) il colpo)\b/iu,
  schivato: /\b(a segno|(?:lo|la) colpisce|in pieno|la guardia regge|(?:lo|la) raggiunge|cerca invano di schivare)\b/iu,
  mancato: /\b(a segno|(?:lo|la) colpisce|in pieno|(?:lo|la) para|blocca il colpo|(?:lo|la) raggiunge)\b/iu,
  sostituito: /\b((?:lo|la) colpisce in pieno|(?:lo|la) raggiunge in pieno)\b/iu,
  copia_colpita: /\b(l'originale|il corpo vero|quello vero) (?:è|viene) colpit[oa]\b/iu,
  originale_individuato: /\b(una copia|la copia) (?:è|viene) colpit[oa]\b/iu,
};
const DEVE_CONTENERE: Record<string, RegExp> = {
  parato: /\b(par[ao]t?\w*|blocc\w*|avambracci[oi]|guardia|deviar\w*|devia\w*|intercett\w*)\b/iu,
  schivato: /\b(schiv\w*|scans\w*|evit\w*|si sposta|si abbassa|si piega|fuori (?:dalla )?traiettoria|si ritrae|di lato)\b/iu,
  mancato: /\b(a vuoto|manca\w*|sbaglia|non (?:lo|la) (?:tocca|raggiunge)|nell'aria|il vuoto)\b/iu,
  copia_colpita: /\bcopi[ae]\b/iu,
  originale_individuato: /\b(originale|corpo vero|quell[oa] ver[oa]|il vero)\b/iu,
};
const ESITO_NEGATO: Record<string, RegExp> = {
  colpito: /\b(?:non\s+(?:(?:lo|la)\s+)?(?:colpisc\w*|raggiung\w*|centr\w*|invest\w*)|non\s+(?:è|viene|resta)\s+(?:colpit\w*|raggiunt\w*|investit\w*)|evita\w*\s+di\s+colpire|senza\s+andare\s+a\s+segno)\b/iu,
  sfiorato: /\b(?:non\s+(?:(?:lo|la)\s+)?sfior\w*|non\s+(?:è|viene|resta)\s+sfiorat\w*)\b/iu,
  parato: /\b(?:non\s+(?:(?:lo|la)\s+)?(?:par\w*|blocc\w*|intercett\w*|devi\w*)|evita\w*\s+di\s+parare|non\s+riesce\s+a\s+(?:parare|bloccare|intercettare|deviare))\b/iu,
  schivato: /\b(?:non\s+(?:(?:lo|la)\s+)?(?:schiv\w*|scans\w*|evit\w*)|rifiuta\w*\s+di\s+schivare|non\s+riesce\s+a\s+(?:schivare|scansare|evitare))\b/iu,
  mancato: /\b(?:non\s+manc\w*|non\s+va\s+a\s+vuoto|anziché\s+mancare)\b/iu,
};

function frasi(t: string): string[] {
  // Si spezza su . ! ? … seguiti da spazio, ma MAI dentro una battuta «…»:
  // «Mi hai preso! Bene.» è una frase sola con la sua attribuzione.
  const out: string[] = [];
  let cur = ""; let chiusura: string | null = null;
  for (let i = 0; i < t.length; i++) {
    const ch = t[i];
    cur += ch;
    if (!chiusura && ch === "«") chiusura = "»";
    else if (!chiusura && ch === "“") chiusura = "”";
    else if (!chiusura && ch === '"') chiusura = '"';
    else if (!chiusura && ch === "<") chiusura = ">";
    else if (chiusura === ch) chiusura = null;
    if (!chiusura && /[.!?…]/.test(ch) && (i + 1 >= t.length || /\s/.test(t[i + 1]))) {
      // includi un'eventuale chiusura di battuta/virgolette attaccata
      out.push(cur.trim()); cur = "";
    }
  }
  if (cur.trim()) out.push(cur.trim());
  return out.filter(Boolean);
}
function ultimaFrase(t: string): string {
  const f = frasi(t);
  return f.length ? f[f.length - 1] : t;
}
function battuteCon(t: string): Array<{ testo: string; idx: number }> {
  return [...t.matchAll(/«([^»]+)»|“([^”]+)”|"([^"\n]+)"|<([^<>\n]+)>/g)].map((m) => ({ testo: (m[1] ?? m[2] ?? m[3] ?? m[4]).trim(), idx: m.index ?? 0 }));
}

function battutaRispondeAlSegnale(segnale: string, frase: string): boolean {
  const dialogo = battuteCon(frase).map((b) => b.testo).join(" ");
  if (!dialogo) return false;
  if (segnale.includes("movimento o sulla distanza")) return /\b(?:(?:la|questa|quella)\s+distanza|rest\w*\s+(?:vicin\w*|lontan\w*|qui)|(?:resto|rimango|vado|avanzo|arretr\w*|muov\w*|spost\w*)(?:\s+(?:al bordo|vicin\w*|lontan\w*|qui|lì|avanti|indietro))?|(?:accorcio|allungo|chiudo|apro)\s+(?:la\s+)?distanza)\b/iu.test(dialogo);
  if (segnale.includes("condizione dello sfidante")) return /\b(?:paura|timore|dolore|male|stanc\w*|fiato|respiro|ferit\w*|il mio corpo|reggo|cedo)\b/iu.test(dialogo);
  if (segnale.includes("intenzioni dello sfidante")) return /\b(?:(?:il mio|questo)\s+(?:piano|intento|scopo)|(?:voglio|intendo|conto di|continuerò|continuo|mi fermo|farò|non farò|sceglierò)\b)/iu.test(dialogo);
  if (segnale.includes("capacità dello sfidante")) return /\b(?:posso|non posso|riesco|non riesco|so farlo|non so farlo|ne sono capace|non ne sono capace)\b/iu.test(dialogo);
  return true;
}

function bersaglioGovernatoCorretto(testo: string, paroleAttese: string[]): boolean {
  const governo = /\b(?:mir\w*|punt\w*|dirig\w*|indirizz\w*|bersagli\w*|attacc\w*|colp\w*|sferr\w*|porta(?:re)?\s+(?:(?:il|lo|la|un|una)\s+)?(?:nuovo\s+)?(?:colpo|pugno|calcio|palmo|gomito|ginocchio))\b/giu;
  const verbi = [...testo.matchAll(governo)].filter((v) => {
    const dopo = testo.slice((v.index ?? 0) + v[0].length);
    return !(/^punt/iu.test(v[0]) && /^\s+(?:il|lo)\s+sguardo\b/iu.test(dopo));
  });
  let zonaGovernata: string | null = null;
  for (const verbo of verbi) {
    const dopo = testo.slice((verbo.index ?? 0) + verbo[0].length, (verbo.index ?? 0) + verbo[0].length + 120)
      .split(/\s+e\s+(?:tiene|stringe|mantiene|piega|solleva)\w*\b/iu, 1)[0];
    const dopoBersaglio = dopo.replace(new RegExp(`^\\s+(?:(?:con\\s+(?:(?:il|lo|la|un|una)\\s+)?(?:propri[oa]\\s+)?|col\\s+))${ZONA_CORPO}\\b`, "iu"), " ");
    const candidati = [...dopoBersaglio.matchAll(new RegExp(`\\b(?:verso|contro|alla|al|sulla|sul)\\s+(?:(?:il|lo|la|un|una)\\s+)?(${ZONA_CORPO})`, "giu"))]
      .map((m) => ({ zona: m[1].toLowerCase(), indice: m.index ?? 0 }));
    const diretto = dopoBersaglio.match(new RegExp(`^\\s+(?:(?:il|lo|la)\\s+)?(${ZONA_CORPO})`, "iu"));
    if (diretto) candidati.push({ zona: diretto[1].toLowerCase(), indice: diretto.index ?? 0 });
    const validi = candidati.filter((m) => !/\b(?:sguardo|occhi)\b[^.;,]{0,50}$/iu.test(dopoBersaglio.slice(0, m.indice))).sort((a, b) => a.indice - b.indice);
    if (validi.length) zonaGovernata = validi.at(-1)!.zona;
  }
  return !!zonaGovernata && paroleAttese.some((p) => normalizzaStile(zonaGovernata).includes(normalizzaStile(p)) || normalizzaStile(p).includes(normalizzaStile(zonaGovernata)));
}

function bersaglioDelContattoCorretto(testo: string, paroleAttese: string[]): boolean | null {
  const contatti = /\b(?:colpisc\w*|colpit\w*|raggiung\w*|raggiunt\w*|centr\w*|invest\w*|investit\w*|impatt\w*|atterr\w*|incass\w*|ricev\w*|subisc\w*|assorb\w*|sfiora\w*|sfiorat\w*|arriv\w*|finisc\w*(?:\s+contro)?|si stampa|abbatt\w*|travolg\w*|travolt\w*|schiant\w*|affond\w*)\b/giu;
  let trovato = false;
  for (const contatto of testo.matchAll(contatti)) {
    const dopo = testo.slice((contatto.index ?? 0) + contatto[0].length, (contatto.index ?? 0) + contatto[0].length + 90);
    if (/^(?:\s+con\s+le\s+dita)?\s+(?:la|il|lo)?\s*propri[oa]\b/iu.test(dopo)) continue;
    const zona = dopo.match(new RegExp(`\\b${ZONA_CORPO}\\b`, "iu"))?.[0]?.toLowerCase();
    if (!zona) continue;
    trovato = true;
    if (!paroleAttese.some((p) => normalizzaStile(zona).includes(normalizzaStile(p)) || normalizzaStile(p).includes(normalizzaStile(zona)))) return false;
  }
  return trovato ? true : null;
}

function apreNuovoAttacco(testo: string, piano: Piano): boolean {
  const nome = escapeRegExp(piano.riferimenti.sfidante);
  const attore = `(?:${nome}|lo sfidante|la sfidante)`;
  const gesto = "(?:carica|prepara|arma|sferra|dirige|indirizza|porta|solleva|scaglia|lancia|riparte|contrattacca|parte|tende|rinnova|passa|attacca|vibra|apre)";
  const colpo = "(?:secondo|nuovo|altro|altra)?\\s*(?:pugno|calcio|colpo|palmo|gomito|ginocchio|ginocchiata|montante|fendente|affondo|attacco|assalto|testata|diretto)";
  return new RegExp(`(?:\\b(?:poi|quindi|subito dopo|appena dopo|terminat\\w*)\\b.{0,120}\\b${attore}\\b.{0,80}\\b${gesto}\\w*\\b.{0,55}\\b${colpo}\\b|\\b${attore}\\b.{0,110}\\b(?:${gesto}\\w*|passa\\s+al\\s+contrattacco)\\b.{0,55}\\b${colpo}\\b|\\b${attore}\\b.{0,80}\\b(?:un|il|una|la)\\s+(?:secondo|nuovo|altro|altra)\\s+(?:pugno|calcio|colpo|ginocchiata|montante|fendente|affondo|attacco)\\b)`, "iu").test(testo);
}

function esitoAttribuitoAlCandidato(testo: string, esito: string, piano: Piano): boolean {
  const perEsito: Record<string, RegExp> = {
    parato: /\b(?:para\w*|blocca\w*|intercetta\w*|devia\w*)\b/iu,
    schivato: /\b(?:schiva\w*|scansa\w*|evita\w*)\b/iu,
    colpito: /\b(?:viene\s+colpit\w*|è\s+colpit\w*|incassa\w*|riceve\w*|subisce\w*|viene\s+mess\w*|è\s+mess\w*|cade\w*|va\s+giù)\b/iu,
    sfiorato: /\b(?:viene\s+sfiorat\w*|è\s+sfiorat\w*|subisce\w*|riceve\w*)\b/iu,
  };
  const re = perEsito[esito];
  if (!re) return false;
  for (const m of testo.matchAll(new RegExp(re.source, "giu"))) {
    if (legaVerboAdAttore(testo, m.index ?? 0, piano, null).attore === "candidato") return true;
  }
  return false;
}

function candidatoSubisceEsitoCorporeo(testo: string, piano: Piano): boolean {
  const candidato = `(?:${escapeRegExp(piano.riferimenti.candidato)}|il candidato|la candidata)`;
  return new RegExp(`\\b${candidato}\\b.{0,35}\\b(?:viene\\s+mess\\w*|è\\s+mess\\w*|cade\\w*|crolla\\w*|stramazza\\w*|si accascia|si affloscia|resta rivers\\w*|finisce bocconi|va\\s+giù)`, "iu").test(testo);
}

function caporaliValide(testo: string): boolean {
  let aperta = false;
  for (const ch of testo) {
    if (ch === "«") { if (aperta) return false; aperta = true; }
    if (ch === "»") { if (!aperta) return false; aperta = false; }
  }
  return !aperta;
}
function contiene(t: string, parole: string[]): boolean {
  const low = t.toLowerCase();
  return parole.some((w) => low.includes(w.toLowerCase()));
}

function escapeRegExp(t: string): string {
  return t.replace(/[.*+?^${}()|[\]\\]/g, "\\$&");
}

function attribuisceVoce(frase: string, nome: string, generico?: string, altri: string[] = []): boolean {
  const soggetti = [nome, generico].filter(Boolean).map(String);
  if (!soggetti.length) return false;
  const soggettoRe = soggetti.map(escapeRegExp).join("|");
  if (new RegExp(`\\bla voce di\\s+(?:${soggettoRe})\\b`, "iu").test(frase)
    || new RegExp(`\\b(?:${soggettoRe})\\b\\s*,?\\s+la cui voce\\b`, "iu").test(frase)) return true;
  const verbi = /\b(?:dice|dire|dicendo|mormora|mormorare|mormorando|grida|gridare|gridando|sussurra|sussurrare|sussurrando|ripete|ripetere|ripetendo|risponde|rispondere|rispondendo|chiede|chiedere|chiedendo|esclama|esclamare|esclamando|ringhia|ringhiare|ringhiando|sibila|sibilare|sibilando|urla|urlare|urlando|sbotta|sbottare|sbottando|commenta|commentare|commentando|borbotta|borbottare|borbottando|ansima|ansimare|ansimando|aggiunge|aggiungere|aggiungendo|conclude|concludere|concludendo|dichiara|dichiarare|dichiarando|annuncia|annunciare|annunciando|chiama|chiamare|chiamando|ordina|ordinare|ordinando|domanda|domandare|domandando|scandisce|scandire|scandendo|replica|replicare|replicando|pronuncia|pronunciare|pronunciando|articola|articolare|articolando|ammette|ammettere|ammettendo|sostiene|sostenere|sostenendo|afferma|affermare|affermando|confessa|confessare|confessando|assicura|assicurare|assicurando)\b/giu;
  const ruoloVerbo = (testo: string, nonFinito: boolean): "soggetto" | "altro" | null => {
    const voci: Array<["soggetto" | "altro", string]> = [
      ...soggetti.map((x): ["soggetto", string] => ["soggetto", x]),
      ...altri.map((x): ["altro", string] => ["altro", x]),
    ];
    const menzioni: Array<{ ruolo: "soggetto" | "altro"; inizio: number }> = [];
    for (const [ruolo, voce] of voci) {
      for (const m of testo.matchAll(new RegExp(`\\b${escapeRegExp(voce)}\\b`, "giu"))) {
        const inizio = m.index ?? 0;
        const prima = testo.slice(Math.max(0, inizio - 24), inizio);
        if (/\b(?:di|del|dello|della|dei|degli|delle|a|ad|al|allo|alla|ai|agli|alle|da|dal|dallo|dalla|davanti a|accanto a|vicino a|contro|verso|su|sul|sullo|sulla|per|tra|fra)\s*$/iu.test(prima)) continue;
        menzioni.push({ ruolo, inizio });
      }
    }
    menzioni.sort((a, b) => a.inizio - b.inizio);
    const coreferenziale = /\b(?:prima di|dopo aver|senza|per|al fine di|pront\w* a|decis\w* a|intenzionat\w* a|sul punto di|continuando a|in procinto di|quasi a)\s*$/iu.test(testo);
    if (nonFinito && !coreferenziale) return menzioni.at(-1)?.ruolo ?? null;
    const connettori = [...testo.matchAll(/[,;:]|\b(?:mentre|quando|poi|quindi|allora|ma|invece|e|che|il quale|la quale|i quali|le quali)\b/giu)];
    const ultimo = connettori.at(-1);
    if (!ultimo) return (coreferenziale ? menzioni[0] : menzioni.at(-1))?.ruolo ?? null;
    const fine = (ultimo.index ?? 0) + ultimo[0].length;
    const dopo = menzioni.filter((x) => x.inizio >= fine).at(-1);
    if (dopo) return dopo.ruolo;
    if (/^(?:che|il quale|la quale|i quali|le quali)$/iu.test(ultimo[0])) return menzioni.filter((x) => x.inizio < (ultimo.index ?? 0)).at(-1)?.ruolo ?? null;
    return menzioni[0]?.ruolo ?? null;
  };
  for (const m of frase.matchAll(verbi)) {
    const i = m.index ?? 0;
    const prima = frase.slice(0, i);
    if (ruoloVerbo(prima, /(?:are|ere|ire)$/iu.test(m[0])) === "soggetto") return true;
    const dopo = frase.slice(i + m[0].length);
    if (new RegExp(`^\\s*,?\\s*(?:${soggettoRe})\\b`, "iu").test(dopo)) return true;
  }
  return false;
}

function attribuisceDiscorsoIndiretto(frase: string, piano: Piano): boolean {
  const verbi = /\b(?:dice|racconta|nota|fa notare|ribatte|promette|avverte|ammette|sostiene|afferma|confessa|assicura|dichiara|annuncia|risponde|replica|spiega|aggiunge|conclude)\b/giu;
  for (const verbo of frase.matchAll(verbi)) {
    const prima = frase.slice(Math.max(0, (verbo.index ?? 0) - 20), verbo.index ?? 0);
    if (/\bnon\s*$/iu.test(prima)) continue;
    const dopo = frase.slice((verbo.index ?? 0) + verbo[0].length, (verbo.index ?? 0) + verbo[0].length + 90);
    if (!/^(?:\s+\p{Lu}[\p{L}’'-]+)?\s*(?:che\b|di\b|dell['’]|a\s+\p{Lu}[\p{L}’'-]+\s+(?:il|lo|la|un|una)\b)/iu.test(dopo)) continue;
    if (legaVerboAdAttore(frase, verbo.index ?? 0, piano, null).attore === "candidato") return true;
  }
  return false;
}

function candidatoSiSente(frase: string, nome: string): boolean {
  const re = new RegExp(`\\b(?:${escapeRegExp(nome)}|il candidato)\\b`, "giu");
  for (const m of frase.matchAll(re)) {
    const prima = frase.slice(Math.max(0, (m.index ?? 0) - 24), m.index ?? 0);
    const dopo = frase.slice((m.index ?? 0) + m[0].length, (m.index ?? 0) + m[0].length + 24);
    if (!/^\s+si sente\b/iu.test(dopo)) continue;
    if (/\b(?:ad|al|accanto ad|accanto al|vicino ad|vicino al|presso)\s*$/iu.test(prima)) continue;
    return true;
  }
  return false;
}

function emozioneDelCandidato(frase: string, nome: string): boolean {
  const candidato = `(?:${escapeRegExp(nome)}|il candidato|la candidata)`;
  const emozione = "(?:paura|timore|rabbia|vergogna|sollievo|gioia|angoscia)";
  return new RegExp(`(?:\\b(?:ad|in)\\s+${candidato}\\b.{0,45}\\b${emozione}\\b|\\b${emozione}\\b.{0,45}\\b${candidato}\\b)`, "iu").test(frase);
}

function statoInternoNominale(frase: string, nome: string): boolean {
  const candidato = `(?:${escapeRegExp(nome)}|il candidato|la candidata)`;
  return new RegExp(`(?:\\b${candidato}\\b.{0,30}(?:ha\\s+(?:dubbi|certezze|sospetti|la sensazione)|nutre\\s+(?:il dubbio|la certezza|un sospetto)|dà\\s+per\\s+scontat\\w*|coltiva\\s+(?:la\\s+)?speranza|è\\s+(?:persuas\\w*|consapevol\\w*))|\\b(?:ad|per)\\s+${candidato}\\b.{0,28}(?:sembra|è certo|è chiaro|è evidente)|\\b(?:dubbio|certezza|sospetto|sensazione|speranza)\\b.{0,35}\\b${candidato}\\b)`, "iu").test(frase);
}

function soggettoAmbientale(prima: string): boolean {
  return /(?:^|[.;,:]|\b(?:mentre|quando|poi|quindi|e)\b)\s*(?:la|il|lo|l['’])?\s*(?:luce|polvere|ombra|aria|stoffa|suono|rumore)(?:\s+\p{L}+){0,4}\s*$/iu.test(prima);
}

function contieneEsitoCompiuto(testo: string, piano: Piano): boolean {
  if (/(?:è|viene|resta)\s+mess\w*.{0,18}\b(?:a terra|al tappeto)\b|\bva\s+giù/iu.test(testo)) return true;
  for (const m of testo.matchAll(new RegExp(CODA_ESITO.source, "giu"))) {
    const prima = testo.slice(Math.max(0, (m.index ?? 0) - 45), m.index ?? 0);
    if (soggettoAmbientale(prima)) continue;
    const dopoBreve = testo.slice((m.index ?? 0) + m[0].length, (m.index ?? 0) + m[0].length + 40);
    if (/^\s+davanti\b/iu.test(dopoBreve) && /\b(?:arriv\w*|trov\w*|atterr\w*)$/iu.test(m[0])) continue;
    if (/(?:\bper|\bdi|\ba|prepara\w*\s+a)\s*$/iu.test(prima) && /(?:are|ere|ire)$/iu.test(m[0])) continue;
    if (/\b(?:tenta\w*|prova\w*|cerca\w*|vorrebbe|potrebbe)\b.{0,32}\b(?:di|a)\s*$/iu.test(prima)) continue;
    const finestra = testo.slice(Math.max(0, (m.index ?? 0) - 80), (m.index ?? 0) + m[0].length + 80);
    const attori = new RegExp(`\\b(?:${escapeRegExp(piano.riferimenti.candidato)}|${escapeRegExp(piano.riferimenti.sfidante)}|il candidato|la candidata|lo sfidante|la sfidante)\\b`, "iu");
    if (!attori.test(finestra) && !/\b(?:colpo|pugno|calcio|nocca|palmo|gomito|ginocchio|attacco|difesa|guardia|corpo|viso|spalla|braccio|torace|petto|ventre|fianco|gamba)\b/iu.test(finestra)) continue;
    return true;
  }
  return false;
}

type AttoreNarrativo = "candidato" | "sfidante";
type MenzioneAttore = { attore: AttoreNarrativo; inizio: number; fine: number };
type EventoMovimento = { attore: AttoreNarrativo; testo: string };

function menzioniAttori(frase: string, piano: Piano): MenzioneAttore[] {
  const voci: Array<[AttoreNarrativo, string]> = [
    ["candidato", piano.riferimenti.candidato], ["candidato", "il candidato"],
    ["sfidante", piano.riferimenti.sfidante], ["sfidante", "lo sfidante"], ["sfidante", "la sfidante"],
  ];
  const viste = new Set<string>();
  const out: MenzioneAttore[] = [];
  for (const [attore, voce] of voci) {
    if (!voce) continue;
    const re = new RegExp(`\\b${escapeRegExp(voce)}\\b`, "giu");
    for (const m of frase.matchAll(re)) {
      const inizio = m.index ?? 0;
      const firma = `${attore}:${inizio}:${m[0].length}`;
      if (viste.has(firma)) continue;
      viste.add(firma);
      out.push({ attore, inizio, fine: inizio + m[0].length });
    }
  }
  for (const pronome of frase.matchAll(/\b(?:quest['’](?:ultimo|ultima)|questi|costui|costei|il secondo|la seconda)\b/giu)) {
    const inizio = pronome.index ?? 0;
    const referente = out.filter((m) => m.inizio < inizio).sort((a, b) => a.inizio - b.inizio).at(-1);
    if (referente) out.push({ attore: referente.attore, inizio, fine: inizio + pronome[0].length });
  }
  return out.sort((a, b) => a.inizio - b.inizio || b.fine - a.fine);
}

function menzioneRelazionale(frase: string, m: MenzioneAttore): boolean {
  const prima = frase.slice(Math.max(0, m.inizio - 24), m.inizio);
  return /\b(?:di|del|dello|della|dei|degli|delle|a|ad|al|allo|alla|ai|agli|alle|da|dal|dallo|dalla|davanti a|accanto a|vicino a|contro|verso|su|sul|sullo|sulla|sui|sugli|sulle|per|tra|fra|sotto|sopra|oltre|dentro)\s*$/iu.test(prima);
}

function soggettoPersistente(frase: string, piano: Piano): AttoreNarrativo | null {
  return soggettoFinoA(frase, frase.length, piano, null, false);
}

function prefissoImplicito(testo: string): boolean {
  return /^(?:\s|[—–,:;]|\b(?:poi|quindi|allora|infine|subito|ancora|ora|lei|lui|esso|essa|costui|costei)\b)*$/iu.test(testo);
}

function soggettoFinoA(frase: string, indice: number, piano: Piano, precedente: AttoreNarrativo | null, nonFinito: boolean): AttoreNarrativo | null {
  const menzioni = menzioniAttori(frase, piano).filter((m) => !menzioneRelazionale(frase, m) && m.inizio < indice);
  if (!menzioni.length && !prefissoImplicito(frase.slice(0, indice))) return null;
  if (nonFinito) return menzioni.at(-1)?.attore ?? precedente;
  const connettori = [...frase.slice(0, indice).matchAll(/[,;:]|\b(?:mentre|quando|poi|quindi|allora|ma|invece|e|che|il quale|la quale|i quali|le quali)\b/giu)];
  let corrente = precedente;
  let inizio = 0;
  for (const connettore of connettori) {
    const fineTratto = connettore.index ?? 0;
    const nelTratto = menzioni.filter((m) => m.inizio >= inizio && m.inizio < fineTratto);
    if (/^(?:che|il quale|la quale|i quali|le quali)$/iu.test(connettore[0])) {
      corrente = menzioniAttori(frase, piano).filter((m) => m.inizio < fineTratto).at(-1)?.attore ?? corrente;
    }
    else corrente = nelTratto[0]?.attore ?? corrente;
    inizio = fineTratto + connettore[0].length;
  }
  const finali = menzioni.filter((m) => m.inizio >= inizio);
  if (finali.length) corrente = finali[0].attore;
  return corrente;
}

function legaVerboAdAttore(frase: string, indice: number, piano: Piano, precedente: AttoreNarrativo | null): { attore: AttoreNarrativo | null; inizioClausola: number } {
  const connettori = [...frase.slice(0, indice).matchAll(/[,;:]|\b(?:mentre|quando|poi|quindi|allora|ma|invece|e|che|il quale|la quale|i quali|le quali)\b/giu)];
  const ultimo = connettori.at(-1);
  const verbo = frase.slice(indice).match(/^\p{L}+(?:\s+\p{L}+)?/u)?.[0] ?? "";
  const nonFinito = /(?:are|ere|ire)\b/iu.test(verbo) && !/\b(?:prima di|dopo aver|senza|per|al fine di|pront\w* a|decis\w* a|intenzionat\w* a|sul punto di|continuando a)\s*$/iu.test(frase.slice(0, indice));
  return {
    attore: soggettoFinoA(frase, indice, piano, precedente, nonFinito),
    inizioClausola: ultimo ? (ultimo.index ?? 0) + ultimo[0].length : 0,
  };
}

function analizzaMovimenti(frase: string, piano: Piano, precedente: AttoreNarrativo | null): EventoMovimento[] {
  const menzioni = menzioniAttori(frase, piano).filter((m) => !menzioneRelazionale(frase, m));
  const eventi: EventoMovimento[] = [];
  const re = new RegExp(SPOSTAMENTO_LINEARE.source, "giu");
  for (const movimento of frase.matchAll(re)) {
    const indice = movimento.index ?? 0;
    const legame = legaVerboAdAttore(frase, indice, piano, precedente);
    const attore = legame.attore;
    if (!attore) continue;
    const prossima = menzioni.find((m) => m.inizio > indice && m.attore !== attore);
    const testoEvento = frase.slice(legame.inizioClausola, prossima?.inizio ?? frase.length).trim();
    eventi.push({ attore, testo: testoEvento });
    const prima = frase.slice(Math.max(0, indice - 100), indice);
    const dopo = frase.slice(indice + movimento[0].length, indice + movimento[0].length + 100);
    const cand = escapeRegExp(piano.riferimenti.candidato); const sfid = escapeRegExp(piano.riferimenti.sfidante);
    const coordinati = new RegExp(`(?:${cand}\\s+e\\s+${sfid}|${sfid}\\s+e\\s+${cand})\\s*$`, "iu").test(prima);
    const insiemeCandidato = new RegExp(`^.{0,50}\\binsieme\\s+ad?\\s+${cand}\\b`, "iu").test(dopo);
    const insiemeSfidante = new RegExp(`^.{0,50}\\binsieme\\s+ad?\\s+${sfid}\\b`, "iu").test(dopo);
    if ((coordinati || insiemeCandidato) && attore !== "candidato") eventi.push({ attore: "candidato", testo: testoEvento });
    if ((coordinati || insiemeSfidante) && attore !== "sfidante") eventi.push({ attore: "sfidante", testo: testoEvento });
  }
  const candidato = escapeRegExp(piano.riferimenti.candidato);
  for (const causativo of frase.matchAll(new RegExp(`\\b(?:(?:sping\\w*|sosping\\w*|trascin\\w*|scaravent\\w*|sbalz\\w*|ricacci\\w*|spost\\w*|costring\\w*)\\s+(?:${candidato}|il candidato|la candidata)\\b.{0,55}\\b(?:indietro|avanti|al bordo|verso (?:il )?bordo|a terra|lontano|vicino|a cedere terreno|a guadagnare terreno)|fa\\s+(?:avanzare|arretrare|indietreggiare|retrocedere)\\s+(?:${candidato}|il candidato|la candidata)\\b)`, "giu"))) {
    eventi.push({ attore: "candidato", testo: causativo[0] });
  }
  const unici = new Map(eventi.map((e) => [`${e.attore}:${e.testo}`, e]));
  return [...unici.values()];
}

function nuovoContattoRisoltoDalloSfidante(testo: string, piano: Piano): boolean {
  let precedente: AttoreNarrativo | null = null;
  for (const frase of frasi(testo)) {
    for (const m of frase.matchAll(new RegExp(CONTATTO_COMPIUTO.source, "giu"))) {
      const indice = m.index ?? 0;
      const prima = frase.slice(Math.max(0, indice - 20), indice);
      if (soggettoAmbientale(frase.slice(0, indice))) continue;
      if (/^tocc/iu.test(m[0]) && /\bsi\s*$/iu.test(prima)) continue;
      const dopoRiflessivo = frase.slice(indice + m[0].length, indice + m[0].length + 80);
      if (/^(?:tocc|sfior)/iu.test(m[0]) && /\b(?:propri[oa]|sua|suo)\s+(?:viso|volto|spalla|braccio|torace|petto|ventre|fianco|gamba)\b/iu.test(dopoRiflessivo)) continue;
      const attore = legaVerboAdAttore(frase, indice, piano, precedente).attore;
      if (/\b(?:viene|è|resta)\s*$/iu.test(prima) && /(?:colpit|investit|raggiunt|travolt)\w*/iu.test(m[0])) {
        if (attore === "candidato") return true;
        continue;
      }
      if (/^(?:incass|ricev|subisc)/iu.test(m[0])) {
        if (attore === "candidato") return true;
        continue;
      }
      const primaCompleta = frase.slice(0, indice);
      const dopoContatto = frase.slice(indice + m[0].length, indice + m[0].length + 70);
      if (/^atterr/iu.test(m[0]) && /^\s+(?:davanti|sul tatami|a terra)\b/iu.test(dopoContatto)) continue;
      if (/\b(?:colpo|pugno|calcio|nocca|palmo|gomito|ginocchio)\s*$/iu.test(primaCompleta)
        && new RegExp(`\\b${ZONA_CORPO}\\b`, "iu").test(dopoContatto)) return true;
      const dopo = frase.slice(indice + m[0].length, indice + m[0].length + 70);
      const candidatoBersaglio = new RegExp(`\\b(?:${escapeRegExp(piano.riferimenti.candidato)}|il candidato|la candidata)\\b`, "iu").test(dopo);
      if (attore === "sfidante" || candidatoBersaglio) return true;
    }
    precedente = soggettoPersistente(frase, piano) ?? precedente;
  }
  return false;
}

function candidatoSubisceContatto(testo: string, piano: Piano): boolean {
  const candidato = `(?:${escapeRegExp(piano.riferimenti.candidato)}|il candidato|la candidata)`;
  return new RegExp(`\\b${candidato}\\b\\s*,?\\s*(?:(?:è|viene|resta)\\s+(?:colpit\\w*|investit\\w*|raggiunt\\w*|travolt\\w*)|(?:incass|ricev|subisc)\\w*)\\b`, "iu").test(testo);
}

/** Controlli comuni a ogni testo pubblicabile. */
function controllaTesto(dove: string, t: string, piano: Piano, p: PayloadV5, v: Verdetto, opts: { finale: boolean; fiato?: boolean }) {
  const r = piano.riferimenti;
  if (/[0-9]/.test(t)) v.errori.push(`${dove}: contiene una cifra`);
  if (/[\u0000-\u0009\u000B-\u001F\u007F]/u.test(t)) v.errori.push(`${dove}: contiene un carattere di controllo non pubblicabile`);
  if (/[\r\n\u0085\u2028\u2029]/u.test(t)) v.errori.push(`${dove}: contiene un a capo o separatore di riga e non è un paragrafo unico`);
  if (/«\s*»/u.test(t)) v.errori.push(`${dove}: contiene una battuta vuota`);
  if (/["“”<>]/u.test(t) || !caporaliValide(t)) {
    v.errori.push(`${dove}: le battute devono usare soltanto le caporali «…» e chiuderle correttamente`);
  }
  const m = t.match(META);
  if (m) v.errori.push(`${dove}: lessico di gioco «${m[0]}»`);
  const pl = t.match(PROMPT_LEAK);
  if (pl) v.errori.push(`${dove}: metalinguaggio da prompt «${pl[0]}»`);
  const nota = t.match(NOTA_STESURA);
  if (nota) v.errori.push(`${dove}: contiene una nota di stesura o correzione «${nota[0]}»`);
  if (!opts.finale && /coprifronte/iu.test(t)) v.errori.push(`${dove}: il coprifronte compare fuori dal finale (R7)`);
  if (/\b(?:un|una|il|la)\s+(?:(?:terz|altr)[oa]\s+)?(?:alliev[oa]|maestr[oa]|sensei|ninja|kunoichi|bidell\w*|ragazz[oa]|persona|uomo|donna|sconosciut[oa]|spettator\w*|spettatric\w*|osservator\w*)\b/iu.test(t)
    || /\b(?:un|una|il|la)\s+(?:figura|sagoma)\s+(?:entra\w*|arriva\w*|compare\w*|osserva\w*|dice|grida\w*|parla\w*|corre(?!ct|tt)\w*|avanza\w*|arretra\w*|sorride\w*|ride\w*|annuisce\w*|tossisce\w*|si muove)\b/iu.test(t)) {
    v.errori.push(`${dove}: introduce una persona estranea ai presenti nella ricevuta`);
  }
  const luogo = ((p.scena as Record<string, unknown>)?.luogo ?? {}) as Record<string, unknown>;
  const nonEsistono = Array.isArray(luogo.non_esistono) ? luogo.non_esistono.map(String) : [];
  for (const assente of nonEsistono) {
    const n = normalizzaStile(assente);
    if (n.length >= 3 && normalizzaStile(t).includes(n)) v.errori.push(`${dove}: introduce un elemento dichiarato assente dalla scena`);
    if (/\barmi?\b/iu.test(assente) && /\b(?:spada|katana|kunai|shuriken|lancia|arco|pugnale)\b/iu.test(t)) {
      v.errori.push(`${dove}: introduce un'arma dichiarata assente dalla scena`);
    }
  }
  const nomiAmmessi = new Set([r.candidato, r.sfidante, r.sensei].filter(Boolean).flatMap((x) => String(x).split(/\s+/u)));
  // Le parole maiuscole già presenti nella ricevuta possono aprire una frase
  // senza diventare falsi nomi propri. Un nome nuovo resta invece bloccante.
  const lessicoAutoritativo = new Set(normalizzaStile(JSON.stringify({
    scena: p.scena, dossier: p.dossier, sensei: p.sensei, intenzioni: p.intenzioni,
  })).split(" ").filter((x) => x.length >= 3));
  const ingressoPersona = /(?:^|[.;:]\s*|\b(?:poi|mentre|quando)\s+)((?:\p{Lu}[\p{L}’'-]+)(?:\s+e\s+\p{Lu}[\p{L}’'-]+)*)\s+(?:entra\w*|arriva\w*|compare\w*|osserva\w*|dice|dicono|grida\w*|parla\w*|corre(?!ct|tt)\w*|avanza\w*|arretra\w*|sorride\w*|ride\w*|annuisce\w*|tossisce\w*|resta\w*)\b/gu;
  for (const estraneo of t.matchAll(ingressoPersona)) {
    const codaClausola = t.slice((estraneo.index ?? 0) + estraneo[0].length).split(/[.!?;:]/u, 1)[0].slice(0, 120);
    const comportamentoPersonale = /\b(?:osserva\w*|dice|dicono|grida\w*|parla\w*|sorride\w*|ride\w*|annuisce\w*|tossisce\w*)\b/iu.test(`${estraneo[0]} ${codaClausola}`);
    for (const nome of estraneo[1].split(/\s+e\s+/u)) {
      if (!nomiAmmessi.has(nome) && (!lessicoAutoritativo.has(normalizzaStile(nome)) || comportamentoPersonale)) {
        v.errori.push(`${dove}: nomina una persona non presente nella ricevuta (${nome})`);
      }
    }
  }
  const complementoPersona = /\b(?:guarda|osserva|fissa|chiama|indica|segue|affronta|saluta|ascolta|riconosce|parla a|si rivolge a|si volta verso)\s+(\p{Lu}[\p{L}’'-]+)\b/gu;
  for (const estraneo of t.matchAll(complementoPersona)) {
    if (!nomiAmmessi.has(estraneo[1])) v.errori.push(`${dove}: nomina una persona non presente nella ricevuta (${estraneo[1]})`);
  }
  if (ESEMPIO_PROMPT_FRASI.some((esempio) => haCopiaLunga(t, esempio))) {
    v.errori.push(`${dove}: ricopia testualmente l'esempio interno al prompt`);
  }
  // R2 · nessuna voce al candidato
  const cand = r.candidato; const sfid = r.sfidante; const sensei = r.sensei;
  const tutteFrasi = frasi(t);
  const intervalliFrasi = (() => {
    let da = 0;
    return tutteFrasi.map((frase) => {
      const inizio = t.indexOf(frase, da); da = Math.max(da, inizio + frase.length);
      return { frase, inizio: Math.max(0, inizio), fine: Math.max(0, inizio) + frase.length };
    });
  })();
  for (const b of battuteCon(t)) {
    const iFr = intervalliFrasi.findIndex((x) => b.idx >= x.inizio && b.idx < x.fine);
    const intervallo = iFr >= 0 ? intervalliFrasi[iFr] : null;
    const fr = intervallo?.frase ?? t.slice(Math.max(0, b.idx - 160), b.idx + b.testo.length + 160);
    const iBattuta = intervallo ? b.idx - intervallo.inizio + 1 : fr.indexOf(b.testo);
    const primaBattuta = fr.slice(0, iBattuta >= 0 ? iBattuta : fr.length).replace(/[«“"<]\s*$/u, "");
    const dopoBattuta = (iBattuta >= 0 ? fr.slice(iBattuta + b.testo.length) : "").replace(/^\s*[»”">]\s*/u, "").split(/\b(?:mentre|poi|quindi|ma|invece)\b|[.;:]/u, 1)[0];
    const colonAttore = /:\s*$/u.test(primaBattuta) ? soggettoPersistente(primaBattuta.slice(0, -1), piano) : null;
    const candidatoEsplicito = attribuisceVoce(primaBattuta, cand, "il candidato", [sfid, "lo sfidante", "la sfidante", ...(sensei ? [sensei, "il sensei", "la sensei"] : [])])
      || attribuisceVoce(dopoBattuta, cand, "il candidato", [sfid, "lo sfidante", "la sfidante"]);
    const sfidanteEsplicito = attribuisceVoce(primaBattuta, sfid, "lo sfidante", [cand, "il candidato", ...(sensei ? [sensei, "il sensei", "la sensei"] : [])])
      || attribuisceVoce(dopoBattuta, sfid, "lo sfidante", [cand, "il candidato"])
      || (sensei ? attribuisceVoce(primaBattuta, sensei, "il sensei", [cand, sfid, "il candidato", "lo sfidante"]) || attribuisceVoce(primaBattuta, sensei, "la sensei", [cand, sfid, "il candidato", "lo sfidante"]) : false);
    const parlaCandidato = candidatoEsplicito || (!sfidanteEsplicito && colonAttore === "candidato");
    const parlaSfidante = sfidanteEsplicito || (!candidatoEsplicito && colonAttore === "sfidante");
    if (parlaCandidato) { v.errori.push(`${dove}: battuta «${b.testo.slice(0, 40)}» attribuita al candidato (R2)`); continue; }
    if (!parlaSfidante) {
      const prima = iFr > 0 ? tutteFrasi[iFr - 1] : "";
      const attribuitaPrima = attribuisceVoce(prima, sfid, "lo sfidante", [cand, "il candidato"])
        || (sensei ? attribuisceVoce(prima, sensei, "il sensei", [cand, sfid, "il candidato", "lo sfidante"]) : false);
      if (!attribuitaPrima) v.errori.push(`${dove}: battuta «${b.testo.slice(0, 40)}» senza attribuzione esplicita`);
    }
    // R5 · niente frasi fatte, niente battute già dette
    const n = normalizzaBattuta(b.testo);
    if (n.length >= 4 && r.esempi_scheda.includes(n)) v.qualita.push(`${dove}: battuta recitata dalla scheda «${b.testo.slice(0, 40)}» (R5)`);
    if (n.length >= 6 && r.battute_gia_dette.includes(n)) v.qualita.push(`${dove}: battuta già detta in questa prova «${b.testo.slice(0, 40)}» (R5)`);
  }
  for (const frase of tutteFrasi) {
    if (!battuteCon(frase).length && attribuisceDiscorsoIndiretto(frase, piano)) {
      v.errori.push(`${dove}: discorso diretto o indiretto attribuito al candidato (R2)`);
    }
  }
  // R3 · il fiato solo dove la ricevuta lo dice
  if (FIATO.test(t) && !opts.fiato && !/fiato/iu.test(String(r.conseguenza ?? ""))) {
    if (r.fiato_in_memoria) v.avvisi.push(`${dove}: il fiato torna dalla memoria dei colpi (continuità, non formula)`);
    else v.errori.push(`${dove}: «fiato spezzato» senza una conseguenza al fiato nella ricevuta (R3)`);
  }
  // anti-ripetizione entro la prova: nessuna frase lunga già pubblicata
  const prec = p.stile_precedente.filter((e) => e.voce === "narratore").map((e) => e.testo.toLowerCase());
  for (const f of frasi(t)) {
    if (f.length >= 60 && prec.some((x) => x.includes(f.toLowerCase().slice(0, 60)))) { v.qualita.push(`${dove}: frase già pubblicata in questa prova`); break; }
  }
  if (TONO_REFERTO.test(t)) v.qualita.push(`${dove}: tono da referto invece di scena`);
  let soggettoPrima: AttoreNarrativo | null = null;
  for (const f of tutteFrasi) {
    let pensieroCandidato = candidatoSiSente(f, cand) || emozioneDelCandidato(f, cand) || statoInternoNominale(f, cand);
    for (const m of f.matchAll(new RegExp(PENSIERO_PG.source, "giu"))) {
      if (legaVerboAdAttore(f, m.index ?? 0, piano, soggettoPrima).attore === "candidato") pensieroCandidato = true;
    }
    if (pensieroCandidato) v.errori.push(`${dove}: attribuisce pensiero, emozione o decisione al candidato`);
    soggettoPrima = soggettoPersistente(f, piano) ?? soggettoPrima;
  }
}

function fontiPerTesto(x: unknown): string[][] | null {
  if (!Array.isArray(x)) return null;
  const out: string[][] = [];
  for (const riga of x) {
    if (!Array.isArray(riga) || riga.some((x) => typeof x !== "string")) return null;
    out.push([...new Set(riga as string[])]);
  }
  return out;
}

function haCopiaLunga(testo: string, fonte: string): boolean {
  const parole = normalizzaStile(fonte).split(" ").filter(Boolean);
  const prosa = normalizzaStile(testo);
  if (parole.length < 5) return parole.length >= 2 && prosa.includes(parole.join(" "));
  for (let i = 0; i <= parole.length - 5; i++) if (prosa.includes(parole.slice(i, i + 5).join(" "))) return true;
  return false;
}

export function claimCorrisponde(piano: Piano, id: string, frase: string): boolean {
    const claim = piano.player_bridge.claims.find((c) => c.id === id);
    if (!claim) return false;
    if (claim.tipo === "battuta") return battutaRispondeAlSegnale(claim.action, frase);
    const segnaliPerTipo: Partial<Record<typeof claim.tipo, RegExp>> = {
      manovra_tentata: /\b(?:tent\w*|prov\w*|cerc\w*|avanz\w*|arretr\w*|scatt\w*|scart\w*|sgusci\w*|balz\w*|salt\w*|ruot\w*|gir\w*|spost\w*|allontan\w*|avvicin\w*|affond\w*|slanci\w*|pieg\w*|flett\w*|sollev\w*|port\w*|colp\w*|calci\w*|pugn\w*)\b/iu,
      difesa_tentata: /\b(?:par\w*|schiv\w*|guardia|proteg\w*|devi\w*|intercett\w*|contrast\w*|ripar\w*|scans\w*)\b/iu,
      traiettoria: /\b(?:dirig\w*|devia\w*|porta\w*|traccia\w*|muov\w*|sinistra|destra|alto|basso|arco|linea|fianco|spalle)\b/iu,
      bersaglio_dichiarato: /\b(?:mir\w*|punt\w*|dirig\w*|indirizz\w*|bersagli\w*|attacc\w*|colp\w*|sferr\w*|porta\w*)\b/iu,
      vincolo_autoimposto: /\b(?:rinuncia\w*|evita\w*|senza|non\s+usa\w*|limita\w*|impone\w*)\b/iu,
      postura: /\b(?:assum\w*|sistem\w*|string\w*|mant\w*|abbass\w*|alz\w*|guardia|postura|peso|baricentro)\b/iu,
    };
    const segnaleAttore = segnaliPerTipo[claim.tipo];
    if (!segnaleAttore) return false;
    const cand = escapeRegExp(piano.riferimenti.candidato); const sfid = escapeRegExp(piano.riferimenti.sfidante);
    const marcata = frase.replace(new RegExp(`\\be\\s+(?=(?:${cand}|${sfid}|il candidato|la candidata|lo sfidante|la sfidante)\\b)`, "giu"), "§");
    const clausole = marcata.split(/§|[.;:]|\b(?:mentre|ma|invece|poi|quindi)\b/iu).map((x) => x.trim()).filter(Boolean);
    const clausoleCandidate = clausole.filter((clausola) => [...clausola.matchAll(new RegExp(segnaleAttore.source, "giu"))]
      .some((m) => legaVerboAdAttore(clausola, m.index ?? 0, piano, null).attore === "candidato"));
    if (!clausoleCandidate.length) return false;
    const fraseClaim = clausoleCandidate.join(" ");
    if (claim.tipo === "postura" && claim.action.includes("baricentro basso")) {
      return /\b(?:abbass\w*|basso|pieg\w*)\b.{0,35}\b(?:baricentro|ginocchi\w*)\b|\b(?:baricentro|ginocchi\w*)\b.{0,35}\b(?:abbass\w*|basso|pieg\w*)\b/iu.test(fraseClaim)
        && !/\b(?:alz\w*|sollev\w*|alto)\b.{0,30}\bbaricentro\b|\bbaricentro\b.{0,30}\b(?:alz\w*|sollev\w*|alto)\b/iu.test(fraseClaim);
    }
    if (claim.tipo === "postura" && claim.action.includes("baricentro alto")) {
      return /\b(?:alz\w*|sollev\w*|alto)\b.{0,30}\bbaricentro\b|\bbaricentro\b.{0,30}\b(?:alz\w*|sollev\w*|alto)\b/iu.test(fraseClaim)
        && !/\b(?:abbass\w*|basso|pieg\w*)\b.{0,35}\b(?:baricentro|ginocchi\w*)\b/iu.test(fraseClaim);
    }
    if (claim.tipo === "postura" && claim.action.includes("peso in avanti")) return /\bpeso\b.{0,24}\b(?:avanti|anteriore)\b/iu.test(fraseClaim) && !/\b(?:non|senza|evita\w*)\b.{0,35}\b(?:porta\w*\s+)?(?:il\s+)?peso\b|\bpeso\b.{0,24}\b(?:indietro|posteriore)\b/iu.test(fraseClaim);
    if (claim.tipo === "postura" && claim.action.includes("peso indietro")) return /\bpeso\b.{0,24}\b(?:indietro|posteriore)\b/iu.test(fraseClaim) && !/\b(?:non|senza|evita\w*)\b.{0,35}\b(?:porta\w*\s+)?(?:il\s+)?peso\b|\bpeso\b.{0,24}\b(?:avanti|anteriore)\b/iu.test(fraseClaim);
    if (claim.tipo === "traiettoria" && /\bsinistra\b/iu.test(claim.action)) return /\bsinistra\b/iu.test(fraseClaim) && !/\b(?:non|senza|evita\w*|si guarda bene dal|si astiene dal)\b.{0,45}\bsinistra\b|\bdestra\b/iu.test(fraseClaim);
    if (claim.tipo === "traiettoria" && /\bdestra\b/iu.test(claim.action)) return /\bdestra\b/iu.test(fraseClaim) && !/\b(?:non|senza|evita\w*|si guarda bene dal|si astiene dal)\b.{0,45}\bdestra\b|\bsinistra\b/iu.test(fraseClaim);
    if (claim.tipo === "vincolo_autoimposto" && /\bchakra\b/iu.test(claim.action)) return /\b(?:senza(?:\s+usare)?\s+chakra|non\s+usa\w*\s+(?:il\s+)?chakra|rinuncia\w*\s+(?:a usare\s+|al\s+)?chakra|evita\w*\s+(?:di usare\s+)?(?:il\s+)?chakra)\b/iu.test(fraseClaim) && !/\bnon\s+(?:rinuncia\w*|evita\w*)\b.{0,25}\bchakra\b/iu.test(fraseClaim);
    if (claim.tipo === "vincolo_autoimposto" && /\barmi\b/iu.test(claim.action)) return /\b(?:armi?|kunai|shuriken|spada)\b/iu.test(fraseClaim) && /\b(?:senza|non|rinuncia|evita)\b/iu.test(fraseClaim);
    if (claim.tipo === "vincolo_autoimposto" && /\btecniche\b/iu.test(claim.action)) return /\btecnic\w*\b/iu.test(fraseClaim) && /\b(?:senza|non|rinuncia|evita)\b/iu.test(fraseClaim);
    const stop = new Set(["tenta", "tentare", "una", "un", "di", "tipo", "assume", "cerca", "postura", "centrata", "su", "dichiara", "traiettoria", "verso", "mira", "alla", "zona", "si", "impone", "limite", "espresso", "come", "gesto", "dichiarato"]);
    const paroleClaim = normalizzaStile(claim.action).split(" ").filter((x) => x.length >= 4 && !stop.has(x));
    if (claim.tipo === "manovra_tentata" && /\b(?:non|senza|invano|senza successo|si astiene|si guarda bene)\b.{0,45}\b(?:avanz\w*|arretr\w*|spost\w*|muov\w*|scatt\w*|scart\w*|sgusci\w*)\b/iu.test(fraseClaim)) return false;
    const paroleFrase = new Set(normalizzaStile(fraseClaim).split(" "));
    if (!paroleClaim.some((x) => paroleFrase.has(x) || [...paroleFrase].some((y) => y.startsWith(x.slice(0, 5)) || x.startsWith(y.slice(0, 5))))) return false;
    if (claim.tipo === "bersaglio_dichiarato") {
      const zonaClaim = ["viso", "spalla", "braccio", "torace", "ventre", "fianco", "gamba"].find((x) => claim.action.includes(x));
      if (zonaClaim && new RegExp(`(?:\\b(?:non|senza)\\b.{0,40}\\b(?:mira\\w*|punta\\w*|dirige\\w*|colp\\w*|raggiung\\w*)\\b.{0,35}\\b${zonaClaim}\\b|\\b(?:evita\\w*|schiva\\w*|ignora\\w*|si astiene dal)\\b.{0,40}\\b${zonaClaim}\\b)`, "iu").test(fraseClaim)) return false;
      if (zonaClaim && !fraseClaim.includes(zonaClaim)) return false;
    }
    return true;
}

function controllaProvenienza(uscita: Record<string, unknown>, azione: string, esiti: Record<string, unknown>, p: PayloadV5, piano: Piano, v: Verdetto) {
  const disponibili = new Set(piano.riferimenti.fonti_disponibili);
  const usate = new Set<string>();
  const controlla = (dove: string, testo: string, grezze: unknown) => {
    const righe = fontiPerTesto(grezze);
    if (!righe) { v.errori.push(`${dove}: traccia frase-per-fonte malformata`); return; }
    const frasiTesto = frasi(testo);
    const nFrasi = frasiTesto.length;
    if (righe.length !== nFrasi) v.errori.push(`${dove}: ${righe.length} righe fonte per ${nFrasi} frasi`);
    for (const [i, fonti] of righe.entries()) {
      if (!fonti.length) v.errori.push(`${dove}: frase senza fonte`);
      if (fonti.length && fonti.every((x) => x === "memoria.stile")) v.errori.push(`${dove}: memoria.stile non autorizza fatti`);
      for (const fonte of fonti) {
        if (!disponibili.has(fonte)) v.errori.push(`${dove}: fonte non autorizzata «${fonte}»`);
        if (fonte.startsWith("claim.")) {
          usate.add(fonte);
          if (!claimCorrisponde(piano, fonte, frasiTesto[i] ?? "")) v.errori.push(`${dove}: il claim «${fonte}» non corrisponde semanticamente alla frase`);
        }
      }
    }
  };

  controlla("azione_png", azione, uscita.fonti_azione);
  const fontiEsiti = uscita.fonti_esiti && typeof uscita.fonti_esiti === "object" ? uscita.fonti_esiti as Record<string, unknown> : {};
  for (const [k, testo] of Object.entries(esiti)) controlla(`branca «${k}»`, String(testo ?? ""), fontiEsiti[k]);
  if (JSON.stringify(Object.keys(fontiEsiti).sort()) !== JSON.stringify(Object.keys(esiti).sort())) v.errori.push("fonti_esiti non allineate alle branche");

  const dichiarateRaw = Array.isArray(uscita.player_reprise_ids) ? uscita.player_reprise_ids : null;
  if (!dichiarateRaw || dichiarateRaw.some((x) => typeof x !== "string")) {
    v.errori.push("player_reprise_ids malformato");
    return;
  }
  const dichiarate = new Set(dichiarateRaw as string[]);
  if (dichiarate.size !== dichiarateRaw.length) v.errori.push("player_reprise_ids contiene duplicati");
  for (const id of dichiarate) if (!piano.riferimenti.player_claim_ids.includes(id)) v.errori.push(`player_reprise senza licenza «${id}»`);
  for (const id of usate) if (!dichiarate.has(id)) v.errori.push(`claim usato senza dichiarazione player_reprise «${id}»`);
  for (const id of dichiarate) if (!usate.has(id)) v.errori.push(`player_reprise dichiarata ma non ancorata a una frase «${id}»`);

  const testiPubblicabili = [azione, ...Object.values(esiti).map(String)].join(" ");
  for (const id of dichiarate) {
    const claim = piano.player_bridge.claims.find((c) => c.id === id);
    if (claim && haCopiaLunga(testiPubblicabili, claim.action)) v.errori.push(`ripresa testuale del claim «${id}»: servono parole proprie`);
  }
  for (const detta of piano.riferimenti.player_utterances) {
    const n = normalizzaStile(detta);
    const copiaInBattuta = [azione, ...Object.values(esiti).map(String)].flatMap(battuteCon).some((b) => normalizzaStile(b.testo) === n);
    if (copiaInBattuta || haCopiaLunga(testiPubblicabili, detta)) v.errori.push("il parlato letterale del candidato è stato copiato nella prosa");
  }
  const battuteOriginali = [...String(p.contesto_pg ?? "").matchAll(/«([^»]+)»|“([^”]+)”|"([^"\n]+)"|<([^<>\n]+)>/gu)]
    .map((m) => (m[1] ?? m[2] ?? m[3] ?? m[4] ?? "").trim()).filter(Boolean);
  for (const detta of battuteOriginali) {
    const n = normalizzaStile(detta);
    const copiaInBattuta = [azione, ...Object.values(esiti).map(String)].flatMap(battuteCon).some((b) => normalizzaStile(b.testo) === n);
    if (copiaInBattuta || haCopiaLunga(testiPubblicabili, detta)) v.errori.push("il parlato letterale del candidato è stato copiato nella prosa");
  }

  const famigliaMovimento = (testo: string): string | null => {
    if (/\b(?:avanz\w*|avvicin\w*|guadagna terreno|si fa avanti|accorcia\w* (?:la )?distanza)\b/iu.test(testo)) return "avanti";
    if (/\b(?:arretr\w*|retroced\w*|indietreggi\w*|ritir\w*|allontan\w*|cede terreno|perde terreno|prende le distanze|si fa indietro|scivol\w* (?:all['’]indietro|indietro)|proiettat\w* (?:all['’]indietro|indietro))\b/iu.test(testo)) return "indietro";
    if (/\b(?:scatt\w*|corr\w*|balz\w*|salt\w*)\b/iu.test(testo)) return "slancio";
    if (/\b(?:cammin\w*|spost\w*|muov\w*|attravers\w*|scart\w*|sgusci\w*)\b/iu.test(testo)) return "generico";
    return null;
  };
  const claimAutorizzaMovimento = (evento: EventoMovimento, fonti: string[]): boolean => {
    if (!MOVIMENTO_TENTATO.test(evento.testo)) return false;
    const famiglia = famigliaMovimento(evento.testo);
    if (!famiglia) return false;
    return fonti.some((id) => {
      const claim = piano.player_bridge.claims.find((c) => c.id === id);
      if (!claim || claim.tipo !== "manovra_tentata" || famigliaMovimento(claim.action) !== famiglia) return false;
      const ampiezza = /\b(?:un|due|tre|più|molti|diversi|parecchi|numerosi|tutt\w*) pass[oi]\b|\b(?:bordo|lunghezza|inter[oa] (?:tatami|aula)|tutt[oa] (?:il tatami|l['’]aula)|quasi tutt[oa] (?:il tatami|l['’]aula)|(?:gran|buona|larga) parte (?:del tatami|dell['’]aula)|metà (?:del tatami|dell['’]aula)|molto terreno|grande distanza|ampio spazio|parecchio terreno|lungo tratto)\b|\bda un capo all['’]altro\b/iu;
      if (ampiezza.test(evento.testo) && !ampiezza.test(claim.action)) return false;
      return true;
    });
  };
  const controllaMovimenti = (dove: string, testo: string, grezze: unknown) => {
    const righe = fontiPerTesto(grezze);
    let precedente: AttoreNarrativo | null = null;
    for (const [i, frase] of frasi(testo).entries()) {
      const fonti = righe?.[i] ?? [];
      if (VARIAZIONE_DISTANZA.test(frase) && !fonti.some((x) => x.startsWith("server.posizione."))) {
        v.errori.push(`${dove}: variazione della distanza senza fonte di posizione nella stessa frase`);
      }
      const eventi = analizzaMovimenti(frase, piano, precedente);
      for (const evento of eventi) {
        const autorizzato = evento.attore === "candidato"
          ? fonti.includes("server.posizione.esito.candidato")
            || claimAutorizzaMovimento(evento, fonti)
          : fonti.includes("server.posizione.esito.sfidante") || fonti.includes("server.posizione.intenzione");
        if (!autorizzato) {
          const dettaglio = evento.attore === "candidato"
            ? "movimento del candidato senza fonte server o player_reprise nella stessa frase"
            : "movimento dello sfidante senza la propria fonte di posizione nella stessa frase";
          v.errori.push(`${dove}: ${dettaglio}`);
        }
      }
      precedente = soggettoPersistente(frase, piano) ?? precedente;
    }
  };
  controllaMovimenti("azione_png", azione, uscita.fonti_azione);
  for (const [k, testo] of Object.entries(esiti)) controllaMovimenti(`branca «${k}»`, String(testo ?? ""), fontiEsiti[k]);
}

function formuleDi(frase: string): string[] {
  const parole = normalizzaStile(frase).split(" ").filter(Boolean);
  if (parole.length < 7) return [];
  return [parole.slice(0, 7).join(" "), parole.slice(-7).join(" ")];
}

function chiusuraConAssetto(chiusura: string, piano: Piano): boolean {
  const candidato = `(?:${escapeRegExp(piano.riferimenti.candidato)}|il candidato|la candidata)`;
  const sfidante = `(?:${escapeRegExp(piano.riferimenti.sfidante)}|lo sfidante)`;
  const nominaEntrambi = new RegExp(`\\b${candidato}\\b`, "iu").test(chiusura)
    && new RegExp(`\\b${sfidante}\\b`, "iu").test(chiusura);
  const relazioneSpaziale = /\b(?:davanti|di fronte|addosso|separat\w*|vicin\w*|lontan\w*|distanza|misura|bordo|centro del tatami|ai lati|fra loro|tra loro)\b/iu.test(chiusura);
  const destinatario = `(?:${candidato}|${sfidante})`;
  const passaggioIniziativa = new RegExp(`(?:\\biniziativa\\b.{0,48}\\b${destinatario}\\b|\\b${destinatario}\\b.{0,48}\\biniziativa\\b)`, "iu").test(chiusura);
  return nominaEntrambi && relazioneSpaziale && passaggioIniziativa;
}

function controllaQualita(uscita: Record<string, unknown>, azione: string, esiti: Record<string, unknown>, p: PayloadV5, piano: Piano, v: Verdetto) {
  const testi = [azione, ...Object.values(esiti).map(String)];
  const memoria = piano.riferimenti.memoria_stile;
  for (const testo of testi) {
    const nuove = frasi(testo);
    for (const nuova of nuove) {
      if (memoria.frasi.some((vecchia) => similaritaStile(nuova, vecchia) >= 0.72)) {
        v.qualita.push("formula o immagine troppo simile a una frase già pubblicata");
        break;
      }
    }
    if (nuove.flatMap(formuleDi).some((nuova) => memoria.formule.some((vecchia) => similaritaStile(nuova, vecchia) >= 0.82))) {
      v.qualita.push("formula d'apertura o chiusura già usata nella prova");
    }
    if (nuove.some((nuova) => memoria.immagini.some((vecchia) => similaritaStile(nuova, vecchia) >= 0.58))) {
      v.qualita.push("immagine narrativa troppo simile a una già usata nella prova");
    }
    const chiusura = nuove.at(-1) ?? "";
    if (chiusura && memoria.chiusure.some((vecchia) => similaritaStile(chiusura, vecchia) >= 0.62)) {
      v.qualita.push("chiusura troppo simile a una già usata nella prova");
    }
    // L'assetto può emergere nell'intera scena, non da una formula nell'ultima
    // frase. Terra verifica leggibilità e iniziativa sulla ricevuta; i controlli
    // deterministici di identità, posizione ed esito rimangono invariati.
  }

  const fonti = [uscita.fonti_azione, ...Object.values((uscita.fonti_esiti && typeof uscita.fonti_esiti === "object") ? uscita.fonti_esiti as Record<string, unknown> : {})]
    .flatMap((x) => fontiPerTesto(x) ?? []).flat();
  if (!fonti.includes("persona.sfidante")) v.qualita.push("la prosa non ancora lo sfidante alla sua persona");
  if (!fonti.includes("server.scena")) v.qualita.push("la prosa non ancora l'ambiente alla scena autoritativa");

  const battute = battuteCon(azione);
  if (piano.riferimenti.player_ha_domanda) {
    const domande = piano.player_bridge.claims.filter((c) => c.tipo === "battuta" && c.action.includes("pone una domanda"));
    const righe = fontiPerTesto(uscita.fonti_azione) ?? [];
    const rispostaAncorata = frasi(azione).some((frase, i) => domande.some((domanda) => (righe[i] ?? []).includes(domanda.id) && battutaRispondeAlSegnale(domanda.action, frase)));
    if (!rispostaAncorata) v.qualita.push("il candidato ha posto una domanda ma la risposta dello sfidante non è ancorata a quella battuta");
  }
  if (battute.some((b) => normalizzaStile(b.testo).split(" ").length <= 3) && !/\b(?:sguardo|mano|piede|passo|spalla|fiato|sorriso|mascella|indica|guarda|accenna)\b/iu.test(azione)) {
    v.qualita.push("battuta ellittica senza gesto che la renda comprensibile");
  }
}

function controllaAmpiezza(uscita: Record<string, unknown>, azione: string, esiti: Record<string, unknown>, p: PayloadV5, piano: Piano, v: Verdetto) {
  const provenienzaDeterministica = uscita.provenienza_deterministica === true;
  const ref = (p.esito_precedente ?? {}) as Record<string, unknown>;
  const intenzione = p.intenzioni.find((i) => i.id === uscita.intenzione_id);
  const movimenti = Array.isArray(ref.movimenti_autoritativi) ? ref.movimenti_autoritativi as Array<Record<string, unknown>> : [];
  const casi: Array<{ fonte: string; valore: string | null; direzione: string; attore: "candidato" | "sfidante" }> = movimenti.flatMap((m) => {
    if (typeof m.ampiezza !== "string" || typeof m.direzione !== "string") return [];
    const attore = m.attore_ref === "actor.candidate" ? "candidato" : "sfidante";
    return [{ fonte: `server.posizione.esito.${attore}`, valore: m.ampiezza, direzione: m.direzione, attore }];
  });
  if (typeof intenzione?.movimento === "string" && ["guadagna terreno", "cede terreno", "resta sulla misura"].includes(intenzione.movimento)) {
    casi.push({ fonte: "server.posizione.intenzione", valore: typeof intenzione.ampiezza === "string" ? intenzione.ampiezza : null, direzione: intenzione.movimento, attore: "sfidante" });
  }
  const testi = [
    { dove: "azione_png", testo: azione, righe: fontiPerTesto(uscita.fonti_azione) ?? [] },
    ...Object.entries(esiti).map(([k, testo]) => ({
      dove: `branca «${k}»`, testo: String(testo ?? ""),
      righe: fontiPerTesto((uscita.fonti_esiti as Record<string, unknown> | undefined)?.[k]) ?? [],
    })),
  ];
  const sequenze = testi.map((blocco) => {
    let ultimo: AttoreNarrativo | null = null;
    const righe = frasi(blocco.testo).map((frase, i) => {
      const menzioni = new Set(menzioniAttori(frase, piano).map((m) => m.attore));
      const eventi = analizzaMovimenti(frase, piano, ultimo);
      const attoriMovimento = new Set(eventi.map((e) => e.attore));
      ultimo = soggettoPersistente(frase, piano) ?? ultimo;
      return { dove: blocco.dove, frase, fonti: blocco.righe[i] ?? [], menzioni, attoriMovimento, eventi };
    });
    return righe;
  }).flat();
  for (const riga of sequenze) {
    for (const attore of riga.attoriMovimento) {
      const fontiAttore = new Set(casi.filter((c) => c.attore === attore).map((c) => c.fonte));
      if (fontiAttore.size && !riga.fonti.some((x) => fontiAttore.has(x))) {
        v.errori.push(`${riga.dove}: movimento dello ${attore} senza la propria fonte di posizione`);
      }
    }
  }
  for (const { fonte, valore, direzione, attore } of casi) {
    const ancorate = sequenze.filter((riga) => riga.fonti.includes(fonte));
    if (valore === null && direzione !== "resta sulla misura" && ancorate.length === 0) {
      v.errori.push(`direzione autoritativa «${direzione}» omessa (${fonte})`);
      continue;
    }
    if (valore !== null && valore !== "nessuno" && ancorate.length === 0) {
      v.errori.push(`ampiezza autoritativa «${valore}» omessa (${fonte})`);
      continue;
    }
    const blocchi = new Map<string, typeof ancorate>();
    for (const riga of ancorate) blocchi.set(riga.dove, [...(blocchi.get(riga.dove) ?? []), riga]);
    for (const [doveBlocco, righeBlocco] of blocchi) {
      const eventiBlocco = righeBlocco.flatMap((riga) => riga.eventi.filter((e) => e.attore === attore));
      if ((direzione !== "resta sulla misura" || (valore !== null && valore !== "nessuno")) && eventiBlocco.length === 0) {
        v.errori.push(valore === null
          ? `direzione autoritativa «${direzione}» omessa (${fonte}, ${doveBlocco})`
          : `ampiezza autoritativa «${valore}» omessa (${fonte}, ${doveBlocco})`);
        continue;
      }
      if (valore !== null && valore !== "nessuno" && eventiBlocco.length > 1) {
        v.errori.push(`${fonte}: movimento autoritativo ripetuto più volte in ${doveBlocco}`);
      }
      for (const { dove, menzioni, attoriMovimento, eventi } of righeBlocco) {
        const propri = eventi.filter((e) => e.attore === attore).map((e) => e.testo);
        if (!propri.length) {
          if (provenienzaDeterministica) continue;
          if (!menzioni.has(attore) && !attoriMovimento.has(attore)) v.errori.push(`${dove}: ${fonte} non è attribuita al proprio attore`);
          continue;
        }
        const testo = propri.join(" ");
      const base = valore?.split(",", 1)[0] ?? null;
      if (/\b(?:non\s+(?:(?:(?:intende|vuole|può|riesce|prova|accetta|accenna|osa|si decide)\s+(?:di\s+|ad?\s+|voler\s+)?|sembra\s+voler\s+|ha\s+alcuna\s+intenzione\s+di\s+))?|senza\s+|evita(?:ndo)?\s+di\s+|rinuncia\s+a\s+|rifiuta\s+di\s+|esclude\s+di\s+|si astiene dall['’]|si guarda bene dall['’]|resta\s+(?:ben\s+)?lontan\w*\s+dall['’]|è\s+resti\w*\s+ad?\s+)(?:avanz\w*|avvicin\w*|guadagna\s+terreno|arretr\w*|retroced\w*|indietreggi\w*|ritir\w*|allontan\w*|cede\s+terreno|perde\s+terreno|scivol\w*|spostarsi|muoversi|si sposta|si muove|si fa avanti|si fa indietro)\b/iu.test(testo)
        || /è\s+(?:(?:ben\s+)?lontan\w*|lungi)\s+dall['’](?:avanz\w*|avvicin\w*|arretr\w*|retroced\w*|indietreggi\w*|ritir\w*|allontan\w*)\b/iu.test(testo)) {
        v.errori.push(`${fonte}: la prosa nega il movimento autoritativo`);
      }
      if (base === "nessuno" && SPOSTAMENTO_LINEARE.test(testo)) v.errori.push(`${fonte}: racconta movimento con ampiezza «nessuno»`);
      if (base === "un passo") {
        if (!/\b(?:un passo|passo breve|breve scarto|piccolo aggiustamento|poco terreno)\b/iu.test(testo)) v.errori.push(`${fonte}: non rende l'ampiezza «un passo»`);
        if (/\b(?:due|tre|più|molti|diversi) passi\b|\b(?:corsa|lung\w+ ritirata|attravers\w+ il tatami)\b|\b(?:ripet\w*|replic\w*|continu\w*|rifà)\b.{0,55}\b(?:altre?\s+)?(?:due|tre|più|diverse|molte)\s+(?:volte|riprese)\b|\b(?:un passo)\s+dopo\s+l['’]altro\b|\bun passo\b.{0,35}\b(?:ciascun\w*|ogni)\b.{0,30}\b(?:due|tre|più)\b|\bun passo\b.{0,30}\b(?:due|tre|più)\s+volte\b|\bun passo\b.{0,25}\bancora\s+e\s+ancora\b|\b(?:un passo|breve scarto)\s+a\s+(?:due|tre|più)\s+riprese\b|\b(?:due|tre|più)\s+falcat\w*\b/iu.test(testo)) v.errori.push(`${fonte}: amplia «un passo» oltre il referto`);
      }
      if (base === "due passi" && !/\b(?:due passi|un paio di passi)\b/iu.test(testo)) v.errori.push(`${fonte}: non rende l'ampiezza «due passi»`);
      if (base === "tre o più passi" && !/\b(?:tre passi|più passi|diversi passi|molti passi|corsa|falcat\w*|buona parte del tatami)\b/iu.test(testo)) v.errori.push(`${fonte}: non rende l'ampiezza «tre o più passi»`);
      if (valore?.includes("fino al bordo") && !/\bbordo\b/iu.test(testo)) v.errori.push(`${fonte}: omette l'arrivo al bordo`);
      if (valore?.includes("fermato dal bordo") && !(/\bbordo\b/iu.test(testo) && /\b(?:ferm\w*|arrest\w*|accorci\w*|tronc\w*|blocc\w*)\b/iu.test(testo))) v.errori.push(`${fonte}: omette il movimento fermato dal bordo`);
      if (direzione === "guadagna terreno" && /\b(?:arretr\w*|allontan\w*|cede terreno|perde terreno|indietro|scivol\w* all['’]indietro|proiettat\w* all['’]indietro)\b/iu.test(testo)) v.errori.push(`${fonte}: contraddice la direzione «guadagna terreno»`);
      if (direzione === "cede terreno" && /\b(?:avanz\w*|avvicin\w*|guadagna terreno|in avanti)\b/iu.test(testo)) v.errori.push(`${fonte}: contraddice la direzione «cede terreno»`);
      if (direzione === "guadagna terreno" && !/\b(?:avanz\w*|avvicin\w*|guadagna terreno|in avanti|si fa avanti|addosso|accorcia\w* (?:la )?distanza)\b/iu.test(testo)) v.errori.push(`${fonte}: non rende la direzione «guadagna terreno»`);
      if (direzione === "cede terreno" && !/\b(?:arretr\w*|retroced\w*|indietreggi\w*|ritir\w*|allontan\w*|cede terreno|perde terreno|indietro|prende le distanze|allunga\w* (?:la )?distanza|scivol\w* all['’]indietro|proiettat\w* all['’]indietro)\b/iu.test(testo)) v.errori.push(`${fonte}: non rende la direzione «cede terreno»`);
      if (direzione === "resta sulla misura" && SPOSTAMENTO_LINEARE.test(testo)) v.errori.push(`${fonte}: contraddice la direzione «resta sulla misura»`);
      }
    }
  }
}

/** Il testo deve raccontare l'esito dato: zona e riferimenti. */
function controllaEsito(dove: string, t: string, esito: string, piano: Piano, v: Verdetto, morbido = false, zona?: { bersaglio: string | null; parole: string[] }) {
  const r = piano.riferimenti;
  const z = zona ?? { bersaglio: r.bersaglio, parole: r.zona_parole };
  if (!(ESITI_NOTI as readonly string[]).includes(esito)) return;
  const c = CONTRADDIZIONI[esito];
  if (c && c.test(t)) (morbido ? v.avvisi : v.errori).push(`${dove}: contraddice l'esito «${esito}»`);
  const negato = ESITO_NEGATO[esito];
  if (negato && negato.test(t)) (morbido ? v.avvisi : v.errori).push(`${dove}: nega l'esito «${esito}»`);
  const d = DEVE_CONTENERE[esito];
  if (d && !d.test(t)) (morbido ? v.avvisi : v.errori).push(`${dove}: non racconta l'esito «${esito}»`);
  if ((esito === "colpito" || esito === "sfiorato") && z.parole.length && !contiene(t, z.parole)) {
    v.errori.push(`${dove}: il colpo «${esito}» non arriva sulla zona della ricevuta (${z.bersaglio})`);
  }
  if ((esito === "colpito" || esito === "sfiorato") && z.parole.length && bersaglioDelContattoCorretto(t, z.parole) === false) {
    v.errori.push(`${dove}: il contatto «${esito}» è legato a una zona diversa dalla ricevuta (${z.bersaglio})`);
  }
  if ((esito === "colpito" || esito === "sfiorato") && bersaglioDelContattoCorretto(t, z.parole) === null) {
    v.errori.push(`${dove}: non racconta un contatto compiuto per l'esito «${esito}»`);
  }
  if (esito === "sostituito" && r.ancora_parole.length && !contiene(t, r.ancora_parole)) {
    v.errori.push(`${dove}: la Sostituzione non nomina l'ancora della ricevuta (${r.ancora_parole.join("/")})`);
  }
  if (esito === "sostituito" && /supporto di legno/iu.test(t)) v.avvisi.push(`${dove}: «supporto di legno» generico invece dell'ancora`);
  if (esito === "sostituito" && !/\b(?:riappar\w*|ricompar\w*|riemerg\w*|si materializz\w*|torna visibil\w*)\b/iu.test(t)) {
    v.errori.push(`${dove}: la Sostituzione non mostra la riapparizione della ricevuta spaziale`);
  }
}

function controllaTecniche(uscita: Record<string, unknown>, p: PayloadV5, v: Verdetto) {
  const azione = String(uscita.azione_png ?? "");
  const intenzione = p.intenzioni.find((i) => i.id === uscita.intenzione_id);
  const ref = (p.esito_precedente ?? {}) as Record<string, unknown>;
  const ids = [...new Set([intenzione?.tecnica_id, typeof ref.tecnica_id === "string" ? ref.tecnica_id : null].filter((x): x is string => !!x))];
  for (const id of ids) {
    const scheda = p.schede_tecniche?.find((s) => s.id === id);
    if (!scheda) continue;
    if (!azione.toLocaleLowerCase("it").includes(scheda.nome.toLocaleLowerCase("it"))) {
      v.errori.push(`azione_png: non rende riconoscibile la tecnica «${scheda.nome}»`);
    }
    // Con più tecniche il paragrafo contiene stadi diversi: un divieto globale
    // attribuirebbe i sigilli dell'una all'altra. Il giudice, con entrambe le
    // schede e i rispettivi ruoli, verifica l'associazione senza fondere gli stadi.
    if (ids.length > 1) continue;
    const senzaSigilli = /(?:senza|non richiede)\s+sigill/iu.test(scheda.attivazione);
    const richiedeSigilli = !senzaSigilli && /sigill/iu.test(scheda.attivazione);
    if (richiedeSigilli && !/\bsigill\w*\b/iu.test(azione)) v.errori.push(`azione_png: omette i sigilli richiesti da «${scheda.nome}»`);
    if (senzaSigilli && /\bsigill\w*\b/iu.test(azione)) v.errori.push(`azione_png: inventa sigilli esclusi dalla scheda «${scheda.nome}»`);
    if (!/\b(?:nessun\w*|zero)\b/iu.test(scheda.chakra) && !/\bchakra\b/iu.test(azione)) {
      v.errori.push(`azione_png: omette la preparazione del chakra per «${scheda.nome}»`);
    }
  }
}

function controllaContrattoSegmenti(uscita: Record<string, unknown>, p: PayloadV5, piano: Piano, v: Verdetto) {
  const errori = uscita.contratto_segmenti_errori;
  if (!Array.isArray(errori) || errori.some((x) => typeof x !== "string")) {
    v.errori.push("contratto interno dei segmenti assente o malformato");
    return;
  }
  v.errori.push(...errori as string[]);
  const interni = uscita._segmenti_interni;
  if (!interni || typeof interni !== "object" || Array.isArray(interni)) {
    v.errori.push("mappa interna dei segmenti assente o malformata");
    return;
  }
  const azione = ((interni as Record<string, unknown>).azione ?? {}) as Record<string, unknown>;
  const rami = ((interni as Record<string, unknown>).esiti ?? {}) as Record<string, unknown>;
  const assetto = typeof azione.assetto_finale === "string" ? azione.assetto_finale : "";
  if (assetto && !chiusuraConAssetto(assetto, piano)) v.errori.push("segmento assetto_finale: nuovo assetto non leggibile");
  const risposta = typeof azione.risposta_fisica === "string" ? azione.risposta_fisica : "";
  if (risposta && !/\b(?:corpo|pelle|stoffa|spalla|braccio|mano|dita|torace|petto|ventre|fianco|costat\w*|gamba|ginocchi\w*|piede|viso|volto|occhi|sguardo|mascella|respiro|fiato|peso|guardia|postura|equilibrio|appoggio|dolore|segno|livido|sangue)\b/iu.test(risposta)) {
    v.errori.push("segmento risposta_fisica: non mostra una risposta del corpo");
  }
  const precedente = typeof azione.esito_precedente === "string" ? azione.esito_precedente : "";
  if (precedente && piano.riferimenti.esito_precedente) {
    controllaEsito("segmento esito_precedente", precedente, piano.riferimenti.esito_precedente, piano, v, false, {
      bersaglio: piano.riferimenti.bersaglio_precedente,
      parole: piano.riferimenti.zona_precedente_parole,
    });
    if (p.ruolo === "png_esito" && ["colpito", "sfiorato", "parato", "schivato"].includes(piano.riferimenti.esito_precedente)
      && !esitoAttribuitoAlCandidato(precedente, piano.riferimenti.esito_precedente, piano)) {
      v.errori.push("segmento esito_precedente: attribuisce l'esito all'attore sbagliato");
    }
  }
  const nuova = typeof azione.nuova_intenzione === "string" ? azione.nuova_intenzione : "";
  if (nuova && p.ruolo === "png_attacca") {
    if (contieneEsitoCompiuto(nuova, piano) || nuovoContattoRisoltoDalloSfidante(nuova, piano) || candidatoSubisceContatto(nuova, piano)) {
      v.errori.push("segmento nuova_intenzione: il nuovo attacco non resta irrisolto");
    }
    const zona = (p.fatti_del_ciclo as Record<string, unknown>).bersaglio_previsto;
    if (typeof zona === "string" && piano.riferimenti.zona_parole.length && !bersaglioGovernatoCorretto(nuova, piano.riferimenti.zona_parole)) {
      v.errori.push(`segmento nuova_intenzione: il nuovo attacco non mira alla zona autoritativa (${zona})`);
    }
  }
  for (const [esito, grezzo] of Object.entries(rami)) {
    if (!grezzo || typeof grezzo !== "object" || Array.isArray(grezzo)) continue;
    const segmenti = grezzo as Record<string, unknown>;
    const testoEsito = typeof segmenti.esito === "string" ? segmenti.esito : "";
    if (testoEsito) controllaEsito(`branca «${esito}».esito`, testoEsito, esito, piano, v);
    if (testoEsito && p.ruolo === "png_attacca" && ["colpito", "sfiorato", "parato", "schivato"].includes(esito)
      && !esitoAttribuitoAlCandidato(testoEsito, esito, piano)) {
      v.errori.push(`branca «${esito}».esito: attribuisce l'esito all'attore sbagliato`);
    }
    const rispostaBranca = typeof segmenti.risposta_fisica === "string" ? segmenti.risposta_fisica : "";
    if (rispostaBranca && !/\b(?:corpo|pelle|stoffa|spalla|braccio|mano|dita|torace|petto|ventre|fianco|costat\w*|gamba|ginocchi\w*|piede|viso|volto|occhi|sguardo|mascella|respiro|fiato|peso|guardia|postura|equilibrio|appoggio|dolore|segno|livido|sangue)\b/iu.test(rispostaBranca)) {
      v.errori.push(`branca «${esito}».risposta_fisica: non mostra una risposta del corpo`);
    }
    const assettoBranca = typeof segmenti.assetto_finale === "string" ? segmenti.assetto_finale : "";
    if (assettoBranca && !chiusuraConAssetto(assettoBranca, piano)) v.errori.push(`branca «${esito}».assetto_finale: nuovo assetto non leggibile`);
  }
}

function componiAtomi(raccordi: Record<string, unknown>, atomi: readonly AtomoMeccanico[]): string {
  return atomi.flatMap((a, i) => [typeof raccordi[`r${i}`] === "string" ? String(raccordi[`r${i}`]).trim() : "", a.testo]).filter(Boolean).join(" ");
}

function controllaContrattoAtomico(uscita: Record<string, unknown>, p: PayloadV5, piano: Piano, v: Verdetto) {
  const errori = uscita.contratto_atomico_errori;
  if (!Array.isArray(errori) || errori.some((x) => typeof x !== "string")) {
    v.errori.push("contratto atomico assente o malformato");
    return;
  }
  v.errori.push(...errori as string[]);
  const scheletro = uscita._atomi_interni as Record<string, unknown> | undefined;
  const raccordi = uscita._raccordi_interni as Record<string, unknown> | undefined;
  if (!scheletro || typeof scheletro !== "object" || !raccordi || typeof raccordi !== "object") {
    v.errori.push("traccia interna di atomi o raccordi assente");
    return;
  }
  const atteso = costruisciScheletroCiclo(p, piano, String(uscita.intenzione_id ?? ""));
  if (JSON.stringify(scheletro) !== JSON.stringify(atteso)) v.errori.push("scheletro atomico diverso dai fatti server");
  const azione = Array.isArray(scheletro.azione) ? scheletro.azione as Array<Record<string, unknown>> : [];
  if (!azione.length || azione.at(-1)?.tipo !== "assetto_finale") v.errori.push("scheletro azione privo dell'atomo finale di assetto");
  const controllaAtomi = (dove: string, xs: Array<Record<string, unknown>>) => {
    const id = new Set<string>();
    for (const a of xs) {
      if (typeof a.id !== "string" || !a.id || id.has(a.id)) v.errori.push(`${dove}: identificatore atomico assente o duplicato`);
      else id.add(a.id);
      if (typeof a.tipo !== "string" || typeof a.testo !== "string" || !a.testo.trim()) v.errori.push(`${dove}: atomo incompleto`);
      if (!Array.isArray(a.fonti) || !(a.fonti as unknown[]).length || (a.fonti as unknown[]).some((x) => typeof x !== "string")) v.errori.push(`${dove}: provenienza atomica assente`);
    }
  };
  controllaAtomi("azione", azione);
  const rami = scheletro.esiti && typeof scheletro.esiti === "object" ? scheletro.esiti as Record<string, unknown> : {};
  for (const [nome, xs] of Object.entries(rami)) {
    const lista = Array.isArray(xs) ? xs as Array<Record<string, unknown>> : [];
    if (!lista.length || lista.at(-1)?.tipo !== "assetto_finale") v.errori.push(`branca «${nome}»: atomo finale di assetto assente`);
    controllaAtomi(`branca «${nome}»`, lista);
  }
  const raccordiAzione = raccordi.azione && typeof raccordi.azione === "object" ? raccordi.azione as Record<string, unknown> : {};
  if (String(uscita.azione_png ?? "") !== componiAtomi(raccordiAzione, atteso.azione)) v.errori.push("azione pubblica diversa dalla composizione atomica autorizzata");
  const raccordiEsiti = raccordi.esiti && typeof raccordi.esiti === "object" ? raccordi.esiti as Record<string, unknown> : {};
  const esitiPubblici = uscita.esiti && typeof uscita.esiti === "object" ? uscita.esiti as Record<string, unknown> : {};
  for (const [nome, atomi] of Object.entries(atteso.esiti)) {
    const blocco = raccordiEsiti[nome] && typeof raccordiEsiti[nome] === "object" ? raccordiEsiti[nome] as Record<string, unknown> : {};
    if (String(esitiPubblici[nome] ?? "") !== componiAtomi(blocco, atomi)) v.errori.push(`branca «${nome}»: testo pubblico diverso dalla composizione atomica autorizzata`);
  }
}

export function valida(uscita: Record<string, unknown>, p: PayloadV5, piano: Piano): Verdetto {
  const v: Verdetto = { errori: [], qualita: [], avvisi: [] };
  const ruolo = p.ruolo as Ruolo;
  const tetti = TETTI_PROSA[ruolo];
  const azione = String(uscita.azione_png ?? "");
  const esiti = (uscita.esiti && typeof uscita.esiti === "object") ? uscita.esiti as Record<string, unknown> : {};
  const atomico = "contratto_atomico_errori" in uscita || "_atomi_interni" in uscita;
  if ("contratto_segmenti_errori" in uscita || "_segmenti_interni" in uscita) controllaContrattoSegmenti(uscita, p, piano, v);
  const intenzione = p.intenzioni.find((i) => i.id === uscita.intenzione_id);
  if (!intenzione) { v.errori.push("intenzione non offerta dal campo"); return v; }

  if (atomico) {
    controllaContrattoAtomico(uscita, p, piano, v);
    if (azione.length < tetti.azione[0] || azione.length > tetti.azione[1]) v.errori.push(`azione_png fuori misura (${azione.length})`);
    const attesi = [...new Set(intenzione.esiti_possibili.map(String))].sort();
    const chiavi = Object.keys(esiti).sort();
    if (JSON.stringify(attesi) !== JSON.stringify(chiavi)) v.errori.push(`branche diverse dalle attese: attese {${attesi.join(",")}}, ricevute {${chiavi.join(",")}}`);
    for (const k of chiavi) {
      const b = String(esiti[k] ?? "");
      if (b.length < tetti.branca[0] || b.length > tetti.branca[1]) v.errori.push(`branca «${k}» fuori misura (${b.length})`);
    }
    v.errori = [...new Set(v.errori)];
    return v;
  }

  if (azione.length < tetti.azione[0] || azione.length > tetti.azione[1]) v.errori.push(`azione_png fuori misura (${azione.length})`);
  controllaTesto("azione_png", azione, piano, p, v, { finale: ruolo === "png_finale" });

  const attesi = [...new Set(intenzione.esiti_possibili.map(String))].sort();
  const chiavi = Object.keys(esiti).sort();
  if (JSON.stringify(attesi) !== JSON.stringify(chiavi)) v.errori.push(`branche diverse dalle attese: attese {${attesi.join(",")}}, ricevute {${chiavi.join(",")}}`);
  for (const k of chiavi) {
    const b = String(esiti[k] ?? "");
    if (b.length < tetti.branca[0] || b.length > tetti.branca[1]) v.errori.push(`branca «${k}» fuori misura (${b.length})`);
    const fiatoOk = /torace|ventre|petto|stomaco|costat/iu.test(String(piano.riferimenti.bersaglio ?? "")) && (k === "colpito" || k === "sfiorato");
    controllaTesto(`branca «${k}»`, b, piano, p, v, { finale: false, fiato: fiatoOk });
    controllaEsito(`branca «${k}»`, b, k, piano, v);
    if (ruolo === "png_difende" && esitoAttribuitoAlCandidato(b, k, piano)) {
      v.errori.push(`branca «${k}»: attribuisce al candidato l'esito destinato allo sfidante`);
    }
    if (ruolo === "png_difende" && (nuovoContattoRisoltoDalloSfidante(b, piano) || apreNuovoAttacco(b, piano))) {
      v.errori.push(`branca «${k}»: apre un nuovo attacco dello sfidante`);
    }
    // una branca non è l'azione ripetuta
    if (b.length >= 80 && azione.includes(b.slice(0, 80))) v.errori.push(`branca «${k}» ricopia azione_png`);
  }
  // branche fra loro: nessuna frase lunga in comune
  for (let i = 0; i < chiavi.length; i++) for (let j = i + 1; j < chiavi.length; j++) {
    const a = frasi(String(esiti[chiavi[i]] ?? "")); const b = String(esiti[chiavi[j]] ?? "").toLowerCase();
    if (a.some((f) => f.length >= 60 && b.includes(f.toLowerCase()))) { v.qualita.push(`branche «${chiavi[i]}» e «${chiavi[j]}» condividono una frase`); }
  }

  const fontiPosizioneIntenzione = [uscita.fonti_azione, ...Object.values((uscita.fonti_esiti && typeof uscita.fonti_esiti === "object") ? uscita.fonti_esiti as Record<string, unknown> : {})]
    .flatMap((x) => fontiPerTesto(x) ?? []).flat().includes("server.posizione.intenzione");
  if (fontiPosizioneIntenzione && !(intenzione.movimento || intenzione.ampiezza)) {
    v.errori.push("server.posizione.intenzione usata per un'intenzione scelta senza movimento");
  }
  controllaProvenienza(uscita, azione, esiti, p, piano, v);
  controllaAmpiezza(uscita, azione, esiti, p, piano, v);
  controllaTecniche(uscita, p, v);

  const r = piano.riferimenti;
  if (ruolo === "png_difende") {
    if (contieneEsitoCompiuto(azione, piano)) v.errori.push("azione_png anticipa l'esito");
    if (!azione.includes(r.sfidante)) v.errori.push("azione_png non nomina lo sfidante");
  }
  if (ruolo === "png_attacca") {
    const righe = fontiPerTesto(uscita.fonti_azione) ?? [];
    if (frasi(azione).some((frase, i) => contieneEsitoCompiuto(frase, piano) && !righe[i]?.includes("server.esito"))
      || nuovoContattoRisoltoDalloSfidante(azione, piano) || candidatoSubisceContatto(azione, piano) || candidatoSubisceEsitoCorporeo(azione, piano)) {
      v.errori.push("azione_png contiene un esito senza fonte server (il nuovo attacco deve restare irrisolto)");
    }
    if (!azione.includes(r.sfidante)) v.errori.push("azione_png non nomina lo sfidante");
    if (!azione.includes(r.candidato)) v.errori.push("azione_png non nomina il candidato");
    if (/\b(?:vince\w*|vinto|perde\w*|perso|sconfitt\w*|promoss\w*)\b/iu.test(azione)) v.errori.push("azione_png inventa un verdetto della prova o dello scambio");
    if (r.esito_precedente && esitoAttribuitoAlCandidato(azione, r.esito_precedente, piano)) v.errori.push("azione_png attribuisce al candidato l'esito destinato allo sfidante");
    if (r.esito_precedente) controllaEsito("azione_png (esito precedente)", azione, r.esito_precedente, piano, v, true, { bersaglio: r.bersaglio_precedente, parole: r.zona_precedente_parole });
    const zona = (p.fatti_del_ciclo as any)?.bersaglio_previsto as string | undefined;
    if (zona) {
      const parole = piano.riferimenti.zona_parole.length ? piano.riferimenti.zona_parole : [];
      if (parole.length && !bersaglioGovernatoCorretto(ultimaFrase(azione), parole)) v.errori.push(`azione_png: il nuovo attacco non mira alla zona autoritativa (${zona})`);
    }
  }
  if (ruolo === "png_esito") {
    if (!azione.includes(r.sfidante)) v.errori.push("azione_png non nomina lo sfidante");
    if (!azione.includes(r.candidato)) v.errori.push("azione_png non nomina il candidato");
    if (r.esito_precedente) controllaEsito("azione_png", azione, r.esito_precedente, piano, v);
    if (apreNuovoAttacco(azione, piano)) v.errori.push("azione_png apre un nuovo attacco dello sfidante dopo l'esito");
  }
  if (ruolo === "png_finale") {
    if (r.sensei && !azione.includes(r.sensei)) v.errori.push("il finale non nomina il Sensei");
    if (!/coprifronte/iu.test(azione)) v.errori.push("il finale non parla della consegna del coprifronte");
    if (r.finale_tipo === "sfinimento" && !/\b(ferm\w+|basta|senza forze|non (?:ha|hanno) più|allo stremo|ingresso)\b/iu.test(azione)) v.avvisi.push("finale per sfinimento senza l'arresto del Sensei");
    if (r.finale_tipo === "quattro_round" && !/\b(abbastanza|a sufficienza|visto|consegn\w+)\b/iu.test(azione)) v.avvisi.push("finale per quattro round senza la consegna");
    if (r.esito_precedente) controllaEsito("azione_png (ultimo esito)", azione, r.esito_precedente, piano, v);
    if (apreNuovoAttacco(azione, piano)) v.errori.push("azione_png apre un nuovo attacco dopo la chiusura della prova");
  }
  controllaQualita(uscita, azione, esiti, p, piano, v);
  v.errori = [...new Set(v.errori)];
  v.qualita = [...new Set(v.qualita)];
  v.avvisi = [...new Set(v.avvisi)];
  return v;
}
