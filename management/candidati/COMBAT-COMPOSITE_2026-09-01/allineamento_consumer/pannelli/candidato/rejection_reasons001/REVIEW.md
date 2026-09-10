# Review indipendente delle motivazioni di rifiuto · 001

COMBAT-PANEL-REJECTION-REASONS-REVIEW-001 · QA-INDEPENDENT · 10/09/2026. **Verdetto: 0 P0 / 0 P1 / 1 P2.** Unico passaggio statico sulla candidata congelata; campagna non eseguita. Nessuna modifica al prodotto.

## Finding aggregato

**RR-01 · P2 · Spiegazione della cardinalità incompleta.** `INSTALL.sql:83`, voce `panel_choice_cardinality_or_dependency_invalid` in `BASELINE.json.mapping`, promette «Manca una scelta richiesta oppure sono selezionate opzioni che dipendono da una scelta diversa». La fonte autentica `multiplication_assault_smoke011/DIAGNOSIS.json → metadata002.functions[4].definition`, `combat_panel_private.resolve_selections`, righe interne 37–40, solleva la stessa causa quando `selected_count > g.max_selected`, oltre a quantità insufficiente e gruppo inattivo. Per una selezione eccessiva in un gruppo attivo entrambe le spiegazioni offerte sono false; il giocatore non riceve l'indicazione necessaria a correggersi. È il significato del controllo già incluso nella mappa, non un nuovo caso di gioco.

Correzione richiesta al proprietario: rendere la stessa spiegazione comprensiva anche dell'eccesso di scelte, senza affermare quale ramo sia fallito; mantenere un'unica causa letterale, lo stesso code/recovery e la mappa sorgente generatrice. Non servono nuovi errori, regole, esempi o sottocasi QA. Ricostruire gli artefatti dipendenti nella sola aggregata; il reviewer non modifica il codice.

## Riscontri positivi

- Sette file congelati e due fonti di provenienza con byte/SHA corrispondenti. MANIFEST `ed547622a76377e9a10fb32fddae461c97b671d2c0e74f941853608f349559f6`; INSTALL `244a75dd746a5ec1d14dbd3daafca3ff1836d0ba5ccf03f5505bceca39a631af`; RECOVERY `d4365bdccf6acd6274021cf2c159c05b2e8e7f07b8dc5148f3ad02037f695dbc`.
- Il confronto autonomo delle definizioni accerta un solo blocco modificato: valore di `message` quando `code=selection_rejected`. Rimuovendo quel blocco e reinserendo l'assegnazione precedente si ottiene il BEFORE byteesatto; il corpo in RECOVERY è lo stesso BEFORE. MD5 BEFORE `84860632d828931cea773b83c583548e`, AFTER `bd5fc563e3cd83a8912c79e9bcdce3c2`.
- Tutte le 40 cause distinte compaiono come eccezioni letterali nelle definizioni congelate010/011; letti i predicati pertinenti. Il CASE usa uguaglianza completa di SQLERRM: nessun LIKE/regex/suffisso per associare cause, nessuna concatenazione o restituzione del messaggio grezzo. Il LIKE22% preesistente riguarda esclusivamente la classificazione SQLSTATE ed è invariato. Fallback sconosciuto byteidentico; UUID, testo privato e JSON arbitrario non vengono proiettati dalla nuova mappa.
- Ordine authentication → request_key_conflict → not_authorized → context_changed → selection_rejected preservato. PGRST di `combat_v2_fail` resta operation_rejected; non si legge o copia il JSON message_it/details. Firma, sei campi API, key, recovery, request fingerprint, advisory lock, replay, dispatch Movimento/ordinary/Master/Clone/Moltiplicazione e intero confine EXCEPTION restano identici. L'handler resta fuori dalla sottotransazione delle operazioni rifiutate.
- INSTALL e RECOVERY delimitano ciascuno una transazione e un solo CREATE OR REPLACE. Pre/post pin del gateway e di combat_v2_fail includono corpo, owner, ACL, search_path, security_definer e volatilità. Nessun GRANT/REVOKE/ALTER o dato prodotto modificato. La recovery pretende AFTER e dipendenza autentici, poi ripristina BEFORE senza cleanup di dati, receipt o storia. L'advisory lock resta cooperativo: esclusiva reale e controllo di drift devono essere mantenuti al gate.
- BUILD letto staticamente: pin delle fonti e dei documenti, ancoraggio unico, cause autentiche, escape SQL dei letterali, controllo inverso e limiti della migrazione coerenti con il prodotto. Il reviewer non ha eseguito il generatore né attestato da sé le due generazioni riferite dall'owner.

## Valutazione del piano QA già congelato

La matrice proposta è proporzionata al delta: 4 gruppi, massimo 9 sottocasi, 9 submission totali compreso setup, 10 minuti, un run, zero provider/browser. Copre installazione pin/ACL, validatore nativo, rollback della sentinella dopo errore del dispatcher, fallback privato e precedenze40001/PGRST/request_key_conflict, successo/replay, recovery COMMIT e conservazione dati. È sufficiente come piano di componente dopo RR-01, senza ampliamento di matrice; **non è ancora autorizzazione al run né prova superata**.

Il gateway integrale, validate_command e combat_v2_fail devono essere corpi nativi pinzati. La sola frontiera del dispatcher sintetica è ammessa per provocare i rami dell'handler e verificare rollback; la sentinella non qualifica Moltiplicazione, costi, Auth o il motore. Per successo/replay deve essere osservabile l'effetto singolo nella frontiera e la ricevuta usata dal vero gateway. Non basta eseguire il CASE isolato o confrontare il dizionario.

Prima dell'esecuzione il runner deve congelare container/database nuovo, DDL/fonti helper richiesti, disponibilità dei ruoli, eventuale configurazione Auth esclusivamente sintetica dichiarata, confini delle nove submission e deadline. Il piano vieta di sostituire validatori, alterare il gateway, indebolire pin o correggere il setup durante la campagna. Se queste precondizioni non si chiudono il run resta NOT_RUN. Il budget nove è un massimo e comprende creazione/setup, non nove prove oltre al bootstrap. I rischi Auth/API/RLS, UI reale, geometria, provider e causa011 sono esplicitamente esclusi.

## Consegna al PM

Rilievi finali aggregati: solo RR-01 P2. Nessuna patch o microdialogo del reviewer; segue la correzione aggregata e la controverifica assegnate dal PM, sugli stessi criteri. Fino ad allora manca il requisito review0/0/0. Anche un successivo verde statico non autorizza produzione: qualifica PostgreSQL, preflight fresco, recovery e gate nominativo restano successivi.

Consumo di questa review: zero query, SQL, test, Docker, browser e provider; sole letture e confronti statici di testo/impronte. Nessuna attribuzione della causa di Assalto011 e nessuna modifica delle candidate UI indipendenti o privateUI003.
