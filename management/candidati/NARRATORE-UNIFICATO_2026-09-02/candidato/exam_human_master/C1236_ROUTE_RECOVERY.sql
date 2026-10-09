BEGIN;
DO $patch$
DECLARE p pg_proc; original_ddl text; modified_ddl text; anchor text := $anchor$x.value->>'combat_outcome' in('peaceful','any')$anchor$; replacement text := $replacement$x.value->>'combat_outcome'='peaceful'$replacement$;
BEGIN
 PERFORM pg_advisory_xact_lock(hashtextextended('C1236_HUMAN_PEACEFUL_ROUTE',0));
 SELECT * INTO STRICT p FROM pg_proc WHERE oid='mission_creation_owner.human_peaceful_route(uuid,bigint)'::regprocedure;
 original_ddl:=pg_get_functiondef(p.oid);
 IF md5(p.prosrc)<>'0dcabc253755cc2d4ec219e4facbbe38' 
 OR p.oid<>109102 OR p.proacl::text IS DISTINCT FROM '{postgres=X/postgres}' OR pg_get_userbyid(p.proowner)<>'postgres'
 OR NOT p.prosecdef OR p.provolatile<>'s' OR p.proconfig IS DISTINCT FROM ARRAY['search_path=""']::text[]
 THEN RAISE EXCEPTION 'C1236_ROUTE_BASELINE_DRIFT'; END IF;
 IF (length(p.prosrc)-length(replace(p.prosrc,anchor,'')))/length(anchor)<>1 THEN RAISE EXCEPTION 'C1236_ROUTE_ANCHOR_DRIFT'; END IF;
 modified_ddl:=replace(original_ddl,anchor,replacement);
 EXECUTE modified_ddl;
 SELECT * INTO STRICT p FROM pg_proc WHERE oid='mission_creation_owner.human_peaceful_route(uuid,bigint)'::regprocedure;
 IF md5(p.prosrc)<>'e7e9294dfb950cea196094a67b6e1f40' OR p.oid<>109102 OR p.proacl::text IS DISTINCT FROM '{postgres=X/postgres}'
 OR pg_get_userbyid(p.proowner)<>'postgres' OR NOT p.prosecdef OR p.provolatile<>'s'
 OR p.proconfig IS DISTINCT FROM ARRAY['search_path=""']::text[]
 THEN RAISE EXCEPTION 'C1236_ROUTE_POSTFLIGHT_DRIFT'; END IF;
END $patch$;
COMMIT;
