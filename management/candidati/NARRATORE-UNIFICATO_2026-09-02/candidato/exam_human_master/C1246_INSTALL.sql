begin;
set local lock_timeout='2s';
set local statement_timeout='10s';
do $preflight$
begin
 if to_regprocedure('public.mission_staff_catalog_state_v1()') is not null then raise exception 'C1246_CATALOG_ALREADY_EXISTS';end if;
 if (select md5(prosrc) from pg_proc where oid='mission_ai_board_owner.staff_only()'::regprocedure) is distinct from 'e9eb8c959bad86a2a4b265ca0e4800a0' then raise exception 'C1246_STAFF_AUTH_DRIFT';end if;
end $preflight$;
create function public.mission_staff_catalog_state_v1() returns jsonb
language plpgsql stable security definer set search_path='' as $c1246$
begin
 perform mission_ai_board_owner.staff_only();
 return jsonb_build_object('schema_version','mission-staff-catalog/1','missions',
  (select coalesce(jsonb_agg(jsonb_build_object('id',m.id,'title',m.title,'status',m.status,
   'kind',case when ss.carrier_mission_id is null then 'source' else 'protected_test' end,
   'source_id',ss.source_mission_id,'archived',ss.carrier_mission_id is not null
    and exists(select 1 from public.master_v2_sessions h where h.mission_id=m.id and h.closed_at is not null and h.stato in('chiusa','annullata'))
    and not exists(select 1 from public.master_v2_sessions h where h.mission_id=m.id and (h.closed_at is null or h.stato not in('chiusa','annullata'))))
   order by m.title,m.id),'[]'::jsonb)
   from public.missions m left join mission_generic_owner.simulation_sources ss on ss.carrier_mission_id=m.id));
end $c1246$;

revoke all on function public.mission_staff_catalog_state_v1() from public,anon,authenticated,service_role;
grant execute on function public.mission_staff_catalog_state_v1() to authenticated;
commit;
