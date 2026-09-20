-- MISSION-RAPID-DB/2026-09-19.mvp1 · candidate only, no production apply.
begin;

do $preflight$
begin
 if to_regnamespace('mission_rapid_owner') is not null then
  raise exception 'MR_INSTALL_ALREADY_PRESENT' using errcode='55000';
 end if;
 if (select md5(prosrc) from pg_proc where oid='public.mission_creation_preflight_v2(jsonb)'::regprocedure)<>'2bfa56c88e45c52eb4495ee1f7c5d870'
 or (select md5(prosrc) from pg_proc where oid='public.mission_create_complete_v1(uuid,jsonb)'::regprocedure)<>'8a512021ec0335f6eddb8b859607b056'
 or (select md5(prosrc) from pg_proc where oid='public.png_builder_compile_v1(uuid,uuid,bigint,text)'::regprocedure)<>'13909ce28a3a4b32fd8b6fbd0a5c944a'
 or (select md5(prosrc) from pg_proc where oid='public.mission_generic_board_open_v1(uuid,uuid,uuid)'::regprocedure)<>'7efaab206f6b8f1fab92b72c848d5d72'
 or md5(pg_get_functiondef('mission_generic_owner.progress_step(uuid,uuid,uuid)'::regprocedure))<>'0bc40e0ff963c26a63e218f2aa95dd94'
 then raise exception 'MR_BASELINE_DRIFT' using errcode='40001';end if;
end $preflight$;

create schema mission_rapid_owner;
revoke all on schema mission_rapid_owner from public,anon,authenticated,service_role;
alter default privileges in schema mission_rapid_owner revoke execute on functions from public;

create table mission_rapid_owner.shared_function_baselines(
 signature text primary key,
 definition text not null,
 definition_md5 text not null check(definition_md5~'^[0-9a-f]{32}$'),
 installed_at timestamptz not null default clock_timestamp()
);
insert into mission_rapid_owner.shared_function_baselines(signature,definition,definition_md5)
select 'mission_generic_owner.progress_step(uuid,uuid,uuid)',pg_get_functiondef(p.oid),md5(pg_get_functiondef(p.oid))
from pg_proc p where p.oid='mission_generic_owner.progress_step(uuid,uuid,uuid)'::regprocedure;

create table mission_rapid_owner.authoring_policy(
 singleton boolean primary key default true check(singleton),
 enabled boolean not null default false,
 model text not null check(length(btrim(model)) between 1 and 120),
 reasoning_effort text not null check(reasoning_effort in('none','minimal','low','medium','high')),
 max_output_tokens integer not null check(max_output_tokens between 1200 and 12000),
 control_version bigint not null default 1 check(control_version>0)
);
insert into mission_rapid_owner.authoring_policy(singleton,enabled,model,reasoning_effort,max_output_tokens)
values(true,false,'CONFIGURE_BEFORE_ENABLE','medium',8000);

create table mission_rapid_owner.drafts(
 id uuid primary key default gen_random_uuid(),
 actor_user uuid not null references public.profiles(id),
 source jsonb not null check(jsonb_typeof(source)='object'),
 source_sha256 text not null check(source_sha256~'^[0-9a-f]{64}$'),
 compiled jsonb,
 document jsonb,
 document_sha256 text,
 state text not null check(state in('queued','claimed','draft','failed','published')),
 control_version bigint not null default 1 check(control_version>0),
 preview_seal text check(preview_seal is null or preview_seal~'^[0-9a-f]{64}$'),
 preview_basis jsonb,
 preview_at timestamptz,
 provider_calls integer not null default 0 check(provider_calls between 0 and 1),
 failure_code text,
 mission_id uuid references public.missions(id),
 plan_version_id uuid references public.mission_plan_versions(id),
 created_at timestamptz not null default clock_timestamp(),
 updated_at timestamptz not null default clock_timestamp(),
 check((compiled is null)=(state in('queued','claimed','failed'))),
 check((document is null)=(document_sha256 is null))
);
create index mission_rapid_drafts_actor_idx on mission_rapid_owner.drafts(actor_user,created_at desc);

create table mission_rapid_owner.requests(
 request_key uuid primary key,
 actor_user uuid not null references public.profiles(id),
 operation text not null check(operation in('compile_request','draft_save','preview','publish')),
 request_fingerprint text not null check(request_fingerprint~'^[0-9a-f]{64}$'),
 draft_id uuid references mission_rapid_owner.drafts(id),
 result jsonb not null,
 created_at timestamptz not null default clock_timestamp()
);

create table mission_rapid_owner.terminal_rules(
 mission_id uuid not null references public.missions(id),
 rule_key text not null check(rule_key~'^[a-z][a-z0-9_]{1,47}$'),
 phase_key text not null check(phase_key~'^[a-z][a-z0-9_]{1,47}$'),
 rule_type text not null check(rule_type in('victory','defeat','surrender_after_exchanges','escape','protect_subject','reach_position','survive_rounds')),
 subject_key text,
 threshold integer check(threshold between 1 and 99),
 outcome text not null check(outcome in('success','failure')),
 transition_key text,
 configuration jsonb not null check(jsonb_typeof(configuration)='object'),
 configuration_sha256 text not null check(configuration_sha256~'^[0-9a-f]{64}$'),
 active boolean not null default true,
 created_at timestamptz not null default clock_timestamp(),
 primary key(mission_id,rule_key),
 check((rule_type in('surrender_after_exchanges','survive_rounds'))=(threshold is not null)),
 check(rule_type<>'victory' or outcome='success'),
 check(rule_type<>'defeat' or outcome='failure'),
 check(rule_type not in('escape','protect_subject','reach_position') or subject_key~'^[a-z][a-z0-9_]{1,47}$')
);

create table mission_rapid_owner.recovery_receipts(
 publication_request uuid primary key,
 draft_id uuid not null references mission_rapid_owner.drafts(id),
 mission_id uuid not null references public.missions(id),
 plan_version_id uuid not null references public.mission_plan_versions(id),
 preview_seal text not null check(preview_seal~'^[0-9a-f]{64}$'),
 recovery_document jsonb not null check(jsonb_typeof(recovery_document)='object'),
 created_at timestamptz not null default clock_timestamp()
);

create table mission_rapid_owner.terminal_events(
 id uuid primary key,
 master_session_id uuid not null references public.master_v2_sessions(id),
 mission_id uuid not null references public.missions(id),
 rule_key text not null,
 event jsonb not null check(jsonb_typeof(event)='object'),
 event_sha256 text not null check(event_sha256~'^[0-9a-f]{64}$'),
 result jsonb not null check(jsonb_typeof(result)='object'),
 created_at timestamptz not null default clock_timestamp(),
 unique(master_session_id,id)
);

create table mission_rapid_owner.media_tickets(
 request_key uuid primary key,
 actor_user uuid not null references public.profiles(id),
 draft_id uuid not null references mission_rapid_owner.drafts(id),
 actor_key text not null check(actor_key~'^[a-z][a-z0-9_]{1,47}$'),
 bundle_id uuid not null,
 template_id uuid not null references public.nb_templates(id),
 template_version_id uuid not null,
 asset_key text not null unique check(asset_key~'^mr_[0-9a-f]{32}$'),
 asset_id text not null check(asset_id~'^[a-z0-9][a-z0-9_]{2,127}$'),
 object_path text not null unique check(object_path~'^ninja-book/[a-z0-9_]+/r[0-9]+/assets/[a-z0-9_]+_v[0-9]+\.(png|jpe?g|webp)$'),
 sha256 text not null check(sha256~'^[0-9a-f]{64}$'),
 bytes bigint not null check(bytes between 1 and 5242880),
 mime_type text not null check(mime_type in('image/png','image/jpeg','image/webp')),
 width_px integer,
 height_px integer,
 media_id uuid unique,
 result jsonb,
 expires_at timestamptz not null default clock_timestamp()+interval '30 minutes',
 created_at timestamptz not null default clock_timestamp(),
 check((media_id is null)=(result is null)),
 check((width_px is null)=(media_id is null)),
 check((height_px is null)=(media_id is null))
);
alter table mission_rapid_owner.media_tickets add constraint mission_rapid_media_template_version_fk foreign key(template_version_id,template_id) references public.nb_template_versions(id,template_id);

do $secure$
declare n text;
begin
 foreach n in array array['shared_function_baselines','authoring_policy','drafts','requests','terminal_rules','recovery_receipts','terminal_events','media_tickets'] loop
  execute format('alter table mission_rapid_owner.%I enable row level security',n);
  execute format('revoke all privileges on mission_rapid_owner.%I from public,anon,authenticated,service_role',n);
 end loop;
end $secure$;

create function mission_rapid_owner.sha(p jsonb) returns text
language sql immutable security definer set search_path='' as $fn$
 select encode(extensions.digest(convert_to(p::text,'UTF8'),'sha256'),'hex')
$fn$;

create function public.mission_rapid_media_ticket_v1(p_draft uuid,p_actor_key text,p_bundle uuid,p_request uuid,p_sha256 text,p_bytes bigint,p_mime text) returns jsonb
language plpgsql security definer set search_path='' as $fn$
declare actor uuid;d mission_rapid_owner.drafts;b png_builder_internal.bundles;t public.nb_templates;v public.nb_template_versions;old mission_rapid_owner.media_tickets;ext text;asset text;path text;fp text;res jsonb;
begin
 actor:=ninja_book_internal.require_staff(true);
 if not (select enabled from mission_rapid_owner.authoring_policy where singleton) then raise exception 'MR_AUTHORING_DISABLED' using errcode='55000';end if;
 if p_draft is null or p_request is null or coalesce(p_actor_key,'')!~'^[a-z][a-z0-9_]{1,47}$' or coalesce(p_sha256,'')!~'^[0-9a-f]{64}$'
 or coalesce(p_bytes,0) not between 1 and 5242880 or coalesce(p_mime,'') not in('image/png','image/jpeg','image/webp') then raise exception 'MR_MEDIA_INPUT' using errcode='22023';end if;
 select * into strict d from mission_rapid_owner.drafts where id=p_draft and actor_user=actor and state='draft';
 if not exists(select 1 from jsonb_array_elements(d.compiled->'actors') a where a->>'actor_key'=p_actor_key) then raise exception 'MR_MEDIA_ACTOR' using errcode='22023';end if;
 select * into strict b from png_builder_internal.bundles where id=p_bundle and status='certified' and disabled_at is null and ownership_mode='adopted';
 select * into strict t from public.nb_templates where id=b.template_id and current_version_id=b.narrative_version_id and lifecycle_state='approved';
 select * into strict v from public.nb_template_versions where id=b.narrative_version_id and template_id=b.template_id and review_state='approved';
 ext:=case p_mime when 'image/png' then 'png' when 'image/jpeg' then 'jpg' else 'webp' end;
 asset:='mr_'||replace(p_request::text,'-','');path:='ninja-book/'||t.template_key||'/r'||v.version_no||'/assets/'||asset||'_v1.'||ext;
 fp:=mission_rapid_owner.sha(jsonb_build_object('draft',p_draft,'actor_key',p_actor_key,'bundle',p_bundle,'sha256',p_sha256,'bytes',p_bytes,'mime',p_mime));
 perform pg_advisory_xact_lock(hashtextextended(p_request::text,19092029));
 select * into old from mission_rapid_owner.media_tickets where request_key=p_request;
 if found then
  if old.actor_user<>actor or old.draft_id<>p_draft or old.actor_key<>p_actor_key or old.bundle_id<>p_bundle or old.sha256<>p_sha256 or old.bytes<>p_bytes or old.mime_type<>p_mime then raise exception 'MR_MEDIA_REQUEST_CONFLICT' using errcode='40001';end if;
  if old.result is not null then return old.result||jsonb_build_object('schema_version','mission-rapid-media-ticket/1','request_key',old.request_key,'asset_key',old.asset_key,'bucket','avatars','object_path',old.object_path,'template_version_id',old.template_version_id,'registered',true);end if;
  return jsonb_build_object('schema_version','mission-rapid-media-ticket/1','request_key',old.request_key,'asset_key',old.asset_key,'bucket','avatars','object_path',old.object_path,'template_version_id',old.template_version_id,'registered',false);
 end if;
 insert into mission_rapid_owner.media_tickets(request_key,actor_user,draft_id,actor_key,bundle_id,template_id,template_version_id,asset_key,asset_id,object_path,sha256,bytes,mime_type)
 values(p_request,actor,p_draft,p_actor_key,p_bundle,b.template_id,b.narrative_version_id,asset,asset,path,p_sha256,p_bytes,p_mime);
 return jsonb_build_object('schema_version','mission-rapid-media-ticket/1','request_key',p_request,'asset_key',asset,'bucket','avatars','object_path',path,'template_version_id',b.narrative_version_id,'registered',false);
end $fn$;

create function public.mission_rapid_media_register_v1(p_request uuid,p_sha256 text,p_bytes bigint,p_mime text,p_width integer,p_height integer) returns jsonb
language plpgsql security definer set search_path='' as $fn$
declare x mission_rapid_owner.media_tickets;m public.nb_template_media_versions%rowtype;prior public.nb_template_media_versions%rowtype;version_no integer;res jsonb;obj_mime text;obj_bytes bigint;
begin
 if coalesce(auth.jwt()->>'role','')<>'service_role' then raise exception 'MR_MEDIA_SERVICE_REQUIRED' using errcode='42501';end if;
 if p_request is null or coalesce(p_width,0) not between 1 and 8192 or coalesce(p_height,0) not between 1 and 8192 then raise exception 'MR_MEDIA_DIMENSIONS' using errcode='22023';end if;
 select * into strict x from mission_rapid_owner.media_tickets where request_key=p_request for update;
 if x.result is not null then return x.result;end if;
 if x.expires_at<clock_timestamp() or x.sha256<>p_sha256 or x.bytes<>p_bytes or x.mime_type<>p_mime then raise exception 'MR_MEDIA_TICKET_MISMATCH' using errcode='40001';end if;
 select o.metadata->>'mimetype',(o.metadata->>'size')::bigint into obj_mime,obj_bytes from storage.objects o where o.bucket_id='avatars' and o.name=x.object_path;
 if not found or obj_mime is distinct from x.mime_type or obj_bytes is distinct from x.bytes then raise exception 'MR_MEDIA_STORAGE_DRIFT' using errcode='55000';end if;
 perform pg_advisory_xact_lock(hashtextextended(x.template_id::text,19092030));
 select * into prior from public.nb_template_media_versions where template_id=x.template_id and active for update;
 select coalesce(max(media_version_no),0)+1 into version_no from public.nb_template_media_versions where template_id=x.template_id;
 insert into public.nb_template_media_versions(template_id,template_version_id,media_version_no,supersedes_media_id,schema_version,asset_id,asset_version,kind,bucket,object_path,sha256,verified_sha256,mime_type,width_px,height_px,bytes,alt_text,provenance,lifecycle_state,active,created_by,reviewed_by,reviewed_at)
 values(x.template_id,x.template_version_id,version_no,prior.id,'ninja-book-media/1.1',x.asset_id,1,'canonical_full_body','avatars',x.object_path,x.sha256,x.sha256,x.mime_type,p_width,p_height,x.bytes,'Immagine missione per '||x.actor_key,jsonb_build_object('source_task','MISSION-RAPID-MEDIA-006','provider',jsonb_build_object('name','upload Staff'),'generated_at',current_date::text,'verification',jsonb_build_object('method','edge_server_bytes_sha256','verifier','png_media_attest_v1','human_reviewed',true)),'review',false,x.actor_user,x.actor_user,clock_timestamp()) returning * into m;
 res:=jsonb_build_object('schema_version','mission-rapid-media-registration/1','request_key',x.request_key,'asset_key',x.asset_key,'media_id',m.id,'template_version_id',m.template_version_id,'control_version',m.control_version,'sha256',m.sha256,'state','review_registered','replayed',false);
 update mission_rapid_owner.media_tickets set media_id=m.id,width_px=p_width,height_px=p_height,result=res where request_key=x.request_key;
 return res;
end $fn$;

create function mission_rapid_owner.validate_source(p jsonb) returns jsonb
language plpgsql immutable security definer set search_path='' as $fn$
declare ks text[];
begin
 if jsonb_typeof(p)<>'object' then raise exception 'MR_SOURCE_INVALID' using errcode='22023';end if;
 select array_agg(key order by key) into ks from jsonb_object_keys(p) key;
 if exists(select 1 from unnest(coalesce(ks,'{}')) k where k not in('plot','phase_hints','has_map_image','map_notes','png_uploads'))
 or jsonb_typeof(p->'plot')<>'string' or length(btrim(p->>'plot')) not between 1 and 24000
 or jsonb_typeof(coalesce(p->'phase_hints','[]'))<>'array' or jsonb_array_length(coalesce(p->'phase_hints','[]'))>8
 or jsonb_typeof(coalesce(p->'png_uploads','[]'))<>'array' or jsonb_array_length(coalesce(p->'png_uploads','[]'))>12
 or jsonb_typeof(coalesce(p->'has_map_image','false'::jsonb))<>'boolean'
 then raise exception 'MR_SOURCE_INVALID' using errcode='22023';end if;
 return p||jsonb_build_object('phase_hints',coalesce(p->'phase_hints','[]'::jsonb),'png_uploads',coalesce(p->'png_uploads','[]'::jsonb),'has_map_image',coalesce(p->'has_map_image','false'::jsonb),'map_notes',coalesce(p->'map_notes','""'::jsonb));
end $fn$;

create function mission_rapid_owner.validate_compiled(p jsonb) returns jsonb
language plpgsql immutable security definer set search_path='' as $fn$
declare m jsonb;ph jsonb;a jsonb;t jsonb;r jsonb;mp jsonb;
begin
 if jsonb_typeof(p)<>'object' or p->>'schema_version'<>'mission-authoring-output/1'
 or jsonb_typeof(p->'mission')<>'object' or jsonb_typeof(p->'phases')<>'array'
 or jsonb_array_length(p->'phases') not between 1 and 8 or jsonb_typeof(p->'actors')<>'array'
 or jsonb_array_length(p->'actors')>12 or jsonb_typeof(p->'terminal_rules')<>'array'
 or jsonb_array_length(p->'terminal_rules')>16 or jsonb_typeof(p->'map_request')<>'object'
 or p::text ~* '"(stats|statistics|pv|hp|chakra|techniques|tecniche|jutsu|chakra_cost|damage|danno|potenza|disciplina)"[[:space:]]*:'
 then raise exception 'MR_COMPILED_INVALID' using errcode='22023';end if;
 m:=p->'mission';mp:=p->'map_request';
 if not mission_generic_owner.keys_valid(m,array['title','grade','team_min','team_max','briefing_public','background_private','narrator_instructions','opening'])
 or coalesce(m->>'grade','') not in('D','C','B','A','S')
 or jsonb_typeof(m->'team_min')<>'number' or jsonb_typeof(m->'team_max')<>'number'
 or (m->>'team_min')::numeric<>trunc((m->>'team_min')::numeric) or (m->>'team_max')::numeric<>trunc((m->>'team_max')::numeric)
 or (m->>'team_min')::integer not between 1 and 4 or (m->>'team_max')::integer not between (m->>'team_min')::integer and 4
 or nullif(btrim(m->>'title'),'') is null or nullif(btrim(m->>'briefing_public'),'') is null
 or not mission_generic_owner.keys_valid(mp,array['mode','width_cells','height_cells','important_objects','notes'])
 or coalesce(mp->>'mode','') not in('default10','specific') or jsonb_typeof(mp->'important_objects')<>'array'
 or (mp->>'mode'='default10' and (mp->'width_cells'<>'null'::jsonb or mp->'height_cells'<>'null'::jsonb))
 or (mp->>'mode'='specific' and (coalesce((mp->>'width_cells')::integer,0) not between 4 and 40 or coalesce((mp->>'height_cells')::integer,0) not between 4 and 40))
 then raise exception 'MR_COMPILED_MISSION_INVALID' using errcode='22023';end if;
 for a in select value from jsonb_array_elements(p->'actors') loop
  if not mission_generic_owner.keys_valid(a,array['actor_key','display_name','role','team','identity','personality','behavior','public_knowledge','private_knowledge','limits','mechanical_request'])
  or coalesce(a->>'actor_key','')!~'^[a-z][a-z0-9_]{1,47}$' or nullif(btrim(a->>'display_name'),'') is null
  or coalesce(a->>'team','') not in('alleati','avversari','civili')
  or jsonb_typeof(a->'public_knowledge')<>'array' or jsonb_typeof(a->'private_knowledge')<>'array' or jsonb_typeof(a->'limits')<>'array'
  or not mission_generic_owner.keys_valid(a->'mechanical_request',array['archetype_tags','combat_role','desired_grade'])
  or coalesce(a#>>'{mechanical_request,desired_grade}','') not in('D','C','B','A','S')
  then raise exception 'MR_COMPILED_ACTOR_INVALID' using errcode='22023';end if;
 end loop;
 for ph in select value from jsonb_array_elements(p->'phases') loop
  if not mission_generic_owner.keys_valid(ph,array['step_key','title','kind','public_objective','private_objective','narrator_notes','actor_keys','transitions'])
  or coalesce(ph->>'step_key','')!~'^[a-z][a-z0-9_]{1,47}$' or coalesce(ph->>'kind','') not in('narrative','exploration','combat')
  or jsonb_typeof(ph->'actor_keys')<>'array' or jsonb_typeof(ph->'transitions')<>'array'
  or exists(select 1 from jsonb_array_elements_text(ph->'actor_keys') k where not exists(select 1 from jsonb_array_elements(p->'actors') x where x->>'actor_key'=k))
  then raise exception 'MR_COMPILED_PHASE_INVALID' using errcode='22023';end if;
  for t in select value from jsonb_array_elements(ph->'transitions') loop
   if not mission_generic_owner.keys_valid(t,array['transition_key','to_step_key','when','public_result','private_note'])
   or coalesce(t->>'transition_key','')!~'^[a-z][a-z0-9_]{1,47}$' or left(t->>'transition_key',3)='mr_'
   or (t->>'to_step_key' is not null and not exists(select 1 from jsonb_array_elements(p->'phases') x where x->>'step_key'=t->>'to_step_key'))
   then raise exception 'MR_COMPILED_TRANSITION_INVALID' using errcode='22023';end if;
  end loop;
 end loop;
 for r in select value from jsonb_array_elements(p->'terminal_rules') loop
  if not mission_generic_owner.keys_valid(r,array['rule_key','phase_key','type','subject_key','threshold','outcome','transition_key'])
  or coalesce(r->>'rule_key','')!~'^[a-z][a-z0-9_]{1,47}$'
  or coalesce(r->>'type','') not in('victory','defeat','surrender_after_exchanges','escape','protect_subject','reach_position','survive_rounds')
  or coalesce(r->>'outcome','') not in('success','failure')
  or (r->>'type'='victory' and r->>'outcome'<>'success')
  or (r->>'type'='defeat' and r->>'outcome'<>'failure')
  or (r->>'type' in('escape','protect_subject','reach_position') and coalesce(r->>'subject_key','')!~'^[a-z][a-z0-9_]{1,47}$')
  or not exists(select 1 from jsonb_array_elements(p->'phases') x where x->>'step_key'=r->>'phase_key')
  or not exists(select 1 from jsonb_array_elements(p->'phases') x where x->>'step_key'=r->>'phase_key' and x->>'kind'='combat')
  or (r->>'type'='escape' and not exists(select 1 from jsonb_array_elements(p->'actors') x where x->>'actor_key'=r->>'subject_key'))
  or ((r->>'type' in('surrender_after_exchanges','survive_rounds')) is distinct from (r->'threshold' is not null and r->'threshold'<>'null'::jsonb))
  or (r->>'type' in('surrender_after_exchanges','survive_rounds') and (jsonb_typeof(r->'threshold')<>'number'
    or (r->>'threshold')::numeric<>trunc((r->>'threshold')::numeric)
    or (r->>'threshold')::integer not between 1 and 99))
  then raise exception 'MR_COMPILED_RULE_INVALID' using errcode='22023';end if;
 end loop;
 if exists(select 1 from jsonb_array_elements(p->'actors') actor_item group by actor_item->>'actor_key' having count(*)>1)
 or exists(select 1 from jsonb_array_elements(p->'phases') phase_item group by phase_item->>'step_key' having count(*)>1)
 or exists(select 1 from jsonb_array_elements(p->'terminal_rules') rule_item group by rule_item->>'rule_key' having count(*)>1)
 or exists(select 1 from jsonb_array_elements(p->'phases') phase_item,lateral jsonb_array_elements(phase_item->'transitions') transition_item group by transition_item->>'transition_key' having count(*)>1)
 or exists(select 1 from jsonb_array_elements(p->'phases') phase_item where phase_item->>'step_key' in('rapid_success','rapid_failure'))
 then raise exception 'MR_COMPILED_DUPLICATE_KEY' using errcode='22023';end if;
 if exists(select 1 from jsonb_array_elements(p->'terminal_rules') rule_item
  where rule_item->>'type' in('surrender_after_exchanges','escape','protect_subject','reach_position','survive_rounds')
  group by rule_item->>'phase_key' having count(*)>1)
 then raise exception 'MR_COMPILED_NATIVE_RULE_AMBIGUOUS' using errcode='22023';end if;
 return p;
end $fn$;

create function public.mission_rapid_compile_request_v1(p_request uuid,p_source jsonb) returns jsonb
language plpgsql security definer set search_path='' as $fn$
declare src jsonb;fp text;old mission_rapid_owner.requests;did uuid;res jsonb;
begin
 perform mission_ai_board_owner.staff_only();
 if p_request is null then raise exception 'MR_REQUEST_REQUIRED' using errcode='22023';end if;
 src:=mission_rapid_owner.validate_source(p_source);fp:=mission_rapid_owner.sha(jsonb_build_object('op','compile_request','source',src));
 perform pg_advisory_xact_lock(hashtextextended(p_request::text,19092026));
 select * into old from mission_rapid_owner.requests where request_key=p_request;
 if found then if old.actor_user<>auth.uid() or old.operation<>'compile_request' or old.request_fingerprint<>fp then raise exception 'MR_REQUEST_CONFLICT' using errcode='40001';end if;return old.result;end if;
 insert into mission_rapid_owner.drafts(actor_user,source,source_sha256,state) values(auth.uid(),src,mission_rapid_owner.sha(src),'queued') returning id into did;
 res:=jsonb_build_object('schema_version','mission-rapid-compile-request/1','request_key',p_request,'draft_id',did,'state','queued','control_version',1);
 insert into mission_rapid_owner.requests values(p_request,auth.uid(),'compile_request',fp,did,res,clock_timestamp());return res;
end $fn$;

create function public.mission_rapid_compile_state_v1(p_request uuid) returns jsonb
language plpgsql stable security definer set search_path='' as $fn$
declare d mission_rapid_owner.drafts;
begin
 perform mission_ai_board_owner.staff_only();
 select x.* into strict d from mission_rapid_owner.drafts x join mission_rapid_owner.requests r on r.draft_id=x.id where r.request_key=p_request and r.operation='compile_request' and r.actor_user=auth.uid();
 return jsonb_build_object('schema_version','mission-rapid-compile-state/1','draft_id',d.id,'state',d.state,'control_version',d.control_version,'source',d.source,'compiled',d.compiled,'failure_code',d.failure_code);
end $fn$;

create function public.mission_rapid_compile_claim_v1(p_user uuid,p_request uuid) returns jsonb
language plpgsql security definer set search_path='' as $fn$
declare d mission_rapid_owner.drafts;pol mission_rapid_owner.authoring_policy;
begin
 select * into strict pol from mission_rapid_owner.authoring_policy where singleton for share;
 if not pol.enabled then raise exception 'MR_AUTHORING_DISABLED' using errcode='55000';end if;
 select x.* into strict d from mission_rapid_owner.drafts x join mission_rapid_owner.requests r on r.draft_id=x.id where r.request_key=p_request and r.actor_user=p_user and r.operation='compile_request' for update of x;
 if d.state='draft' then return jsonb_build_object('state','completed','result',jsonb_build_object('schema_version','mission-rapid-compile-result/1','draft_id',d.id,'control_version',d.control_version,'source',d.source,'compiled',d.compiled));end if;
 if d.state<>'queued' then raise exception 'MR_COMPILE_NOT_CLAIMABLE' using errcode='55000';end if;
 update mission_rapid_owner.drafts set state='claimed',updated_at=clock_timestamp() where id=d.id;
 return jsonb_build_object('state','claimed','request_key',p_request,'draft_id',d.id,'source',d.source,'policy',jsonb_build_object('model',pol.model,'reasoning_effort',pol.reasoning_effort,'max_output_tokens',pol.max_output_tokens));
end $fn$;

create function public.mission_rapid_compile_complete_v1(p_user uuid,p_request uuid,p_document jsonb,p_telemetry jsonb) returns jsonb
language plpgsql security definer set search_path='' as $fn$
declare d mission_rapid_owner.drafts;doc jsonb;res jsonb;
begin
 doc:=mission_rapid_owner.validate_compiled(p_document);
 select x.* into strict d from mission_rapid_owner.drafts x join mission_rapid_owner.requests r on r.draft_id=x.id where r.request_key=p_request and r.actor_user=p_user and r.operation='compile_request' for update of x;
 if d.state='draft' then return jsonb_build_object('schema_version','mission-rapid-compile-result/1','draft_id',d.id,'state','draft','control_version',d.control_version,'source',d.source,'compiled',d.compiled);end if;
 if d.state<>'claimed' or coalesce((p_telemetry->>'provider_calls')::int,-1)<>1
 or doc#>>'{map_request,mode}' is distinct from (case when (d.source->>'has_map_image')::boolean then 'specific' else 'default10' end)
 then raise exception 'MR_COMPILE_STATE' using errcode='55000';end if;
 update mission_rapid_owner.drafts set compiled=doc,document=jsonb_build_object('schema_version','mission-rapid-draft/1','source',source,'compiled',doc,'configuration',jsonb_build_object()),document_sha256=mission_rapid_owner.sha(jsonb_build_object('schema_version','mission-rapid-draft/1','source',source,'compiled',doc,'configuration',jsonb_build_object())),state='draft',provider_calls=1,control_version=control_version+1,updated_at=clock_timestamp() where id=d.id returning control_version into d.control_version;
 return jsonb_build_object('schema_version','mission-rapid-compile-result/1','draft_id',d.id,'state','draft','control_version',d.control_version,'source',d.source,'compiled',doc);
end $fn$;

create function public.mission_rapid_compile_reject_v1(p_user uuid,p_request uuid,p_code text,p_provider_calls integer) returns jsonb
language plpgsql security definer set search_path='' as $fn$
declare did uuid;
begin
 if p_provider_calls not between 0 and 1 or nullif(btrim(p_code),'') is null then raise exception 'MR_REJECT_INVALID' using errcode='22023';end if;
 select x.id into strict did from mission_rapid_owner.drafts x join mission_rapid_owner.requests r on r.draft_id=x.id where r.request_key=p_request and r.actor_user=p_user and r.operation='compile_request' for update of x;
 update mission_rapid_owner.drafts set state='failed',failure_code=left(p_code,120),provider_calls=p_provider_calls,updated_at=clock_timestamp() where id=did and state='claimed';
 return jsonb_build_object('schema_version','mission-rapid-compile-reject/1','draft_id',did,'state','failed');
end $fn$;

create function mission_rapid_owner.validate_draft(p_document jsonb,p_source jsonb) returns jsonb
language plpgsql stable security definer set search_path='' as $fn$
declare c jsonb;src jsonb;cmp jsonb;b jsonb;seen text[]:='{}';actor_count integer;
begin
 if jsonb_typeof(p_document)<>'object' or p_document->>'schema_version'<>'mission-rapid-draft/1'
 or jsonb_typeof(p_document->'configuration')<>'object' then raise exception 'MR_DRAFT_SHAPE' using errcode='22023';end if;
 src:=mission_rapid_owner.validate_source(p_document->'source');
 cmp:=mission_rapid_owner.validate_compiled(p_document->'compiled');
 if src is distinct from p_source
 or cmp#>>'{map_request,mode}' is distinct from (case when (src->>'has_map_image')::boolean then 'specific' else 'default10' end)
 then raise exception 'MR_DRAFT_SOURCE_DRIFT' using errcode='40001';end if;
 c:=p_document->'configuration';
 if jsonb_typeof(c->'actor_bindings')<>'array' or jsonb_typeof(c->'map')<>'object' or jsonb_typeof(c->'budget')<>'object'
 or nullif(c->>'gathering_location_id','') is null or not exists(select 1 from public.locations where id=(c->>'gathering_location_id')::uuid and is_active and not coalesce(is_exam_room,false))
 then raise exception 'MR_CONFIGURATION_INVALID' using errcode='22023';end if;
 actor_count:=jsonb_array_length(cmp->'actors');
 if jsonb_array_length(c->'actor_bindings')<>actor_count then raise exception 'MR_ACTOR_BINDING_COUNT' using errcode='22023';end if;
 for b in select value from jsonb_array_elements(c->'actor_bindings') loop
  if jsonb_typeof(b)<>'object' or not mission_generic_owner.keys_valid(b,array['actor_key','team','approved','base_bundle_id','media_id'])
  or coalesce(b->>'actor_key','')!~'^[a-z][a-z0-9_]{1,47}$'
  or coalesce(b->>'team','') not in('alleati','avversari','civili') or jsonb_typeof(b->'approved')<>'boolean'
  or coalesce(b->>'base_bundle_id','')!~'^[0-9a-f-]{36}$' or coalesce(b->>'media_id','')!~'^[0-9a-f-]{36}$'
  or not exists(select 1 from jsonb_array_elements(cmp->'actors') x where x->>'actor_key'=b->>'actor_key')
  then raise exception 'MR_ACTOR_BINDING_INVALID' using errcode='22023';end if;
  if b->>'actor_key'=any(seen) then raise exception 'MR_ACTOR_BINDING_DUPLICATE' using errcode='22023';end if;seen:=seen||(b->>'actor_key');
 end loop;
 if coalesce(c#>>'{map,mode}','') not in('default10','specific') then raise exception 'MR_MAP_MODE' using errcode='22023';end if;
 if c#>>'{map,mode}'='specific' and (nullif(c#>>'{map,template_key}','') is null or coalesce((c#>>'{map,template_version}')::int,0)<1
 or jsonb_typeof(c#>'{map,spec}')<>'object' or c#>>'{map,spec,template_key}' is distinct from c#>>'{map,template_key}') then raise exception 'MR_MAP_SPEC' using errcode='22023';end if;
 if coalesce((c#>>'{budget,max_calls}')::int,0) not between 1 and 64
 or coalesce((c#>>'{budget,max_input_tokens}')::int,0) not between 1 and 49152
 or coalesce((c#>>'{budget,max_output_tokens}')::int,0) not between 1 and 20000
 or coalesce((c#>>'{budget,max_cost_usd}')::numeric,0)<=0 then raise exception 'MR_BUDGET_INVALID' using errcode='22023';end if;
 return jsonb_set(jsonb_set(p_document,'{source}',src,true),'{compiled}',cmp,true);
end $fn$;

create function mission_rapid_owner.budget_snapshot(p_budget jsonb) returns jsonb
language plpgsql stable security definer set search_path='' as $fn$
declare g mission_generic_owner.runtime_policy;n mission_narrative_internal.runtime_policy;
begin
 select * into strict g from mission_generic_owner.runtime_policy where singleton;
 select * into strict n from mission_narrative_internal.runtime_policy where singleton;
 if g.mode not in('test','all') or g.provider_max_calls is null or g.provider_max_cost_usd is null
 or (p_budget->>'max_calls')::integer<>g.provider_max_calls
 or (p_budget->>'max_cost_usd')::numeric<>g.provider_max_cost_usd
 or (p_budget->>'max_input_tokens')::integer<>n.max_input_tokens
 or (p_budget->>'max_output_tokens')::integer<>n.max_output_tokens
 then raise exception 'MR_BUDGET_RUNTIME_MISMATCH' using errcode='55000';end if;
 return jsonb_build_object('mode',g.mode,'max_calls',g.provider_max_calls,'max_cost_usd',g.provider_max_cost_usd,
  'max_input_tokens',n.max_input_tokens,'max_output_tokens',n.max_output_tokens,
  'generic_policy_sha256',mission_rapid_owner.sha(jsonb_build_object('mode',g.mode,'max_calls',g.provider_max_calls,'max_cost_usd',g.provider_max_cost_usd)),
  'narrative_policy_version',n.policy_version);
end $fn$;

create function mission_rapid_owner.preview_for(p_draft mission_rapid_owner.drafts) returns jsonb
language plpgsql security definer set search_path='' as $fn$
declare c jsonb:=p_draft.document->'configuration';binding jsonb;actor jsonb;rule jsonb;mapspec jsonb;mapdetail jsonb;mappreview jsonb;b png_builder_internal.bundles;mb public.nb_mechanical_bindings;mv public.nb_mechanical_versions;m png_media_internal.attestations;rm mission_rapid_owner.media_tickets;errors jsonb:='[]';cards jsonb:='[]';images jsonb:='[]';mapview jsonb;budgetview jsonb;basis jsonb;mechanical_profile jsonb;seal text;ref_count integer;
begin
 perform mission_rapid_owner.validate_draft(p_draft.document,p_draft.source);
 for binding in select value from jsonb_array_elements(c->'actor_bindings') loop
  select * into b from png_builder_internal.bundles where id=(binding->>'base_bundle_id')::uuid and status='certified' and disabled_at is null;
  if not found then errors:=errors||jsonb_build_array(jsonb_build_object('code','BUNDLE_NOT_CERTIFIED','actor_key',binding->>'actor_key'));
  else
  if b.ownership_mode<>'adopted' then errors:=errors||jsonb_build_array(jsonb_build_object('code','BUNDLE_NOT_ACTIVE','actor_key',binding->>'actor_key'));end if;
   mb:=null;mv:=null;mechanical_profile:=null;
   select * into mb from public.nb_mechanical_bindings where id=(b.certified_payload->>'mechanical_binding_id')::uuid and narrative_template_id=b.template_id and narrative_version_id=b.narrative_version_id and lifecycle_state='approved' and active;
   if not found then errors:=errors||jsonb_build_array(jsonb_build_object('code','MECHANICS_NOT_APPROVED','actor_key',binding->>'actor_key'));
   else
    select * into mv from public.nb_mechanical_versions where id=mb.mechanical_version_id and template_id=mb.mechanical_template_id and review_state='approved';
    if not found then errors:=errors||jsonb_build_array(jsonb_build_object('code','MECHANICS_NOT_APPROVED','actor_key',binding->>'actor_key'));
    else mechanical_profile:=jsonb_build_object('binding_id',mb.id,'version_id',mv.id,'rank',mv.rank,'archetype',mv.archetype,'stats',mv.stats,'vita_max',mv.vita_max,'chakra_max',mv.chakra_max,'abilities',mv.abilities);end if;
   end if;
   if coalesce((binding->>'approved')::boolean,false) is not true then errors:=errors||jsonb_build_array(jsonb_build_object('code','PNG_UNAPPROVED','actor_key',binding->>'actor_key'));end if;
   m:=null;rm:=null;
   select * into m from png_media_internal.attestations where media_id=(binding->>'media_id')::uuid;
   if not found then select * into rm from mission_rapid_owner.media_tickets where media_id=(binding->>'media_id')::uuid;end if;
   if m.media_id is null and rm.media_id is null then errors:=errors||jsonb_build_array(jsonb_build_object('code','MEDIA_MISSING','actor_key',binding->>'actor_key'));
   elsif coalesce(m.template_id,rm.template_id)<>b.template_id or coalesce(m.template_version_id,rm.template_version_id)<>b.narrative_version_id
    or not exists(select 1 from public.nb_template_media_versions q where q.id=(binding->>'media_id')::uuid and q.lifecycle_state='approved' and q.active)
   then errors:=errors||jsonb_build_array(jsonb_build_object('code','MEDIA_TEMPLATE_MISMATCH','actor_key',binding->>'actor_key'));end if;
   select value into actor from jsonb_array_elements(p_draft.compiled->'actors') where value->>'actor_key'=binding->>'actor_key';
   cards:=cards||jsonb_build_array(jsonb_build_object('actor_key',binding->>'actor_key','editorial',actor,'team',binding->>'team','base_bundle_id',b.id,'mechanics',b.certified_payload,'mechanical_profile',mechanical_profile,'approved',binding->'approved'));
   if coalesce(m.media_id,rm.media_id) is not null then images:=images||jsonb_build_array(jsonb_build_object('actor_key',binding->>'actor_key','media_id',coalesce(m.media_id,rm.media_id),'sha256',coalesce(m.sha256,rm.sha256),'mime_type',coalesce(m.mime_type,rm.mime_type),'object_path',coalesce(m.object_path,rm.object_path)));end if;
  end if;
 end loop;
 begin
  if c#>>'{map,mode}'='default10' then
   mapdetail:=public.mission_map_detail_v1('mission_map_bind_3ac00867783c8910b81a43b61015ce0b',1);
  else
   mapdetail:=public.mission_map_detail_v1(c#>>'{map,template_key}',(c#>>'{map,template_version}')::integer);
  end if;
  mapspec:=mapdetail->'spec';
  if mapdetail->>'schema_version' is distinct from 'mission-map-detail/1' or mapdetail->>'status' is distinct from 'ready'
   or coalesce((mapdetail->>'selectable')::boolean,false) is not true
   or (c#>>'{map,mode}'='specific' and mapspec is distinct from c#>'{map,spec}')
  then errors:=errors||jsonb_build_array(jsonb_build_object('code','MAP_INVALID','detail','catalog_or_spec_drift'));
  else
   mapspec:=jsonb_set(mapspec,'{suggested_entries}',(select coalesce(jsonb_agg(value||jsonb_build_object('x_m',((value->>'x_m')::numeric)::integer,'y_m',((value->>'y_m')::numeric)::integer) order by ordinality),'[]'::jsonb) from jsonb_array_elements(mapspec->'suggested_entries') with ordinality),false);
   mappreview:=public.mission_map_preview_v1(mapspec,(p_draft.compiled#>>'{mission,team_max}')::int,jsonb_array_length(p_draft.compiled->'actors'));
   if coalesce((mappreview->>'valid')::boolean,false) is not true
   then errors:=errors||jsonb_build_array(jsonb_build_object('code','MAP_INVALID','detail',mappreview->'errors'));
   elsif coalesce((mappreview->>'can_fit')::boolean,false) is not true
   then errors:=errors||jsonb_build_array(jsonb_build_object('code','MAP_CAPACITY','detail',jsonb_build_object('capacity_16',mappreview->'capacity_16','requested_pg',mappreview->'requested_pg','requested_png',mappreview->'requested_png')));
   end if;
  end if;
  mapview:=mapdetail||jsonb_build_object('spec',mapspec,'validation',mappreview);
 exception when others then errors:=errors||jsonb_build_array(jsonb_build_object('code','MAP_INVALID','detail',sqlstate));mapspec:=null;mapview:=null;end;
 for rule in select value from jsonb_array_elements(p_draft.compiled->'terminal_rules') where value->>'type' in('escape','protect_subject','reach_position') loop
  if rule->>'type'='escape' and not exists(select 1 from jsonb_array_elements(p_draft.compiled->'phases') ph,jsonb_array_elements_text(ph->'actor_keys') ak where ph->>'step_key'=rule->>'phase_key' and ak=rule->>'subject_key') then
   errors:=errors||jsonb_build_array(jsonb_build_object('code','REFERENCE_INVALID','rule_key',rule->>'rule_key','detail','escape_actor_not_in_phase'));
  elsif rule->>'type'='reach_position' and not exists(select 1 from jsonb_array_elements(coalesce(mapspec->'objects','[]'::jsonb)) o where o->>'object_key'=rule->>'subject_key') then
   errors:=errors||jsonb_build_array(jsonb_build_object('code','REFERENCE_INVALID','rule_key',rule->>'rule_key','detail','target_object_missing'));
  elsif rule->>'type'='protect_subject' then
   select (case when exists(select 1 from jsonb_array_elements(p_draft.compiled->'phases') ph,jsonb_array_elements_text(ph->'actor_keys') ak where ph->>'step_key'=rule->>'phase_key' and ak=rule->>'subject_key') then 1 else 0 end)
    +(case when exists(select 1 from jsonb_array_elements(coalesce(mapspec->'objects','[]'::jsonb)) o where o->>'object_key'=rule->>'subject_key') then 1 else 0 end) into ref_count;
   if ref_count<>1 then errors:=errors||jsonb_build_array(jsonb_build_object('code','REFERENCE_INVALID','rule_key',rule->>'rule_key','detail','protected_subject_missing_or_ambiguous'));end if;
  end if;
 end loop;
 begin budgetview:=mission_rapid_owner.budget_snapshot(c->'budget');
 exception when others then errors:=errors||jsonb_build_array(jsonb_build_object('code','BUDGET_RUNTIME_MISMATCH','detail',sqlstate));budgetview:=null;end;
 basis:=jsonb_build_object('draft_id',p_draft.id,'draft_version',p_draft.control_version,'document_sha256',p_draft.document_sha256,'actors',cards,'images',images,'map',mapview,'terminal_rules',p_draft.compiled->'terminal_rules','budget',budgetview,
 'catalog',jsonb_build_object('mission_preflight_md5',(select md5(prosrc) from pg_proc where oid='public.mission_creation_preflight_v2(jsonb)'::regprocedure),'png_compile_md5',(select md5(prosrc) from pg_proc where oid='public.png_builder_compile_v1(uuid,uuid,bigint,text)'::regprocedure)));
 if errors='[]'::jsonb then seal:=mission_rapid_owner.sha(basis);end if;
 return jsonb_build_object('schema_version','mission-rapid-preview/1','draft_id',p_draft.id,'draft_version',p_draft.control_version,'incipit',p_draft.compiled#>>'{mission,opening}','phases',p_draft.compiled->'phases','actors',cards,'images',images,'map',mapview,'terminal_rules',p_draft.compiled->'terminal_rules','budget',budgetview,'errors',errors,'preview_seal',seal,'basis',basis);
end $fn$;

create function mission_rapid_owner.stable_key(p_prefix text,p_value jsonb) returns text
language sql immutable security definer set search_path='' as $fn$
 select left(p_prefix,12)||left(mission_rapid_owner.sha(p_value),24)
$fn$;

create function mission_rapid_owner.rule_transition(p_rule jsonb) returns text
language sql immutable security definer set search_path='' as $fn$
 select case p_rule->>'type'
  when 'victory' then mission_rapid_owner.stable_key('mr_win_',jsonb_build_object('phase',p_rule->>'phase_key'))
  when 'defeat' then mission_rapid_owner.stable_key('mr_loss_',jsonb_build_object('phase',p_rule->>'phase_key'))
  else mission_rapid_owner.stable_key('mr_rule_',p_rule) end
$fn$;

create function mission_rapid_owner.actor_refs(p_draft mission_rapid_owner.drafts) returns jsonb
language plpgsql stable security definer set search_path='' as $fn$
declare binding jsonb;b png_builder_internal.bundles;ref jsonb;refs jsonb:='[]';
begin
 for binding in select value from jsonb_array_elements(p_draft.document#>'{configuration,actor_bindings}') loop
  select * into strict b from png_builder_internal.bundles where id=(binding->>'base_bundle_id')::uuid
   and status='certified' and disabled_at is null and ownership_mode='adopted';
  if b.mechanical_binding_id is null or not exists(select 1 from public.nb_mechanical_bindings x where x.id=b.mechanical_binding_id and x.lifecycle_state='approved' and x.active)
  then raise exception 'MR_BASE_PROFILE_NOT_APPROVED' using errcode='22023';end if;
  ref:=jsonb_build_object('actor_key',binding->>'actor_key','team',binding->>'team',
   'narrative_template_id',b.template_id,'narrative_version_id',b.narrative_version_id,
   'mechanical_binding_id',b.mechanical_binding_id);
  refs:=refs||jsonb_build_array(ref);
 end loop;
 return refs;
end $fn$;

create function mission_rapid_owner.technical_document(p_draft mission_rapid_owner.drafts,p_refs jsonb) returns jsonb
language plpgsql stable security definer set search_path='' as $fn$
declare c jsonb:=p_draft.document->'configuration';m jsonb:=p_draft.compiled->'mission';phase jsonb;actor jsonb;tr jsonb;rule jsonb;
 steps jsonb:='[]';scenes jsonb:='[]';transitions jsonb:='[]';editorial_scenes jsonb:='[]';arenas jsonb:='[]';
 phase_actors jsonb;scene_actors jsonb;editorial_actors jsonb;triggers jsonb;consequences jsonb;encounters jsonb;
 step_key text;next_key text;kind text;auto_key text;fail_key text;win_key text;loss_key text;draw_key text;target text;
 ord integer;setting_name text;setting_description text;
begin
 setting_name:=coalesce(nullif(btrim(c#>>'{map,name}'),''),'Ambientazione della missione');
 setting_description:=coalesce(nullif(btrim(c#>>'{map,description}'),''),nullif(btrim(p_draft.compiled#>>'{map_request,notes}'),''),
  case when c#>>'{map,mode}'='default10' then 'Mappa ordinaria 10×10 configurata dal server.' else 'Mappa specifica configurata dall’editore.' end);
 for phase,ord in select value,ordinality::integer from jsonb_array_elements(p_draft.compiled->'phases') with ordinality loop
  step_key:=phase->>'step_key';kind:=case when phase->>'kind'='combat' then 'mechanical' else 'narrative' end;
  select value->>'step_key' into next_key from jsonb_array_elements(p_draft.compiled->'phases') with ordinality x(value,n) where n=ord+1;
  next_key:=coalesce(next_key,'rapid_success');
  select coalesce(jsonb_agg(r.value order by r.ordinality),'[]'::jsonb) into phase_actors
   from jsonb_array_elements(p_refs) with ordinality r(value,ordinality)
   where r.value->>'actor_key' in(select jsonb_array_elements_text(phase->'actor_keys'));
  scene_actors:=phase_actors;
  select coalesce(jsonb_agg(jsonb_build_object('actor_key',a.value->>'actor_key','role_in_phase',q.editorial_actor->>'role',
    'goal_private',phase->>'private_objective','known_facts_private',concat_ws(E'\n',q.editorial_actor->>'behavior',
      (select string_agg(value,E'\n') from jsonb_array_elements_text(q.editorial_actor->'private_knowledge')),
      (select string_agg(value,E'\n') from jsonb_array_elements_text(q.editorial_actor->'limits'))),
    'public_portrayal',concat_ws(' · ',q.editorial_actor->>'identity',q.editorial_actor->>'personality')) order by a.ordinality),'[]'::jsonb)
   into editorial_actors from jsonb_array_elements(phase_actors) with ordinality a(value,ordinality)
   join lateral (select value from jsonb_array_elements(p_draft.compiled->'actors') x(value) where x.value->>'actor_key'=a.value->>'actor_key') q(editorial_actor) on true;
  triggers:='[]';consequences:='[]';encounters:='[]';
  auto_key:=mission_rapid_owner.stable_key('mr_auto_',jsonb_build_object('phase',step_key));
  fail_key:=mission_rapid_owner.stable_key('mr_fail_',jsonb_build_object('phase',step_key));
  if kind='mechanical' then
   select coalesce(jsonb_agg(case when value->>'team' in('alleati','civili')
      then jsonb_set(value,'{team}',to_jsonb('squadra'::text),true) else value end order by ordinality),'[]'::jsonb)
    into scene_actors from jsonb_array_elements(phase_actors) with ordinality x(value,ordinality);
   if not exists(select 1 from jsonb_array_elements(scene_actors) x where x->>'team'='avversari')
   then raise exception 'MR_COMBAT_REQUIRES_OPPOSITION:%',step_key using errcode='22023';end if;
   win_key:=mission_rapid_owner.stable_key('mr_win_',jsonb_build_object('phase',step_key));
   loss_key:=mission_rapid_owner.stable_key('mr_loss_',jsonb_build_object('phase',step_key));
   draw_key:=mission_rapid_owner.stable_key('mr_draw_',jsonb_build_object('phase',step_key));
   encounters:=jsonb_build_array(jsonb_build_object('encounter_key','enc_'||step_key,'pg_policy','all_active','pg_team','squadra','actors',scene_actors,'arena_ref','mission'));
   triggers:=jsonb_build_array(
    jsonb_build_object('trigger_key','win_'||step_key,'transition_key',win_key,'source_kind','combat_terminal','fact_code','combat_terminal_confirmed','label','Vittoria dei PG','encounter_key','enc_'||step_key,'combat_outcome','pg_win'),
    jsonb_build_object('trigger_key','loss_'||step_key,'transition_key',loss_key,'source_kind','combat_terminal','fact_code','combat_terminal_confirmed','label','Sconfitta dei PG','encounter_key','enc_'||step_key,'combat_outcome','pg_loss'),
    jsonb_build_object('trigger_key','draw_'||step_key,'transition_key',draw_key,'source_kind','combat_terminal','fact_code','combat_terminal_confirmed','label','Esito senza vincitore','encounter_key','enc_'||step_key,'combat_outcome','draw'));
   transitions:=transitions||jsonb_build_array(
    jsonb_build_object('transition_key',win_key,'from_step_key',step_key,'to_step_key',next_key,'event_kind',win_key,'priority',0),
    jsonb_build_object('transition_key',loss_key,'from_step_key',step_key,'to_step_key','rapid_failure','event_kind',loss_key,'priority',0),
    jsonb_build_object('transition_key',draw_key,'from_step_key',step_key,'to_step_key',next_key,'event_kind',draw_key,'priority',0));
   consequences:=consequences||jsonb_build_array(
    jsonb_build_object('transition_key',win_key,'public_fact','Lo scontro è concluso a favore dei PG.','private_note','Usare esclusivamente il terminale autorevole del server.'),
    jsonb_build_object('transition_key',loss_key,'public_fact','Lo scontro si conclude con la sconfitta dei PG.','private_note','Usare esclusivamente il terminale autorevole del server.'),
    jsonb_build_object('transition_key',draw_key,'public_fact','Lo scontro termina senza un vincitore.','private_note','Usare esclusivamente il terminale autorevole del server.'));
   if c#>>'{map,mode}'='specific' then
    arenas:=arenas||jsonb_build_array(jsonb_build_object('step_key',step_key,'zone_key','arena',
     'template_key',c#>>'{map,template_key}','template_version',(c#>>'{map,template_version}')::integer));
   end if;
  else
   triggers:=triggers||jsonb_build_array(jsonb_build_object('trigger_key','next_'||step_key,'transition_key',auto_key,'source_kind','player_choice','fact_code','player_choice_confirmed','label','Prosegui'));
   transitions:=transitions||jsonb_build_array(jsonb_build_object('transition_key',auto_key,'from_step_key',step_key,'to_step_key',next_key,'event_kind',auto_key,'priority',100));
   consequences:=consequences||jsonb_build_array(jsonb_build_object('transition_key',auto_key,'public_fact','La missione prosegue alla fase successiva.','private_note','Confermare solo dopo le azioni effettive dei PG.'));
   for tr in select value from jsonb_array_elements(phase->'transitions') loop
    target:=coalesce(tr->>'to_step_key','rapid_success');
    triggers:=triggers||jsonb_build_array(jsonb_build_object('trigger_key',tr->>'transition_key','transition_key',tr->>'transition_key','source_kind','player_choice','fact_code','player_choice_confirmed','label',left(tr->>'when',160)));
    transitions:=transitions||jsonb_build_array(jsonb_build_object('transition_key',tr->>'transition_key','from_step_key',step_key,'to_step_key',target,'event_kind',tr->>'transition_key','priority',0));
    consequences:=consequences||jsonb_build_array(jsonb_build_object('transition_key',tr->>'transition_key','public_fact',tr->>'public_result','private_note',tr->>'private_note'));
   end loop;
   triggers:=triggers||jsonb_build_array(jsonb_build_object('trigger_key','fail_'||step_key,'transition_key',fail_key,'source_kind','narrative_event','fact_code','mission_rapid_failure_confirmed','label','Condizione di fallimento accertata'));
   transitions:=transitions||jsonb_build_array(jsonb_build_object('transition_key',fail_key,'from_step_key',step_key,'to_step_key','rapid_failure','event_kind',fail_key,'priority',200));
   consequences:=consequences||jsonb_build_array(jsonb_build_object('transition_key',fail_key,'public_fact','La missione non può essere completata.','private_note','Usare solo con una condizione server accertata.'));
  end if;
  for rule in select value from jsonb_array_elements(p_draft.compiled->'terminal_rules') where value->>'phase_key'=step_key and value->>'type' not in('victory','defeat') loop
   tr:=jsonb_build_object('transition_key',mission_rapid_owner.rule_transition(rule),'from_step_key',step_key,
    'to_step_key',case when rule->>'outcome'='success' then 'rapid_success' else 'rapid_failure' end,
    'event_kind',mission_rapid_owner.rule_transition(rule),'priority',0);
   transitions:=transitions||jsonb_build_array(tr);
   triggers:=triggers||jsonb_build_array(jsonb_build_object('trigger_key','term_'||(rule->>'rule_key'),'transition_key',tr->>'transition_key',
    'source_kind',case when kind='mechanical' then 'spatial_event' else 'narrative_event' end,
    'fact_code','mission_rapid_terminal_confirmed','label','Condizione missione: '||(rule->>'rule_key'))||
    case when kind='mechanical' then jsonb_build_object('encounter_key','enc_'||step_key) else '{}'::jsonb end);
   consequences:=consequences||jsonb_build_array(jsonb_build_object('transition_key',tr->>'transition_key','public_fact','La condizione terminale configurata è soddisfatta.','private_note','Usare soltanto la ricevuta del valutatore server mission_rapid.'));
  end loop;
  steps:=steps||jsonb_build_array(jsonb_build_object('step_key',step_key,'kind',kind,'public_objective',phase->>'public_objective'));
  scenes:=scenes||jsonb_build_array(jsonb_build_object('step_key',step_key,'actors',scene_actors,'encounters',encounters,'triggers',triggers));
  editorial_scenes:=editorial_scenes||jsonb_build_array(jsonb_build_object('step_key',step_key,'setting',jsonb_build_object('name','','description',''),
   'director_notes',concat_ws(E'\n',phase->>'narrator_notes',m->>'narrator_instructions'),'entry_public',case when ord=1 then m->>'opening' else phase->>'public_objective' end,
   'actors',editorial_actors,'consequences',consequences));
 end loop;
 steps:=steps||jsonb_build_array(jsonb_build_object('step_key','rapid_success','kind','narrative','public_objective','Missione completata.'),jsonb_build_object('step_key','rapid_failure','kind','narrative','public_objective','Missione fallita.'));
 scenes:=scenes||jsonb_build_array(jsonb_build_object('step_key','rapid_success','actors','[]'::jsonb,'encounters','[]'::jsonb,'triggers','[]'::jsonb),jsonb_build_object('step_key','rapid_failure','actors','[]'::jsonb,'encounters','[]'::jsonb,'triggers','[]'::jsonb));
 editorial_scenes:=editorial_scenes||jsonb_build_array(
  jsonb_build_object('step_key','rapid_success','setting',jsonb_build_object('name','','description',''),'director_notes','Concludere sui soli fatti accertati.','entry_public','La missione è completata.','actors','[]'::jsonb,'consequences','[]'::jsonb),
  jsonb_build_object('step_key','rapid_failure','setting',jsonb_build_object('name','','description',''),'director_notes','Concludere sui soli fatti accertati.','entry_public','La missione non è stata completata.','actors','[]'::jsonb,'consequences','[]'::jsonb));
 return jsonb_build_object('schema_version','mission-creation-document/1',
  'mission',jsonb_build_object('title',m->>'title','grado',m->>'grade','briefing',m->>'briefing_public','village',coalesce(c->>'village',''),
   'tag_trama',concat_ws(E'\n',m->>'background_private',m->>'narrator_instructions'),'team_min',(m->>'team_min')::integer,'team_max',(m->>'team_max')::integer,
   'direction_mode','ai','gathering_location_id',c->>'gathering_location_id'),
  'plan',jsonb_build_object('schema_version','mission-generic-plan-document/1','base_plan_version_id',null,'initial_step_key',p_draft.compiled#>>'{phases,0,step_key}',
   'steps',steps,'transitions',transitions,'terminal_steps',jsonb_build_array(jsonb_build_object('step_key','rapid_success','outcome','success'),jsonb_build_object('step_key','rapid_failure','outcome','failure')),
   'definition',jsonb_build_object('schema_version','mission-generic-definition/1','scenes',scenes)),
  'editorial',jsonb_build_object('plot_private',m->>'background_private','setting',jsonb_build_object('name',setting_name,'description',setting_description),'scenes',editorial_scenes),
  'arenas',arenas);
end $fn$;

create function public.mission_rapid_catalog_v1() returns jsonb
language plpgsql stable security definer set search_path='' as $fn$
declare g mission_generic_owner.runtime_policy;n mission_narrative_internal.runtime_policy;
begin
 perform mission_ai_board_owner.staff_only();
 select * into strict g from mission_generic_owner.runtime_policy where singleton;
 select * into strict n from mission_narrative_internal.runtime_policy where singleton;
 return jsonb_build_object('schema_version','mission-rapid-catalog/1','bundles',(select coalesce(jsonb_agg(jsonb_build_object('bundle_id',b.id,'display_name',b.certified_payload#>>'{document,display_name}','village_scope',b.certified_payload#>>'{document,village_scope}','bundle_sha256',b.bundle_sha256,'mechanics',b.certified_payload,'mechanical_profile',jsonb_build_object('binding_id',mb.id,'version_id',mv.id,'rank',mv.rank,'archetype',mv.archetype,'stats',mv.stats,'vita_max',mv.vita_max,'chakra_max',mv.chakra_max,'abilities',mv.abilities)) order by b.certified_payload#>>'{document,display_name}'),'[]') from png_builder_internal.bundles b join public.nb_mechanical_bindings mb on mb.id=(b.certified_payload->>'mechanical_binding_id')::uuid and mb.narrative_template_id=b.template_id and mb.narrative_version_id=b.narrative_version_id and mb.lifecycle_state='approved' and mb.active join public.nb_mechanical_versions mv on mv.id=mb.mechanical_version_id and mv.template_id=mb.mechanical_template_id and mv.review_state='approved' where b.status='certified' and b.disabled_at is null and b.ownership_mode='adopted'),'mission_creation',public.mission_creation_catalog_v1(),'maps',public.mission_map_catalog_v1(),'runtime_budget',jsonb_build_object('mode',g.mode,'max_calls',g.provider_max_calls,'max_cost_usd',g.provider_max_cost_usd,'max_input_tokens',n.max_input_tokens,'max_output_tokens',n.max_output_tokens,'narrative_policy_version',n.policy_version));
end $fn$;

create function public.mission_rapid_draft_save_v1(p_draft uuid,p_expected_version bigint,p_document jsonb) returns jsonb
language plpgsql security definer set search_path='' as $fn$
declare d mission_rapid_owner.drafts;doc jsonb;sh text;
begin
 perform mission_ai_board_owner.staff_only();select * into strict d from mission_rapid_owner.drafts where id=p_draft and actor_user=auth.uid() for update;
 if d.state<>'draft' or d.control_version<>p_expected_version then raise exception 'MR_DRAFT_DRIFT' using errcode='40001';end if;
 doc:=mission_rapid_owner.validate_draft(p_document,d.source);sh:=mission_rapid_owner.sha(doc);
 update mission_rapid_owner.drafts set compiled=doc->'compiled',document=doc,document_sha256=sh,control_version=control_version+1,preview_seal=null,preview_basis=null,preview_at=null,updated_at=clock_timestamp() where id=d.id returning control_version into p_expected_version;
 return jsonb_build_object('schema_version','mission-rapid-draft-save/1','draft_id',d.id,'control_version',p_expected_version,'document_sha256',sh);
end $fn$;

create function public.mission_rapid_preview_v1(p_draft uuid,p_expected_version bigint) returns jsonb
language plpgsql security definer set search_path='' as $fn$
declare d mission_rapid_owner.drafts;v jsonb;
begin
 perform mission_ai_board_owner.staff_only();select * into strict d from mission_rapid_owner.drafts where id=p_draft and actor_user=auth.uid() for update;
 if d.state<>'draft' or d.control_version<>p_expected_version then raise exception 'MR_DRAFT_DRIFT' using errcode='40001';end if;
 v:=mission_rapid_owner.preview_for(d);
 update mission_rapid_owner.drafts set preview_seal=v->>'preview_seal',preview_basis=case when v->>'preview_seal' is null then null else v->'basis' end,preview_at=case when v->>'preview_seal' is null then null else clock_timestamp() end,updated_at=clock_timestamp() where id=d.id;
 return v-'basis';
end $fn$;

create function public.mission_rapid_publish_v1(p_draft uuid,p_expected_version bigint,p_preview_seal text,p_request uuid) returns jsonb
language plpgsql security definer set search_path='' as $fn$
declare d mission_rapid_owner.drafts;old mission_rapid_owner.requests;fp text;preview jsonb;refs jsonb;doc jsonb;pf jsonb;created jsonb;opened jsonb;res jsonb;r jsonb;mid uuid;pvid uuid;
begin
 perform mission_ai_board_owner.staff_only();
 if p_request is null or coalesce(p_preview_seal,'')!~'^[0-9a-f]{64}$' then raise exception 'MR_PUBLISH_INPUT' using errcode='22023';end if;
 fp:=mission_rapid_owner.sha(jsonb_build_object('op','publish','draft_id',p_draft,'expected_version',p_expected_version,'preview_seal',p_preview_seal));
 perform pg_advisory_xact_lock(hashtextextended(p_request::text,19092028));
 select * into old from mission_rapid_owner.requests where request_key=p_request;
 if found then
  if old.actor_user<>auth.uid() or old.operation<>'publish' or old.request_fingerprint<>fp then raise exception 'MR_REQUEST_CONFLICT' using errcode='40001';end if;
  return old.result;
 end if;
 select * into strict d from mission_rapid_owner.drafts where id=p_draft and actor_user=auth.uid() for update;
 if d.state<>'draft' or d.control_version<>p_expected_version or d.preview_seal is distinct from p_preview_seal or d.preview_basis is null
 then raise exception 'MR_PUBLISH_DRAFT_DRIFT' using errcode='40001';end if;
 preview:=mission_rapid_owner.preview_for(d);
 if preview->'errors'<>'[]'::jsonb or preview->>'preview_seal' is distinct from p_preview_seal
 or preview->'basis' is distinct from d.preview_basis then raise exception 'MR_PUBLISH_PREVIEW_DRIFT' using errcode='40001';end if;
 refs:=mission_rapid_owner.actor_refs(d);
 doc:=mission_rapid_owner.technical_document(d,refs);
 pf:=public.mission_creation_preflight_v2(doc);
 if not coalesce((pf->>'ok')::boolean,false) then raise exception 'MR_PUBLISH_PREFLIGHT:%',pf->'errors' using errcode='22023';end if;
 created:=public.mission_create_complete_v1(mission_ai_service_owner.uuid5(p_request,'mission-create'),doc);
 mid:=(created->>'mission_id')::uuid;pvid:=(created->>'plan_version_id')::uuid;
 for r in select value from jsonb_array_elements(d.compiled->'terminal_rules') loop
  insert into mission_rapid_owner.terminal_rules(mission_id,rule_key,phase_key,rule_type,subject_key,threshold,outcome,transition_key,configuration,configuration_sha256)
  values(mid,r->>'rule_key',r->>'phase_key',r->>'type',nullif(r->>'subject_key',''),case when r->>'threshold' is null then null else (r->>'threshold')::integer end,
   r->>'outcome',mission_rapid_owner.rule_transition(r),r,mission_rapid_owner.sha(r));
 end loop;
 insert into mission_rapid_owner.recovery_receipts(publication_request,draft_id,mission_id,plan_version_id,preview_seal,recovery_document)
 values(p_request,d.id,mid,pvid,p_preview_seal,jsonb_build_object('schema_version','mission-rapid-recovery/1','draft_document',d.document,
  'technical_document',doc,'actor_refs',refs,'preview_basis',d.preview_basis,'action','disable_authoring_and_close_new_board_without_deleting_history'));
 opened:=public.mission_generic_board_open_v1(mid,(d.document#>>'{configuration,gathering_location_id}')::uuid,mission_ai_service_owner.uuid5(p_request,'board-open'));
 res:=jsonb_build_object('schema_version','mission-rapid-publish-result/1','request_key',p_request,'draft_id',d.id,
  'mission_id',mid,'plan_version_id',pvid,'state','open','preview_seal',p_preview_seal,'preflight',pf,'board',opened,
  'budget',mission_rapid_owner.budget_snapshot(d.document#>'{configuration,budget}'));
 update mission_rapid_owner.drafts set state='published',mission_id=mid,plan_version_id=pvid,control_version=control_version+1,updated_at=clock_timestamp() where id=d.id;
 insert into mission_rapid_owner.requests values(p_request,auth.uid(),'publish',fp,d.id,res,clock_timestamp());
 return res;
end $fn$;

create function public.mission_rapid_terminal_evaluate_v1(p_session uuid,p_event jsonb,p_request uuid) returns jsonb
language plpgsql security definer set search_path='' as $fn$
begin
 raise exception 'MR_TERMINAL_NATIVE_ONLY' using errcode='42501';
end $fn$;

create function mission_rapid_owner.try_native_terminal(p_session uuid)
returns jsonb
language plpgsql security definer set search_path='' as $fn$
declare
 m public.master_v2_sessions;
 run public.mission_run_state;
 enc mission_generic_owner.encounters;
 rule mission_rapid_owner.terminal_rules;
 report public.combat_v2_round_reports;
 arena combat_spatial.arena_instances;
 combat public.combat_v2_sessions;
 completed_rounds integer;
 candidate_count integer;
 pg_alive boolean;
 matched boolean;
 actor_matches integer;
 object_matches integer;
 matched_rule mission_rapid_owner.terminal_rules;
 source_document jsonb;
 source_sha text;
 source_ref uuid;
 movement_event_id uuid;
 request_key uuid;
 close_request uuid;
 audit_event_id uuid;
 audit_event jsonb;
 close_receipt jsonb;
 native_event public.combat_v2_events;
 transition_result jsonb;
 result jsonb;
begin
 select * into strict m from public.master_v2_sessions where id=p_session for update;

 -- This guard is the non-interference boundary: ordinary/Adatta missions do
 -- not read encounters, rounds, spatial state, or alter their progress path.
 if m.mission_id is null or not exists(
  select 1 from mission_rapid_owner.terminal_rules x
  where x.mission_id=m.mission_id and x.active
 ) then return null; end if;

 select * into strict run from public.mission_run_state
 where master_session_id=p_session for update;

 select * into enc from mission_generic_owner.encounters e
 where e.master_session_id=p_session
   and e.step_key=run.current_step_key
   and e.run_control_version=run.control_version;
 if not found then return null; end if;
 select * into strict combat from public.combat_v2_sessions
  where id=enc.encounter_id for update;
 select * into strict arena from combat_spatial.arena_instances
  where encounter_id=enc.encounter_id;

 select count(*)::integer into completed_rounds
 from public.combat_v2_rounds cr
 where cr.session_id=enc.encounter_id and cr.state='narrato';

 select exists(
  select 1 from public.combat_v2_actors a
  where a.session_id=enc.encounter_id
    and a.actor_kind='pg' and a.state='attivo'
 ) into pg_alive;

 candidate_count:=0;
 for rule in select * from mission_rapid_owner.terminal_rules x
  where x.mission_id=m.mission_id and x.active
   and x.phase_key=run.current_step_key
   and x.rule_type in('surrender_after_exchanges','escape','protect_subject','reach_position','survive_rounds')
  order by x.rule_key
 loop
  matched:=false;source_ref:=null;source_document:=null;movement_event_id:=null;
  if rule.rule_type='surrender_after_exchanges' then
   matched:=completed_rounds>=rule.threshold;
  elsif rule.rule_type='survive_rounds' then
   matched:=completed_rounds>=rule.threshold and pg_alive;
  elsif rule.rule_type='escape' then
   select count(*) into actor_matches from jsonb_array_elements(enc.actor_map) x
    where x->>'actor_key'=rule.subject_key and x ? 'mechanical_binding_id';
   if actor_matches<>1 then raise exception 'MR_TERMINAL_ESCAPE_ACTOR_REF' using errcode='55000';end if;
   matched:=exists(select 1 from public.combat_v2_actors a,jsonb_array_elements(enc.actor_map) x
    where x->>'actor_key'=rule.subject_key and a.id=(x->>'actor_id')::uuid
     and a.session_id=enc.encounter_id and a.state='ritirato');
  elsif rule.rule_type='protect_subject' then
   select count(*) into actor_matches from jsonb_array_elements(enc.actor_map) x
    where x->>'actor_key'=rule.subject_key;
   select count(*) into object_matches from combat_spatial.arena_objects o
    where o.template_key=arena.template_key and o.template_version=arena.template_version
     and o.object_key=rule.subject_key;
   if actor_matches+object_matches<>1 then raise exception 'MR_TERMINAL_PROTECT_REF_AMBIGUOUS_OR_MISSING' using errcode='55000';end if;
   if combat.state='risolto' then
    if actor_matches=1 then
     matched:=exists(select 1 from public.combat_v2_actors a,jsonb_array_elements(enc.actor_map) x
      where x->>'actor_key'=rule.subject_key and a.id=(x->>'actor_id')::uuid
       and a.session_id=enc.encounter_id and a.state='attivo');
    else
     matched:=exists(select 1 from combat_spatial.object_states os
      where os.instance_id=arena.instance_id and os.object_key=rule.subject_key
       and os.state='available');
    end if;
   end if;
  elsif rule.rule_type='reach_position' then
   select count(*) into object_matches from combat_spatial.arena_objects o
    where o.template_key=arena.template_key and o.template_version=arena.template_version
     and o.object_key=rule.subject_key and o.shape_kind in('circle','aabb');
   if object_matches<>1 then raise exception 'MR_TERMINAL_POSITION_GEOMETRY_REF' using errcode='55000';end if;
   select se.event_id into movement_event_id
   from combat_spatial.actor_states ast
   join public.combat_v2_actors ca on ca.id=ast.actor_id and ca.session_id=enc.encounter_id
   join combat_spatial.arena_objects o on o.template_key=arena.template_key
    and o.template_version=arena.template_version and o.object_key=rule.subject_key
   join combat_spatial.spatial_events se on se.instance_id=arena.instance_id
    and se.actor_id=ast.actor_id and se.event_kind='movement_settled'
   where ast.instance_id=arena.instance_id and ast.state='active'
    and ca.actor_kind='pg' and ca.state='attivo'
    and case o.shape_kind
     when 'circle' then combat_spatial.distance_m(ast.x_m,ast.y_m,
      (o.shape->>'cx')::numeric,(o.shape->>'cy')::numeric)
      <=(o.shape->>'radius')::numeric+ast.footprint_radius_m
     when 'aabb' then ast.x_m between (o.shape->>'min_x')::numeric-ast.footprint_radius_m
      and (o.shape->>'max_x')::numeric+ast.footprint_radius_m
      and ast.y_m between (o.shape->>'min_y')::numeric-ast.footprint_radius_m
      and (o.shape->>'max_y')::numeric+ast.footprint_radius_m
     else false end
   order by se.created_at desc,se.event_id desc limit 1;
   matched:=movement_event_id is not null;
  end if;
  if matched then
   candidate_count:=candidate_count+1;
   matched_rule:=rule;
  end if;
 end loop;

 if candidate_count=0 then return null; end if;
 if candidate_count<>1 then
  raise exception 'MR_TERMINAL_NATIVE_AMBIGUOUS' using errcode='22023';
 end if;

 rule:=matched_rule;

 -- Never terminate across an unresolved or unpublished exchange. This also
 -- prevents creating/abandoning round N+1: the hook may close only at the
 -- existing native narration boundary.
 if exists(select 1 from public.combat_v2_rounds cr
  where cr.session_id=enc.encounter_id and cr.state<>'narrato') then
  return null;
 end if;

 select rr.* into report
 from public.combat_v2_round_reports rr
 join public.combat_v2_rounds cr on cr.id=rr.round_id
 where cr.session_id=enc.encounter_id and cr.state='narrato'
 order by cr.round_no desc,rr.id desc limit 1;

 source_ref:=coalesce(report.id,arena.instance_id);
 source_document:=jsonb_build_object(
  'schema_version','mission-rapid-native-terminal/1',
  'master_session_id',p_session,
  'mission_id',m.mission_id,
  'step_key',run.current_step_key,
  'run_control_version',run.control_version,
  'encounter_id',enc.encounter_id,
  'rule_key',rule.rule_key,
  'rule_type',rule.rule_type,
  'threshold',rule.threshold,
  'completed_narrated_rounds',completed_rounds,
  'pg_alive',pg_alive,
  'source_round_report_id',source_ref,
  'source_movement_event_id',movement_event_id,
  'source_round_report_sha256',case when report.id is null then null else public.combat_v2_sha256(to_jsonb(report)) end,
  'combat_state',combat.state,
  'actor_states',(select jsonb_agg(jsonb_build_object('actor_id',a.id,'state',a.state,'team_key',a.team_key) order by a.id) from public.combat_v2_actors a where a.session_id=enc.encounter_id),
  'arena_state',(select jsonb_build_object('instance_id',arena.instance_id,'map_version',arena.map_version,
   'actors',(select jsonb_agg(to_jsonb(ast) order by ast.actor_id) from combat_spatial.actor_states ast where ast.instance_id=arena.instance_id),
   'objects',(select jsonb_agg(to_jsonb(os) order by os.object_key) from combat_spatial.object_states os where os.instance_id=arena.instance_id)) )
 );
 source_sha:=mission_rapid_owner.sha(source_document);
 request_key:=mission_ai_service_owner.uuid5(
  source_ref,'mission-rapid-native:'||rule.rule_key
 );

 -- Audit the rapid terminalization as an AI-service Combat event. Only after
 -- the native facts and the narration boundary are fixed may the encounter be
 -- moved from in_corso to risolto.
 audit_event:=public.combat_v2_event_begin_ai_service(
  p_session,request_key,'mission_rapid_terminal_close',source_document,
  m.control_version,enc.capability_id
 );
 audit_event_id:=(audit_event->>'event_id')::uuid;
 if audit_event_id is null then
  raise exception 'MR_TERMINAL_AUDIT_REPLAY_UNEXPECTED' using errcode='40001';
 end if;
 if not (audit_event->>'replay')::boolean then
  if combat.state='in_corso' then
   update public.combat_v2_sessions set state='risolto'
    where id=enc.encounter_id and state='in_corso';
  elsif combat.state<>'risolto' then
   raise exception 'MR_TERMINAL_COMBAT_STATE' using errcode='40001';
  end if;
  audit_event:=public.combat_v2_event_complete(
   audit_event_id,
   public.combat_v2_envelope(request_key,jsonb_build_object(
    'encounter_id',enc.encounter_id,'step_key',run.current_step_key,
    'run_version',run.control_version,'rule_key',rule.rule_key,
    'native_facts_sha256',source_sha,'state','risolto'
   ))
  );
 end if;
 select * into strict native_event from public.combat_v2_events
  where id=audit_event_id;
 if native_event.scope_id<>p_session
  or native_event.operation_kind<>'mission_rapid_terminal_close'
  or native_event.status<>'completata'
  or native_event.caller_kind<>'ai_service'
  or native_event.caller_service_capability<>enc.capability_id
 then raise exception 'MR_TERMINAL_AUDIT_INVALID' using errcode='42501';end if;

 -- Reuse the Generic native close port so encounter, arena and lifecycle are
 -- closed exactly as for a natural terminal. Its precondition proves that no
 -- unresolved/nonnarrated round is left behind.
 close_request:=mission_ai_service_owner.uuid5(request_key,'generic-close');
 close_receipt:=public.mission_generic_combat_close_v1(
  p_session,enc.encounter_id,run.control_version,close_request
 );
 select * into strict combat from public.combat_v2_sessions
  where id=enc.encounter_id;
 if combat.state<>'chiuso' or combat.closed_at is null
  or exists(select 1 from public.combat_v2_rounds cr
    where cr.session_id=enc.encounter_id and cr.state<>'narrato')
 then raise exception 'MR_TERMINAL_DANGLING_ENCOUNTER' using errcode='55000';end if;

 source_ref:=native_event.id;
 source_sha:=public.combat_v2_sha256(to_jsonb(native_event));

 transition_result:=mission_generic_owner.apply_authority(
  p_session,request_key,m.control_version,run.control_version,
  'term_'||rule.rule_key,'spatial_event',source_ref,source_sha,null
 );
 result:=jsonb_build_object(
  'schema_version','mission-rapid-terminal-result/2',
  'request_key',request_key,
  'session_id',p_session,
  'mission_id',m.mission_id,
  'matched',true,
  'rule_key',rule.rule_key,
  'outcome',rule.outcome,
  'transition_key',rule.transition_key,
  'source_kind','native_combat_round_report',
  'source_ref',source_ref,
  'receipt_sha256',source_sha,
  'combat_close',close_receipt,
  'transition',transition_result
 );
 insert into mission_rapid_owner.terminal_events(
  id,master_session_id,mission_id,rule_key,event,event_sha256,result
 ) values(
  request_key,p_session,m.mission_id,rule.rule_key,
  to_jsonb(native_event),source_sha,result
 );
 return result;
end $fn$;
alter function mission_rapid_owner.try_native_terminal(uuid) owner to postgres;
revoke all on function mission_rapid_owner.try_native_terminal(uuid)
 from public,anon,authenticated,service_role;
grant execute on function mission_rapid_owner.try_native_terminal(uuid) to postgres;

alter function mission_rapid_owner.sha(jsonb) owner to postgres;
alter function mission_rapid_owner.validate_source(jsonb) owner to postgres;
alter function mission_rapid_owner.validate_compiled(jsonb) owner to postgres;
alter function mission_rapid_owner.validate_draft(jsonb,jsonb) owner to postgres;
alter function mission_rapid_owner.budget_snapshot(jsonb) owner to postgres;
alter function mission_rapid_owner.preview_for(mission_rapid_owner.drafts) owner to postgres;
alter function mission_rapid_owner.stable_key(text,jsonb) owner to postgres;
alter function mission_rapid_owner.rule_transition(jsonb) owner to postgres;
alter function mission_rapid_owner.actor_refs(mission_rapid_owner.drafts) owner to postgres;
alter function mission_rapid_owner.technical_document(mission_rapid_owner.drafts,jsonb) owner to postgres;
alter function public.mission_rapid_media_ticket_v1(uuid,text,uuid,uuid,text,bigint,text) owner to postgres;
alter function public.mission_rapid_media_register_v1(uuid,text,bigint,text,integer,integer) owner to postgres;
alter function public.mission_rapid_compile_request_v1(uuid,jsonb) owner to postgres;
alter function public.mission_rapid_compile_state_v1(uuid) owner to postgres;
alter function public.mission_rapid_compile_claim_v1(uuid,uuid) owner to postgres;
alter function public.mission_rapid_compile_complete_v1(uuid,uuid,jsonb,jsonb) owner to postgres;
alter function public.mission_rapid_compile_reject_v1(uuid,uuid,text,integer) owner to postgres;
alter function public.mission_rapid_catalog_v1() owner to postgres;
alter function public.mission_rapid_draft_save_v1(uuid,bigint,jsonb) owner to postgres;
alter function public.mission_rapid_preview_v1(uuid,bigint) owner to postgres;
alter function public.mission_rapid_publish_v1(uuid,bigint,text,uuid) owner to postgres;
alter function public.mission_rapid_terminal_evaluate_v1(uuid,jsonb,uuid) owner to postgres;
revoke all on function mission_rapid_owner.sha(jsonb),mission_rapid_owner.validate_source(jsonb),mission_rapid_owner.validate_compiled(jsonb),mission_rapid_owner.validate_draft(jsonb,jsonb),mission_rapid_owner.budget_snapshot(jsonb),mission_rapid_owner.preview_for(mission_rapid_owner.drafts),mission_rapid_owner.stable_key(text,jsonb),mission_rapid_owner.rule_transition(jsonb),mission_rapid_owner.actor_refs(mission_rapid_owner.drafts),mission_rapid_owner.technical_document(mission_rapid_owner.drafts,jsonb),mission_rapid_owner.try_native_terminal(uuid) from public,anon,authenticated,service_role;
grant execute on function mission_rapid_owner.sha(jsonb),mission_rapid_owner.validate_source(jsonb),mission_rapid_owner.validate_compiled(jsonb),mission_rapid_owner.validate_draft(jsonb,jsonb),mission_rapid_owner.budget_snapshot(jsonb),mission_rapid_owner.preview_for(mission_rapid_owner.drafts),mission_rapid_owner.stable_key(text,jsonb),mission_rapid_owner.rule_transition(jsonb),mission_rapid_owner.actor_refs(mission_rapid_owner.drafts),mission_rapid_owner.technical_document(mission_rapid_owner.drafts,jsonb),mission_rapid_owner.try_native_terminal(uuid) to postgres;
revoke all on function public.mission_rapid_compile_request_v1(uuid,jsonb),public.mission_rapid_compile_state_v1(uuid),public.mission_rapid_compile_claim_v1(uuid,uuid),public.mission_rapid_compile_complete_v1(uuid,uuid,jsonb,jsonb),public.mission_rapid_compile_reject_v1(uuid,uuid,text,integer),public.mission_rapid_catalog_v1(),public.mission_rapid_draft_save_v1(uuid,bigint,jsonb),public.mission_rapid_preview_v1(uuid,bigint),public.mission_rapid_publish_v1(uuid,bigint,text,uuid),public.mission_rapid_terminal_evaluate_v1(uuid,jsonb,uuid),public.mission_rapid_media_ticket_v1(uuid,text,uuid,uuid,text,bigint,text),public.mission_rapid_media_register_v1(uuid,text,bigint,text,integer,integer) from public,anon,authenticated,service_role;
grant execute on function public.mission_rapid_compile_request_v1(uuid,jsonb),public.mission_rapid_compile_state_v1(uuid),public.mission_rapid_catalog_v1(),public.mission_rapid_draft_save_v1(uuid,bigint,jsonb),public.mission_rapid_preview_v1(uuid,bigint),public.mission_rapid_publish_v1(uuid,bigint,text,uuid),public.mission_rapid_media_ticket_v1(uuid,text,uuid,uuid,text,bigint,text) to authenticated;
grant execute on function public.mission_rapid_compile_claim_v1(uuid,uuid),public.mission_rapid_compile_complete_v1(uuid,uuid,jsonb,jsonb),public.mission_rapid_compile_reject_v1(uuid,uuid,text,integer),public.mission_rapid_media_register_v1(uuid,text,bigint,text,integer,integer) to service_role;

do $patch$
declare source text;old_fragment text;new_fragment text;
begin
 source:=pg_get_functiondef('mission_generic_owner.progress_step(uuid,uuid,uuid)'::regprocedure);
 old_fragment:=E' if exists(select 1 from public.mission_run_outbox uo where uo.master_session_id=p_session and uo.state=''pending'' and not exists(select 1 from mission_generic_owner.unified_batches ub where ub.master_session_id=p_session and ub.state=''preparing'' and ub.route->>''event_id''=uo.event_id::text))\n then return mission_generic_owner.progress_result(p_session,p_user,''narration_pending'');end if;\n settings:=mission_generic_owner.run_plan_settings(p_session);';
 new_fragment:=E' if exists(select 1 from public.mission_run_outbox uo where uo.master_session_id=p_session and uo.state=''pending'' and not exists(select 1 from mission_generic_owner.unified_batches ub where ub.master_session_id=p_session and ub.state=''preparing'' and ub.route->>''event_id''=uo.event_id::text))\n then return mission_generic_owner.progress_result(p_session,p_user,''narration_pending'');end if;\n res:=mission_rapid_owner.try_native_terminal(p_session);\n if res is not null then return mission_generic_owner.progress_result(p_session,p_user,''transitioned'');end if;\n settings:=mission_generic_owner.run_plan_settings(p_session);';
 if md5(source)<>'0bc40e0ff963c26a63e218f2aa95dd94'
 or (length(source)-length(replace(source,old_fragment,'')))/length(old_fragment)<>1
 then raise exception 'MR_PROGRESS_HOOK_DRIFT' using errcode='40001';end if;
 execute replace(source,old_fragment,new_fragment);
end $patch$;

do $postflight$
declare n text;
begin
 if (select enabled from mission_rapid_owner.authoring_policy where singleton) then raise exception 'MR_POSTFLIGHT_POLICY_ENABLED';end if;
 foreach n in array array['shared_function_baselines','authoring_policy','drafts','requests','terminal_rules','recovery_receipts','terminal_events','media_tickets'] loop
  if not exists(select 1 from pg_class c join pg_namespace s on s.oid=c.relnamespace where s.nspname='mission_rapid_owner' and c.relname=n and c.relrowsecurity)
  then raise exception 'MR_POSTFLIGHT_RLS:%',n;end if;
 end loop;
 if not has_function_privilege('authenticated','public.mission_rapid_publish_v1(uuid,bigint,text,uuid)','execute')
 or has_function_privilege('anon','public.mission_rapid_publish_v1(uuid,bigint,text,uuid)','execute')
 or has_function_privilege('service_role','public.mission_rapid_terminal_evaluate_v1(uuid,jsonb,uuid)','execute')
 or has_function_privilege('authenticated','public.mission_rapid_terminal_evaluate_v1(uuid,jsonb,uuid)','execute')
 or has_function_privilege('service_role','mission_rapid_owner.try_native_terminal(uuid)','execute')
 or not has_function_privilege('authenticated','public.mission_rapid_media_ticket_v1(uuid,text,uuid,uuid,text,bigint,text)','execute')
 or has_function_privilege('authenticated','public.mission_rapid_media_register_v1(uuid,text,bigint,text,integer,integer)','execute')
 or not has_function_privilege('service_role','public.mission_rapid_media_register_v1(uuid,text,bigint,text,integer,integer)','execute')
 then raise exception 'MR_POSTFLIGHT_GRANTS';end if;
 if (select md5(prosrc) from pg_proc where oid='public.mission_creation_preflight_v2(jsonb)'::regprocedure)<>'2bfa56c88e45c52eb4495ee1f7c5d870'
 or (select md5(prosrc) from pg_proc where oid='public.mission_create_complete_v1(uuid,jsonb)'::regprocedure)<>'8a512021ec0335f6eddb8b859607b056'
 or (select md5(prosrc) from pg_proc where oid='public.mission_generic_board_open_v1(uuid,uuid,uuid)'::regprocedure)<>'7efaab206f6b8f1fab92b72c848d5d72'
 then raise exception 'MR_POSTFLIGHT_BASELINE_DRIFT';end if;
 if position('mission_rapid_owner.try_native_terminal(p_session)' in pg_get_functiondef('mission_generic_owner.progress_step(uuid,uuid,uuid)'::regprocedure))=0
 then raise exception 'MR_PROGRESS_HOOK_MISSING';end if;
end $postflight$;

commit;
