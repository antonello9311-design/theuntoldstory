CREATE OR REPLACE FUNCTION combat_panel_private.multiplication_choose_ordinary_source(p_context uuid, p_expected bigint, p_candidates jsonb, p_request uuid)
 RETURNS jsonb
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO ''
AS $function$
DECLARE c combat_panel_private.contexts%ROWTYPE;ctx combat_consumer_private.activities%ROWTYPE;
 a public.combat_v2_actors%ROWTYPE;source combat_consumer_private.offers%ROWTYPE;move combat_consumer_private.offers%ROWTYPE;
 cap combat_spatial.movement_capabilities%ROWTYPE;body combat_spatial.actor_states%ROWTYPE;
 instance combat_spatial.arena_instances%ROWTYPE;ch combat_spatial.movement_semantic_choices%ROWTYPE;
 old combat_panel_private.multiplication_ordinary_draw_plans%ROWTYPE;
 candidate jsonb;selection jsonb;geometry jsonb;point jsonb;normalized jsonb:='[]'::jsonb;chosen jsonb;
 indices integer[]:=ARRAY[]::integer[];idx integer;seed bytea;target uuid;formation uuid;version bigint;
 target_current uuid;formation_current uuid;version_current bigint;is_companion boolean;range_m numeric;
 expected_origin boolean;expected_range numeric;distance_m numeric;expected_distance numeric; suiton_profile jsonb; expected_suiton uuid;
BEGIN
 c:=combat_panel_private.owned_context(p_context,p_expected);
 IF p_request IS NULL OR c.activity_kind<>'ordinary_v2' OR c.round_id IS NULL OR c.command_actor_id IS NULL
  OR jsonb_typeof(p_candidates) IS DISTINCT FROM 'array' OR jsonb_array_length(p_candidates)=0 THEN
  RAISE EXCEPTION 'panel_multiplication_draw_invalid' USING ERRCODE='22023'; END IF;
 PERFORM public.combat_v2_lock_round(c.round_id);
 SELECT * INTO STRICT ctx FROM combat_consumer_private.activities WHERE session_id=c.activity_id
  AND exchange_id=c.round_id AND phase='action' AND turn_actor_id=c.command_actor_id;
 SELECT * INTO STRICT a FROM public.combat_v2_actors WHERE id=c.command_actor_id AND session_id=c.activity_id
  AND controller_user=auth.uid() AND state='attivo' AND companion_id IS NULL;
 SELECT * INTO STRICT instance FROM combat_spatial.arena_instances WHERE encounter_id=c.activity_id AND state='open' FOR UPDATE;
 FOR candidate IN SELECT value FROM jsonb_array_elements(p_candidates) LOOP
  IF jsonb_typeof(candidate) IS DISTINCT FROM 'object'
   OR candidate-ARRAY['source_offer_id','movement_offer_id']<>'{}'::jsonb
   OR candidate->>'source_offer_id' IS NULL THEN
   RAISE EXCEPTION 'panel_multiplication_draw_invalid' USING ERRCODE='22023'; END IF;
  SELECT * INTO STRICT source FROM combat_consumer_private.offers WHERE id=(candidate->>'source_offer_id')::uuid
   AND session_id=c.activity_id AND exchange_id=c.round_id AND location_id=c.location_id
   AND principal_character_id=a.character_id AND context_version=ctx.context_version
   AND scene_version=c.scene_version AND state='offered' AND operation='declare';
  selection:=source.source_payload->'multiplication_attack_target';
  IF selection IS NULL OR source.source_payload#>>'{intent,kind}' IS DISTINCT FROM 'attacco'
   OR selection->>'target_actor_id' IS DISTINCT FROM source.source_payload#>>'{intent,target_actor}' THEN
   RAISE EXCEPTION 'panel_multiplication_draw_invalid' USING ERRCODE='22023'; END IF;
  is_companion:=coalesce(selection->>'attack_origin'='marionetta',false);
  suiton_profile:=NULL;
  IF NOT is_companion AND source.source_payload#>>'{intent,ability_source}'='clan' THEN
   suiton_profile:=coalesce(combat_v2_elemental_internal.suiton_profile(a.id,(source.source_payload#>>'{intent,ability_id}')::uuid),combat_v2_elemental_internal.other_profile(a.id,(source.source_payload#>>'{intent,ability_id}')::uuid));
  END IF;
  IF NOT coalesce((is_companion AND source.source_payload#>>'{intent,ability_source}'='clan'
   AND source.source_payload#>>'{intent,ability_id}'='e361f7c3-f90b-47ec-bfee-ccbda21257d9')
   OR (NOT is_companion AND coalesce(selection->>'attack_origin','actor')='actor'
   AND (source.source_payload#>>'{intent,ability_source}'='mano' OR suiton_profile IS NOT NULL)),false) THEN
   RAISE EXCEPTION 'panel_attack_origin_invalid' USING ERRCODE='22023'; END IF;
  range_m:=CASE WHEN suiton_profile->>'catalog_technique_id'='72cbe1fb-34c8-44c7-a053-0014b4894b3e' THEN combat_v2_elemental_internal.scarica_contact_range(a.id,(selection->>'target_actor_id')::uuid) WHEN suiton_profile IS NOT NULL THEN (suiton_profile->>'range_m')::numeric WHEN is_companion THEN 3 ELSE combat_panel_private.manual_contact_center_range(a.id,(selection->>'target_actor_id')::uuid) END;
  -- The new canonical ranged value follows the existing Tactics release authority.
  IF range_m=10 AND combat_panel_private.multiplication_tactics_allowed(a.id) IS DISTINCT FROM true THEN
   RAISE EXCEPTION 'panel_multiplication_ranged_scope_not_allowed' USING ERRCODE='42501';
  END IF;
  target_current:=(selection->>'target_actor_id')::uuid;formation_current:=(selection->>'formation_id')::uuid;
  version_current:=(selection->>'state_version')::bigint;idx:=(selection->>'figure_index')::integer;
  IF target IS NULL THEN target:=target_current;formation:=formation_current;version:=version_current;
   expected_origin:=is_companion;expected_range:=range_m;
   expected_suiton:=CASE WHEN suiton_profile IS NOT NULL THEN (source.source_payload#>>'{intent,ability_id}')::uuid END;
  ELSIF (target,formation,version,expected_origin) IS DISTINCT FROM (target_current,formation_current,version_current,is_companion)
   OR expected_suiton IS DISTINCT FROM (CASE WHEN suiton_profile IS NOT NULL THEN (source.source_payload#>>'{intent,ability_id}')::uuid END) THEN
   RAISE EXCEPTION 'panel_multiplication_draw_invalid' USING ERRCODE='22023'; END IF;
  IF idx IS NULL OR idx=ANY(indices) THEN RAISE EXCEPTION 'panel_multiplication_draw_invalid' USING ERRCODE='22023'; END IF;
  IF is_companion THEN
   geometry:=combat_panel_private.multiplication_companion_target_figure(c.round_id,a.id,target,formation,version,idx);
  ELSE geometry:=combat_panel_private.multiplication_target_figure(a.id,target,formation,version,idx); END IF;
  point:=geometry->'figure';
  IF geometry->>'instance_id' IS DISTINCT FROM instance.instance_id::text THEN
   RAISE EXCEPTION 'panel_multiplication_draw_stale' USING ERRCODE='40001'; END IF;
  IF candidate->>'movement_offer_id' IS NULL THEN
   distance_m:=0;
   IF (point->>'distance_m')::numeric>range_m OR NOT (point->>'path_clear')::boolean THEN
    RAISE EXCEPTION 'panel_multiplication_draw_stale' USING ERRCODE='40001'; END IF;
  ELSE
   IF is_companion THEN RAISE EXCEPTION 'panel_attack_origin_invalid' USING ERRCODE='22023'; END IF;
   SELECT * INTO STRICT move FROM combat_consumer_private.offers WHERE id=(candidate->>'movement_offer_id')::uuid
    AND parent_offer_id=source.id AND session_id=c.activity_id AND exchange_id=c.round_id
    AND location_id=c.location_id AND principal_character_id=a.character_id AND context_version=ctx.context_version
    AND scene_version=c.scene_version AND state='offered' AND offer_kind='movement';
   SELECT * INTO STRICT cap FROM combat_spatial.movement_capabilities WHERE capability_id=(move.source_payload->>'capability_id')::uuid
    AND instance_id=instance.instance_id AND actor_id=a.id AND state='offered';
   SELECT * INTO STRICT body FROM combat_spatial.actor_states WHERE instance_id=instance.instance_id AND actor_id=a.id
    AND controller_principal_id=auth.uid() AND state='active';
   SELECT * INTO STRICT ch FROM combat_spatial.movement_semantic_choices WHERE instance_id=instance.instance_id
    AND actor_id=a.id AND choice_key=cap.choice_key AND enabled;
   IF cap.map_version<>instance.map_version OR cap.actor_body_version<>body.body_version OR cap.choice_version<>ch.choice_version
    OR (cap.start_x_m,cap.start_y_m) IS DISTINCT FROM (body.x_m,body.y_m)
    OR combat_spatial.distance_m(cap.end_x_m,cap.end_y_m,(point->>'x_m')::numeric,(point->>'y_m')::numeric)>range_m
    OR combat_spatial.path_first_block_t(instance.instance_id,a.id,cap.end_x_m,cap.end_y_m,
      (point->>'x_m')::numeric,(point->>'y_m')::numeric,target)<1 THEN
    RAISE EXCEPTION 'panel_multiplication_draw_stale' USING ERRCODE='40001'; END IF;
   distance_m:=round(combat_spatial.distance_m(cap.start_x_m,cap.start_y_m,cap.end_x_m,cap.end_y_m),2);
  END IF;
  IF expected_distance IS NULL THEN expected_distance:=distance_m;
  ELSIF expected_distance<>distance_m THEN RAISE EXCEPTION 'panel_multiplication_draw_distance_mismatch' USING ERRCODE='22023'; END IF;
  indices:=array_append(indices,idx);
  normalized:=normalized||jsonb_build_array(candidate||jsonb_build_object('figure_index',idx));
 END LOOP;
 SELECT array_agg((value->>'figure_index')::integer ORDER BY (value->>'figure_index')::integer),
  jsonb_agg(value ORDER BY (value->>'figure_index')::integer) INTO indices,normalized FROM jsonb_array_elements(normalized);
 SELECT * INTO old FROM combat_panel_private.multiplication_ordinary_draw_plans WHERE request_key=p_request AND target_actor_id=target;
 IF old.request_key IS NOT NULL THEN
  IF old.principal_user IS DISTINCT FROM auth.uid() OR old.prepared_transaction<>txid_current()
   OR old.round_id<>c.round_id OR old.actor_id<>a.id OR old.candidates IS DISTINCT FROM normalized THEN
   RAISE EXCEPTION 'panel_request_key_conflict' USING ERRCODE='22023'; END IF;
  seed:=old.random_seed;
 ELSE seed:=extensions.gen_random_bytes(32); END IF;
 idx:=indices[combat_panel_private.multiplication_random_figure(cardinality(indices),seed)];
 SELECT value INTO STRICT chosen FROM jsonb_array_elements(normalized) WHERE (value->>'figure_index')::integer=idx;
 IF old.request_key IS NULL THEN
  INSERT INTO combat_panel_private.multiplication_ordinary_draw_plans
   (request_key,target_actor_id,round_id,actor_id,principal_user,prepared_transaction,source_offer_id,movement_offer_id,
    formation_id,formation_version,random_seed,random_indices,selected_index,range_m,candidates)
  VALUES(p_request,target,c.round_id,a.id,auth.uid(),txid_current(),(chosen->>'source_offer_id')::uuid,
   (chosen->>'movement_offer_id')::uuid,formation,version,seed,indices,idx,expected_range,normalized);
 END IF;
 RETURN chosen- 'figure_index';
END $function$

