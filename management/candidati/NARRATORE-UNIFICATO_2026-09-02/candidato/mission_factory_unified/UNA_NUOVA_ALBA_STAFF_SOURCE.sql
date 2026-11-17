BEGIN;
SET LOCAL lock_timeout = '4s';

DO $preflight$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_proc p WHERE p.oid=to_regprocedure('public.mission_alba_staff_source_v1(uuid)')
      AND md5(p.prosrc)='a8c836f46581a7112014ae34997015d4'
      AND p.proacl::text='{postgres=X/postgres,authenticated=X/postgres}'
  ) THEN
    RAISE EXCEPTION 'ALBA_STAFF_SOURCE_BASELINE_CHANGED';
  END IF;
  IF NOT EXISTS (
    SELECT 1 FROM pg_proc p JOIN pg_namespace n ON n.oid=p.pronamespace
    WHERE n.nspname='mission_creation_owner' AND p.proname='save_complete'
      AND md5(p.prosrc)='0f5c8c882acf4f10031845c9086fa6b9'
  ) THEN
    RAISE EXCEPTION 'ALBA_STAFF_SAVE_BASELINE_CHANGED';
  END IF;
END;
$preflight$;

CREATE OR REPLACE FUNCTION public.mission_alba_staff_source_v1(p_request uuid)
RETURNS jsonb
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path TO ''
AS $alba$
DECLARE
  draft mission_factory_owner.drafts;
  prior mission_creation_owner.h3_staff_source_requests;
  native_document jsonb;
  metadata jsonb;
  validation jsonb;
  result jsonb;
  mid uuid;
  source_sha text;
  actor constant uuid := 'f0856d53-83a6-4de0-bc0c-12c87916e665';
  room constant uuid := '0b85f354-9cdb-47e1-baf9-3d266bb7e06b';
  expected_document constant text := 'a96ec585eb572a592cdf973e68a26e959011ad916da28555de2993fda9d337ab';
BEGIN
  IF auth.uid() IS DISTINCT FROM actor OR auth.role() IS DISTINCT FROM 'authenticated'
     OR p_request IS DISTINCT FROM '14598d12-2c11-552e-a95d-0f2f3c3c6af9'::uuid THEN
    RAISE EXCEPTION 'ALBA_STAFF_SOURCE_FORBIDDEN' USING ERRCODE='42501';
  END IF;
  PERFORM mission_ai_board_owner.staff_only();
  PERFORM 1 FROM public.locations WHERE id=room AND is_active AND is_test FOR SHARE;
  IF NOT FOUND OR NOT public.master_v2_is_master(actor)
     OR combat_consumer_private.staff_test_allowed(room,ARRAY[actor],false) IS DISTINCT FROM true THEN
    RAISE EXCEPTION 'ALBA_STAFF_ROOM_FORBIDDEN' USING ERRCODE='42501';
  END IF;
  PERFORM pg_advisory_xact_lock(hashtextextended('mission-alba-source:'||p_request::text,611));
  SELECT * INTO prior FROM mission_creation_owner.h3_staff_source_requests WHERE request_key=p_request;
  IF FOUND THEN
    IF prior.actor_user IS DISTINCT FROM actor OR prior.document_sha256 IS DISTINCT FROM expected_document
       OR prior.result->>'schema_version' IS DISTINCT FROM 'mission-creation-result/1'
       OR prior.result->>'mission_id' IS DISTINCT FROM prior.mission_id::text
       OR prior.result->>'direction_mode' IS DISTINCT FROM 'ai'
       OR prior.result->>'state' IS DISTINCT FROM 'configured'
       OR NOT EXISTS(SELECT 1 FROM public.missions m WHERE m.id=prior.mission_id
          AND m.created_by=actor AND m.status='annullata' AND m.xp_reward=0 AND m.ryo_reward=0)
       OR NOT EXISTS(
         SELECT 1 FROM mission_creation_owner.revisions r
         JOIN mission_generic_owner.plan_selections s ON s.mission_id=r.mission_id
           AND s.plan_version_id=r.plan_version_id
         JOIN public.mission_plan_versions v ON v.id=r.plan_version_id AND v.stato='approvata'
         WHERE r.mission_id=prior.mission_id
           AND r.plan_version_id=(prior.result->>'plan_version_id')::uuid
           AND r.direction_mode='ai' AND r.document_sha256=expected_document
           AND mission_internal.fingerprint(r.document)=expected_document
           AND v.plan_sha256=mission_internal.plan_fingerprint(v.id))
       OR EXISTS(SELECT 1 FROM mission_factory_owner.publications WHERE mission_id=prior.mission_id)
       OR EXISTS(SELECT 1 FROM mission_launch_owner.capabilities WHERE mission_id=prior.mission_id) THEN
      RAISE EXCEPTION 'ALBA_STAFF_SOURCE_REPLAY_CONFLICT' USING ERRCODE='40001';
    END IF;
    RETURN prior.result;
  END IF;
  SELECT * INTO STRICT draft FROM mission_factory_owner.drafts
    WHERE id='a050c701-796a-4f6b-b129-42b2262e3303' FOR SHARE;
  IF draft.author_user IS DISTINCT FROM actor OR draft.control_version IS DISTINCT FROM 3
     OR draft.state IS DISTINCT FROM 'draft'
     OR md5(draft.document::text) IS DISTINCT FROM 'cf825ecd8fe85c8f32d10e1a717623a3' THEN
    RAISE EXCEPTION 'ALBA_STAFF_DRAFT_DRIFT' USING ERRCODE='40001';
  END IF;
  native_document:=draft.document#>'{variants,ai,document}';
  source_sha:=mission_internal.fingerprint(native_document);
  metadata:=native_document->'mission';
  IF source_sha IS DISTINCT FROM expected_document
     OR metadata->>'direction_mode' IS DISTINCT FROM 'ai'
     OR metadata->>'team_min' IS DISTINCT FROM '2' OR metadata->>'team_max' IS DISTINCT FROM '2'
     OR native_document#>>'{plan,base_plan_version_id}' IS NOT NULL
     OR native_document->'arenas' IS DISTINCT FROM '[]'::jsonb
     OR jsonb_array_length(native_document#>'{plan,steps}') IS DISTINCT FROM 4
     OR EXISTS(SELECT 1 FROM jsonb_array_elements(native_document#>'{plan,steps}') s
               WHERE s->>'kind' IS DISTINCT FROM 'narrative')
     OR EXISTS(SELECT 1 FROM jsonb_array_elements(native_document#>'{plan,definition,scenes}') s
               WHERE s->'actors' IS DISTINCT FROM '[]'::jsonb
                  OR s->'encounters' IS DISTINCT FROM '[]'::jsonb) THEN
    RAISE EXCEPTION 'ALBA_STAFF_SOURCE_DOCUMENT' USING ERRCODE='42501';
  END IF;
  PERFORM pg_advisory_xact_lock(hashtextextended('mission-alba-document:'||source_sha,611));
  IF EXISTS(SELECT 1 FROM mission_creation_owner.h3_staff_source_requests
            WHERE document_sha256=source_sha) THEN
    RAISE EXCEPTION 'ALBA_STAFF_SOURCE_EXISTS_USE_ORIGINAL_REQUEST' USING ERRCODE='40001';
  END IF;
  validation:=mission_creation_owner.map_binding_guard_mission_publish_v1(
    native_document,mission_creation_owner.validate_document(native_document));
  mid:=public.missione_crea(metadata->>'title',metadata->>'grado',metadata->>'briefing',
    nullif(metadata->>'village',''),metadata->>'tag_trama',
    (metadata->>'team_min')::integer,(metadata->>'team_max')::integer,
    validation->>'gathering_name',0,0);
  UPDATE public.missions SET status='annullata' WHERE id=mid AND status='aperta';
  IF NOT FOUND THEN RAISE EXCEPTION 'ALBA_STAFF_RESERVATION_FAILED'; END IF;
  result:=mission_creation_owner.save_complete(mid,p_request,
    mission_internal.fingerprint(mission_generic_owner.mission_editor_snapshot(mid)),0,native_document);
  IF result->>'schema_version' IS DISTINCT FROM 'mission-creation-result/1'
     OR result->>'mission_id' IS DISTINCT FROM mid::text
     OR result->>'direction_mode' IS DISTINCT FROM 'ai'
     OR result->>'state' IS DISTINCT FROM 'configured'
     OR NOT EXISTS(SELECT 1 FROM public.missions m WHERE m.id=mid AND m.status='annullata'
             AND m.xp_reward=0 AND m.ryo_reward=0 AND m.team_min=2 AND m.team_max=2 AND m.created_by=actor)
     OR NOT EXISTS(SELECT 1 FROM mission_creation_owner.revisions r
          JOIN mission_generic_owner.plan_selections s ON s.mission_id=r.mission_id
               AND s.plan_version_id=r.plan_version_id
          WHERE r.mission_id=mid AND r.plan_version_id=(result->>'plan_version_id')::uuid
            AND r.direction_mode='ai' AND r.document=native_document AND r.document_sha256=source_sha)
     OR EXISTS(SELECT 1 FROM public.master_v2_sessions WHERE mission_id=mid)
     OR EXISTS(SELECT 1 FROM mission_factory_owner.publications WHERE mission_id=mid) THEN
    RAISE EXCEPTION 'ALBA_STAFF_SOURCE_POSTCONDITION';
  END IF;
  INSERT INTO mission_creation_owner.h3_staff_source_requests(
    request_key,actor_user,document_sha256,mission_id,result)
  VALUES(p_request,actor,source_sha,mid,result);
  RETURN result;
END;
$alba$;

ALTER FUNCTION public.mission_alba_staff_source_v1(uuid) OWNER TO postgres;
REVOKE ALL ON FUNCTION public.mission_alba_staff_source_v1(uuid) FROM PUBLIC,anon,authenticated;
GRANT EXECUTE ON FUNCTION public.mission_alba_staff_source_v1(uuid) TO authenticated;
COMMIT;
