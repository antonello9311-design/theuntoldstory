BEGIN;DO $recover$ BEGIN IF current_user<>'postgres' OR current_setting('tus.human_participant_alias_recovery',true) IS DISTINCT FROM 'reviewed:quiescent' THEN RAISE EXCEPTION 'HUMAN_PARTICIPANT_ALIAS_RECOVERY_AUTHORITY';END IF;IF md5((SELECT prosrc FROM pg_proc WHERE oid='public.mission_factory_quest_participant_state_v1(uuid)'::regprocedure)) IS DISTINCT FROM '2169f3ddfbae60cf757cd2c555a9e2f7' OR (SELECT proacl::text FROM pg_proc WHERE oid='public.mission_factory_quest_participant_state_v1(uuid)'::regprocedure) IS DISTINCT FROM '{postgres=X/postgres,authenticated=X/postgres}' OR (SELECT proowner::regrole::text FROM pg_proc WHERE oid='public.mission_factory_quest_participant_state_v1(uuid)'::regprocedure) IS DISTINCT FROM 'postgres' THEN RAISE EXCEPTION 'HUMAN_PARTICIPANT_ALIAS_RECOVERY_DRIFT';END IF;IF md5((SELECT prosrc FROM pg_proc WHERE oid='public.mission_factory_quest_enrollment_v1(uuid,text,boolean,bigint,uuid)'::regprocedure)) IS DISTINCT FROM '78616ab7cd80ac6a9cc75522e2cd866a' OR (SELECT proacl::text FROM pg_proc WHERE oid='public.mission_factory_quest_enrollment_v1(uuid,text,boolean,bigint,uuid)'::regprocedure) IS DISTINCT FROM '{postgres=X/postgres,authenticated=X/postgres}' OR (SELECT proowner::regrole::text FROM pg_proc WHERE oid='public.mission_factory_quest_enrollment_v1(uuid,text,boolean,bigint,uuid)'::regprocedure) IS DISTINCT FROM 'postgres' THEN RAISE EXCEPTION 'HUMAN_PARTICIPANT_ALIAS_RECOVERY_DRIFT';END IF;IF md5((SELECT prosrc FROM pg_proc WHERE oid='mission_factory_owner.c444_runtime_ports_complete_assert_v1()'::regprocedure)) IS DISTINCT FROM '84a85053463960741f7048fa8894f2c4' OR (SELECT proacl::text FROM pg_proc WHERE oid='mission_factory_owner.c444_runtime_ports_complete_assert_v1()'::regprocedure) IS DISTINCT FROM '{postgres=X/postgres}' OR (SELECT proowner::regrole::text FROM pg_proc WHERE oid='mission_factory_owner.c444_runtime_ports_complete_assert_v1()'::regprocedure) IS DISTINCT FROM 'postgres' THEN RAISE EXCEPTION 'HUMAN_PARTICIPANT_ALIAS_RECOVERY_DRIFT';END IF;END $recover$;
CREATE OR REPLACE FUNCTION public.mission_factory_quest_participant_state_v1(p_episode uuid)
 RETURNS jsonb
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO ''
AS $function$
declare
  uid uuid:=auth.uid();
  ch public.characters%rowtype;
  ep mission_factory_owner.quest_episodes%rowtype;
  a mission_factory_owner.quest_arcs%rowtype;
  pub mission_factory_owner.publications%rowtype;
  en mission_factory_owner.quest_episode_enrollments%rowtype;
  q mission_factory_owner.quest_run_sources%rowtype;
  m public.master_v2_sessions%rowtype;
  r public.mission_run_state%rowtype;
  ev public.mission_run_events%rowtype;
  ob public.mission_run_outbox%rowtype;
  cap mission_ai_service_owner.capabilities%rowtype;
  phase text:='unavailable';
  enrollment_open boolean:=false;
  present_now boolean;
  confirmed_session uuid;
  terminal_receipt jsonb;
  terminal_public jsonb;
  opening_valid boolean:=false;
begin
IF EXISTS(SELECT 1 FROM mission_factory_owner.quest_episodes e JOIN mission_factory_owner.quest_arcs human_route_arc ON human_route_arc.id=e.arc_id JOIN mission_factory_owner.publications p ON p.request_key=human_route_arc.publication_request WHERE e.id=p_episode AND p.content_kind='quest_human') THEN RAISE EXCEPTION 'HUMAN_PARTICIPANT_ALIAS_RECOVERY_HUMAN_ROUTE_CLOSED' USING ERRCODE='42501';RETURN mission_factory_owner.c444_participant_state_v1(p_episode);END IF;

  if uid is null or p_episode is null then
    raise exception 'MF_QUEST_PARTICIPANT_NOT_FOUND' using errcode='42501';
  end if;
  select * into ch from public.characters where user_id=uid;
  if ch.id is null or ch.user_id is distinct from uid then
    raise exception 'MF_QUEST_PARTICIPANT_NOT_FOUND' using errcode='42501';
  end if;
  select * into ep from mission_factory_owner.quest_episodes where id=p_episode for share;
  if ep.id is null then
    raise exception 'MF_QUEST_PARTICIPANT_NOT_FOUND' using errcode='42501';
  end if;
  select * into a from mission_factory_owner.quest_arcs where id=ep.arc_id for share;
  if a.id is null or not (ch.id=any(ep.member_character_ids)) then
    raise exception 'MF_QUEST_PARTICIPANT_NOT_FOUND' using errcode='42501';
  end if;
  select * into pub from mission_factory_owner.publications
    where request_key=a.publication_request for share;
  if pub.request_key is null or pub.content_kind<>'quest_ai'
     or not mission_factory_owner.quest_public_open_v3(a.id) or pub.quest_arc_id is distinct from a.id
     or ep.source_sha256 is distinct from mission_factory_owner.sha(ep.source_document)
  then raise exception 'MF_QUEST_PARTICIPANT_NOT_FOUND' using errcode='42501';
  end if;
  select * into en from mission_factory_owner.quest_episode_enrollments
    where episode_id=p_episode and character_id=ch.id for share;
  if en.character_id is not null and
     (en.user_id_snapshot is distinct from uid
      or en.source_sha256 is distinct from ep.source_sha256
      or en.roster_assignment_id is distinct from ep.roster_assignment_id)
  then raise exception 'MF_QUEST_PARTICIPANT_SOURCE_DRIFT' using errcode='40001';
  end if;
  select * into q from mission_factory_owner.quest_run_sources
    where episode_id=p_episode for share;
  enrollment_open:=mission_factory_owner.quest_episode_enrollment_open_v1(ep.id);
  if enrollment_open then
    phase:='enrollment_open';
  elsif q.session_id is not null then
    if q.arc_id is distinct from a.id or q.source_sha256 is distinct from ep.source_sha256
       or not (ch.id=any(q.roster_character_ids)) then
      phase:='uncertain';
    else
      select * into m from public.master_v2_sessions where id=q.session_id for share;
      select * into r from public.mission_run_state
        where master_session_id=q.session_id for share;
      if m.id is null or r.master_session_id is null
         or m.owner_kind is distinct from 'ai_service'
         or r.source_kind is distinct from 'quest'
         or r.quest_episode_id is distinct from ep.id then
        phase:='uncertain';
      elsif q.state='prepared' and m.stato='preparazione'
         and r.run_phase='preparazione' and q.start_event_id is null then
        phase:='prepared';
      elsif q.state in ('opening_pending','uncertain') then
        phase:=q.state;
      elsif q.state='started' then
        select * into ev from public.mission_run_events
          where id=q.start_event_id and master_session_id=q.session_id for share;
        select * into ob from public.mission_run_outbox
          where event_id=q.start_event_id and master_session_id=q.session_id for share;
        select * into cap from mission_ai_service_owner.capabilities
          where master_session_id=q.session_id for share;
        opening_valid:=ev.id is not null and ev.operation_kind='bind' and ev.status='committed'
           and ev.request_key_sha256=mission_internal.request_key_sha256(q.start_request_key)
           and ev.result->>'schema_version'='quest-episode-start/1'
           and ev.plan_version_id=q.plan_version_id and ev.version_after=1
           and ob.event_id is not null and ob.state='published'
           and ob.publication_id is not distinct from q.opening_publication_id
           and exists(select 1 from public.mission_run_publications p
             where p.id=q.opening_publication_id and p.event_id=q.start_event_id
               and p.master_session_id=q.session_id and p.status='committed')
           and exists(select 1 from public.mission_run_messages msg
             where msg.publication_id=q.opening_publication_id)
           and r.plan_version_id=q.plan_version_id and r.last_event_id is not null
           and cap.id is not null and cap.state='active'
           and cap.quest_source_session_id=q.session_id
           and cap.start_request_key=q.start_request_key
           and cap.expected_control_version>=2
           and cap.expected_control_version<=m.control_version;
        if opening_valid and m.stato='in_corso' and m.closed_at is null
           and r.run_phase='in_corso' and r.control_version>=1
        then phase:='started'; confirmed_session:=q.session_id;
        elsif opening_valid and m.stato='chiusura' and m.closed_at is null
           and r.run_phase='in_corso' then
          select * into ev from public.mission_run_events
            where id=r.last_event_id and master_session_id=q.session_id
              and operation_kind='close' for share;
          if ev.id is not null and ev.status='committed'
             and ev.result->>'schema_version'='quest-native-close/1'
             and ev.plan_version_id=q.plan_version_id
             and ev.version_after=r.control_version
             and exists(select 1 from public.mission_run_outbox pending
               where pending.event_id=ev.id and pending.master_session_id=q.session_id
                 and pending.state='pending')
          then phase:='closing_pending'; confirmed_session:=q.session_id;
          else phase:='uncertain'; end if;
        else phase:='uncertain'; end if;
      elsif q.state='terminal' then
        terminal_receipt:=mission_factory_owner.quest_terminal_confirmed_v1(q.session_id);
        if terminal_receipt is null then phase:='uncertain';
        else
          phase:='terminal'; confirmed_session:=q.session_id;
          terminal_public:=jsonb_build_object(
            'schema_version','quest-episode-terminal-public/1',
            'quest_episode_id',ep.id,
            'native_terminal_receipt_id',terminal_receipt->>'native_terminal_receipt_id',
            'outcome',terminal_receipt->>'outcome',
            'reward_state',terminal_receipt->>'reward_state',
            'next_episode_eligible',terminal_receipt->'next_episode_eligible');
        end if;
      else
        phase:='uncertain';
      end if;
    end if;
    present_now:=public._combat_presente(uid,q.location_id) and
      coalesce((select not pr.left_logged from public.presence pr
                where pr.user_id=uid),false);
  end if;
  return jsonb_build_object(
    'schema_version','quest-episode-participant-state/1',
    'quest_episode_id',ep.id,'character_id',ch.id,
    'phase',phase,'enrollment_open',enrollment_open,
    'enrollment_state',case when en.character_id is null then null else en.state end,
    'ready',case when en.character_id is null then false else en.ready end,
    'enrollment_control_version',en.control_version,
    'actions',jsonb_build_object(
      'join',enrollment_open and (en.character_id is null or en.state='withdrawn'),
      'withdraw',enrollment_open and coalesce(en.state='joined',false),
      'ready',enrollment_open and coalesce(en.state='joined',false)),
    'present_now',present_now,'native_session_id',confirmed_session,
    'terminal',terminal_public);
end; $function$
;
CREATE OR REPLACE FUNCTION public.mission_factory_quest_enrollment_v1(p_episode uuid, p_operation text, p_ready boolean, p_expected_version bigint, p_request uuid)
 RETURNS jsonb
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO ''
AS $function$
declare uid uuid:=auth.uid(); c public.characters%rowtype;
  e mission_factory_owner.quest_episodes%rowtype;
  a mission_factory_owner.quest_arcs%rowtype;
  pub mission_factory_owner.publications%rowtype;
  x mission_factory_owner.quest_episode_enrollments%rowtype;
  old mission_factory_owner.quest_episode_enrollment_requests%rowtype;
  fp text; receipt jsonb;
begin
IF EXISTS(SELECT 1 FROM mission_factory_owner.quest_episodes e JOIN mission_factory_owner.quest_arcs human_route_arc ON human_route_arc.id=e.arc_id JOIN mission_factory_owner.publications p ON p.request_key=human_route_arc.publication_request WHERE e.id=p_episode AND p.content_kind='quest_human') THEN RAISE EXCEPTION 'HUMAN_PARTICIPANT_ALIAS_RECOVERY_HUMAN_ROUTE_CLOSED' USING ERRCODE='42501';RETURN mission_factory_owner.c444_enrollment_v1(p_episode,p_operation,p_ready,p_expected_version,p_request);END IF;

  if uid is null or p_episode is null or p_request is null
     or p_operation is null or p_operation not in ('join','withdraw','ready')
     or (p_operation='ready' and p_ready is null)
     or (p_operation<>'ready' and p_ready is not null)
     or (p_operation='join' and p_expected_version is not null)
     or (p_operation in ('withdraw','ready') and
         (p_expected_version is null or p_expected_version<1))
  then raise exception 'MF_QUEST_ENROLLMENT_INPUT' using errcode='22023'; end if;
  select * into strict c from public.characters where user_id=uid;
  perform pg_advisory_xact_lock(hashtextextended(p_request::text,25092601));
  fp:=mission_factory_owner.sha(jsonb_build_object('episode',p_episode,
    'operation',p_operation,'character',c.id,'ready',p_ready,
    'expected_version',p_expected_version));
  select * into old from mission_factory_owner.quest_episode_enrollment_requests
    where request_key=p_request for share;
  if found then
    if old.actor_user<>uid or old.episode_id<>p_episode
       or old.character_id<>c.id or old.operation<>p_operation
       or old.request_fingerprint<>fp
    then raise exception 'MF_QUEST_ENROLLMENT_REQUEST_CONFLICT' using errcode='23505'; end if;
    return old.result;
  end if;
  select * into strict a from mission_factory_owner.quest_arcs
    where id=(select arc_id from mission_factory_owner.quest_episodes where id=p_episode) for share;
  select * into strict e from mission_factory_owner.quest_episodes
    where id=p_episode and arc_id=a.id for update;
  select * into strict pub from mission_factory_owner.publications
    where request_key=a.publication_request for share;
  if not mission_factory_owner.quest_episode_enrollment_open_v1(e.id)
     or pub.content_kind<>'quest_ai' or not mission_factory_owner.quest_public_open_v3(a.id)
     or pub.quest_arc_id<>a.id
     or e.source_sha256<>mission_factory_owner.sha(e.source_document)
     or not(c.id=any(e.member_character_ids)) or c.user_id is distinct from uid
     or exists(select 1 from mission_factory_owner.quest_run_sources
       where episode_id=p_episode)
  then raise exception 'MF_QUEST_ENROLLMENT_CLOSED' using errcode='55000'; end if;
  perform pg_advisory_xact_lock(hashtextextended(c.id::text,203));
  select * into x from mission_factory_owner.quest_episode_enrollments
    where episode_id=p_episode and character_id=c.id for update;
  if p_operation='join' then
    if x.character_id is null or x.state='withdrawn' then
      if exists(select 1 from public.mission_bookings b
          join public.missions m on m.id=b.mission_id
          where b.character_id=c.id and b.status='iscritto'
            and m.status in ('aperta','programmata'))
         or exists(select 1 from public.master_v2_participants mp
           join public.master_v2_sessions ms on ms.id=mp.session_id
           where mp.character_id=c.id and mp.left_at is null and ms.closed_at is null)
         or exists(select 1 from mission_ai_board_owner.roster_reservations rr
           where rr.character_id=c.id and rr.state='active')
      then raise exception 'MF_QUEST_CHARACTER_BUSY' using errcode='40001'; end if;
    end if;
    if x.character_id is null then
      insert into mission_factory_owner.quest_episode_enrollments(
        episode_id,character_id,user_id_snapshot,source_sha256,
        roster_assignment_id,state)
      values(p_episode,c.id,uid,e.source_sha256,e.roster_assignment_id,'joined')
      returning * into x;
    elsif x.user_id_snapshot<>uid or x.source_sha256<>e.source_sha256
       or x.roster_assignment_id<>e.roster_assignment_id
    then raise exception 'MF_QUEST_ENROLLMENT_SOURCE_DRIFT' using errcode='40001';
    elsif x.state='withdrawn' then
      update mission_factory_owner.quest_episode_enrollments
        set state='joined',ready=false,ready_at=null,
          control_version=control_version+1,joined_at=clock_timestamp(),
          changed_at=clock_timestamp()
        where episode_id=p_episode and character_id=c.id returning * into x;
    end if;
  else
    if x.character_id is null or x.user_id_snapshot<>uid or x.state<>'joined'
    then raise exception 'MF_QUEST_NOT_JOINED' using errcode='55000'; end if;
    if x.control_version<>p_expected_version
    then raise exception 'MF_QUEST_ENROLLMENT_CAS' using errcode='40001'; end if;
    if p_operation='withdraw' then
      update mission_factory_owner.quest_episode_enrollments
        set state='withdrawn',ready=false,ready_at=null,
          control_version=control_version+1,changed_at=clock_timestamp()
        where episode_id=p_episode and character_id=c.id returning * into x;
    else
      update mission_factory_owner.quest_episode_enrollments
        set ready=p_ready,ready_at=case when p_ready then clock_timestamp() else null end,
          control_version=control_version+1,changed_at=clock_timestamp()
        where episode_id=p_episode and character_id=c.id returning * into x;
    end if;
  end if;
  receipt:=jsonb_build_object('schema_version','quest-episode-enrollment/1',
    'request_key',p_request,'quest_episode_id',p_episode,'character_id',c.id,
    'source_sha256',x.source_sha256,'roster_assignment_id',x.roster_assignment_id,
    'state',x.state,'ready',x.ready,'control_version',x.control_version);
  insert into mission_factory_owner.quest_episode_enrollment_requests(
    request_key,episode_id,character_id,actor_user,operation,request_fingerprint,result)
  values(p_request,p_episode,c.id,uid,p_operation,fp,receipt);
  return receipt;
end; $function$
;
CREATE OR REPLACE FUNCTION mission_factory_owner.c444_runtime_ports_complete_assert_v1()
 RETURNS void
 LANGUAGE plpgsql
 STABLE SECURITY DEFINER
 SET search_path TO ''
AS $function$BEGIN
IF EXISTS(SELECT 1 FROM jsonb_array_elements($c501_pins$[{"all_arg_types":[],"arg_modes":[],"arg_names":null,"body_md5":"6c4c26b80b3b5df779d333bc07177318","configuration":["search_path=\"\""],"default_arg_count":0,"execute":["postgres"],"input_arg_types":[],"language":"plpgsql","lookup_signature":"mission_factory_owner.c408_stage1_complete_assert_v1()","oid":"279179","owner":"postgres","parallel":"u","return_type":"pg_catalog.void","returns_set":false,"security_definer":true,"strict":false,"variadic_type":null,"volatility":"s"}]$c501_pins$::jsonb) c501_expected LEFT JOIN pg_catalog.pg_proc c501_proc ON c501_proc.oid=pg_catalog.to_regprocedure(c501_expected->>'lookup_signature') WHERE c501_proc.oid IS NULL OR (c501_expected->>'oid' IS NOT NULL AND c501_proc.oid::text IS DISTINCT FROM c501_expected->>'oid') OR md5(c501_proc.prosrc) IS DISTINCT FROM c501_expected->>'body_md5' OR c501_proc.proargtypes::text IS DISTINCT FROM coalesce((SELECT string_agg(pg_catalog.to_regtype(c501_argtype)::oid::text,' ' ORDER BY c501_ord)FROM jsonb_array_elements_text(c501_expected->'input_arg_types')WITH ORDINALITY c501_inputs(c501_argtype,c501_ord)),'') OR coalesce((SELECT jsonb_agg(pg_catalog.format('%I.%I',c501_ns.nspname,c501_type.typname) ORDER BY c501_ord)FROM unnest(coalesce(c501_proc.proallargtypes,c501_proc.proargtypes::oid[]))WITH ORDINALITY c501_all(c501_type_oid,c501_ord)JOIN pg_catalog.pg_type c501_type ON c501_type.oid=c501_type_oid JOIN pg_catalog.pg_namespace c501_ns ON c501_ns.oid=c501_type.typnamespace),'[]'::jsonb) IS DISTINCT FROM c501_expected->'all_arg_types' OR to_jsonb(coalesce(c501_proc.proargmodes,array_fill('i'::"char",ARRAY[c501_proc.pronargs]))) IS DISTINCT FROM c501_expected->'arg_modes' OR coalesce(to_jsonb(c501_proc.proargnames),'null'::jsonb) IS DISTINCT FROM c501_expected->'arg_names' OR c501_proc.prorettype IS DISTINCT FROM pg_catalog.to_regtype(c501_expected->>'return_type') OR c501_proc.proretset IS DISTINCT FROM(c501_expected->>'returns_set')::boolean OR c501_proc.pronargdefaults IS DISTINCT FROM(c501_expected->>'default_arg_count')::integer OR (c501_proc.pronargdefaults=0 AND c501_proc.proargdefaults IS NOT NULL) OR c501_proc.provariadic IS DISTINCT FROM coalesce(pg_catalog.to_regtype(c501_expected->>'variadic_type')::oid,0::oid) OR c501_proc.proisstrict IS DISTINCT FROM(c501_expected->>'strict')::boolean OR c501_proc.provolatile::text IS DISTINCT FROM c501_expected->>'volatility' OR c501_proc.proparallel::text IS DISTINCT FROM c501_expected->>'parallel' OR c501_proc.prosecdef IS DISTINCT FROM(c501_expected->>'security_definer')::boolean OR(SELECT lanname FROM pg_catalog.pg_language WHERE oid=c501_proc.prolang)IS DISTINCT FROM c501_expected->>'language' OR to_jsonb(c501_proc.proconfig) IS DISTINCT FROM c501_expected->'configuration' OR pg_catalog.pg_get_userbyid(c501_proc.proowner)IS DISTINCT FROM c501_expected->>'owner' OR c501_proc.proleakproof OR coalesce((SELECT jsonb_agg(CASE WHEN c501_acl.grantee=0 THEN 'PUBLIC' ELSE pg_catalog.pg_get_userbyid(c501_acl.grantee)END ORDER BY CASE WHEN c501_acl.grantee=0 THEN 'PUBLIC' ELSE pg_catalog.pg_get_userbyid(c501_acl.grantee)END)FROM pg_catalog.aclexplode(coalesce(c501_proc.proacl,pg_catalog.acldefault('f',c501_proc.proowner)))c501_acl WHERE c501_acl.privilege_type='EXECUTE'),'[]'::jsonb)IS DISTINCT FROM c501_expected->'execute' OR EXISTS(SELECT 1 FROM pg_catalog.aclexplode(coalesce(c501_proc.proacl,pg_catalog.acldefault('f',c501_proc.proowner)))c501_acl WHERE c501_acl.is_grantable))THEN RAISE EXCEPTION 'C501_CURRENT_HUMAN_QUALIFIER_ABI_CAS' USING ERRCODE='40001';END IF;
PERFORM mission_factory_owner.c408_stage1_complete_assert_v1();
IF NOT EXISTS(SELECT 1 FROM mission_factory_owner.c444_install_progress WHERE singleton AND complete AND next_unit=26 AND source_input_sha256='9c814c08fba12afbdec246b477a73c0047d318b51dc7c83a23050bd9da9e0aa9')THEN RAISE EXCEPTION 'C501_SOURCE_FAMILY_COMPLETE_PREFIX_REQUIRED';END IF;
IF EXISTS(SELECT 1 FROM jsonb_array_elements((SELECT jsonb_agg('{"configuration":["search_path=\"\""],"default_arg_count":0,"owner":"postgres","parallel":"u","returns_set":false,"security_definer":true,"strict":false,"variadic_type":null}'::jsonb||p)FROM jsonb_array_elements('[{"all_arg_types":[],"arg_modes":[],"arg_names":null,"body_md5":"75fcad93b0da5fee0fc6b7af652a5e85","execute":["postgres"],"input_arg_types":[],"language":"sql","lookup_signature":"mission_factory_owner.c444_enabled_v1()","oid":null,"return_type":"pg_catalog.bool","volatility":"s"},{"all_arg_types":["pg_catalog.uuid"],"arg_modes":["i"],"arg_names":["p_session"],"body_md5":"0a7fa43e594605d397504828f1961f55","execute":["postgres"],"input_arg_types":["pg_catalog.uuid"],"language":"plpgsql","lookup_signature":"mission_factory_owner.c444_read_identity_v1(pg_catalog.uuid)","oid":null,"return_type":"pg_catalog.jsonb","volatility":"s"},{"all_arg_types":["pg_catalog.uuid"],"arg_modes":["i"],"arg_names":["p_session"],"body_md5":"a2f72b56b71b3a8ea089aff06a66e7ae","execute":["postgres"],"input_arg_types":["pg_catalog.uuid"],"language":"plpgsql","lookup_signature":"mission_factory_owner.c444_source_read_assert_v1(pg_catalog.uuid)","oid":null,"return_type":"pg_catalog.jsonb","volatility":"v"},{"all_arg_types":["pg_catalog.uuid"],"arg_modes":["i"],"arg_names":["p_episode"],"body_md5":"3ea3a2a0749910a979216b801a09bb2e","execute":["postgres"],"input_arg_types":["pg_catalog.uuid"],"language":"plpgsql","lookup_signature":"mission_factory_owner.c444_episode_read_assert_v1(pg_catalog.uuid)","oid":null,"return_type":"pg_catalog.void","volatility":"s"},{"all_arg_types":["pg_catalog.uuid"],"arg_modes":["i"],"arg_names":["p_episode"],"body_md5":"5d1943abf0a90cd395165756207e934e","execute":["postgres"],"input_arg_types":["pg_catalog.uuid"],"language":"plpgsql","lookup_signature":"mission_factory_owner.c444_enrollment_open_v1(pg_catalog.uuid)","oid":null,"return_type":"pg_catalog.bool","volatility":"v"},{"all_arg_types":["pg_catalog.uuid","pg_catalog.text","pg_catalog.bool","pg_catalog.int8","pg_catalog.uuid"],"arg_modes":["i","i","i","i","i"],"arg_names":["p_episode","p_operation","p_ready","p_expected_version","p_request"],"body_md5":"1bad66b63bff109cf4e65d14be59722f","execute":["postgres"],"input_arg_types":["pg_catalog.uuid","pg_catalog.text","pg_catalog.bool","pg_catalog.int8","pg_catalog.uuid"],"language":"plpgsql","lookup_signature":"mission_factory_owner.c444_enrollment_v1(pg_catalog.uuid,pg_catalog.text,pg_catalog.bool,pg_catalog.int8,pg_catalog.uuid)","oid":null,"return_type":"pg_catalog.jsonb","volatility":"v"},{"all_arg_types":["pg_catalog.uuid","pg_catalog.text","pg_catalog.bool","pg_catalog.int8","pg_catalog.uuid"],"arg_modes":["i","i","i","i","i"],"arg_names":["p_episode","p_operation","p_ready","p_expected_version","p_request"],"body_md5":"3bb3fde024be997913ba29b795bf2d4b","execute":["authenticated","postgres"],"input_arg_types":["pg_catalog.uuid","pg_catalog.text","pg_catalog.bool","pg_catalog.int8","pg_catalog.uuid"],"language":"plpgsql","lookup_signature":"public.mission_factory_quest_enrollment_v1(pg_catalog.uuid,pg_catalog.text,pg_catalog.bool,pg_catalog.int8,pg_catalog.uuid)","oid":"276409","return_type":"pg_catalog.jsonb","volatility":"v"},{"all_arg_types":["pg_catalog.uuid"],"arg_modes":["i"],"arg_names":["p_session"],"body_md5":"85a879af8a80d50593fcb3970869249f","execute":["postgres"],"input_arg_types":["pg_catalog.uuid"],"language":"plpgsql","lookup_signature":"mission_factory_owner.c444_terminal_confirmed_v1(pg_catalog.uuid)","oid":null,"return_type":"pg_catalog.jsonb","volatility":"v"},{"all_arg_types":["pg_catalog.uuid"],"arg_modes":["i"],"arg_names":["p_session"],"body_md5":"1c6a6240f27b3add37546175768633a2","execute":["postgres"],"input_arg_types":["pg_catalog.uuid"],"language":"plpgsql","lookup_signature":"mission_factory_owner.quest_terminal_confirmed_v1(pg_catalog.uuid)","oid":"276431","return_type":"pg_catalog.jsonb","volatility":"v"},{"all_arg_types":["pg_catalog.uuid"],"arg_modes":["i"],"arg_names":["p_episode"],"body_md5":"5fa62eda7260904e189b55b06088254b","execute":["postgres"],"input_arg_types":["pg_catalog.uuid"],"language":"plpgsql","lookup_signature":"mission_factory_owner.c444_participant_state_v1(pg_catalog.uuid)","oid":null,"return_type":"pg_catalog.jsonb","volatility":"v"},{"all_arg_types":["pg_catalog.uuid"],"arg_modes":["i"],"arg_names":["p_episode"],"body_md5":"6315d7375901bd8fd795cf8176608196","execute":["authenticated","postgres"],"input_arg_types":["pg_catalog.uuid"],"language":"plpgsql","lookup_signature":"public.mission_factory_quest_participant_state_v1(pg_catalog.uuid)","oid":"276446","return_type":"pg_catalog.jsonb","volatility":"v"},{"all_arg_types":["pg_catalog.uuid"],"arg_modes":["i"],"arg_names":["p_request"],"body_md5":"d06ad7832dd3bc64fc0d0472d9965534","execute":["postgres"],"input_arg_types":["pg_catalog.uuid"],"language":"plpgsql","lookup_signature":"mission_factory_owner.c444_run_state_v1(pg_catalog.uuid)","oid":null,"return_type":"pg_catalog.jsonb","volatility":"v"},{"all_arg_types":["pg_catalog.uuid"],"arg_modes":["i"],"arg_names":["p_request"],"body_md5":"6d17dc85221b79a22a4205103898ba0f","execute":["authenticated","postgres"],"input_arg_types":["pg_catalog.uuid"],"language":"plpgsql","lookup_signature":"public.mission_factory_quest_run_state_v1(pg_catalog.uuid)","oid":"276432","return_type":"pg_catalog.jsonb","volatility":"v"},{"all_arg_types":["pg_catalog.uuid"],"arg_modes":["i"],"arg_names":["p_session"],"body_md5":"8d2d40aa16abbf40ea7801ae4ec49774","execute":["postgres"],"input_arg_types":["pg_catalog.uuid"],"language":"plpgsql","lookup_signature":"mission_factory_owner.c444_action_scope_v1(pg_catalog.uuid)","oid":null,"return_type":"pg_catalog.jsonb","volatility":"v"},{"all_arg_types":["pg_catalog.uuid"],"arg_modes":["i"],"arg_names":["p_session"],"body_md5":"7e7da01987e744d27f634cd93c4cd273","execute":["authenticated","postgres"],"input_arg_types":["pg_catalog.uuid"],"language":"plpgsql","lookup_signature":"public.mission_factory_quest_human_runtime_state_v1(pg_catalog.uuid)","oid":null,"return_type":"pg_catalog.jsonb","volatility":"v"},{"all_arg_types":["pg_catalog.uuid"],"arg_modes":["i"],"arg_names":["p_session"],"body_md5":"0bda32f1607eb10808df90b042f5473a","execute":["authenticated","postgres"],"input_arg_types":["pg_catalog.uuid"],"language":"plpgsql","lookup_signature":"public.mission_human_phase_state_v1(pg_catalog.uuid)","oid":"50702","return_type":"pg_catalog.jsonb","volatility":"s"}]'::jsonb)z(p))) c501_expected LEFT JOIN pg_catalog.pg_proc c501_proc ON c501_proc.oid=pg_catalog.to_regprocedure(c501_expected->>'lookup_signature') WHERE c501_proc.oid IS NULL OR (c501_expected->>'oid' IS NOT NULL AND c501_proc.oid::text IS DISTINCT FROM c501_expected->>'oid') OR md5(c501_proc.prosrc) IS DISTINCT FROM c501_expected->>'body_md5' OR c501_proc.proargtypes::text IS DISTINCT FROM coalesce((SELECT string_agg(pg_catalog.to_regtype(c501_argtype)::oid::text,' ' ORDER BY c501_ord)FROM jsonb_array_elements_text(c501_expected->'input_arg_types')WITH ORDINALITY c501_inputs(c501_argtype,c501_ord)),'') OR coalesce((SELECT jsonb_agg(pg_catalog.format('%I.%I',c501_ns.nspname,c501_type.typname) ORDER BY c501_ord)FROM unnest(coalesce(c501_proc.proallargtypes,c501_proc.proargtypes::oid[]))WITH ORDINALITY c501_all(c501_type_oid,c501_ord)JOIN pg_catalog.pg_type c501_type ON c501_type.oid=c501_type_oid JOIN pg_catalog.pg_namespace c501_ns ON c501_ns.oid=c501_type.typnamespace),'[]'::jsonb) IS DISTINCT FROM c501_expected->'all_arg_types' OR to_jsonb(coalesce(c501_proc.proargmodes,array_fill('i'::"char",ARRAY[c501_proc.pronargs]))) IS DISTINCT FROM c501_expected->'arg_modes' OR coalesce(to_jsonb(c501_proc.proargnames),'null'::jsonb) IS DISTINCT FROM c501_expected->'arg_names' OR c501_proc.prorettype IS DISTINCT FROM pg_catalog.to_regtype(c501_expected->>'return_type') OR c501_proc.proretset IS DISTINCT FROM(c501_expected->>'returns_set')::boolean OR c501_proc.pronargdefaults IS DISTINCT FROM(c501_expected->>'default_arg_count')::integer OR (c501_proc.pronargdefaults=0 AND c501_proc.proargdefaults IS NOT NULL) OR c501_proc.provariadic IS DISTINCT FROM coalesce(pg_catalog.to_regtype(c501_expected->>'variadic_type')::oid,0::oid) OR c501_proc.proisstrict IS DISTINCT FROM(c501_expected->>'strict')::boolean OR c501_proc.provolatile::text IS DISTINCT FROM c501_expected->>'volatility' OR c501_proc.proparallel::text IS DISTINCT FROM c501_expected->>'parallel' OR c501_proc.prosecdef IS DISTINCT FROM(c501_expected->>'security_definer')::boolean OR(SELECT lanname FROM pg_catalog.pg_language WHERE oid=c501_proc.prolang)IS DISTINCT FROM c501_expected->>'language' OR to_jsonb(c501_proc.proconfig) IS DISTINCT FROM c501_expected->'configuration' OR pg_catalog.pg_get_userbyid(c501_proc.proowner)IS DISTINCT FROM c501_expected->>'owner' OR c501_proc.proleakproof OR coalesce((SELECT jsonb_agg(CASE WHEN c501_acl.grantee=0 THEN 'PUBLIC' ELSE pg_catalog.pg_get_userbyid(c501_acl.grantee)END ORDER BY CASE WHEN c501_acl.grantee=0 THEN 'PUBLIC' ELSE pg_catalog.pg_get_userbyid(c501_acl.grantee)END)FROM pg_catalog.aclexplode(coalesce(c501_proc.proacl,pg_catalog.acldefault('f',c501_proc.proowner)))c501_acl WHERE c501_acl.privilege_type='EXECUTE'),'[]'::jsonb)IS DISTINCT FROM c501_expected->'execute' OR EXISTS(SELECT 1 FROM pg_catalog.aclexplode(coalesce(c501_proc.proacl,pg_catalog.acldefault('f',c501_proc.proowner)))c501_acl WHERE c501_acl.is_grantable))THEN RAISE EXCEPTION 'C501_PORTS_EFFECTIVE_FULL_ABI_ACL_CAS' USING ERRCODE='40001';END IF;
END$function$
;
DO $post$ BEGIN PERFORM mission_factory_owner.c444_runtime_ports_complete_assert_v1();END $post$;COMMIT;
