CREATE OR REPLACE FUNCTION mission_staff_abort_private.quiescent_v1(p_session uuid)
 RETURNS boolean
 LANGUAGE sql
 STABLE SECURITY DEFINER
 SET search_path TO ''
AS $function$
 select not exists(select 1 from mission_generic_owner.work_items w where w.master_session_id=p_session
  and not ((mission_generic_owner.c1266_generation_timeout_terminal_proof_v1(w.id)IS NOT NULL) OR (mission_generic_owner.c1266_count_terminal_proof_v1(w.id,true)IS NOT NULL) OR ((w.id='d8b37311-6010-4a07-95d3-5e65a33c756d'::uuid AND w.master_session_id='9ac00210-4c88-4c0c-a443-95e3d6740a28'::uuid
 AND w.kind='director'AND w.payload->>'schema_version'='mission-director-work/4'AND w.state='failed'
 AND w.finalized_at IS NOT NULL AND w.receipt_id IS NOT NULL AND w.message_id IS NULL
 AND w.authorization_id IS NULL AND w.dispatch_id IS NULL AND w.lease_expires_at<=clock_timestamp()
 AND w.payload_sha256=public.combat_v2_sha256(w.payload)AND w.result_sha256=public.combat_v2_sha256(w.result)
 AND w.result->>'schema_version'='mission-input-count-unknown-failure/1'
 AND w.result->'failure_codes'='["MISSION_INPUT_COUNT_UNKNOWN"]'::jsonb
 AND w.result->>'outcome_uncertain'='false'AND w.result->>'count_outcome_unknown'='true'
 AND w.result->>'count_http_calls'='1'AND w.result->>'generation_http_calls'='0'
 AND w.result->>'count_cost_state'='unknown_billable'AND w.result->'count_reserve_usd'='0.0124'::jsonb
 AND mission_generic_owner.c1266_historical_work_v1(w.id)->>'execution_context'='staff_mission'
 AND mission_generic_owner.c1266_historical_work_v1(w.id)#>>'{admission,resource_scope}'='staff_simulation'
 AND NOT EXISTS(SELECT 1 FROM mission_generic_owner.unified_batches cleanup_batch WHERE cleanup_batch.master_session_id=w.master_session_id)
 AND EXISTS(SELECT 1 FROM mission_narrative_internal.dispatch_receipts cleanup_receipt
 JOIN mission_narrative_internal.dispatch_audit cleanup_terminal ON cleanup_terminal.receipt_id=cleanup_receipt.id AND cleanup_terminal.event_code='generic_count_unknown_terminal'
 JOIN mission_narrative_internal.dispatch_audit cleanup_proof ON cleanup_proof.receipt_id=cleanup_receipt.id AND cleanup_proof.event_code='c8_count_unknown'
 JOIN staff_ai_quota_private.calls cleanup_count ON cleanup_count.id=(cleanup_terminal.details->>'count_ticket')::uuid
 WHERE cleanup_receipt.id=w.dispatch_receipt_id AND cleanup_receipt.master_session_id=w.master_session_id AND cleanup_receipt.authority_receipt_id=w.id
 AND cleanup_receipt.status='failed'AND cleanup_receipt.finalized_at IS NOT NULL AND cleanup_receipt.dispatch_count=0
 AND cleanup_receipt.charged_cost_usd=0 AND cleanup_receipt.upper_bound_cost_usd IS NULL
 AND cleanup_terminal.details->>'schema_version'='c1266-count-unknown-terminal/1'
 AND cleanup_terminal.details->>'work_id'=w.id::text AND cleanup_terminal.details->>'receipt_id'=w.receipt_id::text
 AND cleanup_terminal.details->>'payload_sha256'=w.payload_sha256 AND cleanup_terminal.details->>'result_sha256'=w.result_sha256
 AND cleanup_terminal.details->>'measurement_id'=cleanup_proof.details->>'measurement_id'
 AND cleanup_terminal.details->>'generation_request_sha256'=cleanup_proof.details->>'generation_request_sha256'
 AND cleanup_proof.details->>'state'='unknown'AND cleanup_proof.details->>'generation_allowed'='false'
 AND cleanup_proof.details->>'count_http_calls'='1'AND cleanup_proof.details->>'generation_http_calls'='0'
 AND cleanup_count.producer='mission_generic_ai'AND cleanup_count.source_id=cleanup_receipt.id
 AND cleanup_count.scope_id=w.master_session_id AND cleanup_count.call_no=2 AND cleanup_count.state='unknown_billable'
 AND cleanup_count.charged_usd IS NULL AND cleanup_count.reserved_usd=0.0124
 AND NOT EXISTS(SELECT 1 FROM mission_narrative_internal.dispatch_attempts cleanup_attempt WHERE cleanup_attempt.receipt_id=cleanup_receipt.id)
 AND NOT EXISTS(SELECT 1 FROM mission_narrative_internal.provider_authorizations cleanup_auth WHERE cleanup_auth.receipt_id=cleanup_receipt.id)
 AND NOT EXISTS(SELECT 1 FROM staff_ai_quota_private.calls cleanup_gen WHERE cleanup_gen.source_id=cleanup_receipt.id AND cleanup_gen.scope_id=w.master_session_id AND cleanup_gen.call_no=1)))IS TRUE) OR ((w.state='failed' AND w.kind='director'
 AND w.payload->>'schema_version'='mission-director-work/4'
 AND w.finalized_at IS NOT NULL AND w.receipt_id IS NOT NULL AND w.message_id IS NULL
 AND w.lease_expires_at IS NOT NULL AND w.lease_expires_at<=clock_timestamp()
 AND w.result->>'ok'='false' AND w.result->>'outcome_uncertain'='false'
 AND w.result->'failure_codes'='["MISSION_ROLE_ROLE_EVIDENCE_UNBOUND"]'::jsonb
 AND jsonb_typeof(w.result->'decision')='null' AND jsonb_typeof(w.result->'command')='null'
 AND EXISTS(SELECT 1 FROM mission_narrative_internal.dispatch_audit terminal_final_audit WHERE terminal_final_audit.receipt_id=w.dispatch_receipt_id AND terminal_final_audit.event_code='generic_finalized' AND terminal_final_audit.details->>'work_id'=w.id::text AND terminal_final_audit.details->>'receipt_id'=w.receipt_id::text AND terminal_final_audit.details->>'result_sha256'=w.result_sha256 AND terminal_final_audit.details->>'result_jsonb_sha256'=public.combat_v2_sha256(w.result) AND terminal_final_audit.details->>'state'='failed' AND terminal_final_audit.details->>'cost_basis'='exact' AND terminal_final_audit.details->>'stale'='false' AND terminal_final_audit.details->>'outcome_uncertain'='false' AND jsonb_typeof(terminal_final_audit.details->'message_id')='null' AND jsonb_typeof(terminal_final_audit.details->'command_receipt')='null' AND jsonb_typeof(terminal_final_audit.details->'application_error_code')='null' AND jsonb_typeof(terminal_final_audit.details->'application_error_sqlstate')='null')
 AND w.payload_sha256=public.combat_v2_sha256(w.payload)
 -- Only immutable named C1266 protected Staff authority: live availability may be OFF for normal cleanup.
 AND mission_generic_owner.c1266_historical_work_v1(w.id)->>'execution_context'='staff_mission'
 AND mission_generic_owner.c1266_historical_work_v1(w.id)#>>'{admission,kind}'='staff_finite'
 AND mission_generic_owner.c1266_historical_work_v1(w.id)#>>'{admission,resource_scope}'='staff_simulation'
 AND mission_generic_owner.c1266_historical_work_v1(w.id)#>>'{admission,location_id}'='0b85f354-9cdb-47e1-baf9-3d266bb7e06b'
 AND EXISTS(SELECT 1 FROM public.master_v2_sessions protected_master
  JOIN public.locations protected_location ON protected_location.id=protected_master.location_id
  WHERE protected_master.id=w.master_session_id AND protected_master.owner_kind='ai_service'
  AND protected_master.location_id='0b85f354-9cdb-47e1-baf9-3d266bb7e06b'
  AND protected_location.is_active AND protected_location.is_test)
 -- A failed validation before a decision cannot have issued a writer or any unified batch/effect.
 AND NOT EXISTS(SELECT 1 FROM mission_generic_owner.unified_batches issued_batch
  WHERE issued_batch.master_session_id=w.master_session_id AND issued_batch.decision_work_id=w.id)
 AND NOT EXISTS(SELECT 1 FROM mission_generic_owner.work_items issued_writer
  WHERE issued_writer.master_session_id=w.master_session_id AND issued_writer.kind='narration'
  AND issued_writer.authority_receipt_id=w.authority_receipt_id)
 AND EXISTS(SELECT 1 FROM mission_narrative_internal.dispatch_receipts paid_receipt
  JOIN mission_narrative_internal.provider_authorizations paid_authorization
   ON paid_authorization.id=w.authorization_id AND paid_authorization.receipt_id=paid_receipt.id
  JOIN mission_narrative_internal.dispatch_attempts paid_attempt
   ON paid_attempt.id=paid_authorization.attempt_id AND paid_attempt.receipt_id=paid_receipt.id
  WHERE paid_receipt.id=w.dispatch_receipt_id AND paid_receipt.master_session_id=w.master_session_id
  AND paid_receipt.authority_receipt_id=w.id AND paid_receipt.request_key=w.request_key
  AND paid_receipt.event_kind='mission_generic_event' AND paid_receipt.renderer_version='mission-generic-runtime/1'
  AND paid_receipt.status='success' AND paid_receipt.finalized_at IS NOT NULL AND paid_receipt.dispatch_count=1
  AND paid_receipt.charged_cost_usd IS NOT NULL AND paid_receipt.charged_cost_usd>=0
  AND paid_receipt.charged_cost_usd<=paid_receipt.upper_bound_cost_usd
  AND paid_attempt.status='success' AND paid_attempt.finalized_at IS NOT NULL
  AND NOT EXISTS(SELECT 1 FROM mission_narrative_internal.dispatch_attempts unresolved_attempt
   WHERE unresolved_attempt.receipt_id=paid_receipt.id
   AND(unresolved_attempt.status<>'success' OR unresolved_attempt.finalized_at IS NULL))
  AND EXISTS(SELECT 1 FROM staff_ai_quota_private.calls settled_generation
   WHERE settled_generation.source_id=paid_receipt.id AND settled_generation.scope_id=w.master_session_id
   AND settled_generation.call_no=1 AND settled_generation.state='settled'
   AND settled_generation.charged_usd=paid_receipt.charged_cost_usd))) IS TRUE) OR (w.state='failed' AND w.result->>'schema_version'='mission-count-overflow-failure/1'
 AND w.result->'failure_codes'='["MISSION_INPUT_COUNT_OVERFLOW"]'::jsonb
 AND w.result->>'outcome_uncertain'='false' AND w.result->>'provider_calls'='0'
 AND w.authorization_id IS NULL AND w.dispatch_id IS NULL AND w.finalized_at IS NOT NULL AND w.receipt_id IS NOT NULL
 AND w.result_sha256=public.combat_v2_sha256(w.result) AND w.payload_sha256=public.combat_v2_sha256(w.payload)
 AND w.master_session_id='ce7bc0e0-c8ed-48dd-a9ec-58c02022a7b9'::uuid
 AND EXISTS(SELECT 1 FROM mission_narrative_internal.dispatch_receipts d
 JOIN mission_narrative_internal.dispatch_audit a ON a.receipt_id=d.id AND a.event_code='generic_count_overflow_terminal'
 JOIN mission_narrative_internal.dispatch_audit cp ON cp.receipt_id=d.id AND cp.event_code='c8_count_success'
 JOIN staff_ai_quota_private.calls ct ON ct.id=(a.details->>'count_ticket')::uuid
 WHERE d.id=w.dispatch_receipt_id AND d.master_session_id=w.master_session_id AND d.authority_receipt_id=w.id
 AND d.status='failed' AND d.dispatch_count=0 AND d.finalized_at IS NOT NULL AND d.charged_cost_usd=0 AND d.upper_bound_cost_usd IS NULL
 AND a.details->>'schema_version'='c1264-count-overflow-terminal/1' AND a.details->>'work_id'=w.id::text
 AND a.details->>'receipt_id'=w.receipt_id::text AND a.details->>'result_sha256'=w.result_sha256
 AND a.details->>'source_window_id'=w.authority_receipt_id::text AND a.details->>'payload_sha256'=w.payload_sha256
 AND cp.details->>'measurement_id'=a.details->>'measurement_id' AND cp.details->>'state'='success'
 AND cp.details->>'generation_allowed'='false' AND (cp.details->>'input_tokens')::integer>12000
 AND cp.details->>'max_input_tokens'='12000' AND cp.details->>'generation_http_calls'='0'
 AND ct.producer='mission_generic_ai' AND ct.scope_id=w.master_session_id AND ct.source_id=d.id AND ct.call_no=2
 AND ct.state='unknown_billable' AND ct.charged_usd IS NULL AND ct.reserved_usd=0.0112
 AND NOT EXISTS(SELECT 1 FROM mission_narrative_internal.dispatch_attempts da WHERE da.receipt_id=d.id)
 AND NOT EXISTS(SELECT 1 FROM mission_narrative_internal.provider_authorizations pa WHERE pa.receipt_id=d.id))) OR (w.master_session_id='ce7bc0e0-c8ed-48dd-a9ec-58c02022a7b9'::uuid AND w.state='failed' AND w.finalized_at IS NOT NULL AND w.result->>'outcome_uncertain'='false' AND mission_generic_owner.role_source_released_v4(w.authority_receipt_id) AND EXISTS(SELECT 1 FROM mission_narrative_internal.dispatch_receipts d WHERE d.id=w.dispatch_receipt_id AND d.status IN('success','fallback') AND d.finalized_at IS NOT NULL AND d.dispatch_count=1 AND EXISTS(SELECT 1 FROM staff_ai_quota_private.calls settled WHERE settled.source_id=d.id AND settled.scope_id=w.master_session_id AND settled.call_no=1 AND settled.state='settled' AND settled.charged_usd=d.charged_cost_usd))) OR (w.state='completed' and exists(select 1 from mission_narrative_internal.dispatch_receipts d where d.id=w.dispatch_receipt_id and d.master_session_id=p_session and d.status='success' and d.finalized_at is not null) and not exists(select 1 from mission_narrative_internal.dispatch_attempts a where a.receipt_id=w.dispatch_receipt_id and (a.status<>'success' or a.finalized_at is null))) or (w.state='ready' and w.lease_id is null and w.dispatch_receipt_id is null
       and w.authorization_id is null and w.dispatch_id is null)
 or (w.state='failed' and w.authorization_id is null and w.dispatch_id is null
 and w.finalized_at is not null and w.receipt_id is not null
 and w.payload_sha256=public.combat_v2_sha256(w.payload)
 and w.result_sha256=public.combat_v2_sha256(w.result)
 and w.result=jsonb_build_object('schema_version','mission-generic-pre-provider-failure/1',
 'work_id',w.id,'master_session_id',w.master_session_id,'event_id',w.event_id,'request_key',w.request_key,
 'revision',w.revision,'ok',false,'failure_code',w.result->>'failure_code','provider_calls',0,'charged_cost_usd',0)
 and w.result->>'failure_code' in('work_validation_failed','request_validation_failed')
 and exists(select 1 from mission_generic_owner.dispatch_admissions ad
 join public.master_v2_sessions ms on ms.id=ad.master_session_id
 join public.locations l on l.id=ms.location_id
 where ad.master_session_id=p_session and ad.c7_budget_enforced
 and ad.c7_budget_qualification_sha256 ~ '^[0-9a-f]{64}$'
 and ms.owner_kind='ai_service' and l.is_test and l.is_active)
 and exists(select 1 from mission_narrative_internal.dispatch_receipts d
 where d.id=w.dispatch_receipt_id and d.master_session_id=p_session and d.authority_receipt_id=w.id
 and d.request_key=w.request_key and d.event_kind='mission_generic_event'
 and d.renderer_version='mission-generic-runtime/1' and d.status='failed' and d.finalized_at is not null
 and d.dispatch_count=0 and d.charged_cost_usd=0 and d.upper_bound_cost_usd=0
 and d.lease_token_sha256 is null and d.lease_expires_at is null
 and not exists(select 1 from mission_narrative_internal.dispatch_attempts da where da.receipt_id=d.id)
 and not exists(select 1 from mission_narrative_internal.provider_authorizations pa where pa.receipt_id=d.id)
 and exists(select 1 from mission_narrative_internal.dispatch_audit audit
 where audit.receipt_id=d.id and audit.event_code='generic_pre_provider_failed'
 and audit.details=jsonb_build_object('work_id',w.id,'receipt_id',w.receipt_id,
 'failure_code',w.result->>'failure_code','provider_calls',0,'charged_cost_usd',0,'result_sha256',w.result_sha256))))))
 and not exists(select 1 from public.combat_v2_sessions s where s.master_session_id=p_session
  and (public.combat_v2_values_written(s.id) is distinct from false or combat_panel_private.uses_simulated_pools(s.id) is distinct from true))
$function$
