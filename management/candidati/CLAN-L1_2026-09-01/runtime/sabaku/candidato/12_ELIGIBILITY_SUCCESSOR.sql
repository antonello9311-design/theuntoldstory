-- Common Eligibility: riconosce soltanto il successore Marionetta gia rilasciato.
-- Prova inversa sui due corpi in baseline/ELIGIBILITY_SUCCESSOR.json: rimosse
-- le sole aggiunte reviewed Marionetta, gli hash tornano esattamente R9.
-- Nessun pin eliminato: altre tre funzioni, ACL, owner, path, schema/history
-- e character_elementi restano soggetti agli stessi controlli.
DO $baseline$
BEGIN
 IF encode(extensions.digest(convert_to(pg_get_functiondef('clan_innata_private.eligibility_release_assert()'::regprocedure),'UTF8'),'sha256'),'hex')<>'e184778b2cbbac9ef1219181b3637034a242fad0c520526b7c97ef89554760d6' THEN
   RAISE EXCEPTION 'common_eligibility_baseline_drift'; END IF;
END $baseline$;

CREATE OR REPLACE FUNCTION clan_innata_private.eligibility_release_assert()
 RETURNS void
 LANGUAGE plpgsql
 STABLE SECURITY DEFINER
 SET search_path TO 'pg_catalog', 'public', 'clan_innata_private'
AS $function$
declare v_marionetta boolean:=false;
begin
 if exists(select 1 from supabase_migrations.schema_migrations where name='marionetta_ordinary_staff_001' or version='20260907084651') then
   if (select count(*) from supabase_migrations.schema_migrations where name='marionetta_ordinary_staff_001' or version='20260907084651')<>1
     or not exists(select 1 from supabase_migrations.schema_migrations where version='20260907084651' and name='marionetta_ordinary_staff_001'
       and cardinality(statements)=1 and encode(extensions.digest(convert_to(array_to_string(statements,''),'UTF8'),'sha256'),'hex')='3d3b6643c1b513728ee8e2366fbde983aa374cf9d330f0976d71c5f122318f17') then
     raise exception 'runtime_eligibility_marionetta_release_drift'; end if;
   v_marionetta:=true;
 end if;
 if (select count(*) from supabase_migrations.schema_migrations where version='20260902055751' and name='genin_elemental_eligibility_common_009' and cardinality(statements)=1 and encode(extensions.digest(convert_to(array_to_string(statements,''),'UTF8'),'sha256'),'hex')='e2ca4e296401307496cdc1ed108f4cf22ee4469a34072172c7b9855063a97c2e')<>1
 or (select count(*) from supabase_migrations.schema_migrations where version between '20260902005704' and '20260902055751')<>4
 or (select count(*) from supabase_migrations.schema_migrations where name='clan_genin_innata_common_release_seal_eligibility_018')>1
 or ((select count(*) from supabase_migrations.schema_migrations where name='clan_genin_innata_common_release_seal_eligibility_018')=0 and ((select count(*) from supabase_migrations.schema_migrations)<>452 or (select version from supabase_migrations.schema_migrations order by version desc limit 1) is distinct from '20260902055751'))
 or ((select count(*) from supabase_migrations.schema_migrations where name='clan_genin_innata_common_release_seal_eligibility_018')=1 and not exists(select 1 from supabase_migrations.schema_migrations where name='clan_genin_innata_common_release_seal_eligibility_018' and version~'^[0-9]{14}$' and version>'20260902055751' and cardinality(statements)=1))
 then raise exception 'runtime_eligibility_history_drift';end if;
 if to_regnamespace('combat_v2_elemental_internal') is null
 or (select count(*) from pg_proc p where p.pronamespace='combat_v2_elemental_internal'::regnamespace)<>2
 or (select pg_get_userbyid(n.nspowner)||'|'||coalesce(n.nspacl::text,'') from pg_namespace n where n.oid='combat_v2_elemental_internal'::regnamespace) is distinct from 'postgres|{postgres=UC/postgres,service_role=U/postgres}'
 then raise exception 'runtime_eligibility_schema_drift';end if;
 if exists(
  with expected(sig,sha,acl) as(values
   ('combat_v2_elemental_internal.is_target_v1(uuid)','8af6bdfc87b76ed118b596f7c7885c6de849c5d89140f61cdd1845047cbd5724','postgres:EXECUTE:false,service_role:EXECUTE:false'),
   ('combat_v2_elemental_internal.eligible_v1(uuid,uuid,boolean)','a5161f2993a4e0ce51864ac67ea88ba3fa6966457da1caf4ca390f17c2b1d8e9','postgres:EXECUTE:false,service_role:EXECUTE:false'),
   ('public.combat_v2_character_snapshot(uuid)',case when v_marionetta then '20c680c16a5ba1adedada1b9dcb6b5ee2f91bf01ddbdd9c0d40064d9d2d57ee3' else '323d6dd5a1cfac2ad6535fb73a4aefb03d33c7aa2894b9196489c17880046f87' end,'postgres:EXECUTE:false,service_role:EXECUTE:false'),
   ('public.combat_v2_actor_ability(uuid,text,uuid,boolean)','2b141c8e4d34edf084263990feb4278c1a5c1e870aafdaffef7a8ff49c262e84','postgres:EXECUTE:false,service_role:EXECUTE:false'),
   ('public.combat_v2_round_options(uuid,uuid)',case when v_marionetta then '6b9012a057baa9bc06b201ce6bcc5b8d8bb4a832ae9a462444c5e3ef55e0c8cb' else '3be90b0da7f02c826ffdfcd594d2132a4af9128291e3417278ad6adac88f6129' end,'authenticated:EXECUTE:false,postgres:EXECUTE:false,service_role:EXECUTE:false')),
  observed as(select e.*,encode(extensions.digest(convert_to(pg_get_functiondef(e.sig::regprocedure),'UTF8'),'sha256'),'hex') actual_sha,p.proowner,p.prosecdef,p.proconfig,(select string_agg(coalesce(r.rolname,'PUBLIC')||':'||x.privilege_type||':'||x.is_grantable,',' order by coalesce(r.rolname,'PUBLIC'),x.privilege_type,x.is_grantable) from aclexplode(coalesce(p.proacl,acldefault('f',p.proowner))) x left join pg_roles r on r.oid=x.grantee) actual_acl from expected e join pg_proc p on p.oid=e.sig::regprocedure)
  select 1 from observed where actual_sha is distinct from sha or actual_acl is distinct from acl or proowner<>'postgres'::regrole or not prosecdef or proconfig is distinct from array['search_path=""'])
 then raise exception 'runtime_eligibility_full_seal_drift';end if;
 if encode(extensions.digest(convert_to(pg_get_functiondef('public.character_elementi(uuid)'::regprocedure),'UTF8'),'sha256'),'hex') is distinct from '2e62fad3aa654ab452c516549ca82068dd33f6496a3c1e17e3a8c805a8ddacd7'
 then raise exception 'runtime_eligibility_character_elementi_drift';end if;
end $function$;
