CREATE OR REPLACE FUNCTION mission_factory_owner.npc_custom_combat_runtime_assert_v1(p_master_session uuid, p_capability uuid, p_offer_ref uuid, p_bundle_version uuid)
 RETURNS void
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO ''
AS $function$
declare m public.master_v2_sessions%rowtype;
  o public.master_v2_nb_actor_offers_v1%rowtype;
  bn png_builder_internal.bundles%rowtype; mv public.nb_mechanical_versions%rowtype;
  q mission_factory_owner.quest_run_sources%rowtype;
  r public.mission_run_state%rowtype;
  rb mission_generic_owner.run_bindings%rowtype;
  scene jsonb; att jsonb; k text; n bigint;
begin
  IF p_capability IS NULL THEN RAISE EXCEPTION 'HUMAN_CUSTOM_RUNTIME_CLOSED' USING ERRCODE='42501';END IF;
  if p_master_session is null or p_capability is null
     or p_offer_ref is null or p_bundle_version is null then
    raise exception 'MF_NPC_CUSTOM_RUNTIME_INPUT' using errcode='22023'; end if;
  perform mission_generic_owner.assert_combat_scope(p_master_session,p_capability);
  select * into m from public.master_v2_sessions where id=p_master_session for share;
  if m.id is null or m.stato not in('preparazione','in_corso') or m.closed_at is not null
     or m.suspended_at is not null
     or not exists(select 1 from public.locations l where l.id=m.location_id
       and l.id='0b85f354-9cdb-47e1-baf9-3d266bb7e06b'::uuid
       and l.is_active and l.is_test) then
    raise exception 'MF_NPC_CUSTOM_RUNTIME_STAFF_ONLY' using errcode='42501'; end if;
  select * into o from public.master_v2_nb_actor_offers_v1
    where offer_ref=p_offer_ref for share;
  select * into bn from png_builder_internal.bundles where id=p_bundle_version for share;
  if o.offer_ref is null or bn.id is null or bn.bundle_kind<>'combat'
     or o.master_session_id is distinct from p_master_session
     or o.recipient_kind<>'ai_service' or o.recipient_service_capability is distinct from p_capability
     or o.lifecycle_state<>'offerta' or o.expires_at<=clock_timestamp()
     or o.narrative_template_id is distinct from bn.template_id
     or o.narrative_version_id is distinct from bn.narrative_version_id
     or o.mechanical_template_id is distinct from bn.mechanical_template_id
     or o.mechanical_version_id is distinct from bn.mechanical_version_id then
    raise exception 'MF_NPC_CUSTOM_RUNTIME_OFFER_STALE' using errcode='55000'; end if;
  att:=png_builder_internal.npc_custom_combat_attest_assert_v1(
    bn.template_id,bn.narrative_version_id,bn.id);
  if att->>'bundle_sha256' is distinct from bn.bundle_sha256 then
    raise exception 'MF_NPC_CUSTOM_RUNTIME_BUNDLE_STALE' using errcode='55000'; end if;
  select * into mv from public.nb_mechanical_versions
    where id=bn.mechanical_version_id and template_id=bn.mechanical_template_id for share;
  if mv.id is null or mv.profile_kind<>'npc_custom' or mv.review_state<>'approved'
     or mv.content_sha256 is distinct from o.expected_mechanical_sha256
     or mv.vita_max<=0 or mv.chakra_max<0 or mv.abilities is distinct from '[]'::jsonb
     or jsonb_typeof(mv.stats) is distinct from 'object' then
    raise exception 'MF_NPC_CUSTOM_RUNTIME_MECHANICS_STALE' using errcode='55000'; end if;
  foreach k in array array['taijutsu','ninjutsu','genjutsu','forza','velocita','mente','resistenza','fuuinjutsu'] loop
    if coalesce(mv.stats->>k,'') !~ '^[0-9]{1,10}$' then
      raise exception 'MF_NPC_CUSTOM_RUNTIME_STATS' using errcode='55000'; end if;
    n:=(mv.stats->>k)::bigint;
    if n>2147483647 then
      raise exception 'MF_NPC_CUSTOM_RUNTIME_STATS' using errcode='55000'; end if;
  end loop;
  select * into q from mission_factory_owner.quest_run_sources
    where session_id=p_master_session for share;
  if q.session_id is not null then
    select * into r from public.mission_run_state
      where master_session_id=p_master_session for share;
    if q.state<>'started' or r.source_kind<>'quest'
       or r.quest_episode_id is distinct from q.episode_id
       or r.run_phase<>'in_corso' or r.current_step_key is null
       or o.source_kind<>'quest' or o.quest_episode_id is distinct from q.episode_id
       or o.quest_source_sha256 is distinct from q.source_sha256 then
      raise exception 'MF_NPC_CUSTOM_RUNTIME_SOURCE_STALE' using errcode='55000'; end if;
    scene:=mission_factory_owner.quest_scene_v1(p_master_session,r.current_step_key);
    if not exists(select 1 from jsonb_array_elements(coalesce(scene->'encounters','[]'::jsonb)) en,
      lateral jsonb_array_elements(coalesce(en.value->'actors','[]'::jsonb)) a
      where a.value->>'combat'='true'
        and a.value->>'npc_id'=bn.template_id::text
        and a.value->>'npc_version_id'=bn.id::text
        and a.value->>'npc_bundle_sha256'=bn.bundle_sha256
        and a.value->>'mechanical_binding_id'=bn.mechanical_binding_id::text) then
      raise exception 'MF_NPC_CUSTOM_RUNTIME_SOURCE_STALE' using errcode='55000'; end if;
  else
    select * into rb from mission_generic_owner.run_bindings
      where master_session_id=p_master_session for share;
    select * into r from public.mission_run_state
      where master_session_id=p_master_session for share;
    if rb.master_session_id is null or r.master_session_id is null
       or r.source_kind<>'mission' or r.run_phase<>'in_corso'
       or r.current_step_key is null or o.source_kind<>'mission'
       or o.mission_id is distinct from m.mission_id
       or rb.snapshot_sha256 is distinct from mission_internal.fingerprint(rb.snapshot)
       or rb.snapshot->>'plan_version_id' is distinct from r.plan_version_id::text
       or not exists(select 1 from jsonb_array_elements(
           coalesce(rb.snapshot->'npc_bundle_pins','[]'::jsonb)) p
           where p.value->>'npc_id'=bn.template_id::text
             and p.value->>'npc_version_id'=bn.id::text
             and p.value->>'plan_version_id'=r.plan_version_id::text
             and p.value->'phase_keys' ? r.current_step_key
             and p.value->>'bundle_sha256'=bn.bundle_sha256
             and p.value->>'mechanical_binding_id'=bn.mechanical_binding_id::text) then
      -- Existing Mission run snapshots do not yet carry this new pin.
      raise exception 'MF_NPC_CUSTOM_RUNTIME_SOURCE_STALE' using errcode='55000'; end if;
  end if;
end $function$;
