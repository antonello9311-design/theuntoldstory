# MISSION-GENERIC · controverifica indipendente SQL C2

Esito del delta grammaticale A2: **VERDE · P0/P1/P2 = 0/0/0**. Reviewer QA-GENERIC-SQL, 11/09/2026. Seconda controverifica cumulativa (2/5), perimetro concordato massimo 20 minuti, zero chiamate provider e zero casi gameplay. Nessuna modifica del codice, apply database o nuova campagna funzionale.

## Baseline e delta verificato
Controllati direttamente i 12 SQL canonici contro SHA-256 e byte del manifest A2. Invertendo esclusivamente le sei sostituzioni dichiarate si ricostruiscono esattamente gli hash A1 congelati: tre file cambiano di 2/8/2 byte; gli altri nove sono identici. Non ci sono variazioni ulteriori nascoste nella composizione SQL. La verifica usa equivalenza crittografica con A1, non un confronto basato soltanto sui nomi delle revisioni.

| File e righe | Delta | SHA-256 A2 |
|---|---|---|
| MISSION_GENERIC_BOARD.sql:119 | 1 espressioni CASE racchiuse tra parentesi | f0827febfea3f6f86e20b745d69ac5b33102b8f2a5ec9250c14ca290637a1774 |
| MISSION_GENERIC_PROVIDER_GATE.sql:54, 77, 79, 80 | 4 espressioni CASE racchiuse tra parentesi | 08a6bc63f598c5c8768d9640a4a8e0782dced24fc82db8a96d9fbb4ff2feb44d |
| MISSION_GENERIC_PROGRESS.sql:30 | 1 espressioni CASE racchiuse tra parentesi | f15b889b1ba36fd5dc3a6c4dbcae2466e8dd8b19f9bbcb90504f3a84577d9581 |

Le quattro funzioni interessate sono booking_terminal_assert, provider_permit, provider_native_assert e finish_scope. Le parentesi delimitano l'operando scalare CASE del confronto nelle condizioni IF. Non cambiano condizioni, valori, precedenza logica prevista, comportamento con NULL, ordine delle operazioni, autorità, ACL, vincoli o gate. Il caso minimo con CASE non delimitato riproduce il rifiuto della grammatica; quello delimitato è accettato.

## Statica e pin
Eseguito nuovamente il parser sulle sorgenti canoniche: **272 statement SQL, 79 funzioni PL/pgSQL dirette e 24 blocchi DO accettati**, nessun ParseError. Il conteggio 272 comprende BEGIN/COMMIT dei dodici moduli; non va confuso con i 250 statement del pacchetto atomico unico predisposto dal PM.

La sola copia temporanea destinata al parser normalizza nomi funzione e tipi compositi a RECORD; i sorgenti consegnati conservano i tipi reali. Per i trigger usato il parser grammaticale raw, evitando il difetto del serializer JSON. Questo controllo attesta la grammatica: non risolve cataloghi, nomi colonna, tipi installati o SQL prodotto dinamicamente dai DO.

Ricontrollati tutti i CASE nei tre file modificati e coperta la stessa causa nelle funzioni dirette dell'intera composizione. I CASE residui sono in SELECT, assegnazioni, RETURN o argomenti già delimitati: non richiedono la correzione di IF. Le aggiunte dinamiche in BOARD:156 e PROGRESS:74,84 usano CASE entro gli argomenti di funzione; nessuna nuova condizione IF con CASE non delimitato è introdotta dal delta.

Ricalcolati indipendentemente **7 pin prosrc interni: PASS** (3 OUTCOME, 1 CHOICE_SOURCES, 3 PROVIDER_GATE). Le quattro funzioni modificate non sono destinatarie di pin prosrc nei moduli dipendenti. Tutti i pin baseline nativi sono testualmente invariati; la nuova verifica live dei 21 pin comunicata dal PM resta evidenza del suo preflight, non un'interrogazione eseguita da questo reviewer.

## Composizione con C1 e limiti
Le parti funzionali restano coperte dai quattro referti C1 congelati: MISSION_GENERIC_REVIEW_DB_C1.md, MISSION_GENERIC_REVIEW_RUNTIME_C1.md, MISSION_GENERIC_REVIEW_SOURCES_C1.md e MISSION_GENERIC_REVIEW_UI_C1.md, ciascuno 0/0/0. C2 verifica esclusivamente che A2 corregga la causa grammaticale senza alterare quelle parti. Non è una nuova autoreview funzionale di PROGRESS/COMBAT.

I riferimenti a contratti o stati A1 conservati nei manifest dei singoli moduli descrivono la loro provenienza e non sono pin DDL runtime. Per l'installazione valgono la lista SQL A2 qui verificata e il pacchetto integrato congelato dal PM. Questo referto non modifica né acquisisce INTEGRATED_MANIFEST o INSTALL. L'eventuale riordino di metadati storici è documentale e non cambia il verdetto sul delta SQL.

Il primo apply A1 fallito con 42601, il rollback integrale e l'assenza dello schema sono informazioni riferite dal PM. C2 non li ricertifica e non dichiara riuscito alcun rilascio. Rimangono al PM la composizione atomica, la baseline live, il mandato e la verifica dell'installazione effettiva; nessun nuovo QA gameplay è richiesto da questo delta.

## Input congelati e consegna
- MISSION_GENERIC_SQL_A2_MANIFEST.json: `12909d5a917d58010b320666eacc724d3f05c62088885ec99d8f9efdff07ad27`.
- MISSION_GENERIC_SQL_A2_HANDOFF.md: `ee3962e81324c94d95b4dc426d443ae85e98de834bbae9d42dd9179c8cd99488`.

Guard MISSION-GENERIC-REVIEW-SQL-C2, owner QA-GENERIC-SQL. Unico output MISSION_GENERIC_REVIEW_SQL_C2.md. Nessun finding P0/P1/P2 nel perimetro; consegna al PM e rilascio delle prenotazioni dopo verifica.
