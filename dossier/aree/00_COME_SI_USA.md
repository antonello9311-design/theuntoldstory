# Le schede d'area — come si usano

> Una scheda per area, riscritta in posto. Tetto: **150 righe**. Numeri e stati hanno data, fonte e perimetro: la scheda non sostituisce il database o il sito pubblicato. Il processo del punto 2 è in `management/coordination/AVVIO_LAVORO.md`: mandato, scope, prenotazioni, dipendenze e consegna.

## Chi avvia una task fa così
1. Leggere `AGENTS.md`, poi `dossier/00_LEGGIMI.md`, `dossier/CONTESTO.md`, `dossier/01_STATO_ATTUALE.md` e `dossier/04_LAVORI_APERTI.md`. Il tabellone si riscrive in posto: si legge il quadro corrente, non si cerca una presunta ultima appendice datata.
2. Individuare l'area nella tabella sotto e leggere la sua scheda. Se il lavoro attraversa un contratto condiviso, leggere anche le aree interessate nel solo perimetro necessario e rispettarne gli owner.
3. Se esiste un cantiere, leggere `SCHEDA.md` e `HANDOFF.md`: mandato, avanzamento, prove, limiti e prossimo passaggio. Durante la transizione di `AGENTS.md`, `lavori/<CANTIERE>/` indica `management/candidati/<CANTIERE>/` e `sito/` indica `sito_live/`. Poi aprire le fonti elencate dalla scheda, nell'ordine e **solo nei blocchi pertinenti** (`rg -n` e intervallo di righe).
4. Consultare `dossier/02_INDICE_DOCUMENTI.md` solo per recuperare una fonte mancante, una decisione, una dipendenza o una contraddizione precisa. Non è una lettura integrale obbligatoria dell'archivio o delle task precedenti. Una proposta o un mandato storico non è un nuovo incarico; una decisione superata conserva il contesto ma non dirige il lavoro corrente.
5. Prima di dichiarare lo stato attuale del backend, verificarlo con letture pertinenti secondo `gdr-verifica`; il DB vince sul documento e il sito pubblicato su `sito_live/`. In un'analisi soltanto documentale indicare esplicitamente fonte e data del checkpoint, senza presentarlo come nuova verifica live. Per scrivere valgono scope autorizzato e owner esclusivo: se il file è cambiato dall'ultima lettura, fermare quella scrittura e coordinare il passaggio.

## Quale scheda apre quale argomento
| Se il task parla di… | Scheda |
|---|---|
| esame, prova Genin, PNG d'esame, `esame_*`, `exam_genin_ai`, tick, monitor | `ESAME.md` |
| scontro, combattimento, Regia, Master V2, `combat_v2_*`, `master_v2_*`, distanze, sostituzione, moltiplicazione, diversivo, AoE, difesa, danni | `COMBAT.md` |
| missione, Nodo Azzurro, Narratore delle missioni, Ninja Book, `nb_*`, `mission_*`, PNG dinamici, Tetsuma/Nao, canary, coordinator | `MISSIONI_IA.md` |
| clan, innata, Byakugan, Sabaku, Nara, tecniche di clan, elementali Genin, kekkei genkai | `CLAN.md` |
| accademia, lezione, Deshi, Sensei IA, `academy_*` | `ACCADEMIA.md` |
| allenamento, Training V2, Sensei dell'allenamento, `training_*`, imparare una tecnica | `TRAINING.md` |
| Test Room, Staff Test Room, Manichino, simulazione, isolamento, `test_room_ai` | `TEST_ROOM.md`, più l'area della funzione provata |
| narratore, voce, persona, repertorio, prompt, provider, lingua, esiti narrativi e memoria della scena | `IA_NARRATIVA.md`, più l'area del prodotto interessato |
| PNG Builder, modello comune e raccordi dei PNG | `MISSIONI_IA.md` e `PIATTAFORMA.md`, poi il prodotto che lo usa |
| land.html, scheda.html, admin.html, regole.html, leggibilità, pannello, legenda, CSS, refactor | `PAGINE.md` |
| caricare su GitHub, cosa è online, SHA, build, REGOLE.md + regole.html, changelog | `PUBBLICAZIONE.md` |
| database, migrazione, cron, Edge, RLS, advisor, GRANT, candidati, archiviazione, ambienti di prova, processo di lavoro e coordinamento | `PIATTAFORMA.md` |

## Lo scheletro della scheda
```
# AREA · Nome — scheda viva
Riscritta il … · da … · stato e perimetro …
## Fonti fondamentali — in quest'ordine, solo il blocco che serve   (max 7)
## Stato vivo — fonte e data della verifica o del checkpoint
## Lavori aperti — in ordine                                      (max 10, priorità e owner)
## Parcheggiato — non riaprire senza mandato
## Decisioni chiuse — non ridiscutere
## Trappole — lezioni pertinenti della memoria di progetto
## Prossimo passo                                                (uno solo)
```

Lo stato della singola candidata segue `AGENTS.md`: proposto / in lavoro / applicato inerte / in uso / chiuso / parcheggiato. «In uso» lo dichiara Antonello. La scheda distingue sorgenti pronte, apply, deploy, enable, verifica sul sito e apertura generale; non riduce tutti i prodotti dell'area a un unico verde. Un PASS circoscritto non chiude altri rossi né certifica casi non eseguiti.

## A fine sessione, per Claude e Codex
- Riscrivere le sezioni effettivamente cambiate nel perimetro assegnato: «Stato vivo», «Lavori aperti», «Prossimo passo». Conservare decisioni, limiti e prove ancora utili, correggendo sul posto le istruzioni superate.
- Registrare ogni cambiamento operativo di cron, flag, gate, Edge o migrazione in «Stato vivo», anche se è già nell'handoff; per le migrazioni aggiornare `PIATTAFORMA.md`. Fonte e data distinguono quanto verificato direttamente da quanto attestato dall'owner.
- Aggiornare `SCHEDA.md`, `HANDOFF.md` e la riga di `STORICO.md` del cantiere secondo `AGENTS.md`; registrare pubblicazione e verifica quando effettuate. Questo non autorizza scritture su file riservati a un altro owner.
- Una decisione chiusa conserva data e perimetro; un lavoro sospeso conserva motivo e condizione di ripresa. Le prove terminali rimangono tali finché il PM non assegna il seguito previsto, senza cancellarne gli esiti.
- Niente nuove appendici datate, sezioni «Rettifica» o duplicati delle schede. La cronologia già presente nel cantiere e in `dossier/storico/` conserva il dettaglio storico; non si crea un nuovo archivio per ogni sessione.
