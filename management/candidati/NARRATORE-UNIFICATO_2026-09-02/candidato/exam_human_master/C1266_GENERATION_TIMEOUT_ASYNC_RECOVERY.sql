-- Conservative async recovery; deactivates the new observer and restores only two source bodies.
-- No DROP, DELETE, reset, refund, prior Root enable/renewal or user-data mutation.
BEGIN;
SELECT pg_catalog.pg_advisory_xact_lock(pg_catalog.hashtextextended('C1266:GENERIC-AI:AVAILABILITY',0));
DO $staff_hold$
BEGIN
 IF NOT EXISTS(SELECT 1 FROM public.master_v2_sessions m WHERE m.id='5bb8dc0d-fe30-4ff5-bb50-1cfda2aee780'::uuid
 AND m.stato='annullata' AND m.closed_at IS NOT NULL AND m.close_reason='staff_simulation_abort')
 OR NOT EXISTS(SELECT 1 FROM mission_staff_abort_private.operations op WHERE op.master_session_id='5bb8dc0d-fe30-4ff5-bb50-1cfda2aee780'::uuid AND op.state='committed'
 AND op.receipt->>'status'='annullata' AND op.receipt->>'resources_protected'='true')
 THEN RAISE EXCEPTION 'C1266_ASYNC_OWN_TECHNICAL_ABORT_REQUIRED' USING ERRCODE='55000';END IF;
 IF (SELECT mode FROM mission_generic_owner.runtime_policy WHERE singleton) IS DISTINCT FROM 'off'
 OR (SELECT enabled FROM mission_generic_owner.provider_policy WHERE singleton) IS DISTINCT FROM false
 OR (SELECT runtime_enabled FROM mission_factory_owner.c464_control WHERE singleton) IS DISTINCT FROM false
 OR EXISTS(SELECT 1 FROM mission_factory_owner.provider_authoring_admissions aa
 WHERE aa.location_id='0b85f354-9cdb-47e1-baf9-3d266bb7e06b'::uuid AND aa.actor_user IN(
 'f0856d53-83a6-4de0-bc0c-12c87916e665'::uuid,'b4952ed5-5ce0-49c0-9f2b-8fd5dcd89b4b'::uuid) AND aa.enabled)
 OR EXISTS(SELECT 1 FROM mission_generic_owner.dispatch_admissions ad WHERE ad.master_session_id='5bb8dc0d-fe30-4ff5-bb50-1cfda2aee780'::uuid AND ad.enabled)
 THEN RAISE EXCEPTION 'C1266_ASYNC_FRESH_HOLD_REQUIRED' USING ERRCODE='55000';END IF;
 IF EXISTS(SELECT 1 FROM mission_generic_owner.work_items w WHERE w.state IN('claimed','authorized','provider_started')
 AND w.lease_expires_at>statement_timestamp())
 OR EXISTS(SELECT 1 FROM mission_narrative_internal.dispatch_receipts d WHERE d.status IN('reserved','authorized','provider_started')
 AND d.finalized_at IS NULL AND d.lease_expires_at>statement_timestamp())
 THEN RAISE EXCEPTION 'C1266_ASYNC_ACTIVE_PROVIDER_WORK' USING ERRCODE='55000';END IF;
END $staff_hold$;
DO $recovery_guard$
BEGIN
 IF md5((SELECT prosrc FROM pg_catalog.pg_proc WHERE oid=to_regprocedure('public.mission_generic_dispatch_claim_v1(uuid,jsonb)'))) IS DISTINCT FROM '26513cd37a169bd43f7b52d75f3e9111'
 OR md5((SELECT prosrc FROM pg_catalog.pg_proc WHERE oid=to_regprocedure('public.mission_generic_dispatch_authorize_v1(uuid,uuid,text,jsonb)'))) IS DISTINCT FROM '6b63629512c5e22ae4e51ec741cbc946'
 OR md5((SELECT prosrc FROM pg_catalog.pg_proc WHERE oid=to_regprocedure('public.mission_generic_dispatch_async_status_v1(uuid,jsonb)'))) IS DISTINCT FROM '411b1525297fa7e983abab4a8bb1ab5f'
 THEN RAISE EXCEPTION 'C1266_ASYNC_RECOVERY_DRIFT' USING ERRCODE='40001';END IF;
END $recovery_guard$;
CREATE OR REPLACE FUNCTION public.mission_generic_dispatch_claim_v1(p_user uuid, p_request jsonb)
 RETURNS jsonb
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO ''
AS $function$
declare w mission_generic_owner.work_items;a mission_generic_owner.dispatch_admissions;pol mission_narrative_internal.runtime_policy;
 d mission_narrative_internal.dispatch_receipts;
 dr uuid;env jsonb;fp text;limits jsonb;staff_calls bigint; narrative_contract jsonb;c7_budget jsonb;
c26_proof jsonb;c5_proof jsonb;
begin
 perform mission_ai_board_owner.service_only();
 -- C1266_AVAILABILITY_COORD: shared before mutation locks; xact lifetime.
 PERFORM pg_catalog.pg_advisory_xact_lock_shared(pg_catalog.hashtextextended('C1266:GENERIC-AI:AVAILABILITY',0));
 
 -- C9: freeze policy DML through proof, Native reserve and authorization.
 LOCK TABLE mission_narrative_internal.runtime_policy IN SHARE MODE;
 perform mission_generic_owner.dispatch_user((p_request->>'master_session_id')::uuid,p_user);
 if (p_request->>'master_session_id')='b70b23cf-bad8-475d-a56a-d9c549e35d84' then
   raise exception 'MRS_STAFF_SUNA_TICK_PAUSED' using errcode='55000';
 end if;
 perform 1 from mission_generic_owner.role_window_cursors
   where master_session_id=(p_request->>'master_session_id')::uuid for update;
 perform 1 from public.master_v2_sessions where id=(p_request->>'master_session_id')::uuid for update;
 select * into strict w from mission_generic_owner.work_items where master_session_id=(p_request->>'master_session_id')::uuid
 and event_id=(p_request->>'event_id')::uuid and request_key=(p_request->>'request_key')::uuid and revision=(p_request->>'expected_revision')::bigint for update;
 if mission_generic_owner.count_overflow_terminal_v1(w.id,p_user) then return jsonb_build_object('state','failed','granted_now',false);end if;
 if w.state='claimed' and w.master_session_id='ce7bc0e0-c8ed-48dd-a9ec-58c02022a7b9'::uuid AND (w.id<>'48e1bdcd-f044-be8c-1923-54d38e7e822c'::uuid OR w.lease_expires_at IS NULL OR w.lease_expires_at>clock_timestamp()) then return jsonb_build_object('state','claimed','granted_now',false);end if;
 IF w.id='48e1bdcd-f044-be8c-1923-54d38e7e822c'::uuid AND (mission_generic_owner.c8_context24_scope_v1(w.id) IS DISTINCT FROM TRUE OR mission_generic_owner.c726_factory_staff_runtime_v1(w.master_session_id) IS DISTINCT FROM TRUE) THEN RAISE EXCEPTION 'C889_CONTEXT24_RUNTIME_CLOSED' USING ERRCODE='42501';END IF;
 perform mission_generic_owner.role_dispatch_assert_v4(w.id);
 IF mission_generic_owner.c1266_opening_named_v1(w.master_session_id) THEN
  c5_proof:=mission_generic_owner.c1266_execution_authority_v1(w.master_session_id,false,true);
  IF c5_proof IS NULL OR mission_generic_owner.flow_scope_enabled(w.master_session_id) IS DISTINCT FROM TRUE THEN RAISE EXCEPTION 'C1266_CLAIM5_CLOSED' USING ERRCODE='42501';END IF;
 END IF;
 c26_proof:=mission_generic_owner.c1266_clean_staff_admission_v1(w.master_session_id,true,true);
 IF EXISTS(SELECT 1 FROM mission_generic_owner.dispatch_admissions ad
 JOIN mission_factory_owner.editor_release_readiness rr ON rr.singleton
 WHERE ad.master_session_id=w.master_session_id
 AND ad.c7_budget_qualification_sha256=rr.canonical_preimage::jsonb#>>'{config,c1266_clean_staff,c7_budget_qualification_sha256}')
 AND c26_proof IS NULL THEN RAISE EXCEPTION 'C1266_CLEAN_RUNTIME_CLOSED' USING ERRCODE='42501';END IF;
 IF EXISTS(SELECT 1 FROM public.master_v2_sessions s726 WHERE s726.id=w.master_session_id AND s726.owner_kind='ai_service' AND s726.location_id='0b85f354-9cdb-47e1-baf9-3d266bb7e06b'::uuid AND (EXISTS(SELECT 1 FROM mission_generic_owner.flow_staff_sessions f726 WHERE f726.master_session_id=s726.id AND f726.enabled) OR EXISTS(SELECT 1 FROM mission_factory_owner.quest_run_sources q726 WHERE q726.session_id=s726.id AND q726.availability_scope='staff' AND q726.execution_context='staff_simulation'))) AND NOT mission_academy_owner.staff_carrier_runtime(w.master_session_id) AND NOT mission_generic_owner.c726_factory_staff_runtime_v1(w.master_session_id) THEN RAISE EXCEPTION 'C726_FACTORY_STAFF_SCOPE_CLOSED' USING ERRCODE='42501';END IF;

 if w.state='failed' and w.kind='choice' and public.combat_v2_is_service()
   and mission_academy_owner.staff_carrier_runtime(w.master_session_id) then
   env:=mission_generic_owner.staff_cached_choice_recover(w.id);
   if env->>'state'='completed' then
     return jsonb_build_object('state','completed','granted_now',false);
   end if;
 end if;
 if w.state='claimed' and w.lease_expires_at<=clock_timestamp() then
  select * into d from mission_narrative_internal.dispatch_receipts where id=w.dispatch_receipt_id for update;
  if found and w.authorization_id is null and w.dispatch_id is null
   and d.status='claimed' and d.dispatch_count=0 and d.charged_cost_usd=0
   and d.upper_bound_cost_usd is null and d.master_session_id=w.master_session_id
   and d.authority_receipt_id=w.id and d.event_kind='mission_generic_event'
   and d.renderer_version='mission-generic-runtime/1' and d.request_key=w.request_key
   and not exists(select 1 from mission_narrative_internal.dispatch_attempts where receipt_id=d.id)
   and not exists(select 1 from mission_narrative_internal.provider_authorizations where receipt_id=d.id)
   and not exists(select 1 from mission_narrative_internal.dispatch_audit where receipt_id=d.id and event_code='c8_count_started')
  then
   update mission_narrative_internal.dispatch_receipts set updated_at=clock_timestamp() where id=d.id;
   insert into mission_narrative_internal.dispatch_audit(receipt_id,event_code,details)
   values(d.id,'generic_pre_provider_claim_reissued',jsonb_build_object('work_id',w.id,
    'provider_calls',0,'charged_cost_usd',0,'expired_lease_id',w.lease_id));
   update mission_generic_owner.work_items set state='ready',
    lease_id=null,lease_expires_at=null where id=w.id returning * into w;
   dr:=d.id;
  end if;
 end if;
 if w.state<>'ready' then return jsonb_build_object('state',w.state,'granted_now',false);end if;
 c7_budget:=mission_generic_owner.c7_run_budget_v1(w.master_session_id,true,null);
 if c7_budget->>'allowed'='false' then
  perform mission_generic_owner.c7_run_budget_stop_v1(w.master_session_id);
  return jsonb_build_object('state','ready','granted_now',false,'reason_code','MGPG_C7_RUN_BUDGET_STOP','provider_calls_remaining',0);
 end if;
 perform mission_generic_owner.work_assert(w);
 perform mission_generic_owner.assert_runtime(w.master_session_id);
 select * into strict a from mission_generic_owner.dispatch_admissions where master_session_id=w.master_session_id for share;
 select * into strict pol from mission_narrative_internal.runtime_policy where singleton for share;
 perform mission_generic_owner.provider_ready(w.id);
 -- Byte transport limits remain independent from Native token policy.
 pol.max_input_tokens:=(mission_generic_owner.capacity()->>'input_capacity_bytes')::integer;
 if not a.enabled or (not mission_academy_owner.staff_carrier_runtime(w.master_session_id) and mission_generic_owner.c1266_staff_scene_policy_v1(w.master_session_id) IS NULL and a.calls_authorized>=a.call_limit) or (not pol.enabled and w.master_session_id<>'93d78313-abde-4087-9eb7-7b96bc0fa089'::uuid and not mission_academy_owner.staff_carrier_runtime(w.master_session_id) and not mission_generic_owner.c726_factory_staff_runtime_v1(w.master_session_id)) or pol.model<>'gpt-6-luna' or pol.reasoning_effort<>'high' or pol.store
 then raise exception 'MGD_PROVIDER_CLOSED';end if;
 if mission_academy_owner.staff_carrier_runtime(w.master_session_id) then
  select count(*) into staff_calls
  from mission_narrative_internal.dispatch_receipts receipt
  join public.master_v2_sessions s on s.id=receipt.master_session_id
  where receipt.event_kind='mission_generic_event' and receipt.renderer_version='mission-generic-runtime/1'
    and receipt.created_at>=clock_timestamp()-interval '30 days'
    and s.location_id='0b85f354-9cdb-47e1-baf9-3d266bb7e06b'::uuid and s.owner_kind='ai_service'
    and exists(select 1 from mission_narrative_internal.dispatch_attempts t where t.receipt_id=receipt.id);
  if staff_calls>=1000 then raise exception 'MGPG_STAFF_ROLLING_BUDGET_EXHAUSTED';end if;
 end if;
 limits:=jsonb_build_object('provider_calls_remaining',case when mission_generic_owner.c1266_staff_scene_policy_v1(w.master_session_id) IS NOT NULL AND c7_budget->>'allowed'='true' THEN 1 /* one legal generation HTTP for this work; not a scene ceiling/sentinel */ when c7_budget->>'enforced'='true' then least((c7_budget->>'remaining_calls')::integer/2,a.call_limit-a.calls_authorized) when staff_calls is null then a.call_limit-a.calls_authorized else 1000-staff_calls end,'max_output_tokens',least(20000,pol.max_output_tokens),
  'max_input_bytes',case when w.kind='director' and (mission_academy_owner.staff_carrier_runtime(w.master_session_id) OR mission_generic_owner.c726_factory_staff_runtime_v1(w.master_session_id)) then 65536 else least(49152,pol.max_input_tokens) end,'max_request_bytes',case when w.kind='narration' and (mission_academy_owner.staff_carrier_runtime(w.master_session_id) OR mission_generic_owner.c726_factory_staff_runtime_v1(w.master_session_id)) then 131072 when w.kind='director' and (mission_academy_owner.staff_carrier_runtime(w.master_session_id) OR mission_generic_owner.c726_factory_staff_runtime_v1(w.master_session_id)) then 65536 else least(65536,pol.max_input_tokens) end,
  'transport_max_chars',5000,'provider_timeout_ms',120000);
 IF c26_proof IS NOT NULL THEN limits:=limits||jsonb_build_object('max_input_bytes',case when w.kind='director' then 65536 else 49152 end,'max_request_bytes',case when w.kind='narration' then 131072 else 65536 end);END IF;
 if octet_length(w.payload::text)>(limits->>'max_input_bytes')::integer then raise exception 'MGD_CONTEXT_OVERFLOW';end if;
 narrative_contract:=mission_public_owner.work_contract_issue_v1(w.id);
 env:=jsonb_build_object('work_id',w.id,'master_session_id',w.master_session_id,'event_id',w.event_id,'authority_receipt_id',w.authority_receipt_id,
  'payload_sha256',w.payload_sha256,'definition_sha256',w.definition_sha256,'revision',w.revision);
 if narrative_contract is not null then env:=env||jsonb_build_object('narrative_admission',narrative_contract);end if;
 fp:=mission_internal.fingerprint(p_request);
 if dr is null then
 insert into mission_narrative_internal.dispatch_receipts(master_session_id,authority_receipt_id,event_kind,renderer_version,request_key,
  request_fingerprint,authority_sha256,envelope,envelope_sha256,status)
 values(w.master_session_id,w.id,'mission_generic_event','mission-generic-runtime/1',w.request_key,fp,
  public.combat_v2_sha256(env),env,public.combat_v2_sha256(env),'claimed') returning id into dr;
 end if;
 update mission_generic_owner.work_items set state='claimed',dispatch_receipt_id=dr,lease_id=gen_random_uuid(),
  lease_expires_at=clock_timestamp()+interval '180 seconds' where id=w.id returning * into w;
 return jsonb_build_object('state','claimed','granted_now',true,'work',jsonb_build_object('schema_version','mission-generic-work/1',
  'work_id',w.id,'master_session_id',w.master_session_id,'event_id',w.event_id,'request_key',w.request_key,'revision',w.revision,
  'step_key',w.step_key,'run_control_version',w.run_control_version,'definition_sha256',w.definition_sha256,
  'encounter_id',w.encounter_id,'authority_receipt_id',w.authority_receipt_id,'kind',w.kind,'lease_id',w.lease_id,
  'server_now',clock_timestamp(),'lease_expires_at',w.lease_expires_at,'payload_sha256',w.payload_sha256,'payload',w.payload,'limits',limits,
  'narrative_admission',narrative_contract,'narrative_admission_sha256',case when narrative_contract is not null then public.combat_v2_sha256(narrative_contract) end,
   'provider_input_contract',case when c5_proof IS NOT NULL THEN mission_generic_owner.c1266_provider_input_v1(w.id,limits) ELSE case when c26_proof IS NOT NULL then jsonb_build_object(
 'schema_version','mission-generic-provider-input/4','input_tokens_limit',24000,'policy_version',pol.policy_version,'http_calls_per_generation',2,
 'scope',jsonb_build_object('schema_version','c1266-clean-staff-work-scope/1','execution_context','staff_mission',
 'master_session_id',w.master_session_id,'work_id',w.id,'event_id',w.event_id,'request_key',w.request_key,'revision',w.revision,
 'authority_receipt_id',w.authority_receipt_id,'definition_sha256',w.definition_sha256,'payload_sha256',w.payload_sha256,
 'payload_schema_version',w.payload->>'schema_version','run_control_version',w.run_control_version,
 'narrative_admission_sha256',case when narrative_contract is not null then public.combat_v2_sha256(narrative_contract) end,
 'release_sha256',c26_proof->>'release_sha256','finite_admission_sha256',c26_proof->>'finite_admission_sha256',
 'policy_snapshot_sha256',public.combat_v2_sha256(mission_generic_owner.c8_policy_snapshot_v1(w.id)),
 'financial_qualification_sha256',a.c8_count_qualification_sha256),
 'pricing',jsonb_build_object('model',pol.model,'reasoning_effort',pol.reasoning_effort,'store',pol.store,
 'max_output_tokens',limits->'max_output_tokens','input_usd_million',pol.input_usd_million,'output_usd_million',pol.output_usd_million,
 'count_upper_cost_usd','0.0124','generation_upper_cost_usd','0.0124'),
 'byte_bounds',jsonb_build_object('max_input_bytes',limits->'max_input_bytes','max_request_bytes',limits->'max_request_bytes')) else case when a.c7_budget_enforced then case when mission_generic_owner.c8_context24_scope_v1(w.id) then jsonb_build_object('schema_version','mission-generic-provider-input/3','input_tokens_limit',24000,'policy_version',pol.policy_version,'http_calls_per_generation',2,'scope',jsonb_build_object('schema_version','c889-context24-work-scope/1','session_id',w.master_session_id,'work_id',w.id,'batch_id',w.authority_receipt_id,'old_work_id','c88958e7-8983-4332-a14e-095076f967f4','financial_qualification_sha256',a.c8_count_qualification_sha256,'count_reserve_usd','0.0124','generation_reserve_usd','0.0124'),'pricing',jsonb_build_object('model',pol.model,'reasoning_effort',pol.reasoning_effort,'store',pol.store,'max_output_tokens',20000,'input_usd_million',pol.input_usd_million,'output_usd_million',pol.output_usd_million,'count_upper_cost_usd','0.0124','generation_upper_cost_usd','0.0124'),'byte_bounds',jsonb_build_object('max_input_bytes',limits->'max_input_bytes','max_request_bytes',limits->'max_request_bytes')) else jsonb_build_object('schema_version','mission-generic-provider-input/1','input_tokens_limit',(select max_input_tokens from mission_narrative_internal.runtime_policy where singleton),'policy_version',pol.policy_version,'http_calls_per_generation',2)  end else null end end end,
  'narrative_profile',case when narrative_contract is not null then narrative_contract->>'editorial_profile' when w.kind in('narration','director') and (mission_academy_owner.staff_carrier_runtime(w.master_session_id) OR mission_generic_owner.c726_factory_staff_runtime_v1(w.master_session_id))
    then 'cinematic_master_1' else 'legacy' end) - case when not a.c7_budget_enforced then 'provider_input_contract' else '__no_key__' end);
end $function$;
CREATE OR REPLACE FUNCTION public.mission_generic_dispatch_authorize_v1(p_work uuid, p_lease uuid, p_worker_token text, p_policy jsonb)
 RETURNS jsonb
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO ''
AS $function$
declare w mission_generic_owner.work_items;a mission_generic_owner.dispatch_admissions;pol mission_narrative_internal.runtime_policy;
 rr jsonb;z jsonb;spent numeric;ub numeric;c8_proof jsonb;
begin
 perform mission_ai_board_owner.service_only();
 -- C1266_AVAILABILITY_COORD: shared before mutation locks; xact lifetime.
 PERFORM pg_catalog.pg_advisory_xact_lock_shared(pg_catalog.hashtextextended('C1266:GENERIC-AI:AVAILABILITY',0));
 
 -- C9: freeze policy DML through proof, Native reserve and authorization.
 LOCK TABLE mission_narrative_internal.runtime_policy IN SHARE MODE;
 perform 1 from mission_generic_owner.role_window_cursors
   where master_session_id=(select master_session_id from mission_generic_owner.work_items where id=p_work)
   for update;
 if (select master_session_id from mission_generic_owner.work_items where id=p_work)
   ='b70b23cf-bad8-475d-a56a-d9c549e35d84'::uuid and not found
 then raise exception 'MRS_V4_CURSOR_REQUIRED' using errcode='40001';end if;
 perform 1 from public.master_v2_sessions where id=(select master_session_id from mission_generic_owner.work_items where id=p_work) for update;
 select * into strict w from mission_generic_owner.work_items where id=p_work for update; perform mission_generic_owner.role_dispatch_assert_v4(w.id);
 perform mission_generic_owner.work_assert(w);
 perform mission_generic_owner.assert_runtime(w.master_session_id);
 IF mission_generic_owner.c1266_opening_named_v1(w.master_session_id) AND mission_generic_owner.c1266_execution_authority_v1(w.master_session_id,false,true) IS NULL THEN RAISE EXCEPTION 'C1266_AUTHORIZE5_CLOSED' USING ERRCODE='42501';END IF;
 IF EXISTS(SELECT 1 FROM public.master_v2_sessions s726 WHERE s726.id=w.master_session_id AND s726.owner_kind='ai_service' AND s726.location_id='0b85f354-9cdb-47e1-baf9-3d266bb7e06b'::uuid AND (EXISTS(SELECT 1 FROM mission_generic_owner.flow_staff_sessions f726 WHERE f726.master_session_id=s726.id AND f726.enabled) OR EXISTS(SELECT 1 FROM mission_factory_owner.quest_run_sources q726 WHERE q726.session_id=s726.id AND q726.availability_scope='staff' AND q726.execution_context='staff_simulation'))) AND NOT mission_academy_owner.staff_carrier_runtime(w.master_session_id) AND NOT mission_generic_owner.c726_factory_staff_runtime_v1(w.master_session_id) THEN RAISE EXCEPTION 'C726_FACTORY_STAFF_SCOPE_CLOSED' USING ERRCODE='42501';END IF;

 if w.state<>'claimed' or w.lease_id<>p_lease or w.lease_expires_at<=clock_timestamp()
 or p_policy->>'payload_sha256' is distinct from w.payload_sha256 then raise exception 'MGD_AUTHORIZE_STALE';end if;
 select * into strict a from mission_generic_owner.dispatch_admissions where master_session_id=w.master_session_id for update;
 select * into strict pol from mission_narrative_internal.runtime_policy where singleton;
 if not a.enabled or (not mission_academy_owner.staff_carrier_runtime(w.master_session_id) and mission_generic_owner.c1266_staff_scene_policy_v1(w.master_session_id) IS NULL and a.calls_authorized>=a.call_limit) or p_policy->>'model' is distinct from pol.model
 or p_policy->>'reasoning_effort' is distinct from pol.reasoning_effort or p_policy->>'store' is distinct from 'false'
 or (p_policy->>'max_output_tokens')::integer is distinct from pol.max_output_tokens then raise exception 'MGD_ADMISSION_INVALID';end if;
 if a.c7_budget_enforced then c8_proof:=mission_generic_owner.c8_input_proof_assert_v1(w.id,p_lease,p_policy);end if;
 pol.max_input_tokens:=mission_generic_owner.receipt_input_cap(w.dispatch_receipt_id,pol.max_input_tokens);
 ub:=(pol.max_input_tokens*pol.input_usd_million+pol.max_output_tokens*pol.output_usd_million)/1000000;
 select coalesce(sum(case when d.status in('success','fallback','unknown_billable') then coalesce(d.charged_cost_usd,0)
  else coalesce(d.upper_bound_cost_usd,0) end),0) into spent
 from mission_narrative_internal.dispatch_receipts d where d.master_session_id=w.master_session_id;
 if not mission_academy_owner.staff_carrier_runtime(w.master_session_id) and mission_generic_owner.c1266_staff_scene_policy_v1(w.master_session_id) IS NULL and spent+ub>a.cost_budget_usd
 then raise exception 'MGD_RUN_BUDGET_EXHAUSTED';end if;
 perform mission_generic_owner.provider_permit(w.id,'authorize');
 rr:=public.mission_narrative_attempt_reserve_internal(p_worker_token,w.dispatch_receipt_id,180,null,null);
 if rr->>'status'<>'reserved' then raise exception 'MGD_NATIVE_RESERVE_REJECTED';end if;
 z:=public.mission_narrative_provider_authorize_internal(p_worker_token,w.dispatch_receipt_id,(rr->>'attempt_id')::uuid,rr->>'lease_token');
 if not mission_academy_owner.staff_carrier_runtime(w.master_session_id) then
   update mission_generic_owner.dispatch_admissions set calls_authorized=calls_authorized+1 where master_session_id=w.master_session_id;
 end if;
 update mission_generic_owner.work_items set state='authorized',authorization_id=(z->>'authorization_id')::uuid where id=w.id;
 return z||jsonb_build_object('work_id',w.id,'granted_now',true)||case when c8_proof is not null then jsonb_build_object('input_measurement_id',c8_proof->>'measurement_id','provider_request_sha256',c8_proof->>'generation_request_sha256','policy_snapshot_sha256',c8_proof->>'policy_snapshot_sha256') else '{}'::jsonb end;
end;
$function$;
REVOKE ALL ON FUNCTION public.mission_generic_dispatch_async_status_v1(uuid,jsonb) FROM PUBLIC,anon,authenticated,service_role;
-- Observer source remains owner-only and unreachable; terminal receipts/accounting retained.
COMMIT;
