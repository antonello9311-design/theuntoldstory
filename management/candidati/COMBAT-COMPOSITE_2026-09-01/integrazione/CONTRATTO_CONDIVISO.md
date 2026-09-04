# `combat_exam_exchange_identity_v1`

## Scopo

Identità unica e server-authoritative per collegare una coppia di azioni dell'Esame, la difesa Sostituzione e il payload del Narratore 4.8. Non è una nuova meccanica e non sostituisce i resolver Combat/Esame esistenti.

## Identità obbligatorie

- `exchange_id`, `exchange_version`;
- `root_application_id`;
- `attack_application_id`;
- `defense_application_id` oppure `null` soltanto prima della dichiarazione;
- `substitution_event_id` oppure `null` quando la difesa non è Sostituzione;
- `resolution_revision` monotona e server-side.

Ogni id è prodotto o risolto dal server. Client, IA e prosa non possono proporlo, sostituirlo o inferirlo.

## Ordine canonico

1. Il server apre l'attacco candidato e fotografa source, attore, bersaglio e stato.
2. Il server apre la finestra difensiva PNG e, se applicabile, enumera capability Sostituzione opache.
3. La difesa viene dichiarata e risolta; un eventuale commit di Sostituzione crea `substitution_event_id` e la ricevuta spaziale.
4. Il server chiude l'esito meccanico dell'attacco candidato.
5. Il piano narrativo include quell'esito e il contrattacco PNG come `pending_unresolved`; il Narratore non ne decide esito o valori.
6. Solo dopo la pubblicazione/approvazione del primo scambio il server apre e risolve il contrattacco e le difese PG.
7. La pubblicazione del secondo scambio precede l'iniziativa successiva, che viene letta dal server e mai scelta dall'IA.

## Output minimo verso il Narratore

`combat_exam_narrative_spatial_receipt_v1` espone soltanto:

- ruoli e subject handle opachi;
- timeline `before -> impact -> anchor -> after`;
- posizione semantica e relazione spaziale autorizzata;
- distanza e fascia calcolate dal server;
- source, arto/traiettoria e bersaglio tipizzati quando necessari e presenti nella source;
- esito già risolto;
- contrattacco con stato `pending_unresolved`;
- iniziativa successiva soltanto dopo la relativa decisione server.

Coordinate, UUID attore, anchor raw, route interne, ragioni private, risorse nascoste e alternative non scelte restano audit-only.

## Errori comuni

- `exchange_identity_missing`
- `exchange_identity_version_stale`
- `exchange_root_mismatch`
- `exchange_phase_invalid`
- `exchange_resolution_revision_conflict`
- `exchange_spatial_receipt_missing`
- `exchange_spatial_receipt_mismatch`
- `exchange_next_initiative_not_authoritative`
- `exchange_request_key_conflict`

Ogni errore fallisce chiuso. Non esistono retarget, reroute, ricostruzione da prosa, scelta IA o avanzamento anticipato del turno.
