BEGIN;

-- Shuriken / Combat V2. The public gate stays closed until Staff acceptance.
CREATE TABLE combat_panel_private.shuriken_spend_v1 (
  declaration_id uuid PRIMARY KEY,
  session_id uuid NOT NULL,
  actor_id uuid NOT NULL,
  simulated boolean NOT NULL,
  spent_at timestamptz NOT NULL DEFAULT now()
);
ALTER TABLE combat_panel_private.shuriken_spend_v1 ENABLE ROW LEVEL SECURITY;
REVOKE ALL ON TABLE combat_panel_private.shuriken_spend_v1 FROM PUBLIC, anon, authenticated, service_role;
CREATE UNIQUE INDEX shuriken_spend_simulated_once_v1
  ON combat_panel_private.shuriken_spend_v1 (session_id, actor_id) WHERE simulated;

CREATE FUNCTION combat_panel_private.shuriken_public_enabled_v1() RETURNS boolean
LANGUAGE sql IMMUTABLE SET search_path TO ''
AS $fn$ SELECT false $fn$;
REVOKE ALL ON FUNCTION combat_panel_private.shuriken_public_enabled_v1() FROM PUBLIC, anon, authenticated, service_role;

CREATE FUNCTION combat_panel_private.shuriken_profile_v1() RETURNS jsonb
LANGUAGE sql IMMUTABLE SET search_path TO ''
AS $fn$
  SELECT jsonb_build_object(
    'source','arma','id','298df4d4-6b82-4b58-9ef5-c1d0421e4097',
    'name','Lancia Shuriken','kind','fisico','usage','principale',
    'range','corta','range_m',10,'chakra_cost',0,'damage_base',10,'element',null
  )
$fn$;
REVOKE ALL ON FUNCTION combat_panel_private.shuriken_profile_v1() FROM PUBLIC, anon, authenticated, service_role;

CREATE FUNCTION combat_panel_private.shuriken_pool_v1(p_actor uuid) RETURNS text
LANGUAGE sql STABLE SET search_path TO ''
AS $fn$
  SELECT CASE
    WHEN l.id='0b85f354-9cdb-47e1-baf9-3d266bb7e06b' AND l.is_test IS TRUE
      AND a.character_id IN ('6bceee99-974f-426b-8d92-38b43b4a4267','2a877f02-4993-4e65-9172-7d29f08c5b86')
      AND combat_panel_private.uses_simulated_pools(s.id) THEN 'staff'
    WHEN l.is_test IS FALSE AND combat_panel_private.shuriken_public_enabled_v1() THEN 'land'
  END
  FROM public.combat_v2_actors a
  JOIN public.characters c ON c.id=a.character_id AND c.user_id=auth.uid()
  JOIN public.combat_v2_sessions s ON s.id=a.session_id AND s.source_kind IN ('ordinary','master')
  JOIN public.locations l ON l.id=s.location_id AND l.is_active AND l.is_exam_room IS NOT TRUE
  JOIN public.items i ON i.id=(combat_panel_private.shuriken_profile_v1()->>'id')::uuid
    AND i.is_active AND i.category='arma_consumabile'
  WHERE a.id=p_actor AND a.actor_kind='pg' AND a.state='attivo'
    AND s.state NOT IN ('chiuso','annullato')
$fn$;
REVOKE ALL ON FUNCTION combat_panel_private.shuriken_pool_v1(uuid) FROM PUBLIC, anon, authenticated, service_role;

CREATE FUNCTION combat_panel_private.shuriken_available_v1(p_actor uuid) RETURNS jsonb
LANGUAGE sql STABLE SET search_path TO ''
AS $fn$
  SELECT CASE combat_panel_private.shuriken_pool_v1(p_actor)
    WHEN 'staff' THEN CASE WHEN NOT EXISTS (
      SELECT 1 FROM combat_panel_private.shuriken_spend_v1 s
      WHERE s.session_id=a.session_id AND s.actor_id=a.id AND s.simulated
    ) THEN combat_panel_private.shuriken_profile_v1() END
    WHEN 'land' THEN CASE WHEN EXISTS (
      SELECT 1 FROM public.character_equipment e
      JOIN public.character_inventory i ON i.character_id=e.character_id AND i.item_id=e.item_id
      WHERE e.character_id=a.character_id AND e.item_id=(combat_panel_private.shuriken_profile_v1()->>'id')::uuid
        AND e.quantity>0 AND i.quantity>0
        AND NOT EXISTS (SELECT 1 FROM public.character_equipment child WHERE child.parent_id=e.id)
    ) THEN combat_panel_private.shuriken_profile_v1() END
  END
  FROM public.combat_v2_actors a WHERE a.id=p_actor
$fn$;
REVOKE ALL ON FUNCTION combat_panel_private.shuriken_available_v1(uuid) FROM PUBLIC, anon, authenticated, service_role;

CREATE FUNCTION combat_panel_private.shuriken_target_v1(p_actor uuid,p_target uuid) RETURNS boolean
LANGUAGE sql STABLE SET search_path TO ''
AS $fn$
  SELECT CASE WHEN EXISTS (
    SELECT 1 FROM public.combat_v2_actors a
    JOIN public.combat_v2_actors t ON t.session_id=a.session_id AND t.team_key<>a.team_key
      AND t.id=p_target AND t.state='attivo'
    JOIN combat_spatial.arena_instances i ON i.encounter_id=a.session_id AND i.state='open'
    JOIN combat_spatial.actor_states origin ON origin.instance_id=i.instance_id AND origin.actor_id=a.id AND origin.state='active'
    JOIN combat_spatial.actor_states target ON target.instance_id=i.instance_id AND target.actor_id=t.id AND target.state='active'
    WHERE a.id=p_actor AND a.state='attivo'
      AND NOT EXISTS (SELECT 1 FROM combat_panel_private.multiplication_formations f WHERE f.actor_id=p_target AND f.state='active')
  ) THEN COALESCE(combat_v2_elemental_internal.other_target_visible(
    p_actor,p_target,(combat_panel_private.shuriken_profile_v1()->>'range_m')::numeric
  ),false) ELSE false END
$fn$;
REVOKE ALL ON FUNCTION combat_panel_private.shuriken_target_v1(uuid,uuid) FROM PUBLIC, anon, authenticated, service_role;

CREATE FUNCTION combat_panel_private.shuriken_spend_v1(p_declaration uuid,p_request_key uuid) RETURNS void
LANGUAGE plpgsql SET search_path TO ''
AS $fn$
DECLARE
  v_actor uuid;
  v_session uuid;
  v_character uuid;
  v_item uuid := (combat_panel_private.shuriken_profile_v1()->>'id')::uuid;
  v_pool text;
  v_equipment uuid;
BEGIN
  SELECT a.id,a.session_id,a.character_id INTO STRICT v_actor,v_session,v_character
  FROM public.combat_v2_declarations d
  JOIN public.combat_v2_actors a ON a.id=d.actor_id
  JOIN public.combat_v2_rounds r ON r.id=d.round_id AND r.session_id=a.session_id
  WHERE d.id=p_declaration AND d.request_key=p_request_key AND d.kind='attacco'
    AND d.sanitized_intent#>>'{server_ability,source}'='arma'
    AND d.sanitized_intent#>>'{server_ability,id}'=v_item::text;

  v_pool:=combat_panel_private.shuriken_pool_v1(v_actor);
  IF v_pool IS NULL THEN
    PERFORM public.combat_v2_fail('opzione_non_offerta','Lancio dello Shuriken non disponibile.',422,p_request_key,'{}');
  END IF;

  IF v_pool='land' THEN
    -- Shared with the inventory writers before any stock reads.
    PERFORM 1 FROM public.characters WHERE id=v_character FOR UPDATE;
    PERFORM clan_akimichi_private.meal_inventory_lock(v_character,v_item);
    SELECT e.id INTO v_equipment
    FROM public.character_equipment e
    WHERE e.character_id=v_character AND e.item_id=v_item AND e.quantity>0
      AND NOT EXISTS (SELECT 1 FROM public.character_equipment child WHERE child.parent_id=e.id)
    ORDER BY e.id LIMIT 1 FOR UPDATE;
    IF v_equipment IS NULL THEN
      PERFORM public.combat_v2_fail('shuriken_non_disponibile','Equipaggia uno Shuriken per lanciarlo.',409,p_request_key,'{}');
    END IF;
    UPDATE public.character_inventory i SET quantity=i.quantity-1
    WHERE i.character_id=v_character AND i.item_id=v_item AND i.quantity>0;
    IF NOT FOUND THEN
      PERFORM public.combat_v2_fail('shuriken_non_disponibile','Non hai Shuriken disponibili.',409,p_request_key,'{}');
    END IF;
    PERFORM public.unequip_row(v_equipment,1);
  END IF;

  INSERT INTO combat_panel_private.shuriken_spend_v1(declaration_id,session_id,actor_id,simulated)
  VALUES (p_declaration,v_session,v_actor,v_pool='staff');
END
$fn$;
REVOKE ALL ON FUNCTION combat_panel_private.shuriken_spend_v1(uuid,uuid) FROM PUBLIC, anon, authenticated, service_role;

CREATE FUNCTION combat_panel_private.shuriken_resolved_v1(p_declaration uuid) RETURNS boolean
LANGUAGE sql STABLE SET search_path TO ''
AS $fn$
  SELECT EXISTS (
    SELECT 1 FROM public.combat_v2_declarations d
    JOIN public.combat_v2_rounds r ON r.id=d.round_id
    JOIN combat_panel_private.shuriken_spend_v1 s ON s.declaration_id=d.id
      AND s.session_id=r.session_id AND s.actor_id=d.actor_id
    WHERE d.id=p_declaration AND d.kind='attacco' AND d.state='risolta'
      AND d.sanitized_intent#>>'{server_ability,source}'='arma'
      AND d.sanitized_intent#>>'{server_ability,id}'=combat_panel_private.shuriken_profile_v1()->>'id'
  )
$fn$;
REVOKE ALL ON FUNCTION combat_panel_private.shuriken_resolved_v1(uuid) FROM PUBLIC, anon, authenticated, service_role;

DO $compose$
DECLARE v_oid oid; v_definition text;
BEGIN
  SELECT p.oid INTO STRICT v_oid FROM pg_proc p JOIN pg_namespace n ON n.oid=p.pronamespace
    WHERE n.nspname='public' AND p.proname='combat_v2_action_declare';
  v_definition:=pg_get_functiondef(v_oid);
  IF md5(v_definition) IS DISTINCT FROM 'a599b31eb137d549f82b2fb6d4a01c02' THEN RAISE EXCEPTION 'shuriken baseline drift: combat_v2_action_declare'; END IF;
  v_definition:=replace(v_definition,$patch$    elsif v_source in ('clan','jutsu') then$patch$,$patch$    elsif v_source='arma' then
      v_meta:=combat_panel_private.shuriken_available_v1(p_actor);
      if v_meta is null or v_i->>'ability_id' is distinct from v_meta->>'id'
         or v_i ? 'move_m'
         or (v_i ? 'target_actor_ids' and v_i->'target_actor_ids' is distinct from jsonb_build_array(v_target))
         or not combat_panel_private.shuriken_target_v1(p_actor,v_target) then
        perform public.combat_v2_fail('shuriken_non_disponibile','Serve uno Shuriken disponibile e un bersaglio visibile entro 10 metri.',422,p_request_key,'{}');
      end if;
    elsif v_source in ('clan','jutsu') then$patch$);
  v_definition:=replace(v_definition,$patch$  IF v_meta ? 'nara_launch' THEN
    PERFORM combat_panel_private.nara_freeze_segment_positions_v1(v_id);$patch$,$patch$  IF v_source='arma' THEN
    PERFORM combat_panel_private.shuriken_spend_v1(v_id,p_request_key);
  END IF;
  IF v_meta ? 'nara_launch' THEN
    PERFORM combat_panel_private.nara_freeze_segment_positions_v1(v_id);$patch$);
  IF md5(v_definition) IS DISTINCT FROM 'c7d780c56576215e5267da68f75aeee0' THEN RAISE EXCEPTION 'shuriken composition drift: combat_v2_action_declare'; END IF;
  EXECUTE v_definition;
  SELECT p.oid INTO STRICT v_oid FROM pg_proc p JOIN pg_namespace n ON n.oid=p.pronamespace
    WHERE n.nspname='combat_panel_private' AND p.proname='master_actor_offers';
  v_definition:=pg_get_functiondef(v_oid);
  IF md5(v_definition) IS DISTINCT FROM '907706e0d4a03e59b41ac1af2e6e71fe' THEN RAISE EXCEPTION 'shuriken baseline drift: master_actor_offers'; END IF;
  v_definition:=replace(v_definition,$patch$ELSE jsonb_build_array(clan_hoki_private.needle_ability(a.id,false)) END) LOOP$patch$,$patch$ELSE jsonb_build_array(clan_hoki_private.needle_ability(a.id,false)) END
      ||coalesce((SELECT jsonb_agg(x.profile) FROM (SELECT combat_panel_private.shuriken_available_v1(a.id) AS profile) x
        WHERE x.profile IS NOT NULL),'[]'::jsonb)) LOOP$patch$);
  v_definition:=replace(v_definition,$patch$WHEN meta->>'source'='mano' THEN 2 ELSE public._fascia_metri$patch$,$patch$WHEN meta->>'source'='arma' THEN (meta->>'range_m')::numeric WHEN meta->>'source'='mano' THEN 2 ELSE public._fascia_metri$patch$);
  v_definition:=replace(v_definition,$patch$         can_stay:=true;
       ELSIF EXISTS(SELECT 1 FROM combat_panel_private.multiplication_formations$patch$,$patch$         can_stay:=true;
       ELSIF meta->>'source'='arma' THEN
         IF NOT combat_panel_private.shuriken_target_v1(a.id,target_id) THEN CONTINUE; END IF;
         can_stay:=true;
       ELSIF EXISTS(SELECT 1 FROM combat_panel_private.multiplication_formations$patch$);
  v_definition:=replace(v_definition,$patch$FOR n IN 2..(CASE WHEN meta ? 'nara_range_m' OR$patch$,$patch$FOR n IN 2..(CASE WHEN meta->>'source'='arma' OR meta ? 'nara_range_m' OR$patch$);
  IF md5(v_definition) IS DISTINCT FROM '315e3c251fc683ff34508e50c5a0e082' THEN RAISE EXCEPTION 'shuriken composition drift: master_actor_offers'; END IF;
  EXECUTE v_definition;
  SELECT p.oid INTO STRICT v_oid FROM pg_proc p JOIN pg_namespace n ON n.oid=p.pronamespace
    WHERE n.nspname='combat_consumer_private' AND p.proname='exchange_options';
  v_definition:=pg_get_functiondef(v_oid);
  IF md5(v_definition) IS DISTINCT FROM 'd0d7b61787a21d625e251483f1917cc3' THEN RAISE EXCEPTION 'shuriken baseline drift: exchange_options'; END IF;
  v_definition:=replace(v_definition,$patch$    caps:=combat_consumer_private.approach_capabilities(ctx.session_id,aid,target);$patch$,$patch$    IF combat_panel_private.shuriken_available_v1(aid) IS NOT NULL
      AND combat_panel_private.shuriken_target_v1(aid,target) THEN
      offered:=combat_consumer_private.offer_exchange(ctx.session_id,aid,target,scene,'declare',
        combat_panel_private.shuriken_profile_v1()->>'name',
        jsonb_build_object('intent',jsonb_build_object('kind','attacco','ability_source','arma',
          'ability_id',combat_panel_private.shuriken_profile_v1()->'id','target_actor',target)));
      IF offered IS NOT NULL THEN offers:=offers||jsonb_build_array(offered); END IF;
    END IF;
    caps:=combat_consumer_private.approach_capabilities(ctx.session_id,aid,target);$patch$);
  IF md5(v_definition) IS DISTINCT FROM '54a1c83a53b993df51d5f544d2e97758' THEN RAISE EXCEPTION 'shuriken composition drift: exchange_options'; END IF;
  EXECUTE v_definition;
  SELECT p.oid INTO STRICT v_oid FROM pg_proc p JOIN pg_namespace n ON n.oid=p.pronamespace
    WHERE n.nspname='combat_consumer_private' AND p.proname='commit_exchange';
  v_definition:=pg_get_functiondef(v_oid);
  IF md5(v_definition) IS DISTINCT FROM '1aa5fa3f6e863050aeef51cf1e2a3464' THEN RAISE EXCEPTION 'shuriken baseline drift: commit_exchange'; END IF;
  v_definition:=replace(v_definition,$patch$    if offer.source_payload ? 'fireball_selection' THEN target:=(offer.source_payload#>>'{intent,target_actor}')::uuid;
    elsif offer.source_payload#>>'{intent,kind}'='attacco' then$patch$,$patch$    if offer.source_payload ? 'fireball_selection' THEN target:=(offer.source_payload#>>'{intent,target_actor}')::uuid;
    elsif offer.source_payload#>>'{intent,kind}'='attacco' AND offer.source_payload#>>'{intent,ability_source}'='arma' then
      -- The common declaration validates the projectile path, range and stock.
      target:=(offer.source_payload#>>'{intent,target_actor}')::uuid;
    elsif offer.source_payload#>>'{intent,kind}'='attacco' then$patch$);
  IF md5(v_definition) IS DISTINCT FROM 'afa2cc75f1effc68d40547843cd8b392' THEN RAISE EXCEPTION 'shuriken composition drift: commit_exchange'; END IF;
  EXECUTE v_definition;
  SELECT p.oid INTO STRICT v_oid FROM pg_proc p JOIN pg_namespace n ON n.oid=p.pronamespace
    WHERE n.nspname='combat_panel_private' AND p.proname='annotate_offer_categories';
  v_definition:=pg_get_functiondef(v_oid);
  IF md5(v_definition) IS DISTINCT FROM 'fd285d2d582fda2f71b15bba5b5647f2' THEN RAISE EXCEPTION 'shuriken baseline drift: annotate_offer_categories'; END IF;
  v_definition:=replace(v_definition,$patch$intent->>'ability_source'<>'mano'$patch$,$patch$intent->>'ability_source' NOT IN ('mano','arma')$patch$);
  v_definition:=replace(v_definition,$patch$intent->>'kind'='attacco' AND intent->>'ability_source'='mano'$patch$,$patch$intent->>'kind'='attacco' AND intent->>'ability_source' IN ('mano','arma')$patch$);
  IF md5(v_definition) IS DISTINCT FROM 'a72c168002d311f74863be764a4bed7e' THEN RAISE EXCEPTION 'shuriken composition drift: annotate_offer_categories'; END IF;
  EXECUTE v_definition;
  SELECT p.oid INTO STRICT v_oid FROM pg_proc p JOIN pg_namespace n ON n.oid=p.pronamespace
    WHERE n.nspname='public' AND p.proname='equip_to_anchor';
  v_definition:=pg_get_functiondef(v_oid);
  IF md5(v_definition) IS DISTINCT FROM 'de4724c17e0e4b25acf38c76410f5fbb' THEN RAISE EXCEPTION 'shuriken baseline drift: equip_to_anchor'; END IF;
  v_definition:=replace(v_definition,$patch$  if exists (select 1 from clan_akimichi_private.meal_items where item_id = p_item) then$patch$,$patch$  if exists (select 1 from clan_akimichi_private.meal_items where item_id = p_item)
     OR (combat_panel_private.shuriken_public_enabled_v1()
         AND p_item=(combat_panel_private.shuriken_profile_v1()->>'id')::uuid) then$patch$);
  IF md5(v_definition) IS DISTINCT FROM 'dc307785b73086b60e1f13dc4ad2fadf' THEN RAISE EXCEPTION 'shuriken composition drift: equip_to_anchor'; END IF;
  EXECUTE v_definition;
  SELECT p.oid INTO STRICT v_oid FROM pg_proc p JOIN pg_namespace n ON n.oid=p.pronamespace
    WHERE n.nspname='public' AND p.proname='place_in_container';
  v_definition:=pg_get_functiondef(v_oid);
  IF md5(v_definition) IS DISTINCT FROM '275727aaff9ff27437f662eb950f9e41' THEN RAISE EXCEPTION 'shuriken baseline drift: place_in_container'; END IF;
  v_definition:=replace(v_definition,$patch$  if exists (select 1 from clan_akimichi_private.meal_items where item_id = p_item) then$patch$,$patch$  if exists (select 1 from clan_akimichi_private.meal_items where item_id = p_item)
     OR (combat_panel_private.shuriken_public_enabled_v1()
         AND p_item=(combat_panel_private.shuriken_profile_v1()->>'id')::uuid) then$patch$);
  IF md5(v_definition) IS DISTINCT FROM 'a6d8faf6de2d6cfd81b1b9a5a71d86e4' THEN RAISE EXCEPTION 'shuriken composition drift: place_in_container'; END IF;
  EXECUTE v_definition;
  SELECT p.oid INTO STRICT v_oid FROM pg_proc p JOIN pg_namespace n ON n.oid=p.pronamespace
    WHERE n.nspname='public' AND p.proname='sell_item';
  v_definition:=pg_get_functiondef(v_oid);
  IF md5(v_definition) IS DISTINCT FROM 'dc4994a7dc41047710bbf1808794e2e3' THEN RAISE EXCEPTION 'shuriken baseline drift: sell_item'; END IF;
  v_definition:=replace(v_definition,$patch$  if exists (select 1 from clan_akimichi_private.meal_items where item_id = p_item_id) then$patch$,$patch$  if exists (select 1 from clan_akimichi_private.meal_items where item_id = p_item_id)
     OR (combat_panel_private.shuriken_public_enabled_v1()
         AND p_item_id=(combat_panel_private.shuriken_profile_v1()->>'id')::uuid) then$patch$);
  IF md5(v_definition) IS DISTINCT FROM 'ab433a671d41a54a0593ac2f74e71797' THEN RAISE EXCEPTION 'shuriken composition drift: sell_item'; END IF;
  EXECUTE v_definition;
  SELECT p.oid INTO STRICT v_oid FROM pg_proc p JOIN pg_namespace n ON n.oid=p.pronamespace
    WHERE n.nspname='public' AND p.proname='staff_adjust_item';
  v_definition:=pg_get_functiondef(v_oid);
  IF md5(v_definition) IS DISTINCT FROM '6e6f40c44f9f50a16329a258f937dd44' THEN RAISE EXCEPTION 'shuriken baseline drift: staff_adjust_item'; END IF;
  v_definition:=replace(v_definition,$patch$  if exists (select 1 from clan_akimichi_private.meal_items where item_id = p_item_id) then$patch$,$patch$  if exists (select 1 from clan_akimichi_private.meal_items where item_id = p_item_id)
     OR (combat_panel_private.shuriken_public_enabled_v1()
         AND p_item_id=(combat_panel_private.shuriken_profile_v1()->>'id')::uuid) then$patch$);
  IF md5(v_definition) IS DISTINCT FROM '5976862c200dcf48f887b04884ec84c3' THEN RAISE EXCEPTION 'shuriken composition drift: staff_adjust_item'; END IF;
  EXECUTE v_definition;
  SELECT p.oid INTO STRICT v_oid FROM pg_proc p JOIN pg_namespace n ON n.oid=p.pronamespace
    WHERE n.nspname='public' AND p.proname='buy_item';
  v_definition:=pg_get_functiondef(v_oid);
  IF md5(v_definition) IS DISTINCT FROM 'b5f1c013f2659aba3825e5772605c630' THEN RAISE EXCEPTION 'shuriken baseline drift: buy_item'; END IF;
  v_definition:=replace(v_definition,$patch$  if exists (select 1 from clan_akimichi_private.meal_items where item_id = p_item_id) then$patch$,$patch$  if exists (select 1 from clan_akimichi_private.meal_items where item_id = p_item_id)
     OR (combat_panel_private.shuriken_public_enabled_v1()
         AND p_item_id=(combat_panel_private.shuriken_profile_v1()->>'id')::uuid) then$patch$);
  IF md5(v_definition) IS DISTINCT FROM '37ea6bccf1c649c6ac8340f0cc026fcc' THEN RAISE EXCEPTION 'shuriken composition drift: buy_item'; END IF;
  EXECUTE v_definition;
  SELECT p.oid INTO STRICT v_oid FROM pg_proc p JOIN pg_namespace n ON n.oid=p.pronamespace
    WHERE n.nspname='public' AND p.proname='unequip_row';
  v_definition:=pg_get_functiondef(v_oid);
  IF md5(v_definition) IS DISTINCT FROM '07ddc1ac27b70b2eee3b57819ddc2031' THEN RAISE EXCEPTION 'shuriken baseline drift: unequip_row'; END IF;
  v_definition:=replace(v_definition,$patch$  if row.anchor is not null and exists(select 1 from public.character_equipment where parent_id=p_equip) then$patch$,$patch$  IF combat_panel_private.shuriken_public_enabled_v1()
    AND (row.item_id=(combat_panel_private.shuriken_profile_v1()->>'id')::uuid
      OR EXISTS(SELECT 1 FROM public.character_equipment child WHERE child.parent_id=p_equip
        AND child.item_id=(combat_panel_private.shuriken_profile_v1()->>'id')::uuid)) THEN
    PERFORM 1 FROM public.characters WHERE id=row.character_id FOR UPDATE;
    PERFORM clan_akimichi_private.meal_inventory_lock(row.character_id,(combat_panel_private.shuriken_profile_v1()->>'id')::uuid);
    SELECT * INTO row FROM public.character_equipment WHERE id=p_equip;
    IF NOT FOUND THEN RAISE EXCEPTION 'Riga non trovata'; END IF;
  END IF;
  if row.anchor is not null and exists(select 1 from public.character_equipment where parent_id=p_equip) then$patch$);
  IF md5(v_definition) IS DISTINCT FROM '2166ca7b2a28f3deb10150346dd29451' THEN RAISE EXCEPTION 'shuriken composition drift: unequip_row'; END IF;
  EXECUTE v_definition;
  SELECT p.oid INTO STRICT v_oid FROM pg_proc p JOIN pg_namespace n ON n.oid=p.pronamespace
    WHERE n.nspname='combat_v2_multitarget_internal' AND p.proname='sync_declaration';
  v_definition:=pg_get_functiondef(v_oid);
  IF md5(v_definition) IS DISTINCT FROM '498741e80f9aae9a0e16f6c92a884330' THEN RAISE EXCEPTION 'shuriken baseline drift: sync_declaration'; END IF;
  v_definition:=replace(v_definition,$patch$   if multiplication_aim_valid is not null then$patch$,$patch$   if new.sanitized_intent->>'ability_source'='arma'
      and new.sanitized_intent->>'ability_id'=combat_panel_private.shuriken_profile_v1()->>'id' then
    if not combat_panel_private.shuriken_target_v1(a.id,t) then raise exception 'fuori_portata'; end if;
   elsif multiplication_aim_valid is not null then$patch$);
  IF md5(v_definition) IS DISTINCT FROM '58c4ce8a9e86dbe3510b79e7d465d52e' THEN RAISE EXCEPTION 'shuriken composition drift: sync_declaration'; END IF;
  EXECUTE v_definition;
  SELECT p.oid INTO STRICT v_oid FROM pg_proc p JOIN pg_namespace n ON n.oid=p.pronamespace
    WHERE n.nspname='clan_marionettisti_private' AND p.proname='narrative_attack_allowed';
  v_definition:=pg_get_functiondef(v_oid);
  IF md5(v_definition) IS DISTINCT FROM 'aa56140c771350b7ec50c555eb7572ec' THEN RAISE EXCEPTION 'shuriken baseline drift: narrative_attack_allowed'; END IF;
  v_definition:=replace(v_definition,$patch$d.sanitized_intent#>>'{server_ability,source}'='mano' or exists($patch$,$patch$d.sanitized_intent#>>'{server_ability,source}'='mano'
   OR combat_panel_private.shuriken_resolved_v1(d.id) or exists($patch$);
  IF md5(v_definition) IS DISTINCT FROM '1083a424325b0b73d649d3f4c5a78f07' THEN RAISE EXCEPTION 'shuriken composition drift: narrative_attack_allowed'; END IF;
  EXECUTE v_definition;
  SELECT p.oid INTO STRICT v_oid FROM pg_proc p JOIN pg_namespace n ON n.oid=p.pronamespace
    WHERE n.nspname='combat_consumer_private' AND p.proname='narrative_context';
  v_definition:=pg_get_functiondef(v_oid);
  IF md5(v_definition) IS DISTINCT FROM 'cfd7f20e13ac4140b29aa9cb83086c10' THEN RAISE EXCEPTION 'shuriken baseline drift: narrative_context'; END IF;
  v_definition:=replace(v_definition,$patch$ else 'Colpo a mani nude' end,'natura'$patch$,$patch$ when combat_panel_private.shuriken_resolved_v1(primary_action.id) then 'Lancio di Shuriken'
       else 'Colpo a mani nude' end,'natura'$patch$);
  IF md5(v_definition) IS DISTINCT FROM '19c1c2496089b698e3f0ebb55515e500' THEN RAISE EXCEPTION 'shuriken composition drift: narrative_context'; END IF;
  EXECUTE v_definition;
  SELECT p.oid INTO STRICT v_oid FROM pg_proc p JOIN pg_namespace n ON n.oid=p.pronamespace
    WHERE n.nspname='combat_panel_private' AND p.proname='narrative_ordinary_context';
  v_definition:=pg_get_functiondef(v_oid);
  IF md5(v_definition) IS DISTINCT FROM '87c455679a535df7c54b47e4dd0f7132' THEN RAISE EXCEPTION 'shuriken baseline drift: narrative_ordinary_context'; END IF;
  v_definition:=replace(v_definition,$patch$   ELSE 'Colpo a mani nude' END;$patch$,$patch$   WHEN combat_panel_private.shuriken_resolved_v1(d.id) THEN 'Lancio di Shuriken'
   ELSE 'Colpo a mani nude' END;$patch$);
  IF md5(v_definition) IS DISTINCT FROM '59fdcdc9dd1587ba4c2add3b008e8892' THEN RAISE EXCEPTION 'shuriken composition drift: narrative_ordinary_context'; END IF;
  EXECUTE v_definition;
END
$compose$;
COMMIT;
