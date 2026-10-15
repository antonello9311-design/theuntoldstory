CREATE OR REPLACE FUNCTION public.npc_combat_submit_review_v1(p_template uuid, p_narrative_version uuid, p_expected_control_version bigint, p_request_key uuid)
 RETURNS jsonb
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO ''
AS $function$
declare
  v_uid uuid:=auth.uid(); v_admin boolean; t public.nb_templates%rowtype;
  nv public.nb_template_versions%rowtype; h png_builder_internal.npc_combat_draft_heads%rowtype;
  mt public.nb_mechanical_templates%rowtype; mv uuid; latest uuid; body jsonb;
  fp text; old png_builder_internal.npc_combat_requests%rowtype;
  receipt jsonb; response jsonb;
begin
  if v_uid is null or not public.is_staff() then raise exception 'NPC_MECH_AUTH' using errcode='42501'; end if;
  if p_template is null or p_narrative_version is null or p_request_key is null or
     p_expected_control_version is null or p_expected_control_version<1
    then raise exception 'NPC_MECH_ARGUMENT' using errcode='22023'; end if;
  perform pg_catalog.pg_advisory_xact_lock(pg_catalog.hashtextextended(p_request_key::text,0));
  select p.role='admin' into v_admin from public.profiles p where p.id=v_uid;
  select * into t from public.nb_templates where id=p_template for update;
  if not found or t.deactivated_at is not null or
     (t.created_by is distinct from v_uid and not coalesce(v_admin,false))
    then raise exception 'NPC_MECH_UNAVAILABLE' using errcode='42501'; end if;
  fp:=pg_catalog.encode(extensions.digest(pg_catalog.convert_to(
    pg_catalog.jsonb_build_object('operation','submit_review','template_id',p_template,
      'narrative_version_id',p_narrative_version,
      'expected',p_expected_control_version)::text,'UTF8'),'sha256'),'hex');
  select * into old from png_builder_internal.npc_combat_requests where request_key=p_request_key;
  if found then
    if old.operation<>'submit_review' or old.actor_id is distinct from v_uid or
       old.narrative_template_id is distinct from p_template or
       old.narrative_version_id is distinct from p_narrative_version or old.fingerprint<>fp
      then raise exception 'NPC_MECH_REQUEST_MISMATCH' using errcode='22023'; end if;
    return pg_catalog.jsonb_set(old.response,'{receipt,replayed}','true'::jsonb,false);
  end if;
  select * into nv from public.nb_template_versions
    where id=p_narrative_version and template_id=p_template for update;
  select * into h from png_builder_internal.npc_combat_draft_heads
    where narrative_template_id=p_template and narrative_version_id=p_narrative_version for update;
  if nv.id is null or nv.review_state<>'draft' or h.narrative_template_id is null or
     h.review_state<>'draft' or h.control_version<>p_expected_control_version
    then raise exception 'NPC_MECH_STALE' using errcode='55000'; end if;
  select v.id into latest from public.nb_template_versions v
    where v.template_id=p_template and v.review_state='draft'
    order by v.version_no desc limit 1;
  if latest is distinct from p_narrative_version then
    raise exception 'NPC_MECH_NARRATIVE_STALE' using errcode='55000'; end if;
  if h.payload_sha256 is distinct from pg_catalog.encode(extensions.digest(
       pg_catalog.convert_to(h.payload::text,'UTF8'),'sha256'),'hex')
    then raise exception 'NPC_MECH_PAYLOAD_DRIFT' using errcode='55000'; end if;
  if nv.mechanical_template_id is distinct from h.mechanical_template_id
    then raise exception 'NPC_MECH_NBE_POINTER_MISMATCH' using errcode='55000'; end if;
  if h.combat then
    if not png_builder_internal.npc_combat_stats_safe(h.payload->'stats') or
       h.payload->'technique_refs'<>'[]'::jsonb or
       h.payload->'ability_refs'<>'[]'::jsonb
      then raise exception 'NPC_MECH_REF_ILLEGAL' using errcode='22023'; end if;
    select * into mt from public.nb_mechanical_templates
      where id=h.mechanical_template_id for update;
    if mt.id is null or mt.archetype<>'npc_custom' or mt.lifecycle_state<>'draft' or
       mt.active or mt.current_version_id is not null
      then raise exception 'NPC_MECH_TEMPLATE_STALE' using errcode='55000'; end if;
    body:=pg_catalog.jsonb_build_object(
      'schema_version','ninja-book-mechanics/npc-custom/1.0',
      'rank','NPC','archetype','npc_custom','base_per_stat',0,
      'allocated_points',0,'innata',0,'stats',h.payload->'stats',
      'vita_max',(h.payload->>'vita_max')::integer,
      'chakra_max',(h.payload->>'chakra_max')::integer,
      'abilities','[]'::jsonb,
      'generation',pg_catalog.jsonb_build_object('source','staff',
        'clan_ref',h.payload->'clan_ref',
        'chakra_element_ref',h.payload->'chakra_element_ref'));
    insert into public.nb_mechanical_versions(
      template_id,version_no,schema_version,rank,archetype,base_per_stat,
      allocated_points,innata,stats,vita_max,chakra_max,abilities,generation,
      content_sha256,review_state,profile_kind)
    values(mt.id,1,'ninja-book-mechanics/npc-custom/1.0','NPC','npc_custom',0,
      0,0,h.payload->'stats',(h.payload->>'vita_max')::integer,
      (h.payload->>'chakra_max')::integer,'[]'::jsonb,body->'generation',
      pg_catalog.encode(extensions.digest(pg_catalog.convert_to(body::text,'UTF8'),'sha256'),'hex'),
      'review','npc_custom') returning id into mv;
    update public.nb_mechanical_templates set lifecycle_state='review',
      current_version_id=mv,control_version=control_version+1,updated_at=clock_timestamp()
      where id=mt.id;
  end if;
  -- Native NBE checks actor Staff, skeleton and transition. Any failure rolls
  -- back the mechanical version and all gateway writes in this same call.
  perform public.nb_admin_template_submit_review(p_template,t.control_version,gen_random_uuid());
  update png_builder_internal.npc_combat_draft_heads set
    mechanical_version_id=mv,review_state='review',control_version=control_version+1,
    updated_by=v_uid,updated_at=clock_timestamp()
    where narrative_template_id=p_template and narrative_version_id=p_narrative_version
    returning * into h;
  receipt:=pg_catalog.jsonb_build_object('request_key',p_request_key,'replayed',false,
    'template_id',p_template,'narrative_version_id',p_narrative_version,
    'mechanical_template_id',h.mechanical_template_id,
    'control_version',h.control_version,'payload_sha256',h.payload_sha256);
  update png_builder_internal.npc_combat_draft_heads set last_receipt=receipt
    where narrative_template_id=p_template and narrative_version_id=p_narrative_version;
  response:=png_builder_internal.npc_combat_state_v1(p_template,p_narrative_version);
  insert into png_builder_internal.npc_combat_requests(
    request_key,operation,narrative_template_id,narrative_version_id,actor_id,fingerprint,response)
  values(p_request_key,'submit_review',p_template,p_narrative_version,v_uid,fp,response);
  return response;
end $function$
;

CREATE OR REPLACE FUNCTION public.npc_combat_approve_v1(p_template uuid, p_narrative_version uuid, p_expected_control_version bigint, p_request_key uuid)
 RETURNS jsonb
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO ''
AS $function$
declare
  v_uid uuid:=auth.uid(); v_admin boolean; t public.nb_templates%rowtype;
  nv public.nb_template_versions%rowtype; h png_builder_internal.npc_combat_draft_heads%rowtype;
  mt public.nb_mechanical_templates%rowtype; mv public.nb_mechanical_versions%rowtype;
  fp text; old png_builder_internal.npc_combat_requests%rowtype;
  receipt jsonb; response jsonb; body jsonb;
  approved_mv public.nb_mechanical_versions%rowtype; next_version integer;
begin
  if v_uid is null or not public.is_staff() then raise exception 'NPC_MECH_AUTH' using errcode='42501'; end if;
  select p.role='admin' into v_admin from public.profiles p where p.id=v_uid;
  if not coalesce(v_admin,false) then raise exception 'NPC_MECH_ADMIN_REQUIRED' using errcode='42501'; end if;
  if p_template is null or p_narrative_version is null or p_request_key is null or
     p_expected_control_version is null or p_expected_control_version<1
    then raise exception 'NPC_MECH_ARGUMENT' using errcode='22023'; end if;
  perform pg_catalog.pg_advisory_xact_lock(pg_catalog.hashtextextended(p_request_key::text,0));
  select * into t from public.nb_templates where id=p_template for update;
  if not found or t.deactivated_at is not null
    then raise exception 'NPC_MECH_UNAVAILABLE' using errcode='42501'; end if;
  fp:=pg_catalog.encode(extensions.digest(pg_catalog.convert_to(
    pg_catalog.jsonb_build_object('operation','approve','template_id',p_template,
      'narrative_version_id',p_narrative_version,
      'expected',p_expected_control_version)::text,'UTF8'),'sha256'),'hex');
  select * into old from png_builder_internal.npc_combat_requests where request_key=p_request_key;
  if found then
    if old.operation<>'approve' or old.actor_id is distinct from v_uid or
       old.narrative_template_id is distinct from p_template or
       old.narrative_version_id is distinct from p_narrative_version or old.fingerprint<>fp
      then raise exception 'NPC_MECH_REQUEST_MISMATCH' using errcode='22023'; end if;
    return pg_catalog.jsonb_set(old.response,'{receipt,replayed}','true'::jsonb,false);
  end if;
  select * into nv from public.nb_template_versions
    where id=p_narrative_version and template_id=p_template for update;
  select * into h from png_builder_internal.npc_combat_draft_heads
    where narrative_template_id=p_template and narrative_version_id=p_narrative_version for update;
  if nv.id is null or nv.review_state<>'review' or h.narrative_template_id is null or
     h.review_state<>'review' or h.control_version<>p_expected_control_version
    then raise exception 'NPC_MECH_STALE' using errcode='55000'; end if;
  if nv.mechanical_template_id is distinct from h.mechanical_template_id or
     h.payload_sha256 is distinct from pg_catalog.encode(extensions.digest(
       pg_catalog.convert_to(h.payload::text,'UTF8'),'sha256'),'hex')
    then raise exception 'NPC_MECH_BINDING_STALE' using errcode='55000'; end if;
  -- The live media register and approve ports require a current approved
  -- narrative version. Media is bound and approved only after this atomic
  -- narrative/mechanical transition, then required by Builder validation.
  -- No unapproved or client-provided media becomes authoritative here.
  if h.combat then
    select * into mt from public.nb_mechanical_templates
      where id=h.mechanical_template_id for update;
    select * into mv from public.nb_mechanical_versions
      where id=h.mechanical_version_id and template_id=h.mechanical_template_id for update;
    body:=pg_catalog.jsonb_build_object(
      'schema_version',mv.schema_version,'rank',mv.rank,'archetype',mv.archetype,
      'base_per_stat',mv.base_per_stat,'allocated_points',mv.allocated_points,
      'innata',mv.innata,'stats',mv.stats,'vita_max',mv.vita_max,
      'chakra_max',mv.chakra_max,'abilities',mv.abilities,'generation',mv.generation);
    if mt.id is null or mt.archetype<>'npc_custom' or mt.lifecycle_state<>'review' or
       mt.active or mt.current_version_id is distinct from mv.id or
       mv.id is null or mv.review_state<>'review' or mv.profile_kind<>'npc_custom' or
       mv.rank<>'NPC' or mv.archetype<>'npc_custom' or mv.abilities<>'[]'::jsonb or
       mv.content_sha256 is distinct from pg_catalog.encode(extensions.digest(
         pg_catalog.convert_to(body::text,'UTF8'),'sha256'),'hex') or
       mv.generation->'clan_ref' is distinct from h.payload->'clan_ref' or
       mv.generation->'chakra_element_ref' is distinct from h.payload->'chakra_element_ref' or
       mv.stats is distinct from h.payload->'stats' or
       mv.vita_max is distinct from (h.payload->>'vita_max')::integer or
       mv.chakra_max is distinct from (h.payload->>'chakra_max')::integer or
       h.payload->'technique_refs'<>'[]'::jsonb or
       h.payload->'ability_refs'<>'[]'::jsonb or
       (h.payload->>'clan_ref' is not null and not exists (
         select 1 from public.clans c where c.name=h.payload->>'clan_ref' and c.is_active))
      then raise exception 'NPC_MECH_VERSION_STALE' using errcode='55000'; end if;
  else
    if h.mechanical_template_id is not null or h.mechanical_version_id is not null or
       h.payload<>'{"combat":false}'::jsonb
      then raise exception 'NPC_MECH_NARRATIVE_SHAPE' using errcode='55000'; end if;
  end if;
  -- NBE Admin authority, skeleton and version transition are rechecked here.
  -- A later failure rolls back this NBE approval in the same transaction.
  perform public.nb_admin_template_approve(p_template,t.control_version,gen_random_uuid());
  if h.combat then
    -- Versions are immutable: approval appends validated content and preserves review history.
    select coalesce(max(v.version_no),0)+1 into next_version
      from public.nb_mechanical_versions v where v.template_id=mt.id;
    insert into public.nb_mechanical_versions(
      template_id,version_no,supersedes_version_id,schema_version,profile_kind,
      rank,archetype,base_per_stat,allocated_points,innata,stats,vita_max,
      chakra_max,abilities,generation,content_sha256,review_state)
    values(mt.id,next_version,mv.id,mv.schema_version,mv.profile_kind,
      mv.rank,mv.archetype,mv.base_per_stat,mv.allocated_points,mv.innata,
      mv.stats,mv.vita_max,mv.chakra_max,mv.abilities,mv.generation,
      mv.content_sha256,'approved') returning * into approved_mv;
    if approved_mv.id is null or approved_mv.id=mv.id or
       approved_mv.supersedes_version_id is distinct from mv.id or
       approved_mv.content_sha256 is distinct from mv.content_sha256 or
       approved_mv.content_sha256 is distinct from pg_catalog.encode(extensions.digest(
         pg_catalog.convert_to(body::text,'UTF8'),'sha256'),'hex') then
      raise exception 'NPC_MECH_APPROVAL_APPEND_DRIFT' using errcode='55000';
    end if;
    update public.nb_mechanical_templates set lifecycle_state='approved',active=true,
      current_version_id=approved_mv.id,control_version=control_version+1,updated_at=clock_timestamp() where id=mt.id;
    insert into public.nb_mechanical_bindings(
      narrative_template_id,narrative_version_id,mechanical_template_id,
      mechanical_version_id,lifecycle_state,active)
    values(p_template,p_narrative_version,mt.id,approved_mv.id,'approved',true);
  end if;
  update png_builder_internal.npc_combat_draft_heads set
    review_state='approved',control_version=control_version+1,
    mechanical_version_id=case when h.combat then approved_mv.id else mechanical_version_id end,
    updated_by=v_uid,updated_at=clock_timestamp()
    where narrative_template_id=p_template and narrative_version_id=p_narrative_version
    returning * into h;
  receipt:=pg_catalog.jsonb_build_object('request_key',p_request_key,'replayed',false,
    'template_id',p_template,'narrative_version_id',p_narrative_version,
    'mechanical_template_id',h.mechanical_template_id,
    'control_version',h.control_version,'payload_sha256',h.payload_sha256);
  update png_builder_internal.npc_combat_draft_heads set last_receipt=receipt
    where narrative_template_id=p_template and narrative_version_id=p_narrative_version;
  response:=png_builder_internal.npc_combat_state_v1(p_template,p_narrative_version);
  insert into png_builder_internal.npc_combat_requests(
    request_key,operation,narrative_template_id,narrative_version_id,actor_id,fingerprint,response)
  values(p_request_key,'approve',p_template,p_narrative_version,v_uid,fp,response);
  return response;
end $function$
;

CREATE OR REPLACE FUNCTION png_builder_internal.npc_custom_combat_source_v1(p_template uuid, p_narrative_version uuid)
 RETURNS jsonb
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO ''
AS $function$
declare t public.nb_templates%rowtype; nv public.nb_template_versions%rowtype;
  h png_builder_internal.npc_combat_draft_heads%rowtype;
  mt public.nb_mechanical_templates%rowtype; mv public.nb_mechanical_versions%rowtype;
  mb public.nb_mechanical_bindings%rowtype; pair jsonb; snap jsonb;
  media uuid[]; portrait uuid; doc jsonb; dep text; mechanical_body jsonb;
begin
  select * into t from public.nb_templates where id=p_template for share;
  select * into nv from public.nb_template_versions
    where id=p_narrative_version and template_id=p_template for share;
  select * into h from png_builder_internal.npc_combat_draft_heads
    where narrative_template_id=p_template and narrative_version_id=p_narrative_version for share;
  if t.id is null or nv.id is null or h.narrative_template_id is null
     or t.current_version_id is distinct from nv.id or t.lifecycle_state<>'approved'
     or t.deactivated_at is not null or nv.review_state<>'approved'
     or h.review_state<>'approved' or h.combat is distinct from true
     or h.mechanical_template_id is null or h.mechanical_version_id is null
     or nv.mechanical_template_id is distinct from h.mechanical_template_id
  then raise exception 'MF_NPC_CUSTOM_SOURCE_STALE' using errcode='55000';end if;
  select * into mt from public.nb_mechanical_templates
    where id=h.mechanical_template_id for share;
  select * into mv from public.nb_mechanical_versions
    where id=h.mechanical_version_id and template_id=h.mechanical_template_id for share;
  select * into mb from public.nb_mechanical_bindings
    where narrative_template_id=p_template and narrative_version_id=p_narrative_version
      and mechanical_template_id=h.mechanical_template_id
      and mechanical_version_id=h.mechanical_version_id for share;
  mechanical_body:=pg_catalog.jsonb_build_object(
      'schema_version',mv.schema_version,'rank',mv.rank,'archetype',mv.archetype,
      'base_per_stat',mv.base_per_stat,'allocated_points',mv.allocated_points,
      'innata',mv.innata,'stats',mv.stats,'vita_max',mv.vita_max,
      'chakra_max',mv.chakra_max,'abilities',mv.abilities,'generation',mv.generation);
  if mt.id is null or mt.archetype<>'npc_custom' or mt.lifecycle_state<>'approved'
     or not mt.active or mt.current_version_id is distinct from mv.id
     or mv.id is null or mv.profile_kind<>'npc_custom'
     or mv.archetype<>'npc_custom' or mv.rank<>'NPC'
     or mv.review_state<>'approved' or mv.abilities<>'[]'::jsonb
     or mv.stats is distinct from h.payload->'stats'
     or mv.vita_max is distinct from (h.payload->>'vita_max')::integer
     or mv.chakra_max is distinct from (h.payload->>'chakra_max')::integer
     or mv.generation->'clan_ref' is distinct from h.payload->'clan_ref'
     or mv.generation->'chakra_element_ref' is distinct from h.payload->'chakra_element_ref'
     or mv.content_sha256 is distinct from pg_catalog.encode(extensions.digest(
          pg_catalog.convert_to(mechanical_body::text,'UTF8'),'sha256'),'hex')
     or not png_builder_internal.npc_combat_stats_safe(mv.stats)
     or mv.vita_max<=0 or mv.chakra_max<0
     or mb.id is null or mb.lifecycle_state<>'approved' or not mb.active
     or (select count(*) from public.nb_mechanical_bindings x
         where x.narrative_template_id=p_template
           and x.narrative_version_id=p_narrative_version
           and x.lifecycle_state='approved' and x.active)<>1
     or exists(select 1 from public.nb_mechanical_ability_profile_refs_v1 ar
        where ar.mechanical_template_id=mt.id and ar.lifecycle_state='approved' and ar.active)
  then raise exception 'MF_NPC_CUSTOM_MECHANICS_STALE' using errcode='55000';end if;
  snap:=public.nb_mechanical_resolve(p_narrative_version);
  if snap->>'mechanical_template_ref' is distinct from mt.id::text
     or snap->>'mechanical_version_ref' is distinct from mv.id::text
     or snap->>'source_sha256' is distinct from mv.content_sha256
     or snap#>'{snapshot,stats}' is distinct from mv.stats
     or snap#>'{snapshot,abilities}' is distinct from '[]'::jsonb
     or (snap#>>'{snapshot,vita_max}')::integer is distinct from mv.vita_max
     or (snap#>>'{snapshot,chakra_max}')::integer is distinct from mv.chakra_max
  then raise exception 'MF_NPC_CUSTOM_SNAPSHOT_STALE' using errcode='55000';end if;
  pair:=png_builder_internal.npc_media_pair_resolve_v1(p_template,p_narrative_version);
  if pair->>'mechanical_template_id' is distinct from mt.id::text
     or pair->>'narrative_content_sha256' is distinct from nv.content_sha256
  then raise exception 'MF_NPC_CUSTOM_MEDIA_STALE' using errcode='55000';end if;
  portrait:=(pair->>'portrait_media_id')::uuid;
  select coalesce(array_agg(m.id order by m.media_version_no,m.id),array[]::uuid[])
    into media from public.nb_template_media_versions m
    where m.template_id=p_template and m.template_version_id=p_narrative_version
      and m.lifecycle_state='approved' and m.active
      and m.sha256=m.verified_sha256;
  if cardinality(media)=0 or portrait<>all(media)
     or cardinality(media)<>(select count(*)::integer from public.nb_template_media_versions m
       where m.template_id=p_template and m.template_version_id=p_narrative_version
         and m.lifecycle_state='approved' and m.active)
  then raise exception 'MF_NPC_CUSTOM_MEDIA_STALE' using errcode='55000';end if;
  doc:=pg_catalog.jsonb_build_object(
    'schema_version','png-builder-sheet/1.0',
    'template_key',t.template_key,'display_name',t.display_name,
    'village_scope',t.village_scope,'source_template_id',t.id,
    'source_template_version_id',nv.id,
    'source_mechanical_template_id',mt.id,'source_mechanical_version_id',mv.id,
    'skeleton',nv.skeleton,'knowledge_boundary',nv.knowledge_boundary,
    'fallback_profile',nv.fallback_profile,
    'media_ids',to_jsonb(media),'ability_refs','[]'::jsonb,
    'consumer_scopes',pg_catalog.jsonb_build_array(
      'surface','narrator_adapter','master_v2','combat_v2'));
  dep:=png_builder_internal.sha(pg_catalog.jsonb_build_object(
    'schema_version','npc-custom-combat-dependency/1',
    'narrative_sha256',nv.content_sha256,'mechanical_sha256',mv.content_sha256,
    'mechanical_binding_id',mb.id,'media_pair',pair,
    'builder_document_sha256',png_builder_internal.sha(doc),
    'snapshot',snap));
  return pg_catalog.jsonb_build_object('document',doc,'dependency_sha256',dep,
    'pair_request_key',pair->>'pair_request_key',
    'mechanical_version_id',mv.id,'mechanical_binding_id',mb.id);
end $function$
;
