# CLAN-RECOVERY-WINDOW-001 · controverifica finale

**Verdetto definitivo P0/P1/P2: 0/0/0. RW-01 risolto. Esito positivo per il solo lettore privato della finestra temporale e la sua matrice locale concordata.** Non qualifica il recupero pubblico, la Colonia o una tecnica live e non autorizza la distribuzione isolata dell'helper.

Reviewer `/root/review_staff94`, 09/09/2026. Unica controverifica statica finale dopo l'unica aggregata. Nessuna SQL, provider, UI, nuova proposta o nuovo esempio. Unico file scritto: questo referto. Ciclo terminale.

## Integrità e delta

Verificati i sei file del manifesto finale, dimensioni e SHA-256, senza drift prima della consegna. Il manifesto `RECOVERY_WINDOW_FINAL_SCOPE.json` ha SHA `94372dbffb9722266d6ef30f98687596a5ecbae5eaae438d6366faf5905c85b0`.

Confrontata la fixture finale con `_precedenti/2026-09-09_recovery_window_initial/QA_RECOVERY_WINDOW.sql`, il cui SHA coincide con il sigillo iniziale. L'unica differenza è `QA_RECOVERY_WINDOW.sql:77`: viene creato prima lo scontro chiuso, poi quello aperto. Parametri, helper, guardie e asserzioni sono identici. Il lettore viene ora raggiunto senza rimuovere la guardia `personaggio_impegnato`.

Il codice applicativo è invariato: `02_RECOVERY_WINDOW.sql` mantiene SHA `93c08770cbae95b5814cc70469f1e9917297955ce38a0cfd4953f1057ffdc285`; anche il modulo 01 conserva il sigillo iniziale. La fixture finale ha SHA `aea35b728495de3b5bf6b5260a4487e779f6995cbc77f68f7867244a422bb31f`.

## Evidenze e chiusura del finding

`QA_RECOVERY_WINDOW_FINAL_RESULT.json`, SHA `8a892cd18c1578bee664cd4389906564609571ed4df7cff7e20645194055b2bb`, registra gli stessi otto gruppi W01–W08 tutti PASS, tre submission SQL, 0,217 secondi, zero provider e nessun errore. Verificata la coerenza tra stdout e matrice strutturata, e l'uguaglianza dei valori pre/post: hash PG/funzioni, conteggi sessioni e assenza dello schema candidato dopo rollback.

W05 raggiunge quindi le asserzioni originarie: stanza protetta esclusa dall'impegno e dal conteggio, `eligible=true`, zero secondi di combattimento e 86.400 di riposo nella finestra sintetica. **RW-01 è chiuso, senza residui P0/P1/P2.** Non ho rieseguito la campagna.

## Limiti confermati

Rimangono quelli della prima review: fixture locali sintetiche del lettore, nessuna certificazione di creazione nativa delle scene, Auth, storico reale, authority dei timestamp lifecycle o runtime live. Il ramo di preparazione resta verificato staticamente nei limiti dichiarati. Il risultato non attesta atomicità futura di lock, risorse, ledger, timestamp e ricevuta, né lo split nel recupero pubblico; tali raccordi restano fuori dal perimetro.

La disponibilità del prerequisito verificato non equivale alla disponibilità della tecnica. La review si chiude con questo verdetto e torna all'owner/PM, senza altri interventi nello stesso ciclo.
