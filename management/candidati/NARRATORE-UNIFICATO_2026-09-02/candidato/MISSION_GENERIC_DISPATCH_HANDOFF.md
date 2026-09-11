# MISSION_GENERIC_DISPATCH · A2 sintassi installazione · candidato congelato

Task MISSION-GENERIC-A2-SYNTAX. Stessa aggregata A2 avviata dal PM dopo rollback completo dell'installazione A1; il primo guard non acquisito per lock del manifest non crea un nuovo budget. Nessun apply o provider in questo incarico. Correzione solo grammaticale, senza cambio comportamento, dati, GRANT, vincoli o gate.

Nessun delta al SQL: byte e SHA A1 invariati.

SQL SHA256 `03d6d4c5158e7a72fe11e0721ccb97023e4de3c4ae2073070eb2efea4d0a7aa0` · 48514 byte. SHA A1 `03d6d4c5158e7a72fe11e0721ccb97023e4de3c4ae2073070eb2efea4d0a7aa0`. Controlli statici: 33 statement SQL top-level, 16 funzioni PL/pgSQL dirette e 0 blocchi DO analizzati. Nelle sole copie passate al parser sono stati sostituiti tipi compositi con RECORD e nomi funzione normalizzati; i file consegnati mantengono i tipi reali. È controllo di grammatica, non compilazione/schema resolution o test funzionale. Il serializer JSON del parser sui trigger è incompleto: usata la porta raw parse_plpgsql_json per attestare assenza di ParseError, senza utilizzare l'AST serializzato malformato.

Pin di composizione: le quattro funzioni interessate non sono target di pin prosrc nei moduli dipendenti; i pin SQL rimangono invariati. Sette pin prosrc tra candidate (OUTCOME, CHOICE_SOURCES, PROVIDER_GATE) ricalcolati PASS sulla composizione corrente. Manifest di modulo riallineato ai file SQL correnti. Le patch DO e i nuovi IF emessi da Progress/ProviderGate sono stati censiti: i CASE dentro argomenti di funzione sono già delimitati; nessun cambio ai loro testi dinamici richiesto da questo difetto. Il parsing del DO non esegue né materializza automaticamente i DDL dinamici.

Consegna al PM: unica freeze A2, controverifica indipendente pertinente ancora richiesta. Nessuna autoreview 0/0/0 dedotta dalla statica. Recovery e contratto funzionale seguono la consegna precedente riportata qui come contesto; nessun SQL applicato dall'owner A2.

## Contratto funzionale precedente conservato

# MISSION-GENERIC-DISPATCH-001 — adapter candidato

Stato: implementato in candidato; nessun apply, deploy, chiamata provider o collaudo. Owner NARRATIVE-DISPATCH. Completa le cinque operazioni DB richieste dal runtime e un ingresso HTTP autenticato. L'integrazione del bundle e la review del candidato composto restano al PM.

## Output e ordine di integrazione

- `MISSION_GENERIC_DISPATCH.sql`: due tabelle private, 17 funzioni e un trigger AFTER INSERT; nuove RPC esclusivamente service_role. Richiede prima la fondazione DB generica, la tabella board_starts del Board e il mapping incontri/Panel del root. I corpi degli hook Combat privati devono essere composti nello stesso rilascio; non basta la presenza dei nomi.
- `mission-generic-http.mjs`: importa runtime candidato e canonical condiviso; `handleMissionGeneric(req,{admin,provider,workerToken})` con Auth.getUser reale, CORS dominio, body massimo8192B e lettura con scadenza10s, identità ricavata dal token. Nessun id utente, RPC, scena o token di worker accettato dal client.

Il root ha scelto l’ingresso Edge `mission_generic_ai`, richiamato con client.functions.invoke e normale sessione Auth. Collegare handleMissionGeneric a questo entrypoint usando client service e provider Responses già esistenti; passare MISSION_NARRATIVE_WORKER_TOKEN dal runtime Edge. È un ingresso sottile al runtime condiviso, senza nuovo motore o prompt. Il nome non attiva da solo il servizio: entrypoint e deploy restano al root. Esame non è toccato.

## Porte effettivamente implementate nel candidato

| Operazione | RPC pubblica service-only |
|---|---|
| Individua un evento | `mission_generic_dispatch_next_v1(p_session uuid,p_user uuid)` |
| Claim | `mission_generic_dispatch_claim_v1(p_user uuid,p_request jsonb)` |
| Rifiuto prima provider | `mission_generic_dispatch_reject_v1(p_user uuid,p_request jsonb,p_lease uuid,p_code text)` |
| Stato | `mission_generic_dispatch_status_v1(p_user uuid,p_request jsonb)` |
| Autorizza | `mission_generic_dispatch_authorize_v1(p_work uuid,p_lease uuid,p_worker_token text,p_policy jsonb)` |
| Consuma | `mission_generic_dispatch_consume_v1(p_work uuid,p_lease uuid,p_worker_token text,p_authorization uuid,p_dispatch_token text)` |
| Finalizza | `mission_generic_dispatch_finalize_v1(p_work uuid,p_finalize_token text,p_result_text text,p_result_sha text)` |

Next espone solo richiesta/ID e stato, non payload PNG o persona. POST `{operation:'next',master_session_id}` è una lettura e non chiama il provider; la successiva richiesta tipizzata del runtime lavora un singolo evento. `createMissionDbAdapter` implementa il collegamento vero a queste RPC; il token finale resta solo nella memoria della singola invocazione. Finalize verifica SHA256 del testo canonico esatto prima di convertirlo in JSONB, evitando equivalenze presunte fra serializzazioni.

Il tick HTTP `{schema_version:'mission-generic-tick/1',master_session_id,request_key}` invoca la porta service-only `mission_generic_progress_v1(session,user,request)` del consumer di avanzamento. Il server deriva incontri, attori, trigger e il descriptor `.dispatch`. Se null, ritorna solo lo stato; altrimenti esegue quel singolo evento tramite runMissionEvent e restituisce progress con `.delivery`. Nessun loop o retry interno. Progress e relativi GRANT appartengono al modulo MISSION_GENERIC_PROGRESS.sql; il client non fornisce PG, scena, valori o evento da inventare.

Tutte le RPC entrano con service_role. Next/claim/status verificano p_user contro partecipazione attuale e proprietà corrente del PG, oppure ruolo staff/admin; l'HTTP ottiene p_user soltanto da Auth.getUser. Authorize/consume/finalize richiedono inoltre lease/capability/token del dispatch. Helpers privati non hanno grant service, authenticated o anon. Nessuna impersonazione Auth di PG o PNG.

## Producer server e pubblicazione

`enqueue_opening(session,start_receipt)` deriva il contesto dalla ricevuta privata board_starts prepared e dall'evento nativo bind committed, step iniziale/CV1 e outbox pending. Master/run devono essere in preparazione e i partecipanti già registrati. Snapshot verificato con fingerprint nativa; briefing, obiettivo e roster vengono letti dal server. Non simula una scelta o un round. Il Board owner conferma tabella, evento, ordine partecipanti e hook `opening_published(session,publication)`.

`narrative_context` è l'unico helper per contesti opening/transizione; evita copie del renderer o del producer.

`enqueue_transition(session,trigger_receipt)` legge la ricevuta generica immutabile e l'evento nativo `mission_run_events` già committed; step/revisione dopo transizione devono coincidere con il run. Snapshot, obiettivi approvati, roster, versioni Ninja Book e role native complete sono riletti dal server. Le role sono solo say pubbliche dei partecipanti/autori, nella finestra della sessione e fino alla ricevuta; nessuna role viene inviata dal client alla porta. Il Fato generico precedente viene mantenuto come fonte di continuità completa. Persona pubblicabile missione limitata a nome/voice/gestures dei pin approvati, senza knowledge_boundary, memoria, obiettivi privati o scheletro intero.

Un trigger AFTER INSERT sulle sole nuove `mission_generic_owner.trigger_receipts` chiama enqueue nella stessa transazione del controller, assicurando una work item per la nuova fase. Replay nativo non reinserisce la ricevuta. La macchina di avanzamento resta `mission_internal.transition`.

`enqueue_choice(session,encounter,actor)` ottiene offerte e persona dal solo hook Panel privato `choice_options(session,actor,work,request)`; capID è la ricevuta d'autorità. Non riceve pannelli o JSON dal client. Ricerca prima un work pending per lo stesso attore/incontro. Persona privata restituita dal Panel viene serializzata come stringa per il consumer, senza copiarla nella risposta HTTP o nel messaggio. Il modello sceglie tramite Common e finalize richiama `choice_commit(work,capability,command)`, poi verifica `panel_choices.result/consumed_at/command_sha256` e la ricevuta Common per principal/request/offer/event e envelope esatto. Non basta un JSON non nullo per dichiarare il comando applicato.

`enqueue_combat(session,event)` usa event=report_id nativo e il hook root `combat_narrative_source`. Richiede `{master_session_id,step_key,run_control_version,encounter_id,authority_receipt_id,payload}`; payload mode combat contiene scena/binding e barriera chiusa. Il producer root è responsabile di appartenenza incontro/report/attori e di tutte le ricevute richieste. Nessuna porta pubblica può inserire una scena arbitraria.

Finalize distingue:

- Scelta: commit Common legale; il hook Common ristretto del root pubblica il tentativo PNG con link alla dichiarazione e autore Fato nella stessa transazione. È un intento ancora da risolvere, distinto dal successivo esito dopo report completo. Il dispatcher non duplica questo messaggio e non chiama post_fato_manual come utente.
- Narrazione Combat: `combat_publish(work_id,text,request_key)` privato root deve chiamare lo store nativo di narrazione e restituire `{message_id:UUID,...}`; il dispatcher verifica l'esistenza del messaggio nella stanza. Nessun inserimento duplicato da questo ramo e nessun round successivo aperto dal dispatcher.
- Narrazione di opening o transizione: inserisce un vero messaggio `kind='fato'`, autore Fato, character/sender/recipient null. Registra `mission_run_publications` e `mission_run_messages` con evento/versione/context/bodySHA e aggiorna `mission_run_outbox` a published nella stessa transazione, usando la guardia nativa. Pubblica soltanto dopo la barriera e non crea segment grant/reveal fittizi: le fonti non attestano nuove rivelazioni. Per opening, solo dopo Fato, publication e outbox published, chiama opening_published nella stessa transazione: il Board attiva il run e applica la propria quota ordinaria; nella simulazione non applica quota/premi. Nessun premio, inventario o avanzamento del grafo implicito.

## Contabilità, lock e limiti

Riusati senza modifiche ai corpi: `mission_narrative_attempt_reserve_internal`, `mission_narrative_provider_authorize_internal`, `mission_narrative_provider_consume_internal`. Una autorizzazione corrisponde a una sola chiamata. Le riserve globali native serializzano solo la breve transazione di budget; non trattengono un lock durante il provider. I work e le lease sono per evento/sessione. L'ordine di scrittura è sessione→work→contabilità.

Nuova `dispatch_admissions` impone anche call_limit e cost_budget_usd espliciti per sessione. Nessuna riga di admission viene creata automaticamente: il setup della prova, dopo budget deciso, usa il helper privato `dispatch_admit(session,calls,cost)`. Le nuove tabelle private hanno RLS e nessun accesso diretto. La funzione ammette solo una configurazione coerente, non raddoppia quote al replay.

Fotografia viva letta in questa ricognizione: runtime_policy missione enabled=false, policy1, Luna/high, max_input_tokens12000 e max_output_tokens4096; budget run/day/global null. Il candidato non cambia queste impostazioni. Le quote specifiche generic impediscono che null diventi consumo illimitato. La richiesta intera ha un limite byte conservativo <=budget input token nativo; input/output sono separati, nessuna sottrazione dei4096output dall'input. La coppia attuale produce max_input_bytes12000, max_request_bytes12000, output4096. Contesti superiori sono rifiutati esplicitamente, mai tagliati. L'adeguatezza del budget va misurata nel sito e configurata prima del collaudo.

Usage valida conserva il costo effettivo, anche se supera la riserva (in tal caso risultato non pubblicabile); usage sconosciuta conserva upper_bound e stato contabile unknown_billable. Un testo/comando scaduto non viene applicato ma il costo resta registrato. Lo stato prodotto completed/failed/uncertain è separato dallo stato contabile. Nessun retry del provider o della mutazione quando la risposta è incerta.

## Vincoli cambiati esplicitamente

1. `dispatch_receipts_event_kind_check`: aggiunge solo `mission_generic_event`, conserva tutti i precedenti valori.
2. `dispatch_receipts_renderer_version_check`: aggiunge solo `mission-generic-runtime/1`.
3. Nuovo `dispatch_receipts_generic_pair_check`: i due nuovi valori devono apparire insieme; non si etichetta l'evento generico come una fase Nodo o opening legacy.
4. Due nuove tabelle: PK/FK, unicità sessione/evento e sessione/richiesta/dedupe, impronte, stati chiusi, stato terminale↔finalized_at e budget positivo/counter entro cap. Nessun vincolo messages o risorse reali modificato.

Schema/check/trigger messages verificati sul vivo in sola lettura: `fato` è ammesso e il solo trigger autojoin ignora messaggi privi di PG valido; nessun gettone role viene creato. Native publication/outbox metadata e guardie letti; nessun INSERT eseguito per verificarli.

## Verifiche e limiti rimasti

Statico JavaScript: Node --check PASS. Parser pglast già disponibile: parse SQL esterno PASS,33statement; delimitatori bilanciati,17funzioni e terminatori END controllati. I corpi PL/pgSQL con rowtype privati non sono compilati né eseguiti in PostgreSQL: questo controllo non attesta risoluzione colonne/firme o funzionalità. Nessun ambiente/banco ricreato o installato. Review indipendente della composizione richiesta prima dell'apply.

Restano al root: composizione ordinata DB→Board tabelle→encounter/Panel→Dispatcher/Sources→Progress (riferimenti incrociati fra helper PL/pgSQL); entrypoint e chiamante sito del nuovo HTTP; configurazione admission/gate/policy; review ed effettivo collaudo. I corpi source/publish Combat sono ora consegnati dal root nel modulo MISSION_GENERIC_SOURCES.sql: devono essere inclusi e verificati nella composizione; il loro limite dichiarato esclude i companion non ancora supportati, con errore esplicito. Il Board implementa il proprio limite chiamate/costo nullable inizialmente non configurato e invoca dispatch_admit prima dell’incipit. Il semplice next non esegue una missione in background. La dichiarazione PNG non deve cadere nel post_fato_manual umano.

Limiti da verificare: finestra role e roster in caso di uscita dalla missione; expiry delle offerte Panel prima della prima claim; gestione operativa di evento fallito o provider billable rimasto incerto. Nessun reset automatico del work e nessuna seconda chiamata dopo consumo. Se un evento resta failed/unknown, le barriere mantengono la missione ferma: non viene aggirata per far avanzare la storia.

Recovery conservativa: chiudere l'admission della sola sessione e il gate generic prima di cambiare hook; conservare work, ricevute, costi, messaggi e outbox. Non eliminare righe o ripristinare risorse PG. La recovery non è stata eseguita e non è un nuovo consenso a un apply.

## Correzione aggregata A1 · RT-R1-02

Contratto aggiornato in MISSION_GENERIC_NARRATIVE_A1_HANDOFF.md: fallimento certo pre-provider autenticato e registrato senza tentativi/costi; applicazione finale in sottotransazione, con costi e audit conservati se respinta; timeout/consumo incerto non diventano fallimenti a costo zero. Stato uncertain osservabile senza retry o abort automatico; campo outcome_uncertain nella consegna. Nuova RPC service-only mission_generic_dispatch_reject_v1. Build Edge .2 e manifest riallineati. Nessun apply/deploy/provider; controverifica A1 pendente.
