# AREA · Combattimento e Regia — scheda viva
Riscritta il 04/09/2026 · da Codex (`P1-COMBAT-ESAME-SOSTITUZIONE-SCAMBIO-001-OFFLINE`) · **stato dell'area: in uso** (V2 multi-target giocato; P1 Esame verde statico, integrazione bloccata dal branch QA)

## Fonti fondamentali — in quest'ordine, solo il blocco che serve
1. `sito_live/REGOLE.md` §4 — in particolare 4.2 ordine del turno, 4.5 distanze/movimento/gittata, 4.7 lo scontro nella land, 4.8 la Regia Master multi-attore; §5.2 i jutsu.
2. Funzioni `combat_v2_*` e `master_v2_*` a database (73 con prefisso `combat`, 24 `master`): il motore è lì, non nei documenti. Porte owner censite in `archivio/2026-08/evidenze/mission_exchange_land_live_postupload_005/VERIFICA_BACKEND.md`.
3. `management/candidati/COMBAT-COMPOSITE_2026-09-01/SCHEDA.md` e `HANDOFF.md` (stato corrente: resolver comune Sostituzione già LIVE, innesto Esame legacy ancora da fare, tre contratti P1 verdi staticamente); `TASK-LAND-MV2-DEFENSE-STABILITY-001.md` (ultimo intervento su land + DB, 01/09).
4. `management/analisi/LETTURA_MOTORE_SPAZIALE.md` e `HANDOFFS/TASK-COMBAT-SPATIAL-AOE-MAP-001.md`; il PM pack `TASK-PM-COMBAT-SPATIAL-AOE-001.md` è da **519 KB**: solo per sezione, mai intero.
5. Decisioni PM del 18–19/08: `DECISIONE-PM-EXAM-TECNICHE-041-042-20260818.md`, `DECISIONE-PM-TRASFORMAZIONE-SCENA-042-A3-20260818.md`, `DECISIONE-PM-COMBAT-MOLTIPLICAZIONE-OFFENSIVA-043-20260819.md`, i `FREEZE-PM-COMBAT-*`.
6. Memoria di progetto: `mv2_finestra_001`, `scontro_ui_001`, `effetti_contratto_deciso`, `effetti_vocabolario_002`, `v11_applicata`.
7. Skill `gdr-contesto` §2 per le formule (atk_tot, dmg, red_div, tenuta) — con i numeri, non con le colonne, che vanno letti a DB.

## Stato vivo — riconciliato il 04/09/2026 sulla baseline PM
- Head LIVE verificata in sola lettura: `20260903203601 esame_narratore_finale_ampiezza_006_recovery`; va riverificata al prossimo gate e non diventa un pin permanente. Il resolver comune Sostituzione R9, le porte Combat e i wrapper Esame esistono già; `_esame_prova_opzioni` e `_esame_risolvi` usano però ancora il ramo legacy senza exact option id e con costo/cooldown locali. Composite R13 resta **LIVE inerte**.
- Candidato P1 Esame depositato nel cantiere: Sostituzione36 + adapter33 + receipt32 + integrazione24 = **125 banchi**, tutti verdi staticamente e con checksum integri. Nessun apply/enable/smoke. Branch QA osservato indietro di head e con control plane `MIGRATIONS_FAILED`; reset controllato affidato all'owner esterno.
- Multi-target V2 vivo (rebase 417/427 applicati 31/08–01/09 con pin `tetsuma_nao`). Round 2 vivo giocato da Itsuki e Hime (Schivata; 5 e 25 danni), anteprima narrativa `pending` non pubblicata: **role congelata**, non autorizza prove Clan né modifiche ai PG.
- Edge `combat_narratore_ai` **v18** ACTIVE su Luna high; cron `combat-narratore` (1′) e `combat-silenzio` (10′).
- Tabelle vuote dell'area: 8 `combat_*`, 5 `master_*` (fondazioni inerti).
- Land: la build locale `LAND-MV2-MOLTIPLICAZIONE-PANEL-004` (01/09 20:47) **non è ancora caricata** (scheda `PUBBLICAZIONE.md`).

## Lavori aperti — in ordine
1. ✅ **Collaudo del land del 01/09 eseguito da Antonello il 02/09 in Test Room** (zona franca, Riuji Master+PG contro Rina): ciclo completo azioni → difese → calcolo → esito pubblicato; la selezione ha retto ai 20″ di polling e a un messaggio in chat pubblicato a metà difesa; Regia e pannello attore convivono. Due richieste emerse, sotto (#2 e #3).
2. **[P2] Iniziativa manuale del Master** (richiesta di Antonello, 02/09): oggi l'ordine di risoluzione lo decide il server — `initiative_snapshot` (Velocità) decrescente, poi un'estrazione casuale sigillata (`rng_order_commitment`) — e il Master non può imporre chi agisce prima. Va deciso il contratto (ordine dichiarato dal Master prima del calcolo, registrato nell'evento, mai dal client dopo il congelamento) prima di toccare `combat_v2_round_resolve`. Chi decide: Antonello; poi COMBAT-CORE/DB-CORE.
3. **[P2] «Utilità» nel menu azione non è chiaro** (Antonello, 02/09): a database `utilita` è solo un tipo di dichiarazione principale senza logica propria — vale come «turno usato per un'azione non offensiva», identico a «Passa» nel calcolo; «Passa» è il turno speso solo per muoversi. Decisione di Antonello (02/09): per ora solo l'etichetta esplicita (fatto, build 005 da caricare); il resolver per le tecniche di scena/supporto e l'iniziativa manuale (#2) sono RINVIATI a dopo la chiusura dei cantieri aperti e della riorganizzazione della cartella.
3b. ✅ **«Chiudi scena»** (02/09, decisione di Antonello: essenziale per i test, non rinviabile): porta nuova `master_v2_scene_close` a registro (`20260902110040`), pulsante nella Regia accanto a «Congela e sospendi» e nella sessione in preparazione (build `LAND-MV2-CHIUDI-SCENA-006`, caricata e collaudata il 02/09). Chiude senza KO: scontro → annullato, round aperto lasciato nella storia, sessione → annullata «chiusa dal Master». Le missioni con `mission_id` restano escluse (solo «Chiudi attività» con esito).
4. **[P1] Playtest delle posizioni in metri** della finestra MV2 (residuo dal 27/08) con due PG veri. Chi: Antonello + QA-PLAYTEST.
5. **[P2] Composite movimento + tecnica** — consumer R13 **LIVE inerte** (history 451, verificato a DB); depositi in `management/candidati/COMBAT-COMPOSITE_2026-09-01/`. Resta: l'attivazione (gate nominativo) dopo i verticali Clan che lo usano. Nessuna attivazione implicita.
6. **[P1] Moltiplicazione/Formazione R4** — candidato e review offline 0/0/0 con sigilli integri, ma la catena pinzata arriva a history453: **rebase sulla head LIVE verificata al gate**, nuova readiness e nuova review prima di qualunque apply. Il candidato sigillato non si aggiorna con search/replace; la role congelata (Ronda, combat in `raccolta_difese` dal 01/09 21:01) deve restare intatta.
6b. **[P1] Innesto Esame della Sostituzione server-authoritative** — resolver comune e wrapper esistono; candidato di riuso/attestazione verde staticamente. Resta sostituire integralmente il ramo legacy di `_esame_prova_opzioni`/`_esame_risolvi`, evitando doppio costo/cooldown, e provarlo sul branch riallineato.
6c. **[P1] Adapter dello scambio + ricevuta POV** — contratti offline verdi: una sola identità di scambio, eventuale contrattacco irrisolto, iniziativa server-derived dopo pubblicazione, projection senza coordinate/UUID. Resta la campagna integrata sul branch e una review indipendente.
7. **[P2] Bridge server-side delle innate in Combat V2** (`clan_innate_activation_turn_bundle_001_context_offline`) — prima di dichiarare Jūken «autorizzato da Byakugan attivo». Dipende da `CLAN.md` fase 1.
8. **[P2] AoE spaziale** — solo progetto; playtest di `p_positions` prima di qualunque area.
9. **[P2] `PM_QUEUE`: le voci 040 (passaggio del Diversivo), 041 (scaling copie), 039 (allineamento pre-live)** sono «READY» dal 14/08 con nota «da riverificare» dal 23/08: dichiararle una per una *superate* o *chiuse*. Chi: PM.
10. **[P3] `guida.html` del motore** (`COMBAT-V1-GUIDA-LAND`) e **dismissione del calcolatore legacy «Combatti»** — candidati solo dopo approvazione PM (scheda `PAGINE.md`).

## Parcheggiato — non riaprire senza mandato
- Trasformazione come finta (TACTIC-015): morta come candidato. Diversivo 016: superato dalla 017 (applicata 17/08). Integrazione DB 040+042 R2: depositata, superata dalla catena 084→108.
- «Colto in azione»: sospeso (decisione V1.1). Parser abilità staff `[abilità: Nome]`: fuori dalla V1, si riapre con la fase 2 degli effetti.
- Fase 2 effetti: non avviabile finché i valori degli effetti dei nove clan non sono definiti (→ `CLAN.md`).

## Decisioni chiuse — non ridiscutere
- Round V1 = una coppia attacco + difesa, un racconto. Striscio = ¼ del danno pieno (min 1); Slancio +3 fino a +9; Sostituzione ogni tre difese.
- Trasformazione è tecnica **solo di scena** (042-A3): mantenerla invece di attaccare dà niente.
- Moltiplicazione = Diversivo con copie **difensive** (043); nessun testo pubblico può negarne la funzione; costo 10 + 5 per copia (changelog 57).
- 01/09: Dispersione offerta/accettata **solo contro Genjutsu**; Sostituzione **solo** da `substitution_offers` server-side con ancora spaziale; `self` solo alle difensive personali senza profilo multi-target.
- I campi «Interpretazione dell'azione/difesa» sono rimossi: la narrazione passa dalla chat; la pubblicazione Fato resta vincolata al referto.
- Innate e leggendarie non occupano slot; il danno base non viene mai dal client.
- **Il Master di una sessione MV2 non può essere anche un attore PG del proprio scontro** (`attore_non_controllato`) — **salvo la zona franca**: dal 02/09 (`20260902102259 test_room_zona_franca_master_attore_001`, autorizzata da Antonello) uno **staff** in un **luogo `is_test`** può aprire lo scontro essendo anche PG (vale per `master_v2_encounter_open` e per il percorso Ninja Book umano). Fuori dai luoghi di prova la regola è intatta. I PNG di regia umana vengono solo da `png_templates` attivi (oggi uno: Rina); i PNG del Ninja Book passano da offerte create dal servizio missioni, non dal menu della land. Un luogo ammette un solo scontro aperto alla volta (legacy o V2).

## Trappole — lezioni della memoria di progetto che valgono qui
[[costo_azione_non_solo_bonus]] · [[opzione_offerta_stato_risultante]] · [[motore_lesivita_falsi_amici]] · [[catalogo_contro_motore]] · [[insieme_chiuso_operatore_in]] · [[qa_coordinate_mappa]] · [[defense_flags_004_collaudata]] · [[clan_innate_contro_motore]]

## Prossimo passo
Attendere il branch QA Healthy e allineato alla head produzione; poi eseguire sullo stesso revision set l'innesto Esame P1-A/P1-B/P1-C, la suite integrata e una sola review indipendente. Nessun apply o enable prima di un gate nominativo separato.
