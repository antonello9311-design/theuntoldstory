-- Conditional config-only recovery; preserve all receipts and arrays/timestamps/history.
BEGIN;
SET LOCAL search_path=pg_catalog;
SET LOCAL lock_timeout='5s';
DO $recovery$
DECLARE ev jsonb:=nullif(current_setting('tus_human_c463.recovery_evidence',true),'')::jsonb;ctrl mission_factory_owner.c463_optin_control;changed integer;
BEGIN
 IF current_user IS DISTINCT FROM 'postgres' OR ev IS NULL
 OR NOT mission_factory_owner.keys_exact_v2(ev,ARRAY['schema_version','operation','session_id','previous_session_id','expected_c463_postimage','authority_ref','authority_sha256','review_ref','review_sha256','review_findings','permit_expires_at'])
 OR ev->>'schema_version' IS DISTINCT FROM 'human-land-c463-recovery-root/1'
 OR ev->>'operation' IS DISTINCT FROM 'disable_exact_two_own_scopes'
 OR ev->'review_findings' IS DISTINCT FROM '[0,0,0]'::jsonb
 OR coalesce(ev->>'authority_sha256','') !~ '^[0-9a-f]{64}$'
 OR coalesce(ev->>'review_sha256','') !~ '^[0-9a-f]{64}$'
 OR nullif(btrim(ev->>'authority_ref'),'') IS NULL OR nullif(btrim(ev->>'review_ref'),'') IS NULL
 OR (ev->>'previous_session_id')::uuid IS NULL OR (ev->>'previous_session_id')::uuid=(ev->>'session_id')::uuid
 OR (ev->>'session_id')::uuid IS NULL OR ev->>'permit_expires_at' IS NULL
 OR (ev->>'permit_expires_at')::timestamptz<=statement_timestamp()
 OR (ev->>'permit_expires_at')::timestamptz>statement_timestamp()+interval '15 minutes'
 THEN RAISE EXCEPTION 'HUMAN_C463_RECOVERY_GENUINE_ROOT_REQUIRED';END IF;
 PERFORM pg_advisory_xact_lock(hashtextextended('human-land-c463-bind',13102026));
 SELECT * INTO STRICT ctrl FROM mission_factory_owner.c463_optin_control WHERE singleton FOR UPDATE;
 IF to_jsonb(ctrl) IS DISTINCT FROM ev->'expected_c463_postimage' OR NOT ctrl.enabled
 OR ctrl.master_user_ids IS DISTINCT FROM ARRAY['f0856d53-83a6-4de0-bc0c-12c87916e665']::uuid[]
 OR ctrl.session_ids IS DISTINCT FROM ARRAY[(ev->>'previous_session_id')::uuid,(ev->>'session_id')::uuid]
 OR NOT EXISTS(SELECT 1 FROM public.master_v2_sessions m JOIN mission_factory_owner.c384_human_bindings b ON b.session_id=m.id WHERE m.id=(ev->>'session_id')::uuid AND m.master_user=ctrl.master_user_ids[1] AND b.assigned_master=m.master_user AND m.owner_kind='human' AND m.tipo='quest' AND m.location_id='0b85f354-9cdb-47e1-baf9-3d266bb7e06b')
 THEN RAISE EXCEPTION 'HUMAN_C463_RECOVERY_POSTIMAGE_DRIFT';END IF;
 UPDATE mission_factory_owner.c463_optin_control SET enabled=false WHERE singleton;
 GET DIAGNOSTICS changed=ROW_COUNT;IF changed<>1 THEN RAISE EXCEPTION 'HUMAN_C463_RECOVERY_COUNT';END IF;
 IF (SELECT to_jsonb(c)-'enabled' FROM mission_factory_owner.c463_optin_control c WHERE singleton) IS DISTINCT FROM (to_jsonb(ctrl)-'enabled') THEN RAISE EXCEPTION 'HUMAN_C463_RECOVERY_HISTORY_DRIFT';END IF;
END $recovery$;
COMMIT;
