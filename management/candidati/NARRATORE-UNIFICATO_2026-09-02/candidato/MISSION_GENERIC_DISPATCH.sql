-- MISSION-GENERIC-DISPATCH/1; candidate, no apply. Requires MISSION_GENERIC_DB.sql.
-- New work items use native mission accounting, never the legacy phase publisher.
begin;

alter table mission_narrative_internal.dispatch_receipts drop constraint dispatch_receipts_event_kind_check;
alter table mission_narrative_internal.dispatch_receipts add constraint dispatch_receipts_event_kind_check check
 (event_kind in('combat_round_complete','combat_terminal','briefing_miyo','lettura_ambiente','raccolta_tracce',
 'transizione_inseguimento','incontro_refurtiva','scontro_2v2','recupero','chiusura_miyo','mission_opening_preview','mission_generic_event'));
alter table mission_narrative_internal.dispatch_receipts drop constraint dispatch_receipts_renderer_version_check;
alter table mission_narrative_internal.dispatch_receipts add constraint dispatch_receipts_renderer_version_check check
 (renderer_version in('mission-surface-renderer/2.0','mission-generic-runtime/1'));
alter table mission_narrative_internal.dispatch_receipts add constraint dispatch_receipts_generic_pair_check check
 ((event_kind='mission_generic_event')=(renderer_version='mission-generic-runtime/1'));

create table mission_generic_owner.dispatch_admissions (
 master_session_id uuid primary key references mission_generic_owner.run_bindings(master_session_id),
 enabled boolean not null default false,
 call_limit integer not null check(call_limit>0),
 cost_budget_usd numeric not null check(cost_budget_usd>0),
 calls_authorized integer not null default 0 check(calls_authorized>=0),
 admitted_at timestamptz not null default clock_timestamp(),
 check(calls_authorized<=call_limit)
);
create table mission_generic_owner.work_items (
 id uuid primary key default gen_random_uuid(),
 master_session_id uuid not null references mission_generic_owner.run_bindings(master_session_id),
 event_id uuid not null default gen_random_uuid(),
 request_key uuid not null default gen_random_uuid(),
 dedupe_key text not null,
 step_key text not null,
 run_control_version bigint not null check(run_control_version>0),
 definition_sha256 text not null check(definition_sha256~'^[0-9a-f]{64}$'),
 encounter_id uuid,
 authority_receipt_id uuid not null,
 kind text not null check(kind in('choice','narration')),
 revision bigint not null check(revision>0),
 payload jsonb not null check(jsonb_typeof(payload)='object'),
 payload_sha256 text not null check(payload_sha256~'^[0-9a-f]{64}$'),
 state text not null default 'ready' check(state in('ready','claimed','authorized','provider_started','completed','failed','uncertain')),
 lease_id uuid,
 lease_expires_at timestamptz,
 dispatch_receipt_id uuid unique references mission_narrative_internal.dispatch_receipts(id),
 authorization_id uuid unique references mission_narrative_internal.provider_authorizations(id),
 dispatch_id uuid unique,
 result jsonb,
 result_sha256 text check(result_sha256~'^[0-9a-f]{64}$'),
 receipt_id uuid unique,
 message_id uuid unique references public.messages(id),
 created_at timestamptz not null default clock_timestamp(),
 finalized_at timestamptz,
 unique(master_session_id,event_id),unique(master_session_id,request_key),unique(master_session_id,dedupe_key),
 check((state in('completed','failed','uncertain'))=(finalized_at is not null))
);
alter table mission_generic_owner.dispatch_admissions enable row level security;
alter table mission_generic_owner.work_items enable row level security;
revoke all on mission_generic_owner.dispatch_admissions,mission_generic_owner.work_items from public,anon,authenticated,service_role;

create function mission_generic_owner.dispatch_user(p_session uuid,p_user uuid)
returns void language plpgsql security definer set search_path='' as $fn$
begin
 perform mission_ai_board_owner.service_only();
 if p_user is null or not exists(select 1 from public.master_v2_sessions s
  where s.id=p_session and s.owner_kind='ai_service' and s.mission_id is not null
  and (exists(select 1 from public.profiles p where p.id=p_user and p.role in('admin','master'))
   or exists(select 1 from public.master_v2_participants mp join public.characters c on c.id=mp.character_id and c.user_id=p_user
    where mp.session_id=s.id and mp.user_id_snapshot=p_user and mp.left_at is null)))
 then raise exception 'MGD_USER_SCOPE' using errcode='42501';end if;
end;
$fn$;

-- Private explicit admission, called by the reviewed setup/release, never a player.
create function mission_generic_owner.dispatch_admit(p_session uuid,p_calls integer,p_cost numeric)
returns void language plpgsql security definer set search_path='' as $fn$
declare a mission_generic_owner.dispatch_admissions;
begin
 perform mission_generic_owner.assert_runtime(p_session);
 if p_calls is null or p_calls<1 or p_cost is null or p_cost<=0 then raise exception 'MGD_BUDGET_REQUIRED';end if;
 select * into a from mission_generic_owner.dispatch_admissions where master_session_id=p_session for update;
 if found then
  if a.call_limit<>p_calls or a.cost_budget_usd<>p_cost then raise exception 'MGD_ADMISSION_CONFLICT' using errcode='40001';end if;
  return;
 end if;
 insert into mission_generic_owner.dispatch_admissions(master_session_id,enabled,call_limit,cost_budget_usd)
 values(p_session,true,p_calls,p_cost);
end;
$fn$;

create function mission_generic_owner.work_status(w mission_generic_owner.work_items)
returns jsonb language sql stable set search_path='' as $fn$
select jsonb_build_object('schema_version','mission-generic-status/1','work_id',w.id,'master_session_id',w.master_session_id,
 'event_id',w.event_id,'request_key',w.request_key,'revision',w.revision,'state',w.state,
 'receipt_id',w.receipt_id,'result_sha256',w.result_sha256)
$fn$;

create function mission_generic_owner.work_assert(w mission_generic_owner.work_items)
returns void language plpgsql security definer set search_path='' as $fn$
declare r public.mission_run_state;b mission_generic_owner.run_bindings;m public.master_v2_sessions;
begin
 perform mission_generic_owner.assert_runtime(w.master_session_id);
 select * into strict m from public.master_v2_sessions where id=w.master_session_id for share;
 select * into strict r from public.mission_run_state where master_session_id=w.master_session_id for share;
 select * into strict b from mission_generic_owner.run_bindings where master_session_id=w.master_session_id;
 if m.owner_kind<>'ai_service' or m.closed_at is not null
 or (w.payload ? 'opening_start_receipt_id' and (m.stato<>'preparazione' or r.run_phase<>'preparazione'
  or not exists(select 1 from mission_generic_owner.board_starts bs where bs.id=(w.payload->>'opening_start_receipt_id')::uuid
   and bs.master_session_id=w.master_session_id and bs.state='prepared')))
 or (not(w.payload ? 'opening_start_receipt_id') and m.stato<>'in_corso')
 or r.current_step_key<>w.step_key or r.control_version<>w.run_control_version
 or b.snapshot_sha256<>w.definition_sha256 or b.snapshot_sha256<>mission_internal.fingerprint(b.snapshot)
 or w.payload_sha256<>public.combat_v2_sha256(w.payload)
 then raise exception 'MGD_WORK_STALE' using errcode='40001';end if;
end;
$fn$;

-- Private shared context producer: source facts are supplied only by the typed
-- opening/transition owner below. No RPC grants or arbitrary client JSON ingress.
create function mission_generic_owner.narrative_context(p_session uuid,p_step text,p_authority uuid,p_cutoff timestamptz,p_facts jsonb)
returns jsonb language plpgsql security definer set search_path='' as $fn$
declare r public.mission_run_state;b mission_generic_owner.run_bindings;m public.master_v2_sessions;
 sc jsonb;a jsonb;pin jsonb;nv public.nb_template_versions;nt public.nb_templates;
 actors jsonb:='[]';sources jsonb:='[]';ctx jsonb;loc text;from_at timestamptz;persona text;previous_fato jsonb;
begin
 select * into strict m from public.master_v2_sessions where id=p_session;
 select * into strict r from public.mission_run_state where master_session_id=p_session;
 select * into strict b from mission_generic_owner.run_bindings where master_session_id=p_session;
 sc:=mission_generic_owner.scene(p_session,p_step);
 select name into strict loc from public.locations where id=m.location_id;
 select coalesce(jsonb_agg(jsonb_build_object('id',p.character_id::text,'name',c.name,'kind','PG','persona',null,'may_speak',false) order by p.joined_at,p.character_id),'[]')
 into actors from public.master_v2_participants p join public.characters c on c.id=p.character_id where p.session_id=p_session and p.left_at is null;
 for a in select value from jsonb_array_elements(sc->'actors') loop
  if a->>'mechanical_binding_id' is not null then
   select x into strict pin from jsonb_array_elements(b.snapshot->'binding_pins') x where x->>'mechanical_binding_id'=a->>'mechanical_binding_id';
  else
   select x into strict pin from jsonb_array_elements(b.snapshot->'narrative_pins') x where x->>'narrative_version_id'=a->>'narrative_version_id';
  end if;
  select * into strict nv from public.nb_template_versions where id=(pin->>'narrative_version_id')::uuid
   and control_version=(pin->>'narrative_version_control_version')::bigint and content_sha256=pin->>'narrative_content_sha256' and review_state='approved';
  select * into strict nt from public.nb_templates where id=nv.template_id
   and control_version=(pin->>'narrative_template_control_version')::bigint and lifecycle_state='approved';
  -- Voice and gestures only: no memory, secrets, goals or knowledge_boundary.
  persona:=jsonb_build_object('nome',nt.display_name,'voce',nv.skeleton->'voice','gesti',nv.skeleton->'gestures')::text;
  actors:=actors||jsonb_build_array(jsonb_build_object('id','png:'||(a->>'actor_key'),'name',nt.display_name,'kind','PNG','persona',persona,'may_speak',true));
 end loop;
 select coalesce(max(x.finalized_at),m.created_at) into from_at from mission_generic_owner.work_items x
 where x.master_session_id=p_session and x.kind='narration' and x.state='completed';
 select coalesce(jsonb_agg(jsonb_build_object('id',msg.id::text,'master_session_id',p_session,'kind','role','actor_id',msg.character_id::text,
  'sequence',q.seq,'body',msg.body,'sha256',encode(extensions.digest(convert_to(msg.body,'UTF8'),'sha256'),'hex'),
  'visibility','public','complete',true) order by q.seq),'[]') into sources
 from (select z.id,row_number() over(order by z.created_at,z.id)::bigint seq from public.messages z
  where z.location_id=m.location_id and z.kind='say' and z.recipient_user is null and z.created_at>from_at and z.created_at<=p_cutoff
  and exists(select 1 from public.master_v2_participants mp where mp.session_id=p_session and mp.character_id=z.character_id
   and mp.user_id_snapshot=z.sender_user and mp.joined_at<=z.created_at and (mp.left_at is null or mp.left_at>z.created_at))) q
 join public.messages msg on msg.id=q.id;
 select jsonb_build_object('id',msg.id::text,'master_session_id',p_session,'kind','fato','actor_id',null,'sequence',0,
  'body',msg.body,'sha256',encode(extensions.digest(convert_to(msg.body,'UTF8'),'sha256'),'hex'),'visibility','public','complete',true)
 into previous_fato from mission_generic_owner.work_items x join public.messages msg on msg.id=x.message_id
 where x.master_session_id=p_session and x.kind='narration' and x.state='completed'
 order by x.finalized_at desc,x.id desc limit 1;
 if previous_fato is not null then sources:=jsonb_build_array(previous_fato)||sources;end if;
 ctx:=jsonb_build_object('schema_version','mission-narrative-context/1','master_session_id',p_session,'step_key',p_step,
  'run_control_version',r.control_version,'definition_sha256',b.snapshot_sha256,'authority_receipt_id',p_authority,
  'location',loc,'actors',actors,'sources',sources,'resolved_facts',p_facts);
 return ctx;
end;
$fn$;

-- A genuine Board bind/opening event, with no artificial player choice or round.
create function mission_generic_owner.enqueue_opening(p_session uuid,p_start uuid)
returns jsonb language plpgsql security definer set search_path='' as $fn$
declare s mission_generic_owner.board_starts;m public.master_v2_sessions;r public.mission_run_state;
 b mission_generic_owner.run_bindings;e public.mission_run_events;ob public.mission_run_outbox;
 w mission_generic_owner.work_items;obj text;ctx jsonb;payload jsonb;briefing text;title text;
begin
 select * into strict m from public.master_v2_sessions where id=p_session for update;
 perform mission_generic_owner.assert_runtime(p_session);
 select * into strict s from mission_generic_owner.board_starts where id=p_start and master_session_id=p_session;
 select * into w from mission_generic_owner.work_items where master_session_id=p_session and dedupe_key='opening:'||s.id;
 if found then return mission_generic_owner.work_status(w);end if;
 select * into strict r from public.mission_run_state where master_session_id=p_session;
 select * into strict b from mission_generic_owner.run_bindings where master_session_id=p_session;
 select * into strict e from public.mission_run_events where id=s.event_id and master_session_id=p_session;
 select * into strict ob from public.mission_run_outbox where event_id=e.id and master_session_id=p_session;
 if s.state<>'prepared' or s.snapshot_sha256<>mission_internal.fingerprint(s.snapshot)
 or m.stato<>'preparazione' or m.closed_at is not null or r.run_phase<>'preparazione'
 or e.operation_kind<>'bind' or e.status<>'committed' or e.version_after<>r.control_version
 or r.control_version<>1 or e.step_after<>r.current_step_key or ob.state<>'pending'
 or ob.event_version_after<>e.version_after or ob.step_key<>e.step_after or ob.context_fingerprint<>e.context_fingerprint
 or not exists(select 1 from public.master_v2_participants mp where mp.session_id=p_session and mp.left_at is null)
 then raise exception 'MGD_OPENING_SOURCE_INVALID';end if;
 select public_objective into strict obj from public.mission_plan_steps where plan_version_id=r.plan_version_id and step_key=r.current_step_key;
 select mi.title,mi.briefing into strict title,briefing from public.missions mi where mi.id=m.mission_id;
 ctx:=mission_generic_owner.narrative_context(p_session,r.current_step_key,s.id,s.created_at,
  jsonb_build_object('missione',title,'incarico',briefing,'obiettivo_iniziale',obj,
  'nota_autorita','È l’apertura della missione. L’incarico non è completato; parole, azioni e decisioni dei PG restano ai giocatori.'));
 payload:=jsonb_build_object('schema_version','mission-generic-narration/1','mode','mission','opening_start_receipt_id',s.id,
  'barrier',jsonb_build_object('closed',true,'required_receipt_ids',jsonb_build_array(s.id,e.id),'receipt_ids',jsonb_build_array(s.id,e.id)),
  'context',ctx);
 insert into mission_generic_owner.work_items(master_session_id,event_id,dedupe_key,step_key,run_control_version,definition_sha256,
  authority_receipt_id,kind,revision,payload,payload_sha256)
 values(p_session,s.id,'opening:'||s.id,r.current_step_key,r.control_version,b.snapshot_sha256,s.id,'narration',r.control_version,
  payload,public.combat_v2_sha256(payload)) returning * into w;
 return mission_generic_owner.work_status(w);
end;
$fn$;

-- A trigger receipt already committed by the native controller is the only source
-- of this narrative event. No JSON, persona, role or evidence arrives from a client.
create function mission_generic_owner.enqueue_transition(p_session uuid,p_receipt uuid)
returns jsonb language plpgsql security definer set search_path='' as $fn$
declare tr mission_generic_owner.trigger_receipts;e public.mission_run_events;r public.mission_run_state;
 b mission_generic_owner.run_bindings;m public.master_v2_sessions;sc jsonb;a jsonb;pin jsonb;nv public.nb_template_versions;nt public.nb_templates;
 actors jsonb:='[]';sources jsonb:='[]';ctx jsonb;payload jsonb;w mission_generic_owner.work_items;
 loc text;obj text;before_obj text;from_at timestamptz;rid uuid;name text;persona text;trigger_label text;previous_fato jsonb;
begin
 select * into strict m from public.master_v2_sessions where id=p_session for update;
 perform mission_generic_owner.assert_runtime(p_session);
 select * into strict tr from mission_generic_owner.trigger_receipts where id=p_receipt and master_session_id=p_session;
 select * into strict e from public.mission_run_events where id=(tr.result->>'event_id')::uuid and master_session_id=p_session and status='committed';
 select * into strict r from public.mission_run_state where master_session_id=p_session for share;
 select * into strict b from mission_generic_owner.run_bindings where master_session_id=p_session;
 select * into w from mission_generic_owner.work_items where master_session_id=p_session and dedupe_key='transition:'||tr.id;
 if found then return mission_generic_owner.work_status(w);end if;
 if e.step_after<>r.current_step_key or e.version_after<>r.control_version or e.version_before<>tr.run_control_version
 or e.step_before<>tr.step_key or tr.result->>'authority_receipt_id'<>tr.id::text then raise exception 'MGD_TRANSITION_STALE' using errcode='40001';end if;
 select public_objective into strict obj from public.mission_plan_steps where plan_version_id=r.plan_version_id and step_key=e.step_after;
 select public_objective into strict before_obj from public.mission_plan_steps where plan_version_id=r.plan_version_id and step_key=e.step_before;
 select x->>'label' into strict trigger_label from jsonb_array_elements(mission_generic_owner.scene(p_session,e.step_before)->'triggers') x
 where x->>'trigger_key'=tr.trigger_key;
 ctx:=mission_generic_owner.narrative_context(p_session,e.step_after,tr.id,tr.issued_at,jsonb_build_object(
  'obiettivo_precedente',before_obj,'obiettivo_corrente',obj,'passaggio_autorizzato',trigger_label,
  'nota_autorita','La transizione autorizza il nuovo obiettivo; non attesta il suo completamento né esiti meccanici ulteriori.'));
 payload:=jsonb_build_object('schema_version','mission-generic-narration/1','mode','mission','barrier',
  jsonb_build_object('closed',true,'required_receipt_ids',jsonb_build_array(tr.id,e.id),'receipt_ids',jsonb_build_array(tr.id,e.id)),'context',ctx);
 insert into mission_generic_owner.work_items(master_session_id,event_id,dedupe_key,step_key,run_control_version,definition_sha256,
  authority_receipt_id,kind,revision,payload,payload_sha256)
 values(p_session,tr.id,'transition:'||tr.id,e.step_after,r.control_version,b.snapshot_sha256,tr.id,'narration',r.control_version,payload,public.combat_v2_sha256(payload)) returning * into w;
 return mission_generic_owner.work_status(w);
end;
$fn$;

-- The committed trigger result is inserted after mission_internal.transition;
-- enqueue in the same transaction so no phase advances without a pending work item.
create function mission_generic_owner.trigger_dispatch_enqueue()
returns trigger language plpgsql security definer set search_path='' as $fn$
begin
 perform mission_generic_owner.enqueue_transition(new.master_session_id,new.id);
 return new;
end;
$fn$;
create trigger mission_generic_trigger_dispatch after insert on mission_generic_owner.trigger_receipts
for each row execute function mission_generic_owner.trigger_dispatch_enqueue();

-- Invoked only by the private, source-validating encounter owner. Choice options
-- are generated now from Common; the caller cannot submit a panel or a persona.
create function mission_generic_owner.enqueue_choice(p_session uuid,p_encounter uuid,p_actor uuid)
returns jsonb language plpgsql security definer set search_path='' as $fn$
declare r public.mission_run_state;b mission_generic_owner.run_bindings;w mission_generic_owner.work_items;
 o jsonb;payload jsonb;wid uuid:=gen_random_uuid();req uuid:=gen_random_uuid();key text;
begin
 perform 1 from public.master_v2_sessions where id=p_session for update;
 perform mission_generic_owner.assert_runtime(p_session);
 select * into strict r from public.mission_run_state where master_session_id=p_session;
 select * into strict b from mission_generic_owner.run_bindings where master_session_id=p_session;
 select * into w from mission_generic_owner.work_items where master_session_id=p_session and encounter_id=p_encounter
  and kind='choice' and payload->>'actor_id'=p_actor::text and state not in('completed','failed') order by created_at,id limit 1;
 if found then return mission_generic_owner.work_status(w);end if;
 o:=mission_generic_owner.choice_options(p_session,p_actor,wid,req);
 if o->>'actor_id' is distinct from p_actor::text or (o#>>'{legal_options,context,activity_id}') is null
 or jsonb_typeof(o->'persona') is distinct from 'object'
 or o->>'encounter_id' is distinct from p_encounter::text then raise exception 'MGD_CHOICE_SOURCE_INVALID';end if;
 key:='choice:'||p_encounter||':'||p_actor||':'||(o->>'context_version');
 select * into w from mission_generic_owner.work_items where master_session_id=p_session and dedupe_key=key;
 if found then return mission_generic_owner.work_status(w);end if;
 payload:=jsonb_build_object('schema_version','mission-generic-choice/1','actor_id',p_actor,'capability_id',o->'capability_id',
  'command_request_key',o->'request_key','persona',(o->'persona')::text,'authorized_context',coalesce(o->'authorized_context','{}'),
  'combat_session_id',o#>'{legal_options,context,activity_id}','round_id',o#>'{legal_options,context,round_id}',
  'context_version',o->'context_version','policy_id',o#>'{legal_options,context,policy_id}',
  'simulated',o#>'{legal_options,context,simulated}','legal_options',o->'legal_options');
 insert into mission_generic_owner.work_items(id,master_session_id,dedupe_key,step_key,run_control_version,definition_sha256,
  encounter_id,authority_receipt_id,kind,revision,payload,payload_sha256)
 values(wid,p_session,key,r.current_step_key,r.control_version,b.snapshot_sha256,p_encounter,(o->>'authority_receipt_id')::uuid,
  'choice',r.control_version,payload,public.combat_v2_sha256(payload)) returning * into w;
 return mission_generic_owner.work_status(w);
end;
$fn$;

-- The Combat owner hook must build the whole frozen scene AFTER required command
-- and resolver receipts exist. No scene JSON can be supplied through this function.
create function mission_generic_owner.enqueue_combat(p_session uuid,p_event uuid)
returns jsonb language plpgsql security definer set search_path='' as $fn$
declare s jsonb;r public.mission_run_state;b mission_generic_owner.run_bindings;w mission_generic_owner.work_items;
begin
 perform 1 from public.master_v2_sessions where id=p_session for update;
 perform mission_generic_owner.assert_runtime(p_session);
 select * into w from mission_generic_owner.work_items where master_session_id=p_session and dedupe_key='combat:'||p_event;
 if found then return mission_generic_owner.work_status(w);end if;
 s:=mission_generic_owner.combat_narrative_source(p_session,p_event);
 select * into strict r from public.mission_run_state where master_session_id=p_session;
 select * into strict b from mission_generic_owner.run_bindings where master_session_id=p_session;
 if s->>'master_session_id' is distinct from p_session::text or s->>'step_key' is distinct from r.current_step_key
 or (s->>'run_control_version')::bigint is distinct from r.control_version
 or s#>>'{payload,barrier,closed}' is distinct from 'true' or s#>>'{payload,mode}' is distinct from 'combat'
 then raise exception 'MGD_COMBAT_SOURCE_INVALID';end if;
 insert into mission_generic_owner.work_items(master_session_id,event_id,dedupe_key,step_key,run_control_version,definition_sha256,
  encounter_id,authority_receipt_id,kind,revision,payload,payload_sha256)
 values(p_session,p_event,'combat:'||p_event,r.current_step_key,r.control_version,b.snapshot_sha256,(s->>'encounter_id')::uuid,
  (s->>'authority_receipt_id')::uuid,'narration',r.control_version,s->'payload',public.combat_v2_sha256(s->'payload')) returning * into w;
 return mission_generic_owner.work_status(w);
end;
$fn$;

create function public.mission_generic_dispatch_next_v1(p_session uuid,p_user uuid)
returns jsonb language plpgsql security definer set search_path='' as $fn$
declare w mission_generic_owner.work_items;
begin
 perform mission_generic_owner.dispatch_user(p_session,p_user);
 select * into w from mission_generic_owner.work_items where master_session_id=p_session
 and state not in('completed','failed') order by created_at,id limit 1;
 if not found then return jsonb_build_object('state','idle');end if;
 return jsonb_build_object('state',w.state,'request',jsonb_build_object('schema_version','mission-generic-request/1',
 'master_session_id',w.master_session_id,'event_id',w.event_id,'request_key',w.request_key,'expected_revision',w.revision));
end;
$fn$;

create function public.mission_generic_dispatch_status_v1(p_user uuid,p_request jsonb)
returns jsonb language plpgsql security definer set search_path='' as $fn$
declare w mission_generic_owner.work_items;
begin
 perform mission_generic_owner.dispatch_user((p_request->>'master_session_id')::uuid,p_user);
 select * into strict w from mission_generic_owner.work_items where master_session_id=(p_request->>'master_session_id')::uuid
 and event_id=(p_request->>'event_id')::uuid and request_key=(p_request->>'request_key')::uuid and revision=(p_request->>'expected_revision')::bigint;
 return mission_generic_owner.work_status(w);
end;
$fn$;

create function public.mission_generic_dispatch_claim_v1(p_user uuid,p_request jsonb)
returns jsonb language plpgsql security definer set search_path='' as $fn$
declare w mission_generic_owner.work_items;a mission_generic_owner.dispatch_admissions;pol mission_narrative_internal.runtime_policy;
 dr uuid;env jsonb;fp text;limits jsonb;
begin
 perform mission_generic_owner.dispatch_user((p_request->>'master_session_id')::uuid,p_user);
 perform 1 from public.master_v2_sessions where id=(p_request->>'master_session_id')::uuid for update;
 select * into strict w from mission_generic_owner.work_items where master_session_id=(p_request->>'master_session_id')::uuid
 and event_id=(p_request->>'event_id')::uuid and request_key=(p_request->>'request_key')::uuid and revision=(p_request->>'expected_revision')::bigint for update;
 if w.state<>'ready' then return jsonb_build_object('state',w.state,'granted_now',false);end if;
 perform mission_generic_owner.work_assert(w);
 select * into strict a from mission_generic_owner.dispatch_admissions where master_session_id=w.master_session_id for share;
 select * into strict pol from mission_narrative_internal.runtime_policy where singleton for share;
 if not a.enabled or a.calls_authorized>=a.call_limit or not pol.enabled or pol.model<>'gpt-5.6-luna' or pol.reasoning_effort<>'high' or pol.store
 then raise exception 'MGD_PROVIDER_CLOSED';end if;
 limits:=jsonb_build_object('provider_calls_remaining',a.call_limit-a.calls_authorized,'max_output_tokens',least(9992,pol.max_output_tokens),
  'max_input_bytes',least(49152,pol.max_input_tokens),'max_request_bytes',least(65536,pol.max_input_tokens),
  'transport_max_chars',5000,'provider_timeout_ms',120000);
 if octet_length(w.payload::text)>(limits->>'max_input_bytes')::integer then raise exception 'MGD_CONTEXT_OVERFLOW';end if;
 env:=jsonb_build_object('work_id',w.id,'master_session_id',w.master_session_id,'event_id',w.event_id,'authority_receipt_id',w.authority_receipt_id,
  'payload_sha256',w.payload_sha256,'definition_sha256',w.definition_sha256,'revision',w.revision);
 fp:=mission_internal.fingerprint(p_request);
 insert into mission_narrative_internal.dispatch_receipts(master_session_id,authority_receipt_id,event_kind,renderer_version,request_key,
  request_fingerprint,authority_sha256,envelope,envelope_sha256,status)
 values(w.master_session_id,w.id,'mission_generic_event','mission-generic-runtime/1',w.request_key,fp,
  public.combat_v2_sha256(env),env,public.combat_v2_sha256(env),'claimed') returning id into dr;
 update mission_generic_owner.work_items set state='claimed',dispatch_receipt_id=dr,lease_id=gen_random_uuid(),
  lease_expires_at=clock_timestamp()+interval '180 seconds' where id=w.id returning * into w;
 return jsonb_build_object('state','claimed','granted_now',true,'work',jsonb_build_object('schema_version','mission-generic-work/1',
  'work_id',w.id,'master_session_id',w.master_session_id,'event_id',w.event_id,'request_key',w.request_key,'revision',w.revision,
  'step_key',w.step_key,'run_control_version',w.run_control_version,'definition_sha256',w.definition_sha256,
  'encounter_id',w.encounter_id,'authority_receipt_id',w.authority_receipt_id,'kind',w.kind,'lease_id',w.lease_id,
  'server_now',clock_timestamp(),'lease_expires_at',w.lease_expires_at,'payload_sha256',w.payload_sha256,'payload',w.payload,'limits',limits));
end;
$fn$;

-- A definite failure before any reservation/authorization is recorded separately
-- from provider finalization. Only the service with the claimed lease can close it.
create function public.mission_generic_dispatch_reject_v1(p_user uuid,p_request jsonb,p_lease uuid,p_code text)
returns jsonb language plpgsql security definer set search_path='' as $fn$
declare w mission_generic_owner.work_items;d mission_narrative_internal.dispatch_receipts;
 receipt uuid:=gen_random_uuid();failure_result jsonb;fp text;
begin
 perform mission_generic_owner.dispatch_user((p_request->>'master_session_id')::uuid,p_user);
 if p_code not in('work_validation_failed','request_validation_failed') or p_code is null or p_lease is null
 then raise exception 'MGD_REJECTION_INPUT';end if;
 perform 1 from public.master_v2_sessions where id=(p_request->>'master_session_id')::uuid for update;
 select * into strict w from mission_generic_owner.work_items where master_session_id=(p_request->>'master_session_id')::uuid
 and event_id=(p_request->>'event_id')::uuid and request_key=(p_request->>'request_key')::uuid
 and revision=(p_request->>'expected_revision')::bigint for update;
 if w.lease_id is distinct from p_lease then raise exception 'MGD_REJECTION_LEASE';end if;
 if w.state='failed' and w.result->>'schema_version'='mission-generic-pre-provider-failure/1' then
  if w.result->>'failure_code' is distinct from p_code then raise exception 'MGD_REJECTION_REPLAY_CONFLICT';end if;
  return mission_generic_owner.work_status(w);
 end if;
 select * into strict d from mission_narrative_internal.dispatch_receipts where id=w.dispatch_receipt_id for update;
 if w.state<>'claimed' or w.authorization_id is not null or w.dispatch_id is not null
 or d.status<>'claimed' or d.dispatch_count<>0 or d.master_session_id<>w.master_session_id
 or d.authority_receipt_id<>w.id or d.event_kind<>'mission_generic_event'
 or d.renderer_version<>'mission-generic-runtime/1' or d.request_key<>w.request_key
 or exists(select 1 from mission_narrative_internal.dispatch_attempts where receipt_id=d.id)
 or exists(select 1 from mission_narrative_internal.provider_authorizations where receipt_id=d.id)
 then raise exception 'MGD_REJECTION_NOT_PRE_PROVIDER';end if;
 failure_result:=jsonb_build_object('schema_version','mission-generic-pre-provider-failure/1','work_id',w.id,
 'master_session_id',w.master_session_id,'event_id',w.event_id,'request_key',w.request_key,'revision',w.revision,
 'ok',false,'failure_code',p_code,'provider_calls',0,'charged_cost_usd',0);
 fp:=public.combat_v2_sha256(failure_result);
 update mission_narrative_internal.dispatch_receipts set status='failed',charged_cost_usd=0,upper_bound_cost_usd=0,
 lease_token_sha256=null,lease_expires_at=null,finalized_at=clock_timestamp(),updated_at=clock_timestamp() where id=d.id;
 update mission_generic_owner.work_items set state='failed',result=failure_result,result_sha256=fp,receipt_id=receipt,
 finalized_at=clock_timestamp() where id=w.id returning * into w;
 insert into mission_narrative_internal.dispatch_audit(receipt_id,event_code,details)
 values(d.id,'generic_pre_provider_failed',jsonb_build_object('work_id',w.id,'receipt_id',receipt,'failure_code',p_code,
 'provider_calls',0,'charged_cost_usd',0,'result_sha256',fp));
 return mission_generic_owner.work_status(w);
end;
$fn$;

create function public.mission_generic_dispatch_authorize_v1(p_work uuid,p_lease uuid,p_worker_token text,p_policy jsonb)
returns jsonb language plpgsql security definer set search_path='' as $fn$
declare w mission_generic_owner.work_items;a mission_generic_owner.dispatch_admissions;pol mission_narrative_internal.runtime_policy;
 rr jsonb;z jsonb;spent numeric;ub numeric;
begin
 perform mission_ai_board_owner.service_only();
 perform 1 from public.master_v2_sessions where id=(select master_session_id from mission_generic_owner.work_items where id=p_work) for update;
 select * into strict w from mission_generic_owner.work_items where id=p_work for update;
 perform mission_generic_owner.work_assert(w);
 if w.state<>'claimed' or w.lease_id<>p_lease or w.lease_expires_at<=clock_timestamp()
 or p_policy->>'payload_sha256' is distinct from w.payload_sha256 then raise exception 'MGD_AUTHORIZE_STALE';end if;
 select * into strict a from mission_generic_owner.dispatch_admissions where master_session_id=w.master_session_id for update;
 select * into strict pol from mission_narrative_internal.runtime_policy where singleton;
 if not a.enabled or a.calls_authorized>=a.call_limit or p_policy->>'model' is distinct from pol.model
 or p_policy->>'reasoning_effort' is distinct from pol.reasoning_effort or p_policy->>'store' is distinct from 'false'
 or (p_policy->>'max_output_tokens')::integer is distinct from pol.max_output_tokens then raise exception 'MGD_ADMISSION_INVALID';end if;
 ub:=(pol.max_input_tokens*pol.input_usd_million+pol.max_output_tokens*pol.output_usd_million)/1000000;
 select coalesce(sum(case when d.status in('success','fallback','unknown_billable') then coalesce(d.charged_cost_usd,0)
  else coalesce(d.upper_bound_cost_usd,0) end),0) into spent
 from mission_narrative_internal.dispatch_receipts d where d.master_session_id=w.master_session_id;
 if spent+ub>a.cost_budget_usd then raise exception 'MGD_RUN_BUDGET_EXHAUSTED';end if;
 rr:=public.mission_narrative_attempt_reserve_internal(p_worker_token,w.dispatch_receipt_id,180,null,null);
 if rr->>'status'<>'reserved' then raise exception 'MGD_NATIVE_RESERVE_REJECTED';end if;
 z:=public.mission_narrative_provider_authorize_internal(p_worker_token,w.dispatch_receipt_id,(rr->>'attempt_id')::uuid,rr->>'lease_token');
 update mission_generic_owner.dispatch_admissions set calls_authorized=calls_authorized+1 where master_session_id=w.master_session_id;
 update mission_generic_owner.work_items set state='authorized',authorization_id=(z->>'authorization_id')::uuid where id=w.id;
 return z||jsonb_build_object('work_id',w.id,'granted_now',true);
end;
$fn$;

create function public.mission_generic_dispatch_consume_v1(p_work uuid,p_lease uuid,p_worker_token text,p_authorization uuid,p_dispatch_token text)
returns jsonb language plpgsql security definer set search_path='' as $fn$
declare w mission_generic_owner.work_items;z jsonb;d uuid:=gen_random_uuid();
begin
 perform mission_ai_board_owner.service_only();
 perform 1 from public.master_v2_sessions where id=(select master_session_id from mission_generic_owner.work_items where id=p_work) for update;
 select * into strict w from mission_generic_owner.work_items where id=p_work for update;
 perform mission_generic_owner.work_assert(w);
 if w.state<>'authorized' or w.authorization_id<>p_authorization or w.lease_id<>p_lease or w.lease_expires_at<=clock_timestamp()
 then raise exception 'MGD_CONSUME_STALE';end if;
 z:=public.mission_narrative_provider_consume_internal(p_worker_token,p_authorization,p_dispatch_token);
 update mission_generic_owner.work_items set state='provider_started',dispatch_id=d where id=w.id;
 return jsonb_build_object('work_id',w.id,'authorization_id',p_authorization,'dispatch_id',d,'granted_now',true,'finalize_token',z->>'finalize_token');
end;
$fn$;

create function public.mission_generic_dispatch_finalize_v1(p_work uuid,p_finalize_token text,p_result_text text,p_result_sha text)
returns jsonb language plpgsql security definer set search_path='' as $fn$
declare w mission_generic_owner.work_items;d mission_narrative_internal.dispatch_receipts;z mission_narrative_internal.provider_authorizations;
 pol mission_narrative_internal.runtime_policy;a mission_narrative_internal.dispatch_attempts;
 ok boolean;stale boolean:=false;metrics jsonb;actual numeric;basis text;receipt uuid:=gen_random_uuid();msg uuid;cr jsonb;
 p_result jsonb;tr mission_generic_owner.trigger_receipts;ev public.mission_run_events;ob public.mission_run_outbox;
 publication uuid;bodysha text;bs mission_generic_owner.board_starts;
 application_error text;outcome_uncertain boolean:=false;
begin
 perform mission_ai_board_owner.service_only();
 perform 1 from public.master_v2_sessions where id=(select master_session_id from mission_generic_owner.work_items where id=p_work) for update;
 if p_result_text is null or octet_length(p_result_text)>65536
 or encode(extensions.digest(convert_to(p_result_text,'UTF8'),'sha256'),'hex') is distinct from p_result_sha
 then raise exception 'MGD_RESULT_HASH';end if;
 p_result:=p_result_text::jsonb;
 select * into strict w from mission_generic_owner.work_items where id=p_work for update;
 if w.state in('completed','failed','uncertain') then
  if w.result_sha256 is distinct from p_result_sha then raise exception 'MGD_FINALIZE_CONFLICT' using errcode='40001';end if;
  return mission_generic_owner.work_status(w);
 end if;
 select * into strict d from mission_narrative_internal.dispatch_receipts where id=w.dispatch_receipt_id for update;
 select * into strict z from mission_narrative_internal.provider_authorizations where id=w.authorization_id and receipt_id=d.id for update;
 select * into strict a from mission_narrative_internal.dispatch_attempts where id=z.attempt_id for update;
 select * into strict pol from mission_narrative_internal.runtime_policy where singleton for share;
 if w.state<>'provider_started' or d.status<>'provider_started' or z.finalize_token_sha256 is distinct from mission_narrative_internal.token_sha(p_finalize_token)
 or p_result->>'schema_version' is distinct from 'mission-generic-result/1' or p_result->>'work_id' is distinct from w.id::text
 or p_result->>'master_session_id' is distinct from w.master_session_id::text or p_result->>'event_id' is distinct from w.event_id::text
 or p_result->>'request_key' is distinct from w.request_key::text or (p_result->>'revision')::bigint is distinct from w.revision
 or p_result->>'authority_receipt_id' is distinct from w.authority_receipt_id::text or p_result->>'definition_sha256' is distinct from w.definition_sha256
 or p_result->>'payload_sha256' is distinct from w.payload_sha256 or p_result->>'kind' is distinct from w.kind
 or p_result->>'authorization_id' is distinct from w.authorization_id::text or p_result->>'dispatch_id' is distinct from w.dispatch_id::text
 or p_result->>'model' is distinct from pol.model or coalesce(p_result_sha,'')!~'^[0-9a-f]{64}$'
 or p_result->>'runtime_version' is distinct from 'mission-generic-runtime/1'
 or p_result->>'provider_calls' not in('0','1')
 or jsonb_typeof(p_result->'outcome_uncertain') is distinct from 'boolean'
 or (p_result->>'outcome_uncertain'='true' and p_result->>'ok' is distinct from 'false')
 or (p_result->>'ok'='true' and p_result->>'provider_calls' is distinct from '1')
 then raise exception 'MGD_FINALIZE_BINDING';end if;
 -- The exact canonical string is hashed before JSONB parsing; no JS/JSONB equivalence assumption.
 metrics:=p_result->'usage';
 if jsonb_typeof(metrics) is distinct from 'object' then metrics:='{}';end if;
 if jsonb_typeof(metrics)='object' and mission_generic_owner.keys_valid(metrics,array['input_tokens','output_tokens','reasoning_tokens','total_tokens'])
 and not exists(select 1 from jsonb_each_text(metrics) where value!~'^[0-9]+$')
 and (metrics->>'reasoning_tokens')::numeric<=(metrics->>'output_tokens')::numeric
 and (metrics->>'total_tokens')::numeric=(metrics->>'input_tokens')::numeric+(metrics->>'output_tokens')::numeric then
  actual:=((metrics->>'input_tokens')::numeric*pol.input_usd_million+(metrics->>'output_tokens')::numeric*pol.output_usd_million)/1000000;basis:='exact';
 else actual:=d.upper_bound_cost_usd;basis:='upper_bound';end if;
 if actual>d.upper_bound_cost_usd then stale:=true;end if;
 begin perform mission_generic_owner.work_assert(w); exception when others then stale:=true;end;
 outcome_uncertain:=(p_result->>'outcome_uncertain')::boolean;
 ok:=coalesce((p_result->>'ok')::boolean,false) and not outcome_uncertain and not stale and w.lease_expires_at>clock_timestamp();
 -- Result application is a subtransaction: failures roll back every domain write,
 -- while the outer transaction still records the provider receipt and real cost.
 begin
 if ok and w.kind='choice' then
  cr:=mission_generic_owner.choice_commit(w.id,(w.payload->>'capability_id')::uuid,p_result->'command');
  if cr is null or not exists(select 1 from mission_generic_owner.panel_choices pc
   join combat_panel_private.request_receipts rr on rr.principal_user=pc.principal_id and rr.request_key=pc.request_key
   where pc.work_id=w.id and pc.id=(w.payload->>'capability_id')::uuid and pc.consumed_at is not null
    and pc.result=cr and rr.viewer_envelope=cr and rr.event_id is not null
    and rr.offer_id=(p_result#>>'{command,offer_id}')::uuid
    and pc.command_sha256=public.combat_v2_sha256(combat_panel_private.validate_command(p_result->'command')))
  then raise exception 'MGD_COMMAND_RECEIPT_MISSING';end if;
 elsif ok then
  if w.payload#>>'{barrier,closed}' is distinct from 'true'
   or exists(select 1 from jsonb_array_elements_text(w.payload#>'{barrier,required_receipt_ids}') id
    where not(w.payload#>'{barrier,receipt_ids}' ? id))
   or jsonb_typeof(p_result->'text') is distinct from 'string' or length(btrim(p_result->>'text')) not between 1 and 5000
  then raise exception 'MGD_NARRATIVE_BARRIER';end if;
  if w.payload->>'mode'='combat' then
   cr:=mission_generic_owner.combat_publish(w.id,p_result->>'text',w.request_key);
   msg:=(cr->>'message_id')::uuid;
   if msg is null or not exists(select 1 from public.messages m join public.master_v2_sessions s on s.location_id=m.location_id
    where s.id=w.master_session_id and m.id=msg) then raise exception 'MGD_COMBAT_PUBLICATION_MISSING';end if;
  elsif w.payload->>'mode'='mission' then
   insert into public.messages(location_id,character_id,author_name,body,kind,sender_user,recipient_user,created_at)
   select location_id,null,'Fato',p_result->>'text','fato',null,null,clock_timestamp() from public.master_v2_sessions where id=w.master_session_id returning id into msg;
   if w.payload ? 'opening_start_receipt_id' then
    select * into strict bs from mission_generic_owner.board_starts where id=w.authority_receipt_id and master_session_id=w.master_session_id for update;
    select * into strict ev from public.mission_run_events where id=bs.event_id and master_session_id=w.master_session_id for update;
   else
    select * into strict tr from mission_generic_owner.trigger_receipts where id=w.authority_receipt_id and master_session_id=w.master_session_id;
    select * into strict ev from public.mission_run_events where id=(tr.result->>'event_id')::uuid and master_session_id=w.master_session_id for update;
   end if;
   select * into strict ob from public.mission_run_outbox where event_id=ev.id and master_session_id=w.master_session_id for update;
   if ev.status<>'committed' or ob.state<>'pending' or ev.version_after<>w.run_control_version
    or ob.event_version_after<>ev.version_after or ev.step_after<>w.step_key or ob.step_key<>w.step_key
    or ob.context_fingerprint<>ev.context_fingerprint then raise exception 'MGD_OUTBOX_STALE';end if;
   bodysha:=encode(extensions.digest(convert_to(p_result->>'text','UTF8'),'sha256'),'hex');
   publication:=gen_random_uuid();
   insert into public.mission_run_publications(id,master_session_id,event_id,request_key_sha256,request_fingerprint,source,
    expected_run_control_version,expected_event_version_after,expected_step_key,context_fingerprint,body_sha256,status)
   values(publication,w.master_session_id,ev.id,mission_internal.request_key_sha256(w.request_key),
    mission_internal.fingerprint(jsonb_build_object('schema_version','mission-generic-publication/1','work_id',w.id,'event_id',ev.id,
    'payload_sha256',w.payload_sha256,'body_sha256',bodysha)),'model',w.run_control_version,ev.version_after,w.step_key,ev.context_fingerprint,bodysha,'committed');
   insert into public.mission_run_messages(publication_id,message_id,body_sha256) values(publication,msg,bodysha);
   -- Same guarded outbox transition as native publication; no invented reveal grants.
   perform set_config('app.mission_outbox_publish','on',true);
   update public.mission_run_outbox set state='published',publication_id=publication,published_at=clock_timestamp() where event_id=ev.id;
   perform set_config('app.mission_outbox_publish','off',true);
   if w.payload ? 'opening_start_receipt_id' then
    perform mission_generic_owner.opening_published(w.master_session_id,publication);
   end if;
  else raise exception 'MGD_NARRATIVE_MODE';
  end if;
 end if;
 exception when others then
  application_error:=SQLSTATE;ok:=false;msg:=null;cr:=null;publication:=null;
 end;
 update mission_narrative_internal.dispatch_attempts set status=case when basis='exact' then 'success' else 'unknown_billable' end,
  actual_cost_usd=actual,cost_basis=basis,input_tokens=case when basis='exact' then (metrics->>'input_tokens')::int end,
  output_tokens=case when basis='exact' then (metrics->>'output_tokens')::int end,reasoning_tokens=case when basis='exact' then (metrics->>'reasoning_tokens')::int end,
  total_tokens=case when basis='exact' then (metrics->>'total_tokens')::int end,finalized_at=clock_timestamp() where id=a.id;
 update mission_narrative_internal.dispatch_receipts set status=case when basis='exact' then 'success' else 'unknown_billable' end,
  charged_cost_usd=actual,lease_token_sha256=null,lease_expires_at=null,finalized_at=clock_timestamp(),updated_at=clock_timestamp() where id=d.id;
 update mission_narrative_internal.provider_authorizations set finalize_token_sha256=null where id=z.id;
 update mission_generic_owner.work_items set state=case when outcome_uncertain then 'uncertain' when ok then 'completed' else 'failed' end,result=p_result,result_sha256=p_result_sha,
  receipt_id=receipt,message_id=msg,finalized_at=clock_timestamp() where id=w.id returning * into w;
 insert into mission_narrative_internal.dispatch_audit(receipt_id,event_code,details) values(d.id,'generic_finalized',jsonb_build_object(
  'work_id',w.id,'receipt_id',receipt,'message_id',msg,'result_jsonb_sha256',public.combat_v2_sha256(p_result),'result_sha256',p_result_sha,
  'command_receipt',cr,'cost_basis',basis,'stale',stale,'state',w.state,
  'outcome_uncertain',outcome_uncertain,'application_error_sqlstate',application_error));
 return mission_generic_owner.work_status(w);
end;
$fn$;

revoke all on function mission_generic_owner.dispatch_user(uuid,uuid),mission_generic_owner.dispatch_admit(uuid,integer,numeric),
 mission_generic_owner.work_status(mission_generic_owner.work_items),mission_generic_owner.work_assert(mission_generic_owner.work_items),
 mission_generic_owner.narrative_context(uuid,text,uuid,timestamptz,jsonb),mission_generic_owner.enqueue_opening(uuid,uuid),
 mission_generic_owner.enqueue_transition(uuid,uuid),mission_generic_owner.trigger_dispatch_enqueue(),
 mission_generic_owner.enqueue_choice(uuid,uuid,uuid),mission_generic_owner.enqueue_combat(uuid,uuid)
 from public,anon,authenticated,service_role;
revoke all on function public.mission_generic_dispatch_next_v1(uuid,uuid),public.mission_generic_dispatch_status_v1(uuid,jsonb),
 public.mission_generic_dispatch_reject_v1(uuid,jsonb,uuid,text),
 public.mission_generic_dispatch_claim_v1(uuid,jsonb),public.mission_generic_dispatch_authorize_v1(uuid,uuid,text,jsonb),
 public.mission_generic_dispatch_consume_v1(uuid,uuid,text,uuid,text),public.mission_generic_dispatch_finalize_v1(uuid,text,text,text)
 from public,anon,authenticated,service_role;
grant execute on function public.mission_generic_dispatch_next_v1(uuid,uuid),public.mission_generic_dispatch_status_v1(uuid,jsonb),
 public.mission_generic_dispatch_reject_v1(uuid,jsonb,uuid,text),
 public.mission_generic_dispatch_claim_v1(uuid,jsonb),public.mission_generic_dispatch_authorize_v1(uuid,uuid,text,jsonb),
 public.mission_generic_dispatch_consume_v1(uuid,uuid,text,uuid,text),public.mission_generic_dispatch_finalize_v1(uuid,text,text,text) to service_role;
commit;
