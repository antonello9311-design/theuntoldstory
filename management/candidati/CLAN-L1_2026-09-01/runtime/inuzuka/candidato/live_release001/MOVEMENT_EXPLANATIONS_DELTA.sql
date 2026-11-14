BEGIN;
SET LOCAL lock_timeout='3s';
DO $pre$ BEGIN
IF md5(pg_get_functiondef('combat_panel_private.movement_explanations(uuid,bigint)'::regprocedure)) IS DISTINCT FROM '83697f0fc91a077dedf6bbb99c1378ef' THEN RAISE EXCEPTION 'inuzuka_movement_explanations_pre'; END IF;
END $pre$;
CREATE OR REPLACE FUNCTION combat_panel_private.movement_explanations(p_context uuid, p_expected bigint)
 RETURNS jsonb
 LANGUAGE plpgsql
 STABLE SECURITY DEFINER
 SET search_path TO ''
AS $function$
DECLARE c combat_panel_private.contexts%ROWTYPE; a public.combat_v2_actors%ROWTYPE;
 o combat_panel_private.offers%ROWTYPE; q record; original combat_consumer_private.offers%ROWTYPE;
 cap combat_spatial.movement_capabilities%ROWTYPE; body combat_spatial.actor_states%ROWTYPE;
 choice combat_spatial.movement_semantic_choices%ROWTYPE; iid uuid; capid uuid; parent_source_offer uuid;
 budget jsonb; general jsonb; reasons jsonb; entries jsonb:='[]'; block text;
 desired numeric; effective numeric; own_turn boolean; regions jsonb; terrain jsonb; visible_areas boolean; block_t numeric; cost_cap combat_panel_private.movement_cost_capabilities%ROWTYPE;
BEGIN
 c:=combat_panel_private.owned_context(p_context,p_expected);
 IF c.command_actor_id IS NULL OR c.round_id IS NULL THEN RETURN NULL; END IF;
 SELECT * INTO STRICT a FROM public.combat_v2_actors WHERE id=c.command_actor_id
   AND session_id=c.activity_id AND exam_regia_private.actor_principal(id,controller_user)=exam_regia_private.current_principal() AND companion_id IS NULL;
 SELECT instance_id INTO iid FROM combat_spatial.arena_instances
   WHERE encounter_id=c.activity_id AND state='open';
 IF iid IS NULL OR a.state<>'attivo' THEN RETURN NULL; END IF;
 own_turn:=CASE c.activity_kind WHEN 'ordinary_v2' THEN EXISTS(
   SELECT 1 FROM combat_consumer_private.activities WHERE session_id=c.activity_id
     AND exchange_id=c.round_id AND turn_actor_id=a.id AND phase='action')
   WHEN 'master_v2' THEN EXISTS(SELECT 1 FROM combat_panel_private.actor_turns t
     JOIN public.combat_v2_rounds r ON r.id=t.round_id
     WHERE t.round_id=c.round_id AND t.actor_id=a.id AND t.state='ready' AND r.phase='raccolta_azioni')
   ELSE false END;
 budget:=combat_panel_private.movement_budget(a.id,c.round_id);
 visible_areas:=EXISTS(SELECT 1 FROM combat_spatial.viewer_grants WHERE instance_id=iid
   AND viewer_principal_id=exam_regia_private.current_principal() AND can_view_map AND can_view_objects);
 FOR o IN SELECT * FROM combat_panel_private.offers WHERE context_id=c.id
   AND principal_user=exam_regia_private.current_principal() AND actor_id=a.id AND context_version=c.context_version
   AND source_fingerprint=c.source_fingerprint AND scene_version IS NOT DISTINCT FROM c.scene_version
   AND state='offered' ORDER BY created_at,id LOOP
   general:='[]'; block:=NULL;
   -- Anche quando il movimento e impedito, la causa puo accompagnare
   -- un'azione valida. Non si crea un falso comando di movimento eseguibile.
   IF own_turn AND o.kind='action' AND o.operation='declare' THEN
     block:=combat_panel_private.movement_block_reason(a.id);
     IF block IS NOT NULL THEN
       general:=jsonb_build_array(jsonb_build_object('kind','blocked','source_kind','undisclosed',
         'label','Il personaggio non può spostarsi nelle condizioni attuali.','amount_m',NULL));
     END IF;
     IF (budget->>'spent_m')::numeric>0 THEN
       general:=general||jsonb_build_array(jsonb_build_object('kind','budget_reduction','source_kind','undisclosed',
         'label','Movimento già utilizzato in questo turno, compresi i compagni che condividono il budget.',
         'amount_m',(budget->>'spent_m')::numeric));
     END IF;
     IF jsonb_array_length(general)>0 THEN
       entries:=entries||jsonb_build_array(jsonb_build_object('offer_id',o.id,'option_id',NULL,
         'effective_distance_m',CASE WHEN block IS NOT NULL THEN 0 ELSE NULL END,'reasons',general));
     END IF;
   END IF;
   FOR q IN SELECT x.* FROM combat_panel_private.choice_options x
     JOIN combat_panel_private.choice_groups g ON g.id=x.group_id AND g.offer_id=x.offer_id
     WHERE x.offer_id=o.id AND (g.purpose='movement_distance'
       OR x.source_payload->>'movement_capability_id' IS NOT NULL
       OR x.source_payload->>'multiplication_movement_capability_id' IS NOT NULL) ORDER BY g.ordinal,x.ordinal LOOP
     -- Prima dell'estrazione non esiste un unico percorso cui attribuire un sovraccosto.
     -- Distanza e candidati sono convalidati dal commit comune; il ledger conserva il costo effettivo.
     IF q.source_payload ? 'multiplication_random_sources' OR q.source_payload ? 'multiplication_figures'
       OR (q.label='Colpisci senza spostarti' AND q.source_payload='{}'::jsonb AND q.distance_m IS NULL) THEN CONTINUE; END IF;
     -- La disposizione descrive le copie; soltanto la scelta dell'originale possiede la capability del corpo.
     capid:=NULL;
     original:=NULL;
     IF q.source_payload->>'movement_capability_id' IS NOT NULL THEN
       capid:=(q.source_payload->>'movement_capability_id')::uuid;
     ELSIF q.source_payload->>'multiplication_movement_capability_id' IS NOT NULL THEN
       capid:=(q.source_payload->>'multiplication_movement_capability_id')::uuid;
     ELSIF o.source_payload->>'adapter'='master_v2' THEN
       capid:=(q.source_payload->>'movement_capability_id')::uuid;
     ELSIF o.source_payload->>'adapter'='ordinary_v2' THEN
       parent_source_offer:=(o.source_payload->>'source_offer_id')::uuid;
       IF parent_source_offer IS NULL AND q.source_payload ? 'movement_offer_id' THEN
         -- Follow only this option's own dependency chain inside the same offer.
         WITH RECURSIVE lineage AS (
           SELECT x.id,x.group_id,x.source_payload,ARRAY[x.id] AS visited,0 AS depth
           FROM combat_panel_private.choice_options x WHERE x.id=q.id AND x.offer_id=o.id
           UNION ALL
           SELECT parent.id,parent.group_id,parent.source_payload,l.visited||parent.id,l.depth+1
           FROM lineage l JOIN combat_panel_private.choice_groups g ON g.id=l.group_id AND g.offer_id=o.id
           JOIN combat_panel_private.choice_options parent ON parent.id=g.depends_on AND parent.offer_id=o.id
           WHERE NOT parent.id=ANY(l.visited)
         ) SELECT (source_payload->>'source_offer_id')::uuid INTO parent_source_offer
           FROM lineage WHERE source_payload->>'source_offer_id' IS NOT NULL ORDER BY depth LIMIT 1;
       END IF;
       SELECT * INTO original FROM combat_consumer_private.offers WHERE
         id=coalesce((q.source_payload->>'movement_offer_id')::uuid,(q.source_payload->>'source_offer_id')::uuid)
         AND session_id=c.activity_id AND exchange_id=c.round_id AND location_id=c.location_id
         AND principal_character_id=a.character_id AND state='offered'
         AND context_version=(o.source_payload->>'source_context_version')::bigint
         AND scene_version IS NOT DISTINCT FROM c.scene_version;
       IF original.id IS NOT NULL AND (
         (q.source_payload ? 'movement_offer_id' AND original.offer_kind='movement'
           AND parent_source_offer IS NOT NULL AND original.parent_offer_id=parent_source_offer)
         OR (q.source_payload ? 'source_offer_id' AND original.operation='control'
           AND (original.source_payload->>'marionetta_operation'='move'
             OR original.source_payload->>'inuzuka_operation'='move'))) THEN
         capid:=(original.source_payload->>'capability_id')::uuid;
       END IF;
     END IF;
     SELECT * INTO cap FROM combat_spatial.movement_capabilities
       WHERE capability_id=capid AND instance_id=iid AND state='offered';
     SELECT * INTO body FROM combat_spatial.actor_states WHERE instance_id=iid AND actor_id=cap.actor_id;
     SELECT * INTO choice FROM combat_spatial.movement_semantic_choices
       WHERE instance_id=iid AND actor_id=cap.actor_id AND choice_key=cap.choice_key;
     IF cap.capability_id IS NULL OR body.state IS DISTINCT FROM 'active'
       OR body.controller_principal_id IS DISTINCT FROM exam_regia_private.current_principal()
       OR cap.actor_body_version IS DISTINCT FROM body.body_version
       OR cap.choice_version IS DISTINCT FROM choice.choice_version OR NOT coalesce(choice.enabled,false)
       OR cap.map_version IS DISTINCT FROM c.scene_version
       OR (cap.start_x_m,cap.start_y_m) IS DISTINCT FROM (body.x_m,body.y_m)
       OR (cap.actor_id IS DISTINCT FROM a.id AND NOT EXISTS(
         SELECT 1 FROM clan_marionettisti_private.links WHERE owner_actor_id=a.id
           AND companion_actor_id=cap.actor_id AND state='connected')
         AND NOT (
           (CASE o.source_payload->>'adapter'
             WHEN 'master_v2' THEN coalesce(o.source_payload->>'dispatch'='inuzuka_control'
               AND o.source_payload->>'inuzuka_operation'='move'
               AND o.source_payload->>'ninken_actor_id'=cap.actor_id::text,false)
             WHEN 'ordinary_v2' THEN coalesce(o.source_payload->>'dispatch'='inuzuka_control'
               AND o.source_payload->>'inuzuka_operation'='move'
               AND ((original.id=(q.source_payload->>'movement_offer_id')::uuid
                 AND original.parent_offer_id=parent_source_offer
                 AND original.offer_kind='movement' AND original.operation='control'
                 AND original.source_payload->>'companion_id'=o.source_payload->>'companion_id'
                 AND original.source_payload->>'capability_id'=cap.capability_id::text)
                 OR (original.id=(q.source_payload->>'source_offer_id')::uuid AND original.operation='control'
                   AND original.source_payload->>'inuzuka_operation'='move'))
               AND original.source_payload->>'ninken_actor_id'=cap.actor_id::text,false)
             ELSE false END)
           AND EXISTS(SELECT 1 FROM public.combat_v2_actors dog
             JOIN public.character_companions cc ON cc.id=dog.companion_id AND cc.character_id=a.character_id
               AND cc.kind='cane_ninja' AND cc.is_active
             JOIN clan_marionettisti_private.sources n ON n.id=cc.id AND n.owner_character_id=a.character_id
               AND n.profile_version='ninken-l1/1' AND n.is_active
             WHERE dog.id=cap.actor_id AND dog.session_id=a.session_id AND dog.state='attivo'
               AND dog.controller_user=a.controller_user AND dog.controller_version=a.controller_version
               AND dog.team_key=a.team_key)
         )) THEN
       RAISE EXCEPTION 'panel_movement_explanation_source_changed' USING ERRCODE='40001'; END IF;
     IF combat_panel_private.movement_block_reason(cap.actor_id) IS NOT NULL THEN
       RAISE EXCEPTION 'panel_movement_explanation_body_changed' USING ERRCODE='40001'; END IF;
     effective:=round(combat_spatial.distance_m(cap.start_x_m,cap.start_y_m,cap.end_x_m,cap.end_y_m),2);
     desired:=combat_spatial.distance_m(cap.start_x_m,cap.start_y_m,choice.endpoint_x_m,choice.endpoint_y_m);
     IF o.source_payload->>'adapter'='ordinary_v2'
       AND q.source_payload ? 'movement_offer_id'
       AND original.id IS NOT NULL
       AND original.id=(q.source_payload->>'movement_offer_id')::uuid
       AND original.viewer_projection ? 'target_distance_m'
       AND original.viewer_projection ? 'travel_m' THEN
       IF q.distance_m IS DISTINCT FROM (original.viewer_projection->>'target_distance_m')::numeric
         OR round((original.viewer_projection->>'travel_m')::numeric,2) IS DISTINCT FROM effective THEN
         RAISE EXCEPTION 'panel_movement_explanation_distance_changed' USING ERRCODE='40001'; END IF;
     ELSIF q.distance_m IS DISTINCT FROM effective THEN
       RAISE EXCEPTION 'panel_movement_explanation_distance_changed' USING ERRCODE='40001'; END IF;
     regions:=combat_panel_private.movement_regions_for_body(iid,cap.actor_id);
     SELECT * INTO cost_cap FROM combat_panel_private.movement_cost_capabilities WHERE capability_id=cap.capability_id;
     IF cost_cap.capability_id IS NULL OR cost_cap.regions_fingerprint<>md5(regions::text) THEN
       RAISE EXCEPTION 'panel_movement_explanation_terrain_changed' USING ERRCODE='40001'; END IF;
     terrain:=combat_panel_private.impervious_path_profile(cap.start_x_m,cap.start_y_m,cap.end_x_m,cap.end_y_m,regions);
     reasons:='[]';
     IF (terrain->>'impervious_distance_m')::numeric>0 THEN
       reasons:=jsonb_build_array(jsonb_build_object('kind','path_surcharge',
         'source_kind',CASE WHEN visible_areas THEN 'environment' ELSE 'undisclosed' END,
         'label',CASE WHEN visible_areas THEN 'Il tratto nelle aree impervie consuma movimento doppio.'
           ELSE 'Il percorso richiede movimento aggiuntivo per le condizioni attuali.' END,
         'amount_m',CASE WHEN visible_areas THEN round((terrain->>'impervious_distance_m')::numeric,2) ELSE NULL END));
     END IF;
     IF effective<round(desired,2) THEN
       block_t:=combat_spatial.path_first_block_t(iid,cap.actor_id,cap.start_x_m,cap.start_y_m,choice.endpoint_x_m,choice.endpoint_y_m);
       -- Un ostacolo successivo al limite del budget non ha fermato questo movimento.
       IF block_t<1 AND (terrain->>'distance_m')::numeric+0.000000001>=desired*block_t THEN
         reasons:=reasons||jsonb_build_array(jsonb_build_object('kind','blocked','source_kind','undisclosed',
           'label','Il percorso si arresta prima della destinazione per i limiti attuali dello scontro.',
           'amount_m',NULL));
       END IF;
     END IF;
     entries:=entries||jsonb_build_array(jsonb_build_object('offer_id',o.id,'option_id',q.id,
       'effective_distance_m',effective,'reasons',reasons));
   END LOOP;
 END LOOP;
 RETURN jsonb_build_object('contract_version','movement-explanations/2',
   'context_version',c.context_version,'entries',entries);
END $function$
;
DO $post$ BEGIN
IF md5(pg_get_functiondef('combat_panel_private.movement_explanations(uuid,bigint)'::regprocedure)) IS DISTINCT FROM 'd42c7b3e82419750385a4c50043c0942' THEN RAISE EXCEPTION 'inuzuka_movement_explanations_post'; END IF;
END $post$;
COMMIT;
