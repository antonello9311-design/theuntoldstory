BEGIN;
SET LOCAL lock_timeout='3s';
DO $pre$ BEGIN
IF md5(pg_get_functiondef('combat_panel_private.master_companion_projection(uuid)'::regprocedure)) IS DISTINCT FROM '47fb0bb47f210ef82481bc2a5ffbcfb9' THEN RAISE EXCEPTION 'inuzuka_master_routes_pre_0'; END IF;
IF md5(pg_get_functiondef('clan_inuzuka_private.master_control_offers(uuid,bigint)'::regprocedure)) IS DISTINCT FROM 'ccb45fbdd0ab076d94f8109c551825ec' THEN RAISE EXCEPTION 'inuzuka_master_routes_pre_1'; END IF;
END $pre$;
CREATE OR REPLACE FUNCTION combat_panel_private.master_companion_projection(p_actor uuid)
 RETURNS jsonb
 LANGUAGE plpgsql
 STABLE SECURITY DEFINER
 SET search_path TO ''
AS $function$
DECLARE owner_actor public.combat_v2_actors%ROWTYPE; b public.combat_v2_actors%ROWTYPE;
 src clan_marionettisti_private.sources%ROWTYPE; h clan_marionettisti_private.chassis%ROWTYPE;
 link clan_marionettisti_private.links%ROWTYPE; label text;
BEGIN
 IF auth.uid() IS NULL OR p_actor IS NULL THEN RETURN NULL; END IF;
 SELECT a.* INTO owner_actor FROM public.combat_v2_actors a
   JOIN public.combat_v2_sessions s ON s.id=a.session_id AND s.source_kind='master'
   JOIN combat_panel_private.master_panel_sessions p ON p.master_session_id=s.master_session_id
   WHERE a.id=p_actor AND a.controller_user=auth.uid() AND a.actor_kind='pg' AND a.companion_id IS NULL;
 IF owner_actor.id IS NULL THEN RETURN NULL; END IF;
 SELECT a.* INTO b FROM public.combat_v2_actors a JOIN clan_marionettisti_private.sources s ON s.id=a.companion_id
   WHERE a.session_id=owner_actor.session_id AND s.owner_character_id=owner_actor.character_id AND s.is_active;
 IF b.id IS NULL THEN RETURN NULL; END IF;
 PERFORM clan_marionettisti_private.assert_companion_actor(b.id,false);
 SELECT * INTO STRICT src FROM clan_marionettisti_private.sources WHERE id=b.companion_id;
 SELECT * INTO STRICT h FROM clan_marionettisti_private.chassis WHERE companion_id=src.id;
 SELECT * INTO link FROM clan_marionettisti_private.links WHERE owner_actor_id=owner_actor.id AND companion_actor_id=b.id;
 -- Match the authoritative Master roster display label for the same body.
 label:='Marionetta';
 RETURN jsonb_build_object('schema_version','combat-companion/1','actor_id',b.id,'display_name',label,
   'commanded_by_me',true,'passive',true,'simulated',src.source_kind='staff',
   'integrity',h.integrity,'integrity_max',h.integrity_max,'link_state',
   CASE WHEN b.state<>'attivo' OR owner_actor.state<>'attivo' OR NOT h.operational THEN 'unavailable'
     ELSE coalesce(link.state,'unavailable') END);
END $function$
;
CREATE OR REPLACE FUNCTION clan_inuzuka_private.master_control_offers(p_context uuid, p_expected bigint)
 RETURNS void
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO ''
AS $function$
DECLARE c combat_panel_private.contexts%ROWTYPE;cc public.character_companions%ROWTYPE;placement jsonb;
 ninken uuid;caps jsonb;item jsonb;move jsonb;moves jsonb:='[]';cap combat_spatial.movement_capabilities%ROWTYPE;
 state clan_innata_combat_private.combat_state%ROWTYPE;scope jsonb;
 oid uuid;direction_group uuid;direction_id uuid;distance_group uuid;direction text;
BEGIN
 c:=combat_panel_private.owned_context(p_context,p_expected);
 IF c.activity_kind<>'master_v2' OR c.command_actor_id IS NULL OR c.round_id IS NULL
  OR NOT clan_inuzuka_private.owner_allowed(c.command_actor_id) THEN RETURN;END IF;
 IF clan_inuzuka_private.staff_profile_needed(c.command_actor_id) THEN
  PERFORM combat_panel_private.create_offer(c.id,c.context_version,'control','control','Prepara profilo Inuzuka',false,
   jsonb_build_object('adapter','master_v2','dispatch','inuzuka_control','inuzuka_operation','staff_profile'));
  RETURN;
 END IF;
 BEGIN scope:=clan_inuzuka_private.quattro_scope(c.command_actor_id);
 EXCEPTION WHEN insufficient_privilege THEN RETURN;END;
 state:=clan_innata_private.combat_state_read(c.command_actor_id,'c11ecd52-43cd-479b-8d5d-08187beba56e');
 IF state.active THEN
  PERFORM combat_panel_private.create_offer(c.id,c.context_version,'control','control','Disattiva Quattro Zampe · gratuito',false,
   jsonb_build_object('adapter','master_v2','dispatch','inuzuka_control','inuzuka_operation','deactivate','expected_state',state.state_version));
 ELSIF coalesce((SELECT (a.mechanics_snapshot->>'chakra')::integer FROM public.combat_v2_actors a WHERE a.id=c.command_actor_id),0)>=5
  AND clan_innata_private.combat_activation_window(c.command_actor_id,'c11ecd52-43cd-479b-8d5d-08187beba56e'::uuid) THEN
  PERFORM combat_panel_private.create_offer(c.id,c.context_version,'control','control','Attiva Quattro Zampe · 5 chakra',false,
   jsonb_build_object('adapter','master_v2','dispatch','inuzuka_control','inuzuka_operation','activate','expected_state',state.state_version));
 END IF;
 SELECT companion.* INTO cc FROM public.character_companions companion JOIN public.combat_v2_actors owner
  ON owner.character_id=companion.character_id WHERE owner.id=c.command_actor_id
  AND companion.kind='cane_ninja' AND companion.is_active ORDER BY companion.created_at,companion.id LIMIT 1;
 IF cc.id IS NULL THEN RETURN;END IF;
 ninken:=clan_inuzuka_private.ninken_actor(c.command_actor_id);
 IF ninken IS NULL THEN
  placement:=clan_inuzuka_private.placement(c.command_actor_id);IF placement IS NULL THEN RETURN;END IF;
  PERFORM combat_panel_private.create_offer(c.id,c.context_version,'control','control','Schiera il ninken',false,
   jsonb_build_object('adapter','master_v2','dispatch','inuzuka_control','inuzuka_operation','bind',
    'companion_id',cc.id,'placement',placement,'companion_context_required',true));
  RETURN;
 END IF;
 caps:=clan_inuzuka_private.movement_options(c.command_actor_id);
 FOR item IN SELECT value FROM jsonb_array_elements(caps) LOOP
  SELECT * INTO STRICT cap FROM combat_spatial.movement_capabilities WHERE capability_id=(item->>'option_id')::uuid;
  direction:=CASE WHEN cap.end_x_m=cap.start_x_m AND cap.end_y_m<cap.start_y_m THEN 'up'
   WHEN cap.end_x_m=cap.start_x_m AND cap.end_y_m>cap.start_y_m THEN 'down'
   WHEN cap.end_y_m=cap.start_y_m AND cap.end_x_m<cap.start_x_m THEN 'left'
   WHEN cap.end_y_m=cap.start_y_m AND cap.end_x_m>cap.start_x_m THEN 'right' END;
  IF direction IS NULL THEN RAISE EXCEPTION 'inuzuka_direction_invalid' USING ERRCODE='22023';END IF;
  moves:=moves||jsonb_build_array(jsonb_build_object('capability_id',cap.capability_id,
   'direction',direction,'distance_m',item->'distance_m'));
 END LOOP;
 IF jsonb_array_length(moves)=0 THEN RETURN;END IF;
 oid:=combat_panel_private.create_offer(c.id,c.context_version,'control','control','Muovi il ninken',false,
  jsonb_build_object('adapter','master_v2','dispatch','inuzuka_control','inuzuka_operation','move',
   'companion_id',cc.id,'ninken_actor_id',ninken,'companion_context_required',true));
 direction_group:=combat_panel_private.add_group(oid,'Direzione','movement_direction','single',1,1);
 FOREACH direction IN ARRAY ARRAY['up','right','down','left'] LOOP
  IF NOT EXISTS(SELECT 1 FROM jsonb_array_elements(moves) WHERE value->>'direction'=direction) THEN CONTINUE;END IF;
  direction_id:=combat_panel_private.add_choice(direction_group,CASE direction WHEN 'up' THEN 'Su'
   WHEN 'right' THEN 'Destra' WHEN 'down' THEN 'Giù' ELSE 'Sinistra' END,
   jsonb_build_object('direction',direction),NULL,direction);
  distance_group:=combat_panel_private.add_group(oid,'Distanza','movement_distance','single',1,1,direction_id);
  FOR move IN SELECT DISTINCT ON ((value->>'distance_m')::numeric) value FROM jsonb_array_elements(moves)
   WHERE value->>'direction'=direction ORDER BY (value->>'distance_m')::numeric,value->>'capability_id' LOOP
   PERFORM combat_panel_private.add_choice(distance_group,(move->>'distance_m')::numeric::integer::text||' m',
    jsonb_build_object('movement_capability_id',move->'capability_id'),(move->>'distance_m')::numeric,direction);
  END LOOP;
 END LOOP;
END $function$
;
DO $post$ BEGIN
IF md5(pg_get_functiondef('combat_panel_private.master_companion_projection(uuid)'::regprocedure)) IS DISTINCT FROM 'f8668b54c97a281050359b2887bef3cc' THEN RAISE EXCEPTION 'inuzuka_master_routes_post_0'; END IF;
IF md5(pg_get_functiondef('clan_inuzuka_private.master_control_offers(uuid,bigint)'::regprocedure)) IS DISTINCT FROM '6a993eec4524f7735197693fbcf48f43' THEN RAISE EXCEPTION 'inuzuka_master_routes_post_1'; END IF;
END $post$;
COMMIT;
