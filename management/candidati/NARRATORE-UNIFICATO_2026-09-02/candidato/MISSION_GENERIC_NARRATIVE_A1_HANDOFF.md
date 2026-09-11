# MISSION-GENERIC-NARRATIVE-A1

Stato: correzione aggregata A1 candidata per RT-R1-02; non applicata. Owner NARRATIVE-A1. Unica consegna per controverifica aggregata, nessuna autoqualificazione. Build Edge `mission-generic-ai/2026-09-11.2`.

## Correzione

Il runtime registra ora i fallimenti certi di validateWork o della costruzione della richiesta tramite `mission_generic_dispatch_reject_v1(p_user,p_request,p_lease,p_code)`. HTTP passa soltanto l'utente ottenuto da Auth.getUser e la lease ricevuta dalla claim; non espone questa operazione come comando browser autonomo. Sono ammessi due codici stabili, senza riportare dati del payload o messaggi di errore arbitrari.

Il server richiede il work claimed e la lease corrispondente, receipt nativa claimed, dispatch_count0 e assenza di qualsiasi tentativo o autorizzazione. Solo allora registra failed, ricevuta e audit pre-provider con costo0/chiamate0. Non crea metriche fittizie e non consuma l'admission. Una risposta incerta alla registrazione viene osservata tramite status: non si ripete la mutazione. Una claim malformata senza lease valida non autorizza a chiudere alcun lavoro.

Finalize racchiude il solo commit Common/pubblicazione in una sottotransazione PL/pgSQL. Un rifiuto applicativo annulla tutte le scritture di dominio del blocco, azzera soltanto i riferimenti locali a pubblicazioni non avvenute e registra fuori dal blocco costi/receipt/audit e stato failed. Il risultato originale del provider resta conservato; application_error_sqlstate distingue l'errore di applicazione dall'esito del modello. Nessun messaggio, comando parziale o avanzamento sopravvive al blocco annullato.

Timeout/esito provider non osservabile restano `uncertain`, con costo nativo exact/upper_bound e ricevuta conservati. Il work non torna ready e non viene rigenerato; next/status lo mantengono osservabile e HTTP risponde202. L'incertezza durante authorize/consume resta nella precedente osservazione senza inventare provider_calls0. Il Board può abortire soltanto un opening failed certo, mai questo stato uncertain. Se un rifiuto finale non viene confermato dal server, il runtime osserva status e conserva pending: nessun retry provider/finalize.

| Esito | Stato work | Contabilità e scritture |
|---|---|---|
| Validazione locale fallita prima di reserve | failed | zero dimostrato dal server, nessun tentativo/autorizzazione |
| Risposta provider completa ma invalida | failed | usage reale o upper_bound nativo, nessun comando/testo |
| Timeout o risposta provider non osservata | uncertain | costo conservato, nessun nuovo tentativo o apertura automatica |
| Commit/publish respinto | failed | dominio rollback atomico, costi e audit conservati fuori sottotransazione |
| Commit/publish riuscito | completed | invariato: una applicazione e ricevuta nativa |

## Contratti e pin

Nuova RPC di rifiuto service-only, aggiuntiva alle cinque operazioni originarie e next/progress. Nuovo campo booleano `outcome_uncertain` nella consegna provider; SQL e runtime vanno composti/distribuiti insieme. Work_items ammette lo stato uncertain con finalized_at contabile valorizzato; è definitivo per il tentativo, ma non autorizza la chiusura narrativa. La tabella privata non cambia permessi. Vincoli nativi invariati: i loro stati failed/unknown_billable e costi0 sono già ammessi e verificati sul catalogo vivo.

ProviderGate ricontrollato contro la nuova Dispatch: claim/authorize/consume non cambiano corpo in A1, quindi i loro tre pin prosrc risultano identici. Anche i tre pin nativi restano invariati. Il manifest ora lega esplicitamente il nuovo SHA del file Dispatch; non è stato inventato un nuovo pin soltanto perché cambia una funzione diversa. La policy legacy resta spenta e i prezzi non cambiano.

Manifest Edge/runtime/Dispatch/ProviderGate/package aggiornati insieme; undici file del bundle con nuovi SHA per runtime, HTTP e index. Choice e shared-scene/provider/Common restano byte-identici. Il pacchetto include la nuova RPC nel contratto e build .2.

## Controlli e limiti

Controlli statici: sintassi Node di runtime/HTTP/index, parsing SQL esterno Dispatch33statement/17funzioni e ProviderGate20statement; ricontrollo dei sei pin e delle dipendenze del bundle. Corpi PL/pgSQL non compilati in PostgreSQL; nessun test funzionale, fault injection, provider, ambiente ricreato, apply, deploy o enable. Il fatto che la mutazione canonica sia consegnata con task_guard non è un apply al database.

Resta alla controverifica indipendente A1 confermare RT-R1-02 insieme agli altri finding aggregati. Questo incarico non modifica Progress, Board, Sources o helper Common degli altri owner. Recovery: spegnere admission/gate per nuovi tentativi, mantenere costi e storico, osservare le incertezze senza reset. Nessuna scena altrui è stata toccata.
