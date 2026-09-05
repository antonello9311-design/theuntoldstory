# AREA · IA narrativa — repertorio, voce, provider — scheda viva
Riscritta il 05/09/2026 · Codex NARRATORE-UNIFICATO · **Esame4.8/prompt31 LIVE v128 verificata; DB336/337 applicati; LAND007 caricata, dominio non attestato per blocco degli strumenti**

## Fonti fondamentali — in quest'ordine, solo il blocco che serve
1. `management/repertorio/README.md`, `MANIFESTO.json`, `GENERAZIONE.md`, `REFERTO_0_3_0.md`, `STORICO_VERSIONI.md` — **la fonte canonica** del repertorio condiviso di lingua e narrazione (v0.3.0, promosso). Le note di redazione sugli esiti vanno qui, non in un handoff.
1a. **Cantiere `management/candidati/NARRATORE-UNIFICATO_2026-09-02/`** (SCHEDA.md = sequenza in 7 passi) e **`management/SCHEDE_SFIDANTI_ESAME.md`** (sei schede, proposte da approvare).
1b. **`management/redazione/`** (README, `LINEE_GUIDA_NARRATIVE_R2.md`, `REGOLE_REDAZIONALI_COMBAT_R3.md`, `NOTE_ESAME_R1-R7.md`) — la fonte redazionale del Narratore indicata da Antonello il 02/09: le linee guida delle Missioni IA sono la base anche per l'Esame; le note dell'Esame sono l'addendum. `NOTE_ESAME_R1-R7.md` — le note di redazione approvate da Antonello (R1 reazioni ai colpi, R2 nessuna voce ai PG, R3 conseguenze verosimili senza formule) in attesa di consolidamento nel repertorio 0.4.0 e nel validatore; una nota nuova si aggiunge lì, non in un handoff.
2. `management/PNG_NARRATIVO_STANDARD.md` — lo standard dei PNG narrativi.
3. `management/analisi/ANALISI_ARCHITETTURA_NARRATIVA_IA.md` (29/08, otto proposte), `CAMPIONE_PONTE_GIOCATORE.md`, `CORPUS_UMANO_COME_SCUOLA.md`, `PIANO_QA_NARRATIVO_UNIFICATO.md`.
4. `management/coordination/HANDOFFS/TASK-AI-LINGUA-NARRAZIONE-CORE-018.md` + `-R2-IMPLEMENTAZIONE.md` + `-R2-AUDIT-USAGE.md`; `TASK-AI-ORCHESTRA-CANONICAL-LUNA-HIGH-145C.md`; `TASK-MISSION-NARRATORE-REAZIONI-COLPI-001.md` (nota approvata il 01/09, da integrare).
5. Registro `public.ai_agents` (kind, model, persona, is_active) — il provider è quello a database, mai dedotto da una riga scrivibile.
6. Memoria di progetto: `ai_lingua_repertorio_condiviso_018`, `provider_da_riga_scrivibile` (🔴), `corpus_reale_come_ancora`, `guardrail_fonte_vs_prompt_certificato`, `narratori_luna_046`.

## Stato vivo — aggiornato il 05/09/2026
- **LIVE verificata direttamente**: singolo deploy `exam_genin_ai` v128,4.8.0/prompt31,ACTIVE/JWTfalse. Download10/10 byte-exact al manifesto `71535d50ce8ee07cf41c193e45ff3f6343dda635df062f6012d4a6b97cce58f4`; bundle remoto `d7b7466fa9903a3232b38d8806849989249ded3b7e15f2d4427e2fb2ffa138ee`. Unico smoke impronta HTTP200,0provider/SQL, promptSHA `c4009b3394b62b35ba724d6068c8323f23e3358892734eac9395d23958564075`.
- **4.8/prompt31 distribuita**:22 gruppi editoriali condivisi in sistema attivo, piano, brief e giudice; prosa diretta Luna/high e controllo Terra/high bloccante. Tetti14.158/10.618, giudice4096; due chiamate al massimo, conteggiate effettivamente. Nessun nuovo smoke narrativo completo o attestazione zero fallback.
- **Review unica e correzione aggregata**: primo referto0/3/2, controverifica finale0/0/0. Suite201/201, orchestrazione simulata1/1 e LAND8/8. Gate integrato DB16/16 e quattro payload NATIVI4/4 in93ms,0provider; tutti png_esito ciclo/replay Konoha bound e Suna legacy, non quattro ruoli.
- **Dipendenze integrate LIVE**: DB-CORE ha applicato una volta codice20260904233136 e seed20260904233137, SHA95472cf8/2fcab661 esatti; postflight33corpi/ACL verdi dopo ciascuno. Konoha10x10,8oggetti,2slot,1binding e1route abilitata; Suna resta legacy. Runtime prima/dopo invariato e0esamiaperti. Evidenza `QA-BRANCH-BASELINE-REPAIR_2026-09-04/referti/PRODV5_LIVE_APPLY_RESULT.json`, SHA0c0edb96. Nessuna geometria Suna nuova.
- **Provenienza card esplicita**: adattamento del catalogo jutsu LIVE, non revisione editoriale inventata. effect duplicato in descrizione/effetto; action_type indica solo tipologia. Vecchi limits della Sostituzione esclusi; distanze dalla ricevuta common/server. Sigilli generici della Sostituzione autorizzati da Antonello come licenza redazionale separata, identica per Luna/Terra, senza nuove sequenze o regole.
- **LAND**: scelta dell'ancora tramite option_id opaco, build LAND-ESAME-ANCHOR-OPTION-007,706117B,SHA c241f571d543214d6ca6c5ea4dbbe7e00fafbf0e431bcb0a5b65bfdd2ce144e5; caricata in root GitHub commit445bdd7304af95456f32bcf9e47aaed31b25884d. Review0/0/0 e8/8, riconciliazione remota verde. Verifica diretta dominio non attestata: accesso bloccato dagli strumenti, nessun aggiramento.
- **Evidenze storiche**: 4.7.1 smoke LIVE10/10 senza ripieghi; QA spaziale receipt37f90c5f, 12 gruppi/24 assert con rollback. Anteprime private conservate, non template e non prove del runtime 4.8.
- Repertorio canonico 0.3.0 invariato. Gli altri narratori non sono stati modificati né ricertificati.

## Lavori aperti — in ordine
1. **[P1] Verifica dominio LAND** — resta non attestata per bloccoURL degli strumenti. DB/Edge sono distribuiti e verificati, LAND caricata; commit e verifiche delle sorgenti/docs selettive nel registro PUBBLICAZIONE. Nessun nuovo esame o campagna stilistica; Tamako viene avviata da Antonello, non da questi task.
2. **[P2] Portare il metodo a combat e missioni** — solo con un mandato separato, mantenendo ricevuta e validatore specifici per consumer.
3. **[P3] `TASK-AI-ITALIANO-COMUNE-001`** — resta necessario un mandato dedicato.

## Parcheggiato — non riaprire senza mandato
- Proposte P2 (blocco voice nella persona), P3 (aprire 018 R2 — già promosso), P5 (audit corpus di ripiego 26–29/08), P6 (contesti orfani `narrative_context_exam/combat`), P7 (caporali — già validati), P8 (`prompt_version`).
- Programma 046 fase A (narratori → Luna): chiuso; i due candidati isolati non si distribuiscono perché nati sulla baseline.

## Decisioni chiuse — non ridiscutere
- «L'IA racconta, il server comanda»: nessun valore di gioco dall'IA; persona, fatti, frame e permessi sono autoritativi lato server.
- 4.7.1 usava una chiamata; Esame4.8 distribuita usa Luna più giudice Terra bloccante, senza retry automatico. Il programma QA comunicante futuro, asincrono e offline, resta distinto e non realizzato.
- Il provider si risolve **prima** di spendere il gettone; `ai_agents.model` non è un instradatore.
- I due asterischi di `personas.json` sono contenuto e non si normalizzano.
- Le cinque IA non condividono memoria: ogni consumer riceve e prova esplicitamente il contratto.
- 03/09: architettura QA futura ratificata — controlli deterministici condivisibili; ricevute e referti come sola comunicazione; Narratori su Luna/high; giudice qualitativo asincrono offline su Terra/high, senza potere di pubblicare, mutare stato, rigenerare o decidere meccaniche; nessuna memoria condivisa gratuita e nessun consumer chiama un altro consumer.
- 03/09: per la revisione 4.3 il modello non certifica più ricevuta o provenienza e non vede raw/claim del giocatore; la Edge materializza gli identificatori e le fonti. Dialogo e ripresa del candidato restano sospesi finché il replay non certifica il contratto minimo.

## Trappole — lezioni della memoria di progetto che valgono qui
[[provider_da_riga_scrivibile]] · [[guardrail_fonte_vs_prompt_certificato]] · [[corpus_reale_come_ancora]] · [[ai_lingua_repertorio_condiviso_018]] · [[accademia_ia_blocco]] · [[scontrino_monouso]] · [[voce_narrativa_066_r2]]

## Prossimo passo
Seguire PUBBLICAZIONE per commit/verifiche dei caricamenti selettivi e lasciare esplicita la verifica dominio LAND non attestata. La futura prova narrativa Tamako è manuale di Antonello, non avviata da questi task; i verdi tecnici non sono una nuova certificazione provider.
