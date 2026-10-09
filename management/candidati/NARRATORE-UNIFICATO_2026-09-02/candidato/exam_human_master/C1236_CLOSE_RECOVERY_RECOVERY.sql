BEGIN;
DO $recover$
DECLARE p pg_proc;
BEGIN
 PERFORM pg_advisory_xact_lock(hashtextextended('C1236_HUMAN_STAFF_RECOVERY',0));
 SELECT * INTO p FROM pg_proc WHERE oid=to_regprocedure('public.mission_human_staff_test_recover_v1(uuid)');
 IF NOT FOUND THEN RAISE EXCEPTION 'C1236_RECOVERY_NOT_INSTALLED'; END IF;
 IF md5(p.prosrc)<>'3b0c60380818034207cc3e432b7e894c' OR NOT p.prosecdef OR p.provolatile<>'s'
 OR pg_get_userbyid(p.proowner)<>'postgres' OR p.proconfig IS DISTINCT FROM ARRAY['search_path=""']::text[]
 OR p.proacl IS NULL OR p.proacl::text NOT IN('{postgres=X/postgres,authenticated=X/postgres}','{postgres=X/postgres}')
 THEN RAISE EXCEPTION 'C1236_RECOVERY_DRIFT'; END IF;
 EXECUTE 'REVOKE EXECUTE ON FUNCTION public.mission_human_staff_test_recover_v1(uuid) FROM PUBLIC,anon,authenticated,service_role';
 SELECT * INTO STRICT p FROM pg_proc WHERE oid='public.mission_human_staff_test_recover_v1(uuid)'::regprocedure;
 IF md5(p.prosrc)<>'3b0c60380818034207cc3e432b7e894c' OR p.proacl::text IS DISTINCT FROM '{postgres=X/postgres}'
 THEN RAISE EXCEPTION 'C1236_RECOVERY_POSTFLIGHT'; END IF;
END $recover$;
COMMIT;
