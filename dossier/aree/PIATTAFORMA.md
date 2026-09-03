# AREA · Piattaforma — database, migrazioni, cron, Edge, cartella di lavoro — scheda viva
Riscritta il 03/09/2026 · da Codex (`PM-DOCUMENTALE-CANTIERI-DIPENDENZE-001`) · **stato dell'area: in uso, con igiene arretrata** (461 migrazioni; regola d'ingresso attiva nel tabellone)

## Fonti fondamentali — in quest'ordine, solo il blocco che serve
1. Skill `gdr-sql` (GRANT esplicito, CHECK, dollar-quoting, prova in transazione, piano prima dell'apply) e `gdr-verifica` (le cinque interrogazioni che fotografano il DB).
2. Il database stesso: `supabase_migrations.schema_migrations` (registro), `cron.job` + `cron.job_run_details`, `list_edge_functions`, `get_advisors`. Il DB vince su ogni documento.
3. `supabase/migrations/` (copie locali, non il registro) e `supabase/functions/` (solo `exam_genin_ai`: le altre Edge hanno il sorgente nei candidati).
4. `management/coordination/RETIRED_CANDIDATES.json` e `management/tooling/` (`manifest_guard` 1.0.0, `pg16.sh` replica locale, `banco_067.sh`).
5. `dossier/05_CONVENZIONI.md` §3 (colonne nuove, `uso`/`difensiva`/`di_scena`, `messages.kind`) — dove `gdr-contesto` è arretrata.
6. Memoria di progetto: `sql_una_sola_chiamata`, `registrazione_migrazione_manuale`, `guardia_nome_migrazione`, `sigillo_trasporto_sql`, `replica_locale_motore`, `dossier_task_dedicato`, `collisione_068_due_sessioni`.

## Stato vivo — baseline backend osservata dal PM il 03/09/2026; Edge riconfermata da Antonello/Claude
- **Registro: 461 migrazioni**, head `20260903111028 esame_narratore_unificato_005_bersaglio_dichiarato` (la zona dichiarata dal candidato prevale sul dado; applicata da Claude/Antonello; testo non ancora depositato in `supabase/migrations/`). Prima: 460 `20260903071306 …_004_tempi` (ripiego 5 minuti, tick 210 s), 457–459 rilascio Narratore unificato, 455 `master_v2_scene_close_001` e 454 `test_room_zona_franca_master_attore_001`. Edge `exam_genin_ai` **v119 (`4.1.0-NU001`, prompt21)**, byte-verificata e `verify_jwt=false`. La chiusura Staff/Test Room è completa: prova annullata/cancelled senza pending, sessione chiusa/cancelled, `is_academy=false`, `is_exam_room=false`, zero prove globali aperte, cicli 2/2 risolti; nessuna DELETE e cron invariati. 449–453 restano la catena Clan/Combat **LIVE inerte**. **Ogni candidato nuovo o da riaprire dipende dalla head LIVE verificata al momento del gate**: i pin storici 453/455 restano nei pacchetti sigillati, ma non autorizzano apply senza rebase e nuova review.
- `public`: **230 tabelle** (93 con zero righe: `training` 24, `nb` 23, `mission` 18, `combat` 8, `master` 5, `character` 3, altre 12) · **705 funzioni** (594 SECURITY DEFINER; per prefisso: `combat` 73, `mission` 64, `academy` 41, `training` 33, `nb` 33, `master` 24, `png` 23, `test` 20, `exam`+`esame` 30, `premio` 11, `role` 11).
- Sicurezza: SECDEF senza `search_path` **0** (il «38» del 29/08 è chiuso) · SECDEF eseguibili da `anon` **15** (da ratificare) · `pg_net` nello schema `public` (da ratificare) · i ~139 warning advisor su SECURITY DEFINER sono l'architettura.
- **Edge (15)**: `login-name` v9 · `delete-account` v9 · `academy_sensei_ai` v40 · `land_help_ai` v12 · `combat_narratore_ai` v18 · `academy_audit_ai` v23 · **`exam_genin_ai` v119 (`4.1.0`, byte-verificata da Antonello/Claude)** · `test_room_ai` v9 · `exam_live_qa_worker_131q` v7 · `ninja_book_test_room_canary` v5 · `training_sensei_ai` v5 · `mission_narratore_ai` v9 · `nodo_azzurro_canary_coordinator` v5 · `png_media_attest_v1` v4 · `mission_ai_board_opening` v2.
- **Cron (13)**: `academy-tick` 1′ · `esame-tick` 1′ (riacceso 01/09 21:56) · `combat-narratore` 1′ · `role-expire-unsaved-2h` 1′ · `exam-surface-qa-worker-131q` 1′ · `academy-audit-observability-reconcile` 5′ · `esame-monitor-10m` · `combat-silenzio` 10′ · `role-maintenance-hourly` :07 · `test-room-cleanup` :23 · `test-room-user-cleanup` :41 · `academy-audit-weekly` lun 04:00 · `pilot-scadenza` **OFF** (dichiarato).
- Utenza: 78 profili, 73 personaggi.
- Cartella di lavoro: `management/` 474 MB — 1.082 cartelle in `candidati/` (172 nate il 01/09), 537 in `review/`, 419 handoff; `_to_delete/` 120 MB (66 archivi C, programma 096).

## Lavori aperti — in ordine
1. **[P1] Regola d'ingresso**: al massimo **tre cantieri «in lavoro»**; nessuna fondazione nuova (tabelle, RPC, Edge) finché non atterra uno fra Missioni IA, Training, Clan. Chi la dichiara: Antonello; chi la fa rispettare: il PM nel tabellone.
2. **[P1] Ratificare i 15 SECDEF eseguibili da `anon`** e `pg_net` in `public` — una review di venti minuti, con l'elenco a database.
3. **[P2] Mappa delle 93 tabelle vuote → cantiere di appartenenza** (già per prefisso qui sopra): serve per sapere cosa archiviare quando un cantiere viene parcheggiato.
4. **[P2] Riallineare `gdr-contesto`** (skill): 705 funzioni, 15 Edge, 13 cron, changelog 73, colonne `uso`/`difensiva`/`di_scena`, «Lumache solo medici» falso, `seconda_natura` gratuita al Jonin. Si consegna come scheda di revisione; la salva Antonello.
5. **[P2] Registrare nel tabellone ogni cron/flag/gate spento o acceso** (lezione del 30/08).
6. **[P3] FK senza indice** segnalati INFO nelle fondazioni Ninja Book / Surface (4+7+5): dopo il traffico reale, non prima.
7. **[P3] `_to_delete/`**: 66 archivi C al programma 096; il resto è già nel Cestino dal 23/08.

## Parcheggiato — non riaprire senza mandato
- Protezione password compromesse di Supabase: **spenta per scelta** (piano gratuito). §7 di `migration_coerenza.sql`: **annullata il 28/07, non rieseguire**. L'account `Riuji` non si tocca.
- Refactor degli helper condivisi fra pagine: decisione aperta nel piano di leggibilità, non è di quest'area.

## Decisioni chiuse — non ridiscutere
- Ogni funzione nuova nasce **invisibile al client** finché non ha il GRANT esplicito; ogni chiamata SQL è una transazione a sé; il rollback si aggancia al nome **registrato** della migrazione, per uguaglianza esatta.
- Le verifiche confrontano impronte salvate col dato, non contano righe; le ancore sui totali vivi invecchiano mentre qualcuno gioca.
- Per disattivare: `is_active=false`, mai `DELETE` (unica deroga: svuotamento dei luoghi `is_test=true`). Nessun file si cancella: si sposta in archivio.
- Il dossier si aggiorna in un task dedicato, non dalla chat che chiude; due sessioni nella stessa cartella si riconoscono da un file che non hai scritto tu.
- Per fermare l'IA dell'Esame si svuota `academy_ai_runtime.tick_token`, **mai** il job cron.

## Trappole — lezioni della memoria di progetto che valgono qui
[[sql_una_sola_chiamata]] · [[registrazione_migrazione_manuale]] · [[guardia_nome_migrazione]] · [[guardia_su_valore_nullo]] · [[role_start_porta_di_servizio]] · [[acl_confronto_per_insieme]] · [[check_vivo_sostituzione_insieme]] · [[rollback_asimmetrico]] · [[funzione_tomba]] · [[collisione_068_due_sessioni]] · [[dossier_task_dedicato]]

## Prossimo passo
Ratificare i 15 `anon` e `pg_net`; per ogni futuro gate, fotografare la head LIVE invece di ereditare un numero storico dai documenti.
