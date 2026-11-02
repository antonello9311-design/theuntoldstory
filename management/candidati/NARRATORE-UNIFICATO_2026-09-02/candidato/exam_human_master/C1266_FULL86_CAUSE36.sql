-- FONTE VERIFICATA: estratto della funzione installata, non installer autonomo.
-- Applicare soltanto tramite pacchetto integrato revisionato e baseline viva.
-- SHA256 installer privato: cf8eaf33f307ab5852a8cf72867c49bc3371a071fb34eb841d30f8ba8f0ef777
-- MD5 pg_get_functiondef atteso: 69b96309bd743d095af9d6ac8521ea12
CREATE OR REPLACE FUNCTION combat_panel_private.commit_master_actor(p_command jsonb)
 RETURNS jsonb
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO ''
AS $function$
DECLARE p jsonb; uid uuid:=exam_regia_private.current_principal(); key uuid; fp text; receipt_id uuid:=gen_random_uuid();
 prior combat_panel_private.request_receipts%ROWTYPE; o combat_panel_private.offers%ROWTYPE;
 c combat_panel_private.contexts%ROWTYPE; a public.combat_v2_actors%ROWTYPE;
 env jsonb; resolved jsonb; selected uuid[]; payload jsonb; intent jsonb; v_master_actor_result jsonb; receipt jsonb;
 targets uuid[]:='{}'; coverages uuid[]:='{}'; primary_attack uuid; movement uuid; substitution uuid;
  rotation_radius integer; fireball_selection jsonb; declaration uuid; label text; target_label text; event jsonb; dispatch text; flow_allocations jsonb:='[]';
  human_stage boolean:=false;intent_stage boolean:=false; ack_context_version bigint;
BEGIN
 IF uid IS NULL THEN RAISE EXCEPTION 'panel_authentication_required' USING ERRCODE='28000'; END IF;
 p:=combat_panel_private.validate_command(p_command); key:=(p->>'request_key')::uuid; fp:=public.combat_v2_sha256(p);
 PERFORM pg_advisory_xact_lock(hashtextextended('panel-request:'||uid::text||':'||key::text,731));
 SELECT * INTO prior FROM combat_panel_private.request_receipts WHERE principal_user=uid AND request_key=key;
 IF prior.request_key IS NOT NULL THEN
   IF prior.command_fingerprint<>fp THEN RAISE EXCEPTION 'panel_request_key_conflict' USING ERRCODE='22023'; END IF;
   RETURN jsonb_set(prior.viewer_envelope,'{receipt,replayed}','true',false);
 END IF;
 SELECT * INTO o FROM combat_panel_private.offers WHERE id=(p->>'offer_id')::uuid AND principal_user=uid;
 IF o.id IS NULL OR o.source_payload->>'adapter' IS DISTINCT FROM 'master_v2'
   OR o.kind NOT IN ('action','defense') THEN RAISE EXCEPTION 'panel_offer_not_available' USING ERRCODE='42501'; END IF;
 -- Preserve historical idempotent receipts; reject only new commits of stale passive attacks.
 IF o.source_payload->>'dispatch'='action' AND o.source_payload->>'kind'='attacco'
   AND o.source_payload->>'ability_source'='clan'
   AND o.source_payload->>'ability_id'='4056f62d-77f3-47f9-8ecb-9a7799682a9d' THEN
   RAISE EXCEPTION 'panel_passive_ability_not_attack' USING ERRCODE='22023'; END IF;
 SELECT * INTO STRICT c FROM combat_panel_private.contexts WHERE id=o.context_id AND principal_user=uid;
 IF c.activity_kind<>'master_v2' OR c.round_id IS NULL
   OR c.location_id IS DISTINCT FROM (p->>'location_id')::uuid OR c.activity_id IS DISTINCT FROM (p->>'activity_id')::uuid THEN
   RAISE EXCEPTION 'panel_activity_scope_invalid' USING ERRCODE='22023'; END IF;
 PERFORM public.combat_v2_lock_round(c.round_id);
 env:=combat_panel_private.master_projection(c.location_id,c.command_actor_id);
 PERFORM 1 FROM combat_panel_private.contexts WHERE id=c.id FOR UPDATE;
 c:=combat_panel_private.owned_context(c.id,(p->>'context_version')::bigint);
 SELECT * INTO STRICT o FROM combat_panel_private.offers WHERE id=o.id FOR UPDATE;
 IF o.state<>'offered' OR o.context_version<>c.context_version OR o.source_fingerprint IS DISTINCT FROM c.source_fingerprint
   OR o.scene_version IS DISTINCT FROM c.scene_version OR o.actor_id IS DISTINCT FROM c.command_actor_id THEN
   RAISE EXCEPTION 'panel_offer_not_available' USING ERRCODE='40001'; END IF;
 IF o.requires_role AND length(btrim(p->>'narrative_text'))=0 THEN RAISE EXCEPTION 'panel_role_required' USING ERRCODE='22023'; END IF;
 SELECT * INTO STRICT a FROM public.combat_v2_actors WHERE id=o.actor_id AND session_id=c.activity_id
   AND exam_regia_private.actor_principal(id,controller_user)=uid AND companion_id IS NULL AND state='attivo' FOR UPDATE;
 SELECT coalesce(array_agg(value::uuid),'{}') INTO selected FROM jsonb_array_elements_text(p->'selected_option_ids');
 resolved:=combat_panel_private.resolve_selections(o.id,selected,p->'inputs');
 FOR payload IN SELECT choice->'payload' FROM jsonb_array_elements(resolved->'groups') AS groups(g)
   CROSS JOIN LATERAL jsonb_array_elements(g->'options') AS choices(choice) LOOP
   IF payload ? 'rotation_radius_m' THEN
     IF rotation_radius IS NOT NULL THEN RAISE EXCEPTION 'rotation_selection_duplicate';END IF;
     rotation_radius:=(payload->>'rotation_radius_m')::integer;
   END IF;
   IF payload ? 'fireball_selection' THEN
     IF fireball_selection IS NOT NULL THEN RAISE EXCEPTION 'fireball_selection_conflict';END IF;
     fireball_selection:=payload->'fireball_selection';
   END IF;
   IF payload ? 'attack_target_id' THEN
     coverages:=array_append(coverages,(payload->>'attack_target_id')::uuid);
     primary_attack:=coalesce(primary_attack,(payload->>'attack_declaration_id')::uuid);
   ELSIF payload ? 'target_actor_id' THEN targets:=array_append(targets,(payload->>'target_actor_id')::uuid);
   END IF;
   IF o.source_payload#>>'{sabaku_flow,version}'='sabaku-flow/2' AND payload ? 'target_actor_id' THEN
     IF NOT payload ? 'flow_count' THEN RAISE EXCEPTION 'sabaku_flow_quantity_required' USING ERRCODE='22023'; END IF;
     flow_allocations:=flow_allocations||jsonb_build_array(jsonb_build_object(
       'target_actor_id',payload->'target_actor_id','flows',payload->'flow_count'));
   END IF;
   IF payload ? 'movement_capability_id' THEN
     IF movement IS NOT NULL THEN RAISE EXCEPTION 'panel_movement_selection_conflict' USING ERRCODE='22023'; END IF;
     movement:=(payload->>'movement_capability_id')::uuid;
   END IF;
   IF payload ? 'substitution_option_id' THEN
     IF substitution IS NOT NULL THEN RAISE EXCEPTION 'panel_substitution_selection_conflict' USING ERRCODE='22023'; END IF;
     substitution:=(payload->>'substitution_option_id')::uuid;
   END IF;
  END LOOP;
  -- Only the Master-controlled PNG may stage privately. PG declarations and
  -- defenses continue through the published window and native controller checks.
  IF a.actor_kind='png' THEN
   PERFORM mission_generic_owner.regia_human_stage_permit_v1(c.round_id,a.id,key);
  END IF;
  -- The human permit is bound to this offer, actor and request in the same TX.
  -- Native context/offer and controller versions were checked above under lock.
  SELECT EXISTS(SELECT 1
    FROM mission_generic_owner.regia_human_stage_permits_v1 hp
    JOIN mission_generic_owner.regia_human_windows_v1 hw
      ON hw.next_round_id=hp.round_id AND hw.master_session_id=hp.master_session_id
    JOIN mission_generic_owner.unified_round_windows uw
      ON uw.round_id=hp.round_id AND uw.batch_id=hw.batch_id
       AND uw.master_session_id=hw.master_session_id
    JOIN public.combat_v2_sessions cs ON cs.id=c.activity_id
       AND cs.master_session_id=hw.master_session_id
    JOIN public.master_v2_sessions ms ON ms.id=hw.master_session_id
    WHERE hp.round_id=c.round_id AND hp.actor_id=a.id AND hp.request_key=key
      AND hp.principal_id=uid AND hp.transaction_id=txid_current()
      AND hp.backend_pid=pg_backend_pid()
      AND hw.encounter_id=cs.id AND a.session_id=cs.id AND a.actor_kind='png'
      AND ms.owner_kind='human' AND ms.closed_at IS NULL
      AND ms.master_user=uid
      AND ms.location_id='0b85f354-9cdb-47e1-baf9-3d266bb7e06b'::uuid
      AND ((hw.state='private' AND hw.side='png' AND uw.side='png'
            AND uw.publication_id IS NULL AND o.operation='declare'
            AND a.id=ANY(uw.expected_actor_ids))
        OR (hw.state='published' AND hw.side='pg' AND uw.side='pg'
            AND uw.publication_id IS NOT NULL AND o.operation='defend'
            AND o.kind='defense')))
    INTO human_stage;
  intent_stage:=auth.uid() IS NULL AND public.combat_v2_is_service() AND a.actor_kind='png'
   AND o.kind='action' AND o.operation='declare' AND o.source_payload->>'dispatch'='action' AND o.source_payload->>'kind'='passa'
   AND mission_generic_owner.unified_service_staging(c.round_id) AND EXISTS(SELECT 1 FROM mission_generic_owner.unified_round_windows uw
     JOIN mission_generic_owner.unified_batches b ON b.id=uw.batch_id JOIN mission_generic_owner.unified_publication_permits pp ON pp.batch_id=b.id AND pp.work_id=b.writer_work_id
     WHERE uw.round_id=c.round_id AND uw.publication_id IS NULL AND a.id=ANY(uw.expected_actor_ids) AND b.retired_at IS NULL
       AND pp.transaction_id=txid_current() AND pp.backend_pid=pg_backend_pid() AND mission_generic_owner.native_intent_work_v1(b.writer_work_id));
  PERFORM mission_generic_owner.unified_assert_command(c.round_id,CASE WHEN o.kind='defense' THEN 'defend' ELSE 'declare' END);
 dispatch:=o.source_payload->>'dispatch';
 IF dispatch IN ('action','movement') THEN
   IF o.source_payload->>'fireball'='true' THEN
     IF fireball_selection IS NULL THEN RAISE EXCEPTION 'fireball_selection_required';END IF;
     intent:=clan_uchiha_private.fireball_prepare(c.round_id,a.id,key,fireball_selection);
     SELECT coalesce(array_agg(value::uuid),'{}') INTO targets FROM jsonb_array_elements_text(coalesce(intent->'target_actor_ids','[]'));
   ELSE
   intent:=jsonb_build_object('kind',o.source_payload->'kind');
   IF intent->>'kind'='attacco' THEN
     IF cardinality(targets)=0 THEN RAISE EXCEPTION 'panel_target_required' USING ERRCODE='22023'; END IF;
     intent:=intent||jsonb_build_object('target_actor',targets[1],'target_actor_ids',targets,
       'ability_source',o.source_payload->'ability_source');
     IF o.source_payload ? 'ability_id' THEN intent:=intent||jsonb_build_object('ability_id',o.source_payload->'ability_id'); END IF;
   ELSIF intent->>'kind'='utilita' AND o.source_payload->>'aburame_escape'='true' THEN
     intent:=intent||jsonb_build_object('ability_source','clan','ability_id','f5e9af24-70f1-49f6-a7ca-74f59256336e');
   ELSIF dispatch='movement' THEN
     IF movement IS NULL THEN RAISE EXCEPTION 'panel_movement_required' USING ERRCODE='22023'; END IF;
   END IF;
   IF movement IS NOT NULL THEN
     IF dispatch='movement' THEN
       PERFORM combat_panel_private.prepare_master_movement(c.round_id,a.id,movement,key);
     ELSIF dispatch='action' AND intent->>'kind'='attacco' AND cardinality(targets)=1
       AND (coalesce(intent->>'ability_source','mano')='mano' OR (intent->>'ability_source'='clan' AND intent->>'ability_id' IN ('9ac77d79-9894-5388-9753-70538ac5eaa3','b076a976-c75b-4b5a-8813-b0e8e2c3af03')))
       AND combat_panel_private.movement_attack_target_valid(a.id,targets[1],movement,CASE WHEN intent->>'ability_source'='clan' THEN 2 ELSE combat_panel_private.manual_contact_center_range(a.id,targets[1]) END)
       AND (intent->>'ability_source'<>'clan' OR intent->>'ability_id'='b076a976-c75b-4b5a-8813-b0e8e2c3af03' OR (SELECT combat_spatial.distance_m(start_x_m,start_y_m,end_x_m,end_y_m)>=5 FROM combat_spatial.movement_capabilities WHERE capability_id=movement)) THEN
       PERFORM combat_panel_private.prepare_master_movement(c.round_id,a.id,movement,key);
     ELSE
       RAISE EXCEPTION 'panel_movement_attack_selection_invalid' USING ERRCODE='22023';
     END IF;
   END IF;
   END IF;
   IF intent->>'kind'='attacco' AND fireball_selection IS NULL THEN
     PERFORM combat_panel_private.multiplication_prepare_selected_aims(c.round_id,a.id,key,targets,resolved);
   END IF;
   IF o.source_payload#>>'{sabaku_flow,version}'='sabaku-flow/2' THEN
     IF movement IS NOT NULL OR dispatch<>'action' OR intent->>'kind'<>'attacco' THEN
       RAISE EXCEPTION 'sabaku_flow_offer_invalid' USING ERRCODE='22023'; END IF;
     -- Il totale e' congelato nell'offerta nativa, mai ricevuto come valore libero dal client.
     IF jsonb_typeof(o.source_payload#>'{sabaku_flow,quantity}') IS DISTINCT FROM 'number'
       OR (o.source_payload#>>'{sabaku_flow,quantity}') !~ '^[1-3]$' THEN
       RAISE EXCEPTION 'sabaku_flow_total_required' USING ERRCODE='22023'; END IF;
     IF (clan_sabaku_private.flow_costs(1,flow_allocations)->>'flows')::integer
       IS DISTINCT FROM (o.source_payload#>>'{sabaku_flow,quantity}')::integer THEN
       RAISE EXCEPTION 'sabaku_flow_total_allocation_mismatch' USING ERRCODE='22023'; END IF;
     PERFORM clan_sabaku_private.flow_prepare(c.round_id,a.id,key,o.id,'panel',flow_allocations);
   END IF;
   IF intent->>'ability_source'='clan' AND combat_v2_elemental_internal.suiton_profile(a.id,(intent->>'ability_id')::uuid) IS NOT NULL THEN
     PERFORM combat_v2_elemental_internal.suiton_prepare_callback('master_v2',o.id,a.id,key,
       ARRAY(SELECT value::uuid FROM jsonb_array_elements_text(p->'selected_option_ids')),p->'inputs',intent);
   END IF;
   IF intent->>'ability_source'='clan' AND combat_v2_elemental_internal.other_profile(a.id,(intent->>'ability_id')::uuid) IS NOT NULL THEN
     PERFORM combat_v2_elemental_internal.other_prepare_callback('master_v2',o.id,a.id,key,ARRAY(SELECT value::uuid FROM jsonb_array_elements_text(p->'selected_option_ids')),p->'inputs',intent);
   END IF;
   v_master_actor_result:=public.combat_v2_action_declare(c.round_id,a.id,intent,p->>'narrative_text',key);
   declaration:=(v_master_actor_result#>>'{data,declaration_id}')::uuid;
 ELSIF dispatch='defense' THEN
   IF cardinality(coverages)=0 OR primary_attack IS NULL THEN RAISE EXCEPTION 'panel_coverage_required' USING ERRCODE='22023'; END IF;
   intent:=jsonb_build_object('reaction',o.source_payload->'reaction','attack_target_ids',coverages);
   IF o.source_payload ? 'ability_id' THEN intent:=intent||jsonb_build_object(
     'ability_source',o.source_payload->'ability_source','ability_id',o.source_payload->'ability_id'); END IF;
   IF o.source_payload->>'rotation_version'='hyuga-rotation/1' THEN
     PERFORM clan_hyuga_private.rotation_prepare(c.round_id,a.id,primary_attack,key,rotation_radius);
   END IF;
   IF o.source_payload->>'aburame_clone'='aburame-clone/1' THEN
     IF primary_attack IS DISTINCT FROM (o.source_payload->>'attack_id')::uuid THEN RAISE EXCEPTION 'aburame_clone_attack_drift';END IF;
     PERFORM clan_aburame_private.clone_prepare(c.round_id,a.id,primary_attack,key,(o.source_payload->>'movement_capability')::uuid);
   END IF;
   v_master_actor_result:=public.combat_v2_defense_declare(c.round_id,primary_attack,a.id,intent,p->>'narrative_text',key);
   declaration:=(v_master_actor_result#>>'{data,defense_id}')::uuid;
 ELSIF dispatch='substitution' THEN
   IF substitution IS NULL THEN RAISE EXCEPTION 'panel_substitution_required' USING ERRCODE='22023'; END IF;
   PERFORM clan_marionettisti_private.assert_jutsu_source(a.id,'jutsu','31b15861-fb78-4f8a-ac1c-ebf2d957c32e');
   IF EXISTS(SELECT 1 FROM combat_spatial.request_receipts WHERE request_key=key) THEN
     RAISE EXCEPTION 'panel_request_key_conflict' USING ERRCODE='22023'; END IF;
   v_master_actor_result:=public.combat_v2_substitution_select_v1(substitution,key);
   declaration:=(v_master_actor_result->>'defense_declaration_id')::uuid;
   -- Il selector vivo crea il testo vuoto. Completa solo la dichiarazione
   -- appena creata, ancora inviata e controllata, nella stessa transazione.
   UPDATE public.combat_v2_declarations SET declaration_text=p->>'narrative_text'
     WHERE id=declaration AND round_id=c.round_id AND actor_id=a.id AND request_key=key
       AND controller_user_snapshot=uid AND state='inviata' AND declaration_text='';
   IF NOT FOUND THEN RAISE EXCEPTION 'panel_substitution_declaration_invalid' USING ERRCODE='22023'; END IF;
 ELSE RAISE EXCEPTION 'panel_dispatch_not_available' USING ERRCODE='22023'; END IF;
 IF declaration IS NULL THEN RAISE EXCEPTION 'panel_source_receipt_invalid' USING ERRCODE='22023'; END IF;
  IF o.operation='defend' THEN
    PERFORM combat_panel_private.multiplication_register_defense_selections(c.round_id,a.id,key,resolved,declaration); END IF;
  IF a.actor_kind='png' AND EXISTS(SELECT 1 FROM mission_generic_owner.unified_round_windows uw WHERE uw.round_id=c.round_id) THEN
     IF NOT (mission_generic_owner.unified_service_staging(c.round_id) OR human_stage)
     THEN RAISE EXCEPTION 'MUF_STAGING_AUTHORITY_REQUIRED' USING ERRCODE='42501'; END IF;
    UPDATE public.combat_v2_declarations d SET controller_user_snapshot=uid
    FROM public.combat_v2_provider_instances_v1 pi
    WHERE d.id=declaration AND d.round_id=c.round_id AND d.actor_id=a.id AND d.request_key=key
       AND (d.state='inviata' OR ((human_stage OR(intent_stage AND d.kind='passa' AND v_master_actor_result#>>'{data,declaration_id}'=d.id::text AND v_master_actor_result#>>'{data,phase}'='risolto' AND v_master_actor_result#>'{data,auto_resolution}' IS NOT NULL AND v_master_actor_result#>'{data,auto_resolution}'<>'null'::jsonb)) AND d.state='risolta'
         AND d.kind IN('utilita','movimento','passa','difesa','nessuna')))
       AND d.declaration_text=coalesce(p->>'narrative_text','')
      AND d.controller_version_snapshot=a.controller_version
      AND pi.id=a.provider_instance_v1_id AND pi.session_id=a.session_id
      AND d.controller_user_snapshot=pi.narrative_version_ref;
    IF NOT FOUND AND NOT EXISTS(SELECT 1 FROM public.combat_v2_declarations d
      WHERE d.id=declaration AND d.round_id=c.round_id AND d.actor_id=a.id AND d.request_key=key
        AND d.state IN ('inviata','risolta') AND d.declaration_text=coalesce(p->>'narrative_text','')
        AND d.controller_version_snapshot=a.controller_version AND d.controller_user_snapshot=uid)
    THEN RAISE EXCEPTION 'MG_DECLARATION_AUTHORITY_INVALID' USING ERRCODE='42501'; END IF;
  END IF;
  -- Solo Passa nativo senza role: l'offerta effettiva è attestata prima del publisher
 -- nella stessa TX. La receipt finale segue normalmente; ogni errore annulla tutto.
 IF a.actor_kind='png' AND NOT o.requires_role AND o.kind='action' AND o.operation='declare'
   AND o.source_payload->>'kind'='passa' AND intent->>'kind'='passa'
    AND nullif(btrim(p->>'narrative_text'),'') IS NULL
    AND EXISTS(SELECT 1 FROM mission_generic_owner.unified_round_windows uw WHERE uw.round_id=c.round_id) THEN
    IF NOT (mission_generic_owner.unified_service_staging(c.round_id) OR human_stage) OR NOT EXISTS(
     SELECT 1 FROM public.combat_v2_declarations pd WHERE pd.id=declaration AND pd.round_id=c.round_id
       AND pd.actor_id=a.id AND pd.request_key=key AND pd.kind='passa'
       AND (pd.state='inviata' OR (pd.state='risolta' AND human_stage
          AND v_master_actor_result#>>'{data,declaration_id}'=pd.id::text
          AND v_master_actor_result#>>'{data,phase}'='risolto'
          AND v_master_actor_result#>'{data,auto_resolution}' IS NOT NULL
          AND v_master_actor_result#>'{data,auto_resolution}'<>'null'::jsonb))
       AND pd.controller_user_snapshot=uid AND pd.controller_version_snapshot=a.controller_version
       AND pd.declaration_text=coalesce(p->>'narrative_text','')) THEN
     RAISE EXCEPTION 'MUF_ROLELESS_PASS_SCOPE' USING ERRCODE='42501'; END IF;
   UPDATE combat_panel_private.offers SET state='consumed',consumed_request_key=key
     WHERE id=o.id AND principal_user=uid AND context_id=c.id AND actor_id=a.id AND state='offered';
   IF NOT FOUND THEN RAISE EXCEPTION 'MUF_ROLELESS_PASS_OFFER' USING ERRCODE='40001'; END IF;
 END IF;
 PERFORM combat_panel_private.publish_master_declaration(declaration,p->>'narrative_text');
 SELECT value->>'display_name' INTO label FROM jsonb_array_elements(env->'actors') WHERE value->>'actor_id'=a.id::text;
 IF cardinality(targets)>0 THEN
   SELECT value->>'display_name' INTO target_label FROM jsonb_array_elements(env->'actors') WHERE value->>'actor_id'=targets[1]::text;
 END IF;
 event:=jsonb_build_object('event_id',receipt_id,'event_kind','action_declared','actor_id',a.id,'display_name',label,
   'label_version',c.context_version,'target_actor_id',CASE WHEN target_label IS NOT NULL THEN targets[1] END,
   'target_display_name',target_label,'target_label_version',CASE WHEN target_label IS NOT NULL THEN c.context_version END,
   'summary',CASE WHEN o.operation='defend' THEN 'Difesa registrata' ELSE 'Azione registrata' END);
 env:=combat_panel_private.master_projection(c.location_id,a.id);
 IF env->>'status'='blocked' AND env->>'reason_code'='REGIA_FATO_PENDING' THEN
  IF a.actor_kind<>'pg' OR o.kind<>'action' OR o.operation<>'declare'
   OR NOT mission_narrative_internal.scene_native_round_bound_v1(
      (SELECT master_session_id FROM public.combat_v2_sessions WHERE id=c.activity_id),c.round_id)
   OR NOT EXISTS(SELECT 1 FROM public.combat_v2_declarations accepted
     JOIN public.combat_v2_rounds rr ON rr.id=accepted.round_id AND rr.session_id=c.activity_id
     JOIN public.combat_v2_round_reports report ON report.id=rr.report_id AND report.round_id=rr.id
     JOIN public.combat_v2_events action_event ON action_event.scope_id=rr.id
      AND action_event.request_key=accepted.request_key AND action_event.operation_kind='combat_v2_action_declare'
     WHERE accepted.id=declaration AND accepted.round_id=c.round_id AND accepted.actor_id=a.id
      AND accepted.kind IN('attacco','utilita','movimento','passa') AND accepted.state='risolta'
      AND accepted.request_key=key AND accepted.controller_user_snapshot=uid
      AND accepted.controller_version_snapshot=a.controller_version
      AND accepted.declaration_text=coalesce(p->>'narrative_text','')
      AND action_event.status='completata' AND action_event.caller=uid
      AND action_event.result=v_master_actor_result AND v_master_actor_result#>>'{data,declaration_id}'=accepted.id::text
      AND v_master_actor_result#>>'{data,phase}'='risolto'
      AND v_master_actor_result#>>'{data,auto_resolution,data,report_id}'=report.id::text
      AND rr.state='risolto' AND report.narration_state='attesa' AND NOT report.values_written
      AND report.mechanics_sha256=public.combat_v2_sha256(report.mechanics))
  THEN RAISE EXCEPTION 'NATIVE_PENDING_ACK_SCOPE' USING ERRCODE='42501';END IF;
  -- A public frame has not been projected. Report the real retained panel
  -- context version, not a synthetic increment or a version from private data.
  SELECT context_version INTO STRICT ack_context_version FROM combat_panel_private.contexts
   WHERE id=c.id AND principal_user=uid AND command_actor_id=a.id
    AND activity_id=c.activity_id AND round_id=c.round_id AND location_id=c.location_id;
  IF ack_context_version<o.context_version THEN RAISE EXCEPTION 'NATIVE_PENDING_ACK_VERSION' USING ERRCODE='40001';END IF;
 ELSE
  ack_context_version:=(env#>>'{context,version}')::bigint;
 END IF;
 receipt:=jsonb_build_object('receipt_id',receipt_id,'request_key',key,'operation',o.operation,'replayed',false,
   'activity_id',c.activity_id,'round_id',c.round_id,'context_version_before',o.context_version,
   'context_version_after',ack_context_version,'declaration_id',declaration,'report_id',NULL,
   'values_written',false,'display_events',jsonb_build_array(event));
 env:=jsonb_set(env,'{receipt}',receipt);
 UPDATE combat_panel_private.offers SET state='consumed',consumed_request_key=key WHERE id=o.id;
 INSERT INTO combat_panel_private.request_receipts(principal_user,request_key,command_fingerprint,offer_id,event_id,viewer_envelope)
   VALUES(uid,key,fp,o.id,receipt_id,env);
 RETURN env;
END $function$
