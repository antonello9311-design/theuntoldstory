begin read only;

select count(*) as history_count,
       (array_agg(version order by version desc))[1] as head_version,
       (array_agg(name order by version desc))[1] as head_name
from supabase_migrations.schema_migrations;

select version,name,
       encode(extensions.digest(convert_to(array_to_string(statements,E'\n'),'UTF8'),'sha256'),'hex') as statement_sha256
from supabase_migrations.schema_migrations
where (version,name) in (
  ('20260901065823','common_sostituzione_spatial_runtime_bridge_009_media_r4_rebase'),
  ('20260901195205','combat_v2_substitution_spatial_offer_only')
)
order by version;

select id,name_it,rank,chakra_cost,action_type,uso,difensiva,gittata,is_active
from public.jutsu
where id='31b15861-fb78-4f8a-ac1c-ebf2d957c32e'::uuid;

with required(signature) as (values
  ('combat_spatial.anchor_is_legal(uuid,uuid,text,text,integer)'),
  ('combat_spatial.substitution_commit(uuid,uuid,uuid)'),
  ('public.combat_v2_substitution_options_v1(uuid)'),
  ('public.combat_v2_substitution_select_v1(uuid,uuid)'),
  ('public.combat_v2_substitution_resolve_internal_v1(uuid,uuid)'),
  ('public.exam_substitution_options_v1(uuid,uuid)'),
  ('public.exam_substitution_commit_v1(uuid,uuid,uuid)')
)
select r.signature,
       to_regprocedure(r.signature) is not null as present,
       case when to_regprocedure(r.signature) is null then null
            else md5(pg_get_functiondef(to_regprocedure(r.signature))) end as body_md5,
       case when to_regprocedure(r.signature) is null then null
            else pg_get_userbyid(p.proowner) end as owner_name,
       case when to_regprocedure(r.signature) is null then null else p.prosecdef end as security_definer,
       case when to_regprocedure(r.signature) is null then null else coalesce(to_jsonb(p.proconfig),'null'::jsonb) end as config,
       case when to_regprocedure(r.signature) is null then null else coalesce(to_jsonb(p.proacl),'null'::jsonb) end as acl
from required r
left join pg_proc p on p.oid=to_regprocedure(r.signature)
order by r.signature;

select 'exam_wrapper_acl' as check_name,
       not has_function_privilege('anon','public.exam_substitution_options_v1(uuid,uuid)','execute')
       and not has_function_privilege('authenticated','public.exam_substitution_options_v1(uuid,uuid)','execute')
       and has_function_privilege('service_role','public.exam_substitution_options_v1(uuid,uuid)','execute')
       and not has_function_privilege('anon','public.exam_substitution_commit_v1(uuid,uuid,uuid)','execute')
       and not has_function_privilege('authenticated','public.exam_substitution_commit_v1(uuid,uuid,uuid)','execute')
       and has_function_privilege('service_role','public.exam_substitution_commit_v1(uuid,uuid,uuid)','execute') as ok;

select
  (select count(*) from public.esame_prove where stato='aperta') as open_exam_count,
  (select count(*) from combat_spatial.substitution_activity_links) as activity_links,
  (select count(*) from combat_spatial.substitution_activity_options) as activity_options,
  (select count(*) from combat_spatial.request_receipts where operation like '%substitution%') as substitution_receipts;

rollback;
