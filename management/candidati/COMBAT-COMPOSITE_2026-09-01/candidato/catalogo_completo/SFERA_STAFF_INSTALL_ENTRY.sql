BEGIN;
SET LOCAL search_path='';
SET LOCAL lock_timeout='2s';

DO $sfera_pre$
#variable_conflict error
DECLARE
 
 rr mission_factory_owner.editor_release_readiness%ROWTYPE;
 prior_release mission_public_owner.release_admissions_v1%ROWTYPE;
 prior_qualification mission_public_owner.public_qualification_attestations_v1%ROWTYPE;
 runtime_before jsonb; review jsonb; edge_receipt jsonb;
 generic_ezbr constant text:='9a6889802cfa17c99a556538cccd4ad7ef75274d32adccbc192c23d257aa3e76';
 root_text text; candidate_root jsonb; db_sha text; config_sha text; new_root_sha text; old_root_sha text;

BEGIN
 
 review:=$sfera_review${"ref":"SFERA_R3_INSTALL_REVIEW","sha256":"8c88e4b99f4bd035f0eebd3e8e7ccdc9b44bc342645ef21eb19f63eb5c831709","P0":0,"P1":0,"P2":0}$sfera_review$::jsonb;
 IF NOT mission_factory_owner.keys_exact_v2(review,ARRAY['ref','sha256','P0','P1','P2'])
  OR coalesce(review->>'ref','')!~'^[A-Za-z0-9_.#-]{1,40}$'
  OR coalesce(review->>'sha256','')!~'^[a-f0-9]{64}$'
  OR review->'P0' IS DISTINCT FROM '0'::jsonb OR review->'P1' IS DISTINCT FROM '0'::jsonb
  OR review->'P2' IS DISTINCT FROM '0'::jsonb THEN RAISE EXCEPTION 'SFERA_REVIEW_REQUIRED';END IF;
 edge_receipt:=$sfera_edge${"version":47,"ezbr_sha256":"8dcd22121cdff0d8188a1a35120708fed4a13a8c4f962d99edb99173db87f6c4","deployment_receipt_sha256":"ff070a53c73cb83ccb00a769012bf90eb668143ccb18b20967f523146c1c99c3","bundle_content_sha256":"f4878a79eef0b41b3fe649972afd2921686b1ee0bd5f33c005ae5243f592edde"}$sfera_edge$::jsonb;
 IF NOT mission_factory_owner.keys_exact_v2(edge_receipt,ARRAY['version','ezbr_sha256','deployment_receipt_sha256','bundle_content_sha256'])
  OR jsonb_typeof(edge_receipt->'version') IS DISTINCT FROM 'number' OR (edge_receipt->>'version')::integer<=46
  OR coalesce(edge_receipt->>'ezbr_sha256','')!~'^[a-f0-9]{64}$'
  OR coalesce(edge_receipt->>'deployment_receipt_sha256','')!~'^[a-f0-9]{64}$'
  OR edge_receipt->>'ezbr_sha256' IN ('0000000000000000000000000000000000000000000000000000000000000000','1bdcde5a74ae789c610e7469a7906a419bb363b189b58133939ebb91db6c1775')
  OR edge_receipt->>'deployment_receipt_sha256' IN ('0000000000000000000000000000000000000000000000000000000000000000','ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff')
  OR edge_receipt->>'bundle_content_sha256' IS DISTINCT FROM 'f4878a79eef0b41b3fe649972afd2921686b1ee0bd5f33c005ae5243f592edde'
 THEN RAISE EXCEPTION 'SFERA_OFFICIAL_EDGE_RECEIPT_REQUIRED'; END IF;

 
 IF current_user<>'postgres' OR session_user<>'postgres' OR auth.uid() IS NOT NULL
  OR (SELECT rolbypassrls FROM pg_roles WHERE rolname='postgres') IS DISTINCT FROM true
 THEN RAISE EXCEPTION 'SFERA_OPERATOR_REQUIRED'; END IF;
 IF NOT pg_try_advisory_xact_lock(hashtextextended('C1266:GENERIC-AI:AVAILABILITY',0))
 THEN RAISE EXCEPTION 'SFERA_AVAILABILITY_BUSY';END IF;
 SELECT * INTO STRICT rr FROM mission_factory_owner.editor_release_readiness WHERE singleton FOR UPDATE NOWAIT;
 LOCK TABLE public.master_v2_sessions,public.combat_v2_sessions,combat_consumer_private.invitations,
  mission_public_owner.party_launch_runtime_v1 IN SHARE ROW EXCLUSIVE MODE NOWAIT;
 IF EXISTS(SELECT 1 FROM public.combat_v2_sessions WHERE closed_at IS NULL AND state IN('preparazione','in_corso','sospeso'))
  OR EXISTS(SELECT 1 FROM public.master_v2_sessions WHERE closed_at IS NULL AND stato NOT IN('chiusa','annullata'))
  OR EXISTS(SELECT 1 FROM combat_consumer_private.invitations WHERE state='pending'
    AND location_id='0b85f354-9cdb-47e1-baf9-3d266bb7e06b')
 THEN RAISE EXCEPTION 'SFERA_REQUIRES_QUIESCENCE'; END IF;
 IF rr.state IS DISTINCT FROM 'enabled' OR rr.scope IS DISTINCT FROM 'staff' OR NOT rr.staff_guards_verified
  OR NOT rr.published_assets_verified OR NOT clan_innata_private.catalogo_eligibility_release_v1()
 THEN RAISE EXCEPTION 'SFERA_NATIVE_BASELINE_UNQUALIFIED'; END IF;
 PERFORM clan_innata_private.runtime_release_assert();

 IF rr.revision_sha256 IS DISTINCT FROM '4aec6254673c4c076d313660659a11a0f0b502d434def8bd7a6e4a5c8776f479'
  OR public.combat_v2_sha256(to_jsonb(rr)) IS DISTINCT FROM 'e882ccc872e5f04774aef7138ffddf2d7eba468351ecb5e859f16dec34bcd235'
  OR octet_length(rr.canonical_preimage)<>523908 OR to_regclass('clan_aburame_private.sfera_staff_gate_v1') IS NOT NULL
 THEN RAISE EXCEPTION 'SFERA_LIVE_ROOT_OR_FOOTPRINT_DRIFT'; END IF;
 IF (SELECT public.combat_v2_sha256(to_jsonb(t)) FROM public.clan_techniques t
     WHERE t.id='07a93dee-a483-4a7b-b3e0-43146c2ce227' AND t.is_active)
    IS DISTINCT FROM 'ed59c81a0dc7d1c0d3aa3cacdc0b5ec9f4cf72280215a831658451a4b0f1b13b'
 THEN RAISE EXCEPTION 'SFERA_CATALOG_ROW_DRIFT'; END IF;
 
 IF EXISTS(SELECT 1 FROM jsonb_to_recordset($sfera_pins$[{"oid":"103987","sig":"clan_aburame_private.action_meta(uuid,uuid,uuid,jsonb)","ddl_md5":"4e8ba71c99aa0d5ae5627e428c140379","abi_sha256":"fc52236d7edeabb6991d0023b61370a556a7d3600b4c840c0c146dda07e26667","ddl_sha256":"cb04919f33adcc03d032466588c6c178caeefe22a307b4dfddfee1f6f1a726f6","source_md5":"984fd297ac3df51105b44a8b06b75673"},{"oid":"103974","sig":"clan_aburame_private.actor_ability(uuid,text,uuid,boolean,jsonb)","ddl_md5":"8a5a1196c6ef0111ff536c13dc3809b0","abi_sha256":"86249c1afe30cb1636e30e43732b859e04584f5b34b36e47b54483eb9cb872de","ddl_sha256":"94854bfbe28f545b3fd6c44ec7a4d9824d498902e40ef1c35320bd4f761b278b","source_md5":"a70ade415877161525005d1ab7e9891a"},{"oid":"103975","sig":"clan_aburame_private.attack_power_source(uuid,uuid)","ddl_md5":"b3b72a0c099c80c4b7c6babb9e0f075e","abi_sha256":"8d4587115ed2951b8bd6832499c596e9ef09f6e9c1a28433c8a6f1c243125964","ddl_sha256":"ec80a3815e09b676e73a60aa84b04dc27fe75554808fb89a1c803069bc2f9a4a","source_md5":"6cc5935ba628a3d8ad5be2101a599a33"},{"oid":"103994","sig":"clan_aburame_private.commit_control(jsonb,jsonb,combat_consumer_private.activities,combat_consumer_private.offers,uuid)","ddl_md5":"158b6f9d54f24d3b054b12d7e07d72d8","abi_sha256":"ebd6d5cfff931425dad92413bfb3729d5ae90d33372b74ef9b31fa6302be2754","ddl_sha256":"bcbb794033db3fd60aaebff8da1fc64150d7c7ab73827dc55401ab5a08f31bdd","source_md5":"45a665e8f3c087ef8a27e5fa37067b46"},{"oid":"104001","sig":"clan_aburame_private.commit_master_stop(jsonb)","ddl_md5":"30766d023aaba4238da1e70146e7e993","abi_sha256":"b5a5dde4a29a1aeb6d682e9bf12b50832047b3257fd4fbed01a93a1ac9779b92","ddl_sha256":"a5a028a71c84f4d4f4c580bd9bd7c45fdd6e1ce7476852e0dc8f56d4294e5b8d","source_md5":"3a796cdbb63fba3de4503ff37d344b33"},{"oid":"103990","sig":"clan_aburame_private.consumer_options(jsonb)","ddl_md5":"7e9287a256cef45a27142ef8854b4e66","abi_sha256":"b5a5dde4a29a1aeb6d682e9bf12b50832047b3257fd4fbed01a93a1ac9779b92","ddl_sha256":"62b0530ebc84bd5c2f7153838dc75543197b9af0597c94c3e6c301f6d809ae01","source_md5":"f37c13f60e9b9d50d29b2805f708ffe0"},{"oid":"103991","sig":"clan_aburame_private.lifecycle()","ddl_md5":"5253ea25e74221595839caa71454cc92","abi_sha256":"0afe54d3a0546711200bd7cf27035ce862b85ff043ec5844f6bcee216dea1bed","ddl_sha256":"f837cf81416d87569b41283378701e9a9c80d35676695d90d2ad5f79b843a29d","source_md5":"71f1221b6e6c7ea1d77f12fef94772a1"},{"oid":"103999","sig":"clan_aburame_private.master_offers(uuid,bigint,jsonb)","ddl_md5":"791e59fee7cb921629eb10358b502f71","abi_sha256":"face4c06af773cfeba8a310ccf0486d4dde2c32572de611195965b14db9d90f5","ddl_sha256":"ef51b49f88c07d95dd26c76027de262e67ed572244f4f96983354b2ff2ddd61a","source_md5":"7246d6464b9a471d1553b0c92968e492"},{"oid":"51291","sig":"clan_hyuga_private.rotation_attack_power_freeze(uuid)","ddl_md5":"7b26edb84b3174c9bc84faad279ad5b2","abi_sha256":"e0cc03f58bdc3b14100c6649fb9feb87873ce5c2a9d2d41307f9b9b283efb66a","ddl_sha256":"2e912410b6770f58f08d10c5b6855553bc03e66461e59b9da8cdbe01da9d2eae","source_md5":"ae3522f18c909b30c223e92f2882c838"},{"oid":"684829","sig":"clan_innata_private.catalogo_eligibility_release_v1()","ddl_md5":"41f45f4be9033482bf4be643e750ed47","abi_sha256":"dc03ebb3082eef5a2a7cc7ffe2dccec1506612d08da34f80c50b737425311774","ddl_sha256":"aa75acfc73af99e779b3be25d1969eb7d9251290140760606b8b020e70a94c2f","source_md5":"37778b193d749fe058330b67d53831c0"},{"oid":"42849","sig":"combat_consumer_private.commit_exchange(jsonb,jsonb)","ddl_md5":"a46d3e81cebf198185610315c73f0a1a","abi_sha256":"acd78e847089e7c7734bd03078805047fee645d4dde38e7f8318ef69a2bd0c2a","ddl_sha256":"95dd10e01634ecd83395897a43ca6543773a2fb7c798efe9f097ca6db4628b70","source_md5":"0dd8a2a38f25312eaf8ec98e5ce2fd14"},{"sig":"combat_consumer_private.narrative_context(uuid)","oid":"42942","source_md5":"84031451f48f40639d7f2a1fe8e957d3","ddl_md5":"3f67e976ddab257ce59ec1785a0365fb","ddl_sha256":"ca63952619a2138b08a2d0470151109a2e43f34d54ce482698df3ccbbe0073b4","abi_sha256":"4069439528f55edc591049d06b40b42dfa3a55dc89cd94dd88a752a11da7caf4"},{"oid":"46723","sig":"combat_consumer_private.narrative_declaration_supported(uuid)","ddl_md5":"9d2cad68a149da7f97c177bcf51d73c0","abi_sha256":"9cbc335cc097ecc96970c4048a00c34c1551c6979c90d313bb6ccbe73f2b89bf","ddl_sha256":"51ebf49d26e7a7590f9a5be23fe8569928cfaa6406238fadeb7fd7462cc1d29a","source_md5":"1ed7184037cedfef9d606dfd7090e7a4"},{"oid":"42968","sig":"combat_consumer_private.validate_narrative_result(jsonb)","ddl_md5":"097d6805ce2b21e21fc9aa7fe2a5a9ca","abi_sha256":"18006465d4873283bc66576fb84b423647bfe6e8ce5600b7f85bab4f524319ae","ddl_sha256":"1e546094f4bc610f26d822796720e243a262e7c7453e0a0de79af12eaf33d932","source_md5":"6664101fcd222bd583e9ae8cf7b2b7fc"},{"oid":"52133","sig":"combat_effects_private.lifecycle_open(uuid,uuid)","ddl_md5":"531b5e14f873e40a1b5042f40ea1b15d","abi_sha256":"89e96dfdb9c4e0622381e328d131f16cc5509789bce1c87189738c8192641380","ddl_sha256":"9d2b110d921df70000a70c8261cd9db036eee18dc82a710a13bbb1a0c3f49c7d","source_md5":"25b975033c044147b540a6e6492f1b85"},{"oid":"46307","sig":"combat_panel_private.consumer_commit_authoritative(jsonb)","ddl_md5":"0ab0b5f9f49879ac3098b8d725f36b5f","abi_sha256":"b5a5dde4a29a1aeb6d682e9bf12b50832047b3257fd4fbed01a93a1ac9779b92","ddl_sha256":"2a09714b134f8618540191fd2d0ef6a67dfdf79f69981d1ba31ec64b53f4caad","source_md5":"c6bb2e3639da7cc65e5c422afea5ffa8"},{"oid":"45000","sig":"combat_panel_private.movement_block_reason(uuid)","ddl_md5":"4830deea719904406d11aa4b05cfd764","abi_sha256":"d3c9bd2b08e411046c0c416c43fa931a2f7beb6f01927d16b2a4c2a99dda3097","ddl_sha256":"2cb55e145c05b8df468706297d83bff59461027b7c2f958f90b6688a3b84695b","source_md5":"9cd995d873f2ae85f3cac5c0d7ff21ad"},{"oid":"46019","sig":"combat_panel_private.narrative_declaration_facts(uuid)","ddl_md5":"4650bb589eddf6b71249114fe08c5844","abi_sha256":"4069439528f55edc591049d06b40b42dfa3a55dc89cd94dd88a752a11da7caf4","ddl_sha256":"5cdbbb9870637b5dc0aa3cb7b9c8838cf51b7d53dc81ac6e7a5dad222640f40b","source_md5":"89ee0fe9b71918c3ba0cf25f7a334f45"},{"oid":"46020","sig":"combat_panel_private.narrative_ordinary_context(uuid)","ddl_md5":"a811eaf1eafd4203b019825e4d84b2dc","abi_sha256":"4069439528f55edc591049d06b40b42dfa3a55dc89cd94dd88a752a11da7caf4","ddl_sha256":"ece9899b4596a8b39e94dc4eba66a7b076d28c70b4396ca2858e6f32f803bc06","source_md5":"13ad2618307934e63c1ad96186957971"},{"oid":"39291","sig":"combat_v2_multitarget_internal.resolve_parent(uuid,uuid,uuid,boolean)","ddl_md5":"2cb3c3d30a1c058770ef611fb90dbd80","abi_sha256":"c1b8a8f6c14d497ab73ae0af11817352fcfd85333acf75c375aca5c3c8a2fee3","ddl_sha256":"1e8bb54c30de47ac9fc9f53a5dbac3a77beac008e16ccb87e5974a50a123d55a","source_md5":"9b278e6f9024b78be794aed4b23ca4ae"},{"oid":"21220","sig":"public._combat_calcola(text,jsonb,jsonb,text,text,integer,text,integer,integer,integer,integer,boolean)","ddl_md5":"935ca8c36a5f2f421e9fb5741bc3d275","abi_sha256":"048bcb6fabc8b438752b8d7594d75fb8b55419fc15f52559d8ce36f0b36b5786","ddl_sha256":"7db9cc7657d6b0478ccb6785259a2f4509ad3d6ea342151849ed973d9913836a","source_md5":"2d53fa8469f54a78a49013a1cdc11c7e"},{"oid":"42947","sig":"public.combat_consumer_narrative_claim_v1(uuid,text,uuid)","ddl_md5":"2c521aac41eeea3d0a843ff05c5b1e24","abi_sha256":"d865515821bea0cef6b0a4662529d1bf555dd93c1ab135a49380848722d9669e","ddl_sha256":"59348972dc171e7fba4b1d9d1c89925ec22562ca98a13e312d294231fadd0244","source_md5":"c144d4c43e22c5e3eb516e0d46ebf65a"},{"oid":"42969","sig":"public.combat_consumer_narrative_complete_v1(uuid,jsonb,uuid)","ddl_md5":"e56749f8d49bc345ebda55a833b0ae00","abi_sha256":"2f0857911ad4603cc525af47e1dba6bda7f615fee23b7e00458c2e3aef5495cc","ddl_sha256":"a5fe27c4cb29439eef68eef237148d2d8930d1cbe8ec05c8cb72197457a156b8","source_md5":"ca906d6285eee8a8617e0cb3db70f6f9"},{"oid":"31324","sig":"public.combat_v2_action_declare(uuid,uuid,jsonb,text,uuid)","ddl_md5":"91afc68d5d1419ed20d63b9c20fe14ea","abi_sha256":"b6d998780cb011e2dd2633261f88a73d72ccbfdf20aaa7ca950edceb4769816d","ddl_sha256":"28dcc3e75ea86866d828137d53172bd38ad3404559d23215d2486022410fce78","source_md5":"77f98c15d1778bd7cc5e6fdfe8d221b8"},{"oid":"31331","sig":"public.combat_v2_round_resolve(uuid,uuid)","ddl_md5":"d9d8438f3fc3bde3e799ee158055305f","abi_sha256":"cd417e11e00af72d6c1b0c5baa4d17feb4c2f4d70f1d8dd613830bf25dc7e29a","ddl_sha256":"5f3da77cefe6005202d48130ebea85a934dceed2fa5fab2b8e929ac5b545ca57","source_md5":"bbe708d2f06cb96681141fce45915c28"},{"oid":"41419","sig":"clan_innata_private.eligibility_release_assert()","ddl_md5":"c853342118edc3e2d886aef09661da1b","abi_sha256":"6196b3570f0cf7b8efd83fc1d688978688a292d4d11b0b9d1ff78241e0316d88","ddl_sha256":"d034de670fcf5ad17d3f4663fe209cda5ca3d85e1c8b86f1bff26fb938f002bb","source_md5":"d12a616a859cd2b497004d0f17395437"},{"oid":"701892","sig":"clan_innata_combat_private.velo_staff_scope_v1(uuid)","abi_sha256":"f14070f64af79a8b4bb0a3c3872b8f66ddb289f196413cae527098686a439c43","ddl_sha256":"419382199472a3b3af19a8c04ec0b450b040b7680d8cb864ba03ec5da9a55d67","source_md5":"3bb31269a7662aaf16169f76bccd6348"}]$sfera_pins$::jsonb)
  AS e(sig text,oid text,source_md5 text,ddl_sha256 text,abi_sha256 text)
  LEFT JOIN pg_proc p ON p.oid=to_regprocedure(e.sig) LEFT JOIN pg_language l ON l.oid=p.prolang
  WHERE p.oid::text IS DISTINCT FROM e.oid OR md5(p.prosrc) IS DISTINCT FROM e.source_md5
   OR encode(extensions.digest(pg_get_functiondef(p.oid),'sha256'),'hex') IS DISTINCT FROM e.ddl_sha256
   OR public.combat_v2_sha256(jsonb_build_object(
       'owner',pg_get_userbyid(p.proowner),'acl',p.proacl::text,'config',p.proconfig,'secdef',p.prosecdef,
       'volatile',p.provolatile::text,'strict',p.proisstrict,'parallel',p.proparallel::text,
       'kind',p.prokind::text,'returns',pg_get_function_result(p.oid),'args',p.proargtypes::text,
       'lang',l.lanname)) IS DISTINCT FROM e.abi_sha256)
 THEN RAISE EXCEPTION 'SFERA_BEFORE_BODY_OR_ABI_DRIFT'; END IF;

 
 SELECT * INTO STRICT prior_release FROM mission_public_owner.release_admissions_v1
  WHERE release_sha256=rr.revision_sha256 FOR SHARE;
 SELECT * INTO STRICT prior_qualification FROM mission_public_owner.public_qualification_attestations_v1
  WHERE release_sha256=rr.revision_sha256 FOR SHARE;
 SELECT to_jsonb(x) INTO STRICT runtime_before FROM mission_public_owner.party_launch_runtime_v1 x
  WHERE singleton FOR UPDATE;
 IF prior_release.edge_sha256 IS DISTINCT FROM generic_ezbr
  OR mission_public_owner.engine_qualification_v1(rr.revision_sha256,true) IS NULL OR public.combat_v2_sha256(mission_public_owner.engine_qualification_v1(rr.revision_sha256,true)) IS DISTINCT FROM '8ed070e196bc1bcb067f013658cb4693f4c36b19ba5651f8c4accb10dbabc8f2'
  OR public.combat_v2_sha256(prior_qualification.payload->'capabilities') IS DISTINCT FROM '49fe134f561273f28e8071b63c45886341371b67d028f06e6b7d8f8d4108e817'
  OR runtime_before IS DISTINCT FROM jsonb_set('{"singleton":true,"staff_enabled":true,"public_enabled":true,"release_sha256":"4aec6254673c4c076d313660659a11a0f0b502d434def8bd7a6e4a5c8776f479"}'::jsonb,'{release_sha256}',to_jsonb(rr.revision_sha256),false)
  OR (SELECT count(*) FROM mission_public_owner.mission_content_admissions_v1 c
      WHERE c.engine_release_sha256=rr.revision_sha256
       AND mission_public_owner.content_admission_v1(c.mission_id,rr.revision_sha256,c.publication_request,true) IS NOT NULL)<>2
  OR (SELECT count(DISTINCT profile_key) FROM mission_public_owner.engine_profile_events_v1
       WHERE engine_release_sha256=rr.revision_sha256)<>1
  
 OR public.combat_v2_sha256(to_jsonb(prior_release)) IS DISTINCT FROM '79362b858c82e8e270b9517e2c9e216e9671e7fcec0be7cf4608803347b2187b'
 OR public.combat_v2_sha256(to_jsonb(prior_qualification)) IS DISTINCT FROM 'bcbf34f55f3e970ca5635a8c2295a79003a5637110fd0a4c792c301f34392601'
 OR (SELECT public.combat_v2_sha256(jsonb_agg(to_jsonb(c) ORDER BY c.mission_id,c.request_key))
        FROM mission_public_owner.mission_content_admissions_v1 c WHERE c.engine_release_sha256=rr.revision_sha256)
       IS DISTINCT FROM 'c958745f0cece7f27a5fac82c3d10e3308e7e8e488e5c0940bb213e040148b38'
 OR (SELECT public.combat_v2_sha256(jsonb_agg(to_jsonb(e) ORDER BY e.profile_key))
        FROM (SELECT DISTINCT ON(z.profile_key) * FROM mission_public_owner.engine_profile_events_v1 z
        WHERE z.engine_release_sha256=rr.revision_sha256 ORDER BY z.profile_key,z.control_version DESC)e)
       IS DISTINCT FROM '78793e8f4ae3d98943729f7e0c1ce831cb087ded23fa41105f2b61ab64e728b4'

 THEN RAISE EXCEPTION 'SFERA_UNRELATED_MISSION_EVIDENCE_DRIFT';END IF;

 
WITH base AS MATERIALIZED (
 SELECT revision_sha256 AS old_sha,public.combat_v2_sha256(to_jsonb(r)) AS old_row_sha,
        canonical_preimage AS old_text,canonical_preimage::jsonb AS r
 FROM mission_factory_owner.editor_release_readiness r WHERE singleton
), edge AS (SELECT edge_receipt AS receipt)
, peer_rows AS (
 SELECT p.oid::regprocedure::text AS signature, jsonb_build_object(
  'signature',p.oid::regprocedure::text,'source_md5',md5(p.prosrc),'ddl_md5',md5(pg_get_functiondef(p.oid)),
  'owner',pg_get_userbyid(p.proowner),'secdef',p.prosecdef,'config',p.proconfig,'acl',p.proacl::text,'volatility',p.provolatile::text) AS record
 FROM pg_proc p WHERE p.oid IN ('combat_panel_private.round_options_authoritative(uuid,uuid)'::regprocedure,'public.combat_v2_substitution_options_v1(uuid)'::regprocedure,'public.combat_v2_substitution_round_offers_v1(uuid,uuid)'::regprocedure,'public.combat_v2_substitution_select_v1(uuid,uuid)'::regprocedure,'clan_innata_private.catalogo_eligibility_release_v1()'::regprocedure,'combat_panel_private.publish_master_declaration(uuid,text)'::regprocedure)
 ), peers AS (
 SELECT count(*) AS count,public.combat_v2_sha256(jsonb_agg(record ORDER BY signature)) AS live_sha,
        public.combat_v2_sha256(jsonb_agg(CASE WHEN signature='clan_innata_private.catalogo_eligibility_release_v1()'
          THEN record||jsonb_build_object('source_md5','c2c8daab17e15234ac98c4fa4414f404','ddl_md5','416c4a3c64364496eaee9b04edb648d3')
          ELSE record END ORDER BY signature)) AS next_sha
 FROM peer_rows)
, staged AS MATERIALIZED (
 SELECT base.*,edge.receipt,jsonb_set(jsonb_set(jsonb_set(jsonb_set(jsonb_set(jsonb_set(jsonb_set(jsonb_set(jsonb_set(jsonb_set(jsonb_set(jsonb_set(jsonb_set(jsonb_set(jsonb_set(jsonb_set(jsonb_set(jsonb_set(jsonb_set(jsonb_set(jsonb_set(jsonb_set(jsonb_set(jsonb_set(jsonb_set(jsonb_set(jsonb_set(r,'{config,catalogo_eligibility_compat,functions,0,source_md5}','"c2c8daab17e15234ac98c4fa4414f404"'::jsonb,false),'{config,catalogo_eligibility_compat,functions,0,ddl_md5}','"416c4a3c64364496eaee9b04edb648d3"'::jsonb,false),'{db_core,catalogo_eligibility_compat,functions,0,source_md5}','"c2c8daab17e15234ac98c4fa4414f404"'::jsonb,false),'{db_core,catalogo_eligibility_compat,functions,0,ddl_md5}','"416c4a3c64364496eaee9b04edb648d3"'::jsonb,false),'{db_core,combat_innata_functions,39291,source_md5}','"4f89aa40d49971d2a74c04b85cd70f09"'::jsonb,false),'{db_core,combat_innata_functions,39291,ddl_md5}','"0f1b28887b56ece0e48b3238b3fb92dd"'::jsonb,false),'{db_core,combat_innata_functions,21220,source_md5}','"ee8d530300ef54e597114c741b85fcbe"'::jsonb,false),'{db_core,combat_innata_functions,21220,ddl_md5}','"7c887ff1aecced55ee5f77aeba71c753"'::jsonb,false),'{db_core,combat_innata_functions,31331,source_md5}','"ea91dd6deeaf06dc059adadfaafd9e95"'::jsonb,false),'{db_core,combat_innata_functions,31331,ddl_md5}','"8a9ec59917bb8802f796cc125e9d1e06"'::jsonb,false),'{db_core,sfera_staff}','"dad3e133506bbce74401b53cec128e8aa58e6f14155f6601749fe5184b1dc1e9"'::jsonb,true),'{db_core,catalogo_eligibility_compat,shared_manifest_sha256}','"0d669a22ab8b24f685352555e569d55ff65b0de59be5a3fe4e8b9640c3b8672e"'::jsonb,false),'{db_core,catalogo_eligibility_compat,functions_manifest_sha256}',to_jsonb(public.combat_v2_sha256('[{"acl":"{postgres=X/postgres}","owner":"postgres","config":["search_path=\"\""],"secdef":true,"ddl_md5":"416c4a3c64364496eaee9b04edb648d3","signature":"clan_innata_private.catalogo_eligibility_release_v1()","source_md5":"c2c8daab17e15234ac98c4fa4414f404","volatility":"s"},{"acl":"{postgres=X/postgres}","owner":"postgres","config":["search_path=pg_catalog, public, clan_innata_private"],"secdef":true,"ddl_md5":"c853342118edc3e2d886aef09661da1b","signature":"clan_innata_private.eligibility_release_assert()","source_md5":"d12a616a859cd2b497004d0f17395437","volatility":"s"}]'::jsonb)),false),'{db_core,catalogo_eligibility_compat,helper_source_md5}','"c2c8daab17e15234ac98c4fa4414f404"'::jsonb,false),'{db_core,cure_command_amendment,helper_source_md5}','"c2c8daab17e15234ac98c4fa4414f404"'::jsonb,false),'{db_core,cure_command_amendment,shared_manifest_sha256}','"0d669a22ab8b24f685352555e569d55ff65b0de59be5a3fe4e8b9640c3b8672e"'::jsonb,false),'{db_core,cure_command_amendment,functions_manifest_sha256}',to_jsonb(peers.next_sha),false),'{config,sfera_staff}','"dad3e133506bbce74401b53cec128e8aa58e6f14155f6601749fe5184b1dc1e9"'::jsonb,true),'{config,catalogo_eligibility_compat,shared_manifest_sha256}','"0d669a22ab8b24f685352555e569d55ff65b0de59be5a3fe4e8b9640c3b8672e"'::jsonb,false),'{config,catalogo_eligibility_compat,functions_manifest_sha256}',to_jsonb(public.combat_v2_sha256('[{"acl":"{postgres=X/postgres}","owner":"postgres","config":["search_path=\"\""],"secdef":true,"ddl_md5":"416c4a3c64364496eaee9b04edb648d3","signature":"clan_innata_private.catalogo_eligibility_release_v1()","source_md5":"c2c8daab17e15234ac98c4fa4414f404","volatility":"s"},{"acl":"{postgres=X/postgres}","owner":"postgres","config":["search_path=pg_catalog, public, clan_innata_private"],"secdef":true,"ddl_md5":"c853342118edc3e2d886aef09661da1b","signature":"clan_innata_private.eligibility_release_assert()","source_md5":"d12a616a859cd2b497004d0f17395437","volatility":"s"}]'::jsonb)),false),'{config,catalogo_eligibility_compat,helper_source_md5}','"c2c8daab17e15234ac98c4fa4414f404"'::jsonb,false),'{config,cure_command_amendment,helper_source_md5}','"c2c8daab17e15234ac98c4fa4414f404"'::jsonb,false),'{config,cure_command_amendment,shared_manifest_sha256}','"0d669a22ab8b24f685352555e569d55ff65b0de59be5a3fe4e8b9640c3b8672e"'::jsonb,false),'{config,cure_command_amendment,functions_manifest_sha256}',to_jsonb(peers.next_sha),false),'{db_core,catalogo_families,2}','["5b8cc87dc91085b066f32e32ca70ca5d72d3643d337a6531777390e7749fc98d","e4c44135ccdfb770e155318ae6dbaf3d6e95c7550df5f4bcc5a0c38f60d25a77","2b38e6014a0723bb02cfcb37ba6b14fcbc609e5a5a428d8dd63e240e18926fc9"]'::jsonb,false),'{db_core,catalogo_families,3}','"cd22449d2aacf38bbf7b919678b58b256c4b89a47b6ccd16a69b6f3a75047bd9"'::jsonb,false),'{edge_bundles}',(SELECT jsonb_agg(CASE
       WHEN b.value->>'name'='combat_narratore_ai' THEN b.value||jsonb_build_object(
        'version',edge.receipt->'version','ezbr_sha256',edge.receipt->'ezbr_sha256',
        'deployment_receipt_sha256',edge.receipt->'deployment_receipt_sha256',
        'files',(SELECT jsonb_agg(CASE WHEN f.value->>'name'='facts.ts' THEN '{"name":"facts.ts","bytes":40051,"sha256":"cd22449d2aacf38bbf7b919678b58b256c4b89a47b6ccd16a69b6f3a75047bd9"}'::jsonb ELSE f.value END ORDER BY f.ord)
                FROM jsonb_array_elements(b.value->'files') WITH ORDINALITY f(value,ord)))
       ELSE b.value END ORDER BY b.ord) FROM jsonb_array_elements(r->'edge_bundles') WITH ORDINALITY b(value,ord)),false) AS patched,
    (old_sha='4aec6254673c4c076d313660659a11a0f0b502d434def8bd7a6e4a5c8776f479' AND old_row_sha='e882ccc872e5f04774aef7138ffddf2d7eba468351ecb5e859f16dec34bcd235' AND octet_length(old_text)=523908 AND r#>'{config,catalogo_eligibility_compat,functions,0,source_md5}' IS NOT DISTINCT FROM '"37778b193d749fe058330b67d53831c0"'::jsonb AND r#>'{config,catalogo_eligibility_compat,functions,0,ddl_md5}' IS NOT DISTINCT FROM '"41f45f4be9033482bf4be643e750ed47"'::jsonb AND r#>'{db_core,catalogo_eligibility_compat,functions,0,source_md5}' IS NOT DISTINCT FROM '"37778b193d749fe058330b67d53831c0"'::jsonb AND r#>'{db_core,catalogo_eligibility_compat,functions,0,ddl_md5}' IS NOT DISTINCT FROM '"41f45f4be9033482bf4be643e750ed47"'::jsonb AND r#>'{db_core,combat_innata_functions,39291,source_md5}' IS NOT DISTINCT FROM '"9b278e6f9024b78be794aed4b23ca4ae"'::jsonb AND r#>'{db_core,combat_innata_functions,39291,ddl_md5}' IS NOT DISTINCT FROM '"2cb3c3d30a1c058770ef611fb90dbd80"'::jsonb AND r#>'{db_core,combat_innata_functions,21220,source_md5}' IS NOT DISTINCT FROM '"2d53fa8469f54a78a49013a1cdc11c7e"'::jsonb AND r#>'{db_core,combat_innata_functions,21220,ddl_md5}' IS NOT DISTINCT FROM '"935ca8c36a5f2f421e9fb5741bc3d275"'::jsonb AND r#>'{db_core,combat_innata_functions,31331,source_md5}' IS NOT DISTINCT FROM '"bbe708d2f06cb96681141fce45915c28"'::jsonb AND r#>'{db_core,combat_innata_functions,31331,ddl_md5}' IS NOT DISTINCT FROM '"d9d8438f3fc3bde3e799ee158055305f"'::jsonb AND r#>'{db_core,sfera_staff}' IS NOT DISTINCT FROM NULL::jsonb AND r#>'{db_core,catalogo_eligibility_compat,shared_manifest_sha256}' IS NOT DISTINCT FROM '"855d79ed19465c764f88ef6bc92711c4be85fea660cd610402d71148471c6141"'::jsonb AND r#>'{db_core,catalogo_eligibility_compat,functions_manifest_sha256}' IS NOT DISTINCT FROM '"02d458ee5b8b604f067198e963028048b2387cffab160c9211ac0624aa3fa08b"'::jsonb AND r#>'{db_core,catalogo_eligibility_compat,helper_source_md5}' IS NOT DISTINCT FROM '"37778b193d749fe058330b67d53831c0"'::jsonb AND r#>'{db_core,cure_command_amendment,helper_source_md5}' IS NOT DISTINCT FROM '"37778b193d749fe058330b67d53831c0"'::jsonb AND r#>'{db_core,cure_command_amendment,shared_manifest_sha256}' IS NOT DISTINCT FROM '"855d79ed19465c764f88ef6bc92711c4be85fea660cd610402d71148471c6141"'::jsonb AND r#>'{db_core,cure_command_amendment,functions_manifest_sha256}' IS NOT DISTINCT FROM '"c7feb158a5ce521e36e3ee65c5cea6b82bcced564e5f7ff2bf298aa6d2833b27"'::jsonb AND r#>'{config,sfera_staff}' IS NOT DISTINCT FROM NULL::jsonb AND r#>'{config,catalogo_eligibility_compat,shared_manifest_sha256}' IS NOT DISTINCT FROM '"855d79ed19465c764f88ef6bc92711c4be85fea660cd610402d71148471c6141"'::jsonb AND r#>'{config,catalogo_eligibility_compat,functions_manifest_sha256}' IS NOT DISTINCT FROM '"02d458ee5b8b604f067198e963028048b2387cffab160c9211ac0624aa3fa08b"'::jsonb AND r#>'{config,catalogo_eligibility_compat,helper_source_md5}' IS NOT DISTINCT FROM '"37778b193d749fe058330b67d53831c0"'::jsonb AND r#>'{config,cure_command_amendment,helper_source_md5}' IS NOT DISTINCT FROM '"37778b193d749fe058330b67d53831c0"'::jsonb AND r#>'{config,cure_command_amendment,shared_manifest_sha256}' IS NOT DISTINCT FROM '"855d79ed19465c764f88ef6bc92711c4be85fea660cd610402d71148471c6141"'::jsonb AND r#>'{config,cure_command_amendment,functions_manifest_sha256}' IS NOT DISTINCT FROM '"c7feb158a5ce521e36e3ee65c5cea6b82bcced564e5f7ff2bf298aa6d2833b27"'::jsonb AND r#>'{db_core,catalogo_families,2}' IS NOT DISTINCT FROM '["5b8cc87dc91085b066f32e32ca70ca5d72d3643d337a6531777390e7749fc98d","6ec0fc7280f7bf5ff9fb6e40011701a9bfdd6829856fa51e1acd9c28af8d4496","2b38e6014a0723bb02cfcb37ba6b14fcbc609e5a5a428d8dd63e240e18926fc9"]'::jsonb AND r#>'{db_core,catalogo_families,3}' IS NOT DISTINCT FROM '"7c261e6fee5b1f608bb8bf4caccbf28e7f409eadd9e866165bbf65f27b9d411a"'::jsonb AND (SELECT value-'files' FROM jsonb_array_elements(r->'edge_bundles') WHERE value->>'name'='combat_narratore_ai')
                     IS NOT DISTINCT FROM '{"name":"combat_narratore_ai","status":"ACTIVE","version":46,"verify_jwt":false,"ezbr_sha256":"1bdcde5a74ae789c610e7469a7906a419bb363b189b58133939ebb91db6c1775","legacy_source_sha256":"7ee0ae0ecafcb6b595abea3687b494481c23b37bd8d8b5e4e2b306bc35360d4b","deployment_receipt_sha256":"c10374720b24f353130b88dc3c1452d5ed224c02d678addd3b42b71873abdf12"}'::jsonb
          AND (SELECT jsonb_agg(x ORDER BY x->>'name') FROM jsonb_array_elements(r->'edge_bundles') b
             CROSS JOIN LATERAL jsonb_array_elements(b->'files') x WHERE b->>'name'='combat_narratore_ai') IS NOT DISTINCT FROM '[{"name":"adattatore.ts","bytes":19495,"sha256":"32bf2b017f70f2b3733992d99ca868405a812c35f725c64cf66adb4f5ebc851d"},{"name":"common.mjs","bytes":8305,"sha256":"c73d6fa04bf22c521b502387adb261c599996e58f309ddb3b5a64dd3f56e6cc4"},{"name":"count.mjs","bytes":4494,"sha256":"77791e0fa712967ba7818dee45964af6e4cda1673e1f4673c0238ff387ee335f"},{"name":"diagnostics.ts","bytes":2964,"sha256":"5846012ec1d57cffa8a54b17dd7a3efe61a91971cdf2b97f8afe67220ebba5ce"},{"name":"editorial.mjs","bytes":7802,"sha256":"8d6c00b9ebc16bfff9f17c7e9670292397f266b24f4664d299c5a3e58d692766"},{"name":"facts.ts","bytes":36210,"sha256":"7c261e6fee5b1f608bb8bf4caccbf28e7f409eadd9e866165bbf65f27b9d411a"},{"name":"flow.mjs","bytes":5332,"sha256":"ceefabdb6bd9e3cfe7e85c31b4a3805f76fbf7dae11ab0ad51994e9deff7722d"},{"name":"index.ts","bytes":71473,"sha256":"c02e347b84556199dd883cb59e5057ff2803ff3da29d0c01e0899ba82fe6d2c3"},{"name":"lifecycle.mjs","bytes":7147,"sha256":"5f7299124083a5b57ce75e6fb0b917fb6cabba0a369a2d78649e31eb4ccb0d6c"},{"name":"orchestra.ts","bytes":1177,"sha256":"47134473ddf7153499f7ce6056b3f892af4166df86fd614cf94b4ff2d9ba4e0f"},{"name":"ordinary.ts","bytes":8946,"sha256":"456e734e9dd96858a44e5d86fb15d76acbff13a2727be64288fbff1601c9f502"},{"name":"recovery.ts","bytes":1081,"sha256":"dadcba58f18fac2aa6fba6f921a556c4653ddfa7eb6042feacd0c5e6dc554692"},{"name":"repertorio.json","bytes":14845,"sha256":"86b291f40f3baadb5fbe7e984e5f01e2fe910b7c645d1a77dd13a41970a4e37e"},{"name":"rinuncia.ts","bytes":3421,"sha256":"30832b9dd830dc32074fb5b96d6062811520cc73169d629e3c08f8dd1b00a421"},{"name":"runtime.ts","bytes":9292,"sha256":"c49dba1ff22b2d4d507b8e1a446319fd03f1ddd82cc1555494f6b638d991ec2e"},{"name":"scene.mjs","bytes":7517,"sha256":"f4cfa79821a27ac026960fde6460bd8562f8ec527698e3a3290004018d9d5301"},{"name":"transport.ts","bytes":4913,"sha256":"590d7e2e2d289d904ea1015049e0723236634dcce7c306ef651b125219f8ad1f"},{"name":"user_test.mjs","bytes":3238,"sha256":"26b1a843cd9470c173f4a0c0a259013cd08b58a3482b699fe7af5daec18be9ba"}]'::jsonb AND (peers.count=6 AND peers.live_sha='c7feb158a5ce521e36e3ee65c5cea6b82bcced564e5f7ff2bf298aa6d2833b27')) AS pins_ok,
    (SELECT coalesce(jsonb_agg(label ORDER BY label) FILTER(WHERE ok IS DISTINCT FROM true),'[]'::jsonb) FROM (VALUES ('{config,catalogo_eligibility_compat,functions,0,source_md5}'::text,r#>'{config,catalogo_eligibility_compat,functions,0,source_md5}' IS NOT DISTINCT FROM '"37778b193d749fe058330b67d53831c0"'::jsonb),('{config,catalogo_eligibility_compat,functions,0,ddl_md5}'::text,r#>'{config,catalogo_eligibility_compat,functions,0,ddl_md5}' IS NOT DISTINCT FROM '"41f45f4be9033482bf4be643e750ed47"'::jsonb),('{db_core,catalogo_eligibility_compat,functions,0,source_md5}'::text,r#>'{db_core,catalogo_eligibility_compat,functions,0,source_md5}' IS NOT DISTINCT FROM '"37778b193d749fe058330b67d53831c0"'::jsonb),('{db_core,catalogo_eligibility_compat,functions,0,ddl_md5}'::text,r#>'{db_core,catalogo_eligibility_compat,functions,0,ddl_md5}' IS NOT DISTINCT FROM '"41f45f4be9033482bf4be643e750ed47"'::jsonb),('{db_core,combat_innata_functions,39291,source_md5}'::text,r#>'{db_core,combat_innata_functions,39291,source_md5}' IS NOT DISTINCT FROM '"9b278e6f9024b78be794aed4b23ca4ae"'::jsonb),('{db_core,combat_innata_functions,39291,ddl_md5}'::text,r#>'{db_core,combat_innata_functions,39291,ddl_md5}' IS NOT DISTINCT FROM '"2cb3c3d30a1c058770ef611fb90dbd80"'::jsonb),('{db_core,combat_innata_functions,21220,source_md5}'::text,r#>'{db_core,combat_innata_functions,21220,source_md5}' IS NOT DISTINCT FROM '"2d53fa8469f54a78a49013a1cdc11c7e"'::jsonb),('{db_core,combat_innata_functions,21220,ddl_md5}'::text,r#>'{db_core,combat_innata_functions,21220,ddl_md5}' IS NOT DISTINCT FROM '"935ca8c36a5f2f421e9fb5741bc3d275"'::jsonb),('{db_core,combat_innata_functions,31331,source_md5}'::text,r#>'{db_core,combat_innata_functions,31331,source_md5}' IS NOT DISTINCT FROM '"bbe708d2f06cb96681141fce45915c28"'::jsonb),('{db_core,combat_innata_functions,31331,ddl_md5}'::text,r#>'{db_core,combat_innata_functions,31331,ddl_md5}' IS NOT DISTINCT FROM '"d9d8438f3fc3bde3e799ee158055305f"'::jsonb),('{db_core,sfera_staff}'::text,r#>'{db_core,sfera_staff}' IS NOT DISTINCT FROM NULL::jsonb),('{db_core,catalogo_eligibility_compat,shared_manifest_sha256}'::text,r#>'{db_core,catalogo_eligibility_compat,shared_manifest_sha256}' IS NOT DISTINCT FROM '"855d79ed19465c764f88ef6bc92711c4be85fea660cd610402d71148471c6141"'::jsonb),('{db_core,catalogo_eligibility_compat,functions_manifest_sha256}'::text,r#>'{db_core,catalogo_eligibility_compat,functions_manifest_sha256}' IS NOT DISTINCT FROM '"02d458ee5b8b604f067198e963028048b2387cffab160c9211ac0624aa3fa08b"'::jsonb),('{db_core,catalogo_eligibility_compat,helper_source_md5}'::text,r#>'{db_core,catalogo_eligibility_compat,helper_source_md5}' IS NOT DISTINCT FROM '"37778b193d749fe058330b67d53831c0"'::jsonb),('{db_core,cure_command_amendment,helper_source_md5}'::text,r#>'{db_core,cure_command_amendment,helper_source_md5}' IS NOT DISTINCT FROM '"37778b193d749fe058330b67d53831c0"'::jsonb),('{db_core,cure_command_amendment,shared_manifest_sha256}'::text,r#>'{db_core,cure_command_amendment,shared_manifest_sha256}' IS NOT DISTINCT FROM '"855d79ed19465c764f88ef6bc92711c4be85fea660cd610402d71148471c6141"'::jsonb),('{db_core,cure_command_amendment,functions_manifest_sha256}'::text,r#>'{db_core,cure_command_amendment,functions_manifest_sha256}' IS NOT DISTINCT FROM '"c7feb158a5ce521e36e3ee65c5cea6b82bcced564e5f7ff2bf298aa6d2833b27"'::jsonb),('{config,sfera_staff}'::text,r#>'{config,sfera_staff}' IS NOT DISTINCT FROM NULL::jsonb),('{config,catalogo_eligibility_compat,shared_manifest_sha256}'::text,r#>'{config,catalogo_eligibility_compat,shared_manifest_sha256}' IS NOT DISTINCT FROM '"855d79ed19465c764f88ef6bc92711c4be85fea660cd610402d71148471c6141"'::jsonb),('{config,catalogo_eligibility_compat,functions_manifest_sha256}'::text,r#>'{config,catalogo_eligibility_compat,functions_manifest_sha256}' IS NOT DISTINCT FROM '"02d458ee5b8b604f067198e963028048b2387cffab160c9211ac0624aa3fa08b"'::jsonb),('{config,catalogo_eligibility_compat,helper_source_md5}'::text,r#>'{config,catalogo_eligibility_compat,helper_source_md5}' IS NOT DISTINCT FROM '"37778b193d749fe058330b67d53831c0"'::jsonb),('{config,cure_command_amendment,helper_source_md5}'::text,r#>'{config,cure_command_amendment,helper_source_md5}' IS NOT DISTINCT FROM '"37778b193d749fe058330b67d53831c0"'::jsonb),('{config,cure_command_amendment,shared_manifest_sha256}'::text,r#>'{config,cure_command_amendment,shared_manifest_sha256}' IS NOT DISTINCT FROM '"855d79ed19465c764f88ef6bc92711c4be85fea660cd610402d71148471c6141"'::jsonb),('{config,cure_command_amendment,functions_manifest_sha256}'::text,r#>'{config,cure_command_amendment,functions_manifest_sha256}' IS NOT DISTINCT FROM '"c7feb158a5ce521e36e3ee65c5cea6b82bcced564e5f7ff2bf298aa6d2833b27"'::jsonb),('{db_core,catalogo_families,2}'::text,r#>'{db_core,catalogo_families,2}' IS NOT DISTINCT FROM '["5b8cc87dc91085b066f32e32ca70ca5d72d3643d337a6531777390e7749fc98d","6ec0fc7280f7bf5ff9fb6e40011701a9bfdd6829856fa51e1acd9c28af8d4496","2b38e6014a0723bb02cfcb37ba6b14fcbc609e5a5a428d8dd63e240e18926fc9"]'::jsonb),('{db_core,catalogo_families,3}'::text,r#>'{db_core,catalogo_families,3}' IS NOT DISTINCT FROM '"7c261e6fee5b1f608bb8bf4caccbf28e7f409eadd9e866165bbf65f27b9d411a"'::jsonb)) g(label,ok)) AS failed_paths, ((SELECT value-'files' FROM jsonb_array_elements(r->'edge_bundles') WHERE value->>'name'='combat_narratore_ai')
                     IS NOT DISTINCT FROM '{"name":"combat_narratore_ai","status":"ACTIVE","version":46,"verify_jwt":false,"ezbr_sha256":"1bdcde5a74ae789c610e7469a7906a419bb363b189b58133939ebb91db6c1775","legacy_source_sha256":"7ee0ae0ecafcb6b595abea3687b494481c23b37bd8d8b5e4e2b306bc35360d4b","deployment_receipt_sha256":"c10374720b24f353130b88dc3c1452d5ed224c02d678addd3b42b71873abdf12"}'::jsonb
          AND (SELECT jsonb_agg(x ORDER BY x->>'name') FROM jsonb_array_elements(r->'edge_bundles') b
             CROSS JOIN LATERAL jsonb_array_elements(b->'files') x WHERE b->>'name'='combat_narratore_ai') IS NOT DISTINCT FROM '[{"name":"adattatore.ts","bytes":19495,"sha256":"32bf2b017f70f2b3733992d99ca868405a812c35f725c64cf66adb4f5ebc851d"},{"name":"common.mjs","bytes":8305,"sha256":"c73d6fa04bf22c521b502387adb261c599996e58f309ddb3b5a64dd3f56e6cc4"},{"name":"count.mjs","bytes":4494,"sha256":"77791e0fa712967ba7818dee45964af6e4cda1673e1f4673c0238ff387ee335f"},{"name":"diagnostics.ts","bytes":2964,"sha256":"5846012ec1d57cffa8a54b17dd7a3efe61a91971cdf2b97f8afe67220ebba5ce"},{"name":"editorial.mjs","bytes":7802,"sha256":"8d6c00b9ebc16bfff9f17c7e9670292397f266b24f4664d299c5a3e58d692766"},{"name":"facts.ts","bytes":36210,"sha256":"7c261e6fee5b1f608bb8bf4caccbf28e7f409eadd9e866165bbf65f27b9d411a"},{"name":"flow.mjs","bytes":5332,"sha256":"ceefabdb6bd9e3cfe7e85c31b4a3805f76fbf7dae11ab0ad51994e9deff7722d"},{"name":"index.ts","bytes":71473,"sha256":"c02e347b84556199dd883cb59e5057ff2803ff3da29d0c01e0899ba82fe6d2c3"},{"name":"lifecycle.mjs","bytes":7147,"sha256":"5f7299124083a5b57ce75e6fb0b917fb6cabba0a369a2d78649e31eb4ccb0d6c"},{"name":"orchestra.ts","bytes":1177,"sha256":"47134473ddf7153499f7ce6056b3f892af4166df86fd614cf94b4ff2d9ba4e0f"},{"name":"ordinary.ts","bytes":8946,"sha256":"456e734e9dd96858a44e5d86fb15d76acbff13a2727be64288fbff1601c9f502"},{"name":"recovery.ts","bytes":1081,"sha256":"dadcba58f18fac2aa6fba6f921a556c4653ddfa7eb6042feacd0c5e6dc554692"},{"name":"repertorio.json","bytes":14845,"sha256":"86b291f40f3baadb5fbe7e984e5f01e2fe910b7c645d1a77dd13a41970a4e37e"},{"name":"rinuncia.ts","bytes":3421,"sha256":"30832b9dd830dc32074fb5b96d6062811520cc73169d629e3c08f8dd1b00a421"},{"name":"runtime.ts","bytes":9292,"sha256":"c49dba1ff22b2d4d507b8e1a446319fd03f1ddd82cc1555494f6b638d991ec2e"},{"name":"scene.mjs","bytes":7517,"sha256":"f4cfa79821a27ac026960fde6460bd8562f8ec527698e3a3290004018d9d5301"},{"name":"transport.ts","bytes":4913,"sha256":"590d7e2e2d289d904ea1015049e0723236634dcce7c306ef651b125219f8ad1f"},{"name":"user_test.mjs","bytes":3238,"sha256":"26b1a843cd9470c173f4a0c0a259013cd08b58a3482b699fe7af5daec18be9ba"}]'::jsonb) AS edge_pins_ok, ((peers.count=6 AND peers.live_sha='c7feb158a5ce521e36e3ee65c5cea6b82bcced564e5f7ff2bf298aa6d2833b27')) AS peer_pins_ok, (old_sha='4aec6254673c4c076d313660659a11a0f0b502d434def8bd7a6e4a5c8776f479' AND old_row_sha='e882ccc872e5f04774aef7138ffddf2d7eba468351ecb5e859f16dec34bcd235' AND octet_length(old_text)=523908) AS parent_pins_ok
 FROM base CROSS JOIN edge CROSS JOIN peers
), families AS MATERIALIZED (
 SELECT *,jsonb_set(patched,'{config,catalogo_families}',to_jsonb(public.combat_v2_sha256(patched#>'{db_core,catalogo_families}')),false) AS c
 FROM staged
), hashing AS MATERIALIZED (
 SELECT *,public.combat_v2_sha256((c->'db_core')-'sha256') AS projected_db_sha,
       public.combat_v2_sha256((c->'config')-'sha256') AS projected_config_sha
 FROM families
), identity AS MATERIALIZED (
 SELECT *,public.combat_v2_sha256(jsonb_build_object('version','sfera-staff/1','mode','staff',
      'parent',old_sha,'previous_identity',r#>'{contract,code_identity_sha256}',
      'leaf','dad3e133506bbce74401b53cec128e8aa58e6f14155f6601749fe5184b1dc1e9','db',projected_db_sha,'config',projected_config_sha,'edge',receipt->'ezbr_sha256')) AS identity_sha
 FROM hashing
), formatted AS MATERIALIZED (
 SELECT *,jsonb_set(jsonb_set(jsonb_set(jsonb_set(c,'{db_core,sha256}',to_jsonb(projected_db_sha),false),
   '{config,sha256}',to_jsonb(projected_config_sha),false),'{contract,code_identity_sha256}',to_jsonb(identity_sha),false),
   '{recovery,semantic_identity_sha256}',to_jsonb(identity_sha),false) AS root_document
 FROM identity
), serialized AS (
 SELECT *,regexp_replace(root_document::text,$rx$("(?:[^"\\]|\\.)*")|[[:space:]]+$rx$,$b$\1$b$,'g') AS candidate_text FROM formatted
)

 SELECT candidate_text,s.root_document,s.projected_db_sha,s.projected_config_sha
 INTO STRICT root_text,candidate_root,db_sha,config_sha FROM serialized s
 WHERE pins_ok IS TRUE AND candidate_text::jsonb=s.root_document
   AND octet_length(candidate_text)<=524288 AND r->'ui'=s.root_document->'ui'
   AND r#>'{db_core,velo_staff}'=s.root_document#>'{db_core,velo_staff}';
 PERFORM set_config('app.sfera_prepared_root',root_text,true);
 PERFORM set_config('app.sfera_review',review::text,true);
END;
$sfera_pre$;
-- SOLE SORGENTI per composizione del PM. Nessuna Entry rilasciabile. Gate Staff spento.
-- Componente Staff riservato e inerte, da comporre con binder, clock e Fato.
CREATE TABLE clan_aburame_private.sfera_staff_gate_v1 (
    singleton boolean PRIMARY KEY CHECK (singleton),
    enabled boolean NOT NULL DEFAULT false
);
INSERT INTO clan_aburame_private.sfera_staff_gate_v1(singleton) VALUES (true);

CREATE TABLE clan_aburame_private.sfera_sources_v1 (
    declaration_id uuid PRIMARY KEY REFERENCES public.combat_v2_declarations(id),
    request_key uuid NOT NULL,
    session_id uuid NOT NULL REFERENCES public.combat_v2_sessions(id),
    round_id uuid NOT NULL REFERENCES public.combat_v2_rounds(id),
    initial_turn_id uuid NOT NULL,
    actor_id uuid NOT NULL REFERENCES public.combat_v2_actors(id),
    target_actor_id uuid NOT NULL REFERENCES public.combat_v2_actors(id),
    owner_character_id uuid NOT NULL REFERENCES public.characters(id),
    owner_controller_version bigint NOT NULL,
    target_controller_version bigint NOT NULL,
    power integer NOT NULL CHECK (power > 0),
    private_ability_sha256 text NOT NULL CHECK (private_ability_sha256 ~ '^[a-f0-9]{64}$'),
    state text NOT NULL CHECK (state IN ('reserved', 'active', 'ended')),
    initial_facts jsonb,
    ended_reason text,
    ended_at timestamptz,
    CHECK (actor_id <> target_actor_id),
    CHECK ((state = 'ended') = (ended_reason IS NOT NULL AND ended_at IS NOT NULL))
);

CREATE UNIQUE INDEX sfera_active_source_per_actor_v1
    ON clan_aburame_private.sfera_sources_v1(session_id, actor_id)
    WHERE state IN ('reserved', 'active');

CREATE TABLE clan_aburame_private.sfera_upkeep_v1 (
    declaration_id uuid NOT NULL REFERENCES clan_aburame_private.sfera_sources_v1(declaration_id),
    turn_id uuid NOT NULL,
    round_id uuid NOT NULL REFERENCES public.combat_v2_rounds(id),
    facts jsonb NOT NULL,
    PRIMARY KEY (declaration_id, turn_id)
);

ALTER TABLE clan_aburame_private.sfera_staff_gate_v1 ENABLE ROW LEVEL SECURITY;
ALTER TABLE clan_aburame_private.sfera_sources_v1 ENABLE ROW LEVEL SECURITY;
ALTER TABLE clan_aburame_private.sfera_upkeep_v1 ENABLE ROW LEVEL SECURITY;
REVOKE ALL ON clan_aburame_private.sfera_staff_gate_v1, clan_aburame_private.sfera_sources_v1,
    clan_aburame_private.sfera_upkeep_v1 FROM PUBLIC, anon, authenticated, service_role;

CREATE FUNCTION clan_aburame_private.sfera_staff_scope_v1(p_session uuid, p_actor uuid, p_target uuid)
RETURNS boolean LANGUAGE sql STABLE SECURITY DEFINER SET search_path = '' AS $$
    SELECT EXISTS(SELECT 1 FROM clan_aburame_private.sfera_staff_gate_v1 WHERE singleton AND enabled)
       AND p_actor IS DISTINCT FROM p_target
       AND combat_panel_private.nara_adv_pool_v1(p_session)
       AND combat_panel_private.cure_staff_execution_scope_v1(p_actor)
       AND combat_panel_private.cure_staff_execution_scope_v1(p_target)
       AND EXISTS (
           SELECT 1 FROM public.combat_v2_actors a JOIN public.combat_v2_actors t ON t.session_id = a.session_id
           WHERE a.session_id = p_session AND a.id = p_actor AND t.id = p_target
               AND a.state = 'attivo' AND t.state = 'attivo' AND a.team_key <> t.team_key
       );
$$;

-- Due arene Staff note, con i soli tronchetti nativi non impervi.
-- La semantica di una barriera sigillata è responsabilità del producer spaziale.
CREATE FUNCTION clan_aburame_private.sfera_clear_arena_distance_v1(
    p_session uuid, p_actor uuid, p_target uuid
) RETURNS numeric LANGUAGE sql STABLE SECURITY DEFINER SET search_path = '' AS $$
    SELECT combat_spatial.distance_m(a.x_m, a.y_m, t.x_m, t.y_m)
    FROM combat_spatial.arena_instances i
    JOIN combat_spatial.actor_states a ON a.instance_id = i.instance_id AND a.actor_id = p_actor AND a.state = 'active'
    JOIN combat_spatial.actor_states t ON t.instance_id = i.instance_id AND t.actor_id = p_target AND t.state = 'active'
    WHERE i.encounter_id = p_session AND i.state = 'open'
      AND (i.context_source, i.template_key) IN (('ordinary','ordinary_neutral_v1'),('panel_master','master_test_20x20_v1'))
      AND NOT EXISTS (
          SELECT 1 FROM combat_spatial.object_states os
          LEFT JOIN combat_spatial.arena_objects native_object
            ON native_object.template_key = i.template_key
              AND native_object.template_version = i.template_version AND native_object.object_key = os.object_key
          WHERE os.instance_id = i.instance_id AND os.state NOT IN ('destroyed', 'consumed')
            AND NOT coalesce(native_object.object_kind = 'substitution_anchor'
                AND native_object.object_key IN ('LOG-A','LOG-B')
                AND native_object.geometry_version = 1 AND NOT native_object.is_impervious, false)
      );
$$;

CREATE FUNCTION clan_aburame_private.sfera_end_v1(p_declaration uuid, p_reason text)
RETURNS void LANGUAGE plpgsql SECURITY DEFINER SET search_path = '' AS $$
DECLARE
    v_source clan_aburame_private.sfera_sources_v1%ROWTYPE;
BEGIN
    SELECT * INTO v_source FROM clan_aburame_private.sfera_sources_v1
    WHERE declaration_id = p_declaration;
    IF NOT FOUND OR v_source.state = 'ended' THEN RETURN; END IF;
    -- La chiusura ammessa anche dopo annullamento libera solo la quota simulata.
    PERFORM 1 FROM public.combat_v2_sessions WHERE id = v_source.session_id FOR UPDATE;
    SELECT * INTO STRICT v_source FROM clan_aburame_private.sfera_sources_v1
    WHERE declaration_id = p_declaration FOR UPDATE;
    IF v_source.state = 'ended' THEN RETURN; END IF;
    IF p_reason IS NULL OR p_reason NOT IN (
        'miss', 'target_depleted', 'source_invalid', 'distance', 'insufficient_chakra',
        'escaped', 'actor_left', 'combat_end', 'unsupported_geometry'
    ) THEN RAISE EXCEPTION 'aburame_sfera_end_reason_invalid'; END IF;

    PERFORM clan_aburame_private.colony_transition(
        v_source.owner_character_id, v_source.session_id, 'simulation',
        'release', v_source.declaration_id, 1, v_source.declaration_id, 0, NULL
    );
    UPDATE clan_aburame_private.sfera_sources_v1
    SET state = 'ended', ended_reason = p_reason, ended_at = transaction_timestamp()
    WHERE declaration_id = p_declaration;
END;
$$;

-- Invocazione dal resolver nativo dopo il freeze e prima del costo. Il contratto server
-- è costruito a monte dai consumer nativi e non può provenire dal client.
CREATE FUNCTION clan_aburame_private.sfera_reserve_v1(p_declaration uuid)
RETURNS void LANGUAGE plpgsql SECURITY DEFINER SET search_path = '' AS $$
DECLARE
    v_d public.combat_v2_declarations%ROWTYPE;
    v_round public.combat_v2_rounds%ROWTYPE;
    v_owner public.combat_v2_actors%ROWTYPE;
    v_target public.combat_v2_actors%ROWTYPE;
    v_existing clan_aburame_private.sfera_sources_v1%ROWTYPE;
    v_ability jsonb;
    v_turn uuid;
    v_distance numeric;
    v_power integer;
BEGIN
    SELECT * INTO STRICT v_d FROM public.combat_v2_declarations WHERE id = p_declaration;
    v_ability := v_d.sanitized_intent->'server_ability';
    IF v_ability->>'aburame_sfera_version' IS DISTINCT FROM 'aburame-sfera/1' THEN RETURN; END IF;
    SELECT * INTO STRICT v_round FROM public.combat_v2_rounds WHERE id = v_d.round_id;
    PERFORM combat_effects_private.lock_context(v_round.session_id);
    PERFORM 1 FROM public.combat_v2_actors
    WHERE session_id = v_round.session_id AND id IN (v_d.actor_id, v_d.target_actor_id)
    ORDER BY id FOR UPDATE;

    SELECT * INTO STRICT v_owner FROM public.combat_v2_actors
    WHERE id = v_d.actor_id AND session_id = v_round.session_id;
    SELECT * INTO STRICT v_target FROM public.combat_v2_actors
    WHERE id = v_d.target_actor_id AND session_id = v_round.session_id;
    v_power := (v_ability->>'power')::integer;
    IF v_d.kind <> 'attacco' OR v_d.frozen_at IS NULL OR v_round.phase IS DISTINCT FROM 'congelato'
       OR v_d.sanitized_intent->>'ability_source' IS DISTINCT FROM 'clan'
       OR v_d.sanitized_intent->>'ability_id' IS DISTINCT FROM '07a93dee-a483-4a7b-b3e0-43146c2ce227'
       OR v_d.cost_snapshot->'chakra' IS DISTINCT FROM '20'::jsonb
       OR v_d.cost_snapshot->'damage_base' IS DISTINCT FROM '0'::jsonb
       OR v_power IS NULL OR v_power <= 0
       OR v_d.controller_user_snapshot IS DISTINCT FROM
           exam_regia_private.actor_principal(v_owner.id, v_owner.controller_user)
       OR v_d.controller_version_snapshot IS DISTINCT FROM v_owner.controller_version
       OR NOT clan_aburame_private.sfera_staff_scope_v1(v_round.session_id, v_owner.id, v_target.id)
       OR (SELECT count(*) FROM public.combat_v2_attack_targets WHERE attack_declaration_id = v_d.id) <> 1
       OR NOT EXISTS (
           SELECT 1 FROM public.combat_v2_attack_targets WHERE attack_declaration_id = v_d.id
              AND target_actor_id = v_target.id AND target_controller_version = v_target.controller_version
       ) THEN RAISE EXCEPTION 'aburame_sfera_frozen_source_invalid'; END IF;

    SELECT * INTO v_existing FROM clan_aburame_private.sfera_sources_v1 WHERE declaration_id = p_declaration;
    IF FOUND THEN
        IF v_existing.request_key IS DISTINCT FROM v_d.request_key
           OR v_existing.power IS DISTINCT FROM v_power
           OR v_existing.private_ability_sha256 IS DISTINCT FROM public.combat_v2_sha256(v_ability)
           OR v_existing.actor_id IS DISTINCT FROM v_owner.id
           OR v_existing.target_actor_id IS DISTINCT FROM v_target.id THEN
            RAISE EXCEPTION 'aburame_sfera_replay_conflict';
        END IF;
        RETURN;
    END IF;

    v_distance := clan_aburame_private.sfera_clear_arena_distance_v1(v_round.session_id, v_owner.id, v_target.id);
    IF v_distance IS NULL OR v_distance > 10
       OR EXISTS (
           SELECT 1 FROM clan_aburame_private.combat_sources
           WHERE session_id = v_round.session_id AND owner_actor_id = v_owner.id
               AND target_actor_id = v_target.id AND source_kind = 'release' AND state IN ('prepared','attached')
       ) THEN RAISE EXCEPTION 'aburame_sfera_geometry_or_coexistence'; END IF;

    v_turn := (combat_effects_private.personal_turn(v_round.session_id, v_owner.id)->>'turn_id')::uuid;
    IF v_turn IS NULL THEN RAISE EXCEPTION 'aburame_sfera_native_turn_required'; END IF;
    PERFORM clan_aburame_private.colony_transition(
        v_owner.character_id, v_round.session_id, 'simulation',
        'allocate', v_d.request_key, 0, v_d.id, 15, NULL
    );
    INSERT INTO clan_aburame_private.sfera_sources_v1 (
        declaration_id, request_key, session_id, round_id, initial_turn_id, actor_id,
        target_actor_id, owner_character_id, owner_controller_version, target_controller_version, power, private_ability_sha256, state
    ) VALUES (
        v_d.id, v_d.request_key, v_round.session_id, v_d.round_id, v_turn, v_owner.id,
        v_target.id, v_owner.character_id, v_owner.controller_version, v_target.controller_version,
        v_power, public.combat_v2_sha256(v_ability), 'reserved'
    );
END;
$$;

-- Il resolver fornisce l'esito pieno dopo negazioni e confronto, nella stessa transazione.
CREATE FUNCTION clan_aburame_private.sfera_finish_v1(
    p_declaration uuid, p_target uuid, p_native_full boolean
) RETURNS jsonb LANGUAGE plpgsql SECURITY DEFINER SET search_path = '' AS $$
DECLARE
    v_source clan_aburame_private.sfera_sources_v1%ROWTYPE;
    v_target public.combat_v2_actors%ROWTYPE;
    v_before integer;
    v_drain integer := 0;
    v_facts jsonb;
    v_applied boolean := false;
BEGIN
    SELECT * INTO v_source FROM clan_aburame_private.sfera_sources_v1
    WHERE declaration_id = p_declaration;
    IF NOT FOUND THEN RETURN NULL; END IF;
    PERFORM combat_effects_private.lock_context(v_source.session_id);
    SELECT * INTO STRICT v_source FROM clan_aburame_private.sfera_sources_v1
    WHERE declaration_id = p_declaration FOR UPDATE;

    IF p_target IS DISTINCT FROM v_source.target_actor_id OR p_native_full IS NULL
       OR NOT EXISTS (SELECT 1 FROM public.combat_v2_rounds WHERE id = v_source.round_id AND phase = 'risoluzione')
       OR NOT clan_aburame_private.sfera_staff_scope_v1(v_source.session_id, v_source.actor_id, p_target)
    THEN RAISE EXCEPTION 'aburame_sfera_result_scope_invalid'; END IF;
    IF v_source.initial_facts IS NOT NULL THEN
        IF v_source.initial_facts->'native_full' IS DISTINCT FROM to_jsonb(p_native_full)
        THEN RAISE EXCEPTION 'aburame_sfera_result_replay_conflict'; END IF;
        RETURN v_source.initial_facts;
    END IF;
    IF v_source.state <> 'reserved' THEN RAISE EXCEPTION 'aburame_sfera_reservation_required'; END IF;

    SELECT * INTO STRICT v_target FROM public.combat_v2_actors
    WHERE id = p_target AND session_id = v_source.session_id FOR UPDATE;
    IF v_target.controller_version IS DISTINCT FROM v_source.target_controller_version
       OR NOT EXISTS (
           SELECT 1 FROM public.combat_v2_actors a WHERE a.id = v_source.actor_id
              AND a.session_id = v_source.session_id AND a.controller_version = v_source.owner_controller_version
       ) THEN RAISE EXCEPTION 'aburame_sfera_frozen_actor_changed'; END IF;
    v_before := (v_target.mechanics_snapshot->>'chakra')::integer;
    IF v_before IS NULL OR v_before < 0 THEN RAISE EXCEPTION 'aburame_sfera_chakra_snapshot_invalid'; END IF;

    IF p_native_full THEN
        v_drain := least(10, v_before);
        UPDATE public.combat_v2_actors
        SET mechanics_snapshot = jsonb_set(mechanics_snapshot, '{chakra}', to_jsonb(v_before - v_drain), false)
        WHERE id = v_target.id;
        IF v_before > v_drain THEN
            UPDATE clan_aburame_private.sfera_sources_v1 SET state = 'active'
            WHERE declaration_id = p_declaration;
            v_applied := true;
        ELSE
            PERFORM clan_aburame_private.sfera_end_v1(p_declaration, 'target_depleted');
        END IF;
    ELSE
        PERFORM clan_aburame_private.sfera_end_v1(p_declaration, 'miss');
    END IF;

    v_facts := jsonb_build_object(
        'version', 'aburame-sfera/1', 'source_declaration_id', p_declaration,
        'target_actor_id', p_target, 'native_full', p_native_full, 'prison_active', v_applied,
        'power', v_source.power, 'chakra_drained', v_drain, 'damage_after', 0
    );
    UPDATE clan_aburame_private.sfera_sources_v1 SET initial_facts = v_facts
    WHERE declaration_id = p_declaration;
    RETURN v_facts;
END;
$$;

CREATE FUNCTION clan_aburame_private.sfera_upkeep_turn_v1(p_session uuid, p_actor uuid)
RETURNS void LANGUAGE plpgsql SECURITY DEFINER SET search_path = '' AS $$
DECLARE
    v_source clan_aburame_private.sfera_sources_v1%ROWTYPE;
    v_owner public.combat_v2_actors%ROWTYPE;
    v_target public.combat_v2_actors%ROWTYPE;
    v_turn jsonb;
    v_turn_id uuid;
    v_round_id uuid;
    v_distance numeric;
    v_owner_chakra integer;
    v_target_chakra integer;
    v_paid integer := 0;
    v_drained integer := 0;
    v_reason text;
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM clan_aburame_private.sfera_sources_v1
        WHERE session_id = p_session AND actor_id = p_actor AND state = 'active'
    ) THEN RETURN; END IF;
    PERFORM combat_effects_private.lock_context(p_session);
    SELECT * INTO v_source FROM clan_aburame_private.sfera_sources_v1
    WHERE session_id = p_session AND actor_id = p_actor AND state = 'active' FOR UPDATE;
    IF NOT FOUND THEN RETURN; END IF;

    v_turn := combat_effects_private.personal_turn(p_session, p_actor);
    v_turn_id := (v_turn->>'turn_id')::uuid;
    v_round_id := (v_turn->>'round_id')::uuid;
    IF v_turn_id IS NULL OR v_round_id IS NULL OR v_turn->>'useful' IS DISTINCT FROM 'true'
       OR v_turn->>'is_current' IS DISTINCT FROM 'true' OR v_turn->>'phase' IS DISTINCT FROM 'action'
       OR (v_turn->>'adapter' = 'master_v2'
           AND NOT combat_panel_private.human_duel_turn_allowed(v_round_id, p_actor))
       OR v_turn_id = v_source.initial_turn_id
       OR EXISTS (
           SELECT 1 FROM clan_aburame_private.sfera_upkeep_v1
           WHERE declaration_id = v_source.declaration_id AND turn_id = v_turn_id
       ) THEN RETURN; END IF;

    PERFORM 1 FROM public.combat_v2_actors
    WHERE session_id = p_session AND id IN (v_source.actor_id, v_source.target_actor_id)
    ORDER BY id FOR UPDATE;
    SELECT * INTO STRICT v_owner FROM public.combat_v2_actors WHERE id = v_source.actor_id;
    SELECT * INTO STRICT v_target FROM public.combat_v2_actors WHERE id = v_source.target_actor_id;
    v_owner_chakra := (v_owner.mechanics_snapshot->>'chakra')::integer;
    v_target_chakra := (v_target.mechanics_snapshot->>'chakra')::integer;
    IF v_owner_chakra IS NULL OR v_target_chakra IS NULL OR v_owner_chakra < 0 OR v_target_chakra < 0
    THEN RAISE EXCEPTION 'aburame_sfera_chakra_snapshot_invalid'; END IF;

    v_distance := clan_aburame_private.sfera_clear_arena_distance_v1(p_session, v_owner.id, v_target.id);
    IF NOT clan_aburame_private.sfera_staff_scope_v1(p_session, v_owner.id, v_target.id)
       OR v_owner.controller_version IS DISTINCT FROM v_source.owner_controller_version
       OR v_target.controller_version IS DISTINCT FROM v_source.target_controller_version
    THEN v_reason := 'source_invalid';
    ELSIF v_target_chakra = 0 THEN v_reason := 'target_depleted';
    ELSIF v_distance IS NULL THEN v_reason := 'unsupported_geometry';
    ELSIF v_distance > 15 THEN v_reason := 'distance';
    ELSIF v_owner_chakra < 10 THEN v_reason := 'insufficient_chakra';
    ELSE
        v_paid := 10;
        v_drained := least(10, v_target_chakra);
        UPDATE public.combat_v2_actors
        SET mechanics_snapshot = jsonb_set(mechanics_snapshot, '{chakra}', to_jsonb(v_owner_chakra - v_paid), false)
        WHERE id = v_owner.id;
        UPDATE public.combat_v2_actors
        SET mechanics_snapshot = jsonb_set(mechanics_snapshot, '{chakra}', to_jsonb(v_target_chakra - v_drained), false)
        WHERE id = v_target.id;
        IF v_target_chakra = v_drained THEN v_reason := 'target_depleted'; END IF;
    END IF;
    IF v_reason IS NOT NULL THEN PERFORM clan_aburame_private.sfera_end_v1(v_source.declaration_id, v_reason); END IF;

    INSERT INTO clan_aburame_private.sfera_upkeep_v1 (declaration_id, turn_id, round_id, facts)
    VALUES (v_source.declaration_id, v_turn_id, v_round_id, jsonb_build_object(
        'version', 'aburame-sfera-upkeep/1', 'source_declaration_id', v_source.declaration_id,
        'target_actor_id', v_target.id, 'chakra_paid', v_paid,
        'chakra_drained', v_drained, 'prison_active', v_reason IS NULL, 'end_reason', v_reason
    ));
END;
$$;

-- Queste proiezioni si usano solo nei consumer server di movimento e direct-target.
-- Interni, self e area seguono le rispettive regole del producer nativo.
CREATE FUNCTION clan_aburame_private.sfera_prison_active_v1(p_session uuid, p_actor uuid)
RETURNS boolean LANGUAGE sql STABLE SECURITY DEFINER SET search_path = '' AS $$
    SELECT EXISTS (
        SELECT 1 FROM clan_aburame_private.sfera_sources_v1 s
        JOIN public.combat_v2_actors target ON target.id = s.target_actor_id AND target.session_id = s.session_id
        JOIN public.combat_v2_actors owner ON owner.id = s.actor_id AND owner.session_id = s.session_id
        WHERE s.session_id = p_session AND s.target_actor_id = p_actor AND s.state = 'active'
          AND owner.controller_version = s.owner_controller_version
          AND target.controller_version = s.target_controller_version
          AND (target.mechanics_snapshot->>'chakra')::integer > 0
          AND clan_aburame_private.sfera_staff_scope_v1(s.session_id, s.actor_id, s.target_actor_id)
          AND clan_aburame_private.sfera_clear_arena_distance_v1(s.session_id, s.actor_id, s.target_actor_id) <= 15
    );
$$;

CREATE FUNCTION clan_aburame_private.sfera_crosses_prison_v1(p_session uuid, p_actor uuid, p_target uuid)
RETURNS boolean LANGUAGE sql STABLE SECURITY DEFINER SET search_path = '' AS $$
    SELECT p_actor IS DISTINCT FROM p_target AND p_actor IS NOT NULL AND p_target IS NOT NULL
       AND (
           clan_aburame_private.sfera_prison_active_v1(p_session, p_actor)
           OR clan_aburame_private.sfera_prison_active_v1(p_session, p_target)
       );
$$;

REVOKE EXECUTE ON FUNCTION
    clan_aburame_private.sfera_staff_scope_v1(uuid,uuid,uuid),
    clan_aburame_private.sfera_clear_arena_distance_v1(uuid,uuid,uuid),
    clan_aburame_private.sfera_end_v1(uuid,text),
    clan_aburame_private.sfera_reserve_v1(uuid),
    clan_aburame_private.sfera_finish_v1(uuid,uuid,boolean),
    clan_aburame_private.sfera_upkeep_turn_v1(uuid,uuid),
    clan_aburame_private.sfera_prison_active_v1(uuid,uuid),
    clan_aburame_private.sfera_crosses_prison_v1(uuid,uuid,uuid)
    FROM PUBLIC, anon, authenticated, service_role;

-- Profilo Staff e binder nativi. Il gate in SFERA_STATE_COMPONENT nasce spento.
CREATE FUNCTION clan_aburame_private.sfera_staff_target_v1(p_actor uuid, p_target uuid)
RETURNS boolean LANGUAGE sql STABLE SECURITY DEFINER SET search_path = '' AS $$
    SELECT EXISTS (
        SELECT 1 FROM public.combat_v2_actors a
        JOIN public.combat_v2_sessions s ON s.id = a.session_id
        WHERE a.id = p_actor
          AND clan_aburame_private.sfera_staff_scope_v1(s.id, p_actor, p_target)
          AND clan_aburame_private.sfera_clear_arena_distance_v1(s.id, p_actor, p_target) <= 10
          AND (s.source_kind = 'ordinary' OR combat_panel_private.target_geometry_valid(p_actor, p_target, 10))
          AND NOT clan_aburame_private.sfera_crosses_prison_v1(s.id, p_actor, p_target)
          AND NOT EXISTS (
              SELECT 1 FROM clan_aburame_private.combat_sources src
              WHERE src.session_id = s.id AND src.owner_actor_id = p_actor AND src.target_actor_id = p_target
                AND src.source_kind = 'release' AND src.state IN ('prepared', 'attached')
          )
    );
$$;

CREATE FUNCTION clan_aburame_private.sfera_prepare_offer_v1(p_actor uuid)
RETURNS boolean LANGUAGE sql STABLE SECURITY DEFINER SET search_path = '' AS $$
    SELECT EXISTS (
        SELECT 1 FROM public.combat_v2_actors a
        JOIN public.combat_v2_actors t ON t.session_id = a.session_id AND t.id <> a.id
        WHERE a.id = p_actor AND clan_aburame_private.sfera_staff_target_v1(a.id, t.id)
          AND NOT a.mechanics_snapshot ? 'sfera_staff_profile'
          AND NOT a.mechanics_snapshot ? 'verme_staff_profile'
          AND NOT EXISTS (
              SELECT 1 FROM public.combat_v2_declarations d JOIN public.combat_v2_rounds r ON r.id = d.round_id
              WHERE r.session_id = a.session_id AND d.actor_id = a.id
          )
    );
$$;

CREATE FUNCTION clan_aburame_private.sfera_staff_prepare_v1(p_actor uuid, p_request uuid)
RETURNS jsonb LANGUAGE plpgsql SECURITY DEFINER SET search_path = '' AS $$
DECLARE
    v_actor public.combat_v2_actors%ROWTYPE;
    v_profile jsonb;
BEGIN
    SELECT * INTO STRICT v_actor FROM public.combat_v2_actors WHERE id = p_actor;
    PERFORM combat_effects_private.lock_context(v_actor.session_id);
    SELECT * INTO STRICT v_actor FROM public.combat_v2_actors WHERE id = p_actor FOR UPDATE;

    IF p_request IS NULL OR exam_regia_private.current_principal() IS NULL
       OR exam_regia_private.actor_principal(v_actor.id, v_actor.controller_user)
          IS DISTINCT FROM exam_regia_private.current_principal()
       OR NOT clan_aburame_private.sfera_prepare_offer_v1(p_actor)
    THEN RAISE EXCEPTION 'aburame_sfera_staff_profile_unavailable' USING ERRCODE = '42501'; END IF;
    v_profile := jsonb_build_object(
        'contract', 'aburame-sfera-staff/1', 'actor_id', p_actor, 'session_id', v_actor.session_id,
        'controller_version', v_actor.controller_version, 'request_key', p_request,
        'level', 3, 'kg', 70, 'simulation', true, 'values_written', false
    );
    UPDATE public.combat_v2_actors SET mechanics_snapshot =
        jsonb_set(jsonb_set(mechanics_snapshot, '{kekkei_genkai}', '70', true), '{sfera_staff_profile}', v_profile, true)
    WHERE id = v_actor.id;
    -- initialize conserva quantità e perdite di una Colonia già esistente.
    PERFORM clan_aburame_private.colony_transition(
        v_actor.character_id, v_actor.session_id, 'simulation', 'initialize', p_request, 0, NULL, 0, 70
    );
    RETURN v_profile;
END;
$$;

CREATE FUNCTION clan_aburame_private.sfera_meta_v1(p_actor uuid, p_defense boolean)
RETURNS jsonb LANGUAGE plpgsql STABLE SECURITY DEFINER SET search_path = '' AS $$
DECLARE
    v_actor public.combat_v2_actors%ROWTYPE;
    v_stats jsonb;
    v_kg integer;
    v_nin integer;
    v_available bigint;
BEGIN
    IF p_defense IS DISTINCT FROM false THEN RETURN NULL; END IF;
    SELECT * INTO v_actor FROM public.combat_v2_actors WHERE id = p_actor;
    v_stats := v_actor.mechanics_snapshot;
    v_kg := (v_stats->>'kekkei_genkai')::integer;
    v_nin := (v_stats->>'ninjutsu')::integer;
    IF v_stats#>>'{sfera_staff_profile,contract}' IS DISTINCT FROM 'aburame-sfera-staff/1'
       OR v_stats#>>'{sfera_staff_profile,actor_id}' IS DISTINCT FROM p_actor::text
       OR v_stats#>>'{sfera_staff_profile,session_id}' IS DISTINCT FROM v_actor.session_id::text
       OR v_stats#>>'{sfera_staff_profile,controller_version}' IS DISTINCT FROM v_actor.controller_version::text
       OR v_kg IS DISTINCT FROM 70 OR v_nin IS NULL OR v_nin < 0
       OR coalesce((v_stats->>'chakra')::integer, 0) < 20
       OR EXISTS (
           SELECT 1 FROM clan_aburame_private.sfera_sources_v1
           WHERE actor_id = p_actor AND session_id = v_actor.session_id AND state IN ('reserved','active')
       )
       OR NOT EXISTS (
           SELECT 1 FROM public.combat_v2_actors t WHERE t.session_id = v_actor.session_id
              AND t.id <> p_actor AND clan_aburame_private.sfera_staff_target_v1(p_actor, t.id)
       )
    THEN RETURN NULL; END IF;

    SELECT c.living - coalesce((
        SELECT sum(s.allocated - s.lost) FROM clan_aburame_private.colony_sources s
        WHERE s.owner_id = c.owner_id AND s.scope_id = c.scope_id AND s.state = 'active'
    ), 0) INTO v_available FROM clan_aburame_private.colonies c
    WHERE c.owner_id = v_actor.character_id AND c.scope_id = v_actor.session_id AND c.scope_kind = 'simulation';
    IF v_available IS NULL OR v_available < 15 THEN RETURN NULL; END IF;

    RETURN jsonb_build_object(
        'source','clan','id','07a93dee-a483-4a7b-b3e0-43146c2ce227','name','Sfera d’Insetti',
        'kind','ninjutsu','range','media','usage','principale','chakra_cost',20,'damage_base',0,
        'defensive',false,'di_scena',false,'diversivo',false,'consumption_type','ad_utilizzo',
        'aburame_sfera_version','aburame-sfera/1','colony_cost',15,'kg',v_kg,'ninjutsu',v_nin,
        'pool',v_kg + v_nin,'power',35 + (v_kg + v_nin)/10,
        'scope_kind','simulation','targeting',jsonb_build_object('mode','single','max_targets',1)
    );
END;
$$;

CREATE FUNCTION clan_aburame_private.sfera_escape_meta_v1(p_actor uuid, p_intent jsonb)
RETURNS jsonb LANGUAGE plpgsql STABLE SECURITY DEFINER SET search_path = '' AS $$
DECLARE
    v_source uuid;
BEGIN
    IF p_intent->>'ability_source' IS DISTINCT FROM 'clan'
       OR p_intent->>'ability_id' IS DISTINCT FROM '07a93dee-a483-4a7b-b3e0-43146c2ce227'
       OR p_intent->>'kind' IS DISTINCT FROM 'utilita' THEN RETURN NULL; END IF;
    SELECT s.declaration_id INTO v_source FROM clan_aburame_private.sfera_sources_v1 s
    WHERE s.target_actor_id = p_actor AND s.state = 'active'
      AND clan_aburame_private.sfera_prison_active_v1(s.session_id, p_actor)
    LIMIT 1;
    IF v_source IS NULL OR p_intent ? 'target_actor' OR p_intent ? 'target_actor_ids' OR p_intent ? 'move_m'
    THEN RAISE EXCEPTION 'aburame_sfera_escape_unavailable'; END IF;

    RETURN jsonb_build_object(
        'source','clan','id','07a93dee-a483-4a7b-b3e0-43146c2ce227','name','Liberarsi dalla Sfera d’Insetti',
        'kind','utilita','usage','principale','chakra_cost',0,'damage_base',0,'aburame_sfera_escape',v_source
    );
END;
$$;

CREATE FUNCTION clan_aburame_private.sfera_resolve_escape_v1(p_declaration uuid)
RETURNS jsonb LANGUAGE plpgsql SECURITY DEFINER SET search_path = '' AS $$
DECLARE
    v_action public.combat_v2_declarations%ROWTYPE;
    v_source clan_aburame_private.sfera_sources_v1%ROWTYPE;
    v_actor public.combat_v2_actors%ROWTYPE;
    v_entropy bytea;
    v_d1 integer;
    v_d2 integer;
    v_pool integer;
    v_total integer;
    v_success boolean;
BEGIN
    SELECT * INTO STRICT v_action FROM public.combat_v2_declarations WHERE id = p_declaration AND kind = 'utilita';
    SELECT * INTO STRICT v_source FROM clan_aburame_private.sfera_sources_v1
    WHERE declaration_id = (v_action.sanitized_intent#>>'{server_ability,aburame_sfera_escape}')::uuid;
    PERFORM combat_effects_private.lock_context(v_source.session_id);
    SELECT * INTO STRICT v_actor FROM public.combat_v2_actors
    WHERE id = v_action.actor_id AND session_id = v_source.session_id FOR UPDATE;
    IF v_source.target_actor_id <> v_actor.id
       OR v_actor.controller_version IS DISTINCT FROM v_action.controller_version_snapshot
       OR NOT EXISTS (
           SELECT 1 FROM public.combat_v2_rounds WHERE id = v_action.round_id
             AND session_id = v_source.session_id AND phase = 'risoluzione'
       ) THEN RAISE EXCEPTION 'aburame_sfera_escape_source_invalid'; END IF;
    IF NOT clan_aburame_private.sfera_prison_active_v1(v_source.session_id, v_actor.id) THEN
        RETURN jsonb_build_object('version','aburame-sfera-escape/1','source_declaration_id',v_source.declaration_id,
            'target_actor_id',v_actor.id,'attempted',false,'reason','source_ended');
    END IF;

    v_pool := (v_actor.mechanics_snapshot->>'forza')::integer + (v_actor.mechanics_snapshot->>'taijutsu')::integer;
    IF v_pool IS NULL THEN RAISE EXCEPTION 'aburame_sfera_escape_pool_invalid'; END IF;
    v_entropy := extensions.gen_random_bytes(32);
    v_d1 := public.combat_v2_derive_d10(v_entropy,'aburame-sfera-escape:' || p_declaration::text,1);
    v_d2 := public.combat_v2_derive_d10(v_entropy,'aburame-sfera-escape:' || p_declaration::text,2);
    v_total := v_pool/5 + v_d1 + v_d2;
    v_success := v_total > v_source.power;
    IF v_success THEN PERFORM clan_aburame_private.sfera_end_v1(v_source.declaration_id,'escaped'); END IF;

    RETURN jsonb_build_object('version','aburame-sfera-escape/1','source_declaration_id',v_source.declaration_id,
        'target_actor_id',v_actor.id,'attempted',true,'success',v_success,'pool',v_pool,'total',v_total,
        'dice',jsonb_build_array(v_d1,v_d2),'power',v_source.power);
END;
$$;

REVOKE EXECUTE ON FUNCTION clan_aburame_private.sfera_staff_target_v1(uuid,uuid),
    clan_aburame_private.sfera_prepare_offer_v1(uuid), clan_aburame_private.sfera_staff_prepare_v1(uuid,uuid),
    clan_aburame_private.sfera_meta_v1(uuid,boolean), clan_aburame_private.sfera_escape_meta_v1(uuid,jsonb),
    clan_aburame_private.sfera_resolve_escape_v1(uuid) FROM PUBLIC, anon, authenticated, service_role;

CREATE FUNCTION clan_aburame_private.sfera_frozen_v1(p_declaration uuid)
RETURNS jsonb LANGUAGE plpgsql STABLE SECURITY DEFINER SET search_path = '' AS $$
DECLARE
    v_row clan_aburame_private.sfera_sources_v1%ROWTYPE;
    v_meta jsonb;
BEGIN
    SELECT * INTO v_row FROM clan_aburame_private.sfera_sources_v1 WHERE declaration_id = p_declaration;
    IF NOT FOUND THEN RETURN NULL; END IF;
    SELECT d.sanitized_intent->'server_ability' INTO STRICT v_meta
    FROM public.combat_v2_declarations d
    WHERE d.id=p_declaration AND d.round_id=v_row.round_id AND d.request_key=v_row.request_key
      AND d.actor_id=v_row.actor_id AND d.target_actor_id=v_row.target_actor_id;
    IF public.combat_v2_sha256(v_meta) IS DISTINCT FROM v_row.private_ability_sha256
    THEN RAISE EXCEPTION 'aburame_sfera_frozen_meta_drift'; END IF;
    RETURN v_meta;
END;
$$;

CREATE FUNCTION clan_aburame_private.sfera_settle_round_v1(p_round uuid)
RETURNS void LANGUAGE plpgsql SECURITY DEFINER SET search_path = '' AS $$
DECLARE
    v_id uuid;
BEGIN
    FOR v_id IN
        SELECT declaration_id FROM clan_aburame_private.sfera_sources_v1
        WHERE round_id=p_round AND state='reserved' ORDER BY declaration_id
    LOOP
        PERFORM clan_aburame_private.sfera_end_v1(v_id,'source_invalid');
    END LOOP;
END;
$$;

REVOKE EXECUTE ON FUNCTION clan_aburame_private.sfera_frozen_v1(uuid),
    clan_aburame_private.sfera_settle_round_v1(uuid) FROM PUBLIC, anon, authenticated, service_role;

-- Non esporre direttamente al client o al provider. Il report nativo ne sigilla i fatti.
CREATE FUNCTION clan_aburame_private.sfera_report_v1(p_round uuid)
RETURNS jsonb LANGUAGE sql STABLE SECURITY DEFINER SET search_path = '' AS $$
    WITH facts(when_order, declaration, kind, payload) AS (
        SELECT 1, s.declaration_id, 'cast', s.initial_facts
        FROM clan_aburame_private.sfera_sources_v1 s
        WHERE s.round_id = p_round AND s.initial_facts IS NOT NULL
        UNION ALL
        SELECT 2, d.id, 'escape', d.outcome->'aburame_sfera_escape'
        FROM public.combat_v2_declarations d
        JOIN clan_aburame_private.sfera_sources_v1 s
          ON s.declaration_id::text = d.sanitized_intent#>>'{server_ability,aburame_sfera_escape}'
        JOIN public.combat_v2_rounds r ON r.id=d.round_id AND r.session_id=s.session_id
        WHERE d.round_id=p_round AND d.actor_id=s.target_actor_id AND d.state='risolta'
          AND jsonb_typeof(d.outcome->'aburame_sfera_escape')='object'
        UNION ALL
        SELECT 0, u.declaration_id, 'turn_start', u.facts
        FROM clan_aburame_private.sfera_upkeep_v1 u
        WHERE u.round_id=p_round
    )
    SELECT CASE WHEN count(*)=0 THEN '{}'::jsonb ELSE jsonb_build_object(
      'aburame_sfera',jsonb_build_object('contract','aburame-sfera-report/1','events',jsonb_agg(
        jsonb_build_object('declaration_id',declaration,'kind',kind,'facts',payload)
        ORDER BY when_order,declaration
      ))
    ) END
    FROM facts;
$$;
REVOKE EXECUTE ON FUNCTION clan_aburame_private.sfera_report_v1(uuid)
    FROM PUBLIC, anon, authenticated, service_role;

-- Il Fato consuma solo eventi dalla meccanica congelata del round.
CREATE FUNCTION clan_aburame_private.sfera_narrative_v1(p_round uuid,p_declaration uuid)
RETURNS jsonb LANGUAGE sql STABLE SECURITY DEFINER SET search_path = '' AS $$
    WITH signed AS (
        SELECT r.session_id,rp.mechanics->'aburame_sfera' AS facts
        FROM public.combat_v2_rounds r
        JOIN public.combat_v2_round_reports rp ON rp.id=r.report_id AND rp.round_id=r.id
        WHERE r.id=p_round AND r.state IN ('risolto','narrato') AND r.resolved_at IS NOT NULL
          AND rp.mechanics_sha256=public.combat_v2_sha256(rp.mechanics)
          AND rp.mechanics#>>'{aburame_sfera,contract}'='aburame-sfera-report/1'
    ), events AS (
        SELECT ev.value AS e, ev.ord, source.actor_id,source.target_actor_id,
               sc.name AS source_name,tc.name AS target_name
        FROM signed
        CROSS JOIN LATERAL jsonb_array_elements(signed.facts->'events') WITH ORDINALITY ev(value,ord)
        JOIN clan_aburame_private.sfera_sources_v1 source
          ON source.declaration_id::text=ev.value#>>'{facts,source_declaration_id}'
         AND source.session_id=signed.session_id
         AND source.target_actor_id::text=ev.value#>>'{facts,target_actor_id}'
        JOIN public.combat_v2_actors sa ON sa.id=source.actor_id AND sa.session_id=signed.session_id
        JOIN public.combat_v2_actors ta ON ta.id=source.target_actor_id AND ta.session_id=signed.session_id
        JOIN public.characters sc ON sc.id=sa.character_id
        JOIN public.characters tc ON tc.id=ta.character_id
        WHERE ev.value->>'kind' IN ('cast','turn_start','escape')
          AND (p_declaration IS NULL OR ev.value->>'declaration_id'=p_declaration::text
              OR ev.value->>'kind'='turn_start' AND EXISTS (
                  SELECT 1 FROM public.combat_v2_declarations d
                  WHERE d.id=p_declaration AND d.round_id=p_round AND d.actor_id=source.actor_id
              ))
    )
    SELECT CASE WHEN count(*)=0 THEN '{}'::jsonb ELSE jsonb_build_object(
        'aburame_sfera_server',jsonb_build_object('version','aburame-sfera-narrative/1','events',jsonb_agg(
            jsonb_build_object(
                'event_key',e->>'kind'||':'||(e->>'declaration_id')||':'||p_round::text,
                'kind',e->>'kind','source_actor_id',actor_id,'target_actor_id',target_actor_id,
                'source',source_name,'target',target_name,
                'prison_active',e#>'{facts,prison_active}',
                'chakra_drained',coalesce(e#>'{facts,chakra_drained}','0'::jsonb),
                'chakra_paid', CASE WHEN e->>'kind'='cast' THEN '20'::jsonb
                                    ELSE coalesce(e#>'{facts,chakra_paid}','0'::jsonb) END,
                'attempted',e#>'{facts,attempted}','success',e#>'{facts,success}',
                'end_reason',coalesce(e#>>'{facts,end_reason}',e#>>'{facts,reason}')
            ) ORDER BY ord
        ))
    ) END FROM events;
$$;

CREATE FUNCTION clan_aburame_private.sfera_narrative_revision_v1(p_facts jsonb)
RETURNS text LANGUAGE plpgsql IMMUTABLE SET search_path = '' AS $$
DECLARE
    v_box jsonb := p_facts->'aburame_sfera_server';
    v_event jsonb;
    v_keys text[] := ARRAY['event_key','kind','source_actor_id','target_actor_id','source','target',
        'prison_active','chakra_drained','chakra_paid','attempted','success','end_reason'];
    v_seen text[] := ARRAY[]::text[];
    v_kind text;
    v_drain integer;
    v_paid integer;
BEGIN
    IF NOT mission_factory_owner.keys_exact_v2(v_box,ARRAY['version','events'])
       OR v_box->>'version' IS DISTINCT FROM 'aburame-sfera-narrative/1'
       OR jsonb_typeof(v_box->'events') IS DISTINCT FROM 'array'
    THEN RAISE EXCEPTION 'aburame_sfera_narrative_shape_invalid'; END IF;
    IF jsonb_array_length(v_box->'events') NOT BETWEEN 1 AND 16
    THEN RAISE EXCEPTION 'aburame_sfera_narrative_length_invalid'; END IF;
    FOR v_event IN SELECT value FROM jsonb_array_elements(v_box->'events')
    LOOP
        IF NOT mission_factory_owner.keys_exact_v2(v_event,v_keys)
           OR jsonb_typeof(v_event->'event_key') IS DISTINCT FROM 'string'
           OR coalesce(length(btrim(v_event->>'event_key')),0) NOT BETWEEN 1 AND 200
           OR v_event->>'event_key'=ANY(v_seen)
           OR jsonb_typeof(v_event->'source') IS DISTINCT FROM 'string'
           OR jsonb_typeof(v_event->'target') IS DISTINCT FROM 'string'
           OR coalesce(length(btrim(v_event->>'source')),0) NOT BETWEEN 1 AND 300
           OR coalesce(length(btrim(v_event->>'target')),0) NOT BETWEEN 1 AND 300
           OR jsonb_typeof(v_event->'source_actor_id') IS DISTINCT FROM 'string'
           OR jsonb_typeof(v_event->'target_actor_id') IS DISTINCT FROM 'string'
           OR NOT (v_event->>'source_actor_id' ~* '^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$')
           OR NOT (v_event->>'target_actor_id' ~* '^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$')
           OR (v_event->>'source_actor_id')::uuid=(v_event->>'target_actor_id')::uuid
           OR jsonb_typeof(v_event->'chakra_drained') IS DISTINCT FROM 'number'
           OR jsonb_typeof(v_event->'chakra_paid') IS DISTINCT FROM 'number'
        THEN RAISE EXCEPTION 'aburame_sfera_narrative_event_invalid'; END IF;
        v_seen:=array_append(v_seen,v_event->>'event_key');
        v_kind:=v_event->>'kind';
        v_drain:=(v_event->>'chakra_drained')::integer;
        v_paid:=(v_event->>'chakra_paid')::integer;
        IF v_drain NOT BETWEEN 0 AND 10 OR (
            CASE v_kind
              WHEN 'cast' THEN p_facts->>'kind'='attacco' AND v_paid=20
                AND jsonb_typeof(v_event->'prison_active')='boolean'
                AND (v_event->'prison_active'='false'::jsonb OR v_drain>0)
                AND v_event->'attempted'='null'::jsonb AND v_event->'success'='null'::jsonb
                AND v_event->'end_reason'='null'::jsonb
              WHEN 'turn_start' THEN v_paid IN (0,10) AND (v_paid=10 OR v_drain=0)
                AND jsonb_typeof(v_event->'prison_active')='boolean'
                AND v_event->'attempted'='null'::jsonb AND v_event->'success'='null'::jsonb
                AND (CASE WHEN v_event->'prison_active'='true'::jsonb
                   THEN v_paid=10 AND v_drain>0 AND v_event->'end_reason'='null'::jsonb
                   ELSE v_event->>'end_reason' IN ('target_depleted','source_invalid','unsupported_geometry','distance','insufficient_chakra') END)
              WHEN 'escape' THEN p_facts->>'kind'='utilita' AND v_paid=0 AND v_drain=0 AND v_event->'prison_active'='null'::jsonb
                AND (CASE WHEN v_event->'attempted'='true'::jsonb THEN jsonb_typeof(v_event->'success')='boolean'
                     AND v_event->'end_reason'='null'::jsonb
                   ELSE v_event->'attempted'='false'::jsonb AND v_event->'success'='null'::jsonb
                     AND v_event->>'end_reason'='source_ended' END)
              ELSE false
            END
        ) IS DISTINCT FROM true THEN RAISE EXCEPTION 'aburame_sfera_narrative_event_range_invalid'; END IF;
    END LOOP;
    IF p_facts ? 'nara_strangle_server' THEN
        PERFORM combat_panel_private.nara_strangle_facts_revision_v1(p_facts-'aburame_sfera_server');
    END IF;
    RETURN 'combat-facts/5';
END;
$$;
REVOKE EXECUTE ON FUNCTION clan_aburame_private.sfera_narrative_v1(uuid,uuid),
    clan_aburame_private.sfera_narrative_revision_v1(jsonb) FROM PUBLIC, anon, authenticated, service_role;

-- L'esito legale è prodotto dal confronto nativo, senza dedurlo dal danno PV.
CREATE FUNCTION clan_aburame_private.sfera_hits_v1(
    p_margin integer,
    p_reaction text,
    p_copy_intercepted boolean,
    p_clone jsonb,
    p_rotation jsonb,
    p_cellular jsonb
) RETURNS boolean LANGUAGE sql IMMUTABLE SET search_path = '' AS $$
    SELECT p_margin >= 0
       AND coalesce(p_reaction,'nessuna') <> 'sostituzione'
       AND NOT coalesce(p_copy_intercepted,false)
       AND NOT coalesce(p_clone->'full_success' = 'true'::jsonb,false)
       AND NOT coalesce(p_rotation->'defense_won' = 'true'::jsonb,false)
       AND NOT coalesce(p_cellular->'defense_won' = 'true'::jsonb,false);
$$;
REVOKE EXECUTE ON FUNCTION clan_aburame_private.sfera_hits_v1(integer,text,boolean,jsonb,jsonb,jsonb)
    FROM PUBLIC, anon, authenticated, service_role;

-- Potenza della stessa fonte dichiarata; niente nuovo evento o costo.
CREATE FUNCTION clan_aburame_private.sfera_defense_power_v1(p_declaration uuid)
RETURNS jsonb LANGUAGE plpgsql STABLE SECURITY DEFINER SET search_path = '' AS $$
DECLARE
    v_d public.combat_v2_declarations%ROWTYPE;
    v_meta jsonb;
    v_live jsonb;
BEGIN
    SELECT * INTO v_d FROM public.combat_v2_declarations
    WHERE id=p_declaration AND kind='attacco' AND state='inviata'
      AND sanitized_intent->>'ability_source'='clan'
      AND sanitized_intent->>'ability_id'='07a93dee-a483-4a7b-b3e0-43146c2ce227';
    IF NOT FOUND THEN RETURN NULL; END IF;
    v_meta:=v_d.sanitized_intent->'server_ability';
    v_live:=clan_aburame_private.sfera_meta_v1(v_d.actor_id,false);
    IF v_live IS NULL OR v_meta IS NULL OR NOT (v_meta @> v_live)
       OR NOT clan_aburame_private.sfera_staff_target_v1(v_d.actor_id,v_d.target_actor_id)
       OR v_d.cost_snapshot->'chakra' IS DISTINCT FROM '20'::jsonb
       OR v_d.cost_snapshot->'damage_base' IS DISTINCT FROM '0'::jsonb
       OR (SELECT count(*) FROM public.combat_v2_attack_targets WHERE attack_declaration_id=v_d.id)<>1
       OR NOT EXISTS (
         SELECT 1 FROM public.combat_v2_attack_targets t
         JOIN public.combat_v2_rounds r ON r.id=t.round_id
         JOIN public.combat_v2_actors a ON a.id=t.target_actor_id AND a.session_id=r.session_id
         WHERE t.attack_declaration_id=v_d.id AND t.round_id=v_d.round_id
           AND t.target_actor_id=v_d.target_actor_id
           AND t.target_controller_version=a.controller_version
       ) THEN RETURN NULL; END IF;
    RETURN v_meta;
END;
$$;
REVOKE EXECUTE ON FUNCTION clan_aburame_private.sfera_defense_power_v1(uuid)
    FROM PUBLIC, anon, authenticated, service_role;

CREATE OR REPLACE FUNCTION public._combat_calcola(p_kind text, p_a jsonb, p_d jsonb, p_reazione text, p_dif_disc text, p_base integer, p_elemento text, p_dado_att integer, p_dado_dif integer, p_mira integer, p_guardia integer, p_colto boolean)
 RETURNS jsonb
 LANGUAGE plpgsql
 IMMUTABLE
 SET search_path TO 'public'
AS $function$
declare
  atk_sum int; def_sum int; off int; red int; v_div int; v_rid int;
  hit_bonus int:=0; hit_margin int; atk int; def int; margine int; mb int; grezzo int; applicato int;
  e_atk int := 0; e_def int := 0; v_gen boolean; v_sost boolean; v_copie boolean;
  v_sfiora boolean := false;
  el_att text; el_dif text;
  -- Guardia è storica: la firma resta compatibile, ma il parametro non decide
  -- più niente. Ogni nuovo referto registra mod_guardia = 0.
  g int := 0; m int := coalesce(p_mira,0);
  -- [V1.1] Lo Slancio viaggia dentro il JSON dell'attaccante: la firma resta
  -- di 12 argomenti, quindi niente DROP+CREATE, niente ACL da rimettere e
  -- test_room_scenario continua a chiamare questa funzione senza modifiche.
  s int := least(9, greatest(0, coalesce((p_a->>'slancio')::int, 0)));
  -- [V1.1] «colto in azione» e' SOSPESO (decisione 6 del 06/08/2026). Il
  -- parametro resta in firma per non toccare i consumer, ma non ha piu'
  -- effetto: mod_colto vale 0 in ogni referto.
  c int := 0;
  v_kind text := lower(coalesce(p_kind,'fisico'));
  -- [040-R1] Le copie viaggiano dentro il json del DIFENSORE, come lo Slancio
  -- viaggia dentro quello dell'attaccante: la firma resta di 12 argomenti.
  -- Il tetto a 4 è la rete finale, non la regola: la regola è `_copie_cap`,
  -- applicata da chi crea le copie.
  cp int := least(4, greatest(0, coalesce((p_d->>'copie_n')::int, 0)));
  bc int := 0;
  fb_deduction integer:=0;fb_modifier jsonb;
begin
  fb_modifier:=p_d->'_facing_modifier';
  IF fb_modifier IS NOT NULL THEN
   IF jsonb_typeof(fb_modifier)IS DISTINCT FROM'object'OR fb_modifier->>'contract'IS DISTINCT FROM'byakugan-facing/1'
    OR (fb_modifier->>'deduction')!~'^[0-3]$'OR(fb_modifier->>'level')!~'^[1-4]$'
    OR jsonb_typeof(fb_modifier->'rear')IS DISTINCT FROM'boolean'
    OR (fb_modifier->>'receipt_id')!~'^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$'
   THEN RAISE EXCEPTION 'facing_math_context_invalid' USING ERRCODE='22023';END IF;
   fb_deduction:=(fb_modifier->>'deduction')::integer;
   IF fb_deduction IS DISTINCT FROM(CASE WHEN(fb_modifier->>'rear')::boolean THEN 4-(fb_modifier->>'level')::integer ELSE 0 END)THEN RAISE EXCEPTION 'facing_math_deduction_invalid' USING ERRCODE='22023';END IF;
  END IF;
  IF coalesce(p_guardia,0) NOT IN (0,1)
   OR (p_guardia=1 AND lower(btrim(coalesce(p_reazione,'')))<>'schivata') THEN
   RAISE EXCEPTION 'inuzuka_guardia_invalid' USING ERRCODE='22023';
  END IF;
  g:=coalesce(p_guardia,0);
  v_gen  := (v_kind = 'genjutsu');
  v_sost := (lower(btrim(coalesce(p_reazione,''))) = 'sostituzione');
  v_copie := (lower(btrim(coalesce(p_reazione,''))) = 'copie');
  -- [040-R1 · ratifica PM 041] Bonus Copertura SUL TOTALE, 0/+2/+3/+3. Solo in
  -- difesa: la modalità ratificata è la sola Copertura, e nessun ramo lo somma
  -- ad `atk`. È qui che il divieto di cumulo con lo Slancio diventa
  -- strutturale invece che una raccomandazione.
  bc := case when v_copie then public._copie_bonus(cp) else 0 end;
  -- [ELEM-CONSERVATO] [TASK-COMBAT-ELEMENTI-JUTSU-001, 10/08/2026]
  -- Il vantaggio elementale non guarda piu' gli elementi POSSEDUTI dai
  -- personaggi (characters.element e element2, che qui non arrivano nemmeno
  -- piu'): guarda i due elementi realmente in campo, cioe' la natura della
  -- tecnica che attacca (p_elemento) e la natura della tecnica difensiva
  -- effettivamente giocata (p_d->>'tech_element', valorizzato solo da chi
  -- risolve). Se uno dei due manca -- colpo fisico, tecnica neutrale, parata,
  -- schivata, Sostituzione neutrale -- il modificatore e' zero da entrambe le
  -- parti. LA V1.1 NON TOCCA QUESTE DUE RIGHE.
  el_att := nullif(btrim(coalesce(p_elemento,'')),'');
  el_dif := nullif(btrim(coalesce(p_d->>'tech_element','')),'');
  -- Il pool d'attacco non dipende dalla reazione. Tenere `copie` nello stesso
  -- ramo lasciava atk_sum/off/red nulli proprio nella nuova difesa: un verde
  -- ottenuto senza calcolare il colpo sarebbe peggiore di un errore rumoroso.
  if p_a ? 'marionetta_profile' then
    if p_a#>>'{marionetta_profile,formula_version}' is distinct from 'marionetta-offense/1' or v_kind<>'fisico' or p_base is distinct from 10 then raise exception 'marionetta_calculation_profile_invalid';end if;
    if ((p_a->'marionetta_profile') @> clan_marionettisti_private.offensive_values((p_a#>>'{marionetta_profile,kg}')::integer,(p_a#>>'{marionetta_profile,ninjutsu}')::integer)) is distinct from true then raise exception 'marionetta_calculation_profile_mismatch';end if;
    atk_sum := (p_a#>>'{marionetta_profile,pool}')::int; off := (p_a#>>'{marionetta_profile,off}')::int; red := 20;
  -- Insert into native profile dispatch before v_gen, after the existing marionetta branch.
elsif p_a ? 'sedici_profile' then
  if v_kind<>'fisico' or p_base<>20
    or p_a#>>'{sedici_profile,profile_version}' is distinct from 'hyuga-sedici/1'
    or p_a#>>'{sedici_profile,power_base}' is distinct from '25'
    or p_a#>>'{sedici_profile,defense_base}' is distinct from '20'
    or p_a#>>'{sedici_profile,passive_juken_added}' is distinct from 'false'
  then raise exception 'sedici_calculation_profile_invalid'; end if;
  atk_sum := (p_a#>>'{sedici_profile,kg}')::int + (p_a#>>'{sedici_profile,taijutsu}')::int;
  off := 25; red := 20;

  elsif p_a ? 'projectile_fireball' then
    if v_kind<>'ninjutsu' or p_base IS DISTINCT FROM (p_a#>>'{projectile_fireball,damage_base}')::integer
      or (p_a->'projectile_fireball' @> clan_uchiha_private.fireball_values(
        (p_a#>>'{projectile_fireball,catalog_technique_id}')::uuid,p_a#>>'{projectile_fireball,mode}',p_a,
        (p_a#>>'{projectile_fireball,resonance_bonus}')::integer)) IS DISTINCT FROM true then
      raise exception 'fireball_calculation_profile_invalid';end if;
    atk_sum:=(p_a#>>'{projectile_fireball,pool}')::integer;off:=(p_a#>>'{projectile_fireball,off}')::integer;red:=40;
    hit_bonus:=(p_a#>>'{projectile_fireball,resonance_bonus}')::integer;
  elsif p_a ? 'aburame_sfera_profile' then
    if v_kind<>'ninjutsu' or p_base is distinct from 0
      or p_a#>>'{aburame_sfera_profile,aburame_sfera_version}' is distinct from 'aburame-sfera/1'
      or (p_a#>>'{aburame_sfera_profile,kg}')::int<70
      or (p_a#>>'{aburame_sfera_profile,ninjutsu}')::int<0
      or (p_a#>>'{aburame_sfera_profile,pool}')::int is distinct from ((p_a#>>'{aburame_sfera_profile,kg}')::int+(p_a#>>'{aburame_sfera_profile,ninjutsu}')::int)
      or (p_a#>>'{aburame_sfera_profile,power}')::int is distinct from (35+(p_a#>>'{aburame_sfera_profile,pool}')::int/10)
    then raise exception 'aburame_sfera_calculation_profile_invalid';end if;
    atk_sum:=(p_a#>>'{aburame_sfera_profile,pool}')::int;
    off:=greatest((p_a#>>'{aburame_sfera_profile,kg}')::int,(p_a#>>'{aburame_sfera_profile,ninjutsu}')::int);red:=40;
  elsif p_a ? 'aburame_verme_profile' then
    if v_kind<>'ninjutsu' or p_base is distinct from 10
      or p_a#>>'{aburame_verme_profile,aburame_verme_version}' is distinct from 'aburame-verme/1'
      or (p_a#>>'{aburame_verme_profile,kg}')::int<55
      or (p_a#>>'{aburame_verme_profile,ninjutsu}')::int<0
      or (p_a#>>'{aburame_verme_profile,pool}')::int is distinct from ((p_a#>>'{aburame_verme_profile,kg}')::int+(p_a#>>'{aburame_verme_profile,ninjutsu}')::int)
      or (p_a#>>'{aburame_verme_profile,power}')::int is distinct from (25+(p_a#>>'{aburame_verme_profile,pool}')::int/10)
    then raise exception 'aburame_verme_calculation_profile_invalid';end if;
    atk_sum:=(p_a#>>'{aburame_verme_profile,pool}')::int;
    off:=greatest((p_a#>>'{aburame_verme_profile,kg}')::int,(p_a#>>'{aburame_verme_profile,ninjutsu}')::int);red:=40;
  elsif v_gen then
    atk_sum := (p_a->>'mente')::int + (p_a->>'genjutsu')::int; off := (p_a->>'mente')::int; red := 40;
  elsif v_kind = 'ninjutsu' then
    atk_sum := (p_a->>'mente')::int + (p_a->>'ninjutsu')::int; off := (p_a->>'mente')::int; red := 40;
  else
    atk_sum := (p_a->>'forza')::int + (p_a->>'taijutsu')::int;
    off := greatest((p_a->>'forza')::int, (p_a->>'taijutsu')::int); red := 20;
  end if;
  if v_copie then
    -- Le copie non danno un bonus piatto: cambiano il pool della reazione.
    -- È il confronto intero Mente + Ninjutsu contro l'attacco.
    def_sum := (p_d->>'mente')::int + (p_d->>'ninjutsu')::int;
  elsif v_gen then
    def_sum := (p_d->>'mente')::int + (p_d->>'genjutsu')::int;
  elsif p_reazione = 'tecnica' then
    def_sum := case lower(btrim(coalesce(p_dif_disc,'')))
      when 'taijutsu'   then (p_d->>'velocita')::int + (p_d->>'taijutsu')::int
      when 'genjutsu'   then (p_d->>'mente')::int    + (p_d->>'genjutsu')::int
      when 'fuuinjutsu' then (p_d->>'mente')::int    + (p_d->>'fuuinjutsu')::int
      else                   (p_d->>'mente')::int    + (p_d->>'ninjutsu')::int end;
  elsif p_reazione = 'parata' then
    -- [changelog 45, 05/08/2026] prima era (forza + taijutsu): la parata pescava da un
    -- pool suo, che il regolamento non ha mai descritto. Ora e' come le altre reazioni
    -- di base; il vantaggio della parata resta tutto nel divisore di riduzione a 10.
    def_sum := (p_d->>'velocita')::int + (p_d->>'taijutsu')::int;
  else
    def_sum := (p_d->>'velocita')::int + (p_d->>'taijutsu')::int;
  end if;
  -- [ELEM-CONSERVATO] Servono DUE elementi dichiarati e diversi fra loro.
  -- Stesso elemento: zero. Il verso lo decide il ciclo
  -- (Fuoco > Vento > Fulmine > Terra > Acqua > Fuoco), che resta tutto dentro
  -- public._elem_batte e non e' toccato ne' da quel task ne' da questo.
  if el_att is not null and el_dif is not null and lower(el_att) <> lower(el_dif) then
    if public._elem_batte(el_att, el_dif) then e_atk := 2;
    elsif public._elem_batte(el_dif, el_att) then e_def := 2;
    end if;
  end if;
  -- [V1.1 · decisione 1 del 06/08/2026] il termine di abilita' passa da
  -- ⌊pool/10⌋ a ⌊pool/5⌋; il dado e' 2d10 e lo tira chi risolve. Lo Slancio
  -- entra qui, accanto alla Mira, e vale solo per l'attaccante.
  atk := (atk_sum/5) + p_dado_att + m + s + e_atk;
  def := (def_sum/5) + p_dado_dif + g + e_def + c + bc - fb_deduction;
  margine := atk - def;
  hit_margin:=margine+hit_bonus;
  -- [V1.1] riduzione_div e riduzione sono SEMPRE valorizzati: servono a
  -- spiegare anche il numero dello sfioramento, che prima non esisteva.
  v_div := case when p_reazione = 'parata' then 10 else red end;
  v_rid := ((p_d->>'resistenza')::int / v_div);
  if hit_margin < 0 then
    -- [V1.1 · decisione 2 del 06/08/2026] Lo sfioramento: un attacco mancato
    -- infligge un quarto del danno pieno, mai meno di 1 PV. Nessuna costante
    -- nuova: la formula e' quella del margine zero, con bonus_margine a 0.
    mb := 0;
    grezzo := greatest(1, coalesce(p_base,0) + (off/4) - v_rid);
    if v_gen or v_sost or v_copie then
      -- Il genjutsu spezzato non sfiora: non c'e' corpo da toccare.
      -- Sostituzione e copia colpita sono negazioni distinte: la prima è
      -- garantita e costa chakra, la seconda dipende dal confronto delle copie.
      grezzo := 0; applicato := 0; v_sfiora := false;
    else
      applicato := greatest(1, grezzo/4); v_sfiora := true;
    end if;
  else
    mb := case when margine < 5 then 0 when margine < 10 then 3 when margine < 15 then 6 else 10 end;
    grezzo := greatest(1, coalesce(p_base,0) + (off/4) + mb - v_rid);
    applicato := least(65, grezzo);
    if v_sost then grezzo := 0; applicato := 0; end if;
  end if;
  return jsonb_build_object(
    'pool_att', atk_sum, 'pool_dif', def_sum, 'dado_att', p_dado_att, 'dado_dif', p_dado_dif,
    'accuracy_contract','accuracy-only/1','mod_risonanza',hit_bonus,'hit_margin',hit_margin,'damage_margin',margine,
    'mod_mira', m, 'mod_guardia', g, 'mod_colto', c, 'mod_slancio', s,
    'copie_n', cp, 'mod_copie', bc,
    'mod_elem_att', e_atk, 'mod_elem_dif', e_def,
    -- [ELEM-CONSERVATO] chiavi diagnostiche: si leggono, non decidono niente.
    'elem_att', el_att, 'elem_dif', el_dif,
    'atk_tot', atk, 'def_tot', def, 'margine', margine, 'bonus_margine', mb, 'off', off,
    'riduzione_div', v_div, 'riduzione', v_rid,
    'danno_grezzo', grezzo, 'danno_applicato', applicato,
    'cap_attivo', (not v_sfiora and grezzo > 65),
    'striscio', v_sfiora,
    'colpito', (hit_margin >= 0 and not v_sost),
    'esito_copie', case when v_copie and hit_margin < 0 then 'copia_colpita'
                        when v_copie then 'originale_individuato' end) || case when p_a ? 'marionetta_profile' then jsonb_build_object('marionetta_profile',p_a->'marionetta_profile') else '{}'::jsonb end
   || CASE WHEN fb_modifier IS NULL THEN '{}'::jsonb ELSE jsonb_build_object('facing_contract','byakugan-facing/1','mod_byakugan_blindspot',-fb_deduction,'facing_receipt_id',fb_modifier->'receipt_id','byakugan_level',fb_modifier->'level','rear_attack',fb_modifier->'rear')END;
end; $function$;
CREATE OR REPLACE FUNCTION clan_aburame_private.action_meta(p_round uuid, p_actor uuid, p_request uuid, p_intent jsonb)
 RETURNS jsonb
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO ''
AS $function$
DECLARE s clan_aburame_private.combat_sources%ROWTYPE;
BEGIN
 IF p_intent->>'ability_id'='07a93dee-a483-4a7b-b3e0-43146c2ce227' AND p_intent->>'kind'='utilita' THEN
  RETURN clan_aburame_private.sfera_escape_meta_v1(p_actor,p_intent);
 END IF;
 IF p_intent->>'kind' IS DISTINCT FROM 'utilita' OR p_intent->>'ability_source' IS DISTINCT FROM 'clan' OR p_intent->>'ability_id' IS DISTINCT FROM 'f5e9af24-70f1-49f6-a7ca-74f59256336e' THEN RETURN NULL;END IF;
 SELECT * INTO s FROM clan_aburame_private.combat_sources WHERE target_actor_id=p_actor AND source_kind='release' AND state='attached' FOR UPDATE;
 IF s.id IS NULL THEN RETURN NULL;END IF;
 RETURN jsonb_build_object('source','clan','id','f5e9af24-70f1-49f6-a7ca-74f59256336e','name','Liberazione dallo sciame','kind','utilita','usage','principale','chakra_cost',0,'damage_base',0,'aburame_escape_source',s.id);
END $function$;
CREATE OR REPLACE FUNCTION clan_aburame_private.actor_ability(p_actor uuid, p_source text, p_ability uuid, p_defense boolean, p_fallback jsonb)
 RETURNS jsonb
 LANGUAGE plpgsql
 STABLE SECURITY DEFINER
 SET search_path TO ''
AS $function$
DECLARE ct public.clan_techniques%ROWTYPE;
BEGIN
 IF p_source='clan' AND p_ability='07a93dee-a483-4a7b-b3e0-43146c2ce227'::uuid THEN
  RETURN clan_aburame_private.sfera_meta_v1(p_actor,p_defense);
 END IF;
 IF p_source='clan' AND p_ability='2f06b6f8-341f-472b-be04-ad48fcf2c412'::uuid THEN
  -- Identita dedicata: stesso metadata/quote del producer, mai la copia generica dello snapshot.
  RETURN clan_aburame_private.verme_meta_v1(p_actor,p_defense);
 END IF;
 IF p_source<>'clan' OR p_ability NOT IN ('f5e9af24-70f1-49f6-a7ca-74f59256336e'::uuid,'b9195ceb-74de-4251-95af-fe5c1bdaf485'::uuid)
 THEN RETURN p_fallback;END IF;
 IF NOT clan_aburame_private.actor_has_technique(p_actor,p_ability) THEN RETURN NULL;END IF;
 IF p_defense IS DISTINCT FROM (p_ability='b9195ceb-74de-4251-95af-fe5c1bdaf485'::uuid) THEN RETURN NULL;END IF;
 SELECT * INTO STRICT ct FROM public.clan_techniques WHERE id=p_ability AND is_active;
 RETURN jsonb_build_object('id',ct.id,'kind','ninjutsu','name',ct.name,'range',CASE WHEN p_defense THEN 'contatto' ELSE 'corta' END,
  'usage',CASE WHEN p_defense THEN 'difesa' ELSE 'principale' END,'source','clan','element',NULL,'di_scena',false,
  'defensive',p_defense,'diversivo',false,'chakra_cost',CASE WHEN p_defense THEN 10 ELSE 5 END,
  'damage_base',CASE WHEN p_defense THEN 0 ELSE 15 END,'consumption_type','ad_utilizzo','aburame_version','aburame-genin/1');
END $function$;
CREATE OR REPLACE FUNCTION clan_aburame_private.commit_control(p jsonb, prepared jsonb, p_ctx combat_consumer_private.activities, p_offer combat_consumer_private.offers, p_event uuid)
 RETURNS jsonb
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO ''
AS $function$
DECLARE actor uuid:=(prepared->>'actor_id')::uuid;cid uuid:=(prepared->>'principal_character_id')::uuid;key uuid:=(p->>'request_key')::uuid;env jsonb;receipt jsonb;label jsonb;
BEGIN
 IF p_offer.source_payload->>'aburame_operation'='sfera_staff_prepare' THEN
  PERFORM clan_aburame_private.sfera_staff_prepare_v1(actor,key);
 ELSIF p_offer.source_payload->>'aburame_operation'='verme_staff_prepare' THEN
  PERFORM clan_aburame_private.verme_staff_prepare_v1(actor,key);
 ELSIF p_offer.source_payload->>'aburame_operation'='release_stop' THEN
  PERFORM clan_aburame_private.stop_release(actor,(p_offer.source_payload->>'source_id')::uuid);
 ELSE RAISE EXCEPTION 'aburame_control_operation_invalid'; END IF;
 UPDATE combat_consumer_private.activities SET context_version=context_version+1,last_action_at=clock_timestamp() WHERE session_id=p_ctx.session_id;
 UPDATE combat_consumer_private.offers SET state='consumed',consumed_request_key=key WHERE id=p_offer.id;
 env:=combat_consumer_private.state_projection(p_ctx.location_id);label:=combat_consumer_private.display_label(p_ctx.session_id,actor,actor,NULL);
 receipt:=jsonb_build_object('receipt_id',p_event,'request_key',key,'operation','control','replayed',false,'activity_id',p_ctx.session_id,'exchange_id',p_ctx.exchange_id,'context_version_before',p_ctx.context_version,'context_version_after',p_ctx.context_version+1,'declaration_id',NULL,'report_id',NULL,'report_sha256',NULL,'values_written',false,'display_events',jsonb_build_array(combat_consumer_private.validate_display_event(jsonb_build_object('event_id',p_event,'event_kind','control_changed','actor_id',actor,'display_name',label->>'display_name','label_version',label->'label_version','target_actor_id',NULL,'target_display_name',NULL,'target_label_version',NULL,'summary',CASE WHEN p_offer.source_payload->>'aburame_operation'='sfera_staff_prepare' THEN 'Profilo Sfera d’Insetti pronto nella sola simulazione Staff.' WHEN p_offer.source_payload->>'aburame_operation'='verme_staff_prepare' THEN 'Profilo Insetto Verme Velenoso pronto nella sola simulazione Staff.' ELSE 'Liberazione dei Kikaichū interrotta.' END))));
 env:=jsonb_set(env,'{receipt}',receipt);
 INSERT INTO combat_consumer_private.request_receipts(principal_character_id,request_key,command_sha256,operation,event_id,viewer_envelope) VALUES(cid,key,prepared->>'command_sha256','control',p_event,env);
 RETURN public.combat_v2_event_complete(p_event,env);
END $function$;
CREATE OR REPLACE FUNCTION clan_aburame_private.commit_master_stop(p_command jsonb)
 RETURNS jsonb
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO ''
AS $function$
DECLARE p jsonb;uid uuid:=exam_regia_private.current_principal();key uuid;fp text;receipt_id uuid:=gen_random_uuid();
 prior combat_panel_private.request_receipts%ROWTYPE;o combat_panel_private.offers%ROWTYPE;c combat_panel_private.contexts%ROWTYPE;
 a public.combat_v2_actors%ROWTYPE;env jsonb;result jsonb;receipt jsonb;event jsonb;label text;
BEGIN
 IF uid IS NULL THEN RAISE EXCEPTION 'panel_authentication_required' USING ERRCODE='28000';END IF;
 p:=combat_panel_private.validate_command(p_command);key:=(p->>'request_key')::uuid;fp:=public.combat_v2_sha256(p);
 PERFORM pg_advisory_xact_lock(hashtextextended('panel-request:'||uid::text||':'||key::text,731));
 SELECT * INTO prior FROM combat_panel_private.request_receipts WHERE principal_user=uid AND request_key=key;
 IF FOUND THEN IF prior.command_fingerprint<>fp THEN RAISE EXCEPTION 'panel_request_key_conflict';END IF;RETURN jsonb_set(prior.viewer_envelope,'{receipt,replayed}','true',false);END IF;
 SELECT * INTO STRICT o FROM combat_panel_private.offers WHERE id=(p->>'offer_id')::uuid AND principal_user=uid AND kind='control' AND operation='control'
  AND source_payload->>'adapter'='master_v2' AND source_payload->>'dispatch'='aburame_control' FOR UPDATE;
 SELECT * INTO STRICT c FROM combat_panel_private.contexts WHERE id=o.context_id AND principal_user=uid;
 IF c.activity_kind<>'master_v2' OR c.location_id IS DISTINCT FROM (p->>'location_id')::uuid OR c.activity_id IS DISTINCT FROM (p->>'activity_id')::uuid THEN RAISE EXCEPTION 'panel_activity_scope_invalid';END IF;
 PERFORM public.combat_v2_lock_round(c.round_id);
 c:=combat_panel_private.owned_context(c.id,(p->>'context_version')::bigint);
 IF o.state<>'offered' OR o.context_version<>c.context_version OR jsonb_array_length(p->'selected_option_ids')<>0 OR jsonb_array_length(p->'inputs')<>0 THEN RAISE EXCEPTION 'panel_offer_not_available';END IF;
 SELECT * INTO STRICT a FROM public.combat_v2_actors WHERE id=o.actor_id AND session_id=c.activity_id
  AND exam_regia_private.actor_principal(id,controller_user)=uid AND state='attivo' FOR UPDATE;
 IF o.source_payload->>'aburame_operation' IN ('verme_staff_prepare','sfera_staff_prepare') THEN
  IF o.source_payload->>'aburame_operation'='sfera_staff_prepare' THEN result:=clan_aburame_private.sfera_staff_prepare_v1(a.id,key);
  ELSE result:=clan_aburame_private.verme_staff_prepare_v1(a.id,key);END IF;
  UPDATE combat_panel_private.offers SET state='revoked' WHERE context_id=c.id AND state='offered' AND id<>o.id;
  UPDATE combat_panel_private.contexts SET context_version=context_version+1
   WHERE id=c.id AND context_version=c.context_version RETURNING * INTO c;
  IF NOT FOUND THEN RAISE EXCEPTION 'aburame_prepare_context_stale';END IF;
 ELSIF o.source_payload->>'aburame_operation'='release_stop' THEN
  result:=clan_aburame_private.stop_release(a.id,(o.source_payload->>'source_id')::uuid);
 ELSE RAISE EXCEPTION 'aburame_master_operation_invalid'; END IF;
 env:=combat_panel_private.master_projection(c.location_id,a.id);
 SELECT value->>'display_name' INTO label FROM jsonb_array_elements(env->'actors') WHERE value->>'actor_id'=a.id::text;
 event:=jsonb_build_object('event_id',receipt_id,'event_kind','control_changed','actor_id',a.id,'display_name',label,'label_version',c.context_version,
  'target_actor_id',NULL,'target_display_name',NULL,'target_label_version',NULL,'summary',CASE WHEN o.source_payload->>'aburame_operation'='sfera_staff_prepare' THEN 'Profilo Sfera d’Insetti pronto nella sola simulazione Staff.' WHEN o.source_payload->>'aburame_operation'='verme_staff_prepare' THEN 'Profilo Insetto Verme Velenoso pronto nella sola simulazione Staff.' ELSE 'Liberazione dei Kikaichū interrotta' END);
 receipt:=jsonb_build_object('receipt_id',receipt_id,'request_key',key,'operation','control','replayed',false,'activity_id',c.activity_id,'round_id',c.round_id,
  'context_version_before',o.context_version,'context_version_after',env#>'{context,version}','declaration_id',NULL,'report_id',NULL,'values_written',false,'display_events',jsonb_build_array(event));
 env:=jsonb_set(env,'{receipt}',receipt);UPDATE combat_panel_private.offers SET state='consumed',consumed_request_key=key WHERE id=o.id;
 INSERT INTO combat_panel_private.request_receipts(principal_user,request_key,command_fingerprint,offer_id,event_id,viewer_envelope)
 VALUES(uid,key,fp,o.id,receipt_id,env);RETURN env;
END $function$;
CREATE OR REPLACE FUNCTION clan_aburame_private.consumer_options(p jsonb)
 RETURNS jsonb
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO ''
AS $function$
DECLARE actor uuid:=(p#>>'{viewer,actor_id}')::uuid;sid uuid:=(p#>>'{context,activity_id}')::uuid;ctx combat_consumer_private.activities%ROWTYPE;offers jsonb:=coalesce(p->'offers','[]');item jsonb;attack uuid;offer jsonb;instance uuid;cap jsonb;caps jsonb:='[]'::jsonb;s clan_aburame_private.combat_sources%ROWTYPE;
BEGIN
 IF actor IS NULL OR sid IS NULL OR p->>'status'<>'ready' THEN RETURN p;END IF;
 SELECT * INTO STRICT ctx FROM combat_consumer_private.activities WHERE session_id=sid;
 IF ctx.phase='action' AND ctx.turn_actor_id=actor THEN
  IF clan_aburame_private.sfera_prepare_offer_v1(actor) THEN
   offers:=offers||jsonb_build_array(combat_consumer_private.offer_exchange(sid,actor,NULL,(p#>>'{context,scene_version}')::integer,'control','Prepara Sfera d’Insetti · solo simulazione Staff',jsonb_build_object('aburame_operation','sfera_staff_prepare')));
  END IF;
  IF clan_aburame_private.sfera_meta_v1(actor,false) IS NOT NULL THEN
   FOR item IN SELECT value FROM jsonb_array_elements(coalesce(p->'actors','[]'))
    WHERE value->>'state'='active' AND clan_aburame_private.sfera_staff_target_v1(actor,(value->>'actor_id')::uuid)
   LOOP
    offers:=offers||jsonb_build_array(combat_consumer_private.offer_exchange(sid,actor,(item->>'actor_id')::uuid,(p#>>'{context,scene_version}')::integer,'declare','Sfera d’Insetti · 20 chakra · 15 Colonia',jsonb_build_object('intent',jsonb_build_object('kind','attacco','ability_source','clan','ability_id','07a93dee-a483-4a7b-b3e0-43146c2ce227','target_actor',item->>'actor_id'))));
   END LOOP;
  END IF;
  IF clan_aburame_private.sfera_prison_active_v1(sid,actor) THEN
   offers:=offers||jsonb_build_array(combat_consumer_private.offer_exchange(sid,actor,NULL,(p#>>'{context,scene_version}')::integer,'declare','Liberarsi dalla Sfera d’Insetti · azione principale',jsonb_build_object('intent',jsonb_build_object('kind','utilita','ability_source','clan','ability_id','07a93dee-a483-4a7b-b3e0-43146c2ce227'))));
  END IF;
  IF clan_aburame_private.verme_staff_scope_v1(actor) AND NOT EXISTS(SELECT 1 FROM clan_aburame_private.verme_staff_profiles_v1 WHERE actor_id=actor)
   AND NOT EXISTS(SELECT 1 FROM public.combat_v2_declarations d JOIN public.combat_v2_rounds r ON r.id=d.round_id WHERE r.session_id=sid AND d.actor_id=actor) THEN
   offers:=offers||jsonb_build_array(combat_consumer_private.offer_exchange(sid,actor,NULL,(p#>>'{context,scene_version}')::integer,'control','Prepara Insetto Verme Velenoso · solo simulazione Staff',jsonb_build_object('aburame_operation','verme_staff_prepare')));
  END IF;
  IF clan_aburame_private.verme_meta_v1(actor,false) IS NOT NULL THEN
   FOR item IN SELECT value FROM jsonb_array_elements(coalesce(p->'actors','[]')) WHERE value->>'actor_id'<>actor::text AND value->>'state'='active'
    AND combat_panel_private.target_geometry_valid(actor,(value->>'actor_id')::uuid,2) LOOP
    offers:=offers||jsonb_build_array(combat_consumer_private.offer_exchange(sid,actor,(item->>'actor_id')::uuid,(p#>>'{context,scene_version}')::integer,'declare','Insetto Verme Velenoso · 10 chakra · contatto',jsonb_build_object('intent',jsonb_build_object('kind','attacco','ability_source','clan','ability_id','2f06b6f8-341f-472b-be04-ad48fcf2c412','target_actor',item->>'actor_id'))));
   END LOOP;
  END IF;
  IF clan_aburame_private.actor_allowed(actor) THEN PERFORM clan_aburame_private.ensure_scope(actor);END IF;
  IF clan_aburame_private.actor_allowed(actor) AND clan_aburame_private.actor_has_technique(actor,'f5e9af24-70f1-49f6-a7ca-74f59256336e') THEN
   FOR item IN SELECT value FROM jsonb_array_elements(coalesce(p->'actors','[]')) WHERE value->>'actor_id'<>actor::text AND value->>'state'='active' AND coalesce((value->>'distance_from_viewer_m')::numeric,999)<=5 LOOP
    offers:=offers||jsonb_build_array(combat_consumer_private.offer_exchange(sid,actor,(item->>'actor_id')::uuid,(p#>>'{context,scene_version}')::integer,'declare','Liberazione dei Kikaichū',jsonb_build_object('intent',jsonb_build_object('kind','attacco','ability_source','clan','ability_id','f5e9af24-70f1-49f6-a7ca-74f59256336e','target_actor',item->>'actor_id'))));
   END LOOP;
  END IF;
  SELECT * INTO s FROM clan_aburame_private.combat_sources WHERE target_actor_id=actor AND source_kind='release' AND state='attached';
  IF s.id IS NOT NULL THEN offers:=offers||jsonb_build_array(combat_consumer_private.offer_exchange(sid,actor,NULL,(p#>>'{context,scene_version}')::integer,'declare','Liberarsi dallo sciame · azione principale · 0 chakra',jsonb_build_object('intent',jsonb_build_object('kind','utilita','ability_source','clan','ability_id','f5e9af24-70f1-49f6-a7ca-74f59256336e'))));END IF;
  FOR s IN SELECT * FROM clan_aburame_private.combat_sources WHERE owner_actor_id=actor AND source_kind='release' AND state='attached' LOOP
   offers:=offers||jsonb_build_array(combat_consumer_private.offer_exchange(sid,actor,NULL,(p#>>'{context,scene_version}')::integer,'control','Interrompi Liberazione dei Kikaichū · gratuito',jsonb_build_object('aburame_operation','release_stop','source_id',s.id)));
  END LOOP;
 END IF;
 IF ctx.phase='defense' AND clan_aburame_private.actor_allowed(actor) AND clan_aburame_private.actor_has_technique(actor,'b9195ceb-74de-4251-95af-fe5c1bdaf485') THEN
  IF EXISTS(
   SELECT 1 FROM combat_consumer_private.offers existing
   JOIN public.combat_v2_actors controlled ON controlled.character_id=existing.principal_character_id
   WHERE existing.session_id=sid AND existing.exchange_id=ctx.exchange_id
    AND existing.context_version=ctx.context_version
    AND existing.scene_version=(p#>>'{context,scene_version}')::bigint
    AND controlled.id=actor AND existing.state='offered'
    AND existing.source_payload->>'aburame_clone'='aburame-clone/1'
  ) THEN
   SELECT coalesce(jsonb_agg(existing.viewer_projection ORDER BY existing.created_at,existing.id),'[]'::jsonb)
   INTO offer
   FROM combat_consumer_private.offers existing
   JOIN public.combat_v2_actors controlled ON controlled.character_id=existing.principal_character_id
   WHERE existing.session_id=sid AND existing.exchange_id=ctx.exchange_id
    AND existing.context_version=ctx.context_version
    AND existing.scene_version=(p#>>'{context,scene_version}')::bigint
    AND controlled.id=actor AND existing.state='offered'
    AND existing.source_payload->>'aburame_clone'='aburame-clone/1';
   RETURN clan_aburame_private.consumer_projection(jsonb_set(p,'{offers}',offers||offer));
  END IF;
  SELECT i.instance_id INTO instance FROM combat_spatial.arena_instances i WHERE i.encounter_id=sid AND i.state='open';
  FOR attack IN SELECT d.id FROM public.combat_v2_declarations d WHERE d.round_id=ctx.exchange_id AND d.kind='attacco' AND d.target_actor_id=actor AND d.state='inviata' ORDER BY d.id LOOP
   IF NOT clan_aburame_private.compatible_attack(attack,actor) THEN CONTINUE;END IF;
   offer:=combat_consumer_private.offer_exchange(sid,actor,ctx.turn_actor_id,(p#>>'{context,scene_version}')::integer,'defend','Clone d''Insetti · resta in posizione',jsonb_build_object('aburame_clone','aburame-clone/1','attack_id',attack,'intent',jsonb_build_object('reaction','tecnica','ability_source','clan','ability_id','b9195ceb-74de-4251-95af-fe5c1bdaf485')));
   offers:=offers||jsonb_build_array(offer);
   IF combat_panel_private.movement_block_reason(actor) IS NULL THEN
    caps:=combat_spatial.movement_options(instance,actor,3);
    FOR cap IN
     SELECT DISTINCT ON (current_cap.end_x_m,current_cap.end_y_m) candidate.value
     FROM jsonb_array_elements(caps) candidate
     JOIN combat_spatial.movement_capabilities current_cap
      ON current_cap.capability_id=(candidate.value->>'option_id')::uuid
      AND current_cap.instance_id=instance AND current_cap.actor_id=actor AND current_cap.state='offered'
     ORDER BY current_cap.end_x_m,current_cap.end_y_m,
      CASE WHEN current_cap.choice_key LIKE 'pgmove:%' THEN 0 ELSE 1 END,current_cap.choice_key
    LOOP
     offer:=combat_consumer_private.offer_exchange(sid,actor,ctx.turn_actor_id,(p#>>'{context,scene_version}')::integer,'defend','Clone d''Insetti · riposiziona '||(cap->>'intent')||' di '||(cap->>'distance_m')||' m',jsonb_build_object('aburame_clone','aburame-clone/1','attack_id',attack,'movement_capability',cap->>'option_id','intent',jsonb_build_object('reaction','tecnica','ability_source','clan','ability_id','b9195ceb-74de-4251-95af-fe5c1bdaf485')));
     offers:=offers||jsonb_build_array(offer);
    END LOOP;
   END IF;
  END LOOP;
 END IF;
 RETURN clan_aburame_private.consumer_projection(jsonb_set(p,'{offers}',offers));
END $function$;
CREATE OR REPLACE FUNCTION clan_aburame_private.lifecycle()
 RETURNS trigger
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO ''
AS $function$
DECLARE s clan_aburame_private.combat_sources%ROWTYPE;session uuid;v_sfera uuid;
BEGIN
 IF TG_TABLE_NAME='combat_v2_sessions' THEN
  session:=NEW.id;
  IF NEW.closed_at IS NULL AND NEW.state NOT IN ('chiusa','annullata') THEN RETURN NEW;END IF;
 ELSIF TG_TABLE_NAME='combat_v2_actors' THEN
  session:=NEW.session_id;
  IF NEW.state='attivo' THEN RETURN NEW;END IF;
 ELSE RAISE EXCEPTION 'aburame_lifecycle_table_invalid';END IF;
  FOR s IN SELECT * FROM clan_aburame_private.combat_sources WHERE session_id=session AND state IN ('prepared','attached','resolved') AND
   (TG_TABLE_NAME='combat_v2_sessions' OR owner_actor_id=NEW.id OR target_actor_id=NEW.id) FOR UPDATE LOOP
   PERFORM clan_aburame_private.end_source(s.id,CASE WHEN TG_TABLE_NAME='combat_v2_sessions' THEN 'combat_end' ELSE 'actor_left' END,0);
  END LOOP;
 FOR v_sfera IN SELECT declaration_id FROM clan_aburame_private.sfera_sources_v1
  WHERE session_id=session AND state IN ('reserved','active')
    AND (TG_TABLE_NAME='combat_v2_sessions' OR actor_id=NEW.id OR target_actor_id=NEW.id)
  ORDER BY declaration_id
 LOOP
  PERFORM clan_aburame_private.sfera_end_v1(v_sfera,CASE WHEN TG_TABLE_NAME='combat_v2_sessions' THEN 'combat_end' ELSE 'actor_left' END);
 END LOOP;
 RETURN NEW;
END $function$;
CREATE OR REPLACE FUNCTION clan_aburame_private.master_offers(p_context uuid, p_expected bigint, p_view jsonb)
 RETURNS void
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO ''
AS $function$
DECLARE c combat_panel_private.contexts%ROWTYPE;a public.combat_v2_actors%ROWTYPE;item jsonb;pending jsonb;
 oid uuid;gid uuid;instance uuid;cap jsonb;s clan_aburame_private.combat_sources%ROWTYPE;
BEGIN
 c:=combat_panel_private.owned_context(p_context,p_expected);
 IF c.activity_kind<>'master_v2' OR c.command_actor_id IS NULL OR c.round_id IS NULL
  OR p_view#>>'{viewer,command_actor_id}' IS DISTINCT FROM c.command_actor_id::text THEN RETURN;END IF;
 SELECT * INTO STRICT a FROM public.combat_v2_actors WHERE id=c.command_actor_id AND session_id=c.activity_id
  AND exam_regia_private.actor_principal(id,controller_user)=exam_regia_private.current_principal();
 IF p_view#>>'{context,phase}'='action' AND combat_panel_private.human_duel_turn_allowed(c.round_id,a.id)
  AND NOT EXISTS(SELECT 1 FROM public.combat_v2_declarations WHERE round_id=c.round_id AND actor_id=a.id AND kind IN ('attacco','movimento','utilita','passa')) THEN
  IF clan_aburame_private.sfera_prepare_offer_v1(a.id) THEN
   PERFORM combat_panel_private.create_offer(c.id,c.context_version,'control','control','Prepara Sfera d’Insetti · solo simulazione Staff',false,
     jsonb_build_object('adapter','master_v2','dispatch','aburame_control','aburame_operation','sfera_staff_prepare'));
  END IF;
  IF clan_aburame_private.sfera_meta_v1(a.id,false) IS NOT NULL THEN
   FOR item IN SELECT value FROM jsonb_array_elements(coalesce(p_view->'actors','[]'))
    WHERE value->>'state'='active' AND clan_aburame_private.sfera_staff_target_v1(a.id,(value->>'actor_id')::uuid)
   LOOP
    oid:=combat_panel_private.create_offer(c.id,c.context_version,'action','declare','Sfera d’Insetti · 20 chakra · 15 Colonia',true,
     jsonb_build_object('adapter','master_v2','dispatch','action','kind','attacco','ability_source','clan','ability_id','07a93dee-a483-4a7b-b3e0-43146c2ce227'));
    gid:=combat_panel_private.add_group(oid,'Bersaglio','target','single',1,1);
    PERFORM combat_panel_private.add_choice(gid,item->>'display_name',jsonb_build_object('target_actor_id',item->'actor_id'));
   END LOOP;
  END IF;
  IF clan_aburame_private.sfera_prison_active_v1(c.activity_id,a.id) THEN
   PERFORM combat_panel_private.create_offer(c.id,c.context_version,'action','declare','Liberarsi dalla Sfera d’Insetti · azione principale',true,
    jsonb_build_object('adapter','master_v2','dispatch','action','kind','utilita','ability_source','clan','ability_id','07a93dee-a483-4a7b-b3e0-43146c2ce227'));
  END IF;
  IF clan_aburame_private.verme_staff_scope_v1(a.id) AND NOT EXISTS(SELECT 1 FROM clan_aburame_private.verme_staff_profiles_v1 WHERE actor_id=a.id)
   AND NOT EXISTS(SELECT 1 FROM public.combat_v2_declarations d JOIN public.combat_v2_rounds r ON r.id=d.round_id WHERE r.session_id=c.activity_id AND d.actor_id=a.id) THEN
   PERFORM combat_panel_private.create_offer(c.id,c.context_version,'control','control','Prepara Insetto Verme Velenoso · solo simulazione Staff',false,
    jsonb_build_object('adapter','master_v2','dispatch','aburame_control','aburame_operation','verme_staff_prepare','aburame_version','aburame-verme/1'));
  END IF;
  IF clan_aburame_private.verme_meta_v1(a.id,false) IS NOT NULL THEN
   FOR item IN SELECT value FROM jsonb_array_elements(coalesce(p_view->'actors','[]')) WHERE value->>'actor_id'<>a.id::text AND value->>'state'='active'
    AND combat_panel_private.target_geometry_valid(a.id,(value->>'actor_id')::uuid,2) LOOP
    oid:=combat_panel_private.create_offer(c.id,c.context_version,'action','declare','Insetto Verme Velenoso · 10 chakra · contatto',true,
     jsonb_build_object('adapter','master_v2','dispatch','action','kind','attacco','ability_source','clan','ability_id','2f06b6f8-341f-472b-be04-ad48fcf2c412','aburame_version','aburame-verme/1'));
    gid:=combat_panel_private.add_group(oid,'Bersaglio','target','single',1,1);
    PERFORM combat_panel_private.add_choice(gid,item->>'display_name',jsonb_build_object('target_actor_id',item->'actor_id'));
   END LOOP;
  END IF;
  IF clan_aburame_private.actor_allowed(a.id) THEN PERFORM clan_aburame_private.ensure_scope(a.id);END IF;
  IF clan_aburame_private.actor_allowed(a.id) AND clan_aburame_private.actor_has_technique(a.id,'f5e9af24-70f1-49f6-a7ca-74f59256336e') THEN
   FOR item IN SELECT value FROM jsonb_array_elements(coalesce(p_view->'actors','[]'))
    WHERE value->>'actor_id'<>a.id::text AND value->>'state'='active'
     AND combat_panel_private.target_geometry_valid(a.id,(value->>'actor_id')::uuid,5) LOOP
    oid:=combat_panel_private.create_offer(c.id,c.context_version,'action','declare','Liberazione dei Kikaichū · 5 chakra',true,
     jsonb_build_object('adapter','master_v2','dispatch','action','kind','attacco','ability_source','clan',
      'ability_id','f5e9af24-70f1-49f6-a7ca-74f59256336e','aburame_version','aburame-genin/1'));
    gid:=combat_panel_private.add_group(oid,'Bersaglio','target','single',1,1);
    PERFORM combat_panel_private.add_choice(gid,item->>'display_name',jsonb_build_object('target_actor_id',item->'actor_id'));
   END LOOP;
  END IF;
  SELECT * INTO s FROM clan_aburame_private.combat_sources WHERE target_actor_id=a.id AND source_kind='release' AND state='attached';
  IF s.id IS NOT NULL THEN
   PERFORM combat_panel_private.create_offer(c.id,c.context_version,'action','declare','Liberarsi dallo sciame · azione principale · 0 chakra',true,
    jsonb_build_object('adapter','master_v2','dispatch','action','kind','utilita','ability_source','clan',
     'ability_id','f5e9af24-70f1-49f6-a7ca-74f59256336e','aburame_escape',true,'aburame_version','aburame-genin/1'));
  END IF;
  FOR s IN SELECT * FROM clan_aburame_private.combat_sources WHERE owner_actor_id=a.id AND source_kind='release' AND state='attached' LOOP
   PERFORM combat_panel_private.create_offer(c.id,c.context_version,'control','control','Interrompi Liberazione dei Kikaichū · gratuito',false,
    jsonb_build_object('adapter','master_v2','dispatch','aburame_control','aburame_operation','release_stop','source_id',s.id,'aburame_version','aburame-genin/1'));
  END LOOP;
 END IF;
 IF p_view#>>'{context,phase}'='defense' AND clan_aburame_private.actor_allowed(a.id) AND clan_aburame_private.actor_has_technique(a.id,'b9195ceb-74de-4251-95af-fe5c1bdaf485')
  AND NOT EXISTS(SELECT 1 FROM public.combat_v2_declarations WHERE round_id=c.round_id AND actor_id=a.id AND kind IN ('difesa','nessuna')) THEN
  SELECT i.instance_id INTO instance FROM combat_spatial.arena_instances i WHERE i.encounter_id=c.activity_id AND i.context_source='panel_master' AND i.state='open';
  FOR pending IN SELECT value FROM jsonb_array_elements(coalesce((SELECT public.combat_v2_round_options(c.round_id,a.id)#>'{data,pending_attack_targets}'),'[]')) LOOP
   IF NOT clan_aburame_private.compatible_attack((pending->>'attack_declaration_id')::uuid,a.id) THEN CONTINUE;END IF;
   oid:=combat_panel_private.create_offer(c.id,c.context_version,'defense','defend','Clone d''Insetti · resta in posizione · 10 chakra',true,
    jsonb_build_object('adapter','master_v2','dispatch','defense','reaction','tecnica','mode','self','ability_source','clan',
     'ability_id','b9195ceb-74de-4251-95af-fe5c1bdaf485','aburame_clone','aburame-clone/1','attack_id',pending->'attack_declaration_id'));
   gid:=combat_panel_private.add_group(oid,'Copertura','coverage','single',1,1);
   PERFORM combat_panel_private.add_choice(gid,'Interponi il clone',jsonb_build_object('attack_target_id',pending->'attack_target_id','attack_declaration_id',pending->'attack_declaration_id'));
   IF combat_panel_private.movement_block_reason(a.id) IS NULL THEN
    FOR cap IN SELECT value FROM jsonb_array_elements(combat_spatial.movement_options(instance,a.id,3)) LOOP
     oid:=combat_panel_private.create_offer(c.id,c.context_version,'defense','defend','Clone d''Insetti · riposiziona '||(cap->>'intent')||' di '||(cap->>'distance_m')||' m · 10 chakra',true,
      jsonb_build_object('adapter','master_v2','dispatch','defense','reaction','tecnica','mode','self','ability_source','clan',
       'ability_id','b9195ceb-74de-4251-95af-fe5c1bdaf485','aburame_clone','aburame-clone/1','attack_id',pending->'attack_declaration_id',
       'movement_capability',cap->'option_id'));
     gid:=combat_panel_private.add_group(oid,'Copertura','coverage','single',1,1);
     PERFORM combat_panel_private.add_choice(gid,'Interponi il clone',jsonb_build_object('attack_target_id',pending->'attack_target_id','attack_declaration_id',pending->'attack_declaration_id'));
    END LOOP;
   END IF;
  END LOOP;
 END IF;
END $function$;
CREATE OR REPLACE FUNCTION combat_consumer_private.commit_exchange(p jsonb, prepared jsonb)
 RETURNS jsonb
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO ''
AS $function$
declare ctx combat_consumer_private.activities%rowtype; offer combat_consumer_private.offers%rowtype;
  aid uuid:=(prepared->>'actor_id')::uuid; cid uuid:=(prepared->>'principal_character_id')::uuid;
  key uuid:=(p->>'request_key')::uuid; event jsonb; event_id uuid; result jsonb; resolve_key uuid;
  suiton_profile jsonb; selection jsonb; multiplication_aim_valid boolean; declaration uuid; report public.combat_v2_round_reports%rowtype; envelope jsonb;
  label jsonb; target_label jsonb; target uuid; display_event jsonb; receipt jsonb; movement jsonb; round_phase text;
  fili_source text; fili_ability uuid; fili_meta jsonb; fili_range numeric; fili_current jsonb;
begin
  select * into ctx from combat_consumer_private.activities where session_id=(p->>'activity_id')::uuid for update;
  select * into offer from combat_consumer_private.offers where id=(p->>'offer_id')::uuid for update;
  if p->>'operation' not in ('declare','defend','control') then
    perform combat_consumer_private.fail('adapter_not_ready',key);
  end if;
  IF offer.source_payload#>>'{sabaku_flow,version}'='sabaku-flow/2' AND p->>'movement_offer_id' IS NOT NULL THEN RAISE EXCEPTION 'sabaku_flow_attached_movement_not_supported' USING ERRCODE='22023'; END IF;
  IF p->>'operation'='control' AND offer.source_payload->>'inuzuka_operation' IN ('bind','move','staff_profile','activate','deactivate') THEN
    RETURN clan_inuzuka_private.commit_control(p,prepared);
  END IF;
  IF p->>'operation'='control' AND offer.source_payload->>'akimichi_operation' IN ('activate','deactivate') THEN
    RETURN clan_akimichi_private.commit_ordinary_form(p,prepared);
  END IF;
  event:=public.combat_v2_event_begin(offer.id,key,'combat_consumer_'||(p->>'operation'),p);
  event_id:=(event->>'event_id')::uuid;
  IF p->>'operation'='control' THEN
    IF offer.source_payload->>'hoki_operation'='body_on' THEN
      RETURN clan_hoki_private.commit_ordinary_body(p,prepared,ctx,offer,event_id);
    END IF;
    IF offer.source_payload->>'aburame_operation' IN('release_stop','verme_staff_prepare','sfera_staff_prepare') THEN
      RETURN clan_aburame_private.commit_control(p,prepared,ctx,offer,event_id);
    END IF;
    PERFORM combat_consumer_private.fail('offer_not_available',key);
  END IF;
  IF offer.source_payload->>'akimichi_partial_offer'='akimichi-partial/1'
    AND public.combat_v2_actor_ability(aid,'clan','214af896-15f8-43e6-858b-614d2851dd3b'::uuid,false)
      ->>'akimichi_partial_contract' IS DISTINCT FROM 'akimichi-partial/1' THEN
    PERFORM combat_consumer_private.fail('offer_not_available',key);
  END IF;
  IF offer.source_payload->>'nara_offer'='nara-possession/1' AND (
    p->>'movement_offer_id' IS NOT NULL
    OR combat_panel_private.nara_offer_meta_v1(aid,false) IS NULL
  ) THEN
    PERFORM combat_consumer_private.fail('offer_not_available',key);
  END IF;
  IF offer.source_payload#>'{intent,target_fili}'='true'::jsonb THEN
    IF p->>'operation' IS DISTINCT FROM 'declare'
       OR offer.source_payload#>>'{intent,kind}' IS DISTINCT FROM 'attacco'
       OR p->>'movement_offer_id' IS NOT NULL
       OR jsonb_typeof(offer.source_payload->'fili_ocular_link') IS DISTINCT FROM 'object' THEN
      PERFORM combat_consumer_private.fail('offer_not_available',key);
    END IF;
    fili_source:=offer.source_payload#>>'{intent,ability_source}';
    fili_ability:=(offer.source_payload#>>'{intent,ability_id}')::uuid;
    fili_meta:=CASE WHEN fili_source='arma' THEN combat_panel_private.shuriken_available_v1(aid)
      ELSE public.combat_v2_actor_ability(aid,fili_source,fili_ability,false) END;
    fili_range:=clan_marionettisti_private.ocular_sever_attack_range_v1(aid,fili_source,fili_ability,fili_meta);
    IF fili_meta IS NULL OR fili_range IS NULL
       OR (fili_meta->>'elementali_profile_version'='elementali-genin/1' AND (
         offer.source_payload->'other_push_requested' IS DISTINCT FROM 'false'::jsonb
         OR combat_v2_elemental_internal.other_quote(aid,fili_ability) IS NULL
       )) THEN
      PERFORM combat_consumer_private.fail('offer_not_available',key);
    END IF;
    fili_current:=clan_marionettisti_private.ocular_sever_source_v1(
      ctx.exchange_id,aid,(offer.source_payload#>>'{intent,target_actor}')::uuid,fili_range);
    IF fili_current IS NULL OR fili_current IS DISTINCT FROM offer.source_payload->'fili_ocular_link' THEN
      PERFORM combat_consumer_private.fail('offer_not_available',key);
    END IF;
    PERFORM clan_marionettisti_private.ocular_sever_authorize_v1(
      ctx.exchange_id,aid,(offer.source_payload#>>'{intent,target_actor}')::uuid,fili_source,fili_ability,key);
  END IF;
  if p->>'movement_offer_id' is not null then
    movement:=combat_consumer_private.commit_movement(offer.id,(p->>'movement_offer_id')::uuid,aid,key);
  end if;
  if movement is not null AND EXISTS(SELECT 1 FROM combat_panel_private.movement_cost_receipts cost
      WHERE cost.event_id=(movement->>'event_id')::uuid AND clan_sabaku_private.clone_movement_interruption(cost.capability_id) IS NOT NULL) then
    perform clan_sabaku_private.clone_record_interrupted_movement((SELECT cost.capability_id FROM combat_panel_private.movement_cost_receipts cost WHERE cost.event_id=(movement->>'event_id')::uuid),ctx.exchange_id,aid);
    update combat_consumer_private.activities set context_version=context_version+1,last_action_at=clock_timestamp() where session_id=ctx.session_id;
    envelope:=combat_consumer_private.state_projection(ctx.location_id);
    label:=combat_consumer_private.display_label(ctx.session_id,aid,aid,null);
    display_event:=combat_consumer_private.validate_display_event(jsonb_build_object(
      'event_id',movement->'event_id','event_kind','movement','actor_id',aid,'display_name',label->>'display_name',
      'label_version',label->'label_version','target_actor_id',null,'target_display_name',null,'target_label_version',null,
      'summary','La presa interrompe lo spostamento. L’azione principale resta disponibile.'));
    receipt:=jsonb_build_object('receipt_id',event_id,'request_key',key,'operation',p->>'operation','replayed',false,
      'activity_id',ctx.session_id,'exchange_id',ctx.exchange_id,'context_version_before',ctx.context_version,
      'context_version_after',CASE WHEN ctx.user_test_context_id IS NOT NULL THEN (SELECT context_version FROM combat_consumer_private.activities WHERE session_id=ctx.session_id) ELSE ctx.context_version+1 END,'declaration_id',null,'report_id',null,'report_sha256',null,
      'values_written',false,'display_events',jsonb_build_array(display_event));
    envelope:=jsonb_set(envelope,'{receipt}',receipt);
    update combat_consumer_private.offers set state='consumed',consumed_request_key=key where id=offer.id;
    insert into combat_consumer_private.request_receipts(principal_character_id,request_key,command_sha256,operation,event_id,viewer_envelope)
      values(cid,key,prepared->>'command_sha256',p->>'operation',event_id,envelope);
    return public.combat_v2_event_complete(event_id,envelope);
  end if;
  IF offer.source_payload#>>'{intent,ability_source}'='clan' THEN
    suiton_profile:=coalesce(combat_v2_elemental_internal.suiton_profile(aid,(offer.source_payload#>>'{intent,ability_id}')::uuid),combat_v2_elemental_internal.other_profile(aid,(offer.source_payload#>>'{intent,ability_id}')::uuid));
  END IF;
  IF offer.source_payload ? 'fireball_selection' THEN
    offer.source_payload:=jsonb_set(offer.source_payload,'{intent}',clan_uchiha_private.fireball_prepare(ctx.exchange_id,aid,key,offer.source_payload->'fireball_selection'));
  END IF;
  if offer.source_payload?'multiplication_attack_target' then
    selection:=offer.source_payload->'multiplication_attack_target';
    if p->>'operation'<>'declare' or offer.source_payload#>>'{intent,kind}' is distinct from 'attacco'
      or not coalesce((offer.source_payload#>>'{intent,ability_source}'='mano'
        and coalesce(selection->>'attack_origin','actor')='actor'
        or offer.source_payload#>>'{intent,ability_source}'='clan'
        and offer.source_payload#>>'{intent,ability_id}'='e361f7c3-f90b-47ec-bfee-ccbda21257d9'
        and selection->>'attack_origin'='marionetta'
        or offer.source_payload#>>'{intent,ability_source}'='clan'
        and offer.source_payload#>>'{intent,ability_id}'='001f907c-8f32-4758-8a16-ad1730e72c59'
        and offer.source_payload#>>'{sabaku_flow,version}'='sabaku-flow/2'
        and coalesce(selection->>'attack_origin','actor')='actor'
        or suiton_profile IS NOT NULL and coalesce(selection->>'attack_origin','actor')='actor'),false)
      or selection->>'target_actor_id' is distinct from offer.source_payload#>>'{intent,target_actor}' then
      perform combat_consumer_private.fail('offer_not_available',key);end if;
    IF offer.source_payload#>>'{sabaku_flow,version}'='sabaku-flow/2' AND selection->>'selection_kind'='server_random' THEN
      PERFORM combat_panel_private.multiplication_prepare_selected_aims(ctx.exchange_id,aid,key,
        ARRAY[(selection->>'target_actor_id')::uuid],jsonb_build_object('groups',jsonb_build_array(
          jsonb_build_object('options',jsonb_build_array(jsonb_build_object('payload',
            jsonb_build_object('multiplication_attack_target',selection)))))));
    ELSE
    perform combat_panel_private.multiplication_prepare_attack_aim_for_source(ctx.exchange_id,aid,
      (selection->>'target_actor_id')::uuid,(selection->>'formation_id')::uuid,
      (selection->>'state_version')::bigint,(selection->>'figure_index')::integer,key,coalesce(selection->>'attack_origin'='marionetta',false));
    END IF;
    perform combat_panel_private.multiplication_bind_ordinary_draw(key,(selection->>'target_actor_id')::uuid,offer.id,(p->>'movement_offer_id')::uuid);
  end if;
  IF offer.source_payload#>>'{sabaku_flow,version}'='sabaku-flow/2' THEN
    IF p->>'operation'<>'declare' OR p->>'movement_offer_id' IS NOT NULL THEN
      RAISE EXCEPTION 'sabaku_flow_offer_invalid' USING ERRCODE='22023'; END IF;
    PERFORM clan_sabaku_private.flow_prepare(ctx.exchange_id,aid,key,offer.id,'consumer',
      offer.source_payload#>'{sabaku_flow,allocations}');
  END IF;
  IF offer.source_payload->>'aburame_clone'='aburame-clone/1' THEN
    IF p->>'operation'<>'defend' THEN PERFORM combat_consumer_private.fail('offer_not_available',key);END IF;
    PERFORM clan_aburame_private.clone_prepare(ctx.exchange_id,aid,(offer.source_payload->>'attack_id')::uuid,key,(offer.source_payload->>'movement_capability')::uuid);
  END IF;
  insert into combat_consumer_private.dispatch_authorizations
    values(key,ctx.exchange_id,cid,txid_current(),p->>'operation','prepared');
  if p->>'operation'='declare' then
    if fili_current IS NOT NULL THEN
      -- The existing declaration still verifies and spends the exact attack source.
      target:=(offer.source_payload#>>'{intent,target_actor}')::uuid;
    elsif offer.source_payload ? 'fireball_selection' THEN target:=(offer.source_payload#>>'{intent,target_actor}')::uuid;
    elsif offer.source_payload#>>'{intent,kind}'='attacco' AND offer.source_payload#>>'{intent,ability_source}'='arma' then
      -- The common declaration validates the projectile path, range and stock.
      target:=(offer.source_payload#>>'{intent,target_actor}')::uuid;
    elsif offer.source_payload#>>'{intent,kind}'='attacco' then
      target:=(offer.source_payload#>>'{intent,target_actor}')::uuid;
      multiplication_aim_valid:=combat_panel_private.multiplication_attack_aim_valid(ctx.exchange_id,aid,target,key,case when suiton_profile IS NOT NULL then (suiton_profile->>'range_m')::integer when offer.source_payload#>>'{intent,ability_source}'='clan'
        and offer.source_payload#>>'{intent,ability_id}'='e361f7c3-f90b-47ec-bfee-ccbda21257d9' then 3 WHEN offer.source_payload#>>'{sabaku_flow,version}'='sabaku-flow/2' THEN 15
        WHEN offer.source_payload#>>'{intent,ability_source}'='clan'
          AND offer.source_payload#>>'{intent,ability_id}'='214af896-15f8-43e6-858b-614d2851dd3b'
          AND offer.source_payload->>'akimichi_partial_offer'='akimichi-partial/1' THEN 3
        WHEN coalesce(offer.source_payload#>>'{intent,ability_source}','mano')='mano' THEN combat_panel_private.manual_contact_center_range(aid,target) else 2 end);
      IF offer.source_payload#>>'{sabaku_flow,version}'='sabaku-flow/2' THEN
        PERFORM clan_sabaku_private.flow_declaration_meta(ctx.exchange_id,aid,key,offer.source_payload->'intent');
      ELSIF offer.source_payload#>>'{intent,ability_source}'='clan'
       and offer.source_payload#>>'{intent,ability_id}'='e361f7c3-f90b-47ec-bfee-ccbda21257d9' then
        if not clan_marionettisti_private.owner_eligible(aid,true) then perform combat_consumer_private.fail('offer_not_available',key);end if;
        perform combat_panel_private.multiplication_companion_attack_source(ctx.exchange_id,aid,target,key,null);
      ELSIF offer.source_payload->>'nara_offer'='nara-possession/1' THEN
        -- The shared declaration computes and freezes the single segment.
        NULL;
      ELSIF offer.source_payload#>>'{intent,ability_source}'='clan'
        AND offer.source_payload#>>'{intent,ability_id}'='07a93dee-a483-4a7b-b3e0-43146c2ce227' THEN
        IF NOT clan_aburame_private.sfera_staff_target_v1(aid,target) THEN
          PERFORM combat_consumer_private.fail('offer_not_available',key);
        END IF;
      elsif multiplication_aim_valid is not null then
        if not multiplication_aim_valid then perform combat_consumer_private.fail('offer_not_available',key);end if;
      elsif suiton_profile IS NOT NULL then
        if not (CASE WHEN combat_v2_elemental_internal.other_profile(aid,(offer.source_payload#>>'{intent,ability_id}')::uuid) IS NOT NULL THEN combat_v2_elemental_internal.other_target_visible(aid,target,(suiton_profile->>'range_m')::numeric) ELSE combat_v2_elemental_internal.suiton_target_visible(aid,target,(suiton_profile->>'range_m')::numeric) END) then
          perform combat_consumer_private.fail('offer_not_available',key);end if;
      elsif offer.source_payload#>>'{intent,ability_source}'='clan'
       and offer.source_payload#>>'{intent,ability_id}'='f5e9af24-70f1-49f6-a7ca-74f59256336e' then
        if (combat_panel_private.has_master_geometry(ctx.session_id) and not combat_panel_private.target_geometry_valid(aid,target,5))
          or (not combat_panel_private.has_master_geometry(ctx.session_id) and
            abs((select position_m from public.combat_v2_actors where id=aid)-(select position_m from public.combat_v2_actors where id=target))>5) then
          perform combat_consumer_private.fail('offer_not_available',key);end if;
      elsif offer.source_payload#>>'{intent,ability_source}'='clan'
       AND offer.source_payload#>>'{intent,ability_id}'='214af896-15f8-43e6-858b-614d2851dd3b'
       AND offer.source_payload->>'akimichi_partial_offer'='akimichi-partial/1' then
        IF NOT clan_akimichi_private.partial_target_valid(aid,target) THEN
          PERFORM combat_consumer_private.fail('offer_not_available',key);
        END IF;
      elsif not combat_consumer_private.melee_eligible(ctx.session_id,aid,target) then
        perform combat_consumer_private.fail('offer_not_available',key);
      end if;
    elsif offer.source_payload#>>'{intent,kind}'='utilita' and offer.source_payload#>>'{intent,ability_id}'='f5e9af24-70f1-49f6-a7ca-74f59256336e' then null;
    ELSIF offer.source_payload#>>'{intent,kind}'='utilita'
      AND offer.source_payload#>>'{intent,ability_source}'='clan'
      AND offer.source_payload#>>'{intent,ability_id}'='07a93dee-a483-4a7b-b3e0-43146c2ce227' THEN
      PERFORM clan_aburame_private.sfera_escape_meta_v1(aid,offer.source_payload->'intent');
    elsif offer.source_payload#>>'{intent,kind}' is distinct from 'passa' then
      perform combat_consumer_private.fail('offer_not_available',key);
    end if;
    IF combat_v2_elemental_internal.suiton_profile(aid,(offer.source_payload#>>'{intent,ability_id}')::uuid) IS NOT NULL THEN
      PERFORM combat_v2_elemental_internal.suiton_prepare_callback('ordinary_v2',offer.id,aid,key,ARRAY[]::uuid[],'[]'::jsonb,offer.source_payload->'intent');
    END IF;
    IF combat_v2_elemental_internal.other_profile(aid,(offer.source_payload#>>'{intent,ability_id}')::uuid) IS NOT NULL THEN
      PERFORM combat_v2_elemental_internal.other_prepare_callback('ordinary_v2',offer.id,aid,key,ARRAY[]::uuid[],'[]'::jsonb,offer.source_payload->'intent');
    END IF;
    result:=public.combat_v2_action_declare(ctx.exchange_id,aid,offer.source_payload->'intent',p->>'narrative_text',key);
    declaration:=(result#>>'{data,declaration_id}')::uuid;
    round_phase:=result#>>'{data,phase}';
    update combat_consumer_private.activities set phase=case round_phase when 'raccolta_azioni' then 'action' when 'raccolta_difese' then 'defense' else phase end where session_id=ctx.session_id;
  else
    IF (offer.source_payload->>'flow_substitution'='flow-substitution/1' OR offer.source_payload->>'suiton_substitution'='suiton-substitution/1' OR offer.source_payload->>'other_substitution'='other-substitution/1' OR offer.source_payload->>'fireball_substitution'='fireball-substitution/1') THEN
      IF offer.source_payload#>>'{intent,reaction}' IS DISTINCT FROM 'sostituzione'
       OR NOT EXISTS(SELECT 1 FROM combat_spatial.substitution_activity_options so
         JOIN combat_spatial.substitution_activity_links sl ON sl.link_id=so.link_id
         JOIN combat_spatial.substitution_capabilities sc ON sc.capability_id=so.capability_id
         JOIN public.combat_v2_actors sa ON sa.id=sl.defender_actor_id AND sa.session_id=sl.activity_session_id
         JOIN public.combat_v2_declarations sd ON sd.id=sl.attack_declaration_id AND sd.round_id=sl.activity_round_id
         WHERE so.capability_id=(offer.source_payload->>'substitution_option_id')::uuid
          AND so.state='offered' AND sl.state='offered' AND sc.state='offered'
          AND sl.activity_kind='combat_v2' AND sl.activity_session_id=ctx.session_id
          AND sl.activity_round_id=ctx.exchange_id AND sl.attack_declaration_id=(offer.source_payload->>'attack_id')::uuid
          AND sl.defender_actor_id=aid AND sa.controller_user=auth.uid()
          AND sa.controller_version=sl.activity_version AND sd.kind='attacco'
          AND ((offer.source_payload->>'flow_substitution'='flow-substitution/1' AND sd.sanitized_intent#>>'{server_ability,sabaku_flow_version}'='sabaku-flow/2') OR (offer.source_payload->>'suiton_substitution'='suiton-substitution/1' AND combat_v2_elemental_internal.suiton_substitution_available(sd.id)) OR (offer.source_payload->>'other_substitution'='other-substitution/1' AND combat_v2_elemental_internal.other_substitution_available(sd.id)) OR (offer.source_payload->>'fireball_substitution'='fireball-substitution/1' AND sd.target_actor_id=aid AND clan_uchiha_private.fireball_source_valid(sd.id)))) THEN
        perform combat_consumer_private.fail('offer_not_available',key);
      END IF;
      PERFORM clan_marionettisti_private.assert_jutsu_source(aid,'jutsu','31b15861-fb78-4f8a-ac1c-ebf2d957c32e');
      result:=public.combat_v2_substitution_select_v1((offer.source_payload->>'substitution_option_id')::uuid,key);
      declaration:=(result->>'defense_declaration_id')::uuid;
      UPDATE public.combat_v2_declarations SET declaration_text=p->>'narrative_text'
       WHERE id=declaration AND round_id=ctx.exchange_id AND actor_id=aid AND request_key=key
        AND parent_attack_id=(offer.source_payload->>'attack_id')::uuid
        AND controller_user_snapshot=auth.uid() AND state='inviata' AND declaration_text='';
      IF NOT FOUND THEN RAISE EXCEPTION 'flow_substitution_declaration_binding_invalid' USING ERRCODE='40001'; END IF;
    ELSE
      IF offer.source_payload#>>'{intent,ability_id}'='58a2f5cd-6409-40f6-8f18-cfdb4410ca26' THEN
        PERFORM clan_hyuga_private.rotation_prepare(ctx.exchange_id,aid,(offer.source_payload->>'attack_id')::uuid,key,(offer.source_payload->>'rotation_radius_m')::integer);
      END IF;
      if offer.source_payload#>>'{intent,reaction}' not in ('schivata','parata','nessuna')
       AND NOT coalesce((offer.source_payload#>>'{intent,reaction}'='tecnica' AND offer.source_payload#>>'{intent,ability_source}'='clan'
        AND (offer.source_payload#>>'{intent,ability_id}'='58a2f5cd-6409-40f6-8f18-cfdb4410ca26'
         OR (offer.source_payload#>>'{intent,ability_id}'='9061c022-ca82-4d2b-8102-e208fcc6c1a2' AND combat_v2_elemental_internal.scudo_profile(aid) IS NOT NULL)
         OR (offer.source_payload#>>'{intent,ability_id}'='b9195ceb-74de-4251-95af-fe5c1bdaf485'
          AND offer.source_payload->>'aburame_clone'='aburame-clone/1'
          AND EXISTS(SELECT 1 FROM clan_aburame_private.clone_preparations cp
           WHERE cp.request_key=key AND cp.round_id=ctx.exchange_id AND cp.actor_id=aid
            AND cp.attack_id=(offer.source_payload->>'attack_id')::uuid
            AND cp.movement_capability IS NOT DISTINCT FROM (offer.source_payload->>'movement_capability')::uuid
            AND NOT cp.consumed)))),false) then
        perform combat_consumer_private.fail('offer_not_available',key);
      end if;
      result:=public.combat_v2_defense_declare(ctx.exchange_id,(offer.source_payload->>'attack_id')::uuid,
        aid,offer.source_payload->'intent',p->>'narrative_text',key);
      declaration:=(result#>>'{data,defense_id}')::uuid;
    END IF;
    target:=ctx.turn_actor_id;
  end if;
  update combat_consumer_private.dispatch_authorizations set state='consumed'
    where request_key=key and round_id=ctx.exchange_id and operation=p->>'operation';
  -- La fase deriva dai bersagli reali: ogni azione senza attacco cede iniziativa senza difesa fittizia.
  select phase into strict round_phase from public.combat_v2_rounds where id=ctx.exchange_id;
  if (p->>'operation'='defend' AND combat_v2_multitarget_internal.round_complete(ctx.exchange_id)) or round_phase='risoluzione' or offer.source_payload#>>'{intent,kind}'='utilita' then
    resolve_key:=gen_random_uuid();
    insert into combat_consumer_private.dispatch_authorizations
      values(resolve_key,ctx.exchange_id,cid,txid_current(),'resolve','prepared');
    perform public.combat_v2_round_resolve(ctx.exchange_id,resolve_key);
    update combat_consumer_private.dispatch_authorizations set state='consumed'
      where request_key=resolve_key and round_id=ctx.exchange_id and operation='resolve';
    select * into report from public.combat_v2_round_reports where round_id=ctx.exchange_id;
    update combat_consumer_private.activities set phase='resolved' where session_id=ctx.session_id;
  end if;
  IF ctx.user_test_context_id IS NOT NULL THEN
    PERFORM user_testroom_common_private.record_role(ctx.session_id,declaration,key,p->>'narrative_text');
    PERFORM user_testroom_common_private.drive_dummy(ctx.session_id,ctx.exchange_id,key);
    SELECT * INTO report FROM public.combat_v2_round_reports WHERE round_id=ctx.exchange_id;
    IF report.id IS NOT NULL THEN PERFORM user_testroom_common_private.publish_and_advance(ctx.session_id,ctx.exchange_id);END IF;
  ELSIF ctx.location_id=combat_panel_private.shuriken_qa_location_v1() THEN
    PERFORM combat_panel_private.shuriken_qa_write_message_v1(declaration);
  ELSE
    perform combat_consumer_private.record_message(declaration,
      public.post_message(ctx.location_id,p->>'narrative_text',null,null,null));
  END IF;
  update combat_consumer_private.activities set context_version=context_version+1,last_action_at=clock_timestamp()
    where session_id=ctx.session_id;
  envelope:=combat_consumer_private.state_projection(ctx.location_id);
  label:=combat_consumer_private.display_label(ctx.session_id,aid,aid,null);
  if target is not null then target_label:=combat_consumer_private.display_label(ctx.session_id,target,aid,null); end if;
  display_event:=combat_consumer_private.validate_display_event(jsonb_build_object(
    'event_id',event_id,'event_kind',case when p->>'operation'='declare' then 'action_declared' else 'defense_resolved' end,
    'actor_id',aid,'display_name',label->>'display_name','label_version',label->'label_version',
    'target_actor_id',target,'target_display_name',target_label->>'display_name','target_label_version',target_label->'label_version',
    'summary',(label->>'display_name')||': '||(offer.viewer_projection->>'label')||'.'));
  receipt:=jsonb_build_object('receipt_id',event_id,'request_key',key,'operation',p->>'operation','replayed',false,
    'activity_id',ctx.session_id,'exchange_id',ctx.exchange_id,'context_version_before',ctx.context_version,
    'context_version_after',CASE WHEN ctx.user_test_context_id IS NOT NULL THEN (SELECT context_version FROM combat_consumer_private.activities WHERE session_id=ctx.session_id) ELSE ctx.context_version+1 END,'declaration_id',declaration,'report_id',report.id,
    'report_sha256',report.mechanics_sha256,'values_written',coalesce(report.values_written,false),
    'display_events',jsonb_build_array(display_event));
  if movement is not null then
    receipt:=jsonb_set(receipt,'{display_events}',jsonb_build_array(combat_consumer_private.validate_display_event(
      jsonb_build_object('event_id',movement->'event_id','event_kind','movement','actor_id',aid,
        'display_name',label->>'display_name','label_version',label->'label_version',
        'target_actor_id',null,'target_display_name',null,'target_label_version',null,
        'summary',(label->>'display_name')||' si sposta di '||(movement->>'d_eff_m')||' m.')))||(receipt->'display_events'));
  end if;
  envelope:=jsonb_set(envelope,'{receipt}',receipt);
  update combat_consumer_private.offers set state='consumed',consumed_request_key=key where id=offer.id;
  insert into combat_consumer_private.request_receipts(principal_character_id,request_key,command_sha256,operation,event_id,viewer_envelope)
    values(cid,key,prepared->>'command_sha256',p->>'operation',event_id,envelope);
  return public.combat_v2_event_complete(event_id,envelope);
end $function$;
CREATE OR REPLACE FUNCTION combat_effects_private.lifecycle_open(p_session uuid, p_actor uuid)
 RETURNS void
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO ''
AS $function$
DECLARE c jsonb; pending_effect boolean;
BEGIN
 PERFORM clan_aburame_private.sfera_upkeep_turn_v1(p_session,p_actor);
 IF EXISTS(SELECT 1 FROM clan_aburame_private.verme_poison_v1 p WHERE p.session_id=p_session AND p.target_actor_id=p_actor AND p.remaining_turns>0) THEN
  c:=combat_effects_private.personal_turn(p_session,p_actor);
  IF c->>'adapter' IS DISTINCT FROM 'master_v2' OR combat_panel_private.human_duel_turn_allowed((c->>'round_id')::uuid,p_actor) THEN
   PERFORM clan_aburame_private.verme_tick_v1(p_session,p_actor,(c->>'turn_id')::uuid,c->>'adapter');
  END IF;
 END IF;
 IF EXISTS(SELECT 1 FROM clan_hoki_private.minor_poison p
   WHERE p.session_id=p_session AND p.target_actor_id=p_actor AND p.remaining_turns>0) THEN
  c:=combat_effects_private.personal_turn(p_session,p_actor);
  IF c->>'adapter' IS DISTINCT FROM 'master_v2'
     OR combat_panel_private.human_duel_turn_allowed((c->>'round_id')::uuid,p_actor) THEN
    PERFORM clan_hoki_private.tick_poison(p_session,p_actor,(c->>'turn_id')::uuid,c->>'adapter');
  END IF;
 END IF;
 IF EXISTS(SELECT 1 FROM clan_hoki_private.body_states b JOIN public.combat_v2_actors a ON a.id=b.actor_id
   WHERE b.session_id=p_session AND b.actor_id=p_actor AND b.ended_at IS NULL AND a.state='attivo') THEN
  c:=combat_effects_private.personal_turn(p_session,p_actor);
  IF c->>'adapter' IS DISTINCT FROM 'master_v2'
     OR combat_panel_private.human_duel_turn_allowed((c->>'round_id')::uuid,p_actor) THEN
    PERFORM clan_hoki_private.body_turn_start(p_session,p_actor,(c->>'turn_id')::uuid,c->>'adapter');
  END IF;
 END IF;
 IF EXISTS(SELECT 1 FROM combat_panel_private.nara_strangle_sources_v1 WHERE session_id=p_session AND actor_id=p_actor AND state='active')THEN
  c:=combat_effects_private.personal_turn(p_session,p_actor);
  IF c->>'useful'='true'AND c->>'is_current'='true'AND(c->>'adapter'<>'master_v2'OR combat_panel_private.human_duel_turn_allowed((c->>'round_id')::uuid,p_actor))THEN
   PERFORM combat_panel_private.nara_strangle_turn_v1(p_session,p_actor,(c->>'turn_id')::uuid,c->>'adapter');
   IF c->>'adapter'='master_v2'AND combat_panel_private.nara_strangle_terminal_report_v1((c->>'round_id')::uuid)THEN RETURN;END IF;
  END IF;
 END IF;
 c:=combat_effects_private.personal_turn(p_session,p_actor);
 IF c->>'adapter'='master_v2'AND combat_panel_private.nara_strangle_terminal_report_v1((c->>'round_id')::uuid)THEN RETURN;END IF;
 PERFORM combat_panel_private.nara_release_unfunded_v1(p_session,p_actor);
 -- Nessuna apertura/gate e nessun turno nuovo: si osserva il turno già creato nativamente.
  PERFORM combat_v2_genjutsu_internal.open_turn(p_session,p_actor);
 pending_effect:=EXISTS(SELECT 1 FROM combat_effects_private.effect_applications
  WHERE session_id=p_session AND target_actor_id=p_actor AND state='pending');
 IF NOT pending_effect AND NOT EXISTS(SELECT 1 FROM clan_akimichi_private.forms
    WHERE session_id=p_session AND actor_id=p_actor AND active) THEN RETURN;END IF;
 PERFORM combat_effects_private.lock_context(p_session);
 PERFORM 1 FROM public.combat_v2_actors WHERE id=p_actor AND session_id=p_session AND state='attivo' FOR UPDATE;
 IF NOT FOUND THEN RETURN;END IF;
 c:=combat_effects_private.personal_turn(p_session,p_actor);
 IF c->>'useful' IS DISTINCT FROM 'true' OR c->>'is_current' IS DISTINCT FROM 'true' THEN
  IF pending_effect THEN RAISE EXCEPTION 'effects_open_native_window_required'; END IF;
  RETURN;
 END IF;
 PERFORM combat_effects_private.personal_turn_start(p_session,p_actor,(c->>'turn_id')::uuid,c->>'adapter');
END $function$;
CREATE OR REPLACE FUNCTION combat_panel_private.consumer_commit_authoritative(p_command jsonb)
 RETURNS jsonb
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO ''
AS $function$
declare prepared jsonb; p jsonb; offer combat_consumer_private.offers%rowtype;
  prof combat_consumer_private.scene_profiles%rowtype;
  inv combat_consumer_private.invitations%rowtype;
  cid uuid; other public.characters%rowtype; key uuid; loc uuid; sid uuid;
  event jsonb; event_id uuid; envelope jsonb; receipt jsonb; before_version bigint;
begin
  prepared:=combat_consumer_private.prepare_command(p_command);
  if (prepared->>'replayed')::boolean then return prepared->'envelope'; end if;
  p:=p_command; cid:=(prepared->>'principal_character_id')::uuid;
  if p->>'operation'='control' then
    if exists(
      select 1 from combat_consumer_private.offers hoki_offer
      where hoki_offer.id=(p->>'offer_id')::uuid
        and hoki_offer.operation='control'
        and (hoki_offer.source_payload->>'hoki_operation'='body_on'
          or hoki_offer.source_payload->>'akimichi_operation' in ('activate','deactivate'))
    ) then
      return combat_consumer_private.commit_exchange(p,prepared);
    end if;
    if exists(
      select 1 from combat_consumer_private.offers inuzuka_offer
      where inuzuka_offer.id=(p->>'offer_id')::uuid
        and inuzuka_offer.operation='control'
        and inuzuka_offer.source_payload->>'inuzuka_operation' in ('bind','move','staff_profile','activate','deactivate')
    ) then
      return combat_consumer_private.commit_exchange(p,prepared);
    end if;
    if exists(
      select 1 from combat_consumer_private.offers stop_offer
      where stop_offer.id=(p->>'offer_id')::uuid
        and stop_offer.operation='control'
        and stop_offer.source_payload->>'aburame_operation' IN('release_stop','verme_staff_prepare','sfera_staff_prepare')
    ) then
      return combat_consumer_private.commit_exchange(p,prepared);
    end if;
    if exists(select 1 from combat_consumer_private.offers where id=(p->>'offer_id')::uuid and source_payload->>'scudo_operation'='staff_profile') then
      return combat_v2_elemental_internal.scudo_commit_control(p,prepared);end if;
    if exists(select 1 from combat_consumer_private.offers where id=(p->>'offer_id')::uuid and source_payload->>'suiton_operation'='staff_profile') then
      return combat_v2_elemental_internal.suiton_commit_control(p,prepared);end if;
    if exists(select 1 from combat_consumer_private.offers where id=(p->>'offer_id')::uuid and source_payload->>'other_operation'='staff_profile') then
      return combat_v2_elemental_internal.other_commit_control(p,prepared);end if;
    return clan_marionettisti_private.commit_control(p,prepared);end if;
  if p->>'operation' in ('declare','defend') then
    return combat_consumer_private.commit_exchange(p,prepared);
  end if;
  key:=(p->>'request_key')::uuid; loc:=(p->>'location_id')::uuid;
  before_version:=(p->>'context_version')::bigint;
  select * into offer from combat_consumer_private.offers where id=(p->>'offer_id')::uuid for update;
  if p->>'operation'='close' and offer.session_id is not null then
    return combat_consumer_private.commit_close(p,prepared);
  end if;
  if p->>'operation' not in ('open','join','close') or
    (p->>'operation'='close' and offer.invitation_id is null) then
    perform combat_consumer_private.fail('adapter_not_ready',key);
  end if;
  perform 1 from public.locations where id=loc for update;
  event:=public.combat_v2_event_begin(offer.id,key,'combat_consumer_'||(p->>'operation'),p);
  event_id:=(event->>'event_id')::uuid;
  if p->>'operation'='open' then
    envelope:=combat_consumer_private.opening_state(loc);
    if envelope->>'status'<>'ready' or envelope#>>'{context,activity_id}' is not null then
      perform combat_consumer_private.fail('offer_not_available',key);
    end if;
    select * into prof from combat_consumer_private.scene_profiles
      where id=(offer.source_payload->>'scene_profile_id')::uuid and location_id=loc and enabled for share;
    if prof.id is null or prof.geometry_sha256 is distinct from offer.source_payload->>'geometry_sha256'
      or prof.producer_version<>offer.scene_version or prof.geometry_sha256 is distinct from
        combat_consumer_private.scene_fingerprint(prof.template_key,prof.template_version) then
      perform combat_consumer_private.fail('context_stale',key);
    end if;
    perform 1 from public.characters where id in (cid,(offer.source_payload->>'recipient_character_id')::uuid)
      order by id for update;
    select * into other from public.characters where id=(offer.source_payload->>'recipient_character_id')::uuid;
    if not combat_consumer_private.runtime_allowed(loc,other.user_id)
      or other.id is null or other.id=cid or coalesce(other.vita,0)<=0
      or public._personaggio_impegnato_meccanicamente(cid)
      or public._personaggio_impegnato_meccanicamente(other.id) then
      perform combat_consumer_private.fail('not_participant',key);
    end if;
    if not public._combat_presente(auth.uid(),loc) or not public._combat_presente(other.user_id,loc) then
      perform combat_consumer_private.fail('presence_required',key);
    end if;
    if exists(select 1 from combat_consumer_private.invitations where state='pending'
      and (opener_character_id in (cid,other.id) or recipient_character_id in (cid,other.id)))
      or exists(select 1 from public.combat_sfide where state='pendente'
        and (sfidante_char in (cid,other.id) or bersaglio_char in (cid,other.id))) then
      perform combat_consumer_private.fail('offer_not_available',key);
    end if;
    insert into combat_consumer_private.invitations(location_id,scene_profile_id,opener_character_id,
      recipient_character_id,open_request_key,geometry_sha256,scene_version)
      values(loc,prof.id,cid,other.id,key,prof.geometry_sha256,prof.producer_version) returning * into inv;
    sid:=inv.id;
    envelope:=combat_consumer_private.opening_state(loc);
  elsif p->>'operation'='join' then
    sid:=combat_consumer_private.accept_invitation(offer.invitation_id,key);
    envelope:=combat_consumer_private.state_projection(loc);
    if envelope->>'status'<>'ready' then
      perform combat_consumer_private.fail('adapter_not_ready',key);
    end if;
  else
    select * into inv from combat_consumer_private.invitations where id=offer.invitation_id for update;
    update combat_consumer_private.invitations set state='closed',decided_at=clock_timestamp(),
      context_version=context_version+1 where id=inv.id;
    sid:=inv.id;
    envelope:=jsonb_build_object('schema_version','combat-consumer/1','status','ready','reason_code',null,
      'context',jsonb_build_object('activity_kind','ordinary_v2','activity_id',sid,'exchange_id',null,
        'round_no',1,'phase','closed','version',inv.context_version+1,'scene_version',inv.scene_version,
        'policy_id',case when (select is_test from public.locations where id=loc) then
          'staff_test_no_persistent_resources_v1' else 'free_duel_nonlethal_real_resources_v1' end),
      'viewer',jsonb_build_object('actor_id',null,'can_command',false),
      'actors','[]'::jsonb,'offers','[]'::jsonb,'receipt',null);
  end if;
  -- Nessuna interpretazione meccanica della prosa: tecnica/compagno null,
  -- nessuna sessione legacy aperta. Controlli editoriali esistenti conservati.
  if length(btrim(p->>'narrative_text'))>0 then
    perform public.post_message(loc,p->>'narrative_text',null,null,null);
  end if;
  receipt:=jsonb_build_object('receipt_id',event_id,'request_key',key,'operation',p->>'operation',
    'replayed',false,'activity_id',sid,'exchange_id',envelope#>'{context,exchange_id}',
    'context_version_before',before_version,'context_version_after',envelope#>'{context,version}',
    'declaration_id',null,'report_id',null,'report_sha256',null,'values_written',false,'display_events','[]'::jsonb);
  envelope:=jsonb_set(envelope,'{receipt}',receipt);
  update combat_consumer_private.offers set state='consumed',consumed_request_key=key where id=offer.id;
  insert into combat_consumer_private.request_receipts(principal_character_id,request_key,
    command_sha256,operation,event_id,viewer_envelope)
    values(cid,key,prepared->>'command_sha256',p->>'operation',event_id,envelope);
  return public.combat_v2_event_complete(event_id,envelope);
end $function$;
CREATE OR REPLACE FUNCTION combat_panel_private.movement_block_reason(p_body uuid)
 RETURNS text
 LANGUAGE plpgsql
 STABLE SECURITY DEFINER
 SET search_path TO ''
AS $function$
DECLARE a public.combat_v2_actors%ROWTYPE; mobility jsonb;
BEGIN
 SELECT * INTO STRICT a FROM public.combat_v2_actors WHERE id=p_body;
 IF a.state<>'attivo' OR coalesce((a.mechanics_snapshot->>'vita')::numeric,0)<=0 THEN
   RETURN 'actor_inoperative'; END IF;
 IF EXISTS(SELECT 1 FROM public.combat_v2_rounds r WHERE r.session_id=a.session_id
  AND r.phase IN('raccolta_azioni','raccolta_difese','congelato','risoluzione')
  AND combat_panel_private.cure_turn_used_v1(r.id,a.id)) THEN RETURN 'healing_turn';END IF;
 IF combat_panel_private.immobilization_active(a.id) THEN RETURN 'immobilized'; END IF;
 IF combat_v2_genjutsu_internal.movement_blocked(a.id) THEN RETURN 'genjutsu_movement_blocked';END IF;
 IF clan_aburame_private.sfera_prison_active_v1(a.session_id,a.id) THEN RETURN 'aburame_sfera_prison';END IF;
 IF a.mechanics_snapshot ? 'mobility' THEN
   mobility:=a.mechanics_snapshot->'mobility';
   IF jsonb_typeof(mobility) IS DISTINCT FROM 'object'
     OR mobility->>'schema_version' IS DISTINCT FROM 'combat-mobility/1'
     OR jsonb_typeof(mobility->'immobilized') IS DISTINCT FROM 'boolean'
     OR mobility-ARRAY['schema_version','immobilized'] IS DISTINCT FROM '{}'::jsonb THEN
     RAISE EXCEPTION 'panel_mobility_snapshot_invalid' USING ERRCODE='22023'; END IF;
   IF (mobility->>'immobilized')::boolean THEN RETURN 'immobilized'; END IF;
 END IF;
 RETURN NULL;
END $function$;
CREATE OR REPLACE FUNCTION public.combat_v2_action_declare(p_round uuid, p_actor uuid, p_intent jsonb, p_text text, p_request_key uuid)
 RETURNS jsonb
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO ''
AS $function$
declare v_uid uuid:=exam_regia_private.current_principal(); v_service boolean:=false; v_service_actor uuid; v_r public.combat_v2_rounds%rowtype; v_a public.combat_v2_actors%rowtype; v_t public.combat_v2_actors%rowtype;
  fireball clan_uchiha_private.fireball_preparations%ROWTYPE; clone_meta jsonb; escape_meta jsonb; aburame_meta jsonb;  multiplication_aim_valid boolean; multiplication_meta jsonb; v_i jsonb; v_kind text; v_target uuid; v_source text; v_ability uuid; v_meta jsonb; v_cost int:=0; v_base int:=10;
  cure_meta jsonb;
    genjutsu_release_meta jsonb;
  v_nara_native boolean := false;
  v_nara_public_enabled boolean;
  v_nara_public_activated_at timestamptz;
  v_has_fili boolean;
  v_fili_range numeric;
  v_fili_source jsonb;
  v_event jsonb; v_event_id uuid; v_id uuid; v_result jsonb; v_resolution jsonb; v_phase text; v_resolution_key uuid; v_max_range int;
begin
  if v_uid is null then delete from mission_exchange_combat_owner.service_action_permits p where p.request_key=p_request_key and p.round_id=p_round and p.actor_id=p_actor and p.intent_sha256=encode(extensions.digest(convert_to(p_intent::text,'UTF8'),'sha256'),'hex') returning true,p.persona_authority_id into v_service,v_service_actor;if not coalesce(v_service,false)then perform public.combat_v2_fail('autenticazione_richiesta','Autenticazione richiesta.',401,p_request_key,'{}');end if;end if;
  perform public.combat_v2_lock_round(p_round);
  perform exam_regia_private.assert_actor_dispatch(p_round,p_actor,p_request_key);
  select * into v_r from public.combat_v2_rounds where id=p_round for update;
  select * into v_a from public.combat_v2_actors where id=p_actor for update;
  if v_a.companion_id is not null then perform public.combat_v2_fail('compagno_senza_turno','Il compagno non dichiara azioni autonome.',409,p_request_key,'{}'); end if;
  perform combat_consumer_private.assert_dispatch(p_round,p_request_key,'declare');
  perform public.combat_v2_assert_operational(p_round,p_request_key,false);
  if exists(select 1 from mission_declaration_owner.gates g where g.round_id=p_round)then delete from mission_declaration_owner.submit_permits x where x.request_key=p_request_key and x.round_id=p_round and x.actor_id=p_actor;if not found then perform public.combat_v2_fail('porta_dichiarazione_richiesta','Usare la porta missione.',409,p_request_key,'{}');end if;end if;
  if v_r.id is null or v_a.id is null or v_a.session_id<>v_r.session_id then perform public.combat_v2_fail('sessione_inesistente','Round o attore inesistente.',404,p_request_key,'{}'); end if;
  if v_r.phase<>'raccolta_azioni' then perform public.combat_v2_fail('fase_non_valida','Il round non raccoglie azioni.',409,p_request_key,'{}'); end if;
  if not combat_panel_private.human_duel_turn_allowed(p_round,p_actor) then perform public.combat_v2_fail('azione_non_disponibile','In questo scambio il personaggio è in difesa.',409,p_request_key,'{}'); end if;
  if not v_service and exam_regia_private.actor_principal(v_a.id,v_a.controller_user)<>v_uid then perform public.combat_v2_fail('attore_non_controllato','Non controlli questo attore.',403,p_request_key,'{}'); end if;
  if v_a.state<>'attivo' then perform public.combat_v2_fail('azione_non_disponibile','Attore non attivo.',409,p_request_key,'{}'); end if;
  PERFORM clan_akimichi_private.common_flush_upkeep_v1(p_actor);
  SELECT * INTO STRICT v_a FROM public.combat_v2_actors WHERE id=p_actor;
  v_i:=public.combat_v2_sanitize_intent(p_intent,false); v_kind:=v_i->>'kind';
  cure_meta:=combat_panel_private.cure_declaration_meta_v1(p_round,p_actor,p_request_key,v_i);
  IF cure_meta IS NOT NULL THEN
    v_target:=(v_i->>'target_actor')::uuid;v_meta:=cure_meta;v_cost:=20;v_base:=0;
  END IF;
    IF (v_kind='movimento' OR coalesce((v_i->>'move_m')::numeric,0)<>0) AND combat_v2_genjutsu_internal.movement_blocked(p_actor) THEN RAISE EXCEPTION 'paralisi_movement_blocked';END IF;
  IF (v_kind='movimento' OR coalesce((v_i->>'move_m')::numeric,0)<>0)
    AND clan_aburame_private.sfera_prison_active_v1(v_r.session_id,p_actor)
  THEN RAISE EXCEPTION 'aburame_sfera_prison_movement_blocked';END IF;
  v_has_fili:=v_i ? 'target_fili';
  if v_has_fili and (
    v_kind<>'attacco' or v_i ? 'move_m' or v_i->>'ability_source' not in ('arma','clan','jutsu')
    or v_i->>'ability_id' is null or v_service or auth.uid() is distinct from v_a.controller_user
    or (v_i ? 'target_actor_ids' and v_i->'target_actor_ids' is distinct from jsonb_build_array(v_i->'target_actor'))
    or not exists(
      select 1 from clan_marionettisti_private.ocular_sever_authorizations_v1 allowed
      where allowed.request_key=p_request_key and allowed.transaction_id=txid_current()
        and allowed.round_id=p_round and allowed.actor_id=p_actor
        and allowed.target_id::text=v_i->>'target_actor'
        and allowed.attack_source=v_i->>'ability_source' and allowed.ability_id::text=v_i->>'ability_id')
  ) then
    perform public.combat_v2_fail('opzione_non_offerta','Seleziona un singolo collegamento e un attacco disponibile.',422,p_request_key,'{}');
  end if;
  fireball:=clan_uchiha_private.fireball_prepared(p_round,p_actor,p_request_key,v_i);
  perform clan_marionettisti_private.assert_jutsu_source(p_actor,v_i->>'ability_source',(v_i->>'ability_id')::uuid);
  if v_kind='attacco' then
    v_target:=(v_i->>'target_actor')::uuid;
    select * into v_t from public.combat_v2_actors t
      where t.id=v_target and t.session_id=v_a.session_id and t.state='attivo' and (t.team_key<>v_a.team_key OR fireball.profile->>'mode'='esplosiva');
    if v_t.id is null then
      perform public.combat_v2_fail('bersaglio_non_valido','Bersaglio non valido.',422,p_request_key,'{}'); end if;
    v_source:=coalesce(v_i->>'ability_source','mano');
    if v_source='mano' then
      if v_i ? 'ability_id' then perform public.combat_v2_fail('intento_non_valido','Il colpo a mano non usa ability_id.',422,p_request_key,'{}'); end if;
      v_meta:=jsonb_build_object('source','mano','name','Colpo','kind','fisico','chakra_cost',0,'damage_base',10,'element',null);
    elsif v_source='arma' then
      v_meta:=combat_panel_private.shuriken_available_v1(p_actor);
      if v_meta is null or v_i->>'ability_id' is distinct from v_meta->>'id'
         or v_i ? 'move_m'
         or (v_i ? 'target_actor_ids' and v_i->'target_actor_ids' is distinct from jsonb_build_array(v_target))
         or (not v_has_fili and not combat_panel_private.shuriken_target_v1(p_actor,v_target)) then
        perform public.combat_v2_fail('shuriken_non_disponibile','Serve uno Shuriken disponibile e un bersaglio visibile entro 10 metri.',422,p_request_key,'{}');
      end if;
    elsif v_source in ('clan','jutsu') then
      v_ability:=(v_i->>'ability_id')::uuid;
      IF v_source='clan' AND v_ability='db51e5ae-8b90-4c3a-a51d-962eb9e19b38'::uuid THEN
        IF combat_panel_private.nara_staff_scope_v1(p_actor) THEN
          v_nara_native := true;
        ELSE
          -- The common mutation already holds the native round and actor locks.
          -- Hold this lock through declaration insertion; recovery takes the same row for update.
          SELECT gate.public_enabled,gate.public_activated_at
          INTO STRICT v_nara_public_enabled,v_nara_public_activated_at
          FROM combat_panel_private.nara_launch_gate_v1 gate
          WHERE gate.singleton FOR SHARE;
          IF v_nara_public_activated_at IS NOT NULL THEN
            IF NOT v_nara_public_enabled OR NOT combat_panel_private.nara_persistent_scope_v1(p_actor) THEN
              PERFORM public.combat_v2_fail('opzione_non_offerta','Tecnica non offerta dal server.',422,p_request_key,'{}');
            END IF;
            v_nara_native := true;
          ELSE
            -- Preserve the original Staff-profile route and ordinary legacy behavior before first activation.
            v_nara_native := combat_panel_private.nara_routes_possession_v1(p_actor);
          END IF;
        END IF;
      END IF;
      IF v_source='clan' AND v_ability='001f907c-8f32-4758-8a16-ad1730e72c59'::uuid THEN
        v_meta:=clan_sabaku_private.flow_declaration_meta(p_round,p_actor,p_request_key,v_i);
      ELSIF v_source='clan' AND v_ability='db51e5ae-8b90-4c3a-a51d-962eb9e19b38'::uuid
        AND v_nara_native THEN
         IF v_i ? 'target_actor_ids' AND jsonb_array_length(v_i->'target_actor_ids')<>1 THEN
           RAISE EXCEPTION 'nara_single_target_required' USING ERRCODE='22023';
         END IF;
         v_meta:=combat_panel_private.nara_offer_meta_v1(v_a.id,false,v_t.id);
      ELSIF v_source='clan' AND combat_v2_elemental_internal.suiton_profile(p_actor,v_ability) IS NOT NULL THEN
        v_meta:=combat_v2_elemental_internal.suiton_declaration_meta(p_round,p_actor,p_request_key,v_i);
        IF v_meta IS NULL THEN RAISE EXCEPTION 'suiton_preparation_required';END IF;
            ELSIF v_source='clan' AND v_ability='31d5d554-44d1-4042-9920-3ddd3bedff7e'::uuid THEN
        v_meta:=combat_v2_genjutsu_internal.declaration_meta(p_round,p_actor,p_request_key,v_i);
        IF v_meta IS NULL THEN RAISE EXCEPTION 'paralisi_preparation_required';END IF;
      ELSIF v_source='clan' AND combat_v2_elemental_internal.other_profile(p_actor,v_ability) IS NOT NULL THEN
        v_meta:=combat_v2_elemental_internal.other_declaration_meta(p_round,p_actor,p_request_key,v_i);
        IF v_meta IS NULL THEN RAISE EXCEPTION 'other_preparation_required';END IF;
      ELSE v_meta:=combat_v2_multitarget_internal.enrich_ability_v1(public.combat_v2_actor_ability(p_actor,v_source,v_ability,false)); END IF;
      if v_source='clan' and v_ability='e361f7c3-f90b-47ec-bfee-ccbda21257d9'::uuid and v_meta is not null then
        perform clan_marionettisti_private.ensure_initial_link(p_actor);
        perform combat_panel_private.multiplication_companion_attack_source(p_round,p_actor,v_target,p_request_key,null);
        v_meta:=v_meta||jsonb_build_object('kind','fisico','chakra_cost',5,'damage_base',10,'usage','principale','consumption_type','ad_utilizzo','defensive',false,'di_scena',false,'diversivo',false,'marionetta_profile_version','marionetta-offense/1');
      end if;
      if v_meta is null then perform public.combat_v2_fail('opzione_non_offerta','Tecnica non offerta dal server.',422,p_request_key,'{}'); end if;
      -- [MISSION-GUARD-003] Le famiglie speciali non diventano attacchi generici.
      if coalesce(v_meta->>'usage','') not in ('principale','rapida')
         or coalesce((v_meta->>'defensive')::boolean,false)
         or coalesce((v_meta->>'di_scena')::boolean,false)
         or (v_source='jutsu' and v_ability='c6e31b7b-38fe-4b4f-b3c7-05f3e922d193'::uuid)
         or coalesce((v_meta->>'diversivo')::boolean,false)
         or coalesce(v_meta->>'consumption_type','ad_utilizzo')='passiva' then
        perform public.combat_v2_fail('profilo_runtime_non_disponibile','Questa tecnica richiede il proprio resolver.',422,p_request_key,'{}');
      end if;
      IF fireball.actor_id IS NOT NULL THEN v_meta:=v_meta||fireball.profile||jsonb_build_object('damage_base',fireball.profile->'damage_base');END IF;
      v_max_range:=CASE WHEN v_source='clan' AND v_ability='f5e9af24-70f1-49f6-a7ca-74f59256336e'::uuid THEN 5
        WHEN v_meta->>'aburame_sfera_version'='aburame-sfera/1' THEN 10
        WHEN v_meta->>'hoki_needle_version'='hoki-needle/1' THEN 15
        WHEN v_meta->>'akimichi_partial_contract'='akimichi-partial/1' THEN 3
        WHEN v_meta ? 'nara_launch' THEN (v_meta->>'nara_range_m')::numeric
        WHEN v_meta->>'sabaku_flow_version'='sabaku-flow/2' THEN 15 ELSE public._fascia_metri(v_meta->>'range') END;
      multiplication_aim_valid:=combat_panel_private.multiplication_attack_aim_valid(p_round,p_actor,v_target,p_request_key,v_max_range);
      if not v_has_fili and fireball.actor_id IS NULL and not (v_source='clan' and v_ability='e361f7c3-f90b-47ec-bfee-ccbda21257d9'::uuid) and
        (case when v_source='clan' AND v_ability='9ac77d79-9894-5388-9753-70538ac5eaa3'::uuid
           AND combat_v2_taijutsu_internal.entry_prepared(p_round,p_actor,p_request_key,v_target) then false
          when v_source='clan' AND v_ability='b076a976-c75b-4b5a-8813-b0e8e2c3af03'::uuid
            AND clan_inuzuka_private.zanna_master_endpoint_v1(p_round,p_actor,v_target,p_request_key,'prepared') then false
          when v_meta->>'aburame_sfera_version'='aburame-sfera/1'
          then not clan_aburame_private.sfera_staff_target_v1(v_a.id,v_t.id)
          when v_meta->>'hoki_needle_version'='hoki-needle/1' then not clan_hoki_private.needle_target_valid(v_a.id,v_t.id)
          WHEN v_meta ? 'nara_launch' THEN false
          when multiplication_aim_valid is not null then not multiplication_aim_valid
          when v_meta->>'akimichi_partial_contract'='akimichi-partial/1'
          then not clan_akimichi_private.partial_target_valid(v_a.id,v_t.id)
          when v_source='clan' AND v_ability='031d5ecc-86ee-4d21-85f1-6b76fc57cef9'::uuid
           AND EXISTS(SELECT 1 FROM public.combat_v2_sessions s WHERE s.id=v_a.session_id AND s.source_kind='ordinary')
          then not combat_consumer_private.melee_eligible(v_a.session_id,v_a.id,v_t.id)
          when combat_panel_private.has_master_geometry(v_a.session_id)
          then not combat_panel_private.target_geometry_valid(v_a.id,v_t.id,v_max_range)
          else abs(v_a.position_m-v_t.position_m)>v_max_range end) then
        perform public.combat_v2_fail('fuori_portata','Bersaglio fuori portata.',422,p_request_key,'{}');
      end if;
    else perform public.combat_v2_fail('opzione_non_offerta','Fonte tecnica non offerta.',422,p_request_key,'{}'); end if;
    IF v_meta->>'aburame_sfera_version'='aburame-sfera/1'
      AND (v_has_fili OR v_i ? 'move_m'
        OR (v_i ? 'target_actor_ids' AND v_i->'target_actor_ids' IS DISTINCT FROM jsonb_build_array(v_target))
        OR NOT clan_aburame_private.sfera_staff_target_v1(v_a.id,v_target))
    THEN RAISE EXCEPTION 'aburame_sfera_target_invalid'; END IF;
    IF v_source='clan' AND v_ability='f5e9af24-70f1-49f6-a7ca-74f59256336e'::uuid AND EXISTS (
      SELECT 1 FROM clan_aburame_private.sfera_sources_v1 s
      WHERE s.session_id=v_a.session_id AND s.actor_id=v_a.id
        AND s.target_actor_id=v_target AND s.state IN ('reserved','active')
    ) THEN RAISE EXCEPTION 'aburame_sfera_release_mutually_exclusive'; END IF;
    IF v_kind='attacco' AND NOT v_has_fili
      AND NOT coalesce(fireball.profile->>'mode'='esplosiva',false)
      AND (
        clan_aburame_private.sfera_crosses_prison_v1(v_a.session_id,v_a.id,v_target)
        OR EXISTS (
          SELECT 1 FROM jsonb_array_elements_text(coalesce(v_i->'target_actor_ids','[]'::jsonb)) AS e(id)
          WHERE clan_aburame_private.sfera_crosses_prison_v1(v_a.session_id,v_a.id,e.id::uuid)
        )
      )
    THEN RAISE EXCEPTION 'aburame_sfera_direct_target_blocked'; END IF;
    v_cost:=coalesce((v_meta->>'chakra_cost')::int,0); v_base:=coalesce((v_meta->>'damage_base')::int,0);
  elsif v_kind='movimento' then
    if combat_panel_private.has_master_geometry(v_a.session_id) then
      v_i:=combat_panel_private.master_movement_intent(p_round,p_actor,p_request_key,v_i);
    else
      if not (v_i ? 'move_m') or (v_i->>'move_m')::int not between -15 and 15 then perform public.combat_v2_fail('intento_non_valido','Spostamento non valido.',422,p_request_key,'{}'); end if;
    end if;
  end if;
  IF fireball.actor_id IS NOT NULL THEN
    v_meta:=coalesce(v_meta,'{}')||fireball.profile||jsonb_build_object('family','projectile_fireball','kind','ninjutsu','element','Fuoco','range','media','source','clan','id',fireball.profile->'catalog_technique_id');
    v_cost:=(fireball.profile->>'chakra_cost')::integer;v_base:=(fireball.profile->>'damage_base')::integer;
  END IF;
  multiplication_meta:=combat_panel_private.multiplication_declaration_meta(p_round,p_actor,p_request_key,v_i,v_meta);
  IF multiplication_meta IS NOT NULL THEN
    v_meta:=multiplication_meta; v_cost:=(v_meta->>'chakra_cost')::integer; v_base:=(v_meta->>'damage_base')::integer;
  END IF;
    IF v_kind='utilita' THEN
    genjutsu_release_meta:=combat_v2_genjutsu_internal.release_meta(p_round,p_actor,p_request_key,v_i);
    IF genjutsu_release_meta IS NOT NULL THEN v_meta:=genjutsu_release_meta;v_target:=(v_i->>'target_actor')::uuid;v_cost:=0;v_base:=0;END IF;
  END IF;
  escape_meta:=combat_panel_private.immobilization_escape_meta(p_round,p_actor,p_request_key,v_i);
  IF escape_meta IS NOT NULL THEN
    IF multiplication_meta IS NOT NULL THEN RAISE EXCEPTION 'immobilization_escape_action_conflict' USING ERRCODE='22023'; END IF;
    v_meta:=escape_meta; v_cost:=0; v_base:=0;
  END IF;
  IF combat_panel_private.nara_owner_choice_v1(p_actor)->'upkeep_due'='true'::jsonb THEN
    PERFORM public.combat_v2_fail('azione_non_disponibile','Mantieni o rilascia il Possesso prima di agire.',409,p_request_key,'{}');
  END IF;
  IF combat_panel_private.nara_controlled_v1(p_actor)
    AND v_kind IS DISTINCT FROM 'passa' AND escape_meta IS NULL THEN
    PERFORM public.combat_v2_fail('azione_non_disponibile','Il corpo è sotto controllo.',409,p_request_key,'{}');
  END IF;
  clone_meta:=clan_sabaku_private.clone_declaration_meta(p_round,p_actor,p_request_key,v_i);
  IF clone_meta IS NOT NULL THEN
    IF multiplication_meta IS NOT NULL OR escape_meta IS NOT NULL THEN RAISE EXCEPTION 'sabaku_clone_action_conflict' USING ERRCODE='22023'; END IF;
    v_meta:=clone_meta; v_cost:=5; v_base:=0;
  END IF;
  aburame_meta:=clan_aburame_private.action_meta(p_round,p_actor,p_request_key,v_i);
  IF aburame_meta IS NOT NULL THEN
    IF multiplication_meta IS NOT NULL OR escape_meta IS NOT NULL OR clone_meta IS NOT NULL THEN RAISE EXCEPTION 'aburame_action_conflict' USING ERRCODE='22023'; END IF;
    v_meta:=aburame_meta;v_cost:=0;v_base:=0;
  END IF;
  if v_has_fili then
    v_fili_range:=clan_marionettisti_private.ocular_sever_attack_range_v1(
      p_actor,v_source,(v_i->>'ability_id')::uuid,v_meta);
    if v_fili_range is not null and multiplication_meta is null and fireball.actor_id is null
       and escape_meta is null and clone_meta is null and aburame_meta is null then
      v_fili_source:=clan_marionettisti_private.ocular_sever_source_v1(p_round,p_actor,v_target,v_fili_range);
    end if;
    if v_fili_source is null then
      perform public.combat_v2_fail('opzione_non_offerta','Servono Fili visibili e a portata dell’attacco scelto.',422,p_request_key,'{}');
    end if;
    update clan_marionettisti_private.ocular_sever_authorizations_v1
      set proof=v_fili_source where request_key=p_request_key and transaction_id=txid_current();
  end if;
  IF cure_meta IS NOT NULL AND (v_meta IS DISTINCT FROM cure_meta OR v_cost<>20 OR v_base<>0) THEN
    RAISE EXCEPTION 'cure_action_family_conflict' USING ERRCODE='22023';
  END IF;
  IF v_i->>'ability_source'='clan' AND v_i->>'ability_id'='0a15282f-d6b5-4ee3-ad52-7fac2525444d' THEN
    v_meta:=combat_panel_private.nara_strangle_action_meta_v1(p_round,p_actor,v_i);v_cost:=10;v_base:=10;v_target:=(v_meta->>'target_actor_id')::uuid;
  END IF;
  v_event:=public.combat_v2_event_begin(p_round,p_request_key,'combat_v2_action_declare',jsonb_build_object('actor',p_actor,'intent',v_i,'text',coalesce(p_text,'')),null);
  if (v_event->>'replay')::boolean then return v_event->'result'; end if; v_event_id:=(v_event->>'event_id')::uuid;
  insert into public.combat_v2_declarations(round_id,actor_id,kind,target_actor_id,sanitized_intent,declaration_text,controller_user_snapshot,controller_version_snapshot,request_key,cost_snapshot)
  values(p_round,p_actor,v_kind,v_target,v_i||case when v_meta is null then '{}'::jsonb else jsonb_build_object('server_ability',v_meta) end,
    coalesce(p_text,''),coalesce(v_uid,v_service_actor),v_a.controller_version,p_request_key,clan_hyuga_private.sedici_cost_snapshot(p_actor,jsonb_build_object('chakra',v_cost,'damage_base',v_base))) returning id into v_id;
  PERFORM combat_panel_private.cure_bind_v1(v_id);
  PERFORM clan_aburame_private.verme_bind_v1(v_id);
  PERFORM combat_panel_private.nara_strangle_bind_v1(v_id);
  IF v_source='arma' THEN
    PERFORM combat_panel_private.shuriken_spend_v1(v_id,p_request_key);
  END IF;
  IF v_meta ? 'nara_launch' THEN
    PERFORM combat_panel_private.nara_freeze_segment_positions_v1(v_id);
  END IF;
  perform combat_panel_private.multiplication_bind_declaration(v_id);
  perform combat_panel_private.immobilization_bind_escape(v_id);
  perform clan_sabaku_private.clone_bind(v_id);
  perform combat_panel_private.multiplication_bind_attack_aims(v_id);
  perform combat_panel_private.bind_master_movement(v_id);
  PERFORM clan_sabaku_private.flow_bind_preparation(v_id);
  PERFORM clan_hyuga_private.juken_freeze(v_id);
  PERFORM clan_hyuga_private.sedici_freeze(v_id);
  PERFORM clan_uchiha_private.fireball_freeze(v_id); PERFORM clan_inuzuka_private.zanna_freeze(v_id);
  PERFORM combat_v2_elemental_internal.suiton_bind_source(v_id);
    PERFORM combat_v2_elemental_internal.other_bind_source(v_id);
  PERFORM combat_v2_genjutsu_internal.bind_source(v_id);
  PERFORM combat_v2_genjutsu_internal.bind_release(v_id);
  if v_kind='attacco' and v_source='clan' and v_ability='e361f7c3-f90b-47ec-bfee-ccbda21257d9'::uuid then
    perform clan_marionettisti_private.freeze_offensive_profile(v_id);
  end if;
  IF v_meta->>'hoki_needle_version'='hoki-needle/1' THEN PERFORM clan_hoki_private.needle_reserve(v_id); END IF;
  PERFORM clan_akimichi_private.bind_partial(v_id);
  PERFORM clan_hyuga_private.rotation_attack_power_freeze(v_id);
  PERFORM clan_akimichi_private.common_attack_power_freeze_v1(v_id);
  v_phase:=combat_consumer_private.advance_after_main_actions(p_round);
  if v_phase='risoluzione' and not combat_consumer_private.owns_round(p_round)
     and (v_r.evaluation_mode='neutra' or not exists(
       select 1 from public.combat_v2_attack_targets t join public.combat_v2_declarations d on d.id=t.attack_declaration_id
       where t.round_id=p_round and t.state not in ('annullata','superflua') and d.state not in ('annullata','superflua')))
     and (v_uid is not null or public.combat_v2_is_service()) then
    v_resolution_key:=md5(p_request_key::text||'|no-attack-resolve')::uuid;
    if v_uid is not null and v_a.character_id is not null then
      insert into combat_consumer_private.dispatch_authorizations(request_key,round_id,principal_character_id,transaction_id,operation,state)
      values(v_resolution_key,p_round,v_a.character_id,txid_current(),'resolve','prepared');
    end if;
    v_resolution:=public.combat_v2_round_resolve(p_round,v_resolution_key);
    v_phase:='risolto';
  end if;
  v_result:=public.combat_v2_envelope(p_request_key,jsonb_build_object('declaration_id',v_id,'target_ids',(select coalesce(jsonb_agg(t.target_actor_id order by t.ordinal),'[]'::jsonb)from public.combat_v2_attack_targets t where t.attack_declaration_id=v_id),'phase',v_phase,'auto_resolution',v_resolution));
  return public.combat_v2_event_complete(v_event_id,v_result);
end $function$;
CREATE OR REPLACE FUNCTION combat_v2_multitarget_internal.resolve_parent(p_session uuid, p_round uuid, p_attack uuid, p_values boolean)
 RETURNS jsonb
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO ''
AS $function$
declare verme_profile jsonb;verme_result jsonb;verme_success boolean;sfera_profile jsonb;sfera_result jsonb;
 elemental_claim jsonb; elemental_channels jsonb; elemental_cap jsonb; fireball_profile jsonb; hyuga_profile jsonb; hyuga_juken jsonb; multiplication_facts jsonb; multiplication_effect jsonb; d public.combat_v2_declarations%rowtype;att public.combat_v2_actors%rowtype;tar public.combat_v2_actors%rowtype;defender public.combat_v2_actors%rowtype;
 t public.combat_v2_attack_targets%rowtype;c public.combat_v2_defense_coverages%rowtype;def public.combat_v2_declarations%rowtype;
 meta jsonb;calc jsonb;rng jsonb;parent_entropy bytea;entropy bytea;ctx text;reaction text;kind text;base int;
 shared_a1 int;shared_a2 int;a1 int;a2 int;d1 int;d2 int;vote_a int;vote_d int;corr int;raw int;final int;full_damage int;damage int;hp int;
 any_success boolean:=false;children jsonb:='[]';child_outcome jsonb;receipt text;old_slancio int;
 fili_hit boolean:=false;
 cellular_calc jsonb;flow_calc jsonb;fb_defense_snapshot jsonb; nara_launch jsonb;
 akimichi_partial clan_akimichi_private.partial_sources%rowtype;
begin
 select*into strict d from public.combat_v2_declarations where id=p_attack and round_id=p_round for update;
 nara_launch:=combat_panel_private.nara_frozen_launch_v1(d.id);
 IF nara_launch IS NOT NULL AND (
  NOT combat_panel_private.nara_launch_resources_match_v1(d.actor_id,p_session,nara_launch,p_values)
  OR (SELECT count(*) FROM public.combat_v2_attack_targets x WHERE x.attack_declaration_id=d.id)<>1
 ) THEN RAISE EXCEPTION 'nara_native_single_target_scope_invalid' USING ERRCODE='55000'; END IF;
 select*into strict att from public.combat_v2_actors where id=d.actor_id for update;
 verme_profile:=clan_aburame_private.verme_frozen_v1(d.id);
 sfera_profile:=clan_aburame_private.sfera_frozen_v1(d.id);
 IF sfera_profile IS NOT NULL THEN
  att.mechanics_snapshot:=att.mechanics_snapshot||jsonb_build_object('aburame_sfera_profile',sfera_profile);
 END IF;
 IF verme_profile->>'source_lost'='true' THEN RETURN jsonb_build_object('source_lost',true);END IF;
 IF verme_profile IS NOT NULL THEN
  IF (SELECT count(*) FROM public.combat_v2_attack_targets WHERE attack_declaration_id=d.id)<>1
  THEN RAISE EXCEPTION 'aburame_verme_single_target_required';END IF;
  att.mechanics_snapshot:=att.mechanics_snapshot||jsonb_build_object('aburame_verme_profile',verme_profile);
 END IF;
 SELECT * INTO akimichi_partial FROM clan_akimichi_private.partial_sources WHERE declaration_id=d.id;
 if d.sanitized_intent->>'ability_source'='clan' and d.sanitized_intent->>'ability_id'='e361f7c3-f90b-47ec-bfee-ccbda21257d9' then
  if (select count(*) from public.combat_v2_attack_targets where attack_declaration_id=d.id)<>1 then raise exception 'marionetta_single_target_required' using errcode='22023';end if;
  calc:=public.combat_v2_clan_genin_marionettisti_resolve_v1(jsonb_build_object('contract_version','marionetta-round-hook/1','declaration_id',d.id,'request_key',d.id));
  att.mechanics_snapshot:=att.mechanics_snapshot||jsonb_build_object('marionetta_profile',calc->'profile');
 end if;
 hyuga_profile:=clan_hyuga_private.sedici_resolve_profile(d.id);
 hyuga_juken:=clan_hyuga_private.juken_resolve_profile(d.id);
 IF hyuga_profile->>'source_lost'='true' THEN
  PERFORM clan_hyuga_private.sedici_finish_lost(d.id); RETURN jsonb_build_object('source_lost',true);
 ELSIF hyuga_juken->>'status'='source_lost' THEN
  PERFORM clan_hyuga_private.juken_finish_lost(d.id); RETURN jsonb_build_object('source_lost',true);
 END IF;
 IF hyuga_profile IS NOT NULL THEN
  IF hyuga_juken IS NOT NULL THEN RAISE EXCEPTION 'hyuga_profile_stacking_forbidden'; END IF;
  att.mechanics_snapshot:=att.mechanics_snapshot||jsonb_build_object('sedici_profile',hyuga_profile);
 END IF;

      fireball_profile:=clan_uchiha_private.fireball_resolve_profile(d.id);
      IF fireball_profile->>'source_lost'='true' THEN PERFORM clan_uchiha_private.fireball_finish_lost(d.id);RETURN fireball_profile;END IF;
      IF fireball_profile IS NOT NULL THEN att.mechanics_snapshot:=att.mechanics_snapshot||jsonb_build_object('projectile_fireball',fireball_profile);END IF;
 meta:=d.sanitized_intent->'server_ability';base:=coalesce((d.cost_snapshot->>'damage_base')::int,0);
 select coalesce((select value from public.combat_v2_ratings where declaration_id=d.id and is_active order by created_at desc limit 1),0)into vote_a;
 old_slancio:=coalesce((att.mechanics_snapshot->>'slancio')::int,0);
 parent_entropy:=extensions.gen_random_bytes(32);
 IF fireball_profile IS NOT NULL THEN
  shared_a1:=public.combat_v2_derive_d10(parent_entropy,'fireball-parent:'||d.id::text,1);
  shared_a2:=public.combat_v2_derive_d10(parent_entropy,'fireball-parent:'||d.id::text,2);
 END IF;
 for t in select*from public.combat_v2_attack_targets where attack_declaration_id=d.id order by ordinal for update loop
  select*into strict c from public.combat_v2_defense_coverages where attack_target_id=t.id for update;
  select*into strict def from public.combat_v2_declarations where id=c.defense_declaration_id for update;
  select*into strict defender from public.combat_v2_actors where id=def.actor_id for update;
  select*into strict tar from public.combat_v2_actors where id=t.target_actor_id for update;
  if (case when combat_panel_private.has_master_geometry(p_session)
    then not combat_panel_private.controller_version_valid(tar.id,t.target_controller_version)
    else tar.controller_version is distinct from t.target_controller_version end) then raise exception 'targeting_geometry_stale';end if;
  if (case when combat_panel_private.has_master_geometry(p_session)
    then not combat_panel_private.controller_version_valid(defender.id,c.defender_controller_version,def.controller_user_snapshot)
    else defender.controller_version is distinct from c.defender_controller_version end) then raise exception 'defender_controller_stale';end if;
  if c.mode<>'self'and(case when combat_panel_private.has_master_geometry(p_session)
     then not combat_panel_private.coverage_geometry_valid(c.id,defender.id)
     else abs(defender.position_m-tar.position_m)>2
       or tar.position_m is distinct from c.protected_position_m end)then raise exception 'targeting_geometry_stale';end if;
  IF meta->>'sabaku_flow_version'='sabaku-flow/2' AND t.state='risolta' THEN
   -- A native substitution already resolved this target before the parent ledger.
   -- Validate its committed receipt and preserve it; never roll or charge it twice.
   IF t.outcome->>'canonical_outcome' IS DISTINCT FROM 'negato_sostituzione'
    OR t.outcome->'damage_applied' IS DISTINCT FROM '0'::jsonb OR t.outcome->'success' IS DISTINCT FROM 'false'::jsonb
    OR t.outcome->>'attack_target_id' IS DISTINCT FROM t.id::text
    OR t.outcome->>'defender_actor_id' IS DISTINCT FROM tar.id::text
    OR t.outcome->>'defense_declaration_id' IS DISTINCT FROM def.id::text
    OR def.sanitized_intent->>'reaction' IS DISTINCT FROM 'sostituzione'
    OR def.outcome->>'canonical_outcome' IS DISTINCT FROM 'negato_sostituzione'
    OR def.outcome->>'substitution_link' IS DISTINCT FROM t.outcome->>'substitution_link'
    OR NOT EXISTS(SELECT 1 FROM clan_sabaku_private.flow_sources fs
      JOIN clan_sabaku_private.flow_consumptions fc ON fc.declaration_id=fs.declaration_id AND fc.source_sha256=fs.source_sha256
      WHERE fs.declaration_id=d.id AND fs.source_sha256=t.outcome->>'flow_source_sha256'
        AND fs.source_sha256=clan_sabaku_private.flow_source_hash(fs))
    OR NOT EXISTS(SELECT 1 FROM combat_spatial.substitution_activity_links sl
      JOIN combat_spatial.substitution_activity_options so ON so.link_id=sl.link_id
      JOIN combat_spatial.spatial_events se ON se.instance_id=sl.instance_id AND se.actor_id=sl.defender_actor_id
      WHERE sl.activity_round_id=p_round AND sl.attack_declaration_id=d.id AND sl.defender_actor_id=tar.id
        AND sl.state='committed' AND so.state='committed' AND so.selected_defense_declaration_id=def.id
        AND se.event_id=(t.outcome->>'substitution_link')::uuid AND se.event_kind='substitution_committed'
        AND se.root_id=d.id AND se.narrator_payload#>>'{impact,outcome}'='negato_sostituzione') THEN
     RAISE EXCEPTION 'flow_substitution_committed_receipt_invalid' USING ERRCODE='40001'; END IF;
   children:=children||jsonb_build_array(t.outcome);
   CONTINUE;
  END IF;
  if tar.state<>'attivo'then
   child_outcome:=jsonb_build_object('success',false,'damage_applied',0,'reason','bersaglio_gia_fuori','child_ordinal',t.ordinal);
   update public.combat_v2_attack_targets set state='superflua',outcome=child_outcome where id=t.id;
  else
   reaction:=coalesce(def.sanitized_intent->>'reaction','nessuna');
   multiplication_facts:=combat_panel_private.multiplication_attack_facts(t.id);
   multiplication_effect:=combat_panel_private.multiplication_effect(multiplication_facts,reaction);
   reaction:=multiplication_effect->>'effective_reaction';kind:=lower(coalesce(meta->>'kind','fisico'));if kind not in('fisico','ninjutsu','genjutsu')then kind:='fisico';end if;
   ctx:='combat-v2/r3/multi-child:'||p_session::text||':'||p_round::text||':'||d.id::text||':'||t.id::text;
   -- Un solo seal parent nel ledger RNG esistente; l'entropia child e' derivata
   -- su un dominio distinto target/ordinale, quindi ogni child ha dadi indipendenti.
   entropy:=extensions.hmac(convert_to(ctx,'UTF8'),parent_entropy,'sha256');
   IF fireball_profile IS NOT NULL THEN a1:=shared_a1;a2:=shared_a2;ELSE a1:=public.combat_v2_derive_d10(entropy,ctx,1);a2:=public.combat_v2_derive_d10(entropy,ctx,2);END IF;d1:=public.combat_v2_derive_d10(entropy,ctx,3);d2:=public.combat_v2_derive_d10(entropy,ctx,4);
   fb_defense_snapshot:=combat_facing_private.defense_snapshot(p_attack,t.id,defender.id,clan_akimichi_private.cellular_snapshot_v1(def.id,case when tar.companion_id is not null then clan_marionettisti_private.defense_snapshot(defender.id,tar.id,reaction) else clan_innata_combat_private.velo_frozen_snapshot_v1(defender.mechanics_snapshot,defender.id,def.id) end),reaction);
   IF nara_launch IS NOT NULL AND (
     hyuga_juken IS NOT NULL OR hyuga_profile IS NOT NULL OR fireball_profile IS NOT NULL
     OR kind<>'ninjutsu' OR base<>0
   ) THEN RAISE EXCEPTION 'nara_native_profile_conflict' USING ERRCODE='55000'; END IF;
   calc:=clan_inuzuka_private.attack_calculate(p_attack,hyuga_juken->'profile',kind,
    clan_innata_combat_private.velo_frozen_snapshot_v1(
      CASE WHEN nara_launch IS NULL THEN att.mechanics_snapshot ELSE
        att.mechanics_snapshot||jsonb_build_object('mente',nara_launch->'kg','ninjutsu',nara_launch->'ninjutsu') END,
      att.id,d.id),
    fb_defense_snapshot,reaction,
    coalesce(def.sanitized_intent->'server_ability'->>'kind','taijutsu'),base,meta->>'element',a1+a2,d1+d2,(multiplication_effect->>'assault_bonus')::integer,clan_inuzuka_private.defense_guardia(def.sanitized_intent),false);
   IF akimichi_partial.declaration_id IS NOT NULL THEN
     calc:=clan_akimichi_private.partial_rebase_native(
       calc,akimichi_partial.kg,akimichi_partial.taijutsu,akimichi_partial.mass);
   END IF;
   calc:=clan_akimichi_private.cellular_mark_v1(def.id,calc);
   calc:=clan_akimichi_private.form_impact(d.id,defender.id,tar.id,kind,reaction,
     coalesce(def.sanitized_intent#>>'{server_ability,kind}','taijutsu'),calc);
   IF nara_launch IS NOT NULL THEN
     calc:=calc||jsonb_build_object('off',nara_launch->'power','danno_grezzo',0,
       'danno_applicato',0,'striscio',false,'cap_attivo',false);
   END IF;
   calc:=calc||jsonb_build_object('mod_assalto',multiplication_effect->'assault_bonus','mod_mira',0);
       calc:=combat_v2_genjutsu_internal.comparison(d.id,def.id,calc);
   rng:=jsonb_build_object('scheme','combat-v2-child-derive/1.0','child_id',t.id,
    'commitment',encode(extensions.digest(entropy,'sha256'),'hex'),
    'shared_offensive_roll',fireball_profile IS NOT NULL,'dice_attack',jsonb_build_array(a1,a2),'dice_defense',jsonb_build_array(d1,d2));
   select coalesce((select value from public.combat_v2_ratings where declaration_id=def.id and is_active order by created_at desc limit 1),0)into vote_d;
   corr:=greatest(-3,least(3,vote_a-CASE WHEN (multiplication_effect->>'defense_spent_on_copy')::boolean THEN 0 ELSE vote_d END));raw:=(calc->>'margine')::int;final:=raw+corr+coalesce((calc->>'mod_risonanza')::integer,0);
   -- B4: la claim modifica soltanto la soglia; il margine danno resta nativo.
   elemental_claim:=combat_v2_elemental_internal.comparison_reserve(d.id,t.id,def.id);
   elemental_channels:=NULL;
   IF elemental_claim IS NOT NULL THEN
     elemental_channels:=combat_v2_elemental_internal.comparison_channels(
       d.id,t.id,def.id,calc,corr,(elemental_claim->>'event_id')::uuid);
     final:=(elemental_channels->>'hit_margin')::integer;
     calc:=calc||jsonb_build_object('elemental_comparison',elemental_channels);
     calc:=calc||jsonb_build_object('common_effects',
       coalesce(calc->'common_effects','{}'::jsonb)||(elemental_channels->'common_effects'));
   END IF;
        IF NOT coalesce((multiplication_effect->>'copy_intercepted')::boolean,false) AND NOT coalesce((multiplication_effect->>'defense_spent_on_copy')::boolean,false) THEN
          elemental_channels:=combat_v2_elemental_internal.other_comparison(d.id,def.id,calc,final);
          final:=(elemental_channels->>'hit_margin')::integer;calc:=elemental_channels->'calculation';
        END IF;
   base:=coalesce((d.cost_snapshot->>'damage_base')::int,0)+coalesce((calc#>>'{akimichi_form,body_mass}')::integer,0);
   if (multiplication_effect->>'copy_intercepted')::boolean or (fireball_profile IS NOT NULL AND reaction='sostituzione') or kind='genjutsu'and final<0 then damage:=0;
   elsif final<0 then damage:=greatest(1,greatest(1,base+((calc->>'off')::int/4)-(calc->>'riduzione')::int)/4);
   else full_damage:=greatest(1,base+((calc->>'off')::int/4)+coalesce((calc->>'bonus_margine')::int,0)-(calc->>'riduzione')::int);damage:=least(65,full_damage);end if;
   flow_calc:=NULL;
   IF meta->>'sabaku_flow_version'='sabaku-flow/2' THEN
     flow_calc:=clan_sabaku_private.flow_resolve_calculation(d.id,tar.id,calc,corr,
       coalesce((multiplication_effect->>'copy_intercepted')::boolean,false),reaction='sostituzione');
     final:=(flow_calc->>'hit_margin')::integer;damage:=(flow_calc->>'damage_applied')::integer;
     calc:=calc||jsonb_build_object('sabaku_flow',flow_calc,'off',flow_calc->'power',
       'bonus_margine',flow_calc->'damage_margin_bonus','danno_grezzo',flow_calc->'full_damage_uncapped',
       'danno_applicato',flow_calc->'damage_applied','colpito',flow_calc->'success','striscio',flow_calc->'striscio');
   END IF;
   IF akimichi_partial.declaration_id IS NOT NULL THEN
     calc:=clan_akimichi_private.partial_damage(calc,final,reaction='sostituzione'
       OR coalesce((multiplication_effect->>'copy_intercepted')::boolean,false));
     damage:=(calc->>'danno_applicato')::integer;
   END IF;
   cellular_calc:=CASE WHEN reaction='tecnica' AND NOT coalesce((multiplication_effect->>'defense_spent_on_copy')::boolean,false) AND NOT coalesce((multiplication_effect->>'copy_intercepted')::boolean,false) THEN clan_akimichi_private.cellular_calculate_v1(def.id,calc,final,base) END;
   IF cellular_calc IS NOT NULL THEN
     damage:=(cellular_calc->>'damage_after')::integer;
     calc:=calc||jsonb_build_object('akimichi_cellular',cellular_calc,'danno_applicato',damage,'striscio',false);
   END IF;
   -- B5: credito originario dopo il danno nativo, prima di Rotazione/armatura/PV.
   IF nara_launch IS NOT NULL OR d.sanitized_intent->'target_fili'='true'::jsonb THEN
     damage:=0;
     calc:=calc||jsonb_build_object('danno_grezzo',0,'danno_applicato',0,'striscio',false,'cap_attivo',false);
   END IF;
       IF calc#>>'{paralisi,contract}'='paralisi-movement/1' THEN damage:=0;END IF;
    IF verme_profile IS NOT NULL THEN
    verme_success:=final>=0 AND reaction<>'sostituzione' AND NOT coalesce((multiplication_effect->>'copy_intercepted')::boolean,false);
    IF reaction='sostituzione' OR(reaction='copie' AND final<0)
      OR coalesce((multiplication_effect->>'copy_intercepted')::boolean,false) THEN
     damage:=0;calc:=calc||jsonb_build_object('danno_applicato',0,'striscio',false);
    END IF;
   END IF;
    IF sfera_profile IS NOT NULL THEN
      damage:=0;
      calc:=calc||jsonb_build_object('danno_grezzo',0,'danno_applicato',0,'striscio',false,'cap_attivo',false);
    END IF;
    elemental_cap:=combat_effects_private.capture_source_cap(d.id,damage);
   IF elemental_cap<>'{}'::jsonb THEN
     calc:=calc||jsonb_build_object('common_effects',
       coalesce(calc->'common_effects','{}'::jsonb)||elemental_cap);
   END IF;
    IF sfera_profile IS NOT NULL THEN
      damage:=0;
      calc:=calc||jsonb_build_object('danno_applicato',0,'striscio',false);
    ELSIF calc#>>'{paralisi,contract}' IS DISTINCT FROM 'paralisi-movement/1' THEN
    calc:=calc||jsonb_build_object('sabaku_armor',clan_sabaku_private.armor_absorb(t.id,damage));
    damage:=(calc#>>'{sabaku_armor,damage_after}')::integer;
    IF NOT (calc->'sabaku_armor' ? 'version') THEN calc:=calc-'sabaku_armor'; END IF;
    END IF;
   IF verme_profile IS NOT NULL THEN
    -- Il recipient canonico resta tar; il difensore intercettante fornisce la copertura nativa.
    verme_result:=clan_aburame_private.verme_finish_v1(d.id,tar.id,verme_success,damage);
    IF verme_result IS NULL THEN RAISE EXCEPTION 'aburame_verme_parent_source_missing';END IF;
    calc:=calc||jsonb_build_object('aburame_verme',verme_result);
   END IF;
   IF sfera_profile IS NOT NULL THEN
    sfera_result:=clan_aburame_private.sfera_finish_v1(d.id,tar.id,
      clan_aburame_private.sfera_hits_v1(final,reaction,(multiplication_effect->>'copy_intercepted')::boolean,
        NULL,NULL,cellular_calc));
    damage:=0;
    calc:=calc||jsonb_build_object('aburame_sfera',sfera_result,'danno_applicato',0,'striscio',false);
   END IF;
   hp:=greatest(0,coalesce((tar.mechanics_snapshot->>'vita')::int,0)-damage);
   update public.combat_v2_actors set mechanics_snapshot=jsonb_set(mechanics_snapshot,'{vita}',to_jsonb(hp),false),state=case when hp=0 then'fuori'else state end where id=tar.id;
   if p_values and tar.actor_kind='pg'and damage>0 then perform set_config('app.allow_vita_delta','1',true);update public.characters set vita=hp where id=tar.character_id;perform set_config('app.allow_vita_delta','0',true);end if;
   any_success:=any_success or ((CASE WHEN flow_calc IS NOT NULL THEN (flow_calc->>'success')::boolean WHEN akimichi_partial.declaration_id IS NOT NULL THEN (calc->>'colpito')::boolean
      WHEN nara_launch IS NOT NULL THEN final>=0 AND reaction<>'sostituzione' AND NOT (multiplication_effect->>'copy_intercepted')::boolean
      ELSE final>=0 AND NOT (multiplication_effect->>'copy_intercepted')::boolean END));
   child_outcome:=jsonb_build_object('child_id',t.id,'child_ordinal',t.ordinal,'target_actor_id',tar.id,'raw',calc,'rng_audit',rng,
    'rating_attack',vote_a,'rating_defense',vote_d,'quality_correction',corr,'threshold_margin',final,'success',(CASE WHEN flow_calc IS NOT NULL THEN (flow_calc->>'success')::boolean WHEN akimichi_partial.declaration_id IS NOT NULL THEN (calc->>'colpito')::boolean
      WHEN nara_launch IS NOT NULL THEN final>=0 AND reaction<>'sostituzione' AND NOT (multiplication_effect->>'copy_intercepted')::boolean
      ELSE final>=0 AND NOT (multiplication_effect->>'copy_intercepted')::boolean END),
    'damage_policy','full_each','damage_applied',damage,'target_hp_after',hp,'ko',hp=0);
    IF verme_profile IS NOT NULL THEN
     child_outcome:=child_outcome||jsonb_build_object('success',verme_success);
     any_success:=verme_success;
    END IF;
    IF jsonb_array_length(multiplication_facts)>0 THEN
     child_outcome:=child_outcome||jsonb_build_object('multiplication',multiplication_facts,'multiplication_effect',multiplication_effect);
    END IF;
    IF nara_launch IS NOT NULL THEN
      child_outcome:=child_outcome||jsonb_build_object('nara_possession',
        combat_panel_private.nara_record_control_v1(t.id,child_outcome));
    END IF;
    IF d.sanitized_intent->'target_fili'='true'::jsonb THEN
      fili_hit:=coalesce((child_outcome->>'success')::boolean,false) AND reaction<>'sostituzione'
        AND clan_marionettisti_private.ocular_sever_frozen_valid_v1(d.id);
      any_success:=fili_hit;
      child_outcome:=child_outcome||jsonb_build_object('success',fili_hit,'fili_recisi',fili_hit);
    END IF;
        IF calc#>>'{paralisi,contract}'='paralisi-movement/1' THEN
      child_outcome:=child_outcome||jsonb_build_object('success',combat_v2_genjutsu_internal.success(calc,final,(multiplication_effect->>'copy_intercepted')::boolean));
      any_success:=(child_outcome->>'success')::boolean;
    END IF;
    child_outcome:=combat_v2_genjutsu_internal.decorate_outcome(d.id,t.id,child_outcome);
    receipt:=combat_v2_multitarget_internal.sha(child_outcome);
   update public.combat_v2_attack_targets set state='risolta',outcome=child_outcome,rng_receipt_sha256=receipt where id=t.id;
  end if;
  PERFORM combat_effects_private.settle_native_target(d.id,t.id);
  PERFORM combat_panel_private.multiplication_attack_finish(t.id);
   update public.combat_v2_defense_coverages set state='risolta'where id=c.id;
  children:=children||jsonb_build_array(child_outcome);
 end loop;
 update public.combat_v2_declarations dd set state='risolta',outcome=(CASE
   WHEN meta->>'sabaku_flow_version'='sabaku-flow/2' AND dd.sanitized_intent->>'reaction'='sostituzione'
    THEN coalesce(dd.outcome,'{}'::jsonb) ELSE '{}'::jsonb END)||jsonb_build_object(
   'linked_attacks',(select coalesce(jsonb_agg(distinct mt.attack_declaration_id order by mt.attack_declaration_id),'[]'::jsonb)
      from public.combat_v2_defense_coverages cv join public.combat_v2_attack_targets mt on mt.id=cv.attack_target_id where cv.defense_declaration_id=dd.id),
   'coverage',(select coalesce(jsonb_agg(jsonb_build_object('attack_target_id',cv2.attack_target_id,'protected_actor_id',cv2.protected_actor_id,'mode',cv2.mode,'state',cv2.state) order by cv2.attack_target_id),'[]'::jsonb)
      from public.combat_v2_defense_coverages cv2 where cv2.defense_declaration_id=dd.id),
   'coverage_count',(select count(*) from public.combat_v2_defense_coverages cv3 where cv3.defense_declaration_id=dd.id))
 where dd.id in(select distinct cv.defense_declaration_id from public.combat_v2_defense_coverages cv join public.combat_v2_attack_targets mt on mt.id=cv.attack_target_id where mt.attack_declaration_id=d.id);
 perform combat_v2_private.rng_seal(p_session,p_round,d.id,'attack',
  'combat-v2/r3/multi-parent:'||p_session::text||':'||p_round::text||':'||d.id::text,
  parent_entropy,jsonb_build_object('scheme','combat-v2-child-derive/1.0','children',children));
 update public.combat_v2_actors set mechanics_snapshot=jsonb_set(mechanics_snapshot,'{slancio}',to_jsonb(case when any_success then 0 else least(9,old_slancio+3)end),true)where id=att.id;
 update public.combat_v2_declarations set state='risolta',outcome=jsonb_build_object('targeting_mode',case when jsonb_array_length(children)>1 then'multi'else'single'end,
  'damage_policy','full_each','child_count',jsonb_array_length(children),'any_success',any_success,'slancio_before',old_slancio,
  'slancio_after',case when any_success then 0 else least(9,old_slancio+3)end,'children',children)||
    CASE WHEN d.sanitized_intent->'target_fili'='true'::jsonb THEN jsonb_build_object('success',fili_hit,'fili_recisi',fili_hit,'damage_applied',0)
         ELSE '{}'::jsonb END where id=d.id;
 return jsonb_build_object('any_success',any_success,'children',children);
end$function$;
CREATE OR REPLACE FUNCTION public.combat_v2_round_resolve(p_round uuid, p_request_key uuid)
 RETURNS jsonb
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO ''
AS $function$
declare verme_profile jsonb;verme_result jsonb;sfera_profile jsonb;sfera_result jsonb;nara_launch jsonb; nara_facts jsonb; elemental_claim jsonb; elemental_channels jsonb; elemental_cap jsonb; elemental_order_outcome jsonb; elemental_order_ready boolean:=false; elemental_target uuid; fireball_profile jsonb; hyuga_profile jsonb; hyuga_juken jsonb; sedici_target uuid; multiplication_facts jsonb; multiplication_effect jsonb; multiplication_target uuid; v_uid uuid:=auth.uid(); v_r public.combat_v2_rounds%rowtype; v_s public.combat_v2_sessions%rowtype; v_m public.master_v2_sessions%rowtype;
  v_event jsonb; v_event_id uuid; v_values boolean; v_entropy bytea; v_order_entropy bytea; v_before jsonb; v_after jsonb; effects_lifecycle jsonb;
  v_d public.combat_v2_declarations%rowtype; v_def public.combat_v2_declarations%rowtype; v_att public.combat_v2_actors%rowtype; v_tar public.combat_v2_actors%rowtype;
  v_meta jsonb; v_calc jsonb; v_rng jsonb; v_kind text; v_reaction text; v_base int; v_dice_a int; v_dice_d int;
  v_a1 int; v_a2 int; v_d1 int; v_d2 int; v_rng_context text; v_order_context text; v_order_rng jsonb;
  v_vote_a int; v_vote_d int; v_corr int; v_raw int; v_final int; v_damage int; v_full int; v_new_hp int;
  v_report jsonb; v_report_id uuid; v_sha text; v_result jsonb; v_chakra int; v_need int; v_order int:=0;
  v_no_attack_continuation boolean:=false;
  v_fili_hit boolean;
  cellular_calc jsonb; rotation_calc jsonb; flow_calc jsonb; movement_calc jsonb; aburame_calc jsonb; fb_defense_snapshot jsonb;
  akimichi_partial clan_akimichi_private.partial_sources%rowtype;
begin
  if v_uid is null and not public.combat_v2_is_service() then perform public.combat_v2_fail('autenticazione_richiesta','Autenticazione richiesta.',401,p_request_key,'{}'); end if;
  perform public.combat_v2_lock_round(p_round);
  select * into v_r from public.combat_v2_rounds where id=p_round for update;
  if v_r.id is null then perform public.combat_v2_fail('sessione_inesistente','Round inesistente.',404,p_request_key,'{}'); end if;
  select * into v_s from public.combat_v2_sessions where id=v_r.session_id for update;
  if v_s.master_session_id is not null then select * into v_m from public.master_v2_sessions where id=v_s.master_session_id for update; end if;
  v_no_attack_continuation:=v_uid is not null and v_s.source_kind='master' and not combat_consumer_private.owns_round(p_round) and v_r.phase='risoluzione'
    and (select count(*) from public.combat_v2_declarations where round_id=p_round and kind in ('attacco','movimento','utilita','passa') and state not in ('annullata','superflua'))=combat_consumer_private.expected_main_count(p_round)
    and (not exists(select 1 from public.combat_v2_attack_targets t join public.combat_v2_declarations d on d.id=t.attack_declaration_id where t.round_id=p_round and t.state not in ('annullata','superflua') and d.state not in ('annullata','superflua'))
      or (v_r.evaluation_mode='neutra' and exists(
        select 1 from combat_panel_private.multiplication_predefense_plans where round_id=p_round)
        and not exists(select 1 from public.combat_v2_attack_targets mt
          where mt.round_id=p_round and not combat_panel_private.multiplication_no_defense(mt.id))))
    and exists(select 1 from combat_consumer_private.dispatch_authorizations x
      join public.combat_v2_actors a on a.character_id=x.principal_character_id and a.session_id=v_s.id and a.state='attivo'
      where x.request_key=p_request_key and x.round_id=p_round and x.operation='resolve' and x.state='prepared'
        and x.transaction_id=txid_current() and exam_regia_private.actor_principal(a.id,a.controller_user)=v_uid
        and exists(select 1 from public.combat_v2_declarations d where d.id=(select z.id from public.combat_v2_declarations z where z.round_id=p_round and z.kind in ('attacco','movimento','utilita','passa') and z.state not in ('annullata','superflua') order by z.created_at desc,z.id desc limit 1) and d.actor_id=a.id and d.controller_user_snapshot=v_uid and d.controller_version_snapshot=a.controller_version));
  if v_s.source_kind='master' and v_m.master_user<>v_uid and not public.combat_v2_is_service() and not v_no_attack_continuation then perform public.combat_v2_fail('master_non_proprietario','Solo il Master corrente può risolvere.',403,p_request_key,'{}'); end if;
  if v_no_attack_continuation then update combat_consumer_private.dispatch_authorizations set state='consumed' where request_key=p_request_key and round_id=p_round and operation='resolve' and transaction_id=txid_current() and state='prepared'; end if;
  if combat_consumer_private.owns_round(p_round) then perform combat_consumer_private.assert_dispatch(p_round,p_request_key,'resolve'); else if v_s.source_kind='ordinary' and not public.combat_v2_is_service() then perform public.combat_v2_fail('controllo_revocato','Risoluzione ordinary solo server.',403,p_request_key,'{}'); end if; end if;
  perform public.combat_v2_assert_operational(p_round,p_request_key,false);
  -- [MISSION-GUARD-005] Precheck globale prima di evento, freeze e costi.
  if exists(select 1 from public.combat_v2_declarations d
     where d.round_id=p_round and d.kind in ('difesa','nessuna')
       and(coalesce(d.sanitized_intent->>'reaction','nessuna')='copie'
        or(coalesce(d.sanitized_intent->>'reaction','nessuna')='tecnica'
          and coalesce(d.sanitized_intent#>>'{server_ability,targeting,mode}','')not in('intercept','multi_protect')
          and NOT EXISTS(SELECT 1 FROM clan_hyuga_private.rotation_sources rs WHERE rs.declaration_id=d.id) AND NOT combat_v2_elemental_internal.scudo_source_valid(d.id) AND NOT clan_aburame_private.clone_source_valid(d.id) AND NOT clan_akimichi_private.cellular_source_valid_v1(d.id)))
  ) then
    perform public.combat_v2_fail('profilo_runtime_non_disponibile','La difesa speciale non ha un resolver V2 attivo.',409,p_request_key,'{}');
  end if;
  v_event:=public.combat_v2_event_begin(p_round,p_request_key,'combat_v2_round_resolve',jsonb_build_object('round',p_round),v_m.control_version);
  if (v_event->>'replay')::boolean then return v_event->'result'; end if; v_event_id:=(v_event->>'event_id')::uuid;
  if v_r.state in ('risolto','narrazione','narrato') then
    select public.combat_v2_envelope(p_request_key,jsonb_build_object('report_id',x.id,'report_sha256',x.mechanics_sha256,'replay',true)) into v_result from public.combat_v2_round_reports x where x.round_id=p_round;
    return public.combat_v2_event_complete(v_event_id,v_result);
  end if;
  if (select count(*) from public.combat_v2_declarations where round_id=p_round and kind in ('attacco','movimento','utilita','passa') and state not in ('annullata','superflua')) <>
     combat_consumer_private.expected_main_count(p_round) then
    perform public.combat_v2_fail('dichiarazioni_mancanti','Mancano dichiarazioni principali.',409,p_request_key,'{}'); end if;
  if not combat_v2_multitarget_internal.round_complete(p_round) then
    perform public.combat_v2_fail('difese_mancanti','Mancano difese.',409,p_request_key,'{}'); end if;
  if v_r.evaluation_mode='neutra' then
    insert into public.combat_v2_ratings(declaration_id,session_id,round_id,pg_character_id,rating_kind,value,source,request_key)
    select d.id,v_s.id,p_round,a.character_id,d.kind,0,'neutralita_sistema',gen_random_uuid()
      from public.combat_v2_declarations d join public.combat_v2_actors a on a.id=d.actor_id
     where d.round_id=p_round and d.kind in ('attacco','difesa') and a.actor_kind='pg'
       and not exists(select 1 from public.combat_v2_ratings x where x.declaration_id=d.id and x.is_active);
  elsif exists(select 1 from public.combat_v2_declarations d join public.combat_v2_actors a on a.id=d.actor_id
    where d.round_id=p_round and d.kind in ('attacco','difesa') and a.actor_kind='pg'
      and not exists(select 1 from public.combat_v2_ratings x where x.declaration_id=d.id and x.is_active)) then
    perform public.combat_v2_fail('voto_richiesto','Mancano voti del Master.',409,p_request_key,'{}');
  end if;
  -- Ordine globale: sessione e round sono già bloccati; ora attori e risorse per UUID.
  perform 1 from public.combat_v2_actors a where a.session_id=v_s.id order by a.id for update;
  perform 1 from public.characters c where c.id in (select a.character_id from public.combat_v2_actors a where a.session_id=v_s.id and a.character_id is not null) order by c.id for update;
  v_before:=(select jsonb_agg(jsonb_build_object('actor',a.id,'state',a.state,'position_m',a.position_m,'mechanics',a.mechanics_snapshot) order by a.id) from public.combat_v2_actors a where a.session_id=v_s.id);
  -- Quota Verme solo nel resolve, prima di qualsiasi costo: stessa transazione del ledger.
  PERFORM clan_aburame_private.verme_reserve_round_v1(p_round);
  PERFORM clan_akimichi_private.common_preflight_calories_v1(p_round);
  -- Rivalidazione cumulativa dei costi prima di qualunque consumo.
  for v_att in select * from public.combat_v2_actors a where a.session_id=v_s.id order by a.id loop
    select coalesce(sum(clan_hyuga_private.sedici_frozen_cost(d.actor_id,d.cost_snapshot)),0) into v_need from public.combat_v2_declarations d where d.round_id=p_round and d.actor_id=v_att.id;
    v_chakra:=coalesce((v_att.mechanics_snapshot->>'chakra')::int,0);
    if v_need>v_chakra then perform public.combat_v2_fail('risorsa_insufficiente','Chakra insufficiente al freeze.',409,p_request_key,jsonb_build_object('actor',v_att.id)); end if;
  end loop;
  v_order_entropy:=coalesce(combat_panel_private.multiplication_order_entropy(p_round),extensions.gen_random_bytes(32));
  v_order_context:='combat-v2/r3/order:'||v_s.id::text||':'||p_round::text;
  update public.combat_v2_rounds set phase='congelato',state='congelato',
    rng_order_commitment=encode(extensions.digest(v_order_entropy,'sha256'),'hex'),freeze_at=clock_timestamp()
   where id=p_round;
  with ord as (
    select d.id,row_number() over(order by a.initiative_snapshot desc,
      (('x'||substr(encode(extensions.digest(v_order_entropy||convert_to(a.id::text,'UTF8'),'sha256'),'hex'),1,16))::bit(64)::bigint),a.id) n,
      (('x'||substr(encode(extensions.digest(v_order_entropy||convert_to(a.id::text,'UTF8'),'sha256'),'hex'),1,16))::bit(64)::bigint) tie
    from public.combat_v2_declarations d join public.combat_v2_actors a on a.id=d.actor_id
    where d.round_id=p_round and d.kind in ('attacco','movimento','utilita','passa'))
  update public.combat_v2_declarations d set order_no=ord.n,tie_break=ord.tie,state='congelata',frozen_at=clock_timestamp() from ord where d.id=ord.id;
  v_order_rng:=combat_v2_private.rng_seal(v_s.id,p_round,null,'order',v_order_context,v_order_entropy,
    jsonb_build_object('order_ties',coalesce((select jsonb_object_agg(d.id::text,d.tie_break order by d.id)
      from public.combat_v2_declarations d where d.round_id=p_round and d.kind in ('attacco','movimento','utilita','passa')),'{}'::jsonb)));
  update public.combat_v2_declarations set state='congelata',frozen_at=clock_timestamp() where round_id=p_round and kind in ('difesa','nessuna');
  for v_def in select * from public.combat_v2_declarations where round_id=p_round and kind='difesa' and sanitized_intent->>'reaction'='sostituzione' order by id loop
    perform combat_spatial.substitution_rebase_selected_internal_v1(v_def.id);
    perform public.combat_v2_substitution_resolve_internal_v1(v_def.id,md5(p_request_key::text||'|substitution|'||v_def.id::text)::uuid);
  end loop;
  update public.combat_v2_ratings set frozen_at=clock_timestamp() where round_id=p_round and frozen_at is null;
  v_values:=public.combat_v2_values_written(v_s.id);
  PERFORM clan_aburame_private.sfera_reserve_v1(d.id)
    FROM public.combat_v2_declarations d WHERE d.round_id=p_round AND d.state='congelata'
      AND d.sanitized_intent#>>'{server_ability,aburame_sfera_version}'='aburame-sfera/1'
    ORDER BY d.actor_id,d.id;
  -- Impegno costi di tutte le dichiarazioni; nessun rimborso successivo.
  for v_d in select * from public.combat_v2_declarations where round_id=p_round and not(kind='difesa' and sanitized_intent->>'reaction'='sostituzione') order by actor_id,id loop
    select * into v_att from public.combat_v2_actors where id=v_d.actor_id for update;
    v_need:=clan_hyuga_private.sedici_frozen_cost(v_d.actor_id,v_d.cost_snapshot); v_chakra:=coalesce((v_att.mechanics_snapshot->>'chakra')::int,0);
    insert into public.combat_v2_resource_ledger(session_id,round_id,declaration_id,actor_id,resource_kind,expected_amount,committed_amount,applied_amount,is_simulated,balance_before,balance_after,idempotency_key)
    values(v_s.id,p_round,v_d.id,v_att.id,'chakra',v_need,v_need,case when v_values then v_need else 0 end,not v_values,v_chakra,case when v_values or combat_panel_private.uses_simulated_pools(v_s.id) then v_chakra-v_need else v_chakra end,gen_random_uuid());
    insert into public.combat_v2_resource_ledger(session_id,round_id,declaration_id,actor_id,resource_kind,expected_amount,committed_amount,applied_amount,is_simulated,idempotency_key)
    values(v_s.id,p_round,v_d.id,v_att.id,case when v_d.kind in ('difesa','nessuna') then 'reazione' else 'azione_principale' end,1,1,case when v_values then 1 else 0 end,not v_values,gen_random_uuid());
    if (v_values or combat_panel_private.uses_simulated_pools(v_s.id)) and v_need>0 then
      update public.combat_v2_actors set mechanics_snapshot=jsonb_set(mechanics_snapshot,'{chakra}',to_jsonb(v_chakra-v_need),false) where id=v_att.id;
      if v_values and v_att.actor_kind='pg' then
        perform set_config('app.allow_chakra_delta','1',true); update public.characters set chakra=chakra-v_need where id=v_att.character_id; perform set_config('app.allow_chakra_delta','0',true);
      end if;
    end if;
  end loop;
  PERFORM clan_akimichi_private.cellular_pay_v1(d.id) FROM public.combat_v2_declarations d WHERE d.round_id=p_round AND d.kind='difesa' ORDER BY d.actor_id,d.id;
  PERFORM clan_akimichi_private.freeze_partial(d.id)
    FROM public.combat_v2_declarations d WHERE d.round_id=p_round
      AND d.sanitized_intent->>'ability_source'='clan'
      AND d.sanitized_intent->>'ability_id'='214af896-15f8-43e6-858b-614d2851dd3b'
      AND d.sanitized_intent#>>'{server_ability,akimichi_partial_contract}'='akimichi-partial/1'
    ORDER BY d.actor_id,d.id;
  -- Once per declaration, after BOTH native ledger entries; same transaction.
  PERFORM clan_hoki_private.needle_settle(d.id,true)
    FROM public.combat_v2_declarations d WHERE d.round_id=p_round
      AND d.sanitized_intent#>>'{server_ability,hoki_needle_version}'='hoki-needle/1'
    ORDER BY d.actor_id,d.id;
  PERFORM clan_sabaku_private.flow_consume_sand(d.id)
    FROM public.combat_v2_declarations d WHERE d.round_id=p_round
      AND d.sanitized_intent#>>'{server_ability,sabaku_flow_version}'='sabaku-flow/2'
    ORDER BY d.actor_id,d.id;
  update public.combat_v2_rounds set phase='risoluzione',state='risoluzione' where id=p_round;
  for v_d in select * from public.combat_v2_declarations where round_id=p_round and kind in ('attacco','movimento','utilita','passa') and state<>'risolta' order by order_no loop
    PERFORM combat_v2_genjutsu_internal.resolution_enter(p_round,v_d.id);
    movement_calc:=NULL;aburame_calc:=NULL;
    select * into v_att from public.combat_v2_actors where id=v_d.actor_id for update;
    if v_d.kind='movimento' then
      if combat_panel_private.has_master_geometry(v_s.id) then
        v_calc:=combat_panel_private.resolve_master_movement(v_d.id,p_request_key);
        update public.combat_v2_declarations set state='risolta',outcome=v_calc where id=v_d.id;
      else
        update public.combat_v2_actors set position_m=greatest(0,least(1000,position_m+(v_d.sanitized_intent->>'move_m')::int)) where id=v_att.id;
        update public.combat_v2_declarations set state='risolta',outcome=jsonb_build_object('movement_m',(v_d.sanitized_intent->>'move_m')::int) where id=v_d.id;
      end if;
    elsif v_d.kind='attacco' then
      elemental_order_ready:=false;
      verme_profile:=clan_aburame_private.verme_frozen_v1(v_d.id);
      sfera_profile:=clan_aburame_private.sfera_frozen_v1(v_d.id);
      IF sfera_profile IS NOT NULL THEN
        v_att.mechanics_snapshot:=v_att.mechanics_snapshot||jsonb_build_object('aburame_sfera_profile',sfera_profile);
      END IF;
      IF verme_profile->>'source_lost'='true' THEN
       update public.combat_v2_declarations set state='superflua',outcome=jsonb_build_object('reason','aburame_verme_source_unavailable','refund',false) where id=v_d.id;CONTINUE;
      END IF;
      IF verme_profile IS NOT NULL THEN v_att.mechanics_snapshot:=v_att.mechanics_snapshot||jsonb_build_object('aburame_verme_profile',verme_profile);END IF;
      nara_launch:=combat_panel_private.nara_frozen_launch_v1(v_d.id);
      IF nara_launch IS NOT NULL AND (
        NOT combat_panel_private.nara_launch_resources_match_v1(v_d.actor_id,v_s.id,nara_launch,v_values)
        OR (SELECT count(*) FROM public.combat_v2_attack_targets t WHERE t.attack_declaration_id=v_d.id)<>1
      ) THEN RAISE EXCEPTION 'nara_native_single_target_scope_invalid' USING ERRCODE='55000'; END IF;
      IF v_d.sanitized_intent->>'movement_contract'='combat-panel-movement-attack/1' THEN
        movement_calc:=combat_panel_private.resolve_master_movement(v_d.id,p_request_key);
        IF movement_calc->>'reason_code' IS NOT NULL OR coalesce((movement_calc->>'movement_m')::numeric,0)<=0 THEN
          UPDATE public.combat_v2_declarations SET state='superflua',outcome=jsonb_build_object(
            'reason','movement_attack_unreachable','refund',false,'movement',movement_calc) WHERE id=v_d.id;
          UPDATE public.combat_v2_declarations SET state='risolta',outcome=jsonb_build_object(
            'linked_attack',v_d.id,'reason','movement_attack_unreachable') WHERE parent_attack_id=v_d.id;
          CONTINUE;
        END IF;
      END IF;
      IF v_d.sanitized_intent#>>'{server_ability,hoki_needle_version}'='hoki-needle/1'
        AND clan_hoki_private.needle_finish_blocked(v_d.id,movement_calc) THEN CONTINUE; END IF;
      SELECT * INTO akimichi_partial FROM clan_akimichi_private.partial_sources WHERE declaration_id=v_d.id;
      IF akimichi_partial.declaration_id IS NOT NULL
        AND clan_akimichi_private.partial_finish_blocked(v_d.id,movement_calc) THEN CONTINUE; END IF;
      hyuga_profile:=clan_hyuga_private.sedici_resolve_profile(v_d.id);
      hyuga_juken:=clan_hyuga_private.juken_resolve_profile(v_d.id);
      IF hyuga_profile->>'source_lost'='true' THEN
        PERFORM clan_hyuga_private.sedici_finish_lost(v_d.id); CONTINUE;
      ELSIF hyuga_juken->>'status'='source_lost' THEN
        PERFORM clan_hyuga_private.juken_finish_lost(v_d.id); CONTINUE;
      END IF;
      IF hyuga_profile IS NOT NULL THEN
        v_att.mechanics_snapshot:=v_att.mechanics_snapshot||jsonb_build_object('sedici_profile',hyuga_profile);
        IF hyuga_juken IS NOT NULL THEN RAISE EXCEPTION 'hyuga_profile_stacking_forbidden'; END IF;
      END IF;
      fireball_profile:=clan_uchiha_private.fireball_resolve_profile(v_d.id);
      IF fireball_profile->>'source_lost'='true' THEN PERFORM clan_uchiha_private.fireball_finish_lost(v_d.id);CONTINUE;END IF;
      IF fireball_profile IS NOT NULL THEN v_att.mechanics_snapshot:=v_att.mechanics_snapshot||jsonb_build_object('projectile_fireball',fireball_profile);END IF;

        if v_d.sanitized_intent->>'ability_source'='clan' and v_d.sanitized_intent->>'ability_id'='e361f7c3-f90b-47ec-bfee-ccbda21257d9' then
          begin
            v_calc:=public.combat_v2_clan_genin_marionettisti_resolve_v1(jsonb_build_object('contract_version','marionetta-round-hook/1','declaration_id',v_d.id,'request_key',p_request_key));
            v_att.mechanics_snapshot:=v_att.mechanics_snapshot||jsonb_build_object('marionetta_profile',v_calc->'profile');
          exception when sqlstate '22023' or no_data_found then
            update public.combat_v2_declarations set state='superflua',outcome=jsonb_build_object('reason','marionetta_source_unavailable','refund',false) where id=v_d.id;
            continue;
          end;
        end if;

      if (select count(*) from public.combat_v2_attack_targets where attack_declaration_id=v_d.id)=1
          and not exists(select 1 from public.combat_v2_defense_coverages c join public.combat_v2_attack_targets t on t.id=c.attack_target_id where t.attack_declaration_id=v_d.id and c.mode<>'self') then
      select * into v_tar from public.combat_v2_actors where id=v_d.target_actor_id for update;
      if v_tar.state<>'attivo' then
        update public.combat_v2_declarations set state='superflua',outcome=jsonb_build_object('reason','bersaglio_gia_fuori','refund',false) where id=v_d.id;
      else
        SELECT id INTO STRICT multiplication_target FROM public.combat_v2_attack_targets WHERE attack_declaration_id=v_d.id;
        select * into v_def from public.combat_v2_declarations where parent_attack_id=v_d.id;
        v_reaction:=coalesce(v_def.sanitized_intent->>'reaction','nessuna'); v_meta:=v_d.sanitized_intent->'server_ability';
        SELECT id INTO STRICT multiplication_target FROM public.combat_v2_attack_targets WHERE attack_declaration_id=v_d.id;
        multiplication_facts:=combat_panel_private.multiplication_attack_facts(multiplication_target);
        multiplication_effect:=combat_panel_private.multiplication_effect(multiplication_facts,v_reaction);
        v_reaction:=multiplication_effect->>'effective_reaction';
        -- [MISSION-GUARD-006] Guard locale dopo la lettura concorrente.
        if v_reaction in ('copie','tecnica') AND NOT EXISTS(SELECT 1 FROM clan_hyuga_private.rotation_sources rs WHERE rs.declaration_id=v_def.id) AND NOT combat_v2_elemental_internal.scudo_source_valid(v_def.id) AND NOT clan_aburame_private.clone_source_valid(v_def.id) AND NOT clan_akimichi_private.cellular_source_valid_v1(v_def.id) AND NOT combat_v2_genjutsu_internal.kai_defense_valid(v_d.id,v_def.id) then
          perform public.combat_v2_fail('profilo_runtime_non_disponibile','La difesa speciale non ha un resolver V2 attivo.',409,p_request_key,'{}');
        end if;
        v_kind:=lower(coalesce(v_meta->>'kind','fisico')); if v_kind not in ('fisico','ninjutsu','genjutsu') then v_kind:='fisico'; end if;
        v_base:=coalesce((v_d.cost_snapshot->>'damage_base')::int,0);
        v_rng_context:='combat-v2/r3/attack:'||v_s.id::text||':'||p_round::text||':'||v_d.id::text;
        v_entropy:=extensions.gen_random_bytes(32);
        v_a1:=public.combat_v2_derive_d10(v_entropy,v_rng_context,1); v_a2:=public.combat_v2_derive_d10(v_entropy,v_rng_context,2);
        v_d1:=public.combat_v2_derive_d10(v_entropy,v_rng_context,3); v_d2:=public.combat_v2_derive_d10(v_entropy,v_rng_context,4);
        v_dice_a:=v_a1+v_a2; v_dice_d:=v_d1+v_d2;
        fb_defense_snapshot:=combat_facing_private.defense_snapshot(v_d.id,multiplication_target,v_def.actor_id,clan_akimichi_private.cellular_snapshot_v1(v_def.id,clan_aburame_private.clone_defense_snapshot(v_def.id,clan_hyuga_private.rotation_defense_snapshot(v_def.id,CASE WHEN v_tar.companion_id IS NOT NULL THEN clan_marionettisti_private.defense_snapshot(v_def.actor_id,v_tar.id,v_reaction)
           ELSE clan_innata_combat_private.velo_frozen_snapshot_v1(clan_marionettisti_private.defense_snapshot(v_def.actor_id,v_tar.id,v_reaction),coalesce(v_def.actor_id,v_tar.id),coalesce(v_def.id,v_d.id))
           END))),v_reaction);
        IF nara_launch IS NOT NULL AND (
          hyuga_juken IS NOT NULL OR hyuga_profile IS NOT NULL OR fireball_profile IS NOT NULL
          OR v_kind<>'ninjutsu' OR v_base<>0
        ) THEN RAISE EXCEPTION 'nara_native_profile_conflict' USING ERRCODE='55000'; END IF;
        v_calc:=clan_inuzuka_private.attack_calculate(v_d.id,hyuga_juken->'profile',v_kind,
          clan_innata_combat_private.velo_frozen_snapshot_v1(
            CASE WHEN nara_launch IS NULL THEN v_att.mechanics_snapshot ELSE
              v_att.mechanics_snapshot||jsonb_build_object('mente',nara_launch->'kg','ninjutsu',nara_launch->'ninjutsu') END,
            v_att.id,v_d.id),
          fb_defense_snapshot,v_reaction,
          coalesce(v_def.sanitized_intent->'server_ability'->>'kind','taijutsu'),v_base,v_meta->>'element',v_dice_a,v_dice_d,(multiplication_effect->>'assault_bonus')::integer,clan_inuzuka_private.defense_guardia(v_def.sanitized_intent),false);
        IF akimichi_partial.declaration_id IS NOT NULL THEN
          v_calc:=clan_akimichi_private.partial_rebase_native(
            v_calc,akimichi_partial.kg,akimichi_partial.taijutsu,akimichi_partial.mass);
          v_base:=v_base+akimichi_partial.mass;
        END IF;
        v_calc:=clan_akimichi_private.cellular_mark_v1(v_def.id,v_calc);
        v_calc:=clan_akimichi_private.form_impact(v_d.id,v_def.actor_id,v_tar.id,v_kind,v_reaction,
          coalesce(v_def.sanitized_intent#>>'{server_ability,kind}','taijutsu'),v_calc);
        v_base:=v_base+coalesce((v_calc#>>'{akimichi_form,body_mass}')::integer,0);
        IF nara_launch IS NOT NULL THEN
          v_calc:=v_calc||jsonb_build_object('off',nara_launch->'power',
            'danno_grezzo',0,'danno_applicato',0,'striscio',false,'cap_attivo',false);
        END IF;
        v_calc:=v_calc||jsonb_build_object('mod_assalto',multiplication_effect->'assault_bonus','mod_mira',0);
                v_calc:=combat_v2_genjutsu_internal.comparison(v_d.id,v_def.id,v_calc);
        v_rng:=combat_v2_private.rng_seal(v_s.id,p_round,v_d.id,'attack',v_rng_context,v_entropy,
          jsonb_build_object(
            'dice_attack',jsonb_build_array(v_a1,v_a2),
            'dice_defense',jsonb_build_array(v_d1,v_d2),
            'pools',jsonb_build_object('attack',v_calc->'pool_att','defense',v_calc->'pool_dif'),
            'modifiers',jsonb_build_object(
              'mira',v_calc->'mod_mira','assalto',v_calc->'mod_assalto','guardia',v_calc->'mod_guardia','colto',v_calc->'mod_colto',
              'slancio',v_calc->'mod_slancio','element_attack',v_calc->'mod_elem_att','element_defense',v_calc->'mod_elem_dif'),
            'totals',jsonb_build_object('attack',v_calc->'atk_tot','defense',v_calc->'def_tot','margin',v_calc->'margine')
          ));
        select coalesce((select value from public.combat_v2_ratings where declaration_id=v_d.id and is_active order by created_at desc limit 1),0) into v_vote_a;
        select coalesce((select value from public.combat_v2_ratings where declaration_id=v_def.id and is_active order by created_at desc limit 1),0) into v_vote_d;
        v_corr:=greatest(-3,least(3,v_vote_a-CASE WHEN (multiplication_effect->>'defense_spent_on_copy')::boolean THEN 0 ELSE v_vote_d END)); v_raw:=(v_calc->>'margine')::int;
        if v_reaction='sostituzione' then v_corr:=0; end if;
        v_final:=v_raw+v_corr+coalesce((v_calc->>'mod_risonanza')::integer,0);
        -- B4: la claim modifica soltanto la soglia; il margine danno resta nativo.
        elemental_claim:=combat_v2_elemental_internal.comparison_reserve(v_d.id,multiplication_target,v_def.id);
        elemental_channels:=NULL;
        IF elemental_claim IS NOT NULL THEN
          elemental_channels:=combat_v2_elemental_internal.comparison_channels(
            v_d.id,multiplication_target,v_def.id,v_calc,v_corr,(elemental_claim->>'event_id')::uuid);
          v_final:=(elemental_channels->>'hit_margin')::integer;
          v_calc:=v_calc||jsonb_build_object('elemental_comparison',elemental_channels);
          v_calc:=v_calc||jsonb_build_object('common_effects',
            coalesce(v_calc->'common_effects','{}'::jsonb)||(elemental_channels->'common_effects'));
        END IF;
        IF NOT coalesce((multiplication_effect->>'copy_intercepted')::boolean,false) AND NOT coalesce((multiplication_effect->>'defense_spent_on_copy')::boolean,false) THEN
          elemental_channels:=combat_v2_elemental_internal.other_comparison(v_d.id,v_def.id,v_calc,v_final);
          v_final:=(elemental_channels->>'hit_margin')::integer;v_calc:=elemental_channels->'calculation';
        END IF;
        if (multiplication_effect->>'copy_intercepted')::boolean or v_reaction='sostituzione' or v_kind='genjutsu' and v_final<0 or v_reaction='copie' and v_final<0 then v_damage:=0;
        elsif v_final<0 then v_damage:=greatest(1,greatest(1,v_base+((v_calc->>'off')::int/4)-(v_calc->>'riduzione')::int)/4);
        else
          v_full:=greatest(1,v_base+((v_calc->>'off')::int/4)+coalesce((v_calc->>'bonus_margine')::int,0)-(v_calc->>'riduzione')::int);
          v_damage:=least(65,v_full);
        end if;
        flow_calc:=NULL;
        IF v_meta->>'sabaku_flow_version'='sabaku-flow/2' THEN
          flow_calc:=clan_sabaku_private.flow_resolve_calculation(v_d.id,v_tar.id,v_calc,v_corr,
            coalesce((multiplication_effect->>'copy_intercepted')::boolean,false),v_reaction='sostituzione');
          v_final:=(flow_calc->>'hit_margin')::integer;v_damage:=(flow_calc->>'damage_applied')::integer;
          v_calc:=v_calc||jsonb_build_object('sabaku_flow',flow_calc,'off',flow_calc->'power',
            'bonus_margine',flow_calc->'damage_margin_bonus','danno_grezzo',flow_calc->'full_damage_uncapped',
            'danno_applicato',flow_calc->'damage_applied','colpito',flow_calc->'success','striscio',flow_calc->'striscio');
        END IF;
        IF akimichi_partial.declaration_id IS NOT NULL THEN
          v_calc:=clan_akimichi_private.partial_damage(v_calc,v_final,v_reaction='sostituzione'
            OR coalesce((multiplication_effect->>'copy_intercepted')::boolean,false));
          v_damage:=(v_calc->>'danno_applicato')::integer;
        END IF;
        -- B5: credito originario dopo il danno nativo, prima di Rotazione/armatura/PV.
        IF nara_launch IS NOT NULL THEN v_damage:=0; END IF;
                IF v_calc#>>'{paralisi,contract}'='paralisi-movement/1' THEN v_damage:=0;END IF;
        IF sfera_profile IS NOT NULL THEN
          v_damage:=0;
          v_calc:=v_calc||jsonb_build_object('danno_grezzo',0,'danno_applicato',0,'striscio',false,'cap_attivo',false);
        END IF;
        elemental_cap:=combat_effects_private.capture_source_cap(v_d.id,v_damage);
        IF elemental_cap<>'{}'::jsonb THEN
          v_calc:=v_calc||jsonb_build_object('common_effects',
            coalesce(v_calc->'common_effects','{}'::jsonb)||elemental_cap);
        END IF;
        IF clan_aburame_private.release_source_valid(v_d.id) THEN
          aburame_calc:=clan_aburame_private.release_resolve(v_d.id,v_tar.id,v_calc,v_final,
            v_reaction<>'sostituzione' AND NOT coalesce((multiplication_effect->>'copy_intercepted')::boolean,false));
          v_damage:=0;v_calc:=v_calc||jsonb_build_object('aburame_release',aburame_calc,'danno_applicato',0,'striscio',false);
        END IF;
        cellular_calc:=CASE WHEN v_reaction='tecnica' AND NOT coalesce((multiplication_effect->>'defense_spent_on_copy')::boolean,false) AND NOT coalesce((multiplication_effect->>'copy_intercepted')::boolean,false) THEN clan_akimichi_private.cellular_calculate_v1(v_def.id,v_calc,v_final,v_base) END;
        IF cellular_calc IS NOT NULL THEN
          v_damage:=(cellular_calc->>'damage_after')::integer;
          v_calc:=v_calc||jsonb_build_object('akimichi_cellular',cellular_calc,'danno_applicato',v_damage,'striscio',false);
        END IF;
        rotation_calc:=clan_hyuga_private.rotation_calculate(v_def.id,v_calc,v_final,v_base);
        IF rotation_calc IS NOT NULL THEN
          v_damage:=(rotation_calc->>'damage_after')::integer;
          v_calc:=v_calc||jsonb_build_object('hyuga_rotation',rotation_calc,'danno_applicato',v_damage,'striscio',false);
        END IF;
        IF clan_aburame_private.clone_source_valid(v_def.id) THEN
          aburame_calc:=clan_aburame_private.clone_resolve(v_def.id,v_calc,v_final,v_base,p_request_key);
          v_damage:=(aburame_calc->>'damage_after')::integer;
          v_calc:=v_calc||jsonb_build_object('aburame_clone',aburame_calc,'danno_applicato',v_damage,'striscio',false);
        END IF;
        IF aburame_calc->>'version'='aburame-release/1' THEN
          v_damage:=0;v_calc:=v_calc||jsonb_build_object('danno_applicato',0,'striscio',false);
        END IF;
        IF akimichi_partial.declaration_id IS NOT NULL AND (
          v_final<=0 OR v_reaction='sostituzione' OR coalesce((multiplication_effect->>'copy_intercepted')::boolean,false)
        ) THEN
          v_damage:=0;
          v_calc:=v_calc||jsonb_build_object('danno_applicato',0,'striscio',false,'colpito',false);
          IF rotation_calc IS NOT NULL THEN
            rotation_calc:=rotation_calc||jsonb_build_object('damage_after',0);
            v_calc:=v_calc||jsonb_build_object('hyuga_rotation',rotation_calc);
          END IF;
          IF aburame_calc->>'version'='aburame-clone/1' THEN
            aburame_calc:=aburame_calc||jsonb_build_object('damage_after',0);
            v_calc:=v_calc||jsonb_build_object('aburame_clone',aburame_calc);
          END IF;
        END IF;
        IF nara_launch IS NOT NULL OR v_d.sanitized_intent->'target_fili'='true'::jsonb THEN
          v_damage:=0;
          v_calc:=v_calc||jsonb_build_object('danno_grezzo',0,'danno_applicato',0,'striscio',false,'cap_attivo',false);
        END IF;
                IF sfera_profile IS NOT NULL THEN
          v_damage:=0;
          v_calc:=v_calc||jsonb_build_object('danno_applicato',0,'striscio',false);
        ELSIF v_calc#>>'{paralisi,contract}' IS DISTINCT FROM 'paralisi-movement/1' THEN
        v_calc:=v_calc||jsonb_build_object('sabaku_armor',clan_sabaku_private.armor_absorb(multiplication_target,v_damage));
        v_damage:=(v_calc#>>'{sabaku_armor,damage_after}')::integer;
        IF NOT (v_calc->'sabaku_armor' ? 'version') THEN v_calc:=v_calc-'sabaku_armor'; END IF;
        END IF;
        verme_result:=clan_aburame_private.verme_finish_v1(v_d.id,v_tar.id,
         v_final>=0 AND v_reaction<>'sostituzione' AND NOT coalesce((multiplication_effect->>'copy_intercepted')::boolean,false),v_damage);
        IF verme_result IS NOT NULL THEN v_calc:=v_calc||jsonb_build_object('aburame_verme',verme_result);END IF;
        IF sfera_profile IS NOT NULL THEN
          sfera_result:=clan_aburame_private.sfera_finish_v1(v_d.id,v_tar.id,
            clan_aburame_private.sfera_hits_v1(v_final,v_reaction,(multiplication_effect->>'copy_intercepted')::boolean,
              v_calc->'aburame_clone',rotation_calc,cellular_calc));
          v_damage:=0;
          v_calc:=v_calc||jsonb_build_object('aburame_sfera',sfera_result,'danno_applicato',0,'striscio',false);
        END IF;
        v_new_hp:=greatest(0,coalesce((v_tar.mechanics_snapshot->>'vita')::int,0)-v_damage);
        update public.combat_v2_actors set mechanics_snapshot=jsonb_set(mechanics_snapshot,'{vita}',to_jsonb(v_new_hp),false),state=case when v_new_hp=0 then 'fuori' else state end where id=v_tar.id;
        if v_values and v_tar.actor_kind='pg' and v_damage>0 then
          perform set_config('app.allow_vita_delta','1',true); update public.characters set vita=v_new_hp where id=v_tar.character_id; perform set_config('app.allow_vita_delta','0',true);
        end if;
        update public.combat_v2_actors set mechanics_snapshot=jsonb_set(mechanics_snapshot,'{slancio}',to_jsonb(CASE WHEN (CASE WHEN akimichi_partial.declaration_id IS NOT NULL THEN (v_calc->>'colpito')::boolean
           ELSE v_final>=0 AND NOT (multiplication_effect->>'copy_intercepted')::boolean END)
          THEN 0 ELSE least(9,coalesce((mechanics_snapshot->>'slancio')::int,0)+3) END),true) where id=v_att.id;
        elemental_order_outcome:=jsonb_build_object('raw',v_calc,'rng_audit',v_rng,'rating_attack',v_vote_a,'rating_defense',v_vote_d,
          'quality_correction',v_corr,'quality_applicable',v_reaction<>'sostituzione','threshold_margin',v_final,'success',CASE WHEN v_calc#>>'{paralisi,contract}'='paralisi-movement/1' THEN combat_v2_genjutsu_internal.success(v_calc,v_final,(multiplication_effect->>'copy_intercepted')::boolean) WHEN akimichi_partial.declaration_id IS NOT NULL THEN (v_calc->>'colpito')::boolean
            ELSE v_final>=0 AND v_reaction<>'sostituzione' AND NOT (multiplication_effect->>'copy_intercepted')::boolean END,
          'damage_applied',v_damage,'target_hp_after',v_new_hp,'ko',v_new_hp=0,'copies_outcome',case when v_reaction='copie' and v_final<0 then 'copia_colpita' when v_reaction='copie' then 'originale_individuato' end)||CASE WHEN jsonb_array_length(multiplication_facts)>0 THEN jsonb_build_object(
            'multiplication',multiplication_facts,'multiplication_effect',multiplication_effect) ELSE '{}'::jsonb END;
        IF v_d.sanitized_intent->'target_fili'='true'::jsonb THEN
          v_fili_hit:=coalesce((elemental_order_outcome->>'success')::boolean,false)
            AND clan_marionettisti_private.ocular_sever_frozen_valid_v1(v_d.id);
          elemental_order_outcome:=elemental_order_outcome||jsonb_build_object('success',v_fili_hit,'fili_recisi',v_fili_hit);
        END IF;
        IF movement_calc IS NOT NULL THEN
          elemental_order_outcome:=elemental_order_outcome||jsonb_build_object('movement',movement_calc);
        END IF;
        -- Prima della principale terminale: child definitivo e settlement di tutte le conseguenze.
        FOR elemental_target IN SELECT t.id FROM public.combat_v2_attack_targets t
          WHERE t.attack_declaration_id=v_d.id AND t.round_id=p_round
           AND (SELECT count(*) FROM public.combat_v2_attack_targets x WHERE x.attack_declaration_id=v_d.id)=1
           AND NOT EXISTS(SELECT 1 FROM public.combat_v2_defense_coverages c JOIN public.combat_v2_attack_targets x ON x.id=c.attack_target_id
             WHERE x.attack_declaration_id=v_d.id AND c.mode<>'self') ORDER BY t.id LOOP
          IF nara_launch IS NOT NULL THEN
            nara_facts:=combat_panel_private.nara_record_control_v1(elemental_target,elemental_order_outcome);
            elemental_order_outcome:=elemental_order_outcome||jsonb_build_object('nara_possession',nara_facts);
          END IF;
                    elemental_order_outcome:=combat_v2_genjutsu_internal.decorate_outcome(v_d.id,elemental_target,elemental_order_outcome);
          UPDATE public.combat_v2_attack_targets SET state='risolta',outcome=elemental_order_outcome WHERE id=elemental_target;
          PERFORM combat_effects_private.settle_native_target(v_d.id,elemental_target);
        END LOOP;
        UPDATE public.combat_v2_declarations SET state='risolta',outcome=elemental_order_outcome WHERE id=v_d.id;
        IF NOT EXISTS(SELECT 1 FROM public.combat_v2_attack_targets WHERE attack_declaration_id=v_d.id)
          AND v_d.sanitized_intent#>>'{server_ability,hoki_needle_version}'='hoki-needle/1'
        THEN PERFORM clan_hoki_private.needle_result(v_d.id,NULL); END IF;
        IF NOT EXISTS(SELECT 1 FROM public.combat_v2_attack_targets WHERE attack_declaration_id=v_d.id)
        THEN PERFORM clan_hoki_private.body_contact(v_d.id,NULL); END IF;
        elemental_order_ready:=true;
        PERFORM combat_panel_private.multiplication_attack_finish(multiplication_target);
        update public.combat_v2_declarations set state='risolta',outcome=jsonb_build_object('linked_attack',v_d.id)||CASE WHEN cellular_calc IS NULL THEN '{}'::jsonb ELSE jsonb_build_object('akimichi_cellular',cellular_calc) END||CASE WHEN rotation_calc IS NULL THEN '{}'::jsonb ELSE jsonb_build_object('hyuga_rotation',rotation_calc) END where id=v_def.id;
      end if;
      else
        v_calc:=combat_v2_multitarget_internal.resolve_parent(v_s.id,p_round,v_d.id,v_values);
      end if;

      IF movement_calc IS NOT NULL AND NOT elemental_order_ready THEN
        UPDATE public.combat_v2_declarations SET outcome=coalesce(outcome,'{}'::jsonb)||jsonb_build_object('movement',movement_calc) WHERE id=v_d.id;
      END IF;

      PERFORM clan_hyuga_private.rotation_finish(v_d.id,p_request_key);
    elsif v_d.kind='utilita' AND v_d.sanitized_intent#>>'{server_ability,nara_strangle_contract}'='nara-strangolamento/1' THEN
      v_calc:=combat_panel_private.nara_strangle_resolve_v1(v_d.id);
      update public.combat_v2_declarations set state='risolta',outcome=v_calc where id=v_d.id;
    elsif v_d.kind='utilita' AND v_d.sanitized_intent#>>'{server_ability,cure_contract}'='palmo-curativo/1' THEN
      v_calc:=combat_panel_private.cure_resolve_v1(v_d.id);
      update public.combat_v2_declarations set state='risolta',outcome=v_calc where id=v_d.id;
        elsif v_d.kind='utilita' AND v_d.sanitized_intent#>>'{server_ability,genjutsu_release_version}'='paralisi-release/1' THEN
      v_calc:=combat_v2_genjutsu_internal.resolve_release(v_d.id);
      update public.combat_v2_declarations set state='risolta',outcome=v_calc where id=v_d.id;
    elsif v_d.kind='utilita' AND EXISTS(SELECT 1 FROM clan_sabaku_private.clone_plans WHERE declaration_id=v_d.id) THEN
      v_calc:=clan_sabaku_private.clone_resolve_creation(v_d.id);
      update public.combat_v2_declarations set state='risolta',outcome=v_calc where id=v_d.id;
    elsif v_d.kind='utilita' AND EXISTS(SELECT 1 FROM combat_panel_private.immobilization_escape_plans WHERE declaration_id=v_d.id) THEN
      v_calc:=combat_panel_private.immobilization_resolve_escape(v_d.id);
      update public.combat_v2_declarations set state='risolta',outcome=v_calc where id=v_d.id;
    elsif v_d.kind='utilita' AND v_d.sanitized_intent#>>'{server_ability,aburame_sfera_escape}' IS NOT NULL THEN
      v_calc:=clan_aburame_private.sfera_resolve_escape_v1(v_d.id);
      UPDATE public.combat_v2_declarations SET state='risolta',outcome=jsonb_build_object('aburame_sfera_escape',v_calc) WHERE id=v_d.id;
    elsif v_d.kind='utilita' AND v_d.sanitized_intent#>>'{server_ability,aburame_escape_source}' IS NOT NULL THEN
      v_calc:=clan_aburame_private.escape_resolve(v_d.id);
      update public.combat_v2_declarations set state='risolta',outcome=jsonb_build_object('aburame_escape',v_calc) where id=v_d.id;
    else update public.combat_v2_declarations set state='risolta',outcome=jsonb_build_object('kind',v_d.kind) where id=v_d.id;
    end if;
  end loop;
  -- SINGLE_SURFACE_SYNC_R6
  update public.combat_v2_attack_targets t set
    state=case when d.state='superflua'then'superflua'else'risolta'end,
    outcome=d.outcome
  from public.combat_v2_declarations d
  where d.id=t.attack_declaration_id and t.round_id=p_round
    and d.state in('risolta','superflua')
    and (select count(*)from public.combat_v2_attack_targets x where x.attack_declaration_id=d.id)=1
    and not exists(select 1 from public.combat_v2_defense_coverages c join public.combat_v2_attack_targets x on x.id=c.attack_target_id where x.attack_declaration_id=d.id and c.mode<>'self');
  update public.combat_v2_defense_coverages c set state='risolta'
  from public.combat_v2_attack_targets t,public.combat_v2_declarations d,public.combat_v2_declarations a
  where c.attack_target_id=t.id and c.defense_declaration_id=d.id and t.attack_declaration_id=a.id
    and c.round_id=p_round and d.state='risolta'and a.state in('risolta','superflua')
    and (select count(*)from public.combat_v2_attack_targets x where x.attack_declaration_id=a.id)=1
    and not exists(select 1 from public.combat_v2_defense_coverages z join public.combat_v2_attack_targets x on x.id=z.attack_target_id where x.attack_declaration_id=a.id and z.mode<>'self');
  FOR elemental_target IN SELECT t.id FROM public.combat_v2_attack_targets t
    WHERE t.round_id=p_round AND t.state IN ('risolta','superflua') ORDER BY t.id LOOP
    PERFORM combat_effects_private.settle_native_target(
      (SELECT attack_declaration_id FROM public.combat_v2_attack_targets WHERE id=elemental_target),elemental_target);
  END LOOP;
  -- SINGLE_SURFACE_SYNC_R6 has persisted the final native target result.
  FOR sedici_target IN SELECT t.id FROM public.combat_v2_attack_targets t
    JOIN clan_hyuga_private.sedici_sources src ON src.declaration_id=t.attack_declaration_id
    WHERE t.round_id=p_round ORDER BY t.id LOOP
    PERFORM clan_hyuga_private.sedici_apply_result(sedici_target);
  END LOOP;
  PERFORM combat_v2_genjutsu_internal.resolution_leave();
  PERFORM clan_aburame_private.verme_settle_round_v1(p_round);
  PERFORM clan_aburame_private.sfera_settle_round_v1(p_round);
  effects_lifecycle:=combat_effects_private.lifecycle_before_report(p_round);
  v_after:=(select jsonb_agg(jsonb_build_object('actor',a.id,'state',a.state,'position_m',a.position_m,'mechanics',a.mechanics_snapshot) order by a.id) from public.combat_v2_actors a where a.session_id=v_s.id);
  v_report:=jsonb_build_object('initial_actors',v_before,'final_actors',v_after,'effects_lifecycle',effects_lifecycle,
    'hyuga_effects',clan_hyuga_private.sedici_round_facts(p_round),
    'aburame_verme',clan_aburame_private.verme_report_v1(p_round),
    'declarations',(select jsonb_agg(jsonb_build_object('id',d.id,'actor',d.actor_id,'kind',d.kind,'target',d.target_actor_id,'parent',d.parent_attack_id,'order',d.order_no,'state',d.state,'cost',d.cost_snapshot||jsonb_build_object('chakra',clan_hyuga_private.sedici_frozen_cost(d.actor_id,d.cost_snapshot)),'outcome',d.outcome,'genjutsu_facts',combat_v2_genjutsu_internal.report_projection(d.id),'scudo_facts',CASE WHEN d.kind='difesa' AND d.state='risolta' AND combat_v2_elemental_internal.scudo_source_valid(d.id) THEN combat_v2_elemental_internal.scudo_narrative(d.id) ELSE '{}'::jsonb END,'elemental_facts',CASE WHEN combat_v2_elemental_internal.other_narrative_supported(d.id) THEN combat_v2_elemental_internal.other_narrative_projection(d.id) ELSE '{}'::jsonb END,'suiton_facts',CASE WHEN combat_v2_elemental_internal.suiton_narrative_supported(d.id)
      THEN combat_v2_elemental_internal.suiton_narrative_projection(d.id)||jsonb_build_object(
        'target_actor_id',(SELECT s.target_actor_id FROM combat_v2_elemental_internal.suiton_sources s WHERE s.declaration_id=d.id))
      ELSE NULL END) order by d.order_no nulls last,d.id) from public.combat_v2_declarations d where d.round_id=p_round),
    'attack_targets',(select jsonb_agg(to_jsonb(t) order by t.attack_declaration_id,t.ordinal)from public.combat_v2_attack_targets t where t.round_id=p_round),'defense_coverages',(select jsonb_agg(to_jsonb(c)order by c.defense_declaration_id,c.id)from public.combat_v2_defense_coverages c where c.round_id=p_round),'ledger',(select jsonb_agg(clan_marionettisti_private.ledger_wire(l) order by l.created_at,l.id) from public.combat_v2_resource_ledger l where l.round_id=p_round),
    'rng_order',v_order_rng,'rng_scheme','hmac-sha256-jsonb-pg17/1',
    'substitution_receipts',coalesce((select jsonb_agg(jsonb_build_object('event_id',e.event_id,'event_kind',e.event_kind,'source_application_id',e.root_id,'round_id',l.activity_round_id,'instance_id',e.instance_id,'actor_id',e.actor_id,'narrator_payload',e.narrator_payload) order by e.created_at,e.event_id) from combat_spatial.spatial_events e join combat_spatial.substitution_activity_links l on l.activity_kind='combat_v2' and l.activity_round_id=p_round and l.attack_declaration_id=e.root_id and l.instance_id=e.instance_id and l.defender_actor_id=e.actor_id and l.state='committed' where e.event_kind='substitution_committed'),'[]'::jsonb),'values_written',v_values,'engine_version',v_r.engine_version,'resolver_version',v_r.resolver_version,'order_version',v_r.order_version,'quality_version',v_r.quality_version);
  v_report:=v_report||clan_aburame_private.sfera_report_v1(p_round);
  IF EXISTS(SELECT 1 FROM clan_sabaku_private.flow_sources WHERE round_id=p_round) THEN
    v_report:=v_report||jsonb_build_object('sabaku_flows',clan_sabaku_private.flow_round_facts(p_round));
  END IF;
  IF EXISTS(SELECT 1 FROM clan_sabaku_private.armor_events WHERE round_id=p_round AND event_kind='hit') THEN
    v_report:=v_report||jsonb_build_object('sabaku_armor',clan_sabaku_private.armor_round_facts(p_round));
  END IF;
  IF EXISTS(SELECT 1 FROM combat_panel_private.multiplication_diversivo_receipts WHERE round_id=p_round) THEN
    v_report:=v_report||jsonb_build_object('multiplication_tactics_contract','multiplication-resume/1',
      'multiplication_diversivo',(SELECT jsonb_agg(lure_receipt.result ORDER BY lure_receipt.attack_target_id,lure_receipt.formation_id)
        FROM combat_panel_private.multiplication_diversivo_receipts lure_receipt WHERE lure_receipt.round_id=p_round));
  END IF;
  IF EXISTS(SELECT 1 FROM clan_hoki_private.combat_events e WHERE e.round_id=p_round) THEN
    v_report:=v_report||jsonb_build_object('hoki_facts',clan_hoki_private.round_facts(p_round));
  END IF;
  v_report:=v_report||combat_panel_private.nara_strangle_facts_v1(p_round);
  v_report:=exam_human_private.round_facts_capture_v1(p_round,v_report);
  v_sha:=public.combat_v2_sha256(v_report);
  insert into public.combat_v2_round_reports(round_id,mechanics,mechanics_sha256,values_written,engine_version,resolver_version,order_version,quality_version)
  values(p_round,v_report,v_sha,v_values,v_r.engine_version,v_r.resolver_version,v_r.order_version,v_r.quality_version) returning id into v_report_id;
  update public.combat_v2_rounds set phase='risolto',state='risolto',resolved_at=clock_timestamp(),report_id=v_report_id where id=p_round;
  if clan_marionettisti_private.is_dedicated_scene(v_s.id) then perform clan_marionettisti_private.settle_round_damage(v_report_id); perform clan_inuzuka_private.settle_round_damage(v_report_id);end if;
  v_result:=public.combat_v2_envelope(p_request_key,jsonb_build_object('report_id',v_report_id,'report_sha256',v_sha,'mechanics',v_report));
  return public.combat_v2_event_complete(v_event_id,v_result);
end $function$;

CREATE OR REPLACE FUNCTION public.combat_consumer_narrative_claim_v1(p_round uuid, p_report_sha256 text, p_request_key uuid)
 RETURNS jsonb
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO ''
AS $function$
declare ctx combat_consumer_private.activities%rowtype; report public.combat_v2_round_reports%rowtype;
  authority combat_consumer_private.narrative_authorities%rowtype;
  claim combat_consumer_private.narrative_claims%rowtype; payload jsonb;
begin
  if not combat_consumer_private.is_service_request() then perform combat_consumer_private.fail('not_participant'); end if;
  if p_request_key is null then perform combat_consumer_private.fail('identifier_invalid'); end if;
  perform public.combat_v2_lock_round(p_round);
  if exists(select 1 from combat_consumer_private.recovery_claims_v1 where round_id=p_round) then raise exception 'legacy_claim_recovery_fenced'; end if;
  select * into ctx from combat_consumer_private.activities where exchange_id=p_round for update;
  if ctx.session_id is null or ctx.phase<>'resolved' then
    return jsonb_build_object('should_call_provider',false,'state','not_ready');
  end if;
  select * into report from public.combat_v2_round_reports where round_id=p_round for update;
  select * into authority from combat_consumer_private.narrative_authorities where session_id=ctx.session_id for update;
  select * into claim from combat_consumer_private.narrative_claims where round_id=p_round for update;
  if claim.id is not null then
    if claim.request_key<>p_request_key or claim.report_sha256 is distinct from p_report_sha256 then
      perform combat_consumer_private.fail('request_key_conflict',p_request_key);
    end if;
    if claim.state='claimed' and claim.expires_at<clock_timestamp() then
      update combat_consumer_private.narrative_claims set state='expired',failure_code='timeout' where id=claim.id;
      claim.state:='expired';
    end if;
    -- Ripetizione non consegna di nuovo il permesso a chiamare il provider.
    return jsonb_build_object('claim_id',claim.id,'should_call_provider',false,'state',claim.state,
      'completion',claim.completion_result);
  end if;
  if not combat_consumer_private.narrative_allowed(ctx.session_id)
    or authority.mode is distinct from 'ai_auto' then
    return jsonb_build_object('should_call_provider',false,'state','disabled');
  end if;
  if report.id is null or report.mechanics_sha256 is distinct from p_report_sha256 or report.narration_state<>'attesa' then
    perform combat_consumer_private.fail('context_stale',p_request_key);
  end if;
  payload:=combat_consumer_private.narrative_context(p_round);
  insert into combat_consumer_private.narrative_claims(session_id,round_id,report_id,report_sha256,
    context_version,control_version,context_payload,context_sha256,request_key,state,expires_at)
    values(ctx.session_id,p_round,report.id,report.mechanics_sha256,ctx.context_version,authority.control_version,
      payload,public.combat_v2_sha256(payload),p_request_key,'claimed',clock_timestamp()+interval '60 seconds') returning * into claim;
  return jsonb_build_object('claim_id',claim.id,'should_call_provider',true,'state',claim.state,
    'report_id',claim.report_id,'round_id',claim.round_id,
    'report_sha256',claim.report_sha256,'context_sha256',claim.context_sha256,'control_version',claim.control_version,
    'edge_revision',case when payload->>'genere'='rinuncia' then 'ordinary-rinuncia/1' when payload->>'genere'='azione_risolta' then 'ordinary-facts/1' else 'ordinary-adapter/1' end,'validator_revision',case when payload->>'genere'='rinuncia' then 'combat-rinuncia/1' when payload->>'genere'='azione_risolta' then CASE WHEN payload->'fatti' ? 'aburame_sfera_server' THEN clan_aburame_private.sfera_narrative_revision_v1(payload->'fatti') WHEN payload->'fatti' ? 'nara_strangle_server' THEN combat_panel_private.nara_strangle_facts_revision_v1(payload->'fatti') WHEN payload->'fatti' ? 'aburame_verme_server' THEN 'combat-facts/3' WHEN payload->'fatti' ?| ARRAY['genjutsu_server','genjutsu_events'] OR payload#>'{fatti,result}' ?| ARRAY['healing','mental_release'] THEN 'combat-facts/2' ELSE 'combat-facts/1' END else 'combat-narratore-v18-existing/1' end,
    'provider','openai','model','gpt-6-luna','expires_at',claim.expires_at,'context',payload);
end $function$;
CREATE OR REPLACE FUNCTION public.combat_consumer_narrative_complete_v1(p_claim uuid, p_result jsonb, p_request_key uuid)
 RETURNS jsonb
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO ''
AS $function$
declare claim combat_consumer_private.narrative_claims%rowtype;
  ctx combat_consumer_private.activities%rowtype; authority combat_consumer_private.narrative_authorities%rowtype;
  fingerprint text; result jsonb;
begin
  if not combat_consumer_private.is_service_request() then perform combat_consumer_private.fail('not_participant'); end if;
  perform combat_consumer_private.validate_narrative_result(p_result);
  select * into claim from combat_consumer_private.narrative_claims where id=p_claim;
  if claim.id is null or claim.request_key is distinct from p_request_key then
    perform combat_consumer_private.fail('request_key_conflict',p_request_key);
  end if;
  perform public.combat_v2_lock_round(claim.round_id);
  if exists(select 1 from combat_consumer_private.recovery_claims_v1 where round_id=claim.round_id) then raise exception 'legacy_claim_recovery_fenced'; end if;
  select * into ctx from combat_consumer_private.activities where session_id=claim.session_id for update;
  select * into authority from combat_consumer_private.narrative_authorities where session_id=claim.session_id for update;
  select * into claim from combat_consumer_private.narrative_claims where id=p_claim for update;
  if (p_result->>'edge_revision',p_result->>'validator_revision') is distinct from
   (case when claim.context_payload->>'genere'='rinuncia' then 'ordinary-rinuncia/1' when claim.context_payload->>'genere'='azione_risolta' then 'ordinary-facts/1' else 'ordinary-adapter/1' end,
    case when claim.context_payload->>'genere'='rinuncia' then 'combat-rinuncia/1' when claim.context_payload->>'genere'='azione_risolta' then CASE WHEN claim.context_payload->'fatti' ? 'aburame_sfera_server' THEN clan_aburame_private.sfera_narrative_revision_v1(claim.context_payload->'fatti') WHEN claim.context_payload->'fatti' ? 'nara_strangle_server' THEN combat_panel_private.nara_strangle_facts_revision_v1(claim.context_payload->'fatti') WHEN claim.context_payload->'fatti' ? 'aburame_verme_server' THEN 'combat-facts/3' WHEN claim.context_payload->'fatti' ?| ARRAY['genjutsu_server','genjutsu_events'] OR claim.context_payload#>'{fatti,result}' ?| ARRAY['healing','mental_release'] THEN 'combat-facts/2' ELSE 'combat-facts/1' END else 'combat-narratore-v18-existing/1' end) then
   raise exception 'rinuncia_result_context_revision_mismatch';end if;
  fingerprint:=public.combat_v2_sha256(p_result);
  if claim.completion_sha256 is not null then
    if claim.completion_sha256<>fingerprint then perform combat_consumer_private.fail('request_key_conflict',p_request_key); end if;
    return claim.completion_result;
  end if;
  if claim.state<>'claimed' or claim.expires_at<clock_timestamp() then
    if claim.state='claimed' then update combat_consumer_private.narrative_claims set state='expired',failure_code='timeout' where id=p_claim; end if;
    return jsonb_build_object('status','not_published','reason','claim_not_active');
  end if;
  if ctx.phase<>'resolved' or ctx.exchange_id is distinct from claim.round_id or ctx.context_version<>claim.context_version
    or authority.mode is distinct from 'ai_auto' or authority.control_version<>claim.control_version
    or not combat_consumer_private.narrative_allowed(ctx.session_id)
    or p_result->>'report_sha256' is distinct from claim.report_sha256
    or p_result->>'context_sha256' is distinct from claim.context_sha256
    or (p_result->>'control_version')::bigint<>claim.control_version
    or not exists(select 1 from public.combat_v2_round_reports where id=claim.report_id and round_id=claim.round_id
      and mechanics_sha256=claim.report_sha256 and narration_state='attesa') then
    update combat_consumer_private.narrative_claims set state='failed',failure_code='context_changed' where id=p_claim;
    return jsonb_build_object('status','not_published','reason','context_changed');
  end if;
  if p_result->>'status'='failed' then
    result:=jsonb_build_object('status','not_published','reason',p_result->>'failure_code');
    update combat_consumer_private.narrative_claims set state='failed',failure_code=p_result->>'failure_code',
      completion_sha256=fingerprint,completion_result=result,provider_response_id=p_result->>'provider_response_id',
      provider_request_sha256=p_result->>'provider_request_sha256',raw_output_sha256=p_result->>'raw_output_sha256' where id=p_claim;
    return result;
  end if;
  if encode(extensions.digest(convert_to(p_result->>'text','UTF8'),'sha256'),'hex') is distinct from p_result->>'text_sha256' then
    raise exception 'narrative_text_hash_invalid';
  end if;
  insert into combat_consumer_private.publish_authorizations
    values(p_request_key,claim.round_id,claim.id,p_result->>'text_sha256',txid_current(),'prepared');
  result:=public.combat_v2_narrative_store(claim.round_id,'fato_ia',p_result->>'text',p_request_key,null);
  update combat_consumer_private.publish_authorizations set state='consumed' where request_key=p_request_key;
  update combat_consumer_private.narrative_claims set state='completed',completion_sha256=fingerprint,
    completion_result=result,provider_response_id=p_result->>'provider_response_id',
    provider_request_sha256=p_result->>'provider_request_sha256',raw_output_sha256=p_result->>'raw_output_sha256' where id=p_claim;
  return result;
end $function$;
CREATE OR REPLACE FUNCTION combat_consumer_private.narrative_declaration_supported(p_declaration uuid)
 RETURNS boolean
 LANGUAGE plpgsql
 STABLE SECURITY DEFINER
 SET search_path TO ''
AS $function$
DECLARE d public.combat_v2_declarations%ROWTYPE; facts jsonb; sid uuid; flow jsonb;
BEGIN
 SELECT * INTO d FROM public.combat_v2_declarations WHERE id=p_declaration;
 IF d.id IS NULL THEN RETURN false; END IF;
 IF d.sanitized_intent#>>'{server_ability,aburame_sfera_version}'='aburame-sfera/1'
    OR d.sanitized_intent#>'{server_ability,aburame_sfera_escape}' IS NOT NULL
    OR d.kind IN('passa','movimento')
       AND clan_aburame_private.sfera_narrative_v1(d.round_id,d.id)?'aburame_sfera_server' THEN
   RETURN d.state IN('risolta','superflua')
     AND clan_aburame_private.sfera_narrative_v1(d.round_id,d.id)?'aburame_sfera_server';
 END IF;
 IF EXISTS(SELECT 1 FROM clan_aburame_private.verme_sources_v1 x WHERE x.declaration_id=d.id AND x.result IS NOT NULL AND x.state IN('resolved','ended')) THEN
  RETURN d.state IN('risolta','superflua') AND clan_aburame_private.verme_narrative_v1(d.round_id,d.id) ? 'aburame_verme_server';
 END IF;
 IF d.kind IN('passa','movimento') AND EXISTS(SELECT 1 FROM clan_aburame_private.verme_events_v1 WHERE round_id=d.round_id AND kind IN('poison_tick','poison_end')) THEN RETURN d.state='risolta';END IF;
 IF d.kind='utilita' AND d.state='risolta' AND d.sanitized_intent#>>'{server_ability,nara_strangle_contract}'='nara-strangolamento/1' THEN RETURN EXISTS(SELECT 1 FROM combat_panel_private.nara_strangle_events_v1 e WHERE e.source_declaration=d.id AND e.round_id=d.round_id AND e.kind='activation' AND e.facts_sha256=public.combat_v2_sha256(e.facts));END IF;
 IF d.sanitized_intent#>>'{server_ability,cure_contract}'='palmo-curativo/1' THEN
   RETURN combat_panel_private.cure_narrative_facts_v1(d.id) IS NOT NULL;
 END IF;
 IF EXISTS(SELECT 1 FROM combat_v2_genjutsu_internal.sources WHERE declaration_id=d.id) OR EXISTS(SELECT 1 FROM combat_v2_genjutsu_internal.release_plans WHERE declaration_id=d.id) THEN RETURN combat_v2_genjutsu_internal.narrative_supported(d.id);END IF;
 IF combat_v2_genjutsu_internal.narrative_supported(d.id) THEN RETURN true;END IF;
 IF d.kind='attacco' AND EXISTS(SELECT 1 FROM clan_sabaku_private.flow_sources WHERE declaration_id=d.id AND round_id=d.round_id AND actor_id=d.actor_id) THEN
   flow:=combat_consumer_private.narrative_flow_round_v1(d.round_id);
   RETURN jsonb_array_length(flow#>'{flussi_server,events}')=1;
 END IF;
 IF d.kind='attacco' AND EXISTS(SELECT 1 FROM combat_v2_elemental_internal.suiton_sources WHERE declaration_id=d.id) THEN
   RETURN combat_v2_elemental_internal.suiton_narrative_supported(d.id);
 END IF;
 IF d.kind='attacco' AND (EXISTS(SELECT 1 FROM combat_v2_elemental_internal.other_sources WHERE declaration_id=d.id) OR EXISTS(SELECT 1 FROM combat_v2_taijutsu_internal.taijutsu_sources WHERE declaration_id=d.id)) THEN RETURN combat_v2_elemental_internal.other_narrative_supported(d.id);END IF;
 IF d.kind='attacco' AND EXISTS(SELECT 1 FROM clan_aburame_private.combat_sources s
   WHERE s.declaration_id=d.id AND s.round_id=d.round_id AND s.owner_actor_id=d.actor_id
     AND s.source_kind='release' AND s.state IN ('prepared','attached','ended')) THEN
   facts:=d.outcome#>'{raw,aburame_release}';
   RETURN coalesce(d.state='risolta'
     AND facts @> '{"version":"aburame-release/1","damage_after":0}'::jsonb
     AND jsonb_typeof(facts->'chakra_drained')='number'
     AND facts->>'chakra_drained' IN ('0','1','2','3','4','5')
     AND facts->>'target_actor_id'=d.target_actor_id::text,false);
 END IF;
 IF d.kind='utilita' AND d.state='risolta'
   AND d.outcome#>>'{aburame_escape,version}'='aburame-escape/1'
   AND jsonb_typeof(d.outcome#>'{aburame_escape,success}')='boolean'
   AND EXISTS(SELECT 1 FROM clan_aburame_private.combat_sources s
     JOIN public.combat_v2_rounds r ON r.id=d.round_id
     WHERE s.id::text=d.outcome#>>'{aburame_escape,source_id}'
       AND s.session_id=r.session_id AND s.source_kind='release'
       AND s.target_actor_id=d.actor_id AND s.state IN ('attached','ended')) THEN
   RETURN true;
 END IF;
 IF d.kind='attacco' AND d.sanitized_intent#>>'{server_ability,nara_launch,schema_version}'='nara-possession/1' THEN
   RETURN combat_panel_private.nara_ordinary_narrative_fact_v1(d.id) IS NOT NULL;
 END IF;
 IF d.state IS DISTINCT FROM 'risolta' THEN RETURN false; END IF;
 IF d.kind='attacco' AND EXISTS(SELECT 1 FROM clan_hoki_private.needle_sources n
     JOIN public.combat_v2_rounds rr ON rr.id=d.round_id AND rr.session_id=n.session_id
     JOIN public.combat_v2_round_reports report ON report.id=rr.report_id AND report.round_id=rr.id
     WHERE n.declaration_id=d.id AND n.state='spent' AND n.actor_id=d.actor_id
       AND n.target_actor_id=d.target_actor_id AND report.mechanics ? 'hoki_facts'
       AND n.declaration_sha256=combat_effects_private.declaration_fingerprint(d.id)
       AND (SELECT count(*) FROM public.combat_v2_attack_targets t
         WHERE t.attack_declaration_id=d.id AND t.state='risolta')=1) THEN RETURN true; END IF;
 IF d.kind='difesa' AND combat_v2_elemental_internal.scudo_source_valid(d.id) THEN RETURN true;END IF;
 IF d.kind='utilita' AND clan_uchiha_private.fireball_source_valid(d.id) THEN RETURN true;END IF;
 IF d.kind='attacco' AND EXISTS(SELECT 1 FROM public.combat_v2_attack_targets mt
   WHERE mt.attack_declaration_id=d.id AND combat_panel_private.multiplication_no_defense(mt.id))
   AND NOT EXISTS(SELECT 1 FROM public.combat_v2_attack_targets mt WHERE mt.attack_declaration_id=d.id
     AND (mt.state NOT IN ('risolta','superflua') OR NOT combat_panel_private.multiplication_no_defense(mt.id))) THEN
   facts:=combat_panel_private.narrative_declaration_facts(d.id);
   RETURN facts->>'schema_version'='combat-narrative-facts/1';
 END IF;
 IF d.kind='utilita' AND EXISTS(SELECT 1 FROM combat_panel_private.multiplication_formations mf
   WHERE mf.declaration_id=d.id AND mf.actor_id=d.actor_id AND mf.mode IN ('copertura','diversivo')
    AND NOT EXISTS(SELECT 1 FROM exam_regia_private.bindings eb WHERE eb.combat_session_id=mf.session_id)) THEN
   facts:=combat_panel_private.narrative_declaration_facts(d.id);
   RETURN facts ? 'multiplication_created';
 END IF;
 IF d.kind='attacco' THEN
   RETURN clan_akimichi_private.narrative_partial_valid(d.id) OR clan_marionettisti_private.narrative_attack_allowed(d.id);
 END IF;
 SELECT session_id INTO sid FROM public.combat_v2_rounds WHERE id=d.round_id;
 IF sid IS NULL THEN RETURN false; END IF;
 IF d.kind='passa' THEN
   RETURN (clan_marionettisti_private.is_dedicated_scene(sid)
     AND coalesce((SELECT rinuncia_enabled FROM clan_marionettisti_private.release_gate WHERE singleton),false))
     OR (d.target_actor_id IS NULL AND d.parent_attack_id IS NULL
       AND d.sanitized_intent->>'kind'='passa'
       AND d.cost_snapshot @> '{"chakra":0}'::jsonb
       AND NOT EXISTS(SELECT 1 FROM public.combat_v2_attack_targets pt WHERE pt.attack_declaration_id=d.id)
       AND EXISTS(SELECT 1 FROM public.combat_v2_actors pa
         WHERE pa.id=d.actor_id AND pa.session_id=sid AND pa.actor_kind='pg'
           AND pa.companion_id IS NULL AND pa.controller_user=d.controller_user_snapshot)
       AND EXISTS(
 SELECT 1 FROM combat_consumer_private.activities turn_scope
 JOIN public.combat_v2_sessions turn_session ON turn_session.id=turn_scope.session_id
 JOIN public.locations turn_location ON turn_location.id=turn_session.location_id
 JOIN combat_panel_private.multiplication_tactics_release_gate turn_gate
   ON turn_gate.singleton AND turn_gate.version>=1
     AND turn_gate.revision_reference='combat-multiplication-tactics/1'
 WHERE turn_scope.session_id=sid AND turn_scope.phase='resolved'
   AND turn_session.source_kind='ordinary' AND turn_session.master_session_id IS NULL
   AND turn_session.state='in_corso' AND turn_session.closed_at IS NULL
   AND turn_scope.location_id=turn_session.location_id AND turn_location.is_active
   AND turn_scope.user_test_context_id IS NULL
   AND (SELECT count(*)=2 AND count(DISTINCT m.character_id)=2
     AND bool_and(coalesce(a.actor_kind='pg' AND a.companion_id IS NULL
       AND a.character_id=m.character_id AND a.controller_user=ch.user_id,false))
     FROM combat_consumer_private.members m
     JOIN public.combat_v2_actors a ON a.id=m.actor_id AND a.session_id=turn_session.id
     JOIN public.characters ch ON ch.id=m.character_id
     WHERE m.session_id=turn_session.id)
   AND (
    (turn_gate.staff_enabled AND turn_location.is_test
      AND turn_location.id='0b85f354-9cdb-47e1-baf9-3d266bb7e06b'::uuid
      AND turn_scope.policy_id='staff_test_no_persistent_resources_v1'
      AND combat_panel_private.uses_simulated_pools(turn_session.id)
      AND NOT public.combat_v2_values_written(turn_session.id)
      AND combat_consumer_private.staff_test_allowed(turn_location.id,
        ARRAY(SELECT a.controller_user FROM combat_consumer_private.members m
          JOIN public.combat_v2_actors a ON a.id=m.actor_id AND a.session_id=turn_session.id
          WHERE m.session_id=turn_session.id ORDER BY a.id),false))
    OR (turn_gate.ordinary_enabled AND NOT turn_location.is_test AND NOT turn_location.is_exam_room)
   )
));
 END IF;
 IF d.kind='movimento' AND EXISTS(SELECT 1 FROM public.combat_v2_round_reports h
   JOIN combat_consumer_private.activities q ON q.exchange_id=h.round_id
   WHERE h.round_id=d.round_id AND q.session_id=sid AND q.phase='resolved'
   AND h.mechanics->'hoki_facts' @> '[{"version":"hoki-minor-poison/1"}]'::jsonb)
 THEN RETURN true; END IF;
 IF d.kind NOT IN ('utilita','movimento') THEN RETURN false; END IF;
 IF NOT EXISTS(SELECT 1 FROM combat_consumer_private.activities c
   JOIN public.combat_v2_sessions s ON s.id=c.session_id
   JOIN public.locations l ON l.id=c.location_id
   WHERE c.session_id=sid AND c.exchange_id=d.round_id AND c.phase='resolved'
     AND l.is_test AND c.policy_id='staff_test_no_persistent_resources_v1'
     AND s.source_kind='ordinary' AND s.location_id=c.location_id
     AND NOT public.combat_v2_values_written(s.id)) THEN RETURN false; END IF;
 facts:=combat_panel_private.narrative_declaration_facts(d.id);
 RETURN CASE WHEN d.kind='utilita' THEN
   (facts ? 'multiplication_created' OR facts->'result' ? 'escape' OR facts ? 'clone_creation')
   ELSE facts ? 'clone_events' END;
END $function$;
CREATE OR REPLACE FUNCTION combat_consumer_private.validate_narrative_result(p jsonb)
 RETURNS void
 LANGUAGE plpgsql
 IMMUTABLE
 SET search_path TO ''
AS $function$
declare k text; keys text[]:=array['schema_version','status','report_sha256','context_sha256','control_version',
  'edge_revision','validator_revision','provider_response_id','provider_request_sha256','raw_output_sha256',
  'text','text_sha256','validation_passed','provider','model','input_tokens','output_tokens','http_attempts','failure_code'];
begin
  if p is null or jsonb_typeof(p)<>'object' or not(p ?& keys)
    or exists(select 1 from jsonb_object_keys(p) x where not(x=any(keys))) then raise exception 'narrative_result_shape_invalid'; end if;
  if p->>'schema_version' is distinct from 'ordinary-narrative-result/1'
    or ((p->>'edge_revision',p->>'validator_revision') is distinct from ('ordinary-adapter/1','combat-narratore-v18-existing/1')
     and (p->>'edge_revision',p->>'validator_revision') is distinct from ('ordinary-rinuncia/1','combat-rinuncia/1')
     and (p->>'edge_revision',p->>'validator_revision') is distinct from ('ordinary-facts/1','combat-facts/1')
     and (p->>'edge_revision',p->>'validator_revision') is distinct from ('ordinary-facts/1','combat-facts/2')
     and (p->>'edge_revision',p->>'validator_revision') is distinct from ('ordinary-facts/1','combat-facts/3')
     and (p->>'edge_revision',p->>'validator_revision') is distinct from ('ordinary-facts/1','combat-facts/4')
     and (p->>'edge_revision',p->>'validator_revision') is distinct from ('ordinary-facts/1','combat-facts/5'))
    or p->>'provider' is distinct from 'openai' or p->>'model' is distinct from 'gpt-6-luna'
    or p->>'status' is null or p->>'status' not in ('succeeded','failed')
    or jsonb_typeof(p->'validation_passed')<>'boolean' then raise exception 'narrative_result_contract_invalid'; end if;
  foreach k in array array['control_version','http_attempts'] loop
    if jsonb_typeof(p->k)<>'number' then raise exception 'narrative_result_number_invalid'; end if;
    if (p->>k)::numeric<>trunc((p->>k)::numeric) or (p->>k)::numeric<0 then raise exception 'narrative_result_number_invalid'; end if;
  end loop;
  if (p->>'control_version')::numeric<1 or (p->>'http_attempts')::numeric>1 then raise exception 'narrative_result_number_invalid'; end if;
  foreach k in array array['input_tokens','output_tokens'] loop
    if p->k<>'null'::jsonb then
      if jsonb_typeof(p->k)<>'number' then raise exception 'narrative_result_number_invalid'; end if;
      if (p->>k)::numeric<0 or (p->>k)::numeric<>trunc((p->>k)::numeric) then raise exception 'narrative_result_number_invalid'; end if;
    end if;
  end loop;
  foreach k in array array['report_sha256','context_sha256'] loop
    if jsonb_typeof(p->k)<>'string' or (p->>k)!~'^[a-f0-9]{64}$' then raise exception 'narrative_result_hash_invalid'; end if;
  end loop;
  foreach k in array array['provider_request_sha256','raw_output_sha256','text_sha256'] loop
    if p->k<>'null'::jsonb and (jsonb_typeof(p->k)<>'string' or (p->>k)!~'^[a-f0-9]{64}$') then
      raise exception 'narrative_result_hash_invalid';
    end if;
  end loop;
  if p->'provider_response_id'<>'null'::jsonb and
    (jsonb_typeof(p->'provider_response_id')<>'string' or length(p->>'provider_response_id') not between 1 and 200) then
    raise exception 'narrative_result_provenance_invalid';
  end if;
  if p->>'status'='succeeded' then
    if p->'provider_response_id'='null'::jsonb or p->'provider_request_sha256'='null'::jsonb
      or p->'raw_output_sha256'='null'::jsonb or p->'text_sha256'='null'::jsonb
      or p->'input_tokens'='null'::jsonb or p->'output_tokens'='null'::jsonb
      or (p->>'output_tokens')::numeric<=0 or (p->>'http_attempts')::integer<>1
      or not (p->>'validation_passed')::boolean or p->'failure_code'<>'null'::jsonb
      or jsonb_typeof(p->'text')<>'string' or length(btrim(p->>'text')) not between 500 and 1500 then
      raise exception 'narrative_result_success_invalid';
    end if;
  elsif p->'text'<>'null'::jsonb or p->'text_sha256'<>'null'::jsonb or (p->>'validation_passed')::boolean
    or p->>'failure_code' is null or p->>'failure_code' not in ('provider_error','validation_rejected','timeout','configuration_mismatch') then
    raise exception 'narrative_result_failure_invalid';
  end if;
end $function$;
CREATE OR REPLACE FUNCTION combat_panel_private.narrative_declaration_facts(p_declaration uuid)
 RETURNS jsonb
 LANGUAGE plpgsql
 STABLE SECURITY DEFINER
 SET search_path TO ''
AS $function$
DECLARE d public.combat_v2_declarations%ROWTYPE; f combat_panel_private.multiplication_formations%ROWTYPE;
 t public.combat_v2_attack_targets%ROWTYPE; facts jsonb; targets jsonb:='[]'::jsonb;
BEGIN
 SELECT * INTO STRICT d FROM public.combat_v2_declarations WHERE id=p_declaration;
 IF d.state<>'risolta' AND NOT (d.state='superflua' AND (EXISTS(SELECT 1 FROM clan_aburame_private.verme_sources_v1 WHERE declaration_id=d.id) OR combat_v2_elemental_internal.suiton_narrative_supported(d.id) OR combat_v2_elemental_internal.other_narrative_supported(d.id) OR combat_v2_genjutsu_internal.narrative_supported(d.id))) THEN
   RAISE EXCEPTION 'panel_narrative_declaration_unresolved' USING ERRCODE='55000'; END IF;
 facts:=jsonb_build_object('schema_version','combat-narrative-facts/1','kind',d.kind,
   'result',CASE WHEN d.state='superflua' THEN jsonb_build_object('attack_result','not_executed') ELSE combat_panel_private.narrative_outcome_facts(d.outcome) END);
 IF d.sanitized_intent#>>'{server_ability,cure_contract}'='palmo-curativo/1' THEN
   IF combat_panel_private.cure_narrative_facts_v1(d.id) IS NULL THEN
     RAISE EXCEPTION 'cure_narrative_source_invalid' USING ERRCODE='55000';END IF;
   facts:=facts||combat_panel_private.cure_narrative_facts_v1(d.id);
 END IF;
 SELECT * INTO f FROM combat_panel_private.multiplication_formations WHERE declaration_id=d.id;
 IF FOUND THEN
   -- Soltanto il modo dichiarato, immutabile; mai stato attuale o figura originale.
   facts:=facts||jsonb_build_object('multiplication_created',jsonb_build_object('mode',f.mode));
 END IF;
 IF d.kind='attacco' THEN
   FOR t IN SELECT * FROM public.combat_v2_attack_targets WHERE attack_declaration_id=d.id ORDER BY ordinal LOOP
     IF t.state NOT IN ('risolta','superflua') THEN
       RAISE EXCEPTION 'panel_narrative_target_unresolved' USING ERRCODE='55000'; END IF;
     targets:=targets||jsonb_build_array(jsonb_build_object('ordinal',t.ordinal,
       'result',CASE WHEN t.state='superflua' THEN jsonb_build_object('attack_result','not_executed')
         ELSE combat_panel_private.narrative_outcome_facts(t.outcome) END));
   END LOOP;
   facts:=facts||jsonb_build_object('targets',targets);
 END IF;
 IF EXISTS(SELECT 1 FROM combat_v2_elemental_internal.suiton_sources WHERE declaration_id=d.id) THEN
   -- 11 checks the frozen source and all terminal receipts before this whitelist.
   facts:=facts||combat_v2_elemental_internal.suiton_narrative_projection(d.id);
   facts:=facts||jsonb_build_object('suiton_technique',(
    SELECT jsonb_build_object('name',s.profile->'name','description',s.profile->'effect_description',
      'limits',s.profile->'limits','provenance','elementali-frozen-tech/1')
    FROM combat_v2_elemental_internal.suiton_sources s WHERE s.declaration_id=d.id));
 END IF;
 IF combat_v2_elemental_internal.other_narrative_supported(d.id) THEN facts:=facts||combat_v2_elemental_internal.other_narrative_projection(d.id);END IF;
  facts:=facts||combat_v2_genjutsu_internal.narrative_facts(d.id)||clan_aburame_private.verme_narrative_v1(d.round_id,d.id);
 facts:=facts||clan_aburame_private.sfera_narrative_v1(d.round_id,d.id);
 IF d.kind IN('attacco','utilita','passa','movimento') THEN facts:=facts||combat_panel_private.nara_strangle_facts_v1(d.round_id,d.actor_id);END IF;
 RETURN combat_panel_private.multiplication_diversivo_narrative(d.id)||clan_hyuga_private.rotation_narrative_facts(d.id)||clan_uchiha_private.fireball_narrative(d.id)||clan_hyuga_private.sedici_narrative_facts(d.id)||facts||combat_panel_private.narrative_clone_facts(d.id)||clan_innata_private.illusion_narrative_facts(d.id)||clan_sabaku_private.armor_narrative_declaration(d.id)||combat_v2_elemental_internal.scudo_narrative(d.id);
END $function$;
CREATE OR REPLACE FUNCTION combat_panel_private.narrative_ordinary_context(p_round uuid)
 RETURNS jsonb
 LANGUAGE plpgsql
 STABLE SECURITY DEFINER
 SET search_path TO ''
AS $function$
DECLARE c combat_consumer_private.activities%ROWTYPE; d public.combat_v2_declarations%ROWTYPE;
 defense public.combat_v2_declarations%ROWTYPE; source public.characters%ROWTYPE; target public.characters%ROWTYPE;
 link combat_consumer_private.declaration_messages%ROWTYPE; facts jsonb; reports jsonb; place text; prior text;
 defense_no integer:=0; defense_character uuid; masked boolean; moved boolean; source_body uuid; target_body uuid; technique text; flow jsonb; nara_fact jsonb;
BEGIN
 SELECT * INTO STRICT c FROM combat_consumer_private.activities WHERE exchange_id=p_round AND phase='resolved';
 IF NOT EXISTS(SELECT 1 FROM public.combat_v2_round_reports WHERE round_id=p_round AND narration_state='attesa') THEN
   RAISE EXCEPTION 'ordinary_report_not_ready'; END IF;
 SELECT * INTO STRICT d FROM public.combat_v2_declarations
   WHERE round_id=p_round AND kind IN ('attacco','utilita','passa','movimento');
 flow:=combat_consumer_private.narrative_flow_round_v1(p_round);
 IF flow ? 'flussi_server' THEN
   facts:=jsonb_build_object('schema_version','combat-narrative-facts/1','kind',d.kind,
     'result',flow#>'{flussi_server,events,0,targets,0,result}',
     'targets',jsonb_build_array(jsonb_build_object('ordinal',1,'result',flow#>'{flussi_server,events,0,targets,0,result}')))
     ||combat_panel_private.narrative_clone_facts(d.id);
 ELSE facts:=combat_panel_private.narrative_declaration_facts(d.id); END IF;
 -- Flow has its own facts branch: append the same immutable lifecycle projection there too.
 facts:=facts||combat_v2_genjutsu_internal.narrative_facts(d.id)||clan_aburame_private.verme_narrative_v1(p_round,NULL);
 facts:=facts||clan_aburame_private.sfera_narrative_v1(p_round,d.id);
 IF d.kind='utilita' AND d.outcome#>>'{aburame_escape,version}'='aburame-escape/1' THEN
   facts:=facts||jsonb_build_object('result',jsonb_build_object('escape',jsonb_build_object(
     'success',d.outcome#>'{aburame_escape,success}','source','aburame')));
 END IF;
 IF clan_sabaku_private.armor_narrative_round(p_round) ? 'armatura_server' THEN
   facts:=facts||clan_sabaku_private.armor_narrative_declaration(d.id);
 END IF;
 IF NOT combat_consumer_private.narrative_declaration_supported(d.id) THEN
   RAISE EXCEPTION 'ordinary_narrative_source_not_ready';
 END IF;
 SELECT ch.* INTO STRICT source FROM public.characters ch JOIN combat_consumer_private.members m ON m.character_id=ch.id
   WHERE m.session_id=c.session_id AND m.actor_id=d.actor_id;
 SELECT ch.* INTO STRICT target FROM public.characters ch JOIN combat_consumer_private.members m ON m.character_id=ch.id
   WHERE m.session_id=c.session_id AND m.actor_id<>d.actor_id;
  IF d.outcome?'mental_release' THEN
  SELECT ch.* INTO STRICT target FROM public.characters ch JOIN public.combat_v2_actors aa ON aa.character_id=ch.id WHERE aa.id=d.target_actor_id;
 END IF;
 IF nullif(btrim(source.name),'') IS NULL OR nullif(btrim(target.name),'') IS NULL THEN
   RAISE EXCEPTION 'ordinary_narrative_projection_missing'; END IF;
 nara_fact:=combat_panel_private.nara_ordinary_narrative_fact_v1(d.id);
 IF nara_fact IS NOT NULL THEN facts:=facts||jsonb_build_object('nara_server',nara_fact); END IF;
 source_body:=coalesce((SELECT companion_actor_id FROM clan_marionettisti_private.offensive_profiles WHERE declaration_id=d.id),d.actor_id);
 target_body:=coalesce(d.target_actor_id,(SELECT actor_id FROM combat_consumer_private.members WHERE session_id=c.session_id AND actor_id<>d.actor_id));
 facts:=facts||clan_hoki_private.ordinary_report_facts(p_round,(
   SELECT jsonb_agg(jsonb_build_object('id',m.actor_id,'name',ch.name) ORDER BY m.actor_id)
   FROM combat_consumer_private.members m JOIN public.characters ch ON ch.id=m.character_id
   WHERE m.session_id=c.session_id));
 SELECT name INTO STRICT place FROM public.locations WHERE id=c.location_id;
 SELECT n.body INTO prior FROM public.combat_v2_narratives n JOIN public.combat_v2_rounds r ON r.id=n.round_id
   WHERE r.session_id=c.session_id AND r.id<>p_round AND r.state='narrato' ORDER BY r.round_no DESC LIMIT 1;
 SELECT * INTO STRICT link FROM combat_consumer_private.declaration_messages WHERE declaration_id=d.id;
 reports:=jsonb_build_object('attack',public._combat_narrative_report(link.message_id,link.message_sha256,c.location_id,source.id));
 IF d.kind='attacco' AND clan_uchiha_private.fireball_source_valid(d.id) THEN
   FOR defense IN SELECT * FROM public.combat_v2_declarations WHERE parent_attack_id=d.id AND kind IN ('difesa','nessuna') ORDER BY actor_id,id LOOP
     defense_no:=defense_no+1;
     SELECT character_id INTO STRICT defense_character FROM combat_consumer_private.members WHERE session_id=c.session_id AND actor_id=defense.actor_id;
     SELECT * INTO STRICT link FROM combat_consumer_private.declaration_messages WHERE declaration_id=defense.id;
     reports:=reports||jsonb_build_object('defense_'||defense_no,public._combat_narrative_report(link.message_id,link.message_sha256,c.location_id,defense_character));
   END LOOP;
 ELSIF d.kind='attacco' AND NOT (
   EXISTS(SELECT 1 FROM public.combat_v2_attack_targets mt WHERE mt.attack_declaration_id=d.id)
   AND NOT EXISTS(SELECT 1 FROM public.combat_v2_attack_targets mt WHERE mt.attack_declaration_id=d.id
     AND NOT combat_panel_private.multiplication_no_defense(mt.id))) THEN
   SELECT * INTO STRICT defense FROM public.combat_v2_declarations WHERE parent_attack_id=d.id AND kind IN ('difesa','nessuna');
   SELECT * INTO STRICT link FROM combat_consumer_private.declaration_messages WHERE declaration_id=defense.id;
   reports:=reports||jsonb_build_object('defense',public._combat_narrative_report(link.message_id,link.message_sha256,c.location_id,target.id));
 END IF;
  -- La difesa Scudo possiede una fonte distinta dall'attacco: solo fatti terminali verificati.
  IF defense.id IS NOT NULL AND defense.state='risolta'
    AND combat_v2_elemental_internal.scudo_source_valid(defense.id) THEN
    facts:=facts||combat_v2_elemental_internal.scudo_narrative(defense.id);
  END IF;
 -- Le distanze reali e il movimento dell'originale non sono fatti pubblici
 -- durante il mascheramento. La sola presenza/risoluzione delle copie non li rivela.
 masked:=facts ? 'multiplication_created' OR facts ? 'clone_events' OR EXISTS(
   SELECT 1 FROM combat_panel_private.multiplication_formations f WHERE f.session_id=c.session_id
     AND f.actor_id IN(d.actor_id,target_body) AND (f.state='active' OR EXISTS(
       SELECT 1 FROM combat_panel_private.multiplication_resolutions mr JOIN public.combat_v2_attack_targets t ON t.id=mr.attack_target_id
       WHERE mr.formation_id=f.id AND t.attack_declaration_id=d.id)));
 IF EXISTS(SELECT 1 FROM clan_aburame_private.combat_sources aburame_history
   WHERE aburame_history.session_id=c.session_id) THEN
   facts:=facts||jsonb_build_object('aburame_scene',jsonb_build_object(
     'schema_version','aburame-narrative-state/1',
     'release_state',CASE WHEN EXISTS(SELECT 1 FROM clan_aburame_private.combat_sources aburame_attached
       WHERE aburame_attached.session_id=c.session_id AND aburame_attached.source_kind='release'
         AND aburame_attached.state='attached') THEN 'attached' ELSE 'inactive' END,
     'release_target_actor_id',(SELECT aburame_attached.target_actor_id
       FROM clan_aburame_private.combat_sources aburame_attached
       WHERE aburame_attached.session_id=c.session_id AND aburame_attached.source_kind='release'
         AND aburame_attached.state='attached' ORDER BY aburame_attached.created_at DESC LIMIT 1))
     ||CASE WHEN masked THEN jsonb_build_object('clone_state','masked') ELSE jsonb_build_object(
     'clone_resolved',EXISTS(SELECT 1 FROM clan_aburame_private.combat_sources aburame_clone
       WHERE aburame_clone.round_id=p_round AND aburame_clone.source_kind='clone'
         AND aburame_clone.state='ended'),
     'clone_owner_actor_id',(SELECT aburame_clone.owner_actor_id
       FROM clan_aburame_private.combat_sources aburame_clone
       WHERE aburame_clone.round_id=p_round AND aburame_clone.source_kind='clone'
         AND aburame_clone.state='ended' ORDER BY aburame_clone.created_at DESC LIMIT 1),
     'clone_moved',EXISTS(SELECT 1 FROM clan_aburame_private.combat_sources aburame_move
       JOIN combat_spatial.movement_capabilities aburame_cap
         ON aburame_cap.capability_id=aburame_move.movement_capability
       WHERE aburame_move.round_id=p_round AND aburame_move.source_kind='clone'
         AND aburame_move.state='ended' AND aburame_cap.state='committed'),
     'clone_movement_m',(SELECT round(combat_spatial.distance_m(aburame_cap.start_x_m,aburame_cap.start_y_m,
          aburame_cap.end_x_m,aburame_cap.end_y_m),0)
       FROM clan_aburame_private.combat_sources aburame_move
       JOIN combat_spatial.movement_capabilities aburame_cap
         ON aburame_cap.capability_id=aburame_move.movement_capability
       WHERE aburame_move.round_id=p_round AND aburame_move.source_kind='clone'
         AND aburame_move.state='ended' AND aburame_cap.state='committed'
       ORDER BY aburame_move.created_at DESC LIMIT 1)) END);
 END IF;
 moved:=EXISTS(SELECT 1 FROM combat_spatial.spatial_events e WHERE e.actor_id=source_body
   AND e.event_kind='movement_settled' AND (e.after_state->>'d_eff_m')::numeric>0
   AND (e.root_id=d.request_key OR EXISTS(SELECT 1 FROM combat_consumer_private.offers o WHERE o.id=e.root_id AND o.exchange_id=p_round)));
 facts:=facts||combat_panel_private.nara_strangle_facts_v1(p_round,d.actor_id);
 technique:=CASE
   WHEN d.sanitized_intent#>>'{server_ability,aburame_sfera_version}'='aburame-sfera/1' THEN 'Sfera d''Insetti'
   WHEN d.sanitized_intent#>'{server_ability,aburame_sfera_escape}' IS NOT NULL THEN 'Liberarsi dalla Sfera d''Insetti'
   WHEN d.sanitized_intent#>>'{server_ability,nara_strangle_contract}'='nara-strangolamento/1' THEN 'Strangolamento dell''Ombra'
   WHEN facts#>>'{result,healing,schema_version}'='palmo-curativo-narrative/1' THEN 'Palmo Curativo'
   WHEN d.sanitized_intent->'target_fili'='true'::jsonb THEN
     (d.sanitized_intent#>>'{server_ability,name}')||' contro i Fili di Chakra. '||
     CASE WHEN d.outcome->'fili_recisi'='true'::jsonb THEN 'I Fili vengono recisi.'
          ELSE 'I Fili restano collegati.' END||' La marionetta non è colpita.'
       WHEN facts ? 'genjutsu_server' THEN 'Paralisi illusoria'
    WHEN facts#>'{result,mental_release}' IS NOT NULL THEN CASE WHEN facts#>>'{result,mental_release,mode}'='kai' THEN 'Dispersione' ELSE 'Liberazione dalla paralisi' END
    WHEN facts ? 'elemental_technique' THEN facts#>>'{elemental_technique,name}' WHEN facts ? 'suiton_technique' THEN facts#>>'{suiton_technique,name}' WHEN flow ? 'flussi_server' THEN 'Flusso di Sabbia' WHEN facts ? 'projectile_fireball' THEN facts#>>'{projectile_fireball,name}' WHEN facts ? 'sedici_chiusure' THEN
    (SELECT name FROM public.clan_techniques WHERE id='031d5ecc-86ee-4d21-85f1-6b76fc57cef9'::uuid)
   WHEN clan_akimichi_private.narrative_partial_valid(d.id) THEN 'Espansione Parziale'
   WHEN nara_fact IS NOT NULL THEN 'Possesso dell''Ombra'
   WHEN EXISTS(SELECT 1 FROM clan_hoki_private.needle_sources s WHERE s.declaration_id=d.id AND s.state='spent')
     THEN 'Aghi Velenosi'
       WHEN EXISTS(SELECT 1 FROM clan_aburame_private.verme_sources_v1 WHERE declaration_id=d.id) THEN 'Insetto Verme Velenoso'
    WHEN facts ? 'juken' THEN 'Attacco a mani nude con Jūken'
   WHEN facts ? 'clone_creation' THEN 'Clone di Sabbia'
   WHEN EXISTS(SELECT 1 FROM clan_aburame_private.combat_sources s
    WHERE s.declaration_id=d.id AND s.round_id=p_round AND s.source_kind='release'
      AND combat_consumer_private.narrative_declaration_supported(s.declaration_id)) THEN
    (SELECT name FROM public.clan_techniques WHERE id='f5e9af24-70f1-49f6-a7ca-74f59256336e'::uuid)
   WHEN d.kind='utilita' AND d.outcome#>>'{aburame_escape,version}'='aburame-escape/1' THEN 'Liberarsi dallo sciame'
   WHEN d.kind='passa' THEN 'Conclusione del turno senza altra azione'
   WHEN d.kind='movimento' THEN 'Spostamento'
   WHEN facts->'result' ? 'escape' THEN 'Tenta di liberarti'
   WHEN facts ? 'multiplication_created' THEN 'Moltiplicazione del corpo'
   WHEN source_body<>d.actor_id THEN 'Marionetta da Combattimento: arto rinforzato contundente, controllato tramite Fili di Chakra'
   WHEN combat_panel_private.shuriken_resolved_v1(d.id) THEN 'Lancio di Shuriken'
   ELSE 'Colpo a mani nude' END;
 technique:=left(technique||clan_akimichi_private.common_result_label_v1(d.outcome),300);
 RETURN jsonb_build_object('ordinary',true,'genere','azione_risolta','non_offensivo',d.kind<>'attacco',
   'autore',jsonb_build_object('nome',source.name,'sesso',source.sex),
   'testimone',CASE WHEN EXISTS(SELECT 1 FROM public.combat_v2_actors WHERE id=target_body AND companion_id IS NOT NULL)
      THEN jsonb_build_object('nome','Marionetta','sesso',null) ELSE jsonb_build_object('nome',target.name,'sesso',target.sex) END,
   'luogo',place,'tecnica',technique,'fatti',facts,
   'movimento',CASE WHEN masked THEN 'non_esposto' WHEN moved THEN 'avvenuto' ELSE 'assente' END,
   'reazione',CASE WHEN clan_uchiha_private.fireball_source_valid(d.id) THEN 'difese individuali nei fatti' WHEN d.kind='attacco' AND defense.id IS NOT NULL THEN defense.sanitized_intent->>'reaction' ELSE NULL END,
   'player_reports',reports,'gia_visto',left(coalesce(prior,''),400),'model','gpt-6-luna');
END $function$;

CREATE OR REPLACE FUNCTION clan_aburame_private.attack_power_source(p_attack uuid, p_actor uuid)
 RETURNS jsonb
 LANGUAGE plpgsql
 STABLE SECURITY DEFINER
 SET search_path TO ''
AS $function$
DECLARE d public.combat_v2_declarations%ROWTYPE;a public.combat_v2_actors%ROWTYPE;prof jsonb;power integer;element text;family text;
BEGIN
 SELECT * INTO d FROM public.combat_v2_declarations WHERE id=p_attack AND kind='attacco' AND target_actor_id=p_actor AND state='inviata';
 IF NOT FOUND OR (SELECT count(*) FROM public.combat_v2_attack_targets t WHERE t.attack_declaration_id=d.id)<>1
  OR coalesce(d.sanitized_intent#>>'{server_ability,targeting,mode}','single') NOT IN ('single','singolo')
  OR coalesce((d.sanitized_intent#>>'{server_ability,targeting,area_radius_m}')::numeric,0)>0
  OR coalesce((d.sanitized_intent#>>'{server_ability,inevitable}')::boolean,false)
  OR lower(coalesce(d.sanitized_intent#>>'{server_ability,kind}','fisico')) LIKE '%genjutsu%'
 THEN RETURN NULL;END IF;
 SELECT * INTO STRICT a FROM public.combat_v2_actors WHERE id=d.actor_id;
 prof:=clan_akimichi_private.partial_power_source(d.id);
 IF EXISTS(SELECT 1 FROM clan_aburame_private.verme_sources_v1 WHERE declaration_id=d.id) THEN
  prof:=clan_aburame_private.verme_frozen_v1(d.id);
  IF prof->>'source_lost'='true' THEN RETURN NULL;END IF;family:='aburame-verme/1';
 ELSIF d.sanitized_intent#>>'{server_ability,aburame_sfera_version}'='aburame-sfera/1' THEN
  prof:=clan_aburame_private.sfera_defense_power_v1(d.id);IF prof IS NULL THEN RETURN NULL; END IF;
  family:='aburame-sfera/1';
 ELSIF d.sanitized_intent#>>'{server_ability,nara_launch,schema_version}'='nara-possession/1' THEN
  prof:=combat_panel_private.nara_frozen_launch_v1(d.id);
  IF prof IS NULL THEN RAISE EXCEPTION 'nara_frozen_launch_invalid' USING ERRCODE='22023'; END IF;
  family:='nara-possession/1';
 ELSIF prof IS NOT NULL THEN family:='akimichi-partial/1';
 ELSIF EXISTS(SELECT 1 FROM clan_sabaku_private.flow_sources x WHERE x.declaration_id=d.id) THEN
  SELECT x.profile INTO prof FROM clan_sabaku_private.flow_sources x WHERE x.declaration_id=d.id;family:='sabaku-flow/2';
 ELSIF EXISTS(SELECT 1 FROM clan_uchiha_private.fireball_sources x WHERE x.declaration_id=d.id AND coalesce((x.profile->>'area_radius_m')::numeric,0)=0) THEN
  SELECT x.profile INTO prof FROM clan_uchiha_private.fireball_sources x WHERE x.declaration_id=d.id;family:='projectile-fireball-offense/2';
 ELSIF EXISTS(SELECT 1 FROM clan_marionettisti_private.offensive_profiles x WHERE x.declaration_id=d.id) THEN
  SELECT x.profile INTO prof FROM clan_marionettisti_private.offensive_profiles x WHERE x.declaration_id=d.id;family:='marionetta-offense/1'; ELSIF EXISTS(SELECT 1 FROM clan_inuzuka_private.zanna_sources x WHERE x.declaration_id=d.id) THEN SELECT x.profile INTO prof FROM clan_inuzuka_private.zanna_sources x WHERE x.declaration_id=d.id;family:='inuzuka-zanna/1';
 ELSIF EXISTS(SELECT 1 FROM clan_hyuga_private.sedici_sources x WHERE x.declaration_id=d.id) THEN
  SELECT x.profile INTO prof FROM clan_hyuga_private.sedici_sources x WHERE x.declaration_id=d.id;family:='hyuga-sedici/1';
 ELSIF EXISTS(SELECT 1 FROM clan_hyuga_private.juken_sources x WHERE x.declaration_id=d.id) THEN
  SELECT x.profile INTO prof FROM clan_hyuga_private.juken_sources x WHERE x.declaration_id=d.id;family:='physical-hand-juken/1';
 ELSIF EXISTS(SELECT 1 FROM combat_v2_taijutsu_internal.taijutsu_sources x WHERE x.declaration_id=d.id) THEN
  SELECT x.profile||x.ability_meta INTO prof FROM combat_v2_taijutsu_internal.taijutsu_sources x WHERE x.declaration_id=d.id;family:='taijutsu-genin/1';
 ELSIF EXISTS(SELECT 1 FROM combat_v2_elemental_internal.other_sources x WHERE x.declaration_id=d.id) THEN
  SELECT x.profile||x.ability_meta INTO prof FROM combat_v2_elemental_internal.other_sources x WHERE x.declaration_id=d.id;family:='elementali-other/1';
 ELSIF EXISTS(SELECT 1 FROM combat_v2_elemental_internal.suiton_sources x WHERE x.declaration_id=d.id) THEN
  SELECT x.profile||x.ability_meta INTO prof FROM combat_v2_elemental_internal.suiton_sources x WHERE x.declaration_id=d.id;family:='elementali-suiton/1';
 ELSIF d.sanitized_intent#>>'{server_ability,hoki_needle_version}'='hoki-needle/1' THEN
  prof:=clan_hoki_private.needle_frozen_profile(d.id); family:='hoki-needle/1';
 ELSIF coalesce(d.sanitized_intent->>'ability_source','mano')='mano' THEN
  power:=10+((coalesce((a.mechanics_snapshot->>'forza')::integer,0)+coalesce((a.mechanics_snapshot->>'taijutsu')::integer,0))/10)+CASE WHEN clan_inuzuka_private.quattro_active(a.id) THEN ((a.mechanics_snapshot->>'kekkei_genkai')::integer+(a.mechanics_snapshot->>'taijutsu')::integer)/30 ELSE 0 END;
  family:='physical-hand/1';prof:=jsonb_build_object('power',power,'element',NULL);
 ELSE RETURN NULL;END IF;
 power:=coalesce((prof->>'power')::integer,(prof->>'power_unmodified')::integer,
  (prof->>'power_base')::integer+coalesce((prof->>'pool')::integer,0)/10);
 IF family NOT IN ('akimichi-partial/1','aburame-sfera/1') THEN power:=power+clan_akimichi_private.body_attack_mass(d.id); END IF;
 element:=lower(coalesce(prof->>'element',d.sanitized_intent#>>'{server_ability,element}',''));
 IF power IS NULL OR power<1 THEN RETURN NULL;END IF;
 RETURN jsonb_build_object('version','aburame-attack-power/1','declaration_id',d.id,'family',family,'power',power,
  'element',CASE WHEN element IN ('fuoco','katon') THEN 'katon' WHEN element IN ('fulmine','raiton') THEN 'raiton' WHEN element IN ('acqua','suiton') THEN 'suiton' ELSE NULL END,
  'source_sha256',public.combat_v2_sha256(jsonb_build_object('declaration_id',d.id,'family',family,'power',power,'profile',prof)));
END $function$;

CREATE OR REPLACE FUNCTION clan_hyuga_private.rotation_attack_power_freeze(p_declaration uuid)
 RETURNS void
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO ''
AS $function$

DECLARE d public.combat_v2_declarations%ROWTYPE; a public.combat_v2_actors%ROWTYPE;
 f clan_sabaku_private.flow_sources%ROWTYPE; j clan_hyuga_private.juken_sources%ROWTYPE;
 h clan_hyuga_private.sedici_sources%ROWTYPE; m clan_marionettisti_private.offensive_profiles%ROWTYPE;
 u clan_uchiha_private.fireball_sources%ROWTYPE; old clan_hyuga_private.rotation_attack_powers%ROWTYPE;
 prof jsonb; native_hash text; fingerprint text; pool bigint; power bigint; base integer; family text; source_actor uuid;
BEGIN
 IF NOT EXISTS(SELECT 1 FROM clan_hyuga_private.rotation_gate WHERE singleton AND enabled) THEN RETURN; END IF;
 SELECT * INTO STRICT d FROM public.combat_v2_declarations WHERE id=p_declaration;
 IF d.kind<>'attacco' THEN RETURN; END IF;
 SELECT * INTO STRICT a FROM public.combat_v2_actors WHERE id=d.actor_id;
 IF exam_regia_private.is_bound(a.session_id) OR clan_hyuga_private.rotation_profile(d.target_actor_id) IS NULL THEN RETURN;END IF;
 fingerprint:=clan_hyuga_private.juken_declaration_fingerprint(d.id);
 SELECT * INTO old FROM clan_hyuga_private.rotation_attack_powers WHERE declaration_id=d.id;
 IF FOUND THEN
  IF old.declaration_sha256 IS DISTINCT FROM fingerprint THEN RAISE EXCEPTION 'rotation_attack_replay_conflict';END IF;
  RETURN;
 END IF;
 source_actor:=a.id;
 SELECT * INTO f FROM clan_sabaku_private.flow_sources WHERE declaration_id=d.id;
 SELECT * INTO u FROM clan_uchiha_private.fireball_sources WHERE declaration_id=d.id;
 SELECT * INTO m FROM clan_marionettisti_private.offensive_profiles WHERE declaration_id=d.id;
 SELECT * INTO h FROM clan_hyuga_private.sedici_sources WHERE declaration_id=d.id;
 SELECT * INTO j FROM clan_hyuga_private.juken_sources WHERE declaration_id=d.id;
 prof:=clan_akimichi_private.partial_power_source(d.id);
 IF d.sanitized_intent#>>'{server_ability,aburame_sfera_version}'='aburame-sfera/1' THEN
  prof:=clan_aburame_private.sfera_defense_power_v1(d.id);IF prof IS NULL THEN RETURN; END IF;
  power:=(prof->>'power')::bigint;pool:=(prof->>'pool')::bigint;base:=35;
  native_hash:=public.combat_v2_sha256(prof);family:='aburame-sfera/1';
 ELSIF d.sanitized_intent#>>'{server_ability,nara_launch,schema_version}'='nara-possession/1' THEN
  prof:=combat_panel_private.nara_frozen_launch_v1(d.id);
  power:=(prof->>'power')::bigint; pool:=(prof->>'attack_pool')::bigint; base:=15;
  native_hash:=public.combat_v2_sha256(prof);family:='nara-possession/1';
 ELSIF prof IS NOT NULL THEN
  power:=(prof->>'power')::bigint;base:=(prof->>'power_base')::integer;pool:=(prof->>'offense_pool')::bigint;
  native_hash:=public.combat_v2_sha256(prof);family:='akimichi-partial/1';
 ELSIF f.declaration_id IS NOT NULL THEN
  IF f.source_sha256 IS DISTINCT FROM clan_sabaku_private.flow_source_hash(f)
   OR f.profile IS DISTINCT FROM d.sanitized_intent#>'{server_ability,flow_profile}' THEN
   RAISE EXCEPTION 'rotation_flow_source_corrupt'; END IF;
  prof:=f.profile;power:=(prof->>'power')::bigint;base:=power::integer;pool:=0;
  native_hash:=f.source_sha256;family:='sabaku-flow/2';
 ELSIF u.declaration_id IS NOT NULL THEN
  IF u.profile IS DISTINCT FROM clan_uchiha_private.fireball_resolve_profile(d.id) THEN
   RAISE EXCEPTION 'rotation_fireball_source_corrupt';END IF;
  IF coalesce((u.profile->>'area_radius_m')::numeric,0)>0 THEN RETURN; END IF;
  prof:=u.profile;power:=(prof->>'power_unmodified')::bigint;pool:=(prof->>'pool')::bigint;
  base:=(prof->>'power_base')::integer;native_hash:=u.source_sha256;family:='projectile-fireball-offense/2';
 ELSIF m.declaration_id IS NOT NULL THEN
  IF m.profile_sha256 IS DISTINCT FROM public.combat_v2_sha256(m.profile) THEN RAISE EXCEPTION 'rotation_puppet_source_corrupt';END IF;
  prof:=m.profile;power:=(prof->>'power')::bigint;base:=(prof->>'power_base')::integer;
  pool:=(prof->>'pool')::bigint;native_hash:=m.profile_sha256;family:='marionetta-offense/1';source_actor:=m.companion_actor_id;
 ELSIF h.declaration_id IS NOT NULL THEN
  IF h.source_sha256 IS DISTINCT FROM fingerprint THEN RAISE EXCEPTION 'rotation_sedici_source_corrupt';END IF;
  prof:=h.profile;base:=(prof->>'power_base')::integer;pool:=(prof->>'pool')::bigint;
  power:=base+pool/10;native_hash:=h.source_sha256;family:='hyuga-sedici/1';
 ELSIF d.sanitized_intent#>>'{server_ability,hoki_needle_version}'='hoki-needle/1' THEN
  prof:=clan_hoki_private.needle_frozen_profile(d.id);
  IF prof IS NULL THEN RAISE EXCEPTION 'hoki_needle_power_source_missing'; END IF;
  pool:=(prof->>'pool')::bigint; base:=(prof->>'power_base')::integer;
  power:=(prof->>'power')::bigint; native_hash:=public.combat_v2_sha256(prof); family:='hoki-needle/1';
 ELSIF coalesce(d.sanitized_intent->>'ability_source','mano')='mano' THEN
  IF j.declaration_id IS NOT NULL THEN
   IF j.declaration_sha256 IS DISTINCT FROM fingerprint THEN RAISE EXCEPTION 'rotation_juken_source_corrupt';END IF;
   prof:=j.profile;pool:=(prof->>'pool')::bigint;native_hash:=j.declaration_sha256;family:='physical-hand-juken/1';
  ELSE
   prof:=clan_innata_combat_private.velo_frozen_snapshot_v1(a.mechanics_snapshot,a.id,d.id);
   IF prof->>'forza' !~ '^[0-9]+$' OR prof->>'taijutsu' !~ '^[0-9]+$'
    OR prof->>'forza' IS NULL OR prof->>'taijutsu' IS NULL THEN RAISE EXCEPTION 'rotation_hand_statistics_invalid'; END IF;
   pool:=(prof->>'forza')::bigint+(prof->>'taijutsu')::bigint;
   native_hash:=public.combat_v2_sha256(jsonb_build_object('forza',prof->'forza','taijutsu',prof->'taijutsu'));
   family:='physical-hand/1';
  END IF;
  base:=10;power:=base+pool/10+clan_akimichi_private.body_attack_mass(d.id);
 ELSE
  -- No name/category guesses and no conversion from damage/off. A future source
  -- is enabled only with its certified frozen power mapping.
  RETURN;
 END IF;
 IF power IS NULL OR power<1 OR power>2147483647 OR pool IS NULL OR pool<0 THEN RAISE EXCEPTION 'rotation_attack_power_invalid';END IF;
 prof:=jsonb_build_object('version','rotation-attack-power/1','family',family,'source_actor_id',source_actor,
  'power_base',base,'pool',pool,'power_contribution',CASE WHEN family='sabaku-flow/2' THEN 0 ELSE pool/10 END,
  'modifiers',CASE WHEN family='akimichi-partial/1' THEN jsonb_build_array(jsonb_build_object('kind','akimichi_mass','value',prof->'mass'))
     WHEN family='physical-hand/1' AND clan_akimichi_private.body_attack_mass(d.id)>0 THEN
       jsonb_build_array(jsonb_build_object('kind','akimichi_mass','value',clan_akimichi_private.body_attack_mass(d.id)))
     ELSE '[]'::jsonb END,'power',power,'native_source_hash',native_hash,'declaration_id',d.id);
 INSERT INTO clan_hyuga_private.rotation_attack_powers(declaration_id,round_id,actor_id,declaration_sha256,profile,source_sha256)
 VALUES(d.id,d.round_id,a.id,fingerprint,prof,public.combat_v2_sha256(prof));
END

$function$;

CREATE OR REPLACE FUNCTION combat_consumer_private.narrative_context(p_round uuid)
 RETURNS jsonb
 LANGUAGE plpgsql
 STABLE SECURITY DEFINER
 SET search_path TO ''
AS $function$
declare ctx combat_consumer_private.activities%rowtype; report public.combat_v2_round_reports%rowtype;
  primary_action public.combat_v2_declarations%rowtype; defense public.combat_v2_declarations%rowtype;
  source public.characters%rowtype; target public.characters%rowtype;
  a combat_spatial.actor_states%rowtype; b combat_spatial.actor_states%rowtype;
  link combat_consumer_private.declaration_messages%rowtype; reports jsonb:='{}';
  distance numeric; outcome text; prior text; location_name text; movement numeric:=0;
begin
  IF EXISTS(SELECT 1 FROM public.combat_v2_round_reports WHERE round_id=p_round AND mechanics->>'catalogo_lifecycle_contract'='catalogo-lifecycle-report/1')THEN RETURN combat_panel_private.nara_strangle_lifecycle_context_v1(p_round);END IF;
  IF EXISTS(SELECT 1 FROM combat_panel_private.nara_strangle_events_v1 WHERE round_id=p_round) THEN RETURN combat_panel_private.narrative_ordinary_context(p_round);END IF;
  IF EXISTS(SELECT 1 FROM clan_aburame_private.verme_events_v1 WHERE round_id=p_round AND kind IN('released','poison_tick','poison_end')) THEN RETURN combat_panel_private.narrative_ordinary_context(p_round);END IF;
  IF EXISTS(SELECT 1 FROM combat_panel_private.cure_ledger_v1 l WHERE l.round_id=p_round
    AND combat_panel_private.cure_narrative_facts_v1(l.declaration_id) IS NOT NULL) THEN
    RETURN combat_panel_private.narrative_ordinary_context(p_round);
  END IF;
  IF EXISTS(SELECT 1 FROM public.combat_v2_declarations z WHERE z.round_id=p_round AND combat_v2_genjutsu_internal.narrative_supported(z.id)) THEN RETURN combat_panel_private.narrative_ordinary_context(p_round);END IF;
  IF EXISTS(SELECT 1 FROM public.combat_v2_declarations d WHERE d.round_id=p_round
    AND d.sanitized_intent#>>'{server_ability,nara_launch,schema_version}'='nara-possession/1'
    AND combat_panel_private.nara_ordinary_narrative_fact_v1(d.id) IS NOT NULL) THEN
    RETURN combat_panel_private.narrative_ordinary_context(p_round);
  END IF;
  IF EXISTS(SELECT 1 FROM clan_akimichi_private.partial_sources s
    WHERE s.round_id=p_round AND clan_akimichi_private.narrative_partial_valid(s.declaration_id)) THEN
    RETURN combat_panel_private.narrative_ordinary_context(p_round);
  END IF;
  IF EXISTS(SELECT 1 FROM clan_hoki_private.needle_sources n
     JOIN public.combat_v2_declarations d ON d.id=n.declaration_id
     WHERE d.round_id=p_round AND n.state='spent'
       AND combat_consumer_private.narrative_declaration_supported(d.id))
   OR EXISTS(SELECT 1 FROM public.combat_v2_round_reports rr
     JOIN public.combat_v2_declarations d ON d.round_id=rr.round_id
     WHERE rr.round_id=p_round AND rr.narration_state='attesa'
       AND (rr.mechanics->'hoki_facts' @? '$[*] ? (@.active == true || @.poison_applied == true || @.version == "hoki-minor-poison/1")')
       AND d.kind IN ('attacco','passa','movimento')
       AND combat_consumer_private.narrative_declaration_supported(d.id)) THEN
    RETURN combat_panel_private.narrative_ordinary_context(p_round);
  END IF;
  IF EXISTS(SELECT 1 FROM combat_v2_elemental_internal.other_sources s
    WHERE s.round_id=p_round AND combat_v2_elemental_internal.other_narrative_supported(s.declaration_id))
    OR EXISTS(SELECT 1 FROM combat_v2_taijutsu_internal.taijutsu_sources s
      WHERE s.round_id=p_round AND combat_v2_taijutsu_internal.narrative_supported(s.declaration_id))
    OR EXISTS(SELECT 1 FROM combat_v2_elemental_internal.scudo_sources s
      JOIN public.combat_v2_declarations d ON d.id=s.declaration_id
      WHERE d.round_id=p_round AND d.state='risolta'
        AND combat_v2_elemental_internal.scudo_source_valid(d.id)) THEN
    RETURN combat_panel_private.narrative_ordinary_context(p_round);
  END IF;
  IF EXISTS(SELECT 1 FROM combat_v2_elemental_internal.suiton_sources s
    WHERE s.round_id=p_round AND combat_v2_elemental_internal.suiton_narrative_supported(s.declaration_id)) THEN
    RETURN combat_panel_private.narrative_ordinary_context(p_round);
  END IF;
  IF EXISTS(SELECT 1 FROM clan_hyuga_private.rotation_sources h
   JOIN public.combat_v2_declarations rot_defense ON rot_defense.id=h.declaration_id
   WHERE h.round_id=p_round AND rot_defense.state='risolta'
    AND rot_defense.outcome#>>'{hyuga_rotation,defense_declaration_id}'=h.declaration_id::text
    AND rot_defense.outcome ? 'hyuga_rotation_movement'
    AND h.source_sha256=clan_hyuga_private.rotation_source_hash(h)) THEN
   RETURN combat_panel_private.narrative_ordinary_context(p_round);
  END IF;
  IF EXISTS(SELECT 1 FROM clan_sabaku_private.flow_sources WHERE round_id=p_round) THEN
    RETURN combat_panel_private.narrative_ordinary_context(p_round);
  END IF;
  IF EXISTS(SELECT 1 FROM clan_sabaku_private.armor_events ae
    WHERE ae.round_id=p_round AND ae.event_kind='hit') THEN
    RETURN combat_panel_private.narrative_ordinary_context(p_round);
  END IF;
  IF EXISTS(SELECT 1 FROM clan_aburame_private.combat_sources s
    WHERE s.round_id=p_round AND s.source_kind IN ('release','clone')
      AND combat_consumer_private.narrative_declaration_supported(s.declaration_id))
    OR EXISTS(SELECT 1 FROM combat_consumer_private.activities aburame_context
      JOIN clan_aburame_private.combat_sources aburame_history
        ON aburame_history.session_id=aburame_context.session_id
      WHERE aburame_context.exchange_id=p_round
        AND aburame_history.source_kind IN ('release','clone')
        AND EXISTS(SELECT 1 FROM public.combat_v2_declarations aburame_current
          WHERE aburame_current.round_id=p_round
            AND aburame_current.kind IN ('attacco','utilita','passa','movimento')
            AND combat_consumer_private.narrative_declaration_supported(aburame_current.id))) THEN
    RETURN combat_panel_private.narrative_ordinary_context(p_round);
  END IF;
  -- Fatti Sfera solo dal report firmato dello scambio Staff protetto.
  IF EXISTS (
    SELECT 1 FROM combat_consumer_private.activities a
    JOIN public.combat_v2_rounds r ON r.id=a.exchange_id AND r.session_id=a.session_id
    JOIN public.combat_v2_round_reports rr ON rr.id=r.report_id AND rr.round_id=r.id
    JOIN public.combat_v2_declarations d ON d.round_id=r.id
    WHERE a.exchange_id=p_round AND a.phase='resolved'
      AND a.location_id='0b85f354-9cdb-47e1-baf9-3d266bb7e06b'
      AND combat_panel_private.nara_adv_pool_v1(a.session_id)
      AND rr.narration_state='attesa'
      AND d.state='risolta' AND d.kind IN ('attacco','utilita','passa','movimento')
      AND clan_aburame_private.sfera_narrative_v1(r.id,d.id) ? 'aburame_sfera_server'
  ) THEN
    RETURN combat_panel_private.narrative_ordinary_context(p_round);
  END IF;
  if exists(select 1 from public.combat_v2_declarations d where d.round_id=p_round
    and ((d.state='risolta' AND (
  (d.kind='attacco' AND (
    EXISTS(SELECT 1 FROM clan_hyuga_private.juken_sources h
      JOIN public.combat_v2_rounds r ON r.id=d.round_id
      WHERE h.declaration_id=d.id AND h.actor_id=d.actor_id AND h.target_actor_id=d.target_actor_id
        AND h.round_id=d.round_id AND h.session_id=r.session_id
        AND d.sanitized_intent#>>'{server_ability,source}'='mano'
        AND h.declaration_sha256=clan_hyuga_private.juken_declaration_fingerprint(d.id))
    OR EXISTS(SELECT 1 FROM clan_hyuga_private.sedici_sources h
      JOIN public.combat_v2_rounds r ON r.id=d.round_id
      WHERE h.declaration_id=d.id AND h.actor_id=d.actor_id AND h.target_actor_id=d.target_actor_id
        AND h.session_id=r.session_id AND d.sanitized_intent->>'ability_source'='clan'
        AND d.sanitized_intent->>'ability_id'='031d5ecc-86ee-4d21-85f1-6b76fc57cef9'
        AND h.source_sha256=clan_hyuga_private.juken_declaration_fingerprint(d.id))))
  OR (clan_hyuga_private.sedici_expiry_facts(d.id) @> '{"sedici_chiusure_expired":true}'::jsonb
      AND combat_consumer_private.narrative_declaration_supported(d.id)))) OR clan_uchiha_private.fireball_source_valid(d.id) OR exists(select 1 from clan_sabaku_private.clone_captures cc where cc.round_id=p_round)
      or d.kind='utilita' or (d.kind='attacco' and (
      exists(select 1 from combat_panel_private.multiplication_formations f where f.declaration_id=d.id)
      or d.outcome ? 'multiplication' or exists(select 1 from public.combat_v2_attack_targets t
        where t.attack_declaration_id=d.id and t.outcome ? 'multiplication'))))) then
    return combat_panel_private.narrative_ordinary_context(p_round);
  end if;
  select c.* into ctx from combat_consumer_private.activities c where exchange_id=p_round and phase='resolved';
  select * into report from public.combat_v2_round_reports where round_id=p_round and narration_state='attesa';
  if ctx.session_id is null or report.id is null then raise exception 'ordinary_report_not_ready'; end if;
  select * into primary_action from public.combat_v2_declarations where round_id=p_round and kind in ('attacco','passa');
  if primary_action.id is null or (primary_action.kind='attacco' and
    not clan_marionettisti_private.narrative_attack_allowed(primary_action.id)) then
    raise exception 'ordinary_narrative_source_not_ready';
  end if;
  select c.* into source from public.characters c join combat_consumer_private.members m on m.character_id=c.id
    where m.session_id=ctx.session_id and m.actor_id=primary_action.actor_id;
  select c.* into target from public.characters c join combat_consumer_private.members m on m.character_id=c.id
    where m.session_id=ctx.session_id and m.actor_id<>primary_action.actor_id;
  select s.* into a from combat_spatial.actor_states s join combat_spatial.arena_instances i on i.instance_id=s.instance_id
    where i.encounter_id=ctx.session_id and s.actor_id=coalesce((select companion_actor_id from clan_marionettisti_private.offensive_profiles where declaration_id=primary_action.id),primary_action.actor_id);
  select s.* into b from combat_spatial.actor_states s join combat_spatial.arena_instances i on i.instance_id=s.instance_id
    where i.encounter_id=ctx.session_id and s.actor_id=coalesce(primary_action.target_actor_id,(select actor_id from combat_consumer_private.members where session_id=ctx.session_id and actor_id<>primary_action.actor_id));
  if nullif(btrim(source.name),'') is null or nullif(btrim(target.name),'') is null
    or a.actor_id is null or b.actor_id is null then raise exception 'ordinary_narrative_projection_missing'; end if;
  distance:=combat_spatial.distance_m(a.x_m,a.y_m,b.x_m,b.y_m);
  select name into location_name from public.locations where id=ctx.location_id;
  select n.body into prior from public.combat_v2_narratives n join public.combat_v2_rounds r on r.id=n.round_id
    where r.session_id=ctx.session_id and r.id<>p_round and r.state='narrato' order by r.round_no desc limit 1;
  select coalesce(sum((e.after_state->>'d_eff_m')::numeric),0) into movement
    from combat_spatial.spatial_events e join combat_consumer_private.offers o on o.id=e.root_id
    where o.exchange_id=p_round and e.actor_id=primary_action.actor_id and e.event_kind='movement_settled';
  select * into link from combat_consumer_private.declaration_messages where declaration_id=primary_action.id;
  if link.message_id is null then raise exception 'ordinary_narrative_message_missing'; end if;
  reports:=jsonb_build_object('attack',public._combat_narrative_report(link.message_id,link.message_sha256,ctx.location_id,source.id));
  if primary_action.kind='passa' then
    return jsonb_build_object('ordinary',true,'genere','rinuncia','non_offensivo',true,
      'autore',jsonb_build_object('nome',source.name,'sesso',source.sex),
      'testimone',jsonb_build_object('nome',target.name,'sesso',target.sex),
      'luogo',location_name,'distanza_fascia',public._fascia_da_metri(ceil(distance)::integer),'movimento_effettivo',movement>0,
      'player_reports',reports,'gia_visto',left(coalesce(prior,''),400),'model','gpt-6-luna');
  end if;
  select * into defense from public.combat_v2_declarations where parent_attack_id=primary_action.id and kind in ('difesa','nessuna');
  if defense.id is null then raise exception 'ordinary_narrative_defense_missing'; end if;
  select * into link from combat_consumer_private.declaration_messages where declaration_id=defense.id;
  if link.message_id is null then raise exception 'ordinary_narrative_message_missing'; end if;
  reports:=reports||jsonb_build_object('defense',public._combat_narrative_report(link.message_id,link.message_sha256,ctx.location_id,target.id));
  outcome:=case when coalesce((primary_action.outcome->>'success')::boolean,false) then 'colpito'
    when coalesce((primary_action.outcome->>'damage_applied')::integer,0)>0 then 'sfiorato' else 'mancato' end;
  return jsonb_build_object('ordinary',true,'genere','confronto','non_offensivo',false,'luogo',location_name,
    'attaccante',jsonb_build_object('nome',source.name,'sesso',source.sex),
    'difensore',case when exists(select 1 from public.combat_v2_actors where id=primary_action.target_actor_id and companion_id is not null)
      then jsonb_build_object('nome','Marionetta','sesso',null) else jsonb_build_object('nome',target.name,'sesso',target.sex) end,
    'tecnica',case when primary_action.sanitized_intent->'target_fili'='true'::jsonb THEN
      (primary_action.sanitized_intent#>>'{server_ability,name}')||' contro i Fili di Chakra. '||
        CASE WHEN primary_action.outcome->'fili_recisi'='true'::jsonb THEN 'I Fili vengono recisi.' ELSE 'I Fili restano collegati.' END||' La marionetta non è colpita.'
      when exists(select 1 from clan_marionettisti_private.offensive_profiles where declaration_id=primary_action.id) then 'Marionetta da Combattimento: arto rinforzato contundente, controllato tramite Fili di Chakra' when combat_panel_private.shuriken_resolved_v1(primary_action.id) then 'Lancio di Shuriken'
       else 'Colpo a mani nude' end,'natura',null,'reazione',defense.sanitized_intent->>'reaction',
    'tecnica_difensiva',CASE WHEN clan_akimichi_private.cellular_source_valid_v1(defense.id) AND defense.state='risolta' THEN 'Espansione Difensiva Cellulare'||clan_akimichi_private.common_result_label_v1(defense.outcome) ELSE NULL END,'esito_copie',null,'esito',outcome,
    'intensita',case when outcome='colpito' then case
      when (primary_action.outcome->>'threshold_margin')::integer<5 then 'di striscio'
      when (primary_action.outcome->>'threshold_margin')::integer<15 then 'in pieno' else 'con violenza' end end,
    'fuori_combattimento',coalesce((primary_action.outcome->>'ko')::boolean,false),
    'vantaggio_elementale',null,'distanza_fascia',public._fascia_da_metri(ceil(distance)::integer),
    'movimento_effettivo',movement>0,'player_reports',reports,'gia_visto',left(coalesce(prior,''),400),'model','gpt-6-luna');
end $function$;

ALTER FUNCTION clan_aburame_private.sfera_clear_arena_distance_v1(uuid,uuid,uuid) OWNER TO postgres;
ALTER FUNCTION clan_aburame_private.sfera_crosses_prison_v1(uuid,uuid,uuid) OWNER TO postgres;
ALTER FUNCTION clan_aburame_private.sfera_defense_power_v1(uuid) OWNER TO postgres;
ALTER FUNCTION clan_aburame_private.sfera_end_v1(uuid,text) OWNER TO postgres;
ALTER FUNCTION clan_aburame_private.sfera_escape_meta_v1(uuid,jsonb) OWNER TO postgres;
ALTER FUNCTION clan_aburame_private.sfera_finish_v1(uuid,uuid,boolean) OWNER TO postgres;
ALTER FUNCTION clan_aburame_private.sfera_frozen_v1(uuid) OWNER TO postgres;
ALTER FUNCTION clan_aburame_private.sfera_hits_v1(integer,text,boolean,jsonb,jsonb,jsonb) OWNER TO postgres;
ALTER FUNCTION clan_aburame_private.sfera_meta_v1(uuid,boolean) OWNER TO postgres;
ALTER FUNCTION clan_aburame_private.sfera_narrative_revision_v1(jsonb) OWNER TO postgres;
ALTER FUNCTION clan_aburame_private.sfera_narrative_v1(uuid,uuid) OWNER TO postgres;
ALTER FUNCTION clan_aburame_private.sfera_prepare_offer_v1(uuid) OWNER TO postgres;
ALTER FUNCTION clan_aburame_private.sfera_prison_active_v1(uuid,uuid) OWNER TO postgres;
ALTER FUNCTION clan_aburame_private.sfera_report_v1(uuid) OWNER TO postgres;
ALTER FUNCTION clan_aburame_private.sfera_reserve_v1(uuid) OWNER TO postgres;
ALTER FUNCTION clan_aburame_private.sfera_resolve_escape_v1(uuid) OWNER TO postgres;
ALTER FUNCTION clan_aburame_private.sfera_settle_round_v1(uuid) OWNER TO postgres;
ALTER FUNCTION clan_aburame_private.sfera_staff_prepare_v1(uuid,uuid) OWNER TO postgres;
ALTER FUNCTION clan_aburame_private.sfera_staff_scope_v1(uuid,uuid,uuid) OWNER TO postgres;
ALTER FUNCTION clan_aburame_private.sfera_staff_target_v1(uuid,uuid) OWNER TO postgres;
ALTER FUNCTION clan_aburame_private.sfera_upkeep_turn_v1(uuid,uuid) OWNER TO postgres;
ALTER TABLE clan_aburame_private.sfera_staff_gate_v1 OWNER TO postgres;
ALTER TABLE clan_aburame_private.sfera_staff_gate_v1 FORCE ROW LEVEL SECURITY;
ALTER TABLE clan_aburame_private.sfera_sources_v1 OWNER TO postgres;
ALTER TABLE clan_aburame_private.sfera_sources_v1 FORCE ROW LEVEL SECURITY;
ALTER TABLE clan_aburame_private.sfera_upkeep_v1 OWNER TO postgres;
ALTER TABLE clan_aburame_private.sfera_upkeep_v1 FORCE ROW LEVEL SECURITY;
CREATE OR REPLACE FUNCTION clan_innata_private.catalogo_eligibility_release_v1()
 RETURNS boolean
 LANGUAGE plpgsql
 STABLE SECURITY DEFINER
 SET search_path TO ''
AS $function$
DECLARE
 rr mission_factory_owner.editor_release_readiness%ROWTYPE;root jsonb;binding jsonb;amendment jsonb;
 params constant jsonb:=$compat_metadata${"expected_alias_count":7,"shared_functions":[{"oid":"42942","signature":"combat_consumer_private.narrative_context(uuid)","source_md5":"7cb3411ca6ec879112227533b51c48a0","ddl_md5":"50dcb79fba3e3a93a97bf957daef26b9","abi":{"acl":"{postgres=X/postgres}","oid":"42942","kind":"f","owner":"postgres","config":["search_path=\"\""],"secdef":true,"strict":false,"nspname":"combat_consumer_private","proname":"narrative_context","returns":"jsonb","language":"plpgsql","parallel":"u","arg_modes":null,"arg_names":["p_round"],"arg_types":"2950","leakproof":false,"signature":"combat_consumer_private.narrative_context(uuid)","volatility":"s"}},{"oid":"46723","signature":"combat_consumer_private.narrative_declaration_supported(uuid)","source_md5":"14b40aca0b52866462e92c86ba214250","ddl_md5":"733fab475974d4393412069bc62f63c2","abi":{"acl":"{postgres=X/postgres}","oid":"46723","kind":"f","owner":"postgres","config":["search_path=\"\""],"secdef":true,"strict":false,"nspname":"combat_consumer_private","proname":"narrative_declaration_supported","returns":"boolean","language":"plpgsql","parallel":"u","arg_modes":null,"arg_names":["p_declaration"],"arg_types":"2950","leakproof":false,"signature":"combat_consumer_private.narrative_declaration_supported(uuid)","volatility":"s"}},{"oid":"42968","signature":"combat_consumer_private.validate_narrative_result(jsonb)","source_md5":"5445a1ce4c8ef497402c8bfe6061dcf5","ddl_md5":"3a865e21ea2104faf7598b0fffd3bfeb","abi":{"acl":"{postgres=X/postgres}","oid":"42968","kind":"f","owner":"postgres","config":["search_path=\"\""],"secdef":false,"strict":false,"nspname":"combat_consumer_private","proname":"validate_narrative_result","returns":"void","language":"plpgsql","parallel":"u","arg_modes":null,"arg_names":["p"],"arg_types":"3802","leakproof":false,"signature":"combat_consumer_private.validate_narrative_result(jsonb)","volatility":"i"}},{"oid":"52137","signature":"combat_effects_private.lifecycle_before_report(uuid)","source_md5":"bc4009af6a274d51e6b96fc51f7a7a78","ddl_md5":"ee929b8e4bb4efcd584e7755aa5df682","abi":{"acl":"{postgres=X/postgres}","oid":"52137","kind":"f","owner":"postgres","config":["search_path=\"\""],"secdef":true,"strict":false,"nspname":"combat_effects_private","proname":"lifecycle_before_report","returns":"jsonb","language":"plpgsql","parallel":"u","arg_modes":null,"arg_names":["p_round"],"arg_types":"2950","leakproof":false,"signature":"combat_effects_private.lifecycle_before_report(uuid)","volatility":"v"}},{"oid":"52136","signature":"combat_effects_private.lifecycle_main_end(uuid)","source_md5":"a1948e8ce4fc505fc23e4e4089958507","ddl_md5":"0b743c53cb23a3402542468dc3096430","abi":{"acl":"{postgres=X/postgres}","oid":"52136","kind":"f","owner":"postgres","config":["search_path=\"\""],"secdef":true,"strict":false,"nspname":"combat_effects_private","proname":"lifecycle_main_end","returns":"jsonb","language":"plpgsql","parallel":"u","arg_modes":null,"arg_names":["p_declaration"],"arg_types":"2950","leakproof":false,"signature":"combat_effects_private.lifecycle_main_end(uuid)","volatility":"v"}},{"oid":"52133","signature":"combat_effects_private.lifecycle_open(uuid,uuid)","source_md5":"3f77d8b6698bc4d6c4b3f454c91b104b","ddl_md5":"ccaa8626e04edc3573771689e1401046","abi":{"acl":"{postgres=X/postgres}","oid":"52133","kind":"f","owner":"postgres","config":["search_path=\"\""],"secdef":true,"strict":false,"nspname":"combat_effects_private","proname":"lifecycle_open","returns":"void","language":"plpgsql","parallel":"u","arg_modes":null,"arg_names":["p_session","p_actor"],"arg_types":"2950 2950","leakproof":false,"signature":"combat_effects_private.lifecycle_open(uuid,uuid)","volatility":"v"}},{"oid":"51910","signature":"combat_effects_private.personal_turn_end(uuid,uuid,uuid,text)","source_md5":"29f0a8df88c6bed279f650d49a706699","ddl_md5":"9e8138c513fa0c8824ca9c5d48aa3d54","abi":{"acl":"{postgres=X/postgres}","oid":"51910","kind":"f","owner":"postgres","config":["search_path=\"\""],"secdef":true,"strict":false,"nspname":"combat_effects_private","proname":"personal_turn_end","returns":"jsonb","language":"plpgsql","parallel":"u","arg_modes":null,"arg_names":["p_session","p_actor","p_turn","p_adapter"],"arg_types":"2950 2950 2950 25","leakproof":false,"signature":"combat_effects_private.personal_turn_end(uuid,uuid,uuid,text)","volatility":"v"}},{"oid":"51906","signature":"combat_effects_private.personal_turn_start(uuid,uuid,uuid,text)","source_md5":"e7ec43224a4640d00c53bad72ac0132d","ddl_md5":"d023d8a651a5e8ef8fdb1cc834b93391","abi":{"acl":"{postgres=X/postgres}","oid":"51906","kind":"f","owner":"postgres","config":["search_path=\"\""],"secdef":true,"strict":false,"nspname":"combat_effects_private","proname":"personal_turn_start","returns":"void","language":"plpgsql","parallel":"u","arg_modes":null,"arg_names":["p_session","p_actor","p_turn","p_adapter"],"arg_types":"2950 2950 2950 25","leakproof":false,"signature":"combat_effects_private.personal_turn_start(uuid,uuid,uuid,text)","volatility":"v"}},{"oid":"44942","signature":"combat_panel_private.commit_master_actor(jsonb)","source_md5":"0c39121bcbd32a49608e4d925560ba41","ddl_md5":"b531bb7f50d4346a09e822b2f2e95144","abi":{"acl":"{postgres=X/postgres}","oid":"44942","kind":"f","owner":"postgres","config":["search_path=\"\""],"secdef":true,"strict":false,"nspname":"combat_panel_private","proname":"commit_master_actor","returns":"jsonb","language":"plpgsql","parallel":"u","arg_modes":null,"arg_names":["p_command"],"arg_types":"3802","leakproof":false,"signature":"combat_panel_private.commit_master_actor(jsonb)","volatility":"v"}},{"oid":"45916","signature":"combat_panel_private.immobilization_actor_lifecycle()","source_md5":"5244a1f635ad7d7336d24140d288b82a","ddl_md5":"f8677e282d09ca9015c01de07391f1bc","abi":{"acl":"{postgres=X/postgres}","oid":"45916","kind":"f","owner":"postgres","config":["search_path=\"\""],"secdef":true,"strict":false,"nspname":"combat_panel_private","proname":"immobilization_actor_lifecycle","returns":"trigger","language":"plpgsql","parallel":"u","arg_modes":null,"arg_names":null,"arg_types":"","leakproof":false,"signature":"combat_panel_private.immobilization_actor_lifecycle()","volatility":"v"}},{"oid":"45918","signature":"combat_panel_private.immobilization_session_lifecycle()","source_md5":"a4671931aa6e908a94af2ad2d788d933","ddl_md5":"38bc9bc060bc1af88cf087f5e4a687bb","abi":{"acl":"{postgres=X/postgres}","oid":"45918","kind":"f","owner":"postgres","config":["search_path=\"\""],"secdef":true,"strict":false,"nspname":"combat_panel_private","proname":"immobilization_session_lifecycle","returns":"trigger","language":"plpgsql","parallel":"u","arg_modes":null,"arg_names":null,"arg_types":"","leakproof":false,"signature":"combat_panel_private.immobilization_session_lifecycle()","volatility":"v"}},{"oid":"44940","signature":"combat_panel_private.master_options(uuid,uuid,bigint)","source_md5":"c3ae5fff837af5db1779970e73a414bd","ddl_md5":"6273f7d573951ae327a062c9d2f37099","abi":{"acl":"{postgres=X/postgres}","oid":"44940","kind":"f","owner":"postgres","config":["search_path=\"\""],"secdef":true,"strict":false,"nspname":"combat_panel_private","proname":"master_options","returns":"jsonb","language":"plpgsql","parallel":"u","arg_modes":null,"arg_names":["p_location","p_actor","p_expected"],"arg_types":"2950 2950 20","leakproof":false,"signature":"combat_panel_private.master_options(uuid,uuid,bigint)","volatility":"v"}},{"oid":"45000","signature":"combat_panel_private.movement_block_reason(uuid)","source_md5":"2522ebb08015c0a1342e63c5f3f40c3a","ddl_md5":"02f80418c4b3e6b762aa06dcb743588d","abi":{"acl":"{postgres=X/postgres}","oid":"45000","kind":"f","owner":"postgres","config":["search_path=\"\""],"secdef":true,"strict":false,"nspname":"combat_panel_private","proname":"movement_block_reason","returns":"text","language":"plpgsql","parallel":"u","arg_modes":null,"arg_names":["p_body"],"arg_types":"2950","leakproof":false,"signature":"combat_panel_private.movement_block_reason(uuid)","volatility":"s"}},{"oid":"46019","signature":"combat_panel_private.narrative_declaration_facts(uuid)","source_md5":"6411b500dfb47e2bd30b3fab1cca9d41","ddl_md5":"3e0bc85ed0d20d893b779a482f0799bb","abi":{"acl":"{postgres=X/postgres}","oid":"46019","kind":"f","owner":"postgres","config":["search_path=\"\""],"secdef":true,"strict":false,"nspname":"combat_panel_private","proname":"narrative_declaration_facts","returns":"jsonb","language":"plpgsql","parallel":"u","arg_modes":null,"arg_names":["p_declaration"],"arg_types":"2950","leakproof":false,"signature":"combat_panel_private.narrative_declaration_facts(uuid)","volatility":"s"}},{"oid":"46020","signature":"combat_panel_private.narrative_ordinary_context(uuid)","source_md5":"e7c2a225b3f4432ba16fc96221f08653","ddl_md5":"31b06a04a966582b028e43525d98a411","abi":{"acl":"{postgres=X/postgres}","oid":"46020","kind":"f","owner":"postgres","config":["search_path=\"\""],"secdef":true,"strict":false,"nspname":"combat_panel_private","proname":"narrative_ordinary_context","returns":"jsonb","language":"plpgsql","parallel":"u","arg_modes":null,"arg_names":["p_round"],"arg_types":"2950","leakproof":false,"signature":"combat_panel_private.narrative_ordinary_context(uuid)","volatility":"s"}},{"oid":"46018","signature":"combat_panel_private.narrative_outcome_facts(jsonb)","source_md5":"988cc3b61d0ebf41effda90d32e173b5","ddl_md5":"a4d973f30fbd64ace5540ea3438c8e26","abi":{"acl":"{postgres=X/postgres}","oid":"46018","kind":"f","owner":"postgres","config":["search_path=\"\""],"secdef":false,"strict":false,"nspname":"combat_panel_private","proname":"narrative_outcome_facts","returns":"jsonb","language":"plpgsql","parallel":"u","arg_modes":null,"arg_names":["p_outcome"],"arg_types":"3802","leakproof":false,"signature":"combat_panel_private.narrative_outcome_facts(jsonb)","volatility":"s"}},{"oid":"44669","signature":"combat_panel_private.ordinary_options(uuid,uuid,bigint)","source_md5":"e1e6cd169797dc97d13aee366489d338","ddl_md5":"46424781b6fd6d34a0415090df6703f1","abi":{"acl":"{postgres=X/postgres}","oid":"44669","kind":"f","owner":"postgres","config":["search_path=\"\""],"secdef":true,"strict":false,"nspname":"combat_panel_private","proname":"ordinary_options","returns":"jsonb","language":"plpgsql","parallel":"u","arg_modes":null,"arg_names":["p_location","p_actor","p_expected"],"arg_types":"2950 2950 20","leakproof":false,"signature":"combat_panel_private.ordinary_options(uuid,uuid,bigint)","volatility":"v"}},{"oid":"44955","signature":"combat_panel_private.round_details_from_source(jsonb,jsonb,jsonb)","source_md5":"23722822d09c8d2a12a5121d04c141a6","ddl_md5":"883d64a10bb28250187b01e96e2dcf5e","abi":{"acl":"{postgres=X/postgres}","oid":"44955","kind":"f","owner":"postgres","config":["search_path=\"\""],"secdef":false,"strict":false,"nspname":"combat_panel_private","proname":"round_details_from_source","returns":"jsonb","language":"plpgsql","parallel":"u","arg_modes":null,"arg_names":["p_source","p_roster","p_offers"],"arg_types":"3802 3802 3802","leakproof":false,"signature":"combat_panel_private.round_details_from_source(jsonb,jsonb,jsonb)","volatility":"i"}},{"oid":"46316","signature":"combat_panel_private.round_options_authoritative(uuid,uuid)","source_md5":"7cf9d8be18c9dab5f75b62c74a5e9e37","ddl_md5":"7758a51d9039673ab98462102c44f888","abi":{"acl":"{postgres=X/postgres}","oid":"46316","kind":"f","owner":"postgres","config":["search_path=\"\""],"secdef":true,"strict":false,"nspname":"combat_panel_private","proname":"round_options_authoritative","returns":"jsonb","language":"plpgsql","parallel":"u","arg_modes":null,"arg_names":["p_round","p_actor"],"arg_types":"2950 2950","leakproof":false,"signature":"combat_panel_private.round_options_authoritative(uuid,uuid)","volatility":"v"}},{"oid":"61967","signature":"combat_v2_elemental_internal.other_consumer_options(jsonb)","source_md5":"8423c49ce8a83f2b19361b82a53fa9f4","ddl_md5":"0d57fa274c2b6b63dc5ed1ef0a7c8ca9","abi":{"acl":"{postgres=X/postgres}","oid":"61967","kind":"f","owner":"postgres","config":["search_path=\"\""],"secdef":true,"strict":false,"nspname":"combat_v2_elemental_internal","proname":"other_consumer_options","returns":"jsonb","language":"plpgsql","parallel":"u","arg_modes":null,"arg_names":["p"],"arg_types":"3802","leakproof":false,"signature":"combat_v2_elemental_internal.other_consumer_options(jsonb)","volatility":"v"}},{"oid":"61972","signature":"combat_v2_elemental_internal.other_control_apply(text,uuid,uuid,uuid)","source_md5":"4cf97ca72ff52f1bd33445ba54c8dd16","ddl_md5":"9066a8a35e086727ed0240ea05fce684","abi":{"acl":"{postgres=X/postgres}","oid":"61972","kind":"f","owner":"postgres","config":["search_path=\"\""],"secdef":true,"strict":false,"nspname":"combat_v2_elemental_internal","proname":"other_control_apply","returns":"jsonb","language":"plpgsql","parallel":"u","arg_modes":null,"arg_names":["p_adapter","p_offer","p_actor","p_request"],"arg_types":"25 2950 2950 2950","leakproof":false,"signature":"combat_v2_elemental_internal.other_control_apply(text,uuid,uuid,uuid)","volatility":"v"}},{"oid":"61971","signature":"combat_v2_elemental_internal.other_control_target(text,uuid,uuid)","source_md5":"b1af00f3eab38ed9e74836c5441616d7","ddl_md5":"03724449dfc52ef8fcf4f89ae6eabb34","abi":{"acl":"{postgres=X/postgres}","oid":"61971","kind":"f","owner":"postgres","config":["search_path=\"\""],"secdef":true,"strict":false,"nspname":"combat_v2_elemental_internal","proname":"other_control_target","returns":"uuid","language":"plpgsql","parallel":"u","arg_modes":null,"arg_names":["p_adapter","p_offer","p_actor"],"arg_types":"25 2950 2950","leakproof":false,"signature":"combat_v2_elemental_internal.other_control_target(text,uuid,uuid)","volatility":"v"}},{"oid":"61970","signature":"combat_v2_elemental_internal.other_master_options(uuid,bigint)","source_md5":"0c79a6a78b76b9e9ef8028d75e514af7","ddl_md5":"38e2e92e5566275950c270ef5a8fe3d6","abi":{"acl":"{postgres=X/postgres}","oid":"61970","kind":"f","owner":"postgres","config":["search_path=\"\""],"secdef":true,"strict":false,"nspname":"combat_v2_elemental_internal","proname":"other_master_options","returns":"void","language":"plpgsql","parallel":"u","arg_modes":null,"arg_names":["p_context","p_expected"],"arg_types":"2950 20","leakproof":false,"signature":"combat_v2_elemental_internal.other_master_options(uuid,bigint)","volatility":"v"}},{"oid":"61954","signature":"combat_v2_elemental_internal.other_prepare_native(uuid,uuid,uuid,jsonb,boolean,jsonb)","source_md5":"6e54b476b36ca716cf8c14f33ef9667e","ddl_md5":"98acc6f2f9fcb26b47f3e6e830763e42","abi":{"acl":"{postgres=X/postgres}","oid":"61954","kind":"f","owner":"postgres","config":["search_path=\"\""],"secdef":true,"strict":false,"nspname":"combat_v2_elemental_internal","proname":"other_prepare_native","returns":"jsonb","language":"plpgsql","parallel":"u","arg_modes":null,"arg_names":["p_round","p_actor","p_request","p_intent","p_push","p_native_ref"],"arg_types":"2950 2950 2950 3802 16 3802","leakproof":false,"signature":"combat_v2_elemental_internal.other_prepare_native(uuid,uuid,uuid,jsonb,boolean,jsonb)","volatility":"v"}},{"oid":"61950","signature":"combat_v2_elemental_internal.other_profile(uuid,uuid)","source_md5":"dd1e62e9052469fae4c98fed245c730a","ddl_md5":"0959ae18dc9357f65d8d8169e39b0cb2","abi":{"acl":"{postgres=X/postgres}","oid":"61950","kind":"f","owner":"postgres","config":["search_path=\"\""],"secdef":true,"strict":false,"nspname":"combat_v2_elemental_internal","proname":"other_profile","returns":"jsonb","language":"plpgsql","parallel":"u","arg_modes":null,"arg_names":["p_actor","p_technique"],"arg_types":"2950 2950","leakproof":false,"signature":"combat_v2_elemental_internal.other_profile(uuid,uuid)","volatility":"s"}},{"oid":"39291","signature":"combat_v2_multitarget_internal.resolve_parent(uuid,uuid,uuid,boolean)","source_md5":"4f89aa40d49971d2a74c04b85cd70f09","ddl_md5":"0f1b28887b56ece0e48b3238b3fb92dd","abi":{"acl":"{postgres=X/postgres}","oid":"39291","kind":"f","owner":"postgres","config":["search_path=\"\""],"secdef":true,"strict":false,"nspname":"combat_v2_multitarget_internal","proname":"resolve_parent","returns":"jsonb","language":"plpgsql","parallel":"u","arg_modes":null,"arg_names":["p_session","p_round","p_attack","p_values"],"arg_types":"2950 2950 2950 16","leakproof":false,"signature":"combat_v2_multitarget_internal.resolve_parent(uuid,uuid,uuid,boolean)","volatility":"v"}},{"oid":"42947","signature":"public.combat_consumer_narrative_claim_v1(uuid,text,uuid)","source_md5":"60fce00fae9119dd6b1c8906ef2ea7e8","ddl_md5":"d0a2ae1909d03454dace2f6e3b994ece","abi":{"acl":"{postgres=X/postgres,service_role=X/postgres}","oid":"42947","kind":"f","owner":"postgres","config":["search_path=\"\""],"secdef":true,"strict":false,"nspname":"public","proname":"combat_consumer_narrative_claim_v1","returns":"jsonb","language":"plpgsql","parallel":"u","arg_modes":null,"arg_names":["p_round","p_report_sha256","p_request_key"],"arg_types":"2950 25 2950","leakproof":false,"signature":"public.combat_consumer_narrative_claim_v1(uuid,text,uuid)","volatility":"v"}},{"oid":"42969","signature":"public.combat_consumer_narrative_complete_v1(uuid,jsonb,uuid)","source_md5":"1468dab936825b51e0f802f117a9dd0d","ddl_md5":"e7dc5d07a611fbfa165f2185fa01f8c3","abi":{"acl":"{postgres=X/postgres,service_role=X/postgres}","oid":"42969","kind":"f","owner":"postgres","config":["search_path=\"\""],"secdef":true,"strict":false,"nspname":"public","proname":"combat_consumer_narrative_complete_v1","returns":"jsonb","language":"plpgsql","parallel":"u","arg_modes":null,"arg_names":["p_claim","p_result","p_request_key"],"arg_types":"2950 3802 2950","leakproof":false,"signature":"public.combat_consumer_narrative_complete_v1(uuid,jsonb,uuid)","volatility":"v"}},{"oid":"44808","signature":"public.combat_panel_commit_v1(jsonb)","source_md5":"0b5a0ca3366bb6a302fcdfcddd306f48","ddl_md5":"274c9e4d68f91524e6a5f8904beea48e","abi":{"acl":"{postgres=X/postgres,authenticated=X/postgres}","oid":"44808","kind":"f","owner":"postgres","config":["search_path=\"\""],"secdef":true,"strict":false,"nspname":"public","proname":"combat_panel_commit_v1","returns":"jsonb","language":"plpgsql","parallel":"u","arg_modes":null,"arg_names":["p_command"],"arg_types":"3802","leakproof":false,"signature":"public.combat_panel_commit_v1(jsonb)","volatility":"v"}},{"oid":"31324","signature":"public.combat_v2_action_declare(uuid,uuid,jsonb,text,uuid)","source_md5":"6c23e94b38f8f252c3e49a1d389e588c","ddl_md5":"18cf15dcb36e3fe52b799a70882a77cf","abi":{"acl":"{postgres=X/postgres,authenticated=X/postgres,service_role=X/postgres}","oid":"31324","kind":"f","owner":"postgres","config":["search_path=\"\""],"secdef":true,"strict":false,"nspname":"public","proname":"combat_v2_action_declare","returns":"jsonb","language":"plpgsql","parallel":"u","arg_modes":null,"arg_names":["p_round","p_actor","p_intent","p_text","p_request_key"],"arg_types":"2950 2950 3802 25 2950","leakproof":false,"signature":"public.combat_v2_action_declare(uuid,uuid,jsonb,text,uuid)","volatility":"v"}},{"oid":"31311","signature":"public.combat_v2_actor_ability(uuid,text,uuid,boolean)","source_md5":"2ec5e6a87514a1997100990dde420a62","ddl_md5":"847221b518ed740a64afdcd00f7cd763","abi":{"acl":"{postgres=X/postgres,service_role=X/postgres}","oid":"31311","kind":"f","owner":"postgres","config":["search_path=\"\""],"secdef":true,"strict":false,"nspname":"public","proname":"combat_v2_actor_ability","returns":"jsonb","language":"sql","parallel":"u","arg_modes":null,"arg_names":["p_actor","p_source","p_ability","p_defense"],"arg_types":"2950 25 2950 16","leakproof":false,"signature":"public.combat_v2_actor_ability(uuid,text,uuid,boolean)","volatility":"s"}},{"oid":"31326","signature":"public.combat_v2_defense_declare(uuid,uuid,uuid,jsonb,text,uuid)","source_md5":"446494ad3becd44a65b241967810e589","ddl_md5":"5a97231f154dab9e97c2a03b0cc142ac","abi":{"acl":"{postgres=X/postgres,authenticated=X/postgres,service_role=X/postgres}","oid":"31326","kind":"f","owner":"postgres","config":["search_path=\"\""],"secdef":true,"strict":false,"nspname":"public","proname":"combat_v2_defense_declare","returns":"jsonb","language":"plpgsql","parallel":"u","arg_modes":null,"arg_names":["p_round","p_attack_declaration","p_actor","p_intent","p_text","p_request_key"],"arg_types":"2950 2950 2950 3802 25 2950","leakproof":false,"signature":"public.combat_v2_defense_declare(uuid,uuid,uuid,jsonb,text,uuid)","volatility":"v"}},{"oid":"31331","signature":"public.combat_v2_round_resolve(uuid,uuid)","source_md5":"ea91dd6deeaf06dc059adadfaafd9e95","ddl_md5":"8a9ec59917bb8802f796cc125e9d1e06","abi":{"acl":"{postgres=X/postgres,service_role=X/postgres,authenticated=X/postgres}","oid":"31331","kind":"f","owner":"postgres","config":["search_path=\"\""],"secdef":true,"strict":false,"nspname":"public","proname":"combat_v2_round_resolve","returns":"jsonb","language":"plpgsql","parallel":"u","arg_modes":null,"arg_names":["p_round","p_request_key"],"arg_types":"2950 2950","leakproof":false,"signature":"public.combat_v2_round_resolve(uuid,uuid)","volatility":"v"}},{"oid":"19700","signature":"public.post_heal(uuid,uuid)","source_md5":"dcde447ee079472efa4fd41c1c911633","ddl_md5":"9fb236d5f72312f6fb33587a2981e427","abi":{"acl":"{postgres=X/postgres,service_role=X/postgres,authenticated=X/postgres}","oid":"19700","kind":"f","owner":"postgres","config":["search_path=public"],"secdef":true,"strict":false,"nspname":"public","proname":"post_heal","returns":"text","language":"plpgsql","parallel":"u","arg_modes":null,"arg_names":["p_location","p_target_user"],"arg_types":"2950 2950","leakproof":false,"signature":"public.post_heal(uuid,uuid)","volatility":"v"}}],"private_functions":[{"signature":"combat_panel_private.catalog_lifecycle_lines_v1(jsonb,jsonb)","source_md5":"8a472424ef8d1bc4d04283d18a0d049e"},{"signature":"combat_panel_private.catalog_result_label_v1(jsonb)","source_md5":"eb0798e0d80f5b1215949f4d6d6445bd"},{"signature":"combat_panel_private.cure_bind_v1(uuid)","source_md5":"a9c1bde3a9b0de30c44312b12be60eff"},{"signature":"combat_panel_private.cure_commit_v1(jsonb)","source_md5":"61532836e90ed32ae807b92ee6632b71"},{"signature":"combat_panel_private.cure_contact_v1(uuid,uuid)","source_md5":"21de7dd5e62b5403b50065d2635e20bf"},{"signature":"combat_panel_private.cure_declaration_meta_v1(uuid,uuid,uuid,jsonb)","source_md5":"9fdec7a42f67372bc1f2e2f408f16ba1"},{"signature":"combat_panel_private.cure_defense_guard_v1()","source_md5":"72b7362b50720f93672dfa1ab96338bc"},{"signature":"combat_panel_private.cure_frozen_turn_valid_v1(uuid,uuid)","source_md5":"7785ea336dd4a1deb9dd19487756d638"},{"signature":"combat_panel_private.cure_narrative_facts_v1(uuid)","source_md5":"a32f97cddb31ccf9581ba328f1e94e49"},{"signature":"combat_panel_private.cure_neutral_preset_v1(uuid,uuid,uuid,jsonb)","source_md5":"dd236ae4c47770d25fd79cb2e9707d1f"},{"signature":"combat_panel_private.cure_note_voluntary_v1(uuid,uuid,text,text)","source_md5":"669353b795c5f327bdcd338c9990716d"},{"signature":"combat_panel_private.cure_offers_v1(uuid,bigint,jsonb)","source_md5":"db137b63815164ffd8435bcf87ce245c"},{"signature":"combat_panel_private.cure_persistent_execution_scope_v1(uuid)","source_md5":"ea6a91fa5940c0d3680a36c4ee962880"},{"signature":"combat_panel_private.cure_persistent_scope_v1(uuid)","source_md5":"4fdb37eb54e15b3da2845a41809ccc57"},{"signature":"combat_panel_private.cure_prepare_v1(uuid,uuid,uuid,uuid)","source_md5":"bf7f19036a2846412374c68950126ac5"},{"signature":"combat_panel_private.cure_profile_v1(uuid)","source_md5":"88ec3750ea8aa0661eaa573747325e87"},{"signature":"combat_panel_private.cure_resolve_v1(uuid)","source_md5":"d385538828e19526af5e59dc8d18f167"},{"signature":"combat_panel_private.cure_staff_execution_scope_v1(uuid)","source_md5":"9adc4dfa74e700f54ba58d8691fb8f76"},{"signature":"combat_panel_private.cure_staff_scope_v1(uuid)","source_md5":"343140ae23ba4787fa511d1e6f27092e"},{"signature":"combat_panel_private.cure_turn_clear_v1(uuid,uuid)","source_md5":"ff5fac17361830d01e19aeba05430328"},{"signature":"combat_panel_private.cure_turn_used_v1(uuid,uuid)","source_md5":"11badbd523e79faba44fa282150be54b"},{"signature":"combat_panel_private.cure_voluntary_receipt_guard_v1()","source_md5":"08bacb86944bec00bc213eddf9815dca"},{"signature":"combat_v2_genjutsu_internal.actor_meta(uuid)","source_md5":"df3798ced5e32f7cb5aef4283fd88a00"},{"signature":"combat_v2_genjutsu_internal.ally_contact(uuid,uuid)","source_md5":"32dcc6e95e61d7e9fe2389a398a07334"},{"signature":"combat_v2_genjutsu_internal.bind_release(uuid)","source_md5":"1c6bfe3e32950c77afbb8c7b91a21078"},{"signature":"combat_v2_genjutsu_internal.bind_source(uuid)","source_md5":"80c79fc14b48e386b5920d021d537ba7"},{"signature":"combat_v2_genjutsu_internal.binding(uuid)","source_md5":"404fc795700a7fbe3334464c97a5058b"},{"signature":"combat_v2_genjutsu_internal.comparison(uuid,uuid,jsonb)","source_md5":"e63a4943d52d01b719d9693039c18d6c"},{"signature":"combat_v2_genjutsu_internal.consumer_options(jsonb)","source_md5":"c8daec5fcb19dc88267f7ceab87a2be8"},{"signature":"combat_v2_genjutsu_internal.declaration_events(uuid)","source_md5":"194b5c80d8e4779c66f0fdb8c50f1de3"},{"signature":"combat_v2_genjutsu_internal.declaration_meta(uuid,uuid,uuid,jsonb)","source_md5":"1dadbb12c0a1965b0461133ca0efc5d3"},{"signature":"combat_v2_genjutsu_internal.decorate_outcome(uuid,uuid,jsonb)","source_md5":"d0160238be06fafb4ce521553d4e745a"},{"signature":"combat_v2_genjutsu_internal.defense_intent_allowed(uuid,jsonb)","source_md5":"bf261ee2a0f55a52a8bb9462333058bd"},{"signature":"combat_v2_genjutsu_internal.end_context(uuid,uuid)","source_md5":"9d931f4ac19d9170e6119458d4825b23"},{"signature":"combat_v2_genjutsu_internal.event_binding(uuid,jsonb)","source_md5":"8b3b23a81afc7c2092902373cedbe0d2"},{"signature":"combat_v2_genjutsu_internal.event_public(text)","source_md5":"ecaea9744e8960072a32e7908856f9c0"},{"signature":"combat_v2_genjutsu_internal.kai_defense_valid(uuid,uuid)","source_md5":"1ab8564f473d8a008ba29e8095a4a6de"},{"signature":"combat_v2_genjutsu_internal.master_options(uuid,bigint)","source_md5":"c9fbd722ccef5bc57cbabb67651a788f"},{"signature":"combat_v2_genjutsu_internal.movement_blocked(uuid)","source_md5":"8a243e907877525d58c71429cfbb8f98"},{"signature":"combat_v2_genjutsu_internal.narrative_facts(uuid)","source_md5":"de22bbd83e9ab8edb6a025e5131edde0"},{"signature":"combat_v2_genjutsu_internal.narrative_supported(uuid)","source_md5":"8c498c00f438621c617ae6132318ab66"},{"signature":"combat_v2_genjutsu_internal.open_turn(uuid,uuid)","source_md5":"701defaed0c81b0a6f4ccef2857a4a42"},{"signature":"combat_v2_genjutsu_internal.panel_options(uuid,bigint)","source_md5":"cb344a077d919955ef0f570ba9313d35"},{"signature":"combat_v2_genjutsu_internal.prepare(uuid,uuid,uuid,jsonb)","source_md5":"7275b845d7140c81fd2ec2ac48d3cd91"},{"signature":"combat_v2_genjutsu_internal.preset_ready(uuid)","source_md5":"b087938ff9bdc51ee5518c72beb88c04"},{"signature":"combat_v2_genjutsu_internal.profile()","source_md5":"87cf137eefa6f81cd178c039859c1c45"},{"signature":"combat_v2_genjutsu_internal.quote(uuid)","source_md5":"28ff62253407034032035e6acd8a2b6b"},{"signature":"combat_v2_genjutsu_internal.raw_attack_facts(uuid)","source_md5":"da147cc5595cac875224cbbebfe82ef8"},{"signature":"combat_v2_genjutsu_internal.real_owned(uuid)","source_md5":"f6e8ecb85aeb3c938cdc71eb0cbf80cd"},{"signature":"combat_v2_genjutsu_internal.record_event(text,uuid,jsonb)","source_md5":"9ba46dc99acb5e3063e0d813b55d0f3f"},{"signature":"combat_v2_genjutsu_internal.release_intents(uuid)","source_md5":"269945acde9a25aa53dc34e473366430"},{"signature":"combat_v2_genjutsu_internal.release_meta(uuid,uuid,uuid,jsonb)","source_md5":"9ebfc24d33a07eeb5b9a59eb85fd694e"},{"signature":"combat_v2_genjutsu_internal.report_facts(uuid)","source_md5":"03c90f3dd07812d1061c7037216304d9"},{"signature":"combat_v2_genjutsu_internal.report_projection(uuid)","source_md5":"d3c2e36c0248730650a6c6c4b34d1e47"},{"signature":"combat_v2_genjutsu_internal.resolution_enter(uuid,uuid)","source_md5":"c45574805f3171628ef99392fa255eb2"},{"signature":"combat_v2_genjutsu_internal.resolution_leave()","source_md5":"612f97c08785e572226423ed5c1f68ed"},{"signature":"combat_v2_genjutsu_internal.resolve_release(uuid)","source_md5":"0e5d351b87010bb3eaa271cb63099661"},{"signature":"combat_v2_genjutsu_internal.runtime_allowed(uuid)","source_md5":"8512b2d982094a3b339de4ec3bfd3327"},{"signature":"combat_v2_genjutsu_internal.scope(uuid)","source_md5":"ca9d5c5a82c1eeb64af358016ac50c1f"},{"signature":"combat_v2_genjutsu_internal.source_valid(uuid)","source_md5":"84ca595cfd34b8467b69c0256e94e254"},{"signature":"combat_v2_genjutsu_internal.staff_bind(uuid,uuid)","source_md5":"b8b6261b5c8f7df3c91400d5969d8eae"},{"signature":"combat_v2_genjutsu_internal.success(jsonb,integer,boolean)","source_md5":"90faca8a42e9f7f54726276f5a1e94bf"},{"signature":"combat_v2_genjutsu_internal.turn_end(uuid,uuid,uuid,text)","source_md5":"5130f380992a3585b502934e2833e716"},{"signature":"combat_v2_genjutsu_internal.turn_start(uuid,uuid,uuid,text)","source_md5":"b1781f3637f8c3414a9dd2c4038869c2"},{"signature":"combat_v2_genjutsu_internal.validate_attack_facts(jsonb)","source_md5":"0c6434b64a325213dbf8d18c603ed061"},{"signature":"combat_v2_genjutsu_internal.validate_release_facts(jsonb)","source_md5":"a46a047fa733321603e24a6102d7183d"}],"relations":[{"name":"combat_panel_private.cure_gate_v1","columns":[{"name":"singleton","type":"boolean","not_null":true,"default":"true"},{"name":"staff_enabled","type":"boolean","not_null":true,"default":"false"},{"name":"public_enabled","type":"boolean","not_null":true,"default":"false"},{"name":"contract_version","type":"text","not_null":true,"default":"'palmo-curativo/1'::text"}]},{"name":"combat_panel_private.cure_ledger_v1","columns":[{"name":"declaration_id","type":"uuid","not_null":true,"default":null},{"name":"session_id","type":"uuid","not_null":true,"default":null},{"name":"round_id","type":"uuid","not_null":true,"default":null},{"name":"actor_id","type":"uuid","not_null":true,"default":null},{"name":"target_actor_id","type":"uuid","not_null":true,"default":null},{"name":"hp_before","type":"integer","not_null":true,"default":null},{"name":"hp_after","type":"integer","not_null":true,"default":null},{"name":"hp_max","type":"integer","not_null":true,"default":null},{"name":"expected_gain","type":"integer","not_null":true,"default":null},{"name":"committed_gain","type":"integer","not_null":true,"default":null},{"name":"applied_real_gain","type":"integer","not_null":true,"default":"0"},{"name":"is_simulated","type":"boolean","not_null":true,"default":null},{"name":"facts","type":"jsonb","not_null":true,"default":null},{"name":"created_at","type":"timestamp with time zone","not_null":true,"default":"clock_timestamp()"}]},{"name":"combat_panel_private.cure_preparations_v1","columns":[{"name":"request_key","type":"uuid","not_null":true,"default":null},{"name":"transaction_id","type":"bigint","not_null":true,"default":null},{"name":"session_id","type":"uuid","not_null":true,"default":null},{"name":"round_id","type":"uuid","not_null":true,"default":null},{"name":"actor_id","type":"uuid","not_null":true,"default":null},{"name":"target_actor_id","type":"uuid","not_null":true,"default":null},{"name":"controller_user","type":"uuid","not_null":true,"default":null},{"name":"controller_version","type":"bigint","not_null":true,"default":null},{"name":"source","type":"jsonb","not_null":true,"default":null},{"name":"source_sha256","type":"text","not_null":true,"default":null},{"name":"declaration_id","type":"uuid","not_null":false,"default":null},{"name":"created_at","type":"timestamp with time zone","not_null":true,"default":"clock_timestamp()"}]},{"name":"combat_panel_private.cure_staff_profiles_v1","columns":[{"name":"actor_id","type":"uuid","not_null":true,"default":null},{"name":"session_id","type":"uuid","not_null":true,"default":null},{"name":"context_id","type":"uuid","not_null":true,"default":null},{"name":"controller_user","type":"uuid","not_null":true,"default":null},{"name":"controller_version","type":"bigint","not_null":true,"default":null},{"name":"ability","type":"jsonb","not_null":true,"default":null},{"name":"proof_sha256","type":"text","not_null":true,"default":null},{"name":"request_key","type":"uuid","not_null":true,"default":null},{"name":"created_at","type":"timestamp with time zone","not_null":true,"default":"clock_timestamp()"}]},{"name":"combat_panel_private.cure_voluntary_actions_v1","columns":[{"name":"actor_id","type":"uuid","not_null":true,"default":null},{"name":"round_id","type":"uuid","not_null":true,"default":null},{"name":"source_kind","type":"text","not_null":true,"default":null},{"name":"source_key","type":"text","not_null":true,"default":null},{"name":"created_at","type":"timestamp with time zone","not_null":true,"default":"clock_timestamp()"}]},{"name":"combat_v2_genjutsu_internal.effects","columns":[{"name":"id","type":"uuid","not_null":true,"default":"gen_random_uuid()"},{"name":"session_id","type":"uuid","not_null":true,"default":null},{"name":"source_declaration_id","type":"uuid","not_null":true,"default":null},{"name":"source_attack_target_id","type":"uuid","not_null":true,"default":null},{"name":"source_actor_id","type":"uuid","not_null":true,"default":null},{"name":"target_actor_id","type":"uuid","not_null":true,"default":null},{"name":"profile","type":"jsonb","not_null":true,"default":null},{"name":"source_outcome_sha256","type":"text","not_null":true,"default":null},{"name":"adapter","type":"text","not_null":true,"default":null},{"name":"excluded_turn_id","type":"uuid","not_null":false,"default":null},{"name":"due_turn_id","type":"uuid","not_null":false,"default":null},{"name":"state","type":"text","not_null":true,"default":null},{"name":"state_version","type":"bigint","not_null":true,"default":"1"},{"name":"created_at","type":"timestamp with time zone","not_null":true,"default":"clock_timestamp()"},{"name":"ended_at","type":"timestamp with time zone","not_null":false,"default":null},{"name":"end_reason","type":"text","not_null":false,"default":null}]},{"name":"combat_v2_genjutsu_internal.events","columns":[{"name":"event_key","type":"text","not_null":true,"default":null},{"name":"effect_id","type":"uuid","not_null":false,"default":null},{"name":"result","type":"jsonb","not_null":true,"default":null},{"name":"result_sha256","type":"text","not_null":true,"default":null},{"name":"binding","type":"jsonb","not_null":true,"default":null},{"name":"binding_sha256","type":"text","not_null":true,"default":null},{"name":"created_at","type":"timestamp with time zone","not_null":true,"default":"clock_timestamp()"}]},{"name":"combat_v2_genjutsu_internal.gate","columns":[{"name":"singleton","type":"boolean","not_null":true,"default":null},{"name":"enabled","type":"boolean","not_null":true,"default":null},{"name":"staff_enabled","type":"boolean","not_null":true,"default":null},{"name":"public_enabled","type":"boolean","not_null":true,"default":null},{"name":"version","type":"integer","not_null":true,"default":null}]},{"name":"combat_v2_genjutsu_internal.preparations","columns":[{"name":"actor_id","type":"uuid","not_null":true,"default":null},{"name":"round_id","type":"uuid","not_null":true,"default":null},{"name":"request_id","type":"uuid","not_null":true,"default":null},{"name":"transaction_id","type":"bigint","not_null":true,"default":null},{"name":"source","type":"jsonb","not_null":true,"default":null},{"name":"source_sha256","type":"text","not_null":true,"default":null}]},{"name":"combat_v2_genjutsu_internal.release_plans","columns":[{"name":"actor_id","type":"uuid","not_null":true,"default":null},{"name":"round_id","type":"uuid","not_null":true,"default":null},{"name":"request_id","type":"uuid","not_null":true,"default":null},{"name":"effect_id","type":"uuid","not_null":true,"default":null},{"name":"source","type":"jsonb","not_null":true,"default":null},{"name":"source_sha256","type":"text","not_null":true,"default":null},{"name":"transaction_id","type":"bigint","not_null":true,"default":null},{"name":"declaration_id","type":"uuid","not_null":false,"default":null},{"name":"declaration_sha256","type":"text","not_null":false,"default":null},{"name":"result","type":"jsonb","not_null":false,"default":null},{"name":"result_sha256","type":"text","not_null":false,"default":null}]},{"name":"combat_v2_genjutsu_internal.sources","columns":[{"name":"declaration_id","type":"uuid","not_null":true,"default":null},{"name":"session_id","type":"uuid","not_null":true,"default":null},{"name":"source","type":"jsonb","not_null":true,"default":null},{"name":"declaration_sha256","type":"text","not_null":true,"default":null},{"name":"source_sha256","type":"text","not_null":true,"default":null}]},{"name":"combat_v2_genjutsu_internal.staff_receipts","columns":[{"name":"actor_id","type":"uuid","not_null":true,"default":null},{"name":"session_id","type":"uuid","not_null":true,"default":null},{"name":"controller_user","type":"uuid","not_null":true,"default":null},{"name":"controller_version","type":"bigint","not_null":true,"default":null},{"name":"request_id","type":"uuid","not_null":true,"default":null},{"name":"receipt","type":"jsonb","not_null":true,"default":null},{"name":"receipt_sha256","type":"text","not_null":true,"default":null}]}],"triggers":[{"table":"clan_akimichi_private.form_commands","name":"cure_voluntary_receipt_v1","function":"combat_panel_private.cure_voluntary_receipt_guard_v1()","type":7},{"table":"clan_hoki_private.combat_events","name":"cure_voluntary_receipt_v1","function":"combat_panel_private.cure_voluntary_receipt_guard_v1()","type":7},{"table":"clan_innata_combat_private.combat_receipts","name":"cure_voluntary_receipt_v1","function":"combat_panel_private.cure_voluntary_receipt_guard_v1()","type":7},{"table":"clan_inuzuka_private.movement_receipts","name":"cure_voluntary_receipt_v1","function":"combat_panel_private.cure_voluntary_receipt_guard_v1()","type":7},{"table":"clan_marionettisti_private.control_events","name":"cure_voluntary_receipt_v1","function":"combat_panel_private.cure_voluntary_receipt_guard_v1()","type":7},{"table":"clan_marionettisti_private.movement_receipts","name":"cure_voluntary_receipt_v1","function":"combat_panel_private.cure_voluntary_receipt_guard_v1()","type":7},{"table":"clan_sabaku_private.armor_events","name":"cure_voluntary_receipt_v1","function":"combat_panel_private.cure_voluntary_receipt_guard_v1()","type":7},{"table":"combat_panel_private.master_movement_receipts","name":"cure_voluntary_receipt_v1","function":"combat_panel_private.cure_voluntary_receipt_guard_v1()","type":7},{"table":"combat_panel_private.request_receipts","name":"cure_voluntary_receipt_v1","function":"combat_panel_private.cure_voluntary_receipt_guard_v1()","type":7},{"table":"public.combat_v2_declarations","name":"cure_turn_defense_guard_v1","function":"combat_panel_private.cure_defense_guard_v1()","type":7}],"native_functions":[{"signature":"public.combat_v2_substitution_options_v1(uuid)","source_md5":"913cfd7a596794334b9b3ec8baa103a2","owner":"postgres","acl":"{postgres=X/postgres,authenticated=X/postgres}","config":["search_path=\"\""],"secdef":true,"volatility":"v","strict":false,"parallel":"u","language":"plpgsql","returns":"jsonb","arg_names":["p_attack_declaration"],"arg_modes":null,"arg_types":"2950","ddl_md5":"1dc4d3088d39991411d875ec662c5123"},{"signature":"public.combat_v2_substitution_round_offers_v1(uuid,uuid)","source_md5":"7f3c2e198105d066aceb762872f51a3d","owner":"postgres","acl":"{postgres=X/postgres,authenticated=X/postgres}","config":["search_path=\"\""],"secdef":true,"volatility":"v","strict":false,"parallel":"u","language":"plpgsql","returns":"jsonb","arg_names":["p_round","p_actor"],"arg_modes":null,"arg_types":"2950 2950","ddl_md5":"3a2b1781cc15da44f69cb940e527e864"},{"signature":"public.combat_v2_substitution_select_v1(uuid,uuid)","source_md5":"209648a06d537ad5b8870bdf8fe5c4cb","owner":"postgres","acl":"{postgres=X/postgres,authenticated=X/postgres}","config":["search_path=\"\""],"secdef":true,"volatility":"v","strict":false,"parallel":"u","language":"plpgsql","returns":"jsonb","arg_names":["p_substitution_option_id","p_request_key"],"arg_modes":null,"arg_types":"2950 2950","ddl_md5":"f2f454ef2248e5f310fdfade6e868657"}]}$compat_metadata$::jsonb;
 shared_manifest jsonb:='[]';private_manifest jsonb:='[]';relation_manifest jsonb:='[]';trigger_manifest jsonb:='[]';
 native_manifest jsonb:='[]';changed_manifest jsonb;item jsonb;h jsonb;abi jsonb;cols jsonb;descriptor jsonb;next_descriptor jsonb;kv record;
 relation_oid oid;function_oid oid;actual_count integer;aliases integer:=0;
 shared_sha text;private_sha text;relations_sha text;
 pending_paths text[]:=ARRAY['["db_core"]'];current_path text[];stack_size integer;
BEGIN
 SELECT * INTO STRICT rr FROM mission_factory_owner.editor_release_readiness WHERE singleton;
 root:=rr.canonical_preimage::jsonb;binding:=root#>'{db_core,catalogo_eligibility_compat}';
 -- Legacy/recovery non acquisisce un PASS dal nuovo ramo: resta il sigillo storico completo.
 IF binding IS NULL OR binding->>'state'='inert_recovery' THEN RETURN false;END IF;
 IF binding->>'schema_version'IS DISTINCT FROM 'catalogo-eligibility-compat/1'
 OR binding->>'state'IS DISTINCT FROM 'active_compatibility'
 OR binding->>'parent_root'IS DISTINCT FROM 'f460be0a321e1640d7993a15285cf1b6352166cda41e991f0c644f29bd6a3658'
 OR binding->>'base_catalogo_source_bundle_sha256'IS DISTINCT FROM '825a1c14a59281fb3168430a993e9f2dbbbc41042f5169638d2e9c1e8e9868a5'
 OR coalesce(binding->>'source_bundle_sha256','')!~'^[0-9a-f]{64}$'
 OR coalesce(binding#>>'{review,sha256}','')!~'^[0-9a-f]{64}$'OR nullif(binding#>>'{review,ref}','')IS NULL
 OR binding#>'{review,P0}'IS DISTINCT FROM '0'::jsonb OR binding#>'{review,P1}'IS DISTINCT FROM '0'::jsonb OR binding#>'{review,P2}'IS DISTINCT FROM '0'::jsonb
 OR rr.state NOT IN('enabled','prepared')OR rr.scope<>'staff'OR NOT rr.staff_guards_verified OR NOT rr.published_assets_verified
 OR rr.observed_revision_sha256 IS DISTINCT FROM rr.revision_sha256
 OR encode(extensions.digest(convert_to(rr.canonical_preimage,'UTF8'),'sha256'),'hex')IS DISTINCT FROM rr.revision_sha256
 OR octet_length(rr.canonical_preimage)>524288
 OR root#>>'{db_core,sha256}'IS DISTINCT FROM public.combat_v2_sha256((root->'db_core')-'sha256')
 OR root#>>'{config,sha256}'IS DISTINCT FROM public.combat_v2_sha256((root->'config')-'sha256')
 OR root#>>'{db_core,catalogo_completo,source_bundle_sha256}'IS DISTINCT FROM binding->>'base_catalogo_source_bundle_sha256'
 OR root#>'{config,catalogo_eligibility_compat}'IS DISTINCT FROM binding
 THEN RAISE EXCEPTION 'catalogo_eligibility_root_admission_drift';END IF;
 IF binding->>'normalized_source_identity_sha256'IS DISTINCT FROM '17fd985dfe72c4c6ad3638c01ad019a1f3deb1c21f587a6a0e98c39458e6550f'
 OR public.combat_v2_sha256(binding->'normalized_source_identity')IS DISTINCT FROM binding->>'normalized_source_identity_sha256'
 THEN RAISE EXCEPTION 'catalogo_eligibility_peer_identity_drift';END IF;
 IF EXISTS(WITH expected(sig,sha,acl)AS(VALUES ('combat_panel_private.mask_native_state(jsonb)','1d2f6ad44b2ff1e9c15d897e38fee54b67c744411081f906bc33a26a42600dac','postgres:EXECUTE:false'),('combat_v2_elemental_internal.other_ability_meta(uuid,jsonb)','15fab8ec94575b4a0e163cfbdcc46272b02d47d772daa262de5483a43b18f5ac','postgres:EXECUTE:false'),('combat_panel_private.round_options_authoritative(uuid,uuid)','22bd8c8faf60ba44a644bf9ccd0f69ab8a5715383c79ff6014509dfd02290554','postgres:EXECUTE:false'),('combat_v2_elemental_internal.eligible_v1(uuid,uuid,boolean)','a5161f2993a4e0ce51864ac67ea88ba3fa6966457da1caf4ca390f17c2b1d8e9','postgres:EXECUTE:false,service_role:EXECUTE:false'),('combat_v2_elemental_internal.is_target_v1(uuid)','8af6bdfc87b76ed118b596f7c7885c6de849c5d89140f61cdd1845047cbd5724','postgres:EXECUTE:false,service_role:EXECUTE:false'),('public.combat_v2_actor_ability(uuid,text,uuid,boolean)','31512f4525275b901ce810f8d23d15a3221091ae6a0f062c40a8d4232c038748','postgres:EXECUTE:false,service_role:EXECUTE:false'),('public.combat_v2_character_snapshot(uuid)','9d97f3d6acd6f723f82b51723be91d0a185ee1be1b8060f5bd9d41379d65ea1d','postgres:EXECUTE:false,service_role:EXECUTE:false'),('public.combat_v2_round_options(uuid,uuid)','0b3acc15933027fa840ca03c0d02f082aecf6f2ccedcdefd737127bed1d853d1','authenticated:EXECUTE:false,postgres:EXECUTE:false,service_role:EXECUTE:false'))SELECT 1 FROM expected e LEFT JOIN pg_proc p ON p.oid=to_regprocedure(e.sig)
 WHERE p.oid IS NULL OR encode(extensions.digest(convert_to(pg_get_functiondef(p.oid),'UTF8'),'sha256'),'hex')IS DISTINCT FROM e.sha
 OR p.proowner IS DISTINCT FROM 'postgres'::regrole OR p.prosecdef IS DISTINCT FROM true OR p.proconfig IS DISTINCT FROM ARRAY['search_path=""']
 OR(SELECT string_agg(coalesce(r.rolname,'PUBLIC')||':'||x.privilege_type||':'||x.is_grantable,','ORDER BY coalesce(r.rolname,'PUBLIC'),x.privilege_type,x.is_grantable)
 FROM aclexplode(coalesce(p.proacl,acldefault('f',p.proowner)))x LEFT JOIN pg_roles r ON r.oid=x.grantee)IS DISTINCT FROM e.acl)
 THEN RAISE EXCEPTION 'catalogo_eligibility_owning_port_drift';END IF;
 amendment:=root#>'{db_core,cure_command_amendment}';
 IF amendment->>'schema_version'IS DISTINCT FROM 'cure-command-amendment/1'OR coalesce(amendment->>'state','')NOT IN('active_amendment','inert_recovery')
 OR amendment->>'active_repair_kind'IS DISTINCT FROM 'paralisi-label-dispatch/1'
 OR amendment->>'commit_source_md5'IS DISTINCT FROM '61532836e90ed32ae807b92ee6632b71'
 OR amendment->>'neutral_source_md5'IS DISTINCT FROM 'dd236ae4c47770d25fd79cb2e9707d1f'
 OR amendment->>'normalized_source_identity_sha256'IS DISTINCT FROM 'e15919762cc27a609fa6938653354e0e1e328c0cabfa4914378fb03d908c7338'
 OR public.combat_v2_sha256(amendment->'normalized_source_identity')IS DISTINCT FROM amendment->>'normalized_source_identity_sha256'
 OR amendment->>'base_catalogo_source_bundle_sha256'IS DISTINCT FROM '825a1c14a59281fb3168430a993e9f2dbbbc41042f5169638d2e9c1e8e9868a5'
 OR amendment->>'base_compat_source_bundle_sha256'IS DISTINCT FROM binding->>'source_bundle_sha256'
 OR amendment->>'base_compat_source_bundle_sha256'IS DISTINCT FROM '654f8fff2f42019ffc4b3ccc6c467fff443ba81f00c7aa020fbd6d7950e2445e'
 OR amendment->>'base_private_functions_manifest_sha256'IS DISTINCT FROM root#>>'{db_core,catalogo_completo,private_functions_manifest_sha256}'
 OR coalesce(amendment->>'source_bundle_sha256','')!~'^[0-9a-f]{64}$'
 OR binding->>'active_amendment_source_bundle_sha256'IS DISTINCT FROM amendment->>'source_bundle_sha256'
 OR root#>'{config,cure_command_amendment}'IS DISTINCT FROM amendment
 OR coalesce(amendment#>>'{review,sha256}','')!~'^[0-9a-f]{64}$'OR nullif(amendment#>>'{review,ref}','')IS NULL
 OR amendment#>'{review,P0}'IS DISTINCT FROM '0'::jsonb OR amendment#>'{review,P1}'IS DISTINCT FROM '0'::jsonb OR amendment#>'{review,P2}'IS DISTINCT FROM '0'::jsonb
 THEN RAISE EXCEPTION 'cure_command_active_amendment_drift';END IF;
 IF amendment->>'state'='inert_recovery'AND NOT EXISTS(SELECT 1 FROM combat_panel_private.cure_gate_v1 WHERE singleton AND NOT staff_enabled AND NOT public_enabled)THEN RAISE EXCEPTION 'cure_neutral_inert_requires_cure_off';END IF;
 -- The label formatter is outside the historic34/66 domains: its exact
 -- DDL/ACL is covered by the owning-port pins above, not a generic grant.
 IF root#>>'{db_core,paralisi_label,schema_version}' IS DISTINCT FROM 'paralisi-label/1'
 OR root#>'{config,paralisi_label}' IS DISTINCT FROM root#>'{db_core,paralisi_label}'
 OR root#>>'{db_core,paralisi_label,leaf_sha256}' IS DISTINCT FROM '0705927fad1de34d8422b68fb4eda5c96fc7b000a77367a3a8ec0e9d15cfa02f'
 OR root#>>'{db_core,paralisi_label,source_bundle_sha256}' IS DISTINCT FROM amendment->>'source_bundle_sha256'
 OR root#>'{db_core,paralisi_label,review}' IS DISTINCT FROM amendment->'review'
 THEN RAISE EXCEPTION 'paralisi_label_root_binding_drift';END IF;
 -- Snapshot condiviso DOPO i delta PM. Nessuna esecuzione di corpi storici.
 FOR item IN SELECT value FROM jsonb_array_elements(params->'shared_functions') ORDER BY value->>'signature' LOOP
  SELECT jsonb_build_object('oid',p.oid::text,'signature',p.oid::regprocedure::text,
   'source_md5',md5(p.prosrc),'ddl_md5',md5(pg_get_functiondef(p.oid)),
   'owner',pg_get_userbyid(p.proowner),'acl',p.proacl::text,'config',p.proconfig,'secdef',p.prosecdef,
   'volatility',p.provolatile::text,'language',l.lanname,'strict',p.proisstrict,'parallel',p.proparallel::text,
   'kind',p.prokind::text,'returns',pg_get_function_result(p.oid),'arg_names',p.proargnames,'arg_modes',p.proargmodes,
   'arg_types',p.proargtypes::text,'leakproof',p.proleakproof,'nspname',n.nspname,'proname',p.proname)
   INTO h FROM pg_proc p JOIN pg_namespace n ON n.oid=p.pronamespace JOIN pg_language l ON l.oid=p.prolang
   WHERE p.oid=to_regprocedure(item->>'signature') AND p.prokind='f';
  IF h IS NULL OR h->>'oid' IS DISTINCT FROM item->>'oid'
  OR h->>'source_md5' IS DISTINCT FROM item->>'source_md5' OR h->>'ddl_md5' IS DISTINCT FROM item->>'ddl_md5'
  OR h-ARRAY['source_md5','ddl_md5'] IS DISTINCT FROM item->'abi' THEN
   RAISE EXCEPTION 'CATALOGO_ROOT_SHARED_ABI_OR_BODY_DRIFT:%',item->>'signature';END IF;
  shared_manifest:=shared_manifest||jsonb_build_array(h);
 END LOOP;
 IF (SELECT count(DISTINCT value->>'oid') FROM jsonb_array_elements(shared_manifest))<>jsonb_array_length(shared_manifest) THEN
  RAISE EXCEPTION 'CATALOGO_ROOT_DUPLICATE_SHARED_OID';END IF;
 -- Stack di soli percorsi: non replica l'intera Root in righe o gruppi SQL.
 WHILE coalesce(cardinality(pending_paths),0)>0 LOOP
  stack_size:=cardinality(pending_paths);
  SELECT ARRAY(SELECT jsonb_array_elements_text(pending_paths[stack_size]::jsonb)) INTO current_path;
  pending_paths:=pending_paths[1:stack_size-1];descriptor:=root#>current_path;
  IF jsonb_typeof(descriptor)='object' THEN
   SELECT value INTO h FROM jsonb_array_elements(shared_manifest) WHERE value->>'oid'=descriptor->>'oid';
   IF descriptor ? 'oid' AND h IS NOT NULL THEN
    FOR kv IN SELECT key,value FROM jsonb_each(descriptor) WHERE key=ANY(ARRAY['owner','acl','config','secdef','strict','language','parallel','arg_modes','arg_names','arg_types','leakproof','returns','volatility','kind','signature','nspname','proname']) LOOP
     IF kv.value IS DISTINCT FROM h->kv.key THEN RAISE EXCEPTION 'CATALOGO_ROOT_ALIAS_ABI_DRIFT:%',array_to_string(current_path,'.');END IF;
    END LOOP;
    next_descriptor:=descriptor;
    IF descriptor ? 'source_md5' THEN next_descriptor:=jsonb_set(next_descriptor,'{source_md5}',h->'source_md5',false);END IF;
    IF descriptor ? 'ddl_md5' THEN next_descriptor:=jsonb_set(next_descriptor,'{ddl_md5}',h->'ddl_md5',false);END IF;
    IF next_descriptor IS DISTINCT FROM descriptor THEN RAISE EXCEPTION 'catalogo_eligibility_root_alias_drift';END IF;
    root:=jsonb_set(root,current_path,next_descriptor,false);aliases:=aliases+1;
   ELSE
    FOR kv IN SELECT key,value FROM jsonb_each(descriptor) WHERE jsonb_typeof(value)IN('object','array') LOOP
     pending_paths:=array_append(pending_paths,to_jsonb(array_append(current_path,kv.key))::text);
    END LOOP;
   END IF;
  ELSIF jsonb_typeof(descriptor)='array' THEN
   FOR kv IN SELECT(ord-1)::text AS key,value FROM jsonb_array_elements(descriptor)WITH ORDINALITY x(value,ord)
    WHERE jsonb_typeof(value)IN('object','array') LOOP
    pending_paths:=array_append(pending_paths,to_jsonb(array_append(current_path,kv.key))::text);
   END LOOP;
  END IF;
 END LOOP;
 IF aliases IS DISTINCT FROM(params->>'expected_alias_count')::integer THEN RAISE EXCEPTION 'CATALOGO_ROOT_ALIAS_COUNT';END IF;
 shared_sha:=public.combat_v2_sha256(shared_manifest);

 FOR item IN SELECT value FROM jsonb_array_elements(params->'private_functions') ORDER BY value->>'signature' LOOP
  function_oid:=to_regprocedure(item->>'signature');
  SELECT jsonb_build_object('signature',p.oid::regprocedure::text,'source_md5',md5(p.prosrc),'ddl_md5',md5(pg_get_functiondef(p.oid)),
   'owner',pg_get_userbyid(p.proowner),'acl',p.proacl::text,'config',p.proconfig,'secdef',p.prosecdef,
   'volatility',p.provolatile::text,'language',l.lanname,'strict',p.proisstrict,'parallel',p.proparallel::text,
   'returns',pg_get_function_result(p.oid),'arg_names',p.proargnames,'arg_modes',p.proargmodes,'arg_types',p.proargtypes::text)
   INTO h FROM pg_proc p JOIN pg_namespace n ON n.oid=p.pronamespace JOIN pg_language l ON l.oid=p.prolang
   WHERE p.oid=function_oid AND p.prokind='f' AND(n.nspname='combat_v2_genjutsu_internal' OR(n.nspname='combat_panel_private' AND(p.proname LIKE 'cure\_%' ESCAPE '\' OR p.proname IN('catalog_result_label_v1','catalog_lifecycle_lines_v1'))));
  IF h IS NULL OR h->>'source_md5' IS DISTINCT FROM item->>'source_md5' OR h->>'owner'<>'postgres'
   OR has_function_privilege('anon',function_oid,'EXECUTE') OR has_function_privilege('authenticated',function_oid,'EXECUTE') THEN
   RAISE EXCEPTION 'CATALOGO_ROOT_PRIVATE_BODY_OR_PRIVILEGE:%',item->>'signature';END IF;
  private_manifest:=private_manifest||jsonb_build_array(h);
 END LOOP;
 SELECT count(*) INTO actual_count FROM pg_proc p JOIN pg_namespace n ON n.oid=p.pronamespace
  WHERE p.prokind='f' AND(n.nspname='combat_v2_genjutsu_internal' OR(n.nspname='combat_panel_private' AND(p.proname LIKE 'cure\_%' ESCAPE '\' OR p.proname IN('catalog_result_label_v1','catalog_lifecycle_lines_v1'))));
 IF actual_count<>jsonb_array_length(private_manifest)
 OR actual_count<>(SELECT count(DISTINCT value->>'signature')FROM jsonb_array_elements(private_manifest)) THEN
  RAISE EXCEPTION 'CATALOGO_ROOT_PRIVATE_MANIFEST_COVERAGE';END IF;
 private_sha:=public.combat_v2_sha256(private_manifest);

 FOR item IN SELECT value FROM jsonb_array_elements(params->'relations') ORDER BY value->>'name' LOOP
  relation_oid:=to_regclass(item->>'name');
  SELECT jsonb_agg(jsonb_build_object('name',a.attname,'type',format_type(a.atttypid,a.atttypmod),
   'not_null',a.attnotnull,'default',pg_get_expr(d.adbin,d.adrelid))ORDER BY a.attnum) INTO cols
   FROM pg_attribute a LEFT JOIN pg_attrdef d ON d.adrelid=a.attrelid AND d.adnum=a.attnum
   WHERE a.attrelid=relation_oid AND a.attnum>0 AND NOT a.attisdropped;
  SELECT jsonb_build_object('name',n.nspname||'.'||c.relname,'owner',pg_get_userbyid(c.relowner),'acl',c.relacl::text,
   'rls',c.relrowsecurity,'force_rls',c.relforcerowsecurity,'persistence',c.relpersistence::text,'columns',cols,
   'constraints',(SELECT coalesce(jsonb_agg(jsonb_build_object('name',k.conname,'definition',pg_get_constraintdef(k.oid),'validated',k.convalidated)ORDER BY k.conname),'[]')FROM pg_constraint k WHERE k.conrelid=c.oid),
   'indexes',(SELECT coalesce(jsonb_agg(jsonb_build_object('name',ic.relname,'definition',pg_get_indexdef(i.indexrelid),'valid',i.indisvalid)ORDER BY ic.relname),'[]')FROM pg_index i JOIN pg_class ic ON ic.oid=i.indexrelid WHERE i.indrelid=c.oid),
   'policies',(SELECT coalesce(jsonb_agg(jsonb_build_object('name',p.polname,'command',p.polcmd,'roles',p.polroles::text,'using',pg_get_expr(p.polqual,p.polrelid),'check',pg_get_expr(p.polwithcheck,p.polrelid))ORDER BY p.polname),'[]')FROM pg_policy p WHERE p.polrelid=c.oid))
   INTO h FROM pg_class c JOIN pg_namespace n ON n.oid=c.relnamespace WHERE c.oid=relation_oid AND c.relkind IN('r','p')
    AND(n.nspname='combat_v2_genjutsu_internal' OR(n.nspname='combat_panel_private' AND c.relname LIKE 'cure\_%' ESCAPE '\'));
  IF h IS NULL OR h->'rls' IS DISTINCT FROM 'true'::jsonb OR h->>'owner'<>'postgres' OR cols IS DISTINCT FROM item->'columns'
   OR has_table_privilege('anon',relation_oid,'SELECT,INSERT,UPDATE,DELETE,TRUNCATE,REFERENCES,TRIGGER')
   OR has_table_privilege('authenticated',relation_oid,'SELECT,INSERT,UPDATE,DELETE,TRUNCATE,REFERENCES,TRIGGER') THEN
   RAISE EXCEPTION 'CATALOGO_ROOT_RELATION_SCHEMA_OR_PRIVILEGE:%',item->>'name';END IF;
  relation_manifest:=relation_manifest||jsonb_build_array(h);
 END LOOP;
 SELECT count(*) INTO actual_count FROM pg_class c JOIN pg_namespace n ON n.oid=c.relnamespace
  WHERE c.relkind IN('r','p')AND(n.nspname='combat_v2_genjutsu_internal' OR(n.nspname='combat_panel_private' AND c.relname LIKE 'cure\_%' ESCAPE '\'));
 IF actual_count<>jsonb_array_length(relation_manifest)
 OR actual_count<>(SELECT count(DISTINCT value->>'name')FROM jsonb_array_elements(relation_manifest))THEN RAISE EXCEPTION 'CATALOGO_ROOT_RELATION_COVERAGE';END IF;
 FOR item IN SELECT value FROM jsonb_array_elements(params->'triggers') ORDER BY value->>'table',value->>'name' LOOP
  SELECT jsonb_build_object('table',item->'table','name',t.tgname,'function',t.tgfoid::regprocedure::text,
   'type',t.tgtype,'enabled',t.tgenabled::text,'definition',pg_get_triggerdef(t.oid),'arguments_sha256',encode(extensions.digest(t.tgargs,'sha256'),'hex'))
   INTO h FROM pg_trigger t JOIN pg_proc tf ON tf.oid=t.tgfoid JOIN pg_namespace tn ON tn.oid=tf.pronamespace
   WHERE t.tgrelid=to_regclass(item->>'table')AND t.tgname=item->>'name'AND NOT t.tgisinternal
    AND tn.nspname='combat_panel_private'AND tf.proname LIKE 'cure\_%' ESCAPE '\';
  IF h IS NULL OR h->>'function' IS DISTINCT FROM item->>'function' OR h->'type' IS DISTINCT FROM item->'type'
   OR h->>'enabled' IS DISTINCT FROM 'O' THEN RAISE EXCEPTION 'CATALOGO_ROOT_TRIGGER_PIN:%',item->>'name';END IF;
  trigger_manifest:=trigger_manifest||jsonb_build_array(h);
 END LOOP;
 IF (SELECT count(DISTINCT jsonb_build_array(value->'table',value->'name'))FROM jsonb_array_elements(trigger_manifest))<>10
 OR (SELECT count(*)FROM pg_trigger t JOIN pg_proc f ON f.oid=t.tgfoid JOIN pg_namespace n ON n.oid=f.pronamespace
  WHERE NOT t.tgisinternal AND n.nspname='combat_panel_private' AND f.proname LIKE 'cure\_%' ESCAPE '\')<>10 THEN
  RAISE EXCEPTION 'CATALOGO_ROOT_TRIGGER_COVERAGE';END IF;
 relations_sha:=public.combat_v2_sha256(jsonb_build_object('relations',relation_manifest,'triggers',trigger_manifest));

 IF shared_sha IS DISTINCT FROM amendment->>'shared_manifest_sha256'
 OR private_sha IS DISTINCT FROM amendment->>'private_functions_manifest_sha256'
 OR relations_sha IS DISTINCT FROM root#>>'{db_core,catalogo_completo,relations_manifest_sha256}'
 OR shared_sha IS DISTINCT FROM binding->>'shared_manifest_sha256'
 OR private_sha IS DISTINCT FROM binding->>'private_functions_manifest_sha256'
 OR relations_sha IS DISTINCT FROM binding->>'relations_manifest_sha256'
 THEN RAISE EXCEPTION 'catalogo_eligibility_integrated_manifest_drift';END IF;

 -- Three owning substitution ports, exact bodies/ABI; authority stays native.
 FOR item IN SELECT value FROM jsonb_array_elements(params->'native_functions')ORDER BY value->>'signature'LOOP
  SELECT jsonb_build_object('signature',p.oid::regprocedure::text,'source_md5',md5(p.prosrc),'ddl_md5',md5(pg_get_functiondef(p.oid)),
   'owner',pg_get_userbyid(p.proowner),'acl',p.proacl::text,'config',p.proconfig,'secdef',p.prosecdef,'volatility',p.provolatile::text,
   'language',l.lanname,'strict',p.proisstrict,'parallel',p.proparallel::text,'returns',pg_get_function_result(p.oid),
   'arg_names',p.proargnames,'arg_modes',p.proargmodes,'arg_types',p.proargtypes::text)INTO h
   FROM pg_proc p JOIN pg_language l ON l.oid=p.prolang WHERE p.oid=to_regprocedure(item->>'signature')AND p.prokind='f';
  IF h IS DISTINCT FROM item THEN RAISE EXCEPTION 'cure_reaction_native_body_or_abi_drift:%',item->>'signature';END IF;
  native_manifest:=native_manifest||jsonb_build_array(h);
 END LOOP;
 IF jsonb_array_length(native_manifest)<>3 OR public.combat_v2_sha256(native_manifest)IS DISTINCT FROM amendment->>'native_functions_manifest_sha256'
 THEN RAISE EXCEPTION 'cure_reaction_native_manifest_drift';END IF;
 -- Own helper metadata is bound externally by the reviewed Root, never a literal self hash.
 SELECT jsonb_agg(jsonb_build_object('signature',p.oid::regprocedure::text,'source_md5',md5(p.prosrc),'ddl_md5',md5(pg_get_functiondef(p.oid)),
  'owner',pg_get_userbyid(p.proowner),'secdef',p.prosecdef,'config',p.proconfig,'acl',p.proacl::text,'volatility',p.provolatile::text)
  ORDER BY p.oid::regprocedure::text)INTO changed_manifest FROM pg_proc p WHERE p.oid IN(
  'combat_panel_private.round_options_authoritative(uuid,uuid)'::regprocedure,
  'public.combat_v2_substitution_options_v1(uuid)'::regprocedure,'public.combat_v2_substitution_round_offers_v1(uuid,uuid)'::regprocedure,
  'public.combat_v2_substitution_select_v1(uuid,uuid)'::regprocedure,'clan_innata_private.catalogo_eligibility_release_v1()'::regprocedure,'combat_panel_private.publish_master_declaration(uuid,text)'::regprocedure);
 IF jsonb_array_length(changed_manifest)<>6 OR public.combat_v2_sha256(changed_manifest)IS DISTINCT FROM amendment->>'functions_manifest_sha256'
 THEN RAISE EXCEPTION 'cure_reaction_changed_manifest_drift';END IF;

 IF jsonb_typeof(root#>'{db_core,catalogo_families}')IS DISTINCT FROM 'array'
 OR jsonb_array_length(root#>'{db_core,catalogo_families}')<>5
 OR root#>'{db_core,catalogo_families,0}'IS DISTINCT FROM '1'::jsonb
 OR root#>>'{db_core,catalogo_families,1}'IS DISTINCT FROM amendment->>'source_bundle_sha256'
 OR root#>'{db_core,catalogo_families,2}'IS DISTINCT FROM (SELECT jsonb_build_array(public.combat_v2_sha256((SELECT coalesce(jsonb_agg(jsonb_build_object('signature',n.nspname||'.'||p.proname||'('||oidvectortypes(p.proargtypes)||')','source_md5',md5(p.prosrc),'ddl_md5',md5(pg_get_functiondef(p.oid)),'owner',pg_get_userbyid(p.proowner),'acl',p.proacl::text,'config',p.proconfig,'secdef',p.prosecdef,'strict',p.proisstrict,'parallel',p.proparallel::text,'volatility',p.provolatile::text,'returns',pg_get_function_result(p.oid),'language',l.lanname)ORDER BY n.nspname,p.proname,oidvectortypes(p.proargtypes)),'[]'::jsonb)FROM pg_proc p JOIN pg_namespace n ON n.oid=p.pronamespace JOIN pg_language l ON l.oid=p.prolang WHERE p.oid IN(to_regprocedure('combat_v2_staff_nb_internal.origin_guard()'),to_regprocedure('combat_v2_staff_nb_internal.preparation_allowed(uuid)'),to_regprocedure('combat_v2_staff_nb_internal.choice(uuid)'),to_regprocedure('combat_v2_staff_nb_internal.roster_offers(uuid,bigint,uuid)'),to_regprocedure('combat_v2_staff_nb_internal.native_construct(uuid,uuid[],jsonb,jsonb,uuid,uuid)'),to_regprocedure('combat_v2_staff_nb_internal.mechanics_ready(uuid)'),to_regprocedure('combat_v2_staff_nb_internal.setup_protected(uuid,uuid)'),to_regprocedure('combat_v2_staff_nb_internal.commit_roster(jsonb)'),to_regprocedure('combat_v2_staff_nb_internal.roster_receipt(uuid)'),to_regprocedure('combat_v2_staff_nb_internal.pg_scope(uuid)'),to_regprocedure('combat_v2_staff_nb_internal.kai_frozen_authority(uuid)'),to_regprocedure('combat_v2_staff_nb_internal.kai_authority(uuid)'),to_regprocedure('combat_v2_staff_nb_internal.kai_contact(uuid,uuid)'),to_regprocedure('clan_aburame_private.verme_manifest_v1()'),to_regprocedure('clan_aburame_private.verme_release_v1()'),to_regprocedure('clan_aburame_private.verme_staff_scope_v1(uuid)'),to_regprocedure('clan_aburame_private.verme_scope_v1(uuid)'),to_regprocedure('clan_aburame_private.verme_event_v1(text,uuid,uuid,uuid,uuid,uuid,text,jsonb)'),to_regprocedure('clan_aburame_private.verme_staff_prepare_v1(uuid,uuid)'),to_regprocedure('clan_aburame_private.verme_meta_v1(uuid,boolean)'),to_regprocedure('clan_aburame_private.verme_bind_v1(uuid)'),to_regprocedure('clan_aburame_private.verme_frozen_v1(uuid)'),to_regprocedure('clan_aburame_private.verme_finish_v1(uuid,uuid,boolean,integer)'),to_regprocedure('clan_aburame_private.verme_tick_v1(uuid,uuid,uuid,text)'),to_regprocedure('clan_aburame_private.verme_end_context_v1()'),to_regprocedure('clan_aburame_private.verme_report_v1(uuid,uuid)'),to_regprocedure('clan_aburame_private.verme_reserve_round_v1(uuid)'),to_regprocedure('clan_aburame_private.verme_settle_round_v1(uuid)'),to_regprocedure('clan_aburame_private.verme_narrative_v1(uuid,uuid)'),to_regprocedure('clan_akimichi_private.common_staff_scope_v1(uuid)'),to_regprocedure('clan_akimichi_private.common_scope_v1(uuid,uuid)'),to_regprocedure('clan_akimichi_private.common_prepare_staff_v1(uuid,uuid,uuid)'),to_regprocedure('clan_akimichi_private.common_modifiers_v1(text,integer,integer,integer)'),to_regprocedure('clan_akimichi_private.common_set_form_v1(uuid,uuid,text)'),to_regprocedure('clan_akimichi_private.common_defer_upkeep_v1(uuid,uuid)'),to_regprocedure('clan_akimichi_private.common_flush_upkeep_v1(uuid)'),to_regprocedure('clan_akimichi_private.cellular_meta_v1(uuid)'),to_regprocedure('clan_akimichi_private.cellular_attack_eligible_v1(uuid,uuid)'),to_regprocedure('clan_akimichi_private.cellular_bind_v1(uuid)'),to_regprocedure('clan_akimichi_private.cellular_source_valid_v1(uuid)'),to_regprocedure('clan_akimichi_private.cellular_pay_v1(uuid)'),to_regprocedure('clan_akimichi_private.cellular_snapshot_v1(uuid,jsonb)'),to_regprocedure('clan_akimichi_private.cellular_mark_v1(uuid,jsonb)'),to_regprocedure('clan_akimichi_private.cellular_calculate_v1(uuid,jsonb,integer,integer)'),to_regprocedure('clan_akimichi_private.common_calorie_balance_v1(uuid,uuid,uuid,uuid)'),to_regprocedure('clan_akimichi_private.common_admit_calories_v1(uuid)'),to_regprocedure('clan_akimichi_private.common_preflight_calories_v1(uuid)'),to_regprocedure('clan_akimichi_private.super_direct_visible_v1(uuid,uuid)'),to_regprocedure('clan_akimichi_private.common_attack_power_freeze_v1(uuid)'),to_regprocedure('clan_akimichi_private.common_panel_offers_v1(uuid,bigint,jsonb)'),to_regprocedure('clan_akimichi_private.common_panel_commit_v1(jsonb)'),to_regprocedure('clan_akimichi_private.common_result_label_v1(jsonb)'),to_regprocedure('clan_akimichi_private.common_source_root_v1()'),to_regprocedure('clan_sabaku_private.armor_absorb_packet_v1(uuid,uuid,uuid,uuid,integer)'),to_regprocedure('combat_panel_private.nara_adv_pool_v1(uuid)'),to_regprocedure('combat_panel_private.nara_adv_protected_v1(uuid)'),to_regprocedure('combat_panel_private.nara_adv_scope_v1(uuid)'),to_regprocedure('combat_panel_private.nara_adv_prepare_v1(uuid,uuid)'),to_regprocedure('combat_panel_private.nara_strangle_meta_v1(uuid)'),to_regprocedure('combat_panel_private.nara_strangle_action_meta_v1(uuid,uuid,jsonb)'),to_regprocedure('combat_panel_private.nara_strangle_bind_v1(uuid)'),to_regprocedure('combat_panel_private.nara_strangle_parent_valid_v1(uuid)'),to_regprocedure('combat_panel_private.nara_strangle_lifecycle_v1(uuid)'),to_regprocedure('combat_panel_private.nara_strangle_packet_v1(uuid,uuid,uuid,text)'),to_regprocedure('combat_panel_private.nara_strangle_resolve_v1(uuid)'),to_regprocedure('combat_panel_private.nara_strangle_turn_v1(uuid,uuid,uuid,text)'),to_regprocedure('combat_panel_private.nara_strangle_facts_revision_v1(jsonb)'),to_regprocedure('combat_panel_private.nara_strangle_facts_v1(uuid,uuid)'),to_regprocedure('combat_panel_private.nara_adv_history_guard_v1()'),to_regprocedure('combat_panel_private.nara_strangle_end_event_v1()'),to_regprocedure('combat_panel_private.nara_strangle_terminal_report_v1(uuid)'),to_regprocedure('combat_panel_private.nara_strangle_lifecycle_context_v1(uuid)'),to_regprocedure('combat_panel_private.nara_adv_offers_v1(uuid,bigint,jsonb)'),to_regprocedure('combat_panel_private.nara_adv_commit_v1(jsonb)'),to_regprocedure('combat_panel_private.nara_strangle_lifecycle_trigger_v1()')))),public.combat_v2_sha256((SELECT coalesce(jsonb_agg(jsonb_build_object('signature',n.nspname||'.'||p.proname||'('||oidvectortypes(p.proargtypes)||')','source_md5',md5(p.prosrc),'ddl_md5',md5(pg_get_functiondef(p.oid)),'owner',pg_get_userbyid(p.proowner),'acl',p.proacl::text,'config',p.proconfig,'secdef',p.prosecdef,'strict',p.proisstrict,'parallel',p.proparallel::text,'volatility',p.provolatile::text,'returns',pg_get_function_result(p.oid),'language',l.lanname)ORDER BY n.nspname,p.proname,oidvectortypes(p.proargtypes)),'[]'::jsonb)FROM pg_proc p JOIN pg_namespace n ON n.oid=p.pronamespace JOIN pg_language l ON l.oid=p.prolang WHERE p.oid IN(to_regprocedure('clan_aburame_private.actor_ability(uuid,text,uuid,boolean,jsonb)'),to_regprocedure('clan_aburame_private.attack_power_source(uuid,uuid)'),to_regprocedure('clan_aburame_private.commit_control(jsonb,jsonb,combat_consumer_private.activities,combat_consumer_private.offers,uuid)'),to_regprocedure('clan_aburame_private.commit_master_stop(jsonb)'),to_regprocedure('clan_aburame_private.consumer_options(jsonb)'),to_regprocedure('clan_aburame_private.master_offers(uuid,bigint,jsonb)'),to_regprocedure('clan_akimichi_private.apply_calorie_event(uuid,uuid,boolean,uuid,text,integer,integer,uuid,timestamp with time zone)'),to_regprocedure('clan_akimichi_private.begin_personal_turn(uuid,uuid)'),to_regprocedure('clan_akimichi_private.bind_partial(uuid)'),to_regprocedure('clan_akimichi_private.end_form(uuid,uuid,text)'),to_regprocedure('clan_akimichi_private.form_change_offer(uuid)'),to_regprocedure('clan_akimichi_private.form_impact(uuid,uuid,uuid,text,text,text,jsonb)'),to_regprocedure('clan_akimichi_private.movement_maximum(uuid,numeric)'),to_regprocedure('clan_akimichi_private.partial_meta(uuid,jsonb)'),to_regprocedure('clan_akimichi_private.set_form(uuid,uuid,boolean)'),to_regprocedure('clan_sabaku_private.armor_absorb(uuid,integer)'),to_regprocedure('clan_sabaku_private.armor_narrative_round(uuid)'),to_regprocedure('clan_sabaku_private.armor_round_facts(uuid)'),to_regprocedure('combat_consumer_private.after_publish(uuid,uuid)'),to_regprocedure('combat_consumer_private.commit_exchange(jsonb,jsonb)'),to_regprocedure('combat_consumer_private.narrative_context(uuid)'),to_regprocedure('combat_consumer_private.narrative_declaration_supported(uuid)'),to_regprocedure('combat_consumer_private.validate_narrative_result(jsonb)'),to_regprocedure('combat_effects_private.lifecycle_actor_end(uuid)'),to_regprocedure('combat_effects_private.lifecycle_open(uuid,uuid)'),to_regprocedure('combat_effects_private.lifecycle_session_end(uuid)'),to_regprocedure('combat_effects_private.personal_turn_end(uuid,uuid,uuid,text)'),to_regprocedure('combat_panel_private.catalog_result_label_v1(jsonb)'),to_regprocedure('combat_panel_private.consumer_commit_authoritative(jsonb)'),to_regprocedure('combat_panel_private.master_admin_offers(uuid,bigint,jsonb)'),to_regprocedure('combat_panel_private.master_options(uuid,uuid,bigint)'),to_regprocedure('combat_panel_private.nara_shadow_level_v1(uuid)'),to_regprocedure('combat_panel_private.narrative_declaration_facts(uuid)'),to_regprocedure('combat_panel_private.narrative_ordinary_context(uuid)'),to_regprocedure('combat_panel_private.ordinary_options(uuid,uuid,bigint)'),to_regprocedure('combat_spatial.movement_commit(uuid,uuid,uuid)'),to_regprocedure('combat_v2_genjutsu_internal.ally_contact(uuid,uuid)'),to_regprocedure('combat_v2_genjutsu_internal.master_options(uuid,bigint)'),to_regprocedure('combat_v2_genjutsu_internal.release_intents(uuid)'),to_regprocedure('combat_v2_genjutsu_internal.release_meta(uuid,uuid,uuid,jsonb)'),to_regprocedure('combat_v2_genjutsu_internal.resolve_release(uuid)'),to_regprocedure('combat_v2_genjutsu_internal.scope(uuid)'),to_regprocedure('combat_v2_multitarget_internal.resolve_parent(uuid,uuid,uuid,boolean)'),to_regprocedure('mission_factory_owner.quest_combat_offer_source_guard_v1()'),to_regprocedure('public._combat_calcola(text,jsonb,jsonb,text,text,integer,text,integer,integer,integer,integer,boolean)'),to_regprocedure('public.combat_consumer_narrative_claim_v1(uuid,text,uuid)'),to_regprocedure('public.combat_consumer_narrative_complete_v1(uuid,jsonb,uuid)'),to_regprocedure('public.combat_panel_commit_v1(jsonb)'),to_regprocedure('public.combat_v2_action_declare(uuid,uuid,jsonb,text,uuid)'),to_regprocedure('public.combat_v2_actor_ability(uuid,text,uuid,boolean)'),to_regprocedure('public.combat_v2_defense_declare(uuid,uuid,uuid,jsonb,text,uuid)'),to_regprocedure('public.combat_v2_round_resolve(uuid,uuid)'),to_regprocedure('public.master_v2_encounter_open_ninja_book_v1_human_ai_core(uuid,uuid[],jsonb,jsonb,uuid)'),to_regprocedure('combat_panel_private.publish_master_declaration(uuid,text)'),to_regprocedure('clan_innata_private.eligibility_release_assert()'),to_regprocedure('combat_panel_private.cure_neutral_preset_v1(uuid,uuid,uuid,jsonb)'),to_regprocedure('combat_panel_private.master_actor_offers(uuid,bigint,jsonb,jsonb)')))),public.combat_v2_sha256((SELECT jsonb_build_object('tables',(SELECT jsonb_agg(jsonb_build_object('schema',n.nspname,'name',c.relname,'owner',pg_get_userbyid(c.relowner),'acl',c.relacl::text,'rls',c.relrowsecurity,'force_rls',c.relforcerowsecurity,'columns',(SELECT jsonb_agg(jsonb_build_object('name',a.attname,'type',format_type(a.atttypid,a.atttypmod),'notnull',a.attnotnull,'default',pg_get_expr(d.adbin,d.adrelid),'identity',a.attidentity,'generated',a.attgenerated)ORDER BY a.attnum)FROM pg_attribute a LEFT JOIN pg_attrdef d ON d.adrelid=a.attrelid AND d.adnum=a.attnum WHERE a.attrelid=c.oid AND a.attnum>0 AND NOT a.attisdropped),'constraints',(SELECT coalesce(jsonb_agg(jsonb_build_object('name',q.conname,'definition',pg_get_constraintdef(q.oid),'validated',q.convalidated,'deferrable',q.condeferrable,'deferred',q.condeferred)ORDER BY q.conname),'[]'::jsonb)FROM pg_constraint q WHERE q.conrelid=c.oid),'indexes',(SELECT coalesce(jsonb_agg(jsonb_build_object('name',ci.relname,'definition',pg_get_indexdef(i.indexrelid),'valid',i.indisvalid,'ready',i.indisready,'live',i.indislive)ORDER BY ci.relname),'[]'::jsonb)FROM pg_index i JOIN pg_class ci ON ci.oid=i.indexrelid WHERE i.indrelid=c.oid),'triggers',(SELECT coalesce(jsonb_agg(pg_get_triggerdef(t.oid)ORDER BY t.tgname),'[]'::jsonb)FROM pg_trigger t WHERE t.tgrelid=c.oid AND NOT t.tgisinternal),'policies',(SELECT coalesce(jsonb_agg(jsonb_build_object('name',p.polname,'cmd',p.polcmd,'roles',p.polroles,'using',pg_get_expr(p.polqual,p.polrelid),'check',pg_get_expr(p.polwithcheck,p.polrelid))ORDER BY p.polname),'[]'::jsonb)FROM pg_policy p WHERE p.polrelid=c.oid))ORDER BY n.nspname,c.relname)FROM pg_class c JOIN pg_namespace n ON n.oid=c.relnamespace WHERE c.oid IN(to_regclass('combat_v2_staff_nb_internal.gate'),to_regclass('combat_v2_staff_nb_internal.roster_sources'),to_regclass('combat_v2_staff_nb_internal.admissions'),to_regclass('clan_aburame_private.verme_gate_v1'),to_regclass('clan_aburame_private.verme_staff_profiles_v1'),to_regclass('clan_aburame_private.verme_sources_v1'),to_regclass('clan_aburame_private.verme_poison_v1'),to_regclass('clan_aburame_private.verme_events_v1'),to_regclass('clan_akimichi_private.common_gate_v1'),to_regclass('clan_akimichi_private.common_staff_profiles_v1'),to_regclass('clan_akimichi_private.common_form_commands_v1'),to_regclass('clan_akimichi_private.common_attack_powers_v1'),to_regclass('clan_akimichi_private.common_pending_upkeep_v1'),to_regclass('clan_akimichi_private.cellular_sources_v1'),to_regclass('combat_panel_private.nara_adv_gate_v1'),to_regclass('combat_panel_private.nara_adv_staff_v1'),to_regclass('combat_panel_private.nara_strangle_sources_v1'),to_regclass('combat_panel_private.nara_strangle_events_v1'),to_regclass('public.master_v2_nb_actor_offers_v1'),to_regclass('clan_akimichi_private.forms'))),'catalog',(SELECT jsonb_agg(jsonb_build_object('id',t.id,'sha256',public.combat_v2_sha256(to_jsonb(t)))ORDER BY t.id)FROM public.clan_techniques t WHERE id IN('0a15282f-d6b5-4ee3-ad52-7fac2525444d','f5f26cb5-9b6f-44b3-94bc-c329a0a88b93','687b058a-807d-4cf7-8bcf-21147931b0f6')),'NBtuples',(SELECT jsonb_build_object('mechanical',(SELECT jsonb_agg(jsonb_build_object('id',v.id,'template_id',v.template_id,'content_sha256',v.content_sha256)ORDER BY v.id)FROM public.nb_mechanical_versions v WHERE v.id IN('31da0000-0000-4000-8000-000000000111','31da0000-0000-4000-8000-000000000112')),'narrative',(SELECT jsonb_agg(jsonb_build_object('id',v.id,'template_id',v.template_id,'content_sha256',v.content_sha256)ORDER BY v.id)FROM public.nb_template_versions v WHERE v.id IN('31da0000-0000-4000-8000-000000000211','31da0000-0000-4000-8000-000000000212')))),'new_triggers',(SELECT jsonb_agg(jsonb_build_object('table',e->>'table','name',t.tgname,'function',t.tgfoid::regprocedure::text,'enabled',t.tgenabled::text,'type',t.tgtype,'definition',pg_get_triggerdef(t.oid),'args_sha256',encode(extensions.digest(t.tgargs,'sha256'),'hex'))ORDER BY e->>'table',e->>'name')FROM jsonb_array_elements($joint_triggers$[{"table":"combat_v2_staff_nb_internal.roster_sources","name":"staff_nb_origin_immutable"},{"table":"public.combat_v2_sessions","name":"aburame_verme_end_session_v1"},{"table":"public.combat_v2_actors","name":"aburame_verme_end_actor_v1"},{"table":"combat_panel_private.nara_strangle_sources_v1","name":"nara_strangle_snapshot_guard_v1"},{"table":"combat_panel_private.nara_strangle_events_v1","name":"nara_strangle_events_guard_v1"},{"table":"combat_panel_private.nara_adv_staff_v1","name":"nara_strangle_staff_guard_v1"},{"table":"combat_panel_private.nara_strangle_sources_v1","name":"nara_strangle_ended_event_v1"},{"table":"combat_panel_private.immobilizations","name":"nara_strangle_parent_end_v1"},{"table":"combat_spatial.actor_states","name":"nara_strangle_geometry_end_v1"}]$joint_triggers$::jsonb)e JOIN pg_trigger t ON t.tgrelid=to_regclass(e->>'table')AND t.tgname=e->>'name'AND NOT t.tgisinternal),'NBnamespace',(SELECT jsonb_build_object('owner',pg_get_userbyid(nspowner),'acl',nspacl::text)FROM pg_namespace WHERE nspname='combat_v2_staff_nb_internal'))))))
 OR root#>'{config,catalogo_families}'IS DISTINCT FROM to_jsonb(public.combat_v2_sha256(root#>'{db_core,catalogo_families}'))
 OR root#>>'{db_core,catalogo_families,3}'IS DISTINCT FROM 'cd22449d2aacf38bbf7b919678b58b256c4b89a47b6ccd16a69b6f3a75047bd9'
 OR NOT EXISTS(SELECT 1 FROM jsonb_array_elements(root->'edge_bundles')b CROSS JOIN LATERAL jsonb_array_elements(b->'files')f WHERE b->>'name'='combat_narratore_ai'AND f->>'name'='facts.ts'AND f->>'sha256'='cd22449d2aacf38bbf7b919678b58b256c4b89a47b6ccd16a69b6f3a75047bd9')
 OR coalesce(root#>'{db_core,catalogo_families,4}','null'::jsonb)NOT IN('[1,1,1,1]'::jsonb,'[0,0,0,0]'::jsonb)
 OR jsonb_typeof(root#>'{db_core,catalogo_families,4}')IS DISTINCT FROM 'array'
 OR EXISTS(SELECT 1 FROM combat_v2_staff_nb_internal.gate WHERE public_enabled)
 OR EXISTS(SELECT 1 FROM clan_aburame_private.verme_gate_v1 WHERE public_enabled)
 OR EXISTS(SELECT 1 FROM clan_akimichi_private.common_gate_v1 WHERE public_enabled OR super_public_enabled OR cellular_public_enabled)
 OR EXISTS(SELECT 1 FROM combat_panel_private.nara_adv_gate_v1 WHERE public_enabled)
 THEN RAISE EXCEPTION 'JOINT_CATALOG_MANIFEST_OR_SCOPE_DRIFT';END IF;
 IF EXISTS(SELECT 1 FROM jsonb_array_elements($joint_expected$[{"signature":"combat_v2_staff_nb_internal.origin_guard()","source_md5":"1140049388497d2060a5559fbdcdfd1f","security_definer":true},{"signature":"combat_v2_staff_nb_internal.preparation_allowed(uuid)","source_md5":"48d0ce9a5a617b90a8d8b7484ff846c5","security_definer":true},{"signature":"combat_v2_staff_nb_internal.choice(uuid)","source_md5":"e0a9c9957b9f831a44e956fc1faa8000","security_definer":true},{"signature":"combat_v2_staff_nb_internal.roster_offers(uuid,bigint,uuid)","source_md5":"2d4f9396d3f6f3acb29d4b57dee65347","security_definer":true},{"signature":"combat_v2_staff_nb_internal.native_construct(uuid,uuid[],jsonb,jsonb,uuid,uuid)","source_md5":"9f45926f70f911af516c1a3f6899ed81","security_definer":true},{"signature":"combat_v2_staff_nb_internal.mechanics_ready(uuid)","source_md5":"d0be038e05e3baea60270c52050db778","security_definer":true},{"signature":"combat_v2_staff_nb_internal.setup_protected(uuid,uuid)","source_md5":"7543230450e0d5b9c985823fe0740b51","security_definer":true},{"signature":"combat_v2_staff_nb_internal.commit_roster(jsonb)","source_md5":"ce1f9682474b4d550c9584206093b872","security_definer":true},{"signature":"combat_v2_staff_nb_internal.roster_receipt(uuid)","source_md5":"4bf43be7f3ed838c3a2fdc64a5e2b85b","security_definer":true},{"signature":"combat_v2_staff_nb_internal.pg_scope(uuid)","source_md5":"3df42b0dd768a6291bd9096a58bf5d08","security_definer":true},{"signature":"combat_v2_staff_nb_internal.kai_frozen_authority(uuid)","source_md5":"95dd90e5eb49840c142d52ffe452a9a8","security_definer":true},{"signature":"combat_v2_staff_nb_internal.kai_authority(uuid)","source_md5":"ccff2cd6a0b988da8f62fcd63a1056e9","security_definer":true},{"signature":"combat_v2_staff_nb_internal.kai_contact(uuid,uuid)","source_md5":"ef2313c0fd4eb2ad78579b8ee0981a6e","security_definer":true},{"signature":"clan_aburame_private.verme_manifest_v1()","source_md5":"d959e35164cb3b91dae5af370e202f10","security_definer":true},{"signature":"clan_aburame_private.verme_release_v1()","source_md5":"1df436e50d123cfaf302edec8f72baea","security_definer":true},{"signature":"clan_aburame_private.verme_staff_scope_v1(uuid)","source_md5":"d4a8c0421eb673be663d716e9a4beab4","security_definer":true},{"signature":"clan_aburame_private.verme_scope_v1(uuid)","source_md5":"6e513c685ae41e3f932bf12601ef5949","security_definer":true},{"signature":"clan_aburame_private.verme_event_v1(text,uuid,uuid,uuid,uuid,uuid,text,jsonb)","source_md5":"b4c4a3c168d647e4607e526ee8808c08","security_definer":true},{"signature":"clan_aburame_private.verme_staff_prepare_v1(uuid,uuid)","source_md5":"4288e5eed6eb7b949746d4972bd7c6ff","security_definer":true},{"signature":"clan_aburame_private.verme_meta_v1(uuid,boolean)","source_md5":"03b0d2b2fe63168c4989cc7a733fa3d8","security_definer":true},{"signature":"clan_aburame_private.verme_bind_v1(uuid)","source_md5":"374b96652f29e70732937dee4e9edb7d","security_definer":true},{"signature":"clan_aburame_private.verme_frozen_v1(uuid)","source_md5":"60b6d1187a64c8afe1c7182fab1366ab","security_definer":true},{"signature":"clan_aburame_private.verme_finish_v1(uuid,uuid,boolean,integer)","source_md5":"15522dc52e63348477b2066bd48aae57","security_definer":true},{"signature":"clan_aburame_private.verme_tick_v1(uuid,uuid,uuid,text)","source_md5":"e383a9cb056c4f39f7d22480970149ee","security_definer":true},{"signature":"clan_aburame_private.verme_end_context_v1()","source_md5":"349317d7764d5ca425c7eb588d257ae1","security_definer":true},{"signature":"clan_aburame_private.verme_report_v1(uuid,uuid)","source_md5":"87e095eb88e29760a8678756d28e39ab","security_definer":true},{"signature":"clan_aburame_private.verme_reserve_round_v1(uuid)","source_md5":"85c89cf0d8b8f55e1db50073c17b5f93","security_definer":true},{"signature":"clan_aburame_private.verme_settle_round_v1(uuid)","source_md5":"53a6b0101059a9cfc462e9327e7c395a","security_definer":true},{"signature":"clan_aburame_private.verme_narrative_v1(uuid,uuid)","source_md5":"d31a97fbe8289c33e32546e1381fb9dd","security_definer":true},{"signature":"clan_akimichi_private.common_staff_scope_v1(uuid)","source_md5":"5b99799e661c5192445ed8c3c80e3315","security_definer":true},{"signature":"clan_akimichi_private.common_scope_v1(uuid,uuid)","source_md5":"b96176036ce4a9e56041ba0ea13a8b12","security_definer":true},{"signature":"clan_akimichi_private.common_prepare_staff_v1(uuid,uuid,uuid)","source_md5":"dce7a5ef3b37dbeb5cd48edf0546c254","security_definer":true},{"signature":"clan_akimichi_private.common_modifiers_v1(text,integer,integer,integer)","source_md5":"5bb71bbae1cc67857e73daa0d790a6cd","security_definer":false},{"signature":"clan_akimichi_private.common_set_form_v1(uuid,uuid,text)","source_md5":"446f6580947bc1a6b7be66ad7559ec5c","security_definer":true},{"signature":"clan_akimichi_private.common_defer_upkeep_v1(uuid,uuid)","source_md5":"cfc4c1f9fdad1ce6da9acef0e9adb23d","security_definer":true},{"signature":"clan_akimichi_private.common_flush_upkeep_v1(uuid)","source_md5":"8fe8dda8a8aafb08e8aa4b5f9bc919a2","security_definer":true},{"signature":"clan_akimichi_private.cellular_meta_v1(uuid)","source_md5":"c7b3f3fce412a1ac01ccfd188e94fe7a","security_definer":true},{"signature":"clan_akimichi_private.cellular_attack_eligible_v1(uuid,uuid)","source_md5":"1b365e150fb330c54c3094c07bb8874a","security_definer":true},{"signature":"clan_akimichi_private.cellular_bind_v1(uuid)","source_md5":"621f9037c8b7c1d575b4d9635085d706","security_definer":true},{"signature":"clan_akimichi_private.cellular_source_valid_v1(uuid)","source_md5":"ad9eac644c136fcde991a93633902b0d","security_definer":true},{"signature":"clan_akimichi_private.cellular_pay_v1(uuid)","source_md5":"843a172c962fe592f00172d8cfed7aef","security_definer":true},{"signature":"clan_akimichi_private.cellular_snapshot_v1(uuid,jsonb)","source_md5":"953342a7d013006a4cf812682285b6b0","security_definer":true},{"signature":"clan_akimichi_private.cellular_mark_v1(uuid,jsonb)","source_md5":"0fb789ae313a680dd4e83eb0e51444e2","security_definer":true},{"signature":"clan_akimichi_private.cellular_calculate_v1(uuid,jsonb,integer,integer)","source_md5":"0ea4f400225ddeef1c231ce879965c53","security_definer":true},{"signature":"clan_akimichi_private.common_calorie_balance_v1(uuid,uuid,uuid,uuid)","source_md5":"8d61faeead0597de3a87adfd548c16ff","security_definer":true},{"signature":"clan_akimichi_private.common_admit_calories_v1(uuid)","source_md5":"798c20833ceffaa85e36c0ef3bf47561","security_definer":true},{"signature":"clan_akimichi_private.common_preflight_calories_v1(uuid)","source_md5":"1960fb6064b16c1dbf91ef88161e93f6","security_definer":true},{"signature":"clan_akimichi_private.super_direct_visible_v1(uuid,uuid)","source_md5":"8fe89b774ef59f9ac66e27be00861d42","security_definer":true},{"signature":"clan_akimichi_private.common_attack_power_freeze_v1(uuid)","source_md5":"58ee8836c59cc9f28ff9f3ff94299153","security_definer":true},{"signature":"clan_akimichi_private.common_panel_offers_v1(uuid,bigint,jsonb)","source_md5":"289d91af1d8f0e84b4948edc3141edc6","security_definer":true},{"signature":"clan_akimichi_private.common_panel_commit_v1(jsonb)","source_md5":"91e55c736eefba25100199b9c05e9fc5","security_definer":true},{"signature":"clan_akimichi_private.common_result_label_v1(jsonb)","source_md5":"49598647a5f77b06747d266e8ae57f28","security_definer":false},{"signature":"clan_akimichi_private.common_source_root_v1()","source_md5":"219f76417a82622471b6d5689e3cd5fd","security_definer":true},{"signature":"clan_sabaku_private.armor_absorb_packet_v1(uuid,uuid,uuid,uuid,integer)","source_md5":"bce137fc38ae8f4d2333944a0bf081f7","security_definer":true},{"signature":"combat_panel_private.nara_adv_pool_v1(uuid)","source_md5":"e299333ced84428fb1f927ab42066a5b","security_definer":true},{"signature":"combat_panel_private.nara_adv_protected_v1(uuid)","source_md5":"13073c7a30b26f5a913c0149821e79ac","security_definer":true},{"signature":"combat_panel_private.nara_adv_scope_v1(uuid)","source_md5":"879b81f9d619ba3ab9253539c931874d","security_definer":true},{"signature":"combat_panel_private.nara_adv_prepare_v1(uuid,uuid)","source_md5":"bd29ec1a52a65e7c7efed66a41fc2125","security_definer":true},{"signature":"combat_panel_private.nara_strangle_meta_v1(uuid)","source_md5":"fe6d88539668bd145ea61525f35e2afa","security_definer":true},{"signature":"combat_panel_private.nara_strangle_action_meta_v1(uuid,uuid,jsonb)","source_md5":"15336a6189c6ede2f2240a03d9b10575","security_definer":true},{"signature":"combat_panel_private.nara_strangle_bind_v1(uuid)","source_md5":"5599670a3de573542f1fc5033d03db99","security_definer":true},{"signature":"combat_panel_private.nara_strangle_parent_valid_v1(uuid)","source_md5":"c73c8de463dbdee906910324c0302e94","security_definer":true},{"signature":"combat_panel_private.nara_strangle_lifecycle_v1(uuid)","source_md5":"99263809c05247500fad36e74b6c0643","security_definer":true},{"signature":"combat_panel_private.nara_strangle_packet_v1(uuid,uuid,uuid,text)","source_md5":"8c36b78f9f7c70bcbafec66edd29da80","security_definer":true},{"signature":"combat_panel_private.nara_strangle_resolve_v1(uuid)","source_md5":"8a966d5cafecd1245c155d69a88b3e9b","security_definer":true},{"signature":"combat_panel_private.nara_strangle_turn_v1(uuid,uuid,uuid,text)","source_md5":"6855e493411aa494c1166d985d965363","security_definer":true},{"signature":"combat_panel_private.nara_strangle_facts_revision_v1(jsonb)","source_md5":"b1949dfaa702714a3b72df2a94265c4d","security_definer":true},{"signature":"combat_panel_private.nara_strangle_facts_v1(uuid,uuid)","source_md5":"537f2221e2a89b5e7f10ef09640d2d2b","security_definer":true},{"signature":"combat_panel_private.nara_adv_history_guard_v1()","source_md5":"69b1e8d5b246aed2234dc1247a5d0e27","security_definer":true},{"signature":"combat_panel_private.nara_strangle_end_event_v1()","source_md5":"1e2ae345ecfa2150a12f607677102ecc","security_definer":true},{"signature":"combat_panel_private.nara_strangle_terminal_report_v1(uuid)","source_md5":"e23e524a71d5a3ef9fb6a89df0d72193","security_definer":true},{"signature":"combat_panel_private.nara_strangle_lifecycle_context_v1(uuid)","source_md5":"b3be34f23b3a6f6fc4d3a6709e1b041d","security_definer":true},{"signature":"combat_panel_private.nara_adv_offers_v1(uuid,bigint,jsonb)","source_md5":"6b25543eea4b107627050aef23f11c0f","security_definer":true},{"signature":"combat_panel_private.nara_adv_commit_v1(jsonb)","source_md5":"b57fd70e77171c807a44e5834acdfb86","security_definer":true},{"signature":"combat_panel_private.nara_strangle_lifecycle_trigger_v1()","source_md5":"15b727456c2551117972133a24862a25","security_definer":true}]$joint_expected$::jsonb)e LEFT JOIN pg_proc p ON p.oid=to_regprocedure(e->>'signature')WHERE p.oid IS NULL OR md5(p.prosrc)IS DISTINCT FROM e->>'source_md5'OR p.proowner<>'postgres'::regrole OR p.prosecdef IS DISTINCT FROM(e->>'security_definer')::boolean OR p.proconfig IS DISTINCT FROM ARRAY['search_path=""']OR has_function_privilege('anon',p.oid,'EXECUTE')OR has_function_privilege('authenticated',p.oid,'EXECUTE')OR has_function_privilege('service_role',p.oid,'EXECUTE'))THEN RAISE EXCEPTION 'JOINT_CATALOG_PRIVATE_BODY_OR_ACL_DRIFT';END IF;
 IF(SELECT count(*)FROM pg_proc p JOIN pg_namespace n ON n.oid=p.pronamespace WHERE n.nspname='clan_aburame_private'AND p.proname LIKE 'verme\_%'ESCAPE'\')<>16
 OR(SELECT count(*)FROM pg_class c JOIN pg_namespace n ON n.oid=c.relnamespace WHERE n.nspname='clan_aburame_private'AND c.relkind='r'AND c.relname LIKE 'verme\_%'ESCAPE'\')<>5
 OR(SELECT count(*)FROM pg_trigger WHERE NOT tgisinternal AND tgname IN('aburame_verme_end_session_v1','aburame_verme_end_actor_v1'))<>2
 OR(SELECT count(*)FROM pg_proc WHERE pronamespace='combat_v2_staff_nb_internal'::regnamespace AND prokind='f')<>13
 OR(SELECT count(*)FROM pg_class WHERE relnamespace='combat_v2_staff_nb_internal'::regnamespace AND relkind='r')<>3
 OR(SELECT count(*)FROM pg_class WHERE oid IN(to_regclass('combat_v2_staff_nb_internal.gate'),to_regclass('combat_v2_staff_nb_internal.roster_sources'),to_regclass('combat_v2_staff_nb_internal.admissions'),to_regclass('clan_aburame_private.verme_gate_v1'),to_regclass('clan_aburame_private.verme_staff_profiles_v1'),to_regclass('clan_aburame_private.verme_sources_v1'),to_regclass('clan_aburame_private.verme_poison_v1'),to_regclass('clan_aburame_private.verme_events_v1'),to_regclass('clan_akimichi_private.common_gate_v1'),to_regclass('clan_akimichi_private.common_staff_profiles_v1'),to_regclass('clan_akimichi_private.common_form_commands_v1'),to_regclass('clan_akimichi_private.common_attack_powers_v1'),to_regclass('clan_akimichi_private.common_pending_upkeep_v1'),to_regclass('clan_akimichi_private.cellular_sources_v1'),to_regclass('combat_panel_private.nara_adv_gate_v1'),to_regclass('combat_panel_private.nara_adv_staff_v1'),to_regclass('combat_panel_private.nara_strangle_sources_v1'),to_regclass('combat_panel_private.nara_strangle_events_v1'),to_regclass('public.master_v2_nb_actor_offers_v1'),to_regclass('clan_akimichi_private.forms')))<>20
 OR(SELECT count(*)FROM jsonb_array_elements($joint_triggers$[{"table":"combat_v2_staff_nb_internal.roster_sources","name":"staff_nb_origin_immutable"},{"table":"public.combat_v2_sessions","name":"aburame_verme_end_session_v1"},{"table":"public.combat_v2_actors","name":"aburame_verme_end_actor_v1"},{"table":"combat_panel_private.nara_strangle_sources_v1","name":"nara_strangle_snapshot_guard_v1"},{"table":"combat_panel_private.nara_strangle_events_v1","name":"nara_strangle_events_guard_v1"},{"table":"combat_panel_private.nara_adv_staff_v1","name":"nara_strangle_staff_guard_v1"},{"table":"combat_panel_private.nara_strangle_sources_v1","name":"nara_strangle_ended_event_v1"},{"table":"combat_panel_private.immobilizations","name":"nara_strangle_parent_end_v1"},{"table":"combat_spatial.actor_states","name":"nara_strangle_geometry_end_v1"}]$joint_triggers$::jsonb)e JOIN pg_trigger t ON t.tgrelid=to_regclass(e->>'table')AND t.tgname=e->>'name'AND NOT t.tgisinternal AND t.tgenabled='O')<>9
 THEN RAISE EXCEPTION 'JOINT_CATALOG_COMPONENT_COVERAGE';END IF;

 -- Attestazione Velo iniziale solo Staff. I tre registri e la capability non sono grant pubblici.
 IF coalesce(root#>>'{db_core,velo_staff}','') NOT IN ('35d754465f1c19509822e9728ade3e23c3d2aefe63f441aff01908e774dfcef6','a44f53e09a8d361eb634f261acec19f8070ea942c8325c14892d643873fb101b')
  OR root#>'{config,velo_staff}' IS DISTINCT FROM root#>'{db_core,velo_staff}'
  OR (SELECT staff_enabled FROM clan_innata_combat_private.velo_staff_gate_v1 WHERE singleton)
      IS DISTINCT FROM (root#>>'{db_core,velo_staff}' = '35d754465f1c19509822e9728ade3e23c3d2aefe63f441aff01908e774dfcef6')
  OR EXISTS(SELECT 1 FROM jsonb_to_recordset($velo_leaf_functions$[{"signature":"clan_innata_combat_private.velo_action_turn_v1(uuid,uuid)","md5":"c98a0dbdf0b54c4b240bc16d3331c666"},{"signature":"clan_innata_combat_private.velo_control_choice_v1(uuid,uuid)","md5":"40db9b6876cdc5c357644f7c4886e0a3"},{"signature":"clan_innata_combat_private.velo_control_commit_v1(jsonb)","md5":"a41d2d4cc5cb6a8e7aa6b35542ec3337"},{"signature":"clan_innata_combat_private.velo_control_offers_v1(uuid,bigint)","md5":"4619836b461198a4f2feeb3557ca0d78"},{"signature":"clan_innata_combat_private.velo_freeze_declaration_v1(uuid)","md5":"ad92aeda67371814120c53a445b38dfa"},{"signature":"clan_innata_combat_private.velo_frozen_snapshot_v1(jsonb,uuid,uuid)","md5":"4fbfa40058b21ac6bf23bf31284892ad"},{"signature":"clan_innata_combat_private.velo_innata_scope_v1(uuid)","md5":"8f3d134a673d13dc640ebe33aa2e10b6"},{"signature":"clan_innata_combat_private.velo_profile_bound_v1(uuid)","md5":"43f8511dc5e87cb8069953212d5452e0"},{"signature":"clan_innata_combat_private.velo_staff_scope_v1(uuid)","md5":"3bb31269a7662aaf16169f76bccd6348"},{"signature":"clan_innata_combat_private.velo_stat_delta_v1(uuid)","md5":"119f87ef4dc7481a07cce29b3ddca241"}]$velo_leaf_functions$::jsonb) AS e(signature text,md5 text)
    LEFT JOIN pg_proc p ON p.oid=to_regprocedure(e.signature)
    WHERE p.oid IS NULL OR md5(p.prosrc) IS DISTINCT FROM e.md5 OR p.prokind IS DISTINCT FROM 'f'
      OR NOT p.prosecdef OR p.proowner IS DISTINCT FROM 'postgres'::regrole
      OR p.proconfig IS DISTINCT FROM ARRAY['search_path=""']
      OR has_function_privilege('anon',p.oid,'EXECUTE')
      OR has_function_privilege('authenticated',p.oid,'EXECUTE')
      OR has_function_privilege('service_role',p.oid,'EXECUTE'))
  OR (SELECT count(*) FROM pg_class c
      WHERE c.relnamespace='clan_innata_combat_private'::regnamespace AND c.relname IN ('velo_staff_gate_v1','velo_staff_profiles_v1','velo_rapid_turn_receipts_v1','velo_declaration_stats_v1')
        AND c.relkind='r' AND c.relowner='postgres'::regrole AND c.relrowsecurity AND c.relforcerowsecurity
        AND NOT has_table_privilege('anon',c.oid,'SELECT,INSERT,UPDATE,DELETE,TRUNCATE,REFERENCES,TRIGGER')
        AND NOT has_table_privilege('authenticated',c.oid,'SELECT,INSERT,UPDATE,DELETE,TRUNCATE,REFERENCES,TRIGGER')
        AND NOT has_table_privilege('service_role',c.oid,'SELECT,INSERT,UPDATE,DELETE,TRUNCATE,REFERENCES,TRIGGER')) IS DISTINCT FROM 4
  OR EXISTS(SELECT 1 FROM clan_innata_combat_private.combat_state
      WHERE technique_id='c9b261da-c9cd-40bb-8189-7b65ab5a1605'::uuid AND is_test IS DISTINCT FROM true)
 THEN RAISE EXCEPTION 'VELO_STAFF_ROOT_CAPABILITY_DRIFT'; END IF;

 IF root#>>'{db_core,sfera_staff}' NOT IN ('dad3e133506bbce74401b53cec128e8aa58e6f14155f6601749fe5184b1dc1e9','8caf9ffc6696faaa710cabbc3f8f199b5f4c039f1446fe9e349282bc5d0713be')
  OR root#>'{db_core,sfera_staff}' IS NULL
  OR root#>'{config,sfera_staff}' IS DISTINCT FROM root#>'{db_core,sfera_staff}'
  OR (SELECT enabled FROM clan_aburame_private.sfera_staff_gate_v1 WHERE singleton)
       IS DISTINCT FROM (root#>>'{db_core,sfera_staff}'='dad3e133506bbce74401b53cec128e8aa58e6f14155f6601749fe5184b1dc1e9')
  OR EXISTS(SELECT 1 FROM jsonb_to_recordset($sfera_expected$[{"sig":"clan_aburame_private.sfera_clear_arena_distance_v1(uuid,uuid,uuid)","src":"1d1b04792be582a169870e020442df77","secdef":true,"vol":"s","lang":"sql"},{"sig":"clan_aburame_private.sfera_crosses_prison_v1(uuid,uuid,uuid)","src":"fc740b7a30426a88fb7bd5d6bfb74119","secdef":true,"vol":"s","lang":"sql"},{"sig":"clan_aburame_private.sfera_defense_power_v1(uuid)","src":"37104a0476806913da988fec817933df","secdef":true,"vol":"s","lang":"plpgsql"},{"sig":"clan_aburame_private.sfera_end_v1(uuid,text)","src":"c1dfa1d61fce21fdcd5ae4487423dff7","secdef":true,"vol":"v","lang":"plpgsql"},{"sig":"clan_aburame_private.sfera_escape_meta_v1(uuid,jsonb)","src":"cede426e3aac765237cc11bdbd223c08","secdef":true,"vol":"s","lang":"plpgsql"},{"sig":"clan_aburame_private.sfera_finish_v1(uuid,uuid,boolean)","src":"cf2dcc5892839faa871fdea87704c1e5","secdef":true,"vol":"v","lang":"plpgsql"},{"sig":"clan_aburame_private.sfera_frozen_v1(uuid)","src":"49e26aecd1e6e8900a45ae08257daf22","secdef":true,"vol":"s","lang":"plpgsql"},{"sig":"clan_aburame_private.sfera_hits_v1(integer,text,boolean,jsonb,jsonb,jsonb)","src":"fdc1ee7ce46344a4fad4d95f9995a2f9","secdef":false,"vol":"i","lang":"sql"},{"sig":"clan_aburame_private.sfera_meta_v1(uuid,boolean)","src":"cef273b4908809d65ee217dfcf250490","secdef":true,"vol":"s","lang":"plpgsql"},{"sig":"clan_aburame_private.sfera_narrative_revision_v1(jsonb)","src":"1a189a0a5d39ac47745553f017bdfa7b","secdef":false,"vol":"i","lang":"plpgsql"},{"sig":"clan_aburame_private.sfera_narrative_v1(uuid,uuid)","src":"b0106668578462f3ca5ab2ee3ee6d23e","secdef":true,"vol":"s","lang":"sql"},{"sig":"clan_aburame_private.sfera_prepare_offer_v1(uuid)","src":"1f4fa63f2d2b40411c66622034730686","secdef":true,"vol":"s","lang":"sql"},{"sig":"clan_aburame_private.sfera_prison_active_v1(uuid,uuid)","src":"708d1f175973c3e2c7d76e74ccda47e1","secdef":true,"vol":"s","lang":"sql"},{"sig":"clan_aburame_private.sfera_report_v1(uuid)","src":"9508b6f8309ada672ba8fc5109fa064a","secdef":true,"vol":"s","lang":"sql"},{"sig":"clan_aburame_private.sfera_reserve_v1(uuid)","src":"37a3e13a9f6ab336d2e6f9b653c9c646","secdef":true,"vol":"v","lang":"plpgsql"},{"sig":"clan_aburame_private.sfera_resolve_escape_v1(uuid)","src":"c02719639f1142f995072ca3c0959659","secdef":true,"vol":"v","lang":"plpgsql"},{"sig":"clan_aburame_private.sfera_settle_round_v1(uuid)","src":"5ad3c0d6c98de683c6adc107ef9e5987","secdef":true,"vol":"v","lang":"plpgsql"},{"sig":"clan_aburame_private.sfera_staff_prepare_v1(uuid,uuid)","src":"2fd4f161bb1d30a025d8453838487c99","secdef":true,"vol":"v","lang":"plpgsql"},{"sig":"clan_aburame_private.sfera_staff_scope_v1(uuid,uuid,uuid)","src":"d3a5a5c986f4dd52d6384389b4e5ce35","secdef":true,"vol":"s","lang":"sql"},{"sig":"clan_aburame_private.sfera_staff_target_v1(uuid,uuid)","src":"df09d5c724779b527af0489175df0aee","secdef":true,"vol":"s","lang":"sql"},{"sig":"clan_aburame_private.sfera_upkeep_turn_v1(uuid,uuid)","src":"2f9dfbd32aae9416441774d7854532ca","secdef":true,"vol":"v","lang":"plpgsql"}]$sfera_expected$::jsonb)
       AS e(sig text,src text,secdef boolean,vol text,lang text)
      LEFT JOIN pg_proc p ON p.oid=to_regprocedure(e.sig) LEFT JOIN pg_language l ON l.oid=p.prolang
      WHERE p.oid IS NULL OR p.prokind<>'f' OR md5(p.prosrc) IS DISTINCT FROM e.src
       OR p.prosecdef IS DISTINCT FROM e.secdef OR p.provolatile::text IS DISTINCT FROM e.vol
       OR l.lanname IS DISTINCT FROM e.lang OR p.proowner IS DISTINCT FROM 'postgres'::regrole
       OR p.proconfig IS DISTINCT FROM ARRAY['search_path=""']
       OR has_function_privilege('anon',p.oid,'EXECUTE')
       OR has_function_privilege('authenticated',p.oid,'EXECUTE')
       OR has_function_privilege('service_role',p.oid,'EXECUTE'))
  OR (SELECT count(*) FROM pg_class c WHERE c.oid IN (to_regclass('clan_aburame_private.sfera_staff_gate_v1'),to_regclass('clan_aburame_private.sfera_sources_v1'),to_regclass('clan_aburame_private.sfera_upkeep_v1'))
     AND c.relkind='r' AND c.relrowsecurity AND c.relforcerowsecurity AND c.relowner='postgres'::regrole
     AND NOT has_table_privilege('anon',c.oid,'SELECT,INSERT,UPDATE,DELETE,TRUNCATE,REFERENCES,TRIGGER')
     AND NOT has_table_privilege('authenticated',c.oid,'SELECT,INSERT,UPDATE,DELETE,TRUNCATE,REFERENCES,TRIGGER')
     AND NOT has_table_privilege('service_role',c.oid,'SELECT,INSERT,UPDATE,DELETE,TRUNCATE,REFERENCES,TRIGGER'))<>3
  OR to_regclass('clan_aburame_private.sfera_active_source_per_actor_v1') IS NULL
  THEN RAISE EXCEPTION 'SFERA_STAFF_CAPABILITY_OR_OBJECT_DRIFT'; END IF;
 RETURN true;
END $function$;

DO $sfera_post$
#variable_conflict error
DECLARE
 
 rr mission_factory_owner.editor_release_readiness%ROWTYPE;
 prior_release mission_public_owner.release_admissions_v1%ROWTYPE;
 prior_qualification mission_public_owner.public_qualification_attestations_v1%ROWTYPE;
 runtime_before jsonb; review jsonb; edge_receipt jsonb;
 generic_ezbr constant text:='9a6889802cfa17c99a556538cccd4ad7ef75274d32adccbc192c23d257aa3e76';
 root_text text; candidate_root jsonb; db_sha text; config_sha text; new_root_sha text; old_root_sha text;

 
 namespace_uuid constant uuid:='9ebf5297-66c5-5a19-b35a-589b626e4a4f';
 old_row_sha text; bindings jsonb; qualification jsonb; content_payload jsonb; content_request uuid;
 content_row mission_public_owner.mission_content_admissions_v1%ROWTYPE; profile_row record;
 params jsonb; affected integer;

BEGIN
 SELECT * INTO STRICT rr FROM mission_factory_owner.editor_release_readiness WHERE singleton FOR UPDATE;
 IF rr.revision_sha256 IS DISTINCT FROM '4aec6254673c4c076d313660659a11a0f0b502d434def8bd7a6e4a5c8776f479'
  OR public.combat_v2_sha256(to_jsonb(rr)) IS DISTINCT FROM 'e882ccc872e5f04774aef7138ffddf2d7eba468351ecb5e859f16dec34bcd235'
 THEN RAISE EXCEPTION 'SFERA_STAGED_ROOT_DRIFT'; END IF;
 review:=current_setting('app.sfera_review')::jsonb;
 root_text:=current_setting('app.sfera_prepared_root');
 
 SELECT * INTO STRICT prior_release FROM mission_public_owner.release_admissions_v1
  WHERE release_sha256=rr.revision_sha256 FOR SHARE;
 SELECT * INTO STRICT prior_qualification FROM mission_public_owner.public_qualification_attestations_v1
  WHERE release_sha256=rr.revision_sha256 FOR SHARE;
 SELECT to_jsonb(x) INTO STRICT runtime_before FROM mission_public_owner.party_launch_runtime_v1 x
  WHERE singleton FOR UPDATE;
 IF prior_release.edge_sha256 IS DISTINCT FROM generic_ezbr
   
  OR public.combat_v2_sha256(prior_qualification.payload->'capabilities') IS DISTINCT FROM '49fe134f561273f28e8071b63c45886341371b67d028f06e6b7d8f8d4108e817'
  OR runtime_before IS DISTINCT FROM jsonb_set('{"singleton":true,"staff_enabled":true,"public_enabled":true,"release_sha256":"4aec6254673c4c076d313660659a11a0f0b502d434def8bd7a6e4a5c8776f479"}'::jsonb,'{release_sha256}',to_jsonb(rr.revision_sha256),false)
  OR (SELECT count(*) FROM mission_public_owner.mission_content_admissions_v1 c
      WHERE c.engine_release_sha256=rr.revision_sha256
       )<>2
  OR (SELECT count(DISTINCT profile_key) FROM mission_public_owner.engine_profile_events_v1
       WHERE engine_release_sha256=rr.revision_sha256)<>1
  
 OR public.combat_v2_sha256(to_jsonb(prior_release)) IS DISTINCT FROM '79362b858c82e8e270b9517e2c9e216e9671e7fcec0be7cf4608803347b2187b'
 OR public.combat_v2_sha256(to_jsonb(prior_qualification)) IS DISTINCT FROM 'bcbf34f55f3e970ca5635a8c2295a79003a5637110fd0a4c792c301f34392601'
 OR (SELECT public.combat_v2_sha256(jsonb_agg(to_jsonb(c) ORDER BY c.mission_id,c.request_key))
        FROM mission_public_owner.mission_content_admissions_v1 c WHERE c.engine_release_sha256=rr.revision_sha256)
       IS DISTINCT FROM 'c958745f0cece7f27a5fac82c3d10e3308e7e8e488e5c0940bb213e040148b38'
 OR (SELECT public.combat_v2_sha256(jsonb_agg(to_jsonb(e) ORDER BY e.profile_key))
        FROM (SELECT DISTINCT ON(z.profile_key) * FROM mission_public_owner.engine_profile_events_v1 z
        WHERE z.engine_release_sha256=rr.revision_sha256 ORDER BY z.profile_key,z.control_version DESC)e)
       IS DISTINCT FROM '78793e8f4ae3d98943729f7e0c1ce831cb087ded23fa41105f2b61ab64e728b4'

 THEN RAISE EXCEPTION 'SFERA_UNRELATED_MISSION_EVIDENCE_DRIFT';END IF;

 
 IF EXISTS(SELECT 1 FROM jsonb_to_recordset($sfera_pins$[{"oid":"103987","sig":"clan_aburame_private.action_meta(uuid,uuid,uuid,jsonb)","ddl_md5":"1e2a53a148df97777a99be26c4cc4e08","abi_sha256":"fc52236d7edeabb6991d0023b61370a556a7d3600b4c840c0c146dda07e26667","ddl_sha256":"31d554d19dfff277367e3bbed24d620ee91daf1ae5b0198c70279aac0b800829","source_md5":"2c07b5aeff995745605cf4118ad5ac99"},{"oid":"103974","sig":"clan_aburame_private.actor_ability(uuid,text,uuid,boolean,jsonb)","ddl_md5":"c65ad678151c7217bb78373e199ffa9a","abi_sha256":"86249c1afe30cb1636e30e43732b859e04584f5b34b36e47b54483eb9cb872de","ddl_sha256":"17caeab9d8e5deda2fe67f12915a27faa28e6b024466e04038715051f7141088","source_md5":"e02b549e7bd2650ac0ecb4700fc63834"},{"oid":"103975","sig":"clan_aburame_private.attack_power_source(uuid,uuid)","ddl_md5":"e2027bb1d3ceb2d205bdc456b423b13d","abi_sha256":"8d4587115ed2951b8bd6832499c596e9ef09f6e9c1a28433c8a6f1c243125964","ddl_sha256":"651f3675289a8b2f7e35d82380947b6509077442c32c0f3e8db5b123dbf3cdff","source_md5":"d52984e3992909123362a02f9182b0f2"},{"oid":"103994","sig":"clan_aburame_private.commit_control(jsonb,jsonb,combat_consumer_private.activities,combat_consumer_private.offers,uuid)","ddl_md5":"36ba5ae3f8b719f67d645fbb7d571c23","abi_sha256":"ebd6d5cfff931425dad92413bfb3729d5ae90d33372b74ef9b31fa6302be2754","ddl_sha256":"464ef24f2849f762691bc8673660a317109b2a7f4886ac92573e69f088cf5c6a","source_md5":"6ea42fd4c8624e9c9990cbbc6232d024"},{"oid":"104001","sig":"clan_aburame_private.commit_master_stop(jsonb)","ddl_md5":"2230ed1fb1c168451f7e352f9dc64846","abi_sha256":"b5a5dde4a29a1aeb6d682e9bf12b50832047b3257fd4fbed01a93a1ac9779b92","ddl_sha256":"6ebd57ac7ac893fb1e9201f6ca9accbd870377c8a80f72911b8de4e1e29adba9","source_md5":"f69f0657a1525a580c1f1b138e45b658"},{"oid":"103990","sig":"clan_aburame_private.consumer_options(jsonb)","ddl_md5":"f9844166777d218fc46626eb965ccdff","abi_sha256":"b5a5dde4a29a1aeb6d682e9bf12b50832047b3257fd4fbed01a93a1ac9779b92","ddl_sha256":"07a3a62c0b3132c30b5eff85d86ca98c17e086495aa025d845790985d1255c8b","source_md5":"9808a140fdfcc7677b2925ccedd411af"},{"oid":"103991","sig":"clan_aburame_private.lifecycle()","ddl_md5":"1e21d9e7f9bf83378973c1a53d97d2ab","abi_sha256":"0afe54d3a0546711200bd7cf27035ce862b85ff043ec5844f6bcee216dea1bed","ddl_sha256":"b2324db10564033ec8dc6ee3a5c391140c06b756b18d9e0d74aecc3c7220ae60","source_md5":"2366a20809381436efc72617f2a77137"},{"oid":"103999","sig":"clan_aburame_private.master_offers(uuid,bigint,jsonb)","ddl_md5":"50ba65d6b9e19e7982d9fc900b715165","abi_sha256":"face4c06af773cfeba8a310ccf0486d4dde2c32572de611195965b14db9d90f5","ddl_sha256":"881894f877479766a217ed053cbce1d5063cbfab29131a58f66d2298b0921179","source_md5":"f5f96332061725285753daf7bc1dec44"},{"oid":"51291","sig":"clan_hyuga_private.rotation_attack_power_freeze(uuid)","ddl_md5":"4f67649ffe23ce8acec0e52e9ae118fe","abi_sha256":"e0cc03f58bdc3b14100c6649fb9feb87873ce5c2a9d2d41307f9b9b283efb66a","ddl_sha256":"2aa9d230a70a972ca534fc339a4575054eda095b44bf6acf9aec6004a36f0c14","source_md5":"8af08c1c76b4f56d24e74587a6d29f42"},{"oid":"684829","sig":"clan_innata_private.catalogo_eligibility_release_v1()","ddl_md5":"416c4a3c64364496eaee9b04edb648d3","abi_sha256":"dc03ebb3082eef5a2a7cc7ffe2dccec1506612d08da34f80c50b737425311774","ddl_sha256":"3e66bb46b18d33097a3f9063ccf193607427a8f751be49e0db72a0a471e79083","source_md5":"c2c8daab17e15234ac98c4fa4414f404"},{"oid":"42849","sig":"combat_consumer_private.commit_exchange(jsonb,jsonb)","ddl_md5":"0987c18bc62dcdcce3f2a4490cc2267d","abi_sha256":"acd78e847089e7c7734bd03078805047fee645d4dde38e7f8318ef69a2bd0c2a","ddl_sha256":"fb0c28be39c452e6008f2d612c98eb95bb1f9b7af8c240e081e461abf4dee536","source_md5":"a887a81d59ce8f92dd7147ca3dda59de"},{"sig":"combat_consumer_private.narrative_context(uuid)","oid":"42942","source_md5":"7cb3411ca6ec879112227533b51c48a0","ddl_md5":"50dcb79fba3e3a93a97bf957daef26b9","ddl_sha256":"a9133e23bc9dda5ee4cbf4c3fc2a342ece23b3e1b2c6601d5ba44a41ab07fe4a","abi_sha256":"4069439528f55edc591049d06b40b42dfa3a55dc89cd94dd88a752a11da7caf4"},{"oid":"46723","sig":"combat_consumer_private.narrative_declaration_supported(uuid)","ddl_md5":"733fab475974d4393412069bc62f63c2","abi_sha256":"9cbc335cc097ecc96970c4048a00c34c1551c6979c90d313bb6ccbe73f2b89bf","ddl_sha256":"7d488bafbabcb00230a1383fcf43b02bbf36ecb96f7cabdab595db3a6bf7c596","source_md5":"14b40aca0b52866462e92c86ba214250"},{"oid":"42968","sig":"combat_consumer_private.validate_narrative_result(jsonb)","ddl_md5":"3a865e21ea2104faf7598b0fffd3bfeb","abi_sha256":"18006465d4873283bc66576fb84b423647bfe6e8ce5600b7f85bab4f524319ae","ddl_sha256":"e6f51c94395cf3d9026c24e832f4a8a69f751bab333c0b33bf33e375c41c19df","source_md5":"5445a1ce4c8ef497402c8bfe6061dcf5"},{"oid":"52133","sig":"combat_effects_private.lifecycle_open(uuid,uuid)","ddl_md5":"ccaa8626e04edc3573771689e1401046","abi_sha256":"89e96dfdb9c4e0622381e328d131f16cc5509789bce1c87189738c8192641380","ddl_sha256":"f5ec41373f40cdd60163b45be90ac75a54aaeaccb1d281df39b6b5697f93e688","source_md5":"3f77d8b6698bc4d6c4b3f454c91b104b"},{"oid":"46307","sig":"combat_panel_private.consumer_commit_authoritative(jsonb)","ddl_md5":"5937cf297aeb5238514057410c162036","abi_sha256":"b5a5dde4a29a1aeb6d682e9bf12b50832047b3257fd4fbed01a93a1ac9779b92","ddl_sha256":"0506d6bee75459aa94d99edae5c5493fff8960120e40f34297db5d8d814295f4","source_md5":"9e1906230327a5ac53ef53eb3a77fb85"},{"oid":"45000","sig":"combat_panel_private.movement_block_reason(uuid)","ddl_md5":"02f80418c4b3e6b762aa06dcb743588d","abi_sha256":"d3c9bd2b08e411046c0c416c43fa931a2f7beb6f01927d16b2a4c2a99dda3097","ddl_sha256":"b8182de2aab9c6464d7869e409349d6339d59fff6bdcdb487cd580a55b645744","source_md5":"2522ebb08015c0a1342e63c5f3f40c3a"},{"oid":"46019","sig":"combat_panel_private.narrative_declaration_facts(uuid)","ddl_md5":"3e0bc85ed0d20d893b779a482f0799bb","abi_sha256":"4069439528f55edc591049d06b40b42dfa3a55dc89cd94dd88a752a11da7caf4","ddl_sha256":"b39630b31ccc6c021e1730f6742ec0408daeb1dc7ae98554bdd5f04a66e32b3e","source_md5":"6411b500dfb47e2bd30b3fab1cca9d41"},{"oid":"46020","sig":"combat_panel_private.narrative_ordinary_context(uuid)","ddl_md5":"31b06a04a966582b028e43525d98a411","abi_sha256":"4069439528f55edc591049d06b40b42dfa3a55dc89cd94dd88a752a11da7caf4","ddl_sha256":"62f45f259b2f3d8fb96b3b0ecfbca6bbaebb8d6ae0d613e23a57fb6ca6ee8395","source_md5":"e7c2a225b3f4432ba16fc96221f08653"},{"oid":"39291","sig":"combat_v2_multitarget_internal.resolve_parent(uuid,uuid,uuid,boolean)","ddl_md5":"0f1b28887b56ece0e48b3238b3fb92dd","abi_sha256":"c1b8a8f6c14d497ab73ae0af11817352fcfd85333acf75c375aca5c3c8a2fee3","ddl_sha256":"80a235bf4cf4fa2453f4ee6b8569fa7a060a1d2fb3171d467d5e7e14e7b07c9d","source_md5":"4f89aa40d49971d2a74c04b85cd70f09"},{"oid":"21220","sig":"public._combat_calcola(text,jsonb,jsonb,text,text,integer,text,integer,integer,integer,integer,boolean)","ddl_md5":"7c887ff1aecced55ee5f77aeba71c753","abi_sha256":"048bcb6fabc8b438752b8d7594d75fb8b55419fc15f52559d8ce36f0b36b5786","ddl_sha256":"45a146dff1b68cd3c4d35f3be0fb3928301faaef89d7225c745043fcf3d6370d","source_md5":"ee8d530300ef54e597114c741b85fcbe"},{"oid":"42947","sig":"public.combat_consumer_narrative_claim_v1(uuid,text,uuid)","ddl_md5":"d0a2ae1909d03454dace2f6e3b994ece","abi_sha256":"d865515821bea0cef6b0a4662529d1bf555dd93c1ab135a49380848722d9669e","ddl_sha256":"59997cfe320213d7593d8de77b385daa456d50cb8fc80731f93343385301511c","source_md5":"60fce00fae9119dd6b1c8906ef2ea7e8"},{"oid":"42969","sig":"public.combat_consumer_narrative_complete_v1(uuid,jsonb,uuid)","ddl_md5":"e7dc5d07a611fbfa165f2185fa01f8c3","abi_sha256":"2f0857911ad4603cc525af47e1dba6bda7f615fee23b7e00458c2e3aef5495cc","ddl_sha256":"bfa0217ce989887eea14c033e0a1e553b7bf9612ae9769a30ea6059e7c822a09","source_md5":"1468dab936825b51e0f802f117a9dd0d"},{"oid":"31324","sig":"public.combat_v2_action_declare(uuid,uuid,jsonb,text,uuid)","ddl_md5":"18cf15dcb36e3fe52b799a70882a77cf","abi_sha256":"b6d998780cb011e2dd2633261f88a73d72ccbfdf20aaa7ca950edceb4769816d","ddl_sha256":"97e895893c50d74251d277b1075a5ff4075f272eec4d77308612a66aba3ca170","source_md5":"6c23e94b38f8f252c3e49a1d389e588c"},{"oid":"31331","sig":"public.combat_v2_round_resolve(uuid,uuid)","ddl_md5":"8a9ec59917bb8802f796cc125e9d1e06","abi_sha256":"cd417e11e00af72d6c1b0c5baa4d17feb4c2f4d70f1d8dd613830bf25dc7e29a","ddl_sha256":"4cfb814e09dd654488c57489c91e81d1250d0587f34080f84e900443040d39c1","source_md5":"ea91dd6deeaf06dc059adadfaafd9e95"},{"oid":"41419","sig":"clan_innata_private.eligibility_release_assert()","ddl_md5":"c853342118edc3e2d886aef09661da1b","abi_sha256":"6196b3570f0cf7b8efd83fc1d688978688a292d4d11b0b9d1ff78241e0316d88","ddl_sha256":"d034de670fcf5ad17d3f4663fe209cda5ca3d85e1c8b86f1bff26fb938f002bb","source_md5":"d12a616a859cd2b497004d0f17395437"},{"oid":"701892","sig":"clan_innata_combat_private.velo_staff_scope_v1(uuid)","abi_sha256":"f14070f64af79a8b4bb0a3c3872b8f66ddb289f196413cae527098686a439c43","ddl_sha256":"419382199472a3b3af19a8c04ec0b450b040b7680d8cb864ba03ec5da9a55d67","source_md5":"3bb31269a7662aaf16169f76bccd6348"}]$sfera_pins$::jsonb)
  AS e(sig text,oid text,source_md5 text,ddl_sha256 text,abi_sha256 text)
  LEFT JOIN pg_proc p ON p.oid=to_regprocedure(e.sig) LEFT JOIN pg_language l ON l.oid=p.prolang
  WHERE p.oid::text IS DISTINCT FROM e.oid OR md5(p.prosrc) IS DISTINCT FROM e.source_md5
   OR encode(extensions.digest(pg_get_functiondef(p.oid),'sha256'),'hex') IS DISTINCT FROM e.ddl_sha256
   OR public.combat_v2_sha256(jsonb_build_object(
       'owner',pg_get_userbyid(p.proowner),'acl',p.proacl::text,'config',p.proconfig,'secdef',p.prosecdef,
       'volatile',p.provolatile::text,'strict',p.proisstrict,'parallel',p.proparallel::text,
       'kind',p.prokind::text,'returns',pg_get_function_result(p.oid),'args',p.proargtypes::text,
       'lang',l.lanname)) IS DISTINCT FROM e.abi_sha256)
 THEN RAISE EXCEPTION 'SFERA_AFTER_BODY_OR_ABI_DRIFT'; END IF;

 
 old_root_sha:=rr.revision_sha256;
 old_row_sha:=public.combat_v2_sha256(to_jsonb(rr));
 candidate_root:=root_text::jsonb;
 db_sha:=candidate_root#>>'{db_core,sha256}';
 config_sha:=candidate_root#>>'{config,sha256}';
 IF octet_length(root_text)>524288 OR db_sha IS DISTINCT FROM public.combat_v2_sha256((candidate_root->'db_core')-'sha256')
 OR config_sha IS DISTINCT FROM public.combat_v2_sha256((candidate_root->'config')-'sha256')
 OR NOT (candidate_root#>>'{db_core,sfera_staff}' IS NOT DISTINCT FROM 'dad3e133506bbce74401b53cec128e8aa58e6f14155f6601749fe5184b1dc1e9')
 OR NOT (candidate_root#>>'{config,sfera_staff}' IS NOT DISTINCT FROM 'dad3e133506bbce74401b53cec128e8aa58e6f14155f6601749fe5184b1dc1e9')
 OR public.combat_v2_sha256(candidate_root->'ui') IS DISTINCT FROM 'b62cac808730c14ff1558ac666b3a76c3cc264e4716b858205acada9efadefc9'
 THEN RAISE EXCEPTION 'SFERA_FINAL_ROOT_BINDING_INVALID'; END IF;
 new_root_sha:=encode(extensions.digest(convert_to(root_text,'UTF8'),'sha256'),'hex');
 params:='{"expected_mission_capabilities_sha256":"49fe134f561273f28e8071b63c45886341371b67d028f06e6b7d8f8d4108e817","compatibility":{"ref":"sfera-staff-existing-missions","sha256":"dad3e133506bbce74401b53cec128e8aa58e6f14155f6601749fe5184b1dc1e9"}}'::jsonb;
 bindings:=jsonb_build_object('db_sha256',db_sha,'edge_sha256',generic_ezbr,
   'client_sha256',public.combat_v2_sha256(candidate_root->'ui'),'configuration_sha256',config_sha);
 UPDATE mission_factory_owner.editor_release_readiness
 SET canonical_preimage=root_text,revision_sha256=new_root_sha,observed_revision_sha256=new_root_sha,
   client_build='mission-factory-admin/2:'||new_root_sha,independent_review_ref=review->>'ref',updated_at=clock_timestamp()
 WHERE singleton AND revision_sha256=old_root_sha AND public.combat_v2_sha256(to_jsonb(editor_release_readiness))=old_row_sha;
 GET DIAGNOSTICS affected=ROW_COUNT;
 IF affected<>1 THEN RAISE EXCEPTION 'SFERA_ROOT_CAS';END IF;
 UPDATE clan_aburame_private.sfera_staff_gate_v1 SET enabled=true WHERE singleton AND NOT enabled;
 GET DIAGNOSTICS affected=ROW_COUNT;
 IF affected<>1 OR NOT clan_innata_private.catalogo_eligibility_release_v1()
 THEN RAISE EXCEPTION 'SFERA_AFTER_CAS_E52_COMPARE_FAILED';END IF;
 PERFORM clan_innata_private.runtime_release_assert();
  INSERT INTO mission_public_owner.release_admissions_v1(release_sha256,db_sha256,edge_sha256,client_sha256,configuration_sha256,
  contract_version,independent_review_ref,staff_evidence_ref,qualified_at,public_enabled)
 VALUES(new_root_sha,db_sha,generic_ezbr,bindings->>'client_sha256',config_sha,prior_release.contract_version,
  review->>'ref',prior_release.staff_evidence_ref,prior_release.qualified_at,prior_release.public_enabled);
 FOR profile_row IN SELECT DISTINCT ON(profile_key)* FROM mission_public_owner.engine_profile_events_v1
  WHERE engine_release_sha256=old_root_sha ORDER BY profile_key,control_version DESC LOOP
  IF profile_row.profile_key IS DISTINCT FROM prior_qualification.payload->>'authoring_profile' THEN
   RAISE EXCEPTION 'SFERA_UNQUALIFIED_PROFILE_CARRYFORWARD';END IF;
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
 OR mission_public_owner.engine_qualification_v1(new_root_sha,true)IS NULL THEN RAISE EXCEPTION 'SFERA_MISSION_CARRYFORWARD_INVALID';END IF;
 FOR content_row IN SELECT * FROM mission_public_owner.mission_content_admissions_v1 WHERE engine_release_sha256=old_root_sha ORDER BY mission_id LOOP
  content_request:=extensions.uuid_generate_v5(content_row.request_key,new_root_sha||':catalogo-compatible-adoption');
  content_payload:=content_row.payload||jsonb_build_object('request_key',content_request,'engine_release_sha256',new_root_sha,'created_at',clock_timestamp());
  INSERT INTO mission_public_owner.mission_content_admissions_v1(request_key,mission_id,config_version,engine_release_sha256,publication_request,payload,payload_sha256)
  VALUES(content_request,content_row.mission_id,content_row.config_version,new_root_sha,content_row.publication_request,content_payload,mission_factory_owner.sha(content_payload));
  IF mission_public_owner.content_admission_v1(content_row.mission_id,new_root_sha,content_row.publication_request,true)IS NULL THEN
   RAISE EXCEPTION 'SFERA_CONTENT_CARRYFORWARD_INVALID';END IF;
 END LOOP;
 UPDATE mission_public_owner.party_launch_runtime_v1 x SET release_sha256=new_root_sha WHERE singleton AND to_jsonb(x)=runtime_before;
 GET DIAGNOSTICS affected=ROW_COUNT;IF affected<>1 THEN RAISE EXCEPTION 'SFERA_PARTY_RUNTIME_CAS';END IF;

 IF (SELECT count(*) FROM mission_public_owner.mission_content_admissions_v1 c WHERE c.engine_release_sha256=new_root_sha
     AND mission_public_owner.content_admission_v1(c.mission_id,new_root_sha,c.publication_request,true) IS NOT NULL)<>2
  OR (SELECT to_jsonb(x) FROM mission_public_owner.party_launch_runtime_v1 x WHERE singleton)
      IS DISTINCT FROM jsonb_set(runtime_before,'{release_sha256}',to_jsonb(new_root_sha),false)
 THEN RAISE EXCEPTION 'SFERA_FINAL_MISSION_BOUNDARY_DRIFT'; END IF;
 PERFORM set_config('app.sfera_result',jsonb_build_object('root_sha256',new_root_sha,'root_bytes',octet_length(root_text),
   'previous_root_sha256',old_root_sha,'staff_enabled',true,'public_opening',false,'existing_mission_contents',2,
   'playtest','NOT_RUN','provider_calls',0)::text,true);

END;
$sfera_post$;

SELECT current_setting('app.sfera_result',true)::jsonb AS release_receipt;
COMMIT;
