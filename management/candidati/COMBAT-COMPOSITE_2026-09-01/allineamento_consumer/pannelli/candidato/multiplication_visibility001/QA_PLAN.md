# QA proposta · visibilità e dichiarazione native complete

**Non eseguita.** Matrice congelata:4gruppi,5sottocasi,al massimo8submission SQL complessive incluse creazione/setup,10min dall’unico avvio,0provider/browser. Preparazione del banco distinta; nessun riuso o reset di database storici, MoltiR4 o PNG5/5. Unico futuro DB dedicato proposto combat_multiplication_visibility_001, container PostgreSQL reale assegnato dal PM prima di qualsiasi setup.

## Soggetto e fixture obbligatori

Eseguire multiplication_prepare_declaration intera AFTER e body_visible_to_viewer intera nativa, senza sostituzione della proiezione, auth.uid, owner_turn_context, actor_profile, movement_budget, distance/path o validatori. Riusare DDL/corpi/constraint/trigger del corpus autentico; nessun INSERT di storia migrazione inventata, bypass runtime, grant fittizio per soddisfare pin o database PNG. Un’identità locale nominale su auth.uid nativa è ammessa come fixture dichiarata, non certifica Auth/API Supabase.

Due PG sintetici con utenti nominali e schede native valide, appartenenza e controllo reali del banco ordinary. Tecnica Moltiplicazione riconosciuta dal catalogo autentico, risorse e cap delle copie disponibili secondo le regole già approvate; nessun nuovo numero di gioco. Round/action e personal turn coerenti, scena/arena/profilo/istanza/map_version/body_version nativi, risorse di combattimento separate dalle schede. Fixture base derivata dai dati pubblici012: attaccante(10,9),bersaglio(9,10),1copia,Est1m,figura2/originale fermo; nessuna copia di PG o testo delle role reali. La cardinalità e gli indici sono prodotti dalla funzione line_figures autentica, non da una struttura JSON inventata per superare un pin.

La fixture non è pronta perché esiste un bootstrap compilabile. Occorre preparare il materializzatore e provarne nella stessa futura campagna gli invarianti nativi di readiness: actor_profile disponibile, body_visible autentica, contesto/risorse/proiezione reali e vincoli attivi. Se un prerequisito blocca l’ingresso prima del controllo sotto esame, il sottocaso è NOT_QUALIFIED/NOT_RUN, non un diniego atteso. Nessun successo ottenuto tramite stub, sola compilazione o trigger disabilitato conta come PASS.

## Matrice fissa

| Gruppo | Casi | Esito richiesto |
|---|---:|---|
| G1 Visibile senza grant diretto |1| Dopo INSTALL integrale COMMIT, la proiezione privata ordinary è ready e include il bersaglio, body_visible nativa true, grant diretto sul nemico assente. Invocare prepare_declaration intera con un request_key sintetico nuovo: successo effettivo e piano nativo persistito con binding/fingerprint corretto, originale fermo; schede reali del banco e risorse estranee invariate. Il piano è il prodotto di questa helper, non una dichiarazione o un attacco già risolti. |
| G2 Diniego nativo |2| In due stati di fixture isolati della stessa matrice: (a) bersaglio non visibile nella proiezione nativa pur avendo grant diretto presente; (b) contesto della proiezione non ready pur avendo grant diretto. In entrambi actor_profile e i prerequisiti precedenti devono consentire di arrivare al controllo; body_visible deve essere false/NULL autentico. prepare_declaration completa nega con il rifiuto di contatto e non lascia piano/risorse scritti. Se non è possibile rappresentare questi stati nativamente, registrare il limite, senza sostituire la helper o contare un errore precedente come prova. |
| G3 Geometria ancora vincolante |1| Bersaglio effettivamente visibile e profilo pronto, ma geometria nativa fuori dalla soglia di contatto (distance_m finale>2, configurata nella fixture entro l’arena). La dichiarazione completa deve ancora negare e non lasciare effetti. Si modifica la fixture locale valida, non il numero della regola né l’esito di distance_m/path. Un solo caso, senza varianti per ogni disgiunto. |
| G4 Recovery integra |1| Snapshot dei piani/dati conservati dopo i casi; RECOVERY completa COMMIT in connessione separata, BEFORE/ACL e helper visibilità identici. I dati presenti prima della recovery restano byteidentici; nessuna cancellazione o riscrittura storico. Non serve ripetere l’intera matrice sul vecchio comportamento. |

Le configurazioni negative vanno definite integralmente e congelate durante la preparazione del banco, prima della prima SQL; sono gli stessi due scenari di questa matrice, non nuove campagne. Se la visibilità della proiezione private exact2 non permette (a) senza rendere l’intero contesto non ready, non inventare un successo o uno stub: registrare l’impossibilità e far valutare al PM la copertura concretamente ottenibile. Il fail-closed NULL è verificabile anche staticamente nell’unica espressione, senza aggiungere un altro esempio dinamico.

## Otto submission massime

1. Preflight identità/isolamento/versione/ruoli esistenti, DB assente e CREATE nello stesso invio psql; nessun altro DB toccato.
2. Bootstrap e materializzazione nativa della fixture; nessuna query esplorativa nascosta, nessun segreto o storia fittizia.
3. INSTALL integrale COMMIT e postpin/ACL.
4. G1 completo e confronti della proiezione/plan/risorse.
5. G2 aggregato dei due stati negativi, risultati raccolti separatamente.
6. G3 geometria nativa, senza fault injection al motore.
7. Snapshot conservativo dei dati e RECOVERY integrale COMMIT; wrapper byteidentico alla candidata, su connessione diversa dall’INSTALL e dai casi.
8. G4 postflight corpo/ACL/helper/dati, raccolta di tutti gli esiti.

Sono submission con più statement dichiarati; ogni setup/preflight/CREATE conta. Runner congela SQL/hash prima dell’unico run. Deadline600s e timeout server/client adeguati al residuo, nessun retry o patch durante la campagna. Raccogliere tutti i rossi sicuri entro budget; errore di isolamento, fonte/pin o bootstrap non fedele blocca i dipendenti. DB preservato dopo recovery; nessun DELETE/reset/dismissione automatica.

## Prerequisiti e limiti del gate

Il corpus Hyūga contiene i corpi/schema, ma il banco nativo pronto per questi5casi non è stato costruito in questo incarico. Restano da attestare fonti catalogo/layout necessarie alla fixture e sequenza di materializzazione con trigger reali, incluse eventuali dipendenze di attestazione del runtime: non chiamare assert originali con history finta. Un eventuale prodotto di attestazione portabile già qualificato va composto solo se realmente necessario, pinzato e autorizzato; non diventa una scorciatoia generica né una riapertura del PNG.

G1 verde deve significare che la helper completa ha realmente accettato la preparazione, non che il runner ha restituito una bozza sintetica. G2/G3 negati devono raggiungere il predicato pertinente. Non qualificare con questa matrice provider, Fato, difesa/consumo delle copie, gioco Master, accesso Auth/RLS via API, UI o parità Test Room utenti legacy. Dopo review e qualifica locale effettive, il PM valuta i rischi residui e assegna il rilascio e un solo smoke protetto pertinente, senza reinvio automatico012 o ricerca casuale del verde.
