-- RECOVERY COMPONENTE FORWARD, sigillo finale owner PM. Conserva la correzione contatto e lo storico.
-- Nessuna reinstallazione del corpo difettoso, nessuna cancellazione o reset.
BEGIN;
DO $recover_pre$
DECLARE r jsonb;
BEGIN
 SELECT canonical_preimage::jsonb INTO STRICT r FROM mission_factory_owner.editor_release_readiness WHERE singleton FOR UPDATE;
 IF r#>>'{db_core,cure_command_amendment,source_bundle_sha256}' IS DISTINCT FROM '680f9d1d43250a7a62ad29537a6d0b2ac13abfdc06f510372c669794b15a403d'
 THEN RAISE EXCEPTION 'palmo_ordinary_recovery_source_mismatch';END IF;
 IF EXISTS(SELECT 1 FROM public.combat_v2_sessions WHERE closed_at IS NULL AND state IN('preparazione','in_corso','sospeso'))
 OR EXISTS(SELECT 1 FROM public.master_v2_sessions WHERE closed_at IS NULL AND suspended_at IS NULL)
 THEN RAISE EXCEPTION 'palmo_ordinary_recovery_requires_quiescence';END IF;
END $recover_pre$;
UPDATE combat_panel_private.cure_gate_v1 SET staff_enabled=false,public_enabled=false WHERE singleton;
-- BEGIN PM_FORWARD_RECOVERY_SLOT
-- Mantenere i due corpi corretti; comporre Root corrente in avanti, amendment state=inert_recovery,
-- disponibilita Cure OFF e digest coerenti. Conservare le altre famiglie, i budget e tutte le ricevute.
-- END PM_FORWARD_RECOVERY_SLOT
DO $recover_post$
DECLARE rr mission_factory_owner.editor_release_readiness%ROWTYPE;r jsonb;a jsonb;
BEGIN
 SELECT * INTO STRICT rr FROM mission_factory_owner.editor_release_readiness WHERE singleton;r:=rr.canonical_preimage::jsonb;a:=r#>'{db_core,cure_command_amendment}';
 IF a IS NULL OR a IS DISTINCT FROM r#>'{config,cure_command_amendment}' OR a->>'state' IS DISTINCT FROM 'inert_recovery'
 OR a->>'source_bundle_sha256' IS DISTINCT FROM '680f9d1d43250a7a62ad29537a6d0b2ac13abfdc06f510372c669794b15a403d'
 OR NOT EXISTS(SELECT 1 FROM combat_panel_private.cure_gate_v1 WHERE singleton AND NOT staff_enabled AND NOT public_enabled)
 OR rr.observed_revision_sha256 IS DISTINCT FROM rr.revision_sha256 OR octet_length(rr.canonical_preimage)>524288
 OR encode(extensions.digest(convert_to(rr.canonical_preimage,'UTF8'),'sha256'),'hex') IS DISTINCT FROM rr.revision_sha256
 OR r#>>'{db_core,sha256}' IS DISTINCT FROM public.combat_v2_sha256((r->'db_core')-'sha256')
 OR r#>>'{config,sha256}' IS DISTINCT FROM public.combat_v2_sha256((r->'config')-'sha256')
 THEN RAISE EXCEPTION 'palmo_ordinary_recovery_root_required';END IF;
 IF clan_innata_private.catalogo_eligibility_release_v1() IS DISTINCT FROM true THEN RAISE EXCEPTION 'palmo_ordinary_recovery_guard_failed';END IF;
END $recover_post$;
COMMIT;
