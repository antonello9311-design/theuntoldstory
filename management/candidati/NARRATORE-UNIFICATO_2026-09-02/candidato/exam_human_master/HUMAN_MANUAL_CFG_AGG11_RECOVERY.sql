-- Conservative CFG11 recovery: disable exact own postimage, preserve arrays, ledger, dates, source and history.
BEGIN;
SET LOCAL search_path=pg_catalog;
DO $recover$
DECLARE ev jsonb:=nullif(current_setting('tus_human_cfg.recovery_evidence',true),'')::jsonb;actual jsonb;
BEGIN
 IF current_user<>'postgres' OR ev IS NULL OR coalesce(ev->>'authority_sha256','') !~ '^[0-9a-f]{64}$' OR coalesce(ev->>'review_sha256','') !~ '^[0-9a-f]{64}$' OR ev->'review_findings' IS DISTINCT FROM'[0,0,0]'::jsonb OR nullif(ev->>'permit_expires_at','') IS NULL OR (ev->>'permit_expires_at')::timestamptz<=statement_timestamp() OR (ev->>'permit_expires_at')::timestamptz>statement_timestamp()+interval '15 minutes' THEN RAISE EXCEPTION 'CFG11_RECOVERY_ROOT_REQUIRED';END IF;
 LOCK TABLE mission_factory_owner.c416_kind_admission,mission_factory_owner.c444_runtime_control,mission_factory_owner.c463_optin_control,mission_factory_owner.manual_authoring_admissions_v1 IN SHARE ROW EXCLUSIVE MODE;
 actual:=jsonb_build_object('c416',(SELECT to_jsonb(x) FROM mission_factory_owner.c416_kind_admission x WHERE singleton),'c444',(SELECT to_jsonb(x) FROM mission_factory_owner.c444_runtime_control x WHERE singleton),'c463',(SELECT to_jsonb(x) FROM mission_factory_owner.c463_optin_control x WHERE singleton),'manual',(SELECT jsonb_agg(to_jsonb(x) ORDER BY actor_user) FROM mission_factory_owner.manual_authoring_admissions_v1 x WHERE release_sha256='37dac90525b249f53fc0404b50adb4ed92df0123649326c99260bf656119d806'));
 IF actual IS DISTINCT FROM ev->'exact_postimage' OR actual#>>'{c416,request_key}'<>'4da1143a-8d60-465c-85de-09796fc2217c' OR actual#>'{c463,session_ids}'<>'["97d2a684-956d-57ad-8d84-aca627dd9e5c"]'::jsonb OR actual#>'{c463,master_user_ids}'<>'["f0856d53-83a6-4de0-bc0c-12c87916e665"]'::jsonb OR jsonb_array_length(actual->'manual')<>2 THEN RAISE EXCEPTION 'CFG11_RECOVERY_EXACT_POSTIMAGE_REQUIRED';END IF;
 UPDATE mission_factory_owner.c416_kind_admission SET enabled=false WHERE singleton;
 UPDATE mission_factory_owner.c444_runtime_control SET enabled=false WHERE singleton;
 UPDATE mission_factory_owner.c463_optin_control SET enabled=false WHERE singleton;
 UPDATE mission_factory_owner.manual_authoring_admissions_v1 SET enabled=false WHERE release_sha256='37dac90525b249f53fc0404b50adb4ed92df0123649326c99260bf656119d806';
END $recover$;
COMMIT;
