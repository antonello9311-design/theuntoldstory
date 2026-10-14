-- Conservative disable only own C444 exact postimage. Preserve every receipt, round, report, array, date and source body.
BEGIN;
SET LOCAL search_path=pg_catalog;
DO $recover$
DECLARE ev jsonb:=nullif(current_setting('tus_human30.recovery_evidence',true),'')::jsonb;c mission_factory_owner.c444_runtime_control;
BEGIN
 IF current_user IS DISTINCT FROM 'postgres' OR ev IS NULL OR ev->'review_findings' IS DISTINCT FROM '[0,0,0]'::jsonb OR coalesce(ev->>'authority_sha256','')!~'^[0-9a-f]{64}$' OR nullif(ev->>'permit_expires_at','') IS NULL OR (ev->>'permit_expires_at')::timestamptz<=statement_timestamp() OR (ev->>'permit_expires_at')::timestamptz>statement_timestamp()+interval '15 minutes' THEN RAISE EXCEPTION 'HUMAN30_RECOVERY_ROOT_REQUIRED';END IF;
 SELECT * INTO STRICT c FROM mission_factory_owner.c444_runtime_control WHERE singleton FOR UPDATE;
 IF to_jsonb(c) IS DISTINCT FROM ev->'exact_c444_postimage' THEN RAISE EXCEPTION 'HUMAN30_RECOVERY_POSTIMAGE_REQUIRED';END IF;
 UPDATE mission_factory_owner.c444_runtime_control SET enabled=false WHERE singleton;
END $recover$;
COMMIT;
