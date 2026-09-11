-- MISSION-GENERIC-OUTCOME/1: apply after DB + PLAN_WRITER; no stored definition or run is rewritten.
begin;
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
commit;
