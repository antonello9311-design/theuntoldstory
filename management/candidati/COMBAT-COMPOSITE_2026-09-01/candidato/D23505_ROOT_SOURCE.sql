-- Complete frozen defense23505 delta over W7 Root 0ace69052d551c1c80c9f29d344ef14504afe9ee59fedd509f4c9fe08f4d6e86 / source 2cc1212cc0ad3d2de72b141a3a8c2c634c46b770c43c0e9ba55aa1f023e3c67f.
-- SOURCE_ONLY, deliberately not installable without reviewed integrated Root.
DO $inert$ BEGIN RAISE EXCEPTION 'SOURCE_ONLY_NOT_INSTALLABLE';END $inert$;
BEGIN;
LOCK TABLE public.combat_v2_declarations IN SHARE ROW EXCLUSIVE MODE;
DO $defense_cas$
DECLARE e jsonb;a record;
BEGIN
 FOR e IN SELECT value FROM jsonb_array_elements($headers$[{"oid":39288,"schema":"combat_v2_multitarget_internal","proname":"sync_declaration","args":"","owner":"postgres","acl":"{postgres=X/postgres}","proconfig":["search_path=\"\""],"prosecdef":true,"provolatile":"v","ddl_md5":"217f7b3cf3c581b64fbe3683dfccf879","signature":"combat_v2_multitarget_internal.sync_declaration()"},{"oid":31336,"schema":"public","proname":"master_v2_make_checkpoint","args":"p_session uuid, p_mode text, p_reason text","owner":"postgres","acl":"{postgres=X/postgres,service_role=X/postgres}","proconfig":["search_path=\"\""],"prosecdef":true,"provolatile":"v","ddl_md5":"aa1dd82f9fa147b94d0e07afb513a42e"},{"oid":46312,"schema":"combat_panel_private","proname":"master_state_authoritative","args":"p_location uuid","owner":"postgres","acl":"{postgres=X/postgres}","proconfig":["search_path=\"\""],"prosecdef":true,"provolatile":"s","ddl_md5":"a027fb51cc093de9d0c61a8161dd8d30"},{"oid":31297,"schema":"public","proname":"combat_v2_sha256","args":"p_value jsonb","owner":"postgres","acl":"{postgres=X/postgres,service_role=X/postgres}","proconfig":["search_path=\"\""],"prosecdef":false,"provolatile":"i","ddl_md5":"4dc3868f16311c1fffdb3d6b2fd733ce"},{"oid":31314,"schema":"public","proname":"combat_v2_lock_round","args":"p_round uuid","owner":"postgres","acl":"{postgres=X/postgres,service_role=X/postgres}","proconfig":["search_path=\"\""],"prosecdef":true,"provolatile":"v","ddl_md5":"4399d9d74f6f47d1f1c34b602b0c01d8"},{"oid":31309,"schema":"public","proname":"combat_v2_values_written","args":"p_session uuid","owner":"postgres","acl":"{postgres=X/postgres,service_role=X/postgres}","proconfig":["search_path=\"\""],"prosecdef":true,"provolatile":"s","ddl_md5":"843e9ef632c305142e1825513f5c1da5"},{"oid":677423,"schema":"clan_innata_narrative_private","proname":"fenice_staff_proof_v1","args":"p_actor uuid","owner":"postgres","acl":"{postgres=X/postgres}","proconfig":["search_path=\"\""],"prosecdef":true,"provolatile":"s","ddl_md5":"7aa18bb1255ac3d8fa5603079254e475"},{"oid":45071,"schema":"combat_panel_private","proname":"owner_turn_context","args":"p_actor uuid","owner":"postgres","acl":"{postgres=X/postgres}","proconfig":["search_path=\"\""],"prosecdef":true,"provolatile":"s","ddl_md5":"56291b63933136f509c818dd58c4bf10"},{"oid":51636,"schema":"combat_panel_private","proname":"multiplication_no_defense","args":"p_target uuid","owner":"postgres","acl":"{postgres=X/postgres}","proconfig":["search_path=\"\""],"prosecdef":true,"provolatile":"s","ddl_md5":"727cc76d6070aa51175fc8074c56d9aa"},{"oid":51621,"schema":"combat_panel_private","proname":"multiplication_tactics_allowed","args":"p_actor uuid","owner":"postgres","acl":"{postgres=X/postgres}","proconfig":["search_path=\"\""],"prosecdef":true,"provolatile":"s","ddl_md5":"86d93a7e6f27d8e7adf6f852f8ef3de3"},{"oid":309015,"schema":"mission_public_owner","proname":"c1266_regia_public_scope_v1","args":"p_mission uuid, p_mode text, p_publication uuid, p_release text","owner":"postgres","acl":"{postgres=X/postgres}","proconfig":["search_path=\"\""],"prosecdef":true,"provolatile":"s","ddl_md5":"da8deaa22cb722ef96bcc4295c96df9b"},{"oid":276559,"schema":"mission_public_owner","proname":"role_session_allowed_v1","args":"p_session uuid","owner":"postgres","acl":"{postgres=X/postgres}","proconfig":["search_path=\"\""],"prosecdef":true,"provolatile":"s","ddl_md5":"1108d29abb45f56019c39c4c23dc863a"}]$headers$::jsonb) LOOP
  SELECT p.oid::bigint oid,pg_get_userbyid(p.proowner) owner,p.proacl::text acl,p.proconfig,
   p.prosecdef,p.provolatile::text provolatile,md5(pg_get_functiondef(p.oid)) ddl_md5 INTO a
  FROM pg_proc p WHERE p.oid=(e->>'oid')::oid;
  IF a.oid IS NULL OR a.owner IS DISTINCT FROM e->>'owner' OR a.acl IS DISTINCT FROM e->>'acl'
   OR to_jsonb(a.proconfig) IS DISTINCT FROM e->'proconfig' OR a.prosecdef IS DISTINCT FROM (e->>'prosecdef')::boolean
   OR a.provolatile IS DISTINCT FROM e->>'provolatile' OR a.ddl_md5 IS DISTINCT FROM e->>'ddl_md5'
  THEN RAISE EXCEPTION 'DEFENSE_23505_FUNCTION_DRIFT:%',e->>'proname';END IF;
 END LOOP;
 IF NOT EXISTS(SELECT 1 FROM pg_class c WHERE c.oid=30948 AND c.relowner='postgres'::regrole
  AND c.relacl::text='{postgres=arwdDxtm/postgres,service_role=arwdDxtm/postgres}' AND c.relrowsecurity AND c.relforcerowsecurity)
 OR NOT EXISTS(SELECT 1 FROM pg_attribute att_meta WHERE att_meta.attrelid=30948 AND att_meta.attname='actor_id' AND att_meta.atttypid='uuid'::regtype AND att_meta.attnotnull AND NOT att_meta.attisdropped)
 OR NOT EXISTS(SELECT 1 FROM pg_trigger t WHERE t.tgrelid=30948 AND t.tgname='combat_v2_declarations_multitarget_sync'
  AND t.tgenabled='O' AND NOT t.tgisinternal AND t.tgfoid='combat_v2_multitarget_internal.sync_declaration()'::regprocedure
  AND pg_get_triggerdef(t.oid)='CREATE TRIGGER combat_v2_declarations_multitarget_sync AFTER INSERT ON public.combat_v2_declarations FOR EACH ROW EXECUTE FUNCTION combat_v2_multitarget_internal.sync_declaration()')
 THEN RAISE EXCEPTION 'DEFENSE_23505_TABLE_OR_TRIGGER_DRIFT';END IF;
 IF NOT EXISTS(SELECT 1 FROM pg_index i JOIN pg_class c ON c.oid=i.indexrelid
  WHERE c.oid=30990 AND c.relname='combat_v2_declarations_difesa_idx' AND c.relowner='postgres'::regrole
   AND i.indrelid='public.combat_v2_declarations'::regclass AND i.indisunique AND i.indisvalid AND i.indisready
   AND pg_get_indexdef(c.oid)='CREATE UNIQUE INDEX combat_v2_declarations_difesa_idx ON public.combat_v2_declarations USING btree (parent_attack_id) WHERE (kind = ANY (ARRAY[''difesa''::text, ''nessuna''::text]))'
   AND NOT EXISTS(SELECT 1 FROM pg_constraint k WHERE k.conindid=c.oid AND k.conrelid=i.indrelid AND k.contype IN('p','u','x')))
 THEN RAISE EXCEPTION 'DEFENSE_23505_INDEX_DRIFT';END IF;
 IF to_regclass('public.combat_v2_declarations_difesa_actor_candidate_idx') IS NOT NULL
 THEN RAISE EXCEPTION 'DEFENSE_23505_NAME_OCCUPIED';END IF;
 IF EXISTS(SELECT 1 FROM public.combat_v2_declarations WHERE kind IN('difesa','nessuna') GROUP BY parent_attack_id,actor_id HAVING count(*)>1)
 THEN RAISE EXCEPTION 'DEFENSE_23505_EXISTING_PAIR_DUPLICATE';END IF;
 IF (SELECT to_jsonb(g) FROM combat_panel_private.multiplication_tactics_release_gate g WHERE singleton)
  IS DISTINCT FROM '{"version":2,"singleton":true,"staff_enabled":true,"master_enabled":false,"generic_enabled":false,"ordinary_enabled":false,"revision_reference":"combat-multiplication-tactics/1"}'::jsonb
 THEN RAISE EXCEPTION 'DEFENSE_23505_RELEASE_GATE_DRIFT';END IF;
 IF current_setting('default_transaction_isolation') IS DISTINCT FROM 'read committed'
 THEN RAISE EXCEPTION 'DEFENSE_23505_NATIVE_ISOLATION_DRIFT';END IF;
END $defense_cas$;
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

CREATE OR REPLACE FUNCTION public.master_v2_make_checkpoint(p_session uuid, p_mode text, p_reason text)
 RETURNS uuid
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO ''
AS $function$
declare v_m public.master_v2_sessions%rowtype; v_payload jsonb; v_id uuid; v_sha text;
begin
  perform public.master_v2_lock_scope(p_session);
  select * into v_m from public.master_v2_sessions where id=p_session for update;
  if v_m.id is null then perform public.combat_v2_fail('sessione_inesistente','Sessione inesistente.',404,null,'{}'); end if;
  v_payload:=jsonb_build_object(
    'schema_version','master-v2-checkpoint/1.0.0',
    'reason',p_reason,
    'master',jsonb_build_object(
      'id',v_m.id,'state',v_m.stato,'state_before_suspend',v_m.stato_pre_sospensione,
      'master_user',v_m.master_user,'control_version',v_m.control_version,
      'created_at',v_m.created_at,'suspended_at',v_m.suspended_at),
    'encounters',coalesce((
      select jsonb_agg(jsonb_build_object(
        'id',s.id,'state',s.state,'state_before_suspend',s.state_before_suspend,
        'engine_version',s.engine_version,'resolver_version',s.resolver_version,
        'actors',coalesce((
          select jsonb_agg(jsonb_build_object(
            'id',a.id,'kind',a.actor_kind,'character_id',a.character_id,
            'png_instance_id',a.png_instance_id,'controller_user',a.controller_user,
            'controller_version',a.controller_version,'team',a.team_key,
            'state',a.state,'terminal_reason',case
              when a.state='ritirato' then 'ritirata'
              when coalesce((a.mechanics_snapshot->>'vita')::int,1)=0 then 'ko'
              when a.state='fuori' then 'fuga'
            end,
            'position_m',a.position_m,'initiative',a.initiative_snapshot,
            'resources',jsonb_build_object(
              'vita',a.mechanics_snapshot->'vita','vita_max',a.mechanics_snapshot->'vita_max',
              'chakra',a.mechanics_snapshot->'chakra','chakra_max',a.mechanics_snapshot->'chakra_max'),
            'mechanics_snapshot',a.mechanics_snapshot
          ) order by a.id) from public.combat_v2_actors a where a.session_id=s.id
        ),'[]'::jsonb),
        'rounds',coalesce((
          select jsonb_agg(jsonb_build_object(
            'id',r.id,'round_no',r.round_no,'phase',r.phase,'state',r.state,
            'versions',jsonb_build_object('engine',r.engine_version,'resolver',r.resolver_version,
              'order',r.order_version,'quality',r.quality_version),
            'rng_order_commitment',r.rng_order_commitment,'freeze_at',r.freeze_at,
            'resolved_at',r.resolved_at,'narrated_at',r.narrated_at,
            'attack_targets',coalesce((select jsonb_agg(to_jsonb(t) order by t.attack_declaration_id,t.ordinal) from public.combat_v2_attack_targets t where t.round_id=r.id),'[]'::jsonb),
            'defense_coverages',coalesce((select jsonb_agg(to_jsonb(c) order by c.defense_declaration_id,c.attack_target_id) from public.combat_v2_defense_coverages c where c.round_id=r.id),'[]'::jsonb),
            'declarations_present',coalesce((
              select jsonb_agg(jsonb_build_object(
                'id',d.id,'actor_id',d.actor_id,'kind',d.kind,
                'parent_attack_id',d.parent_attack_id,'target_actor_id',d.target_actor_id,
                'intent',d.sanitized_intent,'text',d.declaration_text,
                'controller_user',d.controller_user_snapshot,
                'controller_version',d.controller_version_snapshot,
                'state',d.state,'order_no',d.order_no,'tie_break',d.tie_break,
                'cost',d.cost_snapshot,'outcome',d.outcome,
                'created_at',d.created_at,'frozen_at',d.frozen_at
              ) order by d.order_no nulls last,d.id)
              from public.combat_v2_declarations d where d.round_id=r.id
            ),'[]'::jsonb),
            'declarations_missing',coalesce((
              select jsonb_agg(a.id order by a.id)
                from public.combat_v2_actors a where a.session_id=s.id and a.state='attivo'
                 and not exists(select 1 from public.combat_v2_declarations d
                   where d.round_id=r.id and d.actor_id=a.id and d.kind in ('attacco','movimento','utilita','passa'))
            ),'[]'::jsonb),
            'defenses_missing',coalesce((
              select jsonb_agg(d.id order by d.id)
                from public.combat_v2_declarations d where d.round_id=r.id and d.kind='attacco'
                 and (EXISTS(SELECT 1 FROM public.combat_v2_attack_targets mt
                    WHERE mt.attack_declaration_id=d.id AND mt.round_id=r.id AND mt.state='attesa_difesa'
                     AND NOT combat_panel_private.multiplication_no_defense(mt.id)
                     AND NOT EXISTS(SELECT 1 FROM public.combat_v2_defense_coverages cv WHERE cv.attack_target_id=mt.id))
                   OR (NOT EXISTS(SELECT 1 FROM public.combat_v2_attack_targets mt WHERE mt.attack_declaration_id=d.id)
                    AND NOT EXISTS(SELECT 1 FROM public.combat_v2_declarations x
                     WHERE x.parent_attack_id=d.id AND x.kind IN('difesa','nessuna'))))
            ),'[]'::jsonb),
            'ledger',coalesce((select jsonb_agg(clan_marionettisti_private.ledger_wire(l) order by l.created_at,l.id)
              from public.combat_v2_resource_ledger l where l.round_id=r.id),'[]'::jsonb),
            'effects','[]'::jsonb,
            'maintenances',coalesce((select jsonb_agg(clan_marionettisti_private.ledger_wire(l) order by l.created_at,l.id)
              from public.combat_v2_resource_ledger l where l.round_id=r.id and l.resource_kind='mantenimento'),'[]'::jsonb),
            'last_report',(select jsonb_build_object('id',q.id,'sha256',q.mechanics_sha256,
              'mechanics',q.mechanics,'created_at',q.created_at) from public.combat_v2_round_reports q where q.round_id=r.id),
            'last_narrative',(select jsonb_build_object('id',n.id,'kind',n.kind,'body',n.body,
              'created_at',n.created_at) from public.combat_v2_narratives n where n.round_id=r.id)
          ) order by r.round_no) from public.combat_v2_rounds r where r.session_id=s.id
        ),'[]'::jsonb)
      ) order by s.created_at,s.id)
      from public.combat_v2_sessions s where s.master_session_id=p_session
    ),'[]'::jsonb),
    'segments',coalesce((select jsonb_agg(to_jsonb(x) order by x.segment_no)
      from public.master_v2_mechanical_role_segments x where x.master_session_id=p_session),'[]'::jsonb),
    'timer_origins',jsonb_build_object('checkpoint_created_at',clock_timestamp(),
      'master_created_at',v_m.created_at,'master_suspended_at',v_m.suspended_at)
  );
  v_sha:=public.combat_v2_sha256(v_payload);
  insert into public.master_v2_mechanical_checkpoints(scope_kind,master_session_id,mode,previous_state,previous_phase,payload,suspended_at,version,sha256)
  values('master',p_session,p_mode,v_m.stato,(select r.phase from public.combat_v2_sessions s join public.combat_v2_rounds r on r.session_id=s.id where s.master_session_id=p_session order by r.created_at desc limit 1),v_payload,clock_timestamp(),v_m.control_version,v_sha)
  returning id into v_id;
  return v_id;
end $function$
;

CREATE OR REPLACE FUNCTION combat_panel_private.master_state_authoritative(p_location uuid)
 RETURNS jsonb
 LANGUAGE plpgsql
 STABLE SECURITY DEFINER
 SET search_path TO ''
AS $function$
declare
  v_uid uuid:=exam_regia_private.current_principal();
  v_m public.master_v2_sessions%rowtype;
  v_s public.combat_v2_sessions%rowtype;
  v_r public.combat_v2_rounds%rowtype;
  v_is_admin boolean:=false;
  v_is_master boolean:=false;
  v_is_participant boolean:=false;
begin
  if v_uid is null then
    perform public.combat_v2_fail('autenticazione_richiesta','Autenticazione richiesta.',401,null,'{}');
  end if;

  select * into v_m
    from public.master_v2_sessions
   where location_id=p_location and stato not in ('chiusa','annullata')
   order by created_at desc limit 1;

  if v_m.id is null then
    return public.combat_v2_envelope(null,jsonb_build_object(
      'viewer',jsonb_build_object('is_master',false,'is_admin',public.combat_v2_is_admin(v_uid)),
      'master',null,'encounter',null,'actors','[]'::jsonb,'round',null,
      'declarations','[]'::jsonb,'pending_defenses','[]'::jsonb,
      'ratings_pending','[]'::jsonb,'report',null));
  end if;

  v_is_admin:=public.combat_v2_is_admin(v_uid);
  v_is_master:=coalesce(v_m.master_user=v_uid,false);
  select exists(
    select 1 from public.master_v2_participants p
     where p.session_id=v_m.id and p.user_id_snapshot=v_uid
       and p.engagement_state in ('attivo','sospeso')
  ) into v_is_participant;

  v_is_participant:=v_is_participant OR EXISTS(SELECT 1 FROM exam_regia_private.bindings b
 WHERE b.master_session_id=v_m.id AND b.service_principal_id=v_uid AND b.state<>'closed'
 AND v_uid=exam_regia_private.current_principal());
  v_is_participant:=v_is_participant OR mission_generic_owner.principal_in_session(v_m.id,v_uid);
  if not (v_is_master or v_is_admin or v_is_participant) then
    perform public.combat_v2_fail('master_non_proprietario','Sessione non accessibile.',403,null,'{}');
  end if;

  select * into v_s
    from public.combat_v2_sessions
   where master_session_id=v_m.id and state not in ('chiuso','annullato')
   order by created_at desc limit 1;

  if v_s.id is not null then
    select * into v_r
      from public.combat_v2_rounds
     where session_id=v_s.id
     order by round_no desc limit 1;
  end if;

  IF v_r.id IS NOT NULL AND NOT v_is_master AND NOT public.combat_v2_is_service()
   AND mission_narrative_internal.scene_native_round_bound_v1(v_m.id,v_r.id)
   AND (EXISTS(SELECT 1 FROM mission_narrative_internal.scene_runtime_v1 cache
      WHERE cache.master_session_id=v_m.id AND cache.is_active AND cache.turn_owner='fato')
    OR (v_r.state IN('congelato','valutazione','risoluzione','risolto','narrazione')
      AND NOT EXISTS(SELECT 1 FROM public.combat_v2_round_reports report JOIN public.messages published ON published.id=report.message_id
       WHERE report.id=v_r.report_id AND report.round_id=v_r.id AND report.narration_state='pubblicata'
        AND published.kind='fato' AND published.location_id=p_location AND published.recipient_user IS NULL))
    OR EXISTS(SELECT 1 FROM public.combat_v2_declarations pending
      JOIN public.combat_v2_actors png ON png.id=pending.actor_id AND png.actor_kind='png'
      WHERE pending.round_id=v_r.id AND NOT(pending.kind='nessuna' AND coalesce(pending.declaration_text,'')='')
       AND NOT mission_narrative_internal.scene_native_declaration_public_v1(pending.id)))
  THEN
   -- No attested public snapshot of this frame exists: use a typed empty pending
   -- transport rather than expose current PV, positions, action flags or outcomes.
   RETURN public.combat_v2_envelope(NULL,jsonb_build_object(
    'publication_state','pending','reason_code','REGIA_FATO_PENDING',
    'viewer',jsonb_build_object('is_master',false,'is_admin',v_is_admin),
    'master',NULL,'encounter',NULL,'actors','[]'::jsonb,'round',NULL,
    'declarations','[]'::jsonb,'pending_defenses','[]'::jsonb,'ratings_pending','[]'::jsonb,'report',NULL));
  END IF;
  IF v_r.id IS NOT NULL AND NOT v_is_master AND EXISTS(SELECT 1 FROM mission_generic_owner.regia_human_admissions_v1 adm WHERE adm.encounter_id=v_s.id)
   AND NOT EXISTS(SELECT 1 FROM mission_generic_owner.unified_round_windows uw WHERE uw.round_id=v_r.id AND uw.publication_id IS NOT NULL) THEN
    SELECT vr.* INTO v_r FROM public.combat_v2_rounds vr JOIN mission_generic_owner.unified_round_windows uw ON uw.round_id=vr.id
     WHERE vr.session_id=v_s.id AND uw.publication_id IS NOT NULL ORDER BY vr.round_no DESC LIMIT 1;
    IF v_r.id IS NULL THEN v_s:=NULL; END IF;
  END IF;
  IF v_r.id IS NOT NULL AND EXISTS(SELECT 1 FROM mission_generic_owner.unified_round_windows uw WHERE uw.round_id=v_r.id AND uw.publication_id IS NULL)
    AND NOT mission_generic_owner.unified_service_staging(v_r.id)
    AND NOT (v_is_master AND EXISTS(
      SELECT 1 FROM mission_generic_owner.regia_human_windows_v1 hw
      WHERE hw.next_round_id=v_r.id AND hw.master_session_id=v_m.id
        AND hw.state='private')) THEN
    SELECT vr.* INTO v_r FROM public.combat_v2_rounds vr JOIN mission_generic_owner.unified_round_windows uw ON uw.round_id=vr.id
    WHERE vr.session_id=v_s.id AND uw.publication_id IS NOT NULL ORDER BY vr.round_no DESC LIMIT 1;
    IF v_r.id IS NULL THEN v_s:=NULL; END IF;
  END IF;
  -- The human Master may inspect the private successor. Everyone else sees
  -- only the last published round; opening PNG has no public Combat yet.
  IF v_r.id IS NOT NULL AND NOT v_is_master
    AND EXISTS(SELECT 1 FROM exam_human_private.round_publication_windows_v1 w
      WHERE (w.next_round_id=v_r.id OR (w.side='terminal' AND w.source_round_id=v_r.id))
        AND w.state<>'published') THEN
    SELECT vr.* INTO v_r FROM public.combat_v2_rounds vr
      JOIN exam_human_private.round_publication_windows_v1 w ON w.next_round_id=vr.id
      WHERE vr.session_id=v_s.id AND w.state='published' AND vr.state='narrato'
      ORDER BY vr.round_no DESC LIMIT 1;
    IF v_r.id IS NULL THEN v_s:=NULL; END IF;
  END IF;
  return public.combat_v2_envelope(null,jsonb_build_object(
    'unified_publication_id',(SELECT uw.publication_id FROM mission_generic_owner.unified_round_windows uw WHERE uw.round_id=v_r.id),
    'viewer',jsonb_build_object(
      'is_master',v_is_master,
      'is_admin',v_is_admin,
      'is_participant',v_is_participant),
    'master',jsonb_build_object(
      'id',v_m.id,'location_id',v_m.location_id,'tipo',v_m.tipo,
      'stato',v_m.stato,
      'control_version',v_m.control_version,'mission_id',v_m.mission_id,
      'titolo',v_m.titolo,'suspended_at',v_m.suspended_at),
    'encounter',case when v_s.id is null then null else jsonb_build_object(
      'id',v_s.id,'state',v_s.state,'source_kind',v_s.source_kind,
      'location_id',v_s.location_id,'lesiva',v_s.lesiva) end,
    'actors',case when v_s.id is null then '[]'::jsonb else coalesce((
      select jsonb_agg(jsonb_build_object(
        'id',a.id,
        'kind',a.actor_kind,
        'name',coalesce(c.name,p.nome,pi.nome,'Attore'),
        'character_id',a.character_id,
        'team',a.team_key,
        'state',a.state,
        'position_m',a.position_m,
        'initiative',a.initiative_snapshot,
        'mine',exam_regia_private.actor_principal(a.id,a.controller_user)=v_uid,
        'has_action',exists(
          select 1 from public.combat_v2_declarations d
           where d.round_id=v_r.id and d.actor_id=a.id
             and d.kind in ('attacco','movimento','utilita','passa')),
        'reaction_used',exists(
          select 1 from public.combat_v2_declarations d
           join public.combat_v2_declarations x on x.id=d.parent_attack_id
           where d.round_id=v_r.id and d.kind='difesa'
             and d.actor_id=a.id),
        'resources',case when v_is_master or v_is_admin or exam_regia_private.actor_principal(a.id,a.controller_user)=v_uid
          then jsonb_build_object(
            'vita',a.mechanics_snapshot->'vita',
            'vita_max',a.mechanics_snapshot->'vita_max',
            'chakra',a.mechanics_snapshot->'chakra',
            'chakra_max',a.mechanics_snapshot->'chakra_max')
          else null end
      ) order by a.initiative_snapshot desc,a.id)
      from public.combat_v2_actors a
      left join public.characters c on c.id=a.character_id
      left join public.combat_v2_png_instances p on p.id=a.png_instance_id left join public.combat_v2_provider_instances_v1 pi on pi.id=a.provider_instance_v1_id
      where a.session_id=v_s.id
    ),'[]'::jsonb) end,
    'round',case when v_r.id is null then null else jsonb_build_object(
      'id',v_r.id,'no',v_r.round_no,'phase',v_r.phase,'state',v_r.state,
      'evaluation_mode',v_r.evaluation_mode,'report_id',v_r.report_id,
      'resolved_at',v_r.resolved_at,'narrated_at',v_r.narrated_at) end,
    'declarations',case when v_r.id is null then '[]'::jsonb else coalesce((
      select jsonb_agg(jsonb_build_object(
        'id',d.id,'actor_id',d.actor_id,'actor_name',coalesce(ac.name,ap.nome,aip.nome,'Attore'),
        'actor_kind',aa.actor_kind,'kind',d.kind,
        'target_actor_id',d.target_actor_id,'target_name',coalesce(tc.name,tp.nome,tip.nome,'Attore'),
        'parent_attack_id',d.parent_attack_id,'targets',(select coalesce(jsonb_agg(jsonb_build_object('attack_target_id',t.id,'ordinal',t.ordinal,'target_actor_id',t.target_actor_id,'state',CASE WHEN NOT v_is_master AND NOT public.combat_v2_is_service()
          AND mission_narrative_internal.scene_native_round_bound_v1(v_m.id,v_r.id)
          AND EXISTS(SELECT 1 FROM public.combat_v2_defense_coverages private_coverage
           JOIN public.combat_v2_declarations private_none ON private_none.id=private_coverage.defense_declaration_id
           JOIN public.combat_v2_actors private_png ON private_png.id=private_none.actor_id AND private_png.actor_kind='png'
           WHERE private_coverage.attack_target_id=t.id AND private_none.kind='nessuna' AND coalesce(private_none.declaration_text,'')=''
            AND NOT mission_narrative_internal.scene_native_declaration_public_v1(private_none.id))
          THEN NULL ELSE t.state END,'outcome',case when v_r.state in('risolto','narrazione','narrato')then t.outcome else null end)order by t.ordinal),'[]'::jsonb)from public.combat_v2_attack_targets t where t.attack_declaration_id=d.id),'coverage',(select coalesce(jsonb_agg(jsonb_build_object('attack_target_id',c.attack_target_id,'protected_actor_id',c.protected_actor_id,'mode',c.mode,'state',c.state)order by c.id),'[]'::jsonb)from public.combat_v2_defense_coverages c where c.defense_declaration_id=d.id),'state',d.state,'order_no',d.order_no,
        'text',case when v_is_master or v_is_admin or exam_regia_private.actor_principal(aa.id,aa.controller_user)=v_uid
                         or exam_regia_private.actor_principal(ta.id,ta.controller_user)=v_uid or v_r.state in ('risolto','narrazione','narrato')
                    then d.declaration_text else '' end,
        'choice',jsonb_strip_nulls(jsonb_build_object(
          'kind',d.sanitized_intent->>'kind',
          'reaction',d.sanitized_intent->>'reaction',
          'ability_name',d.sanitized_intent->'server_ability'->>'name')),
        'rating',case
          when rr.id is null then null
          when v_is_admin or (rr.source<>'revisione_admin' and (v_is_master or exam_regia_private.actor_principal(aa.id,aa.controller_user)=v_uid))
          then jsonb_build_object('id',rr.id,'value',rr.value,'reason',rr.reason,
                                 'source',rr.source,'created_at',rr.created_at)
          else null end
      ) order by d.order_no nulls last,d.created_at,d.id)
      from public.combat_v2_declarations d
      join public.combat_v2_actors aa on aa.id=d.actor_id
      left join public.characters ac on ac.id=aa.character_id
      left join public.combat_v2_png_instances ap on ap.id=aa.png_instance_id left join public.combat_v2_provider_instances_v1 aip on aip.id=aa.provider_instance_v1_id
      left join public.combat_v2_actors ta on ta.id=d.target_actor_id
      left join public.characters tc on tc.id=ta.character_id
      left join public.combat_v2_png_instances tp on tp.id=ta.png_instance_id left join public.combat_v2_provider_instances_v1 tip on tip.id=ta.provider_instance_v1_id
      left join lateral (
        select r0.* from public.combat_v2_ratings r0
         where r0.declaration_id=d.id and r0.is_active
         order by r0.created_at desc limit 1
      ) rr on true
      where d.round_id=v_r.id
        AND (aa.actor_kind<>'png' OR NOT mission_narrative_internal.scene_native_round_bound_v1(v_m.id,v_r.id)
          OR v_is_master OR public.combat_v2_is_service()
          OR mission_narrative_internal.scene_native_declaration_public_v1(d.id))
        AND (NOT EXISTS(SELECT 1 FROM mission_generic_owner.unified_round_windows uw WHERE uw.round_id=v_r.id)
          OR mission_generic_owner.unified_service_staging(v_r.id) OR aa.actor_kind<>'png' OR d.kind<>'difesa' OR v_r.state='narrato')
        and (v_is_master or v_is_admin or exam_regia_private.actor_principal(aa.id,aa.controller_user)=v_uid
             or exam_regia_private.actor_principal(ta.id,ta.controller_user)=v_uid or v_r.state in ('risolto','narrazione','narrato'))
    ),'[]'::jsonb) end,
    'pending_defenses',case when v_r.id is null then '[]'::jsonb else coalesce((
      select jsonb_agg(jsonb_build_object(
        'attack_declaration_id',d.id,
        'attacker_actor_id',d.actor_id,
        'attacker_name',coalesce(ac.name,ap.nome,aip.nome,'Attore'),
        'target_actor_id',mt.target_actor_id,
        'target_name',coalesce(tc.name,tp.nome,tip.nome,'Attore'),
        'text',case when v_is_master or v_is_admin or exam_regia_private.actor_principal(ta.id,ta.controller_user)=v_uid
                    then d.declaration_text else '' end
      ) order by d.created_at,d.id)
      from public.combat_v2_declarations d
      join public.combat_v2_actors aa on aa.id=d.actor_id
      left join public.characters ac on ac.id=aa.character_id
      left join public.combat_v2_png_instances ap on ap.id=aa.png_instance_id left join public.combat_v2_provider_instances_v1 aip on aip.id=aa.provider_instance_v1_id
      join public.combat_v2_attack_targets mt on mt.attack_declaration_id=d.id AND mt.round_id=v_r.id
      join public.combat_v2_actors ta on ta.id=mt.target_actor_id
      left join public.characters tc on tc.id=ta.character_id
      left join public.combat_v2_png_instances tp on tp.id=ta.png_instance_id left join public.combat_v2_provider_instances_v1 tip on tip.id=ta.provider_instance_v1_id
      where d.round_id=v_r.id and d.kind='attacco'
        AND (aa.actor_kind<>'png' OR NOT mission_narrative_internal.scene_native_round_bound_v1(v_m.id,v_r.id)
          OR v_is_master OR public.combat_v2_is_service()
          OR mission_narrative_internal.scene_native_declaration_public_v1(d.id))
        and mt.state='attesa_difesa'
        and NOT combat_panel_private.multiplication_no_defense(mt.id)
        and not exists(select 1 from public.combat_v2_defense_coverages dc where dc.attack_target_id=mt.id)
        and (v_is_master or v_is_admin or exam_regia_private.actor_principal(ta.id,ta.controller_user)=v_uid)
    ),'[]'::jsonb) end,
    'ratings_pending',case when not (v_is_master or v_is_admin) or v_r.id is null
      then '[]'::jsonb else coalesce((
        select jsonb_agg(jsonb_build_object(
          'declaration_id',d.id,'kind',d.kind,
          'actor_id',d.actor_id,'actor_name',c.name,
          'text',d.declaration_text
        ) order by d.created_at,d.id)
        from public.combat_v2_declarations d
        join public.combat_v2_actors a on a.id=d.actor_id and a.actor_kind='pg'
        join public.characters c on c.id=a.character_id
        where d.round_id=v_r.id and d.kind in ('attacco','difesa')
          and not exists(select 1 from public.combat_v2_ratings x
                          where x.declaration_id=d.id and x.is_active)
      ),'[]'::jsonb) end,
    'report',case when v_r.id is null or not (v_is_master or v_is_admin) then null else (
      select jsonb_build_object(
        'id',q.id,'sha256',q.mechanics_sha256,'mechanics',q.mechanics,
        'values_written',q.values_written,'narration_state',q.narration_state,
        'narrator_kind',q.narrator_kind,'created_at',q.created_at)
       from public.combat_v2_round_reports q
       where q.round_id=v_r.id OR (v_is_master AND q.id IN (
         select hw.source_report_id from mission_generic_owner.regia_human_windows_v1 hw
          where hw.master_session_id=v_m.id AND hw.next_round_id=v_r.id
            AND hw.state='private' AND hw.source_report_sha256=q.mechanics_sha256
         union all
         select ew.source_report_id from exam_human_private.round_publication_windows_v1 ew
          join exam_human_private.requests er ON er.id=ew.exam_id
          where er.master_session_id=v_m.id AND ew.next_round_id=v_r.id
            AND ew.state='private' AND ew.source_report_sha256=q.mechanics_sha256
       ))
       -- The private window still publishes its frozen source, even if the
       -- successor already has a native report from a non-offensive action.
       order by case when q.round_id=v_r.id then 1 else 0 end, q.created_at desc, q.id limit 1
    ) end
  ));
end
$function$
;
CREATE UNIQUE INDEX combat_v2_declarations_difesa_actor_candidate_idx ON public.combat_v2_declarations USING btree (parent_attack_id,actor_id)
 WHERE kind IN('difesa','nessuna');
DROP INDEX public.combat_v2_declarations_difesa_idx;
ALTER INDEX public.combat_v2_declarations_difesa_actor_candidate_idx RENAME TO combat_v2_declarations_difesa_idx;
COMMIT;
