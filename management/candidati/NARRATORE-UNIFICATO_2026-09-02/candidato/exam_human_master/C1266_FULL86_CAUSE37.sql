-- Fonte verificata Full86; NON installer autonomo. Non eseguire senza composizione Root, guardie e review del materiale integrato.
CREATE OR REPLACE FUNCTION mission_narrative_internal.scene_finish_proof_v1(p_session uuid, p_user uuid)
 RETURNS jsonb
 LANGUAGE plpgsql
 STABLE SECURITY DEFINER
 SET search_path TO ''
AS $function$
DECLARE r mission_narrative_internal.scene_runtime_v1;s mission_narrative_internal.scene_sources_v1;
 w mission_generic_owner.work_items;m public.master_v2_sessions;run public.mission_run_state;
 items jsonb;rev text;k uuid;reason text:='scope_closed';
 v_finish37_choice record;v_finish37_command_sha text;v_finish37_command_hashes jsonb:='{}'::jsonb;
BEGIN
 SELECT * INTO r FROM mission_narrative_internal.scene_runtime_v1 WHERE master_session_id=p_session AND is_active;
 IF NOT FOUND THEN RETURN NULL;END IF;
 SELECT * INTO m FROM public.master_v2_sessions WHERE id=p_session;
 SELECT * INTO run FROM public.mission_run_state WHERE master_session_id=p_session;
 IF p_user IS NULL OR m.owner_kind<>'ai_service' OR m.master_user IS NOT NULL
  OR m.location_id<>'0b85f354-9cdb-47e1-baf9-3d266bb7e06b'::uuid
  OR NOT EXISTS(SELECT 1 FROM public.locations WHERE id=m.location_id AND is_test AND is_active)
  OR NOT EXISTS(SELECT 1 FROM mission_generic_owner.board_starts WHERE master_session_id=m.id AND simulation AND state='published')
  OR NOT EXISTS(SELECT 1 FROM public.profiles profile JOIN public.master_v2_participants part ON part.user_id_snapshot=profile.id
   JOIN public.characters ch ON ch.id=part.character_id AND ch.user_id=profile.id
   WHERE profile.id=p_user AND profile.role IN('admin','master') AND part.session_id=m.id)
 THEN RETURN NULL;END IF;
 IF r.mode<>'closed' OR r.turn_owner<>'closed' OR run.run_phase<>'conclusa' THEN reason:='waiting_final_publication';
 ELSIF EXISTS(SELECT 1 FROM mission_generic_owner.work_items x WHERE x.master_session_id=m.id AND x.state NOT IN('completed','failed'))
  OR EXISTS(SELECT 1 FROM mission_narrative_internal.dispatch_attempts attempt JOIN mission_generic_owner.work_items x ON x.dispatch_receipt_id=attempt.receipt_id
   WHERE x.master_session_id=m.id AND attempt.status IN('reserved','authorized','provider_started','unknown_billable'))
  OR EXISTS(SELECT 1 FROM staff_ai_quota_private.calls call WHERE call.scope_id=m.id AND call.state IN('reserved','sent','unknown_billable')
   AND NOT (call.producer='mission_generic_ai' AND call.call_no=2 AND call.state='unknown_billable'
    AND call.sent_at IS NOT NULL AND call.reserved_usd>0 AND call.charged_usd IS NULL
    AND EXISTS(SELECT 1 FROM mission_narrative_internal.dispatch_receipts counted_dr
     JOIN mission_generic_owner.work_items counted_work ON counted_work.dispatch_receipt_id=counted_dr.id AND counted_work.master_session_id=call.scope_id
     JOIN staff_ai_quota_private.calls counted_gen ON counted_gen.producer=call.producer AND counted_gen.source_id=call.source_id AND counted_gen.scope_id=call.scope_id AND counted_gen.call_no=1
     JOIN mission_narrative_internal.dispatch_audit counted_audit ON counted_audit.receipt_id=counted_dr.id AND counted_audit.event_code='c8_count_success'
     WHERE counted_dr.id=call.source_id AND counted_dr.master_session_id=call.scope_id AND counted_dr.status='success'
      AND counted_dr.dispatch_count=1 AND counted_dr.finalized_at IS NOT NULL
      AND counted_work.state IN('completed','failed') AND counted_work.finalized_at IS NOT NULL
      AND counted_gen.state='settled' AND counted_gen.settled_at IS NOT NULL AND counted_gen.charged_usd=counted_dr.charged_cost_usd
      AND counted_audit.details->>'work_id'=counted_work.id::text AND counted_audit.details->>'state'='success'
      AND counted_audit.details->'generation_allowed'='true'::jsonb AND counted_audit.details->>'count_http_calls'='1'
      AND counted_audit.details->>'generation_http_calls'='0'))
   AND NOT(call.producer='mission_generic_ai' AND call.call_no=2 AND call.state='unknown_billable'
    AND call.sent_at IS NOT NULL AND call.charged_usd IS NULL AND call.reserved_usd>0
    AND EXISTS(SELECT 1 FROM mission_generic_owner.work_items old_count
     JOIN mission_narrative_internal.dispatch_receipts old_dr ON old_dr.id=old_count.dispatch_receipt_id
      AND old_dr.id=call.source_id AND old_dr.master_session_id=m.id AND old_dr.authority_receipt_id=old_count.id
      AND old_dr.status='failed' AND old_dr.finalized_at IS NOT NULL AND old_dr.dispatch_count=0 AND old_dr.charged_cost_usd=0
     JOIN mission_narrative_internal.dispatch_audit unknown_a ON unknown_a.receipt_id=old_dr.id AND unknown_a.event_code='c8_count_unknown'
      AND unknown_a.details->>'work_id'=old_count.id::text AND unknown_a.details->>'state'='unknown'
     JOIN mission_narrative_internal.dispatch_audit terminal_a ON terminal_a.receipt_id=old_dr.id AND terminal_a.event_code='c1266_count_terminal'
      AND terminal_a.details->>'work_id'=old_count.id::text AND terminal_a.details->>'result_sha256'=old_count.result_sha256
      AND terminal_a.details->>'count_ticket'=call.id::text AND terminal_a.details->>'count_ticket_sha256'=public.combat_v2_sha256(to_jsonb(call))
     JOIN mission_narrative_internal.dispatch_audit reissued ON reissued.receipt_id=old_dr.id AND reissued.event_code='native_peaceful_count_reissued_v1'
      AND reissued.details->>'old_work_id'=old_count.id::text AND reissued.details->>'old_result_sha256'=old_count.result_sha256
     JOIN mission_generic_owner.work_items child ON child.id::text=reissued.details->>'successor_work_id'
      AND child.master_session_id=m.id AND child.kind='director' AND child.state='completed' AND child.finalized_at IS NOT NULL
      AND child.result->'ok'='true'::jsonb AND child.payload=old_count.payload AND child.payload_sha256=old_count.payload_sha256
     JOIN mission_narrative_internal.dispatch_audit child_a ON child_a.receipt_id=child.dispatch_receipt_id AND child_a.event_code='generic_finalized'
      AND child_a.details->>'work_id'=child.id::text AND child_a.details->>'state'='completed'
      AND child_a.details->>'result_sha256'=child.result_sha256 AND child_a.details->>'result_jsonb_sha256'=public.combat_v2_sha256(child.result)
     JOIN mission_narrative_internal.scene_sources_v1 src ON src.technical_request->>'assessment_work_id'=child.id::text
      AND src.request_kind='combat_peaceful' AND src.published_message_id IS NOT NULL
      AND src.technical_request->'close_eligible'='true'::jsonb
     JOIN mission_generic_owner.work_items writer ON writer.id=src.work_id AND writer.state='completed'
      AND writer.master_session_id=m.id AND writer.message_id=src.published_message_id
     JOIN public.messages msg ON msg.id=src.published_message_id AND msg.location_id=m.location_id AND msg.kind='fato'
      AND msg.recipient_user IS NULL AND msg.body=writer.result->>'text'
     JOIN public.combat_v2_events terminal ON terminal.id::text=src.technical_receipt->>'terminal_event_id'
      AND terminal.status='completata' AND terminal.operation_kind='mission_generic_combat_close_peaceful'
      AND terminal.result#>>'{data,publication_message_id}'=msg.id::text
     WHERE old_count.master_session_id=m.id AND old_count.kind='director' AND old_count.state='failed'
      AND old_count.payload->>'schema_version'='mission-native-peaceful-assessment/1'
      AND old_count.result->>'schema_version'='c1266-count-terminal-failure/1' AND old_count.result->>'failure_code'='MISSION_INPUT_COUNT_UNKNOWN'
      AND old_count.result->>'generation_http_calls'='0' AND old_count.result->>'count_cost_state'='unknown_billable'
      AND old_count.result->'count_reserve_usd'=to_jsonb(call.reserved_usd)
      AND old_count.result_sha256=public.combat_v2_sha256(old_count.result)
      AND old_count.authorization_id IS NULL AND old_count.dispatch_id IS NULL
      AND NOT EXISTS(SELECT 1 FROM mission_narrative_internal.provider_authorizations pa WHERE pa.receipt_id=old_dr.id)
      AND NOT EXISTS(SELECT 1 FROM mission_narrative_internal.dispatch_attempts da WHERE da.receipt_id=old_dr.id)))
)
  OR EXISTS(SELECT 1 FROM public.mission_run_outbox WHERE master_session_id=m.id AND state IN('pending','human_directed'))
  OR EXISTS(SELECT 1 FROM mission_narrative_internal.scene_sources_v1 WHERE scene_id=r.id AND published_message_id IS NULL AND technical_receipt IS NULL AND retired_at IS NULL)
 THEN reason:='work_pending';
 ELSIF EXISTS(SELECT 1 FROM public.combat_v2_sessions WHERE master_session_id=m.id AND (state<>'chiuso' OR closed_at IS NULL)) THEN reason:='combat_pending';
 ELSE
  -- Cause37: normalize only own choice commands once, outside the history SQL predicate.
  FOR v_finish37_choice IN
   SELECT choice37.id,choice37.result->'command' AS command_body
   FROM mission_generic_owner.work_items choice37
   WHERE choice37.master_session_id=m.id AND choice37.kind='choice'
  LOOP
   v_finish37_command_sha:=NULL;
   BEGIN
    v_finish37_command_sha:=public.combat_v2_sha256(combat_panel_private.validate_command(v_finish37_choice.command_body));
   EXCEPTION WHEN data_exception THEN
    v_finish37_command_sha:=NULL;
   END;
   v_finish37_command_hashes:=v_finish37_command_hashes||jsonb_build_object(v_finish37_choice.id::text,v_finish37_command_sha);
  END LOOP;
  SELECT * INTO s FROM mission_narrative_internal.scene_sources_v1 WHERE scene_id=r.id AND published_message_id=r.last_publication_id AND publication_next_step='complete';
  SELECT * INTO w FROM mission_generic_owner.work_items WHERE id=s.work_id;
  IF s.id IS NULL OR w.id IS NULL OR w.state<>'completed' OR w.kind<>'narration' OR w.message_id IS DISTINCT FROM r.last_publication_id
   OR w.result#>>'{scene_update,next_step}' IS DISTINCT FROM 'complete' OR w.result->'ok' IS DISTINCT FROM 'true'::jsonb
   OR run.current_step_key IS DISTINCT FROM r.current_phase_key OR run.control_version IS DISTINCT FROM w.run_control_version+1
   OR NOT EXISTS(SELECT 1 FROM public.messages msg WHERE msg.id=r.last_publication_id AND msg.location_id=m.location_id
    AND msg.kind='fato' AND msg.recipient_user IS NULL AND msg.body=w.result->>'text'
    AND encode(extensions.digest(convert_to(msg.body,'UTF8'),'sha256'),'hex')=r.last_publication_sha256)
  THEN reason:='waiting_final_publication';
  ELSIF EXISTS(SELECT 1 FROM mission_generic_owner.work_items x WHERE x.master_session_id=m.id AND
   (x.finalized_at IS NULL OR x.receipt_id IS NULL OR x.result_sha256 IS NULL OR x.result_sha256!~'^[a-f0-9]{64}$'
    OR (x.state='failed' AND x.message_id IS NOT NULL)
    OR (coalesce(x.result->>'provider_calls','0')='1' AND NOT EXISTS(
     SELECT 1 FROM mission_narrative_internal.dispatch_receipts receipt
     JOIN mission_narrative_internal.dispatch_attempts attempt ON attempt.receipt_id=receipt.id
     WHERE receipt.id=x.dispatch_receipt_id AND receipt.master_session_id=m.id AND receipt.status='success' AND receipt.finalized_at IS NOT NULL
      AND attempt.status='success' AND attempt.cost_basis='exact' AND attempt.finalized_at IS NOT NULL
      AND CASE WHEN EXISTS(SELECT 1 FROM mission_narrative_internal.provider_outputs_v1 output
        WHERE output.work_id=x.id AND output.dispatch_receipt_id=receipt.id AND output.raw_sha256=x.result->>'raw_sha256') THEN true ELSE ((EXISTS(SELECT 1 FROM mission_public_owner.work_contracts_v1 legacy_contract
        WHERE legacy_contract.work_id=x.id AND legacy_contract.master_session_id=m.id
         AND legacy_contract.contract_sha256=public.combat_v2_sha256(legacy_contract.contract)
         AND legacy_contract.payload_sha256=x.payload_sha256 AND legacy_contract.definition_sha256=x.definition_sha256
         AND legacy_contract.contract->>'scope'='staff_mission' AND jsonb_typeof(legacy_contract.contract->'features')='array'
         AND NOT(legacy_contract.contract->'features'?'provider_output_retention_v1'))
        AND x.payload_sha256=public.combat_v2_sha256(x.payload)
        AND x.result->>'provider_status'='completed' AND x.result->>'outcome_uncertain'='false'
        AND x.result->>'usage_unknown'='false' AND x.result->>'raw_sha256'~'^[a-f0-9]{64}$'
        AND receipt.authority_receipt_id=x.id AND receipt.request_key=x.request_key AND receipt.dispatch_count=1
        AND attempt.actual_cost_usd=receipt.charged_cost_usd
        AND EXISTS(SELECT 1 FROM mission_narrative_internal.dispatch_audit legacy_audit
         WHERE legacy_audit.receipt_id=receipt.id AND legacy_audit.event_code='generic_finalized'
          AND legacy_audit.details->>'work_id'=x.id::text AND legacy_audit.details->>'receipt_id'=x.receipt_id::text
          AND legacy_audit.details->>'state'=x.state AND legacy_audit.details->>'result_sha256'=x.result_sha256
          AND legacy_audit.details->>'result_jsonb_sha256'=public.combat_v2_sha256(x.result)
          AND legacy_audit.details->>'stale'='false' AND legacy_audit.details->>'outcome_uncertain'='false'
          AND legacy_audit.details->'application_error_sqlstate'='null'::jsonb)
        AND((x.kind='choice' AND x.state='completed' AND x.payload->>'schema_version'='mission-generic-choice/1'
         AND EXISTS(SELECT 1 FROM mission_generic_owner.panel_choices pc
          JOIN combat_panel_private.request_receipts qr ON qr.principal_user=pc.principal_id AND qr.request_key=pc.request_key
           AND qr.viewer_envelope=pc.result AND qr.command_fingerprint=pc.command_sha256
          JOIN public.combat_v2_declarations decl ON decl.id::text=qr.viewer_envelope#>>'{receipt,declaration_id}'
           AND decl.actor_id=pc.actor_id AND decl.request_key=pc.request_key AND decl.state IN('risolta','superflua')
          JOIN public.combat_v2_rounds rnd ON rnd.id=decl.round_id AND rnd.session_id=x.encounter_id AND rnd.state='narrato'
          WHERE pc.work_id=x.id AND pc.master_session_id=m.id AND pc.consumed_at IS NOT NULL
           AND pc.command_sha256=(v_finish37_command_hashes->>x.id::text)
           AND decl.declaration_text=x.result#>>'{command,narrative_text}'))
        OR(x.kind='narration' AND x.state='completed' AND x.payload->>'schema_version'='mission-generic-narration/2'
         AND x.payload->>'mode'='combat' AND EXISTS(SELECT 1 FROM public.combat_v2_round_reports rep
          JOIN public.combat_v2_rounds rnd ON rnd.id=rep.round_id AND rnd.session_id=x.encounter_id AND rnd.state='narrato'
          JOIN public.combat_v2_narratives narr ON narr.report_id=rep.id AND narr.round_id=rnd.id AND narr.request_key=x.request_key
           AND narr.kind='fato_ia' AND narr.author_user IS NULL
          JOIN public.messages msg ON msg.id=rep.message_id AND msg.id=x.message_id AND msg.location_id=m.location_id
           AND msg.kind='fato' AND msg.recipient_user IS NULL AND msg.sender_user IS NULL AND msg.character_id IS NULL
           AND msg.body=narr.body AND msg.body=x.result->>'text'
          WHERE rep.id=x.authority_receipt_id AND rep.narration_state='pubblicata' AND NOT rep.values_written
           AND rep.mechanics_sha256=public.combat_v2_sha256(rep.mechanics)
           AND rep.mechanics_sha256=x.payload#>>'{scene_binding,report_sha256}'))
        OR(x.kind='narration' AND x.state='failed' AND x.payload->>'schema_version'='mission-generic-narration/2'
         AND x.result->'failure_codes'='["below_required_minimum"]'::jsonb
         AND EXISTS(SELECT 1 FROM LATERAL(SELECT mission_generic_owner.native_combat_writer_reissue_proof_v1(x.id,p_user) proof) recovered
          WHERE recovered.proof->>'failure_class'='completed_minimum_rejected' AND recovered.proof->>'published'='true'
           AND recovered.proof->>'failed_work_id'=x.id::text AND recovered.proof->>'payload_sha256'=x.payload_sha256
           AND recovered.proof->>'successor_publication_id'~'^[a-f0-9-]{36}$'))))
       OR (x.kind='narration' AND x.state='completed' AND x.step_key='inizio' AND x.dedupe_key='opening:'||x.event_id::text
        AND x.result->>'schema_version'='mission-generic-result/1' AND x.result->>'provider_status'='completed'
        AND x.result->'outcome_uncertain'='false'::jsonb AND x.result->>'raw_sha256'~'^[a-f0-9]{64}$'
        AND x.payload_sha256=public.combat_v2_sha256(x.payload)
        AND EXISTS(SELECT 1 FROM mission_narrative_internal.dispatch_audit opening_audit
         JOIN public.messages opening_msg ON opening_msg.id=x.message_id AND opening_msg.location_id=m.location_id
          AND opening_msg.kind='fato' AND opening_msg.recipient_user IS NULL AND opening_msg.body=x.result->>'text'
         JOIN staff_ai_quota_private.calls opening_gen ON opening_gen.producer='mission_generic_ai' AND opening_gen.source_id=receipt.id
          AND opening_gen.scope_id=m.id AND opening_gen.call_no=1 AND opening_gen.state='settled'
          AND opening_gen.settled_at IS NOT NULL AND opening_gen.charged_usd=receipt.charged_cost_usd
         WHERE opening_audit.receipt_id=receipt.id AND opening_audit.event_code='generic_finalized'
          AND opening_audit.details->>'work_id'=x.id::text AND opening_audit.details->>'receipt_id'=x.receipt_id::text
          AND opening_audit.details->>'message_id'=x.message_id::text AND opening_audit.details->>'state'='completed'
          AND opening_audit.details->'stale'='false'::jsonb AND opening_audit.details->'outcome_uncertain'='false'::jsonb
          AND opening_audit.details->>'cost_basis'='exact' AND opening_audit.details->>'result_sha256'=x.result_sha256
          AND opening_audit.details->>'result_jsonb_sha256'=public.combat_v2_sha256(x.result)))) END))))
  THEN reason:='history_unreconciled';
  ELSE
   SELECT coalesce(jsonb_agg(jsonb_build_object('work_id',x.id,'kind',x.kind,'state',x.state,'receipt_id',x.receipt_id,
    'dispatch_receipt_id',x.dispatch_receipt_id,'result_sha256',x.result_sha256,'raw_sha256',x.result->>'raw_sha256',
    'message_id',x.message_id,'disposition',CASE WHEN x.state='failed' THEN 'original_failure_preserved' ELSE 'completed' END)
    ORDER BY x.id),'[]'::jsonb) INTO items FROM mission_generic_owner.work_items x WHERE x.master_session_id=m.id;
   rev:=public.combat_v2_sha256(jsonb_build_object('schema_version','mission-narrative-scene-finish-source/1',
    'scene_id',r.id,'state_version',r.state_version,'snapshot_sha256',r.snapshot_sha256,'phase',r.current_phase_key,
    'publication_id',r.last_publication_id,'publication_sha256',r.last_publication_sha256,'final_work',w.id,
    'result_sha256',w.result_sha256,'history_sha256',public.combat_v2_sha256(items)));
   k:=mission_ai_service_owner.uuid5(m.id,'mission-staff-finish/1:'||rev||':'||r.last_publication_id::text);reason:='ready';
  END IF;
 END IF;
 RETURN jsonb_build_object('schema_version','mission-narrative-scene-finish-proof/1','master_session_id',m.id,
  'can_finish',reason='ready','reason',reason,'source_revision',rev,'publication_id',r.last_publication_id,
  'request_key',k,'history_items',items);
END $function$
