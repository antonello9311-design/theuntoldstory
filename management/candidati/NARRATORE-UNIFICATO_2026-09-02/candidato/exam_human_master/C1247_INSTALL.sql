-- C1247 source-only; nessuna apertura missione/provider/config.
BEGIN;
SET LOCAL lock_timeout='5s';
SET LOCAL statement_timeout='30s';
DO $c1247_cas$
DECLARE wanted jsonb;actual jsonb;
BEGIN
 FOR wanted IN SELECT value FROM jsonb_array_elements($pins$[{"oid":50737,"signature":"mission_creation_owner.human_terminal_guard(uuid,text)","source_md5":"9bd0a1a992d47459a7cec39dc4b3372f","ddl_md5":"a58fc2dd246741c087f305a785e672c1","acl":"{postgres=X/postgres}","config":["search_path=\"\""],"secdef":true,"owner":"postgres"},{"oid":31345,"signature":"public.master_v2_close_human_ai_core(uuid,text,text,boolean,bigint,uuid)","source_md5":"7b96ededb7745964eaba4e004caa07fb","ddl_md5":"b5922c9f4dc490bd4bc3a7611800b96a","acl":"{postgres=X/postgres}","config":["search_path=\"\""],"secdef":true,"owner":"postgres"},{"oid":276565,"signature":"mission_public_owner.human_resource_scope_v1(uuid,uuid,boolean)","source_md5":"a0f6667a0040f469ee88af8cff421157","ddl_md5":"9c91e472863ed0aeef315ac0c4442c4d","acl":"{postgres=X/postgres}","config":["search_path=\"\""],"secdef":true,"owner":"postgres"},{"oid":276557,"signature":"mission_public_owner.human_session_allowed_v1(uuid)","source_md5":"2c7fd64ec85fbbe088ece645c72c4be0","ddl_md5":"17c0ebed78afecc80ae54dcb88cb1737","acl":"{postgres=X/postgres}","config":["search_path=\"\""],"secdef":true,"owner":"postgres"},{"oid":109114,"signature":"public.mission_human_combat_close_peaceful_v1(uuid,bigint,text,text,uuid)","source_md5":"778898a2daa7c36c65d9f9cb6562df6a","ddl_md5":"b12c95183ec9b9fd848409bfabb7000b","acl":"{postgres=X/postgres,authenticated=X/postgres}","config":["search_path=\"\""],"secdef":true,"owner":"postgres"},{"oid":40974,"signature":"mission_ai_board_owner.staff_only()","source_md5":"e9eb8c959bad86a2a4b265ca0e4800a0","ddl_md5":"005295a0e0bbd57100039b2cb6b85b66","acl":"{postgres=X/postgres}","config":["search_path=\"\""],"secdef":true,"owner":"postgres"},{"oid":109102,"signature":"mission_creation_owner.human_peaceful_route(uuid,bigint)","source_md5":"0dcabc253755cc2d4ec219e4facbbe38","ddl_md5":"cd3a15d84ae60dd4e57c51f7aba1ed45","acl":"{postgres=X/postgres}","config":["search_path=\"\""],"secdef":true,"owner":"postgres"},{"oid":50691,"signature":"mission_creation_owner.human_assert(uuid)","source_md5":"1ce886cdc79e7119ec47b59f52185c32","ddl_md5":"64240b718db9c55cb6039a8dce4d6c1b","acl":"{postgres=X/postgres}","config":["search_path=\"\""],"secdef":true,"owner":"postgres"},{"oid":50779,"signature":"mission_creation_owner.human_apply_authority(uuid,uuid,bigint,bigint,text,text,uuid,text,uuid)","source_md5":"7a03f569ae1d9c49cc1b5fed123eb206","ddl_md5":"c8b9c1cc129ba48b377d7cbf42e88dc6","acl":"{postgres=X/postgres}","config":["search_path=\"\""],"secdef":true,"owner":"postgres"},{"oid":276529,"signature":"mission_public_owner.human_fato_scope_allowed_v2(uuid)","source_md5":"c9f378ec6523f9d035435fa2fb353e34","ddl_md5":"29cfaef346e41e8829db31ba9ae9e483","acl":"{postgres=X/postgres}","config":["search_path=\"\""],"secdef":true,"owner":"postgres"},{"oid":50702,"signature":"public.mission_human_phase_state_v1(uuid)","source_md5":"0bda32f1607eb10808df90b042f5473a","ddl_md5":"a88dd968eb57c4c1419376546f143db7","acl":"{postgres=X/postgres,authenticated=X/postgres}","config":["search_path=\"\""],"secdef":true,"owner":"postgres"}]$pins$::jsonb) LOOP
  SELECT jsonb_build_object('oid',p.oid::integer,'signature',wanted->>'signature',
   'source_md5',md5(p.prosrc),'ddl_md5',md5(pg_get_functiondef(p.oid)),
   'acl',p.proacl::text,'config',to_jsonb(p.proconfig),'secdef',p.prosecdef,'owner',pg_get_userbyid(p.proowner)) INTO actual
   FROM pg_proc p WHERE p.oid=to_regprocedure(wanted->>'signature') AND p.prokind='f';
  IF actual IS DISTINCT FROM wanted THEN RAISE EXCEPTION 'C1247_PRE_DRIFT %',wanted->>'signature'; END IF;
 END LOOP;
END $c1247_cas$;
CREATE OR REPLACE FUNCTION mission_creation_owner.human_peaceful_route(p_session uuid, p_run_version bigint)
 RETURNS jsonb
 LANGUAGE plpgsql
 STABLE SECURITY DEFINER
 SET search_path TO ''
AS $function$
declare r public.mission_run_state;h mission_creation_owner.human_encounters;
 s public.combat_v2_sessions;rr public.combat_v2_rounds;route jsonb;cnt int;
begin
 select * into r from public.mission_run_state where master_session_id=p_session and control_version=p_run_version and run_phase='in_corso';
 if not found then return null;end if;
 -- Prima del collaudo la nuova via è riservata alla Staff Test Room nativa.
 if not exists(select 1 from public.master_v2_sessions m
   join public.locations l on l.id=m.location_id
   where m.id=p_session and l.id='0b85f354-9cdb-47e1-baf9-3d266bb7e06b'::uuid
     and l.is_test and exists(select 1 from mission_generic_owner.simulation_sources src
       where src.carrier_mission_id=m.mission_id))
   and not exists(select 1 from public.master_v2_sessions ordinary_master
   join public.locations ordinary_location on ordinary_location.id=ordinary_master.location_id
   where ordinary_master.id=p_session and ordinary_master.owner_kind='human'
    and ordinary_master.master_user=auth.uid() and public.master_v2_is_master(auth.uid())
    and ordinary_master.mission_id is distinct from 'db1588ae-50f2-4c0e-9028-0b94155d94b1'::uuid
    and ordinary_location.is_active and not ordinary_location.is_test and not ordinary_location.is_exam_room
    and mission_creation_owner.is_human(p_session)
    and mission_creation_owner.human_simulated(p_session) is false
    and mission_public_owner.human_session_allowed_v1(p_session) is true)
 then return null;end if;
 select * into h from mission_creation_owner.human_encounters where master_session_id=p_session and run_control_version=p_run_version and step_key=r.current_step_key;
 if not found then return null;end if;
 select * into s from public.combat_v2_sessions where id=h.encounter_id and master_session_id=p_session and state='in_corso' and closed_at is null;
 if not found then return null;end if;
 if not exists(select 1 from public.locations staff_location
   join public.master_v2_sessions staff_master on staff_master.location_id=staff_location.id
   where staff_master.id=p_session and staff_location.id='0b85f354-9cdb-47e1-baf9-3d266bb7e06b'::uuid and staff_location.is_test)
  and (mission_public_owner.human_resource_scope_v1(p_session,s.id,false) is not true
   or combat_panel_private.uses_simulated_pools(s.id) is not false
   or public.combat_v2_values_written(s.id) is distinct from s.lesiva)
 then return null;end if;
 select * into rr from public.combat_v2_rounds where session_id=s.id order by round_no desc limit 1;
 -- Una difesa o una risoluzione avviata non viene mai assorbita dalla chiusura.
 if not found or rr.state<>'raccolta_azioni'
  or exists(select 1 from public.combat_v2_rounds prior where prior.session_id=s.id and prior.id<>rr.id and prior.state<>'narrato')
  or exists(select 1 from public.combat_v2_declarations d where d.round_id=rr.id and d.kind not in('utilita','movimento','passa'))
 then return null;end if;
 select count(*),min(x.value::text)::jsonb into cnt,route
 from jsonb_array_elements(mission_generic_owner.scene(p_session,r.current_step_key)->'triggers') x
 join public.mission_plan_transitions tr on tr.plan_version_id=r.plan_version_id and tr.transition_key=x.value->>'transition_key' and tr.from_step_key=r.current_step_key
 join public.mission_plan_steps next_step on next_step.plan_version_id=r.plan_version_id and next_step.step_key=tr.to_step_key and next_step.kind='narrative'
 where x.value->>'source_kind'='combat_terminal' and x.value->>'combat_outcome' in('peaceful','any') and x.value->>'encounter_key'=h.encounter_key;
 if cnt<>1 then return null;end if;
 return route;
end $function$
;
CREATE OR REPLACE FUNCTION public.mission_human_combat_close_peaceful_v1(p_session uuid, p_expected_version bigint, p_trigger_key text, p_body text, p_request uuid)
 RETURNS jsonb
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO ''
AS $function$
declare m public.master_v2_sessions;r public.mission_run_state;h mission_creation_owner.human_encounters;
 s public.combat_v2_sessions;rr public.combat_v2_rounds;old mission_creation_owner.human_peaceful_closures;route jsonb;tr public.mission_plan_transitions;
 body text:=btrim(coalesce(p_body,''));fp text;event jsonb;event_id uuid;event_sha text;message_id uuid;res jsonb;
begin
 perform mission_creation_owner.human_assert(p_session);
 if p_request is null or p_expected_version is null or p_trigger_key is null or char_length(body) not between 20 and 5000
 then raise exception 'HPC_INPUT_INVALID' using errcode='22023';end if;
 fp:=mission_internal.fingerprint(jsonb_build_object('session',p_session,'expected',p_expected_version,'trigger',p_trigger_key,'body',body,'request',p_request));
 perform public.master_v2_lock_scope(p_session);
 select * into strict m from public.master_v2_sessions where id=p_session for update;
 if (not exists(select 1 from public.locations l where l.id=m.location_id
   and l.id='0b85f354-9cdb-47e1-baf9-3d266bb7e06b'::uuid and l.is_test)
   or not exists(select 1 from mission_generic_owner.simulation_sources src
     where src.carrier_mission_id=m.mission_id))
   and not exists(select 1 from public.master_v2_sessions ordinary_master
   join public.locations ordinary_location on ordinary_location.id=ordinary_master.location_id
   where ordinary_master.id=p_session and ordinary_master.owner_kind='human'
    and ordinary_master.master_user=auth.uid() and public.master_v2_is_master(auth.uid())
    and ordinary_master.mission_id is distinct from 'db1588ae-50f2-4c0e-9028-0b94155d94b1'::uuid
    and ordinary_location.is_active and not ordinary_location.is_test and not ordinary_location.is_exam_room
    and mission_creation_owner.is_human(p_session)
    and mission_creation_owner.human_simulated(p_session) is false
    and mission_public_owner.human_session_allowed_v1(p_session) is true)
 then raise exception 'HPC_STAFF_ONLY' using errcode='42501';end if;
 select * into old from mission_creation_owner.human_peaceful_closures where master_session_id=p_session and request_key=p_request;
 if found then
  if old.actor_user is distinct from auth.uid() or old.request_fingerprint<>fp then raise exception 'HPC_REPLAY_CONFLICT' using errcode='40001';end if;
  return old.result;
 end if;
 select * into strict r from public.mission_run_state where master_session_id=p_session for update;
 if m.stato<>'in_corso' or r.run_phase<>'in_corso' or r.control_version<>p_expected_version then raise exception 'HPC_VERSION_CONFLICT' using errcode='40001';end if;
 route:=mission_creation_owner.human_peaceful_route(p_session,r.control_version);
 if route is null or route->>'trigger_key' is distinct from p_trigger_key then raise exception 'HPC_ROUTE_NOT_AVAILABLE' using errcode='55000';end if;
 select * into strict h from mission_creation_owner.human_encounters where master_session_id=p_session and run_control_version=r.control_version and encounter_key=route->>'encounter_key';
 select * into strict s from public.combat_v2_sessions where id=h.encounter_id and master_session_id=p_session and state='in_corso' for update;
 -- C1247: la policy ordinaria viene verificata con encounter e arena ancora aperti.
 if not exists(select 1 from public.locations l where l.id=m.location_id
   and l.id='0b85f354-9cdb-47e1-baf9-3d266bb7e06b'::uuid and l.is_test)
  and (mission_public_owner.human_resource_scope_v1(p_session,s.id,false) is not true
   or combat_panel_private.uses_simulated_pools(s.id) is not false
   or public.combat_v2_values_written(s.id) is distinct from s.lesiva)
 then raise exception 'HPC_RESOURCE_SCOPE' using errcode='42501';end if;
 select * into strict rr from public.combat_v2_rounds where session_id=s.id order by round_no desc limit 1 for update;
 -- Rivalutare dopo il lock: nessun attacco/difesa o resolver concorrente.
 if mission_creation_owner.human_peaceful_route(p_session,r.control_version) is null then raise exception 'HPC_COMBAT_CHANGED' using errcode='40001';end if;
 select * into strict tr from public.mission_plan_transitions where plan_version_id=r.plan_version_id and transition_key=route->>'transition_key' and from_step_key=r.current_step_key;
 event:=public.combat_v2_event_begin(p_session,mission_ai_service_owner.uuid5(p_request,'human-peaceful-event'),
  'mission_human_combat_close',jsonb_build_object('encounter',s.id,'run_version',r.control_version,'outcome','peaceful','trigger',p_trigger_key),m.control_version);
 event_id:=(event->>'event_id')::uuid;
 if event_id is null then raise exception 'HPC_EVENT_MISSING';end if;
 message_id:=public.post_fato_manual(m.location_id,body);
 update public.combat_v2_sessions set state='chiuso',closed_at=clock_timestamp() where id=s.id and state='in_corso';
 if not found then raise exception 'HPC_COMBAT_CHANGED' using errcode='40001';end if;
 perform public.combat_v2_event_complete(event_id,public.combat_v2_envelope(p_request,jsonb_build_object(
  'encounter_id',s.id,'outcome','peaceful','fato_message_id',message_id,'step_key',r.current_step_key,'run_version',r.control_version)));
 select public.combat_v2_sha256(to_jsonb(x)) into strict event_sha from public.combat_v2_events x where x.id=event_id;
 res:=mission_creation_owner.human_apply_authority(p_session,p_request,m.control_version,r.control_version,
  p_trigger_key,'combat_terminal',event_id,event_sha,null);
 if res->>'step_key' is distinct from tr.to_step_key then
  -- La risposta potrebbe non proiettare step_key: verificare sempre lo stato autorevole.
  if not exists(select 1 from public.mission_run_state now_state where now_state.master_session_id=p_session and now_state.current_step_key=tr.to_step_key and now_state.control_version>r.control_version)
  then raise exception 'HPC_TRANSITION_NOT_COMMITTED';end if;
 end if;
 res:=res||jsonb_build_object('schema_version','mission-human-peaceful-close/1','master_session_id',p_session,
  'encounter_id',s.id,'fato_message_id',message_id,'combat_event_id',event_id,'outcome','peaceful','to_step_key',tr.to_step_key);
 insert into mission_creation_owner.human_peaceful_closures(encounter_id,master_session_id,request_key,actor_user,request_fingerprint,
  from_step_key,to_step_key,run_control_version,trigger_key,fato_message_id,combat_event_id,result)
 values(s.id,p_session,p_request,auth.uid(),fp,r.current_step_key,tr.to_step_key,r.control_version,p_trigger_key,message_id,event_id,res);
 return res;
end $function$
;
CREATE OR REPLACE FUNCTION public.master_v2_close_human_ai_core(p_session uuid, p_mission_outcome text, p_mission_note text, p_close_role boolean, p_expected_control_version bigint, p_request_key uuid)
 RETURNS jsonb
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO ''
AS $function$
declare v_uid uuid:=auth.uid(); v_m public.master_v2_sessions%rowtype; v_step public.master_v2_closure_steps%rowtype;
  v_event jsonb; v_event_id uuid; v_result jsonb; v_role uuid; v_done int;
begin
  if exists(select 1 from combat_consumer_private.narrative_authorities where master_session_id=p_session) then return combat_consumer_private.close_from_master(p_session,p_expected_control_version,p_request_key,jsonb_build_object('via','activity_close','outcome',p_mission_outcome,'reason',p_mission_note,'close_role',p_close_role,'expected',p_expected_control_version)); end if;
  perform mission_creation_owner.human_terminal_guard(p_session,p_mission_outcome);
  perform public.master_v2_lock_scope(p_session);
  select * into v_m from public.master_v2_sessions where id=p_session for update;
  if v_m.id is null then perform public.combat_v2_fail('sessione_inesistente','Sessione inesistente.',404,p_request_key,'{}'); end if;
  if v_m.master_user<>v_uid and not public.combat_v2_is_admin(v_uid) then perform public.combat_v2_fail('master_non_proprietario','Chiusura non consentita.',403,p_request_key,'{}'); end if;
  if v_m.control_version<>p_expected_control_version then perform public.combat_v2_fail('versione_controllo_obsoleta','Versione controllo obsoleta.',409,p_request_key,'{}'); end if;
  if v_m.tipo='quest' and v_m.mission_id is not null and p_mission_outcome not in ('successo','fallimento') then perform public.combat_v2_fail('missione_non_finalizzabile','Esito missione non valido.',422,p_request_key,'{}'); end if;
  v_event:=public.combat_v2_event_begin(p_session,p_request_key,'master_v2_close',jsonb_build_object('outcome',p_mission_outcome,'note',p_mission_note,'close_role',p_close_role,'expected',p_expected_control_version),p_expected_control_version);
  if (v_event->>'replay')::boolean then return v_event->'result'; end if; v_event_id:=(v_event->>'event_id')::uuid;
  if v_m.stato not in ('chiusura','chiusa') then update public.master_v2_sessions set stato='chiusura' where id=p_session; end if;
  select * into v_step from public.master_v2_closure_steps where session_id=p_session and state<>'completato' order by position limit 1 for update;
  if v_step.id is null then
    v_result:=public.combat_v2_envelope(p_request_key,jsonb_build_object('state','chiusa','completed_steps',(select count(*) from public.master_v2_closure_steps where session_id=p_session)));
    return public.combat_v2_event_complete(v_event_id,v_result);
  end if;
  update public.master_v2_closure_steps set state='in_corso',attempts=attempts+1,started_at=coalesce(started_at,clock_timestamp()),request_key=p_request_key where id=v_step.id;
  if v_step.step_name='encounter_resolved' then
    if exists(select 1 from public.combat_v2_sessions where master_session_id=p_session and state not in ('risolto','chiuso','annullato')) then perform public.combat_v2_fail('referto_non_completo','Encounter non terminale.',409,p_request_key,'{}'); end if;
  elsif v_step.step_name='final_report_published' then
    if exists(select 1 from public.combat_v2_sessions s join public.combat_v2_rounds r on r.session_id=s.id where s.master_session_id=p_session and r.state<>'narrato' and (r.state='raccolta_azioni' and s.state='chiuso' and s.closed_at is not null
 and not exists(select 1 from public.combat_v2_rounds later where later.session_id=s.id and later.round_no>r.round_no)
 and not exists(select 1 from public.combat_v2_rounds prior where prior.session_id=s.id and prior.round_no<r.round_no and prior.state<>'narrato')
 and not exists(select 1 from public.combat_v2_declarations d where d.round_id=r.id and d.kind not in('utilita','movimento','passa'))
 and exists(select 1 from mission_creation_owner.human_peaceful_closures hc
 join public.combat_v2_events e on e.id=hc.combat_event_id
 join public.master_v2_sessions pm on pm.id=hc.master_session_id
 join public.locations pl on pl.id=pm.location_id
 where hc.encounter_id=s.id and hc.master_session_id=p_session and hc.actor_user=pm.master_user
 and ((pl.id='0b85f354-9cdb-47e1-baf9-3d266bb7e06b'::uuid and pl.is_test
 and mission_creation_owner.human_simulated(p_session) is true)
 or (pl.is_active and not pl.is_test and not pl.is_exam_room
 and pm.owner_kind='human' and pm.master_user=auth.uid() and public.master_v2_is_master(auth.uid())
 and pm.mission_id is distinct from 'db1588ae-50f2-4c0e-9028-0b94155d94b1'::uuid
 and mission_creation_owner.is_human(p_session)
 and mission_creation_owner.human_simulated(p_session) is false
 and mission_public_owner.human_session_allowed_v1(p_session) is true
 and combat_panel_private.uses_simulated_pools(s.id) is false
 and public.combat_v2_values_written(s.id) is not distinct from s.lesiva
 and exists(select 1 from combat_panel_private.master_panel_sessions real_panel
   where real_panel.master_session_id=p_session and real_panel.location_id=pm.location_id
    and real_panel.policy_id='master_game_resources_v1')
 and exists(select 1 from mission_creation_owner.human_encounters original_encounter
   where original_encounter.master_session_id=p_session and original_encounter.encounter_id=s.id
    and original_encounter.step_key=hc.from_step_key
    and original_encounter.run_control_version=hc.run_control_version)
 and exists(select 1 from public.messages public_fato
   where public_fato.id=hc.fato_message_id and public_fato.location_id=pm.location_id
    and public_fato.kind='fato' and public_fato.character_id is null and public_fato.recipient_user is null)
 and e.request_key=mission_ai_service_owner.uuid5(hc.request_key,'human-peaceful-event')))
 and hc.result->>'schema_version'='mission-human-peaceful-close/1'
 and hc.result->>'master_session_id'=p_session::text and hc.result->>'encounter_id'=s.id::text
 and hc.result->>'outcome'='peaceful' and hc.result->>'fato_message_id'=hc.fato_message_id::text
 and hc.result->>'combat_event_id'=e.id::text
 and e.scope_id=p_session and e.operation_kind='mission_human_combat_close' and e.status='completata'
 and e.caller=hc.actor_user and e.completed_at is not null
 and e.result->>'ok'='true' and e.result->'data'->>'encounter_id'=s.id::text
 and e.result->'data'->>'outcome'='peaceful' and e.result->'data'->>'fato_message_id'=hc.fato_message_id::text)) is not true) then perform public.combat_v2_fail('referto_non_completo','Esiste un round non narrato.',409,p_request_key,'{}'); end if;
  elsif v_step.step_name='mission_run_terminalized' then
    perform mission_internal.close_from_master(
      p_session,p_request_key,p_expected_control_version,
      case when p_mission_outcome='successo' then 'success' else 'failure' end,
      encode(extensions.digest(coalesce(p_mission_note,''),'sha256'),'hex')
    );
  elsif v_step.step_name='mission_finalized' then
    if v_m.tipo='quest' and v_m.mission_id is not null and not mission_creation_owner.human_simulated(p_session) then
      if exists(select 1 from public.missions x where x.id=v_m.mission_id and x.status in ('aperta','programmata')) then
        perform public.missione_esito(v_m.mission_id,p_mission_outcome='successo',p_mission_note);
      elsif not exists(select 1 from public.missions x where x.id=v_m.mission_id and x.status=case when p_mission_outcome='successo' then 'completata' else 'fallita' end) then
        perform public.combat_v2_fail('missione_non_finalizzabile','Missione terminale con esito diverso.',409,p_request_key,'{}');
      end if;
    end if;
  elsif v_step.step_name='role_segment_finalized' then
    if p_close_role and not mission_creation_owner.human_simulated(p_session) then
      for v_role in select role_session_id from public.master_v2_mechanical_role_segments where master_session_id=p_session and closed_at is null order by segment_no loop
        perform public._role_finalize(v_role,'master_v2');
        update public.master_v2_mechanical_role_segments set closed_at=(select closed_at from public.role_sessions where id=v_role) where role_session_id=v_role;
      end loop;
    end if;
  elsif v_step.step_name='master_session_closed' then
    update public.combat_v2_sessions set state='chiuso',closed_at=coalesce(closed_at,clock_timestamp()) where master_session_id=p_session and state in ('risolto','annullato');
    PERFORM combat_effects_private.lifecycle_session_end(s.id) FROM public.combat_v2_sessions s WHERE s.master_session_id=p_session AND s.closed_at IS NOT NULL;
    update public.master_v2_participants set engagement_state='concluso',left_at=coalesce(left_at,clock_timestamp()) where session_id=p_session;
    update public.master_v2_sessions set stato='chiusa',closed_at=clock_timestamp(),close_reason='completata' where id=p_session;
  end if;
  update public.master_v2_closure_steps set state='completato',completed_at=clock_timestamp(),result=jsonb_build_object('ok',true) where id=v_step.id;
  select count(*) into v_done from public.master_v2_closure_steps where session_id=p_session and state='completato';
  if v_done=(select count(*) from public.master_v2_closure_steps where session_id=p_session) then
    v_result:=public.combat_v2_envelope(p_request_key,jsonb_build_object('state','chiusa','completed_steps',(select count(*) from public.master_v2_closure_steps where session_id=p_session)));
    return public.combat_v2_event_complete(v_event_id,v_result);
  end if;
  -- Evento volutamente in_corso: il retry con la stessa chiave avanza un solo passo atomico.
  return public.combat_v2_envelope(p_request_key,jsonb_build_object('state','chiusura','completed_steps',v_done,'next_retry_same_key',true));
end $function$
;
DO $c1247_cas$
DECLARE wanted jsonb;actual jsonb;
BEGIN
 FOR wanted IN SELECT value FROM jsonb_array_elements($pins$[{"oid":50737,"signature":"mission_creation_owner.human_terminal_guard(uuid,text)","source_md5":"9bd0a1a992d47459a7cec39dc4b3372f","ddl_md5":"a58fc2dd246741c087f305a785e672c1","acl":"{postgres=X/postgres}","config":["search_path=\"\""],"secdef":true,"owner":"postgres"},{"oid":31345,"signature":"public.master_v2_close_human_ai_core(uuid,text,text,boolean,bigint,uuid)","source_md5":"37eacc6563ad7b0b01604bf1c6829568","ddl_md5":"23ca18d227ba595038408ef094aed471","acl":"{postgres=X/postgres}","config":["search_path=\"\""],"secdef":true,"owner":"postgres"},{"oid":276565,"signature":"mission_public_owner.human_resource_scope_v1(uuid,uuid,boolean)","source_md5":"a0f6667a0040f469ee88af8cff421157","ddl_md5":"9c91e472863ed0aeef315ac0c4442c4d","acl":"{postgres=X/postgres}","config":["search_path=\"\""],"secdef":true,"owner":"postgres"},{"oid":276557,"signature":"mission_public_owner.human_session_allowed_v1(uuid)","source_md5":"2c7fd64ec85fbbe088ece645c72c4be0","ddl_md5":"17c0ebed78afecc80ae54dcb88cb1737","acl":"{postgres=X/postgres}","config":["search_path=\"\""],"secdef":true,"owner":"postgres"},{"oid":109114,"signature":"public.mission_human_combat_close_peaceful_v1(uuid,bigint,text,text,uuid)","source_md5":"b48e551c36ab107804fe7837ebf62a27","ddl_md5":"7c756b3d8d8ddc43e02b429424108bdb","acl":"{postgres=X/postgres,authenticated=X/postgres}","config":["search_path=\"\""],"secdef":true,"owner":"postgres"},{"oid":40974,"signature":"mission_ai_board_owner.staff_only()","source_md5":"e9eb8c959bad86a2a4b265ca0e4800a0","ddl_md5":"005295a0e0bbd57100039b2cb6b85b66","acl":"{postgres=X/postgres}","config":["search_path=\"\""],"secdef":true,"owner":"postgres"},{"oid":109102,"signature":"mission_creation_owner.human_peaceful_route(uuid,bigint)","source_md5":"c51239bfd9671f9aeaf44ca0c7dc3ece","ddl_md5":"c32f199a4d92cefb1b88d551434cc853","acl":"{postgres=X/postgres}","config":["search_path=\"\""],"secdef":true,"owner":"postgres"},{"oid":50691,"signature":"mission_creation_owner.human_assert(uuid)","source_md5":"1ce886cdc79e7119ec47b59f52185c32","ddl_md5":"64240b718db9c55cb6039a8dce4d6c1b","acl":"{postgres=X/postgres}","config":["search_path=\"\""],"secdef":true,"owner":"postgres"},{"oid":50779,"signature":"mission_creation_owner.human_apply_authority(uuid,uuid,bigint,bigint,text,text,uuid,text,uuid)","source_md5":"7a03f569ae1d9c49cc1b5fed123eb206","ddl_md5":"c8b9c1cc129ba48b377d7cbf42e88dc6","acl":"{postgres=X/postgres}","config":["search_path=\"\""],"secdef":true,"owner":"postgres"},{"oid":276529,"signature":"mission_public_owner.human_fato_scope_allowed_v2(uuid)","source_md5":"c9f378ec6523f9d035435fa2fb353e34","ddl_md5":"29cfaef346e41e8829db31ba9ae9e483","acl":"{postgres=X/postgres}","config":["search_path=\"\""],"secdef":true,"owner":"postgres"},{"oid":50702,"signature":"public.mission_human_phase_state_v1(uuid)","source_md5":"0bda32f1607eb10808df90b042f5473a","ddl_md5":"a88dd968eb57c4c1419376546f143db7","acl":"{postgres=X/postgres,authenticated=X/postgres}","config":["search_path=\"\""],"secdef":true,"owner":"postgres"}]$pins$::jsonb) LOOP
  SELECT jsonb_build_object('oid',p.oid::integer,'signature',wanted->>'signature',
   'source_md5',md5(p.prosrc),'ddl_md5',md5(pg_get_functiondef(p.oid)),
   'acl',p.proacl::text,'config',to_jsonb(p.proconfig),'secdef',p.prosecdef,'owner',pg_get_userbyid(p.proowner)) INTO actual
   FROM pg_proc p WHERE p.oid=to_regprocedure(wanted->>'signature') AND p.prokind='f';
  IF actual IS DISTINCT FROM wanted THEN RAISE EXCEPTION 'C1247_POST_DRIFT %',wanted->>'signature'; END IF;
 END LOOP;
END $c1247_cas$;
COMMIT;
