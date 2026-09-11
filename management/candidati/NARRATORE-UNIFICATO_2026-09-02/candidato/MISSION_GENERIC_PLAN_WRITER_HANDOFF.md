# MISSION_GENERIC_PLAN_WRITER · A2 sintassi installazione · candidato congelato

Task MISSION-GENERIC-A2-SYNTAX. Stessa aggregata A2 avviata dal PM dopo rollback completo dell'installazione A1; il primo guard non acquisito per lock del manifest non crea un nuovo budget. Nessun apply o provider in questo incarico. Correzione solo grammaticale, senza cambio comportamento, dati, GRANT, vincoli o gate.

Nessun delta al SQL: byte e SHA A1 invariati.

SQL SHA256 `2e7a81af83224fb7a6f98d83a3836f4b53ddbee1c61574ab41c3f344795e53ae` · 20832 byte. SHA A1 `2e7a81af83224fb7a6f98d83a3836f4b53ddbee1c61574ab41c3f344795e53ae`. Controlli statici: 28 statement SQL top-level, 5 funzioni PL/pgSQL dirette e 0 blocchi DO analizzati. Nelle sole copie passate al parser sono stati sostituiti tipi compositi con RECORD e nomi funzione normalizzati; i file consegnati mantengono i tipi reali. È controllo di grammatica, non compilazione/schema resolution o test funzionale. Il serializer JSON del parser sui trigger è incompleto: usata la porta raw parse_plpgsql_json per attestare assenza di ParseError, senza utilizzare l'AST serializzato malformato.

Pin di composizione: le quattro funzioni interessate non sono target di pin prosrc nei moduli dipendenti; i pin SQL rimangono invariati. Sette pin prosrc tra candidate (OUTCOME, CHOICE_SOURCES, PROVIDER_GATE) ricalcolati PASS sulla composizione corrente. Manifest di modulo riallineato ai file SQL correnti. Le patch DO e i nuovi IF emessi da Progress/ProviderGate sono stati censiti: i CASE dentro argomenti di funzione sono già delimitati; nessun cambio ai loro testi dinamici richiesto da questo difetto. Il parsing del DO non esegue né materializza automaticamente i DDL dinamici.

Consegna al PM: unica freeze A2, controverifica indipendente pertinente ancora richiesta. Nessuna autoreview 0/0/0 dedotta dalla statica. Recovery e contratto funzionale seguono la consegna precedente riportata qui come contesto; nessun SQL applicato dall'owner A2.

## Contratto funzionale precedente conservato

# MISSION-GENERIC-PLAN-WRITER · aggregata A1 candidata

## Stato e perimetro della consegna
Correzione aggregata **A1**, mandato MISSION_GENERIC_REVIEW_AGGREGATE_R1.md. Candidato soltanto: nessun apply, enable, provider, gameplay o test funzionale locale. Questa consegna non è una autoreview e non modifica i conteggi della review: iniziale R1 conclusa, prima aggregata preparata, controverifica indipendente A1 ancora da eseguire. Recovery conservativa: runtime off/capability disabled, storico e dati conservati.

## Scope / contratti
Writer staff di una nuova revisione piano/definizione atomica, selezione futura distinta dal run. Tre tabelle private e tre RPC pubbliche invariate: plan_catalog_v1(mission), plan_seal_v1(mission,request,expected_mission_sha,document), plan_select_v1(mission,planversion,expected_selection_version,request). Sette funzioni nuove complessive con GRANT/REVOKE espliciti; nessun corpo o vincolo nativo modificato.

## Correzione DB-R1-03
mission_editor_snapshot include ora tutti i contenuti usati dal raccordo: id,title,grado,team_min/max,xp/ryo,status,briefing,village,tag_trama,location_hint. La sigillatura conserva nei settings il nuovo source_mission_content_sha256 del medesimo snapshot meno il solo status; settings_sha256 resta immutabile. selected_plan mantiene il controllo rigoroso sull'intero snapshot, quindi il normale avvio non allenta i propri pin.
Nuovo helper privato **historical_plan(p_mission uuid)** restituisce la stessa shape di selected_plan per la sorgente storica. Confronta il pin contenuti senza status, verifica fingerprint settings, piano e definizione esatta della revisione. Nessuno status, piano, risultato o contenuto originale viene riscritto; una modifica editoriale reale continua a bloccare il riuso. BOARD staff_test_start usa questa lettura soltanto per la sorgente originale, mentre il carrier appena creato usa selected_plan rigoroso.
Il catalogo aggiunge encounter_options allineato al validator A1. Non si modifica il controllo base_plan_version_id dell'editor: il consumer deve proporre l'ultima revisione corretta.

## Consumer / OPEN
Root integra nella UI l'accesso alle sorgenti storiche e la scelta delle revisioni. Il contenuto copiato in Staff Test Room rimane soggetto alla whitelist nativa del roster e ai gate; questo helper non apre una scena. Nessun backfill: i moduli Generic sono ancora candidati mai applicati, quindi il nuovo pin è presente dalla prima sigillatura.

## Statica / passaggio PM
pglast parse_sql PASS: 28 statement top-level; nessuna esecuzione/compilazione PL/pgSQL sul database, nessun test funzionale. Firma SQL SHA256 `2e7a81af83224fb7a6f98d83a3836f4b53ddbee1c61574ab41c3f344795e53ae` · 20832 byte. Congelare con gli altri owner prima della controverifica aggregata; non dichiarare risolto un finding senza tale referto.
