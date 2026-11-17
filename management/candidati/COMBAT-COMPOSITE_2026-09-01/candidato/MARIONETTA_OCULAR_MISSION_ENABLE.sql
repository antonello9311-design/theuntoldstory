-- Apertura limitata al supporto Combat Regia IA dopo una sola prova Staff positiva e chiusa.
BEGIN;
SET LOCAL lock_timeout='3s';
SET LOCAL statement_timeout='30s';
DO $qualification$
DECLARE candidates bigint;
BEGIN
  PERFORM clan_innata_private.eligibility_release_assert();
  IF (SELECT md5(prosrc) FROM pg_proc WHERE oid=to_regprocedure('clan_marionettisti_private.bind_mission_companions_v1(uuid,uuid,uuid,uuid)'))
      IS DISTINCT FROM '059e647e5ca1c0ac55dbdbb751749395'
    OR (SELECT md5(prosrc) FROM pg_proc WHERE oid=to_regprocedure('clan_marionettisti_private.ocular_sever_source_v1(uuid,uuid,uuid,numeric)'))
      IS DISTINCT FROM '84212d9903c799efd10a176de47b7169'
    OR (SELECT md5(prosrc) FROM pg_proc WHERE oid=to_regprocedure('clan_marionettisti_private.mission_companion_valid(uuid,uuid,uuid)'))
      IS DISTINCT FROM '9c5130bed1c357881f51e596d5b61896'
    OR (SELECT md5(prosrc) FROM pg_proc WHERE oid=to_regprocedure('mission_generic_owner.combat_narrative_source(uuid,uuid)'))
      IS DISTINCT FROM '4a468b3e6b9a693523616c99a52f45d5'
    OR (SELECT md5(prosrc) FROM pg_proc WHERE oid=to_regprocedure('mission_generic_owner.bind_arena_native(uuid,uuid,uuid)'))
      IS DISTINCT FROM '258d5edb71a9a74e71504ec684268f42'
  THEN RAISE EXCEPTION 'FILI_MISSION_LAND_BASELINE_CHANGED' USING ERRCODE='40001'; END IF;
  PERFORM 1 FROM clan_marionettisti_private.mission_companion_release_v1
   WHERE singleton AND NOT land_enabled FOR UPDATE;
  IF NOT FOUND THEN RAISE EXCEPTION 'FILI_MISSION_LAND_GATE_CHANGED' USING ERRCODE='40001'; END IF;

WITH staff_source AS (
  SELECT rev.definition_id,rev.mission_id,rev.plan_version_id
  FROM mission_creation_owner.h3_staff_source_requests req
  JOIN mission_generic_owner.plan_revisions rev ON rev.mission_id=req.mission_id
    AND rev.plan_version_id=(req.result->>'plan_version_id')::uuid
  JOIN mission_creation_owner.revisions doc ON doc.mission_id=req.mission_id AND doc.plan_version_id=rev.plan_version_id
    AND doc.direction_mode='ai' AND doc.document_sha256=req.document_sha256
    AND doc.document_sha256=mission_internal.fingerprint(doc.document)
  JOIN mission_generic_owner.definitions def ON def.id=rev.definition_id AND def.plan_version_id=rev.plan_version_id
    AND def.definition=doc.document#>'{plan,definition}' AND def.definition_sha256=mission_internal.fingerprint(def.definition)
  WHERE req.document_sha256='6a1c785a06464fcc3310727bc700f767c77fbf411982ba87090e009ec470210f'
    AND req.request_key='14136a56-0f58-41b2-ae24-8f7f3acbb4b2'::uuid
    AND req.mission_id='e41dec32-ee10-4fba-8647-1ea137d41e3a'::uuid
    AND rev.plan_version_id='17de0505-46c6-4d84-9407-353a4621f367'::uuid
    AND rev.definition_id='7971336f-3794-46e6-b8e6-52c1d1b763a9'::uuid
), qualified_cut AS (
  SELECT master.id AS master_session_id,fight.id AS encounter_id,turn.id AS round_id,
    attack.id AS attack_id,cut.event_id AS cut_event_id,conf.owner_actor_id,conf.body_actor_id,
    report.id AS report_id,report.mechanics_sha256,msg.id AS message_id,
    encode(extensions.digest(convert_to(msg.body,'UTF8'),'sha256'),'hex') AS fato_sha256,
    writer.id AS writer_work_id,writer.receipt_id AS writer_receipt_id,
    writer.dispatch_receipt_id,writer.payload_sha256,writer.result_sha256,
    attack.outcome->'damage_applied' AS damage_applied,
    body_before.snapshot#>'{mechanics,vita}' AS integrity_before,
    body_after.snapshot#>'{mechanics,vita}' AS integrity_after,
    body_after.snapshot#>'{mechanics,vita_max}' AS full_integrity,
    attack.outcome->'target_hp_after' AS outcome_integrity_after,report.values_written
  FROM staff_source src
  JOIN clan_marionettisti_private.mission_companion_entitlements_v1 entitlement
    ON entitlement.id='4f82448a-b874-4be9-9883-b6149c0dc18e'::uuid
    AND entitlement.definition_id=src.definition_id AND entitlement.staff_enabled AND NOT entitlement.land_enabled
    AND entitlement.step_key='inizio' AND entitlement.encounter_key='enc_inizio' AND entitlement.actor_key='png_1'
    AND entitlement.mechanical_binding_id='dec31d7d-5314-4f41-b68b-8f7b1f8fb002'::uuid
  JOIN clan_marionettisti_private.mission_companion_receipts_v1 conf ON conf.entitlement_id=entitlement.id
    AND conf.actor_key=entitlement.actor_key AND conf.mechanical_binding_id=entitlement.mechanical_binding_id AND conf.simulated
  JOIN mission_generic_owner.encounters encounter ON encounter.encounter_id=conf.session_id
    AND encounter.capability_id=conf.capability_id AND encounter.step_key=entitlement.step_key
    AND encounter.encounter_key=entitlement.encounter_key
  JOIN public.combat_v2_sessions fight ON fight.id=encounter.encounter_id AND fight.source_kind='master'
    AND fight.closed_at IS NOT NULL AND NOT fight.lesiva
  JOIN public.master_v2_sessions master ON master.id=encounter.master_session_id AND master.id=fight.master_session_id
    AND master.owner_kind='ai_service' AND master.master_user IS NULL AND master.closed_at IS NOT NULL
    AND master.location_id='0b85f354-9cdb-47e1-baf9-3d266bb7e06b'::uuid AND fight.location_id=master.location_id
  JOIN public.locations loc ON loc.id=master.location_id AND loc.is_test
  JOIN mission_generic_owner.simulation_sources carrier ON carrier.carrier_mission_id=master.mission_id
    AND carrier.source_mission_id=src.mission_id AND carrier.source_plan_version_id=src.plan_version_id
  JOIN clan_marionettisti_private.control_events cut ON cut.session_id=fight.id
    AND cut.owner_actor_id=conf.owner_actor_id AND cut.kind='link_severed'
    AND cut.payload->>'authority'='ocular-sever/1' AND cut.payload->>'companion_actor_id'=conf.body_actor_id::text
  JOIN public.combat_v2_rounds turn ON turn.id=cut.round_id AND turn.session_id=fight.id AND turn.state='narrato'
  JOIN public.combat_v2_declarations attack ON attack.id=cut.source_declaration_id AND attack.round_id=turn.id
    AND attack.target_actor_id=conf.body_actor_id AND attack.kind='attacco' AND attack.state='risolta'
    AND attack.sanitized_intent->'target_fili'='true'::jsonb
    AND attack.outcome @> '{"fili_recisi":true,"success":true,"damage_applied":0,"target_hp_after":30}'::jsonb
    AND cut.request_key=attack.id AND cut.fingerprint=public.combat_v2_sha256(attack.outcome)
  JOIN public.combat_v2_round_reports report ON report.id=turn.report_id AND report.round_id=turn.id
    AND report.narration_state='pubblicata' AND NOT report.values_written
    AND report.mechanics_sha256=public.combat_v2_sha256(report.mechanics)
  JOIN LATERAL jsonb_array_elements(report.mechanics->'initial_actors') body_before(snapshot)
    ON body_before.snapshot->>'actor'=conf.body_actor_id::text
    AND body_before.snapshot->>'state'='attivo'
    AND body_before.snapshot#>'{mechanics,vita}'='30'::jsonb
    AND body_before.snapshot#>'{mechanics,vita_max}'='30'::jsonb
  JOIN LATERAL jsonb_array_elements(report.mechanics->'final_actors') body_after(snapshot)
    ON body_after.snapshot->>'actor'=conf.body_actor_id::text
    AND body_after.snapshot->>'state'='attivo'
    AND body_after.snapshot#>'{mechanics,vita}'=body_before.snapshot#>'{mechanics,vita}'
    AND body_after.snapshot#>'{mechanics,vita_max}'=body_before.snapshot#>'{mechanics,vita_max}'
    AND body_after.snapshot#>'{mechanics,vita}'=attack.outcome->'target_hp_after'
  LEFT JOIN mission_generic_owner.unified_report_publications unified ON unified.report_id=report.id
    AND unified.round_id=turn.id
  JOIN public.messages msg ON msg.id=coalesce(unified.message_id,report.message_id) AND msg.location_id=master.location_id
    AND msg.kind='fato' AND msg.character_id IS NULL AND msg.sender_user IS NULL AND msg.recipient_user IS NULL
  JOIN public.combat_v2_narratives narrative ON narrative.round_id=turn.id AND narrative.report_id=report.id
    AND narrative.kind='fato_ia' AND narrative.author_user IS NULL AND narrative.body=msg.body
  JOIN mission_generic_owner.work_items writer ON writer.master_session_id=master.id AND writer.encounter_id=fight.id
    AND writer.state='completed' AND writer.kind='narration' AND writer.finalized_at IS NOT NULL
    AND writer.receipt_id IS NOT NULL AND writer.message_id=msg.id AND writer.result->>'text'=msg.body
    AND writer.payload_sha256=public.combat_v2_sha256(writer.payload)
    AND (writer.authority_receipt_id=report.id OR EXISTS(
      SELECT 1 FROM mission_generic_owner.unified_batches batch
      WHERE batch.id=unified.batch_id AND batch.id=writer.authority_receipt_id
        AND batch.writer_work_id=writer.id AND batch.master_session_id=master.id
        AND batch.encounter_id=fight.id AND batch.state='published' AND batch.message_id=msg.id))
  JOIN mission_narrative_internal.dispatch_receipts dispatch ON dispatch.id=writer.dispatch_receipt_id
    AND dispatch.master_session_id=master.id AND dispatch.authority_receipt_id=writer.id
    AND dispatch.request_key=writer.request_key AND dispatch.status='success'
    AND dispatch.dispatch_count=1 AND dispatch.finalized_at IS NOT NULL
  JOIN LATERAL (
    SELECT writer.payload AS payload WHERE writer.payload->>'mode'='combat'
    UNION ALL
    SELECT coalesce(item->'native_scene',item)
    FROM jsonb_array_elements(CASE WHEN jsonb_typeof(writer.payload->'resolved_scenes')='array'
      THEN writer.payload->'resolved_scenes' ELSE '[]'::jsonb END) item
  ) input ON input.payload#>>'{scene_binding,session_id}'=fight.id::text
    AND input.payload#>>'{scene_binding,round_id}'=turn.id::text
    AND input.payload#>>'{scene_binding,report_sha256}'=report.mechanics_sha256
    AND input.payload#>>'{scene,snapshot_sha256}'=public.combat_v2_sha256(input.payload#>'{scene,snapshot}')
    AND input.payload#>'{barrier,closed}'='true'::jsonb
    AND input.payload#>'{barrier,receipt_ids}'=jsonb_build_array(report.id)
    AND input.payload#>'{barrier,required_receipt_ids}'=jsonb_build_array(report.id)
  WHERE nullif(btrim(msg.body),'') IS NOT NULL
    AND NOT public.combat_v2_values_written(fight.id)
    AND clan_marionettisti_private.mission_companion_valid(fight.id,conf.owner_actor_id,conf.body_actor_id)
    AND EXISTS(SELECT 1 FROM jsonb_array_elements(report.mechanics->'declarations') sealed
      WHERE sealed->>'id'=attack.id::text AND sealed->'outcome'=attack.outcome)
    AND EXISTS(SELECT 1 FROM jsonb_array_elements((input.payload#>>'{scene,snapshot,resolved_facts}')::jsonb->'declarations') fact
      WHERE fact->>'declaration_id'=attack.id::text AND fact#>'{facts,fili_chakra}' @>
        jsonb_build_object('esito','recisi','nessun_danno_al_corpo',true,
          'marionetta_actor_id',conf.body_actor_id,'controllore_actor_id',conf.owner_actor_id))
    AND EXISTS(SELECT 1 FROM mission_narrative_internal.dispatch_audit audit
      WHERE audit.receipt_id=dispatch.id AND audit.event_code='generic_finalized'
        AND audit.details @> jsonb_build_object('work_id',writer.id,'receipt_id',writer.receipt_id,
          'message_id',msg.id,'state','completed','stale',false,'outcome_uncertain',false,
          'application_error_sqlstate',NULL,'result_jsonb_sha256',public.combat_v2_sha256(writer.result)))
    AND NOT EXISTS(SELECT 1 FROM public.combat_v2_resource_ledger ledger
      WHERE ledger.session_id=fight.id AND ledger.is_simulated IS DISTINCT FROM TRUE)
)
SELECT count(*) INTO candidates FROM qualified_cut;
  IF candidates<>1 THEN
    RAISE EXCEPTION 'FILI_MISSION_STAFF_QUALIFICATION_MISSING_OR_AMBIGUOUS' USING ERRCODE='55000';
  END IF;

  UPDATE clan_marionettisti_private.mission_companion_release_v1
     SET land_enabled=true,updated_at=clock_timestamp()
   WHERE singleton AND NOT land_enabled;
  IF NOT FOUND THEN RAISE EXCEPTION 'FILI_MISSION_LAND_GATE_CHANGED' USING ERRCODE='40001'; END IF;
END;
$qualification$;
COMMIT;
