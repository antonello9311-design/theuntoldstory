# AREA · Piattaforma — database, migrazioni, cron, Edge, cartella di lavoro — scheda viva
Riscritta il 04/09/2026 · da Codex (`NARRATORE-UNIFICATO-SMOKE-CLOSE-4.6.6`) · **stato dell'area: produzione Edge v125/4.6.1; branch QA v125/4.6.6 inerte; gate rosso**

## Fonti fondamentali — in quest'ordine, solo il blocco che serve
1. Skill `gdr-sql` (GRANT esplicito, CHECK, dollar-quoting, prova in transazione, piano prima dell'apply) e `gdr-verifica` (le cinque interrogazioni che fotografano il DB).
2. Il database stesso: `supabase_migrations.schema_migrations` (registro), `cron.job` + `cron.job_run_details`, `list_edge_functions`, `get_advisors`. Il DB vince su ogni documento.
3. `supabase/migrations/` (copie locali, non il registro) e `supabase/functions/` (solo `exam_genin_ai`: le altre Edge hanno il sorgente nei candidati).
4. `management/coordination/RETIRED_CANDIDATES.json` e `management/tooling/` (`manifest_guard` 1.0.0, `pg16.sh` replica locale, `banco_067.sh`).
5. `dossier/05_CONVENZIONI.md` §3 (colonne nuove, `uso`/`difensiva`/`di_scena`, `messages.kind`) — dove `gdr-contesto` è arretrata.
6. Memoria di progetto: `sql_una_sola_chiamata`, `registrazione_migrazione_manuale`, `guardia_nome_migrazione`, `sigillo_trasporto_sql`, `replica_locale_motore`, `dossier_task_dedicato`, `collisione_068_due_sessioni`.

## Stato vivo — baseline backend osservata dal PM il 03/09/2026; Edge riconfermata da Antonello/Claude
- **Branch QA `qa-exchange-monthly-2026-08-31`**, ref `yvqeiorqrdlhuzxkssjg`: Edge `exam_genin_ai` **v125**, `ACTIVE`, bundle SHA-256 `a1e6d128257b8ad63ea6c795f518cf8dd5f94d39f230462bd7c01ea54be8c3e6`, sorgente 9/9 byte-exact alla candidata 4.6.6. Review `0/0/0`; ultimo A–G 15/18 per tre `max_tokens`. Postflight: 0 prove aperte, 0 cicli non terminali; token runtime ruotato server-side.
- **Preflight QA due esami (04/09)**: branch verificato in sola lettura con 0 prove aperte e 0 cicli non terminali. Il corpus contiene una prova sintetica con 18 snapshot, ma soltanto un ciclo per ciascuno dei due esami scelti; nessuna scrittura o chiamata modello eseguita. Produzione letta soltanto per selezione e sigilli, invariata.
- **Produzione**: head DB resta `20260903203601 esame_narratore_finale_ampiezza_006_recovery`; nessuna migrazione nuova. Edge `exam_genin_ai` osservata il 04/09 **v125**, candidata 4.6.1/prompt29, `verify_jwt=false`. Lo smoke reale ha aperto la prova ma è caduto in ripiego al secondo ciclo per alias nominativo; prova/sessione poi chiuse senza pending. Nessun redeploy 4.6.6 autorizzato.
- `public`: **230 tabelle** (93 con zero righe: `training` 24, `nb` 23, `mission` 18, `combat` 8, `master` 5, `character` 3, altre 12) · **732 funzioni** al 03/09/2026; il precedente totale 705 è superato dalla fotografia autenticata corrente.
- Sicurezza: SECDEF senza `search_path` **0** (il «38» del 29/08 è chiuso) · SECDEF eseguibili da `anon` **15** (da ratificare) · `pg_net` nello schema `public` (da ratificare) · i ~139 warning advisor su SECURITY DEFINER sono l'architettura.
- **Edge produzione**: censimento completo precedente conservato; in questo task è stata riconciliata soltanto `exam_genin_ai` **v123**, contenuto recovery `4.1.0-NU001`/prompt21. Nessun'altra Edge è stata modificata o ricensita.
- **Cron (13)**: `academy-tick` 1′ · `esame-tick` 1′ (riacceso 01/09 21:56) · `combat-narratore` 1′ · `role-expire-unsaved-2h` 1′ · `exam-surface-qa-worker-131q` 1′ · `academy-audit-observability-reconcile` 5′ · `esame-monitor-10m` · `combat-silenzio` 10′ · `role-maintenance-hourly` :07 · `test-room-cleanup` :23 · `test-room-user-cleanup` :41 · `academy-audit-weekly` lun 04:00 · `pilot-scadenza` **OFF** (dichiarato).
- Utenza: ultimo conteggio profili 78; **76 personaggi** alla lettura in sola lettura del 03/09.
- Cartella di lavoro: `management/` 474 MB — 1.082 cartelle in `candidati/` (172 nate il 01/09), 537 in `review/`, 419 handoff; `_to_delete/` 120 MB (66 archivi C, programma 096).

## Lavori aperti — in ordine
1. **[P1] Fix REC Esame proposto**: `EXAM-REC-OPEN-001` innesta la porta server esistente in `esame_prova_apri(uuid)` prima dell'incipit, senza firme o ACL nuove. Attende approvazione; nessuna migrazione scritta o applicata.
2. **[P1] Regola d'ingresso**: al massimo **tre cantieri «in lavoro»**; nessuna fondazione nuova (tabelle, RPC, Edge) finché non atterra uno fra Missioni IA, Training, Clan. Chi la dichiara: Antonello; chi la fa rispettare: il PM nel tabellone.
3. **[P1] Ratificare i 15 SECDEF eseguibili da `anon`** e `pg_net` in `public` — una review di venti minuti, con l'elenco a database.
4. **[P2] Mappa delle 93 tabelle vuote → cantiere di appartenenza** (già per prefisso qui sopra): serve per sapere cosa archiviare quando un cantiere viene parcheggiato.
5. **[P2] Riallineare `gdr-contesto`** (skill): 732 funzioni, 15 Edge, 13 cron, changelog 73, colonne `uso`/`difensiva`/`di_scena`, «Lumache solo medici» falso, `seconda_natura` gratuita al Jonin. Si consegna come scheda di revisione; la salva Antonello.
6. **[P2] Registrare nel tabellone ogni cron/flag/gate spento o acceso** (lezione del 30/08).
7. **[P3] FK senza indice** segnalati INFO nelle fondazioni Ninja Book / Surface (4+7+5): dopo il traffico reale, non prima.
8. **[P3] `_to_delete/`**: 66 archivi C al programma 096; il resto è già nel Cestino dal 23/08.

## Parcheggiato — non riaprire senza mandato
- Protezione password compromesse di Supabase: **spenta per scelta** (piano gratuito). §7 di `migration_coerenza.sql`: **annullata il 28/07, non rieseguire**. L'account `Riuji` non si tocca.
- Refactor degli helper condivisi fra pagine: decisione aperta nel piano di leggibilità, non è di quest'area.

## Decisioni chiuse — non ridiscutere
- 03/09: flusso permanente **locale → branch Supabase → produzione**. Locale solo per unit/statiche/fault injection; branch QA healthy e allineato obbligatorio per migrazioni, integrazione, rollback/recovery, race e advisor; produzione mai banco di prova, neppure con `ROLLBACK`. Se il branch non è verde si ferma il gate, senza fallback mutante sulla produzione. Il branch si usa da sessione/workdir isolati e non si altera il link CLI principale.
- Ogni funzione nuova nasce **invisibile al client** finché non ha il GRANT esplicito; ogni chiamata SQL è una transazione a sé; il rollback si aggancia al nome **registrato** della migrazione, per uguaglianza esatta.
- Le verifiche confrontano impronte salvate col dato, non contano righe; le ancore sui totali vivi invecchiano mentre qualcuno gioca.
- Per disattivare: `is_active=false`, mai `DELETE` (unica deroga: svuotamento dei luoghi `is_test=true`). Nessun file si cancella: si sposta in archivio.
- Il dossier si aggiorna in un task dedicato, non dalla chat che chiude; due sessioni nella stessa cartella si riconoscono da un file che non hai scritto tu.
- Per fermare l'IA dell'Esame si svuota `academy_ai_runtime.tick_token`, **mai** il job cron.

## Trappole — lezioni della memoria di progetto che valgono qui
[[sql_una_sola_chiamata]] · [[registrazione_migrazione_manuale]] · [[guardia_nome_migrazione]] · [[guardia_su_valore_nullo]] · [[role_start_porta_di_servizio]] · [[acl_confronto_per_insieme]] · [[check_vivo_sostituzione_insieme]] · [[rollback_asimmetrico]] · [[funzione_tomba]] · [[collisione_068_due_sessioni]] · [[dossier_task_dedicato]]

## Prossimo passo
PM: nuovo piano strutturale per la saturazione Luna/high; nessun retry 4.6.6 e nessun deploy produzione finché A–G non torna 18/18.
