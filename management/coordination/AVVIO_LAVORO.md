# Avvio e coordinamento del lavoro

Versione 1.2 · punto 2: costruzione del nuovo processo, autorizzata da Antonello il 09/09/2026 · verificata e installata localmente. Punto 1: documenti riordinati e decisioni consolidate, completato localmente. Antonello ha autorizzato la ripresa dei caricamenti: il deposito GitHub è selettivo e autonomo quando i file sono pronti, secondo i controlli e i gate distinti di AGENTS. La prima consegna tecnica TASK-PM-AVVIO-001 conserva l’etichetta storica «blocco1»; la numerazione corrente distingue documenti e processo. AGENTS mantiene i gate; questo file descrive l’esecuzione.

## Cosa deve fare Antonello

Aprire una task nella cartella del progetto e descrivere il risultato desiderato, anche soltanto come idea. L'assistente organizza il lavoro tecnico. Per esempio: «Voglio che il giocatore capisca perché non può usare una tecnica». Non servono comandi, nomi di file o scelta degli specialisti.

La prima risposta spiega risultato atteso, cosa è già disponibile, cosa manca e il primo passo concreto. Si chiedono soltanto decisioni di prodotto realmente mancanti o autorizzazioni non già concesse. Una richiesta di analisi rimane analisi; l'avvio non autorizza da solo modifiche applicative, spese, apply, deploy o apertura agli utenti.

## 1. Ingresso unico

1. Verificare la cartella effettiva; leggere `AGENTS.md` e `dossier/00_LEGGIMI.md`.
2. Leggere contesto, fotografia e tabellone indicati lì. Per il solo metodo non ripetere una lettura DB; se si dichiara lo stato backend attuale servono interrogazioni pertinenti. Le fotografie conservano la propria data.
3. Aprire il routing, le aree interessate e `SCHEDA.md` / `HANDOFF.md` del cantiere assegnato. Per una fonte mancante consultare solo il blocco pertinente dell'indice, senza riaprire le task archiviate.
4. Consultare il registro con `task_guard.py ... status` e i lavori avviabili con `ready`. Un registro vuoto non significa prodotto finito: i lavori ereditati stanno nel tabellone e nei cantieri. Non iscrivere né riprendere automaticamente il backlog.
5. Il PM traduce il mandato in risultato osservabile, criteri, scope, contratti, dipendenze, owner, priorità e budget. Per un lavoro semplice usa AVVIO_TEMPLATE.json; per più incarichi collegati usa PIANO_TEMPLATE.json e task_plan.py. È lavoro dell’assistente. Conserva il piano nel cantiere assegnato; non registra in anticipo incarichi che consumano contratti ancora da produrre.
6. Il pianificatore propone gli incarichi pronti e prepara i briefing. L’assistente verifica gli esiti e assegna gli specialisti interni; ogni owner registra e acquisisce il proprio scope con il guard prima di scrivere. Il piano da solo non avvia agenti o operazioni.

Se la cartella canonica o il registro condiviso non sono raggiungibili, procedere con letture e proposte; il PM risolve l'accesso prima delle scritture concorrenti. Nessuna copia privata del registro che pretenda di assegnare gli stessi file.

## 2. Competenze e parallelismo

| Funzione | Responsabilità | Quando può avanzare |
|---|---|---|
| PM | Mandato, priorità, contratti, integrazione, riepiloghi centrali | Sempre nel proprio scope; una sola regia del lavoro |
| Backend / motore | Autorità server, dati, regole, ricevute e permessi | Dopo le decisioni e i contratti necessari |
| Frontend | Percorso del giocatore, messaggi, pannelli e accessibilità | In parallelo su contratto stabile; un owner per ciascuna pagina monolitica |
| Narrativa IA | Contesto autorizzato, memoria, voce e resa scenica | Dopo il contratto dei fatti; nessuna autorità su valori o scelte dei PG |
| Regole / contenuti | Regolamento, guida e testi | In parallelo dopo la ratifica del comportamento |
| QA | Casi e criteri prima; review e collaudo della candidata dopo | Legge indipendentemente, prova la stessa revisione consegnata |
| Rilascio | Riconciliazione, deposito selettivo e verifica | Dopo i gate pertinenti; una pubblicazione per volta |

SCHEDA, HANDOFF e STORICO comuni hanno un integratore unico: gli specialisti gli consegnano i propri delta, senza prenotare tutti gli stessi riepiloghi durante la lavorazione.

Le competenze non richiedono sette agenti. Il PM usa gli slot effettivamente disponibili e delega sottotask indipendenti ad agenti interni, senza aprire nuove task visibili salvo richiesta di Antonello. Per un piccolo intervento bastano owner e verifica pertinente. Per lavori trasversali il PM avvia in parallelo tutti i rami pronti entro le risorse disponibili; se un ramo si blocca proseguono quelli indipendenti.

Ordine: incidente concreto su dati/sicurezza → impedimento al percorso scelto → dipendenza che sblocca più lavori → resto del valore richiesto. A parità di priorità si preferisce una consegna breve e verificabile. Il registro ordina per priorità e dipendenti diretti; il PM valuta urgenza e dimensione, senza una falsa stima automatica del tempo.

Resta il massimo di tre cantieri «in lavoro». Si riusano quelli esistenti; il blocco organizzativo è un incarico PM nei percorsi di coordinamento e non apre un quarto prodotto. I tre cantieri ereditati ancora aperti impegnano gli slot anche con task archiviate: il PM controlla il tabellone prima di autorizzarne altri. Il limite tecnico del registro sulle acquisizioni simultanee è una protezione aggiuntiva, non sostituisce questo controllo.

### Dal piano agli specialisti

Il piano è un elenco di incarichi con lo stesso formato del registro, un obiettivo e il numero massimo di specialisti contemporanei. `task_plan.py` lo legge senza modificarlo e senza creare un registro. Segnala dipendenze mancanti/circolari, collisioni, risorse occupate e incarichi che possono avanzare insieme. La proposta di parallelismo non è una prenotazione: claim resta l’autorità locale per gli scrittori cooperativi.

Per un lavoro trasversale l’ordine ordinario è contratto condiviso → backend e frontend sui file distinti → integrazione → review indipendente → correzione aggregata → controverifica, fino a cinque passaggi cumulativi e arresto al verde → collaudo e gate pertinenti. Il QA può preparare i criteri durante l’implementazione; la review della candidata attende il congelamento. I riepiloghi comuni restano all’integratore. Per un lavoro piccolo non si creano artificialmente tutti questi ruoli.

Quando termina un incarico, il PM legge esito, prove e contratto consegnato, poi riesegue l’analisi del piano. Le dipendenze pronte vengono registrate soltanto ora, contro i file effettivamente prodotti. Se uno specialista si blocca, i rami indipendenti continuano; il PM registra il blocco e non usa una consegna rossa come prerequisito valido. I gruppi suggeriti sono una scelta pratica, non una promessa matematica del tempo minimo assoluto.

L’avvio da un’idea e l’assegnazione degli agenti sono gestiti dall’assistente in questa task. Gli strumenti locali non possono far partire da soli una conversazione chiusa o un’app esterna. Non si creano nuove task visibili o monitor senza il mandato pertinente. Al momento ci sono quattro slot complessivi: regia più al massimo tre specialisti, da ricontrollare se l’ambiente cambia. La costruzione del processo non riapre altre task.

## 3. File e risorse: prenotazione concreta

`management/tooling/task_guard.py` usa Python 3.9 o successivo e la sola libreria standard. Tutte le sessioni sulla stessa macchina usano la medesima `--root` canonica. Stato locale in `management/coordination/runtime/`, escluso dalla pubblicazione; non copiare SQLite fra macchine o worktree per simulare coordinamento.

Si dichiarano **file esatti**, anche quelli nuovi; i contratti stabili entrano in `inputs`. Si prenotano inoltre le risorse condivise pertinenti usando gli stessi nomi:

- `browser:chrome`, `browser:safari`, `browser:iab` per le rispettive superfici condivise;
- `github:main` per il deposito su main;
- `db:produzione` per una mutazione nominativamente autorizzata;
- `staff:room` per una prova nella Staff; `utenti:test-room` per quella utenti;
- `schema:contratto:<nome>` per modificare un contratto esterno non rappresentato da un file condiviso.

Le letture ordinarie non richiedono un'esclusiva del DB. Il browser, invece, può condividere selezione e stato: due esecutori non lo manovrano insieme. Gli ambienti Docker distinti hanno nomi di risorsa distinti; due banchi sullo stesso database locale condividono una risorsa.

La registrazione fotografa le impronte. L'acquisizione è atomica: rifiuta dipendenze non consegnate, file/risorse già occupati, contratti letti mentre un altro li scrive e variazioni rispetto alla baseline. Nessuna scadenza riassegna da sola una prenotazione: prima si verifica il vecchio owner.

Per le scritture cooperative si prepara il contenuto in una copia di lavoro e si usa `apply`: verifica owner e impronte, conserva il precedente e sostituisce il singolo file. Dopo ogni modifica aggiorna l'impronta attesa. I generatori che scrivono direttamente si eseguono in una copia isolata, poi si integrano gli output esatti attraverso la stessa porta. `check` verifica lo scope prima del passaggio di consegna.

**Limite reale:** il registro non è un sistema di permessi e non intercetta un editor, un'altra app o un agente che lo ignora. Il nome owner non è un'identità autenticata. Previene collisioni tra partecipanti conformi e rileva cambiamenti estranei; al drift si ferma la scrittura interessata. Nessuna promessa di esclusione assoluta fra dispositivi. Per worktree e macchine diverse il PM assegna scope canonici disgiunti e integra in sequenza sulla cartella condivisa; nessun upload diretto da due copie concorrenti.

Il guard rifiuta di modificare i propri strumenti. Per bootstrap e manutenzione di questi soli strumenti il PM assegna un owner tooling esclusivo, sospende le operazioni di registro, conserva le precedenti copie e verifica le impronte prima della sostituzione. Nel punto 2 questa eccezione riguarda task_guard.py e test_task_guard.py; sync_skills.py segue il normale percorso del registro. Le modifiche successive ai documenti passano nel registro dopo la sua verifica. Questa eccezione iniziale non si eredita nei lavori di prodotto.

### Comandi per l'assistente

Piano con più incarichi, in sola lettura:

```text
python3 -B management/tooling/task_plan.py --root /Users/antonello/Desktop/theuntoldstory --plan /percorso/assoluto/PIANO.json
```

Aggiungere `--brief TASK-ID` per il briefing proposto o `--spec TASK-ID` per ottenere la specifica soltanto se registrabile ora. L’assistente salva l’output in un file temporaneo e lo passa al registro; nessun comando del pianificatore prenota, scrive o avvia agenti. Gli ID già registrati si gestiscono nel guard e non vengono registrati di nuovo. L’analisi considera gli incarichi già attivi nel limite max_parallel; se la regia mantiene una prenotazione attiva, occupa uno dei posti del piano. La capacità effettiva dell’ambiente e il tetto dei cantieri restano verifiche ulteriori del PM.

Su una copia nuova senza runtime il pianificatore segnala stato non confermato: il PM verifica il coordinamento, compila il primo incarico effettivamente autorizzato dal modello singolo e lo registra con il guard, che inizializza il registro. Non si crea un incarico fittizio consegnato né si copia SQLite da altre macchine. Il modello PIANO_TEMPLATE contiene segnaposto: sostituire cantiere, percorsi, mandato, criteri e budget prima di usarlo.



Usare sempre `python3 -B management/tooling/task_guard.py --root /Users/antonello/Desktop/theuntoldstory` seguito dal comando pertinente:

```text
status
ready
register --spec /percorso/assoluto/incarico.json
claim TASK-ID --owner OWNER
apply TASK-ID --owner OWNER --path percorso/relativo.md --source /percorso/assoluto/candidato.md
check TASK-ID --owner OWNER
release TASK-ID --owner OWNER --outcome consegnato --handoff percorso/HANDOFF.md --note "Esito verificato"
```

Le directory di destinazione devono già esistere e gli input devono essere disponibili. Le dipendenze devono essere registrate prima dei consumatori. Se il produttore cambia un input, la baseline del consumatore diventa vecchia: il PM riconcilia e registra un nuovo incarico con nuovo ID, senza modificare SQLite. Non registrare in anticipo un consumatore contro un contratto che deve ancora essere scritto.

## 4. Dal candidato alla prova

Il percorso completo è: esigenza del giocatore → contratto → backend / UI / narrazione pertinenti → candidato integrato → review → collaudo → gate di rilascio → riscontro reale → consegna. Non si chiude un requisito perché è pronta soltanto la sua metà frontend o backend.

Si fissano prima casi, tempo, chiamate e token della campagna; i valori del modello JSON sono un esempio, non un budget di produzione. Il registro conserva minuti/casi/chiamate dichiarati; non misura né interrompe automaticamente processi o fatturazione. Owner e PM tengono il consumo reale nelle evidenze del cantiere, inclusi token quando pertinenti. A limite raggiunto si consegna quanto raccolto, senza espandere il banco.

Per ogni candidata: un passaggio indipendente iniziale, fino a cinque correzioni aggregate e cinque controverifiche, contando i passaggi già eseguiti. Il rosso intermedio consente il seguito autonomo nel mandato e nel limite; il verde termina il ciclo, il quinto rosso torna al PM. Matrice completa e budget fissato prima di ciascuna campagna; niente micro-patch, nuovi esempi esplorativi, rinomine o riprese che azzerino il conteggio. Errori del banco e difetti del prodotto restano distinti; le evidenze precedenti sono conservate. Regola canonica in AGENTS.md §Budget di revisione vincolante, ratificata il09/09 da Antonello.

Per sviluppo DB vale Docker/PostgreSQL reale e la valutazione dei rischi d'integrazione di AGENTS. Per il solo collaudo di funzioni già pubblicate si usa direttamente il percorso protetto autorizzato. Autorizzazione a una prova non autorizza rilascio, enable o apertura generale. Un contesto di test non protegge automaticamente risorse reali: verificare isolamento e postflight, conservare storico e chiudere soltanto la prova propria salvo mandato contrario.

UI: verificare l'intero gesto dell'utente, esito visibile, persistenza/errore e superficie prevista; conservare screenshot pertinenti. Backend: ricevute, autorità e invarianti. Narrazione: i fatti derivano dal server, il testo non inventa esiti né parla al posto del PG. Il Fato deve far capire la scena in italiano naturale; meccanismi e dati tecnici rimangono nelle evidenze interne.

## 5. Consegna, arresto e ripresa

Gli stati del registro sono dell'**incarico**. `consegnato` non significa prodotto in uso, approvazione della review o rilascio; i gate hanno evidenze proprie. Una dipendenza è soddisfatta solo se il suo contratto d'uscita era quello richiesto dal consumatore. Non usare una consegna rossa come prerequisito verde.

All’avvio predisporre una consegna iniziale nel percorso HANDOFF assegnato, prima delle altre scritture, così resta un riferimento anche in caso di interruzione. Prima di `release`: salvare SCHEDA, HANDOFF e una riga STORICO nel cantiere; aggiornare le sezioni vive pertinenti e comunicare i delta centrali al PM. Per un incarico soltanto PM si usa la consegna nel deposito `management/coordination/HANDOFFS/`, senza aprire un cantiere fittizio. Scrivere completato, incompleto, prove/versioni, decisioni, blocco preciso, file locali/non pubblicati e prossimo passo.

`release ... --outcome sospeso` preserva il lavoro e non sblocca le dipendenze. In caso di drift l’owner può sospendere indicando il proprio handoff preesistente e una nota obbligatoria: il registro conserva baseline, impronte osservate e motivo senza riscrivere i file. Non forzare l’aggiornamento dell’handoff attraverso file in conflitto; il motivo corrente resta nell’evento di sospensione. Il PM legge entrambe le evidenze, riconcilia i contributi e assegna un nuovo incarico. `consegnato` richiede sempre baseline pulita. Un owner non risponde? Il PM verifica task, processi e file; non forza una riassegnazione in base al solo tempo trascorso. La v1 non ha un comando di furto del lock: si riconcilia il registro con l'owner prima della ripresa. Non cancellare il runtime per liberare i file.

Una richiesta di chiusura ferma nuovi rami, prove e provider. Si completa o si mette in sicurezza l'operazione già in corso, si acquisisce l'esito, si salva la consegna e solo allora si archivia la task. Archiviare la task non chiude il prodotto né cancella la cartella del cantiere. I monitor delle task si sospendono separatamente; l'anti-stop del computer è un servizio distinto. Il punto 2 non riaccende monitor o vecchie task.

## 6. Skill, Codex e Claude

`AGENTS.md` è l'ingresso locale di Codex; `CLAUDE.md` importa lo stesso file per Claude Code. Le skill gdr-rotta, gdr-contesto e gdr-chiusura rimandano qui e alle fonti correnti. Le copie operative manutenute sono in `management/coordination/skills/`; quelle installate vengono confrontate e aggiornate esplicitamente, preservando le precedenti. Un aggiornamento del plugin può sostituire la cache: ricontrollare le copie, non creare una seconda procedura.

Le altre skill mantengono la competenza tecnica; le sezioni sul metodo rimandano ad AGENTS. Nel progetto GDR il protocollo generico non impone nuovi file in root, nuova approvazione per lavoro già autorizzato o duplicazione del piano.

Il testo per le istruzioni esterne Claude è in `dossier/06_ISTRUZIONI_PROGETTO.md`. Aggiornare i file sul Mac non aggiorna automaticamente claude.ai/Cowork o altre macchine. La verifica di sincronizzazione distingue sorgente di progetto, copia locale installata e impostazione esterna; l'ultima resta non verificata finché non si controlla nell'app autorizzata. Una sessione che ha già caricato una skill vecchia deve rileggere la versione su disco.

Per controllare le copie installate, usare `python3 -B management/tooling/sync_skills.py --root ROOT_CANONICA --installed CARTELLA_SKILLS_INSTALLATE`. Il controllo è in sola lettura. Per allinearle produrre prima `--plan FILE_ASSOLUTO_NUOVO`, quindi usare gli stessi argomenti con `--apply FILE_ASSOLUTO_NUOVO`: il piano deve ancora coincidere con le impronte. Le otto copie precedenti restano nel runtime locale. L'applicazione è verificata per singolo file; un errore a metà non promette un ripristino totale e richiede riconciliazione. Non eseguire durante un aggiornamento del plugin. Il percorso della cache va verificato sul Mac, senza supporre che la versione sia sempre la stessa.

## 7. Collaudo del punto 2

Il guard viene provato in cartelle temporanee con processi concorrenti e casi di collisione, indipendenza, dipendenze, owner errato, drift e percorsi non ammessi. Si verifica un percorso register → claim → apply → check → release e che i backup conservino i byte originali. Nessun test del guard usa DB, provider o file di gioco.

La review indipendente controlla anche richieste reali: una semplice correzione UI, un lavoro frontend/backend con contratto condiviso, un incarico solo documentale e una ripresa da task archiviata. Una prova a tavolino del metodo non certifica il gameplay. Evidenze e limiti sono nella consegna `HANDOFFS/TASK-PM-AVVIO-001.md`.


Il pianificatore v1.1 ha superato12/12casi integrati e controverifica finale indipendente0/0/0, dopo una sola aggregata. La consegna TASK-PM-PROCESSO-002 registra installazione, limiti e coda di pubblicazione.
