-- MISSION-GENERIC-BOARD/1 candidate. Dependency order: DB, PLAN_WRITER, BOARD,
-- COMBAT authority delta, DISPATCH. No enable/apply has been performed.
begin;
do $staff_pin$
begin
 if md5(pg_get_functiondef('combat_consumer_private.staff_test_allowed(uuid,uuid[],boolean)'::regprocedure))
  <>'80434afefcecbc48e190999830389cee' then raise exception 'MGB_STAFF_POLICY_BASELINE_DRIFT';end if;
end;
$staff_pin$;
alter table mission_ai_board_owner.activations add column generic_plan_version_id uuid
 references mission_generic_owner.plan_revisions(plan_version_id);
alter table mission_ai_board_owner.activations alter column package_id drop not null;
alter table mission_ai_board_owner.activations add constraint activations_content_source_xor
 check ((package_id is not null and generic_plan_version_id is null)
     or (package_id is null and generic_plan_version_id is not null));
alter table mission_generic_owner.runtime_policy add column provider_max_calls integer check(provider_max_calls>0);
alter table mission_generic_owner.runtime_policy add column provider_max_cost_usd numeric check(provider_max_cost_usd>0);

create table mission_generic_owner.start_claims (
 session_id uuid primary key,
 mission_id uuid not null references public.missions(id),
 location_id uuid not null references public.locations(id),
 definition_id uuid not null references mission_generic_owner.definitions(id),
 request_key uuid not null unique,
 actor_user_id uuid not null,
 transaction_id bigint not null,
 backend_pid integer not null,
 simulation boolean not null,
 state text not null check(state in('authorizing','bound')),
 created_at timestamptz not null default clock_timestamp()
);
create table mission_generic_owner.board_starts (
 id uuid primary key default gen_random_uuid(),
 master_session_id uuid not null unique references public.master_v2_sessions(id),
 activation_id uuid not null references mission_ai_board_owner.activations(id),
 capability_id uuid not null references mission_ai_service_owner.capabilities(id),
 request_key uuid not null unique,
 request_fingerprint text not null check(request_fingerprint~'^[0-9a-f]{64}$'),
 event_id uuid not null unique references public.mission_run_events(id),
 snapshot jsonb not null check(jsonb_typeof(snapshot)='object'),
 snapshot_sha256 text not null check(snapshot_sha256~'^[0-9a-f]{64}$'),
 simulation boolean not null,
 state text not null check(state in('prepared','published','aborted')),
 created_at timestamptz not null default clock_timestamp(),
 published_at timestamptz,
 result jsonb not null check(jsonb_typeof(result)='object')
);
create table mission_generic_owner.simulation_sources (
 carrier_mission_id uuid primary key references public.missions(id),
 source_mission_id uuid not null references public.missions(id),
 source_plan_version_id uuid not null references public.mission_plan_versions(id),
 source_sha256 text not null check(source_sha256~'^[0-9a-f]{64}$'),
 request_key uuid not null unique,
 request_fingerprint text not null check(request_fingerprint~'^[0-9a-f]{64}$'),
 created_at timestamptz not null default clock_timestamp()
);
create trigger mission_generic_simulation_source_immutable before update or delete on mission_generic_owner.simulation_sources
 for each row execute function mission_generic_owner.immutable();
alter table mission_generic_owner.start_claims enable row level security;
alter table mission_generic_owner.board_starts enable row level security;
alter table mission_generic_owner.simulation_sources enable row level security;
revoke all on mission_generic_owner.start_claims,mission_generic_owner.board_starts,mission_generic_owner.simulation_sources
 from public,anon,authenticated,service_role;

create function mission_generic_owner.location_runtime(p_location uuid,p_simulation boolean)
returns void language plpgsql stable security definer set search_path='' as $fn$
declare l public.locations;p mission_generic_owner.runtime_policy;
begin
 select * into strict l from public.locations where id=p_location;
 select * into strict p from mission_generic_owner.runtime_policy where singleton;
 if not l.is_active or (coalesce(l.is_exam_room,false) and not coalesce(l.is_test,false)) or coalesce(l.is_test,false)<>p_simulation
 or p.mode='off' or (p.mode='test' and not p_simulation)
 then raise exception 'MGB_LOCATION_RUNTIME_CLOSED' using errcode='55000';end if;
end;
$fn$;

create function mission_generic_owner.arena_source(p_mission uuid,p_location uuid)
returns jsonb language plpgsql security definer set search_path='' as $fn$
declare cfg combat_panel_private.universal_arena_config;t combat_spatial.arena_templates;
 tk text;tv integer;zone text;revision bigint;origin text;catalog jsonb;
begin
 perform 1 from public.locations where id=p_location and is_active and (not coalesce(is_exam_room,false) or coalesce(is_test,false));
 if not found then raise exception 'MGB_ARENA_LOCATION' using errcode='22023';end if;
 perform 1 from combat_panel_private.universal_arena_runtime where singleton and enabled for share;
 if not found then raise exception 'MGB_ARENA_RUNTIME_CLOSED' using errcode='55000';end if;
 perform pg_advisory_xact_lock(hashtextextended('universal-arena-config:'||p_mission::text,817));
 select * into cfg from combat_panel_private.universal_arena_config where scope='mission' and target_id=p_mission for share;
 if found then tk:=cfg.template_key;tv:=cfg.template_version;zone:=cfg.zone_key;revision:=cfg.version;origin:='mission';
 else tk:='master_test_20x20_v1';tv:=1;zone:='arena';revision:=0;origin:='test_fallback';end if;
 if zone<>'arena' then raise exception 'MGB_ARENA_ZONE_UNAVAILABLE' using errcode='22023';end if;
 select * into strict t from combat_spatial.arena_templates where template_key=tk and template_version=tv and status='ready' for share;
 perform 1 from combat_spatial.arena_slots where template_key=tk and template_version=tv order by slot_key for share;
 perform 1 from combat_spatial.arena_objects where template_key=tk and template_version=tv order by object_key for share;
 if combat_spatial.template_errors(tk,tv)<>'[]'::jsonb then raise exception 'MGB_ARENA_TEMPLATE_INVALID' using errcode='22023';end if;
 catalog:=jsonb_build_object('template',to_jsonb(t),'slots',(select coalesce(jsonb_agg(to_jsonb(x) order by slot_key),'[]'::jsonb)
  from combat_spatial.arena_slots x where template_key=tk and template_version=tv),'objects',(select coalesce(jsonb_agg(to_jsonb(x) order by object_key),'[]'::jsonb)
  from combat_spatial.arena_objects x where template_key=tk and template_version=tv));
 return jsonb_build_object('schema_version','mission-arena-source/1','mission_id',p_mission,'location_id',p_location,
  'origin',origin,'config_revision',revision,'template_key',tk,'template_version',tv,'zone_key',zone,
  'width_m',t.width_m,'height_m',t.height_m,'catalog_sha256',public.combat_v2_sha256(catalog),'catalog',catalog,'frozen_at',clock_timestamp());
end;
$fn$;

-- Both BEFORE and AFTER booking triggers use the same native finalization authority.
create function mission_generic_owner.booking_terminal_assert(p_mission uuid,p_character uuid,p_status text)
returns void language plpgsql security definer set search_path='' as $fn$
declare a mission_ai_board_owner.activations;m public.master_v2_sessions;r public.mission_run_state;
 bs mission_generic_owner.board_starts;c mission_ai_service_owner.capabilities;outcome text;
begin
 perform mission_ai_service_owner.service_only();
 if p_status not in('completata','fallita') then raise exception 'MGB_BOOKING_TERMINAL_STATUS' using errcode='42501';end if;
 select * into strict a from mission_ai_board_owner.activations where mission_id=p_mission and generic_plan_version_id is not null for update;
 select * into strict m from public.master_v2_sessions where id=a.current_session_id and mission_id=p_mission;
 select * into strict r from public.mission_run_state where master_session_id=m.id;
 select * into strict bs from mission_generic_owner.board_starts where master_session_id=m.id and activation_id=a.id;
 select * into strict c from mission_ai_service_owner.capabilities where id=bs.capability_id and master_session_id=m.id and state='active';
 outcome:=case when p_status='completata' then 'success' else 'failure' end;
 if a.state<>'started' or m.stato<>'chiusura' or m.closed_at is not null or bs.simulation
 or r.run_phase<>(case when outcome='success' then 'conclusa' else 'fallita' end)
 or not exists(select 1 from public.master_v2_participants where session_id=m.id and character_id=p_character)
 or not exists(select 1 from mission_ai_board_owner.applicants where activation_id=a.id and character_id=p_character and decision='started' and ordinal is not null)
 or mission_generic_owner.finish_scope(m.id,c.id,outcome) is distinct from false
 then raise exception 'MGB_BOOKING_TERMINAL_AUTHORITY' using errcode='42501';end if;
end;
$fn$;

create function mission_generic_owner.booking_assert(p_mission uuid,p_character uuid,p_new_status text,p_old_status text,p_op text)
returns void language plpgsql security definer set search_path='' as $fn$
declare a mission_ai_board_owner.activations;s jsonb;
begin
 select * into strict a from mission_ai_board_owner.activations where mission_id=p_mission for update;
 if a.generic_plan_version_id is null then raise exception 'MGB_BOOKING_STATE' using errcode='55000';end if;
 if p_op='UPDATE' and p_old_status='iscritto' and p_new_status in('completata','fallita') then
  perform mission_generic_owner.booking_terminal_assert(p_mission,p_character,p_new_status);return;
 end if;
 if a.state<>'enrollment_open' then raise exception 'MGB_BOOKING_STATE' using errcode='55000';end if;
 if p_op='UPDATE' and p_old_status='iscritto' and p_new_status<>'iscritto' then return;end if;
 if p_new_status='iscritto' and (p_op='INSERT' or p_old_status is distinct from 'iscritto') then
  perform mission_generic_owner.location_runtime(a.location_id,false);
  s:=mission_generic_owner.selected_plan(p_mission);
  if (s->>'plan_version_id')::uuid<>a.generic_plan_version_id
   or a.mission_seal_sha256<>s#>>'{settings,source_mission_sha256}' then raise exception 'MGB_BOOKING_PLAN_DRIFT' using errcode='40001';end if;
  if (select count(*) from public.mission_bookings where mission_id=p_mission and status='iscritto') >= (s#>>'{settings,team_max}')::int
  then raise exception 'Squadra al completo';end if;
 end if;
end;
$fn$;

-- Preserve the exact legacy body. Only the explicit generic branch dispatches.
do $patch$
declare src text;needle text:= 'select*into a from mission_ai_board_owner.activations where mission_id=new.mission_id for update;has_a:=found;';
begin
 src:=pg_get_functiondef('mission_ai_board_owner.booking_guard()'::regprocedure);
 if md5(src)<>'bc2c23eaa64e0a69bc4cc5c568368364' or (length(src)-length(replace(src,needle,'')))/length(needle)<>1
 then raise exception 'MGB_BOOKING_GUARD_BASELINE_DRIFT';end if;
 src:=replace(src,needle,needle||E'\n if has_a and a.generic_plan_version_id is not null then\n  perform mission_generic_owner.booking_assert(new.mission_id,new.character_id,new.status,case when tg_op=''UPDATE'' then old.status else null end,tg_op);\n  return new;\n end if;');
 execute src;
end;
$patch$;

do $patch_sync$
declare src text;needle text:='select*into a from mission_ai_board_owner.activations where mission_id=new.mission_id for update;if not found then return null;end if;';
begin
 src:=pg_get_functiondef('mission_ai_board_owner.booking_sync()'::regprocedure);
 if md5(src)<>'451704552b059dd8bfbcb8585a0e59a5' or (length(src)-length(replace(src,needle,'')))/length(needle)<>1
 then raise exception 'MGB_BOOKING_SYNC_BASELINE_DRIFT';end if;
 src:=replace(src,needle,needle||E'\n if a.generic_plan_version_id is not null and tg_op=''UPDATE'' and old.status=''iscritto'' and new.status in(''completata'',''fallita'') then\n  perform mission_generic_owner.booking_terminal_assert(new.mission_id,new.character_id,new.status);\n  return null;\n end if;');
 execute src;
end;
$patch_sync$;

create function mission_generic_owner.staff_roster_assert(p_location uuid,p_roster uuid[])
returns void language plpgsql security definer set search_path='' as $fn$
declare principals uuid[];
begin
 perform mission_ai_board_owner.staff_only();
 perform mission_generic_owner.location_runtime(p_location,true);
 if p_roster is null or cardinality(p_roster)=0 or array_position(p_roster,null) is not null
  or (select count(distinct x) from unnest(p_roster)x)<>cardinality(p_roster)
 then raise exception 'MGB_STAFF_ROSTER_POLICY' using errcode='42501';end if;
 perform pg_advisory_xact_lock(hashtextextended(x::text,203)) from unnest(p_roster)x order by x;
 perform 1 from public.characters where id=any(p_roster) order by id for share;
 select array_agg(user_id order by id) into principals from public.characters where id=any(p_roster) and not archived;
 if cardinality(principals) is distinct from cardinality(p_roster)
  or combat_consumer_private.staff_test_allowed(p_location,principals,true) is distinct from true
 then raise exception 'MGB_STAFF_ROSTER_POLICY' using errcode='42501';end if;
end;
$fn$;

create function public.mission_generic_board_open_v1(p_mission uuid,p_location uuid,p_request uuid)
returns jsonb language plpgsql security definer set search_path='' as $fn$
declare s jsonb;a mission_ai_board_owner.activations;m public.missions;fp text;r jsonb;
begin
 perform mission_ai_board_owner.staff_only();perform mission_ai_board_owner.lock_request(p_request);
 fp:=mission_internal.fingerprint(jsonb_build_object('mission',p_mission,'location',p_location));
 r:=mission_ai_board_owner.replay(p_request,'generic_open',fp);if r is not null then return r;end if;
 select * into strict m from public.missions where id=p_mission for update;
 if m.status<>'aperta' then raise exception 'MGB_MISSION_NOT_OPEN' using errcode='55000';end if;
 perform mission_generic_owner.location_runtime(p_location,false);
 s:=mission_generic_owner.selected_plan(p_mission);
 select * into a from mission_ai_board_owner.activations where mission_id=p_mission for update;
 if found then
  if a.generic_plan_version_id is distinct from (s->>'plan_version_id')::uuid or a.location_id<>p_location or a.state<>'enrollment_open'
  then raise exception 'MGB_ACTIVATION_EXISTS' using errcode='40001';end if;
 else
  if exists(select 1 from public.mission_bookings where mission_id=p_mission and status='iscritto')
  then raise exception 'MGB_PREEXISTING_BOOKINGS' using errcode='55000';end if;
  insert into mission_ai_board_owner.activations(mission_id,package_id,generic_plan_version_id,location_id,mission_seal_sha256,state)
  values(p_mission,null,(s->>'plan_version_id')::uuid,p_location,s#>>'{settings,source_mission_sha256}','enrollment_open') returning * into a;
 end if;
 return mission_ai_board_owner.receipt(p_request,'generic_open','staff',auth.uid(),a.id,fp,
  jsonb_build_object('mission_id',p_mission,'state',a.state,'control_version',a.control_version));
end;
$fn$;

create function public.mission_generic_board_join_v1(p_mission uuid,p_request uuid)
returns jsonb language plpgsql security definer set search_path='' as $fn$
declare cid uuid;a mission_ai_board_owner.activations;fp text;r jsonb;
begin
 if auth.uid() is null then raise exception 'MGB_AUTH_REQUIRED' using errcode='42501';end if;
 perform mission_ai_board_owner.lock_request(p_request);
 select id into strict cid from public.characters where user_id=auth.uid();
 fp:=mission_internal.fingerprint(jsonb_build_object('mission',p_mission,'character',cid));
 r:=mission_ai_board_owner.replay(p_request,'generic_join',fp);if r is not null then return r;end if;
 perform 1 from public.missions where id=p_mission for update;
 select * into strict a from mission_ai_board_owner.activations where mission_id=p_mission and generic_plan_version_id is not null for update;
 if a.state<>'enrollment_open' then raise exception 'MGB_ENROLLMENT_CLOSED' using errcode='55000';end if;
 perform mission_generic_owner.location_runtime(a.location_id,false);
 if not exists(select 1 from public.mission_bookings where mission_id=p_mission and character_id=cid and status='iscritto') then
  perform public.missione_iscrivi(p_mission,null,null);
 end if;
 select * into strict a from mission_ai_board_owner.activations where id=a.id;
 return mission_ai_board_owner.receipt(p_request,'generic_join','participant',auth.uid(),a.id,fp,
  jsonb_build_object('mission_id',p_mission,'state','joined','control_version',a.control_version));
end;
$fn$;

create function mission_generic_owner.prepare_start(p_activation uuid,p_roster uuid[],p_request uuid,p_fingerprint text,p_simulation boolean)
returns jsonb language plpgsql security definer set search_path='' as $fn$
declare a mission_ai_board_owner.activations;m public.missions;selected jsonb;pv public.mission_plan_versions;
 old mission_generic_owner.board_starts;sid uuid:=gen_random_uuid();eid uuid:=gen_random_uuid();rid uuid:=gen_random_uuid();cap uuid;
 roster_sha text;ctx text;arena jsonb;snap jsonb;result jsonb;lim int;wk date:=date_trunc('week',current_date)::date;
 pol mission_generic_owner.runtime_policy;cid uuid;
begin
 select * into strict a from mission_ai_board_owner.activations where id=p_activation;
 select * into strict m from public.missions where id=a.mission_id for update;
 select * into strict a from mission_ai_board_owner.activations where id=p_activation for update;
 select * into old from mission_generic_owner.board_starts where request_key=p_request;
 if found then
  if old.activation_id<>p_activation or old.request_fingerprint<>p_fingerprint or old.simulation<>p_simulation
  then raise exception 'MGB_START_REQUEST_CONFLICT' using errcode='40001';end if;
  return old.result;
 end if;
 if a.generic_plan_version_id is null or a.state<>'enrollment_open' or auth.uid() is null
 or p_roster is null or cardinality(p_roster)=0 or array_position(p_roster,null) is not null
 or (select count(distinct x) from unnest(p_roster)x)<>cardinality(p_roster)
 then raise exception 'MGB_START_INPUT' using errcode='22023';end if;
 perform mission_generic_owner.location_runtime(a.location_id,p_simulation);
 if p_simulation and not exists(select 1 from mission_generic_owner.simulation_sources where carrier_mission_id=m.id)
 then raise exception 'MGB_SIMULATION_CARRIER_REQUIRED' using errcode='42501';end if;
 if not p_simulation and m.status<>'aperta' then raise exception 'MGB_MISSION_NOT_OPEN' using errcode='55000';end if;
 selected:=mission_generic_owner.selected_plan(m.id);
 if (selected->>'plan_version_id')::uuid<>a.generic_plan_version_id
 or selected#>>'{settings,source_mission_sha256}'<>a.mission_seal_sha256
 or cardinality(p_roster) not between (selected#>>'{settings,team_min}')::int and (selected#>>'{settings,team_max}')::int
 then raise exception 'MGB_START_PLAN_ROSTER' using errcode='40001';end if;
 select * into strict pv from public.mission_plan_versions where id=a.generic_plan_version_id and stato='approvata' for share;
 select * into strict pol from mission_generic_owner.runtime_policy where singleton for share;
 if pol.provider_max_calls is null or pol.provider_max_cost_usd is null then raise exception 'MGB_PROVIDER_BUDGET_REQUIRED' using errcode='55000';end if;
 perform 1 from public.locations where id=a.location_id for update;
 if exists(select 1 from public.master_v2_sessions where location_id=a.location_id and closed_at is null)
 then raise exception 'MGB_LOCATION_BUSY' using errcode='40001';end if;
 perform pg_advisory_xact_lock(hashtextextended(x::text,203)) from unnest(p_roster)x order by x;
 perform 1 from public.characters where id=any(p_roster) order by id for share;
 if (select count(*) from public.characters where id=any(p_roster) and not archived and user_id is not null)<>cardinality(p_roster)
 then raise exception 'MGB_ROSTER_INELIGIBLE' using errcode='42501';end if;
 if p_simulation then perform mission_generic_owner.staff_roster_assert(a.location_id,p_roster);end if;
 if not p_simulation and exists(select 1 from public.characters where id=any(p_roster)
  and (coalesce(rank,'Deshi')='Deshi' or public._grado_ord(m.grado)>public._grado_max_rank(rank) or coalesce(lealta,50)<=20))
 then raise exception 'MGB_ROSTER_INELIGIBLE' using errcode='42501';end if;
 if exists(select 1 from mission_ai_board_owner.roster_reservations where character_id=any(p_roster) and state='active')
 or exists(select 1 from public.master_v2_participants p join public.master_v2_sessions s on s.id=p.session_id
  where p.character_id=any(p_roster) and p.left_at is null and s.closed_at is null)
 then raise exception 'MGB_ROSTER_BUSY' using errcode='40001';end if;
 if not p_simulation then
  select weekly_limit into strict lim from mission_ai_board_owner.weekly_policy where singleton for share;
  if exists(select 1 from unnest(p_roster)x where (select count(*) from mission_ai_board_owner.weekly_quota q
   where q.character_id=x and q.week_key=wk and q.state in('reserved','consumed'))>=lim)
  then raise exception 'MGB_WEEKLY_LIMIT' using errcode='40001';end if;
 end if;
 -- Claim is private and bound to this transaction/backend. Combat entry guards
 -- must validate it during INSERT, before FK-backed capability/snapshot exist.
 insert into mission_generic_owner.start_claims(session_id,mission_id,location_id,definition_id,request_key,actor_user_id,
  transaction_id,backend_pid,simulation,state)
 values(sid,m.id,a.location_id,(selected->>'definition_id')::uuid,p_request,auth.uid(),txid_current(),pg_backend_pid(),p_simulation,'authorizing');
 insert into public.master_v2_sessions(id,location_id,tipo,stato,master_user,owner_kind,control_version,mission_id,titolo,quest_kind)
 values(sid,a.location_id,'quest','preparazione',null,'ai_service',1,m.id,m.title,null);
 insert into mission_ai_service_owner.capabilities(start_request_key,master_session_id,authority_receipt_sha256,expected_control_version,state,board_activation_id)
 values(p_request,sid,mission_internal.fingerprint(jsonb_build_object('schema_version','mission-generic-capability/1','session',sid,'activation',a.id,'request',p_request)),1,'active',a.id)
 returning id into cap;
 arena:=mission_generic_owner.arena_source(m.id,a.location_id);
 perform mission_generic_owner.attach(sid,(selected->>'definition_id')::uuid,arena);
 insert into public.master_v2_participants(session_id,character_id,user_id_snapshot,engagement_state)
 select sid,c.id,c.user_id,'attivo' from unnest(p_roster) with ordinality x(id,ord) join public.characters c on c.id=x.id order by x.ord;
 insert into mission_ai_board_owner.roster_reservations(activation_id,character_id,state) select a.id,x,'active' from unnest(p_roster)x;
 if not p_simulation then
  insert into mission_ai_board_owner.weekly_quota(activation_id,character_id,week_key,state) select a.id,x,wk,'reserved' from unnest(p_roster)x;
 end if;
 insert into mission_ai_board_owner.applicants(activation_id,character_id,decision,ready,ordinal,ready_at,decided_at)
 select a.id,x.id,'started',true,x.ord::smallint,clock_timestamp(),clock_timestamp() from unnest(p_roster) with ordinality x(id,ord)
 on conflict(activation_id,character_id) do update set decision='started',ready=true,ordinal=excluded.ordinal,decided_at=excluded.decided_at;
 roster_sha:=mission_internal.fingerprint(to_jsonb(p_roster));
 insert into public.mission_run_state(master_session_id,mission_id,plan_id,plan_version_id,plan_version,plan_sha256,current_step_key,run_phase,control_version)
 values(sid,m.id,pv.plan_id,pv.id,pv.versione,pv.plan_sha256,pv.initial_step_key,'preparazione',1);
 ctx:=mission_internal.fingerprint(jsonb_build_object('schema_version','mission-context/1.0','master_session_id',sid::text,
  'event_id',eid::text,'plan_id',pv.plan_id::text,'plan_version_id',pv.id::text,'step_key',pv.initial_step_key,'event_version_after',1));
 result:=jsonb_build_object('schema_version','mission-generic-start/1','mission_id',m.id,'master_session_id',sid,
  'start_receipt_id',rid,'event_id',eid,'context_fingerprint',ctx,'step',pv.initial_step_key,'master_control_version',1,'run_control_version',1,'opening_pending',true,'simulation',p_simulation);
 insert into public.mission_run_events(id,master_session_id,operation_kind,request_key_sha256,request_fingerprint,status,
  plan_version_id,step_after,version_after,context_fingerprint,result)
 values(eid,sid,'bind',mission_internal.request_key_sha256(p_request),p_fingerprint,'committed',pv.id,pv.initial_step_key,1,ctx,result);
 update public.mission_run_state set last_event_id=eid where master_session_id=sid;
 insert into public.mission_run_outbox(event_id,master_session_id,surface_kind,event_version_after,step_key,context_fingerprint)
 values(eid,sid,'mission_narrative',1,pv.initial_step_key,ctx);
 snap:=jsonb_build_object('schema_version','mission-generic-opening-source/1','mission_id',m.id,'location_id',a.location_id,
  'selection',selected,'arena',arena,'roster_sha256',roster_sha,'roster',to_jsonb(p_roster),
  'title',m.title,'briefing',m.briefing,'initial_step',pv.initial_step_key,'simulation',p_simulation);
 insert into mission_generic_owner.board_starts(id,master_session_id,activation_id,capability_id,request_key,request_fingerprint,event_id,
  snapshot,snapshot_sha256,simulation,state,result)
 values(rid,sid,a.id,cap,p_request,p_fingerprint,eid,snap,mission_internal.fingerprint(snap),p_simulation,'prepared',result);
 update mission_ai_board_owner.activations set state='start_reserved',roster_sha256=roster_sha,all_ready=true,
  current_session_id=sid,frozen_at=clock_timestamp(),control_version=control_version+1 where id=a.id;
 update mission_generic_owner.start_claims set state='bound' where session_id=sid;
 perform mission_generic_owner.dispatch_admit(sid,pol.provider_max_calls,pol.provider_max_cost_usd);
 perform mission_generic_owner.enqueue_opening(sid,rid);
 return result;
end;
$fn$;

create function public.mission_generic_board_start_v1(p_mission uuid,p_expected_version bigint,p_request uuid)
returns jsonb language plpgsql security definer set search_path='' as $fn$
declare cid uuid;a mission_ai_board_owner.activations;ids uuid[];fp text;r jsonb;
begin
 if auth.uid() is null then raise exception 'MGB_AUTH_REQUIRED' using errcode='42501';end if;
 perform mission_ai_board_owner.lock_request(p_request);
 select id into strict cid from public.characters where user_id=auth.uid();
 fp:=mission_internal.fingerprint(jsonb_build_object('mission',p_mission,'character',cid,'version',p_expected_version));
 r:=mission_ai_board_owner.replay(p_request,'generic_start',fp);if r is not null then return r;end if;
 perform 1 from public.missions where id=p_mission for update;
 perform 1 from public.mission_bookings where mission_id=p_mission and status='iscritto' order by character_id for update;
 select * into strict a from mission_ai_board_owner.activations where mission_id=p_mission and generic_plan_version_id is not null for update;
 if a.control_version<>p_expected_version or a.state<>'enrollment_open' then raise exception 'MGB_START_CAS' using errcode='40001';end if;
 select array_agg(b.character_id order by b.created_at,b.character_id) into ids from public.mission_bookings b where b.mission_id=p_mission and b.status='iscritto';
 if ids is null or not(cid=any(ids)) then raise exception 'MGB_NOT_JOINED' using errcode='42501';end if;
 if exists(select 1 from unnest(ids)x left join mission_ai_board_owner.applicants ap on ap.activation_id=a.id and ap.character_id=x
  where not coalesce(ap.ready,false) or ap.decision is distinct from 'joined')
 then raise exception 'MGB_NOT_ALL_READY' using errcode='55000';end if;
 r:=mission_generic_owner.prepare_start(a.id,ids,p_request,fp,false);
 return mission_ai_board_owner.receipt(p_request,'generic_start','participant',auth.uid(),a.id,fp,r);
end;
$fn$;

create function mission_generic_owner.opening_published(p_session uuid,p_publication uuid)
returns void language plpgsql security definer set search_path='' as $fn$
declare s mission_generic_owner.board_starts;r public.mission_run_state;m public.master_v2_sessions;
begin
 select * into strict m from public.master_v2_sessions where id=p_session for update;
 select * into strict r from public.mission_run_state where master_session_id=p_session for update;
 select * into strict s from mission_generic_owner.board_starts where master_session_id=p_session for update;
 if not exists(select 1 from public.mission_run_outbox o where o.event_id=s.event_id and o.master_session_id=p_session
  and o.publication_id=p_publication and o.state='published' and o.event_version_after=1)
 then raise exception 'MGB_OPENING_NOT_PUBLISHED' using errcode='40001';end if;
 if s.state='published' then return;end if;
 if s.state<>'prepared' or m.stato<>'preparazione' or r.run_phase<>'preparazione' or m.control_version<>1 or r.control_version<>1
 then raise exception 'MGB_OPENING_STATE_DRIFT' using errcode='40001';end if;
 update public.master_v2_sessions set stato='in_corso',control_version=2 where id=p_session;
 update public.mission_run_state set run_phase='in_corso',updated_at=clock_timestamp() where master_session_id=p_session;
 update mission_ai_service_owner.capabilities set expected_control_version=2 where id=s.capability_id and state='active';
 if not found then raise exception 'MGB_OPENING_CAPABILITY_DRIFT' using errcode='40001';end if;
 if not s.simulation then
  update mission_ai_board_owner.weekly_quota set state='consumed',consumed_at=clock_timestamp()
   where activation_id=s.activation_id and state='reserved';
  update public.missions set status='programmata',master_id=null where id=m.mission_id;
 end if;
 update mission_ai_board_owner.activations set state='started',started_at=clock_timestamp(),control_version=control_version+1 where id=s.activation_id;
 update mission_generic_owner.board_starts set state='published',published_at=clock_timestamp() where id=s.id;
end;
$fn$;

-- Protected Staff Test Room starts reuse the native scene and preserve original mission history.
create function public.mission_generic_staff_test_start_v1(p_source_mission uuid,p_location uuid,p_roster uuid[],p_request uuid)
returns jsonb language plpgsql security definer set search_path='' as $fn$
declare src public.missions;sel jsonb;arena jsonb;doc jsonb;sealed jsonb;def jsonb;
 carrier uuid:=gen_random_uuid();aid uuid;fp text;r jsonb;old mission_generic_owner.simulation_sources;sha text;
begin
 perform mission_ai_board_owner.staff_only();perform mission_ai_board_owner.lock_request(p_request);
 fp:=mission_internal.fingerprint(jsonb_build_object('source_mission',p_source_mission,'location',p_location,'roster',to_jsonb(p_roster)));
 select * into old from mission_generic_owner.simulation_sources where request_key=p_request;
 if found then
  if old.request_fingerprint<>fp then raise exception 'MGB_TEST_REQUEST_CONFLICT' using errcode='40001';end if;
  select s.result into strict r from mission_generic_owner.board_starts s join public.master_v2_sessions m on m.id=s.master_session_id
   where m.mission_id=old.carrier_mission_id;
  return r||jsonb_build_object('source_mission_id',old.source_mission_id,'replay',true);
 end if;
 perform mission_generic_owner.location_runtime(p_location,true);
 select * into strict src from public.missions where id=p_source_mission for share;
 if exists(select 1 from mission_generic_owner.simulation_sources where carrier_mission_id=src.id)
 then raise exception 'MGB_TEST_SOURCE_MUST_BE_ORIGINAL' using errcode='22023';end if;
 -- Validate all principals before creating even the carrier/pinned copy.
 perform mission_generic_owner.staff_roster_assert(p_location,p_roster);
 sel:=mission_generic_owner.historical_plan(src.id);
 select definition into strict def from mission_generic_owner.definitions where id=(sel->>'definition_id')::uuid;
 arena:=mission_generic_owner.arena_source(src.id,p_location);
 insert into public.missions(id,title,village,grado,briefing,tag_trama,xp_reward,ryo_reward,team_min,team_max,location_hint,status,created_by)
 values(carrier,'Prova · '||src.title,src.village,src.grado,src.briefing,src.tag_trama,0,0,src.team_min,src.team_max,src.location_hint,'annullata',auth.uid());
 doc:=jsonb_build_object('schema_version','mission-generic-plan-document/1','base_plan_version_id',null,
  'initial_step_key',(select initial_step_key from public.mission_plan_versions where id=(sel->>'plan_version_id')::uuid),
  'steps',(select jsonb_agg(jsonb_build_object('step_key',step_key,'kind',kind,'public_objective',public_objective) order by ordinal)
   from public.mission_plan_steps where plan_version_id=(sel->>'plan_version_id')::uuid),
  'transitions',(select coalesce(jsonb_agg(jsonb_build_object('transition_key',transition_key,'from_step_key',from_step_key,'to_step_key',to_step_key,'event_kind',event_kind,'priority',priority) order by transition_key),'[]'::jsonb)
   from public.mission_plan_transitions where plan_version_id=(sel->>'plan_version_id')::uuid),
  'definition',def,'terminal_steps',sel#>'{settings,terminal_steps}');
 sha:=mission_internal.fingerprint(mission_generic_owner.mission_editor_snapshot(carrier));
 sealed:=public.mission_generic_plan_seal_v1(carrier,gen_random_uuid(),sha,doc);
 perform public.mission_generic_plan_select_v1(carrier,(sealed->>'plan_version_id')::uuid,0,gen_random_uuid());
 insert into mission_generic_owner.simulation_sources(carrier_mission_id,source_mission_id,source_plan_version_id,source_sha256,request_key,request_fingerprint)
 values(carrier,src.id,(sel->>'plan_version_id')::uuid,mission_internal.fingerprint(sel),p_request,fp);
 perform public.universal_arena_configure_v1('mission',carrier,arena->>'template_key',(arena->>'template_version')::integer,arena->>'zone_key',0);
 insert into mission_ai_board_owner.activations(mission_id,package_id,generic_plan_version_id,location_id,mission_seal_sha256,state)
 values(carrier,null,(sealed->>'plan_version_id')::uuid,p_location,sha,'enrollment_open') returning id into aid;
 r:=mission_generic_owner.prepare_start(aid,p_roster,p_request,fp,true);
 return r||jsonb_build_object('source_mission_id',src.id,'replay',false);
end;
$fn$;

create function public.mission_generic_board_state_v1(p_mission uuid default null)
returns jsonb language plpgsql stable security definer set search_path='' as $fn$
declare cid uuid;items jsonb;
begin
 if auth.uid() is null then raise exception 'MGB_AUTH_REQUIRED' using errcode='42501';end if;
 select id into cid from public.characters where user_id=auth.uid();
 select coalesce(jsonb_agg(jsonb_build_object(
  'mission_id',q.mission_id,'title',q.title,'activation_id',q.id,'location_id',q.location_id,
  'state',q.state,'control_version',q.control_version,'master_session_id',q.current_session_id,
  'team_min',q.team_min,'team_max',q.team_max,'participants',q.participants,'joined',q.joined,'ready',q.ready,
  'all_ready',q.ready_count=q.participants and q.participants>0,
  'available',q.available,
  'can_join',q.available and not q.joined and q.participants<q.team_max,
  'can_start',q.available and q.joined and q.ready_count=q.participants and q.participants between q.team_min and q.team_max
 ) order by q.title,q.mission_id),'[]'::jsonb) into items from (
  select a.*,m.title,m.team_min,m.team_max,
   (select count(*) from mission_ai_board_owner.applicants ap where ap.activation_id=a.id and ap.decision in('joined','started')) participants,
   (select count(*) from mission_ai_board_owner.applicants ap where ap.activation_id=a.id and ap.decision in('joined','started') and ap.ready) ready_count,
   exists(select 1 from mission_ai_board_owner.applicants ap where ap.activation_id=a.id and ap.character_id=cid and ap.decision in('joined','started')) joined,
   exists(select 1 from mission_ai_board_owner.applicants ap where ap.activation_id=a.id and ap.character_id=cid and ap.decision in('joined','started') and ap.ready) ready,
   (a.state='enrollment_open' and m.status='aperta' and l.is_active and not coalesce(l.is_test,false)
    and not coalesce(l.is_exam_room,false) and rp.mode='all' and rp.provider_max_calls is not null and rp.provider_max_cost_usd is not null
    and ps.plan_version_id=a.generic_plan_version_id and pr.source_mission_sha256=mission_internal.fingerprint(mission_generic_owner.mission_editor_snapshot(m.id))) available
  from mission_ai_board_owner.activations a join public.missions m on m.id=a.mission_id
  join public.locations l on l.id=a.location_id join mission_generic_owner.plan_revisions pr on pr.plan_version_id=a.generic_plan_version_id
  join mission_generic_owner.plan_selections ps on ps.mission_id=m.id cross join mission_generic_owner.runtime_policy rp
  where rp.singleton and a.generic_plan_version_id is not null and (p_mission is null or m.id=p_mission)
   and not exists(select 1 from mission_generic_owner.simulation_sources ss where ss.carrier_mission_id=m.id)
 ) q;
 return jsonb_build_object('schema_version','mission-generic-board-state/1','missions',items);
end;
$fn$;

revoke all on function mission_generic_owner.staff_roster_assert(uuid,uuid[]) from public,anon,authenticated,service_role;
revoke all on function mission_generic_owner.booking_terminal_assert(uuid,uuid,text) from public,anon,authenticated,service_role;
revoke all on function mission_generic_owner.location_runtime(uuid,boolean) from public,anon,authenticated,service_role;
revoke all on function mission_generic_owner.arena_source(uuid,uuid) from public,anon,authenticated,service_role;
revoke all on function mission_generic_owner.booking_assert(uuid,uuid,text,text,text) from public,anon,authenticated,service_role;
revoke all on function mission_generic_owner.prepare_start(uuid,uuid[],uuid,text,boolean) from public,anon,authenticated,service_role;
revoke all on function mission_generic_owner.opening_published(uuid,uuid) from public,anon,authenticated,service_role;
revoke all on function public.mission_generic_board_open_v1(uuid,uuid,uuid) from public,anon,authenticated,service_role;
revoke all on function public.mission_generic_board_join_v1(uuid,uuid) from public,anon,authenticated,service_role;
revoke all on function public.mission_generic_board_start_v1(uuid,bigint,uuid) from public,anon,authenticated,service_role;
revoke all on function public.mission_generic_staff_test_start_v1(uuid,uuid,uuid[],uuid) from public,anon,authenticated,service_role;
revoke all on function public.mission_generic_board_state_v1(uuid) from public,anon,authenticated,service_role;
grant execute on function public.mission_generic_board_open_v1(uuid,uuid,uuid) to authenticated;
grant execute on function public.mission_generic_board_join_v1(uuid,uuid) to authenticated;
grant execute on function public.mission_generic_board_start_v1(uuid,bigint,uuid) to authenticated;
grant execute on function public.mission_generic_staff_test_start_v1(uuid,uuid,uuid[],uuid) to authenticated;
grant execute on function public.mission_generic_board_state_v1(uuid) to authenticated;
commit;
