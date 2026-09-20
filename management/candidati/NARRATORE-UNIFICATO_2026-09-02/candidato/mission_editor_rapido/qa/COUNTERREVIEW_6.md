# MISSION-RAPID-COUNTERREVIEW-032 · sesta controreview indipendente

Esito: **VERDE — P0/P1/P2 = 0/0/0**.

Controreview eccezionale della candidata congelata `mission-rapid-editor/2026-09-19.review10`, eseguita in sola lettura. Nessun Docker, browser, provider, DB, Edge o altra mutazione live.

## Delta review10

- Il preflight conserva il pin esatto della baseline viva `0bc40e0ff963c26a63e218f2aa95dd94` (`db/INSTALL.sql:9-14`) e salva la definizione originale prima dell'innesto (`db/INSTALL.sql:21-29`).
- L'anchor di installazione comprende integralmente la guardia corrente su `mission_run_outbox`, l'esclusione del batch `unified_batches.state='preparing'`, gli alias `uo`/`ub` e il legame `ub.route->>'event_id'=uo.event_id::text` (`db/INSTALL.sql:987-997`). La simulazione locale sulla sorgente integrata e il confronto con l'evidenza readonly attestata coincidono: `old_count=1`, `new_count_before=0`, `new_count_after=1`, `adds_single_hook=1`, `preserves_unified_batch_guard=true`.
- L'hook resta dopo il ritorno `narration_pending`; quindi non anticipa né aggira il batch unificato in preparazione. La candidata rifiuta sia MD5 diverso sia anchor non univoco.
- La recovery usa gli stessi frammenti old/new, ricostruisce la sola definizione attesa, rifiuta qualsiasi drift e ripristina la baseline salvata (`db/RECOVERY.sql:13-30`); il postflight verifica anche il relativo MD5 (`db/RECOVERY.sql:66-76`).

## Regressioni e invarianti ricontrollate

- Non-interferenza Mission Generic/«Adatta»: `try_native_terminal` restituisce `null` per una missione senza regole rapide attive prima di leggere run, incontro, round o stato spaziale (`db/INSTALL.sql:725-735`). La guardia `unified_batches` della baseline resta byte-identica dentro il frammento sostituito.
- Autorità e idempotenza terminale: helper privato, endpoint JSON sempre negato, lock della sessione, fatti derivati da Combat/spaziale, chiusura tramite porta Generic, transizione tramite `apply_authority` e ricevuta persistita; i grant pubblici/service non espongono l'helper (`db/INSTALL.sql:686-957`).
- Pubblicazione: staff-only, fingerprint e advisory lock sulla request, replay dello stesso risultato, controllo versione/seal/basis, nuovo preflight, creazione/versione, regole, recovery receipt e apertura board nella stessa transazione (`db/INSTALL.sql:646-685`).
- Restano chiusi tutti i finding precedenti: confronti PostgreSQL `IS DISTINCT FROM (CASE ... END)`, soglie matematicamente intere (`db/INSTALL.sql:267-293`), una sola regola nativa non standard per fase, mappa viva/spec/capienza, CORS, source/asset UI identici, e attori di scena/incontro JSON-identici con alleati/civili su `squadra` e almeno un avversario (`db/INSTALL.sql:528-593`).
- `INSTALL.sql` e `RECOVERY.sql` hanno una transazione ciascuno, dollar tag bilanciati e nessun `DELETE`, `DROP` o `TRUNCATE`. I dieci moduli JavaScript verificabili passano `node --check`.

## Prove

- Suite pure: **154/154 PASS** — compilatore 35/35, UI 51/51, media 18/18, integrazione Admin 28/28, contratto 22/22.
- Integrità: **17/17 PASS** — 16 artefatti dichiarati in `MANIFEST.json:14-30` più SHA-256 della baseline `sito_live/admin.html` (`MANIFEST.json:5-6`).
- JSON: **9/9 validi** nel perimetro candidato; sorgente UI e asset deploy byte-identici.
- Il test di contratto 22 fissa guardia completa, posizione dell'hook e pin (`qa/CONTRACT.test.mjs:112-119`); i test 7-9 coprono manifest, hash e import transitivi (`qa/CONTRACT.test.mjs:36-56`).

Gate statico superato. Il referto non autorizza autonomamente apply, deploy, enable o apertura: resta necessario il checkpoint readonly previsto e il successivo rilascio riservato secondo il mandato PM.
