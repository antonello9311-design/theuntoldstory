# Piano · Narratore finale dell'Esame Genin · revisione architetturale 4.6.0

TASK-ID: `ESAME-GENIN-NARRATORE-FINALE-001`  
Baseline LIVE: database head documentata `20260903203601 …_006_recovery` · Edge osservata `exam_genin_ai` v123 / `4.1.0-NU001` · prompt21 · sorgente 6/6 byte-identica alla recovery · produzione non mutata.

## Perimetro

La revisione 4.6.0 sostituisce anche i segmenti meccanici liberi della 4.5.0. I fatti diventano atomi tipizzati costruiti esclusivamente dalla Edge e mai emessi o riscritti da Luna, senza cambiare il wire pubblico consumato da database e LAND:

1. la Edge sceglie una sola intenzione offerta; Luna riceve soltanto slot di raccordo associati allo scheletro già chiuso;
2. la Edge costruisce per ruolo gli atomi `esito`, `risposta_fisica`, `movimento`, `nuova_intenzione`, `intervento_sensei` e `assetto_finale`: i fatti risolti arrivano dal referto, mentre le risposte delle branche derivano esclusivamente dalla tabella chiusa `esito × bersaglio` del server; attore, risultato, posizione e iniziativa non sono mai scelti dal modello; `png_finale` richiede il Sensei e tutti i suoi atomi conclusivi portano iniziativa terminale `prova chiusa`;
3. la Edge sceglie deterministicamente una sola intenzione fra quelle già autorizzate dal server; `intenzione_id` non attraversa il confine generativo; ogni branca riceve i propri atomi di esito, risposta e assetto;
4. Luna sceglie soltanto quadruple ordinate di ID chiusi (`fuoco`, `contrappunto`, `chiusura`, `estensione`), una per atomo; nessuna prosa o battuta attraversa il confine generativo;
5. la Edge valida keyset, domini, cardinalità e duplicati, quindi materializza internamente i raccordi atmosferici: attori, fatti e testo libero non possono essere emessi dal modello;
6. la Edge sceglie varianti linguistiche degli atomi da librerie server-side mediante una selezione deterministica su ricevuta/atomo, quindi la semantica è immutabile senza imporre una sola formula;
7. la Edge compone `raccordo → atomo → raccordo` e assegna le fonti frase-per-frase; il solo output pubblico resta `intenzione_id` + `azione_png` + `esiti`, senza atomi o slot esposti;
8. prosa, densità, limiti, Luna/`high`, payload DB5 e una sola chiamata per ciclo restano invariati.

## File

- `[NEW] candidato/edge/player_bridge.ts` — estrazione deterministica, autorizzazione e soppressione dei claim.
- `[NEW] candidato/edge/memoria.ts` — memoria stilistica non autoritativa.
- `[MODIFY] candidato/edge/contratto.ts` — tipi dei claim, ampiezza opzionale e nuova versione candidata.
- `[MODIFY] candidato/edge/piano.ts` — piano basato su `player_reprise`, memoria e ampiezza autoritativa.
- `[MODIFY] candidato/edge/prompt.ts` — schema JSON dei soli raccordi, con cardinalità derivata dagli atomi protetti.
- `[MODIFY] candidato/edge/validatore.ts` — errori meccanici separati da rilievi qualitativi.
- `[MODIFY] candidato/edge/index.ts` — telemetria distinta e supporto al banco controllato; una sola risposta pubblicabile.
- `[MODIFY] candidato/edge/provenienza.ts` — costruttore degli atomi tipizzati, librerie linguistiche server-side, contratto dei raccordi, composizione e provenienza deterministiche.
- `[NEW] candidato/test/` — fixture sintetiche e test automatici del ponte, memoria, piano e validatori.
- `[NEW] candidato/CONTRATTO_DB.md` — forma richiesta ai quattro corpi LIVE post-461.
- `[NEW] candidato/REPLAY_MANIFEST.md` — selezione sanitizzata dei replay e criteri frase-per-fonte.
- `[MODIFY] referti/` — unica review indipendente finale; nessun esito si autocertifica.

## Contratti

### Ampiezza

Il database resta autoritativo. Le intenzioni e i referti potranno aggiungere soltanto il vocabolario chiuso `nessuno` / `un passo` / `due passi` / `tre o più passi`, con l'eventuale suffisso sul bordo, derivato dal movimento già risolto. Nessuna coordinata o quantità viene scelta dall'Edge o dal modello. La candidata accetta il campo in modo opzionale, quindi resta compatibile con payload v5/461 finché la migrazione non è autorizzata.

### Confine del giocatore

Il testo grezzo è input non fidato e non arriva più direttamente al modello. Il ponte locale continua a riconoscere i claim per i controlli di regressione, ma la candidata non li trasporta nel brief generativo.

Sono soppressi prima del prompt:

- auto-risoluzioni, danni, contatti ed esiti dichiarati dal giocatore;
- movimenti o bersagli in conflitto con ricevuta e fatti server;
- pensieri, intenzioni interne o voce non letterale;
- dettagli numerici che il motore non autorizza.

La battuta letterale non attraversa il ponte. In questa candidata nemmeno i claim sanitizzati entrano nel brief del modello: `player_reprise_ids` è materializzato come lista vuota dalla Edge. È una riduzione deliberata della superficie generativa, non uno spostamento di autorità; il ponte e i controlli restano nel bundle per impedire regressioni e per un eventuale ripristino futuro dopo certificazione.

### Atomi protetti, raccordi chiusi e wire pubblico invariato

La Edge seleziona prima una sola intenzione con una funzione deterministica su `ricevuta_id + ruolo` e sull'insieme ordinato delle intenzioni già offerte dal server. Lo schema del modello richiede poi una `scelta` con soli `raccordi_azione` ed `esiti`: `intenzione_id` non viene esposta né accettata. Lo scheletro contiene una sequenza ordinata di `N` atomi tipizzati e un array di `N` raccordi, uno prima di ciascun atomo; ogni branca segue lo stesso contratto sul proprio scheletro. `minItems=maxItems=N` e `additionalProperties=false` impediscono omissioni, inversioni strutturali, intenzioni, atomi, testi meccanici o campi pubblici. Nessun raccordo segue l'ultimo atomo: l'assetto finale resta così l'ultima frase del paragrafo.

Ogni atomo contiene identificatore, tipo, attore, bersaglio, risultato, risposta fisica autorizzata, posizione/assetto, iniziativa, testo server-side e fonti. Il testo è costruito da una libreria chiusa con più varianti semanticamente equivalenti; la scelta della variante è deterministica su `ricevuta_id + intenzione_id + id_atomo`. Luna non vede né restituisce il testo finale degli atomi e non può ometterli, invertirli o riscriverli.

Ogni raccordo nasce da quattro slot semantici chiusi: Luna restituisce soltanto gli ID, la Edge conserva i frammenti testuali e li compone. La combinazione descrive esclusivamente luce, aria, polvere, suoni impersonali, ombre e ritmo percettivo; nessuna parola libera può nominare attori o introdurre fatti. Atomi e raccordi interni non entrano nell'oggetto consegnato al database, alla LAND o nel referto pubblico.

Le fonti restano un vocabolario chiuso e vengono assegnate dalla Edge: ogni atomo porta soltanto le fonti del fatto che materializza; ogni raccordo usa `server.scena` e, per il solo stile, `persona.sfidante`/`memoria.stile`, mai come fonte di fatti meccanici. Nessun ID viene emesso dal modello.

### Validazione

- `errori`: keyset/cardinalità/tipi/duplicazioni dei raccordi; tentativo di emettere o riscrivere atomi; persone, cifre, dialogo, corpo, movimento, colpi, esiti, ferite, stati, posizione o iniziativa nei raccordi; mismatch fra atomi ricostruiti e ricevuta; a capo/controlli ed elementi assenti. Bloccano la pubblicazione.
- `qualita`: ripetizioni, chiusure equivalenti, battuta opaca, mancata risposta a una domanda, assenza di evoluzione o di firma della persona. Non cambiano i fatti e richiedono nuova generazione nel banco controllato.
- `avvisi`: segnali diagnostici non conclusivi. Le invenzioni linguistiche a vocabolario aperto non vengono dichiarate automaticamente coperte da un ID: il replay frase-per-fonte e la review restano il gate di certificazione.

Il LIVE conserva una sola risposta pubblicabile per ciclo. Nessun secondo giudice IA. Anche il banco 4.6 esegue una sola chiamata per ciclo: nessun retry o rigenerazione durante la raccolta.

## Gate

1. Test automatici e fault injection sistemica su omissione/duplicazione slot, tentata omissione o riscrittura di un atomo, inversione attori, esito/bersaglio/posizione/iniziativa errati, persona estranea, cifra, dialogo, movimento, colpo, stato e ogni separatore di riga; controllo sintattico e checksum.
2. Unica review indipendente finale sul contratto e sul comportamento: `P0/P1/P2 = 0`.
3. Nessuna migrazione prevista: firme DB/RPC e payload LAND restano invariati; se emerge un delta pubblico, STOP con differenza esatta.
4. Dopo review 0/0/0, deploy sul solo branch QA healthy/allineato e confronto sorgenti byte-esatto.
5. Una campagna A–G completa Luna/`high`, una sola chiamata per ciclo e nessun retry: un rosso blocca la produzione ma non interrompe la raccolta salvo P0, rischio dati/sicurezza, budget o mutazione non prevista.
6. I finding si raggruppano per causa sistemica. È ammessa al massimo una revisione architetturale aggregata, seguita da una sola ricertificazione A–G completa; mai micro-correzioni per fixture.
7. Se la ricertificazione è interamente verde, readiness nominativa di produzione e prova reale Staff/Test Room; nessun deploy di produzione senza gate nominativo.

## Vincoli dichiarati

- Nessun vincolo di gioco aggiunto o allentato in questa fase offline.
- Nessuna firma RPC o forma pubblica prevista: l'oggetto segmentato esiste soltanto fra modello ed Edge; se l'implementazione richiedesse un delta DB/LAND, STOP con il delta esatto.
- Nessun file del sito o del regolamento viene toccato da questa revisione qualitativa.
- Il job `esame-tick` non viene mai spento.
- `reasoning=high` resta invariato. Diagnosi del 04/09: 16.384 è il solo delta della richiesta A02 respinta subito con `invalid_prompt`, mentre 8.192 era accettato dal provider; A02 ha inoltre zero branche e nessun `esito_precedente`, ma il prompt statico pretendeva di raccontarlo. La 4.4.2 riportava `png_attacca` a 8.192 e rendeva esplicita la variante senza esito precedente. Dopo i due `max_tokens` della ricertificazione v119, la 4.6.1 applica il nuovo mandato: **+20% arrotondato per eccesso**, quindi 9.831 per `png_difende/png_attacca` e 7.373 per `png_esito/png_finale`. I limiti della prosa restano separati e invariati rispetto al precedente +20% sui caratteri.
- Nei soli replay sanitizzati, `png_esito`/`png_finale` completano `esito_precedente` copiando il referto autoritativo congelato sulla stessa fotografia quando lo scambio storico non è presente. Nessun fatto viene dedotto; la dogana V5 e il validatore restano identici.
