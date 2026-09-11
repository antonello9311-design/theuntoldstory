# MISSION_GENERIC_BOARD · A2 sintassi installazione · candidato congelato

Task MISSION-GENERIC-A2-SYNTAX. Stessa aggregata A2 avviata dal PM dopo rollback completo dell'installazione A1; il primo guard non acquisito per lock del manifest non crea un nuovo budget. Nessun apply o provider in questo incarico. Correzione solo grammaticale, senza cambio comportamento, dati, GRANT, vincoli o gate.

- Riga 119: `<>case when outcome='success' then 'conclusa' else 'fallita' end` → `<>(case when outcome='success' then 'conclusa' else 'fallita' end)`.

SQL SHA256 `f0827febfea3f6f86e20b745d69ac5b33102b8f2a5ec9250c14ca290637a1774` · 38907 byte. SHA A1 `c8f24b6021243f5491f01fb7c6bb8242b705626c611a3bd16b81417139fb7cd5`. Controlli statici: 47 statement SQL top-level, 12 funzioni PL/pgSQL dirette e 3 blocchi DO analizzati. Nelle sole copie passate al parser sono stati sostituiti tipi compositi con RECORD e nomi funzione normalizzati; i file consegnati mantengono i tipi reali. È controllo di grammatica, non compilazione/schema resolution o test funzionale. Il serializer JSON del parser sui trigger è incompleto: usata la porta raw parse_plpgsql_json per attestare assenza di ParseError, senza utilizzare l'AST serializzato malformato.

Pin di composizione: le quattro funzioni interessate non sono target di pin prosrc nei moduli dipendenti; i pin SQL rimangono invariati. Sette pin prosrc tra candidate (OUTCOME, CHOICE_SOURCES, PROVIDER_GATE) ricalcolati PASS sulla composizione corrente. Manifest di modulo riallineato ai file SQL correnti. Le patch DO e i nuovi IF emessi da Progress/ProviderGate sono stati censiti: i CASE dentro argomenti di funzione sono già delimitati; nessun cambio ai loro testi dinamici richiesto da questo difetto. Il parsing del DO non esegue né materializza automaticamente i DDL dinamici.

Consegna al PM: unica freeze A2, controverifica indipendente pertinente ancora richiesta. Nessuna autoreview 0/0/0 dedotta dalla statica. Recovery e contratto funzionale seguono la consegna precedente riportata qui come contesto; nessun SQL applicato dall'owner A2.

## Contratto funzionale precedente conservato

# MISSION-GENERIC-BOARD · aggregata A1 candidata

## Stato e perimetro della consegna
Correzione aggregata **A1**, mandato MISSION_GENERIC_REVIEW_AGGREGATE_R1.md. Candidato soltanto: nessun apply, enable, provider, gameplay o test funzionale locale. Questa consegna non è una autoreview e non modifica i conteggi della review: iniziale R1 conclusa, prima aggregata preparata, controverifica indipendente A1 ancora da eseguire. Recovery conservativa: runtime off/capability disabled, storico e dati conservati.

## Scope / contratti
Avvio bacheca e Staff Test Room riusando native activations/applicants/reservations/quota/requests; incipit tramite dispatch_admit+enqueue_opening, attivazione soltanto in opening_published dopo Fato. Tre tabelle private, dodici funzioni nuove, cinque RPC autenticate invariate. Native location Test Room ammessa anche quando is_exam_room=true; esame reale escluso.
Vincolo allentato invariato: activations.package_id nullable, sostituito dal CHECK XOR package_id/generic_plan_version_id con FK; nessun dato preesistente riscritto. Budget provider nullable e positivi, senza default, fail closed finché policy esplicita.

## Correzione DB-R1-01
Nuovo **staff_roster_assert(location,roster)** privato: staff_only, location/runtime, shape e unicità, lock PG per UUID e lettura user_id reali non archiviati. Richiede staff_test_allowed(location,principals,true) strettamente true, compresa policy provider nativa. Nessun elenco locale di nomi/identità e nessun superamento dei limiti Staff 1..2. Viene chiamato prima di creare carrier/piano/activation e ripetuto dentro prepare_start prima delle mutazioni sessione/partecipanti/reservation/work. Roster ordinario conserva il proprio limite nativo team_min/max. Baseline nativa staff_test_allowed MD5 80434afefcecbc48e190999830389cee vincolata nel modulo.

## Correzione DB-R1-02
Nuovo **booking_terminal_assert(mission,character,status)** privato usato sia da BEFORE booking_guard sia da AFTER booking_sync. Ammette soltanto UPDATE iscritto→completata/fallita della chiusura Generic verificata: service authority, activation started e corrente, master chiusura, run conclusa/fallita coerente, capability attiva, roster partecipante/applicant started+ordinal, board_start non simulato e finish_scope nativa strettamente false. La verifica Progress conserva barriera narrativa, stato incontri e corrispondenza roster.
BEFORE permette questa sola finalizzazione prima di imporre enrollment_open alle normali operazioni. AFTER ritorna senza trasformare l'applicant storico started in withdrawn e senza cancellare ordinal. Ritiro/nuova iscrizione durante avvio o missione continuano a fallire; il ramo legacy è intatto. I due corpi nativi sono patchati tramite needle unico e hash esatto: booking_guard bc2c23eaa64e0a69bc4cc5c568368364, booking_sync 451704552b059dd8bfbcb8585a0e59a5. Nessun CHECK degli applicants allentato.

## Correzione DB-R1-03 / dipendenze
Staff_test_start legge historical_plan per la sorgente originale, poi copia contenuto/piano/mappa in un carrier nuovo; sorgente e scene pregresse intatte. Zero premi sul carrier non è la protezione: Progress verifica simulation_sources/snapshot/whitelist e salta esplicitamente ricompense/progressione. Le API Board restano invariate; catalogo pubblico non espone sorgenti di test.
Prima di enable devono esistere gli hook Progress start_claims, finish_scope/chiusura/abort e Dispatcher admission/opening. BOARD dipende ora esplicitamente da finish_scope per le guardie terminali eseguite a runtime; non aprire/finalizzare prima della composizione completa. Progress rilascia reservations e quote riservate nell'abort certo, mantenendo audit.

## Statica / passaggio PM
pglast parse_sql PASS: 47 statement top-level; nessuna esecuzione/compilazione PL/pgSQL sul database, nessun test funzionale. Firma SQL SHA256 `c8f24b6021243f5491f01fb7c6bb8242b705626c611a3bd16b81417139fb7cd5` · 38905 byte. Congelare con gli altri owner prima della controverifica aggregata; non dichiarare risolto un finding senza tale referto.
