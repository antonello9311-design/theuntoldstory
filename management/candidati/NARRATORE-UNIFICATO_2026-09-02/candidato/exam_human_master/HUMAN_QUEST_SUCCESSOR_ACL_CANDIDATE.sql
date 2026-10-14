BEGIN;
DO $cas$ DECLARE p pg_catalog.pg_proc; evidence jsonb; BEGIN
 evidence:=nullif(pg_catalog.current_setting('tus.human_successor_acl_authority',true),'')::jsonb;
 IF current_user<>'postgres' OR evidence IS NULL OR evidence->>'schema_version' IS DISTINCT FROM 'human-quest-successor-acl-authority/1' OR evidence->>'operation' IS DISTINCT FROM 'grant_authenticated' OR evidence->>'review' IS DISTINCT FROM '0/0/0' OR coalesce((evidence->>'expires_at')::timestamptz,'-infinity'::timestamptz)<=clock_timestamp() THEN RAISE EXCEPTION 'HUMAN_SUCCESSOR_ACL_AUTHORITY';END IF;
 SELECT * INTO STRICT p FROM pg_catalog.pg_proc WHERE oid='public.mission_factory_quest_human_successor_scope_v1(uuid)'::regprocedure;
 IF p.oid<>279885 OR p.proowner<>'postgres'::regrole OR p.proacl::text IS DISTINCT FROM '{postgres=X/postgres}' OR pg_catalog.md5(p.prosrc) IS DISTINCT FROM 'bd64eb3e6b6d547b53b7b631e376a16c' OR pg_catalog.md5(pg_catalog.pg_get_functiondef(p.oid)) IS DISTINCT FROM 'e1e71c24f947d2d88b998ed8db1c6eb5' OR p.prosecdef IS DISTINCT FROM true OR p.proconfig IS DISTINCT FROM ARRAY['search_path=""']::text[] THEN RAISE EXCEPTION 'HUMAN_SUCCESSOR_ACL_BASELINE_DRIFT';END IF;
 IF pg_catalog.md5(pg_catalog.pg_get_functiondef('mission_factory_owner.c407_identity_v1(uuid)'::regprocedure)) IS DISTINCT FROM '1e98938354fcb8e27cf826ab90f22770' OR pg_catalog.md5(pg_catalog.pg_get_functiondef('mission_factory_owner.c444_source_read_assert_v1(uuid)'::regprocedure)) IS DISTINCT FROM '6e18de2d68527bcf821e3ee5cc153201' THEN RAISE EXCEPTION 'HUMAN_SUCCESSOR_ACL_AUTH_PARENT_DRIFT';END IF;
 END $cas$;
REVOKE ALL ON FUNCTION public.mission_factory_quest_human_successor_scope_v1(uuid) FROM PUBLIC,anon,service_role;
GRANT EXECUTE ON FUNCTION public.mission_factory_quest_human_successor_scope_v1(uuid) TO authenticated;
DO $post$ BEGIN IF (SELECT proacl::text FROM pg_catalog.pg_proc WHERE oid='public.mission_factory_quest_human_successor_scope_v1(uuid)'::regprocedure) IS DISTINCT FROM '{postgres=X/postgres,authenticated=X/postgres}' OR pg_catalog.md5(pg_catalog.pg_get_functiondef('public.mission_factory_quest_human_successor_scope_v1(uuid)'::regprocedure)) IS DISTINCT FROM 'e1e71c24f947d2d88b998ed8db1c6eb5' THEN RAISE EXCEPTION 'HUMAN_SUCCESSOR_ACL_POSTIMAGE';END IF;END $post$;
COMMIT;
