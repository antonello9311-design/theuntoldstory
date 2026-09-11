-- MISSION-GENERIC-SOURCES/1. Install after DB/Combat/Panel/Dispatch; runtime remains off.
begin;
create function mission_generic_owner.combat_narrative_source(p_session uuid,p_event uuid)
returns jsonb language plpgsql security definer set search_path='' as $fn$
declare e mission_generic_owner.encounters%rowtype; b mission_generic_owner.run_bindings%rowtype;
 run public.mission_run_state%rowtype; s public.combat_v2_sessions%rowtype;
 r public.combat_v2_rounds%rowtype; rep public.combat_v2_round_reports%rowtype;
 a public.combat_v2_actors%rowtype; d public.combat_v2_declarations%rowtype;
 place public.locations%rowtype; row record; item jsonb; projected jsonb; narrator jsonb;
 actors jsonb:='[]'; actions jsonb:='[]'; sources jsonb:='[]'; facts jsonb:='[]'; spatial jsonb:='[]';
 snapshot jsonb; candidate jsonb; scenehash text; body text; sid text; pname text; persona text;
 prior_count integer:=0; included integer:=0;
begin
 if auth.uid() is not null or not public.combat_v2_is_service() then raise exception 'MG_SERVICE_REQUIRED' using errcode='42501';end if;
 perform mission_generic_owner.assert_runtime(p_session);
 select * into strict b from mission_generic_owner.run_bindings where master_session_id=p_session;
 select * into strict run from public.mission_run_state where master_session_id=p_session;
 select * into strict rep from public.combat_v2_round_reports where id=p_event;
 perform public.combat_v2_lock_round(rep.round_id);
 select * into strict r from public.combat_v2_rounds where id=rep.round_id and report_id=rep.id;
 select * into strict s from public.combat_v2_sessions where id=r.session_id and master_session_id=p_session;
 select * into strict e from mission_generic_owner.encounters where encounter_id=s.id and master_session_id=p_session;
 select * into strict place from public.locations where id=s.location_id;
 if e.step_key<>run.current_step_key or e.run_control_version<>run.control_version
  or b.snapshot_sha256 is distinct from mission_internal.fingerprint(b.snapshot)
  or r.state<>'risolto' or r.resolved_at is null or rep.narration_state<>'attesa'
  or rep.mechanics_sha256 is distinct from public.combat_v2_sha256(rep.mechanics)
  or jsonb_typeof(rep.mechanics->'declarations') is distinct from 'array'
  or (place.is_test and (rep.values_written or public.combat_v2_values_written(s.id)))
 then raise exception 'MG_COMBAT_SOURCE_STALE' using errcode='55000';end if;
 for a in select * from public.combat_v2_actors where session_id=s.id order by id loop
  persona:=null;pname:=null;
  if a.actor_kind='pg' then
   select name into strict pname from public.characters where id=a.character_id and user_id=a.controller_user;
  elsif a.actor_kind='png' then
   select pi.nome,jsonb_build_object('voice',nv.skeleton->'voice','gestures',nv.skeleton->'gestures')::text into strict pname,persona
    from public.combat_v2_provider_instances_v1 pi join public.nb_template_versions nv on nv.id=pi.narrative_version_ref
    where pi.id=a.provider_instance_v1_id and pi.session_id=s.id;
  else raise exception 'MG_SCENE_ACTOR_UNSUPPORTED' using errcode='55000';end if;
  if nullif(btrim(pname),'') is null then raise exception 'MG_SCENE_IDENTITY_MISSING';end if;
  actors:=actors||jsonb_build_array(jsonb_build_object('id',a.id,'name',pname,'kind',upper(a.actor_kind),
    'persona',persona,'may_speak',a.actor_kind='png'));
 end loop;
 if nullif(btrim(place.description),'') is not null then
  body:=place.description;
  sources:=jsonb_build_array(jsonb_build_object('id','location:'||place.id,'session_id',s.id,'round_id',r.id,
   'kind','setting','actor_id',null,'sequence',0,'body',body,
   'sha256',encode(extensions.digest(convert_to(body,'UTF8'),'sha256'),'hex'),'visibility','public','complete',true));
 end if;
 -- Only public mission publications tied to this run, never an unfiltered chat.
 for row in select w.id,w.result->>'text' body,w.message_id from mission_generic_owner.work_items w
  where w.master_session_id=p_session and w.kind='narration' and w.state='completed' and w.payload->>'mode'='mission'
  order by w.created_at desc limit 1 loop
  if nullif(btrim(row.body),'') is null or not exists(select 1 from public.messages m where m.id=row.message_id
    and m.location_id=place.id and m.recipient_user is null and m.kind='fato' and m.body=row.body)
  then raise exception 'MG_SCENE_CONTINUITY_CHANGED';end if;
  sources:=sources||jsonb_build_array(jsonb_build_object('id','mission:'||row.id,'session_id',s.id,'round_id',r.id,
   'kind','setting','actor_id',null,'sequence',0,'body',row.body,
   'sha256',encode(extensions.digest(convert_to(row.body,'UTF8'),'sha256'),'hex'),'visibility','public','complete',true));
 end loop;
 for d in select * from public.combat_v2_declarations where round_id=r.id order by order_no nulls last,id loop
  select value into strict item from jsonb_array_elements(rep.mechanics->'declarations') where value->>'id'=d.id::text;
  if item->>'actor' is distinct from d.actor_id::text or item->>'kind' is distinct from d.kind
   or item->>'state' is distinct from d.state or item->'outcome' is distinct from d.outcome
   or d.state not in('risolta','superflua') then raise exception 'MG_SCENE_REPORT_CHANGED';end if;
  if d.state='risolta' then projected:=combat_panel_private.narrative_declaration_facts(d.id);
  else projected:=jsonb_build_object('execution','not_executed','result',combat_panel_private.narrative_outcome_facts(d.outcome));end if;
  facts:=facts||jsonb_build_array(jsonb_build_object('declaration_id',d.id,'actor_id',d.actor_id,
   'target_actor_id',d.target_actor_id,'kind',d.kind,'facts',projected));
  -- Automatic missing-defence receipts are facts, not a newly invented role.
  if d.kind='nessuna' and coalesce(d.declaration_text,'')='' then continue;end if;
  select * into strict a from public.combat_v2_actors where id=d.actor_id and session_id=s.id;
  select m.id::text,m.body into sid,body from combat_consumer_private.declaration_messages l
   join public.messages m on m.id=l.message_id where l.declaration_id=d.id and m.location_id=place.id
    and m.recipient_user is null and m.kind not in('whisper','motore')
    and public._combat_narrative_sha(m.id)=l.message_sha256
    and ((a.actor_kind='pg' and m.character_id=a.character_id and m.sender_user=a.controller_user)
      or (a.actor_kind='png' and m.character_id is null and m.sender_user is null and m.kind='fato'));
  if a.actor_kind='png' and not exists(select 1 from mission_generic_owner.panel_choices c
    join combat_panel_private.request_receipts q on q.principal_user=c.principal_id and q.request_key=c.request_key
    where c.encounter_id=s.id and c.actor_id=a.id and c.request_key=d.request_key and c.consumed_at is not null
    and c.result=q.viewer_envelope and c.command_sha256=q.command_fingerprint
    and q.viewer_envelope#>>'{receipt,declaration_id}'=d.id::text)
  then raise exception 'MG_SCENE_PNG_RECEIPT_MISSING';end if;
  if sid is null or nullif(btrim(body),'') is null then raise exception 'MG_SCENE_ROLE_MISSING';end if;
  actions:=actions||jsonb_build_array(jsonb_build_object('actor_id',a.id,'role',case when d.kind='difesa' then 'difesa' else 'azione' end,'source_id',sid));
  sources:=sources||jsonb_build_array(jsonb_build_object('id',sid,'session_id',s.id,'round_id',r.id,'kind','role',
   'actor_id',a.id,'sequence',r.round_no,'body',body,'sha256',encode(extensions.digest(convert_to(body,'UTF8'),'sha256'),'hex'),
   'visibility','public','complete',true));
 end loop;
 if jsonb_array_length(actions)=0 or jsonb_array_length(facts)<>jsonb_array_length(rep.mechanics->'declarations')
 then raise exception 'MG_SCENE_BARRIER_INCOMPLETE';end if;
 for item in select value from jsonb_array_elements(coalesce(rep.mechanics->'substitution_receipts','[]')) loop
  narrator:=item->'narrator_payload';
  if item->>'round_id' is distinct from r.id::text or narrator->>'schema_version' is distinct from 'common-substitution-narrator/1.0'
   or not exists(select 1 from jsonb_array_elements(actors) ar where ar->>'id'=item->>'actor_id')
  then raise exception 'MG_SCENE_SUBSTITUTION_CHANGED';end if;
  spatial:=spatial||jsonb_build_array(jsonb_build_object('actor_id',item->'actor_id','kind','substitution',
   'outcome',narrator#>'{impact,outcome}','anchor',narrator#>'{anchor,semantic_label}','after',narrator#>'{after,semantic_region}'));
 end loop;
 select count(*) into prior_count from public.combat_v2_narratives n join public.combat_v2_rounds old on old.id=n.round_id
   join public.combat_v2_round_reports q on q.id=n.report_id where old.session_id=s.id and old.round_no<r.round_no
   and old.state='narrato' and q.narration_state='pubblicata';
 snapshot:=jsonb_build_object('schema_version','combat-scene/1','session_id',s.id,'round_id',r.id,
  'report_sha256',rep.mechanics_sha256,'control_version',run.control_version,'location',place.name,'actors',actors,'actions',actions,
  'resolved_facts',jsonb_build_object('schema_version','mission-generic-resolved-facts/1','round_no',r.round_no,
   'declarations',facts,'spatial',spatial)::text,'sources',sources,
  'selection',jsonb_build_object('max_input_bytes',12000,'previous_available',prior_count,'previous_included',0));
 if octet_length(snapshot::text)>12000 then raise exception 'MG_SCENE_REQUIRED_CONTEXT_OVERFLOW' using errcode='54000';end if;
 for row in select n.id,n.round_id,n.body,old.round_no,q.message_id from public.combat_v2_narratives n
  join public.combat_v2_rounds old on old.id=n.round_id and old.session_id=s.id
  join public.combat_v2_round_reports q on q.id=n.report_id and q.round_id=old.id
  where old.round_no<r.round_no and old.state='narrato' and q.narration_state='pubblicata' order by old.round_no desc,n.id loop
  if not exists(select 1 from public.messages m where m.id=row.message_id and m.location_id=place.id and m.body=row.body
    and m.character_id is null and m.sender_user is null and m.recipient_user is null and m.kind='fato')
  then raise exception 'MG_SCENE_PREVIOUS_CHANGED';end if;
  candidate:=jsonb_set(snapshot,'{sources}',snapshot->'sources'||jsonb_build_array(jsonb_build_object('id',row.id,
   'session_id',s.id,'round_id',row.round_id,'kind','fato','actor_id',null,'sequence',row.round_no,'body',row.body,
   'sha256',encode(extensions.digest(convert_to(row.body,'UTF8'),'sha256'),'hex'),'visibility','public','complete',true)));
  candidate:=jsonb_set(candidate,'{selection,previous_included}',to_jsonb(included+1));
  if octet_length(candidate::text)<=12000 then snapshot:=candidate;included:=included+1;end if;
 end loop;
 scenehash:=public.combat_v2_sha256(snapshot);
 return jsonb_build_object('master_session_id',p_session,'step_key',run.current_step_key,'run_control_version',run.control_version,
  'encounter_id',s.id,'authority_receipt_id',rep.id,'payload',jsonb_build_object('schema_version','mission-generic-narration/1',
   'mode','combat','scene',jsonb_build_object('snapshot',snapshot,'snapshot_sha256',scenehash),
   'scene_binding',jsonb_build_object('session_id',s.id,'round_id',r.id,'report_sha256',rep.mechanics_sha256,
    'control_version',run.control_version,'hash_authority','combat_v2_sha256/jsonb','scene_sha256',scenehash),
   'barrier',jsonb_build_object('closed',true,'required_receipt_ids',jsonb_build_array(rep.id),'receipt_ids',jsonb_build_array(rep.id))));
end $fn$;

create function mission_generic_owner.combat_publish(p_work uuid,p_text text,p_request uuid)
returns jsonb language plpgsql security definer set search_path='' as $fn$
declare w mission_generic_owner.work_items%rowtype; source jsonb; result jsonb;
begin
 if auth.uid() is not null or not public.combat_v2_is_service() then raise exception 'MG_SERVICE_REQUIRED' using errcode='42501';end if;
 select * into strict w from mission_generic_owner.work_items where id=p_work for update;
 if w.kind<>'narration' or w.payload->>'mode'<>'combat' or w.state<>'provider_started' or w.request_key<>p_request
  or w.lease_expires_at<=clock_timestamp() or w.payload_sha256<>public.combat_v2_sha256(w.payload)
 then raise exception 'MG_PUBLISH_WORK_INVALID';end if;
 source:=mission_generic_owner.combat_narrative_source(w.master_session_id,w.authority_receipt_id);
 if source->'payload' is distinct from w.payload then raise exception 'MG_PUBLISH_SOURCE_CHANGED';end if;
 result:=public.combat_v2_narrative_store((w.payload#>>'{scene_binding,round_id}')::uuid,'fato_ia',p_text,p_request,null);
 return result->'data';
end $fn$;
revoke all on function mission_generic_owner.combat_narrative_source(uuid,uuid),mission_generic_owner.combat_publish(uuid,text,uuid)
 from public,anon,authenticated,service_role;
do $pin$ begin
 IF md5((select prosrc from pg_proc where oid='combat_panel_private.publish_master_declaration(uuid,text)'::regprocedure)) IS DISTINCT FROM '1d1e0ebfef6f1e95aa9cba9a44e91bf1' THEN RAISE EXCEPTION 'MG_PUBLISH_BASELINE_DRIFT';END IF;
end $pin$;
CREATE OR REPLACE FUNCTION combat_panel_private.publish_master_declaration(p_declaration uuid, p_text text)
 RETURNS uuid
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO ''
AS $function$
DECLARE a public.combat_v2_actors%ROWTYPE; d public.combat_v2_declarations%ROWTYPE;
 location uuid; v_message_id uuid; guided_before text;
BEGIN
 SELECT * INTO STRICT d FROM public.combat_v2_declarations WHERE id=p_declaration FOR UPDATE;
 SELECT a0.* INTO a FROM public.combat_v2_actors a0
   JOIN public.combat_v2_rounds r ON r.id=d.round_id AND r.session_id=a0.session_id
   JOIN public.combat_v2_sessions s ON s.id=r.session_id AND s.source_kind='master'
   WHERE a0.id=d.actor_id AND exam_regia_private.actor_principal(a0.id,a0.controller_user)=exam_regia_private.current_principal() AND a0.companion_id IS NULL;
 IF a.id IS NULL OR d.controller_user_snapshot IS DISTINCT FROM exam_regia_private.current_principal()
   OR d.controller_version_snapshot<>a.controller_version OR d.state<>'inviata'
   OR d.declaration_text IS DISTINCT FROM coalesce(p_text,'') THEN
   RAISE EXCEPTION 'panel_role_declaration_scope_invalid' USING ERRCODE='42501'; END IF;
 SELECT location_id INTO STRICT location FROM public.combat_v2_sessions WHERE id=a.session_id;

 IF a.actor_kind='png' AND mission_generic_owner.principal_in_session(
  (SELECT master_session_id FROM public.combat_v2_sessions WHERE id=a.session_id),exam_regia_private.current_principal())
  AND mission_generic_owner.actor_principal(a.id)=exam_regia_private.current_principal() THEN
  IF nullif(btrim(p_text),'') IS NULL THEN RAISE EXCEPTION 'MG_PNG_ATTEMPT_EMPTY'; END IF;
  INSERT INTO public.messages(location_id,character_id,author_name,body,kind)
   VALUES(location,NULL,'Fato',p_text,'fato') RETURNING id INTO v_message_id;
  INSERT INTO combat_consumer_private.declaration_messages
   VALUES(d.id,v_message_id,public._combat_narrative_sha(v_message_id));
  RETURN v_message_id;
 END IF;
 IF a.actor_kind='png' AND EXISTS(SELECT 1 FROM exam_regia_private.bindings b
 WHERE b.png_actor_id=a.id AND b.combat_session_id=a.session_id
 AND b.service_principal_id=exam_regia_private.current_principal() AND b.state='active') THEN
  -- La dichiarazione resta immutabile; testo PNG pubblicato soltanto via ricevuta SESSION.
  RETURN NULL;
 END IF;
 IF a.actor_kind='pg' AND exam_regia_private.is_bound(a.session_id) THEN
  IF length(btrim(coalesce(p_text,'')))=0 THEN RETURN NULL; END IF;
  v_message_id:=public._esame_testo_candidato(a.session_id,p_text);
  PERFORM combat_consumer_private.record_message(d.id,v_message_id);
  RETURN v_message_id;
 END IF;
 IF length(btrim(coalesce(p_text,'')))=0 THEN RETURN NULL; END IF;
 IF a.actor_kind='pg' THEN
   guided_before:=current_setting('app.combat_guidata',true);
   PERFORM set_config('app.combat_guidata','1',true);
   BEGIN
     v_message_id:=public.post_message(location,p_text,NULL,NULL,NULL);
   EXCEPTION WHEN OTHERS THEN
     PERFORM set_config('app.combat_guidata',coalesce(guided_before,''),true); RAISE;
   END;
   PERFORM set_config('app.combat_guidata',coalesce(guided_before,''),true);
   PERFORM combat_consumer_private.record_message(d.id,v_message_id);
 ELSIF a.actor_kind='png' THEN
   v_message_id:=public.post_fato_manual(location,p_text);
   IF NOT EXISTS(SELECT 1 FROM public.messages m JOIN public.fato_manual_audit f ON f.message_id=m.id
     WHERE m.id=v_message_id AND m.location_id=location AND m.kind='fato' AND m.character_id IS NULL
       AND f.actor_user=exam_regia_private.current_principal() AND f.location_id=location) THEN
     RAISE EXCEPTION 'panel_role_message_scope_invalid' USING ERRCODE='42501'; END IF;
   INSERT INTO combat_consumer_private.declaration_messages
     VALUES(d.id,v_message_id,public._combat_narrative_sha(v_message_id));
 ELSE RAISE EXCEPTION 'panel_role_actor_kind_invalid' USING ERRCODE='22023'; END IF;
 RETURN v_message_id;
END $function$;


commit;
