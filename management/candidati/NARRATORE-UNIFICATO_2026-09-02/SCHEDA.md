Stato: **applicato inerte**

# Cantiere · NARRATORE-UNIFICATO — l'Esame sul modello della Ronda
Aperto il 02/09/2026 · revisioni precedenti conservate in `_precedenti/` · revisione 4.7.1/prompt30 pubblicata in produzione e verificata · A08 QA verde · smoke completo Test Room verde senza ripieghi.

## Scopo
Portare la prosa dell'Esame Genin sul modello del «terzo livello» usato nella Ronda — ricevuta autoritativa → piano narrativo in 8 punti → Luna → validatore per riferimenti → pubblicazione — con le note di redazione R1–R6 e gli sfidanti dotati di scheda e personalità. **Voce: il Narratore in terza persona (Fato); nella candidata 4.5.0 il dialogo resta sospeso per tutti finché il contratto minimo non supera il replay**, mentre personalità e tattica passano da corpo, ritmo e ambiente. Il server resta l'unica autorità su esiti, danni e posizioni; la mossa del PNG la sceglie il modello fra le opzioni legali del server (R6).

## Stato operativo al 04/09/2026

- Passi 1–5 restano attivi. La head DB documentata resta `20260903203601 esame_narratore_finale_ampiezza_006_recovery`; nessuna migrazione nuova. Edge LIVE aggiornata il 04/09 alla revisione `4.7.1-NU001-CANDIDATO`/prompt30, `verify_jwt=false`.
- Revisione corrente `4.7.1-NU001-CANDIDATO`, prompt30: sostituisce l'output strict annidato con un vettore minimo di ID; ordine di azione e rami, cardinalità, domini ed estensioni sono ricostruiti e validati server-side. Wire pubblico invariato; Luna `reasoning=high`, `verbosity=medium`, una chiamata e tetto output uniforme **1.024**. Suite **189/189**, checksum **9/9**, review indipendente **`0/0/0`**. Edge QA e produzione riscaricate e confrontate **9/9 byte-exact**.
- Gate dinamico concordato: unico A08 sul branch, HTTP 200, Luna/prompt30, stop normale, 1 chiamata, 0 motivi/qualità/avvisi e nessun fallback. Branch poi reso inerte con token ruotato, 0 prove aperte e 0 cicli non terminali.
- Smoke completo LIVE con `testperfunzioni`: sessione `b4ea7ece…`, prova `7dfe2fef…`, apertura → combattimento → uscita → chiusura. **10/10 cicli risolti** (`png_difende` 4, `png_attacca` 3, `png_esito` 2, `png_finale` 1), tutti `gpt-5.6-luna`, prompt30 e `stop`; **0 ripieghi e 0 non conformi**. Prova `conclusa|done`, sessione `closed|done`, esito `solida`, chiusura isolata, XP 0 e grado invariato. Test Room ripristinata `is_test=true`, `is_active=true`, `is_academy=false`, `is_exam_room=false`; 0 prove aperte, 0 cicli attivi, cron `esame-tick` acceso. Mai Riuji.
- Banco storico: 18 cicli, 17 accettati sulla v120, utile solo come riferimento. Replay della candidata v121: 18 cicli A–G, 17 risposte HTTP e **0/17 accettate**, più un 504; 124 rilievi bloccanti aggregati. Referto: `referti/REPLAY_LIVE_V121.md`.
- Smoke Staff/Test Room concluso autoritativamente: prova `31491c15-7b5a-4385-913c-920b24d23acb` annullata/cancelled senza pending; sessione Accademia chiusa/cancelled; Test Room ancora attiva come luogo di prova ma con `is_academy=false`, `is_exam_room=false`; prove aperte globali 0; cicli narrativi 2/2 risolti. È uno smoke misto, non una certificazione qualitativa.
- Il fallimento 4/18 è stato corretto senza liste di sinonimi né casi ad hoc: il brief espone obblighi chiusi per ruolo; esito risolto, nuova intenzione e branche ricevono fonti distinte; i tetti finali sono 9.831 token per i ruoli con branche e 7.373 per gli altri; il riconoscitore distingue il lessico autoritativo ambientale dal suo uso come persona. Il canary e il programma QA condiviso Esame + Missioni non sono partiti; il passo 6 (`REGOLE.md` + `regole.html`) resta separato.
- Certificazione conclusiva 4.6.1 sulla Edge QA **v120**: 18/18 casi A–G verdi, una chiamata ciascuno, nessun retry, 0 motivi/qualità/avvisi; output 183–521 token, totale 15.048 input, 4.932 output, 3.379 reasoning; latenza media 3.688 ms, massima 5.798 ms. Postflight: 0 prove aperte, 0 azioni senza esito, 0 cicli non terminali; token runtime ruotato. Produzione v123/recovery `ACTIVE`, 0 prove aperte e `esame-tick` attivo.
- La 4.6.1 è stata poi distribuita in produzione come Edge **v125**. Primo smoke reale controllato con `testperfunzioni`: apertura riuscita e primo `png_difende` Luna verde; il successivo `png_attacca` è caduto in ripiego per alias nominativo dell'iniziativa fuori vocabolario. Prova e sessione chiuse senza pending, zero XP; mai usato Riuji. La 4.6.2 ha corretto esattamente quel trasporto.
- Ultimo gate autorizzato sulla 4.6.6/QA v125: **15/18 pulite**, una chiamata per caso, zero qualità/avvisi sui 15 verdi; azioni verdi 438–1.159 caratteri. A08 `png_difende`, A09 e A17 `png_attacca` hanno saturato esattamente 11.798 output token (`max_tokens`, 65.818–68.626 ms). Totali 15.082 input, 39.193 output, 2.768 reasoning; latenza media 14.374 ms. PM: STOP, nessun deploy produzione e nessun nuovo smoke; branch reso inerte, 0 prove aperte e 0 cicli non terminali.
- QA bounded su due esami reali (04/09): selezionati `2399b1fa…` e `23d4ccf1…`, con sei cicli deterministici già identificati. **Campagna non avviata**: il branch contiene un solo snapshot per ciascuna delle due prove e i replay di agosto non conservano l'azione byte-exact (`contesto_pg` vuoto e messaggi non risolvibili). 0 chiamate Luna, 0 Terra, costo $0; produzione e branch invariati. Referto: `referti/CONFRONTO_DUE_ESAMI.md`.

## Fonti (in quest'ordine)
1. **`management/redazione/`** — `LINEE_GUIDA_NARRATIVE_R2.md` (la base: §5 PNG, §6 dialogo, §10 combattimento, §14 istruzione breve, §15 checklist), `REGOLE_REDAZIONALI_COMBAT_R3.md` (ferite dal fatto autorizzato, variazione delle conseguenze, struttura dell'esito, validazione bloccante), `NOTE_ESAME_R1-R7.md` (addendum dell'Esame e scelte decise). È la fonte indicata da Antonello per il Narratore d'esame.
2. `management/SCHEDE_SFIDANTI_ESAME.md` — i sei sfidanti: com'è oggi (DB), proposte e **riferimento visivo** trascritto dalle sei tavole di `management/sfidanti_esame/riferimenti/` (serie completa il 02/09).
3. `management/coordination/HANDOFFS/ARCHITETTURA-PNG-NINJA-BOOK-2026-09-02.md` §9–11 — il modello del terzo livello.
4. Edge viva `exam_genin_ai` v123, sorgente byte-identica alla recovery (`4.1.0-NU001`, prompt21), e candidata locale `candidato/edge/` (`4.5.0-NU001-CANDIDATO`, prompt28, contratto DB5); il branch QA ospita la stessa revisione come v117 per il mandato mirato; `mission_narratore_ai` resta solo fonte di metodo.
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
8. ⚠️ **Candidata qualitativa v121 ritirata** — il gate generativo ha prodotto 0/17 cicli validi e un 504; recovery completato su Edge e DB, copia intatta in `_precedenti/2026-09-03_v121_ritirata/`.
9. ✅ **Revisione conclusiva** — 4.7.1 generalizza il trasporto compatto a tutti i ruoli e ai rami senza cambiare il wire; 189/189, checksum 9/9, review 0/0/0, A08 QA verde, produzione byte-exact e smoke completo 10/10 senza ripieghi.
10. **QA empirico su due esami** — ⛔ preflight chiuso senza generazioni: il corpus QA non offre due catene da tre cicli e non conserva le azioni byte-exact dei cicli di agosto. Serve fonte autoritativa già depositata oppure autorizzazione separata alla materializzazione di fixture immutabili sul branch.

## Vincoli
- Nessun apply/deploy senza il sì di Antonello a ogni passo; il candidato di ogni passo sta in questa cartella, la revisione corrente sostituisce, la precedente va in `_precedenti/`.
- «L'IA racconta, il server comanda»: nessun valore di gioco dal modello.
- Il repertorio canonico 0.3.0 (`management/repertorio/`) è sigillato: le note entrano nel consolidamento 0.4.0, non a mano.
- La land: il pannello resta invariato in questo cantiere; il difetto «round che avanza prima dell'esito narrato» è di LAND-UI (scheda `ESAME.md`), non di questo cantiere.

## Difetti che questo cantiere chiude (misurati il 02/09)
voce inventata al candidato · formula «spezza il fiato» ripetuta (causa: validatore) · ferita inventata e propagata via `storia_narrativa` · congedo del Sensei in ripiego per «ferite» · sfidanti quasi muti.

## Prossimo passo
Il ciclo tecnico Narratore 4.7.1 è concluso. Resta separato il passo 6 di regolamento (`REGOLE.md` + `regole.html`) e gli altri lavori già elencati nell'area Esame; lo stato «in uso» della revisione resta una dichiarazione di Antonello.
