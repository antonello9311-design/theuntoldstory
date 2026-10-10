begin;
set local lock_timeout='2s';
do $recovery$ begin
 if (select md5(prosrc) from pg_proc where oid='public.mission_staff_catalog_state_v1()'::regprocedure) is distinct from '929e147167e6c2ca53689da0065473ff' then raise exception 'C1246_RECOVERY_DRIFT';end if;
end $recovery$;
revoke all on function public.mission_staff_catalog_state_v1() from public,anon,authenticated,service_role;
commit;
