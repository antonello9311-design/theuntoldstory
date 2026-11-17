BEGIN;
SET LOCAL lock_timeout='4s';
SELECT pg_advisory_xact_lock(hashtextextended('C1266:GENERIC-AI:AVAILABILITY',0));
DO $alba_suna_guard$
BEGIN
 IF NOT EXISTS(SELECT 1 FROM pg_proc WHERE oid='mission_riuji_owner.village_exception(uuid,uuid,uuid)'::regprocedure AND md5(pg_get_functiondef(oid))='ca9ff46a083d2c375c4f6ab9d8742d3c' AND proowner='postgres'::regrole AND proacl::text='{postgres=X/postgres}' AND prosecdef AND provolatile='s' AND proconfig=ARRAY['search_path=""']) THEN RAISE EXCEPTION 'ALBA_SUNA_FUNCTION_DRIFT';END IF;
 PERFORM 1 FROM public.missions m WHERE m.id='a3a8430f-6a3d-4d46-9a75-271d5458406d' AND m.title='Una nuova alba' AND m.status='aperta' AND m.village='Konoha' AND md5(to_jsonb(m)::text)='a5f0b8b08c7b5fe33c6f5336dec70661' FOR UPDATE;
 IF NOT FOUND THEN RAISE EXCEPTION 'ALBA_SUNA_MISSION_DRIFT';END IF;
 PERFORM 1 FROM mission_ai_board_owner.activations WHERE mission_id='a3a8430f-6a3d-4d46-9a75-271d5458406d' AND state='enrollment_open' AND current_session_id IS NULL AND generic_plan_version_id='90d513ec-15e9-4a83-b9b9-c67052b77be9' AND location_id='6c737082-8fc7-4fd8-b246-30297a1ed1af' FOR UPDATE;
 IF NOT FOUND THEN RAISE EXCEPTION 'ALBA_SUNA_ACTIVATION_DRIFT';END IF;
 IF NOT EXISTS(SELECT 1 FROM mission_factory_owner.editor_release_readiness WHERE singleton AND revision_sha256='fa7f5e2f14fad90a7bd306d022f8dd85b7f411042ad35083a7b28ba5b75a9f0c' AND observed_revision_sha256=revision_sha256 AND state='enabled') OR mission_public_owner.engine_qualification_v1('fa7f5e2f14fad90a7bd306d022f8dd85b7f411042ad35083a7b28ba5b75a9f0c',true) IS NULL OR NOT mission_public_owner.is_public_launch_v1('a3a8430f-6a3d-4d46-9a75-271d5458406d') OR mission_public_owner.content_admission_v1('a3a8430f-6a3d-4d46-9a75-271d5458406d','fa7f5e2f14fad90a7bd306d022f8dd85b7f411042ad35083a7b28ba5b75a9f0c','1358279e-7d51-4c89-a34a-4d7ec540bb86',true) IS NULL THEN RAISE EXCEPTION 'ALBA_SUNA_RELEASE_DRIFT';END IF;
 IF EXISTS(SELECT 1 FROM public.master_v2_sessions WHERE mission_id='a3a8430f-6a3d-4d46-9a75-271d5458406d') THEN RAISE EXCEPTION 'ALBA_SUNA_MISSION_STARTED';END IF;
END $alba_suna_guard$;
DO $alba_suna_recovery_guard$
BEGIN
 IF EXISTS(SELECT 1 FROM public.mission_bookings b JOIN public.characters c ON c.id=b.character_id WHERE b.mission_id='a3a8430f-6a3d-4d46-9a75-271d5458406d' AND c.village='Suna') OR EXISTS(SELECT 1 FROM mission_ai_board_owner.applicants a JOIN public.characters c ON c.id=a.character_id WHERE a.activation_id IN(SELECT id FROM mission_ai_board_owner.activations WHERE mission_id='a3a8430f-6a3d-4d46-9a75-271d5458406d') AND c.village='Suna') THEN RAISE EXCEPTION 'ALBA_SUNA_RECOVERY_FORWARD_REQUIRED';END IF;
END $alba_suna_recovery_guard$;
CREATE OR REPLACE FUNCTION mission_riuji_owner.village_exception(p_character uuid, p_user uuid, p_mission uuid)
 RETURNS boolean
 LANGUAGE sql
 STABLE SECURITY DEFINER
 SET search_path TO ''
AS $function$
  select exists (
    select 1
    from mission_riuji_owner.permission e
    join public.characters c on c.id = e.character_id
    where e.character_id = p_character and e.user_id = p_user and c.user_id = e.user_id
      and e.active and e.phase = 'public' and e.target_cross_village = p_mission
  ) or (
    p_mission is not distinct from '6d6c216a-222d-4cba-b2fc-f3e0c199c195'::uuid
    and exists (
      select 1 from public.characters c
      where c.id = p_character and c.user_id = p_user and c.village = 'Suna'
    )
  );
$function$;
DO $alba_suna_check$
BEGIN
 IF NOT EXISTS(SELECT 1 FROM pg_proc WHERE oid='mission_riuji_owner.village_exception(uuid,uuid,uuid)'::regprocedure AND md5(pg_get_functiondef(oid))='4d322d96bef3c706fd373ed92432e9ff' AND proowner='postgres'::regrole AND proacl::text='{postgres=X/postgres}' AND prosecdef AND provolatile='s' AND proconfig=ARRAY['search_path=""']) THEN RAISE EXCEPTION 'ALBA_SUNA_SOURCE_DRIFT';END IF;
 IF (SELECT md5(to_jsonb(m)::text) FROM public.missions m WHERE m.id='a3a8430f-6a3d-4d46-9a75-271d5458406d') IS DISTINCT FROM 'a5f0b8b08c7b5fe33c6f5336dec70661' OR (SELECT md5(document::text) FROM mission_factory_owner.drafts WHERE id='a050c701-796a-4f6b-b129-42b2262e3303') IS DISTINCT FROM 'cf825ecd8fe85c8f32d10e1a717623a3' OR (SELECT md5(definition::text) FROM mission_generic_owner.definitions WHERE plan_version_id='90d513ec-15e9-4a83-b9b9-c67052b77be9') IS DISTINCT FROM '2592d20c17c2ea0dfe1204ee851fd58a' OR mission_generic_owner.selected_plan('a3a8430f-6a3d-4d46-9a75-271d5458406d')->>'plan_version_id' IS DISTINCT FROM '90d513ec-15e9-4a83-b9b9-c67052b77be9' OR mission_public_owner.engine_qualification_v1('fa7f5e2f14fad90a7bd306d022f8dd85b7f411042ad35083a7b28ba5b75a9f0c',true) IS NULL OR NOT mission_public_owner.is_public_launch_v1('a3a8430f-6a3d-4d46-9a75-271d5458406d') OR mission_public_owner.content_admission_v1('a3a8430f-6a3d-4d46-9a75-271d5458406d','fa7f5e2f14fad90a7bd306d022f8dd85b7f411042ad35083a7b28ba5b75a9f0c','1358279e-7d51-4c89-a34a-4d7ec540bb86',true) IS NULL THEN RAISE EXCEPTION 'ALBA_SUNA_CUSTODY_OR_ADMISSION';END IF;
END $alba_suna_check$;
COMMIT;
