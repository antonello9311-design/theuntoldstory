BEGIN;
SET LOCAL lock_timeout='3s';
SET LOCAL statement_timeout='25s';
DO $staff_npc_run_preflight$
BEGIN
  IF md5(pg_get_functiondef('clan_marionettisti_private.staff_companion_npc_bundle_valid_v1(uuid,uuid,uuid)'::regprocedure)) IS DISTINCT FROM '12fbeaa4d6c64b93b89d264faa206321'
    OR NOT EXISTS (
      SELECT 1 FROM pg_proc
      WHERE oid='clan_marionettisti_private.staff_companion_npc_bundle_valid_v1(uuid,uuid,uuid)'::regprocedure
        AND pg_get_userbyid(proowner)='postgres'
        AND proacl='{postgres=X/postgres}'::aclitem[]
    )
  THEN
    RAISE EXCEPTION 'Baseline o permessi del certificato PNG Staff non corrispondenti' USING ERRCODE='40001';
  END IF;
END;
$staff_npc_run_preflight$;

CREATE OR REPLACE FUNCTION clan_marionettisti_private.staff_companion_npc_bundle_valid_v1(p_master uuid, p_binding uuid, p_bundle uuid)
 RETURNS boolean
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO ''
AS $function$
DECLARE certified png_builder_internal.bundles%ROWTYPE;
BEGIN
  -- Lo stesso certificato resta vincolato alla fonte Staff e al run attestato.
  IF p_master IS NULL
    OR p_binding IS DISTINCT FROM 'dec31d7d-5314-4f41-b68b-8f7b1f8fb002'::uuid
    OR p_bundle IS DISTINCT FROM '26164714-6aa3-4d7c-8833-0d1cc9d8b860'::uuid
  THEN RETURN false; END IF;

  SELECT bundle.* INTO certified
  FROM public.master_v2_sessions master
  JOIN public.locations room ON room.id=master.location_id AND room.is_active AND room.is_test
  JOIN mission_generic_owner.simulation_sources lineage ON lineage.carrier_mission_id=master.mission_id
  JOIN mission_creation_owner.h3_staff_source_requests author ON author.mission_id=lineage.source_mission_id
    AND author.request_key='14136a56-0f58-41b2-ae24-8f7f3acbb4b2'::uuid
    AND author.document_sha256='6a1c785a06464fcc3310727bc700f767c77fbf411982ba87090e009ec470210f'
    AND author.result->>'mission_id'=lineage.source_mission_id::text
    AND author.result->>'plan_version_id'=lineage.source_plan_version_id::text
  JOIN mission_generic_owner.plan_revisions source_revision ON source_revision.plan_version_id=lineage.source_plan_version_id
    AND source_revision.mission_id=lineage.source_mission_id
  JOIN mission_creation_owner.revisions source_document ON source_document.plan_version_id=source_revision.plan_version_id
    AND source_document.mission_id=source_revision.mission_id AND source_document.direction_mode='ai'
    AND source_document.document_sha256=author.document_sha256
    AND source_document.document_sha256=mission_internal.fingerprint(source_document.document)
  JOIN mission_generic_owner.definitions source_definition ON source_definition.id=source_revision.definition_id
    AND source_definition.plan_version_id=source_revision.plan_version_id
    AND source_definition.definition=source_document.document#>'{plan,definition}'
    AND source_definition.definition_sha256=mission_internal.fingerprint(source_definition.definition)
  JOIN mission_generic_owner.run_bindings frozen ON frozen.master_session_id=master.id
    AND frozen.snapshot_sha256=mission_internal.fingerprint(frozen.snapshot)
    AND frozen.snapshot->'definition'=source_definition.definition
    AND frozen.snapshot->>'definition_sha256'=source_definition.definition_sha256
  JOIN mission_generic_owner.definitions carrier_definition ON carrier_definition.id=frozen.definition_id
    AND carrier_definition.definition=source_definition.definition
    AND carrier_definition.definition_sha256=source_definition.definition_sha256
  JOIN public.mission_run_state run ON run.master_session_id=master.id
    AND run.mission_id=master.mission_id AND run.source_kind='mission'
    AND run.run_phase='in_corso' AND run.current_step_key='inizio'
    AND run.plan_version_id=carrier_definition.plan_version_id
    AND run.plan_version_id::text=frozen.snapshot->>'plan_version_id'
    AND run.plan_sha256=carrier_definition.plan_sha256
    AND run.plan_sha256=frozen.snapshot->>'plan_sha256'
  JOIN mission_generic_owner.start_claims start_claim ON start_claim.session_id=master.id
    AND start_claim.request_key=lineage.request_key AND start_claim.mission_id=master.mission_id
    AND start_claim.location_id=room.id AND start_claim.definition_id=carrier_definition.id
    AND start_claim.simulation AND start_claim.state='bound'
  JOIN mission_generic_owner.board_starts start_receipt ON start_receipt.master_session_id=master.id
    AND start_receipt.request_key=start_claim.request_key
    AND start_receipt.request_fingerprint=lineage.request_fingerprint
    AND start_receipt.simulation AND start_receipt.state='published'
    AND start_receipt.snapshot_sha256=mission_internal.fingerprint(start_receipt.snapshot)
    AND start_receipt.snapshot->>'mission_id'=master.mission_id::text
    AND start_receipt.snapshot->>'location_id'=room.id::text
    AND start_receipt.snapshot->'simulation'='true'::jsonb
    AND start_receipt.snapshot#>>'{selection,plan_version_id}'=run.plan_version_id::text
    AND start_receipt.snapshot#>>'{selection,plan_sha256}'=run.plan_sha256
    AND start_receipt.snapshot#>>'{selection,definition_id}'=carrier_definition.id::text
    AND start_receipt.snapshot#>>'{selection,definition_sha256}'=carrier_definition.definition_sha256
    AND start_receipt.snapshot->'arena'=frozen.snapshot->'arena'
    AND start_receipt.result->>'master_session_id'=master.id::text
    AND start_receipt.result->>'mission_id'=master.mission_id::text
    AND start_receipt.result->>'start_receipt_id'=start_receipt.id::text
    AND start_receipt.result->'simulation'='true'::jsonb
    AND start_receipt.snapshot->'roster' IN (
      '["2a877f02-4993-4e65-9172-7d29f08c5b86","6bceee99-974f-426b-8d92-38b43b4a4267"]'::jsonb,
      '["6bceee99-974f-426b-8d92-38b43b4a4267","2a877f02-4993-4e65-9172-7d29f08c5b86"]'::jsonb
    )
  JOIN mission_ai_service_owner.capabilities capability ON capability.id=start_receipt.capability_id
    AND capability.master_session_id=master.id
    AND capability.start_request_key=start_receipt.request_key AND capability.state='active'
  JOIN clan_marionettisti_private.mission_companion_entitlements_v1 entitlement
    ON entitlement.definition_id=source_definition.id AND entitlement.step_key=run.current_step_key
    AND entitlement.encounter_key='enc_inizio' AND entitlement.actor_key='png_1'
    AND entitlement.mechanical_binding_id=p_binding AND entitlement.staff_enabled AND NOT entitlement.land_enabled
  JOIN png_builder_internal.bundles bundle ON bundle.id=p_bundle AND bundle.mechanical_binding_id=p_binding
    AND bundle.bundle_sha256='c0257dd5219d23dde880e9f8cc9e867988a21a1008aa59ca6f0b63e7844210e6'
    AND bundle.status='certified' AND bundle.ownership_mode='adopted'
    AND bundle.bundle_kind='combat' AND bundle.disabled_at IS NULL
  WHERE master.id=p_master
    AND master.location_id='0b85f354-9cdb-47e1-baf9-3d266bb7e06b'::uuid
    AND master.owner_kind='ai_service' AND master.master_user IS NULL
    AND master.closed_at IS NULL AND master.suspended_at IS NULL
    AND NOT (frozen.snapshot ? 'npc_bundle_pins')
    AND NOT EXISTS (SELECT 1 FROM mission_factory_owner.quest_run_sources quest WHERE quest.session_id=master.id)
    AND EXISTS (
      SELECT 1 FROM jsonb_array_elements(source_definition.definition->'scenes') AS phase(value)
      CROSS JOIN LATERAL jsonb_array_elements(phase.value->'encounters') AS encounter(value)
      CROSS JOIN LATERAL jsonb_array_elements(encounter.value->'actors') AS actor(value)
      WHERE phase.value->>'step_key'=entitlement.step_key
        AND encounter.value->>'encounter_key'=entitlement.encounter_key
        AND actor.value->>'actor_key'=entitlement.actor_key
        AND actor.value->>'mechanical_binding_id'=p_binding::text
        AND actor.value->>'narrative_template_id'=bundle.template_id::text
        AND actor.value->>'narrative_version_id'=bundle.narrative_version_id::text
    )
  FOR SHARE OF bundle,entitlement;

  IF NOT FOUND THEN RETURN false; END IF;
  RETURN png_builder_internal.npc_custom_combat_attest_assert_v1(
    certified.template_id,certified.narrative_version_id,certified.id
  )->>'bundle_sha256' IS NOT DISTINCT FROM certified.bundle_sha256;
END;
$function$;

COMMIT;