BEGIN;SET LOCAL lock_timeout='5s';SET LOCAL statement_timeout='30s';DO $bindhold$DECLARE r record;BEGIN
 IF current_user<>'postgres' THEN RAISE EXCEPTION 'BIND_HOLD_OWNER';END IF;
 LOCK TABLE mission_factory_owner.editor_release_readiness,mission_factory_owner.c464_control,mission_factory_owner.provider_authoring_runtime,mission_factory_owner.provider_authoring_admissions IN SHARE ROW EXCLUSIVE MODE;
 SELECT * INTO STRICT r FROM mission_factory_owner.editor_release_readiness WHERE singleton FOR UPDATE;
 IF r.revision_sha256<>'06c87c0d0e107c0c7bc9c56e916c0e15f221801babf0badb7739ddde6804b5b6' OR r.observed_revision_sha256<>r.revision_sha256
 OR encode(extensions.digest(convert_to(r.canonical_preimage,'UTF8'),'sha256'),'hex')<>r.revision_sha256
 OR r.canonical_preimage::jsonb#>>'{contract,version}'<>'C1264-C889-CONTEXT24-1'
 THEN RAISE EXCEPTION 'BIND_HOLD_R_CAS';END IF;
 IF mission_staff_abort_private.quiescent_v1('ce7bc0e0-c8ed-48dd-a9ec-58c02022a7b9'::uuid) IS DISTINCT FROM TRUE AND NOT((EXISTS(SELECT 1 FROM mission_generic_owner.work_items w JOIN mission_narrative_internal.dispatch_receipts nd ON nd.id=w.dispatch_receipt_id JOIN mission_generic_owner.unified_batches ub ON ub.id=w.authority_receipt_id WHERE w.id='48e1bdcd-f044-be8c-1923-54d38e7e822c'::uuid AND w.master_session_id='ce7bc0e0-c8ed-48dd-a9ec-58c02022a7b9'::uuid AND w.kind='narration' AND w.state='claimed' AND w.lease_id IS NOT NULL AND w.lease_expires_at<=clock_timestamp() AND w.authorization_id IS NULL AND w.dispatch_id IS NULL AND w.receipt_id IS NULL AND w.finalized_at IS NULL AND w.payload_sha256='da8c38c23db1c04ceaaaedfb7b5ead1b43c18c1ee60b069696ba36d832c9da78' AND w.payload_sha256=public.combat_v2_sha256(w.payload) AND ub.id='32e674f6-f1b8-4273-973e-7da88ed2c5b9'::uuid AND ub.writer_work_id=w.id AND ub.state='ready' AND ub.message_id IS NULL AND nd.id='be73eebf-d932-442d-a80f-f8c9ccdd4e1b'::uuid AND nd.master_session_id=w.master_session_id AND nd.authority_receipt_id=w.id AND nd.request_key=w.request_key AND nd.event_kind='mission_generic_event' AND nd.renderer_version='mission-generic-runtime/1' AND nd.status='claimed' AND nd.dispatch_count=0 AND nd.charged_cost_usd=0 AND nd.upper_bound_cost_usd IS NULL AND nd.finalized_at IS NULL AND nd.lease_expires_at IS NULL AND nd.lease_token_sha256 IS NULL AND NOT EXISTS(SELECT 1 FROM mission_narrative_internal.dispatch_attempts z WHERE z.receipt_id=nd.id) AND NOT EXISTS(SELECT 1 FROM mission_narrative_internal.provider_authorizations z WHERE z.receipt_id=nd.id) AND NOT EXISTS(SELECT 1 FROM mission_narrative_internal.dispatch_audit z WHERE z.receipt_id=nd.id AND z.event_code LIKE 'c8_count_%') AND NOT EXISTS(SELECT 1 FROM staff_ai_quota_private.calls z WHERE z.source_id=nd.id))) AND (not exists(select 1 from mission_generic_owner.work_items w where w.master_session_id='ce7bc0e0-c8ed-48dd-a9ec-58c02022a7b9'::uuid AND w.id<>'48e1bdcd-f044-be8c-1923-54d38e7e822c'::uuid
  and not ((w.state='failed' AND w.result->>'schema_version'='mission-count-overflow-failure/1'
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
 AND NOT EXISTS(SELECT 1 FROM mission_narrative_internal.provider_authorizations pa WHERE pa.receipt_id=d.id))) OR (w.master_session_id='ce7bc0e0-c8ed-48dd-a9ec-58c02022a7b9'::uuid AND w.state='failed' AND w.finalized_at IS NOT NULL AND w.result->>'outcome_uncertain'='false' AND mission_generic_owner.role_source_released_v4(w.authority_receipt_id) AND EXISTS(SELECT 1 FROM mission_narrative_internal.dispatch_receipts d WHERE d.id=w.dispatch_receipt_id AND d.status IN('success','fallback') AND d.finalized_at IS NOT NULL AND d.dispatch_count=1 AND EXISTS(SELECT 1 FROM staff_ai_quota_private.calls settled WHERE settled.source_id=d.id AND settled.scope_id=w.master_session_id AND settled.call_no=1 AND settled.state='settled' AND settled.charged_usd=d.charged_cost_usd))) OR (w.state='completed' and exists(select 1 from mission_narrative_internal.dispatch_receipts d where d.id=w.dispatch_receipt_id and d.master_session_id='ce7bc0e0-c8ed-48dd-a9ec-58c02022a7b9'::uuid and d.status='success' and d.finalized_at is not null) and not exists(select 1 from mission_narrative_internal.dispatch_attempts a where a.receipt_id=w.dispatch_receipt_id and (a.status<>'success' or a.finalized_at is null))) or (w.state='ready' and w.lease_id is null and w.dispatch_receipt_id is null
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
 where ad.master_session_id='ce7bc0e0-c8ed-48dd-a9ec-58c02022a7b9'::uuid and ad.c7_budget_enforced
 and ad.c7_budget_qualification_sha256 ~ '^[0-9a-f]{64}$'
 and ms.owner_kind='ai_service' and l.is_test and l.is_active)
 and exists(select 1 from mission_narrative_internal.dispatch_receipts d
 where d.id=w.dispatch_receipt_id and d.master_session_id='ce7bc0e0-c8ed-48dd-a9ec-58c02022a7b9'::uuid and d.authority_receipt_id=w.id
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
 and not exists(select 1 from public.combat_v2_sessions s where s.master_session_id='ce7bc0e0-c8ed-48dd-a9ec-58c02022a7b9'::uuid
  and (public.combat_v2_values_written(s.id) is distinct from false or combat_panel_private.uses_simulated_pools(s.id) is distinct from true)))) THEN RAISE EXCEPTION 'BIND_HOLD_INFLIGHT';END IF;
 IF (SELECT release_sha256 FROM mission_factory_owner.c464_control WHERE singleton)<>r.revision_sha256
 OR (SELECT release_sha256 FROM mission_factory_owner.provider_authoring_runtime WHERE singleton)<>r.revision_sha256
 OR EXISTS(SELECT 1 FROM mission_factory_owner.provider_authoring_admissions WHERE release_sha256<>r.revision_sha256)
 THEN RAISE EXCEPTION 'BIND_HOLD_CFG_CAS';END IF;
 UPDATE mission_factory_owner.c464_control SET runtime_enabled=false WHERE singleton AND release_sha256=r.revision_sha256;
 UPDATE mission_factory_owner.provider_authoring_runtime SET enabled=false WHERE singleton AND release_sha256=r.revision_sha256;
 UPDATE mission_factory_owner.provider_authoring_admissions SET enabled=false WHERE release_sha256=r.revision_sha256
 AND actor_user IN('f0856d53-83a6-4de0-bc0c-12c87916e665'::uuid,'b4952ed5-5ce0-49c0-9f2b-8fd5dcd89b4b'::uuid)
 AND location_id='0b85f354-9cdb-47e1-baf9-3d266bb7e06b'::uuid;
END $bindhold$;COMMIT;
