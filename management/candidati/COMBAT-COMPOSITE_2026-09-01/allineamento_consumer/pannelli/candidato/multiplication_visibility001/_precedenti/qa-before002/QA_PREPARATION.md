# Preparazione QA nativa · visibilità Moltiplicazione

**PREPARATA, NON ESEGUITA.** Incarico COMBAT-MULTIPLICATION-VISIBILITY-QA-PREP-001. Nessuna query, SQL, Docker, browser, provider o test runtime effettuato. I sette file prodotto e QA_PLAN originaria restano immutati. Prima dell'esecuzione servono incarico PM, accettazione esplicita della matrice ridotta e verifica del presente banco. Il runner rifiuta l'avvio senza entrambi i gate nominativi.

## Matrice proposta al PM, non ancora formalizzata

Quattro gruppi, quattro casi G1/G2b/G3/G4, massimo otto submission SQL totali comprendenti creazione/setup, dieci minuti, zero provider e retry. G2a NON_APPLICABILE AL PRODOTTO CORRENTE per l'ultima precisazione di Antonello: invisibilità è una funzione futura e nessun jutsu/arma attuale la produce. Non è PASS e non autorizza rimuovere il requisito futuro. Il precedente ragionamento «due membri implica impossibilità generale di nascondersi» non è una prova del dominio: viene ritirato. Identificatore in mappa e corpo visibile non sono intercambiabili per future funzioni.

G1: due utenti/PG nominali sintetici, Moltiplicazione dal catalogo autentico, apertura e materializzazione ordinary native. Il vincitore dell'iniziativa nativa diventa l'attaccante della prova, senza imporre tiro o ordine; entrambi hanno gli stessi valori Deshi di default e stessa tecnica. Solo posizione iniziale del banco deriva dai punti pubblici012: attaccante(10,9), bersaglio(9,10), copia Est1m, originale2 fermo. Le figure sono prodotte dalla vera line_figures(10,9,1,0,1,1), non da JSON inventato. prepare_declaration AFTER intera deve scrivere piano corretto, costo15, fingerprint, transazione/binding, nessun movimento/declaration_id; schede e snapshot attori invariati. È preparazione nativa, non attacco risolto o prova UI.

G2b: nel solo blocco locale sintetico, grant diretto verso il bersaglio presente e runtime_config.enabled=false; release_gate.ordinary_enabled resta true. La proiezione deve essere blocked e body_visible false/NULL, mentre actor_profile resta available. Si invoca la preparazione completa e si accetta soltanto SQLSTATE22023 con panel_multiplication_assault_contact_invalid. Un rifiuto precedente è rosso. L'exception block annulla modifica config/grant e qualsiasi piano: nessun ripristino dopo una mutazione su PG reali, che qui non esistono.

G3: bersaglio visibile, profilo pronto, corpo bersaglio posto nella sola fixture a(15,10), oltre contatto. Il numero della regola resta invariato; la vera distance_m e il preparatore devono negare. L'exception block annulla la posizione negativa. Nessuna variante aggiunta.

G4: snapshot di quattordici relazioni pertinenti; RECOVERY completa e byteidentica COMMIT su connessione distinta dall'INSTALL, postflight due corpi/owner/ACL/config e dati. Tabelle e database restano conservati. Non si esegue la vecchia helper per cercare un rifiuto verde.

## Fonti e catena nativa

HYUGA_RUNTIME_METADATA.json contiene le definizioni autentiche, identificate per indice/MD5/SHA nel manifest. HYUGA_RUNTIME_COMPILE_BOOTSTRAP.sql riproduce DDL, vincoli, trigger e corpi integrali, senza storia migrazioni o chiave RNG. Nel suo segmento cambia soltanto il nome del database nella guardia locale, non funzioni, owner, ACL, attestazioni o pin. Il commento storico del bootstrap sulla non giocabilità Hyūga resta nel segmento originale: non viene trasformato in certificazione di questo percorso Moltiplicazione. Il banco non invoca assert storici o costruisce storia fittizia; eventuale guardia nativa realmente incontrata produce rosso e non viene aggirata.

Moltiplicazione: riga pubblica after_j da NARRATIVE_CATALOG_INSTALL.sql, tutti i campi copiati come catalogo e mai dati di PG. Geometria: segmento seed della migrazione ordinary_neutral_arena_inert, senza il suo vecchio patch al validatore o inventario dei luoghi reali. Il seed riusa geometry_fingerprint/template_errors nativi e i pin originali; nuovo luogo/profilo solo nominali locali. auth.users→handle_new_user e characters→trigger nativi; valori di base e risorse derivati dai default/calc originali, nessuna assegnazione stat alta o UPDATE delle schede.

accept_invitation righe18–57 controlla utenti/presenza/template e chiama ordinary_open; righe58–81 produce turno/attività/membri/place_fighters. ordinary_open righe30–34 produce attori da combat_v2_character_snapshot: le capacità vengono dal possesso della riga catalogo, non da uno snapshot finto. place_fighters righe14–57 e claim_scene creano scene claim, arena e corpi mediante prodotto. Solo invito pending, appartenenza alla tecnica e posizioni iniziali sono input sintetici espliciti. Non è mock Auth, perché auth.uid resta nativa, ma l'identità nominale locale NON certifica autenticazione Supabase/API/RLS.

## Raggiungibilità di G2b e limite futuro

Riferimenti sono righe delle definizioni nel corpus, non righe del JSON serializzato:

- prepare_declaration righe17–51: lock_round, attore controllato, actor_profile, formazione, istanza/scope/body. Nessuna verifica consumer.runtime_config in questi controlli. Righe61–75: movement_budget e ramo movimento; l'originale fermo non usa movement_commit/attestazioni di movimento. Righe77–96: bersaglio e unico controllo di visibilità/geometria. Il pin dei due soggetti resta quello della candidata001.
- actor_profile righe16–25: owner_turn_context e access_reason. owner_turn_context ordinary usa attività phase/action/turno, non runtime_config. access_reason righe10–18 usa presenza, is_test e release_gate; la fixture è ordinary non-test locale, con ordinary_enabled=true. Non concede Staff e non pretende di qualificare Staff Test Room.
- runtime_allowed righe7–11 legge enabled per luogo non-test. state_projection righe17–20 chiama runtime_allowed e restituisce blocked. body_visible righe18–25 chiama questa proiezione, richiede status ready e l'identificatore del bersaglio; con enabled=false non restituisce true anche se il grant diretto esiste.
- state_projection righe102–144 costruisce map.actors da corpi attivi, membri e attori PG nello specifico template ordinary corrente. Il ramo non legge una transizione hidden. actor_states accetta active/removed: removed non viene usato per fingere occultamento. map_projection generica legge viewer_grants ma il ramo ordinary della helper usa state_projection. La futura invisibilità deve avere una transizione autorevole visibile→nascosto→visibile e raggiungere questo punto centrale; questa candidata non la implementa e non la certifica.

L'analisi di raggiungibilità è statica. Il banco richiede profilo disponibile e il codice d'errore esatto per qualificare G2b: un pin/owner/attestazione o prerequisito precedente non diventa falso positivo.

## Otto submission e ambiente proposto

1 preflight/ruoli/versione e CREATE via un solo psql; 2 bootstrap+fixture; 3 INSTALL integrale COMMIT; 4 G1; 5 G2b; 6 G3; 7 snapshot+RECOVERY integrale COMMIT; 8 postflight. Ogni psql conta, incluse preparazioni. Runner congela SHA di tutte le otto stringhe prima di qualsiasi SQL. Nessun probe, query nascosta, retry, reset o ricreazione. I rossi sicuri dei casi vengono raccolti; errore di fonte/ambiente/setup/install ferma i dipendenti.

Nuovo DB combat_multiplication_visibility_001; proposta dello stesso cluster locale compose autorizzabile dal PM: fullID8681f0364c9f27bd5c856d2cc0f20690c8bc2f8d4aaf36de3394241b1596c019, immagine17.6.1.136, rete/porte/mount esatti di QA_ENVIRONMENT.json pinzato. Non è networknone: il runner richiede la configurazione specifica già nota e non legge Env o contenuti dei mount. Nessun ispezione eseguita in preparazione. Non crea ruoli globali, non tocca altri database/configurazioni, non avvia o ferma container. Futuro owner deve acquisire entrambi alias cluster e DB dedicato.

## Consegna e limiti

AST Python, costruzione delle otto stringhe in memoria senza chiamare main/Docker e impronte statiche completati; nessuna compilazione PostgreSQL o qualifica runtime dichiarata. Il materializzatore è concreto e usa funzioni complete; se una dipendenza del bootstrap o del percorso nativo fallisce, il risultato sarà NOT_QUALIFIED con nome/errore, senza patch nel run. Il corpo completo non viene sostituito con un successo simulato. Restano gate: accettazione PM dei quattro casi e verifica della preparazione, assegnazione esclusiva dell'ambiente, unica campagna e valutazione delle differenze Auth/RLS/API prima di rilascio.

Nessun verde precedente rieseguito, PNG5/5 intatto, nessuna modifica prodotto/candidato/review o feature invisibilità. Passaggio al PM: leggere i quattro artefatti e formalizzare la matrice pertinente prima della prima SQL.
