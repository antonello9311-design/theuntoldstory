CREATE OR REPLACE FUNCTION public.mission_factory_mission_d100_state_v1(p_session uuid, p_view text, p_character uuid)
 RETURNS jsonb
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO ''
AS $function$
DECLARE ms public.master_v2_sessions;rs public.mission_run_state;rb mission_generic_owner.run_bindings;
 ctl mission_factory_owner.c655_control;pb mission_factory_owner.c655_published_bindings;
 br mission_factory_owner.c655_runtime_bindings;rec mission_factory_owner.c655_receipts;
 eventrow public.mission_run_events;pending public.mission_run_events;
 actor uuid;src uuid;chars uuid[];users uuid[];mode_name text;
 is_master boolean:=false;qualified boolean:=false;pending_fato boolean:=false;live_scope boolean:=false;
 visible_step text;visible_cv bigint;scope jsonb:=NULL;items jsonb:='[]';rolls jsonb;offers jsonb;result jsonb;report jsonb;
 role_receipts jsonb:='[]';current_offers jsonb:='[]';normalized jsonb;binding_state text;published_message uuid;guide_done boolean;support_done boolean;can_roll boolean;can_bind boolean;
BEGIN
 IF auth.uid() IS NULL OR p_session IS NULL OR p_view IS NULL OR p_view NOT IN('player','master')
 OR (p_view='player' AND p_character IS NULL) OR (p_view='master' AND p_character IS NOT NULL)
 THEN RAISE EXCEPTION 'MF_D100_STATE_AUTH_INPUT' USING ERRCODE='42501';END IF;
 -- C1236: authenticated negative eligibility only; no data or capability is returned.
 IF EXISTS(
  SELECT 1 FROM public.master_v2_sessions master_probe
  JOIN public.locations location_probe ON location_probe.id=master_probe.location_id
   AND location_probe.is_active AND location_probe.is_test
  JOIN public.mission_run_state run_probe ON run_probe.master_session_id=master_probe.id
   AND run_probe.mission_id=master_probe.mission_id AND run_probe.source_kind='mission'
   AND run_probe.quest_arc_id IS NULL AND run_probe.quest_episode_id IS NULL
  JOIN mission_generic_owner.simulation_sources source_probe ON source_probe.carrier_mission_id=master_probe.mission_id
   AND source_probe.source_mission_id IS NOT NULL
  WHERE master_probe.id=p_session AND master_probe.tipo='quest'
   AND master_probe.location_id='0b85f354-9cdb-47e1-baf9-3d266bb7e06b'::uuid
   AND master_probe.owner_kind IN('human','ai_service')
   AND ((p_view='master' AND master_probe.owner_kind='human'
    AND master_probe.master_user=auth.uid() AND public.master_v2_is_master(auth.uid()))
    OR (p_view='player' AND EXISTS(
     SELECT 1 FROM public.master_v2_participants member_probe
     JOIN public.characters character_probe ON character_probe.id=member_probe.character_id
      AND character_probe.user_id=member_probe.user_id_snapshot
     WHERE member_probe.session_id=p_session AND member_probe.character_id=p_character
      AND member_probe.user_id_snapshot=auth.uid())))
   AND NOT EXISTS(
    SELECT 1 FROM mission_factory_owner.c655_published_bindings pair_probe
    WHERE pair_probe.mission_id=master_probe.mission_id
     AND pair_probe.lineage_source=source_probe.source_mission_id
     AND run_probe.plan_version_id=CASE WHEN master_probe.owner_kind='human' THEN pair_probe.human_plan_id ELSE pair_probe.ai_plan_id END
     AND run_probe.plan_sha256=CASE WHEN master_probe.owner_kind='human' THEN pair_probe.human_plan_sha256 ELSE pair_probe.ai_plan_sha256 END)
 ) THEN RAISE EXCEPTION 'MF_D100_STATE_PAIR_REQUIRED' USING ERRCODE='PT409';END IF;
 SELECT * INTO STRICT ms FROM public.master_v2_sessions WHERE id=p_session FOR UPDATE;
 IF p_view='player' THEN
  SELECT mp.character_id INTO actor FROM public.master_v2_participants mp
  JOIN public.characters pc ON pc.id=mp.character_id AND pc.user_id=mp.user_id_snapshot
  WHERE mp.session_id=p_session AND mp.character_id=p_character AND mp.user_id_snapshot=auth.uid();
  IF actor IS NULL THEN RAISE EXCEPTION 'MF_D100_STATE_PLAYER_FORBIDDEN' USING ERRCODE='42501';END IF;
 ELSE
  is_master:=ms.owner_kind='human' AND ms.master_user=auth.uid()
    AND public.master_v2_is_master(auth.uid()) AND mission_creation_owner.is_human(p_session);
  IF NOT is_master THEN RAISE EXCEPTION 'MF_D100_STATE_MASTER_FORBIDDEN' USING ERRCODE='42501';END IF;
 END IF;
 SELECT * INTO STRICT rs FROM public.mission_run_state WHERE master_session_id=p_session FOR UPDATE;
 SELECT * INTO STRICT rb FROM mission_generic_owner.run_bindings WHERE master_session_id=p_session;
 SELECT * INTO STRICT ctl FROM mission_factory_owner.c655_control WHERE singleton;
 SELECT ss.source_mission_id INTO src FROM mission_generic_owner.simulation_sources ss WHERE ss.carrier_mission_id=ms.mission_id;
 SELECT array_agg(mp.character_id ORDER BY mp.character_id),array_agg(mp.user_id_snapshot ORDER BY mp.character_id)
 INTO chars,users FROM public.master_v2_participants mp JOIN public.characters pc ON pc.id=mp.character_id AND pc.user_id=mp.user_id_snapshot
 WHERE mp.session_id=p_session AND mp.left_at IS NULL AND mp.engagement_state='attivo';
 mode_name:=CASE WHEN ms.owner_kind='human' AND mission_creation_owner.is_human(ms.id) THEN 'human' WHEN ms.owner_kind='ai_service' THEN 'ai' ELSE NULL END;
 IF mode_name IS NULL OR src IS NULL OR ms.location_id<>'0b85f354-9cdb-47e1-baf9-3d266bb7e06b'::uuid
 OR NOT EXISTS(SELECT 1 FROM public.locations l WHERE l.id=ms.location_id AND l.is_active AND l.is_test)
 OR rs.source_kind IS DISTINCT FROM 'mission' OR rs.quest_arc_id IS NOT NULL OR rs.quest_episode_id IS NOT NULL
 OR rs.mission_id IS DISTINCT FROM ms.mission_id OR rb.snapshot_sha256 IS DISTINCT FROM mission_internal.fingerprint(rb.snapshot)
 OR rs.plan_version_id::text IS DISTINCT FROM rb.snapshot->>'plan_version_id'
 OR rs.plan_sha256 IS DISTINCT FROM rb.snapshot->>'plan_sha256'
 OR mission_internal.plan_fingerprint(rs.plan_version_id) IS DISTINCT FROM rs.plan_sha256
 THEN RAISE EXCEPTION 'MF_D100_STATE_NATIVE_SCOPE' USING ERRCODE='42501';END IF;
 IF NOT EXISTS(SELECT 1 FROM mission_factory_owner.c655_published_bindings b WHERE b.mission_id=ms.mission_id AND b.lineage_source=src
  AND rs.plan_version_id=CASE WHEN mode_name='human' THEN b.human_plan_id ELSE b.ai_plan_id END
  AND rs.plan_sha256=CASE WHEN mode_name='human' THEN b.human_plan_sha256 ELSE b.ai_plan_sha256 END)
 THEN RAISE EXCEPTION 'MF_D100_STATE_PAIR_REQUIRED' USING ERRCODE='PT409';END IF;
 SELECT ev.* INTO pending FROM public.mission_run_outbox ob JOIN public.mission_run_events ev ON ev.id=ob.event_id AND ev.master_session_id=ob.master_session_id
 WHERE ob.master_session_id=p_session AND ob.state IS DISTINCT FROM 'published'
 ORDER BY ob.event_version_after,ob.event_id LIMIT 1;
 IF pending.id IS NOT NULL AND pending.status IS DISTINCT FROM 'committed' THEN RAISE EXCEPTION 'MF_D100_STATE_OUTBOX_DRIFT' USING ERRCODE='PT409';END IF;
 pending_fato:=pending.id IS NOT NULL;
 visible_step:=CASE WHEN p_view='player' AND pending_fato THEN pending.step_before ELSE rs.current_step_key END;
 visible_cv:=CASE WHEN p_view='player' AND pending_fato THEN pending.version_before ELSE rs.control_version END;
 qualified:=mission_factory_owner.c666_projection_ready_v1() IS TRUE;
 live_scope:=qualified AND ctl.enabled AND ctl.expires_at>statement_timestamp()
  AND ms.closed_at IS NULL AND ms.suspended_at IS NULL AND ms.stato='in_corso' AND rs.run_phase='in_corso'
  AND NOT pending_fato AND chars IS NOT NULL AND cardinality(chars) BETWEEN 1 AND 4;
 IF live_scope AND EXISTS(SELECT 1 FROM mission_factory_owner.c655_published_bindings b WHERE b.mission_id=ms.mission_id AND b.step_key=rs.current_step_key) THEN
  SELECT * INTO STRICT pb FROM mission_factory_owner.c655_published_bindings b WHERE b.mission_id=ms.mission_id AND b.step_key=rs.current_step_key;
  normalized:=mission_factory_owner.c655_binding_v1(jsonb_build_object('policy_mission_id',pb.binding->'policy_mission_id','policy_step_key',pb.binding->'policy_step_key'),pb.binding->>'success_transition_key',pb.binding->>'complication_transition_key');
  IF normalized IS DISTINCT FROM pb.binding THEN RAISE EXCEPTION 'MF_D100_STATE_POLICY_DRIFT' USING ERRCODE='PT409';END IF;
  scope:=public.mission_factory_mission_d100_scope_v1(p_session);
  IF p_view='player' AND mode_name='human' THEN
   scope:=scope||jsonb_build_object('can_bind',false,'reason_code','role_assignment_master_only');
  END IF;
 END IF;
 IF scope IS NOT NULL THEN
  SELECT coalesce(jsonb_agg(jsonb_build_object('character_id',ro.character_id,'role',role_name.role,
    'can_select',coalesce((scope->>'can_bind')::boolean,false) AND (p_view='master' OR (mode_name='ai' AND ro.character_id=actor))
      AND CASE role_name.role WHEN 'guide' THEN (scope->>'guide_character_id' IS NULL OR scope->>'guide_character_id'=ro.character_id::text)
        AND scope->>'support_character_id' IS DISTINCT FROM ro.character_id::text
      ELSE (scope->>'support_character_id' IS NULL OR scope->>'support_character_id'=ro.character_id::text)
        AND scope->>'guide_character_id' IS DISTINCT FROM ro.character_id::text END)
    ORDER BY ro.character_id,role_name.role),'[]') INTO current_offers
   FROM unnest(chars) ro(character_id) CROSS JOIN unnest(ARRAY['guide','support']) role_name(role)
   WHERE (p_view='master' OR ro.character_id=actor) AND (role_name.role='guide' OR cardinality(chars)>1);
 END IF;
 FOR br IN SELECT * FROM mission_factory_owner.c655_runtime_bindings b WHERE b.session_id=p_session ORDER BY b.run_cv,b.step_key,b.id LOOP
  IF p_view='player' AND NOT(p_character=ANY(br.roster)) THEN CONTINUE;END IF;
  SELECT * INTO STRICT pb FROM mission_factory_owner.c655_published_bindings b WHERE b.mission_id=br.mission_id AND b.step_key=br.step_key;
  IF br.mission_id IS DISTINCT FROM ms.mission_id OR pb.lineage_source IS DISTINCT FROM src
   OR br.plan_id IS DISTINCT FROM rs.plan_version_id OR br.snapshot_sha256 IS DISTINCT FROM rb.snapshot_sha256
   OR br.published_phase_sha256 IS DISTINCT FROM pb.phase_sha256
   OR cardinality(br.roster) NOT BETWEEN 1 AND 4
   OR NOT EXISTS(SELECT 1 FROM mission_factory_owner.drafts df WHERE df.id=pb.draft_id AND df.control_version=pb.draft_cv
     AND df.document_sha256=pb.source_document_sha256 AND mission_factory_owner.sha(df.document)=pb.source_document_sha256)
   OR EXISTS(SELECT 1 FROM unnest(br.roster) ro(character_id) WHERE NOT EXISTS(SELECT 1 FROM public.master_v2_participants mp
     JOIN public.characters pc ON pc.id=mp.character_id AND pc.user_id=mp.user_id_snapshot WHERE mp.session_id=p_session AND mp.character_id=ro.character_id))
  THEN RAISE EXCEPTION 'MF_D100_STATE_BINDING_DRIFT' USING ERRCODE='PT409';END IF;
  SELECT * INTO rec FROM mission_factory_owner.c655_receipts WHERE binding_id=br.id;
  SELECT coalesce(jsonb_agg(jsonb_build_object('character_id',rr.character_id,'role',rr.role,'message_id',rr.message_id,'result',rr.result)
    ORDER BY rr.role,rr.character_id),'[]') INTO rolls
   FROM mission_factory_owner.c655_rolls rr JOIN public.messages msg ON msg.id=rr.message_id
   JOIN public.master_v2_participants mp ON mp.session_id=p_session AND mp.character_id=rr.character_id
   WHERE rr.binding_id=br.id AND msg.location_id=ms.location_id AND msg.kind='roll' AND msg.dice_sides=100
    AND msg.dice_result=rr.result AND msg.character_id=rr.character_id AND msg.sender_user=mp.user_id_snapshot AND msg.recipient_user IS NULL;
  IF jsonb_array_length(rolls)<>(SELECT count(*) FROM mission_factory_owner.c655_rolls rr WHERE rr.binding_id=br.id)
  THEN RAISE EXCEPTION 'MF_D100_STATE_ROLL_DRIFT' USING ERRCODE='PT409';END IF;
  guide_done:=EXISTS(SELECT 1 FROM mission_factory_owner.c655_rolls rr WHERE rr.binding_id=br.id AND rr.role='guide');
  support_done:=br.support_id IS NULL OR EXISTS(SELECT 1 FROM mission_factory_owner.c655_rolls rr WHERE rr.binding_id=br.id AND rr.role='support');
  published_message:=NULL;eventrow:=NULL;result:=NULL;report:=NULL;
  IF rec.binding_id IS NOT NULL THEN
   IF mission_factory_owner.sha(rec.facts) IS DISTINCT FROM rec.facts_sha256
    OR rec.result->>'source_sha256' IS DISTINCT FROM rec.facts_sha256
    OR rec.result->>'binding_id' IS DISTINCT FROM br.id::text OR rec.result->>'state' IS DISTINCT FROM 'resolved'
   THEN RAISE EXCEPTION 'MF_D100_STATE_RECEIPT_DRIFT' USING ERRCODE='PT409';END IF;
   SELECT * INTO STRICT eventrow FROM public.mission_run_events ev
    WHERE ev.id=(rec.result#>>'{transition,event_id}')::uuid AND ev.master_session_id=p_session AND ev.status='committed'
     AND ev.operation_kind='transition' AND ev.plan_version_id=br.plan_id AND ev.step_before=br.step_key
     AND ev.version_before=br.run_cv AND ev.request_key_sha256=mission_internal.request_key_sha256(rec.request_key);
   SELECT msg.id INTO published_message FROM public.mission_run_outbox ob
    JOIN public.mission_run_publications pub ON pub.id=ob.publication_id AND pub.event_id=ob.event_id AND pub.master_session_id=ob.master_session_id AND pub.status='committed'
    JOIN public.mission_run_messages rm ON rm.publication_id=pub.id AND rm.body_sha256=pub.body_sha256
    JOIN public.messages msg ON msg.id=rm.message_id AND msg.location_id=ms.location_id AND msg.kind='fato' AND msg.character_id IS NULL AND msg.recipient_user IS NULL
    WHERE ob.event_id=eventrow.id AND ob.master_session_id=p_session AND ob.state='published' AND ob.published_at IS NOT NULL
     AND ob.event_version_after=eventrow.version_after AND ob.step_key=eventrow.step_after AND ob.context_fingerprint=eventrow.context_fingerprint;
   IF p_view='master' OR published_message IS NOT NULL THEN
    result:=jsonb_build_object('schema_version','mission-d100-visible-receipt/1','binding_id',br.id,'event_id',eventrow.id,
     'request_key',rec.request_key,'facts_sha256',rec.facts_sha256,'success',(rec.result->>'success')::boolean,
     'next_step_key',eventrow.step_after,'run_control_version',eventrow.version_after,'fato_message_id',published_message);
   END IF;
   IF p_view='master' THEN
    report:=jsonb_build_object('schema_version','mission-d100-master-report/1','binding_id',br.id,
     'guide_result',rec.facts->'guide_result','support_result',rec.facts->'support_result',
     'base_threshold',rec.facts->'base_threshold','support_threshold',rec.facts->'support_threshold',
     'effective_threshold',rec.facts->'effective_threshold','success',rec.facts->'success');
   END IF;
  END IF;
  binding_state:=CASE WHEN rec.binding_id IS NOT NULL AND published_message IS NOT NULL THEN 'resolved'
    WHEN rec.binding_id IS NOT NULL THEN 'awaiting_fato'
    WHEN br.guide_id IS NULL OR (cardinality(br.roster)>1 AND br.support_id IS NULL) THEN 'waiting_role_assignment'
    ELSE 'waiting_native_roles' END;
  can_bind:=live_scope AND br.step_key=rs.current_step_key AND br.run_cv=rs.control_version
    AND jsonb_array_length(rolls)=0 AND coalesce((scope->>'can_bind')::boolean,false);
  can_roll:=live_scope AND br.step_key=rs.current_step_key AND br.run_cv=rs.control_version
    AND br.master_cv=ms.control_version AND p_view='player' AND actor=ANY(chars)
    AND br.guide_id IS NOT NULL AND (cardinality(br.roster)=1 OR br.support_id IS NOT NULL)
    AND actor IN(br.guide_id,br.support_id) AND NOT EXISTS(SELECT 1 FROM mission_factory_owner.c655_rolls rr WHERE rr.binding_id=br.id AND rr.character_id=actor);
  SELECT coalesce(jsonb_agg(jsonb_build_object('character_id',ro.character_id,'role',role_name.role,
    'can_select',can_bind AND (p_view='master' OR (mode_name='ai' AND ro.character_id=actor))
      AND CASE role_name.role WHEN 'guide' THEN (br.guide_id IS NULL OR br.guide_id=ro.character_id) AND br.support_id IS DISTINCT FROM ro.character_id ELSE (br.support_id IS NULL OR br.support_id=ro.character_id) AND br.guide_id IS DISTINCT FROM ro.character_id END)
    ORDER BY ro.character_id,role_name.role),'[]') INTO offers
   FROM unnest(br.roster) ro(character_id) CROSS JOIN unnest(ARRAY['guide','support']) role_name(role)
   WHERE (p_view='master' OR ro.character_id=actor) AND (role_name.role='guide' OR cardinality(br.roster)>1);
  items:=items||jsonb_build_array(jsonb_build_object('binding_id',br.id,'step_key',br.step_key,'run_control_version',br.run_cv,
    'native_policy_sha256',pb.binding->>'native_policy_sha256','guide_character_id',br.guide_id,'support_character_id',br.support_id,
    'progress',jsonb_build_object('state',binding_state,'guide_complete',guide_done,'support_required',cardinality(br.roster)>1,
      'support_complete',support_done,'can_roll',coalesce(can_roll,false),'can_bind',coalesce(can_bind,false),
      'role_assignment_frozen',jsonb_array_length(rolls)>0,'fato_pending',rec.binding_id IS NOT NULL AND published_message IS NULL),
    'role_offers',offers,'rolls',rolls,'receipt',result,'master_report',report));
 END LOOP;
 IF p_view='master' OR mode_name='ai' THEN
  SELECT coalesce(jsonb_agg(jsonb_build_object('request_key',req.request_key,'binding_id',req.binding_id,'receipt',req.receipt)
    ORDER BY binding.run_cv,req.request_key),'[]') INTO role_receipts
   FROM mission_factory_owner.c655_role_requests req JOIN mission_factory_owner.c655_runtime_bindings binding ON binding.id=req.binding_id
   WHERE binding.session_id=p_session AND req.principal_id=auth.uid()
    AND (p_view='master' OR actor=ANY(binding.roster));
 END IF;
 RETURN jsonb_build_object('schema_version','mission-d100-runtime-state/1','master_session_id',p_session,'viewer_mode',p_view,
  'viewer_character_id',actor,'direction_mode',mode_name,'location_id',ms.location_id,'visible_step_key',visible_step,
  'visible_run_control_version',visible_cv,'interaction_state',CASE WHEN pending_fato THEN 'fato_pending' WHEN live_scope THEN 'active' ELSE 'read_only' END,
  'role_scope',scope,'role_offers',current_offers,'role_receipts',role_receipts,'bindings',items,'reason_code',CASE WHEN pending_fato THEN 'MF_D100_FATO_PENDING' WHEN NOT live_scope THEN 'MF_D100_READ_ONLY' ELSE NULL END);
END $function$
