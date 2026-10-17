CREATE OR REPLACE FUNCTION mission_staff_abort_private.quiescent_v1(p_session uuid)
 RETURNS boolean
 LANGUAGE sql
 STABLE SECURITY DEFINER
 SET search_path TO ''
AS $function$
 select not exists(select 1 from mission_generic_owner.work_items w where w.master_session_id=p_session
  and not (
  -- C1266 prerequisite9: own terminal pre-effect failure, exact candidate8 Root, preserved accounting.
  ((w.state IN('failed','uncertain')
 AND w.lease_id IS NOT NULL AND w.authorization_id IS NOT NULL AND w.dispatch_id IS NOT NULL
 AND w.result->>'work_id'=w.id::text AND w.result->>'master_session_id'=w.master_session_id::text
 AND w.result->>'payload_sha256'=w.payload_sha256 AND w.result->>'definition_sha256'=w.definition_sha256
 AND w.result->>'authority_receipt_id'=w.authority_receipt_id::text
 AND w.result->>'authorization_id'=w.authorization_id::text AND w.result->>'dispatch_id'=w.dispatch_id::text
 AND w.result->>'event_id'=w.event_id::text AND w.result->>'request_key'=w.request_key::text
 AND w.result->>'revision'=w.revision::text AND w.result->>'kind'=w.kind
 AND w.result->>'provider_calls'='1'
 AND jsonb_typeof(w.result->'text')='null'
 AND (SELECT count(*) FROM mission_narrative_internal.dispatch_audit one_final
  WHERE one_final.receipt_id=w.dispatch_receipt_id AND one_final.event_code='generic_finalized')=1
 -- Completed/incomplete are exact paid failures; the separate finalized timeout retains its full unknown-billable bound.
 AND ((w.state='failed' AND w.result->>'outcome_uncertain'='false' AND w.result->>'usage_unknown'='false' AND w.result->>'provider_status'='completed'
   AND jsonb_typeof(w.result->'failure_codes')='array'
   AND jsonb_array_length(CASE WHEN jsonb_typeof(w.result->'failure_codes')='array' THEN w.result->'failure_codes' ELSE '[]'::jsonb END) BETWEEN 1 AND 8
   AND ((w.kind='choice' AND w.result->'failure_codes'<@'["MISSION_CHOICE_OUTPUT_INVALID","MISSION_CHOICE_SELECTION_REJECTED","MISSION_PROFILE_AUDIT_INVALID","MISSION_PEACEFUL_PROPOSAL_INVALID","MISSION_PEACEFUL_NONE_INVALID","MISSION_PEACEFUL_CAPABILITY_SELECTION_INVALID","MISSION_PEACEFUL_SOURCE_INVALID","PROVIDER_SCHEMA","provider_or_validation_failed","provider_output_too_large"]'::jsonb) OR(w.kind='director' AND w.result->'failure_codes'<@'["MISSION_C1266_JOINT_WIRE_INVALID","MISSION_DIRECTOR_GUIDANCE_INVALID","MISSION_DIRECTOR_MOVEMENT_EVIDENCE_MISSING","MISSION_DIRECTOR_PROGRESS_BASIS_INVALID","MISSION_DIRECTOR_PROGRESS_INVALID","MISSION_DIRECTOR_SOURCE_REVISION_INVALID","MISSION_PROFILE_AUDIT_INVALID","MISSION_UNIFIED_DIRECTOR_ACTION_KIND_REJECTED","MISSION_UNIFIED_DIRECTOR_ACTOR_REJECTED","MISSION_UNIFIED_DIRECTOR_ENTRY_POLICY_REJECTED","MISSION_UNIFIED_DIRECTOR_ENTRY_REJECTED","MISSION_UNIFIED_DIRECTOR_OPPORTUNITY_REJECTED","MISSION_UNIFIED_DIRECTOR_OUTPUT_INVALID","MISSION_UNIFIED_DIRECTOR_PNG_OFFENSE_MISMATCH","PROVIDER_SCHEMA","provider_or_validation_failed","provider_output_too_large"]'::jsonb)
     OR(w.kind='narration' AND w.payload->>'schema_version' IN('mission-generic-narration/2','mission-generic-narration/3') AND w.result->'failure_codes'<@'["MISSION_CONTINUITY_HISTORY_DRIFT","MISSION_CONTINUITY_HISTORY_MISSING","MISSION_CONTINUITY_INVALID","MISSION_CONTINUITY_MEMORY_DRIFT","MISSION_CONTINUITY_OUTPUT_INVALID","MISSION_NARRATIVE_FORMAT_INVALID","MISSION_NARRATIVE_LITERAL_REPETITION","MISSION_PROFILE_AUDIT_INVALID","PROVIDER_SCHEMA","below_required_minimum","empty_output","provider_or_validation_failed","provider_output_too_large","transport_output_overflow"]'::jsonb)
     OR(w.kind='narration' AND w.payload->>'schema_version'='mission-generic-narration/4' AND w.result->'failure_codes'<@'["MISSION_CONTINUITY_HISTORY_DRIFT","MISSION_CONTINUITY_HISTORY_MISSING","MISSION_CONTINUITY_INVALID","MISSION_CONTINUITY_MEMORY_DRIFT","MISSION_CONTINUITY_OUTPUT_INVALID","MISSION_NARRATIVE_FORMAT_INVALID","MISSION_NARRATIVE_LITERAL_REPETITION","MISSION_PROFILE_AUDIT_INVALID","MISSION_SEGMENTED_OUTPUT_INVALID","MISSION_SEGMENTED_PART_INVALID","MISSION_SEGMENTED_PROSE_INVALID","MISSION_SEGMENTED_SLOT_COVERAGE_INVALID","MISSION_SEGMENTED_SLOT_INVALID","MISSION_SEGMENTED_SLOT_ORDER_INVALID","MISSION_SEGMENTED_TRANSPORT_RESERVE_INVALID","PROVIDER_SCHEMA","below_required_minimum","empty_output","provider_or_validation_failed","provider_output_too_large","transport_output_overflow"]'::jsonb)))
  OR(w.state='failed' AND w.result->>'outcome_uncertain'='false' AND w.result->>'usage_unknown'='false' AND w.result->>'provider_status'='incomplete' AND w.result->'failure_codes'='["MISSION_PROVIDER_INCOMPLETE"]'::jsonb)
  OR(w.state='uncertain' AND w.result->>'outcome_uncertain'='true'
   AND w.result->>'usage_unknown'='true' AND jsonb_typeof(w.result->'usage')='null'
   AND jsonb_typeof(w.result->'provider_status')='null' AND jsonb_typeof(w.result->'raw_sha256')='null'
   AND w.result->'failure_codes'='["provider_outcome_unknown"]'::jsonb))
 -- Same immutable historical work authority as the original abort; exact full candidate8 bundle in its Root.
 AND EXISTS(SELECT 1 FROM mission_factory_owner.editor_release_readiness rr
  WHERE rr.singleton AND rr.revision_sha256=rr.observed_revision_sha256
  AND encode(extensions.digest(convert_to(rr.canonical_preimage,'UTF8'),'sha256'),'hex')=rr.revision_sha256
  AND mission_generic_owner.c1266_historical_work_v1(w.id)->>'release_sha256'=rr.revision_sha256
  AND (SELECT count(*) FROM jsonb_array_elements(CASE WHEN jsonb_typeof(rr.canonical_preimage::jsonb->'edge_bundles')='array' THEN rr.canonical_preimage::jsonb->'edge_bundles' ELSE '[]'::jsonb END) eb WHERE eb->>'name'='mission_generic_ai')=1
  AND EXISTS(SELECT 1 FROM jsonb_array_elements(CASE WHEN jsonb_typeof(rr.canonical_preimage::jsonb->'edge_bundles')='array' THEN rr.canonical_preimage::jsonb->'edge_bundles' ELSE '[]'::jsonb END) eb
   WHERE eb->>'name'='mission_generic_ai'
   AND (SELECT jsonb_agg(jsonb_build_object('name',ef->>'name','bytes',ef->'bytes','sha256',ef->>'sha256') ORDER BY ef->>'name')
    FROM jsonb_array_elements(CASE WHEN jsonb_typeof(eb->'files')='array' THEN eb->'files' ELSE '[]'::jsonb END) ef) IN ('[{"name":"exam_regia17/edge/src/contracts.mjs","bytes":3947,"sha256":"0ad88b84c3e083fc6cb333119d603daf23b3cd465d30285fba6aba5b1bb2f3b7"},{"name":"exam_regia17/edge/src/provider.mjs","bytes":1238,"sha256":"f7e5671ca353b15d7f8b9a427cef4e596d07296b41970e1776939bdd7b77c0dc"},{"name":"exam_regia17/edge/src/shared-panel/multiplication.mjs","bytes":2611,"sha256":"d038e1052633d6ba8df80526a4b4b4a29be8b96024248619400008e5c2b1f7fe"},{"name":"exam_regia17/edge/src/shared-panel/validate.mjs","bytes":14018,"sha256":"972533fbe65ecfa7a954a5610d6ee6aedb317f4d99955a0a0ed1fecb715e613d"},{"name":"exam_regia17/edge/src/shared-scene/common.mjs","bytes":9284,"sha256":"8b8ecc621a0753567ae3c5b8f8dc01ea958bd6a2284ad893449415f81cc7f7dd"},{"name":"exam_regia17/edge/src/shared-scene/editorial.mjs","bytes":5369,"sha256":"8f04bfc747c1d3acf93960e9ba2ac295d27ab0baf552e9e35d35b13d203b8300"},{"name":"exam_regia17/edge/src/shared-scene/narrative-master.mjs","bytes":7437,"sha256":"1560429c7c503d4d9dd78ef22c58394c8781fa9efed7d2ba61863d29630983a2"},{"name":"exam_regia17/edge/src/shared-scene/scene.mjs","bytes":6700,"sha256":"be436f9ad4bfca637f7bbc9a35e51bcbcc5e66128d5069b3f4300fcb6c90c5e7"},{"name":"exam_regia17/edge/src/shared-scene/staff-common.mjs","bytes":6765,"sha256":"e316c7569c3bd79fbdac21322fd1dc7027a213578ceb022a89fbd50546ea0ed7"},{"name":"mission-director-narration-read.mjs","bytes":4052,"sha256":"5b82fb2ab74a3eaf6b56502a25fd7f69ef3a7c285ad2edae27ae15686930e1b7"},{"name":"mission-generic-choice.mjs","bytes":9237,"sha256":"7690b4e5ac91ea6bc7573ba238ee5883f2175935856833ca584759f7f20fe776"},{"name":"mission-generic-http.mjs","bytes":23645,"sha256":"93b4037046e9f64c731a9f1a17a455378fb03babbcdc1bd6f2397f0fd5379b27"},{"name":"mission-generic-index.ts","bytes":21221,"sha256":"fd7c88ce861ec8b1e9a56bb3ba1b08500a48430c270ec0282d498891b922dcfb"},{"name":"mission-generic-runtime.mjs","bytes":266168,"sha256":"38ef965084b8cdf73dce0348df5e8ec143e3f596d4d2aa403afcb65739c92763"}]'::jsonb,'[{"name":"exam_regia17/edge/src/contracts.mjs","bytes":3947,"sha256":"0ad88b84c3e083fc6cb333119d603daf23b3cd465d30285fba6aba5b1bb2f3b7"},{"name":"exam_regia17/edge/src/provider.mjs","bytes":1238,"sha256":"f7e5671ca353b15d7f8b9a427cef4e596d07296b41970e1776939bdd7b77c0dc"},{"name":"exam_regia17/edge/src/shared-panel/multiplication.mjs","bytes":2611,"sha256":"d038e1052633d6ba8df80526a4b4b4a29be8b96024248619400008e5c2b1f7fe"},{"name":"exam_regia17/edge/src/shared-panel/validate.mjs","bytes":14018,"sha256":"972533fbe65ecfa7a954a5610d6ee6aedb317f4d99955a0a0ed1fecb715e613d"},{"name":"exam_regia17/edge/src/shared-scene/common.mjs","bytes":9284,"sha256":"8b8ecc621a0753567ae3c5b8f8dc01ea958bd6a2284ad893449415f81cc7f7dd"},{"name":"exam_regia17/edge/src/shared-scene/editorial.mjs","bytes":5369,"sha256":"8f04bfc747c1d3acf93960e9ba2ac295d27ab0baf552e9e35d35b13d203b8300"},{"name":"exam_regia17/edge/src/shared-scene/narrative-master.mjs","bytes":7437,"sha256":"1560429c7c503d4d9dd78ef22c58394c8781fa9efed7d2ba61863d29630983a2"},{"name":"exam_regia17/edge/src/shared-scene/scene.mjs","bytes":6700,"sha256":"be436f9ad4bfca637f7bbc9a35e51bcbcc5e66128d5069b3f4300fcb6c90c5e7"},{"name":"exam_regia17/edge/src/shared-scene/staff-common.mjs","bytes":6765,"sha256":"e316c7569c3bd79fbdac21322fd1dc7027a213578ceb022a89fbd50546ea0ed7"},{"name":"mission-director-narration-read.mjs","bytes":4052,"sha256":"5b82fb2ab74a3eaf6b56502a25fd7f69ef3a7c285ad2edae27ae15686930e1b7"},{"name":"mission-generic-choice.mjs","bytes":9237,"sha256":"7690b4e5ac91ea6bc7573ba238ee5883f2175935856833ca584759f7f20fe776"},{"name":"mission-generic-http.mjs","bytes":23645,"sha256":"93b4037046e9f64c731a9f1a17a455378fb03babbcdc1bd6f2397f0fd5379b27"},{"name":"mission-generic-index.ts","bytes":22079,"sha256":"cc91c743e69c25295f7921f3eaf39a1ba7d550321432543b9cc06fba360bd362"},{"name":"mission-generic-runtime.mjs","bytes":273331,"sha256":"98c2559cf3c7d5deb217fcb2b1a389d85719c787f319600873ffba4e315df1fe"}]'::jsonb)))
 -- Effects of THIS work only: past Fati and already prepared private simulation mechanics remain unchanged.
 AND NOT EXISTS(SELECT 1 FROM mission_generic_owner.unified_segment_publications_v4 own_publication WHERE own_publication.work_id=w.id)
 AND NOT EXISTS(SELECT 1 FROM mission_generic_owner.unified_batches issued_batch WHERE issued_batch.decision_work_id=w.id)
 AND ((w.kind='director' AND w.authority_receipt_id=w.id AND w.payload->>'schema_version'='mission-director-work/4'
   AND w.result->>'schema_version'='mission-generic-result/1'
   AND NOT EXISTS(SELECT 1 FROM mission_generic_owner.work_items issued_writer WHERE issued_writer.master_session_id=w.master_session_id AND issued_writer.kind='narration' AND issued_writer.authority_receipt_id=w.authority_receipt_id)
   AND EXISTS(SELECT 1 FROM mission_generic_owner.unified_source_windows sw
    WHERE sw.id=w.authority_receipt_id AND sw.work_id=w.id AND sw.master_session_id=w.master_session_id
    AND sw.source_sha256=w.payload_sha256 AND sw.definition_sha256=w.definition_sha256
    AND sw.step_key=w.step_key AND sw.run_control_version=w.run_control_version
    AND sw.consumed_message_id IS NULL AND sw.superseded_at IS NULL))
  OR(w.kind='narration' AND w.payload->>'schema_version'='mission-generic-narration/2'
   AND w.payload->>'mode'='mission' AND w.result->>'schema_version'='mission-generic-result/1'
   AND w.payload->>'opening_start_receipt_id'=w.authority_receipt_id::text
   AND EXISTS(SELECT 1 FROM mission_generic_owner.board_starts own_start WHERE own_start.id=w.authority_receipt_id AND own_start.master_session_id=w.master_session_id))

  OR(w.kind='choice' AND w.payload->>'schema_version'='mission-generic-choice/1'
   AND w.result->>'schema_version'='mission-generic-result/1' AND w.payload->'simulated'='true'::jsonb
   AND EXISTS(SELECT 1 FROM mission_generic_owner.panel_choices pc
    JOIN mission_generic_owner.encounters en ON en.encounter_id=pc.encounter_id AND en.master_session_id=pc.master_session_id
    JOIN public.combat_v2_sessions cs ON cs.id=en.encounter_id AND cs.master_session_id=w.master_session_id
    JOIN public.combat_v2_rounds rd ON rd.session_id=cs.id AND rd.id::text=w.payload->>'round_id'
    JOIN public.combat_v2_actors ca ON ca.id=pc.actor_id AND ca.session_id=cs.id
    WHERE pc.id=w.authority_receipt_id AND pc.id::text=w.payload->>'capability_id'
    AND pc.work_id=w.id AND pc.master_session_id=w.master_session_id AND pc.encounter_id=w.encounter_id
    AND pc.encounter_id::text=w.payload->>'combat_session_id' AND pc.actor_id::text=w.payload->>'actor_id'
    AND pc.request_key::text=w.payload->>'command_request_key' AND pc.context_version::text=w.payload->>'context_version'
    AND pc.legal_options=w.payload->'legal_options' AND pc.options_sha256=public.combat_v2_sha256(pc.legal_options)
    AND pc.legal_options#>>'{context,simulated}'='true' AND pc.legal_options#>>'{context,round_id}'=rd.id::text
    AND pc.legal_options#>>'{context,activity_id}'=cs.id::text
    AND pc.consumed_at IS NULL AND pc.result IS NULL AND pc.command_sha256 IS NULL
    AND ca.actor_kind='png' AND ca.controller_user IS NULL AND ca.character_id IS NULL AND ca.companion_id IS NULL
    AND cs.location_id='0b85f354-9cdb-47e1-baf9-3d266bb7e06b'::uuid
    AND en.step_key=w.step_key AND en.run_control_version=w.run_control_version
    AND public.combat_v2_values_written(cs.id) IS FALSE AND combat_panel_private.uses_simulated_pools(cs.id) IS TRUE
    AND NOT EXISTS(SELECT 1 FROM combat_panel_private.request_receipts effect WHERE effect.principal_user=pc.principal_id AND effect.request_key=pc.request_key)
    AND NOT EXISTS(SELECT 1 FROM mission_generic_owner.panel_permits effect WHERE effect.work_id=w.id AND effect.operation='commit')))
  OR(w.kind='narration' AND w.payload->>'schema_version'='mission-generic-narration/2' AND w.payload->>'mode'='combat'
   AND w.result->>'schema_version'='mission-generic-result/1'
   AND w.payload#>>'{barrier,closed}'='true'
   AND w.payload#>'{barrier,required_receipt_ids}'=jsonb_build_array(w.authority_receipt_id)
   AND w.payload#>'{barrier,receipt_ids}'=jsonb_build_array(w.authority_receipt_id)
   AND EXISTS(SELECT 1 FROM public.combat_v2_round_reports rep
    JOIN public.combat_v2_rounds rd ON rd.id=rep.round_id AND rd.report_id=rep.id
    JOIN public.combat_v2_sessions cs ON cs.id=rd.session_id AND cs.master_session_id=w.master_session_id
    JOIN mission_generic_owner.encounters en ON en.encounter_id=cs.id AND en.master_session_id=w.master_session_id
    WHERE rep.id=w.authority_receipt_id AND cs.id=w.encounter_id
    AND w.payload#>>'{scene_binding,session_id}'=cs.id::text AND w.payload#>>'{scene_binding,round_id}'=rd.id::text
    AND w.payload#>>'{scene_binding,report_sha256}'=rep.mechanics_sha256
    AND w.payload#>>'{scene_binding,control_version}'=w.run_control_version::text
    AND w.payload#>>'{scene_binding,hash_authority}'='combat_v2_sha256/jsonb'
    AND w.payload#>>'{scene_binding,scene_sha256}'=public.combat_v2_sha256(w.payload#>'{scene,snapshot}')
    AND w.payload#>>'{scene,snapshot_sha256}'=w.payload#>>'{scene_binding,scene_sha256}'
    AND rep.mechanics_sha256=public.combat_v2_sha256(rep.mechanics)
    AND rd.state='risolto' AND rd.resolved_at IS NOT NULL AND rep.narration_state='attesa' AND rep.message_id IS NULL
    AND rep.values_written IS FALSE AND public.combat_v2_values_written(cs.id) IS FALSE AND combat_panel_private.uses_simulated_pools(cs.id) IS TRUE
    AND en.step_key=w.step_key AND en.run_control_version=w.run_control_version
    AND cs.location_id='0b85f354-9cdb-47e1-baf9-3d266bb7e06b'::uuid
    AND NOT EXISTS(SELECT 1 FROM public.combat_v2_narratives emitted WHERE emitted.report_id=rep.id)
    AND NOT EXISTS(SELECT 1 FROM mission_generic_owner.unified_report_publications emitted WHERE emitted.report_id=rep.id)))
  OR(w.kind='narration' AND w.payload->>'mode'='unified'
   AND ((w.payload->>'schema_version'='mission-generic-narration/3' AND w.result->>'schema_version'='mission-generic-result/1')
    OR(w.payload->>'schema_version'='mission-generic-narration/4' AND w.result->>'schema_version'='mission-generic-result/2' AND jsonb_typeof(w.result->'segments')='null'))
   AND EXISTS(SELECT 1 FROM mission_generic_owner.unified_batches ub
    JOIN mission_generic_owner.unified_source_windows sw ON sw.id=ub.source_window_id
    WHERE ub.id=w.authority_receipt_id AND ub.writer_work_id=w.id AND ub.master_session_id=w.master_session_id
    AND ub.state='ready' AND ub.message_id IS NULL AND ub.payload=w.payload AND ub.payload_sha256=w.payload_sha256
    AND ub.decision_sha256=public.combat_v2_sha256(ub.decision)
    AND w.payload->>'batch_id'=ub.id::text AND w.payload->>'preparation_receipt_id'=ub.id::text AND w.payload->>'next_state_receipt_id'=ub.id::text
    AND w.payload#>>'{publication_barrier,closed}'='true'
    AND w.payload#>'{publication_barrier,required_receipt_ids}'=w.payload#>'{publication_barrier,receipt_ids}'
    AND w.payload#>'{publication_barrier,receipt_ids}'@>jsonb_build_array(ub.id)
    AND ub.step_key=w.step_key AND ub.run_control_version=w.run_control_version
    AND ub.decision->>'schema_version'='mission-director-proposal/4'
    AND w.payload->'director_proposal'=ub.decision-'role_disposition'
    AND w.payload->'role_disposition'=ub.decision->'role_disposition' AND w.payload->'role_interpretation'=ub.decision->'role_interpretation'
    AND sw.master_session_id=w.master_session_id AND sw.work_id=ub.decision_work_id
    AND sw.definition_sha256=w.definition_sha256 AND sw.step_key=w.step_key
    AND sw.run_control_version=w.run_control_version AND sw.consumed_message_id IS NULL AND sw.superseded_at IS NULL)))
 -- The Count reservation is retained, not refunded. The successful Count and immutable request remain bound.
 AND (SELECT count(*) FROM mission_narrative_internal.dispatch_audit one_count WHERE one_count.receipt_id=w.dispatch_receipt_id AND one_count.event_code='c8_count_started')=1
 AND (SELECT count(*) FROM mission_narrative_internal.dispatch_audit one_count WHERE one_count.receipt_id=w.dispatch_receipt_id AND one_count.event_code IN('c8_count_success','c8_count_unknown'))=1
 AND EXISTS(SELECT 1 FROM mission_narrative_internal.dispatch_audit count_start
  JOIN mission_narrative_internal.dispatch_audit count_success ON count_success.receipt_id=count_start.receipt_id AND count_success.event_code='c8_count_success'
  JOIN staff_ai_quota_private.calls retained_count ON retained_count.id::text=count_start.details->>'shared_count_ticket'
  WHERE count_start.receipt_id=w.dispatch_receipt_id AND count_start.event_code='c8_count_started'
  AND count_start.details->>'work_id'=w.id::text AND count_start.details->>'lease_id'=w.lease_id::text
  AND count_success.details->>'work_id'=w.id::text AND count_success.details->>'schema_version'='mission-generic-count-proof/1'
  AND count_start.details->>'measurement_id'=count_success.details->>'measurement_id'
  AND count_start.details->>'generation_request_sha256'=count_success.details->>'generation_request_sha256'
  AND encode(extensions.digest(convert_to(count_start.details->>'generation_request_text','UTF8'),'sha256'),'hex')=count_success.details->>'generation_request_sha256'
  AND w.result->>'request_sha256'=count_success.details->>'generation_request_sha256'
  AND count_start.details->>'policy_snapshot_sha256'=count_success.details->>'policy_snapshot_sha256'
  AND public.combat_v2_sha256(count_start.details->'policy_snapshot')=count_success.details->>'policy_snapshot_sha256'
  AND count_success.details->>'state'='success' AND count_success.details->>'generation_allowed'='true'
  AND count_success.details->>'count_http_calls'='1' AND count_success.details->>'generation_http_calls'='0'
  AND count_start.details->>'execution_context'='staff_mission'
  AND count_start.details->>'admission_sha256'=public.combat_v2_sha256(mission_generic_owner.c1266_historical_work_v1(w.id)->'admission')
  AND count_start.details->>'shared_count_scope'=w.master_session_id::text AND count_start.details->>'shared_count_source'=w.dispatch_receipt_id::text AND count_start.details->>'shared_count_call_no'='2'
  AND retained_count.producer='mission_generic_ai' AND retained_count.scope_id=w.master_session_id AND retained_count.source_id=w.dispatch_receipt_id
  AND retained_count.call_no=2 AND retained_count.state='unknown_billable' AND retained_count.charged_usd IS NULL AND retained_count.reserved_usd=0.0124)

 AND w.finalized_at IS NOT NULL AND w.receipt_id IS NOT NULL AND w.message_id IS NULL
 AND w.lease_expires_at IS NOT NULL AND w.lease_expires_at<=clock_timestamp()
 AND w.result->>'ok'='false'

 AND (w.kind<>'director' OR jsonb_typeof(w.result->'decision')='null') AND jsonb_typeof(w.result->'command')='null'
 AND EXISTS(SELECT 1 FROM mission_narrative_internal.dispatch_audit terminal_final_audit WHERE terminal_final_audit.receipt_id=w.dispatch_receipt_id AND terminal_final_audit.event_code='generic_finalized' AND terminal_final_audit.details->>'work_id'=w.id::text AND terminal_final_audit.details->>'receipt_id'=w.receipt_id::text AND terminal_final_audit.details->>'result_sha256'=w.result_sha256 AND terminal_final_audit.details->>'result_jsonb_sha256'=public.combat_v2_sha256(w.result) AND terminal_final_audit.details->>'state'=w.state::text AND terminal_final_audit.details->>'cost_basis'=CASE WHEN w.state='uncertain' THEN 'upper_bound' ELSE 'exact' END AND terminal_final_audit.details->>'stale'='false' AND terminal_final_audit.details->>'outcome_uncertain'=w.result->>'outcome_uncertain' AND jsonb_typeof(terminal_final_audit.details->'message_id')='null' AND jsonb_typeof(terminal_final_audit.details->'command_receipt')='null' AND jsonb_typeof(terminal_final_audit.details->'application_error_code')='null' AND jsonb_typeof(terminal_final_audit.details->'application_error_sqlstate')='null')
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
 AND EXISTS(SELECT 1 FROM mission_narrative_internal.dispatch_receipts paid_receipt
  JOIN mission_narrative_internal.provider_authorizations paid_authorization
   ON paid_authorization.id=w.authorization_id AND paid_authorization.receipt_id=paid_receipt.id
  JOIN mission_narrative_internal.dispatch_attempts paid_attempt
   ON paid_attempt.id=paid_authorization.attempt_id AND paid_attempt.receipt_id=paid_receipt.id
  WHERE paid_receipt.id=w.dispatch_receipt_id AND paid_receipt.master_session_id=w.master_session_id
  AND paid_receipt.authority_receipt_id=w.id AND paid_receipt.request_key=w.request_key
  AND paid_receipt.event_kind='mission_generic_event' AND paid_receipt.renderer_version='mission-generic-runtime/1'
  AND paid_receipt.status=CASE WHEN w.state='uncertain' THEN 'unknown_billable' ELSE 'success' END AND paid_receipt.finalized_at IS NOT NULL AND paid_receipt.dispatch_count=1
  AND paid_receipt.charged_cost_usd IS NOT NULL AND paid_receipt.charged_cost_usd>=0
  AND paid_receipt.charged_cost_usd<=paid_receipt.upper_bound_cost_usd
  AND paid_receipt.lease_token_sha256 IS NULL AND paid_receipt.lease_expires_at IS NULL AND paid_authorization.finalize_token_sha256 IS NULL
  AND paid_attempt.cost_basis=CASE WHEN w.state='uncertain' THEN 'upper_bound' ELSE 'exact' END
  AND (w.state<>'uncertain' OR (paid_receipt.charged_cost_usd=0.0124 AND paid_receipt.upper_bound_cost_usd=0.0124))
  AND paid_attempt.actual_cost_usd=paid_receipt.charged_cost_usd
  AND (SELECT count(*) FROM mission_narrative_internal.dispatch_attempts single_attempt WHERE single_attempt.receipt_id=paid_receipt.id)=1
  AND paid_receipt.envelope->>'payload_sha256'=w.payload_sha256
  AND paid_attempt.status=CASE WHEN w.state='uncertain' THEN 'unknown_billable' ELSE 'success' END AND paid_attempt.finalized_at IS NOT NULL
  AND NOT EXISTS(SELECT 1 FROM mission_narrative_internal.dispatch_attempts unresolved_attempt
   WHERE unresolved_attempt.receipt_id=paid_receipt.id
   AND(unresolved_attempt.status<>CASE WHEN w.state='uncertain' THEN 'unknown_billable' ELSE 'success' END OR unresolved_attempt.finalized_at IS NULL))
  AND EXISTS(SELECT 1 FROM staff_ai_quota_private.calls settled_generation
   WHERE settled_generation.producer='mission_generic_ai' AND settled_generation.reserved_usd=0.0124
   AND settled_generation.source_id=paid_receipt.id AND settled_generation.scope_id=w.master_session_id
   AND settled_generation.call_no=1 AND settled_generation.state=CASE WHEN w.state='uncertain' THEN 'unknown_billable' ELSE 'settled' END
   AND ((w.state='failed' AND settled_generation.charged_usd=paid_receipt.charged_cost_usd) OR(w.state='uncertain' AND (settled_generation.charged_usd IS NULL OR settled_generation.charged_usd=paid_receipt.charged_cost_usd)))))) IS TRUE) OR 
  -- C1266 OWN CLEANUP7: this immutable terminal receipt only; no narrative acceptance or retry.
  ((w.id='59ec7e51-0627-4c69-bd32-028f1c2fd055'::uuid
 AND p_session='c21baa1a-cdac-4401-9131-493eef208a21'::uuid
 AND w.master_session_id='c21baa1a-cdac-4401-9131-493eef208a21'::uuid
 AND w.authority_receipt_id=w.id
 AND w.receipt_id='b8516441-150e-4e78-9b06-f6ce79301b5f'::uuid
 AND w.dispatch_receipt_id='4dc24e1e-be05-4a90-8e9a-4c0b4e3312c9'::uuid
 AND w.dispatch_id='1b42af27-1e8f-4ee3-9b2d-741d0bd1ade6'::uuid
 AND w.authorization_id='f6f845e3-fe85-4d3e-b4ee-54b713c0d523'::uuid
 AND w.payload_sha256='b6b14db30f4f6ace88d144f071f25f4c33866c2c0e71baba75acc01460952d86'
 AND w.result_sha256='946f1513df2c3cd453de2ba6be4c4fe3e465d3f90a724d7b977085f0eaf32107'
 AND public.combat_v2_sha256(w.result)='16626266c62ed54639f53abe8d90beee2c2925bd12e4ca9aaa92be47d5b1baf6'
 AND w.finalized_at='2026-10-17T14:25:12.971635+00:00'::timestamptz
 AND w.lease_expires_at='2026-10-17T14:29:04.418908+00:00'::timestamptz
 AND w.result->>'schema_version'='mission-generic-result/1'
 AND w.result->>'provider_status'='completed'
 AND (SELECT count(*) FROM mission_narrative_internal.dispatch_audit unique_final
  WHERE unique_final.receipt_id=w.dispatch_receipt_id AND unique_final.event_code='generic_finalized')=1
 AND NOT EXISTS(SELECT 1 FROM mission_generic_owner.unified_segment_publications_v4 own_publication WHERE own_publication.work_id=w.id)
 AND EXISTS(SELECT 1 FROM staff_ai_quota_private.calls retained_count
  WHERE retained_count.id='5ff1888d-f447-4adc-90a1-3a71f3756080'::uuid
  AND retained_count.producer='mission_generic_ai' AND retained_count.scope_id=w.master_session_id
  AND retained_count.source_id=w.dispatch_receipt_id AND retained_count.call_no=2
  AND retained_count.state='unknown_billable' AND retained_count.charged_usd IS NULL AND retained_count.reserved_usd=0.0124)
 AND EXISTS(SELECT 1 FROM mission_narrative_internal.dispatch_audit count_start
  JOIN mission_narrative_internal.dispatch_audit count_success ON count_success.receipt_id=count_start.receipt_id
  AND count_success.event_code='c8_count_success'
  WHERE count_start.receipt_id=w.dispatch_receipt_id AND count_start.event_code='c8_count_started'
  AND count_start.details->>'work_id'=w.id::text
  AND count_start.details->>'shared_count_ticket'='5ff1888d-f447-4adc-90a1-3a71f3756080'
  AND count_start.details->>'measurement_id'='e99eb70c-20b6-403b-85a5-40dbd155a332'
  AND count_success.details->>'measurement_id'=count_start.details->>'measurement_id'
  AND count_success.details->>'work_id'=w.id::text
  AND count_success.details->>'schema_version'='mission-generic-count-proof/1'
  AND count_success.details->>'state'='success' AND count_success.details->>'generation_allowed'='true'
  AND count_success.details->>'count_http_calls'='1' AND count_success.details->>'generation_http_calls'='0')
 AND w.state='failed' AND w.kind='director'
 AND w.payload->>'schema_version'='mission-director-work/4'
 AND w.finalized_at IS NOT NULL AND w.receipt_id IS NOT NULL AND w.message_id IS NULL
 AND w.lease_expires_at IS NOT NULL AND w.lease_expires_at<=clock_timestamp()
 AND w.result->>'ok'='false' AND w.result->>'outcome_uncertain'='false'
 AND w.result->'failure_codes'='["MISSION_ROLE_TEMPORAL_SEQUENCE_LITERAL_COVERAGE_INVALID"]'::jsonb
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
  AND paid_authorization.attempt_id='739ce8a3-fb14-410e-9d3f-e1e47186ccef'::uuid
  AND paid_attempt.actual_cost_usd=0.0074534 AND paid_receipt.charged_cost_usd=0.0074534
  AND paid_receipt.upper_bound_cost_usd=0.0124
  AND paid_attempt.status='success' AND paid_attempt.finalized_at IS NOT NULL
  AND NOT EXISTS(SELECT 1 FROM mission_narrative_internal.dispatch_attempts unresolved_attempt
   WHERE unresolved_attempt.receipt_id=paid_receipt.id
   AND(unresolved_attempt.status<>'success' OR unresolved_attempt.finalized_at IS NULL))
  AND EXISTS(SELECT 1 FROM staff_ai_quota_private.calls settled_generation
   WHERE settled_generation.id='040bd9e0-1e4d-4e06-9b04-19c1420a3d73'::uuid
   AND settled_generation.producer='mission_generic_ai' AND settled_generation.reserved_usd=0.0124
   AND settled_generation.source_id=paid_receipt.id AND settled_generation.scope_id=w.master_session_id
   AND settled_generation.call_no=1 AND settled_generation.state='settled'
   AND settled_generation.charged_usd=paid_receipt.charged_cost_usd))) IS TRUE) OR (mission_generic_owner.c1266_generation_timeout_terminal_proof_v1(w.id)IS NOT NULL) OR (mission_generic_owner.c1266_count_terminal_proof_v1(w.id,true)IS NOT NULL) OR ((w.id='d8b37311-6010-4a07-95d3-5e65a33c756d'::uuid AND w.master_session_id='9ac00210-4c88-4c0c-a443-95e3d6740a28'::uuid
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
