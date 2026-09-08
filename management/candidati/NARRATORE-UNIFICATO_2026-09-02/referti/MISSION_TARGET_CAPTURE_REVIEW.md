# MISSION-EXAM-TARGET-CAPTURE-001 — review indipendente

**VERDE tecnico, 0 P0 / 0 P1 / 0 P2.** Unico passaggio aggregato dell'08/09/2026. Nessun finding, correzione o nuovo esempio richiesti. Nessun test aggiuntivo, SQL eseguito, provider, apply o modifica ai file dell'owner da parte del reviewer.

## Pin e delta

Letti contratto, SQL, quattro gruppi congelati, manifest e QA. Impronte e byte verificati **3/3**: SQL 3587 byte `753af90a9a4ccd85582a7b215bf1c9dfedd35e7ccdb2e761b1f3c52968576933`; test `de3926e9f6b335cc201c293b5e48f615cc7fd4e118fbef320b594642a2e9574f`; contratto `19d7bb5f34f207779c32f493daa4db4a03a9d7a0a9b13f4075e4be568eab313c`.

Ricostruita in lettura l'impronta del corpo SQL rimuovendo i soli due caratteri aggiunti: MD5 `95b3a01f7efecc82516550200dedfa63`, corrispondente alla baseline dichiarata. Nessuna interrogazione di produzione eseguita dal reviewer.

## Semantica e regressioni

Il pattern completo racchiude v_mir in una cattura esterna destinata a m[1] e la zona in quella destinata a m[2]. Il gruppo interno preesistente in v_mir introduceva una cattura ulteriore: m[2] rappresentava nuovamente il prefisso, non la zona. Renderlo non catturante riallinea gli indici alla concatenazione che il codice usa per localizzare prefisso e zona. Si corregge il meccanismo generale di cattura, senza aggiungere parole o adattamenti al singolo testo.

Il resto del corpo è identico: dizionario, ordine dei rami e preferenze, classificazione delle zone, lateralità, RNG e comportamento in assenza di zona non vengono riscritti. La zona restituita può cambiare per dichiarazioni prima interpretate erroneamente; è l'effetto funzionale richiesto. La funzione resta un parser euristico e non attribuisce semanticamente ogni colpo a originale o copie. Non ricostruisce né corregge scambi già risolti.

Firma, linguaggio, search_path e IMMUTABLE sono preservati; CREATE OR REPLACE mantiene l'owner esistente. Le revoche a PUBLIC/anon/authenticated e i GRANT a postgres/service_role conservano il perimetro dichiarato, da riconciliare nel preflight operativo. Nessuna nuova funzione o vincolo. Il codice non aggiorna personaggi, referti, danni o tiri. La precedente candidata sulla proiezione delle copie resta distinta e non viene modificata da questa review.

## Evidenze e limiti

QA owner su PostgreSQL locale reale esclusivo tus_night_projection_001: i due input sintetici previsti dal gruppo 1 espongono l'errore della baseline; prima matrice candidata **4/4 PASS**, 6,095 / 0,513 / 0,591 / 0,742 ms, con ROLLBACK. Il test letto copre mira successiva a menzione possessiva, bersaglio unico/lateralità, fallback/null e ACL/volatilità/delta esatto. Nessuna role completa o dato PG importato nel banco. Il reviewer non ha rieseguito o ampliato i quattro gruppi.

Il verde attesta la correzione circoscritta e la coerenza con il contratto; non certifica comprensione generale delle role, qualità del Narratore o nuova narrazione dei dati storici. Applicazione nell'aggregata futura solo dopo baseline e gate nominativo, prima dei campioni di conferma secondo la sequenza stabilita. Nessun campione provider eseguito o autorizzato implicitamente da questo referto.
