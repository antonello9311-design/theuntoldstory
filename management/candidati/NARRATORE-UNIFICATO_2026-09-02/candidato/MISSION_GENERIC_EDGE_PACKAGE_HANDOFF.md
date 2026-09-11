# MISSION-GENERIC-EDGE-PACKAGE-001

Stato: candidato consegnato, non pubblicato. Owner NARRATIVE-PACKAGE. Scope: ingresso Deno per `mission_generic_ai`, manifest del bundle e collegamento ai moduli già consegnati. Nessuna modifica al consumer Esame o a prompt/provider condivisi.

## Ingresso completo

`mission-generic-index.ts` avvia `Deno.serve`, costruisce il client Supabase service con session persistence/refresh disabilitati e passa il provider Responses esistente a `handleMissionGeneric`. Le credenziali vengono lette solo dal runtime distribuito; nessuna chiave è stata letta o stampata durante la preparazione. Build: `mission-generic-ai/2026-09-11.2`, restituita nell'header `x-mission-build`.

Il bundle usa invariato `exam_regia17/edge/src/provider.mjs`: una POST Responses, AbortSignal del runtime, parsing JSON e metriche reali, conservazione di provider_result in caso di formato invalido, nessun retry o modello alternativo. Il timeout, il limite di output e la prenotazione dei costi restano nel runtime generico e nelle RPC native già composte. L'ingresso non imposta modelli o nuovi prompt.

Il browser invoca `client.functions.invoke('mission_generic_ai', {body: {schema_version:'mission-generic-tick/1',master_session_id,request_key}})` con la propria sessione. Il handler verifica Bearer tramite `admin.auth.getUser`, quindi Progress deriva scena e lavoro sul server. Il tick esegue al massimo un work. Restano supportati next di sola lettura e mission-generic-request/1 per il lavoro già emesso dal server.

CORS ammette soltanto `https://theuntoldstory.it` e `https://www.theuntoldstory.it`; metodi POST/OPTIONS e header authorization/apikey/content-type/x-client-info. Le risposte sono JSON no-store. Errori inattesi restituiscono solo un codice generico e retry false, senza dettagli di configurazione o provider. Auth e scope delle RPC sono necessari anche per richieste senza Origin.

## Composizione e porte

Il manifest elenca gli undici file del bundle, con percorso di sorgente, percorso relativo nel bundle, byte e SHA256. Mantenere esattamente questi percorsi; entrypoint `mission-generic-index.ts`. L'unico import esterno è `jsr:@supabase/supabase-js@2`, lo stesso riferimento del consumer nativo letto. Non è stato scaricato o aggiornato per questa consegna; la risoluzione effettiva del pacchetto va registrata al deploy.

Il manifest indica `verify_jwt:false`: l'autenticazione esplicita è nel handler tramite getUser e le RPC sono service-only, senza affidarsi al vecchio controllo JWT del gateway. Non pubblicare le RPC a anon/authenticated per aggirare errori di configurazione.

Il contratto adapter è già implementato in mission-generic-http.mjs:

- claim/status con p_user derivato da Auth e p_request;
- authorize con work/lease/worker/policy;
- consume con work/lease/worker/authorization/dispatch_token;
- finalize con work/finalize_token/testo canonico/SHA;
- next e progress passano l'utente Auth reale; progress riceve anche request UUID e non valori di gioco.

Nomi completi delle otto RPC nel manifest. Non vengono inventati nuovi metodi DB o nomi RPC. La configurazione richiede i quattro nomi ambiente riportati nel manifest, senza duplicare credenziali nel client o nei file.

## Verifiche, dipendenze e passaggio al PM

Controllo sintattico dell'entrypoint JavaScript compatibile TypeScript: PASS. Grafo statico: undici file locali risolti, hash congelati. I moduli HTTP/runtime erano già verificati con import reale locale senza invocazione. Deno non è disponibile in questo host: non si dichiara una compilazione Deno o un deploy riuscito. Nessun ambiente ricreato, chiamata provider o test funzionale.

Prima dell'operazione dipendente servono composizione e review pertinenti di DB/Board/Panel/Sources/Progress/Dispatcher, ingressi del sito e configurazione esplicita dei gate/quote. Il manifest è un elenco distribuibile, non attiva la funzione né il runtime. Le funzioni SQL e il bundle devono essere quelli della stessa composizione; drift negli input invalida i pin.

Recovery conservativa: chiudere admission/gate della funzione generica, preservare work, contabilità, messaggi e storico. Nessuna modifica a Esame, cron esistenti, credenziali o risorse PG. Apply, deploy e provider eseguiti: zero.

## Correzione aggregata A1 · RT-R1-02

Contratto aggiornato in MISSION_GENERIC_NARRATIVE_A1_HANDOFF.md: fallimento certo pre-provider autenticato e registrato senza tentativi/costi; applicazione finale in sottotransazione, con costi e audit conservati se respinta; timeout/consumo incerto non diventano fallimenti a costo zero. Stato uncertain osservabile senza retry o abort automatico; campo outcome_uncertain nella consegna. Nuova RPC service-only mission_generic_dispatch_reject_v1. Build Edge .2 e manifest riallineati. Nessun apply/deploy/provider; controverifica A1 pendente.
