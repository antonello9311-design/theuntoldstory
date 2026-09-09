# Avversario sintetico nativo nella Staff Test Room

**Stato: proposto · NARRATIVE-STAFF-SYNTHETIC-PLAN-001 · 09/09/2026 · owner PM-DESIGN.** Documento di progettazione; nessun codice, schema, permesso, scena o account modificato. Le attività descritte sotto sono lavori futuri da assegnare dal PM. Non costituisce autorizzazione ad applicare una migrazione o ad aprire il servizio agli utenti.

## 1. Risultato richiesto e scelta proposta

Antonello vuole continuare a giocare con **Riuji**, che è totalmente escluso da test, azioni automatiche, accessi, chiusure e preparazioni del banco. Il collaudo deve poter usare **testperfunzioni e un avversario simulato**, conservando intatta anche la scena già esistente. La nuova indicazione prevale sulle autorizzazioni precedenti che comprendevano Riuji.

La soluzione proposta è un **PNG con profilo permanente riutilizzabile, richiamabile soltanto nelle Test Room, con una nuova istanza creata dal server per ogni prova**, comandabile attraverso controlli di prova riservati allo staff. Deve percorrere apertura, dichiarazione, difesa, risoluzione, movimento, pubblicazione narrativa e chiusura dello stesso percorso ordinary che si vuole collaudare. L'avversario non richiede un account né una scheda in `characters`: il motore possiede già un'identità nativa per gli attori PNG.

La permanenza del profilo e il richiamo rapido solo in stanza Test sono ratificati da Antonello il 09/09. Il server verifica il luogo e i permessi a ogni richiamo; la chiusura conserva profilo, storico e audit, mentre risorse, effetti e posizione appartengono alla singola prova. Nessun richiamo di questo profilo nel mondo di gioco, nelle quest o nelle missioni reali. Staff e stanza utenti mantengono cataloghi e controlli distinti.

Il primo incremento Staff comprende un solo PG autorizzato, testperfunzioni, e un PNG. Il contratto di identità, controllo e fonti sarà riutilizzabile dal multiattore; la parità con tutti gli scontri Master, quest e missioni rimane un ampliamento distinto. Il collegamento non richiede che tutti quei domini siano rilasciati contemporaneamente.

Il termine «mock» indica qui l'avversario sintetico e le sue risorse simulate. Un suo turno risolto dal motore reale può qualificare quel percorso applicativo; una fixture locale o una risposta narrativa simulata non dimostra Auth, Edge, provider o comportamento sul sito.

## 2. Evidenze disponibili e loro limiti

La lettura di questo piano non ha eseguito SQL, chiamate IA o attività browser. Le evidenze di produzione sono quelle già raccolte dall'owner e dal PM; prima dell'implementazione il DB owner dovrà riconciliare i contratti pertinenti con la versione allora effettiva.

| Fonte | Evidenza utilizzata | Limite |
|---|---|---|
| `../HANDOFF.md`, stato del rilascio 09/09 | Edge `combat_narratore_ai` v24 ACTIVE; migrazione `20260909183721 narrative_tech_sources_staff_001`; snapshot MD5 `a417e6a98201a2177cb8c244a736bb3c`; helper `955228bdc23c89cdb287198db57231b8`; nessun collaudo provider ancora eseguito | Rilascio attestato dal PM, non riverificato da questo piano |
| `NARRATIVE_TECH_INSTALL.sql`, circa righe 190–192 e guard Staff ordinary | Il produttore dello snapshot ricava ancora esattamente due PG da `members` e `characters`; il nuovo helper delle fonti è collegato al solo Staff ordinary | Il rilascio del narratore non ha introdotto una porta ordinary PG+PNG |
| Ricognizione NARRATIVE-AI del 09/09, 18:35:02–18:35:38 UTC, tre interrogazioni già concluse | `accept_invitation` autentica il destinatario e richiede presenza dei due PG; `combat_v2_ordinary_open` costruisce due attori da schede reali; `members.character_id` ha FK e obbligo di valorizzazione; slot 1/2 | Fotografia precedente all'apply del narratore delle 18:37; il vecchio MD5 snapshot `542eb2b95627522ee8e0f28507fdf29b` non è lo stato attuale |
| Stessa ricognizione: `staff_test_allowed` e `commit_master_open` | Ammettere uno o due principal nel controllo Staff non elimina il requisito dei due PG nelle routine chiamate. Il percorso Master apre una sessione e una proiezione differenti | Un Master/PNG non qualifica automaticamente l'hook ordinary |
| `ESPANSIONE_MULTIATTORE.md`, sezioni identità, runtime, Regia, Builder e spazio | Il contratto scena supporta attori PG/PNG; runtime, pubblicazione e fonti ordinary restano specifici. Esistono componenti nativi per PNG, geometria e lifecycle da riusare | Proposte future e fotografie storiche non attestano collegamenti già realizzati; lo stato del rilascio corrente viene dall'HANDOFF |
| `CONTRATTO_FATTI_NARRATIVI.md` e `NARRATIVE_TECH_REVIEW_PASS02.md` | Esiti server, fonti catalogo congelate, ruolo centrale delle role, separazione fra invarianti e stile; qualifica tecnica già ottenuta | Non riaperta; la nuova identità sintetica richiede una nuova integrazione |
| Baseline locale `../../CLAN-L1_2026-09-01/runtime/marionettisti/release/VISIBILITY_STRUCTURE_IMPORT.sql` | Contratti strutturali e routine elencati sotto | Import locale precedente: utile per progettare, non certificazione della produzione odierna |

Per l'ultima fonte il percorso dalla cartella di questo documento è `../../CLAN-L1_2026-09-01/runtime/marionettisti/release/VISIBILITY_STRUCTURE_IMPORT.sql`. I blocchi pertinenti sono: `accept_invitation` 718–795; `display_label` 1524–1545; `combat_v2_ordinary_open` 29121–29154; `master_v2_encounter_open` 33605–33693; `members` 47582–47590; `combat_v2_actors` 53939–53960. I numeri identificano la copia consultata, non righe della definizione live.

In quella struttura `combat_v2_actors` ammette già PG con `character_id` e PNG con `character_id` nullo e un riferimento nativo a istanza PNG o provider. L'apertura Master costruisce PNG da template attivi, senza accettare valori meccanici arbitrari dal client. Al contrario, il consumer ordinary usa schede PG anche per nomi, appartenenza e fonti. Cambiare soltanto il conteggio degli attori lascerebbe irrisolte queste dipendenze.

## 3. Un vincolo preliminare: conservare la scena esistente

La baseline locale delle aperture ordinary e Master contiene controlli contro più combattimenti attivi nello stesso luogo; altri consumer ricavano la scena corrente dal luogo e i PG possono risultare impegnati meccanicamente. Pertanto un semplice nuovo pulsante nella medesima stanza potrebbe collidere con la scena esistente o selezionarla per errore.

Il primo contratto tecnico deve risolvere questa dipendenza senza chiudere, resettare, spostare o scollegare Riuji o testperfunzioni dalla scena esistente. Non si presume che un flag `is_test` renda automaticamente sicura una seconda sessione.

La direzione preferita è un **contesto di prova esplicito**, collegato alla sessione e all'istanza spaziale native, con identificativo della prova, owner autorizzato, attori ammessi e stato. Tutte le operazioni della nuova modalità devono ricevere o derivare senza ambiguità quell'identificativo: ricerca della scena, lock, risorse, offerte, messaggi, snapshot e chiusura. I controlli ordinari di occupazione restano validi per il gioco reale e per il percorso legacy; la nuova modalità deve dimostrare perché una prova isolata non condivide il loro stato di gioco.

Prima di fissare lo schema, il DB owner inventaria i vincoli per luogo, gli indici, i lookup della scena attiva e i controlli di occupazione. Valuta se una istanza Staff privata già supportata possa fornire l'isolamento con meno modifiche. Una seconda stanza, da sola, non risolve eventuali controlli globali sul PG. Non si introduce un bypass generale dei blocchi né si realizza un sistema universale di scene parallele come prerequisito.

Se il percorso non può ancora garantire questa separazione, resta fermata la sola apertura della nuova prova. Lo sviluppo del contratto prosegue; Riuji non diventa un sostituto di comodo e la scena precedente non viene chiusa implicitamente. Questo piano non attesta che un eventuale vincolo meccanico preesistente sul gioco di Riuji sia già risolto.

## 4. Contratto dell'attore e autorità del server

### Identità e creazione

- Il PG reale conserva identità e permessi effettivi. L'avversario è `actor_kind='png'`, con riferimento nativo all'istanza PNG e `character_id` nullo. Nessun account fittizio, FK falsificata, scheda clonata o impersonazione SQL.
- Il server conserva un profilo permanente riferito al template canonico ammesso e crea una nuova istanza per ogni prova; congela versione, tecniche e caratteristiche necessarie nel contesto della sessione. Non si crea un secondo catalogo di tecniche o descrizioni.
- Nome visibile, identità tecnica e capacità sono distinti. Le decisioni usano `actor_id`, sessione e versione; etichette e nomi non identificano bersagli o autorizzazioni.
- La porta di apertura è nuova e riservata alla modalità Staff protetta. Autentica l'operatore, verifica il perimetro della stanza, il PG ammesso e il template, quindi richiama i componenti nativi. Il normale invito fra due giocatori conserva consenso e controlli attuali: non si simula l'accettazione da parte del PNG.

### Controllo, dichiarazioni e difesa

Il primo avversario è comandato esplicitamente dai controlli di prova; non richiede una seconda IA che decida azioni. Un operatore autenticato riceve una capacità circoscritta a quella prova e a quel PNG. La presenza di un medesimo principal su entrambi i lati non rende i due attori intercambiabili.

Le azioni ammesse provengono dalle stesse offerte e dagli stessi validatori del prodotto. Costi, bersagli, distanze, difesa, consumo e risultato sono risolti dal server. Il controller non invia un esito riuscito, un danno o una fine tecnica da imporre al motore. Richieste duplicate, versioni vecchie, bersagli di altre sessioni e comandi dopo chiusura devono essere rifiutati o trattati secondo l'idempotenza del contratto.

Le role del PG mantengono la propria provenienza. La dichiarazione del PNG viene attribuita a un'azione controllata dal server e all'operatore autorizzato, senza inventare un messaggio scritto da un secondo personaggio reale. Serve quindi un collegamento tipizzato fra dichiarazione, attore, azione, turno e fonte: testo di un PG oppure dichiarazione sintetica autenticata. Il testo resta materiale narrativo non fidato, mai un comando al motore.

### Binding del consumer ordinary

`members.character_id NOT NULL` e i join con `characters` richiedono una modifica esplicita. La direzione è rendere `actor_id` l'identità comune e mantenere il legame alla scheda per i soli PG. La scelta fra estensione della membership e adattatore comune con binding tipizzato va chiusa dopo la ricognizione di FK, trigger, indici, RLS e consumer: il piano non autorizza di rimuovere un vincolo alla cieca.

Nel primo incremento resta la cardinalità di due attori, con composizione ammessa PG+PNG soltanto nella nuova modalità Staff. Il vecchio PG+PG continua a usare i propri vincoli. La futura cardinalità multiattore è un contratto successivo; niente `LIMIT 2`, selezione di «altro membro» o confronto per `user_id` deve essere riutilizzato nel nuovo binding senza verificarne il significato.

## 5. Proiezione, narrazione, risorse e chiusura

Il percorso deve conservare `source_kind='ordinary'` con round, report e hash validi, perché è questa la linea da qualificare. Non basta cambiare quel campo a una sessione Master: deve essere prodotto da una vera apertura e risoluzione ordinary conforme al nuovo contratto.

Un resolver condiviso dell'identità alimenta nomi, roster e fonti: scheda autorizzata per il PG, istanza/template nativo per il PNG. `scene_snapshot_v2`, contesto ordinary, dichiarazioni, label e fonti tecniche devono concordare sullo stesso attore. Si riusano catalogo, helper delle descrizioni/effetti e contratto scena esistenti. Il produttore congela fatti e fonti al momento previsto; replay e recupero non ricostruiscono la scena leggendo cataloghi o role modificati dopo.

`scene.mjs` supporta già PG/PNG: si modifica solo se la nuova integrazione ne dimostra la necessità. La voce del PNG può usare persona e facoltà di parlare soltanto quando autorizzate; il narratore non inventa decisioni o battute del PG. Fine, permanenza e distruzione delle tecniche provengono da eventi server. Il danno da solo non equivale alla fine di un Clone; le distinzioni fra Clone di Sabbia solido e Moltiplicazione illusoria restano quelle ratificate.

Le risorse della prova sono stato simulato per **entrambi** gli attori. Leggere un profilo autorizzato per costruire il contesto non autorizza a scrivere PV, chakra, inventario, XP, valuta, grado o progressione nelle schede reali. Anche trigger, automazioni, premi, conteggi e consumer esterni devono riconoscere il perimetro. Un ripristino dei valori dopo la prova non dimostra isolamento.

Chiusura e recovery selezionano la sola prova nuova mediante identità esplicita, conservando profilo permanente, audit, messaggi e ricevute. Un richiamo successivo usa una nuova istanza e non eredita danni, effetti, posizione o stato della prova chiusa. Non cancellano lo storico e non selezionano «l'ultima scena del luogo». Il piano di recovery deve preservare compatibilità con snapshot e richieste in corso; deve dichiarare che non può annullare una chiamata HTTP già partita. Niente retry provider usato per cercare un esito favorevole.

## 6. Opzioni e criterio di scelta

| Opzione | Vantaggio | Esito proposto |
|---|---|---|
| Usare subito Master con PNG | Esistono costruttore canonico, attori e geometria nativi | Utile come fonte di componenti; apertura, valutazione e proiezione diverse non completano il collaudo ordinary richiesto |
| Estendere ordinary con binding PG/PNG e contesto Staff isolato | Percorre il consumer che deve essere verificato e prepara un contratto riutilizzabile dal multiattore | **Scelta raccomandata**, previa ricognizione delle dipendenze e isolamento della scena |
| Creare un secondo PG/account o forzare le FK | Ridurrebbe artificialmente il requisito a due schede | Esclusa dal mandato e dal modello di identità richiesto |

Il riuso del costruttore PNG Master può avvenire estraendo un componente privato comune, se necessario, con gli stessi validatori. Non si copia il motore in una variante di test. Un'eventuale estrazione deve preservare comportamento, ACL e chiamanti Master esistenti e includerli fra le verifiche di regressione pertinenti.

## 7. Lavori da assegnare e ordine delle dipendenze

I nomi seguenti sono deliverable proposti nel cantiere esistente, non file già creati. Il PM fissa lo scope esatto e il guard prima di ogni scrittura.

| Pacchetto | Owner / consumer | Fonti e output previsti | Dipendenza e risultato |
|---|---|---|---|
| Contratto e baseline mirata | DB-CORE + COMBAT-CORE, approvazione PM; NARRATIVE-AI e LAND-UI consultati | `STAFF_SYNTHETIC_CONTRACT.md`, `STAFF_SYNTHETIC_BASELINE.json`; routine di apertura, membership, identità, busy/luogo, offerte, controller, snapshot, policy e writer | Prima dei cambi condivisi: lista completa dei vincoli da aggiungere/modificare, permessi, isolamento della scena e piano di compatibilità |
| Adattamento nativo | Un owner DB-CORE sul pacchetto SQL, contributi COMBAT-CORE in copia | `STAFF_SYNTHETIC_INSTALL.sql`, `STAFF_SYNTHETIC_RECOVERY.sql`; primitive native PNG, binding ordinary, controllo e lifecycle | Contratto congelato; stessi esiti/formule e proiezioni, nessun fake PG o writer reale |
| Collegamento narrativo | NARRATIVE-AI, integratore DB per funzioni condivise | Contributi al pacchetto SQL e, solo se necessari, moduli Edge assegnati esplicitamente | Identità e fonti pronte; shape PG/PNG, provenienza e snapshot invariati nel significato |
| Controlli sul sito | LAND-UI, review DB/COMBAT | `STAFF_SYNTHETIC_LAND.html` come candidato; integrazione futura in `sito_live/land.html` dopo riconciliazione remota | Contratto RPC stabile; richiamo rapido del profilo permanente nella sola stanza Test autorizzata, selezione chiara del PNG e comandi autorizzati, nessun valore meccanico dal client |
| Banco e evidenze | QA-PLAYTEST, reviewer indipendente | `STAFF_SYNTHETIC_QA.py`, `STAFF_SYNTHETIC_QA_RESULT.json`, manifest e referto assegnati dal PM | Intera candidata end-to-end congelata; evidenze separate fra locale, servizi reali e sito |
| Rilascio e smoke | PM con owner DB, NARRATIVE e LAND | `STAFF_SYNTHETIC_RELEASE_PLAN.md`, aggiornamenti alle schede/HANDOFF esistenti | Review verde, recovery provato, preflight e gate nominativi; solo prova autorizzata con testperfunzioni |

Dopo il contratto, UI, mapping narrativo e preparazione del banco possono procedere in parallelo su file separati. Un integratore solo modifica SQL condiviso e uno solo integra `land.html`. Ogni consumer aspetta gli input dichiarati pronti; nessuna sovrascrittura di una candidata altrui.

Le sorgenti `NARRATIVE_TECH_*` e `PG_MOVEMENT_*` già qualificate non vengono riscritte come se appartenessero a questo piano. La nuova migrazione si basa sulle versioni effettive al momento del freeze, inclusi eventuali rilasci del movimento avvenuti nel frattempo. Drift o incompatibilità fermano l'integrazione dipendente, non autorizzano a ripristinare una vecchia funzione.

## 8. Criteri di accettazione e budget proposto

**Questo piano non ha eseguito prove e non apre una campagna.** Prima dell'esecuzione il PM e l'owner congelano vettori, copertura, conteggio delle invocazioni e budget della candidata. Proposta iniziale: dieci gruppi, massimo 24 invocazioni SQL complessive su PostgreSQL Docker, 45 minuti, zero provider e limite di 20.000 token per la campagna orchestrata. Il limite include preparazione, installazione, pre/postflight e recovery; eventuali connessioni concorrenti sono conteggiate. Se la matrice non è rappresentabile entro quel budget, la si dimensiona prima del freeze, non durante il banco.

1. **Apertura e identità:** un testperfunzioni autorizzato e un PNG nativo, senza seconda scheda; prova nuova riconoscibile e scena esistente invariata.
2. **Permessi:** comandi limitati a operatore, prova e attore; nessuna inclusione di Riuji, PG estranei o cataloghi Staff nella superficie utenti; consenso PG+PG legacy preservato.
3. **Azioni e difesa:** offerte e risoluzione native su entrambi gli attori; bersagli, controller e versioni verificati; nessun risultato imposto dal controller.
4. **Movimento e tecniche:** percorso spaziale e lifecycle corrente, offerte aggiornate e attribuzione corretta. Le fixture sintetiche eventualmente necessarie sono dichiarate e non vengono presentate come eventi spontanei del motore.
5. **Fonti narrative:** binding PG/PNG, role e tecniche coerenti; nessuna fonte attribuita a un PG assente; cataloghi trattati come dati; nessun segreto o informazione riservata aggiunta al payload.
6. **Isolamento:** nessuna scrittura a risorse, premi o progressione reali durante le operazioni e nel postflight; confronto delle superfici protette e dei writer pertinenti.
7. **Ripetizione e concorrenza:** idempotenza, versioni vecchie e controllo concorrente producono un solo effetto; la prova non intercetta la scena precedente o le sue richieste.
8. **Snapshot e replay:** fonti congelate, stessa autorità dell'esito e compatibilità dei payload esistenti; verifica strutturale senza giudice stilistico IA locale.
9. **Chiusura e riuso:** termina soltanto la prova creata, impedisce nuovi comandi sulla prova chiusa, conserva profilo permanente, storico e audit e non lascia lavoro pendente imprevisto. Un nuovo richiamo genera una nuova istanza isolata; il richiamo fuori dalle Test Room è rifiutato dal server.
10. **Installazione e recovery:** apply e recovery con COMMIT verificati da nuova connessione; corpi, ownership e ACL attesi; compatibilità legacy e dati di prova conservati. Nessuna fault injection in produzione.

La campagna raccoglie insieme gli esiti entro budget; revisione e correzioni seguono il metodo vigente e il conteggio assegnato a questa nuova candidata. I verdi precedenti non vengono rimessi in discussione per creare esempi aggiuntivi.

Docker dimostra i contratti rappresentati, non autentica utenti Supabase reali e non certifica RLS via API, Edge, Realtime o UI. Owner e reviewer valutano i rischi residui prima del rilascio. Se un rischio significativo non può essere dimostrato localmente né attraverso un collaudo live realmente isolato, il PM propone il solo ambiente temporaneo necessario con costo e termine espliciti; non usa la produzione per scoprire la sicurezza della migrazione.

Dopo i gate previsti: **una prova Staff controllata**, testperfunzioni più PNG, massimo una chiamata narrativa/provider senza retry, massimo dieci minuti e tetto richiesto di 12.000 token complessivi provider; consumi effettivi registrati quando disponibili. La scena contiene soltanto le azioni necessarie al singolo report previsto dal contratto congelato. Le chiamate preparatorie non devono generare IA implicita. Si confrontano pre/postflight, si conserva la ricevuta e si chiude esclusivamente la prova nuova.

Il login deve essere quello autorizzato per il collaudo; non si riusa una sessione Riuji per operare «come testperfunzioni». Se l'accesso o l'isolamento non sono disponibili, lo smoke resta non eseguito. Il verde locale non viene presentato come prova cinematografica o qualità live già osservata.

## 9. Perimetro di rilascio e decisioni

La porta del controller sintetico nasce riservata allo Staff. Le funzioni comuni continuano a servire entrambe le Test Room secondo i rispettivi permessi; questa estensione non trasferisce agli utenti il catalogo o il controllo Staff. Un'eventuale modalità PG+PNG accessibile agli utenti richiederà il proprio contratto di autorizzazione, senza duplicare il motore.

Sono già fissati: profilo PNG permanente e richiamo rapido soltanto nelle Test Room; nuova istanza e risorse separate per ogni prova; esclusione totale di Riuji; scena esistente intatta; testperfunzioni quale unico PG del primo collaudo; identità PNG nativa separata da `characters`; server autore di ogni fatto meccanico; risorse isolate; stesso percorso ordinary e provider del prodotto. Questi punti non richiedono una nuova domanda ad Antonello.

Restano decisioni tecniche dell'owner e del PM, da chiudere nel contratto prima di implementare: forma minima del binding PG/PNG, riuso o estrazione della factory canonica, isolamento nativo del contesto rispetto ai lock per luogo/PG e superficie minima del controller. Il criterio è ridurre i cambi condivisi mantenendo tutte le invarianti, non ridurre la qualifica ignorando dipendenze. Personalità autonoma, memoria narrativa fra prove (distinta dal profilo permanente), difficoltà adattiva e generalizzazione universale multiattore non fanno parte del primo incremento.

## 10. Consegna al PM

**TASK-ID:** PM-IA-PNG-PROGRESS-002, allineamento della ratifica permanente sul piano NARRATIVE-STAFF-SYNTHETIC-PLAN-001. **Scope toccato:** soltanto questo documento. **Contratti usati/modificati:** fonti locali e ricognizione già consegnata; nessun contratto applicativo modificato. **Decisione proposta:** PNG nativo con controller Staff e binding ordinary esplicito; componenti Master riutilizzati dove equivalenti, senza dichiarare equivalenza dei due percorsi. **OPEN:** scelte tecniche elencate nella sezione precedente. **Prove eseguite:** sola verifica documentale; zero SQL, provider e browser. **Rischio principale:** dipendenze ordinary su schede reali e selezione/occupazione per luogo, che impediscono di trattare il lavoro come semplice cambio di cardinalità. **Passaggio richiesto:** contratto STAFF_SYNTHETIC_CONTRACT e baseline consegnati con readiness OPEN; completare i metadati mancanti prima della candidata end-to-end; nessun intervento sulla scena esistente o su Riuji.
