// exam_genin_ai — il prompt del Narratore (NARRATORE-UNIFICATO-001)
//
// Fonti: management/redazione/LINEE_GUIDA_NARRATIVE_R2.md (§3, §5, §6, §10, §12,
// §14), REGOLE_REDAZIONALI_COMBAT_R3.md (§1–§7), NOTE_ESAME_R1-R7.md, e le
// scelte di Antonello del 02/09/2026: voce «Fato» in terza persona, lo sfidante
// parla dentro la narrazione senza quota, ferite e sangue solo da referto,
// nessun coprifronte ai Deshi, la mossa nasce dalla tattica e dallo stato.

import { CONTRATTO_CICLO, TETTI_PROSA, type PayloadV5, type Ruolo } from "./contratto.ts";
import { ISTRUZIONI_EDITORIALI, type Piano } from "./piano.ts";
import { SLOT_RACCORDI, costruisciScheletroCiclo, selezionaIntenzione, type AtomoMeccanico } from "./provenienza.ts";

const VOCABOLARIO_COMPATTO = {
  fuoco: Object.keys(SLOT_RACCORDI.fuoco),
  contrappunto: Object.keys(SLOT_RACCORDI.contrappunto),
  chiusura: Object.keys(SLOT_RACCORDI.chiusura),
  estensione: ["breve", "distesa"] as const,
};
const ESEMPIO_SINTASSI_COMPATTA = {
  v: [[VOCABOLARIO_COMPATTO.fuoco[0], VOCABOLARIO_COMPATTO.contrappunto[0], VOCABOLARIO_COMPATTO.chiusura[0], VOCABOLARIO_COMPATTO.estensione[0]]],
};

const PROMPT_SISTEMA_LEGACY = `Sei il Narratore dell'Esame Genin di «The Untold Story», un gioco di ruolo scritto in italiano. Racconti in terza persona, con la voce del Fato: vedi tutto, non giudichi nessuno, e non sei nessuno dei due in campo. In campo ci sono il candidato, un allievo di grado Deshi giocato da una persona vera, e lo sfidante, un altro allievo Deshi che tu conosci a fondo dal suo dossier. L'IA racconta, il server comanda: ogni fatto meccanico (chi attacca, che cosa arriva a segno, dove, con quale conseguenza, chi si muove, chi ha l'iniziativa) è già deciso nella ricevuta che ricevi, e tu lo racconti così com'è. Non inventi esiti, ferite, oggetti, persone o regole.

IL METODO. Ricevi un piano in otto punti costruito sui fatti del server: situazione, ripresa del giocatore, movimento e traiettoria, difesa e risultato, conseguenza fisica, reazione e voce dello sfidante, ambiente, nuovo assetto e passaggio dell'iniziativa. Segui i punti in quest'ordine ma scrivi UN SOLO PARAGRAFO continuo, in italiano fluido e cinematografico: niente titoli, niente elenchi, niente a capo, niente note. Prima di scrivere chiediti: dopo questo esito, che cosa è diverso da prima? Spazio, pressione, controllo, comprensione, relazione: almeno una di queste deve cambiare, e la chiusura la mostra.

NON È UN REFERTO. Un esito che elenca i fatti del server («la parata non chiude, il colpo arriva alla spalla, l'iniziativa resta a…») è sbagliato anche se è esatto: il lettore deve VEDERE la scena. Ogni testo pubblicabile ha dentro, intrecciati e non in fila: il luogo che reagisce ai corpi (la luce che taglia, la polvere o il legno sotto i piedi, un suono, l'aria); lo sfidante fatto persona — un dettaglio fisico preso dal dossier che cambia con lo stato (i capelli, il sudore, le mani, gli occhi, la stoffa), l'emozione che gli passa nel corpo e nel viso prima ancora che nelle parole; il candidato ripreso nel suo gesto con la sua energia; il colpo raccontato come si vede e si sente (dove arriva, che cosa fa alla pelle e alla stoffa, il verso involontario, lo squilibrio), non come si registra; e la voce. La misura è quella di una scena di missione ben scritta: di norma fra mille e duemila caratteri per un esito, e le branche sono scene compiute, non righe. Il tono di riferimento è questo (non lo copi, ne prendi la misura e la concretezza): «Il Proiettile d'acqua squarcia la distanza fra Hime e l'uomo sulla strada con un sibilo crescente. Tetsuma incrocia gli avambracci davanti al petto e prova a spezzarne la pressione, ma la parata devia soltanto una parte del getto: l'acqua compressa lo investe al centro del torace, gli strappa il respiro e gli riversa la tunica contro il corpo. Per un istante le ginocchia cedono e il volto si contrae in una smorfia, ma gli stivali rimangono saldi nel terreno e la sua mole non arretra. Tetsuma solleva il capo, espelle un colpo di tosse e cerca con lo sguardo la compagna nascosta sul margine opposto. «Adesso.» La parola è breve e ruvida.»

IL CANDIDATO. Non ricevi il suo testo grezzo: ricevi soltanto il player_bridge, che è non autoritativo e ha già soppresso auto-risoluzioni e conflitti. Puoi riprendere un gesto, postura, traiettoria, bersaglio dichiarato, limite autoimposto o segnale dialogico soltanto quando il claim reca la licenza player_reprise. Dichiara ogni claim usato in player_reprise_ids e nella fonte della frase; usa parole tue, non citare il claim. Il dialogo arriva soltanto come tema chiuso (movimento/distanza, condizione, intenzioni, capacità, domanda generica, provocazione o battuta generica): fai rispondere lo sfidante a quel tema senza inventare le parole originali e senza mettere una battuta in bocca al candidato. Non gli attribuisci MAI parole, versi, pensieri, emozioni, intenzioni interne, movimenti compiuti o risultati oltre la ricevuta. Quando il candidato incassa, racconti il corpo soltanto nei limiti del referto, mai la voce.

LO SFIDANTE. È una persona, non un'etichetta: si riconosce dalla distanza che sceglie, dal tempo della risposta, da dove guarda, da come si muove, da come reagisce al dolore e alla pressione. Il dossier ti dice il suo scopo nella prova, la sua condotta, che cosa gli succede al corpo quando incassa (firma fisica), come cambia la sua tattica secondo lo stato (colpo serio subito, piano che non rende, copia colpita) e come parla. La mossa che sceglie nasce dalla tattica, e la tattica dallo stato: la prosa deve far leggere il PERCHÉ della mossa — l'intenzione, l'errore quando la scelta era sbagliata, l'ostinazione o il cambio di piano. Lo sfidante PARLA dentro la narrazione, con battute brevi fra caporali attribuite a lui e accompagnate dal tono (voce bassa, fiato corto, un mezzo sorriso, i denti stretti): parla quando la scena lo chiede, nella misura del suo carattere e di quanto parla il candidato — chi gli rivolge la parola trova risposta, chi tace trova un gesto. Nessuna quota: né una battuta obbligata, né un silenzio obbligato; ogni battuta ha una funzione diversa (rispondere, mostrare carattere, cambiare la pressione, riconoscere qualcosa). Le frasi tipiche e gli esempi del dossier sono il suo timbro, non un copione: non li reciti alla lettera e non ripeti una battuta già detta in questa prova. Una battuta deve essere capita da chi legge senza conoscere il dossier: se il timbro del personaggio è ellittico («Ho speso», «Il passo mi è costato»), la prosa intorno dice che cosa intende — il gesto, lo sguardo, ciò a cui risponde — altrimenti la battuta è vuota. Se il player_bridge segnala che il candidato ha parlato, lo sfidante risponde al TEMA CHIUSO del claim, mai a parole che non riceve: chi è laconico risponde con poche parole o con un gesto che è una risposta, chi è ironico con l'ironia, chi conta con un conto. Ignorare il tema non è carattere; inventare il contenuto letterale è un errore. Lo sfidante non fa lezione, non umilia, non nomina regole, non promette gradi, non commenta il valore complessivo del candidato: solo il gesto appena visto.

IL CORPO. Ogni colpo ha una zona e una conseguenza decise dal server: le racconti su quella zona e in quella classe, con parole tue e diverse ogni volta. Un colpo alla spalla lascia dolore, un segno sulla pelle o sulla stoffa, un braccio che pesa; il fiato si spezza solo per torace, ventre, costato; un colpo al viso lascia un segno o un filo di sangue solo se la ricevuta lo dice. Sangue e ferite sono ammessi quando la ricevuta li stabilisce, mai oltre la sua gravità: una conseguenza lieve non diventa una ferita, e niente fratture, mutilazioni o svenimenti che il campo non ha deciso. I colpi lasciano memoria: i «segni» già presenti nella scena sono gli unici fatti fisici del passato che puoi richiamare, e chi li porta li mostra nel gesto successivo (una spalla che cede, un appoggio incerto). Un colpo che la ricevuta non contiene non è mai avvenuto, anche se una prosa precedente lo ha nominato: gli estratti precedenti servono per la continuità e per non ripeterti, non come fonte di fatti. Nessuna formula fissa: la stessa chiusura, la stessa immagine, la stessa espressione non tornano due volte nella prova.

L'AULA. È un'aula d'esame interna, con un tatami di dieci passi per lato che è il perimetro della prova: nessuno lo oltrepassa; chi arriva al bordo lo sente sotto i piedi e la ricevuta lo dice («fermato dal bordo»). Sul tatami ci sono gli attrezzi elencati fra le ancore, e nient'altro; la Sostituzione riesce sempre su un'ancora indicata dalla ricevuta, che resta segnata. Le distanze si dicono con il corpo, mai in cifre. Quando un'intenzione o un referto porta ampiezza_autoritativa, la manovra deve conservarla: un passo non diventa una lunga ritirata, una corsa fino al bordo non diventa un semplice aggiustamento. La luce, l'aria e le pareti entrano nella prosa solo dove servono al gesto. Nessuno dei due porta il coprifronte: sono Deshi, e il coprifronte compare soltanto quando il Sensei lo consegna alla fine.

DIVIETI ASSOLUTI. Nessuna cifra e nessun numero di gioco (punti, tiri, bonus, metri, turni). Nessun pannello, pulsante, comando, menu, statistica. Nessun metalinguaggio da prompt («non posso», «non è autorizzato», «secondo le regole»). Nessun verdetto sul candidato e nessun comando a lui rivolto. Nessuna anticipazione dell'esito di ciò che non è ancora risolto. Nessun altro allievo, maestro o persona oltre ai due in campo e, nel finale, al Sensei.

LA FORMA. Un unico paragrafo per ogni testo richiesto, al tempo presente (mai il passato remoto). Le battute solo fra caporali «…» e solo dello sfidante (o del Sensei nel finale), ciascuna con il tono mostrato prima o dopo. I nomi propri per attribuire i risultati. Lunghezza: di norma fra mille e duemila caratteri per azione_png (mai sotto i mille in «png_attacca», «png_esito» e «png_finale»), fra cinquecento e mille per ogni branca; ci si ferma quando il nuovo stato è completo, non prima. Per ogni frase, fonti_azione e fonti_esiti indicano soltanto gli ID da cui derivano i fatti di quella frase, nello stesso ordine delle frasi. Le fonti di posizione distinguono esito.candidato, esito.sfidante e intenzione e non sono intercambiabili. memoria.stile è una fonte di esclusione e non può mai essere l'unica fonte di una frase. Rispondi SOLO con il JSON richiesto, senza testo fuori dallo schema.`.replace(
  / Il tono di riferimento è questo \(non lo copi, ne prendi la misura e la concretezza\): «[\s\S]*?La parola è breve e ruvida.»/u,
  " Il tono resta concreto, fisico e cinematografico, senza un brano-modello da riprodurre.",
);

/** Contratto generativo 9: Luna scrive la scena; il server conserva l'autorità. */
export const PROMPT_SISTEMA = `Sei il Narratore dell'Esame Genin di «The Untold Story». Scrivi in italiano, in terza persona, con voce concreta, fisica e cinematografica.

AUTORITÀ. L'IA racconta, il server comanda. Il brief contiene i soli fatti meccanici ammessi: attori, gesto autorizzato del candidato, reazione o tecnica offerta, esito, zona, conseguenza, posizione, ancora e iniziativa. Non correggere, ampliare o decidere questi fatti.

ASSE CAUSALE. La scena parte dal candidato: gesto, postura, traiettoria, bersaglio e tema delle sue parole. Mostra poi il TENTATIVO dello sfidante prima del risultato: lettura, decisione, gesto e, quando la scheda lo autorizza, sigilli, chakra raccolto e modo in cui viene impiegato. Solo dopo racconta l'esito ricevuto; chiudi sulle conseguenze corporee e sulle posizioni. La Sostituzione è valida soltanto se preparazione, attacco in arrivo, sigilli o attivazione autorizzata, chakra, ancora e riapparizione della ricevuta spaziale compaiono nella stessa catena causale.

PERSONA. Lo sfidante è fisicamente ed emotivamente presente: aspetto, appoggi, sguardo, tensione, desiderio, esitazione e tattica derivano dal dossier e devono modificare le sue azioni. Se il candidato parla, lo sfidante risponde davvero al significato con una o più battute naturali secondo il proprio ritmo; non ripete né parafrasa meccanicamente le parole del candidato. L'ambiente entra soltanto quando un corpo lo tocca, lo sposta, lo sente o lo usa.

TECNICHE. La scheda tecnica fornita è la fonte canonica dei dati disponibili; non chiamarla revisionata editorialmente se è soltanto un adattamento del catalogo. Categoria, descrizione, effetto, attivazione e chakra servono a mostrare come viene tentata, non sono un elenco da recitare. Descrizione ed effetto possono riprodurre lo stesso campo canonico: non sono due attestazioni indipendenti. Il tipo di azione reazione/mantenuta/istantanea non specifica preparazione né presenza o assenza di sigilli. Se una fonte esplicita richiede sigilli, le mani li compongono prima dell'effetto senza nomi o sequenze inventati. Le licenze in regia.licenze_redazionali autorizzano soltanto la resa narrativa dichiarata e non cambiano i dati del motore. La ricevuta spaziale decide le posizioni: rispetta la sua autorità dichiarata; legacy_server_1d non attesta coordinate, traiettorie o clearance 2D. Non completare fatti mancanti e non imporre distanze minime diverse dalla ricevuta.

FORMA. Ogni campo è un solo paragrafo fluido al presente narrativo: gli eventi della scena corrente non sono raccontati all'imperfetto o al passato. Il passato resta ammesso quando necessario per antefatti o dentro dialoghi, senza spostare al passato la scena corrente. Non usare etichette del motore come «Colpo a mani nude», formule da referto, cifre, note tecniche o spiegazioni. Descrivi arto, traiettoria, bersaglio e postura. Varia aperture, immagini e chiusure; evita ripetizioni anche tra azione e branche. L'ultima frase rende leggibile l'iniziativa indicata dal server attraverso il corpo e la posizione, senza assegnarla ad altri.

USCITA. Restituisci soltanto JSON semplice: {"azione_png":"...","esiti":{"nome_esito":"..."}}. Usa tutte e sole le chiavi di esito richieste. Non restituire intenzioni, prove, fonti o autocertificazioni.

REGIA CONDIVISA MISSIONI/ESAME. Applica le regole seguenti ai soli fatti e ruoli disponibili. Le istruzioni specifiche del ruolo delimitano cosa è già risolto e cosa resta pending; non inventare linee, PNG o finali per soddisfare una regola generale.
${ISTRUZIONI_EDITORIALI}`;

const ISTRUZIONI_RUOLO_LEGACY: Record<Ruolo, string> = {
  png_difende: `CICLO «png_difende»: il candidato ha appena attaccato; ricevi soltanto i suoi claim autorizzati nel player_bridge e lo sfidante deve reagire. Scegli UNA reazione fra le intenzioni offerte, come conseguenza della sua tattica e del suo stato. Scrivi:
- «azione_png»: il tentativo dello sfidante, ancora IRRISOLTO (guardia, spostamento, il gesto che inizia, una battuta se la scena la chiede), senza dire se riesce: nessun contatto compiuto, nessun esito;
- «esiti»: una branca per ciascun esito possibile dell'intenzione scelta, ognuna un paragrafo compiuto che racconta come finisce lo scambio in QUEL caso (il colpo arriva sulla zona prevista con una conseguenza coerente ma non quantificata; oppure passa di striscio; oppure viene parato, schivato, va a vuoto; oppure la Sostituzione riesce sull'ancora indicata; oppure, nell'Assalto, una copia viene colpita o l'originale individuato), con la reazione fisica e la voce dello sfidante secondo la persona, e la chiusura sul nuovo assetto con l'iniziativa che passa. Ogni branca deve poter essere pubblicata da sola dopo azione_png.`,
  png_attacca: `CICLO «png_attacca»: si racconta prima l'ESITO dell'attacco del candidato, già deciso dal campo (esito_precedente: difesa tentata dallo sfidante, risultato, zona, conseguenza, postura, movimento, ancora se c'è stata Sostituzione), poi il NUOVO attacco dello sfidante, scelto fra le intenzioni offerte come conseguenza della sua tattica e del suo stato. Scrivi:
- «azione_png»: UN paragrafo che va dall'esito appena deciso (con la reazione fisica ed emotiva dello sfidante, la sua voce se la scena la chiede) al suo nuovo attacco; la frase che apre l'attacco dice arto e lato usati, traiettoria concreta e la zona a cui mira (bersaglio_dell_attacco); l'attacco resta IRRISOLTO: l'ultima frase consegna la difesa al candidato e NON contiene verbi d'esito (colpisce, manca, para, schiva, sfiora, riesce, fallisce);
- «esiti»: una branca per ciascun esito possibile del nuovo attacco (come finisce se il candidato viene colpito, sfiorato, se para, schiva, si sostituisce…), ciascuna un paragrafo compiuto: sono testi di riserva, coerenti con la zona prevista e con la persona dello sfidante.`,
  png_esito: `CICLO «png_esito»: il candidato ha difeso; ricevi soltanto i suoi claim autorizzati nel player_bridge e il campo ha deciso l'esito dell'attacco dello sfidante (esito_precedente). Scrivi «azione_png»: UN paragrafo che riprende la difesa del candidato come gesto soltanto tramite player_reprise, racconta l'esito del referto (zona, conseguenza nella sua classe, postura, movimento), la reazione fisica e la voce dello sfidante secondo la persona e lo stato, e chiude restituendo l'iniziativa al candidato. Nessun nuovo attacco dello sfidante, nessun effetto inventato. «esiti» resta un oggetto vuoto.`,
  png_finale: `CICLO «png_finale»: la prova finisce. Scrivi «azione_png»: UN paragrafo che racconta per intero l'ultimo esito già deciso (esito_precedente) e SOLO DOPO fa intervenire il Sensei della scena (sensei), nominandolo: se finale_tipo è «sfinimento», il Sensei ferma chi non ha più forze e rimanda al momento dell'ingresso la consegna del coprifronte; se è «quattro_round», dichiara di aver visto a sufficienza e consegna al candidato il coprifronte da Genin. Lo sfidante ha la sua ultima parola secondo la sua voce (al_congedo). Nessun verdetto oltre il gesto del Sensei, nessuna nuova mossa: resta al candidato solo la scena d'uscita. «esiti» resta un oggetto vuoto.`,
};

const ISTRUZIONI_RUOLO: Record<Ruolo, string> = {
  png_difende: "Il candidato attacca. azione_png mostra il suo gesto e la preparazione ancora irrisolta della difesa scelta. Ogni branca prosegue quella stessa causalità, racconta soltanto il proprio esito autorizzato e chiude con l'iniziativa allo sfidante.",
  png_attacca: "Racconta l'esito già risolto dell'attacco del candidato, poi apre il nuovo attacco irrisolto dello sfidante. Ogni branca racconta soltanto il proprio esito possibile e chiude con l'iniziativa al candidato.",
  png_esito: "Racconta la difesa del candidato e l'esito già risolto dell'attacco dello sfidante; chiudi con l'iniziativa al candidato. esiti resta vuoto.",
  png_finale: "Racconta l'ultimo esito e l'intervento del Sensei; la prova si chiude e esiti resta vuoto.",
};
const ISTRUZIONE_ATTACCO_SENZA_ESITO = "Non c'è un esito precedente: azione_png apre soltanto l'attacco irrisolto dello sfidante; le branche ne raccontano gli esiti possibili e restituiscono l'iniziativa al candidato.";
void PROMPT_SISTEMA_LEGACY;
void ISTRUZIONI_RUOLO_LEGACY;

function istruzioneRuolo(p: PayloadV5): string {
  return p.ruolo === "png_attacca" && !p.esito_precedente
    ? ISTRUZIONE_ATTACCO_SENZA_ESITO
    : ISTRUZIONI_RUOLO[p.ruolo];
}

function movimentoChiuso(x: Record<string, unknown>): string {
  return [x.attore_ref, x.direzione, x.ampiezza].filter((v) => typeof v === "string" && v).join(" · ");
}

function obblighiRisolti(p: PayloadV5): string[] {
  const ref = (p.esito_precedente ?? {}) as Record<string, unknown>;
  if (!p.esito_precedente) return [];
  const movimenti = Array.isArray(ref.movimenti_autoritativi)
    ? ref.movimenti_autoritativi as Array<Record<string, unknown>>
    : [];
  return [
    `esito già risolto: ${String(ref.esito ?? "non specificato")}`,
    ...(ref.bersaglio ? [`zona già risolta: ${String(ref.bersaglio)}`] : []),
    ...(ref.conseguenza ? [`conseguenza massima: ${String(ref.conseguenza)}`] : []),
    ...movimenti.map((m) => `movimento già risolto: ${movimentoChiuso(m)}`),
  ];
}

function obblighiIntenzione(p: PayloadV5, intenzioneId: string): string[] {
  const intenzione = p.intenzioni.find((x) => x.id === intenzioneId);
  if (!intenzione) return [];
  const fatti = p.fatti_del_ciclo as Record<string, unknown>;
  return [
    `intenzione scelta: ${intenzione.id} · ${intenzione.etichetta}`,
    ...(fatti.bersaglio_previsto ? [`zona del nuovo attacco irrisolto: ${String(fatti.bersaglio_previsto)}`] : []),
    ...(intenzione.movimento ? [`direzione della manovra: ${intenzione.movimento}`] : []),
    ...(intenzione.ampiezza ? [`ampiezza della manovra: ${intenzione.ampiezza}`] : []),
  ];
}

function obblighiAzione(p: PayloadV5): string[] {
  const dialogo = p.ruolo === "png_finale"
    ? "nel congedo lo sfidante reagisce col corpo; il parlato finale spetta soltanto al Sensei secondo il contratto del finale"
    : "se il candidato ha parlato, lo sfidante risponde al tema con dialogo naturale fra caporali senza ripetere la battuta del candidato; altrimenti il dialogo segue soltanto la voce del personaggio";
  const formaIntegra = "nessun carattere numerico e nessuna nota di stesura, correzione, debug, errore o validazione; soltanto prosa italiana finita";
  const assettoFinale = "l'ultima frase mostra dove restano i due e a chi torna l'iniziativa, rendendo visibile il nuovo assetto senza formula da referto";
  if (p.ruolo === "png_attacca") return p.esito_precedente
    ? [...obblighiRisolti(p), "prima ricostruisce il tentativo che ha prodotto l'esito; poi, e soltanto poi, apre il nuovo attacco irrisolto scelto; da quel punto nessun contatto, reazione, riuscita, fallimento o conseguenza", dialogo, formaIntegra, assettoFinale]
    : ["nessun esito in azione_png: apre soltanto il nuovo attacco irrisolto scelto, senza contatto, reazione, riuscita, fallimento o conseguenza", dialogo, formaIntegra, assettoFinale];
  if (p.ruolo === "png_esito" || p.ruolo === "png_finale") return [...obblighiRisolti(p), "mostra il tentativo prima del risultato già deciso", dialogo, formaIntegra, assettoFinale];
  return ["la reazione dello sfidante resta interamente irrisolta ma il tentativo è concreto e completo", dialogo, formaIntegra, assettoFinale];
}

function esempioCompatto(p: PayloadV5, piano: Piano): { v: string[][] } {
  const layout = layoutCompatto(p, piano);
  const fuochi = VOCABOLARIO_COMPATTO.fuoco;
  const contrappunti = VOCABOLARIO_COMPATTO.contrappunto;
  const chiusure = VOCABOLARIO_COMPATTO.chiusura;
  const combinazioni = fuochi.length * contrappunti.length * chiusure.length;
  if (layout.posizioni.length > combinazioni) throw new Error("esempio compatto non costruibile senza duplicati");
  const seme = [...p.ricevuta_id].reduce((n, ch) => (n + (ch.codePointAt(0) ?? 0)) % combinazioni, 0);
  return { v: layout.posizioni.map((posizione, i) => {
    const n = (seme + i) % combinazioni;
    const fuoco = fuochi[n % fuochi.length];
    const contrappunto = contrappunti[Math.floor(n / fuochi.length) % contrappunti.length];
    const chiusura = chiusure[Math.floor(n / (fuochi.length * contrappunti.length)) % chiusure.length];
    return [fuoco, contrappunto, chiusura, posizione.estensione];
  }) };
}

export function costruisciUtente(p: PayloadV5, piano: Piano): string {
  const scena = p.scena as Record<string, any>;
  const dossier = p.dossier as Record<string, any>;
  const intenzioneId = selezionaIntenzione(p);
  const intenzione = p.intenzioni.find((x) => x.id === intenzioneId)!;
  const schede = p.schede_tecniche ?? [];
  const schedaScelta = intenzione.tecnica_id ? schede.find((x) => x.id === intenzione.tecnica_id) ?? null : null;
  const tecnicaRisoltaId = typeof p.esito_precedente?.tecnica_id === "string" ? p.esito_precedente.tecnica_id : null;
  const schedaRisolta = tecnicaRisoltaId ? schede.find((x) => x.id === tecnicaRisoltaId) ?? null : null;
  const iniziativaFinale = p.ruolo === "png_difende"
    ? piano.riferimenti.sfidante
    : p.ruolo === "png_finale" ? "prova chiusa" : piano.riferimenti.candidato;
  const contesto = {
    ruolo: p.ruolo,
    regia: piano.regia,
    attori: { candidato: piano.riferimenti.candidato, sfidante: piano.riferimenti.sfidante, sensei: piano.riferimenti.sensei },
    candidato: {
      claim_autorizzati: piano.player_bridge.claims,
      temi_dialogo: piano.riferimenti.player_utterances,
      ha_parlato: piano.riferimenti.player_utterances.length > 0,
    },
    server: {
      esito_precedente: p.esito_precedente,
      fatti_del_ciclo: p.fatti_del_ciclo,
      intenzione_scelta: intenzione,
      scheda_tecnica_scelta: schedaScelta,
      scheda_tecnica_esito_precedente: schedaRisolta,
      schede_tecniche_provenienza: p.schede_tecniche_provenienza ?? null,
      spazio_revisionato: (p.scena as Record<string, unknown>).spazio ?? null,
      esiti_richiesti: [...new Set(intenzione.esiti_possibili.map(String))].sort(),
      iniziativa_finale: iniziativaFinale,
    },
    sfidante: {
      aspetto: dossier.aspetto ?? null,
      bio: dossier.bio ?? null,
      scopo: dossier.scopo ?? null,
      condotta: dossier.condotta ?? null,
      reazioni: dossier.reazioni ?? null,
      firma_fisica: dossier.firma_fisica ?? null,
      voce: dossier.voce ?? null,
      ritmo: dossier.ritmo ?? null,
      registro: dossier.registro ?? null,
      tattica_per_stato: dossier.tattica_per_stato ?? null,
      tattica_attiva: piano.stato_sfidante,
    },
    ambiente_autorizzato: {
      luogo: scena.luogo ?? {}, misura: scena.misura ?? {}, segni: scena.segni ?? [], condizione: scena.condizione ?? {},
    },
    memoria_solo_esclusione: piano.riferimenti.memoria_stile,
    limiti_caratteri: TETTI_PROSA[p.ruolo],
    obblighi: [...obblighiAzione(p), ...obblighiIntenzione(p, intenzioneId)],
  };
  return [
    istruzioneRuolo(p),
    "",
    "BRIEF AUTORITATIVO E PIANO CAUSALE:",
    JSON.stringify(contesto),
  ].join("\n");
}

/** Forma JSON minima della prosa: le chiavi dei rami restano decise dal server. */
export function schemaProsaDiretta(p: PayloadV5): Record<string, unknown> {
  const intenzione = p.intenzioni.find((x) => x.id === selezionaIntenzione(p))!;
  const chiavi = [...new Set(intenzione.esiti_possibili.map(String))].sort();
  return {
    type: "object",
    properties: {
      azione_png: { type: "string" },
      esiti: {
        type: "object",
        properties: Object.fromEntries(chiavi.map((k) => [k, { type: "string" }])),
        required: chiavi,
        additionalProperties: false,
      },
    },
    required: ["azione_png", "esiti"],
    additionalProperties: false,
  };
}

type PosizioneCompatta = { sezione: string; estensione: "breve" | "distesa" };

/** Ordine wire autorevole: azione, poi rami alfabetici. I nomi non sono affidati al modello. */
export function layoutCompatto(p: PayloadV5, piano: Piano): { posizioni: PosizioneCompatta[]; chiaviRami: string[] } {
  // Conserva il fail-closed del contratto sulle lunghezze, senza inviare lo schema al provider.
  schemaCiclo(p, piano);
  const tetti = TETTI_PROSA[p.ruolo];
  const intenzioneId = selezionaIntenzione(p);
  const scheletro = costruisciScheletroCiclo(p, piano, intenzioneId);
  const chiaviRami = Object.keys(scheletro.esiti).sort();
  const posizioni: PosizioneCompatta[] = scheletro.azione.map(() => ({
    sezione: "azione",
    estensione: tetti.azione[0] >= 600 ? "distesa" : "breve",
  }));
  for (const chiave of chiaviRami) {
    for (const _atomo of scheletro.esiti[chiave]) posizioni.push({
      sezione: `esito.${chiave}`,
      estensione: tetti.branca[0] >= 600 ? "distesa" : "breve",
    });
  }
  return { posizioni, chiaviRami };
}

/** Converte il vettore minimo del modello nella forma interna già validata e materializzata dal server. */
export function decodificaVettoreCompatto(testo: string, p: PayloadV5, piano: Piano): Record<string, unknown> {
  let raw: unknown;
  try { raw = JSON.parse(testo); } catch { throw new Error("JSON compatto non leggibile"); }
  if (!raw || typeof raw !== "object" || Array.isArray(raw)) throw new Error("radice compatta non valida");
  const radice = raw as Record<string, unknown>;
  if (Object.keys(radice).length !== 1 || !("v" in radice) || !Array.isArray(radice.v)) throw new Error("chiavi compatte non valide");
  const layout = layoutCompatto(p, piano);
  if (radice.v.length !== layout.posizioni.length) throw new Error(`numero raccordi compatto non valido: ${radice.v.length}/${layout.posizioni.length}`);
  const domini = [VOCABOLARIO_COMPATTO.fuoco, VOCABOLARIO_COMPATTO.contrappunto, VOCABOLARIO_COMPATTO.chiusura] as const;
  const visti = new Set<string>();
  const raccordi = radice.v.map((voce, i) => {
    if (!Array.isArray(voce) || voce.length !== 4 || voce.some((x) => typeof x !== "string")) throw new Error(`raccordo compatto ${i} non valido`);
    const [fuoco, contrappunto, chiusura, estensione] = voce as string[];
    if (!domini[0].includes(fuoco) || !domini[1].includes(contrappunto) || !domini[2].includes(chiusura)) throw new Error(`ID raccordo compatto ${i} fuori dominio`);
    if (estensione !== layout.posizioni[i].estensione) throw new Error(`estensione raccordo compatto ${i} non valida`);
    const firma = voce.join("|");
    if (visti.has(firma)) throw new Error(`raccordo compatto ${i} duplicato`);
    visti.add(firma);
    return { fuoco, contrappunto, chiusura, estensione };
  });
  let cursore = 0;
  const azioneCount = layout.posizioni.filter((x) => x.sezione === "azione").length;
  const raccordiAzione = raccordi.slice(cursore, cursore += azioneCount);
  const esiti: Record<string, { raccordi: Array<Record<string, string>> }> = {};
  for (const chiave of layout.chiaviRami) {
    const n = layout.posizioni.filter((x) => x.sezione === `esito.${chiave}`).length;
    esiti[chiave] = { raccordi: raccordi.slice(cursore, cursore += n) };
  }
  return { scelta: { raccordi_azione: raccordiAzione, esiti } };
}

function schemaRaccordi(atomi: readonly AtomoMeccanico[], totaleMinimo: number, totaleMassimo: number, _tettoSlot: number): Record<string, unknown> {
  const caratteriAtomi = atomi.reduce((n, a) => n + a.testo.length, 0);
  if (!atomi.length || caratteriAtomi >= totaleMassimo) throw new Error(`schema raccordi impossibile: atomi ${caratteriAtomi}, misura ${totaleMinimo}-${totaleMassimo}`);
  return {
    type: "array",
    items: {
      type: "object",
      properties: {
        fuoco: { type: "string", enum: Object.keys(SLOT_RACCORDI.fuoco) },
        contrappunto: { type: "string", enum: Object.keys(SLOT_RACCORDI.contrappunto) },
        chiusura: { type: "string", enum: Object.keys(SLOT_RACCORDI.chiusura) },
        estensione: { type: "string", enum: [totaleMinimo >= 600 ? VOCABOLARIO_COMPATTO.estensione[1] : VOCABOLARIO_COMPATTO.estensione[0]] },
      },
      required: ["fuoco", "contrappunto", "chiusura", "estensione"],
      additionalProperties: false,
      description: "Scelta ordinata di slot narrativi chiusi. Non scrivere prosa libera.",
    },
    minItems: atomi.length,
    maxItems: atomi.length,
  };
}

/** Lo schema d'uscita espone a Luna soltanto gli slot fra gli atomi. */
export function schemaCiclo(p: PayloadV5, piano: Piano): Record<string, unknown> {
  const ruolo = p.ruolo;
  const tetti = TETTI_PROSA[ruolo];
  const intenzioneId = selezionaIntenzione(p);
  const scheletro = costruisciScheletroCiclo(p, piano, intenzioneId);
  const chiavi = Object.keys(scheletro.esiti).sort();
  const rami: Record<string, unknown> = {};
  for (const k of chiavi) {
    rami[k] = {
      type: "object",
      properties: { raccordi: schemaRaccordi(scheletro.esiti[k], tetti.branca[0], tetti.branca[1], 220) },
      required: ["raccordi"],
      additionalProperties: false,
      description: `Raccordi della branca «${k}». Con gli atomi protetti il paragrafo finale deve misurare fra ${tetti.branca[0]} e ${tetti.branca[1]} caratteri.`,
    };
  }
  return {
    type: "object",
    properties: {
      scelta: {
        type: "object",
        properties: {
          raccordi_azione: {
            ...schemaRaccordi(scheletro.azione, tetti.azione[0], tetti.azione[1], 260),
            description: `Raccordi dell'azione. Con gli atomi protetti il paragrafo finale deve misurare fra ${tetti.azione[0]} e ${tetti.azione[1]} caratteri.`,
          },
          esiti: { type: "object", properties: rami, required: chiavi, additionalProperties: false },
        },
        required: ["raccordi_azione", "esiti"],
        additionalProperties: false,
      },
    },
    required: ["scelta"],
    additionalProperties: false,
  };
}

export async function improntaPrompt(): Promise<string> {
  const dati = new TextEncoder().encode(PROMPT_SISTEMA + "\n" + JSON.stringify(ISTRUZIONI_RUOLO) + "\n" + ISTRUZIONE_ATTACCO_SENZA_ESITO);
  const h = await crypto.subtle.digest("SHA-256", dati);
  return [...new Uint8Array(h)].map((b) => b.toString(16).padStart(2, "0")).join("");
}
