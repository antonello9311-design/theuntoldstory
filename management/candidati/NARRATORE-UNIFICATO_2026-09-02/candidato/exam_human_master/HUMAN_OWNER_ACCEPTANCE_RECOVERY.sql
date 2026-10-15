-- ROOT TEMPLATE ONLY. No body restoration after release; retain acceptance and immutable history.
-- Materialize only with fresh whole-row hashes and a reviewed finite Root authority envelope.
DO $owner_recovery$
DECLARE e jsonb:=current_setting('tus.owner_acceptance_recovery',true)::jsonb;
 g mission_factory_owner.quest_fixed30_admission;r mission_public_owner.release_admissions_v1;
BEGIN
 IF current_user IS DISTINCT FROM 'postgres'::name OR auth.uid() IS NOT NULL
 OR e IS NULL OR NOT mission_factory_owner.keys_exact_v2(e,ARRAY['operation','release_sha256','request_key','expected_fixed30_md5','expected_admission_md5','expires_at','authority_sha256','review_ref'])
 OR e->>'operation' IS DISTINCT FROM 'disable_exact_human_owner_accepted_release'
 OR coalesce(e->>'release_sha256','')!~'^[0-9a-f]{64}$'
 OR coalesce(e->>'request_key','')!~'^[0-9a-f]{8}(-[0-9a-f]{4}){3}-[0-9a-f]{12}$'
 OR coalesce(e->>'expected_fixed30_md5','')!~'^[0-9a-f]{32}$'
 OR coalesce(e->>'expected_admission_md5','')!~'^[0-9a-f]{32}$'
 OR coalesce(e->>'authority_sha256','')!~'^[0-9a-f]{64}$'
 OR nullif(btrim(e->>'review_ref'),'') IS NULL
 OR e->>'expires_at' IS NULL
 OR (e->>'expires_at')::timestamptz<=clock_timestamp()
 OR (e->>'expires_at')::timestamptz>clock_timestamp()+interval '15 minutes'
 THEN RAISE EXCEPTION 'OWNER_RECOVERY_FINITE_ROOT_AUTHORITY_REQUIRED';END IF;
 SELECT * INTO STRICT g FROM mission_factory_owner.quest_fixed30_admission WHERE singleton FOR UPDATE;
 SELECT * INTO STRICT r FROM mission_public_owner.release_admissions_v1 WHERE release_sha256=e->>'release_sha256' FOR UPDATE;
 IF md5(to_jsonb(g)::text) IS DISTINCT FROM e->>'expected_fixed30_md5'
 OR md5(to_jsonb(r)::text) IS DISTINCT FROM e->>'expected_admission_md5'
 OR g.public_release_sha256 IS DISTINCT FROM r.release_sha256
 OR NOT EXISTS(SELECT 1 FROM mission_public_owner.public_qualification_attestations_v1 q WHERE q.release_sha256=r.release_sha256 AND q.payload->>'schema_version'='human-owner-accepted-release/1')
 OR EXISTS(SELECT 1 FROM mission_factory_owner.quest_arcs a WHERE a.public_release_sha256=r.release_sha256 AND a.state NOT IN('completed','cancelled','failed'))
 THEN RAISE EXCEPTION 'OWNER_RECOVERY_EXACT_SCOPE_OR_ACTIVE_ARC_DRIFT';END IF;
 UPDATE mission_public_owner.release_admissions_v1 SET public_enabled=false WHERE release_sha256=r.release_sha256;
 IF (SELECT to_jsonb(x) FROM mission_factory_owner.quest_fixed30_admission x WHERE singleton) IS DISTINCT FROM to_jsonb(g)
 OR (SELECT to_jsonb(x) FROM mission_public_owner.release_admissions_v1 x WHERE release_sha256=r.release_sha256) IS DISTINCT FROM jsonb_set(to_jsonb(r),'{public_enabled}','false'::jsonb)
 THEN RAISE EXCEPTION 'OWNER_RECOVERY_POST_SCOPE_DRIFT';END IF;
END $owner_recovery$;
