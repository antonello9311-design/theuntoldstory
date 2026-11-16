BEGIN;
SET LOCAL lock_timeout='3s';
SET LOCAL statement_timeout='30s';
DO $qualify$ BEGIN
 PERFORM clan_innata_private.eligibility_release_assert();
 IF EXISTS (SELECT 1 FROM public.combat_v2_sessions WHERE closed_at IS NULL)
 OR EXISTS (SELECT 1 FROM public.master_v2_sessions WHERE closed_at IS NULL)
 THEN RAISE EXCEPTION 'OCULAR_ORDINARY_ACTIVE_SCENE'; END IF;
 IF md5(pg_get_functiondef('public.combat_v2_sanitize_intent(jsonb,boolean)'::regprocedure)) IS DISTINCT FROM '28e2a6e486496d11602d53e394eda078'
 THEN RAISE EXCEPTION 'OCULAR_ORDINARY_RELEASE_DRIFT: public.combat_v2_sanitize_intent(jsonb,boolean)'; END IF;
 IF md5(pg_get_functiondef('public.combat_v2_action_declare(uuid,uuid,jsonb,text,uuid)'::regprocedure)) IS DISTINCT FROM 'd5a0d2536a90b3e75e776d5312c3129d'
 THEN RAISE EXCEPTION 'OCULAR_ORDINARY_RELEASE_DRIFT: public.combat_v2_action_declare(uuid,uuid,jsonb,text,uuid)'; END IF;
 IF md5(pg_get_functiondef('combat_v2_multitarget_internal.sync_declaration()'::regprocedure)) IS DISTINCT FROM 'b68a55d64864778ee4457ff0c124f729'
 THEN RAISE EXCEPTION 'OCULAR_ORDINARY_RELEASE_DRIFT: combat_v2_multitarget_internal.sync_declaration()'; END IF;
 IF md5(pg_get_functiondef('public.combat_v2_round_resolve(uuid,uuid)'::regprocedure)) IS DISTINCT FROM 'd677231858895dbb83b2759f00667531'
 THEN RAISE EXCEPTION 'OCULAR_ORDINARY_RELEASE_DRIFT: public.combat_v2_round_resolve(uuid,uuid)'; END IF;
 IF md5(pg_get_functiondef('combat_v2_multitarget_internal.resolve_parent(uuid,uuid,uuid,boolean)'::regprocedure)) IS DISTINCT FROM '1968d5ba7041bf1e47e958e40d40d250'
 THEN RAISE EXCEPTION 'OCULAR_ORDINARY_RELEASE_DRIFT: combat_v2_multitarget_internal.resolve_parent(uuid,uuid,uuid,boolean)'; END IF;
 IF md5(pg_get_functiondef('combat_effects_private.settle_native_target(uuid,uuid)'::regprocedure)) IS DISTINCT FROM 'a25903f31d8065a0ba9cdf4b55b99788'
 THEN RAISE EXCEPTION 'OCULAR_ORDINARY_RELEASE_DRIFT: combat_effects_private.settle_native_target(uuid,uuid)'; END IF;
 IF md5(pg_get_functiondef('clan_marionettisti_private.settle_round_damage(uuid)'::regprocedure)) IS DISTINCT FROM '01faf30ab475d00f14abf110046c25cb'
 THEN RAISE EXCEPTION 'OCULAR_ORDINARY_RELEASE_DRIFT: clan_marionettisti_private.settle_round_damage(uuid)'; END IF;
 IF md5(pg_get_functiondef('clan_marionettisti_private.declaration_terminal_trigger()'::regprocedure)) IS DISTINCT FROM '0c3e1b7ebd7eec9eb55ab36ddc08915c'
 THEN RAISE EXCEPTION 'OCULAR_ORDINARY_RELEASE_DRIFT: clan_marionettisti_private.declaration_terminal_trigger()'; END IF;
 IF md5(pg_get_functiondef('clan_marionettisti_private.narrative_attack_allowed(uuid)'::regprocedure)) IS DISTINCT FROM '159909e401940d7d9a738b7ff5d78ba7'
 THEN RAISE EXCEPTION 'OCULAR_ORDINARY_RELEASE_DRIFT: clan_marionettisti_private.narrative_attack_allowed(uuid)'; END IF;
 IF md5(pg_get_functiondef('combat_consumer_private.narrative_context(uuid)'::regprocedure)) IS DISTINCT FROM '5ab195d900fd93be7f4309e2d1cb096e'
 THEN RAISE EXCEPTION 'OCULAR_ORDINARY_RELEASE_DRIFT: combat_consumer_private.narrative_context(uuid)'; END IF;
 IF md5(pg_get_functiondef('combat_effects_private.freeze_source(uuid)'::regprocedure)) IS DISTINCT FROM 'e59a18dd2f6cc25f2e4f0a5b86e15693'
 THEN RAISE EXCEPTION 'OCULAR_ORDINARY_RELEASE_DRIFT: combat_effects_private.freeze_source(uuid)'; END IF;
 IF md5(pg_get_functiondef('combat_panel_private.master_actor_offers(uuid,bigint,jsonb,jsonb)'::regprocedure)) IS DISTINCT FROM 'c0d45115277701459d8ce08df170d5bd'
 THEN RAISE EXCEPTION 'OCULAR_ORDINARY_RELEASE_DRIFT: combat_panel_private.master_actor_offers(uuid,bigint,jsonb,jsonb)'; END IF;
 IF md5(pg_get_functiondef('combat_panel_private.commit_master_actor(jsonb)'::regprocedure)) IS DISTINCT FROM 'e51c494262b73642801bcc963a65968c'
 THEN RAISE EXCEPTION 'OCULAR_ORDINARY_RELEASE_DRIFT: combat_panel_private.commit_master_actor(jsonb)'; END IF;
 IF md5(pg_get_functiondef('combat_consumer_private.exchange_options(jsonb)'::regprocedure)) IS DISTINCT FROM '391f04948fae1ac05ceb8ca041d225a1'
 THEN RAISE EXCEPTION 'OCULAR_ORDINARY_RELEASE_DRIFT: combat_consumer_private.exchange_options(jsonb)'; END IF;
 IF md5(pg_get_functiondef('combat_consumer_private.offer_exchange(uuid,uuid,uuid,integer,text,text,jsonb)'::regprocedure)) IS DISTINCT FROM 'bcc7e0bd1e0af49ff8b61465ec9318dd'
 THEN RAISE EXCEPTION 'OCULAR_ORDINARY_RELEASE_DRIFT: combat_consumer_private.offer_exchange(uuid,uuid,uuid,integer,text,text,jsonb)'; END IF;
 IF md5(pg_get_functiondef('combat_consumer_private.commit_exchange(jsonb,jsonb)'::regprocedure)) IS DISTINCT FROM 'f840b188efdc4118f9de7ec68b15c1c5'
 THEN RAISE EXCEPTION 'OCULAR_ORDINARY_RELEASE_DRIFT: combat_consumer_private.commit_exchange(jsonb,jsonb)'; END IF;
 IF md5(pg_get_functiondef('combat_panel_private.narrative_ordinary_context(uuid)'::regprocedure)) IS DISTINCT FROM '5c68f15d8957b5ef3b7b55f54e0f2f9c'
 THEN RAISE EXCEPTION 'OCULAR_ORDINARY_RELEASE_DRIFT: combat_panel_private.narrative_ordinary_context(uuid)'; END IF;
 IF md5(pg_get_functiondef('public.marionetta_staff_sever_arm_v1(uuid,uuid,uuid)'::regprocedure)) IS DISTINCT FROM 'd649a3dc295f0ea1908b230e5b89c797'
 THEN RAISE EXCEPTION 'OCULAR_ORDINARY_RELEASE_DRIFT: public.marionetta_staff_sever_arm_v1(uuid,uuid,uuid)'; END IF;
 IF md5(pg_get_functiondef('clan_marionettisti_private.ocular_sever_contact_v1(uuid,uuid,uuid,uuid,text,integer,numeric,numeric)'::regprocedure)) IS DISTINCT FROM 'f4503cc4d026963b2b0ead840a1470c3'
 THEN RAISE EXCEPTION 'OCULAR_ORDINARY_RELEASE_DRIFT: clan_marionettisti_private.ocular_sever_contact_v1(uuid,uuid,uuid,uuid,text,integer,numeric,numeric)'; END IF;
 IF md5(pg_get_functiondef('clan_marionettisti_private.ocular_sever_attack_range_v1(uuid,text,uuid,jsonb)'::regprocedure)) IS DISTINCT FROM 'fc5606c65f1433f1757ada02bf374b7d'
 THEN RAISE EXCEPTION 'OCULAR_ORDINARY_RELEASE_DRIFT: clan_marionettisti_private.ocular_sever_attack_range_v1(uuid,text,uuid,jsonb)'; END IF;
 IF md5(pg_get_functiondef('clan_marionettisti_private.ocular_sever_frozen_valid_v1(uuid)'::regprocedure)) IS DISTINCT FROM '5b5b9f558b542a71f0aa5a41328bc489'
 THEN RAISE EXCEPTION 'OCULAR_ORDINARY_RELEASE_DRIFT: clan_marionettisti_private.ocular_sever_frozen_valid_v1(uuid)'; END IF;
 IF md5(pg_get_functiondef('clan_marionettisti_private.ocular_sever_authorize_v1(uuid,uuid,uuid,text,uuid,uuid)'::regprocedure)) IS DISTINCT FROM '2f4c8544dab49ede553a654c5a8af442'
 THEN RAISE EXCEPTION 'OCULAR_ORDINARY_RELEASE_DRIFT: clan_marionettisti_private.ocular_sever_authorize_v1(uuid,uuid,uuid,text,uuid,uuid)'; END IF;
 IF md5(pg_get_functiondef('clan_marionettisti_private.ocular_sever_proof_v1(uuid,uuid,uuid,uuid)'::regprocedure)) IS DISTINCT FROM 'b769f9f8a9e748b53f6109f0a2b04359'
 THEN RAISE EXCEPTION 'OCULAR_ORDINARY_RELEASE_DRIFT: clan_marionettisti_private.ocular_sever_proof_v1(uuid,uuid,uuid,uuid)'; END IF;
 IF md5(pg_get_functiondef('clan_marionettisti_private.ocular_sever_source_v1(uuid,uuid,uuid,numeric)'::regprocedure)) IS DISTINCT FROM '2f9dd54ea654cc148fc9fe55b7b43b86'
 THEN RAISE EXCEPTION 'OCULAR_ORDINARY_RELEASE_DRIFT: clan_marionettisti_private.ocular_sever_source_v1(uuid,uuid,uuid,numeric)'; END IF;
 IF md5(pg_get_functiondef('combat_panel_private.annotate_offer_categories(jsonb)'::regprocedure)) IS DISTINCT FROM '05e20323b1d62d1e79031ec0b4231d71'
 THEN RAISE EXCEPTION 'OCULAR_ORDINARY_RELEASE_DRIFT: combat_panel_private.annotate_offer_categories(jsonb)'; END IF;
 IF (
   SELECT count(*)
   FROM public.combat_v2_sessions s
   JOIN public.locations l ON l.id=s.location_id AND l.is_test
   JOIN public.combat_v2_rounds round ON round.session_id=s.id
   JOIN public.combat_v2_round_reports report ON report.round_id=round.id
     AND report.narration_state='pubblicata' AND report.narrator_kind='ia' AND report.message_id IS NOT NULL
   JOIN combat_consumer_private.narrative_claims n ON n.round_id=round.id AND n.report_id=report.id AND n.state='completed'
   JOIN public.combat_v2_declarations d ON d.round_id=round.id AND d.state='risolta'
   JOIN clan_marionettisti_private.ocular_sever_authorizations_v1 a ON a.request_key=d.request_key
     AND a.round_id=d.round_id AND a.actor_id=d.actor_id AND a.target_id=d.target_actor_id
     AND a.attack_source='arma' AND a.proof->'staff_simulated'='true'::jsonb
   WHERE s.id='9febacc0-cab8-4908-9daf-81eff7e844c9'::uuid AND s.source_kind='ordinary' AND s.master_session_id IS NULL
     AND s.closed_at IS NOT NULL AND d.id='d74a2300-3f5c-472e-9876-2c72df14c4d2'::uuid
     AND d.sanitized_intent->'target_fili'='true'::jsonb
     AND d.outcome->'fili_recisi'='true'::jsonb AND d.outcome->'damage_applied'='0'::jsonb
     AND d.outcome->'target_hp_after'='30'::jsonb
     AND NOT public.combat_v2_values_written(s.id)
     AND (SELECT count(*) FROM clan_marionettisti_private.control_events e
       WHERE e.source_declaration_id=d.id AND e.round_id=d.round_id AND e.session_id=s.id
         AND e.kind='link_severed' AND e.payload->>'authority'='ocular-sever/1')=1
     AND (SELECT count(*) FROM combat_panel_private.shuriken_spend_v1 spend
       WHERE spend.declaration_id=d.id AND spend.simulated)=1
     AND NOT EXISTS (SELECT 1 FROM public.combat_v2_resource_ledger spend WHERE spend.session_id=s.id AND spend.applied_amount>0)
 )<>1 THEN RAISE EXCEPTION 'OCULAR_ORDINARY_STAFF_RECEIPT_REQUIRED'; END IF;
 IF NOT EXISTS(SELECT 1 FROM clan_marionettisti_private.ocular_sever_gate_v1 WHERE singleton
      AND staff_enabled AND public_enabled AND NOT ordinary_enabled)
 THEN RAISE EXCEPTION 'OCULAR_ORDINARY_GATE_DRIFT'; END IF;
END $qualify$;
CREATE OR REPLACE FUNCTION clan_marionettisti_private.ocular_sever_source_v1(p_round uuid, p_actor uuid, p_body uuid, p_max_range_m numeric)
 RETURNS jsonb
 LANGUAGE plpgsql
 STABLE SECURITY DEFINER
 SET search_path TO ''
AS $function$
DECLARE
  scope record;
  gate clan_marionettisti_private.ocular_sever_gate_v1;
  eye uuid;
  family text;
  tier integer;
  eye_range numeric;
  simulated boolean;
BEGIN
  SELECT r.session_id, r.phase, s.source_kind, s.master_session_id, a.controller_user, a.id AS attacker_id, l.owner_actor_id,
    l.companion_actor_id, l.instance_id, l.link_version, l.is_simulated,
    place.id AS location_id, place.is_test, place.is_exam_room
  INTO scope
  FROM public.combat_v2_rounds r
  JOIN public.combat_v2_sessions s ON s.id=r.session_id AND s.state='in_corso' AND s.closed_at IS NULL
  JOIN public.locations place ON place.id=s.location_id AND place.is_active
  JOIN public.combat_v2_actors a ON a.id=p_actor AND a.session_id=s.id
    AND a.actor_kind='pg' AND a.companion_id IS NULL AND a.controller_user=auth.uid() AND a.state='attivo'
  JOIN clan_marionettisti_private.links l ON l.companion_actor_id=p_body AND l.state='connected'
  JOIN public.combat_v2_actors b ON b.id=l.companion_actor_id AND b.session_id=s.id
    AND b.companion_id IS NOT NULL AND b.state='attivo' AND b.team_key<>a.team_key
  JOIN public.combat_v2_actors o ON o.id=l.owner_actor_id AND o.session_id=s.id AND o.state='attivo'
    AND o.team_key=b.team_key
  JOIN combat_spatial.arena_instances i ON i.instance_id=l.instance_id AND i.encounter_id=s.id AND i.state='open'
  WHERE r.id=p_round AND r.phase='raccolta_azioni'
    AND s.source_kind IN ('ordinary','master')
    AND NOT EXISTS (SELECT 1 FROM exam_regia_private.bindings x WHERE x.combat_session_id=s.id)
    AND NOT EXISTS (SELECT 1 FROM exam_human_private.native_bindings x WHERE x.master_session_id=s.master_session_id)
    AND NOT EXISTS (SELECT 1 FROM user_testroom_common_private.contexts x WHERE x.id=s.id);
  IF NOT FOUND OR NOT clan_marionettisti_private.is_dedicated_scene(scope.session_id)
  THEN RETURN NULL; END IF;

  SELECT * INTO STRICT gate FROM clan_marionettisti_private.ocular_sever_gate_v1 WHERE singleton;
  simulated:=NOT public.combat_v2_values_written(scope.session_id);
  IF simulated IS DISTINCT FROM scope.is_simulated
    OR (CASE WHEN simulated THEN NOT (gate.staff_enabled AND scope.is_test
          AND scope.location_id='0b85f354-9cdb-47e1-baf9-3d266bb7e06b'::uuid
          AND combat_consumer_private.staff_test_allowed(scope.location_id,ARRAY[auth.uid()],false))
        ELSE NOT gate.public_enabled OR scope.is_test OR scope.is_exam_room IS TRUE
             OR NOT (
               (scope.source_kind='ordinary' AND gate.ordinary_enabled)
               OR (scope.source_kind='master' AND EXISTS (SELECT 1 FROM public.master_v2_sessions m
                 WHERE m.id=scope.master_session_id AND m.owner_kind='human' AND m.master_user IS NOT NULL
                   AND m.closed_at IS NULL))
             ) END)
    OR NOT clan_marionettisti_private.actor_visible(scope.session_id,p_body,scope.controller_user)
  THEN RETURN NULL; END IF;

  SELECT ct.id,ct.name,ct.level,public._fascia_metri(ct.gittata) INTO eye,family,tier,eye_range
  FROM clan_innata_combat_private.combat_state st
  JOIN public.clan_techniques ct ON ct.id=st.technique_id AND ct.is_active AND ct.is_innata AND ct.level BETWEEN 1 AND 4
  WHERE st.session_id=scope.session_id AND st.actor_id=p_actor AND st.is_test=simulated
    AND st.active AND st.state_version>0 AND
    ((ct.clan='Hyuga' AND ct.name='Byakugan' AND EXISTS(
        SELECT 1 FROM clan_innata_narrative_private.byakugan_candidates_v1(p_actor) candidate WHERE candidate.technique_id=ct.id))
     OR (ct.clan='Uchiha' AND ct.name='Sharingan' AND ct.id=clan_innata_narrative_private.sharingan_selected_v2(p_actor)))
  ORDER BY ct.level DESC,ct.id LIMIT 1;
  IF eye IS NULL THEN RETURN NULL; END IF;
  IF (clan_innata_private.combat_state_read(p_actor,eye)).active IS DISTINCT FROM true THEN RETURN NULL; END IF;

  IF NOT clan_marionettisti_private.ocular_sever_contact_v1(
    scope.instance_id,p_actor,scope.owner_actor_id,p_body,family,tier,p_max_range_m,eye_range
  ) THEN RETURN NULL; END IF;

  RETURN jsonb_build_object('eye_id',eye,'owner_actor_id',scope.owner_actor_id,
    'companion_actor_id',p_body,'link_version',scope.link_version,'staff_simulated',simulated,
    'range_m',p_max_range_m);
END $function$;
DO $enable$ BEGIN
 PERFORM clan_innata_private.eligibility_release_assert();
 IF md5(pg_get_functiondef('clan_marionettisti_private.ocular_sever_source_v1(uuid,uuid,uuid,numeric)'::regprocedure)) IS DISTINCT FROM '60709ae48b6cbbb4d520ded79ed9a336'
 THEN RAISE EXCEPTION 'OCULAR_ORDINARY_RELEASE_DRIFT: clan_marionettisti_private.ocular_sever_source_v1(uuid,uuid,uuid,numeric)'; END IF;
 UPDATE clan_marionettisti_private.ocular_sever_gate_v1 SET ordinary_enabled=true WHERE singleton
   AND staff_enabled AND public_enabled AND NOT ordinary_enabled;
 IF NOT FOUND THEN RAISE EXCEPTION 'OCULAR_ORDINARY_GATE_DRIFT'; END IF;
END $enable$;
COMMIT;
