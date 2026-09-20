# MISSION-RAPID-TECHNICAL-ACTOR-REVIEW-054 · review indipendente alias attore tecnico

Esito: **VERDE — P0/P1/P2 = 0/0/0**.

Review eseguita sugli input registrati, senza DB, browser, provider, apply o deploy. I pin live sono confrontati con le evidenze readonly documentate.

## Delta e semantica

- Il corpo corrente di `mission_rapid_owner.technical_document` contiene esattamente sei accessi `q.editorial_actor->` e un solo alias laterale `q(editorial_actor) on true`; l'alias precedente `q(actor)` è assente (`db/INSTALL.sql:533-539`).
- I sei accessi conservano gli stessi campi editoriali: `role`, `behavior`, `private_knowledge`, `limits`, `identity` e `personality`. Cambia soltanto la qualificazione del valore JSON restituito dalla laterale; aggregazione, ordinamento, join per `actor_key` e documento prodotto restano invariati.
- Qualificare sia la relazione `q` sia la colonna `editorial_actor` elimina l'ambiguità con la variabile PL/pgSQL `actor` dichiarata dalla funzione (`db/INSTALL.sql:514-520`) senza ampliare il perimetro della query.

## Pin, apply e recovery

- Il corpo corrente produce esattamente MD5 `6ff11ad4312d7acf2f89f7f3498e47fc`. Invertendo soltanto i sei token e l'unico alias si ricostruisce esattamente la baseline `bb89a4e690197e5103a19002896779e9`.
- Il fix accetta soltanto `bb89a4e…`, verifica sei token e un alias, applica le due sostituzioni e controlla il risultato `6ff11ad…`; il replay è ammesso solo sul nuovo MD5 (`db/TECHNICAL_ACTOR_ALIAS_FIX.sql:13-28`).
- La recovery è l'inverso esatto: richiede `6ff11ad…`, sei token nuovi e un alias nuovo, ripristina le forme precedenti e verifica `bb89a4e…`; il replay è ammesso soltanto sulla baseline (`db/TECHNICAL_ACTOR_ALIAS_RECOVERY.sql:13-28`).
- Entrambi i file usano una sola transazione, non contengono `DELETE`, `DROP` o `TRUNCATE` e falliscono prima dell'`EXECUTE` in presenza di drift.

## Invarianti e prove

- Il pin `preview_for` resta `c988923b347cc600b85bb215ea025663`, verificato sia nel corpo di `INSTALL.sql` sia nelle dipendenze di fix/recovery (`db/TECHNICAL_ACTOR_ALIAS_FIX.sql:20-23`; recovery alle stesse righe).
- «Adatta missioni» è invariata: il delta ricrea soltanto `technical_document`; pin `progress_step`, guardia `unified_batches` e hook rapido conservano le occorrenze previste. Il test contrattuale 22 resta verde.
- Il test 26 verifica i sei accessi qualificati, l'alias nuovo e l'assenza di quello precedente (`qa/CONTRACT.test.mjs:134-138`).
- Suite pertinente: **26/26 PASS**.
- Manifest: **20/20 PASS**. `INSTALL.sql`, fix, recovery e suite di contratto sono pinndati alle impronte correnti (`MANIFEST.json:20,24-25,34`), con conteggio contratto coerente 26/26 (`MANIFEST.json:36`).

Nessun finding. Il referto non autorizza operazioni live.
