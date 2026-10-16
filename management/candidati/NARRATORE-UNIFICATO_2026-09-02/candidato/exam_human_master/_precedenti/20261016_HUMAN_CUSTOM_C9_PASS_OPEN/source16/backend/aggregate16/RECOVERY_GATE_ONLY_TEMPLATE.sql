-- Operational recovery only. Root supplies genuine finite authority and exact observed postimage.
-- No body restore, no deletion, no source/proof/history rewrite. This template is not a permit.
BEGIN;
SET LOCAL search_path=pg_catalog,public,extensions;
SET LOCAL lock_timeout='5s';
SET LOCAL statement_timeout='30s';
DO $custom_recovery$
DECLARE v_ev jsonb:=nullif(current_setting('tus.human_custom_recovery',true),'')::jsonb;v_gate jsonb;v_release jsonb;v_sha text;
BEGIN
 IF current_user IS DISTINCT FROM 'postgres'::name OR auth.uid() IS NOT NULL OR v_ev IS NULL OR jsonb_typeof(v_ev) IS DISTINCT FROM 'object'
 OR (SELECT array_agg(k ORDER BY k) FROM jsonb_object_keys(v_ev) k) IS DISTINCT FROM ARRAY['authority_sha256','capability_sha256','expected_fixed30','expected_release','expires_at','operation','review_ref','review_sha256']::text[]
 OR v_ev->>'expires_at' IS NULL OR (v_ev->>'expires_at')::timestamptz<=clock_timestamp() OR (v_ev->>'expires_at')::timestamptz>clock_timestamp()+interval '10 minutes'
 OR v_ev->>'operation' IS DISTINCT FROM 'disable_exact_human_custom_capability'
 OR coalesce(v_ev->>'authority_sha256','')!~'^[0-9a-f]{64}$' OR coalesce(v_ev->>'review_sha256','')!~'^[0-9a-f]{64}$' OR nullif(btrim(v_ev->>'review_ref'),'') IS NULL
 OR coalesce(v_ev->>'capability_sha256','')!~'^[0-9a-f]{64}$'
 OR jsonb_typeof(v_ev->'expected_fixed30') IS DISTINCT FROM 'object' OR jsonb_typeof(v_ev->'expected_release') IS DISTINCT FROM 'object'
 THEN RAISE EXCEPTION 'HUMAN_CUSTOM_RECOVERY_FINITE_ROOT_AUTHORITY_REQUIRED';END IF;
 v_sha:=v_ev->>'capability_sha256';
 PERFORM pg_advisory_xact_lock(hashtextextended('human-custom-ordinary-release',15102026));
 SELECT to_jsonb(cg) INTO v_gate FROM mission_factory_owner.quest_fixed30_admission cg WHERE singleton FOR UPDATE;
 SELECT to_jsonb(cr) INTO v_release FROM mission_public_owner.release_admissions_v1 cr WHERE release_sha256=v_sha FOR UPDATE;
 IF v_gate IS DISTINCT FROM v_ev->'expected_fixed30' OR v_release IS DISTINCT FROM v_ev->'expected_release' OR v_release->>'release_sha256' IS DISTINCT FROM v_sha
 THEN RAISE EXCEPTION 'HUMAN_CUSTOM_RECOVERY_POSTIMAGE_DRIFT';END IF;
 -- The base historical S5 release and its public gate metadata are never changed.
 IF v_sha='5ab4234b32294cc26472855447e6230f62c5e07308768816ae0c2ea304d94366' THEN RAISE EXCEPTION 'HUMAN_CUSTOM_RECOVERY_BASE_RELEASE_FORBIDDEN';END IF;
 UPDATE mission_public_owner.release_admissions_v1 SET public_enabled=false WHERE release_sha256=v_sha;
 IF 'AUTHORIZED_TEST_MANIFEST:'||(v_gate->>'public_staff_test_manifest_ref') IS NOT DISTINCT FROM v_release->>'staff_evidence_ref' THEN
  UPDATE mission_factory_owner.quest_fixed30_admission SET public_staff_enabled=false WHERE singleton;
 END IF;
 IF EXISTS(SELECT 1 FROM mission_public_owner.release_admissions_v1 WHERE release_sha256=v_sha AND public_enabled) THEN RAISE EXCEPTION 'HUMAN_CUSTOM_RECOVERY_FLAG_DRIFT';END IF;
END $custom_recovery$;
COMMIT;
