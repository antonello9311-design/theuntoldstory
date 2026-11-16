BEGIN;
SET LOCAL lock_timeout='3s';
SET LOCAL statement_timeout='30s';
DO $check$
BEGIN
 IF EXISTS(SELECT 1 FROM public.combat_v2_sessions WHERE closed_at IS NULL)
    OR EXISTS(SELECT 1 FROM public.master_v2_sessions WHERE closed_at IS NULL)
 THEN RAISE EXCEPTION 'OCULAR_ORDINARY_ACTIVE_SCENE'; END IF;
 IF md5(pg_get_functiondef('combat_panel_private.annotate_offer_categories(jsonb)'::regprocedure))<>'a72c168002d311f74863be764a4bed7e'
 OR md5(pg_get_functiondef('combat_panel_private.import_companion_moves(uuid,bigint,jsonb,bigint)'::regprocedure))<>'d58ebd7223bdcc445898ee827bd0ed92'
 OR md5(pg_get_functiondef('combat_panel_private.commit_ordinary(jsonb)'::regprocedure))<>'32e182213765142348c97ff756f9bef2'
 THEN RAISE EXCEPTION 'OCULAR_ORDINARY_ANNOTATION_DRIFT'; END IF;
 PERFORM clan_innata_private.eligibility_release_assert();
END $check$;
ALTER TABLE clan_marionettisti_private.ocular_sever_gate_v1
 ADD COLUMN ordinary_enabled boolean NOT NULL DEFAULT false;
CREATE OR REPLACE FUNCTION combat_panel_private.annotate_offer_categories(p_envelope jsonb)
 RETURNS jsonb
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO ''
AS $function$
DECLARE item jsonb; annotated jsonb:='[]'::jsonb; uid uuid:=exam_regia_private.current_principal();
 o combat_panel_private.offers%ROWTYPE; c combat_panel_private.contexts%ROWTYPE;
 co combat_consumer_private.offers%ROWTYPE; src jsonb; intent jsonb; category text;
BEGIN
 IF jsonb_typeof(p_envelope->'offers') IS DISTINCT FROM 'array' THEN RETURN p_envelope; END IF;
 IF uid IS NULL THEN RAISE EXCEPTION 'panel_authentication_required' USING ERRCODE='28000'; END IF;
 FOR item IN SELECT value FROM jsonb_array_elements(p_envelope->'offers') LOOP
  SELECT * INTO STRICT o FROM combat_panel_private.offers
   WHERE id=(item->>'offer_id')::uuid AND principal_user=uid;
  -- INUZUKA-PANEL-ANNOTATION-CONTEXT-CACHE-20260922-009
  IF c.id IS NULL OR c.id IS DISTINCT FROM o.context_id
    OR c.context_version IS DISTINCT FROM o.context_version THEN
   c:=combat_panel_private.owned_context(o.context_id,o.context_version);
  END IF;
  IF o.state<>'offered' OR o.context_version IS DISTINCT FROM (item->>'context_version')::bigint
   OR o.scene_version IS DISTINCT FROM (item->>'scene_version')::bigint
   OR o.source_fingerprint IS DISTINCT FROM c.source_fingerprint
   OR o.scene_version IS DISTINCT FROM c.scene_version
   OR o.actor_id IS DISTINCT FROM (item->>'actor_id')::uuid THEN
   RAISE EXCEPTION 'panel_offer_not_available' USING ERRCODE='40001'; END IF;
  src:=o.source_payload; category:='other';
  -- Already-issued passive attacks remain in history, but are not rendered by this opt-in API.
  IF src->>'adapter'='master_v2' AND src->>'dispatch'='action' AND src->>'kind'='attacco'
   AND src->>'ability_source'='clan' AND src->>'ability_id'='4056f62d-77f3-47f9-8ecb-9a7799682a9d' THEN
   CONTINUE;
  END IF;
  IF o.kind NOT IN ('action','control','defense')
    OR src->>'dispatch' IN ('movement','master_movement_control','pg_movement') THEN
   annotated:=annotated||jsonb_build_array(item); CONTINUE;
  END IF;
  -- Grouped marionette movement has native sources on the distance choices.
  IF o.kind='control' AND o.operation='control'
    AND c.activity_kind='ordinary_v2' AND src->>'adapter'='ordinary_v2'
    AND src->'source_offer_id'='null'::jsonb
    AND src->>'source_activity_id'=c.activity_id::text
    AND src->>'source_exchange_id'=c.round_id::text
    AND (
      (c.location_id='0b85f354-9cdb-47e1-baf9-3d266bb7e06b'::uuid
        AND NOT public.combat_v2_values_written(c.activity_id))
      OR EXISTS(SELECT 1 FROM clan_marionettisti_private.ocular_sever_gate_v1 gate
        WHERE gate.singleton AND gate.public_enabled AND gate.ordinary_enabled)
    )
    AND EXISTS(SELECT 1 FROM combat_panel_private.choice_groups g
      JOIN combat_panel_private.choice_options ch ON ch.group_id=g.id AND ch.offer_id=o.id
      WHERE g.offer_id=o.id AND g.purpose='movement_distance')
    AND NOT EXISTS (
      SELECT 1 FROM combat_panel_private.choice_groups g
      JOIN combat_panel_private.choice_options ch ON ch.group_id=g.id AND ch.offer_id=o.id
      WHERE g.offer_id=o.id AND g.purpose='movement_distance' AND NOT EXISTS (
        SELECT 1 FROM combat_consumer_private.offers native
        JOIN public.characters pg ON pg.id=native.principal_character_id AND pg.user_id=auth.uid()
        WHERE native.id=(ch.source_payload->>'source_offer_id')::uuid AND native.location_id=c.location_id
          AND native.session_id=c.activity_id AND native.exchange_id=c.round_id
          AND native.context_version=(src->>'source_context_version')::bigint
          AND native.scene_version=c.scene_version AND native.state='offered'
          AND native.operation='control' AND native.source_payload->>'marionetta_operation'='move'
      )
    ) THEN
    annotated:=annotated||jsonb_build_array(item||jsonb_build_object('ui_category','other'));
    CONTINUE;
  END IF;
  IF src->>'adapter'='ordinary_v2' AND src ? 'source_offer_id' THEN
   SELECT * INTO co FROM combat_consumer_private.offers original
    WHERE original.id=(src->>'source_offer_id')::uuid AND original.session_id=c.activity_id
     AND original.exchange_id=c.round_id
     AND original.context_version=(src->>'source_context_version')::bigint
     AND original.scene_version=c.scene_version AND original.state='offered'
     AND original.operation=o.operation
     AND EXISTS(SELECT 1 FROM public.characters ch WHERE ch.id=original.principal_character_id AND ch.user_id=auth.uid());
   IF co.id IS NULL THEN RAISE EXCEPTION 'panel_ui_source_not_available' USING ERRCODE='40001'; END IF;
   IF co.offer_kind='movement' THEN
    annotated:=annotated||jsonb_build_array(item); CONTINUE;
   END IF;
   src:=co.source_payload; intent:=coalesce(src->'intent','{}'::jsonb);
  ELSE intent:=src;
  END IF;
  IF o.kind='control' AND (
    src->>'sharingan_operation' IN ('activate','deactivate')
    OR src->>'sabaku_operation' IN ('activate','deactivate')
    OR src->>'hyuga_operation' IN ('activate','deactivate')) THEN category:='innate';
  ELSIF src->>'dispatch' IN ('multiplication','multiplication_ordinary_attack','sabaku_clone','substitution','suiton_control','other_control','scudo_control')
    OR src ? 'suiton_operation' OR src ? 'other_operation' OR src ? 'scudo_operation'
    OR src#>>'{sabaku_flow,version}'='sabaku-flow/2'
    OR (intent->>'ability_source' IS NOT NULL AND intent->>'ability_source' NOT IN ('mano','arma')
        AND nullif(intent->>'ability_id','') IS NOT NULL)
    OR intent->>'reaction'='sostituzione' THEN category:='technique';
  ELSIF (intent->>'kind'='attacco' AND intent->>'ability_source' IN ('mano','arma'))
    OR intent->>'kind' IN ('utilita','passa')
    OR intent->>'reaction' IN ('parata','schivata','nessuna')
    OR src->>'dispatch'='immobilization_escape' THEN category:='basic';
  END IF;
  annotated:=annotated||jsonb_build_array(item||jsonb_build_object('ui_category',category));
 END LOOP;
 RETURN jsonb_set(p_envelope,'{offers}',annotated,false);
END $function$;
DO $post$ BEGIN PERFORM clan_innata_private.eligibility_release_assert(); END $post$;
COMMIT;
