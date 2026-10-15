BEGIN;
SET LOCAL search_path=pg_catalog,public,extensions;
SET LOCAL lock_timeout='5s';
SET LOCAL statement_timeout='30s';
DO $zero_c463$
DECLARE v_ev jsonb:=nullif(current_setting('tus.zero_c463',true),'')::jsonb;v_before jsonb;v_after jsonb;v_wanted jsonb;v_post jsonb;v_count bigint;
BEGIN
 IF current_user IS DISTINCT FROM 'postgres'::name OR auth.uid() IS NOT NULL OR v_ev IS NULL OR jsonb_typeof(v_ev) IS DISTINCT FROM 'object'
 OR (SELECT array_agg(zck ORDER BY zck) FROM jsonb_object_keys(v_ev) zck) IS DISTINCT FROM ARRAY['authority_sha256','baseline_file_sha256','expires_at','operation','request_key','review_ref','review_sha256','run_until']::text[]
 OR v_ev->>'expires_at' IS NULL OR (v_ev->>'expires_at')::timestamptz<=clock_timestamp() OR (v_ev->>'expires_at')::timestamptz>clock_timestamp()+interval '15 minutes'
 OR coalesce(v_ev->>'authority_sha256','')!~'^[0-9a-f]{64}$' OR coalesce(v_ev->>'review_sha256','')!~'^[0-9a-f]{64}$' OR nullif(btrim(v_ev->>'review_ref'),'') IS NULL
 OR coalesce(v_ev->>'request_key','')!~'^[0-9a-f]{8}(-[0-9a-f]{4}){3}-[0-9a-f]{12}$'
 OR v_ev->>'baseline_file_sha256' IS DISTINCT FROM '89b1d74b76448bd9c2eb870da5f1a53deed3c3739b55379d2dc0df6504784d98' OR v_ev->>'run_until' IS DISTINCT FROM '2026-10-15T19:02:41+00:00'
 THEN RAISE EXCEPTION 'ZERO_C463_GENUINE_ROOT_FINITE_AUTHORITY_REQUIRED';END IF;
 IF v_ev->>'operation' IS DISTINCT FROM 'disable_exact_own_c463_binding' THEN RAISE EXCEPTION 'ZERO_C463_RECOVERY_OPERATION';END IF;
 v_post:=nullif(current_setting('tus.zero_c463_actual_post',true),'')::jsonb;
 IF v_post IS NULL OR jsonb_typeof(v_post) IS DISTINCT FROM 'object' OR v_post->>'singleton' IS DISTINCT FROM 'true'
 OR v_post->>'enabled' IS DISTINCT FROM 'true' OR v_post->'master_user_ids' IS DISTINCT FROM '["f0856d53-83a6-4de0-bc0c-12c87916e665"]'::jsonb
 OR v_post->'session_ids' IS DISTINCT FROM '["0ca5fa37-0dd8-5955-8508-e71cdbe7305a"]'::jsonb
 OR (v_post->>'bound_at')::timestamptz IS DISTINCT FROM '2026-10-15T17:02:41+00:00'::timestamptz
 OR (v_post->>'expires_at')::timestamptz IS DISTINCT FROM '2026-10-15T19:02:41+00:00'::timestamptz
 OR v_post->>'bound_at' IS NULL OR v_post->>'expires_at' IS NULL
 OR coalesce(v_post->>'review_sha256','')!~'^[0-9a-f]{64}$'
 THEN RAISE EXCEPTION 'ZERO_C463_IMMUTABLE_OWN_POST_REQUIRED';END IF;
 LOCK TABLE mission_factory_owner.c463_optin_control IN SHARE ROW EXCLUSIVE MODE;
 SELECT to_jsonb(zcr) INTO STRICT v_before FROM mission_factory_owner.c463_optin_control zcr WHERE singleton FOR UPDATE;
 IF v_before IS DISTINCT FROM v_post THEN RAISE EXCEPTION 'ZERO_C463_RECOVERY_POST_DRIFT';END IF;
 UPDATE mission_factory_owner.c463_optin_control SET enabled=false WHERE singleton;
 SELECT to_jsonb(zcr) INTO STRICT v_after FROM mission_factory_owner.c463_optin_control zcr WHERE singleton;
 IF v_after IS DISTINCT FROM jsonb_set(v_before,'{enabled}','false'::jsonb) THEN RAISE EXCEPTION 'ZERO_C463_RECOVERY_DRIFT';END IF;
END $zero_c463$;
COMMIT;
