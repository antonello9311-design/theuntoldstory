BEGIN;
SET LOCAL lock_timeout='3s';
SET LOCAL statement_timeout='30s';
LOCK TABLE public.combat_v2_sessions,public.master_v2_sessions IN SHARE ROW EXCLUSIVE MODE;
DO $restore$ BEGIN
 IF EXISTS (SELECT 1 FROM public.combat_v2_sessions WHERE closed_at IS NULL)
 OR EXISTS (SELECT 1 FROM public.master_v2_sessions WHERE closed_at IS NULL)
 THEN RAISE EXCEPTION 'OCULAR_ORDINARY_ACTIVE_SCENE'; END IF;
 IF md5(pg_get_functiondef('combat_panel_private.annotate_offer_categories(jsonb)'::regprocedure)) IS DISTINCT FROM '05e20323b1d62d1e79031ec0b4231d71'
 THEN RAISE EXCEPTION 'OCULAR_ORDINARY_RELEASE_DRIFT: combat_panel_private.annotate_offer_categories(jsonb)'; END IF;
 IF md5(pg_get_functiondef('clan_marionettisti_private.ocular_sever_source_v1(uuid,uuid,uuid,numeric)'::regprocedure)) NOT IN ('2f9dd54ea654cc148fc9fe55b7b43b86','60709ae48b6cbbb4d520ded79ed9a336')
 THEN RAISE EXCEPTION 'OCULAR_ORDINARY_RECOVERY_DRIFT'; END IF;
 UPDATE clan_marionettisti_private.ocular_sever_gate_v1 SET ordinary_enabled=false WHERE singleton;
END $restore$;
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
        ELSE NOT gate.public_enabled OR scope.source_kind IS DISTINCT FROM 'master'
             OR scope.is_test OR scope.is_exam_room IS TRUE
             OR NOT EXISTS (SELECT 1 FROM public.master_v2_sessions m
               WHERE m.id=scope.master_session_id AND m.owner_kind='human' AND m.master_user IS NOT NULL
                 AND m.closed_at IS NULL) END)
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
DO $verify$ BEGIN PERFORM clan_innata_private.eligibility_release_assert(); END $verify$;
COMMIT;
