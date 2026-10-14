# Controverifica empirica aggregata 3 — GREEN 0/0/0

Candidata 28.919 byte SHA-256 `1b8beb4fa1086b955c7094abcc5c411c410dad56ab9d9cb98c260e64df1a3fbc`; recovery `8239cbc635a97be205589225372da197a1d0ff5216837831f3e3e16b10a89304`; manifest `6f1f6f99552789eaecbfff442c41b9ef956fbe3f6540910b9ca855140a39d748`.

Delta pertinente al 22P02 osservato: quattro concatenazioni ambiguamente risolte text[]/literal sono sostituite con `pg_catalog.array_append(scopes, literal)`. Ogni append conserva la propria condizione, ordine e valore. Reverse esatto della DDL viva con queste sole quattro sostituzioni. Nessun cambiamento ad Auth, controlli, selezione PNG/versione, shape pubblica, availability o combat. Header dei tre helper equivalenti alla baseline, quindi firme/default/security/config e ACL esistenti conservati da CREATE OR REPLACE.

Composizione qualificata: c408 cambia esclusivamente il pin npc_item_v2 da `6f844f04d4fc83c127bb251c4aff04e9` a `c0a69970de74d30d948c7c8e8ac751e8`; c444 cambia esclusivamente il pin c408 da `5e6ffd85200853f395de66a474cab046` a `81562f2945f6371b2bae301232aa353a`. Reverse di entrambi esatto, nessun reinstall di altri corpi. Nuovo c444 body `654d297086e6d8a2f9d275447b69f5f9`. Il qualifier completo c444→c40897/16 precede e segue la modifica; preflight CAS delle tre DDL vive e Staff quiescente. Necessaria una sola transazione per cinque statement.

Parsing statico cinque SQL/cinque programmi PL della candidata e uno/uno della recovery. Quattro tipi compositi DECLARE normalizzati esclusivamente nella copia del parser. Recovery aggiornata alla composizione attuale, controlla qualifier/body/OID e disabilita solo il selettore proprio CV1→CV2, conservando codice, bozza, dati e storico.

GREEN 0/0/0 sulla composizione statica. Preflight fresco/autorità Root restano necessari; il percorso Aggiorna catalogo PNG e le due puntate devono essere riverificati sullo stesso caso nella Staff. Nessun apply/UI/DB mutante/provider/caso locale. Parent installato, review precedenti, conteggi cumulativi e deadline originale conservati, senza reset.

## Revisioni precedenti conservate

# Controverifica empirica aggregata 2 — GREEN 0/0/0

Candidata 2.078 byte SHA-256 `0a2fec6f2fb7f2ea2bd7dd1a8b597915290b75d1fbe83236bd521b1fc76f9629`; manifest `56716b1f92950d36728f5febabef9a40def3309dc5d4eb162d77b688c444c551`.

Delta minimo pertinente al difetto osservato: `can_decide` diventa booleano false quando non esiste una review o il suo status è NULL. Solo un admin con status requested produce true. L'uguaglianza inversa con la DDL catturata è esatta sostituendo il solo `coalesce(r.status='requested',false)` con l'espressione precedente. Firme, header, security, search_path, assert_editor, Auth, role lookup, status/provenienza della review e gli altri campi restano invariati. Nessuna decisione o guardia server viene allentata.

Sintassi: tre statement SQL e tre programmi PL validati; i due tipi compositi DECLARE sono normalizzati soltanto nella copia del parser. Body MD5 nuovo `a9b97352a15680a287eb590e272c0cb8` conforme alla postcondizione. Preflight richiede DDL precedente esatta, postgres, Staff quiescente e qualifier c444 completo; postflight ripete il qualifier. Eseguire i tre statement in una sola transazione.

Ricerca inversa readonly del vecchio body MD5 `4de6fb6c089fa6b92de708482ad69673`: nessun pin in pg_proc. Ricerca per nome della funzione: tre consumer request_v1, decide_v1 e state_v2; nessun pin individuato. La correzione conserva la shape ed elimina il NULL incompatibile col contratto booleano del client. L'aggregata b666 già installata resta parent, con recovery conservativa gate-only compatibile che conserva codice/dati/storico; nessuna recovery fittizia della bozza.

Verdetto statico pertinente GREEN 0/0/0; il percorso UI Review corretto resta da riverificare sullo stesso caso. Necessari preflight fresco e autorità Root, nessun PASS runtime dedotto. Review iniziale, aggregata1 e conteggi cumulativi conservati; nessun reset o nuovo ciclo. Provider zero, nessuna UI/DB mutante/apply o campagna locale; deadline empirica invariata.
