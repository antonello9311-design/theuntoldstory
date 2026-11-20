BEGIN;
SET LOCAL search_path='';
SET LOCAL lock_timeout='2s';
DO $pill_inert$
#variable_conflict error
DECLARE 
 rr mission_factory_owner.editor_release_readiness%ROWTYPE;
 prior_release mission_public_owner.release_admissions_v1%ROWTYPE;
 prior_qualification mission_public_owner.public_qualification_attestations_v1%ROWTYPE;
 runtime_before jsonb; review jsonb; root_text text; candidate_root jsonb; resources_before jsonb;
 db_sha text; config_sha text; new_root_sha text; old_root_sha text; old_row_sha text;
 bindings jsonb; qualification jsonb; content_payload jsonb; content_request uuid;
 content_row mission_public_owner.mission_content_admissions_v1%ROWTYPE; profile_row record;
 params jsonb; affected integer;
 namespace_uuid constant uuid:='5d20915b-9e97-5eca-8851-fd9f7f4c842a';
 generic_ezbr constant text:='9a6889802cfa17c99a556538cccd4ad7ef75274d32adccbc192c23d257aa3e76';
BEGIN
 review:=$pill_review${"ref":"PILL-R3-CHECK-RECOVERY","sha256":"9e698a735557ea999f3075b9beb5a069fd3ab09dd0d0ab784e5e0c9683fa3f9a","P0":0,"P1":0,"P2":0}$pill_review$::jsonb;
 IF NOT mission_factory_owner.keys_exact_v2(review,ARRAY['ref','sha256','P0','P1','P2'])
    OR coalesce(review->>'ref','')!~'^[A-Za-z0-9_.#-]{1,40}$'
    OR coalesce(review->>'sha256','')!~'^[a-f0-9]{64}$'
    OR review->'P0' IS DISTINCT FROM '0'::jsonb
    OR review->'P1' IS DISTINCT FROM '0'::jsonb
    OR review->'P2' IS DISTINCT FROM '0'::jsonb THEN RAISE EXCEPTION 'PILL_INDEPENDENT_REVIEW_REQUIRED'; END IF;
 
 IF current_user<>'postgres' OR session_user<>'postgres' OR auth.uid() IS NOT NULL
    OR (SELECT rolbypassrls FROM pg_roles WHERE rolname='postgres') IS DISTINCT FROM true
 THEN RAISE EXCEPTION 'PILL_OPERATION_ROLE_REQUIRED'; END IF;
 IF NOT pg_try_advisory_xact_lock(hashtextextended('C1266:GENERIC-AI:AVAILABILITY',0))
 THEN RAISE EXCEPTION 'PILL_AVAILABILITY_BUSY'; END IF;
 SELECT * INTO STRICT rr FROM mission_factory_owner.editor_release_readiness WHERE singleton FOR UPDATE NOWAIT;
 LOCK TABLE public.master_v2_sessions,public.combat_v2_sessions,combat_consumer_private.invitations,
            mission_public_owner.party_launch_runtime_v1 IN SHARE ROW EXCLUSIVE MODE NOWAIT;
 IF EXISTS(SELECT 1 FROM public.combat_v2_sessions WHERE closed_at IS NULL AND state IN ('preparazione','in_corso','sospeso'))
    OR EXISTS(SELECT 1 FROM public.master_v2_sessions WHERE closed_at IS NULL AND stato NOT IN ('chiusa','annullata'))
    OR EXISTS(SELECT 1 FROM combat_consumer_private.invitations
              WHERE state='pending' AND location_id='0b85f354-9cdb-47e1-baf9-3d266bb7e06b')
    OR EXISTS(SELECT 1 FROM clan_aburame_private.sfera_sources_v1 WHERE state IN ('reserved','active'))
 THEN RAISE EXCEPTION 'PILL_QUIESCENCE_REQUIRED'; END IF;
 IF rr.scope IS DISTINCT FROM 'staff' OR rr.state IS DISTINCT FROM 'enabled'
    OR NOT rr.staff_guards_verified OR NOT rr.published_assets_verified
    OR rr.revision_sha256 IS DISTINCT FROM rr.observed_revision_sha256
    OR encode(extensions.digest(convert_to(rr.canonical_preimage,'UTF8'),'sha256'),'hex') IS DISTINCT FROM rr.revision_sha256
    OR NOT clan_innata_private.catalogo_eligibility_release_v1()
 THEN RAISE EXCEPTION 'PILL_PARENT_RELEASE_UNQUALIFIED'; END IF;
 PERFORM clan_innata_private.runtime_release_assert();
 IF rr.revision_sha256 IS DISTINCT FROM 'de34836ca073cda7dcf5d5920ff39d131d0da200a4100ac7589fea6f33663c3f'
   OR (SELECT staff_enabled FROM combat_panel_private.chakra_pill_staff_gate_v1 WHERE singleton) IS DISTINCT FROM true
 THEN RAISE EXCEPTION 'PILL_ACTIVE_PARENT_REQUIRED'; END IF;
 IF EXISTS(SELECT 1 FROM jsonb_to_recordset('[{"acl":"{postgres=X/postgres}","ddl_md5":"19c0226969fc069225a14c65a5d563e9","ddl_sha256":"a3d468831fa5a16a3dc0ef1bab71a4b39245292d5dd9983f2589320a3f1d7358","oid":"44940","owner":"postgres","sig":"combat_panel_private.master_options(uuid,uuid,bigint)","source_md5":"ad3cec069a1a0c5ab4a4a804de12bbec"},{"acl":"{postgres=X/postgres}","ddl_md5":"ff85a0b898d7635043ba47df4a304afd","ddl_sha256":"8055222d421ed9b07446ac66124172bc40de466b50c8b62765afcf08b265807d","oid":"44669","owner":"postgres","sig":"combat_panel_private.ordinary_options(uuid,uuid,bigint)","source_md5":"0e0226a9138c221d59a073d161d7a759"},{"acl":"{postgres=X/postgres,authenticated=X/postgres}","ddl_md5":"83b8cd6b6c06835579d573a08eaacd4b","ddl_sha256":"547eb53046d06f4947903862d69473a15364e45be294d6435b00e285b560d2b6","oid":"44808","owner":"postgres","sig":"public.combat_panel_commit_v1(jsonb)","source_md5":"427e6ecda3eeb2c2a141aa077ea7f0a9"},{"acl":"{postgres=X/postgres}","ddl_md5":"385cfe6490299ce6694d31d307acf36d","ddl_sha256":"85d1d252592ebb9baf654e64e61007089713d6f689ec01ac4c6ce5b72a510ca5","oid":"684829","owner":"postgres","sig":"clan_innata_private.catalogo_eligibility_release_v1()","source_md5":"0b45f09f8f4d1257fb50461bde8a7c11"}]'::jsonb)
   AS e(sig text, oid text, owner text, acl text, source_md5 text, ddl_sha256 text)
   LEFT JOIN pg_proc p ON p.oid=to_regprocedure(e.sig)
   WHERE p.oid::text IS DISTINCT FROM e.oid OR p.proowner::regrole::text IS DISTINCT FROM e.owner
      OR p.proacl::text IS DISTINCT FROM e.acl OR md5(p.prosrc) IS DISTINCT FROM e.source_md5
      OR encode(extensions.digest(convert_to(pg_get_functiondef(p.oid),'UTF8'),'sha256'),'hex') IS DISTINCT FROM e.ddl_sha256)
   THEN RAISE EXCEPTION 'PILL_AFTER_FUNCTION_DRIFT'; END IF;
 SELECT * INTO STRICT prior_release FROM mission_public_owner.release_admissions_v1
 WHERE release_sha256=rr.revision_sha256 FOR SHARE;
 SELECT * INTO STRICT prior_qualification FROM mission_public_owner.public_qualification_attestations_v1
 WHERE release_sha256=rr.revision_sha256 FOR SHARE;
 SELECT to_jsonb(x) INTO STRICT runtime_before FROM mission_public_owner.party_launch_runtime_v1 x WHERE singleton FOR UPDATE;
 IF prior_release.edge_sha256 IS DISTINCT FROM generic_ezbr
 OR public.combat_v2_sha256(prior_qualification.payload->'capabilities') IS DISTINCT FROM '49fe134f561273f28e8071b63c45886341371b67d028f06e6b7d8f8d4108e817'
 OR runtime_before IS DISTINCT FROM jsonb_set('{"public_enabled":true,"release_sha256":"799e64f09637b5a7d331c3faf931ccab0c114cf33565c78b1cb40feefec82967","singleton":true,"staff_enabled":true}'::jsonb,'{release_sha256}',to_jsonb(rr.revision_sha256),false)
 OR (SELECT count(*) FROM mission_public_owner.mission_content_admissions_v1 c
   WHERE c.engine_release_sha256=rr.revision_sha256 AND mission_public_owner.content_admission_v1(c.mission_id,rr.revision_sha256,c.publication_request,true) IS NOT NULL) IS DISTINCT FROM 2
 OR (SELECT count(DISTINCT profile_key) FROM mission_public_owner.engine_profile_events_v1
     WHERE engine_release_sha256=rr.revision_sha256) IS DISTINCT FROM 1
 
 OR mission_public_owner.engine_qualification_v1(rr.revision_sha256,true) IS NULL
 THEN RAISE EXCEPTION 'PILL_PARENT_MISSION_BOUNDARY'; END IF;
 resources_before:=jsonb_build_object(
'characters', (SELECT public.combat_v2_sha256(coalesce(jsonb_agg(to_jsonb(row_data) ORDER BY to_jsonb(row_data)::text),'[]'::jsonb)) FROM public.characters row_data WHERE row_data.id IN ('2a877f02-4993-4e65-9172-7d29f08c5b86'::uuid,'6bceee99-974f-426b-8d92-38b43b4a4267'::uuid)),
'character_inventory', (SELECT public.combat_v2_sha256(coalesce(jsonb_agg(to_jsonb(row_data) ORDER BY to_jsonb(row_data)::text),'[]'::jsonb)) FROM public.character_inventory row_data WHERE row_data.character_id IN ('2a877f02-4993-4e65-9172-7d29f08c5b86'::uuid,'6bceee99-974f-426b-8d92-38b43b4a4267'::uuid)),
'character_equipment', (SELECT public.combat_v2_sha256(coalesce(jsonb_agg(to_jsonb(row_data) ORDER BY to_jsonb(row_data)::text),'[]'::jsonb)) FROM public.character_equipment row_data WHERE row_data.character_id IN ('2a877f02-4993-4e65-9172-7d29f08c5b86'::uuid,'6bceee99-974f-426b-8d92-38b43b4a4267'::uuid)),
'character_abilities', (SELECT public.combat_v2_sha256(coalesce(jsonb_agg(to_jsonb(row_data) ORDER BY to_jsonb(row_data)::text),'[]'::jsonb)) FROM public.character_abilities row_data WHERE row_data.character_id IN ('2a877f02-4993-4e65-9172-7d29f08c5b86'::uuid,'6bceee99-974f-426b-8d92-38b43b4a4267'::uuid)),
'character_jutsu', (SELECT public.combat_v2_sha256(coalesce(jsonb_agg(to_jsonb(row_data) ORDER BY to_jsonb(row_data)::text),'[]'::jsonb)) FROM public.character_jutsu row_data JOIN public.characters owner ON owner.user_id=row_data.user_id WHERE owner.id IN ('2a877f02-4993-4e65-9172-7d29f08c5b86'::uuid,'6bceee99-974f-426b-8d92-38b43b4a4267'::uuid)));
 
WITH p AS MATERIALIZED (
 SELECT r.revision_sha256 AS root_sha,r.canonical_preimage::jsonb AS j
 FROM mission_factory_owner.editor_release_readiness r WHERE r.singleton AND r.revision_sha256='de34836ca073cda7dcf5d5920ff39d131d0da200a4100ac7589fea6f33663c3f' AND r.canonical_preimage::jsonb#>>'{db_core,pill_staff}'='cf9238856c043a3e4cb20890293af8dc3be58e751141589c04c54bd7ca147c45' AND r.canonical_preimage::jsonb#>>'{config,pill_staff}'='cf9238856c043a3e4cb20890293af8dc3be58e751141589c04c54bd7ca147c45'
), peer_rows AS MATERIALIZED (
 SELECT p.oid::regprocedure::text AS sig,
 jsonb_build_object('signature',p.oid::regprocedure::text,
  'source_md5',md5(p.prosrc),'ddl_md5',md5(pg_get_functiondef(p.oid)),
  'owner',pg_get_userbyid(p.proowner),'secdef',p.prosecdef,'config',p.proconfig,
  'acl',p.proacl::text,'volatility',p.provolatile::text) AS metadata
 FROM pg_proc p WHERE p.oid IN ('combat_panel_private.round_options_authoritative(uuid,uuid)'::regprocedure,'public.combat_v2_substitution_options_v1(uuid)'::regprocedure,'public.combat_v2_substitution_round_offers_v1(uuid,uuid)'::regprocedure,'public.combat_v2_substitution_select_v1(uuid,uuid)'::regprocedure,'clan_innata_private.catalogo_eligibility_release_v1()'::regprocedure,'combat_panel_private.publish_master_declaration(uuid,text)'::regprocedure)
), peer AS MATERIALIZED (
 SELECT count(*) AS n,public.combat_v2_sha256(jsonb_agg(
      CASE WHEN sig='clan_innata_private.catalogo_eligibility_release_v1()'
      THEN metadata||jsonb_build_object('source_md5','0b45f09f8f4d1257fb50461bde8a7c11',
                                         'ddl_md5','385cfe6490299ce6694d31d307acf36d')
      ELSE metadata END ORDER BY sig)) AS digest
 FROM peer_rows
), patched AS MATERIALIZED (
 SELECT p.*,peer.digest AS peer_sha,jsonb_set(jsonb_set(jsonb_set(jsonb_set(jsonb_set(jsonb_set(jsonb_set(jsonb_set(jsonb_set(jsonb_set(jsonb_set(jsonb_set(jsonb_set(jsonb_set(jsonb_set(jsonb_set(jsonb_set(jsonb_set(jsonb_set(p.j,'{db_core,pill_staff}',to_jsonb('86c7b40969d82d5f6f0d885cfc7ab0d3fa89887f61ab901e586c2787a62e3386'::text),true),'{db_core,catalogo_eligibility_compat,shared_manifest_sha256}',to_jsonb('9720e93192c9f54839ecd08e02948b012efcd69c653ad4a3227cbaa811257a25'::text),false),'{db_core,catalogo_eligibility_compat,functions}','[{"acl":"{postgres=X/postgres}","config":["search_path=\"\""],"ddl_md5":"385cfe6490299ce6694d31d307acf36d","owner":"postgres","secdef":true,"signature":"clan_innata_private.catalogo_eligibility_release_v1()","source_md5":"0b45f09f8f4d1257fb50461bde8a7c11","volatility":"s"},{"acl":"{postgres=X/postgres}","config":["search_path=pg_catalog, public, clan_innata_private"],"ddl_md5":"c853342118edc3e2d886aef09661da1b","owner":"postgres","secdef":true,"signature":"clan_innata_private.eligibility_release_assert()","source_md5":"d12a616a859cd2b497004d0f17395437","volatility":"s"}]'::jsonb,false),'{db_core,catalogo_eligibility_compat,functions_manifest_sha256}',to_jsonb(public.combat_v2_sha256('[{"acl":"{postgres=X/postgres}","config":["search_path=\"\""],"ddl_md5":"385cfe6490299ce6694d31d307acf36d","owner":"postgres","secdef":true,"signature":"clan_innata_private.catalogo_eligibility_release_v1()","source_md5":"0b45f09f8f4d1257fb50461bde8a7c11","volatility":"s"},{"acl":"{postgres=X/postgres}","config":["search_path=pg_catalog, public, clan_innata_private"],"ddl_md5":"c853342118edc3e2d886aef09661da1b","owner":"postgres","secdef":true,"signature":"clan_innata_private.eligibility_release_assert()","source_md5":"d12a616a859cd2b497004d0f17395437","volatility":"s"}]'::jsonb)),false),'{db_core,catalogo_eligibility_compat,helper_source_md5}',to_jsonb('0b45f09f8f4d1257fb50461bde8a7c11'::text),false),'{db_core,cure_command_amendment,shared_manifest_sha256}',to_jsonb('9720e93192c9f54839ecd08e02948b012efcd69c653ad4a3227cbaa811257a25'::text),false),'{db_core,cure_command_amendment,helper_source_md5}',to_jsonb('0b45f09f8f4d1257fb50461bde8a7c11'::text),false),'{db_core,cure_command_amendment,functions_manifest_sha256}',to_jsonb(peer.digest),false),'{config,pill_staff}',to_jsonb('86c7b40969d82d5f6f0d885cfc7ab0d3fa89887f61ab901e586c2787a62e3386'::text),true),'{config,catalogo_eligibility_compat,shared_manifest_sha256}',to_jsonb('9720e93192c9f54839ecd08e02948b012efcd69c653ad4a3227cbaa811257a25'::text),false),'{config,catalogo_eligibility_compat,functions}','[{"acl":"{postgres=X/postgres}","config":["search_path=\"\""],"ddl_md5":"385cfe6490299ce6694d31d307acf36d","owner":"postgres","secdef":true,"signature":"clan_innata_private.catalogo_eligibility_release_v1()","source_md5":"0b45f09f8f4d1257fb50461bde8a7c11","volatility":"s"},{"acl":"{postgres=X/postgres}","config":["search_path=pg_catalog, public, clan_innata_private"],"ddl_md5":"c853342118edc3e2d886aef09661da1b","owner":"postgres","secdef":true,"signature":"clan_innata_private.eligibility_release_assert()","source_md5":"d12a616a859cd2b497004d0f17395437","volatility":"s"}]'::jsonb,false),'{config,catalogo_eligibility_compat,functions_manifest_sha256}',to_jsonb(public.combat_v2_sha256('[{"acl":"{postgres=X/postgres}","config":["search_path=\"\""],"ddl_md5":"385cfe6490299ce6694d31d307acf36d","owner":"postgres","secdef":true,"signature":"clan_innata_private.catalogo_eligibility_release_v1()","source_md5":"0b45f09f8f4d1257fb50461bde8a7c11","volatility":"s"},{"acl":"{postgres=X/postgres}","config":["search_path=pg_catalog, public, clan_innata_private"],"ddl_md5":"c853342118edc3e2d886aef09661da1b","owner":"postgres","secdef":true,"signature":"clan_innata_private.eligibility_release_assert()","source_md5":"d12a616a859cd2b497004d0f17395437","volatility":"s"}]'::jsonb)),false),'{config,catalogo_eligibility_compat,helper_source_md5}',to_jsonb('0b45f09f8f4d1257fb50461bde8a7c11'::text),false),'{config,cure_command_amendment,shared_manifest_sha256}',to_jsonb('9720e93192c9f54839ecd08e02948b012efcd69c653ad4a3227cbaa811257a25'::text),false),'{config,cure_command_amendment,helper_source_md5}',to_jsonb('0b45f09f8f4d1257fb50461bde8a7c11'::text),false),'{config,cure_command_amendment,functions_manifest_sha256}',to_jsonb(peer.digest),false),'{db_core,catalogo_families,2}','["5b8cc87dc91085b066f32e32ca70ca5d72d3643d337a6531777390e7749fc98d","329838b340bb6a92e56253c5f3980d9df6623ac0ae2add83082b11f078160bd7","fd740654e1f3a83eb84c5634bd8da7f6895022bf2ee200deca3032ebfc83f78e"]'::jsonb,false),'{db_core,all_function_headers,228,source_md5}',to_jsonb('ad3cec069a1a0c5ab4a4a804de12bbec'::text),false),'{db_core,all_function_headers,228,ddl_md5}',to_jsonb('19c0226969fc069225a14c65a5d563e9'::text),false) AS stage_doc
 FROM p CROSS JOIN peer WHERE peer.n=6
 AND p.j#>>'{db_core,all_function_headers,228,oid}'='44940'
 AND p.j#>>'{db_core,sfera_staff}'='d2f38943c31031ee0fa051e57add33095908eed0806382d93984fb44d111a2eb'
 AND p.j#>>'{db_core,velo_staff}'='35d754465f1c19509822e9728ade3e23c3d2aefe63f441aff01908e774dfcef6'
), mirrors AS MATERIALIZED (
 SELECT *,jsonb_set(stage_doc,'{config,catalogo_families}',
               to_jsonb(public.combat_v2_sha256(stage_doc#>'{db_core,catalogo_families}')),false) AS parts
 FROM patched
), digests AS MATERIALIZED (
 SELECT *,public.combat_v2_sha256((parts->'db_core')-'sha256') AS db_sha,
          public.combat_v2_sha256((parts->'config')-'sha256') AS config_sha
 FROM mirrors
), identities AS MATERIALIZED (
 SELECT d.*,public.combat_v2_sha256(jsonb_build_object(
  'contract','staff-chakra-pill/1','mode','inert','parent',d.root_sha,
  'prior_code_identity',d.j#>'{contract,code_identity_sha256}','leaf','86c7b40969d82d5f6f0d885cfc7ab0d3fa89887f61ab901e586c2787a62e3386',
  'db',d.db_sha,'config',d.config_sha,'edge',d.j->'edge_bundles')) AS code_sha
 FROM digests d
), combined AS MATERIALIZED (
 SELECT i.*,jsonb_set(jsonb_set(jsonb_set(jsonb_set(i.parts,'{db_core,sha256}',to_jsonb(i.db_sha),false),
  '{config,sha256}',to_jsonb(i.config_sha),false),'{contract,code_identity_sha256}',to_jsonb(i.code_sha),false),
  '{recovery,semantic_identity_sha256}',to_jsonb(i.code_sha),false) AS root_document
 FROM identities i
), candidate AS MATERIALIZED (
 SELECT *,regexp_replace(root_document::text,$rx$("(?:[^"\\]|\\.)*")|[[:space:]]+$rx$,$b$\1$b$,'g') AS root_text FROM combined
)

 SELECT c.root_text INTO STRICT root_text FROM candidate c
 WHERE c.root_text::jsonb=c.root_document AND octet_length(c.root_text)<=524288;
 old_root_sha:=rr.revision_sha256;
 old_row_sha:=public.combat_v2_sha256(to_jsonb(rr));
 candidate_root:=root_text::jsonb;
 db_sha:=candidate_root#>>'{db_core,sha256}'; config_sha:=candidate_root#>>'{config,sha256}';
 new_root_sha:=encode(extensions.digest(convert_to(root_text,'UTF8'),'sha256'),'hex');
 IF new_root_sha IS DISTINCT FROM '74dc4f0ec1a66c0b0a2f18f4f9b67f179d5b1bf1e6ae8c45338de2ddd63454f5'
   OR octet_length(root_text) IS DISTINCT FROM 524230 OR octet_length(root_text)>524288
   OR db_sha IS DISTINCT FROM public.combat_v2_sha256((candidate_root->'db_core')-'sha256')
   OR config_sha IS DISTINCT FROM public.combat_v2_sha256((candidate_root->'config')-'sha256')
   OR candidate_root#>>'{db_core,pill_staff}' IS DISTINCT FROM '86c7b40969d82d5f6f0d885cfc7ab0d3fa89887f61ab901e586c2787a62e3386'
   OR candidate_root#>>'{config,pill_staff}' IS DISTINCT FROM '86c7b40969d82d5f6f0d885cfc7ab0d3fa89887f61ab901e586c2787a62e3386'
   OR candidate_root#>>'{db_core,sfera_staff}' IS DISTINCT FROM 'd2f38943c31031ee0fa051e57add33095908eed0806382d93984fb44d111a2eb'
   OR candidate_root#>>'{db_core,velo_staff}' IS DISTINCT FROM '35d754465f1c19509822e9728ade3e23c3d2aefe63f441aff01908e774dfcef6'
   OR public.combat_v2_sha256(candidate_root->'ui') IS DISTINCT FROM 'b62cac808730c14ff1558ac666b3a76c3cc264e4716b858205acada9efadefc9'
   OR public.combat_v2_sha256(candidate_root->'edge_bundles') IS DISTINCT FROM '67ee310b994f65492aa094f6f3f6e435aa2faf95d98246bbc6b00b90afc9c783'
 THEN RAISE EXCEPTION 'PILL_FINAL_ROOT_BINDING'; END IF;
 params:='{"compatibility":{"ref":"pillola-staff-inert-existing-missions","sha256":"86c7b40969d82d5f6f0d885cfc7ab0d3fa89887f61ab901e586c2787a62e3386"},"expected_mission_capabilities_sha256":"49fe134f561273f28e8071b63c45886341371b67d028f06e6b7d8f8d4108e817"}'::jsonb;
 bindings:=jsonb_build_object('db_sha256',db_sha,'edge_sha256',generic_ezbr,
   'client_sha256',public.combat_v2_sha256(candidate_root->'ui'),'configuration_sha256',config_sha);
 UPDATE mission_factory_owner.editor_release_readiness
 SET canonical_preimage=root_text,revision_sha256=new_root_sha,observed_revision_sha256=new_root_sha,
   client_build='mission-factory-admin/2:'||new_root_sha,independent_review_ref=review->>'ref',updated_at=clock_timestamp()
 WHERE singleton AND revision_sha256=old_root_sha AND public.combat_v2_sha256(to_jsonb(editor_release_readiness))=old_row_sha;
 GET DIAGNOSTICS affected=ROW_COUNT;
 IF affected<>1 THEN RAISE EXCEPTION 'PILL_ROOT_CAS'; END IF;
 UPDATE combat_panel_private.chakra_pill_staff_gate_v1 SET staff_enabled=false
 WHERE singleton AND staff_enabled IS NOT DISTINCT FROM true;
 GET DIAGNOSTICS affected=ROW_COUNT;
 IF affected<>1 THEN RAISE EXCEPTION 'PILL_GATE_CAS'; END IF;
 IF NOT clan_innata_private.catalogo_eligibility_release_v1() THEN RAISE EXCEPTION 'PILL_POST_CAS_E52'; END IF;
 PERFORM clan_innata_private.runtime_release_assert();
  INSERT INTO mission_public_owner.release_admissions_v1(release_sha256,db_sha256,edge_sha256,client_sha256,configuration_sha256,
  contract_version,independent_review_ref,staff_evidence_ref,qualified_at,public_enabled)
 VALUES(new_root_sha,db_sha,generic_ezbr,bindings->>'client_sha256',config_sha,prior_release.contract_version,
  review->>'ref',prior_release.staff_evidence_ref,prior_release.qualified_at,prior_release.public_enabled);
 FOR profile_row IN SELECT DISTINCT ON(profile_key)* FROM mission_public_owner.engine_profile_events_v1
  WHERE engine_release_sha256=old_root_sha ORDER BY profile_key,control_version DESC LOOP
  IF profile_row.profile_key IS DISTINCT FROM prior_qualification.payload->>'authoring_profile' THEN
   RAISE EXCEPTION 'PILL_ROOT_UNQUALIFIED_PROFILE_CARRYFORWARD';END IF;
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
 OR mission_public_owner.engine_qualification_v1(new_root_sha,true)IS NULL THEN RAISE EXCEPTION 'PILL_ROOT_MISSION_CARRYFORWARD_INVALID';END IF;
 FOR content_row IN SELECT * FROM mission_public_owner.mission_content_admissions_v1 WHERE engine_release_sha256=old_root_sha ORDER BY mission_id LOOP
  content_request:=extensions.uuid_generate_v5(content_row.request_key,new_root_sha||':catalogo-compatible-adoption');
  content_payload:=content_row.payload||jsonb_build_object('request_key',content_request,'engine_release_sha256',new_root_sha,'created_at',clock_timestamp());
  INSERT INTO mission_public_owner.mission_content_admissions_v1(request_key,mission_id,config_version,engine_release_sha256,publication_request,payload,payload_sha256)
  VALUES(content_request,content_row.mission_id,content_row.config_version,new_root_sha,content_row.publication_request,content_payload,mission_factory_owner.sha(content_payload));
  IF mission_public_owner.content_admission_v1(content_row.mission_id,new_root_sha,content_row.publication_request,true)IS NULL THEN
   RAISE EXCEPTION 'PILL_ROOT_CONTENT_CARRYFORWARD_INVALID';END IF;
 END LOOP;
 UPDATE mission_public_owner.party_launch_runtime_v1 x SET release_sha256=new_root_sha WHERE singleton AND to_jsonb(x)=runtime_before;
 GET DIAGNOSTICS affected=ROW_COUNT;IF affected<>1 THEN RAISE EXCEPTION 'PILL_ROOT_PARTY_RUNTIME_CAS';END IF;

 IF (SELECT count(*) FROM mission_public_owner.mission_content_admissions_v1 c
     WHERE c.engine_release_sha256=new_root_sha
       AND mission_public_owner.content_admission_v1(c.mission_id,new_root_sha,c.publication_request,true) IS NOT NULL) IS DISTINCT FROM 2
   OR (SELECT to_jsonb(x) FROM mission_public_owner.party_launch_runtime_v1 x WHERE singleton)
      IS DISTINCT FROM jsonb_set(runtime_before,'{release_sha256}',to_jsonb(new_root_sha),false)
   OR resources_before IS DISTINCT FROM jsonb_build_object(
'characters', (SELECT public.combat_v2_sha256(coalesce(jsonb_agg(to_jsonb(row_data) ORDER BY to_jsonb(row_data)::text),'[]'::jsonb)) FROM public.characters row_data WHERE row_data.id IN ('2a877f02-4993-4e65-9172-7d29f08c5b86'::uuid,'6bceee99-974f-426b-8d92-38b43b4a4267'::uuid)),
'character_inventory', (SELECT public.combat_v2_sha256(coalesce(jsonb_agg(to_jsonb(row_data) ORDER BY to_jsonb(row_data)::text),'[]'::jsonb)) FROM public.character_inventory row_data WHERE row_data.character_id IN ('2a877f02-4993-4e65-9172-7d29f08c5b86'::uuid,'6bceee99-974f-426b-8d92-38b43b4a4267'::uuid)),
'character_equipment', (SELECT public.combat_v2_sha256(coalesce(jsonb_agg(to_jsonb(row_data) ORDER BY to_jsonb(row_data)::text),'[]'::jsonb)) FROM public.character_equipment row_data WHERE row_data.character_id IN ('2a877f02-4993-4e65-9172-7d29f08c5b86'::uuid,'6bceee99-974f-426b-8d92-38b43b4a4267'::uuid)),
'character_abilities', (SELECT public.combat_v2_sha256(coalesce(jsonb_agg(to_jsonb(row_data) ORDER BY to_jsonb(row_data)::text),'[]'::jsonb)) FROM public.character_abilities row_data WHERE row_data.character_id IN ('2a877f02-4993-4e65-9172-7d29f08c5b86'::uuid,'6bceee99-974f-426b-8d92-38b43b4a4267'::uuid)),
'character_jutsu', (SELECT public.combat_v2_sha256(coalesce(jsonb_agg(to_jsonb(row_data) ORDER BY to_jsonb(row_data)::text),'[]'::jsonb)) FROM public.character_jutsu row_data JOIN public.characters owner ON owner.user_id=row_data.user_id WHERE owner.id IN ('2a877f02-4993-4e65-9172-7d29f08c5b86'::uuid,'6bceee99-974f-426b-8d92-38b43b4a4267'::uuid)))
 THEN RAISE EXCEPTION 'PILL_FINAL_MISSION_OR_RESOURCES_BOUNDARY'; END IF;
 PERFORM set_config('app.pill_release_result',jsonb_build_object('previous_root',old_root_sha,'root',new_root_sha,
  'root_bytes',octet_length(root_text),'staff_enabled',false,'public_enabled',false,'provider_calls',0,
  'staff_gameplay','NOT_RUN','two_mission_admissions',true,'protected_resources_identical',true)::text,true);

END;
$pill_inert$;

SELECT current_setting('app.pill_release_result',true)::jsonb AS release_receipt;
COMMIT;
