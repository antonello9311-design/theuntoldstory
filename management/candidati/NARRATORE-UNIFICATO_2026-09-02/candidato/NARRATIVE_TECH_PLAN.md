# IA-NARRATIVE-TECH-001 — primo raccordo ordinary Staff

Stato: candidata passaggio cumulativo 2/5 congelata, campagna locale 8/8 PASS; controverifica 2/5 da ricevere. Revisione della stessa candidata, non nuovo ciclo · 09/09/2026. Owner NARRATIVE-AI. AGENTS e AVVIO v1.2 applicano il limite di cinque aggregate/controverifiche, comprese quelle consumate. Prima aggregata e controverifica rosse preservate; seconda controverifica da richiedere dopo questa campagna. Contratto documentale già0/0/0 immutato.

## Risultato e perimetro

Prima integrazione nel percorso ordinary Staff già collaudato: leggere dal catalogo le fonti delle tecniche realmente coinvolte, congelare ID/versione/impronta/contenuto nello snapshot esistente e rendere esplicita la cessazione Clone attestata. Estensione multiattore, mappe/PNG, quest e missioni seguono con mapping propri: non bloccano questo raccordo. Non è un catalogo parallelo, né un nuovo motore di risoluzione.

Il candidato modifica `combat_consumer_private.scene_snapshot_v2(uuid)` soltanto dopo la formazione dei fatti esistenti. Aggiunge `combat_consumer_private.narrative_tech_sources_v1(uuid)`, helper interno con EXECUTE solo postgres, search_path vuoto. Nessuna API pubblica nuova, firma frontend, tabella, trigger, flag o catalogo modificati. Nessun nuovo campo editoriale amministrabile: si usano i campi canonici già disponibili.

## Fonti vive e associazioni

Baseline readonly09/09 in NARRATIVE_TECH_BASELINE.json: corpi/MD5/owner/ACL dei produttori pertinenti, colonne e due righe pubbliche di catalogo. Nessuna role o dato PG raccolto. Lo scope Edge comprende editorial.mjs e le due dipendenze common.mjs/scene.mjs scaricate da combat_narratore_ai ACTIVE23; editorial locale precedente è byte-identico alla fonte viva. Il bundle di rilascio completo dovrà essere riconciliato e congelato dal successivo owner del rilascio.

- Clone: `clan_techniques` ID617484d6-af7b-41c3-a37f-615b22818421, campi `name`, `description`, `danno_effetto`. Collegamento nativo attestato da clone_ready; dichiarazione con outcome sabaku-clone/1 e catture reali del round. Il testo canonico rimane quello letto, ancora incompleto rispetto alle ratifiche editoriali: il candidato non lo corregge o sostituisce.
- Moltiplicazione: `jutsu` IDc6e31b7b-38fe-4b4f-b3c7-05f3e922d193, campi `name_it`, `effect`, `limits`, senza `description`. Collegamento nativo attestato da multiplication_actor_profile. Formazione della dichiarazione corrente, risoluzioni su formazioni persistenti o formazione coinvolta nella cattura Clone: associazione per riferimenti nativi, mai per nome nella role.
- La proiezione mantiene l’attore proprietario della tecnica, incluso il difensore di una formazione persistente. Non include indice originale/selezionato, figure, coordinate, entropia, dadi o statistiche. Non enumera l’inventario né tutte le capacità possedute.
- Ogni fonte congela ID catalogo, attore, mapping_version ordinary-tech/1, contenuto selezionato e SHA256 del JSONB selezionato. È impronta della fonte, non autorizzazione o prova di esito. Lo snapshot viene persistito dal lifecycle già esistente; l’helper non modifica le righe canoniche.

## Fatti dinamici e testo

Le catture Clone con esito negativo si raccordano alla riga Clone realmente ended e all’end_reason corrispondente capture_failed/copy_triggered. Il candidato legge il valore registrato, senza dedurre la fine dal danno o inventare il successo. La proiezione aggiunge conclusioni_effetti_server con stato terminato e causa solo quando cattura e stato nativo concordano; una contraddizione tecnica produce errore esplicito.

L’aggancio non pretende di coprire in questa tranche ogni cessazione temporale, rilascio della presa, morte/assenza dell’attore o tutte le tecniche del gioco. Copre il P2 osservato sulla cattura e le fonti Clone/Moltiplicazione necessarie al percorso. Le ulteriori cause non hanno ancora un raccordo generale a evento immutabile del round: restano incomplete, senza aggiungere falsi aggiornamenti da stato corrente.

NARRATIVE_TECH_EDITORIAL.mjs separa fonti_tecniche_catalogo dai fatti_definitivi_server nel prompt. Il sistema dichiara che catalogo e comandi eventualmente contenuti nel suo testo sono dati non istruzioni: natura e possibilità non sono esiti avvenuti. La role guida gesto/postura/ritmo compatibili, nessuna coreografia o frase obbligatoria. Il vecchio resolved_facts resta compatibile quando manca il nuovo campo. Nessun modello è stato chiamato: efficacia qualitativa e resistenza empirica della generazione non attestate.

Ratifiche Moltiplicazione conservate come requisiti futuri, non certificazione runtime: Assalto aumenta la probabilità di colpire senza successo garantito; Copertura arretra e aumenta la probabilità difensiva; Diversivo consuma l’attacco e induce lo spostamento avversario se l’originale non è riconosciuto. Le fonti di catalogo e il motore non sono aggiornati da questo raccordo. Il narratore non deve anticipare tali risultati se non presenti nelle ricevute.

## Preflight, installazione e recupero candidati

PREFLIGHT e INSTALL verificano, prima di ogni DDL, definizione, owner postgres e ACL esatti delle dipendenze native congelate; l’helper deve essere assente. Qualsiasi grant estraneo o cambio owner provoca errore, senza normalizzazione silenziosa. INSTALL è una transazione con lock_timeout locale 3s; definizioni generate terminate esplicitamente. Dopo INSTALL si verificano corpo, owner e ACL privati di helper e snapshot. RECOVERY applica gli stessi pin prima del ripristino e controlla gli oggetti risultanti: ripristina snapshot originale, mantiene helper privata. Nessun DROP/DELETE. Un riapply dopo recovery non è supportato da questo INSTALL nuovo-solamente: richiede percorso nominato successivo.

NT-02 limita il raccordo mediante predicato nativo a attività resolved/policy staff_test_no_persistent_resources_v1, round effettivo, sessione ordinary, location di test coincidente, nessuna scrittura risorse reali e staff_test_allowed con controller del roster. Il controllo precede l’aggancio nello snapshot; all’esterno resta il risultato legacy. L’helper applica lo stesso confine internamente e rifiuta l’uso fuori scope. Si riusano configurazione e guardie native; nessuna nuova macchina ON/OFF. Il parametro provider=false significa che questa lettura non chiama provider: il dispatch mantiene il proprio controllo provider già esistente.

NT-01/02/03 appartengono alla prima aggregata conservata; qui resta una correzione funzionale: il confronto end_reason IS DISTINCT FROM CASE è reso non ambiguo con parentesi attorno all’espressione CASE. Nessun esito/condizione cambiato. MD5 helper aggiornato a955228bdc23c89cdb287198db57231b8 in INSTALL/RECOVERY e verificaG8. Snapshot, confine Staff nativo, ACL, cataloghi, mapping, fonti e EDITORIAL invariati.

Il precedente pacchetto di15file (11candidati+4referti) è preservato integralmente in _precedenti/2026-09-09_narrative_tech_pass01. Il referto precedente mantiene il verdetto storico e non viene riscritto. Il nuovo seguito è autorizzato esplicitamente dalla regola09/09; non azzera contatori o evidenze.

## Campagna del passaggio 2/5: revisione congelata e budget

Budget di questo passaggio:25min,8gruppi originali completi, massimo10submission SQL incluse verifica DB assente e creazione DB,0provider/produzione/browser/GitHub. Una esecuzione dopo congelamento; nessuna patch tra gruppi o dopo l’output prima della controverifica. Il runner raccoglie gli esiti anche rossi, salvo sicurezza/dati/budget.

PostgreSQL17.6 nel nuovo database narrative_tech_pass02, container tus_ordinary_compose_qa_db; nuova risorsa autorizzata dal PM per conservare narrative_tech_final e narrative_tech_qa. Nessun reset, configurazione globale o interferenza con gli altri banchi. Il cambio del nome del banco preserva il precedente e non è cambio di candidata né azzeramento del conteggio.

G1 installazione/owner/ACL/confineStaff; G2 fonteClone e role; G3 finecattura e privacy; G4 mappingMoltiplicazione; G5 difesa persistente; G6 congelamento fonte e nuova impronta dopo variazione; G7 rifiuto fine incoerente; G8 recovery esatto/ownerACL e separazione fonti Edge/compatibilitàlegacy. Matrice SQL identica alla prima aggregata, senza nuovi esempi.

Fixture minima sintetica, corpi pertinenti congelati, dipendenze non esercitate incomplete. Nessuna certificazione di Auth/API, hostedDeno, intero lifecycle persistente/concorrenza/provider/UI/qualità narrativa. Le sette impronte tecniche sono congelate nel manifest prima del run; Risultato effettivo: bootstrap/INSTALL PASS, otto gruppi PASS, recovery esatto e adattatore Edge PASS;9/10submission,0,630secondi,0provider. QA_RESULT conserva gli esiti. Nessuna modifica tecnica dopo il run.

## Passaggio al PM

Consegnare11file con manifest, campagna completa e contatore aggregata2/5 per controverifica2/5. Si termina al verde; un rosso permette il seguito nel limite cumulativo e nel mandato, ma nessuna patch prima del referto corrente. Il quinto rosso torna al PM. Nessun nuovo esempio esplorativo o azzeramento con rinomina.

Prima di un rilascio restano riconciliazione del bundleEdge completo, preflight corpi/owner/ACL correnti e gate nominati distinti. Adattatore Edge compatibilelegacy prima del raccordoDB, evitando nuovi snapshot al vecchio prompt. RecoveryDB non riscrive Fati/snapshot già acquisiti né annulla provider in volo; conservare il lettorecompatibile. INSTALL richiede helperassente: riapply dopo recovery richiede percorso distinto autorizzato. Catalogo/enable/collaudolive e apertura pubblica non sono autorizzati da questa tranche. Root mantiene riepiloghi e dossier.
