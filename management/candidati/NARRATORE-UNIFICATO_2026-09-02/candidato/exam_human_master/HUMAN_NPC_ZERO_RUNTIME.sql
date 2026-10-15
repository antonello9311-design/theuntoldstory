-- SOURCE ONLY: new Human Native custom Staff capability. No installer/permit.
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

  -- New capability: normal Human Native Staff only. Existing AI branch below is byte-exact.
  IF p_capability IS NULL THEN
   DECLARE v_human_actor uuid:=auth.uid();v_human_allowed_auth_ids uuid[];
   BEGIN
    IF v_human_actor IS NULL OR auth.role() IS DISTINCT FROM 'authenticated'
    OR public.is_staff() IS DISTINCT FROM true OR public.master_v2_is_master(v_human_actor) IS DISTINCT FROM true
    OR p_master_session IS NULL OR p_offer_ref IS NULL OR p_bundle_version IS NULL
    THEN RAISE EXCEPTION 'HUMAN_CUSTOM_STAFF_AUTH_REQUIRED' USING ERRCODE='42501';END IF;
    SELECT * INTO STRICT m FROM public.master_v2_sessions WHERE id=p_master_session FOR SHARE;
    SELECT * INTO STRICT q FROM mission_factory_owner.quest_run_sources WHERE session_id=p_master_session FOR SHARE;
    SELECT * INTO STRICT r FROM public.mission_run_state WHERE master_session_id=p_master_session FOR SHARE;
    SELECT allowed_auth_ids INTO STRICT v_human_allowed_auth_ids FROM mission_factory_owner.c416_kind_admission WHERE singleton FOR SHARE;
    IF m.owner_kind IS DISTINCT FROM 'human' OR m.master_user IS DISTINCT FROM v_human_actor OR m.tipo IS DISTINCT FROM 'quest' OR m.mission_id IS NOT NULL
    OR m.stato IS NULL OR m.stato NOT IN('preparazione','in_corso') OR m.closed_at IS NOT NULL OR m.suspended_at IS NOT NULL
    OR m.location_id IS DISTINCT FROM '0b85f354-9cdb-47e1-baf9-3d266bb7e06b'::uuid
    OR NOT EXISTS(SELECT 1 FROM public.locations location WHERE location.id=m.location_id AND location.is_active AND location.is_test)
    OR q.state IS DISTINCT FROM 'started' OR q.availability_scope IS DISTINCT FROM 'staff' OR q.execution_context IS DISTINCT FROM 'staff_simulation'
    OR q.public_release_sha256 IS NOT NULL OR q.location_id IS DISTINCT FROM m.location_id
    OR q.staff_release_sha256 IS DISTINCT FROM mission_factory_owner.staff_release_sha_v1()
    OR r.source_kind IS DISTINCT FROM 'quest' OR r.quest_episode_id IS DISTINCT FROM q.episode_id OR r.run_phase IS DISTINCT FROM 'in_corso' OR r.current_step_key IS NULL
    OR mission_factory_owner.c395_human_mode_v1(p_master_session) IS DISTINCT FROM true
    OR mission_factory_owner.c416_kind_live_v1() IS DISTINCT FROM true OR mission_factory_owner.c444_enabled_v1() IS DISTINCT FROM true
    OR cardinality(v_human_allowed_auth_ids) IS DISTINCT FROM 2 OR array_position(v_human_allowed_auth_ids,NULL) IS NOT NULL
    OR NOT(v_human_actor=ANY(v_human_allowed_auth_ids)) OR cardinality(q.roster_character_ids) IS DISTINCT FROM 2
    OR EXISTS(SELECT 1 FROM unnest(q.roster_character_ids) member(id) LEFT JOIN public.characters character_row ON character_row.id=member.id
       WHERE character_row.id IS NULL OR character_row.user_id IS NULL OR NOT(character_row.user_id=ANY(v_human_allowed_auth_ids)))
    OR NOT EXISTS(SELECT 1 FROM mission_creation_owner.human_open_admissions admission WHERE admission.master_session_id=p_master_session
       AND admission.transaction_id=txid_current() AND admission.backend_pid=pg_backend_pid() AND admission.actor_user=v_human_actor)
    THEN RAISE EXCEPTION 'HUMAN_CUSTOM_NATIVE_STAFF_SCOPE_REQUIRED' USING ERRCODE='42501';END IF;
    PERFORM mission_factory_owner.c407_active_v1(p_master_session,'admission');
    PERFORM mission_factory_owner.quest_run_source_assert_v1(p_master_session);
    SELECT * INTO STRICT o FROM public.master_v2_nb_actor_offers_v1 WHERE offer_ref=p_offer_ref FOR SHARE;
    SELECT * INTO STRICT bn FROM png_builder_internal.bundles WHERE id=p_bundle_version FOR SHARE;
    IF bn.bundle_kind IS DISTINCT FROM 'combat' OR bn.status IS DISTINCT FROM 'certified' OR bn.ownership_mode IS DISTINCT FROM 'adopted' OR bn.disabled_at IS NOT NULL
    OR o.master_session_id IS DISTINCT FROM p_master_session OR o.mission_id IS NOT NULL OR o.source_kind IS DISTINCT FROM 'quest'
    OR o.quest_episode_id IS DISTINCT FROM q.episode_id OR o.quest_source_sha256 IS DISTINCT FROM q.source_sha256
    OR o.recipient_kind IS DISTINCT FROM 'human' OR o.recipient_user IS DISTINCT FROM v_human_actor
    OR o.recipient_service_capability IS NOT NULL OR o.created_by_service_capability IS NOT NULL OR o.created_by IS DISTINCT FROM v_human_actor
    OR o.lifecycle_state IS DISTINCT FROM 'offerta' OR o.expires_at IS NULL OR o.expires_at<=clock_timestamp()
    OR o.expected_master_control_version IS DISTINCT FROM m.control_version
    OR o.narrative_template_id IS DISTINCT FROM bn.template_id OR o.narrative_version_id IS DISTINCT FROM bn.narrative_version_id
    OR o.mechanical_template_id IS DISTINCT FROM bn.mechanical_template_id OR o.mechanical_version_id IS DISTINCT FROM bn.mechanical_version_id
    THEN RAISE EXCEPTION 'HUMAN_CUSTOM_OFFER_BUNDLE_STALE' USING ERRCODE='55000';END IF;
    att:=png_builder_internal.npc_custom_combat_attest_assert_v1(bn.template_id,bn.narrative_version_id,bn.id);
    IF att->>'bundle_sha256' IS DISTINCT FROM bn.bundle_sha256 THEN RAISE EXCEPTION 'HUMAN_CUSTOM_ATTEST_STALE' USING ERRCODE='55000';END IF;
    SELECT * INTO STRICT mv FROM public.nb_mechanical_versions WHERE id=bn.mechanical_version_id AND template_id=bn.mechanical_template_id FOR SHARE;
    IF mv.profile_kind IS DISTINCT FROM 'npc_custom' OR mv.review_state IS DISTINCT FROM 'approved' OR mv.content_sha256 IS DISTINCT FROM o.expected_mechanical_sha256
    OR mv.vita_max IS NULL OR mv.vita_max<=0 OR mv.chakra_max IS NULL OR mv.chakra_max<0 OR mv.abilities IS DISTINCT FROM '[]'::jsonb
    OR png_builder_internal.npc_combat_stats_safe(mv.stats) IS DISTINCT FROM true
    THEN RAISE EXCEPTION 'HUMAN_CUSTOM_MECHANICS_STALE' USING ERRCODE='55000';END IF;
    scene:=mission_factory_owner.quest_scene_v1(p_master_session,r.current_step_key);
    IF NOT EXISTS(SELECT 1 FROM jsonb_array_elements(coalesce(scene->'encounters','[]'::jsonb)) encounter_row,
       LATERAL jsonb_array_elements(coalesce(encounter_row.value->'actors','[]'::jsonb)) actor_row
       WHERE actor_row.value->>'combat'='true' AND actor_row.value->>'npc_id'=bn.template_id::text
       AND actor_row.value->>'npc_version_id'=bn.id::text AND actor_row.value->>'npc_bundle_sha256'=bn.bundle_sha256
       AND actor_row.value->>'mechanical_binding_id'=bn.mechanical_binding_id::text)
    THEN RAISE EXCEPTION 'HUMAN_CUSTOM_SOURCE_ACTOR_STALE' USING ERRCODE='55000';END IF;
    RETURN;
   END;
  END IF;
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
CREATE OR REPLACE FUNCTION public.master_v2_encounter_open_ninja_book_v1_human_ai_core(p_master_session uuid, p_pg_ids uuid[], p_actor_offers jsonb, p_team_map jsonb, p_request_key uuid)
 RETURNS jsonb
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO ''
AS $function$
declare
  v_uid uuid:=auth.uid(); v_m public.master_v2_sessions%rowtype; v_event jsonb; v_event_id uuid;
  v_enc uuid; v_round uuid; v_pg uuid; v_snap jsonb; v_team text; v_spec jsonb;
  v_offer public.master_v2_nb_actor_offers_v1%rowtype; v_nt public.nb_templates%rowtype;
  v_nv public.nb_template_versions%rowtype; v_b public.nb_mechanical_bindings%rowtype;
  v_mt public.nb_mechanical_templates%rowtype; v_mv public.nb_mechanical_versions%rowtype;
  v_instance uuid; v_mode text; v_result jsonb; v_count integer; v_client uuid; v_offer_ref uuid; v_quest_source mission_factory_owner.quest_run_sources; v_is_human_quest boolean; v_custom_bundle uuid;
begin
  perform mission_creation_owner.assert_human_open(p_master_session,p_request_key,p_pg_ids,p_actor_offers,p_team_map);
  if v_uid is null then perform public.master_v2_nb_fail_v1('autenticazione_richiesta','Autenticazione richiesta.',401,p_request_key); end if;
  select * into v_m from public.master_v2_sessions where id=p_master_session;
  if v_m.id is null then perform public.master_v2_nb_fail_v1('sessione_inesistente','Sessione Master inesistente.',404,p_request_key); end if;
  if v_m.master_user<>v_uid and NOT mission_generic_owner.regia_entry_permit_valid_v1(p_master_session,p_request_key) then perform public.master_v2_nb_fail_v1('master_non_proprietario','Solo il Master corrente può aprire lo scontro.',403,p_request_key); end if;
  v_is_human_quest:=mission_factory_owner.c395_human_mode_v1(p_master_session);
  IF v_is_human_quest THEN SELECT * INTO STRICT v_quest_source FROM mission_factory_owner.quest_run_sources WHERE session_id=p_master_session FOR SHARE;PERFORM mission_factory_owner.c407_active_v1(p_master_session,'admission');END IF;
  if v_m.tipo<>'quest' or (NOT v_is_human_quest AND v_m.mission_id is null) OR (v_is_human_quest AND (v_m.mission_id IS NOT NULL OR v_quest_source.state IS DISTINCT FROM 'started')) or v_m.stato not in ('preparazione','in_corso') then
    perform public.master_v2_nb_fail_v1('sessione_non_operativa','Sessione missione non operativa.',409,p_request_key);
  end if;
  if p_pg_ids is null or cardinality(p_pg_ids)<1 or cardinality(p_pg_ids)>12
     or p_actor_offers is null or jsonb_typeof(p_actor_offers)<>'array'
     or jsonb_array_length(p_actor_offers)<1 or jsonb_array_length(p_actor_offers)>12
     or p_team_map is null or jsonb_typeof(p_team_map)<>'object' then
    perform public.master_v2_nb_fail_v1('intento_non_valido','Elenco attori non valido.',422,p_request_key);
  end if;
  select count(distinct x) into v_count from unnest(p_pg_ids) x;
  if v_count<>cardinality(p_pg_ids) then perform public.master_v2_nb_fail_v1('intento_non_valido','PG duplicato.',422,p_request_key); end if;
  if exists(select 1 from public.characters c where c.id=any(p_pg_ids) and c.user_id=v_uid) and not (public.is_staff() and exists(select 1 from public.locations l where l.id=v_m.location_id and l.is_test)) then
    perform public.master_v2_nb_fail_v1('attore_non_controllato','Il Master corrente non può essere un attore PG.',422,p_request_key);
  end if;
  if (select count(*) from public.characters c where c.id=any(p_pg_ids))<>cardinality(p_pg_ids) then
    perform public.master_v2_nb_fail_v1('intento_non_valido','Uno o più PG non esistono.',422,p_request_key);
  end if;
  if exists(select 1 from jsonb_array_elements(p_actor_offers) x
    where jsonb_typeof(x)<>'object' or public.combat_v2_has_forbidden_key(x)
       or exists(select 1 from jsonb_object_keys(x) k where k not in ('client_ref','provider','offer_ref'))
       or (select count(*) from jsonb_object_keys(x))<>3) then
    perform public.master_v2_nb_fail_v1('campo_meccanico_vietato','Payload provider non valido.',422,p_request_key);
  end if;
  if exists(select 1 from jsonb_array_elements(p_actor_offers) x where x->>'provider'<>'ninja_book') then
    perform public.master_v2_nb_fail_v1('riferimento_provider_non_valido','Provider non valido.',422,p_request_key);
  end if;
  begin
    if (select count(distinct (x->>'client_ref')::uuid) from jsonb_array_elements(p_actor_offers) x)<>jsonb_array_length(p_actor_offers)
       or (select count(distinct (x->>'offer_ref')::uuid) from jsonb_array_elements(p_actor_offers) x)<>jsonb_array_length(p_actor_offers) then
      perform public.master_v2_nb_fail_v1('intento_non_valido','Identità provider duplicata.',422,p_request_key);
    end if;
  exception when invalid_text_representation then
    perform public.master_v2_nb_fail_v1('intento_non_valido','Riferimento provider non valido.',422,p_request_key);
  end;
  if (select count(*) from jsonb_object_keys(p_team_map))<>
       cardinality(p_pg_ids)+jsonb_array_length(p_actor_offers)
     or exists(select 1 from jsonb_object_keys(p_team_map) k
       where not (k=any(array(select x::text from unnest(p_pg_ids) x))
                  or k=any(array(select x->>'client_ref' from jsonb_array_elements(p_actor_offers) x)))) then
    perform public.master_v2_nb_fail_v1('intento_non_valido','Mappa squadre non esatta.',422,p_request_key);
  end if;

  perform 1 from public.locations l where l.id=v_m.location_id order by l.id for update;
  perform combat_gate_private.master_claim_assert(p_master_session,v_m.location_id);
  perform 1 from public.characters c where c.id=any(p_pg_ids) order by c.id for key share;
  perform public.master_v2_lock_scope(p_master_session);
  select * into v_m from public.master_v2_sessions where id=p_master_session for update;
  if v_m.master_user<>v_uid and NOT mission_generic_owner.regia_entry_permit_valid_v1(p_master_session,p_request_key) then perform public.master_v2_nb_fail_v1('master_non_proprietario','Controllo Master cambiato durante l’apertura.',409,p_request_key); end if;
  if v_m.tipo<>'quest' or v_m.stato not in ('preparazione','in_corso') then
    perform public.master_v2_nb_fail_v1('sessione_non_operativa','Sessione non più operativa.',409,p_request_key);
  end if;
  v_event:=public.combat_v2_event_begin(p_master_session,p_request_key,
    'master_v2_encounter_open_ninja_book_v1',jsonb_build_object('pg',p_pg_ids,'actors',p_actor_offers,'teams',p_team_map),v_m.control_version);
  if (v_event->>'replay')::boolean then
    v_event_id:=(v_event->>'event_id')::uuid;
    insert into public.master_v2_nb_offer_audit_v1(offer_ref,event_id,action,actor_user)
    select (x->>'offer_ref')::uuid,v_event_id,'replay',v_uid from jsonb_array_elements(p_actor_offers) x
    on conflict do nothing;
    return v_event->'result';
  end if;
  v_event_id:=(v_event->>'event_id')::uuid;
  if exists(select 1 from public.combat_sessions where location_id=v_m.location_id and state='aperto')
     or exists(select 1 from public.combat_v2_sessions where location_id=v_m.location_id AND user_test_context_id IS NULL and state not in ('chiuso','annullato')) then
    perform public.master_v2_nb_fail_v1('scontro_gia_aperto_nel_luogo','Esiste già uno scontro nel luogo.',409,p_request_key);
  end if;

  -- Ordine lock: sessione Master -> offer UUID -> narrative/binding/mechanical UUID.
  perform 1 from public.master_v2_nb_actor_offers_v1 o
   where o.offer_ref in (select (x->>'offer_ref')::uuid from jsonb_array_elements(p_actor_offers) x)
   order by o.offer_ref for update;
  if (select count(*) from public.master_v2_nb_actor_offers_v1 o
      where o.offer_ref in (select (x->>'offer_ref')::uuid from jsonb_array_elements(p_actor_offers) x))<>jsonb_array_length(p_actor_offers) then
    perform public.master_v2_nb_fail_v1('opzione_non_offerta','Opzione non offerta.',422,p_request_key);
  end if;
  perform 1 from public.nb_template_versions v where v.id in(
    select o.narrative_version_id from public.master_v2_nb_actor_offers_v1 o
    where o.offer_ref in(select (x->>'offer_ref')::uuid from jsonb_array_elements(p_actor_offers)x)) order by v.id for update;
  perform 1 from public.nb_templates t where t.id in(
    select o.narrative_template_id from public.master_v2_nb_actor_offers_v1 o
    where o.offer_ref in(select (x->>'offer_ref')::uuid from jsonb_array_elements(p_actor_offers)x)) order by t.id for update;
  perform 1 from public.nb_mechanical_bindings b where b.narrative_version_id in(
    select o.narrative_version_id from public.master_v2_nb_actor_offers_v1 o
    where o.offer_ref in(select (x->>'offer_ref')::uuid from jsonb_array_elements(p_actor_offers)x)) order by b.id for update;
  perform 1 from public.nb_mechanical_versions v where v.id in(
    select o.mechanical_version_id from public.master_v2_nb_actor_offers_v1 o
    where o.offer_ref in(select (x->>'offer_ref')::uuid from jsonb_array_elements(p_actor_offers)x)) order by v.id for update;
  perform 1 from public.nb_mechanical_templates t where t.id in(
    select o.mechanical_template_id from public.master_v2_nb_actor_offers_v1 o
    where o.offer_ref in(select (x->>'offer_ref')::uuid from jsonb_array_elements(p_actor_offers)x)) order by t.id for update;

  -- Risolve e congela tutto prima del primo INSERT di sessione/istanza.
  for v_spec in select value from jsonb_array_elements(p_actor_offers) order by value->>'offer_ref' loop
    v_client:=(v_spec->>'client_ref')::uuid; v_offer_ref:=(v_spec->>'offer_ref')::uuid;
    select * into v_offer from public.master_v2_nb_actor_offers_v1 where offer_ref=v_offer_ref;
    if v_offer.master_session_id<>p_master_session OR (v_is_human_quest AND (v_offer.source_kind IS DISTINCT FROM 'quest' OR v_offer.mission_id IS NOT NULL OR v_offer.quest_episode_id IS DISTINCT FROM v_quest_source.episode_id OR v_offer.quest_source_sha256 IS DISTINCT FROM v_quest_source.source_sha256)) OR (NOT v_is_human_quest AND (v_offer.source_kind IS DISTINCT FROM 'mission' OR v_offer.mission_id IS DISTINCT FROM v_m.mission_id))
       or v_offer.recipient_user<>v_m.master_user or v_offer.lifecycle_state<>'offerta'
       or v_offer.expires_at<=clock_timestamp() then
      perform public.master_v2_nb_fail_v1('opzione_non_offerta','Opzione non offerta.',422,p_request_key);
    end if;
    select * into v_nv from public.nb_template_versions where id=v_offer.narrative_version_id and template_id=v_offer.narrative_template_id;
    select * into v_nt from public.nb_templates where id=v_offer.narrative_template_id;
    select * into v_b from public.nb_mechanical_bindings where narrative_version_id=v_offer.narrative_version_id;
    select * into v_mv from public.nb_mechanical_versions where id=v_offer.mechanical_version_id and template_id=v_offer.mechanical_template_id;
    select * into v_mt from public.nb_mechanical_templates where id=v_offer.mechanical_template_id;

    -- Canonical custom bundle must pass the Human Native Staff gate before any insert.
    IF v_mv.profile_kind='npc_custom' AND v_is_human_quest AND v_m.owner_kind='human'
      AND v_m.location_id='0b85f354-9cdb-47e1-baf9-3d266bb7e06b'::uuid
      AND v_quest_source.availability_scope='staff' AND v_quest_source.execution_context='staff_simulation' THEN
      IF (SELECT count(*) FROM png_builder_internal.bundles custom_bundle JOIN png_builder_internal.npc_custom_combat_attests custom_attest ON custom_attest.bundle_id=custom_bundle.id
          WHERE custom_bundle.template_id=v_offer.narrative_template_id AND custom_bundle.narrative_version_id=v_offer.narrative_version_id
          AND custom_bundle.mechanical_version_id=v_offer.mechanical_version_id AND custom_bundle.mechanical_binding_id=v_b.id
          AND custom_bundle.status='certified' AND custom_bundle.ownership_mode='adopted' AND custom_bundle.disabled_at IS NULL)<>1
      THEN PERFORM public.master_v2_nb_fail_v1('opzione_non_offerta','Bundle PNG non disponibile.',422,p_request_key);END IF;
      SELECT custom_bundle.id INTO STRICT v_custom_bundle FROM png_builder_internal.bundles custom_bundle JOIN png_builder_internal.npc_custom_combat_attests custom_attest ON custom_attest.bundle_id=custom_bundle.id
       WHERE custom_bundle.template_id=v_offer.narrative_template_id AND custom_bundle.narrative_version_id=v_offer.narrative_version_id
       AND custom_bundle.mechanical_version_id=v_offer.mechanical_version_id AND custom_bundle.mechanical_binding_id=v_b.id
       AND custom_bundle.status='certified' AND custom_bundle.ownership_mode='adopted' AND custom_bundle.disabled_at IS NULL;
      PERFORM mission_factory_owner.npc_custom_combat_runtime_assert_v1(p_master_session,NULL,v_offer_ref,v_custom_bundle);
    END IF;
    if v_nt.id is null or v_nv.id is null or v_b.id is null or v_mt.id is null or v_mv.id is null
       or v_nt.lifecycle_state<>'approved' or v_nt.current_version_id<>v_nv.id or v_nv.review_state<>'approved'
       or v_b.lifecycle_state<>'approved' or not v_b.active
       or v_b.mechanical_template_id<>v_mt.id or v_b.mechanical_version_id<>v_mv.id
       or v_mt.lifecycle_state<>'approved' or not v_mt.active or v_mt.current_version_id<>v_mv.id
       or v_mv.review_state<>'approved' then
      perform public.master_v2_nb_fail_v1('opzione_non_offerta','Opzione non offerta.',422,p_request_key);
    end if;
    if v_offer.expected_master_control_version<>v_m.control_version
       or v_offer.expected_narrative_template_control_version<>v_nt.control_version
       or v_offer.expected_narrative_version_control_version<>v_nv.control_version
       or v_offer.expected_binding_control_version<>v_b.control_version
       or v_offer.expected_mechanical_template_control_version<>v_mt.control_version
       or v_offer.expected_mechanical_version_control_version<>v_mv.control_version
       or v_offer.expected_narrative_sha256<>v_nv.content_sha256
       or v_offer.expected_mechanical_sha256<>v_mv.content_sha256 then
      perform public.master_v2_nb_fail_v1('versione_provider_obsoleta','L’offerta provider è obsoleta.',409,p_request_key);
    end if;
    v_team:=nullif(btrim(p_team_map->>v_client::text),'');
    if v_team is null then perform public.master_v2_nb_fail_v1('intento_non_valido','Squadra provider mancante.',422,p_request_key); end if;
  end loop;

  insert into public.combat_v2_sessions(source_kind,master_session_id,location_id,state,lesiva)
  values('master',p_master_session,v_m.location_id,'in_corso',not exists(select 1 from public.locations l where l.id=v_m.location_id and l.is_test)) returning id into v_enc;
  foreach v_pg in array p_pg_ids loop
    v_snap:=mission_creation_owner.carry_snapshot(p_master_session,v_pg,null,public.combat_v2_character_snapshot(v_pg)); v_team:=nullif(btrim(p_team_map->>v_pg::text),'');
    if v_snap is null or v_team is null then perform public.master_v2_nb_fail_v1('intento_non_valido','Snapshot o squadra PG non disponibile.',422,p_request_key); end if;
    insert into public.combat_v2_actors(session_id,actor_kind,character_id,controller_user,team_key,position_m,initiative_snapshot,mechanics_snapshot)
    select v_enc,'pg',c.id,c.user_id,v_team,0,c.velocita,v_snap from public.characters c where c.id=v_pg;
    insert into public.master_v2_participants(session_id,character_id,user_id_snapshot)
    select p_master_session,c.id,c.user_id from public.characters c where c.id=v_pg on conflict(session_id,character_id) do nothing;
  end loop;
  for v_spec in select value from jsonb_array_elements(p_actor_offers) order by value->>'offer_ref' loop
    v_client:=(v_spec->>'client_ref')::uuid; v_offer_ref:=(v_spec->>'offer_ref')::uuid;
    select * into v_offer from public.master_v2_nb_actor_offers_v1 where offer_ref=v_offer_ref;
    select * into v_nt from public.nb_templates where id=v_offer.narrative_template_id;
    select * into v_mv from public.nb_mechanical_versions where id=v_offer.mechanical_version_id;
    v_team:=nullif(btrim(p_team_map->>v_client::text),'');
    v_snap:=jsonb_build_object('name',v_nt.display_name,'vita',v_mv.vita_max,'vita_max',v_mv.vita_max,
      'chakra',v_mv.chakra_max,'chakra_max',v_mv.chakra_max,
      'taijutsu',(v_mv.stats->>'taijutsu')::integer,'ninjutsu',(v_mv.stats->>'ninjutsu')::integer,
      'genjutsu',(v_mv.stats->>'genjutsu')::integer,'forza',(v_mv.stats->>'forza')::integer,
      'velocita',(v_mv.stats->>'velocita')::integer,'mente',(v_mv.stats->>'mente')::integer,
      'resistenza',(v_mv.stats->>'resistenza')::integer,'fuuinjutsu',(v_mv.stats->>'fuuinjutsu')::integer,
      'slancio',0,'abilities',v_mv.abilities);
    v_snap:=mission_creation_owner.carry_snapshot(p_master_session,null,v_client,v_snap);
    insert into public.combat_v2_provider_instances_v1(session_id,client_ref,provider,offer_ref,
      narrative_template_ref,narrative_version_ref,mechanical_template_ref,mechanical_version_ref,
      source_sha256,snapshot_sha256,nome,snapshot)
    values(v_enc,v_client,'ninja_book',v_offer_ref,v_offer.narrative_template_id,v_offer.narrative_version_id,
      v_offer.mechanical_template_id,v_offer.mechanical_version_id,v_mv.content_sha256,public.combat_v2_sha256(v_snap),v_nt.display_name,v_snap)
    returning id into v_instance;
    insert into public.combat_v2_actors(session_id,actor_kind,provider_instance_v1_id,controller_user,team_key,position_m,initiative_snapshot,mechanics_snapshot)
    values(v_enc,'png',v_instance,v_m.master_user,v_team,0,(v_mv.stats->>'velocita')::integer,v_snap);
    update public.master_v2_nb_actor_offers_v1 set lifecycle_state='consumata',consumed_event_id=v_event_id,
      consumed_at=clock_timestamp(),control_version=control_version+1,updated_at=clock_timestamp() where offer_ref=v_offer_ref;
    insert into public.master_v2_nb_offer_audit_v1(offer_ref,event_id,action,actor_user,details)
    values(v_offer_ref,v_event_id,'consumo',v_uid,jsonb_build_object('provider_instance_id',v_instance));
  end loop;
  select case when v_m.master_user is null then 'neutra' else 'umana' end into v_mode;
  insert into public.combat_v2_rounds(session_id,round_no,evaluation_mode) values(v_enc,1,v_mode) returning id into v_round;
  update public.master_v2_sessions set stato='in_corso' where id=p_master_session;
  if v_m.tipo='quest' and mission_internal.runtime_enabled()
     and exists(select 1 from public.mission_run_state where master_session_id=p_master_session and run_phase='preparazione') then
    perform mission_internal.sync_lifecycle(p_master_session,p_request_key,v_m.control_version,
      (select control_version from public.mission_run_state where master_session_id=p_master_session),'in_corso');
  end if;
  v_result:=public.combat_v2_envelope(p_request_key,jsonb_build_object('encounter_id',v_enc,'round_id',v_round,'evaluation_mode',v_mode));
  return public.combat_v2_event_complete(v_event_id,v_result);
end
$function$;
