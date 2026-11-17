-- SOURCE ONLY · A · Lettura della trama canonica della bozza IA
-- Revisione, mandato nominativo e qualifica Staff precedono l’installazione.
BEGIN;
SET LOCAL lock_timeout = '4s';

DO $alba_guard$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_catalog.pg_proc proc
    WHERE proc.oid = pg_catalog.to_regprocedure('mission_factory_owner.preview_ai_v3(uuid, bigint, uuid)')
      AND md5(pg_catalog.pg_get_functiondef(proc.oid)) IN ('7380ad6ff0be3f03501ddf28e5ddba9d')
      AND proc.proacl::text = '{postgres=X/postgres}'
      AND pg_catalog.pg_get_userbyid(proc.proowner) = 'postgres'
  ) THEN
    RAISE EXCEPTION 'Alba A: baseline variata: preview_ai_v3';
  END IF;
  IF NOT EXISTS (
    SELECT 1 FROM pg_catalog.pg_proc proc
    WHERE proc.oid = pg_catalog.to_regprocedure('mission_factory_owner.publish_ai_v3(uuid, bigint, text, uuid, text, timestamp with time zone)')
      AND md5(pg_catalog.pg_get_functiondef(proc.oid)) IN ('912bf5f8e49e79e6b1ce8a0d1b0b068e')
      AND proc.proacl::text = '{postgres=X/postgres}'
      AND pg_catalog.pg_get_userbyid(proc.proowner) = 'postgres'
  ) THEN
    RAISE EXCEPTION 'Alba A: baseline variata: publish_ai_v3';
  END IF;
  IF NOT EXISTS (
    SELECT 1 FROM pg_catalog.pg_proc proc
    WHERE proc.oid = pg_catalog.to_regprocedure('mission_public_owner.content_admission_v1(uuid, text, uuid, boolean)')
      AND md5(pg_catalog.pg_get_functiondef(proc.oid)) IN ('58327e17ca819be8d2764ca0865b6038')
      AND proc.proacl::text = '{postgres=X/postgres}'
      AND pg_catalog.pg_get_userbyid(proc.proowner) = 'postgres'
  ) THEN
    RAISE EXCEPTION 'Alba A: baseline variata: content_admission_v1';
  END IF;
END;
$alba_guard$;

CREATE OR REPLACE FUNCTION mission_factory_owner.preview_ai_v3(p_draft uuid, p_expected_version bigint, p_actor uuid)
 RETURNS jsonb
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO ''
AS $function$
declare em3_engine jsonb; em3_profile jsonb; p_allow_published boolean:=false; d mission_factory_owner.drafts; c mission_factory_owner.catalog_versions;
        doc jsonb; m jsonb; phases jsonb; npcs jsonb; maps jsonb; vars jsonb;
        phase jsonb; actor jsonb; transition jsonb; variant jsonb; actor_key text;
        maprow jsonb; detail jsonb; mapcheck jsonb; budget jsonb;
        media_ticket mission_factory_owner.context_media_tickets;
        refs jsonb:='[]'::jsonb; maprefs jsonb:='[]'::jsonb; mediarefs jsonb:='[]'::jsonb;
        errors jsonb:='[]'::jsonb; basis jsonb; seal text; mission_caps jsonb; d100_refs jsonb:='[]'; d100_projection jsonb;
        step_keys text[]:='{}'; actor_keys text[]:='{}'; mode text;
        min_team integer; max_team integer; npc_count integer; review_status text;
begin
  select * into strict d from mission_factory_owner.drafts where id=p_draft;
  if p_actor is null or not exists(select 1 from public.profiles p where p.id=p_actor
      and p.role in('admin','master') and (p_actor=d.author_user or p.role='admin'))
    then raise exception 'MF_EDITOR_FORBIDDEN' using errcode='42501'; end if;
  if d.control_version<>p_expected_version or (d.state not in('draft','previewed')
      and not (p_allow_published and d.state='published'))
    then raise exception 'MF_DRAFT_DRIFT' using errcode='40001'; end if;
  doc:=mission_factory_owner.validate_ai_draft_v3(d.document);
  SELECT mission_public_owner.engine_qualification_v1(revision_sha256,false) INTO em3_engine FROM mission_factory_owner.editor_release_readiness WHERE singleton;mission_caps:=em3_engine->'capabilities';IF em3_engine IS NULL THEN RAISE EXCEPTION 'MF_AI_ENGINE_UNAVAILABLE' USING ERRCODE='55000';END IF;
  m:=doc->'mission'; phases:=doc->'phases'; npcs:=doc->'npc_bindings'; maps:=doc->'maps'; vars:=doc->'variants';
  IF jsonb_typeof(doc#>'{variants,ai,document}') IS DISTINCT FROM 'object' THEN RETURN jsonb_build_object('schema_version','mission-factory-preview/3','draft_id',d.id,'draft_version',d.control_version,'preview_seal',NULL,'validated',false,'errors',jsonb_build_array(jsonb_build_object('code','MF_AI_DOCUMENT_REQUIRED','path','variants.ai.document')),'public_summary',coalesce(m->>'briefing',''),'staff_summary',coalesce(m->>'title',''),'basis',basis);END IF;
  IF m->>'team_min'<>'2' OR m->>'team_max'<>'2' OR jsonb_array_length(npcs)<>2 THEN errors:=errors||jsonb_build_array(jsonb_build_object('code','MF_AI_CAPABILITY_ENVELOPE','path','mission'));END IF;
  if d.sensitive_review_required then
    select r.status into review_status from mission_factory_owner.sensitive_reviews r
      where r.draft_id=d.id and r.document_sha256=d.document_sha256
      order by r.requested_at desc,r.request_key desc limit 1;
    if review_status is distinct from 'approved' then
      errors:=errors||jsonb_build_array(jsonb_build_object('code','MF_SENSITIVE_REVIEW_REQUIRED','path','mission'));
    end if;
  end if;
  select * into c from mission_factory_owner.catalog_versions
    where version=d.catalog_version and qualified and active;
  if c.version is null or c.version is distinct from doc->>'catalog_version'
     or mission_factory_owner.sha(c.document)<>c.document_sha256
    then errors:=errors||jsonb_build_array(jsonb_build_object('code','MF_CATALOG_STALE','path','catalog_version'));
  end if;
  if nullif(btrim(m->>'title'),'') is null
     or nullif(btrim(CASE
          WHEN (doc#>'{variants,ai,document,editorial}') ? 'plot_private'
          THEN doc#>>'{variants,ai,document,editorial,plot_private}'
          ELSE m->>'plot_private'
        END),'') is null
     or nullif(btrim(m->>'briefing'),'') is null
    then errors:=errors||jsonb_build_array(jsonb_build_object('code','MF_MISSION_TEXT_REQUIRED','path','mission')); end if;
  if coalesce(m->>'team_min','') !~ '^[1-4]$' or coalesce(m->>'team_max','') !~ '^[1-4]$'
    then errors:=errors||jsonb_build_array(jsonb_build_object('code','MF_TEAM_RANGE','path','mission'));
  else
    min_team:=(m->>'team_min')::integer; max_team:=(m->>'team_max')::integer;
    if min_team>max_team then errors:=errors||jsonb_build_array(jsonb_build_object('code','MF_TEAM_RANGE','path','mission')); end if;
  end if;
  if coalesce(m->>'gathering_location_id','') !~ '^[0-9a-fA-F-]{36}$'
     or not exists(select 1 from public.locations l where l.id::text=m->>'gathering_location_id'
       and l.is_active and not coalesce(l.is_exam_room,false) and not coalesce(l.is_test,false))
    then errors:=errors||jsonb_build_array(jsonb_build_object('code','MF_GATHERING_LOCATION','path','mission.gathering_location_id')); end if;
  if jsonb_array_length(phases)=0
    then errors:=errors||jsonb_build_array(jsonb_build_object('code','MF_PHASE_REQUIRED','path','phases')); end if;
  for phase in select value from jsonb_array_elements(phases) loop
    if jsonb_typeof(phase)<>'object' or nullif(phase->>'step_key','') is null
      then errors:=errors||jsonb_build_array(jsonb_build_object('code','MF_PHASE_SHAPE','path','phases')); continue; end if;
    if phase->>'step_key'=any(step_keys)
      then errors:=errors||jsonb_build_array(jsonb_build_object('code','MF_PHASE_DUPLICATE','path',phase->>'step_key')); end if;
    step_keys:=step_keys||(phase->>'step_key');
    if c.version is null or not exists(select 1 from jsonb_array_elements(mission_caps) x
      where x.value->>'key'=phase->>'capability_key' and x.value->>'qualified'='true'
        and x.value->>'family'=phase->>'kind' and x.value->>'usage'='phase_transition'
        and x.value->>'phase_allowed'='true'
        and x.value->'allowed_content_kinds'='["mission"]'::jsonb)
      then errors:=errors||jsonb_build_array(jsonb_build_object('code','MF_CAPABILITY_NOT_QUALIFIED','path',phase->>'step_key')); end if;
  end loop;
  for phase in select value from jsonb_array_elements(phases) loop
    if jsonb_typeof(phase)<>'object' then continue; end if;
    if jsonb_typeof(phase->'transitions')='array' then
      for transition in select value from jsonb_array_elements(phase->'transitions') loop
        if nullif(transition->>'to_step_key','') is not null and not (transition->>'to_step_key'=any(step_keys))
          then errors:=errors||jsonb_build_array(jsonb_build_object('code','MF_TRANSITION_ORPHAN','path',phase->>'step_key')); end if;
      end loop;
    end if;
  end loop;
  for phase in select value from jsonb_array_elements(phases) where value->>'kind'='d100' loop
    begin
      for transition in select value from jsonb_array_elements(phase->'transitions') loop
        for mode in select unnest(array['ai']) loop
          d100_projection:=mission_factory_owner.c655_projection_v1(phase,transition,mode);
        end loop;
      end loop;
      if jsonb_array_length(phase->'transitions') is distinct from 2 then raise exception 'C655_PHASE_BINDING_SHAPE';end if;
      d100_refs:=d100_refs||jsonb_build_array(jsonb_build_object('step_key',phase->>'step_key',
        'phase_sha256',mission_factory_owner.sha(phase),'binding',phase->'d100_binding'));
    exception when others then
      errors:=errors||jsonb_build_array(jsonb_build_object('code','MF_D100_NATIVE_BINDING_INVALID','path',phase->>'step_key'));
    end;
  end loop;
  npc_count:=jsonb_array_length(npcs);
  if npc_count>12 or (c.version is not null and npc_count>coalesce((c.document#>>'{limits,png_max}')::integer,12))
    then errors:=errors||jsonb_build_array(jsonb_build_object('code','MF_NPC_LIMIT','path','npc_bindings')); end if;
  for actor in select value from jsonb_array_elements(npcs) loop
    if jsonb_typeof(actor)<>'object' or nullif(actor->>'actor_key','') is null
      then errors:=errors||jsonb_build_array(jsonb_build_object('code','MF_NPC_SHAPE','path','npc_bindings')); continue; end if;
    if actor->>'actor_key'=any(actor_keys)
      then errors:=errors||jsonb_build_array(jsonb_build_object('code','MF_ACTOR_DUPLICATE','path',actor->>'actor_key')); end if;
    actor_keys:=actor_keys||(actor->>'actor_key');
    if jsonb_typeof(actor->'phase_keys')<>'array' then
      errors:=errors||jsonb_build_array(jsonb_build_object('code','MF_NPC_PHASE','path',actor->>'actor_key'));
    elsif exists(select 1 from jsonb_array_elements_text(actor->'phase_keys') em3_k where not(em3_k.value=any(step_keys))) then
      errors:=errors||jsonb_build_array(jsonb_build_object('code','MF_NPC_PHASE','path',actor->>'actor_key'));
    end if;
    begin
      refs:=refs||jsonb_build_array(mission_factory_owner.npc_reference_context_v1(
        d.id,d.control_version,actor->>'actor_key',p_allow_published));
    exception when others then
      errors:=errors||jsonb_build_array(jsonb_build_object('code','MF_NPC_UNAVAILABLE','path',actor->>'actor_key'));
    end;
  end loop;
  for maprow in select value from jsonb_array_elements(maps) loop
    if jsonb_typeof(maprow)<>'object' or nullif(maprow->>'context_media_id','') is null then continue; end if;
    begin
      select * into strict media_ticket from mission_factory_owner.context_media_tickets em3_ticket
        where em3_ticket.media_id=(maprow->>'context_media_id')::uuid and em3_ticket.draft_id=d.id
          and em3_ticket.phase_key=maprow->>'step_key' and em3_ticket.active and em3_ticket.result is not null;
      if media_ticket.result->>'state'<>'registered'
         or not exists(select 1 from storage.objects o
           where o.bucket_id='location-images' and o.name=media_ticket.object_path
             and o.metadata->>'mimetype'=media_ticket.mime_type
             and (o.metadata->>'size')::bigint=media_ticket.bytes)
        then raise exception 'MF_MEDIA_STALE' using errcode='55000'; end if;
      mediarefs:=mediarefs||jsonb_build_array(jsonb_build_object('step_key',media_ticket.phase_key,
        'media_id',media_ticket.media_id,'sha256',media_ticket.sha256));
    exception when others then
      errors:=errors||jsonb_build_array(jsonb_build_object('code','MF_MEDIA_CURRENT_REQUIRED',
        'path',coalesce(maprow->>'step_key','maps')));
    end;
  end loop;
  for phase in select value from jsonb_array_elements(phases) loop
    if jsonb_typeof(phase)<>'object' or phase->>'kind'<>'combat' then continue; end if;
    select x.value into maprow from jsonb_array_elements(maps) x where x.value->>'step_key'=phase->>'step_key';
    if maprow is null or jsonb_typeof(maprow->'combat_map')<>'object'
      then errors:=errors||jsonb_build_array(jsonb_build_object('code','MF_ARENA_REQUIRED','path',phase->>'step_key')); continue; end if;
    begin
      detail:=public.mission_map_detail_v1(maprow#>>'{combat_map,template_key}',(maprow#>>'{combat_map,template_version}')::integer);
      if detail->>'schema_version'<>'mission-map-detail/1' or detail->>'status'<>'ready'
         or coalesce((detail->>'selectable')::boolean,false) is not true
        then raise exception 'MF_ARENA_NOT_READY' using errcode='55000'; end if;
      mapcheck:=public.mission_map_preview_v1(detail->'spec',max_team,
        (select count(*)::integer from jsonb_array_elements(npcs) em3_actor where em3_actor.value->'phase_keys' ? (phase->>'step_key')));
      if coalesce((mapcheck->>'valid')::boolean,false) is not true or coalesce((mapcheck->>'can_fit')::boolean,false) is not true
        then raise exception 'MF_ARENA_CAPACITY' using errcode='55000'; end if;
      maprefs:=maprefs||jsonb_build_array(jsonb_build_object('step_key',phase->>'step_key',
        'template_key',maprow#>>'{combat_map,template_key}',
        'template_version',(maprow#>>'{combat_map,template_version}')::integer,
        'geometry_sha256',mission_factory_owner.sha(detail->'spec')));
    exception when others then
      errors:=errors||jsonb_build_array(jsonb_build_object('code','MF_ARENA_INVALID','path',phase->>'step_key'));
    end;
    if jsonb_typeof(phase->'actor_keys')='array' then
      for actor_key in select value from jsonb_array_elements_text(phase->'actor_keys') loop
        if not exists(select 1 from jsonb_array_elements(npcs) em3_actor
          where em3_actor.value->>'actor_key'=actor_key and em3_actor.value->>'combat'='true')
          then errors:=errors||jsonb_build_array(jsonb_build_object('code','MF_COMBAT_ACTOR','path',phase->>'step_key')); end if;
      end loop;
    end if;
  end loop;
  for mode in select unnest(array['ai']) loop
    variant:=vars->mode;
    if jsonb_typeof(variant)<>'object' or variant->>'mode'<>mode or jsonb_typeof(variant->'document')<>'object'
      then errors:=errors||jsonb_build_array(jsonb_build_object('code','MF_DUAL_VARIANT_DRAFT_REQUIRED','path','variants.'||mode)); continue; end if;
    begin
      perform mission_creation_owner.validate_document(variant->'document');
      IF variant#>>'{document,plan,schema_version}' IS DISTINCT FROM 'mission-generic-plan-document/1' OR variant#>'{document,plan,base_plan_version_id}' IS DISTINCT FROM 'null'::jsonb
       OR NOT mission_generic_owner.keys_valid(variant#>'{document,plan}',ARRAY['schema_version','base_plan_version_id','initial_step_key','steps','transitions','definition','terminal_steps'])
       OR EXISTS(SELECT 1 FROM jsonb_array_elements(variant#>'{document,plan,steps}') st WHERE NOT mission_generic_owner.keys_valid(st,ARRAY['step_key','kind','public_objective']) OR coalesce(st->>'kind','')NOT IN('narrative','mechanical') OR coalesce(st->>'step_key','')!~'^[a-z][a-z0-9_]{0,63}$' OR length(btrim(coalesce(st->>'public_objective','')))NOT BETWEEN 1 AND 500)
       OR EXISTS(SELECT 1 FROM jsonb_array_elements(variant#>'{document,plan,transitions}') em3_tr_json WHERE NOT mission_generic_owner.keys_valid(em3_tr_json,ARRAY['transition_key','from_step_key','to_step_key','event_kind','priority']) OR jsonb_typeof(em3_tr_json->'priority')IS DISTINCT FROM 'number' OR(em3_tr_json->>'priority')::numeric<>trunc((em3_tr_json->>'priority')::numeric))
       OR EXISTS(SELECT 1 FROM jsonb_array_elements(variant#>'{document,plan,steps}') st GROUP BY st->>'step_key' HAVING count(*)>1)
       OR EXISTS(SELECT 1 FROM jsonb_array_elements(variant#>'{document,plan,transitions}') em3_tr_json GROUP BY em3_tr_json->>'transition_key' HAVING count(*)>1)
       OR NOT EXISTS(SELECT 1 FROM jsonb_array_elements(variant#>'{document,plan,steps}') st WHERE st->>'step_key'=variant#>>'{document,plan,initial_step_key}')
      THEN RAISE EXCEPTION 'MF_AI_PLAN_SHAPE' USING ERRCODE='22023';END IF;
      IF jsonb_array_length(variant#>'{document,plan,terminal_steps}')=0
       OR EXISTS(SELECT 1 FROM jsonb_array_elements(variant#>'{document,plan,terminal_steps}') te WHERE NOT mission_generic_owner.keys_valid(te,ARRAY['step_key','outcome']) OR coalesce(te->>'outcome','')NOT IN('success','failure') OR NOT EXISTS(SELECT 1 FROM jsonb_array_elements(variant#>'{document,plan,steps}') st WHERE st->>'step_key'=te->>'step_key' AND st->>'kind'='narrative') OR EXISTS(SELECT 1 FROM jsonb_array_elements(variant#>'{document,plan,transitions}') em3_tr_json WHERE em3_tr_json->>'from_step_key'=te->>'step_key'))
       OR EXISTS(WITH RECURSIVE reach(k)AS(SELECT variant#>>'{document,plan,initial_step_key}' UNION SELECT em3_tr_json->>'to_step_key'FROM jsonb_array_elements(variant#>'{document,plan,transitions}')em3_tr_json JOIN reach ON reach.k=em3_tr_json->>'from_step_key')SELECT 1 FROM jsonb_array_elements(variant#>'{document,plan,steps}')st WHERE st->>'step_key'NOT IN(SELECT reach.k FROM reach))
       OR EXISTS(WITH RECURSIVE ending(k)AS(SELECT te->>'step_key'FROM jsonb_array_elements(variant#>'{document,plan,terminal_steps}')te UNION SELECT em3_tr_json->>'from_step_key'FROM jsonb_array_elements(variant#>'{document,plan,transitions}')em3_tr_json JOIN ending ON ending.k=em3_tr_json->>'to_step_key')SELECT 1 FROM jsonb_array_elements(variant#>'{document,plan,steps}')st WHERE st->>'step_key'NOT IN(SELECT ending.k FROM ending))
      THEN RAISE EXCEPTION 'MF_AI_PATH_TO_END_REQUIRED' USING ERRCODE='22023';END IF;
      PERFORM mission_creation_owner.validate_narrative_budget(variant->'document');

      declare p_definition jsonb:=variant#>'{document,plan,definition}';p_plan uuid:=NULL;s jsonb;e jsonb;a jsonb;t jsonb;tr public.mission_plan_transitions;
 req public.mission_plan_requirements;b public.nb_mechanical_bindings; k text;scount int;sk text;
begin

 if not mission_generic_owner.keys_valid(p_definition,array['schema_version','scenes'])
 or p_definition->>'schema_version' is distinct from 'mission-generic-definition/1'
 or jsonb_typeof(p_definition->'scenes') is distinct from 'array' then
  raise exception 'MG_DEFINITION_SHAPE' using errcode='22023';end if;
 select count(*) into scount from jsonb_populate_recordset(NULL::public.mission_plan_steps,variant#>'{document,plan,steps}') where true;
 if jsonb_array_length(p_definition->'scenes')<>scount or scount=0
 or exists(select 1 from jsonb_array_elements(p_definition->'scenes') x group by x->>'step_key' having count(*)>1)
 then raise exception 'MG_SCENES_COVERAGE' using errcode='22023';end if;
 for s in select value from jsonb_array_elements(p_definition->'scenes') loop
  if not mission_generic_owner.keys_valid(s,array['step_key','actors','encounters','triggers'],array['arrival_conflict'])
  or jsonb_typeof(s->'actors') is distinct from 'array'
  or jsonb_typeof(s->'encounters') is distinct from 'array'
  or jsonb_typeof(s->'triggers') is distinct from 'array'
  or not exists(select 1 from jsonb_populate_recordset(NULL::public.mission_plan_steps,variant#>'{document,plan,steps}') where true and step_key=s->>'step_key')
  then raise exception 'MG_SCENE_INVALID' using errcode='22023';end if;
  if exists(select 1 from jsonb_array_elements(s->'actors') x group by x->>'actor_key' having count(*)>1)
  or exists(select 1 from jsonb_array_elements(s->'encounters') x group by x->>'encounter_key' having count(*)>1)
  or exists(select 1 from jsonb_array_elements(s->'triggers') x group by x->>'trigger_key' having count(*)>1)
  then raise exception 'MG_DUPLICATE_KEY' using errcode='22023';end if;
  select kind into strict sk from jsonb_populate_recordset(NULL::public.mission_plan_steps,variant#>'{document,plan,steps}') where true and step_key=s->>'step_key';
  -- Le scene narrative possono offrire Combat senza renderlo inevitabile.
  if sk='narrative' and jsonb_array_length(s->'encounters')>1 then raise exception 'MFC_NARRATIVE_ENCOUNTER_COUNT' using errcode='22023';end if;
  if sk='mechanical' and jsonb_array_length(s->'encounters')<>1
  then raise exception 'MG_ONE_ENCOUNTER_PER_STEP_REQUIRED' using errcode='22023';end if;
  for a in select value from jsonb_array_elements(s->'actors') loop
   if not mission_generic_owner.keys_valid(a,array['actor_key','mechanical_binding_id','team'],array['narrative_template_id','narrative_version_id','entry_policy'])
   or coalesce(a->>'actor_key','')!~'^[a-z][a-z0-9_]{0,63}$'
   or coalesce(a->>'team','')!~'^[a-z][a-z0-9_]{0,63}$'
   then raise exception 'MG_ACTOR_INVALID' using errcode='22023';end if;
   if a ? 'entry_policy' then
    if not mission_generic_owner.keys_valid(a->'entry_policy',array['visible_on_enter','visibility_trigger_key','entry_capabilities','offense_allowed'])
      or jsonb_typeof(a#>'{entry_policy,visible_on_enter}')<>'boolean'
      or jsonb_typeof(a#>'{entry_policy,offense_allowed}')<>'boolean'
      or jsonb_typeof(a#>'{entry_policy,entry_capabilities}')<>'array'
      or jsonb_array_length(a#>'{entry_policy,entry_capabilities}')>4
      or exists(select 1 from jsonb_array_elements_text(a#>'{entry_policy,entry_capabilities}') capability where capability not in('speak','gesture','utility','offense'))
      or exists(select 1 from jsonb_array_elements_text(a#>'{entry_policy,entry_capabilities}') capability group by capability having count(*)>1)
      or ((a#>>'{entry_policy,offense_allowed}')::boolean is distinct from (a#>'{entry_policy,entry_capabilities}' ? 'offense'))
      or ((a#>>'{entry_policy,visible_on_enter}')::boolean and a#>'{entry_policy,visibility_trigger_key}'<>'null'::jsonb)
      or (not (a#>>'{entry_policy,visible_on_enter}')::boolean and (
        coalesce(a#>>'{entry_policy,visibility_trigger_key}','')!~'^[a-z][a-z0-9_]{0,63}$'
        or not exists(select 1 from jsonb_array_elements(p_definition->'scenes') source_scene
          cross join lateral jsonb_array_elements(source_scene->'triggers') visibility_trigger
          join jsonb_populate_recordset(NULL::public.mission_plan_transitions,variant#>'{document,plan,transitions}') incoming on true
            and incoming.from_step_key=source_scene->>'step_key'
            and incoming.transition_key=visibility_trigger->>'transition_key'
          where incoming.to_step_key=s->>'step_key'
            and visibility_trigger->>'trigger_key'=a#>>'{entry_policy,visibility_trigger_key}')))
      or ((a#>>'{entry_policy,offense_allowed}')::boolean and (
        a->>'mechanical_binding_id' is null or not exists(
          select 1 from jsonb_array_elements(s->'encounters') encounter,
            jsonb_array_elements(encounter->'actors') encounter_actor
          where encounter_actor->>'actor_key'=a->>'actor_key')))
    then raise exception 'MNE_ENTRY_POLICY_INVALID' using errcode='22023';end if;
   end if;
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
  if s ? 'arrival_conflict' then
    if not mission_generic_owner.keys_valid(s->'arrival_conflict',array['encounter_key','entry_side','public_cause'])
      or s#>>'{arrival_conflict,entry_side}' not in('pg','png')
      or length(btrim(coalesce(s#>>'{arrival_conflict,public_cause}',''))) not between 20 and 120
      or not exists(select 1 from jsonb_array_elements(s->'encounters') ae
        where ae->>'encounter_key'=s#>>'{arrival_conflict,encounter_key}')
    then raise exception 'MFC_ARRIVAL_CONFLICT_INVALID' using errcode='22023';end if;
  end if;
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
    if a->>'mechanical_binding_id' is null or not exists(select 1 from jsonb_array_elements(s->'actors') x where x-'entry_policy'=a)
    then raise exception 'MG_ENCOUNTER_ACTOR_SCOPE' using errcode='22023';end if;
   end loop;
  end loop;
  -- Any is a wildcard; overlapping edges would let one server event select two destinations.
  if exists(select 1 from jsonb_array_elements(s->'triggers') with ordinality mc_edge_left(edge,ordinal)
   join jsonb_array_elements(s->'triggers') with ordinality mc_edge_right(edge,ordinal) on mc_edge_left.ordinal<mc_edge_right.ordinal
   where mc_edge_left.edge->>'source_kind'='combat_terminal' and mc_edge_right.edge->>'source_kind'='combat_terminal'
    and mc_edge_left.edge->>'encounter_key'=mc_edge_right.edge->>'encounter_key'
    and (coalesce(mc_edge_left.edge->>'combat_outcome','any')='any' or coalesce(mc_edge_right.edge->>'combat_outcome','any')='any'
     or mc_edge_left.edge->>'combat_outcome'=mc_edge_right.edge->>'combat_outcome'))
  then raise exception 'MG_COMBAT_OUTCOME_OVERLAP' using errcode='22023';end if;
  for t in select value from jsonb_array_elements(s->'triggers') loop
   if not mission_generic_owner.keys_valid(t,array['trigger_key','transition_key','source_kind','fact_code','label'],array['encounter_key','combat_outcome'])
   or coalesce(t->>'trigger_key','')!~'^[a-z][a-z0-9_]{0,63}$'
   or coalesce(t->>'source_kind','') not in('player_choice','combat_terminal','narrative_event','spatial_event')
   or coalesce(t->>'fact_code','')!~'^[a-z][a-z0-9_]{0,79}$'
   or char_length(btrim(coalesce(t->>'label',''))) not between 1 and 160
   then raise exception 'MG_TRIGGER_INVALID' using errcode='22023';end if;
   if t ? 'combat_outcome' and (t->>'source_kind'<>'combat_terminal'
    or coalesce(t->>'combat_outcome','') not in('any','pg_win','pg_loss','draw','peaceful'))
   then raise exception 'MG_COMBAT_OUTCOME_INVALID' using errcode='22023';end if;
   select * into tr from jsonb_populate_recordset(NULL::public.mission_plan_transitions,variant#>'{document,plan,transitions}') where true
    and transition_key=t->>'transition_key' and from_step_key=s->>'step_key';
   if not found then raise exception 'MG_TRIGGER_TRANSITION_SCOPE' using errcode='22023';end if;
   if t->>'combat_outcome'='peaceful' and not exists(
    select 1 from jsonb_populate_recordset(NULL::public.mission_plan_steps,variant#>'{document,plan,steps}') target where true
      and target.step_key=tr.to_step_key and target.kind='narrative'
      and target.step_key<>s->>'step_key') then
    raise exception 'MUP_PEACEFUL_TARGET_NOT_NARRATIVE' using errcode='22023';end if;
   -- A trigger identifies one edge. Existing controller never receives a client destination.
   if (select count(*) from jsonb_populate_recordset(NULL::public.mission_plan_transitions,variant#>'{document,plan,transitions}') where true
    and from_step_key=tr.from_step_key and event_kind=tr.event_kind)<>1
   then raise exception 'MG_TRIGGER_EVENT_AMBIGUOUS' using errcode='22023';end if;
   if (select count(*) from jsonb_array_elements(s->'triggers') mtr where mtr->>'transition_key'=tr.transition_key)<>1
   then raise exception 'MG_TRIGGER_REQUIREMENT_COUNT' using errcode='22023';end if;
   req:=jsonb_populate_record(NULL::public.mission_plan_requirements,jsonb_build_object('ordinal',1,'provider_owner','DB-MISSION','domain','mission','source_kind','server_receipt','capability_key','mission.generic.trigger.v1','feature_version','mission-generic/1','provider_contract_version','mission-evidence-ref/1.2','projection_version',1,'fact_code',t->>'fact_code'));
   if req.ordinal<>1 or req.provider_owner<>'DB-MISSION' or req.domain<>'mission'
    or req.source_kind<>'server_receipt' or req.capability_key is distinct from 'mission.generic.trigger.v1'
    or req.feature_version<>'mission-generic/1' or req.provider_contract_version<>'mission-evidence-ref/1.2'
    or req.projection_version<>1 or req.fact_code is distinct from t->>'fact_code'
   then raise exception 'MG_TRIGGER_REQUIREMENT_CONTRACT' using errcode='22023';end if;
   if t->>'source_kind' in('combat_terminal','spatial_event') then
    if t->>'source_kind'='spatial_event' and sk<>'mechanical' then raise exception 'MG_MECHANICAL_TRIGGER_STEP' using errcode='22023';end if;
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
 if exists(select 1 from jsonb_array_elements(p_definition->'scenes') mc_scene_rows(scene),
  lateral jsonb_array_elements(mc_scene_rows.scene->'actors') mc_actor_rows(actor) group by mc_actor_rows.actor->>'actor_key'
  having count(distinct ((mc_actor_rows.actor-'team'-'entry_policy')))>1)
 then raise exception 'MG_ACTOR_IDENTITY_DRIFT' using errcode='22023';end if;
end;
      if variant#>>'{document,mission,direction_mode}'<>mode
        or variant#>>'{document,mission,title}' is distinct from m->>'title'
        or variant#>>'{document,mission,grado}' is distinct from vars#>>'{ai,document,mission,grado}'
        or variant#>>'{document,mission,gathering_location_id}' is distinct from m->>'gathering_location_id'
        or (variant#>>'{document,mission,team_min}')::integer is distinct from min_team
        or (variant#>>'{document,mission,team_max}')::integer is distinct from max_team
        then raise exception 'MF_VARIANT_MISMATCH' using errcode='22023'; end if;
    exception when others then
      errors:=errors||jsonb_build_array(jsonb_build_object('code','MF_VARIANT_INVALID','path','variants.'||mode));
    end;
  end loop;
  begin
    budget:=em3_engine->'financial_profile';budget:=budget||jsonb_build_object('policy_id',budget->>'financial_qualification_sha256');
    if budget->>'policy_id' is distinct from doc->>'budget_policy_id'
      then errors:=errors||jsonb_build_array(jsonb_build_object('code','MF_BUDGET_STALE','path','budget_policy_id')); end if;
  exception when others then
    errors:=errors||jsonb_build_array(jsonb_build_object('code','MF_BUDGET_UNAVAILABLE','path','budget_policy_id'));
  end;
  if errors='[]'::jsonb then
    basis:=jsonb_build_object('schema_version','mission-factory-preview-basis/3',
      'draft_id',d.id,'draft_version',d.control_version,'document_sha256',d.document_sha256,
      'catalog_sha256',c.document_sha256,'mission_capability_projection_sha256',mission_factory_owner.sha(mission_caps),'npc_refs',refs,'map_refs',maprefs,
      'media_refs',mediarefs,'budget',budget,'d100_native_bindings',d100_refs,'d100_native_subject_sha256','617c77bfb5ac3bb3a2bee0b1776b38fa39204ab737f7c42881f13ad0ab76852f',
      'variants',jsonb_build_object('ai',mission_factory_owner.sha(vars#>'{ai,document}'),
                                    'human',mission_factory_owner.sha(vars#>'{human,document}')));
    seal:=mission_factory_owner.sha(basis);
  end if;
  return jsonb_build_object('schema_version','mission-factory-preview/3','draft_id',d.id,
    'draft_version',d.control_version,'preview_seal',seal,'validated',errors='[]'::jsonb,
    'errors',errors,'public_summary',coalesce(m->>'briefing',''),
    'staff_summary',coalesce(m->>'title',''),'basis',basis);
end 
$function$;

DO $alba_guard$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_catalog.pg_proc proc
    WHERE proc.oid = pg_catalog.to_regprocedure('mission_factory_owner.preview_ai_v3(uuid, bigint, uuid)')
      AND md5(pg_catalog.pg_get_functiondef(proc.oid)) IN ('4a9ef2e1ed3eac633f040e938aca1e5d')
      AND proc.proacl::text = '{postgres=X/postgres}'
      AND pg_catalog.pg_get_userbyid(proc.proowner) = 'postgres'
  ) THEN
    RAISE EXCEPTION 'Alba A: definizione non confermata: preview_ai_v3';
  END IF;
END;
$alba_guard$;

COMMIT;
