# MISSION_GENERIC_DB · A2 sintassi installazione · candidato congelato

Task MISSION-GENERIC-A2-SYNTAX. Stessa aggregata A2 avviata dal PM dopo rollback completo dell'installazione A1; il primo guard non acquisito per lock del manifest non crea un nuovo budget. Nessun apply o provider in questo incarico. Correzione solo grammaticale, senza cambio comportamento, dati, GRANT, vincoli o gate.

Nessun delta al SQL: byte e SHA A1 invariati.

SQL SHA256 `b7e42ea5a6b78d50d5289a356d7be96b550d30cdb305e99b02145cf53fc732ff` · 38596 byte. SHA A1 `b7e42ea5a6b78d50d5289a356d7be96b550d30cdb305e99b02145cf53fc732ff`. Controlli statici: 42 statement SQL top-level, 10 funzioni PL/pgSQL dirette e 0 blocchi DO analizzati. Nelle sole copie passate al parser sono stati sostituiti tipi compositi con RECORD e nomi funzione normalizzati; i file consegnati mantengono i tipi reali. È controllo di grammatica, non compilazione/schema resolution o test funzionale. Il serializer JSON del parser sui trigger è incompleto: usata la porta raw parse_plpgsql_json per attestare assenza di ParseError, senza utilizzare l'AST serializzato malformato.

Pin di composizione: le quattro funzioni interessate non sono target di pin prosrc nei moduli dipendenti; i pin SQL rimangono invariati. Sette pin prosrc tra candidate (OUTCOME, CHOICE_SOURCES, PROVIDER_GATE) ricalcolati PASS sulla composizione corrente. Manifest di modulo riallineato ai file SQL correnti. Le patch DO e i nuovi IF emessi da Progress/ProviderGate sono stati censiti: i CASE dentro argomenti di funzione sono già delimitati; nessun cambio ai loro testi dinamici richiesto da questo difetto. Il parsing del DO non esegue né materializza automaticamente i DDL dinamici.

Consegna al PM: unica freeze A2, controverifica indipendente pertinente ancora richiesta. Nessuna autoreview 0/0/0 dedotta dalla statica. Recovery e contratto funzionale seguono la consegna precedente riportata qui come contesto; nessun SQL applicato dall'owner A2.

## Contratto funzionale precedente conservato

# MISSION-GENERIC-DB · aggregata A1 candidata

## Stato e perimetro della consegna
Correzione aggregata **A1**, mandato MISSION_GENERIC_REVIEW_AGGREGATE_R1.md. Candidato soltanto: nessun apply, enable, provider, gameplay o test funzionale locale. Questa consegna non è una autoreview e non modifica i conteggi della review: iniziale R1 conclusa, prima aggregata preparata, controverifica indipendente A1 ancora da eseguire. Recovery conservativa: runtime off/capability disabled, storico e dati conservati.

## Scope / contratti
Configurazione immutabile, snapshot per run e trigger sopra controller nativo mission_internal.transition. Dodici funzioni nuove, quattro tabelle private RLS, cinque RPC pubbliche. Nessun corpo nativo modificato o vincolo esistente allentato. API e shape restano quelle del contratto precedente.

## Correzione DB-R1-04
Alla sigillatura ogni fase narrative ha zero incontri; ogni fase mechanical ha esattamente un incontro, riapribile in una visita distinta dal controller. Gli attori PNG di tale incontro devono essere 1..12, almeno uno con team diverso da pg_team. Il massimo12 deriva dalla guardia del core nativo Regia Ninja Book verificata, non da un nuovo massimo del gioco. Restano liberi zero o più PNG narrativi nelle fasi narrative; nessuna estensione al PvP missione o a più aperture nello stesso step.
Il catalogo editor espone encounter_options:{per_step:1,npc_min:1,npc_max:12,opposing_npc_required:true,mission_pvp:false}. Shape, profili approvati, attori duplicati, identità persistente e requirements conservano i controlli precedenti.

## Consumer / OPEN
OUTCOME A1 deriva l'intero validator aggiornato e mantiene il discriminante server degli esiti. BOARD/Progress/Dispatcher e UI restano moduli separati della composizione; questo file da solo non implementa il prodotto end-to-end. Runtime nasce off e capability evidence disabled. Verifiche live soltanto dopo composizione e controverifica pertinente.

## Statica / passaggio PM
pglast parse_sql PASS: 42 statement top-level; nessuna esecuzione/compilazione PL/pgSQL sul database, nessun test funzionale. Firma SQL SHA256 `b7e42ea5a6b78d50d5289a356d7be96b550d30cdb305e99b02145cf53fc732ff` · 38596 byte. Congelare con gli altri owner prima della controverifica aggregata; non dichiarare risolto un finding senza tale referto.
