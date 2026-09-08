# MISSION-EXAM-EDITORIAL-REBUILD-001 — QA
08/09/2026. Budget4gruppi PostgreSQL,3gruppi Node,0provider,0Esami live.

PostgreSQL17.6 reale nel container locale esistente, database dedicato tus_exam_editorial_rebuild_001 copiato da tus_night_projection_001. Schema baseline; sole sei persona narrative reali, profili statistici sintetici e nessun dato/Auth del giocatore. Non è una prova di runtimeAuth.
- QA01 PASS: sei persona after esatte, tutte le altre colonne ai_agents e tutti i profili invariati.
- QA02 PASS: secondo apply inerte, nessuna modifica.
- QA03 PASS: drift nell'ultimo ID intercettato, annullate anche le modifiche precedenti nella stessa chiamata.
- QA04 PASS: binding profilo errato intercettato, nessuna mutazione parziale.
Transazione finale ROLLBACK; nessun DELETE.

Node3/3PASS,19moduli sintatticamente validi: differenze di codice limitate ai prompt e ai loro identificatori; contesto ricevuto integro; budget10000/high invariato; struttura JSON e autorità server/claim preservate; testo sotto1000 non bloccato; porte ritirate410senza servizi. Circa390ms nell'ultima esecuzione.

Incidenti di preparazione risolti prima del verdetto: profili sintetici inizialmente con somma80, rifiutati dal CHECK140; corretti a140senza allentare vincoli. Nel confezionamento dell'unica aggregata il cambio appellativo aveva modificato una baselineJSON: il QA ha rilevato il drift, ripristinata la baseline dall'archivio, verificati integralmente SQL/JSON/before/after e rieseguiti gli stessi4gruppi, tutti verdi. Nessun effetto produzione in entrambi i casi.

Limite: questi controlli attestano integrità della modifica, non il miglioramento già dimostrato di una nuova prosa. Nessuna chiamata al modello è stata eseguita.

