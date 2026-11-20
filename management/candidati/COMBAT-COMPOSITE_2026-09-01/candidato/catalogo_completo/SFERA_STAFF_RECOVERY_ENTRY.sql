BEGIN;
SET LOCAL search_path='';
SET LOCAL lock_timeout='2s';

DO $sfera_recovery$
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

 expected_active_root text:=$sfera_active$8261958382e653c1077972c8410f01b039b1d82d7a032efff09189a8734e0cfb$sfera_active$;
BEGIN
 
 review:=$sfera_review${"ref":"SFERA_R3_RECOVERY_REVIEW","sha256":"33a5fd3048d6ab9a750e123d45b1b2a33f9223136157799462c142df53671b48","P0":0,"P1":0,"P2":0}$sfera_review$::jsonb;
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

 IF expected_active_root!~'^[a-f0-9]{64}$' OR rr.revision_sha256 IS DISTINCT FROM expected_active_root
  OR (SELECT enabled FROM clan_aburame_private.sfera_staff_gate_v1 WHERE singleton) IS DISTINCT FROM true
  OR EXISTS(SELECT 1 FROM clan_aburame_private.sfera_sources_v1 WHERE state IN('reserved','active'))
  OR EXISTS(SELECT 1 FROM clan_aburame_private.sfera_sources_v1 s JOIN clan_aburame_private.colony_sources c
       ON c.owner_id=s.owner_character_id AND c.scope_id=s.session_id AND c.source_id=s.declaration_id
       WHERE c.state='active')
 THEN RAISE EXCEPTION 'SFERA_RECOVERY_REQUIRES_NATIVE_SETTLEMENT_AND_EXACT_ACTIVE_ROOT'; END IF;
 
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

 
 SELECT * INTO STRICT prior_release FROM mission_public_owner.release_admissions_v1
  WHERE release_sha256=rr.revision_sha256 FOR SHARE;
 SELECT * INTO STRICT prior_qualification FROM mission_public_owner.public_qualification_attestations_v1
  WHERE release_sha256=rr.revision_sha256 FOR SHARE;
 SELECT to_jsonb(x) INTO STRICT runtime_before FROM mission_public_owner.party_launch_runtime_v1 x
  WHERE singleton FOR UPDATE;
 IF prior_release.edge_sha256 IS DISTINCT FROM generic_ezbr
  OR mission_public_owner.engine_qualification_v1(rr.revision_sha256,true) IS NULL 
  OR public.combat_v2_sha256(prior_qualification.payload->'capabilities') IS DISTINCT FROM '49fe134f561273f28e8071b63c45886341371b67d028f06e6b7d8f8d4108e817'
  OR runtime_before IS DISTINCT FROM jsonb_set('{"singleton":true,"staff_enabled":true,"public_enabled":true,"release_sha256":"4aec6254673c4c076d313660659a11a0f0b502d434def8bd7a6e4a5c8776f479"}'::jsonb,'{release_sha256}',to_jsonb(rr.revision_sha256),false)
  OR (SELECT count(*) FROM mission_public_owner.mission_content_admissions_v1 c
      WHERE c.engine_release_sha256=rr.revision_sha256
       AND mission_public_owner.content_admission_v1(c.mission_id,rr.revision_sha256,c.publication_request,true) IS NOT NULL)<>2
  OR (SELECT count(DISTINCT profile_key) FROM mission_public_owner.engine_profile_events_v1
       WHERE engine_release_sha256=rr.revision_sha256)<>1
  
 THEN RAISE EXCEPTION 'SFERA_UNRELATED_MISSION_EVIDENCE_DRIFT';END IF;

 
WITH base AS MATERIALIZED (
 SELECT revision_sha256 AS old_sha,public.combat_v2_sha256(to_jsonb(r)) AS old_row_sha,
        canonical_preimage AS old_text,canonical_preimage::jsonb AS r
 FROM mission_factory_owner.editor_release_readiness r WHERE singleton
), edge AS (SELECT edge_receipt AS receipt)

, staged AS MATERIALIZED (
 SELECT base.*,edge.receipt,jsonb_set(jsonb_set(r,'{db_core,sfera_staff}','"8caf9ffc6696faaa710cabbc3f8f199b5f4c039f1446fe9e349282bc5d0713be"'::jsonb,false),'{config,sfera_staff}','"8caf9ffc6696faaa710cabbc3f8f199b5f4c039f1446fe9e349282bc5d0713be"'::jsonb,false) AS patched,
    (old_sha=expected_active_root AND r#>'{db_core,sfera_staff}' IS NOT DISTINCT FROM '"dad3e133506bbce74401b53cec128e8aa58e6f14155f6601749fe5184b1dc1e9"'::jsonb AND r#>'{config,sfera_staff}' IS NOT DISTINCT FROM '"dad3e133506bbce74401b53cec128e8aa58e6f14155f6601749fe5184b1dc1e9"'::jsonb AND (SELECT value->'ezbr_sha256'=edge.receipt->'ezbr_sha256'
                            AND value->'version'=edge.receipt->'version'
                            AND value->'deployment_receipt_sha256'=edge.receipt->'deployment_receipt_sha256'
                      FROM jsonb_array_elements(r->'edge_bundles') WHERE value->>'name'='combat_narratore_ai') IS TRUE
          AND (SELECT jsonb_agg(x ORDER BY x->>'name') FROM jsonb_array_elements(r->'edge_bundles') b
             CROSS JOIN LATERAL jsonb_array_elements(b->'files') x WHERE b->>'name'='combat_narratore_ai')
                IS NOT DISTINCT FROM '[{"name":"adattatore.ts","bytes":19495,"sha256":"32bf2b017f70f2b3733992d99ca868405a812c35f725c64cf66adb4f5ebc851d"},{"name":"common.mjs","bytes":8305,"sha256":"c73d6fa04bf22c521b502387adb261c599996e58f309ddb3b5a64dd3f56e6cc4"},{"name":"count.mjs","bytes":4494,"sha256":"77791e0fa712967ba7818dee45964af6e4cda1673e1f4673c0238ff387ee335f"},{"name":"diagnostics.ts","bytes":2964,"sha256":"5846012ec1d57cffa8a54b17dd7a3efe61a91971cdf2b97f8afe67220ebba5ce"},{"name":"editorial.mjs","bytes":7802,"sha256":"8d6c00b9ebc16bfff9f17c7e9670292397f266b24f4664d299c5a3e58d692766"},{"name":"facts.ts","bytes":40051,"sha256":"cd22449d2aacf38bbf7b919678b58b256c4b89a47b6ccd16a69b6f3a75047bd9"},{"name":"flow.mjs","bytes":5332,"sha256":"ceefabdb6bd9e3cfe7e85c31b4a3805f76fbf7dae11ab0ad51994e9deff7722d"},{"name":"index.ts","bytes":71473,"sha256":"c02e347b84556199dd883cb59e5057ff2803ff3da29d0c01e0899ba82fe6d2c3"},{"name":"lifecycle.mjs","bytes":7147,"sha256":"5f7299124083a5b57ce75e6fb0b917fb6cabba0a369a2d78649e31eb4ccb0d6c"},{"name":"orchestra.ts","bytes":1177,"sha256":"47134473ddf7153499f7ce6056b3f892af4166df86fd614cf94b4ff2d9ba4e0f"},{"name":"ordinary.ts","bytes":8946,"sha256":"456e734e9dd96858a44e5d86fb15d76acbff13a2727be64288fbff1601c9f502"},{"name":"recovery.ts","bytes":1081,"sha256":"dadcba58f18fac2aa6fba6f921a556c4653ddfa7eb6042feacd0c5e6dc554692"},{"name":"repertorio.json","bytes":14845,"sha256":"86b291f40f3baadb5fbe7e984e5f01e2fe910b7c645d1a77dd13a41970a4e37e"},{"name":"rinuncia.ts","bytes":3421,"sha256":"30832b9dd830dc32074fb5b96d6062811520cc73169d629e3c08f8dd1b00a421"},{"name":"runtime.ts","bytes":9292,"sha256":"c49dba1ff22b2d4d507b8e1a446319fd03f1ddd82cc1555494f6b638d991ec2e"},{"name":"scene.mjs","bytes":7517,"sha256":"f4cfa79821a27ac026960fde6460bd8562f8ec527698e3a3290004018d9d5301"},{"name":"transport.ts","bytes":4913,"sha256":"590d7e2e2d289d904ea1015049e0723236634dcce7c306ef651b125219f8ad1f"},{"name":"user_test.mjs","bytes":3238,"sha256":"26b1a843cd9470c173f4a0c0a259013cd08b58a3482b699fe7af5daec18be9ba"}]'::jsonb AND true) AS pins_ok,
    (SELECT coalesce(jsonb_agg(label ORDER BY label) FILTER(WHERE ok IS DISTINCT FROM true),'[]'::jsonb) FROM (VALUES ('{db_core,sfera_staff}'::text,r#>'{db_core,sfera_staff}' IS NOT DISTINCT FROM '"dad3e133506bbce74401b53cec128e8aa58e6f14155f6601749fe5184b1dc1e9"'::jsonb),('{config,sfera_staff}'::text,r#>'{config,sfera_staff}' IS NOT DISTINCT FROM '"dad3e133506bbce74401b53cec128e8aa58e6f14155f6601749fe5184b1dc1e9"'::jsonb)) g(label,ok)) AS failed_paths, ((SELECT value->'ezbr_sha256'=edge.receipt->'ezbr_sha256'
                            AND value->'version'=edge.receipt->'version'
                            AND value->'deployment_receipt_sha256'=edge.receipt->'deployment_receipt_sha256'
                      FROM jsonb_array_elements(r->'edge_bundles') WHERE value->>'name'='combat_narratore_ai') IS TRUE
          AND (SELECT jsonb_agg(x ORDER BY x->>'name') FROM jsonb_array_elements(r->'edge_bundles') b
             CROSS JOIN LATERAL jsonb_array_elements(b->'files') x WHERE b->>'name'='combat_narratore_ai')
                IS NOT DISTINCT FROM '[{"name":"adattatore.ts","bytes":19495,"sha256":"32bf2b017f70f2b3733992d99ca868405a812c35f725c64cf66adb4f5ebc851d"},{"name":"common.mjs","bytes":8305,"sha256":"c73d6fa04bf22c521b502387adb261c599996e58f309ddb3b5a64dd3f56e6cc4"},{"name":"count.mjs","bytes":4494,"sha256":"77791e0fa712967ba7818dee45964af6e4cda1673e1f4673c0238ff387ee335f"},{"name":"diagnostics.ts","bytes":2964,"sha256":"5846012ec1d57cffa8a54b17dd7a3efe61a91971cdf2b97f8afe67220ebba5ce"},{"name":"editorial.mjs","bytes":7802,"sha256":"8d6c00b9ebc16bfff9f17c7e9670292397f266b24f4664d299c5a3e58d692766"},{"name":"facts.ts","bytes":40051,"sha256":"cd22449d2aacf38bbf7b919678b58b256c4b89a47b6ccd16a69b6f3a75047bd9"},{"name":"flow.mjs","bytes":5332,"sha256":"ceefabdb6bd9e3cfe7e85c31b4a3805f76fbf7dae11ab0ad51994e9deff7722d"},{"name":"index.ts","bytes":71473,"sha256":"c02e347b84556199dd883cb59e5057ff2803ff3da29d0c01e0899ba82fe6d2c3"},{"name":"lifecycle.mjs","bytes":7147,"sha256":"5f7299124083a5b57ce75e6fb0b917fb6cabba0a369a2d78649e31eb4ccb0d6c"},{"name":"orchestra.ts","bytes":1177,"sha256":"47134473ddf7153499f7ce6056b3f892af4166df86fd614cf94b4ff2d9ba4e0f"},{"name":"ordinary.ts","bytes":8946,"sha256":"456e734e9dd96858a44e5d86fb15d76acbff13a2727be64288fbff1601c9f502"},{"name":"recovery.ts","bytes":1081,"sha256":"dadcba58f18fac2aa6fba6f921a556c4653ddfa7eb6042feacd0c5e6dc554692"},{"name":"repertorio.json","bytes":14845,"sha256":"86b291f40f3baadb5fbe7e984e5f01e2fe910b7c645d1a77dd13a41970a4e37e"},{"name":"rinuncia.ts","bytes":3421,"sha256":"30832b9dd830dc32074fb5b96d6062811520cc73169d629e3c08f8dd1b00a421"},{"name":"runtime.ts","bytes":9292,"sha256":"c49dba1ff22b2d4d507b8e1a446319fd03f1ddd82cc1555494f6b638d991ec2e"},{"name":"scene.mjs","bytes":7517,"sha256":"f4cfa79821a27ac026960fde6460bd8562f8ec527698e3a3290004018d9d5301"},{"name":"transport.ts","bytes":4913,"sha256":"590d7e2e2d289d904ea1015049e0723236634dcce7c306ef651b125219f8ad1f"},{"name":"user_test.mjs","bytes":3238,"sha256":"26b1a843cd9470c173f4a0c0a259013cd08b58a3482b699fe7af5daec18be9ba"}]'::jsonb) AS edge_pins_ok, (true) AS peer_pins_ok, (old_sha=expected_active_root) AS parent_pins_ok
 FROM base CROSS JOIN edge
), families AS MATERIALIZED (
 SELECT *,jsonb_set(patched,'{config,catalogo_families}',to_jsonb(public.combat_v2_sha256(patched#>'{db_core,catalogo_families}')),false) AS c
 FROM staged
), hashing AS MATERIALIZED (
 SELECT *,public.combat_v2_sha256((c->'db_core')-'sha256') AS projected_db_sha,
       public.combat_v2_sha256((c->'config')-'sha256') AS projected_config_sha
 FROM families
), identity AS MATERIALIZED (
 SELECT *,public.combat_v2_sha256(jsonb_build_object('version','sfera-staff/1','mode','inert',
      'parent',old_sha,'previous_identity',r#>'{contract,code_identity_sha256}',
      'leaf','8caf9ffc6696faaa710cabbc3f8f199b5f4c039f1446fe9e349282bc5d0713be','db',projected_db_sha,'config',projected_config_sha,'edge',receipt->'ezbr_sha256')) AS identity_sha
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
 WHERE pins_ok IS TRUE AND candidate_text::jsonb=s.root_document AND octet_length(candidate_text)<=524288
   AND r->'ui'=s.root_document->'ui' AND r->'edge_bundles'=s.root_document->'edge_bundles';
 
 old_root_sha:=rr.revision_sha256;
 old_row_sha:=public.combat_v2_sha256(to_jsonb(rr));
 candidate_root:=root_text::jsonb;
 db_sha:=candidate_root#>>'{db_core,sha256}';
 config_sha:=candidate_root#>>'{config,sha256}';
 IF octet_length(root_text)>524288 OR db_sha IS DISTINCT FROM public.combat_v2_sha256((candidate_root->'db_core')-'sha256')
 OR config_sha IS DISTINCT FROM public.combat_v2_sha256((candidate_root->'config')-'sha256')
 OR NOT (candidate_root#>>'{db_core,sfera_staff}' IS NOT DISTINCT FROM '8caf9ffc6696faaa710cabbc3f8f199b5f4c039f1446fe9e349282bc5d0713be')
 OR NOT (candidate_root#>>'{config,sfera_staff}' IS NOT DISTINCT FROM '8caf9ffc6696faaa710cabbc3f8f199b5f4c039f1446fe9e349282bc5d0713be')
 OR public.combat_v2_sha256(candidate_root->'ui') IS DISTINCT FROM 'b62cac808730c14ff1558ac666b3a76c3cc264e4716b858205acada9efadefc9'
 THEN RAISE EXCEPTION 'SFERA_FINAL_ROOT_BINDING_INVALID'; END IF;
 new_root_sha:=encode(extensions.digest(convert_to(root_text,'UTF8'),'sha256'),'hex');
 params:='{"expected_mission_capabilities_sha256":"49fe134f561273f28e8071b63c45886341371b67d028f06e6b7d8f8d4108e817","compatibility":{"ref":"sfera-inert-existing-missions","sha256":"8caf9ffc6696faaa710cabbc3f8f199b5f4c039f1446fe9e349282bc5d0713be"}}'::jsonb;
 bindings:=jsonb_build_object('db_sha256',db_sha,'edge_sha256',generic_ezbr,
   'client_sha256',public.combat_v2_sha256(candidate_root->'ui'),'configuration_sha256',config_sha);
 UPDATE mission_factory_owner.editor_release_readiness
 SET canonical_preimage=root_text,revision_sha256=new_root_sha,observed_revision_sha256=new_root_sha,
   client_build='mission-factory-admin/2:'||new_root_sha,independent_review_ref=review->>'ref',updated_at=clock_timestamp()
 WHERE singleton AND revision_sha256=old_root_sha AND public.combat_v2_sha256(to_jsonb(editor_release_readiness))=old_row_sha;
 GET DIAGNOSTICS affected=ROW_COUNT;
 IF affected<>1 THEN RAISE EXCEPTION 'SFERA_ROOT_CAS';END IF;
 UPDATE clan_aburame_private.sfera_staff_gate_v1 SET enabled=false WHERE singleton AND enabled;
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
   'previous_root_sha256',old_root_sha,'staff_enabled',false,'public_opening',false,'existing_mission_contents',2,
   'playtest','NOT_RUN','provider_calls',0)::text,true);

END;
$sfera_recovery$;

SELECT current_setting('app.sfera_result',true)::jsonb AS release_receipt;
COMMIT;
