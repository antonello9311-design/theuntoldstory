-- MISSION-GENERIC-COMBAT/1: candidato privato, nessun apply eseguito.
-- Comporre dopo MISSION_GENERIC_DB.sql e con l'adapter Common service del PM.
begin;
do $metadata$ begin
 if not exists(select 1 from pg_proc where oid=to_regprocedure('public.master_v2_encounter_open_ninja_book_v1_ai_service_core(uuid,uuid[],jsonb,jsonb,uuid,uuid)') and pg_get_userbyid(proowner)='postgres' and prosecdef and proconfig=ARRAY['search_path=""'] and proacl::text='{postgres=X/postgres}') then raise exception 'MG_COMBAT_METADATA_DRIFT';end if;
 if not exists(select 1 from pg_proc where oid=to_regprocedure('combat_panel_private.enroll_master(uuid)') and pg_get_userbyid(proowner)='postgres' and prosecdef and proconfig=ARRAY['search_path=""'] and proacl::text='{postgres=X/postgres}') then raise exception 'MG_COMBAT_METADATA_DRIFT';end if;
 if not exists(select 1 from pg_proc where oid=to_regprocedure('combat_panel_private.master_entry_trigger()') and pg_get_userbyid(proowner)='postgres' and prosecdef and proconfig=ARRAY['search_path=""'] and proacl::text='{postgres=X/postgres}') then raise exception 'MG_COMBAT_METADATA_DRIFT';end if;
 if not exists(select 1 from pg_proc where oid=to_regprocedure('combat_panel_private.uses_simulated_pools(uuid)') and pg_get_userbyid(proowner)='postgres' and prosecdef and proconfig=ARRAY['search_path=""'] and proacl::text='{postgres=X/postgres}') then raise exception 'MG_COMBAT_METADATA_DRIFT';end if;
 if not exists(select 1 from pg_proc where oid=to_regprocedure('combat_spatial.exchange_owner_receipt(uuid,uuid)') and pg_get_userbyid(proowner)='postgres' and prosecdef and proconfig=ARRAY['search_path=""'] and proacl::text='{postgres=X/postgres,service_role=X/postgres}') then raise exception 'MG_COMBAT_METADATA_DRIFT';end if;
 if not exists(select 1 from pg_proc where oid=to_regprocedure('public.universal_arena_state_v1(uuid)') and pg_get_userbyid(proowner)='postgres' and prosecdef and proconfig=ARRAY['search_path=""'] and proacl::text='{postgres=X/postgres,authenticated=X/postgres}') then raise exception 'MG_COMBAT_METADATA_DRIFT';end if;
 if not exists(select 1 from pg_constraint where conrelid='combat_spatial.arena_instances'::regclass and conname='arena_instances_master_session_id_key' and pg_get_constraintdef(oid)='UNIQUE (master_session_id)') then raise exception 'MG_ARENA_CONSTRAINT_DRIFT';end if;
end $metadata$;

do $pin$ begin
 if md5(pg_get_functiondef('public.master_v2_encounter_open_ninja_book_v1_ai_service_core(uuid,uuid[],jsonb,jsonb,uuid,uuid)'::regprocedure))<>'a5cf9a033b4913aee6cd27a8708c9b61'
 or md5(pg_get_functiondef('combat_panel_private.uses_simulated_pools(uuid)'::regprocedure))<>'bbd85ffd70c2bcf58b9ecb54b5f9e069'
 then raise exception 'MG_COMBAT_BASELINE_DRIFT';end if;
end $pin$;

create table mission_generic_owner.encounters (
 encounter_id uuid primary key references public.combat_v2_sessions(id),
 master_session_id uuid not null references mission_generic_owner.run_bindings(master_session_id),
 step_key text not null,run_control_version bigint not null check(run_control_version>0),
 encounter_key text not null,request_key uuid not null,request_fingerprint text not null,
 capability_id uuid not null references mission_ai_service_owner.capabilities(id),
 actor_map jsonb not null check(jsonb_typeof(actor_map)='array'),
 created_at timestamptz not null default clock_timestamp(),open_receipt jsonb not null,
 unique(master_session_id,run_control_version,encounter_key),unique(master_session_id,request_key)
);
alter table mission_generic_owner.encounters enable row level security;
revoke all on mission_generic_owner.encounters from public,anon,authenticated,service_role;
create trigger mission_generic_encounter_immutable before update or delete on mission_generic_owner.encounters
for each row execute function mission_generic_owner.immutable();

create function mission_generic_owner.assert_combat_scope(p_master uuid,p_cap uuid)
returns void language plpgsql security definer set search_path='' as $fn$
declare m public.master_v2_sessions;b mission_generic_owner.run_bindings; principals uuid[];l public.locations;
begin
 perform mission_generic_owner.assert_runtime(p_master);
 perform mission_ai_service_owner.assert_capability(p_master,p_cap);
 select * into strict m from public.master_v2_sessions where id=p_master;
 select * into strict b from mission_generic_owner.run_bindings where master_session_id=p_master;
 select * into strict l from public.locations where id=m.location_id;
 if m.owner_kind<>'ai_service' or m.master_user is not null or m.mission_id is null or m.tipo<>'quest'
 or m.closed_at is not null or m.suspended_at is not null or m.stato not in('preparazione','in_corso')
 or not l.is_active or l.is_test is null or b.snapshot_sha256<>mission_internal.fingerprint(b.snapshot)
 or b.snapshot#>>'{arena,mission_id}' is distinct from m.mission_id::text
 or b.snapshot#>>'{arena,location_id}' is distinct from m.location_id::text
 then raise exception 'MG_COMBAT_AUTHORITY' using errcode='42501';end if;
 if exists(select 1 from public.master_v2_participants p left join public.characters c on c.id=p.character_id
 where p.session_id=p_master and p.left_at is null and p.engagement_state='attivo'
 and (c.id is null or c.user_id is distinct from p.user_id_snapshot))
 then raise exception 'MG_COMBAT_ROSTER_IDENTITY_DRIFT' using errcode='42501';end if;
 select array_agg(distinct p.user_id_snapshot order by p.user_id_snapshot) into principals
 from public.master_v2_participants p join public.characters c on c.id=p.character_id and c.user_id=p.user_id_snapshot
 where p.session_id=p_master and p.left_at is null and p.engagement_state='attivo';
 if coalesce(cardinality(principals),0)=0 then raise exception 'MG_COMBAT_ROSTER_EMPTY';end if;
 if l.is_test and (l.id<>'0b85f354-9cdb-47e1-baf9-3d266bb7e06b'::uuid
 or combat_consumer_private.staff_test_allowed(l.id,principals,false) is distinct from true)
 then raise exception 'MG_COMBAT_TEST_SCOPE' using errcode='42501';end if;
end $fn$;

create function mission_generic_owner.binding_is_pinned(p_master uuid,p_binding uuid)
returns boolean language sql stable security definer set search_path='' as $fn$
 select exists(select 1 from mission_generic_owner.run_bindings r,
 lateral jsonb_array_elements(r.snapshot->'binding_pins') p
 join public.nb_mechanical_bindings b on b.id=(p->>'mechanical_binding_id')::uuid
 join public.nb_templates nt on nt.id=b.narrative_template_id
 join public.nb_template_versions nv on nv.id=b.narrative_version_id
 join public.nb_mechanical_templates mt on mt.id=b.mechanical_template_id
 join public.nb_mechanical_versions mv on mv.id=b.mechanical_version_id
 where r.master_session_id=p_master and b.id=p_binding and b.control_version=(p->>'control_version')::bigint
 and nt.id=(p->>'narrative_template_id')::uuid and nv.id=(p->>'narrative_version_id')::uuid
 and mt.id=(p->>'mechanical_template_id')::uuid and mv.id=(p->>'mechanical_version_id')::uuid
 and nt.control_version=(p->>'narrative_template_control_version')::bigint
 and nv.control_version=(p->>'narrative_version_control_version')::bigint
 and mt.control_version=(p->>'mechanical_template_control_version')::bigint
 and mv.control_version=(p->>'mechanical_version_control_version')::bigint
 and nv.content_sha256=p->>'narrative_content_sha256' and mv.content_sha256=p->>'mechanical_content_sha256')
$fn$;

-- Trasferisce solo le risorse reali dell'ultimo incontro dello stesso run/attore.
-- Nessuna lettura di PG diversi, nessuna scrittura in characters o inventario.
create function mission_generic_owner.carry_snapshot(p_master uuid,p_character uuid,p_client uuid,p_fresh jsonb)
returns jsonb language plpgsql security definer set search_path='' as $fn$
declare prior jsonb;
begin
 select a.mechanics_snapshot into prior from mission_generic_owner.encounters e
 join public.combat_v2_sessions s on s.id=e.encounter_id
 join public.combat_v2_actors a on a.session_id=s.id
 left join public.combat_v2_provider_instances_v1 pi on pi.id=a.provider_instance_v1_id
 where e.master_session_id=p_master and s.state='chiuso' and s.closed_at is not null
 and ((p_character is not null and a.character_id=p_character)
 or (p_character is null and p_client is not null and pi.client_ref=p_client))
 order by e.created_at desc,e.encounter_id desc limit 1;
 if prior is null then return p_fresh;end if;
 if prior->'vita_max' is distinct from p_fresh->'vita_max' or prior->'chakra_max' is distinct from p_fresh->'chakra_max'
 or jsonb_typeof(prior->'vita') is distinct from 'number' or jsonb_typeof(prior->'chakra') is distinct from 'number'
 then raise exception 'MG_COMBAT_RESOURCE_BASELINE_CHANGED' using errcode='40001';end if;
 return p_fresh||jsonb_build_object('vita',prior->'vita','chakra',prior->'chakra');
end $fn$;

-- Un'unica arena aperta per master; lo storico resta distinto per encounter.
-- La guardia additive sotto conserva il vincolo storico assoluto sui percorsi legacy.
alter table combat_spatial.arena_instances drop constraint arena_instances_master_session_id_key;
create unique index arena_instances_master_open_unique on combat_spatial.arena_instances(master_session_id)
where master_session_id is not null and state='open';
create function mission_generic_owner.arena_multi_guard() returns trigger
language plpgsql security definer set search_path='' as $fn$
begin
 if new.master_session_id is null then return new;end if;
 perform 1 from public.master_v2_sessions where id=new.master_session_id for update;
 if exists(select 1 from combat_spatial.arena_instances i where i.master_session_id=new.master_session_id and i.instance_id<>new.instance_id)
 and not exists(select 1 from mission_generic_owner.encounters e where e.master_session_id=new.master_session_id
 and e.encounter_id=new.encounter_id and new.context_source='panel_master')
 then raise exception 'MG_ARENA_LEGACY_UNIQUENESS' using errcode='23505';end if;
 return new;
end $fn$;
create trigger mission_generic_arena_multi_guard before insert or update of master_session_id,encounter_id,context_source
on combat_spatial.arena_instances for each row execute function mission_generic_owner.arena_multi_guard();

create function mission_generic_owner.bind_arena_native(p_master uuid,p_encounter uuid,p_request uuid)
returns jsonb language plpgsql security definer set search_path='' as $fn$
declare e mission_generic_owner.encounters;b mission_generic_owner.run_bindings;m public.master_v2_sessions;
 t combat_spatial.arena_templates;src jsonb;pid uuid;claim uuid;iid uuid;policy text;chosen boolean;
 a record;slot record;radius numeric;principal uuid;
begin
 select * into strict e from mission_generic_owner.encounters where encounter_id=p_encounter and master_session_id=p_master;
 perform mission_generic_owner.assert_combat_scope(p_master,e.capability_id);
 select * into strict m from public.master_v2_sessions where id=p_master for update;
 select * into strict b from mission_generic_owner.run_bindings where master_session_id=p_master;
 src:=b.snapshot->'arena';
 select * into strict t from combat_spatial.arena_templates
 where template_key=src->>'template_key' and template_version=(src->>'template_version')::integer and status='ready' for share;
 perform 1 from combat_spatial.arena_slots where template_key=t.template_key and template_version=t.template_version order by slot_key for share;
 perform 1 from combat_spatial.arena_objects where template_key=t.template_key and template_version=t.template_version order by object_key for share;
 if src->>'zone_key'<>'arena' or src->>'catalog_sha256' is distinct from combat_panel_private.universal_arena_hash(t.template_key,t.template_version)
 or t.geometry_hash is distinct from combat_spatial.geometry_fingerprint(t.template_key,t.template_version)
 or combat_spatial.template_errors(t.template_key,t.template_version)<>'[]'::jsonb
 then raise exception 'MG_ARENA_FROZEN_CATALOG_DRIFT' using errcode='40001';end if;
 if exists(select 1 from combat_spatial.arena_instances where encounter_id=p_encounter)
 or exists(select 1 from public.combat_v2_declarations d join public.combat_v2_rounds r on r.id=d.round_id where r.session_id=p_encounter)
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
 values(pid,m.location_id,'Arena missione',t.template_key,t.template_version,1,t.geometry_hash,policy,'participants',true);
 insert into combat_panel_private.master_scene_claims(id,profile_id,profile_version,master_session_id,encounter_id,
 template_key,template_version,authority_principal_id,authority_control_version,geometry_fingerprint,roster_fingerprint,policy_id,visibility_mode)
 values(claim,pid,1,p_master,p_encounter,t.template_key,t.template_version,e.capability_id,m.control_version,
 t.geometry_hash,combat_panel_private.master_roster_fingerprint(p_encounter),policy,'participants');
 insert into combat_spatial.arena_instances(instance_id,master_session_id,encounter_id,binding_id,template_key,template_version,map_version,state,context_source,panel_claim_id)
 values(iid,p_master,p_encounter,null,t.template_key,t.template_version,1,'open','panel_master',claim);
 -- Le opzioni e le collisioni derivano dal catalogo server; nessuna coordinata IA/client.
 for a in select * from public.combat_v2_actors where session_id=p_encounter and state='attivo' order by actor_kind,id loop
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
 for a in select * from combat_spatial.actor_states where instance_id=iid loop
  if combat_spatial.path_first_block_t(iid,a.actor_id,a.x_m,a.y_m,a.x_m,a.y_m,null)<1
  then raise exception 'MG_ARENA_FINAL_OCCUPANCY_INVALID' using errcode='22023';end if;
 end loop;
 return jsonb_build_object('instance_id',iid,'claim_id',claim,'map_version',1);
end $fn$;

CREATE OR REPLACE FUNCTION mission_generic_owner.open_core(p_master_session uuid, p_pg_ids uuid[], p_actor_offers jsonb, p_team_map jsonb, p_request_key uuid, p_capability uuid)
 RETURNS jsonb
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO ''
AS $function$
declare
  v_uid uuid:=null::uuid; v_cap uuid:=p_capability; v_m public.master_v2_sessions%rowtype; v_event jsonb; v_event_id uuid;
  v_enc uuid; v_round uuid; v_pg uuid; v_snap jsonb; v_team text; v_spec jsonb;
  v_offer public.master_v2_nb_actor_offers_v1%rowtype; v_nt public.nb_templates%rowtype;
  v_nv public.nb_template_versions%rowtype; v_b public.nb_mechanical_bindings%rowtype;
  v_mt public.nb_mechanical_templates%rowtype; v_mv public.nb_mechanical_versions%rowtype;
  v_instance uuid; v_mode text; v_result jsonb; v_count integer; v_client uuid; v_offer_ref uuid;
begin
  perform mission_generic_owner.assert_combat_scope(p_master_session,v_cap);
  if v_cap is null then perform public.master_v2_nb_fail_v1('autenticazione_richiesta','Capability IA richiesta.',401,p_request_key); end if;
  select * into v_m from public.master_v2_sessions where id=p_master_session;
  if v_m.id is null then perform public.master_v2_nb_fail_v1('sessione_inesistente','Sessione Master inesistente.',404,p_request_key); end if;
  if (v_m.owner_kind<>'ai_service' or v_m.master_user is not null or v_cap is null) then perform public.master_v2_nb_fail_v1('master_non_proprietario','Solo il Master corrente può aprire lo scontro.',403,p_request_key); end if;
  if v_m.tipo<>'quest' or v_m.mission_id is null or v_m.stato not in ('preparazione','in_corso') then
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
  if exists(select 1 from public.characters c where c.id=any(p_pg_ids) and c.user_id=v_uid) then
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
  if (v_m.owner_kind<>'ai_service' or v_m.master_user is not null or v_cap is null) then perform public.master_v2_nb_fail_v1('master_non_proprietario','Controllo Master cambiato durante l’apertura.',409,p_request_key); end if;
  if v_m.tipo<>'quest' or v_m.stato not in ('preparazione','in_corso') then
    perform public.master_v2_nb_fail_v1('sessione_non_operativa','Sessione non più operativa.',409,p_request_key);
  end if;
  v_event:=public.combat_v2_event_begin_ai_service(p_master_session,p_request_key,
    'mission_generic_combat_open',jsonb_build_object('pg',p_pg_ids,'actors',p_actor_offers,'teams',p_team_map),v_m.control_version,v_cap);
  if (v_event->>'replay')::boolean then
    v_event_id:=(v_event->>'event_id')::uuid;
    insert into public.master_v2_nb_offer_audit_v1(offer_ref,event_id,action,actor_user,actor_service_capability,actor_kind)
    select (x->>'offer_ref')::uuid,v_event_id,'replay',null,v_cap,'ai_service' from jsonb_array_elements(p_actor_offers) x
    on conflict do nothing;
    return v_event->'result';
  end if;
  v_event_id:=(v_event->>'event_id')::uuid;
  if exists(select 1 from public.combat_sessions where location_id=v_m.location_id and state='aperto')
     or exists(select 1 from public.combat_v2_sessions where location_id=v_m.location_id and state not in ('chiuso','annullato')) then
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
    if v_offer.master_session_id<>p_master_session or v_offer.mission_id<>v_m.mission_id
       or (v_offer.recipient_kind<>'ai_service' or v_offer.recipient_user is not null or v_offer.recipient_service_capability is distinct from v_cap) or v_offer.lifecycle_state<>'offerta'
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
       or v_b.lifecycle_state<>'approved' or not mission_generic_owner.binding_is_pinned(p_master_session,v_b.id)
       or (not v_b.active and not exists(select 1 from public.locations where id=v_m.location_id and is_test))
       or v_b.mechanical_template_id<>v_mt.id or v_b.mechanical_version_id<>v_mv.id
       or v_mt.lifecycle_state<>'approved' or (not v_mt.active and not exists(select 1 from public.locations where id=v_m.location_id and is_test)) or v_mt.current_version_id<>v_mv.id
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
    v_snap:=mission_generic_owner.carry_snapshot(p_master_session,v_pg,null,public.combat_v2_character_snapshot(v_pg)); v_team:=nullif(btrim(p_team_map->>v_pg::text),'');
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
    v_snap:=mission_generic_owner.carry_snapshot(p_master_session,null,v_client,v_snap);
    insert into public.combat_v2_provider_instances_v1(session_id,client_ref,provider,offer_ref,
      narrative_template_ref,narrative_version_ref,mechanical_template_ref,mechanical_version_ref,
      source_sha256,snapshot_sha256,nome,snapshot)
    values(v_enc,v_client,'ninja_book',v_offer_ref,v_offer.narrative_template_id,v_offer.narrative_version_id,
      v_offer.mechanical_template_id,v_offer.mechanical_version_id,v_mv.content_sha256,public.combat_v2_sha256(v_snap),v_nt.display_name,v_snap)
    returning id into v_instance;
    insert into public.combat_v2_actors(session_id,actor_kind,provider_instance_v1_id,controller_user,team_key,position_m,initiative_snapshot,mechanics_snapshot)
    values(v_enc,'png',v_instance,null,v_team,0,(v_mv.stats->>'velocita')::integer,v_snap);
    update public.master_v2_nb_actor_offers_v1 set lifecycle_state='consumata',consumed_event_id=v_event_id,
      consumed_at=clock_timestamp(),control_version=control_version+1,updated_at=clock_timestamp() where offer_ref=v_offer_ref;
    insert into public.master_v2_nb_offer_audit_v1(offer_ref,event_id,action,actor_user,actor_service_capability,actor_kind,details)
    values(v_offer_ref,v_event_id,'consumo',null,v_cap,'ai_service',jsonb_build_object('provider_instance_id',v_instance));
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


create function public.mission_generic_combat_open_v1(p_session uuid,p_encounter_key text,p_expected_run_version bigint,p_request_key uuid)
returns jsonb language plpgsql security definer set search_path='' as $fn$
declare m public.master_v2_sessions;run public.mission_run_state;c mission_ai_service_owner.capabilities;
 existing mission_generic_owner.encounters;spec jsonb;scene jsonb;pgs uuid[];actors jsonb:='[]';teams jsonb:='{}';
 a jsonb;pin jsonb;offer uuid;client uuid;child uuid;res jsonb;enc uuid;arena jsonb;maps jsonb;fp text;
 nt public.nb_templates;nv public.nb_template_versions;mb public.nb_mechanical_bindings;
 mt public.nb_mechanical_templates;mv public.nb_mechanical_versions;
begin
 perform mission_ai_service_owner.service_only();
 if p_request_key is null or p_encounter_key is null or p_expected_run_version is null then raise exception 'MG_COMBAT_OPEN_INPUT';end if;
 perform mission_ai_service_owner.lock_request(p_request_key);
 select * into strict m from public.master_v2_sessions where id=p_session;
 perform 1 from public.locations where id=m.location_id for update;
 perform public.master_v2_lock_scope(p_session);
 select * into strict m from public.master_v2_sessions where id=p_session for update;
 select * into strict c from mission_ai_service_owner.capabilities where master_session_id=p_session for update;
 perform mission_generic_owner.assert_combat_scope(p_session,c.id);
 fp:=public.combat_v2_sha256(jsonb_build_object('master',p_session,'encounter',p_encounter_key,'run_version',p_expected_run_version,'capability',c.id));
 select * into existing from mission_generic_owner.encounters where master_session_id=p_session and request_key=p_request_key;
 if found then
  if existing.request_fingerprint<>fp then raise exception 'MG_COMBAT_REPLAY_CONFLICT' using errcode='40001';end if;
  return existing.open_receipt||jsonb_build_object('replayed',true);
 end if;
 select * into strict run from public.mission_run_state where master_session_id=p_session for update;
 if run.control_version<>p_expected_run_version or run.run_phase<>'in_corso'
 then raise exception 'MG_COMBAT_RUN_CAS' using errcode='40001';end if;
 scene:=mission_generic_owner.scene(p_session,run.current_step_key);
 select value into strict spec from jsonb_array_elements(scene->'encounters') where value->>'encounter_key'=p_encounter_key;
 if spec->>'pg_policy'<>'all_active' or spec->>'arena_ref'<>'mission' or jsonb_array_length(spec->'actors')=0
 then raise exception 'MG_COMBAT_SCENE_NOT_COMBAT' using errcode='22023';end if;
 if exists(select 1 from mission_generic_owner.encounters where master_session_id=p_session and
 run_control_version=run.control_version and encounter_key=p_encounter_key)
 then raise exception 'MG_COMBAT_ALREADY_OPENED_THIS_VISIT' using errcode='40001';end if;
 -- Non chiude implicitamente altri incontri o risorse. La chiusura terminale ha una propria ricevuta.
 if exists(select 1 from public.combat_v2_sessions where master_session_id=p_session and (state<>'chiuso' or closed_at is null))
 then raise exception 'MG_COMBAT_PREVIOUS_NOT_CLOSED' using errcode='55000';end if;
 select array_agg(p.character_id order by p.character_id) into pgs from public.master_v2_participants p
 join public.characters pg on pg.id=p.character_id and pg.user_id=p.user_id_snapshot
 where p.session_id=p_session and p.left_at is null and p.engagement_state='attivo';
 select coalesce(jsonb_object_agg(x::text,spec->>'pg_team'),'{}') into teams from unnest(pgs) x;
 for a in select value from jsonb_array_elements(spec->'actors') order by value->>'actor_key' loop
  select * into strict mb from public.nb_mechanical_bindings where id=(a->>'mechanical_binding_id')::uuid for share;
  if not mission_generic_owner.binding_is_pinned(p_session,mb.id) then raise exception 'MG_COMBAT_PIN_DRIFT' using errcode='40001';end if;
  select * into strict nt from public.nb_templates where id=mb.narrative_template_id for share;
  select * into strict nv from public.nb_template_versions where id=mb.narrative_version_id for share;
  select * into strict mt from public.nb_mechanical_templates where id=mb.mechanical_template_id for share;
  select * into strict mv from public.nb_mechanical_versions where id=mb.mechanical_version_id for share;
  offer:=mission_ai_service_owner.uuid5(p_request_key,'offer:'||(a->>'actor_key'));
  client:=mission_ai_service_owner.uuid5(p_session,'actor:'||(a->>'actor_key'));
  insert into public.master_v2_nb_actor_offers_v1(offer_ref,master_session_id,mission_id,recipient_user,recipient_kind,
  recipient_service_capability,narrative_template_id,narrative_version_id,mechanical_template_id,mechanical_version_id,
  expected_master_control_version,expected_narrative_template_control_version,expected_narrative_version_control_version,
  expected_binding_control_version,expected_mechanical_template_control_version,expected_mechanical_version_control_version,
  expected_narrative_sha256,expected_mechanical_sha256,lifecycle_state,control_version,expires_at,created_by,created_by_service_capability)
  values(offer,p_session,m.mission_id,null,'ai_service',c.id,nt.id,nv.id,mt.id,mv.id,m.control_version,
  nt.control_version,nv.control_version,mb.control_version,mt.control_version,mv.control_version,
  nv.content_sha256,mv.content_sha256,'offerta',1,clock_timestamp()+interval '15 minutes',null,c.id);
  actors:=actors||jsonb_build_array(jsonb_build_object('client_ref',client,'provider','ninja_book','offer_ref',offer));
  teams:=teams||jsonb_build_object(client::text,a->>'team');
 end loop;
 child:=mission_ai_service_owner.uuid5(p_request_key,'generic-encounter');
 res:=mission_generic_owner.open_core(p_session,pgs,actors,teams,child,c.id);
 enc:=(res#>>'{data,encounter_id}')::uuid;
 if enc is null then raise exception 'MG_COMBAT_NATIVE_RECEIPT_SHAPE';end if;
 select jsonb_agg(x.v order by x.v->>'actor_key') into maps from (
  select jsonb_build_object('actor_key','pg:'||ca.character_id::text,'actor_id',ca.id,'character_id',ca.character_id) v
   from public.combat_v2_actors ca where ca.session_id=enc and ca.actor_kind='pg'
  union all
  select jsonb_build_object('actor_key',j->>'actor_key','actor_id',ca.id,'mechanical_binding_id',j->>'mechanical_binding_id')
   from public.combat_v2_actors ca join public.combat_v2_provider_instances_v1 pi on pi.id=ca.provider_instance_v1_id
   cross join jsonb_array_elements(spec->'actors') j where ca.session_id=enc
   and pi.client_ref=mission_ai_service_owner.uuid5(p_session,'actor:'||(j->>'actor_key'))
 ) x;
 if jsonb_array_length(maps)<>cardinality(pgs)+jsonb_array_length(actors) then raise exception 'MG_COMBAT_MAPPING_INCOMPLETE';end if;
 update public.combat_v2_actors set state='fuori' where session_id=enc and (mechanics_snapshot->>'vita')::integer<=0;
 if (select count(distinct team_key) from public.combat_v2_actors where session_id=enc and state='attivo')<2
 then raise exception 'MG_COMBAT_NO_OPPOSING_ACTIVE_TEAMS' using errcode='22023';end if;
 res:=jsonb_build_object('schema_version','mission-generic-encounter/1','master_session_id',p_session,'encounter_id',enc,
 'step_key',run.current_step_key,'run_control_version',run.control_version,'encounter_key',p_encounter_key,'combat',res,'actor_map',maps);
 insert into mission_generic_owner.encounters(encounter_id,master_session_id,step_key,run_control_version,encounter_key,
 request_key,request_fingerprint,capability_id,actor_map,open_receipt)
 values(enc,p_session,run.current_step_key,run.control_version,p_encounter_key,p_request_key,fp,c.id,maps,res);
 arena:=mission_generic_owner.bind_arena_native(p_session,enc,p_request_key);
 -- Non aggiornare la ricevuta immutabile dopo il bind: arena IDs deterministici sono ricavabili dall'incontro.
 perform combat_panel_private.assert_master_ready(enc);
 if (select is_test from public.locations where id=m.location_id) and not combat_panel_private.uses_simulated_pools(enc)
 then raise exception 'MG_COMBAT_SIMULATION_NOT_BOUND' using errcode='42501';end if;
 return res;
end $fn$;

create function public.mission_generic_combat_close_v1(p_session uuid,p_encounter uuid,p_expected_run_version bigint,p_request_key uuid)
returns jsonb language plpgsql security definer set search_path='' as $fn$
declare e mission_generic_owner.encounters;run public.mission_run_state;s public.combat_v2_sessions;m public.master_v2_sessions;
 ev jsonb;res jsonb;
begin
 perform mission_ai_service_owner.service_only();
 if p_session is null or p_encounter is null or p_request_key is null or p_expected_run_version is null then raise exception 'MG_COMBAT_CLOSE_INPUT';end if;
 perform mission_ai_service_owner.lock_request(p_request_key);
 perform public.master_v2_lock_scope(p_session);
 select * into strict m from public.master_v2_sessions where id=p_session for update;
 select * into strict e from mission_generic_owner.encounters where encounter_id=p_encounter and master_session_id=p_session;
 perform mission_generic_owner.assert_combat_scope(p_session,e.capability_id);
 ev:=public.combat_v2_event_begin_ai_service(p_session,p_request_key,'mission_generic_combat_close',
 jsonb_build_object('encounter_id',p_encounter,'run_version',p_expected_run_version),m.control_version,e.capability_id);
 if (ev->>'replay')::boolean then return ev->'result';end if;
 select * into strict run from public.mission_run_state where master_session_id=p_session for update;
 select * into strict s from public.combat_v2_sessions where id=p_encounter and master_session_id=p_session for update;
 if run.control_version<>p_expected_run_version or run.current_step_key<>e.step_key
 or s.state<>'risolto' or s.closed_at is not null
 or not exists(select 1 from public.combat_v2_rounds where session_id=s.id)
 or exists(select 1 from public.combat_v2_rounds where session_id=s.id and state<>'narrato')
 then raise exception 'MG_COMBAT_TERMINAL_NOT_READY' using errcode='40001';end if;
 -- Stessa chiusura dell'incontro nella closure nativa, senza chiusura della missione.
 update public.combat_v2_sessions set state='chiuso',closed_at=clock_timestamp() where id=s.id;
 res:=public.combat_v2_envelope(p_request_key,jsonb_build_object('encounter_id',s.id,'state','chiuso',
 'master_session_id',p_session,'step_key',e.step_key,'encounter_key',e.encounter_key,'run_version',run.control_version,
 'terminal_event_id',(ev->>'event_id')::uuid));
 return public.combat_v2_event_complete((ev->>'event_id')::uuid,res);
end $fn$;


create function mission_generic_owner.enroll_native(p_master uuid) returns void
language plpgsql security definer set search_path='' as $fn$
declare m public.master_v2_sessions;b mission_generic_owner.run_bindings;l public.locations;policy text;
begin
 select * into strict m from public.master_v2_sessions where id=p_master for update;
 select * into strict b from mission_generic_owner.run_bindings where master_session_id=p_master;
 select * into strict l from public.locations where id=m.location_id;
 if m.owner_kind<>'ai_service' or m.master_user is not null or m.mission_id is null
 or b.snapshot_sha256<>mission_internal.fingerprint(b.snapshot)
 or b.snapshot#>>'{arena,location_id}' is distinct from m.location_id::text
 or b.snapshot#>>'{arena,mission_id}' is distinct from m.mission_id::text
 or l.is_test is null or not l.is_active
 or not exists(select 1 from mission_ai_service_owner.capabilities where master_session_id=p_master)
 then raise exception 'MG_ENROLL_AUTHORITY' using errcode='42501';end if;
 if l.is_test and l.id<>'0b85f354-9cdb-47e1-baf9-3d266bb7e06b'::uuid then raise exception 'MG_ENROLL_TEST_LOCATION' using errcode='42501';end if;
 policy:=case when l.is_test then 'staff_test_no_persistent_resources_v1' else 'master_game_resources_v1' end;
 insert into combat_panel_private.master_panel_sessions(master_session_id,location_id,policy_id)
 values(p_master,m.location_id,policy) on conflict(master_session_id) do nothing;
 if not exists(select 1 from combat_panel_private.master_panel_sessions where master_session_id=p_master and location_id=m.location_id and policy_id=policy)
 then raise exception 'MG_ENROLL_POLICY_DRIFT' using errcode='42501';end if;
end $fn$;

create function mission_generic_owner.assert_native_actor(a public.combat_v2_actors) returns void
language plpgsql security definer set search_path='' as $fn$
declare s public.combat_v2_sessions;c uuid;scene jsonb;
begin
 select * into strict s from public.combat_v2_sessions where id=a.session_id;
 select id into strict c from mission_ai_service_owner.capabilities where master_session_id=s.master_session_id and state='active';
 perform mission_generic_owner.assert_combat_scope(s.master_session_id,c);
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
end $fn$;

do $patch$ declare src text;old text;new text;begin
 src:=pg_get_functiondef('combat_panel_private.enroll_master(uuid)'::regprocedure);
 if md5(src)<>'3c4fedad2d3f12da837cbd6fdb2eccce' then raise exception 'MG_ENROLL_BASELINE_DRIFT';end if;
 old:=' SELECT * INTO STRICT m FROM public.master_v2_sessions WHERE id=p_master FOR UPDATE;';
 new:=old||E'\n IF EXISTS(SELECT 1 FROM mission_generic_owner.run_bindings WHERE master_session_id=p_master) THEN\n  PERFORM mission_generic_owner.enroll_native(p_master); RETURN;\n END IF;';
 if (length(src)-length(replace(src,old,'')))/length(old)<>1 then raise exception 'MG_ENROLL_PATCH_DRIFT';end if;
 execute replace(src,old,new);
 src:=pg_get_functiondef('combat_panel_private.master_entry_trigger()'::regprocedure);
 if md5(src)<>'eb631425a179b3d96e4cae224900782d' then raise exception 'MG_ENTRY_BASELINE_DRIFT';end if;
 old:='   SELECT * INTO STRICT s FROM public.combat_v2_sessions WHERE id=NEW.session_id;';
 new:=old||E'\n   IF EXISTS(SELECT 1 FROM mission_generic_owner.run_bindings WHERE master_session_id=s.master_session_id) THEN\n    PERFORM mission_generic_owner.assert_native_actor(NEW); RETURN NEW;\n   END IF;';
 if (length(src)-length(replace(src,old,'')))/length(old)<>1 then raise exception 'MG_ENTRY_ACTOR_PATCH_DRIFT';end if;
 src:=replace(src,old,new);
 old:=E' ELSIF TG_TABLE_SCHEMA=''public'' AND TG_TABLE_NAME=''mission_run_state'' THEN';
 new:=old||E'\n   IF EXISTS(SELECT 1 FROM mission_generic_owner.run_bindings WHERE master_session_id=NEW.master_session_id) THEN\n    PERFORM mission_generic_owner.enroll_native(NEW.master_session_id);\n    IF NEW.plan_version_id IS DISTINCT FROM (SELECT (snapshot->>''plan_version_id'')::uuid FROM mission_generic_owner.run_bindings WHERE master_session_id=NEW.master_session_id) THEN\n     RAISE EXCEPTION ''MG_NATIVE_RUN_PLAN_DRIFT'' USING ERRCODE=''42501'';\n    END IF;\n    RETURN NEW;\n   END IF;';
 if (length(src)-length(replace(src,old,'')))/length(old)<>1 then raise exception 'MG_ENTRY_RUN_PATCH_DRIFT';end if;
 execute replace(src,old,new);
end $patch$;

-- Ricevuta spaziale nativa: stessa firma/fatti, cardinalità dal roster vivo invece di 2v2.
do $clone$ declare src text;old text;new text;begin
 src:=pg_get_functiondef('combat_spatial.exchange_owner_receipt(uuid,uuid)'::regprocedure);
 if md5(src)<>'2a33b6c81ee49015986b25379396725d' then raise exception 'MG_SPATIAL_BASELINE_DRIFT';end if;
 src:=replace(src,'combat_spatial.exchange_owner_receipt(', 'mission_generic_owner.exchange_owner_receipt(');
 old:='exact_events boolean;fp text;';new:='exact_events boolean;fp text;expected_count integer;';
 if (length(src)-length(replace(src,old,'')))/length(old)<>1 then raise exception 'MG_SPATIAL_DECLARE_DRIFT';end if;src:=replace(src,old,new);
 old:='   select * into strict t from combat_spatial.arena_templates where template_key=i.template_key and template_version=i.template_version;';
 new:=old||E'\n   IF NOT EXISTS(SELECT 1 FROM mission_generic_owner.encounters WHERE encounter_id=i.encounter_id AND master_session_id=i.master_session_id) THEN RAISE EXCEPTION ''MG_SPATIAL_SCOPE''; END IF;\n   SELECT count(*) INTO expected_count FROM combat_spatial.actor_states WHERE instance_id=p_instance AND state=''active'';';
 if (length(src)-length(replace(src,old,'')))/length(old)<>1 then raise exception 'MG_SPATIAL_ROSTER_DRIFT';end if;src:=replace(src,old,new);
 if (length(src)-length(replace(src,'count(*)=4','')))/length('count(*)=4')<>2 then raise exception 'MG_SPATIAL_COUNT_DRIFT';end if;
 src:=replace(src,'count(*)=4','count(*)=expected_count and expected_count>0');
 src:=replace(src,'count(distinct a.actor_id)=4','count(distinct a.actor_id)=expected_count');
 src:=replace(src,'count(distinct e.actor_id)=4','count(distinct e.actor_id)=expected_count');
 src:=replace(src,E'count(*)filter(where a.actor_kind=''PG'')=2 and count(*)filter(where a.actor_kind=''PNG'')=2',
 E'count(*)filter(where a.actor_kind=''PG'')>=1 and count(*)filter(where a.actor_kind=''PNG'')>=1');
 execute src;
 src:=pg_get_functiondef('combat_spatial.exchange_owner_receipt(uuid,uuid)'::regprocedure);
 old:='  begin';
 new:=old||E'\n   IF EXISTS(SELECT 1 FROM mission_generic_owner.encounters e JOIN combat_spatial.arena_instances i ON i.encounter_id=e.encounter_id WHERE i.instance_id=p_instance) THEN RETURN mission_generic_owner.exchange_owner_receipt(p_instance,p_round); END IF;';
 if (length(src)-length(replace(src,old,'')))/length(old)<>1 then raise exception 'MG_SPATIAL_HOOK_DRIFT';end if;
 execute replace(src,old,new);
end $clone$;

-- Protezione risorse: ramo Generic prima dei rami legacy, che restano intatti.
do $patch$ declare src text;old text;new text;begin
 src:=pg_get_functiondef('combat_panel_private.uses_simulated_pools(uuid)'::regprocedure);
 old:=E'BEGIN\n IF exam_regia_private.is_bound(p_session) THEN RETURN true; END IF;';
 new:=E'BEGIN\n IF EXISTS(SELECT 1 FROM mission_generic_owner.encounters WHERE encounter_id=p_session) THEN\n   RETURN mission_generic_owner.uses_simulated_pools(p_session);\n END IF;\n IF exam_regia_private.is_bound(p_session) THEN RETURN true; END IF;';
 if (length(src)-length(replace(src,old,'')))/length(old)<>1 then raise exception 'MG_RESOURCE_PATCH_DRIFT';end if;
 execute replace(src,old,new);
end $patch$;

create function mission_generic_owner.uses_simulated_pools(p_encounter uuid)
returns boolean language plpgsql security definer set search_path='' as $fn$
declare e mission_generic_owner.encounters;m public.master_v2_sessions;i combat_spatial.arena_instances;
 c combat_panel_private.master_scene_claims;principals uuid[];sim boolean;
begin
 select * into strict e from mission_generic_owner.encounters where encounter_id=p_encounter;
 select * into strict m from public.master_v2_sessions where id=e.master_session_id;
 select is_test into strict sim from public.locations where id=m.location_id and is_active;
 select * into strict i from combat_spatial.arena_instances where encounter_id=p_encounter and master_session_id=m.id and context_source='panel_master';
 select * into strict c from combat_panel_private.master_scene_claims where id=i.panel_claim_id and encounter_id=p_encounter and master_session_id=m.id;
 if c.authority_principal_id<>e.capability_id or not exists(select 1 from mission_ai_service_owner.capabilities
 where id=e.capability_id and master_session_id=m.id) then raise exception 'MG_RESOURCE_AUTHORITY' using errcode='42501';end if;
 if sim then
  select array_agg(distinct a.controller_user) into principals from public.combat_v2_actors a where a.session_id=p_encounter and a.actor_kind='pg';
  if c.policy_id<>'staff_test_no_persistent_resources_v1'
  or combat_consumer_private.staff_test_allowed(m.location_id,principals,false) is distinct from true
  or exists(select 1 from public.combat_v2_actors a left join public.characters pg on pg.id=a.character_id
    where a.session_id=p_encounter and a.actor_kind='pg' and (pg.id is null or pg.user_id is distinct from a.controller_user))
  then raise exception 'MG_RESOURCE_TEST_SCOPE' using errcode='42501';end if;
 elsif c.policy_id<>'master_game_resources_v1' then raise exception 'MG_RESOURCE_POLICY' using errcode='42501';end if;
 return sim;
end $fn$;

-- La pagina comune conserva la RPC pubblica e la stessa autorizzazione partecipanti.
-- Solo dopo tale controllo, le missioni Generic leggono la propria fonte congelata.
create function mission_generic_owner.arena_state(p_master uuid) returns jsonb
language sql stable security definer set search_path='' as $fn$
 select jsonb_build_object('schema_version','universal-arena-state/1','status','ready','master_session_id',p_master,
 'origin','mission','mission_id',m.mission_id,'location_id',m.location_id,
 'template_key',b.snapshot#>>'{arena,template_key}','template_version',(b.snapshot#>>'{arena,template_version}')::integer,
 'zone_key',b.snapshot#>>'{arena,zone_key}','catalog_sha256',b.snapshot#>>'{arena,catalog_sha256}','frozen_at',b.attached_at)
 from mission_generic_owner.run_bindings b join public.master_v2_sessions m on m.id=b.master_session_id
 where b.master_session_id=p_master and b.snapshot_sha256=mission_internal.fingerprint(b.snapshot)
$fn$;
do $patch$ declare src text;old text;new text;begin
 src:=pg_get_functiondef('public.universal_arena_state_v1(uuid)'::regprocedure);
 if md5(src)<>'406819c3379cb206f751114e27393513' then raise exception 'MG_ARENA_STATE_BASELINE_DRIFT';end if;
 old:=E' IF auth.uid() IS NULL THEN RAISE EXCEPTION ''authentication_required'' USING ERRCODE=''28000''; END IF;';
 new:=E' IF auth.uid() IS NULL THEN\n  IF EXISTS(SELECT 1 FROM mission_generic_owner.encounters e\n   JOIN public.combat_v2_sessions s ON s.id=e.encounter_id AND s.closed_at IS NULL\n   JOIN mission_ai_service_owner.capabilities c ON c.id=e.capability_id AND c.master_session_id=e.master_session_id AND c.state=''active'',\n   LATERAL jsonb_array_elements(e.actor_map) a\n   WHERE e.master_session_id=p_master AND a->>''mechanical_binding_id'' IS NOT NULL\n   AND mission_ai_service_owner.uuid5((a->>''actor_id'')::uuid,''mission-generic-principal'')=exam_regia_private.current_principal()) THEN\n   RETURN mission_generic_owner.arena_state(p_master);\n  END IF;\n  RAISE EXCEPTION ''authentication_required'' USING ERRCODE=''28000'';\n END IF;';
 if (length(src)-length(replace(src,old,'')))/length(old)<>1 then raise exception 'MG_ARENA_STATE_AUTH_PATCH_DRIFT';end if;
 src:=replace(src,old,new);
 old:=' SELECT * INTO frozen FROM combat_panel_private.universal_arena_snapshots WHERE master_session_id=m.id;';
 new:=E' IF EXISTS(SELECT 1 FROM mission_generic_owner.run_bindings WHERE master_session_id=m.id) THEN\n  RETURN mission_generic_owner.arena_state(m.id);\n END IF;\n'||old;
 if (length(src)-length(replace(src,old,'')))/length(old)<>1 then raise exception 'MG_ARENA_STATE_PATCH_DRIFT';end if;
 execute replace(src,old,new);
end $patch$;

revoke all on function mission_generic_owner.assert_combat_scope(uuid,uuid),
mission_generic_owner.binding_is_pinned(uuid,uuid),mission_generic_owner.carry_snapshot(uuid,uuid,uuid,jsonb),
mission_generic_owner.arena_multi_guard(),mission_generic_owner.bind_arena_native(uuid,uuid,uuid),
mission_generic_owner.open_core(uuid,uuid[],jsonb,jsonb,uuid,uuid),mission_generic_owner.uses_simulated_pools(uuid),mission_generic_owner.arena_state(uuid),
mission_generic_owner.enroll_native(uuid),mission_generic_owner.assert_native_actor(public.combat_v2_actors),mission_generic_owner.exchange_owner_receipt(uuid,uuid)
from public,anon,authenticated,service_role;
revoke all on function public.mission_generic_combat_open_v1(uuid,text,bigint,uuid) from public,anon,authenticated,service_role;
grant execute on function public.mission_generic_combat_open_v1(uuid,text,bigint,uuid) to service_role;
revoke all on function public.mission_generic_combat_close_v1(uuid,uuid,bigint,uuid) from public,anon,authenticated,service_role;
grant execute on function public.mission_generic_combat_close_v1(uuid,uuid,bigint,uuid) to service_role;
commit;
