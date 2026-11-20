BEGIN;
SET LOCAL search_path='';
SET LOCAL lock_timeout='2s';
DO $sfera_map_inert$
#variable_conflict error
DECLARE
 
 rr mission_factory_owner.editor_release_readiness%ROWTYPE;
 prior_release mission_public_owner.release_admissions_v1%ROWTYPE;
 prior_qualification mission_public_owner.public_qualification_attestations_v1%ROWTYPE;
 runtime_before jsonb; review jsonb;
 root_text text; candidate_root jsonb; db_sha text; config_sha text; new_root_sha text; old_root_sha text;
 old_row_sha text; bindings jsonb; qualification jsonb; content_payload jsonb; content_request uuid;
 content_row mission_public_owner.mission_content_admissions_v1%ROWTYPE; profile_row record;
 params jsonb; affected integer;
 namespace_uuid constant uuid:='5d20915b-9e97-5eca-8851-fd9f7f4c842a';
 generic_ezbr constant text:='9a6889802cfa17c99a556538cccd4ad7ef75274d32adccbc192c23d257aa3e76';

 expected_active_root constant text:='799e64f09637b5a7d331c3faf931ccab0c114cf33565c78b1cb40feefec82967';
BEGIN
 review:=$map_review${"ref":"SFERA_MAP_RECOVERY_REVIEW","sha256":"d19ed6769e2a1ec300fcbbb7d3dff321601c797d4c1ec461076199b33deda91f","P0":0,"P1":0,"P2":0}$map_review$::jsonb;
 IF NOT mission_factory_owner.keys_exact_v2(review,ARRAY['ref','sha256','P0','P1','P2'])
  OR coalesce(review->>'ref','')!~'^[A-Za-z0-9_.#-]{1,40}$'
  OR coalesce(review->>'sha256','')!~'^[a-f0-9]{64}$'
  OR review->'P0' IS DISTINCT FROM '0'::jsonb OR review->'P1' IS DISTINCT FROM '0'::jsonb
  OR review->'P2' IS DISTINCT FROM '0'::jsonb THEN RAISE EXCEPTION 'SFERA_MAP_REVIEW_REQUIRED';END IF;
 
 IF current_user<>'postgres' OR session_user<>'postgres' OR auth.uid() IS NOT NULL
   OR (SELECT rolbypassrls FROM pg_roles WHERE rolname='postgres') IS DISTINCT FROM true
 THEN RAISE EXCEPTION 'SFERA_MAP_OPERATION_REQUIRED'; END IF;
 IF NOT pg_try_advisory_xact_lock(hashtextextended('C1266:GENERIC-AI:AVAILABILITY',0))
 THEN RAISE EXCEPTION 'SFERA_MAP_AVAILABILITY_BUSY';END IF;
 SELECT * INTO STRICT rr FROM mission_factory_owner.editor_release_readiness WHERE singleton FOR UPDATE NOWAIT;
 LOCK TABLE public.master_v2_sessions,public.combat_v2_sessions,combat_consumer_private.invitations,
   mission_public_owner.party_launch_runtime_v1 IN SHARE ROW EXCLUSIVE MODE NOWAIT;
 IF EXISTS(SELECT 1 FROM public.combat_v2_sessions WHERE closed_at IS NULL AND state IN('preparazione','in_corso','sospeso'))
   OR EXISTS(SELECT 1 FROM public.master_v2_sessions WHERE closed_at IS NULL AND stato NOT IN('chiusa','annullata'))
   OR EXISTS(SELECT 1 FROM combat_consumer_private.invitations WHERE state='pending' AND location_id='0b85f354-9cdb-47e1-baf9-3d266bb7e06b')
   OR EXISTS(SELECT 1 FROM clan_aburame_private.sfera_sources_v1 WHERE state IN('reserved','active'))
   OR EXISTS(SELECT 1 FROM clan_aburame_private.sfera_sources_v1 s JOIN clan_aburame_private.colony_sources c
     ON c.owner_id=s.owner_character_id AND c.scope_id=s.session_id AND c.source_id=s.declaration_id WHERE c.state='active')
 THEN RAISE EXCEPTION 'SFERA_MAP_QUIESCENCE_REQUIRED'; END IF;
 IF rr.state IS DISTINCT FROM 'enabled' OR rr.scope IS DISTINCT FROM 'staff' OR NOT rr.staff_guards_verified
   OR NOT rr.published_assets_verified OR NOT clan_innata_private.catalogo_eligibility_release_v1()
   OR (SELECT enabled FROM clan_aburame_private.sfera_staff_gate_v1 WHERE singleton) IS DISTINCT FROM true
 THEN RAISE EXCEPTION 'SFERA_MAP_PARENT_UNQUALIFIED'; END IF;
 PERFORM clan_innata_private.runtime_release_assert();

 IF EXISTS(SELECT 1 FROM jsonb_to_recordset('[{"sig":"clan_aburame_private.sfera_clear_arena_distance_v1(uuid,uuid,uuid)","oid":"702098","abi_sha256":"465357c43e5c62f2e798643680fa862dbe7a9967053c1caebddfba564fd12c4d","source_md5":"eb0baae14293899634255d12a254a5d2","ddl_md5":"55df5a71ee1c2516063bac8755608279","ddl_sha256":"e87607ce83bf52294acdd53332a8837f5e4a77cb204c9e7e2826339c1adb61d2"},{"sig":"clan_innata_private.catalogo_eligibility_release_v1()","oid":"684829","abi_sha256":"dc03ebb3082eef5a2a7cc7ffe2dccec1506612d08da34f80c50b737425311774","source_md5":"84a7a8b6bdbbd5c8e33144d93444eec9","ddl_md5":"711a1b58f810c00651d816cc8147e33b","ddl_sha256":"89f41ba5949a9f4e48d34e978657f033da6f8c047513a371a8622639ca982617"},{"oid":"41419","sig":"clan_innata_private.eligibility_release_assert()","ddl_md5":"c853342118edc3e2d886aef09661da1b","abi_sha256":"6196b3570f0cf7b8efd83fc1d688978688a292d4d11b0b9d1ff78241e0316d88","ddl_sha256":"d034de670fcf5ad17d3f4663fe209cda5ca3d85e1c8b86f1bff26fb938f002bb","source_md5":"d12a616a859cd2b497004d0f17395437"}]'::jsonb)
 AS e(sig text,oid text,source_md5 text,ddl_sha256 text,abi_sha256 text)
 LEFT JOIN pg_proc p ON p.oid=to_regprocedure(e.sig) LEFT JOIN pg_language l ON l.oid=p.prolang
 WHERE p.oid::text IS DISTINCT FROM e.oid OR md5(p.prosrc) IS DISTINCT FROM e.source_md5
 OR encode(extensions.digest(pg_get_functiondef(p.oid),'sha256'),'hex') IS DISTINCT FROM e.ddl_sha256
 OR public.combat_v2_sha256(jsonb_build_object(
   'owner',pg_get_userbyid(p.proowner),'acl',p.proacl::text,'config',p.proconfig,'secdef',p.prosecdef,
   'volatile',p.provolatile::text,'strict',p.proisstrict,'parallel',p.proparallel::text,
   'kind',p.prokind::text,'returns',pg_get_function_result(p.oid),'args',p.proargtypes::text,'lang',l.lanname)) IS DISTINCT FROM e.abi_sha256)
 THEN RAISE EXCEPTION 'SFERA_MAP_AFTER_ABI_OR_DDL_DRIFT'; END IF;
 SELECT * INTO STRICT prior_release FROM mission_public_owner.release_admissions_v1
 WHERE release_sha256=rr.revision_sha256 FOR SHARE;
 SELECT * INTO STRICT prior_qualification FROM mission_public_owner.public_qualification_attestations_v1
 WHERE release_sha256=rr.revision_sha256 FOR SHARE;
 SELECT to_jsonb(x) INTO STRICT runtime_before FROM mission_public_owner.party_launch_runtime_v1 x WHERE singleton FOR UPDATE;
 IF prior_release.edge_sha256 IS DISTINCT FROM generic_ezbr
  OR public.combat_v2_sha256(prior_qualification.payload->'capabilities') IS DISTINCT FROM '49fe134f561273f28e8071b63c45886341371b67d028f06e6b7d8f8d4108e817'
  OR runtime_before IS DISTINCT FROM jsonb_set('{"singleton":true,"staff_enabled":true,"public_enabled":true,"release_sha256":"8261958382e653c1077972c8410f01b039b1d82d7a032efff09189a8734e0cfb"}'::jsonb,'{release_sha256}',to_jsonb(rr.revision_sha256),false)
  OR (SELECT count(*) FROM mission_public_owner.mission_content_admissions_v1 c
       WHERE c.engine_release_sha256=rr.revision_sha256 AND mission_public_owner.content_admission_v1(c.mission_id,rr.revision_sha256,c.publication_request,true) IS NOT NULL)<>2
  OR (SELECT count(DISTINCT profile_key) FROM mission_public_owner.engine_profile_events_v1
     WHERE engine_release_sha256=rr.revision_sha256)<>1
  
  OR mission_public_owner.engine_qualification_v1(rr.revision_sha256,true) IS NULL
 THEN RAISE EXCEPTION 'SFERA_MAP_PARENT_MISSION_EVIDENCE_DRIFT';END IF;
 
WITH parent AS MATERIALIZED (
 SELECT r.revision_sha256 AS root_sha,r.canonical_preimage::jsonb AS j,
        octet_length(r.canonical_preimage) AS old_size
 FROM mission_factory_owner.editor_release_readiness r WHERE r.singleton AND r.revision_sha256=expected_active_root
), peer_rows AS MATERIALIZED (
 SELECT p.oid::regprocedure::text AS signature,jsonb_build_object(
  'signature',p.oid::regprocedure::text,'source_md5',md5(p.prosrc),'ddl_md5',md5(pg_get_functiondef(p.oid)),
  'owner',pg_get_userbyid(p.proowner),'secdef',p.prosecdef,'config',p.proconfig,'acl',p.proacl::text,'volatility',p.provolatile::text) AS obj
 FROM pg_proc p WHERE p.oid IN ('combat_panel_private.round_options_authoritative(uuid,uuid)'::regprocedure,'public.combat_v2_substitution_options_v1(uuid)'::regprocedure,'public.combat_v2_substitution_round_offers_v1(uuid,uuid)'::regprocedure,'public.combat_v2_substitution_select_v1(uuid,uuid)'::regprocedure,'clan_innata_private.catalogo_eligibility_release_v1()'::regprocedure,'combat_panel_private.publish_master_declaration(uuid,text)'::regprocedure)
), peers AS MATERIALIZED (
 SELECT count(*),public.combat_v2_sha256(jsonb_agg(obj ORDER BY signature)) AS live_sha,
    public.combat_v2_sha256(jsonb_agg(CASE WHEN signature='clan_innata_private.catalogo_eligibility_release_v1()'
      THEN obj||jsonb_build_object('source_md5','84a7a8b6bdbbd5c8e33144d93444eec9','ddl_md5','711a1b58f810c00651d816cc8147e33b')
      ELSE obj END ORDER BY signature)) AS next_sha
 FROM peer_rows
), patched AS MATERIALIZED (
 SELECT p.*,peers.live_sha,peers.next_sha,jsonb_set(jsonb_set(p.j,'{db_core,sfera_staff}','"de77cc1b529bf5f6f3cd7420aa6f315521a89bbb713f0dd9af4b9713a46defd1"'::jsonb,false),'{config,sfera_staff}','"de77cc1b529bf5f6f3cd7420aa6f315521a89bbb713f0dd9af4b9713a46defd1"'::jsonb,false) AS doc
 FROM parent p CROSS JOIN peers
 WHERE p.j#>'{db_core,sfera_staff}' IS NOT DISTINCT FROM '"d2f38943c31031ee0fa051e57add33095908eed0806382d93984fb44d111a2eb"'::jsonb AND p.j#>'{config,sfera_staff}' IS NOT DISTINCT FROM '"d2f38943c31031ee0fa051e57add33095908eed0806382d93984fb44d111a2eb"'::jsonb AND (peers.count=6 AND peers.live_sha=p.j#>>'{db_core,cure_command_amendment,functions_manifest_sha256}')
   AND p.j#>'{db_core,catalogo_families,2}'='["5b8cc87dc91085b066f32e32ca70ca5d72d3643d337a6531777390e7749fc98d","e4c44135ccdfb770e155318ae6dbaf3d6e95c7550df5f4bcc5a0c38f60d25a77","2b38e6014a0723bb02cfcb37ba6b14fcbc609e5a5a428d8dd63e240e18926fc9"]'::jsonb
   AND p.j#>>'{db_core,catalogo_eligibility_compat,shared_manifest_sha256}'='0d669a22ab8b24f685352555e569d55ff65b0de59be5a3fe4e8b9640c3b8672e'
   AND p.j#>>'{db_core,velo_staff}'='35d754465f1c19509822e9728ade3e23c3d2aefe63f441aff01908e774dfcef6'
   AND p.j#>>'{config,velo_staff}'='35d754465f1c19509822e9728ade3e23c3d2aefe63f441aff01908e774dfcef6'
   AND public.combat_v2_sha256(p.j->'edge_bundles')='67ee310b994f65492aa094f6f3f6e435aa2faf95d98246bbc6b00b90afc9c783'
   AND public.combat_v2_sha256(p.j->'ui')='b62cac808730c14ff1558ac666b3a76c3cc264e4716b858205acada9efadefc9'
), digest_next AS MATERIALIZED (
 SELECT *,public.combat_v2_sha256((doc->'db_core')-'sha256') AS db_sha_next,
          public.combat_v2_sha256((doc->'config')-'sha256') AS config_sha_next
 FROM patched
), identities AS MATERIALIZED (
 SELECT *,public.combat_v2_sha256(jsonb_build_object('version','sfera-arena-native/2','mode','inert',
    'parent',root_sha,'prior_code_identity',j#>'{contract,code_identity_sha256}','leaf','de77cc1b529bf5f6f3cd7420aa6f315521a89bbb713f0dd9af4b9713a46defd1',
    'db',db_sha_next,'config',config_sha_next,'edge',j->'edge_bundles')) AS new_identity
 FROM digest_next
), serialized AS MATERIALIZED (
 SELECT *,jsonb_set(jsonb_set(jsonb_set(jsonb_set(doc,'{db_core,sha256}',to_jsonb(db_sha_next),false),
   '{config,sha256}',to_jsonb(config_sha_next),false),'{contract,code_identity_sha256}',to_jsonb(new_identity),false),
   '{recovery,semantic_identity_sha256}',to_jsonb(new_identity),false) AS root_document
 FROM identities
), candidate AS MATERIALIZED (
 SELECT *,regexp_replace(root_document::text,$rx$("(?:[^"\\]|\\.)*")|[[:space:]]+$rx$,$b$\1$b$,'g') AS root_text FROM serialized
)

 SELECT c.root_text INTO STRICT root_text FROM candidate c
 WHERE c.root_text::jsonb=c.root_document AND octet_length(c.root_text)<=524288;
 IF encode(extensions.digest(convert_to(root_text,'UTF8'),'sha256'),'hex') IS DISTINCT FROM '7167e454da19dc525a27acfb181ecbfbb057d5beafd58ddc9fabe0209bc8f979'
 THEN RAISE EXCEPTION 'SFERA_MAP_PROJECTED_RECOVERY_MISMATCH';END IF;
 
 old_root_sha:=rr.revision_sha256;
 old_row_sha:=public.combat_v2_sha256(to_jsonb(rr));
 candidate_root:=root_text::jsonb;
 db_sha:=candidate_root#>>'{db_core,sha256}'; config_sha:=candidate_root#>>'{config,sha256}';
 IF octet_length(root_text)>524288
  OR db_sha IS DISTINCT FROM public.combat_v2_sha256((candidate_root->'db_core')-'sha256')
  OR config_sha IS DISTINCT FROM public.combat_v2_sha256((candidate_root->'config')-'sha256')
  OR candidate_root#>>'{db_core,sfera_staff}' IS DISTINCT FROM 'de77cc1b529bf5f6f3cd7420aa6f315521a89bbb713f0dd9af4b9713a46defd1'
  OR candidate_root#>>'{config,sfera_staff}' IS DISTINCT FROM 'de77cc1b529bf5f6f3cd7420aa6f315521a89bbb713f0dd9af4b9713a46defd1'
  OR public.combat_v2_sha256(candidate_root->'ui') IS DISTINCT FROM 'b62cac808730c14ff1558ac666b3a76c3cc264e4716b858205acada9efadefc9'
  OR public.combat_v2_sha256(candidate_root->'edge_bundles') IS DISTINCT FROM '67ee310b994f65492aa094f6f3f6e435aa2faf95d98246bbc6b00b90afc9c783'
 THEN RAISE EXCEPTION 'SFERA_MAP_FINAL_ROOT_BINDING'; END IF;
 new_root_sha:=encode(extensions.digest(convert_to(root_text,'UTF8'),'sha256'),'hex');
 params:='{"expected_mission_capabilities_sha256":"49fe134f561273f28e8071b63c45886341371b67d028f06e6b7d8f8d4108e817","compatibility":{"ref":"sfera-arena-inert-existing-missions","sha256":"de77cc1b529bf5f6f3cd7420aa6f315521a89bbb713f0dd9af4b9713a46defd1"}}'::jsonb;
 bindings:=jsonb_build_object('db_sha256',db_sha,'edge_sha256',generic_ezbr,
   'client_sha256',public.combat_v2_sha256(candidate_root->'ui'),'configuration_sha256',config_sha);
 UPDATE mission_factory_owner.editor_release_readiness
 SET canonical_preimage=root_text,revision_sha256=new_root_sha,observed_revision_sha256=new_root_sha,
   client_build='mission-factory-admin/2:'||new_root_sha,independent_review_ref=review->>'ref',updated_at=clock_timestamp()
 WHERE singleton AND revision_sha256=old_root_sha AND public.combat_v2_sha256(to_jsonb(editor_release_readiness))=old_row_sha;
 GET DIAGNOSTICS affected=ROW_COUNT;
 IF affected<>1 THEN RAISE EXCEPTION 'SFERA_MAP_ROOT_CAS';END IF;
 UPDATE clan_aburame_private.sfera_staff_gate_v1 SET enabled=false WHERE singleton AND enabled;
 GET DIAGNOSTICS affected=ROW_COUNT;
 IF affected<>1 THEN RAISE EXCEPTION 'SFERA_MAP_GATE_CAS';END IF;
 IF (SELECT enabled FROM clan_aburame_private.sfera_staff_gate_v1 WHERE singleton) IS DISTINCT FROM false
    OR NOT clan_innata_private.catalogo_eligibility_release_v1()
 THEN RAISE EXCEPTION 'SFERA_MAP_AFTER_CAS_E52_OR_GATE';END IF;
 PERFORM clan_innata_private.runtime_release_assert();
  INSERT INTO mission_public_owner.release_admissions_v1(release_sha256,db_sha256,edge_sha256,client_sha256,configuration_sha256,
  contract_version,independent_review_ref,staff_evidence_ref,qualified_at,public_enabled)
 VALUES(new_root_sha,db_sha,generic_ezbr,bindings->>'client_sha256',config_sha,prior_release.contract_version,
  review->>'ref',prior_release.staff_evidence_ref,prior_release.qualified_at,prior_release.public_enabled);
 FOR profile_row IN SELECT DISTINCT ON(profile_key)* FROM mission_public_owner.engine_profile_events_v1
  WHERE engine_release_sha256=old_root_sha ORDER BY profile_key,control_version DESC LOOP
  IF profile_row.profile_key IS DISTINCT FROM prior_qualification.payload->>'authoring_profile' THEN
   RAISE EXCEPTION 'SFERA_MAP_UNQUALIFIED_PROFILE_CARRYFORWARD';END IF;
  INSERT INTO mission_public_owner.engine_profile_events_v1(event_id,engine_release_sha256,profile_key,expected_control_version,
   control_version,authoring_enabled,runtime_enabled,actor_user,reason)
  VALUES(extensions.uuid_generate_v5(namespace_uuid,new_root_sha||':profile:'||profile_row.profile_key),new_root_sha,profile_row.profile_key,
   0,1,profile_row.authoring_enabled,profile_row.runtime_enabled,profile_row.actor_user,
   'Compatible carryforward of existing mission profile only; new catalog techniques have no Staff PASS');
 END LOOP;
 qualification:=prior_qualification.payload||jsonb_build_object('revision_sha256',new_root_sha,'bindings',bindings,'independent_review',review,
  'reuse_evidence',(prior_qualification.payload->'reuse_evidence')||jsonb_build_object('new_mission_QA_claim',false,
   'catalogo_compatibility',jsonb_build_object('parent_root',old_root_sha,'ref',params#>'{compatibility,ref}',
    'sha256',params#>'{compatibility,sha256}','scope','existing_mission_capabilities_only','new_techniques_staff_pass',false)));
 INSERT INTO mission_public_owner.public_qualification_attestations_v1(release_sha256,request_key,payload,payload_sha256,
  positive_staff_evidence_ref,authorized_test_manifest_ref,created_by)
 VALUES(new_root_sha,extensions.uuid_generate_v5(namespace_uuid,new_root_sha||':qualification'),qualification,mission_factory_owner.sha(qualification),
  prior_qualification.positive_staff_evidence_ref,prior_qualification.authorized_test_manifest_ref,prior_qualification.created_by);
 IF qualification->'capabilities' IS DISTINCT FROM prior_qualification.payload->'capabilities'
 OR public.combat_v2_sha256(qualification->'capabilities') IS DISTINCT FROM params->>'expected_mission_capabilities_sha256'
 OR mission_public_owner.engine_qualification_v1(new_root_sha,true)IS NULL THEN RAISE EXCEPTION 'SFERA_MAP_MISSION_CARRYFORWARD_INVALID';END IF;
 FOR content_row IN SELECT * FROM mission_public_owner.mission_content_admissions_v1 WHERE engine_release_sha256=old_root_sha ORDER BY mission_id LOOP
  content_request:=extensions.uuid_generate_v5(content_row.request_key,new_root_sha||':catalogo-compatible-adoption');
  content_payload:=content_row.payload||jsonb_build_object('request_key',content_request,'engine_release_sha256',new_root_sha,'created_at',clock_timestamp());
  INSERT INTO mission_public_owner.mission_content_admissions_v1(request_key,mission_id,config_version,engine_release_sha256,publication_request,payload,payload_sha256)
  VALUES(content_request,content_row.mission_id,content_row.config_version,new_root_sha,content_row.publication_request,content_payload,mission_factory_owner.sha(content_payload));
  IF mission_public_owner.content_admission_v1(content_row.mission_id,new_root_sha,content_row.publication_request,true)IS NULL THEN
   RAISE EXCEPTION 'SFERA_MAP_CONTENT_CARRYFORWARD_INVALID';END IF;
 END LOOP;
 UPDATE mission_public_owner.party_launch_runtime_v1 x SET release_sha256=new_root_sha WHERE singleton AND to_jsonb(x)=runtime_before;
 GET DIAGNOSTICS affected=ROW_COUNT;IF affected<>1 THEN RAISE EXCEPTION 'SFERA_MAP_PARTY_RUNTIME_CAS';END IF;

 IF (SELECT count(*) FROM mission_public_owner.mission_content_admissions_v1 c WHERE c.engine_release_sha256=new_root_sha
     AND mission_public_owner.content_admission_v1(c.mission_id,new_root_sha,c.publication_request,true) IS NOT NULL)<>2
  OR (SELECT to_jsonb(x) FROM mission_public_owner.party_launch_runtime_v1 x WHERE singleton)
      IS DISTINCT FROM jsonb_set(runtime_before,'{release_sha256}',to_jsonb(new_root_sha),false)
 THEN RAISE EXCEPTION 'SFERA_MAP_FINAL_MISSION_BOUNDARY_DRIFT'; END IF;
 PERFORM set_config('app.sfera_map_result',jsonb_build_object('root_sha256',new_root_sha,'root_bytes',octet_length(root_text),
  'previous_root_sha256',old_root_sha,'staff_enabled',false,'public_opening',false,'playtest','NOT_RUN','provider_calls',0)::text,true);

END;
$sfera_map_inert$;
SELECT current_setting('app.sfera_map_result',true)::jsonb AS release_receipt;
COMMIT;
