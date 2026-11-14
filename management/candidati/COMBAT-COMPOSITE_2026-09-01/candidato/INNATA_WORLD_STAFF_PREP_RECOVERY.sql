BEGIN;
DO $pins$
BEGIN
  IF md5(pg_get_functiondef('clan_innata_narrative_private.world_passive_role_v1(uuid,uuid,uuid)'::regprocedure)) IS DISTINCT FROM 'eb0a439f50d705590582be4e7942f2fb' THEN
    RAISE EXCEPTION 'STAFF_FILI_PASSIVE_BASELINE: clan_innata_narrative_private.world_passive_role_v1';
  END IF;
  IF md5(pg_get_functiondef('clan_innata_narrative_private.world_passive_bind_v1(uuid)'::regprocedure)) IS DISTINCT FROM 'bfdb2864810e5c3a916f8498df9f154e' THEN
    RAISE EXCEPTION 'STAFF_FILI_PASSIVE_BASELINE: clan_innata_narrative_private.world_passive_bind_v1';
  END IF;
  IF md5(pg_get_functiondef('clan_innata_narrative_private.world_passive_effective_v1(uuid,uuid)'::regprocedure)) IS DISTINCT FROM 'de5da9b2971a7ee77224e745ceb83fd3' THEN
    RAISE EXCEPTION 'STAFF_FILI_PASSIVE_BASELINE: clan_innata_narrative_private.world_passive_effective_v1';
  END IF;
END $pins$;

LOCK TABLE public.combat_v2_declarations IN ACCESS EXCLUSIVE MODE NOWAIT;
LOCK TABLE clan_innata_narrative_private.staff_passive_profiles_v1 IN SHARE MODE NOWAIT;
DO $recovery$
BEGIN
  IF EXISTS (
    SELECT 1 FROM clan_marionettisti_private.staff_sever_permits_v1 p
    JOIN public.combat_v2_rounds r ON r.id=p.round_id
    JOIN public.combat_v2_sessions s ON s.id=r.session_id AND s.closed_at IS NULL
  ) OR EXISTS (
    SELECT 1 FROM public.combat_v2_sessions s
    JOIN public.combat_v2_actors a ON a.session_id=s.id
    JOIN clan_innata_narrative_private.staff_passive_profiles_v1 p ON p.location_id=s.location_id
      AND p.character_id=a.character_id AND p.controller_user=a.controller_user
      AND p.master_session_id IS NOT DISTINCT FROM s.master_session_id
    WHERE s.closed_at IS NULL AND (
      p.disabled_at IS NULL AND p.expires_at>statement_timestamp() OR EXISTS (
        SELECT 1 FROM clan_innata_narrative_private.world_passive_combat_v1 b
        WHERE b.session_id=s.id AND b.actor_id=a.id
          AND b.fact->>'staff_temporary_passive_profile'='true'
      )
    )
  ) THEN RAISE EXCEPTION 'STAFF_FILI_PASSIVE_CLOSE_TEST_BEFORE_RECOVERY'; END IF;
END $recovery$;
REVOKE EXECUTE ON FUNCTION public.innata_staff_passive_profile_v1(uuid,uuid,uuid,text) FROM authenticated;
REVOKE EXECUTE ON FUNCTION public.marionetta_staff_sever_arm_v1(uuid,uuid,uuid) FROM authenticated;
UPDATE clan_innata_narrative_private.staff_passive_profiles_v1 SET disabled_at=statement_timestamp() WHERE disabled_at IS NULL;
ALTER TABLE public.combat_v2_declarations DISABLE TRIGGER zz_marionetta_staff_sever;
ALTER TABLE public.combat_v2_declarations DISABLE TRIGGER zz_marionetta_staff_sever_capture;
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
    select * from clan_innata_narrative_private.world_passive_acquisitions_v1(actor.id) a
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
    join clan_innata_narrative_private.world_passive_acquisitions_v1(actor.character_id) owned
      on owned.technique_id=r.technique_id and owned.acquisition_id=r.acquisition_id
      and owned.started_at is not distinct from r.acquisition_started_at
      and owned.activated_at is not distinct from r.acquisition_activated_at
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
  join lateral clan_innata_narrative_private.world_passive_acquisitions_v1(a.character_id) owned
    on owned.technique_id=b.technique_id and owned.acquisition_id=r.acquisition_id
    and owned.started_at is not distinct from r.acquisition_started_at
    and owned.activated_at is not distinct from r.acquisition_activated_at
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
