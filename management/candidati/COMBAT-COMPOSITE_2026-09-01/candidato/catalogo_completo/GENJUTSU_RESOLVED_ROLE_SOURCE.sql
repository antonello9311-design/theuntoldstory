BEGIN;
DO $role_pre$
DECLARE rr mission_factory_owner.editor_release_readiness%ROWTYPE;p jsonb;f jsonb;
BEGIN
 IF current_user<>'postgres' OR session_user<>'postgres' OR auth.uid() IS NOT NULL THEN RAISE EXCEPTION 'GENJUTSU_ROLE_OPERATOR_REQUIRED';END IF;
 IF NOT pg_try_advisory_xact_lock(hashtextextended('C1266:GENERIC-AI:AVAILABILITY',0)) THEN RAISE EXCEPTION 'GENJUTSU_ROLE_AVAILABILITY_BUSY';END IF;
 PERFORM set_config('app.cure_reaction_paralisi_gate_before',(SELECT to_jsonb(g)::text FROM combat_v2_genjutsu_internal.gate g WHERE singleton),true);
 PERFORM set_config('app.cure_reaction_cure_gate_before',(SELECT to_jsonb(g)::text FROM combat_panel_private.cure_gate_v1 g WHERE singleton),true);
 p:=nullif(current_setting('app.genjutsu_resolved_role_parameters',true),'')::jsonb;
 SELECT * INTO STRICT rr FROM mission_factory_owner.editor_release_readiness WHERE singleton FOR UPDATE NOWAIT;
 IF p->>'mode' IS DISTINCT FROM 'source' OR rr.revision_sha256 IS DISTINCT FROM '9e0cea20b1f19680794da220b5636cd17e302ad8f84df7d9b50ae3dc4f81f50c'
 OR public.combat_v2_sha256(to_jsonb(rr)) IS DISTINCT FROM '7192592b48a491f455863dbd62b1ed75397e1af728ab1db10fbbc61f9f971ebe' THEN RAISE EXCEPTION 'GENJUTSU_ROLE_BASELINE_DRIFT';END IF;
 IF EXISTS(SELECT 1 FROM public.combat_v2_sessions WHERE closed_at IS NULL AND state IN('preparazione','in_corso','sospeso'))
 OR EXISTS(SELECT 1 FROM public.master_v2_sessions WHERE closed_at IS NULL AND suspended_at IS NULL) THEN RAISE EXCEPTION 'GENJUTSU_ROLE_REQUIRES_QUIESCENCE';END IF;
 FOR f IN SELECT value FROM jsonb_array_elements($role_pins$[{"signature":"clan_innata_private.eligibility_release_assert()","source_md5":"ef199a674937b3bc4f9dbd49f35bf9b2","ddl_sha256":"680a47c514ab2255937d259a2fb0ecc8fd1b098670089d595b531839a23e33f9"},{"signature":"clan_innata_private.catalogo_eligibility_release_v1()","source_md5":"e52a8ac90fb15cad425cd0d17c9b4d4b","ddl_sha256":"72141f00f7b6c79aacf634334290e92debbcc3a5bd77365c55dc4ef3a82ea5f6"},{"signature":"clan_innata_private.runtime_release_assert()","source_md5":"6b9ed7edc3ea365017e1f5e84200ed79","ddl_sha256":"220301a349fe8d8d59717f82f84b9b5785c21acf0e8bd965682be6f85e513a38"},{"signature":"combat_panel_private.cure_contact_v1(uuid,uuid)","source_md5":"21de7dd5e62b5403b50065d2635e20bf","ddl_sha256":"0d5ef7dfd803fadfc2ec38aa4285467cd95f83bb613e6c0b6a0dde650d571f00"},{"signature":"combat_panel_private.master_projection(uuid,uuid)","source_md5":"271ea56acb5f135ad6e3d24d8601e3b1","ddl_sha256":"da26a20b86b168b4769b851405794371ddbe54095c1e8c775859c0b1c155cd0b"},{"signature":"combat_panel_private.round_options_authoritative(uuid,uuid)","source_md5":"7cf9d8be18c9dab5f75b62c74a5e9e37","ddl_sha256":"22bd8c8faf60ba44a644bf9ccd0f69ab8a5715383c79ff6014509dfd02290554"},{"signature":"combat_v2_elemental_internal.other_ability_meta(uuid,jsonb)","source_md5":"aa3d6fe2cb785a3a132a7b281bdab70a","ddl_sha256":"15fab8ec94575b4a0e163cfbdcc46272b02d47d772daa262de5483a43b18f5ac"},{"signature":"combat_panel_private.publish_master_declaration(uuid,text)","source_md5":"5bc0eeaea3b3b64578105067b4b40c28","ddl_sha256":"377cb7bcbc4d5ec3fb1c7fd49e2fa59552e5f2ba55dc4435b5eb21bbd4590c6b"}]$role_pins$::jsonb) LOOP
  IF md5((SELECT prosrc FROM pg_proc WHERE oid=to_regprocedure(f->>'signature'))) IS DISTINCT FROM f->>'source_md5'
   OR encode(extensions.digest(convert_to(pg_get_functiondef(to_regprocedure(f->>'signature')),'UTF8'),'sha256'),'hex') IS DISTINCT FROM f->>'ddl_sha256'
  THEN RAISE EXCEPTION 'GENJUTSU_ROLE_BODY_DRIFT:%',f->>'signature';END IF;
 END LOOP;
END $role_pre$;
CREATE OR REPLACE FUNCTION combat_panel_private.publish_master_declaration(p_declaration uuid, p_text text)
 RETURNS uuid
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO ''
AS $function$
DECLARE a public.combat_v2_actors%ROWTYPE; d public.combat_v2_declarations%ROWTYPE;
  location uuid; v_message_id uuid; guided_before text;
  human_window boolean:=false; human_stage boolean:=false; human_pg_resolved boolean:=false; native_private boolean:=false; native_pg_resolved boolean:=false; human_png_pass_resolved boolean:=false; human_genjutsu_resolved boolean:=false;
BEGIN
 SELECT * INTO STRICT d FROM public.combat_v2_declarations WHERE id=p_declaration FOR UPDATE;
  SELECT a0.* INTO a FROM public.combat_v2_actors a0
    JOIN public.combat_v2_rounds r ON r.id=d.round_id AND r.session_id=a0.session_id
    JOIN public.combat_v2_sessions s ON s.id=r.session_id AND s.source_kind='master'
    WHERE a0.id=d.actor_id AND exam_regia_private.actor_principal(a0.id,a0.controller_user)=exam_regia_private.current_principal() AND a0.companion_id IS NULL;
  SELECT EXISTS(SELECT 1 FROM mission_generic_owner.regia_human_windows_v1 hw
    WHERE hw.next_round_id=d.round_id AND hw.state IN('private','published')) INTO human_window;
  IF a.actor_kind='png' AND human_window THEN
    SELECT EXISTS(SELECT 1
      FROM mission_generic_owner.regia_human_stage_permits_v1 hp
      JOIN mission_generic_owner.regia_human_windows_v1 hw
        ON hw.next_round_id=hp.round_id AND hw.master_session_id=hp.master_session_id
      JOIN mission_generic_owner.unified_round_windows uw
        ON uw.round_id=hp.round_id AND uw.batch_id=hw.batch_id
         AND uw.master_session_id=hw.master_session_id
      JOIN public.combat_v2_sessions cs ON cs.id=a.session_id
         AND cs.master_session_id=hw.master_session_id
      JOIN public.master_v2_sessions ms ON ms.id=hw.master_session_id
      WHERE hp.round_id=d.round_id AND hp.actor_id=d.actor_id
        AND hp.request_key=d.request_key AND hp.principal_id=auth.uid()
        AND hp.transaction_id=txid_current() AND hp.backend_pid=pg_backend_pid()
        AND hw.encounter_id=cs.id AND ms.owner_kind='human'
        AND ms.closed_at IS NULL AND ms.master_user=auth.uid()
        AND ms.location_id='0b85f354-9cdb-47e1-baf9-3d266bb7e06b'::uuid
        AND d.controller_user_snapshot=hp.principal_id
        AND d.controller_version_snapshot=a.controller_version
        AND ((hw.state='private' AND hw.side='png' AND uw.side='png'
              AND uw.publication_id IS NULL AND d.actor_id=ANY(uw.expected_actor_ids)
              AND d.kind IN('attacco','movimento','utilita','passa'))
          OR (hw.state='published' AND hw.side='pg' AND uw.side='pg'
              AND uw.publication_id IS NOT NULL AND d.kind IN('difesa','nessuna'))))
      INTO human_stage;
  END IF;
  -- PG Human needs no Master permit. A resolved non-offensive declaration is
  -- accepted only when the published PG window and completed native action
  -- receipt identify this same actor, request, text and controller version.
   IF a.actor_kind='pg' AND d.state='risolta'
     AND d.kind IN ('utilita','movimento','passa')
     AND nullif(btrim(d.declaration_text),'') IS NOT NULL THEN
     SELECT EXISTS(SELECT 1
       FROM mission_generic_owner.regia_human_windows_v1 hw
       JOIN mission_generic_owner.unified_round_windows uw
         ON uw.round_id=hw.next_round_id AND uw.batch_id=hw.batch_id
           AND uw.master_session_id=hw.master_session_id
       JOIN public.combat_v2_sessions cs ON cs.id=hw.encounter_id
         AND cs.master_session_id=hw.master_session_id
       JOIN public.master_v2_sessions ms ON ms.id=hw.master_session_id
       JOIN public.locations loc ON loc.id=ms.location_id
       JOIN public.combat_v2_events ev ON ev.scope_id=d.round_id
         AND ev.request_key=d.request_key AND ev.operation_kind='combat_v2_action_declare'
       WHERE hw.next_round_id=d.round_id AND hw.state='published' AND hw.side='pg'
         AND hw.encounter_id=a.session_id AND uw.side='pg'
         AND uw.publication_id IS NOT NULL AND d.actor_id=ANY(uw.expected_actor_ids)
         AND ms.owner_kind='human' AND ms.closed_at IS NULL AND ms.stato='in_corso'
         AND ms.location_id='0b85f354-9cdb-47e1-baf9-3d266bb7e06b'::uuid
         AND loc.is_active AND loc.is_test
         AND ev.status='completata' AND ev.caller=auth.uid()
         AND ev.result#>>'{data,declaration_id}'=d.id::text
         AND ev.result#>>'{data,phase}'='risolto'
         AND ev.result#>'{data,auto_resolution}' IS NOT NULL
         AND ev.result#>'{data,auto_resolution}'<>'null'::jsonb)
       INTO human_pg_resolved;
   END IF;
  -- A Native PG main may already be resolved by action_declare in this same
  -- transaction. Admit only its exact completed event and protected report.
  IF a.actor_kind='pg' AND d.state='risolta' AND d.kind IN('attacco','utilita','movimento','passa')
   AND auth.uid() IS NOT NULL AND nullif(btrim(d.declaration_text),'') IS NOT NULL
   AND mission_narrative_internal.scene_native_round_bound_v1(
    (SELECT master_session_id FROM public.combat_v2_sessions WHERE id=a.session_id),d.round_id)
  THEN
   SELECT EXISTS(SELECT 1 FROM public.combat_v2_events accepted
    JOIN public.combat_v2_rounds rr ON rr.id=d.round_id AND rr.session_id=a.session_id
    JOIN public.combat_v2_round_reports report ON report.id=rr.report_id AND report.round_id=rr.id
    WHERE accepted.scope_id=d.round_id AND accepted.request_key=d.request_key
     AND accepted.operation_kind='combat_v2_action_declare' AND accepted.status='completata'
     AND accepted.caller=auth.uid() AND accepted.caller=d.controller_user_snapshot
     AND accepted.result#>>'{data,declaration_id}'=d.id::text AND accepted.result#>>'{data,phase}'='risolto'
     AND accepted.result#>>'{data,auto_resolution,data,report_id}'=report.id::text
     AND rr.state='risolto' AND rr.resolved_at IS NOT NULL AND report.narration_state='attesa'
     AND NOT report.values_written AND report.mechanics_sha256=public.combat_v2_sha256(report.mechanics))
   INTO native_pg_resolved;
  END IF;
  -- Roleless human-Master PNG Passa may auto-resolve the complete round before
  -- this publisher. Admit only the exact completed native event, with Cure's
  -- existing Staff/public scopes; no mission, exam or service staging extension.
  IF a.actor_kind='png' AND d.state='risolta' AND d.kind='passa'
   AND d.declaration_text='' AND coalesce(p_text,'')=''
   AND auth.uid() IS NOT NULL AND a.controller_user=auth.uid() THEN
   SELECT EXISTS(SELECT 1 FROM public.combat_v2_events accepted
    JOIN public.combat_v2_rounds rr ON rr.id=d.round_id AND rr.session_id=a.session_id
    JOIN public.combat_v2_sessions ss ON ss.id=rr.session_id
    JOIN public.master_v2_sessions ms ON ms.id=ss.master_session_id
    JOIN public.combat_v2_round_reports report ON report.id=rr.report_id AND report.round_id=rr.id
    WHERE ss.source_kind='master' AND ss.state='in_corso' AND ss.closed_at IS NULL
     AND ms.owner_kind='human' AND ms.tipo='duello' AND ms.master_user=auth.uid()
     AND ms.mission_id IS NULL AND ms.closed_at IS NULL AND ms.suspended_at IS NULL
     AND accepted.scope_id=d.round_id AND accepted.request_key=d.request_key
     AND accepted.operation_kind='combat_v2_action_declare' AND accepted.status='completata'
     AND accepted.caller=auth.uid() AND accepted.caller=d.controller_user_snapshot
     AND accepted.result#>>'{data,declaration_id}'=d.id::text AND accepted.result#>>'{data,phase}'='risolto'
     AND accepted.result#>>'{data,auto_resolution,data,report_id}'=report.id::text
     AND rr.state='risolto' AND rr.resolved_at IS NOT NULL AND report.narration_state='attesa'
     AND report.values_written IS NOT DISTINCT FROM public.combat_v2_values_written(ss.id)
     AND report.mechanics_sha256=public.combat_v2_sha256(report.mechanics)
     AND EXISTS(SELECT 1 FROM public.combat_v2_actors scoped_pg
       WHERE scoped_pg.session_id=ss.id AND scoped_pg.actor_kind='pg'
        AND(scoped_pg.companion_id IS NULL)
        AND(combat_panel_private.cure_staff_scope_v1(scoped_pg.id)
         OR combat_panel_private.cure_persistent_scope_v1(scoped_pg.id)))
     AND NOT EXISTS(SELECT 1 FROM mission_generic_owner.unified_round_windows uw WHERE uw.round_id=rr.id)
     AND NOT EXISTS(SELECT 1 FROM exam_regia_private.bindings eb WHERE eb.combat_session_id=ss.id))
   INTO human_png_pass_resolved;
  END IF;
  -- A protected Human duel may resolve a native release main immediately.
  -- Accept its role only from this transaction's frozen release plan and the
  -- exact completed action event/report. No arbitrary resolved PG action.
  IF a.actor_kind='pg' AND d.state='risolta' AND d.kind='utilita'
   AND auth.uid() IS NOT NULL AND a.controller_user=auth.uid()
   AND nullif(btrim(d.declaration_text),'') IS NOT NULL
   AND d.sanitized_intent#>>'{server_ability,genjutsu_release_version}'='paralisi-release/1'
  THEN
   SELECT EXISTS(SELECT 1
    FROM public.combat_v2_rounds rr
    JOIN public.combat_v2_sessions ss ON ss.id=rr.session_id
    JOIN public.master_v2_sessions ms ON ms.id=ss.master_session_id
    JOIN public.locations loc ON loc.id=ss.location_id
    JOIN public.combat_v2_events accepted ON accepted.scope_id=rr.id
    JOIN public.combat_v2_round_reports report ON report.id=rr.report_id AND report.round_id=rr.id
    JOIN combat_v2_genjutsu_internal.release_plans rp ON rp.declaration_id=d.id
    WHERE rr.id=d.round_id AND rr.session_id=a.session_id
     AND ss.source_kind='master' AND ss.state='in_corso' AND ss.closed_at IS NULL
     AND ms.owner_kind='human' AND ms.tipo='duello' AND ms.stato='in_corso'
     AND ms.closed_at IS NULL AND ms.suspended_at IS NULL AND ms.mission_id IS NULL
     AND ms.quest_kind IS NULL AND ss.location_id=ms.location_id
     AND loc.id='0b85f354-9cdb-47e1-baf9-3d266bb7e06b'::uuid AND loc.is_active AND loc.is_test
     AND combat_panel_private.human_duel_round(rr.id)
     AND combat_panel_private.uses_simulated_pools(ss.id)
     AND public.combat_v2_values_written(ss.id) IS FALSE
     AND combat_v2_genjutsu_internal.runtime_allowed(a.id)
     AND NOT EXISTS(SELECT 1 FROM mission_generic_owner.unified_round_windows uw WHERE uw.round_id=rr.id)
     AND NOT EXISTS(SELECT 1 FROM exam_regia_private.bindings eb WHERE eb.combat_session_id=ss.id)
     AND accepted.request_key=d.request_key AND accepted.operation_kind='combat_v2_action_declare'
     AND accepted.status='completata' AND accepted.caller=auth.uid()
     AND accepted.caller=d.controller_user_snapshot
     AND accepted.result#>>'{data,declaration_id}'=d.id::text
     AND accepted.result#>>'{data,phase}'='risolto'
     AND accepted.result#>>'{data,auto_resolution,data,report_id}'=report.id::text
     AND rr.state='risolto' AND rr.resolved_at IS NOT NULL AND report.narration_state='attesa'
     AND report.values_written IS FALSE AND report.mechanics_sha256=public.combat_v2_sha256(report.mechanics)
     AND rp.actor_id=a.id AND rp.round_id=rr.id AND rp.request_id=d.request_key
     AND rp.transaction_id=txid_current()
     AND rp.source_sha256=public.combat_v2_sha256(rp.source)
     AND rp.result IS NOT NULL AND rp.result_sha256=public.combat_v2_sha256(rp.result)
     AND rp.source->'intent'=d.sanitized_intent-'server_ability'
     AND rp.source->'meta'=d.sanitized_intent->'server_ability'
     AND rp.source->>'principal'=auth.uid()::text
     AND rp.source->>'controller_version'=a.controller_version::text
     AND d.controller_version_snapshot=a.controller_version
     AND d.cost_snapshot->'chakra'='0'::jsonb
     AND d.declaration_text=coalesce(p_text,''))
    INTO human_genjutsu_resolved;
  END IF;
  -- Native PNG defences remain private until the complete round Fato.
  -- This publisher runs before the final choice/request receipts exist: bind the
  -- live transaction permit; combat_narrative_source later verifies the completed receipts.
  IF a.actor_kind='png' AND d.kind IN('difesa','nessuna','attacco','movimento','utilita','passa')
   AND mission_narrative_internal.scene_native_round_bound_v1(
     (SELECT master_session_id FROM public.combat_v2_sessions WHERE id=a.session_id),d.round_id)
  THEN
   IF auth.uid() IS NOT NULL OR NOT public.combat_v2_is_service() OR NOT EXISTS(
    SELECT 1 FROM mission_generic_owner.panel_permits pp
    JOIN mission_generic_owner.panel_choices pc ON pc.work_id=pp.work_id
      AND pc.master_session_id=pp.master_session_id AND pc.encounter_id=pp.encounter_id
      AND pc.actor_id=pp.actor_id AND pc.principal_id=pp.principal_id AND pc.request_key=pp.request_key
    JOIN mission_generic_owner.work_items wi ON wi.id=pc.work_id
      AND wi.master_session_id=pc.master_session_id AND wi.encounter_id=pc.encounter_id
    WHERE pp.encounter_id=a.session_id AND pp.actor_id=a.id AND pp.request_key=d.request_key
      AND pp.principal_id=exam_regia_private.current_principal()
      AND pp.operation='commit' AND pp.consumed_at IS NULL
      AND pp.transaction_id=txid_current() AND pp.backend_pid=pg_backend_pid()
      AND pc.consumed_at IS NULL AND pc.controller_version=a.controller_version
      AND wi.kind='choice' AND wi.state='provider_started'
      AND wi.dispatch_receipt_id IS NOT NULL)
   THEN RAISE EXCEPTION 'NATIVE_PRIVATE_INTENT_AUTHORITY' USING ERRCODE='42501';END IF;
   native_private:=true;
  END IF;
   IF a.id IS NULL OR d.controller_user_snapshot IS DISTINCT FROM exam_regia_private.current_principal()
     OR d.controller_version_snapshot<>a.controller_version
     OR (d.state<>'inviata' AND NOT native_private AND NOT exam_human_private.round_declaration_permit_v1(d.id)
       AND NOT (
         (d.state='risolta' AND a.actor_kind='png'
           AND EXISTS(SELECT 1 FROM mission_generic_owner.unified_round_windows uw WHERE uw.round_id=d.round_id)
           AND (mission_generic_owner.unified_service_staging(d.round_id) OR human_stage))
         OR (d.state='risolta' AND a.actor_kind='pg'
           AND ((d.kind='passa' AND d.declaration_text='')
             OR (d.kind IN ('utilita','movimento','passa')
               AND nullif(btrim(d.declaration_text),'') IS NOT NULL
               AND EXISTS(SELECT 1 FROM mission_generic_owner.unified_round_windows uw2
                 JOIN mission_generic_owner.flow_staff_sessions fs2 ON fs2.master_session_id=uw2.master_session_id AND fs2.enabled
                 JOIN public.master_v2_sessions ms2 ON ms2.id=fs2.master_session_id
                   AND ms2.owner_kind='ai_service' AND ms2.closed_at IS NULL
                 JOIN public.locations l2 ON l2.id=ms2.location_id AND l2.is_test
                 WHERE uw2.round_id=d.round_id AND uw2.side='pg' AND uw2.publication_id IS NOT NULL
                   AND ms2.id=(SELECT master_session_id FROM public.combat_v2_sessions WHERE id=a.session_id))))
           AND (EXISTS(SELECT 1 FROM mission_generic_owner.unified_round_windows uw WHERE uw.round_id=d.round_id)
             OR combat_panel_private.human_duel_round(d.round_id)))
         OR human_pg_resolved OR native_pg_resolved OR human_png_pass_resolved OR human_genjutsu_resolved))
     OR d.declaration_text IS DISTINCT FROM coalesce(p_text,'') THEN
     RAISE EXCEPTION 'panel_role_declaration_scope_invalid' USING ERRCODE='42501'; END IF;
  SELECT location_id INTO STRICT location FROM public.combat_v2_sessions WHERE id=a.session_id;
  IF native_private THEN RETURN NULL;END IF;
  IF a.actor_kind='png' AND exam_human_private.round_declaration_permit_v1(d.id) THEN RETURN NULL; END IF;
  IF a.actor_kind='png' AND human_window THEN
    IF NOT human_stage THEN RAISE EXCEPTION 'REGIA_FATO_PENDING' USING ERRCODE='42501'; END IF;
    RETURN NULL;
  END IF;

 IF a.actor_kind='png' AND EXISTS(
  SELECT 1 FROM mission_generic_owner.unified_batches ub
   WHERE ub.master_session_id=(SELECT master_session_id FROM public.combat_v2_sessions WHERE id=a.session_id)
     AND ub.state IN ('preparing','ready') AND ub.composition_kind='entry_png'
     AND ub.payload->>'schema_version'='mission-generic-narration/4')
  AND (mission_generic_owner.principal_in_session(
   (SELECT master_session_id FROM public.combat_v2_sessions WHERE id=a.session_id),exam_regia_private.current_principal())
   AND mission_generic_owner.actor_principal(a.id)=exam_regia_private.current_principal()) IS NOT TRUE
 THEN RAISE EXCEPTION 'MRS_V4_PUBLISHER_PRINCIPAL_INVALID' USING ERRCODE='42501'; END IF;

 IF a.actor_kind='png' AND mission_generic_owner.principal_in_session(
  (SELECT master_session_id FROM public.combat_v2_sessions WHERE id=a.session_id),exam_regia_private.current_principal())
  AND mission_generic_owner.actor_principal(a.id)=exam_regia_private.current_principal() THEN
  IF nullif(btrim(p_text),'') IS NULL THEN RAISE EXCEPTION 'MG_PNG_ATTEMPT_EMPTY'; END IF;
  IF mission_generic_owner.try_stage_deferred_png_v4(d.id,p_text) THEN RETURN NULL; END IF;
   -- Only the protected Mission Generic Staff path can defer this public text.
   -- Entry PNG v4 keeps its separate sealed-slot publisher and cannot fall through.
   IF EXISTS(SELECT 1 FROM mission_generic_owner.unified_round_windows uw
      JOIN mission_generic_owner.unified_batches ub ON ub.id=uw.batch_id
      JOIN mission_generic_owner.flow_staff_sessions fs ON fs.master_session_id=ub.master_session_id AND fs.enabled
      JOIN public.master_v2_sessions ms ON ms.id=fs.master_session_id
       AND ms.owner_kind='ai_service' AND ms.closed_at IS NULL
      JOIN public.locations loc ON loc.id=ms.location_id AND loc.id=location AND loc.is_test
      WHERE uw.round_id=d.round_id AND ub.master_session_id=(SELECT master_session_id FROM public.combat_v2_sessions WHERE id=a.session_id)
        AND NOT (ub.composition_kind='entry_png' AND ub.payload->>'schema_version'='mission-generic-narration/4'))
   THEN RETURN NULL; END IF;
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
DO $catalogo_root$
DECLARE
 expected_parameters_sha256 constant text:='__GENJUTSU_RESOLVED_ROLE_PARAMETERS_SHA256__';
 old_root_sha text;
 old_row_sha text;
 generic_ezbr constant text:='9a6889802cfa17c99a556538cccd4ad7ef75274d32adccbc192c23d257aa3e76';
 baseline_combat_ezbr constant text:='79bdb113f0203e5b0578a1211fb43f1c5cfb6b3bb5585714b4d9b5475ce27a11';
 rr mission_factory_owner.editor_release_readiness%ROWTYPE;
 prior_release mission_public_owner.release_admissions_v1%ROWTYPE;
 prior_qualification mission_public_owner.public_qualification_attestations_v1%ROWTYPE;
 params jsonb;review jsonb;binding jsonb;before_root jsonb;root jsonb;core jsonb;cfg jsonb;identity jsonb;runtime_before jsonb;expected_ui jsonb;
 shared_manifest jsonb:='[]';private_manifest jsonb:='[]';relation_manifest jsonb:='[]';trigger_manifest jsonb:='[]';
 item jsonb;h jsonb;abi jsonb;cols jsonb;descriptor jsonb;next_descriptor jsonb;alias_row record;kv record;
 relation_oid oid;function_oid oid;actual_count integer;affected integer;aliases integer:=0;
 old_generic jsonb;old_combat jsonb;edge_receipt jsonb;edge_files jsonb;base_files jsonb;changed_files jsonb;
 db_stored text;db_old_recomputed text;db_sha text;shared_sha text;private_sha text;relations_sha text;
 config_sha text;identity_sha text;root_text text;new_root_sha text;bindings jsonb;qualification jsonb;
 content_row mission_public_owner.mission_content_admissions_v1%ROWTYPE;content_request uuid;content_payload jsonb;
 changed_headers jsonb;native_manifest jsonb;pending_paths text[]:=ARRAY['["db_core"]'];current_path text[];stack_size integer;
 raw_bytes bytea;compact_bytes bytea:=''::bytea;byte_chunks bytea[]:='{}';byte_chunk bytea:=''::bytea;
 byte_index integer;byte_value integer;inside_string boolean:=false;escaped boolean:=false;
 profile_row record;profile_state jsonb;schema_name text;name_only text;
 namespace_uuid constant uuid:='9ebf5297-66c5-5a19-b35a-589b626e4a4f';
BEGIN
 IF current_user<>'postgres' OR session_user<>'postgres' OR auth.uid() IS NOT NULL THEN
  RAISE EXCEPTION 'CATALOGO_ROOT_OPERATOR_REQUIRED';END IF;
 PERFORM set_config('search_path','',true);
 IF NOT pg_try_advisory_xact_lock(hashtextextended('C1266:GENERIC-AI:AVAILABILITY',0)) THEN
  RAISE EXCEPTION 'CATALOGO_ROOT_AVAILABILITY_BUSY';END IF;
 params:=nullif(current_setting('app.genjutsu_resolved_role_parameters',true),'')::jsonb;old_root_sha:=params#>>'{expected_current,root_sha256}';old_row_sha:=params#>>'{expected_current,root_row_sha256}';
 SELECT * INTO STRICT rr FROM mission_factory_owner.editor_release_readiness WHERE singleton FOR UPDATE NOWAIT;
 IF rr.revision_sha256<>old_root_sha OR rr.observed_revision_sha256 IS DISTINCT FROM old_root_sha
 OR public.combat_v2_sha256(to_jsonb(rr))<>old_row_sha
 OR encode(extensions.digest(convert_to(rr.canonical_preimage,'UTF8'),'sha256'),'hex')<>old_root_sha
 OR octet_length(rr.canonical_preimage)<>(params#>>'{expected_current,root_bytes}')::integer THEN RAISE EXCEPTION 'CATALOGO_ROOT_BASELINE_DRIFT';END IF;
 IF EXISTS(SELECT 1 FROM public.combat_v2_sessions WHERE state='in_corso' AND closed_at IS NULL)
 OR EXISTS(SELECT 1 FROM public.master_v2_sessions WHERE stato NOT IN('chiusa','annullata') AND closed_at IS NULL) THEN
  RAISE EXCEPTION 'CATALOGO_ROOT_REQUIRES_QUIESCENCE';END IF;
 params:=nullif(current_setting('app.genjutsu_resolved_role_parameters',true),'')::jsonb;
 IF expected_parameters_sha256 !~ '^[0-9a-f]{64}$' OR params IS NULL
 OR public.combat_v2_sha256(params)<>expected_parameters_sha256
 OR params->>'schema_version' IS DISTINCT FROM 'genjutsu-resolved-role-parameters/1' THEN
  RAISE EXCEPTION 'CATALOGO_ROOT_REVIEWED_PARAMETERS_REQUIRED';END IF;
 review:=params->'review';
 IF NOT mission_factory_owner.keys_exact_v2(review,ARRAY['ref','sha256','P0','P1','P2']) THEN
  RAISE EXCEPTION 'CATALOGO_ROOT_REVIEW_SHAPE';END IF;
 IF nullif(review->>'ref','') IS NULL OR octet_length(to_jsonb(review->>'ref')::text)>258 OR coalesce(review->>'sha256','')!~'^[0-9a-f]{64}$'
 OR review->'P0' IS DISTINCT FROM '0'::jsonb OR review->'P1' IS DISTINCT FROM '0'::jsonb OR review->'P2' IS DISTINCT FROM '0'::jsonb
 OR coalesce(params->>'source_bundle_sha256','')!~'^[0-9a-f]{64}$'
 OR params#>>'{baseline_custody,sha256}' IS DISTINCT FROM old_root_sha
 OR nullif(params#>>'{baseline_custody,ref}','') IS NULL
 OR params#>>'{compatibility,scope}' IS DISTINCT FROM 'existing_mission_capabilities_only'
 OR params#>'{compatibility,new_techniques_staff_pass}' IS DISTINCT FROM 'false'::jsonb
 OR coalesce(params#>>'{compatibility,sha256}','')!~'^[0-9a-f]{64}$'
 OR nullif(params#>>'{compatibility,ref}','') IS NULL THEN RAISE EXCEPTION 'CATALOGO_ROOT_REVIEW_SCOPE_REQUIRED';END IF;
 LOCK TABLE mission_public_owner.release_admissions_v1,mission_public_owner.public_qualification_attestations_v1,
  mission_public_owner.engine_profile_events_v1,mission_public_owner.mission_content_admissions_v1,
  mission_public_owner.party_launch_runtime_v1 IN SHARE ROW EXCLUSIVE MODE NOWAIT;
 before_root:=rr.canonical_preimage::jsonb;root:=before_root;
 -- Il JSON runtime è riletto esplicitamente per il CAS finale e conserva entrambi i booleani.
 SELECT to_jsonb(x) INTO STRICT runtime_before FROM mission_public_owner.party_launch_runtime_v1 x WHERE singleton FOR UPDATE;
 IF runtime_before IS DISTINCT FROM jsonb_build_object('singleton',true,'staff_enabled',true,'public_enabled',true,'release_sha256',old_root_sha) THEN
  RAISE EXCEPTION 'CATALOGO_ROOT_PARTY_BASELINE';END IF;
 SELECT value INTO STRICT old_generic FROM jsonb_array_elements(before_root->'edge_bundles') WHERE value->>'name'='mission_generic_ai';
 SELECT value INTO STRICT old_combat FROM jsonb_array_elements(before_root->'edge_bundles') WHERE value->>'name'='combat_narratore_ai';
 IF old_generic->>'ezbr_sha256'<>generic_ezbr OR old_generic->'version'<>'168'::jsonb
 OR old_combat->'version'IS DISTINCT FROM '45'::jsonb OR old_combat->>'ezbr_sha256'IS DISTINCT FROM '79bdb113f0203e5b0578a1211fb43f1c5cfb6b3bb5585714b4d9b5475ce27a11'
 OR public.combat_v2_sha256(root->'ui')<>'cd76714cb188ea3f69189ac5dd793304acdc2179da724aad852f961d12ab3014' THEN
  RAISE EXCEPTION 'CATALOGO_ROOT_UNRELATED_SURFACE_DRIFT';END IF;
 db_stored:=root#>>'{db_core,sha256}';db_old_recomputed:=public.combat_v2_sha256((root->'db_core')-'sha256');
 IF db_stored IS DISTINCT FROM params#>>'{expected_current,db_sha256}' OR db_old_recomputed IS DISTINCT FROM db_stored
 OR root#>>'{config,sha256}'<>public.combat_v2_sha256((root->'config')-'sha256') THEN
  RAISE EXCEPTION 'CATALOGO_ROOT_HASH_RECONCILIATION_DRIFT';END IF;

SELECT jsonb_agg(jsonb_build_object('oid',p.oid::text,'signature',p.oid::regprocedure::text,'source_md5',md5(p.prosrc),'ddl_md5',md5(pg_get_functiondef(p.oid)),
 'owner',pg_get_userbyid(p.proowner),'acl',p.proacl::text,'config',p.proconfig,'secdef',p.prosecdef,'volatility',p.provolatile::text,
 'language',l.lanname,'strict',p.proisstrict,'parallel',p.proparallel::text,'kind',p.prokind::text,'returns',pg_get_function_result(p.oid),
 'arg_names',p.proargnames,'arg_modes',p.proargmodes,'arg_types',p.proargtypes::text,'leakproof',p.proleakproof,'nspname',n.nspname,'proname',p.proname)
 ORDER BY p.oid::regprocedure::text) INTO shared_manifest FROM pg_proc p JOIN pg_namespace n ON n.oid=p.pronamespace JOIN pg_language l ON l.oid=p.prolang
 WHERE p.prokind='f'AND p.oid IN('combat_consumer_private.narrative_context(uuid)'::regprocedure,'combat_consumer_private.narrative_declaration_supported(uuid)'::regprocedure,'combat_consumer_private.validate_narrative_result(jsonb)'::regprocedure,'combat_effects_private.lifecycle_before_report(uuid)'::regprocedure,'combat_effects_private.lifecycle_main_end(uuid)'::regprocedure,'combat_effects_private.lifecycle_open(uuid,uuid)'::regprocedure,'combat_effects_private.personal_turn_end(uuid,uuid,uuid,text)'::regprocedure,'combat_effects_private.personal_turn_start(uuid,uuid,uuid,text)'::regprocedure,'combat_panel_private.commit_master_actor(jsonb)'::regprocedure,'combat_panel_private.immobilization_actor_lifecycle()'::regprocedure,'combat_panel_private.immobilization_session_lifecycle()'::regprocedure,'combat_panel_private.master_options(uuid,uuid,bigint)'::regprocedure,'combat_panel_private.movement_block_reason(uuid)'::regprocedure,'combat_panel_private.narrative_declaration_facts(uuid)'::regprocedure,'combat_panel_private.narrative_ordinary_context(uuid)'::regprocedure,'combat_panel_private.narrative_outcome_facts(jsonb)'::regprocedure,'combat_panel_private.ordinary_options(uuid,uuid,bigint)'::regprocedure,'combat_panel_private.round_details_from_source(jsonb,jsonb,jsonb)'::regprocedure,'combat_panel_private.round_options_authoritative(uuid,uuid)'::regprocedure,'combat_v2_elemental_internal.other_consumer_options(jsonb)'::regprocedure,'combat_v2_elemental_internal.other_control_apply(text,uuid,uuid,uuid)'::regprocedure,'combat_v2_elemental_internal.other_control_target(text,uuid,uuid)'::regprocedure,'combat_v2_elemental_internal.other_master_options(uuid,bigint)'::regprocedure,'combat_v2_elemental_internal.other_prepare_native(uuid,uuid,uuid,jsonb,boolean,jsonb)'::regprocedure,'combat_v2_elemental_internal.other_profile(uuid,uuid)'::regprocedure,'combat_v2_multitarget_internal.resolve_parent(uuid,uuid,uuid,boolean)'::regprocedure,'public.combat_consumer_narrative_claim_v1(uuid,text,uuid)'::regprocedure,'public.combat_consumer_narrative_complete_v1(uuid,jsonb,uuid)'::regprocedure,'public.combat_panel_commit_v1(jsonb)'::regprocedure,'public.combat_v2_action_declare(uuid,uuid,jsonb,text,uuid)'::regprocedure,'public.combat_v2_actor_ability(uuid,text,uuid,boolean)'::regprocedure,'public.combat_v2_defense_declare(uuid,uuid,uuid,jsonb,text,uuid)'::regprocedure,'public.combat_v2_round_resolve(uuid,uuid)'::regprocedure,'public.post_heal(uuid,uuid)'::regprocedure);
SELECT coalesce(jsonb_agg(jsonb_build_object('signature',p.oid::regprocedure::text,'source_md5',md5(p.prosrc),'ddl_md5',md5(pg_get_functiondef(p.oid)),
 'owner',pg_get_userbyid(p.proowner),'acl',p.proacl::text,'config',p.proconfig,'secdef',p.prosecdef,'volatility',p.provolatile::text,'language',l.lanname,
 'strict',p.proisstrict,'parallel',p.proparallel::text,'returns',pg_get_function_result(p.oid),'arg_names',p.proargnames,'arg_modes',p.proargmodes,'arg_types',p.proargtypes::text)
 ORDER BY p.oid::regprocedure::text),'[]'::jsonb) INTO private_manifest FROM pg_proc p JOIN pg_namespace n ON n.oid=p.pronamespace JOIN pg_language l ON l.oid=p.prolang
 WHERE p.prokind='f'AND(n.nspname='combat_v2_genjutsu_internal'OR(n.nspname='combat_panel_private'AND(p.proname LIKE 'cure\_%'ESCAPE'\'OR p.proname IN('catalog_result_label_v1','catalog_lifecycle_lines_v1'))));
SELECT jsonb_agg(jsonb_build_object('signature',p.oid::regprocedure::text,'source_md5',md5(p.prosrc),'ddl_md5',md5(pg_get_functiondef(p.oid)),
 'owner',pg_get_userbyid(p.proowner),'acl',p.proacl::text,'config',p.proconfig,'secdef',p.prosecdef,'volatility',p.provolatile::text,
 'language',l.lanname,'strict',p.proisstrict,'parallel',p.proparallel::text,'returns',pg_get_function_result(p.oid),
 'arg_names',p.proargnames,'arg_modes',p.proargmodes,'arg_types',p.proargtypes::text)ORDER BY p.oid::regprocedure::text)
  INTO native_manifest FROM pg_proc p JOIN pg_language l ON l.oid=p.prolang WHERE p.prokind='f'AND p.oid IN('public.combat_v2_substitution_options_v1(uuid)'::regprocedure,'public.combat_v2_substitution_round_offers_v1(uuid,uuid)'::regprocedure,'public.combat_v2_substitution_select_v1(uuid,uuid)'::regprocedure);
SELECT jsonb_agg(jsonb_build_object('signature',p.oid::regprocedure::text,'source_md5',md5(p.prosrc),'ddl_md5',md5(pg_get_functiondef(p.oid)),
 'owner',pg_get_userbyid(p.proowner),'secdef',p.prosecdef,'config',p.proconfig,'acl',p.proacl::text,'volatility',p.provolatile::text)ORDER BY p.oid::regprocedure::text)
  INTO trigger_manifest FROM pg_proc p WHERE p.oid IN('combat_panel_private.round_options_authoritative(uuid,uuid)'::regprocedure,'public.combat_v2_substitution_options_v1(uuid)'::regprocedure,'public.combat_v2_substitution_round_offers_v1(uuid,uuid)'::regprocedure,'public.combat_v2_substitution_select_v1(uuid,uuid)'::regprocedure,'clan_innata_private.catalogo_eligibility_release_v1()'::regprocedure,'combat_panel_private.publish_master_declaration(uuid,text)'::regprocedure);
SELECT jsonb_agg(jsonb_build_object('oid',p.oid::text,'signature',p.oid::regprocedure::text,'source_md5',md5(p.prosrc),'ddl_md5',md5(pg_get_functiondef(p.oid)),
 'owner',pg_get_userbyid(p.proowner),'acl',p.proacl::text,'config',p.proconfig,'secdef',p.prosecdef,'volatility',p.provolatile::text,
 'language',l.lanname,'strict',p.proisstrict,'parallel',p.proparallel::text,'kind',p.prokind::text,'returns',pg_get_function_result(p.oid),
 'arg_names',p.proargnames,'arg_modes',p.proargmodes,'arg_types',p.proargtypes::text,'leakproof',p.proleakproof,'nspname',n.nspname,'proname',p.proname)
 ORDER BY p.oid::regprocedure::text) INTO changed_headers FROM pg_proc p JOIN pg_namespace n ON n.oid=p.pronamespace JOIN pg_language l ON l.oid=p.prolang
 WHERE p.prokind='f'AND p.oid IN('combat_panel_private.publish_master_declaration(uuid,text)'::regprocedure);
SELECT jsonb_agg(jsonb_build_object('signature',p.oid::regprocedure::text,'source_md5',md5(p.prosrc),'ddl_md5',md5(pg_get_functiondef(p.oid)),
 'owner',pg_get_userbyid(p.proowner),'secdef',p.prosecdef,'config',p.proconfig,'acl',p.proacl::text,'volatility',p.provolatile::text)ORDER BY p.oid::regprocedure::text)
  INTO relation_manifest FROM pg_proc p WHERE p.oid IN('clan_innata_private.eligibility_release_assert()'::regprocedure,'clan_innata_private.catalogo_eligibility_release_v1()'::regprocedure);
 shared_sha:=public.combat_v2_sha256(shared_manifest);private_sha:=public.combat_v2_sha256(private_manifest);
 IF jsonb_array_length(shared_manifest)<>34 OR jsonb_array_length(private_manifest)<>66 OR jsonb_array_length(native_manifest)<>3
 OR jsonb_array_length(changed_headers)<>1 OR jsonb_array_length(relation_manifest)<>2 OR shared_sha<>'03f750c6bb386e6ef79db36673a0ec9382e9d131b6d4ad970dcb8690b3f5ed18'OR private_sha<>'738506bdca70d1a39219535f7aa12ffc8dc4c1807939b9b6d8f986c9890f0833'
 OR public.combat_v2_sha256(native_manifest)<>'2d903f7977adb0086633ebe09f6e8b9994bdf2b17218a14ae3a2eac837b6581f'THEN RAISE EXCEPTION 'cure_reaction_post_manifest_drift';END IF;
 IF jsonb_array_length(trigger_manifest)<>6 OR public.combat_v2_sha256(trigger_manifest)<>'b0d8eb653120c5fca28c4de81bbce61b0275da88f78bddff0eec768a837a0d02'THEN RAISE EXCEPTION 'palmo_completion_peer6_drift';END IF;
 -- Update every existing touched-OID alias; ABI remains byte-exact.
 WHILE coalesce(cardinality(pending_paths),0)>0 LOOP
  stack_size:=cardinality(pending_paths);SELECT ARRAY(SELECT jsonb_array_elements_text(pending_paths[stack_size]::jsonb))INTO current_path;
  pending_paths:=pending_paths[1:stack_size-1];descriptor:=root#>current_path;
  IF jsonb_typeof(descriptor)='object'THEN
   SELECT value INTO h FROM jsonb_array_elements(changed_headers)WHERE value->>'oid'=descriptor->>'oid';
   IF descriptor?'oid'AND h IS NOT NULL THEN
    FOR kv IN SELECT key,value FROM jsonb_each(descriptor)WHERE key=ANY(ARRAY['owner','acl','config','secdef','strict','language','parallel','arg_modes','arg_names','arg_types','leakproof','returns','volatility','kind','signature','nspname','proname'])LOOP
     IF kv.value IS DISTINCT FROM h->kv.key THEN RAISE EXCEPTION 'cure_reaction_alias_abi';END IF;
    END LOOP;
    next_descriptor:=descriptor;
    IF descriptor?'source_md5'THEN next_descriptor:=jsonb_set(next_descriptor,'{source_md5}',h->'source_md5',false);END IF;
    IF descriptor?'ddl_md5'THEN next_descriptor:=jsonb_set(next_descriptor,'{ddl_md5}',h->'ddl_md5',false);END IF;
    root:=jsonb_set(root,current_path,next_descriptor,false);aliases:=aliases+1;
   ELSE
    FOR kv IN SELECT key,value FROM jsonb_each(descriptor)WHERE jsonb_typeof(value)IN('object','array')LOOP pending_paths:=array_append(pending_paths,to_jsonb(array_append(current_path,kv.key))::text);END LOOP;
   END IF;
  ELSIF jsonb_typeof(descriptor)='array'THEN
   FOR kv IN SELECT(ord-1)::text AS key,value FROM jsonb_array_elements(descriptor)WITH ORDINALITY x(value,ord)WHERE jsonb_typeof(value)IN('object','array')LOOP pending_paths:=array_append(pending_paths,to_jsonb(array_append(current_path,kv.key))::text);END LOOP;
  END IF;
 END LOOP;
 IF aliases<>1 THEN RAISE EXCEPTION 'staff_entry_repairs_alias_count';END IF;
 binding:=root#>'{db_core,cure_command_amendment}';
 binding:=jsonb_set(binding,'{functions_manifest_sha256}',to_jsonb(public.combat_v2_sha256(trigger_manifest)),false);
 root:=jsonb_set(root,'{db_core,cure_command_amendment}',binding,false);root:=jsonb_set(root,'{config,cure_command_amendment}',binding,false);
 core:=root->'db_core';db_sha:=public.combat_v2_sha256(core-'sha256');core:=jsonb_set(core,'{sha256}',to_jsonb(db_sha),false);root:=jsonb_set(root,'{db_core}',core,false);
 cfg:=root->'config';config_sha:=public.combat_v2_sha256(cfg-'sha256');cfg:=jsonb_set(cfg,'{sha256}',to_jsonb(config_sha),false);root:=jsonb_set(root,'{config}',cfg,false);
 expected_ui:=before_root->'ui';
 IF public.combat_v2_sha256(expected_ui)IS DISTINCT FROM 'cd76714cb188ea3f69189ac5dd793304acdc2179da724aad852f961d12ab3014' THEN RAISE EXCEPTION 'cure_entry_recovery_ui_drift';END IF;
 identity:=jsonb_build_object('schema_version','genjutsu-resolved-role-code-identity/1','parent_root',old_root_sha,'parent_code_identity',before_root#>'{contract,code_identity_sha256}',
  'normalized_amendment_identity_sha256',binding->'normalized_source_identity_sha256','active_shared_manifest_sha256',shared_sha,
  'active_private_functions_manifest_sha256',private_sha,'native_functions_manifest_sha256',binding->'native_functions_manifest_sha256',
  'source_bundle_sha256',params->'source_bundle_sha256','mode',params->'mode','guard_source_md5','ef199a674937b3bc4f9dbd49f35bf9b2','db_sha256',db_sha,'client_sha256',public.combat_v2_sha256(root->'ui'),'ui_graph_sha256',root#>>'{ui,import_graph_sha256}','amendment_state',binding->'state');
 identity_sha:=public.combat_v2_sha256(identity);root:=jsonb_set(root,'{contract,code_identity_sha256}',to_jsonb(identity_sha),false);
 root:=jsonb_set(root,'{recovery,semantic_identity_sha256}',to_jsonb(identity_sha),false);
 root:=jsonb_set(root,'{recovery,cure_command_amendment}',jsonb_build_object('parent_root',old_root_sha,'state',binding->'state',
  'previous_semantic_identity',before_root#>'{recovery,semantic_identity_sha256}','policy','forward_role_keep_code'),false);
 IF root->'ui'IS DISTINCT FROM expected_ui OR root->'edge_bundles'IS DISTINCT FROM before_root->'edge_bundles'
 OR(root->'config')-ARRAY['sha256','cure_command_amendment']IS DISTINCT FROM(before_root->'config')-ARRAY['sha256','cure_command_amendment']
 OR root#>'{db_core,catalogo_completo}'IS DISTINCT FROM before_root#>'{db_core,catalogo_completo}'THEN RAISE EXCEPTION 'cure_reaction_unrelated_config_changed';END IF;
 -- Lexer UTF8 a byte, memoria limitata: non usa token SQL, sort o aggregati.
 -- Si scarta soltanto whitespace JSON ASCII esterno alle stringhe.
 -- Gli escape e ogni byte interno alle stringhe restano identici; niente NFC.
 raw_bytes:=convert_to(root::text,'UTF8');
 IF octet_length(raw_bytes)>1048576 THEN RAISE EXCEPTION 'CATALOGO_ROOT_SERIALIZATION_INPUT_CAP';END IF;
 FOR byte_index IN 0..octet_length(raw_bytes)-1 LOOP
  byte_value:=get_byte(raw_bytes,byte_index);
  IF inside_string THEN
   IF escaped THEN escaped:=false;
   ELSIF byte_value=92 THEN escaped:=true;
   ELSIF byte_value=34 THEN inside_string:=false;END IF;
  ELSE
   IF byte_value=34 THEN inside_string:=true;
   ELSIF byte_value IN(9,10,13,32) THEN CONTINUE;END IF;
  END IF;
  byte_chunk:=byte_chunk||substring(raw_bytes FROM byte_index+1 FOR 1);
  IF octet_length(byte_chunk)>=4096 THEN
   byte_chunks:=array_append(byte_chunks,byte_chunk);byte_chunk:=''::bytea;
  END IF;
 END LOOP;
 IF inside_string OR escaped THEN RAISE EXCEPTION 'CATALOGO_ROOT_SERIALIZATION_STRING_STATE';END IF;
 IF octet_length(byte_chunk)>0 THEN byte_chunks:=array_append(byte_chunks,byte_chunk);END IF;
 FOREACH byte_chunk IN ARRAY byte_chunks LOOP compact_bytes:=compact_bytes||byte_chunk;END LOOP;
 root_text:=convert_from(compact_bytes,'UTF8');
 IF root_text IS NULL OR root_text::jsonb IS DISTINCT FROM root THEN RAISE EXCEPTION 'CATALOGO_ROOT_COMPACT_SERIALIZATION';END IF;
 IF octet_length(root_text)>524288 THEN RAISE EXCEPTION 'CATALOGO_ROOT_BYTES_CAP:%',octet_length(root_text);END IF;
 new_root_sha:=encode(extensions.digest(convert_to(root_text,'UTF8'),'sha256'),'hex');

 -- Baseline missione validata prima del passaggio; niente nuove capability.
 IF mission_public_owner.engine_qualification_v1(old_root_sha,true)IS NULL THEN RAISE EXCEPTION 'CATALOGO_ROOT_PREVIOUS_MISSION_UNQUALIFIED';END IF;
 SELECT * INTO STRICT prior_release FROM mission_public_owner.release_admissions_v1 WHERE release_sha256=old_root_sha FOR SHARE;
 SELECT * INTO STRICT prior_qualification FROM mission_public_owner.public_qualification_attestations_v1 WHERE release_sha256=old_root_sha FOR SHARE;
 IF(SELECT count(*)FROM mission_public_owner.mission_content_admissions_v1 WHERE engine_release_sha256=old_root_sha)<>2
 OR(SELECT public.combat_v2_sha256(jsonb_agg(to_jsonb(c)ORDER BY c.mission_id,c.request_key))FROM mission_public_owner.mission_content_admissions_v1 c WHERE engine_release_sha256=old_root_sha)
 IS DISTINCT FROM params->>'expected_content_admission_rows_sha256'
 THEN RAISE EXCEPTION 'FIX_ELIGIBILITY_CONTENT_BASELINE';END IF;
 FOR content_row IN SELECT * FROM mission_public_owner.mission_content_admissions_v1 WHERE engine_release_sha256=old_root_sha FOR SHARE LOOP
  IF mission_public_owner.content_admission_v1(content_row.mission_id,old_root_sha,content_row.publication_request,true)IS NULL THEN
   RAISE EXCEPTION 'CATALOGO_ROOT_PREVIOUS_CONTENT_UNQUALIFIED';END IF;
 END LOOP;
 bindings:=jsonb_build_object('db_sha256',db_sha,'edge_sha256',generic_ezbr,'client_sha256',public.combat_v2_sha256(root->'ui'),'configuration_sha256',config_sha);
 UPDATE mission_factory_owner.editor_release_readiness SET canonical_preimage=root_text,revision_sha256=new_root_sha,
  observed_revision_sha256=new_root_sha,client_build='mission-factory-admin/2:'||new_root_sha,
  independent_review_ref=review->>'ref',updated_at=clock_timestamp()
  WHERE singleton AND revision_sha256=old_root_sha AND public.combat_v2_sha256(to_jsonb(editor_release_readiness))=old_row_sha;
 GET DIAGNOSTICS affected=ROW_COUNT;IF affected<>1 THEN RAISE EXCEPTION 'CATALOGO_ROOT_ROW_CAS';END IF;
 INSERT INTO mission_public_owner.release_admissions_v1(release_sha256,db_sha256,edge_sha256,client_sha256,configuration_sha256,
  contract_version,independent_review_ref,staff_evidence_ref,qualified_at,public_enabled)
 VALUES(new_root_sha,db_sha,generic_ezbr,bindings->>'client_sha256',config_sha,prior_release.contract_version,
  review->>'ref',prior_release.staff_evidence_ref,prior_release.qualified_at,prior_release.public_enabled);
 FOR profile_row IN SELECT DISTINCT ON(profile_key)* FROM mission_public_owner.engine_profile_events_v1
  WHERE engine_release_sha256=old_root_sha ORDER BY profile_key,control_version DESC LOOP
  IF profile_row.profile_key IS DISTINCT FROM prior_qualification.payload->>'authoring_profile' THEN
   RAISE EXCEPTION 'CATALOGO_ROOT_UNQUALIFIED_PROFILE_CARRYFORWARD';END IF;
  INSERT INTO mission_public_owner.engine_profile_events_v1(event_id,engine_release_sha256,profile_key,expected_control_version,
   control_version,authoring_enabled,runtime_enabled,actor_user,reason)
  VALUES(extensions.uuid_generate_v5(namespace_uuid,new_root_sha||':profile:'||profile_row.profile_key),new_root_sha,profile_row.profile_key,
   0,1,profile_row.authoring_enabled,profile_row.runtime_enabled,profile_row.actor_user,
   'Compatible carryforward of existing mission profile only; new catalog techniques have no Staff PASS');
 END LOOP;
 qualification:=prior_qualification.payload||jsonb_build_object('revision_sha256',new_root_sha,'bindings',bindings,'independent_review',review,
  'reuse_evidence',(prior_qualification.payload->'reuse_evidence')||jsonb_build_object('new_mission_QA_claim',false,
   'catalogo_compatibility',jsonb_build_object('parent_root',old_root_sha,'ref',params#>'{compatibility,ref}',
    'sha256',params#>'{compatibility,sha256}','scope','existing_mission_capabilities_only','new_techniques_staff_pass',false)));
 INSERT INTO mission_public_owner.public_qualification_attestations_v1(release_sha256,request_key,payload,payload_sha256,
  positive_staff_evidence_ref,authorized_test_manifest_ref,created_by)
 VALUES(new_root_sha,extensions.uuid_generate_v5(namespace_uuid,new_root_sha||':qualification'),qualification,mission_factory_owner.sha(qualification),
  prior_qualification.positive_staff_evidence_ref,prior_qualification.authorized_test_manifest_ref,prior_qualification.created_by);
 IF qualification->'capabilities' IS DISTINCT FROM prior_qualification.payload->'capabilities'
 OR mission_public_owner.engine_qualification_v1(new_root_sha,true)IS NULL THEN RAISE EXCEPTION 'CATALOGO_ROOT_MISSION_CARRYFORWARD_INVALID';END IF;
 FOR content_row IN SELECT * FROM mission_public_owner.mission_content_admissions_v1 WHERE engine_release_sha256=old_root_sha ORDER BY mission_id LOOP
  content_request:=extensions.uuid_generate_v5(content_row.request_key,new_root_sha||':catalogo-compatible-adoption');
  content_payload:=content_row.payload||jsonb_build_object('request_key',content_request,'engine_release_sha256',new_root_sha,'created_at',clock_timestamp());
  INSERT INTO mission_public_owner.mission_content_admissions_v1(request_key,mission_id,config_version,engine_release_sha256,publication_request,payload,payload_sha256)
  VALUES(content_request,content_row.mission_id,content_row.config_version,new_root_sha,content_row.publication_request,content_payload,mission_factory_owner.sha(content_payload));
  IF mission_public_owner.content_admission_v1(content_row.mission_id,new_root_sha,content_row.publication_request,true)IS NULL THEN
   RAISE EXCEPTION 'CATALOGO_ROOT_CONTENT_CARRYFORWARD_INVALID';END IF;
 END LOOP;
 UPDATE mission_public_owner.party_launch_runtime_v1 x SET release_sha256=new_root_sha WHERE singleton AND to_jsonb(x)=runtime_before;
 GET DIAGNOSTICS affected=ROW_COUNT;IF affected<>1 THEN RAISE EXCEPTION 'CATALOGO_ROOT_PARTY_RUNTIME_CAS';END IF;
 IF NOT EXISTS(SELECT 1 FROM mission_public_owner.party_launch_runtime_v1 x WHERE singleton
  AND to_jsonb(x)=jsonb_set(runtime_before,'{release_sha256}',to_jsonb(new_root_sha),false))THEN RAISE EXCEPTION 'CATALOGO_ROOT_PARTY_FLAGS_CHANGED';END IF;
 IF(SELECT to_jsonb(g)FROM combat_v2_genjutsu_internal.gate g WHERE singleton)IS DISTINCT FROM current_setting('app.cure_reaction_paralisi_gate_before')::jsonb THEN RAISE EXCEPTION 'cure_reaction_paralisi_gate_changed';END IF;
 IF(SELECT to_jsonb(g)FROM combat_panel_private.cure_gate_v1 g WHERE singleton)IS DISTINCT FROM current_setting('app.cure_reaction_cure_gate_before')::jsonb THEN RAISE EXCEPTION 'palmo_completion_cure_gate_changed';END IF;
 IF NOT clan_innata_private.catalogo_eligibility_release_v1()THEN RAISE EXCEPTION 'FIX_ELIGIBILITY_BRANCH_NOT_ADMITTED';END IF;
 PERFORM set_config('app.genjutsu_resolved_role_result',jsonb_build_object('root_sha256',new_root_sha,'root_bytes',octet_length(root_text),'source_bundle_sha256',params->'source_bundle_sha256',
  'db_sha256',db_sha,'configuration_sha256',config_sha,'code_identity_sha256',identity_sha,'aliases_updated',aliases,
  'amendment_identity_sha256',binding->'normalized_source_identity_sha256','active_shared_manifest_sha256',shared_sha,'active_private_functions_manifest_sha256',private_sha,
  'new_techniques_staff_pass',false,'provider_calls',0)::text,true);
END $catalogo_root$;
DO $role_post$
DECLARE rr mission_factory_owner.editor_release_readiness%ROWTYPE;r jsonb;f jsonb;
BEGIN
 FOR f IN SELECT value FROM jsonb_array_elements($role_pins$[{"signature":"clan_innata_private.eligibility_release_assert()","source_md5":"ef199a674937b3bc4f9dbd49f35bf9b2","ddl_sha256":"680a47c514ab2255937d259a2fb0ecc8fd1b098670089d595b531839a23e33f9"},{"signature":"clan_innata_private.catalogo_eligibility_release_v1()","source_md5":"e52a8ac90fb15cad425cd0d17c9b4d4b","ddl_sha256":"72141f00f7b6c79aacf634334290e92debbcc3a5bd77365c55dc4ef3a82ea5f6"},{"signature":"clan_innata_private.runtime_release_assert()","source_md5":"6b9ed7edc3ea365017e1f5e84200ed79","ddl_sha256":"220301a349fe8d8d59717f82f84b9b5785c21acf0e8bd965682be6f85e513a38"},{"signature":"combat_panel_private.cure_contact_v1(uuid,uuid)","source_md5":"21de7dd5e62b5403b50065d2635e20bf","ddl_sha256":"0d5ef7dfd803fadfc2ec38aa4285467cd95f83bb613e6c0b6a0dde650d571f00"},{"signature":"combat_panel_private.master_projection(uuid,uuid)","source_md5":"271ea56acb5f135ad6e3d24d8601e3b1","ddl_sha256":"da26a20b86b168b4769b851405794371ddbe54095c1e8c775859c0b1c155cd0b"},{"signature":"combat_panel_private.round_options_authoritative(uuid,uuid)","source_md5":"7cf9d8be18c9dab5f75b62c74a5e9e37","ddl_sha256":"22bd8c8faf60ba44a644bf9ccd0f69ab8a5715383c79ff6014509dfd02290554"},{"signature":"combat_v2_elemental_internal.other_ability_meta(uuid,jsonb)","source_md5":"aa3d6fe2cb785a3a132a7b281bdab70a","ddl_sha256":"15fab8ec94575b4a0e163cfbdcc46272b02d47d772daa262de5483a43b18f5ac"},{"signature":"combat_panel_private.publish_master_declaration(uuid,text)","source_md5":"6c89288503ac54271d47e8f81b131393","ddl_sha256":"93726ac57b6b0a6b60602dac04da8e23afb276b6ae6c1b9658dd782b9a6ccda4"}]$role_pins$::jsonb) LOOP
  IF md5((SELECT prosrc FROM pg_proc WHERE oid=to_regprocedure(f->>'signature'))) IS DISTINCT FROM f->>'source_md5'
   OR encode(extensions.digest(convert_to(pg_get_functiondef(to_regprocedure(f->>'signature')),'UTF8'),'sha256'),'hex') IS DISTINCT FROM f->>'ddl_sha256'
  THEN RAISE EXCEPTION 'GENJUTSU_ROLE_BODY_DRIFT:%',f->>'signature';END IF;
 END LOOP;
 SELECT * INTO STRICT rr FROM mission_factory_owner.editor_release_readiness WHERE singleton;
 r:=rr.canonical_preimage::jsonb;
 IF r#>'{db_core,cure_command_amendment}' IS DISTINCT FROM r#>'{config,cure_command_amendment}'
 OR r#>>'{db_core,cure_command_amendment,functions_manifest_sha256}' IS DISTINCT FROM 'b0d8eb653120c5fca28c4de81bbce61b0275da88f78bddff0eec768a837a0d02'
 OR rr.observed_revision_sha256 IS DISTINCT FROM rr.revision_sha256
 OR encode(extensions.digest(convert_to(rr.canonical_preimage,'UTF8'),'sha256'),'hex') IS DISTINCT FROM rr.revision_sha256
 THEN RAISE EXCEPTION 'GENJUTSU_ROLE_ROOT_NOT_SEALED';END IF;
 PERFORM clan_innata_private.eligibility_release_assert();
END $role_post$;
COMMIT;
