-- MISSION-GENERIC-PANEL/1. Candidate: install after DB + Combat modules.
-- Service authority is scoped to one PNG, work item and SQL transaction.
begin;
do $pin$ begin
 IF md5((select prosrc from pg_proc where oid='combat_panel_private.master_state_authoritative(uuid)'::regprocedure)) IS DISTINCT FROM 'fc2ecc2f2336a9f98e71964b6da3056a' THEN RAISE EXCEPTION 'MG_SHARED_BASELINE_DRIFT: combat_panel_private.master_state_authoritative(uuid)'; END IF;
 IF md5((select prosrc from pg_proc where oid='exam_regia_private.actor_principal(uuid,uuid)'::regprocedure)) IS DISTINCT FROM '4a55f4d6f465e49e3843ec019ab398dd' THEN RAISE EXCEPTION 'MG_SHARED_BASELINE_DRIFT: exam_regia_private.actor_principal(uuid,uuid)'; END IF;
 IF md5((select prosrc from pg_proc where oid='exam_regia_private.current_principal()'::regprocedure)) IS DISTINCT FROM '380d81087ef018194d102499cf5f7cbb' THEN RAISE EXCEPTION 'MG_SHARED_BASELINE_DRIFT: exam_regia_private.current_principal()'; END IF;
end $pin$;

create table mission_generic_owner.panel_permits (
 id uuid primary key default gen_random_uuid(),
 master_session_id uuid not null references mission_generic_owner.run_bindings(master_session_id),
 encounter_id uuid not null references mission_generic_owner.encounters(encounter_id),
 actor_id uuid not null references public.combat_v2_actors(id),
 work_id uuid not null,
 principal_id uuid not null,
 operation text not null check(operation in('options','commit')),
 request_key uuid not null,
 transaction_id bigint not null,
 backend_pid integer not null,
 created_at timestamptz not null default clock_timestamp(),
 consumed_at timestamptz
);
create table mission_generic_owner.panel_choices (
 id uuid primary key default gen_random_uuid(),
 work_id uuid not null unique,
 master_session_id uuid not null references mission_generic_owner.run_bindings(master_session_id),
 encounter_id uuid not null references mission_generic_owner.encounters(encounter_id),
 actor_id uuid not null references public.combat_v2_actors(id),
 principal_id uuid not null,
 request_key uuid not null,
 context_version bigint not null,
 controller_version bigint not null,
 legal_options jsonb not null,
 options_sha256 text not null,
 expires_at timestamptz not null,
 consumed_at timestamptz,
 command_sha256 text,
 result jsonb,
 check(options_sha256 ~ '^[0-9a-f]{64}$'),
 check((consumed_at is null)=(result is null)),
 unique(master_session_id,request_key)
);
alter table mission_generic_owner.panel_permits enable row level security;
alter table mission_generic_owner.panel_choices enable row level security;
revoke all on mission_generic_owner.panel_permits,mission_generic_owner.panel_choices from public,anon,authenticated,service_role;

create function mission_generic_owner.actor_principal(p_actor uuid) returns uuid
language sql stable security definer set search_path='' as $fn$
 select mission_ai_service_owner.uuid5(a.id,'mission-generic-principal')
 from public.combat_v2_actors a
 join mission_generic_owner.encounters e on e.encounter_id=a.session_id
 join mission_generic_owner.run_bindings b on b.master_session_id=e.master_session_id
 join public.master_v2_sessions m on m.id=e.master_session_id
 join public.combat_v2_sessions s on s.id=e.encounter_id
 join mission_ai_service_owner.capabilities c on c.id=e.capability_id and c.master_session_id=m.id
 where a.id=p_actor and a.actor_kind='png' and a.controller_user is null and a.character_id is null
 and m.owner_kind='ai_service' and m.master_user is null and m.closed_at is null
 and s.closed_at is null and s.state not in('chiuso','annullato') and c.state='active'
 and b.snapshot_sha256=mission_internal.fingerprint(b.snapshot)
 and exists(select 1 from jsonb_array_elements(e.actor_map) x where x->>'actor_id'=a.id::text)
$fn$;

create function mission_generic_owner.current_principal() returns uuid
language plpgsql stable security definer set search_path='' as $fn$
declare v uuid; n integer;
begin
 if auth.uid() is not null or not public.combat_v2_is_service() then return null; end if;
 select count(distinct p.principal_id),(array_agg(p.principal_id))[1] into n,v
 from mission_generic_owner.panel_permits p
 join mission_generic_owner.runtime_policy pol on pol.singleton and pol.mode<>'off'
 join public.master_v2_sessions m on m.id=p.master_session_id
 join public.locations l on l.id=m.location_id
 where p.transaction_id=txid_current() and p.backend_pid=pg_backend_pid() and p.consumed_at is null
 and p.created_at>clock_timestamp()-interval '150 seconds'
 and p.principal_id=mission_generic_owner.actor_principal(p.actor_id)
 and (pol.mode='all' or (pol.mode='test' and l.is_test));
 if n>1 then raise exception 'MG_AMBIGUOUS_PANEL_AUTHORITY' using errcode='42501'; end if;
 return v;
end $fn$;

create function mission_generic_owner.principal_in_session(p_session uuid,p_principal uuid) returns boolean
language sql stable security definer set search_path='' as $fn$
 select p_principal is not null and p_principal=mission_generic_owner.current_principal()
 and exists(select 1 from mission_generic_owner.panel_permits p
 where p.master_session_id=p_session and p.principal_id=p_principal
 and p.transaction_id=txid_current() and p.backend_pid=pg_backend_pid() and p.consumed_at is null)
$fn$;

create function mission_generic_owner.choice_options(p_session uuid,p_actor uuid,p_work uuid,p_request uuid)
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
  'authorized_context',jsonb_build_object('context',c.legal_options->'context','viewer',c.legal_options->'viewer')); 
end $fn$;

create function mission_generic_owner.choice_commit(p_work uuid,p_capability uuid,p_command jsonb)
returns jsonb language plpgsql security definer set search_path='' as $fn$
declare c mission_generic_owner.panel_choices%rowtype; a public.combat_v2_actors%rowtype;
 cmd jsonb; fp text; o combat_panel_private.offers%rowtype; permit uuid; res jsonb;
begin
 if auth.uid() is not null or not public.combat_v2_is_service() then raise exception 'MG_SERVICE_REQUIRED' using errcode='42501'; end if;
 select * into strict c from mission_generic_owner.panel_choices where id=p_capability and work_id=p_work for update;
 cmd:=combat_panel_private.validate_command(p_command);fp:=public.combat_v2_sha256(cmd);
 if c.consumed_at is not null then
  if c.command_sha256 is distinct from fp then raise exception 'MG_COMMAND_REPLAY_CONFLICT' using errcode='22023'; end if;
  return c.result;
 end if;
 perform mission_generic_owner.assert_runtime(c.master_session_id);
 select * into strict a from public.combat_v2_actors where id=c.actor_id and session_id=c.encounter_id for update;
 if c.expires_at<=clock_timestamp() or a.controller_version<>c.controller_version or a.state<>'attivo'
  or c.principal_id is distinct from mission_generic_owner.actor_principal(a.id)
  or c.options_sha256 is distinct from public.combat_v2_sha256(c.legal_options)
  or c.request_key is distinct from (cmd->>'request_key')::uuid
  or c.encounter_id is distinct from (cmd->>'activity_id')::uuid
  or c.context_version is distinct from (cmd->>'context_version')::bigint
  or cmd->>'location_id' is distinct from c.legal_options#>>'{context,location_id}'
 then raise exception 'MG_CHOICE_STALE' using errcode='40001'; end if;
 select * into strict o from combat_panel_private.offers where id=(cmd->>'offer_id')::uuid
  and principal_user=c.principal_id and actor_id=c.actor_id and state='offered';
 if o.kind='administration' or not exists(select 1 from jsonb_array_elements(c.legal_options->'offers') x where x->>'offer_id'=o.id::text)
 then raise exception 'MG_COMMAND_FORBIDDEN' using errcode='42501'; end if;
 insert into mission_generic_owner.panel_permits(master_session_id,encounter_id,actor_id,work_id,principal_id,operation,request_key,transaction_id,backend_pid)
 values(c.master_session_id,c.encounter_id,c.actor_id,p_work,c.principal_id,'commit',c.request_key,txid_current(),pg_backend_pid()) returning id into permit;
 res:=case when o.source_payload->>'dispatch'='multiplication' then combat_panel_private.commit_multiplication(cmd)
  else combat_panel_private.commit_master_actor(cmd) end;
 update mission_generic_owner.panel_permits set consumed_at=clock_timestamp() where id=permit;
 update mission_generic_owner.panel_choices set consumed_at=clock_timestamp(),command_sha256=fp,result=res where id=c.id;
 return res;
end $fn$;

-- New helpers stay private: service clients must enter through the work dispatcher.
revoke all on function mission_generic_owner.actor_principal(uuid),mission_generic_owner.current_principal(),
 mission_generic_owner.principal_in_session(uuid,uuid),mission_generic_owner.choice_options(uuid,uuid,uuid,uuid),
 mission_generic_owner.choice_commit(uuid,uuid,jsonb) from public,anon,authenticated,service_role;

-- Shared hooks preserve real user and existing examination authority.
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

  return public.combat_v2_envelope(null,jsonb_build_object(
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
             and x.target_actor_id=a.id),
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
        'parent_attack_id',d.parent_attack_id,'targets',(select coalesce(jsonb_agg(jsonb_build_object('attack_target_id',t.id,'ordinal',t.ordinal,'target_actor_id',t.target_actor_id,'state',t.state,'outcome',case when v_r.state in('risolto','narrazione','narrato')then t.outcome else null end)order by t.ordinal),'[]'::jsonb)from public.combat_v2_attack_targets t where t.attack_declaration_id=d.id),'coverage',(select coalesce(jsonb_agg(jsonb_build_object('attack_target_id',c.attack_target_id,'protected_actor_id',c.protected_actor_id,'mode',c.mode,'state',c.state)order by c.id),'[]'::jsonb)from public.combat_v2_defense_coverages c where c.defense_declaration_id=d.id),'state',d.state,'order_no',d.order_no,
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
        and (v_is_master or v_is_admin or exam_regia_private.actor_principal(aa.id,aa.controller_user)=v_uid
             or exam_regia_private.actor_principal(ta.id,ta.controller_user)=v_uid or v_r.state in ('risolto','narrazione','narrato'))
    ),'[]'::jsonb) end,
    'pending_defenses',case when v_r.id is null then '[]'::jsonb else coalesce((
      select jsonb_agg(jsonb_build_object(
        'attack_declaration_id',d.id,
        'attacker_actor_id',d.actor_id,
        'attacker_name',coalesce(ac.name,ap.nome,aip.nome,'Attore'),
        'target_actor_id',d.target_actor_id,
        'target_name',coalesce(tc.name,tp.nome,tip.nome,'Attore'),
        'text',case when v_is_master or v_is_admin or exam_regia_private.actor_principal(ta.id,ta.controller_user)=v_uid
                    then d.declaration_text else '' end
      ) order by d.created_at,d.id)
      from public.combat_v2_declarations d
      join public.combat_v2_actors aa on aa.id=d.actor_id
      left join public.characters ac on ac.id=aa.character_id
      left join public.combat_v2_png_instances ap on ap.id=aa.png_instance_id left join public.combat_v2_provider_instances_v1 aip on aip.id=aa.provider_instance_v1_id
      join public.combat_v2_actors ta on ta.id=d.target_actor_id
      left join public.characters tc on tc.id=ta.character_id
      left join public.combat_v2_png_instances tp on tp.id=ta.png_instance_id left join public.combat_v2_provider_instances_v1 tip on tip.id=ta.provider_instance_v1_id
      where d.round_id=v_r.id and d.kind='attacco'
        and not exists(select 1 from public.combat_v2_declarations x
                        where x.parent_attack_id=d.id and x.kind in ('difesa','nessuna'))
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
      from public.combat_v2_round_reports q where q.round_id=v_r.id
    ) end
  ));
end
$function$;

CREATE OR REPLACE FUNCTION exam_regia_private.actor_principal(p_actor uuid, p_user uuid)
 RETURNS uuid
 LANGUAGE sql
 STABLE SECURITY DEFINER
 SET search_path TO ''
AS $function$
 SELECT coalesce(p_user,(SELECT b.service_principal_id FROM exam_regia_private.bindings b
  WHERE b.png_actor_id=p_actor AND b.state<>'closed'),mission_generic_owner.actor_principal(p_actor));
$function$;

CREATE OR REPLACE FUNCTION exam_regia_private.current_principal()
 RETURNS uuid
 LANGUAGE plpgsql
 STABLE SECURITY DEFINER
 SET search_path TO ''
AS $function$
DECLARE principal uuid; generic_principal uuid;
BEGIN
 IF auth.uid() IS NOT NULL THEN RETURN auth.uid(); END IF;
 IF NOT public.combat_v2_is_service() THEN RETURN NULL; END IF;
 generic_principal:=mission_generic_owner.current_principal();
 IF NOT EXISTS(SELECT 1 FROM exam_regia_private.runtime WHERE singleton AND enabled) THEN RETURN generic_principal; END IF;
 SELECT p.principal_id INTO principal FROM exam_regia_private.execution_permits p
 JOIN exam_regia_private.bindings b ON b.prova_id=p.prova_id AND b.png_actor_id=p.actor_id
  AND b.service_principal_id=p.principal_id AND b.state IN ('active','paused')
 JOIN public.combat_v2_sessions s ON s.id=b.combat_session_id AND s.master_session_id=b.master_session_id
  AND s.source_kind='master' AND NOT s.lesiva AND s.closed_at IS NULL
 JOIN public.master_v2_sessions m ON m.id=b.master_session_id AND m.owner_kind='ai_service'
  AND m.master_user IS NULL AND m.closed_at IS NULL
 WHERE p.transaction_id=txid_current() AND p.backend_pid=pg_backend_pid() AND p.consumed_at IS NULL
  AND p.created_at>clock_timestamp()-interval '150 seconds';
 IF principal IS NULL THEN RETURN generic_principal; END IF;
 IF generic_principal IS NOT NULL AND generic_principal<>principal THEN RAISE EXCEPTION 'MG_AMBIGUOUS_PANEL_AUTHORITY' USING ERRCODE='42501'; END IF;
 IF (SELECT count(DISTINCT p.principal_id) FROM exam_regia_private.execution_permits p
  WHERE p.transaction_id=txid_current() AND p.backend_pid=pg_backend_pid() AND p.consumed_at IS NULL)>1
 THEN RAISE EXCEPTION 'exam_regia_ambiguous_authority' USING ERRCODE='42501'; END IF;
 RETURN principal;
END $function$;

commit;
