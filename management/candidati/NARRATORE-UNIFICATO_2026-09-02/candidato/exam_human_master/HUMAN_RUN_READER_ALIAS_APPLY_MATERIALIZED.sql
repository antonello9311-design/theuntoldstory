BEGIN;
SELECT pg_catalog.set_config('tus.human_run_reader_alias_authority','reviewed:0/0/0',true);
SELECT pg_catalog.set_config('tus.human21_root_authority',$root_authority${"schema_version":"human21-root-authority/1","request_key":"be36979d-a5bf-4753-8f45-5ebbdb1480ac","operation":"install_human21_readonly_runstate_alias_delta_current_C444_pin","review":"0/0/0","human_aggregate":21,"review_sha256":"18312ce7c40bc8225e1d9b0082936f2f5367b14eacd4483a90bff7ff7b5e6f57","source_sha256":"c0637b93811ef9bed0f3683e1845000f511c28a2c1337d1242bf4d82c9a4a683","issued_at":"2026-10-14T19:41:40.654352+00:00","expires_at":"2026-10-14T19:46:40.654352+00:00","campaign_deadline":"2026-10-14T19:51:58.071006+00:00","provider_calls":0,"WIP_reset":false,"session_id":"97d2a684-956d-57ad-8d84-aca627dd9e5c","scope":"Onlyread getterSQLaliasq/currentC444correspondingpin. Originalprep72e/UIconfirmed, Nativeoptin0/readfailure BEFOREoptin; noC463/CFG7/lease/public/otherfunctionchanges; historyHuman1\u201321 preserved."}$root_authority$,true);
DO $root_permit$ DECLARE e jsonb:=current_setting('tus.human21_root_authority',true)::jsonb;BEGIN IF current_user<>'postgres' OR e->>'review'<>'0/0/0' OR e->>'schema_version'<>'human21-root-authority/1' OR (e->>'expires_at')::timestamptz<=clock_timestamp() THEN RAISE EXCEPTION 'HUMAN21_FRESH_ROOT_PERMIT';END IF;END $root_permit$;
DO $guard$ BEGIN IF current_user<>'postgres' OR current_setting('tus.human_run_reader_alias_authority',true) IS DISTINCT FROM 'reviewed:0/0/0' THEN RAISE EXCEPTION 'HUMAN21_AUTHORITY';END IF;IF md5(pg_get_functiondef('public.mission_factory_quest_run_state_v1(uuid)'::regprocedure)) IS DISTINCT FROM 'bca5ded7d72f2613423a3ee89181e6de' OR (SELECT proacl::text FROM pg_proc WHERE oid='public.mission_factory_quest_run_state_v1(uuid)'::regprocedure) IS DISTINCT FROM '{postgres=X/postgres,authenticated=X/postgres}' OR (SELECT proowner::regrole::text FROM pg_proc WHERE oid='public.mission_factory_quest_run_state_v1(uuid)'::regprocedure) IS DISTINCT FROM 'postgres' THEN RAISE EXCEPTION 'HUMAN21_BASELINE_DRIFT';END IF;IF md5(pg_get_functiondef('mission_factory_owner.c444_runtime_ports_complete_assert_v1()'::regprocedure)) IS DISTINCT FROM 'e37fb17f85f18305ec3152196d46ba7a' OR (SELECT proacl::text FROM pg_proc WHERE oid='mission_factory_owner.c444_runtime_ports_complete_assert_v1()'::regprocedure) IS DISTINCT FROM '{postgres=X/postgres}' OR (SELECT proowner::regrole::text FROM pg_proc WHERE oid='mission_factory_owner.c444_runtime_ports_complete_assert_v1()'::regprocedure) IS DISTINCT FROM 'postgres' THEN RAISE EXCEPTION 'HUMAN21_BASELINE_DRIFT';END IF;END $guard$;
CREATE OR REPLACE FUNCTION public.mission_factory_quest_run_state_v1(p_request uuid)
 RETURNS jsonb
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO ''
AS $function$
declare q mission_factory_owner.quest_run_sources%rowtype;
  m public.master_v2_sessions%rowtype;
  r public.mission_run_state%rowtype;
  e public.mission_run_events%rowtype;
  ob public.mission_run_outbox%rowtype;
  c mission_ai_service_owner.capabilities%rowtype;
  op text; st text; receipt jsonb; n integer;
  terminal_event public.mission_run_events%rowtype;
begin
IF EXISTS(SELECT 1 FROM mission_factory_owner.c384_human_bindings b JOIN mission_factory_owner.quest_run_sources human_route_source ON human_route_source.session_id=b.session_id WHERE human_route_source.prepare_request_key=p_request OR human_route_source.start_request_key=p_request OR EXISTS(SELECT 1 FROM public.mission_run_events ev WHERE ev.master_session_id=human_route_source.session_id AND ev.operation_kind='close' AND ev.request_key_sha256=mission_internal.request_key_sha256(p_request))) THEN RETURN mission_factory_owner.c444_run_state_v1(p_request);END IF;

  perform mission_ai_board_owner.staff_only();
  if p_request is null then
    raise exception 'MF_QUEST_READBACK_REQUEST' using errcode='22023'; end if;
  select count(*) into n from (
    select run_source.session_id from mission_factory_owner.quest_run_sources run_source
      where run_source.prepare_request_key=p_request or run_source.start_request_key=p_request
    union all
    select ev.master_session_id from public.mission_run_events ev
      join mission_factory_owner.quest_run_sources run_source on run_source.session_id=ev.master_session_id
      where ev.operation_kind='close'
        and ev.request_key_sha256=mission_internal.request_key_sha256(p_request)
  ) requests;
  if n=0 then
    return jsonb_build_object('schema_version','quest-episode-run-state/1',
      'request_key',p_request,'operation',null,'state','unknown','receipt',null,
      'run_control_version',null,'opening_publication_id',null);
  elsif n<>1 then
    raise exception 'MF_QUEST_READBACK_AMBIGUOUS' using errcode='40001'; end if;
  select * into terminal_event from public.mission_run_events ev
    where ev.operation_kind='close'
      and ev.request_key_sha256=mission_internal.request_key_sha256(p_request)
      and exists(select 1 from mission_factory_owner.quest_run_sources run_source
        where run_source.session_id=ev.master_session_id) for share;
  if terminal_event.id is not null then
    select * into strict q from mission_factory_owner.quest_run_sources
      where session_id=terminal_event.master_session_id for share;
    op:='terminal';
  else
    select * into strict q from mission_factory_owner.quest_run_sources
      where prepare_request_key=p_request or start_request_key=p_request for share;
    op:=case when p_request=q.prepare_request_key then 'prepare' else 'start' end;
  end if;
  select * into strict m from public.master_v2_sessions
    where id=q.session_id for share;
  select * into strict r from public.mission_run_state
    where master_session_id=q.session_id for share;
  if op<>'terminal' and m.stato='chiusura' then
    select * into terminal_event from public.mission_run_events
      where id=r.last_event_id and master_session_id=q.session_id
        and operation_kind='close' for share;
  end if;
  st:=q.state;
  if op='prepare' then
    receipt:=jsonb_build_object('schema_version','quest-episode-prepare/1',
      'request_key',p_request,'state','prepared',
      'quest_arc_id',q.arc_id,'quest_episode_id',q.episode_id,
      'native_session_id',q.session_id,'source_sha256',q.source_sha256,
      'plan_version_id',q.plan_version_id,'plan_sha256',q.plan_sha256,
      'roster_snapshot_sha256',q.roster_snapshot_sha256,
      'staff_release_sha256',q.staff_release_sha256,
      'location_id',q.location_id,'control_version',1,
      'opening_publication_id',null);
  elsif op='start' then
    select * into e from public.mission_run_events
      where id=q.start_event_id and master_session_id=q.session_id for share;
    if e.id is null or e.operation_kind<>'bind' or e.status<>'committed'
       or e.request_key_sha256<>mission_internal.request_key_sha256(p_request)
       or e.plan_version_id is distinct from q.plan_version_id
       or e.version_after is distinct from 1
       or e.result->>'schema_version' is distinct from 'quest-episode-start/1'
    then st:='uncertain'; receipt:=null;
    else
      receipt:=e.result;
      select * into ob from public.mission_run_outbox
        where event_id=e.id and master_session_id=q.session_id for share;
      select * into c from mission_ai_service_owner.capabilities
        where master_session_id=q.session_id for share;
      if ob.event_id is null or c.id is null
         or c.quest_source_session_id is distinct from q.session_id
         or c.start_request_key is distinct from q.start_request_key
      then st:='uncertain'; end if;
    end if;
  else
    receipt:=null;
  end if;
  if q.state='prepared' then
    if m.stato<>'preparazione' or m.control_version<>1
       or r.run_phase<>'preparazione' or r.control_version<>1
       or r.last_event_id is not null or q.start_event_id is not null
    then st:='uncertain'; end if;
  elsif q.state='started' then
    if st<>'uncertain' and m.stato='chiusura'
       and r.last_event_id is not distinct from terminal_event.id
       and terminal_event.id is not null and terminal_event.operation_kind='close'
       and terminal_event.status='committed'
       and terminal_event.result->>'schema_version'='quest-native-close/1'
       and terminal_event.version_after=r.control_version
       and terminal_event.plan_version_id=q.plan_version_id
       and q.opening_publication_id is not null
       and exists(select 1 from public.mission_run_publications opening
         where opening.id=q.opening_publication_id
           and opening.event_id=q.start_event_id
           and opening.master_session_id=q.session_id
           and opening.status='committed')
       and (op<>'terminal' or terminal_event.request_key_sha256=
         mission_internal.request_key_sha256(p_request))
       and exists(select 1 from public.mission_run_outbox pending
         where pending.event_id=terminal_event.id
           and pending.master_session_id=q.session_id and pending.state='pending')
    then
      st:='closing_pending'; receipt:=null;
    elsif op='terminal' then
      st:='uncertain'; receipt:=null;
    else
    if op='prepare' and ob.event_id is null then
      select * into ob from public.mission_run_outbox
        where event_id=q.start_event_id and master_session_id=q.session_id for share;
      select * into c from mission_ai_service_owner.capabilities
        where master_session_id=q.session_id for share;
    end if;
    if ob.event_id is null or c.id is null
       or ob.state is distinct from 'published'
       or ob.publication_id is distinct from q.opening_publication_id
       or not exists(select 1 from public.mission_run_publications p
         where p.id=q.opening_publication_id and p.event_id=q.start_event_id
           and p.master_session_id=q.session_id and p.status='committed')
       or not exists(select 1 from public.mission_run_messages msg
         where msg.publication_id=q.opening_publication_id)
       or m.stato<>'in_corso' or m.closed_at is not null or m.control_version<2
       or r.run_phase<>'in_corso' or r.plan_version_id is distinct from q.plan_version_id
       or r.control_version<1 or r.last_event_id is null
       or c.state is distinct from 'active' or c.expected_control_version<2
       or c.expected_control_version>m.control_version
       or c.quest_source_session_id is distinct from q.session_id
    then st:='uncertain'; else st:='started'; end if;
    end if;
  elsif q.state='terminal' then
    receipt:=mission_factory_owner.quest_terminal_confirmed_v1(q.session_id);
    if receipt is not null and
       (op<>'terminal' or
        (terminal_event.id is not null and
         receipt->>'request_key'=p_request::text))
    then st:='terminal'; else st:='uncertain'; receipt:=null; end if;
  end if;
  return jsonb_build_object('schema_version','quest-episode-run-state/1',
    'request_key',p_request,'operation',op,'state',st,'receipt',receipt,
    'run_control_version',r.control_version,
    'opening_publication_id',case when st in ('started','closing_pending','terminal')
      then q.opening_publication_id else null end);
end; $function$
;
CREATE OR REPLACE FUNCTION mission_factory_owner.c444_runtime_ports_complete_assert_v1()
 RETURNS void
 LANGUAGE plpgsql
 STABLE SECURITY DEFINER
 SET search_path TO ''
AS $function$BEGIN
IF EXISTS(SELECT 1 FROM jsonb_array_elements($c501_pins$[{"all_arg_types":[],"arg_modes":[],"arg_names":null,"body_md5":"3a3cefd9b1fca302f640733d13ca06ed","configuration":["search_path=\"\""],"default_arg_count":0,"execute":["postgres"],"input_arg_types":[],"language":"plpgsql","lookup_signature":"mission_factory_owner.c408_stage1_complete_assert_v1()","oid":"279179","owner":"postgres","parallel":"u","return_type":"pg_catalog.void","returns_set":false,"security_definer":true,"strict":false,"variadic_type":null,"volatility":"s"}]$c501_pins$::jsonb) c501_expected LEFT JOIN pg_catalog.pg_proc c501_proc ON c501_proc.oid=pg_catalog.to_regprocedure(c501_expected->>'lookup_signature') WHERE c501_proc.oid IS NULL OR (c501_expected->>'oid' IS NOT NULL AND c501_proc.oid::text IS DISTINCT FROM c501_expected->>'oid') OR md5(c501_proc.prosrc) IS DISTINCT FROM c501_expected->>'body_md5' OR c501_proc.proargtypes::text IS DISTINCT FROM coalesce((SELECT string_agg(pg_catalog.to_regtype(c501_argtype)::oid::text,' ' ORDER BY c501_ord)FROM jsonb_array_elements_text(c501_expected->'input_arg_types')WITH ORDINALITY c501_inputs(c501_argtype,c501_ord)),'') OR coalesce((SELECT jsonb_agg(pg_catalog.format('%I.%I',c501_ns.nspname,c501_type.typname) ORDER BY c501_ord)FROM unnest(coalesce(c501_proc.proallargtypes,c501_proc.proargtypes::oid[]))WITH ORDINALITY c501_all(c501_type_oid,c501_ord)JOIN pg_catalog.pg_type c501_type ON c501_type.oid=c501_type_oid JOIN pg_catalog.pg_namespace c501_ns ON c501_ns.oid=c501_type.typnamespace),'[]'::jsonb) IS DISTINCT FROM c501_expected->'all_arg_types' OR to_jsonb(coalesce(c501_proc.proargmodes,array_fill('i'::"char",ARRAY[c501_proc.pronargs]))) IS DISTINCT FROM c501_expected->'arg_modes' OR coalesce(to_jsonb(c501_proc.proargnames),'null'::jsonb) IS DISTINCT FROM c501_expected->'arg_names' OR c501_proc.prorettype IS DISTINCT FROM pg_catalog.to_regtype(c501_expected->>'return_type') OR c501_proc.proretset IS DISTINCT FROM(c501_expected->>'returns_set')::boolean OR c501_proc.pronargdefaults IS DISTINCT FROM(c501_expected->>'default_arg_count')::integer OR (c501_proc.pronargdefaults=0 AND c501_proc.proargdefaults IS NOT NULL) OR c501_proc.provariadic IS DISTINCT FROM coalesce(pg_catalog.to_regtype(c501_expected->>'variadic_type')::oid,0::oid) OR c501_proc.proisstrict IS DISTINCT FROM(c501_expected->>'strict')::boolean OR c501_proc.provolatile::text IS DISTINCT FROM c501_expected->>'volatility' OR c501_proc.proparallel::text IS DISTINCT FROM c501_expected->>'parallel' OR c501_proc.prosecdef IS DISTINCT FROM(c501_expected->>'security_definer')::boolean OR(SELECT lanname FROM pg_catalog.pg_language WHERE oid=c501_proc.prolang)IS DISTINCT FROM c501_expected->>'language' OR to_jsonb(c501_proc.proconfig) IS DISTINCT FROM c501_expected->'configuration' OR pg_catalog.pg_get_userbyid(c501_proc.proowner)IS DISTINCT FROM c501_expected->>'owner' OR c501_proc.proleakproof OR coalesce((SELECT jsonb_agg(CASE WHEN c501_acl.grantee=0 THEN 'PUBLIC' ELSE pg_catalog.pg_get_userbyid(c501_acl.grantee)END ORDER BY CASE WHEN c501_acl.grantee=0 THEN 'PUBLIC' ELSE pg_catalog.pg_get_userbyid(c501_acl.grantee)END)FROM pg_catalog.aclexplode(coalesce(c501_proc.proacl,pg_catalog.acldefault('f',c501_proc.proowner)))c501_acl WHERE c501_acl.privilege_type='EXECUTE'),'[]'::jsonb)IS DISTINCT FROM c501_expected->'execute' OR EXISTS(SELECT 1 FROM pg_catalog.aclexplode(coalesce(c501_proc.proacl,pg_catalog.acldefault('f',c501_proc.proowner)))c501_acl WHERE c501_acl.is_grantable))THEN RAISE EXCEPTION 'C501_CURRENT_HUMAN_QUALIFIER_ABI_CAS' USING ERRCODE='40001';END IF;
PERFORM mission_factory_owner.c408_stage1_complete_assert_v1();
IF NOT EXISTS(SELECT 1 FROM mission_factory_owner.c444_install_progress WHERE singleton AND complete AND next_unit=26 AND source_input_sha256='9c814c08fba12afbdec246b477a73c0047d318b51dc7c83a23050bd9da9e0aa9')THEN RAISE EXCEPTION 'C501_SOURCE_FAMILY_COMPLETE_PREFIX_REQUIRED';END IF;
IF EXISTS(SELECT 1 FROM jsonb_array_elements((SELECT jsonb_agg('{"configuration":["search_path=\"\""],"default_arg_count":0,"owner":"postgres","parallel":"u","returns_set":false,"security_definer":true,"strict":false,"variadic_type":null}'::jsonb||p)FROM jsonb_array_elements('[{"all_arg_types":[],"arg_modes":[],"arg_names":null,"body_md5":"75fcad93b0da5fee0fc6b7af652a5e85","execute":["postgres"],"input_arg_types":[],"language":"sql","lookup_signature":"mission_factory_owner.c444_enabled_v1()","oid":null,"return_type":"pg_catalog.bool","volatility":"s"},{"all_arg_types":["pg_catalog.uuid"],"arg_modes":["i"],"arg_names":["p_session"],"body_md5":"0a7fa43e594605d397504828f1961f55","execute":["postgres"],"input_arg_types":["pg_catalog.uuid"],"language":"plpgsql","lookup_signature":"mission_factory_owner.c444_read_identity_v1(pg_catalog.uuid)","oid":null,"return_type":"pg_catalog.jsonb","volatility":"s"},{"all_arg_types":["pg_catalog.uuid"],"arg_modes":["i"],"arg_names":["p_session"],"body_md5":"a2f72b56b71b3a8ea089aff06a66e7ae","execute":["postgres"],"input_arg_types":["pg_catalog.uuid"],"language":"plpgsql","lookup_signature":"mission_factory_owner.c444_source_read_assert_v1(pg_catalog.uuid)","oid":null,"return_type":"pg_catalog.jsonb","volatility":"v"},{"all_arg_types":["pg_catalog.uuid"],"arg_modes":["i"],"arg_names":["p_episode"],"body_md5":"3ea3a2a0749910a979216b801a09bb2e","execute":["postgres"],"input_arg_types":["pg_catalog.uuid"],"language":"plpgsql","lookup_signature":"mission_factory_owner.c444_episode_read_assert_v1(pg_catalog.uuid)","oid":null,"return_type":"pg_catalog.void","volatility":"s"},{"all_arg_types":["pg_catalog.uuid"],"arg_modes":["i"],"arg_names":["p_episode"],"body_md5":"5d1943abf0a90cd395165756207e934e","execute":["postgres"],"input_arg_types":["pg_catalog.uuid"],"language":"plpgsql","lookup_signature":"mission_factory_owner.c444_enrollment_open_v1(pg_catalog.uuid)","oid":null,"return_type":"pg_catalog.bool","volatility":"v"},{"all_arg_types":["pg_catalog.uuid","pg_catalog.text","pg_catalog.bool","pg_catalog.int8","pg_catalog.uuid"],"arg_modes":["i","i","i","i","i"],"arg_names":["p_episode","p_operation","p_ready","p_expected_version","p_request"],"body_md5":"1bad66b63bff109cf4e65d14be59722f","execute":["postgres"],"input_arg_types":["pg_catalog.uuid","pg_catalog.text","pg_catalog.bool","pg_catalog.int8","pg_catalog.uuid"],"language":"plpgsql","lookup_signature":"mission_factory_owner.c444_enrollment_v1(pg_catalog.uuid,pg_catalog.text,pg_catalog.bool,pg_catalog.int8,pg_catalog.uuid)","oid":null,"return_type":"pg_catalog.jsonb","volatility":"v"},{"all_arg_types":["pg_catalog.uuid","pg_catalog.text","pg_catalog.bool","pg_catalog.int8","pg_catalog.uuid"],"arg_modes":["i","i","i","i","i"],"arg_names":["p_episode","p_operation","p_ready","p_expected_version","p_request"],"body_md5":"555a2c26cd901ba41d34c5365aa89755","execute":["authenticated","postgres"],"input_arg_types":["pg_catalog.uuid","pg_catalog.text","pg_catalog.bool","pg_catalog.int8","pg_catalog.uuid"],"language":"plpgsql","lookup_signature":"public.mission_factory_quest_enrollment_v1(pg_catalog.uuid,pg_catalog.text,pg_catalog.bool,pg_catalog.int8,pg_catalog.uuid)","oid":"276409","return_type":"pg_catalog.jsonb","volatility":"v"},{"all_arg_types":["pg_catalog.uuid"],"arg_modes":["i"],"arg_names":["p_session"],"body_md5":"85a879af8a80d50593fcb3970869249f","execute":["postgres"],"input_arg_types":["pg_catalog.uuid"],"language":"plpgsql","lookup_signature":"mission_factory_owner.c444_terminal_confirmed_v1(pg_catalog.uuid)","oid":null,"return_type":"pg_catalog.jsonb","volatility":"v"},{"all_arg_types":["pg_catalog.uuid"],"arg_modes":["i"],"arg_names":["p_session"],"body_md5":"1c6a6240f27b3add37546175768633a2","execute":["postgres"],"input_arg_types":["pg_catalog.uuid"],"language":"plpgsql","lookup_signature":"mission_factory_owner.quest_terminal_confirmed_v1(pg_catalog.uuid)","oid":"276431","return_type":"pg_catalog.jsonb","volatility":"v"},{"all_arg_types":["pg_catalog.uuid"],"arg_modes":["i"],"arg_names":["p_episode"],"body_md5":"5fa62eda7260904e189b55b06088254b","execute":["postgres"],"input_arg_types":["pg_catalog.uuid"],"language":"plpgsql","lookup_signature":"mission_factory_owner.c444_participant_state_v1(pg_catalog.uuid)","oid":null,"return_type":"pg_catalog.jsonb","volatility":"v"},{"all_arg_types":["pg_catalog.uuid"],"arg_modes":["i"],"arg_names":["p_episode"],"body_md5":"2169f3ddfbae60cf757cd2c555a9e2f7","execute":["authenticated","postgres"],"input_arg_types":["pg_catalog.uuid"],"language":"plpgsql","lookup_signature":"public.mission_factory_quest_participant_state_v1(pg_catalog.uuid)","oid":"276446","return_type":"pg_catalog.jsonb","volatility":"v"},{"all_arg_types":["pg_catalog.uuid"],"arg_modes":["i"],"arg_names":["p_request"],"body_md5":"d06ad7832dd3bc64fc0d0472d9965534","execute":["postgres"],"input_arg_types":["pg_catalog.uuid"],"language":"plpgsql","lookup_signature":"mission_factory_owner.c444_run_state_v1(pg_catalog.uuid)","oid":null,"return_type":"pg_catalog.jsonb","volatility":"v"},{"all_arg_types":["pg_catalog.uuid"],"arg_modes":["i"],"arg_names":["p_request"],"body_md5":"17a33bc8b9d5bdd4468aa582002cb7fa","execute":["authenticated","postgres"],"input_arg_types":["pg_catalog.uuid"],"language":"plpgsql","lookup_signature":"public.mission_factory_quest_run_state_v1(pg_catalog.uuid)","oid":"276432","return_type":"pg_catalog.jsonb","volatility":"v"},{"all_arg_types":["pg_catalog.uuid"],"arg_modes":["i"],"arg_names":["p_session"],"body_md5":"8d2d40aa16abbf40ea7801ae4ec49774","execute":["postgres"],"input_arg_types":["pg_catalog.uuid"],"language":"plpgsql","lookup_signature":"mission_factory_owner.c444_action_scope_v1(pg_catalog.uuid)","oid":null,"return_type":"pg_catalog.jsonb","volatility":"v"},{"all_arg_types":["pg_catalog.uuid"],"arg_modes":["i"],"arg_names":["p_session"],"body_md5":"7e7da01987e744d27f634cd93c4cd273","execute":["authenticated","postgres"],"input_arg_types":["pg_catalog.uuid"],"language":"plpgsql","lookup_signature":"public.mission_factory_quest_human_runtime_state_v1(pg_catalog.uuid)","oid":null,"return_type":"pg_catalog.jsonb","volatility":"v"},{"all_arg_types":["pg_catalog.uuid"],"arg_modes":["i"],"arg_names":["p_session"],"body_md5":"0bda32f1607eb10808df90b042f5473a","execute":["authenticated","postgres"],"input_arg_types":["pg_catalog.uuid"],"language":"plpgsql","lookup_signature":"public.mission_human_phase_state_v1(pg_catalog.uuid)","oid":"50702","return_type":"pg_catalog.jsonb","volatility":"s"}]'::jsonb)z(p))) c501_expected LEFT JOIN pg_catalog.pg_proc c501_proc ON c501_proc.oid=pg_catalog.to_regprocedure(c501_expected->>'lookup_signature') WHERE c501_proc.oid IS NULL OR (c501_expected->>'oid' IS NOT NULL AND c501_proc.oid::text IS DISTINCT FROM c501_expected->>'oid') OR md5(c501_proc.prosrc) IS DISTINCT FROM c501_expected->>'body_md5' OR c501_proc.proargtypes::text IS DISTINCT FROM coalesce((SELECT string_agg(pg_catalog.to_regtype(c501_argtype)::oid::text,' ' ORDER BY c501_ord)FROM jsonb_array_elements_text(c501_expected->'input_arg_types')WITH ORDINALITY c501_inputs(c501_argtype,c501_ord)),'') OR coalesce((SELECT jsonb_agg(pg_catalog.format('%I.%I',c501_ns.nspname,c501_type.typname) ORDER BY c501_ord)FROM unnest(coalesce(c501_proc.proallargtypes,c501_proc.proargtypes::oid[]))WITH ORDINALITY c501_all(c501_type_oid,c501_ord)JOIN pg_catalog.pg_type c501_type ON c501_type.oid=c501_type_oid JOIN pg_catalog.pg_namespace c501_ns ON c501_ns.oid=c501_type.typnamespace),'[]'::jsonb) IS DISTINCT FROM c501_expected->'all_arg_types' OR to_jsonb(coalesce(c501_proc.proargmodes,array_fill('i'::"char",ARRAY[c501_proc.pronargs]))) IS DISTINCT FROM c501_expected->'arg_modes' OR coalesce(to_jsonb(c501_proc.proargnames),'null'::jsonb) IS DISTINCT FROM c501_expected->'arg_names' OR c501_proc.prorettype IS DISTINCT FROM pg_catalog.to_regtype(c501_expected->>'return_type') OR c501_proc.proretset IS DISTINCT FROM(c501_expected->>'returns_set')::boolean OR c501_proc.pronargdefaults IS DISTINCT FROM(c501_expected->>'default_arg_count')::integer OR (c501_proc.pronargdefaults=0 AND c501_proc.proargdefaults IS NOT NULL) OR c501_proc.provariadic IS DISTINCT FROM coalesce(pg_catalog.to_regtype(c501_expected->>'variadic_type')::oid,0::oid) OR c501_proc.proisstrict IS DISTINCT FROM(c501_expected->>'strict')::boolean OR c501_proc.provolatile::text IS DISTINCT FROM c501_expected->>'volatility' OR c501_proc.proparallel::text IS DISTINCT FROM c501_expected->>'parallel' OR c501_proc.prosecdef IS DISTINCT FROM(c501_expected->>'security_definer')::boolean OR(SELECT lanname FROM pg_catalog.pg_language WHERE oid=c501_proc.prolang)IS DISTINCT FROM c501_expected->>'language' OR to_jsonb(c501_proc.proconfig) IS DISTINCT FROM c501_expected->'configuration' OR pg_catalog.pg_get_userbyid(c501_proc.proowner)IS DISTINCT FROM c501_expected->>'owner' OR c501_proc.proleakproof OR coalesce((SELECT jsonb_agg(CASE WHEN c501_acl.grantee=0 THEN 'PUBLIC' ELSE pg_catalog.pg_get_userbyid(c501_acl.grantee)END ORDER BY CASE WHEN c501_acl.grantee=0 THEN 'PUBLIC' ELSE pg_catalog.pg_get_userbyid(c501_acl.grantee)END)FROM pg_catalog.aclexplode(coalesce(c501_proc.proacl,pg_catalog.acldefault('f',c501_proc.proowner)))c501_acl WHERE c501_acl.privilege_type='EXECUTE'),'[]'::jsonb)IS DISTINCT FROM c501_expected->'execute' OR EXISTS(SELECT 1 FROM pg_catalog.aclexplode(coalesce(c501_proc.proacl,pg_catalog.acldefault('f',c501_proc.proowner)))c501_acl WHERE c501_acl.is_grantable))THEN RAISE EXCEPTION 'C501_PORTS_EFFECTIVE_FULL_ABI_ACL_CAS' USING ERRCODE='40001';END IF;
END$function$
;
DO $post$ BEGIN PERFORM mission_factory_owner.c444_runtime_ports_complete_assert_v1();PERFORM mission_factory_owner.c463_optin_complete_assert_v1();END $post$;COMMIT;
