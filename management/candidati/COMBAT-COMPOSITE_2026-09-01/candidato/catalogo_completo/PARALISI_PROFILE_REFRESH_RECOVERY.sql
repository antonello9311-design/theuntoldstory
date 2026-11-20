-- Recovery componente conservativa: lascia il nuovo corpo e lo storico; il PM deve comporre il nuovo seal.
BEGIN;
DO $paralisi_refresh_recovery$
BEGIN
 IF md5((SELECT prosrc FROM pg_proc WHERE oid='combat_panel_private.master_projection(uuid,uuid)'::regprocedure)) IS DISTINCT FROM '271ea56acb5f135ad6e3d24d8601e3b1'
 THEN RAISE EXCEPTION 'paralisi_refresh_recovery_body_drift';END IF;
 UPDATE combat_v2_genjutsu_internal.gate SET staff_enabled=false,public_enabled=false WHERE singleton;
END $paralisi_refresh_recovery$;
-- BEGIN PM_PARALISI_REFRESH_RECOVERY_ROOT_SLOT
-- Owner PM deve sigillare la configurazione OFF e preservare corpo e ricevute.
-- END PM_PARALISI_REFRESH_RECOVERY_ROOT_SLOT
DO $paralisi_refresh_recovery_post$
DECLARE rr mission_factory_owner.editor_release_readiness%ROWTYPE;r jsonb;
BEGIN
 SELECT * INTO STRICT rr FROM mission_factory_owner.editor_release_readiness WHERE singleton;
 r:=rr.canonical_preimage::jsonb;
 IF r#>>'{db_core,paralisi_profile_refresh,source_bundle_sha256}' IS DISTINCT FROM '9c9c84ddb2fcc037b0b2164877d296c72a99529b86f3dfcaf59e5c62d4cb65c3'
 OR r#>>'{db_core,paralisi_profile_refresh,recovery_state}' IS DISTINCT FROM 'paralisi_off_source_retained'
 OR r#>'{db_core,paralisi_profile_refresh}' IS DISTINCT FROM r#>'{config,paralisi_profile_refresh}'
 OR rr.observed_revision_sha256 IS DISTINCT FROM rr.revision_sha256
 OR encode(extensions.digest(convert_to(rr.canonical_preimage,'UTF8'),'sha256'),'hex') IS DISTINCT FROM rr.revision_sha256
 OR octet_length(rr.canonical_preimage)>524288
 OR r#>>'{db_core,sha256}' IS DISTINCT FROM public.combat_v2_sha256((r->'db_core')-'sha256')
 OR r#>>'{config,sha256}' IS DISTINCT FROM public.combat_v2_sha256((r->'config')-'sha256')
 OR clan_innata_private.catalogo_eligibility_release_v1() IS DISTINCT FROM true
 OR EXISTS(SELECT 1 FROM combat_v2_genjutsu_internal.gate WHERE singleton AND(staff_enabled OR public_enabled))
 THEN RAISE EXCEPTION 'paralisi_refresh_recovery_integrated_root_required';END IF;
END $paralisi_refresh_recovery_post$;
COMMIT;
