BEGIN;
SET LOCAL lock_timeout='3s';
SET LOCAL statement_timeout='60s';
DO $pin$ BEGIN
 IF NOT EXISTS(SELECT 1 FROM clan_marionettisti_private.ocular_sever_gate_v1 WHERE singleton AND NOT staff_enabled AND NOT public_enabled)
   OR EXISTS(SELECT 1 FROM clan_marionettisti_private.ocular_sever_authorizations_v1)
 THEN RAISE EXCEPTION 'OCULAR_SEVER_RESIDUAL_DRIFT'; END IF;
 PERFORM clan_innata_private.eligibility_release_assert();
 IF EXISTS (SELECT 1 FROM public.combat_v2_sessions WHERE closed_at IS NULL)
    OR EXISTS (SELECT 1 FROM public.master_v2_sessions WHERE closed_at IS NULL) THEN RAISE EXCEPTION 'OCULAR_SEVER_ACTIVE_SCENE'; END IF;
 IF md5(pg_get_functiondef('public.combat_v2_sanitize_intent(jsonb,boolean)'::regprocedure)) IS DISTINCT FROM '3ffe2ba7cb09d98a9d01706b1081775e' THEN RAISE EXCEPTION 'OCULAR_SEVER_BASELINE: public.combat_v2_sanitize_intent(jsonb,boolean)'; END IF;
 IF md5(pg_get_functiondef('public.combat_v2_action_declare(uuid,uuid,jsonb,text,uuid)'::regprocedure)) IS DISTINCT FROM 'c7d780c56576215e5267da68f75aeee0' THEN RAISE EXCEPTION 'OCULAR_SEVER_BASELINE: public.combat_v2_action_declare(uuid,uuid,jsonb,text,uuid)'; END IF;
 IF md5(pg_get_functiondef('combat_v2_multitarget_internal.sync_declaration()'::regprocedure)) IS DISTINCT FROM '58c4ce8a9e86dbe3510b79e7d465d52e' THEN RAISE EXCEPTION 'OCULAR_SEVER_BASELINE: combat_v2_multitarget_internal.sync_declaration()'; END IF;
 IF md5(pg_get_functiondef('public.combat_v2_round_resolve(uuid,uuid)'::regprocedure)) IS DISTINCT FROM '27bc902e72077f55fc24614c971060a0' THEN RAISE EXCEPTION 'OCULAR_SEVER_BASELINE: public.combat_v2_round_resolve(uuid,uuid)'; END IF;
 IF md5(pg_get_functiondef('combat_v2_multitarget_internal.resolve_parent(uuid,uuid,uuid,boolean)'::regprocedure)) IS DISTINCT FROM 'de8f2b9166ca424d478c6105aa05b341' THEN RAISE EXCEPTION 'OCULAR_SEVER_BASELINE: combat_v2_multitarget_internal.resolve_parent(uuid,uuid,uuid,boolean)'; END IF;
 IF md5(pg_get_functiondef('combat_effects_private.settle_native_target(uuid,uuid)'::regprocedure)) IS DISTINCT FROM '765a82f68e7ba17758007ae3db18ddbb' THEN RAISE EXCEPTION 'OCULAR_SEVER_BASELINE: combat_effects_private.settle_native_target(uuid,uuid)'; END IF;
 IF md5(pg_get_functiondef('clan_marionettisti_private.settle_round_damage(uuid)'::regprocedure)) IS DISTINCT FROM 'd9464bea7cfda45a85909e65f2c6e927' THEN RAISE EXCEPTION 'OCULAR_SEVER_BASELINE: clan_marionettisti_private.settle_round_damage(uuid)'; END IF;
 IF md5(pg_get_functiondef('clan_marionettisti_private.declaration_terminal_trigger()'::regprocedure)) IS DISTINCT FROM '73bb01b4c0fb3ef31035f55469acd91d' THEN RAISE EXCEPTION 'OCULAR_SEVER_BASELINE: clan_marionettisti_private.declaration_terminal_trigger()'; END IF;
 IF md5(pg_get_functiondef('clan_marionettisti_private.narrative_attack_allowed(uuid)'::regprocedure)) IS DISTINCT FROM '1083a424325b0b73d649d3f4c5a78f07' THEN RAISE EXCEPTION 'OCULAR_SEVER_BASELINE: clan_marionettisti_private.narrative_attack_allowed(uuid)'; END IF;
 IF md5(pg_get_functiondef('combat_consumer_private.narrative_context(uuid)'::regprocedure)) IS DISTINCT FROM '19c1c2496089b698e3f0ebb55515e500' THEN RAISE EXCEPTION 'OCULAR_SEVER_BASELINE: combat_consumer_private.narrative_context(uuid)'; END IF;
 IF md5(pg_get_functiondef('combat_effects_private.freeze_source(uuid)'::regprocedure)) IS DISTINCT FROM '4320c02049f202a0e9b232011714cde7' THEN RAISE EXCEPTION 'OCULAR_SEVER_BASELINE: combat_effects_private.freeze_source(uuid)'; END IF;
 IF md5(pg_get_functiondef('combat_panel_private.master_actor_offers(uuid,bigint,jsonb,jsonb)'::regprocedure)) IS DISTINCT FROM '315e3c251fc683ff34508e50c5a0e082' THEN RAISE EXCEPTION 'OCULAR_SEVER_BASELINE: combat_panel_private.master_actor_offers(uuid,bigint,jsonb,jsonb)'; END IF;
 IF md5(pg_get_functiondef('combat_panel_private.commit_master_actor(jsonb)'::regprocedure)) IS DISTINCT FROM '69b96309bd743d095af9d6ac8521ea12' THEN RAISE EXCEPTION 'OCULAR_SEVER_BASELINE: combat_panel_private.commit_master_actor(jsonb)'; END IF;
 IF md5(pg_get_functiondef('combat_consumer_private.exchange_options(jsonb)'::regprocedure)) IS DISTINCT FROM '54a1c83a53b993df51d5f544d2e97758' THEN RAISE EXCEPTION 'OCULAR_SEVER_BASELINE: combat_consumer_private.exchange_options(jsonb)'; END IF;
 IF md5(pg_get_functiondef('combat_consumer_private.offer_exchange(uuid,uuid,uuid,integer,text,text,jsonb)'::regprocedure)) IS DISTINCT FROM 'a61212444e2e007101681e8c596570eb' THEN RAISE EXCEPTION 'OCULAR_SEVER_BASELINE: combat_consumer_private.offer_exchange(uuid,uuid,uuid,integer,text,text,jsonb)'; END IF;
 IF md5(pg_get_functiondef('combat_consumer_private.commit_exchange(jsonb,jsonb)'::regprocedure)) IS DISTINCT FROM '46bfc01f869ced2e54fafdd6f67f2764' THEN RAISE EXCEPTION 'OCULAR_SEVER_BASELINE: combat_consumer_private.commit_exchange(jsonb,jsonb)'; END IF;
 IF md5(pg_get_functiondef('combat_panel_private.narrative_ordinary_context(uuid)'::regprocedure)) IS DISTINCT FROM '59fdcdc9dd1587ba4c2add3b008e8892' THEN RAISE EXCEPTION 'OCULAR_SEVER_BASELINE: combat_panel_private.narrative_ordinary_context(uuid)'; END IF;
 IF md5(pg_get_functiondef('public.marionetta_staff_sever_arm_v1(uuid,uuid,uuid)'::regprocedure)) IS DISTINCT FROM 'd649a3dc295f0ea1908b230e5b89c797' THEN RAISE EXCEPTION 'OCULAR_SEVER_BASELINE: public.marionetta_staff_sever_arm_v1(uuid,uuid,uuid)'; END IF;
END $pin$;
ALTER TABLE clan_marionettisti_private.ocular_sever_authorizations_v1
  ADD COLUMN proof jsonb CHECK (proof IS NULL OR jsonb_typeof(proof)='object');

CREATE FUNCTION clan_marionettisti_private.ocular_sever_proof_v1(
  p_key uuid, p_round uuid, p_actor uuid, p_target uuid
) RETURNS jsonb
LANGUAGE sql STABLE SECURITY DEFINER SET search_path TO ''
AS $fn$
  SELECT x.proof FROM clan_marionettisti_private.ocular_sever_authorizations_v1 x
  WHERE x.request_key=p_key AND x.round_id=p_round AND x.actor_id=p_actor AND x.target_id=p_target
$fn$;
REVOKE ALL ON FUNCTION clan_marionettisti_private.ocular_sever_proof_v1(uuid,uuid,uuid,uuid) FROM PUBLIC, anon, authenticated, service_role;

CREATE OR REPLACE FUNCTION clan_marionettisti_private.ocular_sever_contact_v1(
  p_instance uuid, p_actor uuid, p_owner uuid, p_body uuid,
  family text, tier integer, p_max_range_m numeric, p_eye_range_m numeric
) RETURNS boolean
LANGUAGE plpgsql STABLE SECURITY DEFINER SET search_path TO ''
AS $fn$
DECLARE
  scope record;
  orientation combat_facing_private.orientations;
  dx numeric;
  dy numeric;
  closest numeric;
  max_range numeric;
  samples integer;
BEGIN
  SELECT i.encounter_id AS session_id, i.instance_id,
    ax.x_m AS attacker_x, ax.y_m AS attacker_y,
    ox.x_m AS owner_x, ox.y_m AS owner_y,
    bx.x_m AS body_x, bx.y_m AS body_y
  INTO scope
  FROM combat_spatial.arena_instances i
  JOIN combat_spatial.actor_states ax ON ax.instance_id=i.instance_id AND ax.actor_id=p_actor AND ax.state='active'
  JOIN combat_spatial.actor_states ox ON ox.instance_id=i.instance_id AND ox.actor_id=p_owner AND ox.state='active'
  JOIN combat_spatial.actor_states bx ON bx.instance_id=i.instance_id AND bx.actor_id=p_body AND bx.state='active'
  WHERE i.instance_id=p_instance AND i.state='open';
  IF NOT FOUND OR p_max_range_m IS NULL OR p_max_range_m<0 OR p_eye_range_m IS NULL OR p_eye_range_m<=0
     OR p_max_range_m IN ('NaN'::numeric,'Infinity'::numeric,'-Infinity'::numeric)
  THEN RETURN false; END IF;

  -- Derive a point on the live link without exposing either endpoint to the client.
  dx:=scope.body_x-scope.owner_x;
  dy:=scope.body_y-scope.owner_y;
  IF dx=0 AND dy=0 THEN RETURN false; END IF;
  closest:=greatest(0,least(1,((scope.attacker_x-scope.owner_x)*dx+(scope.attacker_y-scope.owner_y)*dy)/(dx*dx+dy*dy)));
  max_range:=least(p_max_range_m,p_eye_range_m);
  samples:=greatest(1,ceil(sqrt(dx*dx+dy*dy)*4)::integer);
  SELECT * INTO orientation FROM combat_facing_private.orientations
    WHERE session_id=scope.session_id AND actor_id=p_actor AND instance_id=scope.instance_id AND valid;
  RETURN EXISTS(
    -- Keep the continuous nearest point and the engine's spatial resolution along the link.
    SELECT 1 FROM (
      SELECT closest AS parameter
      UNION
      SELECT sample::numeric/samples FROM generate_series(0,samples) sample
    ) t
    CROSS JOIN LATERAL (SELECT scope.owner_x+t.parameter*dx AS x,
                              scope.owner_y+t.parameter*dy AS y) point
    WHERE combat_spatial.distance_m(scope.attacker_x,scope.attacker_y,point.x,point.y)<=max_range
      AND (orientation.session_id IS NULL OR (family='Byakugan' AND tier=4)
        OR orientation.dx*(point.x-scope.attacker_x)+orientation.dy*(point.y-scope.attacker_y)>=0)
      AND combat_spatial.path_first_block_t(scope.instance_id,p_actor,
        scope.attacker_x,scope.attacker_y,point.x,point.y,p_body)>=1
  );
END $fn$;
REVOKE ALL ON FUNCTION clan_marionettisti_private.ocular_sever_contact_v1(uuid,uuid,uuid,uuid,text,integer,numeric,numeric) FROM PUBLIC, anon, authenticated, service_role;

CREATE OR REPLACE FUNCTION clan_marionettisti_private.ocular_sever_source_v1(
  p_round uuid, p_actor uuid, p_body uuid, p_max_range_m numeric
) RETURNS jsonb
LANGUAGE plpgsql STABLE SECURITY DEFINER SET search_path TO ''
AS $fn$
DECLARE
  scope record;
  gate clan_marionettisti_private.ocular_sever_gate_v1;
  eye uuid;
  family text;
  tier integer;
  eye_range numeric;
  simulated boolean;
BEGIN
  SELECT r.session_id, r.phase, a.controller_user, a.id AS attacker_id, l.owner_actor_id,
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

  SELECT * INTO STRICT gate FROM clan_marionettisti_private.ocular_sever_gate_v1 WHERE singleton;
  simulated:=NOT public.combat_v2_values_written(scope.session_id);
  IF simulated IS DISTINCT FROM scope.is_simulated
    OR (CASE WHEN simulated THEN NOT (gate.staff_enabled AND scope.is_test
          AND scope.location_id='0b85f354-9cdb-47e1-baf9-3d266bb7e06b'::uuid
          AND combat_consumer_private.staff_test_allowed(scope.location_id,ARRAY[auth.uid()],false))
        ELSE NOT gate.public_enabled OR scope.is_test OR scope.is_exam_room IS TRUE END)
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
END $fn$;
REVOKE ALL ON FUNCTION clan_marionettisti_private.ocular_sever_source_v1(uuid,uuid,uuid,numeric) FROM PUBLIC, anon, authenticated, service_role;

CREATE OR REPLACE FUNCTION clan_marionettisti_private.ocular_sever_attack_range_v1(
  p_actor uuid, p_source text, p_ability uuid, p_meta jsonb
) RETURNS numeric
LANGUAGE plpgsql STABLE SECURITY DEFINER SET search_path TO ''
AS $fn$
BEGIN
  IF p_meta IS NULL OR p_ability IS NULL
     OR p_meta->>'source' IS DISTINCT FROM p_source
     OR p_meta->>'id' IS DISTINCT FROM p_ability::text THEN RETURN NULL; END IF;

  IF p_source='arma' THEN
    IF p_ability::text IS DISTINCT FROM combat_panel_private.shuriken_profile_v1()->>'id' THEN RETURN NULL; END IF;
    RETURN (p_meta->>'range_m')::numeric;
  END IF;

  IF p_source NOT IN ('clan','jutsu')
     OR lower(coalesce(p_meta->>'kind','fisico')) NOT IN ('fisico','ninjutsu','taijutsu')
     OR coalesce(p_meta->>'usage','') NOT IN ('principale','rapida')
     OR coalesce((p_meta->>'defensive')::boolean,false)
     OR coalesce((p_meta->>'di_scena')::boolean,false)
     OR coalesce((p_meta->>'diversivo')::boolean,false)
     OR coalesce(p_meta->>'consumption_type','ad_utilizzo')='passiva'
     OR (p_source='clan' AND (
       combat_v2_elemental_internal.suiton_profile(p_actor,p_ability) IS NOT NULL
       OR (combat_v2_elemental_internal.other_profile(p_actor,p_ability) IS NOT NULL
         AND p_ability NOT IN ('6d7c0804-1ba9-4e49-8697-1a550f3608b2'::uuid,
           'b10f8ee7-43ed-4de1-8662-bfcc08ea3a07'::uuid,
           '29e49eb9-56d7-4d35-afae-af14bf0c8e65'::uuid,
           'fea014d1-0d71-43dd-bd60-045fbecf3184'::uuid))))
     OR p_ability IN (
       '001f907c-8f32-4758-8a16-ad1730e72c59'::uuid,
       'db51e5ae-8b90-4c3a-a51d-962eb9e19b38'::uuid,
       'e361f7c3-f90b-47ec-bfee-ccbda21257d9'::uuid,
       '1260dbc8-ab0c-4b2b-9b94-909d39b7ffbe'::uuid,
       '5bf9764e-b719-4972-9d75-083b4cb633e7'::uuid,
       '127f3854-4183-4354-a654-f59320d8807e'::uuid,
       'c8d32b00-3917-41a6-8906-388e7b9efcc7'::uuid,
       '214af896-15f8-43e6-858b-614d2851dd3b'::uuid,
       'b076a976-c75b-4b5a-8813-b0e8e2c3af03'::uuid,
       '9ac77d79-9894-5388-9753-70538ac5eaa3'::uuid,
       '031d5ecc-86ee-4d21-85f1-6b76fc57cef9'::uuid,
       '93e3cca1-3ec3-4737-9a2a-13e466cc542f'::uuid,
       'f5e9af24-70f1-49f6-a7ca-74f59256336e'::uuid,
       'b9195ceb-74de-4251-95af-fe5c1bdaf485'::uuid,
       'c6e31b7b-38fe-4b4f-b3c7-05f3e922d193'::uuid
     ) THEN RETURN NULL; END IF;
  RETURN public._fascia_metri(p_meta->>'range');
END $fn$;
REVOKE ALL ON FUNCTION clan_marionettisti_private.ocular_sever_attack_range_v1(uuid,text,uuid,jsonb) FROM PUBLIC, anon, authenticated, service_role;

CREATE OR REPLACE FUNCTION clan_marionettisti_private.ocular_sever_frozen_valid_v1(p_declaration uuid)
RETURNS boolean LANGUAGE sql STABLE SECURITY DEFINER SET search_path TO ''
AS $fn$
  SELECT EXISTS(
    SELECT 1
    FROM public.combat_v2_declarations d
    JOIN public.combat_v2_rounds r ON r.id=d.round_id AND r.phase='risoluzione'
    JOIN public.combat_v2_actors a ON a.id=d.actor_id AND a.session_id=r.session_id AND a.state='attivo'
    JOIN clan_marionettisti_private.ocular_sever_authorizations_v1 permit
      ON permit.request_key=d.request_key AND permit.round_id=d.round_id AND permit.actor_id=d.actor_id
      AND permit.target_id=d.target_actor_id AND permit.ability_id::text=d.sanitized_intent->>'ability_id'
      AND permit.attack_source=d.sanitized_intent->>'ability_source'
    JOIN clan_marionettisti_private.links l ON l.companion_actor_id=d.target_actor_id
      AND l.owner_actor_id::text=permit.proof->>'owner_actor_id'
      AND l.link_version::text=permit.proof->>'link_version'
      AND l.state='connected'
    JOIN public.combat_v2_actors o ON o.id=l.owner_actor_id AND o.session_id=r.session_id AND o.state='attivo'
    JOIN public.combat_v2_actors b ON b.id=l.companion_actor_id AND b.session_id=r.session_id AND b.state='attivo'
    JOIN combat_spatial.arena_instances i ON i.instance_id=l.instance_id
      AND i.encounter_id=r.session_id AND i.state='open'
    JOIN clan_innata_combat_private.combat_state eye ON eye.session_id=r.session_id AND eye.actor_id=a.id
      AND eye.technique_id::text=permit.proof->>'eye_id'
      AND eye.active AND eye.is_test=l.is_simulated
    JOIN public.clan_techniques ct ON ct.id=eye.technique_id AND ct.is_active AND ct.is_innata
    WHERE d.id=p_declaration AND d.kind='attacco' AND d.sanitized_intent->'target_fili'='true'::jsonb
      AND clan_marionettisti_private.ocular_sever_contact_v1(i.instance_id,a.id,o.id,b.id,ct.name,ct.level,
        (permit.proof->>'range_m')::numeric,public._fascia_metri(ct.gittata))
  )
$fn$;
REVOKE ALL ON FUNCTION clan_marionettisti_private.ocular_sever_frozen_valid_v1(uuid) FROM PUBLIC, anon, authenticated, service_role;

CREATE OR REPLACE FUNCTION clan_marionettisti_private.ocular_sever_authorize_v1(
  p_round uuid,p_actor uuid,p_target uuid,p_source text,p_ability uuid,p_request uuid
) RETURNS void
LANGUAGE sql VOLATILE SECURITY DEFINER SET search_path TO ''
AS $fn$
 INSERT INTO clan_marionettisti_private.ocular_sever_authorizations_v1
   (request_key,transaction_id,round_id,actor_id,target_id,attack_source,ability_id)
 VALUES (p_request,txid_current(),p_round,p_actor,p_target,p_source,p_ability)
 ON CONFLICT (request_key) DO NOTHING
$fn$;
REVOKE ALL ON FUNCTION clan_marionettisti_private.ocular_sever_authorize_v1(uuid,uuid,uuid,text,uuid,uuid) FROM PUBLIC, anon, authenticated, service_role;

CREATE OR REPLACE FUNCTION public.combat_v2_sanitize_intent(p_intent jsonb, p_defense boolean DEFAULT false)
 RETURNS jsonb
 LANGUAGE plpgsql
 STABLE SECURITY DEFINER
 SET search_path TO ''
AS $function$
declare v_allowed text[]; v_key text; v_kind text; v_out jsonb;
begin
  if p_intent is null or jsonb_typeof(p_intent)<>'object' then
    perform public.combat_v2_fail('intento_non_valido','Intento non valido.',422,null,'{}');
  end if;
  if public.combat_v2_has_forbidden_key(p_intent) then
    perform public.combat_v2_fail('campo_meccanico_vietato','Il payload contiene un campo meccanico vietato.',422,null,'{}');
  end if;
  v_allowed := case when p_defense then array['reaction','ability_source','ability_id','attack_target_ids'] else array['kind','ability_source','ability_id','target_actor','target_actor_ids','move_m','target_fili'] end;
  if p_intent ? 'target_fili' and p_intent->'target_fili' is distinct from 'true'::jsonb then
    perform public.combat_v2_fail('intento_non_valido','Bersaglio Fili non valido.',422,null,'{}');
  end if;
  for v_key in select jsonb_object_keys(p_intent) loop
    if not (v_key=any(v_allowed)) then
      perform public.combat_v2_fail('intento_non_valido','Campo intento non riconosciuto.',422,null,jsonb_build_object('field',v_key));
    end if;
  end loop;
  v_kind:=lower(coalesce(p_intent->>case when p_defense then 'reaction' else 'kind' end,''));
  if (p_defense and v_kind not in ('schivata','parata','sostituzione','copie','tecnica','nessuna'))
     or (not p_defense and v_kind not in ('attacco','movimento','utilita','passa')) then
    perform public.combat_v2_fail('intento_non_valido','Tipo di intento non valido.',422,null,'{}');
  end if;
  v_out:=p_intent;
  if v_out ? 'ability_id' and (v_out->>'ability_id') is not null then
    begin perform (v_out->>'ability_id')::uuid; exception when invalid_text_representation then
      perform public.combat_v2_fail('intento_non_valido','Identificativo tecnica non valido.',422,null,'{}'); end;
  end if;
  if v_out ? 'target_actor' and (v_out->>'target_actor') is not null then
    begin perform (v_out->>'target_actor')::uuid; exception when invalid_text_representation then
      perform public.combat_v2_fail('bersaglio_non_valido','Bersaglio non valido.',422,null,'{}'); end;
  end if;
  return v_out;
end $function$;

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
  v_has_fili boolean;
  v_fili_range numeric;
  v_fili_source jsonb;
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
  v_has_fili:=v_i ? 'target_fili';
  if v_has_fili and (
    v_kind<>'attacco' or v_i ? 'move_m' or v_i->>'ability_source' not in ('arma','clan','jutsu')
    or v_i->>'ability_id' is null or v_service or auth.uid() is distinct from v_a.controller_user
    or (v_i ? 'target_actor_ids' and v_i->'target_actor_ids' is distinct from jsonb_build_array(v_i->'target_actor'))
    or not exists(
      select 1 from clan_marionettisti_private.ocular_sever_authorizations_v1 allowed
      where allowed.request_key=p_request_key and allowed.transaction_id=txid_current()
        and allowed.round_id=p_round and allowed.actor_id=p_actor
        and allowed.target_id::text=v_i->>'target_actor'
        and allowed.attack_source=v_i->>'ability_source' and allowed.ability_id::text=v_i->>'ability_id')
  ) then
    perform public.combat_v2_fail('opzione_non_offerta','Seleziona un singolo collegamento e un attacco disponibile.',422,p_request_key,'{}');
  end if;
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
    elsif v_source='arma' then
      v_meta:=combat_panel_private.shuriken_available_v1(p_actor);
      if v_meta is null or v_i->>'ability_id' is distinct from v_meta->>'id'
         or v_i ? 'move_m'
         or (v_i ? 'target_actor_ids' and v_i->'target_actor_ids' is distinct from jsonb_build_array(v_target))
         or (not v_has_fili and not combat_panel_private.shuriken_target_v1(p_actor,v_target)) then
        perform public.combat_v2_fail('shuriken_non_disponibile','Serve uno Shuriken disponibile e un bersaglio visibile entro 10 metri.',422,p_request_key,'{}');
      end if;
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
      if not v_has_fili and fireball.actor_id IS NULL and not (v_source='clan' and v_ability='e361f7c3-f90b-47ec-bfee-ccbda21257d9'::uuid) and
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
  if v_has_fili then
    v_fili_range:=clan_marionettisti_private.ocular_sever_attack_range_v1(
      p_actor,v_source,(v_i->>'ability_id')::uuid,v_meta);
    if v_fili_range is not null and multiplication_meta is null and fireball.actor_id is null
       and escape_meta is null and clone_meta is null and aburame_meta is null then
      v_fili_source:=clan_marionettisti_private.ocular_sever_source_v1(p_round,p_actor,v_target,v_fili_range);
    end if;
    if v_fili_source is null then
      perform public.combat_v2_fail('opzione_non_offerta','Servono Fili visibili e a portata dell’attacco scelto.',422,p_request_key,'{}');
    end if;
    update clan_marionettisti_private.ocular_sever_authorizations_v1
      set proof=v_fili_source where request_key=p_request_key and transaction_id=txid_current();
  end if;
  v_event:=public.combat_v2_event_begin(p_round,p_request_key,'combat_v2_action_declare',jsonb_build_object('actor',p_actor,'intent',v_i,'text',coalesce(p_text,'')),null);
  if (v_event->>'replay')::boolean then return v_event->'result'; end if; v_event_id:=(v_event->>'event_id')::uuid;
  insert into public.combat_v2_declarations(round_id,actor_id,kind,target_actor_id,sanitized_intent,declaration_text,controller_user_snapshot,controller_version_snapshot,request_key,cost_snapshot)
  values(p_round,p_actor,v_kind,v_target,v_i||case when v_meta is null then '{}'::jsonb else jsonb_build_object('server_ability',v_meta) end,
    coalesce(p_text,''),coalesce(v_uid,v_service_actor),v_a.controller_version,p_request_key,clan_hyuga_private.sedici_cost_snapshot(p_actor,jsonb_build_object('chakra',v_cost,'damage_base',v_base))) returning id into v_id;
  IF v_source='arma' THEN
    PERFORM combat_panel_private.shuriken_spend_v1(v_id,p_request_key);
  END IF;
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
end $function$;

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
   if new.sanitized_intent ? 'target_fili' then
     if cardinality(ids)<>1 OR NOT EXISTS(SELECT 1 FROM clan_marionettisti_private.ocular_sever_authorizations_v1 permit
       WHERE permit.request_key=new.request_key AND permit.transaction_id=txid_current()
         AND permit.round_id=new.round_id AND permit.actor_id=a.id AND permit.target_id=t
         AND permit.proof IS NOT NULL AND permit.proof IS NOT DISTINCT FROM
           clan_marionettisti_private.ocular_sever_source_v1(new.round_id,a.id,t,(permit.proof->>'range_m')::numeric)) then
       raise exception 'fili_target_not_available' using errcode='22023';
     end if;
   elsif new.sanitized_intent->>'ability_source'='arma'
     and new.sanitized_intent->>'ability_id'=combat_panel_private.shuriken_profile_v1()->>'id' then
    if not combat_panel_private.shuriken_target_v1(a.id,t) then raise exception 'fuori_portata'; end if;
   elsif multiplication_aim_valid is not null then
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
$function$;

CREATE OR REPLACE FUNCTION public.combat_v2_round_resolve(p_round uuid, p_request_key uuid)
 RETURNS jsonb
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO ''
AS $function$
declare nara_launch jsonb; nara_facts jsonb; elemental_claim jsonb; elemental_channels jsonb; elemental_cap jsonb; elemental_order_outcome jsonb; elemental_order_ready boolean:=false; elemental_target uuid; fireball_profile jsonb; hyuga_profile jsonb; hyuga_juken jsonb; sedici_target uuid; multiplication_facts jsonb; multiplication_effect jsonb; multiplication_target uuid; v_uid uuid:=auth.uid(); v_r public.combat_v2_rounds%rowtype; v_s public.combat_v2_sessions%rowtype; v_m public.master_v2_sessions%rowtype;
  v_event jsonb; v_event_id uuid; v_values boolean; v_entropy bytea; v_order_entropy bytea; v_before jsonb; v_after jsonb; effects_lifecycle jsonb;
  v_d public.combat_v2_declarations%rowtype; v_def public.combat_v2_declarations%rowtype; v_att public.combat_v2_actors%rowtype; v_tar public.combat_v2_actors%rowtype;
  v_meta jsonb; v_calc jsonb; v_rng jsonb; v_kind text; v_reaction text; v_base int; v_dice_a int; v_dice_d int;
  v_a1 int; v_a2 int; v_d1 int; v_d2 int; v_rng_context text; v_order_context text; v_order_rng jsonb;
  v_vote_a int; v_vote_d int; v_corr int; v_raw int; v_final int; v_damage int; v_full int; v_new_hp int;
  v_report jsonb; v_report_id uuid; v_sha text; v_result jsonb; v_chakra int; v_need int; v_order int:=0;
  v_no_attack_continuation boolean:=false;
  v_fili_hit boolean;
  rotation_calc jsonb; flow_calc jsonb; movement_calc jsonb; aburame_calc jsonb; fb_defense_snapshot jsonb;
  akimichi_partial clan_akimichi_private.partial_sources%rowtype;
begin
  if v_uid is null and not public.combat_v2_is_service() then perform public.combat_v2_fail('autenticazione_richiesta','Autenticazione richiesta.',401,p_request_key,'{}'); end if;
  perform public.combat_v2_lock_round(p_round);
  select * into v_r from public.combat_v2_rounds where id=p_round for update;
  if v_r.id is null then perform public.combat_v2_fail('sessione_inesistente','Round inesistente.',404,p_request_key,'{}'); end if;
  select * into v_s from public.combat_v2_sessions where id=v_r.session_id for update;
  if v_s.master_session_id is not null then select * into v_m from public.master_v2_sessions where id=v_s.master_session_id for update; end if;
  v_no_attack_continuation:=v_uid is not null and v_s.source_kind='master' and not combat_consumer_private.owns_round(p_round) and v_r.phase='risoluzione'
    and (select count(*) from public.combat_v2_declarations where round_id=p_round and kind in ('attacco','movimento','utilita','passa') and state not in ('annullata','superflua'))=combat_consumer_private.expected_main_count(p_round)
    and (not exists(select 1 from public.combat_v2_attack_targets t join public.combat_v2_declarations d on d.id=t.attack_declaration_id where t.round_id=p_round and t.state not in ('annullata','superflua') and d.state not in ('annullata','superflua'))
      or (v_r.evaluation_mode='neutra' and exists(
        select 1 from combat_panel_private.multiplication_predefense_plans where round_id=p_round)
        and not exists(select 1 from public.combat_v2_attack_targets mt
          where mt.round_id=p_round and not combat_panel_private.multiplication_no_defense(mt.id))))
    and exists(select 1 from combat_consumer_private.dispatch_authorizations x
      join public.combat_v2_actors a on a.character_id=x.principal_character_id and a.session_id=v_s.id and a.state='attivo'
      where x.request_key=p_request_key and x.round_id=p_round and x.operation='resolve' and x.state='prepared'
        and x.transaction_id=txid_current() and exam_regia_private.actor_principal(a.id,a.controller_user)=v_uid
        and exists(select 1 from public.combat_v2_declarations d where d.id=(select z.id from public.combat_v2_declarations z where z.round_id=p_round and z.kind in ('attacco','movimento','utilita','passa') and z.state not in ('annullata','superflua') order by z.created_at desc,z.id desc limit 1) and d.actor_id=a.id and d.controller_user_snapshot=v_uid and d.controller_version_snapshot=a.controller_version));
  if v_s.source_kind='master' and v_m.master_user<>v_uid and not public.combat_v2_is_service() and not v_no_attack_continuation then perform public.combat_v2_fail('master_non_proprietario','Solo il Master corrente può risolvere.',403,p_request_key,'{}'); end if;
  if v_no_attack_continuation then update combat_consumer_private.dispatch_authorizations set state='consumed' where request_key=p_request_key and round_id=p_round and operation='resolve' and transaction_id=txid_current() and state='prepared'; end if;
  if combat_consumer_private.owns_round(p_round) then perform combat_consumer_private.assert_dispatch(p_round,p_request_key,'resolve'); else if v_s.source_kind='ordinary' and not public.combat_v2_is_service() then perform public.combat_v2_fail('controllo_revocato','Risoluzione ordinary solo server.',403,p_request_key,'{}'); end if; end if;
  perform public.combat_v2_assert_operational(p_round,p_request_key,false);
  -- [MISSION-GUARD-005] Precheck globale prima di evento, freeze e costi.
  if exists(select 1 from public.combat_v2_declarations d
     where d.round_id=p_round and d.kind in ('difesa','nessuna')
       and(coalesce(d.sanitized_intent->>'reaction','nessuna')='copie'
        or(coalesce(d.sanitized_intent->>'reaction','nessuna')='tecnica'
          and coalesce(d.sanitized_intent#>>'{server_ability,targeting,mode}','')not in('intercept','multi_protect')
          and NOT EXISTS(SELECT 1 FROM clan_hyuga_private.rotation_sources rs WHERE rs.declaration_id=d.id) AND NOT combat_v2_elemental_internal.scudo_source_valid(d.id) AND NOT clan_aburame_private.clone_source_valid(d.id)))
  ) then
    perform public.combat_v2_fail('profilo_runtime_non_disponibile','La difesa speciale non ha un resolver V2 attivo.',409,p_request_key,'{}');
  end if;
  v_event:=public.combat_v2_event_begin(p_round,p_request_key,'combat_v2_round_resolve',jsonb_build_object('round',p_round),v_m.control_version);
  if (v_event->>'replay')::boolean then return v_event->'result'; end if; v_event_id:=(v_event->>'event_id')::uuid;
  if v_r.state in ('risolto','narrazione','narrato') then
    select public.combat_v2_envelope(p_request_key,jsonb_build_object('report_id',x.id,'report_sha256',x.mechanics_sha256,'replay',true)) into v_result from public.combat_v2_round_reports x where x.round_id=p_round;
    return public.combat_v2_event_complete(v_event_id,v_result);
  end if;
  if (select count(*) from public.combat_v2_declarations where round_id=p_round and kind in ('attacco','movimento','utilita','passa') and state not in ('annullata','superflua')) <>
     combat_consumer_private.expected_main_count(p_round) then
    perform public.combat_v2_fail('dichiarazioni_mancanti','Mancano dichiarazioni principali.',409,p_request_key,'{}'); end if;
  if not combat_v2_multitarget_internal.round_complete(p_round) then
    perform public.combat_v2_fail('difese_mancanti','Mancano difese.',409,p_request_key,'{}'); end if;
  if v_r.evaluation_mode='neutra' then
    insert into public.combat_v2_ratings(declaration_id,session_id,round_id,pg_character_id,rating_kind,value,source,request_key)
    select d.id,v_s.id,p_round,a.character_id,d.kind,0,'neutralita_sistema',gen_random_uuid()
      from public.combat_v2_declarations d join public.combat_v2_actors a on a.id=d.actor_id
     where d.round_id=p_round and d.kind in ('attacco','difesa') and a.actor_kind='pg'
       and not exists(select 1 from public.combat_v2_ratings x where x.declaration_id=d.id and x.is_active);
  elsif exists(select 1 from public.combat_v2_declarations d join public.combat_v2_actors a on a.id=d.actor_id
    where d.round_id=p_round and d.kind in ('attacco','difesa') and a.actor_kind='pg'
      and not exists(select 1 from public.combat_v2_ratings x where x.declaration_id=d.id and x.is_active)) then
    perform public.combat_v2_fail('voto_richiesto','Mancano voti del Master.',409,p_request_key,'{}');
  end if;
  -- Ordine globale: sessione e round sono già bloccati; ora attori e risorse per UUID.
  perform 1 from public.combat_v2_actors a where a.session_id=v_s.id order by a.id for update;
  perform 1 from public.characters c where c.id in (select a.character_id from public.combat_v2_actors a where a.session_id=v_s.id and a.character_id is not null) order by c.id for update;
  v_before:=(select jsonb_agg(jsonb_build_object('actor',a.id,'state',a.state,'position_m',a.position_m,'mechanics',a.mechanics_snapshot) order by a.id) from public.combat_v2_actors a where a.session_id=v_s.id);
  -- Rivalidazione cumulativa dei costi prima di qualunque consumo.
  for v_att in select * from public.combat_v2_actors a where a.session_id=v_s.id order by a.id loop
    select coalesce(sum(clan_hyuga_private.sedici_frozen_cost(d.actor_id,d.cost_snapshot)),0) into v_need from public.combat_v2_declarations d where d.round_id=p_round and d.actor_id=v_att.id;
    v_chakra:=coalesce((v_att.mechanics_snapshot->>'chakra')::int,0);
    if v_need>v_chakra then perform public.combat_v2_fail('risorsa_insufficiente','Chakra insufficiente al freeze.',409,p_request_key,jsonb_build_object('actor',v_att.id)); end if;
  end loop;
  v_order_entropy:=coalesce(combat_panel_private.multiplication_order_entropy(p_round),extensions.gen_random_bytes(32));
  v_order_context:='combat-v2/r3/order:'||v_s.id::text||':'||p_round::text;
  update public.combat_v2_rounds set phase='congelato',state='congelato',
    rng_order_commitment=encode(extensions.digest(v_order_entropy,'sha256'),'hex'),freeze_at=clock_timestamp()
   where id=p_round;
  with ord as (
    select d.id,row_number() over(order by a.initiative_snapshot desc,
      (('x'||substr(encode(extensions.digest(v_order_entropy||convert_to(a.id::text,'UTF8'),'sha256'),'hex'),1,16))::bit(64)::bigint),a.id) n,
      (('x'||substr(encode(extensions.digest(v_order_entropy||convert_to(a.id::text,'UTF8'),'sha256'),'hex'),1,16))::bit(64)::bigint) tie
    from public.combat_v2_declarations d join public.combat_v2_actors a on a.id=d.actor_id
    where d.round_id=p_round and d.kind in ('attacco','movimento','utilita','passa'))
  update public.combat_v2_declarations d set order_no=ord.n,tie_break=ord.tie,state='congelata',frozen_at=clock_timestamp() from ord where d.id=ord.id;
  v_order_rng:=combat_v2_private.rng_seal(v_s.id,p_round,null,'order',v_order_context,v_order_entropy,
    jsonb_build_object('order_ties',coalesce((select jsonb_object_agg(d.id::text,d.tie_break order by d.id)
      from public.combat_v2_declarations d where d.round_id=p_round and d.kind in ('attacco','movimento','utilita','passa')),'{}'::jsonb)));
  update public.combat_v2_declarations set state='congelata',frozen_at=clock_timestamp() where round_id=p_round and kind in ('difesa','nessuna');
  for v_def in select * from public.combat_v2_declarations where round_id=p_round and kind='difesa' and sanitized_intent->>'reaction'='sostituzione' order by id loop
    perform combat_spatial.substitution_rebase_selected_internal_v1(v_def.id);
    perform public.combat_v2_substitution_resolve_internal_v1(v_def.id,md5(p_request_key::text||'|substitution|'||v_def.id::text)::uuid);
  end loop;
  update public.combat_v2_ratings set frozen_at=clock_timestamp() where round_id=p_round and frozen_at is null;
  v_values:=public.combat_v2_values_written(v_s.id);
  -- Impegno costi di tutte le dichiarazioni; nessun rimborso successivo.
  for v_d in select * from public.combat_v2_declarations where round_id=p_round and not(kind='difesa' and sanitized_intent->>'reaction'='sostituzione') order by actor_id,id loop
    select * into v_att from public.combat_v2_actors where id=v_d.actor_id for update;
    v_need:=clan_hyuga_private.sedici_frozen_cost(v_d.actor_id,v_d.cost_snapshot); v_chakra:=coalesce((v_att.mechanics_snapshot->>'chakra')::int,0);
    insert into public.combat_v2_resource_ledger(session_id,round_id,declaration_id,actor_id,resource_kind,expected_amount,committed_amount,applied_amount,is_simulated,balance_before,balance_after,idempotency_key)
    values(v_s.id,p_round,v_d.id,v_att.id,'chakra',v_need,v_need,case when v_values then v_need else 0 end,not v_values,v_chakra,case when v_values or combat_panel_private.uses_simulated_pools(v_s.id) then v_chakra-v_need else v_chakra end,gen_random_uuid());
    insert into public.combat_v2_resource_ledger(session_id,round_id,declaration_id,actor_id,resource_kind,expected_amount,committed_amount,applied_amount,is_simulated,idempotency_key)
    values(v_s.id,p_round,v_d.id,v_att.id,case when v_d.kind in ('difesa','nessuna') then 'reazione' else 'azione_principale' end,1,1,case when v_values then 1 else 0 end,not v_values,gen_random_uuid());
    if (v_values or combat_panel_private.uses_simulated_pools(v_s.id)) and v_need>0 then
      update public.combat_v2_actors set mechanics_snapshot=jsonb_set(mechanics_snapshot,'{chakra}',to_jsonb(v_chakra-v_need),false) where id=v_att.id;
      if v_values and v_att.actor_kind='pg' then
        perform set_config('app.allow_chakra_delta','1',true); update public.characters set chakra=chakra-v_need where id=v_att.character_id; perform set_config('app.allow_chakra_delta','0',true);
      end if;
    end if;
  end loop;
  PERFORM clan_akimichi_private.freeze_partial(d.id)
    FROM public.combat_v2_declarations d WHERE d.round_id=p_round
      AND d.sanitized_intent->>'ability_source'='clan'
      AND d.sanitized_intent->>'ability_id'='214af896-15f8-43e6-858b-614d2851dd3b'
      AND d.sanitized_intent#>>'{server_ability,akimichi_partial_contract}'='akimichi-partial/1'
    ORDER BY d.actor_id,d.id;
  -- Once per declaration, after BOTH native ledger entries; same transaction.
  PERFORM clan_hoki_private.needle_settle(d.id,true)
    FROM public.combat_v2_declarations d WHERE d.round_id=p_round
      AND d.sanitized_intent#>>'{server_ability,hoki_needle_version}'='hoki-needle/1'
    ORDER BY d.actor_id,d.id;
  PERFORM clan_sabaku_private.flow_consume_sand(d.id)
    FROM public.combat_v2_declarations d WHERE d.round_id=p_round
      AND d.sanitized_intent#>>'{server_ability,sabaku_flow_version}'='sabaku-flow/2'
    ORDER BY d.actor_id,d.id;
  update public.combat_v2_rounds set phase='risoluzione',state='risoluzione' where id=p_round;
  for v_d in select * from public.combat_v2_declarations where round_id=p_round and kind in ('attacco','movimento','utilita','passa') and state<>'risolta' order by order_no loop
    movement_calc:=NULL;aburame_calc:=NULL;
    select * into v_att from public.combat_v2_actors where id=v_d.actor_id for update;
    if v_d.kind='movimento' then
      if combat_panel_private.has_master_geometry(v_s.id) then
        v_calc:=combat_panel_private.resolve_master_movement(v_d.id,p_request_key);
        update public.combat_v2_declarations set state='risolta',outcome=v_calc where id=v_d.id;
      else
        update public.combat_v2_actors set position_m=greatest(0,least(1000,position_m+(v_d.sanitized_intent->>'move_m')::int)) where id=v_att.id;
        update public.combat_v2_declarations set state='risolta',outcome=jsonb_build_object('movement_m',(v_d.sanitized_intent->>'move_m')::int) where id=v_d.id;
      end if;
    elsif v_d.kind='attacco' then
      elemental_order_ready:=false;
      nara_launch:=combat_panel_private.nara_frozen_launch_v1(v_d.id);
      IF nara_launch IS NOT NULL AND (
        NOT combat_panel_private.nara_launch_resources_match_v1(v_d.actor_id,v_s.id,nara_launch,v_values)
        OR (SELECT count(*) FROM public.combat_v2_attack_targets t WHERE t.attack_declaration_id=v_d.id)<>1
      ) THEN RAISE EXCEPTION 'nara_native_single_target_scope_invalid' USING ERRCODE='55000'; END IF;
      IF v_d.sanitized_intent->>'movement_contract'='combat-panel-movement-attack/1' THEN
        movement_calc:=combat_panel_private.resolve_master_movement(v_d.id,p_request_key);
        IF movement_calc->>'reason_code' IS NOT NULL OR coalesce((movement_calc->>'movement_m')::numeric,0)<=0 THEN
          UPDATE public.combat_v2_declarations SET state='superflua',outcome=jsonb_build_object(
            'reason','movement_attack_unreachable','refund',false,'movement',movement_calc) WHERE id=v_d.id;
          UPDATE public.combat_v2_declarations SET state='risolta',outcome=jsonb_build_object(
            'linked_attack',v_d.id,'reason','movement_attack_unreachable') WHERE parent_attack_id=v_d.id;
          CONTINUE;
        END IF;
      END IF;
      IF v_d.sanitized_intent#>>'{server_ability,hoki_needle_version}'='hoki-needle/1'
        AND clan_hoki_private.needle_finish_blocked(v_d.id,movement_calc) THEN CONTINUE; END IF;
      SELECT * INTO akimichi_partial FROM clan_akimichi_private.partial_sources WHERE declaration_id=v_d.id;
      IF akimichi_partial.declaration_id IS NOT NULL
        AND clan_akimichi_private.partial_finish_blocked(v_d.id,movement_calc) THEN CONTINUE; END IF;
      hyuga_profile:=clan_hyuga_private.sedici_resolve_profile(v_d.id);
      hyuga_juken:=clan_hyuga_private.juken_resolve_profile(v_d.id);
      IF hyuga_profile->>'source_lost'='true' THEN
        PERFORM clan_hyuga_private.sedici_finish_lost(v_d.id); CONTINUE;
      ELSIF hyuga_juken->>'status'='source_lost' THEN
        PERFORM clan_hyuga_private.juken_finish_lost(v_d.id); CONTINUE;
      END IF;
      IF hyuga_profile IS NOT NULL THEN
        v_att.mechanics_snapshot:=v_att.mechanics_snapshot||jsonb_build_object('sedici_profile',hyuga_profile);
        IF hyuga_juken IS NOT NULL THEN RAISE EXCEPTION 'hyuga_profile_stacking_forbidden'; END IF;
      END IF;
      fireball_profile:=clan_uchiha_private.fireball_resolve_profile(v_d.id);
      IF fireball_profile->>'source_lost'='true' THEN PERFORM clan_uchiha_private.fireball_finish_lost(v_d.id);CONTINUE;END IF;
      IF fireball_profile IS NOT NULL THEN v_att.mechanics_snapshot:=v_att.mechanics_snapshot||jsonb_build_object('projectile_fireball',fireball_profile);END IF;

        if v_d.sanitized_intent->>'ability_source'='clan' and v_d.sanitized_intent->>'ability_id'='e361f7c3-f90b-47ec-bfee-ccbda21257d9' then
          begin
            v_calc:=public.combat_v2_clan_genin_marionettisti_resolve_v1(jsonb_build_object('contract_version','marionetta-round-hook/1','declaration_id',v_d.id,'request_key',p_request_key));
            v_att.mechanics_snapshot:=v_att.mechanics_snapshot||jsonb_build_object('marionetta_profile',v_calc->'profile');
          exception when sqlstate '22023' or no_data_found then
            update public.combat_v2_declarations set state='superflua',outcome=jsonb_build_object('reason','marionetta_source_unavailable','refund',false) where id=v_d.id;
            continue;
          end;
        end if;

      if (select count(*) from public.combat_v2_attack_targets where attack_declaration_id=v_d.id)=1
          and not exists(select 1 from public.combat_v2_defense_coverages c join public.combat_v2_attack_targets t on t.id=c.attack_target_id where t.attack_declaration_id=v_d.id and c.mode<>'self') then
      select * into v_tar from public.combat_v2_actors where id=v_d.target_actor_id for update;
      if v_tar.state<>'attivo' then
        update public.combat_v2_declarations set state='superflua',outcome=jsonb_build_object('reason','bersaglio_gia_fuori','refund',false) where id=v_d.id;
      else
        SELECT id INTO STRICT multiplication_target FROM public.combat_v2_attack_targets WHERE attack_declaration_id=v_d.id;
        select * into v_def from public.combat_v2_declarations where parent_attack_id=v_d.id;
        v_reaction:=coalesce(v_def.sanitized_intent->>'reaction','nessuna'); v_meta:=v_d.sanitized_intent->'server_ability';
        SELECT id INTO STRICT multiplication_target FROM public.combat_v2_attack_targets WHERE attack_declaration_id=v_d.id;
        multiplication_facts:=combat_panel_private.multiplication_attack_facts(multiplication_target);
        multiplication_effect:=combat_panel_private.multiplication_effect(multiplication_facts,v_reaction);
        v_reaction:=multiplication_effect->>'effective_reaction';
        -- [MISSION-GUARD-006] Guard locale dopo la lettura concorrente.
        if v_reaction in ('copie','tecnica') AND NOT EXISTS(SELECT 1 FROM clan_hyuga_private.rotation_sources rs WHERE rs.declaration_id=v_def.id) AND NOT combat_v2_elemental_internal.scudo_source_valid(v_def.id) AND NOT clan_aburame_private.clone_source_valid(v_def.id) then
          perform public.combat_v2_fail('profilo_runtime_non_disponibile','La difesa speciale non ha un resolver V2 attivo.',409,p_request_key,'{}');
        end if;
        v_kind:=lower(coalesce(v_meta->>'kind','fisico')); if v_kind not in ('fisico','ninjutsu','genjutsu') then v_kind:='fisico'; end if;
        v_base:=coalesce((v_d.cost_snapshot->>'damage_base')::int,0);
        v_rng_context:='combat-v2/r3/attack:'||v_s.id::text||':'||p_round::text||':'||v_d.id::text;
        v_entropy:=extensions.gen_random_bytes(32);
        v_a1:=public.combat_v2_derive_d10(v_entropy,v_rng_context,1); v_a2:=public.combat_v2_derive_d10(v_entropy,v_rng_context,2);
        v_d1:=public.combat_v2_derive_d10(v_entropy,v_rng_context,3); v_d2:=public.combat_v2_derive_d10(v_entropy,v_rng_context,4);
        v_dice_a:=v_a1+v_a2; v_dice_d:=v_d1+v_d2;
        fb_defense_snapshot:=combat_facing_private.defense_snapshot(v_d.id,multiplication_target,v_def.actor_id,clan_aburame_private.clone_defense_snapshot(v_def.id,clan_hyuga_private.rotation_defense_snapshot(v_def.id,clan_marionettisti_private.defense_snapshot(v_def.actor_id,v_tar.id,v_reaction))),v_reaction);
        IF nara_launch IS NOT NULL AND (
          hyuga_juken IS NOT NULL OR hyuga_profile IS NOT NULL OR fireball_profile IS NOT NULL
          OR v_kind<>'ninjutsu' OR v_base<>0
        ) THEN RAISE EXCEPTION 'nara_native_profile_conflict' USING ERRCODE='55000'; END IF;
        v_calc:=clan_inuzuka_private.attack_calculate(v_d.id,hyuga_juken->'profile',v_kind,
          CASE WHEN nara_launch IS NULL THEN v_att.mechanics_snapshot ELSE
            v_att.mechanics_snapshot||jsonb_build_object('mente',nara_launch->'kg','ninjutsu',nara_launch->'ninjutsu') END,
          fb_defense_snapshot,v_reaction,
          coalesce(v_def.sanitized_intent->'server_ability'->>'kind','taijutsu'),v_base,v_meta->>'element',v_dice_a,v_dice_d,(multiplication_effect->>'assault_bonus')::integer,clan_inuzuka_private.defense_guardia(v_def.sanitized_intent),false);
        IF akimichi_partial.declaration_id IS NOT NULL THEN
          v_calc:=clan_akimichi_private.partial_rebase_native(
            v_calc,akimichi_partial.kg,akimichi_partial.taijutsu,akimichi_partial.mass);
          v_base:=v_base+akimichi_partial.mass;
        END IF;
        v_calc:=clan_akimichi_private.form_impact(v_d.id,v_def.actor_id,v_tar.id,v_kind,v_reaction,
          coalesce(v_def.sanitized_intent#>>'{server_ability,kind}','taijutsu'),v_calc);
        v_base:=v_base+coalesce((v_calc#>>'{akimichi_form,body_mass}')::integer,0);
        IF nara_launch IS NOT NULL THEN
          v_calc:=v_calc||jsonb_build_object('off',nara_launch->'power',
            'danno_grezzo',0,'danno_applicato',0,'striscio',false,'cap_attivo',false);
        END IF;
        v_calc:=v_calc||jsonb_build_object('mod_assalto',multiplication_effect->'assault_bonus','mod_mira',0);
        v_rng:=combat_v2_private.rng_seal(v_s.id,p_round,v_d.id,'attack',v_rng_context,v_entropy,
          jsonb_build_object(
            'dice_attack',jsonb_build_array(v_a1,v_a2),
            'dice_defense',jsonb_build_array(v_d1,v_d2),
            'pools',jsonb_build_object('attack',v_calc->'pool_att','defense',v_calc->'pool_dif'),
            'modifiers',jsonb_build_object(
              'mira',v_calc->'mod_mira','assalto',v_calc->'mod_assalto','guardia',v_calc->'mod_guardia','colto',v_calc->'mod_colto',
              'slancio',v_calc->'mod_slancio','element_attack',v_calc->'mod_elem_att','element_defense',v_calc->'mod_elem_dif'),
            'totals',jsonb_build_object('attack',v_calc->'atk_tot','defense',v_calc->'def_tot','margin',v_calc->'margine')
          ));
        select coalesce((select value from public.combat_v2_ratings where declaration_id=v_d.id and is_active order by created_at desc limit 1),0) into v_vote_a;
        select coalesce((select value from public.combat_v2_ratings where declaration_id=v_def.id and is_active order by created_at desc limit 1),0) into v_vote_d;
        v_corr:=greatest(-3,least(3,v_vote_a-CASE WHEN (multiplication_effect->>'defense_spent_on_copy')::boolean THEN 0 ELSE v_vote_d END)); v_raw:=(v_calc->>'margine')::int;
        if v_reaction='sostituzione' then v_corr:=0; end if;
        v_final:=v_raw+v_corr+coalesce((v_calc->>'mod_risonanza')::integer,0);
        -- B4: la claim modifica soltanto la soglia; il margine danno resta nativo.
        elemental_claim:=combat_v2_elemental_internal.comparison_reserve(v_d.id,multiplication_target,v_def.id);
        elemental_channels:=NULL;
        IF elemental_claim IS NOT NULL THEN
          elemental_channels:=combat_v2_elemental_internal.comparison_channels(
            v_d.id,multiplication_target,v_def.id,v_calc,v_corr,(elemental_claim->>'event_id')::uuid);
          v_final:=(elemental_channels->>'hit_margin')::integer;
          v_calc:=v_calc||jsonb_build_object('elemental_comparison',elemental_channels);
          v_calc:=v_calc||jsonb_build_object('common_effects',
            coalesce(v_calc->'common_effects','{}'::jsonb)||(elemental_channels->'common_effects'));
        END IF;
        IF NOT coalesce((multiplication_effect->>'copy_intercepted')::boolean,false) AND NOT coalesce((multiplication_effect->>'defense_spent_on_copy')::boolean,false) THEN
          elemental_channels:=combat_v2_elemental_internal.other_comparison(v_d.id,v_def.id,v_calc,v_final);
          v_final:=(elemental_channels->>'hit_margin')::integer;v_calc:=elemental_channels->'calculation';
        END IF;
        if (multiplication_effect->>'copy_intercepted')::boolean or v_reaction='sostituzione' or v_kind='genjutsu' and v_final<0 or v_reaction='copie' and v_final<0 then v_damage:=0;
        elsif v_final<0 then v_damage:=greatest(1,greatest(1,v_base+((v_calc->>'off')::int/4)-(v_calc->>'riduzione')::int)/4);
        else
          v_full:=greatest(1,v_base+((v_calc->>'off')::int/4)+coalesce((v_calc->>'bonus_margine')::int,0)-(v_calc->>'riduzione')::int);
          v_damage:=least(65,v_full);
        end if;
        flow_calc:=NULL;
        IF v_meta->>'sabaku_flow_version'='sabaku-flow/2' THEN
          flow_calc:=clan_sabaku_private.flow_resolve_calculation(v_d.id,v_tar.id,v_calc,v_corr,
            coalesce((multiplication_effect->>'copy_intercepted')::boolean,false),v_reaction='sostituzione');
          v_final:=(flow_calc->>'hit_margin')::integer;v_damage:=(flow_calc->>'damage_applied')::integer;
          v_calc:=v_calc||jsonb_build_object('sabaku_flow',flow_calc,'off',flow_calc->'power',
            'bonus_margine',flow_calc->'damage_margin_bonus','danno_grezzo',flow_calc->'full_damage_uncapped',
            'danno_applicato',flow_calc->'damage_applied','colpito',flow_calc->'success','striscio',flow_calc->'striscio');
        END IF;
        IF akimichi_partial.declaration_id IS NOT NULL THEN
          v_calc:=clan_akimichi_private.partial_damage(v_calc,v_final,v_reaction='sostituzione'
            OR coalesce((multiplication_effect->>'copy_intercepted')::boolean,false));
          v_damage:=(v_calc->>'danno_applicato')::integer;
        END IF;
        -- B5: credito originario dopo il danno nativo, prima di Rotazione/armatura/PV.
        IF nara_launch IS NOT NULL THEN v_damage:=0; END IF;
        elemental_cap:=combat_effects_private.capture_source_cap(v_d.id,v_damage);
        IF elemental_cap<>'{}'::jsonb THEN
          v_calc:=v_calc||jsonb_build_object('common_effects',
            coalesce(v_calc->'common_effects','{}'::jsonb)||elemental_cap);
        END IF;
        IF clan_aburame_private.release_source_valid(v_d.id) THEN
          aburame_calc:=clan_aburame_private.release_resolve(v_d.id,v_tar.id,v_calc,v_final,
            v_reaction<>'sostituzione' AND NOT coalesce((multiplication_effect->>'copy_intercepted')::boolean,false));
          v_damage:=0;v_calc:=v_calc||jsonb_build_object('aburame_release',aburame_calc,'danno_applicato',0,'striscio',false);
        END IF;
        rotation_calc:=clan_hyuga_private.rotation_calculate(v_def.id,v_calc,v_final,v_base);
        IF rotation_calc IS NOT NULL THEN
          v_damage:=(rotation_calc->>'damage_after')::integer;
          v_calc:=v_calc||jsonb_build_object('hyuga_rotation',rotation_calc,'danno_applicato',v_damage,'striscio',false);
        END IF;
        IF clan_aburame_private.clone_source_valid(v_def.id) THEN
          aburame_calc:=clan_aburame_private.clone_resolve(v_def.id,v_calc,v_final,v_base,p_request_key);
          v_damage:=(aburame_calc->>'damage_after')::integer;
          v_calc:=v_calc||jsonb_build_object('aburame_clone',aburame_calc,'danno_applicato',v_damage,'striscio',false);
        END IF;
        IF aburame_calc->>'version'='aburame-release/1' THEN
          v_damage:=0;v_calc:=v_calc||jsonb_build_object('danno_applicato',0,'striscio',false);
        END IF;
        IF akimichi_partial.declaration_id IS NOT NULL AND (
          v_final<=0 OR v_reaction='sostituzione' OR coalesce((multiplication_effect->>'copy_intercepted')::boolean,false)
        ) THEN
          v_damage:=0;
          v_calc:=v_calc||jsonb_build_object('danno_applicato',0,'striscio',false,'colpito',false);
          IF rotation_calc IS NOT NULL THEN
            rotation_calc:=rotation_calc||jsonb_build_object('damage_after',0);
            v_calc:=v_calc||jsonb_build_object('hyuga_rotation',rotation_calc);
          END IF;
          IF aburame_calc->>'version'='aburame-clone/1' THEN
            aburame_calc:=aburame_calc||jsonb_build_object('damage_after',0);
            v_calc:=v_calc||jsonb_build_object('aburame_clone',aburame_calc);
          END IF;
        END IF;
        IF nara_launch IS NOT NULL OR v_d.sanitized_intent->'target_fili'='true'::jsonb THEN
          v_damage:=0;
          v_calc:=v_calc||jsonb_build_object('danno_grezzo',0,'danno_applicato',0,'striscio',false,'cap_attivo',false);
        END IF;
        v_calc:=v_calc||jsonb_build_object('sabaku_armor',clan_sabaku_private.armor_absorb(multiplication_target,v_damage));
        v_damage:=(v_calc#>>'{sabaku_armor,damage_after}')::integer;
        IF NOT (v_calc->'sabaku_armor' ? 'version') THEN v_calc:=v_calc-'sabaku_armor'; END IF;
        v_new_hp:=greatest(0,coalesce((v_tar.mechanics_snapshot->>'vita')::int,0)-v_damage);
        update public.combat_v2_actors set mechanics_snapshot=jsonb_set(mechanics_snapshot,'{vita}',to_jsonb(v_new_hp),false),state=case when v_new_hp=0 then 'fuori' else state end where id=v_tar.id;
        if v_values and v_tar.actor_kind='pg' and v_damage>0 then
          perform set_config('app.allow_vita_delta','1',true); update public.characters set vita=v_new_hp where id=v_tar.character_id; perform set_config('app.allow_vita_delta','0',true);
        end if;
        update public.combat_v2_actors set mechanics_snapshot=jsonb_set(mechanics_snapshot,'{slancio}',to_jsonb(CASE WHEN (CASE WHEN akimichi_partial.declaration_id IS NOT NULL THEN (v_calc->>'colpito')::boolean
           ELSE v_final>=0 AND NOT (multiplication_effect->>'copy_intercepted')::boolean END)
          THEN 0 ELSE least(9,coalesce((mechanics_snapshot->>'slancio')::int,0)+3) END),true) where id=v_att.id;
        elemental_order_outcome:=jsonb_build_object('raw',v_calc,'rng_audit',v_rng,'rating_attack',v_vote_a,'rating_defense',v_vote_d,
          'quality_correction',v_corr,'quality_applicable',v_reaction<>'sostituzione','threshold_margin',v_final,'success',CASE WHEN akimichi_partial.declaration_id IS NOT NULL THEN (v_calc->>'colpito')::boolean
            ELSE v_final>=0 AND v_reaction<>'sostituzione' AND NOT (multiplication_effect->>'copy_intercepted')::boolean END,
          'damage_applied',v_damage,'target_hp_after',v_new_hp,'ko',v_new_hp=0,'copies_outcome',case when v_reaction='copie' and v_final<0 then 'copia_colpita' when v_reaction='copie' then 'originale_individuato' end)||CASE WHEN jsonb_array_length(multiplication_facts)>0 THEN jsonb_build_object(
            'multiplication',multiplication_facts,'multiplication_effect',multiplication_effect) ELSE '{}'::jsonb END;
        IF v_d.sanitized_intent->'target_fili'='true'::jsonb THEN
          v_fili_hit:=coalesce((elemental_order_outcome->>'success')::boolean,false)
            AND clan_marionettisti_private.ocular_sever_frozen_valid_v1(v_d.id);
          elemental_order_outcome:=elemental_order_outcome||jsonb_build_object('success',v_fili_hit,'fili_recisi',v_fili_hit);
        END IF;
        IF movement_calc IS NOT NULL THEN
          elemental_order_outcome:=elemental_order_outcome||jsonb_build_object('movement',movement_calc);
        END IF;
        -- Prima della principale terminale: child definitivo e settlement di tutte le conseguenze.
        FOR elemental_target IN SELECT t.id FROM public.combat_v2_attack_targets t
          WHERE t.attack_declaration_id=v_d.id AND t.round_id=p_round
           AND (SELECT count(*) FROM public.combat_v2_attack_targets x WHERE x.attack_declaration_id=v_d.id)=1
           AND NOT EXISTS(SELECT 1 FROM public.combat_v2_defense_coverages c JOIN public.combat_v2_attack_targets x ON x.id=c.attack_target_id
             WHERE x.attack_declaration_id=v_d.id AND c.mode<>'self') ORDER BY t.id LOOP
          IF nara_launch IS NOT NULL THEN
            nara_facts:=combat_panel_private.nara_record_control_v1(elemental_target,elemental_order_outcome);
            elemental_order_outcome:=elemental_order_outcome||jsonb_build_object('nara_possession',nara_facts);
          END IF;
          UPDATE public.combat_v2_attack_targets SET state='risolta',outcome=elemental_order_outcome WHERE id=elemental_target;
          PERFORM combat_effects_private.settle_native_target(v_d.id,elemental_target);
        END LOOP;
        UPDATE public.combat_v2_declarations SET state='risolta',outcome=elemental_order_outcome WHERE id=v_d.id;
        IF NOT EXISTS(SELECT 1 FROM public.combat_v2_attack_targets WHERE attack_declaration_id=v_d.id)
          AND v_d.sanitized_intent#>>'{server_ability,hoki_needle_version}'='hoki-needle/1'
        THEN PERFORM clan_hoki_private.needle_result(v_d.id,NULL); END IF;
        IF NOT EXISTS(SELECT 1 FROM public.combat_v2_attack_targets WHERE attack_declaration_id=v_d.id)
        THEN PERFORM clan_hoki_private.body_contact(v_d.id,NULL); END IF;
        elemental_order_ready:=true;
        PERFORM combat_panel_private.multiplication_attack_finish(multiplication_target);
        update public.combat_v2_declarations set state='risolta',outcome=jsonb_build_object('linked_attack',v_d.id)||CASE WHEN rotation_calc IS NULL THEN '{}'::jsonb ELSE jsonb_build_object('hyuga_rotation',rotation_calc) END where id=v_def.id;
      end if;
      else
        v_calc:=combat_v2_multitarget_internal.resolve_parent(v_s.id,p_round,v_d.id,v_values);
      end if;

      IF movement_calc IS NOT NULL AND NOT elemental_order_ready THEN
        UPDATE public.combat_v2_declarations SET outcome=coalesce(outcome,'{}'::jsonb)||jsonb_build_object('movement',movement_calc) WHERE id=v_d.id;
      END IF;

      PERFORM clan_hyuga_private.rotation_finish(v_d.id,p_request_key);
    elsif v_d.kind='utilita' AND EXISTS(SELECT 1 FROM clan_sabaku_private.clone_plans WHERE declaration_id=v_d.id) THEN
      v_calc:=clan_sabaku_private.clone_resolve_creation(v_d.id);
      update public.combat_v2_declarations set state='risolta',outcome=v_calc where id=v_d.id;
    elsif v_d.kind='utilita' AND EXISTS(SELECT 1 FROM combat_panel_private.immobilization_escape_plans WHERE declaration_id=v_d.id) THEN
      v_calc:=combat_panel_private.immobilization_resolve_escape(v_d.id);
      update public.combat_v2_declarations set state='risolta',outcome=v_calc where id=v_d.id;
    elsif v_d.kind='utilita' AND v_d.sanitized_intent#>>'{server_ability,aburame_escape_source}' IS NOT NULL THEN
      v_calc:=clan_aburame_private.escape_resolve(v_d.id);
      update public.combat_v2_declarations set state='risolta',outcome=jsonb_build_object('aburame_escape',v_calc) where id=v_d.id;
    else update public.combat_v2_declarations set state='risolta',outcome=jsonb_build_object('kind',v_d.kind) where id=v_d.id;
    end if;
  end loop;
  -- SINGLE_SURFACE_SYNC_R6
  update public.combat_v2_attack_targets t set
    state=case when d.state='superflua'then'superflua'else'risolta'end,
    outcome=d.outcome
  from public.combat_v2_declarations d
  where d.id=t.attack_declaration_id and t.round_id=p_round
    and d.state in('risolta','superflua')
    and (select count(*)from public.combat_v2_attack_targets x where x.attack_declaration_id=d.id)=1
    and not exists(select 1 from public.combat_v2_defense_coverages c join public.combat_v2_attack_targets x on x.id=c.attack_target_id where x.attack_declaration_id=d.id and c.mode<>'self');
  update public.combat_v2_defense_coverages c set state='risolta'
  from public.combat_v2_attack_targets t,public.combat_v2_declarations d,public.combat_v2_declarations a
  where c.attack_target_id=t.id and c.defense_declaration_id=d.id and t.attack_declaration_id=a.id
    and c.round_id=p_round and d.state='risolta'and a.state in('risolta','superflua')
    and (select count(*)from public.combat_v2_attack_targets x where x.attack_declaration_id=a.id)=1
    and not exists(select 1 from public.combat_v2_defense_coverages z join public.combat_v2_attack_targets x on x.id=z.attack_target_id where x.attack_declaration_id=a.id and z.mode<>'self');
  FOR elemental_target IN SELECT t.id FROM public.combat_v2_attack_targets t
    WHERE t.round_id=p_round AND t.state IN ('risolta','superflua') ORDER BY t.id LOOP
    PERFORM combat_effects_private.settle_native_target(
      (SELECT attack_declaration_id FROM public.combat_v2_attack_targets WHERE id=elemental_target),elemental_target);
  END LOOP;
  -- SINGLE_SURFACE_SYNC_R6 has persisted the final native target result.
  FOR sedici_target IN SELECT t.id FROM public.combat_v2_attack_targets t
    JOIN clan_hyuga_private.sedici_sources src ON src.declaration_id=t.attack_declaration_id
    WHERE t.round_id=p_round ORDER BY t.id LOOP
    PERFORM clan_hyuga_private.sedici_apply_result(sedici_target);
  END LOOP;
  effects_lifecycle:=combat_effects_private.lifecycle_before_report(p_round);
  v_after:=(select jsonb_agg(jsonb_build_object('actor',a.id,'state',a.state,'position_m',a.position_m,'mechanics',a.mechanics_snapshot) order by a.id) from public.combat_v2_actors a where a.session_id=v_s.id);
  v_report:=jsonb_build_object('initial_actors',v_before,'final_actors',v_after,'effects_lifecycle',effects_lifecycle,
    'hyuga_effects',clan_hyuga_private.sedici_round_facts(p_round),
    'declarations',(select jsonb_agg(jsonb_build_object('id',d.id,'actor',d.actor_id,'kind',d.kind,'target',d.target_actor_id,'parent',d.parent_attack_id,'order',d.order_no,'state',d.state,'cost',d.cost_snapshot||jsonb_build_object('chakra',clan_hyuga_private.sedici_frozen_cost(d.actor_id,d.cost_snapshot)),'outcome',d.outcome,'scudo_facts',CASE WHEN d.kind='difesa' AND d.state='risolta' AND combat_v2_elemental_internal.scudo_source_valid(d.id) THEN combat_v2_elemental_internal.scudo_narrative(d.id) ELSE '{}'::jsonb END,'elemental_facts',CASE WHEN combat_v2_elemental_internal.other_narrative_supported(d.id) THEN combat_v2_elemental_internal.other_narrative_projection(d.id) ELSE '{}'::jsonb END,'suiton_facts',CASE WHEN combat_v2_elemental_internal.suiton_narrative_supported(d.id)
      THEN combat_v2_elemental_internal.suiton_narrative_projection(d.id)||jsonb_build_object(
        'target_actor_id',(SELECT s.target_actor_id FROM combat_v2_elemental_internal.suiton_sources s WHERE s.declaration_id=d.id))
      ELSE NULL END) order by d.order_no nulls last,d.id) from public.combat_v2_declarations d where d.round_id=p_round),
    'attack_targets',(select jsonb_agg(to_jsonb(t) order by t.attack_declaration_id,t.ordinal)from public.combat_v2_attack_targets t where t.round_id=p_round),'defense_coverages',(select jsonb_agg(to_jsonb(c)order by c.defense_declaration_id,c.id)from public.combat_v2_defense_coverages c where c.round_id=p_round),'ledger',(select jsonb_agg(clan_marionettisti_private.ledger_wire(l) order by l.created_at,l.id) from public.combat_v2_resource_ledger l where l.round_id=p_round),
    'rng_order',v_order_rng,'rng_scheme','hmac-sha256-jsonb-pg17/1',
    'substitution_receipts',coalesce((select jsonb_agg(jsonb_build_object('event_id',e.event_id,'event_kind',e.event_kind,'source_application_id',e.root_id,'round_id',l.activity_round_id,'instance_id',e.instance_id,'actor_id',e.actor_id,'narrator_payload',e.narrator_payload) order by e.created_at,e.event_id) from combat_spatial.spatial_events e join combat_spatial.substitution_activity_links l on l.activity_kind='combat_v2' and l.activity_round_id=p_round and l.attack_declaration_id=e.root_id and l.instance_id=e.instance_id and l.defender_actor_id=e.actor_id and l.state='committed' where e.event_kind='substitution_committed'),'[]'::jsonb),'values_written',v_values,'engine_version',v_r.engine_version,'resolver_version',v_r.resolver_version,'order_version',v_r.order_version,'quality_version',v_r.quality_version);
  IF EXISTS(SELECT 1 FROM clan_sabaku_private.flow_sources WHERE round_id=p_round) THEN
    v_report:=v_report||jsonb_build_object('sabaku_flows',clan_sabaku_private.flow_round_facts(p_round));
  END IF;
  IF EXISTS(SELECT 1 FROM clan_sabaku_private.armor_events WHERE round_id=p_round AND event_kind='hit') THEN
    v_report:=v_report||jsonb_build_object('sabaku_armor',clan_sabaku_private.armor_round_facts(p_round));
  END IF;
  IF EXISTS(SELECT 1 FROM combat_panel_private.multiplication_diversivo_receipts WHERE round_id=p_round) THEN
    v_report:=v_report||jsonb_build_object('multiplication_tactics_contract','multiplication-resume/1',
      'multiplication_diversivo',(SELECT jsonb_agg(lure_receipt.result ORDER BY lure_receipt.attack_target_id,lure_receipt.formation_id)
        FROM combat_panel_private.multiplication_diversivo_receipts lure_receipt WHERE lure_receipt.round_id=p_round));
  END IF;
  IF EXISTS(SELECT 1 FROM clan_hoki_private.combat_events e WHERE e.round_id=p_round) THEN
    v_report:=v_report||jsonb_build_object('hoki_facts',clan_hoki_private.round_facts(p_round));
  END IF;
  v_report:=exam_human_private.round_facts_capture_v1(p_round,v_report);
  v_sha:=public.combat_v2_sha256(v_report);
  insert into public.combat_v2_round_reports(round_id,mechanics,mechanics_sha256,values_written,engine_version,resolver_version,order_version,quality_version)
  values(p_round,v_report,v_sha,v_values,v_r.engine_version,v_r.resolver_version,v_r.order_version,v_r.quality_version) returning id into v_report_id;
  update public.combat_v2_rounds set phase='risolto',state='risolto',resolved_at=clock_timestamp(),report_id=v_report_id where id=p_round;
  if clan_marionettisti_private.is_dedicated_scene(v_s.id) then perform clan_marionettisti_private.settle_round_damage(v_report_id); perform clan_inuzuka_private.settle_round_damage(v_report_id);end if;
  v_result:=public.combat_v2_envelope(p_request_key,jsonb_build_object('report_id',v_report_id,'report_sha256',v_sha,'mechanics',v_report));
  return public.combat_v2_event_complete(v_event_id,v_result);
end $function$;

CREATE OR REPLACE FUNCTION combat_v2_multitarget_internal.resolve_parent(p_session uuid, p_round uuid, p_attack uuid, p_values boolean)
 RETURNS jsonb
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO ''
AS $function$
declare elemental_claim jsonb; elemental_channels jsonb; elemental_cap jsonb; fireball_profile jsonb; hyuga_profile jsonb; hyuga_juken jsonb; multiplication_facts jsonb; multiplication_effect jsonb; d public.combat_v2_declarations%rowtype;att public.combat_v2_actors%rowtype;tar public.combat_v2_actors%rowtype;defender public.combat_v2_actors%rowtype;
 t public.combat_v2_attack_targets%rowtype;c public.combat_v2_defense_coverages%rowtype;def public.combat_v2_declarations%rowtype;
 meta jsonb;calc jsonb;rng jsonb;parent_entropy bytea;entropy bytea;ctx text;reaction text;kind text;base int;
 shared_a1 int;shared_a2 int;a1 int;a2 int;d1 int;d2 int;vote_a int;vote_d int;corr int;raw int;final int;full_damage int;damage int;hp int;
 any_success boolean:=false;children jsonb:='[]';child_outcome jsonb;receipt text;old_slancio int;
 fili_hit boolean:=false;
 flow_calc jsonb;fb_defense_snapshot jsonb; nara_launch jsonb;
 akimichi_partial clan_akimichi_private.partial_sources%rowtype;
begin
 select*into strict d from public.combat_v2_declarations where id=p_attack and round_id=p_round for update;
 nara_launch:=combat_panel_private.nara_frozen_launch_v1(d.id);
 IF nara_launch IS NOT NULL AND (
  NOT combat_panel_private.nara_launch_resources_match_v1(d.actor_id,p_session,nara_launch,p_values)
  OR (SELECT count(*) FROM public.combat_v2_attack_targets x WHERE x.attack_declaration_id=d.id)<>1
 ) THEN RAISE EXCEPTION 'nara_native_single_target_scope_invalid' USING ERRCODE='55000'; END IF;
 select*into strict att from public.combat_v2_actors where id=d.actor_id for update;
 SELECT * INTO akimichi_partial FROM clan_akimichi_private.partial_sources WHERE declaration_id=d.id;
 if d.sanitized_intent->>'ability_source'='clan' and d.sanitized_intent->>'ability_id'='e361f7c3-f90b-47ec-bfee-ccbda21257d9' then
  if (select count(*) from public.combat_v2_attack_targets where attack_declaration_id=d.id)<>1 then raise exception 'marionetta_single_target_required' using errcode='22023';end if;
  calc:=public.combat_v2_clan_genin_marionettisti_resolve_v1(jsonb_build_object('contract_version','marionetta-round-hook/1','declaration_id',d.id,'request_key',d.id));
  att.mechanics_snapshot:=att.mechanics_snapshot||jsonb_build_object('marionetta_profile',calc->'profile');
 end if;
 hyuga_profile:=clan_hyuga_private.sedici_resolve_profile(d.id);
 hyuga_juken:=clan_hyuga_private.juken_resolve_profile(d.id);
 IF hyuga_profile->>'source_lost'='true' THEN
  PERFORM clan_hyuga_private.sedici_finish_lost(d.id); RETURN jsonb_build_object('source_lost',true);
 ELSIF hyuga_juken->>'status'='source_lost' THEN
  PERFORM clan_hyuga_private.juken_finish_lost(d.id); RETURN jsonb_build_object('source_lost',true);
 END IF;
 IF hyuga_profile IS NOT NULL THEN
  IF hyuga_juken IS NOT NULL THEN RAISE EXCEPTION 'hyuga_profile_stacking_forbidden'; END IF;
  att.mechanics_snapshot:=att.mechanics_snapshot||jsonb_build_object('sedici_profile',hyuga_profile);
 END IF;

      fireball_profile:=clan_uchiha_private.fireball_resolve_profile(d.id);
      IF fireball_profile->>'source_lost'='true' THEN PERFORM clan_uchiha_private.fireball_finish_lost(d.id);RETURN fireball_profile;END IF;
      IF fireball_profile IS NOT NULL THEN att.mechanics_snapshot:=att.mechanics_snapshot||jsonb_build_object('projectile_fireball',fireball_profile);END IF;
 meta:=d.sanitized_intent->'server_ability';base:=coalesce((d.cost_snapshot->>'damage_base')::int,0);
 select coalesce((select value from public.combat_v2_ratings where declaration_id=d.id and is_active order by created_at desc limit 1),0)into vote_a;
 old_slancio:=coalesce((att.mechanics_snapshot->>'slancio')::int,0);
 parent_entropy:=extensions.gen_random_bytes(32);
 IF fireball_profile IS NOT NULL THEN
  shared_a1:=public.combat_v2_derive_d10(parent_entropy,'fireball-parent:'||d.id::text,1);
  shared_a2:=public.combat_v2_derive_d10(parent_entropy,'fireball-parent:'||d.id::text,2);
 END IF;
 for t in select*from public.combat_v2_attack_targets where attack_declaration_id=d.id order by ordinal for update loop
  select*into strict c from public.combat_v2_defense_coverages where attack_target_id=t.id for update;
  select*into strict def from public.combat_v2_declarations where id=c.defense_declaration_id for update;
  select*into strict defender from public.combat_v2_actors where id=def.actor_id for update;
  select*into strict tar from public.combat_v2_actors where id=t.target_actor_id for update;
  if (case when combat_panel_private.has_master_geometry(p_session)
    then not combat_panel_private.controller_version_valid(tar.id,t.target_controller_version)
    else tar.controller_version is distinct from t.target_controller_version end) then raise exception 'targeting_geometry_stale';end if;
  if (case when combat_panel_private.has_master_geometry(p_session)
    then not combat_panel_private.controller_version_valid(defender.id,c.defender_controller_version,def.controller_user_snapshot)
    else defender.controller_version is distinct from c.defender_controller_version end) then raise exception 'defender_controller_stale';end if;
  if c.mode<>'self'and(case when combat_panel_private.has_master_geometry(p_session)
     then not combat_panel_private.coverage_geometry_valid(c.id,defender.id)
     else abs(defender.position_m-tar.position_m)>2
       or tar.position_m is distinct from c.protected_position_m end)then raise exception 'targeting_geometry_stale';end if;
  IF meta->>'sabaku_flow_version'='sabaku-flow/2' AND t.state='risolta' THEN
   -- A native substitution already resolved this target before the parent ledger.
   -- Validate its committed receipt and preserve it; never roll or charge it twice.
   IF t.outcome->>'canonical_outcome' IS DISTINCT FROM 'negato_sostituzione'
    OR t.outcome->'damage_applied' IS DISTINCT FROM '0'::jsonb OR t.outcome->'success' IS DISTINCT FROM 'false'::jsonb
    OR t.outcome->>'attack_target_id' IS DISTINCT FROM t.id::text
    OR t.outcome->>'defender_actor_id' IS DISTINCT FROM tar.id::text
    OR t.outcome->>'defense_declaration_id' IS DISTINCT FROM def.id::text
    OR def.sanitized_intent->>'reaction' IS DISTINCT FROM 'sostituzione'
    OR def.outcome->>'canonical_outcome' IS DISTINCT FROM 'negato_sostituzione'
    OR def.outcome->>'substitution_link' IS DISTINCT FROM t.outcome->>'substitution_link'
    OR NOT EXISTS(SELECT 1 FROM clan_sabaku_private.flow_sources fs
      JOIN clan_sabaku_private.flow_consumptions fc ON fc.declaration_id=fs.declaration_id AND fc.source_sha256=fs.source_sha256
      WHERE fs.declaration_id=d.id AND fs.source_sha256=t.outcome->>'flow_source_sha256'
        AND fs.source_sha256=clan_sabaku_private.flow_source_hash(fs))
    OR NOT EXISTS(SELECT 1 FROM combat_spatial.substitution_activity_links sl
      JOIN combat_spatial.substitution_activity_options so ON so.link_id=sl.link_id
      JOIN combat_spatial.spatial_events se ON se.instance_id=sl.instance_id AND se.actor_id=sl.defender_actor_id
      WHERE sl.activity_round_id=p_round AND sl.attack_declaration_id=d.id AND sl.defender_actor_id=tar.id
        AND sl.state='committed' AND so.state='committed' AND so.selected_defense_declaration_id=def.id
        AND se.event_id=(t.outcome->>'substitution_link')::uuid AND se.event_kind='substitution_committed'
        AND se.root_id=d.id AND se.narrator_payload#>>'{impact,outcome}'='negato_sostituzione') THEN
     RAISE EXCEPTION 'flow_substitution_committed_receipt_invalid' USING ERRCODE='40001'; END IF;
   children:=children||jsonb_build_array(t.outcome);
   CONTINUE;
  END IF;
  if tar.state<>'attivo'then
   child_outcome:=jsonb_build_object('success',false,'damage_applied',0,'reason','bersaglio_gia_fuori','child_ordinal',t.ordinal);
   update public.combat_v2_attack_targets set state='superflua',outcome=child_outcome where id=t.id;
  else
   reaction:=coalesce(def.sanitized_intent->>'reaction','nessuna');
   multiplication_facts:=combat_panel_private.multiplication_attack_facts(t.id);
   multiplication_effect:=combat_panel_private.multiplication_effect(multiplication_facts,reaction);
   reaction:=multiplication_effect->>'effective_reaction';kind:=lower(coalesce(meta->>'kind','fisico'));if kind not in('fisico','ninjutsu','genjutsu')then kind:='fisico';end if;
   ctx:='combat-v2/r3/multi-child:'||p_session::text||':'||p_round::text||':'||d.id::text||':'||t.id::text;
   -- Un solo seal parent nel ledger RNG esistente; l'entropia child e' derivata
   -- su un dominio distinto target/ordinale, quindi ogni child ha dadi indipendenti.
   entropy:=extensions.hmac(convert_to(ctx,'UTF8'),parent_entropy,'sha256');
   IF fireball_profile IS NOT NULL THEN a1:=shared_a1;a2:=shared_a2;ELSE a1:=public.combat_v2_derive_d10(entropy,ctx,1);a2:=public.combat_v2_derive_d10(entropy,ctx,2);END IF;d1:=public.combat_v2_derive_d10(entropy,ctx,3);d2:=public.combat_v2_derive_d10(entropy,ctx,4);
   fb_defense_snapshot:=combat_facing_private.defense_snapshot(p_attack,t.id,defender.id,case when tar.companion_id is not null then clan_marionettisti_private.defense_snapshot(defender.id,tar.id,reaction) else defender.mechanics_snapshot end,reaction);
   IF nara_launch IS NOT NULL AND (
     hyuga_juken IS NOT NULL OR hyuga_profile IS NOT NULL OR fireball_profile IS NOT NULL
     OR kind<>'ninjutsu' OR base<>0
   ) THEN RAISE EXCEPTION 'nara_native_profile_conflict' USING ERRCODE='55000'; END IF;
   calc:=clan_inuzuka_private.attack_calculate(p_attack,hyuga_juken->'profile',kind,
    CASE WHEN nara_launch IS NULL THEN att.mechanics_snapshot ELSE
      att.mechanics_snapshot||jsonb_build_object('mente',nara_launch->'kg','ninjutsu',nara_launch->'ninjutsu') END,
    fb_defense_snapshot,reaction,
    coalesce(def.sanitized_intent->'server_ability'->>'kind','taijutsu'),base,meta->>'element',a1+a2,d1+d2,(multiplication_effect->>'assault_bonus')::integer,clan_inuzuka_private.defense_guardia(def.sanitized_intent),false);
   IF akimichi_partial.declaration_id IS NOT NULL THEN
     calc:=clan_akimichi_private.partial_rebase_native(
       calc,akimichi_partial.kg,akimichi_partial.taijutsu,akimichi_partial.mass);
   END IF;
   calc:=clan_akimichi_private.form_impact(d.id,defender.id,tar.id,kind,reaction,
     coalesce(def.sanitized_intent#>>'{server_ability,kind}','taijutsu'),calc);
   IF nara_launch IS NOT NULL THEN
     calc:=calc||jsonb_build_object('off',nara_launch->'power','danno_grezzo',0,
       'danno_applicato',0,'striscio',false,'cap_attivo',false);
   END IF;
   calc:=calc||jsonb_build_object('mod_assalto',multiplication_effect->'assault_bonus','mod_mira',0);
   rng:=jsonb_build_object('scheme','combat-v2-child-derive/1.0','child_id',t.id,
    'commitment',encode(extensions.digest(entropy,'sha256'),'hex'),
    'shared_offensive_roll',fireball_profile IS NOT NULL,'dice_attack',jsonb_build_array(a1,a2),'dice_defense',jsonb_build_array(d1,d2));
   select coalesce((select value from public.combat_v2_ratings where declaration_id=def.id and is_active order by created_at desc limit 1),0)into vote_d;
   corr:=greatest(-3,least(3,vote_a-CASE WHEN (multiplication_effect->>'defense_spent_on_copy')::boolean THEN 0 ELSE vote_d END));raw:=(calc->>'margine')::int;final:=raw+corr+coalesce((calc->>'mod_risonanza')::integer,0);
   -- B4: la claim modifica soltanto la soglia; il margine danno resta nativo.
   elemental_claim:=combat_v2_elemental_internal.comparison_reserve(d.id,t.id,def.id);
   elemental_channels:=NULL;
   IF elemental_claim IS NOT NULL THEN
     elemental_channels:=combat_v2_elemental_internal.comparison_channels(
       d.id,t.id,def.id,calc,corr,(elemental_claim->>'event_id')::uuid);
     final:=(elemental_channels->>'hit_margin')::integer;
     calc:=calc||jsonb_build_object('elemental_comparison',elemental_channels);
     calc:=calc||jsonb_build_object('common_effects',
       coalesce(calc->'common_effects','{}'::jsonb)||(elemental_channels->'common_effects'));
   END IF;
        IF NOT coalesce((multiplication_effect->>'copy_intercepted')::boolean,false) AND NOT coalesce((multiplication_effect->>'defense_spent_on_copy')::boolean,false) THEN
          elemental_channels:=combat_v2_elemental_internal.other_comparison(d.id,def.id,calc,final);
          final:=(elemental_channels->>'hit_margin')::integer;calc:=elemental_channels->'calculation';
        END IF;
   base:=coalesce((d.cost_snapshot->>'damage_base')::int,0)+coalesce((calc#>>'{akimichi_form,body_mass}')::integer,0);
   if (multiplication_effect->>'copy_intercepted')::boolean or (fireball_profile IS NOT NULL AND reaction='sostituzione') or kind='genjutsu'and final<0 then damage:=0;
   elsif final<0 then damage:=greatest(1,greatest(1,base+((calc->>'off')::int/4)-(calc->>'riduzione')::int)/4);
   else full_damage:=greatest(1,base+((calc->>'off')::int/4)+coalesce((calc->>'bonus_margine')::int,0)-(calc->>'riduzione')::int);damage:=least(65,full_damage);end if;
   flow_calc:=NULL;
   IF meta->>'sabaku_flow_version'='sabaku-flow/2' THEN
     flow_calc:=clan_sabaku_private.flow_resolve_calculation(d.id,tar.id,calc,corr,
       coalesce((multiplication_effect->>'copy_intercepted')::boolean,false),reaction='sostituzione');
     final:=(flow_calc->>'hit_margin')::integer;damage:=(flow_calc->>'damage_applied')::integer;
     calc:=calc||jsonb_build_object('sabaku_flow',flow_calc,'off',flow_calc->'power',
       'bonus_margine',flow_calc->'damage_margin_bonus','danno_grezzo',flow_calc->'full_damage_uncapped',
       'danno_applicato',flow_calc->'damage_applied','colpito',flow_calc->'success','striscio',flow_calc->'striscio');
   END IF;
   IF akimichi_partial.declaration_id IS NOT NULL THEN
     calc:=clan_akimichi_private.partial_damage(calc,final,reaction='sostituzione'
       OR coalesce((multiplication_effect->>'copy_intercepted')::boolean,false));
     damage:=(calc->>'danno_applicato')::integer;
   END IF;
   -- B5: credito originario dopo il danno nativo, prima di Rotazione/armatura/PV.
   IF nara_launch IS NOT NULL OR d.sanitized_intent->'target_fili'='true'::jsonb THEN
     damage:=0;
     calc:=calc||jsonb_build_object('danno_grezzo',0,'danno_applicato',0,'striscio',false,'cap_attivo',false);
   END IF;
   elemental_cap:=combat_effects_private.capture_source_cap(d.id,damage);
   IF elemental_cap<>'{}'::jsonb THEN
     calc:=calc||jsonb_build_object('common_effects',
       coalesce(calc->'common_effects','{}'::jsonb)||elemental_cap);
   END IF;
   calc:=calc||jsonb_build_object('sabaku_armor',clan_sabaku_private.armor_absorb(t.id,damage));
   damage:=(calc#>>'{sabaku_armor,damage_after}')::integer;
   IF NOT (calc->'sabaku_armor' ? 'version') THEN calc:=calc-'sabaku_armor'; END IF;
   hp:=greatest(0,coalesce((tar.mechanics_snapshot->>'vita')::int,0)-damage);
   update public.combat_v2_actors set mechanics_snapshot=jsonb_set(mechanics_snapshot,'{vita}',to_jsonb(hp),false),state=case when hp=0 then'fuori'else state end where id=tar.id;
   if p_values and tar.actor_kind='pg'and damage>0 then perform set_config('app.allow_vita_delta','1',true);update public.characters set vita=hp where id=tar.character_id;perform set_config('app.allow_vita_delta','0',true);end if;
   any_success:=any_success or ((CASE WHEN flow_calc IS NOT NULL THEN (flow_calc->>'success')::boolean WHEN akimichi_partial.declaration_id IS NOT NULL THEN (calc->>'colpito')::boolean
      WHEN nara_launch IS NOT NULL THEN final>=0 AND reaction<>'sostituzione' AND NOT (multiplication_effect->>'copy_intercepted')::boolean
      ELSE final>=0 AND NOT (multiplication_effect->>'copy_intercepted')::boolean END));
   child_outcome:=jsonb_build_object('child_id',t.id,'child_ordinal',t.ordinal,'target_actor_id',tar.id,'raw',calc,'rng_audit',rng,
    'rating_attack',vote_a,'rating_defense',vote_d,'quality_correction',corr,'threshold_margin',final,'success',(CASE WHEN flow_calc IS NOT NULL THEN (flow_calc->>'success')::boolean WHEN akimichi_partial.declaration_id IS NOT NULL THEN (calc->>'colpito')::boolean
      WHEN nara_launch IS NOT NULL THEN final>=0 AND reaction<>'sostituzione' AND NOT (multiplication_effect->>'copy_intercepted')::boolean
      ELSE final>=0 AND NOT (multiplication_effect->>'copy_intercepted')::boolean END),
    'damage_policy','full_each','damage_applied',damage,'target_hp_after',hp,'ko',hp=0);
   IF jsonb_array_length(multiplication_facts)>0 THEN
     child_outcome:=child_outcome||jsonb_build_object('multiplication',multiplication_facts,'multiplication_effect',multiplication_effect);
    END IF;
    IF nara_launch IS NOT NULL THEN
      child_outcome:=child_outcome||jsonb_build_object('nara_possession',
        combat_panel_private.nara_record_control_v1(t.id,child_outcome));
    END IF;
    IF d.sanitized_intent->'target_fili'='true'::jsonb THEN
      fili_hit:=coalesce((child_outcome->>'success')::boolean,false) AND reaction<>'sostituzione'
        AND clan_marionettisti_private.ocular_sever_frozen_valid_v1(d.id);
      any_success:=fili_hit;
      child_outcome:=child_outcome||jsonb_build_object('success',fili_hit,'fili_recisi',fili_hit);
    END IF;
    receipt:=combat_v2_multitarget_internal.sha(child_outcome);
   update public.combat_v2_attack_targets set state='risolta',outcome=child_outcome,rng_receipt_sha256=receipt where id=t.id;
  end if;
  PERFORM combat_effects_private.settle_native_target(d.id,t.id);
  PERFORM combat_panel_private.multiplication_attack_finish(t.id);
   update public.combat_v2_defense_coverages set state='risolta'where id=c.id;
  children:=children||jsonb_build_array(child_outcome);
 end loop;
 update public.combat_v2_declarations dd set state='risolta',outcome=(CASE
   WHEN meta->>'sabaku_flow_version'='sabaku-flow/2' AND dd.sanitized_intent->>'reaction'='sostituzione'
    THEN coalesce(dd.outcome,'{}'::jsonb) ELSE '{}'::jsonb END)||jsonb_build_object(
   'linked_attacks',(select coalesce(jsonb_agg(distinct mt.attack_declaration_id order by mt.attack_declaration_id),'[]'::jsonb)
      from public.combat_v2_defense_coverages cv join public.combat_v2_attack_targets mt on mt.id=cv.attack_target_id where cv.defense_declaration_id=dd.id),
   'coverage',(select coalesce(jsonb_agg(jsonb_build_object('attack_target_id',cv2.attack_target_id,'protected_actor_id',cv2.protected_actor_id,'mode',cv2.mode,'state',cv2.state) order by cv2.attack_target_id),'[]'::jsonb)
      from public.combat_v2_defense_coverages cv2 where cv2.defense_declaration_id=dd.id),
   'coverage_count',(select count(*) from public.combat_v2_defense_coverages cv3 where cv3.defense_declaration_id=dd.id))
 where dd.id in(select distinct cv.defense_declaration_id from public.combat_v2_defense_coverages cv join public.combat_v2_attack_targets mt on mt.id=cv.attack_target_id where mt.attack_declaration_id=d.id);
 perform combat_v2_private.rng_seal(p_session,p_round,d.id,'attack',
  'combat-v2/r3/multi-parent:'||p_session::text||':'||p_round::text||':'||d.id::text,
  parent_entropy,jsonb_build_object('scheme','combat-v2-child-derive/1.0','children',children));
 update public.combat_v2_actors set mechanics_snapshot=jsonb_set(mechanics_snapshot,'{slancio}',to_jsonb(case when any_success then 0 else least(9,old_slancio+3)end),true)where id=att.id;
 update public.combat_v2_declarations set state='risolta',outcome=jsonb_build_object('targeting_mode',case when jsonb_array_length(children)>1 then'multi'else'single'end,
  'damage_policy','full_each','child_count',jsonb_array_length(children),'any_success',any_success,'slancio_before',old_slancio,
  'slancio_after',case when any_success then 0 else least(9,old_slancio+3)end,'children',children)||
    CASE WHEN d.sanitized_intent->'target_fili'='true'::jsonb THEN jsonb_build_object('success',fili_hit,'fili_recisi',fili_hit,'damage_applied',0)
         ELSE '{}'::jsonb END where id=d.id;
 return jsonb_build_object('any_success',any_success,'children',children);
end$function$;

CREATE OR REPLACE FUNCTION combat_effects_private.settle_native_target(p_declaration uuid, p_attack_target uuid)
 RETURNS jsonb
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO ''
AS $function$
DECLARE d public.combat_v2_declarations%ROWTYPE;src combat_effects_private.sources%ROWTYPE;
 cl combat_effects_private.comparison_claims%ROWTYPE;n jsonb;sid uuid;actor_to_end uuid;
 facts jsonb:='{}'::jsonb;has_suiton boolean;has_claim boolean;has_source boolean;
BEGIN
 SELECT * INTO STRICT d FROM public.combat_v2_declarations WHERE id=p_declaration AND kind='attacco';
 IF d.sanitized_intent->'target_fili'='true'::jsonb THEN RETURN '{}'::jsonb; END IF;
 SELECT session_id INTO STRICT sid FROM public.combat_v2_rounds WHERE id=d.round_id;
 IF d.sanitized_intent#>>'{server_ability,hoki_needle_version}'='hoki-needle/1' THEN
  IF NOT EXISTS(SELECT 1 FROM public.combat_v2_rounds WHERE id=d.round_id AND phase='risoluzione')
  THEN RAISE EXCEPTION 'hoki_needle_result_window_required'; END IF;
  PERFORM clan_hoki_private.needle_result(d.id,p_attack_target);
 END IF;
 IF d.sanitized_intent#>>'{server_ability,source}'='mano'
  AND EXISTS(SELECT 1 FROM clan_hoki_private.body_states b
    WHERE b.actor_id IN(d.actor_id,d.target_actor_id) AND b.ended_at IS NULL)
 THEN PERFORM clan_hoki_private.body_contact(d.id,p_attack_target); END IF;
 SELECT * INTO src FROM combat_effects_private.sources WHERE declaration_id=d.id;
 has_source:=FOUND;
 has_suiton:=EXISTS(SELECT 1 FROM combat_v2_elemental_internal.suiton_sources WHERE declaration_id=d.id) OR EXISTS(SELECT 1 FROM combat_v2_elemental_internal.other_sources WHERE declaration_id=d.id);
 has_claim:=EXISTS(SELECT 1 FROM combat_effects_private.comparison_claims cc
  WHERE cc.attack_declaration_id=d.id AND cc.attack_target_id IS NOT DISTINCT FROM p_attack_target);
 IF NOT has_source AND NOT has_suiton AND NOT has_claim AND NOT EXISTS(
  SELECT 1 FROM combat_effects_private.effect_applications e JOIN public.combat_v2_actors a ON a.id=e.target_actor_id
  WHERE e.session_id=sid AND e.state IN ('pending','active') AND a.state<>'attivo') THEN RETURN facts;END IF;
 PERFORM combat_effects_private.lock_context(sid);
 IF NOT EXISTS(SELECT 1 FROM public.combat_v2_rounds WHERE id=d.round_id AND phase='risoluzione') THEN
  RAISE EXCEPTION 'effects_target_settlement_phase_required';END IF;
 n:=combat_effects_private.native_outcome(d.id,p_attack_target);
 -- La carica va saldata sul child immutabile PRIMA di terminare gli effetti
 -- di un bersaglio che l'HP writer nativo ha appena reso inoperativo.
 FOR cl IN SELECT * FROM combat_effects_private.comparison_claims cc
  WHERE cc.attack_declaration_id=d.id AND cc.attack_target_id IS NOT DISTINCT FROM p_attack_target
  ORDER BY cc.id FOR UPDATE LOOP
  facts:=facts||jsonb_build_object('comparison',combat_effects_private.settle_defense_modifier(cl.id));
 END LOOP;
 FOR actor_to_end IN SELECT DISTINCT a.id FROM public.combat_v2_actors a
  JOIN combat_effects_private.effect_applications e ON e.target_actor_id=a.id AND e.session_id=sid
  WHERE a.session_id=sid AND a.state<>'attivo' AND e.state IN ('pending','active') ORDER BY a.id LOOP
  PERFORM combat_effects_private.end_actor(sid,actor_to_end);
 END LOOP;
 IF has_source THEN
  IF src.profile->>'family'='bruciatura_lieve' AND n->>'state'='risolta' AND n#>'{outcome,success}'='true'::jsonb THEN
   facts:=facts||jsonb_build_object('damage_source',combat_effects_private.freeze_damage_source(d.id,p_attack_target));
  END IF;
  facts:=facts||jsonb_build_object('temporary_effect',combat_effects_private.apply_from_outcome(d.id,p_attack_target));
 END IF;
 IF has_suiton THEN
  IF EXISTS(SELECT 1 FROM combat_v2_elemental_internal.other_sources WHERE declaration_id=d.id) THEN
   facts:=facts||jsonb_build_object('forced_movement',combat_v2_elemental_internal.other_force_from_outcome(d.id,p_attack_target));
  ELSE
  facts:=facts||jsonb_build_object('forced_movement',combat_v2_elemental_internal.suiton_force_from_outcome(d.id,p_attack_target));
  END IF;
 END IF;
 RETURN facts;
END $function$;

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
   where session_id=v_round.session_id and source_kind='staff' and is_active) then
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
    where s.id=v_target.companion_id and ((s.source_kind='staff')=v_report.values_written)) then
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

CREATE OR REPLACE FUNCTION clan_marionettisti_private.declaration_terminal_trigger()
 RETURNS trigger
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO ''
AS $function$
declare start_event clan_marionettisti_private.control_events%rowtype;
 r public.combat_v2_rounds%rowtype;target public.combat_v2_actors%rowtype;
 link clan_marionettisti_private.links%rowtype;cut_no bigint;v_fili_proof jsonb;
begin
 if new.state not in('risolta','superflua') or old.state in('risolta','superflua') then return new;end if;
 select * into strict r from public.combat_v2_rounds where id=new.round_id;
 if r.phase<>'risoluzione' or not clan_marionettisti_private.is_dedicated_scene(r.session_id) then return new;end if;
 if new.kind in('attacco','movimento','utilita','passa') and exists(select 1 from public.combat_v2_actors where id=new.actor_id and state='attivo') then
  select * into start_event from clan_marionettisti_private.control_events
   where round_id=r.id and owner_actor_id=new.actor_id and kind='turn_started';
  if found then
   insert into clan_marionettisti_private.control_events(session_id,round_id,owner_actor_id,kind,source_declaration_id,request_key,fingerprint,payload)
    values(r.session_id,r.id,new.actor_id,'turn_completed',new.id,r.id,public.combat_v2_sha256(new.outcome),
     jsonb_build_object('authority','common-terminal/1','started_event_no',start_event.event_no,'terminal_state',new.state,'kind',new.kind))
    on conflict(owner_actor_id,kind,request_key) do nothing;
  end if;
 end if;
 -- The native attack selected a specific visible link, and has resolved successfully.
 if new.kind='attacco' and new.state='risolta' and new.outcome->>'fili_recisi'='true'
 and new.sanitized_intent->'target_fili'='true'::jsonb then
   v_fili_proof:=clan_marionettisti_private.ocular_sever_proof_v1(new.request_key,new.round_id,new.actor_id,new.target_actor_id);
  select * into target from public.combat_v2_actors where id=new.target_actor_id and session_id=r.session_id;
  if target.companion_id is not null then
   select * into link from clan_marionettisti_private.links where companion_actor_id=target.id for update;
   if found and link.state='connected'
   and link.link_version::text=v_fili_proof->>'link_version'
   and link.owner_actor_id::text=v_fili_proof->>'owner_actor_id' then
    insert into clan_marionettisti_private.control_events(session_id,round_id,owner_actor_id,kind,source_declaration_id,request_key,fingerprint,payload)
     values(r.session_id,r.id,link.owner_actor_id,'link_severed',new.id,new.id,public.combat_v2_sha256(new.outcome),
      jsonb_build_object('authority','ocular-sever/1','companion_actor_id',target.id,'prior_link_version',link.link_version,
        'eye_id',v_fili_proof->'eye_id',
        'attack_source',new.sanitized_intent#>'{server_ability,source}','attack_id',new.sanitized_intent#>'{server_ability,id}'))
     returning event_no into cut_no;
    update clan_marionettisti_private.links set state='severed',link_version=link_version+1,cut_event_no=cut_no where owner_actor_id=link.owner_actor_id;
   end if;
  end if;
 end if;
 return new;
end;
$function$;

CREATE OR REPLACE FUNCTION clan_marionettisti_private.narrative_attack_allowed(p_declaration uuid)
 RETURNS boolean
 LANGUAGE sql
 STABLE SECURITY DEFINER
 SET search_path TO ''
AS $function$
 select exists(select 1 from public.combat_v2_declarations d where d.id=p_declaration and d.kind='attacco'
  and (d.sanitized_intent->'target_fili'='true'::jsonb
     OR clan_uchiha_private.fireball_source_valid(d.id) OR d.sanitized_intent#>>'{server_ability,source}'='mano'
   OR combat_panel_private.shuriken_resolved_v1(d.id) or exists(
   select 1 from clan_hyuga_private.sedici_sources h join public.combat_v2_rounds r on r.id=d.round_id
   where h.declaration_id=d.id and h.actor_id=d.actor_id and h.target_actor_id=d.target_actor_id
    and h.session_id=r.session_id and d.state='risolta'
    and d.sanitized_intent->>'ability_source'='clan'
    and d.sanitized_intent->>'ability_id'='031d5ecc-86ee-4d21-85f1-6b76fc57cef9'
    and h.source_sha256=clan_hyuga_private.juken_declaration_fingerprint(d.id)) or exists(
   select 1 from clan_marionettisti_private.offensive_profiles p
   where p.declaration_id=d.id and p.round_id=d.round_id and p.owner_actor_id=d.actor_id
    and p.target_actor_id=d.target_actor_id and p.profile_sha256=public.combat_v2_sha256(p.profile)
    and d.sanitized_intent->>'ability_source'='clan'
    and d.sanitized_intent->>'ability_id'='e361f7c3-f90b-47ec-bfee-ccbda21257d9')))
$function$;

CREATE OR REPLACE FUNCTION combat_consumer_private.narrative_context(p_round uuid)
 RETURNS jsonb
 LANGUAGE plpgsql
 STABLE SECURITY DEFINER
 SET search_path TO ''
AS $function$
declare ctx combat_consumer_private.activities%rowtype; report public.combat_v2_round_reports%rowtype;
  primary_action public.combat_v2_declarations%rowtype; defense public.combat_v2_declarations%rowtype;
  source public.characters%rowtype; target public.characters%rowtype;
  a combat_spatial.actor_states%rowtype; b combat_spatial.actor_states%rowtype;
  link combat_consumer_private.declaration_messages%rowtype; reports jsonb:='{}';
  distance numeric; outcome text; prior text; location_name text; movement numeric:=0;
begin
  IF EXISTS(SELECT 1 FROM public.combat_v2_declarations d WHERE d.round_id=p_round
    AND d.sanitized_intent#>>'{server_ability,nara_launch,schema_version}'='nara-possession/1'
    AND combat_panel_private.nara_ordinary_narrative_fact_v1(d.id) IS NOT NULL) THEN
    RETURN combat_panel_private.narrative_ordinary_context(p_round);
  END IF;
  IF EXISTS(SELECT 1 FROM clan_akimichi_private.partial_sources s
    WHERE s.round_id=p_round AND clan_akimichi_private.narrative_partial_valid(s.declaration_id)) THEN
    RETURN combat_panel_private.narrative_ordinary_context(p_round);
  END IF;
  IF EXISTS(SELECT 1 FROM clan_hoki_private.needle_sources n
     JOIN public.combat_v2_declarations d ON d.id=n.declaration_id
     WHERE d.round_id=p_round AND n.state='spent'
       AND combat_consumer_private.narrative_declaration_supported(d.id))
   OR EXISTS(SELECT 1 FROM public.combat_v2_round_reports rr
     JOIN public.combat_v2_declarations d ON d.round_id=rr.round_id
     WHERE rr.round_id=p_round AND rr.narration_state='attesa'
       AND (rr.mechanics->'hoki_facts' @? '$[*] ? (@.active == true || @.poison_applied == true || @.version == "hoki-minor-poison/1")')
       AND d.kind IN ('attacco','passa','movimento')
       AND combat_consumer_private.narrative_declaration_supported(d.id)) THEN
    RETURN combat_panel_private.narrative_ordinary_context(p_round);
  END IF;
  IF EXISTS(SELECT 1 FROM combat_v2_elemental_internal.other_sources s
    WHERE s.round_id=p_round AND combat_v2_elemental_internal.other_narrative_supported(s.declaration_id))
    OR EXISTS(SELECT 1 FROM combat_v2_taijutsu_internal.taijutsu_sources s
      WHERE s.round_id=p_round AND combat_v2_taijutsu_internal.narrative_supported(s.declaration_id))
    OR EXISTS(SELECT 1 FROM combat_v2_elemental_internal.scudo_sources s
      JOIN public.combat_v2_declarations d ON d.id=s.declaration_id
      WHERE d.round_id=p_round AND d.state='risolta'
        AND combat_v2_elemental_internal.scudo_source_valid(d.id)) THEN
    RETURN combat_panel_private.narrative_ordinary_context(p_round);
  END IF;
  IF EXISTS(SELECT 1 FROM combat_v2_elemental_internal.suiton_sources s
    WHERE s.round_id=p_round AND combat_v2_elemental_internal.suiton_narrative_supported(s.declaration_id)) THEN
    RETURN combat_panel_private.narrative_ordinary_context(p_round);
  END IF;
  IF EXISTS(SELECT 1 FROM clan_hyuga_private.rotation_sources h
   JOIN public.combat_v2_declarations rot_defense ON rot_defense.id=h.declaration_id
   WHERE h.round_id=p_round AND rot_defense.state='risolta'
    AND rot_defense.outcome#>>'{hyuga_rotation,defense_declaration_id}'=h.declaration_id::text
    AND rot_defense.outcome ? 'hyuga_rotation_movement'
    AND h.source_sha256=clan_hyuga_private.rotation_source_hash(h)) THEN
   RETURN combat_panel_private.narrative_ordinary_context(p_round);
  END IF;
  IF EXISTS(SELECT 1 FROM clan_sabaku_private.flow_sources WHERE round_id=p_round) THEN
    RETURN combat_panel_private.narrative_ordinary_context(p_round);
  END IF;
  IF EXISTS(SELECT 1 FROM clan_sabaku_private.armor_events ae
    WHERE ae.round_id=p_round AND ae.event_kind='hit') THEN
    RETURN combat_panel_private.narrative_ordinary_context(p_round);
  END IF;
  IF EXISTS(SELECT 1 FROM clan_aburame_private.combat_sources s
    WHERE s.round_id=p_round AND s.source_kind IN ('release','clone')
      AND combat_consumer_private.narrative_declaration_supported(s.declaration_id))
    OR EXISTS(SELECT 1 FROM combat_consumer_private.activities aburame_context
      JOIN clan_aburame_private.combat_sources aburame_history
        ON aburame_history.session_id=aburame_context.session_id
      WHERE aburame_context.exchange_id=p_round
        AND aburame_history.source_kind IN ('release','clone')
        AND EXISTS(SELECT 1 FROM public.combat_v2_declarations aburame_current
          WHERE aburame_current.round_id=p_round
            AND aburame_current.kind IN ('attacco','utilita','passa','movimento')
            AND combat_consumer_private.narrative_declaration_supported(aburame_current.id))) THEN
    RETURN combat_panel_private.narrative_ordinary_context(p_round);
  END IF;
  if exists(select 1 from public.combat_v2_declarations d where d.round_id=p_round
    and ((d.state='risolta' AND (
  (d.kind='attacco' AND (
    EXISTS(SELECT 1 FROM clan_hyuga_private.juken_sources h
      JOIN public.combat_v2_rounds r ON r.id=d.round_id
      WHERE h.declaration_id=d.id AND h.actor_id=d.actor_id AND h.target_actor_id=d.target_actor_id
        AND h.round_id=d.round_id AND h.session_id=r.session_id
        AND d.sanitized_intent#>>'{server_ability,source}'='mano'
        AND h.declaration_sha256=clan_hyuga_private.juken_declaration_fingerprint(d.id))
    OR EXISTS(SELECT 1 FROM clan_hyuga_private.sedici_sources h
      JOIN public.combat_v2_rounds r ON r.id=d.round_id
      WHERE h.declaration_id=d.id AND h.actor_id=d.actor_id AND h.target_actor_id=d.target_actor_id
        AND h.session_id=r.session_id AND d.sanitized_intent->>'ability_source'='clan'
        AND d.sanitized_intent->>'ability_id'='031d5ecc-86ee-4d21-85f1-6b76fc57cef9'
        AND h.source_sha256=clan_hyuga_private.juken_declaration_fingerprint(d.id))))
  OR (clan_hyuga_private.sedici_expiry_facts(d.id) @> '{"sedici_chiusure_expired":true}'::jsonb
      AND combat_consumer_private.narrative_declaration_supported(d.id)))) OR clan_uchiha_private.fireball_source_valid(d.id) OR exists(select 1 from clan_sabaku_private.clone_captures cc where cc.round_id=p_round)
      or d.kind='utilita' or (d.kind='attacco' and (
      exists(select 1 from combat_panel_private.multiplication_formations f where f.declaration_id=d.id)
      or d.outcome ? 'multiplication' or exists(select 1 from public.combat_v2_attack_targets t
        where t.attack_declaration_id=d.id and t.outcome ? 'multiplication'))))) then
    return combat_panel_private.narrative_ordinary_context(p_round);
  end if;
  select c.* into ctx from combat_consumer_private.activities c where exchange_id=p_round and phase='resolved';
  select * into report from public.combat_v2_round_reports where round_id=p_round and narration_state='attesa';
  if ctx.session_id is null or report.id is null then raise exception 'ordinary_report_not_ready'; end if;
  select * into primary_action from public.combat_v2_declarations where round_id=p_round and kind in ('attacco','passa');
  if primary_action.id is null or (primary_action.kind='attacco' and
    not clan_marionettisti_private.narrative_attack_allowed(primary_action.id)) then
    raise exception 'ordinary_narrative_source_not_ready';
  end if;
  select c.* into source from public.characters c join combat_consumer_private.members m on m.character_id=c.id
    where m.session_id=ctx.session_id and m.actor_id=primary_action.actor_id;
  select c.* into target from public.characters c join combat_consumer_private.members m on m.character_id=c.id
    where m.session_id=ctx.session_id and m.actor_id<>primary_action.actor_id;
  select s.* into a from combat_spatial.actor_states s join combat_spatial.arena_instances i on i.instance_id=s.instance_id
    where i.encounter_id=ctx.session_id and s.actor_id=coalesce((select companion_actor_id from clan_marionettisti_private.offensive_profiles where declaration_id=primary_action.id),primary_action.actor_id);
  select s.* into b from combat_spatial.actor_states s join combat_spatial.arena_instances i on i.instance_id=s.instance_id
    where i.encounter_id=ctx.session_id and s.actor_id=coalesce(primary_action.target_actor_id,(select actor_id from combat_consumer_private.members where session_id=ctx.session_id and actor_id<>primary_action.actor_id));
  if nullif(btrim(source.name),'') is null or nullif(btrim(target.name),'') is null
    or a.actor_id is null or b.actor_id is null then raise exception 'ordinary_narrative_projection_missing'; end if;
  distance:=combat_spatial.distance_m(a.x_m,a.y_m,b.x_m,b.y_m);
  select name into location_name from public.locations where id=ctx.location_id;
  select n.body into prior from public.combat_v2_narratives n join public.combat_v2_rounds r on r.id=n.round_id
    where r.session_id=ctx.session_id and r.id<>p_round and r.state='narrato' order by r.round_no desc limit 1;
  select coalesce(sum((e.after_state->>'d_eff_m')::numeric),0) into movement
    from combat_spatial.spatial_events e join combat_consumer_private.offers o on o.id=e.root_id
    where o.exchange_id=p_round and e.actor_id=primary_action.actor_id and e.event_kind='movement_settled';
  select * into link from combat_consumer_private.declaration_messages where declaration_id=primary_action.id;
  if link.message_id is null then raise exception 'ordinary_narrative_message_missing'; end if;
  reports:=jsonb_build_object('attack',public._combat_narrative_report(link.message_id,link.message_sha256,ctx.location_id,source.id));
  if primary_action.kind='passa' then
    return jsonb_build_object('ordinary',true,'genere','rinuncia','non_offensivo',true,
      'autore',jsonb_build_object('nome',source.name,'sesso',source.sex),
      'testimone',jsonb_build_object('nome',target.name,'sesso',target.sex),
      'luogo',location_name,'distanza_fascia',public._fascia_da_metri(ceil(distance)::integer),'movimento_effettivo',movement>0,
      'player_reports',reports,'gia_visto',left(coalesce(prior,''),400),'model','gpt-6-luna');
  end if;
  select * into defense from public.combat_v2_declarations where parent_attack_id=primary_action.id and kind in ('difesa','nessuna');
  if defense.id is null then raise exception 'ordinary_narrative_defense_missing'; end if;
  select * into link from combat_consumer_private.declaration_messages where declaration_id=defense.id;
  if link.message_id is null then raise exception 'ordinary_narrative_message_missing'; end if;
  reports:=reports||jsonb_build_object('defense',public._combat_narrative_report(link.message_id,link.message_sha256,ctx.location_id,target.id));
  outcome:=case when coalesce((primary_action.outcome->>'success')::boolean,false) then 'colpito'
    when coalesce((primary_action.outcome->>'damage_applied')::integer,0)>0 then 'sfiorato' else 'mancato' end;
  return jsonb_build_object('ordinary',true,'genere','confronto','non_offensivo',false,'luogo',location_name,
    'attaccante',jsonb_build_object('nome',source.name,'sesso',source.sex),
    'difensore',case when exists(select 1 from public.combat_v2_actors where id=primary_action.target_actor_id and companion_id is not null)
      then jsonb_build_object('nome','Marionetta','sesso',null) else jsonb_build_object('nome',target.name,'sesso',target.sex) end,
    'tecnica',case when primary_action.sanitized_intent->'target_fili'='true'::jsonb THEN
      (primary_action.sanitized_intent#>>'{server_ability,name}')||' contro i Fili di Chakra. '||
        CASE WHEN primary_action.outcome->'fili_recisi'='true'::jsonb THEN 'I Fili vengono recisi.' ELSE 'I Fili restano collegati.' END||' La marionetta non è colpita.'
      when exists(select 1 from clan_marionettisti_private.offensive_profiles where declaration_id=primary_action.id) then 'Marionetta da Combattimento: arto rinforzato contundente, controllato tramite Fili di Chakra' when combat_panel_private.shuriken_resolved_v1(primary_action.id) then 'Lancio di Shuriken'
       else 'Colpo a mani nude' end,'natura',null,'reazione',defense.sanitized_intent->>'reaction',
    'tecnica_difensiva',null,'esito_copie',null,'esito',outcome,
    'intensita',case when outcome='colpito' then case
      when (primary_action.outcome->>'threshold_margin')::integer<5 then 'di striscio'
      when (primary_action.outcome->>'threshold_margin')::integer<15 then 'in pieno' else 'con violenza' end end,
    'fuori_combattimento',coalesce((primary_action.outcome->>'ko')::boolean,false),
    'vantaggio_elementale',null,'distanza_fascia',public._fascia_da_metri(ceil(distance)::integer),
    'movimento_effettivo',movement>0,'player_reports',reports,'gia_visto',left(coalesce(prior,''),400),'model','gpt-6-luna');
end $function$;

CREATE OR REPLACE FUNCTION combat_effects_private.freeze_source(p_declaration uuid)
 RETURNS jsonb
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO ''
AS $function$
DECLARE d public.combat_v2_declarations%ROWTYPE; a public.combat_v2_actors%ROWTYPE;
 prior combat_effects_private.sources%ROWTYPE; effect jsonb; aid uuid; fp text;
BEGIN
 SELECT * INTO STRICT d FROM public.combat_v2_declarations WHERE id=p_declaration;
 IF d.sanitized_intent->'target_fili'='true'::jsonb AND clan_marionettisti_private.ocular_sever_proof_v1(
     d.request_key,d.round_id,d.actor_id,d.target_actor_id) IS NOT NULL THEN
   RETURN NULL;
 END IF;
 SELECT * INTO STRICT a FROM public.combat_v2_actors WHERE id=d.actor_id;
 PERFORM combat_effects_private.lock_context(a.session_id);
 SELECT * INTO STRICT d FROM public.combat_v2_declarations WHERE id=p_declaration FOR UPDATE;
 IF d.sanitized_intent->>'ability_source' IS DISTINCT FROM 'clan' THEN RETURN NULL;END IF;
 aid:=(d.sanitized_intent->>'ability_id')::uuid;effect:=combat_effects_private.technique_effect(aid);
 IF effect IS NULL THEN RETURN NULL;END IF;
 fp:=combat_effects_private.declaration_fingerprint(d.id);
 SELECT * INTO prior FROM combat_effects_private.sources WHERE declaration_id=d.id;
 IF FOUND THEN
  IF prior.declaration_sha256 IS DISTINCT FROM fp OR prior.profile IS DISTINCT FROM effect
   OR prior.profile_sha256 IS DISTINCT FROM public.combat_v2_sha256(effect) THEN RAISE EXCEPTION 'effects_source_replay_conflict';END IF;
  RETURN prior.profile;
 END IF;
 IF NOT ((d.sanitized_intent#>>'{server_ability,elementali_profile_version}'='elementali-genin/1'
    AND EXISTS(SELECT 1 FROM combat_effects_private.technique_gates WHERE catalog_technique_id=aid AND enabled))
   OR (d.sanitized_intent#>>'{server_ability,taijutsu_profile_version}'='taijutsu-genin/1'
    AND EXISTS(SELECT 1 FROM combat_v2_taijutsu_internal.taijutsu_gates WHERE technique_id=aid AND (staff_enabled OR public_enabled))))
  OR d.kind<>'attacco' OR d.state NOT IN ('inviata','congelata')
  OR d.sanitized_intent#>>'{server_ability,catalog_technique_id}' IS DISTINCT FROM aid::text
  OR d.sanitized_intent#>'{server_ability,temporary_effect}' IS DISTINCT FROM effect
  OR NOT EXISTS(SELECT 1 FROM public.combat_v2_actors WHERE id=d.target_actor_id AND session_id=a.session_id AND state='attivo')
  OR NOT EXISTS(SELECT 1 FROM public.combat_v2_rounds WHERE id=d.round_id AND session_id=a.session_id) THEN
  RAISE EXCEPTION 'effects_frozen_source_required' USING ERRCODE='42501';END IF;
 INSERT INTO combat_effects_private.sources(declaration_id,session_id,source_actor_id,target_actor_id,catalog_technique_id,
  profile,profile_sha256,declaration_sha256)
 VALUES(d.id,a.session_id,a.id,d.target_actor_id,aid,effect,public.combat_v2_sha256(effect),fp);
 RETURN effect;
END $function$;

CREATE OR REPLACE FUNCTION combat_panel_private.master_actor_offers(p_context uuid, p_expected bigint, p_view jsonb, p_source jsonb)
 RETURNS void
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO ''
AS $function$
DECLARE c combat_panel_private.contexts%ROWTYPE; a public.combat_v2_actors%ROWTYPE;
 link_targets jsonb; cut_candidates jsonb; cut_cache jsonb:='{}'::jsonb;
 cut_range numeric; cut_group uuid; cut_offer uuid;
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
   -- Restrict consideration to connected companions already shown to this PG.
   SELECT coalesce(jsonb_agg(viewer.actor ORDER BY b.id),'[]'::jsonb) INTO link_targets
   FROM jsonb_array_elements(p_view->'actors') AS viewer(actor)
   JOIN public.combat_v2_actors b ON b.id=(viewer.actor->>'actor_id')::uuid
      AND b.session_id=a.session_id AND b.team_key<>a.team_key AND b.state='attivo'
   JOIN clan_marionettisti_private.links link ON link.companion_actor_id=b.id AND link.state='connected'
   WHERE a.actor_kind='pg' AND a.controller_user=auth.uid()
     AND nullif(btrim(viewer.actor->>'display_name'),'') IS NOT NULL;
   FOR meta IN SELECT value FROM jsonb_array_elements(jsonb_build_array(jsonb_build_object(
     'source','mano','name','Colpo a mano','kind','fisico','chakra_cost',0,'damage_base',10))||(SELECT coalesce(jsonb_agg(x.value ORDER BY x.ordinality),'[]'::jsonb)
       FROM jsonb_array_elements(coalesce(p_source->'abilities','[]'::jsonb)) WITH ORDINALITY x(value,ordinality)
       WHERE CASE WHEN x.value->>'source'='clan'
       AND x.value->>'id' IN ('127f3854-4183-4354-a654-f59320d8807e','c8d32b00-3917-41a6-8906-388e7b9efcc7')
       THEN NOT clan_hoki_private.routes_ability(a.id,(x.value->>'id')::uuid) ELSE true END)
      ||CASE WHEN clan_hoki_private.needle_ability(a.id,false) IS NULL THEN '[]'::jsonb
         ELSE jsonb_build_array(clan_hoki_private.needle_ability(a.id,false)) END
      ||coalesce((SELECT jsonb_agg(x.profile) FROM (SELECT combat_panel_private.shuriken_available_v1(a.id) AS profile) x
        WHERE x.profile IS NOT NULL),'[]'::jsonb)) LOOP
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
     ability_range:=CASE WHEN meta ? 'nara_range_m' THEN (meta->>'nara_range_m')::numeric WHEN meta->>'hoki_needle_version'='hoki-needle/1' THEN 15 WHEN meta->>'akimichi_partial_contract'='akimichi-partial/1' THEN 3 WHEN meta->>'source'='clan' AND meta->>'id'='e361f7c3-f90b-47ec-bfee-ccbda21257d9' THEN 3 WHEN meta->>'source'='clan' AND meta->>'id'='b076a976-c75b-4b5a-8813-b0e8e2c3af03' THEN 2 WHEN meta->>'source'='arma' THEN (meta->>'range_m')::numeric WHEN meta->>'source'='mano' THEN 2 ELSE public._fascia_metri(meta->>'range') END;
     IF jsonb_array_length(link_targets)>0 THEN
       cut_range:=clan_marionettisti_private.ocular_sever_attack_range_v1(
         a.id,meta->>'source',(meta->>'id')::uuid,meta);
       IF cut_range IS NOT NULL THEN
         cut_candidates:=cut_cache->(cut_range::text);
         IF cut_candidates IS NULL THEN
           SELECT coalesce(jsonb_agg(candidate.actor ORDER BY candidate.ordinality),'[]'::jsonb)
             INTO cut_candidates
           FROM jsonb_array_elements(link_targets) WITH ORDINALITY AS candidate(actor,ordinality)
           WHERE clan_marionettisti_private.ocular_sever_source_v1(
             c.round_id,a.id,(candidate.actor->>'actor_id')::uuid,cut_range) IS NOT NULL;
           cut_cache:=jsonb_set(cut_cache,ARRAY[cut_range::text],cut_candidates,true);
         END IF;
         IF jsonb_array_length(cut_candidates)>0 THEN
           cut_offer:=combat_panel_private.create_offer(c.id,c.context_version,'action','declare',
             (meta->>'name')||' · Recidi i Fili'||CASE WHEN cost>0 THEN ' · '||cost::text||' chakra' ELSE '' END,
             true,jsonb_build_object('adapter','master_v2','dispatch','action','kind','attacco',
               'ability_source',meta->'source','ability_id',meta->'id','target_fili',true));
           cut_group:=combat_panel_private.add_group(cut_offer,'Fili da recidere','target','single',1,1);
           FOR item IN SELECT value FROM jsonb_array_elements(cut_candidates) LOOP
             PERFORM combat_panel_private.add_choice(
               cut_group,item->>'display_name',jsonb_build_object('target_actor_id',item->'actor_id'));
           END LOOP;
         END IF;
       END IF;
     END IF;
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
       ELSIF meta->>'source'='arma' THEN
         IF NOT combat_panel_private.shuriken_target_v1(a.id,target_id) THEN CONTINUE; END IF;
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
     FOR n IN 2..(CASE WHEN meta->>'source'='arma' OR meta ? 'nara_range_m' OR (meta->>'source'='clan' AND meta->>'id'='e361f7c3-f90b-47ec-bfee-ccbda21257d9')
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
END $function$;

CREATE OR REPLACE FUNCTION combat_panel_private.commit_master_actor(p_command jsonb)
 RETURNS jsonb
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO ''
AS $function$
DECLARE p jsonb; uid uuid:=exam_regia_private.current_principal(); key uuid; fp text; receipt_id uuid:=gen_random_uuid();
 prior combat_panel_private.request_receipts%ROWTYPE; o combat_panel_private.offers%ROWTYPE;
 c combat_panel_private.contexts%ROWTYPE; a public.combat_v2_actors%ROWTYPE;
 env jsonb; resolved jsonb; selected uuid[]; payload jsonb; intent jsonb; v_master_actor_result jsonb; receipt jsonb;
 targets uuid[]:='{}'; coverages uuid[]:='{}'; primary_attack uuid; movement uuid; substitution uuid;
  rotation_radius integer; fireball_selection jsonb; declaration uuid; label text; target_label text; event jsonb; dispatch text; flow_allocations jsonb:='[]';
  human_stage boolean:=false;intent_stage boolean:=false; ack_context_version bigint;
BEGIN
 IF uid IS NULL THEN RAISE EXCEPTION 'panel_authentication_required' USING ERRCODE='28000'; END IF;
 p:=combat_panel_private.validate_command(p_command); key:=(p->>'request_key')::uuid; fp:=public.combat_v2_sha256(p);
 PERFORM pg_advisory_xact_lock(hashtextextended('panel-request:'||uid::text||':'||key::text,731));
 SELECT * INTO prior FROM combat_panel_private.request_receipts WHERE principal_user=uid AND request_key=key;
 IF prior.request_key IS NOT NULL THEN
   IF prior.command_fingerprint<>fp THEN RAISE EXCEPTION 'panel_request_key_conflict' USING ERRCODE='22023'; END IF;
   RETURN jsonb_set(prior.viewer_envelope,'{receipt,replayed}','true',false);
 END IF;
 SELECT * INTO o FROM combat_panel_private.offers WHERE id=(p->>'offer_id')::uuid AND principal_user=uid;
 IF o.id IS NULL OR o.source_payload->>'adapter' IS DISTINCT FROM 'master_v2'
   OR o.kind NOT IN ('action','defense') THEN RAISE EXCEPTION 'panel_offer_not_available' USING ERRCODE='42501'; END IF;
 -- Preserve historical idempotent receipts; reject only new commits of stale passive attacks.
 IF o.source_payload->>'dispatch'='action' AND o.source_payload->>'kind'='attacco'
   AND o.source_payload->>'ability_source'='clan'
   AND o.source_payload->>'ability_id'='4056f62d-77f3-47f9-8ecb-9a7799682a9d' THEN
   RAISE EXCEPTION 'panel_passive_ability_not_attack' USING ERRCODE='22023'; END IF;
 SELECT * INTO STRICT c FROM combat_panel_private.contexts WHERE id=o.context_id AND principal_user=uid;
 IF c.activity_kind<>'master_v2' OR c.round_id IS NULL
   OR c.location_id IS DISTINCT FROM (p->>'location_id')::uuid OR c.activity_id IS DISTINCT FROM (p->>'activity_id')::uuid THEN
   RAISE EXCEPTION 'panel_activity_scope_invalid' USING ERRCODE='22023'; END IF;
 PERFORM public.combat_v2_lock_round(c.round_id);
 env:=combat_panel_private.master_projection(c.location_id,c.command_actor_id);
 PERFORM 1 FROM combat_panel_private.contexts WHERE id=c.id FOR UPDATE;
 c:=combat_panel_private.owned_context(c.id,(p->>'context_version')::bigint);
 SELECT * INTO STRICT o FROM combat_panel_private.offers WHERE id=o.id FOR UPDATE;
 IF o.state<>'offered' OR o.context_version<>c.context_version OR o.source_fingerprint IS DISTINCT FROM c.source_fingerprint
   OR o.scene_version IS DISTINCT FROM c.scene_version OR o.actor_id IS DISTINCT FROM c.command_actor_id THEN
   RAISE EXCEPTION 'panel_offer_not_available' USING ERRCODE='40001'; END IF;
 IF o.requires_role AND length(btrim(p->>'narrative_text'))=0 THEN RAISE EXCEPTION 'panel_role_required' USING ERRCODE='22023'; END IF;
 SELECT * INTO STRICT a FROM public.combat_v2_actors WHERE id=o.actor_id AND session_id=c.activity_id
   AND exam_regia_private.actor_principal(id,controller_user)=uid AND companion_id IS NULL AND state='attivo' FOR UPDATE;
 SELECT coalesce(array_agg(value::uuid),'{}') INTO selected FROM jsonb_array_elements_text(p->'selected_option_ids');
 resolved:=combat_panel_private.resolve_selections(o.id,selected,p->'inputs');
 FOR payload IN SELECT choice->'payload' FROM jsonb_array_elements(resolved->'groups') AS groups(g)
   CROSS JOIN LATERAL jsonb_array_elements(g->'options') AS choices(choice) LOOP
   IF payload ? 'rotation_radius_m' THEN
     IF rotation_radius IS NOT NULL THEN RAISE EXCEPTION 'rotation_selection_duplicate';END IF;
     rotation_radius:=(payload->>'rotation_radius_m')::integer;
   END IF;
   IF payload ? 'fireball_selection' THEN
     IF fireball_selection IS NOT NULL THEN RAISE EXCEPTION 'fireball_selection_conflict';END IF;
     fireball_selection:=payload->'fireball_selection';
   END IF;
   IF payload ? 'attack_target_id' THEN
     coverages:=array_append(coverages,(payload->>'attack_target_id')::uuid);
     primary_attack:=coalesce(primary_attack,(payload->>'attack_declaration_id')::uuid);
   ELSIF payload ? 'target_actor_id' THEN targets:=array_append(targets,(payload->>'target_actor_id')::uuid);
   END IF;
   IF o.source_payload#>>'{sabaku_flow,version}'='sabaku-flow/2' AND payload ? 'target_actor_id' THEN
     IF NOT payload ? 'flow_count' THEN RAISE EXCEPTION 'sabaku_flow_quantity_required' USING ERRCODE='22023'; END IF;
     flow_allocations:=flow_allocations||jsonb_build_array(jsonb_build_object(
       'target_actor_id',payload->'target_actor_id','flows',payload->'flow_count'));
   END IF;
   IF payload ? 'movement_capability_id' THEN
     IF movement IS NOT NULL THEN RAISE EXCEPTION 'panel_movement_selection_conflict' USING ERRCODE='22023'; END IF;
     movement:=(payload->>'movement_capability_id')::uuid;
   END IF;
   IF payload ? 'substitution_option_id' THEN
     IF substitution IS NOT NULL THEN RAISE EXCEPTION 'panel_substitution_selection_conflict' USING ERRCODE='22023'; END IF;
     substitution:=(payload->>'substitution_option_id')::uuid;
   END IF;
  END LOOP;
  -- Only the Master-controlled PNG may stage privately. PG declarations and
  -- defenses continue through the published window and native controller checks.
  IF a.actor_kind='png' THEN
   PERFORM mission_generic_owner.regia_human_stage_permit_v1(c.round_id,a.id,key);
  END IF;
  -- The human permit is bound to this offer, actor and request in the same TX.
  -- Native context/offer and controller versions were checked above under lock.
  SELECT EXISTS(SELECT 1
    FROM mission_generic_owner.regia_human_stage_permits_v1 hp
    JOIN mission_generic_owner.regia_human_windows_v1 hw
      ON hw.next_round_id=hp.round_id AND hw.master_session_id=hp.master_session_id
    JOIN mission_generic_owner.unified_round_windows uw
      ON uw.round_id=hp.round_id AND uw.batch_id=hw.batch_id
       AND uw.master_session_id=hw.master_session_id
    JOIN public.combat_v2_sessions cs ON cs.id=c.activity_id
       AND cs.master_session_id=hw.master_session_id
    JOIN public.master_v2_sessions ms ON ms.id=hw.master_session_id
    WHERE hp.round_id=c.round_id AND hp.actor_id=a.id AND hp.request_key=key
      AND hp.principal_id=uid AND hp.transaction_id=txid_current()
      AND hp.backend_pid=pg_backend_pid()
      AND hw.encounter_id=cs.id AND a.session_id=cs.id AND a.actor_kind='png'
      AND ms.owner_kind='human' AND ms.closed_at IS NULL
      AND ms.master_user=uid
      AND ms.location_id='0b85f354-9cdb-47e1-baf9-3d266bb7e06b'::uuid
      AND ((hw.state='private' AND hw.side='png' AND uw.side='png'
            AND uw.publication_id IS NULL AND o.operation='declare'
            AND a.id=ANY(uw.expected_actor_ids))
        OR (hw.state='published' AND hw.side='pg' AND uw.side='pg'
            AND uw.publication_id IS NOT NULL AND o.operation='defend'
            AND o.kind='defense')))
    INTO human_stage;
  intent_stage:=auth.uid() IS NULL AND public.combat_v2_is_service() AND a.actor_kind='png'
   AND o.kind='action' AND o.operation='declare' AND o.source_payload->>'dispatch'='action' AND o.source_payload->>'kind'='passa'
   AND mission_generic_owner.unified_service_staging(c.round_id) AND EXISTS(SELECT 1 FROM mission_generic_owner.unified_round_windows uw
     JOIN mission_generic_owner.unified_batches b ON b.id=uw.batch_id JOIN mission_generic_owner.unified_publication_permits pp ON pp.batch_id=b.id AND pp.work_id=b.writer_work_id
     WHERE uw.round_id=c.round_id AND uw.publication_id IS NULL AND a.id=ANY(uw.expected_actor_ids) AND b.retired_at IS NULL
       AND pp.transaction_id=txid_current() AND pp.backend_pid=pg_backend_pid() AND mission_generic_owner.native_intent_work_v1(b.writer_work_id));
  PERFORM mission_generic_owner.unified_assert_command(c.round_id,CASE WHEN o.kind='defense' THEN 'defend' ELSE 'declare' END);
 dispatch:=o.source_payload->>'dispatch';
 IF dispatch IN ('action','movement') THEN
   IF o.source_payload->>'fireball'='true' THEN
     IF fireball_selection IS NULL THEN RAISE EXCEPTION 'fireball_selection_required';END IF;
     intent:=clan_uchiha_private.fireball_prepare(c.round_id,a.id,key,fireball_selection);
     SELECT coalesce(array_agg(value::uuid),'{}') INTO targets FROM jsonb_array_elements_text(coalesce(intent->'target_actor_ids','[]'));
   ELSE
   intent:=jsonb_build_object('kind',o.source_payload->'kind');
   IF intent->>'kind'='attacco' THEN
     IF cardinality(targets)=0 THEN RAISE EXCEPTION 'panel_target_required' USING ERRCODE='22023'; END IF;
     intent:=intent||jsonb_build_object('target_actor',targets[1],'target_actor_ids',targets,
       'ability_source',o.source_payload->'ability_source');
     IF o.source_payload ? 'ability_id' THEN intent:=intent||jsonb_build_object('ability_id',o.source_payload->'ability_id'); END IF;
   ELSIF intent->>'kind'='utilita' AND o.source_payload->>'aburame_escape'='true' THEN
     intent:=intent||jsonb_build_object('ability_source','clan','ability_id','f5e9af24-70f1-49f6-a7ca-74f59256336e');
   ELSIF dispatch='movement' THEN
     IF movement IS NULL THEN RAISE EXCEPTION 'panel_movement_required' USING ERRCODE='22023'; END IF;
   END IF;
   IF movement IS NOT NULL THEN
     IF dispatch='movement' THEN
       PERFORM combat_panel_private.prepare_master_movement(c.round_id,a.id,movement,key);
     ELSIF dispatch='action' AND intent->>'kind'='attacco' AND cardinality(targets)=1
       AND (coalesce(intent->>'ability_source','mano')='mano' OR (intent->>'ability_source'='clan' AND intent->>'ability_id' IN ('9ac77d79-9894-5388-9753-70538ac5eaa3','b076a976-c75b-4b5a-8813-b0e8e2c3af03')))
       AND combat_panel_private.movement_attack_target_valid(a.id,targets[1],movement,CASE WHEN intent->>'ability_source'='clan' THEN 2 ELSE combat_panel_private.manual_contact_center_range(a.id,targets[1]) END)
       AND (intent->>'ability_source'<>'clan' OR intent->>'ability_id'='b076a976-c75b-4b5a-8813-b0e8e2c3af03' OR (SELECT combat_spatial.distance_m(start_x_m,start_y_m,end_x_m,end_y_m)>=5 FROM combat_spatial.movement_capabilities WHERE capability_id=movement)) THEN
       PERFORM combat_panel_private.prepare_master_movement(c.round_id,a.id,movement,key);
     ELSE
       RAISE EXCEPTION 'panel_movement_attack_selection_invalid' USING ERRCODE='22023';
     END IF;
   END IF;
   END IF;
   -- The link mode belongs to this exact server offer, never to client inputs.
   IF o.source_payload->'target_fili'='true'::jsonb THEN
     IF dispatch<>'action' OR intent->>'kind'<>'attacco' OR cardinality(targets)<>1
       OR movement IS NOT NULL OR fireball_selection IS NOT NULL
       OR coalesce(intent->>'ability_source','') NOT IN ('arma','clan','jutsu')
       OR intent->>'ability_id' IS NULL THEN
       RAISE EXCEPTION 'panel_fili_target_selection_invalid' USING ERRCODE='22023';
     END IF;
     intent:=intent||jsonb_build_object('target_fili',true);
   END IF;
   IF intent->>'kind'='attacco' AND fireball_selection IS NULL THEN
     PERFORM combat_panel_private.multiplication_prepare_selected_aims(c.round_id,a.id,key,targets,resolved);
   END IF;
   IF o.source_payload#>>'{sabaku_flow,version}'='sabaku-flow/2' THEN
     IF movement IS NOT NULL OR dispatch<>'action' OR intent->>'kind'<>'attacco' THEN
       RAISE EXCEPTION 'sabaku_flow_offer_invalid' USING ERRCODE='22023'; END IF;
     -- Il totale e' congelato nell'offerta nativa, mai ricevuto come valore libero dal client.
     IF jsonb_typeof(o.source_payload#>'{sabaku_flow,quantity}') IS DISTINCT FROM 'number'
       OR (o.source_payload#>>'{sabaku_flow,quantity}') !~ '^[1-3]$' THEN
       RAISE EXCEPTION 'sabaku_flow_total_required' USING ERRCODE='22023'; END IF;
     IF (clan_sabaku_private.flow_costs(1,flow_allocations)->>'flows')::integer
       IS DISTINCT FROM (o.source_payload#>>'{sabaku_flow,quantity}')::integer THEN
       RAISE EXCEPTION 'sabaku_flow_total_allocation_mismatch' USING ERRCODE='22023'; END IF;
     PERFORM clan_sabaku_private.flow_prepare(c.round_id,a.id,key,o.id,'panel',flow_allocations);
   END IF;
   IF intent->>'ability_source'='clan' AND combat_v2_elemental_internal.suiton_profile(a.id,(intent->>'ability_id')::uuid) IS NOT NULL THEN
     PERFORM combat_v2_elemental_internal.suiton_prepare_callback('master_v2',o.id,a.id,key,
       ARRAY(SELECT value::uuid FROM jsonb_array_elements_text(p->'selected_option_ids')),p->'inputs',intent);
   END IF;
   IF intent->>'ability_source'='clan' AND combat_v2_elemental_internal.other_profile(a.id,(intent->>'ability_id')::uuid) IS NOT NULL THEN
     PERFORM combat_v2_elemental_internal.other_prepare_callback('master_v2',o.id,a.id,key,ARRAY(SELECT value::uuid FROM jsonb_array_elements_text(p->'selected_option_ids')),p->'inputs',intent);
   END IF;
   IF intent->'target_fili'='true'::jsonb THEN
     PERFORM clan_marionettisti_private.ocular_sever_authorize_v1(c.round_id,a.id,targets[1],
       intent->>'ability_source',(intent->>'ability_id')::uuid,key);
   END IF;
   v_master_actor_result:=public.combat_v2_action_declare(c.round_id,a.id,intent,p->>'narrative_text',key);
   declaration:=(v_master_actor_result#>>'{data,declaration_id}')::uuid;
 ELSIF dispatch='defense' THEN
   IF cardinality(coverages)=0 OR primary_attack IS NULL THEN RAISE EXCEPTION 'panel_coverage_required' USING ERRCODE='22023'; END IF;
   intent:=jsonb_build_object('reaction',o.source_payload->'reaction','attack_target_ids',coverages);
   IF o.source_payload ? 'ability_id' THEN intent:=intent||jsonb_build_object(
     'ability_source',o.source_payload->'ability_source','ability_id',o.source_payload->'ability_id'); END IF;
   IF o.source_payload->>'rotation_version'='hyuga-rotation/1' THEN
     PERFORM clan_hyuga_private.rotation_prepare(c.round_id,a.id,primary_attack,key,rotation_radius);
   END IF;
   IF o.source_payload->>'aburame_clone'='aburame-clone/1' THEN
     IF primary_attack IS DISTINCT FROM (o.source_payload->>'attack_id')::uuid THEN RAISE EXCEPTION 'aburame_clone_attack_drift';END IF;
     PERFORM clan_aburame_private.clone_prepare(c.round_id,a.id,primary_attack,key,(o.source_payload->>'movement_capability')::uuid);
   END IF;
   v_master_actor_result:=public.combat_v2_defense_declare(c.round_id,primary_attack,a.id,intent,p->>'narrative_text',key);
   declaration:=(v_master_actor_result#>>'{data,defense_id}')::uuid;
 ELSIF dispatch='substitution' THEN
   IF substitution IS NULL THEN RAISE EXCEPTION 'panel_substitution_required' USING ERRCODE='22023'; END IF;
   PERFORM clan_marionettisti_private.assert_jutsu_source(a.id,'jutsu','31b15861-fb78-4f8a-ac1c-ebf2d957c32e');
   IF EXISTS(SELECT 1 FROM combat_spatial.request_receipts WHERE request_key=key) THEN
     RAISE EXCEPTION 'panel_request_key_conflict' USING ERRCODE='22023'; END IF;
   v_master_actor_result:=public.combat_v2_substitution_select_v1(substitution,key);
   declaration:=(v_master_actor_result->>'defense_declaration_id')::uuid;
   -- Il selector vivo crea il testo vuoto. Completa solo la dichiarazione
   -- appena creata, ancora inviata e controllata, nella stessa transazione.
   UPDATE public.combat_v2_declarations SET declaration_text=p->>'narrative_text'
     WHERE id=declaration AND round_id=c.round_id AND actor_id=a.id AND request_key=key
       AND controller_user_snapshot=uid AND state='inviata' AND declaration_text='';
   IF NOT FOUND THEN RAISE EXCEPTION 'panel_substitution_declaration_invalid' USING ERRCODE='22023'; END IF;
 ELSE RAISE EXCEPTION 'panel_dispatch_not_available' USING ERRCODE='22023'; END IF;
 IF declaration IS NULL THEN RAISE EXCEPTION 'panel_source_receipt_invalid' USING ERRCODE='22023'; END IF;
  IF o.operation='defend' THEN
    PERFORM combat_panel_private.multiplication_register_defense_selections(c.round_id,a.id,key,resolved,declaration); END IF;
  IF a.actor_kind='png' AND EXISTS(SELECT 1 FROM mission_generic_owner.unified_round_windows uw WHERE uw.round_id=c.round_id) THEN
     IF NOT (mission_generic_owner.unified_service_staging(c.round_id) OR human_stage)
     THEN RAISE EXCEPTION 'MUF_STAGING_AUTHORITY_REQUIRED' USING ERRCODE='42501'; END IF;
    UPDATE public.combat_v2_declarations d SET controller_user_snapshot=uid
    FROM public.combat_v2_provider_instances_v1 pi
    WHERE d.id=declaration AND d.round_id=c.round_id AND d.actor_id=a.id AND d.request_key=key
       AND (d.state='inviata' OR ((human_stage OR(intent_stage AND d.kind='passa' AND v_master_actor_result#>>'{data,declaration_id}'=d.id::text AND v_master_actor_result#>>'{data,phase}'='risolto' AND v_master_actor_result#>'{data,auto_resolution}' IS NOT NULL AND v_master_actor_result#>'{data,auto_resolution}'<>'null'::jsonb)) AND d.state='risolta'
         AND d.kind IN('utilita','movimento','passa','difesa','nessuna')))
       AND d.declaration_text=coalesce(p->>'narrative_text','')
      AND d.controller_version_snapshot=a.controller_version
      AND pi.id=a.provider_instance_v1_id AND pi.session_id=a.session_id
      AND d.controller_user_snapshot=pi.narrative_version_ref;
    IF NOT FOUND AND NOT EXISTS(SELECT 1 FROM public.combat_v2_declarations d
      WHERE d.id=declaration AND d.round_id=c.round_id AND d.actor_id=a.id AND d.request_key=key
        AND d.state IN ('inviata','risolta') AND d.declaration_text=coalesce(p->>'narrative_text','')
        AND d.controller_version_snapshot=a.controller_version AND d.controller_user_snapshot=uid)
    THEN RAISE EXCEPTION 'MG_DECLARATION_AUTHORITY_INVALID' USING ERRCODE='42501'; END IF;
  END IF;
  -- Solo Passa nativo senza role: l'offerta effettiva è attestata prima del publisher
 -- nella stessa TX. La receipt finale segue normalmente; ogni errore annulla tutto.
 IF a.actor_kind='png' AND NOT o.requires_role AND o.kind='action' AND o.operation='declare'
   AND o.source_payload->>'kind'='passa' AND intent->>'kind'='passa'
    AND nullif(btrim(p->>'narrative_text'),'') IS NULL
    AND EXISTS(SELECT 1 FROM mission_generic_owner.unified_round_windows uw WHERE uw.round_id=c.round_id) THEN
    IF NOT (mission_generic_owner.unified_service_staging(c.round_id) OR human_stage) OR NOT EXISTS(
     SELECT 1 FROM public.combat_v2_declarations pd WHERE pd.id=declaration AND pd.round_id=c.round_id
       AND pd.actor_id=a.id AND pd.request_key=key AND pd.kind='passa'
       AND (pd.state='inviata' OR (pd.state='risolta' AND human_stage
          AND v_master_actor_result#>>'{data,declaration_id}'=pd.id::text
          AND v_master_actor_result#>>'{data,phase}'='risolto'
          AND v_master_actor_result#>'{data,auto_resolution}' IS NOT NULL
          AND v_master_actor_result#>'{data,auto_resolution}'<>'null'::jsonb))
       AND pd.controller_user_snapshot=uid AND pd.controller_version_snapshot=a.controller_version
       AND pd.declaration_text=coalesce(p->>'narrative_text','')) THEN
     RAISE EXCEPTION 'MUF_ROLELESS_PASS_SCOPE' USING ERRCODE='42501'; END IF;
   UPDATE combat_panel_private.offers SET state='consumed',consumed_request_key=key
     WHERE id=o.id AND principal_user=uid AND context_id=c.id AND actor_id=a.id AND state='offered';
   IF NOT FOUND THEN RAISE EXCEPTION 'MUF_ROLELESS_PASS_OFFER' USING ERRCODE='40001'; END IF;
 END IF;
 PERFORM combat_panel_private.publish_master_declaration(declaration,p->>'narrative_text');
 SELECT value->>'display_name' INTO label FROM jsonb_array_elements(env->'actors') WHERE value->>'actor_id'=a.id::text;
 IF cardinality(targets)>0 THEN
   SELECT value->>'display_name' INTO target_label FROM jsonb_array_elements(env->'actors') WHERE value->>'actor_id'=targets[1]::text;
 END IF;
 event:=jsonb_build_object('event_id',receipt_id,'event_kind','action_declared','actor_id',a.id,'display_name',label,
   'label_version',c.context_version,'target_actor_id',CASE WHEN target_label IS NOT NULL THEN targets[1] END,
   'target_display_name',target_label,'target_label_version',CASE WHEN target_label IS NOT NULL THEN c.context_version END,
   'summary',CASE WHEN o.operation='defend' THEN 'Difesa registrata' ELSE 'Azione registrata' END);
 env:=combat_panel_private.master_projection(c.location_id,a.id);
 IF env->>'status'='blocked' AND env->>'reason_code'='REGIA_FATO_PENDING' THEN
  IF a.actor_kind<>'pg' OR o.kind<>'action' OR o.operation<>'declare'
   OR NOT mission_narrative_internal.scene_native_round_bound_v1(
      (SELECT master_session_id FROM public.combat_v2_sessions WHERE id=c.activity_id),c.round_id)
   OR NOT EXISTS(SELECT 1 FROM public.combat_v2_declarations accepted
     JOIN public.combat_v2_rounds rr ON rr.id=accepted.round_id AND rr.session_id=c.activity_id
     JOIN public.combat_v2_round_reports report ON report.id=rr.report_id AND report.round_id=rr.id
     JOIN public.combat_v2_events action_event ON action_event.scope_id=rr.id
      AND action_event.request_key=accepted.request_key AND action_event.operation_kind='combat_v2_action_declare'
     WHERE accepted.id=declaration AND accepted.round_id=c.round_id AND accepted.actor_id=a.id
      AND accepted.kind IN('attacco','utilita','movimento','passa') AND accepted.state='risolta'
      AND accepted.request_key=key AND accepted.controller_user_snapshot=uid
      AND accepted.controller_version_snapshot=a.controller_version
      AND accepted.declaration_text=coalesce(p->>'narrative_text','')
      AND action_event.status='completata' AND action_event.caller=uid
      AND action_event.result=v_master_actor_result AND v_master_actor_result#>>'{data,declaration_id}'=accepted.id::text
      AND v_master_actor_result#>>'{data,phase}'='risolto'
      AND v_master_actor_result#>>'{data,auto_resolution,data,report_id}'=report.id::text
      AND rr.state='risolto' AND report.narration_state='attesa' AND NOT report.values_written
      AND report.mechanics_sha256=public.combat_v2_sha256(report.mechanics))
  THEN RAISE EXCEPTION 'NATIVE_PENDING_ACK_SCOPE' USING ERRCODE='42501';END IF;
  -- A public frame has not been projected. Report the real retained panel
  -- context version, not a synthetic increment or a version from private data.
  SELECT context_version INTO STRICT ack_context_version FROM combat_panel_private.contexts
   WHERE id=c.id AND principal_user=uid AND command_actor_id=a.id
    AND activity_id=c.activity_id AND round_id=c.round_id AND location_id=c.location_id;
  IF ack_context_version<o.context_version THEN RAISE EXCEPTION 'NATIVE_PENDING_ACK_VERSION' USING ERRCODE='40001';END IF;
 ELSE
  ack_context_version:=(env#>>'{context,version}')::bigint;
 END IF;
 receipt:=jsonb_build_object('receipt_id',receipt_id,'request_key',key,'operation',o.operation,'replayed',false,
   'activity_id',c.activity_id,'round_id',c.round_id,'context_version_before',o.context_version,
   'context_version_after',ack_context_version,'declaration_id',declaration,'report_id',NULL,
   'values_written',false,'display_events',jsonb_build_array(event));
 env:=jsonb_set(env,'{receipt}',receipt);
 UPDATE combat_panel_private.offers SET state='consumed',consumed_request_key=key WHERE id=o.id;
 INSERT INTO combat_panel_private.request_receipts(principal_user,request_key,command_fingerprint,offer_id,event_id,viewer_envelope)
   VALUES(uid,key,fp,o.id,receipt_id,env);
 RETURN env;
END $function$;

CREATE OR REPLACE FUNCTION combat_consumer_private.exchange_options(p_envelope jsonb)
 RETURNS jsonb
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO ''
AS $function$
declare ctx combat_consumer_private.activities%rowtype; aid uuid; target uuid; attack uuid;
  akimichi_offer jsonb; scene integer; offers jsonb:='[]'; reaction text; caps jsonb; offered jsonb; pending jsonb; anchor_option jsonb;
  fili record;
begin
  select * into ctx from combat_consumer_private.activities where session_id=(p_envelope#>>'{context,activity_id}')::uuid;
  aid:=(p_envelope#>>'{viewer,actor_id}')::uuid; scene:=(p_envelope#>>'{context,scene_version}')::integer;
  if aid is null and public.is_staff() then return p_envelope; end if;
  if not exists(select 1 from combat_consumer_private.members m join public.characters c on c.id=m.character_id
    where m.session_id=ctx.session_id and m.actor_id=aid and c.user_id=auth.uid()) then
    perform combat_consumer_private.fail('not_participant');
  end if;
  if ctx.phase='action' and ctx.turn_actor_id=aid then
    select actor_id into target from combat_consumer_private.members where session_id=ctx.session_id and actor_id<>aid;
    IF clan_hoki_private.needle_ability(aid,false) IS NOT NULL
      AND clan_hoki_private.needle_target_valid(aid,target)
      AND EXISTS(SELECT 1 FROM public.combat_v2_actors a WHERE a.id=aid AND
        (a.mechanics_snapshot->>'chakra')::integer>=(clan_hyuga_private.sedici_cost_quote(a.id,5)->>'total')::integer) THEN
      offered:=combat_consumer_private.offer_exchange(ctx.session_id,aid,target,scene,'declare','Aghi Velenosi',
        jsonb_build_object('intent',jsonb_build_object('kind','attacco','ability_source','clan',
          'ability_id','127f3854-4183-4354-a654-f59320d8807e','target_actor',target)));
      IF offered IS NOT NULL THEN offers:=offers||jsonb_build_array(offered); END IF;
    END IF;
    IF clan_hoki_private.body_available(aid) THEN
      offered:=combat_consumer_private.offer_exchange(ctx.session_id,aid,NULL,scene,'control',
        clan_hoki_private.body_offer_label(aid),jsonb_build_object('hoki_operation','body_on'));
      IF offered IS NOT NULL THEN offers:=offers||jsonb_build_array(offered); END IF;
    END IF;
    IF combat_panel_private.shuriken_available_v1(aid) IS NOT NULL
      AND combat_panel_private.shuriken_target_v1(aid,target) THEN
      offered:=combat_consumer_private.offer_exchange(ctx.session_id,aid,target,scene,'declare',
        combat_panel_private.shuriken_profile_v1()->>'name',
        jsonb_build_object('intent',jsonb_build_object('kind','attacco','ability_source','arma',
          'ability_id',combat_panel_private.shuriken_profile_v1()->'id','target_actor',target)));
      IF offered IS NOT NULL THEN offers:=offers||jsonb_build_array(offered); END IF;
    END IF;
    caps:=combat_consumer_private.approach_capabilities(ctx.session_id,aid,target);
    if combat_consumer_private.melee_eligible(ctx.session_id,aid,target) or jsonb_array_length(caps)>0 then
      offered:=combat_consumer_private.offer_exchange(ctx.session_id,aid,target,scene,'declare',
        'Colpo a mani nude',jsonb_build_object('intent',jsonb_build_object('kind','attacco','ability_source','mano','target_actor',target)));
      offered:=combat_consumer_private.attach_movement(offered,caps,aid,target);
      if offered is not null then offers:=offers||jsonb_build_array(offered); end if;
    end if;
    IF public.combat_v2_actor_ability(aid,'clan','214af896-15f8-43e6-858b-614d2851dd3b'::uuid,false)
         ->>'akimichi_partial_contract'='akimichi-partial/1'
       AND clan_akimichi_private.partial_target_valid(aid,target) THEN
      offers:=offers||jsonb_build_array(combat_consumer_private.offer_exchange(
        ctx.session_id,aid,target,scene,'declare','Espansione Parziale',
        jsonb_build_object('akimichi_partial_offer','akimichi-partial/1',
          'intent',jsonb_build_object('kind','attacco','ability_source','clan',
          'ability_id','214af896-15f8-43e6-858b-614d2851dd3b','target_actor',target))));
    END IF;
    akimichi_offer:=clan_akimichi_private.form_change_offer(aid);
    IF akimichi_offer IS NOT NULL THEN
      offers:=offers||jsonb_build_array(combat_consumer_private.offer_exchange(
        ctx.session_id,aid,NULL,scene,'control',akimichi_offer->>'label',
        jsonb_build_object('akimichi_operation',akimichi_offer->>'operation','turn',akimichi_offer->'turn')));
    END IF;
    IF target IS NOT NULL AND combat_panel_private.nara_offer_meta_v1(aid,false,target) IS NOT NULL THEN
      offered:=combat_consumer_private.offer_exchange(
        ctx.session_id,aid,target,scene,'declare','Possesso dell''Ombra',
        jsonb_build_object('nara_offer','nara-possession/1',
          'intent',jsonb_build_object('kind','attacco','ability_source','clan',
            'ability_id','db51e5ae-8b90-4c3a-a51d-962eb9e19b38','target_actor',target)));
      IF offered IS NOT NULL THEN offers:=offers||jsonb_build_array(offered); END IF;
    END IF;
    -- W12: a principal Passa consumes the native main action, without attack or invented facing.
    IF EXISTS(
 SELECT 1 FROM combat_consumer_private.activities turn_scope
 JOIN public.combat_v2_sessions turn_session ON turn_session.id=turn_scope.session_id
 JOIN public.locations turn_location ON turn_location.id=turn_session.location_id
 JOIN combat_panel_private.multiplication_tactics_release_gate turn_gate
   ON turn_gate.singleton AND turn_gate.version>=1
     AND turn_gate.revision_reference='combat-multiplication-tactics/1'
 WHERE turn_scope.session_id=ctx.session_id AND turn_scope.phase='action'
   AND turn_session.source_kind='ordinary' AND turn_session.master_session_id IS NULL
   AND turn_session.state='in_corso' AND turn_session.closed_at IS NULL
   AND turn_scope.location_id=turn_session.location_id AND turn_location.is_active
   AND turn_scope.user_test_context_id IS NULL
   AND (SELECT count(*)=2 AND count(DISTINCT m.character_id)=2
     AND bool_and(coalesce(a.actor_kind='pg' AND a.companion_id IS NULL
       AND a.character_id=m.character_id AND a.controller_user=ch.user_id,false))
     FROM combat_consumer_private.members m
     JOIN public.combat_v2_actors a ON a.id=m.actor_id AND a.session_id=turn_session.id
     JOIN public.characters ch ON ch.id=m.character_id
     WHERE m.session_id=turn_session.id)
   AND (
    (turn_gate.staff_enabled AND turn_location.is_test
      AND turn_location.id='0b85f354-9cdb-47e1-baf9-3d266bb7e06b'::uuid
      AND turn_scope.policy_id='staff_test_no_persistent_resources_v1'
      AND combat_panel_private.uses_simulated_pools(turn_session.id)
      AND NOT public.combat_v2_values_written(turn_session.id)
      AND combat_consumer_private.staff_test_allowed(turn_location.id,
        ARRAY(SELECT a.controller_user FROM combat_consumer_private.members m
          JOIN public.combat_v2_actors a ON a.id=m.actor_id AND a.session_id=turn_session.id
          WHERE m.session_id=turn_session.id ORDER BY a.id),false))
    OR (turn_gate.ordinary_enabled AND NOT turn_location.is_test AND NOT turn_location.is_exam_room)
   )
) THEN
      offers:=offers||jsonb_build_array(combat_consumer_private.offer_exchange(
        ctx.session_id,aid,NULL,scene,'declare','Passa · concludi il turno senza attacco',
        jsonb_build_object('intent',jsonb_build_object('kind','passa'))));
    END IF;
  elsif ctx.phase='defense' and (ctx.turn_actor_id<>aid OR clan_uchiha_private.fireball_pending(ctx.exchange_id,aid)) then
    select d.id into attack from public.combat_v2_declarations d
      where d.round_id=ctx.exchange_id and d.kind='attacco' and (d.target_actor_id=aid OR EXISTS(SELECT 1 FROM clan_uchiha_private.fireball_sources src JOIN public.combat_v2_attack_targets t ON t.attack_declaration_id=src.declaration_id WHERE src.declaration_id=d.id AND t.target_actor_id=aid AND t.state='attesa_difesa'))
        and exists(select 1 from public.combat_v2_attack_targets mt where mt.attack_declaration_id=d.id
          and mt.target_actor_id=aid and not combat_panel_private.multiplication_no_defense(mt.id))
        and not exists(select 1 from public.combat_v2_declarations x where x.parent_attack_id=d.id and x.actor_id=aid);
    if attack is not null then
      foreach reaction in array array['schivata','parata','nessuna'] loop
        offers:=offers||jsonb_build_array(combat_consumer_private.offer_exchange(ctx.session_id,aid,ctx.turn_actor_id,scene,'defend',
          case reaction when 'schivata' then 'Schivata' when 'parata' then 'Parata' else 'Nessuna difesa' end,
          jsonb_build_object('attack_id',attack,'intent',jsonb_build_object('reaction',reaction))));
      end loop;
      IF EXISTS(SELECT 1 FROM public.combat_v2_declarations fd WHERE fd.id=attack
         AND fd.sanitized_intent#>>'{server_ability,sabaku_flow_version}'='sabaku-flow/2') THEN
       BEGIN
        PERFORM clan_marionettisti_private.assert_jutsu_source(aid,'jutsu','31b15861-fb78-4f8a-ac1c-ebf2d957c32e');
        caps:=public.combat_v2_round_options(ctx.exchange_id,aid)#>'{data,substitution_offers}';
        FOR pending IN SELECT value FROM jsonb_array_elements(coalesce(caps,'[]'::jsonb)) LOOP
         IF pending->>'attack_declaration_id' IS DISTINCT FROM attack::text THEN CONTINUE; END IF;
         FOR anchor_option IN SELECT value FROM jsonb_array_elements(coalesce(pending#>'{offer,options}','[]'::jsonb)) LOOP
          offers:=offers||jsonb_build_array(combat_consumer_private.offer_exchange(ctx.session_id,aid,ctx.turn_actor_id,scene,'defend',
            'Sostituzione: '||coalesce(anchor_option->>'label','Punto disponibile'),
            jsonb_build_object('attack_id',attack,'intent',jsonb_build_object('reaction','sostituzione'),
              'flow_substitution','flow-substitution/1','substitution_option_id',anchor_option->'option_id')));
         END LOOP;
        END LOOP;
       EXCEPTION WHEN SQLSTATE '22023' THEN
        IF SQLERRM<>'fili_other_jutsu_unavailable' THEN RAISE; END IF;
       END;
      END IF;
      IF EXISTS(SELECT 1 FROM public.combat_v2_declarations fd WHERE fd.id=attack
         AND fd.target_actor_id=aid
         AND clan_uchiha_private.fireball_source_valid(fd.id)) THEN
       BEGIN
        PERFORM clan_marionettisti_private.assert_jutsu_source(aid,'jutsu','31b15861-fb78-4f8a-ac1c-ebf2d957c32e');
        caps:=public.combat_v2_round_options(ctx.exchange_id,aid)#>'{data,substitution_offers}';
        FOR pending IN SELECT value FROM jsonb_array_elements(coalesce(caps,'[]'::jsonb)) LOOP
         IF pending->>'attack_declaration_id' IS DISTINCT FROM attack::text THEN CONTINUE; END IF;
         FOR anchor_option IN SELECT value FROM jsonb_array_elements(coalesce(pending#>'{offer,options}','[]'::jsonb)) LOOP
          offers:=offers||jsonb_build_array(combat_consumer_private.offer_exchange(ctx.session_id,aid,ctx.turn_actor_id,scene,'defend',
            'Sostituzione: '||coalesce(anchor_option->>'label','Punto disponibile'),
            jsonb_build_object('attack_id',attack,'intent',jsonb_build_object('reaction','sostituzione'),
              'fireball_substitution','fireball-substitution/1','substitution_option_id',anchor_option->'option_id')));
         END LOOP;
        END LOOP;
       EXCEPTION WHEN SQLSTATE '22023' THEN
        IF SQLERRM<>'fili_other_jutsu_unavailable' THEN RAISE; END IF;
       END;
      END IF;
    end if;
  end if;
  -- INUZUKA-CURRENT-OFFERS-CACHE-AND-FOCUSED-QA-20260922-011
  -- INUZUKA-EXACT-STAFF-FIXTURE-20260922-017
  -- INUZUKA-AUTHORIZED-TESTPERFUNZIONI-20260922-018
  if auth.uid()='15448f47-3b43-416f-a703-dbe7a74d36ce'::uuid and exists(
    select 1 from public.combat_v2_actors qa
    join public.characters pg on pg.id=qa.character_id
    where qa.id=aid and qa.controller_user=auth.uid()
      and pg.id='2a877f02-4993-4e65-9172-7d29f08c5b86'::uuid
      and pg.clan='Nessuno'
      and ctx.policy_id='staff_test_no_persistent_resources_v1'
      and ctx.location_id='0b85f354-9cdb-47e1-baf9-3d266bb7e06b'::uuid
      and not public.combat_v2_values_written(ctx.session_id)
      and (select count(distinct ability->>'id') from jsonb_array_elements(
        case when jsonb_typeof(qa.mechanics_snapshot->'abilities')='array'
          then qa.mechanics_snapshot->'abilities' else '[]'::jsonb end) ability
        where ability->>'source'='clan' and ability->>'id' in(
          'b0748ef4-bea8-4d85-95a1-7d9db1b4381c',
          'c11ecd52-43cd-479b-8d5d-08187beba56e',
          'b076a976-c75b-4b5a-8813-b0e8e2c3af03'))=3
      and exists(select 1 from jsonb_array_elements(
        case when jsonb_typeof(qa.mechanics_snapshot->'abilities')='array'
          then qa.mechanics_snapshot->'abilities' else '[]'::jsonb end) ability
        where ability->>'source'='clan'
          and ability->>'id'='6d7c0804-1ba9-4e49-8697-1a550f3608b2')
      and not exists(select 1 from jsonb_array_elements(
        case when jsonb_typeof(qa.mechanics_snapshot->'abilities')='array'
          then qa.mechanics_snapshot->'abilities' else '[]'::jsonb end) ability
        where ability->>'source'='clan' and (ability->>'id' is null or ability->>'id' not in(
          'b0748ef4-bea8-4d85-95a1-7d9db1b4381c',
          'c11ecd52-43cd-479b-8d5d-08187beba56e',
          'b076a976-c75b-4b5a-8813-b0e8e2c3af03',
          '6d7c0804-1ba9-4e49-8697-1a550f3608b2')))
  ) then
    -- INUZUKA-EXACT-STAFF-CATALOG-20260922-025
    return clan_inuzuka_private.consumer_options(jsonb_set(p_envelope,'{offers}','[]'::jsonb));
  end if;
  if public.is_staff() and exists(
    select 1 from public.combat_v2_actors qa
    join public.characters pg on pg.id=qa.character_id
    where qa.id=aid and pg.clan='Nessuno'
      and ctx.policy_id='staff_test_no_persistent_resources_v1'
      and ctx.location_id='0b85f354-9cdb-47e1-baf9-3d266bb7e06b'::uuid
      and not public.combat_v2_values_written(ctx.session_id)
      and (select count(distinct ability->>'id') from jsonb_array_elements(
        case when jsonb_typeof(qa.mechanics_snapshot->'abilities')='array'
          then qa.mechanics_snapshot->'abilities' else '[]'::jsonb end) ability
        where ability->>'source'='clan' and ability->>'id' in(
          'b0748ef4-bea8-4d85-95a1-7d9db1b4381c',
          'c11ecd52-43cd-479b-8d5d-08187beba56e',
          'b076a976-c75b-4b5a-8813-b0e8e2c3af03'))=3
      and not exists(select 1 from jsonb_array_elements(
        case when jsonb_typeof(qa.mechanics_snapshot->'abilities')='array'
          then qa.mechanics_snapshot->'abilities' else '[]'::jsonb end) ability
        -- INUZUKA-FOCUSED-QA-CATALOG-MACRO-20260922-012
        where ability->>'source'='clan' and (
          ability->>'id' is null
          or ability->>'id' !~* '^[0-9a-f]{8}-[0-9a-f]{4}-[1-5][0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}$'
          or (ability->>'id' not in(
            'b0748ef4-bea8-4d85-95a1-7d9db1b4381c',
            'c11ecd52-43cd-479b-8d5d-08187beba56e',
            'b076a976-c75b-4b5a-8813-b0e8e2c3af03')
            and not exists(select 1 from public.clan_techniques generic_technique
              where generic_technique.id=case when ability->>'id' ~* '^[0-9a-f]{8}-[0-9a-f]{4}-[1-5][0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}$' then (ability->>'id')::uuid else null::uuid end
                and generic_technique.macro is distinct from 'clan'))))
  ) then
    return clan_inuzuka_private.consumer_options(jsonb_set(p_envelope,'{offers}',offers));
  end if;
  p_envelope:=clan_inuzuka_private.consumer_options(clan_aburame_private.consumer_options(combat_v2_elemental_internal.scudo_consumer_options(combat_v2_elemental_internal.other_substitution_options(combat_v2_elemental_internal.other_consumer_options(combat_v2_elemental_internal.suiton_substitution_options(combat_v2_elemental_internal.suiton_consumer_options(clan_hyuga_private.rotation_consumer_options(clan_uchiha_private.fireball_consumer_options(clan_hyuga_private.sedici_consumer_options(clan_innata_private.sharingan_consumer_options(clan_hyuga_private.consumer_options(clan_sabaku_private.consumer_options(clan_marionettisti_private.consumer_options(jsonb_set(p_envelope,'{offers}',offers)))))))))))))));

  IF ctx.phase IS DISTINCT FROM 'action' OR ctx.turn_actor_id IS DISTINCT FROM aid
     OR p_envelope->>'status' IS DISTINCT FROM 'ready' THEN RETURN p_envelope; END IF;
  IF NOT EXISTS (
    SELECT 1 FROM clan_marionettisti_private.links l
    JOIN public.combat_v2_actors b ON b.id=l.companion_actor_id
    WHERE b.session_id=ctx.session_id AND l.state='connected' AND l.owner_actor_id<>aid
  ) THEN RETURN p_envelope; END IF;

  offers:=coalesce(p_envelope->'offers','[]'::jsonb);
  FOR fili IN
    WITH compatible_offers AS MATERIALIZED (
      SELECT DISTINCT o.source_payload#>>'{intent,ability_source}' AS ability_source,
        (o.source_payload#>>'{intent,ability_id}')::uuid AS ability_id
      FROM jsonb_array_elements(offers) offered_option(value)
      JOIN combat_consumer_private.offers o ON o.id=(offered_option.value->>'offer_id')::uuid
        AND o.session_id=ctx.session_id AND o.exchange_id=ctx.exchange_id
        AND o.context_version=ctx.context_version AND o.scene_version=scene
        AND o.state='offered' AND o.operation='declare' AND o.offer_kind='action'
      JOIN combat_consumer_private.members m ON m.session_id=ctx.session_id
        AND m.actor_id=aid AND m.character_id=o.principal_character_id
      WHERE o.viewer_projection=offered_option.value
        AND o.source_payload#>>'{intent,kind}'='attacco'
        AND o.source_payload#>>'{intent,ability_source}' IN ('clan','jutsu')
        AND nullif(o.source_payload#>>'{intent,ability_id}','') IS NOT NULL
        AND jsonb_typeof(o.source_payload->'intent')='object'
        AND (o.source_payload->'intent')-ARRAY['kind','ability_source','ability_id','target_actor']='{}'::jsonb
        -- Area selection, movement plans and PG-specific preparations remain native to their own targets.
        AND o.source_payload-'intent'='{}'::jsonb
    ), sources AS MATERIALIZED (
      SELECT 'arma'::text AS ability_source,(w.meta->>'id')::uuid AS ability_id,w.meta,'{}'::jsonb AS native_fields
      FROM (SELECT combat_panel_private.shuriken_available_v1(aid) AS meta) w
      WHERE w.meta IS NOT NULL
      UNION ALL
      SELECT o.ability_source,o.ability_id,
        public.combat_v2_actor_ability(aid,o.ability_source,o.ability_id,false),'{}'::jsonb
      FROM compatible_offers o
      UNION ALL
      -- Keep the elemental preparation's neutral choice and native quote, even when the PG is out of range.
      -- The common range helper decides which of these direct elemental profiles can target Fili.
      SELECT 'clan',g.technique_id,public.combat_v2_actor_ability(aid,'clan',g.technique_id,false),
        jsonb_build_object('other_push_requested',false)
      FROM combat_v2_elemental_internal.other_gates g
      WHERE g.enabled AND combat_v2_elemental_internal.other_quote(aid,g.technique_id) IS NOT NULL
    ), ranges AS MATERIALIZED (
      SELECT ss.*,clan_marionettisti_private.ocular_sever_attack_range_v1(
        aid,ss.ability_source,ss.ability_id,ss.meta) AS range_m
      FROM sources ss WHERE ss.meta IS NOT NULL
        AND (ss.meta->>'elementali_profile_version' IS DISTINCT FROM 'elementali-genin/1'
          OR ss.native_fields->'other_push_requested'='false'::jsonb)
    ), candidates AS MATERIALIZED (
      SELECT r.ability_source,r.ability_id,r.meta,r.native_fields,l.companion_actor_id,
        clan_marionettisti_private.ocular_sever_source_v1(ctx.exchange_id,aid,l.companion_actor_id,r.range_m) AS proof
      FROM ranges r CROSS JOIN clan_marionettisti_private.links l
      JOIN public.combat_v2_actors b ON b.id=l.companion_actor_id AND b.session_id=ctx.session_id
      WHERE r.range_m IS NOT NULL AND l.state='connected' AND l.owner_actor_id<>aid
    )
    SELECT * FROM candidates WHERE proof IS NOT NULL
    ORDER BY ability_source,ability_id,companion_actor_id
  LOOP
    offered:=combat_consumer_private.offer_exchange(ctx.session_id,aid,fili.companion_actor_id,scene,'declare',
      fili.meta->>'name',fili.native_fields||jsonb_build_object(
        'fili_ocular_link',fili.proof,
        'intent',jsonb_build_object('kind','attacco','ability_source',fili.ability_source,
          'ability_id',fili.ability_id,'target_actor',fili.companion_actor_id,'target_fili',true)));
    offers:=offers||jsonb_build_array(offered);
  END LOOP;
  RETURN jsonb_set(p_envelope,'{offers}',offers);
end $function$;

CREATE OR REPLACE FUNCTION combat_consumer_private.offer_exchange(p_session uuid, p_actor uuid, p_target uuid, p_scene integer, p_operation text, p_label text, p_source jsonb)
 RETURNS jsonb
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO ''
AS $function$
declare technique_meta jsonb; technique_quote jsonb; oid uuid:=gen_random_uuid(); label jsonb; cid uuid; projection jsonb;
  p_ctx combat_consumer_private.activities%rowtype;
begin
  select * into strict p_ctx from combat_consumer_private.activities where session_id=p_session;
  select character_id into cid from combat_consumer_private.members
    where session_id=p_ctx.session_id and actor_id=p_actor;
  if p_target is not null then
    label:=combat_consumer_private.display_label(p_ctx.session_id,p_target,p_actor,null);
  end if;
  IF p_source#>>'{intent,ability_source}' IN ('clan','jutsu') AND p_source#>>'{intent,ability_id}' IS NOT NULL THEN
    technique_meta:=public.combat_v2_actor_ability(p_actor,p_source#>>'{intent,ability_source}',(p_source#>>'{intent,ability_id}')::uuid,p_operation='defend');
    IF technique_meta IS NOT NULL THEN
      technique_quote:=clan_hyuga_private.sedici_cost_quote(p_actor,coalesce((technique_meta->>'chakra_cost')::integer,0));
      IF (technique_quote->>'total')::integer>0 THEN
        p_label:=coalesce(technique_meta->>'name',p_label)||' · '||(technique_quote->>'total')||' chakra';
      END IF;
    END IF;
  END IF;
  p_label:=combat_v2_elemental_internal.suiton_offer_label(p_actor,p_source,p_label);
  p_label:=combat_v2_elemental_internal.other_offer_label(p_actor,p_source,p_label);
  IF p_source#>'{intent,target_fili}'='true'::jsonb THEN
    p_label:=p_label||' · Fili di Chakra';
  END IF;
  projection:=jsonb_build_object('offer_id',oid,'kind',case p_operation when 'declare' then 'action' when 'control' then 'control' else 'defense' end,
    'operation',p_operation,'label',p_label,'source_id',gen_random_uuid(),
    'target_actor_id',p_target,'target_display_name',label->>'display_name',
    'movement_required',false,'movement_options','[]'::jsonb,'context_version',p_ctx.context_version,'scene_version',p_scene);
  insert into combat_consumer_private.offers(id,location_id,session_id,exchange_id,principal_character_id,
    context_version,scene_version,operation,offer_kind,source_payload,viewer_projection)
    values(oid,p_ctx.location_id,p_ctx.session_id,p_ctx.exchange_id,cid,p_ctx.context_version,p_scene,
      p_operation,case p_operation when 'declare' then 'action' when 'control' then 'control' else 'defense' end,p_source,projection);
  return projection;
end $function$;

CREATE OR REPLACE FUNCTION combat_consumer_private.commit_exchange(p jsonb, prepared jsonb)
 RETURNS jsonb
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO ''
AS $function$
declare ctx combat_consumer_private.activities%rowtype; offer combat_consumer_private.offers%rowtype;
  aid uuid:=(prepared->>'actor_id')::uuid; cid uuid:=(prepared->>'principal_character_id')::uuid;
  key uuid:=(p->>'request_key')::uuid; event jsonb; event_id uuid; result jsonb; resolve_key uuid;
  suiton_profile jsonb; selection jsonb; multiplication_aim_valid boolean; declaration uuid; report public.combat_v2_round_reports%rowtype; envelope jsonb;
  label jsonb; target_label jsonb; target uuid; display_event jsonb; receipt jsonb; movement jsonb; round_phase text;
  fili_source text; fili_ability uuid; fili_meta jsonb; fili_range numeric; fili_current jsonb;
begin
  select * into ctx from combat_consumer_private.activities where session_id=(p->>'activity_id')::uuid for update;
  select * into offer from combat_consumer_private.offers where id=(p->>'offer_id')::uuid for update;
  if p->>'operation' not in ('declare','defend','control') then
    perform combat_consumer_private.fail('adapter_not_ready',key);
  end if;
  IF offer.source_payload#>>'{sabaku_flow,version}'='sabaku-flow/2' AND p->>'movement_offer_id' IS NOT NULL THEN RAISE EXCEPTION 'sabaku_flow_attached_movement_not_supported' USING ERRCODE='22023'; END IF;
  IF p->>'operation'='control' AND offer.source_payload->>'inuzuka_operation' IN ('bind','move','staff_profile','activate','deactivate') THEN
    RETURN clan_inuzuka_private.commit_control(p,prepared);
  END IF;
  IF p->>'operation'='control' AND offer.source_payload->>'akimichi_operation' IN ('activate','deactivate') THEN
    RETURN clan_akimichi_private.commit_ordinary_form(p,prepared);
  END IF;
  event:=public.combat_v2_event_begin(offer.id,key,'combat_consumer_'||(p->>'operation'),p);
  event_id:=(event->>'event_id')::uuid;
  IF p->>'operation'='control' THEN
    IF offer.source_payload->>'hoki_operation'='body_on' THEN
      RETURN clan_hoki_private.commit_ordinary_body(p,prepared,ctx,offer,event_id);
    END IF;
    IF offer.source_payload->>'aburame_operation'='release_stop' THEN
      RETURN clan_aburame_private.commit_control(p,prepared,ctx,offer,event_id);
    END IF;
    PERFORM combat_consumer_private.fail('offer_not_available',key);
  END IF;
  IF offer.source_payload->>'akimichi_partial_offer'='akimichi-partial/1'
    AND public.combat_v2_actor_ability(aid,'clan','214af896-15f8-43e6-858b-614d2851dd3b'::uuid,false)
      ->>'akimichi_partial_contract' IS DISTINCT FROM 'akimichi-partial/1' THEN
    PERFORM combat_consumer_private.fail('offer_not_available',key);
  END IF;
  IF offer.source_payload->>'nara_offer'='nara-possession/1' AND (
    p->>'movement_offer_id' IS NOT NULL
    OR combat_panel_private.nara_offer_meta_v1(aid,false) IS NULL
  ) THEN
    PERFORM combat_consumer_private.fail('offer_not_available',key);
  END IF;
  IF offer.source_payload#>'{intent,target_fili}'='true'::jsonb THEN
    IF p->>'operation' IS DISTINCT FROM 'declare'
       OR offer.source_payload#>>'{intent,kind}' IS DISTINCT FROM 'attacco'
       OR p->>'movement_offer_id' IS NOT NULL
       OR jsonb_typeof(offer.source_payload->'fili_ocular_link') IS DISTINCT FROM 'object' THEN
      PERFORM combat_consumer_private.fail('offer_not_available',key);
    END IF;
    fili_source:=offer.source_payload#>>'{intent,ability_source}';
    fili_ability:=(offer.source_payload#>>'{intent,ability_id}')::uuid;
    fili_meta:=CASE WHEN fili_source='arma' THEN combat_panel_private.shuriken_available_v1(aid)
      ELSE public.combat_v2_actor_ability(aid,fili_source,fili_ability,false) END;
    fili_range:=clan_marionettisti_private.ocular_sever_attack_range_v1(aid,fili_source,fili_ability,fili_meta);
    IF fili_meta IS NULL OR fili_range IS NULL
       OR (fili_meta->>'elementali_profile_version'='elementali-genin/1' AND (
         offer.source_payload->'other_push_requested' IS DISTINCT FROM 'false'::jsonb
         OR combat_v2_elemental_internal.other_quote(aid,fili_ability) IS NULL
       )) THEN
      PERFORM combat_consumer_private.fail('offer_not_available',key);
    END IF;
    fili_current:=clan_marionettisti_private.ocular_sever_source_v1(
      ctx.exchange_id,aid,(offer.source_payload#>>'{intent,target_actor}')::uuid,fili_range);
    IF fili_current IS NULL OR fili_current IS DISTINCT FROM offer.source_payload->'fili_ocular_link' THEN
      PERFORM combat_consumer_private.fail('offer_not_available',key);
    END IF;
    PERFORM clan_marionettisti_private.ocular_sever_authorize_v1(
      ctx.exchange_id,aid,(offer.source_payload#>>'{intent,target_actor}')::uuid,fili_source,fili_ability,key);
  END IF;
  if p->>'movement_offer_id' is not null then
    movement:=combat_consumer_private.commit_movement(offer.id,(p->>'movement_offer_id')::uuid,aid,key);
  end if;
  if movement is not null AND EXISTS(SELECT 1 FROM combat_panel_private.movement_cost_receipts cost
      WHERE cost.event_id=(movement->>'event_id')::uuid AND clan_sabaku_private.clone_movement_interruption(cost.capability_id) IS NOT NULL) then
    perform clan_sabaku_private.clone_record_interrupted_movement((SELECT cost.capability_id FROM combat_panel_private.movement_cost_receipts cost WHERE cost.event_id=(movement->>'event_id')::uuid),ctx.exchange_id,aid);
    update combat_consumer_private.activities set context_version=context_version+1,last_action_at=clock_timestamp() where session_id=ctx.session_id;
    envelope:=combat_consumer_private.state_projection(ctx.location_id);
    label:=combat_consumer_private.display_label(ctx.session_id,aid,aid,null);
    display_event:=combat_consumer_private.validate_display_event(jsonb_build_object(
      'event_id',movement->'event_id','event_kind','movement','actor_id',aid,'display_name',label->>'display_name',
      'label_version',label->'label_version','target_actor_id',null,'target_display_name',null,'target_label_version',null,
      'summary','La presa interrompe lo spostamento. L’azione principale resta disponibile.'));
    receipt:=jsonb_build_object('receipt_id',event_id,'request_key',key,'operation',p->>'operation','replayed',false,
      'activity_id',ctx.session_id,'exchange_id',ctx.exchange_id,'context_version_before',ctx.context_version,
      'context_version_after',CASE WHEN ctx.user_test_context_id IS NOT NULL THEN (SELECT context_version FROM combat_consumer_private.activities WHERE session_id=ctx.session_id) ELSE ctx.context_version+1 END,'declaration_id',null,'report_id',null,'report_sha256',null,
      'values_written',false,'display_events',jsonb_build_array(display_event));
    envelope:=jsonb_set(envelope,'{receipt}',receipt);
    update combat_consumer_private.offers set state='consumed',consumed_request_key=key where id=offer.id;
    insert into combat_consumer_private.request_receipts(principal_character_id,request_key,command_sha256,operation,event_id,viewer_envelope)
      values(cid,key,prepared->>'command_sha256',p->>'operation',event_id,envelope);
    return public.combat_v2_event_complete(event_id,envelope);
  end if;
  IF offer.source_payload#>>'{intent,ability_source}'='clan' THEN
    suiton_profile:=coalesce(combat_v2_elemental_internal.suiton_profile(aid,(offer.source_payload#>>'{intent,ability_id}')::uuid),combat_v2_elemental_internal.other_profile(aid,(offer.source_payload#>>'{intent,ability_id}')::uuid));
  END IF;
  IF offer.source_payload ? 'fireball_selection' THEN
    offer.source_payload:=jsonb_set(offer.source_payload,'{intent}',clan_uchiha_private.fireball_prepare(ctx.exchange_id,aid,key,offer.source_payload->'fireball_selection'));
  END IF;
  if offer.source_payload?'multiplication_attack_target' then
    selection:=offer.source_payload->'multiplication_attack_target';
    if p->>'operation'<>'declare' or offer.source_payload#>>'{intent,kind}' is distinct from 'attacco'
      or not coalesce((offer.source_payload#>>'{intent,ability_source}'='mano'
        and coalesce(selection->>'attack_origin','actor')='actor'
        or offer.source_payload#>>'{intent,ability_source}'='clan'
        and offer.source_payload#>>'{intent,ability_id}'='e361f7c3-f90b-47ec-bfee-ccbda21257d9'
        and selection->>'attack_origin'='marionetta'
        or offer.source_payload#>>'{intent,ability_source}'='clan'
        and offer.source_payload#>>'{intent,ability_id}'='001f907c-8f32-4758-8a16-ad1730e72c59'
        and offer.source_payload#>>'{sabaku_flow,version}'='sabaku-flow/2'
        and coalesce(selection->>'attack_origin','actor')='actor'
        or suiton_profile IS NOT NULL and coalesce(selection->>'attack_origin','actor')='actor'),false)
      or selection->>'target_actor_id' is distinct from offer.source_payload#>>'{intent,target_actor}' then
      perform combat_consumer_private.fail('offer_not_available',key);end if;
    IF offer.source_payload#>>'{sabaku_flow,version}'='sabaku-flow/2' AND selection->>'selection_kind'='server_random' THEN
      PERFORM combat_panel_private.multiplication_prepare_selected_aims(ctx.exchange_id,aid,key,
        ARRAY[(selection->>'target_actor_id')::uuid],jsonb_build_object('groups',jsonb_build_array(
          jsonb_build_object('options',jsonb_build_array(jsonb_build_object('payload',
            jsonb_build_object('multiplication_attack_target',selection)))))));
    ELSE
    perform combat_panel_private.multiplication_prepare_attack_aim_for_source(ctx.exchange_id,aid,
      (selection->>'target_actor_id')::uuid,(selection->>'formation_id')::uuid,
      (selection->>'state_version')::bigint,(selection->>'figure_index')::integer,key,coalesce(selection->>'attack_origin'='marionetta',false));
    END IF;
    perform combat_panel_private.multiplication_bind_ordinary_draw(key,(selection->>'target_actor_id')::uuid,offer.id,(p->>'movement_offer_id')::uuid);
  end if;
  IF offer.source_payload#>>'{sabaku_flow,version}'='sabaku-flow/2' THEN
    IF p->>'operation'<>'declare' OR p->>'movement_offer_id' IS NOT NULL THEN
      RAISE EXCEPTION 'sabaku_flow_offer_invalid' USING ERRCODE='22023'; END IF;
    PERFORM clan_sabaku_private.flow_prepare(ctx.exchange_id,aid,key,offer.id,'consumer',
      offer.source_payload#>'{sabaku_flow,allocations}');
  END IF;
  IF offer.source_payload->>'aburame_clone'='aburame-clone/1' THEN
    IF p->>'operation'<>'defend' THEN PERFORM combat_consumer_private.fail('offer_not_available',key);END IF;
    PERFORM clan_aburame_private.clone_prepare(ctx.exchange_id,aid,(offer.source_payload->>'attack_id')::uuid,key,(offer.source_payload->>'movement_capability')::uuid);
  END IF;
  insert into combat_consumer_private.dispatch_authorizations
    values(key,ctx.exchange_id,cid,txid_current(),p->>'operation','prepared');
  if p->>'operation'='declare' then
    if fili_current IS NOT NULL THEN
      -- The existing declaration still verifies and spends the exact attack source.
      target:=(offer.source_payload#>>'{intent,target_actor}')::uuid;
    elsif offer.source_payload ? 'fireball_selection' THEN target:=(offer.source_payload#>>'{intent,target_actor}')::uuid;
    elsif offer.source_payload#>>'{intent,kind}'='attacco' AND offer.source_payload#>>'{intent,ability_source}'='arma' then
      -- The common declaration validates the projectile path, range and stock.
      target:=(offer.source_payload#>>'{intent,target_actor}')::uuid;
    elsif offer.source_payload#>>'{intent,kind}'='attacco' then
      target:=(offer.source_payload#>>'{intent,target_actor}')::uuid;
      multiplication_aim_valid:=combat_panel_private.multiplication_attack_aim_valid(ctx.exchange_id,aid,target,key,case when suiton_profile IS NOT NULL then (suiton_profile->>'range_m')::integer when offer.source_payload#>>'{intent,ability_source}'='clan'
        and offer.source_payload#>>'{intent,ability_id}'='e361f7c3-f90b-47ec-bfee-ccbda21257d9' then 3 WHEN offer.source_payload#>>'{sabaku_flow,version}'='sabaku-flow/2' THEN 15
        WHEN offer.source_payload#>>'{intent,ability_source}'='clan'
          AND offer.source_payload#>>'{intent,ability_id}'='214af896-15f8-43e6-858b-614d2851dd3b'
          AND offer.source_payload->>'akimichi_partial_offer'='akimichi-partial/1' THEN 3
        WHEN coalesce(offer.source_payload#>>'{intent,ability_source}','mano')='mano' THEN combat_panel_private.manual_contact_center_range(aid,target) else 2 end);
      IF offer.source_payload#>>'{sabaku_flow,version}'='sabaku-flow/2' THEN
        PERFORM clan_sabaku_private.flow_declaration_meta(ctx.exchange_id,aid,key,offer.source_payload->'intent');
      ELSIF offer.source_payload#>>'{intent,ability_source}'='clan'
       and offer.source_payload#>>'{intent,ability_id}'='e361f7c3-f90b-47ec-bfee-ccbda21257d9' then
        if not clan_marionettisti_private.owner_eligible(aid,true) then perform combat_consumer_private.fail('offer_not_available',key);end if;
        perform combat_panel_private.multiplication_companion_attack_source(ctx.exchange_id,aid,target,key,null);
      ELSIF offer.source_payload->>'nara_offer'='nara-possession/1' THEN
        -- The shared declaration computes and freezes the single segment.
        NULL;
      elsif multiplication_aim_valid is not null then
        if not multiplication_aim_valid then perform combat_consumer_private.fail('offer_not_available',key);end if;
      elsif suiton_profile IS NOT NULL then
        if not (CASE WHEN combat_v2_elemental_internal.other_profile(aid,(offer.source_payload#>>'{intent,ability_id}')::uuid) IS NOT NULL THEN combat_v2_elemental_internal.other_target_visible(aid,target,(suiton_profile->>'range_m')::numeric) ELSE combat_v2_elemental_internal.suiton_target_visible(aid,target,(suiton_profile->>'range_m')::numeric) END) then
          perform combat_consumer_private.fail('offer_not_available',key);end if;
      elsif offer.source_payload#>>'{intent,ability_source}'='clan'
       and offer.source_payload#>>'{intent,ability_id}'='f5e9af24-70f1-49f6-a7ca-74f59256336e' then
        if (combat_panel_private.has_master_geometry(ctx.session_id) and not combat_panel_private.target_geometry_valid(aid,target,5))
          or (not combat_panel_private.has_master_geometry(ctx.session_id) and
            abs((select position_m from public.combat_v2_actors where id=aid)-(select position_m from public.combat_v2_actors where id=target))>5) then
          perform combat_consumer_private.fail('offer_not_available',key);end if;
      elsif offer.source_payload#>>'{intent,ability_source}'='clan'
       AND offer.source_payload#>>'{intent,ability_id}'='214af896-15f8-43e6-858b-614d2851dd3b'
       AND offer.source_payload->>'akimichi_partial_offer'='akimichi-partial/1' then
        IF NOT clan_akimichi_private.partial_target_valid(aid,target) THEN
          PERFORM combat_consumer_private.fail('offer_not_available',key);
        END IF;
      elsif not combat_consumer_private.melee_eligible(ctx.session_id,aid,target) then
        perform combat_consumer_private.fail('offer_not_available',key);
      end if;
    elsif offer.source_payload#>>'{intent,kind}'='utilita' and offer.source_payload#>>'{intent,ability_id}'='f5e9af24-70f1-49f6-a7ca-74f59256336e' then null;
    elsif offer.source_payload#>>'{intent,kind}' is distinct from 'passa' then
      perform combat_consumer_private.fail('offer_not_available',key);
    end if;
    IF combat_v2_elemental_internal.suiton_profile(aid,(offer.source_payload#>>'{intent,ability_id}')::uuid) IS NOT NULL THEN
      PERFORM combat_v2_elemental_internal.suiton_prepare_callback('ordinary_v2',offer.id,aid,key,ARRAY[]::uuid[],'[]'::jsonb,offer.source_payload->'intent');
    END IF;
    IF combat_v2_elemental_internal.other_profile(aid,(offer.source_payload#>>'{intent,ability_id}')::uuid) IS NOT NULL THEN
      PERFORM combat_v2_elemental_internal.other_prepare_callback('ordinary_v2',offer.id,aid,key,ARRAY[]::uuid[],'[]'::jsonb,offer.source_payload->'intent');
    END IF;
    result:=public.combat_v2_action_declare(ctx.exchange_id,aid,offer.source_payload->'intent',p->>'narrative_text',key);
    declaration:=(result#>>'{data,declaration_id}')::uuid;
    round_phase:=result#>>'{data,phase}';
    update combat_consumer_private.activities set phase=case round_phase when 'raccolta_azioni' then 'action' when 'raccolta_difese' then 'defense' else phase end where session_id=ctx.session_id;
  else
    IF (offer.source_payload->>'flow_substitution'='flow-substitution/1' OR offer.source_payload->>'suiton_substitution'='suiton-substitution/1' OR offer.source_payload->>'other_substitution'='other-substitution/1' OR offer.source_payload->>'fireball_substitution'='fireball-substitution/1') THEN
      IF offer.source_payload#>>'{intent,reaction}' IS DISTINCT FROM 'sostituzione'
       OR NOT EXISTS(SELECT 1 FROM combat_spatial.substitution_activity_options so
         JOIN combat_spatial.substitution_activity_links sl ON sl.link_id=so.link_id
         JOIN combat_spatial.substitution_capabilities sc ON sc.capability_id=so.capability_id
         JOIN public.combat_v2_actors sa ON sa.id=sl.defender_actor_id AND sa.session_id=sl.activity_session_id
         JOIN public.combat_v2_declarations sd ON sd.id=sl.attack_declaration_id AND sd.round_id=sl.activity_round_id
         WHERE so.capability_id=(offer.source_payload->>'substitution_option_id')::uuid
          AND so.state='offered' AND sl.state='offered' AND sc.state='offered'
          AND sl.activity_kind='combat_v2' AND sl.activity_session_id=ctx.session_id
          AND sl.activity_round_id=ctx.exchange_id AND sl.attack_declaration_id=(offer.source_payload->>'attack_id')::uuid
          AND sl.defender_actor_id=aid AND sa.controller_user=auth.uid()
          AND sa.controller_version=sl.activity_version AND sd.kind='attacco'
          AND ((offer.source_payload->>'flow_substitution'='flow-substitution/1' AND sd.sanitized_intent#>>'{server_ability,sabaku_flow_version}'='sabaku-flow/2') OR (offer.source_payload->>'suiton_substitution'='suiton-substitution/1' AND combat_v2_elemental_internal.suiton_substitution_available(sd.id)) OR (offer.source_payload->>'other_substitution'='other-substitution/1' AND combat_v2_elemental_internal.other_substitution_available(sd.id)) OR (offer.source_payload->>'fireball_substitution'='fireball-substitution/1' AND sd.target_actor_id=aid AND clan_uchiha_private.fireball_source_valid(sd.id)))) THEN
        perform combat_consumer_private.fail('offer_not_available',key);
      END IF;
      PERFORM clan_marionettisti_private.assert_jutsu_source(aid,'jutsu','31b15861-fb78-4f8a-ac1c-ebf2d957c32e');
      result:=public.combat_v2_substitution_select_v1((offer.source_payload->>'substitution_option_id')::uuid,key);
      declaration:=(result->>'defense_declaration_id')::uuid;
      UPDATE public.combat_v2_declarations SET declaration_text=p->>'narrative_text'
       WHERE id=declaration AND round_id=ctx.exchange_id AND actor_id=aid AND request_key=key
        AND parent_attack_id=(offer.source_payload->>'attack_id')::uuid
        AND controller_user_snapshot=auth.uid() AND state='inviata' AND declaration_text='';
      IF NOT FOUND THEN RAISE EXCEPTION 'flow_substitution_declaration_binding_invalid' USING ERRCODE='40001'; END IF;
    ELSE
      IF offer.source_payload#>>'{intent,ability_id}'='58a2f5cd-6409-40f6-8f18-cfdb4410ca26' THEN
        PERFORM clan_hyuga_private.rotation_prepare(ctx.exchange_id,aid,(offer.source_payload->>'attack_id')::uuid,key,(offer.source_payload->>'rotation_radius_m')::integer);
      END IF;
      if offer.source_payload#>>'{intent,reaction}' not in ('schivata','parata','nessuna')
       AND NOT coalesce((offer.source_payload#>>'{intent,reaction}'='tecnica' AND offer.source_payload#>>'{intent,ability_source}'='clan'
        AND (offer.source_payload#>>'{intent,ability_id}'='58a2f5cd-6409-40f6-8f18-cfdb4410ca26'
         OR (offer.source_payload#>>'{intent,ability_id}'='9061c022-ca82-4d2b-8102-e208fcc6c1a2' AND combat_v2_elemental_internal.scudo_profile(aid) IS NOT NULL)
         OR (offer.source_payload#>>'{intent,ability_id}'='b9195ceb-74de-4251-95af-fe5c1bdaf485'
          AND offer.source_payload->>'aburame_clone'='aburame-clone/1'
          AND EXISTS(SELECT 1 FROM clan_aburame_private.clone_preparations cp
           WHERE cp.request_key=key AND cp.round_id=ctx.exchange_id AND cp.actor_id=aid
            AND cp.attack_id=(offer.source_payload->>'attack_id')::uuid
            AND cp.movement_capability IS NOT DISTINCT FROM (offer.source_payload->>'movement_capability')::uuid
            AND NOT cp.consumed)))),false) then
        perform combat_consumer_private.fail('offer_not_available',key);
      end if;
      result:=public.combat_v2_defense_declare(ctx.exchange_id,(offer.source_payload->>'attack_id')::uuid,
        aid,offer.source_payload->'intent',p->>'narrative_text',key);
      declaration:=(result#>>'{data,defense_id}')::uuid;
    END IF;
    target:=ctx.turn_actor_id;
  end if;
  update combat_consumer_private.dispatch_authorizations set state='consumed'
    where request_key=key and round_id=ctx.exchange_id and operation=p->>'operation';
  -- La fase deriva dai bersagli reali: ogni azione senza attacco cede iniziativa senza difesa fittizia.
  select phase into strict round_phase from public.combat_v2_rounds where id=ctx.exchange_id;
  if (p->>'operation'='defend' AND combat_v2_multitarget_internal.round_complete(ctx.exchange_id)) or round_phase='risoluzione' or offer.source_payload#>>'{intent,kind}'='utilita' then
    resolve_key:=gen_random_uuid();
    insert into combat_consumer_private.dispatch_authorizations
      values(resolve_key,ctx.exchange_id,cid,txid_current(),'resolve','prepared');
    perform public.combat_v2_round_resolve(ctx.exchange_id,resolve_key);
    update combat_consumer_private.dispatch_authorizations set state='consumed'
      where request_key=resolve_key and round_id=ctx.exchange_id and operation='resolve';
    select * into report from public.combat_v2_round_reports where round_id=ctx.exchange_id;
    update combat_consumer_private.activities set phase='resolved' where session_id=ctx.session_id;
  end if;
  IF ctx.user_test_context_id IS NOT NULL THEN
    PERFORM user_testroom_common_private.record_role(ctx.session_id,declaration,key,p->>'narrative_text');
    PERFORM user_testroom_common_private.drive_dummy(ctx.session_id,ctx.exchange_id,key);
    SELECT * INTO report FROM public.combat_v2_round_reports WHERE round_id=ctx.exchange_id;
    IF report.id IS NOT NULL THEN PERFORM user_testroom_common_private.publish_and_advance(ctx.session_id,ctx.exchange_id);END IF;
  ELSIF ctx.location_id=combat_panel_private.shuriken_qa_location_v1() THEN
    PERFORM combat_panel_private.shuriken_qa_write_message_v1(declaration);
  ELSE
    perform combat_consumer_private.record_message(declaration,
      public.post_message(ctx.location_id,p->>'narrative_text',null,null,null));
  END IF;
  update combat_consumer_private.activities set context_version=context_version+1,last_action_at=clock_timestamp()
    where session_id=ctx.session_id;
  envelope:=combat_consumer_private.state_projection(ctx.location_id);
  label:=combat_consumer_private.display_label(ctx.session_id,aid,aid,null);
  if target is not null then target_label:=combat_consumer_private.display_label(ctx.session_id,target,aid,null); end if;
  display_event:=combat_consumer_private.validate_display_event(jsonb_build_object(
    'event_id',event_id,'event_kind',case when p->>'operation'='declare' then 'action_declared' else 'defense_resolved' end,
    'actor_id',aid,'display_name',label->>'display_name','label_version',label->'label_version',
    'target_actor_id',target,'target_display_name',target_label->>'display_name','target_label_version',target_label->'label_version',
    'summary',(label->>'display_name')||': '||(offer.viewer_projection->>'label')||'.'));
  receipt:=jsonb_build_object('receipt_id',event_id,'request_key',key,'operation',p->>'operation','replayed',false,
    'activity_id',ctx.session_id,'exchange_id',ctx.exchange_id,'context_version_before',ctx.context_version,
    'context_version_after',CASE WHEN ctx.user_test_context_id IS NOT NULL THEN (SELECT context_version FROM combat_consumer_private.activities WHERE session_id=ctx.session_id) ELSE ctx.context_version+1 END,'declaration_id',declaration,'report_id',report.id,
    'report_sha256',report.mechanics_sha256,'values_written',coalesce(report.values_written,false),
    'display_events',jsonb_build_array(display_event));
  if movement is not null then
    receipt:=jsonb_set(receipt,'{display_events}',jsonb_build_array(combat_consumer_private.validate_display_event(
      jsonb_build_object('event_id',movement->'event_id','event_kind','movement','actor_id',aid,
        'display_name',label->>'display_name','label_version',label->'label_version',
        'target_actor_id',null,'target_display_name',null,'target_label_version',null,
        'summary',(label->>'display_name')||' si sposta di '||(movement->>'d_eff_m')||' m.')))||(receipt->'display_events'));
  end if;
  envelope:=jsonb_set(envelope,'{receipt}',receipt);
  update combat_consumer_private.offers set state='consumed',consumed_request_key=key where id=offer.id;
  insert into combat_consumer_private.request_receipts(principal_character_id,request_key,command_sha256,operation,event_id,viewer_envelope)
    values(cid,key,prepared->>'command_sha256',p->>'operation',event_id,envelope);
  return public.combat_v2_event_complete(event_id,envelope);
end $function$;

CREATE OR REPLACE FUNCTION combat_panel_private.narrative_ordinary_context(p_round uuid)
 RETURNS jsonb
 LANGUAGE plpgsql
 STABLE SECURITY DEFINER
 SET search_path TO ''
AS $function$
DECLARE c combat_consumer_private.activities%ROWTYPE; d public.combat_v2_declarations%ROWTYPE;
 defense public.combat_v2_declarations%ROWTYPE; source public.characters%ROWTYPE; target public.characters%ROWTYPE;
 link combat_consumer_private.declaration_messages%ROWTYPE; facts jsonb; reports jsonb; place text; prior text;
 defense_no integer:=0; defense_character uuid; masked boolean; moved boolean; source_body uuid; target_body uuid; technique text; flow jsonb; nara_fact jsonb;
BEGIN
 SELECT * INTO STRICT c FROM combat_consumer_private.activities WHERE exchange_id=p_round AND phase='resolved';
 IF NOT EXISTS(SELECT 1 FROM public.combat_v2_round_reports WHERE round_id=p_round AND narration_state='attesa') THEN
   RAISE EXCEPTION 'ordinary_report_not_ready'; END IF;
 SELECT * INTO STRICT d FROM public.combat_v2_declarations
   WHERE round_id=p_round AND kind IN ('attacco','utilita','passa','movimento');
 flow:=combat_consumer_private.narrative_flow_round_v1(p_round);
 IF flow ? 'flussi_server' THEN
   facts:=jsonb_build_object('schema_version','combat-narrative-facts/1','kind',d.kind,
     'result',flow#>'{flussi_server,events,0,targets,0,result}',
     'targets',jsonb_build_array(jsonb_build_object('ordinal',1,'result',flow#>'{flussi_server,events,0,targets,0,result}')))
     ||combat_panel_private.narrative_clone_facts(d.id);
 ELSE facts:=combat_panel_private.narrative_declaration_facts(d.id); END IF;
 IF d.kind='utilita' AND d.outcome#>>'{aburame_escape,version}'='aburame-escape/1' THEN
   facts:=facts||jsonb_build_object('result',jsonb_build_object('escape',jsonb_build_object(
     'success',d.outcome#>'{aburame_escape,success}','source','aburame')));
 END IF;
 IF clan_sabaku_private.armor_narrative_round(p_round) ? 'armatura_server' THEN
   facts:=facts||clan_sabaku_private.armor_narrative_declaration(d.id);
 END IF;
 IF NOT combat_consumer_private.narrative_declaration_supported(d.id) THEN
   RAISE EXCEPTION 'ordinary_narrative_source_not_ready';
 END IF;
 SELECT ch.* INTO STRICT source FROM public.characters ch JOIN combat_consumer_private.members m ON m.character_id=ch.id
   WHERE m.session_id=c.session_id AND m.actor_id=d.actor_id;
 SELECT ch.* INTO STRICT target FROM public.characters ch JOIN combat_consumer_private.members m ON m.character_id=ch.id
   WHERE m.session_id=c.session_id AND m.actor_id<>d.actor_id;
 IF nullif(btrim(source.name),'') IS NULL OR nullif(btrim(target.name),'') IS NULL THEN
   RAISE EXCEPTION 'ordinary_narrative_projection_missing'; END IF;
 nara_fact:=combat_panel_private.nara_ordinary_narrative_fact_v1(d.id);
 IF nara_fact IS NOT NULL THEN facts:=facts||jsonb_build_object('nara_server',nara_fact); END IF;
 source_body:=coalesce((SELECT companion_actor_id FROM clan_marionettisti_private.offensive_profiles WHERE declaration_id=d.id),d.actor_id);
 target_body:=coalesce(d.target_actor_id,(SELECT actor_id FROM combat_consumer_private.members WHERE session_id=c.session_id AND actor_id<>d.actor_id));
 facts:=facts||clan_hoki_private.ordinary_report_facts(p_round,(
   SELECT jsonb_agg(jsonb_build_object('id',m.actor_id,'name',ch.name) ORDER BY m.actor_id)
   FROM combat_consumer_private.members m JOIN public.characters ch ON ch.id=m.character_id
   WHERE m.session_id=c.session_id));
 SELECT name INTO STRICT place FROM public.locations WHERE id=c.location_id;
 SELECT n.body INTO prior FROM public.combat_v2_narratives n JOIN public.combat_v2_rounds r ON r.id=n.round_id
   WHERE r.session_id=c.session_id AND r.id<>p_round AND r.state='narrato' ORDER BY r.round_no DESC LIMIT 1;
 SELECT * INTO STRICT link FROM combat_consumer_private.declaration_messages WHERE declaration_id=d.id;
 reports:=jsonb_build_object('attack',public._combat_narrative_report(link.message_id,link.message_sha256,c.location_id,source.id));
 IF d.kind='attacco' AND clan_uchiha_private.fireball_source_valid(d.id) THEN
   FOR defense IN SELECT * FROM public.combat_v2_declarations WHERE parent_attack_id=d.id AND kind IN ('difesa','nessuna') ORDER BY actor_id,id LOOP
     defense_no:=defense_no+1;
     SELECT character_id INTO STRICT defense_character FROM combat_consumer_private.members WHERE session_id=c.session_id AND actor_id=defense.actor_id;
     SELECT * INTO STRICT link FROM combat_consumer_private.declaration_messages WHERE declaration_id=defense.id;
     reports:=reports||jsonb_build_object('defense_'||defense_no,public._combat_narrative_report(link.message_id,link.message_sha256,c.location_id,defense_character));
   END LOOP;
 ELSIF d.kind='attacco' AND NOT (
   EXISTS(SELECT 1 FROM public.combat_v2_attack_targets mt WHERE mt.attack_declaration_id=d.id)
   AND NOT EXISTS(SELECT 1 FROM public.combat_v2_attack_targets mt WHERE mt.attack_declaration_id=d.id
     AND NOT combat_panel_private.multiplication_no_defense(mt.id))) THEN
   SELECT * INTO STRICT defense FROM public.combat_v2_declarations WHERE parent_attack_id=d.id AND kind IN ('difesa','nessuna');
   SELECT * INTO STRICT link FROM combat_consumer_private.declaration_messages WHERE declaration_id=defense.id;
   reports:=reports||jsonb_build_object('defense',public._combat_narrative_report(link.message_id,link.message_sha256,c.location_id,target.id));
 END IF;
  -- La difesa Scudo possiede una fonte distinta dall'attacco: solo fatti terminali verificati.
  IF defense.id IS NOT NULL AND defense.state='risolta'
    AND combat_v2_elemental_internal.scudo_source_valid(defense.id) THEN
    facts:=facts||combat_v2_elemental_internal.scudo_narrative(defense.id);
  END IF;
 -- Le distanze reali e il movimento dell'originale non sono fatti pubblici
 -- durante il mascheramento. La sola presenza/risoluzione delle copie non li rivela.
 masked:=facts ? 'multiplication_created' OR facts ? 'clone_events' OR EXISTS(
   SELECT 1 FROM combat_panel_private.multiplication_formations f WHERE f.session_id=c.session_id
     AND f.actor_id IN(d.actor_id,target_body) AND (f.state='active' OR EXISTS(
       SELECT 1 FROM combat_panel_private.multiplication_resolutions mr JOIN public.combat_v2_attack_targets t ON t.id=mr.attack_target_id
       WHERE mr.formation_id=f.id AND t.attack_declaration_id=d.id)));
 IF EXISTS(SELECT 1 FROM clan_aburame_private.combat_sources aburame_history
   WHERE aburame_history.session_id=c.session_id) THEN
   facts:=facts||jsonb_build_object('aburame_scene',jsonb_build_object(
     'schema_version','aburame-narrative-state/1',
     'release_state',CASE WHEN EXISTS(SELECT 1 FROM clan_aburame_private.combat_sources aburame_attached
       WHERE aburame_attached.session_id=c.session_id AND aburame_attached.source_kind='release'
         AND aburame_attached.state='attached') THEN 'attached' ELSE 'inactive' END,
     'release_target_actor_id',(SELECT aburame_attached.target_actor_id
       FROM clan_aburame_private.combat_sources aburame_attached
       WHERE aburame_attached.session_id=c.session_id AND aburame_attached.source_kind='release'
         AND aburame_attached.state='attached' ORDER BY aburame_attached.created_at DESC LIMIT 1))
     ||CASE WHEN masked THEN jsonb_build_object('clone_state','masked') ELSE jsonb_build_object(
     'clone_resolved',EXISTS(SELECT 1 FROM clan_aburame_private.combat_sources aburame_clone
       WHERE aburame_clone.round_id=p_round AND aburame_clone.source_kind='clone'
         AND aburame_clone.state='ended'),
     'clone_owner_actor_id',(SELECT aburame_clone.owner_actor_id
       FROM clan_aburame_private.combat_sources aburame_clone
       WHERE aburame_clone.round_id=p_round AND aburame_clone.source_kind='clone'
         AND aburame_clone.state='ended' ORDER BY aburame_clone.created_at DESC LIMIT 1),
     'clone_moved',EXISTS(SELECT 1 FROM clan_aburame_private.combat_sources aburame_move
       JOIN combat_spatial.movement_capabilities aburame_cap
         ON aburame_cap.capability_id=aburame_move.movement_capability
       WHERE aburame_move.round_id=p_round AND aburame_move.source_kind='clone'
         AND aburame_move.state='ended' AND aburame_cap.state='committed'),
     'clone_movement_m',(SELECT round(combat_spatial.distance_m(aburame_cap.start_x_m,aburame_cap.start_y_m,
          aburame_cap.end_x_m,aburame_cap.end_y_m),0)
       FROM clan_aburame_private.combat_sources aburame_move
       JOIN combat_spatial.movement_capabilities aburame_cap
         ON aburame_cap.capability_id=aburame_move.movement_capability
       WHERE aburame_move.round_id=p_round AND aburame_move.source_kind='clone'
         AND aburame_move.state='ended' AND aburame_cap.state='committed'
       ORDER BY aburame_move.created_at DESC LIMIT 1)) END);
 END IF;
 moved:=EXISTS(SELECT 1 FROM combat_spatial.spatial_events e WHERE e.actor_id=source_body
   AND e.event_kind='movement_settled' AND (e.after_state->>'d_eff_m')::numeric>0
   AND (e.root_id=d.request_key OR EXISTS(SELECT 1 FROM combat_consumer_private.offers o WHERE o.id=e.root_id AND o.exchange_id=p_round)));
 technique:=CASE
   WHEN d.sanitized_intent->'target_fili'='true'::jsonb THEN
     (d.sanitized_intent#>>'{server_ability,name}')||' contro i Fili di Chakra. '||
     CASE WHEN d.outcome->'fili_recisi'='true'::jsonb THEN 'I Fili vengono recisi.'
          ELSE 'I Fili restano collegati.' END||' La marionetta non è colpita.'
   WHEN facts ? 'elemental_technique' THEN facts#>>'{elemental_technique,name}' WHEN facts ? 'suiton_technique' THEN facts#>>'{suiton_technique,name}' WHEN flow ? 'flussi_server' THEN 'Flusso di Sabbia' WHEN facts ? 'projectile_fireball' THEN facts#>>'{projectile_fireball,name}' WHEN facts ? 'sedici_chiusure' THEN
    (SELECT name FROM public.clan_techniques WHERE id='031d5ecc-86ee-4d21-85f1-6b76fc57cef9'::uuid)
   WHEN clan_akimichi_private.narrative_partial_valid(d.id) THEN 'Espansione Parziale'
   WHEN nara_fact IS NOT NULL THEN 'Possesso dell''Ombra'
   WHEN EXISTS(SELECT 1 FROM clan_hoki_private.needle_sources s WHERE s.declaration_id=d.id AND s.state='spent')
     THEN 'Aghi Velenosi'
   WHEN facts ? 'juken' THEN 'Attacco a mani nude con Jūken'
   WHEN facts ? 'clone_creation' THEN 'Clone di Sabbia'
   WHEN EXISTS(SELECT 1 FROM clan_aburame_private.combat_sources s
    WHERE s.declaration_id=d.id AND s.round_id=p_round AND s.source_kind='release'
      AND combat_consumer_private.narrative_declaration_supported(s.declaration_id)) THEN
    (SELECT name FROM public.clan_techniques WHERE id='f5e9af24-70f1-49f6-a7ca-74f59256336e'::uuid)
   WHEN d.kind='utilita' AND d.outcome#>>'{aburame_escape,version}'='aburame-escape/1' THEN 'Liberarsi dallo sciame'
   WHEN d.kind='passa' THEN 'Conclusione del turno senza altra azione'
   WHEN d.kind='movimento' THEN 'Spostamento'
   WHEN facts->'result' ? 'escape' THEN 'Tenta di liberarti'
   WHEN facts ? 'multiplication_created' THEN 'Moltiplicazione del corpo'
   WHEN source_body<>d.actor_id THEN 'Marionetta da Combattimento: arto rinforzato contundente, controllato tramite Fili di Chakra'
   WHEN combat_panel_private.shuriken_resolved_v1(d.id) THEN 'Lancio di Shuriken'
   ELSE 'Colpo a mani nude' END;
 RETURN jsonb_build_object('ordinary',true,'genere','azione_risolta','non_offensivo',d.kind<>'attacco',
   'autore',jsonb_build_object('nome',source.name,'sesso',source.sex),
   'testimone',CASE WHEN EXISTS(SELECT 1 FROM public.combat_v2_actors WHERE id=target_body AND companion_id IS NOT NULL)
      THEN jsonb_build_object('nome','Marionetta','sesso',null) ELSE jsonb_build_object('nome',target.name,'sesso',target.sex) END,
   'luogo',place,'tecnica',technique,'fatti',facts,
   'movimento',CASE WHEN masked THEN 'non_esposto' WHEN moved THEN 'avvenuto' ELSE 'assente' END,
   'reazione',CASE WHEN clan_uchiha_private.fireball_source_valid(d.id) THEN 'difese individuali nei fatti' WHEN d.kind='attacco' AND defense.id IS NOT NULL THEN defense.sanitized_intent->>'reaction' ELSE NULL END,
   'player_reports',reports,'gia_visto',left(coalesce(prior,''),400),'model','gpt-6-luna');
END $function$;
ALTER TABLE public.combat_v2_declarations DISABLE TRIGGER zz_marionetta_staff_sever;
REVOKE EXECUTE ON FUNCTION public.marionetta_staff_sever_arm_v1(uuid,uuid,uuid) FROM authenticated;
DO $qualify$ BEGIN
 PERFORM clan_innata_private.eligibility_release_assert();
 UPDATE clan_marionettisti_private.ocular_sever_gate_v1 SET staff_enabled=true WHERE singleton AND NOT public_enabled;
 IF NOT FOUND THEN RAISE EXCEPTION 'OCULAR_SEVER_GATE_DRIFT';END IF;
END $qualify$;
COMMIT;
