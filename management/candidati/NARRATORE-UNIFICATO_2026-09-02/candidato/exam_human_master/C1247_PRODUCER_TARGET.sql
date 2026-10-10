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
