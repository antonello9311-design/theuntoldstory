# MISSION_GENERIC_SOURCES · A2 sintassi installazione · candidato congelato

Task MISSION-GENERIC-A2-SYNTAX. Stessa aggregata A2 avviata dal PM dopo rollback completo dell'installazione A1; il primo guard non acquisito per lock del manifest non crea un nuovo budget. Nessun apply o provider in questo incarico. Correzione solo grammaticale, senza cambio comportamento, dati, GRANT, vincoli o gate.

Nessun delta al SQL: byte e SHA A1 invariati.

SQL SHA256 `b00cb739df02342f218575ef7f2b5359a439495ccb2fbfb65500165b50876152` · 16779 byte. SHA A1 `b00cb739df02342f218575ef7f2b5359a439495ccb2fbfb65500165b50876152`. Controlli statici: 7 statement SQL top-level, 3 funzioni PL/pgSQL dirette e 1 blocchi DO analizzati. Nelle sole copie passate al parser sono stati sostituiti tipi compositi con RECORD e nomi funzione normalizzati; i file consegnati mantengono i tipi reali. È controllo di grammatica, non compilazione/schema resolution o test funzionale. Il serializer JSON del parser sui trigger è incompleto: usata la porta raw parse_plpgsql_json per attestare assenza di ParseError, senza utilizzare l'AST serializzato malformato.

Pin di composizione: le quattro funzioni interessate non sono target di pin prosrc nei moduli dipendenti; i pin SQL rimangono invariati. Sette pin prosrc tra candidate (OUTCOME, CHOICE_SOURCES, PROVIDER_GATE) ricalcolati PASS sulla composizione corrente. Manifest di modulo riallineato ai file SQL correnti. Le patch DO e i nuovi IF emessi da Progress/ProviderGate sono stati censiti: i CASE dentro argomenti di funzione sono già delimitati; nessun cambio ai loro testi dinamici richiesto da questo difetto. Il parsing del DO non esegue né materializza automaticamente i DDL dinamici.

Consegna al PM: unica freeze A2, controverifica indipendente pertinente ancora richiesta. Nessuna autoreview 0/0/0 dedotta dalla statica. Recovery e contratto funzionale seguono la consegna precedente riportata qui come contesto; nessun SQL applicato dall'owner A2.

## Contratto funzionale precedente conservato

TASK-ID · MISSION-GENERIC-SOURCES-FIELD-001 · candidata, nessun apply

Scope toccato · Producer combat-scene/1 da referto risolto e fonti Common; publisher nativo per il lavoro IA; estensione pinned publish_master_declaration per tentativi PNG con autorità generica attiva. Il ramo nuovo registra soltanto il tentativo in Fato e la ricevuta declaration_messages, senza post_fato_manual con identità fittizia. Gli altri rami rimangono identici.

Contratti · combat_narrative_source(session,report_id) restituisce master_session_id, step_key, run_control_version, encounter_id, authority_receipt_id=report_id e payload narration combat con barriera chiusa/report risolto, scene e scene_binding. combat_publish(work,text,request) rilegge e confronta payload, richiede stato provider_started e lease attiva, chiama combat_v2_narrative_store e restituisce data: narrative_id/message_id/next_round_id/encounter_resolved. Tutte le nuove funzioni private, revocate anche a service_role.

Decisioni · Fatti delle dichiarazioni dal resolver tramite proiezioni narrative native, non intero mechanics privato. Role da link e hash Common verificati, per PNG ulteriore capacità consumata/request_receipt coerente. Le difese automatiche senza testo sono fatti e non role fabbricate. Personalità pubblicabile PNG limitata a voice/gestures; conoscenze private non trasferite. Le fonti richieste non vengono tagliate. Continuità include ultima pubblicazione missione del run e precedenti Fato dello stesso incontro, entro limite. Scope iniziale attori PG/PNG del roster; un compagno privo del provider narrativo richiesto produce errore esplicito, non viene inventato.

Prove · Schema/corpi nativi letti dal DB vivo; pglast SQL parse PASS 7 statement; nessuna compilazione corpi PL/pgSQL/schema, prova funzionale locale, chiamata IA o apply. Fonte condivisa Esame usata come contratto ma non richiamata con ID falsi. Il nuovo ramo Common ha pin prosrc MD5 della baseline salvata.

Rischi/limiti · Review aggregata necessaria prima installazione. Fonti dichiarazioni vuote falliscono esplicitamente. Limite attuale scena 12000 byte va composto col budget effettivo dispatcher, per evitare chiamate già impossibili. Non dichiara funzionante il consumer Edge o il tick finché non integrati e provati sul sito. Composizione dopo DB, Combat, Panel, Dispatch (dipendenza work_items); dispatcher può definire prima il richiamo al publisher PL/pgSQL. Nessun grant aggiuntivo sulle funzioni vive.

Recovery · Runtime generico off, preservando storico e risorse simulate. Baseline contiene solo funzione toccata, da riconciliare prima di ogni recupero.

SHA-256 SQL · b00cb739df02342f218575ef7f2b5359a439495ccb2fbfb65500165b50876152
