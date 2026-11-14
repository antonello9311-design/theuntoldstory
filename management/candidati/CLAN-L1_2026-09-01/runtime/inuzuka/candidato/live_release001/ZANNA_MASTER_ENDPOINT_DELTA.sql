BEGIN;
SET LOCAL lock_timeout='3s';
DO $pre$ BEGIN
IF md5(pg_get_functiondef('public.combat_v2_action_declare(uuid,uuid,jsonb,text,uuid)'::regprocedure)) IS DISTINCT FROM '302b549b1407b329cda757c4b6a4c5bb' THEN RAISE EXCEPTION 'inuzuka_zanna_pre_0'; END IF;
IF md5(pg_get_functiondef('combat_v2_multitarget_internal.sync_declaration()'::regprocedure)) IS DISTINCT FROM '0aab830c90d7869438a8453790019555' THEN RAISE EXCEPTION 'inuzuka_zanna_pre_1'; END IF;
IF md5(pg_get_functiondef('combat_panel_private.resolve_master_movement(uuid,uuid)'::regprocedure)) IS DISTINCT FROM '9ffbd6e3a8cb9b18033c1411518d5b65' THEN RAISE EXCEPTION 'inuzuka_zanna_pre_2'; END IF;
IF md5(pg_get_functiondef('clan_inuzuka_private.zanna_contact_valid(uuid)'::regprocedure)) IS DISTINCT FROM '2cbb354a0a78d60e419306f1f4cb8285' THEN RAISE EXCEPTION 'inuzuka_zanna_pre_3'; END IF;
IF md5(pg_get_functiondef('combat_panel_private.master_actor_offers(uuid,bigint,jsonb,jsonb)'::regprocedure)) IS DISTINCT FROM '08734fa08f3829298493124b946c2dd4' THEN RAISE EXCEPTION 'inuzuka_zanna_pre_4'; END IF;
IF md5(pg_get_functiondef('combat_panel_private.bind_master_movement(uuid)'::regprocedure)) IS DISTINCT FROM 'b6855596870b69587aaeb3df029be7a9' THEN RAISE EXCEPTION 'inuzuka_zanna_pre_5'; END IF;
IF to_regprocedure('clan_inuzuka_private.zanna_master_endpoint_v1(uuid,uuid,uuid,uuid,text)') IS NOT NULL THEN RAISE EXCEPTION 'inuzuka_zanna_helper_exists'; END IF;
END $pre$;
CREATE OR REPLACE FUNCTION clan_inuzuka_private.zanna_master_endpoint_v1(p_round uuid, p_actor uuid, p_target uuid, p_request uuid, p_state text)
 RETURNS boolean
 LANGUAGE sql
 STABLE SECURITY DEFINER
 SET search_path TO ''
AS $function$
 SELECT EXISTS (
   SELECT 1 FROM combat_panel_private.master_movement_plans p
   JOIN combat_spatial.movement_capabilities mc ON mc.capability_id=p.capability_id
      AND mc.actor_id=p.actor_id AND mc.instance_id=p.instance_id
   JOIN public.combat_v2_actors a ON a.id=p.actor_id AND a.controller_version=p.controller_version
   WHERE p.request_key=p_request AND p.round_id=p_round AND p.actor_id=p_actor AND p.state=p_state
      AND p_state IN ('prepared','declared') AND p.principal_user=exam_regia_private.current_principal()
      AND split_part(mc.choice_key,':',1)='melee-endpoint/1'
      AND split_part(mc.choice_key,':',2)=p_target::text
      AND split_part(mc.choice_key,':',6)=md5('master-taijutsu-entry:'||p_round||':'||p_actor)
      AND combat_panel_private.movement_attack_target_valid(p_actor,p_target,mc.capability_id,2)
 );
$function$
;
REVOKE ALL ON FUNCTION clan_inuzuka_private.zanna_master_endpoint_v1(uuid,uuid,uuid,uuid,text) FROM PUBLIC, anon, authenticated, service_role;
CREATE OR REPLACE FUNCTION public.combat_v2_action_declare(p_round uuid, p_actor uuid, p_intent jsonb, p_text text, p_request_key uuid)
 RETURNS jsonb
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO ''
AS $function$
declare v_uid uuid:=exam_regia_private.current_principal(); v_service boolean:=false; v_service_actor uuid; v_r public.combat_v2_rounds%rowtype; v_a public.combat_v2_actors%rowtype; v_t public.combat_v2_actors%rowtype;
  fireball clan_uchiha_private.fireball_preparations%ROWTYPE; clone_meta jsonb; escape_meta jsonb; aburame_meta jsonb;  multiplication_aim_valid boolean; multiplication_meta jsonb; v_i jsonb; v_kind text; v_target uuid; v_source text; v_ability uuid; v_meta jsonb; v_cost int:=0; v_base int:=10;
  v_nara_native boolean := false;
  v_nara_public_enabled boolean;
  v_nara_public_activated_at timestamptz;
  v_event jsonb; v_event_id uuid; v_id uuid; v_result jsonb; v_resolution jsonb; v_phase text; v_resolution_key uuid; v_max_range int;
begin
  if v_uid is null then delete from mission_exchange_combat_owner.service_action_permits p where p.request_key=p_request_key and p.round_id=p_round and p.actor_id=p_actor and p.intent_sha256=encode(extensions.digest(convert_to(p_intent::text,'UTF8'),'sha256'),'hex') returning true,p.persona_authority_id into v_service,v_service_actor;if not coalesce(v_service,false)then perform public.combat_v2_fail('autenticazione_richiesta','Autenticazione richiesta.',401,p_request_key,'{}');end if;end if;
  perform public.combat_v2_lock_round(p_round);
  perform exam_regia_private.assert_actor_dispatch(p_round,p_actor,p_request_key);
  select * into v_r from public.combat_v2_rounds where id=p_round for update;
  select * into v_a from public.combat_v2_actors where id=p_actor for update;
  if v_a.companion_id is not null then perform public.combat_v2_fail('compagno_senza_turno','Il compagno non dichiara azioni autonome.',409,p_request_key,'{}'); end if;
  perform combat_consumer_private.assert_dispatch(p_round,p_request_key,'declare');
  perform public.combat_v2_assert_operational(p_round,p_request_key,false);
  if exists(select 1 from mission_declaration_owner.gates g where g.round_id=p_round)then delete from mission_declaration_owner.submit_permits x where x.request_key=p_request_key and x.round_id=p_round and x.actor_id=p_actor;if not found then perform public.combat_v2_fail('porta_dichiarazione_richiesta','Usare la porta missione.',409,p_request_key,'{}');end if;end if;
  if v_r.id is null or v_a.id is null or v_a.session_id<>v_r.session_id then perform public.combat_v2_fail('sessione_inesistente','Round o attore inesistente.',404,p_request_key,'{}'); end if;
  if v_r.phase<>'raccolta_azioni' then perform public.combat_v2_fail('fase_non_valida','Il round non raccoglie azioni.',409,p_request_key,'{}'); end if;
  if not combat_panel_private.human_duel_turn_allowed(p_round,p_actor) then perform public.combat_v2_fail('azione_non_disponibile','In questo scambio il personaggio è in difesa.',409,p_request_key,'{}'); end if;
  if not v_service and exam_regia_private.actor_principal(v_a.id,v_a.controller_user)<>v_uid then perform public.combat_v2_fail('attore_non_controllato','Non controlli questo attore.',403,p_request_key,'{}'); end if;
  if v_a.state<>'attivo' then perform public.combat_v2_fail('azione_non_disponibile','Attore non attivo.',409,p_request_key,'{}'); end if;
  v_i:=public.combat_v2_sanitize_intent(p_intent,false); v_kind:=v_i->>'kind';
  fireball:=clan_uchiha_private.fireball_prepared(p_round,p_actor,p_request_key,v_i);
  perform clan_marionettisti_private.assert_jutsu_source(p_actor,v_i->>'ability_source',(v_i->>'ability_id')::uuid);
  if v_kind='attacco' then
    v_target:=(v_i->>'target_actor')::uuid;
    select * into v_t from public.combat_v2_actors t
      where t.id=v_target and t.session_id=v_a.session_id and t.state='attivo' and (t.team_key<>v_a.team_key OR fireball.profile->>'mode'='esplosiva');
    if v_t.id is null then
      perform public.combat_v2_fail('bersaglio_non_valido','Bersaglio non valido.',422,p_request_key,'{}'); end if;
    v_source:=coalesce(v_i->>'ability_source','mano');
    if v_source='mano' then
      if v_i ? 'ability_id' then perform public.combat_v2_fail('intento_non_valido','Il colpo a mano non usa ability_id.',422,p_request_key,'{}'); end if;
      v_meta:=jsonb_build_object('source','mano','name','Colpo','kind','fisico','chakra_cost',0,'damage_base',10,'element',null);
    elsif v_source in ('clan','jutsu') then
      v_ability:=(v_i->>'ability_id')::uuid;
      IF v_source='clan' AND v_ability='db51e5ae-8b90-4c3a-a51d-962eb9e19b38'::uuid THEN
        IF combat_panel_private.nara_staff_scope_v1(p_actor) THEN
          v_nara_native := true;
        ELSE
          -- The common mutation already holds the native round and actor locks.
          -- Hold this lock through declaration insertion; recovery takes the same row for update.
          SELECT gate.public_enabled,gate.public_activated_at
          INTO STRICT v_nara_public_enabled,v_nara_public_activated_at
          FROM combat_panel_private.nara_launch_gate_v1 gate
          WHERE gate.singleton FOR SHARE;
          IF v_nara_public_activated_at IS NOT NULL THEN
            IF NOT v_nara_public_enabled OR NOT combat_panel_private.nara_persistent_scope_v1(p_actor) THEN
              PERFORM public.combat_v2_fail('opzione_non_offerta','Tecnica non offerta dal server.',422,p_request_key,'{}');
            END IF;
            v_nara_native := true;
          ELSE
            -- Preserve the original Staff-profile route and ordinary legacy behavior before first activation.
            v_nara_native := combat_panel_private.nara_routes_possession_v1(p_actor);
          END IF;
        END IF;
      END IF;
      IF v_source='clan' AND v_ability='001f907c-8f32-4758-8a16-ad1730e72c59'::uuid THEN
        v_meta:=clan_sabaku_private.flow_declaration_meta(p_round,p_actor,p_request_key,v_i);
      ELSIF v_source='clan' AND v_ability='db51e5ae-8b90-4c3a-a51d-962eb9e19b38'::uuid
        AND v_nara_native THEN
         IF v_i ? 'target_actor_ids' AND jsonb_array_length(v_i->'target_actor_ids')<>1 THEN
           RAISE EXCEPTION 'nara_single_target_required' USING ERRCODE='22023';
         END IF;
         v_meta:=combat_panel_private.nara_offer_meta_v1(v_a.id,false,v_t.id);
      ELSIF v_source='clan' AND combat_v2_elemental_internal.suiton_profile(p_actor,v_ability) IS NOT NULL THEN
        v_meta:=combat_v2_elemental_internal.suiton_declaration_meta(p_round,p_actor,p_request_key,v_i);
        IF v_meta IS NULL THEN RAISE EXCEPTION 'suiton_preparation_required';END IF;
      ELSIF v_source='clan' AND combat_v2_elemental_internal.other_profile(p_actor,v_ability) IS NOT NULL THEN
        v_meta:=combat_v2_elemental_internal.other_declaration_meta(p_round,p_actor,p_request_key,v_i);
        IF v_meta IS NULL THEN RAISE EXCEPTION 'other_preparation_required';END IF;
      ELSE v_meta:=combat_v2_multitarget_internal.enrich_ability_v1(public.combat_v2_actor_ability(p_actor,v_source,v_ability,false)); END IF;
      if v_source='clan' and v_ability='e361f7c3-f90b-47ec-bfee-ccbda21257d9'::uuid and v_meta is not null then
        perform clan_marionettisti_private.ensure_initial_link(p_actor);
        perform combat_panel_private.multiplication_companion_attack_source(p_round,p_actor,v_target,p_request_key,null);
        v_meta:=v_meta||jsonb_build_object('kind','fisico','chakra_cost',5,'damage_base',10,'usage','principale','consumption_type','ad_utilizzo','defensive',false,'di_scena',false,'diversivo',false,'marionetta_profile_version','marionetta-offense/1');
      end if;
      if v_meta is null then perform public.combat_v2_fail('opzione_non_offerta','Tecnica non offerta dal server.',422,p_request_key,'{}'); end if;
      -- [MISSION-GUARD-003] Le famiglie speciali non diventano attacchi generici.
      if coalesce(v_meta->>'usage','') not in ('principale','rapida')
         or coalesce((v_meta->>'defensive')::boolean,false)
         or coalesce((v_meta->>'di_scena')::boolean,false)
         or (v_source='jutsu' and v_ability='c6e31b7b-38fe-4b4f-b3c7-05f3e922d193'::uuid)
         or coalesce((v_meta->>'diversivo')::boolean,false)
         or coalesce(v_meta->>'consumption_type','ad_utilizzo')='passiva' then
        perform public.combat_v2_fail('profilo_runtime_non_disponibile','Questa tecnica richiede il proprio resolver.',422,p_request_key,'{}');
      end if;
      IF fireball.actor_id IS NOT NULL THEN v_meta:=v_meta||fireball.profile||jsonb_build_object('damage_base',fireball.profile->'damage_base');END IF;
      v_max_range:=CASE WHEN v_source='clan' AND v_ability='f5e9af24-70f1-49f6-a7ca-74f59256336e'::uuid THEN 5
        WHEN v_meta->>'hoki_needle_version'='hoki-needle/1' THEN 15
        WHEN v_meta->>'akimichi_partial_contract'='akimichi-partial/1' THEN 3
        WHEN v_meta ? 'nara_launch' THEN (v_meta->>'nara_range_m')::numeric
        WHEN v_meta->>'sabaku_flow_version'='sabaku-flow/2' THEN 15 ELSE public._fascia_metri(v_meta->>'range') END;
      multiplication_aim_valid:=combat_panel_private.multiplication_attack_aim_valid(p_round,p_actor,v_target,p_request_key,v_max_range);
      if fireball.actor_id IS NULL and not (v_source='clan' and v_ability='e361f7c3-f90b-47ec-bfee-ccbda21257d9'::uuid) and
        (case when v_source='clan' AND v_ability='9ac77d79-9894-5388-9753-70538ac5eaa3'::uuid
           AND combat_v2_taijutsu_internal.entry_prepared(p_round,p_actor,p_request_key,v_target) then false
          when v_source='clan' AND v_ability='b076a976-c75b-4b5a-8813-b0e8e2c3af03'::uuid
            AND clan_inuzuka_private.zanna_master_endpoint_v1(p_round,p_actor,v_target,p_request_key,'prepared') then false
          when v_meta->>'hoki_needle_version'='hoki-needle/1' then not clan_hoki_private.needle_target_valid(v_a.id,v_t.id)
          WHEN v_meta ? 'nara_launch' THEN false
          when multiplication_aim_valid is not null then not multiplication_aim_valid
          when v_meta->>'akimichi_partial_contract'='akimichi-partial/1'
          then not clan_akimichi_private.partial_target_valid(v_a.id,v_t.id)
          when v_source='clan' AND v_ability='031d5ecc-86ee-4d21-85f1-6b76fc57cef9'::uuid
           AND EXISTS(SELECT 1 FROM public.combat_v2_sessions s WHERE s.id=v_a.session_id AND s.source_kind='ordinary')
          then not combat_consumer_private.melee_eligible(v_a.session_id,v_a.id,v_t.id)
          when combat_panel_private.has_master_geometry(v_a.session_id)
          then not combat_panel_private.target_geometry_valid(v_a.id,v_t.id,v_max_range)
          else abs(v_a.position_m-v_t.position_m)>v_max_range end) then
        perform public.combat_v2_fail('fuori_portata','Bersaglio fuori portata.',422,p_request_key,'{}');
      end if;
    else perform public.combat_v2_fail('opzione_non_offerta','Fonte tecnica non offerta.',422,p_request_key,'{}'); end if;
    v_cost:=coalesce((v_meta->>'chakra_cost')::int,0); v_base:=coalesce((v_meta->>'damage_base')::int,0);
  elsif v_kind='movimento' then
    if combat_panel_private.has_master_geometry(v_a.session_id) then
      v_i:=combat_panel_private.master_movement_intent(p_round,p_actor,p_request_key,v_i);
    else
      if not (v_i ? 'move_m') or (v_i->>'move_m')::int not between -15 and 15 then perform public.combat_v2_fail('intento_non_valido','Spostamento non valido.',422,p_request_key,'{}'); end if;
    end if;
  end if;
  IF fireball.actor_id IS NOT NULL THEN
    v_meta:=coalesce(v_meta,'{}')||fireball.profile||jsonb_build_object('family','projectile_fireball','kind','ninjutsu','element','Fuoco','range','media','source','clan','id',fireball.profile->'catalog_technique_id');
    v_cost:=(fireball.profile->>'chakra_cost')::integer;v_base:=(fireball.profile->>'damage_base')::integer;
  END IF;
  multiplication_meta:=combat_panel_private.multiplication_declaration_meta(p_round,p_actor,p_request_key,v_i,v_meta);
  IF multiplication_meta IS NOT NULL THEN
    v_meta:=multiplication_meta; v_cost:=(v_meta->>'chakra_cost')::integer; v_base:=(v_meta->>'damage_base')::integer;
  END IF;
  escape_meta:=combat_panel_private.immobilization_escape_meta(p_round,p_actor,p_request_key,v_i);
  IF escape_meta IS NOT NULL THEN
    IF multiplication_meta IS NOT NULL THEN RAISE EXCEPTION 'immobilization_escape_action_conflict' USING ERRCODE='22023'; END IF;
    v_meta:=escape_meta; v_cost:=0; v_base:=0;
  END IF;
  IF combat_panel_private.nara_owner_choice_v1(p_actor)->'upkeep_due'='true'::jsonb THEN
    PERFORM public.combat_v2_fail('azione_non_disponibile','Mantieni o rilascia il Possesso prima di agire.',409,p_request_key,'{}');
  END IF;
  IF combat_panel_private.nara_controlled_v1(p_actor)
    AND v_kind IS DISTINCT FROM 'passa' AND escape_meta IS NULL THEN
    PERFORM public.combat_v2_fail('azione_non_disponibile','Il corpo è sotto controllo.',409,p_request_key,'{}');
  END IF;
  clone_meta:=clan_sabaku_private.clone_declaration_meta(p_round,p_actor,p_request_key,v_i);
  IF clone_meta IS NOT NULL THEN
    IF multiplication_meta IS NOT NULL OR escape_meta IS NOT NULL THEN RAISE EXCEPTION 'sabaku_clone_action_conflict' USING ERRCODE='22023'; END IF;
    v_meta:=clone_meta; v_cost:=5; v_base:=0;
  END IF;
  aburame_meta:=clan_aburame_private.action_meta(p_round,p_actor,p_request_key,v_i);
  IF aburame_meta IS NOT NULL THEN
    IF multiplication_meta IS NOT NULL OR escape_meta IS NOT NULL OR clone_meta IS NOT NULL THEN RAISE EXCEPTION 'aburame_action_conflict' USING ERRCODE='22023'; END IF;
    v_meta:=aburame_meta;v_cost:=0;v_base:=0;
  END IF;
  v_event:=public.combat_v2_event_begin(p_round,p_request_key,'combat_v2_action_declare',jsonb_build_object('actor',p_actor,'intent',v_i,'text',coalesce(p_text,'')),null);
  if (v_event->>'replay')::boolean then return v_event->'result'; end if; v_event_id:=(v_event->>'event_id')::uuid;
  insert into public.combat_v2_declarations(round_id,actor_id,kind,target_actor_id,sanitized_intent,declaration_text,controller_user_snapshot,controller_version_snapshot,request_key,cost_snapshot)
  values(p_round,p_actor,v_kind,v_target,v_i||case when v_meta is null then '{}'::jsonb else jsonb_build_object('server_ability',v_meta) end,
    coalesce(p_text,''),coalesce(v_uid,v_service_actor),v_a.controller_version,p_request_key,clan_hyuga_private.sedici_cost_snapshot(p_actor,jsonb_build_object('chakra',v_cost,'damage_base',v_base))) returning id into v_id;
  IF v_meta ? 'nara_launch' THEN
    PERFORM combat_panel_private.nara_freeze_segment_positions_v1(v_id);
  END IF;
  perform combat_panel_private.multiplication_bind_declaration(v_id);
  perform combat_panel_private.immobilization_bind_escape(v_id);
  perform clan_sabaku_private.clone_bind(v_id);
  perform combat_panel_private.multiplication_bind_attack_aims(v_id);
  perform combat_panel_private.bind_master_movement(v_id);
  PERFORM clan_sabaku_private.flow_bind_preparation(v_id);
  PERFORM clan_hyuga_private.juken_freeze(v_id);
  PERFORM clan_hyuga_private.sedici_freeze(v_id);
  PERFORM clan_uchiha_private.fireball_freeze(v_id); PERFORM clan_inuzuka_private.zanna_freeze(v_id);
  PERFORM combat_v2_elemental_internal.suiton_bind_source(v_id);
  PERFORM combat_v2_elemental_internal.other_bind_source(v_id);
  if v_kind='attacco' and v_source='clan' and v_ability='e361f7c3-f90b-47ec-bfee-ccbda21257d9'::uuid then
    perform clan_marionettisti_private.freeze_offensive_profile(v_id);
  end if;
  IF v_meta->>'hoki_needle_version'='hoki-needle/1' THEN PERFORM clan_hoki_private.needle_reserve(v_id); END IF;
  PERFORM clan_akimichi_private.bind_partial(v_id);
  PERFORM clan_hyuga_private.rotation_attack_power_freeze(v_id);
  v_phase:=combat_consumer_private.advance_after_main_actions(p_round);
  if v_phase='risoluzione' and not combat_consumer_private.owns_round(p_round)
     and (v_r.evaluation_mode='neutra' or not exists(
       select 1 from public.combat_v2_attack_targets t join public.combat_v2_declarations d on d.id=t.attack_declaration_id
       where t.round_id=p_round and t.state not in ('annullata','superflua') and d.state not in ('annullata','superflua')))
     and (v_uid is not null or public.combat_v2_is_service()) then
    v_resolution_key:=md5(p_request_key::text||'|no-attack-resolve')::uuid;
    if v_uid is not null and v_a.character_id is not null then
      insert into combat_consumer_private.dispatch_authorizations(request_key,round_id,principal_character_id,transaction_id,operation,state)
      values(v_resolution_key,p_round,v_a.character_id,txid_current(),'resolve','prepared');
    end if;
    v_resolution:=public.combat_v2_round_resolve(p_round,v_resolution_key);
    v_phase:='risolto';
  end if;
  v_result:=public.combat_v2_envelope(p_request_key,jsonb_build_object('declaration_id',v_id,'target_ids',(select coalesce(jsonb_agg(t.target_actor_id order by t.ordinal),'[]'::jsonb)from public.combat_v2_attack_targets t where t.attack_declaration_id=v_id),'phase',v_phase,'auto_resolution',v_resolution));
  return public.combat_v2_event_complete(v_event_id,v_result);
end $function$
;
CREATE OR REPLACE FUNCTION combat_v2_multitarget_internal.sync_declaration()
 RETURNS trigger
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO ''
AS $function$
declare prepared_endpoint combat_panel_private.master_movement_plans%ROWTYPE; endpoint_cap combat_spatial.movement_capabilities%ROWTYPE; manual_endpoint_valid boolean; multiplication_aim_valid boolean; ids uuid[]:='{}';j jsonb;t uuid;n int:=0;a public.combat_v2_actors%rowtype;
        fireball clan_uchiha_private.fireball_preparations%ROWTYPE;target public.combat_v2_actors%rowtype;meta jsonb;mode text;at_id uuid;attack_id uuid;attack public.combat_v2_declarations%rowtype;
 secondary_allowed boolean:=false;secondary_proof jsonb;secondary_session public.combat_v2_sessions;
 secondary_location public.locations;secondary_master public.master_v2_sessions;
 secondary_gate combat_panel_private.multiplication_tactics_release_gate;
begin
 if new.kind='attacco' then
  select*into strict a from public.combat_v2_actors where id=new.actor_id;
  meta:=new.sanitized_intent->'server_ability';
  fireball:=clan_uchiha_private.fireball_prepared(new.round_id,new.actor_id,new.request_key,new.sanitized_intent-'server_ability');
  if new.sanitized_intent?'target_actor_ids' then
   if jsonb_typeof(new.sanitized_intent->'target_actor_ids')<>'array' then raise exception 'targeting_cardinality_invalid';end if;
   for j in select value from jsonb_array_elements(new.sanitized_intent->'target_actor_ids') loop
    begin t:=(j#>>'{}')::uuid;exception when others then raise exception 'targeting_target_not_eligible';end;
    ids:=array_append(ids,t);
   end loop;
  else ids:=array[new.target_actor_id];end if;
  if cardinality(ids)<1 OR (cardinality(ids)>3 AND fireball.profile->>'mode' IS DISTINCT FROM 'esplosiva') then raise exception 'targeting_cardinality_invalid';end if;
  if cardinality(ids)<>(select count(distinct z)from unnest(ids)z)then raise exception 'targeting_duplicate_target';end if;
  if new.target_actor_id is distinct from ids[1]then raise exception 'targeting_primary_not_ordinal_1';end if;
  if fireball.actor_id IS NULL AND not combat_v2_multitarget_internal.attack_profile_ok(meta,cardinality(ids))then raise exception 'targeting_profile_missing';end if;
  foreach t in array ids loop
   select*into target from public.combat_v2_actors where id=t and session_id=a.session_id and state='attivo' for key share;
   if target.id is null or (target.team_key=a.team_key AND fireball.profile->>'mode' IS DISTINCT FROM 'esplosiva') then raise exception 'targeting_target_not_eligible';end if;
   IF fireball.actor_id IS NULL THEN
   manual_endpoint_valid:=false;
   IF coalesce(new.sanitized_intent->>'ability_source','mano')='mano' THEN
    SELECT * INTO prepared_endpoint FROM combat_panel_private.master_movement_plans WHERE request_key=new.request_key;
    IF prepared_endpoint.request_key IS NOT NULL THEN
     SELECT * INTO STRICT endpoint_cap FROM combat_spatial.movement_capabilities WHERE capability_id=prepared_endpoint.capability_id;
     IF split_part(endpoint_cap.choice_key,':',1)='melee-endpoint/1' THEN
      IF (prepared_endpoint.actor_id,prepared_endpoint.round_id,prepared_endpoint.principal_user,
          prepared_endpoint.controller_version,prepared_endpoint.state)
        IS DISTINCT FROM (a.id,new.round_id,exam_regia_private.current_principal(),a.controller_version,'prepared'::text)
        OR cardinality(ids)<>1 OR split_part(endpoint_cap.choice_key,':',2) IS DISTINCT FROM t::text
        OR split_part(endpoint_cap.choice_key,':',6) IS DISTINCT FROM md5('master-mano:'||new.round_id||':'||a.id)
        OR EXISTS(SELECT 1 FROM combat_panel_private.multiplication_formations WHERE actor_id=t AND state='active')
        OR NOT combat_panel_private.movement_attack_target_valid(a.id,t,endpoint_cap.capability_id,
           combat_panel_private.manual_contact_center_range(a.id,t)) THEN
       RAISE EXCEPTION 'panel_manual_endpoint_stale' USING ERRCODE='40001'; END IF;
      manual_endpoint_valid:=true;
     END IF;
    END IF;
   END IF;
   multiplication_aim_valid:=combat_panel_private.multiplication_attack_aim_valid(new.round_id,a.id,t,new.request_key,
     case when new.sanitized_intent->>'ability_source'='clan' and new.sanitized_intent->>'ability_id'='e361f7c3-f90b-47ec-bfee-ccbda21257d9' then 3 when coalesce(new.sanitized_intent->>'ability_source','mano')='mano' then combat_panel_private.manual_contact_center_range(a.id,t) else (CASE WHEN meta->>'sabaku_flow_version'='sabaku-flow/2' THEN 15 ELSE public._fascia_metri(meta->>'range') END) end);
   IF manual_endpoint_valid THEN multiplication_aim_valid:=true; END IF;
   IF new.sanitized_intent->>'ability_source'='clan' AND new.sanitized_intent->>'ability_id'='b076a976-c75b-4b5a-8813-b0e8e2c3af03' AND cardinality(ids)=1
     AND clan_inuzuka_private.zanna_master_endpoint_v1(new.round_id,a.id,t,new.request_key,'prepared')
   THEN multiplication_aim_valid:=true; END IF;
   IF new.sanitized_intent->>'ability_source'='clan'
    AND new.sanitized_intent->>'ability_id'='9ac77d79-9894-5388-9753-70538ac5eaa3'
    AND combat_v2_taijutsu_internal.entry_prepared(new.round_id,a.id,new.request_key,t) THEN
    multiplication_aim_valid:=true;
   END IF;
   if multiplication_aim_valid is not null then
    if new.sanitized_intent->>'ability_source'='clan'
      and new.sanitized_intent->>'ability_id'='e361f7c3-f90b-47ec-bfee-ccbda21257d9' then
      if cardinality(ids)<>1 then raise exception 'marionetta_single_target_required' using errcode='22023';end if;
       perform combat_panel_private.multiplication_companion_attack_source(new.round_id,a.id,t,new.request_key,null);end if;
    if not multiplication_aim_valid then raise exception 'fuori_portata';end if;
   elsif combat_panel_private.has_master_geometry(a.session_id)
    and new.sanitized_intent->>'ability_source'='clan'
    and new.sanitized_intent->>'ability_id'='e361f7c3-f90b-47ec-bfee-ccbda21257d9' then
    if cardinality(ids)<>1 or not clan_marionettisti_private.target_geometry_valid(new.round_id,a.id,t,new.sanitized_intent) then
      raise exception 'fuori_portata';end if;
   elsif combat_panel_private.has_master_geometry(a.session_id) then
    if not combat_panel_private.target_geometry_valid(a.id,t,case when coalesce(new.sanitized_intent->>'ability_source','mano')='mano' then combat_panel_private.manual_contact_center_range(a.id,t) else (CASE WHEN meta->>'sabaku_flow_version'='sabaku-flow/2' THEN 15 ELSE public._fascia_metri(meta->>'range') END) end) then raise exception 'fuori_portata';end if;
   elsif clan_marionettisti_private.is_dedicated_scene(a.session_id) then
    if not clan_marionettisti_private.target_geometry_valid(new.round_id,a.id,t,new.sanitized_intent) then raise exception 'fuori_portata';end if;
   elsif abs(a.position_m-target.position_m)>coalesce((CASE WHEN meta->>'sabaku_flow_version'='sabaku-flow/2' THEN 15 ELSE public._fascia_metri(meta->>'range') END),-1)then raise exception 'fuori_portata';end if;
   END IF; -- Fireball geometry/membership already bound by server preparation.
   n:=n+1;
   insert into public.combat_v2_attack_targets(round_id,attack_declaration_id,ordinal,target_actor_id,target_controller_version,target_position_m)
   values(new.round_id,new.id,n,t,target.controller_version,target.position_m);
  end loop;
 elsif new.kind in('difesa','nessuna')then
  select*into strict a from public.combat_v2_actors where id=new.actor_id;
  select*into strict attack from public.combat_v2_declarations where id=new.parent_attack_id and round_id=new.round_id and kind='attacco';
  -- The physical key is parent+defender. The existing release gate still limits
  -- the additional defender behavior; every producer, including native none,
  -- reaches this trigger before any coverage/geometry writes below.
  PERFORM public.combat_v2_lock_round(new.round_id);
  -- Native API transactions use READ COMMITTED (live/preflight captured).
  -- Fail closed for an unsupported caller isolation instead of a stale guard.
  IF current_setting('transaction_isolation') IS DISTINCT FROM 'read committed'
  THEN RAISE EXCEPTION 'secondary_defense_native_isolation_required' USING ERRCODE='55000';END IF;
  IF EXISTS(SELECT 1 FROM public.combat_v2_declarations prior
    WHERE prior.parent_attack_id=new.parent_attack_id AND prior.kind IN('difesa','nessuna')
      AND prior.id<>new.id AND prior.actor_id<>new.actor_id) THEN
   SELECT * INTO secondary_gate FROM combat_panel_private.multiplication_tactics_release_gate g
    WHERE g.singleton AND g.version>=1 AND g.revision_reference='combat-multiplication-tactics/1' FOR SHARE;
   SELECT * INTO STRICT secondary_session FROM public.combat_v2_sessions WHERE id=a.session_id;
   SELECT * INTO STRICT secondary_location FROM public.locations WHERE id=secondary_session.location_id;
   IF secondary_gate.singleton IS TRUE AND secondary_session.state='in_corso'
    AND secondary_session.closed_at IS NULL AND a.companion_id IS NULL
    AND NOT EXISTS(SELECT 1 FROM exam_regia_private.bindings eb WHERE eb.combat_session_id=secondary_session.id) THEN
    IF secondary_gate.staff_enabled AND secondary_location.is_active AND secondary_location.is_test
     AND secondary_session.location_id='0b85f354-9cdb-47e1-baf9-3d266bb7e06b'::uuid
     AND NOT public.combat_v2_values_written(secondary_session.id) THEN
     secondary_proof:=clan_innata_narrative_private.fenice_staff_proof_v1(attack.actor_id);
     secondary_allowed:=secondary_proof IS NOT NULL
      AND secondary_proof->>'schema_version'='staff-fenice-dependency/1'
      AND secondary_proof->>'session_id'=secondary_session.id::text
      AND secondary_proof->>'actor_id'=attack.actor_id::text
      AND secondary_proof->>'sha256'=public.combat_v2_sha256(secondary_proof-'sha256')
      AND EXISTS(SELECT 1 FROM public.combat_v2_actors source_actor
       WHERE source_actor.id=attack.actor_id AND source_actor.session_id=secondary_session.id
        AND source_actor.mechanics_snapshot->'fenice_staff_dependency'=secondary_proof)
      AND attack.sanitized_intent->>'ability_id'='6cc40917-1719-4759-9ba8-3064b806c24e'
      AND attack.sanitized_intent->'server_ability'=secondary_proof->'ability'
      AND (SELECT count(*) FROM public.combat_v2_attack_targets mt WHERE mt.attack_declaration_id=attack.id)>1;
    ELSIF secondary_location.is_active AND NOT secondary_location.is_test AND NOT secondary_location.is_exam_room THEN
     -- Existing ordinary/master/generic Tactics release modes only. These flags
     -- are all false in this Staff release. Producer Auth/permits stay unchanged.
     IF secondary_session.master_session_id IS NULL THEN
      secondary_allowed:=secondary_gate.ordinary_enabled AND a.actor_kind='pg'
       AND combat_panel_private.owner_turn_context(a.id)->>'activity_kind'='ordinary_v2';
     ELSE
      SELECT * INTO secondary_master FROM public.master_v2_sessions WHERE id=secondary_session.master_session_id
       AND location_id=secondary_session.location_id AND closed_at IS NULL;
      IF secondary_master.owner_kind='human' AND secondary_master.master_user IS NOT NULL THEN
       secondary_allowed:=secondary_gate.master_enabled
        AND combat_panel_private.owner_turn_context(a.id)->>'activity_kind'='master_v2';
      ELSIF secondary_master.owner_kind='ai_service' AND secondary_master.master_user IS NULL THEN
       secondary_allowed:=((a.actor_kind='pg' AND secondary_gate.master_enabled)
        OR(a.actor_kind='png' AND secondary_gate.generic_enabled AND secondary_session.source_kind='master' AND secondary_session.lesiva IS FALSE))
        AND combat_panel_private.owner_turn_context(a.id)->>'activity_kind'='master_v2'
        AND EXISTS(SELECT 1 FROM mission_public_owner.session_admissions_v1 adm
         JOIN mission_public_owner.publications_v2 pub ON pub.request_key=adm.publication_request
          AND pub.mission_id=adm.mission_id AND pub.source_mission_id=adm.mission_id
          AND pub.config_version=adm.capability_version AND pub.target='public'
          AND pub.visibility='open' AND pub.state='open'
         WHERE adm.master_session_id=secondary_master.id AND adm.location_id=secondary_session.location_id
          AND adm.mode='ai' AND adm.publication_request IS NOT NULL
          AND mission_public_owner.role_session_allowed_v1(secondary_master.id)
          AND mission_public_owner.c1266_regia_public_scope_v1(adm.mission_id,'ai',adm.publication_request,pub.release_revision_sha256));
      END IF;
     END IF;
    END IF;
   END IF;
   IF secondary_allowed IS DISTINCT FROM true THEN
    RAISE EXCEPTION 'secondary_defense_scope_not_released' USING ERRCODE='42501';
   END IF;
  END IF;
  meta:=new.sanitized_intent->'server_ability';
  if new.sanitized_intent?'attack_target_ids'then
   if jsonb_typeof(new.sanitized_intent->'attack_target_ids')<>'array'then raise exception 'targeting_cardinality_invalid';end if;
   for j in select value from jsonb_array_elements(new.sanitized_intent->'attack_target_ids')loop
    begin at_id:=(j#>>'{}')::uuid;exception when others then raise exception 'defense_targeting_not_eligible';end;
    ids:=array_append(ids,at_id);
   end loop;
  else
   select array_agg(x.id order by x.ordinal)into ids from public.combat_v2_attack_targets x
    where x.attack_declaration_id=new.parent_attack_id and x.target_actor_id=new.target_actor_id;
  end if;
  if ids is null or cardinality(ids)=0 or cardinality(ids)<>(select count(distinct z)from unnest(ids)z)then raise exception 'defense_targeting_not_eligible';end if;
  mode:=case
    when new.kind='nessuna'
      or coalesce(new.sanitized_intent->>'reaction','nessuna')in('schivata','parata','nessuna')
      then 'self'
    when coalesce(new.sanitized_intent->>'reaction','')='tecnica'
      and nullif(meta#>>'{targeting,mode}','') is null
      then 'self'
    else meta#>>'{targeting,mode}'
  end;
  if mode is null or mode not in('self','intercept','multi_protect')then raise exception 'defense_targeting_not_eligible';end if;
  if mode='self'and cardinality(ids)<>1 then raise exception 'defense_targeting_not_eligible';end if;
  if mode<>'self'and not combat_v2_multitarget_internal.defense_profile_ok(meta,mode,cardinality(ids))then raise exception 'defense_targeting_not_eligible';end if;
  foreach at_id in array ids loop
   IF combat_panel_private.multiplication_no_defense(at_id) THEN
    RAISE EXCEPTION 'defense_targeting_not_required' USING ERRCODE='22023'; END IF;
   select x.target_actor_id,d.id into t,attack_id from public.combat_v2_attack_targets x join public.combat_v2_declarations d on d.id=x.attack_declaration_id
    where x.id=at_id and x.round_id=new.round_id and x.state='attesa_difesa' for update of x;
   if t is null then raise exception 'targeting_child_already_covered';end if;
   if mode in('self','intercept')and attack_id is distinct from new.parent_attack_id then raise exception 'defense_targeting_cross_parent';end if;
   select*into target from public.combat_v2_actors where id=t for key share;
   if mode='self'and t<>new.actor_id and not clan_marionettisti_private.defends_body(new.actor_id,t,coalesce(new.sanitized_intent->>'reaction','nessuna')) then raise exception 'defense_targeting_not_eligible';end if;
   if mode<>'self'and(target.team_key<>a.team_key or
     case when combat_panel_private.has_master_geometry(a.session_id)
       then combat_panel_private.actor_distance(a.id,target.id)>2
       else abs(a.position_m-target.position_m)>2 end)then raise exception 'defense_targeting_not_eligible';end if;
   insert into public.combat_v2_defense_coverages(round_id,defense_declaration_id,attack_target_id,protected_actor_id,mode,defender_controller_version,protected_position_m)
   values(new.round_id,new.id,at_id,t,mode,a.controller_version,target.position_m);
   perform combat_panel_private.capture_coverage_geometry(new.id,at_id);
   update public.combat_v2_attack_targets set state='coperta'where id=at_id;
  end loop;
 end if;
 return new;
end
$function$
;
CREATE OR REPLACE FUNCTION combat_panel_private.resolve_master_movement(p_declaration uuid, p_root uuid)
 RETURNS jsonb
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO ''
AS $function$
DECLARE plan combat_panel_private.master_movement_plans%ROWTYPE; d public.combat_v2_declarations%ROWTYPE;
 a public.combat_v2_actors%ROWTYPE; b combat_spatial.actor_states%ROWTYPE; after_body combat_spatial.actor_states%ROWTYPE;
 cap combat_spatial.movement_capabilities%ROWTYPE;
 original_cap combat_spatial.movement_capabilities%ROWTYPE; manual_endpoint boolean; endpoint_parts text[]; vector_x numeric; vector_y numeric; remaining numeric; metres numeric; actual numeric:=0; key text; item jsonb; movement_result jsonb; spatial jsonb; reason text;
BEGIN
 SELECT * INTO STRICT plan FROM combat_panel_private.master_movement_plans WHERE declaration_id=p_declaration FOR UPDATE;
 IF plan.state='resolved' THEN RETURN plan.result; END IF;
 SELECT * INTO STRICT d FROM public.combat_v2_declarations WHERE id=plan.declaration_id AND round_id=plan.round_id FOR UPDATE;
 SELECT * INTO STRICT a FROM public.combat_v2_actors WHERE id=plan.actor_id FOR UPDATE;
 IF d.actor_id<>a.id OR NOT (
      (d.kind='movimento' AND d.sanitized_intent->>'movement_contract'='combat-panel-movement/1')
      OR (d.kind='attacco' AND (coalesce(d.sanitized_intent->>'ability_source','mano')='mano' OR (d.sanitized_intent->>'ability_source'='clan' AND d.sanitized_intent->>'ability_id' IN ('9ac77d79-9894-5388-9753-70538ac5eaa3','b076a976-c75b-4b5a-8813-b0e8e2c3af03')))
        AND d.sanitized_intent->>'movement_contract'='combat-panel-movement-attack/1'))
   OR NOT combat_panel_private.controller_version_valid(a.id,plan.controller_version,plan.principal_user) OR d.state<>'congelata'
   OR NOT EXISTS(SELECT 1 FROM public.combat_v2_rounds WHERE id=plan.round_id AND session_id=a.session_id AND phase='risoluzione') THEN
   RAISE EXCEPTION 'panel_movement_resolution_scope_invalid' USING ERRCODE='22023'; END IF;
 PERFORM 1 FROM combat_spatial.arena_instances WHERE instance_id=plan.instance_id AND encounter_id=a.session_id AND state='open' FOR UPDATE;
 IF NOT FOUND THEN RAISE EXCEPTION 'panel_master_geometry_required' USING ERRCODE='22023'; END IF;
 SELECT * INTO STRICT b FROM combat_spatial.actor_states WHERE instance_id=plan.instance_id AND actor_id=a.id FOR UPDATE;
 IF b.controller_principal_id IS DISTINCT FROM exam_regia_private.actor_principal(a.id,a.controller_user) THEN
   RAISE EXCEPTION 'panel_movement_controller_stale' USING ERRCODE='40001'; END IF;
 remaining:=(combat_panel_private.master_movement_budget(plan.round_id,a.id)->>'remaining_m')::numeric;
 SELECT * INTO STRICT original_cap FROM combat_spatial.movement_capabilities WHERE capability_id=plan.capability_id;
 manual_endpoint:=d.kind='attacco' AND (coalesce(d.sanitized_intent->>'ability_source','mano')='mano' OR (d.sanitized_intent->>'ability_source'='clan' AND d.sanitized_intent->>'ability_id' IN ('9ac77d79-9894-5388-9753-70538ac5eaa3','b076a976-c75b-4b5a-8813-b0e8e2c3af03')))
   AND split_part(original_cap.choice_key,':',1)='melee-endpoint/1';
 IF manual_endpoint THEN
  IF original_cap.actor_id<>a.id OR original_cap.instance_id<>plan.instance_id
    OR split_part(original_cap.choice_key,':',6) NOT IN (md5('master-mano:'||d.round_id||':'||a.id),md5('master-taijutsu-entry:'||d.round_id||':'||a.id))
    OR combat_spatial.distance_m(original_cap.start_x_m,original_cap.start_y_m,original_cap.end_x_m,original_cap.end_y_m) IS DISTINCT FROM plan.planned_m THEN
   RAISE EXCEPTION 'panel_manual_endpoint_plan_invalid' USING ERRCODE='40001'; END IF;
  vector_x:=original_cap.end_x_m-original_cap.start_x_m;vector_y:=original_cap.end_y_m-original_cap.start_y_m;
 END IF;
 metres:=least(plan.planned_m,remaining);
 IF NOT manual_endpoint AND abs(plan.dx)+abs(plan.dy)=2 THEN metres:=floor(metres/2)*2;END IF;
 reason:=combat_panel_private.movement_block_reason(a.id);
 IF reason IS NOT NULL THEN NULL;
 ELSIF b.state<>'active' THEN reason:='actor_inoperative';
 ELSIF metres<=0 THEN reason:='movement_budget_exhausted';
 ELSE
   -- Mantiene la direzione dichiarata, assesta il percorso dalla posizione
   -- effettiva nel proprio ordine di risoluzione, rispettando i blocchi attuali.
   key:='panel-resolve:'||d.id;
   IF manual_endpoint THEN
    endpoint_parts:=string_to_array(original_cap.choice_key,':');
    endpoint_parts[4]:=(SELECT map_version::text FROM combat_spatial.arena_instances WHERE instance_id=plan.instance_id);
    endpoint_parts[5]:=b.body_version::text;
    endpoint_parts[6]:=md5('master-resolve:'||d.id||':'||original_cap.choice_key);
    endpoint_parts[10]:=round(b.x_m+vector_x*(metres/plan.planned_m),2)::text;
    endpoint_parts[11]:=round(b.y_m+vector_y*(metres/plan.planned_m),2)::text;
    key:=array_to_string(endpoint_parts,':');
   END IF;
   INSERT INTO combat_spatial.movement_semantic_choices(instance_id,actor_id,choice_key,
     endpoint_x_m,endpoint_y_m,max_budget_m,choice_version,enabled)
     VALUES(plan.instance_id,a.id,key,
       b.x_m+CASE WHEN manual_endpoint THEN vector_x*(metres/plan.planned_m) ELSE plan.dx*(metres/(abs(plan.dx)+abs(plan.dy))) END,
       b.y_m+CASE WHEN manual_endpoint THEN vector_y*(metres/plan.planned_m) ELSE plan.dy*(metres/(abs(plan.dx)+abs(plan.dy))) END,remaining,1,true);
   SELECT value INTO item FROM jsonb_array_elements(combat_spatial.movement_options(plan.instance_id,a.id,remaining))
     WHERE value->>'intent'=key AND (value->>'distance_m')::numeric>0;
   IF item IS NOT NULL AND NOT manual_endpoint AND abs(plan.dx)+abs(plan.dy)=2 THEN
     SELECT * INTO STRICT cap FROM combat_spatial.movement_capabilities WHERE capability_id=(item->>'option_id')::uuid AND actor_id=a.id;
     IF abs(cap.end_x_m-cap.start_x_m)<>abs(cap.end_y_m-cap.start_y_m)
       OR sign(cap.end_x_m-cap.start_x_m)<>plan.dx OR sign(cap.end_y_m-cap.start_y_m)<>plan.dy THEN item:=NULL;END IF;
   END IF;
   IF item IS NULL THEN reason:='path_blocked';
   ELSE
     spatial:=combat_spatial.movement_commit((item->>'option_id')::uuid,
       md5(p_root::text||':panel-movement:'||d.id)::uuid,d.id);
     SELECT * INTO STRICT after_body FROM combat_spatial.actor_states WHERE instance_id=b.instance_id AND actor_id=b.actor_id;
     actual:=combat_spatial.distance_m(b.x_m,b.y_m,after_body.x_m,after_body.y_m);
     IF actual>metres OR combat_panel_private.movement_event_cost((spatial->>'event_id')::uuid,actual)>remaining THEN RAISE EXCEPTION 'panel_movement_budget_exceeded' USING ERRCODE='22023'; END IF;
     IF d.sanitized_intent->>'ability_source'='clan' AND d.sanitized_intent->>'ability_id'='9ac77d79-9894-5388-9753-70538ac5eaa3' AND (actual<5 OR NOT combat_panel_private.target_geometry_valid(a.id,d.target_actor_id,2)) THEN reason:='taijutsu_entry_incomplete';END IF;
   END IF;
 END IF;
 IF reason IS NULL AND d.sanitized_intent->>'ability_source'='clan' AND d.sanitized_intent->>'ability_id'='b076a976-c75b-4b5a-8813-b0e8e2c3af03'
   AND NOT combat_panel_private.target_geometry_valid(a.id,d.target_actor_id,2)
 THEN reason:='inuzuka_zanna_contact_lost'; END IF;
 INSERT INTO combat_panel_private.master_movement_receipts(declaration_id,round_id,owner_actor_id,body_actor_id,spatial_event_id,distance_m)
   VALUES(d.id,d.round_id,a.id,a.id,(spatial->>'event_id')::uuid,actual);
 movement_result:=jsonb_build_object('movement_contract',d.sanitized_intent->>'movement_contract','movement_m',round(actual,2),
   'planned_m',round(plan.planned_m,2),'reason_code',reason,'spatial_event_id',spatial->'event_id');
 UPDATE combat_panel_private.master_movement_plans SET state='resolved',result=movement_result WHERE request_key=plan.request_key;
 RETURN movement_result;
END $function$
;
CREATE OR REPLACE FUNCTION clan_inuzuka_private.zanna_contact_valid(p_declaration uuid)
 RETURNS boolean
 LANGUAGE plpgsql
 STABLE SECURITY DEFINER
 SET search_path TO ''
AS $function$
DECLARE d public.combat_v2_declarations%ROWTYPE;a public.combat_v2_actors%ROWTYPE;t public.combat_v2_actors%ROWTYPE;
 source_kind text;
BEGIN
 SELECT * INTO STRICT d FROM public.combat_v2_declarations WHERE id=p_declaration;
 SELECT * INTO STRICT a FROM public.combat_v2_actors WHERE id=d.actor_id;
 SELECT * INTO STRICT t FROM public.combat_v2_actors WHERE id=d.target_actor_id;
 IF a.session_id<>t.session_id OR a.state<>'attivo' OR t.state<>'attivo' OR a.team_key=t.team_key THEN RETURN false;END IF;
 SELECT s.source_kind INTO source_kind FROM public.combat_v2_sessions s WHERE s.id=a.session_id;
 IF source_kind='ordinary' THEN RETURN combat_consumer_private.melee_eligible(a.session_id,a.id,t.id);
 ELSIF source_kind='master' THEN
  IF d.sanitized_intent->>'movement_contract'='combat-panel-movement-attack/1' THEN
   RETURN clan_inuzuka_private.zanna_master_endpoint_v1(d.round_id,a.id,t.id,d.request_key,'declared');
  END IF;
  RETURN combat_panel_private.target_geometry_valid(a.id,t.id,2);
 END IF;
 RETURN false;
END $function$
;
CREATE OR REPLACE FUNCTION combat_panel_private.master_actor_offers(p_context uuid, p_expected bigint, p_view jsonb, p_source jsonb)
 RETURNS void
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO ''
AS $function$
DECLARE c combat_panel_private.contexts%ROWTYPE; a public.combat_v2_actors%ROWTYPE;
 defense_target_id uuid; figure_geometry jsonb; target_choice uuid; meta jsonb; item jsonb; pending jsonb; moves jsonb; one jsonb; target record;
 oid uuid; gid uuid; directions uuid; direction_id uuid; target_id uuid; movement_group uuid;
 cap integer; minimum integer; n integer; chakra numeric; cost numeric; ability_range numeric; target_center_range numeric; endpoint_arena record; endpoint_target record; endpoint_budget numeric; endpoint_options jsonb; can_stay boolean;
 diag_targets_total integer:=0;diag_targets_seen integer:=0;diag_mano_seen integer:=0;diag_geometry_stay integer:=0;diag_endpoint_count integer:=0;diag_pending_count integer:=0;diag_rejected_geometry integer:=0;diag_label_present integer:=0;diag_legal_total integer:=0;diag_action_entered integer:=0; mode text; reaction text; label text; dir text; payload jsonb; legal jsonb; endpoint_cache jsonb:='{}'::jsonb;
BEGIN
 PERFORM set_config('tus.native_attack_producer_called','true',true);
 PERFORM set_config('tus.native_attack_producer_diag',jsonb_build_object('targets_total',0,'targets_seen',0,'mano_seen',0,'geometry_stay',0,'endpoint_count',0,'pending_count',0,'rejected_geometry',0,'label_present',0,'legal_total',0,'action_entered',0)::text,true);
 c:=combat_panel_private.owned_context(p_context,p_expected);
 IF c.activity_kind<>'master_v2' OR c.command_actor_id IS NULL OR c.round_id IS NULL THEN RETURN; END IF;
 SELECT * INTO STRICT a FROM public.combat_v2_actors WHERE id=c.command_actor_id AND session_id=c.activity_id
   AND exam_regia_private.actor_principal(id,controller_user)=exam_regia_private.current_principal() AND companion_id IS NULL;
 IF a.state<>'attivo' THEN RETURN; END IF;
 IF p_view#>>'{viewer,command_actor_id}' IS DISTINCT FROM a.id::text
   OR p_source->>'actor' IS DISTINCT FROM a.id::text OR p_source->>'round' IS DISTINCT FROM c.round_id::text THEN
   RAISE EXCEPTION 'panel_master_source_scope_invalid' USING ERRCODE='22023'; END IF;
 IF NOT combat_panel_private.has_master_geometry(a.session_id) THEN RETURN; END IF;
 SELECT greatest(0,coalesce((a.mechanics_snapshot->>'chakra')::numeric,0)-coalesce(sum(clan_hyuga_private.sedici_frozen_cost(d.actor_id,d.cost_snapshot)),0))
   INTO chakra FROM public.combat_v2_declarations d WHERE d.round_id=c.round_id AND d.actor_id=a.id
     AND d.state NOT IN ('superflua','risolta');
 IF p_view#>>'{context,phase}'='action' AND combat_panel_private.human_duel_turn_allowed(c.round_id,a.id) AND NOT EXISTS(SELECT 1 FROM public.combat_v2_declarations
   WHERE round_id=c.round_id AND actor_id=a.id AND kind IN ('attacco','movimento','utilita','passa')) THEN
   -- Un solo catalogo di spostamenti server-issued alimenta sia Movimento sia
   -- l'avvicinamento atomico del colpo a mano, anche per i PNG di Regia.
   diag_action_entered:=1;diag_targets_total:=jsonb_array_length(coalesce(p_source->'targets','[]'::jsonb));
   moves:=combat_panel_private.master_movement_options(c.round_id,a.id);
   FOR meta IN SELECT value FROM jsonb_array_elements(jsonb_build_array(jsonb_build_object(
     'source','mano','name','Colpo a mano','kind','fisico','chakra_cost',0,'damage_base',10))||(SELECT coalesce(jsonb_agg(x.value ORDER BY x.ordinality),'[]'::jsonb)
       FROM jsonb_array_elements(coalesce(p_source->'abilities','[]'::jsonb)) WITH ORDINALITY x(value,ordinality)
       WHERE CASE WHEN x.value->>'source'='clan'
       AND x.value->>'id' IN ('127f3854-4183-4354-a654-f59320d8807e','c8d32b00-3917-41a6-8906-388e7b9efcc7')
       THEN NOT clan_hoki_private.routes_ability(a.id,(x.value->>'id')::uuid) ELSE true END)
      ||CASE WHEN clan_hoki_private.needle_ability(a.id,false) IS NULL THEN '[]'::jsonb
         ELSE jsonb_build_array(clan_hoki_private.needle_ability(a.id,false)) END) LOOP
     IF meta->>'source'='mano' THEN diag_mano_seen:=diag_mano_seen+1;END IF;
     IF meta->>'source'='clan' AND meta->>'id'='3b4c4fd0-c0c2-46a0-a387-f47a95ef7dda' AND clan_akimichi_private.replacement_applies(a.id) THEN CONTINUE; END IF;
     IF meta->>'source'='clan' AND meta->>'id'='214af896-15f8-43e6-858b-614d2851dd3b' AND clan_akimichi_private.replacement_applies(a.id) THEN
       meta:=clan_akimichi_private.partial_meta(a.id,meta);
       IF meta IS NULL THEN CONTINUE; END IF;
     END IF;
     IF meta->>'id' IN ('1260dbc8-ab0c-4b2b-9b94-909d39b7ffbe','5bf9764e-b719-4972-9d75-083b4cb633e7') THEN CONTINUE;END IF;
     IF meta->>'source'='clan' AND meta->>'id'='617484d6-af7b-41c3-a37f-615b22818421' THEN CONTINUE; END IF;
     IF meta->>'source'='clan' AND meta->>'id'='c11ecd52-43cd-479b-8d5d-08187beba56e' THEN CONTINUE; END IF;
     -- ACTION-FLOW-DB-001: Sharingan is an innate control, never a generic attack.
     IF meta->>'source'='clan' AND meta->>'id'='4056f62d-77f3-47f9-8ecb-9a7799682a9d' THEN CONTINUE; END IF;
     IF meta->>'source'='clan' AND meta->>'id'='db51e5ae-8b90-4c3a-a51d-962eb9e19b38'
       AND combat_panel_private.nara_routes_possession_v1(a.id) THEN
       meta:=combat_panel_private.nara_offer_meta_v1(a.id,false);
       IF meta IS NULL THEN CONTINUE; END IF;
     END IF;
     meta:=clan_hyuga_private.sedici_ability_meta(a.id,meta); IF meta IS NULL THEN CONTINUE; END IF; IF meta->>'source'='clan' AND meta->>'id'='b076a976-c75b-4b5a-8813-b0e8e2c3af03' AND clan_inuzuka_private.zanna_profile(a.id) IS NULL THEN CONTINUE; END IF;
     cost:=(clan_hyuga_private.sedici_cost_quote(a.id,coalesce((meta->>'chakra_cost')::integer,0))->>'total')::integer;
     IF cost>chakra THEN CONTINUE; END IF;
     IF meta->>'source'<>'mano' AND (coalesce(meta->>'usage','') NOT IN ('principale','rapida')
       OR coalesce((meta->>'defensive')::boolean,false) OR coalesce((meta->>'di_scena')::boolean,false)
       OR (meta->>'source'='jutsu' AND meta->>'id'='c6e31b7b-38fe-4b4f-b3c7-05f3e922d193')
       OR coalesce((meta->>'diversivo')::boolean,false) OR coalesce(meta->>'consumption_type','ad_utilizzo')='passiva') THEN CONTINUE; END IF;
     -- Eleggibilità Fili e resolver speciali restano autorità del dominio.
     BEGIN
       PERFORM clan_marionettisti_private.assert_jutsu_source(a.id,meta->>'source',(meta->>'id')::uuid);
     EXCEPTION WHEN SQLSTATE '22023' THEN
       IF SQLERRM='fili_other_jutsu_unavailable' THEN CONTINUE; ELSE RAISE; END IF;
     END;
     ability_range:=CASE WHEN meta ? 'nara_range_m' THEN (meta->>'nara_range_m')::numeric WHEN meta->>'hoki_needle_version'='hoki-needle/1' THEN 15 WHEN meta->>'akimichi_partial_contract'='akimichi-partial/1' THEN 3 WHEN meta->>'source'='clan' AND meta->>'id'='e361f7c3-f90b-47ec-bfee-ccbda21257d9' THEN 3 WHEN meta->>'source'='clan' AND meta->>'id'='b076a976-c75b-4b5a-8813-b0e8e2c3af03' THEN 2 WHEN meta->>'source'='mano' THEN 2 ELSE public._fascia_metri(meta->>'range') END;
     legal:='[]';
     FOR item IN SELECT value FROM jsonb_array_elements(p_source->'targets') LOOP
       diag_targets_seen:=diag_targets_seen+1;target_id:=(item->>'id')::uuid;
       IF meta->>'hoki_needle_version'='hoki-needle/1'
          AND NOT clan_hoki_private.needle_target_valid(a.id,target_id) THEN CONTINUE; END IF;
       IF meta->>'source'='clan' AND meta->>'id'='9ac77d79-9894-5388-9753-70538ac5eaa3' AND EXISTS(SELECT 1 FROM combat_panel_private.multiplication_formations WHERE actor_id=target_id AND state='active') THEN CONTINUE;END IF;
       target_center_range:=CASE WHEN meta->>'source'='clan' AND meta->>'id'='72cbe1fb-34c8-44c7-a053-0014b4894b3e' THEN combat_v2_elemental_internal.scarica_contact_range(a.id,target_id) WHEN meta->>'source'='mano' THEN combat_panel_private.manual_contact_center_range(a.id,target_id) ELSE ability_range END;
       figure_geometry:=NULL; pending:='[]'::jsonb;can_stay:=false;
       IF meta ? 'nara_range_m' THEN
         IF combat_panel_private.nara_offer_meta_v1(a.id,false,target_id) IS NULL THEN CONTINUE; END IF;
         can_stay:=true;
       ELSIF EXISTS(SELECT 1 FROM combat_panel_private.multiplication_formations WHERE actor_id=target_id AND state='active') THEN
         IF NOT EXISTS(SELECT 1 FROM combat_panel_private.multiplication_formations f WHERE f.actor_id=target_id AND f.state='active' AND f.mode='assalto') THEN CONTINUE; END IF;
         IF meta->>'source'='clan' AND meta->>'id'='e361f7c3-f90b-47ec-bfee-ccbda21257d9' THEN
          BEGIN
           figure_geometry:=combat_panel_private.multiplication_companion_target_geometry(c.round_id,a.id,target_id);
          EXCEPTION WHEN SQLSTATE 'P0002' THEN CONTINUE;
           WHEN SQLSTATE '22023' THEN
            IF SQLERRM IN ('marionetta_actor_target_invalid','marionetta_link_unavailable',
             'marionetta_module_unavailable','marionetta_attack_out_of_range') THEN CONTINUE; ELSE RAISE; END IF;
          END;
         ELSE figure_geometry:=combat_panel_private.multiplication_target_geometry(a.id,target_id); END IF;
         IF figure_geometry IS NULL OR NOT EXISTS(SELECT 1 FROM jsonb_array_elements(figure_geometry->'figures')
           WHERE (value->>'distance_m')::numeric<=target_center_range AND (value->>'path_clear')::boolean) THEN CONTINUE; END IF;
       ELSIF meta->>'source'='clan' AND meta->>'id'='e361f7c3-f90b-47ec-bfee-ccbda21257d9' THEN
       BEGIN
         PERFORM clan_marionettisti_private.attack_source(c.round_id,a.id,target_id);
       EXCEPTION WHEN SQLSTATE 'P0002' THEN CONTINUE;
         WHEN SQLSTATE '22023' THEN
           IF SQLERRM IN ('marionetta_actor_target_invalid','marionetta_link_unavailable',
             'marionetta_module_unavailable','marionetta_attack_out_of_range') THEN CONTINUE; ELSE RAISE; END IF;
       END;
     ELSIF (meta->>'source'='mano' OR (meta->>'source'='clan' AND meta->>'id' IN ('9ac77d79-9894-5388-9753-70538ac5eaa3','b076a976-c75b-4b5a-8813-b0e8e2c3af03'))) THEN
       can_stay:=combat_panel_private.target_geometry_valid(a.id,target_id,target_center_range);IF can_stay THEN diag_geometry_stay:=diag_geometry_stay+1;END IF; /* INUZUKA-HOTFIX016-ZANNA-CONTACT-BEGIN */ IF meta->>'source'='clan' AND meta->>'id'='b076a976-c75b-4b5a-8813-b0e8e2c3af03' AND can_stay THEN endpoint_options:='[]'::jsonb; ELSE
       SELECT * INTO STRICT endpoint_arena FROM combat_spatial.arena_instances
         WHERE encounter_id=a.session_id AND context_source='panel_master' AND state='open';
       SELECT * INTO STRICT endpoint_target FROM combat_spatial.actor_states
         WHERE instance_id=endpoint_arena.instance_id AND actor_id=target_id AND state='active';
       endpoint_budget:=(combat_panel_private.master_movement_budget(c.round_id,a.id)->>'remaining_m')::numeric;
       IF meta->>'source'='clan' AND meta->>'id'='9ac77d79-9894-5388-9753-70538ac5eaa3' AND endpoint_cache ? target_id::text THEN
         endpoint_options:=endpoint_cache->target_id::text;
       ELSE
         endpoint_options:=combat_panel_private.melee_integer_endpoint_capabilities(
           endpoint_arena.instance_id,a.id,target_id,endpoint_target.x_m,endpoint_target.y_m,
           endpoint_target.footprint_radius_m,endpoint_budget,CASE WHEN meta->>'source'='mano' THEN 'master-mano:' ELSE 'master-taijutsu-entry:' END||c.round_id||':'||a.id);
         IF meta->>'source'='mano' THEN endpoint_cache:=jsonb_set(endpoint_cache,ARRAY[target_id::text],endpoint_options,true); END IF; /* INUZUKA-HOTFIX016-ZANNA-CONTACT-END */END IF;
       END IF;
       diag_endpoint_count:=diag_endpoint_count+jsonb_array_length(endpoint_options);
       SELECT coalesce(jsonb_agg(jsonb_build_object('capability_id',ec.capability_id,
         'distance_m',combat_spatial.distance_m(ec.start_x_m,ec.start_y_m,ec.end_x_m,ec.end_y_m),
         'target_distance_m',value->'target_distance_m','direction','endpoint')
         ORDER BY (value->>'target_distance_m')::numeric,ec.end_x_m,ec.end_y_m),'[]'::jsonb) INTO pending
       FROM jsonb_array_elements(endpoint_options)
       JOIN combat_spatial.movement_capabilities ec ON ec.capability_id=(value->>'movement_capability_id')::uuid
       WHERE combat_panel_private.movement_attack_target_valid(a.id,target_id,ec.capability_id,target_center_range)
         AND (meta->>'source'='mano' OR meta->>'id'='b076a976-c75b-4b5a-8813-b0e8e2c3af03' OR combat_spatial.distance_m(ec.start_x_m,ec.start_y_m,ec.end_x_m,ec.end_y_m)>=5);
       IF meta->>'source'='clan' AND meta->>'id'='9ac77d79-9894-5388-9753-70538ac5eaa3' THEN can_stay:=false;END IF;
       diag_pending_count:=diag_pending_count+jsonb_array_length(pending);
       IF NOT can_stay AND jsonb_array_length(pending)=0 THEN diag_rejected_geometry:=diag_rejected_geometry+1;CONTINUE; END IF;
     ELSIF NOT combat_panel_private.target_geometry_valid(a.id,target_id,target_center_range) THEN CONTINUE;
     END IF;
       SELECT value->>'display_name' INTO label FROM jsonb_array_elements(p_view->'actors') WHERE value->>'actor_id'=target_id::text;
       IF label IS NOT NULL THEN diag_label_present:=diag_label_present+1;legal:=legal||jsonb_build_array(jsonb_build_object('target_actor_id',target_id,'label',label,'figure_geometry',figure_geometry,'movement_options',pending,'center_range_m',target_center_range,'manual_can_stay',can_stay)); END IF;
     END LOOP;
     diag_legal_total:=diag_legal_total+jsonb_array_length(legal);
     IF jsonb_array_length(legal)=0 THEN CONTINUE; END IF;
     cap:=1;
     FOR n IN 2..(CASE WHEN meta ? 'nara_range_m' OR (meta->>'source'='clan' AND meta->>'id'='e361f7c3-f90b-47ec-bfee-ccbda21257d9')
       THEN 1 ELSE least(3,jsonb_array_length(legal)) END) LOOP
       IF coalesce(combat_v2_multitarget_internal.attack_profile_ok(meta,n),false) THEN cap:=n; END IF;
     END LOOP;
     payload:=jsonb_build_object('adapter','master_v2','dispatch','action','kind','attacco','ability_source',meta->'source');
     IF meta->>'source'<>'mano' THEN payload:=payload||jsonb_build_object('ability_id',meta->'id'); END IF;
     oid:=combat_panel_private.create_offer(c.id,c.context_version,'action','declare',(meta->>'name')||CASE WHEN cost>0 THEN ' · '||cost::text||' chakra' ELSE '' END,true,payload);
     gid:=combat_panel_private.add_group(oid,'Bersaglio','target',CASE WHEN cap>1 THEN 'multiple' ELSE 'single' END,1,cap);
     FOR item IN SELECT value FROM jsonb_array_elements(legal) LOOP
       target_choice:=combat_panel_private.add_choice(gid,item->>'label',jsonb_build_object('target_actor_id',item->'target_actor_id'));
       IF jsonb_typeof(item->'figure_geometry')='object' THEN
         PERFORM combat_panel_private.multiplication_add_attack_figures(oid,target_choice,item->'figure_geometry',(item->>'center_range_m')::numeric,item->>'label');
       END IF;
       IF (meta->>'source'='mano' OR (meta->>'source'='clan' AND meta->>'id' IN ('9ac77d79-9894-5388-9753-70538ac5eaa3','b076a976-c75b-4b5a-8813-b0e8e2c3af03'))) AND jsonb_array_length(coalesce(item->'movement_options','[]'::jsonb))>0 THEN
         movement_group:=combat_panel_private.add_group(oid,'Punto di arrivo','movement_distance','single',1,1,target_choice);
         IF item->'manual_can_stay'='true'::jsonb THEN
          PERFORM combat_panel_private.add_choice(movement_group,'Colpisci senza spostarti','{}'::jsonb);
         END IF;
         FOR one IN SELECT value FROM jsonb_array_elements(item->'movement_options') LOOP
           dir:=one->>'direction';
           label:=CASE dir WHEN 'up' THEN '↑ Su' WHEN 'right' THEN '→ Destra' WHEN 'down' THEN '↓ Giù' WHEN 'left' THEN '← Sinistra'
             WHEN 'up_right' THEN '↗ Alto a destra' WHEN 'down_right' THEN '↘ Basso a destra'
             WHEN 'down_left' THEN '↙ Basso a sinistra' WHEN 'up_left' THEN '↖ Alto a sinistra' ELSE 'Spostamento' END;
           PERFORM combat_panel_private.add_choice(movement_group,CASE WHEN one->>'direction'='endpoint' THEN 'Termina a '||(one->>'target_distance_m')||' m · spostamento '||round((one->>'distance_m')::numeric,2)||' m' ELSE label||' · '||((one->>'distance_m')::numeric::integer)::text||' m' END,
             jsonb_build_object('movement_capability_id',one->'capability_id'),(one->>'distance_m')::numeric,CASE WHEN dir='endpoint' THEN NULL ELSE dir END);
         END LOOP;
       END IF;
     END LOOP;
   END LOOP;
   PERFORM clan_uchiha_private.fireball_master_offers(c.id,c.context_version,p_view);
   IF jsonb_array_length(moves)>0 THEN
     oid:=combat_panel_private.create_offer(c.id,c.context_version,'action','declare','Movimento',true,
       jsonb_build_object('adapter','master_v2','dispatch','movement','kind','movimento'));
     directions:=combat_panel_private.add_group(oid,'Direzione','movement_direction','single',1,1);
     FOREACH dir IN ARRAY ARRAY['up','up_right','right','down_right','down','down_left','left','up_left'] LOOP
       IF NOT EXISTS(SELECT 1 FROM jsonb_array_elements(moves) WHERE value->>'direction'=dir) THEN CONTINUE; END IF;
       direction_id:=combat_panel_private.add_choice(directions,CASE dir WHEN 'up' THEN 'Su' WHEN 'right' THEN 'Destra' WHEN 'down' THEN 'Giù' WHEN 'left' THEN 'Sinistra'
    WHEN 'up_right' THEN 'Alto a destra' WHEN 'down_right' THEN 'Basso a destra'
    WHEN 'down_left' THEN 'Basso a sinistra' WHEN 'up_left' THEN 'Alto a sinistra' END,
         jsonb_build_object('direction',dir),NULL,dir);
       gid:=combat_panel_private.add_group(oid,'Distanza','movement_distance','single',1,1,direction_id);
       FOR item IN SELECT DISTINCT ON ((value->>'distance_m')::numeric) value FROM jsonb_array_elements(moves)
         WHERE value->>'direction'=dir ORDER BY (value->>'distance_m')::numeric,value->>'capability_id' LOOP
         PERFORM combat_panel_private.add_choice(gid,(item->>'distance_m')::numeric::integer::text||' m',jsonb_build_object('movement_capability_id',item->'capability_id'),
           (item->>'distance_m')::numeric,dir);
       END LOOP;
     END LOOP;
   END IF;
   PERFORM combat_panel_private.create_offer(c.id,c.context_version,'action','declare','Azione non offensiva',true,
     jsonb_build_object('adapter','master_v2','dispatch','action','kind','utilita'));
   PERFORM combat_panel_private.create_offer(c.id,c.context_version,'action','declare','Passa',false,
     jsonb_build_object('adapter','master_v2','dispatch','action','kind','passa'));
 ELSIF p_view#>>'{context,phase}'='defense' AND NOT EXISTS(SELECT 1 FROM public.combat_v2_declarations
   WHERE round_id=c.round_id AND actor_id=a.id AND kind IN ('difesa','nessuna')) THEN
   FOR meta IN SELECT value FROM jsonb_array_elements(jsonb_build_array(
     jsonb_build_object('reaction','schivata','name','Schivata'),jsonb_build_object('reaction','parata','name','Parata'),
     jsonb_build_object('reaction','nessuna','name','Nessuna difesa'))||coalesce(p_source->'abilities','[]')) LOOP
     reaction:=coalesce(meta->>'reaction','tecnica'); IF reaction='parata' AND clan_inuzuka_private.quattro_active(a.id) THEN CONTINUE; END IF;
     IF reaction='tecnica' AND NOT coalesce((meta->>'defensive')::boolean,false) THEN CONTINUE; END IF;
     meta:=clan_hyuga_private.sedici_ability_meta(a.id,meta); IF meta IS NULL THEN CONTINUE; END IF; IF meta->>'source'='clan' AND meta->>'id'='b076a976-c75b-4b5a-8813-b0e8e2c3af03' AND clan_inuzuka_private.zanna_profile(a.id) IS NULL THEN CONTINUE; END IF;
     cost:=(clan_hyuga_private.sedici_cost_quote(a.id,coalesce((meta->>'chakra_cost')::integer,0))->>'total')::integer; IF cost>chakra THEN CONTINUE; END IF;
     BEGIN
       PERFORM clan_marionettisti_private.assert_jutsu_source(a.id,meta->>'source',(meta->>'id')::uuid);
     EXCEPTION WHEN SQLSTATE '22023' THEN
       IF SQLERRM='fili_other_jutsu_unavailable' THEN CONTINUE; ELSE RAISE; END IF;
     END;
     mode:=CASE WHEN reaction IN ('schivata','parata','nessuna') THEN 'self' ELSE coalesce(meta#>>'{targeting,mode}','self') END;
     IF mode NOT IN ('self','intercept','multi_protect') THEN CONTINUE; END IF;
     -- Match resolver admission: unsupported generic self is never an offered dead end.
     -- Dedicated spatial substitution below is preserved.
     IF reaction='tecnica' AND mode='self' THEN CONTINUE; END IF;
     minimum:=CASE WHEN mode='multi_protect' THEN 2 ELSE 1 END;
     IF mode<>'self' AND NOT coalesce(combat_v2_multitarget_internal.defense_profile_ok(meta,mode,minimum),false) THEN CONTINUE; END IF;
     legal:='[]';
     FOR pending IN SELECT value FROM jsonb_array_elements(p_source->'pending_attack_targets') LOOP
       target_id:=(pending->>'target_actor_id')::uuid;
       IF NOT EXISTS(SELECT 1 FROM jsonb_array_elements(p_view#>'{map,actors}') WHERE value->>'actor_id'=target_id::text) THEN CONTINUE; END IF;
       IF mode='self' THEN
         IF target_id<>a.id AND NOT clan_marionettisti_private.defends_body(a.id,target_id,reaction) THEN CONTINUE; END IF;
       ELSIF combat_panel_private.actor_distance(a.id,target_id)>2 THEN CONTINUE;
       END IF;
       IF meta->>'id'='9f12fc98-bc97-4b95-9bcc-7ce359ebbe4f' AND NOT EXISTS(
         SELECT 1 FROM public.combat_v2_declarations WHERE id=(pending->>'attack_declaration_id')::uuid
           AND lower(coalesce(sanitized_intent#>>'{server_ability,kind}','')) LIKE '%genjutsu%') THEN CONTINUE; END IF;
       SELECT value->>'display_name' INTO label FROM jsonb_array_elements(p_view->'actors') WHERE value->>'actor_id'=target_id::text;
       legal:=legal||jsonb_build_array(pending||jsonb_build_object('label','Attacco su '||label));
     END LOOP;
     IF jsonb_array_length(legal)<minimum THEN CONTINUE; END IF;
     cap:=CASE WHEN mode='multi_protect' THEN least(4,jsonb_array_length(legal)) ELSE 1 END;
     payload:=jsonb_build_object('adapter','master_v2','dispatch','defense','reaction',reaction,'mode',mode);
     IF reaction='tecnica' THEN payload:=payload||jsonb_build_object('ability_source',meta->'source','ability_id',meta->'id'); END IF;
     oid:=combat_panel_private.create_offer(c.id,c.context_version,'defense','defend',(meta->>'name')||CASE WHEN cost>0 THEN ' · '||cost::text||' chakra' ELSE '' END,true,payload);
     gid:=combat_panel_private.add_group(oid,'Copertura','coverage',CASE WHEN cap>1 THEN 'multiple' ELSE 'single' END,minimum,cap);
     FOR item IN SELECT value FROM jsonb_array_elements(legal) LOOP
       target_choice:=combat_panel_private.add_choice(gid,item->>'label',item-'label');
       PERFORM combat_panel_private.multiplication_add_defense_figures(oid,a.id,(item->>'attack_target_id')::uuid,target_choice);
     END LOOP;
   END LOOP;
   BEGIN
     PERFORM clan_marionettisti_private.assert_jutsu_source(a.id,'jutsu','31b15861-fb78-4f8a-ac1c-ebf2d957c32e');
   EXCEPTION WHEN SQLSTATE '22023' THEN
     IF SQLERRM='fili_other_jutsu_unavailable' THEN RETURN; ELSE RAISE; END IF;
   END;
   IF chakra>=(clan_hyuga_private.sedici_cost_quote(a.id,5)->>'total')::integer THEN
     FOR pending IN SELECT value FROM jsonb_array_elements(coalesce(p_source->'substitution_offers','[]')) LOOP
       IF jsonb_array_length(coalesce(pending#>'{offer,options}','[]'))=0 THEN CONTINUE; END IF;
       oid:=combat_panel_private.create_offer(c.id,c.context_version,'defense','defend','Sostituzione · '||(clan_hyuga_private.sedici_cost_quote(a.id,5)->>'total')||' chakra',true,
         jsonb_build_object('adapter','master_v2','dispatch','substitution','attack_declaration_id',pending->'attack_declaration_id'));
       SELECT id INTO defense_target_id FROM public.combat_v2_attack_targets
         WHERE attack_declaration_id=(pending->>'attack_declaration_id')::uuid AND round_id=c.round_id AND target_actor_id=a.id;
       IF defense_target_id IS NOT NULL THEN
         PERFORM combat_panel_private.multiplication_add_defense_figures(oid,a.id,defense_target_id); END IF;
       gid:=combat_panel_private.add_group(oid,'Punto di sostituzione','target','single',1,1);
       FOR item IN SELECT value FROM jsonb_array_elements(pending#>'{offer,options}') LOOP
         PERFORM combat_panel_private.add_choice(gid,coalesce(item->>'label','Punto disponibile'),
           jsonb_build_object('substitution_option_id',item->'option_id'));
       END LOOP;
     END LOOP;
   END IF;
 END IF;
 PERFORM set_config('tus.native_attack_producer_diag',jsonb_build_object('targets_total',diag_targets_total,'targets_seen',diag_targets_seen,'mano_seen',diag_mano_seen,'geometry_stay',diag_geometry_stay,'endpoint_count',diag_endpoint_count,'pending_count',diag_pending_count,'rejected_geometry',diag_rejected_geometry,'label_present',diag_label_present,'legal_total',diag_legal_total,'action_entered',diag_action_entered)::text,true);
END $function$
;
CREATE OR REPLACE FUNCTION combat_panel_private.bind_master_movement(p_declaration uuid)
 RETURNS void
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO ''
AS $function$
DECLARE d public.combat_v2_declarations%ROWTYPE; planned numeric;
BEGIN
 SELECT * INTO STRICT d FROM public.combat_v2_declarations WHERE id=p_declaration;
 IF d.kind='movimento' AND d.sanitized_intent->>'movement_contract'='combat-panel-movement/1' THEN
   UPDATE combat_panel_private.master_movement_plans SET declaration_id=d.id,state='declared'
     WHERE request_key=d.request_key AND actor_id=d.actor_id AND round_id=d.round_id
       AND principal_user=exam_regia_private.current_principal() AND controller_version=d.controller_version_snapshot AND state='prepared'
     RETURNING planned_m INTO planned;
   IF NOT FOUND THEN RAISE EXCEPTION 'panel_movement_plan_missing' USING ERRCODE='22023'; END IF;
 ELSIF d.kind='attacco' AND (coalesce(d.sanitized_intent->>'ability_source','mano')='mano' OR (d.sanitized_intent->>'ability_source'='clan' AND d.sanitized_intent->>'ability_id' IN ('9ac77d79-9894-5388-9753-70538ac5eaa3','b076a976-c75b-4b5a-8813-b0e8e2c3af03'))) THEN
   UPDATE combat_panel_private.master_movement_plans SET declaration_id=d.id,state='declared'
     WHERE request_key=d.request_key AND actor_id=d.actor_id AND round_id=d.round_id
       AND principal_user=exam_regia_private.current_principal() AND controller_version=d.controller_version_snapshot AND state='prepared'
     RETURNING planned_m INTO planned;
   IF FOUND THEN
     UPDATE public.combat_v2_declarations SET sanitized_intent=sanitized_intent||jsonb_build_object(
       'move_m',planned,'movement_contract','combat-panel-movement-attack/1') WHERE id=d.id;
   END IF;
 END IF;
END $function$
;
DO $post$ BEGIN
IF md5(pg_get_functiondef('public.combat_v2_action_declare(uuid,uuid,jsonb,text,uuid)'::regprocedure)) IS DISTINCT FROM 'a599b31eb137d549f82b2fb6d4a01c02' THEN RAISE EXCEPTION 'inuzuka_zanna_post_0'; END IF;
IF md5(pg_get_functiondef('combat_v2_multitarget_internal.sync_declaration()'::regprocedure)) IS DISTINCT FROM '498741e80f9aae9a0e16f6c92a884330' THEN RAISE EXCEPTION 'inuzuka_zanna_post_1'; END IF;
IF md5(pg_get_functiondef('combat_panel_private.resolve_master_movement(uuid,uuid)'::regprocedure)) IS DISTINCT FROM 'bce0d59162a69cec9c8d9f5464b3b99d' THEN RAISE EXCEPTION 'inuzuka_zanna_post_2'; END IF;
IF md5(pg_get_functiondef('clan_inuzuka_private.zanna_contact_valid(uuid)'::regprocedure)) IS DISTINCT FROM '9766774438bf66a438139a43fc7fbd09' THEN RAISE EXCEPTION 'inuzuka_zanna_post_3'; END IF;
IF md5(pg_get_functiondef('combat_panel_private.master_actor_offers(uuid,bigint,jsonb,jsonb)'::regprocedure)) IS DISTINCT FROM '907706e0d4a03e59b41ac1af2e6e71fe' THEN RAISE EXCEPTION 'inuzuka_zanna_post_4'; END IF;
IF md5(pg_get_functiondef('combat_panel_private.bind_master_movement(uuid)'::regprocedure)) IS DISTINCT FROM 'd942f2150508b22eebb3dc7158f22faa' THEN RAISE EXCEPTION 'inuzuka_zanna_post_5'; END IF;
IF has_function_privilege('anon','clan_inuzuka_private.zanna_master_endpoint_v1(uuid,uuid,uuid,uuid,text)','EXECUTE') OR has_function_privilege('authenticated','clan_inuzuka_private.zanna_master_endpoint_v1(uuid,uuid,uuid,uuid,text)','EXECUTE') THEN RAISE EXCEPTION 'inuzuka_zanna_helper_acl'; END IF;
END $post$;
COMMIT;
