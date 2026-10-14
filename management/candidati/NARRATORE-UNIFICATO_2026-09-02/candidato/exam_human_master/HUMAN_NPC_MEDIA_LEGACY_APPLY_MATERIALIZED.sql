BEGIN;
SELECT pg_catalog.set_config('tus.human_media_legacy_authority',$root_authority${"schema_version":"human-media-legacy-authority/1","request_key":"2857ac74-02fc-4940-8217-6f73c129f9be","operation":"install_scoped_legacy_media2_human9","review":"0/0/0","review_sha256":"b759da24386fc5d45322302d616eb7b08dcde881489803ad7325c195e3ce03ba","source_sha256":"5eb8943502d0d31a0dc9e16fe4898193088d5ee331c2272a1338dad8ce14c0ef","issued_at":"2026-10-14T15:45:47.145375+00:00","expires_at":"2026-10-14T16:00:47.145375+00:00","actor_auth":["f0856d53-83a6-4de0-bc0c-12c87916e665","b4952ed5-5ce0-49c0-9f2b-8fd5dcd89b4b"],"lease_expires_at":"2026-10-14T15:50:06.063407Z","lease_changed":false,"client_commit":"fe804deeab6d4f1cbb2ea0ae71c8294398c5c99c","R37":"37dac90525b249f53fc0404b50adb4ed92df0123649326c99260bf656119d806"}$root_authority$,true);
DO $preflight$ DECLARE e jsonb;BEGIN e:=nullif(pg_catalog.current_setting('tus.human_media_legacy_authority',true),'')::jsonb;IF current_user<>'postgres' OR e IS NULL OR e->>'schema_version' IS DISTINCT FROM 'human-media-legacy-authority/1' OR e->>'review' IS DISTINCT FROM '0/0/0' OR coalesce((e->>'expires_at')::timestamptz,'-infinity'::timestamptz)<=clock_timestamp() THEN RAISE EXCEPTION 'HUMAN_MEDIA_LEGACY_AUTHORITY';END IF;
IF to_regprocedure('png_builder_internal.npc_combat_authoring_attest_v2(uuid,uuid,uuid)') IS NOT NULL THEN RAISE EXCEPTION 'HUMAN_MEDIA_LEGACY_ALREADY_INSTALLED';END IF;
IF md5(pg_get_functiondef('mission_factory_owner.npc_custom_authoring_check_v1(uuid,bigint,text,boolean)'::regprocedure)) IS DISTINCT FROM '0a557d30c5cc4bf6cd67ecfb09af4c12' OR (SELECT proacl::text FROM pg_proc WHERE oid='mission_factory_owner.npc_custom_authoring_check_v1(uuid,bigint,text,boolean)'::regprocedure) IS DISTINCT FROM '{postgres=X/postgres}' THEN RAISE EXCEPTION 'HUMAN_MEDIA_LEGACY_BASELINE_DRIFT';END IF;
IF md5(pg_get_functiondef('mission_factory_owner.npc_item_v2(uuid,uuid,text,boolean)'::regprocedure)) IS DISTINCT FROM '15724aea3d25334855a46f968fe7eefe' OR (SELECT proacl::text FROM pg_proc WHERE oid='mission_factory_owner.npc_item_v2(uuid,uuid,text,boolean)'::regprocedure) IS DISTINCT FROM '{postgres=X/postgres}' THEN RAISE EXCEPTION 'HUMAN_MEDIA_LEGACY_BASELINE_DRIFT';END IF;
IF md5(pg_get_functiondef('mission_factory_owner.c408_stage1_complete_assert_v1()'::regprocedure)) IS DISTINCT FROM 'ffa6c6cd8e95a2d8056d796eb0a4d848' OR (SELECT proacl::text FROM pg_proc WHERE oid='mission_factory_owner.c408_stage1_complete_assert_v1()'::regprocedure) IS DISTINCT FROM '{postgres=X/postgres}' THEN RAISE EXCEPTION 'HUMAN_MEDIA_LEGACY_BASELINE_DRIFT';END IF;
IF md5(pg_get_functiondef('mission_factory_owner.c444_runtime_ports_complete_assert_v1()'::regprocedure)) IS DISTINCT FROM 'b12c3dd456f818f70e47cb8ef7776434' OR (SELECT proacl::text FROM pg_proc WHERE oid='mission_factory_owner.c444_runtime_ports_complete_assert_v1()'::regprocedure) IS DISTINCT FROM '{postgres=X/postgres}' THEN RAISE EXCEPTION 'HUMAN_MEDIA_LEGACY_BASELINE_DRIFT';END IF;
IF md5(pg_get_functiondef('png_builder_internal.npc_media_completion_staff_v1(uuid)'::regprocedure)) IS DISTINCT FROM 'c1fa73e741924f28fd1ed80273e9fe32' THEN RAISE EXCEPTION 'HUMAN_MEDIA_LEGACY_DEPENDENCY_DRIFT';END IF;
IF md5(pg_get_functiondef('png_builder_internal.npc_media_pair_resolve_v1(uuid,uuid)'::regprocedure)) IS DISTINCT FROM '582de6ce3ee789b9906bc0eb58df9ba1' THEN RAISE EXCEPTION 'HUMAN_MEDIA_LEGACY_DEPENDENCY_DRIFT';END IF;
IF md5(pg_get_functiondef('mission_factory_owner.npc_reference(uuid,uuid,boolean)'::regprocedure)) IS DISTINCT FROM 'b18072cc0d02f88b059e8dfd5603e3e2' THEN RAISE EXCEPTION 'HUMAN_MEDIA_LEGACY_DEPENDENCY_DRIFT';END IF;
IF md5(pg_get_functiondef('png_builder_internal.npc_custom_combat_attest_assert_v1(uuid,uuid,uuid)'::regprocedure)) IS DISTINCT FROM '9682652b8b60dba7e161c6a592017791' THEN RAISE EXCEPTION 'HUMAN_MEDIA_LEGACY_DEPENDENCY_DRIFT';END IF;
PERFORM mission_factory_owner.c444_runtime_ports_complete_assert_v1();END $preflight$;
CREATE FUNCTION png_builder_internal.npc_combat_authoring_attest_v2(p_template uuid,p_narrative_version uuid,p_bundle uuid) RETURNS jsonb LANGUAGE plpgsql SECURITY DEFINER SET search_path='' AS $function$
DECLARE b png_builder_internal.bundles%rowtype; pair jsonb; expected jsonb; reference jsonb;
BEGIN
 SELECT value INTO expected FROM jsonb_array_elements($pins$[{"id":"aec1177c-6173-4575-9259-b9135259da1d","template_id":"82afcf8c-0a2c-447a-b9a5-0cf6a8b067b7","narrative_version_id":"daef66b3-3660-443c-af23-6a7b8351e06e","bundle_sha256":"e68f8491e44ee39a7cdece91e46233df3961f8fd527604642eb5c77081386997","bundle_row_sha":"46dbf5833eb68ada4dea92f5be527518419a6ba75a2f810826abf5bc14bcf725","narrative_row_sha":"0737087d375f7c1b2374d243550d4666851128c548dde418b79d5dcd09375b69","mechanical_row_sha":"d7ac5345c5f47fa278f7a4eac7bf29fcfb856dbae0cef7a400883ea55735f305","binding_row_sha":"4d1a0c7bcac50147ff8bd647b204d55363a9b9ee400708b7910962d7fbba202e","profile_kind":"legacy","pair_request_key":"81b616d5-c271-49ed-8183-25aba54a0a94","pair_row_sha":"77c2f883636d649d093239f1f266fc1f8d263f8bc0964d622b88566df3696ffd","pair":{"state":"approved","actor_id":"f0856d53-83a6-4de0-bc0c-12c87916e665","response":{"state":"approved","active":true,"replayed":false,"request_key":"81b616d5-c271-49ed-8183-25aba54a0a94","template_id":"82afcf8c-0a2c-447a-b9a5-0cf6a8b067b7","marker_sha256":"e1636bd9875d3498e6be784cd84cc719d222082a92338d1257749fb7af75bbcf","schema_version":"npc-media-pair/1","marker_media_id":"8ce05c7a-f2e3-458d-a5ec-859ae71a2bd5","portrait_sha256":"7507ddaede8b77c13ed2716895729e80d1c4b8b9c0e60cf43c443b6b4aa59bde","portrait_media_id":"954cb0c9-249c-48e3-88d5-c414710b6e9e","narrative_version_id":"daef66b3-3660-443c-af23-6a7b8351e06e","mechanical_template_id":null,"narrative_content_sha256":"82f94df8b3cf728799f15c3dcb47ae50bd3b0457b19455184205558fd0e3cb2c"},"created_at":"2026-10-14T14:33:14.396456+00:00","fingerprint":"ea14f247069a77b17958df540d2850c45914a2bf76228e295f4cfecd88507196","request_key":"81b616d5-c271-49ed-8183-25aba54a0a94","template_id":"82afcf8c-0a2c-447a-b9a5-0cf6a8b067b7","marker_request":"a6e058f6-35cd-4e17-a4f4-e9804dd0702a","portrait_request":"6a44596d-6fdf-411d-8af4-4d63e7b93eee","narrative_version_id":"daef66b3-3660-443c-af23-6a7b8351e06e","mechanical_template_id":null,"narrative_content_sha256":"82f94df8b3cf728799f15c3dcb47ae50bd3b0457b19455184205558fd0e3cb2c"}},{"id":"7bb53e62-f30c-4c94-b464-8b37a9291cdf","template_id":"0aaecee9-7e33-4e91-9a95-af1d691f3a40","narrative_version_id":"e962b36d-69ba-41ff-9d9f-4b91934cc226","bundle_sha256":"7e08d81e4787fdf0a9c58d437dae9bda7f129cf65818fe6d47a8ea4fac667c3a","bundle_row_sha":"19edd848f2a91a00ae45c3c2264f0e1134445e7cf80f209412ba4e9e6958989c","narrative_row_sha":"2c2d45c0a99e623b17f02c3a942f062353df94dfd098bbc771f4ce55cbb6192a","mechanical_row_sha":"62a651378d7c47a5b7660c0ff251ffdfc42ba7f25074d7a862d32ee8ff68a94c","binding_row_sha":"276376bad55b051371f278f01b671248445ab10d3bc50f50e09452f47ac5425a","profile_kind":"legacy","pair_request_key":"24172edc-a62b-4222-ba54-b6b4c868d01f","pair_row_sha":"2450557ec081c2c1c05671a81a846f6a5516d6fa329d6361cc6026c45cff0486","pair":{"state":"approved","actor_id":"f0856d53-83a6-4de0-bc0c-12c87916e665","response":{"state":"approved","active":true,"replayed":false,"request_key":"24172edc-a62b-4222-ba54-b6b4c868d01f","template_id":"0aaecee9-7e33-4e91-9a95-af1d691f3a40","marker_sha256":"1f9bba5d8ca13fba29178e4de164f9a3b56285766e5e1636dd60a90c05465e0e","schema_version":"npc-media-pair/1","marker_media_id":"dff729ec-dc39-4c55-8df8-2d9cc4bd97dd","portrait_sha256":"316fa42b3a7e85123d9b8e6027182f427a4330cf9b7ab664d665718d76e183b7","portrait_media_id":"a91ed65e-e026-444d-a740-5b0b249418ae","narrative_version_id":"e962b36d-69ba-41ff-9d9f-4b91934cc226","mechanical_template_id":null,"narrative_content_sha256":"86c3d4da1eaa347067899f99598d43f1cb65bbc09d7bb4e88100bea526117940"},"created_at":"2026-10-14T14:36:11.212676+00:00","fingerprint":"aaf1344370b68985529d4f0d5bb8fe2db490890ba5f747dde8b80ee47b7d0dd8","request_key":"24172edc-a62b-4222-ba54-b6b4c868d01f","template_id":"0aaecee9-7e33-4e91-9a95-af1d691f3a40","marker_request":"2979229b-699f-43c9-a65d-60a81e4be733","portrait_request":"16a046ea-62b7-40a2-9ff2-5f615a614972","narrative_version_id":"e962b36d-69ba-41ff-9d9f-4b91934cc226","mechanical_template_id":null,"narrative_content_sha256":"86c3d4da1eaa347067899f99598d43f1cb65bbc09d7bb4e88100bea526117940"}}]$pins$::jsonb) x WHERE x.value->>'id'=p_bundle::text AND x.value->>'template_id'=p_template::text AND x.value->>'narrative_version_id'=p_narrative_version::text;
 IF expected IS NULL THEN RETURN png_builder_internal.npc_custom_combat_attest_assert_v1(p_template,p_narrative_version,p_bundle);END IF;
 IF png_builder_internal.npc_media_completion_staff_v1(auth.uid()) IS DISTINCT FROM true THEN RAISE EXCEPTION 'MF_NPC_LEGACY_STAFF_CLOSED' USING ERRCODE='55000';END IF;
 SELECT * INTO STRICT b FROM png_builder_internal.bundles WHERE id=p_bundle FOR SHARE;
 IF pg_catalog.encode(pg_catalog.sha256(pg_catalog.convert_to(to_jsonb(b)::text,'UTF8')),'hex') IS DISTINCT FROM expected->>'bundle_row_sha'
 OR NOT EXISTS(SELECT 1 FROM public.nb_templates t WHERE t.id=p_template AND t.current_version_id=p_narrative_version AND t.lifecycle_state='approved' AND t.deactivated_at IS NULL)
 OR NOT EXISTS(SELECT 1 FROM public.nb_template_versions nv WHERE nv.id=p_narrative_version AND nv.template_id=p_template AND nv.review_state='approved' AND nv.mechanical_template_id IS NULL AND pg_catalog.encode(pg_catalog.sha256(pg_catalog.convert_to(to_jsonb(nv)::text,'UTF8')),'hex')=expected->>'narrative_row_sha')
 OR NOT EXISTS(SELECT 1 FROM public.nb_mechanical_versions mv WHERE mv.id=b.mechanical_version_id AND mv.template_id=b.mechanical_template_id AND mv.profile_kind='legacy' AND mv.review_state='approved' AND pg_catalog.encode(pg_catalog.sha256(pg_catalog.convert_to(to_jsonb(mv)::text,'UTF8')),'hex')=expected->>'mechanical_row_sha')
 OR NOT EXISTS(SELECT 1 FROM public.nb_mechanical_bindings mb WHERE mb.id=b.mechanical_binding_id AND mb.narrative_template_id=p_template AND mb.narrative_version_id=p_narrative_version AND mb.active AND mb.lifecycle_state='approved' AND pg_catalog.encode(pg_catalog.sha256(pg_catalog.convert_to(to_jsonb(mb)::text,'UTF8')),'hex')=expected->>'binding_row_sha')
 OR EXISTS(SELECT 1 FROM png_builder_internal.npc_combat_draft_heads h WHERE h.narrative_template_id=p_template AND h.narrative_version_id=p_narrative_version)
 OR NOT EXISTS(SELECT 1 FROM png_builder_internal.npc_media_pairs p WHERE p.request_key=(expected->>'pair_request_key')::uuid AND p.template_id=p_template AND p.narrative_version_id=p_narrative_version AND p.state='approved' AND pg_catalog.encode(pg_catalog.sha256(pg_catalog.convert_to(to_jsonb(p)::text,'UTF8')),'hex')=expected->>'pair_row_sha') THEN RAISE EXCEPTION 'MF_NPC_LEGACY_APPROVED_SOURCE_STALE' USING ERRCODE='55000';END IF;
 reference:=mission_factory_owner.npc_reference(p_template,p_bundle,true);
 pair:=png_builder_internal.npc_media_pair_resolve_v1(p_template,p_narrative_version);
 IF reference->>'bundle_sha256' IS DISTINCT FROM expected->>'bundle_sha256' OR pair->>'schema_version' IS DISTINCT FROM 'npc-builder-media-pair/1' OR pair->>'narrative_version_id' IS DISTINCT FROM p_narrative_version::text OR pair->>'portrait_media_id' IS DISTINCT FROM expected#>>'{pair,response,portrait_media_id}' OR pair->>'marker_media_id' IS DISTINCT FROM expected#>>'{pair,response,marker_media_id}' OR pair->>'portrait_sha256' IS DISTINCT FROM expected#>>'{pair,response,portrait_sha256}' OR pair->>'marker_sha256' IS DISTINCT FROM expected#>>'{pair,response,marker_sha256}' THEN RAISE EXCEPTION 'MF_NPC_LEGACY_APPROVED_PAIR_STALE' USING ERRCODE='55000';END IF;
 RETURN jsonb_build_object('bundle_id',b.id,'bundle_sha256',b.bundle_sha256,'dependency_sha256',expected->>'pair_row_sha');
END $function$;
REVOKE ALL ON FUNCTION png_builder_internal.npc_combat_authoring_attest_v2(uuid,uuid,uuid) FROM PUBLIC,anon,authenticated,service_role;
CREATE OR REPLACE FUNCTION mission_factory_owner.npc_custom_authoring_check_v1(p_draft uuid, p_expected_version bigint, p_actor_key text, p_allow_published boolean)
 RETURNS jsonb
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO ''
AS $function$
declare d mission_factory_owner.drafts%rowtype; c mission_factory_owner.catalog_versions%rowtype;
  b jsonb; matched_binding jsonb; ph jsonb; ep jsonb; maprow jsonb; detail jsonb; mapcheck jsonb;
  bn png_builder_internal.bundles%rowtype; ref jsonb; att jsonb;
  errors jsonb:='[]'::jsonb; phases jsonb:='[]'::jsonb;
  kind text; path text; pk text; epkey text; release_sha text;
  npc uuid; version_id uuid; bundle_sha text; idx integer:=0; found_binding boolean:=false;
  found_phase boolean; map_count integer; selected_count integer; binding_count integer;
begin
  if p_draft is null or p_expected_version is null or nullif(btrim(p_actor_key),'') is null
    then raise exception 'MF_NPC_AUTHORING_INPUT' using errcode='22023'; end if;
  select * into d from mission_factory_owner.drafts where id=p_draft;
  if d.id is null then raise exception 'MF_DRAFT_NOT_FOUND' using errcode='P0002'; end if;
  if d.control_version is distinct from p_expected_version
     or d.document_sha256 is distinct from mission_factory_owner.sha(d.document)
     or p_allow_published is null
     or (d.state not in('draft','previewed')
       and not (p_allow_published and d.state='published' and (mission_launch_owner.c11_native_published_draft_v1(d.id,d.control_version) OR exists(
         select 1 from mission_factory_owner.publications pub
           where pub.draft_id=d.id and pub.draft_version=d.control_version
             and pub.state='staff' and pub.target='staff'
             and pub.release_revision_sha256 is not null))))
    then raise exception 'MF_NPC_AUTHORING_DRAFT_STALE' using errcode='40001'; end if;
  kind:=case when d.document->>'schema_version'='mission-factory-draft/1' then 'mission'
             when d.document->>'schema_version'='mission-factory-draft/2'
                  and d.document->>'content_kind'='quest_ai' then 'quest_ai'
             WHEN d.document->>'schema_version'='mission-factory-draft/3' AND d.document->>'content_kind'='quest_human' THEN 'quest_human' else null end;
  if kind is null or jsonb_typeof(d.document->'npc_bindings') is distinct from 'array'
    then raise exception 'MF_NPC_AUTHORING_DRAFT_STALE' using errcode='40001'; end if;
  for b in select value from jsonb_array_elements(d.document->'npc_bindings') loop
    if b->>'actor_key'=p_actor_key then
      if found_binding then
        errors:=errors||jsonb_build_array(jsonb_build_object('code','MF_NPC_AUTHORING_BINDING_INVALID',
          'path','npc_bindings['||idx||']','phase_key',null));
      else
        found_binding:=true; path:='npc_bindings['||idx||']'; matched_binding:=b;
      end if;
    end if;
    idx:=idx+1;
  end loop;
  b:=coalesce(matched_binding,'{}'::jsonb);
  if jsonb_typeof(b->'phase_keys') is distinct from 'array'
     or jsonb_typeof(b->'combat') is distinct from 'boolean'
     or b->>'combat' is distinct from 'true' then
    errors:=errors||jsonb_build_array(jsonb_build_object(
      'code','MF_NPC_AUTHORING_BINDING_INVALID','path',coalesce(path,'npc_bindings'),
      'phase_key',null));
  elsif jsonb_array_length(b->'phase_keys')=0 then
    errors:=errors||jsonb_build_array(jsonb_build_object(
      'code','MF_NPC_AUTHORING_BINDING_INVALID','path',coalesce(path,'npc_bindings'),
      'phase_key',null));
  end if;
  if found_binding and coalesce(b->>'npc_id','') ~* '^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$'
     and coalesce(b->>'npc_version_id','') ~* '^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$' then
    npc:=(b->>'npc_id')::uuid; version_id:=(b->>'npc_version_id')::uuid;
    select * into bn from png_builder_internal.bundles
      where id=version_id and template_id=npc;
    if bn.id is null or bn.bundle_kind is distinct from 'combat' then
      errors:=errors||jsonb_build_array(jsonb_build_object('code','MF_NPC_AUTHORING_BUNDLE_STALE',
        'path',coalesce(path,'npc_bindings'),'phase_key',null));
    else
      begin
        ref:=mission_factory_owner.npc_reference(npc,version_id,false);
        att:=png_builder_internal.npc_combat_authoring_attest_v2(
          npc,bn.narrative_version_id,version_id);
        if ref->>'bundle_sha256' is distinct from att->>'bundle_sha256' then
          raise exception 'MF_NPC_CUSTOM_BUNDLE_STALE' using errcode='55000'; end if;
        bundle_sha:=bn.bundle_sha256;
      exception when sqlstate '55000' then
        errors:=errors||jsonb_build_array(jsonb_build_object('code','MF_NPC_AUTHORING_BUNDLE_STALE',
          'path',coalesce(path,'npc_bindings'),'phase_key',null));
      end;
    end if;
  else
    errors:=errors||jsonb_build_array(jsonb_build_object('code','MF_NPC_AUTHORING_BINDING_INVALID',
      'path',coalesce(path,'npc_bindings'),'phase_key',null));
  end if;
  select * into c from mission_factory_owner.catalog_versions
    where version=d.catalog_version and active and qualified;
  if c.version is null or c.document_sha256 is distinct from mission_factory_owner.sha(c.document)
     or (kind='quest_ai' and not mission_factory_owner.quest_catalog_qualified_v2(c.version))
     OR (kind='quest_human' AND NOT mission_factory_owner.c416_kind_live_v1()) then
    errors:=errors||jsonb_build_array(jsonb_build_object('code','MF_NPC_AUTHORING_SOURCE_UNQUALIFIED',
      'path','catalog_version','phase_key',null));
  end if;
  begin
    release_sha:=mission_factory_owner.staff_release_sha_v1();
  exception when sqlstate '55000' then
    errors:=errors||jsonb_build_array(jsonb_build_object('code','MF_NPC_AUTHORING_SOURCE_UNQUALIFIED',
      'path','staff_release','phase_key',null));
  end;
  if jsonb_typeof(b->'phase_keys')='array' then
    for ph in select value from jsonb_array_elements(b->'phase_keys') loop
      if jsonb_typeof(ph) is distinct from 'string' then
        errors:=errors||jsonb_build_array(jsonb_build_object('code','MF_NPC_AUTHORING_PHASE_INVALID',
          'path',coalesce(path,'npc_bindings')||'.phase_keys','phase_key',null));
        continue;
      end if;
      pk:=ph#>>'{}'; phases:=phases||jsonb_build_array(pk); found_phase:=false;
      if kind='mission' then
        for ep in select value from jsonb_array_elements(coalesce(d.document->'phases','[]'::jsonb)) loop
          if ep->>'step_key'=pk then
            found_phase:=true;
            if ep->>'kind' is distinct from 'combat'
               or (jsonb_typeof(ep->'actor_keys')='array' and not (ep->'actor_keys' ? p_actor_key))
               or c.version is null or not exists(
                   select 1 from jsonb_array_elements(coalesce(c.document->'capabilities','[]'::jsonb)) x
                    where x.value->>'key'=ep->>'capability_key' and x.value->>'qualified'='true') then
              errors:=errors||jsonb_build_array(jsonb_build_object('code','MF_NPC_AUTHORING_PHASE_INVALID',
                'path','phases.'||pk,'phase_key',pk));
            end if;
            select x.value into maprow from jsonb_array_elements(coalesce(d.document->'maps','[]'::jsonb)) x
              where x.value->>'step_key'=pk;
            if maprow is null or jsonb_typeof(maprow->'combat_map') is distinct from 'object' then
              errors:=errors||jsonb_build_array(jsonb_build_object('code','MF_NPC_AUTHORING_ARENA_INVALID',
                'path','phases.'||pk,'phase_key',pk));
            else
              begin
                detail:=public.mission_map_detail_v1(maprow#>>'{combat_map,template_key}',
                  (maprow#>>'{combat_map,template_version}')::integer);
                selected_count:=(select count(*)::integer from jsonb_array_elements(d.document->'npc_bindings') x
                  where x.value->'phase_keys' ? pk);
                mapcheck:=public.mission_map_preview_v1(detail->'spec',
                  case when coalesce(d.document#>>'{mission,team_max}','') ~ '^[1-4]$'
                    then (d.document#>>'{mission,team_max}')::integer else 4 end,selected_count);
                if detail->>'status' is distinct from 'ready'
                   or coalesce((detail->>'selectable')::boolean,false) is not true
                   or coalesce((mapcheck->>'valid')::boolean,false) is not true
                   or coalesce((mapcheck->>'can_fit')::boolean,false) is not true then
                  raise exception 'MF_ARENA_INVALID' using errcode='55000'; end if;
              exception when sqlstate '55000' or invalid_text_representation then
                errors:=errors||jsonb_build_array(jsonb_build_object('code','MF_NPC_AUTHORING_ARENA_INVALID',
                  'path','phases.'||pk,'phase_key',pk));
              end;
            end if;
            exit;
          end if;
        end loop;
      else
        for ep in select value from jsonb_array_elements(coalesce(d.document#>'{quest,episodes}','[]'::jsonb)) loop
          epkey:=ep->>'episode_key';
          if not (ep->'npc_actor_keys' ? p_actor_key) then continue; end if;
          for maprow in select value from jsonb_array_elements(coalesce(ep->'phases','[]'::jsonb)) loop
            if epkey||'/'||(maprow->>'step_key')=pk then
              found_phase:=true;
              if maprow->>'capability_key' is distinct from 'combat.encounter' then
                errors:=errors||jsonb_build_array(jsonb_build_object('code','MF_NPC_AUTHORING_PHASE_INVALID',
                  'path','quest.episodes.'||epkey||'.phases.'||(maprow->>'step_key'),'phase_key',pk));
              end if;
              select x.value into detail from jsonb_array_elements(coalesce(ep->'maps','[]'::jsonb)) x
                where x.value->>'step_key'=maprow->>'step_key';
              if jsonb_typeof(detail->'arena_ref') is distinct from 'object'
                 or coalesce(detail#>>'{arena_ref,template_version}','') !~ '^[1-9][0-9]{0,8}$'
                 or not exists(select 1 from combat_spatial.arena_templates a
                    where a.template_key=detail#>>'{arena_ref,template_key}'
                      and a.template_version=(detail#>>'{arena_ref,template_version}')::integer
                      and a.status='ready'
                      and combat_spatial.template_errors(a.template_key,a.template_version)='[]'::jsonb
                      and a.geometry_hash is not distinct from
                        combat_spatial.geometry_fingerprint(a.template_key,a.template_version)) then
                errors:=errors||jsonb_build_array(jsonb_build_object('code','MF_NPC_AUTHORING_ARENA_INVALID',
                  'path','quest.episodes.'||epkey||'.maps.'||(maprow->>'step_key'),'phase_key',pk));
              end if;
              exit;
            end if;
          end loop;
          if found_phase then exit; end if;
        end loop;
      end if;
      if not found_phase then
        errors:=errors||jsonb_build_array(jsonb_build_object('code','MF_NPC_AUTHORING_PHASE_INVALID',
          'path',coalesce(path,'npc_bindings')||'.phase_keys','phase_key',pk));
      end if;
    end loop;
  end if;
  return jsonb_build_object('schema_version','mission-factory-npc-authoring-check/1',
    'draft_id',d.id,'draft_control_version',d.control_version,'draft_sha256',d.document_sha256,
    'content_kind',kind,'actor_key',p_actor_key,'npc_id',npc,'npc_version_id',version_id,
    'bundle_sha256',bundle_sha,'phase_keys',phases,
    'status',case when errors='[]'::jsonb then 'selectable' else 'blocked' end,
    'staff_selectable',errors='[]'::jsonb,'reason_code',errors->0->>'code',
    'errors',errors,'staff_release_sha256',release_sha);
end $function$
;
CREATE OR REPLACE FUNCTION mission_factory_owner.npc_item_v2(p_npc uuid, p_version uuid, p_content_kind text, p_require_combat boolean)
 RETURNS jsonb
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO ''
AS $function$
declare c mission_factory_owner.catalog_versions; b png_builder_internal.bundles;
        n public.nb_templates; nv public.nb_template_versions;
        base_ref jsonb; combat_ref jsonb; media jsonb; scopes text[]:='{}'; combat_ok boolean:=false; staff_candidate boolean:=false;
begin
  if p_content_kind not in('mission','quest_ai','quest_human','archive') or p_content_kind is null
     or p_require_combat is null or p_npc is null or p_version is null
  then raise exception 'MF_NPC_V2_INPUT' using errcode='22023'; end if;
  select * into c from mission_factory_owner.catalog_versions where active and qualified;
  if c.version is null or mission_factory_owner.sha(c.document)<>c.document_sha256
    then raise exception 'MF_NPC_V2_CATALOG' using errcode='55000'; end if;
  scopes:=pg_catalog.array_append(scopes,'mission');
  if mission_factory_owner.quest_catalog_qualified_v2(c.version)
    then scopes:=pg_catalog.array_append(scopes,'quest_ai'); end if;
  IF mission_factory_owner.c416_kind_live_v1() THEN scopes:=pg_catalog.array_append(scopes,'quest_human');END IF;
  if exists(select 1 from jsonb_array_elements(coalesce(c.document->'content_kinds','[]'::jsonb)) x
      where x.value->>'kind'='archive' and x.value->>'qualified'='true')
    then scopes:=pg_catalog.array_append(scopes,'archive'); end if;
  if not p_content_kind=any(scopes) then
    raise exception 'MF_NPC_V2_CONTENT_UNQUALIFIED' using errcode='55000'; end if;
  base_ref:=mission_factory_owner.npc_reference(p_npc,p_version,false);
  begin
    combat_ref:=mission_factory_owner.npc_reference(p_npc,p_version,true);
    combat_ok:=true;
  exception when SQLSTATE '55000' then combat_ok:=false;
  end;
  if p_require_combat and not combat_ok then
    raise exception 'MF_NPC_V2_COMBAT_UNQUALIFIED' using errcode='55000'; end if;
  select * into b from png_builder_internal.bundles where id=p_version and template_id=p_npc;
  select * into n from public.nb_templates where id=b.template_id;
  select * into nv from public.nb_template_versions where id=b.narrative_version_id;
  media:=png_builder_internal.npc_media_pair_resolve_v1(p_npc,b.narrative_version_id);
  if b.bundle_kind='combat' and public.is_staff() is true then
    begin
      perform png_builder_internal.npc_combat_authoring_attest_v2(
        b.template_id,b.narrative_version_id,b.id);
      staff_candidate:=true;
    exception when SQLSTATE '55000' then staff_candidate:=false; end;
  end if;
  if b.id is null or n.id is null or nv.id is null
     or media->>'schema_version' is distinct from 'npc-builder-media-pair/1'
     or media->>'narrative_version_id' is distinct from b.narrative_version_id::text
     or base_ref->>'bundle_sha256' is distinct from b.bundle_sha256
  then raise exception 'MF_NPC_V2_STALE' using errcode='55000'; end if;
  return jsonb_build_object('npc_id',p_npc,'npc_version_id',p_version,
    'name',n.display_name,'version',nv.version_no,
    'bundle_sha256',b.bundle_sha256,'usage_scopes',to_jsonb(scopes),
    'bundle_kind',b.bundle_kind,
    'capabilities',case when combat_ok then jsonb_build_array('narrative','combat') else jsonb_build_array('narrative') end,
    'combat',combat_ok,'staff_authoring_candidate',staff_candidate,
    'portrait_media_id',media->'portrait_media_id',
    'portrait_sha256',media->>'portrait_sha256',
    'marker_media_id',media->'marker_media_id',
    'marker_sha256',media->>'marker_sha256');
end $function$
;
CREATE OR REPLACE FUNCTION mission_factory_owner.c408_stage1_complete_assert_v1()
 RETURNS void
 LANGUAGE plpgsql
 STABLE SECURITY DEFINER
 SET search_path TO ''
AS $function$
BEGIN
 IF NOT EXISTS(SELECT 1 FROM mission_factory_owner.c422_install_progress WHERE singleton AND complete AND next_unit=20 AND source_input_sha256='8085b8a1127f9d2d86301eafac37e2f6c70fb48cde55f2a9f5bfdcc94eee7093') THEN RAISE EXCEPTION 'C422_COMPOSED_HUMAN_QUALIFICATION_REQUIRED' USING ERRCODE='42501';END IF;
 IF NOT EXISTS(SELECT 1 FROM mission_factory_owner.c408_install_progress WHERE singleton AND source_input_sha256='17d5690518e455e22925aaf3f3d0f44bdd82ae86df6872fa7aea621a6a7e98b3' AND complete AND next_unit=16 AND target_ddl_qualification_sha256~'^[0-9a-f]{64}$') THEN RAISE EXCEPTION 'C408_ALL_UNITS_AND_ACTUAL_DDL_QUALIFICATION_REQUIRED' USING ERRCODE='42501';END IF;
 IF EXISTS(SELECT 1 FROM (SELECT jsonb_build_array(('["mission_academy_owner","mission_creation_owner","mission_factory_owner","mission_public_owner","public"]'::jsonb->>(p->>0)::int)||'.'||(p->>1)||'('||coalesce((SELECT string_agg('["mission_factory_owner.quest_run_sources","pg_catalog._text","pg_catalog._uuid","pg_catalog.bool","pg_catalog.int4","pg_catalog.int8","pg_catalog.jsonb","pg_catalog.text","pg_catalog.timestamptz","pg_catalog.uuid","public.mission_plan_transitions","public.mission_run_state"]'::jsonb->>v::int,',' ORDER BY o) FROM jsonb_array_elements_text(p->2)WITH ORDINALITY AS z(v,o)),'')||')',p->3)||('[[true,"v","postgres",["search_path=\"\""],["postgres"]],[true,"s","postgres",["search_path=\"\""],["postgres"]],[false,"v","postgres",["search_path=\"\""],["postgres"]],[true,"s","postgres",["search_path=\"\""],["authenticated","postgres"]],[false,"i","postgres",["search_path=\"\""],["postgres"]],[true,"v","postgres",["search_path=\"\""],["authenticated","postgres"]],[true,"v","postgres",["search_path=\"\""],["postgres","service_role"]]]'::jsonb->(p->>4)::int) AS e FROM jsonb_array_elements('[[2,"c347_receipt_immutable_v1",[],"0126db34638caad0c40be6769c1d9d4e",0],[2,"c347_native_facts_v1",[9,7,9,7],"a222ed36c37b64f89dbe2b69cc5c8430",0],[2,"c347_issue_native_receipt_v1",[9,7,9,7,9],"a57dbd085d2e61ce319e670ed5fb1f20",0],[2,"c347_validate_native_receipt_v1",[6,9,7,8],"5b2a22345f2be306c891ee74b836b4cf",0],[2,"c352_history_immutable_v1",[],"b0a870be4f5fe115f082be38a514e783",0],[2,"c352_native_resource_source_v1",[],"5902f4292ef7b167aa1ad664255fdcee",1],[2,"c352_prepare_resource_v1",[6],"e40a932dcdd73e39068268e94f8345d0",2],[2,"c352_resource_catalog_v1",[],"b77c874e033de63803c9958672d36fe1",1],[4,"mission_factory_catalog_v1",[],"0b3a4e84fd53535061dd2bb2365d7f0f",3],[4,"mission_factory_catalog_v2",[],"c97e223d2eb6870748bb1d7a74890935",1],[0,"c353_effective_threshold_v1",[4,4,4],"49ffebf8d9071f694d38c9146fa545e3",4],[2,"c353_d100_immutable_v1",[],"3c87bd34a14a37b09572b82b96346392",0],[4,"mission_factory_quest_d100_policy_catalog_v1",[9],"7776317a0494bc7399fdb1300707771b",5],[4,"mission_factory_quest_d100_bind_receipt_v1",[9],"6ccdcab28455c1ce108fe8658a2ee4f9",5],[4,"mission_factory_quest_d100_bind_v1",[9,9,7,7,9,9,7,7,5,9],"48793d9952ac0dcbb181213bc91357d0",5],[2,"c353_after_d100_v1",[9,9,9,4],"e5d1694567e73c4d52775b3377d0ba14",0],[2,"c353_d100_receipt_assert_v1",[9,9],"dd1f942ea6854165e06a160625c1c4e7",0],[0,"after_d100",[9,9,9,4],"ce9c2580b8752105427d3a3b0291286c",0],[2,"c360_phase_shape_v1",[6],"f2e2c8743c7ac168d7a78b806ee74f1f",4],[2,"c360_native_phase_assert_v1",[6],"e61d7db8292f98acdb2518077f3601f3",1],[4,"mission_factory_quest_d100_draft_policy_catalog_v1",[9,5],"da84606351828d80fdada5b64c2af7f8",3],[4,"mission_factory_quest_d100_wakeup_scope_v1",[9,9],"ffc02816fcc5e335ba7899fa72eb3fe5",6],[4,"mission_factory_quest_d100_pending_v1",[9],"57e7babb21507b6df6ca4d0d5c1aee35",6],[4,"mission_factory_quest_d100_consume_v1",[9,9,7],"d2ce506b547f1d7082194d57d1739dc7",6],[2,"validate_quest_draft_v2",[6],"0da0e5522287738b33f17b90d7a1c432",4],[2,"quest_deep_validate_v2",[9,6],"72b51aecd719c425d1d6c6dd3739f952",0],[2,"quest_compile_v1",[9],"e31e74e9fc87bf1582b63f4626267f30",0],[2,"quest_compile_check_v1",[9],"b1a3a6e9339da34d45cea23d21ee4832",1],[2,"quest_preview_basis_v1",[9,5,3],"21939a37af4b02c54d34719be2745e23",0],[2,"quest_decision_issue_v1",[9,9,5,7,7,9,7],"2fc5c1e420c123f032d2f2108e604ad9",0],[2,"quest_validate_evidence_v1",[11,10,6,8],"8475b5d8c73c3e1717961d6542e8cc99",0],[2,"c360_activate_staff_catalog_v1",[6],"94832819f80c8bb3f99dc0fcf45c721c",0],[4,"mission_factory_quest_d100_binding_scope_v1",[9],"6b43ebbdc6cb21c93927d40e63628c57",5],[2,"c384_validate_variant_v2",[6,6,7],"0c74df4b6335a21c24b7ba1eed34a069",4],[2,"c384_validate_dual_draft_v3",[6],"aaf868bba0da5b5eaece8bebf85f286c",4],[2,"c384_immutable_v1",[],"32299e2f2f941b22708fb8efd5f86c67",0],[2,"c384_dual_save_v1",[9,5,6,9],"ef79df6cbdd4ed5f700aaae4345f2cc5",0],[2,"c384_human_identity_v1",[9],"d51d2239739d5d5dfe264a2877d52d37",1],[2,"c384_human_publication_replay_v1",[9,9,7,5,9],"28da0ea196460f7810a67fafe3a786be",1],[2,"c384_human_bind_seal_v1",[9,9,5,9,9,9],"f7859e1d6b17f93a6fe7a54a0fc0f0d9",0],[2,"c395_prepare_assert_v1",[9,5,9,9],"2be3242bf59b21fcce437f062b0a32af",0],[2,"c395_revision_issue_v1",[9,5,9,9,9],"a863ba94b3412d0c58c2e7c2efa8139b",0],[2,"c395_binding_projection_v1",[0],"0b66c70fde49fea2925ce146ccd2f23b",1],[2,"c395_binding_insert_assert_v1",[9,9,6,7],"baa7abfe2e70335660d32b26cd77e888",0],[2,"c395_revision_assert_v1",[9],"00ecc50309178677bec990dce0e93daa",1],[2,"c395_human_mode_v1",[9],"98c2dd9142429998bfc8d137aee19c40",1],[2,"c395_active_human_assert_v1",[9],"8b80feeff37e0402120fa68b2b086947",0],[2,"c395_start_assert_v1",[9],"d0f82355e6d1ef9897edc76a26c96d54",0],[4,"mission_factory_quest_human_prepare_v1",[9,9,9,2,9,5,9],"2a83b1c57d14cc4f37b1326c0b68cc8b",5],[4,"mission_factory_quest_human_start_v1",[9,5,9],"8b72b71be42b248c1ca85b3eccadcaf9",5],[2,"c395_source_assert_v1",[9],"56dc0aaf7b5cde324f58947752510d50",0],[2,"quest_run_binding_guard_v1",[],"5efa189afcb8e3639054b42efaa37d2f",0],[1,"is_human",[9],"f9f3cfd42b5f9a0059247a97e8167881",1],[1,"human_assert",[9],"1ce886cdc79e7119ec47b59f52185c32",0],[2,"quest_run_source_assert_v1",[9],"0fb2f5aca06a41479f22c1ecf07738ee",0],[1,"route_human_outbox",[],"e909272590bc59976f63ce6f3a44e914",0],[2,"c407_identity_v1",[9],"ef0a29b5053665ad13f2df4fb57cccd3",1],[2,"c407_active_v1",[9,7],"ee1cd8d251f1eebbc056baf69b019239",0],[2,"c407_enroll_v1",[9],"e6d59bd7d1515ecea0388626cde25a5a",0],[2,"c407_arena_v1",[9,7],"ce8a15514bc292939a455f687bea04c1",1],[4,"mission_factory_quest_human_fato_publish_v1",[9,9,7,9],"77ec29bb0d60fde6d9d5cc08d446d168",5],[4,"mission_factory_quest_human_d100_consume_v1",[9,9,7],"01bbdb51911e2a380847da0040a2c3eb",5],[1,"human_enroll",[9],"a73a003f10d4a1cff816635cf9990ccb",0],[1,"arena_for_step",[9,7],"1e6146a461ce898ec9d846b92d936f95",1],[1,"human_open",[9,9],"fc283362174d39a7cdabfbc4f67d2c4f",0],[3,"human_fato_scope_allowed_v2",[9],"c9f378ec6523f9d035435fa2fb353e34",1],[2,"quest_apply_authority_v1",[9,9,5,5,7,7,9,7,9],"09d2cd933b2f09f39cd3da13bcb9ffba",0],[2,"c412_read_identity_v1",[9],"7bdd302698207fd7f01b8cbf49920aaf",1],[2,"c412_revision_provenance_v1",[9],"707f715cbe2b964406560dd9c0b83b94",1],[2,"c412_source_assert_v1",[9],"a9526ea4216b8ba83d9097ebc0c92fef",0],[4,"mission_factory_quest_dual_save_v3",[9,5,6,9],"9a8b197d1d78ad0a928ca2b4de99b7f8",5],[4,"mission_factory_quest_dual_get_v3",[9,5],"8e7e961d7882cec1d327081df78cd17c",3],[2,"c412_fact_issue_v1",[9,9,5,7,7,9,7],"b9c290f201b1fc59938a024030242d6a",0],[2,"c412_fact_assert_v1",[9,9,5,7,7,7],"bc2377f4dd9a6c9d838b0a62889546e1",1],[4,"mission_factory_quest_human_terminal_prepare_v1",[9,9,5,9],"92df20717f2485b94a04220603ac32af",5],[4,"mission_factory_quest_human_terminal_publish_v1",[9,9,7,9],"770a3a4d053e3e9ef1d60b11563d44f6",5],[4,"mission_factory_quest_human_phase_action_v1",[9,5,7,7,9],"c275d93276703b033fdf874c31bbbea1",5],[4,"mission_factory_quest_human_round_publish_v1",[9,9,7,5,9],"054ae3e2c80bb9bca9c209048021bd19",5],[2,"c412_manual_fato_write_v1",[9,9,7,9],"a00e737d3e0363a7244c199b4707dc67",0],[2,"c416_kind_live_v1",[],"96766167969aff87b3b11452fd15c598",1],[2,"c416_cap_allowed_v1",[6,7],"86e797ff93036bafaab6867253618b45",1],[2,"c416_root_kind_register_v1",[7,7,1,2,9,6],"e664dbaa69f3f6ced90c6eb81952f8bc",0],[2,"c416_draft_assert_v1",[9,3],"f6325524e99d514ea5830dcd0425227b",1],[2,"c416_arc_assert_v1",[9,3],"2a18f541eafd92baa107cda0f15d2550",1],[4,"mission_factory_quest_dual_create_v3",[9,5,6,2,9],"1262390e33c3c3e885216b26bb1e609d",5],[2,"c416_validate_human_draft_v3",[6],"b36495eebd3071f3c62bb715e19b068a",4],[2,"c416_preview_basis_v3",[9,5,3],"5b5982b93629c7ca47e2d9679693cda9",0],[4,"mission_factory_quest_human_preview_v3",[9,5],"89efad0cce80f20c2b3f29ed9e5df565",5],[4,"mission_factory_quest_human_publish_v3",[9,5,7,9,7,8],"1caccca9ba9448a86b6f5fb57532c5ab",5],[2,"npc_item_v2",[9,9,7,3],"dc260f7771e6ffd8d6d99ce67eb96de7",0],[2,"npc_custom_authoring_check_v1",[9,5,7,3],"cf5dee3ae732ef35c640e33121753f37",0],[2,"quest_publication_scope_v3",[9,3],"775033ca8434cbd732ca9fce7668b9d1",0],[2,"quest_roster_scope_assert_v3",[9,9,2],"cb8a7829e234612c84a9d21673c71e9c",0],[4,"mission_factory_context_media_ticket_v2",[9,7,7,9,7,5,7],"d6a233ac4e184c550625ee11a2dbf173",5],[4,"mission_factory_context_media_register_v2",[9,7,5,7,4,4],"a483d59ca8f9cbc742da777db08c6dee",6],[4,"mission_factory_context_media_catalog_v2",[9,7],"a5c4f7faaeeeb65e40dd344df600add9",3],[4,"mission_factory_quest_dual_import_v3",[9,5,6,2,9,5,9],"ae17f8d86d158e5293701d1fad0c85a7",5]]'::jsonb) AS z(p)) AS seal LEFT JOIN pg_proc f ON f.oid=to_regprocedure(e->>0) WHERE f.oid IS NULL OR md5(f.prosrc) IS DISTINCT FROM e->>1 OR f.prosecdef IS DISTINCT FROM (e->>2)::boolean OR f.provolatile::text IS DISTINCT FROM e->>3 OR pg_get_userbyid(f.proowner) IS DISTINCT FROM e->>4 OR to_jsonb(f.proconfig) IS DISTINCT FROM e->5 OR coalesce((SELECT jsonb_agg(CASE WHEN a.grantee=0 THEN 'PUBLIC' ELSE pg_get_userbyid(a.grantee) END ORDER BY CASE WHEN a.grantee=0 THEN 'PUBLIC' ELSE pg_get_userbyid(a.grantee) END) FROM aclexplode(coalesce(f.proacl,acldefault('f',f.proowner))) a WHERE a.privilege_type='EXECUTE'),'[]'::jsonb) IS DISTINCT FROM e->6 OR EXISTS(SELECT 1 FROM aclexplode(coalesce(f.proacl,acldefault('f',f.proowner))) a WHERE a.is_grantable)) THEN RAISE EXCEPTION 'C408_COMPLETE_FUNCTION_CAS' USING ERRCODE='40001';END IF;
END $function$
;
CREATE OR REPLACE FUNCTION mission_factory_owner.c444_runtime_ports_complete_assert_v1()
 RETURNS void
 LANGUAGE plpgsql
 STABLE SECURITY DEFINER
 SET search_path TO ''
AS $function$BEGIN
IF EXISTS(SELECT 1 FROM jsonb_array_elements($c501_pins$[{"all_arg_types":[],"arg_modes":[],"arg_names":null,"body_md5":"a1a62570ed25596789d82171e465e2e2","configuration":["search_path=\"\""],"default_arg_count":0,"execute":["postgres"],"input_arg_types":[],"language":"plpgsql","lookup_signature":"mission_factory_owner.c408_stage1_complete_assert_v1()","oid":"279179","owner":"postgres","parallel":"u","return_type":"pg_catalog.void","returns_set":false,"security_definer":true,"strict":false,"variadic_type":null,"volatility":"s"}]$c501_pins$::jsonb) c501_expected LEFT JOIN pg_catalog.pg_proc c501_proc ON c501_proc.oid=pg_catalog.to_regprocedure(c501_expected->>'lookup_signature') WHERE c501_proc.oid IS NULL OR (c501_expected->>'oid' IS NOT NULL AND c501_proc.oid::text IS DISTINCT FROM c501_expected->>'oid') OR md5(c501_proc.prosrc) IS DISTINCT FROM c501_expected->>'body_md5' OR c501_proc.proargtypes::text IS DISTINCT FROM coalesce((SELECT string_agg(pg_catalog.to_regtype(c501_argtype)::oid::text,' ' ORDER BY c501_ord)FROM jsonb_array_elements_text(c501_expected->'input_arg_types')WITH ORDINALITY c501_inputs(c501_argtype,c501_ord)),'') OR coalesce((SELECT jsonb_agg(pg_catalog.format('%I.%I',c501_ns.nspname,c501_type.typname) ORDER BY c501_ord)FROM unnest(coalesce(c501_proc.proallargtypes,c501_proc.proargtypes::oid[]))WITH ORDINALITY c501_all(c501_type_oid,c501_ord)JOIN pg_catalog.pg_type c501_type ON c501_type.oid=c501_type_oid JOIN pg_catalog.pg_namespace c501_ns ON c501_ns.oid=c501_type.typnamespace),'[]'::jsonb) IS DISTINCT FROM c501_expected->'all_arg_types' OR to_jsonb(coalesce(c501_proc.proargmodes,array_fill('i'::"char",ARRAY[c501_proc.pronargs]))) IS DISTINCT FROM c501_expected->'arg_modes' OR coalesce(to_jsonb(c501_proc.proargnames),'null'::jsonb) IS DISTINCT FROM c501_expected->'arg_names' OR c501_proc.prorettype IS DISTINCT FROM pg_catalog.to_regtype(c501_expected->>'return_type') OR c501_proc.proretset IS DISTINCT FROM(c501_expected->>'returns_set')::boolean OR c501_proc.pronargdefaults IS DISTINCT FROM(c501_expected->>'default_arg_count')::integer OR (c501_proc.pronargdefaults=0 AND c501_proc.proargdefaults IS NOT NULL) OR c501_proc.provariadic IS DISTINCT FROM coalesce(pg_catalog.to_regtype(c501_expected->>'variadic_type')::oid,0::oid) OR c501_proc.proisstrict IS DISTINCT FROM(c501_expected->>'strict')::boolean OR c501_proc.provolatile::text IS DISTINCT FROM c501_expected->>'volatility' OR c501_proc.proparallel::text IS DISTINCT FROM c501_expected->>'parallel' OR c501_proc.prosecdef IS DISTINCT FROM(c501_expected->>'security_definer')::boolean OR(SELECT lanname FROM pg_catalog.pg_language WHERE oid=c501_proc.prolang)IS DISTINCT FROM c501_expected->>'language' OR to_jsonb(c501_proc.proconfig) IS DISTINCT FROM c501_expected->'configuration' OR pg_catalog.pg_get_userbyid(c501_proc.proowner)IS DISTINCT FROM c501_expected->>'owner' OR c501_proc.proleakproof OR coalesce((SELECT jsonb_agg(CASE WHEN c501_acl.grantee=0 THEN 'PUBLIC' ELSE pg_catalog.pg_get_userbyid(c501_acl.grantee)END ORDER BY CASE WHEN c501_acl.grantee=0 THEN 'PUBLIC' ELSE pg_catalog.pg_get_userbyid(c501_acl.grantee)END)FROM pg_catalog.aclexplode(coalesce(c501_proc.proacl,pg_catalog.acldefault('f',c501_proc.proowner)))c501_acl WHERE c501_acl.privilege_type='EXECUTE'),'[]'::jsonb)IS DISTINCT FROM c501_expected->'execute' OR EXISTS(SELECT 1 FROM pg_catalog.aclexplode(coalesce(c501_proc.proacl,pg_catalog.acldefault('f',c501_proc.proowner)))c501_acl WHERE c501_acl.is_grantable))THEN RAISE EXCEPTION 'C501_CURRENT_HUMAN_QUALIFIER_ABI_CAS' USING ERRCODE='40001';END IF;
PERFORM mission_factory_owner.c408_stage1_complete_assert_v1();
IF NOT EXISTS(SELECT 1 FROM mission_factory_owner.c444_install_progress WHERE singleton AND complete AND next_unit=26 AND source_input_sha256='9c814c08fba12afbdec246b477a73c0047d318b51dc7c83a23050bd9da9e0aa9')THEN RAISE EXCEPTION 'C501_SOURCE_FAMILY_COMPLETE_PREFIX_REQUIRED';END IF;
IF EXISTS(SELECT 1 FROM jsonb_array_elements((SELECT jsonb_agg('{"configuration":["search_path=\"\""],"default_arg_count":0,"owner":"postgres","parallel":"u","returns_set":false,"security_definer":true,"strict":false,"variadic_type":null}'::jsonb||p)FROM jsonb_array_elements('[{"all_arg_types":[],"arg_modes":[],"arg_names":null,"body_md5":"75fcad93b0da5fee0fc6b7af652a5e85","execute":["postgres"],"input_arg_types":[],"language":"sql","lookup_signature":"mission_factory_owner.c444_enabled_v1()","oid":null,"return_type":"pg_catalog.bool","volatility":"s"},{"all_arg_types":["pg_catalog.uuid"],"arg_modes":["i"],"arg_names":["p_session"],"body_md5":"0a7fa43e594605d397504828f1961f55","execute":["postgres"],"input_arg_types":["pg_catalog.uuid"],"language":"plpgsql","lookup_signature":"mission_factory_owner.c444_read_identity_v1(pg_catalog.uuid)","oid":null,"return_type":"pg_catalog.jsonb","volatility":"s"},{"all_arg_types":["pg_catalog.uuid"],"arg_modes":["i"],"arg_names":["p_session"],"body_md5":"a2f72b56b71b3a8ea089aff06a66e7ae","execute":["postgres"],"input_arg_types":["pg_catalog.uuid"],"language":"plpgsql","lookup_signature":"mission_factory_owner.c444_source_read_assert_v1(pg_catalog.uuid)","oid":null,"return_type":"pg_catalog.jsonb","volatility":"v"},{"all_arg_types":["pg_catalog.uuid"],"arg_modes":["i"],"arg_names":["p_episode"],"body_md5":"3ea3a2a0749910a979216b801a09bb2e","execute":["postgres"],"input_arg_types":["pg_catalog.uuid"],"language":"plpgsql","lookup_signature":"mission_factory_owner.c444_episode_read_assert_v1(pg_catalog.uuid)","oid":null,"return_type":"pg_catalog.void","volatility":"s"},{"all_arg_types":["pg_catalog.uuid"],"arg_modes":["i"],"arg_names":["p_episode"],"body_md5":"5d1943abf0a90cd395165756207e934e","execute":["postgres"],"input_arg_types":["pg_catalog.uuid"],"language":"plpgsql","lookup_signature":"mission_factory_owner.c444_enrollment_open_v1(pg_catalog.uuid)","oid":null,"return_type":"pg_catalog.bool","volatility":"v"},{"all_arg_types":["pg_catalog.uuid","pg_catalog.text","pg_catalog.bool","pg_catalog.int8","pg_catalog.uuid"],"arg_modes":["i","i","i","i","i"],"arg_names":["p_episode","p_operation","p_ready","p_expected_version","p_request"],"body_md5":"1bad66b63bff109cf4e65d14be59722f","execute":["postgres"],"input_arg_types":["pg_catalog.uuid","pg_catalog.text","pg_catalog.bool","pg_catalog.int8","pg_catalog.uuid"],"language":"plpgsql","lookup_signature":"mission_factory_owner.c444_enrollment_v1(pg_catalog.uuid,pg_catalog.text,pg_catalog.bool,pg_catalog.int8,pg_catalog.uuid)","oid":null,"return_type":"pg_catalog.jsonb","volatility":"v"},{"all_arg_types":["pg_catalog.uuid","pg_catalog.text","pg_catalog.bool","pg_catalog.int8","pg_catalog.uuid"],"arg_modes":["i","i","i","i","i"],"arg_names":["p_episode","p_operation","p_ready","p_expected_version","p_request"],"body_md5":"01c2c0a636f1ccf084713d1d65decd16","execute":["authenticated","postgres"],"input_arg_types":["pg_catalog.uuid","pg_catalog.text","pg_catalog.bool","pg_catalog.int8","pg_catalog.uuid"],"language":"plpgsql","lookup_signature":"public.mission_factory_quest_enrollment_v1(pg_catalog.uuid,pg_catalog.text,pg_catalog.bool,pg_catalog.int8,pg_catalog.uuid)","oid":"276409","return_type":"pg_catalog.jsonb","volatility":"v"},{"all_arg_types":["pg_catalog.uuid"],"arg_modes":["i"],"arg_names":["p_session"],"body_md5":"85a879af8a80d50593fcb3970869249f","execute":["postgres"],"input_arg_types":["pg_catalog.uuid"],"language":"plpgsql","lookup_signature":"mission_factory_owner.c444_terminal_confirmed_v1(pg_catalog.uuid)","oid":null,"return_type":"pg_catalog.jsonb","volatility":"v"},{"all_arg_types":["pg_catalog.uuid"],"arg_modes":["i"],"arg_names":["p_session"],"body_md5":"1c6a6240f27b3add37546175768633a2","execute":["postgres"],"input_arg_types":["pg_catalog.uuid"],"language":"plpgsql","lookup_signature":"mission_factory_owner.quest_terminal_confirmed_v1(pg_catalog.uuid)","oid":"276431","return_type":"pg_catalog.jsonb","volatility":"v"},{"all_arg_types":["pg_catalog.uuid"],"arg_modes":["i"],"arg_names":["p_episode"],"body_md5":"5fa62eda7260904e189b55b06088254b","execute":["postgres"],"input_arg_types":["pg_catalog.uuid"],"language":"plpgsql","lookup_signature":"mission_factory_owner.c444_participant_state_v1(pg_catalog.uuid)","oid":null,"return_type":"pg_catalog.jsonb","volatility":"v"},{"all_arg_types":["pg_catalog.uuid"],"arg_modes":["i"],"arg_names":["p_episode"],"body_md5":"5b30f993c86a69c24090771c5b3d1404","execute":["authenticated","postgres"],"input_arg_types":["pg_catalog.uuid"],"language":"plpgsql","lookup_signature":"public.mission_factory_quest_participant_state_v1(pg_catalog.uuid)","oid":"276446","return_type":"pg_catalog.jsonb","volatility":"v"},{"all_arg_types":["pg_catalog.uuid"],"arg_modes":["i"],"arg_names":["p_request"],"body_md5":"d06ad7832dd3bc64fc0d0472d9965534","execute":["postgres"],"input_arg_types":["pg_catalog.uuid"],"language":"plpgsql","lookup_signature":"mission_factory_owner.c444_run_state_v1(pg_catalog.uuid)","oid":null,"return_type":"pg_catalog.jsonb","volatility":"v"},{"all_arg_types":["pg_catalog.uuid"],"arg_modes":["i"],"arg_names":["p_request"],"body_md5":"6d17dc85221b79a22a4205103898ba0f","execute":["authenticated","postgres"],"input_arg_types":["pg_catalog.uuid"],"language":"plpgsql","lookup_signature":"public.mission_factory_quest_run_state_v1(pg_catalog.uuid)","oid":"276432","return_type":"pg_catalog.jsonb","volatility":"v"},{"all_arg_types":["pg_catalog.uuid"],"arg_modes":["i"],"arg_names":["p_session"],"body_md5":"8d2d40aa16abbf40ea7801ae4ec49774","execute":["postgres"],"input_arg_types":["pg_catalog.uuid"],"language":"plpgsql","lookup_signature":"mission_factory_owner.c444_action_scope_v1(pg_catalog.uuid)","oid":null,"return_type":"pg_catalog.jsonb","volatility":"v"},{"all_arg_types":["pg_catalog.uuid"],"arg_modes":["i"],"arg_names":["p_session"],"body_md5":"7e7da01987e744d27f634cd93c4cd273","execute":["authenticated","postgres"],"input_arg_types":["pg_catalog.uuid"],"language":"plpgsql","lookup_signature":"public.mission_factory_quest_human_runtime_state_v1(pg_catalog.uuid)","oid":null,"return_type":"pg_catalog.jsonb","volatility":"v"},{"all_arg_types":["pg_catalog.uuid"],"arg_modes":["i"],"arg_names":["p_session"],"body_md5":"0bda32f1607eb10808df90b042f5473a","execute":["authenticated","postgres"],"input_arg_types":["pg_catalog.uuid"],"language":"plpgsql","lookup_signature":"public.mission_human_phase_state_v1(pg_catalog.uuid)","oid":"50702","return_type":"pg_catalog.jsonb","volatility":"s"}]'::jsonb)z(p))) c501_expected LEFT JOIN pg_catalog.pg_proc c501_proc ON c501_proc.oid=pg_catalog.to_regprocedure(c501_expected->>'lookup_signature') WHERE c501_proc.oid IS NULL OR (c501_expected->>'oid' IS NOT NULL AND c501_proc.oid::text IS DISTINCT FROM c501_expected->>'oid') OR md5(c501_proc.prosrc) IS DISTINCT FROM c501_expected->>'body_md5' OR c501_proc.proargtypes::text IS DISTINCT FROM coalesce((SELECT string_agg(pg_catalog.to_regtype(c501_argtype)::oid::text,' ' ORDER BY c501_ord)FROM jsonb_array_elements_text(c501_expected->'input_arg_types')WITH ORDINALITY c501_inputs(c501_argtype,c501_ord)),'') OR coalesce((SELECT jsonb_agg(pg_catalog.format('%I.%I',c501_ns.nspname,c501_type.typname) ORDER BY c501_ord)FROM unnest(coalesce(c501_proc.proallargtypes,c501_proc.proargtypes::oid[]))WITH ORDINALITY c501_all(c501_type_oid,c501_ord)JOIN pg_catalog.pg_type c501_type ON c501_type.oid=c501_type_oid JOIN pg_catalog.pg_namespace c501_ns ON c501_ns.oid=c501_type.typnamespace),'[]'::jsonb) IS DISTINCT FROM c501_expected->'all_arg_types' OR to_jsonb(coalesce(c501_proc.proargmodes,array_fill('i'::"char",ARRAY[c501_proc.pronargs]))) IS DISTINCT FROM c501_expected->'arg_modes' OR coalesce(to_jsonb(c501_proc.proargnames),'null'::jsonb) IS DISTINCT FROM c501_expected->'arg_names' OR c501_proc.prorettype IS DISTINCT FROM pg_catalog.to_regtype(c501_expected->>'return_type') OR c501_proc.proretset IS DISTINCT FROM(c501_expected->>'returns_set')::boolean OR c501_proc.pronargdefaults IS DISTINCT FROM(c501_expected->>'default_arg_count')::integer OR (c501_proc.pronargdefaults=0 AND c501_proc.proargdefaults IS NOT NULL) OR c501_proc.provariadic IS DISTINCT FROM coalesce(pg_catalog.to_regtype(c501_expected->>'variadic_type')::oid,0::oid) OR c501_proc.proisstrict IS DISTINCT FROM(c501_expected->>'strict')::boolean OR c501_proc.provolatile::text IS DISTINCT FROM c501_expected->>'volatility' OR c501_proc.proparallel::text IS DISTINCT FROM c501_expected->>'parallel' OR c501_proc.prosecdef IS DISTINCT FROM(c501_expected->>'security_definer')::boolean OR(SELECT lanname FROM pg_catalog.pg_language WHERE oid=c501_proc.prolang)IS DISTINCT FROM c501_expected->>'language' OR to_jsonb(c501_proc.proconfig) IS DISTINCT FROM c501_expected->'configuration' OR pg_catalog.pg_get_userbyid(c501_proc.proowner)IS DISTINCT FROM c501_expected->>'owner' OR c501_proc.proleakproof OR coalesce((SELECT jsonb_agg(CASE WHEN c501_acl.grantee=0 THEN 'PUBLIC' ELSE pg_catalog.pg_get_userbyid(c501_acl.grantee)END ORDER BY CASE WHEN c501_acl.grantee=0 THEN 'PUBLIC' ELSE pg_catalog.pg_get_userbyid(c501_acl.grantee)END)FROM pg_catalog.aclexplode(coalesce(c501_proc.proacl,pg_catalog.acldefault('f',c501_proc.proowner)))c501_acl WHERE c501_acl.privilege_type='EXECUTE'),'[]'::jsonb)IS DISTINCT FROM c501_expected->'execute' OR EXISTS(SELECT 1 FROM pg_catalog.aclexplode(coalesce(c501_proc.proacl,pg_catalog.acldefault('f',c501_proc.proowner)))c501_acl WHERE c501_acl.is_grantable))THEN RAISE EXCEPTION 'C501_PORTS_EFFECTIVE_FULL_ABI_ACL_CAS' USING ERRCODE='40001';END IF;
END$function$
;
DO $postflight$ BEGIN PERFORM mission_factory_owner.c444_runtime_ports_complete_assert_v1();END $postflight$;COMMIT;
