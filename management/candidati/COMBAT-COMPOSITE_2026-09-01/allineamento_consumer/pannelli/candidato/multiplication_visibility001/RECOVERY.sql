-- COMBAT-MULTIPLICATION-VISIBILITY-CANDIDATE-001 RECOVERY; candidate only. No game-data operations.
BEGIN;
SET LOCAL search_path=pg_catalog,public;
SET LOCAL lock_timeout='5s';
SET LOCAL statement_timeout='120s';
SELECT pg_advisory_xact_lock(hashtextextended('combat_panel_private.multiplication_prepare_declaration:visibility-release',731));
DO $pin$ DECLARE o oid; BEGIN
o:=to_regprocedure('combat_panel_private.body_visible_to_viewer(uuid,uuid)'); IF o IS NULL THEN RAISE EXCEPTION 'multiplication_visibility_missing:%','combat_panel_private.body_visible_to_viewer(uuid,uuid)'; END IF;
IF md5(pg_get_functiondef(o)) IS DISTINCT FROM 'edc4e353722437fc5d17e7918c02b12c' OR NOT EXISTS(SELECT 1 FROM pg_catalog.pg_proc p WHERE p.oid=o AND pg_get_userbyid(p.proowner)='postgres' AND p.proacl::text IS NOT DISTINCT FROM '{postgres=X/postgres}' AND p.prosecdef=true AND p.provolatile='s' AND p.proconfig IS NOT DISTINCT FROM ARRAY['search_path=""']::text[]) THEN RAISE EXCEPTION 'multiplication_visibility_drift:%','combat_panel_private.body_visible_to_viewer(uuid,uuid)'; END IF;
o:=to_regprocedure('combat_panel_private.multiplication_prepare_declaration(uuid,uuid,text,integer,jsonb,integer,uuid,uuid,uuid)'); IF o IS NULL THEN RAISE EXCEPTION 'multiplication_visibility_missing:%','combat_panel_private.multiplication_prepare_declaration(uuid,uuid,text,integer,jsonb,integer,uuid,uuid,uuid)'; END IF;
IF md5(pg_get_functiondef(o)) IS DISTINCT FROM '697d6481412b8769e87789abaeb67422' OR NOT EXISTS(SELECT 1 FROM pg_catalog.pg_proc p WHERE p.oid=o AND pg_get_userbyid(p.proowner)='postgres' AND p.proacl::text IS NOT DISTINCT FROM '{postgres=X/postgres}' AND p.prosecdef=true AND p.provolatile='v' AND p.proconfig IS NOT DISTINCT FROM ARRAY['search_path=""']::text[]) THEN RAISE EXCEPTION 'multiplication_visibility_drift:%','combat_panel_private.multiplication_prepare_declaration(uuid,uuid,text,integer,jsonb,integer,uuid,uuid,uuid)'; END IF;
END $pin$;
-- Existing signature/owner/ACL retained by CREATE OR REPLACE and verified after.
CREATE OR REPLACE FUNCTION combat_panel_private.multiplication_prepare_declaration(p_round uuid, p_actor uuid, p_mode text, p_copies integer, p_figures jsonb, p_original integer, p_target uuid, p_movement uuid, p_request uuid)
 RETURNS void
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO ''
AS $function$
DECLARE a public.combat_v2_actors%ROWTYPE; b combat_spatial.actor_states%ROWTYPE;
 i combat_spatial.arena_instances%ROWTYPE; template combat_spatial.arena_templates%ROWTYPE;
 aim combat_panel_private.multiplication_attack_aims%ROWTYPE; target_geometry jsonb; target_x numeric; target_y numeric;
 cap combat_spatial.movement_capabilities%ROWTYPE; plan combat_panel_private.multiplication_declaration_plans%ROWTYPE;
 profile jsonb; original jsonb; budget jsonb; movement jsonb; origin_x numeric; origin_y numeric;
 endpoint_x numeric; endpoint_y numeric; distance numeric; fp text; cost integer; f jsonb;
BEGIN
 IF auth.uid() IS NULL OR p_request IS NULL THEN RAISE EXCEPTION 'panel_authentication_required' USING ERRCODE='28000'; END IF;
 IF p_mode IS NULL OR p_mode NOT IN ('diversivo','copertura','assalto')
   OR (p_mode='assalto') IS DISTINCT FROM (p_target IS NOT NULL) THEN
   RAISE EXCEPTION 'panel_multiplication_mode_invalid' USING ERRCODE='22023'; END IF;
 PERFORM public.combat_v2_lock_round(p_round);
 SELECT * INTO aim FROM combat_panel_private.multiplication_attack_aims
   WHERE request_key=p_request AND target_actor_id=p_target FOR UPDATE;
 IF aim.request_key IS NOT NULL AND (p_mode IS DISTINCT FROM 'assalto' OR aim.actor_id<>p_actor OR aim.round_id<>p_round
   OR aim.principal_user IS DISTINCT FROM auth.uid() OR aim.prepared_transaction<>txid_current()
   OR aim.attack_target_id IS NOT NULL) THEN
   RAISE EXCEPTION 'panel_multiplication_assault_aim_invalid' USING ERRCODE='40001'; END IF;
 fp:=public.combat_v2_sha256(jsonb_build_object('round',p_round,'actor',p_actor,'mode',p_mode,
   'copies',p_copies,'figures',p_figures,'original',p_original,'target',p_target,'movement',p_movement)
     ||CASE WHEN aim.request_key IS NULL THEN '{}'::jsonb ELSE jsonb_build_object('target_formation',aim.formation_id,
       'target_formation_version',aim.formation_version,'target_figure',aim.selected_index) END);
 SELECT * INTO plan FROM combat_panel_private.multiplication_declaration_plans WHERE request_key=p_request;
 IF plan.request_key IS NOT NULL THEN
   IF plan.principal_user<>auth.uid() OR plan.fingerprint<>fp THEN
     RAISE EXCEPTION 'panel_request_key_conflict' USING ERRCODE='22023'; END IF;
   IF plan.declaration_id IS NULL AND plan.prepared_transaction<>txid_current() THEN
     RAISE EXCEPTION 'panel_multiplication_plan_abandoned' USING ERRCODE='40001'; END IF;
   RETURN;
 END IF;
 SELECT * INTO STRICT a FROM public.combat_v2_actors WHERE id=p_actor AND controller_user=auth.uid()
   AND companion_id IS NULL AND state='attivo' FOR UPDATE;
 profile:=combat_panel_private.multiplication_actor_profile(a.id);
 IF profile IS NULL OR profile->>'round_id' IS DISTINCT FROM p_round::text
   OR NOT coalesce((profile->>'available')::boolean,false) THEN
   RAISE EXCEPTION 'panel_multiplication_not_available' USING ERRCODE='40001'; END IF;
 SELECT (value->>'chakra_cost')::integer INTO cost FROM jsonb_array_elements(profile->'copy_options')
   WHERE (value->>'copies')::integer=p_copies;
 IF cost IS NULL OR NOT combat_panel_private.multiplication_formation_valid(p_figures,p_copies,(profile->>'copy_cap')::integer,p_original) THEN
   RAISE EXCEPTION 'panel_multiplication_formation_invalid' USING ERRCODE='22023'; END IF;
 SELECT * INTO STRICT i FROM combat_spatial.arena_instances WHERE encounter_id=a.session_id AND state='open' FOR UPDATE;
 IF NOT combat_panel_private.shared_movement_scope(i.instance_id) THEN
   RAISE EXCEPTION 'panel_multiplication_scene_invalid' USING ERRCODE='42501'; END IF;
 SELECT * INTO STRICT template FROM combat_spatial.arena_templates WHERE template_key=i.template_key AND template_version=i.template_version;
 SELECT * INTO STRICT b FROM combat_spatial.actor_states WHERE instance_id=i.instance_id AND actor_id=a.id AND state='active' FOR UPDATE;
 IF b.controller_principal_id IS DISTINCT FROM auth.uid() THEN
   RAISE EXCEPTION 'panel_multiplication_controller_stale' USING ERRCODE='40001'; END IF;
 FOR f IN SELECT value FROM jsonb_array_elements(p_figures) LOOP
   IF (f->>'x_m')::numeric NOT BETWEEN b.footprint_radius_m AND template.width_m-b.footprint_radius_m
     OR (f->>'y_m')::numeric NOT BETWEEN b.footprint_radius_m AND template.height_m-b.footprint_radius_m THEN
     RAISE EXCEPTION 'panel_multiplication_figure_outside_arena' USING ERRCODE='22023'; END IF;
 END LOOP;
 SELECT value INTO STRICT original FROM jsonb_array_elements(p_figures) WHERE (value->>'figure_index')::integer=p_original;
 origin_x:=b.x_m; origin_y:=b.y_m; endpoint_x:=(original->>'x_m')::numeric; endpoint_y:=(original->>'y_m')::numeric;
 distance:=combat_spatial.distance_m(origin_x,origin_y,endpoint_x,endpoint_y);
 budget:=combat_panel_private.movement_budget(a.id,p_round);
 IF distance>0 THEN
   IF p_movement IS NULL OR (budget->>'spent_m')::numeric>0 OR distance>(budget->>'remaining_m')::numeric
     OR combat_panel_private.movement_block_reason(a.id) IS NOT NULL THEN
     RAISE EXCEPTION 'panel_multiplication_single_movement_required' USING ERRCODE='22023'; END IF;
   SELECT * INTO STRICT cap FROM combat_spatial.movement_capabilities WHERE capability_id=p_movement FOR UPDATE;
   IF cap.instance_id<>i.instance_id OR cap.actor_id<>a.id OR cap.state<>'offered'
     OR cap.actor_body_version<>b.body_version OR cap.map_version<>i.map_version
     OR (cap.start_x_m,cap.start_y_m,cap.end_x_m,cap.end_y_m) IS DISTINCT FROM (origin_x,origin_y,endpoint_x,endpoint_y)
     OR combat_spatial.path_first_block_t(i.instance_id,a.id,origin_x,origin_y,endpoint_x,endpoint_y)<1 THEN
     RAISE EXCEPTION 'panel_multiplication_movement_stale' USING ERRCODE='40001'; END IF;
 ELSIF p_movement IS NOT NULL THEN
   RAISE EXCEPTION 'panel_multiplication_zero_movement_capability' USING ERRCODE='22023'; END IF;
 IF p_mode='assalto' THEN
   PERFORM 1 FROM public.combat_v2_actors WHERE id=p_target AND session_id=a.session_id
     AND state='attivo' AND team_key<>a.team_key FOR KEY SHARE;
   IF NOT FOUND THEN RAISE EXCEPTION 'panel_multiplication_target_invalid' USING ERRCODE='22023'; END IF;
   IF aim.request_key IS NOT NULL THEN
     target_geometry:=combat_panel_private.multiplication_target_figure(a.id,p_target,aim.formation_id,aim.formation_version,aim.selected_index);
     IF target_geometry IS DISTINCT FROM aim.geometry THEN RAISE EXCEPTION 'panel_multiplication_aim_stale' USING ERRCODE='40001'; END IF;
     target_x:=(target_geometry#>>'{figure,x_m}')::numeric;target_y:=(target_geometry#>>'{figure,y_m}')::numeric;
   ELSE
     IF EXISTS(SELECT 1 FROM combat_panel_private.multiplication_formations WHERE actor_id=p_target AND state='active') THEN
       RAISE EXCEPTION 'panel_multiplication_target_choice_required' USING ERRCODE='22023'; END IF;
     SELECT tb.x_m,tb.y_m INTO STRICT target_x,target_y FROM combat_spatial.actor_states tb
       WHERE tb.instance_id=i.instance_id AND tb.actor_id=p_target AND tb.state='active';
   END IF;
   IF NOT EXISTS(SELECT 1 FROM combat_spatial.viewer_grants WHERE instance_id=i.instance_id
       AND viewer_principal_id=auth.uid() AND subject_actor_id=p_target AND can_view_map)
     OR combat_spatial.distance_m(endpoint_x,endpoint_y,target_x,target_y)>2
     OR (endpoint_x-origin_x)*(target_x-origin_x)+(endpoint_y-origin_y)*(target_y-origin_y)<0
     OR (target_x-endpoint_x)*(target_x-origin_x)+(target_y-endpoint_y)*(target_y-origin_y)<0
     OR combat_spatial.path_first_block_t(i.instance_id,a.id,endpoint_x,endpoint_y,target_x,target_y,p_target)<1 THEN
     RAISE EXCEPTION 'panel_multiplication_assault_contact_invalid' USING ERRCODE='22023'; END IF;
 END IF;
 IF distance>0 THEN
   movement:=combat_spatial.movement_commit(cap.capability_id,
     md5(p_request::text||':multiplication-movement')::uuid,p_request);
   IF combat_panel_private.movement_event_cost((movement->>'event_id')::uuid,distance)>(budget->>'remaining_m')::numeric THEN
     RAISE EXCEPTION 'panel_multiplication_movement_budget_exceeded' USING ERRCODE='40001'; END IF;
   IF clan_sabaku_private.clone_movement_interruption(cap.capability_id) IS NOT NULL THEN
     PERFORM clan_sabaku_private.clone_record_interrupted_movement(cap.capability_id,p_round,a.id);
     RETURN;
   END IF;
   SELECT * INTO STRICT b FROM combat_spatial.actor_states WHERE instance_id=i.instance_id AND actor_id=a.id;
   IF (b.x_m,b.y_m) IS DISTINCT FROM (endpoint_x,endpoint_y) THEN
     RAISE EXCEPTION 'panel_multiplication_original_not_reached' USING ERRCODE='40001'; END IF;
 END IF;
 IF aim.request_key IS NOT NULL THEN
   -- Solo la geometria cambia dopo il movimento autorizzato della stessa TX.
   -- Figura, formazione, versione e controllore restano quelli sigillati.
   target_geometry:=combat_panel_private.multiplication_target_figure(a.id,p_target,aim.formation_id,aim.formation_version,aim.selected_index);
   UPDATE combat_panel_private.multiplication_attack_aims SET geometry=target_geometry
     WHERE request_key=p_request AND target_actor_id=p_target AND actor_id=a.id
       AND prepared_transaction=txid_current() AND attack_target_id IS NULL;
   IF NOT FOUND THEN RAISE EXCEPTION 'panel_multiplication_assault_aim_invalid' USING ERRCODE='40001'; END IF;
 END IF;
 INSERT INTO combat_panel_private.multiplication_declaration_plans(request_key,principal_user,prepared_transaction,
   round_id,actor_id,instance_id,controller_version,source_body_version,mode,copies,copy_cap,chakra_cost,figures,
   original_index,target_actor_id,movement_event_id,movement_m,fingerprint)
 VALUES(p_request,auth.uid(),txid_current(),p_round,a.id,i.instance_id,a.controller_version,b.body_version,
   p_mode,p_copies,(profile->>'copy_cap')::integer,cost,p_figures,p_original,p_target,(movement->>'event_id')::uuid,distance,fp);
END $function$;
DO $pin$ DECLARE o oid; BEGIN
o:=to_regprocedure('combat_panel_private.body_visible_to_viewer(uuid,uuid)'); IF o IS NULL THEN RAISE EXCEPTION 'multiplication_visibility_missing:%','combat_panel_private.body_visible_to_viewer(uuid,uuid)'; END IF;
IF md5(pg_get_functiondef(o)) IS DISTINCT FROM 'edc4e353722437fc5d17e7918c02b12c' OR NOT EXISTS(SELECT 1 FROM pg_catalog.pg_proc p WHERE p.oid=o AND pg_get_userbyid(p.proowner)='postgres' AND p.proacl::text IS NOT DISTINCT FROM '{postgres=X/postgres}' AND p.prosecdef=true AND p.provolatile='s' AND p.proconfig IS NOT DISTINCT FROM ARRAY['search_path=""']::text[]) THEN RAISE EXCEPTION 'multiplication_visibility_drift:%','combat_panel_private.body_visible_to_viewer(uuid,uuid)'; END IF;
o:=to_regprocedure('combat_panel_private.multiplication_prepare_declaration(uuid,uuid,text,integer,jsonb,integer,uuid,uuid,uuid)'); IF o IS NULL THEN RAISE EXCEPTION 'multiplication_visibility_missing:%','combat_panel_private.multiplication_prepare_declaration(uuid,uuid,text,integer,jsonb,integer,uuid,uuid,uuid)'; END IF;
IF md5(pg_get_functiondef(o)) IS DISTINCT FROM '7a3c2f8e8b7a05643ff5750d859a7c17' OR NOT EXISTS(SELECT 1 FROM pg_catalog.pg_proc p WHERE p.oid=o AND pg_get_userbyid(p.proowner)='postgres' AND p.proacl::text IS NOT DISTINCT FROM '{postgres=X/postgres}' AND p.prosecdef=true AND p.provolatile='v' AND p.proconfig IS NOT DISTINCT FROM ARRAY['search_path=""']::text[]) THEN RAISE EXCEPTION 'multiplication_visibility_drift:%','combat_panel_private.multiplication_prepare_declaration(uuid,uuid,text,integer,jsonb,integer,uuid,uuid,uuid)'; END IF;
END $pin$;
COMMIT;
