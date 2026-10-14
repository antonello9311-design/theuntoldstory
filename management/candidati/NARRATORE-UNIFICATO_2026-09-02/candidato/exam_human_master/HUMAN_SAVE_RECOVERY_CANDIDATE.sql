DO $preflight$ BEGIN IF current_user<>'postgres' OR to_regprocedure('public.mission_factory_quest_save_recovery_v1(uuid,bigint,jsonb,uuid)') IS NOT NULL THEN RAISE EXCEPTION 'MF_SAVE_RECOVERY_INSTALL_SCOPE';END IF; IF EXISTS(SELECT 1 FROM public.master_v2_sessions WHERE location_id='0b85f354-9cdb-47e1-baf9-3d266bb7e06b' AND closed_at IS NULL) THEN RAISE EXCEPTION 'MF_SAVE_RECOVERY_QUIESCENCE';END IF; IF md5(pg_get_functiondef('mission_factory_owner.c444_runtime_ports_complete_assert_v1()'::regprocedure)) IS DISTINCT FROM 'b12c3dd456f818f70e47cb8ef7776434' THEN RAISE EXCEPTION 'MF_SAVE_RECOVERY_PARENT_CAS';END IF; IF md5(pg_get_functiondef('mission_factory_owner.validate_quest_draft_v2(jsonb)'::regprocedure)) IS DISTINCT FROM 'f8664f0cb29c5b7a860826ea1006e58f' THEN RAISE EXCEPTION 'MF_SAVE_RECOVERY_PARENT_CAS';END IF; IF md5(pg_get_functiondef('public.mission_factory_request_state_v2(uuid,text)'::regprocedure)) IS DISTINCT FROM '7b8654e46638c82abe7a44d3701620d2' THEN RAISE EXCEPTION 'MF_SAVE_RECOVERY_PARENT_CAS';END IF; IF md5(pg_get_functiondef('public.mission_factory_save_v1(uuid,bigint,jsonb,uuid)'::regprocedure)) IS DISTINCT FROM '7bab4f2c44d607a1e66a242109741996' THEN RAISE EXCEPTION 'MF_SAVE_RECOVERY_PARENT_CAS';END IF; IF md5(pg_get_functiondef('combat_consumer_private.staff_test_allowed(uuid,uuid[],boolean)'::regprocedure)) IS DISTINCT FROM '255e8d73cdd7c3814132d71f0f45b1b5' THEN RAISE EXCEPTION 'MF_SAVE_RECOVERY_STAFF_PARENT_CAS';END IF; IF md5(pg_get_functiondef('mission_factory_owner.c416_kind_live_v1()'::regprocedure)) IS DISTINCT FROM 'ca836584b84f114ede05277e91610235' THEN RAISE EXCEPTION 'MF_SAVE_RECOVERY_STAFF_PARENT_CAS';END IF; IF md5(pg_get_functiondef('mission_factory_owner.c444_enabled_v1()'::regprocedure)) IS DISTINCT FROM '2b8d0af96cf3601f48bbfe9f862c9823' THEN RAISE EXCEPTION 'MF_SAVE_RECOVERY_STAFF_PARENT_CAS';END IF; IF md5(pg_get_functiondef('public.is_staff()'::regprocedure)) IS DISTINCT FROM 'da3d2441d69193629f7ee3d795bb1c3a' THEN RAISE EXCEPTION 'MF_SAVE_RECOVERY_STAFF_PARENT_CAS';END IF; PERFORM mission_factory_owner.c444_runtime_ports_complete_assert_v1();END $preflight$;
CREATE FUNCTION public.mission_factory_quest_save_recovery_v1(p_draft uuid,p_expected_version bigint,p_document jsonb,p_request uuid)
RETURNS jsonb LANGUAGE plpgsql SECURITY DEFINER SET search_path TO '' AS $function$
DECLARE d mission_factory_owner.drafts; r mission_factory_owner.requests; doc jsonb; fp text; state text:='unknown'; rejection text; result jsonb; err text; code text;
BEGIN
 IF auth.uid() IS NULL OR p_draft IS NULL OR p_request IS NULL OR p_expected_version IS NULL OR p_expected_version<1 OR p_document->>'content_kind' IS DISTINCT FROM 'quest_ai' OR p_document->>'schema_version' IS DISTINCT FROM 'mission-factory-draft/2' THEN RAISE EXCEPTION 'MF_SAVE_RECOVERY_INPUT' USING ERRCODE='22023';END IF;
 PERFORM mission_factory_owner.assert_editor(auth.uid());
 IF p_draft IS DISTINCT FROM 'e6d1b561-cc76-4fb9-8e4e-b73ffc86b6be'::uuid
 OR public.is_staff() IS DISTINCT FROM true
 OR mission_factory_owner.c416_kind_live_v1() IS DISTINCT FROM true
 OR mission_factory_owner.c444_enabled_v1() IS DISTINCT FROM true
 OR NOT EXISTS(SELECT 1 FROM mission_factory_owner.c416_kind_admission k WHERE k.singleton AND k.enabled AND auth.uid()=ANY(k.allowed_auth_ids) AND k.bound_at<=statement_timestamp() AND k.expires_at>statement_timestamp())
 OR combat_consumer_private.staff_test_allowed('0b85f354-9cdb-47e1-baf9-3d266bb7e06b'::uuid,ARRAY[auth.uid()]::uuid[],false) IS DISTINCT FROM true
 OR NOT EXISTS(SELECT 1 FROM mission_factory_owner.manual_authoring_admissions_v1 a WHERE a.actor_user=auth.uid() AND a.release_sha256='37dac90525b249f53fc0404b50adb4ed92df0123649326c99260bf656119d806' AND a.location_id='0b85f354-9cdb-47e1-baf9-3d266bb7e06b'::uuid AND a.enabled AND 'save'=ANY(a.operations) AND a.staff_context_bound_at<=statement_timestamp() AND a.expires_at>statement_timestamp())
 THEN RAISE EXCEPTION 'MF_SAVE_RECOVERY_STAFF_SCOPE' USING ERRCODE='42501';END IF;
 PERFORM mission_factory_owner.c444_runtime_ports_complete_assert_v1();
 PERFORM pg_catalog.pg_advisory_xact_lock(pg_catalog.hashtextextended(p_request::text,24092027));
 SELECT * INTO STRICT d FROM mission_factory_owner.drafts WHERE id=p_draft FOR SHARE;
 PERFORM mission_factory_owner.assert_editor(d.author_user);
 IF d.author_user IS DISTINCT FROM auth.uid() OR d.document->>'content_kind' IS DISTINCT FROM 'quest_ai' THEN RAISE EXCEPTION 'MF_SAVE_RECOVERY_OWNER' USING ERRCODE='42501';END IF;
 SELECT * INTO r FROM mission_factory_owner.requests WHERE request_key=p_request;
 IF FOUND THEN
  IF r.actor_user IS DISTINCT FROM auth.uid() OR r.operation IS DISTINCT FROM 'save' OR r.draft_id IS DISTINCT FROM p_draft THEN RAISE EXCEPTION 'MF_REQUEST_CONFLICT' USING ERRCODE='40001';END IF;
  doc:=mission_factory_owner.validate_quest_draft_v2(p_document);
  fp:=mission_factory_owner.sha(jsonb_build_object('op','save','draft_id',p_draft,'expected_version',p_expected_version,'document',doc));
  IF r.fingerprint IS DISTINCT FROM fp OR r.result->>'schema_version' IS DISTINCT FROM 'mission-factory-draft-save/2' OR r.result->>'request_key' IS DISTINCT FROM p_request::text OR r.result->>'draft_id' IS DISTINCT FROM p_draft::text OR r.result->>'content_kind' IS DISTINCT FROM 'quest_ai' THEN RAISE EXCEPTION 'MF_REQUEST_CONFLICT' USING ERRCODE='40001';END IF;
  state:='confirmed';result:=r.result;
 ELSE
  IF d.control_version IS DISTINCT FROM p_expected_version OR d.state NOT IN('draft','previewed') THEN RAISE EXCEPTION 'MF_DRAFT_DRIFT' USING ERRCODE='40001';END IF;
  BEGIN
   doc:=mission_factory_owner.validate_quest_draft_v2(p_document);
  EXCEPTION WHEN SQLSTATE '22023' THEN
   GET STACKED DIAGNOSTICS err=MESSAGE_TEXT,code=RETURNED_SQLSTATE;
   IF code='22023' AND err='MF_QUEST_ARENA_SHAPE' THEN state:='rejected';rejection:=err;END IF;
  END;
 END IF;
 RETURN jsonb_build_object('schema_version','mission-factory-quest-save-recovery/1','request_key',p_request,'draft_id',p_draft,'expected_control_version',p_expected_version,'content_kind','quest_ai','state',state,'payload_sha256',mission_factory_owner.sha(p_document),'rejection_code',rejection,'confirmed_result',result);
END $function$;
REVOKE ALL ON FUNCTION public.mission_factory_quest_save_recovery_v1(uuid,bigint,jsonb,uuid) FROM PUBLIC,anon,service_role;
GRANT EXECUTE ON FUNCTION public.mission_factory_quest_save_recovery_v1(uuid,bigint,jsonb,uuid) TO authenticated;
DO $postflight$ BEGIN IF md5((SELECT prosrc FROM pg_proc WHERE oid='public.mission_factory_quest_save_recovery_v1(uuid,bigint,jsonb,uuid)'::regprocedure)) IS DISTINCT FROM '1a0c51b62173632e9a4206ab134e2588' THEN RAISE EXCEPTION 'MF_SAVE_RECOVERY_BODY';END IF; IF (SELECT array_agg(CASE WHEN a.grantee=0 THEN 'PUBLIC' ELSE pg_get_userbyid(a.grantee) END ORDER BY CASE WHEN a.grantee=0 THEN 'PUBLIC' ELSE pg_get_userbyid(a.grantee) END)::text[] FROM pg_proc p CROSS JOIN LATERAL aclexplode(coalesce(p.proacl,acldefault('f',p.proowner))) a WHERE p.oid='public.mission_factory_quest_save_recovery_v1(uuid,bigint,jsonb,uuid)'::regprocedure AND a.privilege_type='EXECUTE') IS DISTINCT FROM ARRAY['authenticated','postgres']::text[] THEN RAISE EXCEPTION 'MF_SAVE_RECOVERY_ACL';END IF; PERFORM mission_factory_owner.c444_runtime_ports_complete_assert_v1();END $postflight$;
