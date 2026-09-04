# AREA · IA narrativa — repertorio, voce, provider — scheda viva
Riscritta il 04/09/2026 · da Codex (`NARRATORE-UNIFICATO-COMPACT-4.7.1`) · **stato dell'area: in uso; `exam_genin_ai` 4.7.1/prompt30 LIVE e smoke completo verde**

## Fonti fondamentali — in quest'ordine, solo il blocco che serve
1. `management/repertorio/README.md`, `MANIFESTO.json`, `GENERAZIONE.md`, `REFERTO_0_3_0.md`, `STORICO_VERSIONI.md` — **la fonte canonica** del repertorio condiviso di lingua e narrazione (v0.3.0, promosso). Le note di redazione sugli esiti vanno qui, non in un handoff.
1a. **Cantiere `management/candidati/NARRATORE-UNIFICATO_2026-09-02/`** (SCHEDA.md = sequenza in 7 passi) e **`management/SCHEDE_SFIDANTI_ESAME.md`** (sei schede, proposte da approvare).
1b. **`management/redazione/`** (README, `LINEE_GUIDA_NARRATIVE_R2.md`, `REGOLE_REDAZIONALI_COMBAT_R3.md`, `NOTE_ESAME_R1-R7.md`) — la fonte redazionale del Narratore indicata da Antonello il 02/09: le linee guida delle Missioni IA sono la base anche per l'Esame; le note dell'Esame sono l'addendum. `NOTE_ESAME_R1-R7.md` — le note di redazione approvate da Antonello (R1 reazioni ai colpi, R2 nessuna voce ai PG, R3 conseguenze verosimili senza formule) in attesa di consolidamento nel repertorio 0.4.0 e nel validatore; una nota nuova si aggiunge lì, non in un handoff.
2. `management/PNG_NARRATIVO_STANDARD.md` — lo standard dei PNG narrativi.
3. `management/analisi/ANALISI_ARCHITETTURA_NARRATIVA_IA.md` (29/08, otto proposte), `CAMPIONE_PONTE_GIOCATORE.md`, `CORPUS_UMANO_COME_SCUOLA.md`, `PIANO_QA_NARRATIVO_UNIFICATO.md`.
4. `management/coordination/HANDOFFS/TASK-AI-LINGUA-NARRAZIONE-CORE-018.md` + `-R2-IMPLEMENTAZIONE.md` + `-R2-AUDIT-USAGE.md`; `TASK-AI-ORCHESTRA-CANONICAL-LUNA-HIGH-145C.md`; `TASK-MISSION-NARRATORE-REAZIONI-COLPI-001.md` (nota approvata il 01/09, da integrare).
5. Registro `public.ai_agents` (kind, model, persona, is_active) — il provider è quello a database, mai dedotto da una riga scrivibile.
6. Memoria di progetto: `ai_lingua_repertorio_condiviso_018`, `provider_da_riga_scrivibile` (🔴), `corpus_reale_come_ancora`, `guardrail_fonte_vs_prompt_certificato`, `narratori_luna_046`.

## Stato vivo — aggiornato il 04/09/2026
- **`exam_genin_ai` 4.7.1/prompt30 LIVE**, `verify_jwt=false`, pacchetto riscaricato 9/9 byte-exact. Locale 189/189, checksum 9/9 e review indipendente 0/0/0.
- **Candidata `4.6.6-NU001-CANDIDATO`, prompt29**: alias nominativo esatto canonicalizzato fail-closed, tetti `11.798/8.848`, Luna/high e verbosity medium; 186/186, Deno/checksum 9/9 e review `0/0/0`. Edge QA v125 byte-exact. Ultima A–G **15/18**: A08/A09/A17 `max_tokens`; i 15 verdi hanno 438–1.159 caratteri e 0 qualità/avvisi. Gate produzione negato.
- **Gate 4.7.1**: vettore compatto ricomposto server-side, strict rimosso, tetto 1.024. Unico A08 QA verde; smoke LIVE completo con `testperfunzioni`, 10/10 cicli Luna/prompt30/stop, 0 ripieghi e 0 non conformi; chiusura isolata con XP 0 e grado invariato. Branch QA reso inerte; produzione resta attiva.
- **Confronto empirico su due esami**: preflight fermato prima del provider perché il branch non contiene due catene da tre cicli e il replay di agosto non conserva le azioni byte-exact. Luna 0/6, Terra 0/1, costo $0; nessun verdetto qualitativo aggiunto.
- Narratori Edge: `exam_genin_ai` LIVE 4.7.1/prompt30; branch QA sulla stessa revisione ma inerte, token ruotato, 0 prove aperte e 0 cicli non terminali. Gli altri non sono stati modificati né ricensiti.
- Provider: **unico**, `gpt-5.6-luna` con `reasoning: high` (142A/145B/145C: braccio unico, provider ritirato rimosso fisicamente). `OPENAI_API_KEY` è operativo anche sul branch QA; mai letto o stampato.
- Repertorio 018 R2 promosso (v0.3.0); caporali validati; `innesti.json` ricco. **Provato nel bundle v102 che l'innesto performativo NON arriva alla chiamata Surface del Narratore** (usa il proprio prompt dal seed, persona ridotta).
- Diagnosi del 29/08: coerenza raggiunta e provata; **espressività mancante per costruzione** (persona descrittiva senza esempi di voce, esito legato per famiglia, validazione per riferimento e non per contenuto); prosa del giocatore in quarantena → il Narratore non può riprendere l'azione descritta dal PG.

## Lavori aperti — in ordine
1. ✅ **Rilascio Narratore 4.7.1** — manifesto, review, A08, produzione e smoke completo conclusi.
2. **[P2] Portare il metodo a combat e missioni** — solo con un mandato separato, mantenendo ricevuta e validatore specifici per consumer.
3. **[P3] `TASK-AI-ITALIANO-COMUNE-001`** — il prerequisito dell'Esame stabile in produzione è ora soddisfatto; resta necessario un mandato dedicato.

## Parcheggiato — non riaprire senza mandato
- Proposte P2 (blocco voice nella persona), P3 (aprire 018 R2 — già promosso), P5 (audit corpus di ripiego 26–29/08), P6 (contesti orfani `narrative_context_exam/combat`), P7 (caporali — già validati), P8 (`prompt_version`).
- Programma 046 fase A (narratori → Luna): chiuso; i due candidati isolati non si distribuiscono perché nati sulla baseline.

## Decisioni chiuse — non ridiscutere
- «L'IA racconta, il server comanda»: nessun valore di gioco dall'IA; persona, fatti, frame e permessi sono autoritativi lato server.
- Una chiamata modello per ciclo; la risposta in ritardo si scarta; al modello arriva l'elenco già sfrondato.
- Il provider si risolve **prima** di spendere il gettone; `ai_agents.model` non è un instradatore.
- I due asterischi di `personas.json` sono contenuto e non si normalizzano.
- Le cinque IA non condividono memoria: ogni consumer riceve e prova esplicitamente il contratto.
- 03/09: architettura QA futura ratificata — controlli deterministici condivisibili; ricevute e referti come sola comunicazione; Narratori su Luna/high; giudice qualitativo asincrono offline su Terra/high, senza potere di pubblicare, mutare stato, rigenerare o decidere meccaniche; nessuna memoria condivisa gratuita e nessun consumer chiama un altro consumer.
- 03/09: per la revisione 4.3 il modello non certifica più ricevuta o provenienza e non vede raw/claim del giocatore; la Edge materializza gli identificatori e le fonti. Dialogo e ripresa del candidato restano sospesi finché il replay non certifica il contratto minimo.

## Trappole — lezioni della memoria di progetto che valgono qui
[[provider_da_riga_scrivibile]] · [[guardrail_fonte_vs_prompt_certificato]] · [[corpus_reale_come_ancora]] · [[ai_lingua_repertorio_condiviso_018]] · [[accademia_ia_blocco]] · [[scontrino_monouso]] · [[voce_narrativa_066_r2]]

## Prossimo passo
Nessun nuovo ciclo sul Narratore dell'Esame: 4.7.1 è verificata end-to-end. I consumer Combat e Missioni restano separati e richiedono un mandato proprio.
