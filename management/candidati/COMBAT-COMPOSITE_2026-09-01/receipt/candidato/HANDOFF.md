TASK-ID: `P1-C-COMBAT-EXAM-SPATIAL-RECEIPT-001`

Scope toccato: solo `receipt/candidato/` del cantiere COMBAT-COMPOSITE; contratto offline della ricevuta spaziale point-of-view per Esame/Combat. Nessun file condiviso, dossier, database, Edge, UI, regola o LIVE modificato.

Contratti usati/modificati: usa `generic_sostituzione_spatial_v1`, il lifecycle `portable_single_use → consumed_non_substitutable`, range server `3/5/10/15`, cooldown `R1→R4` e l'identità condivisa proposta `combat_exam_exchange_identity_v1`. Introduce soltanto la proiezione `combat_exam_narrative_spatial_receipt_v1`.

Decisioni prese / OPEN: coordinate, footprint, segmenti e UUID restano audit-only; il Narratore riceve timeline semantica before/impact/anchor/after, distanze viewer-specific con fascia coerente, source/traiettoria/anatomia/bersaglio tipizzati, iniziativa server e contrattacco `pending_unresolved`. OPEN prodotto0 nel verticale. L'esatto freeze condiviso dei nomi con P1-A/P1-B e il branch integrato restano gate esterni.

Prove eseguite e risultato: validator statico su schema, esempio sanitizzato, anti-leakage, fascia e 32 banchi continui/unici: GREEN. P0=0, P1=0, P2=0 sul contratto statico; provider0, mutazioni0. Il branch QA condiviso è stale/unhealthy e blocca correttamente il gate integrato: non è stato usato né aggirato.

Rischi o regressioni da verificare: contaminazione fra viewer, esposizione di UUID/coordinate, fascia non derivata dallo stesso snapshot, anatomia o bersaglio inferiti dalla prosa, contrattacco pending narrato come risolto, identità di scambio divergente fra resolver/adapter/receipt.

Passaggio richiesto al PM: congelare i nomi condivisi con P1-A/P1-B, integrare sulla stessa revisione, eseguire l'intera matrice su branch Supabase QA healthy/allineato e sottoporre una sola review indipendente. Nessun apply/deploy/enable/smoke è autorizzato.
