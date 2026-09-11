-- MISSION-GENERIC-PROVIDER-GATE/1. No enable and no price changes.
begin;
create table mission_generic_owner.provider_policy (
 singleton boolean primary key default true check(singleton),
 enabled boolean not null default false,
 max_run_calls integer check(max_run_calls>0),
 max_daily_calls integer check(max_daily_calls>0),
 max_global_calls integer check(max_global_calls>0),
 run_budget_usd numeric check(run_budget_usd>0 and run_budget_usd<'Infinity'::numeric),
 daily_budget_usd numeric check(daily_budget_usd>0 and daily_budget_usd<'Infinity'::numeric),
 global_budget_usd numeric check(global_budget_usd>0 and global_budget_usd<'Infinity'::numeric),
 check(not enabled or (max_run_calls is not null and max_daily_calls is not null and max_global_calls is not null
  and run_budget_usd is not null and daily_budget_usd is not null and global_budget_usd is not null))
);
insert into mission_generic_owner.provider_policy(singleton) values(true);
create table mission_generic_owner.provider_permits (
 work_id uuid primary key references mission_generic_owner.work_items(id),
 receipt_id uuid not null unique references mission_narrative_internal.dispatch_receipts(id),
 transaction_id bigint not null, backend_pid integer not null,
 stage text not null check(stage in('authorize','consume')),
 lease_id uuid not null, payload_sha256 text not null check(payload_sha256~'^[0-9a-f]{64}$'),
 issued_at timestamptz not null default clock_timestamp()
);
alter table mission_generic_owner.provider_policy enable row level security;
alter table mission_generic_owner.provider_permits enable row level security;
revoke all on mission_generic_owner.provider_policy,mission_generic_owner.provider_permits from public,anon,authenticated,service_role;

-- Preclaim checks scope/configuration only. Reservation remains under the native
-- runtime-policy row lock; its existing prices and upper-bound formula are reused.
create function mission_generic_owner.provider_ready(p_work uuid)
returns void language plpgsql security definer set search_path='' as $fn$
declare w mission_generic_owner.work_items;a mission_generic_owner.dispatch_admissions;
 g mission_generic_owner.provider_policy;
begin
 perform mission_ai_board_owner.service_only();
 select * into strict w from mission_generic_owner.work_items where id=p_work;
 perform mission_generic_owner.work_assert(w);
 select * into strict g from mission_generic_owner.provider_policy where singleton for share;
 select * into strict a from mission_generic_owner.dispatch_admissions where master_session_id=w.master_session_id;
 if not g.enabled or not a.enabled or a.call_limit>g.max_run_calls or a.cost_budget_usd>g.run_budget_usd
 or a.calls_authorized>a.call_limit then raise exception 'MGPG_CLOSED_OR_ADMISSION';end if;
end;
$fn$;

-- A permit is minted only inside the generic dispatcher transaction. Native
-- worker tokens, receipt UUIDs or session membership alone cannot create one.
create function mission_generic_owner.provider_permit(p_work uuid,p_stage text)
returns void language plpgsql security definer set search_path='' as $fn$
declare w mission_generic_owner.work_items;
begin
 perform mission_generic_owner.provider_ready(p_work);
 select * into strict w from mission_generic_owner.work_items where id=p_work;
 if p_stage not in('authorize','consume') or w.dispatch_receipt_id is null or w.lease_expires_at<=clock_timestamp()
 or w.state<>(case p_stage when 'authorize' then 'claimed' else 'authorized' end)
 then raise exception 'MGPG_PERMIT_STAGE';end if;
 insert into mission_generic_owner.provider_permits(work_id,receipt_id,transaction_id,backend_pid,stage,lease_id,payload_sha256)
 values(w.id,w.dispatch_receipt_id,txid_current(),pg_backend_pid(),p_stage,w.lease_id,w.payload_sha256)
 on conflict(work_id) do update set receipt_id=excluded.receipt_id,transaction_id=excluded.transaction_id,
 backend_pid=excluded.backend_pid,stage=excluded.stage,lease_id=excluded.lease_id,payload_sha256=excluded.payload_sha256,issued_at=clock_timestamp();
end;
$fn$;

create function mission_generic_owner.provider_native_assert(p_receipt uuid,p_stage text)
returns void language plpgsql security definer set search_path='' as $fn$
declare r mission_narrative_internal.dispatch_receipts;w mission_generic_owner.work_items;
 k mission_generic_owner.provider_permits;g mission_generic_owner.provider_policy;
 a mission_generic_owner.dispatch_admissions;pol mission_narrative_internal.runtime_policy;
 run_spent numeric;day_spent numeric;all_spent numeric;run_calls bigint;day_calls bigint;all_calls bigint;
 ub numeric;extra numeric;extra_call integer;env jsonb;
begin
 if p_stage not in('reserve','authorize','consume') then raise exception 'MGPG_STAGE';end if;
 select * into strict r from mission_narrative_internal.dispatch_receipts where id=p_receipt;
 select * into strict w from mission_generic_owner.work_items where id=r.authority_receipt_id and dispatch_receipt_id=r.id;
 perform mission_generic_owner.provider_ready(w.id);
 select * into strict k from mission_generic_owner.provider_permits where work_id=w.id and receipt_id=r.id;
 if k.transaction_id<>txid_current() or k.backend_pid<>pg_backend_pid()
 or k.stage<>(case p_stage when 'consume' then 'consume' else 'authorize' end)
 or k.lease_id<>w.lease_id or k.payload_sha256<>w.payload_sha256 or w.lease_expires_at<=clock_timestamp()
 or w.state<>(case p_stage when 'consume' then 'authorized' else 'claimed' end)
 or r.status<>(case p_stage when 'reserve' then 'claimed' when 'authorize' then 'reserved' else 'authorized' end)
 or r.event_kind<>'mission_generic_event' or r.renderer_version<>'mission-generic-runtime/1'
 or r.master_session_id<>w.master_session_id or r.request_key<>w.request_key
 then raise exception 'MGPG_PERMIT_INVALID';end if;
 env:=jsonb_build_object('work_id',w.id,'master_session_id',w.master_session_id,'event_id',w.event_id,
 'authority_receipt_id',w.authority_receipt_id,'payload_sha256',w.payload_sha256,'definition_sha256',w.definition_sha256,'revision',w.revision);
 if r.envelope<>env or r.envelope_sha256<>public.combat_v2_sha256(env) or r.authority_sha256<>public.combat_v2_sha256(env)
 then raise exception 'MGPG_ENVELOPE_INVALID';end if;
 select * into strict g from mission_generic_owner.provider_policy where singleton;
 select * into strict a from mission_generic_owner.dispatch_admissions where master_session_id=w.master_session_id;
 select * into strict pol from mission_narrative_internal.runtime_policy where singleton;
 if pol.model<>'gpt-5.6-luna' or pol.reasoning_effort<>'high' or pol.store
 or pol.max_input_tokens<=0 or pol.max_output_tokens<=0
 or not(pol.input_usd_million>=0 and pol.input_usd_million<'Infinity'::numeric)
 or not(pol.output_usd_million>=0 and pol.output_usd_million<'Infinity'::numeric)
 then raise exception 'MGPG_NATIVE_PRICING_POLICY';end if;
 ub:=(pol.max_input_tokens*pol.input_usd_million+pol.max_output_tokens*pol.output_usd_million)/1000000;
 -- Native reserve holds runtime_policy FOR UPDATE before this sum. Other phases
 -- only validate an already charged reservation; no second reservation is added.
 select coalesce(sum(cost)filter(where d.master_session_id=w.master_session_id),0),
 coalesce(sum(cost)filter(where d.created_at>=date_trunc('day',clock_timestamp())),0),coalesce(sum(cost),0),
 count(*)filter(where used and d.master_session_id=w.master_session_id),
 count(*)filter(where used and d.created_at>=date_trunc('day',clock_timestamp())),count(*)filter(where used)
 into run_spent,day_spent,all_spent,run_calls,day_calls,all_calls
 from (select d.*,case when d.status in('success','fallback','unknown_billable') then coalesce(d.charged_cost_usd,d.upper_bound_cost_usd,0)
 else coalesce(d.upper_bound_cost_usd,0) end cost,
 exists(select 1 from mission_narrative_internal.dispatch_attempts t where t.receipt_id=d.id) used
 from mission_narrative_internal.dispatch_receipts d where d.event_kind='mission_generic_event' and d.renderer_version='mission-generic-runtime/1') d;
 extra:=case when p_stage='reserve' then ub else 0 end;extra_call:=case when p_stage='reserve' then 1 else 0 end;
 if run_spent+extra>least(g.run_budget_usd,a.cost_budget_usd) or day_spent+extra>g.daily_budget_usd or all_spent+extra>g.global_budget_usd
 or run_calls+extra_call>least(g.max_run_calls,a.call_limit) or day_calls+extra_call>g.max_daily_calls or all_calls+extra_call>g.max_global_calls
 then raise exception 'MGPG_BUDGET_EXHAUSTED';end if;
end;
$fn$;
revoke all on function mission_generic_owner.provider_ready(uuid),mission_generic_owner.provider_permit(uuid,text),
 mission_generic_owner.provider_native_assert(uuid,text) from public,anon,authenticated,service_role;

DO $patch$
declare old_source text;ddl text;
begin
 select pg_get_functiondef(oid),pg_get_functiondef(oid) into strict old_source,ddl from pg_proc where oid='public.mission_narrative_attempt_reserve_internal(text,uuid,integer,jsonb,text)'::regprocedure;
 if encode(extensions.digest(convert_to(old_source,'UTF8'),'sha256'),'hex')<>'3aeec15d817c925edaeebaaa05e41dfe3ccaf2975b57f9667ef5aab9296b5930' then raise exception 'MGPG_BASELINE_DRIFT: public.mission_narrative_attempt_reserve_internal(text,uuid,integer,jsonb,text)';end if;
 if position($old$select * into strict pol from mission_narrative_internal.runtime_policy where singleton for update;$old$ in ddl)=0 or (length(ddl)-length(replace(ddl,$old$select * into strict pol from mission_narrative_internal.runtime_policy where singleton for update;$old$,'')))/length($old$select * into strict pol from mission_narrative_internal.runtime_policy where singleton for update;$old$)<>1 then raise exception 'MGPG_PATCH_ANCHOR';end if;
 ddl:=replace(ddl,$old$select * into strict pol from mission_narrative_internal.runtime_policy where singleton for update;$old$,$new$select * into strict pol from mission_narrative_internal.runtime_policy where singleton for update;if r.event_kind='mission_generic_event' then perform mission_generic_owner.provider_native_assert(r.id,'reserve');pol.enabled:=true;end if;$new$);execute ddl;
end;
$patch$;

DO $patch$
declare old_source text;ddl text;
begin
 select pg_get_functiondef(oid),pg_get_functiondef(oid) into strict old_source,ddl from pg_proc where oid='public.mission_narrative_provider_authorize_internal(text,uuid,uuid,text)'::regprocedure;
 if encode(extensions.digest(convert_to(old_source,'UTF8'),'sha256'),'hex')<>'9a6354cd4491c8373b71c55ec57da3b7fc674f5f65c6098947911c624e418a61' then raise exception 'MGPG_BASELINE_DRIFT: public.mission_narrative_provider_authorize_internal(text,uuid,uuid,text)';end if;
 if position($old$select * into strict pol from mission_narrative_internal.runtime_policy where singleton for share;$old$ in ddl)=0 or (length(ddl)-length(replace(ddl,$old$select * into strict pol from mission_narrative_internal.runtime_policy where singleton for share;$old$,'')))/length($old$select * into strict pol from mission_narrative_internal.runtime_policy where singleton for share;$old$)<>1 then raise exception 'MGPG_PATCH_ANCHOR';end if;
 ddl:=replace(ddl,$old$select * into strict pol from mission_narrative_internal.runtime_policy where singleton for share;$old$,$new$select * into strict pol from mission_narrative_internal.runtime_policy where singleton for share;if r.event_kind='mission_generic_event' then perform mission_generic_owner.provider_native_assert(r.id,'authorize');pol.enabled:=true;end if;$new$);execute ddl;
end;
$patch$;

DO $patch$
declare old_source text;ddl text;
begin
 select pg_get_functiondef(oid),pg_get_functiondef(oid) into strict old_source,ddl from pg_proc where oid='public.mission_narrative_provider_consume_internal(text,uuid,text)'::regprocedure;
 if encode(extensions.digest(convert_to(old_source,'UTF8'),'sha256'),'hex')<>'4bb867ff39aa53274c6a1c27cf1bcfb9919c36f7d71ebad9a1f2b2664a5ba957' then raise exception 'MGPG_BASELINE_DRIFT: public.mission_narrative_provider_consume_internal(text,uuid,text)';end if;
 if position($old$end if;raw:=gen_random_uuid()::text;$old$ in ddl)=0 or (length(ddl)-length(replace(ddl,$old$end if;raw:=gen_random_uuid()::text;$old$,'')))/length($old$end if;raw:=gen_random_uuid()::text;$old$)<>1 then raise exception 'MGPG_PATCH_ANCHOR';end if;
 ddl:=replace(ddl,$old$end if;raw:=gen_random_uuid()::text;$old$,$new$end if;if r.event_kind='mission_generic_event' then perform mission_generic_owner.provider_native_assert(r.id,'consume');end if;raw:=gen_random_uuid()::text;$new$);execute ddl;
end;
$patch$;

DO $patch$
declare old_source text;ddl text;
begin
 select prosrc,pg_get_functiondef(oid) into strict old_source,ddl from pg_proc where oid='public.mission_generic_dispatch_claim_v1(uuid,jsonb)'::regprocedure;
 if encode(extensions.digest(convert_to(old_source,'UTF8'),'sha256'),'hex')<>'ef3630bccd770a2f4b4557e37da9671e7178317f084b19dd1a3b9d606b495432' then raise exception 'MGPG_BASELINE_DRIFT: public.mission_generic_dispatch_claim_v1(uuid,jsonb)';end if;
 if position($old$if not a.enabled or a.calls_authorized>=a.call_limit or not pol.enabled or pol.model<>'gpt-5.6-luna'$old$ in ddl)=0 or (length(ddl)-length(replace(ddl,$old$if not a.enabled or a.calls_authorized>=a.call_limit or not pol.enabled or pol.model<>'gpt-5.6-luna'$old$,'')))/length($old$if not a.enabled or a.calls_authorized>=a.call_limit or not pol.enabled or pol.model<>'gpt-5.6-luna'$old$)<>1 then raise exception 'MGPG_PATCH_ANCHOR';end if;
 ddl:=replace(ddl,$old$if not a.enabled or a.calls_authorized>=a.call_limit or not pol.enabled or pol.model<>'gpt-5.6-luna'$old$,$new$perform mission_generic_owner.provider_ready(w.id);
 if not a.enabled or a.calls_authorized>=a.call_limit or pol.model<>'gpt-5.6-luna'$new$);execute ddl;
end;
$patch$;

DO $patch$
declare old_source text;ddl text;
begin
 select prosrc,pg_get_functiondef(oid) into strict old_source,ddl from pg_proc where oid='public.mission_generic_dispatch_authorize_v1(uuid,uuid,text,jsonb)'::regprocedure;
 if encode(extensions.digest(convert_to(old_source,'UTF8'),'sha256'),'hex')<>'f145326d6e4a4299fd8c230f43c1706615936eba30177236a4e635c3b3ad9693' then raise exception 'MGPG_BASELINE_DRIFT: public.mission_generic_dispatch_authorize_v1(uuid,uuid,text,jsonb)';end if;
 if position($old$rr:=public.mission_narrative_attempt_reserve_internal($old$ in ddl)=0 or (length(ddl)-length(replace(ddl,$old$rr:=public.mission_narrative_attempt_reserve_internal($old$,'')))/length($old$rr:=public.mission_narrative_attempt_reserve_internal($old$)<>1 then raise exception 'MGPG_PATCH_ANCHOR';end if;
 ddl:=replace(ddl,$old$rr:=public.mission_narrative_attempt_reserve_internal($old$,$new$perform mission_generic_owner.provider_permit(w.id,'authorize');
 rr:=public.mission_narrative_attempt_reserve_internal($new$);execute ddl;
end;
$patch$;

DO $patch$
declare old_source text;ddl text;
begin
 select prosrc,pg_get_functiondef(oid) into strict old_source,ddl from pg_proc where oid='public.mission_generic_dispatch_consume_v1(uuid,uuid,text,uuid,text)'::regprocedure;
 if encode(extensions.digest(convert_to(old_source,'UTF8'),'sha256'),'hex')<>'35176084208703a77d05c7c576ef9a714231ea636c0753c5f51925e136fc193f' then raise exception 'MGPG_BASELINE_DRIFT: public.mission_generic_dispatch_consume_v1(uuid,uuid,text,uuid,text)';end if;
 if position($old$z:=public.mission_narrative_provider_consume_internal($old$ in ddl)=0 or (length(ddl)-length(replace(ddl,$old$z:=public.mission_narrative_provider_consume_internal($old$,'')))/length($old$z:=public.mission_narrative_provider_consume_internal($old$)<>1 then raise exception 'MGPG_PATCH_ANCHOR';end if;
 ddl:=replace(ddl,$old$z:=public.mission_narrative_provider_consume_internal($old$,$new$perform mission_generic_owner.provider_permit(w.id,'consume');
 z:=public.mission_narrative_provider_consume_internal($new$);execute ddl;
end;
$patch$;

-- CREATE OR REPLACE preserves the native ACLs. Explicitly retain service-only generic RPC grants.
revoke all on function public.mission_generic_dispatch_claim_v1(uuid,jsonb),public.mission_generic_dispatch_authorize_v1(uuid,uuid,text,jsonb),public.mission_generic_dispatch_consume_v1(uuid,uuid,text,uuid,text) from public,anon,authenticated;
grant execute on function public.mission_generic_dispatch_claim_v1(uuid,jsonb),public.mission_generic_dispatch_authorize_v1(uuid,uuid,text,jsonb),public.mission_generic_dispatch_consume_v1(uuid,uuid,text,uuid,text) to service_role;
commit;
