BEGIN;
DO $pins$
BEGIN
  IF md5(pg_get_functiondef('public.master_v2_encounter_open(uuid,uuid[],jsonb,jsonb,uuid,jsonb)'::regprocedure)) IS DISTINCT FROM 'e2c728fba47622b4f942925ae5c69487' THEN
    RAISE EXCEPTION 'STAFF_MASTER_ROSTER_BASELINE: public.master_v2_encounter_open(uuid,uuid[],jsonb,jsonb,uuid,jsonb)';
  END IF;
  IF md5(pg_get_functiondef('clan_innata_narrative_private.world_passive_role_v1(uuid,uuid,uuid)'::regprocedure)) IS DISTINCT FROM 'eb0a439f50d705590582be4e7942f2fb' THEN
    RAISE EXCEPTION 'STAFF_MASTER_ROSTER_BASELINE: clan_innata_narrative_private.world_passive_role_v1(uuid,uuid,uuid)';
  END IF;
  IF md5(pg_get_functiondef('combat_gate_private.engagement_insert_guard()'::regprocedure)) IS DISTINCT FROM '28bc96f74f3215a29f5d7c0bd4179668' THEN
    RAISE EXCEPTION 'STAFF_MASTER_ROSTER_BASELINE: combat_gate_private.engagement_insert_guard()';
  END IF;
  IF md5(pg_get_functiondef('public.master_v2_lock_scope(uuid)'::regprocedure)) IS DISTINCT FROM 'b6e04b4d804ca90d1883a105097cfeee' THEN
    RAISE EXCEPTION 'STAFF_MASTER_ROSTER_BASELINE: public.master_v2_lock_scope(uuid)';
  END IF;
  IF md5(pg_get_functiondef('public.enter_land()'::regprocedure)) IS DISTINCT FROM '8f3e1ebd35fe9000039fe0e59256172a' THEN
    RAISE EXCEPTION 'STAFF_MASTER_ROSTER_BASELINE: public.enter_land()';
  END IF;
  IF md5(pg_get_functiondef('clan_innata_narrative_private.world_passive_bind_v1(uuid)'::regprocedure)) IS DISTINCT FROM 'bfdb2864810e5c3a916f8498df9f154e' THEN
    RAISE EXCEPTION 'STAFF_MASTER_ROSTER_BASELINE: clan_innata_narrative_private.world_passive_bind_v1(uuid)';
  END IF;
  IF md5(pg_get_functiondef('combat_panel_private.enroll_master(uuid)'::regprocedure)) IS DISTINCT FROM 'fefaa38e4964b45df46e01be43b62f12' THEN
    RAISE EXCEPTION 'STAFF_MASTER_ROSTER_BASELINE: combat_panel_private.enroll_master(uuid)';
  END IF;
  IF md5(pg_get_functiondef('clan_innata_narrative_private.materialize_v1(uuid)'::regprocedure)) IS DISTINCT FROM 'de20c46ac54f6593d0af2dcb1595a313' THEN
    RAISE EXCEPTION 'STAFF_MASTER_ROSTER_BASELINE: clan_innata_narrative_private.materialize_v1(uuid)';
  END IF;
  IF md5(pg_get_functiondef('clan_innata_narrative_private.staff_profile_authorize_v1(uuid,uuid,uuid)'::regprocedure)) IS DISTINCT FROM 'a1dbc557398d38ca8583d2e4372247c4' THEN
    RAISE EXCEPTION 'STAFF_MASTER_ROSTER_BASELINE: clan_innata_narrative_private.staff_profile_authorize_v1(uuid,uuid,uuid)';
  END IF;
END $pins$;
CREATE TABLE combat_panel_private.staff_prepared_duel_rosters_v1 (
  master_session_id uuid PRIMARY KEY REFERENCES public.master_v2_sessions(id),
  control_version bigint NOT NULL,
  saved_at timestamptz NOT NULL DEFAULT statement_timestamp()
);
ALTER TABLE combat_panel_private.staff_prepared_duel_rosters_v1 ENABLE ROW LEVEL SECURITY;
REVOKE ALL ON combat_panel_private.staff_prepared_duel_rosters_v1 FROM PUBLIC, anon, authenticated, service_role;

CREATE FUNCTION public.master_v2_staff_prepare_roster_v1(p_session uuid, p_pg_ids uuid[], p_expected bigint)
RETURNS jsonb LANGUAGE plpgsql SECURITY DEFINER SET search_path TO ''
AS $fn$
DECLARE
  v_location CONSTANT uuid := '0b85f354-9cdb-47e1-baf9-3d266bb7e06b';
  v_pair CONSTANT uuid[] := ARRAY['2a877f02-4993-4e65-9172-7d29f08c5b86'::uuid,'6bceee99-974f-426b-8d92-38b43b4a4267'::uuid];
  v_master public.master_v2_sessions;
  v_principals uuid[];
  v_saved uuid[];
BEGIN
  IF auth.uid() IS NULL OR NOT public.is_staff() OR cardinality(p_pg_ids) IS DISTINCT FROM 2
     OR NOT (p_pg_ids @> v_pair)
     OR NOT combat_consumer_private.staff_test_allowed(v_location,ARRAY[auth.uid()],false)
  THEN RAISE EXCEPTION 'STAFF_ROSTER_SCOPE' USING ERRCODE='42501'; END IF;

  PERFORM 1 FROM public.locations l WHERE l.id=v_location AND l.is_active AND l.is_test FOR UPDATE;
  IF NOT FOUND THEN RAISE EXCEPTION 'STAFF_ROSTER_SCOPE' USING ERRCODE='42501'; END IF;
  PERFORM combat_gate_private.master_claim_assert(p_session,v_location);
  -- Match the native opening order, location then characters then Master.
  PERFORM 1 FROM public.characters c WHERE c.id=ANY(v_pair) ORDER BY c.id FOR KEY SHARE;
  SELECT * INTO v_master FROM public.master_v2_sessions m WHERE m.id=p_session AND m.location_id=v_location FOR UPDATE;
  IF NOT FOUND OR v_master.master_user IS DISTINCT FROM auth.uid() OR v_master.control_version IS DISTINCT FROM p_expected
     OR v_master.owner_kind IS DISTINCT FROM 'human' OR v_master.tipo IS DISTINCT FROM 'duello'
     OR v_master.mission_id IS NOT NULL OR v_master.stato IS DISTINCT FROM 'preparazione'
     OR v_master.closed_at IS NOT NULL OR v_master.suspended_at IS NOT NULL
     OR NOT EXISTS (SELECT 1 FROM combat_panel_private.master_panel_sessions p
        WHERE p.master_session_id=v_master.id AND p.location_id=v_location AND p.policy_id='staff_test_no_persistent_resources_v1')
     OR EXISTS (SELECT 1 FROM public.combat_v2_sessions s WHERE s.master_session_id=v_master.id)
     OR EXISTS (SELECT 1 FROM exam_human_private.native_bindings b WHERE b.master_session_id=v_master.id)
  THEN RAISE EXCEPTION 'STAFF_ROSTER_PREPARATION_REQUIRED' USING ERRCODE='55000'; END IF;

  SELECT array_agg(DISTINCT c.user_id) INTO v_principals FROM public.characters c
    WHERE c.id=ANY(v_pair) AND c.vita>0 AND public._combat_presente(c.user_id,v_location);
  IF cardinality(v_principals) IS DISTINCT FROM 2
     OR NOT (auth.uid()=ANY(v_principals))
     OR NOT combat_consumer_private.staff_test_allowed(v_location,v_principals,false)
  THEN RAISE EXCEPTION 'STAFF_ROSTER_PARTICIPANTS_REQUIRED' USING ERRCODE='42501'; END IF;

  SELECT array_agg(p.character_id ORDER BY p.character_id) INTO v_saved
  FROM public.master_v2_participants p
  WHERE p.session_id=p_session AND p.left_at IS NULL AND p.engagement_state='attivo';
  IF v_saved IS NOT NULL AND (cardinality(v_saved) IS DISTINCT FROM 2 OR NOT (v_saved @> v_pair)) THEN
    RAISE EXCEPTION 'STAFF_ROSTER_MISMATCH' USING ERRCODE='55000';
  END IF;

  IF v_saved IS NULL THEN
    INSERT INTO public.master_v2_participants(session_id,character_id,user_id_snapshot)
      SELECT p_session,c.id,c.user_id FROM public.characters c WHERE c.id=ANY(v_pair) ORDER BY c.id;
  END IF;
  INSERT INTO combat_panel_private.staff_prepared_duel_rosters_v1 AS existing(master_session_id,control_version)
    VALUES (p_session,v_master.control_version)
    ON CONFLICT (master_session_id) DO UPDATE SET control_version=excluded.control_version
    WHERE existing.control_version IS DISTINCT FROM excluded.control_version;
  RETURN jsonb_build_object('session_id',p_session,'participants',v_pair,'saved',true);
END $fn$;
REVOKE ALL ON FUNCTION public.master_v2_staff_prepare_roster_v1(uuid,uuid[],bigint) FROM PUBLIC, anon, authenticated, service_role;
GRANT EXECUTE ON FUNCTION public.master_v2_staff_prepare_roster_v1(uuid,uuid[],bigint) TO authenticated;
CREATE OR REPLACE FUNCTION public.enter_land()
 RETURNS void
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO 'public'
AS $function$
declare v_seen timestamptz; v_flag boolean; v_name text; v_fresh boolean;
  v_location uuid; v_staff_resume boolean;
begin
  if auth.uid() is null then return; end if;
  select name into v_name from public.characters where user_id = auth.uid();
  if v_name is null then
    raise exception 'Devi prima creare il tuo personaggio.';
  end if;
  select last_seen,left_logged,location_id into v_seen,v_flag,v_location
    from public.presence where user_id=auth.uid();
  -- A reload of an authenticated Staff playtest must not change the real sheet.
  v_staff_resume := v_flag IS FALSE
    AND v_location IS NOT DISTINCT FROM '0b85f354-9cdb-47e1-baf9-3d266bb7e06b'::uuid
    AND public.is_staff() IS TRUE
    AND EXISTS (SELECT 1 FROM public.locations l WHERE l.id=v_location AND l.is_active AND l.is_test)
    AND EXISTS (
      SELECT 1 FROM public.characters c
      WHERE c.user_id=auth.uid() AND c.id IN ('2a877f02-4993-4e65-9172-7d29f08c5b86'::uuid,'6bceee99-974f-426b-8d92-38b43b4a4267'::uuid)
    );
  if not v_staff_resume then perform public.applica_recupero(); end if;
  v_fresh := (v_seen is null or v_seen < now() - interval '12 minutes' or coalesce(v_flag,false));
  if v_fresh then
    insert into public.presence_events(user_id,name,event_type,location_id,location_name)
      values (auth.uid(), v_name, 'enter', null, null);
    insert into public.presence(user_id,last_seen,location_id,left_logged)
      values (auth.uid(),now(),case when v_staff_resume then v_location else null end,false)
      on conflict (user_id) do update set last_seen=now(),location_id=excluded.location_id,left_logged=false;
  else
    update public.presence set last_seen=now(), left_logged=false where user_id=auth.uid();
  end if;
end; $function$
;
CREATE OR REPLACE FUNCTION public.master_v2_encounter_open(p_master_session uuid, p_pg_ids uuid[], p_png_specs jsonb, p_team_map jsonb, p_request_key uuid, p_positions jsonb DEFAULT NULL::jsonb)
 RETURNS jsonb
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO ''
AS $function$
declare v_uid uuid:=auth.uid(); v_m public.master_v2_sessions%rowtype; v_event jsonb; v_event_id uuid;
  v_enc uuid; v_round uuid; v_pg uuid; v_snap jsonb; v_ref text; v_team text; v_spec jsonb; v_tpl public.png_templates%rowtype;
  v_png uuid; v_actor uuid; v_mode text; v_result jsonb; v_count integer; v_pos integer;
begin
 if mission_creation_owner.is_human(p_master_session) then raise exception 'MC_USE_PHASE_ENCOUNTER_ACTION' using errcode='42501';end if;
  if v_uid is null then perform public.combat_v2_fail('autenticazione_richiesta','Autenticazione richiesta.',401,p_request_key,'{}'); end if;
  select * into v_m from public.master_v2_sessions where id=p_master_session;
  if v_m.id is null then perform public.combat_v2_fail('sessione_inesistente','Sessione Master inesistente.',404,p_request_key,'{}'); end if;
  if v_m.master_user<>v_uid then perform public.combat_v2_fail('master_non_proprietario','Solo il Master corrente può aprire lo scontro.',403,p_request_key,'{}'); end if;
  if v_m.stato not in ('preparazione','in_corso') then perform public.combat_v2_fail('sessione_non_operativa','Sessione non operativa.',409,p_request_key,'{}'); end if;
  if p_pg_ids is null or cardinality(p_pg_ids)<1 or cardinality(p_pg_ids)>12 or p_png_specs is null or jsonb_typeof(p_png_specs)<>'array' or jsonb_array_length(p_png_specs)>12 then
    perform public.combat_v2_fail('intento_non_valido','Elenco attori non valido.',422,p_request_key,'{}');
  end if;
  select count(distinct x) into v_count from unnest(p_pg_ids) x;
  if v_count<>cardinality(p_pg_ids) then perform public.combat_v2_fail('intento_non_valido','PG duplicato.',422,p_request_key,'{}'); end if;
  if exists(select 1 from public.characters c where c.id=any(p_pg_ids) and c.user_id=v_uid) and not (public.is_staff() and exists(select 1 from public.locations l where l.id=v_m.location_id and l.is_test)) then
    perform public.combat_v2_fail('attore_non_controllato','Il Master corrente non può essere un attore PG.',422,p_request_key,'{}');
  end if;
  if (select count(*) from public.characters c where c.id=any(p_pg_ids))<>cardinality(p_pg_ids) then
    perform public.combat_v2_fail('intento_non_valido','Uno o più PG non esistono.',422,p_request_key,'{}');
  end if;
  if p_team_map is null or jsonb_typeof(p_team_map)<>'object' then perform public.combat_v2_fail('intento_non_valido','Mappa squadre non valida.',422,p_request_key,'{}'); end if;
  if p_positions is not null and jsonb_typeof(p_positions)<>'object' then perform public.combat_v2_fail('intento_non_valido','Mappa posizioni non valida.',422,p_request_key,'{}'); end if;
  perform 1 from public.locations l where l.id=v_m.location_id order by l.id for update;
  perform combat_gate_private.master_claim_assert(p_master_session,v_m.location_id);
  perform 1 from public.characters c where c.id=any(p_pg_ids) order by c.id for key share;
  perform public.master_v2_lock_scope(p_master_session);
  select * into v_m from public.master_v2_sessions where id=p_master_session for update;
  if v_m.master_user<>v_uid then perform public.combat_v2_fail('master_non_proprietario','Controllo Master cambiato durante l’apertura.',409,p_request_key,'{}'); end if;
  if v_m.stato not in ('preparazione','in_corso') then perform public.combat_v2_fail('sessione_non_operativa','Sessione non più operativa.',409,p_request_key,'{}'); end if;
  v_event:=public.combat_v2_event_begin(p_master_session,p_request_key,'master_v2_encounter_open',jsonb_build_object('pg',p_pg_ids,'png',p_png_specs,'teams',p_team_map),v_m.control_version);
  if (v_event->>'replay')::boolean then return v_event->'result'; end if;
  v_event_id:=(v_event->>'event_id')::uuid;
  if exists(select 1 from public.combat_sessions where location_id=v_m.location_id and state='aperto')
     or exists(select 1 from public.combat_v2_sessions where location_id=v_m.location_id AND user_test_context_id IS NULL and state not in ('chiuso','annullato')) then
    perform public.combat_v2_fail('scontro_gia_aperto_nel_luogo','Esiste già uno scontro nel luogo.',409,p_request_key,'{}');
  end if;
  if v_m.location_id='0b85f354-9cdb-47e1-baf9-3d266bb7e06b'::uuid
    and v_m.tipo='duello' and v_m.owner_kind='human' and v_m.mission_id is null and v_m.stato='preparazione'
    and exists(select 1 from combat_panel_private.staff_prepared_duel_rosters_v1 saved where saved.master_session_id=v_m.id)
    and (
      not exists(select 1 from combat_panel_private.staff_prepared_duel_rosters_v1 saved
        where saved.master_session_id=v_m.id and saved.control_version=v_m.control_version)
      or cardinality(p_pg_ids) <> (select count(*) from public.master_v2_participants p
        where p.session_id=v_m.id and p.left_at is null and p.engagement_state='attivo')
      or exists (
        select 1 from public.master_v2_participants p join public.characters c on c.id=p.character_id
        where p.session_id=v_m.id and p.left_at is null and p.engagement_state='attivo'
          and (not(p.character_id=any(p_pg_ids)) or p.user_id_snapshot is distinct from c.user_id
            or not public._combat_presente(c.user_id,v_m.location_id))
      ) or jsonb_array_length(p_png_specs)<>0
    )
  then raise exception 'STAFF_ROSTER_MISMATCH' using errcode='55000'; end if;
  insert into public.combat_v2_sessions(source_kind,master_session_id,location_id,state,lesiva)
  values('master',p_master_session,v_m.location_id,'in_corso',(not exam_human_private.ordinary_encounter_permit_v1(p_master_session,p_request_key) and not exists(select 1 from public.locations l where l.id=v_m.location_id and l.is_test))) returning id into v_enc;
  foreach v_pg in array p_pg_ids loop
    v_snap:=public.combat_v2_character_snapshot(v_pg);
    if v_snap is null then perform public.combat_v2_fail('intento_non_valido','Snapshot PG non disponibile.',422,p_request_key,jsonb_build_object('character',v_pg)); end if;
    v_team:=nullif(btrim(p_team_map->>v_pg::text),'');
    if v_team is null then perform public.combat_v2_fail('intento_non_valido','Squadra PG mancante.',422,p_request_key,jsonb_build_object('character',v_pg)); end if;
    v_pos := case when p_positions is null or p_positions->>(v_pg::text) is null then 0
                  when (p_positions->>(v_pg::text)) ~ '^[0-9]{1,2}$' then (p_positions->>(v_pg::text))::int
                  else -1 end;
    if v_pos<0 or v_pos>60 or (v_pos % 5)<>0 then perform public.combat_v2_fail('intento_non_valido','Posizione iniziale non valida: 0-60 metri a passi di 5.',422,p_request_key,jsonb_build_object('character',v_pg)); end if;
    insert into public.combat_v2_actors(session_id,actor_kind,character_id,controller_user,team_key,position_m,initiative_snapshot,mechanics_snapshot)
    select v_enc,'pg',c.id,c.user_id,v_team,v_pos,c.velocita,v_snap from public.characters c where c.id=v_pg returning id into v_actor;
    insert into public.master_v2_participants(session_id,character_id,user_id_snapshot)
    select p_master_session,c.id,c.user_id from public.characters c where c.id=v_pg on conflict(session_id,character_id) do nothing;
  end loop;
  for v_spec in select value from jsonb_array_elements(p_png_specs) loop
    if jsonb_typeof(v_spec)<>'object' or public.combat_v2_has_forbidden_key(v_spec)
       or exists(select 1 from jsonb_object_keys(v_spec) k where k not in ('client_ref','template_id','nome','pos')) then
      perform public.combat_v2_fail('campo_meccanico_vietato','Specifica PNG non valida.',422,p_request_key,'{}');
    end if;
    begin v_ref:=v_spec->>'client_ref'; select * into v_tpl from public.png_templates where id=(v_spec->>'template_id')::uuid and (is_active or exam_human_private.combat_open_permit_v1(p_master_session,p_request_key,id));
    exception when invalid_text_representation then perform public.combat_v2_fail('intento_non_valido','Riferimento PNG non valido.',422,p_request_key,'{}'); end;
    if v_tpl.id is null or v_ref is null then perform public.combat_v2_fail('opzione_non_offerta','Template PNG non offerto.',422,p_request_key,'{}'); end if;
    v_team:=nullif(btrim(p_team_map->>v_ref),'');
    if v_team is null then perform public.combat_v2_fail('intento_non_valido','Squadra PNG mancante.',422,p_request_key,jsonb_build_object('client_ref',v_ref)); end if;
    v_snap:=jsonb_build_object('name',coalesce(nullif(btrim(v_spec->>'nome'),''),v_tpl.nome),'vita',coalesce(v_tpl.vita_max,10),'vita_max',coalesce(v_tpl.vita_max,10),
      'chakra',coalesce(v_tpl.chakra_max,0),'chakra_max',coalesce(v_tpl.chakra_max,0),'taijutsu',v_tpl.taijutsu,'ninjutsu',v_tpl.ninjutsu,'genjutsu',v_tpl.genjutsu,
      'forza',v_tpl.forza,'velocita',v_tpl.velocita,'mente',v_tpl.mente,'resistenza',v_tpl.resistenza,'fuuinjutsu',v_tpl.fuuinjutsu,'slancio',0,'abilities',coalesce(v_tpl.abilita,'[]'::jsonb));
    insert into public.combat_v2_png_instances(session_id,template_id,client_ref,nome,snapshot)
    values(v_enc,v_tpl.id,v_ref::uuid,coalesce(nullif(btrim(v_spec->>'nome'),''),v_tpl.nome),v_snap) returning id into v_png;
    v_pos := case when v_spec->>'pos' is null then 0
                  when (v_spec->>'pos') ~ '^[0-9]{1,2}$' then (v_spec->>'pos')::int
                  else -1 end;
    if v_pos<0 or v_pos>60 or (v_pos % 5)<>0 then perform public.combat_v2_fail('intento_non_valido','Posizione iniziale del PNG non valida: 0-60 metri a passi di 5.',422,p_request_key,'{}'); end if;
    insert into public.combat_v2_actors(session_id,actor_kind,png_instance_id,controller_user,team_key,position_m,initiative_snapshot,mechanics_snapshot)
    values(v_enc,'png',v_png,v_uid,v_team,v_pos,v_tpl.velocita,v_snap);
  end loop;
  select case when v_m.master_user is null then 'neutra' else 'umana' end into v_mode;
  insert into public.combat_v2_rounds(session_id,round_no,evaluation_mode) values(v_enc,1,v_mode) returning id into v_round;
  update public.master_v2_sessions set stato='in_corso' where id=p_master_session;
  if v_m.tipo='quest' and mission_internal.runtime_enabled()
     and exists(select 1 from public.mission_run_state where master_session_id=p_master_session and run_phase='preparazione') then
    perform mission_internal.sync_lifecycle(p_master_session,p_request_key,v_m.control_version,
      (select control_version from public.mission_run_state where master_session_id=p_master_session),'in_corso');
  end if;
  IF EXISTS(SELECT 1 FROM combat_panel_private.master_panel_sessions registered74 WHERE registered74.master_session_id=p_master_session)THEN
   perform clan_innata_narrative_private.materialize_v1(v_enc);
  END IF;
  v_result:=public.combat_v2_envelope(p_request_key,jsonb_build_object('encounter_id',v_enc,'round_id',v_round,'evaluation_mode',v_mode));
  return public.combat_v2_event_complete(v_event_id,v_result);
end $function$
;
COMMIT;
