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
