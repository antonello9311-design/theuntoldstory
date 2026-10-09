BEGIN;
SET LOCAL lock_timeout='5s';
SET LOCAL statement_timeout='30s';
DO $patch$
DECLARE d text;s text; old constant text:=$old$where s.master_session_id=p_session and r.state<>'narrato'$old$; new constant text:=$new$where s.master_session_id=p_session and r.state<>'narrato' and (r.state='raccolta_azioni' and s.state='chiuso' and s.closed_at is not null
 and not exists(select 1 from public.combat_v2_rounds later where later.session_id=s.id and later.round_no>r.round_no)
 and not exists(select 1 from public.combat_v2_rounds prior where prior.session_id=s.id and prior.round_no<r.round_no and prior.state<>'narrato')
 and not exists(select 1 from public.combat_v2_declarations d where d.round_id=r.id and d.kind not in('utilita','movimento','passa'))
 and exists(select 1 from mission_creation_owner.human_peaceful_closures hc
 join public.combat_v2_events e on e.id=hc.combat_event_id
 join public.master_v2_sessions pm on pm.id=hc.master_session_id
 join public.locations pl on pl.id=pm.location_id
 where hc.encounter_id=s.id and hc.master_session_id=p_session and hc.actor_user=pm.master_user
 and pl.id='0b85f354-9cdb-47e1-baf9-3d266bb7e06b'::uuid and pl.is_test
 and mission_creation_owner.human_simulated(p_session) is true
 and hc.result->>'schema_version'='mission-human-peaceful-close/1'
 and hc.result->>'master_session_id'=p_session::text and hc.result->>'encounter_id'=s.id::text
 and hc.result->>'outcome'='peaceful' and hc.result->>'fato_message_id'=hc.fato_message_id::text
 and hc.result->>'combat_event_id'=e.id::text
 and e.scope_id=p_session and e.operation_kind='mission_human_combat_close' and e.status='completata'
 and e.caller=hc.actor_user and e.completed_at is not null
 and e.result->>'ok'='true' and e.result->'data'->>'encounter_id'=s.id::text
 and e.result->'data'->>'outcome'='peaceful' and e.result->'data'->>'fato_message_id'=hc.fato_message_id::text)) is not true$new$;
BEGIN
 PERFORM pg_advisory_xact_lock(hashtextextended('C1236_PEACEFUL_FINAL',0));
 SELECT pg_get_functiondef(oid),prosrc INTO STRICT d,s FROM pg_proc WHERE oid='public.master_v2_close_human_ai_core(uuid,text,text,boolean,bigint,uuid)'::regprocedure AND pg_get_userbyid(proowner)='postgres' and prosecdef and provolatile='v' and proconfig=ARRAY['search_path=""']::text[] and proacl::text='{postgres=X/postgres}';
 IF md5(d)<>'9cbcac7562fbab0b26f354a68d3d6bbe' OR md5(s)<>'fdb4f7815e0b4111bd447fdb875f8f3a' THEN RAISE EXCEPTION 'C1236_FINAL_BASELINE_DRIFT';END IF;
 IF md5(pg_get_functiondef('mission_creation_owner.human_simulated(uuid)'::regprocedure))<>'25674d09fe7cac92bfdea65908db6093' THEN RAISE EXCEPTION 'C1236_FINAL_DEPENDENCY_DRIFT';END IF;
 IF (length(s)-length(replace(s,old,'')))/length(old)<>1 THEN RAISE EXCEPTION 'C1236_FINAL_ANCHOR_DRIFT';END IF;
 IF md5(replace(s,old,new))<>'7b96ededb7745964eaba4e004caa07fb' THEN RAISE EXCEPTION 'C1236_FINAL_BODY_DRIFT';END IF;
 EXECUTE replace(d,old,new);
 IF NOT EXISTS(SELECT 1 FROM pg_proc WHERE oid='public.master_v2_close_human_ai_core(uuid,text,text,boolean,bigint,uuid)'::regprocedure AND md5(prosrc)='7b96ededb7745964eaba4e004caa07fb' AND pg_get_userbyid(proowner)='postgres' and prosecdef and provolatile='v' and proconfig=ARRAY['search_path=""']::text[] and proacl::text='{postgres=X/postgres}') THEN RAISE EXCEPTION 'C1236_FINAL_POSTFLIGHT';END IF;
END $patch$;
COMMIT;
