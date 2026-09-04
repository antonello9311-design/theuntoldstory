# Ricevuta spaziale point-of-view · contratto candidato

TASK-ID: `P1-C-COMBAT-EXAM-SPATIAL-RECEIPT-001`  
Stato: `proposto · static target`  
Owner: `COMBAT-CORE`  
Profilo: `combat_exam_narrative_spatial_receipt_v1`  
Identità condivisa: `combat_exam_exchange_identity_v1`

## Scopo

La ricevuta è una proiezione immutabile dei fatti già risolti dal server. Non
calcola posizioni, portate, bersagli, anatomia, esiti o iniziativa e non è un
secondo motore. Collega la singola risoluzione dello scambio al resolver della
Sostituzione e all'adapter narrativo tramite la stessa identità di scambio.

La produzione possiede già fatti di Sostituzione `before/impact/anchor/after` e
ricevute di richiesta: l'implementazione futura deve normalizzare e proiettare
quelle autorità, non creare un secondo registro concorrente.

Il profilo comune autoritativo della tecnica resta
`generic_sostituzione_spatial_v1`. Un profilo di arena, Esame o Missione può
fornire le ancore, ma non sostituisce il contratto comune.

## Identità condivisa e chiavi

L'input server deve contenere, tutti nella stessa revisione:

- `exchange_id`, `exchange_version` e `resolution_revision`;
- `root_application_id` e `attack_application_id`;
- `defense_application_id` e `substitution_event_id` quando l'esito è
  `substituted`;
- `source_snapshot_id`, `spatial_snapshot_id` e rispettive versioni;
- `operation_id`, `operation_kind=narrative_exchange_projection` e
  `request_key`.

L'ordine canonico della shared identity è: `exchange_id`, `exchange_version`,
`root_application_id`, `attack_application_id`, `defense_application_id`,
`substitution_event_id` nullable, `resolution_revision`. La chiave di materializzazione è
`(operation_id, exchange_id, resolution_revision, viewer_scope,
projection_version)`. Un retry byte-equivalente restituisce la stessa ricevuta;
la stessa chiave con input diverso produce `receipt_request_key_conflict`.
Nessuna chiave del client può sostituire gli identificatori server.

## Input autoritativo

La materializzazione accetta soltanto un bundle interno già sigillato:

1. **risoluzione**: esito, ordine delle applicazioni e iniziativa successiva;
2. **source**: categoria e geometria della source, actor/public body d'origine,
   manifestazione eseguita e traiettoria tipizzata;
3. **anatomia**: interfaccia o arto d'origine quando richiesto dal profilo,
   altrimenti `not_applicable`; mai dedotta dalla prosa;
4. **bersaglio**: exact target public body e regione dichiarata/risolta; un
   valore assente resta `unknown`, non viene completato dall'IA;
5. **spazio**: snapshot server `before`, `impact`, `anchor`, `after`, distanze,
   fascia e versioni;
6. **viewer**: exact consumer, purpose, policy e permission version.

Per `substituted`, i quattro momenti sono obbligatori e appartengono allo stesso
`substitution_event_id`:

- `before`: locus del difensore prima dello scambio;
- `impact`: locus terminale dell'attacco/origine del difensore;
- `anchor`: supporto prima allo swap point e dopo come proxy semantico
  `consumed_non_substitutable` all'impact;
- `after`: locus del difensore all'exact swap point.

Le coordinate, footprint, punti di contatto, segmenti e identità database sono
conservati nell'audit interno. Non entrano nella proiezione del Narratore.

## Output autorizzato al Narratore

Schema: `combat-exam-narrative-spatial-receipt/1.0`.

La proiezione contiene soltanto:

- `receipt_handle` opaco, `exchange_handle` opaco e revisione;
- ruoli viewer-safe (`candidate`, `opponent`) e label già autorizzate;
- `source`: famiglia, manifestazione, `trajectory_kind`,
  `anatomical_origin` e `target_region`, tutti da vocabolari tipizzati;
- `before`, `impact`, `anchor`, `after`: regione semantica e relazione dal
  punto di vista del viewer; mai coordinate;
- per ogni soggetto autorizzato, `distance_m` server-derived e
  `range_band`, coerenti sullo stesso snapshot; nessuna distanza di terzi;
- `outcome`, conseguenza meccanica minima e continuità fissa
  `substitution → reappearance → opponent_recovery`;
- `next_initiative` già decisa dal server e
  `counterattack_status=pending_unresolved` quando l'azione seguente non è
  ancora risolta;
- luce e dettagli scenici solo se presenti nel contesto server autorizzato.

`distance_m` non è una coordinata e può essere esposta soltanto tra viewer e
subject autorizzato. La fascia deve essere ricalcolata dal server dallo stesso
valore e dalla stessa `range_profile_version`; incoerenza = rifiuto dell'intera
ricevuta, mai correzione silenziosa.

L'adapter `combat_exam_exchange_adapter_v1` consuma la ricevuta soltanto nello
stato `facts_bound`, la congela dentro `plan_frozen` e non libera l'iniziativa
successiva prima di `narrative_published`. La ricevuta non modifica questi
stati e non può anticipare `release_after=narrative_published`.

## Vincoli narrativi derivati

- Il Narratore può descrivere la continuità già provata, ma non scegliere
  ancora, punto, traiettoria, arto, bersaglio, distanza, danno o iniziativa.
- La battuta del PNG può stare dentro recupero/movimento soltanto se l'adapter
  la autorizza; nessuna voce o nuova azione del candidato viene inventata.
- `pending_unresolved` autorizza soltanto una preparazione o intenzione, mai un
  colpo, tiro, difesa, danno o posizione finale non risolti.
- Un campo `unknown`/`not_applicable` resta tale. Il testo libero non promuove
  un dato mancante a fatto.

## Anti-leakage

- Il Narratore non riceve UUID di actor, body, source, anchor o mappe.
- Non riceve coordinate, footprint, blocker, opzioni scartate, ragioni private,
  chakra residuo, cooldown, probabilità, tiri o hidden target.
- L'anchor usa un handle limitato alla ricevuta e una label semantica già
  autorizzata; non è riutilizzabile per interrogare altre scene.
- Gli errori interni restano audit-only. Al viewer arriva al massimo
  `narrative_receipt_unavailable`.
- La stessa risoluzione può produrre proiezioni diverse per viewer, tutte
  derivate dallo stesso audit snapshot e senza contaminazione fra scope.

## Errori interni closed-world

- `receipt_context_not_authorized`
- `receipt_operation_scope_mismatch`
- `receipt_exchange_identity_mismatch`
- `receipt_resolution_not_settled`
- `receipt_substitution_event_missing`
- `receipt_spatial_snapshot_incomplete`
- `receipt_source_binding_incomplete`
- `receipt_anatomy_binding_missing`
- `receipt_target_binding_missing`
- `receipt_distance_band_mismatch`
- `receipt_stale_resolution_revision`
- `receipt_projection_leakage_blocked`
- `receipt_request_key_conflict`

Qualunque errore nega la ricevuta. Non produce fallback narrativo con fatti
parziali e non modifica la risoluzione storica.

## Confini

Questo candidato non contiene SQL, funzione runtime, Edge, prompt, UI, apply,
deploy, enable o smoke. Il gate integrato richiede resolver P1-A e adapter P1-B
sulla stessa identità, branch Supabase QA healthy/allineato e una sola campagna
con review indipendente. Fino ad allora lo stato operativo resta rosso.
