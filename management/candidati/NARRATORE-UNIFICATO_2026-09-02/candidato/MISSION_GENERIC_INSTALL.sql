-- MISSION-GENERIC A2 · sola correzione CASE su C1, unica transazione, nessun enable.
begin;

-- MODULE MISSION_GENERIC_DB.sql SHA256 b7e42ea5a6b78d50d5289a356d7be96b550d30cdb305e99b02145cf53fc732ff
-- MISSION-GENERIC-DB/1 · candidate only; no database apply performed.
-- Install with the composed bridge reviewed by DB-CORE. All new runtime is OFF.
-- Existing mission_internal.transition remains the only phase controller.
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

-- MODULE MISSION_GENERIC_PLAN_WRITER.sql SHA256 2e7a81af83224fb7a6f98d83a3836f4b53ddbee1c61574ab41c3f344795e53ae
-- MISSION-GENERIC-PLAN-WRITER/1 · candidate, after MISSION_GENERIC_DB.sql.
-- Editorial operations only. No Board start, enable, gameplay or legacy rewrites.
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

-- MODULE MISSION_GENERIC_OUTCOME.sql SHA256 da8c285402f54f37c49261e79069069669f907de5f4177790c6d0e5fb562e2c7
-- MISSION-GENERIC-OUTCOME/1: apply after DB + PLAN_WRITER; no stored definition or run is rewritten.
DO $pin$
begin
 if (select md5(prosrc) from pg_proc where oid='mission_generic_owner.validate_definition(uuid,jsonb)'::regprocedure) is distinct from '96b6a55c701498d9df5388654e4dff67' then raise exception 'MGO_BASELINE_DRIFT: mission_generic_owner.validate_definition(uuid,jsonb)';end if;
 if (select md5(prosrc) from pg_proc where oid='public.mission_generic_editor_v1(uuid)'::regprocedure) is distinct from '653feaf7dea6845ee6f80e067ba289fe' then raise exception 'MGO_BASELINE_DRIFT: public.mission_generic_editor_v1(uuid)';end if;
 if (select md5(prosrc) from pg_proc where oid='public.mission_generic_plan_catalog_v1(uuid)'::regprocedure) is distinct from '97f75f6547ffc3880891f7864c37a153' then raise exception 'MGO_BASELINE_DRIFT: public.mission_generic_plan_catalog_v1(uuid)';end if;
end;
$pin$;
create or replace function mission_generic_owner.validate_definition(p_plan uuid,p_definition jsonb)
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
  -- Any is a wildcard; overlapping edges would let one server event select two destinations.
  if exists(select 1 from jsonb_array_elements(s->'triggers') with ordinality a(t,n)
   join jsonb_array_elements(s->'triggers') with ordinality b(t,n) on a.n<b.n
   where a.t->>'source_kind'='combat_terminal' and b.t->>'source_kind'='combat_terminal'
    and a.t->>'encounter_key'=b.t->>'encounter_key'
    and (coalesce(a.t->>'combat_outcome','any')='any' or coalesce(b.t->>'combat_outcome','any')='any'
     or a.t->>'combat_outcome'=b.t->>'combat_outcome'))
  then raise exception 'MG_COMBAT_OUTCOME_OVERLAP' using errcode='22023';end if;
  for t in select value from jsonb_array_elements(s->'triggers') loop
   if not mission_generic_owner.keys_valid(t,array['trigger_key','transition_key','source_kind','fact_code','label'],array['encounter_key','combat_outcome'])
   or coalesce(t->>'trigger_key','')!~'^[a-z][a-z0-9_]{0,63}$'
   or coalesce(t->>'source_kind','') not in('player_choice','combat_terminal','narrative_event','spatial_event')
   or coalesce(t->>'fact_code','')!~'^[a-z][a-z0-9_]{0,79}$'
   or char_length(btrim(coalesce(t->>'label',''))) not between 1 and 160
   then raise exception 'MG_TRIGGER_INVALID' using errcode='22023';end if;
   if t ? 'combat_outcome' and (t->>'source_kind'<>'combat_terminal'
    or coalesce(t->>'combat_outcome','') not in('any','pg_win','pg_loss','draw'))
   then raise exception 'MG_COMBAT_OUTCOME_INVALID' using errcode='22023';end if;
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

create or replace function public.mission_generic_editor_v1(p_plan_version uuid default null)
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
 return jsonb_build_object('schema_version','mission-generic-editor/1','trigger_options',jsonb_build_object('combat_outcome',jsonb_build_object('source_kind','combat_terminal','optional',true,'default','any','values',jsonb_build_array('any','pg_win','pg_loss','draw'),'authority','server_terminal_receipt')),'encounter_options',jsonb_build_object('per_step',1,'npc_min',1,'npc_max',12,'opposing_npc_required',true,'mission_pvp',false),'runtime_mode',mode,'plans',plans,
  'plan',item,'definitions',coalesce(defs,'[]'::jsonb),'mechanical_profiles',profiles,
  'narrative_profiles',(select coalesce(jsonb_agg(jsonb_build_object('display_name',nt.display_name,
   'narrative_template_id',nt.id,'narrative_version_id',nv.id,'version',nv.version_no) order by nt.display_name,nv.version_no),'[]'::jsonb)
   from public.nb_templates nt join public.nb_template_versions nv on nv.template_id=nt.id
   where nt.lifecycle_state='approved' and nv.review_state='approved'));
end;
$fn$;

create or replace function public.mission_generic_plan_catalog_v1(p_mission uuid)
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
 return jsonb_build_object('schema_version','mission-generic-plan-catalog/1','trigger_options',jsonb_build_object('combat_outcome',jsonb_build_object('source_kind','combat_terminal','optional',true,'default','any','values',jsonb_build_array('any','pg_win','pg_loss','draw'),'authority','server_terminal_receipt')),'encounter_options',jsonb_build_object('per_step',1,'npc_min',1,'npc_max',12,'opposing_npc_required',true,'mission_pvp',false),'mission',m,
  'mission_sha256',mission_internal.fingerprint(m),'versions',versions,'selected_plan_version_id',sel.plan_version_id,
  'selection_control_version',coalesce(sel.control_version,0));
end;
$fn$;

revoke all on function mission_generic_owner.validate_definition(uuid,jsonb) from public,anon,authenticated,service_role;
revoke all on function public.mission_generic_editor_v1(uuid) from public,anon,authenticated,service_role;
revoke all on function public.mission_generic_plan_catalog_v1(uuid) from public,anon,authenticated,service_role;
grant execute on function public.mission_generic_editor_v1(uuid) to authenticated;
grant execute on function public.mission_generic_plan_catalog_v1(uuid) to authenticated;

-- MODULE MISSION_GENERIC_COMBAT.sql SHA256 cb80d82231f59473d4aa13584d3e9e7a3360ff0b90e2cf0d09e5b53310431b5a
-- MISSION-GENERIC-COMBAT/1: candidato privato, nessun apply eseguito.
-- Comporre dopo MISSION_GENERIC_DB.sql e con l'adapter Common service del PM.
do $metadata$ begin
 if not exists(select 1 from pg_proc where oid=to_regprocedure('public.master_v2_encounter_open_ninja_book_v1_ai_service_core(uuid,uuid[],jsonb,jsonb,uuid,uuid)') and pg_get_userbyid(proowner)='postgres' and prosecdef and proconfig=ARRAY['search_path=""'] and proacl::text='{postgres=X/postgres}') then raise exception 'MG_COMBAT_METADATA_DRIFT';end if;
 if not exists(select 1 from pg_proc where oid=to_regprocedure('combat_panel_private.enroll_master(uuid)') and pg_get_userbyid(proowner)='postgres' and prosecdef and proconfig=ARRAY['search_path=""'] and proacl::text='{postgres=X/postgres}') then raise exception 'MG_COMBAT_METADATA_DRIFT';end if;
 if not exists(select 1 from pg_proc where oid=to_regprocedure('combat_panel_private.master_entry_trigger()') and pg_get_userbyid(proowner)='postgres' and prosecdef and proconfig=ARRAY['search_path=""'] and proacl::text='{postgres=X/postgres}') then raise exception 'MG_COMBAT_METADATA_DRIFT';end if;
 if not exists(select 1 from pg_proc where oid=to_regprocedure('combat_panel_private.uses_simulated_pools(uuid)') and pg_get_userbyid(proowner)='postgres' and prosecdef and proconfig=ARRAY['search_path=""'] and proacl::text='{postgres=X/postgres}') then raise exception 'MG_COMBAT_METADATA_DRIFT';end if;
 if not exists(select 1 from pg_proc where oid=to_regprocedure('combat_spatial.exchange_owner_receipt(uuid,uuid)') and pg_get_userbyid(proowner)='postgres' and prosecdef and proconfig=ARRAY['search_path=""'] and proacl::text='{postgres=X/postgres,service_role=X/postgres}') then raise exception 'MG_COMBAT_METADATA_DRIFT';end if;
 if not exists(select 1 from pg_proc where oid=to_regprocedure('public.universal_arena_state_v1(uuid)') and pg_get_userbyid(proowner)='postgres' and prosecdef and proconfig=ARRAY['search_path=""'] and proacl::text='{postgres=X/postgres,authenticated=X/postgres}') then raise exception 'MG_COMBAT_METADATA_DRIFT';end if;
 if not exists(select 1 from pg_constraint where conrelid='combat_spatial.arena_instances'::regclass and conname='arena_instances_master_session_id_key' and pg_get_constraintdef(oid)='UNIQUE (master_session_id)') then raise exception 'MG_ARENA_CONSTRAINT_DRIFT';end if;
end $metadata$;

do $pin$ begin
 if md5(pg_get_functiondef('public.master_v2_encounter_open_ninja_book_v1_ai_service_core(uuid,uuid[],jsonb,jsonb,uuid,uuid)'::regprocedure))<>'a5cf9a033b4913aee6cd27a8708c9b61'
 or md5(pg_get_functiondef('combat_panel_private.uses_simulated_pools(uuid)'::regprocedure))<>'bbd85ffd70c2bcf58b9ecb54b5f9e069'
 then raise exception 'MG_COMBAT_BASELINE_DRIFT';end if;
end $pin$;

create table mission_generic_owner.encounters (
 encounter_id uuid primary key references public.combat_v2_sessions(id),
 master_session_id uuid not null references mission_generic_owner.run_bindings(master_session_id),
 step_key text not null,run_control_version bigint not null check(run_control_version>0),
 encounter_key text not null,request_key uuid not null,request_fingerprint text not null,
 capability_id uuid not null references mission_ai_service_owner.capabilities(id),
 actor_map jsonb not null check(jsonb_typeof(actor_map)='array'),
 created_at timestamptz not null default clock_timestamp(),open_receipt jsonb not null,
 unique(master_session_id,run_control_version,encounter_key),unique(master_session_id,request_key)
);
alter table mission_generic_owner.encounters enable row level security;
revoke all on mission_generic_owner.encounters from public,anon,authenticated,service_role;
create trigger mission_generic_encounter_immutable before update or delete on mission_generic_owner.encounters
for each row execute function mission_generic_owner.immutable();

create function mission_generic_owner.assert_combat_scope(p_master uuid,p_cap uuid)
returns void language plpgsql security definer set search_path='' as $fn$
declare m public.master_v2_sessions;b mission_generic_owner.run_bindings; principals uuid[];l public.locations;
begin
 perform mission_generic_owner.assert_runtime(p_master);
 perform mission_ai_service_owner.assert_capability(p_master,p_cap);
 select * into strict m from public.master_v2_sessions where id=p_master;
 select * into strict b from mission_generic_owner.run_bindings where master_session_id=p_master;
 select * into strict l from public.locations where id=m.location_id;
 if m.owner_kind<>'ai_service' or m.master_user is not null or m.mission_id is null or m.tipo<>'quest'
 or m.closed_at is not null or m.suspended_at is not null or m.stato not in('preparazione','in_corso')
 or not l.is_active or l.is_test is null or b.snapshot_sha256<>mission_internal.fingerprint(b.snapshot)
 or b.snapshot#>>'{arena,mission_id}' is distinct from m.mission_id::text
 or b.snapshot#>>'{arena,location_id}' is distinct from m.location_id::text
 then raise exception 'MG_COMBAT_AUTHORITY' using errcode='42501';end if;
 if exists(select 1 from public.master_v2_participants p left join public.characters c on c.id=p.character_id
 where p.session_id=p_master and p.left_at is null and p.engagement_state='attivo'
 and (c.id is null or c.user_id is distinct from p.user_id_snapshot))
 then raise exception 'MG_COMBAT_ROSTER_IDENTITY_DRIFT' using errcode='42501';end if;
 select array_agg(distinct p.user_id_snapshot order by p.user_id_snapshot) into principals
 from public.master_v2_participants p join public.characters c on c.id=p.character_id and c.user_id=p.user_id_snapshot
 where p.session_id=p_master and p.left_at is null and p.engagement_state='attivo';
 if coalesce(cardinality(principals),0)=0 then raise exception 'MG_COMBAT_ROSTER_EMPTY';end if;
 if l.is_test and (l.id<>'0b85f354-9cdb-47e1-baf9-3d266bb7e06b'::uuid
 or combat_consumer_private.staff_test_allowed(l.id,principals,false) is distinct from true)
 then raise exception 'MG_COMBAT_TEST_SCOPE' using errcode='42501';end if;
end $fn$;

create function mission_generic_owner.binding_is_pinned(p_master uuid,p_binding uuid)
returns boolean language sql stable security definer set search_path='' as $fn$
 select exists(select 1 from mission_generic_owner.run_bindings r,
 lateral jsonb_array_elements(r.snapshot->'binding_pins') p
 join public.nb_mechanical_bindings b on b.id=(p->>'mechanical_binding_id')::uuid
 join public.nb_templates nt on nt.id=b.narrative_template_id
 join public.nb_template_versions nv on nv.id=b.narrative_version_id
 join public.nb_mechanical_templates mt on mt.id=b.mechanical_template_id
 join public.nb_mechanical_versions mv on mv.id=b.mechanical_version_id
 where r.master_session_id=p_master and b.id=p_binding and b.control_version=(p->>'control_version')::bigint
 and nt.id=(p->>'narrative_template_id')::uuid and nv.id=(p->>'narrative_version_id')::uuid
 and mt.id=(p->>'mechanical_template_id')::uuid and mv.id=(p->>'mechanical_version_id')::uuid
 and nt.control_version=(p->>'narrative_template_control_version')::bigint
 and nv.control_version=(p->>'narrative_version_control_version')::bigint
 and mt.control_version=(p->>'mechanical_template_control_version')::bigint
 and mv.control_version=(p->>'mechanical_version_control_version')::bigint
 and nv.content_sha256=p->>'narrative_content_sha256' and mv.content_sha256=p->>'mechanical_content_sha256')
$fn$;

-- Trasferisce solo le risorse reali dell'ultimo incontro dello stesso run/attore.
-- Nessuna lettura di PG diversi, nessuna scrittura in characters o inventario.
create function mission_generic_owner.carry_snapshot(p_master uuid,p_character uuid,p_client uuid,p_fresh jsonb)
returns jsonb language plpgsql security definer set search_path='' as $fn$
declare prior jsonb;
begin
 select a.mechanics_snapshot into prior from mission_generic_owner.encounters e
 join public.combat_v2_sessions s on s.id=e.encounter_id
 join public.combat_v2_actors a on a.session_id=s.id
 left join public.combat_v2_provider_instances_v1 pi on pi.id=a.provider_instance_v1_id
 where e.master_session_id=p_master and s.state='chiuso' and s.closed_at is not null
 and ((p_character is not null and a.character_id=p_character)
 or (p_character is null and p_client is not null and pi.client_ref=p_client))
 order by e.created_at desc,e.encounter_id desc limit 1;
 if prior is null then return p_fresh;end if;
 if prior->'vita_max' is distinct from p_fresh->'vita_max' or prior->'chakra_max' is distinct from p_fresh->'chakra_max'
 or jsonb_typeof(prior->'vita') is distinct from 'number' or jsonb_typeof(prior->'chakra') is distinct from 'number'
 then raise exception 'MG_COMBAT_RESOURCE_BASELINE_CHANGED' using errcode='40001';end if;
 return p_fresh||jsonb_build_object('vita',prior->'vita','chakra',prior->'chakra');
end $fn$;

-- Un'unica arena aperta per master; lo storico resta distinto per encounter.
-- La guardia additive sotto conserva il vincolo storico assoluto sui percorsi legacy.
alter table combat_spatial.arena_instances drop constraint arena_instances_master_session_id_key;
create unique index arena_instances_master_open_unique on combat_spatial.arena_instances(master_session_id)
where master_session_id is not null and state='open';
create function mission_generic_owner.arena_multi_guard() returns trigger
language plpgsql security definer set search_path='' as $fn$
begin
 if new.master_session_id is null then return new;end if;
 perform 1 from public.master_v2_sessions where id=new.master_session_id for update;
 if exists(select 1 from combat_spatial.arena_instances i where i.master_session_id=new.master_session_id and i.instance_id<>new.instance_id)
 and not exists(select 1 from mission_generic_owner.encounters e where e.master_session_id=new.master_session_id
 and e.encounter_id=new.encounter_id and new.context_source='panel_master')
 then raise exception 'MG_ARENA_LEGACY_UNIQUENESS' using errcode='23505';end if;
 return new;
end $fn$;
create trigger mission_generic_arena_multi_guard before insert or update of master_session_id,encounter_id,context_source
on combat_spatial.arena_instances for each row execute function mission_generic_owner.arena_multi_guard();

create function mission_generic_owner.bind_arena_native(p_master uuid,p_encounter uuid,p_request uuid)
returns jsonb language plpgsql security definer set search_path='' as $fn$
declare e mission_generic_owner.encounters;b mission_generic_owner.run_bindings;m public.master_v2_sessions;
 t combat_spatial.arena_templates;src jsonb;pid uuid;claim uuid;iid uuid;policy text;chosen boolean;
 a record;slot record;radius numeric;principal uuid;
begin
 select * into strict e from mission_generic_owner.encounters where encounter_id=p_encounter and master_session_id=p_master;
 perform mission_generic_owner.assert_combat_scope(p_master,e.capability_id);
 select * into strict m from public.master_v2_sessions where id=p_master for update;
 select * into strict b from mission_generic_owner.run_bindings where master_session_id=p_master;
 src:=b.snapshot->'arena';
 select * into strict t from combat_spatial.arena_templates
 where template_key=src->>'template_key' and template_version=(src->>'template_version')::integer and status='ready' for share;
 perform 1 from combat_spatial.arena_slots where template_key=t.template_key and template_version=t.template_version order by slot_key for share;
 perform 1 from combat_spatial.arena_objects where template_key=t.template_key and template_version=t.template_version order by object_key for share;
 if src->>'zone_key'<>'arena' or src->>'catalog_sha256' is distinct from combat_panel_private.universal_arena_hash(t.template_key,t.template_version)
 or t.geometry_hash is distinct from combat_spatial.geometry_fingerprint(t.template_key,t.template_version)
 or combat_spatial.template_errors(t.template_key,t.template_version)<>'[]'::jsonb
 then raise exception 'MG_ARENA_FROZEN_CATALOG_DRIFT' using errcode='40001';end if;
 if exists(select 1 from combat_spatial.arena_instances where encounter_id=p_encounter)
 or exists(select 1 from public.combat_v2_declarations d join public.combat_v2_rounds r on r.id=d.round_id where r.session_id=p_encounter)
 then raise exception 'MG_ARENA_ALREADY_BOUND_OR_DECLARED';end if;
 policy:=case when (select is_test from public.locations where id=m.location_id)
 then 'staff_test_no_persistent_resources_v1' else 'master_game_resources_v1' end;
 pid:=mission_ai_service_owner.uuid5(p_encounter,'generic-arena-profile');
 claim:=mission_ai_service_owner.uuid5(p_encounter,'generic-arena-claim');
 iid:=mission_ai_service_owner.uuid5(p_encounter,'generic-arena-instance');
 insert into combat_panel_private.master_panel_sessions(master_session_id,location_id,policy_id)
 values(p_master,m.location_id,policy) on conflict(master_session_id) do nothing;
 if not exists(select 1 from combat_panel_private.master_panel_sessions where master_session_id=p_master and location_id=m.location_id and policy_id=policy)
 then raise exception 'MG_ARENA_PANEL_POLICY_CONFLICT';end if;
 insert into combat_panel_private.master_scene_profiles(id,location_id,label,template_key,template_version,profile_version,geometry_fingerprint,policy_id,visibility_mode,enabled)
 values(pid,m.location_id,'Arena missione',t.template_key,t.template_version,1,t.geometry_hash,policy,'participants',true);
 insert into combat_panel_private.master_scene_claims(id,profile_id,profile_version,master_session_id,encounter_id,
 template_key,template_version,authority_principal_id,authority_control_version,geometry_fingerprint,roster_fingerprint,policy_id,visibility_mode)
 values(claim,pid,1,p_master,p_encounter,t.template_key,t.template_version,e.capability_id,m.control_version,
 t.geometry_hash,combat_panel_private.master_roster_fingerprint(p_encounter),policy,'participants');
 insert into combat_spatial.arena_instances(instance_id,master_session_id,encounter_id,binding_id,template_key,template_version,map_version,state,context_source,panel_claim_id)
 values(iid,p_master,p_encounter,null,t.template_key,t.template_version,1,'open','panel_master',claim);
 -- Le opzioni e le collisioni derivano dal catalogo server; nessuna coordinata IA/client.
 for a in select * from public.combat_v2_actors where session_id=p_encounter and state='attivo' order by actor_kind,id loop
  radius:=t.actor_radius_m;chosen:=false;
  for slot in select * from combat_spatial.arena_slots where template_key=t.template_key and template_version=t.template_version
  and actor_kind=upper(a.actor_kind) order by slot_key loop
   if clan_marionettisti_private.scene_slot_legal(t.template_key,t.template_version,round(slot.x_m),round(slot.y_m),radius)
   and not exists(select 1 from combat_spatial.actor_states z where z.instance_id=iid and
   (z.slot_key=slot.slot_key or combat_spatial.distance_m(z.x_m,z.y_m,round(slot.x_m),round(slot.y_m))<=z.footprint_radius_m+radius)) then
    principal:=case when a.actor_kind='pg' then a.controller_user else mission_ai_service_owner.uuid5(a.id,'mission-generic-principal') end;
    insert into combat_panel_private.master_placement_options(claim_id,actor_id,slot_key,x_m,y_m,radius_m)
    values(claim,a.id,slot.slot_key,round(slot.x_m),round(slot.y_m),radius);
    insert into combat_spatial.actor_states(instance_id,actor_id,actor_kind,slot_key,controller_principal_id,projection_subject_id,x_m,y_m,footprint_radius_m,body_version,state)
    values(iid,a.id,upper(a.actor_kind),slot.slot_key,principal,gen_random_uuid(),round(slot.x_m),round(slot.y_m),radius,1,'active');
    chosen:=true;exit;
   end if;
  end loop;
  if not chosen then raise exception 'MG_ARENA_LEGAL_SLOTS_INSUFFICIENT' using errcode='22023';end if;
 end loop;
 insert into combat_spatial.viewer_grants(instance_id,viewer_principal_id,subject_actor_id,can_view_map,can_view_objects,grant_version)
 select iid,v.controller_principal_id,z.actor_id,true,true,1 from combat_spatial.actor_states z
 cross join (select distinct controller_principal_id from combat_spatial.actor_states where instance_id=iid) v where z.instance_id=iid;
 insert into combat_spatial.object_states(instance_id,object_key,state,state_version)
 select iid,object_key,case when substitutable then 'available' else 'blocked' end,1 from combat_spatial.arena_objects
 where template_key=t.template_key and template_version=t.template_version;
 for a in select * from combat_spatial.actor_states where instance_id=iid loop
  if combat_spatial.path_first_block_t(iid,a.actor_id,a.x_m,a.y_m,a.x_m,a.y_m,null)<1
  then raise exception 'MG_ARENA_FINAL_OCCUPANCY_INVALID' using errcode='22023';end if;
 end loop;
 return jsonb_build_object('instance_id',iid,'claim_id',claim,'map_version',1);
end $fn$;

CREATE OR REPLACE FUNCTION mission_generic_owner.open_core(p_master_session uuid, p_pg_ids uuid[], p_actor_offers jsonb, p_team_map jsonb, p_request_key uuid, p_capability uuid)
 RETURNS jsonb
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO ''
AS $function$
declare
  v_uid uuid:=null::uuid; v_cap uuid:=p_capability; v_m public.master_v2_sessions%rowtype; v_event jsonb; v_event_id uuid;
  v_enc uuid; v_round uuid; v_pg uuid; v_snap jsonb; v_team text; v_spec jsonb;
  v_offer public.master_v2_nb_actor_offers_v1%rowtype; v_nt public.nb_templates%rowtype;
  v_nv public.nb_template_versions%rowtype; v_b public.nb_mechanical_bindings%rowtype;
  v_mt public.nb_mechanical_templates%rowtype; v_mv public.nb_mechanical_versions%rowtype;
  v_instance uuid; v_mode text; v_result jsonb; v_count integer; v_client uuid; v_offer_ref uuid;
begin
  perform mission_generic_owner.assert_combat_scope(p_master_session,v_cap);
  if v_cap is null then perform public.master_v2_nb_fail_v1('autenticazione_richiesta','Capability IA richiesta.',401,p_request_key); end if;
  select * into v_m from public.master_v2_sessions where id=p_master_session;
  if v_m.id is null then perform public.master_v2_nb_fail_v1('sessione_inesistente','Sessione Master inesistente.',404,p_request_key); end if;
  if (v_m.owner_kind<>'ai_service' or v_m.master_user is not null or v_cap is null) then perform public.master_v2_nb_fail_v1('master_non_proprietario','Solo il Master corrente può aprire lo scontro.',403,p_request_key); end if;
  if v_m.tipo<>'quest' or v_m.mission_id is null or v_m.stato not in ('preparazione','in_corso') then
    perform public.master_v2_nb_fail_v1('sessione_non_operativa','Sessione missione non operativa.',409,p_request_key);
  end if;
  if p_pg_ids is null or cardinality(p_pg_ids)<1 or cardinality(p_pg_ids)>12
     or p_actor_offers is null or jsonb_typeof(p_actor_offers)<>'array'
     or jsonb_array_length(p_actor_offers)<1 or jsonb_array_length(p_actor_offers)>12
     or p_team_map is null or jsonb_typeof(p_team_map)<>'object' then
    perform public.master_v2_nb_fail_v1('intento_non_valido','Elenco attori non valido.',422,p_request_key);
  end if;
  select count(distinct x) into v_count from unnest(p_pg_ids) x;
  if v_count<>cardinality(p_pg_ids) then perform public.master_v2_nb_fail_v1('intento_non_valido','PG duplicato.',422,p_request_key); end if;
  if exists(select 1 from public.characters c where c.id=any(p_pg_ids) and c.user_id=v_uid) then
    perform public.master_v2_nb_fail_v1('attore_non_controllato','Il Master corrente non può essere un attore PG.',422,p_request_key);
  end if;
  if (select count(*) from public.characters c where c.id=any(p_pg_ids))<>cardinality(p_pg_ids) then
    perform public.master_v2_nb_fail_v1('intento_non_valido','Uno o più PG non esistono.',422,p_request_key);
  end if;
  if exists(select 1 from jsonb_array_elements(p_actor_offers) x
    where jsonb_typeof(x)<>'object' or public.combat_v2_has_forbidden_key(x)
       or exists(select 1 from jsonb_object_keys(x) k where k not in ('client_ref','provider','offer_ref'))
       or (select count(*) from jsonb_object_keys(x))<>3) then
    perform public.master_v2_nb_fail_v1('campo_meccanico_vietato','Payload provider non valido.',422,p_request_key);
  end if;
  if exists(select 1 from jsonb_array_elements(p_actor_offers) x where x->>'provider'<>'ninja_book') then
    perform public.master_v2_nb_fail_v1('riferimento_provider_non_valido','Provider non valido.',422,p_request_key);
  end if;
  begin
    if (select count(distinct (x->>'client_ref')::uuid) from jsonb_array_elements(p_actor_offers) x)<>jsonb_array_length(p_actor_offers)
       or (select count(distinct (x->>'offer_ref')::uuid) from jsonb_array_elements(p_actor_offers) x)<>jsonb_array_length(p_actor_offers) then
      perform public.master_v2_nb_fail_v1('intento_non_valido','Identità provider duplicata.',422,p_request_key);
    end if;
  exception when invalid_text_representation then
    perform public.master_v2_nb_fail_v1('intento_non_valido','Riferimento provider non valido.',422,p_request_key);
  end;
  if (select count(*) from jsonb_object_keys(p_team_map))<>
       cardinality(p_pg_ids)+jsonb_array_length(p_actor_offers)
     or exists(select 1 from jsonb_object_keys(p_team_map) k
       where not (k=any(array(select x::text from unnest(p_pg_ids) x))
                  or k=any(array(select x->>'client_ref' from jsonb_array_elements(p_actor_offers) x)))) then
    perform public.master_v2_nb_fail_v1('intento_non_valido','Mappa squadre non esatta.',422,p_request_key);
  end if;

  perform 1 from public.locations l where l.id=v_m.location_id order by l.id for update;
  perform combat_gate_private.master_claim_assert(p_master_session,v_m.location_id);
  perform 1 from public.characters c where c.id=any(p_pg_ids) order by c.id for key share;
  perform public.master_v2_lock_scope(p_master_session);
  select * into v_m from public.master_v2_sessions where id=p_master_session for update;
  if (v_m.owner_kind<>'ai_service' or v_m.master_user is not null or v_cap is null) then perform public.master_v2_nb_fail_v1('master_non_proprietario','Controllo Master cambiato durante l’apertura.',409,p_request_key); end if;
  if v_m.tipo<>'quest' or v_m.stato not in ('preparazione','in_corso') then
    perform public.master_v2_nb_fail_v1('sessione_non_operativa','Sessione non più operativa.',409,p_request_key);
  end if;
  v_event:=public.combat_v2_event_begin_ai_service(p_master_session,p_request_key,
    'mission_generic_combat_open',jsonb_build_object('pg',p_pg_ids,'actors',p_actor_offers,'teams',p_team_map),v_m.control_version,v_cap);
  if (v_event->>'replay')::boolean then
    v_event_id:=(v_event->>'event_id')::uuid;
    insert into public.master_v2_nb_offer_audit_v1(offer_ref,event_id,action,actor_user,actor_service_capability,actor_kind)
    select (x->>'offer_ref')::uuid,v_event_id,'replay',null,v_cap,'ai_service' from jsonb_array_elements(p_actor_offers) x
    on conflict do nothing;
    return v_event->'result';
  end if;
  v_event_id:=(v_event->>'event_id')::uuid;
  if exists(select 1 from public.combat_sessions where location_id=v_m.location_id and state='aperto')
     or exists(select 1 from public.combat_v2_sessions where location_id=v_m.location_id and state not in ('chiuso','annullato')) then
    perform public.master_v2_nb_fail_v1('scontro_gia_aperto_nel_luogo','Esiste già uno scontro nel luogo.',409,p_request_key);
  end if;

  -- Ordine lock: sessione Master -> offer UUID -> narrative/binding/mechanical UUID.
  perform 1 from public.master_v2_nb_actor_offers_v1 o
   where o.offer_ref in (select (x->>'offer_ref')::uuid from jsonb_array_elements(p_actor_offers) x)
   order by o.offer_ref for update;
  if (select count(*) from public.master_v2_nb_actor_offers_v1 o
      where o.offer_ref in (select (x->>'offer_ref')::uuid from jsonb_array_elements(p_actor_offers) x))<>jsonb_array_length(p_actor_offers) then
    perform public.master_v2_nb_fail_v1('opzione_non_offerta','Opzione non offerta.',422,p_request_key);
  end if;
  perform 1 from public.nb_template_versions v where v.id in(
    select o.narrative_version_id from public.master_v2_nb_actor_offers_v1 o
    where o.offer_ref in(select (x->>'offer_ref')::uuid from jsonb_array_elements(p_actor_offers)x)) order by v.id for update;
  perform 1 from public.nb_templates t where t.id in(
    select o.narrative_template_id from public.master_v2_nb_actor_offers_v1 o
    where o.offer_ref in(select (x->>'offer_ref')::uuid from jsonb_array_elements(p_actor_offers)x)) order by t.id for update;
  perform 1 from public.nb_mechanical_bindings b where b.narrative_version_id in(
    select o.narrative_version_id from public.master_v2_nb_actor_offers_v1 o
    where o.offer_ref in(select (x->>'offer_ref')::uuid from jsonb_array_elements(p_actor_offers)x)) order by b.id for update;
  perform 1 from public.nb_mechanical_versions v where v.id in(
    select o.mechanical_version_id from public.master_v2_nb_actor_offers_v1 o
    where o.offer_ref in(select (x->>'offer_ref')::uuid from jsonb_array_elements(p_actor_offers)x)) order by v.id for update;
  perform 1 from public.nb_mechanical_templates t where t.id in(
    select o.mechanical_template_id from public.master_v2_nb_actor_offers_v1 o
    where o.offer_ref in(select (x->>'offer_ref')::uuid from jsonb_array_elements(p_actor_offers)x)) order by t.id for update;

  -- Risolve e congela tutto prima del primo INSERT di sessione/istanza.
  for v_spec in select value from jsonb_array_elements(p_actor_offers) order by value->>'offer_ref' loop
    v_client:=(v_spec->>'client_ref')::uuid; v_offer_ref:=(v_spec->>'offer_ref')::uuid;
    select * into v_offer from public.master_v2_nb_actor_offers_v1 where offer_ref=v_offer_ref;
    if v_offer.master_session_id<>p_master_session or v_offer.mission_id<>v_m.mission_id
       or (v_offer.recipient_kind<>'ai_service' or v_offer.recipient_user is not null or v_offer.recipient_service_capability is distinct from v_cap) or v_offer.lifecycle_state<>'offerta'
       or v_offer.expires_at<=clock_timestamp() then
      perform public.master_v2_nb_fail_v1('opzione_non_offerta','Opzione non offerta.',422,p_request_key);
    end if;
    select * into v_nv from public.nb_template_versions where id=v_offer.narrative_version_id and template_id=v_offer.narrative_template_id;
    select * into v_nt from public.nb_templates where id=v_offer.narrative_template_id;
    select * into v_b from public.nb_mechanical_bindings where narrative_version_id=v_offer.narrative_version_id;
    select * into v_mv from public.nb_mechanical_versions where id=v_offer.mechanical_version_id and template_id=v_offer.mechanical_template_id;
    select * into v_mt from public.nb_mechanical_templates where id=v_offer.mechanical_template_id;
    if v_nt.id is null or v_nv.id is null or v_b.id is null or v_mt.id is null or v_mv.id is null
       or v_nt.lifecycle_state<>'approved' or v_nt.current_version_id<>v_nv.id or v_nv.review_state<>'approved'
       or v_b.lifecycle_state<>'approved' or not mission_generic_owner.binding_is_pinned(p_master_session,v_b.id)
       or (not v_b.active and not exists(select 1 from public.locations where id=v_m.location_id and is_test))
       or v_b.mechanical_template_id<>v_mt.id or v_b.mechanical_version_id<>v_mv.id
       or v_mt.lifecycle_state<>'approved' or (not v_mt.active and not exists(select 1 from public.locations where id=v_m.location_id and is_test)) or v_mt.current_version_id<>v_mv.id
       or v_mv.review_state<>'approved' then
      perform public.master_v2_nb_fail_v1('opzione_non_offerta','Opzione non offerta.',422,p_request_key);
    end if;
    if v_offer.expected_master_control_version<>v_m.control_version
       or v_offer.expected_narrative_template_control_version<>v_nt.control_version
       or v_offer.expected_narrative_version_control_version<>v_nv.control_version
       or v_offer.expected_binding_control_version<>v_b.control_version
       or v_offer.expected_mechanical_template_control_version<>v_mt.control_version
       or v_offer.expected_mechanical_version_control_version<>v_mv.control_version
       or v_offer.expected_narrative_sha256<>v_nv.content_sha256
       or v_offer.expected_mechanical_sha256<>v_mv.content_sha256 then
      perform public.master_v2_nb_fail_v1('versione_provider_obsoleta','L’offerta provider è obsoleta.',409,p_request_key);
    end if;
    v_team:=nullif(btrim(p_team_map->>v_client::text),'');
    if v_team is null then perform public.master_v2_nb_fail_v1('intento_non_valido','Squadra provider mancante.',422,p_request_key); end if;
  end loop;

  insert into public.combat_v2_sessions(source_kind,master_session_id,location_id,state,lesiva)
  values('master',p_master_session,v_m.location_id,'in_corso',not exists(select 1 from public.locations l where l.id=v_m.location_id and l.is_test)) returning id into v_enc;
  foreach v_pg in array p_pg_ids loop
    v_snap:=mission_generic_owner.carry_snapshot(p_master_session,v_pg,null,public.combat_v2_character_snapshot(v_pg)); v_team:=nullif(btrim(p_team_map->>v_pg::text),'');
    if v_snap is null or v_team is null then perform public.master_v2_nb_fail_v1('intento_non_valido','Snapshot o squadra PG non disponibile.',422,p_request_key); end if;
    insert into public.combat_v2_actors(session_id,actor_kind,character_id,controller_user,team_key,position_m,initiative_snapshot,mechanics_snapshot)
    select v_enc,'pg',c.id,c.user_id,v_team,0,c.velocita,v_snap from public.characters c where c.id=v_pg;
    insert into public.master_v2_participants(session_id,character_id,user_id_snapshot)
    select p_master_session,c.id,c.user_id from public.characters c where c.id=v_pg on conflict(session_id,character_id) do nothing;
  end loop;
  for v_spec in select value from jsonb_array_elements(p_actor_offers) order by value->>'offer_ref' loop
    v_client:=(v_spec->>'client_ref')::uuid; v_offer_ref:=(v_spec->>'offer_ref')::uuid;
    select * into v_offer from public.master_v2_nb_actor_offers_v1 where offer_ref=v_offer_ref;
    select * into v_nt from public.nb_templates where id=v_offer.narrative_template_id;
    select * into v_mv from public.nb_mechanical_versions where id=v_offer.mechanical_version_id;
    v_team:=nullif(btrim(p_team_map->>v_client::text),'');
    v_snap:=jsonb_build_object('name',v_nt.display_name,'vita',v_mv.vita_max,'vita_max',v_mv.vita_max,
      'chakra',v_mv.chakra_max,'chakra_max',v_mv.chakra_max,
      'taijutsu',(v_mv.stats->>'taijutsu')::integer,'ninjutsu',(v_mv.stats->>'ninjutsu')::integer,
      'genjutsu',(v_mv.stats->>'genjutsu')::integer,'forza',(v_mv.stats->>'forza')::integer,
      'velocita',(v_mv.stats->>'velocita')::integer,'mente',(v_mv.stats->>'mente')::integer,
      'resistenza',(v_mv.stats->>'resistenza')::integer,'fuuinjutsu',(v_mv.stats->>'fuuinjutsu')::integer,
      'slancio',0,'abilities',v_mv.abilities);
    v_snap:=mission_generic_owner.carry_snapshot(p_master_session,null,v_client,v_snap);
    insert into public.combat_v2_provider_instances_v1(session_id,client_ref,provider,offer_ref,
      narrative_template_ref,narrative_version_ref,mechanical_template_ref,mechanical_version_ref,
      source_sha256,snapshot_sha256,nome,snapshot)
    values(v_enc,v_client,'ninja_book',v_offer_ref,v_offer.narrative_template_id,v_offer.narrative_version_id,
      v_offer.mechanical_template_id,v_offer.mechanical_version_id,v_mv.content_sha256,public.combat_v2_sha256(v_snap),v_nt.display_name,v_snap)
    returning id into v_instance;
    insert into public.combat_v2_actors(session_id,actor_kind,provider_instance_v1_id,controller_user,team_key,position_m,initiative_snapshot,mechanics_snapshot)
    values(v_enc,'png',v_instance,null,v_team,0,(v_mv.stats->>'velocita')::integer,v_snap);
    update public.master_v2_nb_actor_offers_v1 set lifecycle_state='consumata',consumed_event_id=v_event_id,
      consumed_at=clock_timestamp(),control_version=control_version+1,updated_at=clock_timestamp() where offer_ref=v_offer_ref;
    insert into public.master_v2_nb_offer_audit_v1(offer_ref,event_id,action,actor_user,actor_service_capability,actor_kind,details)
    values(v_offer_ref,v_event_id,'consumo',null,v_cap,'ai_service',jsonb_build_object('provider_instance_id',v_instance));
  end loop;
  select case when v_m.master_user is null then 'neutra' else 'umana' end into v_mode;
  insert into public.combat_v2_rounds(session_id,round_no,evaluation_mode) values(v_enc,1,v_mode) returning id into v_round;
  update public.master_v2_sessions set stato='in_corso' where id=p_master_session;
  if v_m.tipo='quest' and mission_internal.runtime_enabled()
     and exists(select 1 from public.mission_run_state where master_session_id=p_master_session and run_phase='preparazione') then
    perform mission_internal.sync_lifecycle(p_master_session,p_request_key,v_m.control_version,
      (select control_version from public.mission_run_state where master_session_id=p_master_session),'in_corso');
  end if;
  v_result:=public.combat_v2_envelope(p_request_key,jsonb_build_object('encounter_id',v_enc,'round_id',v_round,'evaluation_mode',v_mode));
  return public.combat_v2_event_complete(v_event_id,v_result);
end
$function$
;


create function public.mission_generic_combat_open_v1(p_session uuid,p_encounter_key text,p_expected_run_version bigint,p_request_key uuid)
returns jsonb language plpgsql security definer set search_path='' as $fn$
declare m public.master_v2_sessions;run public.mission_run_state;c mission_ai_service_owner.capabilities;
 existing mission_generic_owner.encounters;spec jsonb;scene jsonb;pgs uuid[];actors jsonb:='[]';teams jsonb:='{}';
 a jsonb;pin jsonb;offer uuid;client uuid;child uuid;res jsonb;enc uuid;arena jsonb;maps jsonb;fp text;
 nt public.nb_templates;nv public.nb_template_versions;mb public.nb_mechanical_bindings;
 mt public.nb_mechanical_templates;mv public.nb_mechanical_versions;
begin
 perform mission_ai_service_owner.service_only();
 if p_request_key is null or p_encounter_key is null or p_expected_run_version is null then raise exception 'MG_COMBAT_OPEN_INPUT';end if;
 perform mission_ai_service_owner.lock_request(p_request_key);
 select * into strict m from public.master_v2_sessions where id=p_session;
 perform 1 from public.locations where id=m.location_id for update;
 perform public.master_v2_lock_scope(p_session);
 select * into strict m from public.master_v2_sessions where id=p_session for update;
 select * into strict c from mission_ai_service_owner.capabilities where master_session_id=p_session for update;
 perform mission_generic_owner.assert_combat_scope(p_session,c.id);
 fp:=public.combat_v2_sha256(jsonb_build_object('master',p_session,'encounter',p_encounter_key,'run_version',p_expected_run_version,'capability',c.id));
 select * into existing from mission_generic_owner.encounters where master_session_id=p_session and request_key=p_request_key;
 if found then
  if existing.request_fingerprint<>fp then raise exception 'MG_COMBAT_REPLAY_CONFLICT' using errcode='40001';end if;
  return existing.open_receipt||jsonb_build_object('replayed',true);
 end if;
 select * into strict run from public.mission_run_state where master_session_id=p_session for update;
 if run.control_version<>p_expected_run_version or run.run_phase<>'in_corso'
 then raise exception 'MG_COMBAT_RUN_CAS' using errcode='40001';end if;
 scene:=mission_generic_owner.scene(p_session,run.current_step_key);
 select value into strict spec from jsonb_array_elements(scene->'encounters') where value->>'encounter_key'=p_encounter_key;
 if spec->>'pg_policy'<>'all_active' or spec->>'arena_ref'<>'mission' or jsonb_array_length(spec->'actors')=0
 then raise exception 'MG_COMBAT_SCENE_NOT_COMBAT' using errcode='22023';end if;
 if exists(select 1 from mission_generic_owner.encounters where master_session_id=p_session and
 run_control_version=run.control_version and encounter_key=p_encounter_key)
 then raise exception 'MG_COMBAT_ALREADY_OPENED_THIS_VISIT' using errcode='40001';end if;
 -- Non chiude implicitamente altri incontri o risorse. La chiusura terminale ha una propria ricevuta.
 if exists(select 1 from public.combat_v2_sessions where master_session_id=p_session and (state<>'chiuso' or closed_at is null))
 then raise exception 'MG_COMBAT_PREVIOUS_NOT_CLOSED' using errcode='55000';end if;
 select array_agg(p.character_id order by p.character_id) into pgs from public.master_v2_participants p
 join public.characters pg on pg.id=p.character_id and pg.user_id=p.user_id_snapshot
 where p.session_id=p_session and p.left_at is null and p.engagement_state='attivo';
 select coalesce(jsonb_object_agg(x::text,spec->>'pg_team'),'{}') into teams from unnest(pgs) x;
 for a in select value from jsonb_array_elements(spec->'actors') order by value->>'actor_key' loop
  select * into strict mb from public.nb_mechanical_bindings where id=(a->>'mechanical_binding_id')::uuid for share;
  if not mission_generic_owner.binding_is_pinned(p_session,mb.id) then raise exception 'MG_COMBAT_PIN_DRIFT' using errcode='40001';end if;
  select * into strict nt from public.nb_templates where id=mb.narrative_template_id for share;
  select * into strict nv from public.nb_template_versions where id=mb.narrative_version_id for share;
  select * into strict mt from public.nb_mechanical_templates where id=mb.mechanical_template_id for share;
  select * into strict mv from public.nb_mechanical_versions where id=mb.mechanical_version_id for share;
  offer:=mission_ai_service_owner.uuid5(p_request_key,'offer:'||(a->>'actor_key'));
  client:=mission_ai_service_owner.uuid5(p_session,'actor:'||(a->>'actor_key'));
  insert into public.master_v2_nb_actor_offers_v1(offer_ref,master_session_id,mission_id,recipient_user,recipient_kind,
  recipient_service_capability,narrative_template_id,narrative_version_id,mechanical_template_id,mechanical_version_id,
  expected_master_control_version,expected_narrative_template_control_version,expected_narrative_version_control_version,
  expected_binding_control_version,expected_mechanical_template_control_version,expected_mechanical_version_control_version,
  expected_narrative_sha256,expected_mechanical_sha256,lifecycle_state,control_version,expires_at,created_by,created_by_service_capability)
  values(offer,p_session,m.mission_id,null,'ai_service',c.id,nt.id,nv.id,mt.id,mv.id,m.control_version,
  nt.control_version,nv.control_version,mb.control_version,mt.control_version,mv.control_version,
  nv.content_sha256,mv.content_sha256,'offerta',1,clock_timestamp()+interval '15 minutes',null,c.id);
  actors:=actors||jsonb_build_array(jsonb_build_object('client_ref',client,'provider','ninja_book','offer_ref',offer));
  teams:=teams||jsonb_build_object(client::text,a->>'team');
 end loop;
 child:=mission_ai_service_owner.uuid5(p_request_key,'generic-encounter');
 res:=mission_generic_owner.open_core(p_session,pgs,actors,teams,child,c.id);
 enc:=(res#>>'{data,encounter_id}')::uuid;
 if enc is null then raise exception 'MG_COMBAT_NATIVE_RECEIPT_SHAPE';end if;
 select jsonb_agg(x.v order by x.v->>'actor_key') into maps from (
  select jsonb_build_object('actor_key','pg:'||ca.character_id::text,'actor_id',ca.id,'character_id',ca.character_id) v
   from public.combat_v2_actors ca where ca.session_id=enc and ca.actor_kind='pg'
  union all
  select jsonb_build_object('actor_key',j->>'actor_key','actor_id',ca.id,'mechanical_binding_id',j->>'mechanical_binding_id')
   from public.combat_v2_actors ca join public.combat_v2_provider_instances_v1 pi on pi.id=ca.provider_instance_v1_id
   cross join jsonb_array_elements(spec->'actors') j where ca.session_id=enc
   and pi.client_ref=mission_ai_service_owner.uuid5(p_session,'actor:'||(j->>'actor_key'))
 ) x;
 if jsonb_array_length(maps)<>cardinality(pgs)+jsonb_array_length(actors) then raise exception 'MG_COMBAT_MAPPING_INCOMPLETE';end if;
 update public.combat_v2_actors set state='fuori' where session_id=enc and (mechanics_snapshot->>'vita')::integer<=0;
 if (select count(distinct team_key) from public.combat_v2_actors where session_id=enc and state='attivo')<2
 then raise exception 'MG_COMBAT_NO_OPPOSING_ACTIVE_TEAMS' using errcode='22023';end if;
 res:=jsonb_build_object('schema_version','mission-generic-encounter/1','master_session_id',p_session,'encounter_id',enc,
 'step_key',run.current_step_key,'run_control_version',run.control_version,'encounter_key',p_encounter_key,'combat',res,'actor_map',maps);
 insert into mission_generic_owner.encounters(encounter_id,master_session_id,step_key,run_control_version,encounter_key,
 request_key,request_fingerprint,capability_id,actor_map,open_receipt)
 values(enc,p_session,run.current_step_key,run.control_version,p_encounter_key,p_request_key,fp,c.id,maps,res);
 arena:=mission_generic_owner.bind_arena_native(p_session,enc,p_request_key);
 -- Non aggiornare la ricevuta immutabile dopo il bind: arena IDs deterministici sono ricavabili dall'incontro.
 perform combat_panel_private.assert_master_ready(enc);
 if (select is_test from public.locations where id=m.location_id) and not combat_panel_private.uses_simulated_pools(enc)
 then raise exception 'MG_COMBAT_SIMULATION_NOT_BOUND' using errcode='42501';end if;
 return res;
end $fn$;

create function public.mission_generic_combat_close_v1(p_session uuid,p_encounter uuid,p_expected_run_version bigint,p_request_key uuid)
returns jsonb language plpgsql security definer set search_path='' as $fn$
declare e mission_generic_owner.encounters;run public.mission_run_state;s public.combat_v2_sessions;m public.master_v2_sessions;
 ev jsonb;res jsonb;
begin
 perform mission_ai_service_owner.service_only();
 if p_session is null or p_encounter is null or p_request_key is null or p_expected_run_version is null then raise exception 'MG_COMBAT_CLOSE_INPUT';end if;
 perform mission_ai_service_owner.lock_request(p_request_key);
 perform public.master_v2_lock_scope(p_session);
 select * into strict m from public.master_v2_sessions where id=p_session for update;
 select * into strict e from mission_generic_owner.encounters where encounter_id=p_encounter and master_session_id=p_session;
 perform mission_generic_owner.assert_combat_scope(p_session,e.capability_id);
 ev:=public.combat_v2_event_begin_ai_service(p_session,p_request_key,'mission_generic_combat_close',
 jsonb_build_object('encounter_id',p_encounter,'run_version',p_expected_run_version),m.control_version,e.capability_id);
 if (ev->>'replay')::boolean then return ev->'result';end if;
 select * into strict run from public.mission_run_state where master_session_id=p_session for update;
 select * into strict s from public.combat_v2_sessions where id=p_encounter and master_session_id=p_session for update;
 if run.control_version<>p_expected_run_version or run.current_step_key<>e.step_key
 or s.state<>'risolto' or s.closed_at is not null
 or not exists(select 1 from public.combat_v2_rounds where session_id=s.id)
 or exists(select 1 from public.combat_v2_rounds where session_id=s.id and state<>'narrato')
 then raise exception 'MG_COMBAT_TERMINAL_NOT_READY' using errcode='40001';end if;
 -- Stessa chiusura dell'incontro nella closure nativa, senza chiusura della missione.
 update public.combat_v2_sessions set state='chiuso',closed_at=clock_timestamp() where id=s.id;
 res:=public.combat_v2_envelope(p_request_key,jsonb_build_object('encounter_id',s.id,'state','chiuso',
 'master_session_id',p_session,'step_key',e.step_key,'encounter_key',e.encounter_key,'run_version',run.control_version,
 'terminal_event_id',(ev->>'event_id')::uuid));
 return public.combat_v2_event_complete((ev->>'event_id')::uuid,res);
end $fn$;


create function mission_generic_owner.enroll_native(p_master uuid) returns void
language plpgsql security definer set search_path='' as $fn$
declare m public.master_v2_sessions;b mission_generic_owner.run_bindings;l public.locations;policy text;
begin
 select * into strict m from public.master_v2_sessions where id=p_master for update;
 select * into strict b from mission_generic_owner.run_bindings where master_session_id=p_master;
 select * into strict l from public.locations where id=m.location_id;
 if m.owner_kind<>'ai_service' or m.master_user is not null or m.mission_id is null
 or b.snapshot_sha256<>mission_internal.fingerprint(b.snapshot)
 or b.snapshot#>>'{arena,location_id}' is distinct from m.location_id::text
 or b.snapshot#>>'{arena,mission_id}' is distinct from m.mission_id::text
 or l.is_test is null or not l.is_active
 or not exists(select 1 from mission_ai_service_owner.capabilities where master_session_id=p_master)
 then raise exception 'MG_ENROLL_AUTHORITY' using errcode='42501';end if;
 if l.is_test and l.id<>'0b85f354-9cdb-47e1-baf9-3d266bb7e06b'::uuid then raise exception 'MG_ENROLL_TEST_LOCATION' using errcode='42501';end if;
 policy:=case when l.is_test then 'staff_test_no_persistent_resources_v1' else 'master_game_resources_v1' end;
 insert into combat_panel_private.master_panel_sessions(master_session_id,location_id,policy_id)
 values(p_master,m.location_id,policy) on conflict(master_session_id) do nothing;
 if not exists(select 1 from combat_panel_private.master_panel_sessions where master_session_id=p_master and location_id=m.location_id and policy_id=policy)
 then raise exception 'MG_ENROLL_POLICY_DRIFT' using errcode='42501';end if;
end $fn$;

create function mission_generic_owner.assert_native_actor(a public.combat_v2_actors) returns void
language plpgsql security definer set search_path='' as $fn$
declare s public.combat_v2_sessions;c uuid;scene jsonb;
begin
 select * into strict s from public.combat_v2_sessions where id=a.session_id;
 select id into strict c from mission_ai_service_owner.capabilities where master_session_id=s.master_session_id and state='active';
 perform mission_generic_owner.assert_combat_scope(s.master_session_id,c);
 if a.actor_kind='pg' then
  if not exists(select 1 from public.master_v2_participants p join public.characters ch on ch.id=p.character_id and ch.user_id=p.user_id_snapshot
   where p.session_id=s.master_session_id and p.character_id=a.character_id and p.user_id_snapshot=a.controller_user
   and p.left_at is null and p.engagement_state='attivo') then raise exception 'MG_NATIVE_PG_SCOPE' using errcode='42501';end if;
 else
  if a.controller_user is not null or a.provider_instance_v1_id is null or a.png_instance_id is not null or a.companion_id is not null
  then raise exception 'MG_NATIVE_PNG_SCOPE' using errcode='42501';end if;
  scene:=mission_generic_owner.scene(s.master_session_id,(select current_step_key from public.mission_run_state where master_session_id=s.master_session_id));
  if not exists(select 1 from public.combat_v2_provider_instances_v1 pi
   join public.master_v2_nb_actor_offers_v1 o on o.offer_ref=pi.offer_ref,
   lateral jsonb_array_elements(scene->'encounters') en,lateral jsonb_array_elements(en->'actors') na
   join public.nb_mechanical_bindings mb on mb.id=(na->>'mechanical_binding_id')::uuid
   where pi.id=a.provider_instance_v1_id and pi.session_id=s.id
   and pi.client_ref=mission_ai_service_owner.uuid5(s.master_session_id,'actor:'||(na->>'actor_key'))
   and pi.narrative_version_ref=mb.narrative_version_id and pi.mechanical_version_ref=mb.mechanical_version_id
   and o.master_session_id=s.master_session_id and o.recipient_kind='ai_service' and o.recipient_service_capability=c
   and mission_generic_owner.binding_is_pinned(s.master_session_id,mb.id))
  then raise exception 'MG_NATIVE_PNG_PIN_SCOPE' using errcode='42501';end if;
 end if;
end $fn$;

do $patch$ declare src text;old text;new text;begin
 src:=pg_get_functiondef('combat_panel_private.enroll_master(uuid)'::regprocedure);
 if md5(src)<>'3c4fedad2d3f12da837cbd6fdb2eccce' then raise exception 'MG_ENROLL_BASELINE_DRIFT';end if;
 old:=' SELECT * INTO STRICT m FROM public.master_v2_sessions WHERE id=p_master FOR UPDATE;';
 new:=old||E'\n IF EXISTS(SELECT 1 FROM mission_generic_owner.run_bindings WHERE master_session_id=p_master) THEN\n  PERFORM mission_generic_owner.enroll_native(p_master); RETURN;\n END IF;';
 if (length(src)-length(replace(src,old,'')))/length(old)<>1 then raise exception 'MG_ENROLL_PATCH_DRIFT';end if;
 execute replace(src,old,new);
 src:=pg_get_functiondef('combat_panel_private.master_entry_trigger()'::regprocedure);
 if md5(src)<>'eb631425a179b3d96e4cae224900782d' then raise exception 'MG_ENTRY_BASELINE_DRIFT';end if;
 old:='   SELECT * INTO STRICT s FROM public.combat_v2_sessions WHERE id=NEW.session_id;';
 new:=old||E'\n   IF EXISTS(SELECT 1 FROM mission_generic_owner.run_bindings WHERE master_session_id=s.master_session_id) THEN\n    PERFORM mission_generic_owner.assert_native_actor(NEW); RETURN NEW;\n   END IF;';
 if (length(src)-length(replace(src,old,'')))/length(old)<>1 then raise exception 'MG_ENTRY_ACTOR_PATCH_DRIFT';end if;
 src:=replace(src,old,new);
 old:=E' ELSIF TG_TABLE_SCHEMA=''public'' AND TG_TABLE_NAME=''mission_run_state'' THEN';
 new:=old||E'\n   IF EXISTS(SELECT 1 FROM mission_generic_owner.run_bindings WHERE master_session_id=NEW.master_session_id) THEN\n    PERFORM mission_generic_owner.enroll_native(NEW.master_session_id);\n    IF NEW.plan_version_id IS DISTINCT FROM (SELECT (snapshot->>''plan_version_id'')::uuid FROM mission_generic_owner.run_bindings WHERE master_session_id=NEW.master_session_id) THEN\n     RAISE EXCEPTION ''MG_NATIVE_RUN_PLAN_DRIFT'' USING ERRCODE=''42501'';\n    END IF;\n    RETURN NEW;\n   END IF;';
 if (length(src)-length(replace(src,old,'')))/length(old)<>1 then raise exception 'MG_ENTRY_RUN_PATCH_DRIFT';end if;
 execute replace(src,old,new);
end $patch$;

-- Ricevuta spaziale nativa: stessa firma/fatti, cardinalità dal roster vivo invece di 2v2.
do $clone$ declare src text;old text;new text;begin
 src:=pg_get_functiondef('combat_spatial.exchange_owner_receipt(uuid,uuid)'::regprocedure);
 if md5(src)<>'2a33b6c81ee49015986b25379396725d' then raise exception 'MG_SPATIAL_BASELINE_DRIFT';end if;
 src:=replace(src,'combat_spatial.exchange_owner_receipt(', 'mission_generic_owner.exchange_owner_receipt(');
 old:='exact_events boolean;fp text;';new:='exact_events boolean;fp text;expected_count integer;';
 if (length(src)-length(replace(src,old,'')))/length(old)<>1 then raise exception 'MG_SPATIAL_DECLARE_DRIFT';end if;src:=replace(src,old,new);
 old:='   select * into strict t from combat_spatial.arena_templates where template_key=i.template_key and template_version=i.template_version;';
 new:=old||E'\n   IF NOT EXISTS(SELECT 1 FROM mission_generic_owner.encounters WHERE encounter_id=i.encounter_id AND master_session_id=i.master_session_id) THEN RAISE EXCEPTION ''MG_SPATIAL_SCOPE''; END IF;\n   SELECT count(*) INTO expected_count FROM combat_spatial.actor_states WHERE instance_id=p_instance AND state=''active'';';
 if (length(src)-length(replace(src,old,'')))/length(old)<>1 then raise exception 'MG_SPATIAL_ROSTER_DRIFT';end if;src:=replace(src,old,new);
 if (length(src)-length(replace(src,'count(*)=4','')))/length('count(*)=4')<>2 then raise exception 'MG_SPATIAL_COUNT_DRIFT';end if;
 src:=replace(src,'count(*)=4','count(*)=expected_count and expected_count>0');
 src:=replace(src,'count(distinct a.actor_id)=4','count(distinct a.actor_id)=expected_count');
 src:=replace(src,'count(distinct e.actor_id)=4','count(distinct e.actor_id)=expected_count');
 src:=replace(src,E'count(*)filter(where a.actor_kind=''PG'')=2 and count(*)filter(where a.actor_kind=''PNG'')=2',
 E'count(*)filter(where a.actor_kind=''PG'')>=1 and count(*)filter(where a.actor_kind=''PNG'')>=1');
 execute src;
 src:=pg_get_functiondef('combat_spatial.exchange_owner_receipt(uuid,uuid)'::regprocedure);
 old:='  begin';
 new:=old||E'\n   IF EXISTS(SELECT 1 FROM mission_generic_owner.encounters e JOIN combat_spatial.arena_instances i ON i.encounter_id=e.encounter_id WHERE i.instance_id=p_instance) THEN RETURN mission_generic_owner.exchange_owner_receipt(p_instance,p_round); END IF;';
 if (length(src)-length(replace(src,old,'')))/length(old)<>1 then raise exception 'MG_SPATIAL_HOOK_DRIFT';end if;
 execute replace(src,old,new);
end $clone$;

-- Protezione risorse: ramo Generic prima dei rami legacy, che restano intatti.
do $patch$ declare src text;old text;new text;begin
 src:=pg_get_functiondef('combat_panel_private.uses_simulated_pools(uuid)'::regprocedure);
 old:=E'BEGIN\n IF exam_regia_private.is_bound(p_session) THEN RETURN true; END IF;';
 new:=E'BEGIN\n IF EXISTS(SELECT 1 FROM mission_generic_owner.encounters WHERE encounter_id=p_session) THEN\n   RETURN mission_generic_owner.uses_simulated_pools(p_session);\n END IF;\n IF exam_regia_private.is_bound(p_session) THEN RETURN true; END IF;';
 if (length(src)-length(replace(src,old,'')))/length(old)<>1 then raise exception 'MG_RESOURCE_PATCH_DRIFT';end if;
 execute replace(src,old,new);
end $patch$;

create function mission_generic_owner.uses_simulated_pools(p_encounter uuid)
returns boolean language plpgsql security definer set search_path='' as $fn$
declare e mission_generic_owner.encounters;m public.master_v2_sessions;i combat_spatial.arena_instances;
 c combat_panel_private.master_scene_claims;principals uuid[];sim boolean;
begin
 select * into strict e from mission_generic_owner.encounters where encounter_id=p_encounter;
 select * into strict m from public.master_v2_sessions where id=e.master_session_id;
 select is_test into strict sim from public.locations where id=m.location_id and is_active;
 select * into strict i from combat_spatial.arena_instances where encounter_id=p_encounter and master_session_id=m.id and context_source='panel_master';
 select * into strict c from combat_panel_private.master_scene_claims where id=i.panel_claim_id and encounter_id=p_encounter and master_session_id=m.id;
 if c.authority_principal_id<>e.capability_id or not exists(select 1 from mission_ai_service_owner.capabilities
 where id=e.capability_id and master_session_id=m.id) then raise exception 'MG_RESOURCE_AUTHORITY' using errcode='42501';end if;
 if sim then
  select array_agg(distinct a.controller_user) into principals from public.combat_v2_actors a where a.session_id=p_encounter and a.actor_kind='pg';
  if c.policy_id<>'staff_test_no_persistent_resources_v1'
  or combat_consumer_private.staff_test_allowed(m.location_id,principals,false) is distinct from true
  or exists(select 1 from public.combat_v2_actors a left join public.characters pg on pg.id=a.character_id
    where a.session_id=p_encounter and a.actor_kind='pg' and (pg.id is null or pg.user_id is distinct from a.controller_user))
  then raise exception 'MG_RESOURCE_TEST_SCOPE' using errcode='42501';end if;
 elsif c.policy_id<>'master_game_resources_v1' then raise exception 'MG_RESOURCE_POLICY' using errcode='42501';end if;
 return sim;
end $fn$;

-- La pagina comune conserva la RPC pubblica e la stessa autorizzazione partecipanti.
-- Solo dopo tale controllo, le missioni Generic leggono la propria fonte congelata.
create function mission_generic_owner.arena_state(p_master uuid) returns jsonb
language sql stable security definer set search_path='' as $fn$
 select jsonb_build_object('schema_version','universal-arena-state/1','status','ready','master_session_id',p_master,
 'origin','mission','mission_id',m.mission_id,'location_id',m.location_id,
 'template_key',b.snapshot#>>'{arena,template_key}','template_version',(b.snapshot#>>'{arena,template_version}')::integer,
 'zone_key',b.snapshot#>>'{arena,zone_key}','catalog_sha256',b.snapshot#>>'{arena,catalog_sha256}','frozen_at',b.attached_at)
 from mission_generic_owner.run_bindings b join public.master_v2_sessions m on m.id=b.master_session_id
 where b.master_session_id=p_master and b.snapshot_sha256=mission_internal.fingerprint(b.snapshot)
$fn$;
do $patch$ declare src text;old text;new text;begin
 src:=pg_get_functiondef('public.universal_arena_state_v1(uuid)'::regprocedure);
 if md5(src)<>'406819c3379cb206f751114e27393513' then raise exception 'MG_ARENA_STATE_BASELINE_DRIFT';end if;
 old:=E' IF auth.uid() IS NULL THEN RAISE EXCEPTION ''authentication_required'' USING ERRCODE=''28000''; END IF;';
 new:=E' IF auth.uid() IS NULL THEN\n  IF EXISTS(SELECT 1 FROM mission_generic_owner.encounters e\n   JOIN public.combat_v2_sessions s ON s.id=e.encounter_id AND s.closed_at IS NULL\n   JOIN mission_ai_service_owner.capabilities c ON c.id=e.capability_id AND c.master_session_id=e.master_session_id AND c.state=''active'',\n   LATERAL jsonb_array_elements(e.actor_map) a\n   WHERE e.master_session_id=p_master AND a->>''mechanical_binding_id'' IS NOT NULL\n   AND mission_ai_service_owner.uuid5((a->>''actor_id'')::uuid,''mission-generic-principal'')=exam_regia_private.current_principal()) THEN\n   RETURN mission_generic_owner.arena_state(p_master);\n  END IF;\n  RAISE EXCEPTION ''authentication_required'' USING ERRCODE=''28000'';\n END IF;';
 if (length(src)-length(replace(src,old,'')))/length(old)<>1 then raise exception 'MG_ARENA_STATE_AUTH_PATCH_DRIFT';end if;
 src:=replace(src,old,new);
 old:=' SELECT * INTO frozen FROM combat_panel_private.universal_arena_snapshots WHERE master_session_id=m.id;';
 new:=E' IF EXISTS(SELECT 1 FROM mission_generic_owner.run_bindings WHERE master_session_id=m.id) THEN\n  RETURN mission_generic_owner.arena_state(m.id);\n END IF;\n'||old;
 if (length(src)-length(replace(src,old,'')))/length(old)<>1 then raise exception 'MG_ARENA_STATE_PATCH_DRIFT';end if;
 execute replace(src,old,new);
end $patch$;

revoke all on function mission_generic_owner.assert_combat_scope(uuid,uuid),
mission_generic_owner.binding_is_pinned(uuid,uuid),mission_generic_owner.carry_snapshot(uuid,uuid,uuid,jsonb),
mission_generic_owner.arena_multi_guard(),mission_generic_owner.bind_arena_native(uuid,uuid,uuid),
mission_generic_owner.open_core(uuid,uuid[],jsonb,jsonb,uuid,uuid),mission_generic_owner.uses_simulated_pools(uuid),mission_generic_owner.arena_state(uuid),
mission_generic_owner.enroll_native(uuid),mission_generic_owner.assert_native_actor(public.combat_v2_actors),mission_generic_owner.exchange_owner_receipt(uuid,uuid)
from public,anon,authenticated,service_role;
revoke all on function public.mission_generic_combat_open_v1(uuid,text,bigint,uuid) from public,anon,authenticated,service_role;
grant execute on function public.mission_generic_combat_open_v1(uuid,text,bigint,uuid) to service_role;
revoke all on function public.mission_generic_combat_close_v1(uuid,uuid,bigint,uuid) from public,anon,authenticated,service_role;
grant execute on function public.mission_generic_combat_close_v1(uuid,uuid,bigint,uuid) to service_role;

-- MODULE MISSION_GENERIC_PANEL.sql SHA256 03ee8476754f4c231a0b5142f57bfb8d86c7b46f7432dc57bf966ff87242d2f9
-- MISSION-GENERIC-PANEL/1. Candidate: install after DB + Combat modules.
-- Service authority is scoped to one PNG, work item and SQL transaction.
do $pin$ begin
 IF md5((select prosrc from pg_proc where oid='combat_panel_private.master_state_authoritative(uuid)'::regprocedure)) IS DISTINCT FROM 'fc2ecc2f2336a9f98e71964b6da3056a' THEN RAISE EXCEPTION 'MG_SHARED_BASELINE_DRIFT: combat_panel_private.master_state_authoritative(uuid)'; END IF;
 IF md5((select prosrc from pg_proc where oid='exam_regia_private.actor_principal(uuid,uuid)'::regprocedure)) IS DISTINCT FROM '4a55f4d6f465e49e3843ec019ab398dd' THEN RAISE EXCEPTION 'MG_SHARED_BASELINE_DRIFT: exam_regia_private.actor_principal(uuid,uuid)'; END IF;
 IF md5((select prosrc from pg_proc where oid='exam_regia_private.current_principal()'::regprocedure)) IS DISTINCT FROM '380d81087ef018194d102499cf5f7cbb' THEN RAISE EXCEPTION 'MG_SHARED_BASELINE_DRIFT: exam_regia_private.current_principal()'; END IF;
end $pin$;

create table mission_generic_owner.panel_permits (
 id uuid primary key default gen_random_uuid(),
 master_session_id uuid not null references mission_generic_owner.run_bindings(master_session_id),
 encounter_id uuid not null references mission_generic_owner.encounters(encounter_id),
 actor_id uuid not null references public.combat_v2_actors(id),
 work_id uuid not null,
 principal_id uuid not null,
 operation text not null check(operation in('options','commit')),
 request_key uuid not null,
 transaction_id bigint not null,
 backend_pid integer not null,
 created_at timestamptz not null default clock_timestamp(),
 consumed_at timestamptz
);
create table mission_generic_owner.panel_choices (
 id uuid primary key default gen_random_uuid(),
 work_id uuid not null unique,
 master_session_id uuid not null references mission_generic_owner.run_bindings(master_session_id),
 encounter_id uuid not null references mission_generic_owner.encounters(encounter_id),
 actor_id uuid not null references public.combat_v2_actors(id),
 principal_id uuid not null,
 request_key uuid not null,
 context_version bigint not null,
 controller_version bigint not null,
 legal_options jsonb not null,
 options_sha256 text not null,
 expires_at timestamptz not null,
 consumed_at timestamptz,
 command_sha256 text,
 result jsonb,
 check(options_sha256 ~ '^[0-9a-f]{64}$'),
 check((consumed_at is null)=(result is null)),
 unique(master_session_id,request_key)
);
alter table mission_generic_owner.panel_permits enable row level security;
alter table mission_generic_owner.panel_choices enable row level security;
revoke all on mission_generic_owner.panel_permits,mission_generic_owner.panel_choices from public,anon,authenticated,service_role;

create function mission_generic_owner.actor_principal(p_actor uuid) returns uuid
language sql stable security definer set search_path='' as $fn$
 select mission_ai_service_owner.uuid5(a.id,'mission-generic-principal')
 from public.combat_v2_actors a
 join mission_generic_owner.encounters e on e.encounter_id=a.session_id
 join mission_generic_owner.run_bindings b on b.master_session_id=e.master_session_id
 join public.master_v2_sessions m on m.id=e.master_session_id
 join public.combat_v2_sessions s on s.id=e.encounter_id
 join mission_ai_service_owner.capabilities c on c.id=e.capability_id and c.master_session_id=m.id
 where a.id=p_actor and a.actor_kind='png' and a.controller_user is null and a.character_id is null
 and m.owner_kind='ai_service' and m.master_user is null and m.closed_at is null
 and s.closed_at is null and s.state not in('chiuso','annullato') and c.state='active'
 and b.snapshot_sha256=mission_internal.fingerprint(b.snapshot)
 and exists(select 1 from jsonb_array_elements(e.actor_map) x where x->>'actor_id'=a.id::text)
$fn$;

create function mission_generic_owner.current_principal() returns uuid
language plpgsql stable security definer set search_path='' as $fn$
declare v uuid; n integer;
begin
 if auth.uid() is not null or not public.combat_v2_is_service() then return null; end if;
 select count(distinct p.principal_id),(array_agg(p.principal_id))[1] into n,v
 from mission_generic_owner.panel_permits p
 join mission_generic_owner.runtime_policy pol on pol.singleton and pol.mode<>'off'
 join public.master_v2_sessions m on m.id=p.master_session_id
 join public.locations l on l.id=m.location_id
 where p.transaction_id=txid_current() and p.backend_pid=pg_backend_pid() and p.consumed_at is null
 and p.created_at>clock_timestamp()-interval '150 seconds'
 and p.principal_id=mission_generic_owner.actor_principal(p.actor_id)
 and (pol.mode='all' or (pol.mode='test' and l.is_test));
 if n>1 then raise exception 'MG_AMBIGUOUS_PANEL_AUTHORITY' using errcode='42501'; end if;
 return v;
end $fn$;

create function mission_generic_owner.principal_in_session(p_session uuid,p_principal uuid) returns boolean
language sql stable security definer set search_path='' as $fn$
 select p_principal is not null and p_principal=mission_generic_owner.current_principal()
 and exists(select 1 from mission_generic_owner.panel_permits p
 where p.master_session_id=p_session and p.principal_id=p_principal
 and p.transaction_id=txid_current() and p.backend_pid=pg_backend_pid() and p.consumed_at is null)
$fn$;

create function mission_generic_owner.choice_options(p_session uuid,p_actor uuid,p_work uuid,p_request uuid)
returns jsonb language plpgsql security definer set search_path='' as $fn$
declare a public.combat_v2_actors%rowtype; e mission_generic_owner.encounters%rowtype;
 c mission_generic_owner.panel_choices%rowtype; m public.master_v2_sessions%rowtype;
 env jsonb; permit uuid; principal uuid; persona jsonb;
begin
 if auth.uid() is not null or not public.combat_v2_is_service() or p_work is null or p_request is null
 then raise exception 'MG_SERVICE_REQUIRED' using errcode='42501'; end if;
 perform mission_generic_owner.assert_runtime(p_session);
 select * into strict m from public.master_v2_sessions where id=p_session for update;
 select * into c from mission_generic_owner.panel_choices where work_id=p_work for update;
 if found then
  if c.master_session_id<>p_session or c.actor_id<>p_actor or c.request_key<>p_request or c.expires_at<=clock_timestamp()
  then raise exception 'MG_CHOICE_STALE' using errcode='40001'; end if;
 else
  select * into strict a from public.combat_v2_actors where id=p_actor and actor_kind='png'
   and controller_user is null and character_id is null and companion_id is null and state='attivo' for update;
  select * into strict e from mission_generic_owner.encounters where encounter_id=a.session_id and master_session_id=p_session;
  principal:=mission_generic_owner.actor_principal(p_actor);
  if principal is null then raise exception 'MG_ACTOR_NOT_BOUND' using errcode='42501'; end if;
  insert into mission_generic_owner.panel_permits(master_session_id,encounter_id,actor_id,work_id,principal_id,operation,request_key,transaction_id,backend_pid)
  values(p_session,e.encounter_id,p_actor,p_work,principal,'options',p_request,txid_current(),pg_backend_pid()) returning id into permit;
  env:=combat_panel_private.master_projection(m.location_id,p_actor);
  env:=combat_panel_private.master_options(m.location_id,p_actor,(env#>>'{context,version}')::bigint);
  if env->>'status' is distinct from 'ready' or env#>>'{context,activity_id}' is distinct from e.encounter_id::text
   or env#>>'{viewer,command_actor_id}' is distinct from p_actor::text
   or env#>>'{viewer,can_command}' is distinct from 'true'
   or jsonb_array_length(env->'offers')=0
  then raise exception 'MG_CHOICE_NOT_READY' using errcode='55000'; end if;
  -- Administration never becomes an AI actor choice.
  if exists(select 1 from jsonb_array_elements(env->'offers') x where x->>'kind'='administration')
  then raise exception 'MG_ADMIN_OFFER_FORBIDDEN' using errcode='42501'; end if;
  insert into mission_generic_owner.panel_choices(work_id,master_session_id,encounter_id,actor_id,principal_id,request_key,
   context_version,controller_version,legal_options,options_sha256,expires_at)
  values(p_work,p_session,e.encounter_id,p_actor,principal,p_request,(env#>>'{context,version}')::bigint,
   a.controller_version,env,public.combat_v2_sha256(env),clock_timestamp()+interval '150 seconds') returning * into c;
  update mission_generic_owner.panel_permits set consumed_at=clock_timestamp() where id=permit;
 end if;
 -- Identity/persona are taken from the approved provider version, not model output.
 select jsonb_build_object('identity',nv.skeleton->'identity','voice',nv.skeleton->'voice',
  'conduct',nv.skeleton->'conduct','goals',nv.skeleton->'goals','motivations',nv.skeleton->'motivations',
  'knowledge_limits',nv.skeleton->'knowledge_limits','knowledge_boundary',nv.knowledge_boundary) into persona
 from public.combat_v2_actors aa join public.combat_v2_provider_instances_v1 pi on pi.id=aa.provider_instance_v1_id
 join public.nb_template_versions nv on nv.id=pi.narrative_version_ref where aa.id=c.actor_id;
 return jsonb_build_object('capability_id',c.id,'actor_id',c.actor_id,'legal_options',c.legal_options,
  'context_version',c.context_version,'request_key',c.request_key,'persona',persona,
  'encounter_id',c.encounter_id,'authority_receipt_id',c.id,
  'authorized_context',jsonb_build_object('context',c.legal_options->'context','viewer',c.legal_options->'viewer')); 
end $fn$;

create function mission_generic_owner.choice_commit(p_work uuid,p_capability uuid,p_command jsonb)
returns jsonb language plpgsql security definer set search_path='' as $fn$
declare c mission_generic_owner.panel_choices%rowtype; a public.combat_v2_actors%rowtype;
 cmd jsonb; fp text; o combat_panel_private.offers%rowtype; permit uuid; res jsonb;
begin
 if auth.uid() is not null or not public.combat_v2_is_service() then raise exception 'MG_SERVICE_REQUIRED' using errcode='42501'; end if;
 select * into strict c from mission_generic_owner.panel_choices where id=p_capability and work_id=p_work for update;
 cmd:=combat_panel_private.validate_command(p_command);fp:=public.combat_v2_sha256(cmd);
 if c.consumed_at is not null then
  if c.command_sha256 is distinct from fp then raise exception 'MG_COMMAND_REPLAY_CONFLICT' using errcode='22023'; end if;
  return c.result;
 end if;
 perform mission_generic_owner.assert_runtime(c.master_session_id);
 select * into strict a from public.combat_v2_actors where id=c.actor_id and session_id=c.encounter_id for update;
 if c.expires_at<=clock_timestamp() or a.controller_version<>c.controller_version or a.state<>'attivo'
  or c.principal_id is distinct from mission_generic_owner.actor_principal(a.id)
  or c.options_sha256 is distinct from public.combat_v2_sha256(c.legal_options)
  or c.request_key is distinct from (cmd->>'request_key')::uuid
  or c.encounter_id is distinct from (cmd->>'activity_id')::uuid
  or c.context_version is distinct from (cmd->>'context_version')::bigint
  or cmd->>'location_id' is distinct from c.legal_options#>>'{context,location_id}'
 then raise exception 'MG_CHOICE_STALE' using errcode='40001'; end if;
 select * into strict o from combat_panel_private.offers where id=(cmd->>'offer_id')::uuid
  and principal_user=c.principal_id and actor_id=c.actor_id and state='offered';
 if o.kind='administration' or not exists(select 1 from jsonb_array_elements(c.legal_options->'offers') x where x->>'offer_id'=o.id::text)
 then raise exception 'MG_COMMAND_FORBIDDEN' using errcode='42501'; end if;
 insert into mission_generic_owner.panel_permits(master_session_id,encounter_id,actor_id,work_id,principal_id,operation,request_key,transaction_id,backend_pid)
 values(c.master_session_id,c.encounter_id,c.actor_id,p_work,c.principal_id,'commit',c.request_key,txid_current(),pg_backend_pid()) returning id into permit;
 res:=case when o.source_payload->>'dispatch'='multiplication' then combat_panel_private.commit_multiplication(cmd)
  else combat_panel_private.commit_master_actor(cmd) end;
 update mission_generic_owner.panel_permits set consumed_at=clock_timestamp() where id=permit;
 update mission_generic_owner.panel_choices set consumed_at=clock_timestamp(),command_sha256=fp,result=res where id=c.id;
 return res;
end $fn$;

-- New helpers stay private: service clients must enter through the work dispatcher.
revoke all on function mission_generic_owner.actor_principal(uuid),mission_generic_owner.current_principal(),
 mission_generic_owner.principal_in_session(uuid,uuid),mission_generic_owner.choice_options(uuid,uuid,uuid,uuid),
 mission_generic_owner.choice_commit(uuid,uuid,jsonb) from public,anon,authenticated,service_role;

-- Shared hooks preserve real user and existing examination authority.
CREATE OR REPLACE FUNCTION combat_panel_private.master_state_authoritative(p_location uuid)
 RETURNS jsonb
 LANGUAGE plpgsql
 STABLE SECURITY DEFINER
 SET search_path TO ''
AS $function$
declare
  v_uid uuid:=exam_regia_private.current_principal();
  v_m public.master_v2_sessions%rowtype;
  v_s public.combat_v2_sessions%rowtype;
  v_r public.combat_v2_rounds%rowtype;
  v_is_admin boolean:=false;
  v_is_master boolean:=false;
  v_is_participant boolean:=false;
begin
  if v_uid is null then
    perform public.combat_v2_fail('autenticazione_richiesta','Autenticazione richiesta.',401,null,'{}');
  end if;

  select * into v_m
    from public.master_v2_sessions
   where location_id=p_location and stato not in ('chiusa','annullata')
   order by created_at desc limit 1;

  if v_m.id is null then
    return public.combat_v2_envelope(null,jsonb_build_object(
      'viewer',jsonb_build_object('is_master',false,'is_admin',public.combat_v2_is_admin(v_uid)),
      'master',null,'encounter',null,'actors','[]'::jsonb,'round',null,
      'declarations','[]'::jsonb,'pending_defenses','[]'::jsonb,
      'ratings_pending','[]'::jsonb,'report',null));
  end if;

  v_is_admin:=public.combat_v2_is_admin(v_uid);
  v_is_master:=coalesce(v_m.master_user=v_uid,false);
  select exists(
    select 1 from public.master_v2_participants p
     where p.session_id=v_m.id and p.user_id_snapshot=v_uid
       and p.engagement_state in ('attivo','sospeso')
  ) into v_is_participant;

  v_is_participant:=v_is_participant OR EXISTS(SELECT 1 FROM exam_regia_private.bindings b
 WHERE b.master_session_id=v_m.id AND b.service_principal_id=v_uid AND b.state<>'closed'
 AND v_uid=exam_regia_private.current_principal());
  v_is_participant:=v_is_participant OR mission_generic_owner.principal_in_session(v_m.id,v_uid);
  if not (v_is_master or v_is_admin or v_is_participant) then
    perform public.combat_v2_fail('master_non_proprietario','Sessione non accessibile.',403,null,'{}');
  end if;

  select * into v_s
    from public.combat_v2_sessions
   where master_session_id=v_m.id and state not in ('chiuso','annullato')
   order by created_at desc limit 1;

  if v_s.id is not null then
    select * into v_r
      from public.combat_v2_rounds
     where session_id=v_s.id
     order by round_no desc limit 1;
  end if;

  return public.combat_v2_envelope(null,jsonb_build_object(
    'viewer',jsonb_build_object(
      'is_master',v_is_master,
      'is_admin',v_is_admin,
      'is_participant',v_is_participant),
    'master',jsonb_build_object(
      'id',v_m.id,'location_id',v_m.location_id,'tipo',v_m.tipo,
      'stato',v_m.stato,
      'control_version',v_m.control_version,'mission_id',v_m.mission_id,
      'titolo',v_m.titolo,'suspended_at',v_m.suspended_at),
    'encounter',case when v_s.id is null then null else jsonb_build_object(
      'id',v_s.id,'state',v_s.state,'source_kind',v_s.source_kind,
      'location_id',v_s.location_id,'lesiva',v_s.lesiva) end,
    'actors',case when v_s.id is null then '[]'::jsonb else coalesce((
      select jsonb_agg(jsonb_build_object(
        'id',a.id,
        'kind',a.actor_kind,
        'name',coalesce(c.name,p.nome,pi.nome,'Attore'),
        'character_id',a.character_id,
        'team',a.team_key,
        'state',a.state,
        'position_m',a.position_m,
        'initiative',a.initiative_snapshot,
        'mine',exam_regia_private.actor_principal(a.id,a.controller_user)=v_uid,
        'has_action',exists(
          select 1 from public.combat_v2_declarations d
           where d.round_id=v_r.id and d.actor_id=a.id
             and d.kind in ('attacco','movimento','utilita','passa')),
        'reaction_used',exists(
          select 1 from public.combat_v2_declarations d
           join public.combat_v2_declarations x on x.id=d.parent_attack_id
           where d.round_id=v_r.id and d.kind='difesa'
             and x.target_actor_id=a.id),
        'resources',case when v_is_master or v_is_admin or exam_regia_private.actor_principal(a.id,a.controller_user)=v_uid
          then jsonb_build_object(
            'vita',a.mechanics_snapshot->'vita',
            'vita_max',a.mechanics_snapshot->'vita_max',
            'chakra',a.mechanics_snapshot->'chakra',
            'chakra_max',a.mechanics_snapshot->'chakra_max')
          else null end
      ) order by a.initiative_snapshot desc,a.id)
      from public.combat_v2_actors a
      left join public.characters c on c.id=a.character_id
      left join public.combat_v2_png_instances p on p.id=a.png_instance_id left join public.combat_v2_provider_instances_v1 pi on pi.id=a.provider_instance_v1_id
      where a.session_id=v_s.id
    ),'[]'::jsonb) end,
    'round',case when v_r.id is null then null else jsonb_build_object(
      'id',v_r.id,'no',v_r.round_no,'phase',v_r.phase,'state',v_r.state,
      'evaluation_mode',v_r.evaluation_mode,'report_id',v_r.report_id,
      'resolved_at',v_r.resolved_at,'narrated_at',v_r.narrated_at) end,
    'declarations',case when v_r.id is null then '[]'::jsonb else coalesce((
      select jsonb_agg(jsonb_build_object(
        'id',d.id,'actor_id',d.actor_id,'actor_name',coalesce(ac.name,ap.nome,aip.nome,'Attore'),
        'actor_kind',aa.actor_kind,'kind',d.kind,
        'target_actor_id',d.target_actor_id,'target_name',coalesce(tc.name,tp.nome,tip.nome,'Attore'),
        'parent_attack_id',d.parent_attack_id,'targets',(select coalesce(jsonb_agg(jsonb_build_object('attack_target_id',t.id,'ordinal',t.ordinal,'target_actor_id',t.target_actor_id,'state',t.state,'outcome',case when v_r.state in('risolto','narrazione','narrato')then t.outcome else null end)order by t.ordinal),'[]'::jsonb)from public.combat_v2_attack_targets t where t.attack_declaration_id=d.id),'coverage',(select coalesce(jsonb_agg(jsonb_build_object('attack_target_id',c.attack_target_id,'protected_actor_id',c.protected_actor_id,'mode',c.mode,'state',c.state)order by c.id),'[]'::jsonb)from public.combat_v2_defense_coverages c where c.defense_declaration_id=d.id),'state',d.state,'order_no',d.order_no,
        'text',case when v_is_master or v_is_admin or exam_regia_private.actor_principal(aa.id,aa.controller_user)=v_uid
                         or exam_regia_private.actor_principal(ta.id,ta.controller_user)=v_uid or v_r.state in ('risolto','narrazione','narrato')
                    then d.declaration_text else '' end,
        'choice',jsonb_strip_nulls(jsonb_build_object(
          'kind',d.sanitized_intent->>'kind',
          'reaction',d.sanitized_intent->>'reaction',
          'ability_name',d.sanitized_intent->'server_ability'->>'name')),
        'rating',case
          when rr.id is null then null
          when v_is_admin or (rr.source<>'revisione_admin' and (v_is_master or exam_regia_private.actor_principal(aa.id,aa.controller_user)=v_uid))
          then jsonb_build_object('id',rr.id,'value',rr.value,'reason',rr.reason,
                                 'source',rr.source,'created_at',rr.created_at)
          else null end
      ) order by d.order_no nulls last,d.created_at,d.id)
      from public.combat_v2_declarations d
      join public.combat_v2_actors aa on aa.id=d.actor_id
      left join public.characters ac on ac.id=aa.character_id
      left join public.combat_v2_png_instances ap on ap.id=aa.png_instance_id left join public.combat_v2_provider_instances_v1 aip on aip.id=aa.provider_instance_v1_id
      left join public.combat_v2_actors ta on ta.id=d.target_actor_id
      left join public.characters tc on tc.id=ta.character_id
      left join public.combat_v2_png_instances tp on tp.id=ta.png_instance_id left join public.combat_v2_provider_instances_v1 tip on tip.id=ta.provider_instance_v1_id
      left join lateral (
        select r0.* from public.combat_v2_ratings r0
         where r0.declaration_id=d.id and r0.is_active
         order by r0.created_at desc limit 1
      ) rr on true
      where d.round_id=v_r.id
        and (v_is_master or v_is_admin or exam_regia_private.actor_principal(aa.id,aa.controller_user)=v_uid
             or exam_regia_private.actor_principal(ta.id,ta.controller_user)=v_uid or v_r.state in ('risolto','narrazione','narrato'))
    ),'[]'::jsonb) end,
    'pending_defenses',case when v_r.id is null then '[]'::jsonb else coalesce((
      select jsonb_agg(jsonb_build_object(
        'attack_declaration_id',d.id,
        'attacker_actor_id',d.actor_id,
        'attacker_name',coalesce(ac.name,ap.nome,aip.nome,'Attore'),
        'target_actor_id',d.target_actor_id,
        'target_name',coalesce(tc.name,tp.nome,tip.nome,'Attore'),
        'text',case when v_is_master or v_is_admin or exam_regia_private.actor_principal(ta.id,ta.controller_user)=v_uid
                    then d.declaration_text else '' end
      ) order by d.created_at,d.id)
      from public.combat_v2_declarations d
      join public.combat_v2_actors aa on aa.id=d.actor_id
      left join public.characters ac on ac.id=aa.character_id
      left join public.combat_v2_png_instances ap on ap.id=aa.png_instance_id left join public.combat_v2_provider_instances_v1 aip on aip.id=aa.provider_instance_v1_id
      join public.combat_v2_actors ta on ta.id=d.target_actor_id
      left join public.characters tc on tc.id=ta.character_id
      left join public.combat_v2_png_instances tp on tp.id=ta.png_instance_id left join public.combat_v2_provider_instances_v1 tip on tip.id=ta.provider_instance_v1_id
      where d.round_id=v_r.id and d.kind='attacco'
        and not exists(select 1 from public.combat_v2_declarations x
                        where x.parent_attack_id=d.id and x.kind in ('difesa','nessuna'))
        and (v_is_master or v_is_admin or exam_regia_private.actor_principal(ta.id,ta.controller_user)=v_uid)
    ),'[]'::jsonb) end,
    'ratings_pending',case when not (v_is_master or v_is_admin) or v_r.id is null
      then '[]'::jsonb else coalesce((
        select jsonb_agg(jsonb_build_object(
          'declaration_id',d.id,'kind',d.kind,
          'actor_id',d.actor_id,'actor_name',c.name,
          'text',d.declaration_text
        ) order by d.created_at,d.id)
        from public.combat_v2_declarations d
        join public.combat_v2_actors a on a.id=d.actor_id and a.actor_kind='pg'
        join public.characters c on c.id=a.character_id
        where d.round_id=v_r.id and d.kind in ('attacco','difesa')
          and not exists(select 1 from public.combat_v2_ratings x
                          where x.declaration_id=d.id and x.is_active)
      ),'[]'::jsonb) end,
    'report',case when v_r.id is null or not (v_is_master or v_is_admin) then null else (
      select jsonb_build_object(
        'id',q.id,'sha256',q.mechanics_sha256,'mechanics',q.mechanics,
        'values_written',q.values_written,'narration_state',q.narration_state,
        'narrator_kind',q.narrator_kind,'created_at',q.created_at)
      from public.combat_v2_round_reports q where q.round_id=v_r.id
    ) end
  ));
end
$function$;

CREATE OR REPLACE FUNCTION exam_regia_private.actor_principal(p_actor uuid, p_user uuid)
 RETURNS uuid
 LANGUAGE sql
 STABLE SECURITY DEFINER
 SET search_path TO ''
AS $function$
 SELECT coalesce(p_user,(SELECT b.service_principal_id FROM exam_regia_private.bindings b
  WHERE b.png_actor_id=p_actor AND b.state<>'closed'),mission_generic_owner.actor_principal(p_actor));
$function$;

CREATE OR REPLACE FUNCTION exam_regia_private.current_principal()
 RETURNS uuid
 LANGUAGE plpgsql
 STABLE SECURITY DEFINER
 SET search_path TO ''
AS $function$
DECLARE principal uuid; generic_principal uuid;
BEGIN
 IF auth.uid() IS NOT NULL THEN RETURN auth.uid(); END IF;
 IF NOT public.combat_v2_is_service() THEN RETURN NULL; END IF;
 generic_principal:=mission_generic_owner.current_principal();
 IF NOT EXISTS(SELECT 1 FROM exam_regia_private.runtime WHERE singleton AND enabled) THEN RETURN generic_principal; END IF;
 SELECT p.principal_id INTO principal FROM exam_regia_private.execution_permits p
 JOIN exam_regia_private.bindings b ON b.prova_id=p.prova_id AND b.png_actor_id=p.actor_id
  AND b.service_principal_id=p.principal_id AND b.state IN ('active','paused')
 JOIN public.combat_v2_sessions s ON s.id=b.combat_session_id AND s.master_session_id=b.master_session_id
  AND s.source_kind='master' AND NOT s.lesiva AND s.closed_at IS NULL
 JOIN public.master_v2_sessions m ON m.id=b.master_session_id AND m.owner_kind='ai_service'
  AND m.master_user IS NULL AND m.closed_at IS NULL
 WHERE p.transaction_id=txid_current() AND p.backend_pid=pg_backend_pid() AND p.consumed_at IS NULL
  AND p.created_at>clock_timestamp()-interval '150 seconds';
 IF principal IS NULL THEN RETURN generic_principal; END IF;
 IF generic_principal IS NOT NULL AND generic_principal<>principal THEN RAISE EXCEPTION 'MG_AMBIGUOUS_PANEL_AUTHORITY' USING ERRCODE='42501'; END IF;
 IF (SELECT count(DISTINCT p.principal_id) FROM exam_regia_private.execution_permits p
  WHERE p.transaction_id=txid_current() AND p.backend_pid=pg_backend_pid() AND p.consumed_at IS NULL)>1
 THEN RAISE EXCEPTION 'exam_regia_ambiguous_authority' USING ERRCODE='42501'; END IF;
 RETURN principal;
END $function$;

-- MODULE MISSION_GENERIC_CLAN_OPTIONS.sql SHA256 1af3ee0aaf385591b0af05bcb9d112878982f06483b38fcf68d3b355fcd225c4
-- MISSION-GENERIC-CLAN-OPTIONS/1 — A1 MG-SRC-R1-01; no gate/technique enable.

do $patch$ declare body text;ddl text;o text;n text;begin
 select prosrc,pg_get_functiondef(oid) into strict body,ddl from pg_proc where oid='clan_hyuga_private.master_control_offers(uuid,bigint)'::regprocedure
 and prosecdef and pg_get_userbyid(proowner)='postgres' and proconfig=ARRAY['search_path=""']
 and proacl::text='{postgres=X/postgres}';
 if md5(body)<>'7f9bdd705b4bd629401c7315f2ec2bc7' then raise exception 'MG_CLAN_OPTIONS_BASELINE_DRIFT';end if;
 o:=$old$ SELECT * INTO STRICT a FROM public.combat_v2_actors WHERE id=c.command_actor_id AND session_id=c.activity_id
   AND controller_user=auth.uid();$old$;
 n:=$new$ SELECT * INTO STRICT a FROM public.combat_v2_actors WHERE id=c.command_actor_id AND session_id=c.activity_id
   AND CASE WHEN auth.uid() IS NOT NULL THEN controller_user=auth.uid()
    ELSE actor_kind='png' AND controller_user IS NULL
     AND mission_generic_owner.current_principal()=mission_generic_owner.actor_principal(id) END;$new$;
 if (length(ddl)-length(replace(ddl,o,'')))/length(o)<>1 then raise exception 'MG_CLAN_OPTIONS_ANCHOR_DRIFT';end if;
 execute replace(ddl,o,n);
end $patch$;

do $patch$ declare body text;ddl text;o text;n text;begin
 select prosrc,pg_get_functiondef(oid) into strict body,ddl from pg_proc where oid='clan_innata_private.sharingan_master_control_offers(uuid,bigint)'::regprocedure
 and prosecdef and pg_get_userbyid(proowner)='postgres' and proconfig=ARRAY['search_path=""']
 and proacl::text='{postgres=X/postgres}';
 if md5(body)<>'110e2293ac42e3817ae977ccc92e9fe5' then raise exception 'MG_CLAN_OPTIONS_BASELINE_DRIFT';end if;
 o:=$old$ SELECT * INTO STRICT a FROM public.combat_v2_actors WHERE id=c.command_actor_id AND session_id=c.activity_id
   AND controller_user=auth.uid();$old$;
 n:=$new$ SELECT * INTO STRICT a FROM public.combat_v2_actors WHERE id=c.command_actor_id AND session_id=c.activity_id
   AND CASE WHEN auth.uid() IS NOT NULL THEN controller_user=auth.uid()
    ELSE actor_kind='png' AND controller_user IS NULL
     AND mission_generic_owner.current_principal()=mission_generic_owner.actor_principal(id) END;$new$;
 if (length(ddl)-length(replace(ddl,o,'')))/length(o)<>1 then raise exception 'MG_CLAN_OPTIONS_ANCHOR_DRIFT';end if;
 execute replace(ddl,o,n);
end $patch$;

-- CREATE OR REPLACE conserva le ACL private dei due helper; nessun nuovo GRANT pubblico.

-- MODULE MISSION_GENERIC_BOARD.sql SHA256 f0827febfea3f6f86e20b745d69ac5b33102b8f2a5ec9250c14ca290637a1774
-- MISSION-GENERIC-BOARD/1 candidate. Dependency order: DB, PLAN_WRITER, BOARD,
-- COMBAT authority delta, DISPATCH. No enable/apply has been performed.
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

-- MODULE MISSION_GENERIC_DISPATCH.sql SHA256 03d6d4c5158e7a72fe11e0721ccb97023e4de3c4ae2073070eb2efea4d0a7aa0
-- MISSION-GENERIC-DISPATCH/1; candidate, no apply. Requires MISSION_GENERIC_DB.sql.
-- New work items use native mission accounting, never the legacy phase publisher.
alter table mission_narrative_internal.dispatch_receipts drop constraint dispatch_receipts_event_kind_check;
alter table mission_narrative_internal.dispatch_receipts add constraint dispatch_receipts_event_kind_check check
 (event_kind in('combat_round_complete','combat_terminal','briefing_miyo','lettura_ambiente','raccolta_tracce',
 'transizione_inseguimento','incontro_refurtiva','scontro_2v2','recupero','chiusura_miyo','mission_opening_preview','mission_generic_event'));
alter table mission_narrative_internal.dispatch_receipts drop constraint dispatch_receipts_renderer_version_check;
alter table mission_narrative_internal.dispatch_receipts add constraint dispatch_receipts_renderer_version_check check
 (renderer_version in('mission-surface-renderer/2.0','mission-generic-runtime/1'));
alter table mission_narrative_internal.dispatch_receipts add constraint dispatch_receipts_generic_pair_check check
 ((event_kind='mission_generic_event')=(renderer_version='mission-generic-runtime/1'));

create table mission_generic_owner.dispatch_admissions (
 master_session_id uuid primary key references mission_generic_owner.run_bindings(master_session_id),
 enabled boolean not null default false,
 call_limit integer not null check(call_limit>0),
 cost_budget_usd numeric not null check(cost_budget_usd>0),
 calls_authorized integer not null default 0 check(calls_authorized>=0),
 admitted_at timestamptz not null default clock_timestamp(),
 check(calls_authorized<=call_limit)
);
create table mission_generic_owner.work_items (
 id uuid primary key default gen_random_uuid(),
 master_session_id uuid not null references mission_generic_owner.run_bindings(master_session_id),
 event_id uuid not null default gen_random_uuid(),
 request_key uuid not null default gen_random_uuid(),
 dedupe_key text not null,
 step_key text not null,
 run_control_version bigint not null check(run_control_version>0),
 definition_sha256 text not null check(definition_sha256~'^[0-9a-f]{64}$'),
 encounter_id uuid,
 authority_receipt_id uuid not null,
 kind text not null check(kind in('choice','narration')),
 revision bigint not null check(revision>0),
 payload jsonb not null check(jsonb_typeof(payload)='object'),
 payload_sha256 text not null check(payload_sha256~'^[0-9a-f]{64}$'),
 state text not null default 'ready' check(state in('ready','claimed','authorized','provider_started','completed','failed','uncertain')),
 lease_id uuid,
 lease_expires_at timestamptz,
 dispatch_receipt_id uuid unique references mission_narrative_internal.dispatch_receipts(id),
 authorization_id uuid unique references mission_narrative_internal.provider_authorizations(id),
 dispatch_id uuid unique,
 result jsonb,
 result_sha256 text check(result_sha256~'^[0-9a-f]{64}$'),
 receipt_id uuid unique,
 message_id uuid unique references public.messages(id),
 created_at timestamptz not null default clock_timestamp(),
 finalized_at timestamptz,
 unique(master_session_id,event_id),unique(master_session_id,request_key),unique(master_session_id,dedupe_key),
 check((state in('completed','failed','uncertain'))=(finalized_at is not null))
);
alter table mission_generic_owner.dispatch_admissions enable row level security;
alter table mission_generic_owner.work_items enable row level security;
revoke all on mission_generic_owner.dispatch_admissions,mission_generic_owner.work_items from public,anon,authenticated,service_role;

create function mission_generic_owner.dispatch_user(p_session uuid,p_user uuid)
returns void language plpgsql security definer set search_path='' as $fn$
begin
 perform mission_ai_board_owner.service_only();
 if p_user is null or not exists(select 1 from public.master_v2_sessions s
  where s.id=p_session and s.owner_kind='ai_service' and s.mission_id is not null
  and (exists(select 1 from public.profiles p where p.id=p_user and p.role in('admin','master'))
   or exists(select 1 from public.master_v2_participants mp join public.characters c on c.id=mp.character_id and c.user_id=p_user
    where mp.session_id=s.id and mp.user_id_snapshot=p_user and mp.left_at is null)))
 then raise exception 'MGD_USER_SCOPE' using errcode='42501';end if;
end;
$fn$;

-- Private explicit admission, called by the reviewed setup/release, never a player.
create function mission_generic_owner.dispatch_admit(p_session uuid,p_calls integer,p_cost numeric)
returns void language plpgsql security definer set search_path='' as $fn$
declare a mission_generic_owner.dispatch_admissions;
begin
 perform mission_generic_owner.assert_runtime(p_session);
 if p_calls is null or p_calls<1 or p_cost is null or p_cost<=0 then raise exception 'MGD_BUDGET_REQUIRED';end if;
 select * into a from mission_generic_owner.dispatch_admissions where master_session_id=p_session for update;
 if found then
  if a.call_limit<>p_calls or a.cost_budget_usd<>p_cost then raise exception 'MGD_ADMISSION_CONFLICT' using errcode='40001';end if;
  return;
 end if;
 insert into mission_generic_owner.dispatch_admissions(master_session_id,enabled,call_limit,cost_budget_usd)
 values(p_session,true,p_calls,p_cost);
end;
$fn$;

create function mission_generic_owner.work_status(w mission_generic_owner.work_items)
returns jsonb language sql stable set search_path='' as $fn$
select jsonb_build_object('schema_version','mission-generic-status/1','work_id',w.id,'master_session_id',w.master_session_id,
 'event_id',w.event_id,'request_key',w.request_key,'revision',w.revision,'state',w.state,
 'receipt_id',w.receipt_id,'result_sha256',w.result_sha256)
$fn$;

create function mission_generic_owner.work_assert(w mission_generic_owner.work_items)
returns void language plpgsql security definer set search_path='' as $fn$
declare r public.mission_run_state;b mission_generic_owner.run_bindings;m public.master_v2_sessions;
begin
 perform mission_generic_owner.assert_runtime(w.master_session_id);
 select * into strict m from public.master_v2_sessions where id=w.master_session_id for share;
 select * into strict r from public.mission_run_state where master_session_id=w.master_session_id for share;
 select * into strict b from mission_generic_owner.run_bindings where master_session_id=w.master_session_id;
 if m.owner_kind<>'ai_service' or m.closed_at is not null
 or (w.payload ? 'opening_start_receipt_id' and (m.stato<>'preparazione' or r.run_phase<>'preparazione'
  or not exists(select 1 from mission_generic_owner.board_starts bs where bs.id=(w.payload->>'opening_start_receipt_id')::uuid
   and bs.master_session_id=w.master_session_id and bs.state='prepared')))
 or (not(w.payload ? 'opening_start_receipt_id') and m.stato<>'in_corso')
 or r.current_step_key<>w.step_key or r.control_version<>w.run_control_version
 or b.snapshot_sha256<>w.definition_sha256 or b.snapshot_sha256<>mission_internal.fingerprint(b.snapshot)
 or w.payload_sha256<>public.combat_v2_sha256(w.payload)
 then raise exception 'MGD_WORK_STALE' using errcode='40001';end if;
end;
$fn$;

-- Private shared context producer: source facts are supplied only by the typed
-- opening/transition owner below. No RPC grants or arbitrary client JSON ingress.
create function mission_generic_owner.narrative_context(p_session uuid,p_step text,p_authority uuid,p_cutoff timestamptz,p_facts jsonb)
returns jsonb language plpgsql security definer set search_path='' as $fn$
declare r public.mission_run_state;b mission_generic_owner.run_bindings;m public.master_v2_sessions;
 sc jsonb;a jsonb;pin jsonb;nv public.nb_template_versions;nt public.nb_templates;
 actors jsonb:='[]';sources jsonb:='[]';ctx jsonb;loc text;from_at timestamptz;persona text;previous_fato jsonb;
begin
 select * into strict m from public.master_v2_sessions where id=p_session;
 select * into strict r from public.mission_run_state where master_session_id=p_session;
 select * into strict b from mission_generic_owner.run_bindings where master_session_id=p_session;
 sc:=mission_generic_owner.scene(p_session,p_step);
 select name into strict loc from public.locations where id=m.location_id;
 select coalesce(jsonb_agg(jsonb_build_object('id',p.character_id::text,'name',c.name,'kind','PG','persona',null,'may_speak',false) order by p.joined_at,p.character_id),'[]')
 into actors from public.master_v2_participants p join public.characters c on c.id=p.character_id where p.session_id=p_session and p.left_at is null;
 for a in select value from jsonb_array_elements(sc->'actors') loop
  if a->>'mechanical_binding_id' is not null then
   select x into strict pin from jsonb_array_elements(b.snapshot->'binding_pins') x where x->>'mechanical_binding_id'=a->>'mechanical_binding_id';
  else
   select x into strict pin from jsonb_array_elements(b.snapshot->'narrative_pins') x where x->>'narrative_version_id'=a->>'narrative_version_id';
  end if;
  select * into strict nv from public.nb_template_versions where id=(pin->>'narrative_version_id')::uuid
   and control_version=(pin->>'narrative_version_control_version')::bigint and content_sha256=pin->>'narrative_content_sha256' and review_state='approved';
  select * into strict nt from public.nb_templates where id=nv.template_id
   and control_version=(pin->>'narrative_template_control_version')::bigint and lifecycle_state='approved';
  -- Voice and gestures only: no memory, secrets, goals or knowledge_boundary.
  persona:=jsonb_build_object('nome',nt.display_name,'voce',nv.skeleton->'voice','gesti',nv.skeleton->'gestures')::text;
  actors:=actors||jsonb_build_array(jsonb_build_object('id','png:'||(a->>'actor_key'),'name',nt.display_name,'kind','PNG','persona',persona,'may_speak',true));
 end loop;
 select coalesce(max(x.finalized_at),m.created_at) into from_at from mission_generic_owner.work_items x
 where x.master_session_id=p_session and x.kind='narration' and x.state='completed';
 select coalesce(jsonb_agg(jsonb_build_object('id',msg.id::text,'master_session_id',p_session,'kind','role','actor_id',msg.character_id::text,
  'sequence',q.seq,'body',msg.body,'sha256',encode(extensions.digest(convert_to(msg.body,'UTF8'),'sha256'),'hex'),
  'visibility','public','complete',true) order by q.seq),'[]') into sources
 from (select z.id,row_number() over(order by z.created_at,z.id)::bigint seq from public.messages z
  where z.location_id=m.location_id and z.kind='say' and z.recipient_user is null and z.created_at>from_at and z.created_at<=p_cutoff
  and exists(select 1 from public.master_v2_participants mp where mp.session_id=p_session and mp.character_id=z.character_id
   and mp.user_id_snapshot=z.sender_user and mp.joined_at<=z.created_at and (mp.left_at is null or mp.left_at>z.created_at))) q
 join public.messages msg on msg.id=q.id;
 select jsonb_build_object('id',msg.id::text,'master_session_id',p_session,'kind','fato','actor_id',null,'sequence',0,
  'body',msg.body,'sha256',encode(extensions.digest(convert_to(msg.body,'UTF8'),'sha256'),'hex'),'visibility','public','complete',true)
 into previous_fato from mission_generic_owner.work_items x join public.messages msg on msg.id=x.message_id
 where x.master_session_id=p_session and x.kind='narration' and x.state='completed'
 order by x.finalized_at desc,x.id desc limit 1;
 if previous_fato is not null then sources:=jsonb_build_array(previous_fato)||sources;end if;
 ctx:=jsonb_build_object('schema_version','mission-narrative-context/1','master_session_id',p_session,'step_key',p_step,
  'run_control_version',r.control_version,'definition_sha256',b.snapshot_sha256,'authority_receipt_id',p_authority,
  'location',loc,'actors',actors,'sources',sources,'resolved_facts',p_facts);
 return ctx;
end;
$fn$;

-- A genuine Board bind/opening event, with no artificial player choice or round.
create function mission_generic_owner.enqueue_opening(p_session uuid,p_start uuid)
returns jsonb language plpgsql security definer set search_path='' as $fn$
declare s mission_generic_owner.board_starts;m public.master_v2_sessions;r public.mission_run_state;
 b mission_generic_owner.run_bindings;e public.mission_run_events;ob public.mission_run_outbox;
 w mission_generic_owner.work_items;obj text;ctx jsonb;payload jsonb;briefing text;title text;
begin
 select * into strict m from public.master_v2_sessions where id=p_session for update;
 perform mission_generic_owner.assert_runtime(p_session);
 select * into strict s from mission_generic_owner.board_starts where id=p_start and master_session_id=p_session;
 select * into w from mission_generic_owner.work_items where master_session_id=p_session and dedupe_key='opening:'||s.id;
 if found then return mission_generic_owner.work_status(w);end if;
 select * into strict r from public.mission_run_state where master_session_id=p_session;
 select * into strict b from mission_generic_owner.run_bindings where master_session_id=p_session;
 select * into strict e from public.mission_run_events where id=s.event_id and master_session_id=p_session;
 select * into strict ob from public.mission_run_outbox where event_id=e.id and master_session_id=p_session;
 if s.state<>'prepared' or s.snapshot_sha256<>mission_internal.fingerprint(s.snapshot)
 or m.stato<>'preparazione' or m.closed_at is not null or r.run_phase<>'preparazione'
 or e.operation_kind<>'bind' or e.status<>'committed' or e.version_after<>r.control_version
 or r.control_version<>1 or e.step_after<>r.current_step_key or ob.state<>'pending'
 or ob.event_version_after<>e.version_after or ob.step_key<>e.step_after or ob.context_fingerprint<>e.context_fingerprint
 or not exists(select 1 from public.master_v2_participants mp where mp.session_id=p_session and mp.left_at is null)
 then raise exception 'MGD_OPENING_SOURCE_INVALID';end if;
 select public_objective into strict obj from public.mission_plan_steps where plan_version_id=r.plan_version_id and step_key=r.current_step_key;
 select mi.title,mi.briefing into strict title,briefing from public.missions mi where mi.id=m.mission_id;
 ctx:=mission_generic_owner.narrative_context(p_session,r.current_step_key,s.id,s.created_at,
  jsonb_build_object('missione',title,'incarico',briefing,'obiettivo_iniziale',obj,
  'nota_autorita','È l’apertura della missione. L’incarico non è completato; parole, azioni e decisioni dei PG restano ai giocatori.'));
 payload:=jsonb_build_object('schema_version','mission-generic-narration/1','mode','mission','opening_start_receipt_id',s.id,
  'barrier',jsonb_build_object('closed',true,'required_receipt_ids',jsonb_build_array(s.id,e.id),'receipt_ids',jsonb_build_array(s.id,e.id)),
  'context',ctx);
 insert into mission_generic_owner.work_items(master_session_id,event_id,dedupe_key,step_key,run_control_version,definition_sha256,
  authority_receipt_id,kind,revision,payload,payload_sha256)
 values(p_session,s.id,'opening:'||s.id,r.current_step_key,r.control_version,b.snapshot_sha256,s.id,'narration',r.control_version,
  payload,public.combat_v2_sha256(payload)) returning * into w;
 return mission_generic_owner.work_status(w);
end;
$fn$;

-- A trigger receipt already committed by the native controller is the only source
-- of this narrative event. No JSON, persona, role or evidence arrives from a client.
create function mission_generic_owner.enqueue_transition(p_session uuid,p_receipt uuid)
returns jsonb language plpgsql security definer set search_path='' as $fn$
declare tr mission_generic_owner.trigger_receipts;e public.mission_run_events;r public.mission_run_state;
 b mission_generic_owner.run_bindings;m public.master_v2_sessions;sc jsonb;a jsonb;pin jsonb;nv public.nb_template_versions;nt public.nb_templates;
 actors jsonb:='[]';sources jsonb:='[]';ctx jsonb;payload jsonb;w mission_generic_owner.work_items;
 loc text;obj text;before_obj text;from_at timestamptz;rid uuid;name text;persona text;trigger_label text;previous_fato jsonb;
begin
 select * into strict m from public.master_v2_sessions where id=p_session for update;
 perform mission_generic_owner.assert_runtime(p_session);
 select * into strict tr from mission_generic_owner.trigger_receipts where id=p_receipt and master_session_id=p_session;
 select * into strict e from public.mission_run_events where id=(tr.result->>'event_id')::uuid and master_session_id=p_session and status='committed';
 select * into strict r from public.mission_run_state where master_session_id=p_session for share;
 select * into strict b from mission_generic_owner.run_bindings where master_session_id=p_session;
 select * into w from mission_generic_owner.work_items where master_session_id=p_session and dedupe_key='transition:'||tr.id;
 if found then return mission_generic_owner.work_status(w);end if;
 if e.step_after<>r.current_step_key or e.version_after<>r.control_version or e.version_before<>tr.run_control_version
 or e.step_before<>tr.step_key or tr.result->>'authority_receipt_id'<>tr.id::text then raise exception 'MGD_TRANSITION_STALE' using errcode='40001';end if;
 select public_objective into strict obj from public.mission_plan_steps where plan_version_id=r.plan_version_id and step_key=e.step_after;
 select public_objective into strict before_obj from public.mission_plan_steps where plan_version_id=r.plan_version_id and step_key=e.step_before;
 select x->>'label' into strict trigger_label from jsonb_array_elements(mission_generic_owner.scene(p_session,e.step_before)->'triggers') x
 where x->>'trigger_key'=tr.trigger_key;
 ctx:=mission_generic_owner.narrative_context(p_session,e.step_after,tr.id,tr.issued_at,jsonb_build_object(
  'obiettivo_precedente',before_obj,'obiettivo_corrente',obj,'passaggio_autorizzato',trigger_label,
  'nota_autorita','La transizione autorizza il nuovo obiettivo; non attesta il suo completamento né esiti meccanici ulteriori.'));
 payload:=jsonb_build_object('schema_version','mission-generic-narration/1','mode','mission','barrier',
  jsonb_build_object('closed',true,'required_receipt_ids',jsonb_build_array(tr.id,e.id),'receipt_ids',jsonb_build_array(tr.id,e.id)),'context',ctx);
 insert into mission_generic_owner.work_items(master_session_id,event_id,dedupe_key,step_key,run_control_version,definition_sha256,
  authority_receipt_id,kind,revision,payload,payload_sha256)
 values(p_session,tr.id,'transition:'||tr.id,e.step_after,r.control_version,b.snapshot_sha256,tr.id,'narration',r.control_version,payload,public.combat_v2_sha256(payload)) returning * into w;
 return mission_generic_owner.work_status(w);
end;
$fn$;

-- The committed trigger result is inserted after mission_internal.transition;
-- enqueue in the same transaction so no phase advances without a pending work item.
create function mission_generic_owner.trigger_dispatch_enqueue()
returns trigger language plpgsql security definer set search_path='' as $fn$
begin
 perform mission_generic_owner.enqueue_transition(new.master_session_id,new.id);
 return new;
end;
$fn$;
create trigger mission_generic_trigger_dispatch after insert on mission_generic_owner.trigger_receipts
for each row execute function mission_generic_owner.trigger_dispatch_enqueue();

-- Invoked only by the private, source-validating encounter owner. Choice options
-- are generated now from Common; the caller cannot submit a panel or a persona.
create function mission_generic_owner.enqueue_choice(p_session uuid,p_encounter uuid,p_actor uuid)
returns jsonb language plpgsql security definer set search_path='' as $fn$
declare r public.mission_run_state;b mission_generic_owner.run_bindings;w mission_generic_owner.work_items;
 o jsonb;payload jsonb;wid uuid:=gen_random_uuid();req uuid:=gen_random_uuid();key text;
begin
 perform 1 from public.master_v2_sessions where id=p_session for update;
 perform mission_generic_owner.assert_runtime(p_session);
 select * into strict r from public.mission_run_state where master_session_id=p_session;
 select * into strict b from mission_generic_owner.run_bindings where master_session_id=p_session;
 select * into w from mission_generic_owner.work_items where master_session_id=p_session and encounter_id=p_encounter
  and kind='choice' and payload->>'actor_id'=p_actor::text and state not in('completed','failed') order by created_at,id limit 1;
 if found then return mission_generic_owner.work_status(w);end if;
 o:=mission_generic_owner.choice_options(p_session,p_actor,wid,req);
 if o->>'actor_id' is distinct from p_actor::text or (o#>>'{legal_options,context,activity_id}') is null
 or jsonb_typeof(o->'persona') is distinct from 'object'
 or o->>'encounter_id' is distinct from p_encounter::text then raise exception 'MGD_CHOICE_SOURCE_INVALID';end if;
 key:='choice:'||p_encounter||':'||p_actor||':'||(o->>'context_version');
 select * into w from mission_generic_owner.work_items where master_session_id=p_session and dedupe_key=key;
 if found then return mission_generic_owner.work_status(w);end if;
 payload:=jsonb_build_object('schema_version','mission-generic-choice/1','actor_id',p_actor,'capability_id',o->'capability_id',
  'command_request_key',o->'request_key','persona',(o->'persona')::text,'authorized_context',coalesce(o->'authorized_context','{}'),
  'combat_session_id',o#>'{legal_options,context,activity_id}','round_id',o#>'{legal_options,context,round_id}',
  'context_version',o->'context_version','policy_id',o#>'{legal_options,context,policy_id}',
  'simulated',o#>'{legal_options,context,simulated}','legal_options',o->'legal_options');
 insert into mission_generic_owner.work_items(id,master_session_id,dedupe_key,step_key,run_control_version,definition_sha256,
  encounter_id,authority_receipt_id,kind,revision,payload,payload_sha256)
 values(wid,p_session,key,r.current_step_key,r.control_version,b.snapshot_sha256,p_encounter,(o->>'authority_receipt_id')::uuid,
  'choice',r.control_version,payload,public.combat_v2_sha256(payload)) returning * into w;
 return mission_generic_owner.work_status(w);
end;
$fn$;

-- The Combat owner hook must build the whole frozen scene AFTER required command
-- and resolver receipts exist. No scene JSON can be supplied through this function.
create function mission_generic_owner.enqueue_combat(p_session uuid,p_event uuid)
returns jsonb language plpgsql security definer set search_path='' as $fn$
declare s jsonb;r public.mission_run_state;b mission_generic_owner.run_bindings;w mission_generic_owner.work_items;
begin
 perform 1 from public.master_v2_sessions where id=p_session for update;
 perform mission_generic_owner.assert_runtime(p_session);
 select * into w from mission_generic_owner.work_items where master_session_id=p_session and dedupe_key='combat:'||p_event;
 if found then return mission_generic_owner.work_status(w);end if;
 s:=mission_generic_owner.combat_narrative_source(p_session,p_event);
 select * into strict r from public.mission_run_state where master_session_id=p_session;
 select * into strict b from mission_generic_owner.run_bindings where master_session_id=p_session;
 if s->>'master_session_id' is distinct from p_session::text or s->>'step_key' is distinct from r.current_step_key
 or (s->>'run_control_version')::bigint is distinct from r.control_version
 or s#>>'{payload,barrier,closed}' is distinct from 'true' or s#>>'{payload,mode}' is distinct from 'combat'
 then raise exception 'MGD_COMBAT_SOURCE_INVALID';end if;
 insert into mission_generic_owner.work_items(master_session_id,event_id,dedupe_key,step_key,run_control_version,definition_sha256,
  encounter_id,authority_receipt_id,kind,revision,payload,payload_sha256)
 values(p_session,p_event,'combat:'||p_event,r.current_step_key,r.control_version,b.snapshot_sha256,(s->>'encounter_id')::uuid,
  (s->>'authority_receipt_id')::uuid,'narration',r.control_version,s->'payload',public.combat_v2_sha256(s->'payload')) returning * into w;
 return mission_generic_owner.work_status(w);
end;
$fn$;

create function public.mission_generic_dispatch_next_v1(p_session uuid,p_user uuid)
returns jsonb language plpgsql security definer set search_path='' as $fn$
declare w mission_generic_owner.work_items;
begin
 perform mission_generic_owner.dispatch_user(p_session,p_user);
 select * into w from mission_generic_owner.work_items where master_session_id=p_session
 and state not in('completed','failed') order by created_at,id limit 1;
 if not found then return jsonb_build_object('state','idle');end if;
 return jsonb_build_object('state',w.state,'request',jsonb_build_object('schema_version','mission-generic-request/1',
 'master_session_id',w.master_session_id,'event_id',w.event_id,'request_key',w.request_key,'expected_revision',w.revision));
end;
$fn$;

create function public.mission_generic_dispatch_status_v1(p_user uuid,p_request jsonb)
returns jsonb language plpgsql security definer set search_path='' as $fn$
declare w mission_generic_owner.work_items;
begin
 perform mission_generic_owner.dispatch_user((p_request->>'master_session_id')::uuid,p_user);
 select * into strict w from mission_generic_owner.work_items where master_session_id=(p_request->>'master_session_id')::uuid
 and event_id=(p_request->>'event_id')::uuid and request_key=(p_request->>'request_key')::uuid and revision=(p_request->>'expected_revision')::bigint;
 return mission_generic_owner.work_status(w);
end;
$fn$;

create function public.mission_generic_dispatch_claim_v1(p_user uuid,p_request jsonb)
returns jsonb language plpgsql security definer set search_path='' as $fn$
declare w mission_generic_owner.work_items;a mission_generic_owner.dispatch_admissions;pol mission_narrative_internal.runtime_policy;
 dr uuid;env jsonb;fp text;limits jsonb;
begin
 perform mission_generic_owner.dispatch_user((p_request->>'master_session_id')::uuid,p_user);
 perform 1 from public.master_v2_sessions where id=(p_request->>'master_session_id')::uuid for update;
 select * into strict w from mission_generic_owner.work_items where master_session_id=(p_request->>'master_session_id')::uuid
 and event_id=(p_request->>'event_id')::uuid and request_key=(p_request->>'request_key')::uuid and revision=(p_request->>'expected_revision')::bigint for update;
 if w.state<>'ready' then return jsonb_build_object('state',w.state,'granted_now',false);end if;
 perform mission_generic_owner.work_assert(w);
 select * into strict a from mission_generic_owner.dispatch_admissions where master_session_id=w.master_session_id for share;
 select * into strict pol from mission_narrative_internal.runtime_policy where singleton for share;
 if not a.enabled or a.calls_authorized>=a.call_limit or not pol.enabled or pol.model<>'gpt-5.6-luna' or pol.reasoning_effort<>'high' or pol.store
 then raise exception 'MGD_PROVIDER_CLOSED';end if;
 limits:=jsonb_build_object('provider_calls_remaining',a.call_limit-a.calls_authorized,'max_output_tokens',least(9992,pol.max_output_tokens),
  'max_input_bytes',least(49152,pol.max_input_tokens),'max_request_bytes',least(65536,pol.max_input_tokens),
  'transport_max_chars',5000,'provider_timeout_ms',120000);
 if octet_length(w.payload::text)>(limits->>'max_input_bytes')::integer then raise exception 'MGD_CONTEXT_OVERFLOW';end if;
 env:=jsonb_build_object('work_id',w.id,'master_session_id',w.master_session_id,'event_id',w.event_id,'authority_receipt_id',w.authority_receipt_id,
  'payload_sha256',w.payload_sha256,'definition_sha256',w.definition_sha256,'revision',w.revision);
 fp:=mission_internal.fingerprint(p_request);
 insert into mission_narrative_internal.dispatch_receipts(master_session_id,authority_receipt_id,event_kind,renderer_version,request_key,
  request_fingerprint,authority_sha256,envelope,envelope_sha256,status)
 values(w.master_session_id,w.id,'mission_generic_event','mission-generic-runtime/1',w.request_key,fp,
  public.combat_v2_sha256(env),env,public.combat_v2_sha256(env),'claimed') returning id into dr;
 update mission_generic_owner.work_items set state='claimed',dispatch_receipt_id=dr,lease_id=gen_random_uuid(),
  lease_expires_at=clock_timestamp()+interval '180 seconds' where id=w.id returning * into w;
 return jsonb_build_object('state','claimed','granted_now',true,'work',jsonb_build_object('schema_version','mission-generic-work/1',
  'work_id',w.id,'master_session_id',w.master_session_id,'event_id',w.event_id,'request_key',w.request_key,'revision',w.revision,
  'step_key',w.step_key,'run_control_version',w.run_control_version,'definition_sha256',w.definition_sha256,
  'encounter_id',w.encounter_id,'authority_receipt_id',w.authority_receipt_id,'kind',w.kind,'lease_id',w.lease_id,
  'server_now',clock_timestamp(),'lease_expires_at',w.lease_expires_at,'payload_sha256',w.payload_sha256,'payload',w.payload,'limits',limits));
end;
$fn$;

-- A definite failure before any reservation/authorization is recorded separately
-- from provider finalization. Only the service with the claimed lease can close it.
create function public.mission_generic_dispatch_reject_v1(p_user uuid,p_request jsonb,p_lease uuid,p_code text)
returns jsonb language plpgsql security definer set search_path='' as $fn$
declare w mission_generic_owner.work_items;d mission_narrative_internal.dispatch_receipts;
 receipt uuid:=gen_random_uuid();failure_result jsonb;fp text;
begin
 perform mission_generic_owner.dispatch_user((p_request->>'master_session_id')::uuid,p_user);
 if p_code not in('work_validation_failed','request_validation_failed') or p_code is null or p_lease is null
 then raise exception 'MGD_REJECTION_INPUT';end if;
 perform 1 from public.master_v2_sessions where id=(p_request->>'master_session_id')::uuid for update;
 select * into strict w from mission_generic_owner.work_items where master_session_id=(p_request->>'master_session_id')::uuid
 and event_id=(p_request->>'event_id')::uuid and request_key=(p_request->>'request_key')::uuid
 and revision=(p_request->>'expected_revision')::bigint for update;
 if w.lease_id is distinct from p_lease then raise exception 'MGD_REJECTION_LEASE';end if;
 if w.state='failed' and w.result->>'schema_version'='mission-generic-pre-provider-failure/1' then
  if w.result->>'failure_code' is distinct from p_code then raise exception 'MGD_REJECTION_REPLAY_CONFLICT';end if;
  return mission_generic_owner.work_status(w);
 end if;
 select * into strict d from mission_narrative_internal.dispatch_receipts where id=w.dispatch_receipt_id for update;
 if w.state<>'claimed' or w.authorization_id is not null or w.dispatch_id is not null
 or d.status<>'claimed' or d.dispatch_count<>0 or d.master_session_id<>w.master_session_id
 or d.authority_receipt_id<>w.id or d.event_kind<>'mission_generic_event'
 or d.renderer_version<>'mission-generic-runtime/1' or d.request_key<>w.request_key
 or exists(select 1 from mission_narrative_internal.dispatch_attempts where receipt_id=d.id)
 or exists(select 1 from mission_narrative_internal.provider_authorizations where receipt_id=d.id)
 then raise exception 'MGD_REJECTION_NOT_PRE_PROVIDER';end if;
 failure_result:=jsonb_build_object('schema_version','mission-generic-pre-provider-failure/1','work_id',w.id,
 'master_session_id',w.master_session_id,'event_id',w.event_id,'request_key',w.request_key,'revision',w.revision,
 'ok',false,'failure_code',p_code,'provider_calls',0,'charged_cost_usd',0);
 fp:=public.combat_v2_sha256(failure_result);
 update mission_narrative_internal.dispatch_receipts set status='failed',charged_cost_usd=0,upper_bound_cost_usd=0,
 lease_token_sha256=null,lease_expires_at=null,finalized_at=clock_timestamp(),updated_at=clock_timestamp() where id=d.id;
 update mission_generic_owner.work_items set state='failed',result=failure_result,result_sha256=fp,receipt_id=receipt,
 finalized_at=clock_timestamp() where id=w.id returning * into w;
 insert into mission_narrative_internal.dispatch_audit(receipt_id,event_code,details)
 values(d.id,'generic_pre_provider_failed',jsonb_build_object('work_id',w.id,'receipt_id',receipt,'failure_code',p_code,
 'provider_calls',0,'charged_cost_usd',0,'result_sha256',fp));
 return mission_generic_owner.work_status(w);
end;
$fn$;

create function public.mission_generic_dispatch_authorize_v1(p_work uuid,p_lease uuid,p_worker_token text,p_policy jsonb)
returns jsonb language plpgsql security definer set search_path='' as $fn$
declare w mission_generic_owner.work_items;a mission_generic_owner.dispatch_admissions;pol mission_narrative_internal.runtime_policy;
 rr jsonb;z jsonb;spent numeric;ub numeric;
begin
 perform mission_ai_board_owner.service_only();
 perform 1 from public.master_v2_sessions where id=(select master_session_id from mission_generic_owner.work_items where id=p_work) for update;
 select * into strict w from mission_generic_owner.work_items where id=p_work for update;
 perform mission_generic_owner.work_assert(w);
 if w.state<>'claimed' or w.lease_id<>p_lease or w.lease_expires_at<=clock_timestamp()
 or p_policy->>'payload_sha256' is distinct from w.payload_sha256 then raise exception 'MGD_AUTHORIZE_STALE';end if;
 select * into strict a from mission_generic_owner.dispatch_admissions where master_session_id=w.master_session_id for update;
 select * into strict pol from mission_narrative_internal.runtime_policy where singleton;
 if not a.enabled or a.calls_authorized>=a.call_limit or p_policy->>'model' is distinct from pol.model
 or p_policy->>'reasoning_effort' is distinct from pol.reasoning_effort or p_policy->>'store' is distinct from 'false'
 or (p_policy->>'max_output_tokens')::integer is distinct from pol.max_output_tokens then raise exception 'MGD_ADMISSION_INVALID';end if;
 ub:=(pol.max_input_tokens*pol.input_usd_million+pol.max_output_tokens*pol.output_usd_million)/1000000;
 select coalesce(sum(case when d.status in('success','fallback','unknown_billable') then coalesce(d.charged_cost_usd,0)
  else coalesce(d.upper_bound_cost_usd,0) end),0) into spent
 from mission_narrative_internal.dispatch_receipts d where d.master_session_id=w.master_session_id;
 if spent+ub>a.cost_budget_usd then raise exception 'MGD_RUN_BUDGET_EXHAUSTED';end if;
 rr:=public.mission_narrative_attempt_reserve_internal(p_worker_token,w.dispatch_receipt_id,180,null,null);
 if rr->>'status'<>'reserved' then raise exception 'MGD_NATIVE_RESERVE_REJECTED';end if;
 z:=public.mission_narrative_provider_authorize_internal(p_worker_token,w.dispatch_receipt_id,(rr->>'attempt_id')::uuid,rr->>'lease_token');
 update mission_generic_owner.dispatch_admissions set calls_authorized=calls_authorized+1 where master_session_id=w.master_session_id;
 update mission_generic_owner.work_items set state='authorized',authorization_id=(z->>'authorization_id')::uuid where id=w.id;
 return z||jsonb_build_object('work_id',w.id,'granted_now',true);
end;
$fn$;

create function public.mission_generic_dispatch_consume_v1(p_work uuid,p_lease uuid,p_worker_token text,p_authorization uuid,p_dispatch_token text)
returns jsonb language plpgsql security definer set search_path='' as $fn$
declare w mission_generic_owner.work_items;z jsonb;d uuid:=gen_random_uuid();
begin
 perform mission_ai_board_owner.service_only();
 perform 1 from public.master_v2_sessions where id=(select master_session_id from mission_generic_owner.work_items where id=p_work) for update;
 select * into strict w from mission_generic_owner.work_items where id=p_work for update;
 perform mission_generic_owner.work_assert(w);
 if w.state<>'authorized' or w.authorization_id<>p_authorization or w.lease_id<>p_lease or w.lease_expires_at<=clock_timestamp()
 then raise exception 'MGD_CONSUME_STALE';end if;
 z:=public.mission_narrative_provider_consume_internal(p_worker_token,p_authorization,p_dispatch_token);
 update mission_generic_owner.work_items set state='provider_started',dispatch_id=d where id=w.id;
 return jsonb_build_object('work_id',w.id,'authorization_id',p_authorization,'dispatch_id',d,'granted_now',true,'finalize_token',z->>'finalize_token');
end;
$fn$;

create function public.mission_generic_dispatch_finalize_v1(p_work uuid,p_finalize_token text,p_result_text text,p_result_sha text)
returns jsonb language plpgsql security definer set search_path='' as $fn$
declare w mission_generic_owner.work_items;d mission_narrative_internal.dispatch_receipts;z mission_narrative_internal.provider_authorizations;
 pol mission_narrative_internal.runtime_policy;a mission_narrative_internal.dispatch_attempts;
 ok boolean;stale boolean:=false;metrics jsonb;actual numeric;basis text;receipt uuid:=gen_random_uuid();msg uuid;cr jsonb;
 p_result jsonb;tr mission_generic_owner.trigger_receipts;ev public.mission_run_events;ob public.mission_run_outbox;
 publication uuid;bodysha text;bs mission_generic_owner.board_starts;
 application_error text;outcome_uncertain boolean:=false;
begin
 perform mission_ai_board_owner.service_only();
 perform 1 from public.master_v2_sessions where id=(select master_session_id from mission_generic_owner.work_items where id=p_work) for update;
 if p_result_text is null or octet_length(p_result_text)>65536
 or encode(extensions.digest(convert_to(p_result_text,'UTF8'),'sha256'),'hex') is distinct from p_result_sha
 then raise exception 'MGD_RESULT_HASH';end if;
 p_result:=p_result_text::jsonb;
 select * into strict w from mission_generic_owner.work_items where id=p_work for update;
 if w.state in('completed','failed','uncertain') then
  if w.result_sha256 is distinct from p_result_sha then raise exception 'MGD_FINALIZE_CONFLICT' using errcode='40001';end if;
  return mission_generic_owner.work_status(w);
 end if;
 select * into strict d from mission_narrative_internal.dispatch_receipts where id=w.dispatch_receipt_id for update;
 select * into strict z from mission_narrative_internal.provider_authorizations where id=w.authorization_id and receipt_id=d.id for update;
 select * into strict a from mission_narrative_internal.dispatch_attempts where id=z.attempt_id for update;
 select * into strict pol from mission_narrative_internal.runtime_policy where singleton for share;
 if w.state<>'provider_started' or d.status<>'provider_started' or z.finalize_token_sha256 is distinct from mission_narrative_internal.token_sha(p_finalize_token)
 or p_result->>'schema_version' is distinct from 'mission-generic-result/1' or p_result->>'work_id' is distinct from w.id::text
 or p_result->>'master_session_id' is distinct from w.master_session_id::text or p_result->>'event_id' is distinct from w.event_id::text
 or p_result->>'request_key' is distinct from w.request_key::text or (p_result->>'revision')::bigint is distinct from w.revision
 or p_result->>'authority_receipt_id' is distinct from w.authority_receipt_id::text or p_result->>'definition_sha256' is distinct from w.definition_sha256
 or p_result->>'payload_sha256' is distinct from w.payload_sha256 or p_result->>'kind' is distinct from w.kind
 or p_result->>'authorization_id' is distinct from w.authorization_id::text or p_result->>'dispatch_id' is distinct from w.dispatch_id::text
 or p_result->>'model' is distinct from pol.model or coalesce(p_result_sha,'')!~'^[0-9a-f]{64}$'
 or p_result->>'runtime_version' is distinct from 'mission-generic-runtime/1'
 or p_result->>'provider_calls' not in('0','1')
 or jsonb_typeof(p_result->'outcome_uncertain') is distinct from 'boolean'
 or (p_result->>'outcome_uncertain'='true' and p_result->>'ok' is distinct from 'false')
 or (p_result->>'ok'='true' and p_result->>'provider_calls' is distinct from '1')
 then raise exception 'MGD_FINALIZE_BINDING';end if;
 -- The exact canonical string is hashed before JSONB parsing; no JS/JSONB equivalence assumption.
 metrics:=p_result->'usage';
 if jsonb_typeof(metrics) is distinct from 'object' then metrics:='{}';end if;
 if jsonb_typeof(metrics)='object' and mission_generic_owner.keys_valid(metrics,array['input_tokens','output_tokens','reasoning_tokens','total_tokens'])
 and not exists(select 1 from jsonb_each_text(metrics) where value!~'^[0-9]+$')
 and (metrics->>'reasoning_tokens')::numeric<=(metrics->>'output_tokens')::numeric
 and (metrics->>'total_tokens')::numeric=(metrics->>'input_tokens')::numeric+(metrics->>'output_tokens')::numeric then
  actual:=((metrics->>'input_tokens')::numeric*pol.input_usd_million+(metrics->>'output_tokens')::numeric*pol.output_usd_million)/1000000;basis:='exact';
 else actual:=d.upper_bound_cost_usd;basis:='upper_bound';end if;
 if actual>d.upper_bound_cost_usd then stale:=true;end if;
 begin perform mission_generic_owner.work_assert(w); exception when others then stale:=true;end;
 outcome_uncertain:=(p_result->>'outcome_uncertain')::boolean;
 ok:=coalesce((p_result->>'ok')::boolean,false) and not outcome_uncertain and not stale and w.lease_expires_at>clock_timestamp();
 -- Result application is a subtransaction: failures roll back every domain write,
 -- while the outer transaction still records the provider receipt and real cost.
 begin
 if ok and w.kind='choice' then
  cr:=mission_generic_owner.choice_commit(w.id,(w.payload->>'capability_id')::uuid,p_result->'command');
  if cr is null or not exists(select 1 from mission_generic_owner.panel_choices pc
   join combat_panel_private.request_receipts rr on rr.principal_user=pc.principal_id and rr.request_key=pc.request_key
   where pc.work_id=w.id and pc.id=(w.payload->>'capability_id')::uuid and pc.consumed_at is not null
    and pc.result=cr and rr.viewer_envelope=cr and rr.event_id is not null
    and rr.offer_id=(p_result#>>'{command,offer_id}')::uuid
    and pc.command_sha256=public.combat_v2_sha256(combat_panel_private.validate_command(p_result->'command')))
  then raise exception 'MGD_COMMAND_RECEIPT_MISSING';end if;
 elsif ok then
  if w.payload#>>'{barrier,closed}' is distinct from 'true'
   or exists(select 1 from jsonb_array_elements_text(w.payload#>'{barrier,required_receipt_ids}') id
    where not(w.payload#>'{barrier,receipt_ids}' ? id))
   or jsonb_typeof(p_result->'text') is distinct from 'string' or length(btrim(p_result->>'text')) not between 1 and 5000
  then raise exception 'MGD_NARRATIVE_BARRIER';end if;
  if w.payload->>'mode'='combat' then
   cr:=mission_generic_owner.combat_publish(w.id,p_result->>'text',w.request_key);
   msg:=(cr->>'message_id')::uuid;
   if msg is null or not exists(select 1 from public.messages m join public.master_v2_sessions s on s.location_id=m.location_id
    where s.id=w.master_session_id and m.id=msg) then raise exception 'MGD_COMBAT_PUBLICATION_MISSING';end if;
  elsif w.payload->>'mode'='mission' then
   insert into public.messages(location_id,character_id,author_name,body,kind,sender_user,recipient_user,created_at)
   select location_id,null,'Fato',p_result->>'text','fato',null,null,clock_timestamp() from public.master_v2_sessions where id=w.master_session_id returning id into msg;
   if w.payload ? 'opening_start_receipt_id' then
    select * into strict bs from mission_generic_owner.board_starts where id=w.authority_receipt_id and master_session_id=w.master_session_id for update;
    select * into strict ev from public.mission_run_events where id=bs.event_id and master_session_id=w.master_session_id for update;
   else
    select * into strict tr from mission_generic_owner.trigger_receipts where id=w.authority_receipt_id and master_session_id=w.master_session_id;
    select * into strict ev from public.mission_run_events where id=(tr.result->>'event_id')::uuid and master_session_id=w.master_session_id for update;
   end if;
   select * into strict ob from public.mission_run_outbox where event_id=ev.id and master_session_id=w.master_session_id for update;
   if ev.status<>'committed' or ob.state<>'pending' or ev.version_after<>w.run_control_version
    or ob.event_version_after<>ev.version_after or ev.step_after<>w.step_key or ob.step_key<>w.step_key
    or ob.context_fingerprint<>ev.context_fingerprint then raise exception 'MGD_OUTBOX_STALE';end if;
   bodysha:=encode(extensions.digest(convert_to(p_result->>'text','UTF8'),'sha256'),'hex');
   publication:=gen_random_uuid();
   insert into public.mission_run_publications(id,master_session_id,event_id,request_key_sha256,request_fingerprint,source,
    expected_run_control_version,expected_event_version_after,expected_step_key,context_fingerprint,body_sha256,status)
   values(publication,w.master_session_id,ev.id,mission_internal.request_key_sha256(w.request_key),
    mission_internal.fingerprint(jsonb_build_object('schema_version','mission-generic-publication/1','work_id',w.id,'event_id',ev.id,
    'payload_sha256',w.payload_sha256,'body_sha256',bodysha)),'model',w.run_control_version,ev.version_after,w.step_key,ev.context_fingerprint,bodysha,'committed');
   insert into public.mission_run_messages(publication_id,message_id,body_sha256) values(publication,msg,bodysha);
   -- Same guarded outbox transition as native publication; no invented reveal grants.
   perform set_config('app.mission_outbox_publish','on',true);
   update public.mission_run_outbox set state='published',publication_id=publication,published_at=clock_timestamp() where event_id=ev.id;
   perform set_config('app.mission_outbox_publish','off',true);
   if w.payload ? 'opening_start_receipt_id' then
    perform mission_generic_owner.opening_published(w.master_session_id,publication);
   end if;
  else raise exception 'MGD_NARRATIVE_MODE';
  end if;
 end if;
 exception when others then
  application_error:=SQLSTATE;ok:=false;msg:=null;cr:=null;publication:=null;
 end;
 update mission_narrative_internal.dispatch_attempts set status=case when basis='exact' then 'success' else 'unknown_billable' end,
  actual_cost_usd=actual,cost_basis=basis,input_tokens=case when basis='exact' then (metrics->>'input_tokens')::int end,
  output_tokens=case when basis='exact' then (metrics->>'output_tokens')::int end,reasoning_tokens=case when basis='exact' then (metrics->>'reasoning_tokens')::int end,
  total_tokens=case when basis='exact' then (metrics->>'total_tokens')::int end,finalized_at=clock_timestamp() where id=a.id;
 update mission_narrative_internal.dispatch_receipts set status=case when basis='exact' then 'success' else 'unknown_billable' end,
  charged_cost_usd=actual,lease_token_sha256=null,lease_expires_at=null,finalized_at=clock_timestamp(),updated_at=clock_timestamp() where id=d.id;
 update mission_narrative_internal.provider_authorizations set finalize_token_sha256=null where id=z.id;
 update mission_generic_owner.work_items set state=case when outcome_uncertain then 'uncertain' when ok then 'completed' else 'failed' end,result=p_result,result_sha256=p_result_sha,
  receipt_id=receipt,message_id=msg,finalized_at=clock_timestamp() where id=w.id returning * into w;
 insert into mission_narrative_internal.dispatch_audit(receipt_id,event_code,details) values(d.id,'generic_finalized',jsonb_build_object(
  'work_id',w.id,'receipt_id',receipt,'message_id',msg,'result_jsonb_sha256',public.combat_v2_sha256(p_result),'result_sha256',p_result_sha,
  'command_receipt',cr,'cost_basis',basis,'stale',stale,'state',w.state,
  'outcome_uncertain',outcome_uncertain,'application_error_sqlstate',application_error));
 return mission_generic_owner.work_status(w);
end;
$fn$;

revoke all on function mission_generic_owner.dispatch_user(uuid,uuid),mission_generic_owner.dispatch_admit(uuid,integer,numeric),
 mission_generic_owner.work_status(mission_generic_owner.work_items),mission_generic_owner.work_assert(mission_generic_owner.work_items),
 mission_generic_owner.narrative_context(uuid,text,uuid,timestamptz,jsonb),mission_generic_owner.enqueue_opening(uuid,uuid),
 mission_generic_owner.enqueue_transition(uuid,uuid),mission_generic_owner.trigger_dispatch_enqueue(),
 mission_generic_owner.enqueue_choice(uuid,uuid,uuid),mission_generic_owner.enqueue_combat(uuid,uuid)
 from public,anon,authenticated,service_role;
revoke all on function public.mission_generic_dispatch_next_v1(uuid,uuid),public.mission_generic_dispatch_status_v1(uuid,jsonb),
 public.mission_generic_dispatch_reject_v1(uuid,jsonb,uuid,text),
 public.mission_generic_dispatch_claim_v1(uuid,jsonb),public.mission_generic_dispatch_authorize_v1(uuid,uuid,text,jsonb),
 public.mission_generic_dispatch_consume_v1(uuid,uuid,text,uuid,text),public.mission_generic_dispatch_finalize_v1(uuid,text,text,text)
 from public,anon,authenticated,service_role;
grant execute on function public.mission_generic_dispatch_next_v1(uuid,uuid),public.mission_generic_dispatch_status_v1(uuid,jsonb),
 public.mission_generic_dispatch_reject_v1(uuid,jsonb,uuid,text),
 public.mission_generic_dispatch_claim_v1(uuid,jsonb),public.mission_generic_dispatch_authorize_v1(uuid,uuid,text,jsonb),
 public.mission_generic_dispatch_consume_v1(uuid,uuid,text,uuid,text),public.mission_generic_dispatch_finalize_v1(uuid,text,text,text) to service_role;

-- MODULE MISSION_GENERIC_SOURCES.sql SHA256 b00cb739df02342f218575ef7f2b5359a439495ccb2fbfb65500165b50876152
-- MISSION-GENERIC-SOURCES/1. Install after DB/Combat/Panel/Dispatch; runtime remains off.
create function mission_generic_owner.combat_narrative_source(p_session uuid,p_event uuid)
returns jsonb language plpgsql security definer set search_path='' as $fn$
declare e mission_generic_owner.encounters%rowtype; b mission_generic_owner.run_bindings%rowtype;
 run public.mission_run_state%rowtype; s public.combat_v2_sessions%rowtype;
 r public.combat_v2_rounds%rowtype; rep public.combat_v2_round_reports%rowtype;
 a public.combat_v2_actors%rowtype; d public.combat_v2_declarations%rowtype;
 place public.locations%rowtype; row record; item jsonb; projected jsonb; narrator jsonb;
 actors jsonb:='[]'; actions jsonb:='[]'; sources jsonb:='[]'; facts jsonb:='[]'; spatial jsonb:='[]';
 snapshot jsonb; candidate jsonb; scenehash text; body text; sid text; pname text; persona text;
 prior_count integer:=0; included integer:=0;
begin
 if auth.uid() is not null or not public.combat_v2_is_service() then raise exception 'MG_SERVICE_REQUIRED' using errcode='42501';end if;
 perform mission_generic_owner.assert_runtime(p_session);
 select * into strict b from mission_generic_owner.run_bindings where master_session_id=p_session;
 select * into strict run from public.mission_run_state where master_session_id=p_session;
 select * into strict rep from public.combat_v2_round_reports where id=p_event;
 perform public.combat_v2_lock_round(rep.round_id);
 select * into strict r from public.combat_v2_rounds where id=rep.round_id and report_id=rep.id;
 select * into strict s from public.combat_v2_sessions where id=r.session_id and master_session_id=p_session;
 select * into strict e from mission_generic_owner.encounters where encounter_id=s.id and master_session_id=p_session;
 select * into strict place from public.locations where id=s.location_id;
 if e.step_key<>run.current_step_key or e.run_control_version<>run.control_version
  or b.snapshot_sha256 is distinct from mission_internal.fingerprint(b.snapshot)
  or r.state<>'risolto' or r.resolved_at is null or rep.narration_state<>'attesa'
  or rep.mechanics_sha256 is distinct from public.combat_v2_sha256(rep.mechanics)
  or jsonb_typeof(rep.mechanics->'declarations') is distinct from 'array'
  or (place.is_test and (rep.values_written or public.combat_v2_values_written(s.id)))
 then raise exception 'MG_COMBAT_SOURCE_STALE' using errcode='55000';end if;
 for a in select * from public.combat_v2_actors where session_id=s.id order by id loop
  persona:=null;pname:=null;
  if a.actor_kind='pg' then
   select name into strict pname from public.characters where id=a.character_id and user_id=a.controller_user;
  elsif a.actor_kind='png' then
   select pi.nome,jsonb_build_object('voice',nv.skeleton->'voice','gestures',nv.skeleton->'gestures')::text into strict pname,persona
    from public.combat_v2_provider_instances_v1 pi join public.nb_template_versions nv on nv.id=pi.narrative_version_ref
    where pi.id=a.provider_instance_v1_id and pi.session_id=s.id;
  else raise exception 'MG_SCENE_ACTOR_UNSUPPORTED' using errcode='55000';end if;
  if nullif(btrim(pname),'') is null then raise exception 'MG_SCENE_IDENTITY_MISSING';end if;
  actors:=actors||jsonb_build_array(jsonb_build_object('id',a.id,'name',pname,'kind',upper(a.actor_kind),
    'persona',persona,'may_speak',a.actor_kind='png'));
 end loop;
 if nullif(btrim(place.description),'') is not null then
  body:=place.description;
  sources:=jsonb_build_array(jsonb_build_object('id','location:'||place.id,'session_id',s.id,'round_id',r.id,
   'kind','setting','actor_id',null,'sequence',0,'body',body,
   'sha256',encode(extensions.digest(convert_to(body,'UTF8'),'sha256'),'hex'),'visibility','public','complete',true));
 end if;
 -- Only public mission publications tied to this run, never an unfiltered chat.
 for row in select w.id,w.result->>'text' body,w.message_id from mission_generic_owner.work_items w
  where w.master_session_id=p_session and w.kind='narration' and w.state='completed' and w.payload->>'mode'='mission'
  order by w.created_at desc limit 1 loop
  if nullif(btrim(row.body),'') is null or not exists(select 1 from public.messages m where m.id=row.message_id
    and m.location_id=place.id and m.recipient_user is null and m.kind='fato' and m.body=row.body)
  then raise exception 'MG_SCENE_CONTINUITY_CHANGED';end if;
  sources:=sources||jsonb_build_array(jsonb_build_object('id','mission:'||row.id,'session_id',s.id,'round_id',r.id,
   'kind','setting','actor_id',null,'sequence',0,'body',row.body,
   'sha256',encode(extensions.digest(convert_to(row.body,'UTF8'),'sha256'),'hex'),'visibility','public','complete',true));
 end loop;
 for d in select * from public.combat_v2_declarations where round_id=r.id order by order_no nulls last,id loop
  select value into strict item from jsonb_array_elements(rep.mechanics->'declarations') where value->>'id'=d.id::text;
  if item->>'actor' is distinct from d.actor_id::text or item->>'kind' is distinct from d.kind
   or item->>'state' is distinct from d.state or item->'outcome' is distinct from d.outcome
   or d.state not in('risolta','superflua') then raise exception 'MG_SCENE_REPORT_CHANGED';end if;
  if d.state='risolta' then projected:=combat_panel_private.narrative_declaration_facts(d.id);
  else projected:=jsonb_build_object('execution','not_executed','result',combat_panel_private.narrative_outcome_facts(d.outcome));end if;
  facts:=facts||jsonb_build_array(jsonb_build_object('declaration_id',d.id,'actor_id',d.actor_id,
   'target_actor_id',d.target_actor_id,'kind',d.kind,'facts',projected));
  -- Automatic missing-defence receipts are facts, not a newly invented role.
  if d.kind='nessuna' and coalesce(d.declaration_text,'')='' then continue;end if;
  select * into strict a from public.combat_v2_actors where id=d.actor_id and session_id=s.id;
  select m.id::text,m.body into sid,body from combat_consumer_private.declaration_messages l
   join public.messages m on m.id=l.message_id where l.declaration_id=d.id and m.location_id=place.id
    and m.recipient_user is null and m.kind not in('whisper','motore')
    and public._combat_narrative_sha(m.id)=l.message_sha256
    and ((a.actor_kind='pg' and m.character_id=a.character_id and m.sender_user=a.controller_user)
      or (a.actor_kind='png' and m.character_id is null and m.sender_user is null and m.kind='fato'));
  if a.actor_kind='png' and not exists(select 1 from mission_generic_owner.panel_choices c
    join combat_panel_private.request_receipts q on q.principal_user=c.principal_id and q.request_key=c.request_key
    where c.encounter_id=s.id and c.actor_id=a.id and c.request_key=d.request_key and c.consumed_at is not null
    and c.result=q.viewer_envelope and c.command_sha256=q.command_fingerprint
    and q.viewer_envelope#>>'{receipt,declaration_id}'=d.id::text)
  then raise exception 'MG_SCENE_PNG_RECEIPT_MISSING';end if;
  if sid is null or nullif(btrim(body),'') is null then raise exception 'MG_SCENE_ROLE_MISSING';end if;
  actions:=actions||jsonb_build_array(jsonb_build_object('actor_id',a.id,'role',case when d.kind='difesa' then 'difesa' else 'azione' end,'source_id',sid));
  sources:=sources||jsonb_build_array(jsonb_build_object('id',sid,'session_id',s.id,'round_id',r.id,'kind','role',
   'actor_id',a.id,'sequence',r.round_no,'body',body,'sha256',encode(extensions.digest(convert_to(body,'UTF8'),'sha256'),'hex'),
   'visibility','public','complete',true));
 end loop;
 if jsonb_array_length(actions)=0 or jsonb_array_length(facts)<>jsonb_array_length(rep.mechanics->'declarations')
 then raise exception 'MG_SCENE_BARRIER_INCOMPLETE';end if;
 for item in select value from jsonb_array_elements(coalesce(rep.mechanics->'substitution_receipts','[]')) loop
  narrator:=item->'narrator_payload';
  if item->>'round_id' is distinct from r.id::text or narrator->>'schema_version' is distinct from 'common-substitution-narrator/1.0'
   or not exists(select 1 from jsonb_array_elements(actors) ar where ar->>'id'=item->>'actor_id')
  then raise exception 'MG_SCENE_SUBSTITUTION_CHANGED';end if;
  spatial:=spatial||jsonb_build_array(jsonb_build_object('actor_id',item->'actor_id','kind','substitution',
   'outcome',narrator#>'{impact,outcome}','anchor',narrator#>'{anchor,semantic_label}','after',narrator#>'{after,semantic_region}'));
 end loop;
 select count(*) into prior_count from public.combat_v2_narratives n join public.combat_v2_rounds old on old.id=n.round_id
   join public.combat_v2_round_reports q on q.id=n.report_id where old.session_id=s.id and old.round_no<r.round_no
   and old.state='narrato' and q.narration_state='pubblicata';
 snapshot:=jsonb_build_object('schema_version','combat-scene/1','session_id',s.id,'round_id',r.id,
  'report_sha256',rep.mechanics_sha256,'control_version',run.control_version,'location',place.name,'actors',actors,'actions',actions,
  'resolved_facts',jsonb_build_object('schema_version','mission-generic-resolved-facts/1','round_no',r.round_no,
   'declarations',facts,'spatial',spatial)::text,'sources',sources,
  'selection',jsonb_build_object('max_input_bytes',12000,'previous_available',prior_count,'previous_included',0));
 if octet_length(snapshot::text)>12000 then raise exception 'MG_SCENE_REQUIRED_CONTEXT_OVERFLOW' using errcode='54000';end if;
 for row in select n.id,n.round_id,n.body,old.round_no,q.message_id from public.combat_v2_narratives n
  join public.combat_v2_rounds old on old.id=n.round_id and old.session_id=s.id
  join public.combat_v2_round_reports q on q.id=n.report_id and q.round_id=old.id
  where old.round_no<r.round_no and old.state='narrato' and q.narration_state='pubblicata' order by old.round_no desc,n.id loop
  if not exists(select 1 from public.messages m where m.id=row.message_id and m.location_id=place.id and m.body=row.body
    and m.character_id is null and m.sender_user is null and m.recipient_user is null and m.kind='fato')
  then raise exception 'MG_SCENE_PREVIOUS_CHANGED';end if;
  candidate:=jsonb_set(snapshot,'{sources}',snapshot->'sources'||jsonb_build_array(jsonb_build_object('id',row.id,
   'session_id',s.id,'round_id',row.round_id,'kind','fato','actor_id',null,'sequence',row.round_no,'body',row.body,
   'sha256',encode(extensions.digest(convert_to(row.body,'UTF8'),'sha256'),'hex'),'visibility','public','complete',true)));
  candidate:=jsonb_set(candidate,'{selection,previous_included}',to_jsonb(included+1));
  if octet_length(candidate::text)<=12000 then snapshot:=candidate;included:=included+1;end if;
 end loop;
 scenehash:=public.combat_v2_sha256(snapshot);
 return jsonb_build_object('master_session_id',p_session,'step_key',run.current_step_key,'run_control_version',run.control_version,
  'encounter_id',s.id,'authority_receipt_id',rep.id,'payload',jsonb_build_object('schema_version','mission-generic-narration/1',
   'mode','combat','scene',jsonb_build_object('snapshot',snapshot,'snapshot_sha256',scenehash),
   'scene_binding',jsonb_build_object('session_id',s.id,'round_id',r.id,'report_sha256',rep.mechanics_sha256,
    'control_version',run.control_version,'hash_authority','combat_v2_sha256/jsonb','scene_sha256',scenehash),
   'barrier',jsonb_build_object('closed',true,'required_receipt_ids',jsonb_build_array(rep.id),'receipt_ids',jsonb_build_array(rep.id))));
end $fn$;

create function mission_generic_owner.combat_publish(p_work uuid,p_text text,p_request uuid)
returns jsonb language plpgsql security definer set search_path='' as $fn$
declare w mission_generic_owner.work_items%rowtype; source jsonb; result jsonb;
begin
 if auth.uid() is not null or not public.combat_v2_is_service() then raise exception 'MG_SERVICE_REQUIRED' using errcode='42501';end if;
 select * into strict w from mission_generic_owner.work_items where id=p_work for update;
 if w.kind<>'narration' or w.payload->>'mode'<>'combat' or w.state<>'provider_started' or w.request_key<>p_request
  or w.lease_expires_at<=clock_timestamp() or w.payload_sha256<>public.combat_v2_sha256(w.payload)
 then raise exception 'MG_PUBLISH_WORK_INVALID';end if;
 source:=mission_generic_owner.combat_narrative_source(w.master_session_id,w.authority_receipt_id);
 if source->'payload' is distinct from w.payload then raise exception 'MG_PUBLISH_SOURCE_CHANGED';end if;
 result:=public.combat_v2_narrative_store((w.payload#>>'{scene_binding,round_id}')::uuid,'fato_ia',p_text,p_request,null);
 return result->'data';
end $fn$;
revoke all on function mission_generic_owner.combat_narrative_source(uuid,uuid),mission_generic_owner.combat_publish(uuid,text,uuid)
 from public,anon,authenticated,service_role;
do $pin$ begin
 IF md5((select prosrc from pg_proc where oid='combat_panel_private.publish_master_declaration(uuid,text)'::regprocedure)) IS DISTINCT FROM '1d1e0ebfef6f1e95aa9cba9a44e91bf1' THEN RAISE EXCEPTION 'MG_PUBLISH_BASELINE_DRIFT';END IF;
end $pin$;
CREATE OR REPLACE FUNCTION combat_panel_private.publish_master_declaration(p_declaration uuid, p_text text)
 RETURNS uuid
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO ''
AS $function$
DECLARE a public.combat_v2_actors%ROWTYPE; d public.combat_v2_declarations%ROWTYPE;
 location uuid; v_message_id uuid; guided_before text;
BEGIN
 SELECT * INTO STRICT d FROM public.combat_v2_declarations WHERE id=p_declaration FOR UPDATE;
 SELECT a0.* INTO a FROM public.combat_v2_actors a0
   JOIN public.combat_v2_rounds r ON r.id=d.round_id AND r.session_id=a0.session_id
   JOIN public.combat_v2_sessions s ON s.id=r.session_id AND s.source_kind='master'
   WHERE a0.id=d.actor_id AND exam_regia_private.actor_principal(a0.id,a0.controller_user)=exam_regia_private.current_principal() AND a0.companion_id IS NULL;
 IF a.id IS NULL OR d.controller_user_snapshot IS DISTINCT FROM exam_regia_private.current_principal()
   OR d.controller_version_snapshot<>a.controller_version OR d.state<>'inviata'
   OR d.declaration_text IS DISTINCT FROM coalesce(p_text,'') THEN
   RAISE EXCEPTION 'panel_role_declaration_scope_invalid' USING ERRCODE='42501'; END IF;
 SELECT location_id INTO STRICT location FROM public.combat_v2_sessions WHERE id=a.session_id;

 IF a.actor_kind='png' AND mission_generic_owner.principal_in_session(
  (SELECT master_session_id FROM public.combat_v2_sessions WHERE id=a.session_id),exam_regia_private.current_principal())
  AND mission_generic_owner.actor_principal(a.id)=exam_regia_private.current_principal() THEN
  IF nullif(btrim(p_text),'') IS NULL THEN RAISE EXCEPTION 'MG_PNG_ATTEMPT_EMPTY'; END IF;
  INSERT INTO public.messages(location_id,character_id,author_name,body,kind)
   VALUES(location,NULL,'Fato',p_text,'fato') RETURNING id INTO v_message_id;
  INSERT INTO combat_consumer_private.declaration_messages
   VALUES(d.id,v_message_id,public._combat_narrative_sha(v_message_id));
  RETURN v_message_id;
 END IF;
 IF a.actor_kind='png' AND EXISTS(SELECT 1 FROM exam_regia_private.bindings b
 WHERE b.png_actor_id=a.id AND b.combat_session_id=a.session_id
 AND b.service_principal_id=exam_regia_private.current_principal() AND b.state='active') THEN
  -- La dichiarazione resta immutabile; testo PNG pubblicato soltanto via ricevuta SESSION.
  RETURN NULL;
 END IF;
 IF a.actor_kind='pg' AND exam_regia_private.is_bound(a.session_id) THEN
  IF length(btrim(coalesce(p_text,'')))=0 THEN RETURN NULL; END IF;
  v_message_id:=public._esame_testo_candidato(a.session_id,p_text);
  PERFORM combat_consumer_private.record_message(d.id,v_message_id);
  RETURN v_message_id;
 END IF;
 IF length(btrim(coalesce(p_text,'')))=0 THEN RETURN NULL; END IF;
 IF a.actor_kind='pg' THEN
   guided_before:=current_setting('app.combat_guidata',true);
   PERFORM set_config('app.combat_guidata','1',true);
   BEGIN
     v_message_id:=public.post_message(location,p_text,NULL,NULL,NULL);
   EXCEPTION WHEN OTHERS THEN
     PERFORM set_config('app.combat_guidata',coalesce(guided_before,''),true); RAISE;
   END;
   PERFORM set_config('app.combat_guidata',coalesce(guided_before,''),true);
   PERFORM combat_consumer_private.record_message(d.id,v_message_id);
 ELSIF a.actor_kind='png' THEN
   v_message_id:=public.post_fato_manual(location,p_text);
   IF NOT EXISTS(SELECT 1 FROM public.messages m JOIN public.fato_manual_audit f ON f.message_id=m.id
     WHERE m.id=v_message_id AND m.location_id=location AND m.kind='fato' AND m.character_id IS NULL
       AND f.actor_user=exam_regia_private.current_principal() AND f.location_id=location) THEN
     RAISE EXCEPTION 'panel_role_message_scope_invalid' USING ERRCODE='42501'; END IF;
   INSERT INTO combat_consumer_private.declaration_messages
     VALUES(d.id,v_message_id,public._combat_narrative_sha(v_message_id));
 ELSE RAISE EXCEPTION 'panel_role_actor_kind_invalid' USING ERRCODE='22023'; END IF;
 RETURN v_message_id;
END $function$;

-- MODULE MISSION_GENERIC_CHOICE_SOURCES.sql SHA256 f9f7135332725e49a29946b58c1bfa0b96ed20e6b724823346a4744a67f71102
-- MISSION-GENERIC-CHOICE-SOURCES/1: public context for the actor decision.
create function mission_generic_owner.choice_public_context(p_session uuid,p_actor uuid,p_round uuid,p_panel jsonb)
returns jsonb language plpgsql security definer set search_path='' as $fn$
declare sources jsonb:='[]';row record;encounter uuid;
begin
 if auth.uid() is not null or not public.combat_v2_is_service() then raise exception 'MG_SERVICE_REQUIRED' using errcode='42501';end if;
 select e.encounter_id into strict encounter from mission_generic_owner.encounters e
  join public.combat_v2_rounds r on r.session_id=e.encounter_id
  join public.combat_v2_actors a on a.id=p_actor and a.session_id=e.encounter_id
  where e.master_session_id=p_session and r.id=p_round and mission_generic_owner.actor_principal(a.id) is not null;
 if p_panel#>>'{viewer,command_actor_id}' is distinct from p_actor::text
  or p_panel#>>'{context,activity_id}' is distinct from encounter::text
  or p_panel#>>'{context,round_id}' is distinct from p_round::text then raise exception 'MG_CHOICE_CONTEXT_SCOPE';end if;
 for row in select d.id,d.actor_id,d.kind,m.body,l.message_sha256
  from public.combat_v2_declarations d join combat_consumer_private.declaration_messages l on l.declaration_id=d.id
  join public.messages m on m.id=l.message_id join public.combat_v2_sessions s on s.id=encounter
  join public.combat_v2_actors a on a.id=d.actor_id and a.session_id=s.id
  where d.round_id=p_round and m.location_id=s.location_id and m.recipient_user is null
   and m.kind not in('whisper','motore') and nullif(btrim(m.body),'') is not null
   and ((a.actor_kind='pg' and m.sender_user=a.controller_user and m.character_id=a.character_id)
    or(a.actor_kind='png' and m.sender_user is null and m.character_id is null and m.kind='fato'))
  order by d.order_no nulls last,d.created_at,d.id loop
  if not exists(select 1 from combat_consumer_private.declaration_messages l where l.declaration_id=row.id
   and l.message_sha256=public._combat_narrative_sha(l.message_id)) then raise exception 'MG_CHOICE_ROLE_CHANGED';end if;
  sources:=sources||jsonb_build_array(jsonb_build_object('source_id',row.id,'actor_id',row.actor_id,'kind','declared_attempt',
   'action_kind',row.kind,'body',row.body,'sha256',encode(extensions.digest(convert_to(row.body,'UTF8'),'sha256'),'hex'),
   'visibility','public','complete',true));
 end loop;
 for row in select w.id,w.result->>'text' body,m.body public_body,m.recipient_user,m.kind
  from mission_generic_owner.work_items w join public.messages m on m.id=w.message_id
   join public.master_v2_sessions s on s.id=w.master_session_id and s.location_id=m.location_id
  where w.master_session_id=p_session and w.kind='narration' and w.state='completed' and w.message_id is not null
  order by w.finalized_at desc,w.id limit 1 loop
  if row.body is distinct from row.public_body or row.recipient_user is not null or row.kind<>'fato'
   then raise exception 'MG_CHOICE_CONTINUITY_CHANGED';end if;
  sources:=sources||jsonb_build_array(jsonb_build_object('source_id',row.id,'actor_id',null,'kind','fato','body',row.body,
   'sha256',encode(extensions.digest(convert_to(row.body,'UTF8'),'sha256'),'hex'),'visibility','public','complete',true));
 end loop;
 return jsonb_build_object('context',p_panel->'context','viewer',p_panel->'viewer','public_sources',sources);
end $fn$;
revoke all on function mission_generic_owner.choice_public_context(uuid,uuid,uuid,jsonb) from public,anon,authenticated,service_role;
do $pin$ begin
 if md5((select prosrc from pg_proc where oid='mission_generic_owner.choice_options(uuid,uuid,uuid,uuid)'::regprocedure)) is distinct from '1d8b478516d28e75ea88820a7542a040' then raise exception 'MG_CHOICE_OPTIONS_BASELINE_DRIFT';end if;
end $pin$;
create or replace function mission_generic_owner.choice_options(p_session uuid,p_actor uuid,p_work uuid,p_request uuid)
returns jsonb language plpgsql security definer set search_path='' as $fn$
declare a public.combat_v2_actors%rowtype; e mission_generic_owner.encounters%rowtype;
 c mission_generic_owner.panel_choices%rowtype; m public.master_v2_sessions%rowtype;
 env jsonb; permit uuid; principal uuid; persona jsonb;
begin
 if auth.uid() is not null or not public.combat_v2_is_service() or p_work is null or p_request is null
 then raise exception 'MG_SERVICE_REQUIRED' using errcode='42501'; end if;
 perform mission_generic_owner.assert_runtime(p_session);
 select * into strict m from public.master_v2_sessions where id=p_session for update;
 select * into c from mission_generic_owner.panel_choices where work_id=p_work for update;
 if found then
  if c.master_session_id<>p_session or c.actor_id<>p_actor or c.request_key<>p_request or c.expires_at<=clock_timestamp()
  then raise exception 'MG_CHOICE_STALE' using errcode='40001'; end if;
 else
  select * into strict a from public.combat_v2_actors where id=p_actor and actor_kind='png'
   and controller_user is null and character_id is null and companion_id is null and state='attivo' for update;
  select * into strict e from mission_generic_owner.encounters where encounter_id=a.session_id and master_session_id=p_session;
  principal:=mission_generic_owner.actor_principal(p_actor);
  if principal is null then raise exception 'MG_ACTOR_NOT_BOUND' using errcode='42501'; end if;
  insert into mission_generic_owner.panel_permits(master_session_id,encounter_id,actor_id,work_id,principal_id,operation,request_key,transaction_id,backend_pid)
  values(p_session,e.encounter_id,p_actor,p_work,principal,'options',p_request,txid_current(),pg_backend_pid()) returning id into permit;
  env:=combat_panel_private.master_projection(m.location_id,p_actor);
  env:=combat_panel_private.master_options(m.location_id,p_actor,(env#>>'{context,version}')::bigint);
  if env->>'status' is distinct from 'ready' or env#>>'{context,activity_id}' is distinct from e.encounter_id::text
   or env#>>'{viewer,command_actor_id}' is distinct from p_actor::text
   or env#>>'{viewer,can_command}' is distinct from 'true'
   or jsonb_array_length(env->'offers')=0
  then raise exception 'MG_CHOICE_NOT_READY' using errcode='55000'; end if;
  -- Administration never becomes an AI actor choice.
  if exists(select 1 from jsonb_array_elements(env->'offers') x where x->>'kind'='administration')
  then raise exception 'MG_ADMIN_OFFER_FORBIDDEN' using errcode='42501'; end if;
  insert into mission_generic_owner.panel_choices(work_id,master_session_id,encounter_id,actor_id,principal_id,request_key,
   context_version,controller_version,legal_options,options_sha256,expires_at)
  values(p_work,p_session,e.encounter_id,p_actor,principal,p_request,(env#>>'{context,version}')::bigint,
   a.controller_version,env,public.combat_v2_sha256(env),clock_timestamp()+interval '150 seconds') returning * into c;
  update mission_generic_owner.panel_permits set consumed_at=clock_timestamp() where id=permit;
 end if;
 -- Identity/persona are taken from the approved provider version, not model output.
 select jsonb_build_object('identity',nv.skeleton->'identity','voice',nv.skeleton->'voice',
  'conduct',nv.skeleton->'conduct','goals',nv.skeleton->'goals','motivations',nv.skeleton->'motivations',
  'knowledge_limits',nv.skeleton->'knowledge_limits','knowledge_boundary',nv.knowledge_boundary) into persona
 from public.combat_v2_actors aa join public.combat_v2_provider_instances_v1 pi on pi.id=aa.provider_instance_v1_id
 join public.nb_template_versions nv on nv.id=pi.narrative_version_ref where aa.id=c.actor_id;
 return jsonb_build_object('capability_id',c.id,'actor_id',c.actor_id,'legal_options',c.legal_options,
  'context_version',c.context_version,'request_key',c.request_key,'persona',persona,
  'encounter_id',c.encounter_id,'authority_receipt_id',c.id,
  'authorized_context',mission_generic_owner.choice_public_context(p_session,c.actor_id,(c.legal_options#>>'{context,round_id}')::uuid,c.legal_options)); 
end $fn$;

-- MODULE MISSION_GENERIC_PROVIDER_GATE.sql SHA256 08a6bc63f598c5c8768d9640a4a8e0782dced24fc82db8a96d9fbb4ff2feb44d
-- MISSION-GENERIC-PROVIDER-GATE/1. No enable and no price changes.
create table mission_generic_owner.provider_policy (
 singleton boolean primary key default true check(singleton),
 enabled boolean not null default false,
 max_run_calls integer check(max_run_calls>0),
 max_daily_calls integer check(max_daily_calls>0),
 max_global_calls integer check(max_global_calls>0),
 run_budget_usd numeric check(run_budget_usd>0 and run_budget_usd<'Infinity'::numeric),
 daily_budget_usd numeric check(daily_budget_usd>0 and daily_budget_usd<'Infinity'::numeric),
 global_budget_usd numeric check(global_budget_usd>0 and global_budget_usd<'Infinity'::numeric),
 check(not enabled or (max_run_calls is not null and max_daily_calls is not null and max_global_calls is not null
  and run_budget_usd is not null and daily_budget_usd is not null and global_budget_usd is not null))
);
insert into mission_generic_owner.provider_policy(singleton) values(true);
create table mission_generic_owner.provider_permits (
 work_id uuid primary key references mission_generic_owner.work_items(id),
 receipt_id uuid not null unique references mission_narrative_internal.dispatch_receipts(id),
 transaction_id bigint not null, backend_pid integer not null,
 stage text not null check(stage in('authorize','consume')),
 lease_id uuid not null, payload_sha256 text not null check(payload_sha256~'^[0-9a-f]{64}$'),
 issued_at timestamptz not null default clock_timestamp()
);
alter table mission_generic_owner.provider_policy enable row level security;
alter table mission_generic_owner.provider_permits enable row level security;
revoke all on mission_generic_owner.provider_policy,mission_generic_owner.provider_permits from public,anon,authenticated,service_role;

-- Preclaim checks scope/configuration only. Reservation remains under the native
-- runtime-policy row lock; its existing prices and upper-bound formula are reused.
create function mission_generic_owner.provider_ready(p_work uuid)
returns void language plpgsql security definer set search_path='' as $fn$
declare w mission_generic_owner.work_items;a mission_generic_owner.dispatch_admissions;
 g mission_generic_owner.provider_policy;
begin
 perform mission_ai_board_owner.service_only();
 select * into strict w from mission_generic_owner.work_items where id=p_work;
 perform mission_generic_owner.work_assert(w);
 select * into strict g from mission_generic_owner.provider_policy where singleton for share;
 select * into strict a from mission_generic_owner.dispatch_admissions where master_session_id=w.master_session_id;
 if not g.enabled or not a.enabled or a.call_limit>g.max_run_calls or a.cost_budget_usd>g.run_budget_usd
 or a.calls_authorized>a.call_limit then raise exception 'MGPG_CLOSED_OR_ADMISSION';end if;
end;
$fn$;

-- A permit is minted only inside the generic dispatcher transaction. Native
-- worker tokens, receipt UUIDs or session membership alone cannot create one.
create function mission_generic_owner.provider_permit(p_work uuid,p_stage text)
returns void language plpgsql security definer set search_path='' as $fn$
declare w mission_generic_owner.work_items;
begin
 perform mission_generic_owner.provider_ready(p_work);
 select * into strict w from mission_generic_owner.work_items where id=p_work;
 if p_stage not in('authorize','consume') or w.dispatch_receipt_id is null or w.lease_expires_at<=clock_timestamp()
 or w.state<>(case p_stage when 'authorize' then 'claimed' else 'authorized' end)
 then raise exception 'MGPG_PERMIT_STAGE';end if;
 insert into mission_generic_owner.provider_permits(work_id,receipt_id,transaction_id,backend_pid,stage,lease_id,payload_sha256)
 values(w.id,w.dispatch_receipt_id,txid_current(),pg_backend_pid(),p_stage,w.lease_id,w.payload_sha256)
 on conflict(work_id) do update set receipt_id=excluded.receipt_id,transaction_id=excluded.transaction_id,
 backend_pid=excluded.backend_pid,stage=excluded.stage,lease_id=excluded.lease_id,payload_sha256=excluded.payload_sha256,issued_at=clock_timestamp();
end;
$fn$;

create function mission_generic_owner.provider_native_assert(p_receipt uuid,p_stage text)
returns void language plpgsql security definer set search_path='' as $fn$
declare r mission_narrative_internal.dispatch_receipts;w mission_generic_owner.work_items;
 k mission_generic_owner.provider_permits;g mission_generic_owner.provider_policy;
 a mission_generic_owner.dispatch_admissions;pol mission_narrative_internal.runtime_policy;
 run_spent numeric;day_spent numeric;all_spent numeric;run_calls bigint;day_calls bigint;all_calls bigint;
 ub numeric;extra numeric;extra_call integer;env jsonb;
begin
 if p_stage not in('reserve','authorize','consume') then raise exception 'MGPG_STAGE';end if;
 select * into strict r from mission_narrative_internal.dispatch_receipts where id=p_receipt;
 select * into strict w from mission_generic_owner.work_items where id=r.authority_receipt_id and dispatch_receipt_id=r.id;
 perform mission_generic_owner.provider_ready(w.id);
 select * into strict k from mission_generic_owner.provider_permits where work_id=w.id and receipt_id=r.id;
 if k.transaction_id<>txid_current() or k.backend_pid<>pg_backend_pid()
 or k.stage<>(case p_stage when 'consume' then 'consume' else 'authorize' end)
 or k.lease_id<>w.lease_id or k.payload_sha256<>w.payload_sha256 or w.lease_expires_at<=clock_timestamp()
 or w.state<>(case p_stage when 'consume' then 'authorized' else 'claimed' end)
 or r.status<>(case p_stage when 'reserve' then 'claimed' when 'authorize' then 'reserved' else 'authorized' end)
 or r.event_kind<>'mission_generic_event' or r.renderer_version<>'mission-generic-runtime/1'
 or r.master_session_id<>w.master_session_id or r.request_key<>w.request_key
 then raise exception 'MGPG_PERMIT_INVALID';end if;
 env:=jsonb_build_object('work_id',w.id,'master_session_id',w.master_session_id,'event_id',w.event_id,
 'authority_receipt_id',w.authority_receipt_id,'payload_sha256',w.payload_sha256,'definition_sha256',w.definition_sha256,'revision',w.revision);
 if r.envelope<>env or r.envelope_sha256<>public.combat_v2_sha256(env) or r.authority_sha256<>public.combat_v2_sha256(env)
 then raise exception 'MGPG_ENVELOPE_INVALID';end if;
 select * into strict g from mission_generic_owner.provider_policy where singleton;
 select * into strict a from mission_generic_owner.dispatch_admissions where master_session_id=w.master_session_id;
 select * into strict pol from mission_narrative_internal.runtime_policy where singleton;
 if pol.model<>'gpt-5.6-luna' or pol.reasoning_effort<>'high' or pol.store
 or pol.max_input_tokens<=0 or pol.max_output_tokens<=0
 or not(pol.input_usd_million>=0 and pol.input_usd_million<'Infinity'::numeric)
 or not(pol.output_usd_million>=0 and pol.output_usd_million<'Infinity'::numeric)
 then raise exception 'MGPG_NATIVE_PRICING_POLICY';end if;
 ub:=(pol.max_input_tokens*pol.input_usd_million+pol.max_output_tokens*pol.output_usd_million)/1000000;
 -- Native reserve holds runtime_policy FOR UPDATE before this sum. Other phases
 -- only validate an already charged reservation; no second reservation is added.
 select coalesce(sum(cost)filter(where d.master_session_id=w.master_session_id),0),
 coalesce(sum(cost)filter(where d.created_at>=date_trunc('day',clock_timestamp())),0),coalesce(sum(cost),0),
 count(*)filter(where used and d.master_session_id=w.master_session_id),
 count(*)filter(where used and d.created_at>=date_trunc('day',clock_timestamp())),count(*)filter(where used)
 into run_spent,day_spent,all_spent,run_calls,day_calls,all_calls
 from (select d.*,case when d.status in('success','fallback','unknown_billable') then coalesce(d.charged_cost_usd,d.upper_bound_cost_usd,0)
 else coalesce(d.upper_bound_cost_usd,0) end cost,
 exists(select 1 from mission_narrative_internal.dispatch_attempts t where t.receipt_id=d.id) used
 from mission_narrative_internal.dispatch_receipts d where d.event_kind='mission_generic_event' and d.renderer_version='mission-generic-runtime/1') d;
 extra:=case when p_stage='reserve' then ub else 0 end;extra_call:=case when p_stage='reserve' then 1 else 0 end;
 if run_spent+extra>least(g.run_budget_usd,a.cost_budget_usd) or day_spent+extra>g.daily_budget_usd or all_spent+extra>g.global_budget_usd
 or run_calls+extra_call>least(g.max_run_calls,a.call_limit) or day_calls+extra_call>g.max_daily_calls or all_calls+extra_call>g.max_global_calls
 then raise exception 'MGPG_BUDGET_EXHAUSTED';end if;
end;
$fn$;
revoke all on function mission_generic_owner.provider_ready(uuid),mission_generic_owner.provider_permit(uuid,text),
 mission_generic_owner.provider_native_assert(uuid,text) from public,anon,authenticated,service_role;

DO $patch$
declare old_source text;ddl text;
begin
 select pg_get_functiondef(oid),pg_get_functiondef(oid) into strict old_source,ddl from pg_proc where oid='public.mission_narrative_attempt_reserve_internal(text,uuid,integer,jsonb,text)'::regprocedure;
 if encode(extensions.digest(convert_to(old_source,'UTF8'),'sha256'),'hex')<>'3aeec15d817c925edaeebaaa05e41dfe3ccaf2975b57f9667ef5aab9296b5930' then raise exception 'MGPG_BASELINE_DRIFT: public.mission_narrative_attempt_reserve_internal(text,uuid,integer,jsonb,text)';end if;
 if position($old$select * into strict pol from mission_narrative_internal.runtime_policy where singleton for update;$old$ in ddl)=0 or (length(ddl)-length(replace(ddl,$old$select * into strict pol from mission_narrative_internal.runtime_policy where singleton for update;$old$,'')))/length($old$select * into strict pol from mission_narrative_internal.runtime_policy where singleton for update;$old$)<>1 then raise exception 'MGPG_PATCH_ANCHOR';end if;
 ddl:=replace(ddl,$old$select * into strict pol from mission_narrative_internal.runtime_policy where singleton for update;$old$,$new$select * into strict pol from mission_narrative_internal.runtime_policy where singleton for update;if r.event_kind='mission_generic_event' then perform mission_generic_owner.provider_native_assert(r.id,'reserve');pol.enabled:=true;end if;$new$);execute ddl;
end;
$patch$;

DO $patch$
declare old_source text;ddl text;
begin
 select pg_get_functiondef(oid),pg_get_functiondef(oid) into strict old_source,ddl from pg_proc where oid='public.mission_narrative_provider_authorize_internal(text,uuid,uuid,text)'::regprocedure;
 if encode(extensions.digest(convert_to(old_source,'UTF8'),'sha256'),'hex')<>'9a6354cd4491c8373b71c55ec57da3b7fc674f5f65c6098947911c624e418a61' then raise exception 'MGPG_BASELINE_DRIFT: public.mission_narrative_provider_authorize_internal(text,uuid,uuid,text)';end if;
 if position($old$select * into strict pol from mission_narrative_internal.runtime_policy where singleton for share;$old$ in ddl)=0 or (length(ddl)-length(replace(ddl,$old$select * into strict pol from mission_narrative_internal.runtime_policy where singleton for share;$old$,'')))/length($old$select * into strict pol from mission_narrative_internal.runtime_policy where singleton for share;$old$)<>1 then raise exception 'MGPG_PATCH_ANCHOR';end if;
 ddl:=replace(ddl,$old$select * into strict pol from mission_narrative_internal.runtime_policy where singleton for share;$old$,$new$select * into strict pol from mission_narrative_internal.runtime_policy where singleton for share;if r.event_kind='mission_generic_event' then perform mission_generic_owner.provider_native_assert(r.id,'authorize');pol.enabled:=true;end if;$new$);execute ddl;
end;
$patch$;

DO $patch$
declare old_source text;ddl text;
begin
 select pg_get_functiondef(oid),pg_get_functiondef(oid) into strict old_source,ddl from pg_proc where oid='public.mission_narrative_provider_consume_internal(text,uuid,text)'::regprocedure;
 if encode(extensions.digest(convert_to(old_source,'UTF8'),'sha256'),'hex')<>'4bb867ff39aa53274c6a1c27cf1bcfb9919c36f7d71ebad9a1f2b2664a5ba957' then raise exception 'MGPG_BASELINE_DRIFT: public.mission_narrative_provider_consume_internal(text,uuid,text)';end if;
 if position($old$end if;raw:=gen_random_uuid()::text;$old$ in ddl)=0 or (length(ddl)-length(replace(ddl,$old$end if;raw:=gen_random_uuid()::text;$old$,'')))/length($old$end if;raw:=gen_random_uuid()::text;$old$)<>1 then raise exception 'MGPG_PATCH_ANCHOR';end if;
 ddl:=replace(ddl,$old$end if;raw:=gen_random_uuid()::text;$old$,$new$end if;if r.event_kind='mission_generic_event' then perform mission_generic_owner.provider_native_assert(r.id,'consume');end if;raw:=gen_random_uuid()::text;$new$);execute ddl;
end;
$patch$;

DO $patch$
declare old_source text;ddl text;
begin
 select prosrc,pg_get_functiondef(oid) into strict old_source,ddl from pg_proc where oid='public.mission_generic_dispatch_claim_v1(uuid,jsonb)'::regprocedure;
 if encode(extensions.digest(convert_to(old_source,'UTF8'),'sha256'),'hex')<>'ef3630bccd770a2f4b4557e37da9671e7178317f084b19dd1a3b9d606b495432' then raise exception 'MGPG_BASELINE_DRIFT: public.mission_generic_dispatch_claim_v1(uuid,jsonb)';end if;
 if position($old$if not a.enabled or a.calls_authorized>=a.call_limit or not pol.enabled or pol.model<>'gpt-5.6-luna'$old$ in ddl)=0 or (length(ddl)-length(replace(ddl,$old$if not a.enabled or a.calls_authorized>=a.call_limit or not pol.enabled or pol.model<>'gpt-5.6-luna'$old$,'')))/length($old$if not a.enabled or a.calls_authorized>=a.call_limit or not pol.enabled or pol.model<>'gpt-5.6-luna'$old$)<>1 then raise exception 'MGPG_PATCH_ANCHOR';end if;
 ddl:=replace(ddl,$old$if not a.enabled or a.calls_authorized>=a.call_limit or not pol.enabled or pol.model<>'gpt-5.6-luna'$old$,$new$perform mission_generic_owner.provider_ready(w.id);
 if not a.enabled or a.calls_authorized>=a.call_limit or pol.model<>'gpt-5.6-luna'$new$);execute ddl;
end;
$patch$;

DO $patch$
declare old_source text;ddl text;
begin
 select prosrc,pg_get_functiondef(oid) into strict old_source,ddl from pg_proc where oid='public.mission_generic_dispatch_authorize_v1(uuid,uuid,text,jsonb)'::regprocedure;
 if encode(extensions.digest(convert_to(old_source,'UTF8'),'sha256'),'hex')<>'f145326d6e4a4299fd8c230f43c1706615936eba30177236a4e635c3b3ad9693' then raise exception 'MGPG_BASELINE_DRIFT: public.mission_generic_dispatch_authorize_v1(uuid,uuid,text,jsonb)';end if;
 if position($old$rr:=public.mission_narrative_attempt_reserve_internal($old$ in ddl)=0 or (length(ddl)-length(replace(ddl,$old$rr:=public.mission_narrative_attempt_reserve_internal($old$,'')))/length($old$rr:=public.mission_narrative_attempt_reserve_internal($old$)<>1 then raise exception 'MGPG_PATCH_ANCHOR';end if;
 ddl:=replace(ddl,$old$rr:=public.mission_narrative_attempt_reserve_internal($old$,$new$perform mission_generic_owner.provider_permit(w.id,'authorize');
 rr:=public.mission_narrative_attempt_reserve_internal($new$);execute ddl;
end;
$patch$;

DO $patch$
declare old_source text;ddl text;
begin
 select prosrc,pg_get_functiondef(oid) into strict old_source,ddl from pg_proc where oid='public.mission_generic_dispatch_consume_v1(uuid,uuid,text,uuid,text)'::regprocedure;
 if encode(extensions.digest(convert_to(old_source,'UTF8'),'sha256'),'hex')<>'35176084208703a77d05c7c576ef9a714231ea636c0753c5f51925e136fc193f' then raise exception 'MGPG_BASELINE_DRIFT: public.mission_generic_dispatch_consume_v1(uuid,uuid,text,uuid,text)';end if;
 if position($old$z:=public.mission_narrative_provider_consume_internal($old$ in ddl)=0 or (length(ddl)-length(replace(ddl,$old$z:=public.mission_narrative_provider_consume_internal($old$,'')))/length($old$z:=public.mission_narrative_provider_consume_internal($old$)<>1 then raise exception 'MGPG_PATCH_ANCHOR';end if;
 ddl:=replace(ddl,$old$z:=public.mission_narrative_provider_consume_internal($old$,$new$perform mission_generic_owner.provider_permit(w.id,'consume');
 z:=public.mission_narrative_provider_consume_internal($new$);execute ddl;
end;
$patch$;

-- CREATE OR REPLACE preserves the native ACLs. Explicitly retain service-only generic RPC grants.
revoke all on function public.mission_generic_dispatch_claim_v1(uuid,jsonb),public.mission_generic_dispatch_authorize_v1(uuid,uuid,text,jsonb),public.mission_generic_dispatch_consume_v1(uuid,uuid,text,uuid,text) from public,anon,authenticated;
grant execute on function public.mission_generic_dispatch_claim_v1(uuid,jsonb),public.mission_generic_dispatch_authorize_v1(uuid,uuid,text,jsonb),public.mission_generic_dispatch_consume_v1(uuid,uuid,text,uuid,text) to service_role;

-- MODULE MISSION_GENERIC_PROGRESS.sql SHA256 f15b889b1ba36fd5dc3a6c4dbcae2466e8dd8b19f9bbcb90504f3a84577d9581
-- MISSION-GENERIC-PROGRESS/1: candidate only; dependencies DB, PLAN_WRITER, BOARD, COMBAT, PANEL, SOURCES, DISPATCH.
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
