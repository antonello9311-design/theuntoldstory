BEGIN;
SET LOCAL lock_timeout='5s';
SET LOCAL statement_timeout='30s';
DO $pre$
BEGIN
 IF to_regprocedure('public.mission_human_staff_test_recover_v1(uuid)') IS NOT NULL THEN RAISE EXCEPTION 'C1236_RECOVER_ALREADY_PRESENT'; END IF;
 IF md5(pg_get_functiondef('mission_creation_owner.human_assert(uuid)'::regprocedure))<>'64240b718db9c55cb6039a8dce4d6c1b'
 OR md5(pg_get_functiondef('mission_creation_owner.human_simulated(uuid)'::regprocedure))<>'25674d09fe7cac92bfdea65908db6093'
 THEN RAISE EXCEPTION 'C1236_RECOVER_AUTHORITY_DRIFT'; END IF;
END $pre$;
CREATE FUNCTION public.mission_human_staff_test_recover_v1(p_session uuid) RETURNS jsonb
LANGUAGE plpgsql STABLE SECURITY DEFINER SET search_path='' AS $fn$
DECLARE m public.master_v2_sessions; n bigint; v jsonb;
BEGIN
 PERFORM mission_ai_board_owner.staff_only();
 PERFORM mission_creation_owner.human_assert(p_session);
 SELECT * INTO STRICT m FROM public.master_v2_sessions WHERE id=p_session;
 IF m.location_id<>'0b85f354-9cdb-47e1-baf9-3d266bb7e06b'::uuid
 OR mission_creation_owner.human_simulated(p_session) IS DISTINCT FROM true
 THEN RAISE EXCEPTION 'MC_RECOVER_TEST_SCOPE' USING ERRCODE='42501'; END IF;
 SELECT count(*),jsonb_agg(jsonb_build_object('schema_version','mission-human-staff-start/5',
  'user',q.actor_user,'mission',ss.source_mission_id,'location',a.location_id,
  'request',q.request_key,'roster',to_jsonb(a.roster),'result',q.result))->0 INTO n,v
 FROM mission_creation_owner.requests q
 JOIN mission_creation_owner.human_test_admissions a ON a.request_key=q.request_key AND a.carrier_mission_id=q.mission_id AND a.actor_user=q.actor_user
 JOIN mission_generic_owner.simulation_sources ss ON ss.carrier_mission_id=q.mission_id AND ss.request_key=q.request_key
 WHERE q.mission_id=m.mission_id AND q.actor_user=auth.uid() AND a.location_id=m.location_id
 AND q.result->>'schema_version'='mission-human-test-start/1'
 AND q.result->>'master_session_id'=p_session::text AND q.result->>'source_mission_id'=ss.source_mission_id::text
 AND q.result->>'simulation'='true' AND q.result->>'direction_mode'='human'
 AND cardinality(a.roster) BETWEEN 1 AND 4;
 IF n<>1 THEN RAISE EXCEPTION 'MC_RECOVER_ORIGINAL_RECEIPT_REQUIRED' USING ERRCODE='55000'; END IF;
 RETURN v;
END;
$fn$;
REVOKE ALL ON FUNCTION public.mission_human_staff_test_recover_v1(uuid) FROM PUBLIC,anon,authenticated,service_role;
GRANT EXECUTE ON FUNCTION public.mission_human_staff_test_recover_v1(uuid) TO authenticated;
DO $post$
BEGIN
 IF NOT EXISTS(SELECT 1 FROM pg_proc WHERE oid='public.mission_human_staff_test_recover_v1(uuid)'::regprocedure AND md5(prosrc)='3b0c60380818034207cc3e432b7e894c' AND prosecdef AND provolatile='s' AND pg_get_userbyid(proowner)='postgres' AND proconfig=ARRAY['search_path=""']::text[] AND proacl::text='{postgres=X/postgres,authenticated=X/postgres}') THEN RAISE EXCEPTION 'C1236_RECOVER_POSTFLIGHT'; END IF;
END $post$;
COMMIT;
