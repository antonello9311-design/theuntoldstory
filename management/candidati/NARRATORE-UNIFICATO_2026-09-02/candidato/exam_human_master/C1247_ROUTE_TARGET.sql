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
