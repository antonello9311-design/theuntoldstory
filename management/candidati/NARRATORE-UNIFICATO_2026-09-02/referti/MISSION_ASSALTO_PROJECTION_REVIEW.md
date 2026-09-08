# MISSION-EXAM-ASSALTO-PROJECTION-001 — review indipendente

**VERDE tecnico, 0 P0 / 0 P1 / 0 P2.** Unico passaggio aggregato dell'08/09/2026; nessun finding, correzione o nuovo caso richiesti. Nessuna esecuzione di test, chiamata provider, mutazione locale o produzione da parte del reviewer.

## Perimetro e pin

Letti contratto, candidata SQL, quattro gruppi congelati, manifest e QA. Verificati in lettura byte/SHA **3/3**: SQL 1953 byte `47a93c7d879d1994faf83f02af83da980d9da00a2fa0a4c23cacef862e6383ca`; test `1b0a6f211f7d4fc090e1c4573a11f0417d75c9be8faf8a9d18b46a3efe64cb38`; contratto `41503f05d9c2f129fdfd1c39b2b122e89c8df66a3b2342bbb5e9ae030c234015`.

Confrontato il corpo con il helper della baseline sintetica e tracciata la costruzione del referto Assalto in `candidato/test/tamako-qa-bootstrap.sql`: il ramo Assalto assegna copia_colpita/originale_individuato all'esito dell'inganno, mentre il referto preesistente usa impropriamente «una copia del difensore» per copia_colpita. Non letti testi delle role reali o dati dei personaggi. Il fatto live e l'impronta prosrc di produzione sono evidenze riferite dall'owner, non una nuova verifica del database del reviewer.

## Semantica e regressioni

Il nuovo ramo si attiva soltanto per il nome esatto della tecnica Assalto, i due esiti dell'inganno e identità presenti. Distingue il difensore destinatario del colpo reale, il proprietario delle figure (attaccante) e la figura verso cui è diretta la difesa. La correzione non interpreta il testo della role e non cambia chi infligge o riceve danni nel motore. `bersaglio_su` identifica il destinatario del tentativo/colpo: non certifica da solo che il colpo sia riuscito; colpito, danno e le altre conseguenze rimangono separati e invariati.

Il ramo ordinario per tecniche diverse dall'Assalto, inclusa difesa tramite copie, resta quello preesistente. In assenza delle identità richieste non viene inventato un proprietario. Il passaggio ricorsivo e la rimozione preesistente di appendici, numeri e stringhe contenenti cifre rimangono uguali; non è aggiunto un nuovo filtro narrativo. I tre campi proiettati risultano stabili a una seconda proiezione.

Firma, linguaggio SQL, IMMUTABLE e search_path restano invariati. CREATE OR REPLACE conserva l'owner esistente; revoche a PUBLIC/anon/authenticated e GRANT a postgres/service_role mantengono il perimetro dichiarato, da confrontare con la baseline effettiva nel preflight operativo. Non vengono creati vincoli o funzioni ulteriori. La funzione restituisce JSON e non contiene scritture di stato, scambi, messaggi o personaggi.

## QA e limiti

L'owner attesta quattro gruppi locali reali **4/4 PASS**, 2,195 / 0,605 / 5,287 / 1,680 ms, con ROLLBACK, nel database esclusivo tus_night_projection_001. Il test letto copre entrambi gli esiti Assalto, ramo ordinario copie, ricorsione/filtri/idempotenza, identità insufficienti/null e ACL/volatilità. Il terminatore SQL mancante è stato corretto nella preparazione prima del banco, senza cambio logico. Il reviewer non ha ripetuto o ampliato le prove.

Il verde tecnico non certifica prosa, provider o risoluzione del separato conflitto di zona volto/gamba. Nessun record storico viene riscritto; soltanto future letture attraverso la proiezione applicano l'identità corretta. Applicazione di produzione e campioni provider restano subordinati al gate nominativo e alla sequenza baseline/conferma stabilita dall'owner/PM; questa review non li esegue né li anticipa.
