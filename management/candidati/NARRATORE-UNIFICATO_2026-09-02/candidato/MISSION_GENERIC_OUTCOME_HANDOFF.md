# MISSION_GENERIC_OUTCOME · A2 sintassi installazione · candidato congelato

Task MISSION-GENERIC-A2-SYNTAX. Stessa aggregata A2 avviata dal PM dopo rollback completo dell'installazione A1; il primo guard non acquisito per lock del manifest non crea un nuovo budget. Nessun apply o provider in questo incarico. Correzione solo grammaticale, senza cambio comportamento, dati, GRANT, vincoli o gate.

Nessun delta al SQL: byte e SHA A1 invariati.

SQL SHA256 `da8c285402f54f37c49261e79069069669f907de5f4177790c6d0e5fb562e2c7` · 16843 byte. SHA A1 `da8c285402f54f37c49261e79069069669f907de5f4177790c6d0e5fb562e2c7`. Controlli statici: 11 statement SQL top-level, 3 funzioni PL/pgSQL dirette e 1 blocchi DO analizzati. Nelle sole copie passate al parser sono stati sostituiti tipi compositi con RECORD e nomi funzione normalizzati; i file consegnati mantengono i tipi reali. È controllo di grammatica, non compilazione/schema resolution o test funzionale. Il serializer JSON del parser sui trigger è incompleto: usata la porta raw parse_plpgsql_json per attestare assenza di ParseError, senza utilizzare l'AST serializzato malformato.

Pin di composizione: le quattro funzioni interessate non sono target di pin prosrc nei moduli dipendenti; i pin SQL rimangono invariati. Sette pin prosrc tra candidate (OUTCOME, CHOICE_SOURCES, PROVIDER_GATE) ricalcolati PASS sulla composizione corrente. Manifest di modulo riallineato ai file SQL correnti. Le patch DO e i nuovi IF emessi da Progress/ProviderGate sono stati censiti: i CASE dentro argomenti di funzione sono già delimitati; nessun cambio ai loro testi dinamici richiesto da questo difetto. Il parsing del DO non esegue né materializza automaticamente i DDL dinamici.

Consegna al PM: unica freeze A2, controverifica indipendente pertinente ancora richiesta. Nessuna autoreview 0/0/0 dedotta dalla statica. Recovery e contratto funzionale seguono la consegna precedente riportata qui come contesto; nessun SQL applicato dall'owner A2.

## Contratto funzionale precedente conservato

# MISSION-GENERIC-OUTCOME · aggregata A1 candidata

## Stato e perimetro della consegna
Correzione aggregata **A1**, mandato MISSION_GENERIC_REVIEW_AGGREGATE_R1.md. Candidato soltanto: nessun apply, enable, provider, gameplay o test funzionale locale. Questa consegna non è una autoreview e non modifica i conteggi della review: iniziale R1 conclusa, prima aggregata preparata, controverifica indipendente A1 ancora da eseguire. Recovery conservativa: runtime off/capability disabled, storico e dati conservati.

## Scope / contratti
Delta dopo DB e PLAN_WRITER A1. Tre replace vincolati ai prosrc aggiornati: validate_definition, editor_v1, plan_catalog_v1. Nessuna tabella/dato aggiunto dal delta, nessuna definizione o snapshot preesistente riscritto. GRANT/REVOKE espliciti ribaditi.

## Correzione A1 / pin
Il validator derivato include DB-R1-04: un incontro per fase mechanical, 1..12 PNG combattenti e almeno un PNG avversario, zero incontri nelle fasi narrative. Preserva combat_outcome opzionale any|pg_win|pg_loss|draw, assente=any; campo vietato sugli altri source_kind e null esplicito invalido. Sovrapposizioni wildcard/caso specifico o duplicati stesso step+encounter rifiutati. Lo stato vincitore resta deciso dal producer Progress server, mai dal client.
Cataloghi riportano sia trigger_options.combat_outcome sia encounter_options A1. Il writer continua a usare il validator condiviso. I tre pin prosrc sono rigenerati dalle candidate DB/PLAN_WRITER A1 e non dalle precedenti R1.

## Consumer / OPEN
Comporre dopo i due moduli nuovi; il pin blocca l'uso accidentale delle versioni precedenti. Nessuna qualifica live dedotta dal parser; controverifica indipendente e collaudo del percorso reale restano al PM.

## Statica / passaggio PM
pglast parse_sql PASS: 11 statement top-level; nessuna esecuzione/compilazione PL/pgSQL sul database, nessun test funzionale. Firma SQL SHA256 `da8c285402f54f37c49261e79069069669f907de5f4177790c6d0e5fb562e2c7` · 16843 byte. Congelare con gli altri owner prima della controverifica aggregata; non dichiarare risolto un finding senza tale referto.
