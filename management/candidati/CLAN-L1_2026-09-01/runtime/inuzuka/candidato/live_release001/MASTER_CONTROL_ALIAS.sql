DO $guard$ BEGIN IF md5(pg_get_functiondef('clan_inuzuka_private.commit_master_control(jsonb)'::regprocedure)) <> '292c4f356f399948c4889ff6e4be30be' THEN RAISE EXCEPTION 'inuzuka_master_control_drift'; END IF; END $guard$;
CREATE OR REPLACE FUNCTION clan_inuzuka_private.commit_master_control(p jsonb)
 RETURNS jsonb
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO ''
AS $function$
DECLARE uid uuid:=auth.uid();key uuid:=(p->>'request_key')::uuid;fp text:=public.combat_v2_sha256(p);
 prior combat_panel_private.request_receipts%ROWTYPE;o combat_panel_private.offers%ROWTYPE;
 c combat_panel_private.contexts%ROWTYPE;a public.combat_v2_actors%ROWTYPE;cc public.character_companions%ROWTYPE;
 ctx jsonb;resolved jsonb;payload jsonb;result jsonb;env jsonb;receipt jsonb;event jsonb;label text;
 selected uuid[];capability uuid;operation text;eid uuid:=gen_random_uuid();body uuid;expected bigint;
BEGIN
 PERFORM pg_advisory_xact_lock(hashtextextended('panel-request:'||uid::text||':'||key::text,731));
 SELECT * INTO prior FROM combat_panel_private.request_receipts WHERE principal_user=uid AND request_key=key;
 IF FOUND THEN IF prior.command_fingerprint<>fp THEN RAISE EXCEPTION 'panel_request_key_conflict' USING ERRCODE='22023';END IF;
  RETURN jsonb_set(prior.viewer_envelope,'{receipt,replayed}','true',false);END IF;
 SELECT offer.* INTO STRICT o FROM combat_panel_private.offers AS offer
 WHERE offer.id=(p->>'offer_id')::uuid AND offer.principal_user=uid
  AND offer.kind='control' AND offer.operation='control' AND offer.source_payload->>'adapter'='master_v2'
  AND offer.source_payload->>'dispatch'='inuzuka_control';
 SELECT * INTO STRICT c FROM combat_panel_private.contexts WHERE id=o.context_id AND principal_user=uid;
 IF c.activity_kind<>'master_v2' OR c.round_id IS NULL OR c.location_id IS DISTINCT FROM (p->>'location_id')::uuid
  OR c.activity_id IS DISTINCT FROM (p->>'activity_id')::uuid
  OR combat_panel_private.access_reason(c.location_id,'master_v2') IS NOT NULL THEN
  RAISE EXCEPTION 'panel_activity_scope_invalid' USING ERRCODE='42501';END IF;
 PERFORM public.combat_v2_lock_round(c.round_id);PERFORM 1 FROM combat_panel_private.contexts WHERE id=c.id FOR UPDATE;
 c:=combat_panel_private.owned_context(c.id,(p->>'context_version')::bigint);
 SELECT * INTO STRICT o FROM combat_panel_private.offers WHERE id=o.id FOR UPDATE;
 IF o.state<>'offered' OR o.context_version<>c.context_version OR o.source_fingerprint IS DISTINCT FROM c.source_fingerprint
  OR o.scene_version IS DISTINCT FROM c.scene_version OR o.actor_id IS DISTINCT FROM c.command_actor_id THEN
  RAISE EXCEPTION 'panel_offer_not_available' USING ERRCODE='40001';END IF;
 SELECT * INTO STRICT a FROM public.combat_v2_actors WHERE id=o.actor_id AND session_id=c.activity_id
  AND controller_user=uid AND actor_kind='pg' AND companion_id IS NULL AND state='attivo' FOR UPDATE;
 ctx:=combat_panel_private.owner_turn_context(a.id);
 IF (ctx->>'round_id')::uuid IS DISTINCT FROM c.round_id OR NOT coalesce((ctx->>'can_move')::boolean,false)
  OR NOT clan_inuzuka_private.owner_allowed(a.id) THEN RAISE EXCEPTION 'inuzuka_master_turn_changed' USING ERRCODE='40001';END IF;
 operation:=o.source_payload->>'inuzuka_operation';
 IF operation IN ('activate','deactivate') THEN
  expected:=(o.source_payload->>'expected_state')::bigint;
  IF expected IS NULL OR o.source_payload IS DISTINCT FROM jsonb_build_object('adapter','master_v2',
    'dispatch','inuzuka_control','inuzuka_operation',operation,'expected_state',expected)
   OR jsonb_array_length(p->'selected_option_ids')<>0 OR jsonb_array_length(p->'inputs')<>0
   OR p->>'companion_id' IS NOT NULL OR coalesce(p->>'companion_body','')<>'' THEN
   RAISE EXCEPTION 'inuzuka_master_offer_invalid' USING ERRCODE='22023';END IF;
 ELSIF operation<>'staff_profile' THEN
  cc:=clan_inuzuka_private.master_companion_context_assert(p,o,a.id);
 END IF;
 env:=clan_inuzuka_private.master_projection(combat_panel_private.master_projection(c.location_id,a.id));
 SELECT value->>'display_name' INTO label FROM jsonb_array_elements(env->'actors') WHERE value->>'actor_id'=a.id::text;
 SELECT coalesce(array_agg(value::uuid),'{}') INTO selected FROM jsonb_array_elements_text(p->'selected_option_ids');
 resolved:=combat_panel_private.resolve_selections(o.id,selected,p->'inputs');
 FOR payload IN SELECT choice->'payload' FROM jsonb_array_elements(resolved->'groups') AS groups(g)
  CROSS JOIN LATERAL jsonb_array_elements(g->'options') AS choices(choice) LOOP
  IF payload ? 'movement_capability_id' THEN IF capability IS NOT NULL THEN
   RAISE EXCEPTION 'panel_movement_selection_conflict' USING ERRCODE='22023';END IF;
   capability:=(payload->>'movement_capability_id')::uuid;END IF;
 END LOOP;
 IF operation IN ('activate','deactivate') AND capability IS NULL AND cardinality(selected)=0 THEN
  result:=clan_innata_private.combat_transition(a.id,'c11ecd52-43cd-479b-8d5d-08187beba56e',operation,key,expected);
 ELSIF operation='staff_profile' AND capability IS NULL AND cardinality(selected)=0 THEN
  IF p->>'companion_id' IS NOT NULL OR coalesce(p->>'companion_body','')<>'' THEN
   RAISE EXCEPTION 'inuzuka_staff_profile_command_invalid' USING ERRCODE='22023';END IF;
  result:=clan_inuzuka_private.staff_profile_apply(a.id);
 ELSIF operation='bind' AND capability IS NULL AND cardinality(selected)=0 THEN
  body:=clan_inuzuka_private.body_bind(a.id,cc.id,o.source_payload->'placement');
  result:=jsonb_build_object('actor_id',body,'companion_id',cc.id,'operation','bind');
 ELSIF operation='move' AND capability IS NOT NULL THEN
  result:=clan_inuzuka_private.movement_commit(a.id,capability,key,o.id)||jsonb_build_object(
   'actor_id',o.source_payload->'ninken_actor_id','companion_id',cc.id,'operation','move');
 ELSE RAISE EXCEPTION 'inuzuka_master_operation_invalid' USING ERRCODE='22023';END IF;
 IF operation IN ('bind','move') THEN
  PERFORM public.post_message(c.location_id,p->>'narrative_text',NULL,cc.id,p->>'companion_body');
 END IF;
 event:=jsonb_build_object('event_id',eid,'event_kind','control_changed','actor_id',a.id,'display_name',label,
  'label_version',c.context_version,'target_actor_id',NULL,'target_display_name',NULL,'target_label_version',NULL,
  'summary',CASE operation WHEN 'staff_profile' THEN 'Profilo Inuzuka simulato pronto.'
   WHEN 'activate' THEN 'Quattro Zampe attiva.' WHEN 'deactivate' THEN 'Quattro Zampe disattivata.'
   WHEN 'bind' THEN 'Ninken schierato sulla mappa.' ELSE 'Ninken spostato sulla mappa.' END);
 env:=clan_inuzuka_private.master_projection(combat_panel_private.master_projection(c.location_id,a.id));
 receipt:=jsonb_build_object('receipt_id',eid,'request_key',key,'operation','control','replayed',false,
  'activity_id',c.activity_id,'round_id',c.round_id,'context_version_before',o.context_version,
  'context_version_after',env#>'{context,version}','declaration_id',NULL,'report_id',NULL,
  'values_written',coalesce((result->>'values_written')::boolean,false),'display_events',jsonb_build_array(event),'inuzuka',result);
 env:=jsonb_set(env,'{receipt}',receipt);
 UPDATE combat_panel_private.offers SET state='consumed',consumed_request_key=key WHERE id=o.id;
 INSERT INTO combat_panel_private.request_receipts(principal_user,request_key,command_fingerprint,offer_id,event_id,viewer_envelope)
 VALUES(uid,key,fp,o.id,eid,env);RETURN env;
END $function$;
DO $guard$ BEGIN IF md5(pg_get_functiondef('clan_inuzuka_private.commit_master_control(jsonb)'::regprocedure)) <> 'a9fff8f899516e79f9edc8e533ec8f34' THEN RAISE EXCEPTION 'inuzuka_master_control_drift'; END IF; END $guard$;
