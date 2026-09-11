-- MISSION-GENERIC-PLAN-WRITER/1 · candidate, after MISSION_GENERIC_DB.sql.
-- Editorial operations only. No Board start, enable, gameplay or legacy rewrites.
begin;

create table mission_generic_owner.plan_revisions (
 plan_version_id uuid primary key references public.mission_plan_versions(id),
 definition_id uuid not null unique references mission_generic_owner.definitions(id),
 mission_id uuid not null references public.missions(id),
 request_key uuid not null unique,
 request_fingerprint text not null check(request_fingerprint~'^[0-9a-f]{64}$'),
 source_mission_sha256 text not null check(source_mission_sha256~'^[0-9a-f]{64}$'),
 settings jsonb not null check(jsonb_typeof(settings)='object'),
 settings_sha256 text not null check(settings_sha256~'^[0-9a-f]{64}$'),
 result jsonb not null check(jsonb_typeof(result)='object'),
 created_at timestamptz not null default clock_timestamp()
);
create table mission_generic_owner.plan_selections (
 mission_id uuid primary key references public.missions(id),
 plan_version_id uuid not null references mission_generic_owner.plan_revisions(plan_version_id),
 control_version bigint not null default 1 check(control_version>0),
 selected_at timestamptz not null default clock_timestamp()
);
create table mission_generic_owner.plan_selection_receipts (
 mission_id uuid not null references public.missions(id),
 request_key uuid not null,
 request_fingerprint text not null check(request_fingerprint~'^[0-9a-f]{64}$'),
 result jsonb not null check(jsonb_typeof(result)='object'),
 created_at timestamptz not null default clock_timestamp(),
 primary key(mission_id,request_key)
);
alter table mission_generic_owner.plan_revisions enable row level security;
alter table mission_generic_owner.plan_selections enable row level security;
alter table mission_generic_owner.plan_selection_receipts enable row level security;
revoke all on mission_generic_owner.plan_revisions,mission_generic_owner.plan_selections,mission_generic_owner.plan_selection_receipts
 from public,anon,authenticated,service_role;
create trigger mission_generic_plan_revision_immutable before update or delete on mission_generic_owner.plan_revisions
 for each row execute function mission_generic_owner.immutable();
create trigger mission_generic_plan_selection_receipt_immutable before update or delete on mission_generic_owner.plan_selection_receipts
 for each row execute function mission_generic_owner.immutable();

create function mission_generic_owner.mission_editor_snapshot(p_mission uuid)
returns jsonb language sql stable security definer set search_path='' as $fn$
 select jsonb_build_object('mission_id',m.id,'title',m.title,'grado',m.grado,'team_min',m.team_min,
  'team_max',m.team_max,'xp_reward',m.xp_reward,'ryo_reward',m.ryo_reward,'status',m.status,
  'briefing',m.briefing,'village',m.village,'tag_trama',m.tag_trama,'location_hint',m.location_hint)
 from public.missions m where m.id=p_mission
$fn$;

create function public.mission_generic_plan_catalog_v1(p_mission uuid)
returns jsonb language plpgsql stable security definer set search_path='' as $fn$
declare m jsonb;versions jsonb;sel mission_generic_owner.plan_selections;
begin
 perform mission_ai_board_owner.staff_only();
 m:=mission_generic_owner.mission_editor_snapshot(p_mission);
 if m is null then raise exception 'MGP_MISSION_NOT_FOUND' using errcode='22023';end if;
 select * into sel from mission_generic_owner.plan_selections where mission_id=p_mission;
 select coalesce(jsonb_agg(jsonb_build_object('plan_version_id',v.id,'plan_id',v.plan_id,'version',v.versione,
  'state',v.stato,'plan_sha256',v.plan_sha256,'definition_id',r.definition_id,'settings',r.settings,
  'generic_ready',r.plan_version_id is not null) order by v.created_at desc,v.id),'[]'::jsonb)
 into versions from public.mission_plan_versions v join public.mission_plans p on p.id=v.plan_id
 left join mission_generic_owner.plan_revisions r on r.plan_version_id=v.id where p.mission_id=p_mission;
 return jsonb_build_object('schema_version','mission-generic-plan-catalog/1','encounter_options',jsonb_build_object('per_step',1,'npc_min',1,'npc_max',12,'opposing_npc_required',true,'mission_pvp',false),'mission',m,
  'mission_sha256',mission_internal.fingerprint(m),'versions',versions,'selected_plan_version_id',sel.plan_version_id,
  'selection_control_version',coalesce(sel.control_version,0));
end;
$fn$;

-- Document is supplied by an authenticated staff editor. Requirement authority,
-- ordinal and hashes are produced by server; client never supplies evidence.
create function public.mission_generic_plan_seal_v1(p_mission uuid,p_request uuid,p_expected_mission_sha256 text,p_document jsonb)
returns jsonb language plpgsql security definer set search_path='' as $fn$
declare m public.missions;ms jsonb;fp text;old mission_generic_owner.plan_revisions;
 base public.mission_plan_versions;pid uuid;vid uuid:=gen_random_uuid();ver bigint;s jsonb;t jsonb;trg jsonb;
 kind text;ord bigint;sha text;sealed jsonb;settings jsonb;res jsonb;terminal_count int;did uuid;
begin
 perform mission_ai_board_owner.staff_only();
 if p_request is null or coalesce(p_expected_mission_sha256,'')!~'^[0-9a-f]{64}$'
 or not mission_generic_owner.keys_valid(p_document,array['schema_version','base_plan_version_id','initial_step_key','steps','transitions','definition','terminal_steps'])
 or p_document->>'schema_version' is distinct from 'mission-generic-plan-document/1'
 or jsonb_typeof(p_document->'steps') is distinct from 'array'
 or jsonb_typeof(p_document->'transitions') is distinct from 'array'
 or jsonb_typeof(p_document->'terminal_steps') is distinct from 'array'
 or coalesce(p_document->>'initial_step_key','')!~'^[a-z][a-z0-9_]{0,63}$'
 then raise exception 'MGP_DOCUMENT_INVALID' using errcode='22023';end if;
 fp:=mission_internal.fingerprint(jsonb_build_object('mission',p_mission,'request',p_request,
  'expected_mission_sha256',p_expected_mission_sha256,'document',p_document));
 select * into strict m from public.missions where id=p_mission for update;
 select * into old from mission_generic_owner.plan_revisions where request_key=p_request;
 if found then
  if old.mission_id<>p_mission or old.request_fingerprint<>fp then raise exception 'MGP_REQUEST_CONFLICT' using errcode='40001';end if;
  return old.result;
 end if;
 ms:=mission_generic_owner.mission_editor_snapshot(p_mission);
 if mission_internal.fingerprint(ms)<>p_expected_mission_sha256 then raise exception 'MGP_MISSION_DRIFT' using errcode='40001';end if;
 -- Mission before plan versions, matching the start adapter. Native child guard
 -- locks all version rows in UUID order, so acquire that order before children.
 perform id from public.mission_plan_versions order by id for update;
 -- Native missions CHECKs define roster limits. No new game maximum is introduced.
 if p_document->>'base_plan_version_id' is null then
  pid:=gen_random_uuid();ver:=1;
  insert into public.mission_plans(id,mission_id,stato) values(pid,p_mission,'bozza');
 else
  select v.* into strict base from public.mission_plan_versions v join public.mission_plans p on p.id=v.plan_id
   where v.id=(p_document->>'base_plan_version_id')::uuid and p.mission_id=p_mission and v.stato='approvata';
  pid:=base.plan_id;
  select coalesce(max(versione),0)+1 into ver from public.mission_plan_versions where plan_id=pid;
  if base.versione<>ver-1 then raise exception 'MGP_BASE_VERSION_STALE' using errcode='40001';end if;
 end if;
 insert into public.mission_plan_versions(id,plan_id,versione,stato,initial_step_key)
  values(vid,pid,ver,'bozza',p_document->>'initial_step_key');
 for s,ord in select value,ordinality from jsonb_array_elements(p_document->'steps') with ordinality loop
  if not mission_generic_owner.keys_valid(s,array['step_key','kind','public_objective'])
  then raise exception 'MGP_STEP_INVALID' using errcode='22023';end if;
  insert into public.mission_plan_steps(plan_version_id,step_key,kind,public_objective,ordinal)
   values(vid,s->>'step_key',s->>'kind',s->>'public_objective',ord::int);
 end loop;
 if not exists(select 1 from public.mission_plan_steps where plan_version_id=vid and step_key=p_document->>'initial_step_key')
 then raise exception 'MGP_INITIAL_STEP_MISSING' using errcode='22023';end if;
 for t in select value from jsonb_array_elements(p_document->'transitions') loop
  if not mission_generic_owner.keys_valid(t,array['transition_key','from_step_key','to_step_key','event_kind','priority'])
  or jsonb_typeof(t->'priority') is distinct from 'number' or (t->>'priority')::numeric<>trunc((t->>'priority')::numeric)
  then raise exception 'MGP_TRANSITION_INVALID' using errcode='22023';end if;
  insert into public.mission_plan_transitions(plan_version_id,transition_key,from_step_key,to_step_key,event_kind,priority)
   values(vid,t->>'transition_key',t->>'from_step_key',t->>'to_step_key',t->>'event_kind',(t->>'priority')::int);
  select st.kind into strict kind from public.mission_plan_steps st where st.plan_version_id=vid and st.step_key=t->>'from_step_key';
  select tr into strict trg from jsonb_array_elements(p_document#>'{definition,scenes}') sc,
   lateral jsonb_array_elements(sc->'triggers') tr where sc->>'step_key'=t->>'from_step_key' and tr->>'transition_key'=t->>'transition_key';
  insert into public.mission_plan_requirements(plan_version_id,transition_key,ordinal,step_kind,provider_owner,domain,source_kind,
   capability_key,feature_version,provider_contract_version,projection_version,fact_code,max_age_ms)
  values(vid,t->>'transition_key',1,kind,'DB-MISSION','mission','server_receipt','mission.generic.trigger.v1',
   'mission-generic/1','mission-evidence-ref/1.2',1,trg->>'fact_code',60000);
 end loop;
 -- All steps reachable from initial; all steps can reach an explicit terminal.
 -- Cycles with a route to an ending are allowed, not an accidental dead end.
 if exists(with recursive reachable(k) as (
   select p_document->>'initial_step_key'
   union select t.to_step_key from public.mission_plan_transitions t join reachable r on r.k=t.from_step_key where t.plan_version_id=vid)
   select 1 from public.mission_plan_steps st where st.plan_version_id=vid and st.step_key not in(select k from reachable))
 then raise exception 'MGP_UNREACHABLE_STEP' using errcode='22023';end if;
 terminal_count:=jsonb_array_length(p_document->'terminal_steps');
 if terminal_count=0 or exists(select 1 from jsonb_array_elements(p_document->'terminal_steps') x group by x->>'step_key' having count(*)>1)
 then raise exception 'MGP_TERMINALS_INVALID' using errcode='22023';end if;
 for s in select value from jsonb_array_elements(p_document->'terminal_steps') loop
  if not mission_generic_owner.keys_valid(s,array['step_key','outcome'])
  or coalesce(s->>'outcome','') not in('success','failure')
  or not exists(select 1 from public.mission_plan_steps st where st.plan_version_id=vid and st.step_key=s->>'step_key' and st.kind='narrative')
  or exists(select 1 from public.mission_plan_transitions t where t.plan_version_id=vid and t.from_step_key=s->>'step_key')
  then raise exception 'MGP_TERMINAL_INVALID' using errcode='22023';end if;
 end loop;
 if exists(with recursive can_finish(k) as (
   select x->>'step_key' from jsonb_array_elements(p_document->'terminal_steps') x
   union select t.from_step_key from public.mission_plan_transitions t join can_finish r on r.k=t.to_step_key where t.plan_version_id=vid)
   select 1 from public.mission_plan_steps st where st.plan_version_id=vid and st.step_key not in(select k from can_finish))
 then raise exception 'MGP_NO_PATH_TO_TERMINAL' using errcode='22023';end if;
 perform mission_generic_owner.validate_definition(vid,p_document->'definition');
 sha:=mission_internal.plan_fingerprint(vid);
 perform mission_internal.plan_approve(vid,sha);
 sealed:=public.mission_generic_definition_seal_v1(vid,1,p_document->'definition',sha);
 did:=(sealed->>'definition_id')::uuid;
 settings:=jsonb_build_object('schema_version','mission-generic-plan-settings/1','team_min',m.team_min,'team_max',m.team_max,
  'terminal_steps',p_document->'terminal_steps','source_mission_sha256',p_expected_mission_sha256,
  'source_mission_content_sha256',mission_internal.fingerprint(ms-'status'));
 res:=jsonb_build_object('schema_version','mission-generic-plan-seal/1','mission_id',p_mission,'plan_id',pid,
  'plan_version_id',vid,'version',ver,'plan_sha256',sha,'definition_id',did,'definition_sha256',sealed->>'definition_sha256',
  'settings_sha256',mission_internal.fingerprint(settings),'selected',false,'state','sealed');
 insert into mission_generic_owner.plan_revisions(plan_version_id,definition_id,mission_id,request_key,request_fingerprint,
  source_mission_sha256,settings,settings_sha256,result)
 values(vid,did,p_mission,p_request,fp,p_expected_mission_sha256,settings,mission_internal.fingerprint(settings),res);
 return res;
end;
$fn$;

-- Explicit editorial selection affects only future starts. Running session
-- snapshots never read this mutable pointer again. Gate mode remains unchanged.
create function public.mission_generic_plan_select_v1(p_mission uuid,p_plan_version uuid,p_expected_selection_version bigint,p_request uuid)
returns jsonb language plpgsql security definer set search_path='' as $fn$
declare sel mission_generic_owner.plan_selections;r mission_generic_owner.plan_revisions;
 old mission_generic_owner.plan_selection_receipts;fp text;res jsonb;ms jsonb;
begin
 perform mission_ai_board_owner.staff_only();
 if p_request is null or p_expected_selection_version is null or p_expected_selection_version<0 then raise exception 'MGP_SELECTION_INPUT' using errcode='22023';end if;
 select mission_generic_owner.mission_editor_snapshot(id) into strict ms from public.missions where id=p_mission for update;
 fp:=mission_internal.fingerprint(jsonb_build_object('mission',p_mission,'plan_version',p_plan_version,'expected',p_expected_selection_version));
 select * into old from mission_generic_owner.plan_selection_receipts where mission_id=p_mission and request_key=p_request;
 if found then
  if old.request_fingerprint<>fp then raise exception 'MGP_SELECTION_REQUEST_CONFLICT' using errcode='40001';end if;
  return old.result;
 end if;
 select * into strict r from mission_generic_owner.plan_revisions where plan_version_id=p_plan_version and mission_id=p_mission;
 if r.source_mission_sha256<>mission_internal.fingerprint(ms) then raise exception 'MGP_SELECTION_MISSION_DRIFT' using errcode='40001';end if;
 if mission_internal.plan_fingerprint(p_plan_version) is distinct from (select plan_sha256 from public.mission_plan_versions where id=p_plan_version and stato='approvata')
 then raise exception 'MGP_SELECTION_PLAN_DRIFT' using errcode='40001';end if;
 select * into sel from mission_generic_owner.plan_selections where mission_id=p_mission for update;
 if coalesce(sel.control_version,0)<>p_expected_selection_version then raise exception 'MGP_SELECTION_CAS' using errcode='40001';end if;
 insert into mission_generic_owner.plan_selections(mission_id,plan_version_id,control_version)
 values(p_mission,p_plan_version,1) on conflict(mission_id) do update set plan_version_id=excluded.plan_version_id,
  control_version=mission_generic_owner.plan_selections.control_version+1,selected_at=clock_timestamp()
 returning * into sel;
 res:=jsonb_build_object('schema_version','mission-generic-plan-select/1','mission_id',p_mission,
  'plan_version_id',sel.plan_version_id,'definition_id',r.definition_id,'selection_control_version',sel.control_version);
 insert into mission_generic_owner.plan_selection_receipts(mission_id,request_key,request_fingerprint,result) values(p_mission,p_request,fp,res);
 return res;
end;
$fn$;

-- Private reader used by the future-start adapter while holding the mission lock.
-- Returns only server-selected identities and pins, never a requested destination.
create function mission_generic_owner.selected_plan(p_mission uuid)
returns jsonb language plpgsql stable security definer set search_path='' as $fn$
declare s mission_generic_owner.plan_selections;r mission_generic_owner.plan_revisions;v public.mission_plan_versions;
 d mission_generic_owner.definitions;m jsonb;
begin
 select * into strict s from mission_generic_owner.plan_selections where mission_id=p_mission;
 select * into strict r from mission_generic_owner.plan_revisions where plan_version_id=s.plan_version_id and mission_id=p_mission;
 select * into strict v from public.mission_plan_versions where id=r.plan_version_id and stato='approvata';
 select * into strict d from mission_generic_owner.definitions where id=r.definition_id and plan_version_id=v.id;
 m:=mission_generic_owner.mission_editor_snapshot(p_mission);
 if r.source_mission_sha256<>mission_internal.fingerprint(m) or r.settings_sha256<>mission_internal.fingerprint(r.settings)
 or v.plan_sha256<>mission_internal.plan_fingerprint(v.id) or d.plan_sha256<>v.plan_sha256
 then raise exception 'MGP_SELECTED_PLAN_DRIFT' using errcode='40001';end if;
 return jsonb_build_object('mission_id',p_mission,'plan_id',v.plan_id,'plan_version_id',v.id,'version',v.versione,
  'plan_sha256',v.plan_sha256,'definition_id',d.id,'definition_sha256',d.definition_sha256,
  'settings',r.settings,'settings_sha256',r.settings_sha256,'selection_control_version',s.control_version);
end;
$fn$;

-- Historical replay ignores only operational mission status. All editorial content,
-- plan, definition and settings remain pinned; no original row is rewritten.
create function mission_generic_owner.historical_plan(p_mission uuid)
returns jsonb language plpgsql stable security definer set search_path='' as $fn$
declare s mission_generic_owner.plan_selections;r mission_generic_owner.plan_revisions;v public.mission_plan_versions;
 d mission_generic_owner.definitions;m jsonb;
begin
 select * into strict s from mission_generic_owner.plan_selections where mission_id=p_mission;
 select * into strict r from mission_generic_owner.plan_revisions where plan_version_id=s.plan_version_id and mission_id=p_mission;
 select * into strict v from public.mission_plan_versions where id=r.plan_version_id and stato='approvata';
 select * into strict d from mission_generic_owner.definitions where id=r.definition_id and plan_version_id=v.id;
 m:=mission_generic_owner.mission_editor_snapshot(p_mission);
 if r.settings->>'source_mission_content_sha256' is distinct from mission_internal.fingerprint(m-'status')
 or r.settings_sha256<>mission_internal.fingerprint(r.settings)
 or v.plan_sha256<>mission_internal.plan_fingerprint(v.id) or d.plan_sha256<>v.plan_sha256
 or d.definition_sha256<>mission_internal.fingerprint(d.definition)
 then raise exception 'MGP_SELECTED_PLAN_DRIFT' using errcode='40001';end if;
 return jsonb_build_object('mission_id',p_mission,'plan_id',v.plan_id,'plan_version_id',v.id,'version',v.versione,
  'plan_sha256',v.plan_sha256,'definition_id',d.id,'definition_sha256',d.definition_sha256,
  'settings',r.settings,'settings_sha256',r.settings_sha256,'selection_control_version',s.control_version);
end;
$fn$;

-- Runtime endings/roster read the immutable revision referenced by the attached
-- definition, never the mutable selection for the next mission start.
create function mission_generic_owner.run_plan_settings(p_session uuid)
returns jsonb language sql stable security definer set search_path='' as $fn$
 select r.settings from mission_generic_owner.run_bindings b
 join mission_generic_owner.plan_revisions r on r.definition_id=b.definition_id
 where b.master_session_id=p_session and b.snapshot_sha256=mission_internal.fingerprint(b.snapshot)
 and r.plan_version_id::text=b.snapshot->>'plan_version_id'
 and r.settings_sha256=mission_internal.fingerprint(r.settings)
$fn$;

revoke all on function mission_generic_owner.mission_editor_snapshot(uuid) from public,anon,authenticated,service_role;
revoke all on function mission_generic_owner.selected_plan(uuid) from public,anon,authenticated,service_role;
revoke all on function mission_generic_owner.historical_plan(uuid) from public,anon,authenticated,service_role;
revoke all on function mission_generic_owner.run_plan_settings(uuid) from public,anon,authenticated,service_role;
revoke all on function public.mission_generic_plan_catalog_v1(uuid) from public,anon,authenticated,service_role;
revoke all on function public.mission_generic_plan_seal_v1(uuid,uuid,text,jsonb) from public,anon,authenticated,service_role;
revoke all on function public.mission_generic_plan_select_v1(uuid,uuid,bigint,uuid) from public,anon,authenticated,service_role;
grant execute on function public.mission_generic_plan_catalog_v1(uuid) to authenticated;
grant execute on function public.mission_generic_plan_seal_v1(uuid,uuid,text,jsonb) to authenticated;
grant execute on function public.mission_generic_plan_select_v1(uuid,uuid,bigint,uuid) to authenticated;
commit;
