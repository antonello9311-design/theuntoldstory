Stato: **in lavoro**

# Cantiere · NARRATORE-UNIFICATO — l'Esame sul modello della Ronda
Aperto il 02/09/2026 · passi 1–5 rilasciati · prova finale Test Room conclusa · resta il passo 6 (regolamento) · terzo cantiere in lavoro (tetto 3).

## Scopo
Portare la prosa dell'Esame Genin sul modello del «terzo livello» usato nella Ronda — ricevuta autoritativa → piano narrativo in 8 punti → Luna → validatore per riferimenti → pubblicazione — con le note di redazione R1–R6 e gli sfidanti dotati di scheda e personalità. **Voce: il Narratore in terza persona (Fato); il PNG parla dentro la narrazione**, non più come modello in prima persona. Il server resta l'unica autorità su esiti, danni, posizioni; la mossa del PNG la sceglie il modello fra le opzioni legali del server (R6).

## Stato operativo al 03/09/2026

- Passi 1–5 rilasciati con migrazioni 457–461. Head LIVE: `20260903111028 esame_narratore_unificato_005_bersaglio_dichiarato`; la zona dichiarata dal candidato prevale sul dado. Edge `exam_genin_ai` **v119 (`4.1.0-NU001`, prompt21)**, byte-verificata da Antonello/Claude, `verify_jwt=false`; prompt/contesto voce ampliati, minimi `azione_png >=1000` e branche `>=450`.
- Banco replay: 18 cicli, 17 accettati; resta un riferimento di qualità, non un'autorizzazione meccanica.
- Smoke Staff/Test Room concluso autoritativamente: prova `31491c15-7b5a-4385-913c-920b24d23acb` annullata/cancelled senza pending; sessione Accademia chiusa/cancelled; Test Room ancora attiva come luogo di prova ma con `is_academy=false`, `is_exam_room=false`; prove aperte globali 0; cicli narrativi 2/2 risolti. È uno smoke misto, non una certificazione qualitativa.
- Residuo del cantiere: passo 6, sincronizzazione `REGOLE.md` + `regole.html`. Player bridge strutturato, ampiezza delle manovre, memoria anti-ripetizione e validazione qualitativa sono lavori successivi separati, nella scheda `IA_NARRATIVA.md`.

## Fonti (in quest'ordine)
1. **`management/redazione/`** — `LINEE_GUIDA_NARRATIVE_R2.md` (la base: §5 PNG, §6 dialogo, §10 combattimento, §14 istruzione breve, §15 checklist), `REGOLE_REDAZIONALI_COMBAT_R3.md` (ferite dal fatto autorizzato, variazione delle conseguenze, struttura dell'esito, validazione bloccante), `NOTE_ESAME_R1-R7.md` (addendum dell'Esame e scelte decise). È la fonte indicata da Antonello per il Narratore d'esame.
2. `management/SCHEDE_SFIDANTI_ESAME.md` — i sei sfidanti: com'è oggi (DB), proposte e **riferimento visivo** trascritto dalle sei tavole di `management/sfidanti_esame/riferimenti/` (serie completa il 02/09).
3. `management/coordination/HANDOFFS/ARCHITETTURA-PNG-NINJA-BOOK-2026-09-02.md` §9–11 — il modello del terzo livello.
4. Edge viva `exam_genin_ai` v119 (`4.1.0-NU001`, prompt21), byte-verificata da Antonello/Claude, e `mission_narratore_ai` v9 (`beat_plan.mjs`, `player_bridge.mjs`, `regia_corpus.mjs`, `validator.mjs`).
5. `dossier/aree/ESAME.md` e `IA_NARRATIVA.md` — stato vivo e difetti misurati il 02/09.
6. `management/arene/` — tavole e schede delle aule d'esame di Konoha e di Suna (8 ancore per la Sostituzione, stesse posizioni; tabella scelta per villaggio in `_esame_luogo_prova()`).
7. Prova di riferimento: `esame_prove.id = 5c8dda6b-0259-401f-9ed1-a22825e67343` (Riuji vs Isamu, 12 cicli) + i 7 esami veri per il banco dei replay.

## Sequenza (uno alla volta, ogni passo chiude prima del successivo)
1. **Canone + schede** — ✅ note R1–R6 scritte; ✅ schede dei sei sfidanti scritte con proposte; ✅ sei tavole e due aule ricevute e trascritte (02/09); ✅ Antonello ha approvato le proposte di tutti e sei (02/09). **Passo 1 chiuso.**
2. ✅ **Ricevuta arricchita (P1)** — rilasciata nelle migrazioni 457–461: referto v2 e payload v5, aula per villaggio, 8 ancore, perimetro server-side [0,10], GRANT espliciti e bersaglio dichiarato prioritario sul dado.
3. ✅ **Personas** — i sei sfidanti sono dossier per il Narratore, senza coprifronte e allineati alle trascrizioni approvate.
3b. **Ritratti dei sei sfidanti** — oggi `ai_agents.avatar_url` è vuoto per tutti e sei (i 4 Sensei ce l'hanno, bucket `avatars/ai-<nome>-…`; i PNG del Ninja Book hanno i media). Le immagini le genera e carica Antonello dal brief «aspetto» delle schede; poi una migrazione di dati imposta i sei `avatar_url`; poi LAND-UI mostra il ritratto nella card dell'Esame (oggi la card non ha nessuna immagine: `esame_prova_stato.avversario` porta solo il nome — va aggiunto `avatar_url` in `_esame_stato_json`) e accanto ai messaggi del Narratore nei cicli PNG. Passo indipendente dagli altri: può andare in parallelo.
4. ✅ **Edge riscritta** — `exam_genin_ai` v119 (`4.1.0-NU001`, prompt21): piano narrativo, una chiamata Luna high, validatore per riferimenti, contesto voce ampliato; timeout modello 200 s.
5. ✅ **Banco sui replay** — 18 cicli, 17 accettati; latenza media 67 s, massima 134 s.
6. **Regolamento** — REGOLE.md + regole.html insieme (skill `gdr-regole-sync`): «la prova non toglie nulla davvero, ma la scena può mostrarlo».
7. ✅ **Distribuzione + smoke misto** in Staff/Test Room concluso; chiusura backend completa verificata (zero prove globali aperte, 2/2 cicli risolti). Non vale come certificazione qualitativa.

## Vincoli
- Nessun apply/deploy senza il sì di Antonello a ogni passo; il candidato di ogni passo sta in questa cartella, la revisione corrente sostituisce, la precedente va in `_precedenti/`.
- «L'IA racconta, il server comanda»: nessun valore di gioco dal modello.
- Il repertorio canonico 0.3.0 (`management/repertorio/`) è sigillato: le note entrano nel consolidamento 0.4.0, non a mano.
- La land: il pannello resta invariato in questo cantiere; il difetto «round che avanza prima dell'esito narrato» è di LAND-UI (scheda `ESAME.md`), non di questo cantiere.

## Difetti che questo cantiere chiude (misurati il 02/09)
voce inventata al candidato · formula «spezza il fiato» ripetuta (causa: validatore) · ferita inventata e propagata via `storia_narrativa` · congedo del Sensei in ripiego per «ferite» · sfidanti quasi muti.
