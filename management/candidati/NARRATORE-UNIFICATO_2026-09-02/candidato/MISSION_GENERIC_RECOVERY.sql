-- MISSION-GENERIC recovery conservativa: chiude solo nuove ammissioni/raccordi.
-- Nessuna cancellazione o reset di run, personaggi, ricevute, storico, cron Esame o flag legacy.
begin;
update mission_generic_owner.runtime_policy set mode='off' where singleton;
update mission_generic_owner.provider_policy set enabled=false where singleton;
update mission_generic_owner.dispatch_admissions set enabled=false where enabled;
update public.mission_evidence_capabilities set enabled=false where capability_key='mission.generic.trigger.v1';
commit;
