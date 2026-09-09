-- Exact prior snapshot restored; helper retained private, no DROP/DELETE.
BEGIN;
SET LOCAL lock_timeout='3s';
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
   AND md5(pg_catalog.pg_get_functiondef(proc.oid))='542eb2b95627522ee8e0f28507fdf29b'
   AND pg_catalog.pg_get_userbyid(proc.proowner)='postgres'
   AND proc.proacl IS NOT DISTINCT FROM '{postgres=X/postgres}'::aclitem[]) THEN
   RAISE EXCEPTION 'narrative_tech_body_owner_acl_drift: combat_consumer_private.scene_snapshot_v2(uuid)'; END IF;
END $pin$;
COMMIT;
