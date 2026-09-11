-- MISSION-GENERIC-CHOICE-SOURCES/1: public context for the actor decision.
begin;
create function mission_generic_owner.choice_public_context(p_session uuid,p_actor uuid,p_round uuid,p_panel jsonb)
returns jsonb language plpgsql security definer set search_path='' as $fn$
declare sources jsonb:='[]';row record;encounter uuid;
begin
 if auth.uid() is not null or not public.combat_v2_is_service() then raise exception 'MG_SERVICE_REQUIRED' using errcode='42501';end if;
 select e.encounter_id into strict encounter from mission_generic_owner.encounters e
  join public.combat_v2_rounds r on r.session_id=e.encounter_id
  join public.combat_v2_actors a on a.id=p_actor and a.session_id=e.encounter_id
  where e.master_session_id=p_session and r.id=p_round and mission_generic_owner.actor_principal(a.id) is not null;
 if p_panel#>>'{viewer,command_actor_id}' is distinct from p_actor::text
  or p_panel#>>'{context,activity_id}' is distinct from encounter::text
  or p_panel#>>'{context,round_id}' is distinct from p_round::text then raise exception 'MG_CHOICE_CONTEXT_SCOPE';end if;
 for row in select d.id,d.actor_id,d.kind,m.body,l.message_sha256
  from public.combat_v2_declarations d join combat_consumer_private.declaration_messages l on l.declaration_id=d.id
  join public.messages m on m.id=l.message_id join public.combat_v2_sessions s on s.id=encounter
  join public.combat_v2_actors a on a.id=d.actor_id and a.session_id=s.id
  where d.round_id=p_round and m.location_id=s.location_id and m.recipient_user is null
   and m.kind not in('whisper','motore') and nullif(btrim(m.body),'') is not null
   and ((a.actor_kind='pg' and m.sender_user=a.controller_user and m.character_id=a.character_id)
    or(a.actor_kind='png' and m.sender_user is null and m.character_id is null and m.kind='fato'))
  order by d.order_no nulls last,d.created_at,d.id loop
  if not exists(select 1 from combat_consumer_private.declaration_messages l where l.declaration_id=row.id
   and l.message_sha256=public._combat_narrative_sha(l.message_id)) then raise exception 'MG_CHOICE_ROLE_CHANGED';end if;
  sources:=sources||jsonb_build_array(jsonb_build_object('source_id',row.id,'actor_id',row.actor_id,'kind','declared_attempt',
   'action_kind',row.kind,'body',row.body,'sha256',encode(extensions.digest(convert_to(row.body,'UTF8'),'sha256'),'hex'),
   'visibility','public','complete',true));
 end loop;
 for row in select w.id,w.result->>'text' body,m.body public_body,m.recipient_user,m.kind
  from mission_generic_owner.work_items w join public.messages m on m.id=w.message_id
   join public.master_v2_sessions s on s.id=w.master_session_id and s.location_id=m.location_id
  where w.master_session_id=p_session and w.kind='narration' and w.state='completed' and w.message_id is not null
  order by w.finalized_at desc,w.id limit 1 loop
  if row.body is distinct from row.public_body or row.recipient_user is not null or row.kind<>'fato'
   then raise exception 'MG_CHOICE_CONTINUITY_CHANGED';end if;
  sources:=sources||jsonb_build_array(jsonb_build_object('source_id',row.id,'actor_id',null,'kind','fato','body',row.body,
   'sha256',encode(extensions.digest(convert_to(row.body,'UTF8'),'sha256'),'hex'),'visibility','public','complete',true));
 end loop;
 return jsonb_build_object('context',p_panel->'context','viewer',p_panel->'viewer','public_sources',sources);
end $fn$;
revoke all on function mission_generic_owner.choice_public_context(uuid,uuid,uuid,jsonb) from public,anon,authenticated,service_role;
do $pin$ begin
 if md5((select prosrc from pg_proc where oid='mission_generic_owner.choice_options(uuid,uuid,uuid,uuid)'::regprocedure)) is distinct from '1d8b478516d28e75ea88820a7542a040' then raise exception 'MG_CHOICE_OPTIONS_BASELINE_DRIFT';end if;
end $pin$;
create or replace function mission_generic_owner.choice_options(p_session uuid,p_actor uuid,p_work uuid,p_request uuid)
returns jsonb language plpgsql security definer set search_path='' as $fn$
declare a public.combat_v2_actors%rowtype; e mission_generic_owner.encounters%rowtype;
 c mission_generic_owner.panel_choices%rowtype; m public.master_v2_sessions%rowtype;
 env jsonb; permit uuid; principal uuid; persona jsonb;
begin
 if auth.uid() is not null or not public.combat_v2_is_service() or p_work is null or p_request is null
 then raise exception 'MG_SERVICE_REQUIRED' using errcode='42501'; end if;
 perform mission_generic_owner.assert_runtime(p_session);
 select * into strict m from public.master_v2_sessions where id=p_session for update;
 select * into c from mission_generic_owner.panel_choices where work_id=p_work for update;
 if found then
  if c.master_session_id<>p_session or c.actor_id<>p_actor or c.request_key<>p_request or c.expires_at<=clock_timestamp()
  then raise exception 'MG_CHOICE_STALE' using errcode='40001'; end if;
 else
  select * into strict a from public.combat_v2_actors where id=p_actor and actor_kind='png'
   and controller_user is null and character_id is null and companion_id is null and state='attivo' for update;
  select * into strict e from mission_generic_owner.encounters where encounter_id=a.session_id and master_session_id=p_session;
  principal:=mission_generic_owner.actor_principal(p_actor);
  if principal is null then raise exception 'MG_ACTOR_NOT_BOUND' using errcode='42501'; end if;
  insert into mission_generic_owner.panel_permits(master_session_id,encounter_id,actor_id,work_id,principal_id,operation,request_key,transaction_id,backend_pid)
  values(p_session,e.encounter_id,p_actor,p_work,principal,'options',p_request,txid_current(),pg_backend_pid()) returning id into permit;
  env:=combat_panel_private.master_projection(m.location_id,p_actor);
  env:=combat_panel_private.master_options(m.location_id,p_actor,(env#>>'{context,version}')::bigint);
  if env->>'status' is distinct from 'ready' or env#>>'{context,activity_id}' is distinct from e.encounter_id::text
   or env#>>'{viewer,command_actor_id}' is distinct from p_actor::text
   or env#>>'{viewer,can_command}' is distinct from 'true'
   or jsonb_array_length(env->'offers')=0
  then raise exception 'MG_CHOICE_NOT_READY' using errcode='55000'; end if;
  -- Administration never becomes an AI actor choice.
  if exists(select 1 from jsonb_array_elements(env->'offers') x where x->>'kind'='administration')
  then raise exception 'MG_ADMIN_OFFER_FORBIDDEN' using errcode='42501'; end if;
  insert into mission_generic_owner.panel_choices(work_id,master_session_id,encounter_id,actor_id,principal_id,request_key,
   context_version,controller_version,legal_options,options_sha256,expires_at)
  values(p_work,p_session,e.encounter_id,p_actor,principal,p_request,(env#>>'{context,version}')::bigint,
   a.controller_version,env,public.combat_v2_sha256(env),clock_timestamp()+interval '150 seconds') returning * into c;
  update mission_generic_owner.panel_permits set consumed_at=clock_timestamp() where id=permit;
 end if;
 -- Identity/persona are taken from the approved provider version, not model output.
 select jsonb_build_object('identity',nv.skeleton->'identity','voice',nv.skeleton->'voice',
  'conduct',nv.skeleton->'conduct','goals',nv.skeleton->'goals','motivations',nv.skeleton->'motivations',
  'knowledge_limits',nv.skeleton->'knowledge_limits','knowledge_boundary',nv.knowledge_boundary) into persona
 from public.combat_v2_actors aa join public.combat_v2_provider_instances_v1 pi on pi.id=aa.provider_instance_v1_id
 join public.nb_template_versions nv on nv.id=pi.narrative_version_ref where aa.id=c.actor_id;
 return jsonb_build_object('capability_id',c.id,'actor_id',c.actor_id,'legal_options',c.legal_options,
  'context_version',c.context_version,'request_key',c.request_key,'persona',persona,
  'encounter_id',c.encounter_id,'authority_receipt_id',c.id,
  'authorized_context',mission_generic_owner.choice_public_context(p_session,c.actor_id,(c.legal_options#>>'{context,round_id}')::uuid,c.legal_options)); 
end $fn$;
commit;
