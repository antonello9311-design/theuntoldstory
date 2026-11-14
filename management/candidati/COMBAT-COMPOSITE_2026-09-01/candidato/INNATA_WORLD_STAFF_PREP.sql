BEGIN;
DO $pins$
BEGIN
  IF md5(pg_get_functiondef('clan_innata_narrative_private.world_passive_role_v1(uuid,uuid,uuid)'::regprocedure)) IS DISTINCT FROM '201ec7f3cfbc3da0d98defafc844ac17' THEN
    RAISE EXCEPTION 'STAFF_FILI_PASSIVE_BASELINE: clan_innata_narrative_private.world_passive_role_v1';
  END IF;
  IF md5(pg_get_functiondef('clan_innata_narrative_private.world_passive_bind_v1(uuid)'::regprocedure)) IS DISTINCT FROM '9ed6c1f150c2ab4b921a30bb5c93e4cc' THEN
    RAISE EXCEPTION 'STAFF_FILI_PASSIVE_BASELINE: clan_innata_narrative_private.world_passive_bind_v1';
  END IF;
  IF md5(pg_get_functiondef('clan_innata_narrative_private.world_passive_effective_v1(uuid,uuid)'::regprocedure)) IS DISTINCT FROM 'c9ac2ed4f1f418d534f74b7e10f7c050' THEN
    RAISE EXCEPTION 'STAFF_FILI_PASSIVE_BASELINE: clan_innata_narrative_private.world_passive_effective_v1';
  END IF;
  IF md5(pg_get_functiondef('clan_marionettisti_private.declaration_terminal_trigger()'::regprocedure)) IS DISTINCT FROM '73bb01b4c0fb3ef31035f55469acd91d' THEN
    RAISE EXCEPTION 'STAFF_FILI_PASSIVE_BASELINE: clan_marionettisti_private.declaration_terminal_trigger';
  END IF;
  IF md5(pg_get_functiondef('clan_innata_narrative_private.world_passive_acquisitions_v1(uuid)'::regprocedure)) IS DISTINCT FROM '5d29b9e77ff0beb07d6e725ba5116a00' THEN
    RAISE EXCEPTION 'STAFF_FILI_PASSIVE_BASELINE: clan_innata_narrative_private.world_passive_acquisitions_v1';
  END IF;
  IF md5(pg_get_functiondef('combat_panel_private.master_staff_companion_scope(uuid)'::regprocedure)) IS DISTINCT FROM '584a00bfedf0280c6665065f66336cbb' THEN
    RAISE EXCEPTION 'STAFF_FILI_PASSIVE_BASELINE: combat_panel_private.master_staff_companion_scope';
  END IF;
  IF md5(pg_get_functiondef('clan_innata_narrative_private.staff_profile_authorize_v1(uuid,uuid,uuid)'::regprocedure)) IS DISTINCT FROM 'a1dbc557398d38ca8583d2e4372247c4' THEN
    RAISE EXCEPTION 'STAFF_FILI_PASSIVE_BASELINE: clan_innata_narrative_private.staff_profile_authorize_v1';
  END IF;
  IF md5(pg_get_functiondef('combat_panel_private.commit_master_actor(jsonb)'::regprocedure)) IS DISTINCT FROM '69b96309bd743d095af9d6ac8521ea12' THEN
    RAISE EXCEPTION 'STAFF_FILI_PASSIVE_BASELINE: combat_panel_private.commit_master_actor(jsonb)';
  END IF;
  IF md5(pg_get_functiondef('clan_marionettisti_private.is_dedicated_scene(uuid)'::regprocedure)) IS DISTINCT FROM '85c8f044f8383f4587a1d8175d9a0ec9' THEN
    RAISE EXCEPTION 'STAFF_FILI_PASSIVE_BASELINE: clan_marionettisti_private.is_dedicated_scene(uuid)';
  END IF;
  IF md5(pg_get_functiondef('public.combat_v2_action_declare(uuid,uuid,jsonb,text,uuid)'::regprocedure)) IS DISTINCT FROM 'c7d780c56576215e5267da68f75aeee0' THEN
    RAISE EXCEPTION 'STAFF_FILI_PASSIVE_BASELINE: public.combat_v2_action_declare(uuid,uuid,jsonb,text,uuid)';
  END IF;
  IF md5(pg_get_functiondef('clan_marionettisti_private.relink_ready(uuid,uuid)'::regprocedure)) IS DISTINCT FROM 'fe14b411fd83b2b61d1b5449d4aad314' THEN
    RAISE EXCEPTION 'STAFF_FILI_PASSIVE_BASELINE: clan_marionettisti_private.relink_ready(uuid,uuid)';
  END IF;
  IF md5(pg_get_functiondef('combat_panel_private.round_options_authoritative(uuid,uuid)'::regprocedure)) IS DISTINCT FROM '4c7f687dc541b096097f526d59702b02' THEN
    RAISE EXCEPTION 'STAFF_FILI_PASSIVE_BASELINE: combat_panel_private.round_options_authoritative(uuid,uuid)';
  END IF;
  IF md5(pg_get_functiondef('clan_marionettisti_private.relink_options(uuid,uuid)'::regprocedure)) IS DISTINCT FROM 'dbb463b203107eb33c4adb53fd999e85' THEN
    RAISE EXCEPTION 'STAFF_FILI_PASSIVE_BASELINE: clan_marionettisti_private.relink_options(uuid,uuid)';
  END IF;
END $pins$;
CREATE TABLE clan_innata_narrative_private.staff_passive_profiles_v1 (
  profile_id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  location_id uuid NOT NULL REFERENCES public.locations(id),
  character_id uuid NOT NULL REFERENCES public.characters(id),
  controller_user uuid NOT NULL,
  master_session_id uuid REFERENCES public.master_v2_sessions(id),
  family text NOT NULL,
  started_at timestamptz NOT NULL DEFAULT statement_timestamp(),
  expires_at timestamptz NOT NULL DEFAULT statement_timestamp() + interval '20 minutes',
  disabled_at timestamptz,
  CHECK (location_id = '0b85f354-9cdb-47e1-baf9-3d266bb7e06b'::uuid),
  CHECK (family IN ('aburame','akimichi','hoki_dokugan','inuzuka','marionettisti','nara','sabaku')),
  CHECK (expires_at > started_at AND expires_at <= started_at + interval '20 minutes')
);
CREATE UNIQUE INDEX staff_passive_profiles_v1_one
  ON clan_innata_narrative_private.staff_passive_profiles_v1(character_id)
  WHERE disabled_at IS NULL;
ALTER TABLE clan_innata_narrative_private.staff_passive_profiles_v1 ENABLE ROW LEVEL SECURITY;
REVOKE ALL ON clan_innata_narrative_private.staff_passive_profiles_v1 FROM PUBLIC, anon, authenticated, service_role;

CREATE FUNCTION public.innata_staff_passive_profile_v1(p_location uuid, p_master uuid, p_character uuid, p_family text)
RETURNS jsonb LANGUAGE plpgsql SECURITY DEFINER SET search_path TO ''
AS $fn$
DECLARE
  profile clan_innata_narrative_private.staff_passive_profiles_v1;
  technique_count integer;
BEGIN
  PERFORM clan_innata_narrative_private.staff_profile_authorize_v1(p_location,p_master,p_character);
  IF p_character NOT IN ('2a877f02-4993-4e65-9172-7d29f08c5b86'::uuid,'6bceee99-974f-426b-8d92-38b43b4a4267'::uuid)
     OR NOT combat_consumer_private.staff_test_allowed(p_location,ARRAY[auth.uid()],false)
     OR NOT EXISTS (SELECT 1 FROM clan_innata_narrative_private.world_passive_gate_v1 WHERE singleton AND staff_preview)
  THEN RAISE EXCEPTION 'INNATA_STAFF_ONLY' USING ERRCODE='42501'; END IF;

  PERFORM pg_advisory_xact_lock(hashtextextended('innata-narrative:'||p_character::text,0));
  IF EXISTS (
    SELECT 1 FROM public.combat_v2_sessions s JOIN public.combat_v2_actors a ON a.session_id=s.id
    WHERE a.character_id=p_character AND s.closed_at IS NULL
  ) THEN RAISE EXCEPTION 'INNATA_STAFF_PREPARE_BEFORE_COMBAT' USING ERRCODE='55000'; END IF;

  IF p_family IS NOT NULL THEN
    IF p_master IS NOT NULL AND NOT EXISTS (
      SELECT 1 FROM public.master_v2_sessions m
      WHERE m.id=p_master AND m.owner_kind='human' AND m.mission_id IS NULL
        AND m.tipo='duello' AND m.master_user IS NOT NULL AND m.closed_at IS NULL
        AND m.suspended_at IS NULL AND m.stato IN ('preparazione','in_corso')
    ) THEN RAISE EXCEPTION 'INNATA_STAFF_HUMAN_DUEL_ONLY' USING ERRCODE='42501'; END IF;
    IF (SELECT c.staff_ability_profile->>'profile_key' FROM clan_innata_narrative_private.contexts_v1 c
        WHERE c.character_id=p_character AND c.location_id=p_location
        ORDER BY c.created_at DESC,c.context_id DESC LIMIT 1) IS NOT NULL
    THEN RAISE EXCEPTION 'INNATA_STAFF_REMOVE_OTHER_PROFILE' USING ERRCODE='55000'; END IF;
    SELECT count(*) INTO technique_count
    FROM clan_innata_narrative_private.world_passive_catalog_v1 c
    JOIN public.clan_techniques t ON t.id=c.technique_id AND t.is_active
      AND t.level=c.tier AND lower(t.clan)=lower(c.catalog_clan)
    WHERE c.family=p_family;
    IF technique_count=0 THEN RAISE EXCEPTION 'INNATA_STAFF_UNKNOWN_FAMILY' USING ERRCODE='22023'; END IF;
    SELECT * INTO profile FROM clan_innata_narrative_private.staff_passive_profiles_v1 p
    WHERE p.character_id=p_character AND p.controller_user=auth.uid() AND p.family=p_family
      AND p.master_session_id IS NOT DISTINCT FROM p_master AND p.disabled_at IS NULL
      AND p.expires_at>statement_timestamp();
    IF FOUND THEN RETURN jsonb_build_object('family',profile.family,'expires_at',profile.expires_at,'techniques',technique_count); END IF;
  END IF;

  UPDATE clan_innata_narrative_private.staff_passive_profiles_v1 SET disabled_at=statement_timestamp()
    WHERE character_id=p_character AND disabled_at IS NULL;
  IF p_family IS NULL THEN RETURN jsonb_build_object('family',null,'techniques',0); END IF;
  INSERT INTO clan_innata_narrative_private.staff_passive_profiles_v1
    (location_id,character_id,controller_user,master_session_id,family)
    VALUES (p_location,p_character,auth.uid(),p_master,p_family)
    RETURNING * INTO profile;
  RETURN jsonb_build_object('family',profile.family,'expires_at',profile.expires_at,'techniques',technique_count);
END $fn$;
REVOKE ALL ON FUNCTION public.innata_staff_passive_profile_v1(uuid,uuid,uuid,text) FROM PUBLIC, anon, authenticated, service_role;
GRANT EXECUTE ON FUNCTION public.innata_staff_passive_profile_v1(uuid,uuid,uuid,text) TO authenticated;

CREATE FUNCTION clan_innata_narrative_private.world_passive_staff_sources_v1(p_character uuid, p_location uuid, p_master uuid)
RETURNS TABLE(technique_id uuid, family text, tier integer, acquisition_id uuid, started_at timestamptz,
              activated_at timestamptz, is_simulated boolean)
LANGUAGE sql STABLE SECURITY DEFINER SET search_path TO ''
AS $fn$
  WITH selected AS (
    SELECT p.* FROM clan_innata_narrative_private.staff_passive_profiles_v1 p
    JOIN public.characters ch ON ch.id=p.character_id AND ch.user_id=p.controller_user
    JOIN clan_innata_narrative_private.world_passive_gate_v1 g ON g.singleton AND g.staff_preview
    WHERE p_location='0b85f354-9cdb-47e1-baf9-3d266bb7e06b'::uuid
      AND p.character_id=p_character AND p.location_id=p_location
      AND p.master_session_id IS NOT DISTINCT FROM p_master
      AND p.disabled_at IS NULL AND p.expires_at>statement_timestamp()
      AND combat_consumer_private.staff_test_allowed(p_location,ARRAY[p.controller_user],false)
  )
  SELECT a.*, false
  FROM clan_innata_narrative_private.world_passive_acquisitions_v1(p_character) a
  WHERE NOT EXISTS (SELECT 1 FROM selected)
  UNION ALL
  SELECT c.technique_id,c.family,c.tier,p.profile_id,p.started_at,p.started_at,true
  FROM selected p
  JOIN clan_innata_narrative_private.world_passive_catalog_v1 c ON c.family=p.family
  JOIN public.clan_techniques t ON t.id=c.technique_id AND t.is_active
    AND t.level=c.tier AND lower(t.clan)=lower(c.catalog_clan);
$fn$;
REVOKE ALL ON FUNCTION clan_innata_narrative_private.world_passive_staff_sources_v1(uuid,uuid,uuid) FROM PUBLIC, anon, authenticated, service_role;

CREATE TABLE clan_marionettisti_private.staff_sever_permits_v1 (
  round_id uuid PRIMARY KEY REFERENCES public.combat_v2_rounds(id),
  attacker_id uuid NOT NULL REFERENCES public.combat_v2_actors(id),
  target_id uuid NOT NULL REFERENCES public.combat_v2_actors(id),
  controller_user uuid NOT NULL,
  armed_at timestamptz NOT NULL DEFAULT statement_timestamp(),
  declaration_id uuid REFERENCES public.combat_v2_declarations(id),
  CHECK (attacker_id <> target_id)
);
ALTER TABLE clan_marionettisti_private.staff_sever_permits_v1 ENABLE ROW LEVEL SECURITY;
REVOKE ALL ON clan_marionettisti_private.staff_sever_permits_v1 FROM PUBLIC, anon, authenticated, service_role;

CREATE FUNCTION clan_marionettisti_private.staff_sever_scope_v1(p_round uuid, p_actor uuid, p_target uuid)
RETURNS boolean LANGUAGE sql STABLE SECURITY DEFINER SET search_path TO ''
AS $fn$
  SELECT EXISTS (
    SELECT 1 FROM public.combat_v2_rounds r
    JOIN public.combat_v2_sessions s ON s.id=r.session_id AND s.closed_at IS NULL AND s.state='in_corso'
    JOIN public.master_v2_sessions m ON m.id=s.master_session_id AND m.closed_at IS NULL
      AND m.location_id=s.location_id AND m.owner_kind='human' AND m.master_user IS NOT NULL
      AND m.mission_id IS NULL AND m.tipo='duello' AND m.suspended_at IS NULL
    JOIN public.combat_v2_actors a ON a.id=p_actor AND a.session_id=s.id AND a.state='attivo'
      AND a.actor_kind='pg' AND a.companion_id IS NULL
    JOIN public.characters ac ON ac.id=a.character_id AND ac.user_id=a.controller_user
    JOIN public.combat_v2_actors t ON t.id=p_target AND t.session_id=s.id AND t.state='attivo'
      AND t.team_key<>a.team_key AND t.companion_id IS NOT NULL
    JOIN clan_marionettisti_private.links l ON l.companion_actor_id=t.id AND l.is_simulated AND l.state='connected'
    JOIN public.combat_v2_actors owner ON owner.id=l.owner_actor_id AND owner.session_id=s.id
      AND owner.controller_user=t.controller_user AND owner.team_key=t.team_key AND owner.state='attivo'
      AND owner.actor_kind='pg' AND owner.companion_id IS NULL
    WHERE r.id=p_round AND r.phase='raccolta_azioni'
      AND s.location_id='0b85f354-9cdb-47e1-baf9-3d266bb7e06b'::uuid
      AND s.source_kind='master' AND public.combat_v2_values_written(s.id) IS FALSE
      AND a.character_id IN ('2a877f02-4993-4e65-9172-7d29f08c5b86'::uuid,'6bceee99-974f-426b-8d92-38b43b4a4267'::uuid)
      AND owner.character_id IN ('2a877f02-4993-4e65-9172-7d29f08c5b86'::uuid,'6bceee99-974f-426b-8d92-38b43b4a4267'::uuid)
      AND combat_panel_private.master_staff_companion_scope(s.id)
      AND clan_marionettisti_private.is_dedicated_scene(s.id)
      AND NOT EXISTS (SELECT 1 FROM exam_regia_private.bindings b WHERE b.combat_session_id=s.id)
      AND NOT EXISTS (SELECT 1 FROM exam_human_private.native_bindings b WHERE b.master_session_id=m.id)
  );
$fn$;
REVOKE ALL ON FUNCTION clan_marionettisti_private.staff_sever_scope_v1(uuid,uuid,uuid) FROM PUBLIC, anon, authenticated, service_role;

CREATE FUNCTION public.marionetta_staff_sever_arm_v1(p_location uuid, p_master uuid, p_character uuid)
RETURNS jsonb LANGUAGE plpgsql SECURITY DEFINER SET search_path TO ''
AS $fn$
DECLARE
  v_encounter_id uuid;
  v_round_id uuid;
  v_attacker_id uuid;
  v_target_id uuid;
  matched integer;
  permit clan_marionettisti_private.staff_sever_permits_v1;
BEGIN
  PERFORM clan_innata_narrative_private.staff_profile_authorize_v1(p_location,p_master,p_character);
  IF p_master IS NULL THEN RAISE EXCEPTION 'MARIONETTA_STAFF_OPEN_DUEL' USING ERRCODE='55000'; END IF;

  SELECT s.id INTO STRICT v_encounter_id FROM public.combat_v2_sessions s
    WHERE s.master_session_id=p_master AND s.location_id=p_location
      AND s.source_kind='master' AND s.closed_at IS NULL AND s.state='in_corso';
  SELECT r.id INTO STRICT v_round_id FROM public.combat_v2_rounds r
    WHERE r.session_id=v_encounter_id AND r.phase='raccolta_azioni'
    ORDER BY r.round_no DESC LIMIT 1 FOR UPDATE;
  SELECT a.id INTO STRICT v_attacker_id FROM public.combat_v2_actors a
    WHERE a.session_id=v_encounter_id AND a.character_id=p_character AND a.controller_user=auth.uid()
      AND a.actor_kind='pg' AND a.companion_id IS NULL;

  SELECT count(*),(array_agg(l.companion_actor_id))[1] INTO matched,v_target_id
    FROM clan_marionettisti_private.links l
    JOIN public.combat_v2_actors t ON t.id=l.companion_actor_id AND t.session_id=v_encounter_id
    WHERE clan_marionettisti_private.staff_sever_scope_v1(v_round_id,v_attacker_id,t.id);
  IF matched<>1 THEN RAISE EXCEPTION 'MARIONETTA_STAFF_CONNECTED_TARGET_REQUIRED' USING ERRCODE='55000'; END IF;
  IF EXISTS (SELECT 1 FROM public.combat_v2_declarations d
     WHERE d.round_id=v_round_id AND d.actor_id=v_attacker_id AND d.kind='attacco')
  THEN RAISE EXCEPTION 'MARIONETTA_STAFF_ARM_BEFORE_ATTACK' USING ERRCODE='55000'; END IF;

  INSERT INTO clan_marionettisti_private.staff_sever_permits_v1 (round_id,attacker_id,target_id,controller_user)
    VALUES (v_round_id,v_attacker_id,v_target_id,auth.uid()) ON CONFLICT ON CONSTRAINT staff_sever_permits_v1_pkey DO NOTHING;
  SELECT * INTO STRICT permit FROM clan_marionettisti_private.staff_sever_permits_v1 p WHERE p.round_id=v_round_id;
  IF permit.attacker_id<>v_attacker_id OR permit.target_id<>v_target_id OR permit.controller_user<>auth.uid()
    OR permit.declaration_id IS NOT NULL
  THEN RAISE EXCEPTION 'MARIONETTA_STAFF_PERMIT_ALREADY_USED' USING ERRCODE='55000'; END IF;
  RETURN jsonb_build_object('round_id',permit.round_id,'target_actor_id',permit.target_id,'armed',true);
EXCEPTION WHEN no_data_found OR too_many_rows THEN
  RAISE EXCEPTION 'MARIONETTA_STAFF_OPEN_DUEL' USING ERRCODE='55000';
END $fn$;
REVOKE ALL ON FUNCTION public.marionetta_staff_sever_arm_v1(uuid,uuid,uuid) FROM PUBLIC, anon, authenticated, service_role;
GRANT EXECUTE ON FUNCTION public.marionetta_staff_sever_arm_v1(uuid,uuid,uuid) TO authenticated;

CREATE FUNCTION clan_marionettisti_private.staff_sever_declaration_v1()
RETURNS trigger LANGUAGE plpgsql SECURITY DEFINER SET search_path TO ''
AS $fn$
DECLARE
  permit clan_marionettisti_private.staff_sever_permits_v1;
BEGIN
  IF new.kind IS DISTINCT FROM 'attacco' OR new.target_actor_id IS NULL OR auth.uid() IS NULL
    OR new.sanitized_intent#>>'{server_ability,source}' IS DISTINCT FROM 'mano'
    OR (new.sanitized_intent ? 'target_actor_ids'
      AND new.sanitized_intent->'target_actor_ids' IS DISTINCT FROM jsonb_build_array(new.target_actor_id))
  THEN RETURN new; END IF;
  SELECT * INTO permit FROM clan_marionettisti_private.staff_sever_permits_v1 p
    WHERE p.round_id=new.round_id AND p.attacker_id=new.actor_id AND p.target_id=new.target_actor_id
      AND p.controller_user=auth.uid() AND p.controller_user=new.controller_user_snapshot
      AND p.declaration_id IS NULL FOR UPDATE;
  IF NOT FOUND OR NOT clan_marionettisti_private.staff_sever_scope_v1(new.round_id,new.actor_id,new.target_actor_id)
  THEN RETURN new; END IF;

  new.sanitized_intent:=jsonb_set(new.sanitized_intent,'{server_ability,link_control_traits}',
    jsonb_build_object('perceives_chakra_links',true,'severs_chakra_links',true,'staff_simulated',true));
  RETURN new;
END $fn$;
REVOKE ALL ON FUNCTION clan_marionettisti_private.staff_sever_declaration_v1() FROM PUBLIC, anon, authenticated, service_role;

CREATE FUNCTION clan_marionettisti_private.staff_sever_capture_v1()
RETURNS trigger LANGUAGE plpgsql SECURITY DEFINER SET search_path TO ''
AS $fn$
BEGIN
  UPDATE clan_marionettisti_private.staff_sever_permits_v1 p SET declaration_id=new.id
    WHERE p.round_id=new.round_id AND p.attacker_id=new.actor_id AND p.target_id=new.target_actor_id
      AND p.controller_user=new.controller_user_snapshot AND p.declaration_id IS NULL;
  RETURN new;
END $fn$;
REVOKE ALL ON FUNCTION clan_marionettisti_private.staff_sever_capture_v1() FROM PUBLIC, anon, authenticated, service_role;

CREATE TRIGGER zz_marionetta_staff_sever BEFORE INSERT ON public.combat_v2_declarations
FOR EACH ROW WHEN (NEW.kind='attacco') EXECUTE FUNCTION clan_marionettisti_private.staff_sever_declaration_v1();
CREATE TRIGGER zz_marionetta_staff_sever_capture AFTER INSERT ON public.combat_v2_declarations
FOR EACH ROW WHEN (NEW.sanitized_intent#>>'{server_ability,link_control_traits,staff_simulated}'='true')
EXECUTE FUNCTION clan_marionettisti_private.staff_sever_capture_v1();

CREATE OR REPLACE FUNCTION clan_innata_narrative_private.world_passive_role_v1(p_message uuid, p_character uuid, p_location uuid)
 RETURNS void
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO ''
AS $function$
declare
  actor public.characters;
  accepted public.messages;
  place public.locations;
  gate clan_innata_narrative_private.world_passive_gate_v1;
  master_id uuid;
  master_count integer;
  acquisition record;
  fact jsonb;
begin
  if auth.uid() is null then return; end if;
  select * into place from public.locations where id=p_location and is_active;
  if not found then return; end if;
  select * into gate from clan_innata_narrative_private.world_passive_gate_v1 where singleton;
  if not found then return; end if;
  if place.is_test then
    if not gate.staff_preview or place.id<>'0b85f354-9cdb-47e1-baf9-3d266bb7e06b'::uuid
       or public._puo_test_room() is distinct from true
       or combat_consumer_private.staff_test_allowed(place.id,array[auth.uid()],false) is distinct from true
       or (select c.staff_ability_profile->>'profile_key' from clan_innata_narrative_private.contexts_v1 c
           where c.character_id=p_character and c.location_id=place.id
           order by c.created_at desc,c.context_id desc limit 1) is not null
    then return; end if;
  elsif place.is_exam_room is distinct from false or not gate.public_enabled then return;
  end if;

  select * into actor from public.characters where id=p_character and user_id=auth.uid();
  if not found then return; end if;
  select * into accepted from public.messages
  where id=p_message and character_id=actor.id and (sender_user is null or sender_user=actor.user_id)
    and location_id=place.id and kind='say' and recipient_user is null;
  -- Some guided or automated paths can write messages; use the normal
  -- accepted-role RPC, never a guided combat declaration as provenance.
  if not found or coalesce(current_setting('app.combat_guidata',true),'')='1' then return; end if;

  perform pg_advisory_xact_lock(hashtextextended('innata-narrative:'||actor.id::text,0));
  if exists (
    select 1 from public.combat_v2_actors ca
    join public.combat_v2_sessions cs on cs.id=ca.session_id and cs.closed_at is null
    where ca.character_id=actor.id
  ) then return; end if;
  -- A guided IA submission must never fall back to an ordinary role.
  if exists(select 1 from mission_generic_owner.role_submissions where message_id=accepted.id)
  then return; end if;

  select count(*),(array_agg(ms.id order by ms.id))[1] into master_count,master_id
  from public.master_v2_sessions ms join public.master_v2_participants mp on mp.session_id=ms.id
  where ms.location_id=place.id and ms.closed_at is null and mp.character_id=actor.id
    and mp.left_at is null and mp.engagement_state='attivo';
  if master_count>1 then return; end if;
  if master_id is null then
    if public._personaggio_impegnato_meccanicamente(actor.id) is distinct from false then return; end if;
  elsif not exists (
    select 1 from public.master_v2_sessions ms join public.master_v2_participants mp on mp.session_id=ms.id
    where ms.id=master_id and ms.owner_kind='human' and ms.mission_id is null
      and ms.tipo='duello' and ms.master_user is not null
      and ms.closed_at is null and ms.suspended_at is null and ms.stato in ('preparazione','in_corso')
      and mp.character_id=actor.id and mp.user_id_snapshot=actor.user_id
      and mp.joined_at<=accepted.created_at and mp.left_at is null and mp.engagement_state='attivo'
  ) then return; end if;

  insert into clan_innata_narrative_private.world_passive_messages_v1
    (message_id,character_id,controller_user,location_id,master_session_id,accepted_at,staff_preview,gate_version)
  values (accepted.id,actor.id,actor.user_id,place.id,master_id,accepted.created_at,place.is_test,gate.control_version)
  on conflict (message_id) do nothing;
  if not found or accepted.companion_id is not null then return; end if;

  for acquisition in
    select * from clan_innata_narrative_private.world_passive_staff_sources_v1(actor.id,place.id,master_id) a
    where (a.started_at is null or a.started_at<=accepted.created_at)
      and (a.activated_at is null or a.activated_at<=accepted.created_at)
    order by technique_id
  loop
    fact:=jsonb_build_object(
      'schema_version','innata-world-passive-fact/1','message_id',accepted.id,
      'accepted_at',accepted.created_at,'character_id',actor.id,
      'location_id',place.id,'master_session_id',master_id,
      'technique_id',acquisition.technique_id,'family',acquisition.family,'tier',acquisition.tier,
      'acquisition_id',acquisition.acquisition_id,'started_at',acquisition.started_at,
      'activated_at',acquisition.activated_at,'staff_preview',place.is_test,'gate_version',gate.control_version,
      'eligible',true,'capabilities_granted',false,'resource_usage_authorized',false,'values_written',false);
    IF acquisition.is_simulated THEN
      fact:=fact||jsonb_build_object('staff_temporary_passive_profile',true);
    END IF;
    insert into clan_innata_narrative_private.world_passive_roles_v1
      (message_id,technique_id,character_id,controller_user,location_id,master_session_id,
       accepted_at,acquisition_id,acquisition_started_at,acquisition_activated_at,staff_preview,
       gate_version,fact,fact_sha256)
    values (accepted.id,acquisition.technique_id,actor.id,actor.user_id,place.id,master_id,
      accepted.created_at,acquisition.acquisition_id,acquisition.started_at,acquisition.activated_at,
      place.is_test,gate.control_version,fact,public.combat_v2_sha256(fact))
    on conflict (message_id,technique_id) do nothing;
  end loop;
end;
$function$
;
CREATE OR REPLACE FUNCTION clan_innata_narrative_private.world_passive_bind_v1(p_session uuid)
 RETURNS void
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO ''
AS $function$
declare
  scene public.combat_v2_sessions;
  place public.locations;
  gate clan_innata_narrative_private.world_passive_gate_v1;
  actor public.combat_v2_actors;
  prior_close timestamptz;
  latest_role uuid;
  principals uuid[];
  policy text;
  refs jsonb;
begin
  select * into scene from public.combat_v2_sessions where id=p_session and closed_at is null and state='in_corso';
  if not found then return; end if;
  select * into place from public.locations where id=scene.location_id and is_active;
  if not found then return; end if;
  select * into gate from clan_innata_narrative_private.world_passive_gate_v1 where singleton;
  if not found then return; end if;
  if place.is_test then
    if not gate.staff_preview or place.id<>'0b85f354-9cdb-47e1-baf9-3d266bb7e06b'::uuid
       or public.combat_v2_values_written(scene.id) is distinct from false
    then return; end if;
  elsif place.is_exam_room is distinct from false or not gate.public_enabled
     or public.combat_v2_values_written(scene.id) is distinct from true then return;
  end if;
  if scene.source_kind='ordinary' and scene.master_session_id is null then
    select a.policy_id into policy from combat_consumer_private.activities a
      where a.session_id=scene.id and a.location_id=place.id;
  elsif scene.source_kind='master' and exists (
    select 1 from public.master_v2_sessions ms
    where ms.id=scene.master_session_id and ms.location_id=place.id and ms.closed_at is null
      and ms.suspended_at is null and ms.owner_kind='human' and ms.master_user is not null
      and ms.mission_id is null and ms.tipo='duello' and ms.stato in ('preparazione','in_corso')
  ) then
    select m.policy_id into policy from combat_panel_private.master_panel_sessions m
      where m.master_session_id=scene.master_session_id and m.location_id=place.id;
  else return;
  end if;

  if place.is_test then
    select array_agg(distinct a.controller_user) into principals from public.combat_v2_actors a
    where a.session_id=scene.id and a.actor_kind='pg' and a.companion_id is null;
    if policy is distinct from 'staff_test_no_persistent_resources_v1'
       or combat_consumer_private.staff_test_allowed(place.id,principals,false) is distinct from true
    then return; end if;
  elsif policy is distinct from (case when scene.source_kind='ordinary'
    then 'free_duel_nonlethal_real_resources_v1' else 'master_game_resources_v1' end) then return;
  end if;

  for actor in
    select a.* from public.combat_v2_actors a
    join public.characters c on c.id=a.character_id and c.user_id=a.controller_user
    where a.session_id=scene.id and a.actor_kind='pg' and a.companion_id is null and a.state='attivo'
    order by a.character_id,a.id
  loop
    perform pg_advisory_xact_lock(hashtextextended('innata-narrative:'||actor.character_id::text,0));
    if scene.master_session_id is not null and not exists (
      select 1 from public.master_v2_participants mp
      where mp.session_id=scene.master_session_id and mp.character_id=actor.character_id
        and mp.user_id_snapshot=actor.controller_user and mp.left_at is null and mp.engagement_state='attivo'
    ) then continue; end if;
    if place.is_test and (
      select c.staff_ability_profile->>'profile_key' from clan_innata_narrative_private.contexts_v1 c
      where c.character_id=actor.character_id and c.location_id=place.id
      order by c.created_at desc,c.context_id desc limit 1
    ) is not null then continue; end if;

    select max(s.closed_at) into prior_close
    from public.combat_v2_sessions s join public.combat_v2_actors a on a.session_id=s.id
    where s.id<>scene.id and s.location_id=place.id and s.closed_at<=scene.created_at
      and a.character_id=actor.character_id and a.actor_kind='pg';

    -- Only the latest accepted role can contribute a fact. A role with no
    -- eligibility receipt must not silently fall back to an older receipt.
    select receipt.message_id into latest_role
    from clan_innata_narrative_private.world_passive_messages_v1 receipt
    where receipt.character_id=actor.character_id and receipt.controller_user=actor.controller_user
      and receipt.location_id=place.id and receipt.staff_preview=place.is_test
      and receipt.gate_version=gate.control_version
      and receipt.accepted_at<=scene.created_at and (prior_close is null or receipt.accepted_at>prior_close)
      and receipt.accepted_at>=scene.created_at-interval '24 hours'
    order by receipt.accepted_at desc,receipt.message_id desc limit 1;
    if latest_role is null then continue; end if;

    insert into clan_innata_narrative_private.world_passive_combat_v1
      (session_id,actor_id,technique_id,message_id,fact,fact_sha256,gate_version)
    select scene.id,actor.id,r.technique_id,r.message_id,r.fact,r.fact_sha256,gate.control_version
    from clan_innata_narrative_private.world_passive_roles_v1 r
    join clan_innata_narrative_private.world_passive_staff_sources_v1(actor.character_id,place.id,scene.master_session_id) owned
      on owned.technique_id=r.technique_id and owned.acquisition_id=r.acquisition_id
      and owned.started_at is not distinct from r.acquisition_started_at
      and owned.activated_at is not distinct from r.acquisition_activated_at
      and owned.is_simulated is not distinct from coalesce(r.fact->>'staff_temporary_passive_profile'='true',false)
    where r.message_id=latest_role and r.character_id=actor.character_id
      and r.controller_user=actor.controller_user and r.location_id=place.id
      and r.master_session_id is not distinct from scene.master_session_id
      and r.staff_preview=place.is_test and r.gate_version=gate.control_version
      and r.fact_sha256=public.combat_v2_sha256(r.fact)
      and exists (
        select 1 from public.messages m
        where m.id=r.message_id and m.created_at=r.accepted_at and m.character_id=r.character_id
          and m.location_id=r.location_id and (m.sender_user is null or m.sender_user=r.controller_user)
          and m.kind='say' and m.recipient_user is null and m.companion_id is null
      )
      and (scene.master_session_id is not null or not exists (
        select 1 from public.role_sessions rec
        where rec.location_id=place.id and rec.closed_at is not null
          and r.accepted_at>=coalesce(rec.record_from,rec.started_at)
          and r.accepted_at<=rec.closed_at and rec.closed_at<=scene.created_at
      ))
      and (scene.master_session_id is null or exists (
        select 1 from public.master_v2_participants mp where mp.session_id=scene.master_session_id
          and mp.character_id=actor.character_id and mp.user_id_snapshot=actor.controller_user
          and mp.joined_at<=r.accepted_at and mp.left_at is null and mp.engagement_state='attivo'
      ))
    on conflict do nothing;
    -- The actor snapshot references only bound technique ids. Acquisition ids
    -- and role provenance stay private; no effect/ability is added to offers.
    refs:=clan_innata_narrative_private.world_passive_effective_v1(scene.id,actor.id);
    if refs is not null then
      update public.combat_v2_actors
      set mechanics_snapshot=jsonb_set(mechanics_snapshot,'{innata_world_passives_bound_at_open_v1}',refs,true)
      where id=actor.id and session_id=scene.id
        and mechanics_snapshot->'innata_world_passives_bound_at_open_v1' is distinct from refs;
    end if;
  end loop;
end;
$function$
;
CREATE OR REPLACE FUNCTION clan_innata_narrative_private.world_passive_effective_v1(p_session uuid, p_actor uuid)
 RETURNS jsonb
 LANGUAGE sql
 STABLE SECURITY DEFINER
 SET search_path TO ''
AS $function$
  select jsonb_agg(b.technique_id order by b.technique_id)
  from clan_innata_narrative_private.world_passive_combat_v1 b
  join public.combat_v2_actors a on a.id=b.actor_id and a.session_id=b.session_id
    and a.actor_kind='pg' and a.companion_id is null and a.state='attivo'
  join public.combat_v2_sessions s on s.id=b.session_id and s.closed_at is null and s.state='in_corso'
  join public.locations l on l.id=s.location_id and l.is_active
  join clan_innata_narrative_private.world_passive_gate_v1 g on g.singleton and g.control_version=b.gate_version
  join clan_innata_narrative_private.world_passive_roles_v1 r
    on r.message_id=b.message_id and r.technique_id=b.technique_id and r.gate_version=b.gate_version
    and r.character_id=a.character_id and r.controller_user=a.controller_user and r.location_id=l.id
    and r.master_session_id is not distinct from s.master_session_id and r.staff_preview=l.is_test
    and r.fact_sha256=b.fact_sha256 and r.fact=b.fact
  join public.characters c on c.id=a.character_id and c.user_id=a.controller_user
  join public.messages msg on msg.id=r.message_id and msg.created_at=r.accepted_at
    and msg.character_id=r.character_id and msg.location_id=r.location_id
    and (msg.sender_user is null or msg.sender_user=r.controller_user)
    and msg.kind='say' and msg.recipient_user is null and msg.companion_id is null
  left join combat_consumer_private.activities ordinary on ordinary.session_id=s.id
    and ordinary.location_id=l.id
  left join combat_panel_private.master_panel_sessions panel on panel.master_session_id=s.master_session_id
    and panel.location_id=l.id
  join lateral clan_innata_narrative_private.world_passive_staff_sources_v1(a.character_id,l.id,s.master_session_id) owned
    on owned.technique_id=b.technique_id and owned.acquisition_id=r.acquisition_id
    and owned.started_at is not distinct from r.acquisition_started_at
    and owned.activated_at is not distinct from r.acquisition_activated_at
    and owned.is_simulated is not distinct from coalesce(r.fact->>'staff_temporary_passive_profile'='true',false)
  where b.session_id=p_session and b.actor_id=p_actor and b.fact_sha256=public.combat_v2_sha256(b.fact)
    and (s.source_kind='ordinary' and s.master_session_id is null and ordinary.session_id is not null
      or s.source_kind='master' and panel.master_session_id is not null and exists (
        select 1 from public.master_v2_sessions m join public.master_v2_participants mp on mp.session_id=m.id
        where m.id=s.master_session_id and m.location_id=l.id and m.closed_at is null
          and m.suspended_at is null and m.owner_kind='human' and m.tipo='duello' and m.mission_id is null
          and m.master_user is not null and m.stato in ('preparazione','in_corso')
          and mp.character_id=a.character_id and mp.user_id_snapshot=a.controller_user
          and mp.joined_at<=r.accepted_at and mp.left_at is null and mp.engagement_state='attivo'
      ))
    and case when l.is_test then
      g.staff_preview and l.id='0b85f354-9cdb-47e1-baf9-3d266bb7e06b'::uuid
      and coalesce(ordinary.policy_id,panel.policy_id)='staff_test_no_persistent_resources_v1'
      and public.combat_v2_values_written(s.id) is false
      and combat_consumer_private.staff_test_allowed(l.id,array(
        select distinct pg.controller_user from public.combat_v2_actors pg
        where pg.session_id=s.id and pg.actor_kind='pg' and pg.companion_id is null
      ),false)
    else g.public_enabled and l.is_exam_room is false and public.combat_v2_values_written(s.id) is true
      and coalesce(ordinary.policy_id,panel.policy_id)=
        case when s.source_kind='ordinary' then 'free_duel_nonlethal_real_resources_v1' else 'master_game_resources_v1' end
    end
$function$
;
COMMIT;
