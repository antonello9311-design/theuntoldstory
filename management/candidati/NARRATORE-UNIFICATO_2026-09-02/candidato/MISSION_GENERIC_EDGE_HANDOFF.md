# MISSION-GENERIC-EDGE-001 — consumer candidato

Stato: moduli implementati, non integrati in endpoint e non distribuiti. Owner NARRATIVE-MISSION, 11/09/2026. Nessuna chiamata provider o prova funzionale; controllo sintattico statico dei due moduli PASS.

## Scope e riuso

`mission-generic-runtime.mjs` lavora un solo evento server; `mission-generic-choice.mjs` sceglie un solo PNG attraverso le offerte Common. Nessun limite 2v2, nomi Nodo, massimo round Esame o seconda macchina di fasi. PG/PNG variabili sono proiettati dal server. Il modulo non interpreta né esegue trigger del grafo: il controller nativo resta responsabile dell'avanzamento.

Gli import riusano i moduli del candidato `exam_regia17/edge/src`: shared-scene/editorial, shared-scene/common, shared-scene/scene, shared-panel/validate e PROVIDER dai contracts esistenti. Tutti i file Esame restano invariati. Il consumer riusa il provider Responses esistente mediante dependency injection `provider.create({payload,signal})`; non introduce modelli o una pipeline estetica nuova. Il solo prompt di scelta è l'adattamento del prompt già usato per il PNG Esame, senza i riferimenti alla prova e al singolo controattacco.

Snapshot live consultati nella ricognizione: mission_narratore_ai v19 ACTIVE, combat_narratore_ai v25 ACTIVE, mission_ai_board_opening v2, nodo_azzurro_canary_coordinator v5. I tre moduli shared-scene sono byte-identici tra le due Edge vive. Nessuno di questi endpoint contiene ancora i nuovi moduli.

## Contratto adapter minimo per l'integratore

Non sono nomi di RPC installate: `db` è un adapter fidato con cinque metodi. Il routing HTTP deve autenticare l'utente/worker e autorizzare la sessione prima di costruire l'adapter; i nomi RPC non provengono dalla richiesta. Nessun accesso browser o provider è effettuato da questa consegna.

`runMissionEvent({request,db,provider,now?})` riceve esattamente:

```js
{
  schema_version: 'mission-generic-request/1',
  master_session_id: UUID,
  event_id: UUID,
  request_key: UUID,
  expected_revision: integerPositive
}
```

La visita dello step è identificata da `step_key` + `run_control_version`; non viene creato un secondo contatore. `definition_sha256` deve essere l'impronta del run snapshot congelato (`mission_generic_owner.run_bindings.snapshot_sha256`), non un hash della definizione aggiornata successivamente.

`db.claim(request,{signal})` restituisce `{state:'claimed',granted_now:true,work}` soltanto al titolare nuovo. Replay, lavoro già consumato o finale si recuperano via status senza provider. Work:

```js
{
  schema_version:'mission-generic-work/1', work_id:UUID,
  master_session_id:UUID, event_id:UUID, request_key:UUID, revision:integerPositive,
  step_key:string, run_control_version:integerPositive, definition_sha256:SHA256,
  encounter_id:UUID|null, authority_receipt_id:UUID,
  kind:'choice'|'narration', lease_id:UUID, server_now:ISODate, lease_expires_at:ISODate,
  payload_sha256:SHA256, payload:choicePayload|narrationPayload,
  limits:{provider_calls_remaining:integerPositive,max_output_tokens:integerPositive,
    max_input_bytes:integerPositive,max_request_bytes:integerPositive,
    transport_max_chars:integerPositive,provider_timeout_ms:integerPositive}
}
```

La claim deve attestare tutti i binding sessione/run/step/visita/incontro/attore. Il consumer controlla forma e coerenza di richiesta; non rilegge tabelle dal client. `payload_sha256` è opaco JSONB e deve essere riletto dalle RPC nelle fasi successive. La claim deve conservare l'evento immutabile e una richiesta coerente non deve restituire un altro work.

`db.status(request,{signal})` è sola lettura e restituisce un record con `schema_version:'mission-generic-status/1',work_id,master_session_id,event_id,request_key,revision,state,receipt_id,result_sha256`. Le conclusioni riconosciute sono `completed` e `failed`; altro stato o errore restituiscono `202` incerto e vietano rigenerazione.

`db.authorize(work,policy,{signal})` riceve policy `{model,reasoning_effort,max_output_tokens,store:false,payload_sha256}`. Deve rileggere claim/lease/versioni e budget della singola sessione. Restituisce `{work_id,authorization_id,granted_now:true,model,reasoning_effort,max_output_tokens,store:false}` solo per una nuova autorizzazione. Non creare un'autorizzazione multipla per tre chiamate.

`db.consume(work,permission,{signal})` consuma una sola autorizzazione e restituisce `{work_id,authorization_id,dispatch_id,granted_now:true}`. Tutti gli identificativi sono UUID. Alla risposta incerta non segue alcuna chiamata provider.

`db.finalize(work,delivery,resultSha256,{signal})` deve essere atomica: salvare risultato/audit e, solo con payload attuale, lease valido e `ok:true`, applicare il comando Common o pubblicare il testo. Il client non invoca gateway umano. La stessa chiave/hash restituisce la ricevuta originale; collisione rifiutata. Il comando PNG viene rivalidato interamente sul server, senza importare costi, PV, posizione o esiti dal modello. Se la lease è scaduta o l'evento superato, conservare l'audit di consumo ma non applicare né pubblicare. La risposta ha lo stesso schema di status e `result_sha256` uguale all'hash ricevuto. L'esito incerto viene osservato con status, non ritentato.

`delivery` contiene versione, binding di work/evento/richiesta/revisione/autorità/snapshot/payload, kind, runtime/editorial/choice version, authorization_id, dispatch_id, provider_calls (0 o 1), model, usage o null, usage_unknown, provider_status, impronte request/raw e `{ok,text,command}`. Include failure_codes e advisories quando pertinenti. L'impronta risultato usa canonical JSON intero a numeri sicuri dei moduli esistenti. Non contiene raw completo e non restituisce persona, capability o prosa alla risposta HTTP pubblica; la pubblicazione è del server.

## Payload choice

```js
{
  schema_version:'mission-generic-choice/1',actor_id:UUID,capability_id:UUID,
  command_request_key:UUID,persona:string,authorized_context:object,
  combat_session_id:UUID,round_id:UUID,context_version:integer,
  policy_id:string,simulated:boolean,legal_options:CommonPanelEnvelope
}
```

Il server proietta il pannello dal punto di vista del solo PNG comandato. Viewer senza permessi Master/Admin, un solo attore controllato, tutte le offerte dello stesso attore, stessi activity/round/contextversion/policy/simulated. Gli altri attori possono essere quanti previsti dal server. Persona non concede visibilità o tecniche. Output `combat-panel-command/1`, selezione validata con `selectionReady`; la command_request_key è scelta dal server, non dal modello. Il testo resta intenzione non risolta, non è un Fato pubblico separato.

## Payload narration e barriera

```js
{
  schema_version:'mission-generic-narration/1',mode:'combat'|'mission',
  barrier:{closed:true,required_receipt_ids:[UUID,...],receipt_ids:[UUID,...]},
  // mode combat:
  scene:CombatSceneEnvelope,scene_binding:CombatSceneBinding,
  // mode mission:
  context:MissionNarrativeContext
}
```

La barriera viene chiusa dal producer server soltanto dopo tutte le scelte e ricevute del segmento; comprende authority_receipt_id. Gli array sono univoci, nessuna receipt richiesta può mancare. Questi flag non autorizzano input client: la claim attesta il segmento. Combat usa scenePrompts e richiede binding `hash_authority:'combat_v2_sha256/jsonb'`, stessa scena e report. Il DB deve verificare l'appartenenza di quella sessione Combat all'encounter indicato; non è deducibile solo dai UUID.

Mission context ha esattamente `schema_version:'mission-narrative-context/1',master_session_id,step_key,run_control_version,definition_sha256,authority_receipt_id,location,actors,sources,resolved_facts`. Actors: stessi cinque campi di shared-scene (`id,name,kind,persona,may_speak`). Sources: `id,master_session_id,kind,actor_id,sequence,body,sha256,visibility,complete`; kind role/fato/setting/perception, fonti intere e hash verificati. Role e perception hanno autore presente; setting/Fato autore null. Ogni fonte appartiene alla stessa sessione. Facts sono la proiezione autorizzata del server, non l'intero stato interno. Nessun round o azione Combat fittizia per incipit/dialogo. Il producer deve includere tutte le role necessarie del segmento; il modulo non cerca la chat e non sceglie quali fonti omettere.

Per missione viene usato `editorialPrompt('mission_fato')` già esistente, con attribuzioni delle fonti identiche alla composizione Combat. Per Combat si usa direttamente shared scenePrompts. `inspectNarrative` verifica completezza del trasporto, blocco unico e capacità: non è un secondo giudice semantico né una prova che l'IA non possa sbagliare un fatto. Autorità e continuità dipendono dal producer/server e vanno collaudate nel sito.

## Budget e concorrenza

Una autorizzazione/consume e al massimo una provider.create per evento; nessun loop di missione o batch PNG dentro un dispatch. Tutto lo stato JS è locale all'invocazione. Budget generale dispatch180s, claim10s, authorize/consume5s ciascuno, provider cap120s con AbortSignal, finalize10s, status5s. La lease sottrae conservativamente anche il tempo trascorso dall'ingresso, senza assumere orologi sincronizzati. Cap esistenti: input49152B, request65536B, testo5000Unicode, output9992token. Il server può ridurre i limiti, non superarli dal payload.

Usage disponibile viene conservata; timeout/errore senza metrica rimangono `usage_unknown:true` e non sono falsificati come consumozero. Eventuali risposte tardive dopo timeout non autorizzano una seconda chiamata. L'audit della finalizzazione scaduta è requisito dell'adapter DB, non un bypass lease.

## Verifica e passaggio al PM

Node --check dei due moduli PASS. Nessun mock, banco, provider, browser, trigger o sessione creati. Le dipendenze devono essere comprese e pinzate nel bundle finale; i percorsi di import sono relativi al candidato attuale e l'integratore li rimappa se colloca i moduli in `src`. Esame non modificato.

Mancano per runtime live: adapter RPC con le garanzie sopra, writer dei work item dal controller/Combat, routing HTTP autenticato e composizione bundle/permessi; prova del sito e review indipendente della composizione. Questo candidato non può essere dichiarato attivo solo perché i moduli sono presenti. Il publisher umano e il vecchio opening a tre chiamate non sono fallback.

## Correzione aggregata A1 · RT-R1-02

Contratto aggiornato in MISSION_GENERIC_NARRATIVE_A1_HANDOFF.md: fallimento certo pre-provider autenticato e registrato senza tentativi/costi; applicazione finale in sottotransazione, con costi e audit conservati se respinta; timeout/consumo incerto non diventano fallimenti a costo zero. Stato uncertain osservabile senza retry o abort automatico; campo outcome_uncertain nella consegna. Nuova RPC service-only mission_generic_dispatch_reject_v1. Build Edge .2 e manifest riallineati. Nessun apply/deploy/provider; controverifica A1 pendente.
