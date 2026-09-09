# AREA · Allenamento V2 e Sensei IA dell'allenamento — scheda viva
Allineamento documentale del 09/09/2026 · fotografia tecnica del 01/09 conservata e qualificata; recuperata una ratifica narrativa circoscritta. La ricognizione non certifica lo stato live odierno del Training o del Sensei IA.

## Fonti fondamentali — in quest'ordine, solo il blocco che serve
1. `sito_live/REGOLE.md` §6.1 «Training V2 — imparare una tecnica in una role» e la riga 72 del changelog — il regolamento vivo.
2. `management/coordination/HANDOFFS/DECISION-PACK-TRAINING-V2-20260819-FROZEN.md` — il contratto congelato; `TASK-TRAINING-V2-CORE-002-R3-CONSEGNA.md`, `TASK-TRAINING-V2-CORE-REBASE-004.md`, `QUEUE-TRAINING-V2-POST-DBCORE-047-20260819.md`.
3. Tabelle `training_*` a database (33 funzioni con prefisso `training`): `training_sessions` è la verità sugli allenamenti; `training_guidance_policies` (347 righe) e `training_guidance_event_contracts` (5) per la guidance.
4. Sensei IA: `TASK-TRAINING-SENSEI-AI-124A-OFFLINE.md` e la catena 146B…146AX (`HANDOFFS/TASK-TRAINING-SENSEI-AI-*`); Edge `training_sensei_ai` v5.
5. `claude/allenamento_progettazione.md` — l'intenzione di design originaria (superata dove il DB dice altro).
6. Memoria di progetto: `training_v2_cooperativa`, `motore_lesivita_falsi_amici`, `xp_scale_non_scritte`.
7. `dossier/02_INDICE_DOCUMENTI.md` §Cosa portare nel nuovo punto di partenza, «Allenamento e riservatezza dell'innata»; task archiviata `01a06cea-33ec-7ef1-a709-4d346062a24b`, «Valuta allenamento Ryutama e Kirei». Conservare il verdetto del caso senza copiarne la role privata.

## Stato vivo — fotografia tecnica del 01/09/2026, non riverificata da questo allineamento
- Core V2 a database dal 26/08; consumer Scheda/Land/Admin allineati in `sito_live/` il 26/08 (caricamento su GitHub: vedi `PUBBLICAZIONE.md`).
- `training_sessions`, fotografia del 01/09: 6 righe — 26/08 valida, 26/08 annullata, 28/08 e 29/08 abbandonate, due `legacy_review` del 10/08. Questi pochi eventi storici non stabiliscono il tasso di abbandono o le cause dell'uso attuale.
- `character_abilities`: 10 righe (tecniche apprese o in addestramento).
- Edge `training_sensei_ai` **v5** ACTIVE (`verify_jwt=false`), runtime spento, budget null, nessun contenuto né persona; `training_ai_runtime` 1 riga, audit 1.
- Guidance 146AD/146AL/146AO e unknown-billable 146AV-R4: a database, **inerti**. 24 tabelle `training_*` vuote.

## Lavori aperti — in ordine
1. **[P1] Riconciliare gli eventi storici abbandonati/annullati con le eventuali prove successive** — sola lettura mirata, distinguendo stato della sessione, motivazione e difetti d'interfaccia osservati. Le date del 26–29/08 sono indizi da contestualizzare, non diagnosi automatica dell'uso corrente.
2. **[P1] Un allenamento completo fatto da Antonello** con un PG di prova, nelle tre modalità (individuale, cooperativa, gruppo), fino alla tecnica attiva.
3. **[P2] Contenuti e persona del Sensei IA** — approvati editorialmente prima di qualunque runtime; poi budget e canary. Parcheggiato finché il punto 2 non è verde.
4. **[P3] Guidance e unknown-billable** — restano inerti finché il Sensei non ha contenuti.

## Parcheggiato — non riaprire senza mandato
- `TRAINING-AI-SENSEI-001` come «maestro facoltativo per tecniche complesse» (P2 dell'08/08): assorbito dalla catena 146; non si riapre con quel nome.
- Runtime, provider e canary del Sensei: vietati finché mancano contenuti approvati.

## Decisioni chiuse — non ridiscutere
- Una riga per personaggio, non di coppia: annullare A non tocca B; lo storico non congela l'avanzamento.
- Giornata 06:00–05:59; osservatori esclusi; l'abbandono non rimborsa; lo sparring è non letale ma conserva PV e chakra consumati; sospetti e legacy passano dall'Admin; progresso, attivazione e notifica sono atomici; **l'IA non decide**.
- «Acquistabile» si legge in `training_start`, non in `xp_cost`.
- **Ratifica narrativa di un singolo allenamento:** nella task `01a06cea-33ec-7ef1-a709-4d346062a24b` Antonello ha riconosciuto la validità narrativa del caso anche senza rivelazione pubblica dell'innata. Il giudizio resta circoscritto a quel caso: non modifica le regole generali, non convalida automaticamente una sessione e non attesta aggiornamenti di progressione a database. Nessuna role privata è riprodotta qui.

## Trappole — lezioni della memoria di progetto che valgono qui
[[training_v2_cooperativa]] · [[motore_lesivita_falsi_amici]] · [[xp_scale_non_scritte]] · [[rpc_vive_senza_interfaccia]] · [[fixture_muta_verde_sbagliato]]

## Prossimo passo
Riconciliare soltanto le evidenze tecniche e le prove recenti pertinenti prima di riprendere i lavori aperti. Conservare la ratifica narrativa del singolo caso con il suo perimetro; eventuali convalide, avanzamenti o prove live seguono le autorizzazioni e il funzionamento del Training, senza derivare automaticamente da questa nota.
