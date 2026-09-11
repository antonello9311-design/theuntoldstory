-- MISSION-GENERIC-DB/1 · candidate only; no database apply performed.
-- Install with the composed bridge reviewed by DB-CORE. All new runtime is OFF.
-- Existing mission_internal.transition remains the only phase controller.
begin;

create schema mission_generic_owner;
revoke all on schema mission_generic_owner from public, anon, authenticated, service_role;
alter default privileges in schema mission_generic_owner revoke execute on functions from public;

create table mission_generic_owner.runtime_policy (
  singleton boolean primary key default true check(singleton),
  mode text not null default 'off' check(mode in('off','test','all'))
);
insert into mission_generic_owner.runtime_policy(singleton) values(true);

create table mission_generic_owner.definitions (
  id uuid primary key default gen_random_uuid(),
  plan_version_id uuid not null references public.mission_plan_versions(id),
  version bigint not null check(version>0),
  definition jsonb not null check(jsonb_typeof(definition)='object'),
  definition_sha256 text not null check(definition_sha256~'^[0-9a-f]{64}$'),
  plan_sha256 text not null check(plan_sha256~'^[0-9a-f]{64}$'),
  sealed_at timestamptz not null default clock_timestamp(),
  unique(plan_version_id,version)
);
create table mission_generic_owner.run_bindings (
  master_session_id uuid primary key references public.master_v2_sessions(id),
  definition_id uuid not null references mission_generic_owner.definitions(id),
  snapshot jsonb not null check(jsonb_typeof(snapshot)='object'),
  snapshot_sha256 text not null check(snapshot_sha256~'^[0-9a-f]{64}$'),
  attached_at timestamptz not null default clock_timestamp()
);
create table mission_generic_owner.trigger_receipts (
  id uuid primary key default gen_random_uuid(),
  master_session_id uuid not null references mission_generic_owner.run_bindings(master_session_id),
  request_key uuid not null,
  request_fingerprint text not null check(request_fingerprint~'^[0-9a-f]{64}$'),
  step_key text not null,
  run_control_version bigint not null check(run_control_version>0),
  trigger_key text not null,
  source_kind text not null check(source_kind in('player_choice','combat_terminal','narrative_event','spatial_event')),
  source_ref uuid not null,
  source_sha256 text not null check(source_sha256~'^[0-9a-f]{64}$'),
  actor_character_id uuid references public.characters(id),
  issued_at timestamptz not null default clock_timestamp(),
  result jsonb not null check(jsonb_typeof(result)='object'),
  unique(master_session_id,request_key),
  unique(master_session_id,run_control_version,trigger_key,source_kind,source_ref)
);

alter table mission_generic_owner.runtime_policy enable row level security;
alter table mission_generic_owner.definitions enable row level security;
alter table mission_generic_owner.run_bindings enable row level security;
alter table mission_generic_owner.trigger_receipts enable row level security;
revoke all on all tables in schema mission_generic_owner from public,anon,authenticated,service_role;

create function mission_generic_owner.immutable() returns trigger
language plpgsql set search_path='' as $fn$
begin raise exception 'MG_IMMUTABLE' using errcode='55000'; end;
$fn$;
create trigger mission_generic_definition_immutable before update or delete on mission_generic_owner.definitions
for each row execute function mission_generic_owner.immutable();
create trigger mission_generic_binding_immutable before update or delete on mission_generic_owner.run_bindings
for each row execute function mission_generic_owner.immutable();
create trigger mission_generic_receipt_immutable before update or delete on mission_generic_owner.trigger_receipts
for each row execute function mission_generic_owner.immutable();

create function mission_generic_owner.keys_valid(p jsonb,required text[],optional text[] default '{}')
returns boolean language sql immutable set search_path='' as $fn$
select coalesce(jsonb_typeof(p)='object'
 and not exists(select 1 from unnest(required) k where not(p ? k))
 and not exists(select 1 from jsonb_object_keys(p) k where not(k=any(required||optional))),false)
$fn$;

-- Definition format is additive to approved mission_plan_*; no destinations or
-- mechanical amounts are accepted here. Approved Ninja Book IDs are pinned.
create function mission_generic_owner.validate_definition(p_plan uuid,p_definition jsonb)
returns void language plpgsql security definer set search_path='' as $fn$
declare s jsonb;e jsonb;a jsonb;t jsonb;tr public.mission_plan_transitions;
 req public.mission_plan_requirements;b public.nb_mechanical_bindings; k text;scount int;sk text;
begin
 if not mission_generic_owner.keys_valid(p_definition,array['schema_version','scenes'])
 or p_definition->>'schema_version' is distinct from 'mission-generic-definition/1'
 or jsonb_typeof(p_definition->'scenes') is distinct from 'array' then
  raise exception 'MG_DEFINITION_SHAPE' using errcode='22023';end if;
 select count(*) into scount from public.mission_plan_steps where plan_version_id=p_plan;
 if jsonb_array_length(p_definition->'scenes')<>scount or scount=0
 or exists(select 1 from jsonb_array_elements(p_definition->'scenes') x group by x->>'step_key' having count(*)>1)
 then raise exception 'MG_SCENES_COVERAGE' using errcode='22023';end if;
 for s in select value from jsonb_array_elements(p_definition->'scenes') loop
  if not mission_generic_owner.keys_valid(s,array['step_key','actors','encounters','triggers'])
  or jsonb_typeof(s->'actors') is distinct from 'array'
  or jsonb_typeof(s->'encounters') is distinct from 'array'
  or jsonb_typeof(s->'triggers') is distinct from 'array'
  or not exists(select 1 from public.mission_plan_steps where plan_version_id=p_plan and step_key=s->>'step_key')
  then raise exception 'MG_SCENE_INVALID' using errcode='22023';end if;
  if exists(select 1 from jsonb_array_elements(s->'actors') x group by x->>'actor_key' having count(*)>1)
  or exists(select 1 from jsonb_array_elements(s->'encounters') x group by x->>'encounter_key' having count(*)>1)
  or exists(select 1 from jsonb_array_elements(s->'triggers') x group by x->>'trigger_key' having count(*)>1)
  then raise exception 'MG_DUPLICATE_KEY' using errcode='22023';end if;
  select kind into strict sk from public.mission_plan_steps where plan_version_id=p_plan and step_key=s->>'step_key';
  if sk='narrative' and jsonb_array_length(s->'encounters')>0 then raise exception 'MG_ENCOUNTER_REQUIRES_MECHANICAL_STEP' using errcode='22023';end if;
  if sk='mechanical' and jsonb_array_length(s->'encounters')<>1
  then raise exception 'MG_ONE_ENCOUNTER_PER_STEP_REQUIRED' using errcode='22023';end if;
  for a in select value from jsonb_array_elements(s->'actors') loop
   if not mission_generic_owner.keys_valid(a,array['actor_key','mechanical_binding_id','team'],array['narrative_template_id','narrative_version_id'])
   or coalesce(a->>'actor_key','')!~'^[a-z][a-z0-9_]{0,63}$'
   or coalesce(a->>'team','')!~'^[a-z][a-z0-9_]{0,63}$'
   then raise exception 'MG_ACTOR_INVALID' using errcode='22023';end if;
   -- Narrative-only actors still reference a reviewed, pinned Ninja Book profile.
   if a->>'mechanical_binding_id' is not null then
    select * into b from public.nb_mechanical_bindings where id=(a->>'mechanical_binding_id')::uuid;
    if not found or b.lifecycle_state<>'approved' then raise exception 'MG_ACTOR_NOT_APPROVED' using errcode='22023';end if;
    if (a ? 'narrative_template_id' and a->>'narrative_template_id' is distinct from b.narrative_template_id::text)
    or (a ? 'narrative_version_id' and a->>'narrative_version_id' is distinct from b.narrative_version_id::text)
    then raise exception 'MG_ACTOR_NARRATIVE_SCOPE' using errcode='22023';end if;
    if not exists(select 1 from public.nb_template_versions nv join public.nb_templates nt on nt.id=nv.template_id
      join public.nb_mechanical_versions mv on mv.id=b.mechanical_version_id
      join public.nb_mechanical_templates mt on mt.id=mv.template_id
      where nv.id=b.narrative_version_id and nt.id=b.narrative_template_id and nv.review_state='approved'
      and nt.lifecycle_state='approved' and mv.review_state='approved' and mt.id=b.mechanical_template_id and mt.lifecycle_state='approved')
    then raise exception 'MG_ACTOR_PROFILE_NOT_APPROVED' using errcode='22023';end if;
   elsif not exists(select 1 from public.nb_template_versions nv join public.nb_templates nt on nt.id=nv.template_id
    where nv.id=(a->>'narrative_version_id')::uuid and nt.id=(a->>'narrative_template_id')::uuid
     and nv.review_state='approved' and nt.lifecycle_state='approved') then
    raise exception 'MG_NARRATIVE_ACTOR_NOT_APPROVED' using errcode='22023';
   end if;
  end loop;
  for e in select value from jsonb_array_elements(s->'encounters') loop
   if not mission_generic_owner.keys_valid(e,array['encounter_key','pg_policy','pg_team','actors','arena_ref'],array['zone_key'])
   or coalesce(e->>'encounter_key','')!~'^[a-z][a-z0-9_]{0,63}$'
   or e->>'pg_policy' is distinct from 'all_active'
   or coalesce(e->>'pg_team','')!~'^[a-z][a-z0-9_]{0,63}$'
   or e->>'arena_ref' is distinct from 'mission'
   or jsonb_typeof(e->'actors') is distinct from 'array'
   or (e ? 'zone_key' and coalesce(e->>'zone_key','')!~'^[a-z][a-z0-9_]{0,63}$')
   then raise exception 'MG_ENCOUNTER_INVALID' using errcode='22023';end if;
   -- Native Regia Ninja Book core admits 1..12 PNG offers; no mission PvP extension.
   if jsonb_array_length(e->'actors') not between 1 and 12
    or not exists(select 1 from jsonb_array_elements(e->'actors') x where x->>'team'<>e->>'pg_team')
   then raise exception 'MG_ENCOUNTER_OPPOSITION_REQUIRED' using errcode='22023';end if;
   if exists(select 1 from jsonb_array_elements(e->'actors') x group by x->>'actor_key' having count(*)>1)
   then raise exception 'MG_ENCOUNTER_DUPLICATE_ACTOR' using errcode='22023';end if;
   for a in select value from jsonb_array_elements(e->'actors') loop
    if a->>'mechanical_binding_id' is null or not exists(select 1 from jsonb_array_elements(s->'actors') x where x=a)
    then raise exception 'MG_ENCOUNTER_ACTOR_SCOPE' using errcode='22023';end if;
   end loop;
  end loop;
  for t in select value from jsonb_array_elements(s->'triggers') loop
   if not mission_generic_owner.keys_valid(t,array['trigger_key','transition_key','source_kind','fact_code','label'],array['encounter_key'])
   or coalesce(t->>'trigger_key','')!~'^[a-z][a-z0-9_]{0,63}$'
   or coalesce(t->>'source_kind','') not in('player_choice','combat_terminal','narrative_event','spatial_event')
   or coalesce(t->>'fact_code','')!~'^[a-z][a-z0-9_]{0,79}$'
   or char_length(btrim(coalesce(t->>'label',''))) not between 1 and 160
   then raise exception 'MG_TRIGGER_INVALID' using errcode='22023';end if;
   select * into tr from public.mission_plan_transitions where plan_version_id=p_plan
    and transition_key=t->>'transition_key' and from_step_key=s->>'step_key';
   if not found then raise exception 'MG_TRIGGER_TRANSITION_SCOPE' using errcode='22023';end if;
   -- A trigger identifies one edge. Existing controller never receives a client destination.
   if (select count(*) from public.mission_plan_transitions where plan_version_id=p_plan
    and from_step_key=tr.from_step_key and event_kind=tr.event_kind)<>1
   then raise exception 'MG_TRIGGER_EVENT_AMBIGUOUS' using errcode='22023';end if;
   if (select count(*) from public.mission_plan_requirements where plan_version_id=p_plan and transition_key=tr.transition_key)<>1
   then raise exception 'MG_TRIGGER_REQUIREMENT_COUNT' using errcode='22023';end if;
   select * into strict req from public.mission_plan_requirements where plan_version_id=p_plan and transition_key=tr.transition_key;
   if req.ordinal<>1 or req.provider_owner<>'DB-MISSION' or req.domain<>'mission'
    or req.source_kind<>'server_receipt' or req.capability_key<>'mission.generic.trigger.v1'
    or req.feature_version<>'mission-generic/1' or req.provider_contract_version<>'mission-evidence-ref/1.2'
    or req.projection_version<>1 or req.fact_code is distinct from t->>'fact_code'
   then raise exception 'MG_TRIGGER_REQUIREMENT_CONTRACT' using errcode='22023';end if;
   if t->>'source_kind' in('combat_terminal','spatial_event') then
    if sk<>'mechanical' then raise exception 'MG_MECHANICAL_TRIGGER_STEP' using errcode='22023';end if;
    if not exists(select 1 from jsonb_array_elements(s->'encounters') x where x->>'encounter_key'=t->>'encounter_key')
    then raise exception 'MG_TRIGGER_ENCOUNTER_REQUIRED' using errcode='22023';end if;
   else
    if sk<>'narrative' or t ? 'encounter_key' then raise exception 'MG_NARRATIVE_TRIGGER_STEP' using errcode='22023';end if;
    if t->>'source_kind'='player_choice' and t->>'fact_code'<>'player_choice_confirmed'
    then raise exception 'MG_CHOICE_CANNOT_ASSERT_MECHANICS' using errcode='22023';end if;
   end if;
  end loop;
 end loop;
 -- Actor identities persist across encounters; a key cannot silently change its profile.
 if exists(select 1 from jsonb_array_elements(p_definition->'scenes') s,
  lateral jsonb_array_elements(s->'actors') a group by a->>'actor_key'
  having count(distinct (a-'team'))>1)
 then raise exception 'MG_ACTOR_IDENTITY_DRIFT' using errcode='22023';end if;
end;
$fn$;

-- Editorial operation: one immutable definition/version. Does not activate a run.
create function public.mission_generic_definition_seal_v1(p_plan_version uuid,p_version bigint,p_definition jsonb,p_expected_plan_sha256 text)
returns jsonb language plpgsql security definer set search_path='' as $fn$
declare pv public.mission_plan_versions;d mission_generic_owner.definitions;sh text;
begin
 perform mission_ai_board_owner.staff_only();
 select * into strict pv from public.mission_plan_versions where id=p_plan_version for share;
 if pv.stato<>'approvata' or pv.plan_sha256 is distinct from p_expected_plan_sha256
 or mission_internal.plan_fingerprint(p_plan_version) is distinct from pv.plan_sha256
 or p_version is null or p_version<1 then raise exception 'MG_PLAN_NOT_CURRENT' using errcode='40001';end if;
 perform mission_generic_owner.validate_definition(p_plan_version,p_definition);
 sh:=mission_internal.fingerprint(p_definition);
 perform pg_advisory_xact_lock(hashtextextended(p_plan_version::text,51091));
 select * into d from mission_generic_owner.definitions where plan_version_id=p_plan_version and version=p_version;
 if found then
  if d.definition_sha256<>sh or d.plan_sha256<>pv.plan_sha256 then raise exception 'MG_DEFINITION_VERSION_CONFLICT' using errcode='40001';end if;
 else
  insert into mission_generic_owner.definitions(plan_version_id,version,definition,definition_sha256,plan_sha256)
   values(p_plan_version,p_version,p_definition,sh,pv.plan_sha256) returning * into d;
 end if;
 return jsonb_build_object('definition_id',d.id,'version',d.version,'definition_sha256',d.definition_sha256,'plan_sha256',d.plan_sha256);
end;
$fn$;

-- Private freeze entry for Board and the composed protected-start adapter.
-- p_arena is accepted only from a privileged producer that read the native catalog.
-- No external role receives EXECUTE on this helper.
create function mission_generic_owner.attach(p_session uuid,p_definition uuid,p_arena jsonb)
returns jsonb language plpgsql security definer set search_path='' as $fn$
declare m public.master_v2_sessions;d mission_generic_owner.definitions;b mission_generic_owner.run_bindings;
 snap jsonb;pins jsonb;npins jsonb;sc jsonb;e jsonb;pid uuid;existing_run public.mission_run_state;
begin
 select * into strict m from public.master_v2_sessions where id=p_session for update;
 select * into strict d from mission_generic_owner.definitions where id=p_definition;
 select * into b from mission_generic_owner.run_bindings where master_session_id=p_session;
 if found then
  if b.definition_id<>p_definition or b.snapshot->'arena' is distinct from p_arena then raise exception 'MG_ATTACH_CONFLICT' using errcode='40001';end if;
  return jsonb_build_object('master_session_id',p_session,'snapshot_sha256',b.snapshot_sha256);
 end if;
 if m.owner_kind<>'ai_service' or m.tipo<>'quest' or m.mission_id is null or m.stato<>'preparazione'
 or m.closed_at is not null then raise exception 'MG_ATTACH_BEFORE_OPENING_REQUIRED' using errcode='55000';end if;
 select plan_id into strict pid from public.mission_plan_versions where id=d.plan_version_id and stato='approvata' and plan_sha256=d.plan_sha256;
 if not exists(select 1 from public.mission_plans where id=pid and mission_id=m.mission_id)
 or mission_internal.plan_fingerprint(d.plan_version_id)<>d.plan_sha256
 then raise exception 'MG_ATTACH_PLAN_SCOPE' using errcode='40001';end if;
 select * into existing_run from public.mission_run_state where master_session_id=p_session;
 if found and (existing_run.plan_version_id<>d.plan_version_id or existing_run.run_phase<>'preparazione')
 then raise exception 'MG_ATTACH_EXISTING_RUN_CONFLICT' using errcode='40001';end if;
 if p_arena->>'schema_version' is distinct from 'mission-arena-source/1'
 or p_arena->>'mission_id' is distinct from m.mission_id::text
 or p_arena->>'location_id' is distinct from m.location_id::text
 or jsonb_typeof(p_arena->'catalog') is distinct from 'object'
 or p_arena->>'catalog_sha256' is distinct from public.combat_v2_sha256(p_arena->'catalog')
 then raise exception 'MG_ARENA_SOURCE_INVALID' using errcode='22023';end if;
 -- Lock every pinned profile before validation and snapshot reads; no editorial
 -- mutation may change approval/content between those two operations.
 perform 1 from public.nb_mechanical_bindings n where n.id in(
  select (a->>'mechanical_binding_id')::uuid from jsonb_array_elements(d.definition->'scenes') s,
  lateral jsonb_array_elements(s->'actors') a where a->>'mechanical_binding_id' is not null) order by n.id for share;
 perform 1 from public.nb_templates nt where nt.id in(
  select n.narrative_template_id from public.nb_mechanical_bindings n where n.id in(
   select (a->>'mechanical_binding_id')::uuid from jsonb_array_elements(d.definition->'scenes') s,
   lateral jsonb_array_elements(s->'actors') a where a->>'mechanical_binding_id' is not null)
  union select (a->>'narrative_template_id')::uuid from jsonb_array_elements(d.definition->'scenes') s,
   lateral jsonb_array_elements(s->'actors') a where a->>'mechanical_binding_id' is null) order by nt.id for share;
 perform 1 from public.nb_template_versions nv where nv.id in(
  select n.narrative_version_id from public.nb_mechanical_bindings n where n.id in(
   select (a->>'mechanical_binding_id')::uuid from jsonb_array_elements(d.definition->'scenes') s,
   lateral jsonb_array_elements(s->'actors') a where a->>'mechanical_binding_id' is not null)
  union select (a->>'narrative_version_id')::uuid from jsonb_array_elements(d.definition->'scenes') s,
   lateral jsonb_array_elements(s->'actors') a where a->>'mechanical_binding_id' is null) order by nv.id for share;
 perform 1 from public.nb_mechanical_templates mt where mt.id in(
  select n.mechanical_template_id from public.nb_mechanical_bindings n where n.id in(
   select (a->>'mechanical_binding_id')::uuid from jsonb_array_elements(d.definition->'scenes') s,
   lateral jsonb_array_elements(s->'actors') a where a->>'mechanical_binding_id' is not null)) order by mt.id for share;
 perform 1 from public.nb_mechanical_versions mv where mv.id in(
  select n.mechanical_version_id from public.nb_mechanical_bindings n where n.id in(
   select (a->>'mechanical_binding_id')::uuid from jsonb_array_elements(d.definition->'scenes') s,
   lateral jsonb_array_elements(s->'actors') a where a->>'mechanical_binding_id' is not null)) order by mv.id for share;
 perform mission_generic_owner.validate_definition(d.plan_version_id,d.definition);
 for sc in select value from jsonb_array_elements(d.definition->'scenes') loop
  for e in select value from jsonb_array_elements(sc->'encounters') loop
   -- Current native source exposes the whole-arena zone. Do not silently invent geometry.
   if coalesce(e->>'zone_key',p_arena->>'zone_key') is distinct from p_arena->>'zone_key'
   then raise exception 'MG_ARENA_ZONE_NOT_IN_SOURCE' using errcode='22023';end if;
  end loop;
 end loop;
 select coalesce(jsonb_agg(jsonb_build_object('mechanical_binding_id',n.id,'control_version',n.control_version,
  'narrative_template_id',n.narrative_template_id,'narrative_version_id',n.narrative_version_id,
  'mechanical_template_id',n.mechanical_template_id,'mechanical_version_id',n.mechanical_version_id,
  'narrative_template_control_version',nt.control_version,'narrative_version_control_version',nv.control_version,
  'narrative_content_sha256',nv.content_sha256,'mechanical_template_control_version',mt.control_version,
  'mechanical_version_control_version',mv.control_version,'mechanical_content_sha256',mv.content_sha256) order by n.id),'[]'::jsonb)
 into pins from public.nb_mechanical_bindings n
 join public.nb_templates nt on nt.id=n.narrative_template_id
 join public.nb_template_versions nv on nv.id=n.narrative_version_id
 join public.nb_mechanical_templates mt on mt.id=n.mechanical_template_id
 join public.nb_mechanical_versions mv on mv.id=n.mechanical_version_id
 where n.id in(
  select (a->>'mechanical_binding_id')::uuid from jsonb_array_elements(d.definition->'scenes') s,
  lateral jsonb_array_elements(s->'actors') a where a->>'mechanical_binding_id' is not null);
 select coalesce(jsonb_agg(jsonb_build_object('narrative_template_id',nt.id,'narrative_version_id',nv.id,
  'narrative_template_control_version',nt.control_version,'narrative_version_control_version',nv.control_version,
  'narrative_content_sha256',nv.content_sha256) order by nv.id),'[]'::jsonb)
 into npins from public.nb_template_versions nv join public.nb_templates nt on nt.id=nv.template_id
 where nv.id in(select (a->>'narrative_version_id')::uuid from jsonb_array_elements(d.definition->'scenes') s,
  lateral jsonb_array_elements(s->'actors') a where a->>'mechanical_binding_id' is null);
 snap:=jsonb_build_object('schema_version','mission-generic-run/1','plan_version_id',d.plan_version_id,
  'plan_sha256',d.plan_sha256,'definition_sha256',d.definition_sha256,'definition',d.definition,
  'binding_pins',pins,'narrative_pins',npins,'arena',p_arena);
 insert into mission_generic_owner.run_bindings(master_session_id,definition_id,snapshot,snapshot_sha256)
  values(p_session,d.id,snap,mission_internal.fingerprint(snap)) returning * into b;
 return jsonb_build_object('master_session_id',p_session,'snapshot_sha256',b.snapshot_sha256);
end;
$fn$;

-- Explicit service-only Board integration, to be invoked before opening_claim.
create function public.mission_generic_board_attach_v1(p_session uuid,p_definition uuid)
returns jsonb language plpgsql security definer set search_path='' as $fn$
declare b mission_ai_board_owner.session_bindings;d mission_generic_owner.definitions;
begin
 perform mission_ai_board_owner.service_only();
 perform 1 from public.master_v2_sessions where id=p_session for update;
 select * into strict b from mission_ai_board_owner.session_bindings where master_session_id=p_session for share;
 select * into strict d from mission_generic_owner.definitions where id=p_definition;
 if exists(select 1 from mission_generic_owner.run_bindings where master_session_id=p_session) then
  return mission_generic_owner.attach(p_session,p_definition,b.binding->'arena');
 end if;
 if b.state<>'prepared' or b.binding#>>'{plan,plan_version_id}' is distinct from d.plan_version_id::text
 or exists(select 1 from mission_narrative_internal.dispatch_receipts where master_session_id=p_session)
 then raise exception 'MG_BOARD_OPENING_ALREADY_STARTED' using errcode='55000';end if;
 return mission_generic_owner.attach(p_session,p_definition,b.binding->'arena');
end;
$fn$;

create function mission_generic_owner.scene(p_session uuid,p_step text)
returns jsonb language sql stable security definer set search_path='' as $fn$
 select x from mission_generic_owner.run_bindings b,
 lateral jsonb_array_elements(b.snapshot#>'{definition,scenes}') x
 where b.master_session_id=p_session and x->>'step_key'=p_step
 and b.snapshot_sha256=mission_internal.fingerprint(b.snapshot)
$fn$;

create function mission_generic_owner.assert_runtime(p_session uuid)
returns void language plpgsql stable security definer set search_path='' as $fn$
declare mode text; test boolean;
begin
 select p.mode into strict mode from mission_generic_owner.runtime_policy p where singleton;
 select coalesce(l.is_test,false) into strict test from public.master_v2_sessions m join public.locations l on l.id=m.location_id where m.id=p_session;
 if mode='off' or (mode='test' and not test) then raise exception 'MG_RUNTIME_CLOSED' using errcode='55000';end if;
end;
$fn$;

-- Owner-only integration point: callers MUST verify their native source before
-- invoking this. Only player_choice is connected by this module. Combat/narrative/
-- spatial producers get no public acceptance endpoint and cannot self-attest via API.
-- Atomically persist the authoritative trigger and advance the existing controller.
create function mission_generic_owner.apply_authority(p_session uuid,p_request uuid,p_master_cv bigint,p_run_cv bigint,
 p_trigger text,p_source_kind text,p_source_ref uuid,p_source_sha256 text,p_actor uuid default null)
returns jsonb language plpgsql security definer set search_path='' as $fn$
declare m public.master_v2_sessions;r public.mission_run_state;b mission_generic_owner.run_bindings;
 old mission_generic_owner.trigger_receipts;t jsonb;sc jsonb;tr public.mission_plan_transitions;req public.mission_plan_requirements;
 cap public.mission_evidence_capabilities;fp text;ev uuid:=gen_random_uuid();at timestamptz:=clock_timestamp();
 evidence jsonb;result jsonb;ash text;
begin
 if p_request is null or p_source_ref is null or p_master_cv is null or p_run_cv is null
 or coalesce(p_source_sha256,'')!~'^[0-9a-f]{64}$' then raise exception 'MG_AUTHORITY_INPUT' using errcode='22023';end if;
 select * into strict m from public.master_v2_sessions where id=p_session for update;
 select * into strict r from public.mission_run_state where master_session_id=p_session for update;
 select * into strict b from mission_generic_owner.run_bindings where master_session_id=p_session;
 fp:=mission_internal.fingerprint(jsonb_build_object('session',p_session,'request',p_request,'master_cv',p_master_cv,'run_cv',p_run_cv,
  'trigger',p_trigger,'source_kind',p_source_kind,'source_ref',p_source_ref,'source_sha256',p_source_sha256,'actor',p_actor,'snapshot',b.snapshot_sha256));
 select * into old from mission_generic_owner.trigger_receipts where master_session_id=p_session and request_key=p_request;
 if found then
  if old.request_fingerprint<>fp then raise exception 'MG_REQUEST_CONFLICT' using errcode='40001';end if;
  return old.result;
 end if;
 perform mission_generic_owner.assert_runtime(p_session);
 if exists(select 1 from public.mission_run_outbox where master_session_id=p_session and state='pending')
 then raise exception 'MG_NARRATION_PENDING' using errcode='55000';end if;
 if m.owner_kind<>'ai_service' or m.closed_at is not null or m.stato<>'in_corso' or r.run_phase<>'in_corso'
 or m.control_version<>p_master_cv or r.control_version<>p_run_cv
 or r.plan_version_id::text is distinct from b.snapshot->>'plan_version_id'
 or r.plan_sha256 is distinct from b.snapshot->>'plan_sha256'
 then raise exception 'MG_RUN_CONFLICT' using errcode='40001';end if;
 sc:=mission_generic_owner.scene(p_session,r.current_step_key);
 select x into t from jsonb_array_elements(sc->'triggers') x where x->>'trigger_key'=p_trigger;
 if t is null or t->>'source_kind' is distinct from p_source_kind then raise exception 'MG_TRIGGER_NOT_OFFERED' using errcode='42501';end if;
 select * into strict tr from public.mission_plan_transitions where plan_version_id=r.plan_version_id and transition_key=t->>'transition_key' and from_step_key=r.current_step_key;
 select * into strict req from public.mission_plan_requirements where plan_version_id=r.plan_version_id and transition_key=tr.transition_key;
 select * into strict cap from public.mission_evidence_capabilities where capability_key='mission.generic.trigger.v1';
 if not cap.enabled or (cap.provider_owner,cap.domain,cap.source_kind,cap.feature_version,cap.provider_contract_version,cap.projection_version)
 is distinct from ('DB-MISSION'::text,'mission'::text,'server_receipt'::text,'mission-generic/1'::text,'mission-evidence-ref/1.2'::text,1)
 then raise exception 'MG_CAPABILITY_CLOSED' using errcode='55000';end if;
 ash:=mission_internal.fingerprint(jsonb_build_object('receipt',ev,'source_ref',p_source_ref,'source_sha256',p_source_sha256,
  'session',p_session,'step',r.current_step_key,'run_version',p_run_cv,'snapshot_sha256',b.snapshot_sha256,'trigger',p_trigger));
 evidence:=jsonb_build_array(jsonb_build_object('schema_version','mission-evidence-ref/1.2','ordinal',1,
  'provider_owner',cap.provider_owner,'domain',cap.domain,'source_kind',cap.source_kind,'capability_key',cap.capability_key,
  'feature_version',cap.feature_version,'provider_contract_version',cap.provider_contract_version,'master_session_id',p_session,
  'mission_id',r.mission_id,'plan_id',r.plan_id,'plan_version_id',r.plan_version_id,'run_control_version',p_run_cv,
  'step_key',r.current_step_key,'scope_ref',p_session,'evidence_ref',ev,'projection_version',cap.projection_version,
  'fact_code',req.fact_code,'payload_sha256',p_source_sha256,'owner_validation_sha256',ash,'terminal',true,
  'issued_at',at,'validated_at',at,'expires_at',at+make_interval(secs=>req.max_age_ms/1000.0),'owner_validation_status','current'));
 result:=mission_internal.transition(p_session,p_request,p_master_cv,p_run_cv,tr.event_kind,evidence);
 result:=result||jsonb_build_object('authority_receipt_id',ev,'trigger_key',p_trigger);
 insert into mission_generic_owner.trigger_receipts(id,master_session_id,request_key,request_fingerprint,step_key,run_control_version,
  trigger_key,source_kind,source_ref,source_sha256,actor_character_id,issued_at,result)
 values(ev,p_session,p_request,fp,r.current_step_key,p_run_cv,p_trigger,p_source_kind,p_source_ref,p_source_sha256,p_actor,at,result);
 return result;
end;
$fn$;

-- A click on a server-offered option is itself an authenticated player choice.
-- It does not assert mechanical success or substitute for Combat/server facts.
create function public.mission_generic_choose_v1(p_session uuid,p_trigger text,p_request uuid,p_expected_master_version bigint,p_expected_run_version bigint)
returns jsonb language plpgsql security definer set search_path='' as $fn$
declare uid uuid:=auth.uid();cid uuid;source_sha text;
begin
 if uid is null then raise exception 'MG_AUTH_REQUIRED' using errcode='42501';end if;
 perform 1 from public.master_v2_sessions where id=p_session for update;
 select mp.character_id into strict cid from public.master_v2_participants mp
 join public.characters c on c.id=mp.character_id and c.user_id=uid
 where mp.session_id=p_session and mp.user_id_snapshot=uid
 and ((mp.left_at is null and mp.engagement_state='attivo') or exists(
  select 1 from mission_generic_owner.trigger_receipts er where er.master_session_id=p_session
   and er.request_key=p_request and er.source_kind='player_choice' and er.actor_character_id=mp.character_id));
 source_sha:=mission_internal.fingerprint(jsonb_build_object('source','authenticated-player-choice/1','session',p_session,
  'character',cid,'request',p_request,'trigger',p_trigger,'run_version',p_expected_run_version,'master_version',p_expected_master_version));
 return mission_generic_owner.apply_authority(p_session,p_request,p_expected_master_version,p_expected_run_version,
  p_trigger,'player_choice',p_request,source_sha,cid);
end;
$fn$;

create function public.mission_generic_choices_v1(p_session uuid)
returns jsonb language plpgsql stable security definer set search_path='' as $fn$
declare uid uuid:=auth.uid();m public.master_v2_sessions;r public.mission_run_state;sc jsonb;
begin
 if uid is null or not exists(select 1 from public.master_v2_participants mp join public.characters c on c.id=mp.character_id
  where mp.session_id=p_session and mp.user_id_snapshot=uid and c.user_id=uid and mp.left_at is null)
 then raise exception 'MG_NOT_PARTICIPANT' using errcode='42501';end if;
 perform mission_generic_owner.assert_runtime(p_session);
 select * into strict m from public.master_v2_sessions where id=p_session;
 select * into strict r from public.mission_run_state where master_session_id=p_session;
 sc:=mission_generic_owner.scene(p_session,r.current_step_key);
 return jsonb_build_object('schema_version','mission-generic-choices/1','master_session_id',p_session,
  'step_key',r.current_step_key,'master_control_version',m.control_version,'run_control_version',r.control_version,
  'narration_pending',exists(select 1 from public.mission_run_outbox where master_session_id=p_session and state='pending'),
  'choices',case when m.stato='in_corso' and r.run_phase='in_corso' and m.closed_at is null
   and not exists(select 1 from public.mission_run_outbox where master_session_id=p_session and state='pending') then
   (select coalesce(jsonb_agg(jsonb_build_object('trigger_key',x->>'trigger_key','label',x->>'label') order by x->>'trigger_key'),'[]'::jsonb)
   from jsonb_array_elements(sc->'triggers') x where x->>'source_kind'='player_choice') else '[]'::jsonb end);
end;
$fn$;

-- Capability registration is inert. Activation is a distinct reviewed operation.
create function public.mission_generic_editor_v1(p_plan_version uuid default null)
returns jsonb language plpgsql stable security definer set search_path='' as $fn$
declare plans jsonb;profiles jsonb;item jsonb;defs jsonb;mode text;
begin
 perform mission_ai_board_owner.staff_only();
 select p.mode into strict mode from mission_generic_owner.runtime_policy p where singleton;
 select coalesce(jsonb_agg(jsonb_build_object('plan_version_id',v.id,'plan_id',v.plan_id,'mission_id',p.mission_id,
  'title',m.title,'version',v.versione,'initial_step_key',v.initial_step_key,'plan_sha256',v.plan_sha256)
  order by m.title,v.versione),'[]'::jsonb)
 into plans from public.mission_plan_versions v join public.mission_plans p on p.id=v.plan_id
 join public.missions m on m.id=p.mission_id where v.stato='approvata';
 select coalesce(jsonb_agg(jsonb_build_object('mechanical_binding_id',b.id,'display_name',nt.display_name,
  'narrative_template_id',nt.id,'narrative_version_id',nv.id,'mechanical_template_id',mt.id,
  'mechanical_version_id',mv.id,'rank',mv.rank,'archetype',mt.archetype,'active',b.active,
  'control_version',b.control_version) order by nt.display_name,b.id),'[]'::jsonb)
 into profiles from public.nb_mechanical_bindings b join public.nb_templates nt on nt.id=b.narrative_template_id
 join public.nb_template_versions nv on nv.id=b.narrative_version_id and nv.template_id=nt.id
 join public.nb_mechanical_templates mt on mt.id=b.mechanical_template_id
 join public.nb_mechanical_versions mv on mv.id=b.mechanical_version_id and mv.template_id=mt.id
 where b.lifecycle_state='approved' and nt.lifecycle_state='approved' and mt.lifecycle_state='approved'
 and nv.review_state='approved' and mv.review_state='approved';
 if p_plan_version is not null then
  select x into item from jsonb_array_elements(plans) x where x->>'plan_version_id'=p_plan_version::text;
  if item is null then raise exception 'MG_PLAN_NOT_APPROVED' using errcode='22023';end if;
  item:=item||jsonb_build_object(
   'steps',(select coalesce(jsonb_agg(to_jsonb(s) order by s.ordinal),'[]'::jsonb) from public.mission_plan_steps s where s.plan_version_id=p_plan_version),
   'transitions',(select coalesce(jsonb_agg(to_jsonb(t) order by t.from_step_key,t.priority,t.transition_key),'[]'::jsonb) from public.mission_plan_transitions t where t.plan_version_id=p_plan_version),
   'requirements',(select coalesce(jsonb_agg(to_jsonb(r) order by r.transition_key,r.ordinal),'[]'::jsonb) from public.mission_plan_requirements r where r.plan_version_id=p_plan_version));
  select coalesce(jsonb_agg(jsonb_build_object('id',d.id,'version',d.version,'definition',d.definition,
   'definition_sha256',d.definition_sha256,'sealed_at',d.sealed_at) order by d.version desc),'[]'::jsonb)
   into defs from mission_generic_owner.definitions d where d.plan_version_id=p_plan_version;
 end if;
 return jsonb_build_object('schema_version','mission-generic-editor/1','encounter_options',jsonb_build_object('per_step',1,'npc_min',1,'npc_max',12,'opposing_npc_required',true,'mission_pvp',false),'runtime_mode',mode,'plans',plans,
  'plan',item,'definitions',coalesce(defs,'[]'::jsonb),'mechanical_profiles',profiles,
  'narrative_profiles',(select coalesce(jsonb_agg(jsonb_build_object('display_name',nt.display_name,
   'narrative_template_id',nt.id,'narrative_version_id',nv.id,'version',nv.version_no) order by nt.display_name,nv.version_no),'[]'::jsonb)
   from public.nb_templates nt join public.nb_template_versions nv on nv.template_id=nt.id
   where nt.lifecycle_state='approved' and nv.review_state='approved'));
end;
$fn$;

insert into public.mission_evidence_capabilities(capability_key,enabled,provider_owner,domain,source_kind,feature_version,provider_contract_version,projection_version)
values('mission.generic.trigger.v1',false,'DB-MISSION','mission','server_receipt','mission-generic/1','mission-evidence-ref/1.2',1);

revoke all on all functions in schema mission_generic_owner from public,anon,authenticated,service_role;
revoke all on function public.mission_generic_definition_seal_v1(uuid,bigint,jsonb,text) from public,anon,authenticated,service_role;
revoke all on function public.mission_generic_board_attach_v1(uuid,uuid) from public,anon,authenticated,service_role;
revoke all on function public.mission_generic_choose_v1(uuid,text,uuid,bigint,bigint) from public,anon,authenticated,service_role;
revoke all on function public.mission_generic_choices_v1(uuid) from public,anon,authenticated,service_role;
revoke all on function public.mission_generic_editor_v1(uuid) from public,anon,authenticated,service_role;
grant execute on function public.mission_generic_definition_seal_v1(uuid,bigint,jsonb,text) to authenticated;
grant execute on function public.mission_generic_board_attach_v1(uuid,uuid) to service_role;
grant execute on function public.mission_generic_choose_v1(uuid,text,uuid,bigint,bigint) to authenticated;
grant execute on function public.mission_generic_choices_v1(uuid) to authenticated;
grant execute on function public.mission_generic_editor_v1(uuid) to authenticated;

commit;
