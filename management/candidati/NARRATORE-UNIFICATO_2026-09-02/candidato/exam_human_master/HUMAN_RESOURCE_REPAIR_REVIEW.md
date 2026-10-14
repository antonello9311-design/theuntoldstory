# Controverifica empirica aggregata 2 — GREEN 0/0/0

Candidata 2.078 byte SHA-256 `0a2fec6f2fb7f2ea2bd7dd1a8b597915290b75d1fbe83236bd521b1fc76f9629`; manifest `56716b1f92950d36728f5febabef9a40def3309dc5d4eb162d77b688c444c551`.

Delta minimo pertinente al difetto osservato: `can_decide` diventa booleano false quando non esiste una review o il suo status è NULL. Solo un admin con status requested produce true. L'uguaglianza inversa con la DDL catturata è esatta sostituendo il solo `coalesce(r.status='requested',false)` con l'espressione precedente. Firme, header, security, search_path, assert_editor, Auth, role lookup, status/provenienza della review e gli altri campi restano invariati. Nessuna decisione o guardia server viene allentata.

Sintassi: tre statement SQL e tre programmi PL validati; i due tipi compositi DECLARE sono normalizzati soltanto nella copia del parser. Body MD5 nuovo `a9b97352a15680a287eb590e272c0cb8` conforme alla postcondizione. Preflight richiede DDL precedente esatta, postgres, Staff quiescente e qualifier c444 completo; postflight ripete il qualifier. Eseguire i tre statement in una sola transazione.

Ricerca inversa readonly del vecchio body MD5 `4de6fb6c089fa6b92de708482ad69673`: nessun pin in pg_proc. Ricerca per nome della funzione: tre consumer request_v1, decide_v1 e state_v2; nessun pin individuato. La correzione conserva la shape ed elimina il NULL incompatibile col contratto booleano del client. L'aggregata b666 già installata resta parent, con recovery conservativa gate-only compatibile che conserva codice/dati/storico; nessuna recovery fittizia della bozza.

Verdetto statico pertinente GREEN 0/0/0; il percorso UI Review corretto resta da riverificare sullo stesso caso. Necessari preflight fresco e autorità Root, nessun PASS runtime dedotto. Review iniziale, aggregata1 e conteggi cumulativi conservati; nessun reset o nuovo ciclo. Provider zero, nessuna UI/DB mutante/apply o campagna locale; deadline empirica invariata.
