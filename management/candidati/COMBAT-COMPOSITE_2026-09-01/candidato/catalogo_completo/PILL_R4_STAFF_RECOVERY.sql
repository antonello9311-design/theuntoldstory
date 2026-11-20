BEGIN;
SET LOCAL search_path='';
SET LOCAL lock_timeout='2s';
DO $pill_r4_inert$
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
 
 review:=$pill_review${"ref":"PILL_R4_STAFF_RECOVERY_REVIEW","sha256":"cfb54a7a3823c14daad37a03903d46111d11c2ebc8a3a8d235ab2a308f8a7920","P0":0,"P1":0,"P2":0}$pill_review$::jsonb;
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
 IF rr.revision_sha256 IS DISTINCT FROM '5d5b68c60256c9a1d1fad9eec6ca30c4346a2dee9202e4c9f9584d2f2734a129'
   OR octet_length(rr.canonical_preimage) IS DISTINCT FROM 524230
   OR (SELECT g.staff_enabled FROM combat_panel_private.chakra_pill_staff_gate_v1 g WHERE singleton) IS DISTINCT FROM true
 THEN RAISE EXCEPTION 'PILL_R4_ACTIVE_PARENT_REQUIRED';END IF;
 IF EXISTS(SELECT 1 FROM jsonb_to_recordset('[{"acl":"{postgres=X/postgres}","config":["search_path=\"\""],"ddl_md5":"41e2a1299f5596a630c80305fcbcaffb","ddl_sha256":"0d24cfc44b693f4303e87831c113dfbb85b2178663e7f52af2e2d79c9666928f","oid":"684829","owner":"postgres","security_definer":true,"signature":"clan_innata_private.catalogo_eligibility_release_v1()","source_md5":"3527a5e7bfb068cb45498a46d9ed8b04","volatility":"s"},{"acl":"{postgres=X/postgres}","config":["search_path=\"\""],"ddl_md5":"6f29ef348683add7f830a4051501a214","ddl_sha256":"55221b397209efacf205254582a952d283c70cca1264b5bbcd2d5a9918a59167","oid":"702261","owner":"postgres","security_definer":true,"signature":"combat_panel_private.chakra_pill_staff_commit_v1(jsonb)","source_md5":"1c42ef5f3f511155c4fd24ce9a281944","volatility":"v"},{"acl":"{postgres=X/postgres}","config":["search_path=pg_catalog, public, clan_innata_private"],"ddl_md5":"c853342118edc3e2d886aef09661da1b","ddl_sha256":"d034de670fcf5ad17d3f4663fe209cda5ca3d85e1c8b86f1bff26fb938f002bb","oid":"41419","owner":"postgres","security_definer":true,"signature":"clan_innata_private.eligibility_release_assert()","source_md5":"d12a616a859cd2b497004d0f17395437","volatility":"s"}]'::jsonb)
 AS e(signature text,oid text,owner text,acl text,config jsonb,security_definer boolean,volatility text,source_md5 text,ddl_sha256 text)
 LEFT JOIN pg_proc p ON p.oid=to_regprocedure(e.signature)
 WHERE p.oid::text IS DISTINCT FROM e.oid OR p.proowner::regrole::text IS DISTINCT FROM e.owner
  OR p.proacl::text IS DISTINCT FROM e.acl OR to_jsonb(p.proconfig) IS DISTINCT FROM e.config
  OR p.prosecdef IS DISTINCT FROM e.security_definer OR p.provolatile::text IS DISTINCT FROM e.volatility
  OR md5(p.prosrc) IS DISTINCT FROM e.source_md5
  OR encode(extensions.digest(convert_to(pg_get_functiondef(p.oid),'UTF8'),'sha256'),'hex') IS DISTINCT FROM e.ddl_sha256)
 THEN RAISE EXCEPTION 'PILL_R4_AFTER_BODY_OR_ABI_DRIFT';END IF;
 SELECT * INTO STRICT prior_release FROM mission_public_owner.release_admissions_v1
 WHERE release_sha256=rr.revision_sha256 FOR SHARE;
 SELECT * INTO STRICT prior_qualification FROM mission_public_owner.public_qualification_attestations_v1
 WHERE release_sha256=rr.revision_sha256 FOR SHARE;
 SELECT to_jsonb(x) INTO STRICT runtime_before FROM mission_public_owner.party_launch_runtime_v1 x WHERE singleton FOR UPDATE;
 IF prior_release.edge_sha256 IS DISTINCT FROM generic_ezbr
 OR public.combat_v2_sha256(prior_qualification.payload->'capabilities') IS DISTINCT FROM '49fe134f561273f28e8071b63c45886341371b67d028f06e6b7d8f8d4108e817'
 OR runtime_before IS DISTINCT FROM jsonb_set('{"public_enabled":true,"release_sha256":"de34836ca073cda7dcf5d5920ff39d131d0da200a4100ac7589fea6f33663c3f","singleton":true,"staff_enabled":true}'::jsonb,'{release_sha256}',to_jsonb(rr.revision_sha256),false)
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
'character_jutsu', (SELECT public.combat_v2_sha256(coalesce(jsonb_agg(to_jsonb(row_data) ORDER BY to_jsonb(row_data)::text),'[]'::jsonb)) FROM public.character_jutsu row_data JOIN public.characters owner ON owner.user_id=row_data.user_id WHERE owner.id IN ('2a877f02-4993-4e65-9172-7d29f08c5b86'::uuid,'6bceee99-974f-426b-8d92-38b43b4a4267'::uuid)),
 'pill_staff_ledger',(SELECT public.combat_v2_sha256(coalesce(jsonb_agg(to_jsonb(u) ORDER BY u.session_id,u.actor_id),'[]'::jsonb))
 FROM combat_panel_private.chakra_pill_staff_uses_v1 u));
 
WITH p AS MATERIALIZED (SELECT parent_row.revision_sha256 AS root_sha,parent_row.canonical_preimage::jsonb AS doc
          FROM mission_factory_owner.editor_release_readiness parent_row WHERE parent_row.singleton AND parent_row.revision_sha256='5d5b68c60256c9a1d1fad9eec6ca30c4346a2dee9202e4c9f9584d2f2734a129'
          
), peer_rows AS MATERIALIZED (
 SELECT f.oid::regprocedure::text AS sig,
  jsonb_build_object('signature',f.oid::regprocedure::text,'source_md5',md5(f.prosrc),
   'ddl_md5',md5(pg_get_functiondef(f.oid)),'owner',pg_get_userbyid(f.proowner),'secdef',f.prosecdef,
   'config',f.proconfig,'acl',f.proacl::text,'volatility',f.provolatile::text) AS value
 FROM pg_proc f WHERE f.oid IN ('combat_panel_private.round_options_authoritative(uuid,uuid)'::regprocedure,'public.combat_v2_substitution_options_v1(uuid)'::regprocedure,'public.combat_v2_substitution_round_offers_v1(uuid,uuid)'::regprocedure,'public.combat_v2_substitution_select_v1(uuid,uuid)'::regprocedure,'clan_innata_private.catalogo_eligibility_release_v1()'::regprocedure,'combat_panel_private.publish_master_declaration(uuid,text)'::regprocedure)
), pr AS MATERIALIZED (
 SELECT count(*) n,public.combat_v2_sha256(jsonb_agg(t.value ORDER BY t.sig)) AS before_sha,
  public.combat_v2_sha256(jsonb_agg(CASE WHEN t.sig='clan_innata_private.catalogo_eligibility_release_v1()'
   THEN t.value||jsonb_build_object('source_md5','3527a5e7bfb068cb45498a46d9ed8b04','ddl_md5','41e2a1299f5596a630c80305fcbcaffb')
   ELSE t.value END ORDER BY t.sig)) AS next_sha FROM peer_rows t
), patch AS MATERIALIZED (
 SELECT p.*,pr.next_sha AS peer_sha,jsonb_set(jsonb_set(jsonb_set(jsonb_set(jsonb_set(jsonb_set(jsonb_set(jsonb_set(jsonb_set(jsonb_set(jsonb_set(jsonb_set(p.doc,'{db_core,pill_staff}',to_jsonb('56593008fdce3145214a8f33debc10379438360a0c05ad40e52ef25cfeb6118f'::text),false),'{db_core,catalogo_eligibility_compat,functions}','[{"acl":"{postgres=X/postgres}","config":["search_path=\"\""],"ddl_md5":"41e2a1299f5596a630c80305fcbcaffb","owner":"postgres","secdef":true,"signature":"clan_innata_private.catalogo_eligibility_release_v1()","source_md5":"3527a5e7bfb068cb45498a46d9ed8b04","volatility":"s"},{"acl":"{postgres=X/postgres}","config":["search_path=pg_catalog, public, clan_innata_private"],"ddl_md5":"c853342118edc3e2d886aef09661da1b","owner":"postgres","secdef":true,"signature":"clan_innata_private.eligibility_release_assert()","source_md5":"d12a616a859cd2b497004d0f17395437","volatility":"s"}]'::jsonb,false),'{db_core,catalogo_eligibility_compat,helper_source_md5}',to_jsonb('3527a5e7bfb068cb45498a46d9ed8b04'::text),false),'{db_core,catalogo_eligibility_compat,functions_manifest_sha256}',to_jsonb(public.combat_v2_sha256('[{"acl":"{postgres=X/postgres}","config":["search_path=\"\""],"ddl_md5":"41e2a1299f5596a630c80305fcbcaffb","owner":"postgres","secdef":true,"signature":"clan_innata_private.catalogo_eligibility_release_v1()","source_md5":"3527a5e7bfb068cb45498a46d9ed8b04","volatility":"s"},{"acl":"{postgres=X/postgres}","config":["search_path=pg_catalog, public, clan_innata_private"],"ddl_md5":"c853342118edc3e2d886aef09661da1b","owner":"postgres","secdef":true,"signature":"clan_innata_private.eligibility_release_assert()","source_md5":"d12a616a859cd2b497004d0f17395437","volatility":"s"}]'::jsonb)),false),'{db_core,cure_command_amendment,helper_source_md5}',to_jsonb('3527a5e7bfb068cb45498a46d9ed8b04'::text),false),'{db_core,cure_command_amendment,functions_manifest_sha256}',to_jsonb(pr.next_sha),false),'{config,pill_staff}',to_jsonb('56593008fdce3145214a8f33debc10379438360a0c05ad40e52ef25cfeb6118f'::text),false),'{config,catalogo_eligibility_compat,functions}','[{"acl":"{postgres=X/postgres}","config":["search_path=\"\""],"ddl_md5":"41e2a1299f5596a630c80305fcbcaffb","owner":"postgres","secdef":true,"signature":"clan_innata_private.catalogo_eligibility_release_v1()","source_md5":"3527a5e7bfb068cb45498a46d9ed8b04","volatility":"s"},{"acl":"{postgres=X/postgres}","config":["search_path=pg_catalog, public, clan_innata_private"],"ddl_md5":"c853342118edc3e2d886aef09661da1b","owner":"postgres","secdef":true,"signature":"clan_innata_private.eligibility_release_assert()","source_md5":"d12a616a859cd2b497004d0f17395437","volatility":"s"}]'::jsonb,false),'{config,catalogo_eligibility_compat,helper_source_md5}',to_jsonb('3527a5e7bfb068cb45498a46d9ed8b04'::text),false),'{config,catalogo_eligibility_compat,functions_manifest_sha256}',to_jsonb(public.combat_v2_sha256('[{"acl":"{postgres=X/postgres}","config":["search_path=\"\""],"ddl_md5":"41e2a1299f5596a630c80305fcbcaffb","owner":"postgres","secdef":true,"signature":"clan_innata_private.catalogo_eligibility_release_v1()","source_md5":"3527a5e7bfb068cb45498a46d9ed8b04","volatility":"s"},{"acl":"{postgres=X/postgres}","config":["search_path=pg_catalog, public, clan_innata_private"],"ddl_md5":"c853342118edc3e2d886aef09661da1b","owner":"postgres","secdef":true,"signature":"clan_innata_private.eligibility_release_assert()","source_md5":"d12a616a859cd2b497004d0f17395437","volatility":"s"}]'::jsonb)),false),'{config,cure_command_amendment,helper_source_md5}',to_jsonb('3527a5e7bfb068cb45498a46d9ed8b04'::text),false),'{config,cure_command_amendment,functions_manifest_sha256}',to_jsonb(pr.next_sha),false) AS changed_doc
 FROM p CROSS JOIN pr WHERE pr.n=6 AND pr.next_sha=p.doc#>>'{db_core,cure_command_amendment,functions_manifest_sha256}'
  AND p.doc#>>'{db_core,pill_staff}'='ad86bba1f557b4d262aee7a4029d068af15e7742dab993f4327bd8e05aecbb3f' AND p.doc#>>'{config,pill_staff}'='ad86bba1f557b4d262aee7a4029d068af15e7742dab993f4327bd8e05aecbb3f'
  AND p.doc#>'{db_core,sfera_staff}'=p.doc#>'{config,sfera_staff}'
  AND p.doc#>>'{db_core,sfera_staff}'='d2f38943c31031ee0fa051e57add33095908eed0806382d93984fb44d111a2eb'
  AND p.doc#>'{db_core,velo_staff}'=p.doc#>'{config,velo_staff}'
  AND p.doc#>>'{db_core,velo_staff}'='35d754465f1c19509822e9728ade3e23c3d2aefe63f441aff01908e774dfcef6'
  AND p.doc#>'{db_core,catalogo_families,2}'='["5b8cc87dc91085b066f32e32ca70ca5d72d3643d337a6531777390e7749fc98d","329838b340bb6a92e56253c5f3980d9df6623ac0ae2add83082b11f078160bd7","fd740654e1f3a83eb84c5634bd8da7f6895022bf2ee200deca3032ebfc83f78e"]'::jsonb
  AND public.combat_v2_sha256(p.doc->'ui')='b62cac808730c14ff1558ac666b3a76c3cc264e4716b858205acada9efadefc9'
  AND public.combat_v2_sha256(p.doc->'edge_bundles')='67ee310b994f65492aa094f6f3f6e435aa2faf95d98246bbc6b00b90afc9c783'
), digests AS MATERIALIZED (
 SELECT s.*,public.combat_v2_sha256((s.changed_doc->'db_core')-'sha256') AS db_sha,
  public.combat_v2_sha256((s.changed_doc->'config')-'sha256') AS config_sha FROM patch s
), identities AS MATERIALIZED (
 SELECT d.*,public.combat_v2_sha256(jsonb_build_object('contract','staff-chakra-pill/1','mode','inert',
 'parent',d.root_sha,'prior_code_identity',d.doc#>'{contract,code_identity_sha256}','leaf','56593008fdce3145214a8f33debc10379438360a0c05ad40e52ef25cfeb6118f',
 'db',d.db_sha,'config',d.config_sha,'edge',d.doc->'edge_bundles')) AS code_sha FROM digests d
), combined AS MATERIALIZED (
 SELECT i.*,jsonb_set(jsonb_set(jsonb_set(jsonb_set(i.changed_doc,'{db_core,sha256}',to_jsonb(i.db_sha),false),
 '{config,sha256}',to_jsonb(i.config_sha),false),'{contract,code_identity_sha256}',to_jsonb(i.code_sha),false),
 '{recovery,semantic_identity_sha256}',to_jsonb(i.code_sha),false) AS root_document FROM identities i
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
 IF new_root_sha IS DISTINCT FROM 'f8955a4e1390b3e86d69d988e703a72ddf0460bbc1f9e6aa6943ebfb2d9acc68'
   OR octet_length(root_text) IS DISTINCT FROM 524230 OR octet_length(root_text)>524288
   OR db_sha IS DISTINCT FROM public.combat_v2_sha256((candidate_root->'db_core')-'sha256')
   OR config_sha IS DISTINCT FROM public.combat_v2_sha256((candidate_root->'config')-'sha256')
   OR candidate_root#>>'{db_core,pill_staff}' IS DISTINCT FROM '56593008fdce3145214a8f33debc10379438360a0c05ad40e52ef25cfeb6118f'
   OR candidate_root#>>'{config,pill_staff}' IS DISTINCT FROM '56593008fdce3145214a8f33debc10379438360a0c05ad40e52ef25cfeb6118f'
   OR candidate_root#>>'{db_core,sfera_staff}' IS DISTINCT FROM 'd2f38943c31031ee0fa051e57add33095908eed0806382d93984fb44d111a2eb'
   OR candidate_root#>>'{db_core,velo_staff}' IS DISTINCT FROM '35d754465f1c19509822e9728ade3e23c3d2aefe63f441aff01908e774dfcef6'
   OR public.combat_v2_sha256(candidate_root->'ui') IS DISTINCT FROM 'b62cac808730c14ff1558ac666b3a76c3cc264e4716b858205acada9efadefc9'
   OR public.combat_v2_sha256(candidate_root->'edge_bundles') IS DISTINCT FROM '67ee310b994f65492aa094f6f3f6e435aa2faf95d98246bbc6b00b90afc9c783'
 THEN RAISE EXCEPTION 'PILL_FINAL_ROOT_BINDING'; END IF;
 params:='{"compatibility":{"ref":"pillola-staff-inert-existing-missions","sha256":"56593008fdce3145214a8f33debc10379438360a0c05ad40e52ef25cfeb6118f"},"expected_mission_capabilities_sha256":"49fe134f561273f28e8071b63c45886341371b67d028f06e6b7d8f8d4108e817"}'::jsonb;
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
   RAISE EXCEPTION 'PILL_R4_ROOT_UNQUALIFIED_PROFILE_CARRYFORWARD';END IF;
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
 OR mission_public_owner.engine_qualification_v1(new_root_sha,true)IS NULL THEN RAISE EXCEPTION 'PILL_R4_ROOT_MISSION_CARRYFORWARD_INVALID';END IF;
 FOR content_row IN SELECT * FROM mission_public_owner.mission_content_admissions_v1 WHERE engine_release_sha256=old_root_sha ORDER BY mission_id LOOP
  content_request:=extensions.uuid_generate_v5(content_row.request_key,new_root_sha||':catalogo-compatible-adoption');
  content_payload:=content_row.payload||jsonb_build_object('request_key',content_request,'engine_release_sha256',new_root_sha,'created_at',clock_timestamp());
  INSERT INTO mission_public_owner.mission_content_admissions_v1(request_key,mission_id,config_version,engine_release_sha256,publication_request,payload,payload_sha256)
  VALUES(content_request,content_row.mission_id,content_row.config_version,new_root_sha,content_row.publication_request,content_payload,mission_factory_owner.sha(content_payload));
  IF mission_public_owner.content_admission_v1(content_row.mission_id,new_root_sha,content_row.publication_request,true)IS NULL THEN
   RAISE EXCEPTION 'PILL_R4_ROOT_CONTENT_CARRYFORWARD_INVALID';END IF;
 END LOOP;
 UPDATE mission_public_owner.party_launch_runtime_v1 x SET release_sha256=new_root_sha WHERE singleton AND to_jsonb(x)=runtime_before;
 GET DIAGNOSTICS affected=ROW_COUNT;IF affected<>1 THEN RAISE EXCEPTION 'PILL_R4_ROOT_PARTY_RUNTIME_CAS';END IF;

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
'character_jutsu', (SELECT public.combat_v2_sha256(coalesce(jsonb_agg(to_jsonb(row_data) ORDER BY to_jsonb(row_data)::text),'[]'::jsonb)) FROM public.character_jutsu row_data JOIN public.characters owner ON owner.user_id=row_data.user_id WHERE owner.id IN ('2a877f02-4993-4e65-9172-7d29f08c5b86'::uuid,'6bceee99-974f-426b-8d92-38b43b4a4267'::uuid)),
 'pill_staff_ledger',(SELECT public.combat_v2_sha256(coalesce(jsonb_agg(to_jsonb(u) ORDER BY u.session_id,u.actor_id),'[]'::jsonb))
 FROM combat_panel_private.chakra_pill_staff_uses_v1 u))
 THEN RAISE EXCEPTION 'PILL_FINAL_MISSION_OR_RESOURCES_BOUNDARY'; END IF;
 PERFORM set_config('app.pill_release_result',jsonb_build_object('previous_root',old_root_sha,'root',new_root_sha,
  'root_bytes',octet_length(root_text),'staff_enabled',false,'public_enabled',false,'provider_calls',0,
  'staff_gameplay','NOT_RUN','two_mission_admissions',true,'protected_resources_identical',true,'pill_staff_ledger_sha256',resources_before->>'pill_staff_ledger')::text,true);


END;
$pill_r4_inert$;

SELECT current_setting('app.pill_release_result',true)::jsonb AS release_receipt;
COMMIT;
