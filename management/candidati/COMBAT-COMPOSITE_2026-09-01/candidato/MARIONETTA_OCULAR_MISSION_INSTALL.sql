-- Marionetta del PNG e recisione nei fatti della Regia IA.
-- Disponibilità iniziale della sola fonte riservata in Staff. Nessun run o Fato avviato da questa migrazione.
BEGIN;
SET LOCAL lock_timeout = '3s';
SET LOCAL statement_timeout = '65s';

DO $baseline$
BEGIN
  PERFORM clan_innata_private.eligibility_release_assert();
  IF EXISTS (SELECT 1 FROM public.combat_v2_sessions WHERE closed_at IS NULL)
     OR EXISTS (SELECT 1 FROM public.master_v2_sessions WHERE closed_at IS NULL) THEN
    RAISE EXCEPTION 'Sessione di gioco attiva' USING ERRCODE='55000';
  END IF;
  IF NOT EXISTS (
    SELECT 1 FROM clan_marionettisti_private.ocular_sever_gate_v1 gate
    WHERE gate.singleton AND gate.staff_enabled AND gate.public_enabled AND gate.ordinary_enabled
  ) THEN
    RAISE EXCEPTION 'Baseline recisione diversa' USING ERRCODE='40001';
  END IF;
  IF (SELECT md5(pg_get_functiondef(p.oid)) FROM pg_proc p WHERE p.oid=to_regprocedure('mission_generic_owner.progress_step(uuid,uuid,uuid)')) IS DISTINCT FROM '5979e49f1ac1d3f69ba39d1bdfa98627' THEN
    RAISE EXCEPTION 'Baseline diversa: mission_generic_owner.progress_step(uuid,uuid,uuid)' USING ERRCODE='40001';
  END IF;
  IF (SELECT md5(pg_get_functiondef(p.oid)) FROM pg_proc p WHERE p.oid=to_regprocedure('mission_generic_owner.unified_advance(uuid,uuid,uuid)')) IS DISTINCT FROM 'b9e793aacb1d4ea9862e9c32f9ea786f' THEN
    RAISE EXCEPTION 'Baseline diversa: mission_generic_owner.unified_advance(uuid,uuid,uuid)' USING ERRCODE='40001';
  END IF;
  IF (SELECT md5(pg_get_functiondef(p.oid)) FROM pg_proc p WHERE p.oid=to_regprocedure('mission_generic_owner.unified_assert_command(uuid,text)')) IS DISTINCT FROM 'ad2d106a090fe7d143c80e62af095950' THEN
    RAISE EXCEPTION 'Baseline diversa: mission_generic_owner.unified_assert_command(uuid,text)' USING ERRCODE='40001';
  END IF;
  IF (SELECT md5(pg_get_functiondef(p.oid)) FROM pg_proc p WHERE p.oid=to_regprocedure('combat_panel_private.master_companion_actor_visible(uuid,uuid,uuid)')) IS DISTINCT FROM '3fd1a4b26b1b1f3b3bcda920cf8e40a5' THEN
    RAISE EXCEPTION 'Baseline diversa: combat_panel_private.master_companion_actor_visible(uuid,uuid,uuid)' USING ERRCODE='40001';
  END IF;
  IF (SELECT md5(pg_get_functiondef(p.oid)) FROM pg_proc p WHERE p.oid=to_regprocedure('clan_marionettisti_private.ocular_sever_source_v1(uuid,uuid,uuid,numeric)')) IS DISTINCT FROM '60709ae48b6cbbb4d520ded79ed9a336' THEN
    RAISE EXCEPTION 'Baseline diversa: clan_marionettisti_private.ocular_sever_source_v1(uuid,uuid,uuid,numeric)' USING ERRCODE='40001';
  END IF;
  IF (SELECT md5(pg_get_functiondef(p.oid)) FROM pg_proc p WHERE p.oid=to_regprocedure('mission_generic_owner.combat_narrative_source(uuid,uuid)')) IS DISTINCT FROM '5986897f6f491a42ee1f6ecef2d0988e' THEN
    RAISE EXCEPTION 'Baseline diversa: mission_generic_owner.combat_narrative_source(uuid,uuid)' USING ERRCODE='40001';
  END IF;
  IF (SELECT md5(pg_get_functiondef(p.oid)) FROM pg_proc p WHERE p.oid=to_regprocedure('mission_generic_owner.current_principal()')) IS DISTINCT FROM '8ce5d45739d39c26e16026b768a5ea35' THEN
    RAISE EXCEPTION 'Baseline diversa: mission_generic_owner.current_principal()' USING ERRCODE='40001';
  END IF;
  IF (SELECT md5(p.prosrc) FROM pg_proc p WHERE p.oid=to_regprocedure('public.combat_v2_defense_declare(uuid,uuid,uuid,jsonb,text,uuid)')) IS DISTINCT FROM '76704c9c9e1131a1df75f8f368d31261' THEN
    RAISE EXCEPTION 'Baseline diversa: public.combat_v2_defense_declare(uuid,uuid,uuid,jsonb,text,uuid)' USING ERRCODE='40001';
  END IF;
  IF (SELECT md5(pg_get_functiondef(p.oid)) FROM pg_proc p WHERE p.oid=to_regprocedure('public.mission_human_staff_source_create_v1(uuid,jsonb,uuid)')) IS DISTINCT FROM '0a55e640f29e34221aa5cf26d64a5c84' THEN
    RAISE EXCEPTION 'Baseline diversa: public.mission_human_staff_source_create_v1(uuid,jsonb,uuid)' USING ERRCODE='40001';
  END IF;
  IF (SELECT md5(pg_get_functiondef(p.oid)) FROM pg_proc p WHERE p.oid=to_regprocedure('public.mission_generic_staff_test_start_v1(uuid,uuid,uuid[],uuid)')) IS DISTINCT FROM 'e4e35c865abe20aa2556767a77c27d6c' THEN
    RAISE EXCEPTION 'Baseline diversa: public.mission_generic_staff_test_start_v1(uuid,uuid,uuid[],uuid)' USING ERRCODE='40001';
  END IF;
END;
$baseline$;

DO $pinned_actor_baseline$
BEGIN
  IF md5(pg_get_functiondef('clan_marionettisti_private.assert_source(uuid)'::regprocedure)) IS DISTINCT FROM 'd0e923a7342bec18ed1f79c1feef2a47' THEN
    RAISE EXCEPTION 'Stale baseline: clan_marionettisti_private.assert_source(uuid)' USING ERRCODE='40001';
  END IF;
  IF md5(pg_get_functiondef('clan_marionettisti_private.assert_companion_actor(uuid,boolean)'::regprocedure)) IS DISTINCT FROM 'fccdb70452af3cec1fd7fcf92226fd17' THEN
    RAISE EXCEPTION 'Stale baseline: clan_marionettisti_private.assert_companion_actor(uuid,boolean)' USING ERRCODE='40001';
  END IF;
  IF md5(pg_get_functiondef('clan_marionettisti_private.owner_eligible(uuid,boolean)'::regprocedure)) IS DISTINCT FROM '11113bf666d33d673881e95d01790d3e' THEN
    RAISE EXCEPTION 'Stale baseline: clan_marionettisti_private.owner_eligible(uuid,boolean)' USING ERRCODE='40001';
  END IF;
  IF md5(pg_get_functiondef('clan_marionettisti_private.apply_resolved_damage(uuid,uuid,bigint,integer)'::regprocedure)) IS DISTINCT FROM '8d0dcd64bfad86b19fef201496e7de67' THEN
    RAISE EXCEPTION 'Stale baseline: clan_marionettisti_private.apply_resolved_damage(uuid,uuid,bigint,integer)' USING ERRCODE='40001';
  END IF;
  IF md5(pg_get_functiondef('clan_marionettisti_private.settle_round_damage(uuid)'::regprocedure)) IS DISTINCT FROM '01faf30ab475d00f14abf110046c25cb' THEN
    RAISE EXCEPTION 'Stale baseline: clan_marionettisti_private.settle_round_damage(uuid)' USING ERRCODE='40001';
  END IF;
  IF md5(pg_get_functiondef('combat_panel_private.master_companion_roster_valid(uuid)'::regprocedure)) IS DISTINCT FROM '92387dbd38c74f862712ebf416b1485a' THEN
    RAISE EXCEPTION 'Stale baseline: combat_panel_private.master_companion_roster_valid(uuid)' USING ERRCODE='40001';
  END IF;
  IF md5(pg_get_functiondef('mission_generic_owner.assert_native_actor(public.combat_v2_actors)'::regprocedure)) IS DISTINCT FROM 'd2544212e91721f8fdbe98f4e01e8d46' THEN
    RAISE EXCEPTION 'Stale baseline: mission_generic_owner.assert_native_actor(combat_v2_actors)' USING ERRCODE='40001';
  END IF;
  IF md5(pg_get_functiondef('mission_generic_owner.actor_principal(uuid)'::regprocedure)) IS DISTINCT FROM '71e1e500a490fcd81f0bd743a8c18a8c' THEN
    RAISE EXCEPTION 'Stale baseline: mission_generic_owner.actor_principal(uuid)' USING ERRCODE='40001';
  END IF;
  IF md5(pg_get_functiondef('mission_generic_owner.bind_arena_native(uuid,uuid,uuid)'::regprocedure)) IS DISTINCT FROM '0e545701b16d7e669c0d5803b4f1f142' THEN
    RAISE EXCEPTION 'Stale baseline: mission_generic_owner.bind_arena_native(uuid,uuid,uuid)' USING ERRCODE='40001';
  END IF;
END;
$pinned_actor_baseline$;
ALTER TABLE clan_marionettisti_private.sources
  ALTER COLUMN owner_character_id DROP NOT NULL,
  DROP CONSTRAINT sources_source_kind_check,
  DROP CONSTRAINT sources_check;

ALTER TABLE clan_marionettisti_private.sources
  ADD CONSTRAINT sources_source_kind_check
    CHECK (source_kind IN ('real','staff','mission_service')),
  ADD CONSTRAINT sources_check CHECK (
    (source_kind='real' AND real_companion_id IS NOT NULL AND real_companion_id=id
      AND session_id IS NULL AND owner_actor_id IS NULL AND owner_character_id IS NOT NULL)
    OR (source_kind='staff' AND real_companion_id IS NULL
      AND session_id IS NOT NULL AND owner_actor_id IS NOT NULL AND owner_character_id IS NOT NULL)
    OR (source_kind='mission_service' AND real_companion_id IS NULL
      AND session_id IS NOT NULL AND owner_actor_id IS NOT NULL AND owner_character_id IS NULL
      AND profile_version='marionetta-l1/1')
  );

ALTER TABLE clan_marionettisti_private.chassis
  ALTER COLUMN owner_character_id DROP NOT NULL,
  ADD COLUMN mission_owner_actor_id uuid REFERENCES public.combat_v2_actors(id) ON DELETE RESTRICT,
  ADD CONSTRAINT chassis_owner_identity_check
    CHECK ((owner_character_id IS NULL) <> (mission_owner_actor_id IS NULL));

CREATE TABLE clan_marionettisti_private.mission_companion_entitlements_v1 (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  definition_id uuid NOT NULL REFERENCES mission_generic_owner.definitions(id) ON DELETE RESTRICT,
  step_key text NOT NULL CHECK (length(step_key) BETWEEN 1 AND 80),
  encounter_key text NOT NULL CHECK (length(encounter_key) BETWEEN 1 AND 80),
  actor_key text NOT NULL CHECK (length(actor_key) BETWEEN 1 AND 80),
  mechanical_binding_id uuid NOT NULL REFERENCES public.nb_mechanical_bindings(id) ON DELETE RESTRICT,
  staff_enabled boolean NOT NULL DEFAULT false,
  land_enabled boolean NOT NULL DEFAULT false,
  UNIQUE (definition_id,step_key,encounter_key,actor_key)
);
ALTER TABLE clan_marionettisti_private.mission_companion_entitlements_v1 ENABLE ROW LEVEL SECURITY;
REVOKE ALL ON clan_marionettisti_private.mission_companion_entitlements_v1 FROM PUBLIC, anon, authenticated, service_role;

CREATE TABLE clan_marionettisti_private.mission_companion_release_v1 (
  singleton boolean PRIMARY KEY DEFAULT true CHECK (singleton),
  land_enabled boolean NOT NULL DEFAULT false,
  updated_at timestamptz NOT NULL DEFAULT clock_timestamp()
);
ALTER TABLE clan_marionettisti_private.mission_companion_release_v1 ENABLE ROW LEVEL SECURITY;
REVOKE ALL ON clan_marionettisti_private.mission_companion_release_v1 FROM PUBLIC, anon, authenticated, service_role;
INSERT INTO clan_marionettisti_private.mission_companion_release_v1 (singleton) VALUES (true);

CREATE TABLE clan_marionettisti_private.mission_companion_receipts_v1 (
  source_id uuid PRIMARY KEY REFERENCES clan_marionettisti_private.sources(id) ON DELETE RESTRICT,
  entitlement_id uuid NOT NULL REFERENCES clan_marionettisti_private.mission_companion_entitlements_v1(id) ON DELETE RESTRICT,
  session_id uuid NOT NULL REFERENCES mission_generic_owner.encounters(encounter_id) ON DELETE RESTRICT,
  owner_actor_id uuid NOT NULL REFERENCES public.combat_v2_actors(id) ON DELETE RESTRICT,
  body_actor_id uuid NOT NULL UNIQUE REFERENCES public.combat_v2_actors(id) DEFERRABLE INITIALLY DEFERRED,
  instance_id uuid NOT NULL REFERENCES combat_spatial.arena_instances(instance_id) ON DELETE RESTRICT,
  capability_id uuid NOT NULL REFERENCES mission_ai_service_owner.capabilities(id) ON DELETE RESTRICT,
  provider_instance_id uuid NOT NULL REFERENCES public.combat_v2_provider_instances_v1(id) ON DELETE RESTRICT,
  run_snapshot_sha256 text NOT NULL CHECK (run_snapshot_sha256 ~ '^[0-9a-f]{64}$'),
  actor_key text NOT NULL CHECK (length(actor_key) BETWEEN 1 AND 80),
  mechanical_binding_id uuid NOT NULL REFERENCES public.nb_mechanical_bindings(id) ON DELETE RESTRICT,
  simulated boolean NOT NULL,
  created_at timestamptz NOT NULL DEFAULT clock_timestamp(),
  UNIQUE (session_id,owner_actor_id),
  CHECK (owner_actor_id<>body_actor_id)
);
ALTER TABLE clan_marionettisti_private.mission_companion_receipts_v1 ENABLE ROW LEVEL SECURITY;
REVOKE ALL ON clan_marionettisti_private.mission_companion_receipts_v1 FROM PUBLIC, anon, authenticated, service_role;

CREATE FUNCTION clan_marionettisti_private.mission_companion_identity_v1(p_body public.combat_v2_actors)
RETURNS boolean
LANGUAGE sql
STABLE SECURITY DEFINER
SET search_path=''
AS $function$
  SELECT EXISTS (
    SELECT 1
    FROM clan_marionettisti_private.mission_companion_receipts_v1 receipt
    JOIN clan_marionettisti_private.sources source ON source.id=receipt.source_id AND source.is_active
    JOIN clan_marionettisti_private.chassis chassis ON chassis.companion_id=source.id
    JOIN mission_generic_owner.encounters encounter ON encounter.encounter_id=receipt.session_id
      AND encounter.capability_id=receipt.capability_id
    JOIN mission_generic_owner.run_bindings binding ON binding.master_session_id=encounter.master_session_id
      AND binding.snapshot_sha256=receipt.run_snapshot_sha256
    JOIN public.combat_v2_sessions combat ON combat.id=receipt.session_id
      AND combat.source_kind='master' AND combat.master_session_id=encounter.master_session_id
    JOIN public.master_v2_sessions master ON master.id=combat.master_session_id
      AND master.owner_kind='ai_service' AND master.master_user IS NULL
    JOIN public.combat_v2_actors owner ON owner.id=receipt.owner_actor_id
      AND owner.session_id=receipt.session_id AND owner.actor_kind='png'
      AND owner.provider_instance_v1_id=receipt.provider_instance_id AND owner.controller_user IS NULL
      AND owner.companion_id IS NULL
    JOIN combat_spatial.arena_instances arena ON arena.instance_id=receipt.instance_id
      AND arena.encounter_id=receipt.session_id AND arena.master_session_id=master.id
      AND arena.context_source='panel_master'
    WHERE receipt.body_actor_id=p_body.id AND receipt.session_id=p_body.session_id
      AND source.id=p_body.companion_id AND source.source_kind='mission_service'
      AND source.session_id=receipt.session_id AND source.owner_actor_id=receipt.owner_actor_id
      AND source.profile_version='marionetta-l1/1' AND chassis.mission_owner_actor_id=owner.id
      AND p_body.actor_kind='png' AND p_body.controller_user IS NULL AND p_body.character_id IS NULL
      AND p_body.provider_instance_v1_id IS NULL AND p_body.png_instance_id IS NULL
      AND p_body.team_key=owner.team_key AND p_body.controller_version=owner.controller_version
      AND p_body.initiative_snapshot=0 AND p_body.mechanics_snapshot @> '{"companion_passive":true}'::jsonb
      AND EXISTS (SELECT 1 FROM jsonb_array_elements(encounter.actor_map) item
        WHERE item->>'actor_id'=owner.id::text AND item->>'actor_key'=receipt.actor_key
          AND item->>'mechanical_binding_id'=receipt.mechanical_binding_id::text)
  )
$function$;
REVOKE ALL ON FUNCTION clan_marionettisti_private.mission_companion_identity_v1(public.combat_v2_actors)
  FROM PUBLIC, anon, authenticated, service_role;

CREATE FUNCTION clan_marionettisti_private.mission_companion_valid(p_session uuid,p_owner uuid,p_body uuid)
RETURNS boolean
LANGUAGE sql
STABLE SECURITY DEFINER
SET search_path=''
AS $function$
  SELECT EXISTS (
    SELECT 1
    FROM public.combat_v2_actors body
    JOIN clan_marionettisti_private.mission_companion_receipts_v1 receipt
      ON receipt.body_actor_id=body.id AND receipt.session_id=body.session_id
    JOIN clan_marionettisti_private.links link ON link.owner_actor_id=receipt.owner_actor_id
      AND link.companion_actor_id=body.id AND link.instance_id=receipt.instance_id
      AND link.is_simulated=receipt.simulated
    JOIN combat_spatial.actor_states body_map ON body_map.instance_id=receipt.instance_id AND body_map.actor_id=body.id
    JOIN combat_spatial.actor_states owner_map ON owner_map.instance_id=receipt.instance_id
      AND owner_map.actor_id=receipt.owner_actor_id
    WHERE body.id=p_body AND body.session_id=p_session AND receipt.owner_actor_id=p_owner
      AND body_map.actor_kind='PNG' AND owner_map.actor_kind='PNG'
      AND body_map.footprint_radius_m=0.5
      AND clan_marionettisti_private.mission_companion_identity_v1(body)
  )
$function$;
REVOKE ALL ON FUNCTION clan_marionettisti_private.mission_companion_valid(uuid,uuid,uuid)
  FROM PUBLIC, anon, authenticated, service_role;
CREATE OR REPLACE FUNCTION clan_marionettisti_private.assert_source(p_source uuid)
 RETURNS clan_marionettisti_private.sources
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO ''
AS $function$
declare src clan_marionettisti_private.sources%rowtype;
 a public.combat_v2_actors%rowtype; principals uuid[];
begin
 select * into src from clan_marionettisti_private.sources where id=p_source;
 if not found or not src.is_active then raise exception 'companion_source_unavailable' using errcode='40001';end if;
 if src.source_kind='real' then
  if not exists(select 1 from public.character_companions cc
    join public.characters c on c.id=cc.character_id
    where cc.id=src.real_companion_id and cc.character_id=src.owner_character_id
      and cc.kind='marionetta' and cc.is_active and c.clan='Marionettisti') then
   raise exception 'companion_real_source_drift' using errcode='40001';
  end if;
 elsif src.source_kind='mission_service' then
  if not exists (select 1 from clan_marionettisti_private.mission_companion_receipts_v1 issued
    where issued.source_id=src.id
      and clan_marionettisti_private.mission_companion_valid(src.session_id,src.owner_actor_id,issued.body_actor_id)) then
   raise exception 'mission_companion_source_drift' using errcode='40001';
  end if;
 else
  if not coalesce((select staff_enabled from clan_marionettisti_private.release_gate where singleton),false) then
   raise exception 'companion_staff_release_disabled' using errcode='42501';end if;
  select * into a from public.combat_v2_actors where id=src.owner_actor_id;
  if not found or a.actor_kind<>'pg' or a.session_id<>src.session_id
    or a.character_id is distinct from src.owner_character_id then
   raise exception 'companion_staff_owner_drift' using errcode='40001';
  end if;
  if exists(select 1 from public.combat_v2_sessions ms
    join combat_panel_private.master_panel_sessions mp on mp.master_session_id=ms.master_session_id
    where ms.id=src.session_id and ms.source_kind='master') then
   if not combat_panel_private.master_staff_companion_scope(src.session_id) then
    raise exception 'companion_master_staff_scope_invalid' using errcode='42501';end if;
   return src;
  end if;
  select array_agg(distinct x.controller_user order by x.controller_user) into principals
   from public.combat_v2_actors x
   join combat_consumer_private.members m on m.session_id=x.session_id
    and m.actor_id=x.id and m.character_id=x.character_id
   join public.characters c on c.id=x.character_id and c.user_id=x.controller_user
   where x.session_id=src.session_id and x.actor_kind='pg';
  if cardinality(principals) is distinct from 2
   or (select count(*) from public.combat_v2_actors where session_id=src.session_id and actor_kind='pg')<>2
   or not (a.controller_user=any(principals)) or not exists(
   select 1 from public.combat_v2_sessions s
   join combat_consumer_private.activities ctx on ctx.session_id=s.id and ctx.location_id=s.location_id
   where s.id=src.session_id and s.source_kind='ordinary' and s.closed_at is null
    and ctx.phase<>'closed' and ctx.policy_id='staff_test_no_persistent_resources_v1'
    and not public.combat_v2_values_written(s.id)
    and combat_consumer_private.staff_test_allowed(s.location_id,principals,false)) then
   raise exception 'companion_staff_scope_invalid' using errcode='42501';
  end if;
 end if;
 return src;
end;
$function$;

CREATE OR REPLACE FUNCTION clan_marionettisti_private.assert_companion_actor(p_actor uuid, p_require_active boolean DEFAULT true)
 RETURNS uuid
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO ''
AS $function$
declare
  v_actor public.combat_v2_actors%rowtype;
  v_owner public.combat_v2_actors%rowtype;
  v_comp clan_marionettisti_private.sources%rowtype;
  v_chassis clan_marionettisti_private.chassis%rowtype;
begin
  select * into v_actor from public.combat_v2_actors where id=p_actor;
  if not found or v_actor.actor_kind<>'png' or v_actor.companion_id is null then
    raise exception 'companion_actor_required' using errcode='22023';
  end if;
  v_comp:=clan_marionettisti_private.assert_source(v_actor.companion_id);
  if v_comp.source_kind='mission_service' then
    select * into v_owner from public.combat_v2_actors where id=v_comp.owner_actor_id;
    if not found or v_comp.session_id is distinct from v_actor.session_id
        or p_require_active is null or (p_require_active and v_owner.state<>'attivo') then
      raise exception 'mission_companion_owner_binding_drift' using errcode='40001';
    end if;
    return v_owner.id;
  end if;
  if v_comp.source_kind='staff' and v_comp.session_id<>v_actor.session_id then
    raise exception 'companion_test_session_mismatch' using errcode='40001';end if;
  if v_comp.source_kind='real' and exists(select 1 from public.combat_v2_sessions s
    join public.locations loc on loc.id=s.location_id where s.id=v_actor.session_id and loc.is_test) then
    raise exception 'companion_real_source_in_test' using errcode='42501';end if;
  select * into v_chassis from clan_marionettisti_private.chassis
    where companion_id=v_comp.id;
  if not found or v_chassis.owner_character_id<>v_comp.owner_character_id then
    raise exception 'companion_chassis_source_drift' using errcode='40001';
  end if;
  select * into v_owner from public.combat_v2_actors
    where session_id=v_actor.session_id and actor_kind='pg'
      and character_id=v_comp.owner_character_id;
  if not found or p_require_active is null or (p_require_active and v_owner.state<>'attivo')
      or v_actor.controller_user is distinct from v_owner.controller_user
      or v_actor.team_key is distinct from v_owner.team_key
      or v_actor.controller_version is distinct from v_owner.controller_version then
    raise exception 'companion_owner_binding_drift' using errcode='40001';
  end if;
  if v_comp.source_kind='staff' and v_comp.owner_actor_id<>v_owner.id then
    raise exception 'companion_staff_owner_mismatch' using errcode='40001';end if;
  return v_owner.id;
end;
$function$;

CREATE OR REPLACE FUNCTION clan_marionettisti_private.owner_eligible(p_actor uuid, p_attack boolean DEFAULT false)
 RETURNS boolean
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO ''
AS $function$
declare a public.combat_v2_actors%rowtype; src clan_marionettisti_private.sources%rowtype;
 needed uuid[]:=array['4d742b75-2592-4379-81c0-07ddf436f32b'::uuid,'bfe4b934-5979-4e5a-8bff-982f9c41cfe7'::uuid];
begin
 select * into a from public.combat_v2_actors where id=p_actor;
 if not found or a.state<>'attivo' or p_attack is null then return false;end if;
 if a.actor_kind='png' then
  return not p_attack and exists(
    select 1 from clan_marionettisti_private.mission_companion_receipts_v1 issued
    where issued.session_id=a.session_id and issued.owner_actor_id=a.id
      and clan_marionettisti_private.mission_companion_valid(a.session_id,a.id,issued.body_actor_id));
 end if;
 if a.actor_kind<>'pg' then return false;end if;
 if p_attack and coalesce((a.mechanics_snapshot->>'chakra')::integer,-1)<5 then return false;end if;
 if p_attack then needed:=array_append(needed,'e361f7c3-f90b-47ec-bfee-ccbda21257d9'::uuid);end if;
 select * into src from clan_marionettisti_private.sources
  where source_kind='staff' and session_id=a.session_id and owner_actor_id=a.id and is_active;
 if found then
  perform clan_marionettisti_private.assert_source(src.id);
  return coalesce((a.mechanics_snapshot->>'kekkei_genkai')::integer>=30,false)
   and (select count(distinct (j->>'id')::uuid) from jsonb_array_elements(coalesce(a.mechanics_snapshot->'abilities','[]')) j
    where j->>'source'='clan' and (j->>'id')::uuid=any(needed))=cardinality(needed);
 end if;
 if exists(select 1 from public.combat_v2_sessions s join public.locations l on l.id=s.location_id
  where s.id=a.session_id and l.is_test) then return false;end if;
 if not coalesce((select public_enabled from clan_marionettisti_private.release_gate where singleton),false) then return false;end if;
 return exists(select 1 from public.characters c where c.id=a.character_id
    and c.clan='Marionettisti' and c.kekkei_genkai>=30 and public._grade_rank(c.rank)>=1)
  and (select count(distinct ca.technique_id) from public.character_abilities ca
    join public.clan_techniques ct on ct.id=ca.technique_id and ct.is_active
    where ca.character_id=a.character_id and ca.state='attiva' and ca.technique_id=any(needed))=cardinality(needed);
end;
$function$;

CREATE OR REPLACE FUNCTION clan_marionettisti_private.apply_resolved_damage(p_companion uuid, p_damage_event uuid, p_expected_version bigint, p_resolved_damage integer)
 RETURNS jsonb
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO ''
AS $function$
declare
  v_comp clan_marionettisti_private.sources%rowtype;
  v_state clan_marionettisti_private.chassis%rowtype;
  v_receipt clan_marionettisti_private.damage_receipts%rowtype;
  v_after integer;
  v_source_identity record;
begin
  if p_companion is null or p_damage_event is null or p_expected_version is null
      or p_expected_version < 1 or p_resolved_damage is null or p_resolved_damage < 0 then
    raise exception 'invalid_damage_request' using errcode = '22023';
  end if;
  -- Il resolver blocca prima attori e PG, poi il compagno.
  select source_kind, owner_character_id, owner_actor_id into v_source_identity
    from clan_marionettisti_private.sources where id=p_companion;
  if not found then raise exception 'companion_not_found' using errcode='22023'; end if;
  if v_source_identity.source_kind='mission_service' then
    perform 1 from public.combat_v2_actors where id=v_source_identity.owner_actor_id for share;
  else
    perform 1 from public.characters where id=v_source_identity.owner_character_id for share;
  end if;
  if not found then raise exception 'owner_not_eligible' using errcode='22023'; end if;
  perform clan_marionettisti_private.assert_source(p_companion);
  select * into v_comp from clan_marionettisti_private.sources where id = p_companion for update;
  if not found then raise exception 'companion_not_found' using errcode = '22023'; end if;
  select * into v_state from clan_marionettisti_private.chassis
    where companion_id = p_companion for update;
  if not found then raise exception 'chassis_not_registered' using errcode = '22023'; end if;
  -- Anche il replay deve rispettare l'identità e l'abilitazione correnti.
  if not v_comp.is_active
      or v_comp.source_kind is distinct from v_source_identity.source_kind
      or v_comp.owner_character_id is distinct from v_source_identity.owner_character_id
      or v_comp.owner_actor_id is distinct from v_source_identity.owner_actor_id
      or v_state.owner_character_id is distinct from v_comp.owner_character_id
      or v_state.mission_owner_actor_id is distinct from
        (case when v_comp.source_kind='mission_service' then v_comp.owner_actor_id else null end) then
    raise exception 'companion_source_drift' using errcode = '40001';
  end if;
  select * into v_receipt from clan_marionettisti_private.damage_receipts
    where companion_id = p_companion and damage_event_id = p_damage_event;
  if found then
    if v_receipt.expected_version <> p_expected_version
        or v_receipt.resolved_damage <> p_resolved_damage then
      raise exception 'damage_event_conflict' using errcode = '22023';
    end if;
    return jsonb_build_object('damage_event_id', p_damage_event,
      'integrity', v_receipt.integrity_after, 'state_version', v_receipt.resulting_version);
  end if;
  if v_state.state_version <> p_expected_version then
    raise exception 'chassis_version_stale' using errcode = '40001';
  end if;
  v_after := greatest(0, v_state.integrity - p_resolved_damage);
  insert into clan_marionettisti_private.damage_receipts
    (companion_id, damage_event_id, expected_version, resolved_damage,
     integrity_before, integrity_after, resulting_version)
    values (p_companion, p_damage_event, p_expected_version, p_resolved_damage,
      v_state.integrity, v_after, v_state.state_version + 1);
  update clan_marionettisti_private.chassis
    set integrity = v_after, state_version = state_version + 1
    where companion_id = p_companion;
  return jsonb_build_object('damage_event_id', p_damage_event,
    'integrity', v_after, 'state_version', v_state.state_version + 1);
end;
$function$;

CREATE OR REPLACE FUNCTION clan_marionettisti_private.settle_round_damage(p_report uuid)
 RETURNS jsonb
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO ''
AS $function$
declare
 v_report public.combat_v2_round_reports%rowtype;
 v_round public.combat_v2_rounds%rowtype;
 v_target record;
 v_chassis clan_marionettisti_private.chassis%rowtype;
 v_link clan_marionettisti_private.common_damage_links%rowtype;
 v_receipt clan_marionettisti_private.damage_receipts%rowtype;
 v_result jsonb; v_count integer:=0; v_owner uuid;
 v_damage integer; v_hp integer;
 v_seen uuid[]:='{}'; v_initial jsonb;
begin
 select * into v_report from public.combat_v2_round_reports where id=p_report;
 if not found then raise exception 'common_report_required' using errcode='22023'; end if;
 -- Ordine lock comune; mai mutare lo storage su sola attestazione client.
 perform public.combat_v2_lock_round(v_report.round_id);
 select * into v_round from public.combat_v2_rounds where id=v_report.round_id for update;
 if not found or v_round.report_id is distinct from p_report
   or v_report.values_written is null
   or jsonb_typeof(v_report.mechanics) is distinct from 'object'
   or v_round.state not in ('risolto','narrazione','narrato')
   or v_report.mechanics_sha256 is distinct from public.combat_v2_sha256(v_report.mechanics)
   or (v_report.mechanics->>'values_written')::boolean is distinct from v_report.values_written then
  raise exception 'common_report_binding_invalid' using errcode='40001';
 end if;
 if not v_report.values_written and not exists(
   select 1 from clan_marionettisti_private.sources
   where session_id=v_round.session_id and source_kind in ('staff','mission_service') and is_active) then
  return jsonb_build_object('report_id',p_report,'persisted_targets',0,'simulated',true);
 end if;
 perform 1 from public.combat_v2_sessions where id=v_round.session_id for update;
 perform 1 from public.combat_v2_actors where session_id=v_round.session_id order by id for update;
 perform 1 from public.characters where id in
  (select character_id from public.combat_v2_actors where session_id=v_round.session_id and actor_kind='pg')
  order by id for update;
 for v_target in
  select t.*,a.companion_id,a.session_id as actor_session_id,d.order_no
  from public.combat_v2_attack_targets t
  join public.combat_v2_declarations d on d.id=t.attack_declaration_id and d.round_id=t.round_id
  join public.combat_v2_actors a on a.id=t.target_actor_id
  join clan_marionettisti_private.sources source on source.id=a.companion_id and source.profile_version='marionetta-l1/1'
  where t.round_id=v_round.id and a.companion_id is not null
    and d.sanitized_intent->'target_fili' IS DISTINCT FROM 'true'::jsonb
  order by d.order_no,t.ordinal,t.id
 loop
  if v_target.actor_session_id is distinct from v_round.session_id
    or not exists(select 1 from jsonb_array_elements(v_report.mechanics->'attack_targets') j
      where j= (select to_jsonb(t) from public.combat_v2_attack_targets t where t.id=v_target.id)) then
   raise exception 'common_target_binding_invalid' using errcode='40001';
  end if;
  -- Owner può essere andato KO nello stesso round: non annullare il danno già risolto.
  v_owner:=clan_marionettisti_private.assert_companion_actor(v_target.target_actor_id,false);
  if exists(select 1 from clan_marionettisti_private.sources s
    left join clan_marionettisti_private.mission_companion_receipts_v1 issued on issued.source_id=s.id
    where s.id=v_target.companion_id
      and (case when s.source_kind='mission_service' then issued.simulated else s.source_kind='staff' end)
        is distinct from (not v_report.values_written)) then
   raise exception 'common_companion_resource_scope_mismatch' using errcode='40001';end if;
  if v_target.state='superflua' then continue; end if;
  if v_target.state<>'risolta'
    or jsonb_typeof(v_target.outcome->'damage_applied') is distinct from 'number'
    or jsonb_typeof(v_target.outcome->'target_hp_after') is distinct from 'number' then
   raise exception 'common_target_not_settled' using errcode='40001';
  end if;
  v_damage:=(v_target.outcome->>'damage_applied')::integer;
  v_hp:=(v_target.outcome->>'target_hp_after')::integer;
  if v_damage<0 or v_hp<0 or v_hp>30 then
   raise exception 'common_damage_shape_invalid' using errcode='40001';
  end if;
  select * into v_link from clan_marionettisti_private.common_damage_links where attack_target_id=v_target.id;
  if found then
   if v_link.report_id<>p_report or v_link.companion_id<>v_target.companion_id
     or v_link.report_sha256<>v_report.mechanics_sha256 then
    raise exception 'common_damage_link_conflict' using errcode='40001';
   end if;
   select * into strict v_receipt from clan_marionettisti_private.damage_receipts
     where companion_id=v_target.companion_id and damage_event_id=v_target.id;
   v_result:=clan_marionettisti_private.apply_resolved_damage(v_target.companion_id,
     v_target.id,v_receipt.expected_version,v_damage);
  else
   -- consumer detiene già gli attori/PG: completa ordine compagno→chassis.
   perform 1 from clan_marionettisti_private.sources where id=v_target.companion_id for update;
   select * into strict v_chassis from clan_marionettisti_private.chassis
     where companion_id=v_target.companion_id for update;
   if not (v_target.companion_id=any(v_seen)) then
    select j->'mechanics' into strict v_initial
      from jsonb_array_elements(v_report.mechanics->'initial_actors') j
      where j->>'actor'=v_target.target_actor_id::text;
    if jsonb_typeof(v_initial->'vita') is distinct from 'number'
      or (v_initial->>'vita')::integer<>v_chassis.integrity then
     raise exception 'common_initial_chassis_drift' using errcode='40001';
    end if;
    v_seen:=array_append(v_seen,v_target.companion_id);
   end if;
   if greatest(0,v_chassis.integrity-v_damage)<>v_hp then
    raise exception 'common_chassis_balance_drift' using errcode='40001';
   end if;
   v_result:=clan_marionettisti_private.apply_resolved_damage(v_target.companion_id,
     v_target.id,v_chassis.state_version,v_damage);
   insert into clan_marionettisti_private.common_damage_links
     (attack_target_id,report_id,companion_id,report_sha256)
     values(v_target.id,p_report,v_target.companion_id,v_report.mechanics_sha256);
  end if;
  if (v_result->>'integrity')::integer<>v_hp then
   raise exception 'common_damage_receipt_mismatch' using errcode='40001';
  end if;
  v_count:=v_count+1;
 end loop;
 return jsonb_build_object('report_id',p_report,'persisted_targets',v_count,'simulated',not v_report.values_written);
end;
$function$;

CREATE OR REPLACE FUNCTION combat_panel_private.master_companion_roster_valid(p_session uuid)
 RETURNS boolean
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO ''
AS $function$
DECLARE actor record;
BEGIN
 IF NOT EXISTS(SELECT 1 FROM public.combat_v2_sessions s
   JOIN combat_panel_private.master_panel_sessions p ON p.master_session_id=s.master_session_id
   WHERE s.id=p_session AND s.source_kind='master') THEN RETURN false;END IF;
 IF NOT public.combat_v2_values_written(p_session)
   AND NOT combat_panel_private.master_staff_companion_scope(p_session)
   AND (NOT EXISTS (SELECT 1 FROM clan_marionettisti_private.mission_companion_receipts_v1 issued
     WHERE issued.session_id=p_session AND issued.simulated
       AND clan_marionettisti_private.mission_companion_valid(p_session,issued.owner_actor_id,issued.body_actor_id))
     OR EXISTS (SELECT 1 FROM public.combat_v2_actors body
       JOIN clan_marionettisti_private.sources src ON src.id=body.companion_id
       WHERE body.session_id=p_session AND src.source_kind<>'mission_service')) THEN RETURN false;END IF;
 IF EXISTS(SELECT 1 FROM public.combat_v2_actors x
   LEFT JOIN clan_marionettisti_private.sources src ON src.id=x.companion_id AND src.is_active
   WHERE x.session_id=p_session AND x.companion_id IS NOT NULL AND src.id IS NULL)
  OR EXISTS(SELECT 1 FROM public.combat_v2_actors x JOIN clan_marionettisti_private.sources src ON src.id=x.companion_id
    WHERE x.session_id=p_session GROUP BY coalesce(src.owner_character_id,src.owner_actor_id) HAVING count(*)>1) THEN RETURN false;END IF;
 FOR actor IN SELECT x.*,src.profile_version FROM public.combat_v2_actors x
  JOIN clan_marionettisti_private.sources src ON src.id=x.companion_id AND src.is_active
  WHERE x.session_id=p_session AND x.companion_id IS NOT NULL LOOP
  IF actor.actor_kind<>'png' OR actor.initiative_snapshot<>0
   OR actor.mechanics_snapshot->>'companion_passive' IS DISTINCT FROM 'true' THEN RETURN false;END IF;
  IF actor.profile_version='marionetta-l1/1' THEN
   PERFORM clan_marionettisti_private.assert_companion_actor(actor.id,false);
  ELSIF actor.profile_version='ninken-l1/1' THEN
   PERFORM clan_inuzuka_private.assert_ninken_actor(actor.id,false);
  ELSE RETURN false;END IF;
 END LOOP;
 RETURN true;
END $function$;

CREATE OR REPLACE FUNCTION mission_generic_owner.assert_native_actor(a public.combat_v2_actors)
 RETURNS void
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO ''
AS $function$
declare s public.combat_v2_sessions;c uuid;scene jsonb;
begin
 select * into strict s from public.combat_v2_sessions where id=a.session_id;
 select id into strict c from mission_ai_service_owner.capabilities where master_session_id=s.master_session_id and state='active';
 perform mission_generic_owner.assert_combat_scope(s.master_session_id,c);
 if a.companion_id is not null then
  if not clan_marionettisti_private.mission_companion_identity_v1(a)
  then raise exception 'MG_NATIVE_PNG_SCOPE' using errcode='42501';end if;
  return;
 end if;
 if a.actor_kind='pg' then
  if not exists(select 1 from public.master_v2_participants p join public.characters ch on ch.id=p.character_id and ch.user_id=p.user_id_snapshot
   where p.session_id=s.master_session_id and p.character_id=a.character_id and p.user_id_snapshot=a.controller_user
   and p.left_at is null and p.engagement_state='attivo') then raise exception 'MG_NATIVE_PG_SCOPE' using errcode='42501';end if;
 else
  if a.controller_user is not null or a.provider_instance_v1_id is null or a.png_instance_id is not null or a.companion_id is not null
  then raise exception 'MG_NATIVE_PNG_SCOPE' using errcode='42501';end if;
  scene:=mission_generic_owner.scene(s.master_session_id,(select current_step_key from public.mission_run_state where master_session_id=s.master_session_id));
  if not exists(select 1 from public.combat_v2_provider_instances_v1 pi
   join public.master_v2_nb_actor_offers_v1 o on o.offer_ref=pi.offer_ref,
   lateral jsonb_array_elements(scene->'encounters') en,lateral jsonb_array_elements(en->'actors') na
   join public.nb_mechanical_bindings mb on mb.id=(na->>'mechanical_binding_id')::uuid
   where pi.id=a.provider_instance_v1_id and pi.session_id=s.id
   and pi.client_ref=mission_ai_service_owner.uuid5(s.master_session_id,'actor:'||(na->>'actor_key'))
   and pi.narrative_version_ref=mb.narrative_version_id and pi.mechanical_version_ref=mb.mechanical_version_id
   and o.master_session_id=s.master_session_id and o.recipient_kind='ai_service' and o.recipient_service_capability=c
   and mission_generic_owner.binding_is_pinned(s.master_session_id,mb.id))
  then raise exception 'MG_NATIVE_PNG_PIN_SCOPE' using errcode='42501';end if;
 end if;
end $function$;

CREATE OR REPLACE FUNCTION mission_generic_owner.actor_principal(p_actor uuid)
 RETURNS uuid
 LANGUAGE sql
 STABLE SECURITY DEFINER
 SET search_path TO ''
AS $function$
 select mission_ai_service_owner.uuid5(a.id,'mission-generic-principal')
 from public.combat_v2_actors a
 join mission_generic_owner.encounters e on e.encounter_id=a.session_id
 join mission_generic_owner.run_bindings b on b.master_session_id=e.master_session_id
 join public.master_v2_sessions m on m.id=e.master_session_id
 join public.combat_v2_sessions s on s.id=e.encounter_id
 join mission_ai_service_owner.capabilities c on c.id=e.capability_id and c.master_session_id=m.id
 where a.id=p_actor and a.actor_kind='png' and a.controller_user is null and a.character_id is null
 and m.owner_kind='ai_service' and m.master_user is null and m.closed_at is null
 and s.closed_at is null and s.state not in('chiuso','annullato') and c.state='active'
 and b.snapshot_sha256=mission_internal.fingerprint(b.snapshot)
 and (exists(select 1 from jsonb_array_elements(e.actor_map) x where x->>'actor_id'=a.id::text)
   or (a.companion_id is not null and exists(
     select 1 from clan_marionettisti_private.mission_companion_receipts_v1 issued
     where issued.source_id=a.companion_id
       and clan_marionettisti_private.mission_companion_valid(a.session_id,issued.owner_actor_id,a.id))))
$function$;
CREATE FUNCTION clan_marionettisti_private.bind_mission_companions_v1(
  p_master uuid,p_encounter uuid,p_instance uuid,p_request uuid
)
RETURNS void
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path=''
AS $function$
DECLARE scope record; entitlement record; owner public.combat_v2_actors%ROWTYPE;
  owner_map combat_spatial.actor_states%ROWTYPE; placement record;
  source_id uuid; body_id uuid; simulated boolean; land_released boolean;
BEGIN
  -- A mission without a configured companion keeps its original arena path.
  IF NOT EXISTS (
    SELECT 1 FROM mission_generic_owner.encounters e
    JOIN mission_generic_owner.run_bindings binding ON binding.master_session_id=e.master_session_id
    JOIN public.master_v2_sessions master ON master.id=e.master_session_id
    JOIN public.locations room ON room.id=master.location_id
    LEFT JOIN mission_generic_owner.simulation_sources simulation
      ON simulation.carrier_mission_id=master.mission_id AND room.is_test
    LEFT JOIN mission_generic_owner.plan_revisions source_revision
      ON source_revision.plan_version_id=simulation.source_plan_version_id
     AND source_revision.mission_id=simulation.source_mission_id
    JOIN clan_marionettisti_private.mission_companion_entitlements_v1 candidate_entitlement
      ON candidate_entitlement.definition_id=CASE WHEN room.is_test THEN source_revision.definition_id ELSE binding.definition_id END
     AND candidate_entitlement.step_key=e.step_key AND candidate_entitlement.encounter_key=e.encounter_key
     AND (CASE WHEN room.is_test THEN candidate_entitlement.staff_enabled ELSE candidate_entitlement.land_enabled END)
    WHERE e.master_session_id=p_master AND e.encounter_id=p_encounter
  ) THEN RETURN; END IF;

  SELECT e.capability_id,e.actor_map,e.step_key,e.encounter_key,
    b.definition_id,staff_revision.definition_id AS staff_definition_id,b.snapshot_sha256,l.id AS location_id,l.is_test,
    i.instance_id,i.template_key,i.template_version,i.panel_claim_id
    INTO STRICT scope
    FROM mission_generic_owner.encounters e
    JOIN mission_generic_owner.run_bindings b ON b.master_session_id=e.master_session_id
      AND b.snapshot_sha256=mission_internal.fingerprint(b.snapshot)
    JOIN public.master_v2_sessions m ON m.id=e.master_session_id AND m.owner_kind='ai_service'
      AND m.master_user IS NULL AND m.closed_at IS NULL
    JOIN public.combat_v2_sessions s ON s.id=e.encounter_id AND s.master_session_id=m.id
      AND s.source_kind='master' AND s.closed_at IS NULL AND s.location_id=m.location_id
    JOIN public.locations l ON l.id=m.location_id AND l.is_active
    LEFT JOIN mission_generic_owner.simulation_sources simulation ON simulation.carrier_mission_id=m.mission_id AND l.is_test
    LEFT JOIN mission_generic_owner.plan_revisions staff_revision
      ON staff_revision.plan_version_id=simulation.source_plan_version_id AND staff_revision.mission_id=simulation.source_mission_id
    JOIN combat_spatial.arena_instances i ON i.instance_id=p_instance AND i.encounter_id=s.id
      AND i.master_session_id=m.id AND i.context_source='panel_master' AND i.state='open'
    JOIN combat_panel_private.master_scene_claims scene_claim ON scene_claim.id=i.panel_claim_id
      AND scene_claim.encounter_id=s.id AND scene_claim.master_session_id=m.id
      AND scene_claim.authority_principal_id=e.capability_id
    WHERE m.id=p_master AND e.encounter_id=p_encounter AND e.request_key=p_request;

  simulated:=NOT public.combat_v2_values_written(p_encounter);
  IF NOT EXISTS (
    SELECT 1 FROM clan_marionettisti_private.mission_companion_entitlements_v1 pin
    WHERE pin.definition_id=CASE WHEN scope.is_test THEN scope.staff_definition_id ELSE scope.definition_id END
      AND pin.step_key=scope.step_key
      AND pin.encounter_key=scope.encounter_key
      AND CASE WHEN scope.is_test THEN pin.staff_enabled ELSE pin.land_enabled END
  ) THEN RETURN; END IF;
  IF NOT scope.is_test THEN
    SELECT release.land_enabled INTO land_released
    FROM clan_marionettisti_private.mission_companion_release_v1 release
    WHERE release.singleton FOR SHARE;
    IF land_released IS DISTINCT FROM true THEN RETURN; END IF;
  END IF;

  PERFORM mission_generic_owner.assert_combat_scope(p_master,scope.capability_id);
  IF scope.is_test AND (NOT simulated OR scope.location_id<>'0b85f354-9cdb-47e1-baf9-3d266bb7e06b'::uuid) THEN
    RAISE EXCEPTION 'mission_companion_resource_scope_invalid' USING ERRCODE='42501';
  END IF;
  -- This is part of the native arena-open transaction, before any declaration.
  IF EXISTS (SELECT 1 FROM public.combat_v2_rounds turn
    JOIN public.combat_v2_declarations declaration ON declaration.round_id=turn.id
    WHERE turn.session_id=p_encounter) THEN
    RAISE EXCEPTION 'mission_companion_encounter_already_playing' USING ERRCODE='40001';
  END IF;

  FOR entitlement IN
    SELECT pin.*,
      (frozen.item->>'actor_id')::uuid AS owner_id
    FROM clan_marionettisti_private.mission_companion_entitlements_v1 pin
    LEFT JOIN LATERAL (
      SELECT actor.item FROM jsonb_array_elements(scope.actor_map) actor(item)
      WHERE actor.item->>'actor_key'=pin.actor_key
        AND actor.item->>'mechanical_binding_id'=pin.mechanical_binding_id::text
    ) frozen ON true
    WHERE pin.definition_id=CASE WHEN scope.is_test THEN scope.staff_definition_id ELSE scope.definition_id END
      AND pin.step_key=scope.step_key
      AND pin.encounter_key=scope.encounter_key
      AND CASE WHEN scope.is_test THEN pin.staff_enabled ELSE pin.land_enabled END
    ORDER BY pin.actor_key
    FOR SHARE OF pin
  LOOP
    SELECT npc.* INTO owner
    FROM public.combat_v2_actors npc
    JOIN public.combat_v2_provider_instances_v1 provider ON provider.id=npc.provider_instance_v1_id
      AND provider.session_id=npc.session_id
    JOIN public.nb_mechanical_bindings pinned ON pinned.id=entitlement.mechanical_binding_id
      AND pinned.narrative_version_id=provider.narrative_version_ref
      AND pinned.mechanical_version_id=provider.mechanical_version_ref
    WHERE npc.id=entitlement.owner_id AND npc.session_id=p_encounter
      AND npc.actor_kind='png' AND npc.state='attivo' AND npc.companion_id IS NULL
      AND npc.controller_user IS NULL AND npc.character_id IS NULL
      AND EXISTS (SELECT 1 FROM public.combat_v2_actors pg
        WHERE pg.session_id=p_encounter AND pg.actor_kind='pg'
          AND pg.state='attivo' AND pg.team_key<>npc.team_key);
    IF NOT FOUND THEN RAISE EXCEPTION 'mission_companion_bound_npc_invalid' USING ERRCODE='42501'; END IF;
    PERFORM mission_generic_owner.assert_native_actor(owner);
    SELECT * INTO STRICT owner_map FROM combat_spatial.actor_states
      WHERE instance_id=p_instance AND actor_id=owner.id AND actor_kind='PNG' AND state='active';

    -- Native L1 placement: cardinal two-metre offsets, actual footprint and line of effect.
    SELECT candidate.x,candidate.y INTO placement
    FROM (VALUES (1,2,0),(2,0,2),(3,-2,0),(4,0,-2)) offset_choice(ordinal,dx,dy)
    CROSS JOIN LATERAL (SELECT owner_map.x_m+offset_choice.dx AS x,
                              owner_map.y_m+offset_choice.dy AS y) candidate
    WHERE clan_marionettisti_private.scene_slot_legal(scope.template_key,scope.template_version,candidate.x,candidate.y,0.5)
      AND NOT EXISTS (SELECT 1 FROM combat_spatial.actor_states obstacle
        WHERE obstacle.instance_id=p_instance AND obstacle.state='active'
          AND combat_spatial.distance_m(candidate.x,candidate.y,obstacle.x_m,obstacle.y_m)<=0.5+obstacle.footprint_radius_m)
      AND combat_spatial.path_first_block_t(p_instance,owner.id,owner_map.x_m,owner_map.y_m,candidate.x,candidate.y,NULL)>=1
    ORDER BY offset_choice.ordinal
    LIMIT 1;
    IF NOT FOUND THEN RAISE EXCEPTION 'mission_companion_placement_unavailable' USING ERRCODE='22023'; END IF;

    source_id:=mission_ai_service_owner.uuid5(p_encounter,'marionetta-source:'||entitlement.actor_key);
    body_id:=mission_ai_service_owner.uuid5(p_encounter,'marionetta-body:'||entitlement.actor_key);
    INSERT INTO clan_marionettisti_private.sources(id,source_kind,session_id,owner_actor_id,profile_version)
      VALUES(source_id,'mission_service',p_encounter,owner.id,'marionetta-l1/1');
    INSERT INTO clan_marionettisti_private.chassis(companion_id,mission_owner_actor_id)
      VALUES(source_id,owner.id);
    INSERT INTO clan_marionettisti_private.mission_companion_receipts_v1(
      source_id,entitlement_id,session_id,owner_actor_id,body_actor_id,instance_id,
      capability_id,provider_instance_id,run_snapshot_sha256,actor_key,mechanical_binding_id,simulated
    ) VALUES (
      source_id,entitlement.id,p_encounter,owner.id,body_id,p_instance,
      scope.capability_id,owner.provider_instance_v1_id,scope.snapshot_sha256,
      entitlement.actor_key,entitlement.mechanical_binding_id,simulated
    );
    INSERT INTO public.combat_v2_actors(id,session_id,actor_kind,companion_id,team_key,state,
      position_m,initiative_snapshot,mechanics_snapshot,controller_version)
      VALUES(body_id,p_encounter,'png',source_id,owner.team_key,'attivo',0,0,
        jsonb_build_object('vita',30,'vita_max',30,'companion_passive',true,'position_authority','spatial2d'),
        owner.controller_version);
    INSERT INTO combat_spatial.actor_states(instance_id,actor_id,actor_kind,slot_key,controller_principal_id,
      projection_subject_id,x_m,y_m,footprint_radius_m,body_version,state)
      VALUES(p_instance,body_id,'PNG','COMPANION-'||owner.id,mission_ai_service_owner.uuid5(body_id,'mission-generic-principal'),
        mission_ai_service_owner.uuid5(body_id,'mission-generic-projection'),placement.x,placement.y,0.5,1,'active');
    INSERT INTO combat_spatial.viewer_grants(instance_id,viewer_principal_id,subject_actor_id,can_view_map,can_view_objects,grant_version)
      SELECT p_instance,grant_row.viewer_principal_id,body_id,true,grant_row.can_view_objects,1
      FROM combat_spatial.viewer_grants grant_row
      WHERE grant_row.instance_id=p_instance AND grant_row.subject_actor_id=owner.id AND grant_row.can_view_map;
    IF NOT clan_marionettisti_private.link_path(p_instance,owner.id,body_id) THEN
      RAISE EXCEPTION 'mission_companion_link_unavailable' USING ERRCODE='22023';
    END IF;
    INSERT INTO clan_marionettisti_private.links(owner_actor_id,companion_actor_id,instance_id,state,link_version,is_simulated)
      VALUES(owner.id,body_id,p_instance,'connected',1,simulated);
    IF NOT clan_marionettisti_private.mission_companion_valid(p_encounter,owner.id,body_id) THEN
      RAISE EXCEPTION 'mission_companion_initial_binding_failed' USING ERRCODE='40001';
    END IF;
  END LOOP;
  UPDATE combat_panel_private.master_scene_claims SET roster_fingerprint=combat_panel_private.master_roster_fingerprint(p_encounter)
    WHERE id=scope.panel_claim_id;
  IF NOT combat_panel_private.master_companion_roster_valid(p_encounter) THEN
    RAISE EXCEPTION 'mission_companion_roster_invalid' USING ERRCODE='40001';
  END IF;
END;
$function$;
REVOKE ALL ON FUNCTION clan_marionettisti_private.bind_mission_companions_v1(uuid,uuid,uuid,uuid)
  FROM PUBLIC, anon, authenticated, service_role;
CREATE OR REPLACE FUNCTION mission_generic_owner.bind_arena_native(p_master uuid, p_encounter uuid, p_request uuid)
 RETURNS jsonb
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO ''
AS $function$
declare e mission_generic_owner.encounters;b mission_generic_owner.run_bindings;m public.master_v2_sessions;
 t combat_spatial.arena_templates;src jsonb;pid uuid;claim uuid;iid uuid;policy text;chosen boolean;planned jsonb;placement jsonb;placement_index integer:=0;
 q mission_factory_owner.quest_run_sources%rowtype;r public.mission_run_state%rowtype;sc jsonb;en jsonb;is_quest boolean;
 a record;slot record;radius numeric;principal uuid;
begin
 select * into strict e from mission_generic_owner.encounters where encounter_id=p_encounter and master_session_id=p_master;
 perform mission_generic_owner.assert_combat_scope(p_master,e.capability_id);
 select * into strict m from public.master_v2_sessions where id=p_master for update;
 select * into q from mission_factory_owner.quest_run_sources where session_id=p_master for share;
 is_quest:=found;
 if is_quest then
   select * into strict r from public.mission_run_state where master_session_id=p_master for share;
   if q.state<>'started' or r.source_kind<>'quest' or r.current_step_key is distinct from e.step_key
      or r.run_phase<>'in_corso' then
     raise exception 'MF_QUEST_ARENA_SOURCE_DRIFT' using errcode='40001';
   end if;
   sc:=mission_factory_owner.quest_scene_v1(p_master,e.step_key);
   select x.value into strict en from jsonb_array_elements(sc->'encounters') x
     where x.value->>'encounter_key'=e.encounter_key;
   if jsonb_typeof(en->'arena_ref')<>'object'
      or coalesce(en->>'arena_catalog_sha256','') !~ '^[0-9a-f]{64}$' then
     raise exception 'MF_QUEST_ARENA_PIN_MISSING' using errcode='55000';
   end if;
   src:=(en->'arena_ref')||jsonb_build_object('catalog_sha256',en->>'arena_catalog_sha256');
 else
   select * into strict b from mission_generic_owner.run_bindings where master_session_id=p_master;
   src:=mission_creation_owner.arena_for_step(p_master,e.step_key);
 end if;
 select * into strict t from combat_spatial.arena_templates
 where template_key=src->>'template_key' and template_version=(src->>'template_version')::integer and status='ready' for share;
 perform 1 from combat_spatial.arena_slots where template_key=t.template_key and template_version=t.template_version order by slot_key for share;
 perform 1 from combat_spatial.arena_objects where template_key=t.template_key and template_version=t.template_version order by object_key for share;
 if src->>'zone_key'<>'arena' or src->>'catalog_sha256' is distinct from combat_panel_private.universal_arena_hash(t.template_key,t.template_version)
 or t.geometry_hash is distinct from combat_spatial.geometry_fingerprint(t.template_key,t.template_version)
 or combat_spatial.template_errors(t.template_key,t.template_version)<>'[]'::jsonb
 then raise exception 'MG_ARENA_FROZEN_CATALOG_DRIFT' using errcode='40001';end if;
 if exists(select 1 from combat_spatial.arena_instances where encounter_id=p_encounter)
 or exists(select 1 from public.combat_v2_declarations d join public.combat_v2_rounds combat_round_row on combat_round_row.id=d.round_id where combat_round_row.session_id=p_encounter)
 then raise exception 'MG_ARENA_ALREADY_BOUND_OR_DECLARED';end if;
 policy:=case when (select is_test from public.locations where id=m.location_id)
 then 'staff_test_no_persistent_resources_v1' else 'master_game_resources_v1' end;
 pid:=mission_ai_service_owner.uuid5(p_encounter,'generic-arena-profile');
 claim:=mission_ai_service_owner.uuid5(p_encounter,'generic-arena-claim');
 iid:=mission_ai_service_owner.uuid5(p_encounter,'generic-arena-instance');
 insert into combat_panel_private.master_panel_sessions(master_session_id,location_id,policy_id)
 values(p_master,m.location_id,policy) on conflict(master_session_id) do nothing;
 if not exists(select 1 from combat_panel_private.master_panel_sessions where master_session_id=p_master and location_id=m.location_id and policy_id=policy)
 then raise exception 'MG_ARENA_PANEL_POLICY_CONFLICT';end if;
 insert into combat_panel_private.master_scene_profiles(id,location_id,label,template_key,template_version,profile_version,geometry_fingerprint,policy_id,visibility_mode,enabled)
 values(pid,m.location_id,case when is_quest then 'Arena Quest' else 'Arena missione' end,t.template_key,t.template_version,1,t.geometry_hash,policy,'participants',true);
 insert into combat_panel_private.master_scene_claims(id,profile_id,profile_version,master_session_id,encounter_id,
 template_key,template_version,authority_principal_id,authority_control_version,geometry_fingerprint,roster_fingerprint,policy_id,visibility_mode)
 values(claim,pid,1,p_master,p_encounter,t.template_key,t.template_version,e.capability_id,m.control_version,
 t.geometry_hash,combat_panel_private.master_roster_fingerprint(p_encounter),policy,'participants');
 insert into combat_spatial.arena_instances(instance_id,master_session_id,encounter_id,binding_id,template_key,template_version,map_version,state,context_source,panel_claim_id)
 values(iid,p_master,p_encounter,null,t.template_key,t.template_version,1,'open','panel_master',claim);
 -- Le opzioni e le collisioni derivano dal catalogo server; nessuna coordinata IA/client.
 if t.contract_version='arena-template/general-v1' then
  planned:=mission_creation_owner.general_plan_positions(t.template_key,t.template_version,
   (select count(*)::integer from public.combat_v2_actors where session_id=p_encounter and state='attivo' and actor_kind='pg'),
   (select count(*)::integer from public.combat_v2_actors where session_id=p_encounter and state='attivo' and actor_kind='png'));
 end if;
 for a in select * from public.combat_v2_actors where session_id=p_encounter and state='attivo' order by actor_kind,id loop
  if t.contract_version='arena-template/general-v1' then
   placement:=planned->placement_index;placement_index:=placement_index+1;
   if placement is null then raise exception 'MG_ARENA_LEGAL_SLOTS_INSUFFICIENT' using errcode='22023';end if;
   radius:=t.actor_radius_m;
   principal:=case when a.actor_kind='pg' then a.controller_user else mission_ai_service_owner.uuid5(a.id,'mission-generic-principal') end;
   insert into combat_panel_private.master_placement_options(claim_id,actor_id,slot_key,x_m,y_m,radius_m)
    values(claim,a.id,placement->>'slot_key',(placement->>'x')::integer,(placement->>'y')::integer,radius);
   insert into combat_spatial.actor_states(instance_id,actor_id,actor_kind,slot_key,controller_principal_id,projection_subject_id,x_m,y_m,footprint_radius_m,body_version,state)
    values(iid,a.id,upper(a.actor_kind),placement->>'slot_key',principal,gen_random_uuid(),(placement->>'x')::integer,(placement->>'y')::integer,radius,1,'active');
   continue;
  end if;
  radius:=t.actor_radius_m;chosen:=false;
  for slot in select * from combat_spatial.arena_slots where template_key=t.template_key and template_version=t.template_version
  and actor_kind=upper(a.actor_kind) order by slot_key loop
   if clan_marionettisti_private.scene_slot_legal(t.template_key,t.template_version,round(slot.x_m),round(slot.y_m),radius)
   and not exists(select 1 from combat_spatial.actor_states z where z.instance_id=iid and
   (z.slot_key=slot.slot_key or combat_spatial.distance_m(z.x_m,z.y_m,round(slot.x_m),round(slot.y_m))<=z.footprint_radius_m+radius)) then
    principal:=case when a.actor_kind='pg' then a.controller_user else mission_ai_service_owner.uuid5(a.id,'mission-generic-principal') end;
    insert into combat_panel_private.master_placement_options(claim_id,actor_id,slot_key,x_m,y_m,radius_m)
    values(claim,a.id,slot.slot_key,round(slot.x_m),round(slot.y_m),radius);
    insert into combat_spatial.actor_states(instance_id,actor_id,actor_kind,slot_key,controller_principal_id,projection_subject_id,x_m,y_m,footprint_radius_m,body_version,state)
    values(iid,a.id,upper(a.actor_kind),slot.slot_key,principal,gen_random_uuid(),round(slot.x_m),round(slot.y_m),radius,1,'active');
    chosen:=true;exit;
   end if;
  end loop;
  if not chosen then raise exception 'MG_ARENA_LEGAL_SLOTS_INSUFFICIENT' using errcode='22023';end if;
 end loop;
 insert into combat_spatial.viewer_grants(instance_id,viewer_principal_id,subject_actor_id,can_view_map,can_view_objects,grant_version)
 select iid,v.controller_principal_id,z.actor_id,true,true,1 from combat_spatial.actor_states z
 cross join (select distinct controller_principal_id from combat_spatial.actor_states where instance_id=iid) v where z.instance_id=iid;
 insert into combat_spatial.object_states(instance_id,object_key,state,state_version)
 select iid,object_key,case when substitutable then 'available' else 'blocked' end,1 from combat_spatial.arena_objects
 where template_key=t.template_key and template_version=t.template_version;
 if not is_quest then
  if not is_quest then
    perform clan_marionettisti_private.bind_mission_companions_v1(p_master,p_encounter,iid,p_request);
  end if;
 end if;
 for a in select * from combat_spatial.actor_states where instance_id=iid loop
  if combat_spatial.path_first_block_t(iid,a.actor_id,a.x_m,a.y_m,a.x_m,a.y_m,null)<1
  then raise exception 'MG_ARENA_FINAL_OCCUPANCY_INVALID' using errcode='22023';end if;
 end loop;
 perform clan_innata_narrative_private.materialize_v1(p_encounter);
 return jsonb_build_object('instance_id',iid,'claim_id',claim,'map_version',1);
end $function$;

CREATE OR REPLACE FUNCTION mission_generic_owner.current_principal()
 RETURNS uuid
 LANGUAGE plpgsql
 STABLE SECURITY DEFINER
 SET search_path TO ''
AS $function$
declare v uuid; n integer;
begin
 if auth.uid() is not null or not public.combat_v2_is_service() then return null; end if;
 -- Fence cheap permit eligibility before any recursive binding fingerprint.
 WITH eligible_permits AS MATERIALIZED(
  SELECT p.principal_id,p.actor_id,p.created_at
  FROM mission_generic_owner.panel_permits p
  JOIN mission_generic_owner.runtime_policy pol ON pol.singleton AND pol.mode<>'off'
  JOIN public.master_v2_sessions m ON m.id=p.master_session_id
  JOIN public.locations l ON l.id=m.location_id
  WHERE p.transaction_id=txid_current() AND p.backend_pid=pg_backend_pid() AND p.consumed_at IS NULL
   AND p.created_at>clock_timestamp()-interval '150 seconds'
   AND (
     pol.mode='all' OR (pol.mode='test' AND l.is_test)
     OR (pol.mode='test' AND NOT l.is_test AND EXISTS(
       SELECT 1
       FROM clan_marionettisti_private.mission_companion_receipts_v1 companion
       JOIN mission_public_owner.session_admissions_v1 admission ON admission.master_session_id=m.id
       WHERE companion.session_id=p.encounter_id AND companion.owner_actor_id=p.actor_id
         AND mission_public_owner.c1266_regia_public_qualification_v1(
               admission.mission_id,admission.release_sha256,false
             )->>'schema_version'='mission-scene-public-qualification/1'
         AND mission_public_owner.launch_provenance_v1(admission.master_session_id) IS NOT NULL
     ))
   )
 ), eligible_actors AS MATERIALIZED(
  SELECT DISTINCT actor_id FROM eligible_permits
 ), verified_principals AS MATERIALIZED(
  SELECT actor_id,mission_generic_owner.actor_principal(actor_id) AS principal_id FROM eligible_actors
 )
 SELECT count(DISTINCT p.principal_id),(array_agg(p.principal_id))[1] INTO n,v
 FROM eligible_permits p JOIN verified_principals verified ON verified.actor_id=p.actor_id
 WHERE p.principal_id=verified.principal_id
  AND p.created_at>clock_timestamp()-interval '150 seconds';
 if n>1 then raise exception 'MG_AMBIGUOUS_PANEL_AUTHORITY' using errcode='42501'; end if;
 return v;
end $function$
;

CREATE FUNCTION mission_generic_owner.mission_companion_defense_owner_v1(p_encounter uuid,p_target uuid)
RETURNS uuid
LANGUAGE sql STABLE SECURITY DEFINER SET search_path TO ''
AS $function$
  SELECT l.owner_actor_id
  FROM clan_marionettisti_private.links l
  JOIN public.combat_v2_actors body ON body.id=l.companion_actor_id
    AND body.session_id=p_encounter AND body.state='attivo'
  JOIN public.combat_v2_actors owner ON owner.id=l.owner_actor_id
    AND owner.session_id=p_encounter AND owner.actor_kind='png' AND owner.state='attivo'
  WHERE body.id=p_target
    AND clan_marionettisti_private.mission_companion_valid(p_encounter,owner.id,body.id)
$function$;
REVOKE ALL ON FUNCTION mission_generic_owner.mission_companion_defense_owner_v1(uuid,uuid) FROM PUBLIC,anon,authenticated,service_role;

CREATE OR REPLACE FUNCTION mission_generic_owner.unified_advance(p_session uuid, p_user uuid, p_request uuid)
 RETURNS jsonb
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO ''
AS $function$
declare ub mission_generic_owner.unified_batches;ee mission_generic_owner.encounters;rr public.combat_v2_rounds;rw mission_generic_owner.unified_round_windows;
ca uuid;res jsonb;bid uuid;newreport uuid;newround uuid;oldround public.combat_v2_rounds;terminal_route jsonb;nextctx jsonb;
begin
 
select candidate.* into ub from mission_generic_owner.unified_batches candidate
where candidate.master_session_id=p_session and candidate.state<>'published'
  and not mission_generic_owner.role_source_released_v4(candidate.source_window_id)
for update of candidate;

 if ub.state='needs_review' then return mission_generic_owner.progress_result(p_session,p_user,'needs_review');end if;
 if ub.id is not null then
  -- Only native protected Staff or admitted public mission authority may prepare a private successor.
  -- The round-init trigger binds the PNG cohort to this same batch; player
  -- commands and projections remain behind unified_round_windows.publication_id.
  if ub.state='preparing' and ub.entry_side='png' and ub.next_round_id is null
    and ub.source_window_id is null and ub.source_report_id is not null
    and ub.route is null and (exists(
      select 1 from mission_generic_owner.flow_staff_sessions fs
      join public.master_v2_sessions ms on ms.id=fs.master_session_id
      join public.locations loc on loc.id=ms.location_id
      where fs.master_session_id=p_session and fs.enabled
        and ms.owner_kind='ai_service' and ms.closed_at is null and loc.is_test) OR mission_public_owner.ai_resource_scope_v1(p_session,ub.encounter_id))
  then
    select * into strict oldround from public.combat_v2_rounds
      where id=ub.source_round_id and session_id=ub.encounter_id
        and state='risolto' for update;
    if not exists(select 1 from public.combat_v2_round_reports rep
        where rep.id=ub.source_report_id and rep.round_id=oldround.id
          and rep.narration_state='attesa')
      or exists(select 1 from public.combat_v2_rounds successor
        where successor.session_id=oldround.session_id
          and successor.round_no=oldround.round_no+1)
    then raise exception 'MUF_PRIVATE_SUCCESSOR_DRIFT' using errcode='40001';end if;
    update public.combat_v2_rounds
      set staff_private_successor_source=true
      where id=oldround.id and state='risolto'
        and staff_private_successor_source=false;
    if not found then raise exception 'MUF_PRIVATE_SOURCE_MARKER_DRIFT' using errcode='40001';end if;
    insert into public.combat_v2_rounds(session_id,round_no,evaluation_mode)
      values(oldround.session_id,oldround.round_no+1,oldround.evaluation_mode)
      returning id into newround;
    update mission_generic_owner.unified_batches
      set next_round_id=newround where id=ub.id and next_round_id is null;
    if not found or not exists(select 1 from mission_generic_owner.unified_round_windows private_window
        where private_window.round_id=newround and private_window.batch_id=ub.id and private_window.side='png'
          and private_window.publication_id is null)
    then raise exception 'MUF_PRIVATE_SUCCESSOR_BINDING' using errcode='40001';end if;
    select * into strict ub from mission_generic_owner.unified_batches where id=ub.id;
  end if;
  if ub.next_round_id is not null and ub.entry_side='png' then
   select aa into ca from mission_generic_owner.unified_round_windows ww cross join unnest(ww.expected_actor_ids) aa
   where ww.round_id=ub.next_round_id and not exists(select 1 from public.combat_v2_declarations dd where dd.round_id=ww.round_id
   and dd.actor_id=aa and exists(select 1 from combat_panel_private.actor_turns mt where mt.round_id=ww.round_id and mt.actor_id=aa and mt.main_declaration_id=dd.id)) order by aa limit 1;
   if ca is not null then res:=mission_generic_owner.enqueue_choice(p_session,ub.encounter_id,ca);return mission_generic_owner.progress_result(p_session,p_user,'choice_ready');end if;
  end if;
  if ub.next_round_id is not null and ub.entry_side='png' and not exists(select 1 from public.combat_v2_attack_targets at where at.round_id=ub.next_round_id) then
   if ub.source_window_id is not null and ub.composition_kind='entry_png' and ub.decision->>'schema_version'='mission-director-proposal/2'
   then raise exception 'MNE_ENTRY_OFFENSE_MISSING' using errcode='55000';end if;
   select * into strict oldround from public.combat_v2_rounds where id=ub.next_round_id;
   insert into mission_generic_owner.unified_preparation_permits(round_id,batch_id,transaction_id,backend_pid) values(oldround.id,ub.id,txid_current(),pg_backend_pid());
   res:=public.combat_v2_round_resolve(oldround.id,mission_ai_service_owner.uuid5(oldround.id,'generic-resolve'));
   newreport:=(res#>>'{data,report_id}')::uuid;
   if newreport is null then raise exception 'MUF_NONOFFENSIVE_REPORT_MISSING';end if;
   if ub.source_report_id is null then
    update mission_generic_owner.unified_batches set source_report_id=newreport,source_round_id=oldround.id,entry_side='pg',composition_kind='combat_resolved_no_pending' where id=ub.id;
   else
    update mission_generic_owner.unified_batches set secondary_report_id=newreport,entry_side='pg',composition_kind='combat_resolved_no_pending' where id=ub.id;
   end if;
   perform mission_generic_owner.apply_surrender_if_due(p_session,oldround.id);
   terminal_route:=mission_generic_owner.unified_terminal_route(p_session,oldround.session_id);
   if terminal_route is not null then
    nextctx:=mission_generic_owner.narrative_context(p_session,terminal_route->>'to_step_key',ub.id,clock_timestamp(),
      jsonb_build_object('passaggio_preparato',terminal_route->>'label',
       'accordo_pacifico_attestato',case when terminal_route->>'outcome'='peaceful'
         then terminal_route->>'agreement_summary' else null end,'nota_autorita','La rotta segue gli esiti del server; nessuna azione ulteriore dei PG è attestata.'));
    update mission_generic_owner.unified_batches set route=terminal_route,context=nextctx,composition_kind='combat_exit',entry_side=null,next_round_id=null where id=ub.id;
   else
    update mission_generic_owner.unified_batches set next_round_id=null where id=ub.id;
   end if;
  end if;
  if ub.entry_side='png' and ub.next_round_id is not null
    and ub.source_report_id is not null and ub.source_window_id is null
    and exists(select 1 from public.combat_v2_attack_targets target
      where target.round_id=ub.next_round_id)
  then
    update mission_generic_owner.unified_batches
      set composition_kind='combat_resolved_then_png_offensive'
      where id=ub.id and state='preparing';
    if not found then raise exception 'MUF_OFFENSE_BATCH_STATE' using errcode='40001';end if;
  end if;
  res:=mission_generic_owner.unified_enqueue_writer(ub.id);return mission_generic_owner.progress_result(p_session,p_user,'narration_ready');
 end if;
 select ge.* into ee from mission_generic_owner.encounters ge join public.combat_v2_sessions cs on cs.id=ge.encounter_id
 where ge.master_session_id=p_session and cs.closed_at is null;
 if ee.encounter_id is null then
  res:=mission_generic_owner.unified_enqueue_director(p_session);return mission_generic_owner.progress_result(p_session,p_user,res->>'state');
 end if;
 select * into strict rr from public.combat_v2_rounds where session_id=ee.encounter_id order by round_no desc limit 1 for update;
 select * into rw from mission_generic_owner.unified_round_windows where round_id=rr.id;
 if rw.round_id is null then return null;end if; -- Existing Generic encounters keep their already opened cadence.
 if rr.state='risolto' then bid:=mission_generic_owner.unified_prepare_resolved(p_session,rr.id);return mission_generic_owner.unified_advance(p_session,p_user,p_request);end if;
 if rw.publication_id is null then raise exception 'MUF_WINDOW_WITHOUT_PUBLICATION_BATCH';end if;
 if rr.phase='raccolta_azioni' then
  if exists(select 1 from unnest(rw.expected_actor_ids) ai join public.combat_v2_actors aa on aa.id=ai where aa.actor_kind='pg'
   and not exists(select 1 from public.combat_v2_declarations dd where dd.round_id=rr.id and dd.actor_id=ai and exists(select 1 from combat_panel_private.actor_turns mt where mt.round_id=rr.id and mt.actor_id=ai and mt.main_declaration_id=dd.id)))
  then return mission_generic_owner.progress_result(p_session,p_user,'waiting_player');end if;
  select ai into ca from unnest(rw.expected_actor_ids) ai join public.combat_v2_actors aa on aa.id=ai where aa.actor_kind='png'
   and not exists(select 1 from public.combat_v2_declarations dd where dd.round_id=rr.id and dd.actor_id=ai and exists(select 1 from combat_panel_private.actor_turns mt where mt.round_id=rr.id and mt.actor_id=ai and mt.main_declaration_id=dd.id)) order by ai limit 1;
  if ca is not null then res:=mission_generic_owner.enqueue_choice(p_session,ee.encounter_id,ca);return mission_generic_owner.progress_result(p_session,p_user,'choice_ready');end if;
 end if;
 if rr.phase='raccolta_difese' then
  select aa.id into ca from public.combat_v2_actors aa where aa.session_id=ee.encounter_id and aa.actor_kind='png' and aa.state='attivo'
   and exists(select 1 from public.combat_v2_attack_targets tt where tt.round_id=rr.id and (tt.target_actor_id=aa.id
      or mission_generic_owner.mission_companion_defense_owner_v1(ee.encounter_id,tt.target_actor_id)=aa.id)
    and not exists(select 1 from public.combat_v2_defense_coverages cc where cc.attack_target_id=tt.id)) order by aa.id limit 1;
  if ca is not null then res:=mission_generic_owner.enqueue_choice(p_session,ee.encounter_id,ca);return mission_generic_owner.progress_result(p_session,p_user,'choice_ready');end if;
 end if;
 if (select count(*) from combat_panel_private.actor_turns mt where mt.round_id=rr.id and mt.actor_id=any(rw.expected_actor_ids) and mt.main_declaration_id is not null)<>cardinality(rw.expected_actor_ids)
 then return mission_generic_owner.progress_result(p_session,p_user,'waiting_player');end if;
 if not combat_v2_multitarget_internal.round_complete(rr.id) then return mission_generic_owner.progress_result(p_session,p_user,'waiting_defense');end if;
 if rr.evaluation_mode<>'neutra' and exists(select 1 from public.combat_v2_declarations dd join public.combat_v2_actors aa on aa.id=dd.actor_id
 where dd.round_id=rr.id and aa.actor_kind='pg' and dd.kind in('attacco','difesa') and not exists(select 1 from public.combat_v2_ratings rt where rt.declaration_id=dd.id and rt.is_active))
 then return mission_generic_owner.progress_result(p_session,p_user,'waiting_quality');end if;
 if (select ll.is_test from public.locations ll join public.master_v2_sessions mm on mm.location_id=ll.id where mm.id=p_session)
 and (public.combat_v2_values_written(ee.encounter_id) or not combat_panel_private.uses_simulated_pools(ee.encounter_id)) then raise exception 'MUF_SIMULATION_SCOPE' using errcode='42501';end if;
 res:=public.combat_v2_round_resolve(rr.id,mission_ai_service_owner.uuid5(rr.id,'generic-resolve'));
 bid:=mission_generic_owner.unified_prepare_resolved(p_session,rr.id);
 return mission_generic_owner.unified_advance(p_session,p_user,p_request);
end $function$;

CREATE OR REPLACE FUNCTION mission_generic_owner.unified_assert_command(p_round uuid, p_operation text)
 RETURNS void
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO ''
AS $function$
DECLARE w mission_generic_owner.unified_round_windows%ROWTYPE; staging boolean; actor uuid; human_stage boolean;
 scene56_receipt jsonb;
BEGIN
 IF p_operation IN('declare','defend') AND EXISTS(SELECT 1 FROM public.combat_v2_rounds rr
  JOIN public.combat_v2_sessions cs ON cs.id=rr.session_id
  JOIN mission_narrative_internal.scene_runtime_v1 cache ON cache.master_session_id=cs.master_session_id AND cache.is_active
  WHERE rr.id=p_round AND (cache.turn_owner='fato' OR cache.mode<>'combat'))
 THEN RAISE EXCEPTION 'SCENE56_FATO_OWNS_TURN' USING ERRCODE='42501';END IF;
 IF NOT EXISTS(SELECT 1 FROM mission_generic_owner.unified_round_windows uw WHERE uw.round_id=p_round) THEN
  scene56_receipt:=mission_narrative_internal.scene_opening_receipt_v1(p_round);
  IF scene56_receipt IS NOT NULL THEN
   IF p_operation NOT IN('declare','defend','resolve') THEN RAISE EXCEPTION 'MUF_COMMAND_INVALID' USING ERRCODE='42501';END IF;
   IF p_operation='resolve' AND auth.uid() IS NULL AND public.combat_v2_is_service() THEN RETURN;END IF;
   -- Only a genuine Native PNG defense commit may pass without a player JWT.
   -- The permit is private, unconsumed and local to this transaction/backend.
   IF p_operation='defend' AND auth.uid() IS NULL AND public.combat_v2_is_service() AND EXISTS(
    SELECT 1 FROM mission_generic_owner.panel_permits pp
    JOIN mission_generic_owner.panel_choices pc ON pc.work_id=pp.work_id AND pc.actor_id=pp.actor_id
     AND pc.request_key=pp.request_key AND pc.master_session_id=pp.master_session_id AND pc.encounter_id=pp.encounter_id
     AND pc.principal_id=pp.principal_id
    JOIN mission_generic_owner.work_items wi ON wi.id=pp.work_id AND wi.master_session_id=pp.master_session_id
     AND wi.encounter_id=pp.encounter_id AND wi.kind='choice' AND wi.state='provider_started'
     AND wi.payload->>'schema_version'='mission-generic-choice/1' AND wi.payload->>'round_id'=p_round::text
     AND wi.payload->>'actor_id'=pp.actor_id::text AND wi.payload->>'command_request_key'=pp.request_key::text
     AND wi.payload->'legal_options'=pc.legal_options AND wi.payload->>'context_version'=pc.context_version::text
    JOIN mission_generic_owner.encounters source_enc ON source_enc.encounter_id=pp.encounter_id AND source_enc.master_session_id=pp.master_session_id
    JOIN mission_ai_service_owner.capabilities cap ON cap.id=source_enc.capability_id AND cap.master_session_id=pp.master_session_id
     AND cap.state='active'
     AND wi.payload->>'capability_id'=pc.id::text
    JOIN public.combat_v2_rounds rr ON rr.id=p_round AND rr.session_id=pp.encounter_id AND rr.phase='raccolta_difese'
    JOIN public.combat_v2_actors npc ON npc.id=pp.actor_id AND npc.session_id=rr.session_id
     AND npc.actor_kind='png' AND npc.state='attivo' AND npc.companion_id IS NULL AND npc.controller_user IS NULL
    WHERE pp.encounter_id=(scene56_receipt->>'encounter_id')::uuid
     AND EXISTS(SELECT 1 FROM mission_narrative_internal.scene_runtime_v1 cache
      WHERE cache.id=(scene56_receipt->>'scene_id')::uuid AND cache.master_session_id=pp.master_session_id
       AND cache.mode='combat' AND cache.turn_owner='combat' AND cache.is_active)
     AND pp.transaction_id=txid_current() AND pp.backend_pid=pg_backend_pid() AND pp.consumed_at IS NULL AND pp.operation='commit'
     AND pp.created_at>clock_timestamp()-interval '150 seconds'
     AND pc.consumed_at IS NULL AND pc.expires_at>clock_timestamp() AND pc.controller_version=npc.controller_version
     AND pc.options_sha256=public.combat_v2_sha256(pc.legal_options)
     AND pc.legal_options#>>'{context,round_id}'=p_round::text
     AND pc.legal_options#>>'{context,activity_id}'=pp.encounter_id::text
     AND pc.legal_options#>>'{context,version}'=pc.context_version::text
     AND pc.legal_options#>>'{viewer,command_actor_id}'=npc.id::text
     AND pp.principal_id=mission_generic_owner.current_principal()
     AND pp.principal_id=mission_generic_owner.actor_principal(npc.id)
     AND EXISTS(SELECT 1 FROM public.combat_v2_attack_targets target
      JOIN public.combat_v2_declarations attack ON attack.id=target.attack_declaration_id AND attack.round_id=target.round_id
      WHERE target.round_id=rr.id AND target.state='attesa_difesa'
       AND (target.target_actor_id=npc.id OR mission_generic_owner.mission_companion_defense_owner_v1(rr.session_id,target.target_actor_id)=npc.id)
       AND attack.kind='attacco' AND attack.state NOT IN('annullata','superflua')
       AND NOT combat_panel_private.multiplication_no_defense(target.id)))
   THEN RETURN;END IF;

   IF auth.uid() IS NULL OR NOT EXISTS(SELECT 1 FROM public.combat_v2_actors a JOIN public.combat_v2_rounds rr ON rr.session_id=a.session_id
    JOIN public.characters ch ON ch.id=a.character_id AND ch.user_id=a.controller_user
    WHERE rr.id=p_round AND a.actor_kind='pg' AND a.state='attivo' AND a.companion_id IS NULL AND a.controller_user=auth.uid())
   THEN RAISE EXCEPTION 'REGIA_ACCESS_DENIED' USING ERRCODE='42501';END IF;
   RETURN;
  END IF;
 END IF;
 SELECT * INTO w FROM mission_generic_owner.unified_round_windows WHERE round_id=p_round;
 IF w.round_id IS NULL THEN
  IF EXISTS(SELECT 1 FROM mission_generic_owner.regia_human_admissions_v1 adm
    JOIN public.combat_v2_rounds rr ON rr.session_id=adm.encounter_id
    WHERE rr.id=p_round) THEN RAISE EXCEPTION 'REGIA_TURN_AUTHORITY_REQUIRED' USING ERRCODE='42501'; END IF;
  RETURN;
 END IF;
 human_stage:=EXISTS(SELECT 1 FROM mission_generic_owner.regia_human_stage_permits_v1 hp
  JOIN mission_generic_owner.regia_human_windows_v1 hw ON hw.next_round_id=hp.round_id
  WHERE hp.round_id=p_round AND hp.master_session_id=w.master_session_id
   AND hp.principal_id=auth.uid() AND hp.transaction_id=txid_current()
   AND hp.backend_pid=pg_backend_pid());
 staging:=mission_generic_owner.unified_service_staging(p_round) OR human_stage;
 PERFORM mission_generic_owner.assert_runtime(w.master_session_id);
 IF p_operation='resolve' THEN
  IF w.publication_id IS NOT NULL THEN RETURN; END IF;
  IF auth.uid() IS NULL AND public.combat_v2_is_service() AND w.side='png' AND EXISTS(
   SELECT 1 FROM mission_generic_owner.unified_preparation_permits pp
   JOIN mission_generic_owner.unified_batches ub ON ub.id=pp.batch_id AND ub.id=w.batch_id
   JOIN public.combat_v2_rounds rr ON rr.id=pp.round_id AND rr.session_id=ub.encounter_id
   WHERE pp.round_id=p_round AND pp.transaction_id=txid_current() AND pp.backend_pid=pg_backend_pid()
   AND ub.master_session_id=w.master_session_id AND ub.state='preparing'
   AND NOT EXISTS(SELECT 1 FROM public.combat_v2_attack_targets atg WHERE atg.round_id=p_round)
   AND NOT EXISTS(SELECT 1 FROM unnest(w.expected_actor_ids) expected(id) WHERE NOT EXISTS(
    SELECT 1 FROM combat_panel_private.actor_turns atn JOIN public.combat_v2_declarations dd ON dd.id=atn.main_declaration_id
    WHERE atn.round_id=p_round AND atn.actor_id=expected.id AND dd.round_id=p_round AND dd.actor_id=expected.id))) THEN RETURN; END IF;
  RAISE EXCEPTION 'MUF_PUBLICATION_PENDING' USING ERRCODE='42501';
 END IF;
 IF w.publication_id IS NULL AND NOT staging THEN RAISE EXCEPTION 'MUF_PUBLICATION_PENDING' USING ERRCODE='42501'; END IF;
 IF p_operation NOT IN('declare','defend') THEN RAISE EXCEPTION 'MUF_COMMAND_INVALID' USING ERRCODE='42501'; END IF;
 IF staging AND human_stage THEN
  SELECT hp.actor_id INTO STRICT actor FROM mission_generic_owner.regia_human_stage_permits_v1 hp
   WHERE hp.round_id=p_round AND hp.master_session_id=w.master_session_id
    AND hp.principal_id=auth.uid() AND hp.transaction_id=txid_current()
    AND hp.backend_pid=pg_backend_pid() ORDER BY hp.id DESC LIMIT 1;
 ELSIF staging THEN
  SELECT pp.actor_id INTO STRICT actor FROM mission_generic_owner.panel_permits pp
  JOIN mission_generic_owner.panel_choices pc ON pc.work_id=pp.work_id AND pc.actor_id=pp.actor_id AND pc.request_key=pp.request_key
  JOIN mission_generic_owner.work_items wi ON wi.id=pp.work_id AND wi.master_session_id=pp.master_session_id
  JOIN public.combat_v2_rounds rr ON rr.id=p_round AND rr.session_id=pp.encounter_id
  WHERE pp.transaction_id=txid_current() AND pp.backend_pid=pg_backend_pid() AND pp.consumed_at IS NULL
  AND pp.operation='commit' AND pp.principal_id=mission_generic_owner.current_principal()
  AND wi.kind='choice' AND pc.consumed_at IS NULL
  AND (wi.state='provider_started' OR (wi.state='failed' AND EXISTS (
    SELECT 1 FROM mission_generic_owner.cached_choice_recovery_permits recovery
    WHERE recovery.work_id=wi.id AND recovery.choice_id=pc.id
      AND recovery.master_session_id=w.master_session_id AND recovery.round_id=p_round
      AND recovery.transaction_id=txid_current() AND recovery.backend_pid=pg_backend_pid()
      AND recovery.consumed_at IS NULL)));
 ELSE
  SELECT a.id INTO STRICT actor FROM public.combat_v2_actors a JOIN public.combat_v2_rounds rr ON rr.session_id=a.session_id
  WHERE rr.id=p_round AND a.actor_kind='pg' AND a.companion_id IS NULL AND a.state='attivo'
  AND a.controller_user=auth.uid();
 END IF;
 IF p_operation='declare' AND NOT actor=ANY(w.expected_actor_ids) THEN RAISE EXCEPTION 'MUF_COHORT_NOT_ACTIVE' USING ERRCODE='42501'; END IF;
 IF w.publication_id IS NULL AND (w.side<>'png' OR p_operation<>'declare') THEN RAISE EXCEPTION 'MUF_STAGING_OPERATION_INVALID' USING ERRCODE='42501'; END IF;
END $function$;

CREATE OR REPLACE FUNCTION mission_generic_owner.progress_step(p_session uuid, p_user uuid, p_request uuid)
 RETURNS jsonb
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO ''
AS $function$
declare m public.master_v2_sessions;r public.mission_run_state;e mission_generic_owner.encounters;
 s public.combat_v2_sessions;roundrow public.combat_v2_rounds;rep public.combat_v2_round_reports;
 count28 uuid;sc jsonb;spec jsonb;settings jsonb;term jsonb;cap uuid;actor uuid;res jsonb;n integer;pending jsonb;c7_budget jsonb;c21_owned boolean;w9_defense boolean;
begin
 perform mission_ai_board_owner.service_only();
 -- C9: freeze policy DML through proof, Native reserve and authorization.
 LOCK TABLE mission_narrative_internal.runtime_policy IN SHARE MODE;
 perform 1 from public.locations where id=(select location_id from mission_factory_owner.quest_run_sources where session_id=p_session) for update;
 if p_request is null then raise exception 'MGP_REQUEST_REQUIRED';end if;
 perform mission_generic_owner.dispatch_user(p_session,p_user);
 perform public.master_v2_lock_scope(p_session);
 select * into strict m from public.master_v2_sessions where id=p_session for update;
 perform mission_generic_owner.assert_runtime(p_session);
 select * into strict r from public.mission_run_state where master_session_id=p_session for update;
 if m.closed_at is not null then return jsonb_build_object('schema_version','mission-generic-progress/1','master_session_id',p_session,'state','closed','dispatch',null);end if;
 c21_owned:=(EXISTS(SELECT 1 FROM mission_public_owner.work_contracts_v1 sticky_wc
 WHERE sticky_wc.master_session_id=p_session AND sticky_wc.scope='staff_mission'
 AND sticky_wc.contract_sha256=public.combat_v2_sha256(sticky_wc.contract)
 AND sticky_wc.contract->>'schema_version'='mission-narrative-admission/3'
 AND sticky_wc.contract->'features' ? 'execution_authority_v1'
 AND (sticky_wc.contract#>>'{source_attestation,execution_authority,schema_version}'='c1266-work-execution-attestation/1' OR ((mission_generic_owner.c1266_historical_work_v1(sticky_wc.work_id)->>'schema_version'='c1266-work-execution-attestation/2') AND sticky_wc.contract#>'{source_attestation,execution_authority}'=mission_generic_owner.c1266_historical_work_v1(sticky_wc.work_id)))
 AND sticky_wc.contract#>>'{source_attestation,execution_authority,execution_context}'='staff_mission'
 AND sticky_wc.contract#>>'{source_attestation,execution_authority,admission,kind}'='staff_finite'
 AND sticky_wc.contract#>>'{source_attestation,execution_authority,admission,resource_scope}'='staff_simulation'
 AND (sticky_wc.contract#>>'{source_attestation,execution_authority,source_scope,mission_id}'='5878822d-dc03-4ac2-ad0b-1547f0ab3fc0' OR ((mission_generic_owner.c1266_historical_work_v1(sticky_wc.work_id)->>'schema_version'='c1266-work-execution-attestation/2') AND sticky_wc.contract#>'{source_attestation,execution_authority}'=mission_generic_owner.c1266_historical_work_v1(sticky_wc.work_id)))
 AND sticky_wc.contract#>>'{source_attestation,execution_authority,release_sha256}'=sticky_wc.release_sha256
 AND sticky_wc.contract#>>'{source_attestation,execution_authority,binding_sha256}'=sticky_wc.definition_sha256) OR EXISTS(SELECT 1 FROM mission_generic_owner.simulation_sources ss21
 JOIN mission_generic_owner.board_starts bs21 ON bs21.request_key=ss21.request_key
 JOIN mission_generic_owner.start_claims sc22 ON sc22.session_id=bs21.master_session_id
 JOIN mission_generic_owner.run_bindings rb21 ON rb21.master_session_id=bs21.master_session_id
 JOIN public.master_v2_sessions ms21 ON ms21.id=bs21.master_session_id
  AND ms21.mission_id=ss21.carrier_mission_id
 WHERE NOT EXISTS(SELECT 1 FROM mission_generic_owner.manual_staff_admissions_v1 manual_source WHERE manual_source.master_session_id=bs21.master_session_id) AND bs21.master_session_id=p_session
 AND ms21.owner_kind='ai_service' AND ms21.master_user IS NULL
 AND ms21.location_id='0b85f354-9cdb-47e1-baf9-3d266bb7e06b'::uuid
 AND (ss21.source_mission_id='5878822d-dc03-4ac2-ad0b-1547f0ab3fc0'::uuid OR (mission_generic_owner.c1266_staff_source_scope_v1(bs21.master_session_id) IS NOT NULL AND ss21.source_mission_id::text=mission_generic_owner.c1266_staff_source_scope_v1(bs21.master_session_id)#>>'{source_scope,mission_id}'))
 AND sc22.state='bound' AND sc22.simulation
 AND sc22.mission_id=ms21.mission_id AND sc22.location_id=ms21.location_id
 AND sc22.request_key=bs21.request_key
 AND bs21.simulation AND bs21.snapshot->'simulation'='true'::jsonb
 AND bs21.snapshot_sha256=mission_internal.fingerprint(bs21.snapshot)
 AND bs21.snapshot->>'schema_version'='mission-generic-opening-source/1'
 AND bs21.snapshot->>'mission_id'=ss21.carrier_mission_id::text
 AND bs21.snapshot->>'location_id'='0b85f354-9cdb-47e1-baf9-3d266bb7e06b'
 AND rb21.snapshot_sha256=mission_internal.fingerprint(rb21.snapshot)
 AND rb21.snapshot->>'schema_version'='mission-generic-run/1'));
 c7_budget:=mission_generic_owner.c7_run_budget_v1(p_session,
 CASE WHEN c21_owned THEN false ELSE
 not exists(select 1 from mission_generic_owner.work_items pending_work where pending_work.master_session_id=p_session
 and pending_work.state in('claimed','authorized','provider_started')) END,null);
 if c7_budget->>'allowed'='false' then
  IF c21_owned THEN INSERT INTO public.mission_run_audit(master_session_id,event_code,metadata) VALUES(p_session,'C1266_CAMPAIGN_PROVIDER_STOP',jsonb_build_object('reason_code',c7_budget->>'reason_code','stop_causes',c7_budget->'stop_causes','boundary','progress'));END IF;
  perform mission_generic_owner.c7_run_budget_stop_v1(p_session);
  return jsonb_build_object('schema_version','mission-generic-progress/1','master_session_id',p_session,'state','paused','dispatch',null,'reason_code','MGPG_C7_RUN_BUDGET_STOP');
 end if;
 select id into strict cap from mission_ai_service_owner.capabilities where master_session_id=p_session and state='active';
 FOR count28 IN SELECT id FROM mission_generic_owner.work_items WHERE master_session_id=p_session
  AND kind='director' AND payload->>'schema_version'='mission-native-peaceful-assessment/1'
  AND state='claimed' AND lease_expires_at<=clock_timestamp() LOOP
  PERFORM mission_generic_owner.count_overflow_terminal_v1(count28,p_user);
 END LOOP;
 pending:=public.mission_generic_dispatch_next_v1(p_session,p_user);
 if pending->'request' is not null then return mission_generic_owner.progress_result(p_session,p_user,'work_pending');end if;
 if m.stato='preparazione' and r.run_phase='preparazione' and exists(select 1 from mission_generic_owner.work_items
 where master_session_id=p_session and state='failed' and payload ? 'opening_start_receipt_id') then
  res:=mission_generic_owner.abort_opening(p_session,p_user,mission_ai_service_owner.uuid5(p_session,'generic-abort-opening'));
  return jsonb_build_object('schema_version','mission-generic-progress/1','master_session_id',p_session,'state','aborted','dispatch',null);
 end if;
 if m.stato<>'in_corso' or m.suspended_at is not null or r.run_phase<>'in_corso'
 then return mission_generic_owner.progress_result(p_session,p_user,'paused');end if;
 perform mission_generic_owner.assert_combat_scope(p_session,cap);
 SELECT cs.* INTO s FROM public.combat_v2_sessions cs WHERE cs.master_session_id=p_session AND cs.closed_at IS NULL AND cs.state='in_corso';
 IF FOUND AND EXISTS(SELECT 1 FROM mission_narrative_internal.scene_runtime_v1 np WHERE np.master_session_id=p_session AND np.is_active AND np.mode='combat') THEN
  SELECT * INTO STRICT roundrow FROM public.combat_v2_rounds WHERE session_id=s.id ORDER BY round_no DESC LIMIT 1 FOR UPDATE;
 IF mission_narrative_internal.scene_native_round_bound_v1(p_session,roundrow.id)
  AND roundrow.state='raccolta_azioni' AND roundrow.round_no>1
  AND NOT EXISTS(SELECT 1 FROM public.combat_v2_declarations WHERE round_id=roundrow.id)
  AND EXISTS(SELECT 1 FROM public.combat_v2_rounds prev JOIN public.combat_v2_round_reports pr ON pr.id=prev.report_id
   WHERE prev.session_id=s.id AND prev.round_no=roundrow.round_no-1 AND prev.state='narrato' AND pr.narration_state='pubblicata'
   AND NOT EXISTS(SELECT 1 FROM public.combat_v2_declarations dd WHERE dd.round_id=prev.id AND dd.kind IN('attacco','difesa')))
 THEN
  res:=mission_narrative_internal.native_peaceful_prepare_v1(p_session,roundrow.id);
  RETURN jsonb_build_object('schema_version','mission-generic-progress/1','master_session_id',p_session,'state','work_queued','dispatch',null);
 END IF;
 END IF;

 if exists(select 1 from mission_generic_owner.work_items wi where wi.master_session_id=p_session
 and wi.step_key=r.current_step_key and wi.run_control_version=r.control_version and wi.state='failed'
 and not (wi.kind='narration' AND wi.result->>'schema_version'='c1266-count-terminal-failure/1'
  AND wi.result->>'failure_code'='MISSION_INPUT_COUNT_OVERFLOW' AND EXISTS(
   SELECT 1 FROM LATERAL(SELECT mission_generic_owner.writer_count_reissue_proof_v1(wi.id,NULL) proof) solved49
   WHERE solved49.proof->>'schema_version'='mission-writer-count-reissue-proof/1'
    AND solved49.proof->>'old_work_id'=wi.id::text AND solved49.proof->>'master_session_id'=wi.master_session_id::text
    AND solved49.proof->'published'='true'::jsonb))
 and not (wi.kind='director' AND wi.result->'failure_codes' ? 'MISSION_PROVIDER_OUTPUT_RETENTION_FAILED'
  AND mission_generic_owner.retained_director_adoption_v1(wi.id,true) IS NOT NULL)
 and not (wi.kind='narration' AND wi.payload->>'schema_version'='mission-generic-narration/2'
  AND wi.payload->>'mode'='combat' AND EXISTS(SELECT 1 FROM LATERAL(
   SELECT mission_generic_owner.native_combat_writer_reissue_proof_v1(wi.id,p_user) proof) resolved_native
   WHERE resolved_native.proof->>'published'='true'))
 and not (wi.kind='narration' AND wi.payload->>'schema_version'='mission-generic-narration/3'
  AND wi.result->>'schema_version'='mission-generic-pre-provider-failure/1'
  AND wi.result->>'failure_code'='request_validation_failed'
  AND wi.result->>'provider_calls'='0' AND wi.result->>'charged_cost_usd'='0'
  AND EXISTS(
   SELECT 1
   FROM LATERAL(SELECT mission_generic_owner.combat_narration_reissue_proof_v1(wi.id,p_user) x) native_reissue
   JOIN mission_generic_owner.work_items successor ON successor.id=(native_reissue.x->>'successor_work_id')::uuid
     AND successor.master_session_id=wi.master_session_id AND successor.authority_receipt_id=wi.authority_receipt_id
     AND successor.kind='narration' AND successor.state='completed' AND successor.finalized_at IS NOT NULL
     AND successor.receipt_id IS NOT NULL AND successor.result_sha256 ~ '^[0-9a-f]{64}$'
     AND successor.payload=wi.payload AND successor.payload_sha256=wi.payload_sha256
   JOIN mission_narrative_internal.dispatch_receipts native_receipt ON native_receipt.id=successor.dispatch_receipt_id
     AND native_receipt.master_session_id=p_session AND native_receipt.authority_receipt_id=successor.id
     AND native_receipt.request_key=successor.request_key AND native_receipt.status='success' AND native_receipt.finalized_at IS NOT NULL
     AND native_receipt.request_fingerprint=mission_internal.fingerprint(jsonb_build_object('schema_version','mission-generic-request/1','master_session_id',successor.master_session_id,'event_id',successor.event_id,'request_key',successor.request_key,'expected_revision',successor.revision))
     AND native_receipt.envelope_sha256=public.combat_v2_sha256(native_receipt.envelope)
     AND native_receipt.authority_sha256=native_receipt.envelope_sha256
   JOIN mission_generic_owner.unified_batches native_batch ON native_batch.id=successor.authority_receipt_id
     AND native_batch.master_session_id=p_session AND native_batch.writer_work_id=successor.id
     AND native_batch.retired_at IS NULL AND native_batch.state='published' AND native_batch.published_at IS NOT NULL
     AND native_batch.message_id=successor.message_id AND native_batch.source_window_id IS NULL
     AND native_batch.payload=successor.payload AND native_batch.payload_sha256=successor.payload_sha256
   JOIN public.combat_v2_round_reports native_report ON native_report.id=native_batch.source_report_id
     AND native_report.round_id=native_batch.source_round_id
     AND native_report.narration_state='pubblicata' AND native_report.message_id=successor.message_id
     AND native_report.values_written IS FALSE
     AND native_report.mechanics_sha256=public.combat_v2_sha256(native_report.mechanics)
   JOIN public.combat_v2_rounds native_round ON native_round.id=native_report.round_id
     AND native_round.session_id=native_batch.encounter_id AND native_round.state='narrato'
   JOIN mission_generic_owner.unified_report_publications native_publication ON native_publication.report_id=native_report.id
     AND native_publication.round_id=native_round.id AND native_publication.batch_id=native_batch.id
     AND native_publication.primary_report AND native_publication.message_id=successor.message_id
   JOIN public.messages native_message ON native_message.id=successor.message_id AND native_message.kind='fato'
     AND native_message.location_id=m.location_id AND native_message.character_id IS NULL AND native_message.recipient_user IS NULL
     AND native_message.body=successor.result->>'text'
   JOIN public.combat_v2_narratives native_narrative ON native_narrative.report_id=native_report.id
     AND native_narrative.round_id=native_round.id AND native_narrative.request_key=successor.request_key
     AND native_narrative.kind='fato_ia' AND native_narrative.author_user IS NULL AND native_narrative.body=native_message.body
   WHERE native_reissue.x->>'schema_version'='mission-combat-narration-reissue-proof/1'
     AND native_reissue.x->>'published'='true'
     AND native_reissue.x->>'master_session_id'=p_session::text AND native_reissue.x->>'failed_work_id'=wi.id::text
     AND native_reissue.x->>'batch_id'=native_batch.id::text
     AND native_reissue.x->>'payload_sha256'=wi.payload_sha256
     AND mission_generic_owner.c1266_historical_work_v1(successor.id)->>'schema_version'='c1266-work-execution-attestation/3'
     AND EXISTS(SELECT 1 FROM mission_narrative_internal.dispatch_audit finalized
       WHERE finalized.receipt_id=native_receipt.id AND finalized.event_code='generic_finalized'
         AND finalized.details->>'work_id'=successor.id::text AND finalized.details->>'receipt_id'=successor.receipt_id::text
         AND finalized.details->>'message_id'=native_message.id::text AND finalized.details->>'state'='completed'
         AND finalized.details->>'result_sha256'=successor.result_sha256
         AND finalized.details->>'result_jsonb_sha256'=public.combat_v2_sha256(successor.result)
         AND finalized.details->>'stale'='false' AND finalized.details->>'outcome_uncertain'='false'
         AND finalized.details->'application_error_sqlstate'='null'::jsonb)
     AND (native_batch.secondary_report_id IS NULL OR EXISTS(
       SELECT 1 FROM public.combat_v2_round_reports secondary_report
       JOIN mission_generic_owner.unified_report_publications secondary_publication
         ON secondary_publication.report_id=secondary_report.id AND secondary_publication.round_id=secondary_report.round_id
         AND secondary_publication.batch_id=native_batch.id AND NOT secondary_publication.primary_report
         AND secondary_publication.message_id=native_message.id
       WHERE secondary_report.id=native_batch.secondary_report_id AND secondary_report.narration_state='pubblicata'
         AND secondary_report.message_id IS NULL AND secondary_report.values_written IS FALSE
         AND secondary_report.mechanics_sha256=public.combat_v2_sha256(secondary_report.mechanics)))
  ))
 and NOT ((wi.id='e76f31f2-eded-495e-9c5f-f03461c5cc3a'::uuid AND wi.master_session_id='44078c5f-7001-4129-9506-e2f34e68c8ac'::uuid AND wi.kind='director' AND wi.state='failed' AND wi.message_id IS NULL
 AND wi.payload_sha256='f962403b87a5c6bf6930818e4d5655e57451d1adebbd404702f4a75ae7bcf03a' AND wi.payload_sha256=public.combat_v2_sha256(wi.payload)
 AND wi.result_sha256='73c3158fe44061c34b1dc410daec3fda85cd98ee3fadbbc063bbfdea5982571d' AND public.combat_v2_sha256(wi.result)='cee81d0c273baaf64705be7b53c884778f063bcd739461c777666cdcbd440ad4'
 AND wi.result->>'ok'='true' AND wi.result->>'provider_calls'='1' AND wi.result->>'outcome_uncertain'='false'
 AND EXISTS(SELECT 1 FROM mission_public_owner.work_contracts_v1 wc WHERE wc.work_id=wi.id AND wc.contract_sha256='ad13df1382af67d4af779f9f16790085468f3c14a9dd9c2c16d145477038f302' AND wc.contract_sha256=public.combat_v2_sha256(wc.contract) AND wc.release_sha256='feaf314957d5dab65a2420748e935015e5aa2e16fb2aed996e38e11e57189243' AND wc.contract->'features'?'provider_output_retention_v1')
 AND EXISTS(SELECT 1 FROM mission_narrative_internal.provider_outputs_v1 raw WHERE raw.id=(wi.result->>'output_receipt_id')::uuid AND raw.work_id=wi.id AND raw.authorization_id=wi.authorization_id AND raw.dispatch_id=wi.dispatch_id AND raw.dispatch_receipt_id=wi.dispatch_receipt_id AND raw.raw_sha256=wi.result->>'raw_sha256' AND raw.raw_sha256=encode(extensions.digest(convert_to(raw.raw_output,'UTF8'),'sha256'),'hex'))
 AND EXISTS(SELECT 1 FROM mission_narrative_internal.dispatch_receipts dr JOIN mission_narrative_internal.dispatch_audit fa ON fa.receipt_id=dr.id AND fa.event_code='generic_finalized'
  JOIN staff_ai_quota_private.calls q ON q.producer='mission_generic_ai' AND q.source_id=dr.id AND q.scope_id=wi.master_session_id AND q.call_no=1 AND q.state='settled' AND q.charged_usd=dr.charged_cost_usd
 WHERE dr.id=wi.dispatch_receipt_id AND dr.master_session_id=wi.master_session_id AND dr.authority_receipt_id=wi.id AND dr.request_key=wi.request_key AND dr.status='success' AND dr.dispatch_count=1 AND dr.finalized_at IS NOT NULL
 AND fa.details->>'work_id'=wi.id::text AND fa.details->>'receipt_id'=wi.receipt_id::text AND fa.details->>'result_sha256'=wi.result_sha256 AND fa.details->>'result_jsonb_sha256'=public.combat_v2_sha256(wi.result)
 AND fa.details->>'application_error_sqlstate'='23505' AND fa.details->'command_receipt'='null'::jsonb AND fa.details->>'stale'='false' AND fa.details->>'outcome_uncertain'='false')) AND EXISTS(SELECT 1 FROM mission_narrative_internal.dispatch_audit ap JOIN mission_generic_owner.unified_batches ab ON ab.decision_work_id=wi.id AND ab.master_session_id=wi.master_session_id
 JOIN mission_generic_owner.work_items aw ON aw.id=ab.writer_work_id AND aw.master_session_id=wi.master_session_id AND aw.authority_receipt_id=ab.id AND aw.kind='narration'
 WHERE ap.receipt_id=wi.dispatch_receipt_id AND ap.event_code='c1266_saved_director_applied' AND ap.details->>'schema_version'='c1266-saved-director-application/1'
 AND ap.details->>'master_session_id'=wi.master_session_id::text AND ap.details->>'work_id'=wi.id::text AND ap.details->>'result_sha256'=wi.result_sha256 AND ap.details->>'batch_id'=ab.id::text AND ap.details->>'writer_work_id'=aw.id::text AND ap.details->>'generation_http_calls'='0' AND ap.details->>'failed_work_preserved'='true'
 AND ab.retired_at IS NULL AND ab.state='published' AND aw.state='completed' AND ab.message_id=aw.message_id AND EXISTS(SELECT 1 FROM public.messages pm JOIN mission_generic_owner.unified_source_windows ps ON ps.id=ab.source_window_id AND ps.consumed_message_id=pm.id JOIN mission_generic_owner.unified_segment_publications_v4 pp ON pp.work_id=aw.id AND pp.message_id=pm.id WHERE pm.id=aw.message_id AND pm.kind='fato' AND pm.recipient_user IS NULL AND pm.body=aw.result->>'text')))
 and NOT (wi.kind='director' AND wi.state='failed' AND wi.result->>'ok'='true'
 AND wi.payload_sha256=public.combat_v2_sha256(wi.payload)
 AND EXISTS(SELECT 1 FROM mission_narrative_internal.dispatch_receipts healed_dr
  JOIN mission_narrative_internal.dispatch_audit healed_a ON healed_a.receipt_id=healed_dr.id AND healed_a.event_code='c1266_saved_director_applied'
  JOIN mission_narrative_internal.dispatch_audit healed_f ON healed_f.receipt_id=healed_dr.id AND healed_f.event_code='generic_finalized'
  JOIN mission_generic_owner.unified_batches healed_b ON healed_b.decision_work_id=wi.id AND healed_b.master_session_id=p_session
  JOIN mission_generic_owner.unified_source_windows healed_s ON healed_s.id=healed_b.source_window_id AND healed_s.work_id=wi.id AND healed_s.master_session_id=p_session
  JOIN mission_generic_owner.work_items healed_writer ON healed_writer.id=healed_b.writer_work_id AND healed_writer.master_session_id=p_session AND healed_writer.authority_receipt_id=healed_b.id
  JOIN public.messages healed_msg ON healed_msg.id=healed_writer.message_id AND healed_msg.kind='fato' AND healed_msg.recipient_user IS NULL AND healed_msg.body=healed_writer.result->>'text'
  WHERE healed_dr.id=wi.dispatch_receipt_id AND healed_dr.master_session_id=p_session AND healed_dr.authority_receipt_id=wi.id AND healed_dr.request_key=wi.request_key
   AND healed_dr.status='success' AND healed_dr.dispatch_count=1 AND healed_dr.finalized_at IS NOT NULL
   AND healed_a.details->>'schema_version'='c1266-saved-director-application/1' AND healed_a.details->>'master_session_id'=p_session::text
   AND healed_a.details->>'work_id'=wi.id::text AND healed_a.details->>'result_sha256'=wi.result_sha256
   AND healed_a.details->>'batch_id'=healed_b.id::text AND healed_a.details->>'writer_work_id'=healed_writer.id::text
   AND healed_a.details->>'generation_http_calls'='0' AND healed_a.details->>'failed_work_preserved'='true'
   AND healed_f.details->>'work_id'=wi.id::text AND healed_f.details->>'receipt_id'=wi.receipt_id::text
   AND healed_f.details->>'result_sha256'=wi.result_sha256 AND healed_f.details->>'result_jsonb_sha256'=public.combat_v2_sha256(wi.result)
   AND healed_b.state='published' AND healed_b.published_at IS NOT NULL AND healed_b.message_id=healed_writer.message_id
   AND healed_s.consumed_message_id=healed_b.message_id AND healed_s.superseded_at IS NULL
   AND healed_s.source_sha256=wi.payload_sha256 AND healed_writer.kind='narration' AND healed_writer.state='completed'
   AND healed_writer.payload=healed_b.payload AND healed_writer.payload_sha256=healed_b.payload_sha256
   AND healed_writer.payload_sha256=public.combat_v2_sha256(healed_writer.payload)
   AND EXISTS(SELECT 1 FROM mission_generic_owner.unified_segment_publications_v4 healed_pub WHERE healed_pub.work_id=healed_writer.id AND healed_pub.message_id=healed_msg.id)
   AND EXISTS(SELECT 1 FROM staff_ai_quota_private.calls healed_q WHERE healed_q.producer='mission_generic_ai' AND healed_q.scope_id=p_session AND healed_q.source_id=healed_dr.id AND healed_q.call_no=1 AND healed_q.state='settled' AND healed_q.charged_usd=healed_dr.charged_cost_usd)))
 and not (wi.id='849c4dac-280f-4331-9d6e-4197445f5ae4'::uuid
   and wi.kind='narration'
   and wi.authority_receipt_id='44639b01-ea89-4368-847c-0e40c6eaf9cc'::uuid
   and wi.result->'failure_codes'='["MISSION_PROFILE_AUDIT_INVALID"]'::jsonb
   and wi.payload_sha256=public.combat_v2_sha256(wi.payload)
   and exists (
     select 1 from mission_generic_owner.unified_batches recovered
     join mission_generic_owner.work_items successor on successor.id=recovered.writer_work_id
     join mission_generic_owner.flow_staff_sessions staff on staff.master_session_id=recovered.master_session_id and staff.enabled
     join public.master_v2_sessions session on session.id=staff.master_session_id and session.owner_kind='ai_service' and session.closed_at is null
     join public.locations location on location.id=session.location_id and location.is_test
     where recovered.id=wi.authority_receipt_id and recovered.master_session_id=p_session
       and recovered.state='published' and recovered.message_id is not null
       and recovered.payload_sha256=wi.payload_sha256
       and successor.id='6027edf0-355d-47c9-b88c-9a9e1a2d795b'::uuid
       and successor.master_session_id=p_session and successor.kind='narration'
       and successor.state='completed' and successor.message_id=recovered.message_id
       and successor.authority_receipt_id=recovered.id
       and successor.payload_sha256=recovered.payload_sha256
   ))
 and not exists(select 1 from mission_generic_owner.unified_source_windows released_source
   join mission_generic_owner.role_window_cursors staff_cursor
     on staff_cursor.master_session_id=released_source.master_session_id
   where (released_source.work_id=wi.id
     or exists(select 1 from mission_generic_owner.unified_batches released_batch
       where released_batch.source_window_id=released_source.id
         and released_batch.writer_work_id=wi.id))
     and released_source.master_session_id=p_session
     and mission_generic_owner.role_source_released_v4(released_source.id))
 and not (wi.id='d7c28505-7b5e-4e80-a148-3dceb6884174'::uuid
   and p_session='b70b23cf-bad8-475d-a56a-d9c549e35d84'::uuid
   and mission_generic_owner.flow_scope_enabled(p_session)
   and wi.kind='director' and wi.result->>'ok'='true'
   and wi.result_sha256='103cb96c6026f2dd043eaa3486bb39dac68a1765a7d01995ca5dcaefb5b46b3d'
   and exists(select 1 from mission_generic_owner.unified_batches repaired
      where repaired.decision_work_id=wi.id and repaired.source_window_id=wi.authority_receipt_id
       and repaired.master_session_id=p_session and repaired.step_key=wi.step_key
       and repaired.run_control_version=wi.run_control_version
       and repaired.composition_kind='narrative_continuation'
       and repaired.decision=wi.result->'decision'
       and repaired.decision_sha256=public.combat_v2_sha256(wi.result->'decision')
       and repaired.writer_work_id is not null and repaired.state in('ready','published')))
 and not (p_session='b70b23cf-bad8-475d-a56a-d9c549e35d84'::uuid
   and mission_generic_owner.flow_scope_enabled(p_session)
   and exists(select 1 from mission_generic_owner.unified_source_windows superseded
     where superseded.id=wi.id and superseded.work_id=wi.id
       and superseded.master_session_id=p_session
       and superseded.superseded_at is not null and superseded.consumed_message_id is null))
 and (wi.result->>'schema_version'='mission-generic-pre-provider-failure/1'
  and wi.result->>'failure_code'='request_validation_failed'
  and wi.result->>'provider_calls'='0' and wi.result->>'charged_cost_usd'='0'
  and wi.result_sha256=public.combat_v2_sha256(wi.result)
  and wi.payload_sha256=public.combat_v2_sha256(wi.payload)
  and (select count(*) from public.mission_run_audit qa
   join mission_generic_owner.work_items rw on rw.id::text=qa.metadata->>'new_work_id'
   join mission_generic_owner.unified_batches ub on ub.id=wi.authority_receipt_id and ub.writer_work_id=rw.id
   where qa.master_session_id=p_session and qa.event_code='QA_PREPROVIDER_NARRATION_RECOVERED'
    and qa.metadata->>'failed_work_id'=wi.id::text and qa.metadata->>'batch_id'=ub.id::text
    and qa.metadata->>'recovery_dedupe'=rw.dedupe_key
    and rw.master_session_id=wi.master_session_id and rw.authority_receipt_id=wi.authority_receipt_id
    and rw.kind=wi.kind and rw.state='completed' and ub.master_session_id=wi.master_session_id
    and ub.state='published' and rw.payload=ub.payload and rw.payload_sha256=ub.payload_sha256
    and rw.payload_sha256=public.combat_v2_sha256(rw.payload))=1) is not true
  and not (
    wi.id='3076c471-37c5-438e-8f50-0a790b787e05'::uuid
    and wi.kind='choice'
    and p_session='93d78313-abde-4087-9eb7-7b96bc0fa089'::uuid
    and wi.encounter_id='deadfef6-5b16-4921-aa86-b86ffad6f2f2'::uuid
    and wi.payload->>'actor_id'='1f662f89-447a-4cd3-9873-a5953a0e0d91'
    and wi.payload->>'round_id'='44061137-17a3-43fa-9225-d29aaa26e58a'
    and (
      (
        (select md5(prosrc) from pg_proc where oid='mission_generic_owner.enqueue_choice(uuid,uuid,uuid)'::regprocedure)
          ='76a88f0e93752e1456c90d160a7a855d'
        and exists (
          select 1 from mission_generic_owner.unified_batches ub
          where ub.master_session_id=p_session
            and ub.id='fbfc8e29-8724-4241-b2fe-22dbc17eb9e7'::uuid
            and ub.encounter_id=wi.encounter_id
            and ub.state='preparing' and ub.entry_side='png'
            and ub.next_round_id='44061137-17a3-43fa-9225-d29aaa26e58a'::uuid
        )
        and not exists (
          select 1 from mission_generic_owner.work_items rw
          where rw.master_session_id=p_session
            and rw.dedupe_key=wi.dedupe_key||':recovery:'||wi.id::text
        )
        and not exists (
          select 1 from public.combat_v2_declarations d
          where d.round_id='44061137-17a3-43fa-9225-d29aaa26e58a'::uuid
            and d.actor_id='1f662f89-447a-4cd3-9873-a5953a0e0d91'::uuid
        )
      )
      or exists (
        select 1 from mission_generic_owner.work_items rw
        where rw.master_session_id=p_session
          and rw.dedupe_key=wi.dedupe_key||':recovery:'||wi.id::text
          and rw.kind='choice' and rw.state='completed'
          and rw.encounter_id=wi.encounter_id
          and rw.payload->>'actor_id'=wi.payload->>'actor_id'
          and rw.payload->>'round_id'=wi.payload->>'round_id'
          and rw.payload_sha256=public.combat_v2_sha256(rw.payload)
          and rw.result_sha256=public.combat_v2_sha256(rw.result)
          and exists (
            select 1 from public.combat_v2_declarations d
            where d.round_id='44061137-17a3-43fa-9225-d29aaa26e58a'::uuid
              and d.actor_id='1f662f89-447a-4cd3-9873-a5953a0e0d91'::uuid
          )
      )
    )
  )
)
 then return mission_generic_owner.progress_result(p_session,p_user,'needs_attention');end if;
 if exists(select 1 from public.mission_run_outbox uo where uo.master_session_id=p_session and uo.state='pending' and not exists(select 1 from mission_generic_owner.unified_batches ub where ub.master_session_id=p_session and ub.state='preparing' and ub.route->>'event_id'=uo.event_id::text))
 then return mission_generic_owner.progress_result(p_session,p_user,'narration_pending');end if;
 if not exists(select 1 from mission_factory_owner.quest_run_sources where session_id=p_session) then
 res:=mission_rapid_owner.try_native_terminal(p_session);
 if res is not null then return mission_generic_owner.progress_result(p_session,p_user,'transitioned');end if;
 settings:=mission_generic_owner.run_plan_settings(p_session);
 select count(*),jsonb_agg(x)->0 into n,term from jsonb_array_elements(settings->'terminal_steps') x where x->>'step_key'=r.current_step_key;
 if n>1 then raise exception 'MGP_PLAN_TERMINAL_AMBIGUOUS';end if;
 if n=1 AND mission_generic_owner.staff_finish_policy_v1(p_session) IS DISTINCT FROM true then
  res:=mission_generic_owner.finish_mission(p_session,term->>'outcome');
  return jsonb_build_object('schema_version','mission-generic-progress/1','master_session_id',p_session,'state','closed','dispatch',null);
 end if;
 end if;
 res:=mission_generic_owner.unified_advance(p_session,p_user,p_request);
 if res is not null then return res;end if;
 sc:=mission_generic_owner.scene(p_session,r.current_step_key);
 select count(*) into n from mission_generic_owner.encounters x join public.combat_v2_sessions y on y.id=x.encounter_id
 where x.master_session_id=p_session and y.closed_at is null;
 if n>1 then raise exception 'MGP_MULTIPLE_ACTIVE_ENCOUNTERS';end if;
 select x.* into e from mission_generic_owner.encounters x join public.combat_v2_sessions y on y.id=x.encounter_id
 where x.master_session_id=p_session and y.closed_at is null;
 if e.encounter_id is null then
  select count(*),jsonb_agg(x)->0 into n,spec from jsonb_array_elements(sc->'encounters') x
  where not exists(select 1 from mission_generic_owner.encounters z where z.master_session_id=p_session
   and z.step_key=r.current_step_key and z.run_control_version=r.control_version and z.encounter_key=x->>'encounter_key');
  if n=0 then return mission_generic_owner.progress_result(p_session,p_user,'waiting_choice');end if;
  if n>1 then raise exception 'MGP_ENCOUNTER_OPEN_POINT_AMBIGUOUS' using errcode='22023';end if;
  res:=public.mission_generic_combat_open_v1(p_session,spec->>'encounter_key',r.control_version,
    mission_ai_service_owner.uuid5(p_session,'encounter:'||r.control_version||':'||(spec->>'encounter_key')));
  select * into strict e from mission_generic_owner.encounters where encounter_id=(res->>'encounter_id')::uuid;
 end if;
 if e.step_key<>r.current_step_key or e.run_control_version<>r.control_version then raise exception 'MGP_ENCOUNTER_VISIT_DRIFT';end if;
 select * into strict s from public.combat_v2_sessions where id=e.encounter_id for update;
 if s.state='risolto' then
  res:=mission_generic_owner.advance_combat_terminal(p_session,s.id);
  return mission_generic_owner.progress_result(p_session,p_user,'transitioned');
 end if;
 if s.state<>'in_corso' then raise exception 'MGP_ENCOUNTER_STATE';end if;
 select * into strict roundrow from public.combat_v2_rounds where session_id=s.id order by round_no desc limit 1 for update;
 if roundrow.state in('risolto','narrazione') then
  select * into strict rep from public.combat_v2_round_reports where round_id=roundrow.id;
  if rep.narration_state<>'attesa' then raise exception 'MGP_REPORT_STATE';end if;
  return mission_public_owner.enqueue_combat_unified_v1(p_session,rep.id,p_user);
 end if;
 w9_defense:=roundrow.phase='raccolta_difese'
  AND mission_generic_owner.tactics_w9_source_v1(p_session) IS NOT NULL;
 -- Common offre difese soltanto nella fase nativa raccolta_difese. Un target
 -- già creato durante raccolta_azioni non anticipa la scelta del PNG.
 select a.id into actor from public.combat_v2_actors a where a.session_id=s.id and a.actor_kind='png' and a.state='attivo'
 and roundrow.phase='raccolta_difese' and roundrow.state='raccolta_difese'
 and exists(select 1 from jsonb_array_elements(e.actor_map) x where x->>'actor_id'=a.id::text and x->>'mechanical_binding_id' is not null)
 and exists(select 1 from public.combat_v2_attack_targets t where t.round_id=roundrow.id and (t.target_actor_id=a.id
    or mission_generic_owner.mission_companion_defense_owner_v1(e.encounter_id,t.target_actor_id)=a.id)
  and (not w9_defense or (t.state='attesa_difesa' and not combat_panel_private.multiplication_no_defense(t.id)))
  and not exists(select 1 from public.combat_v2_defense_coverages c where c.attack_target_id=t.id)) order by a.id limit 1;
 if actor is not null then
  res:=mission_generic_owner.enqueue_choice(p_session,s.id,actor);
  return mission_generic_owner.progress_result(p_session,p_user,'choice_ready');
 end if;
 if exists(select 1 from public.combat_v2_actors a where a.session_id=s.id and a.actor_kind='pg' and a.state='attivo'
 and clan_marionettisti_private.can_declare(a.id) and not exists(select 1 from public.combat_v2_declarations d
  where d.round_id=roundrow.id and d.actor_id=a.id and d.kind in('attacco','movimento','utilita','passa')))
 then return mission_generic_owner.progress_result(p_session,p_user,'waiting_player');end if;
 -- La barriera PG precedente resta obbligatoria; ogni PNG riceve una
 -- principale soltanto se manca e il round raccoglie ancora azioni.
 IF mission_narrative_internal.scene_opening_receipt_v1(roundrow.id) IS NULL THEN
 select a.id into actor from public.combat_v2_actors a where a.session_id=s.id and a.actor_kind='png' and a.state='attivo'
 and roundrow.phase='raccolta_azioni' and roundrow.state='raccolta_azioni'
 and clan_marionettisti_private.can_declare(a.id)
 and exists(select 1 from jsonb_array_elements(e.actor_map) x where x->>'actor_id'=a.id::text and x->>'mechanical_binding_id' is not null)
 and not exists(select 1 from public.combat_v2_declarations d where d.round_id=roundrow.id and d.actor_id=a.id
 and d.kind in('attacco','movimento','utilita','passa')) order by a.id limit 1;
 ELSE actor:=NULL;END IF;
 if actor is not null then
  res:=mission_generic_owner.enqueue_choice(p_session,s.id,actor);
  return mission_generic_owner.progress_result(p_session,p_user,'choice_ready');
 end if;
 IF mission_narrative_internal.scene_native_round_bound_v1(p_session,roundrow.id)
  AND roundrow.phase='raccolta_difese'
  AND EXISTS(SELECT 1 FROM public.combat_v2_attack_targets pg_target
    JOIN public.combat_v2_actors pg ON pg.id=pg_target.target_actor_id AND pg.actor_kind='pg'
    WHERE pg_target.round_id=roundrow.id AND pg_target.state='attesa_difesa'
     AND (NOT w9_defense OR NOT combat_panel_private.multiplication_no_defense(pg_target.id))
     AND NOT EXISTS(SELECT 1 FROM public.combat_v2_defense_coverages covered WHERE covered.attack_target_id=pg_target.id))
  AND NOT EXISTS(SELECT 1 FROM public.combat_v2_attack_targets npc_target
    JOIN public.combat_v2_actors png ON png.id=npc_target.target_actor_id AND png.actor_kind='png' AND png.state='attivo'
    WHERE npc_target.round_id=roundrow.id
     AND (NOT w9_defense OR (npc_target.state='attesa_difesa'
      AND NOT combat_panel_private.multiplication_no_defense(npc_target.id)))
     AND NOT EXISTS(SELECT 1 FROM public.combat_v2_defense_coverages covered WHERE covered.attack_target_id=npc_target.id))
  AND EXISTS(SELECT 1 FROM public.combat_v2_declarations dd JOIN public.combat_v2_actors png ON png.id=dd.actor_id
    WHERE dd.round_id=roundrow.id AND png.actor_kind='png' AND dd.kind IN('attacco','movimento','utilita','passa','difesa','nessuna')
     AND NOT(dd.kind='nessuna' AND coalesce(dd.declaration_text,'')='')
     AND NOT mission_narrative_internal.scene_native_declaration_public_v1(dd.id))
 THEN res:=mission_narrative_internal.scene_combat_intent_prepare_v1(p_session,roundrow.id);
  IF res IS NOT NULL THEN RETURN mission_generic_owner.progress_result(p_session,p_user,'narration_ready');END IF;
 END IF;
 if (select count(*) from public.combat_v2_declarations where round_id=roundrow.id and kind in('attacco','movimento','utilita','passa'))
 <>combat_consumer_private.expected_main_count(roundrow.id)
 then return mission_generic_owner.progress_result(p_session,p_user,'waiting_player');end if;
 if not combat_v2_multitarget_internal.round_complete(roundrow.id)
 then return mission_generic_owner.progress_result(p_session,p_user,'waiting_defense');end if;
 if roundrow.evaluation_mode<>'neutra' and exists(select 1 from public.combat_v2_declarations d
 join public.combat_v2_actors a on a.id=d.actor_id where d.round_id=roundrow.id and a.actor_kind='pg' and d.kind in('attacco','difesa')
 and not exists(select 1 from public.combat_v2_ratings x where x.declaration_id=d.id and x.is_active))
 then return mission_generic_owner.progress_result(p_session,p_user,'waiting_quality');end if;
 -- Neutra: il resolver nativo registra zero con fonte neutralita_sistema. Nessun voto IA.
 if (select is_test from public.locations where id=m.location_id) and (public.combat_v2_values_written(s.id)
 or not combat_panel_private.uses_simulated_pools(s.id)) then raise exception 'MGP_SIMULATION_SCOPE' using errcode='42501';end if;
 res:=public.combat_v2_round_resolve(roundrow.id,mission_ai_service_owner.uuid5(roundrow.id,'generic-resolve'));
 select * into strict rep from public.combat_v2_round_reports where id=(res#>>'{data,report_id}')::uuid and round_id=roundrow.id;
 return mission_public_owner.enqueue_combat_unified_v1(p_session,rep.id,p_user);
end $function$;

CREATE OR REPLACE FUNCTION combat_panel_private.master_companion_actor_visible(p_session uuid, p_actor uuid, p_viewer uuid)
 RETURNS boolean
 LANGUAGE plpgsql
 STABLE SECURITY DEFINER
 SET search_path TO ''
AS $function$
DECLARE s public.combat_v2_sessions%ROWTYPE; i combat_spatial.arena_instances%ROWTYPE;
 b combat_spatial.actor_states%ROWTYPE; src jsonb; raw jsonb; round_no integer;
BEGIN
 IF p_viewer IS NULL THEN RETURN false; END IF;
 IF auth.uid() IS NOT NULL THEN
   IF p_viewer IS DISTINCT FROM auth.uid() THEN RETURN false; END IF;
 ELSIF NOT public.combat_v2_is_service()
    OR p_viewer IS DISTINCT FROM mission_generic_owner.current_principal() THEN
   RETURN false;
 END IF;
 SELECT s0.* INTO s FROM public.combat_v2_sessions s0
   JOIN combat_panel_private.master_panel_sessions p ON p.master_session_id=s0.master_session_id
   WHERE s0.id=p_session AND s0.source_kind='master' AND s0.closed_at IS NULL;
 IF s.id IS NULL THEN RETURN false; END IF;
 src:=public.master_v2_ui_state(s.location_id)->'data';
 IF src#>>'{encounter,id}' IS DISTINCT FROM s.id::text THEN RETURN false; END IF;
 SELECT * INTO i FROM combat_spatial.arena_instances WHERE encounter_id=s.id AND context_source='panel_master' AND state='open';
 SELECT * INTO b FROM combat_spatial.actor_states WHERE instance_id=i.instance_id AND actor_id=p_actor AND state='active';
 IF b.actor_id IS NULL OR NOT EXISTS(SELECT 1 FROM combat_spatial.viewer_grants
   WHERE instance_id=i.instance_id AND viewer_principal_id=p_viewer AND can_view_map) THEN RETURN false; END IF;
 round_no:=coalesce((src#>>'{round,no}')::integer,1);
 raw:=combat_spatial.map_projection(i.instance_id,p_viewer,round_no);
 RETURN EXISTS(SELECT 1 FROM jsonb_array_elements(raw->'actors') item
   WHERE item->>'subject'=b.projection_subject_id::text);
END $function$;

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
    o.actor_kind AS owner_actor_kind,
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

  -- A service-controlled owner needs the mission's server-authored companion binding.
  IF scope.owner_actor_kind='png' AND NOT coalesce(
       clan_marionettisti_private.mission_companion_valid(scope.session_id,scope.owner_actor_id,p_body),false)
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
               OR (scope.source_kind='master' AND scope.owner_actor_kind='png'
                 AND EXISTS (SELECT 1 FROM public.master_v2_sessions m
                   WHERE m.id=scope.master_session_id AND m.owner_kind='ai_service'
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

CREATE OR REPLACE FUNCTION public.combat_v2_defense_declare(p_round uuid, p_attack_declaration uuid, p_actor uuid, p_intent jsonb, p_text text, p_request_key uuid)
 RETURNS jsonb
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO ''
AS $function$
declare v_uid uuid:=exam_regia_private.current_principal(); v_service boolean:=false; v_service_actor uuid; v_r public.combat_v2_rounds%rowtype; v_a public.combat_v2_actors%rowtype; v_atk public.combat_v2_declarations%rowtype;
  v_i jsonb; v_reaction text; v_source text; v_ability uuid; v_meta jsonb; v_cost int:=0; v_event jsonb; v_event_id uuid; v_id uuid; v_result jsonb; v_existing public.combat_v2_events%rowtype; v_payload jsonb; v_fp text;
begin
  if v_uid is null then delete from mission_exchange_combat_owner.service_defense_permits p where p.request_key=p_request_key and p.round_id=p_round and p.attack_id=p_attack_declaration and p.actor_id=p_actor and p.intent_sha256=encode(extensions.digest(convert_to(p_intent::text,'UTF8'),'sha256'),'hex') returning true,p.capability_id into v_service,v_service_actor;if not coalesce(v_service,false)then perform public.combat_v2_fail('autenticazione_richiesta','Autenticazione richiesta.',401,p_request_key,'{}');end if;end if;
  perform public.combat_v2_lock_round(p_round);
  perform exam_regia_private.assert_actor_dispatch(p_round,p_actor,p_request_key);
  select * into v_r from public.combat_v2_rounds where id=p_round for update;
  select * into v_a from public.combat_v2_actors where id=p_actor for update;
  if v_a.companion_id is not null then perform public.combat_v2_fail('compagno_senza_turno','Il compagno non dichiara azioni autonome.',409,p_request_key,'{}'); end if;
  select * into v_atk from public.combat_v2_declarations where id=p_attack_declaration for update;
  perform combat_consumer_private.assert_dispatch(p_round,p_request_key,'defend');
  perform public.combat_v2_assert_operational(p_round,p_request_key,false);
  if v_r.id is null or v_a.id is null or v_atk.id is null or v_atk.round_id<>p_round then
    perform public.combat_v2_fail('bersaglio_non_valido','Difesa non collegata a questo attore.',422,p_request_key,'{}'); end if;
  if v_r.phase<>'raccolta_difese' then perform public.combat_v2_fail('fase_non_valida','Il round non raccoglie difese.',409,p_request_key,'{}'); end if;
  IF v_a.actor_kind='png' AND EXISTS(SELECT 1 FROM user_testroom_common_private.contexts WHERE id=v_a.session_id) THEN
    PERFORM user_testroom_common_private.assert_png_defense(p_round,p_attack_declaration,p_actor,p_intent,p_request_key);
  ELSE if not v_service and exam_regia_private.actor_principal(v_a.id,v_a.controller_user)<>v_uid then perform public.combat_v2_fail('attore_non_controllato','Non controlli questo attore.',403,p_request_key,'{}'); end if; END IF;
  v_i := public.combat_v2_sanitize_intent(p_intent,true); v_i:=clan_inuzuka_private.defense_guard(p_actor,v_i);
  perform clan_marionettisti_private.assert_jutsu_source(p_actor,v_i->>'ability_source',(v_i->>'ability_id')::uuid);
  v_payload:=jsonb_build_object('attack',p_attack_declaration,'actor',p_actor,'intent',v_i,'text',coalesce(p_text,''));
  v_fp:=public.combat_v2_sha256(jsonb_build_object('operation','combat_v2_defense_declare','payload',v_payload,'caller',exam_regia_private.current_principal(),'scope',p_round));
  select * into v_existing from public.combat_v2_events where scope_id=p_round and request_key=p_request_key for update;
  if v_existing.id is not null then
    if v_existing.operation_kind is distinct from 'combat_v2_defense_declare'
       or v_existing.request_fingerprint is distinct from v_fp then
      perform public.combat_v2_fail('request_key_conflict','La chiave richiesta e gia associata a una difesa diversa.',409,p_request_key,'{}');
    end if;
    if v_existing.status='completata' then return v_existing.result; end if;
    perform public.combat_v2_fail('operazione_in_corso','Operazione gia in corso.',409,p_request_key,'{}');
  end if;
  if exists(select 1 from public.combat_v2_declarations d join public.combat_v2_declarations x on x.id=d.parent_attack_id where d.round_id=p_round and d.kind='difesa' and d.actor_id=p_actor) then
    perform public.combat_v2_fail('azione_non_disponibile','La reazione del round è già stata usata.',409,p_request_key,'{}'); end if;
  IF EXISTS(SELECT 1 FROM public.combat_v2_attack_targets mt
   WHERE mt.attack_declaration_id=p_attack_declaration
     AND combat_panel_private.multiplication_no_defense(mt.id))
   AND NOT EXISTS(SELECT 1 FROM public.combat_v2_attack_targets mt
    WHERE mt.attack_declaration_id=p_attack_declaration
      AND NOT combat_panel_private.multiplication_no_defense(mt.id)) THEN
    perform public.combat_v2_fail('difesa_non_richiesta','Il colpo non richiede una difesa.',409,p_request_key,'{}');
  END IF;
  v_reaction:=v_i->>'reaction';
  IF combat_panel_private.nara_controlled_v1(p_actor) AND v_reaction IS DISTINCT FROM 'nessuna' THEN
    PERFORM public.combat_v2_fail('azione_non_disponibile','Il corpo è sotto controllo.',409,p_request_key,'{}');
  END IF;
  -- [MISSION-GUARD-003] I resolver V2 dedicati non sono ancora collegati.
  if v_reaction in ('sostituzione','copie') then
    perform public.combat_v2_fail('profilo_runtime_non_disponibile','Questa difesa richiede il proprio resolver.',422,p_request_key,'{}');
  end if;
  if v_reaction='tecnica' then
    v_source:=v_i->>'ability_source'; v_ability:=(v_i->>'ability_id')::uuid;
    if v_ability='31b15861-fb78-4f8a-ac1c-ebf2d957c32e'::uuid then
      perform public.combat_v2_fail('profilo_runtime_non_disponibile','Sostituzione richiede un’offerta spaziale valida.',422,p_request_key,'{}');
    end if;
    PERFORM combat_v2_elemental_internal.scudo_prepare_native(p_round,p_attack_declaration,p_actor,p_request_key,v_i);
    v_meta:=combat_v2_elemental_internal.scudo_declaration_meta(p_round,p_attack_declaration,p_actor,p_request_key,v_i);
    IF v_meta IS NULL THEN
      v_meta:=combat_v2_multitarget_internal.enrich_ability_v1(public.combat_v2_actor_ability(p_actor,v_source,v_ability,true));
    END IF;
    if v_meta is null then perform public.combat_v2_fail('opzione_non_offerta','Tecnica difensiva non offerta.',422,p_request_key,'{}'); end if;
    if v_ability='9f12fc98-bc97-4b95-9bcc-7ce359ebbe4f'::uuid
       and lower(coalesce(v_atk.sanitized_intent#>>'{server_ability,kind}','')) not like '%genjutsu%' then
      perform public.combat_v2_fail('opzione_non_offerta','Dispersione è disponibile soltanto contro Genjutsu.',422,p_request_key,'{}');
    end if;
    v_cost:=coalesce((v_meta->>'chakra_cost')::int,0);
  elsif v_reaction='sostituzione' then v_cost:=5;
  end if;
  v_event:=public.combat_v2_event_begin(p_round,p_request_key,'combat_v2_defense_declare',v_payload,null);
  if (v_event->>'replay')::boolean then return v_event->'result'; end if; v_event_id:=(v_event->>'event_id')::uuid;
  insert into public.combat_v2_declarations(round_id,actor_id,kind,parent_attack_id,target_actor_id,sanitized_intent,declaration_text,controller_user_snapshot,controller_version_snapshot,request_key,cost_snapshot)
  values(p_round,p_actor,'difesa',p_attack_declaration,case when clan_marionettisti_private.defends_body(p_actor,v_atk.target_actor_id,v_reaction) then v_atk.target_actor_id else p_actor end,v_i||case when v_meta is null then '{}'::jsonb else jsonb_build_object('server_ability',v_meta) end,
    coalesce(p_text,''),coalesce(v_uid,v_service_actor),v_a.controller_version,p_request_key,clan_hyuga_private.sedici_cost_snapshot(p_actor,jsonb_build_object('chakra',v_cost))) returning id into v_id;
  PERFORM combat_v2_elemental_internal.scudo_bind_source(v_id);
  PERFORM clan_hyuga_private.rotation_freeze(v_id);
  insert into public.combat_v2_declarations(round_id,actor_id,kind,parent_attack_id,target_actor_id,sanitized_intent,declaration_text,controller_user_snapshot,controller_version_snapshot,request_key,cost_snapshot)
  select p_round,p_actor,'nessuna',x.id,p_actor,jsonb_build_object('reaction','nessuna'),'',coalesce(v_uid,v_service_actor),v_a.controller_version,gen_random_uuid(),'{}'::jsonb
    from public.combat_v2_declarations x
   where x.round_id=p_round and x.kind='attacco' and exists(select 1 from public.combat_v2_attack_targets mt
     where mt.attack_declaration_id=x.id and mt.round_id=p_round
       and mt.target_actor_id=p_actor and mt.state='attesa_difesa'
       and not combat_panel_private.multiplication_no_defense(mt.id)
       and not exists(select 1 from public.combat_v2_defense_coverages c where c.attack_target_id=mt.id)) and x.id<>p_attack_declaration
     and not exists(select 1 from public.combat_v2_declarations d where d.parent_attack_id=x.id and d.actor_id=p_actor);
  -- The owner's round reaction also covers the decision on its mission puppet.
  -- Record native no-defense declarations for the other attacks on that puppet.
  IF v_a.actor_kind='png' AND auth.uid() IS NULL
     AND v_uid=mission_generic_owner.actor_principal(p_actor) THEN
    INSERT INTO public.combat_v2_declarations(round_id,actor_id,kind,parent_attack_id,target_actor_id,
      sanitized_intent,declaration_text,controller_user_snapshot,controller_version_snapshot,request_key,cost_snapshot)
    SELECT DISTINCT ON (target.attack_declaration_id)
      p_round,p_actor,'nessuna',target.attack_declaration_id,target.target_actor_id,
      jsonb_build_object('reaction','nessuna'),'',v_uid,v_a.controller_version,gen_random_uuid(),'{}'::jsonb
    FROM public.combat_v2_attack_targets target
    JOIN public.combat_v2_declarations attack
      ON attack.id=target.attack_declaration_id AND attack.round_id=target.round_id AND attack.kind='attacco'
    WHERE target.round_id=p_round AND target.state='attesa_difesa'
      AND target.attack_declaration_id<>p_attack_declaration
      AND NOT combat_panel_private.multiplication_no_defense(target.id)
      AND mission_generic_owner.mission_companion_defense_owner_v1(v_a.session_id,target.target_actor_id)=p_actor
      AND NOT EXISTS (SELECT 1 FROM public.combat_v2_defense_coverages coverage
        WHERE coverage.attack_target_id=target.id)
      AND NOT EXISTS (SELECT 1 FROM public.combat_v2_declarations response
        WHERE response.parent_attack_id=target.attack_declaration_id AND response.actor_id=p_actor
          AND response.kind IN ('difesa','nessuna'))
    ORDER BY target.attack_declaration_id,target.ordinal;
  END IF;
  v_result:=public.combat_v2_envelope(p_request_key,jsonb_build_object('defense_id',v_id));
  return public.combat_v2_event_complete(v_event_id,v_result);
end
$function$;

CREATE OR REPLACE FUNCTION mission_generic_owner.combat_narrative_source(p_session uuid, p_event uuid)
 RETURNS jsonb
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO ''
AS $function$
declare scene56_runtime mission_narrative_internal.scene_runtime_v1;scene56_npc jsonb;scene56_last public.messages;
 e mission_generic_owner.encounters%rowtype; b mission_generic_owner.run_bindings%rowtype;
 run public.mission_run_state%rowtype; s public.combat_v2_sessions%rowtype;
 r public.combat_v2_rounds%rowtype; rep public.combat_v2_round_reports%rowtype;
 a public.combat_v2_actors%rowtype; d public.combat_v2_declarations%rowtype;
 place public.locations%rowtype; row record; item jsonb; projected jsonb; narrator jsonb;
 puppet_owner uuid; puppet jsonb; puppets jsonb:='[]'::jsonb; cut_proof jsonb; cut_event_count integer;
 cut_status text; cut_description text;
 roleless jsonb:='[]'; actors jsonb:='[]'; actions jsonb:='[]'; sources jsonb:='[]'; facts jsonb:='[]'; spatial jsonb:='[]';
 snapshot jsonb; candidate jsonb; scenehash text; body text; sid text; pname text; persona text; cover_terminal jsonb;
 prior_count integer:=0; included integer:=0;director jsonb;loc text;setting_body text;setting_id text;actor_key text;payload jsonb;knowledge jsonb;knowledge_context jsonb:='[]';input_cap integer;continuity_snapshot jsonb;private_native20 boolean:=false;
begin
 if auth.uid() is not null or not public.combat_v2_is_service() then raise exception 'MG_SERVICE_REQUIRED' using errcode='42501';end if;
 perform mission_generic_owner.assert_runtime(p_session);
 input_cap:=(mission_generic_owner.capacity()->>'input_capacity_bytes')::integer;
 select * into strict b from mission_generic_owner.run_bindings where master_session_id=p_session;
 select * into strict run from public.mission_run_state where master_session_id=p_session;
 select * into strict rep from public.combat_v2_round_reports where id=p_event;
 perform public.combat_v2_lock_round(rep.round_id);
 select * into strict r from public.combat_v2_rounds where id=rep.round_id and report_id=rep.id;
 select * into strict s from public.combat_v2_sessions where id=r.session_id and master_session_id=p_session;
 select * into strict e from mission_generic_owner.encounters where encounter_id=s.id and master_session_id=p_session;
 select * into strict place from public.locations where id=s.location_id;
 if e.step_key<>run.current_step_key or e.run_control_version<>run.control_version
  or b.snapshot_sha256 is distinct from mission_internal.fingerprint(b.snapshot)
  or r.state<>'risolto' or r.resolved_at is null or rep.narration_state<>'attesa'
  or rep.mechanics_sha256 is distinct from public.combat_v2_sha256(rep.mechanics)
  or jsonb_typeof(rep.mechanics->'declarations') is distinct from 'array'
  or (place.is_test and (rep.values_written or public.combat_v2_values_written(s.id)))
 then raise exception 'MG_COMBAT_SOURCE_STALE' using errcode='55000';end if;
 SELECT * INTO scene56_runtime FROM mission_narrative_internal.scene_runtime_v1 WHERE master_session_id=p_session AND is_active;
 director:=mission_creation_owner.director_context(p_session,run.current_step_key);
 if director is null then
  loc:=place.name;setting_body:=place.description;setting_id:='location:'||place.id;
 else
  loc:=case when nullif(btrim(director#>>'{setting,name}'),'') is not null then director#>>'{setting,name}' else 'Ambientazione della missione' end;
  setting_body:=director#>>'{setting,description}';
  setting_id:='mission-setting:'||p_session||':'||run.current_step_key;
  if director->>'schema_version' is distinct from 'mission-director-context/1'
   or nullif(btrim(loc),'') is null or nullif(btrim(setting_body),'') is null
  then raise exception 'MC_DIRECTOR_CONTEXT_INVALID';end if;
 end if;
 for a in select * from public.combat_v2_actors where session_id=s.id order by id loop
  persona:=null;pname:=null;
  if a.actor_kind='pg' then
   select name into strict pname from public.characters where id=a.character_id and user_id=a.controller_user;
  elsif a.actor_kind='png' and a.companion_id is not null then
   select src.owner_actor_id into strict puppet_owner
    from clan_marionettisti_private.sources src
    where src.id=a.companion_id and src.source_kind='mission_service' and src.session_id=s.id;
   if not coalesce(clan_marionettisti_private.mission_companion_valid(s.id,puppet_owner,a.id),false) then
    raise exception 'MG_SCENE_PUPPET_BINDING_INVALID' using errcode='55000';
   end if;
   -- This body is a controlled object. It has neither its own role nor its own knowledge.
   puppets:=puppets||jsonb_build_array(jsonb_build_object(
    'actor_id',a.id,'controller_actor_id',puppet_owner,'nome','Marionetta da Combattimento',
    'capacita_narrative','La marionetta è un oggetto controllato dal PNG. Il compagno non parla e non agisce autonomamente.'));
   continue;
  elsif a.actor_kind='png' then
    IF scene56_runtime.id IS NOT NULL THEN
     SELECT map->>'actor_key' INTO STRICT actor_key FROM jsonb_array_elements(e.actor_map)map WHERE map->>'actor_id'=a.id::text;
     SELECT npc INTO STRICT scene56_npc FROM jsonb_array_elements(scene56_runtime.snapshot->'npcs')npc WHERE npc->>'actor_key'=actor_key;
     pname:=scene56_npc->>'name';
     persona:=jsonb_build_object('voice',scene56_npc#>'{profile,skeleton,voice}',
      'gestures',scene56_npc#>'{profile,skeleton,gestures}',
      'life_core',scene56_npc#>'{profile,skeleton}',
      'conduct',scene56_npc#>'{profile,skeleton,conduct}',
      'forbidden',scene56_npc#>'{profile,skeleton,forbidden}')::text;
     knowledge:=jsonb_build_object('actor_id',a.id,'knowledge_limits',scene56_npc#>'{profile,skeleton,knowledge_limits}',
      'knowledge_boundary',scene56_npc->'knowledge');
    ELSE
   select pi.nome,(jsonb_build_object('voice',nv.skeleton->'voice','gestures',nv.skeleton->'gestures',
    'life_core',jsonb_build_object(
    'background',jsonb_strip_nulls(jsonb_build_object('role',nv.skeleton#>'{identity,role}','origin',nv.skeleton#>'{identity,origin}')),
    'motivations',nv.skeleton->'motivations','goals',nv.skeleton->'goals','fears',nv.skeleton->'fears',
    'fragility',nv.skeleton->'fragility','resilience',nv.skeleton->'resilience',
    'character_errors',nv.skeleton->'character_errors','recovery',nv.skeleton->'recovery',
    'relationships',nv.skeleton->'relationships',
    'continuity',jsonb_strip_nulls(jsonb_build_object('emotional',nv.skeleton#>'{continuity,emotional}',
      'relational',nv.skeleton#>'{continuity,relational}','emotional_endings',nv.skeleton#>'{continuity,emotional_endings}')))) || case when mission_academy_owner.staff_carrier_runtime(p_session) then jsonb_build_object('conduct',nv.skeleton->'conduct','forbidden',nv.skeleton->'forbidden') else '{}'::jsonb end)::text,
    jsonb_build_object('actor_id',a.id,'knowledge_limits',nv.skeleton->'knowledge_limits','knowledge_boundary',nv.knowledge_boundary)
    into strict pname,persona,knowledge
    from public.combat_v2_provider_instances_v1 pi join public.nb_template_versions nv on nv.id=pi.narrative_version_ref
    where pi.id=a.provider_instance_v1_id and pi.session_id=s.id;
    END IF;
   if director is not null then
    select x->>'actor_key' into strict actor_key from jsonb_array_elements(e.actor_map) x
     where x->>'actor_id'=a.id::text;
    -- The mapping identifies the approved actor for its private phase notes.
    -- It carries no secret or additional actor authority.
    persona:=(persona::jsonb||jsonb_build_object('mission_actor_key',actor_key))::text;
    knowledge_context:=knowledge_context||jsonb_build_array(knowledge||jsonb_build_object('actor_key',actor_key));
   end if;
  else raise exception 'MG_SCENE_ACTOR_UNSUPPORTED'  using errcode='55000';end if;
  if nullif(btrim(pname),'') is null then raise exception 'MG_SCENE_IDENTITY_MISSING';end if;
  actors:=actors||jsonb_build_array(jsonb_build_object('id',a.id,'name',pname,'kind',upper(a.actor_kind),
    'persona',persona,'may_speak',a.actor_kind='png'));
 end loop;
 if nullif(btrim(setting_body),'') is not null then
  body:=setting_body;
  sources:=jsonb_build_array(jsonb_build_object('id',setting_id,'session_id',s.id,'round_id',r.id,
   'kind','setting','actor_id',null,'sequence',0,'body',body,
   'sha256',encode(extensions.digest(convert_to(body,'UTF8'),'sha256'),'hex'),'visibility','public','complete',true));
 end if;
 -- Staff reads this publication in the certified delta, not twice as a setting.
 -- Legacy public path remains unchanged.
 if not mission_generic_owner.flow_scope_enabled(p_session) then
 -- Only public mission publications tied to this run, never an unfiltered chat.
 for row in select w.id,w.result->>'text' body,
 case when w.payload->>'mode'='unified' then coalesce(w.message_id,(select urp.message_id
  from mission_generic_owner.unified_report_publications urp join mission_generic_owner.unified_batches ub on ub.id=urp.batch_id
  where ub.id=w.authority_receipt_id and ub.master_session_id=w.master_session_id and ub.writer_work_id=w.id
   and ub.state='published' and ub.message_id=urp.message_id and urp.primary_report and urp.report_id=ub.source_report_id))
 else w.message_id end message_id from mission_generic_owner.work_items w
  where w.master_session_id=p_session and w.kind='narration' and w.state='completed' and w.payload->>'mode' in('mission','unified')
  order by w.created_at desc limit 1 loop
  if nullif(btrim(row.body),'') is null or not exists(select 1 from public.messages m where m.id=row.message_id
    and m.location_id=place.id and m.recipient_user is null and m.kind='fato' and m.body=row.body)
  then raise exception 'MG_SCENE_CONTINUITY_CHANGED';end if;
  sources:=sources||jsonb_build_array(jsonb_build_object('id','mission:'||row.id,'session_id',s.id,'round_id',r.id,
   'kind','setting','actor_id',null,'sequence',0,'body',row.body,
   'sha256',encode(extensions.digest(convert_to(row.body,'UTF8'),'sha256'),'hex'),'visibility','public','complete',true));
 end loop;
 end if;
 IF scene56_runtime.id IS NOT NULL AND scene56_runtime.last_publication_id IS NOT NULL THEN
  SELECT * INTO STRICT scene56_last FROM public.messages WHERE id=scene56_runtime.last_publication_id
   AND location_id=place.id AND kind='fato' AND recipient_user IS NULL;
  IF encode(extensions.digest(convert_to(scene56_last.body,'UTF8'),'sha256'),'hex') IS DISTINCT FROM scene56_runtime.last_publication_sha256
   THEN RAISE EXCEPTION 'SCENE56_COMBAT_CONTINUITY_CHANGED' USING ERRCODE='PT409';END IF;
  sources:=sources||jsonb_build_array(jsonb_build_object('id','mission:'||scene56_last.id,'session_id',s.id,'round_id',r.id,
   'kind','setting','actor_id',NULL,'sequence',0,'body',scene56_last.body,'sha256',scene56_runtime.last_publication_sha256,
   'visibility','public','complete',true));
 END IF;
 for d in select * from public.combat_v2_declarations where round_id=r.id order by order_no nulls last,id loop
  private_native20:=false;
  select value into strict item from jsonb_array_elements(rep.mechanics->'declarations') where value->>'id'=d.id::text;
  if item->>'actor' is distinct from d.actor_id::text or item->>'kind' is distinct from d.kind
   or item->>'state' is distinct from d.state or item->'outcome' is distinct from d.outcome
   or d.state not in('risolta','superflua') then raise exception 'MG_SCENE_REPORT_CHANGED';end if;
  if d.kind='attacco' and d.sanitized_intent->'target_fili'='true'::jsonb then
   select p into strict puppet from jsonb_array_elements(puppets) p
    where p->>'actor_id'=d.target_actor_id::text;
   select authz.proof into strict cut_proof
    from clan_marionettisti_private.ocular_sever_authorizations_v1 authz
    where authz.request_key=d.request_key and authz.round_id=r.id and authz.actor_id=d.actor_id
     and authz.target_id=d.target_actor_id and authz.proof->>'owner_actor_id'=puppet->>'controller_actor_id'
     and authz.proof->>'companion_actor_id'=d.target_actor_id::text
     and authz.attack_source=d.sanitized_intent#>>'{server_ability,source}'
     and authz.ability_id::text=d.sanitized_intent#>>'{server_ability,id}';
   if d.state='risolta' and (
      d.outcome->'fili_recisi' is null
      or jsonb_typeof(d.outcome->'fili_recisi') is distinct from 'boolean'
      or d.outcome->'success' is distinct from d.outcome->'fili_recisi'
      or d.outcome->'damage_applied' is distinct from '0'::jsonb)
   then raise exception 'MG_SCENE_FILI_OUTCOME_CHANGED' using errcode='55000';end if;
   if d.state='risolta' and d.outcome->'fili_recisi'='true'::jsonb then
    select count(*) into cut_event_count from clan_marionettisti_private.control_events cut
     where cut.session_id=s.id and cut.round_id=r.id and cut.kind='link_severed'
      and cut.source_declaration_id=d.id and cut.request_key=d.id
      and cut.owner_actor_id::text=puppet->>'controller_actor_id'
      and cut.fingerprint=public.combat_v2_sha256(d.outcome)
      and cut.payload->>'authority'='ocular-sever/1'
      and cut.payload->>'companion_actor_id'=d.target_actor_id::text
      and cut.payload->'prior_link_version'=cut_proof->'link_version'
      and cut.payload->'eye_id'=cut_proof->'eye_id'
      and cut.payload->'attack_source'=d.sanitized_intent#>'{server_ability,source}'
      and cut.payload->'attack_id'=d.sanitized_intent#>'{server_ability,id}';
    if cut_event_count<>1 then raise exception 'MG_SCENE_FILI_RECEIPT_MISSING' using errcode='55000';end if;
    cut_status:='recisi';
    cut_description:='I Fili di Chakra che collegano il PNG alla marionetta sono recisi. Il PNG perde il controllo della marionetta. Il taglio non colpisce il corpo della marionetta.';
   elsif d.state='superflua' then
    cut_status:='non_eseguito';
    cut_description:='Il tentativo di recisione non è stato eseguito.';
   else
    cut_status:='non_recisi';
    cut_description:='Il tentativo non recide i Fili di Chakra e non colpisce il corpo della marionetta.';
   end if;
   -- The attack result concerns the control link. It must not appear as a hit on the body.
   projected:=jsonb_build_object('schema_version','combat-narrative-facts/1','kind',d.kind,
    'execution',case when d.state='superflua' then 'not_executed' else 'resolved' end,
    'fili_chakra',jsonb_build_object('esito',cut_status,'marionetta_actor_id',d.target_actor_id,
      'controllore_actor_id',puppet->'controller_actor_id','tecnica',d.sanitized_intent#>'{server_ability,name}',
      'nessun_danno_al_corpo',true,'fatto_narrabile',cut_description));
  elsif d.state='risolta' then projected:=combat_panel_private.narrative_declaration_facts(d.id);
  else
   projected:=jsonb_build_object('execution','not_executed','result',combat_panel_private.narrative_outcome_facts(d.outcome));
   IF d.state='superflua' AND combat_v2_elemental_internal.suiton_narrative_supported(d.id) THEN
    projected:=projected||combat_v2_elemental_internal.suiton_narrative_projection(d.id)||jsonb_build_object('suiton_technique',(SELECT jsonb_build_object('name',s.profile->'name','description',s.profile->'effect_description','limits',s.profile->'limits','provenance','elementali-frozen-tech/1') FROM combat_v2_elemental_internal.suiton_sources s WHERE s.declaration_id=d.id));
   END IF;
  end if;
  IF d.state='superflua' AND d.sanitized_intent->'target_fili' IS DISTINCT FROM 'true'::jsonb
    AND combat_v2_elemental_internal.other_narrative_supported(d.id) THEN
   projected:=projected||combat_v2_elemental_internal.other_narrative_projection(d.id);
  END IF;
  facts:=facts||jsonb_build_array(jsonb_build_object('declaration_id',d.id,'actor_id',d.actor_id,
   'target_actor_id',d.target_actor_id,'kind',d.kind,'facts',projected));
  -- Automatic missing-defence receipts are facts, not a newly invented role.
  if d.kind='nessuna' and coalesce(d.declaration_text,'')='' then continue;end if;
  select * into strict a from public.combat_v2_actors where id=d.actor_id and session_id=s.id;
  select m.id::text,m.body into sid,body from combat_consumer_private.declaration_messages l
   join public.messages m on m.id=l.message_id where l.declaration_id=d.id and m.location_id=place.id
    and m.recipient_user is null and m.kind not in('whisper','motore')
    and public._combat_narrative_sha(m.id)=l.message_sha256
    and ((a.actor_kind='pg' and m.character_id=a.character_id and (
        m.sender_user=a.controller_user
        or (m.sender_user is null and exists(select 1 from combat_panel_private.request_receipts q
          where q.principal_user=a.controller_user and q.request_key=d.request_key
            and q.viewer_envelope#>>'{receipt,declaration_id}'=d.id::text))))
      or (a.actor_kind='png' and m.character_id is null and m.sender_user is null and m.kind='fato'));
  if sid is null and a.actor_kind='png' and (exists(select 1 from mission_generic_owner.unified_round_windows uw where uw.round_id=d.round_id) OR mission_narrative_internal.scene_native_round_bound_v1(p_session,d.round_id))
   and not exists(select 1 from mission_generic_owner.unified_round_windows rw
    join mission_generic_owner.unified_batches batch_row on batch_row.id=rw.batch_id
    where rw.round_id=d.round_id and batch_row.payload->>'schema_version'='mission-generic-narration/4'
      and batch_row.composition_kind='entry_png') then
   select 'choice:'||w.id::text,w.result#>>'{command,narrative_text}' into strict sid,body
   from mission_generic_owner.panel_choices c
   join mission_generic_owner.work_items w on w.id=c.work_id and w.master_session_id=p_session
   join mission_narrative_internal.dispatch_audit da on da.receipt_id=w.dispatch_receipt_id and da.event_code='generic_finalized'
   join combat_panel_private.request_receipts q on q.principal_user=c.principal_id and q.request_key=c.request_key
   where c.encounter_id=s.id and c.actor_id=a.id and c.request_key=d.request_key and c.consumed_at is not null
    and c.result=q.viewer_envelope and c.command_sha256=q.command_fingerprint
    and q.viewer_envelope#>>'{receipt,declaration_id}'=d.id::text
    and w.kind='choice' and w.state='completed'
    and da.details->>'result_sha256'=w.result_sha256
    and da.details->>'result_jsonb_sha256'=public.combat_v2_sha256(w.result)
    and w.result#>>'{command,narrative_text}'=d.declaration_text;
   private_native20:=mission_narrative_internal.scene_native_round_bound_v1(p_session,d.round_id);
  end if;
  if a.actor_kind='png' and not exists(select 1 from mission_generic_owner.panel_choices c
    join combat_panel_private.request_receipts q on q.principal_user=c.principal_id and q.request_key=c.request_key
    where c.encounter_id=s.id and c.actor_id=a.id and c.request_key=d.request_key and c.consumed_at is not null
    and c.result=q.viewer_envelope and c.command_sha256=q.command_fingerprint
    and q.viewer_envelope#>>'{receipt,declaration_id}'=d.id::text)
  then raise exception 'MG_SCENE_PNG_RECEIPT_MISSING';end if;
  if a.actor_kind='png' and (exists(select 1 from mission_generic_owner.unified_round_windows urw where urw.round_id=r.id) OR mission_narrative_internal.scene_native_round_bound_v1(p_session,r.id)) then
   if exists(select 1 from mission_generic_owner.unified_round_windows rw
      join mission_generic_owner.unified_batches batch_row on batch_row.id=rw.batch_id
      where rw.round_id=d.round_id and batch_row.payload->>'schema_version'='mission-generic-narration/4'
       and batch_row.composition_kind='entry_png') then
    select v.source_id::text,v.body into sid,body
     from mission_generic_owner.verified_deferred_source_v4(d.id) v;
    if sid is null then raise exception 'MRS_V4_SCENE_DEFERRED_SOURCE_MISSING';end if;
   else
    sid:=CASE WHEN private_native20 THEN 'native-intent:'||d.id::text ELSE d.id::text END;body:=d.declaration_text;
   end if;
  end if;
  if d.kind='passa' and coalesce(btrim(d.declaration_text),'')='' then
   IF mission_narrative_internal.scene_native_round_bound_v1(p_session,r.id) THEN
    -- The original consumed offer required no role. Keep its mechanics fact; do not invent text or a Unified window.
    PERFORM mission_generic_owner.unified_roleless_receipt(d.id);CONTINUE;
   ELSIF exists(select 1 from mission_generic_owner.unified_round_windows urw where urw.round_id=r.id) THEN
    roleless:=roleless||jsonb_build_array(mission_generic_owner.unified_roleless_receipt(d.id));continue;
   END IF;
  end if;
  if sid is null or nullif(btrim(body),'') is null then raise exception 'MG_SCENE_ROLE_MISSING';end if;
  actions:=actions||jsonb_build_array(jsonb_build_object('actor_id',a.id,'role',case when d.kind='difesa' then 'difesa' else 'azione' end,'source_id',sid));
  sources:=sources||jsonb_build_array(jsonb_build_object('id',sid,'session_id',s.id,'round_id',r.id,'kind',CASE WHEN private_native20 THEN 'native_intent' ELSE 'role' END,
   'actor_id',a.id,'sequence',r.round_no,'body',body,'sha256',encode(extensions.digest(convert_to(body,'UTF8'),'sha256'),'hex'),
   'visibility',CASE WHEN private_native20 THEN 'private_intention' ELSE 'public' END,'complete',true));
 end loop;
 if (jsonb_array_length(actions)=0 and jsonb_array_length(roleless)=0) or jsonb_array_length(facts)<>jsonb_array_length(rep.mechanics->'declarations')
 then raise exception 'MG_SCENE_BARRIER_INCOMPLETE';end if;
 for item in select value from jsonb_array_elements(coalesce(rep.mechanics->'substitution_receipts','[]')) loop
  narrator:=item->'narrator_payload';
  if item->>'round_id' is distinct from r.id::text or narrator->>'schema_version' is distinct from 'common-substitution-narrator/1.0'
   or not exists(select 1 from jsonb_array_elements(actors) ar where ar->>'id'=item->>'actor_id')
  then raise exception 'MG_SCENE_SUBSTITUTION_CHANGED';end if;
  spatial:=spatial||jsonb_build_array(jsonb_build_object('actor_id',item->'actor_id','kind','substitution',
   'outcome',narrator#>'{impact,outcome}','anchor',narrator#>'{anchor,semantic_label}','after',narrator#>'{after,semantic_region}'));
 end loop;
 select count(*) into prior_count from public.combat_v2_narratives n join public.combat_v2_rounds old on old.id=n.round_id
   join public.combat_v2_round_reports q on q.id=n.report_id where old.session_id=s.id and old.round_no<r.round_no
   and old.state='narrato' and q.narration_state='pubblicata';
 if mission_generic_owner.flow_scope_enabled(p_session) then
  continuity_snapshot:=mission_generic_owner.continuity_snapshot(p_session);
 end if;
 -- The declaration list is not an event timeline. The resolved attack's
 -- receipt and the formation's terminal row determine the state after impact.
 if place.is_test and s.lesiva is false and mission_generic_owner.tactics_w9_source_v1(p_session) is not null then
  select jsonb_agg(jsonb_build_object(
    'actor_id',formation.actor_id,
    'creation_declaration_id',formation.declaration_id,
    'attack_declaration_id',attack_target.attack_declaration_id,
    'mode','copertura','attack_outcome',resolution.outcome,
    'formation_state_at_round_end','consumed','protection_active_at_round_end',false)
   order by formation.actor_id,attack_target.attack_declaration_id,attack_target.ordinal,formation.id)
  into cover_terminal
  from jsonb_array_elements(case when jsonb_typeof(rep.mechanics->'attack_targets')='array'
    then rep.mechanics->'attack_targets' else '[]'::jsonb end) sealed_target(target_fact)
  join public.combat_v2_attack_targets attack_target
   on attack_target.id::text=sealed_target.target_fact->>'id'
   and attack_target.round_id=r.id and attack_target.state='risolta'
   and attack_target.outcome=sealed_target.target_fact->'outcome'
  join combat_panel_private.multiplication_resolutions resolution
   on resolution.attack_target_id=attack_target.id
  join combat_panel_private.multiplication_formations formation
   on formation.id=resolution.formation_id and formation.actor_id=attack_target.target_actor_id
   and formation.session_id=s.id and formation.round_id=r.id
   and formation.mode='copertura' and formation.state='consumed'
   and formation.terminal_reason='first_attack' and formation.ended_at<=r.resolved_at
  join public.combat_v2_actors cover_actor
   on cover_actor.id=formation.actor_id and cover_actor.session_id=s.id and cover_actor.actor_kind='png'
  join public.combat_v2_provider_instances_v1 cover_provider
   on cover_provider.id=cover_actor.provider_instance_v1_id and cover_provider.session_id=s.id
   and cover_provider.provider='ninja_book'
   and cover_provider.mechanical_version_ref='31da0000-0000-4000-8000-000000000111'::uuid
  where resolution.receipt_sha256=public.combat_v2_sha256(resolution.facts)
   and resolution.outcome in ('copy_hit','original_found')
   and resolution.facts->>'outcome'=resolution.outcome
   and resolution.facts->>'mode'=formation.mode
   and resolution.facts->>'formation_id'=formation.id::text
   and resolution.facts->>'attack_target_id'=attack_target.id::text
   and attack_target.outcome->'multiplication' @> jsonb_build_array(jsonb_build_object(
    'schema_version','combat-multiplication-resolution/1','role','targeted','mode',formation.mode,
    'formation_id',formation.id,'attack_target_id',attack_target.id,'outcome',resolution.outcome));
 end if;
 snapshot:=jsonb_build_object('schema_version','combat-scene/1','session_id',s.id,'round_id',r.id,
  'report_sha256',rep.mechanics_sha256,'control_version',run.control_version,'location',loc,'actors',actors,'actions',actions,
  'resolved_facts',(jsonb_build_object('schema_version','mission-generic-resolved-facts/1','round_no',r.round_no,
   'declarations',facts,'spatial',spatial)
   ||case when jsonb_array_length(puppets)=0 then '{}'::jsonb
     else jsonb_build_object('marionette_controllate',puppets) end
   ||case when cover_terminal is null then '{}'::jsonb
    else jsonb_build_object('multiplication_terminal',cover_terminal) end
   ||clan_hoki_private.narrative_facts(rep.mechanics->'hoki_facts',actors))::text,'sources',sources,
  'selection',jsonb_build_object('max_input_bytes',input_cap,'previous_available',prior_count,'previous_included',0));
 if octet_length(snapshot::text)>input_cap then raise exception 'MG_SCENE_REQUIRED_CONTEXT_OVERFLOW' using errcode='54000';end if;
 if not mission_generic_owner.flow_scope_enabled(p_session) then
 for row in select n.id,n.round_id,n.body,old.round_no,q.message_id from public.combat_v2_narratives n
  join public.combat_v2_rounds old on old.id=n.round_id and old.session_id=s.id
  join public.combat_v2_round_reports q on q.id=n.report_id and q.round_id=old.id
  where old.round_no<r.round_no and old.state='narrato' and q.narration_state='pubblicata' and not exists(select 1 from mission_generic_owner.unified_report_publications urp where urp.report_id=q.id and not urp.primary_report) order by old.round_no desc,n.id loop
  if not exists(select 1 from public.messages m where m.id=row.message_id and m.location_id=place.id and m.body=row.body
    and m.character_id is null and m.sender_user is null and m.recipient_user is null and m.kind='fato')
  then raise exception 'MG_SCENE_PREVIOUS_CHANGED';end if;
  candidate:=jsonb_set(snapshot,'{sources}',snapshot->'sources'||jsonb_build_array(jsonb_build_object('id',row.id,
   'session_id',s.id,'round_id',row.round_id,'kind','fato','actor_id',null,'sequence',row.round_no,'body',row.body,
   'sha256',encode(extensions.digest(convert_to(row.body,'UTF8'),'sha256'),'hex'),'visibility','public','complete',true)));
  candidate:=jsonb_set(candidate,'{selection,previous_included}',to_jsonb(included+1));
  if octet_length(candidate::text)<=input_cap then snapshot:=candidate;included:=included+1;end if;
 end loop;
 end if;
 scenehash:=public.combat_v2_sha256(snapshot);
 payload:=jsonb_build_object('schema_version',case when director is null then 'mission-generic-narration/1' else 'mission-generic-narration/2' end,
   'mode','combat','scene',jsonb_build_object('snapshot',snapshot,'snapshot_sha256',scenehash),
   'scene_binding',jsonb_build_object('session_id',s.id,'round_id',r.id,'report_sha256',rep.mechanics_sha256,
    'control_version',run.control_version,'hash_authority','combat_v2_sha256/jsonb','scene_sha256',scenehash),
   'barrier',jsonb_build_object('closed',true,'required_receipt_ids',jsonb_build_array(rep.id),'receipt_ids',jsonb_build_array(rep.id)));
 if director is not null then
  payload:=payload||jsonb_build_object('director_context',director,'knowledge_context',knowledge_context,
   'source_cursor',jsonb_build_object('scope','combat_declarations','through',r.resolved_at));
 end if;
 if continuity_snapshot is not null then
  payload:=payload||jsonb_build_object('continuity',continuity_snapshot->'continuity',
   'history_chain_sha256',continuity_snapshot->'history_chain_sha256',
   'history_count',continuity_snapshot->'history_count',
   'continuity_delta',continuity_snapshot->'delta');
 end if;
 if jsonb_array_length(roleless)>0 then payload:=payload||jsonb_build_object('roleless_declarations',roleless);end if;
 return jsonb_build_object('master_session_id',p_session,'step_key',run.current_step_key,'run_control_version',run.control_version,
  'encounter_id',s.id,'authority_receipt_id',rep.id,'payload',payload);
end $function$;

-- Isolated source-only candidate. Apply after independent review and reconciliation.
-- Authoring only. No launch, provider call, catalogue publish or admission.
DO $pin$
DECLARE f regprocedure:=to_regprocedure('public.mission_human_staff_source_create_v1(uuid,jsonb,uuid)');
BEGIN
 IF f IS NULL THEN RAISE EXCEPTION 'FILI_STAFF_AUTHORING_BASE_MISSING' USING ERRCODE='40001'; END IF;
 IF to_regclass('clan_marionettisti_private.mission_companion_entitlements_v1') IS NULL
 THEN RAISE EXCEPTION 'FILI_STAFF_AUTHORING_ENTITLEMENT_UNINSTALLED' USING ERRCODE='40001'; END IF;
 IF md5(pg_get_functiondef(f)) IS DISTINCT FROM '0a55e640f29e34221aa5cf26d64a5c84'
 OR (SELECT proacl::text FROM pg_proc WHERE oid=f) IS DISTINCT FROM '{postgres=X/postgres,authenticated=X/postgres}'
 THEN RAISE EXCEPTION 'FILI_STAFF_AUTHORING_BASE_DRIFT' USING ERRCODE='40001'; END IF;
END $pin$;

CREATE OR REPLACE FUNCTION public.mission_human_staff_source_create_v1(p_request uuid, p_document jsonb, p_location uuid)
 RETURNS jsonb
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO ''
AS $function$
DECLARE old record;pf jsonb;validation jsonb;m jsonb;
 mid uuid;doc_sha text;source_result jsonb;scene jsonb;enc jsonb;actor jsonb;enc_count integer:=0;
 named_ai boolean:=false; fili_ai boolean:=false; expected_xp integer:=30;pin record;reference jsonb;
 staff_definition uuid;
BEGIN
 IF auth.uid() IS NULL OR auth.role() IS DISTINCT FROM 'authenticated' OR p_request IS NULL
 OR p_location IS DISTINCT FROM '0b85f354-9cdb-47e1-baf9-3d266bb7e06b'::uuid
 THEN RAISE EXCEPTION 'H3_STAFF_SOURCE_AUTHORITY' USING ERRCODE='42501'; END IF;
 PERFORM mission_ai_board_owner.staff_only();
 PERFORM 1 FROM public.locations WHERE id=p_location AND is_active AND is_test FOR SHARE;
 IF NOT FOUND OR NOT public.master_v2_is_master(auth.uid())
 OR combat_consumer_private.staff_test_allowed(p_location,ARRAY[auth.uid()],false) IS DISTINCT FROM true
 THEN RAISE EXCEPTION 'H3_STAFF_SOURCE_AUTHORITY' USING ERRCODE='42501'; END IF;
 fili_ai:=p_document IS NOT DISTINCT FROM '{"schema_version":"mission-creation-staff-fili-source/1","mission":{"direction_mode":"ai"}}'::jsonb;
 IF fili_ai THEN
  IF p_request IS DISTINCT FROM '14136a56-0f58-41b2-ae24-8f7f3acbb4b2'::uuid OR auth.uid() IS DISTINCT FROM 'f0856d53-83a6-4de0-bc0c-12c87916e665'::uuid
  THEN RAISE EXCEPTION 'H3_STAFF_SOURCE_FILI_SCOPE' USING ERRCODE='42501'; END IF;
  p_document:=$fili_doc${"schema_version":"mission-creation-document/1","mission":{"title":"Recisione dei Fili · Prova Regia IA","grado":"D","briefing":"Nel campo simulato della Staff Test Room, Iori Mizuhara conduce una marionetta da esercitazione e affronta Riuji e testperfunzioni in un breve scontro controllato. I partecipanti decidono le proprie azioni. La presenza della marionetta e lo stato dei fili sono quelli attestati dal motore. La prova non assegna premi.","village":"","tag_trama":"Staff · Recisione dei Fili · Regia IA","team_min":2,"team_max":2,"direction_mode":"ai","gathering_location_id":"f91ba1a5-f839-426c-8f31-f159fbc88697"},"plan":{"schema_version":"mission-generic-plan-document/1","base_plan_version_id":null,"initial_step_key":"inizio","steps":[{"step_key":"inizio","kind":"mechanical","public_objective":"Affrontare il marionettista nel campo simulato e osservare gli effetti attestati delle azioni."},{"step_key":"conclusione","kind":"narrative","public_objective":"Registrare l'esito del confronto e chiudere il campo di prova."}],"transitions":[{"transition_key":"inizio_esito","from_step_key":"inizio","to_step_key":"conclusione","event_kind":"inizio_esito","priority":0}],"definition":{"schema_version":"mission-generic-definition/1","scenes":[{"step_key":"inizio","actors":[{"actor_key":"png_1","mechanical_binding_id":"dec31d7d-5314-4f41-b68b-8f7b1f8fb002","narrative_template_id":"656490d0-643f-4514-bcb3-3602856da755","narrative_version_id":"92782adb-d8d8-4701-9108-1b97c42d1e5d","team":"marionettista"}],"encounters":[{"encounter_key":"enc_inizio","pg_policy":"all_active","pg_team":"partecipanti","actors":[{"actor_key":"png_1","mechanical_binding_id":"dec31d7d-5314-4f41-b68b-8f7b1f8fb002","narrative_template_id":"656490d0-643f-4514-bcb3-3602856da755","narrative_version_id":"92782adb-d8d8-4701-9108-1b97c42d1e5d","team":"marionettista"}],"arena_ref":"mission"}],"triggers":[{"trigger_key":"esito","transition_key":"inizio_esito","source_kind":"combat_terminal","fact_code":"combat_terminal_confirmed","label":"Conclusione del confronto","encounter_key":"enc_inizio","combat_outcome":"any"}]},{"step_key":"conclusione","actors":[],"encounters":[],"triggers":[]}]},"terminal_steps":[{"step_key":"conclusione","outcome":"success"}]},"editorial":{"plot_private":"Esercitazione riservata alla Staff. Iori Mizuhara assume il ruolo di marionettista avversario in questa sola scena. Il costrutto e i fili risultano presenti soltanto quando il motore li lega al suo attore. Ogni azione e risultato viene determinato dal motore. Il Fato distingue il taglio dei fili da un colpo alla marionetta e racconta solo il fatto registrato. Riuji e testperfunzioni decidono liberamente cosa fare. La conclusione non certifica il collaudo.","setting":{"name":"Campo di addestramento simulato","description":"Su un terreno delimitato con un sasso e un tronco si svolge un confronto con un solo marionettista. Iori Mizuhara è presente come esercitatore. Posizioni, ingombri e ostacoli seguono la mappa nativa."},"scenes":[{"step_key":"inizio","setting":{"name":"","description":""},"director_notes":"Accogli le decisioni esplicite dei partecipanti e apri il confronto quando le loro role confermano che sono pronti. Puoi usare soltanto le azioni che il pannello rende disponibili. Le reazioni del marionettista e gli effetti sul collegamento sono quelli attestati. La marionetta resta distinta dai fili e dal manovratore.","entry_public":"Il campo simulato è delimitato da due riferimenti sul terreno, il sasso e il tronco. Iori Mizuhara aspetta come marionettista avversario della prova. I partecipanti scelgono se dichiararsi pronti e come affrontarlo. Si applicano le azioni e le conseguenze del combattimento nativo.","actors":[{"actor_key":"png_1","role_in_phase":"Iori Mizuhara interpreta il marionettista avversario in questa sola scena Staff.","goal_private":"Offrire un confronto controllato. Accetta l'attacco dichiarato dai partecipanti e scegli soltanto reazioni native effettivamente offerte. Il motore risolve il tentativo. Se la marionetta perde il collegamento, considera esclusivamente l'esito attestato.","known_facts_private":"Conosce i limiti dell'esercizio, la mappa percepibile e la propria marionetta quando il motore conferma il collegamento.","public_portrayal":"Un esercitatore avversario che assume il ruolo di marionettista nella Staff Test Room."}],"consequences":[{"transition_key":"inizio_esito","public_fact":"Il confronto ha raggiunto l'esito registrato dal motore.","private_note":"Conservare distinti attacchi, eventuale taglio dei fili e integrità del costrutto."}]},{"step_key":"conclusione","setting":{"name":"","description":""},"director_notes":"Racconta soltanto l'esito certificato dal motore, poi concludi l'esercitazione.","entry_public":"Il confronto si conclude. Il resoconto riprende l'esito attestato e il campo torna a disposizione della Staff.","actors":[],"consequences":[]}]},"arenas":[]}$fili_doc$::jsonb;
 END IF;
 doc_sha:=mission_internal.fingerprint(p_document);
 -- Named authoring only. This creates neither an admission nor a Service session.
 IF fili_ai IS DISTINCT FROM (doc_sha='6a1c785a06464fcc3310727bc700f767c77fbf411982ba87090e009ec470210f')
 THEN RAISE EXCEPTION 'H3_STAFF_SOURCE_FILI_DOCUMENT_NOT_PINNED' USING ERRCODE='42501'; END IF;
 named_ai:=fili_ai OR doc_sha='e7c1cfc8ea3fdf59753fc8457718f34ca119dce0f24368c00d34ef8a5298b028';
 IF named_ai THEN
  IF auth.uid() NOT IN ('f0856d53-83a6-4de0-bc0c-12c87916e665'::uuid,'15448f47-3b43-416f-a703-dbe7a74d36ce'::uuid)
   OR NOT EXISTS(SELECT 1 FROM public.characters ch WHERE ch.id='6bceee99-974f-426b-8d92-38b43b4a4267'::uuid AND ch.user_id='f0856d53-83a6-4de0-bc0c-12c87916e665'::uuid)
   OR NOT EXISTS(SELECT 1 FROM public.characters ch WHERE ch.id='2a877f02-4993-4e65-9172-7d29f08c5b86'::uuid AND ch.user_id='15448f47-3b43-416f-a703-dbe7a74d36ce'::uuid)
  THEN RAISE EXCEPTION 'H3_STAFF_SOURCE_TACTICS_PRINCIPALS' USING ERRCODE='42501';END IF;
  expected_xp:=0;
 END IF;
 PERFORM pg_advisory_xact_lock(hashtextextended('mission-create:'||p_request::text,611));
 SELECT * INTO old FROM mission_creation_owner.h3_staff_source_requests WHERE request_key=p_request;
 IF FOUND THEN
  IF old.actor_user IS DISTINCT FROM auth.uid() OR old.document_sha256 IS DISTINCT FROM doc_sha
  THEN RAISE EXCEPTION 'H3_STAFF_SOURCE_REPLAY_CONFLICT' USING ERRCODE='40001'; END IF;
  RETURN old.result;
 END IF;
 IF EXISTS(SELECT 1 FROM mission_creation_owner.requests WHERE request_key=p_request)
 THEN RAISE EXCEPTION 'H3_STAFF_SOURCE_REQUEST_CONFLICT' USING ERRCODE='40001'; END IF;
 IF named_ai THEN
  -- Serialize different request keys for this one frozen authoring input.
  PERFORM pg_advisory_xact_lock(hashtextextended('mission-create-document:'||doc_sha,611));
  IF EXISTS(SELECT 1 FROM mission_creation_owner.h3_staff_source_requests r WHERE r.document_sha256=doc_sha)
  THEN RAISE EXCEPTION 'H3_STAFF_SOURCE_TACTICS_ALREADY_CREATED' USING ERRCODE='40001';END IF;
  IF fili_ai THEN
   PERFORM 1 FROM public.nb_mechanical_bindings mb
    JOIN public.nb_mechanical_versions mv ON mv.id=mb.mechanical_version_id AND mv.template_id=mb.mechanical_template_id
    JOIN public.nb_template_versions nv ON nv.id=mb.narrative_version_id AND nv.template_id=mb.narrative_template_id
    JOIN public.nb_templates nt ON nt.id=nv.template_id
   WHERE mb.id='dec31d7d-5314-4f41-b68b-8f7b1f8fb002'::uuid AND mb.active AND mb.lifecycle_state='approved'
    AND mb.narrative_template_id='656490d0-643f-4514-bcb3-3602856da755'::uuid
    AND nt.lifecycle_state='approved' AND nt.village_scope='Staff Test Room'
    AND nv.id='92782adb-d8d8-4701-9108-1b97c42d1e5d'::uuid AND nv.review_state='approved'
    AND nv.content_sha256='f438d0dc9c6eac3a213298b77af9a2d6a5eb8c8b5dbefba7c7415113cc0ad5c2'
    AND mb.mechanical_template_id='bb29392b-28e1-4f0d-ba47-a2c9c24527ba'::uuid
    AND mv.id='2fe0fc4b-e560-40ea-9196-e5b376d25bc6'::uuid AND mv.review_state='approved'
    AND mv.content_sha256='5d18bef2d7f2b2219a0a1ae654551f3ebc73d009403b80d9d4d389875bfce0a7'
   FOR SHARE OF mb,mv,nv,nt;
   IF NOT FOUND THEN RAISE EXCEPTION 'H3_STAFF_SOURCE_FILI_PROFILE_DRIFT' USING ERRCODE='40001'; END IF;
  ELSE
   FOR pin IN SELECT * FROM (VALUES
   ('31da0000-0000-4000-8000-000000000201'::uuid,'31da0000-0000-4000-8000-000000000211'::uuid,'31da0000-0000-4000-8000-000000000301'::uuid,'31da0000-0000-4000-8000-000000000101'::uuid,'31da0000-0000-4000-8000-000000000111'::uuid,'5581b06099e588b27361cdf75e0e6265475c330802f61034c6ad67ca3d381ad2','c67d27b6-3e2d-4e91-beeb-e8c5cd1590f8'::uuid,'901a6a8b17fa8e2038ce5230f835ac95135688631ddd0816ec40f0333e9f0d5a'),
   ('31da0000-0000-4000-8000-000000000202'::uuid,'31da0000-0000-4000-8000-000000000212'::uuid,'31da0000-0000-4000-8000-000000000302'::uuid,'31da0000-0000-4000-8000-000000000102'::uuid,'31da0000-0000-4000-8000-000000000112'::uuid,'bbe92ed1b3dd171c6498f1a1541ad6b391c80e015956ae748c1eeece17f99fac','628d7118-a9e3-43d2-8dbd-2cbac0736205'::uuid,'45592ba1e150f55230d6429f7cf6ef02bebc510118301bcf93c37c0d07635e84')
  ) AS pins(nt,nv,binding,mt,mv,mechanical_sha,bundle,bundle_sha) LOOP
   PERFORM 1 FROM public.nb_mechanical_bindings mb
    JOIN public.nb_mechanical_versions mv ON mv.id=mb.mechanical_version_id AND mv.template_id=mb.mechanical_template_id
    JOIN public.nb_template_versions nv ON nv.id=mb.narrative_version_id AND nv.template_id=mb.narrative_template_id
    JOIN public.nb_templates nt ON nt.id=nv.template_id
    JOIN png_builder_internal.bundles b ON b.id=pin.bundle AND b.template_id=nt.id
   WHERE mb.id=pin.binding AND mb.narrative_template_id=pin.nt AND mb.narrative_version_id=pin.nv
    AND mb.mechanical_template_id=pin.mt AND mb.mechanical_version_id=pin.mv
    AND mv.content_sha256=pin.mechanical_sha AND b.bundle_sha256=pin.bundle_sha
   FOR SHARE OF mb,mv,nv,nt,b;
   IF NOT FOUND THEN RAISE EXCEPTION 'H3_STAFF_SOURCE_TACTICS_PROFILE_DRIFT' USING ERRCODE='40001';END IF;
   reference:=mission_factory_owner.npc_reference(pin.nt,pin.bundle,true);
   IF reference->>'bundle_sha256' IS DISTINCT FROM pin.bundle_sha
    OR reference->>'narrative_version_id' IS DISTINCT FROM pin.nv::text
    OR reference->>'mechanical_binding_id' IS DISTINCT FROM pin.binding::text
    OR reference->>'mechanical_version_id' IS DISTINCT FROM pin.mv::text
    OR reference->'combat' IS DISTINCT FROM 'true'::jsonb
   THEN RAISE EXCEPTION 'H3_STAFF_SOURCE_TACTICS_PROFILE_DRIFT' USING ERRCODE='40001';END IF;
   END LOOP;
  END IF;
 END IF;
 pf:=mission_creation_owner.preflight_document_v2(p_document);
 IF (pf->>'ok')::boolean IS DISTINCT FROM true
 THEN RAISE EXCEPTION 'H3_STAFF_SOURCE_PREFLIGHT:%',pf->'errors' USING ERRCODE='22023'; END IF;
 m:=p_document->'mission';
 IF (NOT named_ai AND m->>'direction_mode' IS DISTINCT FROM 'human')
 OR (named_ai AND (m->>'direction_mode' IS DISTINCT FROM 'ai' OR m->>'team_min' IS DISTINCT FROM '2' OR m->>'team_max' IS DISTINCT FROM '2'))
 OR (m->>'team_min' IN ('1','2','3','4')) IS NOT TRUE
 OR (m->>'team_max' IN ('1','2','3','4')) IS NOT TRUE
 OR (m->>'team_min')::integer > (m->>'team_max')::integer
 OR p_document#>>'{plan,base_plan_version_id}' IS NOT NULL
 THEN RAISE EXCEPTION 'H3_STAFF_SOURCE_SCOPE' USING ERRCODE='22023'; END IF;
 FOR scene IN SELECT value FROM jsonb_array_elements(p_document#>'{plan,definition,scenes}') LOOP
  FOR enc IN SELECT value FROM jsonb_array_elements(coalesce(scene->'encounters','[]'::jsonb)) LOOP
   enc_count:=enc_count+1;
   IF (jsonb_array_length(enc->'actors') BETWEEN 1 AND 4) IS NOT TRUE
   THEN RAISE EXCEPTION 'H4_STAFF_SOURCE_PNG_COUNT' USING ERRCODE='22023'; END IF;
   IF EXISTS(SELECT 1 FROM jsonb_array_elements(enc->'actors') a WHERE nullif(a->>'actor_key','') IS NULL)
    OR (SELECT count(DISTINCT a->>'actor_key') FROM jsonb_array_elements(enc->'actors') a) <> jsonb_array_length(enc->'actors')
   THEN RAISE EXCEPTION 'H4_STAFF_SOURCE_DISTINCT_ACTORS' USING ERRCODE='22023'; END IF;
   FOR actor IN SELECT value FROM jsonb_array_elements(enc->'actors') LOOP
    IF (NOT named_ai AND actor->>'mechanical_binding_id' IS DISTINCT FROM '66a6628d-d465-4103-b74b-2184f4b07d04')
     OR (named_ai AND NOT fili_ai AND actor->>'mechanical_binding_id' NOT IN ('31da0000-0000-4000-8000-000000000301','31da0000-0000-4000-8000-000000000302'))
     OR (fili_ai AND (
      (scene->>'step_key') IS DISTINCT FROM 'inizio'
      OR NOT EXISTS (SELECT 1 FROM jsonb_array_elements(p_document#>'{plan,steps}') s WHERE s->>'step_key'='inizio' AND s->>'kind'='mechanical')
      OR (enc->>'encounter_key') IS DISTINCT FROM 'enc_inizio' OR jsonb_array_length(enc->'actors')<>1
      OR (actor->>'actor_key') IS DISTINCT FROM 'png_1'
      OR (actor->>'mechanical_binding_id') IS DISTINCT FROM 'dec31d7d-5314-4f41-b68b-8f7b1f8fb002'))
    THEN RAISE EXCEPTION 'H3_STAFF_SOURCE_APPROVED_PROFILE_REQUIRED' USING ERRCODE='42501'; END IF;
   END LOOP;
  END LOOP;
 END LOOP;
 IF enc_count<>1 THEN RAISE EXCEPTION 'H3_STAFF_SOURCE_ONE_ENCOUNTER' USING ERRCODE='22023'; END IF;
 validation:=mission_creation_owner.map_binding_guard_mission_publish_v1(p_document,mission_creation_owner.validate_document(p_document));
 mid:=public.missione_crea(m->>'title',m->>'grado',m->>'briefing',nullif(m->>'village',''),m->>'tag_trama',(m->>'team_min')::integer,(m->>'team_max')::integer,validation->>'gathering_name',expected_xp,0);
 -- La stessa transazione non espone mai la fonte aperta alla bacheca o alle iscrizioni.
 UPDATE public.missions SET status='annullata' WHERE id=mid AND status='aperta';
 IF NOT FOUND THEN RAISE EXCEPTION 'H3_STAFF_SOURCE_RESERVATION_FAILED'; END IF;
 source_result:=mission_creation_owner.save_complete(mid,p_request,mission_internal.fingerprint(mission_generic_owner.mission_editor_snapshot(mid)),0,p_document);
 IF source_result->>'schema_version' IS DISTINCT FROM 'mission-creation-result/1'
 OR source_result->>'mission_id' IS DISTINCT FROM mid::text OR source_result->>'state' IS DISTINCT FROM 'configured'
 OR NOT EXISTS(SELECT 1 FROM public.missions WHERE id=mid AND status='annullata' AND xp_reward=expected_xp AND ryo_reward=0
 AND team_min=(m->>'team_min')::integer AND team_max=(m->>'team_max')::integer)
 THEN RAISE EXCEPTION 'H3_STAFF_SOURCE_POSTCONDITION'; END IF;
 IF fili_ai THEN
  SELECT d.id INTO STRICT staff_definition FROM mission_generic_owner.plan_revisions rev
   JOIN mission_generic_owner.definitions d ON d.id=rev.definition_id
   WHERE rev.plan_version_id=(source_result->>'plan_version_id')::uuid AND rev.mission_id=mid
    AND d.definition_sha256=mission_internal.fingerprint(p_document#>'{plan,definition}')
    AND d.definition=p_document#>'{plan,definition}';
  INSERT INTO clan_marionettisti_private.mission_companion_entitlements_v1
   (definition_id,step_key,encounter_key,actor_key,mechanical_binding_id,staff_enabled,land_enabled)
  VALUES (staff_definition,'inizio','enc_inizio','png_1','dec31d7d-5314-4f41-b68b-8f7b1f8fb002'::uuid,true,false);
 END IF;
 INSERT INTO mission_creation_owner.h3_staff_source_requests(request_key,actor_user,document_sha256,mission_id,result)
 VALUES(p_request,auth.uid(),doc_sha,mid,source_result);
 RETURN source_result;
END $function$;

CREATE OR REPLACE FUNCTION public.mission_generic_staff_test_start_v1(p_source_mission uuid, p_location uuid, p_roster uuid[], p_request uuid)
 RETURNS jsonb
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO ''
AS $function$
declare src public.missions;sel jsonb;arena jsonb;carrier_arena jsonb;doc jsonb;sealed jsonb;def jsonb;
 carrier uuid:=gen_random_uuid();aid uuid;fp text;r jsonb;old mission_generic_owner.simulation_sources;sha text;
begin
 perform mission_ai_board_owner.staff_only();
 -- C1266_AVAILABILITY_COORD: shared before mutation locks; xact lifetime.
 PERFORM pg_catalog.pg_advisory_xact_lock_shared(pg_catalog.hashtextextended('C1266:GENERIC-AI:AVAILABILITY',0));
 perform mission_ai_board_owner.lock_request(p_request);
 fp:=mission_internal.fingerprint(jsonb_build_object('source_mission',p_source_mission,'location',p_location,'roster',to_jsonb(p_roster)));
 IF EXISTS(SELECT 1 FROM mission_generic_owner.manual_staff_start_rejections_v1 denied WHERE denied.request_key=p_request) THEN RAISE EXCEPTION 'MANUAL_STAFF_START_REQUEST_REJECTED' USING ERRCODE='40001';END IF;
 select * into old from mission_generic_owner.simulation_sources where request_key=p_request;
 if found then
  if old.request_fingerprint<>fp then raise exception 'MGB_TEST_REQUEST_CONFLICT' using errcode='40001';end if;
  select s.result into strict r from mission_generic_owner.board_starts s join public.master_v2_sessions m on m.id=s.master_session_id
   where m.mission_id=old.carrier_mission_id;
  IF NOT EXISTS(SELECT 1 FROM mission_generic_owner.start_claims sc WHERE sc.request_key=p_request AND sc.actor_user_id=auth.uid()) THEN RAISE EXCEPTION 'MANUAL_STAFF_START_REPLAY_OWNER' USING ERRCODE='42501';END IF;
  return r||jsonb_build_object('source_mission_id',old.source_mission_id,'replay',true);
 end if;
 perform mission_generic_owner.location_runtime(p_location,true);
 select * into strict src from public.missions where id=p_source_mission for share;
 if exists(select 1 from mission_generic_owner.simulation_sources where carrier_mission_id=src.id)
 then raise exception 'MGB_TEST_SOURCE_MUST_BE_ORIGINAL' using errcode='22023';end if;
 -- Validate all principals before creating even the carrier/pinned copy.
 perform mission_generic_owner.staff_roster_assert(p_location,p_roster);
 sel:=mission_generic_owner.historical_plan(src.id);
 select definition into strict def from mission_generic_owner.definitions where id=(sel->>'definition_id')::uuid;
 arena:=mission_generic_owner.arena_source(src.id,p_location);
 insert into public.missions(id,title,village,grado,briefing,tag_trama,xp_reward,ryo_reward,team_min,team_max,location_hint,status,created_by)
 values(carrier,'Prova · '||src.title,src.village,src.grado,src.briefing,src.tag_trama,0,0,src.team_min,src.team_max,src.location_hint,'annullata',auth.uid());
 doc:=jsonb_build_object('schema_version','mission-generic-plan-document/1','base_plan_version_id',null,
  'initial_step_key',(select initial_step_key from public.mission_plan_versions where id=(sel->>'plan_version_id')::uuid),
  'steps',(select jsonb_agg(jsonb_build_object('step_key',step_key,'kind',kind,'public_objective',public_objective) order by ordinal)
   from public.mission_plan_steps where plan_version_id=(sel->>'plan_version_id')::uuid),
  'transitions',(select coalesce(jsonb_agg(jsonb_build_object('transition_key',transition_key,'from_step_key',from_step_key,'to_step_key',to_step_key,'event_kind',event_kind,'priority',priority) order by transition_key),'[]'::jsonb)
   from public.mission_plan_transitions where plan_version_id=(sel->>'plan_version_id')::uuid),
  'definition',def,'terminal_steps',sel#>'{settings,terminal_steps}');
 sha:=mission_internal.fingerprint(mission_generic_owner.mission_editor_snapshot(carrier));
 sealed:=public.mission_generic_plan_seal_v1(carrier,gen_random_uuid(),sha,doc);
 perform mission_creation_owner.copy_revision((sel->>'plan_version_id')::uuid,(sealed->>'plan_version_id')::uuid,carrier);
 perform public.mission_generic_plan_select_v1(carrier,(sealed->>'plan_version_id')::uuid,0,gen_random_uuid());
 insert into mission_generic_owner.simulation_sources(carrier_mission_id,source_mission_id,source_plan_version_id,source_sha256,request_key,request_fingerprint)
 values(carrier,src.id,(sel->>'plan_version_id')::uuid,mission_internal.fingerprint(sel),p_request,fp);

 if mission_academy_owner.is_academy(src.id) then
  insert into mission_academy_owner.policies
   (mission_id,policy_key,display_grade,village,min_rank,max_rank,xp_reward,ryo_reward,always_complete,context_only,rescue_before_ko,active)
  select carrier,policy_key||':staff:'||carrier::text,display_grade,village,min_rank,max_rank,xp_reward,ryo_reward,always_complete,context_only,rescue_before_ko,active
   from mission_academy_owner.policies where mission_id=src.id and active;
  if not found then raise exception 'ACADEMY_STAFF_SOURCE_POLICY_MISSING' using errcode='22023';end if;
  insert into mission_academy_owner.roster_actor_rules(mission_id,actor_key,min_roster,active)
   select carrier,actor_key,min_roster,active from mission_academy_owner.roster_actor_rules where mission_id=src.id;
  insert into mission_academy_owner.d100_challenges
   (mission_id,step_key,ordinal,challenge_key,threshold,support_threshold,success_fact,complication_fact,active)
   select carrier,step_key,ordinal,challenge_key,threshold,support_threshold,success_fact,complication_fact,active
   from mission_academy_owner.d100_challenges where mission_id=src.id;
 end if;
 if p_location='0b85f354-9cdb-47e1-baf9-3d266bb7e06b'::uuid
  and arena @> '{"origin":"default","config_revision":0,"zone_key":"arena"}'::jsonb
  and exists(select 1 from clan_marionettisti_private.mission_companion_entitlements_v1 reserved
    where reserved.definition_id=(sel->>'definition_id')::uuid and reserved.staff_enabled and not reserved.land_enabled)
 then
  -- The carrier can use the same server default. It cannot own that global binding.
  select mission_generic_owner.arena_source(carrier,p_location) into carrier_arena;
  if carrier_arena->>'origin' is distinct from 'default'
   or carrier_arena->>'template_key' is distinct from arena->>'template_key'
   or carrier_arena->>'template_version' is distinct from arena->>'template_version'
   or carrier_arena->>'zone_key' is distinct from arena->>'zone_key'
   or carrier_arena->>'catalog_sha256' is distinct from arena->>'catalog_sha256'
  then raise exception 'MGB_STAFF_DEFAULT_ARENA_DRIFT' using errcode='40001';end if;
 elsif arena->>'template_key' is not null then
  perform public.universal_arena_configure_v1('mission',carrier,arena->>'template_key',(arena->>'template_version')::integer,arena->>'zone_key',0);
 end if;
 insert into mission_ai_board_owner.activations(mission_id,package_id,generic_plan_version_id,location_id,mission_seal_sha256,state)
 values(carrier,null,(sealed->>'plan_version_id')::uuid,p_location,sha,'enrollment_open') returning id into aid;
 r:=mission_generic_owner.prepare_start(aid,p_roster,p_request,fp,true);
 -- Event42: only this newly accepted AI Staff start creates a server root. No replay/backfill.
 DECLARE cfg jsonb;sid uuid;ek uuid;ev bigint:=1;domain text:='start';source_id uuid:=p_request;
 source_sha text;rootrow mission_generic_owner.event_outbox_v1;request_id bigint;affected integer;
 BEGIN
 SELECT rr.canonical_preimage::jsonb#>'{config,c1266_server_events}' INTO cfg
 FROM mission_factory_owner.editor_release_readiness rr WHERE rr.singleton AND rr.state='enabled' AND rr.scope='staff';
 IF cfg->>'schema_version'='c1266-server-events/1' AND cfg->'enabled'='true'::jsonb THEN
 sid:=(r->>'master_session_id')::uuid;
 IF p_location IS DISTINCT FROM '0b85f354-9cdb-47e1-baf9-3d266bb7e06b'::uuid
 OR sid IS NULL OR auth.uid() IS NULL OR NOT EXISTS(SELECT 1 FROM mission_generic_owner.start_claims sc
 JOIN mission_generic_owner.board_starts bs ON bs.request_key=sc.request_key
 WHERE sc.request_key=p_request AND sc.actor_user_id=auth.uid() AND sc.session_id=sid AND bs.master_session_id=sid
 AND bs.result=r) THEN RAISE EXCEPTION 'EVENT42_START_PROOF' USING ERRCODE='42501';END IF;
 ek:=mission_ai_service_owner.uuid5(sid,'server-event:start:'||p_request::text);source_sha:=public.combat_v2_sha256(r);
 rootrow.root_event_key:=ek;rootrow.root_request_key:=p_request;rootrow.root_principal:=auth.uid();rootrow.root_receipt_sha256:=source_sha;
 IF cfg->>'endpoint' IS DISTINCT FROM 'https://tyhyxkslteigibktluml.supabase.co/functions/v1/mission_generic_ai'
 THEN RAISE EXCEPTION 'EVENT42_ENDPOINT_REJECTED' USING ERRCODE='42501'; END IF;
 INSERT INTO mission_generic_owner.event_outbox_v1(event_key,event_version,master_session_id,event_domain,
 source_id,source_sha256,root_event_key,root_request_key,root_principal,root_receipt_sha256)
 VALUES(ek,ev,sid,domain,source_id,source_sha,rootrow.root_event_key,rootrow.root_request_key,
 rootrow.root_principal,rootrow.root_receipt_sha256)
 ON CONFLICT(event_key,event_version) DO NOTHING;
 GET DIAGNOSTICS affected=ROW_COUNT;
 IF affected=1 THEN
 IF cfg->'enabled'='true'::jsonb THEN
 request_id:=net.http_post(cfg->>'endpoint',jsonb_build_object('schema_version','mission-event-wake/2',
 'event_key',ek,'event_version',ev),'{}'::jsonb,
 jsonb_build_object('Content-Type','application/json','x-tus-server-event','event42'),5000);
 UPDATE mission_generic_owner.event_outbox_v1 SET wake_request_id=request_id
 WHERE event_key=ek AND event_version=ev;
 END IF;
 END IF;
 -- Public display hint is emitted only by deferred source/outbox hook.
 END IF;
 END;

 return r||jsonb_build_object('source_mission_id',src.id,'replay',false);
end;
$function$;

SELECT clan_innata_private.eligibility_release_assert();
DO $initial_scope$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM clan_marionettisti_private.mission_companion_release_v1
    WHERE singleton AND NOT land_enabled
  ) OR EXISTS (
    SELECT 1 FROM clan_marionettisti_private.mission_companion_entitlements_v1
    WHERE land_enabled
  ) THEN
    RAISE EXCEPTION 'Apertura Land non prevista per l’installazione Staff';
  END IF;
END;
$initial_scope$;
COMMIT;
