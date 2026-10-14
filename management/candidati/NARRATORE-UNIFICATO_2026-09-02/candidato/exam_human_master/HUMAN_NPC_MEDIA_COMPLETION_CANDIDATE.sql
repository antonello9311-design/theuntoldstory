BEGIN;
DO $preflight$ declare e jsonb; begin
 e:=nullif(pg_catalog.current_setting('tus.human_npc_media_authority',true),'')::jsonb;
 if current_user<>'postgres' or e is null or e->>'schema_version' is distinct from 'human-npc-media-install-authority/1' or e->>'source_id' is distinct from 'HUMAN-NPC-MEDIA-SOURCE-20261014' or e->>'independent_review' is distinct from '0/0/0' or e->>'edge_bundle_reviewed' is distinct from 'true' or coalesce((e->>'expires_at')::timestamptz,'-infinity'::timestamptz)<=clock_timestamp() then raise exception 'MEDIA_COMPLETION_ROOT_AUTHORITY_REQUIRED'; end if;
 if pg_catalog.to_regprocedure('png_builder_internal.npc_media_completion_staff_v1(uuid)') is not null or pg_catalog.to_regprocedure('public.npc_media_completion_ticket_v2(uuid,uuid,text,uuid,text,bigint,text)') is not null or pg_catalog.to_regprocedure('public.npc_media_completion_binding_v2(uuid,uuid)') is not null or pg_catalog.to_regprocedure('png_builder_internal.npc_media_approved_legacy_completion_v1(uuid,uuid,text,text,bigint,text,uuid)') is not null then raise exception 'MEDIA_COMPLETION_ALREADY_INSTALLED'; end if;
if pg_catalog.md5(pg_catalog.pg_get_functiondef('public.npc_media_ticket_v1(uuid,uuid,text,uuid,text,bigint,text)'::regprocedure))<>'a384b9c2e0e29e858c41bdbfcab242b5' then raise exception 'MEDIA_COMPLETION_BASELINE_DRIFT'; end if;
if pg_catalog.md5(pg_catalog.pg_get_functiondef('public.npc_media_register_v1(uuid,text,bigint,text,integer,integer)'::regprocedure))<>'59efb59d651bc78fafabd3d4ea97abf9' then raise exception 'MEDIA_COMPLETION_BASELINE_DRIFT'; end if;
if pg_catalog.md5(pg_catalog.pg_get_functiondef('public.npc_media_approve_pair_v1(uuid,uuid,uuid,uuid,uuid)'::regprocedure))<>'bfc2309a66950a10d2d3234c943bbb64' then raise exception 'MEDIA_COMPLETION_BASELINE_DRIFT'; end if;
if pg_catalog.md5(pg_catalog.pg_get_functiondef('combat_consumer_private.staff_test_allowed(uuid,uuid[],boolean)'::regprocedure)) is distinct from '255e8d73cdd7c3814132d71f0f45b1b5' then raise exception 'MEDIA_COMPLETION_STAFF_PARENT_DRIFT';end if;
if pg_catalog.md5(pg_catalog.pg_get_functiondef('mission_factory_owner.c416_kind_live_v1()'::regprocedure)) is distinct from 'ca836584b84f114ede05277e91610235' then raise exception 'MEDIA_COMPLETION_STAFF_PARENT_DRIFT';end if;
if pg_catalog.md5(pg_catalog.pg_get_functiondef('mission_factory_owner.c444_enabled_v1()'::regprocedure)) is distinct from '2b8d0af96cf3601f48bbfe9f862c9823' then raise exception 'MEDIA_COMPLETION_STAFF_PARENT_DRIFT';end if;
end $preflight$;
CREATE FUNCTION png_builder_internal.npc_media_completion_staff_v1(p_actor uuid) RETURNS boolean LANGUAGE sql STABLE SECURITY DEFINER SET search_path='' AS $staff$
SELECT coalesce(
 p_actor=ANY(ARRAY['f0856d53-83a6-4de0-bc0c-12c87916e665'::uuid,'b4952ed5-5ce0-49c0-9f2b-8fd5dcd89b4b'::uuid])
 AND EXISTS(SELECT 1 FROM public.profiles p WHERE p.id=p_actor AND p.role IN('admin','master'))
 AND mission_factory_owner.c416_kind_live_v1() IS TRUE
 AND mission_factory_owner.c444_enabled_v1() IS TRUE
 AND EXISTS(SELECT 1 FROM mission_factory_owner.c416_kind_admission k WHERE k.singleton AND k.enabled AND p_actor=ANY(k.allowed_auth_ids) AND k.bound_at<=statement_timestamp() AND k.expires_at>statement_timestamp())
 AND combat_consumer_private.staff_test_allowed('0b85f354-9cdb-47e1-baf9-3d266bb7e06b'::uuid,ARRAY[p_actor]::uuid[],false) IS TRUE
 AND EXISTS(SELECT 1 FROM mission_factory_owner.manual_authoring_admissions_v1 a WHERE a.actor_user=p_actor AND a.release_sha256='37dac90525b249f53fc0404b50adb4ed92df0123649326c99260bf656119d806' AND a.location_id='0b85f354-9cdb-47e1-baf9-3d266bb7e06b'::uuid AND a.enabled AND 'npc_narrative'=ANY(a.operations) AND a.staff_context_bound_at<=statement_timestamp() AND a.expires_at>statement_timestamp()),false)
$staff$;
CREATE OR REPLACE FUNCTION png_builder_internal.npc_media_approved_legacy_completion_v1(p_template uuid,p_version uuid,p_kind text,p_sha text,p_bytes bigint,p_mime text,p_actor uuid)
RETURNS boolean LANGUAGE sql STABLE SECURITY DEFINER SET search_path='' AS $completion$
select png_builder_internal.npc_media_completion_staff_v1(p_actor) AND coalesce((p_template='82afcf8c-0a2c-447a-b9a5-0cf6a8b067b7'::uuid and p_version='daef66b3-3660-443c-af23-6a7b8351e06e'::uuid
 and exists(select 1 from public.nb_templates t where t.id=p_template and t.current_version_id=p_version and t.deactivated_at is null)
 and exists(select 1 from public.nb_template_versions v where v.id=p_version and v.template_id=p_template and v.review_state='approved' and v.mechanical_template_id is null and pg_catalog.encode(pg_catalog.sha256(pg_catalog.convert_to(pg_catalog.to_jsonb(v)::text,'UTF8')),'hex')='0737087d375f7c1b2374d243550d4666851128c548dde418b79d5dcd09375b69')
 and not exists(select 1 from png_builder_internal.npc_combat_draft_heads h where h.narrative_template_id=p_template and h.narrative_version_id=p_version)
 and exists(select 1 from png_builder_internal.bundles b where b.id='aec1177c-6173-4575-9259-b9135259da1d'::uuid and pg_catalog.encode(pg_catalog.sha256(pg_catalog.convert_to(pg_catalog.to_jsonb(b)::text,'UTF8')),'hex')='46dbf5833eb68ada4dea92f5be527518419a6ba75a2f810826abf5bc14bcf725')
 and exists(select 1 from public.nb_mechanical_bindings b where b.id='5a329d4f-8add-47e9-84a6-e70f669375e5'::uuid and pg_catalog.encode(pg_catalog.sha256(pg_catalog.convert_to(pg_catalog.to_jsonb(b)::text,'UTF8')),'hex')='4d1a0c7bcac50147ff8bd647b204d55363a9b9ee400708b7910962d7fbba202e')
 and exists(select 1 from public.nb_mechanical_versions v where v.id='88eabccc-ec40-49fe-abc2-8a8e6391b8b2'::uuid and pg_catalog.encode(pg_catalog.sha256(pg_catalog.convert_to(pg_catalog.to_jsonb(v)::text,'UTF8')),'hex')='d7ac5345c5f47fa278f7a4eac7bf29fcfb856dbae0cef7a400883ea55735f305')
 and exists(select 1 from public.nb_template_media_versions m where m.id='7d5258c0-6560-4c74-bc3e-6c52ba1ebb28'::uuid and m.template_id=p_template and m.template_version_id=p_version and m.active and m.lifecycle_state='approved' and m.kind='canonical_full_body' and m.asset_id='mr_0e116da9fc44431ca87e91d65159932a' and m.bucket='avatars' and m.object_path='ninja-book/academy_nami_kasei/r1/assets/mr_0e116da9fc44431ca87e91d65159932a_v1.png' and m.sha256='7507ddaede8b77c13ed2716895729e80d1c4b8b9c0e60cf43c443b6b4aa59bde' and m.verified_sha256='7507ddaede8b77c13ed2716895729e80d1c4b8b9c0e60cf43c443b6b4aa59bde' and m.bytes=2774288 and m.mime_type='image/png')
 and not exists(select 1 from png_builder_internal.npc_media_pairs pair where pair.template_id=p_template and pair.narrative_version_id=p_version)
 and ((p_kind='binding' and p_sha is null and p_bytes is null and p_mime is null) or (p_mime='image/png' and ((p_kind='portrait' and p_sha='7507ddaede8b77c13ed2716895729e80d1c4b8b9c0e60cf43c443b6b4aa59bde' and p_bytes=2774288) or (p_kind='marker' and p_sha='e1636bd9875d3498e6be784cd84cc719d222082a92338d1257749fb7af75bbcf' and p_bytes=1867688))))) or (p_template='0aaecee9-7e33-4e91-9a95-af1d691f3a40'::uuid and p_version='e962b36d-69ba-41ff-9d9f-4b91934cc226'::uuid
 and exists(select 1 from public.nb_templates t where t.id=p_template and t.current_version_id=p_version and t.deactivated_at is null)
 and exists(select 1 from public.nb_template_versions v where v.id=p_version and v.template_id=p_template and v.review_state='approved' and v.mechanical_template_id is null and pg_catalog.encode(pg_catalog.sha256(pg_catalog.convert_to(pg_catalog.to_jsonb(v)::text,'UTF8')),'hex')='2c2d45c0a99e623b17f02c3a942f062353df94dfd098bbc771f4ce55cbb6192a')
 and not exists(select 1 from png_builder_internal.npc_combat_draft_heads h where h.narrative_template_id=p_template and h.narrative_version_id=p_version)
 and exists(select 1 from png_builder_internal.bundles b where b.id='7bb53e62-f30c-4c94-b464-8b37a9291cdf'::uuid and pg_catalog.encode(pg_catalog.sha256(pg_catalog.convert_to(pg_catalog.to_jsonb(b)::text,'UTF8')),'hex')='19edd848f2a91a00ae45c3c2264f0e1134445e7cf80f209412ba4e9e6958989c')
 and exists(select 1 from public.nb_mechanical_bindings b where b.id='bb9bb7b7-3fca-418a-b067-fe246dd82d4c'::uuid and pg_catalog.encode(pg_catalog.sha256(pg_catalog.convert_to(pg_catalog.to_jsonb(b)::text,'UTF8')),'hex')='276376bad55b051371f278f01b671248445ab10d3bc50f50e09452f47ac5425a')
 and exists(select 1 from public.nb_mechanical_versions v where v.id='444a3afc-dc9f-40e6-bc81-1e26e79b9b8c'::uuid and pg_catalog.encode(pg_catalog.sha256(pg_catalog.convert_to(pg_catalog.to_jsonb(v)::text,'UTF8')),'hex')='62a651378d7c47a5b7660c0ff251ffdfc42ba7f25074d7a862d32ee8ff68a94c')
 and exists(select 1 from public.nb_template_media_versions m where m.id='cb0a95de-3c61-4ca8-8b3f-ec5b3adf9c92'::uuid and m.template_id=p_template and m.template_version_id=p_version and m.active and m.lifecycle_state='approved' and m.kind='canonical_full_body' and m.asset_id='mr_ff8e5297e11045878941434803f1418c' and m.bucket='avatars' and m.object_path='ninja-book/academy_tetsuna_hoji/r1/assets/mr_ff8e5297e11045878941434803f1418c_v1.png' and m.sha256='316fa42b3a7e85123d9b8e6027182f427a4330cf9b7ab664d665718d76e183b7' and m.verified_sha256='316fa42b3a7e85123d9b8e6027182f427a4330cf9b7ab664d665718d76e183b7' and m.bytes=2525641 and m.mime_type='image/png')
 and not exists(select 1 from png_builder_internal.npc_media_pairs pair where pair.template_id=p_template and pair.narrative_version_id=p_version)
 and ((p_kind='binding' and p_sha is null and p_bytes is null and p_mime is null) or (p_mime='image/png' and ((p_kind='portrait' and p_sha='316fa42b3a7e85123d9b8e6027182f427a4330cf9b7ab664d665718d76e183b7' and p_bytes=2525641) or (p_kind='marker' and p_sha='1f9bba5d8ca13fba29178e4de164f9a3b56285766e5e1636dd60a90c05465e0e' and p_bytes=2137301))))),false)
$completion$;
CREATE OR REPLACE FUNCTION public.npc_media_completion_binding_v2(p_template uuid,p_narrative_version uuid) RETURNS jsonb LANGUAGE plpgsql STABLE SECURITY DEFINER SET search_path='' AS $binding$
declare eligible boolean; uid uuid:=auth.uid();
begin
 if uid is null or not public.is_staff() or not exists(select 1 from public.nb_templates t where t.id=p_template and (t.created_by=uid or exists(select 1 from public.profiles p where p.id=uid and p.role='admin'))) then raise exception 'NPC_MEDIA_AUTH' using errcode='42501'; end if;
 eligible:=png_builder_internal.npc_media_approved_legacy_completion_v1(p_template,p_narrative_version,'binding',null,null,null,uid);
 return pg_catalog.jsonb_build_object('schema_version','npc-media-completion-binding/2','template_id',p_template,'narrative_version_id',p_narrative_version,'eligible',eligible,'completion_mode',case when eligible then 'approved_legacy_missing_pair' else null end);
end $binding$;
CREATE OR REPLACE FUNCTION public.npc_media_ticket_v1(p_template uuid, p_narrative_version uuid, p_kind text, p_request uuid, p_sha256 text, p_bytes bigint, p_mime text)
 RETURNS jsonb
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO ''
AS $function$
declare v_uid uuid:=auth.uid(); v_admin boolean; t public.nb_templates%rowtype;
        v public.nb_template_versions%rowtype;
        h png_builder_internal.npc_combat_draft_heads%rowtype;
        old png_builder_internal.npc_media_tickets%rowtype;
        latest uuid; ext text; v_path text; v_asset_id text;
begin
  if v_uid is null or not public.is_staff() then raise exception 'NPC_MEDIA_AUTH' using errcode='42501'; end if;
  if p_template is null or p_narrative_version is null or p_request is null or
     coalesce(p_kind,'') not in ('portrait','marker') or coalesce(p_sha256,'') !~ '^[0-9a-f]{64}$' or
     coalesce(p_bytes,0) not between 1 and 4194304 or
     coalesce(p_mime,'') not in ('image/png','image/jpeg','image/webp')
    then raise exception 'NPC_MEDIA_INPUT' using errcode='22023'; end if;
  perform pg_catalog.pg_advisory_xact_lock(pg_catalog.hashtextextended(p_request::text,25092025));
  select p.role='admin' into v_admin from public.profiles p where p.id=v_uid;
  select * into t from public.nb_templates where id=p_template for update;
  if not found or t.deactivated_at is not null or
     (t.created_by is distinct from v_uid and not coalesce(v_admin,false))
    then raise exception 'NPC_MEDIA_AUTH' using errcode='42501'; end if;
  select * into old from png_builder_internal.npc_media_tickets where request_key=p_request;
  if found then
    if old.actor_id is distinct from v_uid or old.template_id is distinct from p_template or
       old.narrative_version_id is distinct from p_narrative_version or
       old.kind is distinct from p_kind or old.sha256 is distinct from p_sha256 or
       old.bytes is distinct from p_bytes or old.mime_type is distinct from p_mime
      then raise exception 'NPC_MEDIA_REQUEST_MISMATCH' using errcode='22023'; end if;
    select * into v from public.nb_template_versions
      where id=p_narrative_version and template_id=p_template;
    select x.id into latest from public.nb_template_versions x
      where x.template_id=p_template and x.review_state='draft'
      order by x.version_no desc limit 1;
    if v.id is null or v.content_sha256 is distinct from old.narrative_content_sha256 or
       v.mechanical_template_id is distinct from old.mechanical_template_id or
       (latest is not null and latest is distinct from p_narrative_version) or
       (v.review_state='approved' and t.current_version_id is distinct from p_narrative_version) or
       (old.state='pending' and v.review_state<>'draft' and not png_builder_internal.npc_media_approved_legacy_completion_v1(p_template,p_narrative_version,old.kind,old.sha256,old.bytes,old.mime_type,v_uid))
      then raise exception 'NPC_MEDIA_STALE' using errcode='55000'; end if;
    return png_builder_internal.npc_media_ticket_view_v1(old);
  end if;
  select * into v from public.nb_template_versions
    where id=p_narrative_version and template_id=p_template for update;
  select * into h from png_builder_internal.npc_combat_draft_heads
    where narrative_template_id=p_template and narrative_version_id=p_narrative_version for share;
  select x.id into latest from public.nb_template_versions x
    where x.template_id=p_template and x.review_state='draft'
    order by x.version_no desc limit 1;
  if not png_builder_internal.npc_media_approved_legacy_completion_v1(p_template,p_narrative_version,p_kind,p_sha256,p_bytes,p_mime,v_uid) and (v.id is null or v.review_state<>'draft' or latest is distinct from p_narrative_version or
     (v.mechanical_template_id is null and h.narrative_template_id is not null and
       (h.combat is distinct from false or h.mechanical_template_id is not null or
        h.review_state<>'draft')) or
     (v.mechanical_template_id is not null and
       (h.narrative_template_id is null or h.combat is distinct from true or
        h.review_state<>'draft' or
        v.mechanical_template_id is distinct from h.mechanical_template_id)))
    then raise exception 'NPC_MEDIA_STALE' using errcode='55000'; end if;
  ext:=case p_mime when 'image/png' then 'png' when 'image/jpeg' then 'jpg' else 'webp' end;
  -- Preserve the live NBE media object_path CHECK and asset_id CHECK.
  -- Request and full byte hash make the path unique without an upsert.
  v_asset_id:='npc_'||p_kind||'_'||replace(p_request::text,'-','')||'_'||p_sha256;
  v_path:='ninja-book/'||t.template_key||'/r'||v.version_no::text||
    '/assets/'||v_asset_id||'_v1.'||ext;
  insert into png_builder_internal.npc_media_tickets(
    request_key,actor_id,template_id,narrative_version_id,kind,asset_id,object_path,
    sha256,bytes,mime_type,narrative_content_sha256,mechanical_template_id)
  values(p_request,v_uid,p_template,p_narrative_version,p_kind,v_asset_id,v_path,
    p_sha256,p_bytes,p_mime,v.content_sha256,v.mechanical_template_id)
  returning * into old;
  return png_builder_internal.npc_media_ticket_view_v1(old);
end $function$
;
CREATE OR REPLACE FUNCTION public.npc_media_register_v1(p_request uuid, p_sha256 text, p_bytes bigint, p_mime text, p_width integer, p_height integer)
 RETURNS jsonb
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO ''
AS $function$
declare
  x png_builder_internal.npc_media_tickets%rowtype;
  t public.nb_templates%rowtype;
  v public.nb_template_versions%rowtype;
  h png_builder_internal.npc_combat_draft_heads%rowtype;
  latest uuid;
  obj_mime text;
  obj_bytes bigint;
  receipt jsonb;
begin
  if coalesce(auth.jwt()->>'role','')<>'service_role' then
    raise exception 'NPC_MEDIA_SERVICE_REQUIRED' using errcode='42501';
  end if;
  if p_request is null or coalesce(p_sha256,'') !~ '^[0-9a-f]{64}$' or
     coalesce(p_bytes,0) not between 1 and 4194304 or
     coalesce(p_mime,'') not in ('image/png','image/jpeg','image/webp') or
     coalesce(p_width,0) not between 1 and 8192 or
     coalesce(p_height,0) not between 1 and 8192 then
    raise exception 'NPC_MEDIA_INPUT' using errcode='22023';
  end if;

  select * into x from png_builder_internal.npc_media_tickets
    where request_key=p_request for update;
  if not found then raise exception 'NPC_MEDIA_TICKET_MISSING' using errcode='55000'; end if;
  if x.sha256 is distinct from p_sha256 or x.bytes is distinct from p_bytes or
     x.mime_type is distinct from p_mime then
    raise exception 'NPC_MEDIA_REQUEST_MISMATCH' using errcode='22023';
  end if;
  if x.state='registered' or x.state='approved' then
    if x.width_px is distinct from p_width or x.height_px is distinct from p_height or
       x.registration is null then
      raise exception 'NPC_MEDIA_REQUEST_MISMATCH' using errcode='22023';
    end if;
    return x.registration;
  end if;
  if x.state<>'pending' or x.expires_at<=clock_timestamp() then
    raise exception 'NPC_MEDIA_EXPIRED' using errcode='55000';
  end if;

  select * into t from public.nb_templates where id=x.template_id for update;
  select * into v from public.nb_template_versions
    where id=x.narrative_version_id and template_id=x.template_id for update;
  select * into h from png_builder_internal.npc_combat_draft_heads
    where narrative_template_id=x.template_id and narrative_version_id=x.narrative_version_id
    for share;
  select q.id into latest from public.nb_template_versions q
    where q.template_id=x.template_id and q.review_state='draft'
    order by q.version_no desc limit 1;
  if not png_builder_internal.npc_media_approved_legacy_completion_v1(x.template_id,x.narrative_version_id,x.kind,x.sha256,x.bytes,x.mime_type,x.actor_id) and (t.id is null or t.deactivated_at is not null or
     v.id is null or v.review_state<>'draft' or
     latest is distinct from x.narrative_version_id or
     h.narrative_template_id is null or h.review_state<>'draft' or
     v.content_sha256 is distinct from x.narrative_content_sha256 or
     v.mechanical_template_id is distinct from x.mechanical_template_id or
     h.mechanical_template_id is distinct from x.mechanical_template_id) then
    raise exception 'NPC_MEDIA_STALE' using errcode='55000';
  end if;

  select o.metadata->>'mimetype',(o.metadata->>'size')::bigint
    into obj_mime,obj_bytes from storage.objects o
    where o.bucket_id=x.bucket and o.name=x.object_path;
  if not found or obj_mime is distinct from x.mime_type or
     obj_bytes is distinct from x.bytes then
    raise exception 'NPC_MEDIA_STORAGE_DRIFT' using errcode='55000';
  end if;

  receipt:=pg_catalog.jsonb_build_object(
    'schema_version','npc-media-registration/1',
    'request_key',x.request_key,'template_id',x.template_id,
    'narrative_version_id',x.narrative_version_id,'kind',x.kind,
    'media_id',x.media_id,'asset_id',x.asset_id,
    'bucket',x.bucket,'object_path',x.object_path,
    'sha256',x.sha256,'bytes',x.bytes,'mime_type',x.mime_type,
    'width_px',p_width,'height_px',p_height,
    'narrative_content_sha256',x.narrative_content_sha256,
    'mechanical_template_id',x.mechanical_template_id,
    'state','registered');
  update png_builder_internal.npc_media_tickets
    set state='registered',width_px=p_width,height_px=p_height,
        registration=receipt,registered_at=clock_timestamp()
    where request_key=x.request_key;
  return receipt;
end $function$
;
REVOKE ALL ON FUNCTION png_builder_internal.npc_media_approved_legacy_completion_v1(uuid,uuid,text,text,bigint,text,uuid) FROM PUBLIC,anon,authenticated,service_role;
REVOKE ALL ON FUNCTION public.npc_media_completion_binding_v2(uuid,uuid) FROM PUBLIC,anon,authenticated,service_role;
GRANT EXECUTE ON FUNCTION public.npc_media_completion_binding_v2(uuid,uuid) TO authenticated;
CREATE FUNCTION public.npc_media_completion_ticket_v2(p_template uuid,p_narrative_version uuid,p_kind text,p_request uuid,p_sha256 text,p_bytes bigint,p_mime text)
RETURNS jsonb LANGUAGE plpgsql SECURITY DEFINER SET search_path='' AS $scoped_ticket$
DECLARE uid uuid:=auth.uid(); known png_builder_internal.npc_media_tickets%rowtype; exact_file boolean;
BEGIN
 IF png_builder_internal.npc_media_completion_staff_v1(uid) IS DISTINCT FROM true THEN RAISE EXCEPTION 'NPC_MEDIA_COMPLETION_STAFF_SCOPE' USING ERRCODE='42501';END IF;
 exact_file:=p_mime='image/png' AND ((p_template='82afcf8c-0a2c-447a-b9a5-0cf6a8b067b7'::uuid AND p_narrative_version='daef66b3-3660-443c-af23-6a7b8351e06e'::uuid AND ((p_kind='portrait' AND p_sha256='7507ddaede8b77c13ed2716895729e80d1c4b8b9c0e60cf43c443b6b4aa59bde' AND p_bytes=2774288) OR (p_kind='marker' AND p_sha256='e1636bd9875d3498e6be784cd84cc719d222082a92338d1257749fb7af75bbcf' AND p_bytes=1867688))) OR (p_template='0aaecee9-7e33-4e91-9a95-af1d691f3a40'::uuid AND p_narrative_version='e962b36d-69ba-41ff-9d9f-4b91934cc226'::uuid AND ((p_kind='portrait' AND p_sha256='316fa42b3a7e85123d9b8e6027182f427a4330cf9b7ab664d665718d76e183b7' AND p_bytes=2525641) OR (p_kind='marker' AND p_sha256='1f9bba5d8ca13fba29178e4de164f9a3b56285766e5e1636dd60a90c05465e0e' AND p_bytes=2137301))));
 IF exact_file IS DISTINCT FROM true THEN RAISE EXCEPTION 'NPC_MEDIA_COMPLETION_FILE_SCOPE' USING ERRCODE='42501';END IF;
 SELECT * INTO known FROM png_builder_internal.npc_media_tickets WHERE request_key=p_request;
 IF known.request_key IS NOT NULL AND known.state IN('registered','approved') THEN
  -- The ordinary ticket port verifies actual actor, request fingerprint and narrative/current version before readonly replay.
  RETURN public.npc_media_ticket_v1(p_template,p_narrative_version,p_kind,p_request,p_sha256,p_bytes,p_mime);
 END IF;
 IF png_builder_internal.npc_media_approved_legacy_completion_v1(p_template,p_narrative_version,p_kind,p_sha256,p_bytes,p_mime,uid) IS DISTINCT FROM true THEN RAISE EXCEPTION 'NPC_MEDIA_COMPLETION_PAIR_SCOPE' USING ERRCODE='42501';END IF;
 RETURN public.npc_media_ticket_v1(p_template,p_narrative_version,p_kind,p_request,p_sha256,p_bytes,p_mime);
END $scoped_ticket$;
REVOKE ALL ON FUNCTION png_builder_internal.npc_media_completion_staff_v1(uuid) FROM PUBLIC,anon,authenticated,service_role;
REVOKE ALL ON FUNCTION public.npc_media_completion_ticket_v2(uuid,uuid,text,uuid,text,bigint,text) FROM PUBLIC,anon,authenticated,service_role;
GRANT EXECUTE ON FUNCTION public.npc_media_completion_ticket_v2(uuid,uuid,text,uuid,text,bigint,text) TO authenticated;
COMMIT;
