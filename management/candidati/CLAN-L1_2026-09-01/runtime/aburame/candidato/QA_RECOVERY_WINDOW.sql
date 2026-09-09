CREATE TEMP TABLE recovery_results(case_id text,passed boolean,error text);
CREATE TEMP TABLE recovery_pg_before AS SELECT md5(coalesce(string_agg(to_jsonb(c)::text,'' ORDER BY id),'')) AS seal FROM public.characters c;
CREATE FUNCTION pg_temp.rid(n integer) RETURNS uuid LANGUAGE sql IMMUTABLE AS 'SELECT md5(''recovery-window-qa-''||n)::uuid';
CREATE FUNCTION pg_temp.charid() RETURNS uuid LANGUAGE sql AS 'SELECT id FROM public.characters ORDER BY id LIMIT 1';
CREATE FUNCTION pg_temp.legacy(n integer,start_time timestamptz,end_time timestamptz,role_name text DEFAULT 'combattente') RETURNS void LANGUAGE plpgsql AS $f$
DECLARE u uuid;cid uuid:=pg_temp.charid();sid uuid:=pg_temp.rid(n);loc uuid:=pg_temp.rid(n+1000);
BEGIN
 SELECT user_id INTO u FROM public.characters WHERE id=cid;
 INSERT INTO public.locations(id,name,is_test) VALUES(loc,'Fixture recupero legacy',false);
 INSERT INTO public.combat_sessions(id,location_id,opened_by,state,created_at,closed_at) VALUES(sid,loc,u,'chiuso',start_time,end_time);
 INSERT INTO public.combat_participants(session_id,user_id,character_id,character_name,ruolo,joined_at) VALUES(sid,u,cid,'PG sintetico',role_name,start_time);
END $f$;
CREATE FUNCTION pg_temp.v2(n integer,start_time timestamptz,end_time timestamptz,test_room boolean DEFAULT false,actor_state text DEFAULT 'attivo',master_left timestamptz DEFAULT NULL) RETURNS uuid LANGUAGE plpgsql AS $f$
DECLARE u uuid;cid uuid:=pg_temp.charid();sid uuid:=pg_temp.rid(n);loc uuid:=pg_temp.rid(n+1000);mid uuid;
BEGIN
 SELECT user_id INTO u FROM public.characters WHERE id=cid;
 INSERT INTO public.locations(id,name,is_test) VALUES(loc,'Fixture recupero V2',test_room);
 IF master_left IS NOT NULL THEN
  mid:=pg_temp.rid(n+2000);
  INSERT INTO public.master_v2_sessions(id,location_id,tipo,titolo,master_user,stato,created_at) VALUES(mid,loc,'duello','Fixture QA',u,'in_corso',start_time);
  INSERT INTO public.master_v2_participants(session_id,character_id,user_id_snapshot,joined_at,left_at,engagement_state) VALUES(mid,cid,u,start_time,master_left,'concluso');
 END IF;
 INSERT INTO public.combat_v2_sessions(id,source_kind,master_session_id,location_id,state,created_at,closed_at)
 VALUES(sid,CASE WHEN mid IS NULL THEN 'ordinary' ELSE 'master' END,mid,loc,CASE WHEN end_time IS NULL THEN 'in_corso' ELSE 'chiuso' END,start_time,end_time);
 INSERT INTO public.combat_v2_actors(session_id,actor_kind,character_id,controller_user,team_key,state,initiative_snapshot,mechanics_snapshot,created_at)
 VALUES(sid,'pg',cid,u,'A',actor_state,1,'{}',start_time);
 RETURN sid;
END $f$;
CREATE FUNCTION pg_temp.window() RETURNS jsonb LANGUAGE sql AS $f$
 SELECT clan_aburame_private.recovery_window(pg_temp.charid(),'2026-01-01 00:00+00','2026-01-02 00:00+00')
$f$;

DO $case$
DECLARE a jsonb;sid uuid;err text;invalid_rejected boolean:=false;
BEGIN
 BEGIN
a:=pg_temp.window();ASSERT a->>'eligible'='true' AND (a->>'rest_seconds')::numeric=86400;
 RAISE EXCEPTION 'qa_case_rollback' USING ERRCODE='ZQ001';
 EXCEPTION WHEN SQLSTATE 'ZQ001' THEN INSERT INTO recovery_results VALUES('W01',true,NULL);
 WHEN OTHERS OR ASSERT_FAILURE THEN GET STACKED DIAGNOSTICS err=MESSAGE_TEXT; INSERT INTO recovery_results VALUES('W01',false,err); END;
END $case$;

DO $case$
DECLARE a jsonb;sid uuid;err text;invalid_rejected boolean:=false;
BEGIN
 BEGIN
PERFORM pg_temp.legacy(1,'2026-01-01 00:00+00','2026-01-01 06:00+00');PERFORM pg_temp.legacy(2,'2026-01-01 08:00+00','2026-01-01 10:00+00','partecipante');a:=pg_temp.window();ASSERT (a->>'combat_seconds')::numeric=21600 AND (a->>'rest_seconds')::numeric=64800;
 RAISE EXCEPTION 'qa_case_rollback' USING ERRCODE='ZQ001';
 EXCEPTION WHEN SQLSTATE 'ZQ001' THEN INSERT INTO recovery_results VALUES('W02',true,NULL);
 WHEN OTHERS OR ASSERT_FAILURE THEN GET STACKED DIAGNOSTICS err=MESSAGE_TEXT; INSERT INTO recovery_results VALUES('W02',false,err); END;
END $case$;

DO $case$
DECLARE a jsonb;sid uuid;err text;invalid_rejected boolean:=false;
BEGIN
 BEGIN
PERFORM pg_temp.legacy(1,'2026-01-01 04:00+00','2026-01-01 10:00+00');PERFORM pg_temp.v2(2,'2026-01-01 02:00+00','2026-01-01 08:00+00');a:=pg_temp.window();ASSERT (a->>'combat_seconds')::numeric=28800 AND (a->>'rest_seconds')::numeric=57600;
 RAISE EXCEPTION 'qa_case_rollback' USING ERRCODE='ZQ001';
 EXCEPTION WHEN SQLSTATE 'ZQ001' THEN INSERT INTO recovery_results VALUES('W03',true,NULL);
 WHEN OTHERS OR ASSERT_FAILURE THEN GET STACKED DIAGNOSTICS err=MESSAGE_TEXT; INSERT INTO recovery_results VALUES('W03',false,err); END;
END $case$;

DO $case$
DECLARE a jsonb;sid uuid;err text;invalid_rejected boolean:=false;
BEGIN
 BEGIN
sid:=pg_temp.v2(1,'2026-01-01 02:00+00',NULL);a:=pg_temp.window();ASSERT a->>'currently_busy'='true' AND a->>'eligible'='false' AND a->>'rest_seconds' IS NULL;UPDATE public.combat_v2_sessions SET state='sospeso' WHERE id=sid;a:=pg_temp.window();ASSERT a->>'currently_busy'='true';
 RAISE EXCEPTION 'qa_case_rollback' USING ERRCODE='ZQ001';
 EXCEPTION WHEN SQLSTATE 'ZQ001' THEN INSERT INTO recovery_results VALUES('W04',true,NULL);
 WHEN OTHERS OR ASSERT_FAILURE THEN GET STACKED DIAGNOSTICS err=MESSAGE_TEXT; INSERT INTO recovery_results VALUES('W04',false,err); END;
END $case$;

DO $case$
DECLARE a jsonb;sid uuid;err text;invalid_rejected boolean:=false;
BEGIN
 BEGIN
PERFORM pg_temp.v2(2,'2026-01-01 03:00+00','2026-01-01 08:00+00',true);PERFORM pg_temp.v2(1,'2026-01-01 02:00+00',NULL,true);a:=pg_temp.window();ASSERT a->>'eligible'='true' AND (a->>'combat_seconds')::numeric=0 AND (a->>'rest_seconds')::numeric=86400;
 RAISE EXCEPTION 'qa_case_rollback' USING ERRCODE='ZQ001';
 EXCEPTION WHEN SQLSTATE 'ZQ001' THEN INSERT INTO recovery_results VALUES('W05',true,NULL);
 WHEN OTHERS OR ASSERT_FAILURE THEN GET STACKED DIAGNOSTICS err=MESSAGE_TEXT; INSERT INTO recovery_results VALUES('W05',false,err); END;
END $case$;

DO $case$
DECLARE a jsonb;sid uuid;err text;invalid_rejected boolean:=false;
BEGIN
 BEGIN
PERFORM pg_temp.v2(1,'2026-01-01 02:00+00','2026-01-01 08:00+00',false,'fuori');a:=pg_temp.window();ASSERT a->>'history_complete'='false' AND a->>'eligible'='false' AND a->>'rest_seconds' IS NULL;
 RAISE EXCEPTION 'qa_case_rollback' USING ERRCODE='ZQ001';
 EXCEPTION WHEN SQLSTATE 'ZQ001' THEN INSERT INTO recovery_results VALUES('W06',true,NULL);
 WHEN OTHERS OR ASSERT_FAILURE THEN GET STACKED DIAGNOSTICS err=MESSAGE_TEXT; INSERT INTO recovery_results VALUES('W06',false,err); END;
END $case$;

DO $case$
DECLARE a jsonb;sid uuid;err text;invalid_rejected boolean:=false;
BEGIN
 BEGIN
PERFORM pg_temp.v2(1,'2026-01-01 02:00+00',NULL,false,'ritirato','2026-01-01 06:00+00');a:=pg_temp.window();ASSERT a->>'history_complete'='true' AND a->>'currently_busy'='false' AND (a->>'combat_seconds')::numeric=14400 AND (a->>'rest_seconds')::numeric=72000;
 RAISE EXCEPTION 'qa_case_rollback' USING ERRCODE='ZQ001';
 EXCEPTION WHEN SQLSTATE 'ZQ001' THEN INSERT INTO recovery_results VALUES('W07',true,NULL);
 WHEN OTHERS OR ASSERT_FAILURE THEN GET STACKED DIAGNOSTICS err=MESSAGE_TEXT; INSERT INTO recovery_results VALUES('W07',false,err); END;
END $case$;

DO $case$
DECLARE a jsonb;sid uuid;err text;invalid_rejected boolean:=false;
BEGIN
 BEGIN
PERFORM pg_temp.v2(1,'2025-12-31 22:00+00','2026-01-01 02:00+00');PERFORM pg_temp.v2(2,'2026-01-01 22:00+00','2026-01-02 02:00+00');a:=pg_temp.window();ASSERT (a->>'combat_seconds')::numeric=14400;
BEGIN PERFORM clan_aburame_private.recovery_window(pg_temp.charid(),'2026-01-02','2026-01-01');EXCEPTION WHEN SQLSTATE '22023' THEN invalid_rejected:=true;END;ASSERT invalid_rejected;
ASSERT NOT has_function_privilege('anon','clan_aburame_private.recovery_window(uuid,timestamptz,timestamptz)','EXECUTE');
ASSERT NOT has_function_privilege('authenticated','clan_aburame_private.recovery_window(uuid,timestamptz,timestamptz)','EXECUTE');
ASSERT NOT has_function_privilege('service_role','clan_aburame_private.recovery_window(uuid,timestamptz,timestamptz)','EXECUTE');
ASSERT (SELECT seal FROM recovery_pg_before)=(SELECT md5(coalesce(string_agg(to_jsonb(c)::text,'' ORDER BY id),'')) FROM public.characters c);
 RAISE EXCEPTION 'qa_case_rollback' USING ERRCODE='ZQ001';
 EXCEPTION WHEN SQLSTATE 'ZQ001' THEN INSERT INTO recovery_results VALUES('W08',true,NULL);
 WHEN OTHERS OR ASSERT_FAILURE THEN GET STACKED DIAGNOSTICS err=MESSAGE_TEXT; INSERT INTO recovery_results VALUES('W08',false,err); END;
END $case$;
SELECT jsonb_build_object('groups',count(*),'passed',count(*) FILTER(WHERE passed),'results',jsonb_agg(to_jsonb(r) ORDER BY case_id)) FROM recovery_results r;
