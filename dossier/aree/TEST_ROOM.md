# AREA · Test Room (staff e utenti) — scheda viva
Riscritta il 04/09/2026 · da Codex (`TEST-ROOM-TESTER-AVANZATO-RINVIO-001`) · **stato dell'area: applicato, QA reale a metà** (DB ed Edge dal 23/08; 5 dispatch reali il 25/08; caricamento Land/regole da confermare)

## Fonti fondamentali — in quest'ordine, solo il blocco che serve
1. `sito_live/REGOLE.md` §10 «Master e staff» (la Test Room è il luogo di prova riservato allo staff: i tiri sono veri, i numeri no).
2. `management/coordination/HANDOFFS/TASK-TEST-ROOM-UTENTI-MOCK-AI-068.md` (server/IA) e `…-070-LAND-A1/A2/A3-HANDOFF.md` (Land, regole, handoff coordinato) — la sandbox pubblica non lesiva.
3. Tabelle `test_room_*` e Edge `test_room_ai` (v9); cron `test-room-cleanup` (:23) e `test-room-user-cleanup` (:41).
4. `TASK-TEST-ROOM-ACTOR-RUNNER-001.md`, `TASK-TEST-ROOM-DUAL-MODE-002.md`, `TASK-EXAM-TEST-ROOM-PULIZIA-MESSAGGI-073-DISCOVERY.md`.
5. Memoria di progetto: `test_room_cancello_e_deroga` (🔴), `test_room_collaudo_giocato`, `sandbox_test_room_068_r2`.

## Stato vivo — verificato a database il 04/09/2026
- **Smoke Esame 4.7.1 (04/09)**: usato soltanto `testperfunzioni`; flag `is_academy` e `is_exam_room` accesi per la durata della prova e poi ripristinati. Sessione `b4ea7ece…` chiusa `done`, prova `7dfe2fef…` conclusa `done`, 10/10 cicli Luna senza ripieghi, XP 0 e grado invariato. Postflight: Test Room `is_test=true`, `is_active=true`, `is_academy=false`, `is_exam_room=false`; 0 prove aperte e 0 cicli attivi; cron Esame acceso. Mai Riuji.
- **02/09**: per la prova d'esame di Riuji sono stati accesi e poi **spenti alle 18:50 UTC** i flag `is_exam_room` e `is_academy` sulla Test Room (oggi entrambi `false`, `is_test=true`). Lezione: la land disegna l'Esame solo in `is_exam_room` e ritrova la sessione solo da `academy_class_state` (`is_academy`); in una stanza senza i due flag, dopo un refresh il riquadro resta su «Il narratore sta preparando la scena». Se si ripete una prova d'esame qui, i due flag vanno riaccesi per la durata della prova e rispenti.
- **Deroghe di collaudo per lo staff nella Test Room (02/09):** `20260902102259` zona franca (lo staff schiera i propri PG in Regia) e `20260902152803 esame_avvia_deroga_test_room_002` (lo staff avvia l'Esame con qualunque PG: niente controllo di villaggio, grado, lezioni; la chiusura in `is_test` resta isolata — xp 0, grado invariato). Entrambe valgono per `is_test` + `is_staff()`, mai per un giocatore.
- Migrazione `20260823012339 test_room_utenti_mock_ai_070_r2` a registro; Edge `test_room_ai` **v9** ACTIVE (`verify_jwt=true`); `ninja_book_test_room_canary` v5 (appartiene a `MISSIONI_IA.md`).
- Tabelle: `test_room_fixture` 10 · `test_room_user_mock_profiles` 1 · `test_room_user_sessions` 1 · `test_room_user_ai_dispatch` **5** (ultimo il 25/08 09:08 UTC) · `test_room_user_quota` 1 · `test_room_user_reports` 7. Cioè: la QA reale con la quota piena (5 dispatch) è stata fatta almeno una volta il 25/08; il «+1» oltre quota e la prova con **due** account non risultano.
- Limite server: 5 dispatch per account e giornata 06:00–05:59 Europe/Rome; esito meccanico sempre disponibile, narrazione IA facoltativa.
- 20 funzioni con prefisso `test`.

## Lavori aperti — in ordine
1. **[P1] Chiudere la QA reale**: secondo account, sesto dispatch respinto, KO/ripristino del Manichino, confine delle 06:00, audit modello/token, blocco del retry sul referto fallito. Mezz'ora. Chi: Antonello + un secondo account.
2. **[P1] Verificare se Land e regole del 070 sono già dentro le build correnti** (`sito_live/land.html` di stasera e `regole.html` del 28/08) e caricate: la voce in `PM_QUEUE` è «READY» dal 23/08 e non dice se è successo. → `PUBBLICAZIONE.md`.
3. **[P2] Pulizia messaggi 073** — discovery consegnata, niente applicato.
4. **[P3] Chiudere la voce in `PM_QUEUE`** una volta fatti 1 e 2.

## Parcheggiato — non riaprire senza mandato
- Il candidato 068 R1 (server/IA): superato dal 070 R2 applicato. Non si riapre.
- **`TEST-ROOM-TESTER-AVANZATO` (04/09)** — rinviato per costo e priorità: ruolo/capability Tester separato dallo staff, scheda ombra modificabile (rango, statistiche, clan e jutsu), Esame ripetibile e chiamate Luna con quota, senza mai scrivere sulla scheda reale. Stima preliminare: 7–10 giorni lavorativi per l'MVP, 12–18 con tutti i pacchetti clan. Antonello prosegue per ora con il collaudo manuale; nessun cantiere aperto e nessun codice/DB autorizzato.

## Decisioni chiuse — non ridiscutere
- **04/09:** il progetto «Tester avanzato» non parte ora; resta parcheggiato finché Antonello non dà un nuovo mandato. La Test Room pubblica attuale e le deroghe staff restano invariate.
- Sandbox pubblica **non lesiva**: contro il Manichino mock, zero conseguenze persistenti, nessun catalogo staff, nessun riuso automatico della modalità «reale» dei candidati 001/002.
- Il cancello `_puo_test_room()` **è anche la deroga**: allargarlo regala tecniche non possedute, chakra gratis e l'intero catalogo. Non si tocca senza un banco che lo provi nei due sensi.
- Il modello si risolve prima di spendere il gettone; il referto IA fallito non si ritenta.
- **«Chiudi scena» (02/09, `20260902110040 master_v2_scene_close_001`)**: il Master chiude una scena a metà senza KO; vale ovunque (non solo in Test Room), esclude le missioni con `mission_id`. Pulsante nel land 006.
- **Zona franca (02/09, `20260902102259 test_room_zona_franca_master_attore_001`)**: in un luogo `is_test` uno staff può essere Master e attore PG dello stesso scontro V2, senza secondo account. Vincolo allentato dichiarato ad Antonello; rollback depositato in `supabase/migrations/…_ROLLBACK.sql`. Fuori dalla Test Room niente cambia.

## Trappole — lezioni della memoria di progetto che valgono qui
[[test_room_cancello_e_deroga]] · [[test_room_collaudo_giocato]] · [[sandbox_test_room_068_r2]] · [[provider_da_riga_scrivibile]] · [[guasto_solo_sotto_corsa]]

## Prossimo passo
Antonello completa in autonomia la mezz'ora con due account; il Tester avanzato resta parcheggiato.
