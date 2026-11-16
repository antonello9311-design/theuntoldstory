-- Apertura del raccordo nelle missioni Land ammesse, dopo esito del caso Staff e review.
-- Le singole definizioni Land devono già avere la loro ammissione e un binding conforme.
BEGIN;
SET LOCAL lock_timeout = '3s';
SET LOCAL statement_timeout = '30s';

DO $qualification$
BEGIN
  PERFORM clan_innata_private.eligibility_release_assert();
  IF (
    SELECT count(*)
    FROM mission_creation_owner.h3_staff_source_requests source
    JOIN mission_generic_owner.plan_revisions source_revision
      ON source_revision.plan_version_id=(source.result->>'plan_version_id')::uuid
     AND source_revision.mission_id=source.mission_id
    JOIN clan_marionettisti_private.mission_companion_entitlements_v1 entitlement
      ON entitlement.definition_id=source_revision.definition_id
     AND NOT entitlement.land_enabled
    JOIN clan_marionettisti_private.mission_companion_receipts_v1 companion
      ON companion.entitlement_id=entitlement.id AND companion.simulated
    JOIN mission_generic_owner.encounters encounter ON encounter.encounter_id=companion.session_id
    JOIN public.combat_v2_sessions combat ON combat.id=encounter.encounter_id AND combat.closed_at IS NOT NULL
    JOIN public.master_v2_sessions master
      ON master.id=encounter.master_session_id AND master.owner_kind='ai_service' AND master.closed_at IS NOT NULL
    JOIN clan_marionettisti_private.control_events event
      ON event.session_id=companion.session_id AND event.owner_actor_id=companion.owner_actor_id
     AND event.kind='link_severed' AND event.payload->>'authority'='ocular-sever/1'
     AND event.payload->>'companion_actor_id'=companion.body_actor_id::text
    JOIN public.combat_v2_round_reports report ON report.round_id=event.round_id AND NOT report.values_written AND report.narration_state='pubblicata'
    LEFT JOIN mission_generic_owner.unified_report_publications publication ON publication.report_id=report.id
    JOIN public.messages message ON message.id=coalesce(publication.message_id,report.message_id)
      AND message.location_id=master.location_id AND message.kind='fato' AND message.recipient_user IS NULL
    WHERE source.request_key='14136a56-0f58-41b2-ae24-8f7f3acbb4b2'::uuid
      AND master.location_id='0b85f354-9cdb-47e1-baf9-3d266bb7e06b'::uuid
      AND nullif(btrim(message.body),'') IS NOT NULL
      AND clan_marionettisti_private.mission_companion_valid(
           companion.session_id,companion.owner_actor_id,companion.body_actor_id
          )
  )<>1 THEN
    RAISE EXCEPTION 'Recisione e Fato Staff da qualificare' USING ERRCODE='55000';
  END IF;
  UPDATE clan_marionettisti_private.mission_companion_release_v1
  SET land_enabled=true,updated_at=clock_timestamp()
  WHERE singleton AND NOT land_enabled;
  IF NOT FOUND THEN
    RAISE EXCEPTION 'Gate di rilascio inatteso' USING ERRCODE='40001';
  END IF;
END;
$qualification$;
COMMIT;
