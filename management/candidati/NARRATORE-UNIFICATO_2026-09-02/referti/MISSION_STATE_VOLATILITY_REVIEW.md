# MISSION-EXAM-STATE-VOLATILITY-001 — review indipendente

**VERDE tecnico, 0 P0 / 0 P1 / 0 P2.** Unico passaggio circoscritto al blocco reale del pannello. Nessun finding, correzione o nuovo caso richiesti. Nessun test aggiuntivo, SQL eseguito, provider o mutazione di produzione da parte del reviewer.

## Perimetro e impronte

Letti contratto, SQL, tre gruppi congelati, manifest e QA. Byte e SHA verificati **3/3**: SQL 234 byte `e562a066bc5b52614bf556fbe06becdb7a0e7cd40324941384d6b63111a7dbba`; test `152caa42281678af0eba8b912d8e3c7d11d3f7e7b09735dab80c0d3822b4139a`; contratto `ac9479c4eddb025c7d5da4a80a325221d06472a7d74b1b6da9f46af7d1da4f48`.

Tracciata in lettura la baseline congelata: esame_prova_stato controlla autenticazione e proprietario/staff e chiama _esame_stato_json; quest'ultima ottiene le opzioni del candidato, che richiamano la preparazione comune della Sostituzione. Il percorso include _esame_spatial_prepare_v1, exam_substitution_source_open_v1 ed exam_substitution_options_v1. La porta non rappresenta quindi una lettura priva di effetti di servizio.

## Esito del delta

ALTER FUNCTION modifica soltanto la volatilità della RPC pubblica da STABLE a VOLATILE. Il corpo, la firma, SECURITY DEFINER, owner, search_path e ACL non vengono sostituiti. I controlli di autenticazione e autorizzazione esistenti restano nella stessa funzione; nessun helper viene reso accessibile al browser. La notifica pgrst richiede la ricarica dello schema per il metadato aggiornato.

La modifica è coerente con il POST ordinario del client e con la necessità della catena di preparare le offerte tramite scritture server già previste. Non aggiunge scritture applicative, azioni di combattimento, provider o nuove regole. L'eventuale GET non è il percorso supportato per questa RPC scrivibile, come dichiarato dal contratto. La classificazione aggiornata è il solo cambiamento operativo, senza alterazioni ai dati storici.

## QA e riscontro necessario

QA owner **3/3 PASS** su PostgreSQL 17.6 locale reale: transazione READ ONLY riproduce 25006; transazione scrivibile dopo il cambio restituisce lo stato e conserva l'impronta della scheda; autenticazione assente respinta e corpo MD5 `a2f88dc113ee44b9078e09a580153bce`/ACL invariati. Il banco chiude la fixture attraverso esame_session_close. Dati e identità sono sintetici; il reviewer non ha rieseguito le prove.

Il verde riguarda la candidata minima, non il comportamento già corretto del sito. Dopo il singolo apply autorizzato occorrono controllo dei metadati e normale rilettura del pannello dall'identità Tamako già autenticata, senza inviare una difesa: il QA SQL locale non sostituisce il riscontro PostgREST reale. Nessuna riapertura delle candidate di proiezione Assalto e cattura della zona, che restano distinte e inerti.
