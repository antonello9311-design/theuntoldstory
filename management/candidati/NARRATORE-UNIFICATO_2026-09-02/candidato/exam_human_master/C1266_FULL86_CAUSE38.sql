-- Fonte verificata Full86; NON installer autonomo. Non eseguire senza composizione Root, guardie e review del materiale integrato.
CREATE OR REPLACE FUNCTION mission_generic_owner.finish_scope(p_session uuid, p_cap uuid, p_outcome text)
 RETURNS boolean
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO ''
AS $function$
declare m public.master_v2_sessions;r public.mission_run_state;b mission_generic_owner.board_starts;
 settings jsonb;sim boolean;principals uuid[];permit56 boolean:=false;receipt56 mission_generic_owner.staff_finish_receipts_v1;proof56 jsonb;
begin
 perform mission_ai_service_owner.service_only();
 perform mission_generic_owner.assert_runtime(p_session);
 perform mission_ai_service_owner.assert_capability(p_session,p_cap);
 select * into strict m from public.master_v2_sessions where id=p_session for update;
 select * into strict r from public.mission_run_state where master_session_id=p_session for update;
 select * into strict b from mission_generic_owner.board_starts where master_session_id=p_session and capability_id=p_cap;
 IF EXISTS(SELECT 1 FROM mission_narrative_internal.scene_runtime_v1 WHERE master_session_id=p_session AND is_active) THEN
  SELECT * INTO receipt56 FROM mission_generic_owner.staff_finish_receipts_v1 WHERE master_session_id=p_session
   AND state='preparing' AND transaction_id=txid_current();
  IF receipt56.request_key IS NOT NULL THEN
   proof56:=mission_narrative_internal.scene_finish_proof_v1(p_session,receipt56.actor_user_id);
   permit56:=proof56->'can_finish'='true'::jsonb
    AND receipt56.source_revision=proof56->>'source_revision'
    AND receipt56.publication_id=(proof56->>'publication_id')::uuid
    AND receipt56.request_key=(proof56->>'request_key')::uuid
    AND receipt56.history_proof=proof56->'history_items'
    AND receipt56.history_proof_sha256=public.combat_v2_sha256(proof56->'history_items');
  END IF;
 END IF;
 settings:=mission_generic_owner.run_plan_settings(p_session);
 if m.owner_kind<>'ai_service' or m.master_user is not null or m.mission_id is null or m.suspended_at is not null
 or m.stato not in('in_corso','chiusura','chiusa') or r.run_phase not in('in_corso','conclusa','fallita')
 or (r.run_phase<>'in_corso' and r.run_phase<>(case when p_outcome='success' then 'conclusa' else 'fallita' end))
 or b.state<>'published' or b.snapshot_sha256<>mission_internal.fingerprint(b.snapshot)
 or (select count(*) from jsonb_array_elements(settings->'terminal_steps') x
   where x->>'step_key'=r.current_step_key and x->>'outcome'=p_outcome)<>1
 or exists(select 1 from public.mission_run_outbox where master_session_id=p_session and state='pending')
 or (exists(select 1 from mission_generic_owner.work_items where master_session_id=p_session and state<>'completed') AND (CASE WHEN EXISTS(SELECT 1 FROM mission_narrative_internal.scene_runtime_v1 WHERE master_session_id=p_session AND is_active) THEN permit56 ELSE mission_generic_owner.staff_finish_permit_v1(p_session) END) IS DISTINCT FROM true)
 or exists(select 1 from public.combat_v2_sessions where master_session_id=p_session and (state<>'chiuso' or closed_at is null))
 or exists(select 1 from public.combat_v2_sessions s join public.combat_v2_rounds rr on rr.session_id=s.id
  where s.master_session_id=p_session and rr.state<>'narrato'
   AND NOT ((permit56 IS TRUE AND s.state='chiuso' AND s.closed_at IS NOT NULL
    AND rr.state='raccolta_azioni' AND rr.freeze_at IS NULL AND rr.report_id IS NULL
    AND rr.resolved_at IS NULL AND rr.narrated_at IS NULL
    AND NOT EXISTS(SELECT 1 FROM public.combat_v2_rounds later38 WHERE later38.session_id=s.id AND later38.round_no>rr.round_no)
    AND NOT EXISTS(SELECT 1 FROM public.combat_v2_declarations decl38 WHERE decl38.round_id=rr.id)
    AND NOT EXISTS(SELECT 1 FROM public.combat_v2_round_reports report38 WHERE report38.round_id=rr.id)
    AND EXISTS(
     SELECT 1 FROM mission_narrative_internal.scene_sources_v1 src38
     JOIN mission_narrative_internal.scene_runtime_v1 scene38 ON scene38.id=src38.scene_id AND scene38.master_session_id=p_session AND scene38.is_active
     JOIN mission_generic_owner.work_items work38 ON work38.id=src38.work_id AND work38.master_session_id=p_session
      AND work38.state='completed' AND work38.kind='narration'
      AND work38.message_id=src38.published_message_id
     JOIN public.combat_v2_events close38 ON close38.id::text=src38.technical_receipt->>'terminal_event_id'
      AND close38.scope_id=p_session AND close38.operation_kind='mission_generic_combat_close_peaceful' AND close38.status='completata'
     WHERE src38.request_kind='combat_peaceful'
      AND src38.technical_receipt->>'schema_version'='mission-native-peaceful-publication/1'
      AND src38.technical_receipt->>'unused_successor_round_id'=rr.id::text
      AND src38.technical_receipt->>'message_id'=work38.message_id::text
      AND src38.technical_request->'close_eligible'='true'::jsonb
      AND close38.result#>>'{data,state}'='chiuso'
      AND close38.result#>>'{data,publication_message_id}'=work38.message_id::text
      AND close38.result#>>'{data,closure_kind}'='peaceful'
      AND close38.result#>>'{data,encounter_id}'=s.id::text
      AND close38.result#>>'{data,master_session_id}'=p_session::text
      AND close38.result#>>'{data,unused_successor_round_id}'=rr.id::text)) IS TRUE))
 then raise exception 'MGP_FINISH_AUTHORITY' using errcode='42501';end if;
 -- Il Fato conclusivo è quello della visita terminale oppure della transizione
 -- terminale pubblicata insieme al suo evento autorevole nello stesso batch.
 if not exists(select 1 from mission_generic_owner.work_items w where w.master_session_id=p_session
 and w.kind='narration' and w.state='completed' and w.step_key=r.current_step_key
 and w.run_control_version=case when r.run_phase='in_corso' then r.control_version else r.control_version-1 end
 and w.message_id is not null)
 and not exists(
   select 1 from public.mission_run_events ev
   join public.mission_run_publications pub on pub.event_id=ev.id
     and pub.master_session_id=ev.master_session_id and pub.status='committed'
     and pub.source='model' and pub.expected_step_key=ev.step_after
     and pub.expected_event_version_after=ev.version_after
     and pub.expected_run_control_version=ev.version_after
     and pub.context_fingerprint=ev.context_fingerprint
   join public.mission_run_messages rm on rm.publication_id=pub.id
     and rm.body_sha256=pub.body_sha256
   join public.messages msg on msg.id=rm.message_id and msg.kind='fato'
     and msg.location_id=m.location_id
     and encode(extensions.digest(convert_to(msg.body,'UTF8'),'sha256'),'hex')=rm.body_sha256
   join mission_generic_owner.work_items w on w.message_id=msg.id
     and w.master_session_id=ev.master_session_id
     and w.kind='narration' and w.state='completed'
     and w.step_key=ev.step_before and w.run_control_version=ev.version_before
   join mission_generic_owner.unified_batches ub on ub.writer_work_id=w.id
     and ub.master_session_id=ev.master_session_id and ub.state='published'
     and ub.message_id=msg.id
   where ev.master_session_id=p_session and ev.operation_kind='transition'
     and ev.status='committed' and ev.step_after=r.current_step_key
     and ev.version_after=case when r.run_phase='in_corso' then r.control_version else r.control_version-1 end
     and ev.plan_version_id=r.plan_version_id
     and (
       (ub.step_key=ev.step_after and ub.run_control_version=ev.version_after
         and ub.route->>'event_id'=ev.id::text)
       or
       (ub.composition_kind='combat_exit' and ub.step_key=ev.step_before
         and ub.run_control_version=ev.version_before
         and ub.route->>'to_step_key'=ev.step_after
         and ub.route->>'transition_key'=ev.transition_key)
     )
 )
 then raise exception 'MGP_FINISH_NARRATION_BARRIER';end if;
 select is_test into strict sim from public.locations where id=m.location_id and is_active;
 if b.simulation is distinct from sim then raise exception 'MGP_FINISH_SIMULATION_DRIFT';end if;
 if sim then
  select array_agg(distinct p.user_id_snapshot) into principals from public.master_v2_participants p
  join public.characters c on c.id=p.character_id and c.user_id=p.user_id_snapshot where p.session_id=p_session;
  if m.location_id<>'0b85f354-9cdb-47e1-baf9-3d266bb7e06b'::uuid
  or coalesce(cardinality(principals),0)=0 or combat_consumer_private.staff_test_allowed(m.location_id,principals,false) is distinct from true
  or not exists(select 1 from mission_generic_owner.simulation_sources x where x.carrier_mission_id=m.mission_id
   and x.source_sha256~'^[0-9a-f]{64}$')
  then raise exception 'MGP_FINISH_PROTECTED_SOURCE' using errcode='42501';end if;
 else
  if exists(select 1 from mission_generic_owner.simulation_sources where carrier_mission_id=m.mission_id)
  then raise exception 'MGP_FINISH_CARRIER_IN_REAL_ROOM';end if;
  -- Il premiato è esattamente il roster reale congelato, non un nuovo iscritto.
  if (select array_agg(character_id order by character_id) from public.mission_bookings where mission_id=m.mission_id
       and status in('iscritto','completata','fallita')) is distinct from
     (select array_agg(character_id order by character_id) from public.master_v2_participants where session_id=p_session)
  then raise exception 'MGP_FINISH_BOOKING_ROSTER_DRIFT';end if;
 end if;
 return sim;
end $function$

CREATE OR REPLACE FUNCTION mission_generic_owner.close_core(p_session uuid, p_mission_outcome text, p_mission_note text, p_close_role boolean, p_expected_control_version bigint, p_request_key uuid, p_capability uuid)
 RETURNS jsonb
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO ''
AS $function$
declare v_uid uuid:=null::uuid; v_cap uuid:=p_capability; v_m public.master_v2_sessions%rowtype; v_step public.master_v2_closure_steps%rowtype;
  v_event jsonb; v_event_id uuid; v_result jsonb; v_role uuid; v_done int; v_sim boolean;
  scene56 mission_narrative_internal.scene_runtime_v1; finish56 mission_generic_owner.staff_finish_receipts_v1; proof56 jsonb; run56 public.mission_run_state;
begin
  perform public.master_v2_lock_scope(p_session);
  v_sim:=mission_generic_owner.finish_scope(p_session,p_capability,case when p_mission_outcome='successo' then 'success' else 'failure' end);
  select * into v_m from public.master_v2_sessions where id=p_session for update;
  if v_m.id is null then perform public.combat_v2_fail('sessione_inesistente','Sessione inesistente.',404,p_request_key,'{}'); end if;
  if (v_m.owner_kind<>'ai_service' or v_m.master_user is not null or v_cap is null) then perform public.combat_v2_fail('master_non_proprietario','Chiusura non consentita.',403,p_request_key,'{}'); end if;
  if v_m.control_version<>p_expected_control_version then perform public.combat_v2_fail('versione_controllo_obsoleta','Versione controllo obsoleta.',409,p_request_key,'{}'); end if;
  if v_m.tipo='quest' and v_m.mission_id is not null and p_mission_outcome not in ('successo','fallimento') then perform public.combat_v2_fail('missione_non_finalizzabile','Esito missione non valido.',422,p_request_key,'{}'); end if;
  v_event:=public.combat_v2_event_begin_ai_service(p_session,p_request_key,'mission_generic_close',jsonb_build_object('outcome',p_mission_outcome,'note',p_mission_note,'close_role',p_close_role,'expected',p_expected_control_version),p_expected_control_version,v_cap);
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
    PERFORM mission_generic_owner.finish_scope(p_session,p_capability,case when p_mission_outcome='successo' then 'success' else 'failure' end);
  elsif v_step.step_name='mission_run_terminalized' then
    IF EXISTS(SELECT 1 FROM mission_narrative_internal.scene_runtime_v1 WHERE master_session_id=p_session AND is_active) THEN
      SELECT * INTO STRICT scene56 FROM mission_narrative_internal.scene_runtime_v1 WHERE master_session_id=p_session AND is_active FOR UPDATE;
      SELECT * INTO STRICT run56 FROM public.mission_run_state WHERE master_session_id=p_session FOR UPDATE;
      SELECT * INTO STRICT finish56 FROM mission_generic_owner.staff_finish_receipts_v1 WHERE master_session_id=p_session AND state='preparing' AND transaction_id=txid_current() FOR UPDATE;
      proof56:=mission_narrative_internal.scene_finish_proof_v1(p_session,finish56.actor_user_id);
      IF v_sim IS DISTINCT FROM true OR p_mission_outcome IS DISTINCT FROM 'successo'
       OR run56.run_phase IS DISTINCT FROM 'conclusa' OR scene56.mode IS DISTINCT FROM 'closed' OR scene56.turn_owner IS DISTINCT FROM 'closed'
       OR scene56.current_phase_key IS DISTINCT FROM run56.current_step_key OR scene56.state_version<1
       OR proof56->'can_finish' IS DISTINCT FROM 'true'::jsonb
       OR finish56.source_revision IS DISTINCT FROM proof56->>'source_revision'
       OR finish56.publication_id::text IS DISTINCT FROM proof56->>'publication_id'
       OR finish56.request_key::text IS DISTINCT FROM proof56->>'request_key'
       OR finish56.history_proof IS DISTINCT FROM proof56->'history_items'
       OR finish56.history_proof_sha256 IS DISTINCT FROM public.combat_v2_sha256(proof56->'history_items')
       OR finish56.release_sha256 IS DISTINCT FROM (SELECT revision_sha256 FROM mission_factory_owner.editor_release_readiness WHERE singleton)
       OR finish56.work_snapshot_sha256 IS DISTINCT FROM (SELECT public.combat_v2_sha256(coalesce(jsonb_agg(to_jsonb(work56) ORDER BY work56.id),'[]'::jsonb)) FROM mission_generic_owner.work_items work56 WHERE work56.master_session_id=p_session)
      THEN RAISE EXCEPTION 'N56_FINISH_TERMINAL_PROOF_CONFLICT' USING ERRCODE='PT409';END IF;
      -- The published Scene already terminalized this run. The normal closure step below records completion without a second run event.
    ELSE
    perform mission_internal.close_from_master(
      p_session,p_request_key,p_expected_control_version,
      case when p_mission_outcome='successo' then 'success' else 'failure' end,
      encode(extensions.digest(coalesce(p_mission_note,''),'sha256'),'hex')
    );
    END IF;
  elsif v_step.step_name='mission_finalized' then
    if not v_sim and v_m.tipo='quest' and v_m.mission_id is not null then
      if exists(select 1 from public.missions x where x.id=v_m.mission_id and x.status in ('aperta','programmata')) then
        perform mission_generic_owner.mission_result(p_session,p_capability,v_m.mission_id,p_mission_outcome='successo',p_mission_note);
      elsif not exists(select 1 from public.missions x where x.id=v_m.mission_id and x.status=case when p_mission_outcome='successo' then 'completata' else 'fallita' end) then
        perform public.combat_v2_fail('missione_non_finalizzabile','Missione terminale con esito diverso.',409,p_request_key,'{}');
      end if;
    end if;
  elsif v_step.step_name='role_segment_finalized' then
    if p_close_role and not v_sim then
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
