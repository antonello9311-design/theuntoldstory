BEGIN;
DO $pre$ BEGIN
IF (SELECT jsonb_build_object('oid',oid::bigint,'source_md5',md5(prosrc),'ddl_md5',md5(pg_get_functiondef(oid)),'acl',proacl::text,'owner',pg_get_userbyid(proowner),'security_definer',prosecdef,'config',proconfig) FROM pg_proc WHERE oid=to_regprocedure('mission_human_staff_test_start_v1(uuid,uuid,uuid[],uuid)')) IS DISTINCT FROM $pin${"oid": 50735, "source_md5": "ac289854f74768b8fdd293916d14b59b", "ddl_md5": "48ae61fc9250ac6ccd97e858db882296", "acl": "{postgres=X/postgres,authenticated=X/postgres}", "owner": "postgres", "security_definer": true, "config": ["search_path=\"\""]}$pin$::jsonb THEN RAISE EXCEPTION 'C1237_BASELINE_DRIFT';END IF;
IF (SELECT jsonb_build_object('oid',oid::bigint,'source_md5',md5(prosrc),'ddl_md5',md5(pg_get_functiondef(oid)),'acl',proacl::text,'owner',pg_get_userbyid(proowner),'security_definer',prosecdef,'config',proconfig) FROM pg_proc WHERE oid=to_regprocedure('mission_human_staff_source_create_v1(uuid,jsonb,uuid)')) IS DISTINCT FROM $pin${"oid": 300864, "source_md5": "ac142c1cd8c99c459250bfb9923fa3cf", "ddl_md5": "52808e6fa80f42da097b06bd534fe08b", "acl": "{postgres=X/postgres,authenticated=X/postgres}", "owner": "postgres", "security_definer": true, "config": ["search_path=\"\""]}$pin$::jsonb THEN RAISE EXCEPTION 'C1237_BASELINE_DRIFT';END IF;
IF (SELECT jsonb_build_object('oid',oid::bigint,'source_md5',md5(prosrc),'ddl_md5',md5(pg_get_functiondef(oid)),'acl',proacl::text,'owner',pg_get_userbyid(proowner),'security_definer',prosecdef,'config',proconfig) FROM pg_proc WHERE oid=to_regprocedure('mission_public_owner.human_session_allowed_v1(uuid)')) IS DISTINCT FROM $pin${"oid": 276557, "source_md5": "2c7fd64ec85fbbe088ece645c72c4be0", "ddl_md5": "17c0ebed78afecc80ae54dcb88cb1737", "acl": "{postgres=X/postgres}", "owner": "postgres", "security_definer": true, "config": ["search_path=\"\""]}$pin$::jsonb THEN RAISE EXCEPTION 'C1237_BASELINE_DRIFT';END IF;IF EXISTS(SELECT 1 FROM public.master_v2_sessions WHERE location_id='0b85f354-9cdb-47e1-baf9-3d266bb7e06b' AND closed_at IS NULL) OR EXISTS(SELECT 1 FROM public.combat_v2_sessions WHERE location_id='0b85f354-9cdb-47e1-baf9-3d266bb7e06b' AND closed_at IS NULL) THEN RAISE EXCEPTION 'C1237_STAFF_BUSY'; END IF;
END $pre$;
CREATE OR REPLACE FUNCTION public.mission_human_staff_source_create_v1(p_request uuid, p_document jsonb, p_location uuid)
 RETURNS jsonb
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO ''
AS $function$
DECLARE old record;pf jsonb;validation jsonb;m jsonb;
 mid uuid;doc_sha text;result jsonb;scene jsonb;enc jsonb;actor jsonb;enc_count integer:=0;
BEGIN
 IF auth.uid() IS NULL OR auth.role() IS DISTINCT FROM 'authenticated' OR p_request IS NULL
 OR p_location IS DISTINCT FROM '0b85f354-9cdb-47e1-baf9-3d266bb7e06b'::uuid
 THEN RAISE EXCEPTION 'H3_STAFF_SOURCE_AUTHORITY' USING ERRCODE='42501'; END IF;
 PERFORM mission_ai_board_owner.staff_only();
 PERFORM 1 FROM public.locations WHERE id=p_location AND is_active AND is_test FOR SHARE;
 IF NOT FOUND OR NOT public.master_v2_is_master(auth.uid())
 OR combat_consumer_private.staff_test_allowed(p_location,ARRAY[auth.uid()],false) IS DISTINCT FROM true
 THEN RAISE EXCEPTION 'H3_STAFF_SOURCE_AUTHORITY' USING ERRCODE='42501'; END IF;
 doc_sha:=mission_internal.fingerprint(p_document);
 PERFORM pg_advisory_xact_lock(hashtextextended('mission-create:'||p_request::text,611));
 SELECT * INTO old FROM mission_creation_owner.h3_staff_source_requests WHERE request_key=p_request;
 IF FOUND THEN
  IF old.actor_user IS DISTINCT FROM auth.uid() OR old.document_sha256 IS DISTINCT FROM doc_sha
  THEN RAISE EXCEPTION 'H3_STAFF_SOURCE_REPLAY_CONFLICT' USING ERRCODE='40001'; END IF;
  RETURN old.result;
 END IF;
 IF EXISTS(SELECT 1 FROM mission_creation_owner.requests WHERE request_key=p_request)
 THEN RAISE EXCEPTION 'H3_STAFF_SOURCE_REQUEST_CONFLICT' USING ERRCODE='40001'; END IF;
 pf:=mission_creation_owner.preflight_document_v2(p_document);
 IF (pf->>'ok')::boolean IS DISTINCT FROM true
 THEN RAISE EXCEPTION 'H3_STAFF_SOURCE_PREFLIGHT:%',pf->'errors' USING ERRCODE='22023'; END IF;
 m:=p_document->'mission';
 IF m->>'direction_mode' IS DISTINCT FROM 'human' OR m->>'team_min' IS DISTINCT FROM '1'
 OR m->>'team_max' IS DISTINCT FROM '1' OR p_document#>>'{plan,base_plan_version_id}' IS NOT NULL
 THEN RAISE EXCEPTION 'H3_STAFF_SOURCE_SCOPE' USING ERRCODE='22023'; END IF;
 FOR scene IN SELECT value FROM jsonb_array_elements(p_document#>'{plan,definition,scenes}') LOOP
  FOR enc IN SELECT value FROM jsonb_array_elements(coalesce(scene->'encounters','[]'::jsonb)) LOOP
   enc_count:=enc_count+1;
   IF (jsonb_array_length(enc->'actors') BETWEEN 1 AND 4) IS NOT TRUE
   THEN RAISE EXCEPTION 'H4_STAFF_SOURCE_PNG_COUNT' USING ERRCODE='22023'; END IF;
   IF EXISTS(SELECT 1 FROM jsonb_array_elements(enc->'actors') a WHERE nullif(a->>'actor_key','') IS NULL)
    OR (SELECT count(DISTINCT a->>'actor_key') FROM jsonb_array_elements(enc->'actors') a) <> jsonb_array_length(enc->'actors')
   THEN RAISE EXCEPTION 'H4_STAFF_SOURCE_DISTINCT_ACTORS' USING ERRCODE='22023'; END IF;
   FOR actor IN SELECT value FROM jsonb_array_elements(enc->'actors') LOOP
    IF actor->>'mechanical_binding_id' IS DISTINCT FROM '66a6628d-d465-4103-b74b-2184f4b07d04'
    THEN RAISE EXCEPTION 'H3_STAFF_SOURCE_APPROVED_PROFILE_REQUIRED' USING ERRCODE='42501'; END IF;
   END LOOP;
  END LOOP;
 END LOOP;
 IF enc_count<>1 THEN RAISE EXCEPTION 'H3_STAFF_SOURCE_ONE_ENCOUNTER' USING ERRCODE='22023'; END IF;
 validation:=mission_creation_owner.map_binding_guard_mission_publish_v1(p_document,mission_creation_owner.validate_document(p_document));
 mid:=public.missione_crea(m->>'title',m->>'grado',m->>'briefing',nullif(m->>'village',''),m->>'tag_trama',1,1,validation->>'gathering_name',30,0);
 -- La stessa transazione non espone mai la fonte aperta alla bacheca o alle iscrizioni.
 UPDATE public.missions SET status='annullata' WHERE id=mid AND status='aperta';
 IF NOT FOUND THEN RAISE EXCEPTION 'H3_STAFF_SOURCE_RESERVATION_FAILED'; END IF;
 result:=mission_creation_owner.save_complete(mid,p_request,mission_internal.fingerprint(mission_generic_owner.mission_editor_snapshot(mid)),0,p_document);
 IF result->>'schema_version' IS DISTINCT FROM 'mission-creation-result/1'
 OR result->>'mission_id' IS DISTINCT FROM mid::text OR result->>'state' IS DISTINCT FROM 'configured'
 OR NOT EXISTS(SELECT 1 FROM public.missions WHERE id=mid AND status='annullata' AND xp_reward=30 AND ryo_reward=0)
 THEN RAISE EXCEPTION 'H3_STAFF_SOURCE_POSTCONDITION'; END IF;
 INSERT INTO mission_creation_owner.h3_staff_source_requests(request_key,actor_user,document_sha256,mission_id,result)
 VALUES(p_request,auth.uid(),doc_sha,mid,result);
 RETURN result;
END $function$
;
COMMIT;
