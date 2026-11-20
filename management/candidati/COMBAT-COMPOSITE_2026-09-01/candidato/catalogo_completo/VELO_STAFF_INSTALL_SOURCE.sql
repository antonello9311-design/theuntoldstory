BEGIN;
SET LOCAL search_path='';
SET LOCAL lock_timeout='2s';

DO $velo_pre$
#variable_conflict error
DECLARE

 rr mission_factory_owner.editor_release_readiness%ROWTYPE;
 prior_release mission_public_owner.release_admissions_v1%ROWTYPE;
 prior_qualification mission_public_owner.public_qualification_attestations_v1%ROWTYPE;
 review jsonb;
 generic_ezbr constant text:='9a6889802cfa17c99a556538cccd4ad7ef75274d32adccbc192c23d257aa3e76';

BEGIN

 review:=$velo_review$__VELO_STAFF_R2_FORWARD_REVIEW_JSON__$velo_review$::jsonb;
 IF NOT mission_factory_owner.keys_exact_v2(review,ARRAY['ref','sha256','P0','P1','P2'])
 OR coalesce(review->>'ref','') !~ '^[A-Za-z0-9_.#-]{1,40}$'
 OR coalesce(review->>'sha256','') !~ '^[a-f0-9]{64}$'
 OR review->'P0' IS DISTINCT FROM '0'::jsonb OR review->'P1' IS DISTINCT FROM '0'::jsonb
 OR review->'P2' IS DISTINCT FROM '0'::jsonb THEN
  RAISE EXCEPTION 'VELO_INDEPENDENT_REVIEW_REQUIRED';
 END IF;
 PERFORM set_config('app.velo_review',review::text,true);


 IF current_user<>'postgres' OR session_user<>'postgres' OR auth.uid() IS NOT NULL
 OR (SELECT rolbypassrls FROM pg_roles WHERE rolname='postgres') IS DISTINCT FROM true THEN
  RAISE EXCEPTION 'VELO_OPERATOR_REQUIRED';
 END IF;
 IF NOT pg_try_advisory_xact_lock(hashtextextended('C1266:GENERIC-AI:AVAILABILITY',0)) THEN
  RAISE EXCEPTION 'VELO_availability_busy';
 END IF;
 SELECT * INTO STRICT rr FROM mission_factory_owner.editor_release_readiness WHERE singleton FOR UPDATE NOWAIT;
 LOCK TABLE public.master_v2_sessions,public.combat_v2_sessions,combat_consumer_private.invitations IN SHARE MODE NOWAIT;
 LOCK TABLE mission_public_owner.release_admissions_v1,mission_public_owner.public_qualification_attestations_v1,
  mission_public_owner.engine_profile_events_v1,mission_public_owner.mission_content_admissions_v1,
  mission_public_owner.party_launch_runtime_v1 IN SHARE ROW EXCLUSIVE MODE NOWAIT;

 IF EXISTS(SELECT 1 FROM public.combat_v2_sessions WHERE closed_at IS NULL AND state IN ('preparazione','in_corso','sospeso'))
 OR EXISTS(SELECT 1 FROM public.master_v2_sessions WHERE closed_at IS NULL AND stato NOT IN ('chiusa','annullata'))
 OR EXISTS(SELECT 1 FROM combat_consumer_private.invitations
           WHERE state='pending' AND location_id='0b85f354-9cdb-47e1-baf9-3d266bb7e06b'::uuid) THEN
  RAISE EXCEPTION 'VELO_REQUIRES_QUIESCENCE';
 END IF;
 IF rr.state IS DISTINCT FROM 'enabled' OR rr.scope IS DISTINCT FROM 'staff'
  OR rr.staff_guards_verified IS DISTINCT FROM true OR rr.published_assets_verified IS DISTINCT FROM true
  OR public.combat_v2_sha256(to_jsonb(rr)-ARRAY['canonical_preimage','revision_sha256','observed_revision_sha256','client_build','independent_review_ref','updated_at']) IS DISTINCT FROM '85efdb471dc5560963e027a19649f6dfab701125ca948c0c3d1aa4dce7d6da37'
  OR encode(extensions.digest(convert_to(rr.canonical_preimage,'UTF8'),'sha256'),'hex') IS DISTINCT FROM rr.revision_sha256
  OR rr.observed_revision_sha256 IS DISTINCT FROM rr.revision_sha256
  OR NOT clan_innata_private.catalogo_eligibility_release_v1() THEN
  RAISE EXCEPTION 'VELO_READINESS_DRIFT';
 END IF;
 PERFORM clan_innata_private.runtime_release_assert();

 IF rr.revision_sha256 IS DISTINCT FROM '0fb538733f7010d36babf42f2ffa69432b16b8baa1e9bdea6d0b4ff6d447ae8d'
 OR public.combat_v2_sha256(to_jsonb(rr)) IS DISTINCT FROM '92af19424dbe4a11633c86e637c99c529785ae917ad4b58f563264c9a6ed5db1'
 OR octet_length(rr.canonical_preimage) IS DISTINCT FROM 523748
 OR to_regclass('clan_innata_combat_private.velo_staff_gate_v1') IS NOT NULL THEN
  RAISE EXCEPTION 'VELO_FORWARD_BASELINE_DRIFT';
 END IF;
 IF EXISTS(SELECT 1 FROM clan_innata_combat_private.combat_state WHERE technique_id='c9b261da-c9cd-40bb-8189-7b65ab5a1605')
 OR EXISTS(SELECT 1 FROM clan_innata_combat_private.combat_receipts WHERE technique_id='c9b261da-c9cd-40bb-8189-7b65ab5a1605') THEN
  RAISE EXCEPTION 'VELO_FORWARD_EXISTING_HISTORY';
 END IF;

 IF (SELECT public.combat_v2_sha256(to_jsonb(t)) FROM public.clan_techniques t WHERE t.id='c9b261da-c9cd-40bb-8189-7b65ab5a1605')
     IS DISTINCT FROM 'a79a36d47fe260c0db0d965703cef3b41d98c39530605382d6a8c68109d78229' THEN
  RAISE EXCEPTION 'VELO_CATALOGUE_DRIFT';
 END IF;


 IF jsonb_build_object('ABU',(SELECT to_jsonb(g) FROM clan_aburame_private.verme_gate_v1 AS g WHERE g.singleton),
    'AKI',(SELECT to_jsonb(g) FROM clan_akimichi_private.common_gate_v1 AS g WHERE g.singleton),
    'NARA',(SELECT to_jsonb(g) FROM combat_panel_private.nara_adv_gate_v1 AS g WHERE g.singleton),
    'NB',(SELECT to_jsonb(g) FROM combat_v2_staff_nb_internal.gate AS g WHERE g.singleton),
    'aburame_genin',(SELECT to_jsonb(g) FROM clan_aburame_private.release_gate AS g WHERE g.singleton),
    'akimichi_genin',(SELECT to_jsonb(g) FROM clan_akimichi_private.release_gate AS g WHERE g.singleton),
    'cure',(SELECT to_jsonb(g) FROM combat_panel_private.cure_gate_v1 AS g WHERE g.singleton),
    'genjutsu',(SELECT to_jsonb(g) FROM combat_v2_genjutsu_internal.gate AS g WHERE g.singleton),
    'nara_genin',(SELECT to_jsonb(g) FROM combat_panel_private.nara_launch_gate_v1 AS g WHERE g.singleton)) IS DISTINCT FROM $velo_baseline_gates${"NB":{"version":1,"singleton":true,"staff_enabled":true,"public_enabled":false},"ABU":{"singleton":true,"staff_enabled":true,"public_enabled":false,"contract_version":"aburame-verme/1"},"AKI":{"singleton":true,"staff_enabled":true,"public_enabled":false,"contract_version":"akimichi-common/1","super_public_enabled":false,"cellular_public_enabled":false},"NARA":{"singleton":true,"staff_enabled":true,"public_enabled":false},"cure":{"singleton":true,"staff_enabled":true,"public_enabled":false,"contract_version":"palmo-curativo/1"},"genjutsu":{"enabled":true,"version":1,"singleton":true,"staff_enabled":true,"public_enabled":false},"nara_genin":{"singleton":true,"staff_enabled":true,"public_enabled":true,"public_activated_at":"2026-11-13T10:40:45.463756+00:00"},"aburame_genin":{"version":2,"singleton":true,"staff_enabled":true,"public_enabled":true},"akimichi_genin":{"singleton":true,"staff_enabled":true,"public_enabled":true}}$velo_baseline_gates$::jsonb THEN
  RAISE EXCEPTION 'VELO_EXISTING_GATES_DRIFT';
 END IF;


 IF EXISTS(SELECT 1 FROM jsonb_to_recordset($velo_headers$[{"sig":"combat_panel_private.master_options(uuid,uuid,bigint)","oid":"44940","src":"daccab39aa3e67a4c1a361860b8adbdf","sha":"fd36c031dc772ea40934238d3defabda351509ee7719056e7cc5bc0a8589f90f","abi":"ce730160f86c59e91d1a0a7deef8f8deeaf3d391ab86ea68d39782a6cd536022"},{"sig":"combat_panel_private.ordinary_options(uuid,uuid,bigint)","oid":"44669","src":"4c23fa161abb816fb0f10d50f2642630","sha":"48b17c87dd8af9ecb4d916f80e20d62e7d81f1eab0581cbb5872ee3ed2ea0289","abi":"643e9950ea1e32cbf6277499719fa8f15fa7a0b7d05f54e12e75ef937be06ae6"},{"sig":"public.combat_panel_commit_v1(jsonb)","oid":"44808","src":"9c98707e4d76a4e0a23b5e7efb504ab2","sha":"f38877f00bc244105753fa05c9b507f1ab67916c38a4db9df4badcff888afa08","abi":"e372b82c6e09185978269696be55e171660ff3dfe967336165aad4cda5b3ef03"},{"sig":"clan_innata_private.combat_activation_window(uuid,uuid)","oid":"48763","src":"5385f7e1bdc32ee7d59133e95815e21b","sha":"8537c438f12fb93f2cc268d9904e5d86429e1735a769992555a96703a683a873","abi":"9f2be91f9ba58d72824e9f1f94acbf904e60b51cf8ce5a6a085bb08f667030be"},{"sig":"clan_innata_private.combat_scope(uuid,uuid)","oid":"48765","src":"1e4edfe0c15ef30d9e2a302660f16925","sha":"ce5122cda19a5077d410c468e36cdf776c0384e8ce842413c29118252ae3c55b","abi":"dffecf3d30ec820085f38cefa4d4a8927dcf31671af742187bc9aa47703fd4c4"},{"sig":"clan_innata_private.combat_transition(uuid,uuid,text,uuid,bigint)","oid":"48770","src":"c0cc84dede19bba696ab104456e5b95d","sha":"7e3f1a86f604f216f8cb220c8e70b05c56a6327d8da7fb49a91c2a36b9241620","abi":"e4d484a489ecb1fc2d75b676f82b9aa44084920a65a1a30b48b0b3549c872d35"},{"sig":"combat_v2_multitarget_internal.sync_declaration()","oid":"39288","src":"5d233775e0306d9712ca05d87e747131","sha":"fa7e71e54fe60868154fd291533f4f9f9a58257fe2353f9f9ee88e7e9c70e240","abi":"2a7ccf3c2542a9a82bf85c86e944a27ac329e52c5f4482f43db0e41c5ae90043"},{"sig":"public.combat_v2_round_resolve(uuid,uuid)","oid":"31331","src":"4cf0eb3077ada0bb5e628bd89fef4dc3","sha":"394e7c89d81c88b059356d633011ba29fde9978b9fa3f5ba138986ff1e9b7c0a","abi":"1a8c5c3dbfab1c5ca0205bd5a0d6dd0d855a8f9650e4191094a4121a87835fc0"},{"sig":"combat_v2_multitarget_internal.resolve_parent(uuid,uuid,uuid,boolean)","oid":"39291","src":"ea4552d934017752fa4c97e6a2480bbf","sha":"21b722a3f3287655a92afd9972b0f9e0bd19653d372c3dc4b0332c74e20c80ac","abi":"030493526444add376807fb621719ed92aae1d2123ee31c7f51ef80c2bc0d7ac"},{"sig":"clan_hyuga_private.rotation_attack_power_freeze(uuid)","oid":"51291","src":"54c485bd1e699de176450a2a7f476b02","sha":"9deb7be857bc8a30ef6a22d9c1024ab3429abd8994c112860130da603cd4d2c4","abi":"a282ba1d663a2562c8ff803a53862bccb7c55d9bcfcba335a25c63b65b6e282f"},{"sig":"clan_akimichi_private.common_attack_power_freeze_v1(uuid)","oid":"685921","src":"a0aef8c5b85e4afcc2a32a95800f6e27","sha":"0a74f6313ef4cd6bb70496e9fd762a06f7e2c902259a71653b01bfbbfa23ae99","abi":"3f0579083ae695c3f6796801bd244ba7b09d7f89fe34bcb1f89387d596ef1bd8"},{"sig":"combat_panel_private.movement_budget(uuid,uuid)","oid":"45001","src":"57546d18129f1fd09b05aeecfca00403","sha":"6da4f33f23230c6fca92e9fe37975baee4dfdd5f9e441aad93aac607293e7f93","abi":"2c6ab2d8a23b0b32e487b404aa7656953b872815ef262a49c45f023777ab3367"},{"sig":"clan_innata_private.combat_begin_turn(uuid)","oid":"45348","src":"fce814aa347127860965c5374ec23659","sha":"9109fbae8495b8c776e6ab78d8c5b348460ef0612c274a3ec959bb1ac86cdb3a","abi":"f1d4529e49023b94937550724c4e57a4684402efa6f710a234c1492bfee17340"},{"sig":"clan_innata_private.combat_begin_turn(uuid,uuid)","oid":"48764","src":"47566d1c6ccf6958caf89f33ffd9b65b","sha":"3693a17cf2193b575264621d33fb418825dec0ba7883eb71ce64fb0b5d3fb269","abi":"a9251bdd618edb2d1b58752600ab26472bc54e664af3193a5b4952c45abaad06"},{"sig":"clan_innata_private.combat_terminal(uuid,text)","oid":"45347","src":"73cc679cf6c5d0faf74643bcf793be97","sha":"a0d531987f530c8d33b88e106aab18ab9831b554ddaac5973a00fa9f15efd5e4","abi":"4d5212d30963d1246daffd96bbc5319ce5d2fa9e73aec71adf9e1a734dee9097"},{"sig":"clan_innata_private.combat_terminal(uuid,uuid,text)","oid":"48768","src":"f6b3bc2a10d4745c45e25c242daa017a","sha":"e72500cd23558802d839a12f3b2f0df88e199c3bdfbc09876eb411e6fcb9e533","abi":"af9a577ba02e0a94922490532a92000d5cefbc016ffbc8d82b970862faeb07f0"},{"sig":"public.combat_v2_actor_ability(uuid,text,uuid,boolean)","oid":"31311","src":"0ca27d8dd57a67f255016e0d13008b1f","sha":"512afb87dcdaaae4c394ea5eff500bcbf12123dea43ee13588e84fb5c19563d8","abi":"d6389fce6481a1ba0b34106c4583eb03404117c2ea8c88b395cfdd6c1da040d8"},{"sig":"public.combat_v2_character_snapshot(uuid)","oid":"31310","src":"46a5bc3b2febda3dc31eba2d43bdf381","sha":"20c680c16a5ba1adedada1b9dcb6b5ee2f91bf01ddbdd9c0d40064d9d2d57ee3","abi":"4f39724d600a2d16ec55572864d6963eb8bf892e84c390305b9a2dc8719cdf09"},{"sig":"public.test_room_user_techniques()","oid":"30222","src":"69f0f194f74087a78bd6fbc26e88b4df","sha":"4b7abe4dfdd7e15241b0e8ab760756793f1ec98141f1f8c9e3eef2c23f8f96a9","abi":"8f1ed10e342f59e1d5a60bfdca54da7ffb3d14d2b45f57c95210bb989f1aa43a"},{"sig":"combat_panel_private.master_actor_offers(uuid,bigint,jsonb,jsonb)","oid":"44936","src":"952a8a0deeaa6c1db84410b8409c06a1","sha":"a51da939fb5fa697bb1106dd97fe0bd9ce8c2ba993f00479d00df447410c0a09","abi":"fceda56eb2d5e085dfd66f4c401be6836c55a111bb000f111a53d304e8f5628e"},{"sig":"combat_panel_private.master_scene_lifecycle_trigger()","oid":"44994","src":"a4c4c266b494fb77ab0a7afeb988de94","sha":"c0c589b3d72725a6805e5900560b6a8ade2bf2baaaadfd29af77032a2c9391b2","abi":"b1beed1b917da5326ece7870681ec0b8f4127bdb8ba16d6a982ab8b870ee0815"},{"sig":"clan_innata_private.catalogo_eligibility_release_v1()","oid":"684829","src":"d5cd7195b4036520b46ec1fc87175c2f","sha":"6815c950932fbdfcc07df6fdd71fb562e6b5c054cc978e23e74683bffc4a4ef4","abi":"7d2dcd85f468271ee5b86ca4cb359d8c8e0adcb8a08af8784f52c7d01ebdec5b"},{"sig":"clan_innata_private.eligibility_release_assert()","oid":"41419","src":"78dd10959830241cf446b1cd738dbd2d","sha":"45331155de0bcce8201993b0bc155194d331e35430690716f1fb6feb2d21464e","abi":"7a319aa51034184281d8449c40422632bd7ad214b9f1ad005ba1b390511361ca"}]$velo_headers$::jsonb) AS expected(sig text,oid text,src text,sha text,abi text)
  LEFT JOIN pg_proc p ON p.oid=to_regprocedure(expected.sig)
  LEFT JOIN pg_language l ON l.oid=p.prolang
  WHERE p.oid::text IS DISTINCT FROM expected.oid OR md5(p.prosrc) IS DISTINCT FROM expected.src
   OR encode(extensions.digest(pg_get_functiondef(p.oid),'sha256'),'hex') IS DISTINCT FROM expected.sha
   OR public.combat_v2_sha256(jsonb_build_object('oid',p.oid::text,'owner',pg_get_userbyid(p.proowner),
 'acl',p.proacl::text,'config',p.proconfig,'security_definer',p.prosecdef,'strict',p.proisstrict,
 'volatile',p.provolatile::text,'parallel',p.proparallel::text,'kind',p.prokind::text,'language',l.lanname,
 'returns',pg_get_function_result(p.oid),'arg_types',p.proargtypes::text,'arg_names',p.proargnames,
 'arg_modes',p.proargmodes,'leakproof',p.proleakproof)) IS DISTINCT FROM expected.abi) THEN
  RAISE EXCEPTION 'VELO_BEFORE_HEADER_OR_BODY_DRIFT';
 END IF;


 IF EXISTS (
 WITH relation_names(name) AS (VALUES ('clan_innata_combat_private.combat_state'::text),('public.combat_v2_actors'::text),('public.combat_v2_declarations'::text),('public.combat_v2_sessions'::text),('public.master_v2_sessions'::text)),
 relations AS (SELECT r.* FROM relation_names rn CROSS JOIN LATERAL (SELECT w.name,c.oid,c.relkind::text kind,c.relowner::regrole::text owner,c.relacl::text acl,c.relrowsecurity rls,c.relforcerowsecurity force_rls,
 (SELECT coalesce(jsonb_agg(jsonb_build_object('name',a.attname,'type',format_type(a.atttypid,a.atttypmod),'notnull',a.attnotnull,'default',pg_get_expr(d.adbin,d.adrelid))ORDER BY a.attnum),'[]'::jsonb)FROM pg_attribute a LEFT JOIN pg_attrdef d ON d.adrelid=a.attrelid AND d.adnum=a.attnum WHERE a.attrelid=c.oid AND a.attnum>0 AND NOT a.attisdropped)columns,
 (SELECT coalesce(jsonb_agg(jsonb_build_object('name',x.conname,'ddl',CASE WHEN x.conname='combat_state_technique_id_check' THEN regexp_replace(pg_get_constraintdef(x.oid),'[()[:space:]]','','g') ELSE pg_get_constraintdef(x.oid) END,'validated',x.convalidated)ORDER BY x.conname),'[]'::jsonb)FROM pg_constraint x WHERE x.conrelid=c.oid)constraints,
 (SELECT coalesce(jsonb_agg(jsonb_build_object('name',t.tgname,'enabled',t.tgenabled::text,'ddl',pg_get_triggerdef(t.oid),'function_md5',md5(pg_get_functiondef(t.tgfoid)))ORDER BY t.tgname),'[]'::jsonb)FROM pg_trigger t WHERE t.tgrelid=c.oid AND NOT t.tgisinternal)triggers,
 (SELECT coalesce(jsonb_agg(jsonb_build_object('name',x.polname,'command',x.polcmd::text,'permissive',x.polpermissive,'roles',to_jsonb(x.polroles),'using',pg_get_expr(x.polqual,x.polrelid),'with_check',pg_get_expr(x.polwithcheck,x.polrelid))ORDER BY x.polname),'[]'::jsonb)FROM pg_policy x WHERE x.polrelid=c.oid)policies,
 (SELECT coalesce(jsonb_agg(jsonb_build_object('name',x.indexrelid::regclass::text,'ddl',pg_get_indexdef(x.indexrelid))ORDER BY x.indexrelid::regclass::text),'[]'::jsonb)FROM pg_index x WHERE x.indrelid=c.oid)indexes,
 CASE WHEN c.relkind='v'THEN pg_get_viewdef(c.oid,true)END view FROM(SELECT rn.name::text name)w LEFT JOIN pg_class c ON c.oid=to_regclass(w.name)) r)
 SELECT 1 FROM jsonb_to_recordset($velo_rel_shapes$[{"name":"clan_innata_combat_private.combat_state","descriptor":{"acl":"{postgres=arwdDxtm/postgres}","oid":"45211","rls":true,"kind":"r","name":"clan_innata_combat_private.combat_state","view":null,"owner":"postgres","columns":[{"name":"session_id","type":"uuid","default":null,"notnull":true},{"name":"actor_id","type":"uuid","default":null,"notnull":true},{"name":"technique_id","type":"uuid","default":null,"notnull":true},{"name":"is_test","type":"boolean","default":null,"notnull":true},{"name":"active","type":"boolean","default":"false","notnull":true},{"name":"state_version","type":"bigint","default":"0","notnull":true},{"name":"activated_round_id","type":"uuid","default":null,"notnull":false},{"name":"last_upkeep_round_id","type":"uuid","default":null,"notnull":false}],"indexes":[{"ddl":"CREATE UNIQUE INDEX combat_state_pkey ON clan_innata_combat_private.combat_state USING btree (session_id, actor_id, technique_id)","name":"clan_innata_combat_private.combat_state_pkey"}],"policies":[],"triggers":[{"ddl":"CREATE TRIGGER byakugan_family_guard BEFORE INSERT OR UPDATE ON clan_innata_combat_private.combat_state FOR EACH ROW EXECUTE FUNCTION clan_innata_narrative_private.byakugan_family_guard_v1()","name":"byakugan_family_guard","enabled":"O","function_md5":"b056df94d5db4cd7472e71c031e29362"},{"ddl":"CREATE TRIGGER common_combat_canonical BEFORE INSERT OR UPDATE ON clan_innata_combat_private.combat_state FOR EACH ROW EXECUTE FUNCTION clan_innata_private.combat_state_guard()","name":"common_combat_canonical","enabled":"O","function_md5":"bf835cd2b9a7da124c5bb614f036aade"},{"ddl":"CREATE TRIGGER sabaku_clone_innata_off AFTER UPDATE OF active ON clan_innata_combat_private.combat_state FOR EACH ROW EXECUTE FUNCTION clan_sabaku_private.clone_lifecycle_trigger()","name":"sabaku_clone_innata_off","enabled":"O","function_md5":"d8187fc67f036ca0cb9a0cfcd5137eed"}],"force_rls":false,"constraints":[{"ddl":"FOREIGN KEY (activated_round_id) REFERENCES public.combat_v2_rounds(id)","name":"combat_state_activated_round_id_fkey","validated":true},{"ddl":"FOREIGN KEY (actor_id) REFERENCES public.combat_v2_actors(id)","name":"combat_state_actor_id_fkey","validated":true},{"ddl":"FOREIGN KEY (last_upkeep_round_id) REFERENCES public.combat_v2_rounds(id)","name":"combat_state_last_upkeep_round_id_fkey","validated":true},{"ddl":"PRIMARY KEY (session_id, actor_id, technique_id)","name":"combat_state_pkey","validated":true},{"ddl":"FOREIGN KEY (session_id) REFERENCES public.combat_v2_sessions(id)","name":"combat_state_session_id_fkey","validated":true},{"ddl":"CHECK ((state_version >= 0))","name":"combat_state_state_version_check","validated":true},{"ddl":"CHECKtechnique_id=ANYARRAY['001f907c-8f32-4758-8a16-ad1730e72c59'::uuid,'4056f62d-77f3-47f9-8ecb-9a7799682a9d'::uuid,'c11ecd52-43cd-479b-8d5d-08187beba56e'::uuid,'4a527ff2-0420-4da9-bc1f-5489c753b285'::uuid,'8e20bafe-cb3c-4967-b9c7-2a4bca694996'::uuid,'9b384de3-35f0-43c0-b145-94f985fa758a'::uuid,'a50808fa-e7cd-45ee-b4d4-33ad8c65d472'::uuid]ORtechnique_id=ANYARRAY['65b30dec-6f9f-459e-b78c-49173d74f251'::uuid,'f3673da7-42c9-497e-abe1-1c0982429f35'::uuid,'1ab6d359-f337-45ed-839c-4e626d2e2819'::uuid]","name":"combat_state_technique_id_check","validated":true},{"ddl":"FOREIGN KEY (technique_id) REFERENCES public.clan_techniques(id)","name":"combat_state_technique_id_fkey","validated":true}]}},{"name":"public.combat_v2_actors","descriptor":{"acl":"{postgres=arwdDxtm/postgres,service_role=arwdDxtm/postgres}","oid":"30878","rls":true,"kind":"r","name":"public.combat_v2_actors","view":null,"owner":"postgres","columns":[{"name":"id","type":"uuid","default":"gen_random_uuid()","notnull":true},{"name":"session_id","type":"uuid","default":null,"notnull":true},{"name":"actor_kind","type":"text","default":null,"notnull":true},{"name":"character_id","type":"uuid","default":null,"notnull":false},{"name":"png_instance_id","type":"uuid","default":null,"notnull":false},{"name":"controller_user","type":"uuid","default":null,"notnull":false},{"name":"team_key","type":"text","default":null,"notnull":true},{"name":"state","type":"text","default":"'attivo'::text","notnull":true},{"name":"position_m","type":"integer","default":"0","notnull":true},{"name":"initiative_snapshot","type":"integer","default":null,"notnull":true},{"name":"mechanics_snapshot","type":"jsonb","default":null,"notnull":true},{"name":"controller_version","type":"bigint","default":"1","notnull":true},{"name":"created_at","type":"timestamp with time zone","default":"clock_timestamp()","notnull":true},{"name":"provider_instance_v1_id","type":"uuid","default":null,"notnull":false},{"name":"companion_id","type":"uuid","default":null,"notnull":false}],"indexes":[{"ddl":"CREATE INDEX combat_v2_actors_character_idx ON public.combat_v2_actors USING btree (character_id)","name":"public.combat_v2_actors_character_idx"},{"ddl":"CREATE INDEX combat_v2_actors_controller_idx ON public.combat_v2_actors USING btree (session_id, controller_user)","name":"public.combat_v2_actors_controller_idx"},{"ddl":"CREATE UNIQUE INDEX combat_v2_actors_pkey ON public.combat_v2_actors USING btree (id)","name":"public.combat_v2_actors_pkey"},{"ddl":"CREATE INDEX combat_v2_actors_png_instance_idx ON public.combat_v2_actors USING btree (png_instance_id)","name":"public.combat_v2_actors_png_instance_idx"},{"ddl":"CREATE INDEX combat_v2_actors_provider_instance_v1_idx ON public.combat_v2_actors USING btree (provider_instance_v1_id)","name":"public.combat_v2_actors_provider_instance_v1_idx"},{"ddl":"CREATE UNIQUE INDEX combat_v2_actors_session_companion_key ON public.combat_v2_actors USING btree (session_id, companion_id)","name":"public.combat_v2_actors_session_companion_key"},{"ddl":"CREATE UNIQUE INDEX combat_v2_actors_session_id_character_id_key ON public.combat_v2_actors USING btree (session_id, character_id)","name":"public.combat_v2_actors_session_id_character_id_key"},{"ddl":"CREATE UNIQUE INDEX combat_v2_actors_session_id_id_key ON public.combat_v2_actors USING btree (session_id, id)","name":"public.combat_v2_actors_session_id_id_key"},{"ddl":"CREATE UNIQUE INDEX combat_v2_actors_session_id_png_instance_id_key ON public.combat_v2_actors USING btree (session_id, png_instance_id)","name":"public.combat_v2_actors_session_id_png_instance_id_key"},{"ddl":"CREATE UNIQUE INDEX combat_v2_actors_session_provider_v1_key ON public.combat_v2_actors USING btree (session_id, provider_instance_v1_id)","name":"public.combat_v2_actors_session_provider_v1_key"}],"policies":[],"triggers":[{"ddl":"CREATE TRIGGER aburame_actor_end AFTER UPDATE OF state ON public.combat_v2_actors FOR EACH ROW EXECUTE FUNCTION clan_aburame_private.lifecycle()","name":"aburame_actor_end","enabled":"O","function_md5":"5253ea25e74221595839caa71454cc92"},{"ddl":"CREATE TRIGGER aburame_verme_end_actor_v1 AFTER UPDATE OF state ON public.combat_v2_actors FOR EACH ROW EXECUTE FUNCTION clan_aburame_private.verme_end_context_v1()","name":"aburame_verme_end_actor_v1","enabled":"O","function_md5":"8305ad7a81146dae9a9a24566f933c62"},{"ddl":"CREATE TRIGGER combat_gate_v2_actor_engagement BEFORE INSERT ON public.combat_v2_actors FOR EACH ROW EXECUTE FUNCTION combat_gate_private.engagement_insert_guard()","name":"combat_gate_v2_actor_engagement","enabled":"O","function_md5":"28bc96f74f3215a29f5d7c0bd4179668"},{"ddl":"CREATE TRIGGER ehm_continuity_actor_guard BEFORE INSERT OR DELETE OR UPDATE ON public.combat_v2_actors FOR EACH ROW EXECUTE FUNCTION exam_human_private.continuity_session_guard_v1()","name":"ehm_continuity_actor_guard","enabled":"O","function_md5":"952113aad8265aa0cc6ecb47c76711f8"},{"ddl":"CREATE TRIGGER hyuga_sedici_actor_end AFTER UPDATE OF state ON public.combat_v2_actors FOR EACH ROW EXECUTE FUNCTION clan_hyuga_private.sedici_lifecycle()","name":"hyuga_sedici_actor_end","enabled":"O","function_md5":"49ac3dc34e918726db3ef05a2203f78b"},{"ddl":"CREATE TRIGGER mission_academy_prevent_ko BEFORE UPDATE OF mechanics_snapshot, state ON public.combat_v2_actors FOR EACH ROW EXECUTE FUNCTION mission_academy_owner.prevent_ko()","name":"mission_academy_prevent_ko","enabled":"O","function_md5":"951a02380ecbe367665a8ca925f5574d"},{"ddl":"CREATE TRIGGER panel_actor_controller_sync AFTER UPDATE OF controller_user, controller_version ON public.combat_v2_actors FOR EACH ROW EXECUTE FUNCTION combat_panel_private.master_scene_lifecycle_trigger()","name":"panel_actor_controller_sync","enabled":"O","function_md5":"088d456afa8f57ea9e594fc7fcbd5804"},{"ddl":"CREATE TRIGGER panel_actor_entry BEFORE INSERT OR UPDATE OF session_id, actor_kind, character_id, controller_user, companion_id ON public.combat_v2_actors FOR EACH ROW EXECUTE FUNCTION combat_panel_private.master_entry_trigger()","name":"panel_actor_entry","enabled":"O","function_md5":"d4a3102cb9908464cc08be0b263d9d6f"},{"ddl":"CREATE TRIGGER panel_actor_turn_actor AFTER INSERT OR UPDATE OF state ON public.combat_v2_actors FOR EACH ROW EXECUTE FUNCTION combat_panel_private.actor_turn_lifecycle()","name":"panel_actor_turn_actor","enabled":"O","function_md5":"50eebd47ec1b7c58054ac06644974eeb"},{"ddl":"CREATE TRIGGER panel_immobilization_actor_end AFTER UPDATE OF state ON public.combat_v2_actors FOR EACH ROW EXECUTE FUNCTION combat_panel_private.immobilization_actor_lifecycle()","name":"panel_immobilization_actor_end","enabled":"O","function_md5":"f8677e282d09ca9015c01de07391f1bc"},{"ddl":"CREATE TRIGGER panel_multiplication_actor_end AFTER UPDATE OF state, mechanics_snapshot ON public.combat_v2_actors FOR EACH ROW EXECUTE FUNCTION combat_panel_private.multiplication_actor_end()","name":"panel_multiplication_actor_end","enabled":"O","function_md5":"390e5a2262affd6c56270631bdcf6232"},{"ddl":"CREATE TRIGGER riuji_parallel_combat_actor_guard BEFORE INSERT OR UPDATE OF state, character_id, session_id ON public.combat_v2_actors FOR EACH ROW EXECUTE FUNCTION mission_riuji_owner.combat_actor_guard()","name":"riuji_parallel_combat_actor_guard","enabled":"O","function_md5":"cadc0fea465b158223d9e5cc70a73301"},{"ddl":"CREATE TRIGGER sabaku_actor_lifecycle AFTER UPDATE OF state, mechanics_snapshot ON public.combat_v2_actors FOR EACH ROW EXECUTE FUNCTION clan_sabaku_private.actor_lifecycle()","name":"sabaku_actor_lifecycle","enabled":"O","function_md5":"395822d8985049c7e4c3a11c300b6d7f"},{"ddl":"CREATE TRIGGER sabaku_armor_actor_terminal AFTER UPDATE OF state, mechanics_snapshot ON public.combat_v2_actors FOR EACH ROW EXECUTE FUNCTION clan_sabaku_private.armor_actor_terminal()","name":"sabaku_armor_actor_terminal","enabled":"O","function_md5":"2371908f08a459bcaba40a82cf094107"},{"ddl":"CREATE TRIGGER sabaku_clone_actor_end AFTER UPDATE OF state, mechanics_snapshot ON public.combat_v2_actors FOR EACH ROW EXECUTE FUNCTION clan_sabaku_private.clone_lifecycle_trigger()","name":"sabaku_clone_actor_end","enabled":"O","function_md5":"d8187fc67f036ca0cb9a0cfcd5137eed"}],"force_rls":true,"constraints":[{"ddl":"CHECK ((actor_kind = ANY (ARRAY['pg'::text, 'png'::text])))","name":"combat_v2_actors_actor_kind_check","validated":true},{"ddl":"FOREIGN KEY (character_id) REFERENCES public.characters(id) ON DELETE RESTRICT","name":"combat_v2_actors_character_id_fkey","validated":true},{"ddl":"FOREIGN KEY (companion_id) REFERENCES clan_marionettisti_private.sources(id) ON DELETE RESTRICT","name":"combat_v2_actors_companion_id_fkey","validated":true},{"ddl":"CHECK (((actor_kind = 'png'::text) OR (controller_user IS NOT NULL)))","name":"combat_v2_actors_controller_chk","validated":true},{"ddl":"CHECK ((((actor_kind = 'pg'::text) AND (character_id IS NOT NULL) AND (png_instance_id IS NULL) AND (provider_instance_v1_id IS NULL) AND (companion_id IS NULL)) OR ((actor_kind = 'png'::text) AND (character_id IS NULL) AND (num_nonnulls(png_instance_id, provider_instance_v1_id, companion_id) = 1))))","name":"combat_v2_actors_identity_chk","validated":true},{"ddl":"CHECK ((jsonb_typeof(mechanics_snapshot) = 'object'::text))","name":"combat_v2_actors_mechanics_snapshot_check","validated":true},{"ddl":"PRIMARY KEY (id)","name":"combat_v2_actors_pkey","validated":true},{"ddl":"FOREIGN KEY (png_instance_id) REFERENCES public.combat_v2_png_instances(id) ON DELETE RESTRICT","name":"combat_v2_actors_png_instance_id_fkey","validated":true},{"ddl":"CHECK (((position_m >= 0) AND (position_m <= 1000)))","name":"combat_v2_actors_position_m_check","validated":true},{"ddl":"FOREIGN KEY (provider_instance_v1_id) REFERENCES public.combat_v2_provider_instances_v1(id) ON DELETE RESTRICT","name":"combat_v2_actors_provider_instance_v1_fkey","validated":true},{"ddl":"UNIQUE (session_id, companion_id)","name":"combat_v2_actors_session_companion_key","validated":true},{"ddl":"UNIQUE (session_id, character_id)","name":"combat_v2_actors_session_id_character_id_key","validated":true},{"ddl":"FOREIGN KEY (session_id) REFERENCES public.combat_v2_sessions(id) ON DELETE RESTRICT","name":"combat_v2_actors_session_id_fkey","validated":true},{"ddl":"UNIQUE (session_id, id)","name":"combat_v2_actors_session_id_id_key","validated":true},{"ddl":"UNIQUE (session_id, png_instance_id)","name":"combat_v2_actors_session_id_png_instance_id_key","validated":true},{"ddl":"UNIQUE (session_id, provider_instance_v1_id)","name":"combat_v2_actors_session_provider_v1_key","validated":true},{"ddl":"CHECK ((state = ANY (ARRAY['attivo'::text, 'fuori'::text, 'ritirato'::text])))","name":"combat_v2_actors_state_check","validated":true},{"ddl":"CHECK (((char_length(btrim(team_key)) >= 1) AND (char_length(btrim(team_key)) <= 40)))","name":"combat_v2_actors_team_key_check","validated":true}]}},{"name":"public.combat_v2_declarations","descriptor":{"acl":"{postgres=arwdDxtm/postgres,service_role=arwdDxtm/postgres}","oid":"30948","rls":true,"kind":"r","name":"public.combat_v2_declarations","view":null,"owner":"postgres","columns":[{"name":"id","type":"uuid","default":"gen_random_uuid()","notnull":true},{"name":"round_id","type":"uuid","default":null,"notnull":true},{"name":"actor_id","type":"uuid","default":null,"notnull":true},{"name":"kind","type":"text","default":null,"notnull":true},{"name":"parent_attack_id","type":"uuid","default":null,"notnull":false},{"name":"target_actor_id","type":"uuid","default":null,"notnull":false},{"name":"sanitized_intent","type":"jsonb","default":null,"notnull":true},{"name":"declaration_text","type":"text","default":"''::text","notnull":true},{"name":"controller_user_snapshot","type":"uuid","default":null,"notnull":true},{"name":"controller_version_snapshot","type":"bigint","default":null,"notnull":true},{"name":"request_key","type":"uuid","default":null,"notnull":true},{"name":"state","type":"text","default":"'inviata'::text","notnull":true},{"name":"outcome","type":"jsonb","default":null,"notnull":false},{"name":"order_no","type":"integer","default":null,"notnull":false},{"name":"tie_break","type":"bigint","default":null,"notnull":false},{"name":"cost_snapshot","type":"jsonb","default":"'{}'::jsonb","notnull":true},{"name":"created_at","type":"timestamp with time zone","default":"clock_timestamp()","notnull":true},{"name":"frozen_at","type":"timestamp with time zone","default":null,"notnull":false}],"indexes":[{"ddl":"CREATE INDEX combat_v2_declarations_actor_idx ON public.combat_v2_declarations USING btree (actor_id)","name":"public.combat_v2_declarations_actor_idx"},{"ddl":"CREATE UNIQUE INDEX combat_v2_declarations_difesa_idx ON public.combat_v2_declarations USING btree (parent_attack_id, actor_id) WHERE (kind = ANY (ARRAY['difesa'::text, 'nessuna'::text]))","name":"public.combat_v2_declarations_difesa_idx"},{"ddl":"CREATE UNIQUE INDEX combat_v2_declarations_pkey ON public.combat_v2_declarations USING btree (id)","name":"public.combat_v2_declarations_pkey"},{"ddl":"CREATE UNIQUE INDEX combat_v2_declarations_principale_idx ON public.combat_v2_declarations USING btree (round_id, actor_id) WHERE (kind = ANY (ARRAY['attacco'::text, 'movimento'::text, 'utilita'::text, 'passa'::text]))","name":"public.combat_v2_declarations_principale_idx"},{"ddl":"CREATE UNIQUE INDEX combat_v2_declarations_round_id_request_key_key ON public.combat_v2_declarations USING btree (round_id, request_key)","name":"public.combat_v2_declarations_round_id_request_key_key"},{"ddl":"CREATE INDEX combat_v2_declarations_round_order_idx ON public.combat_v2_declarations USING btree (round_id, order_no)","name":"public.combat_v2_declarations_round_order_idx"},{"ddl":"CREATE INDEX combat_v2_declarations_target_idx ON public.combat_v2_declarations USING btree (target_actor_id)","name":"public.combat_v2_declarations_target_idx"}],"policies":[],"triggers":[{"ddl":"CREATE TRIGGER aburame_bind_declaration AFTER INSERT ON public.combat_v2_declarations FOR EACH ROW EXECUTE FUNCTION clan_aburame_private.bind_declaration()","name":"aburame_bind_declaration","enabled":"O","function_md5":"88de13aaa8d8f15547754c11b0f762dc"},{"ddl":"CREATE TRIGGER combat_v2_declarations_multitarget_sync AFTER INSERT ON public.combat_v2_declarations FOR EACH ROW EXECUTE FUNCTION combat_v2_multitarget_internal.sync_declaration()","name":"combat_v2_declarations_multitarget_sync","enabled":"O","function_md5":"b68a55d64864778ee4457ff0c124f729"},{"ddl":"CREATE TRIGGER cure_turn_defense_guard_v1 BEFORE INSERT ON public.combat_v2_declarations FOR EACH ROW EXECUTE FUNCTION combat_panel_private.cure_defense_guard_v1()","name":"cure_turn_defense_guard_v1","enabled":"O","function_md5":"139cfbb96fd7a9bd3cfe0326c3ca8292"},{"ddl":"CREATE TRIGGER ehm_round_declaration_guard BEFORE INSERT ON public.combat_v2_declarations FOR EACH ROW EXECUTE FUNCTION exam_human_private.round_declaration_guard_v1()","name":"ehm_round_declaration_guard","enabled":"O","function_md5":"12d6750967b54533ccf98b2b8f7f3974"},{"ddl":"CREATE CONSTRAINT TRIGGER event42_hint_combat_v2_declarations AFTER INSERT OR DELETE OR UPDATE ON public.combat_v2_declarations DEFERRABLE INITIALLY DEFERRED FOR EACH ROW EXECUTE FUNCTION mission_generic_owner.event_capture_v1('hint')","name":"event42_hint_combat_v2_declarations","enabled":"O","function_md5":"9b0b9bef1a608e974a6bee1e9d288feb"},{"ddl":"CREATE TRIGGER event42_pg_declaration AFTER INSERT ON public.combat_v2_declarations FOR EACH ROW EXECUTE FUNCTION mission_generic_owner.event_capture_v1('ai')","name":"event42_pg_declaration","enabled":"O","function_md5":"9b0b9bef1a608e974a6bee1e9d288feb"},{"ddl":"CREATE TRIGGER facing_completed_action AFTER UPDATE OF state ON public.combat_v2_declarations FOR EACH ROW EXECUTE FUNCTION combat_facing_private.completed_action()","name":"facing_completed_action","enabled":"O","function_md5":"124c1f2318c514378ce3d1d759f1bb9c"},{"ddl":"CREATE TRIGGER marionetta_terminal_event AFTER UPDATE OF state ON public.combat_v2_declarations FOR EACH ROW EXECUTE FUNCTION clan_marionettisti_private.declaration_terminal_trigger()","name":"marionetta_terminal_event","enabled":"O","function_md5":"0c3e1b7ebd7eec9eb55ab36ddc08915c"},{"ddl":"CREATE TRIGGER panel_actor_turn_declaration AFTER INSERT OR UPDATE OF state ON public.combat_v2_declarations FOR EACH ROW EXECUTE FUNCTION combat_panel_private.actor_turn_lifecycle()","name":"panel_actor_turn_declaration","enabled":"O","function_md5":"50eebd47ec1b7c58054ac06644974eeb"},{"ddl":"CREATE TRIGGER panel_declaration_ready BEFORE INSERT OR UPDATE OF round_id, actor_id, kind ON public.combat_v2_declarations FOR EACH ROW EXECUTE FUNCTION combat_panel_private.master_entry_trigger()","name":"panel_declaration_ready","enabled":"O","function_md5":"d4a3102cb9908464cc08be0b263d9d6f"},{"ddl":"CREATE TRIGGER panel_multiplication_assault_end AFTER UPDATE OF state ON public.combat_v2_declarations FOR EACH ROW EXECUTE FUNCTION combat_panel_private.multiplication_assault_end()","name":"panel_multiplication_assault_end","enabled":"O","function_md5":"16ac1cebd0b314a09d07f8e93e764104"},{"ddl":"CREATE TRIGGER panel_multiplication_next_action BEFORE INSERT ON public.combat_v2_declarations FOR EACH ROW EXECUTE FUNCTION combat_panel_private.multiplication_next_action()","name":"panel_multiplication_next_action","enabled":"O","function_md5":"1be8d365734c37dda8de7bf54c694cb8"},{"ddl":"CREATE TRIGGER regia_human_private_declaration_guard_v1 BEFORE INSERT ON public.combat_v2_declarations FOR EACH ROW EXECUTE FUNCTION mission_generic_owner.regia_human_declaration_guard_v1()","name":"regia_human_private_declaration_guard_v1","enabled":"O","function_md5":"fbb2af1f53dc44eccb448b88d9db8839"},{"ddl":"CREATE TRIGGER regia_round_declaration_revision_v1 AFTER INSERT OR UPDATE OF sanitized_intent, target_actor_id, declaration_text ON public.combat_v2_declarations FOR EACH ROW EXECUTE FUNCTION exam_human_private.round_publication_revision_bump_v1()","name":"regia_round_declaration_revision_v1","enabled":"O","function_md5":"e1fc682dbc655327408f79fbcf11a2e2"},{"ddl":"CREATE TRIGGER sabaku_master_main BEFORE INSERT ON public.combat_v2_declarations FOR EACH ROW EXECUTE FUNCTION clan_sabaku_private.master_turn_lifecycle()","name":"sabaku_master_main","enabled":"O","function_md5":"2b497ca1230e6642f49d9e65df2ed86b"},{"ddl":"CREATE TRIGGER shuriken_qa_declaration_guard BEFORE INSERT ON public.combat_v2_declarations FOR EACH ROW EXECUTE FUNCTION combat_panel_private.shuriken_qa_declaration_guard_v1()","name":"shuriken_qa_declaration_guard","enabled":"O","function_md5":"b87c0e84252a083ebf72051e34bc0078"},{"ddl":"CREATE TRIGGER zz_innata_chat_tags_snapshot BEFORE INSERT ON public.combat_v2_declarations FOR EACH ROW EXECUTE FUNCTION clan_innata_private.freeze_chat_tags()","name":"zz_innata_chat_tags_snapshot","enabled":"O","function_md5":"30ddee68343d405a201ffb237b965cff"},{"ddl":"CREATE TRIGGER zz_marionetta_staff_sever BEFORE INSERT ON public.combat_v2_declarations FOR EACH ROW WHEN ((new.kind = 'attacco'::text)) EXECUTE FUNCTION clan_marionettisti_private.staff_sever_declaration_v1()","name":"zz_marionetta_staff_sever","enabled":"D","function_md5":"b90160271b98f7039cd2fc46756efea8"},{"ddl":"CREATE TRIGGER zz_marionetta_staff_sever_capture AFTER INSERT ON public.combat_v2_declarations FOR EACH ROW WHEN (((new.sanitized_intent #>> '{server_ability,link_control_traits,staff_simulated}'::text[]) = 'true'::text)) EXECUTE FUNCTION clan_marionettisti_private.staff_sever_capture_v1()","name":"zz_marionetta_staff_sever_capture","enabled":"O","function_md5":"d2c073dbc65945d8bfd7de36563eda9d"}],"force_rls":true,"constraints":[{"ddl":"FOREIGN KEY (actor_id) REFERENCES public.combat_v2_actors(id) ON DELETE RESTRICT","name":"combat_v2_declarations_actor_id_fkey","validated":true},{"ddl":"CHECK ((jsonb_typeof(cost_snapshot) = 'object'::text))","name":"combat_v2_declarations_cost_snapshot_check","validated":true},{"ddl":"CHECK ((char_length(declaration_text) <= 5000))","name":"combat_v2_declarations_declaration_text_check","validated":true},{"ddl":"CHECK ((kind = ANY (ARRAY['attacco'::text, 'difesa'::text, 'movimento'::text, 'utilita'::text, 'passa'::text, 'nessuna'::text])))","name":"combat_v2_declarations_kind_check","validated":true},{"ddl":"FOREIGN KEY (parent_attack_id) REFERENCES public.combat_v2_declarations(id) ON DELETE RESTRICT","name":"combat_v2_declarations_parent_attack_id_fkey","validated":true},{"ddl":"CHECK (((kind = ANY (ARRAY['difesa'::text, 'nessuna'::text])) = (parent_attack_id IS NOT NULL)))","name":"combat_v2_declarations_parent_chk","validated":true},{"ddl":"PRIMARY KEY (id)","name":"combat_v2_declarations_pkey","validated":true},{"ddl":"FOREIGN KEY (round_id) REFERENCES public.combat_v2_rounds(id) ON DELETE RESTRICT","name":"combat_v2_declarations_round_id_fkey","validated":true},{"ddl":"UNIQUE (round_id, request_key)","name":"combat_v2_declarations_round_id_request_key_key","validated":true},{"ddl":"CHECK ((jsonb_typeof(sanitized_intent) = 'object'::text))","name":"combat_v2_declarations_sanitized_intent_check","validated":true},{"ddl":"CHECK ((state = ANY (ARRAY['bozza_server'::text, 'inviata'::text, 'congelata'::text, 'risolta'::text, 'superflua'::text])))","name":"combat_v2_declarations_state_check","validated":true},{"ddl":"FOREIGN KEY (target_actor_id) REFERENCES public.combat_v2_actors(id) ON DELETE RESTRICT","name":"combat_v2_declarations_target_actor_id_fkey","validated":true},{"ddl":"CHECK (((kind <> 'attacco'::text) OR (target_actor_id IS NOT NULL)))","name":"combat_v2_declarations_target_chk","validated":true},{"ddl":"TRIGGER DEFERRABLE INITIALLY DEFERRED","name":"event42_hint_combat_v2_declarations","validated":true}]}},{"name":"public.combat_v2_sessions","descriptor":{"acl":"{postgres=arwdDxtm/postgres,service_role=arwdDxtm/postgres}","oid":"30825","rls":true,"kind":"r","name":"public.combat_v2_sessions","view":null,"owner":"postgres","columns":[{"name":"id","type":"uuid","default":"gen_random_uuid()","notnull":true},{"name":"source_kind","type":"text","default":null,"notnull":true},{"name":"master_session_id","type":"uuid","default":null,"notnull":false},{"name":"location_id","type":"uuid","default":null,"notnull":true},{"name":"state","type":"text","default":"'preparazione'::text","notnull":true},{"name":"state_before_suspend","type":"text","default":null,"notnull":false},{"name":"engine_version","type":"text","default":"'combat-v2/2.0.0'::text","notnull":true},{"name":"resolver_version","type":"text","default":"'v11-parity/1'::text","notnull":true},{"name":"lesiva","type":"boolean","default":"false","notnull":true},{"name":"created_at","type":"timestamp with time zone","default":"clock_timestamp()","notnull":true},{"name":"closed_at","type":"timestamp with time zone","default":null,"notnull":false},{"name":"user_test_context_id","type":"uuid","default":null,"notnull":false}],"indexes":[{"ddl":"CREATE INDEX combat_v2_sessions_master_idx ON public.combat_v2_sessions USING btree (master_session_id)","name":"public.combat_v2_sessions_master_idx"},{"ddl":"CREATE UNIQUE INDEX combat_v2_sessions_pkey ON public.combat_v2_sessions USING btree (id)","name":"public.combat_v2_sessions_pkey"},{"ddl":"CREATE UNIQUE INDEX combat_v2_sessions_unica_luogo_idx ON public.combat_v2_sessions USING btree (location_id) WHERE ((state <> ALL (ARRAY['chiuso'::text, 'annullato'::text])) AND (user_test_context_id IS NULL))","name":"public.combat_v2_sessions_unica_luogo_idx"},{"ddl":"CREATE UNIQUE INDEX user_test_session_binding_unique ON public.combat_v2_sessions USING btree (user_test_context_id) WHERE (user_test_context_id IS NOT NULL)","name":"public.user_test_session_binding_unique"}],"policies":[],"triggers":[{"ddl":"CREATE TRIGGER aburame_session_end AFTER UPDATE OF state, closed_at ON public.combat_v2_sessions FOR EACH ROW EXECUTE FUNCTION clan_aburame_private.lifecycle()","name":"aburame_session_end","enabled":"O","function_md5":"5253ea25e74221595839caa71454cc92"},{"ddl":"CREATE TRIGGER aburame_verme_end_session_v1 AFTER UPDATE OF state, closed_at ON public.combat_v2_sessions FOR EACH ROW EXECUTE FUNCTION clan_aburame_private.verme_end_context_v1()","name":"aburame_verme_end_session_v1","enabled":"O","function_md5":"8305ad7a81146dae9a9a24566f933c62"},{"ddl":"CREATE TRIGGER combat_gate_v2_claim BEFORE INSERT OR UPDATE OF state, location_id, source_kind, master_session_id ON public.combat_v2_sessions FOR EACH ROW EXECUTE FUNCTION combat_gate_private.v2_claim_trigger()","name":"combat_gate_v2_claim","enabled":"O","function_md5":"d1d386dc90cceb83d49ab2b24b97876e"},{"ddl":"CREATE TRIGGER ehm_continuity_session_guard BEFORE INSERT OR UPDATE ON public.combat_v2_sessions FOR EACH ROW EXECUTE FUNCTION exam_human_private.continuity_session_guard_v1()","name":"ehm_continuity_session_guard","enabled":"O","function_md5":"952113aad8265aa0cc6ecb47c76711f8"},{"ddl":"CREATE TRIGGER exam_human_no_uncomposed_encounter BEFORE INSERT OR UPDATE OF master_session_id ON public.combat_v2_sessions FOR EACH ROW EXECUTE FUNCTION exam_human_private.native_lifecycle_guard_v1()","name":"exam_human_no_uncomposed_encounter","enabled":"O","function_md5":"6b96e5306bc421a9a6cc3baabfaaa0fb"},{"ddl":"CREATE TRIGGER hyuga_sedici_session_end AFTER UPDATE OF state, closed_at ON public.combat_v2_sessions FOR EACH ROW EXECUTE FUNCTION clan_hyuga_private.sedici_lifecycle()","name":"hyuga_sedici_session_end","enabled":"O","function_md5":"49ac3dc34e918726db3ef05a2203f78b"},{"ddl":"CREATE TRIGGER inuzuka_session_close AFTER UPDATE OF state ON public.combat_v2_sessions FOR EACH ROW EXECUTE FUNCTION clan_inuzuka_private.session_close_trigger()","name":"inuzuka_session_close","enabled":"O","function_md5":"f9569aeb2d3a3256548d713d621c9898"},{"ddl":"CREATE TRIGGER ordinary_narrative_no_second_encounter BEFORE INSERT OR UPDATE OF master_session_id ON public.combat_v2_sessions FOR EACH ROW EXECUTE FUNCTION combat_consumer_private.no_second_encounter()","name":"ordinary_narrative_no_second_encounter","enabled":"O","function_md5":"fac69f481e1787099b1758e0b35c7f8a"},{"ddl":"CREATE TRIGGER panel_encounter_entry AFTER INSERT OR UPDATE OF source_kind, master_session_id, location_id, lesiva ON public.combat_v2_sessions FOR EACH ROW EXECUTE FUNCTION combat_panel_private.master_entry_trigger()","name":"panel_encounter_entry","enabled":"O","function_md5":"d4a3102cb9908464cc08be0b263d9d6f"},{"ddl":"CREATE TRIGGER panel_encounter_terminal_sync AFTER UPDATE OF state, closed_at ON public.combat_v2_sessions FOR EACH ROW EXECUTE FUNCTION combat_panel_private.master_scene_lifecycle_trigger()","name":"panel_encounter_terminal_sync","enabled":"O","function_md5":"088d456afa8f57ea9e594fc7fcbd5804"},{"ddl":"CREATE TRIGGER panel_immobilization_session_end AFTER UPDATE OF state ON public.combat_v2_sessions FOR EACH ROW EXECUTE FUNCTION combat_panel_private.immobilization_session_lifecycle()","name":"panel_immobilization_session_end","enabled":"O","function_md5":"38bc9bc060bc1af88cf087f5e4a687bb"},{"ddl":"CREATE TRIGGER panel_multiplication_combat_end AFTER UPDATE OF state, closed_at ON public.combat_v2_sessions FOR EACH ROW EXECUTE FUNCTION combat_panel_private.multiplication_combat_end()","name":"panel_multiplication_combat_end","enabled":"O","function_md5":"83c3a56e1b4b1b9a49f7008d9d8e3591"},{"ddl":"CREATE TRIGGER quest_ai_native_combat_insert BEFORE INSERT ON public.combat_v2_sessions FOR EACH ROW EXECUTE FUNCTION mission_factory_owner.quest_combat_insert_guard_v1()","name":"quest_ai_native_combat_insert","enabled":"O","function_md5":"dccee1ffa367f56a23246e547578d888"},{"ddl":"CREATE TRIGGER quest_ai_native_combat_update BEFORE UPDATE OF master_session_id, source_kind, location_id, lesiva, state ON public.combat_v2_sessions FOR EACH ROW EXECUTE FUNCTION mission_factory_owner.quest_combat_insert_guard_v1()","name":"quest_ai_native_combat_update","enabled":"O","function_md5":"dccee1ffa367f56a23246e547578d888"},{"ddl":"CREATE TRIGGER sabaku_armor_session_terminal AFTER UPDATE OF state, closed_at ON public.combat_v2_sessions FOR EACH ROW EXECUTE FUNCTION clan_sabaku_private.armor_session_terminal()","name":"sabaku_armor_session_terminal","enabled":"O","function_md5":"f94210c8254eb9f4bc1da46a40465427"},{"ddl":"CREATE TRIGGER sabaku_clone_session_end AFTER UPDATE OF state, closed_at ON public.combat_v2_sessions FOR EACH ROW EXECUTE FUNCTION clan_sabaku_private.clone_lifecycle_trigger()","name":"sabaku_clone_session_end","enabled":"O","function_md5":"d8187fc67f036ca0cb9a0cfcd5137eed"},{"ddl":"CREATE TRIGGER user_test_native_binding BEFORE INSERT OR UPDATE ON public.combat_v2_sessions FOR EACH ROW EXECUTE FUNCTION user_testroom_common_private.propagate_context()","name":"user_test_native_binding","enabled":"O","function_md5":"a8d38263f2f5f7c58a3f1a69aee24ed6"}],"force_rls":true,"constraints":[{"ddl":"FOREIGN KEY (location_id) REFERENCES public.locations(id) ON DELETE RESTRICT","name":"combat_v2_sessions_location_id_fkey","validated":true},{"ddl":"FOREIGN KEY (master_session_id) REFERENCES public.master_v2_sessions(id) ON DELETE RESTRICT","name":"combat_v2_sessions_master_session_id_fkey","validated":true},{"ddl":"PRIMARY KEY (id)","name":"combat_v2_sessions_pkey","validated":true},{"ddl":"CHECK (((source_kind = 'master'::text) = (master_session_id IS NOT NULL)))","name":"combat_v2_sessions_source_chk","validated":true},{"ddl":"CHECK ((source_kind = ANY (ARRAY['ordinary'::text, 'master'::text])))","name":"combat_v2_sessions_source_kind_check","validated":true},{"ddl":"CHECK ((state = ANY (ARRAY['preparazione'::text, 'in_corso'::text, 'sospeso'::text, 'risolto'::text, 'chiuso'::text, 'annullato'::text])))","name":"combat_v2_sessions_state_check","validated":true},{"ddl":"CHECK (((state <> ALL (ARRAY['chiuso'::text, 'annullato'::text])) OR (closed_at IS NOT NULL)))","name":"combat_v2_sessions_terminale_chk","validated":true},{"ddl":"FOREIGN KEY (user_test_context_id) REFERENCES user_testroom_common_private.contexts(id)","name":"combat_v2_sessions_user_test_context_id_fkey","validated":true}]}},{"name":"public.master_v2_sessions","descriptor":{"acl":"{postgres=arwdDxtm/postgres,service_role=arwdDxtm/postgres}","oid":"30691","rls":true,"kind":"r","name":"public.master_v2_sessions","view":null,"owner":"postgres","columns":[{"name":"id","type":"uuid","default":"gen_random_uuid()","notnull":true},{"name":"location_id","type":"uuid","default":null,"notnull":true},{"name":"tipo","type":"text","default":null,"notnull":true},{"name":"stato","type":"text","default":"'preparazione'::text","notnull":true},{"name":"master_user","type":"uuid","default":null,"notnull":false},{"name":"control_version","type":"bigint","default":"1","notnull":true},{"name":"mission_id","type":"uuid","default":null,"notnull":false},{"name":"titolo","type":"text","default":null,"notnull":true},{"name":"stato_pre_sospensione","type":"text","default":null,"notnull":false},{"name":"created_at","type":"timestamp with time zone","default":"clock_timestamp()","notnull":true},{"name":"suspended_at","type":"timestamp with time zone","default":null,"notnull":false},{"name":"closed_at","type":"timestamp with time zone","default":null,"notnull":false},{"name":"close_reason","type":"text","default":null,"notnull":false},{"name":"quest_kind","type":"text","default":null,"notnull":false},{"name":"owner_kind","type":"text","default":"'human'::text","notnull":true}],"indexes":[{"ddl":"CREATE UNIQUE INDEX master_v2_sessions_id_mission_id_key ON public.master_v2_sessions USING btree (id, mission_id)","name":"public.master_v2_sessions_id_mission_id_key"},{"ddl":"CREATE INDEX master_v2_sessions_master_stato_idx ON public.master_v2_sessions USING btree (master_user, stato)","name":"public.master_v2_sessions_master_stato_idx"},{"ddl":"CREATE INDEX master_v2_sessions_missione_idx ON public.master_v2_sessions USING btree (mission_id) WHERE (mission_id IS NOT NULL)","name":"public.master_v2_sessions_missione_idx"},{"ddl":"CREATE UNIQUE INDEX master_v2_sessions_pkey ON public.master_v2_sessions USING btree (id)","name":"public.master_v2_sessions_pkey"},{"ddl":"CREATE UNIQUE INDEX master_v2_sessions_unica_luogo_idx ON public.master_v2_sessions USING btree (location_id) WHERE (stato <> ALL (ARRAY['chiusa'::text, 'annullata'::text]))","name":"public.master_v2_sessions_unica_luogo_idx"}],"policies":[],"triggers":[{"ddl":"CREATE TRIGGER aa_universal_arena_freeze AFTER INSERT ON public.master_v2_sessions FOR EACH ROW EXECUTE FUNCTION combat_panel_private.universal_arena_freeze()","name":"aa_universal_arena_freeze","enabled":"O","function_md5":"cee37e6572a8d549167aff3b4d9be0cd"},{"ddl":"CREATE TRIGGER combat_gate_master_claim BEFORE INSERT OR UPDATE OF stato, location_id ON public.master_v2_sessions FOR EACH ROW EXECUTE FUNCTION combat_gate_private.master_claim_trigger()","name":"combat_gate_master_claim","enabled":"O","function_md5":"9813c9aa62b7e0ab16e8ec5d4f4ae309"},{"ddl":"CREATE CONSTRAINT TRIGGER event42_hint_master_v2_sessions AFTER INSERT OR DELETE OR UPDATE ON public.master_v2_sessions DEFERRABLE INITIALLY DEFERRED FOR EACH ROW EXECUTE FUNCTION mission_generic_owner.event_capture_v1('hint')","name":"event42_hint_master_v2_sessions","enabled":"O","function_md5":"9b0b9bef1a608e974a6bee1e9d288feb"},{"ddl":"CREATE TRIGGER exam_human_native_lifecycle BEFORE DELETE OR UPDATE ON public.master_v2_sessions FOR EACH ROW EXECUTE FUNCTION exam_human_private.native_lifecycle_guard_v1()","name":"exam_human_native_lifecycle","enabled":"O","function_md5":"6b96e5306bc421a9a6cc3baabfaaa0fb"},{"ddl":"CREATE TRIGGER ordinary_narrative_master_binding_guard BEFORE UPDATE OF master_user, owner_kind, tipo, mission_id, quest_kind ON public.master_v2_sessions FOR EACH ROW EXECUTE FUNCTION combat_consumer_private.guard_narrative_master_binding()","name":"ordinary_narrative_master_binding_guard","enabled":"O","function_md5":"52c8b437c69acc73ecfe0cda9250e7ce"},{"ddl":"CREATE TRIGGER panel_actor_turn_close AFTER UPDATE OF stato ON public.master_v2_sessions FOR EACH ROW EXECUTE FUNCTION combat_panel_private.actor_turn_lifecycle()","name":"panel_actor_turn_close","enabled":"O","function_md5":"50eebd47ec1b7c58054ac06644974eeb"},{"ddl":"CREATE TRIGGER panel_master_authority_sync AFTER UPDATE OF master_user, control_version, stato, closed_at ON public.master_v2_sessions FOR EACH ROW EXECUTE FUNCTION combat_panel_private.master_scene_lifecycle_trigger()","name":"panel_master_authority_sync","enabled":"O","function_md5":"088d456afa8f57ea9e594fc7fcbd5804"},{"ddl":"CREATE TRIGGER panel_master_entry AFTER INSERT OR UPDATE OF location_id, mission_id, owner_kind, master_user ON public.master_v2_sessions FOR EACH ROW EXECUTE FUNCTION combat_panel_private.master_entry_trigger()","name":"panel_master_entry","enabled":"O","function_md5":"d4a3102cb9908464cc08be0b263d9d6f"},{"ddl":"CREATE TRIGGER shuriken_qa_no_master_scene BEFORE INSERT OR UPDATE OF location_id ON public.master_v2_sessions FOR EACH ROW EXECUTE FUNCTION combat_panel_private.shuriken_qa_reject_other_scene_v1()","name":"shuriken_qa_no_master_scene","enabled":"O","function_md5":"e2af1618fa9c95badfe6a95da52d6bb1"},{"ddl":"CREATE TRIGGER universal_arena_source_immutable BEFORE UPDATE OF location_id, mission_id ON public.master_v2_sessions FOR EACH ROW EXECUTE FUNCTION combat_panel_private.universal_arena_identity_guard()","name":"universal_arena_source_immutable","enabled":"O","function_md5":"d67e3f898e3fbfca6103d4dde08ae2e9"}],"force_rls":true,"constraints":[{"ddl":"TRIGGER DEFERRABLE INITIALLY DEFERRED","name":"event42_hint_master_v2_sessions","validated":true},{"ddl":"CHECK ((control_version >= 1))","name":"master_v2_sessions_control_version_check","validated":true},{"ddl":"UNIQUE (id, mission_id)","name":"master_v2_sessions_id_mission_id_key","validated":true},{"ddl":"FOREIGN KEY (location_id) REFERENCES public.locations(id) ON DELETE RESTRICT","name":"master_v2_sessions_location_id_fkey","validated":true},{"ddl":"CHECK ((((owner_kind = 'human'::text) AND (master_user IS NOT NULL)) OR ((owner_kind = 'ai_service'::text) AND (master_user IS NULL))))","name":"master_v2_sessions_master_chk","validated":true},{"ddl":"FOREIGN KEY (master_user) REFERENCES public.profiles(id) ON DELETE RESTRICT","name":"master_v2_sessions_master_user_fkey","validated":true},{"ddl":"FOREIGN KEY (mission_id) REFERENCES public.missions(id) ON DELETE RESTRICT","name":"master_v2_sessions_mission_id_fkey","validated":true},{"ddl":"CHECK ((((tipo = 'duello'::text) AND (mission_id IS NULL) AND (quest_kind IS NULL)) OR ((tipo = 'quest'::text) AND (((mission_id IS NOT NULL) AND (quest_kind IS NULL)) OR ((mission_id IS NULL) AND (quest_kind IS NOT NULL))))))","name":"master_v2_sessions_missione_chk","validated":true},{"ddl":"CHECK ((owner_kind = ANY (ARRAY['human'::text, 'ai_service'::text])))","name":"master_v2_sessions_owner_kind_chk","validated":true},{"ddl":"PRIMARY KEY (id)","name":"master_v2_sessions_pkey","validated":true},{"ddl":"CHECK (((quest_kind IS NULL) OR (quest_kind = ANY (ARRAY['one_shot'::text, 'trama'::text]))))","name":"master_v2_sessions_quest_kind_chk","validated":true},{"ddl":"CHECK ((stato = ANY (ARRAY['preparazione'::text, 'in_corso'::text, 'sospesa'::text, 'chiusura'::text, 'chiusa'::text, 'annullata'::text])))","name":"master_v2_sessions_stato_check","validated":true},{"ddl":"CHECK (((stato = ANY (ARRAY['chiusa'::text, 'annullata'::text])) = (closed_at IS NOT NULL)))","name":"master_v2_sessions_terminale_chk","validated":true},{"ddl":"CHECK ((tipo = ANY (ARRAY['duello'::text, 'quest'::text])))","name":"master_v2_sessions_tipo_check","validated":true},{"ddl":"CHECK (((char_length(btrim(titolo)) >= 2) AND (char_length(btrim(titolo)) <= 120)))","name":"master_v2_sessions_titolo_check","validated":true}]}}]$velo_rel_shapes$::jsonb) AS e(name text,descriptor jsonb)
 LEFT JOIN relations r ON r.name=e.name
 WHERE to_jsonb(r) IS DISTINCT FROM e.descriptor
 ) THEN RAISE EXCEPTION 'VELO_BEFORE_RELATION_SHAPE_DRIFT'; END IF;
 

 SELECT * INTO STRICT prior_release FROM mission_public_owner.release_admissions_v1 WHERE release_sha256='0fb538733f7010d36babf42f2ffa69432b16b8baa1e9bdea6d0b4ff6d447ae8d' FOR SHARE;
 SELECT * INTO STRICT prior_qualification FROM mission_public_owner.public_qualification_attestations_v1 WHERE release_sha256='0fb538733f7010d36babf42f2ffa69432b16b8baa1e9bdea6d0b4ff6d447ae8d' FOR SHARE;
 IF prior_release.edge_sha256 IS DISTINCT FROM generic_ezbr
 OR public.combat_v2_sha256(to_jsonb(prior_release)) IS DISTINCT FROM '603b6304eab7f53e87862df3b847ffc82aedda02f6841037752eeb2d68ed54cf'
 OR public.combat_v2_sha256(to_jsonb(prior_qualification)) IS DISTINCT FROM '9110bf5dad2ac135d8ef4edccd1655358e76b1acf63e70dc95b62f3f8a55e6f0'
 OR public.combat_v2_sha256(prior_qualification.payload->'capabilities') IS DISTINCT FROM '49fe134f561273f28e8071b63c45886341371b67d028f06e6b7d8f8d4108e817'
 OR (SELECT count(*) FROM mission_public_owner.mission_content_admissions_v1 c WHERE c.engine_release_sha256='0fb538733f7010d36babf42f2ffa69432b16b8baa1e9bdea6d0b4ff6d447ae8d') IS DISTINCT FROM 2::bigint
 OR (SELECT public.combat_v2_sha256(jsonb_agg(to_jsonb(c) ORDER BY c.mission_id,c.request_key))
     FROM mission_public_owner.mission_content_admissions_v1 c WHERE c.engine_release_sha256='0fb538733f7010d36babf42f2ffa69432b16b8baa1e9bdea6d0b4ff6d447ae8d')
    IS DISTINCT FROM '474eaa2ff3a9b7c7d9e399c13325a8b798d61ac8dc1d3659851fa66665e9880a'
 OR (SELECT count(DISTINCT e.profile_key) FROM mission_public_owner.engine_profile_events_v1 e WHERE e.engine_release_sha256='0fb538733f7010d36babf42f2ffa69432b16b8baa1e9bdea6d0b4ff6d447ae8d') IS DISTINCT FROM 1::bigint
 OR (SELECT public.combat_v2_sha256(jsonb_agg(to_jsonb(e) ORDER BY e.profile_key))
     FROM (SELECT DISTINCT ON (z.profile_key) * FROM mission_public_owner.engine_profile_events_v1 z
           WHERE z.engine_release_sha256='0fb538733f7010d36babf42f2ffa69432b16b8baa1e9bdea6d0b4ff6d447ae8d' ORDER BY z.profile_key,z.control_version DESC) AS e)
   IS DISTINCT FROM '0f56704fdb068f91d9ac0883ca92b900677d13cf105a3cd0e581177a4b3cd450' THEN
  RAISE EXCEPTION 'VELO_EXISTING_MISSION_EVIDENCE_DRIFT';
 END IF;


 IF mission_public_owner.engine_qualification_v1('0fb538733f7010d36babf42f2ffa69432b16b8baa1e9bdea6d0b4ff6d447ae8d',true) IS NULL
  OR (SELECT count(*) FROM mission_public_owner.mission_content_admissions_v1 c
      WHERE c.engine_release_sha256='0fb538733f7010d36babf42f2ffa69432b16b8baa1e9bdea6d0b4ff6d447ae8d'
       AND mission_public_owner.content_admission_v1(c.mission_id,'0fb538733f7010d36babf42f2ffa69432b16b8baa1e9bdea6d0b4ff6d447ae8d',c.publication_request,true) IS NOT NULL)
     IS DISTINCT FROM 2::bigint THEN RAISE EXCEPTION 'VELO_RETAINED_MISSIONS_NOT_QUALIFIED'; END IF;

 IF public.combat_v2_sha256(mission_public_owner.engine_qualification_v1('0fb538733f7010d36babf42f2ffa69432b16b8baa1e9bdea6d0b4ff6d447ae8d',true)) IS DISTINCT FROM 'f5e8e73851bfc6c552e324d0445b7409437423da553077bd47e5cfe3caa8c821'
 OR (SELECT to_jsonb(x) FROM mission_public_owner.party_launch_runtime_v1 x WHERE x.singleton) IS DISTINCT FROM $velo_runtime${"singleton":true,"staff_enabled":true,"public_enabled":true,"release_sha256":"0fb538733f7010d36babf42f2ffa69432b16b8baa1e9bdea6d0b4ff6d447ae8d"}$velo_runtime$::jsonb THEN
  RAISE EXCEPTION 'VELO_FORWARD_EFFECTIVE_CAPABILITY_DRIFT';
 END IF;
END
$velo_pre$;

DO $velo_store_projection$
DECLARE selected_root text;
BEGIN

WITH base AS MATERIALIZED (
  SELECT canonical_preimage old_text, canonical_preimage::jsonb r,revision_sha256 old_root
  FROM mission_factory_owner.editor_release_readiness WHERE singleton
), f0 AS MATERIALIZED (
  SELECT (SELECT public.combat_v2_sha256((SELECT jsonb_agg((e.abi||jsonb_build_object('source_md5',e.source_md5,'ddl_md5',e.ddl_md5)) ORDER BY e.signature)
  FROM jsonb_to_recordset($velo_shared_meta$[{"oid":"42942","signature":"combat_consumer_private.narrative_context(uuid)","source_md5":"84031451f48f40639d7f2a1fe8e957d3","ddl_md5":"3f67e976ddab257ce59ec1785a0365fb","abi":{"acl":"{postgres=X/postgres}","oid":"42942","kind":"f","owner":"postgres","config":["search_path=\"\""],"secdef":true,"strict":false,"nspname":"combat_consumer_private","proname":"narrative_context","returns":"jsonb","language":"plpgsql","parallel":"u","arg_modes":null,"arg_names":["p_round"],"arg_types":"2950","leakproof":false,"signature":"combat_consumer_private.narrative_context(uuid)","volatility":"s"}},{"oid":"46723","signature":"combat_consumer_private.narrative_declaration_supported(uuid)","source_md5":"1ed7184037cedfef9d606dfd7090e7a4","ddl_md5":"9d2cad68a149da7f97c177bcf51d73c0","abi":{"acl":"{postgres=X/postgres}","oid":"46723","kind":"f","owner":"postgres","config":["search_path=\"\""],"secdef":true,"strict":false,"nspname":"combat_consumer_private","proname":"narrative_declaration_supported","returns":"boolean","language":"plpgsql","parallel":"u","arg_modes":null,"arg_names":["p_declaration"],"arg_types":"2950","leakproof":false,"signature":"combat_consumer_private.narrative_declaration_supported(uuid)","volatility":"s"}},{"oid":"42968","signature":"combat_consumer_private.validate_narrative_result(jsonb)","source_md5":"6664101fcd222bd583e9ae8cf7b2b7fc","ddl_md5":"097d6805ce2b21e21fc9aa7fe2a5a9ca","abi":{"acl":"{postgres=X/postgres}","oid":"42968","kind":"f","owner":"postgres","config":["search_path=\"\""],"secdef":false,"strict":false,"nspname":"combat_consumer_private","proname":"validate_narrative_result","returns":"void","language":"plpgsql","parallel":"u","arg_modes":null,"arg_names":["p"],"arg_types":"3802","leakproof":false,"signature":"combat_consumer_private.validate_narrative_result(jsonb)","volatility":"i"}},{"oid":"52137","signature":"combat_effects_private.lifecycle_before_report(uuid)","source_md5":"bc4009af6a274d51e6b96fc51f7a7a78","ddl_md5":"ee929b8e4bb4efcd584e7755aa5df682","abi":{"acl":"{postgres=X/postgres}","oid":"52137","kind":"f","owner":"postgres","config":["search_path=\"\""],"secdef":true,"strict":false,"nspname":"combat_effects_private","proname":"lifecycle_before_report","returns":"jsonb","language":"plpgsql","parallel":"u","arg_modes":null,"arg_names":["p_round"],"arg_types":"2950","leakproof":false,"signature":"combat_effects_private.lifecycle_before_report(uuid)","volatility":"v"}},{"oid":"52136","signature":"combat_effects_private.lifecycle_main_end(uuid)","source_md5":"a1948e8ce4fc505fc23e4e4089958507","ddl_md5":"0b743c53cb23a3402542468dc3096430","abi":{"acl":"{postgres=X/postgres}","oid":"52136","kind":"f","owner":"postgres","config":["search_path=\"\""],"secdef":true,"strict":false,"nspname":"combat_effects_private","proname":"lifecycle_main_end","returns":"jsonb","language":"plpgsql","parallel":"u","arg_modes":null,"arg_names":["p_declaration"],"arg_types":"2950","leakproof":false,"signature":"combat_effects_private.lifecycle_main_end(uuid)","volatility":"v"}},{"oid":"52133","signature":"combat_effects_private.lifecycle_open(uuid,uuid)","source_md5":"25b975033c044147b540a6e6492f1b85","ddl_md5":"531b5e14f873e40a1b5042f40ea1b15d","abi":{"acl":"{postgres=X/postgres}","oid":"52133","kind":"f","owner":"postgres","config":["search_path=\"\""],"secdef":true,"strict":false,"nspname":"combat_effects_private","proname":"lifecycle_open","returns":"void","language":"plpgsql","parallel":"u","arg_modes":null,"arg_names":["p_session","p_actor"],"arg_types":"2950 2950","leakproof":false,"signature":"combat_effects_private.lifecycle_open(uuid,uuid)","volatility":"v"}},{"oid":"51910","signature":"combat_effects_private.personal_turn_end(uuid,uuid,uuid,text)","source_md5":"29f0a8df88c6bed279f650d49a706699","ddl_md5":"9e8138c513fa0c8824ca9c5d48aa3d54","abi":{"acl":"{postgres=X/postgres}","oid":"51910","kind":"f","owner":"postgres","config":["search_path=\"\""],"secdef":true,"strict":false,"nspname":"combat_effects_private","proname":"personal_turn_end","returns":"jsonb","language":"plpgsql","parallel":"u","arg_modes":null,"arg_names":["p_session","p_actor","p_turn","p_adapter"],"arg_types":"2950 2950 2950 25","leakproof":false,"signature":"combat_effects_private.personal_turn_end(uuid,uuid,uuid,text)","volatility":"v"}},{"oid":"51906","signature":"combat_effects_private.personal_turn_start(uuid,uuid,uuid,text)","source_md5":"e7ec43224a4640d00c53bad72ac0132d","ddl_md5":"d023d8a651a5e8ef8fdb1cc834b93391","abi":{"acl":"{postgres=X/postgres}","oid":"51906","kind":"f","owner":"postgres","config":["search_path=\"\""],"secdef":true,"strict":false,"nspname":"combat_effects_private","proname":"personal_turn_start","returns":"void","language":"plpgsql","parallel":"u","arg_modes":null,"arg_names":["p_session","p_actor","p_turn","p_adapter"],"arg_types":"2950 2950 2950 25","leakproof":false,"signature":"combat_effects_private.personal_turn_start(uuid,uuid,uuid,text)","volatility":"v"}},{"oid":"44942","signature":"combat_panel_private.commit_master_actor(jsonb)","source_md5":"0c39121bcbd32a49608e4d925560ba41","ddl_md5":"b531bb7f50d4346a09e822b2f2e95144","abi":{"acl":"{postgres=X/postgres}","oid":"44942","kind":"f","owner":"postgres","config":["search_path=\"\""],"secdef":true,"strict":false,"nspname":"combat_panel_private","proname":"commit_master_actor","returns":"jsonb","language":"plpgsql","parallel":"u","arg_modes":null,"arg_names":["p_command"],"arg_types":"3802","leakproof":false,"signature":"combat_panel_private.commit_master_actor(jsonb)","volatility":"v"}},{"oid":"45916","signature":"combat_panel_private.immobilization_actor_lifecycle()","source_md5":"5244a1f635ad7d7336d24140d288b82a","ddl_md5":"f8677e282d09ca9015c01de07391f1bc","abi":{"acl":"{postgres=X/postgres}","oid":"45916","kind":"f","owner":"postgres","config":["search_path=\"\""],"secdef":true,"strict":false,"nspname":"combat_panel_private","proname":"immobilization_actor_lifecycle","returns":"trigger","language":"plpgsql","parallel":"u","arg_modes":null,"arg_names":null,"arg_types":"","leakproof":false,"signature":"combat_panel_private.immobilization_actor_lifecycle()","volatility":"v"}},{"oid":"45918","signature":"combat_panel_private.immobilization_session_lifecycle()","source_md5":"a4671931aa6e908a94af2ad2d788d933","ddl_md5":"38bc9bc060bc1af88cf087f5e4a687bb","abi":{"acl":"{postgres=X/postgres}","oid":"45918","kind":"f","owner":"postgres","config":["search_path=\"\""],"secdef":true,"strict":false,"nspname":"combat_panel_private","proname":"immobilization_session_lifecycle","returns":"trigger","language":"plpgsql","parallel":"u","arg_modes":null,"arg_names":null,"arg_types":"","leakproof":false,"signature":"combat_panel_private.immobilization_session_lifecycle()","volatility":"v"}},{"oid":"44940","signature":"combat_panel_private.master_options(uuid,uuid,bigint)","source_md5":"daccab39aa3e67a4c1a361860b8adbdf","ddl_md5":"d48e2877b5b38f53724dcb75368c7464","abi":{"acl":"{postgres=X/postgres}","oid":"44940","kind":"f","owner":"postgres","config":["search_path=\"\""],"secdef":true,"strict":false,"nspname":"combat_panel_private","proname":"master_options","returns":"jsonb","language":"plpgsql","parallel":"u","arg_modes":null,"arg_names":["p_location","p_actor","p_expected"],"arg_types":"2950 2950 20","leakproof":false,"signature":"combat_panel_private.master_options(uuid,uuid,bigint)","volatility":"v"}},{"oid":"45000","signature":"combat_panel_private.movement_block_reason(uuid)","source_md5":"9cd995d873f2ae85f3cac5c0d7ff21ad","ddl_md5":"4830deea719904406d11aa4b05cfd764","abi":{"acl":"{postgres=X/postgres}","oid":"45000","kind":"f","owner":"postgres","config":["search_path=\"\""],"secdef":true,"strict":false,"nspname":"combat_panel_private","proname":"movement_block_reason","returns":"text","language":"plpgsql","parallel":"u","arg_modes":null,"arg_names":["p_body"],"arg_types":"2950","leakproof":false,"signature":"combat_panel_private.movement_block_reason(uuid)","volatility":"s"}},{"oid":"46019","signature":"combat_panel_private.narrative_declaration_facts(uuid)","source_md5":"89ee0fe9b71918c3ba0cf25f7a334f45","ddl_md5":"4650bb589eddf6b71249114fe08c5844","abi":{"acl":"{postgres=X/postgres}","oid":"46019","kind":"f","owner":"postgres","config":["search_path=\"\""],"secdef":true,"strict":false,"nspname":"combat_panel_private","proname":"narrative_declaration_facts","returns":"jsonb","language":"plpgsql","parallel":"u","arg_modes":null,"arg_names":["p_declaration"],"arg_types":"2950","leakproof":false,"signature":"combat_panel_private.narrative_declaration_facts(uuid)","volatility":"s"}},{"oid":"46020","signature":"combat_panel_private.narrative_ordinary_context(uuid)","source_md5":"13ad2618307934e63c1ad96186957971","ddl_md5":"a811eaf1eafd4203b019825e4d84b2dc","abi":{"acl":"{postgres=X/postgres}","oid":"46020","kind":"f","owner":"postgres","config":["search_path=\"\""],"secdef":true,"strict":false,"nspname":"combat_panel_private","proname":"narrative_ordinary_context","returns":"jsonb","language":"plpgsql","parallel":"u","arg_modes":null,"arg_names":["p_round"],"arg_types":"2950","leakproof":false,"signature":"combat_panel_private.narrative_ordinary_context(uuid)","volatility":"s"}},{"oid":"46018","signature":"combat_panel_private.narrative_outcome_facts(jsonb)","source_md5":"988cc3b61d0ebf41effda90d32e173b5","ddl_md5":"a4d973f30fbd64ace5540ea3438c8e26","abi":{"acl":"{postgres=X/postgres}","oid":"46018","kind":"f","owner":"postgres","config":["search_path=\"\""],"secdef":false,"strict":false,"nspname":"combat_panel_private","proname":"narrative_outcome_facts","returns":"jsonb","language":"plpgsql","parallel":"u","arg_modes":null,"arg_names":["p_outcome"],"arg_types":"3802","leakproof":false,"signature":"combat_panel_private.narrative_outcome_facts(jsonb)","volatility":"s"}},{"oid":"44669","signature":"combat_panel_private.ordinary_options(uuid,uuid,bigint)","source_md5":"4c23fa161abb816fb0f10d50f2642630","ddl_md5":"a75ca48f390505fa9daa33800876b945","abi":{"acl":"{postgres=X/postgres}","oid":"44669","kind":"f","owner":"postgres","config":["search_path=\"\""],"secdef":true,"strict":false,"nspname":"combat_panel_private","proname":"ordinary_options","returns":"jsonb","language":"plpgsql","parallel":"u","arg_modes":null,"arg_names":["p_location","p_actor","p_expected"],"arg_types":"2950 2950 20","leakproof":false,"signature":"combat_panel_private.ordinary_options(uuid,uuid,bigint)","volatility":"v"}},{"oid":"44955","signature":"combat_panel_private.round_details_from_source(jsonb,jsonb,jsonb)","source_md5":"23722822d09c8d2a12a5121d04c141a6","ddl_md5":"883d64a10bb28250187b01e96e2dcf5e","abi":{"acl":"{postgres=X/postgres}","oid":"44955","kind":"f","owner":"postgres","config":["search_path=\"\""],"secdef":false,"strict":false,"nspname":"combat_panel_private","proname":"round_details_from_source","returns":"jsonb","language":"plpgsql","parallel":"u","arg_modes":null,"arg_names":["p_source","p_roster","p_offers"],"arg_types":"3802 3802 3802","leakproof":false,"signature":"combat_panel_private.round_details_from_source(jsonb,jsonb,jsonb)","volatility":"i"}},{"oid":"46316","signature":"combat_panel_private.round_options_authoritative(uuid,uuid)","source_md5":"7cf9d8be18c9dab5f75b62c74a5e9e37","ddl_md5":"7758a51d9039673ab98462102c44f888","abi":{"acl":"{postgres=X/postgres}","oid":"46316","kind":"f","owner":"postgres","config":["search_path=\"\""],"secdef":true,"strict":false,"nspname":"combat_panel_private","proname":"round_options_authoritative","returns":"jsonb","language":"plpgsql","parallel":"u","arg_modes":null,"arg_names":["p_round","p_actor"],"arg_types":"2950 2950","leakproof":false,"signature":"combat_panel_private.round_options_authoritative(uuid,uuid)","volatility":"v"}},{"oid":"61967","signature":"combat_v2_elemental_internal.other_consumer_options(jsonb)","source_md5":"8423c49ce8a83f2b19361b82a53fa9f4","ddl_md5":"0d57fa274c2b6b63dc5ed1ef0a7c8ca9","abi":{"acl":"{postgres=X/postgres}","oid":"61967","kind":"f","owner":"postgres","config":["search_path=\"\""],"secdef":true,"strict":false,"nspname":"combat_v2_elemental_internal","proname":"other_consumer_options","returns":"jsonb","language":"plpgsql","parallel":"u","arg_modes":null,"arg_names":["p"],"arg_types":"3802","leakproof":false,"signature":"combat_v2_elemental_internal.other_consumer_options(jsonb)","volatility":"v"}},{"oid":"61972","signature":"combat_v2_elemental_internal.other_control_apply(text,uuid,uuid,uuid)","source_md5":"4cf97ca72ff52f1bd33445ba54c8dd16","ddl_md5":"9066a8a35e086727ed0240ea05fce684","abi":{"acl":"{postgres=X/postgres}","oid":"61972","kind":"f","owner":"postgres","config":["search_path=\"\""],"secdef":true,"strict":false,"nspname":"combat_v2_elemental_internal","proname":"other_control_apply","returns":"jsonb","language":"plpgsql","parallel":"u","arg_modes":null,"arg_names":["p_adapter","p_offer","p_actor","p_request"],"arg_types":"25 2950 2950 2950","leakproof":false,"signature":"combat_v2_elemental_internal.other_control_apply(text,uuid,uuid,uuid)","volatility":"v"}},{"oid":"61971","signature":"combat_v2_elemental_internal.other_control_target(text,uuid,uuid)","source_md5":"b1af00f3eab38ed9e74836c5441616d7","ddl_md5":"03724449dfc52ef8fcf4f89ae6eabb34","abi":{"acl":"{postgres=X/postgres}","oid":"61971","kind":"f","owner":"postgres","config":["search_path=\"\""],"secdef":true,"strict":false,"nspname":"combat_v2_elemental_internal","proname":"other_control_target","returns":"uuid","language":"plpgsql","parallel":"u","arg_modes":null,"arg_names":["p_adapter","p_offer","p_actor"],"arg_types":"25 2950 2950","leakproof":false,"signature":"combat_v2_elemental_internal.other_control_target(text,uuid,uuid)","volatility":"v"}},{"oid":"61970","signature":"combat_v2_elemental_internal.other_master_options(uuid,bigint)","source_md5":"0c79a6a78b76b9e9ef8028d75e514af7","ddl_md5":"38e2e92e5566275950c270ef5a8fe3d6","abi":{"acl":"{postgres=X/postgres}","oid":"61970","kind":"f","owner":"postgres","config":["search_path=\"\""],"secdef":true,"strict":false,"nspname":"combat_v2_elemental_internal","proname":"other_master_options","returns":"void","language":"plpgsql","parallel":"u","arg_modes":null,"arg_names":["p_context","p_expected"],"arg_types":"2950 20","leakproof":false,"signature":"combat_v2_elemental_internal.other_master_options(uuid,bigint)","volatility":"v"}},{"oid":"61954","signature":"combat_v2_elemental_internal.other_prepare_native(uuid,uuid,uuid,jsonb,boolean,jsonb)","source_md5":"6e54b476b36ca716cf8c14f33ef9667e","ddl_md5":"98acc6f2f9fcb26b47f3e6e830763e42","abi":{"acl":"{postgres=X/postgres}","oid":"61954","kind":"f","owner":"postgres","config":["search_path=\"\""],"secdef":true,"strict":false,"nspname":"combat_v2_elemental_internal","proname":"other_prepare_native","returns":"jsonb","language":"plpgsql","parallel":"u","arg_modes":null,"arg_names":["p_round","p_actor","p_request","p_intent","p_push","p_native_ref"],"arg_types":"2950 2950 2950 3802 16 3802","leakproof":false,"signature":"combat_v2_elemental_internal.other_prepare_native(uuid,uuid,uuid,jsonb,boolean,jsonb)","volatility":"v"}},{"oid":"61950","signature":"combat_v2_elemental_internal.other_profile(uuid,uuid)","source_md5":"dd1e62e9052469fae4c98fed245c730a","ddl_md5":"0959ae18dc9357f65d8d8169e39b0cb2","abi":{"acl":"{postgres=X/postgres}","oid":"61950","kind":"f","owner":"postgres","config":["search_path=\"\""],"secdef":true,"strict":false,"nspname":"combat_v2_elemental_internal","proname":"other_profile","returns":"jsonb","language":"plpgsql","parallel":"u","arg_modes":null,"arg_names":["p_actor","p_technique"],"arg_types":"2950 2950","leakproof":false,"signature":"combat_v2_elemental_internal.other_profile(uuid,uuid)","volatility":"s"}},{"oid":"39291","signature":"combat_v2_multitarget_internal.resolve_parent(uuid,uuid,uuid,boolean)","source_md5":"ea4552d934017752fa4c97e6a2480bbf","ddl_md5":"f0c0e87e074c953e6aacd51656f4f6d7","abi":{"acl":"{postgres=X/postgres}","oid":"39291","kind":"f","owner":"postgres","config":["search_path=\"\""],"secdef":true,"strict":false,"nspname":"combat_v2_multitarget_internal","proname":"resolve_parent","returns":"jsonb","language":"plpgsql","parallel":"u","arg_modes":null,"arg_names":["p_session","p_round","p_attack","p_values"],"arg_types":"2950 2950 2950 16","leakproof":false,"signature":"combat_v2_multitarget_internal.resolve_parent(uuid,uuid,uuid,boolean)","volatility":"v"}},{"oid":"42947","signature":"public.combat_consumer_narrative_claim_v1(uuid,text,uuid)","source_md5":"c144d4c43e22c5e3eb516e0d46ebf65a","ddl_md5":"2c521aac41eeea3d0a843ff05c5b1e24","abi":{"acl":"{postgres=X/postgres,service_role=X/postgres}","oid":"42947","kind":"f","owner":"postgres","config":["search_path=\"\""],"secdef":true,"strict":false,"nspname":"public","proname":"combat_consumer_narrative_claim_v1","returns":"jsonb","language":"plpgsql","parallel":"u","arg_modes":null,"arg_names":["p_round","p_report_sha256","p_request_key"],"arg_types":"2950 25 2950","leakproof":false,"signature":"public.combat_consumer_narrative_claim_v1(uuid,text,uuid)","volatility":"v"}},{"oid":"42969","signature":"public.combat_consumer_narrative_complete_v1(uuid,jsonb,uuid)","source_md5":"ca906d6285eee8a8617e0cb3db70f6f9","ddl_md5":"e56749f8d49bc345ebda55a833b0ae00","abi":{"acl":"{postgres=X/postgres,service_role=X/postgres}","oid":"42969","kind":"f","owner":"postgres","config":["search_path=\"\""],"secdef":true,"strict":false,"nspname":"public","proname":"combat_consumer_narrative_complete_v1","returns":"jsonb","language":"plpgsql","parallel":"u","arg_modes":null,"arg_names":["p_claim","p_result","p_request_key"],"arg_types":"2950 3802 2950","leakproof":false,"signature":"public.combat_consumer_narrative_complete_v1(uuid,jsonb,uuid)","volatility":"v"}},{"oid":"44808","signature":"public.combat_panel_commit_v1(jsonb)","source_md5":"9c98707e4d76a4e0a23b5e7efb504ab2","ddl_md5":"488795f7305371ce8238b2a61f42fd4c","abi":{"acl":"{postgres=X/postgres,authenticated=X/postgres}","oid":"44808","kind":"f","owner":"postgres","config":["search_path=\"\""],"secdef":true,"strict":false,"nspname":"public","proname":"combat_panel_commit_v1","returns":"jsonb","language":"plpgsql","parallel":"u","arg_modes":null,"arg_names":["p_command"],"arg_types":"3802","leakproof":false,"signature":"public.combat_panel_commit_v1(jsonb)","volatility":"v"}},{"oid":"31324","signature":"public.combat_v2_action_declare(uuid,uuid,jsonb,text,uuid)","source_md5":"77f98c15d1778bd7cc5e6fdfe8d221b8","ddl_md5":"91afc68d5d1419ed20d63b9c20fe14ea","abi":{"acl":"{postgres=X/postgres,authenticated=X/postgres,service_role=X/postgres}","oid":"31324","kind":"f","owner":"postgres","config":["search_path=\"\""],"secdef":true,"strict":false,"nspname":"public","proname":"combat_v2_action_declare","returns":"jsonb","language":"plpgsql","parallel":"u","arg_modes":null,"arg_names":["p_round","p_actor","p_intent","p_text","p_request_key"],"arg_types":"2950 2950 3802 25 2950","leakproof":false,"signature":"public.combat_v2_action_declare(uuid,uuid,jsonb,text,uuid)","volatility":"v"}},{"oid":"31311","signature":"public.combat_v2_actor_ability(uuid,text,uuid,boolean)","source_md5":"0ca27d8dd57a67f255016e0d13008b1f","ddl_md5":"0d2c8fafaf5a660558709d0b64ed1665","abi":{"acl":"{postgres=X/postgres,service_role=X/postgres}","oid":"31311","kind":"f","owner":"postgres","config":["search_path=\"\""],"secdef":true,"strict":false,"nspname":"public","proname":"combat_v2_actor_ability","returns":"jsonb","language":"sql","parallel":"u","arg_modes":null,"arg_names":["p_actor","p_source","p_ability","p_defense"],"arg_types":"2950 25 2950 16","leakproof":false,"signature":"public.combat_v2_actor_ability(uuid,text,uuid,boolean)","volatility":"s"}},{"oid":"31326","signature":"public.combat_v2_defense_declare(uuid,uuid,uuid,jsonb,text,uuid)","source_md5":"446494ad3becd44a65b241967810e589","ddl_md5":"5a97231f154dab9e97c2a03b0cc142ac","abi":{"acl":"{postgres=X/postgres,authenticated=X/postgres,service_role=X/postgres}","oid":"31326","kind":"f","owner":"postgres","config":["search_path=\"\""],"secdef":true,"strict":false,"nspname":"public","proname":"combat_v2_defense_declare","returns":"jsonb","language":"plpgsql","parallel":"u","arg_modes":null,"arg_names":["p_round","p_attack_declaration","p_actor","p_intent","p_text","p_request_key"],"arg_types":"2950 2950 2950 3802 25 2950","leakproof":false,"signature":"public.combat_v2_defense_declare(uuid,uuid,uuid,jsonb,text,uuid)","volatility":"v"}},{"oid":"31331","signature":"public.combat_v2_round_resolve(uuid,uuid)","source_md5":"4cf0eb3077ada0bb5e628bd89fef4dc3","ddl_md5":"a2572e624c5c977e1c4d20086fa22ec4","abi":{"acl":"{postgres=X/postgres,service_role=X/postgres,authenticated=X/postgres}","oid":"31331","kind":"f","owner":"postgres","config":["search_path=\"\""],"secdef":true,"strict":false,"nspname":"public","proname":"combat_v2_round_resolve","returns":"jsonb","language":"plpgsql","parallel":"u","arg_modes":null,"arg_names":["p_round","p_request_key"],"arg_types":"2950 2950","leakproof":false,"signature":"public.combat_v2_round_resolve(uuid,uuid)","volatility":"v"}},{"oid":"19700","signature":"public.post_heal(uuid,uuid)","source_md5":"dcde447ee079472efa4fd41c1c911633","ddl_md5":"9fb236d5f72312f6fb33587a2981e427","abi":{"acl":"{postgres=X/postgres,service_role=X/postgres,authenticated=X/postgres}","oid":"19700","kind":"f","owner":"postgres","config":["search_path=public"],"secdef":true,"strict":false,"nspname":"public","proname":"post_heal","returns":"text","language":"plpgsql","parallel":"u","arg_modes":null,"arg_names":["p_location","p_target_user"],"arg_types":"2950 2950","leakproof":false,"signature":"public.post_heal(uuid,uuid)","volatility":"v"}}]$velo_shared_meta$::jsonb)
       AS e(signature text, source_md5 text, ddl_md5 text, abi jsonb)))) shared_sha, (SELECT jsonb_agg(jsonb_build_object('signature',p.oid::regprocedure::text,'source_md5',md5(p.prosrc),'ddl_md5',md5(pg_get_functiondef(p.oid)),
  'owner',pg_get_userbyid(p.proowner),'secdef',p.prosecdef,'config',p.proconfig,'acl',p.proacl::text,'volatility',p.provolatile::text)
  ORDER BY p.oid::regprocedure::text)FROM pg_proc p WHERE p.oid IN(
  'combat_panel_private.round_options_authoritative(uuid,uuid)'::regprocedure,
  'public.combat_v2_substitution_options_v1(uuid)'::regprocedure,'public.combat_v2_substitution_round_offers_v1(uuid,uuid)'::regprocedure,
  'public.combat_v2_substitution_select_v1(uuid,uuid)'::regprocedure,'clan_innata_private.catalogo_eligibility_release_v1()'::regprocedure,'combat_panel_private.publish_master_declaration(uuid,text)'::regprocedure)) peer6, (SELECT jsonb_agg(jsonb_build_object('signature',p.oid::regprocedure::text,'source_md5',md5(p.prosrc),
'ddl_md5',md5(pg_get_functiondef(p.oid)),'owner',pg_get_userbyid(p.proowner),'secdef',p.prosecdef,
'config',p.proconfig,'acl',p.proacl::text,'volatility',p.provolatile::text) ORDER BY p.oid::regprocedure::text) AS metadata FROM pg_proc p WHERE p.oid IN ('clan_innata_private.catalogo_eligibility_release_v1()'::regprocedure,'clan_innata_private.eligibility_release_assert()'::regprocedure)) compat, (SELECT jsonb_build_array(public.combat_v2_sha256((SELECT coalesce(jsonb_agg(jsonb_build_object('signature',n.nspname||'.'||p.proname||'('||oidvectortypes(p.proargtypes)||')','source_md5',md5(p.prosrc),'ddl_md5',md5(pg_get_functiondef(p.oid)),'owner',pg_get_userbyid(p.proowner),'acl',p.proacl::text,'config',p.proconfig,'secdef',p.prosecdef,'strict',p.proisstrict,'parallel',p.proparallel::text,'volatility',p.provolatile::text,'returns',pg_get_function_result(p.oid),'language',l.lanname)ORDER BY n.nspname,p.proname,oidvectortypes(p.proargtypes)),'[]'::jsonb)FROM pg_proc p JOIN pg_namespace n ON n.oid=p.pronamespace JOIN pg_language l ON l.oid=p.prolang WHERE p.oid IN(to_regprocedure('combat_v2_staff_nb_internal.origin_guard()'),to_regprocedure('combat_v2_staff_nb_internal.preparation_allowed(uuid)'),to_regprocedure('combat_v2_staff_nb_internal.choice(uuid)'),to_regprocedure('combat_v2_staff_nb_internal.roster_offers(uuid,bigint,uuid)'),to_regprocedure('combat_v2_staff_nb_internal.native_construct(uuid,uuid[],jsonb,jsonb,uuid,uuid)'),to_regprocedure('combat_v2_staff_nb_internal.mechanics_ready(uuid)'),to_regprocedure('combat_v2_staff_nb_internal.setup_protected(uuid,uuid)'),to_regprocedure('combat_v2_staff_nb_internal.commit_roster(jsonb)'),to_regprocedure('combat_v2_staff_nb_internal.roster_receipt(uuid)'),to_regprocedure('combat_v2_staff_nb_internal.pg_scope(uuid)'),to_regprocedure('combat_v2_staff_nb_internal.kai_frozen_authority(uuid)'),to_regprocedure('combat_v2_staff_nb_internal.kai_authority(uuid)'),to_regprocedure('combat_v2_staff_nb_internal.kai_contact(uuid,uuid)'),to_regprocedure('clan_aburame_private.verme_manifest_v1()'),to_regprocedure('clan_aburame_private.verme_release_v1()'),to_regprocedure('clan_aburame_private.verme_staff_scope_v1(uuid)'),to_regprocedure('clan_aburame_private.verme_scope_v1(uuid)'),to_regprocedure('clan_aburame_private.verme_event_v1(text,uuid,uuid,uuid,uuid,uuid,text,jsonb)'),to_regprocedure('clan_aburame_private.verme_staff_prepare_v1(uuid,uuid)'),to_regprocedure('clan_aburame_private.verme_meta_v1(uuid,boolean)'),to_regprocedure('clan_aburame_private.verme_bind_v1(uuid)'),to_regprocedure('clan_aburame_private.verme_frozen_v1(uuid)'),to_regprocedure('clan_aburame_private.verme_finish_v1(uuid,uuid,boolean,integer)'),to_regprocedure('clan_aburame_private.verme_tick_v1(uuid,uuid,uuid,text)'),to_regprocedure('clan_aburame_private.verme_end_context_v1()'),to_regprocedure('clan_aburame_private.verme_report_v1(uuid,uuid)'),to_regprocedure('clan_aburame_private.verme_reserve_round_v1(uuid)'),to_regprocedure('clan_aburame_private.verme_settle_round_v1(uuid)'),to_regprocedure('clan_aburame_private.verme_narrative_v1(uuid,uuid)'),to_regprocedure('clan_akimichi_private.common_staff_scope_v1(uuid)'),to_regprocedure('clan_akimichi_private.common_scope_v1(uuid,uuid)'),to_regprocedure('clan_akimichi_private.common_prepare_staff_v1(uuid,uuid,uuid)'),to_regprocedure('clan_akimichi_private.common_modifiers_v1(text,integer,integer,integer)'),to_regprocedure('clan_akimichi_private.common_set_form_v1(uuid,uuid,text)'),to_regprocedure('clan_akimichi_private.common_defer_upkeep_v1(uuid,uuid)'),to_regprocedure('clan_akimichi_private.common_flush_upkeep_v1(uuid)'),to_regprocedure('clan_akimichi_private.cellular_meta_v1(uuid)'),to_regprocedure('clan_akimichi_private.cellular_attack_eligible_v1(uuid,uuid)'),to_regprocedure('clan_akimichi_private.cellular_bind_v1(uuid)'),to_regprocedure('clan_akimichi_private.cellular_source_valid_v1(uuid)'),to_regprocedure('clan_akimichi_private.cellular_pay_v1(uuid)'),to_regprocedure('clan_akimichi_private.cellular_snapshot_v1(uuid,jsonb)'),to_regprocedure('clan_akimichi_private.cellular_mark_v1(uuid,jsonb)'),to_regprocedure('clan_akimichi_private.cellular_calculate_v1(uuid,jsonb,integer,integer)'),to_regprocedure('clan_akimichi_private.common_calorie_balance_v1(uuid,uuid,uuid,uuid)'),to_regprocedure('clan_akimichi_private.common_admit_calories_v1(uuid)'),to_regprocedure('clan_akimichi_private.common_preflight_calories_v1(uuid)'),to_regprocedure('clan_akimichi_private.super_direct_visible_v1(uuid,uuid)'),to_regprocedure('clan_akimichi_private.common_attack_power_freeze_v1(uuid)'),to_regprocedure('clan_akimichi_private.common_panel_offers_v1(uuid,bigint,jsonb)'),to_regprocedure('clan_akimichi_private.common_panel_commit_v1(jsonb)'),to_regprocedure('clan_akimichi_private.common_result_label_v1(jsonb)'),to_regprocedure('clan_akimichi_private.common_source_root_v1()'),to_regprocedure('clan_sabaku_private.armor_absorb_packet_v1(uuid,uuid,uuid,uuid,integer)'),to_regprocedure('combat_panel_private.nara_adv_pool_v1(uuid)'),to_regprocedure('combat_panel_private.nara_adv_protected_v1(uuid)'),to_regprocedure('combat_panel_private.nara_adv_scope_v1(uuid)'),to_regprocedure('combat_panel_private.nara_adv_prepare_v1(uuid,uuid)'),to_regprocedure('combat_panel_private.nara_strangle_meta_v1(uuid)'),to_regprocedure('combat_panel_private.nara_strangle_action_meta_v1(uuid,uuid,jsonb)'),to_regprocedure('combat_panel_private.nara_strangle_bind_v1(uuid)'),to_regprocedure('combat_panel_private.nara_strangle_parent_valid_v1(uuid)'),to_regprocedure('combat_panel_private.nara_strangle_lifecycle_v1(uuid)'),to_regprocedure('combat_panel_private.nara_strangle_packet_v1(uuid,uuid,uuid,text)'),to_regprocedure('combat_panel_private.nara_strangle_resolve_v1(uuid)'),to_regprocedure('combat_panel_private.nara_strangle_turn_v1(uuid,uuid,uuid,text)'),to_regprocedure('combat_panel_private.nara_strangle_facts_revision_v1(jsonb)'),to_regprocedure('combat_panel_private.nara_strangle_facts_v1(uuid,uuid)'),to_regprocedure('combat_panel_private.nara_adv_history_guard_v1()'),to_regprocedure('combat_panel_private.nara_strangle_end_event_v1()'),to_regprocedure('combat_panel_private.nara_strangle_terminal_report_v1(uuid)'),to_regprocedure('combat_panel_private.nara_strangle_lifecycle_context_v1(uuid)'),to_regprocedure('combat_panel_private.nara_adv_offers_v1(uuid,bigint,jsonb)'),to_regprocedure('combat_panel_private.nara_adv_commit_v1(jsonb)'),to_regprocedure('combat_panel_private.nara_strangle_lifecycle_trigger_v1()')))),public.combat_v2_sha256((SELECT coalesce(jsonb_agg(jsonb_build_object('signature',n.nspname||'.'||p.proname||'('||oidvectortypes(p.proargtypes)||')','source_md5',md5(p.prosrc),'ddl_md5',md5(pg_get_functiondef(p.oid)),'owner',pg_get_userbyid(p.proowner),'acl',p.proacl::text,'config',p.proconfig,'secdef',p.prosecdef,'strict',p.proisstrict,'parallel',p.proparallel::text,'volatility',p.provolatile::text,'returns',pg_get_function_result(p.oid),'language',l.lanname)ORDER BY n.nspname,p.proname,oidvectortypes(p.proargtypes)),'[]'::jsonb)FROM pg_proc p JOIN pg_namespace n ON n.oid=p.pronamespace JOIN pg_language l ON l.oid=p.prolang WHERE p.oid IN(to_regprocedure('clan_aburame_private.actor_ability(uuid,text,uuid,boolean,jsonb)'),to_regprocedure('clan_aburame_private.attack_power_source(uuid,uuid)'),to_regprocedure('clan_aburame_private.commit_control(jsonb,jsonb,combat_consumer_private.activities,combat_consumer_private.offers,uuid)'),to_regprocedure('clan_aburame_private.commit_master_stop(jsonb)'),to_regprocedure('clan_aburame_private.consumer_options(jsonb)'),to_regprocedure('clan_aburame_private.master_offers(uuid,bigint,jsonb)'),to_regprocedure('clan_akimichi_private.apply_calorie_event(uuid,uuid,boolean,uuid,text,integer,integer,uuid,timestamp with time zone)'),to_regprocedure('clan_akimichi_private.begin_personal_turn(uuid,uuid)'),to_regprocedure('clan_akimichi_private.bind_partial(uuid)'),to_regprocedure('clan_akimichi_private.end_form(uuid,uuid,text)'),to_regprocedure('clan_akimichi_private.form_change_offer(uuid)'),to_regprocedure('clan_akimichi_private.form_impact(uuid,uuid,uuid,text,text,text,jsonb)'),to_regprocedure('clan_akimichi_private.movement_maximum(uuid,numeric)'),to_regprocedure('clan_akimichi_private.partial_meta(uuid,jsonb)'),to_regprocedure('clan_akimichi_private.set_form(uuid,uuid,boolean)'),to_regprocedure('clan_sabaku_private.armor_absorb(uuid,integer)'),to_regprocedure('clan_sabaku_private.armor_narrative_round(uuid)'),to_regprocedure('clan_sabaku_private.armor_round_facts(uuid)'),to_regprocedure('combat_consumer_private.after_publish(uuid,uuid)'),to_regprocedure('combat_consumer_private.commit_exchange(jsonb,jsonb)'),to_regprocedure('combat_consumer_private.narrative_context(uuid)'),to_regprocedure('combat_consumer_private.narrative_declaration_supported(uuid)'),to_regprocedure('combat_consumer_private.validate_narrative_result(jsonb)'),to_regprocedure('combat_effects_private.lifecycle_actor_end(uuid)'),to_regprocedure('combat_effects_private.lifecycle_open(uuid,uuid)'),to_regprocedure('combat_effects_private.lifecycle_session_end(uuid)'),to_regprocedure('combat_effects_private.personal_turn_end(uuid,uuid,uuid,text)'),to_regprocedure('combat_panel_private.catalog_result_label_v1(jsonb)'),to_regprocedure('combat_panel_private.consumer_commit_authoritative(jsonb)'),to_regprocedure('combat_panel_private.master_admin_offers(uuid,bigint,jsonb)'),to_regprocedure('combat_panel_private.master_options(uuid,uuid,bigint)'),to_regprocedure('combat_panel_private.nara_shadow_level_v1(uuid)'),to_regprocedure('combat_panel_private.narrative_declaration_facts(uuid)'),to_regprocedure('combat_panel_private.narrative_ordinary_context(uuid)'),to_regprocedure('combat_panel_private.ordinary_options(uuid,uuid,bigint)'),to_regprocedure('combat_spatial.movement_commit(uuid,uuid,uuid)'),to_regprocedure('combat_v2_genjutsu_internal.ally_contact(uuid,uuid)'),to_regprocedure('combat_v2_genjutsu_internal.master_options(uuid,bigint)'),to_regprocedure('combat_v2_genjutsu_internal.release_intents(uuid)'),to_regprocedure('combat_v2_genjutsu_internal.release_meta(uuid,uuid,uuid,jsonb)'),to_regprocedure('combat_v2_genjutsu_internal.resolve_release(uuid)'),to_regprocedure('combat_v2_genjutsu_internal.scope(uuid)'),to_regprocedure('combat_v2_multitarget_internal.resolve_parent(uuid,uuid,uuid,boolean)'),to_regprocedure('mission_factory_owner.quest_combat_offer_source_guard_v1()'),to_regprocedure('public._combat_calcola(text,jsonb,jsonb,text,text,integer,text,integer,integer,integer,integer,boolean)'),to_regprocedure('public.combat_consumer_narrative_claim_v1(uuid,text,uuid)'),to_regprocedure('public.combat_consumer_narrative_complete_v1(uuid,jsonb,uuid)'),to_regprocedure('public.combat_panel_commit_v1(jsonb)'),to_regprocedure('public.combat_v2_action_declare(uuid,uuid,jsonb,text,uuid)'),to_regprocedure('public.combat_v2_actor_ability(uuid,text,uuid,boolean)'),to_regprocedure('public.combat_v2_defense_declare(uuid,uuid,uuid,jsonb,text,uuid)'),to_regprocedure('public.combat_v2_round_resolve(uuid,uuid)'),to_regprocedure('public.master_v2_encounter_open_ninja_book_v1_human_ai_core(uuid,uuid[],jsonb,jsonb,uuid)'),to_regprocedure('combat_panel_private.publish_master_declaration(uuid,text)'),to_regprocedure('clan_innata_private.eligibility_release_assert()'),to_regprocedure('combat_panel_private.cure_neutral_preset_v1(uuid,uuid,uuid,jsonb)'),to_regprocedure('combat_panel_private.master_actor_offers(uuid,bigint,jsonb,jsonb)')))),public.combat_v2_sha256((SELECT jsonb_build_object('tables',(SELECT jsonb_agg(jsonb_build_object('schema',n.nspname,'name',c.relname,'owner',pg_get_userbyid(c.relowner),'acl',c.relacl::text,'rls',c.relrowsecurity,'force_rls',c.relforcerowsecurity,'columns',(SELECT jsonb_agg(jsonb_build_object('name',a.attname,'type',format_type(a.atttypid,a.atttypmod),'notnull',a.attnotnull,'default',pg_get_expr(d.adbin,d.adrelid),'identity',a.attidentity,'generated',a.attgenerated)ORDER BY a.attnum)FROM pg_attribute a LEFT JOIN pg_attrdef d ON d.adrelid=a.attrelid AND d.adnum=a.attnum WHERE a.attrelid=c.oid AND a.attnum>0 AND NOT a.attisdropped),'constraints',(SELECT coalesce(jsonb_agg(jsonb_build_object('name',q.conname,'definition',pg_get_constraintdef(q.oid),'validated',q.convalidated,'deferrable',q.condeferrable,'deferred',q.condeferred)ORDER BY q.conname),'[]'::jsonb)FROM pg_constraint q WHERE q.conrelid=c.oid),'indexes',(SELECT coalesce(jsonb_agg(jsonb_build_object('name',ci.relname,'definition',pg_get_indexdef(i.indexrelid),'valid',i.indisvalid,'ready',i.indisready,'live',i.indislive)ORDER BY ci.relname),'[]'::jsonb)FROM pg_index i JOIN pg_class ci ON ci.oid=i.indexrelid WHERE i.indrelid=c.oid),'triggers',(SELECT coalesce(jsonb_agg(pg_get_triggerdef(t.oid)ORDER BY t.tgname),'[]'::jsonb)FROM pg_trigger t WHERE t.tgrelid=c.oid AND NOT t.tgisinternal),'policies',(SELECT coalesce(jsonb_agg(jsonb_build_object('name',p.polname,'cmd',p.polcmd,'roles',p.polroles,'using',pg_get_expr(p.polqual,p.polrelid),'check',pg_get_expr(p.polwithcheck,p.polrelid))ORDER BY p.polname),'[]'::jsonb)FROM pg_policy p WHERE p.polrelid=c.oid))ORDER BY n.nspname,c.relname)FROM pg_class c JOIN pg_namespace n ON n.oid=c.relnamespace WHERE c.oid IN(to_regclass('combat_v2_staff_nb_internal.gate'),to_regclass('combat_v2_staff_nb_internal.roster_sources'),to_regclass('combat_v2_staff_nb_internal.admissions'),to_regclass('clan_aburame_private.verme_gate_v1'),to_regclass('clan_aburame_private.verme_staff_profiles_v1'),to_regclass('clan_aburame_private.verme_sources_v1'),to_regclass('clan_aburame_private.verme_poison_v1'),to_regclass('clan_aburame_private.verme_events_v1'),to_regclass('clan_akimichi_private.common_gate_v1'),to_regclass('clan_akimichi_private.common_staff_profiles_v1'),to_regclass('clan_akimichi_private.common_form_commands_v1'),to_regclass('clan_akimichi_private.common_attack_powers_v1'),to_regclass('clan_akimichi_private.common_pending_upkeep_v1'),to_regclass('clan_akimichi_private.cellular_sources_v1'),to_regclass('combat_panel_private.nara_adv_gate_v1'),to_regclass('combat_panel_private.nara_adv_staff_v1'),to_regclass('combat_panel_private.nara_strangle_sources_v1'),to_regclass('combat_panel_private.nara_strangle_events_v1'),to_regclass('public.master_v2_nb_actor_offers_v1'),to_regclass('clan_akimichi_private.forms'))),'catalog',(SELECT jsonb_agg(jsonb_build_object('id',t.id,'sha256',public.combat_v2_sha256(to_jsonb(t)))ORDER BY t.id)FROM public.clan_techniques t WHERE id IN('0a15282f-d6b5-4ee3-ad52-7fac2525444d','f5f26cb5-9b6f-44b3-94bc-c329a0a88b93','687b058a-807d-4cf7-8bcf-21147931b0f6')),'NBtuples',(SELECT jsonb_build_object('mechanical',(SELECT jsonb_agg(jsonb_build_object('id',v.id,'template_id',v.template_id,'content_sha256',v.content_sha256)ORDER BY v.id)FROM public.nb_mechanical_versions v WHERE v.id IN('31da0000-0000-4000-8000-000000000111','31da0000-0000-4000-8000-000000000112')),'narrative',(SELECT jsonb_agg(jsonb_build_object('id',v.id,'template_id',v.template_id,'content_sha256',v.content_sha256)ORDER BY v.id)FROM public.nb_template_versions v WHERE v.id IN('31da0000-0000-4000-8000-000000000211','31da0000-0000-4000-8000-000000000212')))),'new_triggers',(SELECT jsonb_agg(jsonb_build_object('table',e->>'table','name',t.tgname,'function',t.tgfoid::regprocedure::text,'enabled',t.tgenabled::text,'type',t.tgtype,'definition',pg_get_triggerdef(t.oid),'args_sha256',encode(extensions.digest(t.tgargs,'sha256'),'hex'))ORDER BY e->>'table',e->>'name')FROM jsonb_array_elements($joint_triggers$[{"table":"combat_v2_staff_nb_internal.roster_sources","name":"staff_nb_origin_immutable"},{"table":"public.combat_v2_sessions","name":"aburame_verme_end_session_v1"},{"table":"public.combat_v2_actors","name":"aburame_verme_end_actor_v1"},{"table":"combat_panel_private.nara_strangle_sources_v1","name":"nara_strangle_snapshot_guard_v1"},{"table":"combat_panel_private.nara_strangle_events_v1","name":"nara_strangle_events_guard_v1"},{"table":"combat_panel_private.nara_adv_staff_v1","name":"nara_strangle_staff_guard_v1"},{"table":"combat_panel_private.nara_strangle_sources_v1","name":"nara_strangle_ended_event_v1"},{"table":"combat_panel_private.immobilizations","name":"nara_strangle_parent_end_v1"},{"table":"combat_spatial.actor_states","name":"nara_strangle_geometry_end_v1"}]$joint_triggers$::jsonb)e JOIN pg_trigger t ON t.tgrelid=to_regclass(e->>'table')AND t.tgname=e->>'name'AND NOT t.tgisinternal),'NBnamespace',(SELECT jsonb_build_object('owner',pg_get_userbyid(nspowner),'acl',nspacl::text)FROM pg_namespace WHERE nspname='combat_v2_staff_nb_internal')))))) descriptor
), f1 AS MATERIALIZED (
  SELECT (SELECT public.combat_v2_sha256((SELECT jsonb_agg((e.abi||jsonb_build_object('source_md5',e.source_md5,'ddl_md5',e.ddl_md5)) ORDER BY e.signature)
  FROM jsonb_to_recordset($velo_shared_meta$[{"oid":"42942","signature":"combat_consumer_private.narrative_context(uuid)","source_md5":"84031451f48f40639d7f2a1fe8e957d3","ddl_md5":"3f67e976ddab257ce59ec1785a0365fb","abi":{"acl":"{postgres=X/postgres}","oid":"42942","kind":"f","owner":"postgres","config":["search_path=\"\""],"secdef":true,"strict":false,"nspname":"combat_consumer_private","proname":"narrative_context","returns":"jsonb","language":"plpgsql","parallel":"u","arg_modes":null,"arg_names":["p_round"],"arg_types":"2950","leakproof":false,"signature":"combat_consumer_private.narrative_context(uuid)","volatility":"s"}},{"oid":"46723","signature":"combat_consumer_private.narrative_declaration_supported(uuid)","source_md5":"1ed7184037cedfef9d606dfd7090e7a4","ddl_md5":"9d2cad68a149da7f97c177bcf51d73c0","abi":{"acl":"{postgres=X/postgres}","oid":"46723","kind":"f","owner":"postgres","config":["search_path=\"\""],"secdef":true,"strict":false,"nspname":"combat_consumer_private","proname":"narrative_declaration_supported","returns":"boolean","language":"plpgsql","parallel":"u","arg_modes":null,"arg_names":["p_declaration"],"arg_types":"2950","leakproof":false,"signature":"combat_consumer_private.narrative_declaration_supported(uuid)","volatility":"s"}},{"oid":"42968","signature":"combat_consumer_private.validate_narrative_result(jsonb)","source_md5":"6664101fcd222bd583e9ae8cf7b2b7fc","ddl_md5":"097d6805ce2b21e21fc9aa7fe2a5a9ca","abi":{"acl":"{postgres=X/postgres}","oid":"42968","kind":"f","owner":"postgres","config":["search_path=\"\""],"secdef":false,"strict":false,"nspname":"combat_consumer_private","proname":"validate_narrative_result","returns":"void","language":"plpgsql","parallel":"u","arg_modes":null,"arg_names":["p"],"arg_types":"3802","leakproof":false,"signature":"combat_consumer_private.validate_narrative_result(jsonb)","volatility":"i"}},{"oid":"52137","signature":"combat_effects_private.lifecycle_before_report(uuid)","source_md5":"bc4009af6a274d51e6b96fc51f7a7a78","ddl_md5":"ee929b8e4bb4efcd584e7755aa5df682","abi":{"acl":"{postgres=X/postgres}","oid":"52137","kind":"f","owner":"postgres","config":["search_path=\"\""],"secdef":true,"strict":false,"nspname":"combat_effects_private","proname":"lifecycle_before_report","returns":"jsonb","language":"plpgsql","parallel":"u","arg_modes":null,"arg_names":["p_round"],"arg_types":"2950","leakproof":false,"signature":"combat_effects_private.lifecycle_before_report(uuid)","volatility":"v"}},{"oid":"52136","signature":"combat_effects_private.lifecycle_main_end(uuid)","source_md5":"a1948e8ce4fc505fc23e4e4089958507","ddl_md5":"0b743c53cb23a3402542468dc3096430","abi":{"acl":"{postgres=X/postgres}","oid":"52136","kind":"f","owner":"postgres","config":["search_path=\"\""],"secdef":true,"strict":false,"nspname":"combat_effects_private","proname":"lifecycle_main_end","returns":"jsonb","language":"plpgsql","parallel":"u","arg_modes":null,"arg_names":["p_declaration"],"arg_types":"2950","leakproof":false,"signature":"combat_effects_private.lifecycle_main_end(uuid)","volatility":"v"}},{"oid":"52133","signature":"combat_effects_private.lifecycle_open(uuid,uuid)","source_md5":"25b975033c044147b540a6e6492f1b85","ddl_md5":"531b5e14f873e40a1b5042f40ea1b15d","abi":{"acl":"{postgres=X/postgres}","oid":"52133","kind":"f","owner":"postgres","config":["search_path=\"\""],"secdef":true,"strict":false,"nspname":"combat_effects_private","proname":"lifecycle_open","returns":"void","language":"plpgsql","parallel":"u","arg_modes":null,"arg_names":["p_session","p_actor"],"arg_types":"2950 2950","leakproof":false,"signature":"combat_effects_private.lifecycle_open(uuid,uuid)","volatility":"v"}},{"oid":"51910","signature":"combat_effects_private.personal_turn_end(uuid,uuid,uuid,text)","source_md5":"29f0a8df88c6bed279f650d49a706699","ddl_md5":"9e8138c513fa0c8824ca9c5d48aa3d54","abi":{"acl":"{postgres=X/postgres}","oid":"51910","kind":"f","owner":"postgres","config":["search_path=\"\""],"secdef":true,"strict":false,"nspname":"combat_effects_private","proname":"personal_turn_end","returns":"jsonb","language":"plpgsql","parallel":"u","arg_modes":null,"arg_names":["p_session","p_actor","p_turn","p_adapter"],"arg_types":"2950 2950 2950 25","leakproof":false,"signature":"combat_effects_private.personal_turn_end(uuid,uuid,uuid,text)","volatility":"v"}},{"oid":"51906","signature":"combat_effects_private.personal_turn_start(uuid,uuid,uuid,text)","source_md5":"e7ec43224a4640d00c53bad72ac0132d","ddl_md5":"d023d8a651a5e8ef8fdb1cc834b93391","abi":{"acl":"{postgres=X/postgres}","oid":"51906","kind":"f","owner":"postgres","config":["search_path=\"\""],"secdef":true,"strict":false,"nspname":"combat_effects_private","proname":"personal_turn_start","returns":"void","language":"plpgsql","parallel":"u","arg_modes":null,"arg_names":["p_session","p_actor","p_turn","p_adapter"],"arg_types":"2950 2950 2950 25","leakproof":false,"signature":"combat_effects_private.personal_turn_start(uuid,uuid,uuid,text)","volatility":"v"}},{"oid":"44942","signature":"combat_panel_private.commit_master_actor(jsonb)","source_md5":"0c39121bcbd32a49608e4d925560ba41","ddl_md5":"b531bb7f50d4346a09e822b2f2e95144","abi":{"acl":"{postgres=X/postgres}","oid":"44942","kind":"f","owner":"postgres","config":["search_path=\"\""],"secdef":true,"strict":false,"nspname":"combat_panel_private","proname":"commit_master_actor","returns":"jsonb","language":"plpgsql","parallel":"u","arg_modes":null,"arg_names":["p_command"],"arg_types":"3802","leakproof":false,"signature":"combat_panel_private.commit_master_actor(jsonb)","volatility":"v"}},{"oid":"45916","signature":"combat_panel_private.immobilization_actor_lifecycle()","source_md5":"5244a1f635ad7d7336d24140d288b82a","ddl_md5":"f8677e282d09ca9015c01de07391f1bc","abi":{"acl":"{postgres=X/postgres}","oid":"45916","kind":"f","owner":"postgres","config":["search_path=\"\""],"secdef":true,"strict":false,"nspname":"combat_panel_private","proname":"immobilization_actor_lifecycle","returns":"trigger","language":"plpgsql","parallel":"u","arg_modes":null,"arg_names":null,"arg_types":"","leakproof":false,"signature":"combat_panel_private.immobilization_actor_lifecycle()","volatility":"v"}},{"oid":"45918","signature":"combat_panel_private.immobilization_session_lifecycle()","source_md5":"a4671931aa6e908a94af2ad2d788d933","ddl_md5":"38bc9bc060bc1af88cf087f5e4a687bb","abi":{"acl":"{postgres=X/postgres}","oid":"45918","kind":"f","owner":"postgres","config":["search_path=\"\""],"secdef":true,"strict":false,"nspname":"combat_panel_private","proname":"immobilization_session_lifecycle","returns":"trigger","language":"plpgsql","parallel":"u","arg_modes":null,"arg_names":null,"arg_types":"","leakproof":false,"signature":"combat_panel_private.immobilization_session_lifecycle()","volatility":"v"}},{"oid":"44940","signature":"combat_panel_private.master_options(uuid,uuid,bigint)","source_md5":"c3ae5fff837af5db1779970e73a414bd","ddl_md5":"6273f7d573951ae327a062c9d2f37099","abi":{"acl":"{postgres=X/postgres}","oid":"44940","kind":"f","owner":"postgres","config":["search_path=\"\""],"secdef":true,"strict":false,"nspname":"combat_panel_private","proname":"master_options","returns":"jsonb","language":"plpgsql","parallel":"u","arg_modes":null,"arg_names":["p_location","p_actor","p_expected"],"arg_types":"2950 2950 20","leakproof":false,"signature":"combat_panel_private.master_options(uuid,uuid,bigint)","volatility":"v"}},{"oid":"45000","signature":"combat_panel_private.movement_block_reason(uuid)","source_md5":"9cd995d873f2ae85f3cac5c0d7ff21ad","ddl_md5":"4830deea719904406d11aa4b05cfd764","abi":{"acl":"{postgres=X/postgres}","oid":"45000","kind":"f","owner":"postgres","config":["search_path=\"\""],"secdef":true,"strict":false,"nspname":"combat_panel_private","proname":"movement_block_reason","returns":"text","language":"plpgsql","parallel":"u","arg_modes":null,"arg_names":["p_body"],"arg_types":"2950","leakproof":false,"signature":"combat_panel_private.movement_block_reason(uuid)","volatility":"s"}},{"oid":"46019","signature":"combat_panel_private.narrative_declaration_facts(uuid)","source_md5":"89ee0fe9b71918c3ba0cf25f7a334f45","ddl_md5":"4650bb589eddf6b71249114fe08c5844","abi":{"acl":"{postgres=X/postgres}","oid":"46019","kind":"f","owner":"postgres","config":["search_path=\"\""],"secdef":true,"strict":false,"nspname":"combat_panel_private","proname":"narrative_declaration_facts","returns":"jsonb","language":"plpgsql","parallel":"u","arg_modes":null,"arg_names":["p_declaration"],"arg_types":"2950","leakproof":false,"signature":"combat_panel_private.narrative_declaration_facts(uuid)","volatility":"s"}},{"oid":"46020","signature":"combat_panel_private.narrative_ordinary_context(uuid)","source_md5":"13ad2618307934e63c1ad96186957971","ddl_md5":"a811eaf1eafd4203b019825e4d84b2dc","abi":{"acl":"{postgres=X/postgres}","oid":"46020","kind":"f","owner":"postgres","config":["search_path=\"\""],"secdef":true,"strict":false,"nspname":"combat_panel_private","proname":"narrative_ordinary_context","returns":"jsonb","language":"plpgsql","parallel":"u","arg_modes":null,"arg_names":["p_round"],"arg_types":"2950","leakproof":false,"signature":"combat_panel_private.narrative_ordinary_context(uuid)","volatility":"s"}},{"oid":"46018","signature":"combat_panel_private.narrative_outcome_facts(jsonb)","source_md5":"988cc3b61d0ebf41effda90d32e173b5","ddl_md5":"a4d973f30fbd64ace5540ea3438c8e26","abi":{"acl":"{postgres=X/postgres}","oid":"46018","kind":"f","owner":"postgres","config":["search_path=\"\""],"secdef":false,"strict":false,"nspname":"combat_panel_private","proname":"narrative_outcome_facts","returns":"jsonb","language":"plpgsql","parallel":"u","arg_modes":null,"arg_names":["p_outcome"],"arg_types":"3802","leakproof":false,"signature":"combat_panel_private.narrative_outcome_facts(jsonb)","volatility":"s"}},{"oid":"44669","signature":"combat_panel_private.ordinary_options(uuid,uuid,bigint)","source_md5":"e1e6cd169797dc97d13aee366489d338","ddl_md5":"46424781b6fd6d34a0415090df6703f1","abi":{"acl":"{postgres=X/postgres}","oid":"44669","kind":"f","owner":"postgres","config":["search_path=\"\""],"secdef":true,"strict":false,"nspname":"combat_panel_private","proname":"ordinary_options","returns":"jsonb","language":"plpgsql","parallel":"u","arg_modes":null,"arg_names":["p_location","p_actor","p_expected"],"arg_types":"2950 2950 20","leakproof":false,"signature":"combat_panel_private.ordinary_options(uuid,uuid,bigint)","volatility":"v"}},{"oid":"44955","signature":"combat_panel_private.round_details_from_source(jsonb,jsonb,jsonb)","source_md5":"23722822d09c8d2a12a5121d04c141a6","ddl_md5":"883d64a10bb28250187b01e96e2dcf5e","abi":{"acl":"{postgres=X/postgres}","oid":"44955","kind":"f","owner":"postgres","config":["search_path=\"\""],"secdef":false,"strict":false,"nspname":"combat_panel_private","proname":"round_details_from_source","returns":"jsonb","language":"plpgsql","parallel":"u","arg_modes":null,"arg_names":["p_source","p_roster","p_offers"],"arg_types":"3802 3802 3802","leakproof":false,"signature":"combat_panel_private.round_details_from_source(jsonb,jsonb,jsonb)","volatility":"i"}},{"oid":"46316","signature":"combat_panel_private.round_options_authoritative(uuid,uuid)","source_md5":"7cf9d8be18c9dab5f75b62c74a5e9e37","ddl_md5":"7758a51d9039673ab98462102c44f888","abi":{"acl":"{postgres=X/postgres}","oid":"46316","kind":"f","owner":"postgres","config":["search_path=\"\""],"secdef":true,"strict":false,"nspname":"combat_panel_private","proname":"round_options_authoritative","returns":"jsonb","language":"plpgsql","parallel":"u","arg_modes":null,"arg_names":["p_round","p_actor"],"arg_types":"2950 2950","leakproof":false,"signature":"combat_panel_private.round_options_authoritative(uuid,uuid)","volatility":"v"}},{"oid":"61967","signature":"combat_v2_elemental_internal.other_consumer_options(jsonb)","source_md5":"8423c49ce8a83f2b19361b82a53fa9f4","ddl_md5":"0d57fa274c2b6b63dc5ed1ef0a7c8ca9","abi":{"acl":"{postgres=X/postgres}","oid":"61967","kind":"f","owner":"postgres","config":["search_path=\"\""],"secdef":true,"strict":false,"nspname":"combat_v2_elemental_internal","proname":"other_consumer_options","returns":"jsonb","language":"plpgsql","parallel":"u","arg_modes":null,"arg_names":["p"],"arg_types":"3802","leakproof":false,"signature":"combat_v2_elemental_internal.other_consumer_options(jsonb)","volatility":"v"}},{"oid":"61972","signature":"combat_v2_elemental_internal.other_control_apply(text,uuid,uuid,uuid)","source_md5":"4cf97ca72ff52f1bd33445ba54c8dd16","ddl_md5":"9066a8a35e086727ed0240ea05fce684","abi":{"acl":"{postgres=X/postgres}","oid":"61972","kind":"f","owner":"postgres","config":["search_path=\"\""],"secdef":true,"strict":false,"nspname":"combat_v2_elemental_internal","proname":"other_control_apply","returns":"jsonb","language":"plpgsql","parallel":"u","arg_modes":null,"arg_names":["p_adapter","p_offer","p_actor","p_request"],"arg_types":"25 2950 2950 2950","leakproof":false,"signature":"combat_v2_elemental_internal.other_control_apply(text,uuid,uuid,uuid)","volatility":"v"}},{"oid":"61971","signature":"combat_v2_elemental_internal.other_control_target(text,uuid,uuid)","source_md5":"b1af00f3eab38ed9e74836c5441616d7","ddl_md5":"03724449dfc52ef8fcf4f89ae6eabb34","abi":{"acl":"{postgres=X/postgres}","oid":"61971","kind":"f","owner":"postgres","config":["search_path=\"\""],"secdef":true,"strict":false,"nspname":"combat_v2_elemental_internal","proname":"other_control_target","returns":"uuid","language":"plpgsql","parallel":"u","arg_modes":null,"arg_names":["p_adapter","p_offer","p_actor"],"arg_types":"25 2950 2950","leakproof":false,"signature":"combat_v2_elemental_internal.other_control_target(text,uuid,uuid)","volatility":"v"}},{"oid":"61970","signature":"combat_v2_elemental_internal.other_master_options(uuid,bigint)","source_md5":"0c79a6a78b76b9e9ef8028d75e514af7","ddl_md5":"38e2e92e5566275950c270ef5a8fe3d6","abi":{"acl":"{postgres=X/postgres}","oid":"61970","kind":"f","owner":"postgres","config":["search_path=\"\""],"secdef":true,"strict":false,"nspname":"combat_v2_elemental_internal","proname":"other_master_options","returns":"void","language":"plpgsql","parallel":"u","arg_modes":null,"arg_names":["p_context","p_expected"],"arg_types":"2950 20","leakproof":false,"signature":"combat_v2_elemental_internal.other_master_options(uuid,bigint)","volatility":"v"}},{"oid":"61954","signature":"combat_v2_elemental_internal.other_prepare_native(uuid,uuid,uuid,jsonb,boolean,jsonb)","source_md5":"6e54b476b36ca716cf8c14f33ef9667e","ddl_md5":"98acc6f2f9fcb26b47f3e6e830763e42","abi":{"acl":"{postgres=X/postgres}","oid":"61954","kind":"f","owner":"postgres","config":["search_path=\"\""],"secdef":true,"strict":false,"nspname":"combat_v2_elemental_internal","proname":"other_prepare_native","returns":"jsonb","language":"plpgsql","parallel":"u","arg_modes":null,"arg_names":["p_round","p_actor","p_request","p_intent","p_push","p_native_ref"],"arg_types":"2950 2950 2950 3802 16 3802","leakproof":false,"signature":"combat_v2_elemental_internal.other_prepare_native(uuid,uuid,uuid,jsonb,boolean,jsonb)","volatility":"v"}},{"oid":"61950","signature":"combat_v2_elemental_internal.other_profile(uuid,uuid)","source_md5":"dd1e62e9052469fae4c98fed245c730a","ddl_md5":"0959ae18dc9357f65d8d8169e39b0cb2","abi":{"acl":"{postgres=X/postgres}","oid":"61950","kind":"f","owner":"postgres","config":["search_path=\"\""],"secdef":true,"strict":false,"nspname":"combat_v2_elemental_internal","proname":"other_profile","returns":"jsonb","language":"plpgsql","parallel":"u","arg_modes":null,"arg_names":["p_actor","p_technique"],"arg_types":"2950 2950","leakproof":false,"signature":"combat_v2_elemental_internal.other_profile(uuid,uuid)","volatility":"s"}},{"oid":"39291","signature":"combat_v2_multitarget_internal.resolve_parent(uuid,uuid,uuid,boolean)","source_md5":"9b278e6f9024b78be794aed4b23ca4ae","ddl_md5":"2cb3c3d30a1c058770ef611fb90dbd80","abi":{"acl":"{postgres=X/postgres}","oid":"39291","kind":"f","owner":"postgres","config":["search_path=\"\""],"secdef":true,"strict":false,"nspname":"combat_v2_multitarget_internal","proname":"resolve_parent","returns":"jsonb","language":"plpgsql","parallel":"u","arg_modes":null,"arg_names":["p_session","p_round","p_attack","p_values"],"arg_types":"2950 2950 2950 16","leakproof":false,"signature":"combat_v2_multitarget_internal.resolve_parent(uuid,uuid,uuid,boolean)","volatility":"v"}},{"oid":"42947","signature":"public.combat_consumer_narrative_claim_v1(uuid,text,uuid)","source_md5":"c144d4c43e22c5e3eb516e0d46ebf65a","ddl_md5":"2c521aac41eeea3d0a843ff05c5b1e24","abi":{"acl":"{postgres=X/postgres,service_role=X/postgres}","oid":"42947","kind":"f","owner":"postgres","config":["search_path=\"\""],"secdef":true,"strict":false,"nspname":"public","proname":"combat_consumer_narrative_claim_v1","returns":"jsonb","language":"plpgsql","parallel":"u","arg_modes":null,"arg_names":["p_round","p_report_sha256","p_request_key"],"arg_types":"2950 25 2950","leakproof":false,"signature":"public.combat_consumer_narrative_claim_v1(uuid,text,uuid)","volatility":"v"}},{"oid":"42969","signature":"public.combat_consumer_narrative_complete_v1(uuid,jsonb,uuid)","source_md5":"ca906d6285eee8a8617e0cb3db70f6f9","ddl_md5":"e56749f8d49bc345ebda55a833b0ae00","abi":{"acl":"{postgres=X/postgres,service_role=X/postgres}","oid":"42969","kind":"f","owner":"postgres","config":["search_path=\"\""],"secdef":true,"strict":false,"nspname":"public","proname":"combat_consumer_narrative_complete_v1","returns":"jsonb","language":"plpgsql","parallel":"u","arg_modes":null,"arg_names":["p_claim","p_result","p_request_key"],"arg_types":"2950 3802 2950","leakproof":false,"signature":"public.combat_consumer_narrative_complete_v1(uuid,jsonb,uuid)","volatility":"v"}},{"oid":"44808","signature":"public.combat_panel_commit_v1(jsonb)","source_md5":"0b5a0ca3366bb6a302fcdfcddd306f48","ddl_md5":"274c9e4d68f91524e6a5f8904beea48e","abi":{"acl":"{postgres=X/postgres,authenticated=X/postgres}","oid":"44808","kind":"f","owner":"postgres","config":["search_path=\"\""],"secdef":true,"strict":false,"nspname":"public","proname":"combat_panel_commit_v1","returns":"jsonb","language":"plpgsql","parallel":"u","arg_modes":null,"arg_names":["p_command"],"arg_types":"3802","leakproof":false,"signature":"public.combat_panel_commit_v1(jsonb)","volatility":"v"}},{"oid":"31324","signature":"public.combat_v2_action_declare(uuid,uuid,jsonb,text,uuid)","source_md5":"77f98c15d1778bd7cc5e6fdfe8d221b8","ddl_md5":"91afc68d5d1419ed20d63b9c20fe14ea","abi":{"acl":"{postgres=X/postgres,authenticated=X/postgres,service_role=X/postgres}","oid":"31324","kind":"f","owner":"postgres","config":["search_path=\"\""],"secdef":true,"strict":false,"nspname":"public","proname":"combat_v2_action_declare","returns":"jsonb","language":"plpgsql","parallel":"u","arg_modes":null,"arg_names":["p_round","p_actor","p_intent","p_text","p_request_key"],"arg_types":"2950 2950 3802 25 2950","leakproof":false,"signature":"public.combat_v2_action_declare(uuid,uuid,jsonb,text,uuid)","volatility":"v"}},{"oid":"31311","signature":"public.combat_v2_actor_ability(uuid,text,uuid,boolean)","source_md5":"2ec5e6a87514a1997100990dde420a62","ddl_md5":"847221b518ed740a64afdcd00f7cd763","abi":{"acl":"{postgres=X/postgres,service_role=X/postgres}","oid":"31311","kind":"f","owner":"postgres","config":["search_path=\"\""],"secdef":true,"strict":false,"nspname":"public","proname":"combat_v2_actor_ability","returns":"jsonb","language":"sql","parallel":"u","arg_modes":null,"arg_names":["p_actor","p_source","p_ability","p_defense"],"arg_types":"2950 25 2950 16","leakproof":false,"signature":"public.combat_v2_actor_ability(uuid,text,uuid,boolean)","volatility":"s"}},{"oid":"31326","signature":"public.combat_v2_defense_declare(uuid,uuid,uuid,jsonb,text,uuid)","source_md5":"446494ad3becd44a65b241967810e589","ddl_md5":"5a97231f154dab9e97c2a03b0cc142ac","abi":{"acl":"{postgres=X/postgres,authenticated=X/postgres,service_role=X/postgres}","oid":"31326","kind":"f","owner":"postgres","config":["search_path=\"\""],"secdef":true,"strict":false,"nspname":"public","proname":"combat_v2_defense_declare","returns":"jsonb","language":"plpgsql","parallel":"u","arg_modes":null,"arg_names":["p_round","p_attack_declaration","p_actor","p_intent","p_text","p_request_key"],"arg_types":"2950 2950 2950 3802 25 2950","leakproof":false,"signature":"public.combat_v2_defense_declare(uuid,uuid,uuid,jsonb,text,uuid)","volatility":"v"}},{"oid":"31331","signature":"public.combat_v2_round_resolve(uuid,uuid)","source_md5":"bbe708d2f06cb96681141fce45915c28","ddl_md5":"d9d8438f3fc3bde3e799ee158055305f","abi":{"acl":"{postgres=X/postgres,service_role=X/postgres,authenticated=X/postgres}","oid":"31331","kind":"f","owner":"postgres","config":["search_path=\"\""],"secdef":true,"strict":false,"nspname":"public","proname":"combat_v2_round_resolve","returns":"jsonb","language":"plpgsql","parallel":"u","arg_modes":null,"arg_names":["p_round","p_request_key"],"arg_types":"2950 2950","leakproof":false,"signature":"public.combat_v2_round_resolve(uuid,uuid)","volatility":"v"}},{"oid":"19700","signature":"public.post_heal(uuid,uuid)","source_md5":"dcde447ee079472efa4fd41c1c911633","ddl_md5":"9fb236d5f72312f6fb33587a2981e427","abi":{"acl":"{postgres=X/postgres,service_role=X/postgres,authenticated=X/postgres}","oid":"19700","kind":"f","owner":"postgres","config":["search_path=public"],"secdef":true,"strict":false,"nspname":"public","proname":"post_heal","returns":"text","language":"plpgsql","parallel":"u","arg_modes":null,"arg_names":["p_location","p_target_user"],"arg_types":"2950 2950","leakproof":false,"signature":"public.post_heal(uuid,uuid)","volatility":"v"}}]$velo_shared_meta$::jsonb)
       AS e(signature text, source_md5 text, ddl_md5 text, abi jsonb)))) shared_sha, (SELECT jsonb_agg(jsonb_build_object('signature',p.oid::regprocedure::text,'source_md5',CASE p.oid WHEN 44940::oid THEN 'c3ae5fff837af5db1779970e73a414bd' WHEN 44669::oid THEN 'e1e6cd169797dc97d13aee366489d338' WHEN 44808::oid THEN '0b5a0ca3366bb6a302fcdfcddd306f48' WHEN 48763::oid THEN '05e73d85d678cb5b3200bc29b21c99a9' WHEN 48765::oid THEN 'e12934f6fd0e74edf84dc08ade7855de' WHEN 48770::oid THEN 'fdae855ce3462f4bbb21ec3da7105d59' WHEN 39288::oid THEN 'c9efcd8d9408f1316df17105cbaf2281' WHEN 31331::oid THEN 'bbe708d2f06cb96681141fce45915c28' WHEN 39291::oid THEN '9b278e6f9024b78be794aed4b23ca4ae' WHEN 51291::oid THEN 'ae3522f18c909b30c223e92f2882c838' WHEN 685921::oid THEN '58ee8836c59cc9f28ff9f3ff94299153' WHEN 45001::oid THEN '2e4848de4c59bfc1e1f460fbf329fb9c' WHEN 45348::oid THEN 'b8de7335961eeceefa28b21469900cea' WHEN 48764::oid THEN '74468122de46ceb379a579ba0eac75b1' WHEN 45347::oid THEN 'e5181a58a3fc736bf10a0e02dba3e348' WHEN 48768::oid THEN 'e472b9538e020d39a00472a890ebb706' WHEN 31311::oid THEN '2ec5e6a87514a1997100990dde420a62' WHEN 31310::oid THEN 'c54182dff687852cf654e73408c9ac71' WHEN 30222::oid THEN '97b94d31899d0bdb8276f6ad53eea644' WHEN 44936::oid THEN 'da0eec6d13a6c0379238533199e48f4e' WHEN 44994::oid THEN '232595d7ae9724429f4b4f4d0f8a2402' WHEN 684829::oid THEN '9c17aacce8e7e38597cd0980d6ed533e' WHEN 41419::oid THEN '318083236b37a6573e00f7061e41588e' ELSE md5(p.prosrc) END,'ddl_md5',CASE p.oid WHEN 44940::oid THEN '6273f7d573951ae327a062c9d2f37099' WHEN 44669::oid THEN '46424781b6fd6d34a0415090df6703f1' WHEN 44808::oid THEN '274c9e4d68f91524e6a5f8904beea48e' WHEN 48763::oid THEN 'ca5ba06b8ada95493fe45a68a1f50fe7' WHEN 48765::oid THEN '5eb56be61fda4fca6bcbe42e519fedb5' WHEN 48770::oid THEN '9875b83c334e4347bc585846e7086af1' WHEN 39288::oid THEN '57425688322ab5f43182bfe0597a4ac1' WHEN 31331::oid THEN 'd9d8438f3fc3bde3e799ee158055305f' WHEN 39291::oid THEN '2cb3c3d30a1c058770ef611fb90dbd80' WHEN 51291::oid THEN '7b26edb84b3174c9bc84faad279ad5b2' WHEN 685921::oid THEN '0ca00ced8dfbaa0b940fff06cd83978e' WHEN 45001::oid THEN '0efc4067b45eba7790191bc35b560590' WHEN 45348::oid THEN '95d9cff285f99114e3a89f4aba25120a' WHEN 48764::oid THEN '04f940aea00a8b3b88b3b6df0d1ffbad' WHEN 45347::oid THEN '8b402d8ce7b496b3b9c81e9a7d43e22b' WHEN 48768::oid THEN '9281070c6227efc5cd43c9fb4c861cac' WHEN 31311::oid THEN '847221b518ed740a64afdcd00f7cd763' WHEN 31310::oid THEN 'e8bb8dc977559b8343e099075a7d43fa' WHEN 30222::oid THEN '0b0c0a881ba0df6758b67b9262d079b9' WHEN 44936::oid THEN '429921d9e4f52d48bee34e4136d5fa54' WHEN 44994::oid THEN '95e0c0559898f60c848996e84a845a7c' WHEN 684829::oid THEN 'b86d92c434b923a5ec6431004f486b66' WHEN 41419::oid THEN 'cdabfe45e3a1426061e3cfe6615ecb7e' ELSE md5(pg_get_functiondef(p.oid)) END,
  'owner',pg_get_userbyid(p.proowner),'secdef',p.prosecdef,'config',p.proconfig,'acl',p.proacl::text,'volatility',p.provolatile::text)
  ORDER BY p.oid::regprocedure::text)FROM pg_proc p WHERE p.oid IN(
  'combat_panel_private.round_options_authoritative(uuid,uuid)'::regprocedure,
  'public.combat_v2_substitution_options_v1(uuid)'::regprocedure,'public.combat_v2_substitution_round_offers_v1(uuid,uuid)'::regprocedure,
  'public.combat_v2_substitution_select_v1(uuid,uuid)'::regprocedure,'clan_innata_private.catalogo_eligibility_release_v1()'::regprocedure,'combat_panel_private.publish_master_declaration(uuid,text)'::regprocedure)) peer6, (SELECT jsonb_agg(jsonb_build_object('signature',p.oid::regprocedure::text,'source_md5',CASE p.oid WHEN 44940::oid THEN 'c3ae5fff837af5db1779970e73a414bd' WHEN 44669::oid THEN 'e1e6cd169797dc97d13aee366489d338' WHEN 44808::oid THEN '0b5a0ca3366bb6a302fcdfcddd306f48' WHEN 48763::oid THEN '05e73d85d678cb5b3200bc29b21c99a9' WHEN 48765::oid THEN 'e12934f6fd0e74edf84dc08ade7855de' WHEN 48770::oid THEN 'fdae855ce3462f4bbb21ec3da7105d59' WHEN 39288::oid THEN 'c9efcd8d9408f1316df17105cbaf2281' WHEN 31331::oid THEN 'bbe708d2f06cb96681141fce45915c28' WHEN 39291::oid THEN '9b278e6f9024b78be794aed4b23ca4ae' WHEN 51291::oid THEN 'ae3522f18c909b30c223e92f2882c838' WHEN 685921::oid THEN '58ee8836c59cc9f28ff9f3ff94299153' WHEN 45001::oid THEN '2e4848de4c59bfc1e1f460fbf329fb9c' WHEN 45348::oid THEN 'b8de7335961eeceefa28b21469900cea' WHEN 48764::oid THEN '74468122de46ceb379a579ba0eac75b1' WHEN 45347::oid THEN 'e5181a58a3fc736bf10a0e02dba3e348' WHEN 48768::oid THEN 'e472b9538e020d39a00472a890ebb706' WHEN 31311::oid THEN '2ec5e6a87514a1997100990dde420a62' WHEN 31310::oid THEN 'c54182dff687852cf654e73408c9ac71' WHEN 30222::oid THEN '97b94d31899d0bdb8276f6ad53eea644' WHEN 44936::oid THEN 'da0eec6d13a6c0379238533199e48f4e' WHEN 44994::oid THEN '232595d7ae9724429f4b4f4d0f8a2402' WHEN 684829::oid THEN '9c17aacce8e7e38597cd0980d6ed533e' WHEN 41419::oid THEN '318083236b37a6573e00f7061e41588e' ELSE md5(p.prosrc) END,
'ddl_md5',CASE p.oid WHEN 44940::oid THEN '6273f7d573951ae327a062c9d2f37099' WHEN 44669::oid THEN '46424781b6fd6d34a0415090df6703f1' WHEN 44808::oid THEN '274c9e4d68f91524e6a5f8904beea48e' WHEN 48763::oid THEN 'ca5ba06b8ada95493fe45a68a1f50fe7' WHEN 48765::oid THEN '5eb56be61fda4fca6bcbe42e519fedb5' WHEN 48770::oid THEN '9875b83c334e4347bc585846e7086af1' WHEN 39288::oid THEN '57425688322ab5f43182bfe0597a4ac1' WHEN 31331::oid THEN 'd9d8438f3fc3bde3e799ee158055305f' WHEN 39291::oid THEN '2cb3c3d30a1c058770ef611fb90dbd80' WHEN 51291::oid THEN '7b26edb84b3174c9bc84faad279ad5b2' WHEN 685921::oid THEN '0ca00ced8dfbaa0b940fff06cd83978e' WHEN 45001::oid THEN '0efc4067b45eba7790191bc35b560590' WHEN 45348::oid THEN '95d9cff285f99114e3a89f4aba25120a' WHEN 48764::oid THEN '04f940aea00a8b3b88b3b6df0d1ffbad' WHEN 45347::oid THEN '8b402d8ce7b496b3b9c81e9a7d43e22b' WHEN 48768::oid THEN '9281070c6227efc5cd43c9fb4c861cac' WHEN 31311::oid THEN '847221b518ed740a64afdcd00f7cd763' WHEN 31310::oid THEN 'e8bb8dc977559b8343e099075a7d43fa' WHEN 30222::oid THEN '0b0c0a881ba0df6758b67b9262d079b9' WHEN 44936::oid THEN '429921d9e4f52d48bee34e4136d5fa54' WHEN 44994::oid THEN '95e0c0559898f60c848996e84a845a7c' WHEN 684829::oid THEN 'b86d92c434b923a5ec6431004f486b66' WHEN 41419::oid THEN 'cdabfe45e3a1426061e3cfe6615ecb7e' ELSE md5(pg_get_functiondef(p.oid)) END,'owner',pg_get_userbyid(p.proowner),'secdef',p.prosecdef,
'config',p.proconfig,'acl',p.proacl::text,'volatility',p.provolatile::text) ORDER BY p.oid::regprocedure::text) AS metadata FROM pg_proc p WHERE p.oid IN ('clan_innata_private.catalogo_eligibility_release_v1()'::regprocedure,'clan_innata_private.eligibility_release_assert()'::regprocedure)) compat, (SELECT jsonb_build_array(public.combat_v2_sha256((SELECT coalesce(jsonb_agg(jsonb_build_object('signature',n.nspname||'.'||p.proname||'('||oidvectortypes(p.proargtypes)||')','source_md5',CASE p.oid WHEN 44940::oid THEN 'c3ae5fff837af5db1779970e73a414bd' WHEN 44669::oid THEN 'e1e6cd169797dc97d13aee366489d338' WHEN 44808::oid THEN '0b5a0ca3366bb6a302fcdfcddd306f48' WHEN 48763::oid THEN '05e73d85d678cb5b3200bc29b21c99a9' WHEN 48765::oid THEN 'e12934f6fd0e74edf84dc08ade7855de' WHEN 48770::oid THEN 'fdae855ce3462f4bbb21ec3da7105d59' WHEN 39288::oid THEN 'c9efcd8d9408f1316df17105cbaf2281' WHEN 31331::oid THEN 'bbe708d2f06cb96681141fce45915c28' WHEN 39291::oid THEN '9b278e6f9024b78be794aed4b23ca4ae' WHEN 51291::oid THEN 'ae3522f18c909b30c223e92f2882c838' WHEN 685921::oid THEN '58ee8836c59cc9f28ff9f3ff94299153' WHEN 45001::oid THEN '2e4848de4c59bfc1e1f460fbf329fb9c' WHEN 45348::oid THEN 'b8de7335961eeceefa28b21469900cea' WHEN 48764::oid THEN '74468122de46ceb379a579ba0eac75b1' WHEN 45347::oid THEN 'e5181a58a3fc736bf10a0e02dba3e348' WHEN 48768::oid THEN 'e472b9538e020d39a00472a890ebb706' WHEN 31311::oid THEN '2ec5e6a87514a1997100990dde420a62' WHEN 31310::oid THEN 'c54182dff687852cf654e73408c9ac71' WHEN 30222::oid THEN '97b94d31899d0bdb8276f6ad53eea644' WHEN 44936::oid THEN 'da0eec6d13a6c0379238533199e48f4e' WHEN 44994::oid THEN '232595d7ae9724429f4b4f4d0f8a2402' WHEN 684829::oid THEN '9c17aacce8e7e38597cd0980d6ed533e' WHEN 41419::oid THEN '318083236b37a6573e00f7061e41588e' ELSE md5(p.prosrc) END,'ddl_md5',CASE p.oid WHEN 44940::oid THEN '6273f7d573951ae327a062c9d2f37099' WHEN 44669::oid THEN '46424781b6fd6d34a0415090df6703f1' WHEN 44808::oid THEN '274c9e4d68f91524e6a5f8904beea48e' WHEN 48763::oid THEN 'ca5ba06b8ada95493fe45a68a1f50fe7' WHEN 48765::oid THEN '5eb56be61fda4fca6bcbe42e519fedb5' WHEN 48770::oid THEN '9875b83c334e4347bc585846e7086af1' WHEN 39288::oid THEN '57425688322ab5f43182bfe0597a4ac1' WHEN 31331::oid THEN 'd9d8438f3fc3bde3e799ee158055305f' WHEN 39291::oid THEN '2cb3c3d30a1c058770ef611fb90dbd80' WHEN 51291::oid THEN '7b26edb84b3174c9bc84faad279ad5b2' WHEN 685921::oid THEN '0ca00ced8dfbaa0b940fff06cd83978e' WHEN 45001::oid THEN '0efc4067b45eba7790191bc35b560590' WHEN 45348::oid THEN '95d9cff285f99114e3a89f4aba25120a' WHEN 48764::oid THEN '04f940aea00a8b3b88b3b6df0d1ffbad' WHEN 45347::oid THEN '8b402d8ce7b496b3b9c81e9a7d43e22b' WHEN 48768::oid THEN '9281070c6227efc5cd43c9fb4c861cac' WHEN 31311::oid THEN '847221b518ed740a64afdcd00f7cd763' WHEN 31310::oid THEN 'e8bb8dc977559b8343e099075a7d43fa' WHEN 30222::oid THEN '0b0c0a881ba0df6758b67b9262d079b9' WHEN 44936::oid THEN '429921d9e4f52d48bee34e4136d5fa54' WHEN 44994::oid THEN '95e0c0559898f60c848996e84a845a7c' WHEN 684829::oid THEN 'b86d92c434b923a5ec6431004f486b66' WHEN 41419::oid THEN 'cdabfe45e3a1426061e3cfe6615ecb7e' ELSE md5(pg_get_functiondef(p.oid)) END,'owner',pg_get_userbyid(p.proowner),'acl',p.proacl::text,'config',p.proconfig,'secdef',p.prosecdef,'strict',p.proisstrict,'parallel',p.proparallel::text,'volatility',p.provolatile::text,'returns',pg_get_function_result(p.oid),'language',l.lanname)ORDER BY n.nspname,p.proname,oidvectortypes(p.proargtypes)),'[]'::jsonb)FROM pg_proc p JOIN pg_namespace n ON n.oid=p.pronamespace JOIN pg_language l ON l.oid=p.prolang WHERE p.oid IN(to_regprocedure('combat_v2_staff_nb_internal.origin_guard()'),to_regprocedure('combat_v2_staff_nb_internal.preparation_allowed(uuid)'),to_regprocedure('combat_v2_staff_nb_internal.choice(uuid)'),to_regprocedure('combat_v2_staff_nb_internal.roster_offers(uuid,bigint,uuid)'),to_regprocedure('combat_v2_staff_nb_internal.native_construct(uuid,uuid[],jsonb,jsonb,uuid,uuid)'),to_regprocedure('combat_v2_staff_nb_internal.mechanics_ready(uuid)'),to_regprocedure('combat_v2_staff_nb_internal.setup_protected(uuid,uuid)'),to_regprocedure('combat_v2_staff_nb_internal.commit_roster(jsonb)'),to_regprocedure('combat_v2_staff_nb_internal.roster_receipt(uuid)'),to_regprocedure('combat_v2_staff_nb_internal.pg_scope(uuid)'),to_regprocedure('combat_v2_staff_nb_internal.kai_frozen_authority(uuid)'),to_regprocedure('combat_v2_staff_nb_internal.kai_authority(uuid)'),to_regprocedure('combat_v2_staff_nb_internal.kai_contact(uuid,uuid)'),to_regprocedure('clan_aburame_private.verme_manifest_v1()'),to_regprocedure('clan_aburame_private.verme_release_v1()'),to_regprocedure('clan_aburame_private.verme_staff_scope_v1(uuid)'),to_regprocedure('clan_aburame_private.verme_scope_v1(uuid)'),to_regprocedure('clan_aburame_private.verme_event_v1(text,uuid,uuid,uuid,uuid,uuid,text,jsonb)'),to_regprocedure('clan_aburame_private.verme_staff_prepare_v1(uuid,uuid)'),to_regprocedure('clan_aburame_private.verme_meta_v1(uuid,boolean)'),to_regprocedure('clan_aburame_private.verme_bind_v1(uuid)'),to_regprocedure('clan_aburame_private.verme_frozen_v1(uuid)'),to_regprocedure('clan_aburame_private.verme_finish_v1(uuid,uuid,boolean,integer)'),to_regprocedure('clan_aburame_private.verme_tick_v1(uuid,uuid,uuid,text)'),to_regprocedure('clan_aburame_private.verme_end_context_v1()'),to_regprocedure('clan_aburame_private.verme_report_v1(uuid,uuid)'),to_regprocedure('clan_aburame_private.verme_reserve_round_v1(uuid)'),to_regprocedure('clan_aburame_private.verme_settle_round_v1(uuid)'),to_regprocedure('clan_aburame_private.verme_narrative_v1(uuid,uuid)'),to_regprocedure('clan_akimichi_private.common_staff_scope_v1(uuid)'),to_regprocedure('clan_akimichi_private.common_scope_v1(uuid,uuid)'),to_regprocedure('clan_akimichi_private.common_prepare_staff_v1(uuid,uuid,uuid)'),to_regprocedure('clan_akimichi_private.common_modifiers_v1(text,integer,integer,integer)'),to_regprocedure('clan_akimichi_private.common_set_form_v1(uuid,uuid,text)'),to_regprocedure('clan_akimichi_private.common_defer_upkeep_v1(uuid,uuid)'),to_regprocedure('clan_akimichi_private.common_flush_upkeep_v1(uuid)'),to_regprocedure('clan_akimichi_private.cellular_meta_v1(uuid)'),to_regprocedure('clan_akimichi_private.cellular_attack_eligible_v1(uuid,uuid)'),to_regprocedure('clan_akimichi_private.cellular_bind_v1(uuid)'),to_regprocedure('clan_akimichi_private.cellular_source_valid_v1(uuid)'),to_regprocedure('clan_akimichi_private.cellular_pay_v1(uuid)'),to_regprocedure('clan_akimichi_private.cellular_snapshot_v1(uuid,jsonb)'),to_regprocedure('clan_akimichi_private.cellular_mark_v1(uuid,jsonb)'),to_regprocedure('clan_akimichi_private.cellular_calculate_v1(uuid,jsonb,integer,integer)'),to_regprocedure('clan_akimichi_private.common_calorie_balance_v1(uuid,uuid,uuid,uuid)'),to_regprocedure('clan_akimichi_private.common_admit_calories_v1(uuid)'),to_regprocedure('clan_akimichi_private.common_preflight_calories_v1(uuid)'),to_regprocedure('clan_akimichi_private.super_direct_visible_v1(uuid,uuid)'),to_regprocedure('clan_akimichi_private.common_attack_power_freeze_v1(uuid)'),to_regprocedure('clan_akimichi_private.common_panel_offers_v1(uuid,bigint,jsonb)'),to_regprocedure('clan_akimichi_private.common_panel_commit_v1(jsonb)'),to_regprocedure('clan_akimichi_private.common_result_label_v1(jsonb)'),to_regprocedure('clan_akimichi_private.common_source_root_v1()'),to_regprocedure('clan_sabaku_private.armor_absorb_packet_v1(uuid,uuid,uuid,uuid,integer)'),to_regprocedure('combat_panel_private.nara_adv_pool_v1(uuid)'),to_regprocedure('combat_panel_private.nara_adv_protected_v1(uuid)'),to_regprocedure('combat_panel_private.nara_adv_scope_v1(uuid)'),to_regprocedure('combat_panel_private.nara_adv_prepare_v1(uuid,uuid)'),to_regprocedure('combat_panel_private.nara_strangle_meta_v1(uuid)'),to_regprocedure('combat_panel_private.nara_strangle_action_meta_v1(uuid,uuid,jsonb)'),to_regprocedure('combat_panel_private.nara_strangle_bind_v1(uuid)'),to_regprocedure('combat_panel_private.nara_strangle_parent_valid_v1(uuid)'),to_regprocedure('combat_panel_private.nara_strangle_lifecycle_v1(uuid)'),to_regprocedure('combat_panel_private.nara_strangle_packet_v1(uuid,uuid,uuid,text)'),to_regprocedure('combat_panel_private.nara_strangle_resolve_v1(uuid)'),to_regprocedure('combat_panel_private.nara_strangle_turn_v1(uuid,uuid,uuid,text)'),to_regprocedure('combat_panel_private.nara_strangle_facts_revision_v1(jsonb)'),to_regprocedure('combat_panel_private.nara_strangle_facts_v1(uuid,uuid)'),to_regprocedure('combat_panel_private.nara_adv_history_guard_v1()'),to_regprocedure('combat_panel_private.nara_strangle_end_event_v1()'),to_regprocedure('combat_panel_private.nara_strangle_terminal_report_v1(uuid)'),to_regprocedure('combat_panel_private.nara_strangle_lifecycle_context_v1(uuid)'),to_regprocedure('combat_panel_private.nara_adv_offers_v1(uuid,bigint,jsonb)'),to_regprocedure('combat_panel_private.nara_adv_commit_v1(jsonb)'),to_regprocedure('combat_panel_private.nara_strangle_lifecycle_trigger_v1()')))),public.combat_v2_sha256((SELECT coalesce(jsonb_agg(jsonb_build_object('signature',n.nspname||'.'||p.proname||'('||oidvectortypes(p.proargtypes)||')','source_md5',CASE p.oid WHEN 44940::oid THEN 'c3ae5fff837af5db1779970e73a414bd' WHEN 44669::oid THEN 'e1e6cd169797dc97d13aee366489d338' WHEN 44808::oid THEN '0b5a0ca3366bb6a302fcdfcddd306f48' WHEN 48763::oid THEN '05e73d85d678cb5b3200bc29b21c99a9' WHEN 48765::oid THEN 'e12934f6fd0e74edf84dc08ade7855de' WHEN 48770::oid THEN 'fdae855ce3462f4bbb21ec3da7105d59' WHEN 39288::oid THEN 'c9efcd8d9408f1316df17105cbaf2281' WHEN 31331::oid THEN 'bbe708d2f06cb96681141fce45915c28' WHEN 39291::oid THEN '9b278e6f9024b78be794aed4b23ca4ae' WHEN 51291::oid THEN 'ae3522f18c909b30c223e92f2882c838' WHEN 685921::oid THEN '58ee8836c59cc9f28ff9f3ff94299153' WHEN 45001::oid THEN '2e4848de4c59bfc1e1f460fbf329fb9c' WHEN 45348::oid THEN 'b8de7335961eeceefa28b21469900cea' WHEN 48764::oid THEN '74468122de46ceb379a579ba0eac75b1' WHEN 45347::oid THEN 'e5181a58a3fc736bf10a0e02dba3e348' WHEN 48768::oid THEN 'e472b9538e020d39a00472a890ebb706' WHEN 31311::oid THEN '2ec5e6a87514a1997100990dde420a62' WHEN 31310::oid THEN 'c54182dff687852cf654e73408c9ac71' WHEN 30222::oid THEN '97b94d31899d0bdb8276f6ad53eea644' WHEN 44936::oid THEN 'da0eec6d13a6c0379238533199e48f4e' WHEN 44994::oid THEN '232595d7ae9724429f4b4f4d0f8a2402' WHEN 684829::oid THEN '9c17aacce8e7e38597cd0980d6ed533e' WHEN 41419::oid THEN '318083236b37a6573e00f7061e41588e' ELSE md5(p.prosrc) END,'ddl_md5',CASE p.oid WHEN 44940::oid THEN '6273f7d573951ae327a062c9d2f37099' WHEN 44669::oid THEN '46424781b6fd6d34a0415090df6703f1' WHEN 44808::oid THEN '274c9e4d68f91524e6a5f8904beea48e' WHEN 48763::oid THEN 'ca5ba06b8ada95493fe45a68a1f50fe7' WHEN 48765::oid THEN '5eb56be61fda4fca6bcbe42e519fedb5' WHEN 48770::oid THEN '9875b83c334e4347bc585846e7086af1' WHEN 39288::oid THEN '57425688322ab5f43182bfe0597a4ac1' WHEN 31331::oid THEN 'd9d8438f3fc3bde3e799ee158055305f' WHEN 39291::oid THEN '2cb3c3d30a1c058770ef611fb90dbd80' WHEN 51291::oid THEN '7b26edb84b3174c9bc84faad279ad5b2' WHEN 685921::oid THEN '0ca00ced8dfbaa0b940fff06cd83978e' WHEN 45001::oid THEN '0efc4067b45eba7790191bc35b560590' WHEN 45348::oid THEN '95d9cff285f99114e3a89f4aba25120a' WHEN 48764::oid THEN '04f940aea00a8b3b88b3b6df0d1ffbad' WHEN 45347::oid THEN '8b402d8ce7b496b3b9c81e9a7d43e22b' WHEN 48768::oid THEN '9281070c6227efc5cd43c9fb4c861cac' WHEN 31311::oid THEN '847221b518ed740a64afdcd00f7cd763' WHEN 31310::oid THEN 'e8bb8dc977559b8343e099075a7d43fa' WHEN 30222::oid THEN '0b0c0a881ba0df6758b67b9262d079b9' WHEN 44936::oid THEN '429921d9e4f52d48bee34e4136d5fa54' WHEN 44994::oid THEN '95e0c0559898f60c848996e84a845a7c' WHEN 684829::oid THEN 'b86d92c434b923a5ec6431004f486b66' WHEN 41419::oid THEN 'cdabfe45e3a1426061e3cfe6615ecb7e' ELSE md5(pg_get_functiondef(p.oid)) END,'owner',pg_get_userbyid(p.proowner),'acl',p.proacl::text,'config',p.proconfig,'secdef',p.prosecdef,'strict',p.proisstrict,'parallel',p.proparallel::text,'volatility',p.provolatile::text,'returns',pg_get_function_result(p.oid),'language',l.lanname)ORDER BY n.nspname,p.proname,oidvectortypes(p.proargtypes)),'[]'::jsonb)FROM pg_proc p JOIN pg_namespace n ON n.oid=p.pronamespace JOIN pg_language l ON l.oid=p.prolang WHERE p.oid IN(to_regprocedure('clan_aburame_private.actor_ability(uuid,text,uuid,boolean,jsonb)'),to_regprocedure('clan_aburame_private.attack_power_source(uuid,uuid)'),to_regprocedure('clan_aburame_private.commit_control(jsonb,jsonb,combat_consumer_private.activities,combat_consumer_private.offers,uuid)'),to_regprocedure('clan_aburame_private.commit_master_stop(jsonb)'),to_regprocedure('clan_aburame_private.consumer_options(jsonb)'),to_regprocedure('clan_aburame_private.master_offers(uuid,bigint,jsonb)'),to_regprocedure('clan_akimichi_private.apply_calorie_event(uuid,uuid,boolean,uuid,text,integer,integer,uuid,timestamp with time zone)'),to_regprocedure('clan_akimichi_private.begin_personal_turn(uuid,uuid)'),to_regprocedure('clan_akimichi_private.bind_partial(uuid)'),to_regprocedure('clan_akimichi_private.end_form(uuid,uuid,text)'),to_regprocedure('clan_akimichi_private.form_change_offer(uuid)'),to_regprocedure('clan_akimichi_private.form_impact(uuid,uuid,uuid,text,text,text,jsonb)'),to_regprocedure('clan_akimichi_private.movement_maximum(uuid,numeric)'),to_regprocedure('clan_akimichi_private.partial_meta(uuid,jsonb)'),to_regprocedure('clan_akimichi_private.set_form(uuid,uuid,boolean)'),to_regprocedure('clan_sabaku_private.armor_absorb(uuid,integer)'),to_regprocedure('clan_sabaku_private.armor_narrative_round(uuid)'),to_regprocedure('clan_sabaku_private.armor_round_facts(uuid)'),to_regprocedure('combat_consumer_private.after_publish(uuid,uuid)'),to_regprocedure('combat_consumer_private.commit_exchange(jsonb,jsonb)'),to_regprocedure('combat_consumer_private.narrative_context(uuid)'),to_regprocedure('combat_consumer_private.narrative_declaration_supported(uuid)'),to_regprocedure('combat_consumer_private.validate_narrative_result(jsonb)'),to_regprocedure('combat_effects_private.lifecycle_actor_end(uuid)'),to_regprocedure('combat_effects_private.lifecycle_open(uuid,uuid)'),to_regprocedure('combat_effects_private.lifecycle_session_end(uuid)'),to_regprocedure('combat_effects_private.personal_turn_end(uuid,uuid,uuid,text)'),to_regprocedure('combat_panel_private.catalog_result_label_v1(jsonb)'),to_regprocedure('combat_panel_private.consumer_commit_authoritative(jsonb)'),to_regprocedure('combat_panel_private.master_admin_offers(uuid,bigint,jsonb)'),to_regprocedure('combat_panel_private.master_options(uuid,uuid,bigint)'),to_regprocedure('combat_panel_private.nara_shadow_level_v1(uuid)'),to_regprocedure('combat_panel_private.narrative_declaration_facts(uuid)'),to_regprocedure('combat_panel_private.narrative_ordinary_context(uuid)'),to_regprocedure('combat_panel_private.ordinary_options(uuid,uuid,bigint)'),to_regprocedure('combat_spatial.movement_commit(uuid,uuid,uuid)'),to_regprocedure('combat_v2_genjutsu_internal.ally_contact(uuid,uuid)'),to_regprocedure('combat_v2_genjutsu_internal.master_options(uuid,bigint)'),to_regprocedure('combat_v2_genjutsu_internal.release_intents(uuid)'),to_regprocedure('combat_v2_genjutsu_internal.release_meta(uuid,uuid,uuid,jsonb)'),to_regprocedure('combat_v2_genjutsu_internal.resolve_release(uuid)'),to_regprocedure('combat_v2_genjutsu_internal.scope(uuid)'),to_regprocedure('combat_v2_multitarget_internal.resolve_parent(uuid,uuid,uuid,boolean)'),to_regprocedure('mission_factory_owner.quest_combat_offer_source_guard_v1()'),to_regprocedure('public._combat_calcola(text,jsonb,jsonb,text,text,integer,text,integer,integer,integer,integer,boolean)'),to_regprocedure('public.combat_consumer_narrative_claim_v1(uuid,text,uuid)'),to_regprocedure('public.combat_consumer_narrative_complete_v1(uuid,jsonb,uuid)'),to_regprocedure('public.combat_panel_commit_v1(jsonb)'),to_regprocedure('public.combat_v2_action_declare(uuid,uuid,jsonb,text,uuid)'),to_regprocedure('public.combat_v2_actor_ability(uuid,text,uuid,boolean)'),to_regprocedure('public.combat_v2_defense_declare(uuid,uuid,uuid,jsonb,text,uuid)'),to_regprocedure('public.combat_v2_round_resolve(uuid,uuid)'),to_regprocedure('public.master_v2_encounter_open_ninja_book_v1_human_ai_core(uuid,uuid[],jsonb,jsonb,uuid)'),to_regprocedure('combat_panel_private.publish_master_declaration(uuid,text)'),to_regprocedure('clan_innata_private.eligibility_release_assert()'),to_regprocedure('combat_panel_private.cure_neutral_preset_v1(uuid,uuid,uuid,jsonb)'),to_regprocedure('combat_panel_private.master_actor_offers(uuid,bigint,jsonb,jsonb)')))),public.combat_v2_sha256((SELECT jsonb_build_object('tables',(SELECT jsonb_agg(jsonb_build_object('schema',n.nspname,'name',c.relname,'owner',pg_get_userbyid(c.relowner),'acl',c.relacl::text,'rls',c.relrowsecurity,'force_rls',c.relforcerowsecurity,'columns',(SELECT jsonb_agg(jsonb_build_object('name',a.attname,'type',format_type(a.atttypid,a.atttypmod),'notnull',a.attnotnull,'default',pg_get_expr(d.adbin,d.adrelid),'identity',a.attidentity,'generated',a.attgenerated)ORDER BY a.attnum)FROM pg_attribute a LEFT JOIN pg_attrdef d ON d.adrelid=a.attrelid AND d.adnum=a.attnum WHERE a.attrelid=c.oid AND a.attnum>0 AND NOT a.attisdropped),'constraints',(SELECT coalesce(jsonb_agg(jsonb_build_object('name',q.conname,'definition',pg_get_constraintdef(q.oid),'validated',q.convalidated,'deferrable',q.condeferrable,'deferred',q.condeferred)ORDER BY q.conname),'[]'::jsonb)FROM pg_constraint q WHERE q.conrelid=c.oid),'indexes',(SELECT coalesce(jsonb_agg(jsonb_build_object('name',ci.relname,'definition',pg_get_indexdef(i.indexrelid),'valid',i.indisvalid,'ready',i.indisready,'live',i.indislive)ORDER BY ci.relname),'[]'::jsonb)FROM pg_index i JOIN pg_class ci ON ci.oid=i.indexrelid WHERE i.indrelid=c.oid),'triggers',(SELECT coalesce(jsonb_agg(pg_get_triggerdef(t.oid)ORDER BY t.tgname),'[]'::jsonb)FROM pg_trigger t WHERE t.tgrelid=c.oid AND NOT t.tgisinternal),'policies',(SELECT coalesce(jsonb_agg(jsonb_build_object('name',p.polname,'cmd',p.polcmd,'roles',p.polroles,'using',pg_get_expr(p.polqual,p.polrelid),'check',pg_get_expr(p.polwithcheck,p.polrelid))ORDER BY p.polname),'[]'::jsonb)FROM pg_policy p WHERE p.polrelid=c.oid))ORDER BY n.nspname,c.relname)FROM pg_class c JOIN pg_namespace n ON n.oid=c.relnamespace WHERE c.oid IN(to_regclass('combat_v2_staff_nb_internal.gate'),to_regclass('combat_v2_staff_nb_internal.roster_sources'),to_regclass('combat_v2_staff_nb_internal.admissions'),to_regclass('clan_aburame_private.verme_gate_v1'),to_regclass('clan_aburame_private.verme_staff_profiles_v1'),to_regclass('clan_aburame_private.verme_sources_v1'),to_regclass('clan_aburame_private.verme_poison_v1'),to_regclass('clan_aburame_private.verme_events_v1'),to_regclass('clan_akimichi_private.common_gate_v1'),to_regclass('clan_akimichi_private.common_staff_profiles_v1'),to_regclass('clan_akimichi_private.common_form_commands_v1'),to_regclass('clan_akimichi_private.common_attack_powers_v1'),to_regclass('clan_akimichi_private.common_pending_upkeep_v1'),to_regclass('clan_akimichi_private.cellular_sources_v1'),to_regclass('combat_panel_private.nara_adv_gate_v1'),to_regclass('combat_panel_private.nara_adv_staff_v1'),to_regclass('combat_panel_private.nara_strangle_sources_v1'),to_regclass('combat_panel_private.nara_strangle_events_v1'),to_regclass('public.master_v2_nb_actor_offers_v1'),to_regclass('clan_akimichi_private.forms'))),'catalog',(SELECT jsonb_agg(jsonb_build_object('id',t.id,'sha256',public.combat_v2_sha256(to_jsonb(t)))ORDER BY t.id)FROM public.clan_techniques t WHERE id IN('0a15282f-d6b5-4ee3-ad52-7fac2525444d','f5f26cb5-9b6f-44b3-94bc-c329a0a88b93','687b058a-807d-4cf7-8bcf-21147931b0f6')),'NBtuples',(SELECT jsonb_build_object('mechanical',(SELECT jsonb_agg(jsonb_build_object('id',v.id,'template_id',v.template_id,'content_sha256',v.content_sha256)ORDER BY v.id)FROM public.nb_mechanical_versions v WHERE v.id IN('31da0000-0000-4000-8000-000000000111','31da0000-0000-4000-8000-000000000112')),'narrative',(SELECT jsonb_agg(jsonb_build_object('id',v.id,'template_id',v.template_id,'content_sha256',v.content_sha256)ORDER BY v.id)FROM public.nb_template_versions v WHERE v.id IN('31da0000-0000-4000-8000-000000000211','31da0000-0000-4000-8000-000000000212')))),'new_triggers',(SELECT jsonb_agg(jsonb_build_object('table',e->>'table','name',t.tgname,'function',t.tgfoid::regprocedure::text,'enabled',t.tgenabled::text,'type',t.tgtype,'definition',pg_get_triggerdef(t.oid),'args_sha256',encode(extensions.digest(t.tgargs,'sha256'),'hex'))ORDER BY e->>'table',e->>'name')FROM jsonb_array_elements($joint_triggers$[{"table":"combat_v2_staff_nb_internal.roster_sources","name":"staff_nb_origin_immutable"},{"table":"public.combat_v2_sessions","name":"aburame_verme_end_session_v1"},{"table":"public.combat_v2_actors","name":"aburame_verme_end_actor_v1"},{"table":"combat_panel_private.nara_strangle_sources_v1","name":"nara_strangle_snapshot_guard_v1"},{"table":"combat_panel_private.nara_strangle_events_v1","name":"nara_strangle_events_guard_v1"},{"table":"combat_panel_private.nara_adv_staff_v1","name":"nara_strangle_staff_guard_v1"},{"table":"combat_panel_private.nara_strangle_sources_v1","name":"nara_strangle_ended_event_v1"},{"table":"combat_panel_private.immobilizations","name":"nara_strangle_parent_end_v1"},{"table":"combat_spatial.actor_states","name":"nara_strangle_geometry_end_v1"}]$joint_triggers$::jsonb)e JOIN pg_trigger t ON t.tgrelid=to_regclass(e->>'table')AND t.tgname=e->>'name'AND NOT t.tgisinternal),'NBnamespace',(SELECT jsonb_build_object('owner',pg_get_userbyid(nspowner),'acl',nspacl::text)FROM pg_namespace WHERE nspname='combat_v2_staff_nb_internal')))))) descriptor
), staged AS MATERIALIZED (
  SELECT base.*, jsonb_set(jsonb_set(jsonb_set(jsonb_set(jsonb_set(jsonb_set(jsonb_set(jsonb_set(jsonb_set(jsonb_set(jsonb_set(jsonb_set(jsonb_set(jsonb_set(jsonb_set(jsonb_set(jsonb_set(jsonb_set(jsonb_set(jsonb_set(jsonb_set(jsonb_set(jsonb_set(jsonb_set(jsonb_set(jsonb_set(jsonb_set(jsonb_set(jsonb_set(jsonb_set(jsonb_set(jsonb_set(jsonb_set(jsonb_set(jsonb_set(jsonb_set(jsonb_set(jsonb_set(jsonb_set(jsonb_set(jsonb_set(jsonb_set(jsonb_set(jsonb_set(jsonb_set(jsonb_set(jsonb_set(jsonb_set(jsonb_set(jsonb_set(jsonb_set(jsonb_set(jsonb_set(jsonb_set(jsonb_set(r,ARRAY['db_core','all_function_headers','228','source_md5']::text[],to_jsonb('c3ae5fff837af5db1779970e73a414bd'::text),false),ARRAY['db_core','all_function_headers','228','ddl_md5']::text[],to_jsonb('6273f7d573951ae327a062c9d2f37099'::text),false),ARRAY['db_core','combat_innata_functions','48763','source_md5']::text[],to_jsonb('05e73d85d678cb5b3200bc29b21c99a9'::text),false),ARRAY['db_core','combat_innata_functions','48763','ddl_md5']::text[],to_jsonb('ca5ba06b8ada95493fe45a68a1f50fe7'::text),false),ARRAY['db_core','innata_all_clan_functions','48763','source_md5']::text[],to_jsonb('05e73d85d678cb5b3200bc29b21c99a9'::text),false),ARRAY['db_core','innata_all_clan_functions','48763','ddl_md5']::text[],to_jsonb('ca5ba06b8ada95493fe45a68a1f50fe7'::text),false),ARRAY['db_core','combat_innata_functions','48765','source_md5']::text[],to_jsonb('e12934f6fd0e74edf84dc08ade7855de'::text),false),ARRAY['db_core','combat_innata_functions','48765','ddl_md5']::text[],to_jsonb('5eb56be61fda4fca6bcbe42e519fedb5'::text),false),ARRAY['db_core','innata_all_clan_functions','48765','source_md5']::text[],to_jsonb('e12934f6fd0e74edf84dc08ade7855de'::text),false),ARRAY['db_core','innata_all_clan_functions','48765','ddl_md5']::text[],to_jsonb('5eb56be61fda4fca6bcbe42e519fedb5'::text),false),ARRAY['db_core','innata_maintained_functions','clan_innata_private.combat_scope(uuid,uuid)','source_md5']::text[],to_jsonb('e12934f6fd0e74edf84dc08ade7855de'::text),false),ARRAY['db_core','innata_maintained_functions','clan_innata_private.combat_scope(uuid,uuid)','ddl_md5']::text[],to_jsonb('5eb56be61fda4fca6bcbe42e519fedb5'::text),false),ARRAY['db_core','combat_innata_functions','48770','source_md5']::text[],to_jsonb('fdae855ce3462f4bbb21ec3da7105d59'::text),false),ARRAY['db_core','combat_innata_functions','48770','ddl_md5']::text[],to_jsonb('9875b83c334e4347bc585846e7086af1'::text),false),ARRAY['db_core','innata_all_clan_functions','48770','source_md5']::text[],to_jsonb('fdae855ce3462f4bbb21ec3da7105d59'::text),false),ARRAY['db_core','innata_all_clan_functions','48770','ddl_md5']::text[],to_jsonb('9875b83c334e4347bc585846e7086af1'::text),false),ARRAY['db_core','innata_maintained_functions','clan_innata_private.combat_transition(uuid,uuid,text,uuid,int8)','source_md5']::text[],to_jsonb('fdae855ce3462f4bbb21ec3da7105d59'::text),false),ARRAY['db_core','innata_maintained_functions','clan_innata_private.combat_transition(uuid,uuid,text,uuid,int8)','ddl_md5']::text[],to_jsonb('9875b83c334e4347bc585846e7086af1'::text),false),ARRAY['db_core','combat_innata_functions','31331','source_md5']::text[],to_jsonb('bbe708d2f06cb96681141fce45915c28'::text),false),ARRAY['db_core','combat_innata_functions','31331','ddl_md5']::text[],to_jsonb('d9d8438f3fc3bde3e799ee158055305f'::text),false),ARRAY['db_core','combat_innata_functions','39291','source_md5']::text[],to_jsonb('9b278e6f9024b78be794aed4b23ca4ae'::text),false),ARRAY['db_core','combat_innata_functions','39291','ddl_md5']::text[],to_jsonb('2cb3c3d30a1c058770ef611fb90dbd80'::text),false),ARRAY['db_core','combat_innata_functions','48764','source_md5']::text[],to_jsonb('74468122de46ceb379a579ba0eac75b1'::text),false),ARRAY['db_core','combat_innata_functions','48764','ddl_md5']::text[],to_jsonb('04f940aea00a8b3b88b3b6df0d1ffbad'::text),false),ARRAY['db_core','innata_all_clan_functions','48764','source_md5']::text[],to_jsonb('74468122de46ceb379a579ba0eac75b1'::text),false),ARRAY['db_core','innata_all_clan_functions','48764','ddl_md5']::text[],to_jsonb('04f940aea00a8b3b88b3b6df0d1ffbad'::text),false),ARRAY['db_core','innata_maintained_functions','clan_innata_private.combat_begin_turn(uuid,uuid)','source_md5']::text[],to_jsonb('74468122de46ceb379a579ba0eac75b1'::text),false),ARRAY['db_core','innata_maintained_functions','clan_innata_private.combat_begin_turn(uuid,uuid)','ddl_md5']::text[],to_jsonb('04f940aea00a8b3b88b3b6df0d1ffbad'::text),false),ARRAY['db_core','combat_innata_functions','48768','source_md5']::text[],to_jsonb('e472b9538e020d39a00472a890ebb706'::text),false),ARRAY['db_core','combat_innata_functions','48768','ddl_md5']::text[],to_jsonb('9281070c6227efc5cd43c9fb4c861cac'::text),false),ARRAY['db_core','innata_all_clan_functions','48768','source_md5']::text[],to_jsonb('e472b9538e020d39a00472a890ebb706'::text),false),ARRAY['db_core','innata_all_clan_functions','48768','ddl_md5']::text[],to_jsonb('9281070c6227efc5cd43c9fb4c861cac'::text),false),ARRAY['db_core','all_function_headers','12','source_md5']::text[],to_jsonb('da0eec6d13a6c0379238533199e48f4e'::text),false),ARRAY['db_core','all_function_headers','12','ddl_md5']::text[],to_jsonb('429921d9e4f52d48bee34e4136d5fa54'::text),false),ARRAY['db_core','c1266_functions','126','source_md5']::text[],to_jsonb('da0eec6d13a6c0379238533199e48f4e'::text),false),ARRAY['db_core','c1266_functions','126','ddl_md5']::text[],to_jsonb('429921d9e4f52d48bee34e4136d5fa54'::text),false),ARRAY['db_core','combat_innata_functions','41419','source_md5']::text[],to_jsonb('318083236b37a6573e00f7061e41588e'::text),false),ARRAY['db_core','combat_innata_functions','41419','ddl_md5']::text[],to_jsonb('cdabfe45e3a1426061e3cfe6615ecb7e'::text),false),ARRAY['db_core','catalogo_eligibility_compat','shared_manifest_sha256']::text[],to_jsonb(f1.shared_sha),false),ARRAY['config','catalogo_eligibility_compat','shared_manifest_sha256']::text[],to_jsonb(f1.shared_sha),false),ARRAY['db_core','cure_command_amendment','shared_manifest_sha256']::text[],to_jsonb(f1.shared_sha),false),ARRAY['config','cure_command_amendment','shared_manifest_sha256']::text[],to_jsonb(f1.shared_sha),false),ARRAY['db_core','catalogo_eligibility_compat','functions']::text[],f1.compat,false),ARRAY['config','catalogo_eligibility_compat','functions']::text[],f1.compat,false),ARRAY['db_core','catalogo_eligibility_compat','functions_manifest_sha256']::text[],to_jsonb(public.combat_v2_sha256(f1.compat)),false),ARRAY['config','catalogo_eligibility_compat','functions_manifest_sha256']::text[],to_jsonb(public.combat_v2_sha256(f1.compat)),false),ARRAY['db_core','catalogo_eligibility_compat','helper_source_md5']::text[],f1.compat#>'{0,source_md5}',false),ARRAY['config','catalogo_eligibility_compat','helper_source_md5']::text[],f1.compat#>'{0,source_md5}',false),ARRAY['db_core','cure_command_amendment','helper_source_md5']::text[],f1.compat#>'{0,source_md5}',false),ARRAY['config','cure_command_amendment','helper_source_md5']::text[],f1.compat#>'{0,source_md5}',false),ARRAY['db_core','cure_command_amendment','functions_manifest_sha256']::text[],to_jsonb(public.combat_v2_sha256(f1.peer6)),false),ARRAY['config','cure_command_amendment','functions_manifest_sha256']::text[],to_jsonb(public.combat_v2_sha256(f1.peer6)),false),ARRAY['db_core','catalogo_families','2']::text[],f1.descriptor,false),ARRAY['db_core','velo_staff']::text[],to_jsonb('c3612c94016774b3457ea72312e9a1ef763caca10bcec2151a7a522980d13c13'::text),true),ARRAY['config','velo_staff']::text[],to_jsonb('c3612c94016774b3457ea72312e9a1ef763caca10bcec2151a7a522980d13c13'::text),true) candidate,
    ((r#>ARRAY['db_core','all_function_headers','228','source_md5']::text[]) IS NOT DISTINCT FROM to_jsonb('daccab39aa3e67a4c1a361860b8adbdf'::text)
 AND (r#>ARRAY['db_core','all_function_headers','228','ddl_md5']::text[]) IS NOT DISTINCT FROM to_jsonb('d48e2877b5b38f53724dcb75368c7464'::text)
 AND (r#>ARRAY['db_core','combat_innata_functions','48763','source_md5']::text[]) IS NOT DISTINCT FROM to_jsonb('5385f7e1bdc32ee7d59133e95815e21b'::text)
 AND (r#>ARRAY['db_core','combat_innata_functions','48763','ddl_md5']::text[]) IS NOT DISTINCT FROM to_jsonb('c1d1c95774c9018b5a2cbf5dc224c5d5'::text)
 AND (r#>ARRAY['db_core','innata_all_clan_functions','48763','source_md5']::text[]) IS NOT DISTINCT FROM to_jsonb('5385f7e1bdc32ee7d59133e95815e21b'::text)
 AND (r#>ARRAY['db_core','innata_all_clan_functions','48763','ddl_md5']::text[]) IS NOT DISTINCT FROM to_jsonb('c1d1c95774c9018b5a2cbf5dc224c5d5'::text)
 AND (r#>ARRAY['db_core','combat_innata_functions','48765','source_md5']::text[]) IS NOT DISTINCT FROM to_jsonb('1e4edfe0c15ef30d9e2a302660f16925'::text)
 AND (r#>ARRAY['db_core','combat_innata_functions','48765','ddl_md5']::text[]) IS NOT DISTINCT FROM to_jsonb('84c2c403580e9294bd60e4971a26a079'::text)
 AND (r#>ARRAY['db_core','innata_all_clan_functions','48765','source_md5']::text[]) IS NOT DISTINCT FROM to_jsonb('1e4edfe0c15ef30d9e2a302660f16925'::text)
 AND (r#>ARRAY['db_core','innata_all_clan_functions','48765','ddl_md5']::text[]) IS NOT DISTINCT FROM to_jsonb('84c2c403580e9294bd60e4971a26a079'::text)
 AND (r#>ARRAY['db_core','innata_maintained_functions','clan_innata_private.combat_scope(uuid,uuid)','source_md5']::text[]) IS NOT DISTINCT FROM to_jsonb('1e4edfe0c15ef30d9e2a302660f16925'::text)
 AND (r#>ARRAY['db_core','innata_maintained_functions','clan_innata_private.combat_scope(uuid,uuid)','ddl_md5']::text[]) IS NOT DISTINCT FROM to_jsonb('84c2c403580e9294bd60e4971a26a079'::text)
 AND (r#>ARRAY['db_core','combat_innata_functions','48770','source_md5']::text[]) IS NOT DISTINCT FROM to_jsonb('c0cc84dede19bba696ab104456e5b95d'::text)
 AND (r#>ARRAY['db_core','combat_innata_functions','48770','ddl_md5']::text[]) IS NOT DISTINCT FROM to_jsonb('adcee64c879b2b45e80a331891dcb7a8'::text)
 AND (r#>ARRAY['db_core','innata_all_clan_functions','48770','source_md5']::text[]) IS NOT DISTINCT FROM to_jsonb('c0cc84dede19bba696ab104456e5b95d'::text)
 AND (r#>ARRAY['db_core','innata_all_clan_functions','48770','ddl_md5']::text[]) IS NOT DISTINCT FROM to_jsonb('adcee64c879b2b45e80a331891dcb7a8'::text)
 AND (r#>ARRAY['db_core','innata_maintained_functions','clan_innata_private.combat_transition(uuid,uuid,text,uuid,int8)','source_md5']::text[]) IS NOT DISTINCT FROM to_jsonb('c0cc84dede19bba696ab104456e5b95d'::text)
 AND (r#>ARRAY['db_core','innata_maintained_functions','clan_innata_private.combat_transition(uuid,uuid,text,uuid,int8)','ddl_md5']::text[]) IS NOT DISTINCT FROM to_jsonb('adcee64c879b2b45e80a331891dcb7a8'::text)
 AND (r#>ARRAY['db_core','combat_innata_functions','31331','source_md5']::text[]) IS NOT DISTINCT FROM to_jsonb('4cf0eb3077ada0bb5e628bd89fef4dc3'::text)
 AND (r#>ARRAY['db_core','combat_innata_functions','31331','ddl_md5']::text[]) IS NOT DISTINCT FROM to_jsonb('a2572e624c5c977e1c4d20086fa22ec4'::text)
 AND (r#>ARRAY['db_core','combat_innata_functions','39291','source_md5']::text[]) IS NOT DISTINCT FROM to_jsonb('ea4552d934017752fa4c97e6a2480bbf'::text)
 AND (r#>ARRAY['db_core','combat_innata_functions','39291','ddl_md5']::text[]) IS NOT DISTINCT FROM to_jsonb('f0c0e87e074c953e6aacd51656f4f6d7'::text)
 AND (r#>ARRAY['db_core','combat_innata_functions','48764','source_md5']::text[]) IS NOT DISTINCT FROM to_jsonb('47566d1c6ccf6958caf89f33ffd9b65b'::text)
 AND (r#>ARRAY['db_core','combat_innata_functions','48764','ddl_md5']::text[]) IS NOT DISTINCT FROM to_jsonb('9a0086038eabbcd580b857f8f628c517'::text)
 AND (r#>ARRAY['db_core','innata_all_clan_functions','48764','source_md5']::text[]) IS NOT DISTINCT FROM to_jsonb('47566d1c6ccf6958caf89f33ffd9b65b'::text)
 AND (r#>ARRAY['db_core','innata_all_clan_functions','48764','ddl_md5']::text[]) IS NOT DISTINCT FROM to_jsonb('9a0086038eabbcd580b857f8f628c517'::text)
 AND (r#>ARRAY['db_core','innata_maintained_functions','clan_innata_private.combat_begin_turn(uuid,uuid)','source_md5']::text[]) IS NOT DISTINCT FROM to_jsonb('47566d1c6ccf6958caf89f33ffd9b65b'::text)
 AND (r#>ARRAY['db_core','innata_maintained_functions','clan_innata_private.combat_begin_turn(uuid,uuid)','ddl_md5']::text[]) IS NOT DISTINCT FROM to_jsonb('9a0086038eabbcd580b857f8f628c517'::text)
 AND (r#>ARRAY['db_core','combat_innata_functions','48768','source_md5']::text[]) IS NOT DISTINCT FROM to_jsonb('f6b3bc2a10d4745c45e25c242daa017a'::text)
 AND (r#>ARRAY['db_core','combat_innata_functions','48768','ddl_md5']::text[]) IS NOT DISTINCT FROM to_jsonb('3b4cc62bfc60fdc56434e0b7c91fca70'::text)
 AND (r#>ARRAY['db_core','innata_all_clan_functions','48768','source_md5']::text[]) IS NOT DISTINCT FROM to_jsonb('f6b3bc2a10d4745c45e25c242daa017a'::text)
 AND (r#>ARRAY['db_core','innata_all_clan_functions','48768','ddl_md5']::text[]) IS NOT DISTINCT FROM to_jsonb('3b4cc62bfc60fdc56434e0b7c91fca70'::text)
 AND (r#>ARRAY['db_core','all_function_headers','12','source_md5']::text[]) IS NOT DISTINCT FROM to_jsonb('952a8a0deeaa6c1db84410b8409c06a1'::text)
 AND (r#>ARRAY['db_core','all_function_headers','12','ddl_md5']::text[]) IS NOT DISTINCT FROM to_jsonb('ca73ddb9500122f6c103991263a5a321'::text)
 AND (r#>ARRAY['db_core','c1266_functions','126','source_md5']::text[]) IS NOT DISTINCT FROM to_jsonb('952a8a0deeaa6c1db84410b8409c06a1'::text)
 AND (r#>ARRAY['db_core','c1266_functions','126','ddl_md5']::text[]) IS NOT DISTINCT FROM to_jsonb('ca73ddb9500122f6c103991263a5a321'::text)
 AND (r#>ARRAY['db_core','combat_innata_functions','41419','source_md5']::text[]) IS NOT DISTINCT FROM to_jsonb('78dd10959830241cf446b1cd738dbd2d'::text)
 AND (r#>ARRAY['db_core','combat_innata_functions','41419','ddl_md5']::text[]) IS NOT DISTINCT FROM to_jsonb('92c40d8638c7a14d1041a2accba0120e'::text)
 AND (r#>ARRAY['db_core','catalogo_eligibility_compat','shared_manifest_sha256']::text[]) IS NOT DISTINCT FROM to_jsonb(f0.shared_sha)
 AND (r#>ARRAY['config','catalogo_eligibility_compat','shared_manifest_sha256']::text[]) IS NOT DISTINCT FROM to_jsonb(f0.shared_sha)
 AND (r#>ARRAY['db_core','cure_command_amendment','shared_manifest_sha256']::text[]) IS NOT DISTINCT FROM to_jsonb(f0.shared_sha)
 AND (r#>ARRAY['config','cure_command_amendment','shared_manifest_sha256']::text[]) IS NOT DISTINCT FROM to_jsonb(f0.shared_sha)
 AND (r#>ARRAY['db_core','catalogo_eligibility_compat','functions']::text[]) IS NOT DISTINCT FROM f0.compat
 AND (r#>ARRAY['config','catalogo_eligibility_compat','functions']::text[]) IS NOT DISTINCT FROM f0.compat
 AND (r#>ARRAY['db_core','catalogo_eligibility_compat','functions_manifest_sha256']::text[]) IS NOT DISTINCT FROM to_jsonb(public.combat_v2_sha256(f0.compat))
 AND (r#>ARRAY['config','catalogo_eligibility_compat','functions_manifest_sha256']::text[]) IS NOT DISTINCT FROM to_jsonb(public.combat_v2_sha256(f0.compat))
 AND (r#>ARRAY['db_core','catalogo_eligibility_compat','helper_source_md5']::text[]) IS NOT DISTINCT FROM f0.compat#>'{0,source_md5}'
 AND (r#>ARRAY['config','catalogo_eligibility_compat','helper_source_md5']::text[]) IS NOT DISTINCT FROM f0.compat#>'{0,source_md5}'
 AND (r#>ARRAY['db_core','cure_command_amendment','helper_source_md5']::text[]) IS NOT DISTINCT FROM f0.compat#>'{0,source_md5}'
 AND (r#>ARRAY['config','cure_command_amendment','helper_source_md5']::text[]) IS NOT DISTINCT FROM f0.compat#>'{0,source_md5}'
 AND (r#>ARRAY['db_core','cure_command_amendment','functions_manifest_sha256']::text[]) IS NOT DISTINCT FROM to_jsonb(public.combat_v2_sha256(f0.peer6))
 AND (r#>ARRAY['config','cure_command_amendment','functions_manifest_sha256']::text[]) IS NOT DISTINCT FROM to_jsonb(public.combat_v2_sha256(f0.peer6))
 AND (r#>ARRAY['db_core','catalogo_families','2']::text[]) IS NOT DISTINCT FROM f0.descriptor
 AND (r#>ARRAY['db_core','velo_staff']::text[]) IS NOT DISTINCT FROM NULL::jsonb
 AND (r#>ARRAY['config','velo_staff']::text[]) IS NOT DISTINCT FROM NULL::jsonb) AS pins_ok,
    f0.shared_sha old_shared_sha,f1.shared_sha new_shared_sha,
    f0.compat old_compat,f1.compat new_compat,
    public.combat_v2_sha256(f0.peer6) old_peer_sha,public.combat_v2_sha256(f1.peer6) new_peer_sha,
    f0.descriptor old_descriptor,f1.descriptor new_descriptor
  FROM base CROSS JOIN f0 CROSS JOIN f1
), with_families AS MATERIALIZED (
  SELECT *,jsonb_set(candidate,'{config,catalogo_families}',to_jsonb(public.combat_v2_sha256(candidate#>'{db_core,catalogo_families}')),false) next_candidate
  FROM staged
), with_sha AS MATERIALIZED (
  SELECT *,public.combat_v2_sha256((next_candidate->'db_core')-'sha256') next_db,
    public.combat_v2_sha256((next_candidate->'config')-'sha256') next_config
  FROM with_families
), with_identity AS MATERIALIZED (
  SELECT *,public.combat_v2_sha256(jsonb_build_object('version','velo-staff/1','source_root',old_root,'leaf','c3612c94016774b3457ea72312e9a1ef763caca10bcec2151a7a522980d13c13',
      'previous_identity',r#>'{contract,code_identity_sha256}','db',next_db,'config',next_config)) next_identity
  FROM with_sha
), result_root AS MATERIALIZED (
  SELECT *,jsonb_set(jsonb_set(jsonb_set(jsonb_set(next_candidate,
    '{db_core,sha256}',to_jsonb(next_db),false),'{config,sha256}',to_jsonb(next_config),false),
    '{contract,code_identity_sha256}',to_jsonb(next_identity),false),
    '{recovery,semantic_identity_sha256}',to_jsonb(next_identity),false) root_after
  FROM with_identity
), compact AS MATERIALIZED (
  SELECT *,regexp_replace(root_after::text,$rx$("(?:[^"\\]|\\.)*")|[[:space:]]+$rx$,$b$\1$b$,'g') after_text
  FROM result_root
)

SELECT after_text INTO STRICT selected_root
FROM compact
WHERE pins_ok IS TRUE AND old_root='0fb538733f7010d36babf42f2ffa69432b16b8baa1e9bdea6d0b4ff6d447ae8d' AND after_text::jsonb=root_after
 AND octet_length(after_text)=523908 AND octet_length(after_text)<=524288
 AND encode(extensions.digest(convert_to(after_text,'UTF8'),'sha256'),'hex')='2bcaf1943d787202406fad30d0a628869df77aae792eaa38d089dea41f393e42';
 PERFORM set_config('app.velo_root_candidate',selected_root,true);
END $velo_store_projection$;

DO $velo_projection$
BEGIN
IF nullif(current_setting('app.velo_root_candidate',true),'') IS NULL
 OR encode(extensions.digest(convert_to(current_setting('app.velo_root_candidate'),'UTF8'),'sha256'),'hex') IS DISTINCT FROM '2bcaf1943d787202406fad30d0a628869df77aae792eaa38d089dea41f393e42'
 THEN RAISE EXCEPTION 'VELO_ROOT_PROJECTION_DRIFT';END IF;
END $velo_projection$;

-- Velo Staff. Componente sorgente, da integrare e rivedere prima di qualunque applicazione.
DO $velo_state_schema$
DECLARE
    v_before text;
BEGIN
    SELECT pg_catalog.pg_get_constraintdef(c.oid)
    INTO STRICT v_before
    FROM pg_catalog.pg_constraint AS c
    WHERE c.conrelid = 'clan_innata_combat_private.combat_state'::regclass
      AND c.conname = 'combat_state_technique_id_check'
      AND c.contype = 'c'
      AND c.convalidated;

    IF v_before IS DISTINCT FROM $velo_state_check_before$CHECK (((technique_id = ANY (ARRAY['001f907c-8f32-4758-8a16-ad1730e72c59'::uuid, '4056f62d-77f3-47f9-8ecb-9a7799682a9d'::uuid, 'c11ecd52-43cd-479b-8d5d-08187beba56e'::uuid, '4a527ff2-0420-4da9-bc1f-5489c753b285'::uuid, '8e20bafe-cb3c-4967-b9c7-2a4bca694996'::uuid, '9b384de3-35f0-43c0-b145-94f985fa758a'::uuid, 'a50808fa-e7cd-45ee-b4d4-33ad8c65d472'::uuid])) OR (technique_id = ANY (ARRAY['65b30dec-6f9f-459e-b78c-49173d74f251'::uuid, 'f3673da7-42c9-497e-abe1-1c0982429f35'::uuid, '1ab6d359-f337-45ed-839c-4e626d2e2819'::uuid]))))$velo_state_check_before$ THEN
        RAISE EXCEPTION 'VELO_COMBAT_STATE_CHECK_DRIFT';
    END IF;
END
$velo_state_schema$;

ALTER TABLE clan_innata_combat_private.combat_state
    DROP CONSTRAINT combat_state_technique_id_check,
    ADD CONSTRAINT combat_state_technique_id_check
    CHECK ((((technique_id = ANY (ARRAY['001f907c-8f32-4758-8a16-ad1730e72c59'::uuid, '4056f62d-77f3-47f9-8ecb-9a7799682a9d'::uuid, 'c11ecd52-43cd-479b-8d5d-08187beba56e'::uuid, '4a527ff2-0420-4da9-bc1f-5489c753b285'::uuid, '8e20bafe-cb3c-4967-b9c7-2a4bca694996'::uuid, '9b384de3-35f0-43c0-b145-94f985fa758a'::uuid, 'a50808fa-e7cd-45ee-b4d4-33ad8c65d472'::uuid])) OR (technique_id = ANY (ARRAY['65b30dec-6f9f-459e-b78c-49173d74f251'::uuid, 'f3673da7-42c9-497e-abe1-1c0982429f35'::uuid, '1ab6d359-f337-45ed-839c-4e626d2e2819'::uuid])))) OR
           (technique_id = 'c9b261da-c9cd-40bb-8189-7b65ab5a1605'::uuid AND is_test IS TRUE));

CREATE TABLE clan_innata_combat_private.velo_staff_gate_v1 (
    singleton boolean PRIMARY KEY CHECK (singleton IS TRUE),
    staff_enabled boolean NOT NULL DEFAULT false
);

ALTER TABLE clan_innata_combat_private.velo_staff_gate_v1 OWNER TO postgres;
ALTER TABLE clan_innata_combat_private.velo_staff_gate_v1 ENABLE ROW LEVEL SECURITY;
ALTER TABLE clan_innata_combat_private.velo_staff_gate_v1 FORCE ROW LEVEL SECURITY;
REVOKE ALL ON TABLE clan_innata_combat_private.velo_staff_gate_v1 FROM PUBLIC, anon, authenticated, service_role;
GRANT SELECT, INSERT, UPDATE ON TABLE clan_innata_combat_private.velo_staff_gate_v1 TO postgres;
INSERT INTO clan_innata_combat_private.velo_staff_gate_v1 (singleton, staff_enabled) VALUES (true, false);

CREATE FUNCTION clan_innata_combat_private.velo_staff_scope_v1(p_actor uuid)
RETURNS boolean
LANGUAGE sql STABLE SECURITY DEFINER SET search_path = ''
AS $velo_scope$
    SELECT EXISTS (
        SELECT 1
        FROM public.combat_v2_actors AS a
        JOIN public.combat_v2_sessions AS s ON s.id = a.session_id
        JOIN public.locations AS loc ON loc.id = s.location_id
        JOIN clan_innata_combat_private.velo_staff_gate_v1 AS gate
          ON gate.singleton AND gate.staff_enabled
        JOIN public.characters AS ch ON ch.id = a.character_id AND ch.user_id = a.controller_user
        CROSS JOIN LATERAL (
            SELECT array_agg(pg.character_id ORDER BY pg.character_id) AS character_ids,
                   array_agg(DISTINCT pg.controller_user ORDER BY pg.controller_user) AS principals
            FROM public.combat_v2_actors AS pg
            JOIN public.characters AS pc ON pc.id = pg.character_id AND pc.user_id = pg.controller_user
            WHERE pg.session_id = a.session_id AND pg.actor_kind = 'pg' AND pg.companion_id IS NULL
        ) AS roster
        WHERE a.id = p_actor AND a.state = 'attivo' AND a.actor_kind = 'pg' AND a.companion_id IS NULL
          AND CASE WHEN jsonb_typeof(a.mechanics_snapshot->'vita') = 'number'
              THEN (a.mechanics_snapshot->>'vita')::numeric > 0 ELSE false END
          AND ch.id = ANY (roster.character_ids)
          AND roster.character_ids = ARRAY[
              '2a877f02-4993-4e65-9172-7d29f08c5b86'::uuid,
              '6bceee99-974f-426b-8d92-38b43b4a4267'::uuid]
          AND cardinality(roster.principals) = 2
          AND NOT EXISTS (
              SELECT 1 FROM public.combat_v2_actors AS other
              WHERE other.session_id = s.id AND (
                  other.actor_kind IS DISTINCT FROM 'pg' OR other.companion_id IS NOT NULL
                  OR NOT COALESCE(other.character_id = ANY(roster.character_ids), false)
                  OR NOT COALESCE(other.controller_user = ANY(roster.principals), false)
              )
          )
          AND s.state = 'in_corso' AND s.closed_at IS NULL AND s.lesiva IS FALSE
          AND s.user_test_context_id IS NULL
          AND loc.id = '0b85f354-9cdb-47e1-baf9-3d266bb7e06b'::uuid AND loc.is_active AND loc.is_test
          AND public.combat_v2_values_written(s.id) IS FALSE
          AND combat_panel_private.uses_simulated_pools(s.id) IS TRUE
          AND combat_consumer_private.staff_test_allowed(loc.id, roster.principals, false) IS TRUE
          AND EXISTS (SELECT 1 FROM public.presence AS p
                      WHERE p.user_id = a.controller_user AND p.location_id = loc.id)
          AND CASE s.source_kind
              WHEN 'ordinary' THEN EXISTS (
                  SELECT 1 FROM combat_consumer_private.activities AS ctx
                  JOIN combat_consumer_private.members AS owner ON owner.session_id = ctx.session_id
                  WHERE ctx.session_id = s.id AND ctx.location_id = loc.id
                    AND owner.actor_id = a.id AND owner.character_id = a.character_id
                    AND s.master_session_id IS NULL
                    AND ctx.policy_id = 'staff_test_no_persistent_resources_v1')
              WHEN 'master' THEN EXISTS (
                  SELECT 1 FROM public.master_v2_sessions AS m
                  JOIN combat_panel_private.master_panel_sessions AS ctx ON ctx.master_session_id = m.id
                  WHERE m.id = s.master_session_id AND m.location_id = loc.id AND ctx.location_id = loc.id
                    AND m.owner_kind = 'human' AND m.tipo = 'duello' AND m.mission_id IS NULL AND m.quest_kind IS NULL
                    AND m.stato = 'in_corso' AND m.closed_at IS NULL AND m.suspended_at IS NULL
                    AND m.master_user = ANY(roster.principals)
                    AND ctx.policy_id = 'staff_test_no_persistent_resources_v1'
                    AND NOT EXISTS (SELECT 1 FROM public.mission_run_state AS q WHERE q.master_session_id = m.id)
                    AND NOT EXISTS (SELECT 1 FROM mission_generic_owner.run_bindings AS q WHERE q.master_session_id = m.id)
                    AND NOT EXISTS (SELECT 1 FROM mission_narrative_internal.scene_runtime_v1 AS q
                                    WHERE q.master_session_id = m.id AND q.is_active)
                    AND NOT EXISTS (SELECT 1 FROM mission_factory_owner.quest_run_sources AS q WHERE q.session_id = m.id)
                    AND NOT EXISTS (SELECT 1 FROM exam_human_private.native_bindings AS q WHERE q.master_session_id = m.id)
                    AND NOT EXISTS (SELECT 1 FROM exam_regia_private.bindings AS q WHERE q.combat_session_id = s.id))
              ELSE false
          END
    );
$velo_scope$;

CREATE FUNCTION clan_innata_combat_private.velo_stat_delta_v1(p_actor uuid)
RETURNS integer
LANGUAGE sql STABLE SECURITY DEFINER SET search_path = ''
AS $velo_delta$
    SELECT CASE WHEN EXISTS (
        SELECT 1 FROM clan_innata_combat_private.combat_state AS st
        JOIN public.combat_v2_actors AS a ON a.id = st.actor_id AND a.session_id = st.session_id
        WHERE a.id = p_actor AND st.technique_id = 'c9b261da-c9cd-40bb-8189-7b65ab5a1605'::uuid
          AND st.is_test IS TRUE AND st.active IS TRUE
    ) AND clan_innata_combat_private.velo_staff_scope_v1(p_actor) THEN 5 ELSE 0 END;
$velo_delta$;

ALTER FUNCTION clan_innata_combat_private.velo_staff_scope_v1(uuid) OWNER TO postgres;
ALTER FUNCTION clan_innata_combat_private.velo_stat_delta_v1(uuid) OWNER TO postgres;
REVOKE ALL ON FUNCTION clan_innata_combat_private.velo_staff_scope_v1(uuid) FROM PUBLIC, anon, authenticated, service_role;
REVOKE ALL ON FUNCTION clan_innata_combat_private.velo_stat_delta_v1(uuid) FROM PUBLIC, anon, authenticated, service_role;
GRANT EXECUTE ON FUNCTION clan_innata_combat_private.velo_staff_scope_v1(uuid) TO postgres;
GRANT EXECUTE ON FUNCTION clan_innata_combat_private.velo_stat_delta_v1(uuid) TO postgres;

-- Sorgente per composizione: richiede VELO_STAFF_EFFECT_COMPONENT e i delta comuni.
CREATE TABLE clan_innata_combat_private.velo_staff_profiles_v1 (
    session_id uuid NOT NULL REFERENCES public.combat_v2_sessions(id),
    actor_id uuid NOT NULL REFERENCES public.combat_v2_actors(id),
    controller_user uuid NOT NULL,
    controller_version bigint NOT NULL,
    request_id uuid NOT NULL,
    PRIMARY KEY (session_id, actor_id, controller_version),
    UNIQUE (controller_user, request_id)
);

CREATE TABLE clan_innata_combat_private.velo_rapid_turn_receipts_v1 (
    session_id uuid NOT NULL REFERENCES public.combat_v2_sessions(id),
    actor_id uuid NOT NULL REFERENCES public.combat_v2_actors(id),
    round_id uuid NOT NULL REFERENCES public.combat_v2_rounds(id),
    personal_turn_id uuid NOT NULL,
    request_id uuid NOT NULL,
    PRIMARY KEY (session_id, actor_id, personal_turn_id),
    UNIQUE (session_id, actor_id, request_id)
);

ALTER TABLE clan_innata_combat_private.velo_staff_profiles_v1 OWNER TO postgres;
ALTER TABLE clan_innata_combat_private.velo_staff_profiles_v1 ENABLE ROW LEVEL SECURITY;
ALTER TABLE clan_innata_combat_private.velo_staff_profiles_v1 FORCE ROW LEVEL SECURITY;
REVOKE ALL ON TABLE clan_innata_combat_private.velo_staff_profiles_v1 FROM PUBLIC, anon, authenticated, service_role;
GRANT SELECT, INSERT ON TABLE clan_innata_combat_private.velo_staff_profiles_v1 TO postgres;

ALTER TABLE clan_innata_combat_private.velo_rapid_turn_receipts_v1 OWNER TO postgres;
ALTER TABLE clan_innata_combat_private.velo_rapid_turn_receipts_v1 ENABLE ROW LEVEL SECURITY;
ALTER TABLE clan_innata_combat_private.velo_rapid_turn_receipts_v1 FORCE ROW LEVEL SECURITY;
REVOKE ALL ON TABLE clan_innata_combat_private.velo_rapid_turn_receipts_v1 FROM PUBLIC, anon, authenticated, service_role;
GRANT SELECT, INSERT ON TABLE clan_innata_combat_private.velo_rapid_turn_receipts_v1 TO postgres;

CREATE FUNCTION clan_innata_combat_private.velo_profile_bound_v1(p_actor uuid)
RETURNS boolean
LANGUAGE sql STABLE SECURITY DEFINER SET search_path = ''
AS $velo_profile$
    SELECT EXISTS (
        SELECT 1
        FROM clan_innata_combat_private.velo_staff_profiles_v1 AS profile
        JOIN public.combat_v2_actors AS a ON a.id = profile.actor_id AND a.session_id = profile.session_id
        WHERE a.id = p_actor
          AND profile.controller_user = a.controller_user
          AND profile.controller_version = a.controller_version
    ) AND clan_innata_combat_private.velo_staff_scope_v1(p_actor);
$velo_profile$;

CREATE OR REPLACE FUNCTION clan_innata_combat_private.velo_stat_delta_v1(p_actor uuid)
RETURNS integer
LANGUAGE sql STABLE SECURITY DEFINER SET search_path = ''
AS $velo_delta$
    SELECT CASE WHEN EXISTS (
        SELECT 1 FROM clan_innata_combat_private.combat_state AS st
        JOIN public.combat_v2_actors AS a ON a.id = st.actor_id AND a.session_id = st.session_id
        WHERE a.id = p_actor AND st.technique_id = 'c9b261da-c9cd-40bb-8189-7b65ab5a1605'::uuid
          AND st.is_test IS TRUE AND st.active IS TRUE
    ) AND clan_innata_combat_private.velo_profile_bound_v1(p_actor) THEN 5 ELSE 0 END;
$velo_delta$;

CREATE FUNCTION clan_innata_combat_private.velo_action_turn_v1(p_actor uuid, p_round uuid)
RETURNS uuid
LANGUAGE plpgsql STABLE SECURITY DEFINER SET search_path = ''
AS $velo_turn$
#variable_conflict error
DECLARE
    v_turn jsonb;
BEGIN
    IF NOT clan_innata_combat_private.velo_staff_scope_v1(p_actor) THEN
        RETURN NULL;
    END IF;
    v_turn := combat_panel_private.owner_turn_context(p_actor);
    IF v_turn->'can_move' IS DISTINCT FROM 'true'::jsonb
       OR v_turn->>'round_id' IS DISTINCT FROM p_round::text THEN
        RETURN NULL;
    END IF;
    IF v_turn->>'activity_kind' = 'master_v2'
       AND combat_panel_private.human_duel_round(p_round)
       AND combat_panel_private.human_duel_turn_allowed(p_round, p_actor) IS DISTINCT FROM true THEN
        RETURN NULL;
    END IF;
    RETURN (v_turn->>'personal_turn_id')::uuid;
END
$velo_turn$;

CREATE FUNCTION clan_innata_combat_private.velo_control_choice_v1(p_actor uuid, p_round uuid)
RETURNS text
LANGUAGE plpgsql STABLE SECURITY DEFINER SET search_path = ''
AS $velo_choice$
#variable_conflict error
DECLARE
    v_tid constant uuid := 'c9b261da-c9cd-40bb-8189-7b65ab5a1605';
    v_actor public.combat_v2_actors%ROWTYPE;
    v_turn uuid;
    v_total integer;
BEGIN
    IF NOT public.is_staff() THEN RETURN NULL; END IF;
    v_turn := clan_innata_combat_private.velo_action_turn_v1(p_actor, p_round);
    IF v_turn IS NULL THEN RETURN NULL; END IF;
    SELECT * INTO v_actor FROM public.combat_v2_actors AS a
    WHERE a.id = p_actor AND a.controller_user = auth.uid();
    IF NOT FOUND THEN RETURN NULL; END IF;
    IF jsonb_typeof(v_actor.mechanics_snapshot->'kekkei_genkai') IS DISTINCT FROM 'number' THEN RETURN NULL; END IF;
    IF NOT EXISTS (
        SELECT 1 FROM public.characters AS ch
        WHERE ch.id = v_actor.character_id AND ch.user_id = v_actor.controller_user
          AND public._grade_rank(ch.rank) >= public._grade_rank('Genin')
    ) OR (v_actor.mechanics_snapshot->>'kekkei_genkai')::numeric < 10 THEN
        RETURN NULL;
    END IF;
    IF NOT clan_innata_combat_private.velo_profile_bound_v1(p_actor) THEN
        -- L'ammissione vale solo per questo attore simulato. Nessuna abilità è assegnata alla scheda.
        IF EXISTS (
            SELECT 1 FROM clan_innata_combat_private.combat_state AS st
            WHERE st.session_id = v_actor.session_id AND st.actor_id = p_actor
              AND st.technique_id = v_tid AND st.active
        ) THEN RETURN NULL; END IF;
        RETURN 'prepare';
    END IF;
    IF clan_innata_combat_private.velo_stat_delta_v1(p_actor) = 5 THEN
        RETURN 'deactivate';
    END IF;
    IF EXISTS (
        SELECT 1 FROM clan_innata_combat_private.velo_rapid_turn_receipts_v1 AS rapid
        WHERE rapid.session_id = v_actor.session_id AND rapid.actor_id = p_actor AND rapid.personal_turn_id = v_turn
    ) OR EXISTS (
        SELECT 1 FROM clan_innata_combat_private.combat_receipts AS receipt
        WHERE receipt.session_id = v_actor.session_id AND receipt.actor_id = p_actor AND receipt.round_id = p_round
          AND receipt.operation = 'activate' AND receipt.chakra_spent > 0
    ) THEN RETURN NULL; END IF;
    IF NOT EXISTS (SELECT 1 FROM public.clan_techniques t
                   WHERE t.id = v_tid AND t.is_active AND t.uso = 'rapida'
                     AND t.attivazione = 'istantanea' AND t.chakra_cost = 5
                     AND t.consumption_type = 'per_turno') THEN
        RETURN NULL;
    END IF;
    IF jsonb_typeof(v_actor.mechanics_snapshot->'chakra') IS DISTINCT FROM 'number' THEN RETURN NULL; END IF;
    v_total := (clan_hyuga_private.sedici_cost_quote(p_actor, 5)->>'total')::integer;
    IF v_total IS NULL OR (v_actor.mechanics_snapshot->>'chakra')::numeric < v_total THEN
        RETURN NULL;
    END IF;
    RETURN 'activate';
END
$velo_choice$;

CREATE FUNCTION clan_innata_combat_private.velo_control_offers_v1(p_context uuid, p_expected bigint)
RETURNS void
LANGUAGE plpgsql VOLATILE SECURITY DEFINER SET search_path = ''
AS $velo_offers$
#variable_conflict error
DECLARE
    v_context combat_panel_private.contexts%ROWTYPE;
    v_choice text;
    v_label text;
    v_turn uuid;
BEGIN
    v_context := combat_panel_private.owned_context(p_context, p_expected);
    IF v_context.round_id IS NULL OR v_context.command_actor_id IS NULL
       OR v_context.activity_kind NOT IN ('ordinary_v2', 'master_v2') THEN RETURN; END IF;
    IF NOT EXISTS (SELECT 1 FROM public.combat_v2_actors AS a
                   WHERE a.id = v_context.command_actor_id AND a.session_id = v_context.activity_id
                     AND a.controller_user = auth.uid()) THEN RETURN; END IF;
    v_choice := clan_innata_combat_private.velo_control_choice_v1(v_context.command_actor_id, v_context.round_id);
    IF v_choice IS NULL THEN RETURN; END IF;
    v_turn := clan_innata_combat_private.velo_action_turn_v1(v_context.command_actor_id, v_context.round_id);
    IF v_turn IS NULL OR EXISTS (
        SELECT 1 FROM combat_panel_private.offers AS o
        WHERE o.context_id = v_context.id AND o.context_version = v_context.context_version AND o.state = 'offered'
          AND o.source_payload->>'dispatch' = 'velo_staff_control'
          AND o.source_payload->>'velo_action' = v_choice
          AND o.source_payload->>'personal_turn_id' = v_turn::text) THEN RETURN; END IF;
    v_label := CASE v_choice WHEN 'prepare' THEN 'Prepara prova Staff · Velo del Cercoterio'
                     WHEN 'activate' THEN 'Attiva Velo del Cercoterio · azione rapida'
                     WHEN 'deactivate' THEN 'Disattiva Velo del Cercoterio · gratuito' END;
    PERFORM combat_panel_private.create_offer(
        v_context.id, v_context.context_version, 'control', 'control', v_label, false,
        jsonb_build_object('adapter', v_context.activity_kind, 'dispatch', 'velo_staff_control',
                           'contract', 'velo-staff-control/1', 'velo_action', v_choice,
                           'personal_turn_id', v_turn));
END
$velo_offers$;

CREATE FUNCTION clan_innata_combat_private.velo_control_commit_v1(p_command jsonb)
RETURNS jsonb
LANGUAGE plpgsql VOLATILE SECURITY DEFINER SET search_path = ''
AS $velo_commit$
#variable_conflict error
DECLARE
    v_uid uuid := auth.uid();
    v_tid constant uuid := 'c9b261da-c9cd-40bb-8189-7b65ab5a1605';
    v_command jsonb;
    v_request uuid;
    v_fingerprint text;
    v_previous combat_panel_private.request_receipts%ROWTYPE;
    v_offer combat_panel_private.offers%ROWTYPE;
    v_context combat_panel_private.contexts%ROWTYPE;
    v_actor public.combat_v2_actors%ROWTYPE;
    v_state clan_innata_combat_private.combat_state%ROWTYPE;
    v_operation text;
    v_turn uuid;
    v_envelope jsonb;
    v_result jsonb;
    v_receipt_id uuid := gen_random_uuid();
    v_display_event jsonb;
    v_label text;
    v_changed integer;
BEGIN
    IF v_uid IS NULL OR NOT public.is_staff() THEN
        RAISE EXCEPTION 'VELO_STAFF_AUTH_REQUIRED' USING ERRCODE = '42501';
    END IF;
    v_command := combat_panel_private.validate_command(p_command);
    v_request := (v_command->>'request_key')::uuid;
    v_fingerprint := public.combat_v2_sha256(v_command);
    PERFORM pg_advisory_xact_lock(hashtextextended('panel-request:' || v_uid::text || ':' || v_request::text, 731));
    SELECT * INTO v_previous FROM combat_panel_private.request_receipts AS rr
    WHERE rr.principal_user = v_uid AND rr.request_key = v_request;
    IF FOUND THEN
        IF v_previous.command_fingerprint IS DISTINCT FROM v_fingerprint THEN
            RAISE EXCEPTION 'panel_request_key_conflict' USING ERRCODE = '22023';
        END IF;
        RETURN jsonb_set(v_previous.viewer_envelope, '{receipt,replayed}', 'true', false);
    END IF;

    SELECT * INTO v_offer FROM combat_panel_private.offers AS o
    WHERE o.id = (v_command->>'offer_id')::uuid AND o.principal_user = v_uid
      AND o.kind = 'control' AND o.operation = 'control' AND NOT o.requires_role
      AND o.source_payload->>'dispatch' = 'velo_staff_control'
      AND o.source_payload->>'contract' = 'velo-staff-control/1';
    IF NOT FOUND THEN RAISE EXCEPTION 'panel_offer_not_available' USING ERRCODE = '42501'; END IF;
    IF v_command->'selected_option_ids' IS DISTINCT FROM '[]'::jsonb
       OR v_command->'inputs' IS DISTINCT FROM '[]'::jsonb
       OR v_command->'companion_id' IS DISTINCT FROM 'null'::jsonb
       OR v_command->>'companion_body' IS DISTINCT FROM ''
       OR trim(v_command->>'narrative_text') IS DISTINCT FROM '' THEN
        RAISE EXCEPTION 'VELO_STAFF_CONTROL_SELECTION_INVALID' USING ERRCODE = '22023';
    END IF;
    SELECT * INTO STRICT v_context FROM combat_panel_private.contexts AS c
    WHERE c.id = v_offer.context_id AND c.principal_user = v_uid;
    IF v_context.round_id IS NULL OR v_context.activity_kind NOT IN ('ordinary_v2', 'master_v2')
       OR v_context.activity_kind IS DISTINCT FROM v_offer.source_payload->>'adapter'
       OR v_context.location_id IS DISTINCT FROM (v_command->>'location_id')::uuid
       OR v_context.activity_id IS DISTINCT FROM (v_command->>'activity_id')::uuid THEN
        RAISE EXCEPTION 'panel_activity_scope_invalid' USING ERRCODE = '22023';
    END IF;

    PERFORM public.combat_v2_lock_round(v_context.round_id);
    IF v_context.activity_kind = 'ordinary_v2' THEN
        v_envelope := combat_panel_private.ordinary_projection(v_context.location_id, v_context.command_actor_id);
    ELSE
        v_envelope := combat_panel_private.master_projection(v_context.location_id, v_context.command_actor_id);
    END IF;
    IF v_envelope->>'status' IS DISTINCT FROM 'ready' THEN
        RAISE EXCEPTION 'panel_source_not_ready' USING ERRCODE = '40001';
    END IF;
    v_context := combat_panel_private.owned_context(v_context.id, (v_command->>'context_version')::bigint);
    SELECT * INTO STRICT v_offer FROM combat_panel_private.offers AS o WHERE o.id = v_offer.id FOR UPDATE;
    IF v_offer.state IS DISTINCT FROM 'offered'
       OR v_offer.context_version IS DISTINCT FROM v_context.context_version
       OR v_offer.scene_version IS DISTINCT FROM v_context.scene_version
       OR v_offer.source_fingerprint IS DISTINCT FROM v_context.source_fingerprint
       OR v_offer.actor_id IS DISTINCT FROM v_context.command_actor_id THEN
        RAISE EXCEPTION 'panel_offer_not_available' USING ERRCODE = '40001';
    END IF;
    SELECT * INTO STRICT v_actor FROM public.combat_v2_actors AS a
    WHERE a.id = v_offer.actor_id AND a.session_id = v_context.activity_id
      AND a.controller_user = v_uid AND a.actor_kind = 'pg' AND a.companion_id IS NULL AND a.state = 'attivo'
    FOR UPDATE;

    v_turn := clan_innata_combat_private.velo_action_turn_v1(v_actor.id, v_context.round_id);
    v_operation := clan_innata_combat_private.velo_control_choice_v1(v_actor.id, v_context.round_id);
    IF v_turn IS NULL OR v_operation IS NULL
       OR v_turn::text IS DISTINCT FROM v_offer.source_payload->>'personal_turn_id'
       OR v_operation IS DISTINCT FROM v_offer.source_payload->>'velo_action' THEN
        RAISE EXCEPTION 'VELO_STAFF_CONTROL_STALE' USING ERRCODE = '40001';
    END IF;
    IF v_operation = 'prepare' THEN
        INSERT INTO clan_innata_combat_private.velo_staff_profiles_v1
            (session_id, actor_id, controller_user, controller_version, request_id)
        VALUES (v_actor.session_id, v_actor.id, v_uid, v_actor.controller_version, v_request);
    ELSE
        IF v_operation = 'activate' THEN
            INSERT INTO clan_innata_combat_private.velo_rapid_turn_receipts_v1
                (session_id, actor_id, round_id, personal_turn_id, request_id)
            VALUES (v_actor.session_id, v_actor.id, v_context.round_id, v_turn, v_request)
            ON CONFLICT (session_id, actor_id, personal_turn_id) DO NOTHING;
            GET DIAGNOSTICS v_changed = ROW_COUNT;
            IF v_changed IS DISTINCT FROM 1 THEN
                RAISE EXCEPTION 'VELO_STAFF_RAPID_ALREADY_CONSUMED' USING ERRCODE = '40001';
            END IF;
        END IF;
        v_state := clan_innata_private.combat_state_read(v_actor.id, v_tid);
        v_result := clan_innata_private.combat_transition(v_actor.id, v_tid, v_operation, v_request, v_state.state_version);
        IF v_result->'is_test' IS DISTINCT FROM 'true'::jsonb
           OR v_result->'values_written' IS DISTINCT FROM 'false'::jsonb
           OR v_result->'main_action_consumed' IS DISTINCT FROM 'false'::jsonb
           OR v_result->'active' IS DISTINCT FROM to_jsonb(v_operation = 'activate') THEN
            RAISE EXCEPTION 'VELO_STAFF_EFFECT_RECEIPT_INVALID';
        END IF;
        v_receipt_id := (v_result->>'receipt_id')::uuid;
    END IF;

    UPDATE combat_panel_private.offers AS o
    SET state = 'consumed', consumed_request_key = v_request
    WHERE o.id = v_offer.id AND o.state = 'offered';
    GET DIAGNOSTICS v_changed = ROW_COUNT;
    IF v_changed IS DISTINCT FROM 1 THEN RAISE EXCEPTION 'VELO_STAFF_OFFER_CAS'; END IF;

    IF v_context.activity_kind = 'ordinary_v2' THEN
        UPDATE combat_consumer_private.activities AS ctx
        SET context_version = ctx.context_version + 1, last_action_at = clock_timestamp()
        WHERE ctx.session_id = v_context.activity_id AND ctx.exchange_id = v_context.round_id;
        GET DIAGNOSTICS v_changed = ROW_COUNT;
        IF v_changed IS DISTINCT FROM 1 THEN RAISE EXCEPTION 'VELO_STAFF_ORDINARY_CAS'; END IF;
    END IF;
    UPDATE combat_panel_private.contexts AS c
    SET context_version = c.context_version + 1, updated_at = clock_timestamp()
    WHERE c.id = v_context.id AND c.context_version = v_context.context_version;
    GET DIAGNOSTICS v_changed = ROW_COUNT;
    IF v_changed IS DISTINCT FROM 1 THEN RAISE EXCEPTION 'VELO_STAFF_CONTEXT_CAS'; END IF;

    IF v_context.activity_kind = 'ordinary_v2' THEN
        v_envelope := combat_panel_private.ordinary_projection(v_context.location_id, v_actor.id);
    ELSE
        v_envelope := combat_panel_private.master_projection(v_context.location_id, v_actor.id);
    END IF;
    IF v_envelope->>'status' IS DISTINCT FROM 'ready' OR v_receipt_id IS NULL THEN
        RAISE EXCEPTION 'VELO_STAFF_CONTROL_ENVELOPE_INVALID';
    END IF;
    SELECT item->>'display_name' INTO STRICT v_label
    FROM jsonb_array_elements(v_envelope->'actors') AS viewers(item)
    WHERE item->>'actor_id' = v_actor.id::text;
    v_display_event := combat_consumer_private.validate_display_event(jsonb_build_object(
        'event_id', v_receipt_id, 'event_kind', 'control_changed', 'actor_id', v_actor.id,
        'display_name', v_label, 'label_version', v_context.context_version,
        'target_actor_id', NULL, 'target_display_name', NULL, 'target_label_version', NULL,
        'summary', CASE v_operation
            WHEN 'prepare' THEN 'Prova Staff Velo del Cercoterio preparata.'
            WHEN 'activate' THEN format('Velo del Cercoterio attivo. Chakra di prova speso: %s.',
                                        v_result->>'chakra_spent')
            WHEN 'deactivate' THEN 'Velo del Cercoterio disattivato.'
        END));
    v_envelope := jsonb_set(v_envelope, '{receipt}',
        jsonb_build_object('receipt_id', v_receipt_id, 'request_key', v_request, 'operation', 'control',
            'replayed', false, 'activity_id', v_context.activity_id, 'round_id', v_context.round_id,
            'context_version_before', v_offer.context_version, 'context_version_after', v_envelope#>'{context,version}',
            'declaration_id', NULL, 'report_id', NULL, 'values_written', false, 'display_events', jsonb_build_array(v_display_event)));

    INSERT INTO combat_panel_private.request_receipts
        (principal_user, request_key, command_fingerprint, offer_id, event_id, viewer_envelope)
    VALUES (v_uid, v_request, v_fingerprint, v_offer.id, v_receipt_id, v_envelope);
    RETURN v_envelope;
END
$velo_commit$;

ALTER FUNCTION clan_innata_combat_private.velo_profile_bound_v1(uuid) OWNER TO postgres;
ALTER FUNCTION clan_innata_combat_private.velo_action_turn_v1(uuid,uuid) OWNER TO postgres;
ALTER FUNCTION clan_innata_combat_private.velo_control_choice_v1(uuid,uuid) OWNER TO postgres;
ALTER FUNCTION clan_innata_combat_private.velo_control_offers_v1(uuid,bigint) OWNER TO postgres;
ALTER FUNCTION clan_innata_combat_private.velo_control_commit_v1(jsonb) OWNER TO postgres;
REVOKE ALL ON FUNCTION clan_innata_combat_private.velo_profile_bound_v1(uuid) FROM PUBLIC, anon, authenticated, service_role;
REVOKE ALL ON FUNCTION clan_innata_combat_private.velo_action_turn_v1(uuid,uuid) FROM PUBLIC, anon, authenticated, service_role;
REVOKE ALL ON FUNCTION clan_innata_combat_private.velo_control_choice_v1(uuid,uuid) FROM PUBLIC, anon, authenticated, service_role;
REVOKE ALL ON FUNCTION clan_innata_combat_private.velo_control_offers_v1(uuid,bigint) FROM PUBLIC, anon, authenticated, service_role;
REVOKE ALL ON FUNCTION clan_innata_combat_private.velo_control_commit_v1(jsonb) FROM PUBLIC, anon, authenticated, service_role;
GRANT EXECUTE ON FUNCTION clan_innata_combat_private.velo_profile_bound_v1(uuid) TO postgres;
GRANT EXECUTE ON FUNCTION clan_innata_combat_private.velo_action_turn_v1(uuid,uuid) TO postgres;
GRANT EXECUTE ON FUNCTION clan_innata_combat_private.velo_control_choice_v1(uuid,uuid) TO postgres;
GRANT EXECUTE ON FUNCTION clan_innata_combat_private.velo_control_offers_v1(uuid,bigint) TO postgres;
GRANT EXECUTE ON FUNCTION clan_innata_combat_private.velo_control_commit_v1(jsonb) TO postgres;

CREATE FUNCTION clan_innata_combat_private.velo_innata_scope_v1(p_actor uuid)
RETURNS jsonb
LANGUAGE plpgsql STABLE SECURITY DEFINER SET search_path = ''
AS $velo_scope$
#variable_conflict error
DECLARE
    v_context clan_innata_combat_private.actor_context;
BEGIN
    IF clan_innata_combat_private.velo_profile_bound_v1(p_actor) IS DISTINCT FROM true THEN
        RAISE EXCEPTION 'VELO_STAFF_PROFILE_REQUIRED' USING ERRCODE = '42501';
    END IF;
    v_context := clan_innata_private.combat_context(p_actor);
    RETURN jsonb_build_object('actor_id', p_actor, 'session_id', v_context.session_id,
                              'round_id', v_context.exchange_id, 'personal_turn_id', v_context.personal_turn_id,
                              'activity_kind', v_context.activity_kind, 'context_version', v_context.context_version,
                              'is_test', true, 'staff_scope', true, 'policy_id', v_context.policy_id,
                              'turn_owner', v_context.turn_actor_id = p_actor, 'phase', v_context.phase);
END
$velo_scope$;
ALTER FUNCTION clan_innata_combat_private.velo_innata_scope_v1(uuid) OWNER TO postgres;
REVOKE ALL ON FUNCTION clan_innata_combat_private.velo_innata_scope_v1(uuid) FROM PUBLIC, anon, authenticated, service_role;
GRANT EXECUTE ON FUNCTION clan_innata_combat_private.velo_innata_scope_v1(uuid) TO postgres;

-- Componente sorgente. Richiede profilo e stato Velo riservati alla Staff.
CREATE TABLE clan_innata_combat_private.velo_declaration_stats_v1 (
    declaration_id uuid NOT NULL REFERENCES public.combat_v2_declarations(id),
    actor_id uuid NOT NULL REFERENCES public.combat_v2_actors(id),
    session_id uuid NOT NULL REFERENCES public.combat_v2_sessions(id),
    base_forza integer NOT NULL,
    base_velocita integer NOT NULL,
    effective_forza integer NOT NULL CHECK (effective_forza = base_forza + 5),
    effective_velocita integer NOT NULL CHECK (effective_velocita = base_velocita + 5),
    PRIMARY KEY (declaration_id, actor_id)
);

ALTER TABLE clan_innata_combat_private.velo_declaration_stats_v1 OWNER TO postgres;
ALTER TABLE clan_innata_combat_private.velo_declaration_stats_v1 ENABLE ROW LEVEL SECURITY;
ALTER TABLE clan_innata_combat_private.velo_declaration_stats_v1 FORCE ROW LEVEL SECURITY;
REVOKE ALL ON TABLE clan_innata_combat_private.velo_declaration_stats_v1 FROM PUBLIC, anon, authenticated, service_role;
GRANT SELECT, INSERT ON TABLE clan_innata_combat_private.velo_declaration_stats_v1 TO postgres;

CREATE FUNCTION clan_innata_combat_private.velo_freeze_declaration_v1(p_declaration uuid)
RETURNS void
LANGUAGE plpgsql VOLATILE SECURITY DEFINER SET search_path = ''
AS $velo_freeze$
#variable_conflict error
DECLARE
    v_decl public.combat_v2_declarations%ROWTYPE;
    v_session uuid;
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM clan_innata_combat_private.velo_staff_gate_v1 AS gate
        WHERE gate.singleton AND gate.staff_enabled
    ) THEN RETURN; END IF;
    SELECT * INTO STRICT v_decl FROM public.combat_v2_declarations AS d WHERE d.id = p_declaration;
    IF v_decl.kind NOT IN ('attacco', 'difesa', 'nessuna') THEN RETURN; END IF;
    SELECT r.session_id INTO STRICT v_session FROM public.combat_v2_rounds AS r WHERE r.id = v_decl.round_id;
    INSERT INTO clan_innata_combat_private.velo_declaration_stats_v1 (
        declaration_id, actor_id, session_id, base_forza, base_velocita, effective_forza, effective_velocita
    )
    SELECT v_decl.id, a.id, a.session_id, stats.forza, stats.velocita, stats.forza + 5, stats.velocita + 5
    FROM public.combat_v2_actors AS a
    CROSS JOIN LATERAL (
        SELECT (a.mechanics_snapshot->>'forza')::integer AS forza,
               (a.mechanics_snapshot->>'velocita')::integer AS velocita
    ) AS stats
    WHERE a.session_id = v_session
      AND (
          a.id = v_decl.actor_id OR
          (v_decl.kind = 'attacco' AND EXISTS (
              SELECT 1 FROM public.combat_v2_attack_targets AS target
              WHERE target.attack_declaration_id = v_decl.id AND target.round_id = v_decl.round_id
                AND target.target_actor_id = a.id
          ))
      )
      AND clan_innata_combat_private.velo_stat_delta_v1(a.id) = 5
    ORDER BY a.id;
END
$velo_freeze$;

CREATE FUNCTION clan_innata_combat_private.velo_frozen_snapshot_v1(p_snapshot jsonb, p_actor uuid, p_declaration uuid)
RETURNS jsonb
LANGUAGE sql STABLE SECURITY DEFINER SET search_path = ''
AS $velo_frozen_snapshot$
    SELECT COALESCE((
        SELECT p_snapshot || jsonb_build_object('forza', stat.effective_forza, 'velocita', stat.effective_velocita)
        FROM clan_innata_combat_private.velo_declaration_stats_v1 AS stat
        WHERE stat.actor_id = p_actor AND stat.declaration_id = p_declaration
    ), p_snapshot);
$velo_frozen_snapshot$;

ALTER FUNCTION clan_innata_combat_private.velo_freeze_declaration_v1(uuid) OWNER TO postgres;
ALTER FUNCTION clan_innata_combat_private.velo_frozen_snapshot_v1(jsonb,uuid,uuid) OWNER TO postgres;
REVOKE ALL ON FUNCTION clan_innata_combat_private.velo_freeze_declaration_v1(uuid) FROM PUBLIC, anon, authenticated, service_role;
REVOKE ALL ON FUNCTION clan_innata_combat_private.velo_frozen_snapshot_v1(jsonb,uuid,uuid) FROM PUBLIC, anon, authenticated, service_role;
GRANT EXECUTE ON FUNCTION clan_innata_combat_private.velo_freeze_declaration_v1(uuid) TO postgres;
GRANT EXECUTE ON FUNCTION clan_innata_combat_private.velo_frozen_snapshot_v1(jsonb,uuid,uuid) TO postgres;
CREATE OR REPLACE FUNCTION combat_panel_private.master_options(p_location uuid, p_actor uuid, p_expected bigint)
 RETURNS jsonb
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO ''
AS $function$
DECLARE env jsonb; source jsonb; c combat_panel_private.contexts%ROWTYPE; rid uuid; offers jsonb;
BEGIN
 IF exam_regia_private.current_principal() IS NULL THEN RAISE EXCEPTION 'panel_authentication_required' USING ERRCODE='28000'; END IF;
 SELECT r.id INTO rid FROM public.master_v2_sessions m JOIN public.combat_v2_sessions s ON s.master_session_id=m.id
   JOIN public.combat_v2_rounds r ON r.session_id=s.id WHERE m.location_id=p_location
     AND m.stato NOT IN ('chiusa','annullata') AND s.state NOT IN ('chiuso','annullato') ORDER BY r.round_no DESC LIMIT 1;
 IF rid IS NOT NULL THEN PERFORM public.combat_v2_lock_round(rid);
 ELSE PERFORM 1 FROM public.locations WHERE id=p_location FOR UPDATE; END IF;
 env:=combat_panel_private.master_projection(p_location,p_actor);
 IF env#>>'{context,version}' IS DISTINCT FROM p_expected::text THEN
   RAISE EXCEPTION 'panel_context_stale' USING ERRCODE='40001'; END IF;
 SELECT * INTO STRICT c FROM combat_panel_private.contexts WHERE location_id=p_location AND principal_user=exam_regia_private.current_principal()
   AND command_actor_id IS NOT DISTINCT FROM (env#>>'{viewer,command_actor_id}')::uuid FOR UPDATE;
 -- Il controllo prepara Movimento senza revocare attacco e tecnica già offerti.
 IF NOT EXISTS(SELECT 1 FROM combat_panel_private.offers WHERE context_id=c.id AND context_version=c.context_version AND state='offered') THEN
   IF c.command_actor_id IS NOT NULL AND c.round_id IS NOT NULL THEN
     -- La versione richiesta e gia validata sotto lock del round.
     -- Upkeep e inizializzazione autorizzati precedono il catalogo delle azioni.
     PERFORM clan_sabaku_private.prepare_master_owner(c.command_actor_id);
     PERFORM combat_panel_private.prepare_master_companion(c.command_actor_id);
     source:=public.combat_v2_round_options(c.round_id,c.command_actor_id)->'data';
     -- Controllo is activated by master_control_offers. Its attack is only the attested Flow producer.
     -- Exclude exactly that identity from generic attacks; preserve every other native ability.
     source:=jsonb_set(source,'{abilities}',coalesce((SELECT jsonb_agg(value ORDER BY ordinal)
       FROM jsonb_array_elements(coalesce(source->'abilities','[]')) WITH ORDINALITY AS abilities(value,ordinal)
       WHERE NOT coalesce(value->>'source'='clan' AND value->>'id' IN ('001f907c-8f32-4758-8a16-ad1730e72c59','f5e9af24-70f1-49f6-a7ca-74f59256336e','b9195ceb-74de-4251-95af-fe5c1bdaf485','2f06b6f8-341f-472b-be04-ad48fcf2c412','0a15282f-d6b5-4ee3-ad52-7fac2525444d'),false)
       -- Byakugan is an innate control; native Master activation is produced separately.
       AND NOT(c.location_id='0b85f354-9cdb-47e1-baf9-3d266bb7e06b'::uuid
         AND coalesce(combat_panel_private.uses_simulated_pools(c.activity_id),false)
         AND EXISTS(SELECT 1 FROM clan_innata_narrative_private.byakugan_catalog_v1 byakugan
         JOIN public.clan_techniques technique ON technique.id=byakugan.technique_id AND technique.is_innata
         WHERE value->>'source'='clan' AND value->>'id'=byakugan.technique_id::text))),'[]'::jsonb));
     env:=combat_panel_private.master_projection(p_location,c.command_actor_id);
     SELECT * INTO STRICT c FROM combat_panel_private.contexts WHERE id=c.id
       AND principal_user=exam_regia_private.current_principal() FOR UPDATE;
     PERFORM set_config('application_name','TUS_PERF master_actor',true); RAISE WARNING 'TUS_PERF stage=master_actor_begin context=%',c.id; PERFORM combat_panel_private.master_actor_offers(c.id,c.context_version,env,source); RAISE WARNING 'TUS_PERF stage=master_actor_end context=%',c.id; PERFORM set_config('application_name','TUS_PERF after_actor',true);
     PERFORM clan_aburame_private.master_offers(c.id,c.context_version,env);
     PERFORM combat_panel_private.master_companion_bind_offers(c.id,c.context_version);
     PERFORM combat_panel_private.master_companion_control_offers(c.id,c.context_version,source); PERFORM set_config('application_name','TUS_PERF inuzuka_control',true); RAISE WARNING 'TUS_PERF stage=inuzuka_control_begin context=%',c.id; PERFORM clan_inuzuka_private.master_control_offers(c.id,c.context_version); RAISE WARNING 'TUS_PERF stage=inuzuka_control_end context=%',c.id; PERFORM set_config('application_name','TUS_PERF done',true);
   END IF;
   PERFORM clan_hoki_private.master_body_offer(c.id,c.context_version);
   PERFORM clan_akimichi_private.master_form_offers(c.id,c.context_version);
   PERFORM clan_sabaku_private.master_control_offers(c.id,c.context_version);
   PERFORM clan_hyuga_private.master_control_offers(c.id,c.context_version);
   PERFORM clan_innata_private.sharingan_master_control_offers(c.id,c.context_version);
   IF NOT exam_regia_private.is_bound(c.activity_id) THEN PERFORM combat_panel_private.master_admin_offers(c.id,c.context_version,public.master_v2_ui_state(p_location)->'data'); END IF;
 END IF;
 PERFORM combat_panel_private.master_movement_control_offers(c.id,c.context_version);
 PERFORM combat_panel_private.multiplication_offers(c.id,c.context_version,env);
 PERFORM combat_panel_private.immobilization_escape_offers(c.id,c.context_version,env);
 PERFORM combat_panel_private.nara_control_offers_v1(c.id,c.context_version,env);
 PERFORM combat_panel_private.cure_offers_v1(c.id,c.context_version,env);
 PERFORM clan_akimichi_private.common_panel_offers_v1(c.id,c.context_version,env);
 PERFORM clan_innata_combat_private.velo_control_offers_v1(c.id,c.context_version);
 PERFORM clan_sabaku_private.clone_offers(c.id,c.context_version,env);
 PERFORM clan_sabaku_private.flow_master_offers(c.id,c.context_version,env);
 PERFORM clan_hyuga_private.rotation_panel_offers(c.id,c.context_version);
 PERFORM combat_panel_private.master_open_offers(c.id,c.context_version);
 PERFORM combat_v2_elemental_internal.suiton_master_options(c.id,c.context_version);
 PERFORM combat_v2_elemental_internal.scudo_master_options(c.id,c.context_version);
 PERFORM combat_v2_elemental_internal.other_master_options(c.id,c.context_version);
 IF EXISTS(SELECT 1 FROM public.combat_v2_actors a JOIN public.combat_v2_sessions s ON s.id=a.session_id
  JOIN public.master_v2_sessions master ON master.id=s.master_session_id AND master.owner_kind='ai_service'
  JOIN public.locations loc ON loc.id=master.location_id AND loc.id=p_location AND loc.is_test AND loc.is_active
  JOIN mission_narrative_internal.scene_runtime_v1 scene ON scene.master_session_id=master.id AND scene.is_active AND scene.mode='combat'
  WHERE a.id=c.command_actor_id AND a.actor_kind='pg' AND a.character_id IS NOT NULL
   AND a.controller_user=exam_regia_private.current_principal() AND s.id=c.activity_id AND NOT s.lesiva
   AND combat_panel_private.uses_simulated_pools(s.id) AND NOT public.combat_v2_values_written(s.id)) THEN
  UPDATE combat_panel_private.offers SET requires_role=true
   WHERE context_id=c.id AND context_version=c.context_version AND state='offered' AND kind='action'
    AND source_payload->>'kind'='passa' AND NOT requires_role;
 END IF;
   PERFORM combat_v2_genjutsu_internal.panel_options(c.id,c.context_version);
  PERFORM combat_panel_private.nara_adv_offers_v1(c.id,c.context_version,env);
 SELECT coalesce(jsonb_agg(combat_panel_private.offer_projection(id) ORDER BY created_at,id),'[]') INTO offers
   FROM combat_panel_private.offers WHERE context_id=c.id AND context_version=c.context_version AND state='offered';
 RETURN clan_aburame_private.consumer_projection(jsonb_set(combat_panel_private.attach_rating_offers(jsonb_set(env,'{offers}',offers),c.id),
   '{movement_explanations}',coalesce(combat_panel_private.movement_explanations(c.id,c.context_version),'null'::jsonb)));
END $function$;

CREATE OR REPLACE FUNCTION combat_panel_private.ordinary_options(p_location uuid, p_actor uuid, p_expected bigint)
 RETURNS jsonb
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO ''
AS $function$
DECLARE env jsonb; src jsonb; c combat_panel_private.contexts%ROWTYPE; rid uuid;
 item jsonb; companion_moves jsonb:='[]'; rendered jsonb; ignored uuid;
BEGIN
 -- Ordine coerente con il commit del motore: round/sessione prima del
 -- contesto del nuovo pannello. Non si blocca il POV prima delle risorse.
 SELECT exchange_id INTO rid FROM combat_consumer_private.activities
   WHERE location_id=p_location AND phase<>'closed' AND
    ((user_testroom_common_private.bound_context(p_location) IS NULL AND user_test_context_id IS NULL)
     OR session_id=user_testroom_common_private.bound_context(p_location));
 IF rid IS NOT NULL THEN PERFORM public.combat_v2_lock_round(rid);
 ELSE PERFORM 1 FROM public.locations WHERE id=p_location FOR UPDATE; END IF;
 PERFORM set_config('application_name','TUS_PERF ordinary_projection_initial',true); -- INUZUKA-ORDINARY-DIAG018
 env:=combat_panel_private.ordinary_projection(p_location,p_actor);
 PERFORM set_config('application_name','TUS_PERF ordinary_context_initial',true); -- INUZUKA-ORDINARY-DIAG018
 IF env->>'status' IS DISTINCT FROM 'ready' THEN RETURN env; END IF;
 SELECT * INTO STRICT c FROM combat_panel_private.contexts WHERE location_id=p_location
   AND principal_user=auth.uid() AND command_actor_id IS NOT DISTINCT FROM (env#>>'{viewer,command_actor_id}')::uuid;
 IF c.context_version IS DISTINCT FROM p_expected THEN
   RAISE EXCEPTION 'panel_context_stale' USING ERRCODE='40001'; END IF;
 IF NOT EXISTS(SELECT 1 FROM combat_panel_private.offers WHERE context_id=c.id
   AND context_version=c.context_version AND state='offered'
   AND source_payload->>'adapter'='ordinary_v2') THEN -- INUZUKA-ORDINARY-SOURCE-OFFER-GATE-20260922-010
 PERFORM set_config('application_name','TUS_PERF consumer_state',true); -- INUZUKA-ORDINARY-DIAG018
   src:=combat_panel_private.consumer_state_authoritative(p_location);
 PERFORM set_config('application_name','TUS_PERF consumer_options',true); -- INUZUKA-ORDINARY-DIAG018
   -- INUZUKA-EXACT-STAFF-DIRECT-CONSUMER-20260922-028
   IF p_location='0b85f354-9cdb-47e1-baf9-3d266bb7e06b'::uuid
    AND p_actor='c5865d83-3651-4815-a7e2-de484c3f5481'::uuid
    AND auth.uid()='15448f47-3b43-416f-a703-dbe7a74d36ce'::uuid
    AND c.activity_id='0e35db27-29a7-49fc-a496-12ae663edb77'::uuid
    AND c.round_id='fc5be64f-5023-4f7d-a2ce-89797ea09061'::uuid
    AND c.location_id=p_location AND c.command_actor_id=p_actor
    AND c.context_version=p_expected
    AND EXISTS(
      SELECT 1 FROM combat_consumer_private.activities qa_ctx
      JOIN public.combat_v2_actors qa ON qa.id=p_actor AND qa.session_id=qa_ctx.session_id
      JOIN public.characters pg ON pg.id=qa.character_id
      WHERE qa_ctx.session_id=c.activity_id AND qa_ctx.exchange_id=c.round_id
       AND qa_ctx.location_id=p_location AND qa_ctx.phase='action'
       AND qa_ctx.turn_actor_id=p_actor
       AND qa_ctx.policy_id='staff_test_no_persistent_resources_v1'
       AND qa.controller_user=auth.uid() AND qa.actor_kind='pg'
       AND qa.companion_id IS NULL AND qa.state='attivo'
       AND pg.id='2a877f02-4993-4e65-9172-7d29f08c5b86'::uuid
       AND pg.clan='Nessuno'
       AND NOT public.combat_v2_values_written(qa_ctx.session_id)
       AND (SELECT count(DISTINCT a->>'id') FROM jsonb_array_elements(
         CASE WHEN jsonb_typeof(qa.mechanics_snapshot->'abilities')='array'
          THEN qa.mechanics_snapshot->'abilities' ELSE '[]'::jsonb END) a
        WHERE a->>'source'='clan' AND a->>'id' IN(
         '6d7c0804-1ba9-4e49-8697-1a550f3608b2','b0748ef4-bea8-4d85-95a1-7d9db1b4381c',
         'b076a976-c75b-4b5a-8813-b0e8e2c3af03','c11ecd52-43cd-479b-8d5d-08187beba56e'))=4
       AND NOT EXISTS(SELECT 1 FROM jsonb_array_elements(
         CASE WHEN jsonb_typeof(qa.mechanics_snapshot->'abilities')='array'
          THEN qa.mechanics_snapshot->'abilities' ELSE '[]'::jsonb END) a
        WHERE a->>'source'='clan' AND (a->>'id' IS NULL OR a->>'id' NOT IN(
         '6d7c0804-1ba9-4e49-8697-1a550f3608b2','b0748ef4-bea8-4d85-95a1-7d9db1b4381c',
         'b076a976-c75b-4b5a-8813-b0e8e2c3af03','c11ecd52-43cd-479b-8d5d-08187beba56e')))
    ) THEN
     src:=clan_inuzuka_private.consumer_options(src);
   ELSE
     src:=combat_panel_private.consumer_options_authoritative(p_location,(src#>>'{context,version}')::bigint);
   END IF;
 PERFORM set_config('application_name','TUS_PERF consumer_ready',true); -- INUZUKA-ORDINARY-DIAG018
   IF src->>'status' IS DISTINCT FROM 'ready' THEN
     RAISE EXCEPTION 'panel_source_options_not_ready' USING ERRCODE='40001'; END IF;
   -- I producer gia rilasciati possono preparare il link iniziale. Riprendere
   -- la projection autorizzata e la nuova versione prima di importare offerte.
 PERFORM set_config('application_name','TUS_PERF ordinary_projection_refresh',true); -- INUZUKA-ORDINARY-DIAG018
 -- INUZUKA-EXACT-STAFF-SKIP-PROJECTION-REFRESH-20260922-026
 IF NOT (
   p_location='0b85f354-9cdb-47e1-baf9-3d266bb7e06b'::uuid
   AND p_actor='c5865d83-3651-4815-a7e2-de484c3f5481'::uuid
   AND auth.uid()='15448f47-3b43-416f-a703-dbe7a74d36ce'::uuid
   AND EXISTS(
     SELECT 1 FROM combat_consumer_private.activities qa_ctx
     JOIN public.combat_v2_actors qa ON qa.id=p_actor
     JOIN public.characters pg ON pg.id=qa.character_id
     WHERE qa_ctx.session_id='0e35db27-29a7-49fc-a496-12ae663edb77'::uuid
       AND qa_ctx.exchange_id='fc5be64f-5023-4f7d-a2ce-89797ea09061'::uuid
       AND qa_ctx.location_id=p_location
       AND qa_ctx.phase='action'
       AND qa_ctx.turn_actor_id=p_actor
       AND qa_ctx.policy_id='staff_test_no_persistent_resources_v1'
       AND qa.session_id=qa_ctx.session_id
       AND c.activity_id=qa_ctx.session_id
       AND c.round_id=qa_ctx.exchange_id
       AND c.location_id=qa_ctx.location_id
       AND c.command_actor_id=p_actor
       AND c.context_version=p_expected
       -- INUZUKA-EXACT-STAFF-CONTEXT-GUARD-20260922-027
       -- Il contesto e' gia vincolato lato server da c, qa_ctx, attore, utente,
       -- sessione, scambio, stanza Staff, versione e policy della fixture.
       AND qa.controller_user=auth.uid()
       AND qa.actor_kind='pg'
       AND qa.companion_id IS NULL
       AND qa.state='attivo'
       AND pg.id='2a877f02-4993-4e65-9172-7d29f08c5b86'::uuid
       AND pg.clan='Nessuno'
       AND NOT public.combat_v2_values_written(qa_ctx.session_id)
       AND (SELECT count(DISTINCT a->>'id') FROM jsonb_array_elements(
         CASE WHEN jsonb_typeof(qa.mechanics_snapshot->'abilities')='array' THEN qa.mechanics_snapshot->'abilities' ELSE '[]'::jsonb END) a
         WHERE a->>'source'='clan' AND a->>'id' IN (
           '6d7c0804-1ba9-4e49-8697-1a550f3608b2','b0748ef4-bea8-4d85-95a1-7d9db1b4381c',
           'b076a976-c75b-4b5a-8813-b0e8e2c3af03','c11ecd52-43cd-479b-8d5d-08187beba56e'))=4
       AND NOT EXISTS(SELECT 1 FROM jsonb_array_elements(
         CASE WHEN jsonb_typeof(qa.mechanics_snapshot->'abilities')='array' THEN qa.mechanics_snapshot->'abilities' ELSE '[]'::jsonb END) a
         WHERE a->>'source'='clan' AND (a->>'id' IS NULL OR a->>'id' NOT IN (
           '6d7c0804-1ba9-4e49-8697-1a550f3608b2','b0748ef4-bea8-4d85-95a1-7d9db1b4381c',
           'b076a976-c75b-4b5a-8813-b0e8e2c3af03','c11ecd52-43cd-479b-8d5d-08187beba56e')))
   )
 ) THEN
   env:=combat_panel_private.ordinary_projection(p_location,p_actor);
 END IF;
 PERFORM set_config('application_name','TUS_PERF import_prepare',true); -- INUZUKA-ORDINARY-DIAG018
   SELECT * INTO STRICT c FROM combat_panel_private.contexts WHERE location_id=p_location
     AND principal_user=auth.uid() AND command_actor_id IS NOT DISTINCT FROM (env#>>'{viewer,command_actor_id}')::uuid;
 PERFORM set_config('application_name','TUS_PERF import_offers',true); -- INUZUKA-ORDINARY-DIAG018
   FOR item IN SELECT value FROM jsonb_array_elements(src->'offers') LOOP
     IF jsonb_typeof(item->'companion_movement')='object' THEN
       companion_moves:=companion_moves||jsonb_build_array(item);
     ELSE
       ignored:=combat_panel_private.import_ordinary_offer(c.id,c.context_version,item,(src#>>'{context,version}')::bigint);
     END IF;
   END LOOP;
   IF jsonb_array_length(companion_moves)>0 THEN
     ignored:=combat_panel_private.import_companion_moves(c.id,c.context_version,companion_moves,(src#>>'{context,version}')::bigint);
   END IF;
 END IF;
 PERFORM set_config('application_name','TUS_PERF helpers_attack',true); -- INUZUKA-ORDINARY-DIAG018
 -- INUZUKA-STAFF-QA-SKIP-UNRELATED-HELPERS-20260922-022
 IF NOT (
   p_location='0b85f354-9cdb-47e1-baf9-3d266bb7e06b'::uuid
   AND p_actor='c5865d83-3651-4815-a7e2-de484c3f5481'::uuid
   AND auth.uid()='15448f47-3b43-416f-a703-dbe7a74d36ce'::uuid
   AND EXISTS(
     SELECT 1 FROM combat_consumer_private.activities qa_session
     JOIN public.combat_v2_actors qa_actor ON qa_actor.id=p_actor
     JOIN public.characters qa_character ON qa_character.id=qa_actor.character_id
     WHERE qa_session.location_id=p_location
       AND qa_session.session_id=c.activity_id
       AND qa_session.exchange_id=c.round_id
       AND qa_session.phase<>'closed'
       AND qa_session.turn_actor_id=p_actor
       AND qa_session.policy_id='staff_test_no_persistent_resources_v1'
       AND qa_actor.session_id=qa_session.session_id
       AND qa_actor.controller_user=auth.uid()
       AND qa_actor.actor_kind='pg'
       AND qa_actor.companion_id IS NULL
       AND qa_actor.state='attivo'
       AND qa_character.id='2a877f02-4993-4e65-9172-7d29f08c5b86'::uuid
       AND qa_character.clan='Nessuno'
       AND NOT public.combat_v2_values_written(qa_session.session_id)
   )
 ) THEN
 PERFORM combat_panel_private.multiplication_ordinary_attack_offers(c.id,c.context_version,env);
 PERFORM combat_v2_elemental_internal.suiton_ordinary_copy_offers(c.id,c.context_version,env);
 PERFORM combat_v2_elemental_internal.other_ordinary_copy_offers(c.id,c.context_version,env);
 IF c.location_id='0b85f354-9cdb-47e1-baf9-3d266bb7e06b'::uuid THEN PERFORM set_config('application_name','TUS_PERF helper_companion_attack',true); END IF; -- INUZUKA-DISPATCH-DIAG020
 PERFORM combat_panel_private.multiplication_companion_ordinary_offers(c.id,c.context_version,env);
 IF c.location_id='0b85f354-9cdb-47e1-baf9-3d266bb7e06b'::uuid THEN PERFORM set_config('application_name','TUS_PERF helper_multiplication',true); END IF; -- INUZUKA-DISPATCH-DIAG020
  -- INUZUKA-STAFF-QA-SKIP-UNRELATED-MULTIPLICATION-20260922-021
  IF NOT (
    p_location='0b85f354-9cdb-47e1-baf9-3d266bb7e06b'::uuid
    AND p_actor='c5865d83-3651-4815-a7e2-de484c3f5481'::uuid
    AND auth.uid()='15448f47-3b43-416f-a703-dbe7a74d36ce'::uuid
    AND EXISTS(
      SELECT 1
      FROM combat_consumer_private.activities qa_session
      JOIN public.combat_v2_actors qa_actor ON qa_actor.id=p_actor
      JOIN public.characters qa_character ON qa_character.id=qa_actor.character_id
      WHERE qa_session.location_id=p_location
        AND qa_session.session_id=c.activity_id
        AND qa_session.exchange_id=c.round_id
        AND qa_session.phase<>'closed'
        AND qa_session.turn_actor_id=p_actor
        AND qa_session.policy_id='staff_test_no_persistent_resources_v1'
        AND qa_actor.session_id=qa_session.session_id
        AND qa_actor.controller_user=auth.uid()
        AND qa_actor.actor_kind='pg'
        AND qa_actor.companion_id IS NULL
        AND qa_actor.state='attivo'
        AND qa_character.id='2a877f02-4993-4e65-9172-7d29f08c5b86'::uuid
        AND qa_character.clan='Nessuno'
        AND NOT public.combat_v2_values_written(qa_session.session_id)
    )
  ) THEN
    PERFORM combat_panel_private.multiplication_offers(c.id,c.context_version,env);
  END IF;
 IF c.location_id='0b85f354-9cdb-47e1-baf9-3d266bb7e06b'::uuid THEN PERFORM set_config('application_name','TUS_PERF helper_immobilization',true); END IF; -- INUZUKA-DISPATCH-DIAG020
 PERFORM combat_panel_private.immobilization_escape_offers(c.id,c.context_version,env);
 PERFORM combat_panel_private.nara_control_offers_v1(c.id,c.context_version,env);
 PERFORM combat_panel_private.cure_offers_v1(c.id,c.context_version,env);
 PERFORM clan_akimichi_private.common_panel_offers_v1(c.id,c.context_version,env);
 PERFORM clan_innata_combat_private.velo_control_offers_v1(c.id,c.context_version);
 IF c.location_id='0b85f354-9cdb-47e1-baf9-3d266bb7e06b'::uuid THEN PERFORM set_config('application_name','TUS_PERF helper_clone',true); END IF; -- INUZUKA-DISPATCH-DIAG020
 PERFORM clan_sabaku_private.clone_offers(c.id,c.context_version,env);
 PERFORM clan_sabaku_private.flow_ordinary_figure_offers(c.id,c.context_version,env);
 END IF;
 PERFORM set_config('application_name','TUS_PERF helpers_movement',true); -- INUZUKA-ORDINARY-DIAG018
 -- INUZUKA-STAFF-QA-SKIP-PG-MOVEMENT-20260922-023
 IF NOT (
   p_location='0b85f354-9cdb-47e1-baf9-3d266bb7e06b'::uuid
   AND p_actor='c5865d83-3651-4815-a7e2-de484c3f5481'::uuid
   AND auth.uid()='15448f47-3b43-416f-a703-dbe7a74d36ce'::uuid
   AND EXISTS(
     SELECT 1 FROM combat_consumer_private.activities qa_session
     JOIN public.combat_v2_actors qa_actor ON qa_actor.id=p_actor
     JOIN public.characters qa_character ON qa_character.id=qa_actor.character_id
     WHERE qa_session.location_id=p_location
       AND qa_session.session_id=c.activity_id
       AND qa_session.exchange_id=c.round_id
       AND qa_session.phase<>'closed'
       AND qa_session.turn_actor_id=p_actor
       AND qa_session.policy_id='staff_test_no_persistent_resources_v1'
       AND qa_actor.session_id=qa_session.session_id
       AND qa_actor.controller_user=auth.uid()
       AND qa_actor.actor_kind='pg'
       AND qa_actor.companion_id IS NULL
       AND qa_actor.state='attivo'
       AND qa_character.id='2a877f02-4993-4e65-9172-7d29f08c5b86'::uuid
       AND qa_character.clan='Nessuno'
       AND NOT public.combat_v2_values_written(qa_session.session_id)
   )
 ) THEN
   PERFORM combat_panel_private.pg_movement_offers(c.id,c.context_version);
 END IF;
 IF user_testroom_common_private.bound_context(p_location) IS NULL THEN
  PERFORM combat_panel_private.master_open_offers(c.id,c.context_version);
 END IF;
 PERFORM set_config('application_name','TUS_PERF render_offers',true); -- INUZUKA-ORDINARY-DIAG018
   PERFORM combat_v2_genjutsu_internal.panel_options(c.id,c.context_version);
 PERFORM combat_panel_private.nara_adv_offers_v1(c.id,c.context_version,env);
  SELECT coalesce(jsonb_agg(combat_panel_private.offer_projection(id) ORDER BY created_at,id),'[]'::jsonb)
   INTO rendered FROM combat_panel_private.offers WHERE context_id=c.id
     AND context_version=c.context_version AND state='offered';
 PERFORM set_config('application_name','TUS_PERF movement_explanations',true); -- INUZUKA-ORDINARY-DIAG018
 RETURN jsonb_set(jsonb_set(env,'{offers}',rendered),'{movement_explanations}',
   coalesce(combat_panel_private.movement_explanations(c.id,c.context_version),'null'::jsonb));
END $function$;

CREATE OR REPLACE FUNCTION public.combat_panel_commit_v1(p_command jsonb)
 RETURNS jsonb
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO ''
AS $function$
DECLARE p jsonb; uid uuid:=auth.uid(); key uuid; fp text; adapter text; reason text;
 prior combat_panel_private.request_receipts%ROWTYPE; offer combat_panel_private.offers%ROWTYPE;
 code text; message text; recovery text;
 diag_context text; diag_state text; diag_frames jsonb;
 diag35_binding jsonb; diag35_scope uuid; diag35_frames jsonb; diag35_data jsonb;
 diag35_key uuid; diag35_fingerprint text; diag35_adapter text; diag35_offer combat_panel_private.offers%ROWTYPE;
BEGIN
 IF uid IS NULL THEN RAISE EXCEPTION 'panel_authentication_required' USING ERRCODE='28000'; END IF;
 p:=combat_panel_private.validate_command(p_command);
 PERFORM exam_human_private.assert_panel_command_v1(p); key:=(p->>'request_key')::uuid; fp:=public.combat_v2_sha256(p);
 PERFORM pg_advisory_xact_lock(hashtextextended('panel-request:'||uid::text||':'||key::text,731));
 SELECT * INTO prior FROM combat_panel_private.request_receipts WHERE principal_user=uid AND request_key=key;
 IF prior.request_key IS NOT NULL THEN
   IF prior.command_fingerprint<>fp THEN RAISE EXCEPTION 'panel_request_key_conflict' USING ERRCODE='22023'; END IF;
   IF prior.viewer_envelope#>'{receipt,inuzuka}' IS NOT NULL AND EXISTS(
     SELECT 1 FROM combat_panel_private.offers saved_offer WHERE saved_offer.id=prior.offer_id
       AND saved_offer.principal_user=uid AND saved_offer.kind='control'
       AND saved_offer.source_payload->>'adapter'='master_v2'
       AND saved_offer.source_payload->>'dispatch'='inuzuka_control'
   ) THEN
     RETURN jsonb_set(prior.viewer_envelope,'{receipt,replayed}','true',false) #- '{receipt,inuzuka}';
   END IF;
   RETURN jsonb_set(prior.viewer_envelope,'{receipt,replayed}','true',false);
 END IF;
 SELECT * INTO offer FROM combat_panel_private.offers WHERE id=(p->>'offer_id')::uuid AND principal_user=uid;
 IF offer.id IS NULL THEN RAISE EXCEPTION 'panel_offer_not_available' USING ERRCODE='42501'; END IF;
 IF EXISTS(SELECT 1 FROM combat_panel_private.contexts ctx
   JOIN mission_generic_owner.unified_batches ub ON ub.encounter_id=ctx.activity_id
   WHERE ctx.id=offer.context_id AND ctx.principal_user=uid
     AND ub.source_window_id IS NOT NULL AND ub.composition_kind='entry_png'
     AND ub.state IN('preparing','ready') AND ub.message_id IS NULL)
 THEN RAISE EXCEPTION 'MUF_PUBLICATION_PENDING' USING ERRCODE='42501'; END IF;
 adapter:=offer.source_payload->>'adapter';
 reason:=combat_panel_private.access_reason((p->>'location_id')::uuid,adapter);
 IF reason IS NOT NULL THEN RAISE EXCEPTION 'panel_access_rejected' USING ERRCODE='42501'; END IF;
 IF adapter IS DISTINCT FROM combat_panel_private.location_adapter((p->>'location_id')::uuid) THEN
   RAISE EXCEPTION 'panel_context_stale' USING ERRCODE='40001'; END IF;
 IF adapter='master_v2' AND offer.kind='administration' AND offer.operation='administration'
   AND offer.source_payload->>'dispatch'='staff_native_roster' THEN
   RETURN combat_v2_staff_nb_internal.commit_roster(p);
 END IF;
 IF adapter IN ('ordinary_v2','master_v2') AND offer.kind = 'control'
   AND offer.operation = 'control' AND offer.source_payload->>'dispatch' = 'velo_staff_control' THEN
   RETURN clan_innata_combat_private.velo_control_commit_v1(p);
 END IF;
 IF offer.source_payload->>'dispatch' IN('akimichi_common_profile','akimichi_common_form','akimichi_cellular') THEN
   RETURN clan_akimichi_private.common_panel_commit_v1(p);
 END IF;
 IF offer.source_payload->>'dispatch' IN('nara_adv_prepare','nara_strangle') THEN RETURN combat_panel_private.nara_adv_commit_v1(p);END IF;
 IF offer.source_payload->>'dispatch' IN('cure_staff_profile','cure_action') THEN
   RETURN combat_panel_private.cure_commit_v1(p);
 END IF;
 IF offer.kind='administration' AND offer.operation='open'
   AND offer.source_payload->>'dispatch'='master_session_open' THEN
   RETURN combat_panel_private.commit_master_open(p); END IF;
 IF offer.kind='action' AND offer.operation='declare' AND offer.source_payload->>'dispatch'='sabaku_clone' THEN
   RETURN clan_sabaku_private.commit_clone(p); END IF;
 IF offer.kind='action' AND offer.operation='declare' AND offer.source_payload->>'dispatch'='immobilization_escape' THEN
   RETURN combat_panel_private.commit_immobilization_escape(p); END IF;
 IF offer.kind='action' AND offer.operation='declare' AND offer.source_payload->>'dispatch'='multiplication' THEN
   RETURN combat_panel_private.commit_multiplication(p); END IF;
 IF adapter IN ('ordinary_v2','master_v2') AND offer.kind='control' AND offer.operation='control'
   AND offer.source_payload->>'dispatch'='nara_possession_control' THEN
   RETURN combat_panel_private.nara_commit_control_v1(p); END IF;
 IF adapter='ordinary_v2' AND offer.kind='control' AND offer.operation='control' AND offer.source_payload->>'dispatch'='pg_movement' THEN
   RETURN combat_panel_private.commit_pg_movement(p); END IF;
 IF adapter='ordinary_v2' THEN RETURN combat_panel_private.commit_ordinary(p); END IF;
 IF adapter='master_v2' AND offer.kind='control' AND offer.operation='control' AND offer.source_payload->>'dispatch'='master_movement_control' THEN
   RETURN combat_panel_private.commit_master_movement_control(p); END IF;
 IF adapter='master_v2' THEN
   IF offer.kind='control' AND offer.source_payload->>'dispatch'='hoki_control' THEN
     RETURN clan_hoki_private.commit_master_body(p); END IF;
   IF offer.kind='control' AND offer.source_payload->>'dispatch'='aburame_control' THEN
     RETURN clan_aburame_private.commit_master_stop(p); END IF;
   IF offer.kind='control' AND offer.source_payload->>'dispatch'='scudo_control' THEN
     RETURN combat_v2_elemental_internal.scudo_commit_master_control(p); END IF;
   IF offer.kind='control' AND offer.source_payload->>'dispatch'='suiton_control' THEN
     RETURN combat_v2_elemental_internal.suiton_commit_master_control(p); END IF;
   IF offer.kind='control' AND offer.source_payload->>'dispatch'='other_control' THEN
     RETURN combat_v2_elemental_internal.other_commit_master_control(p); END IF;
   IF offer.kind='control' AND offer.source_payload->>'dispatch'='hyuga_control' THEN
     RETURN clan_hyuga_private.commit_master_control(p); END IF;
   IF offer.kind='control' AND offer.source_payload->>'dispatch'='sharingan_control' THEN
     RETURN clan_innata_private.sharingan_commit_master_control(p); END IF;
   IF offer.kind='control' AND offer.source_payload->>'dispatch'='sabaku_control' THEN
     RETURN clan_sabaku_private.commit_master_control(p); END IF;
   IF offer.kind='control' AND offer.source_payload->>'dispatch'='akimichi_form' THEN
     RETURN clan_akimichi_private.commit_master_form(p);
   END IF;
   IF offer.kind='control' AND offer.source_payload->>'dispatch'='inuzuka_control' THEN RETURN clan_inuzuka_private.commit_master_control(p) #- '{receipt,inuzuka}'; END IF; IF offer.kind='control' AND offer.source_payload->>'dispatch'='companion_control' THEN
     RETURN combat_panel_private.commit_master_companion(p); END IF;
   IF offer.kind='administration' THEN RETURN combat_panel_private.commit_master_admin(p); END IF;
   RETURN combat_panel_private.commit_master_actor(p);
 END IF;
 RAISE EXCEPTION 'panel_dispatch_not_available' USING ERRCODE='22023';
EXCEPTION WHEN OTHERS THEN
 -- Questo ramo viene raggiunto dopo il rollback dell'intera sottotransazione
 -- della richiesta. Non comprende timeout/disconnessioni senza risposta DB.
 code:=CASE WHEN SQLSTATE='28000' THEN 'authentication_required'
   WHEN SQLERRM='panel_request_key_conflict' THEN 'request_key_conflict'
   WHEN SQLSTATE='42501' THEN 'not_authorized'
   WHEN SQLSTATE='40001' THEN 'context_changed'
   WHEN SQLSTATE LIKE '22%' THEN 'selection_rejected' ELSE 'operation_rejected' END;
 message:=CASE code WHEN 'authentication_required' THEN 'Accedi nuovamente per continuare.'
   WHEN 'request_key_conflict' THEN 'Questa richiesta è già associata a un altro invio. Verifica lo stato prima di continuare.'
   WHEN 'not_authorized' THEN 'Questa operazione non è disponibile per il tuo accesso.'
   WHEN 'context_changed' THEN 'Lo scontro è cambiato. Rileggi lo stato e scegli di nuovo.'
   WHEN 'selection_rejected' THEN CASE SQLERRM
     WHEN 'panel_command_shape_invalid' THEN 'La richiesta non ha il formato previsto. Riapri il pannello prima di inviare.'
     WHEN 'panel_command_keys_invalid' THEN 'La richiesta non ha il formato previsto. Riapri il pannello prima di inviare.'
     WHEN 'panel_contract_version_invalid' THEN 'La richiesta non ha il formato previsto. Riapri il pannello prima di inviare.'
     WHEN 'panel_command_values_invalid' THEN 'La richiesta non ha il formato previsto. Riapri il pannello prima di inviare.'
     WHEN 'panel_identifier_invalid' THEN 'La richiesta non identifica correttamente il contesto o le scelte. Rileggi il pannello.'
     WHEN 'panel_option_identifier_invalid' THEN 'La richiesta non identifica correttamente il contesto o le scelte. Rileggi il pannello.'
     WHEN 'panel_context_version_invalid' THEN 'La richiesta non identifica correttamente il contesto o le scelte. Rileggi il pannello.'
     WHEN 'panel_duplicate_selection' THEN 'La selezione contiene elementi ripetuti o non validi. Rileggi le opzioni e scegli nuovamente.'
     WHEN 'panel_selection_invalid' THEN 'La selezione contiene elementi ripetuti o non validi. Rileggi le opzioni e scegli nuovamente.'
     WHEN 'panel_selection_not_offered' THEN 'Una delle scelte inviate non appartiene alle opzioni disponibili. Rileggi le opzioni.'
     WHEN 'panel_choice_cardinality_or_dependency_invalid' THEN 'Manca una scelta richiesta, sono selezionate troppe opzioni oppure alcune scelte sono incompatibili. Rileggi le opzioni e correggi la selezione.'
     WHEN 'panel_input_shape_invalid' THEN 'Uno dei campi richiesti è mancante, ripetuto o non valido. Controlla i campi prima di inviare.'
     WHEN 'panel_duplicate_input' THEN 'Uno dei campi richiesti è mancante, ripetuto o non valido. Controlla i campi prima di inviare.'
     WHEN 'panel_input_cardinality_invalid' THEN 'Uno dei campi richiesti è mancante, ripetuto o non valido. Controlla i campi prima di inviare.'
     WHEN 'panel_input_value_invalid' THEN 'Uno dei campi richiesti è mancante, ripetuto o non valido. Controlla i campi prima di inviare.'
     WHEN 'panel_input_not_offered' THEN 'La richiesta contiene un campo non previsto per questa azione. Rileggi le opzioni.'
     WHEN 'panel_activity_scope_invalid' THEN 'La richiesta non appartiene allo scontro o al luogo selezionato. Riapri il pannello.'
     WHEN 'panel_role_required' THEN 'Questa dichiarazione richiede un testo di azione valido prima della conferma.'
     WHEN 'panel_multiplication_selection_incomplete' THEN 'Completa le scelte di copie, modalità, disposizione e originale prima di confermare.'
     WHEN 'panel_multiplication_selection_conflict' THEN 'Le scelte di modalità, copie, disposizione o bersaglio della Moltiplicazione sono incompatibili.'
     WHEN 'panel_multiplication_mode_invalid' THEN 'La modalità scelta e la presenza del bersaglio non sono compatibili.'
     WHEN 'panel_multiplication_formation_invalid' THEN 'Il numero di copie o la disposizione non rispettano i limiti disponibili della Moltiplicazione.'
     WHEN 'panel_multiplication_figure_outside_arena' THEN 'La disposizione porta almeno una figura fuori dai confini dell’arena.'
     WHEN 'panel_multiplication_single_movement_required' THEN 'Lo spostamento dell’originale non è disponibile. Controlla il movimento residuo e gli impedimenti.'
     WHEN 'panel_multiplication_zero_movement_capability' THEN 'È stato richiesto uno spostamento, ma l’originale è nella posizione di partenza. Rileggi le opzioni.'
     WHEN 'panel_multiplication_target_invalid' THEN 'Il bersaglio dell’assalto non è un avversario attivo in questo scontro.'
     WHEN 'panel_multiplication_target_choice_required' THEN 'Per questo bersaglio occorre selezionare una figura tra quelle offerte.'
     WHEN 'panel_multiplication_target_selection_conflict' THEN 'La selezione della figura per il bersaglio non è completa o contiene scelte incompatibili.'
     WHEN 'panel_multiplication_target_selection_invalid' THEN 'La selezione della figura per il bersaglio non è completa o contiene scelte incompatibili.'
     WHEN 'panel_attack_origin_invalid' THEN 'L’origine scelta per l’attacco non è consentita.'
     WHEN 'panel_multiplication_assault_contact_invalid' THEN 'L’assalto non può raggiungere il bersaglio dalla posizione scelta: verifica visibilità, contatto, direzione e percorso.'
     WHEN 'panel_multiplication_catalog_changed' THEN 'La tecnica non è utilizzabile con la configurazione attuale. Segnala il rifiuto allo staff.'
     WHEN 'panel_multiplication_rank_unavailable' THEN 'Non è possibile determinare le copie disponibili per il rango del personaggio. Contatta lo staff.'
     WHEN 'panel_multiplication_resources_invalid' THEN 'Non è possibile verificare le risorse disponibili per la Moltiplicazione. Contatta lo staff.'
     WHEN 'panel_multiplication_cost_snapshot_invalid' THEN 'Non è possibile verificare le risorse disponibili per la Moltiplicazione. Contatta lo staff.'
     WHEN 'panel_multiplication_npc_source_unavailable' THEN 'Questo attore non dispone di una fonte valida per usare la Moltiplicazione.'
     WHEN 'panel_multiplication_actor_kind_invalid' THEN 'Questo attore non dispone di una fonte valida per usare la Moltiplicazione.'
     WHEN 'immobilization_escape_action_conflict' THEN 'La stessa dichiarazione contiene azioni speciali incompatibili. Rileggi le opzioni e scegli una sola azione.'
     WHEN 'sabaku_clone_action_conflict' THEN 'La stessa dichiarazione contiene azioni speciali incompatibili. Rileggi le opzioni e scegli una sola azione.'
     WHEN 'panel_dispatch_not_available' THEN 'Questa azione non ha un percorso disponibile nel pannello. Segnala il rifiuto allo staff.'
     ELSE 'Le scelte non sono più valide. Rileggi le opzioni.' END
   ELSE 'Il server ha rifiutato l’operazione. Rileggi lo stato; se il problema resta, informa lo staff.' END;
 recovery:=CASE WHEN code='authentication_required' THEN 'authenticate'
   WHEN code='request_key_conflict' THEN 'contact_staff' ELSE 'refresh' END;
 -- Diagnostica privata della sola sessione Staff autorizzata. Nessun testo della richiesta.
 GET STACKED DIAGNOSTICS diag_context = PG_EXCEPTION_CONTEXT, diag_state = RETURNED_SQLSTATE;
 BEGIN
  IF uid IS NOT NULL AND key IS NOT NULL AND offer.id IS NOT NULL
   AND offer.principal_user=uid AND public.is_staff()
   AND ((offer.kind='action' AND offer.operation='declare')
    OR (offer.kind='control' AND offer.operation='control' AND adapter='ordinary_v2'
     AND EXISTS (SELECT 1 FROM combat_consumer_private.offers diagnostic_source
       WHERE diagnostic_source.id=(offer.source_payload->>'source_offer_id')::uuid
        AND diagnostic_source.session_id=(offer.source_payload->>'source_activity_id')::uuid
        AND diagnostic_source.operation='control'
        AND diagnostic_source.source_payload->>'aburame_operation'='release_stop'))
    OR (offer.kind='defense' AND offer.operation='defend' AND adapter='ordinary_v2'
     AND EXISTS (
      SELECT 1 FROM combat_consumer_private.offers src
      JOIN public.combat_v2_actors defender ON defender.id=offer.actor_id
      WHERE src.id=(offer.source_payload->>'source_offer_id')::uuid
       AND src.offer_kind='defense' AND src.operation='defend'
       AND (src.source_payload#>>'{intent,reaction}' IN ('parata','schivata','nessuna')
        OR (src.source_payload->>'aburame_clone'='aburame-clone/1'
         AND src.source_payload#>>'{intent,reaction}'='tecnica'
         AND src.source_payload#>>'{intent,ability_source}'='clan'
         AND src.source_payload#>>'{intent,ability_id}'='b9195ceb-74de-4251-95af-fe5c1bdaf485'))
       AND src.session_id=defender.session_id
       AND src.principal_character_id=defender.character_id
       AND src.location_id='0b85f354-9cdb-47e1-baf9-3d266bb7e06b'::uuid)))
   AND adapter IN ('ordinary_v2','master_v2')
   AND EXISTS (
    SELECT 1 FROM combat_panel_private.contexts c
    JOIN public.combat_v2_actors a ON a.id=offer.actor_id AND a.controller_user=uid
    JOIN public.combat_v2_sessions s ON s.id=a.session_id
    WHERE c.id=offer.context_id AND c.principal_user=uid AND c.command_actor_id=a.id
     AND s.id='bff182d1-7027-4519-a546-65e28d991716'::uuid
     AND c.activity_id=s.id
     AND c.id='8b72e8cf-c522-4b88-bc64-a51c83bddcb4'::uuid
     AND c.round_id='c880d549-179d-414d-ad25-a987c999af87'::uuid
     AND c.location_id='0b85f354-9cdb-47e1-baf9-3d266bb7e06b'::uuid
     AND s.location_id=c.location_id
     AND c.activity_kind=adapter
     AND a.id IN ('ff130a12-d6df-4e11-8add-b3087b42aab8'::uuid,'da8eebcd-2d79-49c2-b5ec-c7ea4fbc02d8'::uuid)
     AND NOT public.combat_v2_values_written(s.id))
   AND combat_panel_private.access_reason('0b85f354-9cdb-47e1-baf9-3d266bb7e06b'::uuid,adapter) IS NULL
  THEN
   SELECT coalesce(jsonb_agg(jsonb_build_object('function',x.parts[1],'line',x.parts[2]::integer) ORDER BY x.ord),'[]'::jsonb)
    INTO diag_frames
    FROM (SELECT m.parts,m.ord FROM regexp_matches(diag_context,
     'PL/pgSQL function ([a-z_][a-z0-9_]*(?:[.][a-z_][a-z0-9_]*)?)[(][^\n]*[)] line ([0-9]+)',
     'g') WITH ORDINALITY AS m(parts,ord) LIMIT 16) x;
   INSERT INTO public.combat_v2_events(scope_id,request_key,operation_kind,request_fingerprint,
    caller,status,error_sanitized,completed_at)
   VALUES('36651303-0795-4b3e-832d-e2ae6d070b0c'::uuid,key,'staff_panel_rejection_diagnostic',
    public.combat_v2_sha256(jsonb_build_object('request_key',key,'sqlstate',diag_state,'frames',diag_frames)),
    NULL,'fallita',jsonb_build_object('schema','staff-panel-diagnostic/1','sqlstate',diag_state,'frames',diag_frames),clock_timestamp())
   ON CONFLICT (scope_id,request_key) DO NOTHING;
  END IF;
 EXCEPTION WHEN OTHERS THEN
  -- Un errore del solo audit non sostituisce il rifiuto pubblico originale.
  NULL;
 END;
 BEGIN
  -- Audit35: letture e scrittura diagnostiche isolate, dopo il rollback della richiesta.
  -- Il guard costante racchiude TUTTO il nuovo audit; la recovery lo disattiva integralmente.
  IF TRUE THEN
   IF uid IS NOT NULL AND p IS NOT NULL AND jsonb_typeof(p)='object' AND public.is_staff() THEN
    diag35_key:=(p->>'request_key')::uuid;
    diag35_fingerprint:=public.combat_v2_sha256(p);
    SELECT * INTO diag35_offer FROM combat_panel_private.offers
     WHERE id=(p->>'offer_id')::uuid AND principal_user=uid;
    diag35_adapter:=diag35_offer.source_payload->>'adapter';
    IF diag35_key IS NOT NULL AND diag35_offer.id IS NOT NULL
     AND diag35_offer.principal_user=uid AND diag35_fingerprint~'^[0-9a-f]{64}$'
     AND diag35_adapter IN ('ordinary_v2','master_v2')
     AND combat_panel_private.access_reason('0b85f354-9cdb-47e1-baf9-3d266bb7e06b'::uuid,diag35_adapter) IS NULL
     AND combat_consumer_private.staff_test_allowed('0b85f354-9cdb-47e1-baf9-3d266bb7e06b'::uuid,ARRAY[uid]::uuid[],false)
    THEN
     SELECT jsonb_build_object('master_session_id',ds.master_session_id,'encounter_id',ds.id,
       'context_id',dc.id,'round_id',dc.round_id,'actor_id',da.id,'context_version',dc.context_version)
     INTO diag35_binding
     FROM combat_panel_private.contexts dc
     JOIN public.combat_v2_actors da ON da.id=diag35_offer.actor_id AND da.controller_user=uid
     JOIN public.combat_v2_sessions ds ON ds.id=da.session_id
     JOIN public.combat_v2_rounds dr ON dr.id=dc.round_id AND dr.session_id=ds.id
     JOIN public.locations dl ON dl.id=ds.location_id AND dl.is_active AND dl.is_test
     WHERE dc.id=diag35_offer.context_id AND dc.principal_user=uid AND dc.command_actor_id=da.id
      AND dc.activity_id=ds.id AND dc.activity_kind=diag35_adapter
      AND dc.location_id='0b85f354-9cdb-47e1-baf9-3d266bb7e06b'::uuid
      AND dl.id=dc.location_id
      AND combat_panel_private.uses_simulated_pools(ds.id) IS TRUE
      AND public.combat_v2_values_written(ds.id) IS FALSE;
     IF diag35_binding IS NOT NULL THEN
      SELECT coalesce(jsonb_agg(jsonb_build_object('function',df.parts[1],'line',df.parts[2]::integer) ORDER BY df.ord),'[]'::jsonb)
      INTO diag35_frames
      FROM (SELECT dm.parts,dm.ord FROM regexp_matches(diag_context,
       'PL/pgSQL function ([a-z_][a-z0-9_]*(?:[.][a-z_][a-z0-9_]*)?)[(][^\n]*[)] line ([0-9]+)',
       'g') WITH ORDINALITY AS dm(parts,ord) LIMIT 16) df;
      diag35_scope:=mission_ai_service_owner.uuid5((diag35_binding->>'encounter_id')::uuid,'staff-panel-rejection-diagnostic/2');
      diag35_data:=jsonb_build_object('schema','staff-panel-diagnostic/2','sqlstate',diag_state,
        'frames',diag35_frames,'binding',diag35_binding,'command_sha256',diag35_fingerprint);
      INSERT INTO public.combat_v2_events(scope_id,request_key,operation_kind,request_fingerprint,
       caller,control_version,status,error_sanitized,completed_at)
      VALUES(diag35_scope,diag35_key,'staff_panel_rejection_diagnostic',public.combat_v2_sha256(diag35_data),
       uid,(diag35_binding->>'context_version')::bigint,'fallita',diag35_data,clock_timestamp())
      ON CONFLICT (scope_id,request_key) DO NOTHING;
     END IF;
    END IF;
   END IF;
  END IF;
 EXCEPTION WHEN OTHERS THEN
  -- Un errore dell'audit corrente non altera né il rifiuto originale né l'audit storico.
  NULL;
 END;
 RETURN jsonb_build_object('schema_version','combat-panel-error/1','status','rejected','request_key',key,
   'code',code,'message',message,'recovery',recovery);
END $function$;

CREATE OR REPLACE FUNCTION clan_innata_private.combat_activation_window(p_actor uuid, p_technique uuid)
 RETURNS boolean
 LANGUAGE plpgsql
 STABLE SECURITY DEFINER
 SET search_path TO ''
AS $function$
DECLARE a public.combat_v2_actors%ROWTYPE; c clan_innata_combat_private.actor_context;
BEGIN
 SELECT * INTO STRICT a FROM public.combat_v2_actors WHERE id=p_actor;
 c:=clan_innata_private.combat_context(a.id);
 IF p_technique IN('65b30dec-6f9f-459e-b78c-49173d74f251'::uuid,'f3673da7-42c9-497e-abe1-1c0982429f35'::uuid,'1ab6d359-f337-45ed-839c-4e626d2e2819'::uuid)AND(clan_innata_narrative_private.staff_profile_actor_v1(p_actor)->>'technique_id')IS DISTINCT FROM p_technique::text THEN RETURN false;END IF;
 IF p_technique NOT IN ('001f907c-8f32-4758-8a16-ad1730e72c59'::uuid,'4a527ff2-0420-4da9-bc1f-5489c753b285'::uuid,'8e20bafe-cb3c-4967-b9c7-2a4bca694996'::uuid,'9b384de3-35f0-43c0-b145-94f985fa758a'::uuid,'a50808fa-e7cd-45ee-b4d4-33ad8c65d472'::uuid,'4056f62d-77f3-47f9-8ecb-9a7799682a9d'::uuid,'65b30dec-6f9f-459e-b78c-49173d74f251'::uuid,'f3673da7-42c9-497e-abe1-1c0982429f35'::uuid,'1ab6d359-f337-45ed-839c-4e626d2e2819'::uuid,'c11ecd52-43cd-479b-8d5d-08187beba56e'::uuid,'c9b261da-c9cd-40bb-8189-7b65ab5a1605'::uuid) OR p_technique IS NULL THEN RETURN false; END IF;
 RETURN c.activity_kind='ordinary_v2' AND c.phase='action' AND c.turn_actor_id=a.id
   AND NOT EXISTS(SELECT 1 FROM public.combat_v2_declarations d WHERE d.round_id=c.exchange_id AND d.actor_id=a.id)
   AND NOT EXISTS(SELECT 1 FROM clan_innata_combat_private.combat_receipts r WHERE r.session_id=a.session_id
     AND r.actor_id=a.id AND r.round_id=c.exchange_id AND
       ((r.operation='activate' AND r.chakra_spent>0) OR (r.operation='deactivate' AND r.technique_id=p_technique)))
   AND NOT EXISTS(SELECT 1 FROM combat_consumer_private.offers o WHERE o.session_id=a.session_id
     AND o.exchange_id=c.exchange_id AND o.principal_character_id=a.character_id AND o.state='consumed'
     AND o.operation='control' AND (o.source_payload->>'sabaku_operation'='transport'
       OR o.source_payload->>'marionetta_operation' IN ('move','relink')));
END $function$;

CREATE OR REPLACE FUNCTION clan_innata_private.combat_scope(p_actor uuid, p_technique uuid)
 RETURNS jsonb
 LANGUAGE plpgsql
 STABLE SECURITY DEFINER
 SET search_path TO ''
AS $function$
DECLARE result jsonb;
BEGIN
 IF p_technique='c9b261da-c9cd-40bb-8189-7b65ab5a1605'::uuid THEN
  RETURN clan_innata_combat_private.velo_innata_scope_v1(p_actor);
 ELSIF p_technique='001f907c-8f32-4758-8a16-ad1730e72c59'::uuid THEN
  RETURN clan_innata_private.combat_scope(p_actor);
 ELSIF p_technique='4a527ff2-0420-4da9-bc1f-5489c753b285'::uuid AND NOT clan_innata_narrative_private.byakugan_enabled_v1(p_actor)THEN RETURN clan_hyuga_private.combat_scope(p_actor);
 ELSIF p_technique IN('4a527ff2-0420-4da9-bc1f-5489c753b285'::uuid,'8e20bafe-cb3c-4967-b9c7-2a4bca694996'::uuid,'9b384de3-35f0-43c0-b145-94f985fa758a'::uuid,'a50808fa-e7cd-45ee-b4d4-33ad8c65d472'::uuid) THEN
  RETURN clan_innata_narrative_private.byakugan_scope_v1(p_actor,p_technique);
 ELSIF p_technique IN('65b30dec-6f9f-459e-b78c-49173d74f251'::uuid,'f3673da7-42c9-497e-abe1-1c0982429f35'::uuid,'1ab6d359-f337-45ed-839c-4e626d2e2819'::uuid)THEN
  result:=clan_innata_private.sharingan_combat_scope(p_actor);
  IF (result->>'is_test')::boolean THEN
   IF (clan_innata_narrative_private.staff_profile_actor_v1(p_actor)->>'technique_id')IS DISTINCT FROM p_technique::text
   THEN RAISE EXCEPTION 'common_combat_technique_not_supported' USING ERRCODE='22023';END IF;
  ELSIF clan_innata_narrative_private.sharingan_selected_v2(p_actor) IS DISTINCT FROM p_technique THEN
   RAISE EXCEPTION 'SHARINGAN_WORLD_CARRY_REQUIRED' USING ERRCODE='42501';
  END IF;
  PERFORM clan_innata_narrative_private.quote_v1(p_technique,NOT(result->>'is_test')::boolean);
  RETURN result;
 ELSIF p_technique='4056f62d-77f3-47f9-8ecb-9a7799682a9d'::uuid THEN RETURN clan_innata_private.sharingan_combat_scope(p_actor);
  ELSIF p_technique='c11ecd52-43cd-479b-8d5d-08187beba56e'::uuid THEN RETURN clan_inuzuka_private.quattro_scope(p_actor);
 END IF;
 RAISE EXCEPTION 'common_combat_technique_not_supported' USING ERRCODE='22023';
END $function$;

CREATE OR REPLACE FUNCTION clan_innata_private.combat_transition(p_actor uuid, p_technique uuid, p_operation text, p_request uuid, p_expected_state bigint)
 RETURNS jsonb
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO ''
AS $function$
DECLARE a public.combat_v2_actors%ROWTYPE; c clan_innata_combat_private.actor_context;
 s clan_innata_combat_private.combat_state%ROWTYPE; previous clan_innata_combat_private.combat_receipts%ROWTYPE;
 scope jsonb; cost_quote jsonb; fp text; amount integer:=0; before_balance integer; real_balance integer;
 receipt uuid; result jsonb; prior_flag text; terminate_reason text;
 t uuid:=p_technique;base_cost integer:=5;replaced jsonb;
 sharingan_quote clan_innata_narrative_private.config_quotes_v1;
BEGIN
 IF t='001f907c-8f32-4758-8a16-ad1730e72c59'::uuid THEN
  RETURN clan_innata_private.combat_transition(p_actor,p_operation,p_request,p_expected_state); END IF;
 IF p_request IS NULL OR p_expected_state IS NULL OR p_operation IS NULL
   OR p_operation NOT IN ('activate','deactivate','upkeep') THEN
   RAISE EXCEPTION 'common_combat_request_invalid' USING ERRCODE='22023'; END IF;
 SELECT * INTO STRICT a FROM public.combat_v2_actors WHERE id=p_actor;
 PERFORM 1 FROM public.combat_v2_sessions WHERE id=a.session_id FOR UPDATE;
 PERFORM 1 FROM combat_consumer_private.activities WHERE session_id=a.session_id FOR UPDATE;
 c:=clan_innata_private.combat_context(a.id);
 SELECT * INTO STRICT a FROM public.combat_v2_actors WHERE id=p_actor FOR UPDATE;
 fp:=public.combat_v2_sha256(jsonb_build_object('session',a.session_id,'actor',a.id,
   'round',c.exchange_id,'technique_id',t,'operation',p_operation,'expected_state',p_expected_state));
 -- A real higher OFF immediately changes the mutable Sharingan selection.
 -- Only the original committed OFF may return before normal scope checks.
 IF p_operation='deactivate' AND t IN('65b30dec-6f9f-459e-b78c-49173d74f251'::uuid,'f3673da7-42c9-497e-abe1-1c0982429f35'::uuid,'1ab6d359-f337-45ed-839c-4e626d2e2819'::uuid)
   AND public.combat_v2_values_written(a.session_id) THEN
  SELECT * INTO previous FROM clan_innata_combat_private.combat_receipts
   WHERE session_id=a.session_id AND actor_id=a.id AND request_id=p_request;
  IF FOUND THEN
   IF a.actor_kind IS DISTINCT FROM 'pg' OR a.companion_id IS NOT NULL
    OR a.controller_user IS DISTINCT FROM auth.uid() OR auth.uid() IS NULL
    OR NOT EXISTS(SELECT 1 FROM public.characters pc WHERE pc.id=a.character_id AND pc.user_id=auth.uid())
   THEN RAISE EXCEPTION 'SHARINGAN_WORLD_REPLAY_OWNER_REQUIRED' USING ERRCODE='42501';END IF;
   IF previous.is_test IS DISTINCT FROM false OR previous.technique_id IS DISTINCT FROM t
    OR previous.operation IS DISTINCT FROM 'deactivate' OR previous.round_id IS DISTINCT FROM c.exchange_id
    OR previous.fingerprint IS DISTINCT FROM fp
   THEN RAISE EXCEPTION 'common_combat_request_conflict' USING ERRCODE='22023';END IF;
   RETURN previous.result||jsonb_build_object('replayed',true);
  END IF;
 END IF;
 IF p_operation='deactivate'AND a.actor_kind='png'THEN
  scope:=clan_innata_narrative_private.png_drain_scope_v1(a.id,t);
 ELSE scope:=clan_innata_private.combat_scope(p_actor,t);END IF;
 IF t IN('4a527ff2-0420-4da9-bc1f-5489c753b285'::uuid,'8e20bafe-cb3c-4967-b9c7-2a4bca694996'::uuid,'9b384de3-35f0-43c0-b145-94f985fa758a'::uuid,'a50808fa-e7cd-45ee-b4d4-33ad8c65d472'::uuid)AND p_operation<>'deactivate'THEN base_cost:=(clan_innata_narrative_private.byakugan_quote_v1(t)).base_cost;END IF;
 IF t IN('65b30dec-6f9f-459e-b78c-49173d74f251'::uuid,'f3673da7-42c9-497e-abe1-1c0982429f35'::uuid,'1ab6d359-f337-45ed-839c-4e626d2e2819'::uuid) AND p_operation<>'deactivate' THEN
  IF p_operation='activate' AND NOT(scope->>'is_test')::boolean THEN
   RAISE EXCEPTION 'SHARINGAN_WORLD_ACTIVATION_REQUIRES_NARRATIVE' USING ERRCODE='42501';END IF;
  sharingan_quote:=clan_innata_narrative_private.quote_v1(t,NOT(scope->>'is_test')::boolean);
  base_cost:=CASE p_operation WHEN 'upkeep' THEN sharingan_quote.upkeep_cost ELSE sharingan_quote.activation_cost END;
 END IF;
 IF p_operation='activate'AND a.actor_kind='png'THEN
 INSERT INTO clan_innata_narrative_private.png_selections_v1(session_id,actor_id,technique_id,provider_instance_id,mechanical_version_id,source_sha256,snapshot_sha256,selection_request)
 SELECT a.session_id,a.id,t,i.id,i.mechanical_version_ref,i.source_sha256,i.snapshot_sha256,p_request
 FROM public.combat_v2_provider_instances_v1 i WHERE i.id=a.provider_instance_v1_id AND clan_innata_narrative_private.png_profile_valid_v1(a.id,t)
 ON CONFLICT(session_id,actor_id,technique_id)DO NOTHING;
 END IF;
 IF p_operation='activate' AND EXISTS(
   SELECT 1 FROM clan_marionettisti_private.links WHERE owner_actor_id=a.id AND state='connected') THEN
   RAISE EXCEPTION 'common_combat_jutsu_blocked_by_threads' USING ERRCODE='55000'; END IF;
 -- OFF è immediato anche fuori dal turno d'azione; ownership, sessione
 -- e condizioni dello scope restano verificate prima di questa distinzione.
 IF p_operation<>'deactivate' AND (c.phase<>'action' OR c.turn_actor_id<>a.id) THEN
   RAISE EXCEPTION 'common_combat_turn_invalid' USING ERRCODE='55000'; END IF;
 SELECT * INTO previous FROM clan_innata_combat_private.combat_receipts
   WHERE session_id=a.session_id AND actor_id=a.id AND request_id=p_request;
 IF FOUND THEN
   IF previous.fingerprint<>fp THEN RAISE EXCEPTION 'common_combat_request_conflict' USING ERRCODE='22023'; END IF;
   RETURN previous.result||jsonb_build_object('replayed',true);
 END IF;
 IF t='c9b261da-c9cd-40bb-8189-7b65ab5a1605'::uuid AND p_operation IN ('activate','deactivate') THEN
  IF NOT public.is_staff() OR a.controller_user IS DISTINCT FROM auth.uid()
   OR clan_innata_combat_private.velo_action_turn_v1(a.id,c.exchange_id) IS DISTINCT FROM c.personal_turn_id
   OR c.personal_turn_id IS NULL THEN
   RAISE EXCEPTION 'VELO_STAFF_NATIVE_TURN_REQUIRED' USING ERRCODE='42501';END IF;
  IF p_operation='activate' AND NOT EXISTS(
   SELECT 1 FROM clan_innata_combat_private.velo_rapid_turn_receipts_v1 rapid
   WHERE rapid.session_id=a.session_id AND rapid.actor_id=a.id AND rapid.round_id=c.exchange_id
     AND rapid.personal_turn_id=c.personal_turn_id AND rapid.request_id=p_request)
  THEN RAISE EXCEPTION 'VELO_STAFF_NATIVE_RAPID_REQUIRED' USING ERRCODE='42501';END IF;
 END IF;
 IF p_operation='deactivate'AND a.actor_kind='png'THEN
  SELECT * INTO STRICT s FROM clan_innata_combat_private.combat_state WHERE session_id=a.session_id AND actor_id=a.id AND technique_id=t FOR UPDATE;
 ELSE s:=clan_innata_private.combat_state_ensure(a.id,t);END IF;
 IF s.state_version<>p_expected_state THEN RAISE EXCEPTION 'common_combat_state_stale' USING ERRCODE='40001'; END IF;

 IF p_operation='activate' AND NOT s.active AND c.activity_kind='ordinary_v2'
   AND NOT clan_innata_private.combat_activation_window(a.id,t) THEN
  RAISE EXCEPTION 'common_activation_window_closed' USING ERRCODE='55000'; END IF;
 IF p_operation='activate' AND NOT s.active THEN amount:=base_cost;
 ELSIF p_operation='upkeep' THEN
   IF NOT s.active THEN RAISE EXCEPTION 'common_combat_innata_inactive' USING ERRCODE='55000'; END IF;
   IF s.activated_round_id IS DISTINCT FROM c.exchange_id AND s.last_upkeep_round_id IS DISTINCT FROM c.exchange_id THEN amount:=base_cost; END IF;
 END IF;
 IF amount>0 THEN
  cost_quote:=clan_hyuga_private.sedici_cost_quote(a.id,amount);
  amount:=(cost_quote->>'total')::integer;
 END IF;
 IF jsonb_typeof(a.mechanics_snapshot->'chakra') IS DISTINCT FROM 'number' THEN
   RAISE EXCEPTION 'common_combat_chakra_snapshot_invalid'; END IF;
 before_balance:=(a.mechanics_snapshot->>'chakra')::integer;
 IF before_balance<amount THEN
   IF p_operation='upkeep' THEN amount:=0; terminate_reason:='insufficient_chakra';
   ELSE RAISE EXCEPTION 'common_combat_insufficient_chakra' USING ERRCODE='22023'; END IF;
 END IF;
 IF amount>0 AND NOT (scope->>'is_test')::boolean AND a.actor_kind='pg' THEN
   SELECT chakra INTO STRICT real_balance FROM public.characters WHERE id=a.character_id FOR UPDATE;
   IF real_balance<amount THEN
     IF p_operation='upkeep' THEN amount:=0; terminate_reason:='insufficient_chakra';
     ELSE RAISE EXCEPTION 'common_combat_insufficient_real_chakra' USING ERRCODE='22023'; END IF;
   END IF;
 END IF;
 IF terminate_reason IS NOT NULL THEN
   UPDATE clan_innata_combat_private.combat_state SET active=false,state_version=state_version+1,
     last_upkeep_round_id=c.exchange_id
     WHERE session_id=a.session_id AND actor_id=a.id AND technique_id=t RETURNING * INTO s;
 ELSIF p_operation='activate' AND NOT s.active THEN
   IF(scope->>'is_test')::boolean AND t IN('4056f62d-77f3-47f9-8ecb-9a7799682a9d'::uuid,'65b30dec-6f9f-459e-b78c-49173d74f251'::uuid,'f3673da7-42c9-497e-abe1-1c0982429f35'::uuid,'1ab6d359-f337-45ed-839c-4e626d2e2819'::uuid)THEN
    SELECT coalesce(jsonb_agg(jsonb_build_object('technique_id',x.technique_id,'state_version',x.state_version)ORDER BY x.technique_id),'[]'::jsonb)INTO replaced FROM clan_innata_combat_private.combat_state x WHERE x.session_id=a.session_id AND x.actor_id=a.id AND x.active AND x.technique_id<>t AND x.technique_id IN('4056f62d-77f3-47f9-8ecb-9a7799682a9d'::uuid,'65b30dec-6f9f-459e-b78c-49173d74f251'::uuid,'f3673da7-42c9-497e-abe1-1c0982429f35'::uuid,'1ab6d359-f337-45ed-839c-4e626d2e2819'::uuid);
    UPDATE clan_innata_combat_private.combat_state SET active=false,state_version=state_version+1 WHERE session_id=a.session_id AND actor_id=a.id AND active AND technique_id<>t AND technique_id IN('4056f62d-77f3-47f9-8ecb-9a7799682a9d'::uuid,'65b30dec-6f9f-459e-b78c-49173d74f251'::uuid,'f3673da7-42c9-497e-abe1-1c0982429f35'::uuid,'1ab6d359-f337-45ed-839c-4e626d2e2819'::uuid);
   END IF;
   UPDATE clan_innata_combat_private.combat_state SET active=true,state_version=state_version+1,
     activated_round_id=c.exchange_id,last_upkeep_round_id=c.exchange_id
     WHERE session_id=a.session_id AND actor_id=a.id AND technique_id=t RETURNING * INTO s;
 ELSIF p_operation='deactivate' AND s.active THEN
   UPDATE clan_innata_combat_private.combat_state SET active=false,state_version=state_version+1
     WHERE session_id=a.session_id AND actor_id=a.id AND technique_id=t RETURNING * INTO s;
 ELSIF p_operation='upkeep' AND amount>0 THEN
   UPDATE clan_innata_combat_private.combat_state SET state_version=state_version+1,last_upkeep_round_id=c.exchange_id
     WHERE session_id=a.session_id AND actor_id=a.id AND technique_id=t RETURNING * INTO s;
 END IF;
 receipt:=gen_random_uuid();
 result:=jsonb_build_object('contract_version','common-combat-innata/1','receipt_id',receipt,
   'operation',p_operation,'technique_id',t,'active',s.active,'state_version',s.state_version,
   'technique_cost',CASE WHEN amount>0 THEN cost_quote ELSE NULL END,'chakra_spent',amount,'main_action_consumed',false,'is_test',(scope->>'is_test')::boolean,
   'values_written',amount>0 AND NOT (scope->>'is_test')::boolean,'replayed',false,'termination_reason',terminate_reason);
 IF replaced IS NOT NULL THEN result:=result||jsonb_build_object('replaced_family_states',replaced);END IF;
 INSERT INTO clan_innata_combat_private.combat_receipts(receipt_id,session_id,round_id,actor_id,technique_id,
   operation,request_id,fingerprint,chakra_spent,is_test,result)
   VALUES(receipt,a.session_id,c.exchange_id,a.id,
     t,
     p_operation,p_request,fp,amount,(scope->>'is_test')::boolean,result);
 IF amount>0 THEN
   INSERT INTO clan_innata_combat_private.combat_resource_ledger(receipt_id,expected_amount,committed_amount,
     applied_amount,is_test,balance_before,balance_after)
     VALUES(receipt,amount,amount,CASE WHEN (scope->>'is_test')::boolean THEN 0 ELSE amount END,
       (scope->>'is_test')::boolean,before_balance,before_balance-amount);
   UPDATE public.combat_v2_actors SET mechanics_snapshot=jsonb_set(mechanics_snapshot,'{chakra}',to_jsonb(before_balance-amount),false)
     WHERE id=a.id;
   IF NOT (scope->>'is_test')::boolean AND a.actor_kind='pg' THEN
     prior_flag:=current_setting('app.allow_chakra_delta',true);
     PERFORM set_config('app.allow_chakra_delta','1',true);
     UPDATE public.characters SET chakra=chakra-amount WHERE id=a.character_id;
     PERFORM set_config('app.allow_chakra_delta',coalesce(prior_flag,''),true);
   END IF;
 END IF;
 RETURN result;
END $function$;

CREATE OR REPLACE FUNCTION combat_v2_multitarget_internal.sync_declaration()
 RETURNS trigger
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO ''
AS $function$
declare prepared_endpoint combat_panel_private.master_movement_plans%ROWTYPE; endpoint_cap combat_spatial.movement_capabilities%ROWTYPE; manual_endpoint_valid boolean; multiplication_aim_valid boolean; ids uuid[]:='{}';j jsonb;t uuid;n int:=0;a public.combat_v2_actors%rowtype;
        fireball clan_uchiha_private.fireball_preparations%ROWTYPE;target public.combat_v2_actors%rowtype;meta jsonb;mode text;at_id uuid;attack_id uuid;attack public.combat_v2_declarations%rowtype;
 secondary_allowed boolean:=false;secondary_proof jsonb;secondary_session public.combat_v2_sessions;
 secondary_location public.locations;secondary_master public.master_v2_sessions;
 secondary_gate combat_panel_private.multiplication_tactics_release_gate;
begin
 if new.kind='attacco' then
  select*into strict a from public.combat_v2_actors where id=new.actor_id;
  meta:=new.sanitized_intent->'server_ability';
  fireball:=clan_uchiha_private.fireball_prepared(new.round_id,new.actor_id,new.request_key,new.sanitized_intent-'server_ability');
  if new.sanitized_intent?'target_actor_ids' then
   if jsonb_typeof(new.sanitized_intent->'target_actor_ids')<>'array' then raise exception 'targeting_cardinality_invalid';end if;
   for j in select value from jsonb_array_elements(new.sanitized_intent->'target_actor_ids') loop
    begin t:=(j#>>'{}')::uuid;exception when others then raise exception 'targeting_target_not_eligible';end;
    ids:=array_append(ids,t);
   end loop;
  else ids:=array[new.target_actor_id];end if;
  if cardinality(ids)<1 OR (cardinality(ids)>3 AND fireball.profile->>'mode' IS DISTINCT FROM 'esplosiva') then raise exception 'targeting_cardinality_invalid';end if;
  if cardinality(ids)<>(select count(distinct z)from unnest(ids)z)then raise exception 'targeting_duplicate_target';end if;
  if new.target_actor_id is distinct from ids[1]then raise exception 'targeting_primary_not_ordinal_1';end if;
  if fireball.actor_id IS NULL AND not combat_v2_multitarget_internal.attack_profile_ok(meta,cardinality(ids))then raise exception 'targeting_profile_missing';end if;
  foreach t in array ids loop
   select*into target from public.combat_v2_actors where id=t and session_id=a.session_id and state='attivo' for key share;
   if target.id is null or (target.team_key=a.team_key AND fireball.profile->>'mode' IS DISTINCT FROM 'esplosiva') then raise exception 'targeting_target_not_eligible';end if;
   IF fireball.actor_id IS NULL THEN
   manual_endpoint_valid:=false;
   IF coalesce(new.sanitized_intent->>'ability_source','mano')='mano' THEN
    SELECT * INTO prepared_endpoint FROM combat_panel_private.master_movement_plans WHERE request_key=new.request_key;
    IF prepared_endpoint.request_key IS NOT NULL THEN
     SELECT * INTO STRICT endpoint_cap FROM combat_spatial.movement_capabilities WHERE capability_id=prepared_endpoint.capability_id;
     IF split_part(endpoint_cap.choice_key,':',1)='melee-endpoint/1' THEN
      IF (prepared_endpoint.actor_id,prepared_endpoint.round_id,prepared_endpoint.principal_user,
          prepared_endpoint.controller_version,prepared_endpoint.state)
        IS DISTINCT FROM (a.id,new.round_id,exam_regia_private.current_principal(),a.controller_version,'prepared'::text)
        OR cardinality(ids)<>1 OR split_part(endpoint_cap.choice_key,':',2) IS DISTINCT FROM t::text
        OR split_part(endpoint_cap.choice_key,':',6) IS DISTINCT FROM md5('master-mano:'||new.round_id||':'||a.id)
        OR EXISTS(SELECT 1 FROM combat_panel_private.multiplication_formations WHERE actor_id=t AND state='active')
        OR NOT combat_panel_private.movement_attack_target_valid(a.id,t,endpoint_cap.capability_id,
           combat_panel_private.manual_contact_center_range(a.id,t)) THEN
       RAISE EXCEPTION 'panel_manual_endpoint_stale' USING ERRCODE='40001'; END IF;
      manual_endpoint_valid:=true;
     END IF;
    END IF;
   END IF;
   multiplication_aim_valid:=combat_panel_private.multiplication_attack_aim_valid(new.round_id,a.id,t,new.request_key,
     case when new.sanitized_intent->>'ability_source'='clan' and new.sanitized_intent->>'ability_id'='e361f7c3-f90b-47ec-bfee-ccbda21257d9' then 3 when coalesce(new.sanitized_intent->>'ability_source','mano')='mano' then combat_panel_private.manual_contact_center_range(a.id,t) else (CASE WHEN meta->>'sabaku_flow_version'='sabaku-flow/2' THEN 15 ELSE public._fascia_metri(meta->>'range') END) end);
   IF manual_endpoint_valid THEN multiplication_aim_valid:=true; END IF;
   IF new.sanitized_intent->>'ability_source'='clan' AND new.sanitized_intent->>'ability_id'='b076a976-c75b-4b5a-8813-b0e8e2c3af03' AND cardinality(ids)=1
     AND clan_inuzuka_private.zanna_master_endpoint_v1(new.round_id,a.id,t,new.request_key,'prepared')
   THEN multiplication_aim_valid:=true; END IF;
   IF new.sanitized_intent->>'ability_source'='clan'
    AND new.sanitized_intent->>'ability_id'='9ac77d79-9894-5388-9753-70538ac5eaa3'
    AND combat_v2_taijutsu_internal.entry_prepared(new.round_id,a.id,new.request_key,t) THEN
    multiplication_aim_valid:=true;
   END IF;
   if new.sanitized_intent ? 'target_fili' then
     if cardinality(ids)<>1 OR NOT EXISTS(SELECT 1 FROM clan_marionettisti_private.ocular_sever_authorizations_v1 permit
       WHERE permit.request_key=new.request_key AND permit.transaction_id=txid_current()
         AND permit.round_id=new.round_id AND permit.actor_id=a.id AND permit.target_id=t
         AND permit.proof IS NOT NULL AND permit.proof IS NOT DISTINCT FROM
           clan_marionettisti_private.ocular_sever_source_v1(new.round_id,a.id,t,(permit.proof->>'range_m')::numeric)) then
       raise exception 'fili_target_not_available' using errcode='22023';
     end if;
   elsif new.sanitized_intent->>'ability_source'='arma'
     and new.sanitized_intent->>'ability_id'=combat_panel_private.shuriken_profile_v1()->>'id' then
    if not combat_panel_private.shuriken_target_v1(a.id,t) then raise exception 'fuori_portata'; end if;
   elsif multiplication_aim_valid is not null then
    if new.sanitized_intent->>'ability_source'='clan'
      and new.sanitized_intent->>'ability_id'='e361f7c3-f90b-47ec-bfee-ccbda21257d9' then
      if cardinality(ids)<>1 then raise exception 'marionetta_single_target_required' using errcode='22023';end if;
       perform combat_panel_private.multiplication_companion_attack_source(new.round_id,a.id,t,new.request_key,null);end if;
    if not multiplication_aim_valid then raise exception 'fuori_portata';end if;
   elsif combat_panel_private.has_master_geometry(a.session_id)
    and new.sanitized_intent->>'ability_source'='clan'
    and new.sanitized_intent->>'ability_id'='e361f7c3-f90b-47ec-bfee-ccbda21257d9' then
    if cardinality(ids)<>1 or not clan_marionettisti_private.target_geometry_valid(new.round_id,a.id,t,new.sanitized_intent) then
      raise exception 'fuori_portata';end if;
   elsif combat_panel_private.has_master_geometry(a.session_id) then
    if not combat_panel_private.target_geometry_valid(a.id,t,case when coalesce(new.sanitized_intent->>'ability_source','mano')='mano' then combat_panel_private.manual_contact_center_range(a.id,t) else (CASE WHEN meta->>'sabaku_flow_version'='sabaku-flow/2' THEN 15 ELSE public._fascia_metri(meta->>'range') END) end) then raise exception 'fuori_portata';end if;
   elsif clan_marionettisti_private.is_dedicated_scene(a.session_id) then
    if not clan_marionettisti_private.target_geometry_valid(new.round_id,a.id,t,new.sanitized_intent) then raise exception 'fuori_portata';end if;
   elsif abs(a.position_m-target.position_m)>coalesce((CASE WHEN meta->>'sabaku_flow_version'='sabaku-flow/2' THEN 15 ELSE public._fascia_metri(meta->>'range') END),-1)then raise exception 'fuori_portata';end if;
   END IF; -- Fireball geometry/membership already bound by server preparation.
   n:=n+1;
   insert into public.combat_v2_attack_targets(round_id,attack_declaration_id,ordinal,target_actor_id,target_controller_version,target_position_m)
   values(new.round_id,new.id,n,t,target.controller_version,target.position_m);
  end loop;
 elsif new.kind in('difesa','nessuna')then
  select*into strict a from public.combat_v2_actors where id=new.actor_id;
  select*into strict attack from public.combat_v2_declarations where id=new.parent_attack_id and round_id=new.round_id and kind='attacco';
  -- The physical key is parent+defender. The existing release gate still limits
  -- the additional defender behavior; every producer, including native none,
  -- reaches this trigger before any coverage/geometry writes below.
  PERFORM public.combat_v2_lock_round(new.round_id);
  -- Native API transactions use READ COMMITTED (live/preflight captured).
  -- Fail closed for an unsupported caller isolation instead of a stale guard.
  IF current_setting('transaction_isolation') IS DISTINCT FROM 'read committed'
  THEN RAISE EXCEPTION 'secondary_defense_native_isolation_required' USING ERRCODE='55000';END IF;
  IF EXISTS(SELECT 1 FROM public.combat_v2_declarations prior
    WHERE prior.parent_attack_id=new.parent_attack_id AND prior.kind IN('difesa','nessuna')
      AND prior.id<>new.id AND prior.actor_id<>new.actor_id) THEN
   SELECT * INTO secondary_gate FROM combat_panel_private.multiplication_tactics_release_gate g
    WHERE g.singleton AND g.version>=1 AND g.revision_reference='combat-multiplication-tactics/1' FOR SHARE;
   SELECT * INTO STRICT secondary_session FROM public.combat_v2_sessions WHERE id=a.session_id;
   SELECT * INTO STRICT secondary_location FROM public.locations WHERE id=secondary_session.location_id;
   IF secondary_gate.singleton IS TRUE AND secondary_session.state='in_corso'
    AND secondary_session.closed_at IS NULL AND a.companion_id IS NULL
    AND NOT EXISTS(SELECT 1 FROM exam_regia_private.bindings eb WHERE eb.combat_session_id=secondary_session.id) THEN
    IF secondary_gate.staff_enabled AND secondary_location.is_active AND secondary_location.is_test
     AND secondary_session.location_id='0b85f354-9cdb-47e1-baf9-3d266bb7e06b'::uuid
     AND NOT public.combat_v2_values_written(secondary_session.id) THEN
     secondary_proof:=clan_innata_narrative_private.fenice_staff_proof_v1(attack.actor_id);
     secondary_allowed:=secondary_proof IS NOT NULL
      AND secondary_proof->>'schema_version'='staff-fenice-dependency/1'
      AND secondary_proof->>'session_id'=secondary_session.id::text
      AND secondary_proof->>'actor_id'=attack.actor_id::text
      AND secondary_proof->>'sha256'=public.combat_v2_sha256(secondary_proof-'sha256')
      AND EXISTS(SELECT 1 FROM public.combat_v2_actors source_actor
       WHERE source_actor.id=attack.actor_id AND source_actor.session_id=secondary_session.id
        AND source_actor.mechanics_snapshot->'fenice_staff_dependency'=secondary_proof)
      AND attack.sanitized_intent->>'ability_id'='6cc40917-1719-4759-9ba8-3064b806c24e'
      AND attack.sanitized_intent->'server_ability'=secondary_proof->'ability'
      AND (SELECT count(*) FROM public.combat_v2_attack_targets mt WHERE mt.attack_declaration_id=attack.id)>1;
    ELSIF secondary_location.is_active AND NOT secondary_location.is_test AND NOT secondary_location.is_exam_room THEN
     -- Existing ordinary/master/generic Tactics release modes only. These flags
     -- are all false in this Staff release. Producer Auth/permits stay unchanged.
     IF secondary_session.master_session_id IS NULL THEN
      secondary_allowed:=secondary_gate.ordinary_enabled AND a.actor_kind='pg'
       AND combat_panel_private.owner_turn_context(a.id)->>'activity_kind'='ordinary_v2';
     ELSE
      SELECT * INTO secondary_master FROM public.master_v2_sessions WHERE id=secondary_session.master_session_id
       AND location_id=secondary_session.location_id AND closed_at IS NULL;
      IF secondary_master.owner_kind='human' AND secondary_master.master_user IS NOT NULL THEN
       secondary_allowed:=secondary_gate.master_enabled
        AND combat_panel_private.owner_turn_context(a.id)->>'activity_kind'='master_v2';
      ELSIF secondary_master.owner_kind='ai_service' AND secondary_master.master_user IS NULL THEN
       secondary_allowed:=((a.actor_kind='pg' AND secondary_gate.master_enabled)
        OR(a.actor_kind='png' AND secondary_gate.generic_enabled AND secondary_session.source_kind='master' AND secondary_session.lesiva IS FALSE))
        AND combat_panel_private.owner_turn_context(a.id)->>'activity_kind'='master_v2'
        AND EXISTS(SELECT 1 FROM mission_public_owner.session_admissions_v1 adm
         JOIN mission_public_owner.publications_v2 pub ON pub.request_key=adm.publication_request
          AND pub.mission_id=adm.mission_id AND pub.source_mission_id=adm.mission_id
          AND pub.config_version=adm.capability_version AND pub.target='public'
          AND pub.visibility='open' AND pub.state='open'
         WHERE adm.master_session_id=secondary_master.id AND adm.location_id=secondary_session.location_id
          AND adm.mode='ai' AND adm.publication_request IS NOT NULL
          AND mission_public_owner.role_session_allowed_v1(secondary_master.id)
          AND mission_public_owner.c1266_regia_public_scope_v1(adm.mission_id,'ai',adm.publication_request,pub.release_revision_sha256));
      END IF;
     END IF;
    END IF;
   END IF;
   IF secondary_allowed IS DISTINCT FROM true THEN
    RAISE EXCEPTION 'secondary_defense_scope_not_released' USING ERRCODE='42501';
   END IF;
  END IF;
  meta:=new.sanitized_intent->'server_ability';
  if new.sanitized_intent?'attack_target_ids'then
   if jsonb_typeof(new.sanitized_intent->'attack_target_ids')<>'array'then raise exception 'targeting_cardinality_invalid';end if;
   for j in select value from jsonb_array_elements(new.sanitized_intent->'attack_target_ids')loop
    begin at_id:=(j#>>'{}')::uuid;exception when others then raise exception 'defense_targeting_not_eligible';end;
    ids:=array_append(ids,at_id);
   end loop;
  else
   select array_agg(x.id order by x.ordinal)into ids from public.combat_v2_attack_targets x
    where x.attack_declaration_id=new.parent_attack_id and x.target_actor_id=new.target_actor_id;
  end if;
  if ids is null or cardinality(ids)=0 or cardinality(ids)<>(select count(distinct z)from unnest(ids)z)then raise exception 'defense_targeting_not_eligible';end if;
  mode:=case
    when new.kind='nessuna'
      or coalesce(new.sanitized_intent->>'reaction','nessuna')in('schivata','parata','nessuna')
      then 'self'
    when coalesce(new.sanitized_intent->>'reaction','')='tecnica'
      and nullif(meta#>>'{targeting,mode}','') is null
      then 'self'
    else meta#>>'{targeting,mode}'
  end;
  if mode is null or mode not in('self','intercept','multi_protect')then raise exception 'defense_targeting_not_eligible';end if;
  if mode='self'and cardinality(ids)<>1 then raise exception 'defense_targeting_not_eligible';end if;
  if mode<>'self'and not combat_v2_multitarget_internal.defense_profile_ok(meta,mode,cardinality(ids))then raise exception 'defense_targeting_not_eligible';end if;
  foreach at_id in array ids loop
   IF combat_panel_private.multiplication_no_defense(at_id) THEN
    RAISE EXCEPTION 'defense_targeting_not_required' USING ERRCODE='22023'; END IF;
   select x.target_actor_id,d.id into t,attack_id from public.combat_v2_attack_targets x join public.combat_v2_declarations d on d.id=x.attack_declaration_id
    where x.id=at_id and x.round_id=new.round_id and x.state='attesa_difesa' for update of x;
   if t is null then raise exception 'targeting_child_already_covered';end if;
   if mode in('self','intercept')and attack_id is distinct from new.parent_attack_id then raise exception 'defense_targeting_cross_parent';end if;
   select*into target from public.combat_v2_actors where id=t for key share;
   if mode='self'and t<>new.actor_id and not clan_marionettisti_private.defends_body(new.actor_id,t,coalesce(new.sanitized_intent->>'reaction','nessuna')) then raise exception 'defense_targeting_not_eligible';end if;
   if mode<>'self'and(target.team_key<>a.team_key or
     case when combat_panel_private.has_master_geometry(a.session_id)
       then combat_panel_private.actor_distance(a.id,target.id)>2
       else abs(a.position_m-target.position_m)>2 end)then raise exception 'defense_targeting_not_eligible';end if;
   insert into public.combat_v2_defense_coverages(round_id,defense_declaration_id,attack_target_id,protected_actor_id,mode,defender_controller_version,protected_position_m)
   values(new.round_id,new.id,at_id,t,mode,a.controller_version,target.position_m);
   perform combat_panel_private.capture_coverage_geometry(new.id,at_id);
   update public.combat_v2_attack_targets set state='coperta'where id=at_id;
  end loop;
 end if;
 IF new.kind IN ('attacco','difesa','nessuna') THEN
   PERFORM clan_innata_combat_private.velo_freeze_declaration_v1(new.id);
 END IF;
 return new;
end
$function$;

CREATE OR REPLACE FUNCTION public.combat_v2_round_resolve(p_round uuid, p_request_key uuid)
 RETURNS jsonb
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO ''
AS $function$
declare verme_profile jsonb;verme_result jsonb;nara_launch jsonb; nara_facts jsonb; elemental_claim jsonb; elemental_channels jsonb; elemental_cap jsonb; elemental_order_outcome jsonb; elemental_order_ready boolean:=false; elemental_target uuid; fireball_profile jsonb; hyuga_profile jsonb; hyuga_juken jsonb; sedici_target uuid; multiplication_facts jsonb; multiplication_effect jsonb; multiplication_target uuid; v_uid uuid:=auth.uid(); v_r public.combat_v2_rounds%rowtype; v_s public.combat_v2_sessions%rowtype; v_m public.master_v2_sessions%rowtype;
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
                IF v_calc#>>'{paralisi,contract}' IS DISTINCT FROM 'paralisi-movement/1' THEN
        v_calc:=v_calc||jsonb_build_object('sabaku_armor',clan_sabaku_private.armor_absorb(multiplication_target,v_damage));
        v_damage:=(v_calc#>>'{sabaku_armor,damage_after}')::integer;
        IF NOT (v_calc->'sabaku_armor' ? 'version') THEN v_calc:=v_calc-'sabaku_armor'; END IF;
        END IF;
        verme_result:=clan_aburame_private.verme_finish_v1(v_d.id,v_tar.id,
         v_final>=0 AND v_reaction<>'sostituzione' AND NOT coalesce((multiplication_effect->>'copy_intercepted')::boolean,false),v_damage);
        IF verme_result IS NOT NULL THEN v_calc:=v_calc||jsonb_build_object('aburame_verme',verme_result);END IF;
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

CREATE OR REPLACE FUNCTION combat_v2_multitarget_internal.resolve_parent(p_session uuid, p_round uuid, p_attack uuid, p_values boolean)
 RETURNS jsonb
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO ''
AS $function$
declare verme_profile jsonb;verme_result jsonb;verme_success boolean;
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
    elemental_cap:=combat_effects_private.capture_source_cap(d.id,damage);
   IF elemental_cap<>'{}'::jsonb THEN
     calc:=calc||jsonb_build_object('common_effects',
       coalesce(calc->'common_effects','{}'::jsonb)||elemental_cap);
   END IF;
    IF calc#>>'{paralisi,contract}' IS DISTINCT FROM 'paralisi-movement/1' THEN
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
 IF d.sanitized_intent#>>'{server_ability,nara_launch,schema_version}'='nara-possession/1' THEN
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

CREATE OR REPLACE FUNCTION clan_akimichi_private.common_attack_power_freeze_v1(p_declaration uuid)
 RETURNS void
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO ''
AS $function$

DECLARE d public.combat_v2_declarations%ROWTYPE; a public.combat_v2_actors%ROWTYPE;
 f clan_sabaku_private.flow_sources%ROWTYPE; j clan_hyuga_private.juken_sources%ROWTYPE;
 h clan_hyuga_private.sedici_sources%ROWTYPE; m clan_marionettisti_private.offensive_profiles%ROWTYPE;
 u clan_uchiha_private.fireball_sources%ROWTYPE; old clan_akimichi_private.common_attack_powers_v1%ROWTYPE;
 prof jsonb; native_hash text; fingerprint text; pool bigint; power bigint; base integer; family text; source_actor uuid;
BEGIN
 IF NOT EXISTS(SELECT 1 FROM clan_akimichi_private.common_gate_v1 WHERE singleton AND (staff_enabled OR public_enabled)) THEN RETURN; END IF;
 SELECT * INTO STRICT d FROM public.combat_v2_declarations WHERE id=p_declaration;
 IF d.kind<>'attacco' THEN RETURN; END IF;
 SELECT * INTO STRICT a FROM public.combat_v2_actors WHERE id=d.actor_id;
 IF exam_regia_private.is_bound(a.session_id) OR lower(coalesce(d.sanitized_intent#>>'{server_ability,kind}','fisico'))<>'fisico'
 OR NOT EXISTS(SELECT 1 FROM public.combat_v2_attack_targets t WHERE t.attack_declaration_id=d.id AND clan_akimichi_private.cellular_meta_v1(t.target_actor_id) IS NOT NULL) THEN RETURN;END IF;
 fingerprint:=clan_hyuga_private.juken_declaration_fingerprint(d.id);
 SELECT * INTO old FROM clan_akimichi_private.common_attack_powers_v1 WHERE declaration_id=d.id;
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
 IF d.sanitized_intent#>>'{server_ability,nara_launch,schema_version}'='nara-possession/1' THEN
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
 prof:=jsonb_build_object('version','akimichi-common-attack-power/1','family',family,'source_actor_id',source_actor,
  'power_base',base,'pool',pool,'power_contribution',CASE WHEN family='sabaku-flow/2' THEN 0 ELSE pool/10 END,
  'modifiers',CASE WHEN family='akimichi-partial/1' THEN jsonb_build_array(jsonb_build_object('kind','akimichi_mass','value',prof->'mass'))
     WHEN family='physical-hand/1' AND clan_akimichi_private.body_attack_mass(d.id)>0 THEN
       jsonb_build_array(jsonb_build_object('kind','akimichi_mass','value',clan_akimichi_private.body_attack_mass(d.id)))
     ELSE '[]'::jsonb END,'power',power,'native_source_hash',native_hash,'declaration_id',d.id);
 INSERT INTO clan_akimichi_private.common_attack_powers_v1(declaration_id,round_id,actor_id,declaration_sha256,profile,source_sha256)
 VALUES(d.id,d.round_id,a.id,fingerprint,prof,public.combat_v2_sha256(prof));
END

$function$;

CREATE OR REPLACE FUNCTION combat_panel_private.movement_budget(p_owner uuid, p_round uuid)
 RETURNS jsonb
 LANGUAGE plpgsql
 STABLE SECURITY DEFINER
 SET search_path TO ''
AS $function$
DECLARE a public.combat_v2_actors%ROWTYPE; base numeric; spent numeric; bonus numeric:=0; elemental_delta numeric:=0; elemental_effect jsonb;
BEGIN
 SELECT * INTO STRICT a FROM public.combat_v2_actors WHERE id=p_owner AND companion_id IS NULL;
 IF a.actor_kind NOT IN ('pg','png') OR NOT EXISTS(SELECT 1 FROM public.combat_v2_rounds WHERE id=p_round AND session_id=a.session_id)
   OR NOT (combat_panel_private.has_master_geometry(a.session_id) OR EXISTS(
     SELECT 1 FROM combat_consumer_private.activities WHERE session_id=a.session_id)) THEN
   RAISE EXCEPTION 'panel_movement_budget_scope_invalid' USING ERRCODE='22023'; END IF;
 IF jsonb_typeof(a.mechanics_snapshot->'velocita') IS DISTINCT FROM 'number'
   OR (a.mechanics_snapshot->>'velocita')::numeric<0
   OR (a.mechanics_snapshot->>'velocita')::numeric IN ('NaN'::numeric,'Infinity'::numeric) THEN
   RAISE EXCEPTION 'panel_movement_speed_invalid' USING ERRCODE='22023'; END IF;
 -- Velo modifica la caratteristica prima della conversione in metri.
 base:=floor(((a.mechanics_snapshot->>'velocita')::numeric
   + clan_innata_combat_private.velo_stat_delta_v1(a.id))/10)*5;
 -- Ogni percorso conserva la sua ricevuta sorgente. PG e marionetta
 -- consumano entrambi quella del medesimo owner; il movimento principale
 -- Master ha la ricevuta della dichiarazione, mai una seconda contabilita.
 SELECT coalesce(sum(cost_m),0) INTO spent FROM (
   SELECT combat_panel_private.movement_event_cost((result->>'event_id')::uuid,distance_m) AS cost_m FROM clan_marionettisti_private.movement_receipts WHERE owner_actor_id=a.id AND round_id=ANY(exam_regia_private.logical_round_ids(p_round))
   UNION ALL
   SELECT combat_panel_private.movement_event_cost(spatial_event_id,distance_m) AS cost_m FROM combat_panel_private.master_movement_receipts WHERE owner_actor_id=a.id AND round_id=ANY(exam_regia_private.logical_round_ids(p_round))
   UNION ALL
   SELECT cost_m FROM combat_panel_private.multiplication_diversivo_receipts
    WHERE actor_id=a.id AND round_id=ANY(exam_regia_private.logical_round_ids(p_round))
   UNION ALL
   SELECT cost_m FROM combat_panel_private.multiplication_assault_route_receipts
    WHERE actor_id=a.id AND round_id=ANY(exam_regia_private.logical_round_ids(p_round))
 ) settled;
 IF spent<0 OR spent IN ('NaN'::numeric,'Infinity'::numeric) THEN
   RAISE EXCEPTION 'panel_movement_ledger_invalid' USING ERRCODE='22023'; END IF;
 -- Nome fisso di un provider privato. Nessun nome funzione o numero dal
 -- client; nessun collegamento a tecniche non ancora installate/attive.
 IF to_regprocedure('clan_sabaku_private.transport_movement_bonus(uuid)') IS NOT NULL THEN
   EXECUTE 'SELECT CASE WHEN EXISTS(SELECT 1 FROM clan_sabaku_private.transport_uses WHERE actor_id=$1 AND state=''active'')
     THEN clan_sabaku_private.transport_movement_bonus($1) ELSE 0 END' INTO bonus USING a.id;
   IF bonus IS NULL OR bonus NOT IN (0,5) THEN
     RAISE EXCEPTION 'panel_movement_source_invalid' USING ERRCODE='22023'; END IF;
 END IF;
 elemental_effect:=combat_effects_private.movement_modifier(a.id,p_round);
 elemental_delta:=(elemental_effect->>'delta_m')::numeric;
 IF elemental_delta IS NULL OR elemental_delta NOT IN (0,-2) THEN RAISE EXCEPTION 'elemental_movement_modifier_invalid';END IF;
 bonus:=bonus+clan_inuzuka_private.movement_bonus(a.id); IF bonus NOT IN (0,5) THEN RAISE EXCEPTION 'inuzuka_movement_bonus_invalid' USING ERRCODE='22023'; END IF; RETURN jsonb_build_object('base_m',base,'spent_m',spent,'movement_max_flat_m',bonus,
   'maximum_m',clan_akimichi_private.movement_maximum(a.id,greatest(0,base+bonus+elemental_delta)),
   'remaining_m',CASE WHEN a.state='attivo' THEN greatest(0,
     clan_akimichi_private.movement_maximum(a.id,greatest(0,base+bonus+elemental_delta))-spent) ELSE 0 END)
   ||CASE WHEN elemental_delta=0 THEN '{}'::jsonb ELSE jsonb_build_object('temporary_effect',elemental_effect) END;
END $function$;

CREATE OR REPLACE FUNCTION clan_innata_private.combat_begin_turn(p_actor uuid)
 RETURNS void
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO ''
AS $function$
DECLARE a public.combat_v2_actors%ROWTYPE; c clan_innata_combat_private.actor_context;
 s clan_innata_combat_private.combat_state%ROWTYPE; key uuid;
BEGIN
 PERFORM clan_innata_private.combat_begin_turn(p_actor,'4a527ff2-0420-4da9-bc1f-5489c753b285'::uuid);
 PERFORM clan_innata_private.combat_begin_turn(p_actor,'4056f62d-77f3-47f9-8ecb-9a7799682a9d'::uuid);
  PERFORM clan_innata_private.combat_begin_turn(p_actor,'c11ecd52-43cd-479b-8d5d-08187beba56e'::uuid);
 IF EXISTS(SELECT 1 FROM clan_innata_combat_private.combat_state AS st
    JOIN public.combat_v2_actors AS owner ON owner.id=st.actor_id AND owner.session_id=st.session_id
    WHERE owner.id=p_actor AND st.technique_id='c9b261da-c9cd-40bb-8189-7b65ab5a1605'::uuid AND st.is_test IS TRUE AND st.active) THEN
  PERFORM clan_innata_private.combat_begin_turn(p_actor,'c9b261da-c9cd-40bb-8189-7b65ab5a1605'::uuid);
 END IF;
 SELECT * INTO STRICT a FROM public.combat_v2_actors WHERE id=p_actor;
 c:=clan_innata_private.combat_context(a.id);
 BEGIN s:=clan_innata_private.combat_state_read(a.id);
 EXCEPTION WHEN insufficient_privilege THEN RETURN; END;
 IF NOT coalesce(s.active,false) OR s.last_upkeep_round_id=c.exchange_id THEN RETURN; END IF;
 -- Human duels alternate one legal owner per exchange; a ready defensive
 -- actor_turn is not a new upkeep turn. Readers may enter here before actions.
 IF c.activity_kind='master_v2'
  AND c.location_id='0b85f354-9cdb-47e1-baf9-3d266bb7e06b'::uuid
  AND c.policy_id='staff_test_no_persistent_resources_v1' THEN
 IF NOT public.combat_v2_values_written(a.session_id)
  AND combat_panel_private.uses_simulated_pools(a.session_id)
  AND combat_panel_private.human_duel_round(c.exchange_id)
  AND combat_panel_private.human_duel_turn_allowed(c.exchange_id,a.id) IS DISTINCT FROM true
 THEN RETURN; END IF;
 END IF;
 IF c.phase<>'action' OR c.turn_actor_id<>a.id THEN RAISE EXCEPTION 'common_upkeep_wrong_turn'; END IF;
 IF coalesce((a.mechanics_snapshot->>'vita')::integer,0)<=0 THEN
   PERFORM clan_innata_private.combat_terminal(a.id,'owner_ko'); RETURN; END IF;
 IF a.state<>'attivo' THEN
   PERFORM clan_innata_private.combat_terminal(a.id,'owner_inoperative'); RETURN; END IF;
 IF NOT EXISTS(SELECT 1 FROM public.presence WHERE user_id=a.controller_user AND location_id=c.location_id) THEN
   PERFORM clan_innata_private.combat_terminal(a.id,'owner_absent'); RETURN; END IF;
 key:=md5('common-upkeep:'||a.session_id||':'||a.id||':'||c.exchange_id)::uuid;
 PERFORM clan_innata_private.combat_transition(a.id,'upkeep',key,s.state_version);
END $function$;

CREATE OR REPLACE FUNCTION clan_innata_private.combat_begin_turn(p_actor uuid, p_technique uuid)
 RETURNS void
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO ''
AS $function$
DECLARE a public.combat_v2_actors%ROWTYPE; c clan_innata_combat_private.actor_context;
 s clan_innata_combat_private.combat_state%ROWTYPE; key uuid;
BEGIN
 IF p_technique='4056f62d-77f3-47f9-8ecb-9a7799682a9d'::uuid THEN p_technique:=clan_innata_narrative_private.sharingan_selected_v2(p_actor);END IF;
 IF p_technique='4a527ff2-0420-4da9-bc1f-5489c753b285'::uuid THEN
 SELECT st.technique_id INTO key FROM clan_innata_combat_private.combat_state st JOIN clan_innata_narrative_private.byakugan_catalog_v1 q ON q.technique_id=st.technique_id WHERE st.actor_id=p_actor AND st.active;
 IF key IS NOT NULL THEN p_technique:=key;END IF;END IF;
 IF p_technique='001f907c-8f32-4758-8a16-ad1730e72c59'::uuid THEN
  PERFORM clan_innata_private.combat_begin_turn(p_actor); RETURN; END IF;
 IF (p_technique IS NULL OR p_technique NOT IN ('4a527ff2-0420-4da9-bc1f-5489c753b285'::uuid,'8e20bafe-cb3c-4967-b9c7-2a4bca694996'::uuid,'9b384de3-35f0-43c0-b145-94f985fa758a'::uuid,'a50808fa-e7cd-45ee-b4d4-33ad8c65d472'::uuid,'4056f62d-77f3-47f9-8ecb-9a7799682a9d'::uuid,'65b30dec-6f9f-459e-b78c-49173d74f251'::uuid,'f3673da7-42c9-497e-abe1-1c0982429f35'::uuid,'1ab6d359-f337-45ed-839c-4e626d2e2819'::uuid,'c11ecd52-43cd-479b-8d5d-08187beba56e'::uuid,'c9b261da-c9cd-40bb-8189-7b65ab5a1605'::uuid)) THEN
  RAISE EXCEPTION 'common_combat_technique_not_supported' USING ERRCODE='22023'; END IF;
 SELECT * INTO STRICT a FROM public.combat_v2_actors WHERE id=p_actor;
 PERFORM 1 FROM public.combat_v2_sessions WHERE id=a.session_id FOR UPDATE;
 PERFORM 1 FROM combat_consumer_private.activities WHERE session_id=a.session_id FOR UPDATE;
 SELECT * INTO STRICT a FROM public.combat_v2_actors WHERE id=p_actor FOR UPDATE;
 c:=clan_innata_private.combat_context(a.id);
 SELECT * INTO s FROM clan_innata_combat_private.combat_state WHERE session_id=a.session_id
   AND actor_id=a.id AND technique_id=p_technique FOR UPDATE;
 IF NOT coalesce(s.active,false) THEN RETURN; END IF;
 IF p_technique='c9b261da-c9cd-40bb-8189-7b65ab5a1605'::uuid
    AND (s.is_test IS DISTINCT FROM true OR NOT clan_innata_combat_private.velo_profile_bound_v1(a.id)) THEN
  IF s.is_test IS TRUE THEN
   PERFORM clan_innata_private.combat_terminal(a.id,p_technique,'owner_inoperative');
  END IF;
  RETURN;
 END IF;
 IF a.actor_kind='png'AND NOT clan_innata_narrative_private.png_profile_valid_v1(a.id,p_technique)THEN
  PERFORM clan_innata_private.combat_terminal(a.id,p_technique,'innata_off');RETURN;
 END IF;
 IF coalesce((a.mechanics_snapshot->>'vita')::integer,0)<=0 THEN
  PERFORM clan_innata_private.combat_terminal(a.id,p_technique,'owner_ko'); RETURN; END IF;
 IF a.state<>'attivo' THEN
  PERFORM clan_innata_private.combat_terminal(a.id,p_technique,'owner_inoperative'); RETURN; END IF;
 IF a.actor_kind='pg'AND NOT EXISTS(SELECT 1 FROM public.presence WHERE user_id=a.controller_user AND location_id=c.location_id) THEN
  PERFORM clan_innata_private.combat_terminal(a.id,p_technique,'owner_absent'); RETURN; END IF;
 IF s.last_upkeep_round_id=c.exchange_id THEN RETURN; END IF;
 -- Human duels alternate one legal owner per exchange; a ready defensive
 -- actor_turn is not a new upkeep turn. Readers may enter here before actions.
 IF c.activity_kind='master_v2'
  AND c.location_id='0b85f354-9cdb-47e1-baf9-3d266bb7e06b'::uuid
  AND c.policy_id='staff_test_no_persistent_resources_v1' THEN
 IF NOT public.combat_v2_values_written(a.session_id)
  AND combat_panel_private.uses_simulated_pools(a.session_id)
  AND combat_panel_private.human_duel_round(c.exchange_id)
  AND combat_panel_private.human_duel_turn_allowed(c.exchange_id,a.id) IS DISTINCT FROM true
 THEN RETURN; END IF;
 END IF;
 IF c.phase<>'action' OR c.turn_actor_id<>a.id THEN RAISE EXCEPTION 'common_upkeep_wrong_turn'; END IF;
 key:=md5('common-upkeep:'||a.session_id||':'||a.id||':'||p_technique||':'||c.exchange_id)::uuid;
 IF p_technique='4056f62d-77f3-47f9-8ecb-9a7799682a9d'::uuid
  OR (NOT s.is_test AND p_technique IN('65b30dec-6f9f-459e-b78c-49173d74f251'::uuid,'f3673da7-42c9-497e-abe1-1c0982429f35'::uuid,'1ab6d359-f337-45ed-839c-4e626d2e2819'::uuid)) THEN
  BEGIN
   PERFORM clan_innata_private.combat_transition(a.id,p_technique,'upkeep',key,s.state_version);
  EXCEPTION WHEN insufficient_privilege THEN
   -- Rejected scope rolls back the upkeep subtransaction; terminal is native, no refund.
   PERFORM clan_innata_private.combat_terminal(a.id,p_technique,'innata_off');
  END;
 ELSE
  PERFORM clan_innata_private.combat_transition(a.id,p_technique,'upkeep',key,s.state_version);
 END IF;
END $function$;

CREATE OR REPLACE FUNCTION clan_innata_private.combat_terminal(p_actor uuid, p_reason text)
 RETURNS void
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO ''
AS $function$
DECLARE a public.combat_v2_actors%ROWTYPE; c clan_innata_combat_private.actor_context;
 s clan_innata_combat_private.combat_state%ROWTYPE; use_id uuid; key uuid; receipt uuid:=gen_random_uuid();
 result jsonb; test boolean; changed boolean:=false;
BEGIN
 PERFORM clan_innata_private.combat_terminal(p_actor,'4a527ff2-0420-4da9-bc1f-5489c753b285'::uuid,p_reason);
 PERFORM clan_innata_private.combat_terminal(p_actor,'4056f62d-77f3-47f9-8ecb-9a7799682a9d'::uuid,p_reason);
  PERFORM clan_innata_private.combat_terminal(p_actor,'c11ecd52-43cd-479b-8d5d-08187beba56e'::uuid,p_reason);
 IF EXISTS(SELECT 1 FROM clan_innata_combat_private.combat_state AS st
    JOIN public.combat_v2_actors AS aa ON aa.session_id=st.session_id AND aa.id=st.actor_id
    WHERE aa.id=p_actor AND st.technique_id='c9b261da-c9cd-40bb-8189-7b65ab5a1605'::uuid
      AND st.active AND st.is_test IS TRUE) THEN
  PERFORM clan_innata_private.combat_terminal(p_actor,'c9b261da-c9cd-40bb-8189-7b65ab5a1605'::uuid,p_reason);
 END IF;
 IF p_reason IS NULL OR p_reason NOT IN ('owner_ko','owner_absent','owner_inoperative','combat_end','innata_off') THEN
   RAISE EXCEPTION 'common_terminal_reason_invalid' USING ERRCODE='22023'; END IF;
 SELECT * INTO STRICT a FROM public.combat_v2_actors WHERE id=p_actor;
 PERFORM 1 FROM public.combat_v2_sessions WHERE id=a.session_id FOR UPDATE;
 PERFORM 1 FROM combat_consumer_private.activities WHERE session_id=a.session_id FOR UPDATE;
 c:=clan_innata_private.combat_context(a.id);
 PERFORM 1 FROM public.combat_v2_actors WHERE id=p_actor FOR UPDATE;
 SELECT * INTO s FROM clan_innata_combat_private.combat_state WHERE session_id=a.session_id AND actor_id=a.id
   AND technique_id='001f907c-8f32-4758-8a16-ad1730e72c59' FOR UPDATE;
 IF s.active THEN
   UPDATE clan_innata_combat_private.combat_state SET active=false,state_version=state_version+1
    WHERE session_id=a.session_id AND actor_id=a.id AND technique_id=s.technique_id RETURNING * INTO s;
   changed:=true;
 END IF;
 FOR use_id IN SELECT id FROM clan_sabaku_private.transport_uses
  WHERE session_id=a.session_id AND actor_id=a.id AND state='active' ORDER BY id
 LOOP
   PERFORM clan_sabaku_private.transport_release(use_id,p_reason);
 END LOOP;
 IF EXISTS(SELECT 1 FROM clan_sabaku_private.armor_states WHERE actor_id=a.id AND active) THEN
   PERFORM clan_sabaku_private.armor_stop(a.id,p_reason,md5('armor-terminal-common:'||a.id::text||':'||coalesce(s.state_version,0)::text||':'||p_reason)::uuid);
 END IF;
 IF NOT changed THEN RETURN; END IF;
 test:=NOT public.combat_v2_values_written(a.session_id);
 key:=md5('common-terminal:'||a.session_id||':'||a.id||':'||s.state_version)::uuid;
 result:=jsonb_build_object('contract_version','common-combat-innata/1','receipt_id',receipt,
  'operation','deactivate','active',false,'state_version',s.state_version,'chakra_spent',0,
  'main_action_consumed',false,'is_test',test,'values_written',false,'replayed',false,
  'termination_reason',p_reason,'source','lifecycle');
 INSERT INTO clan_innata_combat_private.combat_receipts(receipt_id,session_id,round_id,actor_id,technique_id,
  operation,request_id,fingerprint,chakra_spent,is_test,result)
  VALUES(receipt,a.session_id,c.exchange_id,a.id,s.technique_id,'deactivate',key,
    public.combat_v2_sha256(jsonb_build_object('actor',a.id,'state_version',s.state_version,'reason',p_reason)),0,test,result);
END $function$;

CREATE OR REPLACE FUNCTION clan_innata_private.combat_terminal(p_actor uuid, p_technique uuid, p_reason text)
 RETURNS void
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO ''
AS $function$
DECLARE a public.combat_v2_actors%ROWTYPE; c clan_innata_combat_private.actor_context;
 s clan_innata_combat_private.combat_state%ROWTYPE; key uuid; receipt uuid:=gen_random_uuid(); result jsonb;
BEGIN
 IF p_technique='4056f62d-77f3-47f9-8ecb-9a7799682a9d'::uuid THEN p_technique:=clan_innata_narrative_private.sharingan_selected_v2(p_actor);END IF;
 IF p_technique='4a527ff2-0420-4da9-bc1f-5489c753b285'::uuid THEN
 SELECT st.technique_id INTO key FROM clan_innata_combat_private.combat_state st JOIN clan_innata_narrative_private.byakugan_catalog_v1 q ON q.technique_id=st.technique_id WHERE st.actor_id=p_actor AND st.active;
 IF key IS NOT NULL THEN p_technique:=key;END IF;END IF;
 IF p_technique='001f907c-8f32-4758-8a16-ad1730e72c59'::uuid THEN
  PERFORM clan_innata_private.combat_terminal(p_actor,p_reason); RETURN; END IF;
 IF (p_technique IS NULL OR p_technique NOT IN ('4a527ff2-0420-4da9-bc1f-5489c753b285'::uuid,'8e20bafe-cb3c-4967-b9c7-2a4bca694996'::uuid,'9b384de3-35f0-43c0-b145-94f985fa758a'::uuid,'a50808fa-e7cd-45ee-b4d4-33ad8c65d472'::uuid,'4056f62d-77f3-47f9-8ecb-9a7799682a9d'::uuid,'65b30dec-6f9f-459e-b78c-49173d74f251'::uuid,'f3673da7-42c9-497e-abe1-1c0982429f35'::uuid,'1ab6d359-f337-45ed-839c-4e626d2e2819'::uuid,'c11ecd52-43cd-479b-8d5d-08187beba56e'::uuid,'c9b261da-c9cd-40bb-8189-7b65ab5a1605'::uuid))
   OR p_reason IS NULL OR p_reason NOT IN ('owner_ko','owner_absent','owner_inoperative','combat_end','innata_off') THEN
  RAISE EXCEPTION 'common_terminal_request_invalid' USING ERRCODE='22023'; END IF;
 SELECT * INTO STRICT a FROM public.combat_v2_actors WHERE id=p_actor;
 PERFORM 1 FROM public.combat_v2_sessions WHERE id=a.session_id FOR UPDATE;
 PERFORM 1 FROM combat_consumer_private.activities WHERE session_id=a.session_id FOR UPDATE;
 c:=clan_innata_private.combat_context(a.id);
 PERFORM 1 FROM public.combat_v2_actors WHERE id=p_actor FOR UPDATE;
 SELECT * INTO s FROM clan_innata_combat_private.combat_state WHERE session_id=a.session_id AND actor_id=a.id
   AND technique_id=p_technique FOR UPDATE;
 IF NOT coalesce(s.active,false) THEN RETURN; END IF;
 UPDATE clan_innata_combat_private.combat_state SET active=false,state_version=state_version+1
  WHERE session_id=a.session_id AND actor_id=a.id AND technique_id=p_technique RETURNING * INTO s;
 key:=md5('common-terminal:'||a.session_id||':'||a.id||':'||p_technique||':'||s.state_version)::uuid;
 result:=jsonb_build_object('contract_version','common-combat-innata/1','receipt_id',receipt,
   'technique_id',p_technique,'operation','deactivate','active',false,'state_version',s.state_version,
   'chakra_spent',0,'main_action_consumed',false,'is_test',s.is_test,'values_written',false,
   'replayed',false,'termination_reason',p_reason,'source','lifecycle');
 INSERT INTO clan_innata_combat_private.combat_receipts(receipt_id,session_id,round_id,actor_id,technique_id,
   operation,request_id,fingerprint,chakra_spent,is_test,result)
 VALUES(receipt,a.session_id,c.exchange_id,a.id,p_technique,'deactivate',key,
   public.combat_v2_sha256(jsonb_build_object('actor',a.id,'technique_id',p_technique,
     'state_version',s.state_version,'reason',p_reason)),0,s.is_test,result);
END $function$;

CREATE OR REPLACE FUNCTION public.combat_v2_actor_ability(p_actor uuid, p_source text, p_ability uuid, p_defense boolean DEFAULT false)
 RETURNS jsonb
 LANGUAGE sql
 STABLE SECURITY DEFINER
 SET search_path TO ''
AS $function$
 SELECT CASE WHEN p_source='clan' AND p_ability='c9b261da-c9cd-40bb-8189-7b65ab5a1605'::uuid THEN NULL::jsonb WHEN p_source='clan'AND p_ability='0a15282f-d6b5-4ee3-ad52-7fac2525444d'::uuid THEN NULL::jsonb WHEN p_source='clan' AND p_ability='f5f26cb5-9b6f-44b3-94bc-c329a0a88b93'::uuid THEN NULL::jsonb
 WHEN p_source='clan' AND p_ability='687b058a-807d-4cf7-8bcf-21147931b0f6'::uuid THEN CASE WHEN p_defense THEN clan_akimichi_private.cellular_meta_v1(p_actor) ELSE NULL::jsonb END
 WHEN p_source='clan' AND p_ability='c47814d2-ef27-4967-87ad-da633b0f4d78'::uuid THEN NULL::jsonb
 WHEN p_source='clan' AND p_ability='31d5d554-44d1-4042-9920-3ddd3bedff7e'::uuid THEN CASE WHEN p_defense THEN NULL::jsonb ELSE combat_v2_genjutsu_internal.actor_meta(p_actor) END
 WHEN p_source='clan' AND p_ability='127f3854-4183-4354-a654-f59320d8807e' AND clan_hoki_private.routes_ability(p_actor,p_ability) THEN clan_hoki_private.needle_ability(p_actor,p_defense)
 WHEN p_source='clan' AND p_ability='c8d32b00-3917-41a6-8906-388e7b9efcc7' AND clan_hoki_private.routes_ability(p_actor,p_ability) THEN NULL
 WHEN p_source='clan' AND p_ability='3b4c4fd0-c0c2-46a0-a387-f47a95ef7dda'::uuid AND clan_akimichi_private.replacement_applies(p_actor) THEN NULL::jsonb
 WHEN p_source='clan' AND p_ability='214af896-15f8-43e6-858b-614d2851dd3b'::uuid AND clan_akimichi_private.replacement_applies(p_actor) THEN
  CASE WHEN p_defense IS FALSE THEN (
   SELECT clan_akimichi_private.partial_meta(p_actor, a.value)
   FROM public.combat_v2_actors x
   CROSS JOIN LATERAL jsonb_array_elements(coalesce(x.mechanics_snapshot->'abilities','[]'::jsonb)) a(value)
   WHERE x.id=p_actor AND a.value->>'source'='clan' AND a.value->>'id'=p_ability::text
   LIMIT 1
  ) ELSE NULL::jsonb END
 WHEN p_source='clan' AND p_ability='db51e5ae-8b90-4c3a-a51d-962eb9e19b38'::uuid
   AND combat_panel_private.nara_routes_possession_v1(p_actor)
 THEN combat_panel_private.nara_offer_meta_v1(p_actor,p_defense)
 WHEN p_source='clan'AND p_ability='6cc40917-1719-4759-9ba8-3064b806c24e'::uuid
 AND EXISTS(SELECT 1 FROM public.combat_v2_actors a WHERE a.id=p_actor AND a.mechanics_snapshot ? 'fenice_staff_dependency')THEN
 (SELECT proof->'ability'FROM public.combat_v2_actors a
 CROSS JOIN LATERAL(SELECT clan_innata_narrative_private.fenice_staff_proof_v1(a.id)proof)q
 WHERE a.id=p_actor AND p_defense IS FALSE AND proof IS NOT NULL AND proof=a.mechanics_snapshot->'fenice_staff_dependency'
 AND(SELECT count(*)FROM jsonb_array_elements(a.mechanics_snapshot->'abilities')x WHERE x=proof->'ability')=1)
 ELSE(SELECT CASE WHEN p_source='clan' AND p_ability='58a2f5cd-6409-40f6-8f18-cfdb4410ca26'::uuid THEN
 CASE WHEN p_defense THEN clan_hyuga_private.rotation_ability_meta(p_actor) ELSE NULL END
 ELSE clan_aburame_private.actor_ability(p_actor,p_source,p_ability,p_defense,(select combat_v2_elemental_internal.scudo_ability_meta(p_actor,combat_v2_elemental_internal.other_ability_meta(p_actor,combat_v2_elemental_internal.suiton_ability_meta(p_actor,clan_uchiha_private.fireball_ability_meta(p_actor,clan_hyuga_private.sedici_ability_meta(p_actor,a.value)))))
  from public.combat_v2_actors x
  cross join lateral jsonb_array_elements(coalesce(x.mechanics_snapshot->'abilities','[]'::jsonb)) a(value)
  where x.id=p_actor and a.value->>'source'=p_source and (a.value->>'id')::uuid=p_ability
    and (not p_defense or coalesce((a.value->>'defensive')::boolean,false))
    and CASE WHEN p_source='clan' AND p_ability IN (
          '1260dbc8-ab0c-4b2b-9b94-909d39b7ffbe'::uuid,'5bf9764e-b719-4972-9d75-083b4cb633e7'::uuid)
        THEN clan_uchiha_private.fireball_ability_meta(p_actor,a.value) IS NOT NULL
        ELSE (not combat_v2_elemental_internal.is_target_v1(p_ability)
         or combat_v2_elemental_internal.eligible_v1(x.character_id,p_ability,p_defense)
         or (p_defense AND p_source='clan' AND p_ability='9061c022-ca82-4d2b-8102-e208fcc6c1a2'::uuid AND combat_v2_elemental_internal.scudo_profile(p_actor) IS NOT NULL)
         or (NOT p_defense AND p_source='clan' AND coalesce(combat_v2_elemental_internal.suiton_profile(p_actor,p_ability),combat_v2_elemental_internal.other_profile(p_actor,p_ability)) IS NOT NULL)) END
    and clan_hyuga_private.sedici_ability_meta(p_actor,a.value) IS NOT NULL
    and clan_uchiha_private.fireball_ability_meta(p_actor,a.value) IS NOT NULL
  limit 1)) END)END
$function$;

CREATE OR REPLACE FUNCTION public.combat_v2_character_snapshot(p_character uuid)
 RETURNS jsonb
 LANGUAGE plpgsql
 STABLE SECURITY DEFINER
 SET search_path TO ''
AS $function$
declare v_out jsonb;
begin
  select jsonb_build_object(
    'name',c.name,'vita',c.vita,'vita_max',c.vita_max,'chakra',c.chakra,'chakra_max',c.chakra_max,
    'taijutsu',c.taijutsu,'ninjutsu',c.ninjutsu,'kekkei_genkai',c.kekkei_genkai,'genjutsu',c.genjutsu,'forza',c.forza,
    'velocita',c.velocita,'mente',c.mente,'resistenza',c.resistenza,'fuuinjutsu',c.fuuinjutsu,'slancio',0,
    'abilities',coalesce((select jsonb_agg(x order by x->>'name') from (
      select jsonb_strip_nulls(jsonb_build_object('source','clan','id',t.id,'name',t.name,'kind',coalesce(t.category,'fisico'),
        'usage',t.uso,'defensive',coalesce(t.difensiva,false),'di_scena',coalesce(t.di_scena,false),'diversivo',false,'consumption_type',coalesce(t.consumption_type,'ad_utilizzo'),'range',t.gittata,'chakra_cost',coalesce(t.chakra_cost,0),
        'damage_base',coalesce(t.danno_base,0),'element',case when cardinality(t.req_elements)>0 then t.req_elements[1] end,
        'element_requirements',case when combat_v2_elemental_internal.is_target_v1(t.id) then to_jsonb(t.req_elements) end,
        'element_mode',case when combat_v2_elemental_internal.is_target_v1(t.id) then t.req_elements_mode end,
        'element_authority',case when combat_v2_elemental_internal.is_target_v1(t.id) then 'character_elementi/1' end,
        'targeting_mode',case when combat_v2_elemental_internal.is_target_v1(t.id) then case when t.difensiva then 'self_defense' else 'single_enemy' end end)) x
      from public.character_abilities ca join public.clan_techniques t on t.id=ca.technique_id
      where ca.character_id=c.id and ca.state='attiva' and t.is_active
        and t.id<>'c9b261da-c9cd-40bb-8189-7b65ab5a1605'::uuid
        and (not combat_v2_elemental_internal.is_target_v1(t.id) or combat_v2_elemental_internal.eligible_v1(c.id,t.id,null))
      union all
      select jsonb_build_object('source','jutsu','id',j.id,'name',j.name_it,'kind',coalesce(j.category,'fisico'),
        'usage',j.uso,'defensive',coalesce(j.difensiva,false),'di_scena',coalesce(j.di_scena,false),'diversivo',coalesce(j.diversivo,false),'consumption_type','ad_utilizzo','range',j.gittata,'chakra_cost',coalesce(j.chakra_cost,0),
        'damage_base',coalesce(j.damage_base,0),'element',j.nature) x
      from public.character_jutsu cj join public.jutsu j on j.id=cj.jutsu_id
      where cj.user_id=c.user_id and j.is_active
    ) q),'[]'::jsonb)
  ) into v_out from public.characters c where c.id=p_character;
  v_out:=jsonb_set(v_out,'{abilities}',combat_v2_multitarget_internal.enrich_abilities_v1(v_out->'abilities'),false);
  return v_out;
end $function$;

CREATE OR REPLACE FUNCTION public.test_room_user_techniques()
 RETURNS jsonb
 LANGUAGE sql
 STABLE SECURITY DEFINER
 SET search_path TO 'public'
AS $function$
with me as (
  select id, user_id from public.characters where user_id=auth.uid() limit 1
), choices as (
  select 'clan'::text source, t.id technique_id, t.name,
         coalesce(t.disciplina,t.category,'Ninjutsu') discipline,
         coalesce(t.chakra_cost,0) chakra_cost,
         coalesce(t.danno_base,0) damage_base,
         coalesce(t.gittata,t.portata,'media') range,
         coalesce(t.attivazione,'istantanea') activation,
         coalesce(t.uso,'principale') usage
  from me join public.character_abilities ca on ca.character_id=me.id and ca.state='attiva'
  join public.clan_techniques t on t.id=ca.technique_id and t.is_active
  where not t.difensiva and not t.di_scena and t.id<>'c9b261da-c9cd-40bb-8189-7b65ab5a1605'::uuid
    and coalesce(t.uso,'principale') in ('principale','rapida')
    and coalesce(t.consumption_type,'ad_utilizzo') <> 'passiva'
  union all
  select 'jutsu', j.id, j.name_it,
         coalesce(j.atk_discipline,j.category,'Ninjutsu'),
         coalesce(j.chakra_cost,0), coalesce(j.damage_base,0),
         coalesce(j.gittata,'corta'),
         case when j.kind='abilita' then 'istantanea' else 'sigilli' end,
         coalesce(j.uso,'principale')
  from me join public.character_jutsu cj on cj.user_id=me.user_id
  join public.jutsu j on j.id=cj.jutsu_id and j.is_active
  where not j.difensiva and not j.di_scena and j.id<>'c6e31b7b-38fe-4b4f-b3c7-05f3e922d193'::uuid and j.kind <> 'abilita'
    and coalesce(j.uso,'principale') in ('principale','rapida')
)
select coalesce(jsonb_agg(to_jsonb(choices) order by name),'[]'::jsonb) from choices;
$function$;

CREATE OR REPLACE FUNCTION combat_panel_private.master_actor_offers(p_context uuid, p_expected bigint, p_view jsonb, p_source jsonb)
 RETURNS void
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO ''
AS $function$
DECLARE c combat_panel_private.contexts%ROWTYPE; a public.combat_v2_actors%ROWTYPE;
 link_targets jsonb; cut_candidates jsonb; cut_cache jsonb:='{}'::jsonb;
 cut_range numeric; cut_group uuid; cut_offer uuid;
 defense_target_id uuid; figure_geometry jsonb; target_choice uuid; meta jsonb; item jsonb; pending jsonb; moves jsonb; one jsonb; target record;
 oid uuid; gid uuid; directions uuid; direction_id uuid; target_id uuid; movement_group uuid;
 cap integer; minimum integer; n integer; chakra numeric; cost numeric; ability_range numeric; target_center_range numeric; endpoint_arena record; endpoint_target record; endpoint_budget numeric; endpoint_options jsonb; can_stay boolean;
 diag_targets_total integer:=0;diag_targets_seen integer:=0;diag_mano_seen integer:=0;diag_geometry_stay integer:=0;diag_endpoint_count integer:=0;diag_pending_count integer:=0;diag_rejected_geometry integer:=0;diag_label_present integer:=0;diag_legal_total integer:=0;diag_action_entered integer:=0; mode text; reaction text; label text; dir text; payload jsonb; legal jsonb; endpoint_cache jsonb:='{}'::jsonb;
BEGIN
 PERFORM set_config('tus.native_attack_producer_called','true',true);
 PERFORM set_config('tus.native_attack_producer_diag',jsonb_build_object('targets_total',0,'targets_seen',0,'mano_seen',0,'geometry_stay',0,'endpoint_count',0,'pending_count',0,'rejected_geometry',0,'label_present',0,'legal_total',0,'action_entered',0)::text,true);
 c:=combat_panel_private.owned_context(p_context,p_expected);
 IF c.activity_kind<>'master_v2' OR c.command_actor_id IS NULL OR c.round_id IS NULL THEN RETURN; END IF;
 SELECT * INTO STRICT a FROM public.combat_v2_actors WHERE id=c.command_actor_id AND session_id=c.activity_id
   AND exam_regia_private.actor_principal(id,controller_user)=exam_regia_private.current_principal() AND companion_id IS NULL;
 IF a.state<>'attivo' THEN RETURN; END IF;
 IF p_view#>>'{viewer,command_actor_id}' IS DISTINCT FROM a.id::text
   OR p_source->>'actor' IS DISTINCT FROM a.id::text OR p_source->>'round' IS DISTINCT FROM c.round_id::text THEN
   RAISE EXCEPTION 'panel_master_source_scope_invalid' USING ERRCODE='22023'; END IF;
 IF NOT combat_panel_private.has_master_geometry(a.session_id) THEN RETURN; END IF;
 SELECT greatest(0,coalesce((a.mechanics_snapshot->>'chakra')::numeric,0)-coalesce(sum(clan_hyuga_private.sedici_frozen_cost(d.actor_id,d.cost_snapshot)),0))
   INTO chakra FROM public.combat_v2_declarations d WHERE d.round_id=c.round_id AND d.actor_id=a.id
     AND d.state NOT IN ('superflua','risolta');
 IF p_view#>>'{context,phase}'='action' AND combat_panel_private.human_duel_turn_allowed(c.round_id,a.id) AND NOT EXISTS(SELECT 1 FROM public.combat_v2_declarations
   WHERE round_id=c.round_id AND actor_id=a.id AND kind IN ('attacco','movimento','utilita','passa')) THEN
   -- Un solo catalogo di spostamenti server-issued alimenta sia Movimento sia
   -- l'avvicinamento atomico del colpo a mano, anche per i PNG di Regia.
   diag_action_entered:=1;diag_targets_total:=jsonb_array_length(coalesce(p_source->'targets','[]'::jsonb));
   moves:=combat_panel_private.master_movement_options(c.round_id,a.id);
   -- Restrict consideration to connected companions already shown to this PG.
   SELECT coalesce(jsonb_agg(viewer.actor ORDER BY b.id),'[]'::jsonb) INTO link_targets
   FROM jsonb_array_elements(p_view->'actors') AS viewer(actor)
   JOIN public.combat_v2_actors b ON b.id=(viewer.actor->>'actor_id')::uuid
      AND b.session_id=a.session_id AND b.team_key<>a.team_key AND b.state='attivo'
   JOIN clan_marionettisti_private.links link ON link.companion_actor_id=b.id AND link.state='connected'
   WHERE a.actor_kind='pg' AND a.controller_user=auth.uid()
     AND nullif(btrim(viewer.actor->>'display_name'),'') IS NOT NULL;
   FOR meta IN SELECT value FROM jsonb_array_elements(jsonb_build_array(jsonb_build_object(
     'source','mano','name','Colpo a mano','kind','fisico','chakra_cost',0,'damage_base',10))||(SELECT coalesce(jsonb_agg(x.value ORDER BY x.ordinality),'[]'::jsonb)
       FROM jsonb_array_elements(coalesce(p_source->'abilities','[]'::jsonb)) WITH ORDINALITY x(value,ordinality)
       WHERE CASE WHEN x.value->>'source'='clan'
       AND x.value->>'id' IN ('127f3854-4183-4354-a654-f59320d8807e','c8d32b00-3917-41a6-8906-388e7b9efcc7')
       THEN NOT clan_hoki_private.routes_ability(a.id,(x.value->>'id')::uuid) ELSE true END)
      ||CASE WHEN clan_hoki_private.needle_ability(a.id,false) IS NULL THEN '[]'::jsonb
         ELSE jsonb_build_array(clan_hoki_private.needle_ability(a.id,false)) END
      ||coalesce((SELECT jsonb_agg(x.profile) FROM (SELECT combat_panel_private.shuriken_available_v1(a.id) AS profile) x
        WHERE x.profile IS NOT NULL),'[]'::jsonb)) LOOP
     IF meta->>'source'='mano' THEN diag_mano_seen:=diag_mano_seen+1;END IF;
     IF meta->>'source'='clan' AND meta->>'id'='c9b261da-c9cd-40bb-8189-7b65ab5a1605' THEN CONTINUE; END IF;
     -- Super is a form control, never a generic main attack.
     IF meta->>'source'='clan' AND meta->>'id'='f5f26cb5-9b6f-44b3-94bc-c329a0a88b93' THEN CONTINUE;END IF;
     IF meta->>'source'='clan' AND meta->>'id'='3b4c4fd0-c0c2-46a0-a387-f47a95ef7dda' AND clan_akimichi_private.replacement_applies(a.id) THEN CONTINUE; END IF;
     IF meta->>'source'='clan' AND meta->>'id'='214af896-15f8-43e6-858b-614d2851dd3b' AND clan_akimichi_private.replacement_applies(a.id) THEN
       meta:=clan_akimichi_private.partial_meta(a.id,meta);
       IF meta IS NULL THEN CONTINUE; END IF;
     END IF;
     IF meta->>'id' IN ('1260dbc8-ab0c-4b2b-9b94-909d39b7ffbe','5bf9764e-b719-4972-9d75-083b4cb633e7') THEN CONTINUE;END IF;
     IF meta->>'source'='clan' AND meta->>'id'='617484d6-af7b-41c3-a37f-615b22818421' THEN CONTINUE; END IF;
     IF meta->>'source'='clan' AND meta->>'id'='c11ecd52-43cd-479b-8d5d-08187beba56e' THEN CONTINUE; END IF;
     -- ACTION-FLOW-DB-001: Sharingan is an innate control, never a generic attack.
     IF meta->>'source'='clan' AND meta->>'id'='4056f62d-77f3-47f9-8ecb-9a7799682a9d' THEN CONTINUE; END IF;
     IF meta->>'source'='clan' AND meta->>'id'='db51e5ae-8b90-4c3a-a51d-962eb9e19b38'
       AND combat_panel_private.nara_routes_possession_v1(a.id) THEN
       meta:=combat_panel_private.nara_offer_meta_v1(a.id,false);
       IF meta IS NULL THEN CONTINUE; END IF;
     END IF;
     meta:=clan_hyuga_private.sedici_ability_meta(a.id,meta); IF meta IS NULL THEN CONTINUE; END IF; IF meta->>'source'='clan' AND meta->>'id'='b076a976-c75b-4b5a-8813-b0e8e2c3af03' AND clan_inuzuka_private.zanna_profile(a.id) IS NULL THEN CONTINUE; END IF;
     cost:=(clan_hyuga_private.sedici_cost_quote(a.id,coalesce((meta->>'chakra_cost')::integer,0))->>'total')::integer;
     IF cost>chakra THEN CONTINUE; END IF;
     IF meta->>'source'<>'mano' AND (coalesce(meta->>'usage','') NOT IN ('principale','rapida')
       OR coalesce((meta->>'defensive')::boolean,false) OR coalesce((meta->>'di_scena')::boolean,false)
       OR (meta->>'source'='jutsu' AND meta->>'id'='c6e31b7b-38fe-4b4f-b3c7-05f3e922d193')
       OR coalesce((meta->>'diversivo')::boolean,false) OR coalesce(meta->>'consumption_type','ad_utilizzo')='passiva') THEN CONTINUE; END IF;
     -- Eleggibilità Fili e resolver speciali restano autorità del dominio.
     BEGIN
       PERFORM clan_marionettisti_private.assert_jutsu_source(a.id,meta->>'source',(meta->>'id')::uuid);
     EXCEPTION WHEN SQLSTATE '22023' THEN
       IF SQLERRM='fili_other_jutsu_unavailable' THEN CONTINUE; ELSE RAISE; END IF;
     END;
     ability_range:=CASE WHEN meta ? 'nara_range_m' THEN (meta->>'nara_range_m')::numeric WHEN meta->>'hoki_needle_version'='hoki-needle/1' THEN 15 WHEN meta->>'akimichi_partial_contract'='akimichi-partial/1' THEN 3 WHEN meta->>'source'='clan' AND meta->>'id'='e361f7c3-f90b-47ec-bfee-ccbda21257d9' THEN 3 WHEN meta->>'source'='clan' AND meta->>'id'='b076a976-c75b-4b5a-8813-b0e8e2c3af03' THEN 2 WHEN meta->>'source'='arma' THEN (meta->>'range_m')::numeric WHEN meta->>'source'='mano' THEN 2 ELSE public._fascia_metri(meta->>'range') END;
     IF jsonb_array_length(link_targets)>0 THEN
       cut_range:=clan_marionettisti_private.ocular_sever_attack_range_v1(
         a.id,meta->>'source',(meta->>'id')::uuid,meta);
       IF cut_range IS NOT NULL THEN
         cut_candidates:=cut_cache->(cut_range::text);
         IF cut_candidates IS NULL THEN
           SELECT coalesce(jsonb_agg(candidate.actor ORDER BY candidate.ordinality),'[]'::jsonb)
             INTO cut_candidates
           FROM jsonb_array_elements(link_targets) WITH ORDINALITY AS candidate(actor,ordinality)
           WHERE clan_marionettisti_private.ocular_sever_source_v1(
             c.round_id,a.id,(candidate.actor->>'actor_id')::uuid,cut_range) IS NOT NULL;
           cut_cache:=jsonb_set(cut_cache,ARRAY[cut_range::text],cut_candidates,true);
         END IF;
         IF jsonb_array_length(cut_candidates)>0 THEN
           cut_offer:=combat_panel_private.create_offer(c.id,c.context_version,'action','declare',
             (meta->>'name')||' · Recidi i Fili'||CASE WHEN cost>0 THEN ' · '||cost::text||' chakra' ELSE '' END,
             true,jsonb_build_object('adapter','master_v2','dispatch','action','kind','attacco',
               'ability_source',meta->'source','ability_id',meta->'id','target_fili',true));
           cut_group:=combat_panel_private.add_group(cut_offer,'Fili da recidere','target','single',1,1);
           FOR item IN SELECT value FROM jsonb_array_elements(cut_candidates) LOOP
             PERFORM combat_panel_private.add_choice(
               cut_group,item->>'display_name',jsonb_build_object('target_actor_id',item->'actor_id'));
           END LOOP;
         END IF;
       END IF;
     END IF;
     legal:='[]';
     FOR item IN SELECT value FROM jsonb_array_elements(p_source->'targets') LOOP
       diag_targets_seen:=diag_targets_seen+1;target_id:=(item->>'id')::uuid;
       IF meta->>'hoki_needle_version'='hoki-needle/1'
          AND NOT clan_hoki_private.needle_target_valid(a.id,target_id) THEN CONTINUE; END IF;
       IF meta->>'source'='clan' AND meta->>'id'='9ac77d79-9894-5388-9753-70538ac5eaa3' AND EXISTS(SELECT 1 FROM combat_panel_private.multiplication_formations WHERE actor_id=target_id AND state='active') THEN CONTINUE;END IF;
       target_center_range:=CASE WHEN meta->>'source'='clan' AND meta->>'id'='72cbe1fb-34c8-44c7-a053-0014b4894b3e' THEN combat_v2_elemental_internal.scarica_contact_range(a.id,target_id) WHEN meta->>'source'='mano' THEN combat_panel_private.manual_contact_center_range(a.id,target_id) ELSE ability_range END;
       figure_geometry:=NULL; pending:='[]'::jsonb;can_stay:=false;
       IF meta ? 'nara_range_m' THEN
         IF combat_panel_private.nara_offer_meta_v1(a.id,false,target_id) IS NULL THEN CONTINUE; END IF;
         can_stay:=true;
       ELSIF meta->>'source'='arma' THEN
         IF NOT combat_panel_private.shuriken_target_v1(a.id,target_id) THEN CONTINUE; END IF;
         can_stay:=true;
       ELSIF EXISTS(SELECT 1 FROM combat_panel_private.multiplication_formations WHERE actor_id=target_id AND state='active') THEN
         IF NOT EXISTS(SELECT 1 FROM combat_panel_private.multiplication_formations f WHERE f.actor_id=target_id AND f.state='active' AND f.mode='assalto') THEN CONTINUE; END IF;
         IF meta->>'source'='clan' AND meta->>'id'='e361f7c3-f90b-47ec-bfee-ccbda21257d9' THEN
          BEGIN
           figure_geometry:=combat_panel_private.multiplication_companion_target_geometry(c.round_id,a.id,target_id);
          EXCEPTION WHEN SQLSTATE 'P0002' THEN CONTINUE;
           WHEN SQLSTATE '22023' THEN
            IF SQLERRM IN ('marionetta_actor_target_invalid','marionetta_link_unavailable',
             'marionetta_module_unavailable','marionetta_attack_out_of_range') THEN CONTINUE; ELSE RAISE; END IF;
          END;
         ELSE figure_geometry:=combat_panel_private.multiplication_target_geometry(a.id,target_id); END IF;
         IF figure_geometry IS NULL OR NOT EXISTS(SELECT 1 FROM jsonb_array_elements(figure_geometry->'figures')
           WHERE (value->>'distance_m')::numeric<=target_center_range AND (value->>'path_clear')::boolean) THEN CONTINUE; END IF;
       ELSIF meta->>'source'='clan' AND meta->>'id'='e361f7c3-f90b-47ec-bfee-ccbda21257d9' THEN
       BEGIN
         PERFORM clan_marionettisti_private.attack_source(c.round_id,a.id,target_id);
       EXCEPTION WHEN SQLSTATE 'P0002' THEN CONTINUE;
         WHEN SQLSTATE '22023' THEN
           IF SQLERRM IN ('marionetta_actor_target_invalid','marionetta_link_unavailable',
             'marionetta_module_unavailable','marionetta_attack_out_of_range') THEN CONTINUE; ELSE RAISE; END IF;
       END;
     ELSIF (meta->>'source'='mano' OR (meta->>'source'='clan' AND meta->>'id' IN ('9ac77d79-9894-5388-9753-70538ac5eaa3','b076a976-c75b-4b5a-8813-b0e8e2c3af03'))) THEN
       can_stay:=combat_panel_private.target_geometry_valid(a.id,target_id,target_center_range);IF can_stay THEN diag_geometry_stay:=diag_geometry_stay+1;END IF; /* INUZUKA-HOTFIX016-ZANNA-CONTACT-BEGIN */ IF meta->>'source'='clan' AND meta->>'id'='b076a976-c75b-4b5a-8813-b0e8e2c3af03' AND can_stay THEN endpoint_options:='[]'::jsonb; ELSE
       SELECT * INTO STRICT endpoint_arena FROM combat_spatial.arena_instances
         WHERE encounter_id=a.session_id AND context_source='panel_master' AND state='open';
       SELECT * INTO STRICT endpoint_target FROM combat_spatial.actor_states
         WHERE instance_id=endpoint_arena.instance_id AND actor_id=target_id AND state='active';
       endpoint_budget:=(combat_panel_private.master_movement_budget(c.round_id,a.id)->>'remaining_m')::numeric;
       IF meta->>'source'='clan' AND meta->>'id'='9ac77d79-9894-5388-9753-70538ac5eaa3' AND endpoint_cache ? target_id::text THEN
         endpoint_options:=endpoint_cache->target_id::text;
       ELSE
         endpoint_options:=combat_panel_private.melee_integer_endpoint_capabilities(
           endpoint_arena.instance_id,a.id,target_id,endpoint_target.x_m,endpoint_target.y_m,
           endpoint_target.footprint_radius_m,endpoint_budget,CASE WHEN meta->>'source'='mano' THEN 'master-mano:' ELSE 'master-taijutsu-entry:' END||c.round_id||':'||a.id);
         IF meta->>'source'='mano' THEN endpoint_cache:=jsonb_set(endpoint_cache,ARRAY[target_id::text],endpoint_options,true); END IF; /* INUZUKA-HOTFIX016-ZANNA-CONTACT-END */END IF;
       END IF;
       diag_endpoint_count:=diag_endpoint_count+jsonb_array_length(endpoint_options);
       SELECT coalesce(jsonb_agg(jsonb_build_object('capability_id',ec.capability_id,
         'distance_m',combat_spatial.distance_m(ec.start_x_m,ec.start_y_m,ec.end_x_m,ec.end_y_m),
         'target_distance_m',value->'target_distance_m','direction','endpoint')
         ORDER BY (value->>'target_distance_m')::numeric,ec.end_x_m,ec.end_y_m),'[]'::jsonb) INTO pending
       FROM jsonb_array_elements(endpoint_options)
       JOIN combat_spatial.movement_capabilities ec ON ec.capability_id=(value->>'movement_capability_id')::uuid
       WHERE combat_panel_private.movement_attack_target_valid(a.id,target_id,ec.capability_id,target_center_range)
         AND (meta->>'source'='mano' OR meta->>'id'='b076a976-c75b-4b5a-8813-b0e8e2c3af03' OR combat_spatial.distance_m(ec.start_x_m,ec.start_y_m,ec.end_x_m,ec.end_y_m)>=5);
       IF meta->>'source'='clan' AND meta->>'id'='9ac77d79-9894-5388-9753-70538ac5eaa3' THEN can_stay:=false;END IF;
       diag_pending_count:=diag_pending_count+jsonb_array_length(pending);
       IF NOT can_stay AND jsonb_array_length(pending)=0 THEN diag_rejected_geometry:=diag_rejected_geometry+1;CONTINUE; END IF;
     ELSIF NOT combat_panel_private.target_geometry_valid(a.id,target_id,target_center_range) THEN CONTINUE;
     END IF;
       SELECT value->>'display_name' INTO label FROM jsonb_array_elements(p_view->'actors') WHERE value->>'actor_id'=target_id::text;
       IF label IS NOT NULL THEN diag_label_present:=diag_label_present+1;legal:=legal||jsonb_build_array(jsonb_build_object('target_actor_id',target_id,'label',label,'figure_geometry',figure_geometry,'movement_options',pending,'center_range_m',target_center_range,'manual_can_stay',can_stay)); END IF;
     END LOOP;
     diag_legal_total:=diag_legal_total+jsonb_array_length(legal);
     IF jsonb_array_length(legal)=0 THEN CONTINUE; END IF;
     cap:=1;
     FOR n IN 2..(CASE WHEN meta->>'source'='arma' OR meta ? 'nara_range_m' OR (meta->>'source'='clan' AND meta->>'id'='e361f7c3-f90b-47ec-bfee-ccbda21257d9')
       THEN 1 ELSE least(3,jsonb_array_length(legal)) END) LOOP
       IF coalesce(combat_v2_multitarget_internal.attack_profile_ok(meta,n),false) THEN cap:=n; END IF;
     END LOOP;
     payload:=jsonb_build_object('adapter','master_v2','dispatch','action','kind','attacco','ability_source',meta->'source');
     IF meta->>'source'<>'mano' THEN payload:=payload||jsonb_build_object('ability_id',meta->'id'); END IF;
     oid:=combat_panel_private.create_offer(c.id,c.context_version,'action','declare',(meta->>'name')||CASE WHEN cost>0 THEN ' · '||cost::text||' chakra' ELSE '' END,true,payload);
     gid:=combat_panel_private.add_group(oid,'Bersaglio','target',CASE WHEN cap>1 THEN 'multiple' ELSE 'single' END,1,cap);
     FOR item IN SELECT value FROM jsonb_array_elements(legal) LOOP
       target_choice:=combat_panel_private.add_choice(gid,item->>'label',jsonb_build_object('target_actor_id',item->'target_actor_id'));
       IF jsonb_typeof(item->'figure_geometry')='object' THEN
         PERFORM combat_panel_private.multiplication_add_attack_figures(oid,target_choice,item->'figure_geometry',(item->>'center_range_m')::numeric,item->>'label');
       END IF;
       IF (meta->>'source'='mano' OR (meta->>'source'='clan' AND meta->>'id' IN ('9ac77d79-9894-5388-9753-70538ac5eaa3','b076a976-c75b-4b5a-8813-b0e8e2c3af03'))) AND jsonb_array_length(coalesce(item->'movement_options','[]'::jsonb))>0 THEN
         movement_group:=combat_panel_private.add_group(oid,'Punto di arrivo','movement_distance','single',1,1,target_choice);
         IF item->'manual_can_stay'='true'::jsonb THEN
          PERFORM combat_panel_private.add_choice(movement_group,'Colpisci senza spostarti','{}'::jsonb);
         END IF;
         FOR one IN SELECT value FROM jsonb_array_elements(item->'movement_options') LOOP
           dir:=one->>'direction';
           label:=CASE dir WHEN 'up' THEN '↑ Su' WHEN 'right' THEN '→ Destra' WHEN 'down' THEN '↓ Giù' WHEN 'left' THEN '← Sinistra'
             WHEN 'up_right' THEN '↗ Alto a destra' WHEN 'down_right' THEN '↘ Basso a destra'
             WHEN 'down_left' THEN '↙ Basso a sinistra' WHEN 'up_left' THEN '↖ Alto a sinistra' ELSE 'Spostamento' END;
           PERFORM combat_panel_private.add_choice(movement_group,CASE WHEN one->>'direction'='endpoint' THEN 'Termina a '||(one->>'target_distance_m')||' m · spostamento '||round((one->>'distance_m')::numeric,2)||' m' ELSE label||' · '||((one->>'distance_m')::numeric::integer)::text||' m' END,
             jsonb_build_object('movement_capability_id',one->'capability_id'),(one->>'distance_m')::numeric,CASE WHEN dir='endpoint' THEN NULL ELSE dir END);
         END LOOP;
       END IF;
     END LOOP;
   END LOOP;
   PERFORM clan_uchiha_private.fireball_master_offers(c.id,c.context_version,p_view);
   IF jsonb_array_length(moves)>0 THEN
     oid:=combat_panel_private.create_offer(c.id,c.context_version,'action','declare','Movimento',true,
       jsonb_build_object('adapter','master_v2','dispatch','movement','kind','movimento'));
     directions:=combat_panel_private.add_group(oid,'Direzione','movement_direction','single',1,1);
     FOREACH dir IN ARRAY ARRAY['up','up_right','right','down_right','down','down_left','left','up_left'] LOOP
       IF NOT EXISTS(SELECT 1 FROM jsonb_array_elements(moves) WHERE value->>'direction'=dir) THEN CONTINUE; END IF;
       direction_id:=combat_panel_private.add_choice(directions,CASE dir WHEN 'up' THEN 'Su' WHEN 'right' THEN 'Destra' WHEN 'down' THEN 'Giù' WHEN 'left' THEN 'Sinistra'
    WHEN 'up_right' THEN 'Alto a destra' WHEN 'down_right' THEN 'Basso a destra'
    WHEN 'down_left' THEN 'Basso a sinistra' WHEN 'up_left' THEN 'Alto a sinistra' END,
         jsonb_build_object('direction',dir),NULL,dir);
       gid:=combat_panel_private.add_group(oid,'Distanza','movement_distance','single',1,1,direction_id);
       FOR item IN SELECT DISTINCT ON ((value->>'distance_m')::numeric) value FROM jsonb_array_elements(moves)
         WHERE value->>'direction'=dir ORDER BY (value->>'distance_m')::numeric,value->>'capability_id' LOOP
         PERFORM combat_panel_private.add_choice(gid,(item->>'distance_m')::numeric::integer::text||' m',jsonb_build_object('movement_capability_id',item->'capability_id'),
           (item->>'distance_m')::numeric,dir);
       END LOOP;
     END LOOP;
   END IF;
   PERFORM combat_panel_private.create_offer(c.id,c.context_version,'action','declare','Azione non offensiva',true,
     jsonb_build_object('adapter','master_v2','dispatch','action','kind','utilita'));
   PERFORM combat_panel_private.create_offer(c.id,c.context_version,'action','declare','Passa',false,
     jsonb_build_object('adapter','master_v2','dispatch','action','kind','passa'));
 ELSIF p_view#>>'{context,phase}'='defense' AND NOT EXISTS(SELECT 1 FROM public.combat_v2_declarations
   WHERE round_id=c.round_id AND actor_id=a.id AND kind IN ('difesa','nessuna')) THEN
   FOR meta IN SELECT value FROM jsonb_array_elements(jsonb_build_array(
     jsonb_build_object('reaction','schivata','name','Schivata'),jsonb_build_object('reaction','parata','name','Parata'),
     jsonb_build_object('reaction','nessuna','name','Nessuna difesa'))||coalesce(p_source->'abilities','[]')) LOOP
     reaction:=coalesce(meta->>'reaction','tecnica'); IF reaction='parata' AND clan_inuzuka_private.quattro_active(a.id) THEN CONTINUE; END IF;
     IF reaction='tecnica' AND NOT coalesce((meta->>'defensive')::boolean,false) THEN CONTINUE; END IF;
     meta:=clan_hyuga_private.sedici_ability_meta(a.id,meta); IF meta IS NULL THEN CONTINUE; END IF; IF meta->>'source'='clan' AND meta->>'id'='b076a976-c75b-4b5a-8813-b0e8e2c3af03' AND clan_inuzuka_private.zanna_profile(a.id) IS NULL THEN CONTINUE; END IF;
     cost:=(clan_hyuga_private.sedici_cost_quote(a.id,coalesce((meta->>'chakra_cost')::integer,0))->>'total')::integer; IF cost>chakra THEN CONTINUE; END IF;
     BEGIN
       PERFORM clan_marionettisti_private.assert_jutsu_source(a.id,meta->>'source',(meta->>'id')::uuid);
     EXCEPTION WHEN SQLSTATE '22023' THEN
       IF SQLERRM='fili_other_jutsu_unavailable' THEN CONTINUE; ELSE RAISE; END IF;
     END;
     mode:=CASE WHEN reaction IN ('schivata','parata','nessuna') THEN 'self' ELSE coalesce(meta#>>'{targeting,mode}','self') END;
     IF mode NOT IN ('self','intercept','multi_protect') THEN CONTINUE; END IF;
     -- Match resolver admission: unsupported generic self is never an offered dead end.
     -- Dedicated spatial substitution below is preserved.
     IF reaction='tecnica' AND mode='self' THEN CONTINUE; END IF;
     minimum:=CASE WHEN mode='multi_protect' THEN 2 ELSE 1 END;
     IF mode<>'self' AND NOT coalesce(combat_v2_multitarget_internal.defense_profile_ok(meta,mode,minimum),false) THEN CONTINUE; END IF;
     legal:='[]';
     FOR pending IN SELECT value FROM jsonb_array_elements(p_source->'pending_attack_targets') LOOP
       target_id:=(pending->>'target_actor_id')::uuid;
       IF NOT EXISTS(SELECT 1 FROM jsonb_array_elements(p_view#>'{map,actors}') WHERE value->>'actor_id'=target_id::text) THEN CONTINUE; END IF;
       IF mode='self' THEN
         IF target_id<>a.id AND NOT clan_marionettisti_private.defends_body(a.id,target_id,reaction) THEN CONTINUE; END IF;
       ELSIF combat_panel_private.actor_distance(a.id,target_id)>2 THEN CONTINUE;
       END IF;
       IF meta->>'id'='9f12fc98-bc97-4b95-9bcc-7ce359ebbe4f' AND NOT EXISTS(
         SELECT 1 FROM public.combat_v2_declarations WHERE id=(pending->>'attack_declaration_id')::uuid
           AND lower(coalesce(sanitized_intent#>>'{server_ability,kind}','')) LIKE '%genjutsu%') THEN CONTINUE; END IF;
       SELECT value->>'display_name' INTO label FROM jsonb_array_elements(p_view->'actors') WHERE value->>'actor_id'=target_id::text;
       legal:=legal||jsonb_build_array(pending||jsonb_build_object('label','Attacco su '||label));
     END LOOP;
     IF jsonb_array_length(legal)<minimum THEN CONTINUE; END IF;
     cap:=CASE WHEN mode='multi_protect' THEN least(4,jsonb_array_length(legal)) ELSE 1 END;
     payload:=jsonb_build_object('adapter','master_v2','dispatch','defense','reaction',reaction,'mode',mode);
     IF reaction='tecnica' THEN payload:=payload||jsonb_build_object('ability_source',meta->'source','ability_id',meta->'id'); END IF;
     oid:=combat_panel_private.create_offer(c.id,c.context_version,'defense','defend',(meta->>'name')||CASE WHEN cost>0 THEN ' · '||cost::text||' chakra' ELSE '' END,true,payload);
     gid:=combat_panel_private.add_group(oid,'Copertura','coverage',CASE WHEN cap>1 THEN 'multiple' ELSE 'single' END,minimum,cap);
     FOR item IN SELECT value FROM jsonb_array_elements(legal) LOOP
       target_choice:=combat_panel_private.add_choice(gid,item->>'label',item-'label');
       PERFORM combat_panel_private.multiplication_add_defense_figures(oid,a.id,(item->>'attack_target_id')::uuid,target_choice);
     END LOOP;
   END LOOP;
   BEGIN
     PERFORM clan_marionettisti_private.assert_jutsu_source(a.id,'jutsu','31b15861-fb78-4f8a-ac1c-ebf2d957c32e');
   EXCEPTION WHEN SQLSTATE '22023' THEN
     IF SQLERRM='fili_other_jutsu_unavailable' THEN RETURN; ELSE RAISE; END IF;
   END;
   IF chakra>=(clan_hyuga_private.sedici_cost_quote(a.id,5)->>'total')::integer THEN
     FOR pending IN SELECT value FROM jsonb_array_elements(coalesce(p_source->'substitution_offers','[]')) LOOP
       IF jsonb_array_length(coalesce(pending#>'{offer,options}','[]'))=0 THEN CONTINUE; END IF;
       oid:=combat_panel_private.create_offer(c.id,c.context_version,'defense','defend','Sostituzione · '||(clan_hyuga_private.sedici_cost_quote(a.id,5)->>'total')||' chakra',true,
         jsonb_build_object('adapter','master_v2','dispatch','substitution','attack_declaration_id',pending->'attack_declaration_id'));
       SELECT id INTO defense_target_id FROM public.combat_v2_attack_targets
         WHERE attack_declaration_id=(pending->>'attack_declaration_id')::uuid AND round_id=c.round_id AND target_actor_id=a.id;
       IF defense_target_id IS NOT NULL THEN
         PERFORM combat_panel_private.multiplication_add_defense_figures(oid,a.id,defense_target_id); END IF;
       gid:=combat_panel_private.add_group(oid,'Punto di sostituzione','target','single',1,1);
       FOR item IN SELECT value FROM jsonb_array_elements(pending#>'{offer,options}') LOOP
         PERFORM combat_panel_private.add_choice(gid,coalesce(item->>'label','Punto disponibile'),
           jsonb_build_object('substitution_option_id',item->'option_id'));
       END LOOP;
     END LOOP;
   END IF;
 END IF;
 PERFORM set_config('tus.native_attack_producer_diag',jsonb_build_object('targets_total',diag_targets_total,'targets_seen',diag_targets_seen,'mano_seen',diag_mano_seen,'geometry_stay',diag_geometry_stay,'endpoint_count',diag_endpoint_count,'pending_count',diag_pending_count,'rejected_geometry',diag_rejected_geometry,'label_present',diag_label_present,'legal_total',diag_legal_total,'action_entered',diag_action_entered)::text,true);
END $function$;

CREATE OR REPLACE FUNCTION combat_panel_private.master_scene_lifecycle_trigger()
 RETURNS trigger
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO ''
AS $function$
DECLARE encounter uuid;
BEGIN
 IF TG_TABLE_NAME='master_v2_sessions' THEN
   IF (NEW.master_user,NEW.control_version,NEW.stato,NEW.closed_at) IS NOT DISTINCT FROM
     (OLD.master_user,OLD.control_version,OLD.stato,OLD.closed_at) THEN RETURN NEW; END IF;
   FOR encounter IN SELECT s.id FROM public.combat_v2_sessions s JOIN combat_spatial.arena_instances i
     ON i.encounter_id=s.id AND i.context_source='panel_master' WHERE s.master_session_id=NEW.id ORDER BY s.id LOOP
     PERFORM combat_panel_private.sync_master_scene(encounter);
   END LOOP;
 ELSIF TG_TABLE_NAME='combat_v2_sessions' THEN
   IF (NEW.state,NEW.closed_at) IS DISTINCT FROM (OLD.state,OLD.closed_at) THEN
     PERFORM combat_panel_private.sync_master_scene(NEW.id);
   END IF;
 ELSIF TG_TABLE_NAME='combat_v2_actors' THEN
   IF (NEW.controller_user,NEW.controller_version) IS DISTINCT FROM (OLD.controller_user,OLD.controller_version) THEN
     PERFORM combat_panel_private.sync_master_scene(NEW.session_id);
     IF EXISTS (SELECT 1 FROM clan_innata_combat_private.combat_state AS st
                WHERE st.session_id=NEW.session_id AND st.actor_id=NEW.id
                  AND st.technique_id='c9b261da-c9cd-40bb-8189-7b65ab5a1605'::uuid AND st.is_test IS TRUE AND st.active) THEN
      PERFORM clan_innata_private.combat_terminal(NEW.id,'c9b261da-c9cd-40bb-8189-7b65ab5a1605'::uuid,'owner_inoperative');
     END IF;
   END IF;
 END IF;
 RETURN NEW;
END $function$;

CREATE OR REPLACE FUNCTION clan_innata_private.catalogo_eligibility_release_v1()
 RETURNS boolean
 LANGUAGE plpgsql
 STABLE SECURITY DEFINER
 SET search_path TO ''
AS $function$
DECLARE
 rr mission_factory_owner.editor_release_readiness%ROWTYPE;root jsonb;binding jsonb;amendment jsonb;
 params constant jsonb:=$compat_metadata${"expected_alias_count":7,"shared_functions":[{"oid":"42942","signature":"combat_consumer_private.narrative_context(uuid)","source_md5":"84031451f48f40639d7f2a1fe8e957d3","ddl_md5":"3f67e976ddab257ce59ec1785a0365fb","abi":{"acl":"{postgres=X/postgres}","oid":"42942","kind":"f","owner":"postgres","config":["search_path=\"\""],"secdef":true,"strict":false,"nspname":"combat_consumer_private","proname":"narrative_context","returns":"jsonb","language":"plpgsql","parallel":"u","arg_modes":null,"arg_names":["p_round"],"arg_types":"2950","leakproof":false,"signature":"combat_consumer_private.narrative_context(uuid)","volatility":"s"}},{"oid":"46723","signature":"combat_consumer_private.narrative_declaration_supported(uuid)","source_md5":"1ed7184037cedfef9d606dfd7090e7a4","ddl_md5":"9d2cad68a149da7f97c177bcf51d73c0","abi":{"acl":"{postgres=X/postgres}","oid":"46723","kind":"f","owner":"postgres","config":["search_path=\"\""],"secdef":true,"strict":false,"nspname":"combat_consumer_private","proname":"narrative_declaration_supported","returns":"boolean","language":"plpgsql","parallel":"u","arg_modes":null,"arg_names":["p_declaration"],"arg_types":"2950","leakproof":false,"signature":"combat_consumer_private.narrative_declaration_supported(uuid)","volatility":"s"}},{"oid":"42968","signature":"combat_consumer_private.validate_narrative_result(jsonb)","source_md5":"6664101fcd222bd583e9ae8cf7b2b7fc","ddl_md5":"097d6805ce2b21e21fc9aa7fe2a5a9ca","abi":{"acl":"{postgres=X/postgres}","oid":"42968","kind":"f","owner":"postgres","config":["search_path=\"\""],"secdef":false,"strict":false,"nspname":"combat_consumer_private","proname":"validate_narrative_result","returns":"void","language":"plpgsql","parallel":"u","arg_modes":null,"arg_names":["p"],"arg_types":"3802","leakproof":false,"signature":"combat_consumer_private.validate_narrative_result(jsonb)","volatility":"i"}},{"oid":"52137","signature":"combat_effects_private.lifecycle_before_report(uuid)","source_md5":"bc4009af6a274d51e6b96fc51f7a7a78","ddl_md5":"ee929b8e4bb4efcd584e7755aa5df682","abi":{"acl":"{postgres=X/postgres}","oid":"52137","kind":"f","owner":"postgres","config":["search_path=\"\""],"secdef":true,"strict":false,"nspname":"combat_effects_private","proname":"lifecycle_before_report","returns":"jsonb","language":"plpgsql","parallel":"u","arg_modes":null,"arg_names":["p_round"],"arg_types":"2950","leakproof":false,"signature":"combat_effects_private.lifecycle_before_report(uuid)","volatility":"v"}},{"oid":"52136","signature":"combat_effects_private.lifecycle_main_end(uuid)","source_md5":"a1948e8ce4fc505fc23e4e4089958507","ddl_md5":"0b743c53cb23a3402542468dc3096430","abi":{"acl":"{postgres=X/postgres}","oid":"52136","kind":"f","owner":"postgres","config":["search_path=\"\""],"secdef":true,"strict":false,"nspname":"combat_effects_private","proname":"lifecycle_main_end","returns":"jsonb","language":"plpgsql","parallel":"u","arg_modes":null,"arg_names":["p_declaration"],"arg_types":"2950","leakproof":false,"signature":"combat_effects_private.lifecycle_main_end(uuid)","volatility":"v"}},{"oid":"52133","signature":"combat_effects_private.lifecycle_open(uuid,uuid)","source_md5":"25b975033c044147b540a6e6492f1b85","ddl_md5":"531b5e14f873e40a1b5042f40ea1b15d","abi":{"acl":"{postgres=X/postgres}","oid":"52133","kind":"f","owner":"postgres","config":["search_path=\"\""],"secdef":true,"strict":false,"nspname":"combat_effects_private","proname":"lifecycle_open","returns":"void","language":"plpgsql","parallel":"u","arg_modes":null,"arg_names":["p_session","p_actor"],"arg_types":"2950 2950","leakproof":false,"signature":"combat_effects_private.lifecycle_open(uuid,uuid)","volatility":"v"}},{"oid":"51910","signature":"combat_effects_private.personal_turn_end(uuid,uuid,uuid,text)","source_md5":"29f0a8df88c6bed279f650d49a706699","ddl_md5":"9e8138c513fa0c8824ca9c5d48aa3d54","abi":{"acl":"{postgres=X/postgres}","oid":"51910","kind":"f","owner":"postgres","config":["search_path=\"\""],"secdef":true,"strict":false,"nspname":"combat_effects_private","proname":"personal_turn_end","returns":"jsonb","language":"plpgsql","parallel":"u","arg_modes":null,"arg_names":["p_session","p_actor","p_turn","p_adapter"],"arg_types":"2950 2950 2950 25","leakproof":false,"signature":"combat_effects_private.personal_turn_end(uuid,uuid,uuid,text)","volatility":"v"}},{"oid":"51906","signature":"combat_effects_private.personal_turn_start(uuid,uuid,uuid,text)","source_md5":"e7ec43224a4640d00c53bad72ac0132d","ddl_md5":"d023d8a651a5e8ef8fdb1cc834b93391","abi":{"acl":"{postgres=X/postgres}","oid":"51906","kind":"f","owner":"postgres","config":["search_path=\"\""],"secdef":true,"strict":false,"nspname":"combat_effects_private","proname":"personal_turn_start","returns":"void","language":"plpgsql","parallel":"u","arg_modes":null,"arg_names":["p_session","p_actor","p_turn","p_adapter"],"arg_types":"2950 2950 2950 25","leakproof":false,"signature":"combat_effects_private.personal_turn_start(uuid,uuid,uuid,text)","volatility":"v"}},{"oid":"44942","signature":"combat_panel_private.commit_master_actor(jsonb)","source_md5":"0c39121bcbd32a49608e4d925560ba41","ddl_md5":"b531bb7f50d4346a09e822b2f2e95144","abi":{"acl":"{postgres=X/postgres}","oid":"44942","kind":"f","owner":"postgres","config":["search_path=\"\""],"secdef":true,"strict":false,"nspname":"combat_panel_private","proname":"commit_master_actor","returns":"jsonb","language":"plpgsql","parallel":"u","arg_modes":null,"arg_names":["p_command"],"arg_types":"3802","leakproof":false,"signature":"combat_panel_private.commit_master_actor(jsonb)","volatility":"v"}},{"oid":"45916","signature":"combat_panel_private.immobilization_actor_lifecycle()","source_md5":"5244a1f635ad7d7336d24140d288b82a","ddl_md5":"f8677e282d09ca9015c01de07391f1bc","abi":{"acl":"{postgres=X/postgres}","oid":"45916","kind":"f","owner":"postgres","config":["search_path=\"\""],"secdef":true,"strict":false,"nspname":"combat_panel_private","proname":"immobilization_actor_lifecycle","returns":"trigger","language":"plpgsql","parallel":"u","arg_modes":null,"arg_names":null,"arg_types":"","leakproof":false,"signature":"combat_panel_private.immobilization_actor_lifecycle()","volatility":"v"}},{"oid":"45918","signature":"combat_panel_private.immobilization_session_lifecycle()","source_md5":"a4671931aa6e908a94af2ad2d788d933","ddl_md5":"38bc9bc060bc1af88cf087f5e4a687bb","abi":{"acl":"{postgres=X/postgres}","oid":"45918","kind":"f","owner":"postgres","config":["search_path=\"\""],"secdef":true,"strict":false,"nspname":"combat_panel_private","proname":"immobilization_session_lifecycle","returns":"trigger","language":"plpgsql","parallel":"u","arg_modes":null,"arg_names":null,"arg_types":"","leakproof":false,"signature":"combat_panel_private.immobilization_session_lifecycle()","volatility":"v"}},{"oid":"44940","signature":"combat_panel_private.master_options(uuid,uuid,bigint)","source_md5":"c3ae5fff837af5db1779970e73a414bd","ddl_md5":"6273f7d573951ae327a062c9d2f37099","abi":{"acl":"{postgres=X/postgres}","oid":"44940","kind":"f","owner":"postgres","config":["search_path=\"\""],"secdef":true,"strict":false,"nspname":"combat_panel_private","proname":"master_options","returns":"jsonb","language":"plpgsql","parallel":"u","arg_modes":null,"arg_names":["p_location","p_actor","p_expected"],"arg_types":"2950 2950 20","leakproof":false,"signature":"combat_panel_private.master_options(uuid,uuid,bigint)","volatility":"v"}},{"oid":"45000","signature":"combat_panel_private.movement_block_reason(uuid)","source_md5":"9cd995d873f2ae85f3cac5c0d7ff21ad","ddl_md5":"4830deea719904406d11aa4b05cfd764","abi":{"acl":"{postgres=X/postgres}","oid":"45000","kind":"f","owner":"postgres","config":["search_path=\"\""],"secdef":true,"strict":false,"nspname":"combat_panel_private","proname":"movement_block_reason","returns":"text","language":"plpgsql","parallel":"u","arg_modes":null,"arg_names":["p_body"],"arg_types":"2950","leakproof":false,"signature":"combat_panel_private.movement_block_reason(uuid)","volatility":"s"}},{"oid":"46019","signature":"combat_panel_private.narrative_declaration_facts(uuid)","source_md5":"89ee0fe9b71918c3ba0cf25f7a334f45","ddl_md5":"4650bb589eddf6b71249114fe08c5844","abi":{"acl":"{postgres=X/postgres}","oid":"46019","kind":"f","owner":"postgres","config":["search_path=\"\""],"secdef":true,"strict":false,"nspname":"combat_panel_private","proname":"narrative_declaration_facts","returns":"jsonb","language":"plpgsql","parallel":"u","arg_modes":null,"arg_names":["p_declaration"],"arg_types":"2950","leakproof":false,"signature":"combat_panel_private.narrative_declaration_facts(uuid)","volatility":"s"}},{"oid":"46020","signature":"combat_panel_private.narrative_ordinary_context(uuid)","source_md5":"13ad2618307934e63c1ad96186957971","ddl_md5":"a811eaf1eafd4203b019825e4d84b2dc","abi":{"acl":"{postgres=X/postgres}","oid":"46020","kind":"f","owner":"postgres","config":["search_path=\"\""],"secdef":true,"strict":false,"nspname":"combat_panel_private","proname":"narrative_ordinary_context","returns":"jsonb","language":"plpgsql","parallel":"u","arg_modes":null,"arg_names":["p_round"],"arg_types":"2950","leakproof":false,"signature":"combat_panel_private.narrative_ordinary_context(uuid)","volatility":"s"}},{"oid":"46018","signature":"combat_panel_private.narrative_outcome_facts(jsonb)","source_md5":"988cc3b61d0ebf41effda90d32e173b5","ddl_md5":"a4d973f30fbd64ace5540ea3438c8e26","abi":{"acl":"{postgres=X/postgres}","oid":"46018","kind":"f","owner":"postgres","config":["search_path=\"\""],"secdef":false,"strict":false,"nspname":"combat_panel_private","proname":"narrative_outcome_facts","returns":"jsonb","language":"plpgsql","parallel":"u","arg_modes":null,"arg_names":["p_outcome"],"arg_types":"3802","leakproof":false,"signature":"combat_panel_private.narrative_outcome_facts(jsonb)","volatility":"s"}},{"oid":"44669","signature":"combat_panel_private.ordinary_options(uuid,uuid,bigint)","source_md5":"e1e6cd169797dc97d13aee366489d338","ddl_md5":"46424781b6fd6d34a0415090df6703f1","abi":{"acl":"{postgres=X/postgres}","oid":"44669","kind":"f","owner":"postgres","config":["search_path=\"\""],"secdef":true,"strict":false,"nspname":"combat_panel_private","proname":"ordinary_options","returns":"jsonb","language":"plpgsql","parallel":"u","arg_modes":null,"arg_names":["p_location","p_actor","p_expected"],"arg_types":"2950 2950 20","leakproof":false,"signature":"combat_panel_private.ordinary_options(uuid,uuid,bigint)","volatility":"v"}},{"oid":"44955","signature":"combat_panel_private.round_details_from_source(jsonb,jsonb,jsonb)","source_md5":"23722822d09c8d2a12a5121d04c141a6","ddl_md5":"883d64a10bb28250187b01e96e2dcf5e","abi":{"acl":"{postgres=X/postgres}","oid":"44955","kind":"f","owner":"postgres","config":["search_path=\"\""],"secdef":false,"strict":false,"nspname":"combat_panel_private","proname":"round_details_from_source","returns":"jsonb","language":"plpgsql","parallel":"u","arg_modes":null,"arg_names":["p_source","p_roster","p_offers"],"arg_types":"3802 3802 3802","leakproof":false,"signature":"combat_panel_private.round_details_from_source(jsonb,jsonb,jsonb)","volatility":"i"}},{"oid":"46316","signature":"combat_panel_private.round_options_authoritative(uuid,uuid)","source_md5":"7cf9d8be18c9dab5f75b62c74a5e9e37","ddl_md5":"7758a51d9039673ab98462102c44f888","abi":{"acl":"{postgres=X/postgres}","oid":"46316","kind":"f","owner":"postgres","config":["search_path=\"\""],"secdef":true,"strict":false,"nspname":"combat_panel_private","proname":"round_options_authoritative","returns":"jsonb","language":"plpgsql","parallel":"u","arg_modes":null,"arg_names":["p_round","p_actor"],"arg_types":"2950 2950","leakproof":false,"signature":"combat_panel_private.round_options_authoritative(uuid,uuid)","volatility":"v"}},{"oid":"61967","signature":"combat_v2_elemental_internal.other_consumer_options(jsonb)","source_md5":"8423c49ce8a83f2b19361b82a53fa9f4","ddl_md5":"0d57fa274c2b6b63dc5ed1ef0a7c8ca9","abi":{"acl":"{postgres=X/postgres}","oid":"61967","kind":"f","owner":"postgres","config":["search_path=\"\""],"secdef":true,"strict":false,"nspname":"combat_v2_elemental_internal","proname":"other_consumer_options","returns":"jsonb","language":"plpgsql","parallel":"u","arg_modes":null,"arg_names":["p"],"arg_types":"3802","leakproof":false,"signature":"combat_v2_elemental_internal.other_consumer_options(jsonb)","volatility":"v"}},{"oid":"61972","signature":"combat_v2_elemental_internal.other_control_apply(text,uuid,uuid,uuid)","source_md5":"4cf97ca72ff52f1bd33445ba54c8dd16","ddl_md5":"9066a8a35e086727ed0240ea05fce684","abi":{"acl":"{postgres=X/postgres}","oid":"61972","kind":"f","owner":"postgres","config":["search_path=\"\""],"secdef":true,"strict":false,"nspname":"combat_v2_elemental_internal","proname":"other_control_apply","returns":"jsonb","language":"plpgsql","parallel":"u","arg_modes":null,"arg_names":["p_adapter","p_offer","p_actor","p_request"],"arg_types":"25 2950 2950 2950","leakproof":false,"signature":"combat_v2_elemental_internal.other_control_apply(text,uuid,uuid,uuid)","volatility":"v"}},{"oid":"61971","signature":"combat_v2_elemental_internal.other_control_target(text,uuid,uuid)","source_md5":"b1af00f3eab38ed9e74836c5441616d7","ddl_md5":"03724449dfc52ef8fcf4f89ae6eabb34","abi":{"acl":"{postgres=X/postgres}","oid":"61971","kind":"f","owner":"postgres","config":["search_path=\"\""],"secdef":true,"strict":false,"nspname":"combat_v2_elemental_internal","proname":"other_control_target","returns":"uuid","language":"plpgsql","parallel":"u","arg_modes":null,"arg_names":["p_adapter","p_offer","p_actor"],"arg_types":"25 2950 2950","leakproof":false,"signature":"combat_v2_elemental_internal.other_control_target(text,uuid,uuid)","volatility":"v"}},{"oid":"61970","signature":"combat_v2_elemental_internal.other_master_options(uuid,bigint)","source_md5":"0c79a6a78b76b9e9ef8028d75e514af7","ddl_md5":"38e2e92e5566275950c270ef5a8fe3d6","abi":{"acl":"{postgres=X/postgres}","oid":"61970","kind":"f","owner":"postgres","config":["search_path=\"\""],"secdef":true,"strict":false,"nspname":"combat_v2_elemental_internal","proname":"other_master_options","returns":"void","language":"plpgsql","parallel":"u","arg_modes":null,"arg_names":["p_context","p_expected"],"arg_types":"2950 20","leakproof":false,"signature":"combat_v2_elemental_internal.other_master_options(uuid,bigint)","volatility":"v"}},{"oid":"61954","signature":"combat_v2_elemental_internal.other_prepare_native(uuid,uuid,uuid,jsonb,boolean,jsonb)","source_md5":"6e54b476b36ca716cf8c14f33ef9667e","ddl_md5":"98acc6f2f9fcb26b47f3e6e830763e42","abi":{"acl":"{postgres=X/postgres}","oid":"61954","kind":"f","owner":"postgres","config":["search_path=\"\""],"secdef":true,"strict":false,"nspname":"combat_v2_elemental_internal","proname":"other_prepare_native","returns":"jsonb","language":"plpgsql","parallel":"u","arg_modes":null,"arg_names":["p_round","p_actor","p_request","p_intent","p_push","p_native_ref"],"arg_types":"2950 2950 2950 3802 16 3802","leakproof":false,"signature":"combat_v2_elemental_internal.other_prepare_native(uuid,uuid,uuid,jsonb,boolean,jsonb)","volatility":"v"}},{"oid":"61950","signature":"combat_v2_elemental_internal.other_profile(uuid,uuid)","source_md5":"dd1e62e9052469fae4c98fed245c730a","ddl_md5":"0959ae18dc9357f65d8d8169e39b0cb2","abi":{"acl":"{postgres=X/postgres}","oid":"61950","kind":"f","owner":"postgres","config":["search_path=\"\""],"secdef":true,"strict":false,"nspname":"combat_v2_elemental_internal","proname":"other_profile","returns":"jsonb","language":"plpgsql","parallel":"u","arg_modes":null,"arg_names":["p_actor","p_technique"],"arg_types":"2950 2950","leakproof":false,"signature":"combat_v2_elemental_internal.other_profile(uuid,uuid)","volatility":"s"}},{"oid":"39291","signature":"combat_v2_multitarget_internal.resolve_parent(uuid,uuid,uuid,boolean)","source_md5":"9b278e6f9024b78be794aed4b23ca4ae","ddl_md5":"2cb3c3d30a1c058770ef611fb90dbd80","abi":{"acl":"{postgres=X/postgres}","oid":"39291","kind":"f","owner":"postgres","config":["search_path=\"\""],"secdef":true,"strict":false,"nspname":"combat_v2_multitarget_internal","proname":"resolve_parent","returns":"jsonb","language":"plpgsql","parallel":"u","arg_modes":null,"arg_names":["p_session","p_round","p_attack","p_values"],"arg_types":"2950 2950 2950 16","leakproof":false,"signature":"combat_v2_multitarget_internal.resolve_parent(uuid,uuid,uuid,boolean)","volatility":"v"}},{"oid":"42947","signature":"public.combat_consumer_narrative_claim_v1(uuid,text,uuid)","source_md5":"c144d4c43e22c5e3eb516e0d46ebf65a","ddl_md5":"2c521aac41eeea3d0a843ff05c5b1e24","abi":{"acl":"{postgres=X/postgres,service_role=X/postgres}","oid":"42947","kind":"f","owner":"postgres","config":["search_path=\"\""],"secdef":true,"strict":false,"nspname":"public","proname":"combat_consumer_narrative_claim_v1","returns":"jsonb","language":"plpgsql","parallel":"u","arg_modes":null,"arg_names":["p_round","p_report_sha256","p_request_key"],"arg_types":"2950 25 2950","leakproof":false,"signature":"public.combat_consumer_narrative_claim_v1(uuid,text,uuid)","volatility":"v"}},{"oid":"42969","signature":"public.combat_consumer_narrative_complete_v1(uuid,jsonb,uuid)","source_md5":"ca906d6285eee8a8617e0cb3db70f6f9","ddl_md5":"e56749f8d49bc345ebda55a833b0ae00","abi":{"acl":"{postgres=X/postgres,service_role=X/postgres}","oid":"42969","kind":"f","owner":"postgres","config":["search_path=\"\""],"secdef":true,"strict":false,"nspname":"public","proname":"combat_consumer_narrative_complete_v1","returns":"jsonb","language":"plpgsql","parallel":"u","arg_modes":null,"arg_names":["p_claim","p_result","p_request_key"],"arg_types":"2950 3802 2950","leakproof":false,"signature":"public.combat_consumer_narrative_complete_v1(uuid,jsonb,uuid)","volatility":"v"}},{"oid":"44808","signature":"public.combat_panel_commit_v1(jsonb)","source_md5":"0b5a0ca3366bb6a302fcdfcddd306f48","ddl_md5":"274c9e4d68f91524e6a5f8904beea48e","abi":{"acl":"{postgres=X/postgres,authenticated=X/postgres}","oid":"44808","kind":"f","owner":"postgres","config":["search_path=\"\""],"secdef":true,"strict":false,"nspname":"public","proname":"combat_panel_commit_v1","returns":"jsonb","language":"plpgsql","parallel":"u","arg_modes":null,"arg_names":["p_command"],"arg_types":"3802","leakproof":false,"signature":"public.combat_panel_commit_v1(jsonb)","volatility":"v"}},{"oid":"31324","signature":"public.combat_v2_action_declare(uuid,uuid,jsonb,text,uuid)","source_md5":"77f98c15d1778bd7cc5e6fdfe8d221b8","ddl_md5":"91afc68d5d1419ed20d63b9c20fe14ea","abi":{"acl":"{postgres=X/postgres,authenticated=X/postgres,service_role=X/postgres}","oid":"31324","kind":"f","owner":"postgres","config":["search_path=\"\""],"secdef":true,"strict":false,"nspname":"public","proname":"combat_v2_action_declare","returns":"jsonb","language":"plpgsql","parallel":"u","arg_modes":null,"arg_names":["p_round","p_actor","p_intent","p_text","p_request_key"],"arg_types":"2950 2950 3802 25 2950","leakproof":false,"signature":"public.combat_v2_action_declare(uuid,uuid,jsonb,text,uuid)","volatility":"v"}},{"oid":"31311","signature":"public.combat_v2_actor_ability(uuid,text,uuid,boolean)","source_md5":"2ec5e6a87514a1997100990dde420a62","ddl_md5":"847221b518ed740a64afdcd00f7cd763","abi":{"acl":"{postgres=X/postgres,service_role=X/postgres}","oid":"31311","kind":"f","owner":"postgres","config":["search_path=\"\""],"secdef":true,"strict":false,"nspname":"public","proname":"combat_v2_actor_ability","returns":"jsonb","language":"sql","parallel":"u","arg_modes":null,"arg_names":["p_actor","p_source","p_ability","p_defense"],"arg_types":"2950 25 2950 16","leakproof":false,"signature":"public.combat_v2_actor_ability(uuid,text,uuid,boolean)","volatility":"s"}},{"oid":"31326","signature":"public.combat_v2_defense_declare(uuid,uuid,uuid,jsonb,text,uuid)","source_md5":"446494ad3becd44a65b241967810e589","ddl_md5":"5a97231f154dab9e97c2a03b0cc142ac","abi":{"acl":"{postgres=X/postgres,authenticated=X/postgres,service_role=X/postgres}","oid":"31326","kind":"f","owner":"postgres","config":["search_path=\"\""],"secdef":true,"strict":false,"nspname":"public","proname":"combat_v2_defense_declare","returns":"jsonb","language":"plpgsql","parallel":"u","arg_modes":null,"arg_names":["p_round","p_attack_declaration","p_actor","p_intent","p_text","p_request_key"],"arg_types":"2950 2950 2950 3802 25 2950","leakproof":false,"signature":"public.combat_v2_defense_declare(uuid,uuid,uuid,jsonb,text,uuid)","volatility":"v"}},{"oid":"31331","signature":"public.combat_v2_round_resolve(uuid,uuid)","source_md5":"bbe708d2f06cb96681141fce45915c28","ddl_md5":"d9d8438f3fc3bde3e799ee158055305f","abi":{"acl":"{postgres=X/postgres,service_role=X/postgres,authenticated=X/postgres}","oid":"31331","kind":"f","owner":"postgres","config":["search_path=\"\""],"secdef":true,"strict":false,"nspname":"public","proname":"combat_v2_round_resolve","returns":"jsonb","language":"plpgsql","parallel":"u","arg_modes":null,"arg_names":["p_round","p_request_key"],"arg_types":"2950 2950","leakproof":false,"signature":"public.combat_v2_round_resolve(uuid,uuid)","volatility":"v"}},{"oid":"19700","signature":"public.post_heal(uuid,uuid)","source_md5":"dcde447ee079472efa4fd41c1c911633","ddl_md5":"9fb236d5f72312f6fb33587a2981e427","abi":{"acl":"{postgres=X/postgres,service_role=X/postgres,authenticated=X/postgres}","oid":"19700","kind":"f","owner":"postgres","config":["search_path=public"],"secdef":true,"strict":false,"nspname":"public","proname":"post_heal","returns":"text","language":"plpgsql","parallel":"u","arg_modes":null,"arg_names":["p_location","p_target_user"],"arg_types":"2950 2950","leakproof":false,"signature":"public.post_heal(uuid,uuid)","volatility":"v"}}],"private_functions":[{"signature":"combat_panel_private.catalog_lifecycle_lines_v1(jsonb,jsonb)","source_md5":"8a472424ef8d1bc4d04283d18a0d049e"},{"signature":"combat_panel_private.catalog_result_label_v1(jsonb)","source_md5":"eb0798e0d80f5b1215949f4d6d6445bd"},{"signature":"combat_panel_private.cure_bind_v1(uuid)","source_md5":"a9c1bde3a9b0de30c44312b12be60eff"},{"signature":"combat_panel_private.cure_commit_v1(jsonb)","source_md5":"61532836e90ed32ae807b92ee6632b71"},{"signature":"combat_panel_private.cure_contact_v1(uuid,uuid)","source_md5":"21de7dd5e62b5403b50065d2635e20bf"},{"signature":"combat_panel_private.cure_declaration_meta_v1(uuid,uuid,uuid,jsonb)","source_md5":"9fdec7a42f67372bc1f2e2f408f16ba1"},{"signature":"combat_panel_private.cure_defense_guard_v1()","source_md5":"72b7362b50720f93672dfa1ab96338bc"},{"signature":"combat_panel_private.cure_frozen_turn_valid_v1(uuid,uuid)","source_md5":"7785ea336dd4a1deb9dd19487756d638"},{"signature":"combat_panel_private.cure_narrative_facts_v1(uuid)","source_md5":"a32f97cddb31ccf9581ba328f1e94e49"},{"signature":"combat_panel_private.cure_neutral_preset_v1(uuid,uuid,uuid,jsonb)","source_md5":"dd236ae4c47770d25fd79cb2e9707d1f"},{"signature":"combat_panel_private.cure_note_voluntary_v1(uuid,uuid,text,text)","source_md5":"669353b795c5f327bdcd338c9990716d"},{"signature":"combat_panel_private.cure_offers_v1(uuid,bigint,jsonb)","source_md5":"db137b63815164ffd8435bcf87ce245c"},{"signature":"combat_panel_private.cure_persistent_execution_scope_v1(uuid)","source_md5":"ea6a91fa5940c0d3680a36c4ee962880"},{"signature":"combat_panel_private.cure_persistent_scope_v1(uuid)","source_md5":"4fdb37eb54e15b3da2845a41809ccc57"},{"signature":"combat_panel_private.cure_prepare_v1(uuid,uuid,uuid,uuid)","source_md5":"bf7f19036a2846412374c68950126ac5"},{"signature":"combat_panel_private.cure_profile_v1(uuid)","source_md5":"88ec3750ea8aa0661eaa573747325e87"},{"signature":"combat_panel_private.cure_resolve_v1(uuid)","source_md5":"d385538828e19526af5e59dc8d18f167"},{"signature":"combat_panel_private.cure_staff_execution_scope_v1(uuid)","source_md5":"9adc4dfa74e700f54ba58d8691fb8f76"},{"signature":"combat_panel_private.cure_staff_scope_v1(uuid)","source_md5":"343140ae23ba4787fa511d1e6f27092e"},{"signature":"combat_panel_private.cure_turn_clear_v1(uuid,uuid)","source_md5":"ff5fac17361830d01e19aeba05430328"},{"signature":"combat_panel_private.cure_turn_used_v1(uuid,uuid)","source_md5":"11badbd523e79faba44fa282150be54b"},{"signature":"combat_panel_private.cure_voluntary_receipt_guard_v1()","source_md5":"08bacb86944bec00bc213eddf9815dca"},{"signature":"combat_v2_genjutsu_internal.actor_meta(uuid)","source_md5":"df3798ced5e32f7cb5aef4283fd88a00"},{"signature":"combat_v2_genjutsu_internal.ally_contact(uuid,uuid)","source_md5":"32dcc6e95e61d7e9fe2389a398a07334"},{"signature":"combat_v2_genjutsu_internal.bind_release(uuid)","source_md5":"1c6bfe3e32950c77afbb8c7b91a21078"},{"signature":"combat_v2_genjutsu_internal.bind_source(uuid)","source_md5":"80c79fc14b48e386b5920d021d537ba7"},{"signature":"combat_v2_genjutsu_internal.binding(uuid)","source_md5":"404fc795700a7fbe3334464c97a5058b"},{"signature":"combat_v2_genjutsu_internal.comparison(uuid,uuid,jsonb)","source_md5":"e63a4943d52d01b719d9693039c18d6c"},{"signature":"combat_v2_genjutsu_internal.consumer_options(jsonb)","source_md5":"c8daec5fcb19dc88267f7ceab87a2be8"},{"signature":"combat_v2_genjutsu_internal.declaration_events(uuid)","source_md5":"194b5c80d8e4779c66f0fdb8c50f1de3"},{"signature":"combat_v2_genjutsu_internal.declaration_meta(uuid,uuid,uuid,jsonb)","source_md5":"1dadbb12c0a1965b0461133ca0efc5d3"},{"signature":"combat_v2_genjutsu_internal.decorate_outcome(uuid,uuid,jsonb)","source_md5":"d0160238be06fafb4ce521553d4e745a"},{"signature":"combat_v2_genjutsu_internal.defense_intent_allowed(uuid,jsonb)","source_md5":"bf261ee2a0f55a52a8bb9462333058bd"},{"signature":"combat_v2_genjutsu_internal.end_context(uuid,uuid)","source_md5":"9d931f4ac19d9170e6119458d4825b23"},{"signature":"combat_v2_genjutsu_internal.event_binding(uuid,jsonb)","source_md5":"8b3b23a81afc7c2092902373cedbe0d2"},{"signature":"combat_v2_genjutsu_internal.event_public(text)","source_md5":"ecaea9744e8960072a32e7908856f9c0"},{"signature":"combat_v2_genjutsu_internal.kai_defense_valid(uuid,uuid)","source_md5":"1ab8564f473d8a008ba29e8095a4a6de"},{"signature":"combat_v2_genjutsu_internal.master_options(uuid,bigint)","source_md5":"c9fbd722ccef5bc57cbabb67651a788f"},{"signature":"combat_v2_genjutsu_internal.movement_blocked(uuid)","source_md5":"8a243e907877525d58c71429cfbb8f98"},{"signature":"combat_v2_genjutsu_internal.narrative_facts(uuid)","source_md5":"de22bbd83e9ab8edb6a025e5131edde0"},{"signature":"combat_v2_genjutsu_internal.narrative_supported(uuid)","source_md5":"8c498c00f438621c617ae6132318ab66"},{"signature":"combat_v2_genjutsu_internal.open_turn(uuid,uuid)","source_md5":"701defaed0c81b0a6f4ccef2857a4a42"},{"signature":"combat_v2_genjutsu_internal.panel_options(uuid,bigint)","source_md5":"cb344a077d919955ef0f570ba9313d35"},{"signature":"combat_v2_genjutsu_internal.prepare(uuid,uuid,uuid,jsonb)","source_md5":"7275b845d7140c81fd2ec2ac48d3cd91"},{"signature":"combat_v2_genjutsu_internal.preset_ready(uuid)","source_md5":"b087938ff9bdc51ee5518c72beb88c04"},{"signature":"combat_v2_genjutsu_internal.profile()","source_md5":"87cf137eefa6f81cd178c039859c1c45"},{"signature":"combat_v2_genjutsu_internal.quote(uuid)","source_md5":"28ff62253407034032035e6acd8a2b6b"},{"signature":"combat_v2_genjutsu_internal.raw_attack_facts(uuid)","source_md5":"da147cc5595cac875224cbbebfe82ef8"},{"signature":"combat_v2_genjutsu_internal.real_owned(uuid)","source_md5":"f6e8ecb85aeb3c938cdc71eb0cbf80cd"},{"signature":"combat_v2_genjutsu_internal.record_event(text,uuid,jsonb)","source_md5":"9ba46dc99acb5e3063e0d813b55d0f3f"},{"signature":"combat_v2_genjutsu_internal.release_intents(uuid)","source_md5":"269945acde9a25aa53dc34e473366430"},{"signature":"combat_v2_genjutsu_internal.release_meta(uuid,uuid,uuid,jsonb)","source_md5":"9ebfc24d33a07eeb5b9a59eb85fd694e"},{"signature":"combat_v2_genjutsu_internal.report_facts(uuid)","source_md5":"03c90f3dd07812d1061c7037216304d9"},{"signature":"combat_v2_genjutsu_internal.report_projection(uuid)","source_md5":"d3c2e36c0248730650a6c6c4b34d1e47"},{"signature":"combat_v2_genjutsu_internal.resolution_enter(uuid,uuid)","source_md5":"c45574805f3171628ef99392fa255eb2"},{"signature":"combat_v2_genjutsu_internal.resolution_leave()","source_md5":"612f97c08785e572226423ed5c1f68ed"},{"signature":"combat_v2_genjutsu_internal.resolve_release(uuid)","source_md5":"0e5d351b87010bb3eaa271cb63099661"},{"signature":"combat_v2_genjutsu_internal.runtime_allowed(uuid)","source_md5":"8512b2d982094a3b339de4ec3bfd3327"},{"signature":"combat_v2_genjutsu_internal.scope(uuid)","source_md5":"ca9d5c5a82c1eeb64af358016ac50c1f"},{"signature":"combat_v2_genjutsu_internal.source_valid(uuid)","source_md5":"84ca595cfd34b8467b69c0256e94e254"},{"signature":"combat_v2_genjutsu_internal.staff_bind(uuid,uuid)","source_md5":"b8b6261b5c8f7df3c91400d5969d8eae"},{"signature":"combat_v2_genjutsu_internal.success(jsonb,integer,boolean)","source_md5":"90faca8a42e9f7f54726276f5a1e94bf"},{"signature":"combat_v2_genjutsu_internal.turn_end(uuid,uuid,uuid,text)","source_md5":"5130f380992a3585b502934e2833e716"},{"signature":"combat_v2_genjutsu_internal.turn_start(uuid,uuid,uuid,text)","source_md5":"b1781f3637f8c3414a9dd2c4038869c2"},{"signature":"combat_v2_genjutsu_internal.validate_attack_facts(jsonb)","source_md5":"0c6434b64a325213dbf8d18c603ed061"},{"signature":"combat_v2_genjutsu_internal.validate_release_facts(jsonb)","source_md5":"a46a047fa733321603e24a6102d7183d"}],"relations":[{"name":"combat_panel_private.cure_gate_v1","columns":[{"name":"singleton","type":"boolean","not_null":true,"default":"true"},{"name":"staff_enabled","type":"boolean","not_null":true,"default":"false"},{"name":"public_enabled","type":"boolean","not_null":true,"default":"false"},{"name":"contract_version","type":"text","not_null":true,"default":"'palmo-curativo/1'::text"}]},{"name":"combat_panel_private.cure_ledger_v1","columns":[{"name":"declaration_id","type":"uuid","not_null":true,"default":null},{"name":"session_id","type":"uuid","not_null":true,"default":null},{"name":"round_id","type":"uuid","not_null":true,"default":null},{"name":"actor_id","type":"uuid","not_null":true,"default":null},{"name":"target_actor_id","type":"uuid","not_null":true,"default":null},{"name":"hp_before","type":"integer","not_null":true,"default":null},{"name":"hp_after","type":"integer","not_null":true,"default":null},{"name":"hp_max","type":"integer","not_null":true,"default":null},{"name":"expected_gain","type":"integer","not_null":true,"default":null},{"name":"committed_gain","type":"integer","not_null":true,"default":null},{"name":"applied_real_gain","type":"integer","not_null":true,"default":"0"},{"name":"is_simulated","type":"boolean","not_null":true,"default":null},{"name":"facts","type":"jsonb","not_null":true,"default":null},{"name":"created_at","type":"timestamp with time zone","not_null":true,"default":"clock_timestamp()"}]},{"name":"combat_panel_private.cure_preparations_v1","columns":[{"name":"request_key","type":"uuid","not_null":true,"default":null},{"name":"transaction_id","type":"bigint","not_null":true,"default":null},{"name":"session_id","type":"uuid","not_null":true,"default":null},{"name":"round_id","type":"uuid","not_null":true,"default":null},{"name":"actor_id","type":"uuid","not_null":true,"default":null},{"name":"target_actor_id","type":"uuid","not_null":true,"default":null},{"name":"controller_user","type":"uuid","not_null":true,"default":null},{"name":"controller_version","type":"bigint","not_null":true,"default":null},{"name":"source","type":"jsonb","not_null":true,"default":null},{"name":"source_sha256","type":"text","not_null":true,"default":null},{"name":"declaration_id","type":"uuid","not_null":false,"default":null},{"name":"created_at","type":"timestamp with time zone","not_null":true,"default":"clock_timestamp()"}]},{"name":"combat_panel_private.cure_staff_profiles_v1","columns":[{"name":"actor_id","type":"uuid","not_null":true,"default":null},{"name":"session_id","type":"uuid","not_null":true,"default":null},{"name":"context_id","type":"uuid","not_null":true,"default":null},{"name":"controller_user","type":"uuid","not_null":true,"default":null},{"name":"controller_version","type":"bigint","not_null":true,"default":null},{"name":"ability","type":"jsonb","not_null":true,"default":null},{"name":"proof_sha256","type":"text","not_null":true,"default":null},{"name":"request_key","type":"uuid","not_null":true,"default":null},{"name":"created_at","type":"timestamp with time zone","not_null":true,"default":"clock_timestamp()"}]},{"name":"combat_panel_private.cure_voluntary_actions_v1","columns":[{"name":"actor_id","type":"uuid","not_null":true,"default":null},{"name":"round_id","type":"uuid","not_null":true,"default":null},{"name":"source_kind","type":"text","not_null":true,"default":null},{"name":"source_key","type":"text","not_null":true,"default":null},{"name":"created_at","type":"timestamp with time zone","not_null":true,"default":"clock_timestamp()"}]},{"name":"combat_v2_genjutsu_internal.effects","columns":[{"name":"id","type":"uuid","not_null":true,"default":"gen_random_uuid()"},{"name":"session_id","type":"uuid","not_null":true,"default":null},{"name":"source_declaration_id","type":"uuid","not_null":true,"default":null},{"name":"source_attack_target_id","type":"uuid","not_null":true,"default":null},{"name":"source_actor_id","type":"uuid","not_null":true,"default":null},{"name":"target_actor_id","type":"uuid","not_null":true,"default":null},{"name":"profile","type":"jsonb","not_null":true,"default":null},{"name":"source_outcome_sha256","type":"text","not_null":true,"default":null},{"name":"adapter","type":"text","not_null":true,"default":null},{"name":"excluded_turn_id","type":"uuid","not_null":false,"default":null},{"name":"due_turn_id","type":"uuid","not_null":false,"default":null},{"name":"state","type":"text","not_null":true,"default":null},{"name":"state_version","type":"bigint","not_null":true,"default":"1"},{"name":"created_at","type":"timestamp with time zone","not_null":true,"default":"clock_timestamp()"},{"name":"ended_at","type":"timestamp with time zone","not_null":false,"default":null},{"name":"end_reason","type":"text","not_null":false,"default":null}]},{"name":"combat_v2_genjutsu_internal.events","columns":[{"name":"event_key","type":"text","not_null":true,"default":null},{"name":"effect_id","type":"uuid","not_null":false,"default":null},{"name":"result","type":"jsonb","not_null":true,"default":null},{"name":"result_sha256","type":"text","not_null":true,"default":null},{"name":"binding","type":"jsonb","not_null":true,"default":null},{"name":"binding_sha256","type":"text","not_null":true,"default":null},{"name":"created_at","type":"timestamp with time zone","not_null":true,"default":"clock_timestamp()"}]},{"name":"combat_v2_genjutsu_internal.gate","columns":[{"name":"singleton","type":"boolean","not_null":true,"default":null},{"name":"enabled","type":"boolean","not_null":true,"default":null},{"name":"staff_enabled","type":"boolean","not_null":true,"default":null},{"name":"public_enabled","type":"boolean","not_null":true,"default":null},{"name":"version","type":"integer","not_null":true,"default":null}]},{"name":"combat_v2_genjutsu_internal.preparations","columns":[{"name":"actor_id","type":"uuid","not_null":true,"default":null},{"name":"round_id","type":"uuid","not_null":true,"default":null},{"name":"request_id","type":"uuid","not_null":true,"default":null},{"name":"transaction_id","type":"bigint","not_null":true,"default":null},{"name":"source","type":"jsonb","not_null":true,"default":null},{"name":"source_sha256","type":"text","not_null":true,"default":null}]},{"name":"combat_v2_genjutsu_internal.release_plans","columns":[{"name":"actor_id","type":"uuid","not_null":true,"default":null},{"name":"round_id","type":"uuid","not_null":true,"default":null},{"name":"request_id","type":"uuid","not_null":true,"default":null},{"name":"effect_id","type":"uuid","not_null":true,"default":null},{"name":"source","type":"jsonb","not_null":true,"default":null},{"name":"source_sha256","type":"text","not_null":true,"default":null},{"name":"transaction_id","type":"bigint","not_null":true,"default":null},{"name":"declaration_id","type":"uuid","not_null":false,"default":null},{"name":"declaration_sha256","type":"text","not_null":false,"default":null},{"name":"result","type":"jsonb","not_null":false,"default":null},{"name":"result_sha256","type":"text","not_null":false,"default":null}]},{"name":"combat_v2_genjutsu_internal.sources","columns":[{"name":"declaration_id","type":"uuid","not_null":true,"default":null},{"name":"session_id","type":"uuid","not_null":true,"default":null},{"name":"source","type":"jsonb","not_null":true,"default":null},{"name":"declaration_sha256","type":"text","not_null":true,"default":null},{"name":"source_sha256","type":"text","not_null":true,"default":null}]},{"name":"combat_v2_genjutsu_internal.staff_receipts","columns":[{"name":"actor_id","type":"uuid","not_null":true,"default":null},{"name":"session_id","type":"uuid","not_null":true,"default":null},{"name":"controller_user","type":"uuid","not_null":true,"default":null},{"name":"controller_version","type":"bigint","not_null":true,"default":null},{"name":"request_id","type":"uuid","not_null":true,"default":null},{"name":"receipt","type":"jsonb","not_null":true,"default":null},{"name":"receipt_sha256","type":"text","not_null":true,"default":null}]}],"triggers":[{"table":"clan_akimichi_private.form_commands","name":"cure_voluntary_receipt_v1","function":"combat_panel_private.cure_voluntary_receipt_guard_v1()","type":7},{"table":"clan_hoki_private.combat_events","name":"cure_voluntary_receipt_v1","function":"combat_panel_private.cure_voluntary_receipt_guard_v1()","type":7},{"table":"clan_innata_combat_private.combat_receipts","name":"cure_voluntary_receipt_v1","function":"combat_panel_private.cure_voluntary_receipt_guard_v1()","type":7},{"table":"clan_inuzuka_private.movement_receipts","name":"cure_voluntary_receipt_v1","function":"combat_panel_private.cure_voluntary_receipt_guard_v1()","type":7},{"table":"clan_marionettisti_private.control_events","name":"cure_voluntary_receipt_v1","function":"combat_panel_private.cure_voluntary_receipt_guard_v1()","type":7},{"table":"clan_marionettisti_private.movement_receipts","name":"cure_voluntary_receipt_v1","function":"combat_panel_private.cure_voluntary_receipt_guard_v1()","type":7},{"table":"clan_sabaku_private.armor_events","name":"cure_voluntary_receipt_v1","function":"combat_panel_private.cure_voluntary_receipt_guard_v1()","type":7},{"table":"combat_panel_private.master_movement_receipts","name":"cure_voluntary_receipt_v1","function":"combat_panel_private.cure_voluntary_receipt_guard_v1()","type":7},{"table":"combat_panel_private.request_receipts","name":"cure_voluntary_receipt_v1","function":"combat_panel_private.cure_voluntary_receipt_guard_v1()","type":7},{"table":"public.combat_v2_declarations","name":"cure_turn_defense_guard_v1","function":"combat_panel_private.cure_defense_guard_v1()","type":7}],"native_functions":[{"signature":"public.combat_v2_substitution_options_v1(uuid)","source_md5":"913cfd7a596794334b9b3ec8baa103a2","owner":"postgres","acl":"{postgres=X/postgres,authenticated=X/postgres}","config":["search_path=\"\""],"secdef":true,"volatility":"v","strict":false,"parallel":"u","language":"plpgsql","returns":"jsonb","arg_names":["p_attack_declaration"],"arg_modes":null,"arg_types":"2950","ddl_md5":"1dc4d3088d39991411d875ec662c5123"},{"signature":"public.combat_v2_substitution_round_offers_v1(uuid,uuid)","source_md5":"7f3c2e198105d066aceb762872f51a3d","owner":"postgres","acl":"{postgres=X/postgres,authenticated=X/postgres}","config":["search_path=\"\""],"secdef":true,"volatility":"v","strict":false,"parallel":"u","language":"plpgsql","returns":"jsonb","arg_names":["p_round","p_actor"],"arg_modes":null,"arg_types":"2950 2950","ddl_md5":"3a2b1781cc15da44f69cb940e527e864"},{"signature":"public.combat_v2_substitution_select_v1(uuid,uuid)","source_md5":"209648a06d537ad5b8870bdf8fe5c4cb","owner":"postgres","acl":"{postgres=X/postgres,authenticated=X/postgres}","config":["search_path=\"\""],"secdef":true,"volatility":"v","strict":false,"parallel":"u","language":"plpgsql","returns":"jsonb","arg_names":["p_substitution_option_id","p_request_key"],"arg_modes":null,"arg_types":"2950 2950","ddl_md5":"f2f454ef2248e5f310fdfade6e868657"}]}$compat_metadata$::jsonb;
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
 OR root#>>'{db_core,catalogo_families,3}'IS DISTINCT FROM '7c261e6fee5b1f608bb8bf4caccbf28e7f409eadd9e866165bbf65f27b9d411a'
 OR NOT EXISTS(SELECT 1 FROM jsonb_array_elements(root->'edge_bundles')b CROSS JOIN LATERAL jsonb_array_elements(b->'files')f WHERE b->>'name'='combat_narratore_ai'AND f->>'name'='facts.ts'AND f->>'sha256'='7c261e6fee5b1f608bb8bf4caccbf28e7f409eadd9e866165bbf65f27b9d411a')
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
 IF coalesce(root#>>'{db_core,velo_staff}','') NOT IN ('c3612c94016774b3457ea72312e9a1ef763caca10bcec2151a7a522980d13c13','2b98a9825dd12827a82d4bdfb367e27ddaa887de27c43d6c1260f0c7b05d5d8c')
  OR root#>'{config,velo_staff}' IS DISTINCT FROM root#>'{db_core,velo_staff}'
  OR (SELECT staff_enabled FROM clan_innata_combat_private.velo_staff_gate_v1 WHERE singleton)
      IS DISTINCT FROM (root#>>'{db_core,velo_staff}' = 'c3612c94016774b3457ea72312e9a1ef763caca10bcec2151a7a522980d13c13')
  OR EXISTS(SELECT 1 FROM jsonb_to_recordset($velo_leaf_functions$[{"signature":"clan_innata_combat_private.velo_action_turn_v1(uuid,uuid)","md5":"c98a0dbdf0b54c4b240bc16d3331c666"},{"signature":"clan_innata_combat_private.velo_control_choice_v1(uuid,uuid)","md5":"40db9b6876cdc5c357644f7c4886e0a3"},{"signature":"clan_innata_combat_private.velo_control_commit_v1(jsonb)","md5":"a41d2d4cc5cb6a8e7aa6b35542ec3337"},{"signature":"clan_innata_combat_private.velo_control_offers_v1(uuid,bigint)","md5":"4619836b461198a4f2feeb3557ca0d78"},{"signature":"clan_innata_combat_private.velo_freeze_declaration_v1(uuid)","md5":"ad92aeda67371814120c53a445b38dfa"},{"signature":"clan_innata_combat_private.velo_frozen_snapshot_v1(jsonb,uuid,uuid)","md5":"4fbfa40058b21ac6bf23bf31284892ad"},{"signature":"clan_innata_combat_private.velo_innata_scope_v1(uuid)","md5":"8f3d134a673d13dc640ebe33aa2e10b6"},{"signature":"clan_innata_combat_private.velo_profile_bound_v1(uuid)","md5":"43f8511dc5e87cb8069953212d5452e0"},{"signature":"clan_innata_combat_private.velo_staff_scope_v1(uuid)","md5":"58bcea50c7964b4357fd15b51364e322"},{"signature":"clan_innata_combat_private.velo_stat_delta_v1(uuid)","md5":"119f87ef4dc7481a07cce29b3ddca241"}]$velo_leaf_functions$::jsonb) AS e(signature text,md5 text)
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
 RETURN true;
END $function$;

CREATE OR REPLACE FUNCTION clan_innata_private.eligibility_release_assert()
 RETURNS void
 LANGUAGE plpgsql
 STABLE SECURITY DEFINER
 SET search_path TO 'pg_catalog', 'public', 'clan_innata_private'
AS $function$
declare v_marionetta boolean:=false; v_panel boolean:=false; v_catalogo boolean:=false; v_velo boolean:=false;
begin
 v_catalogo:=clan_innata_private.catalogo_eligibility_release_v1();
 v_velo:=v_catalogo AND EXISTS (
   SELECT 1 FROM mission_factory_owner.editor_release_readiness AS rr
   WHERE rr.singleton AND rr.canonical_preimage::jsonb#>>'{db_core,velo_staff}' IN ('c3612c94016774b3457ea72312e9a1ef763caca10bcec2151a7a522980d13c13','2b98a9825dd12827a82d4bdfb367e27ddaa887de27c43d6c1260f0c7b05d5d8c')
 );

 -- La porta pubblica aggiornata è ammessa solo insieme al suo producer
 -- originale privato e alla redazione esatta: corpi, autorità e ACL pinzati.
 with expected(sig,sha,acl) as(values ('public.combat_v2_round_options(uuid,uuid)','0b3acc15933027fa840ca03c0d02f082aecf6f2ccedcdefd737127bed1d853d1','authenticated:EXECUTE:false,postgres:EXECUTE:false,service_role:EXECUTE:false'),('combat_panel_private.round_options_authoritative(uuid,uuid)','879b5d69f1ca6a8f9cc28421699b77d649e3e277f4130a40308ca3acfc8a895c','postgres:EXECUTE:false'),('combat_panel_private.mask_native_state(jsonb)','1d2f6ad44b2ff1e9c15d897e38fee54b67c744411081f906bc33a26a42600dac','postgres:EXECUTE:false')),
 observed as(select e.*,p.oid,p.proowner,p.prosecdef,p.proconfig,
   case when p.oid is null then null else encode(extensions.digest(convert_to(pg_get_functiondef(p.oid),'UTF8'),'sha256'),'hex') end actual_sha,
   (select string_agg(coalesce(r.rolname,'PUBLIC')||':'||x.privilege_type||':'||x.is_grantable,',' order by coalesce(r.rolname,'PUBLIC'),x.privilege_type,x.is_grantable)
     from aclexplode(coalesce(p.proacl,acldefault('f',p.proowner))) x left join pg_roles r on r.oid=x.grantee) actual_acl
   from expected e left join pg_proc p on p.oid=to_regprocedure(e.sig))
 select count(*)=3 and bool_and(coalesce(oid is not null and actual_sha=sha and actual_acl=acl
   and proowner='postgres'::regrole and prosecdef and proconfig=array['search_path=""'],false))
 into v_panel from observed;
 IF v_catalogo THEN v_panel:=true;END IF;
 if exists(select 1 from supabase_migrations.schema_migrations where name='marionetta_ordinary_staff_001' or version='20260907084651') then
   if (select count(*) from supabase_migrations.schema_migrations where name='marionetta_ordinary_staff_001' or version='20260907084651')<>1
     or not exists(select 1 from supabase_migrations.schema_migrations where version='20260907084651' and name='marionetta_ordinary_staff_001'
       and cardinality(statements)=1 and encode(extensions.digest(convert_to(array_to_string(statements,''),'UTF8'),'sha256'),'hex')='3d3b6643c1b513728ee8e2366fbde983aa374cf9d330f0976d71c5f122318f17') then
     raise exception 'runtime_eligibility_marionetta_release_drift'; end if;
   v_marionetta:=true;
 end if;
 if (select count(*) from supabase_migrations.schema_migrations where version='20260902055751' and name='genin_elemental_eligibility_common_009' and cardinality(statements)=1 and encode(extensions.digest(convert_to(array_to_string(statements,''),'UTF8'),'sha256'),'hex')='e2ca4e296401307496cdc1ed108f4cf22ee4469a34072172c7b9855063a97c2e')<>1
 or (select count(*) from supabase_migrations.schema_migrations where version between '20260902005704' and '20260902055751')<>4
 or (select count(*) from supabase_migrations.schema_migrations where name='clan_genin_innata_common_release_seal_eligibility_018')>1
 or ((select count(*) from supabase_migrations.schema_migrations where name='clan_genin_innata_common_release_seal_eligibility_018')=0 and ((select count(*) from supabase_migrations.schema_migrations)<>452 or (select version from supabase_migrations.schema_migrations order by version desc limit 1) is distinct from '20260902055751'))
 or ((select count(*) from supabase_migrations.schema_migrations where name='clan_genin_innata_common_release_seal_eligibility_018')=1 and not exists(select 1 from supabase_migrations.schema_migrations where name='clan_genin_innata_common_release_seal_eligibility_018' and version~'^[0-9]{14}$' and version>'20260902055751' and cardinality(statements)=1))
 then raise exception 'runtime_eligibility_history_drift';end if;
 if to_regnamespace('combat_v2_elemental_internal') is null
 or (select count(*) from pg_proc p where p.pronamespace='combat_v2_elemental_internal'::regnamespace)<>91
 or (select pg_get_userbyid(n.nspowner)||'|'||coalesce(n.nspacl::text,'') from pg_namespace n where n.oid='combat_v2_elemental_internal'::regnamespace) is distinct from 'postgres|{postgres=UC/postgres,service_role=U/postgres}'
 then raise exception 'runtime_eligibility_schema_drift';end if;

 -- Rilascio Suiton verificato: insieme chiuso di 35 helper aggiuntivi.
 -- I due helper storici mantengono le verifiche originali sottostanti.
 if (select count(*) from supabase_migrations.schema_migrations
     where version='20260912191445' and name='elementali_staff_suiton_install_20260912_1912'
       and cardinality(statements)=1
       and encode(extensions.digest(convert_to(array_to_string(statements,''),'UTF8'),'sha256'),'hex')='e7bd1cb6dea7505399fc9dbce5b39ec5078eb9474f55990def7502a68fbbdb18')<>1
 then raise exception 'runtime_eligibility_suiton_release_drift';end if;
 if exists(
  with expected(sig,sha,definer) as(values
   ('combat_v2_elemental_internal.comparison_channels(uuid,uuid,uuid,jsonb,integer,uuid)', '4db77777b8277750fb1468b8789915facbf71864d81f2647dedad6a0d40f26f8', true),
   ('combat_v2_elemental_internal.comparison_reserve(uuid,uuid,uuid)', '712095a7757a2828bed68307408edba803169e8465b1f31b62e3b408b04749df', true),
   ('combat_v2_elemental_internal.suiton_ability_meta(uuid,jsonb)', '8856c83e2aac23fbac02b3fa893caf0f0809234bf8a7ff42aeac6b246db14838', true),
   ('combat_v2_elemental_internal.suiton_bind_source(uuid)', '1fd85f165e897d3e90ddb0f04bc2c5523b73587f26d1037e0ab45635ac1208f5', true),
   ('combat_v2_elemental_internal.suiton_commit_control(jsonb,jsonb)', 'aca8de9ce4d1caf737ea789d11aeb5de4e8a55be2840f4700eb0daaa8b5357dc', true),
   ('combat_v2_elemental_internal.suiton_commit_master_control(jsonb)', '8e3dc679cced28892d6270a5310d49b975b9da9e483cfff635140db331e0e43d', true),
   ('combat_v2_elemental_internal.suiton_consumer_options(jsonb)', '82231c040ab41b619f29616499fad90e6d6efebfc614bebe67e8b91c82081ca5', true),
   ('combat_v2_elemental_internal.suiton_control_apply(text,uuid,uuid,uuid)', '15c8ce32ece8af8c407bac7e46fbbb414184fd87bfb3e1238a3b4e461f43ba39', true),
   ('combat_v2_elemental_internal.suiton_control_target(text,uuid,uuid)', '83833b6ff5f114c3b870c3767565d00ea829bbf85f02606f034e197e4c37ab03', true),
   ('combat_v2_elemental_internal.suiton_declaration_meta(uuid,uuid,uuid,jsonb)', '7b13ed2ad7acc320c88350a5ec0fd2d9155614f51b5ea6682094e88e6bfbba36', true),
   ('combat_v2_elemental_internal.suiton_draw_range(uuid,uuid,boolean)', 'b178d00a882a8e2cff719795874d1a553e4478f0369ef6eb5a9ed4e20ccb71f4', true),
   ('combat_v2_elemental_internal.suiton_force_from_outcome(uuid,uuid)', 'aa3b68e633cc12f401505a6ba3492e92e94c44598940bf90e7c70473e90ca7f0', true),
   ('combat_v2_elemental_internal.suiton_geometry(uuid,uuid,boolean)', '422ce58f19b0c0d9692fbf639f409f54b45d054b6c3f01e580b8be1f43222288', true),
   ('combat_v2_elemental_internal.suiton_master_options(uuid,bigint)', 'a2359c02aaeb2192ecef01fae57d05f6fb548d0c245380494915427341499d5f', true),
   ('combat_v2_elemental_internal.suiton_meta(uuid)', '65375ebe226f598927e0873b228d0daaa9f239249f6b2e9196ad4ae5a2282f7b', true),
   ('combat_v2_elemental_internal.suiton_narrative_facts(uuid)', 'b6936b0bd08eee059ae94cffcdd3c2e7319b3aa6f7430e38a91bfc088cd49901', true),
   ('combat_v2_elemental_internal.suiton_narrative_projection(uuid)', 'd34e9dc4d467ab47f8a263d837b8f00d6f0f3f02c7b59d1b4063ce1aa7022276', true),
   ('combat_v2_elemental_internal.suiton_narrative_supported(uuid)', '660838edb1eef2ba8afbab180edf21ec295170aa36b0122e163fc17c59f42a48', true),
   ('combat_v2_elemental_internal.suiton_offer_label(uuid,jsonb,text)', '71ef19352a96939de8a8034cc821f79326a0d33eb0fa4c673a4aabe6f8aa1fe0', true),
   ('combat_v2_elemental_internal.suiton_ordinary_copy_offers(uuid,bigint,jsonb)', '3392390a180bee9b10b58495a32d889d05da52cfdec5611c47c7769599fbaef5', true),
   ('combat_v2_elemental_internal.suiton_png_owned(uuid,uuid)', 'b2d3877e7497adbdc4a76139d2627ac0744b192a0823d54dbc90afaabf6bd659', true),
   ('combat_v2_elemental_internal.suiton_prepare_callback(text,uuid,uuid,uuid,uuid[],jsonb,jsonb)', '973b09c57a37f9721e216f8dfd4b1e0dbfc29d80c8cb4615a175603366e36c87', true),
   ('combat_v2_elemental_internal.suiton_prepare_master(uuid,uuid,uuid[],jsonb,jsonb)', '9ef708a90471da085ffb0d804f31a010f021ce227d43b40060ecd8e7cb707b12', true),
   ('combat_v2_elemental_internal.suiton_prepare_native(uuid,uuid,uuid,jsonb,boolean,jsonb)', '1b5986868ba2679c2ebd8dbf824a22cee4190ec4c0e17852d089ab8093e78655', true),
   ('combat_v2_elemental_internal.suiton_prepare_ordinary(uuid,uuid,uuid)', 'b3c5628855bd2c213c268d209219559a362c67f399133e15186eaf3e78497ad3', true),
   ('combat_v2_elemental_internal.suiton_preset_ready(uuid,uuid)', 'c65ac30e5d1b1a8bf88ee73e636a15da683f9ae3f97c124ae9b5b9199a386ec7', true),
   ('combat_v2_elemental_internal.suiton_profile(uuid,uuid)', 'f8174ccbe1808bedc756e452c4fb8cf7cd9f9f6629fe627ed473b36d516a65c6', true),
   ('combat_v2_elemental_internal.suiton_quote(uuid,uuid)', '900157dfaaf19810d4d21a4138a9a63c77ae6cc460d0d296425556a6efa653a1', true),
   ('combat_v2_elemental_internal.suiton_source_valid(uuid)', 'd937562a6537b70bf92233e0f3a3182ff346a93c7a586d73139febe7370d5969', true),
   ('combat_v2_elemental_internal.suiton_staff_bind(uuid,uuid,uuid)', '09bcc66bf8d7cf5e5f04f41cc6b071841a6472d9cf45d750f789d679fdf3a576', true),
   ('combat_v2_elemental_internal.suiton_staff_binding(uuid,uuid)', 'fbbf2c198e245b92424046ed58bc79c7b2d4ff440e82722ab90187de89d20152', true),
   ('combat_v2_elemental_internal.suiton_substitution_available(uuid)', '7535c6c3c7366a23e22f697c5eb20bf8e3cd422208909881ab32327106b5ee1a', true),
   ('combat_v2_elemental_internal.suiton_substitution_options(jsonb)', '3d07b691098cdf4b698ed8822ab4c554de722a90d586b917dad59a0131fe3aaa', true),
   ('combat_v2_elemental_internal.suiton_target_visible(uuid,uuid,numeric)', '5eff813391e64689028888e8449b89abcf2486601428e72c5917e59ffb72769d', true),
   ('combat_v2_elemental_internal.technique_profile_v1(uuid)', '6446b74bbe092d8627820dc064d778aaf188eec6c7dd28e79e985843b995bd93', false)),
  observed as(select e.*,p.oid,p.proowner,p.prosecdef,p.proconfig,
   case when p.oid is null then null else encode(extensions.digest(convert_to(pg_get_functiondef(p.oid),'UTF8'),'sha256'),'hex') end actual_sha,
   (select string_agg(coalesce(r.rolname,'PUBLIC')||':'||x.privilege_type||':'||x.is_grantable,',' order by coalesce(r.rolname,'PUBLIC'),x.privilege_type,x.is_grantable)
    from aclexplode(coalesce(p.proacl,acldefault('f',p.proowner))) x left join pg_roles r on r.oid=x.grantee) actual_acl
   from expected e left join pg_proc p on p.oid=to_regprocedure(e.sig))
  select 1 from observed where oid is null or actual_sha is distinct from sha
   or proowner is distinct from 'postgres'::regrole or prosecdef is distinct from definer
   or proconfig is distinct from array['search_path=""']
   or actual_acl is distinct from 'postgres:EXECUTE:false'
 ) then raise exception 'runtime_eligibility_suiton_helper_drift';end if;

 if exists(
  with expected(sig,sha,acl) as(values
   ('combat_v2_elemental_internal.is_target_v1(uuid)','8af6bdfc87b76ed118b596f7c7885c6de849c5d89140f61cdd1845047cbd5724','postgres:EXECUTE:false,service_role:EXECUTE:false'),
   ('combat_v2_elemental_internal.eligible_v1(uuid,uuid,boolean)','a5161f2993a4e0ce51864ac67ea88ba3fa6966457da1caf4ca390f17c2b1d8e9','postgres:EXECUTE:false,service_role:EXECUTE:false'),
   ('public.combat_v2_character_snapshot(uuid)',CASE WHEN v_velo THEN '9d97f3d6acd6f723f82b51723be91d0a185ee1be1b8060f5bd9d41379d65ea1d' WHEN v_marionetta then '20c680c16a5ba1adedada1b9dcb6b5ee2f91bf01ddbdd9c0d40064d9d2d57ee3' else '323d6dd5a1cfac2ad6535fb73a4aefb03d33c7aa2894b9196489c17880046f87' end,'postgres:EXECUTE:false,service_role:EXECUTE:false'),
   ('public.combat_v2_actor_ability(uuid,text,uuid,boolean)',CASE WHEN v_velo THEN '31512f4525275b901ce810f8d23d15a3221091ae6a0f062c40a8d4232c038748' WHEN v_catalogo THEN '512afb87dcdaaae4c394ea5eff500bcbf12123dea43ee13588e84fb5c19563d8' ELSE 'cb9e81c2b23aedb968eafa00f15dc3de188e57a5e72f04805a2d0617934575a7'END,'postgres:EXECUTE:false,service_role:EXECUTE:false'),
   ('public.combat_v2_round_options(uuid,uuid)',case when v_panel then '0b3acc15933027fa840ca03c0d02f082aecf6f2ccedcdefd737127bed1d853d1' when v_marionetta then '6b9012a057baa9bc06b201ce6bcc5b8d8bb4a832ae9a462444c5e3ef55e0c8cb' else '3be90b0da7f02c826ffdfcd594d2132a4af9128291e3417278ad6adac88f6129' end,'authenticated:EXECUTE:false,postgres:EXECUTE:false,service_role:EXECUTE:false')),
  observed as(select e.*,encode(extensions.digest(convert_to(pg_get_functiondef(e.sig::regprocedure),'UTF8'),'sha256'),'hex') actual_sha,p.proowner,p.prosecdef,p.proconfig,(select string_agg(coalesce(r.rolname,'PUBLIC')||':'||x.privilege_type||':'||x.is_grantable,',' order by coalesce(r.rolname,'PUBLIC'),x.privilege_type,x.is_grantable) from aclexplode(coalesce(p.proacl,acldefault('f',p.proowner))) x left join pg_roles r on r.oid=x.grantee) actual_acl from expected e join pg_proc p on p.oid=e.sig::regprocedure)
  select 1 from observed where actual_sha is distinct from sha or actual_acl is distinct from acl or proowner<>'postgres'::regrole or not prosecdef or proconfig is distinct from array['search_path=""'])
 then raise exception 'runtime_eligibility_full_seal_drift';end if;
 if encode(extensions.digest(convert_to(pg_get_functiondef('public.character_elementi(uuid)'::regprocedure),'UTF8'),'sha256'),'hex') is distinct from '2e62fad3aa654ab452c516549ca82068dd33f6496a3c1e17e3a8c805a8ddacd7'
 then raise exception 'runtime_eligibility_character_elementi_drift';end if;

 IF EXISTS(WITH expected(sig,hash,sd) AS (VALUES ('combat_v2_elemental_internal.other_meta(uuid)','18a6130387a81b22c993feaaf2613612',true),('combat_v2_elemental_internal.other_staff_binding(uuid,uuid)','cb15a27f82e60cf2ace2f22de4ca1e73',true),('combat_v2_elemental_internal.other_png_owned(uuid,uuid)','1730fa382f3f2da21b05ba43e1876330',true),('combat_v2_elemental_internal.other_profile(uuid,uuid)',CASE WHEN v_catalogo THEN 'dd1e62e9052469fae4c98fed245c730a' ELSE 'f71b7422e1af07cfb2784137d5d05f03'END,true),('combat_v2_elemental_internal.other_ability_meta(uuid,jsonb)',CASE WHEN v_catalogo THEN 'aa3d6fe2cb785a3a132a7b281bdab70a' ELSE '07a3babec6e05865d9265b09c22d0859' END,true),('combat_v2_elemental_internal.other_staff_bind(uuid,uuid,uuid)','a4fb778f33ab73c31e63904f51299985',true),('combat_v2_elemental_internal.other_geometry(uuid,uuid,pg_catalog.bool)','8776c899d5534308eb256de2ba451ae8',true),('combat_v2_elemental_internal.other_prepare_native(uuid,uuid,uuid,jsonb,pg_catalog.bool,jsonb)',CASE WHEN v_catalogo THEN '6e54b476b36ca716cf8c14f33ef9667e' ELSE '0e93d6425a2e8a151765040279758310'END,true),('combat_v2_elemental_internal.other_declaration_meta(uuid,uuid,uuid,jsonb)','d37f38beb455ecfbcda7a63962013542',true),('combat_v2_elemental_internal.other_bind_source(uuid)','35714da91f1df0f2d90d5921099e1177',true),('combat_v2_elemental_internal.other_source_valid(uuid)','20b96bb421f4bfbd3eb74a33294a3080',true),('combat_v2_elemental_internal.other_prepare_ordinary(uuid,uuid,uuid)','bb260ba226bc3557058820bdd5cacc93',true),('combat_v2_elemental_internal.other_prepare_master(uuid,uuid,uuid[],jsonb,jsonb)','1159e41bd29afbed0f8a5e828a0a79de',true),('combat_v2_elemental_internal.other_preset_ready(uuid,uuid)','eda00ca66bd5e24d1ac8cd1e620bf9c4',true),('combat_v2_elemental_internal.other_quote(uuid,uuid)','d50b47aedacd9734f5561067a3d62ba8',true),('combat_v2_elemental_internal.other_target_visible(uuid,uuid,pg_catalog.numeric)','f4440fc78dec1369349183c0957b1d1e',true),('combat_v2_elemental_internal.other_offer_label(uuid,jsonb,text)','4d40c4838291ae873d83ee544a4b0044',true),('combat_v2_elemental_internal.other_draw_range(uuid,uuid,pg_catalog.bool)','4856b88270f39cc66a656ec4a679d8d3',true),('combat_v2_elemental_internal.other_substitution_available(uuid)','a89a389d107dc8ad30a007f25ef1981a',true),('combat_v2_elemental_internal.other_substitution_options(jsonb)','5c08c47feed36d8c9c7f2d44f2ab9309',true),('combat_v2_elemental_internal.other_consumer_options(jsonb)',CASE WHEN v_catalogo THEN '8423c49ce8a83f2b19361b82a53fa9f4' ELSE '204fe2a77ba4c45cc862113859836151'END,true),('combat_v2_elemental_internal.other_ordinary_copy_offers(uuid,pg_catalog.int8,jsonb)','00bec9479f3d07cac011cc6139e27ad1',true),('combat_v2_elemental_internal.other_master_options(uuid,pg_catalog.int8)',CASE WHEN v_catalogo THEN '0c79a6a78b76b9e9ef8028d75e514af7' ELSE '13cd420ffe7d757af62bc723f27ce8b3'END,true),('combat_v2_elemental_internal.other_control_target(text,uuid,uuid)',CASE WHEN v_catalogo THEN 'b1af00f3eab38ed9e74836c5441616d7' ELSE 'b811c5e103dd67321aa8a2e3c601efbf'END,true),('combat_v2_elemental_internal.other_control_apply(text,uuid,uuid,uuid)',CASE WHEN v_catalogo THEN '4cf97ca72ff52f1bd33445ba54c8dd16' ELSE '63e4716e93d126611ca0490fe218fc57'END,true),('combat_v2_elemental_internal.other_prepare_callback(text,uuid,uuid,uuid,uuid[],jsonb,jsonb)','44d80129a84b21ab9345adfb4864736f',true),('combat_v2_elemental_internal.other_commit_control(jsonb,jsonb)','21538535df526b17d42dc91c7a3d4013',true),('combat_v2_elemental_internal.other_commit_master_control(jsonb)','c1690a97d6d6398360a401098588e56a',true),('combat_v2_elemental_internal.other_comparison(uuid,uuid,jsonb,pg_catalog.int4)','3b918a70932e681e148f7a90028f2d1c',true),('combat_v2_elemental_internal.other_force_from_outcome(uuid,uuid)','429727092531f7f07cfa99e06c7808d6',true),('combat_v2_elemental_internal.other_narrative_supported(uuid)','4a0d496f8d0528005aa3309ed60e3d0b',true),('combat_v2_elemental_internal.other_narrative_projection(uuid)','8ff935d763f4e4aeac25c3d6d017ecd3',true),('combat_v2_elemental_internal.scudo_profile(uuid)','92cfb95b3f56d8249d56c7d574e38d26',true),('combat_v2_elemental_internal.scudo_prepare_defense(uuid,uuid,uuid,uuid,uuid,jsonb)','b5808b034b5a3bcf50b7bcb8336d212a',true),('combat_v2_elemental_internal.scudo_declaration_meta(uuid,uuid,uuid,uuid,jsonb)','c27749ce44a439b3d59361a59e2337e9',true),('combat_v2_elemental_internal.scudo_bind_source(uuid)','cb840b147ea888fbfa57e3e55be49697',true),('combat_v2_elemental_internal.scudo_source_valid(uuid)','eacac569a8408d9e081344eebe12f9e2',true),('combat_v2_elemental_internal.scudo_meta(uuid)','92d3214d9de700399b263d1ee9ba8f93',true),('combat_v2_elemental_internal.scudo_staff_binding(uuid,uuid)','bf78d306e9a024a88ab453b9e8317671',true),('combat_v2_elemental_internal.scudo_staff_bind(uuid,uuid,uuid)','5f0c851bc78380fd88f246ca65fdb7fe',true),('combat_v2_elemental_internal.scudo_preset_ready(uuid,uuid)','b822c5fd7f3b549d455bbbcbe9e985c5',true),('combat_v2_elemental_internal.scudo_control_target(text,uuid,uuid)','014ec28c115fd3712b43d4253ffc39a9',true),('combat_v2_elemental_internal.scudo_control_apply(text,uuid,uuid,uuid)','2730009defb70b8c045be6430f496967',true),('combat_v2_elemental_internal.scudo_commit_control(jsonb,jsonb)','8b86c31c9d637aeb01beeb1c2fa2d1e7',true),('combat_v2_elemental_internal.scudo_commit_master_control(jsonb)','9bde876c7796180ea80bea206fe5829f',true),('combat_v2_elemental_internal.scudo_ability_meta(uuid,jsonb)','029b589a7af1a873e58cd3435bee3343',true),('combat_v2_elemental_internal.scudo_quote(uuid)','5c768cd419a7166e6e23420d5af3164b',true),('combat_v2_elemental_internal.scudo_consumer_options(jsonb)','e84aa35091f26367645f35a8815c78b1',true),('combat_v2_elemental_internal.scudo_master_options(uuid,pg_catalog.int8)','33fb2ed8a14cb05a3414e7be89556659',true),('combat_v2_elemental_internal.scudo_prepare_native(uuid,uuid,uuid,uuid,jsonb)','df51b64ad4443f0acdde37fbfdd5284e',true),('combat_v2_elemental_internal.scudo_narrative(uuid)','c580ef1cdbaff1598a7863603aa5c9a3',true),('combat_v2_elemental_internal.scarica_contact_range(uuid,uuid)','f92feff3bb5167ba034931dcb3832f4e',true),('combat_v2_elemental_internal.scarica_contact_witness(uuid,uuid,uuid,uuid)','34fb9bc5836831510ebd6e300e60a408',true),('combat_v2_elemental_internal.scarica_source_contact_valid(uuid)','57ed0bac1c1d36d8fd259010ceab4538',true)) SELECT 1 FROM expected e LEFT JOIN pg_proc p ON p.oid=to_regprocedure(e.sig) WHERE p.oid IS NULL OR md5(p.prosrc) IS DISTINCT FROM e.hash OR p.prosecdef IS DISTINCT FROM e.sd OR p.proowner IS DISTINCT FROM 'postgres'::regrole OR p.proconfig IS DISTINCT FROM ARRAY['search_path=""'] OR p.proacl IS DISTINCT FROM '{postgres=X/postgres}'::aclitem[]) THEN RAISE EXCEPTION 'runtime_elemental_complete_helper_drift';END IF;
end $function$;


DO $velo_post$
#variable_conflict error
DECLARE

 rr mission_factory_owner.editor_release_readiness%ROWTYPE;
 prior_release mission_public_owner.release_admissions_v1%ROWTYPE;
 prior_qualification mission_public_owner.public_qualification_attestations_v1%ROWTYPE;
 review jsonb;
 generic_ezbr constant text:='9a6889802cfa17c99a556538cccd4ad7ef75274d32adccbc192c23d257aa3e76';

 namespace_uuid constant uuid:='9ebf5297-66c5-5a19-b35a-589b626e4a4f';
 old_root_sha constant text:='0fb538733f7010d36babf42f2ffa69432b16b8baa1e9bdea6d0b4ff6d447ae8d';
 new_root_sha constant text:='2bcaf1943d787202406fad30d0a628869df77aae792eaa38d089dea41f393e42';
 db_sha constant text:='95818740afca109e2512ff80879a5a1748165c8d92f49c85c2f422735f01a5a5';
 config_sha constant text:='8ff571fa9a29db2742046c26fbb3ac63d0ddbdb59314891d4a655f091f1fad54';
 root_text text:=current_setting('app.velo_root_candidate');
 root jsonb;
 params jsonb; content_row mission_public_owner.mission_content_admissions_v1%ROWTYPE;
 runtime_before jsonb; bindings jsonb; qualification jsonb; content_payload jsonb;
 profile_row record; content_request uuid; affected integer;
BEGIN
 review:=current_setting('app.velo_review')::jsonb;
 params:=$velo_p${"expected_mission_capabilities_sha256":"49fe134f561273f28e8071b63c45886341371b67d028f06e6b7d8f8d4108e817","compatibility":{"ref":"velo-staff-existing-missions-r2","sha256":"c3612c94016774b3457ea72312e9a1ef763caca10bcec2151a7a522980d13c13"}}$velo_p$::jsonb;
 root:=root_text::jsonb;

 IF EXISTS(SELECT 1 FROM jsonb_to_recordset($velo_headers$[{"sig":"combat_panel_private.master_options(uuid,uuid,bigint)","oid":"44940","src":"c3ae5fff837af5db1779970e73a414bd","sha":"50e37d3c5d1ec147b55c576ba33d3565bbf7b1d0dab143d46f11a92fba61dd10","abi":"ce730160f86c59e91d1a0a7deef8f8deeaf3d391ab86ea68d39782a6cd536022"},{"sig":"combat_panel_private.ordinary_options(uuid,uuid,bigint)","oid":"44669","src":"e1e6cd169797dc97d13aee366489d338","sha":"fd38e02203a115949f47babb317ac999fd1af3fd3da1379b423d718baa7fb99b","abi":"643e9950ea1e32cbf6277499719fa8f15fa7a0b7d05f54e12e75ef937be06ae6"},{"sig":"public.combat_panel_commit_v1(jsonb)","oid":"44808","src":"0b5a0ca3366bb6a302fcdfcddd306f48","sha":"bd6c5f84f3858f716e8578b856b226e4674fa8acc99493db4c9aa8589825bc23","abi":"e372b82c6e09185978269696be55e171660ff3dfe967336165aad4cda5b3ef03"},{"sig":"clan_innata_private.combat_activation_window(uuid,uuid)","oid":"48763","src":"05e73d85d678cb5b3200bc29b21c99a9","sha":"e3dc2954718ea40a2e0ef7a16d843d900abad3865026883f7dab66759826ed1f","abi":"9f2be91f9ba58d72824e9f1f94acbf904e60b51cf8ce5a6a085bb08f667030be"},{"sig":"clan_innata_private.combat_scope(uuid,uuid)","oid":"48765","src":"e12934f6fd0e74edf84dc08ade7855de","sha":"5a0faf548a56310862a158510339dee2de32b0b56ae8d5434c14bd8fe67ac6f7","abi":"dffecf3d30ec820085f38cefa4d4a8927dcf31671af742187bc9aa47703fd4c4"},{"sig":"clan_innata_private.combat_transition(uuid,uuid,text,uuid,bigint)","oid":"48770","src":"fdae855ce3462f4bbb21ec3da7105d59","sha":"6bb07db723dd303e909279f2c8ceff2efb67a0c9e2ff24bc5b8ddf0b909c948c","abi":"e4d484a489ecb1fc2d75b676f82b9aa44084920a65a1a30b48b0b3549c872d35"},{"sig":"combat_v2_multitarget_internal.sync_declaration()","oid":"39288","src":"c9efcd8d9408f1316df17105cbaf2281","sha":"7d57154681b95fad0e07c6993d87644044ee0d88a2aad5629a9f509c29e42c49","abi":"2a7ccf3c2542a9a82bf85c86e944a27ac329e52c5f4482f43db0e41c5ae90043"},{"sig":"public.combat_v2_round_resolve(uuid,uuid)","oid":"31331","src":"bbe708d2f06cb96681141fce45915c28","sha":"5f3da77cefe6005202d48130ebea85a934dceed2fa5fab2b8e929ac5b545ca57","abi":"1a8c5c3dbfab1c5ca0205bd5a0d6dd0d855a8f9650e4191094a4121a87835fc0"},{"sig":"combat_v2_multitarget_internal.resolve_parent(uuid,uuid,uuid,boolean)","oid":"39291","src":"9b278e6f9024b78be794aed4b23ca4ae","sha":"1e8bb54c30de47ac9fc9f53a5dbac3a77beac008e16ccb87e5974a50a123d55a","abi":"030493526444add376807fb621719ed92aae1d2123ee31c7f51ef80c2bc0d7ac"},{"sig":"clan_hyuga_private.rotation_attack_power_freeze(uuid)","oid":"51291","src":"ae3522f18c909b30c223e92f2882c838","sha":"2e912410b6770f58f08d10c5b6855553bc03e66461e59b9da8cdbe01da9d2eae","abi":"a282ba1d663a2562c8ff803a53862bccb7c55d9bcfcba335a25c63b65b6e282f"},{"sig":"clan_akimichi_private.common_attack_power_freeze_v1(uuid)","oid":"685921","src":"58ee8836c59cc9f28ff9f3ff94299153","sha":"b23e213b2e250a45aefc98df8e638e25d8c7c99ed1ef56f27e9f7921bdd568bd","abi":"3f0579083ae695c3f6796801bd244ba7b09d7f89fe34bcb1f89387d596ef1bd8"},{"sig":"combat_panel_private.movement_budget(uuid,uuid)","oid":"45001","src":"2e4848de4c59bfc1e1f460fbf329fb9c","sha":"64adc44afd5cddbc9e01c490069e2ecb3ddd1e99a448bd196d8cb5159c80f96d","abi":"2c6ab2d8a23b0b32e487b404aa7656953b872815ef262a49c45f023777ab3367"},{"sig":"clan_innata_private.combat_begin_turn(uuid)","oid":"45348","src":"b8de7335961eeceefa28b21469900cea","sha":"e18f42c8badcc6b943ac5e2beeff25ef3bc8986bfe4818a20817de2fea820599","abi":"f1d4529e49023b94937550724c4e57a4684402efa6f710a234c1492bfee17340"},{"sig":"clan_innata_private.combat_begin_turn(uuid,uuid)","oid":"48764","src":"74468122de46ceb379a579ba0eac75b1","sha":"80f6951f7b31b7fd7032213918129b1df51ad84b01f33c46129a1c39b966617d","abi":"a9251bdd618edb2d1b58752600ab26472bc54e664af3193a5b4952c45abaad06"},{"sig":"clan_innata_private.combat_terminal(uuid,text)","oid":"45347","src":"e5181a58a3fc736bf10a0e02dba3e348","sha":"c3fa79cb05581a2492b7f9df54d9e2f7effb99a057873180989534d5d2618530","abi":"4d5212d30963d1246daffd96bbc5319ce5d2fa9e73aec71adf9e1a734dee9097"},{"sig":"clan_innata_private.combat_terminal(uuid,uuid,text)","oid":"48768","src":"e472b9538e020d39a00472a890ebb706","sha":"d2f853e932f722554cc1c2c76c94be735190dea4a9505c0cbac607c1983dabf6","abi":"af9a577ba02e0a94922490532a92000d5cefbc016ffbc8d82b970862faeb07f0"},{"sig":"public.combat_v2_actor_ability(uuid,text,uuid,boolean)","oid":"31311","src":"2ec5e6a87514a1997100990dde420a62","sha":"31512f4525275b901ce810f8d23d15a3221091ae6a0f062c40a8d4232c038748","abi":"d6389fce6481a1ba0b34106c4583eb03404117c2ea8c88b395cfdd6c1da040d8"},{"sig":"public.combat_v2_character_snapshot(uuid)","oid":"31310","src":"c54182dff687852cf654e73408c9ac71","sha":"9d97f3d6acd6f723f82b51723be91d0a185ee1be1b8060f5bd9d41379d65ea1d","abi":"4f39724d600a2d16ec55572864d6963eb8bf892e84c390305b9a2dc8719cdf09"},{"sig":"public.test_room_user_techniques()","oid":"30222","src":"97b94d31899d0bdb8276f6ad53eea644","sha":"09dcf4bad36d9297e11a9f198060c4deec642f0e366bb7bb03b7445e74f90ed8","abi":"8f1ed10e342f59e1d5a60bfdca54da7ffb3d14d2b45f57c95210bb989f1aa43a"},{"sig":"combat_panel_private.master_actor_offers(uuid,bigint,jsonb,jsonb)","oid":"44936","src":"da0eec6d13a6c0379238533199e48f4e","sha":"e027f5d36a7a11d345224c6ee41c0325990fd24654d5da23c3ff505bb3912c42","abi":"fceda56eb2d5e085dfd66f4c401be6836c55a111bb000f111a53d304e8f5628e"},{"sig":"combat_panel_private.master_scene_lifecycle_trigger()","oid":"44994","src":"232595d7ae9724429f4b4f4d0f8a2402","sha":"1a2985e37a6aeaff616a4a851433841cbb8eb129ec301d019bc56514ecde455a","abi":"b1beed1b917da5326ece7870681ec0b8f4127bdb8ba16d6a982ab8b870ee0815"},{"sig":"clan_innata_private.catalogo_eligibility_release_v1()","oid":"684829","src":"9c17aacce8e7e38597cd0980d6ed533e","sha":"fa28712daea087bf2611f6d3167aa34576c04b0e598e084501a3033bcbdace27","abi":"7d2dcd85f468271ee5b86ca4cb359d8c8e0adcb8a08af8784f52c7d01ebdec5b"},{"sig":"clan_innata_private.eligibility_release_assert()","oid":"41419","src":"318083236b37a6573e00f7061e41588e","sha":"a195b9b8d0d0a353eaa7c17a9a092223a6cc642b64163cbcf09475312b08dbb1","abi":"7a319aa51034184281d8449c40422632bd7ad214b9f1ad005ba1b390511361ca"}]$velo_headers$::jsonb) AS expected(sig text,oid text,src text,sha text,abi text)
  LEFT JOIN pg_proc p ON p.oid=to_regprocedure(expected.sig)
  LEFT JOIN pg_language l ON l.oid=p.prolang
  WHERE p.oid::text IS DISTINCT FROM expected.oid OR md5(p.prosrc) IS DISTINCT FROM expected.src
   OR encode(extensions.digest(pg_get_functiondef(p.oid),'sha256'),'hex') IS DISTINCT FROM expected.sha
   OR public.combat_v2_sha256(jsonb_build_object('oid',p.oid::text,'owner',pg_get_userbyid(p.proowner),
 'acl',p.proacl::text,'config',p.proconfig,'security_definer',p.prosecdef,'strict',p.proisstrict,
 'volatile',p.provolatile::text,'parallel',p.proparallel::text,'kind',p.prokind::text,'language',l.lanname,
 'returns',pg_get_function_result(p.oid),'arg_types',p.proargtypes::text,'arg_names',p.proargnames,
 'arg_modes',p.proargmodes,'leakproof',p.proleakproof)) IS DISTINCT FROM expected.abi) THEN
  RAISE EXCEPTION 'VELO_AFTER_HEADER_OR_BODY_DRIFT';
 END IF;


 IF EXISTS (
 WITH relation_names(name) AS (VALUES ('clan_innata_combat_private.combat_state'::text),('public.combat_v2_actors'::text),('public.combat_v2_declarations'::text),('public.combat_v2_sessions'::text),('public.master_v2_sessions'::text)),
 relations AS (SELECT r.* FROM relation_names rn CROSS JOIN LATERAL (SELECT w.name,c.oid,c.relkind::text kind,c.relowner::regrole::text owner,c.relacl::text acl,c.relrowsecurity rls,c.relforcerowsecurity force_rls,
 (SELECT coalesce(jsonb_agg(jsonb_build_object('name',a.attname,'type',format_type(a.atttypid,a.atttypmod),'notnull',a.attnotnull,'default',pg_get_expr(d.adbin,d.adrelid))ORDER BY a.attnum),'[]'::jsonb)FROM pg_attribute a LEFT JOIN pg_attrdef d ON d.adrelid=a.attrelid AND d.adnum=a.attnum WHERE a.attrelid=c.oid AND a.attnum>0 AND NOT a.attisdropped)columns,
 (SELECT coalesce(jsonb_agg(jsonb_build_object('name',x.conname,'ddl',CASE WHEN x.conname='combat_state_technique_id_check' THEN regexp_replace(pg_get_constraintdef(x.oid),'[()[:space:]]','','g') ELSE pg_get_constraintdef(x.oid) END,'validated',x.convalidated)ORDER BY x.conname),'[]'::jsonb)FROM pg_constraint x WHERE x.conrelid=c.oid)constraints,
 (SELECT coalesce(jsonb_agg(jsonb_build_object('name',t.tgname,'enabled',t.tgenabled::text,'ddl',pg_get_triggerdef(t.oid),'function_md5',md5(pg_get_functiondef(t.tgfoid)))ORDER BY t.tgname),'[]'::jsonb)FROM pg_trigger t WHERE t.tgrelid=c.oid AND NOT t.tgisinternal)triggers,
 (SELECT coalesce(jsonb_agg(jsonb_build_object('name',x.polname,'command',x.polcmd::text,'permissive',x.polpermissive,'roles',to_jsonb(x.polroles),'using',pg_get_expr(x.polqual,x.polrelid),'with_check',pg_get_expr(x.polwithcheck,x.polrelid))ORDER BY x.polname),'[]'::jsonb)FROM pg_policy x WHERE x.polrelid=c.oid)policies,
 (SELECT coalesce(jsonb_agg(jsonb_build_object('name',x.indexrelid::regclass::text,'ddl',pg_get_indexdef(x.indexrelid))ORDER BY x.indexrelid::regclass::text),'[]'::jsonb)FROM pg_index x WHERE x.indrelid=c.oid)indexes,
 CASE WHEN c.relkind='v'THEN pg_get_viewdef(c.oid,true)END view FROM(SELECT rn.name::text name)w LEFT JOIN pg_class c ON c.oid=to_regclass(w.name)) r)
 SELECT 1 FROM jsonb_to_recordset($velo_rel_shapes$[{"name":"clan_innata_combat_private.combat_state","descriptor":{"acl":"{postgres=arwdDxtm/postgres}","oid":"45211","rls":true,"kind":"r","name":"clan_innata_combat_private.combat_state","view":null,"owner":"postgres","columns":[{"name":"session_id","type":"uuid","default":null,"notnull":true},{"name":"actor_id","type":"uuid","default":null,"notnull":true},{"name":"technique_id","type":"uuid","default":null,"notnull":true},{"name":"is_test","type":"boolean","default":null,"notnull":true},{"name":"active","type":"boolean","default":"false","notnull":true},{"name":"state_version","type":"bigint","default":"0","notnull":true},{"name":"activated_round_id","type":"uuid","default":null,"notnull":false},{"name":"last_upkeep_round_id","type":"uuid","default":null,"notnull":false}],"indexes":[{"ddl":"CREATE UNIQUE INDEX combat_state_pkey ON clan_innata_combat_private.combat_state USING btree (session_id, actor_id, technique_id)","name":"clan_innata_combat_private.combat_state_pkey"}],"policies":[],"triggers":[{"ddl":"CREATE TRIGGER byakugan_family_guard BEFORE INSERT OR UPDATE ON clan_innata_combat_private.combat_state FOR EACH ROW EXECUTE FUNCTION clan_innata_narrative_private.byakugan_family_guard_v1()","name":"byakugan_family_guard","enabled":"O","function_md5":"b056df94d5db4cd7472e71c031e29362"},{"ddl":"CREATE TRIGGER common_combat_canonical BEFORE INSERT OR UPDATE ON clan_innata_combat_private.combat_state FOR EACH ROW EXECUTE FUNCTION clan_innata_private.combat_state_guard()","name":"common_combat_canonical","enabled":"O","function_md5":"bf835cd2b9a7da124c5bb614f036aade"},{"ddl":"CREATE TRIGGER sabaku_clone_innata_off AFTER UPDATE OF active ON clan_innata_combat_private.combat_state FOR EACH ROW EXECUTE FUNCTION clan_sabaku_private.clone_lifecycle_trigger()","name":"sabaku_clone_innata_off","enabled":"O","function_md5":"d8187fc67f036ca0cb9a0cfcd5137eed"}],"force_rls":false,"constraints":[{"ddl":"FOREIGN KEY (activated_round_id) REFERENCES public.combat_v2_rounds(id)","name":"combat_state_activated_round_id_fkey","validated":true},{"ddl":"FOREIGN KEY (actor_id) REFERENCES public.combat_v2_actors(id)","name":"combat_state_actor_id_fkey","validated":true},{"ddl":"FOREIGN KEY (last_upkeep_round_id) REFERENCES public.combat_v2_rounds(id)","name":"combat_state_last_upkeep_round_id_fkey","validated":true},{"ddl":"PRIMARY KEY (session_id, actor_id, technique_id)","name":"combat_state_pkey","validated":true},{"ddl":"FOREIGN KEY (session_id) REFERENCES public.combat_v2_sessions(id)","name":"combat_state_session_id_fkey","validated":true},{"ddl":"CHECK ((state_version >= 0))","name":"combat_state_state_version_check","validated":true},{"ddl":"CHECKtechnique_id=ANYARRAY['001f907c-8f32-4758-8a16-ad1730e72c59'::uuid,'4056f62d-77f3-47f9-8ecb-9a7799682a9d'::uuid,'c11ecd52-43cd-479b-8d5d-08187beba56e'::uuid,'4a527ff2-0420-4da9-bc1f-5489c753b285'::uuid,'8e20bafe-cb3c-4967-b9c7-2a4bca694996'::uuid,'9b384de3-35f0-43c0-b145-94f985fa758a'::uuid,'a50808fa-e7cd-45ee-b4d4-33ad8c65d472'::uuid]ORtechnique_id=ANYARRAY['65b30dec-6f9f-459e-b78c-49173d74f251'::uuid,'f3673da7-42c9-497e-abe1-1c0982429f35'::uuid,'1ab6d359-f337-45ed-839c-4e626d2e2819'::uuid]ORtechnique_id='c9b261da-c9cd-40bb-8189-7b65ab5a1605'::uuidANDis_testISTRUE","name":"combat_state_technique_id_check","validated":true},{"ddl":"FOREIGN KEY (technique_id) REFERENCES public.clan_techniques(id)","name":"combat_state_technique_id_fkey","validated":true}]}},{"name":"public.combat_v2_actors","descriptor":{"acl":"{postgres=arwdDxtm/postgres,service_role=arwdDxtm/postgres}","oid":"30878","rls":true,"kind":"r","name":"public.combat_v2_actors","view":null,"owner":"postgres","columns":[{"name":"id","type":"uuid","default":"gen_random_uuid()","notnull":true},{"name":"session_id","type":"uuid","default":null,"notnull":true},{"name":"actor_kind","type":"text","default":null,"notnull":true},{"name":"character_id","type":"uuid","default":null,"notnull":false},{"name":"png_instance_id","type":"uuid","default":null,"notnull":false},{"name":"controller_user","type":"uuid","default":null,"notnull":false},{"name":"team_key","type":"text","default":null,"notnull":true},{"name":"state","type":"text","default":"'attivo'::text","notnull":true},{"name":"position_m","type":"integer","default":"0","notnull":true},{"name":"initiative_snapshot","type":"integer","default":null,"notnull":true},{"name":"mechanics_snapshot","type":"jsonb","default":null,"notnull":true},{"name":"controller_version","type":"bigint","default":"1","notnull":true},{"name":"created_at","type":"timestamp with time zone","default":"clock_timestamp()","notnull":true},{"name":"provider_instance_v1_id","type":"uuid","default":null,"notnull":false},{"name":"companion_id","type":"uuid","default":null,"notnull":false}],"indexes":[{"ddl":"CREATE INDEX combat_v2_actors_character_idx ON public.combat_v2_actors USING btree (character_id)","name":"public.combat_v2_actors_character_idx"},{"ddl":"CREATE INDEX combat_v2_actors_controller_idx ON public.combat_v2_actors USING btree (session_id, controller_user)","name":"public.combat_v2_actors_controller_idx"},{"ddl":"CREATE UNIQUE INDEX combat_v2_actors_pkey ON public.combat_v2_actors USING btree (id)","name":"public.combat_v2_actors_pkey"},{"ddl":"CREATE INDEX combat_v2_actors_png_instance_idx ON public.combat_v2_actors USING btree (png_instance_id)","name":"public.combat_v2_actors_png_instance_idx"},{"ddl":"CREATE INDEX combat_v2_actors_provider_instance_v1_idx ON public.combat_v2_actors USING btree (provider_instance_v1_id)","name":"public.combat_v2_actors_provider_instance_v1_idx"},{"ddl":"CREATE UNIQUE INDEX combat_v2_actors_session_companion_key ON public.combat_v2_actors USING btree (session_id, companion_id)","name":"public.combat_v2_actors_session_companion_key"},{"ddl":"CREATE UNIQUE INDEX combat_v2_actors_session_id_character_id_key ON public.combat_v2_actors USING btree (session_id, character_id)","name":"public.combat_v2_actors_session_id_character_id_key"},{"ddl":"CREATE UNIQUE INDEX combat_v2_actors_session_id_id_key ON public.combat_v2_actors USING btree (session_id, id)","name":"public.combat_v2_actors_session_id_id_key"},{"ddl":"CREATE UNIQUE INDEX combat_v2_actors_session_id_png_instance_id_key ON public.combat_v2_actors USING btree (session_id, png_instance_id)","name":"public.combat_v2_actors_session_id_png_instance_id_key"},{"ddl":"CREATE UNIQUE INDEX combat_v2_actors_session_provider_v1_key ON public.combat_v2_actors USING btree (session_id, provider_instance_v1_id)","name":"public.combat_v2_actors_session_provider_v1_key"}],"policies":[],"triggers":[{"ddl":"CREATE TRIGGER aburame_actor_end AFTER UPDATE OF state ON public.combat_v2_actors FOR EACH ROW EXECUTE FUNCTION clan_aburame_private.lifecycle()","name":"aburame_actor_end","enabled":"O","function_md5":"5253ea25e74221595839caa71454cc92"},{"ddl":"CREATE TRIGGER aburame_verme_end_actor_v1 AFTER UPDATE OF state ON public.combat_v2_actors FOR EACH ROW EXECUTE FUNCTION clan_aburame_private.verme_end_context_v1()","name":"aburame_verme_end_actor_v1","enabled":"O","function_md5":"8305ad7a81146dae9a9a24566f933c62"},{"ddl":"CREATE TRIGGER combat_gate_v2_actor_engagement BEFORE INSERT ON public.combat_v2_actors FOR EACH ROW EXECUTE FUNCTION combat_gate_private.engagement_insert_guard()","name":"combat_gate_v2_actor_engagement","enabled":"O","function_md5":"28bc96f74f3215a29f5d7c0bd4179668"},{"ddl":"CREATE TRIGGER ehm_continuity_actor_guard BEFORE INSERT OR DELETE OR UPDATE ON public.combat_v2_actors FOR EACH ROW EXECUTE FUNCTION exam_human_private.continuity_session_guard_v1()","name":"ehm_continuity_actor_guard","enabled":"O","function_md5":"952113aad8265aa0cc6ecb47c76711f8"},{"ddl":"CREATE TRIGGER hyuga_sedici_actor_end AFTER UPDATE OF state ON public.combat_v2_actors FOR EACH ROW EXECUTE FUNCTION clan_hyuga_private.sedici_lifecycle()","name":"hyuga_sedici_actor_end","enabled":"O","function_md5":"49ac3dc34e918726db3ef05a2203f78b"},{"ddl":"CREATE TRIGGER mission_academy_prevent_ko BEFORE UPDATE OF mechanics_snapshot, state ON public.combat_v2_actors FOR EACH ROW EXECUTE FUNCTION mission_academy_owner.prevent_ko()","name":"mission_academy_prevent_ko","enabled":"O","function_md5":"951a02380ecbe367665a8ca925f5574d"},{"ddl":"CREATE TRIGGER panel_actor_controller_sync AFTER UPDATE OF controller_user, controller_version ON public.combat_v2_actors FOR EACH ROW EXECUTE FUNCTION combat_panel_private.master_scene_lifecycle_trigger()","name":"panel_actor_controller_sync","enabled":"O","function_md5":"95e0c0559898f60c848996e84a845a7c"},{"ddl":"CREATE TRIGGER panel_actor_entry BEFORE INSERT OR UPDATE OF session_id, actor_kind, character_id, controller_user, companion_id ON public.combat_v2_actors FOR EACH ROW EXECUTE FUNCTION combat_panel_private.master_entry_trigger()","name":"panel_actor_entry","enabled":"O","function_md5":"d4a3102cb9908464cc08be0b263d9d6f"},{"ddl":"CREATE TRIGGER panel_actor_turn_actor AFTER INSERT OR UPDATE OF state ON public.combat_v2_actors FOR EACH ROW EXECUTE FUNCTION combat_panel_private.actor_turn_lifecycle()","name":"panel_actor_turn_actor","enabled":"O","function_md5":"50eebd47ec1b7c58054ac06644974eeb"},{"ddl":"CREATE TRIGGER panel_immobilization_actor_end AFTER UPDATE OF state ON public.combat_v2_actors FOR EACH ROW EXECUTE FUNCTION combat_panel_private.immobilization_actor_lifecycle()","name":"panel_immobilization_actor_end","enabled":"O","function_md5":"f8677e282d09ca9015c01de07391f1bc"},{"ddl":"CREATE TRIGGER panel_multiplication_actor_end AFTER UPDATE OF state, mechanics_snapshot ON public.combat_v2_actors FOR EACH ROW EXECUTE FUNCTION combat_panel_private.multiplication_actor_end()","name":"panel_multiplication_actor_end","enabled":"O","function_md5":"390e5a2262affd6c56270631bdcf6232"},{"ddl":"CREATE TRIGGER riuji_parallel_combat_actor_guard BEFORE INSERT OR UPDATE OF state, character_id, session_id ON public.combat_v2_actors FOR EACH ROW EXECUTE FUNCTION mission_riuji_owner.combat_actor_guard()","name":"riuji_parallel_combat_actor_guard","enabled":"O","function_md5":"cadc0fea465b158223d9e5cc70a73301"},{"ddl":"CREATE TRIGGER sabaku_actor_lifecycle AFTER UPDATE OF state, mechanics_snapshot ON public.combat_v2_actors FOR EACH ROW EXECUTE FUNCTION clan_sabaku_private.actor_lifecycle()","name":"sabaku_actor_lifecycle","enabled":"O","function_md5":"395822d8985049c7e4c3a11c300b6d7f"},{"ddl":"CREATE TRIGGER sabaku_armor_actor_terminal AFTER UPDATE OF state, mechanics_snapshot ON public.combat_v2_actors FOR EACH ROW EXECUTE FUNCTION clan_sabaku_private.armor_actor_terminal()","name":"sabaku_armor_actor_terminal","enabled":"O","function_md5":"2371908f08a459bcaba40a82cf094107"},{"ddl":"CREATE TRIGGER sabaku_clone_actor_end AFTER UPDATE OF state, mechanics_snapshot ON public.combat_v2_actors FOR EACH ROW EXECUTE FUNCTION clan_sabaku_private.clone_lifecycle_trigger()","name":"sabaku_clone_actor_end","enabled":"O","function_md5":"d8187fc67f036ca0cb9a0cfcd5137eed"}],"force_rls":true,"constraints":[{"ddl":"CHECK ((actor_kind = ANY (ARRAY['pg'::text, 'png'::text])))","name":"combat_v2_actors_actor_kind_check","validated":true},{"ddl":"FOREIGN KEY (character_id) REFERENCES public.characters(id) ON DELETE RESTRICT","name":"combat_v2_actors_character_id_fkey","validated":true},{"ddl":"FOREIGN KEY (companion_id) REFERENCES clan_marionettisti_private.sources(id) ON DELETE RESTRICT","name":"combat_v2_actors_companion_id_fkey","validated":true},{"ddl":"CHECK (((actor_kind = 'png'::text) OR (controller_user IS NOT NULL)))","name":"combat_v2_actors_controller_chk","validated":true},{"ddl":"CHECK ((((actor_kind = 'pg'::text) AND (character_id IS NOT NULL) AND (png_instance_id IS NULL) AND (provider_instance_v1_id IS NULL) AND (companion_id IS NULL)) OR ((actor_kind = 'png'::text) AND (character_id IS NULL) AND (num_nonnulls(png_instance_id, provider_instance_v1_id, companion_id) = 1))))","name":"combat_v2_actors_identity_chk","validated":true},{"ddl":"CHECK ((jsonb_typeof(mechanics_snapshot) = 'object'::text))","name":"combat_v2_actors_mechanics_snapshot_check","validated":true},{"ddl":"PRIMARY KEY (id)","name":"combat_v2_actors_pkey","validated":true},{"ddl":"FOREIGN KEY (png_instance_id) REFERENCES public.combat_v2_png_instances(id) ON DELETE RESTRICT","name":"combat_v2_actors_png_instance_id_fkey","validated":true},{"ddl":"CHECK (((position_m >= 0) AND (position_m <= 1000)))","name":"combat_v2_actors_position_m_check","validated":true},{"ddl":"FOREIGN KEY (provider_instance_v1_id) REFERENCES public.combat_v2_provider_instances_v1(id) ON DELETE RESTRICT","name":"combat_v2_actors_provider_instance_v1_fkey","validated":true},{"ddl":"UNIQUE (session_id, companion_id)","name":"combat_v2_actors_session_companion_key","validated":true},{"ddl":"UNIQUE (session_id, character_id)","name":"combat_v2_actors_session_id_character_id_key","validated":true},{"ddl":"FOREIGN KEY (session_id) REFERENCES public.combat_v2_sessions(id) ON DELETE RESTRICT","name":"combat_v2_actors_session_id_fkey","validated":true},{"ddl":"UNIQUE (session_id, id)","name":"combat_v2_actors_session_id_id_key","validated":true},{"ddl":"UNIQUE (session_id, png_instance_id)","name":"combat_v2_actors_session_id_png_instance_id_key","validated":true},{"ddl":"UNIQUE (session_id, provider_instance_v1_id)","name":"combat_v2_actors_session_provider_v1_key","validated":true},{"ddl":"CHECK ((state = ANY (ARRAY['attivo'::text, 'fuori'::text, 'ritirato'::text])))","name":"combat_v2_actors_state_check","validated":true},{"ddl":"CHECK (((char_length(btrim(team_key)) >= 1) AND (char_length(btrim(team_key)) <= 40)))","name":"combat_v2_actors_team_key_check","validated":true}]}},{"name":"public.combat_v2_declarations","descriptor":{"acl":"{postgres=arwdDxtm/postgres,service_role=arwdDxtm/postgres}","oid":"30948","rls":true,"kind":"r","name":"public.combat_v2_declarations","view":null,"owner":"postgres","columns":[{"name":"id","type":"uuid","default":"gen_random_uuid()","notnull":true},{"name":"round_id","type":"uuid","default":null,"notnull":true},{"name":"actor_id","type":"uuid","default":null,"notnull":true},{"name":"kind","type":"text","default":null,"notnull":true},{"name":"parent_attack_id","type":"uuid","default":null,"notnull":false},{"name":"target_actor_id","type":"uuid","default":null,"notnull":false},{"name":"sanitized_intent","type":"jsonb","default":null,"notnull":true},{"name":"declaration_text","type":"text","default":"''::text","notnull":true},{"name":"controller_user_snapshot","type":"uuid","default":null,"notnull":true},{"name":"controller_version_snapshot","type":"bigint","default":null,"notnull":true},{"name":"request_key","type":"uuid","default":null,"notnull":true},{"name":"state","type":"text","default":"'inviata'::text","notnull":true},{"name":"outcome","type":"jsonb","default":null,"notnull":false},{"name":"order_no","type":"integer","default":null,"notnull":false},{"name":"tie_break","type":"bigint","default":null,"notnull":false},{"name":"cost_snapshot","type":"jsonb","default":"'{}'::jsonb","notnull":true},{"name":"created_at","type":"timestamp with time zone","default":"clock_timestamp()","notnull":true},{"name":"frozen_at","type":"timestamp with time zone","default":null,"notnull":false}],"indexes":[{"ddl":"CREATE INDEX combat_v2_declarations_actor_idx ON public.combat_v2_declarations USING btree (actor_id)","name":"public.combat_v2_declarations_actor_idx"},{"ddl":"CREATE UNIQUE INDEX combat_v2_declarations_difesa_idx ON public.combat_v2_declarations USING btree (parent_attack_id, actor_id) WHERE (kind = ANY (ARRAY['difesa'::text, 'nessuna'::text]))","name":"public.combat_v2_declarations_difesa_idx"},{"ddl":"CREATE UNIQUE INDEX combat_v2_declarations_pkey ON public.combat_v2_declarations USING btree (id)","name":"public.combat_v2_declarations_pkey"},{"ddl":"CREATE UNIQUE INDEX combat_v2_declarations_principale_idx ON public.combat_v2_declarations USING btree (round_id, actor_id) WHERE (kind = ANY (ARRAY['attacco'::text, 'movimento'::text, 'utilita'::text, 'passa'::text]))","name":"public.combat_v2_declarations_principale_idx"},{"ddl":"CREATE UNIQUE INDEX combat_v2_declarations_round_id_request_key_key ON public.combat_v2_declarations USING btree (round_id, request_key)","name":"public.combat_v2_declarations_round_id_request_key_key"},{"ddl":"CREATE INDEX combat_v2_declarations_round_order_idx ON public.combat_v2_declarations USING btree (round_id, order_no)","name":"public.combat_v2_declarations_round_order_idx"},{"ddl":"CREATE INDEX combat_v2_declarations_target_idx ON public.combat_v2_declarations USING btree (target_actor_id)","name":"public.combat_v2_declarations_target_idx"}],"policies":[],"triggers":[{"ddl":"CREATE TRIGGER aburame_bind_declaration AFTER INSERT ON public.combat_v2_declarations FOR EACH ROW EXECUTE FUNCTION clan_aburame_private.bind_declaration()","name":"aburame_bind_declaration","enabled":"O","function_md5":"88de13aaa8d8f15547754c11b0f762dc"},{"ddl":"CREATE TRIGGER combat_v2_declarations_multitarget_sync AFTER INSERT ON public.combat_v2_declarations FOR EACH ROW EXECUTE FUNCTION combat_v2_multitarget_internal.sync_declaration()","name":"combat_v2_declarations_multitarget_sync","enabled":"O","function_md5":"57425688322ab5f43182bfe0597a4ac1"},{"ddl":"CREATE TRIGGER cure_turn_defense_guard_v1 BEFORE INSERT ON public.combat_v2_declarations FOR EACH ROW EXECUTE FUNCTION combat_panel_private.cure_defense_guard_v1()","name":"cure_turn_defense_guard_v1","enabled":"O","function_md5":"139cfbb96fd7a9bd3cfe0326c3ca8292"},{"ddl":"CREATE TRIGGER ehm_round_declaration_guard BEFORE INSERT ON public.combat_v2_declarations FOR EACH ROW EXECUTE FUNCTION exam_human_private.round_declaration_guard_v1()","name":"ehm_round_declaration_guard","enabled":"O","function_md5":"12d6750967b54533ccf98b2b8f7f3974"},{"ddl":"CREATE CONSTRAINT TRIGGER event42_hint_combat_v2_declarations AFTER INSERT OR DELETE OR UPDATE ON public.combat_v2_declarations DEFERRABLE INITIALLY DEFERRED FOR EACH ROW EXECUTE FUNCTION mission_generic_owner.event_capture_v1('hint')","name":"event42_hint_combat_v2_declarations","enabled":"O","function_md5":"9b0b9bef1a608e974a6bee1e9d288feb"},{"ddl":"CREATE TRIGGER event42_pg_declaration AFTER INSERT ON public.combat_v2_declarations FOR EACH ROW EXECUTE FUNCTION mission_generic_owner.event_capture_v1('ai')","name":"event42_pg_declaration","enabled":"O","function_md5":"9b0b9bef1a608e974a6bee1e9d288feb"},{"ddl":"CREATE TRIGGER facing_completed_action AFTER UPDATE OF state ON public.combat_v2_declarations FOR EACH ROW EXECUTE FUNCTION combat_facing_private.completed_action()","name":"facing_completed_action","enabled":"O","function_md5":"124c1f2318c514378ce3d1d759f1bb9c"},{"ddl":"CREATE TRIGGER marionetta_terminal_event AFTER UPDATE OF state ON public.combat_v2_declarations FOR EACH ROW EXECUTE FUNCTION clan_marionettisti_private.declaration_terminal_trigger()","name":"marionetta_terminal_event","enabled":"O","function_md5":"0c3e1b7ebd7eec9eb55ab36ddc08915c"},{"ddl":"CREATE TRIGGER panel_actor_turn_declaration AFTER INSERT OR UPDATE OF state ON public.combat_v2_declarations FOR EACH ROW EXECUTE FUNCTION combat_panel_private.actor_turn_lifecycle()","name":"panel_actor_turn_declaration","enabled":"O","function_md5":"50eebd47ec1b7c58054ac06644974eeb"},{"ddl":"CREATE TRIGGER panel_declaration_ready BEFORE INSERT OR UPDATE OF round_id, actor_id, kind ON public.combat_v2_declarations FOR EACH ROW EXECUTE FUNCTION combat_panel_private.master_entry_trigger()","name":"panel_declaration_ready","enabled":"O","function_md5":"d4a3102cb9908464cc08be0b263d9d6f"},{"ddl":"CREATE TRIGGER panel_multiplication_assault_end AFTER UPDATE OF state ON public.combat_v2_declarations FOR EACH ROW EXECUTE FUNCTION combat_panel_private.multiplication_assault_end()","name":"panel_multiplication_assault_end","enabled":"O","function_md5":"16ac1cebd0b314a09d07f8e93e764104"},{"ddl":"CREATE TRIGGER panel_multiplication_next_action BEFORE INSERT ON public.combat_v2_declarations FOR EACH ROW EXECUTE FUNCTION combat_panel_private.multiplication_next_action()","name":"panel_multiplication_next_action","enabled":"O","function_md5":"1be8d365734c37dda8de7bf54c694cb8"},{"ddl":"CREATE TRIGGER regia_human_private_declaration_guard_v1 BEFORE INSERT ON public.combat_v2_declarations FOR EACH ROW EXECUTE FUNCTION mission_generic_owner.regia_human_declaration_guard_v1()","name":"regia_human_private_declaration_guard_v1","enabled":"O","function_md5":"fbb2af1f53dc44eccb448b88d9db8839"},{"ddl":"CREATE TRIGGER regia_round_declaration_revision_v1 AFTER INSERT OR UPDATE OF sanitized_intent, target_actor_id, declaration_text ON public.combat_v2_declarations FOR EACH ROW EXECUTE FUNCTION exam_human_private.round_publication_revision_bump_v1()","name":"regia_round_declaration_revision_v1","enabled":"O","function_md5":"e1fc682dbc655327408f79fbcf11a2e2"},{"ddl":"CREATE TRIGGER sabaku_master_main BEFORE INSERT ON public.combat_v2_declarations FOR EACH ROW EXECUTE FUNCTION clan_sabaku_private.master_turn_lifecycle()","name":"sabaku_master_main","enabled":"O","function_md5":"2b497ca1230e6642f49d9e65df2ed86b"},{"ddl":"CREATE TRIGGER shuriken_qa_declaration_guard BEFORE INSERT ON public.combat_v2_declarations FOR EACH ROW EXECUTE FUNCTION combat_panel_private.shuriken_qa_declaration_guard_v1()","name":"shuriken_qa_declaration_guard","enabled":"O","function_md5":"b87c0e84252a083ebf72051e34bc0078"},{"ddl":"CREATE TRIGGER zz_innata_chat_tags_snapshot BEFORE INSERT ON public.combat_v2_declarations FOR EACH ROW EXECUTE FUNCTION clan_innata_private.freeze_chat_tags()","name":"zz_innata_chat_tags_snapshot","enabled":"O","function_md5":"30ddee68343d405a201ffb237b965cff"},{"ddl":"CREATE TRIGGER zz_marionetta_staff_sever BEFORE INSERT ON public.combat_v2_declarations FOR EACH ROW WHEN ((new.kind = 'attacco'::text)) EXECUTE FUNCTION clan_marionettisti_private.staff_sever_declaration_v1()","name":"zz_marionetta_staff_sever","enabled":"D","function_md5":"b90160271b98f7039cd2fc46756efea8"},{"ddl":"CREATE TRIGGER zz_marionetta_staff_sever_capture AFTER INSERT ON public.combat_v2_declarations FOR EACH ROW WHEN (((new.sanitized_intent #>> '{server_ability,link_control_traits,staff_simulated}'::text[]) = 'true'::text)) EXECUTE FUNCTION clan_marionettisti_private.staff_sever_capture_v1()","name":"zz_marionetta_staff_sever_capture","enabled":"O","function_md5":"d2c073dbc65945d8bfd7de36563eda9d"}],"force_rls":true,"constraints":[{"ddl":"FOREIGN KEY (actor_id) REFERENCES public.combat_v2_actors(id) ON DELETE RESTRICT","name":"combat_v2_declarations_actor_id_fkey","validated":true},{"ddl":"CHECK ((jsonb_typeof(cost_snapshot) = 'object'::text))","name":"combat_v2_declarations_cost_snapshot_check","validated":true},{"ddl":"CHECK ((char_length(declaration_text) <= 5000))","name":"combat_v2_declarations_declaration_text_check","validated":true},{"ddl":"CHECK ((kind = ANY (ARRAY['attacco'::text, 'difesa'::text, 'movimento'::text, 'utilita'::text, 'passa'::text, 'nessuna'::text])))","name":"combat_v2_declarations_kind_check","validated":true},{"ddl":"FOREIGN KEY (parent_attack_id) REFERENCES public.combat_v2_declarations(id) ON DELETE RESTRICT","name":"combat_v2_declarations_parent_attack_id_fkey","validated":true},{"ddl":"CHECK (((kind = ANY (ARRAY['difesa'::text, 'nessuna'::text])) = (parent_attack_id IS NOT NULL)))","name":"combat_v2_declarations_parent_chk","validated":true},{"ddl":"PRIMARY KEY (id)","name":"combat_v2_declarations_pkey","validated":true},{"ddl":"FOREIGN KEY (round_id) REFERENCES public.combat_v2_rounds(id) ON DELETE RESTRICT","name":"combat_v2_declarations_round_id_fkey","validated":true},{"ddl":"UNIQUE (round_id, request_key)","name":"combat_v2_declarations_round_id_request_key_key","validated":true},{"ddl":"CHECK ((jsonb_typeof(sanitized_intent) = 'object'::text))","name":"combat_v2_declarations_sanitized_intent_check","validated":true},{"ddl":"CHECK ((state = ANY (ARRAY['bozza_server'::text, 'inviata'::text, 'congelata'::text, 'risolta'::text, 'superflua'::text])))","name":"combat_v2_declarations_state_check","validated":true},{"ddl":"FOREIGN KEY (target_actor_id) REFERENCES public.combat_v2_actors(id) ON DELETE RESTRICT","name":"combat_v2_declarations_target_actor_id_fkey","validated":true},{"ddl":"CHECK (((kind <> 'attacco'::text) OR (target_actor_id IS NOT NULL)))","name":"combat_v2_declarations_target_chk","validated":true},{"ddl":"TRIGGER DEFERRABLE INITIALLY DEFERRED","name":"event42_hint_combat_v2_declarations","validated":true}]}},{"name":"public.combat_v2_sessions","descriptor":{"acl":"{postgres=arwdDxtm/postgres,service_role=arwdDxtm/postgres}","oid":"30825","rls":true,"kind":"r","name":"public.combat_v2_sessions","view":null,"owner":"postgres","columns":[{"name":"id","type":"uuid","default":"gen_random_uuid()","notnull":true},{"name":"source_kind","type":"text","default":null,"notnull":true},{"name":"master_session_id","type":"uuid","default":null,"notnull":false},{"name":"location_id","type":"uuid","default":null,"notnull":true},{"name":"state","type":"text","default":"'preparazione'::text","notnull":true},{"name":"state_before_suspend","type":"text","default":null,"notnull":false},{"name":"engine_version","type":"text","default":"'combat-v2/2.0.0'::text","notnull":true},{"name":"resolver_version","type":"text","default":"'v11-parity/1'::text","notnull":true},{"name":"lesiva","type":"boolean","default":"false","notnull":true},{"name":"created_at","type":"timestamp with time zone","default":"clock_timestamp()","notnull":true},{"name":"closed_at","type":"timestamp with time zone","default":null,"notnull":false},{"name":"user_test_context_id","type":"uuid","default":null,"notnull":false}],"indexes":[{"ddl":"CREATE INDEX combat_v2_sessions_master_idx ON public.combat_v2_sessions USING btree (master_session_id)","name":"public.combat_v2_sessions_master_idx"},{"ddl":"CREATE UNIQUE INDEX combat_v2_sessions_pkey ON public.combat_v2_sessions USING btree (id)","name":"public.combat_v2_sessions_pkey"},{"ddl":"CREATE UNIQUE INDEX combat_v2_sessions_unica_luogo_idx ON public.combat_v2_sessions USING btree (location_id) WHERE ((state <> ALL (ARRAY['chiuso'::text, 'annullato'::text])) AND (user_test_context_id IS NULL))","name":"public.combat_v2_sessions_unica_luogo_idx"},{"ddl":"CREATE UNIQUE INDEX user_test_session_binding_unique ON public.combat_v2_sessions USING btree (user_test_context_id) WHERE (user_test_context_id IS NOT NULL)","name":"public.user_test_session_binding_unique"}],"policies":[],"triggers":[{"ddl":"CREATE TRIGGER aburame_session_end AFTER UPDATE OF state, closed_at ON public.combat_v2_sessions FOR EACH ROW EXECUTE FUNCTION clan_aburame_private.lifecycle()","name":"aburame_session_end","enabled":"O","function_md5":"5253ea25e74221595839caa71454cc92"},{"ddl":"CREATE TRIGGER aburame_verme_end_session_v1 AFTER UPDATE OF state, closed_at ON public.combat_v2_sessions FOR EACH ROW EXECUTE FUNCTION clan_aburame_private.verme_end_context_v1()","name":"aburame_verme_end_session_v1","enabled":"O","function_md5":"8305ad7a81146dae9a9a24566f933c62"},{"ddl":"CREATE TRIGGER combat_gate_v2_claim BEFORE INSERT OR UPDATE OF state, location_id, source_kind, master_session_id ON public.combat_v2_sessions FOR EACH ROW EXECUTE FUNCTION combat_gate_private.v2_claim_trigger()","name":"combat_gate_v2_claim","enabled":"O","function_md5":"d1d386dc90cceb83d49ab2b24b97876e"},{"ddl":"CREATE TRIGGER ehm_continuity_session_guard BEFORE INSERT OR UPDATE ON public.combat_v2_sessions FOR EACH ROW EXECUTE FUNCTION exam_human_private.continuity_session_guard_v1()","name":"ehm_continuity_session_guard","enabled":"O","function_md5":"952113aad8265aa0cc6ecb47c76711f8"},{"ddl":"CREATE TRIGGER exam_human_no_uncomposed_encounter BEFORE INSERT OR UPDATE OF master_session_id ON public.combat_v2_sessions FOR EACH ROW EXECUTE FUNCTION exam_human_private.native_lifecycle_guard_v1()","name":"exam_human_no_uncomposed_encounter","enabled":"O","function_md5":"6b96e5306bc421a9a6cc3baabfaaa0fb"},{"ddl":"CREATE TRIGGER hyuga_sedici_session_end AFTER UPDATE OF state, closed_at ON public.combat_v2_sessions FOR EACH ROW EXECUTE FUNCTION clan_hyuga_private.sedici_lifecycle()","name":"hyuga_sedici_session_end","enabled":"O","function_md5":"49ac3dc34e918726db3ef05a2203f78b"},{"ddl":"CREATE TRIGGER inuzuka_session_close AFTER UPDATE OF state ON public.combat_v2_sessions FOR EACH ROW EXECUTE FUNCTION clan_inuzuka_private.session_close_trigger()","name":"inuzuka_session_close","enabled":"O","function_md5":"f9569aeb2d3a3256548d713d621c9898"},{"ddl":"CREATE TRIGGER ordinary_narrative_no_second_encounter BEFORE INSERT OR UPDATE OF master_session_id ON public.combat_v2_sessions FOR EACH ROW EXECUTE FUNCTION combat_consumer_private.no_second_encounter()","name":"ordinary_narrative_no_second_encounter","enabled":"O","function_md5":"fac69f481e1787099b1758e0b35c7f8a"},{"ddl":"CREATE TRIGGER panel_encounter_entry AFTER INSERT OR UPDATE OF source_kind, master_session_id, location_id, lesiva ON public.combat_v2_sessions FOR EACH ROW EXECUTE FUNCTION combat_panel_private.master_entry_trigger()","name":"panel_encounter_entry","enabled":"O","function_md5":"d4a3102cb9908464cc08be0b263d9d6f"},{"ddl":"CREATE TRIGGER panel_encounter_terminal_sync AFTER UPDATE OF state, closed_at ON public.combat_v2_sessions FOR EACH ROW EXECUTE FUNCTION combat_panel_private.master_scene_lifecycle_trigger()","name":"panel_encounter_terminal_sync","enabled":"O","function_md5":"95e0c0559898f60c848996e84a845a7c"},{"ddl":"CREATE TRIGGER panel_immobilization_session_end AFTER UPDATE OF state ON public.combat_v2_sessions FOR EACH ROW EXECUTE FUNCTION combat_panel_private.immobilization_session_lifecycle()","name":"panel_immobilization_session_end","enabled":"O","function_md5":"38bc9bc060bc1af88cf087f5e4a687bb"},{"ddl":"CREATE TRIGGER panel_multiplication_combat_end AFTER UPDATE OF state, closed_at ON public.combat_v2_sessions FOR EACH ROW EXECUTE FUNCTION combat_panel_private.multiplication_combat_end()","name":"panel_multiplication_combat_end","enabled":"O","function_md5":"83c3a56e1b4b1b9a49f7008d9d8e3591"},{"ddl":"CREATE TRIGGER quest_ai_native_combat_insert BEFORE INSERT ON public.combat_v2_sessions FOR EACH ROW EXECUTE FUNCTION mission_factory_owner.quest_combat_insert_guard_v1()","name":"quest_ai_native_combat_insert","enabled":"O","function_md5":"dccee1ffa367f56a23246e547578d888"},{"ddl":"CREATE TRIGGER quest_ai_native_combat_update BEFORE UPDATE OF master_session_id, source_kind, location_id, lesiva, state ON public.combat_v2_sessions FOR EACH ROW EXECUTE FUNCTION mission_factory_owner.quest_combat_insert_guard_v1()","name":"quest_ai_native_combat_update","enabled":"O","function_md5":"dccee1ffa367f56a23246e547578d888"},{"ddl":"CREATE TRIGGER sabaku_armor_session_terminal AFTER UPDATE OF state, closed_at ON public.combat_v2_sessions FOR EACH ROW EXECUTE FUNCTION clan_sabaku_private.armor_session_terminal()","name":"sabaku_armor_session_terminal","enabled":"O","function_md5":"f94210c8254eb9f4bc1da46a40465427"},{"ddl":"CREATE TRIGGER sabaku_clone_session_end AFTER UPDATE OF state, closed_at ON public.combat_v2_sessions FOR EACH ROW EXECUTE FUNCTION clan_sabaku_private.clone_lifecycle_trigger()","name":"sabaku_clone_session_end","enabled":"O","function_md5":"d8187fc67f036ca0cb9a0cfcd5137eed"},{"ddl":"CREATE TRIGGER user_test_native_binding BEFORE INSERT OR UPDATE ON public.combat_v2_sessions FOR EACH ROW EXECUTE FUNCTION user_testroom_common_private.propagate_context()","name":"user_test_native_binding","enabled":"O","function_md5":"a8d38263f2f5f7c58a3f1a69aee24ed6"}],"force_rls":true,"constraints":[{"ddl":"FOREIGN KEY (location_id) REFERENCES public.locations(id) ON DELETE RESTRICT","name":"combat_v2_sessions_location_id_fkey","validated":true},{"ddl":"FOREIGN KEY (master_session_id) REFERENCES public.master_v2_sessions(id) ON DELETE RESTRICT","name":"combat_v2_sessions_master_session_id_fkey","validated":true},{"ddl":"PRIMARY KEY (id)","name":"combat_v2_sessions_pkey","validated":true},{"ddl":"CHECK (((source_kind = 'master'::text) = (master_session_id IS NOT NULL)))","name":"combat_v2_sessions_source_chk","validated":true},{"ddl":"CHECK ((source_kind = ANY (ARRAY['ordinary'::text, 'master'::text])))","name":"combat_v2_sessions_source_kind_check","validated":true},{"ddl":"CHECK ((state = ANY (ARRAY['preparazione'::text, 'in_corso'::text, 'sospeso'::text, 'risolto'::text, 'chiuso'::text, 'annullato'::text])))","name":"combat_v2_sessions_state_check","validated":true},{"ddl":"CHECK (((state <> ALL (ARRAY['chiuso'::text, 'annullato'::text])) OR (closed_at IS NOT NULL)))","name":"combat_v2_sessions_terminale_chk","validated":true},{"ddl":"FOREIGN KEY (user_test_context_id) REFERENCES user_testroom_common_private.contexts(id)","name":"combat_v2_sessions_user_test_context_id_fkey","validated":true}]}},{"name":"public.master_v2_sessions","descriptor":{"acl":"{postgres=arwdDxtm/postgres,service_role=arwdDxtm/postgres}","oid":"30691","rls":true,"kind":"r","name":"public.master_v2_sessions","view":null,"owner":"postgres","columns":[{"name":"id","type":"uuid","default":"gen_random_uuid()","notnull":true},{"name":"location_id","type":"uuid","default":null,"notnull":true},{"name":"tipo","type":"text","default":null,"notnull":true},{"name":"stato","type":"text","default":"'preparazione'::text","notnull":true},{"name":"master_user","type":"uuid","default":null,"notnull":false},{"name":"control_version","type":"bigint","default":"1","notnull":true},{"name":"mission_id","type":"uuid","default":null,"notnull":false},{"name":"titolo","type":"text","default":null,"notnull":true},{"name":"stato_pre_sospensione","type":"text","default":null,"notnull":false},{"name":"created_at","type":"timestamp with time zone","default":"clock_timestamp()","notnull":true},{"name":"suspended_at","type":"timestamp with time zone","default":null,"notnull":false},{"name":"closed_at","type":"timestamp with time zone","default":null,"notnull":false},{"name":"close_reason","type":"text","default":null,"notnull":false},{"name":"quest_kind","type":"text","default":null,"notnull":false},{"name":"owner_kind","type":"text","default":"'human'::text","notnull":true}],"indexes":[{"ddl":"CREATE UNIQUE INDEX master_v2_sessions_id_mission_id_key ON public.master_v2_sessions USING btree (id, mission_id)","name":"public.master_v2_sessions_id_mission_id_key"},{"ddl":"CREATE INDEX master_v2_sessions_master_stato_idx ON public.master_v2_sessions USING btree (master_user, stato)","name":"public.master_v2_sessions_master_stato_idx"},{"ddl":"CREATE INDEX master_v2_sessions_missione_idx ON public.master_v2_sessions USING btree (mission_id) WHERE (mission_id IS NOT NULL)","name":"public.master_v2_sessions_missione_idx"},{"ddl":"CREATE UNIQUE INDEX master_v2_sessions_pkey ON public.master_v2_sessions USING btree (id)","name":"public.master_v2_sessions_pkey"},{"ddl":"CREATE UNIQUE INDEX master_v2_sessions_unica_luogo_idx ON public.master_v2_sessions USING btree (location_id) WHERE (stato <> ALL (ARRAY['chiusa'::text, 'annullata'::text]))","name":"public.master_v2_sessions_unica_luogo_idx"}],"policies":[],"triggers":[{"ddl":"CREATE TRIGGER aa_universal_arena_freeze AFTER INSERT ON public.master_v2_sessions FOR EACH ROW EXECUTE FUNCTION combat_panel_private.universal_arena_freeze()","name":"aa_universal_arena_freeze","enabled":"O","function_md5":"cee37e6572a8d549167aff3b4d9be0cd"},{"ddl":"CREATE TRIGGER combat_gate_master_claim BEFORE INSERT OR UPDATE OF stato, location_id ON public.master_v2_sessions FOR EACH ROW EXECUTE FUNCTION combat_gate_private.master_claim_trigger()","name":"combat_gate_master_claim","enabled":"O","function_md5":"9813c9aa62b7e0ab16e8ec5d4f4ae309"},{"ddl":"CREATE CONSTRAINT TRIGGER event42_hint_master_v2_sessions AFTER INSERT OR DELETE OR UPDATE ON public.master_v2_sessions DEFERRABLE INITIALLY DEFERRED FOR EACH ROW EXECUTE FUNCTION mission_generic_owner.event_capture_v1('hint')","name":"event42_hint_master_v2_sessions","enabled":"O","function_md5":"9b0b9bef1a608e974a6bee1e9d288feb"},{"ddl":"CREATE TRIGGER exam_human_native_lifecycle BEFORE DELETE OR UPDATE ON public.master_v2_sessions FOR EACH ROW EXECUTE FUNCTION exam_human_private.native_lifecycle_guard_v1()","name":"exam_human_native_lifecycle","enabled":"O","function_md5":"6b96e5306bc421a9a6cc3baabfaaa0fb"},{"ddl":"CREATE TRIGGER ordinary_narrative_master_binding_guard BEFORE UPDATE OF master_user, owner_kind, tipo, mission_id, quest_kind ON public.master_v2_sessions FOR EACH ROW EXECUTE FUNCTION combat_consumer_private.guard_narrative_master_binding()","name":"ordinary_narrative_master_binding_guard","enabled":"O","function_md5":"52c8b437c69acc73ecfe0cda9250e7ce"},{"ddl":"CREATE TRIGGER panel_actor_turn_close AFTER UPDATE OF stato ON public.master_v2_sessions FOR EACH ROW EXECUTE FUNCTION combat_panel_private.actor_turn_lifecycle()","name":"panel_actor_turn_close","enabled":"O","function_md5":"50eebd47ec1b7c58054ac06644974eeb"},{"ddl":"CREATE TRIGGER panel_master_authority_sync AFTER UPDATE OF master_user, control_version, stato, closed_at ON public.master_v2_sessions FOR EACH ROW EXECUTE FUNCTION combat_panel_private.master_scene_lifecycle_trigger()","name":"panel_master_authority_sync","enabled":"O","function_md5":"95e0c0559898f60c848996e84a845a7c"},{"ddl":"CREATE TRIGGER panel_master_entry AFTER INSERT OR UPDATE OF location_id, mission_id, owner_kind, master_user ON public.master_v2_sessions FOR EACH ROW EXECUTE FUNCTION combat_panel_private.master_entry_trigger()","name":"panel_master_entry","enabled":"O","function_md5":"d4a3102cb9908464cc08be0b263d9d6f"},{"ddl":"CREATE TRIGGER shuriken_qa_no_master_scene BEFORE INSERT OR UPDATE OF location_id ON public.master_v2_sessions FOR EACH ROW EXECUTE FUNCTION combat_panel_private.shuriken_qa_reject_other_scene_v1()","name":"shuriken_qa_no_master_scene","enabled":"O","function_md5":"e2af1618fa9c95badfe6a95da52d6bb1"},{"ddl":"CREATE TRIGGER universal_arena_source_immutable BEFORE UPDATE OF location_id, mission_id ON public.master_v2_sessions FOR EACH ROW EXECUTE FUNCTION combat_panel_private.universal_arena_identity_guard()","name":"universal_arena_source_immutable","enabled":"O","function_md5":"d67e3f898e3fbfca6103d4dde08ae2e9"}],"force_rls":true,"constraints":[{"ddl":"TRIGGER DEFERRABLE INITIALLY DEFERRED","name":"event42_hint_master_v2_sessions","validated":true},{"ddl":"CHECK ((control_version >= 1))","name":"master_v2_sessions_control_version_check","validated":true},{"ddl":"UNIQUE (id, mission_id)","name":"master_v2_sessions_id_mission_id_key","validated":true},{"ddl":"FOREIGN KEY (location_id) REFERENCES public.locations(id) ON DELETE RESTRICT","name":"master_v2_sessions_location_id_fkey","validated":true},{"ddl":"CHECK ((((owner_kind = 'human'::text) AND (master_user IS NOT NULL)) OR ((owner_kind = 'ai_service'::text) AND (master_user IS NULL))))","name":"master_v2_sessions_master_chk","validated":true},{"ddl":"FOREIGN KEY (master_user) REFERENCES public.profiles(id) ON DELETE RESTRICT","name":"master_v2_sessions_master_user_fkey","validated":true},{"ddl":"FOREIGN KEY (mission_id) REFERENCES public.missions(id) ON DELETE RESTRICT","name":"master_v2_sessions_mission_id_fkey","validated":true},{"ddl":"CHECK ((((tipo = 'duello'::text) AND (mission_id IS NULL) AND (quest_kind IS NULL)) OR ((tipo = 'quest'::text) AND (((mission_id IS NOT NULL) AND (quest_kind IS NULL)) OR ((mission_id IS NULL) AND (quest_kind IS NOT NULL))))))","name":"master_v2_sessions_missione_chk","validated":true},{"ddl":"CHECK ((owner_kind = ANY (ARRAY['human'::text, 'ai_service'::text])))","name":"master_v2_sessions_owner_kind_chk","validated":true},{"ddl":"PRIMARY KEY (id)","name":"master_v2_sessions_pkey","validated":true},{"ddl":"CHECK (((quest_kind IS NULL) OR (quest_kind = ANY (ARRAY['one_shot'::text, 'trama'::text]))))","name":"master_v2_sessions_quest_kind_chk","validated":true},{"ddl":"CHECK ((stato = ANY (ARRAY['preparazione'::text, 'in_corso'::text, 'sospesa'::text, 'chiusura'::text, 'chiusa'::text, 'annullata'::text])))","name":"master_v2_sessions_stato_check","validated":true},{"ddl":"CHECK (((stato = ANY (ARRAY['chiusa'::text, 'annullata'::text])) = (closed_at IS NOT NULL)))","name":"master_v2_sessions_terminale_chk","validated":true},{"ddl":"CHECK ((tipo = ANY (ARRAY['duello'::text, 'quest'::text])))","name":"master_v2_sessions_tipo_check","validated":true},{"ddl":"CHECK (((char_length(btrim(titolo)) >= 2) AND (char_length(btrim(titolo)) <= 120)))","name":"master_v2_sessions_titolo_check","validated":true}]}}]$velo_rel_shapes$::jsonb) AS e(name text,descriptor jsonb)
 LEFT JOIN relations r ON r.name=e.name
 WHERE to_jsonb(r) IS DISTINCT FROM e.descriptor
 ) THEN RAISE EXCEPTION 'VELO_AFTER_RELATION_SHAPE_DRIFT'; END IF;
 

 IF (SELECT public.combat_v2_sha256(to_jsonb(t)) FROM public.clan_techniques t WHERE t.id='c9b261da-c9cd-40bb-8189-7b65ab5a1605')
     IS DISTINCT FROM 'a79a36d47fe260c0db0d965703cef3b41d98c39530605382d6a8c68109d78229' THEN
  RAISE EXCEPTION 'VELO_CATALOGUE_DRIFT';
 END IF;


 IF jsonb_build_object('ABU',(SELECT to_jsonb(g) FROM clan_aburame_private.verme_gate_v1 AS g WHERE g.singleton),
    'AKI',(SELECT to_jsonb(g) FROM clan_akimichi_private.common_gate_v1 AS g WHERE g.singleton),
    'NARA',(SELECT to_jsonb(g) FROM combat_panel_private.nara_adv_gate_v1 AS g WHERE g.singleton),
    'NB',(SELECT to_jsonb(g) FROM combat_v2_staff_nb_internal.gate AS g WHERE g.singleton),
    'aburame_genin',(SELECT to_jsonb(g) FROM clan_aburame_private.release_gate AS g WHERE g.singleton),
    'akimichi_genin',(SELECT to_jsonb(g) FROM clan_akimichi_private.release_gate AS g WHERE g.singleton),
    'cure',(SELECT to_jsonb(g) FROM combat_panel_private.cure_gate_v1 AS g WHERE g.singleton),
    'genjutsu',(SELECT to_jsonb(g) FROM combat_v2_genjutsu_internal.gate AS g WHERE g.singleton),
    'nara_genin',(SELECT to_jsonb(g) FROM combat_panel_private.nara_launch_gate_v1 AS g WHERE g.singleton)) IS DISTINCT FROM $velo_baseline_gates${"NB":{"version":1,"singleton":true,"staff_enabled":true,"public_enabled":false},"ABU":{"singleton":true,"staff_enabled":true,"public_enabled":false,"contract_version":"aburame-verme/1"},"AKI":{"singleton":true,"staff_enabled":true,"public_enabled":false,"contract_version":"akimichi-common/1","super_public_enabled":false,"cellular_public_enabled":false},"NARA":{"singleton":true,"staff_enabled":true,"public_enabled":false},"cure":{"singleton":true,"staff_enabled":true,"public_enabled":false,"contract_version":"palmo-curativo/1"},"genjutsu":{"enabled":true,"version":1,"singleton":true,"staff_enabled":true,"public_enabled":false},"nara_genin":{"singleton":true,"staff_enabled":true,"public_enabled":true,"public_activated_at":"2026-11-13T10:40:45.463756+00:00"},"aburame_genin":{"version":2,"singleton":true,"staff_enabled":true,"public_enabled":true},"akimichi_genin":{"singleton":true,"staff_enabled":true,"public_enabled":true}}$velo_baseline_gates$::jsonb THEN
  RAISE EXCEPTION 'VELO_EXISTING_GATES_DRIFT';
 END IF;


 SELECT * INTO STRICT prior_release FROM mission_public_owner.release_admissions_v1 WHERE release_sha256='0fb538733f7010d36babf42f2ffa69432b16b8baa1e9bdea6d0b4ff6d447ae8d' FOR SHARE;
 SELECT * INTO STRICT prior_qualification FROM mission_public_owner.public_qualification_attestations_v1 WHERE release_sha256='0fb538733f7010d36babf42f2ffa69432b16b8baa1e9bdea6d0b4ff6d447ae8d' FOR SHARE;
 IF prior_release.edge_sha256 IS DISTINCT FROM generic_ezbr
 OR public.combat_v2_sha256(to_jsonb(prior_release)) IS DISTINCT FROM '603b6304eab7f53e87862df3b847ffc82aedda02f6841037752eeb2d68ed54cf'
 OR public.combat_v2_sha256(to_jsonb(prior_qualification)) IS DISTINCT FROM '9110bf5dad2ac135d8ef4edccd1655358e76b1acf63e70dc95b62f3f8a55e6f0'
 OR public.combat_v2_sha256(prior_qualification.payload->'capabilities') IS DISTINCT FROM '49fe134f561273f28e8071b63c45886341371b67d028f06e6b7d8f8d4108e817'
 OR (SELECT count(*) FROM mission_public_owner.mission_content_admissions_v1 c WHERE c.engine_release_sha256='0fb538733f7010d36babf42f2ffa69432b16b8baa1e9bdea6d0b4ff6d447ae8d') IS DISTINCT FROM 2::bigint
 OR (SELECT public.combat_v2_sha256(jsonb_agg(to_jsonb(c) ORDER BY c.mission_id,c.request_key))
     FROM mission_public_owner.mission_content_admissions_v1 c WHERE c.engine_release_sha256='0fb538733f7010d36babf42f2ffa69432b16b8baa1e9bdea6d0b4ff6d447ae8d')
    IS DISTINCT FROM '474eaa2ff3a9b7c7d9e399c13325a8b798d61ac8dc1d3659851fa66665e9880a'
 OR (SELECT count(DISTINCT e.profile_key) FROM mission_public_owner.engine_profile_events_v1 e WHERE e.engine_release_sha256='0fb538733f7010d36babf42f2ffa69432b16b8baa1e9bdea6d0b4ff6d447ae8d') IS DISTINCT FROM 1::bigint
 OR (SELECT public.combat_v2_sha256(jsonb_agg(to_jsonb(e) ORDER BY e.profile_key))
     FROM (SELECT DISTINCT ON (z.profile_key) * FROM mission_public_owner.engine_profile_events_v1 z
           WHERE z.engine_release_sha256='0fb538733f7010d36babf42f2ffa69432b16b8baa1e9bdea6d0b4ff6d447ae8d' ORDER BY z.profile_key,z.control_version DESC) AS e)
   IS DISTINCT FROM '0f56704fdb068f91d9ac0883ca92b900677d13cf105a3cd0e581177a4b3cd450' THEN
  RAISE EXCEPTION 'VELO_EXISTING_MISSION_EVIDENCE_DRIFT';
 END IF;

 SELECT to_jsonb(x) INTO STRICT runtime_before FROM mission_public_owner.party_launch_runtime_v1 x WHERE x.singleton FOR UPDATE;
 IF runtime_before IS DISTINCT FROM $velo_runtime${"singleton":true,"staff_enabled":true,"public_enabled":true,"release_sha256":"0fb538733f7010d36babf42f2ffa69432b16b8baa1e9bdea6d0b4ff6d447ae8d"}$velo_runtime$::jsonb THEN RAISE EXCEPTION 'VELO_PARTY_RUNTIME_DRIFT'; END IF;
 bindings:=jsonb_build_object('db_sha256',db_sha,'edge_sha256',generic_ezbr,
  'client_sha256',public.combat_v2_sha256(root->'ui'),'configuration_sha256',config_sha);
 UPDATE mission_factory_owner.editor_release_readiness
 SET canonical_preimage=root_text,revision_sha256=new_root_sha,observed_revision_sha256=new_root_sha,
  client_build='mission-factory-admin/2:'||new_root_sha,independent_review_ref=review->>'ref',updated_at=clock_timestamp()
 WHERE singleton AND revision_sha256=old_root_sha
    AND public.combat_v2_sha256(to_jsonb(editor_release_readiness))='92af19424dbe4a11633c86e637c99c529785ae917ad4b58f563264c9a6ed5db1';
 GET DIAGNOSTICS affected=ROW_COUNT;
 IF affected<>1 THEN RAISE EXCEPTION 'VELO_ROOT_CAS'; END IF;
 UPDATE clan_innata_combat_private.velo_staff_gate_v1 SET staff_enabled=true WHERE singleton AND NOT staff_enabled;
 GET DIAGNOSTICS affected=ROW_COUNT;
 IF affected<>1 OR NOT clan_innata_private.catalogo_eligibility_release_v1() THEN
  RAISE EXCEPTION 'VELO_FINAL_STAFF_ATTESTATION_INVALID';
 END IF;
 PERFORM clan_innata_private.runtime_release_assert();
 INSERT INTO mission_public_owner.release_admissions_v1(release_sha256,db_sha256,edge_sha256,client_sha256,configuration_sha256,
  contract_version,independent_review_ref,staff_evidence_ref,qualified_at,public_enabled)
 VALUES(new_root_sha,db_sha,generic_ezbr,bindings->>'client_sha256',config_sha,prior_release.contract_version,
  review->>'ref',prior_release.staff_evidence_ref,prior_release.qualified_at,prior_release.public_enabled);
 FOR profile_row IN SELECT DISTINCT ON(profile_key)* FROM mission_public_owner.engine_profile_events_v1
  WHERE engine_release_sha256=old_root_sha ORDER BY profile_key,control_version DESC LOOP
  IF profile_row.profile_key IS DISTINCT FROM prior_qualification.payload->>'authoring_profile' THEN
   RAISE EXCEPTION 'VELO_UNQUALIFIED_PROFILE_CARRYFORWARD';END IF;
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
 OR mission_public_owner.engine_qualification_v1(new_root_sha,true)IS NULL THEN RAISE EXCEPTION 'VELO_MISSION_CARRYFORWARD_INVALID';END IF;
 FOR content_row IN SELECT * FROM mission_public_owner.mission_content_admissions_v1 WHERE engine_release_sha256=old_root_sha ORDER BY mission_id LOOP
  content_request:=extensions.uuid_generate_v5(content_row.request_key,new_root_sha||':catalogo-compatible-adoption');
  content_payload:=content_row.payload||jsonb_build_object('request_key',content_request,'engine_release_sha256',new_root_sha,'created_at',clock_timestamp());
  INSERT INTO mission_public_owner.mission_content_admissions_v1(request_key,mission_id,config_version,engine_release_sha256,publication_request,payload,payload_sha256)
  VALUES(content_request,content_row.mission_id,content_row.config_version,new_root_sha,content_row.publication_request,content_payload,mission_factory_owner.sha(content_payload));
  IF mission_public_owner.content_admission_v1(content_row.mission_id,new_root_sha,content_row.publication_request,true)IS NULL THEN
   RAISE EXCEPTION 'VELO_CONTENT_CARRYFORWARD_INVALID';END IF;
 END LOOP;
 UPDATE mission_public_owner.party_launch_runtime_v1 x SET release_sha256=new_root_sha WHERE singleton AND to_jsonb(x)=runtime_before;
 GET DIAGNOSTICS affected=ROW_COUNT;IF affected<>1 THEN RAISE EXCEPTION 'VELO_PARTY_RUNTIME_CAS';END IF;


 IF mission_public_owner.engine_qualification_v1('2bcaf1943d787202406fad30d0a628869df77aae792eaa38d089dea41f393e42',true) IS NULL
  OR (SELECT count(*) FROM mission_public_owner.mission_content_admissions_v1 c
      WHERE c.engine_release_sha256='2bcaf1943d787202406fad30d0a628869df77aae792eaa38d089dea41f393e42'
       AND mission_public_owner.content_admission_v1(c.mission_id,'2bcaf1943d787202406fad30d0a628869df77aae792eaa38d089dea41f393e42',c.publication_request,true) IS NOT NULL)
     IS DISTINCT FROM 2::bigint THEN RAISE EXCEPTION 'VELO_RETAINED_MISSIONS_NOT_QUALIFIED'; END IF;


 IF jsonb_build_object('ABU',(SELECT to_jsonb(g) FROM clan_aburame_private.verme_gate_v1 AS g WHERE g.singleton),
    'AKI',(SELECT to_jsonb(g) FROM clan_akimichi_private.common_gate_v1 AS g WHERE g.singleton),
    'NARA',(SELECT to_jsonb(g) FROM combat_panel_private.nara_adv_gate_v1 AS g WHERE g.singleton),
    'NB',(SELECT to_jsonb(g) FROM combat_v2_staff_nb_internal.gate AS g WHERE g.singleton),
    'aburame_genin',(SELECT to_jsonb(g) FROM clan_aburame_private.release_gate AS g WHERE g.singleton),
    'akimichi_genin',(SELECT to_jsonb(g) FROM clan_akimichi_private.release_gate AS g WHERE g.singleton),
    'cure',(SELECT to_jsonb(g) FROM combat_panel_private.cure_gate_v1 AS g WHERE g.singleton),
    'genjutsu',(SELECT to_jsonb(g) FROM combat_v2_genjutsu_internal.gate AS g WHERE g.singleton),
    'nara_genin',(SELECT to_jsonb(g) FROM combat_panel_private.nara_launch_gate_v1 AS g WHERE g.singleton)) IS DISTINCT FROM $velo_baseline_gates${"NB":{"version":1,"singleton":true,"staff_enabled":true,"public_enabled":false},"ABU":{"singleton":true,"staff_enabled":true,"public_enabled":false,"contract_version":"aburame-verme/1"},"AKI":{"singleton":true,"staff_enabled":true,"public_enabled":false,"contract_version":"akimichi-common/1","super_public_enabled":false,"cellular_public_enabled":false},"NARA":{"singleton":true,"staff_enabled":true,"public_enabled":false},"cure":{"singleton":true,"staff_enabled":true,"public_enabled":false,"contract_version":"palmo-curativo/1"},"genjutsu":{"enabled":true,"version":1,"singleton":true,"staff_enabled":true,"public_enabled":false},"nara_genin":{"singleton":true,"staff_enabled":true,"public_enabled":true,"public_activated_at":"2026-11-13T10:40:45.463756+00:00"},"aburame_genin":{"version":2,"singleton":true,"staff_enabled":true,"public_enabled":true},"akimichi_genin":{"singleton":true,"staff_enabled":true,"public_enabled":true}}$velo_baseline_gates$::jsonb THEN
  RAISE EXCEPTION 'VELO_EXISTING_GATES_DRIFT';
 END IF;

 IF (SELECT to_jsonb(x) FROM mission_public_owner.party_launch_runtime_v1 x WHERE x.singleton)
      IS DISTINCT FROM jsonb_set(runtime_before,'{release_sha256}',to_jsonb(new_root_sha),false) THEN
  RAISE EXCEPTION 'VELO_FINAL_MISSION_BOUNDARY_DRIFT';
 END IF;
 PERFORM set_config('app.velo_result',jsonb_build_object('root_sha256',new_root_sha,'root_bytes',octet_length(root_text),
  'previous_root_sha256',old_root_sha,'staff_enabled',true,'public_opening',false,
  'existing_mission_contents',2,'playtest','NOT_RUN','provider_calls',0)::text,true);
END
$velo_post$;

SELECT current_setting('app.velo_result',true)::jsonb AS release_receipt;
COMMIT;
