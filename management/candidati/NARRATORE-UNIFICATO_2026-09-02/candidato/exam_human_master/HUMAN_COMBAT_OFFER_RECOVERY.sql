BEGIN;DO $guard$ BEGIN IF current_user<>'postgres' OR current_setting('tus.human_combat_offer_recovery',true) IS DISTINCT FROM 'reviewed:0/0/0' THEN RAISE EXCEPTION 'HUMAN22_AUTHORITY';END IF;IF md5(pg_get_functiondef('mission_creation_owner.human_open(uuid,uuid)'::regprocedure)) IS DISTINCT FROM 'ca6f975bfe10133c07c3ba35c07e58c9' OR (SELECT proacl::text FROM pg_proc WHERE oid='mission_creation_owner.human_open(uuid,uuid)'::regprocedure) IS DISTINCT FROM '{postgres=X/postgres}' OR (SELECT proowner::regrole::text FROM pg_proc WHERE oid='mission_creation_owner.human_open(uuid,uuid)'::regprocedure) IS DISTINCT FROM 'postgres' THEN RAISE EXCEPTION 'HUMAN22_BASELINE_DRIFT';END IF;IF md5(pg_get_functiondef('public.master_v2_encounter_open_ninja_book_v1_human_ai_core(uuid,uuid[],jsonb,jsonb,uuid)'::regprocedure)) IS DISTINCT FROM '8f6d78667022ac248ca0c992bb237b69' OR (SELECT proacl::text FROM pg_proc WHERE oid='public.master_v2_encounter_open_ninja_book_v1_human_ai_core(uuid,uuid[],jsonb,jsonb,uuid)'::regprocedure) IS DISTINCT FROM '{postgres=X/postgres}' OR (SELECT proowner::regrole::text FROM pg_proc WHERE oid='public.master_v2_encounter_open_ninja_book_v1_human_ai_core(uuid,uuid[],jsonb,jsonb,uuid)'::regprocedure) IS DISTINCT FROM 'postgres' THEN RAISE EXCEPTION 'HUMAN22_BASELINE_DRIFT';END IF;IF md5(pg_get_functiondef('mission_factory_owner.c408_stage1_complete_assert_v1()'::regprocedure)) IS DISTINCT FROM 'd82dfb39b3a1330d5179818026c86e83' OR (SELECT proacl::text FROM pg_proc WHERE oid='mission_factory_owner.c408_stage1_complete_assert_v1()'::regprocedure) IS DISTINCT FROM '{postgres=X/postgres}' OR (SELECT proowner::regrole::text FROM pg_proc WHERE oid='mission_factory_owner.c408_stage1_complete_assert_v1()'::regprocedure) IS DISTINCT FROM 'postgres' THEN RAISE EXCEPTION 'HUMAN22_BASELINE_DRIFT';END IF;IF md5(pg_get_functiondef('mission_factory_owner.c444_runtime_ports_complete_assert_v1()'::regprocedure)) IS DISTINCT FROM '3ebc1662e60b104e66c2c6e9a690bf0f' OR (SELECT proacl::text FROM pg_proc WHERE oid='mission_factory_owner.c444_runtime_ports_complete_assert_v1()'::regprocedure) IS DISTINCT FROM '{postgres=X/postgres}' OR (SELECT proowner::regrole::text FROM pg_proc WHERE oid='mission_factory_owner.c444_runtime_ports_complete_assert_v1()'::regprocedure) IS DISTINCT FROM 'postgres' THEN RAISE EXCEPTION 'HUMAN22_BASELINE_DRIFT';END IF;IF NOT EXISTS(SELECT 1 FROM public.master_v2_sessions WHERE id='97d2a684-956d-57ad-8d84-aca627dd9e5c' AND suspended_at IS NOT NULL AND closed_at IS NULL) OR EXISTS(SELECT 1 FROM public.combat_v2_sessions WHERE master_session_id='97d2a684-956d-57ad-8d84-aca627dd9e5c' AND state NOT IN('chiuso','annullato')) THEN RAISE EXCEPTION 'HUMAN22_SUSPENDED_OWN_SCOPE_REQUIRED';END IF;END $guard$;
CREATE OR REPLACE FUNCTION mission_creation_owner.human_open(p_session uuid, p_request uuid)
 RETURNS jsonb
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO ''
AS $function$
declare m public.master_v2_sessions;r public.mission_run_state;sc jsonb;spec jsonb;pgs uuid[];teams jsonb;offers jsonb:='[]';a jsonb;
 mb public.nb_mechanical_bindings;nt public.nb_templates;nv public.nb_template_versions;mt public.nb_mechanical_templates;mv public.nb_mechanical_versions;
 offer uuid;client uuid;result jsonb;enc uuid;maps jsonb; opening_batch uuid;
 opening_round uuid; opening_side text; opening_ids uuid[]; opening_keys text[];
 opening_window uuid; quest_source mission_factory_owner.quest_run_sources; is_human_quest boolean;
begin
 IF mission_factory_owner.c395_human_mode_v1(p_session) THEN RAISE EXCEPTION 'HUMAN22_RECOVERY_QUEST_COMBAT_CLOSED' USING ERRCODE='42501';END IF;
IF mission_factory_owner.c395_human_mode_v1(p_session) THEN PERFORM mission_factory_owner.c407_active_v1(p_session,'admission');END IF;
 if NOT mission_generic_owner.regia_entry_permit_valid_v1(p_session,p_request) then
  perform mission_creation_owner.human_assert(p_session);
 end if;
 select * into strict m from public.master_v2_sessions where id=p_session for update;
 select * into strict r from public.mission_run_state where master_session_id=p_session for update;
 is_human_quest:=mission_factory_owner.c395_human_mode_v1(p_session);
 IF is_human_quest THEN SELECT * INTO STRICT quest_source FROM mission_factory_owner.quest_run_sources WHERE session_id=p_session FOR SHARE;IF r.source_kind IS DISTINCT FROM 'quest' OR r.quest_episode_id IS DISTINCT FROM quest_source.episode_id OR m.mission_id IS NOT NULL THEN RAISE EXCEPTION 'HUMAN22_QUEST_SOURCE_DRIFT';END IF;END IF;
 sc:=mission_generic_owner.scene(p_session,r.current_step_key);
 if jsonb_array_length(sc->'encounters')<>1 then raise exception 'MC_PHASE_HAS_NO_ENCOUNTER' using errcode='22023';end if;
 spec:=sc#>'{encounters,0}';
 if exists(select 1 from mission_creation_owner.human_encounters previous
   join mission_creation_owner.human_peaceful_closures closure
     on closure.encounter_id=previous.encounter_id and closure.master_session_id=p_session
   where previous.master_session_id=p_session
     and previous.encounter_key=spec->>'encounter_key')
 then raise exception 'HPC_PEACEFUL_REOPEN_FORBIDDEN' using errcode='40001';end if;
 if exists(select 1 from mission_creation_owner.human_encounters where master_session_id=p_session and run_control_version=r.control_version)
 then raise exception 'MC_ENCOUNTER_ALREADY_OPENED' using errcode='40001';end if;
 if exists(select 1 from public.combat_v2_sessions where master_session_id=p_session and (state<>'chiuso' or closed_at is null))
 then raise exception 'MC_PREVIOUS_ENCOUNTER_NOT_CLOSED' using errcode='55000';end if;
 select array_agg(p.character_id order by p.character_id) into pgs from public.master_v2_participants p
 join public.characters c on c.id=p.character_id and c.user_id=p.user_id_snapshot
 where p.session_id=p_session and p.left_at is null and p.engagement_state='attivo';
 IF mission_factory_owner.c395_human_mode_v1(p_session) THEN
 IF pgs IS DISTINCT FROM (SELECT ARRAY(SELECT x FROM unnest(q.roster_character_ids)x ORDER BY x) FROM mission_factory_owner.quest_run_sources q WHERE q.session_id=p_session) OR cardinality(pgs) NOT BETWEEN 1 AND 4 OR jsonb_array_length(spec->'actors') NOT BETWEEN 1 AND 4 THEN RAISE EXCEPTION 'C407_CONFIRMED_NATIVE_ROSTER_REQUIRED' USING ERRCODE='55000';END IF;
ELSE
if coalesce(cardinality(pgs),0) not between
 (select team_min from public.missions where id=m.mission_id) and (select team_max from public.missions where id=m.mission_id)
 then raise exception 'MC_CONFIRMED_ROSTER_REQUIRED' using errcode='55000';end if;
END IF;
 select jsonb_object_agg(x::text,spec->>'pg_team') into teams from unnest(pgs)x;
 for a in select value from jsonb_array_elements(spec->'actors') order by value->>'actor_key' loop
  select * into strict mb from public.nb_mechanical_bindings where id=(a->>'mechanical_binding_id')::uuid for share;
  if not mission_generic_owner.binding_is_pinned(p_session,mb.id) then raise exception 'MC_PROFILE_PIN_DRIFT' using errcode='40001';end if;
  select * into strict nt from public.nb_templates where id=mb.narrative_template_id for share;
  select * into strict nv from public.nb_template_versions where id=mb.narrative_version_id for share;
  select * into strict mt from public.nb_mechanical_templates where id=mb.mechanical_template_id for share;
  select * into strict mv from public.nb_mechanical_versions where id=mb.mechanical_version_id for share;
  offer:=mission_ai_service_owner.uuid5(p_request,'human-offer:'||(a->>'actor_key'));
  client:=mission_ai_service_owner.uuid5(p_session,'actor:'||(a->>'actor_key'));
  insert into public.master_v2_nb_actor_offers_v1(offer_ref,master_session_id,mission_id,source_kind,quest_episode_id,quest_source_sha256,recipient_user,recipient_kind,
   narrative_template_id,narrative_version_id,mechanical_template_id,mechanical_version_id,
   expected_master_control_version,expected_narrative_template_control_version,expected_narrative_version_control_version,
   expected_binding_control_version,expected_mechanical_template_control_version,expected_mechanical_version_control_version,
   expected_narrative_sha256,expected_mechanical_sha256,expires_at,created_by)
  values(offer,p_session,m.mission_id,CASE WHEN is_human_quest THEN 'quest' ELSE 'mission' END,CASE WHEN is_human_quest THEN quest_source.episode_id ELSE NULL END,CASE WHEN is_human_quest THEN quest_source.source_sha256 ELSE NULL END,m.master_user,'human',nt.id,nv.id,mt.id,mv.id,m.control_version,
   nt.control_version,nv.control_version,mb.control_version,mt.control_version,mv.control_version,
   nv.content_sha256,mv.content_sha256,clock_timestamp()+interval '15 minutes',auth.uid());
  offers:=offers||jsonb_build_array(jsonb_build_object('client_ref',client,'provider','ninja_book','offer_ref',offer));
  teams:=teams||jsonb_build_object(client::text,a->>'team');
 end loop;
 if exists(select 1 from mission_generic_owner.regia_human_session_optins_v1 opt
    where opt.master_session_id=p_session and opt.actor_user=m.master_user) then
   -- Staging creates no side or public turn; advance_v2 seals that authority.
   if (not (m.location_id='0b85f354-9cdb-47e1-baf9-3d266bb7e06b'::uuid and exists(select 1 from public.locations l where l.id=m.location_id and l.is_active and l.is_test))
      and not mission_public_owner.human_session_allowed_v1(m.id))
      or not exists(select 1 from mission_generic_owner.run_bindings b where b.master_session_id=p_session)
   then raise exception 'REGIA_OPTIN_SCOPE' using errcode='42501'; end if;
 end if;
  insert into mission_creation_owner.human_open_admissions values(p_session,mission_ai_service_owner.uuid5(p_request,'native-open'),txid_current(),pg_backend_pid(),auth.uid(),mission_internal.fingerprint(jsonb_build_object('pgs',to_jsonb(pgs),'offers',offers,'teams',teams)));
 result:=public.master_v2_encounter_open_ninja_book_v1(p_session,pgs,offers,teams,mission_ai_service_owner.uuid5(p_request,'native-open'));
 enc:=(result#>>'{data,encounter_id}')::uuid;
 if enc is null then raise exception 'MC_NATIVE_ENCOUNTER_RECEIPT';end if;
 select jsonb_agg(x.v order by x.v->>'actor_key') into maps from (
  select jsonb_build_object('actor_key','pg:'||ca.character_id::text,'actor_id',ca.id,'character_id',ca.character_id) v from public.combat_v2_actors ca where ca.session_id=enc and ca.actor_kind='pg'
  union all select jsonb_build_object('actor_key',j->>'actor_key','actor_id',ca.id,'mechanical_binding_id',j->>'mechanical_binding_id')
   from public.combat_v2_actors ca join public.combat_v2_provider_instances_v1 pi on pi.id=ca.provider_instance_v1_id
   cross join jsonb_array_elements(spec->'actors') j where ca.session_id=enc and pi.client_ref=mission_ai_service_owner.uuid5(p_session,'actor:'||(j->>'actor_key'))
 )x;
 if jsonb_array_length(maps)<>cardinality(pgs)+jsonb_array_length(offers) then raise exception 'MC_ACTOR_MAP_INCOMPLETE';end if;
 insert into mission_creation_owner.human_encounters(encounter_id,master_session_id,step_key,run_control_version,encounter_key,actor_map)
 values(enc,p_session,r.current_step_key,r.control_version,spec->>'encounter_key',maps);
 update public.combat_v2_actors set state='fuori' where session_id=enc and (mechanics_snapshot->>'vita')::int<=0;
 if (select count(distinct team_key) from public.combat_v2_actors where session_id=enc and state='attivo')<2 then raise exception 'MC_NO_OPPOSING_ACTIVE_TEAMS';end if;
 perform mission_creation_owner.bind_human_arena(p_session,enc,p_request);
 perform combat_panel_private.assert_master_ready(enc);
 if (select is_test from public.locations where id=m.location_id) and not combat_panel_private.uses_simulated_pools(enc)
 then raise exception 'MC_SIMULATION_NOT_BOUND' using errcode='42501';end if;
 return jsonb_build_object('encounter_id',enc,'combat',result,'step_key',r.current_step_key,'run_control_version',r.control_version,'regia_opening_window_id',opening_window,'regia_opening_side',opening_side);
end $function$
;
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
  v_instance uuid; v_mode text; v_result jsonb; v_count integer; v_client uuid; v_offer_ref uuid; v_quest_source mission_factory_owner.quest_run_sources; v_is_human_quest boolean;
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
$function$
;
CREATE OR REPLACE FUNCTION mission_factory_owner.c408_stage1_complete_assert_v1()
 RETURNS void
 LANGUAGE plpgsql
 STABLE SECURITY DEFINER
 SET search_path TO ''
AS $function$
BEGIN

 IF NOT EXISTS(SELECT 1 FROM pg_catalog.pg_proc p JOIN pg_catalog.pg_language l ON l.oid=p.prolang WHERE p.oid=pg_catalog.to_regprocedure('mission_factory_owner.c416_kind_renewal_continuity_v1(uuid,uuid,uuid)') AND md5(p.prosrc)='daf00919217a021a27572479a19073a7' AND p.proowner='postgres'::regrole AND p.proacl::text='{postgres=X/postgres}' AND p.prosecdef AND p.provolatile='s' AND p.proconfig=ARRAY['search_path=""']::text[] AND p.prokind='f' AND p.proparallel='u' AND NOT p.proisstrict AND p.provariadic=0 AND p.proargmodes IS NULL AND p.proallargtypes IS NULL AND p.proargdefaults IS NULL AND p.prorettype='boolean'::regtype AND NOT p.proretset AND p.pronargdefaults=0 AND p.proargnames=ARRAY['p_draft','p_original_request','p_author']::text[] AND p.proargtypes::text='2950 2950 2950' AND l.lanname='sql') THEN RAISE EXCEPTION 'HUMAN16_CONTINUITY_CERTIFICATE_HELPER_ABI';END IF;
 IF NOT EXISTS(SELECT 1 FROM mission_factory_owner.c422_install_progress WHERE singleton AND complete AND next_unit=20 AND source_input_sha256='8085b8a1127f9d2d86301eafac37e2f6c70fb48cde55f2a9f5bfdcc94eee7093') THEN RAISE EXCEPTION 'C422_COMPOSED_HUMAN_QUALIFICATION_REQUIRED' USING ERRCODE='42501';END IF;
 IF NOT EXISTS(SELECT 1 FROM mission_factory_owner.c408_install_progress WHERE singleton AND source_input_sha256='17d5690518e455e22925aaf3f3d0f44bdd82ae86df6872fa7aea621a6a7e98b3' AND complete AND next_unit=16 AND target_ddl_qualification_sha256~'^[0-9a-f]{64}$') THEN RAISE EXCEPTION 'C408_ALL_UNITS_AND_ACTUAL_DDL_QUALIFICATION_REQUIRED' USING ERRCODE='42501';END IF;
 IF EXISTS(SELECT 1 FROM (SELECT jsonb_build_array(('["mission_academy_owner","mission_creation_owner","mission_factory_owner","mission_public_owner","public"]'::jsonb->>(p->>0)::int)||'.'||(p->>1)||'('||coalesce((SELECT string_agg('["mission_factory_owner.quest_run_sources","pg_catalog._text","pg_catalog._uuid","pg_catalog.bool","pg_catalog.int4","pg_catalog.int8","pg_catalog.jsonb","pg_catalog.text","pg_catalog.timestamptz","pg_catalog.uuid","public.mission_plan_transitions","public.mission_run_state"]'::jsonb->>v::int,',' ORDER BY o) FROM jsonb_array_elements_text(p->2)WITH ORDINALITY AS z(v,o)),'')||')',p->3)||('[[true,"v","postgres",["search_path=\"\""],["postgres"]],[true,"s","postgres",["search_path=\"\""],["postgres"]],[false,"v","postgres",["search_path=\"\""],["postgres"]],[true,"s","postgres",["search_path=\"\""],["authenticated","postgres"]],[false,"i","postgres",["search_path=\"\""],["postgres"]],[true,"v","postgres",["search_path=\"\""],["authenticated","postgres"]],[true,"v","postgres",["search_path=\"\""],["postgres","service_role"]]]'::jsonb->(p->>4)::int) AS e FROM jsonb_array_elements('[[2,"c347_receipt_immutable_v1",[],"0126db34638caad0c40be6769c1d9d4e",0],[2,"c347_native_facts_v1",[9,7,9,7],"a222ed36c37b64f89dbe2b69cc5c8430",0],[2,"c347_issue_native_receipt_v1",[9,7,9,7,9],"a57dbd085d2e61ce319e670ed5fb1f20",0],[2,"c347_validate_native_receipt_v1",[6,9,7,8],"5b2a22345f2be306c891ee74b836b4cf",0],[2,"c352_history_immutable_v1",[],"b0a870be4f5fe115f082be38a514e783",0],[2,"c352_native_resource_source_v1",[],"5902f4292ef7b167aa1ad664255fdcee",1],[2,"c352_prepare_resource_v1",[6],"e40a932dcdd73e39068268e94f8345d0",2],[2,"c352_resource_catalog_v1",[],"b77c874e033de63803c9958672d36fe1",1],[4,"mission_factory_catalog_v1",[],"0b3a4e84fd53535061dd2bb2365d7f0f",3],[4,"mission_factory_catalog_v2",[],"8cf99c6a615ad5eeac3eabddcbe6f4f7",1],[0,"c353_effective_threshold_v1",[4,4,4],"49ffebf8d9071f694d38c9146fa545e3",4],[2,"c353_d100_immutable_v1",[],"3c87bd34a14a37b09572b82b96346392",0],[4,"mission_factory_quest_d100_policy_catalog_v1",[9],"7776317a0494bc7399fdb1300707771b",5],[4,"mission_factory_quest_d100_bind_receipt_v1",[9],"6ccdcab28455c1ce108fe8658a2ee4f9",5],[4,"mission_factory_quest_d100_bind_v1",[9,9,7,7,9,9,7,7,5,9],"48793d9952ac0dcbb181213bc91357d0",5],[2,"c353_after_d100_v1",[9,9,9,4],"e5d1694567e73c4d52775b3377d0ba14",0],[2,"c353_d100_receipt_assert_v1",[9,9],"dd1f942ea6854165e06a160625c1c4e7",0],[0,"after_d100",[9,9,9,4],"ce9c2580b8752105427d3a3b0291286c",0],[2,"c360_phase_shape_v1",[6],"f2e2c8743c7ac168d7a78b806ee74f1f",4],[2,"c360_native_phase_assert_v1",[6],"e61d7db8292f98acdb2518077f3601f3",1],[4,"mission_factory_quest_d100_draft_policy_catalog_v1",[9,5],"da84606351828d80fdada5b64c2af7f8",3],[4,"mission_factory_quest_d100_wakeup_scope_v1",[9,9],"ffc02816fcc5e335ba7899fa72eb3fe5",6],[4,"mission_factory_quest_d100_pending_v1",[9],"57e7babb21507b6df6ca4d0d5c1aee35",6],[4,"mission_factory_quest_d100_consume_v1",[9,9,7],"d2ce506b547f1d7082194d57d1739dc7",6],[2,"validate_quest_draft_v2",[6],"0da0e5522287738b33f17b90d7a1c432",4],[2,"quest_deep_validate_v2",[9,6],"72b51aecd719c425d1d6c6dd3739f952",0],[2,"quest_compile_v1",[9],"e31e74e9fc87bf1582b63f4626267f30",0],[2,"quest_compile_check_v1",[9],"b1a3a6e9339da34d45cea23d21ee4832",1],[2,"quest_preview_basis_v1",[9,5,3],"21939a37af4b02c54d34719be2745e23",0],[2,"quest_decision_issue_v1",[9,9,5,7,7,9,7],"2fc5c1e420c123f032d2f2108e604ad9",0],[2,"quest_validate_evidence_v1",[11,10,6,8],"8475b5d8c73c3e1717961d6542e8cc99",0],[2,"c360_activate_staff_catalog_v1",[6],"94832819f80c8bb3f99dc0fcf45c721c",0],[4,"mission_factory_quest_d100_binding_scope_v1",[9],"6b43ebbdc6cb21c93927d40e63628c57",5],[2,"c384_validate_variant_v2",[6,6,7],"0c74df4b6335a21c24b7ba1eed34a069",4],[2,"c384_validate_dual_draft_v3",[6],"aaf868bba0da5b5eaece8bebf85f286c",4],[2,"c384_immutable_v1",[],"32299e2f2f941b22708fb8efd5f86c67",0],[2,"c384_dual_save_v1",[9,5,6,9],"ef79df6cbdd4ed5f700aaae4345f2cc5",0],[2,"c384_human_identity_v1",[9],"d51d2239739d5d5dfe264a2877d52d37",1],[2,"c384_human_publication_replay_v1",[9,9,7,5,9],"28da0ea196460f7810a67fafe3a786be",1],[2,"c384_human_bind_seal_v1",[9,9,5,9,9,9],"f7859e1d6b17f93a6fe7a54a0fc0f0d9",0],[2,"c395_prepare_assert_v1",[9,5,9,9],"2be3242bf59b21fcce437f062b0a32af",0],[2,"c395_revision_issue_v1",[9,5,9,9,9],"a863ba94b3412d0c58c2e7c2efa8139b",0],[2,"c395_binding_projection_v1",[0],"0b66c70fde49fea2925ce146ccd2f23b",1],[2,"c395_binding_insert_assert_v1",[9,9,6,7],"baa7abfe2e70335660d32b26cd77e888",0],[2,"c395_revision_assert_v1",[9],"00ecc50309178677bec990dce0e93daa",1],[2,"c395_human_mode_v1",[9],"98c2dd9142429998bfc8d137aee19c40",1],[2,"c395_active_human_assert_v1",[9],"8b80feeff37e0402120fa68b2b086947",0],[2,"c395_start_assert_v1",[9],"d0f82355e6d1ef9897edc76a26c96d54",0],[4,"mission_factory_quest_human_prepare_v1",[9,9,9,2,9,5,9],"2a83b1c57d14cc4f37b1326c0b68cc8b",5],[4,"mission_factory_quest_human_start_v1",[9,5,9],"8b72b71be42b248c1ca85b3eccadcaf9",5],[2,"c395_source_assert_v1",[9],"56dc0aaf7b5cde324f58947752510d50",0],[2,"quest_run_binding_guard_v1",[],"5efa189afcb8e3639054b42efaa37d2f",0],[1,"is_human",[9],"f9f3cfd42b5f9a0059247a97e8167881",1],[1,"human_assert",[9],"1ce886cdc79e7119ec47b59f52185c32",0],[2,"quest_run_source_assert_v1",[9],"0fb2f5aca06a41479f22c1ecf07738ee",0],[1,"route_human_outbox",[],"e909272590bc59976f63ce6f3a44e914",0],[2,"c407_identity_v1",[9],"ef0a29b5053665ad13f2df4fb57cccd3",1],[2,"c407_active_v1",[9,7],"ee1cd8d251f1eebbc056baf69b019239",0],[2,"c407_enroll_v1",[9],"e6d59bd7d1515ecea0388626cde25a5a",0],[2,"c407_arena_v1",[9,7],"ce8a15514bc292939a455f687bea04c1",1],[4,"mission_factory_quest_human_fato_publish_v1",[9,9,7,9],"77ec29bb0d60fde6d9d5cc08d446d168",5],[4,"mission_factory_quest_human_d100_consume_v1",[9,9,7],"01bbdb51911e2a380847da0040a2c3eb",5],[1,"human_enroll",[9],"a73a003f10d4a1cff816635cf9990ccb",0],[1,"arena_for_step",[9,7],"1e6146a461ce898ec9d846b92d936f95",1],[1,"human_open",[9,9],"55c22a96c0d63ac28051ae7114853c27",0],[3,"human_fato_scope_allowed_v2",[9],"c9f378ec6523f9d035435fa2fb353e34",1],[2,"quest_apply_authority_v1",[9,9,5,5,7,7,9,7,9],"09d2cd933b2f09f39cd3da13bcb9ffba",0],[2,"c412_read_identity_v1",[9],"7bdd302698207fd7f01b8cbf49920aaf",1],[2,"c412_revision_provenance_v1",[9],"707f715cbe2b964406560dd9c0b83b94",1],[2,"c412_source_assert_v1",[9],"a9526ea4216b8ba83d9097ebc0c92fef",0],[4,"mission_factory_quest_dual_save_v3",[9,5,6,9],"9a8b197d1d78ad0a928ca2b4de99b7f8",5],[4,"mission_factory_quest_dual_get_v3",[9,5],"8e7e961d7882cec1d327081df78cd17c",3],[2,"c412_fact_issue_v1",[9,9,5,7,7,9,7],"b9c290f201b1fc59938a024030242d6a",0],[2,"c412_fact_assert_v1",[9,9,5,7,7,7],"bc2377f4dd9a6c9d838b0a62889546e1",1],[4,"mission_factory_quest_human_terminal_prepare_v1",[9,9,5,9],"92df20717f2485b94a04220603ac32af",5],[4,"mission_factory_quest_human_terminal_publish_v1",[9,9,7,9],"770a3a4d053e3e9ef1d60b11563d44f6",5],[4,"mission_factory_quest_human_phase_action_v1",[9,5,7,7,9],"c275d93276703b033fdf874c31bbbea1",5],[4,"mission_factory_quest_human_round_publish_v1",[9,9,7,5,9],"054ae3e2c80bb9bca9c209048021bd19",5],[2,"c412_manual_fato_write_v1",[9,9,7,9],"a00e737d3e0363a7244c199b4707dc67",0],[2,"c416_kind_live_v1",[],"96766167969aff87b3b11452fd15c598",1],[2,"c416_cap_allowed_v1",[6,7],"86e797ff93036bafaab6867253618b45",1],[2,"c416_root_kind_register_v1",[7,7,1,2,9,6],"e664dbaa69f3f6ced90c6eb81952f8bc",0],[2,"c416_draft_assert_v1",[9,3],"4c8fb91e06a036f3998342bfbc98b3b8",1],[2,"c416_arc_assert_v1",[9,3],"2a18f541eafd92baa107cda0f15d2550",1],[4,"mission_factory_quest_dual_create_v3",[9,5,6,2,9],"1262390e33c3c3e885216b26bb1e609d",5],[2,"c416_validate_human_draft_v3",[6],"b36495eebd3071f3c62bb715e19b068a",4],[2,"c416_preview_basis_v3",[9,5,3],"5b5982b93629c7ca47e2d9679693cda9",0],[4,"mission_factory_quest_human_preview_v3",[9,5],"89efad0cce80f20c2b3f29ed9e5df565",5],[4,"mission_factory_quest_human_publish_v3",[9,5,7,9,7,8],"55ada638bbf2e5dd6c92ca882141afb5",5],[2,"npc_item_v2",[9,9,7,3],"dc260f7771e6ffd8d6d99ce67eb96de7",0],[2,"npc_custom_authoring_check_v1",[9,5,7,3],"7d14a659984865eaac36f0dbf271bc60",0],[2,"quest_publication_scope_v3",[9,3],"775033ca8434cbd732ca9fce7668b9d1",0],[2,"quest_roster_scope_assert_v3",[9,9,2],"cb8a7829e234612c84a9d21673c71e9c",0],[4,"mission_factory_context_media_ticket_v2",[9,7,7,9,7,5,7],"d6a233ac4e184c550625ee11a2dbf173",5],[4,"mission_factory_context_media_register_v2",[9,7,5,7,4,4],"a483d59ca8f9cbc742da777db08c6dee",6],[4,"mission_factory_context_media_catalog_v2",[9,7],"a5c4f7faaeeeb65e40dd344df600add9",3],[4,"mission_factory_quest_dual_import_v3",[9,5,6,2,9,5,9],"811bd99d9fce22b8b9714485ea4dae98",5]]'::jsonb) AS z(p)) AS seal LEFT JOIN pg_proc f ON f.oid=to_regprocedure(e->>0) WHERE f.oid IS NULL OR md5(f.prosrc) IS DISTINCT FROM e->>1 OR f.prosecdef IS DISTINCT FROM (e->>2)::boolean OR f.provolatile::text IS DISTINCT FROM e->>3 OR pg_get_userbyid(f.proowner) IS DISTINCT FROM e->>4 OR to_jsonb(f.proconfig) IS DISTINCT FROM e->5 OR coalesce((SELECT jsonb_agg(CASE WHEN a.grantee=0 THEN 'PUBLIC' ELSE pg_get_userbyid(a.grantee) END ORDER BY CASE WHEN a.grantee=0 THEN 'PUBLIC' ELSE pg_get_userbyid(a.grantee) END) FROM aclexplode(coalesce(f.proacl,acldefault('f',f.proowner))) a WHERE a.privilege_type='EXECUTE'),'[]'::jsonb) IS DISTINCT FROM e->6 OR EXISTS(SELECT 1 FROM aclexplode(coalesce(f.proacl,acldefault('f',f.proowner))) a WHERE a.is_grantable)) THEN RAISE EXCEPTION 'C408_COMPLETE_FUNCTION_CAS' USING ERRCODE='40001';END IF;
END $function$
;
CREATE OR REPLACE FUNCTION mission_factory_owner.c444_runtime_ports_complete_assert_v1()
 RETURNS void
 LANGUAGE plpgsql
 STABLE SECURITY DEFINER
 SET search_path TO ''
AS $function$BEGIN
IF EXISTS(SELECT 1 FROM jsonb_array_elements($c501_pins$[{"all_arg_types":[],"arg_modes":[],"arg_names":null,"body_md5":"2ede16b8539261f97581dfbcd6ac919c","configuration":["search_path=\"\""],"default_arg_count":0,"execute":["postgres"],"input_arg_types":[],"language":"plpgsql","lookup_signature":"mission_factory_owner.c408_stage1_complete_assert_v1()","oid":"279179","owner":"postgres","parallel":"u","return_type":"pg_catalog.void","returns_set":false,"security_definer":true,"strict":false,"variadic_type":null,"volatility":"s"}]$c501_pins$::jsonb) c501_expected LEFT JOIN pg_catalog.pg_proc c501_proc ON c501_proc.oid=pg_catalog.to_regprocedure(c501_expected->>'lookup_signature') WHERE c501_proc.oid IS NULL OR (c501_expected->>'oid' IS NOT NULL AND c501_proc.oid::text IS DISTINCT FROM c501_expected->>'oid') OR md5(c501_proc.prosrc) IS DISTINCT FROM c501_expected->>'body_md5' OR c501_proc.proargtypes::text IS DISTINCT FROM coalesce((SELECT string_agg(pg_catalog.to_regtype(c501_argtype)::oid::text,' ' ORDER BY c501_ord)FROM jsonb_array_elements_text(c501_expected->'input_arg_types')WITH ORDINALITY c501_inputs(c501_argtype,c501_ord)),'') OR coalesce((SELECT jsonb_agg(pg_catalog.format('%I.%I',c501_ns.nspname,c501_type.typname) ORDER BY c501_ord)FROM unnest(coalesce(c501_proc.proallargtypes,c501_proc.proargtypes::oid[]))WITH ORDINALITY c501_all(c501_type_oid,c501_ord)JOIN pg_catalog.pg_type c501_type ON c501_type.oid=c501_type_oid JOIN pg_catalog.pg_namespace c501_ns ON c501_ns.oid=c501_type.typnamespace),'[]'::jsonb) IS DISTINCT FROM c501_expected->'all_arg_types' OR to_jsonb(coalesce(c501_proc.proargmodes,array_fill('i'::"char",ARRAY[c501_proc.pronargs]))) IS DISTINCT FROM c501_expected->'arg_modes' OR coalesce(to_jsonb(c501_proc.proargnames),'null'::jsonb) IS DISTINCT FROM c501_expected->'arg_names' OR c501_proc.prorettype IS DISTINCT FROM pg_catalog.to_regtype(c501_expected->>'return_type') OR c501_proc.proretset IS DISTINCT FROM(c501_expected->>'returns_set')::boolean OR c501_proc.pronargdefaults IS DISTINCT FROM(c501_expected->>'default_arg_count')::integer OR (c501_proc.pronargdefaults=0 AND c501_proc.proargdefaults IS NOT NULL) OR c501_proc.provariadic IS DISTINCT FROM coalesce(pg_catalog.to_regtype(c501_expected->>'variadic_type')::oid,0::oid) OR c501_proc.proisstrict IS DISTINCT FROM(c501_expected->>'strict')::boolean OR c501_proc.provolatile::text IS DISTINCT FROM c501_expected->>'volatility' OR c501_proc.proparallel::text IS DISTINCT FROM c501_expected->>'parallel' OR c501_proc.prosecdef IS DISTINCT FROM(c501_expected->>'security_definer')::boolean OR(SELECT lanname FROM pg_catalog.pg_language WHERE oid=c501_proc.prolang)IS DISTINCT FROM c501_expected->>'language' OR to_jsonb(c501_proc.proconfig) IS DISTINCT FROM c501_expected->'configuration' OR pg_catalog.pg_get_userbyid(c501_proc.proowner)IS DISTINCT FROM c501_expected->>'owner' OR c501_proc.proleakproof OR coalesce((SELECT jsonb_agg(CASE WHEN c501_acl.grantee=0 THEN 'PUBLIC' ELSE pg_catalog.pg_get_userbyid(c501_acl.grantee)END ORDER BY CASE WHEN c501_acl.grantee=0 THEN 'PUBLIC' ELSE pg_catalog.pg_get_userbyid(c501_acl.grantee)END)FROM pg_catalog.aclexplode(coalesce(c501_proc.proacl,pg_catalog.acldefault('f',c501_proc.proowner)))c501_acl WHERE c501_acl.privilege_type='EXECUTE'),'[]'::jsonb)IS DISTINCT FROM c501_expected->'execute' OR EXISTS(SELECT 1 FROM pg_catalog.aclexplode(coalesce(c501_proc.proacl,pg_catalog.acldefault('f',c501_proc.proowner)))c501_acl WHERE c501_acl.is_grantable))THEN RAISE EXCEPTION 'C501_CURRENT_HUMAN_QUALIFIER_ABI_CAS' USING ERRCODE='40001';END IF;
PERFORM mission_factory_owner.c408_stage1_complete_assert_v1();
IF NOT EXISTS(SELECT 1 FROM mission_factory_owner.c444_install_progress WHERE singleton AND complete AND next_unit=26 AND source_input_sha256='9c814c08fba12afbdec246b477a73c0047d318b51dc7c83a23050bd9da9e0aa9')THEN RAISE EXCEPTION 'C501_SOURCE_FAMILY_COMPLETE_PREFIX_REQUIRED';END IF;
IF EXISTS(SELECT 1 FROM jsonb_array_elements((SELECT jsonb_agg('{"configuration":["search_path=\"\""],"default_arg_count":0,"owner":"postgres","parallel":"u","returns_set":false,"security_definer":true,"strict":false,"variadic_type":null}'::jsonb||p)FROM jsonb_array_elements('[{"all_arg_types":[],"arg_modes":[],"arg_names":null,"body_md5":"75fcad93b0da5fee0fc6b7af652a5e85","execute":["postgres"],"input_arg_types":[],"language":"sql","lookup_signature":"mission_factory_owner.c444_enabled_v1()","oid":null,"return_type":"pg_catalog.bool","volatility":"s"},{"all_arg_types":["pg_catalog.uuid"],"arg_modes":["i"],"arg_names":["p_session"],"body_md5":"0a7fa43e594605d397504828f1961f55","execute":["postgres"],"input_arg_types":["pg_catalog.uuid"],"language":"plpgsql","lookup_signature":"mission_factory_owner.c444_read_identity_v1(pg_catalog.uuid)","oid":null,"return_type":"pg_catalog.jsonb","volatility":"s"},{"all_arg_types":["pg_catalog.uuid"],"arg_modes":["i"],"arg_names":["p_session"],"body_md5":"a2f72b56b71b3a8ea089aff06a66e7ae","execute":["postgres"],"input_arg_types":["pg_catalog.uuid"],"language":"plpgsql","lookup_signature":"mission_factory_owner.c444_source_read_assert_v1(pg_catalog.uuid)","oid":null,"return_type":"pg_catalog.jsonb","volatility":"v"},{"all_arg_types":["pg_catalog.uuid"],"arg_modes":["i"],"arg_names":["p_episode"],"body_md5":"3ea3a2a0749910a979216b801a09bb2e","execute":["postgres"],"input_arg_types":["pg_catalog.uuid"],"language":"plpgsql","lookup_signature":"mission_factory_owner.c444_episode_read_assert_v1(pg_catalog.uuid)","oid":null,"return_type":"pg_catalog.void","volatility":"s"},{"all_arg_types":["pg_catalog.uuid"],"arg_modes":["i"],"arg_names":["p_episode"],"body_md5":"5d1943abf0a90cd395165756207e934e","execute":["postgres"],"input_arg_types":["pg_catalog.uuid"],"language":"plpgsql","lookup_signature":"mission_factory_owner.c444_enrollment_open_v1(pg_catalog.uuid)","oid":null,"return_type":"pg_catalog.bool","volatility":"v"},{"all_arg_types":["pg_catalog.uuid","pg_catalog.text","pg_catalog.bool","pg_catalog.int8","pg_catalog.uuid"],"arg_modes":["i","i","i","i","i"],"arg_names":["p_episode","p_operation","p_ready","p_expected_version","p_request"],"body_md5":"1bad66b63bff109cf4e65d14be59722f","execute":["postgres"],"input_arg_types":["pg_catalog.uuid","pg_catalog.text","pg_catalog.bool","pg_catalog.int8","pg_catalog.uuid"],"language":"plpgsql","lookup_signature":"mission_factory_owner.c444_enrollment_v1(pg_catalog.uuid,pg_catalog.text,pg_catalog.bool,pg_catalog.int8,pg_catalog.uuid)","oid":null,"return_type":"pg_catalog.jsonb","volatility":"v"},{"all_arg_types":["pg_catalog.uuid","pg_catalog.text","pg_catalog.bool","pg_catalog.int8","pg_catalog.uuid"],"arg_modes":["i","i","i","i","i"],"arg_names":["p_episode","p_operation","p_ready","p_expected_version","p_request"],"body_md5":"555a2c26cd901ba41d34c5365aa89755","execute":["authenticated","postgres"],"input_arg_types":["pg_catalog.uuid","pg_catalog.text","pg_catalog.bool","pg_catalog.int8","pg_catalog.uuid"],"language":"plpgsql","lookup_signature":"public.mission_factory_quest_enrollment_v1(pg_catalog.uuid,pg_catalog.text,pg_catalog.bool,pg_catalog.int8,pg_catalog.uuid)","oid":"276409","return_type":"pg_catalog.jsonb","volatility":"v"},{"all_arg_types":["pg_catalog.uuid"],"arg_modes":["i"],"arg_names":["p_session"],"body_md5":"85a879af8a80d50593fcb3970869249f","execute":["postgres"],"input_arg_types":["pg_catalog.uuid"],"language":"plpgsql","lookup_signature":"mission_factory_owner.c444_terminal_confirmed_v1(pg_catalog.uuid)","oid":null,"return_type":"pg_catalog.jsonb","volatility":"v"},{"all_arg_types":["pg_catalog.uuid"],"arg_modes":["i"],"arg_names":["p_session"],"body_md5":"1c6a6240f27b3add37546175768633a2","execute":["postgres"],"input_arg_types":["pg_catalog.uuid"],"language":"plpgsql","lookup_signature":"mission_factory_owner.quest_terminal_confirmed_v1(pg_catalog.uuid)","oid":"276431","return_type":"pg_catalog.jsonb","volatility":"v"},{"all_arg_types":["pg_catalog.uuid"],"arg_modes":["i"],"arg_names":["p_episode"],"body_md5":"5fa62eda7260904e189b55b06088254b","execute":["postgres"],"input_arg_types":["pg_catalog.uuid"],"language":"plpgsql","lookup_signature":"mission_factory_owner.c444_participant_state_v1(pg_catalog.uuid)","oid":null,"return_type":"pg_catalog.jsonb","volatility":"v"},{"all_arg_types":["pg_catalog.uuid"],"arg_modes":["i"],"arg_names":["p_episode"],"body_md5":"2169f3ddfbae60cf757cd2c555a9e2f7","execute":["authenticated","postgres"],"input_arg_types":["pg_catalog.uuid"],"language":"plpgsql","lookup_signature":"public.mission_factory_quest_participant_state_v1(pg_catalog.uuid)","oid":"276446","return_type":"pg_catalog.jsonb","volatility":"v"},{"all_arg_types":["pg_catalog.uuid"],"arg_modes":["i"],"arg_names":["p_request"],"body_md5":"d06ad7832dd3bc64fc0d0472d9965534","execute":["postgres"],"input_arg_types":["pg_catalog.uuid"],"language":"plpgsql","lookup_signature":"mission_factory_owner.c444_run_state_v1(pg_catalog.uuid)","oid":null,"return_type":"pg_catalog.jsonb","volatility":"v"},{"all_arg_types":["pg_catalog.uuid"],"arg_modes":["i"],"arg_names":["p_request"],"body_md5":"17a33bc8b9d5bdd4468aa582002cb7fa","execute":["authenticated","postgres"],"input_arg_types":["pg_catalog.uuid"],"language":"plpgsql","lookup_signature":"public.mission_factory_quest_run_state_v1(pg_catalog.uuid)","oid":"276432","return_type":"pg_catalog.jsonb","volatility":"v"},{"all_arg_types":["pg_catalog.uuid"],"arg_modes":["i"],"arg_names":["p_session"],"body_md5":"8d2d40aa16abbf40ea7801ae4ec49774","execute":["postgres"],"input_arg_types":["pg_catalog.uuid"],"language":"plpgsql","lookup_signature":"mission_factory_owner.c444_action_scope_v1(pg_catalog.uuid)","oid":null,"return_type":"pg_catalog.jsonb","volatility":"v"},{"all_arg_types":["pg_catalog.uuid"],"arg_modes":["i"],"arg_names":["p_session"],"body_md5":"7e7da01987e744d27f634cd93c4cd273","execute":["authenticated","postgres"],"input_arg_types":["pg_catalog.uuid"],"language":"plpgsql","lookup_signature":"public.mission_factory_quest_human_runtime_state_v1(pg_catalog.uuid)","oid":null,"return_type":"pg_catalog.jsonb","volatility":"v"},{"all_arg_types":["pg_catalog.uuid"],"arg_modes":["i"],"arg_names":["p_session"],"body_md5":"0bda32f1607eb10808df90b042f5473a","execute":["authenticated","postgres"],"input_arg_types":["pg_catalog.uuid"],"language":"plpgsql","lookup_signature":"public.mission_human_phase_state_v1(pg_catalog.uuid)","oid":"50702","return_type":"pg_catalog.jsonb","volatility":"s"}]'::jsonb)z(p))) c501_expected LEFT JOIN pg_catalog.pg_proc c501_proc ON c501_proc.oid=pg_catalog.to_regprocedure(c501_expected->>'lookup_signature') WHERE c501_proc.oid IS NULL OR (c501_expected->>'oid' IS NOT NULL AND c501_proc.oid::text IS DISTINCT FROM c501_expected->>'oid') OR md5(c501_proc.prosrc) IS DISTINCT FROM c501_expected->>'body_md5' OR c501_proc.proargtypes::text IS DISTINCT FROM coalesce((SELECT string_agg(pg_catalog.to_regtype(c501_argtype)::oid::text,' ' ORDER BY c501_ord)FROM jsonb_array_elements_text(c501_expected->'input_arg_types')WITH ORDINALITY c501_inputs(c501_argtype,c501_ord)),'') OR coalesce((SELECT jsonb_agg(pg_catalog.format('%I.%I',c501_ns.nspname,c501_type.typname) ORDER BY c501_ord)FROM unnest(coalesce(c501_proc.proallargtypes,c501_proc.proargtypes::oid[]))WITH ORDINALITY c501_all(c501_type_oid,c501_ord)JOIN pg_catalog.pg_type c501_type ON c501_type.oid=c501_type_oid JOIN pg_catalog.pg_namespace c501_ns ON c501_ns.oid=c501_type.typnamespace),'[]'::jsonb) IS DISTINCT FROM c501_expected->'all_arg_types' OR to_jsonb(coalesce(c501_proc.proargmodes,array_fill('i'::"char",ARRAY[c501_proc.pronargs]))) IS DISTINCT FROM c501_expected->'arg_modes' OR coalesce(to_jsonb(c501_proc.proargnames),'null'::jsonb) IS DISTINCT FROM c501_expected->'arg_names' OR c501_proc.prorettype IS DISTINCT FROM pg_catalog.to_regtype(c501_expected->>'return_type') OR c501_proc.proretset IS DISTINCT FROM(c501_expected->>'returns_set')::boolean OR c501_proc.pronargdefaults IS DISTINCT FROM(c501_expected->>'default_arg_count')::integer OR (c501_proc.pronargdefaults=0 AND c501_proc.proargdefaults IS NOT NULL) OR c501_proc.provariadic IS DISTINCT FROM coalesce(pg_catalog.to_regtype(c501_expected->>'variadic_type')::oid,0::oid) OR c501_proc.proisstrict IS DISTINCT FROM(c501_expected->>'strict')::boolean OR c501_proc.provolatile::text IS DISTINCT FROM c501_expected->>'volatility' OR c501_proc.proparallel::text IS DISTINCT FROM c501_expected->>'parallel' OR c501_proc.prosecdef IS DISTINCT FROM(c501_expected->>'security_definer')::boolean OR(SELECT lanname FROM pg_catalog.pg_language WHERE oid=c501_proc.prolang)IS DISTINCT FROM c501_expected->>'language' OR to_jsonb(c501_proc.proconfig) IS DISTINCT FROM c501_expected->'configuration' OR pg_catalog.pg_get_userbyid(c501_proc.proowner)IS DISTINCT FROM c501_expected->>'owner' OR c501_proc.proleakproof OR coalesce((SELECT jsonb_agg(CASE WHEN c501_acl.grantee=0 THEN 'PUBLIC' ELSE pg_catalog.pg_get_userbyid(c501_acl.grantee)END ORDER BY CASE WHEN c501_acl.grantee=0 THEN 'PUBLIC' ELSE pg_catalog.pg_get_userbyid(c501_acl.grantee)END)FROM pg_catalog.aclexplode(coalesce(c501_proc.proacl,pg_catalog.acldefault('f',c501_proc.proowner)))c501_acl WHERE c501_acl.privilege_type='EXECUTE'),'[]'::jsonb)IS DISTINCT FROM c501_expected->'execute' OR EXISTS(SELECT 1 FROM pg_catalog.aclexplode(coalesce(c501_proc.proacl,pg_catalog.acldefault('f',c501_proc.proowner)))c501_acl WHERE c501_acl.is_grantable))THEN RAISE EXCEPTION 'C501_PORTS_EFFECTIVE_FULL_ABI_ACL_CAS' USING ERRCODE='40001';END IF;
END$function$
;
DO $post$ BEGIN PERFORM mission_factory_owner.c444_runtime_ports_complete_assert_v1();PERFORM mission_factory_owner.c463_optin_complete_assert_v1();END $post$;COMMIT;
