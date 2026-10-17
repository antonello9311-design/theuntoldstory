-- SOURCE ONLY: install after qualified technical abort, protected postflight and fresh HOLD.
-- No flag enable, Root registration/renewal, provider calls, gameplay or cost mutation.
BEGIN;
SELECT pg_catalog.pg_advisory_xact_lock(pg_catalog.hashtextextended('C1266:GENERIC-AI:AVAILABILITY',0));
DO $baseline$
BEGIN
 IF EXISTS(SELECT 1 FROM (VALUES
('mission_generic_owner.c1266_clean_staff_admission_v1(uuid,boolean,boolean)','308958','ddf38f4d3b39114d74bd00ba6a2310ac','d3efa550240b4cfe4fe571a559caef24','{postgres=X/postgres}','postgres','plpgsql','v',true,'["search_path=\"\""]'::jsonb),
('mission_staff_abort_private.quiescent_v1(uuid)','261521','d2babd5767a55995f6478a9db2b58e46','2041b115d672d988a52b1a5255aab573','{postgres=X/postgres}','postgres','sql','s',true,'["search_path=\"\""]'::jsonb),
('public.mission_generic_dispatch_finalize_v1(uuid,text,text,text)','50414','8ec3a46b6ccf9367604f4d94f1ce7560','2c9874697871e6f14644c86b3a2abae0','{postgres=X/postgres,service_role=X/postgres}','postgres','plpgsql','v',true,'["search_path=\"\""]'::jsonb),
('public.mission_narrative_attempt_reserve_internal(text,uuid,integer,jsonb,text)','35929','dbfdc0f6b0bc421c55e49c51d61b3103','cf331376c5a1205367228c287d8ae372','{postgres=X/postgres,anon=X/postgres}','postgres','plpgsql','v',true,'["search_path=\"\""]'::jsonb),
('mission_staff_abort_private.source_v1(uuid)','261520','1f73a4af64288375b2958def5ee21923','4fd3054b232421df9398b8c1359512f4','{postgres=X/postgres}','postgres','plpgsql','v',true,'["search_path=\"\""]'::jsonb),
('public.mission_generic_dispatch_authorize_v1(uuid,uuid,text,jsonb)','50412','d42b7199823b1f6e4a9937f061440457','d8cc2e59d5c48e3a99b7b19a37ad027f','{postgres=X/postgres,service_role=X/postgres}','postgres','plpgsql','v',true,'["search_path=\"\""]'::jsonb),
('public.mission_generic_dispatch_claim_v1(uuid,jsonb)','50410','1c4ce5a60bd575249783892cb2cbbd52','e6a1e6a69998f85427af9fd7bd13a942','{postgres=X/postgres,service_role=X/postgres}','postgres','plpgsql','v',true,'["search_path=\"\""]'::jsonb),
('public.mission_generic_dispatch_consume_v1(uuid,uuid,text,uuid,text)','50413','9f562ade3085ec571e1710a6eeb41901','a99aba7ce1a32aada299abcaa6d20001','{postgres=X/postgres,service_role=X/postgres}','postgres','plpgsql','v',true,'["search_path=\"\""]'::jsonb),
('public.mission_generic_input_count_start_v1(uuid,uuid,text,text)','278279','21a49c40890c157da7ec7c4abc32751d','767b3b25dec1eeed3e78bbf61aceb887','{postgres=X/postgres,service_role=X/postgres}','postgres','plpgsql','v',true,'["search_path=\"\""]'::jsonb),
('public.mission_staff_simulation_abort_state_v1(uuid)','261522','ca5e9cece7e9d53f97250848f674a8a8','9d7131c725aaaaf700878fc34687aa68','{postgres=X/postgres,authenticated=X/postgres}','postgres','plpgsql','v',true,'["search_path=\"\""]'::jsonb),
('public.mission_staff_simulation_abort_v1(uuid,bigint,bigint,uuid)','261524','e5186651b4bdabb04dcb27a412c8d8d1','518dc28a889dc531a8f2dd5c5d8701d4','{postgres=X/postgres,authenticated=X/postgres}','postgres','plpgsql','v',true,'["search_path=\"\""]'::jsonb)
 ) expected(signature,oid,source_md5,ddl_md5,acl,owner,language,volatility,secdef,config)
 LEFT JOIN pg_catalog.pg_proc p ON p.oid=to_regprocedure(expected.signature)
 LEFT JOIN pg_catalog.pg_language l ON l.oid=p.prolang
 WHERE p.oid IS NULL OR p.oid::text IS DISTINCT FROM expected.oid
 OR md5(p.prosrc) IS DISTINCT FROM expected.source_md5 OR md5(pg_get_functiondef(p.oid)) IS DISTINCT FROM expected.ddl_md5
 OR p.proacl::text IS DISTINCT FROM expected.acl OR pg_get_userbyid(p.proowner) IS DISTINCT FROM expected.owner
 OR l.lanname IS DISTINCT FROM expected.language OR p.provolatile::text IS DISTINCT FROM expected.volatility
 OR p.prosecdef IS DISTINCT FROM expected.secdef OR to_jsonb(p.proconfig) IS DISTINCT FROM expected.config)
 THEN RAISE EXCEPTION 'C1266_TIMEOUT_BASELINE_DRIFT' USING ERRCODE='40001';END IF;
END $baseline$;
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
DO $new_observer$
BEGIN
 IF to_regprocedure('public.mission_generic_dispatch_async_status_v1(uuid,jsonb)') IS NOT NULL
 THEN RAISE EXCEPTION 'C1266_ASYNC_OBSERVER_ALREADY_EXISTS' USING ERRCODE='40001';END IF;
 IF md5((SELECT prosrc FROM pg_catalog.pg_proc WHERE oid=to_regprocedure('mission_generic_owner.c1266_generation_timeout_terminal_proof_v1(uuid)'))) IS DISTINCT FROM 'fba30ab2b365491e1c257855dece874b'
 THEN RAISE EXCEPTION 'C1266_ASYNC_TECHNICAL_PROOF_DRIFT' USING ERRCODE='40001';END IF;
END $new_observer$;
CREATE FUNCTION public.mission_generic_dispatch_async_status_v1(p_user uuid,p_request jsonb)
RETURNS jsonb LANGUAGE plpgsql STABLE SECURITY DEFINER SET search_path TO '' AS $status$
DECLARE w mission_generic_owner.work_items; e jsonb;
 recover_session uuid;selector jsonb;recover_request jsonb;next_key uuid;depth integer:=0;status_proof jsonb;marker jsonb;marker_count bigint;
 tick mission_generic_owner.staff_progress_ticks_v1;progress mission_generic_owner.progress_receipts;
 source_window mission_generic_owner.unified_source_windows;receipt mission_narrative_internal.dispatch_receipts;
 recovery_none jsonb:=jsonb_build_object('schema_version','mission-generic-async-recovery/1','status','none',
  'request',NULL,'work_id',NULL,'state',NULL,'receipt_id',NULL,'result_sha256',NULL,'kind',NULL,'retry',false,'provider_retry_allowed',false);
BEGIN
 PERFORM mission_ai_board_owner.service_only();
 -- Recovery is a distinct closed DTO on this service-only reader. It never claims work.
 IF p_request->>'schema_version'='mission-generic-async-recover/1' THEN
  IF p_user IS NULL OR NOT mission_factory_owner.keys_exact_v2(p_request,ARRAY['schema_version','master_session_id','selector'])
   OR (p_request->>'master_session_id' ~ '^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$') IS DISTINCT FROM TRUE
  THEN RAISE EXCEPTION 'C1266_ASYNC_RECOVERY_INPUT' USING ERRCODE='22023';END IF;
  recover_session:=(p_request->>'master_session_id')::uuid;selector:=p_request->'selector';
  IF selector->>'kind'='request' AND mission_factory_owner.keys_exact_v2(selector,ARRAY['kind','request']) THEN
   recover_request:=selector->'request';
  ELSIF selector->>'kind'='staff_tick' AND mission_factory_owner.keys_exact_v2(selector,ARRAY['kind','source_revision'])
   AND selector->>'source_revision' ~ '^[0-9a-f]{64}$' THEN
   -- Same persisted ownership and receipt/hash bindings as the Staff tick producer.
   SELECT * INTO tick FROM mission_generic_owner.staff_progress_ticks_v1 t
    WHERE t.master_session_id=recover_session AND t.source_revision=selector->>'source_revision' AND t.actor_user_id=p_user;
   IF NOT FOUND OR NOT EXISTS(SELECT 1 FROM public.profiles sp WHERE sp.id=tick.staff_user_id AND sp.role IN('admin','master'))
    OR NOT EXISTS(SELECT 1 FROM public.master_v2_participants mp
     JOIN public.characters ch ON ch.id=mp.character_id AND ch.user_id=mp.user_id_snapshot
     JOIN public.profiles tp ON tp.id=mp.user_id_snapshot AND tp.role IN('admin','master')
     WHERE mp.session_id=recover_session AND mp.user_id_snapshot=p_user AND mp.left_at IS NULL)
   THEN RETURN recovery_none;END IF;
   SELECT * INTO progress FROM mission_generic_owner.progress_receipts pr WHERE pr.request_key=tick.request_key
    AND pr.master_session_id=recover_session AND pr.actor_user_id=p_user
    AND pr.result_sha256=tick.result_sha256 AND pr.result_sha256=public.combat_v2_sha256(pr.result);
   IF NOT FOUND THEN RETURN recovery_none;END IF;
   recover_request:=progress.result->'dispatch';
  ELSE RAISE EXCEPTION 'C1266_ASYNC_RECOVERY_SELECTOR' USING ERRCODE='22023';END IF;
  LOOP
   IF selector->>'kind'='staff_tick' THEN
    -- The persisted own progress receipt is the acknowledgement. Missing/claimed work is not no_work.
    IF (mission_factory_owner.keys_exact_v2(progress.result,ARRAY['schema_version','master_session_id','state','dispatch'])
     OR (mission_factory_owner.keys_exact_v2(progress.result,ARRAY['schema_version','master_session_id','state','dispatch','reason_code'])
      AND progress.result->>'reason_code'='MGPG_C7_RUN_BUDGET_STOP' AND progress.result->>'state'='paused')) IS DISTINCT FROM TRUE
     OR progress.result->>'schema_version' IS DISTINCT FROM 'mission-generic-progress/1'
     OR progress.result->>'master_session_id' IS DISTINCT FROM recover_session::text
     OR jsonb_typeof(progress.result->'state') IS DISTINCT FROM 'string'
     OR (progress.result->>'state' ~ '^[a-z][a-z0-9_]{0,63}$') IS DISTINCT FROM TRUE
    THEN RAISE EXCEPTION 'C1266_ASYNC_RECOVERY_PROGRESS' USING ERRCODE='22023';END IF;
    IF recover_request='null'::jsonb THEN
     IF NOT EXISTS(SELECT 1 FROM public.master_v2_sessions m JOIN public.locations l ON l.id=m.location_id
      WHERE m.id=recover_session AND m.owner_kind='ai_service' AND m.master_user IS NULL
       AND m.location_id='0b85f354-9cdb-47e1-baf9-3d266bb7e06b'::uuid AND l.is_active AND l.is_test
       AND EXISTS(SELECT 1 FROM public.master_v2_participants mp
        JOIN public.characters ch ON ch.id=mp.character_id AND ch.user_id=mp.user_id_snapshot
        JOIN public.profiles tp ON tp.id=mp.user_id_snapshot AND tp.role IN('admin','master')
        WHERE mp.session_id=m.id AND mp.user_id_snapshot=p_user AND mp.left_at IS NULL))
      OR EXISTS(SELECT 1 FROM mission_generic_owner.work_items pending WHERE pending.master_session_id=recover_session
       AND pending.state IN('ready','claimed','authorized','provider_started','uncertain'))
     THEN RETURN recovery_none;END IF;
     RETURN jsonb_set(recovery_none,'{status}',to_jsonb('no_work'::text));
    END IF;
   END IF;
   IF NOT mission_factory_owner.keys_exact_v2(recover_request,ARRAY['schema_version','master_session_id','event_id','request_key','expected_revision'])
    OR recover_request->>'schema_version' IS DISTINCT FROM 'mission-generic-request/1'
    OR recover_request->>'master_session_id' IS DISTINCT FROM recover_session::text
    OR (recover_request->>'event_id' ~ '^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$') IS DISTINCT FROM TRUE
    OR (recover_request->>'request_key' ~ '^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$') IS DISTINCT FROM TRUE
    OR jsonb_typeof(recover_request->'expected_revision') IS DISTINCT FROM 'number'
    OR (recover_request->>'expected_revision' ~ '^[1-9][0-9]*$') IS DISTINCT FROM TRUE
   THEN RAISE EXCEPTION 'C1266_ASYNC_RECOVERY_REQUEST' USING ERRCODE='22023';END IF;
   IF (recover_request->>'expected_revision')::numeric>9007199254740991 THEN
    RAISE EXCEPTION 'C1266_ASYNC_RECOVERY_REVISION' USING ERRCODE='22023';END IF;
   IF selector->>'kind'='staff_tick' AND (progress.result->>'schema_version' IS DISTINCT FROM 'mission-generic-progress/1'
    OR progress.result->>'master_session_id' IS DISTINCT FROM recover_session::text) THEN RETURN recovery_none;END IF;
   SELECT * INTO w FROM mission_generic_owner.work_items wi WHERE wi.master_session_id=recover_session
    AND wi.event_id=(recover_request->>'event_id')::uuid AND wi.request_key=(recover_request->>'request_key')::uuid
    AND wi.revision=(recover_request->>'expected_revision')::bigint;
   IF NOT FOUND THEN RETURN recovery_none;END IF;
   next_key:=NULL;
   -- Follow only the two existing server-generated retry successors, never compute a new work.
   IF selector->>'kind'='staff_tick' AND depth<2 AND w.kind='director' AND w.id=w.event_id
    AND w.state='failed' AND w.finalized_at IS NOT NULL THEN
    SELECT * INTO source_window FROM mission_generic_owner.unified_source_windows sw
     WHERE sw.id=w.authority_receipt_id AND sw.work_id=w.id AND sw.master_session_id=recover_session;
    IF FOUND AND source_window.context->>'source_revision'=selector->>'source_revision'
     AND source_window.superseded_reason='staff_failed_director_validation_retry'
     AND source_window.consumed_message_id IS NULL AND mission_generic_owner.role_source_released_v4(source_window.id) THEN
     next_key:=mission_ai_service_owner.uuid5(w.id,CASE WHEN depth=0 THEN 'mission-staff-released-director-retry/1:'
      ELSE 'mission-staff-db-context-retry/2:' END||(selector->>'source_revision'));
    END IF;
   END IF;
   IF next_key IS NULL THEN EXIT;END IF;
   SELECT * INTO progress FROM mission_generic_owner.progress_receipts pr WHERE pr.request_key=next_key;
   IF NOT FOUND THEN EXIT;END IF;
   IF progress.master_session_id IS DISTINCT FROM recover_session OR progress.actor_user_id IS DISTINCT FROM p_user
    OR progress.result_sha256 IS DISTINCT FROM public.combat_v2_sha256(progress.result) THEN RETURN recovery_none;END IF;
   recover_request:=progress.result->'dispatch';depth:=depth+1;
  END LOOP;
  -- Legacy receipt has no marker. A local journal, Staff role or readable work is insufficient.
  SELECT * INTO receipt FROM mission_narrative_internal.dispatch_receipts d WHERE d.id=w.dispatch_receipt_id;
  IF NOT FOUND OR receipt.master_session_id IS DISTINCT FROM w.master_session_id
   OR receipt.authority_receipt_id IS DISTINCT FROM w.id OR receipt.request_key IS DISTINCT FROM w.request_key
   OR receipt.event_kind IS DISTINCT FROM 'mission_generic_event' OR receipt.renderer_version IS DISTINCT FROM 'mission-generic-runtime/1'
   OR receipt.request_fingerprint IS DISTINCT FROM mission_internal.fingerprint(recover_request)
   OR receipt.envelope_sha256 IS DISTINCT FROM public.combat_v2_sha256(receipt.envelope)
   OR receipt.authority_sha256 IS DISTINCT FROM receipt.envelope_sha256
   OR receipt.envelope->>'work_id' IS DISTINCT FROM w.id::text
   OR receipt.envelope->>'master_session_id' IS DISTINCT FROM w.master_session_id::text
   OR receipt.envelope->>'event_id' IS DISTINCT FROM w.event_id::text
   OR receipt.envelope->>'authority_receipt_id' IS DISTINCT FROM w.authority_receipt_id::text
   OR receipt.envelope->>'payload_sha256' IS DISTINCT FROM w.payload_sha256
   OR receipt.envelope->>'definition_sha256' IS DISTINCT FROM w.definition_sha256
   OR receipt.envelope->'revision' IS DISTINCT FROM to_jsonb(w.revision)
  THEN RETURN recovery_none;END IF;
  SELECT count(*),(jsonb_agg(a.details)->0) INTO marker_count,marker FROM mission_narrative_internal.dispatch_audit a
   WHERE a.receipt_id=receipt.id AND a.event_code='c1266_async_owner_v1';
  IF marker_count<>1 OR NOT mission_factory_owner.keys_exact_v2(marker,ARRAY['schema_version','actor_user_id','work_id','request_sha256','envelope_sha256','provider_timeout_ms'])
   OR marker->>'schema_version' IS DISTINCT FROM 'mission-generic-async-owner/1'
   OR marker->>'actor_user_id' IS DISTINCT FROM p_user::text OR marker->>'work_id' IS DISTINCT FROM w.id::text
   OR marker->>'request_sha256' IS DISTINCT FROM public.combat_v2_sha256(recover_request)
   OR marker->>'envelope_sha256' IS DISTINCT FROM receipt.envelope_sha256
   OR marker->'provider_timeout_ms' IS DISTINCT FROM '240000'::jsonb
  THEN RETURN recovery_none;END IF;
  e:=mission_generic_owner.c1266_historical_work_v1(w.id);
  IF e IS NULL OR (e->>'execution_context' IN('staff_mission','ordinary_mission')) IS DISTINCT FROM TRUE
   OR NOT EXISTS(SELECT 1 FROM public.master_v2_sessions m WHERE m.id=w.master_session_id
    AND m.owner_kind='ai_service' AND m.master_user IS NULL AND m.closed_at IS NULL AND m.suspended_at IS NULL
    AND (EXISTS(SELECT 1 FROM public.profiles p WHERE p.id=p_user AND p.role IN('admin','master'))
     OR EXISTS(SELECT 1 FROM public.master_v2_participants mp JOIN public.characters c ON c.id=mp.character_id AND c.user_id=p_user
      WHERE mp.session_id=m.id AND mp.user_id_snapshot=p_user AND mp.left_at IS NULL)))
   OR (w.kind IN('director','narration','choice')) IS DISTINCT FROM TRUE
  THEN RETURN recovery_none;END IF;
  status_proof:=mission_generic_owner.work_status(w);
  RETURN jsonb_build_object('schema_version','mission-generic-async-recovery/1','status','owned','request',recover_request,
   'work_id',w.id,'state',status_proof->'state','receipt_id',status_proof->'receipt_id',
   'result_sha256',status_proof->'result_sha256','kind',w.kind,'retry',false,'provider_retry_allowed',false);
 END IF;
 IF p_user IS NULL OR NOT mission_factory_owner.keys_exact_v2(p_request,ARRAY['schema_version','master_session_id','event_id','request_key','expected_revision'])
 OR p_request->>'schema_version' IS DISTINCT FROM 'mission-generic-request/1'
 THEN RAISE EXCEPTION 'C1266_ASYNC_STATUS_INPUT' USING ERRCODE='22023';END IF;
 SELECT * INTO STRICT w FROM mission_generic_owner.work_items
 WHERE master_session_id=(p_request->>'master_session_id')::uuid
 AND event_id=(p_request->>'event_id')::uuid AND request_key=(p_request->>'request_key')::uuid
 AND revision=(p_request->>'expected_revision')::bigint;
 e:=mission_generic_owner.c1266_historical_work_v1(w.id);
 IF e IS NULL OR (e->>'execution_context' IN('staff_mission','ordinary_mission')) IS DISTINCT FROM TRUE
 OR NOT EXISTS(SELECT 1 FROM public.master_v2_sessions m
 WHERE m.id=w.master_session_id AND m.owner_kind='ai_service' AND m.master_user IS NULL
 AND (EXISTS(SELECT 1 FROM public.profiles p WHERE p.id=p_user AND p.role IN('admin','master'))
 OR EXISTS(SELECT 1 FROM public.master_v2_participants mp
 JOIN public.characters c ON c.id=mp.character_id AND c.user_id=p_user
 WHERE mp.session_id=m.id AND mp.user_id_snapshot=p_user
 AND (mp.left_at IS NULL OR (m.closed_at IS NOT NULL AND w.finalized_at IS NOT NULL
 AND w.state IN('completed','failed','uncertain') AND w.receipt_id IS NOT NULL)))))
 THEN RAISE EXCEPTION 'C1266_ASYNC_STATUS_SCOPE' USING ERRCODE='42501';END IF;
 -- Observation only. Terminal history access conveys no new claim, gameplay or provider permission.
 -- No overflow terminalizer, current Root/lease renewal, dispatch mutation, or publication mutation.
 RETURN mission_generic_owner.work_status(w);
END $status$;
REVOKE ALL ON FUNCTION public.mission_generic_dispatch_async_status_v1(uuid,jsonb) FROM PUBLIC,anon,authenticated;
GRANT EXECUTE ON FUNCTION public.mission_generic_dispatch_async_status_v1(uuid,jsonb) TO service_role;
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
  'transport_max_chars',5000,'provider_timeout_ms',CASE WHEN c26_proof IS NOT NULL OR c5_proof IS NOT NULL THEN 240000 ELSE 120000 END);
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
 -- Audit is immutable; preserve the exact Native envelope and all existing authority hashes.
 -- This proves an owned claim under the async contract, not waitUntil registration/completion.
 -- Only newly inserted receipts get this marker. No legacy backfill or marker on lease reissue.
 IF (c26_proof IS NOT NULL OR c5_proof IS NOT NULL) AND limits->'provider_timeout_ms'='240000'::jsonb THEN
  INSERT INTO mission_narrative_internal.dispatch_audit(receipt_id,event_code,details)
  VALUES(dr,'c1266_async_owner_v1',jsonb_build_object('schema_version','mission-generic-async-owner/1',
   'actor_user_id',p_user,'work_id',w.id,'request_sha256',public.combat_v2_sha256(p_request),
   'envelope_sha256',public.combat_v2_sha256(env),'provider_timeout_ms',240000));
 END IF;
 end if;
 -- A complete worker window must fit inside the immutable finite Staff admission.
 IF c26_proof IS NOT NULL AND
 (c26_proof#>>'{admission_attestation,expires_at}')::timestamptz<=clock_timestamp()+interval '360 seconds'
 THEN RAISE EXCEPTION 'C1266_BACKGROUND_DEADLINE_CLOSED' USING ERRCODE='55000';END IF;
 IF c5_proof IS NOT NULL AND c5_proof#>>'{admission,kind}'='staff_finite' AND
 (c5_proof#>>'{admission,expires_at}')::timestamptz<=clock_timestamp()+interval '360 seconds'
 THEN RAISE EXCEPTION 'C1266_BACKGROUND_DEADLINE_CLOSED' USING ERRCODE='55000';END IF;
 update mission_generic_owner.work_items set state='claimed',dispatch_receipt_id=dr,lease_id=gen_random_uuid(),
  lease_expires_at=CASE WHEN c26_proof IS NOT NULL THEN least(clock_timestamp()+interval '360 seconds',(c26_proof#>>'{admission_attestation,expires_at}')::timestamptz) WHEN c5_proof IS NOT NULL THEN CASE WHEN c5_proof#>>'{admission,kind}'='staff_finite' THEN least(clock_timestamp()+interval '360 seconds',(c5_proof#>>'{admission,expires_at}')::timestamptz) ELSE clock_timestamp()+interval '360 seconds' END ELSE clock_timestamp()+interval '180 seconds' END where id=w.id returning * into w;
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
 -- Count and Gen have independent budgets. Native Gen lease stays within the work lease.
 if mission_generic_owner.c1266_clean_staff_admission_v1(w.master_session_id,true,true) IS NOT NULL
 OR (mission_generic_owner.c1266_opening_named_v1(w.master_session_id) AND mission_generic_owner.c1266_execution_authority_v1(w.master_session_id,false,true) IS NOT NULL) then
  if extract(epoch from(w.lease_expires_at-clock_timestamp()))<30 then
   raise exception 'C1266_BACKGROUND_GENERATION_DEADLINE_CLOSED' using errcode='55000';end if;
  rr:=public.mission_narrative_attempt_reserve_internal(p_worker_token,w.dispatch_receipt_id,
   least(260,floor(extract(epoch from(w.lease_expires_at-clock_timestamp())))::integer),null,null);
 else
  rr:=public.mission_narrative_attempt_reserve_internal(p_worker_token,w.dispatch_receipt_id,180,null,null);
 end if;
 if rr->>'status'<>'reserved' then raise exception 'MGD_NATIVE_RESERVE_REJECTED';end if;
 z:=public.mission_narrative_provider_authorize_internal(p_worker_token,w.dispatch_receipt_id,(rr->>'attempt_id')::uuid,rr->>'lease_token');
 if not mission_academy_owner.staff_carrier_runtime(w.master_session_id) then
   update mission_generic_owner.dispatch_admissions set calls_authorized=calls_authorized+1 where master_session_id=w.master_session_id;
 end if;
 update mission_generic_owner.work_items set state='authorized',authorization_id=(z->>'authorization_id')::uuid where id=w.id;
 return z||jsonb_build_object('work_id',w.id,'granted_now',true)||case when c8_proof is not null then jsonb_build_object('input_measurement_id',c8_proof->>'measurement_id','provider_request_sha256',c8_proof->>'generation_request_sha256','policy_snapshot_sha256',c8_proof->>'policy_snapshot_sha256') else '{}'::jsonb end;
end;
$function$;
DO $async_post$
BEGIN
 IF md5((SELECT prosrc FROM pg_catalog.pg_proc WHERE oid=to_regprocedure('public.mission_generic_dispatch_claim_v1(uuid,jsonb)'))) IS DISTINCT FROM '26513cd37a169bd43f7b52d75f3e9111'
 OR md5((SELECT prosrc FROM pg_catalog.pg_proc WHERE oid=to_regprocedure('public.mission_generic_dispatch_authorize_v1(uuid,uuid,text,jsonb)'))) IS DISTINCT FROM '6b63629512c5e22ae4e51ec741cbc946'
 OR md5((SELECT prosrc FROM pg_catalog.pg_proc WHERE oid=to_regprocedure('public.mission_generic_dispatch_async_status_v1(uuid,jsonb)'))) IS DISTINCT FROM '411b1525297fa7e983abab4a8bb1ab5f'
 THEN RAISE EXCEPTION 'C1266_ASYNC_SOURCE_POST_MISMATCH' USING ERRCODE='40001';END IF;
 IF EXISTS(SELECT 1 FROM pg_catalog.pg_proc p WHERE p.oid=ANY(ARRAY[
 to_regprocedure('public.mission_generic_dispatch_claim_v1(uuid,jsonb)')::oid,
 to_regprocedure('public.mission_generic_dispatch_authorize_v1(uuid,uuid,text,jsonb)')::oid,
 to_regprocedure('public.mission_generic_dispatch_async_status_v1(uuid,jsonb)')::oid])
 AND(p.proacl::text IS DISTINCT FROM '{postgres=X/postgres,service_role=X/postgres}' OR pg_get_userbyid(p.proowner)<>'postgres'))
 THEN RAISE EXCEPTION 'C1266_ASYNC_SOURCE_ACL_DRIFT' USING ERRCODE='40001';END IF;
END $async_post$;
COMMIT;
