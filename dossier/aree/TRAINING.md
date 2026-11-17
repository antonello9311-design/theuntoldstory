# AREA · Allenamento V2 e Sensei IA dell'allenamento — scheda viva
Allineamento del 17/11/2026 · aperto il cantiere [Allenamento individuale in Scheda](../../management/candidati/ALLENAMENTO-INDIVIDUALE_2026-11-17/SCHEDA.md).

## Fonti fondamentali — in quest'ordine, solo il blocco che serve
1. `sito_live/REGOLE.md` §6.1 «Allenamento e apprendimento delle tecniche» e le righe 72, 105 e 106 del changelog — il regolamento vivo.
2. `management/coordination/HANDOFFS/DECISION-PACK-TRAINING-V2-20260819-FROZEN.md` — il contratto congelato; `TASK-TRAINING-V2-CORE-002-R3-CONSEGNA.md`, `TASK-TRAINING-V2-CORE-REBASE-004.md`, `QUEUE-TRAINING-V2-POST-DBCORE-047-20260819.md`.
3. Tabelle `training_*` a database (33 funzioni con prefisso `training`): `training_sessions` è la verità sugli allenamenti; `training_guidance_policies` (347 righe) e `training_guidance_event_contracts` (5) per la guidance.
4. Sensei IA: `TASK-TRAINING-SENSEI-AI-124A-OFFLINE.md` e la catena 146B…146AX (`HANDOFFS/TASK-TRAINING-SENSEI-AI-*`); Edge `training_sensei_ai` v5.
5. `claude/allenamento_progettazione.md` — l'intenzione di design originaria (superata dove il DB dice altro).
6. Memoria di progetto: `training_v2_cooperativa`, `motore_lesivita_falsi_amici`, `xp_scale_non_scritte`.
7. `dossier/02_INDICE_DOCUMENTI.md` §Cosa portare nel nuovo punto di partenza, «Allenamento e riservatezza dell'innata»; task archiviata `01a06cea-33ec-7ef1-a709-4d346062a24b`, «Valuta allenamento Ryutama e Kirei». Conservare il verdetto del caso senza copiarne la role privata.

## Stato vivo — riscontro del 17/11/2026

- Allenamento individuale ordinario attivo in Scheda, con costo XP all’avvio e una sessione per personaggio a giornata. Maturazione al cambio delle 06:00 di Roma.
- Cooperativa, gruppo, sparring e percorsi speciali conservano la registrazione in role quando prevista. La quota è condivisa. Le dichiarazioni e gli avvii precedenti all’apertura restano validi secondo il proprio percorso.
- Collaudo Staff completato su saldo simulato. L’apertura di Combat da un altro PG ha acquisito la tecnica maturata nel contesto protetto. Esito e ricevute nella consegna del cantiere.
- Il runtime Sensei IA risulta spento al precedente riscontro. Le vecchie verifiche di guidance restano nel contratto storico.

## Lavori aperti

Il primo utilizzo pubblico sarà osservabile al normale uso della funzione. Le nuove prove del Sensei e della guidance restano parcheggiate.

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

Conservare gli esiti del [collaudo Staff](../../management/candidati/ALLENAMENTO-INDIVIDUALE_2026-11-17/HANDOFF.md).

