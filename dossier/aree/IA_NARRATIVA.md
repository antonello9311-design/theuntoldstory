# AREA · IA narrativa — repertorio, voce, provider — scheda viva
Riscritta il 03/09/2026 · da Codex (`PM-DOCUMENTALE-CANTIERI-DIPENDENZE-001`) · **stato dell'area: in uso; Narratore Esame v119 LIVE, qualità ancora da certificare**

## Fonti fondamentali — in quest'ordine, solo il blocco che serve
1. `management/repertorio/README.md`, `MANIFESTO.json`, `GENERAZIONE.md`, `REFERTO_0_3_0.md`, `STORICO_VERSIONI.md` — **la fonte canonica** del repertorio condiviso di lingua e narrazione (v0.3.0, promosso). Le note di redazione sugli esiti vanno qui, non in un handoff.
1a. **Cantiere `management/candidati/NARRATORE-UNIFICATO_2026-09-02/`** (SCHEDA.md = sequenza in 7 passi) e **`management/SCHEDE_SFIDANTI_ESAME.md`** (sei schede, proposte da approvare).
1b. **`management/redazione/`** (README, `LINEE_GUIDA_NARRATIVE_R2.md`, `REGOLE_REDAZIONALI_COMBAT_R3.md`, `NOTE_ESAME_R1-R7.md`) — la fonte redazionale del Narratore indicata da Antonello il 02/09: le linee guida delle Missioni IA sono la base anche per l'Esame; le note dell'Esame sono l'addendum. `NOTE_ESAME_R1-R7.md` — le note di redazione approvate da Antonello (R1 reazioni ai colpi, R2 nessuna voce ai PG, R3 conseguenze verosimili senza formule) in attesa di consolidamento nel repertorio 0.4.0 e nel validatore; una nota nuova si aggiunge lì, non in un handoff.
2. `management/PNG_NARRATIVO_STANDARD.md` — lo standard dei PNG narrativi.
3. `management/analisi/ANALISI_ARCHITETTURA_NARRATIVA_IA.md` (29/08, otto proposte), `CAMPIONE_PONTE_GIOCATORE.md`, `CORPUS_UMANO_COME_SCUOLA.md`, `PIANO_QA_NARRATIVO_UNIFICATO.md`.
4. `management/coordination/HANDOFFS/TASK-AI-LINGUA-NARRAZIONE-CORE-018.md` + `-R2-IMPLEMENTAZIONE.md` + `-R2-AUDIT-USAGE.md`; `TASK-AI-ORCHESTRA-CANONICAL-LUNA-HIGH-145C.md`; `TASK-MISSION-NARRATORE-REAZIONI-COLPI-001.md` (nota approvata il 01/09, da integrare).
5. Registro `public.ai_agents` (kind, model, persona, is_active) — il provider è quello a database, mai dedotto da una riga scrivibile.
6. Memoria di progetto: `ai_lingua_repertorio_condiviso_018`, `provider_da_riga_scrivibile` (🔴), `corpus_reale_come_ancora`, `guardrail_fonte_vs_prompt_certificato`, `narratori_luna_046`.

## Stato vivo — Edge riconfermata da Antonello/Claude il 03/09/2026
- **`exam_genin_ai` v119 (`4.1.0-NU001`, prompt21) LIVE**, byte-verificata da Antonello/Claude, `verify_jwt=false`: metodo ricevuta autoritativa → piano narrativo → prosa → validatore per riferimenti; prompt e contesto voce ampliati; minimi `azione_png >=1000` e branche `>=450`. Migrazioni 457–461, head `20260903111028 esame_narratore_unificato_005_bersaglio_dichiarato`; P1 «fatti d'esito arricchiti» è LIVE lato DB. Lo smoke Staff/Test Room è concluso lato backend (zero prove globali aperte, 2/2 cicli risolti), ma **non è certificazione qualitativa**.
- Narratori Edge vivi: `academy_sensei_ai` v40 · `combat_narratore_ai` v18 · **`exam_genin_ai` v119** · `mission_narratore_ai` v9 · `training_sensei_ai` v5 (spento) · Tavolo di Aiuto `land_help_ai` v12.
- Provider: **unico**, `gpt-5.6-luna` con `reasoning: high` (142A/145B/145C: braccio unico, provider ritirato rimosso fisicamente). `OPENAI_API_KEY` nei Secrets della Edge (mai letta).
- Repertorio 018 R2 promosso (v0.3.0); caporali validati; `innesti.json` ricco. **Provato nel bundle v102 che l'innesto performativo NON arriva alla chiamata Surface del Narratore** (usa il proprio prompt dal seed, persona ridotta).
- Diagnosi del 29/08: coerenza raggiunta e provata; **espressività mancante per costruzione** (persona descrittiva senza esempi di voce, esito legato per famiglia, validazione per riferimento e non per contenuto); prosa del giocatore in quarantena → il Narratore non può riprendere l'azione descritta dal PG.

## Lavori aperti — in ordine
1. **[P1] Player bridge strutturato** — portare intenti e dettagli non autoritativi del giocatore come claim espliciti (`player_claims` / `player_reprise`), sopprimendo ogni conflitto con i fatti server.
2. **[P1] Ampiezza delle manovre** — evitare che il piano narrativo restringa le opzioni legali del PNG a poche sequenze ricorrenti; nessuna meccanica nuova dal modello.
3. **[P1] Memoria anti-ripetizione** — formule, chiusure e immagini già usate nella prova devono entrare nel contesto di esclusione, senza trasformarsi in fatti di gioco.
4. **[P1] Validazione qualitativa della voce end-to-end** — v119 amplia prompt e contesto voce, ma lo smoke misto non certifica naturalezza, dialogo o varietà; serve banco dedicato e lettura umana.
5. **[P2] Portare il metodo a combat e missioni** — solo dopo la certificazione dell'Esame, mantenendo ricevuta e validatore specifici per consumer.
6. **[P3] `TASK-AI-ITALIANO-COMUNE-001`** — si riprende quando il contratto dell'Esame è stabile.

## Parcheggiato — non riaprire senza mandato
- Proposte P2 (blocco voice nella persona), P3 (aprire 018 R2 — già promosso), P5 (audit corpus di ripiego 26–29/08), P6 (contesti orfani `narrative_context_exam/combat`), P7 (caporali — già validati), P8 (`prompt_version`).
- Programma 046 fase A (narratori → Luna): chiuso; i due candidati isolati non si distribuiscono perché nati sulla baseline.

## Decisioni chiuse — non ridiscutere
- «L'IA racconta, il server comanda»: nessun valore di gioco dall'IA; persona, fatti, frame e permessi sono autoritativi lato server.
- Una chiamata modello per ciclo; la risposta in ritardo si scarta; al modello arriva l'elenco già sfrondato.
- Il provider si risolve **prima** di spendere il gettone; `ai_agents.model` non è un instradatore.
- I due asterischi di `personas.json` sono contenuto e non si normalizzano.
- Le cinque IA non condividono memoria: ogni consumer riceve e prova esplicitamente il contratto.

## Trappole — lezioni della memoria di progetto che valgono qui
[[provider_da_riga_scrivibile]] · [[guardrail_fonte_vs_prompt_certificato]] · [[corpus_reale_come_ancora]] · [[ai_lingua_repertorio_condiviso_018]] · [[accademia_ia_blocco]] · [[scontrino_monouso]] · [[voce_narrativa_066_r2]]

## Prossimo passo
Preparare la certificazione qualitativa v119 separata dal rilascio: player bridge, ampiezza delle manovre, memoria anti-ripetizione e banco umano sulla voce end-to-end.
