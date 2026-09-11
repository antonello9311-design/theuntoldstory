# MISSION_GENERIC_CHOICE_SOURCES · A2 sintassi installazione · candidato congelato

Task MISSION-GENERIC-A2-SYNTAX. Stessa aggregata A2 avviata dal PM dopo rollback completo dell'installazione A1; il primo guard non acquisito per lock del manifest non crea un nuovo budget. Nessun apply o provider in questo incarico. Correzione solo grammaticale, senza cambio comportamento, dati, GRANT, vincoli o gate.

Nessun delta al SQL: byte e SHA A1 invariati.

SQL SHA256 `f9f7135332725e49a29946b58c1bfa0b96ed20e6b724823346a4744a67f71102` · 7943 byte. SHA A1 `f9f7135332725e49a29946b58c1bfa0b96ed20e6b724823346a4744a67f71102`. Controlli statici: 6 statement SQL top-level, 2 funzioni PL/pgSQL dirette e 1 blocchi DO analizzati. Nelle sole copie passate al parser sono stati sostituiti tipi compositi con RECORD e nomi funzione normalizzati; i file consegnati mantengono i tipi reali. È controllo di grammatica, non compilazione/schema resolution o test funzionale. Il serializer JSON del parser sui trigger è incompleto: usata la porta raw parse_plpgsql_json per attestare assenza di ParseError, senza utilizzare l'AST serializzato malformato.

Pin di composizione: le quattro funzioni interessate non sono target di pin prosrc nei moduli dipendenti; i pin SQL rimangono invariati. Sette pin prosrc tra candidate (OUTCOME, CHOICE_SOURCES, PROVIDER_GATE) ricalcolati PASS sulla composizione corrente. Manifest di modulo riallineato ai file SQL correnti. Le patch DO e i nuovi IF emessi da Progress/ProviderGate sono stati censiti: i CASE dentro argomenti di funzione sono già delimitati; nessun cambio ai loro testi dinamici richiesto da questo difetto. Il parsing del DO non esegue né materializza automaticamente i DDL dinamici.

Consegna al PM: unica freeze A2, controverifica indipendente pertinente ancora richiesta. Nessuna autoreview 0/0/0 dedotta dalla statica. Recovery e contratto funzionale seguono la consegna precedente riportata qui come contesto; nessun SQL applicato dall'owner A2.

## Contratto funzionale precedente conservato

TASK-ID · MISSION-GENERIC-CHOICE-SOURCES-001 · candidata, non applicata

Scope · Fonti pubbliche pertinenti al PNG che sceglie: dichiarazioni del round con messaggio/link/hash verificati e ultimo Fato pubblicato dello stesso run. Niente chat intera, whisper, prosa di altri run o conoscenze private di altri PNG. Il tentativo dichiarato non viene promosso a fatto risolto.

Contratti · Helper privato choice_public_context(session,actor,round,panel) chiamato da sostituzione precisa/pinned di choice_options candidata. Restituisce context/viewer invariati + public_sources. Ordine dopo Panel e Dispatcher; no grant client/service. Il dispatcher trasferisce oggetto autorizzato al prompt del solo PNG. Non modifica scelte, costi, esiti o testo generato; senza contesto pertinente il modello non riceve role inventate.

Prove · Lettura fonti native e composizione esatta; parser SQL statico. Nessun test funzionale, provider o DB apply. Da integrare nella review aggregata REV1; limiti di byte contabilizzati dal dispatcher prima della chiamata, senza tagliare role richieste.

Recovery · Runtime generico spento, storico preservato. Dipende dalle ricevute native già installate dai moduli precedenti. La nuova funzione resta privata; replace mantiene ACL di choice_options.

SHA-256 SQL · f9f7135332725e49a29946b58c1bfa0b96ed20e6b724823346a4744a67f71102
