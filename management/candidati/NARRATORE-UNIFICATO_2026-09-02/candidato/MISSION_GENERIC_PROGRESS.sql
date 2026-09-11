-- MISSION-GENERIC-PROGRESS/1: candidate only; dependencies DB, PLAN_WRITER, BOARD, COMBAT, PANEL, SOURCES, DISPATCH.
begin;
-- Baseline nativa letta dal progetto tyhyxkslteigibktluml, 11/09/2026.
do $pins$ declare p record;begin
 for p in select * from (values
 ('public.combat_v2_round_resolve(uuid,uuid)','74f50ecc6665bb0c9bc115dea2c58911'),
 ('public.master_v2_close_ai_service_core(uuid,text,text,boolean,bigint,uuid,uuid)','500814ab37bf0c968dcd4ebe12caccf0'),
 ('public.missione_esito(uuid,boolean,text)','e7e016791a9b24a3962ca6d7e697b699')
 ) v(signature,expected_md5) loop
  if to_regprocedure(p.signature) is null or md5(pg_get_functiondef(to_regprocedure(p.signature)))<>p.expected_md5
  or not exists(select 1 from pg_proc where oid=to_regprocedure(p.signature) and prosecdef and pg_get_userbyid(proowner)='postgres')
  then raise exception 'MGP_NATIVE_BASELINE_DRIFT: %',p.signature;end if;
 end loop;
end $pins$;

create function mission_generic_owner.finish_scope(p_session uuid,p_cap uuid,p_outcome text)
returns boolean language plpgsql security definer set search_path='' as $fn$
declare m public.master_v2_sessions;r public.mission_run_state;b mission_generic_owner.board_starts;
 settings jsonb;sim boolean;principals uuid[];
begin
 perform mission_ai_service_owner.service_only();
 perform mission_generic_owner.assert_runtime(p_session);
 perform mission_ai_service_owner.assert_capability(p_session,p_cap);
 select * into strict m from public.master_v2_sessions where id=p_session for update;
 select * into strict r from public.mission_run_state where master_session_id=p_session for update;
 select * into strict b from mission_generic_owner.board_starts where master_session_id=p_session and capability_id=p_cap;
 settings:=mission_generic_owner.run_plan_settings(p_session);
 if m.owner_kind<>'ai_service' or m.master_user is not null or m.mission_id is null or m.suspended_at is not null
 or m.stato not in('in_corso','chiusura','chiusa') or r.run_phase not in('in_corso','conclusa','fallita')
 or (r.run_phase<>'in_corso' and r.run_phase<>(case when p_outcome='success' then 'conclusa' else 'fallita' end))
 or b.state<>'published' or b.snapshot_sha256<>mission_internal.fingerprint(b.snapshot)
 or (select count(*) from jsonb_array_elements(settings->'terminal_steps') x
   where x->>'step_key'=r.current_step_key and x->>'outcome'=p_outcome)<>1
 or exists(select 1 from public.mission_run_outbox where master_session_id=p_session and state='pending')
 or exists(select 1 from mission_generic_owner.work_items where master_session_id=p_session and state<>'completed')
 or exists(select 1 from public.combat_v2_sessions where master_session_id=p_session and (state<>'chiuso' or closed_at is null))
 or exists(select 1 from public.combat_v2_sessions s join public.combat_v2_rounds rr on rr.session_id=s.id
  where s.master_session_id=p_session and rr.state<>'narrato')
 then raise exception 'MGP_FINISH_AUTHORITY' using errcode='42501';end if;
 -- Il testo conclusivo deve essere già pubblicato dal work della visita terminale.
 if not exists(select 1 from mission_generic_owner.work_items w where w.master_session_id=p_session
 and w.kind='narration' and w.state='completed' and w.step_key=r.current_step_key
 and w.run_control_version=case when r.run_phase='in_corso' then r.control_version else r.control_version-1 end
 and w.message_id is not null)
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
end $fn$;

-- Stesse ricompense native e stessi passi di chiusura; unica autorità Generic.
do $clone$ declare s text;o text;n text;begin
 s:=pg_get_functiondef('public.missione_esito(uuid,boolean,text)'::regprocedure);
 if md5(s)<>'e7e016791a9b24a3962ca6d7e697b699' then raise exception 'MGP_REWARDS_BASELINE_DRIFT';end if;
 s:=replace(s,'public.missione_esito(p_mission uuid,','mission_generic_owner.mission_result(p_session uuid, p_cap uuid, p_mission uuid,');
 o:='  if not public.is_staff() then raise exception ''solo lo staff conferma gli esiti''; end if;';
 n:=E'  if mission_generic_owner.finish_scope(p_session,p_cap,case when p_successo then ''success'' else ''failure'' end)\n  or not exists(select 1 from public.master_v2_sessions where id=p_session and mission_id=p_mission and stato=''chiusura'')\n  then raise exception ''MGP_REAL_REWARDS_SCOPE'' using errcode=''42501'';end if;';
 if (length(s)-length(replace(s,o,'')))/length(o)<>1 then raise exception 'MGP_REWARDS_GUARD_DRIFT';end if;
 s:=replace(s,o,n);s:=replace(s,'SET search_path TO ''public''','SET search_path TO ''''');execute s;
 s:=pg_get_functiondef('public.master_v2_close_ai_service_core(uuid,text,text,boolean,bigint,uuid,uuid)'::regprocedure);
 if md5(s)<>'500814ab37bf0c968dcd4ebe12caccf0' then raise exception 'MGP_CLOSE_BASELINE_DRIFT';end if;
 s:=replace(s,'public.master_v2_close_ai_service_core(', 'mission_generic_owner.close_core(');
 o:='  v_event jsonb; v_event_id uuid; v_result jsonb; v_role uuid; v_done int;';
 n:=o||' v_sim boolean;';
 if (length(s)-length(replace(s,o,'')))/length(o)<>1 then raise exception 'MGP_CLOSE_DECLARE_DRIFT';end if;s:=replace(s,o,n);
 o:='  perform public.master_v2_lock_scope(p_session);';
 n:=o||E'\n  v_sim:=mission_generic_owner.finish_scope(p_session,p_capability,case when p_mission_outcome=''successo'' then ''success'' else ''failure'' end);';
 if (length(s)-length(replace(s,o,'')))/length(o)<>1 then raise exception 'MGP_CLOSE_SCOPE_DRIFT';end if;s:=replace(s,o,n);
 o:='    if v_m.tipo=''quest'' and v_m.mission_id is not null then';n:='    if not v_sim and v_m.tipo=''quest'' and v_m.mission_id is not null then';
 if (length(s)-length(replace(s,o,'')))/length(o)<>1 then raise exception 'MGP_CLOSE_REWARDS_DRIFT';end if;s:=replace(s,o,n);
 o:='public.missione_esito(v_m.mission_id,p_mission_outcome=''successo'',p_mission_note)';
 n:='mission_generic_owner.mission_result(p_session,p_capability,v_m.mission_id,p_mission_outcome=''successo'',p_mission_note)';
 if (length(s)-length(replace(s,o,'')))/length(o)<>1 then raise exception 'MGP_CLOSE_REWARD_CALL_DRIFT';end if;s:=replace(s,o,n);
 o:='    if p_close_role then';n:='    if p_close_role and not v_sim then';
 if (length(s)-length(replace(s,o,'')))/length(o)<>1 then raise exception 'MGP_CLOSE_ROLE_DRIFT';end if;s:=replace(s,o,n);
 s:=replace(s,'''master_v2_close'',jsonb_build_object','''mission_generic_close'',jsonb_build_object');
 execute s;
end $clone$;

create function mission_generic_owner.finish_mission(p_session uuid,p_outcome text)
returns jsonb language plpgsql security definer set search_path='' as $fn$
declare m public.master_v2_sessions;c mission_ai_service_owner.capabilities;b mission_generic_owner.board_starts;
 sim boolean;k uuid;res jsonb;i integer;note text;
begin
 perform mission_ai_service_owner.service_only();
 select * into strict m from public.master_v2_sessions where id=p_session for update;
 select * into strict c from mission_ai_service_owner.capabilities where master_session_id=p_session and state='active' for update;
 sim:=mission_generic_owner.finish_scope(p_session,c.id,p_outcome);
 select * into strict b from mission_generic_owner.board_starts where master_session_id=p_session;
 k:=mission_ai_service_owner.uuid5(p_session,'generic-finish');
 note:='Missione conclusa nello step '||(select current_step_key from public.mission_run_state where master_session_id=p_session)||'.';
 if not exists(select 1 from public.master_v2_closure_steps where session_id=p_session) then
  insert into public.master_v2_closure_steps(session_id,position,step_name)
  select p_session,n::smallint,x from unnest(array['encounter_resolved','final_report_published','mission_run_terminalized',
   'mission_finalized','role_segment_finalized','master_session_closed']) with ordinality t(x,n);
 end if;
 if (select array_agg(step_name order by position) from public.master_v2_closure_steps where session_id=p_session)
 <>array['encounter_resolved','final_report_published','mission_run_terminalized','mission_finalized','role_segment_finalized','master_session_closed']
 then raise exception 'MGP_CLOSURE_STEPS_DRIFT';end if;
 -- Un'unica transazione: si avanzano soltanto i sei passi nativi, nessuna chiamata provider.
 for i in 1..6 loop
  res:=mission_generic_owner.close_core(p_session,case when p_outcome='success' then 'successo' else 'fallimento' end,
   note,not sim,m.control_version,k,c.id);
 end loop;
 if not exists(select 1 from public.master_v2_sessions where id=p_session and stato='chiusa' and closed_at is not null)
 then raise exception 'MGP_NATIVE_CLOSE_INCOMPLETE';end if;
 update mission_ai_service_owner.capabilities set state='terminal',terminal_request_key=k,terminal_mode='normal',terminal_at=clock_timestamp() where id=c.id;
 update mission_ai_board_owner.roster_reservations set state='released',released_at=clock_timestamp()
 where activation_id=b.activation_id and state='active';
 update mission_ai_board_owner.activations set state='disarmed',control_version=control_version+1
 where id=b.activation_id and current_session_id=p_session;
 update mission_generic_owner.dispatch_admissions set enabled=false where master_session_id=p_session;
 return res;
end $fn$;

revoke all on function mission_generic_owner.finish_scope(uuid,uuid,text),
 mission_generic_owner.mission_result(uuid,uuid,uuid,boolean,text),
 mission_generic_owner.close_core(uuid,text,text,boolean,bigint,uuid,uuid),mission_generic_owner.finish_mission(uuid,text)
 from public,anon,authenticated,service_role;

create function mission_generic_owner.abort_opening(p_session uuid,p_user uuid,p_request uuid)
returns jsonb language plpgsql security definer set search_path='' as $fn$
declare m public.master_v2_sessions;r public.mission_run_state;b mission_generic_owner.board_starts;
 c mission_ai_service_owner.capabilities;ev jsonb;res jsonb;
begin
 perform mission_generic_owner.dispatch_user(p_session,p_user);
 select * into strict m from public.master_v2_sessions where id=p_session for update;
 select * into strict r from public.mission_run_state where master_session_id=p_session for update;
 select * into strict b from mission_generic_owner.board_starts where master_session_id=p_session for update;
 select * into strict c from mission_ai_service_owner.capabilities where id=b.capability_id and state='active' for update;
 if m.stato<>'preparazione' or m.closed_at is not null or r.run_phase<>'preparazione' or b.state<>'prepared'
 or b.snapshot_sha256<>mission_internal.fingerprint(b.snapshot)
 or exists(select 1 from public.combat_v2_sessions where master_session_id=p_session)
 or (select count(*) from mission_generic_owner.work_items where master_session_id=p_session)<>1
 or not exists(select 1 from mission_generic_owner.work_items w where w.master_session_id=p_session
  and w.state='failed' and w.kind='narration' and w.message_id is null and w.finalized_at is not null
  and w.payload->>'opening_start_receipt_id'=b.id::text)
 or exists(select 1 from public.mission_run_outbox where master_session_id=p_session and state='published')
 then raise exception 'MGP_ABORT_OPENING_NOT_DEFINITIVE' using errcode='42501';end if;
 perform mission_ai_service_owner.assert_capability(p_session,c.id);
 ev:=public.combat_v2_event_begin_ai_service(p_session,p_request,'mission_generic_opening_abort',
 jsonb_build_object('start_receipt_id',b.id,'reason','opening_failed'),m.control_version,c.id);
 if (ev->>'replay')::boolean then return ev->'result';end if;
 update public.master_v2_sessions set stato='annullata',closed_at=clock_timestamp(),close_reason='opening_failed' where id=p_session;
 res:=mission_internal.sync_lifecycle(p_session,mission_ai_service_owner.uuid5(p_request,'abort-run'),m.control_version,r.control_version,'annullata');
 update public.master_v2_participants set engagement_state='concluso',left_at=clock_timestamp() where session_id=p_session and left_at is null;
 update mission_generic_owner.board_starts set state='aborted' where id=b.id;
 update mission_ai_board_owner.roster_reservations set state='released',released_at=clock_timestamp()
 where activation_id=b.activation_id and state='active';
 update mission_ai_board_owner.weekly_quota set state='released',released_at=clock_timestamp()
 where activation_id=b.activation_id and state='reserved';
 update mission_ai_board_owner.activations set state='disarmed',control_version=control_version+1
 where id=b.activation_id and current_session_id=p_session;
 update mission_generic_owner.dispatch_admissions set enabled=false where master_session_id=p_session;
 res:=public.combat_v2_event_complete((ev->>'event_id')::uuid,
 public.combat_v2_envelope(p_request,jsonb_build_object('state','annullata','master_session_id',p_session,'start_receipt_id',b.id)));
 update mission_ai_service_owner.capabilities set state='terminal',terminal_request_key=p_request,terminal_mode='abort',terminal_at=clock_timestamp() where id=c.id;
 -- Outbox non pubblicata e work fallito rimangono nello storico: nessuna finta pubblicazione.
 return res;
end $fn$;
revoke all on function mission_generic_owner.abort_opening(uuid,uuid,uuid) from public,anon,authenticated,service_role;

create function mission_generic_owner.start_claim_valid(p_master uuid)
returns boolean language plpgsql security definer set search_path='' as $fn$
declare c mission_generic_owner.start_claims;m public.master_v2_sessions;
begin
 select * into c from mission_generic_owner.start_claims where session_id=p_master;
 if not found or c.state<>'authorizing' or c.transaction_id<>txid_current() or c.backend_pid<>pg_backend_pid() or c.actor_user_id is distinct from auth.uid()
 then return false;end if;
 select * into strict m from public.master_v2_sessions where id=p_master;
 if m.owner_kind<>'ai_service' or m.master_user is not null or m.tipo<>'quest' or m.stato<>'preparazione'
 or m.mission_id is distinct from c.mission_id or m.location_id is distinct from c.location_id
 or m.closed_at is not null then raise exception 'MGP_START_CLAIM_DRIFT' using errcode='42501';end if;
 perform mission_generic_owner.location_runtime(c.location_id,c.simulation);
 if c.simulation and (c.location_id<>'0b85f354-9cdb-47e1-baf9-3d266bb7e06b'::uuid
 or not combat_consumer_private.staff_test_allowed(c.location_id,array[c.actor_user_id],false)
 or not exists(select 1 from mission_generic_owner.simulation_sources where carrier_mission_id=c.mission_id))
 then raise exception 'MGP_START_SIMULATION_SCOPE' using errcode='42501';end if;
 if not exists(select 1 from mission_generic_owner.definitions where id=c.definition_id)
 then raise exception 'MGP_START_DEFINITION';end if;
 return true;
end $fn$;

-- Hook dopo COMBAT: prova transazionale di Board prima del binding FK.
do $patch$ declare s text;o text;n text;begin
 s:=pg_get_functiondef('combat_panel_private.enroll_master(uuid)'::regprocedure);
 if md5(s)<>'3ace2632fdb641b78f9f4efc9ae1868f' then raise exception 'MGP_COMBAT_ENROLL_BASELINE_DRIFT';end if;
 o:=' SELECT * INTO STRICT m FROM public.master_v2_sessions WHERE id=p_master FOR UPDATE;';
 n:=o||E'\n IF mission_generic_owner.start_claim_valid(p_master) THEN RETURN; END IF;';
 if (length(s)-length(replace(s,o,'')))/length(o)<>1 then raise exception 'MGP_START_HOOK_DRIFT';end if;
 execute replace(s,o,n);
end $patch$;

create function mission_generic_owner.progress_result(p_session uuid,p_user uuid,p_state text)
returns jsonb language plpgsql security definer set search_path='' as $fn$
declare d jsonb;
begin
 d:=public.mission_generic_dispatch_next_v1(p_session,p_user);
 return jsonb_build_object('schema_version','mission-generic-progress/1','master_session_id',p_session,
  'state',p_state,'dispatch',d->'request');
end $fn$;

create function mission_generic_owner.encounter_outcome(p_session uuid,p_encounter uuid)
returns text language plpgsql stable security definer set search_path='' as $fn$
declare e mission_generic_owner.encounters;sc jsonb;pgteam text;teams text[];
begin
 select * into strict e from mission_generic_owner.encounters where master_session_id=p_session and encounter_id=p_encounter;
 sc:=mission_generic_owner.scene(p_session,e.step_key);
 select x->>'pg_team' into strict pgteam from jsonb_array_elements(sc->'encounters') x where x->>'encounter_key'=e.encounter_key;
 if not exists(select 1 from public.combat_v2_sessions where id=p_encounter and state in('risolto','chiuso'))
 or exists(select 1 from public.combat_v2_rounds where session_id=p_encounter and state<>'narrato')
 then raise exception 'MGP_OUTCOME_NOT_TERMINAL';end if;
 select array_agg(distinct team_key) into teams from public.combat_v2_actors
 where session_id=p_encounter and state='attivo' and companion_id is null;
 if coalesce(cardinality(teams),0)=0 then return 'draw';end if;
 if cardinality(teams)<>1 then raise exception 'MGP_OUTCOME_NOT_UNIQUE';end if;
 return case when teams[1]=pgteam then 'pg_win' else 'pg_loss' end;
end $fn$;

create function mission_generic_owner.advance_combat_terminal(p_session uuid,p_encounter uuid)
returns jsonb language plpgsql security definer set search_path='' as $fn$
declare e mission_generic_owner.encounters;m public.master_v2_sessions;r public.mission_run_state;
 sc jsonb;selected jsonb;n integer;outcome text;receipt jsonb;ev public.combat_v2_events;k uuid;
begin
 select * into strict m from public.master_v2_sessions where id=p_session for update;
 select * into strict r from public.mission_run_state where master_session_id=p_session for update;
 select * into strict e from mission_generic_owner.encounters where master_session_id=p_session and encounter_id=p_encounter;
 if r.current_step_key<>e.step_key or r.control_version<>e.run_control_version
 then raise exception 'MGP_TERMINAL_VISIT_DRIFT' using errcode='40001';end if;
 sc:=mission_generic_owner.scene(p_session,r.current_step_key);
 outcome:=mission_generic_owner.encounter_outcome(p_session,p_encounter);
 select count(*),jsonb_agg(x)->0 into n,selected from jsonb_array_elements(sc->'triggers') x
 where x->>'source_kind'='combat_terminal' and x->>'encounter_key'=e.encounter_key
 and coalesce(x->>'combat_outcome','any') in('any',outcome);
 if n<>1 then raise exception 'MGP_TERMINAL_TRIGGER_AMBIGUOUS_OR_MISSING' using errcode='22023';end if;
 k:=mission_ai_service_owner.uuid5(p_encounter,'generic-close');
 receipt:=public.mission_generic_combat_close_v1(p_session,p_encounter,r.control_version,k);
 select * into strict ev from public.combat_v2_events where id=(receipt#>>'{data,terminal_event_id}')::uuid;
 if ev.scope_id<>p_session or ev.operation_kind<>'mission_generic_combat_close' or ev.status<>'completata'
 or ev.caller_kind<>'ai_service' or ev.caller_service_capability<>e.capability_id
 or ev.result#>>'{data,encounter_id}' is distinct from p_encounter::text
 or ev.result#>>'{data,step_key}' is distinct from r.current_step_key
 or (ev.result#>>'{data,run_version}')::bigint is distinct from r.control_version
 then raise exception 'MGP_TERMINAL_RECEIPT_INVALID' using errcode='42501';end if;
 return mission_generic_owner.apply_authority(p_session,mission_ai_service_owner.uuid5(ev.id,'generic-transition'),
 m.control_version,r.control_version,selected->>'trigger_key','combat_terminal',ev.id,public.combat_v2_sha256(to_jsonb(ev)),null);
end $fn$;

create function mission_generic_owner.progress_step(p_session uuid,p_user uuid,p_request uuid)
returns jsonb language plpgsql security definer set search_path='' as $fn$
declare m public.master_v2_sessions;r public.mission_run_state;e mission_generic_owner.encounters;
 s public.combat_v2_sessions;roundrow public.combat_v2_rounds;rep public.combat_v2_round_reports;
 sc jsonb;spec jsonb;settings jsonb;term jsonb;cap uuid;actor uuid;res jsonb;n integer;pending jsonb;
begin
 perform mission_ai_board_owner.service_only();
 if p_request is null then raise exception 'MGP_REQUEST_REQUIRED';end if;
 perform mission_generic_owner.dispatch_user(p_session,p_user);
 perform public.master_v2_lock_scope(p_session);
 select * into strict m from public.master_v2_sessions where id=p_session for update;
 perform mission_generic_owner.assert_runtime(p_session);
 select * into strict r from public.mission_run_state where master_session_id=p_session for update;
 if m.closed_at is not null then return jsonb_build_object('schema_version','mission-generic-progress/1','master_session_id',p_session,'state','closed','dispatch',null);end if;
 select id into strict cap from mission_ai_service_owner.capabilities where master_session_id=p_session and state='active';
 pending:=public.mission_generic_dispatch_next_v1(p_session,p_user);
 if pending->'request' is not null then return mission_generic_owner.progress_result(p_session,p_user,'work_pending');end if;
 if m.stato='preparazione' and r.run_phase='preparazione' and exists(select 1 from mission_generic_owner.work_items
 where master_session_id=p_session and state='failed' and payload ? 'opening_start_receipt_id') then
  res:=mission_generic_owner.abort_opening(p_session,p_user,mission_ai_service_owner.uuid5(p_session,'generic-abort-opening'));
  return jsonb_build_object('schema_version','mission-generic-progress/1','master_session_id',p_session,'state','aborted','dispatch',null);
 end if;
 if m.stato<>'in_corso' or m.suspended_at is not null or r.run_phase<>'in_corso'
 then return mission_generic_owner.progress_result(p_session,p_user,'paused');end if;
 perform mission_generic_owner.assert_combat_scope(p_session,cap);
 if exists(select 1 from mission_generic_owner.work_items where master_session_id=p_session
 and step_key=r.current_step_key and run_control_version=r.control_version and state='failed')
 then return mission_generic_owner.progress_result(p_session,p_user,'needs_attention');end if;
 if exists(select 1 from public.mission_run_outbox where master_session_id=p_session and state='pending')
 then return mission_generic_owner.progress_result(p_session,p_user,'narration_pending');end if;
 settings:=mission_generic_owner.run_plan_settings(p_session);
 select count(*),jsonb_agg(x)->0 into n,term from jsonb_array_elements(settings->'terminal_steps') x where x->>'step_key'=r.current_step_key;
 if n>1 then raise exception 'MGP_PLAN_TERMINAL_AMBIGUOUS';end if;
 if n=1 then
  res:=mission_generic_owner.finish_mission(p_session,term->>'outcome');
  return jsonb_build_object('schema_version','mission-generic-progress/1','master_session_id',p_session,'state','closed','dispatch',null);
 end if;
 sc:=mission_generic_owner.scene(p_session,r.current_step_key);
 select count(*) into n from mission_generic_owner.encounters x join public.combat_v2_sessions y on y.id=x.encounter_id
 where x.master_session_id=p_session and y.closed_at is null;
 if n>1 then raise exception 'MGP_MULTIPLE_ACTIVE_ENCOUNTERS';end if;
 select x.* into e from mission_generic_owner.encounters x join public.combat_v2_sessions y on y.id=x.encounter_id
 where x.master_session_id=p_session and y.closed_at is null;
 if e.encounter_id is null then
  select count(*),jsonb_agg(x)->0 into n,spec from jsonb_array_elements(sc->'encounters') x
  where not exists(select 1 from mission_generic_owner.encounters z where z.master_session_id=p_session
   and z.step_key=r.current_step_key and z.run_control_version=r.control_version and z.encounter_key=x->>'encounter_key');
  if n=0 then return mission_generic_owner.progress_result(p_session,p_user,'waiting_choice');end if;
  if n>1 then raise exception 'MGP_ENCOUNTER_OPEN_POINT_AMBIGUOUS' using errcode='22023';end if;
  res:=public.mission_generic_combat_open_v1(p_session,spec->>'encounter_key',r.control_version,
    mission_ai_service_owner.uuid5(p_session,'encounter:'||r.control_version||':'||(spec->>'encounter_key')));
  select * into strict e from mission_generic_owner.encounters where encounter_id=(res->>'encounter_id')::uuid;
 end if;
 if e.step_key<>r.current_step_key or e.run_control_version<>r.control_version then raise exception 'MGP_ENCOUNTER_VISIT_DRIFT';end if;
 select * into strict s from public.combat_v2_sessions where id=e.encounter_id for update;
 if s.state='risolto' then
  res:=mission_generic_owner.advance_combat_terminal(p_session,s.id);
  return mission_generic_owner.progress_result(p_session,p_user,'transitioned');
 end if;
 if s.state<>'in_corso' then raise exception 'MGP_ENCOUNTER_STATE';end if;
 select * into strict roundrow from public.combat_v2_rounds where session_id=s.id order by round_no desc limit 1 for update;
 if roundrow.state in('risolto','narrazione') then
  select * into strict rep from public.combat_v2_round_reports where round_id=roundrow.id;
  if rep.narration_state<>'attesa' then raise exception 'MGP_REPORT_STATE';end if;
  res:=mission_generic_owner.enqueue_combat(p_session,rep.id);
  return mission_generic_owner.progress_result(p_session,p_user,'narration_ready');
 end if;
 -- Common offre difese soltanto nella fase nativa raccolta_difese. Un target
 -- già creato durante raccolta_azioni non anticipa la scelta del PNG.
 select a.id into actor from public.combat_v2_actors a where a.session_id=s.id and a.actor_kind='png' and a.state='attivo'
 and roundrow.phase='raccolta_difese' and roundrow.state='raccolta_difese'
 and exists(select 1 from jsonb_array_elements(e.actor_map) x where x->>'actor_id'=a.id::text and x->>'mechanical_binding_id' is not null)
 and exists(select 1 from public.combat_v2_attack_targets t where t.round_id=roundrow.id and t.target_actor_id=a.id
  and not exists(select 1 from public.combat_v2_defense_coverages c where c.attack_target_id=t.id)) order by a.id limit 1;
 if actor is not null then
  res:=mission_generic_owner.enqueue_choice(p_session,s.id,actor);
  return mission_generic_owner.progress_result(p_session,p_user,'choice_ready');
 end if;
 if exists(select 1 from public.combat_v2_actors a where a.session_id=s.id and a.actor_kind='pg' and a.state='attivo'
 and clan_marionettisti_private.can_declare(a.id) and not exists(select 1 from public.combat_v2_declarations d
  where d.round_id=roundrow.id and d.actor_id=a.id and d.kind in('attacco','movimento','utilita','passa')))
 then return mission_generic_owner.progress_result(p_session,p_user,'waiting_player');end if;
 -- La barriera PG precedente resta obbligatoria; ogni PNG riceve una
 -- principale soltanto se manca e il round raccoglie ancora azioni.
 select a.id into actor from public.combat_v2_actors a where a.session_id=s.id and a.actor_kind='png' and a.state='attivo'
 and roundrow.phase='raccolta_azioni' and roundrow.state='raccolta_azioni'
 and clan_marionettisti_private.can_declare(a.id)
 and exists(select 1 from jsonb_array_elements(e.actor_map) x where x->>'actor_id'=a.id::text and x->>'mechanical_binding_id' is not null)
 and not exists(select 1 from public.combat_v2_declarations d where d.round_id=roundrow.id and d.actor_id=a.id
 and d.kind in('attacco','movimento','utilita','passa')) order by a.id limit 1;
 if actor is not null then
  res:=mission_generic_owner.enqueue_choice(p_session,s.id,actor);
  return mission_generic_owner.progress_result(p_session,p_user,'choice_ready');
 end if;
 if (select count(*) from public.combat_v2_declarations where round_id=roundrow.id and kind in('attacco','movimento','utilita','passa'))
 <>combat_consumer_private.expected_main_count(roundrow.id)
 then return mission_generic_owner.progress_result(p_session,p_user,'waiting_player');end if;
 if not combat_v2_multitarget_internal.round_complete(roundrow.id)
 then return mission_generic_owner.progress_result(p_session,p_user,'waiting_defense');end if;
 if roundrow.evaluation_mode<>'neutra' and exists(select 1 from public.combat_v2_declarations d
 join public.combat_v2_actors a on a.id=d.actor_id where d.round_id=roundrow.id and a.actor_kind='pg' and d.kind in('attacco','difesa')
 and not exists(select 1 from public.combat_v2_ratings x where x.declaration_id=d.id and x.is_active))
 then return mission_generic_owner.progress_result(p_session,p_user,'waiting_quality');end if;
 -- Neutra: il resolver nativo registra zero con fonte neutralita_sistema. Nessun voto IA.
 if (select is_test from public.locations where id=m.location_id) and (public.combat_v2_values_written(s.id)
 or not combat_panel_private.uses_simulated_pools(s.id)) then raise exception 'MGP_SIMULATION_SCOPE' using errcode='42501';end if;
 res:=public.combat_v2_round_resolve(roundrow.id,mission_ai_service_owner.uuid5(roundrow.id,'generic-resolve'));
 select * into strict rep from public.combat_v2_round_reports where id=(res#>>'{data,report_id}')::uuid and round_id=roundrow.id;
 res:=mission_generic_owner.enqueue_combat(p_session,rep.id);
 return mission_generic_owner.progress_result(p_session,p_user,'narration_ready');
end $fn$;

create function public.mission_generic_room_state_v1(p_location uuid)
returns jsonb language plpgsql stable security definer set search_path='' as $fn$
declare uid uuid:=auth.uid();m public.master_v2_sessions;r public.mission_run_state;vchoices jsonb;
 staff boolean;participant boolean;objective text;active boolean;
begin
 if uid is null then raise exception 'authentication_required' using errcode='28000';end if;
 staff:=exists(select 1 from public.profiles where id=uid and role in('admin','master'));
 select s.* into m from public.master_v2_sessions s join mission_generic_owner.run_bindings b on b.master_session_id=s.id
 where s.location_id=p_location and s.closed_at is null and s.owner_kind='ai_service'
 and (staff or exists(select 1 from public.master_v2_participants p join public.characters c on c.id=p.character_id and c.user_id=uid
  where p.session_id=s.id and p.user_id_snapshot=uid and p.left_at is null)) order by s.created_at desc limit 1;
 if m.id is null then return null;end if;
 perform mission_generic_owner.assert_runtime(m.id);
 select * into strict r from public.mission_run_state where master_session_id=m.id;
 participant:=exists(select 1 from public.master_v2_participants p join public.characters c on c.id=p.character_id and c.user_id=uid
 where p.session_id=m.id and p.user_id_snapshot=uid and p.left_at is null);
 select public_objective into objective from public.mission_plan_steps where plan_version_id=r.plan_version_id and step_key=r.current_step_key;
 if participant then vchoices:=public.mission_generic_choices_v1(m.id);else vchoices:=jsonb_build_object('choices','[]'::jsonb);end if;
 active:=m.stato in('preparazione','in_corso') and m.suspended_at is null and r.run_phase in('preparazione','in_corso');
 return jsonb_build_object('session_id',m.id,'step_key',r.current_step_key,'objective',objective,
 'choices',vchoices->'choices','choice_context',vchoices-'choices','state',m.stato,'can_tick',active,
 'request',case when active then jsonb_build_object('schema_version','mission-generic-tick/1','master_session_id',m.id) else null end);
end $fn$;


create table mission_generic_owner.progress_receipts (
 request_key uuid primary key,
 master_session_id uuid not null references mission_generic_owner.run_bindings(master_session_id),
 actor_user_id uuid not null,
 result jsonb not null,
 result_sha256 text not null check(result_sha256~'^[0-9a-f]{64}$'),
 created_at timestamptz not null default clock_timestamp()
);
alter table mission_generic_owner.progress_receipts enable row level security;
create trigger mission_generic_progress_immutable before update or delete on mission_generic_owner.progress_receipts
 for each row execute function mission_generic_owner.immutable();
revoke all on mission_generic_owner.progress_receipts from public,anon,authenticated,service_role;

create function public.mission_generic_progress_v1(p_session uuid,p_user uuid,p_request uuid)
returns jsonb language plpgsql security definer set search_path='' as $fn$
declare old mission_generic_owner.progress_receipts;res jsonb;
begin
 perform mission_ai_board_owner.service_only();
 if p_user is null or p_request is null or p_session is null then raise exception 'MGP_REQUEST_REQUIRED';end if;
 perform mission_ai_service_owner.lock_request(p_request);
 select * into old from mission_generic_owner.progress_receipts where request_key=p_request;
 if found then
  if old.master_session_id<>p_session or old.actor_user_id<>p_user or old.result_sha256<>public.combat_v2_sha256(old.result)
  then raise exception 'MGP_REQUEST_CONFLICT' using errcode='40001';end if;
  return old.result;
 end if;
 res:=mission_generic_owner.progress_step(p_session,p_user,p_request);
 insert into mission_generic_owner.progress_receipts(request_key,master_session_id,actor_user_id,result,result_sha256)
 values(p_request,p_session,p_user,res,public.combat_v2_sha256(res));
 return res;
end $fn$;

revoke all on function mission_generic_owner.start_claim_valid(uuid),mission_generic_owner.progress_result(uuid,uuid,text),
 mission_generic_owner.encounter_outcome(uuid,uuid),mission_generic_owner.advance_combat_terminal(uuid,uuid)
 from public,anon,authenticated,service_role;
revoke all on function mission_generic_owner.progress_step(uuid,uuid,uuid),public.mission_generic_progress_v1(uuid,uuid,uuid),public.mission_generic_room_state_v1(uuid)
 from public,anon,authenticated,service_role;
grant execute on function public.mission_generic_progress_v1(uuid,uuid,uuid) to service_role;
grant execute on function public.mission_generic_room_state_v1(uuid) to authenticated;

commit;
