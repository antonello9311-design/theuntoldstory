# QA proposto · handler Common e rollback, non ancora eseguito

Budget congelato: **un solo run,4gruppi,al massimo9sottocasi,9submission SQL complessive incluse creazione/setup,10min,0provider/browser**. Nessuna campagna viene eseguita dalla costruzione. Si raccolgono tutti i gruppi anche rossi entro budget, salvo errore di isolamento/sicurezza o mutazione fuori piano; nessuna patch, nuova fixture o retry durante il run. Review indipendente e assegnazione PM devono precedere preparazione esecutiva/apply.

## Banco e autorità delle prove

PostgreSQL reale nel contenitore QA già esistente indicato dal PM, nuovo database dedicato `combat_panel_rejection_reasons_001`, nessun reset o riuso dei banchi storici. Prima della futura esecuzione il runner deve verificare identità e configurazione del contenitore, disponibilità dei ruoli e assenza del DB; la presente costruzione non usa Docker. I pin del container, tempi e confini delle nove submission vanno fissati dal runner prima del suo freeze, senza aumentare il budget qui proposto.

Il soggetto delle prove è **il gateway AFTER completo e byteidentico**, installato e recuperato tramite gli script candidati completi. Usare DDL pertinente e corpi nativi già disponibili nei corpus/banchi Common (validate_command, auth.uid, funzioni/hash/shape necessarie); originali e pin devono essere verificati. Non inventare corpi per soddisfare un pin mancante. Le sei helper raccolte nella diagnosi e le fonti DISTANCE_*CASES del cantiere possono fornire materiale di preparazione, senza eseguire quelle vecchie campagne.

La sola frontiera verso un dispatcher di gioco può essere un **adattatore sintetico esplicitamente dichiarato nel banco**, capace di scrivere una riga sentinella locale e poi sollevare un'eccezione prefissata, oppure restituire una proiezione minima di successo. È una prova del rollback dell'handler PostgreSQL e della classificazione, non di Moltiplicazione, risorse, Auth, RLS o percorso RPC reale. Non chiamare il motore con dati dei PG. Non alterare il gateway, validate_command o combat_v2_fail per facilitare i casi. Eventuali corpi di supporto/test boundary differenti dai nativi devono essere elencati e non attestati come autenticazione o comportamento del server di gioco. Se il setup non riproduce fedelmente firme/DDL/pin del soggetto, segnalare NOT_RUN prima del run anziché ridurre le guardie.

## Matrice fissa

| Gruppo | Sottocasi massimi | Evidenza significativa |
|---|---:|---|
| G1 Installazione |1| PRE pin/ACL/schema, INSTALL COMMIT su connessione distinta, AFTER completo e ACL identici alle attese; nessuna nuova funzione/tabella/privilegio prodotto. |
| G2 Errori nativi e rollback |2| Comando malformato rifiutato da validate_command nativa prima del dispatch, shapeesatta6campi e messaggio semanticamente utile; separatamente dispatcher locale scrive sentinella poi solleva la causa prefissata formation_invalid22023: risposta selection_rejected, messaggio di numero/disposizione, **riga sentinella assente dopo il ritorno** e nessuna receipt aggiunta dalla richiesta. Non basta confrontare stringhe del dizionario. |
| G3 Priorità e riservatezza |4| Errore22 sconosciuto con marcatore privato sintetico/suffisso di nome noto: fallback generico e marcatore assente in tutta la risposta; nome noto maSQLSTATE40001: classificazione/messaggio context_changed originali; combat_v2_fail nativa con codice ammesso dal corpus: PGRST resta operation_rejected e nessun message_it/details_sanitized viene copiato; panel_request_key_conflict22023 mantiene priorità/request_key_conflict/recoverycontact_staff. Nessuna stringa reale privata nella fixture. |
| G4 Successo e recovery |2| Successo/replay del percorso di frontiera conserva il risultato e la richiesta con un unico effetto sentinella; RECOVERY COMMIT da altra connessione ripristina corpo/ACL BEFORE esatti e il messaggio generico precedente, preservando dati/receipt di prova già presenti. |

Le etichette delle cause sono selezionate per coprire autorità, rollback, priorità e riservatezza, non per attribuire011 o controllare quaranta uguaglianze causa→frase. La mappa completa è verificata staticamente dal builder attraverso sorgenti autentiche; non si aggiungono casi per ciascuna voce o sinonimi di una fixture.

## Nove submission complessive

1. Preflight cluster/ruoli/assenza DB e unica creazione DB dedicato, senza modificare altri database o ruoli globali.
2. Bootstrap DDL/corpi/fixture di componente e baseline prima;0righe reali, frontiere simulate dichiarate.
3. INSTALL completo COMMIT e postpin del G1.
4. G2 aggregato: errore del validatore reale e rollback di scrittura sentinella dopo eccezione del dispatcher.
5. G3 aggregato: quattro sottocasi con risultati raccolti senza allargare la matrice.
6. Successo e replay del G4, confronto effetto singolo e ricevuta.
7. Snapshot dati/ACL/corpi prima recovery, nessuna pulizia.
8. RECOVERY completo COMMIT.
9. Postflight: corpo/ACL originali, messaggio precedente e conservazione delle righe sentinella/receipt già concluse; nessuna cancellazione del banco.

Timeout globale10min; deadline residua e limiti psql/server devono essere definiti nel runner prima del freeze. Il preflight fallito non autorizza riconfigurazione del container. Le nove submission sono un massimo, non un obiettivo da raggiungere con retry. Fonte/context/SQL/fixture congelati prima dell'unica esecuzione; risultato e contatori effettivi sono consegnati anche se rossi.

## Gate e limiti

Nessuna prova qui certifica Auth/API/RLS/Edge, concorrenza di gioco, geometria, consumo chakra, causa011 o narrazione. La modifica non introduce dipendenze da provider. L'integrazione del messaggio nel renderer usa il contratto già esistente, ma lo smoke live dopo rilascio resta distinto e richiede l'incarico PM protetto. Recovery e preflight di produzione devono mantenere gli stessi pin ed esclusiva, senza riscrivere dati per ottenere quiete o verde. Nessun apply, deploy, caricamento o apertura generale deriva da questo piano.
