# Candidato integrato P1 Combat Esame

Il candidato compone, senza duplicarli:

1. `generic_sostituzione_spatial_v1` e le porte common/exam già LIVE inerti;
2. `combat_exam_exchange_adapter_v1`;
3. `combat_exam_narrative_spatial_receipt_v1`.

La shared identity è `combat_exam_exchange_identity_v1` con sette campi in ordine canonico: `exchange_id`, `exchange_version`, `root_application_id`, `attack_application_id`, `defense_application_id`, `substitution_event_id`, `resolution_revision`.

## Delta applicativo futuro

L'owner DB-CORE/COMBAT-CORE dovrà sostituire il ramo legacy Sostituzione in `_esame_prova_opzioni` e `_esame_risolvi`: non può sommare wrapper e logica corrente, perché costo, cooldown e anchor verrebbero applicati due volte. L'offerta deve provenire da capability opache e la risoluzione dalla receipt già prodotta dal common resolver.

Lo stesso delta materializzerà il piano adapter e la ricevuta point-of-view. Il contrattacco entra come `pending_unresolved`; soltanto il server, dopo la barriera di pubblicazione, apre il secondo scambio e poi rilascia l'iniziativa successiva.

## Stato del gate

I tre verticali sono staticamente verdi sulla stessa identità. Il candidato non contiene un apply integrato: la branch QA non è allineata alla produzione e il suo control plane è rosso. Nessuna review integrata `0/0/0`, migration, rollback, race, provider call, enable o smoke può essere dichiarata prima del riallineamento.
