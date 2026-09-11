# MISSION_GENERIC_COMBAT · A2 sintassi installazione · candidato congelato

Task MISSION-GENERIC-A2-SYNTAX. Stessa aggregata A2 avviata dal PM dopo rollback completo dell'installazione A1; il primo guard non acquisito per lock del manifest non crea un nuovo budget. Nessun apply o provider in questo incarico. Correzione solo grammaticale, senza cambio comportamento, dati, GRANT, vincoli o gate.

Nessun delta al SQL: byte e SHA A1 invariati.

SQL SHA256 `cb80d82231f59473d4aa13584d3e9e7a3360ff0b90e2cf0d09e5b53310431b5a` · 58263 byte. SHA A1 `cb80d82231f59473d4aa13584d3e9e7a3360ff0b90e2cf0d09e5b53310431b5a`. Controlli statici: 32 statement SQL top-level, 10 funzioni PL/pgSQL dirette e 6 blocchi DO analizzati. Nelle sole copie passate al parser sono stati sostituiti tipi compositi con RECORD e nomi funzione normalizzati; i file consegnati mantengono i tipi reali. È controllo di grammatica, non compilazione/schema resolution o test funzionale. Il serializer JSON del parser sui trigger è incompleto: usata la porta raw parse_plpgsql_json per attestare assenza di ParseError, senza utilizzare l'AST serializzato malformato.

Pin di composizione: le quattro funzioni interessate non sono target di pin prosrc nei moduli dipendenti; i pin SQL rimangono invariati. Sette pin prosrc tra candidate (OUTCOME, CHOICE_SOURCES, PROVIDER_GATE) ricalcolati PASS sulla composizione corrente. Manifest di modulo riallineato ai file SQL correnti. Le patch DO e i nuovi IF emessi da Progress/ProviderGate sono stati censiti: i CASE dentro argomenti di funzione sono già delimitati; nessun cambio ai loro testi dinamici richiesto da questo difetto. Il parsing del DO non esegue né materializza automaticamente i DDL dinamici.

Consegna al PM: unica freeze A2, controverifica indipendente pertinente ancora richiesta. Nessuna autoreview 0/0/0 dedotta dalla statica. Recovery e contratto funzionale seguono la consegna precedente riportata qui come contesto; nessun SQL applicato dall'owner A2.

## Contratto funzionale precedente conservato

TASK-ID · MISSION-GENERIC-COMBAT-001 · candidata pronta per integrazione e review, non applicata

Scope toccato: solo MISSION_GENERIC_COMBAT.sql e consegne. Database interrogato in sola lettura l’11/09; nessun browser, provider, gioco o apply. Sito invariato.

Contratti: mission_generic_owner.run_bindings/snapshot e scene() da DB-MISSION. Tabella encounters(master_session_id,encounter_id PK,step_key,run_control_version,encounter_key,request_key,request_fingerprint,capability_id,actor_map,created_at,open_receipt). actor_map JSON array PNG {actor_key,actor_id,mechanical_binding_id}; PG {actor_key:'pg:'+character_id,actor_id,character_id}. Principal PNG uuid5(actor_id,'mission-generic-principal'), capability distinta come authority del claim. Nessuna identità umana impersonata.

API nuove service_role: mission_generic_combat_open_v1(uuid,text,bigint,uuid), mission_generic_combat_close_v1(uuid,uuid,bigint,uuid). Apertura deriva PG attivi e PNG/team dalla configurazione congelata, costruisce offerte native con pin e crea mappa nativa atomicamente. Replay stesso request restituisce ricevuta; collisioni e revisioni diverse falliscono. Chiusura richiede risolto e tutti round narrati, registra evento server e chiude soltanto incontro/arena tramite lifecycle nativo. Restituisce terminal_event_id per transizione server della missione.

Core: copia nominata privata del solo ingresso Ninja Book, sette sostituzioni puntuali dalla baseline live pinned. Rimosso riferimento Nodo soltanto dalla copia, sostituito con binding congelato approvato. I limiti tecnici nativi 1..12 PG e 1..12 PNG restano; nessuno scontro per scena senza PNG. Nessun secondo resolver. Il core originario e i percorsi Nodo/Ronda/Esame/ordinary non sono riscritti.

Arena: profilo e claim per incontro, source panel_master, catalogo e hash congelati; slot server ordinati e collisioni native, nessuna coordinata client/IA. Sono supportate le zone arena attualmente pubblicate; zone ulteriori devono essere implementate nel catalogo prima di usarle. Unica arena aperta per Master, storico precedente conservato per encounter. Il vincolo assoluto precedente sul master è sostituito da indice parziale; trigger aggiuntivo mantiene l’unicità assoluta sui percorsi legacy. Verificato in DB: zero FK dipendenti dal vecchio indice; censiti 28 riferimenti arena/master. Consumer di stato/scambi usano encounter/instance o aggregazione dello storico; i vecchi offer/bind che negano più arene restano invariati, il Generic usa il proprio ingresso.

Hook nativi pinned: enroll_master e master_entry_trigger accettano soltanto run Generic ai_service/capability congelata, mantenendo i vecchi rami; uses_simulated_pools controlla Generic claim+policy+PG Staff reali senza NULL dei PNG; universal_arena_state mantiene autorizzazione PG e aggiunge solo principal PNG attestato da execution permit tramite hook ROOT; exchange_owner_receipt usa la stessa ricevuta spaziale con cardinalità roster reale, non 2v2. Actor_principal/current_principal/master_state_authoritative sono DELTA ROOT separati necessari alla composizione.

Continuità: copia PV/chakra dall’ultimo incontro chiuso dello stesso run e attore stabile; primo ingresso usa snapshot nativo. Massimi cambiati falliscono; nessun ripristino gratuito. PG/PNG a PV zero sono fuori. Nessuna scrittura characters, inventario, XP, grado o flag is_test. Prima dello scontro successivo il precedente deve essere chiuso con ricevuta; non vengono chiuse automaticamente scene altrui.

Prove: 32 statement SQL parse PASS con pglast; 7 sostituzioni univoche core. Le definizioni vive e ACL/owner/search_path delle 6 funzioni baseline sono pin nel manifest/migrazione. Il parser PL/pgSQL non risolve namespace privati e rowtype: nessuna compilazione o funzionalità attestata. Nessun ambiente ricreato. Gameplay live da eseguire solo dopo review della composizione e rilascio autorizzato.

Rischi/regressioni: review pertinente deve controllare hook dinamici, ordering trigger/capability/binding, mapping principal ROOT, CAS dei passaggi e interazioni con narratore/resolve. Schema/plugin live vince sulla candidata. Apertura multipla e chiusura terminale da verificare sul sito protetto, inclusi persistenza risorse e assenza premi/scritture esterne. Le capacità native di chiamata/valutazione/resolve/narrativa restano nella composizione worker ROOT; il solo file Combat non rende il worker completo.

Recovery: tenere il runtime Generic spento prima del primo collaudo; in difetto sospendere dispatch e conservare scene/audit. Non ripristinare UNIQUE assoluta quando esistono più arene storiche, non rimuovere gli hook di protezione mentre ci sono scene Generic. L’eventuale spegnimento mode rende non eseguibili anche ingressi operativi: prima della disattivazione completa chiudere le sole prove autorizzate tramite il percorso terminale oppure consegnare stato sospeso. Nessuna cancellazione di dati o reset schede.

Passaggio PM: integrare DB + Combat + Common service + worker, review indipendente prima di apply/deploy/enable. Aggiornare SCHEDA/HANDOFF/STORICO e MISSIONI_IA/PIATTAFORMA centrali; questo sottotask non ne acquisisce proprietà. Il rilascio e la prova restano non eseguiti.
