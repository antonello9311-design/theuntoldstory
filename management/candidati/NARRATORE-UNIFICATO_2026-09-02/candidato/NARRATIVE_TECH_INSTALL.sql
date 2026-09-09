-- Unique aggregate NT-01/02/03. Candidate only; separate named apply gate.
BEGIN;
SET LOCAL lock_timeout='3s';
DO $pin$ BEGIN
 IF current_user<>'postgres' THEN RAISE EXCEPTION 'narrative_tech_postgres_owner_required'; END IF;
 IF NOT EXISTS(SELECT 1 FROM pg_catalog.pg_proc proc WHERE proc.oid=pg_catalog.to_regprocedure('combat_consumer_private.scene_snapshot_v2(uuid)')
   AND md5(pg_catalog.pg_get_functiondef(proc.oid))='542eb2b95627522ee8e0f28507fdf29b'
   AND pg_catalog.pg_get_userbyid(proc.proowner)='postgres'
   AND proc.proacl IS NOT DISTINCT FROM '{postgres=X/postgres}'::aclitem[]) THEN
   RAISE EXCEPTION 'narrative_tech_body_owner_acl_drift: combat_consumer_private.scene_snapshot_v2(uuid)'; END IF;
 IF NOT EXISTS(SELECT 1 FROM pg_catalog.pg_proc proc WHERE proc.oid=pg_catalog.to_regprocedure('combat_panel_private.narrative_ordinary_context(uuid)')
   AND md5(pg_catalog.pg_get_functiondef(proc.oid))='ec6a66b6599cdfb3d80aea6c12c9dd43'
   AND pg_catalog.pg_get_userbyid(proc.proowner)='postgres'
   AND proc.proacl IS NOT DISTINCT FROM '{postgres=X/postgres}'::aclitem[]) THEN
   RAISE EXCEPTION 'narrative_tech_body_owner_acl_drift: combat_panel_private.narrative_ordinary_context(uuid)'; END IF;
 IF NOT EXISTS(SELECT 1 FROM pg_catalog.pg_proc proc WHERE proc.oid=pg_catalog.to_regprocedure('combat_panel_private.narrative_declaration_facts(uuid)')
   AND md5(pg_catalog.pg_get_functiondef(proc.oid))='037f85e391975594049c08b91df5008a'
   AND pg_catalog.pg_get_userbyid(proc.proowner)='postgres'
   AND proc.proacl IS NOT DISTINCT FROM '{postgres=X/postgres}'::aclitem[]) THEN
   RAISE EXCEPTION 'narrative_tech_body_owner_acl_drift: combat_panel_private.narrative_declaration_facts(uuid)'; END IF;
 IF NOT EXISTS(SELECT 1 FROM pg_catalog.pg_proc proc WHERE proc.oid=pg_catalog.to_regprocedure('combat_panel_private.narrative_clone_facts(uuid)')
   AND md5(pg_catalog.pg_get_functiondef(proc.oid))='6341d8856acf6a01e877a891feee4019'
   AND pg_catalog.pg_get_userbyid(proc.proowner)='postgres'
   AND proc.proacl IS NOT DISTINCT FROM '{postgres=X/postgres}'::aclitem[]) THEN
   RAISE EXCEPTION 'narrative_tech_body_owner_acl_drift: combat_panel_private.narrative_clone_facts(uuid)'; END IF;
 IF NOT EXISTS(SELECT 1 FROM pg_catalog.pg_proc proc WHERE proc.oid=pg_catalog.to_regprocedure('combat_panel_private.multiplication_actor_profile(uuid)')
   AND md5(pg_catalog.pg_get_functiondef(proc.oid))='ae1c065dcea82548cb954768b2bffce4'
   AND pg_catalog.pg_get_userbyid(proc.proowner)='postgres'
   AND proc.proacl IS NOT DISTINCT FROM '{postgres=X/postgres}'::aclitem[]) THEN
   RAISE EXCEPTION 'narrative_tech_body_owner_acl_drift: combat_panel_private.multiplication_actor_profile(uuid)'; END IF;
 IF NOT EXISTS(SELECT 1 FROM pg_catalog.pg_proc proc WHERE proc.oid=pg_catalog.to_regprocedure('combat_panel_private.multiplication_bind_declaration(uuid)')
   AND md5(pg_catalog.pg_get_functiondef(proc.oid))='f5eee385a0ac19ea360bb99b14d0c371'
   AND pg_catalog.pg_get_userbyid(proc.proowner)='postgres'
   AND proc.proacl IS NOT DISTINCT FROM '{postgres=X/postgres}'::aclitem[]) THEN
   RAISE EXCEPTION 'narrative_tech_body_owner_acl_drift: combat_panel_private.multiplication_bind_declaration(uuid)'; END IF;
 IF NOT EXISTS(SELECT 1 FROM pg_catalog.pg_proc proc WHERE proc.oid=pg_catalog.to_regprocedure('clan_sabaku_private.clone_release(uuid,text)')
   AND md5(pg_catalog.pg_get_functiondef(proc.oid))='ee1aee1336e24b53bbb756b4ecd11045'
   AND pg_catalog.pg_get_userbyid(proc.proowner)='postgres'
   AND proc.proacl IS NOT DISTINCT FROM '{postgres=X/postgres}'::aclitem[]) THEN
   RAISE EXCEPTION 'narrative_tech_body_owner_acl_drift: clan_sabaku_private.clone_release(uuid,text)'; END IF;
 IF NOT EXISTS(SELECT 1 FROM pg_catalog.pg_proc proc WHERE proc.oid=pg_catalog.to_regprocedure('clan_sabaku_private.clone_ready(uuid)')
   AND md5(pg_catalog.pg_get_functiondef(proc.oid))='3e09f5c8d13089c4754b9bbebe1164c9'
   AND pg_catalog.pg_get_userbyid(proc.proowner)='postgres'
   AND proc.proacl IS NOT DISTINCT FROM '{postgres=X/postgres}'::aclitem[]) THEN
   RAISE EXCEPTION 'narrative_tech_body_owner_acl_drift: clan_sabaku_private.clone_ready(uuid)'; END IF;
 IF NOT EXISTS(SELECT 1 FROM pg_catalog.pg_proc proc WHERE proc.oid=pg_catalog.to_regprocedure('clan_sabaku_private.clone_trigger_nearby(uuid,uuid,text,uuid,uuid,uuid)')
   AND md5(pg_catalog.pg_get_functiondef(proc.oid))='bb273f4aa9001c29ea6d337a7af8d4b1'
   AND pg_catalog.pg_get_userbyid(proc.proowner)='postgres'
   AND proc.proacl IS NOT DISTINCT FROM '{postgres=X/postgres}'::aclitem[]) THEN
   RAISE EXCEPTION 'narrative_tech_body_owner_acl_drift: clan_sabaku_private.clone_trigger_nearby(uuid,uuid,text,uuid,uuid,uuid)'; END IF;
 IF NOT EXISTS(SELECT 1 FROM pg_catalog.pg_proc proc WHERE proc.oid=pg_catalog.to_regprocedure('combat_consumer_private.staff_test_allowed(uuid,uuid[],boolean)')
   AND md5(pg_catalog.pg_get_functiondef(proc.oid))='80434afefcecbc48e190999830389cee'
   AND pg_catalog.pg_get_userbyid(proc.proowner)='postgres'
   AND proc.proacl IS NOT DISTINCT FROM '{postgres=X/postgres}'::aclitem[]) THEN
   RAISE EXCEPTION 'narrative_tech_body_owner_acl_drift: combat_consumer_private.staff_test_allowed(uuid,uuid[],boolean)'; END IF;
 IF NOT EXISTS(SELECT 1 FROM pg_catalog.pg_proc proc WHERE proc.oid=pg_catalog.to_regprocedure('public.combat_v2_values_written(uuid)')
   AND md5(pg_catalog.pg_get_functiondef(proc.oid))='843e9ef632c305142e1825513f5c1da5'
   AND pg_catalog.pg_get_userbyid(proc.proowner)='postgres'
   AND proc.proacl IS NOT DISTINCT FROM '{postgres=X/postgres,service_role=X/postgres}'::aclitem[]) THEN
   RAISE EXCEPTION 'narrative_tech_body_owner_acl_drift: public.combat_v2_values_written(uuid)'; END IF;
 IF NOT EXISTS(SELECT 1 FROM pg_catalog.pg_proc proc WHERE proc.oid=pg_catalog.to_regprocedure('combat_consumer_private.narrative_declaration_supported(uuid)')
   AND md5(pg_catalog.pg_get_functiondef(proc.oid))='5d92acb102cf08fb6407c25efb6032b0'
   AND pg_catalog.pg_get_userbyid(proc.proowner)='postgres'
   AND proc.proacl IS NOT DISTINCT FROM '{postgres=X/postgres}'::aclitem[]) THEN
   RAISE EXCEPTION 'narrative_tech_body_owner_acl_drift: combat_consumer_private.narrative_declaration_supported(uuid)'; END IF;
 IF to_regprocedure('combat_consumer_private.narrative_tech_sources_v1(uuid)') IS NOT NULL THEN RAISE EXCEPTION 'narrative_tech_helper_exists'; END IF;
END $pin$;
CREATE OR REPLACE FUNCTION combat_consumer_private.narrative_tech_sources_v1(p_claim uuid)
 RETURNS jsonb
 LANGUAGE plpgsql
 STABLE SECURITY DEFINER
 SET search_path TO ''
AS $function$
DECLARE claim combat_consumer_private.narrative_claims%ROWTYPE;
  unit public.combat_v2_rounds%ROWTYPE; ref record; event record; content jsonb;
  sources jsonb:='[]'; endings jsonb:='[]'; native_id uuid; source_kind text;
BEGIN
 SELECT * INTO STRICT claim FROM combat_consumer_private.narrative_claims WHERE id=p_claim;
 SELECT * INTO STRICT unit FROM public.combat_v2_rounds WHERE id=claim.round_id;
 IF unit.session_id IS DISTINCT FROM claim.session_id OR claim.context_payload->>'ordinary' IS DISTINCT FROM 'true'
   OR claim.context_payload->>'genere' IS DISTINCT FROM 'azione_risolta' THEN
   RAISE EXCEPTION 'narrative_tech_scope_invalid' USING ERRCODE='22023';
 END IF;
 IF NOT EXISTS(SELECT 1 FROM combat_consumer_private.activities staff_activity
      JOIN public.combat_v2_sessions staff_session ON staff_session.id=staff_activity.session_id
      JOIN public.locations staff_location ON staff_location.id=staff_activity.location_id
      WHERE staff_activity.session_id=claim.session_id AND staff_activity.exchange_id=claim.round_id
        AND staff_activity.phase='resolved' AND staff_activity.policy_id='staff_test_no_persistent_resources_v1'
        AND staff_session.source_kind='ordinary' AND staff_session.location_id=staff_activity.location_id
        AND staff_location.is_test AND NOT public.combat_v2_values_written(staff_session.id)
        AND combat_consumer_private.staff_test_allowed(staff_location.id,
          (SELECT array_agg(actor.controller_user ORDER BY actor.id)
           FROM combat_consumer_private.members member JOIN public.combat_v2_actors actor
             ON actor.id=member.actor_id AND actor.session_id=member.session_id
             AND actor.character_id=member.character_id
           WHERE member.session_id=claim.session_id),false)) THEN
   RAISE EXCEPTION 'narrative_tech_staff_scope_required' USING ERRCODE='42501';
 END IF;
 -- Native rows certify use: no role-text/name lookup, no inventory scan.
 FOR ref IN
  SELECT DISTINCT x.catalog,x.actor_id FROM (
   SELECT 'clan_techniques'::text catalog,d.actor_id
    FROM public.combat_v2_declarations d
    WHERE d.round_id=claim.round_id AND d.state='risolta'
      AND d.outcome->'sabaku_clone'->>'schema_version'='sabaku-clone/1'
      AND d.kind='utilita'
   UNION
   SELECT 'clan_techniques',c.actor_id FROM clan_sabaku_private.clone_captures cc
    JOIN clan_sabaku_private.clones c ON c.id=cc.clone_id
    WHERE cc.round_id=claim.round_id AND c.session_id=claim.session_id
   UNION
   SELECT 'jutsu',f.actor_id FROM combat_panel_private.multiplication_formations f
    JOIN public.combat_v2_declarations d ON d.id=f.declaration_id
    WHERE f.session_id=claim.session_id AND d.round_id=claim.round_id AND d.state='risolta'
   UNION
   SELECT 'jutsu',f.actor_id FROM combat_panel_private.multiplication_resolutions mr
    JOIN combat_panel_private.multiplication_formations f ON f.id=mr.formation_id
    JOIN public.combat_v2_attack_targets t ON t.id=mr.attack_target_id
    JOIN public.combat_v2_declarations d ON d.id=t.attack_declaration_id
    WHERE f.session_id=claim.session_id AND d.round_id=claim.round_id AND d.state='risolta'
      AND t.state IN('risolta','superflua')
   UNION
   SELECT 'jutsu',f.actor_id FROM clan_sabaku_private.clone_captures cc
    JOIN combat_panel_private.multiplication_formations f ON f.id=cc.formation_id
    WHERE cc.round_id=claim.round_id AND f.session_id=claim.session_id
  ) x ORDER BY x.catalog,x.actor_id
 LOOP
  IF NOT EXISTS(SELECT 1 FROM combat_consumer_private.members m
    WHERE m.session_id=claim.session_id AND m.actor_id=ref.actor_id) THEN
   RAISE EXCEPTION 'narrative_tech_actor_not_in_scene' USING ERRCODE='22023';
  END IF;
  IF ref.catalog='clan_techniques' THEN
   native_id:='617484d6-af7b-41c3-a37f-615b22818421';
   SELECT jsonb_build_object('id',id,'name',name,'description',description,'danno_effetto',danno_effetto)
     INTO STRICT content FROM public.clan_techniques WHERE id=native_id;
  ELSE
   native_id:='c6e31b7b-38fe-4b4f-b3c7-05f3e922d193';
   SELECT jsonb_build_object('id',id,'name_it',name_it,'effect',effect,'limits',limits)
     INTO STRICT content FROM public.jutsu WHERE id=native_id;
  END IF;
  sources:=sources||jsonb_build_array(jsonb_build_object('catalog',ref.catalog,'technique_id',native_id,
    'actor_id',ref.actor_id,'mapping_version','ordinary-tech/1','source_sha256',
    encode(extensions.digest(convert_to(content::text,'UTF8'),'sha256'),'hex'),'content',content));
 END LOOP;
 -- Terminal event only when the native capture and native terminal state agree.
 -- No original index, figures, coordinates, dice, private stats, or inference from damage.
 FOR event IN
  SELECT cc.id,cc.copy_hit,cc.result,c.actor_id,c.state,c.end_reason,c.ended_at,cc.created_at
  FROM clan_sabaku_private.clone_captures cc JOIN clan_sabaku_private.clones c ON c.id=cc.clone_id
  WHERE cc.round_id=claim.round_id AND c.session_id=claim.session_id
  ORDER BY cc.created_at,cc.id
 LOOP
  IF event.result->>'schema_version' IS DISTINCT FROM 'sabaku-clone-capture/1'
    OR event.result->'copy_hit' IS DISTINCT FROM to_jsonb(event.copy_hit)
    OR jsonb_typeof(event.result->'success') IS DISTINCT FROM 'boolean' THEN
   RAISE EXCEPTION 'narrative_tech_capture_invalid' USING ERRCODE='22023';
  END IF;
  IF event.result->'success'='false'::jsonb THEN
   IF event.state IS DISTINCT FROM 'ended' OR event.ended_at IS NULL
    OR event.ended_at<event.created_at
    OR event.end_reason IS DISTINCT FROM (CASE WHEN event.copy_hit THEN 'copy_triggered' ELSE 'capture_failed' END) THEN
    RAISE EXCEPTION 'narrative_tech_terminal_event_missing' USING ERRCODE='22023';
   END IF;
   endings:=endings||jsonb_build_array(jsonb_build_object('tecnica','Clone di Sabbia','actor_id',event.actor_id,
      'stato','terminato','causa',event.end_reason));
  END IF;
 END LOOP;
 RETURN jsonb_build_object('fonti_tecniche',sources,'conclusioni_effetti_server',endings);
END $function$;
REVOKE ALL ON FUNCTION combat_consumer_private.narrative_tech_sources_v1(uuid) FROM PUBLIC,anon,authenticated,service_role;
GRANT EXECUTE ON FUNCTION combat_consumer_private.narrative_tech_sources_v1(uuid) TO postgres;
CREATE OR REPLACE FUNCTION combat_consumer_private.scene_snapshot_v2(p_claim uuid)
 RETURNS jsonb
 LANGUAGE plpgsql
 STABLE SECURITY DEFINER
 SET search_path TO ''
AS $function$
DECLARE c combat_consumer_private.narrative_claims%ROWTYPE;
  activity combat_consumer_private.activities%ROWTYPE; row record; snap jsonb; candidate jsonb;
  actors jsonb; actions jsonb:='[]'; sources jsonb:='[]'; role_count integer:=0;
  prior_count integer:=0; included integer:=0; current_round integer; place public.locations%ROWTYPE;
  body_sha text; facts jsonb;
BEGIN
  SELECT * INTO STRICT c FROM combat_consumer_private.narrative_claims WHERE id=p_claim;
  SELECT * INTO STRICT activity FROM combat_consumer_private.activities WHERE session_id=c.session_id;
  SELECT round_no INTO STRICT current_round FROM public.combat_v2_rounds WHERE id=c.round_id;
  SELECT * INTO STRICT place FROM public.locations WHERE id=activity.location_id;
  IF c.context_payload->>'genere' NOT IN('confronto','rinuncia','azione_risolta') THEN RAISE EXCEPTION 'scene_kind_unsupported'; END IF;
  SELECT jsonb_agg(jsonb_build_object('id',m.actor_id,'name',ch.name,'kind','PG','persona',null,'may_speak',false) ORDER BY m.actor_id)
    INTO actors FROM combat_consumer_private.members m JOIN public.characters ch ON ch.id=m.character_id
    WHERE m.session_id=c.session_id;
  IF jsonb_array_length(actors) IS DISTINCT FROM 2 THEN RAISE EXCEPTION 'scene_current_consumer_roster_unsupported'; END IF;
  -- La descrizione del luogo è ambientazione pubblica. Event_note esclusa: nessuna nuova policy implicita.
  IF nullif(btrim(place.description),'') IS NOT NULL THEN
    sources:=sources||jsonb_build_array(jsonb_build_object('id','location:'||place.id,'session_id',c.session_id,
      'round_id',c.round_id,'kind','setting','actor_id',null,'sequence',current_round,'body',place.description,
      'sha256',encode(extensions.digest(convert_to(place.description,'UTF8'),'sha256'),'hex'),'visibility','public','complete',true));
  END IF;
  FOR row IN
    SELECT d.id,d.actor_id,d.kind,m.id message_id,m.body,m.location_id,m.character_id,l.message_sha256,mem.character_id expected_character
    FROM public.combat_v2_declarations d
    JOIN combat_consumer_private.members mem ON mem.actor_id=d.actor_id AND mem.session_id=c.session_id
    LEFT JOIN combat_consumer_private.declaration_messages l ON l.declaration_id=d.id
    LEFT JOIN public.messages m ON m.id=l.message_id
    WHERE d.round_id=c.round_id AND d.kind IN('attacco','utilita','passa','movimento','difesa','nessuna')
    ORDER BY CASE WHEN d.kind IN('difesa','nessuna') THEN 1 ELSE 0 END,d.id
  LOOP
    IF row.message_id IS NULL OR row.location_id IS DISTINCT FROM activity.location_id
      OR row.character_id IS DISTINCT FROM row.expected_character OR nullif(btrim(row.body),'') IS NULL
      OR public._combat_narrative_sha(row.message_id) IS DISTINCT FROM row.message_sha256 THEN RAISE EXCEPTION 'scene_current_source_invalid'; END IF;
    role_count:=role_count+1;
    actions:=actions||jsonb_build_array(jsonb_build_object('actor_id',row.actor_id,
      'role',CASE WHEN row.kind IN('difesa','nessuna') THEN 'difesa' ELSE 'azione' END,'source_id',row.message_id));
    body_sha:=encode(extensions.digest(convert_to(row.body,'UTF8'),'sha256'),'hex');
    sources:=sources||jsonb_build_array(jsonb_build_object('id',row.message_id,'session_id',c.session_id,'round_id',c.round_id,
      'kind','role','actor_id',row.actor_id,'sequence',current_round,'body',row.body,'sha256',body_sha,'visibility','public','complete',true));
  END LOOP;
  IF role_count<>(CASE WHEN c.context_payload->>'genere'='confronto' OR c.context_payload->>'reazione' IS NOT NULL THEN 2 ELSE 1 END) THEN
    RAISE EXCEPTION 'scene_current_actions_incomplete'; END IF;
  -- Proiezione narrativa già prodotta dal server: nessuna lettura di mechanics_snapshot o ricalcolo.
  facts:=c.context_payload-ARRAY['player_reports','gia_visto','ordinary','model'];
  IF c.context_payload->>'ordinary'='true' AND c.context_payload->>'genere'='azione_risolta'
    AND EXISTS(SELECT 1 FROM combat_consumer_private.activities staff_activity
      JOIN public.combat_v2_sessions staff_session ON staff_session.id=staff_activity.session_id
      JOIN public.locations staff_location ON staff_location.id=staff_activity.location_id
      WHERE staff_activity.session_id=c.session_id AND staff_activity.exchange_id=c.round_id
        AND staff_activity.phase='resolved' AND staff_activity.policy_id='staff_test_no_persistent_resources_v1'
        AND staff_session.source_kind='ordinary' AND staff_session.location_id=staff_activity.location_id
        AND staff_location.is_test AND NOT public.combat_v2_values_written(staff_session.id)
        AND combat_consumer_private.staff_test_allowed(staff_location.id,
          (SELECT array_agg(actor.controller_user ORDER BY actor.id)
           FROM combat_consumer_private.members member JOIN public.combat_v2_actors actor
             ON actor.id=member.actor_id AND actor.session_id=member.session_id
             AND actor.character_id=member.character_id
           WHERE member.session_id=c.session_id),false)) THEN
    facts:=facts||combat_consumer_private.narrative_tech_sources_v1(c.id);
  END IF;
  SELECT count(*) INTO prior_count FROM public.combat_v2_narratives n JOIN public.combat_v2_rounds r ON r.id=n.round_id
    WHERE r.session_id=c.session_id AND r.round_no<current_round AND r.state='narrato';
  snap:=jsonb_build_object('schema_version','combat-scene/1','session_id',c.session_id,'round_id',c.round_id,
    'report_sha256',c.report_sha256,'control_version',c.control_version,'location',place.name,
    'actors',actors,'actions',actions,'resolved_facts',facts::text,'sources',sources,
    'selection',jsonb_build_object('max_input_bytes',49152,'previous_available',prior_count,'previous_included',0));
  IF octet_length(snap::text)>49152 THEN RAISE EXCEPTION 'scene_required_context_overflow'; END IF;
  FOR row IN SELECT n.id,n.round_id,n.body,r.round_no FROM public.combat_v2_narratives n
    JOIN public.combat_v2_rounds r ON r.id=n.round_id WHERE r.session_id=c.session_id AND r.round_no<current_round
    AND r.state='narrato' ORDER BY r.round_no DESC,n.id
  LOOP
    candidate:=jsonb_set(snap,'{sources}',(snap->'sources')||jsonb_build_array(jsonb_build_object('id',row.id,
      'session_id',c.session_id,'round_id',row.round_id,'kind','fato','actor_id',null,'sequence',row.round_no,'body',row.body,
      'sha256',encode(extensions.digest(convert_to(row.body,'UTF8'),'sha256'),'hex'),'visibility','public','complete',true)));
    candidate:=jsonb_set(candidate,'{selection,previous_included}',to_jsonb(included+1));
    EXIT WHEN octet_length(candidate::text)>49152;
    included:=included+1; snap:=candidate;
  END LOOP;
  RETURN snap;
END $function$;
REVOKE ALL ON FUNCTION combat_consumer_private.scene_snapshot_v2(uuid) FROM PUBLIC,anon,authenticated,service_role;
GRANT EXECUTE ON FUNCTION combat_consumer_private.scene_snapshot_v2(uuid) TO postgres;
DO $pin$ BEGIN
 IF current_user<>'postgres' THEN RAISE EXCEPTION 'narrative_tech_postgres_owner_required'; END IF;
 IF NOT EXISTS(SELECT 1 FROM pg_catalog.pg_proc proc WHERE proc.oid=pg_catalog.to_regprocedure('combat_consumer_private.narrative_tech_sources_v1(uuid)')
   AND md5(pg_catalog.pg_get_functiondef(proc.oid))='955228bdc23c89cdb287198db57231b8'
   AND pg_catalog.pg_get_userbyid(proc.proowner)='postgres'
   AND proc.proacl IS NOT DISTINCT FROM '{postgres=X/postgres}'::aclitem[]) THEN
   RAISE EXCEPTION 'narrative_tech_body_owner_acl_drift: combat_consumer_private.narrative_tech_sources_v1(uuid)'; END IF;
 IF NOT EXISTS(SELECT 1 FROM pg_catalog.pg_proc proc WHERE proc.oid=pg_catalog.to_regprocedure('combat_consumer_private.scene_snapshot_v2(uuid)')
   AND md5(pg_catalog.pg_get_functiondef(proc.oid))='a417e6a98201a2177cb8c244a736bb3c'
   AND pg_catalog.pg_get_userbyid(proc.proowner)='postgres'
   AND proc.proacl IS NOT DISTINCT FROM '{postgres=X/postgres}'::aclitem[]) THEN
   RAISE EXCEPTION 'narrative_tech_body_owner_acl_drift: combat_consumer_private.scene_snapshot_v2(uuid)'; END IF;
END $pin$;
COMMIT;
