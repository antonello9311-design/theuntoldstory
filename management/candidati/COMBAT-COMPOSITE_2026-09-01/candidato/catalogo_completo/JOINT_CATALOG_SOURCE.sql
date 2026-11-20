-- Joint source-only template; bind reviewed actual P and Edge receipt. No direct execution.
BEGIN;
SET LOCAL search_path='';
DO $joint_pre$
DECLARE rr mission_factory_owner.editor_release_readiness%ROWTYPE;p jsonb;f jsonb;
BEGIN
 IF current_user<>'postgres'OR session_user<>'postgres'OR auth.uid()IS NOT NULL THEN RAISE EXCEPTION 'JOINT_OPERATOR_REQUIRED';END IF;
 IF NOT pg_try_advisory_xact_lock(hashtextextended('C1266:GENERIC-AI:AVAILABILITY',0))THEN RAISE EXCEPTION 'JOINT_AVAILABILITY_BUSY';END IF;
 p:=nullif(current_setting('app.joint_catalog_parameters',true),'')::jsonb;
 SELECT * INTO STRICT rr FROM mission_factory_owner.editor_release_readiness WHERE singleton FOR UPDATE NOWAIT;
 IF rr.revision_sha256 IS DISTINCT FROM p#>>'{expected_current,root_sha256}'OR public.combat_v2_sha256(to_jsonb(rr))IS DISTINCT FROM p#>>'{expected_current,root_row_sha256}'THEN RAISE EXCEPTION 'JOINT_BASELINE_DRIFT';END IF;
 IF EXISTS(SELECT 1 FROM public.combat_v2_sessions WHERE closed_at IS NULL AND state='in_corso')OR EXISTS(SELECT 1 FROM public.master_v2_sessions WHERE closed_at IS NULL AND stato NOT IN('chiusa','annullata'))THEN RAISE EXCEPTION 'JOINT_REQUIRES_QUIESCENCE';END IF;
 PERFORM set_config('app.cure_reaction_paralisi_gate_before',(SELECT to_jsonb(g)::text FROM combat_v2_genjutsu_internal.gate g WHERE singleton),true);
 PERFORM set_config('app.cure_reaction_cure_gate_before',(SELECT to_jsonb(g)::text FROM combat_panel_private.cure_gate_v1 g WHERE singleton),true);
 PERFORM set_config('app.joint_catalog_native_gates_before',jsonb_build_object('aburame_genin',(SELECT to_jsonb(g)FROM clan_aburame_private.release_gate g WHERE singleton),'nara_genin',(SELECT to_jsonb(g)FROM combat_panel_private.nara_launch_gate_v1 g WHERE singleton),'akimichi_genin',(SELECT to_jsonb(g)FROM clan_akimichi_private.release_gate g WHERE singleton))::text,true);
 FOR f IN SELECT value FROM jsonb_array_elements($joint_owning$[{"signature":"clan_aburame_private.actor_ability(uuid,text,uuid,boolean,jsonb)","source_md5":"5c777c1573d9600904f8347ca1d3710d","ddl_sha256":"b91a6f1e5a67456629593462061fad5e85a43a554987a9054b83ff971f10ee35","owner":"postgres","acl":"{postgres=X/postgres}","config":["search_path=\"\""],"secdef":true},{"signature":"clan_aburame_private.attack_power_source(uuid,uuid)","source_md5":"b0372025c62575ca73763e29dabf24ea","ddl_sha256":"ca9630cba11af388c5020c51d74c691eaacad85b6d3551e14f2c91cf1046bef7","owner":"postgres","acl":"{postgres=X/postgres}","config":["search_path=\"\""],"secdef":true},{"signature":"clan_aburame_private.commit_control(jsonb,jsonb,combat_consumer_private.activities,combat_consumer_private.offers,uuid)","source_md5":"df2a4aec09cb6aa1243c3b4a573e11e8","ddl_sha256":"0f69641cdfeef55fa675df0ab3871ca318a16cd6d62bf63f133e6d7deaa7a8ec","owner":"postgres","acl":"{postgres=X/postgres}","config":["search_path=\"\""],"secdef":true},{"signature":"clan_aburame_private.commit_master_stop(jsonb)","source_md5":"ecfd39d2549452d6349bd36f2081c87f","ddl_sha256":"ebcd84dfc07b4f3086c26b8ec61bfc0344c4400f5ec188842b4b4188a4e688f5","owner":"postgres","acl":"{postgres=X/postgres}","config":["search_path=\"\""],"secdef":true},{"signature":"clan_aburame_private.consumer_options(jsonb)","source_md5":"ec235280809c186d60934a361dc97c8d","ddl_sha256":"00eb8bda488b77d32c3a33c3e3b866d45c937e5cdec94d5592e5cedb8dde9446","owner":"postgres","acl":"{postgres=X/postgres}","config":["search_path=\"\""],"secdef":true},{"signature":"clan_aburame_private.master_offers(uuid,bigint,jsonb)","source_md5":"a60c8dfe6cb9841e3bc32176b9cff273","ddl_sha256":"112242e294eb4da95e93b359ddcccdbb1dfe5a8d9a56eed29a5e4cbca9f7a678","owner":"postgres","acl":"{postgres=X/postgres}","config":["search_path=\"\""],"secdef":true},{"signature":"clan_akimichi_private.apply_calorie_event(uuid,uuid,boolean,uuid,text,integer,integer,uuid,timestamp with time zone)","source_md5":"8547929b762a5920eff026634728653f","ddl_sha256":"00bde30c5630480b3d385f6969c24873ce964b321b35def6a9a53e8b19efed92","owner":"postgres","acl":"{postgres=X/postgres}","config":["search_path=\"\""],"secdef":true},{"signature":"clan_akimichi_private.begin_personal_turn(uuid,uuid)","source_md5":"abfce763adc51e991d2e97259d5f0829","ddl_sha256":"96b3de12fcdcbddc277ef6e0032148629fd13a98117facda4e9eb12be6d7425a","owner":"postgres","acl":"{postgres=X/postgres}","config":["search_path=\"\""],"secdef":true},{"signature":"clan_akimichi_private.bind_partial(uuid)","source_md5":"b641bd93f7457ecbb6dd16233f5d1d7f","ddl_sha256":"3ba9ef8d6ea5d88339f069a6c66641b10f4ae41b54787797a582fa0bf5593ded","owner":"postgres","acl":"{postgres=X/postgres}","config":["search_path=\"\""],"secdef":true},{"signature":"clan_akimichi_private.end_form(uuid,uuid,text)","source_md5":"6e39a547d317445e64b48a10c90c5556","ddl_sha256":"6637f368db7a9b816c37cfa1db7f473c43f6b825493910f540036e6df5a8060b","owner":"postgres","acl":"{postgres=X/postgres}","config":["search_path=\"\""],"secdef":true},{"signature":"clan_akimichi_private.form_change_offer(uuid)","source_md5":"6688fe91fa77b4f54dfecc5d0b2ed889","ddl_sha256":"aed7a68f7ddac16d8d397d5af36ff3dc082450b1f585be0cb7f86f31f7d25851","owner":"postgres","acl":"{postgres=X/postgres}","config":["search_path=\"\""],"secdef":true},{"signature":"clan_akimichi_private.form_impact(uuid,uuid,uuid,text,text,text,jsonb)","source_md5":"7c6d3523282558e3c5e59b21889059fa","ddl_sha256":"7b9152ec1de73c1c97718265db058e57cd57c0f70e413dac2c5504053ecc5e3b","owner":"postgres","acl":"{postgres=X/postgres}","config":["search_path=\"\""],"secdef":true},{"signature":"clan_akimichi_private.movement_maximum(uuid,numeric)","source_md5":"e4000b9fbc0252583999169e88e398a6","ddl_sha256":"a33b903cfa79518e073a9fb4ea9926c83fa0138e67eddd8a81daab0043d588fb","owner":"postgres","acl":"{postgres=X/postgres}","config":["search_path=\"\""],"secdef":true},{"signature":"clan_akimichi_private.partial_meta(uuid,jsonb)","source_md5":"4829e3e1f22c72ab156850976d7243ec","ddl_sha256":"46463fa1af40099ee6a2d1ce92d27d5205ecb0abdbb57b1bf80ec992d85132f8","owner":"postgres","acl":"{postgres=X/postgres}","config":["search_path=\"\""],"secdef":true},{"signature":"clan_akimichi_private.set_form(uuid,uuid,boolean)","source_md5":"44f3fa136cccf39068a7a77ff2136380","ddl_sha256":"131f9ad17a7262959828dd8d5ae240632a8d49665da9bba9559bc1a758f0f3ee","owner":"postgres","acl":"{postgres=X/postgres}","config":["search_path=\"\""],"secdef":true},{"signature":"clan_sabaku_private.armor_absorb(uuid,integer)","source_md5":"e23261cc3fd2dcd2fcbe7152a0db046e","ddl_sha256":"e326603d6439578a01c4dbddee43f9c4bd7dfc861a67bfadae3188fee4f7238a","owner":"postgres","acl":"{postgres=X/postgres}","config":["search_path=\"\""],"secdef":true},{"signature":"clan_sabaku_private.armor_narrative_round(uuid)","source_md5":"5a9e20d0ed65efcfd8550bf3e4cbf4cb","ddl_sha256":"d4f68da65b1cbf8167394bf2320df0bf761038bb54d2e65c3677dd7503430734","owner":"postgres","acl":"{postgres=X/postgres}","config":["search_path=\"\""],"secdef":true},{"signature":"clan_sabaku_private.armor_round_facts(uuid)","source_md5":"86e140b925c2d90380abc4e8bff2b4fa","ddl_sha256":"bb508501043b7d3d5663b4e7153050c8cdb7fb56e2a1618507ced7211fe23b69","owner":"postgres","acl":"{postgres=X/postgres}","config":["search_path=\"\""],"secdef":true},{"signature":"combat_consumer_private.after_publish(uuid,uuid)","source_md5":"f92a1cd710ad6e28123f3f3cd7226bd0","ddl_sha256":"cc2f938ee212cc8da5f53561e98d68a0430e4a29178521f20fd8a91d71c28ec6","owner":"postgres","acl":"{postgres=X/postgres}","config":["search_path=\"\""],"secdef":true},{"signature":"combat_consumer_private.commit_exchange(jsonb,jsonb)","source_md5":"e21d25bb92574909095004845b25d64a","ddl_sha256":"ce4bda0359a709a96514eb14483a151269eb304322c3ed3e995d88437754676d","owner":"postgres","acl":"{postgres=X/postgres}","config":["search_path=\"\""],"secdef":true},{"signature":"combat_consumer_private.narrative_context(uuid)","source_md5":"bb4d81831292676d2e50e16d14f3192c","ddl_sha256":"23bed326056c73dbde6d5a46e3d3b962384493cfab0283a35f1649292bd78cbf","owner":"postgres","acl":"{postgres=X/postgres}","config":["search_path=\"\""],"secdef":true},{"signature":"combat_consumer_private.narrative_declaration_supported(uuid)","source_md5":"b2d2c4047c4f63cb104effede756b4b8","ddl_sha256":"70689a25d0c08f7915d7405f88e733b334e19c689b0e094f8ef40b02e5d39843","owner":"postgres","acl":"{postgres=X/postgres}","config":["search_path=\"\""],"secdef":true},{"signature":"combat_consumer_private.validate_narrative_result(jsonb)","source_md5":"a1ce0576cc6ca82207301ae0bbc21904","ddl_sha256":"9ba51ad9979fbe88745d94981bd77df0ba2ce36e12f5591bc4df8b6f774413b7","owner":"postgres","acl":"{postgres=X/postgres}","config":["search_path=\"\""],"secdef":false},{"signature":"combat_effects_private.lifecycle_actor_end(uuid)","source_md5":"6633af861fa683c67e0e72a3bc3a39e8","ddl_sha256":"d7bbff1801a753f859d438166e7edd3fd2d260911d21af618335d740a5a46182","owner":"postgres","acl":"{postgres=X/postgres}","config":["search_path=\"\""],"secdef":true},{"signature":"combat_effects_private.lifecycle_open(uuid,uuid)","source_md5":"f94e3ef794064277d596354feba2cd50","ddl_sha256":"26c16b32c97ca05507c47861c77096d4e6f0328339af6e257bfea3f4615dbaa1","owner":"postgres","acl":"{postgres=X/postgres}","config":["search_path=\"\""],"secdef":true},{"signature":"combat_effects_private.lifecycle_session_end(uuid)","source_md5":"cb0673130543a118c7f75792b4fe170b","ddl_sha256":"76844cf8ee832eddbf6f03cb3e1008c380dd6b576b328247945efd1e75416caa","owner":"postgres","acl":"{postgres=X/postgres}","config":["search_path=\"\""],"secdef":true},{"signature":"combat_effects_private.personal_turn_end(uuid,uuid,uuid,text)","source_md5":"125e376708eaccc758e7887a9bcef705","ddl_sha256":"0a0d05ad60a0877f2ef48100f0154ee29c10a8e9ad8c57d291855077ce860b04","owner":"postgres","acl":"{postgres=X/postgres}","config":["search_path=\"\""],"secdef":true},{"signature":"combat_panel_private.catalog_result_label_v1(jsonb)","source_md5":"acae3722db638c3e8449b39f627fcfca","ddl_sha256":"ddcad0f5d3fe3ba7d0a1502c56f2a006e684116478d49adc7a1eaa9cb6a696c7","owner":"postgres","acl":"{postgres=X/postgres}","config":["search_path=\"\""],"secdef":false},{"signature":"combat_panel_private.consumer_commit_authoritative(jsonb)","source_md5":"17fd4965dd0cf6e971513f0eec95365f","ddl_sha256":"b46f351b1527e73807ae51de1d686e0a95c1e4bb93bab9657f9d5e113f29ab7d","owner":"postgres","acl":"{postgres=X/postgres}","config":["search_path=\"\""],"secdef":true},{"signature":"combat_panel_private.master_admin_offers(uuid,bigint,jsonb)","source_md5":"ea4d09198d2877b25bbb6fa79156bdb8","ddl_sha256":"74beed6a41d17f5308ce538d224a73635e879bd3f1784ac668a1cb7f03bdbbfd","owner":"postgres","acl":"{postgres=X/postgres}","config":["search_path=\"\""],"secdef":true},{"signature":"combat_panel_private.master_options(uuid,uuid,bigint)","source_md5":"84c29f6a84fbe579caf5bb3fec7a2382","ddl_sha256":"155b2a279cbef5f31ee7ee332f7844fe928ba3394cd43439906972f51129ca32","owner":"postgres","acl":"{postgres=X/postgres}","config":["search_path=\"\""],"secdef":true},{"signature":"combat_panel_private.nara_shadow_level_v1(uuid)","source_md5":"ae66bd5fd6f1ff407950463a008f6b77","ddl_sha256":"3b85cc7e4d3f261d7dae9ab2a6deb82946209e82875049be241b9d02448f4e04","owner":"postgres","acl":"{postgres=X/postgres}","config":["search_path=\"\""],"secdef":true},{"signature":"combat_panel_private.narrative_declaration_facts(uuid)","source_md5":"f4639eff179e6fdf1f998c0656ada09d","ddl_sha256":"8574c88360502e4a6e84541cb0da05af25fb5a1b5b907577de0840d303675bb1","owner":"postgres","acl":"{postgres=X/postgres}","config":["search_path=\"\""],"secdef":true},{"signature":"combat_panel_private.narrative_ordinary_context(uuid)","source_md5":"37d04042d9ee9cfec4ac237c7d9a5f37","ddl_sha256":"bd9ba81d6af8995121dcdd651789bf08e87ffd87157ec525a8e789f615e9411e","owner":"postgres","acl":"{postgres=X/postgres}","config":["search_path=\"\""],"secdef":true},{"signature":"combat_panel_private.ordinary_options(uuid,uuid,bigint)","source_md5":"4337c8fe49127d7d72edc0789fc0352b","ddl_sha256":"c814662051a0c6cdbeab0c020f4d2fb13cc124e66cdf2860130343a7b598f632","owner":"postgres","acl":"{postgres=X/postgres}","config":["search_path=\"\""],"secdef":true},{"signature":"combat_spatial.movement_commit(uuid,uuid,uuid)","source_md5":"fad828c5762e68c670da961e2ef5369b","ddl_sha256":"4239bff5d0cfb4f1bedcd4fc4e7e18c1c38f81c53074c4776d7ab8c921f430e0","owner":"postgres","acl":"{postgres=X/postgres}","config":["search_path=\"\""],"secdef":true},{"signature":"combat_v2_genjutsu_internal.ally_contact(uuid,uuid)","source_md5":"09fe1a174c9e813dcf541f1ad41a7016","ddl_sha256":"da243c808313512ad2d25cd3ca97f178fa898fbd4b0fc53e710dd77cce17ab65","owner":"postgres","acl":"{postgres=X/postgres}","config":["search_path=\"\""],"secdef":true},{"signature":"combat_v2_genjutsu_internal.master_options(uuid,bigint)","source_md5":"0111ecc9e4034eb295e5a898cd4cd88e","ddl_sha256":"7c6acdd5a1dea490a371b5041f82b9691c094fecaaec3018674bf416bce84e32","owner":"postgres","acl":"{postgres=X/postgres}","config":["search_path=\"\""],"secdef":true},{"signature":"combat_v2_genjutsu_internal.release_intents(uuid)","source_md5":"e1ddaf358a32b03d0ae3aed3023d57a7","ddl_sha256":"f58c697b1b3d01f8d8c293fb0e6c2270e835e81001aa9258669124781856bed5","owner":"postgres","acl":"{postgres=X/postgres}","config":["search_path=\"\""],"secdef":true},{"signature":"combat_v2_genjutsu_internal.release_meta(uuid,uuid,uuid,jsonb)","source_md5":"1d0416d6f715524c8ac1374dbabae55d","ddl_sha256":"04abf68582e6d78325e86a171bea580ea9e7a569de85828fd113b2cb8980b5ba","owner":"postgres","acl":"{postgres=X/postgres}","config":["search_path=\"\""],"secdef":true},{"signature":"combat_v2_genjutsu_internal.resolve_release(uuid)","source_md5":"cb9fcdd4ff035ca7938144412be57e2c","ddl_sha256":"99e3a874cbd2e19fb18f59100c391fb56c2908f055a23a1cabf061b73da60834","owner":"postgres","acl":"{postgres=X/postgres}","config":["search_path=\"\""],"secdef":true},{"signature":"combat_v2_genjutsu_internal.scope(uuid)","source_md5":"17ac15ea8ea5a734ff4eb0cc9d6e7f34","ddl_sha256":"3be4b86aa07ec1344f84d9544e0a87d91141814a7b01e3137026cd8a696698b3","owner":"postgres","acl":"{postgres=X/postgres}","config":["search_path=\"\""],"secdef":true},{"signature":"combat_v2_multitarget_internal.resolve_parent(uuid,uuid,uuid,boolean)","source_md5":"e9c7eb293c1791e36ba5fe70204af224","ddl_sha256":"8cdb1857a2418dcd3e06006688642c2e7da90782593a52ddf0f0e093e62a9de2","owner":"postgres","acl":"{postgres=X/postgres}","config":["search_path=\"\""],"secdef":true},{"signature":"mission_factory_owner.quest_combat_offer_source_guard_v1()","source_md5":"89715d9e01a4be4060ff8ce29cbdd599","ddl_sha256":"a74dd515eba37a0c0f05cb090da13448772379135a7b826ae8c9d4c89ab5a793","owner":"postgres","acl":"{postgres=X/postgres}","config":["search_path=\"\""],"secdef":true},{"signature":"public._combat_calcola(text,jsonb,jsonb,text,text,integer,text,integer,integer,integer,integer,boolean)","source_md5":"734a10044ff1333294933c706bcce3b5","ddl_sha256":"79288dbc8ba3d3d2997a24f8439d96984d6ccd6c112a388d569d435642423545","owner":"postgres","acl":"{postgres=X/postgres,service_role=X/postgres}","config":["search_path=public"],"secdef":false},{"signature":"public.combat_consumer_narrative_claim_v1(uuid,text,uuid)","source_md5":"1b51f51abc7ee3201a994c520fbcc64c","ddl_sha256":"59c76b57d6d92fed8e92894a0ff54d8aeadec995e213c04b7087804648b4cfeb","owner":"postgres","acl":"{postgres=X/postgres,service_role=X/postgres}","config":["search_path=\"\""],"secdef":true},{"signature":"public.combat_consumer_narrative_complete_v1(uuid,jsonb,uuid)","source_md5":"2d60a9af131230e7f40ff99ed6456180","ddl_sha256":"c14523e95544182275336ca9c14a2bf88d0b048858a96fe8772bf8a0f00c905c","owner":"postgres","acl":"{postgres=X/postgres,service_role=X/postgres}","config":["search_path=\"\""],"secdef":true},{"signature":"public.combat_panel_commit_v1(jsonb)","source_md5":"ce0c32cce5f6da141e20c015aba9e880","ddl_sha256":"2b4660b431f9824cef1ed59b7f299998e8a7be06f66d18cb8c2e5b734c841fbe","owner":"postgres","acl":"{postgres=X/postgres,authenticated=X/postgres}","config":["search_path=\"\""],"secdef":true},{"signature":"public.combat_v2_action_declare(uuid,uuid,jsonb,text,uuid)","source_md5":"56a48200d4a15178b63e52445cb42ba7","ddl_sha256":"a6031c7e390241dd7fad8e81be90ae8f3dc57e2283e742c19047d046c9e93f6d","owner":"postgres","acl":"{postgres=X/postgres,authenticated=X/postgres,service_role=X/postgres}","config":["search_path=\"\""],"secdef":true},{"signature":"public.combat_v2_actor_ability(uuid,text,uuid,boolean)","source_md5":"6bc1065e07011266fead520f4b7d3b47","ddl_sha256":"3f86b9972ead72801b6a4c392d2b180d011ca2605075855cd21a59b848f665e4","owner":"postgres","acl":"{postgres=X/postgres,service_role=X/postgres}","config":["search_path=\"\""],"secdef":true},{"signature":"public.combat_v2_defense_declare(uuid,uuid,uuid,jsonb,text,uuid)","source_md5":"7e947fd7937ec49f19101a58d95432d8","ddl_sha256":"f92e4d4bf5e6e22d79b64204471083ed07be97404e2961f5a57ab2956a098265","owner":"postgres","acl":"{postgres=X/postgres,authenticated=X/postgres,service_role=X/postgres}","config":["search_path=\"\""],"secdef":true},{"signature":"public.combat_v2_round_resolve(uuid,uuid)","source_md5":"954c762bcaf8a4638d51a9061a275f24","ddl_sha256":"c3242f7ef7d828b88e349996e08c52c73758be0a4848fad7329fa9e0be437daa","owner":"postgres","acl":"{postgres=X/postgres,service_role=X/postgres,authenticated=X/postgres}","config":["search_path=\"\""],"secdef":true},{"signature":"public.master_v2_encounter_open_ninja_book_v1_human_ai_core(uuid,uuid[],jsonb,jsonb,uuid)","source_md5":"da4541712ac4dc097b0e54dfee1ecf7c","ddl_sha256":"d3d2122c5269ef35d8ae001acd1586cc05433ee0da859a3b3b62b991f579949a","owner":"postgres","acl":"{postgres=X/postgres}","config":["search_path=\"\""],"secdef":true},{"signature":"combat_panel_private.publish_master_declaration(uuid,text)","source_md5":"6c89288503ac54271d47e8f81b131393","ddl_sha256":"93726ac57b6b0a6b60602dac04da8e23afb276b6ae6c1b9658dd782b9a6ccda4","owner":"postgres","acl":"{postgres=X/postgres}","config":["search_path=\"\""],"secdef":true},{"signature":"clan_innata_private.eligibility_release_assert()","source_md5":"ef199a674937b3bc4f9dbd49f35bf9b2","ddl_sha256":"680a47c514ab2255937d259a2fb0ecc8fd1b098670089d595b531839a23e33f9","owner":"postgres","acl":"{postgres=X/postgres}","config":["search_path=pg_catalog, public, clan_innata_private"],"secdef":true},{"signature":"clan_innata_private.catalogo_eligibility_release_v1()","source_md5":"e52a8ac90fb15cad425cd0d17c9b4d4b","ddl_sha256":"72141f00f7b6c79aacf634334290e92debbcc3a5bd77365c55dc4ef3a82ea5f6","owner":"postgres","acl":"{postgres=X/postgres}","config":["search_path=\"\""],"secdef":true}]$joint_owning$::jsonb)LOOP
 IF md5((SELECT prosrc FROM pg_proc WHERE oid=to_regprocedure(f->>'signature')))IS DISTINCT FROM f->>'source_md5'OR encode(extensions.digest(convert_to(pg_get_functiondef(to_regprocedure(f->>'signature')),'UTF8'),'sha256'),'hex')IS DISTINCT FROM f->>'ddl_sha256'OR NOT EXISTS(SELECT 1 FROM pg_proc pp WHERE pp.oid=to_regprocedure(f->>'signature')AND pg_get_userbyid(pp.proowner)=f->>'owner'AND pp.proacl::text IS NOT DISTINCT FROM f->>'acl'AND coalesce(to_jsonb(pp.proconfig),'null'::jsonb)IS NOT DISTINCT FROM f->'config'AND pp.prosecdef=(f->>'secdef')::boolean)THEN RAISE EXCEPTION 'JOINT_OWNING_DRIFT:%',f->>'signature';END IF;
 END LOOP;
 IF p->>'mode'IS DISTINCT FROM 'source'OR rr.revision_sha256<>'df85a212a00f218f6ba8435a267b012d382584bd9e23afbe0abb21f911f2d53b'OR public.combat_v2_sha256(to_jsonb(rr))<>'18619d4dc2be7f0513e9376ff922566d57d4dd41dc2de643d0db63cff4a02ab7'OR to_regclass('combat_v2_staff_nb_internal.gate')IS NOT NULL OR to_regclass('clan_aburame_private.verme_gate_v1')IS NOT NULL OR to_regclass('clan_akimichi_private.common_gate_v1')IS NOT NULL OR to_regclass('combat_panel_private.nara_adv_gate_v1')IS NOT NULL THEN RAISE EXCEPTION 'JOINT_SOURCE_SCOPE_DRIFT';END IF;
IF public.combat_v2_sha256((SELECT jsonb_build_object('tables',(SELECT jsonb_agg(jsonb_build_object('schema',n.nspname,'name',c.relname,'owner',pg_get_userbyid(c.relowner),'acl',c.relacl::text,'rls',c.relrowsecurity,'force_rls',c.relforcerowsecurity,'columns',(SELECT jsonb_agg(jsonb_build_object('name',a.attname,'type',format_type(a.atttypid,a.atttypmod),'notnull',a.attnotnull,'default',pg_get_expr(d.adbin,d.adrelid),'identity',a.attidentity,'generated',a.attgenerated)ORDER BY a.attnum)FROM pg_attribute a LEFT JOIN pg_attrdef d ON d.adrelid=a.attrelid AND d.adnum=a.attnum WHERE a.attrelid=c.oid AND a.attnum>0 AND NOT a.attisdropped),'constraints',(SELECT coalesce(jsonb_agg(jsonb_build_object('name',q.conname,'definition',pg_get_constraintdef(q.oid),'validated',q.convalidated,'deferrable',q.condeferrable,'deferred',q.condeferred)ORDER BY q.conname),'[]'::jsonb)FROM pg_constraint q WHERE q.conrelid=c.oid),'indexes',(SELECT coalesce(jsonb_agg(jsonb_build_object('name',ci.relname,'definition',pg_get_indexdef(i.indexrelid),'valid',i.indisvalid,'ready',i.indisready,'live',i.indislive)ORDER BY ci.relname),'[]'::jsonb)FROM pg_index i JOIN pg_class ci ON ci.oid=i.indexrelid WHERE i.indrelid=c.oid),'triggers',(SELECT coalesce(jsonb_agg(pg_get_triggerdef(t.oid)ORDER BY t.tgname),'[]'::jsonb)FROM pg_trigger t WHERE t.tgrelid=c.oid AND NOT t.tgisinternal),'policies',(SELECT coalesce(jsonb_agg(jsonb_build_object('name',p.polname,'cmd',p.polcmd,'roles',p.polroles,'using',pg_get_expr(p.polqual,p.polrelid),'check',pg_get_expr(p.polwithcheck,p.polrelid))ORDER BY p.polname),'[]'::jsonb)FROM pg_policy p WHERE p.polrelid=c.oid))ORDER BY n.nspname,c.relname)FROM pg_class c JOIN pg_namespace n ON n.oid=c.relnamespace WHERE c.oid IN(to_regclass('combat_v2_staff_nb_internal.gate'),to_regclass('combat_v2_staff_nb_internal.roster_sources'),to_regclass('combat_v2_staff_nb_internal.admissions'),to_regclass('clan_aburame_private.verme_gate_v1'),to_regclass('clan_aburame_private.verme_staff_profiles_v1'),to_regclass('clan_aburame_private.verme_sources_v1'),to_regclass('clan_aburame_private.verme_poison_v1'),to_regclass('clan_aburame_private.verme_events_v1'),to_regclass('clan_akimichi_private.common_gate_v1'),to_regclass('clan_akimichi_private.common_staff_profiles_v1'),to_regclass('clan_akimichi_private.common_form_commands_v1'),to_regclass('clan_akimichi_private.common_attack_powers_v1'),to_regclass('clan_akimichi_private.common_pending_upkeep_v1'),to_regclass('clan_akimichi_private.cellular_sources_v1'),to_regclass('combat_panel_private.nara_adv_gate_v1'),to_regclass('combat_panel_private.nara_adv_staff_v1'),to_regclass('combat_panel_private.nara_strangle_sources_v1'),to_regclass('combat_panel_private.nara_strangle_events_v1'),to_regclass('public.master_v2_nb_actor_offers_v1'),to_regclass('clan_akimichi_private.forms'))),'catalog',(SELECT jsonb_agg(jsonb_build_object('id',t.id,'sha256',public.combat_v2_sha256(to_jsonb(t)))ORDER BY t.id)FROM public.clan_techniques t WHERE id IN('0a15282f-d6b5-4ee3-ad52-7fac2525444d','f5f26cb5-9b6f-44b3-94bc-c329a0a88b93','687b058a-807d-4cf7-8bcf-21147931b0f6')),'NBtuples',(SELECT jsonb_build_object('mechanical',(SELECT jsonb_agg(jsonb_build_object('id',v.id,'template_id',v.template_id,'content_sha256',v.content_sha256)ORDER BY v.id)FROM public.nb_mechanical_versions v WHERE v.id IN('31da0000-0000-4000-8000-000000000111','31da0000-0000-4000-8000-000000000112')),'narrative',(SELECT jsonb_agg(jsonb_build_object('id',v.id,'template_id',v.template_id,'content_sha256',v.content_sha256)ORDER BY v.id)FROM public.nb_template_versions v WHERE v.id IN('31da0000-0000-4000-8000-000000000211','31da0000-0000-4000-8000-000000000212')))),'new_triggers',(SELECT jsonb_agg(jsonb_build_object('table',e->>'table','name',t.tgname,'function',t.tgfoid::regprocedure::text,'enabled',t.tgenabled::text,'type',t.tgtype,'definition',pg_get_triggerdef(t.oid),'args_sha256',encode(extensions.digest(t.tgargs,'sha256'),'hex'))ORDER BY e->>'table',e->>'name')FROM jsonb_array_elements($joint_triggers$[{"table":"combat_v2_staff_nb_internal.roster_sources","name":"staff_nb_origin_immutable"},{"table":"public.combat_v2_sessions","name":"aburame_verme_end_session_v1"},{"table":"public.combat_v2_actors","name":"aburame_verme_end_actor_v1"},{"table":"combat_panel_private.nara_strangle_sources_v1","name":"nara_strangle_snapshot_guard_v1"},{"table":"combat_panel_private.nara_strangle_events_v1","name":"nara_strangle_events_guard_v1"},{"table":"combat_panel_private.nara_adv_staff_v1","name":"nara_strangle_staff_guard_v1"},{"table":"combat_panel_private.nara_strangle_sources_v1","name":"nara_strangle_ended_event_v1"},{"table":"combat_panel_private.immobilizations","name":"nara_strangle_parent_end_v1"},{"table":"combat_spatial.actor_states","name":"nara_strangle_geometry_end_v1"}]$joint_triggers$::jsonb)e JOIN pg_trigger t ON t.tgrelid=to_regclass(e->>'table')AND t.tgname=e->>'name'AND NOT t.tgisinternal),'NBnamespace',(SELECT jsonb_build_object('owner',pg_get_userbyid(nspowner),'acl',nspacl::text)FROM pg_namespace WHERE nspname='combat_v2_staff_nb_internal'))))IS DISTINCT FROM '01bf2c232484ea66a05b7186b0a6ab17fd19d43df02f30b373d4d8b429a584a2'THEN RAISE EXCEPTION 'JOINT_SCHEMA_STATIC_TUPLE_BASELINE_DRIFT';END IF;
IF EXISTS(SELECT 1 FROM jsonb_array_elements($joint_absent$["combat_v2_staff_nb_internal.origin_guard()","combat_v2_staff_nb_internal.preparation_allowed(uuid)","combat_v2_staff_nb_internal.choice(uuid)","combat_v2_staff_nb_internal.roster_offers(uuid,bigint,uuid)","combat_v2_staff_nb_internal.native_construct(uuid,uuid[],jsonb,jsonb,uuid,uuid)","combat_v2_staff_nb_internal.mechanics_ready(uuid)","combat_v2_staff_nb_internal.setup_protected(uuid,uuid)","combat_v2_staff_nb_internal.commit_roster(jsonb)","combat_v2_staff_nb_internal.roster_receipt(uuid)","combat_v2_staff_nb_internal.pg_scope(uuid)","combat_v2_staff_nb_internal.kai_frozen_authority(uuid)","combat_v2_staff_nb_internal.kai_authority(uuid)","combat_v2_staff_nb_internal.kai_contact(uuid,uuid)","clan_aburame_private.verme_manifest_v1()","clan_aburame_private.verme_release_v1()","clan_aburame_private.verme_staff_scope_v1(uuid)","clan_aburame_private.verme_scope_v1(uuid)","clan_aburame_private.verme_event_v1(text,uuid,uuid,uuid,uuid,uuid,text,jsonb)","clan_aburame_private.verme_staff_prepare_v1(uuid,uuid)","clan_aburame_private.verme_meta_v1(uuid,boolean)","clan_aburame_private.verme_bind_v1(uuid)","clan_aburame_private.verme_frozen_v1(uuid)","clan_aburame_private.verme_finish_v1(uuid,uuid,boolean,integer)","clan_aburame_private.verme_tick_v1(uuid,uuid,uuid,text)","clan_aburame_private.verme_end_context_v1()","clan_aburame_private.verme_report_v1(uuid,uuid)","clan_aburame_private.verme_reserve_round_v1(uuid)","clan_aburame_private.verme_settle_round_v1(uuid)","clan_aburame_private.verme_narrative_v1(uuid,uuid)","clan_akimichi_private.common_staff_scope_v1(uuid)","clan_akimichi_private.common_scope_v1(uuid,uuid)","clan_akimichi_private.common_prepare_staff_v1(uuid,uuid,uuid)","clan_akimichi_private.common_modifiers_v1(text,integer,integer,integer)","clan_akimichi_private.common_set_form_v1(uuid,uuid,text)","clan_akimichi_private.common_defer_upkeep_v1(uuid,uuid)","clan_akimichi_private.common_flush_upkeep_v1(uuid)","clan_akimichi_private.cellular_meta_v1(uuid)","clan_akimichi_private.cellular_attack_eligible_v1(uuid,uuid)","clan_akimichi_private.cellular_bind_v1(uuid)","clan_akimichi_private.cellular_source_valid_v1(uuid)","clan_akimichi_private.cellular_pay_v1(uuid)","clan_akimichi_private.cellular_snapshot_v1(uuid,jsonb)","clan_akimichi_private.cellular_mark_v1(uuid,jsonb)","clan_akimichi_private.cellular_calculate_v1(uuid,jsonb,integer,integer)","clan_akimichi_private.common_calorie_balance_v1(uuid,uuid,uuid,uuid)","clan_akimichi_private.common_admit_calories_v1(uuid)","clan_akimichi_private.common_preflight_calories_v1(uuid)","clan_akimichi_private.super_direct_visible_v1(uuid,uuid)","clan_akimichi_private.common_attack_power_freeze_v1(uuid)","clan_akimichi_private.common_panel_offers_v1(uuid,bigint,jsonb)","clan_akimichi_private.common_panel_commit_v1(jsonb)","clan_akimichi_private.common_result_label_v1(jsonb)","clan_akimichi_private.common_source_root_v1()","clan_sabaku_private.armor_absorb_packet_v1(uuid,uuid,uuid,uuid,integer)","combat_panel_private.nara_adv_pool_v1(uuid)","combat_panel_private.nara_adv_protected_v1(uuid)","combat_panel_private.nara_adv_scope_v1(uuid)","combat_panel_private.nara_adv_prepare_v1(uuid,uuid)","combat_panel_private.nara_strangle_meta_v1(uuid)","combat_panel_private.nara_strangle_action_meta_v1(uuid,uuid,jsonb)","combat_panel_private.nara_strangle_bind_v1(uuid)","combat_panel_private.nara_strangle_parent_valid_v1(uuid)","combat_panel_private.nara_strangle_lifecycle_v1(uuid)","combat_panel_private.nara_strangle_packet_v1(uuid,uuid,uuid,text)","combat_panel_private.nara_strangle_resolve_v1(uuid)","combat_panel_private.nara_strangle_turn_v1(uuid,uuid,uuid,text)","combat_panel_private.nara_strangle_facts_revision_v1(jsonb)","combat_panel_private.nara_strangle_facts_v1(uuid,uuid)","combat_panel_private.nara_adv_history_guard_v1()","combat_panel_private.nara_strangle_end_event_v1()","combat_panel_private.nara_strangle_terminal_report_v1(uuid)","combat_panel_private.nara_strangle_lifecycle_context_v1(uuid)","combat_panel_private.nara_adv_offers_v1(uuid,bigint,jsonb)","combat_panel_private.nara_adv_commit_v1(jsonb)","combat_panel_private.nara_strangle_lifecycle_trigger_v1()"]$joint_absent$::jsonb)e WHERE to_regprocedure(e#>>'{}')IS NOT NULL)THEN RAISE EXCEPTION 'JOINT_NEW_PRIVATE_ALREADY_EXISTS';END IF;
IF(SELECT public.combat_v2_sha256(to_jsonb(t))FROM public.clan_techniques t WHERE id='0a15282f-d6b5-4ee3-ad52-7fac2525444d')IS DISTINCT FROM 'daa15e90ec69c7e0edd0768a3d3d9d835469e28a0f69e0d35ff5f685b7b3501b'THEN RAISE EXCEPTION 'JOINT_CATALOG_BASELINE_DRIFT';END IF;
IF(SELECT public.combat_v2_sha256(to_jsonb(t))FROM public.clan_techniques t WHERE id='687b058a-807d-4cf7-8bcf-21147931b0f6')IS DISTINCT FROM '034572022439f0fdd6be8f1c4aa45f579e8bb2abdbc7080ced858cbf72cb39f6'THEN RAISE EXCEPTION 'JOINT_CATALOG_BASELINE_DRIFT';END IF;
IF(SELECT public.combat_v2_sha256(to_jsonb(t))FROM public.clan_techniques t WHERE id='f5f26cb5-9b6f-44b3-94bc-c329a0a88b93')IS DISTINCT FROM '06b46beca8f5d11edd9e1eb6b7f048d105aaa9d1771e5f00600ff6e6bdb4f1fe'THEN RAISE EXCEPTION 'JOINT_CATALOG_BASELINE_DRIFT';END IF;
END $joint_pre$;

-- Recovered aggregate1 private source, current component; no enable/apply/provider.
CREATE SCHEMA combat_v2_staff_nb_internal AUTHORIZATION postgres;
CREATE TABLE combat_v2_staff_nb_internal.gate(
 singleton boolean PRIMARY KEY CHECK(singleton),staff_enabled boolean NOT NULL,
 public_enabled boolean NOT NULL CHECK(public_enabled IS FALSE),version integer NOT NULL CHECK(version=1));
INSERT INTO combat_v2_staff_nb_internal.gate VALUES(true,false,false,1);
CREATE TABLE combat_v2_staff_nb_internal.roster_sources(
 id uuid PRIMARY KEY DEFAULT gen_random_uuid(),master_session_id uuid NOT NULL REFERENCES public.master_v2_sessions(id),
 context_id uuid NOT NULL REFERENCES combat_panel_private.contexts(id),context_version bigint NOT NULL,
 principal_user uuid NOT NULL,master_control_version bigint NOT NULL,
 mechanical_version_id uuid NOT NULL REFERENCES public.nb_mechanical_versions(id),
 source jsonb NOT NULL CHECK(jsonb_typeof(source)='object'),source_sha256 text NOT NULL CHECK(source_sha256 ~ '^[0-9a-f]{64}$'),
 state text NOT NULL DEFAULT 'offered' CHECK(state IN('offered','consumed','closed')),
 created_at timestamptz NOT NULL DEFAULT clock_timestamp(),
 UNIQUE(id,master_session_id),UNIQUE(context_id,context_version,mechanical_version_id));
CREATE TABLE combat_v2_staff_nb_internal.admissions(
 source_id uuid PRIMARY KEY,
 master_session_id uuid NOT NULL UNIQUE REFERENCES public.master_v2_sessions(id),
 request_id uuid NOT NULL,principal_user uuid NOT NULL,transaction_id bigint NOT NULL,backend_pid integer NOT NULL,
 event_id uuid NOT NULL REFERENCES public.combat_v2_events(id),offer_ref uuid NOT NULL UNIQUE,
 encounter_id uuid UNIQUE REFERENCES public.combat_v2_sessions(id),
 receipt jsonb,receipt_sha256 text CHECK(receipt_sha256 ~ '^[0-9a-f]{64}$'),
 FOREIGN KEY(source_id,master_session_id) REFERENCES combat_v2_staff_nb_internal.roster_sources(id,master_session_id) ON DELETE RESTRICT,
 UNIQUE(principal_user,request_id),CHECK((receipt IS NULL)=(receipt_sha256 IS NULL)),
 CHECK((encounter_id IS NULL)=(receipt IS NULL)));
ALTER TABLE public.master_v2_nb_actor_offers_v1 ADD COLUMN staff_combat_source_id uuid;
ALTER TABLE public.master_v2_nb_actor_offers_v1 ADD CONSTRAINT master_v2_nb_offer_staff_combat_source_fk
 FOREIGN KEY(staff_combat_source_id,master_session_id)
 REFERENCES combat_v2_staff_nb_internal.roster_sources(id,master_session_id) ON DELETE RESTRICT;
ALTER TABLE public.master_v2_nb_actor_offers_v1 DROP CONSTRAINT master_v2_nb_offer_source_kind_check;
ALTER TABLE public.master_v2_nb_actor_offers_v1 ADD CONSTRAINT master_v2_nb_offer_source_kind_check
 CHECK(source_kind=ANY(ARRAY['mission','quest','staff_combat']::text[]));
ALTER TABLE public.master_v2_nb_actor_offers_v1 DROP CONSTRAINT master_v2_nb_offer_source_identity_check;
ALTER TABLE public.master_v2_nb_actor_offers_v1 ADD CONSTRAINT master_v2_nb_offer_source_identity_check CHECK(
 (source_kind='mission' AND mission_id IS NOT NULL AND quest_episode_id IS NULL AND quest_source_sha256 IS NULL AND staff_combat_source_id IS NULL)
 OR(source_kind='quest' AND mission_id IS NULL AND quest_episode_id IS NOT NULL AND quest_source_sha256 ~ '^[0-9a-f]{64}$' AND staff_combat_source_id IS NULL)
 OR(source_kind='staff_combat' AND mission_id IS NULL AND quest_episode_id IS NULL AND quest_source_sha256 IS NULL AND staff_combat_source_id IS NOT NULL));
ALTER TABLE combat_v2_staff_nb_internal.admissions ADD CONSTRAINT staff_nb_admission_offer_fk
 FOREIGN KEY(offer_ref) REFERENCES public.master_v2_nb_actor_offers_v1(offer_ref) ON DELETE RESTRICT DEFERRABLE INITIALLY DEFERRED;
ALTER TABLE combat_v2_staff_nb_internal.gate ENABLE ROW LEVEL SECURITY;
ALTER TABLE combat_v2_staff_nb_internal.gate FORCE ROW LEVEL SECURITY;
ALTER TABLE combat_v2_staff_nb_internal.roster_sources ENABLE ROW LEVEL SECURITY;
ALTER TABLE combat_v2_staff_nb_internal.roster_sources FORCE ROW LEVEL SECURITY;
ALTER TABLE combat_v2_staff_nb_internal.admissions ENABLE ROW LEVEL SECURITY;
ALTER TABLE combat_v2_staff_nb_internal.admissions FORCE ROW LEVEL SECURITY;
-- COMPONENTE SOURCE: nessun apply autonomo. Integrare i delta comuni e la Root.
CREATE TABLE clan_aburame_private.verme_gate_v1 (
 singleton boolean PRIMARY KEY DEFAULT true CHECK(singleton),
 staff_enabled boolean NOT NULL DEFAULT false, public_enabled boolean NOT NULL DEFAULT false,
 contract_version text NOT NULL DEFAULT 'aburame-verme/1' CHECK(contract_version='aburame-verme/1')
);
INSERT INTO clan_aburame_private.verme_gate_v1 VALUES(true,false,false,'aburame-verme/1');
CREATE TABLE clan_aburame_private.verme_staff_profiles_v1 (
 actor_id uuid PRIMARY KEY REFERENCES public.combat_v2_actors(id),
 session_id uuid NOT NULL REFERENCES public.combat_v2_sessions(id),
 controller_user uuid NOT NULL, controller_version bigint NOT NULL,
 request_key uuid NOT NULL UNIQUE, original_snapshot_sha256 text NOT NULL CHECK(length(original_snapshot_sha256)=64),
 profile jsonb NOT NULL, profile_sha256 text NOT NULL CHECK(length(profile_sha256)=64),
 created_at timestamptz NOT NULL DEFAULT clock_timestamp()
);
CREATE TABLE clan_aburame_private.verme_sources_v1 (
 declaration_id uuid PRIMARY KEY REFERENCES public.combat_v2_declarations(id),
 session_id uuid NOT NULL REFERENCES public.combat_v2_sessions(id), round_id uuid NOT NULL REFERENCES public.combat_v2_rounds(id),
 actor_id uuid NOT NULL REFERENCES public.combat_v2_actors(id), target_actor_id uuid NOT NULL REFERENCES public.combat_v2_actors(id),
 owner_character_id uuid NOT NULL REFERENCES public.characters(id),
 scope_id uuid NOT NULL, scope_kind text NOT NULL CHECK(scope_kind IN('simulation','persistent')),
 request_key uuid NOT NULL UNIQUE, controller_user uuid NOT NULL, declaration_principal uuid NOT NULL, controller_version bigint NOT NULL,
 profile jsonb NOT NULL, profile_sha256 text NOT NULL CHECK(length(profile_sha256)=64),
 state text NOT NULL DEFAULT 'prepared' CHECK(state IN('prepared','resolved','ended')),
 colony_reserved boolean NOT NULL DEFAULT false,
 result jsonb, created_at timestamptz NOT NULL DEFAULT clock_timestamp(), ended_at timestamptz,
 CHECK((state='prepared')=(ended_at IS NULL))
);
CREATE TABLE clan_aburame_private.verme_poison_v1 (
 session_id uuid NOT NULL REFERENCES public.combat_v2_sessions(id), target_actor_id uuid NOT NULL REFERENCES public.combat_v2_actors(id),
 id uuid NOT NULL UNIQUE DEFAULT gen_random_uuid(), source_actor_id uuid NOT NULL REFERENCES public.combat_v2_actors(id),
 source_declaration_id uuid NOT NULL REFERENCES public.combat_v2_declarations(id),
 generation bigint NOT NULL DEFAULT 1 CHECK(generation>0),
 excluded_turn_id uuid, remaining_turns integer NOT NULL DEFAULT 2 CHECK(remaining_turns BETWEEN 0 AND 2),
 end_reason text, last_tick_turn_id uuid, updated_at timestamptz NOT NULL DEFAULT clock_timestamp(),
 PRIMARY KEY(session_id,target_actor_id)
);
CREATE TABLE clan_aburame_private.verme_events_v1 (
 event_key text PRIMARY KEY, session_id uuid NOT NULL REFERENCES public.combat_v2_sessions(id),
 round_id uuid REFERENCES public.combat_v2_rounds(id), actor_id uuid NOT NULL REFERENCES public.combat_v2_actors(id),
 target_actor_id uuid REFERENCES public.combat_v2_actors(id), declaration_id uuid REFERENCES public.combat_v2_declarations(id),
 kind text NOT NULL CHECK(kind IN('prepared','released','poison_applied','poison_refreshed','poison_tick','poison_end','staff_prepared')),
 facts jsonb NOT NULL, facts_sha256 text NOT NULL CHECK(length(facts_sha256)=64),
 created_at timestamptz NOT NULL DEFAULT clock_timestamp()
);
ALTER TABLE clan_aburame_private.verme_gate_v1 ENABLE ROW LEVEL SECURITY;
ALTER TABLE clan_aburame_private.verme_gate_v1 FORCE ROW LEVEL SECURITY;
ALTER TABLE clan_aburame_private.verme_staff_profiles_v1 ENABLE ROW LEVEL SECURITY;
ALTER TABLE clan_aburame_private.verme_staff_profiles_v1 FORCE ROW LEVEL SECURITY;
ALTER TABLE clan_aburame_private.verme_sources_v1 ENABLE ROW LEVEL SECURITY;
ALTER TABLE clan_aburame_private.verme_sources_v1 FORCE ROW LEVEL SECURITY;
ALTER TABLE clan_aburame_private.verme_poison_v1 ENABLE ROW LEVEL SECURITY;
ALTER TABLE clan_aburame_private.verme_poison_v1 FORCE ROW LEVEL SECURITY;
ALTER TABLE clan_aburame_private.verme_events_v1 ENABLE ROW LEVEL SECURITY;
ALTER TABLE clan_aburame_private.verme_events_v1 FORCE ROW LEVEL SECURITY;
-- Component Akimichi common/1: Super Espansione and Difesa Cellulare.
-- Private functions are reached only through the existing panel and native ports.
CREATE TABLE clan_akimichi_private.common_gate_v1 (
 singleton boolean PRIMARY KEY DEFAULT true CHECK(singleton),
 contract_version text NOT NULL CHECK(contract_version='akimichi-common/1'),
 staff_enabled boolean NOT NULL DEFAULT false,
 public_enabled boolean NOT NULL DEFAULT false,
 super_public_enabled boolean NOT NULL DEFAULT false,
 cellular_public_enabled boolean NOT NULL DEFAULT false
);
INSERT INTO clan_akimichi_private.common_gate_v1 VALUES(true,'akimichi-common/1',false,false,false,false);
ALTER TABLE clan_akimichi_private.forms ADD COLUMN form_kind text NOT NULL DEFAULT 'base';
ALTER TABLE clan_akimichi_private.forms ADD CONSTRAINT akimichi_form_kind_v1 CHECK(form_kind IN('base','super'));
CREATE TABLE clan_akimichi_private.common_staff_profiles_v1 (
 actor_id uuid PRIMARY KEY REFERENCES public.combat_v2_actors(id),
 session_id uuid NOT NULL REFERENCES public.combat_v2_sessions(id),
 context_id uuid NOT NULL REFERENCES combat_panel_private.contexts(id),
 character_id uuid NOT NULL REFERENCES public.characters(id),
 controller_user uuid NOT NULL, controller_version bigint NOT NULL,
 request_key uuid NOT NULL UNIQUE, profile jsonb NOT NULL,
 profile_sha256 text NOT NULL CHECK(profile_sha256 ~ '^[0-9a-f]{64}$'),
 created_at timestamptz NOT NULL DEFAULT clock_timestamp()
);
CREATE TABLE clan_akimichi_private.common_form_commands_v1 (
 actor_id uuid NOT NULL REFERENCES public.combat_v2_actors(id),
 session_id uuid NOT NULL REFERENCES public.combat_v2_sessions(id),
 event_id uuid NOT NULL, form_kind text NOT NULL CHECK(form_kind IN('base','super','off')),
 result jsonb NOT NULL, PRIMARY KEY(actor_id,session_id,event_id)
);
CREATE TABLE clan_akimichi_private.common_attack_powers_v1 (
 declaration_id uuid PRIMARY KEY REFERENCES public.combat_v2_declarations(id),
 round_id uuid NOT NULL REFERENCES public.combat_v2_rounds(id),
 actor_id uuid NOT NULL REFERENCES public.combat_v2_actors(id),
 declaration_sha256 text NOT NULL CHECK(declaration_sha256 ~ '^[0-9a-f]{64}$'),
 profile jsonb NOT NULL, source_sha256 text NOT NULL CHECK(source_sha256 ~ '^[0-9a-f]{64}$')
);
CREATE TABLE clan_akimichi_private.common_pending_upkeep_v1 (
 actor_id uuid NOT NULL REFERENCES public.combat_v2_actors(id),
 session_id uuid NOT NULL REFERENCES public.combat_v2_sessions(id),
 personal_turn_id uuid NOT NULL, form_kind text NOT NULL CHECK(form_kind IN('base','super')),
 state text NOT NULL DEFAULT 'pending' CHECK(state IN('pending','paid','replaced','ended')),
 receipt jsonb, PRIMARY KEY(actor_id,session_id,personal_turn_id)
);
CREATE UNIQUE INDEX akimichi_common_one_pending_upkeep_v1
 ON clan_akimichi_private.common_pending_upkeep_v1(actor_id,session_id) WHERE state='pending';
CREATE TABLE clan_akimichi_private.cellular_sources_v1 (
 declaration_id uuid PRIMARY KEY REFERENCES public.combat_v2_declarations(id),
 attack_declaration_id uuid NOT NULL REFERENCES public.combat_v2_declarations(id),
 actor_id uuid NOT NULL REFERENCES public.combat_v2_actors(id),
 session_id uuid NOT NULL REFERENCES public.combat_v2_sessions(id),
 round_id uuid NOT NULL REFERENCES public.combat_v2_rounds(id),
 owner_id uuid NOT NULL REFERENCES public.characters(id), scope_id uuid NOT NULL,
 simulated boolean NOT NULL, controller_version bigint NOT NULL,
 permanent_kg integer NOT NULL CHECK(permanent_kg>=0),
 permanent_resistance integer NOT NULL CHECK(permanent_resistance>=0),
 profile jsonb NOT NULL, source_sha256 text NOT NULL CHECK(source_sha256 ~ '^[0-9a-f]{64}$'),
 calorie_receipt jsonb, UNIQUE(attack_declaration_id,actor_id),
 CHECK((scope_id<>owner_id)=simulated)
);
ALTER TABLE clan_akimichi_private.common_gate_v1 ENABLE ROW LEVEL SECURITY;
ALTER TABLE clan_akimichi_private.common_staff_profiles_v1 ENABLE ROW LEVEL SECURITY;
ALTER TABLE clan_akimichi_private.common_form_commands_v1 ENABLE ROW LEVEL SECURITY;
ALTER TABLE clan_akimichi_private.common_attack_powers_v1 ENABLE ROW LEVEL SECURITY;
ALTER TABLE clan_akimichi_private.common_pending_upkeep_v1 ENABLE ROW LEVEL SECURITY;
ALTER TABLE clan_akimichi_private.cellular_sources_v1 ENABLE ROW LEVEL SECURITY;
-- Single Staff-only Nara profile; the original Possesso and pools remain native.
CREATE TABLE combat_panel_private.nara_adv_gate_v1(singleton boolean PRIMARY KEY DEFAULT true CHECK(singleton),staff_enabled boolean NOT NULL DEFAULT false,public_enabled boolean NOT NULL DEFAULT false CHECK(NOT public_enabled));
INSERT INTO combat_panel_private.nara_adv_gate_v1 VALUES(true,false,false);
CREATE TABLE combat_panel_private.nara_adv_staff_v1(actor_id uuid PRIMARY KEY REFERENCES public.combat_v2_actors,session_id uuid NOT NULL REFERENCES public.combat_v2_sessions,controller_user uuid NOT NULL,controller_version bigint NOT NULL,profile jsonb NOT NULL,profile_sha256 text NOT NULL);
CREATE TABLE combat_panel_private.nara_strangle_sources_v1(declaration_id uuid PRIMARY KEY REFERENCES public.combat_v2_declarations,session_id uuid NOT NULL REFERENCES public.combat_v2_sessions,actor_id uuid NOT NULL REFERENCES public.combat_v2_actors,target_actor_id uuid NOT NULL REFERENCES public.combat_v2_actors,parent_id uuid NOT NULL REFERENCES combat_panel_private.immobilizations,profile jsonb NOT NULL,profile_sha256 text NOT NULL,state text NOT NULL DEFAULT 'prepared' CHECK(state IN('prepared','active','ended')),end_reason text,activation_turn uuid NOT NULL);
CREATE UNIQUE INDEX nara_strangle_one_active_parent_v1 ON combat_panel_private.nara_strangle_sources_v1(parent_id) WHERE state IN('prepared','active');
CREATE TABLE combat_panel_private.nara_strangle_events_v1(event_id uuid PRIMARY KEY,source_declaration uuid NOT NULL REFERENCES combat_panel_private.nara_strangle_sources_v1,session_id uuid NOT NULL REFERENCES public.combat_v2_sessions,round_id uuid NOT NULL REFERENCES public.combat_v2_rounds,turn_id uuid NOT NULL,kind text NOT NULL CHECK(kind IN('activation','upkeep','ended')),facts jsonb NOT NULL,facts_sha256 text NOT NULL,created_at timestamptz NOT NULL DEFAULT clock_timestamp());
ALTER TABLE combat_panel_private.nara_adv_gate_v1 ENABLE ROW LEVEL SECURITY;
ALTER TABLE combat_panel_private.nara_adv_gate_v1 FORCE ROW LEVEL SECURITY;
ALTER TABLE combat_panel_private.nara_adv_staff_v1 ENABLE ROW LEVEL SECURITY;
ALTER TABLE combat_panel_private.nara_adv_staff_v1 FORCE ROW LEVEL SECURITY;
ALTER TABLE combat_panel_private.nara_strangle_sources_v1 ENABLE ROW LEVEL SECURITY;
ALTER TABLE combat_panel_private.nara_strangle_sources_v1 FORCE ROW LEVEL SECURITY;
ALTER TABLE combat_panel_private.nara_strangle_events_v1 ENABLE ROW LEVEL SECURITY;
ALTER TABLE combat_panel_private.nara_strangle_events_v1 FORCE ROW LEVEL SECURITY;
CREATE FUNCTION combat_v2_staff_nb_internal.origin_guard() RETURNS trigger LANGUAGE plpgsql SECURITY DEFINER SET search_path='' AS $nb$
BEGIN
 IF TG_OP<>'UPDATE' OR (to_jsonb(NEW)-'state') IS DISTINCT FROM (to_jsonb(OLD)-'state')
 OR OLD.state='closed' OR(OLD.state='consumed' AND NEW.state NOT IN('consumed','closed')) THEN
  RAISE EXCEPTION 'staff_nb_origin_immutable' USING ERRCODE='42501';END IF;RETURN NEW;
END $nb$;
CREATE FUNCTION combat_v2_staff_nb_internal.choice(p_mechanical_version uuid) RETURNS jsonb LANGUAGE plpgsql STABLE SECURITY DEFINER SET search_path='' AS $nb$
DECLARE nt public.nb_templates%ROWTYPE;nv public.nb_template_versions%ROWTYPE;b public.nb_mechanical_bindings%ROWTYPE;
 mt public.nb_mechanical_templates%ROWTYPE;mv public.nb_mechanical_versions%ROWTYPE;expected text;kai jsonb;
BEGIN
 expected:=CASE p_mechanical_version
 WHEN '31da0000-0000-4000-8000-000000000111'::uuid THEN '5581b06099e588b27361cdf75e0e6265475c330802f61034c6ad67ca3d381ad2'
 WHEN '31da0000-0000-4000-8000-000000000112'::uuid THEN 'bbe92ed1b3dd171c6498f1a1541ad6b391c80e015956ae748c1eeece17f99fac' ELSE NULL END;
 IF expected IS NULL THEN RETURN NULL;END IF;
 SELECT * INTO mv FROM public.nb_mechanical_versions WHERE id=p_mechanical_version AND review_state='approved' AND content_sha256=expected;
 IF mv.id IS NULL OR mv.profile_kind='npc_custom' OR mv.template_id IS DISTINCT FROM (CASE WHEN mv.id='31da0000-0000-4000-8000-000000000111'::uuid
  THEN '31da0000-0000-4000-8000-000000000101'::uuid ELSE '31da0000-0000-4000-8000-000000000102'::uuid END) THEN RETURN NULL;END IF;
 SELECT * INTO mt FROM public.nb_mechanical_templates WHERE id=mv.template_id AND active AND lifecycle_state='approved' AND current_version_id=mv.id;
 IF mt.id IS NULL OR(SELECT count(*) FROM public.nb_mechanical_bindings WHERE mechanical_version_id=mv.id AND active AND lifecycle_state='approved')<>1 THEN RETURN NULL;END IF;
 SELECT * INTO STRICT b FROM public.nb_mechanical_bindings WHERE mechanical_version_id=mv.id AND active AND lifecycle_state='approved';
 SELECT * INTO nt FROM public.nb_templates WHERE id=b.narrative_template_id AND lifecycle_state='approved' AND current_version_id=b.narrative_version_id;
 SELECT * INTO nv FROM public.nb_template_versions WHERE id=b.narrative_version_id AND template_id=nt.id AND review_state='approved';
 IF nt.id IS NULL OR nv.id IS NULL OR jsonb_typeof(mv.stats->'mente') IS DISTINCT FROM 'number'
 OR jsonb_typeof(mv.stats->'genjutsu') IS DISTINCT FROM 'number' OR(mv.stats->>'mente')::numeric<20
 OR(SELECT count(*) FROM jsonb_array_elements(mv.abilities) x WHERE x->>'source'='jutsu' AND x->>'id'='9f12fc98-bc97-4b95-9bcc-7ce359ebbe4f')<>1 THEN RETURN NULL;END IF;
 SELECT value INTO STRICT kai FROM jsonb_array_elements(mv.abilities) WHERE value->>'source'='jutsu' AND value->>'id'='9f12fc98-bc97-4b95-9bcc-7ce359ebbe4f';
 IF kai->'chakra_cost' IS DISTINCT FROM '0'::jsonb OR kai->>'usage' IS DISTINCT FROM 'difesa' OR kai->'defensive' IS DISTINCT FROM 'true'::jsonb THEN RETURN NULL;END IF;
 RETURN jsonb_build_object('mechanical_template_id',mt.id,'mechanical_version_id',mv.id,'mechanical_template_control_version',mt.control_version,
 'mechanical_version_control_version',mv.control_version,'mechanical_sha256',mv.content_sha256,'binding_id',b.id,'binding_control_version',b.control_version,
 'narrative_template_id',nt.id,'narrative_version_id',nv.id,'narrative_template_control_version',nt.control_version,
 'narrative_version_control_version',nv.control_version,'narrative_sha256',nv.content_sha256,'name',nt.display_name,'stats',mv.stats,'abilities',mv.abilities,'kai',kai);
END $nb$;
CREATE FUNCTION combat_v2_staff_nb_internal.roster_offers(p_context uuid,p_expected bigint,p_master uuid) RETURNS void LANGUAGE plpgsql SECURITY DEFINER SET search_path='' AS $nb$
DECLARE c combat_panel_private.contexts%ROWTYPE;m public.master_v2_sessions%ROWTYPE;v uuid;tuple jsonb;src jsonb;sid uuid;oid uuid;gid uuid;
BEGIN
 c:=combat_panel_private.owned_context(p_context,p_expected);
 IF c.activity_kind<>'master_v2' OR c.round_id IS NOT NULL OR NOT combat_v2_staff_nb_internal.preparation_allowed(p_master) THEN RETURN;END IF;
 SELECT * INTO STRICT m FROM public.master_v2_sessions WHERE id=p_master AND location_id=c.location_id;
 IF EXISTS(SELECT 1 FROM combat_panel_private.offers WHERE context_id=c.id AND context_version=c.context_version
 AND state='offered' AND source_payload->>'dispatch'='staff_native_roster') THEN RETURN;END IF;
 -- No zero-choice offer. Both approved choices must still be representable.
 IF combat_v2_staff_nb_internal.choice('31da0000-0000-4000-8000-000000000111') IS NULL
 OR combat_v2_staff_nb_internal.choice('31da0000-0000-4000-8000-000000000112') IS NULL THEN RETURN;END IF;
 oid:=combat_panel_private.create_offer(c.id,c.context_version,'administration','administration','Prepara partecipanti con PNG NinjaBook',false,
 jsonb_build_object('adapter','master_v2','dispatch','staff_native_roster','master_session_id',m.id,'control_version',m.control_version));
 gid:=combat_panel_private.add_group(oid,'Soccorritore NinjaBook','generic','single',1,1);
 FOREACH v IN ARRAY ARRAY['31da0000-0000-4000-8000-000000000111'::uuid,'31da0000-0000-4000-8000-000000000112'::uuid] LOOP
  tuple:=combat_v2_staff_nb_internal.choice(v);
  src:=jsonb_build_object('contract','staff-nb-roster/1','master_session_id',m.id,'master_control_version',m.control_version,
   'principal_user',auth.uid(),'context_id',c.id,'context_version',c.context_version,'scene_version',c.scene_version,
   'source_fingerprint',c.source_fingerprint,'tuple',tuple,'pg_ids',jsonb_build_array('2a877f02-4993-4e65-9172-7d29f08c5b86','6bceee99-974f-426b-8d92-38b43b4a4267'),
   'pg_teams',jsonb_build_object('2a877f02-4993-4e65-9172-7d29f08c5b86','A','6bceee99-974f-426b-8d92-38b43b4a4267','B'),'png_team','B');
  INSERT INTO combat_v2_staff_nb_internal.roster_sources(master_session_id,context_id,context_version,principal_user,master_control_version,mechanical_version_id,source,source_sha256)
  VALUES(m.id,c.id,c.context_version,auth.uid(),m.control_version,v,src,public.combat_v2_sha256(src))
  ON CONFLICT(context_id,context_version,mechanical_version_id) DO NOTHING;
  SELECT id INTO STRICT sid FROM combat_v2_staff_nb_internal.roster_sources WHERE context_id=c.id AND context_version=c.context_version
   AND mechanical_version_id=v AND state='offered' AND source=src AND source_sha256=public.combat_v2_sha256(src);
  PERFORM combat_panel_private.add_choice(gid,tuple->>'name',jsonb_build_object('staff_roster_source_id',sid));
 END LOOP;
END $nb$;
CREATE FUNCTION combat_v2_staff_nb_internal.native_construct(p_master_session uuid,p_pg_ids uuid[],p_actor_offers jsonb,p_team_map jsonb,p_request_key uuid,p_event_id uuid)
RETURNS jsonb LANGUAGE plpgsql SECURITY DEFINER SET search_path='' AS $nb$
DECLARE v_uid uuid:=auth.uid();v_m public.master_v2_sessions%ROWTYPE;v_event_id uuid:=p_event_id;
 v_enc uuid;v_round uuid;v_pg uuid;v_snap jsonb;v_team text;v_spec jsonb;
 v_offer public.master_v2_nb_actor_offers_v1%ROWTYPE;v_nt public.nb_templates%ROWTYPE;
 v_nv public.nb_template_versions%ROWTYPE;v_b public.nb_mechanical_bindings%ROWTYPE;
 v_mt public.nb_mechanical_templates%ROWTYPE;v_mv public.nb_mechanical_versions%ROWTYPE;
 v_instance uuid;v_mode text;v_result jsonb;v_client uuid;v_offer_ref uuid;
BEGIN
 SELECT * INTO STRICT v_m FROM public.master_v2_sessions WHERE id=p_master_session FOR UPDATE;
 IF p_event_id IS NULL OR NOT EXISTS(SELECT 1 FROM public.combat_v2_events WHERE id=p_event_id AND scope_id=p_master_session
 AND request_key=p_request_key) THEN RAISE EXCEPTION 'native_nb_constructor_requires_event';END IF;
  -- Ordine lock: sessione Master -> offer UUID -> narrative/binding/mechanical UUID.
  perform 1 from public.master_v2_nb_actor_offers_v1 o
   where o.offer_ref in (select (x->>'offer_ref')::uuid from jsonb_array_elements(p_actor_offers) x)
   order by o.offer_ref for update;
  if (select count(*) from public.master_v2_nb_actor_offers_v1 o
      where o.offer_ref in (select (x->>'offer_ref')::uuid from jsonb_array_elements(p_actor_offers) x))<>jsonb_array_length(p_actor_offers) then
    perform public.master_v2_nb_fail_v1('opzione_non_offerta','Opzione non offerta.',422,p_request_key);
  end if;
  perform 1 from public.nb_template_versions v where v.id in(
    select o.narrative_version_id from public.master_v2_nb_actor_offers_v1 o
    where o.offer_ref in(select (x->>'offer_ref')::uuid from jsonb_array_elements(p_actor_offers)x)) order by v.id for update;
  perform 1 from public.nb_templates t where t.id in(
    select o.narrative_template_id from public.master_v2_nb_actor_offers_v1 o
    where o.offer_ref in(select (x->>'offer_ref')::uuid from jsonb_array_elements(p_actor_offers)x)) order by t.id for update;
  perform 1 from public.nb_mechanical_bindings b where b.narrative_version_id in(
    select o.narrative_version_id from public.master_v2_nb_actor_offers_v1 o
    where o.offer_ref in(select (x->>'offer_ref')::uuid from jsonb_array_elements(p_actor_offers)x)) order by b.id for update;
  perform 1 from public.nb_mechanical_versions v where v.id in(
    select o.mechanical_version_id from public.master_v2_nb_actor_offers_v1 o
    where o.offer_ref in(select (x->>'offer_ref')::uuid from jsonb_array_elements(p_actor_offers)x)) order by v.id for update;
  perform 1 from public.nb_mechanical_templates t where t.id in(
    select o.mechanical_template_id from public.master_v2_nb_actor_offers_v1 o
    where o.offer_ref in(select (x->>'offer_ref')::uuid from jsonb_array_elements(p_actor_offers)x)) order by t.id for update;

  -- Risolve e congela tutto prima del primo INSERT di sessione/istanza.
  for v_spec in select value from jsonb_array_elements(p_actor_offers) order by value->>'offer_ref' loop
    v_client:=(v_spec->>'client_ref')::uuid; v_offer_ref:=(v_spec->>'offer_ref')::uuid;
    select * into v_offer from public.master_v2_nb_actor_offers_v1 where offer_ref=v_offer_ref;
    if v_offer.master_session_id<>p_master_session or v_offer.recipient_user<>v_m.master_user
       or v_offer.lifecycle_state<>'offerta' or v_offer.expires_at<=clock_timestamp() then
      perform public.master_v2_nb_fail_v1('opzione_non_offerta','Opzione non offerta.',422,p_request_key);
    end if;
    select * into v_nv from public.nb_template_versions where id=v_offer.narrative_version_id and template_id=v_offer.narrative_template_id;
    select * into v_nt from public.nb_templates where id=v_offer.narrative_template_id;
    select * into v_b from public.nb_mechanical_bindings where narrative_version_id=v_offer.narrative_version_id;
    select * into v_mv from public.nb_mechanical_versions where id=v_offer.mechanical_version_id and template_id=v_offer.mechanical_template_id;
    select * into v_mt from public.nb_mechanical_templates where id=v_offer.mechanical_template_id;

    if v_nt.id is null or v_nv.id is null or v_b.id is null or v_mt.id is null or v_mv.id is null
       or v_nt.lifecycle_state<>'approved' or v_nt.current_version_id<>v_nv.id or v_nv.review_state<>'approved'
       or v_b.lifecycle_state<>'approved' or not v_b.active
       or v_b.mechanical_template_id<>v_mt.id or v_b.mechanical_version_id<>v_mv.id
       or v_mt.lifecycle_state<>'approved' or not v_mt.active or v_mt.current_version_id<>v_mv.id
       or v_mv.review_state<>'approved' then
      perform public.master_v2_nb_fail_v1('opzione_non_offerta','Opzione non offerta.',422,p_request_key);
    end if;
    if v_offer.expected_master_control_version<>v_m.control_version
       or v_offer.expected_narrative_template_control_version<>v_nt.control_version
       or v_offer.expected_narrative_version_control_version<>v_nv.control_version
       or v_offer.expected_binding_control_version<>v_b.control_version
       or v_offer.expected_mechanical_template_control_version<>v_mt.control_version
       or v_offer.expected_mechanical_version_control_version<>v_mv.control_version
       or v_offer.expected_narrative_sha256<>v_nv.content_sha256
       or v_offer.expected_mechanical_sha256<>v_mv.content_sha256 then
      perform public.master_v2_nb_fail_v1('versione_provider_obsoleta','L’offerta provider è obsoleta.',409,p_request_key);
    end if;
    v_team:=nullif(btrim(p_team_map->>v_client::text),'');
    if v_team is null then perform public.master_v2_nb_fail_v1('intento_non_valido','Squadra provider mancante.',422,p_request_key); end if;
  end loop;

  insert into public.combat_v2_sessions(source_kind,master_session_id,location_id,state,lesiva)
  values('master',p_master_session,v_m.location_id,'in_corso',not exists(select 1 from public.locations l where l.id=v_m.location_id and l.is_test)) returning id into v_enc;
  foreach v_pg in array p_pg_ids loop
    v_snap:=mission_creation_owner.carry_snapshot(p_master_session,v_pg,null,public.combat_v2_character_snapshot(v_pg)); v_team:=nullif(btrim(p_team_map->>v_pg::text),'');
    if v_snap is null or v_team is null then perform public.master_v2_nb_fail_v1('intento_non_valido','Snapshot o squadra PG non disponibile.',422,p_request_key); end if;
    insert into public.combat_v2_actors(session_id,actor_kind,character_id,controller_user,team_key,position_m,initiative_snapshot,mechanics_snapshot)
    select v_enc,'pg',c.id,c.user_id,v_team,0,c.velocita,v_snap from public.characters c where c.id=v_pg;
    insert into public.master_v2_participants(session_id,character_id,user_id_snapshot)
    select p_master_session,c.id,c.user_id from public.characters c where c.id=v_pg on conflict(session_id,character_id) do nothing;
  end loop;
  for v_spec in select value from jsonb_array_elements(p_actor_offers) order by value->>'offer_ref' loop
    v_client:=(v_spec->>'client_ref')::uuid; v_offer_ref:=(v_spec->>'offer_ref')::uuid;
    select * into v_offer from public.master_v2_nb_actor_offers_v1 where offer_ref=v_offer_ref;
    select * into v_nt from public.nb_templates where id=v_offer.narrative_template_id;
    select * into v_mv from public.nb_mechanical_versions where id=v_offer.mechanical_version_id;
    v_team:=nullif(btrim(p_team_map->>v_client::text),'');
    v_snap:=jsonb_build_object('name',v_nt.display_name,'vita',v_mv.vita_max,'vita_max',v_mv.vita_max,
      'chakra',v_mv.chakra_max,'chakra_max',v_mv.chakra_max,
      'taijutsu',(v_mv.stats->>'taijutsu')::integer,'ninjutsu',(v_mv.stats->>'ninjutsu')::integer,
      'genjutsu',(v_mv.stats->>'genjutsu')::integer,'forza',(v_mv.stats->>'forza')::integer,
      'velocita',(v_mv.stats->>'velocita')::integer,'mente',(v_mv.stats->>'mente')::integer,
      'resistenza',(v_mv.stats->>'resistenza')::integer,'fuuinjutsu',(v_mv.stats->>'fuuinjutsu')::integer,
      'slancio',0,'abilities',v_mv.abilities);
    v_snap:=mission_creation_owner.carry_snapshot(p_master_session,null,v_client,v_snap);
    insert into public.combat_v2_provider_instances_v1(session_id,client_ref,provider,offer_ref,
      narrative_template_ref,narrative_version_ref,mechanical_template_ref,mechanical_version_ref,
      source_sha256,snapshot_sha256,nome,snapshot)
    values(v_enc,v_client,'ninja_book',v_offer_ref,v_offer.narrative_template_id,v_offer.narrative_version_id,
      v_offer.mechanical_template_id,v_offer.mechanical_version_id,v_mv.content_sha256,public.combat_v2_sha256(v_snap),v_nt.display_name,v_snap)
    returning id into v_instance;
    insert into public.combat_v2_actors(session_id,actor_kind,provider_instance_v1_id,controller_user,team_key,position_m,initiative_snapshot,mechanics_snapshot)
    values(v_enc,'png',v_instance,v_m.master_user,v_team,0,(v_mv.stats->>'velocita')::integer,v_snap);
    update public.master_v2_nb_actor_offers_v1 set lifecycle_state='consumata',consumed_event_id=v_event_id,
      consumed_at=clock_timestamp(),control_version=control_version+1,updated_at=clock_timestamp() where offer_ref=v_offer_ref;
    insert into public.master_v2_nb_offer_audit_v1(offer_ref,event_id,action,actor_user,details)
    values(v_offer_ref,v_event_id,'consumo',v_uid,jsonb_build_object('provider_instance_id',v_instance));
  end loop;
  select case when v_m.master_user is null then 'neutra' else 'umana' end into v_mode;
  insert into public.combat_v2_rounds(session_id,round_no,evaluation_mode) values(v_enc,1,v_mode) returning id into v_round;
  update public.master_v2_sessions set stato='in_corso' where id=p_master_session;
  if v_m.tipo='quest' and mission_internal.runtime_enabled()
     and exists(select 1 from public.mission_run_state where master_session_id=p_master_session and run_phase='preparazione') then
    perform mission_internal.sync_lifecycle(p_master_session,p_request_key,v_m.control_version,
      (select control_version from public.mission_run_state where master_session_id=p_master_session),'in_corso');
  end if;
  IF EXISTS(SELECT 1 FROM combat_panel_private.master_panel_sessions registered74 WHERE registered74.master_session_id=p_master_session)THEN
   perform clan_innata_narrative_private.materialize_v1(v_enc);
  END IF;
  v_result:=public.combat_v2_envelope(p_request_key,jsonb_build_object('encounter_id',v_enc,'round_id',v_round,'evaluation_mode',v_mode));
  return public.combat_v2_event_complete(v_event_id,v_result);
END $nb$;
-- Setup admission proves protected authority, not the existence of a bound arena.
-- Mechanical readiness is independently required by every NB-backed Para/Kai runtime authority.
CREATE FUNCTION combat_v2_staff_nb_internal.mechanics_ready(p_session uuid) RETURNS boolean LANGUAGE plpgsql STABLE SECURITY DEFINER SET search_path='' AS $nb$
DECLARE iid uuid;
BEGIN
 SELECT i.instance_id INTO iid FROM public.combat_v2_sessions s
 JOIN public.master_v2_sessions m ON m.id=s.master_session_id
 JOIN public.locations l ON l.id=s.location_id
 JOIN combat_panel_private.master_panel_sessions mp ON mp.master_session_id=m.id AND mp.location_id=l.id
 JOIN combat_spatial.arena_instances i ON i.encounter_id=s.id AND i.master_session_id=m.id AND i.context_source='panel_master' AND i.state='open'
 JOIN combat_panel_private.master_scene_claims cl ON cl.id=i.panel_claim_id AND cl.encounter_id=s.id AND cl.master_session_id=m.id
 JOIN combat_panel_private.master_scene_receipts receipt ON receipt.instance_id=i.instance_id AND receipt.claim_id=cl.id AND receipt.principal_user=m.master_user
 WHERE s.id=p_session AND s.source_kind='master' AND s.state='in_corso' AND s.closed_at IS NULL AND s.user_test_context_id IS NULL
 AND s.lesiva IS FALSE AND l.id='0b85f354-9cdb-47e1-baf9-3d266bb7e06b'::uuid AND l.is_active AND l.is_test
 AND mp.policy_id='staff_test_no_persistent_resources_v1' AND cl.policy_id=mp.policy_id
 AND cl.authority_principal_id=m.master_user AND cl.authority_control_version=m.control_version
 AND m.owner_kind='human' AND m.tipo='duello' AND m.mission_id IS NULL AND m.quest_kind IS NULL
 AND m.stato='in_corso' AND m.closed_at IS NULL AND m.suspended_at IS NULL;
 IF iid IS NULL OR public.combat_v2_values_written(p_session) IS DISTINCT FROM false THEN RETURN false;END IF;
 -- Mirror the native readiness invariant before invoking its owning assertion.
 IF EXISTS(SELECT 1 FROM public.combat_v2_actors a WHERE a.session_id=p_session AND a.state='attivo'
 AND NOT EXISTS(SELECT 1 FROM combat_spatial.actor_states b WHERE b.instance_id=iid AND b.actor_id=a.id AND b.state='active'
 AND b.controller_principal_id IS NOT DISTINCT FROM exam_regia_private.actor_principal(a.id,a.controller_user))) THEN RETURN false;END IF;
 PERFORM combat_panel_private.assert_master_ready(p_session);
 RETURN combat_panel_private.uses_simulated_pools(p_session) IS TRUE;
END $nb$;
CREATE FUNCTION combat_v2_staff_nb_internal.setup_protected(p_session uuid,p_source uuid) RETURNS boolean LANGUAGE plpgsql STABLE SECURITY DEFINER SET search_path='' AS $nb$
DECLARE eligible boolean;
BEGIN
 SELECT EXISTS(SELECT 1 FROM public.combat_v2_sessions s JOIN public.master_v2_sessions m ON m.id=s.master_session_id
 JOIN public.locations l ON l.id=s.location_id
 JOIN combat_panel_private.master_panel_sessions mp ON mp.master_session_id=m.id AND mp.location_id=l.id
 JOIN combat_v2_staff_nb_internal.roster_sources origin ON origin.id=p_source AND origin.master_session_id=m.id
 JOIN combat_v2_staff_nb_internal.admissions ad ON ad.source_id=origin.id AND ad.master_session_id=m.id
 JOIN combat_v2_staff_nb_internal.gate g ON g.singleton
 WHERE s.id=p_session AND s.source_kind='master' AND s.state='in_corso' AND s.closed_at IS NULL
 AND s.user_test_context_id IS NULL AND s.lesiva IS FALSE
 AND l.id='0b85f354-9cdb-47e1-baf9-3d266bb7e06b'::uuid AND l.is_active AND l.is_test
 AND mp.policy_id='staff_test_no_persistent_resources_v1' AND m.owner_kind='human' AND m.tipo='duello'
 AND m.mission_id IS NULL AND m.quest_kind IS NULL AND m.stato='in_corso' AND m.closed_at IS NULL AND m.suspended_at IS NULL
 AND m.master_user=auth.uid() AND public.is_staff() AND g.staff_enabled AND NOT g.public_enabled
 AND public.combat_v2_values_written(s.id) IS FALSE
 AND origin.state='offered' AND origin.principal_user=m.master_user AND origin.source_sha256=public.combat_v2_sha256(origin.source)
 AND ad.principal_user=m.master_user AND ad.transaction_id=txid_current() AND ad.backend_pid=pg_backend_pid()
 AND ad.encounter_id IS NULL AND ad.receipt IS NULL
 AND NOT EXISTS(SELECT 1 FROM public.mission_run_state x WHERE x.master_session_id=m.id)
 AND NOT EXISTS(SELECT 1 FROM combat_consumer_private.narrative_authorities x WHERE x.master_session_id=m.id)
 AND NOT EXISTS(SELECT 1 FROM exam_human_private.native_bindings x WHERE x.master_session_id=m.id)
 AND NOT EXISTS(SELECT 1 FROM exam_regia_private.bindings x WHERE x.combat_session_id=s.id)
 AND NOT EXISTS(SELECT 1 FROM mission_factory_owner.quest_run_sources x WHERE x.session_id=m.id)
 AND(SELECT count(*) FROM public.combat_v2_actors a WHERE a.session_id=s.id)=3
 AND(SELECT count(*) FROM public.combat_v2_actors a JOIN public.characters ch ON ch.id=a.character_id AND ch.user_id=a.controller_user
 WHERE a.session_id=s.id AND a.actor_kind='pg' AND a.companion_id IS NULL AND a.state='attivo'
 AND a.character_id IN('2a877f02-4993-4e65-9172-7d29f08c5b86'::uuid,'6bceee99-974f-426b-8d92-38b43b4a4267'::uuid))=2
 AND EXISTS(SELECT 1 FROM public.combat_v2_actors a JOIN public.combat_v2_provider_instances_v1 pv ON pv.id=a.provider_instance_v1_id
 JOIN public.master_v2_nb_actor_offers_v1 o ON o.offer_ref=pv.offer_ref
 WHERE a.session_id=s.id AND a.actor_kind='png' AND a.companion_id IS NULL AND a.state='attivo' AND a.controller_user=m.master_user AND a.team_key='B'
 AND pv.session_id=s.id AND pv.provider='ninja_book' AND pv.offer_ref=ad.offer_ref
 AND o.staff_combat_source_id=origin.id AND o.master_session_id=m.id AND o.source_kind='staff_combat'
 AND o.lifecycle_state='consumata' AND o.consumed_event_id=ad.event_id)) INTO eligible;
 IF eligible IS DISTINCT FROM true THEN RETURN false;END IF;
 -- A preplacement scene is admitted only as setup. An already present arena must prove full native readiness.
 IF EXISTS(SELECT 1 FROM combat_spatial.arena_instances WHERE encounter_id=p_session) THEN
  RETURN combat_v2_staff_nb_internal.mechanics_ready(p_session);END IF;
 RETURN true;
END $nb$;
CREATE FUNCTION combat_v2_staff_nb_internal.commit_roster(p_command jsonb) RETURNS jsonb LANGUAGE plpgsql SECURITY DEFINER SET search_path='' AS $nb$
DECLARE p jsonb;uid uuid:=auth.uid();key uuid;fp text;o combat_panel_private.offers%ROWTYPE;
 c combat_panel_private.contexts%ROWTYPE;m public.master_v2_sessions%ROWTYPE;origin combat_v2_staff_nb_internal.roster_sources%ROWTYPE;
 prior combat_panel_private.request_receipts%ROWTYPE;selected uuid[];resolved jsonb;payload jsonb;source_id uuid;tuple jsonb;
 native_offer uuid:=gen_random_uuid();client_id uuid:=gen_random_uuid();actors jsonb;pgs uuid[];teams jsonb;
 ev jsonb;eid uuid;result jsonb;enc uuid;round_id uuid;v_receipt jsonb;env jsonb;pg_caster uuid;pg_target uuid;npc uuid;pi public.combat_v2_provider_instances_v1%ROWTYPE;
BEGIN
 IF uid IS NULL OR NOT public.is_staff() THEN RAISE EXCEPTION 'staff_nb_auth_required' USING ERRCODE='42501';END IF;
 p:=combat_panel_private.validate_command(p_command);key:=(p->>'request_key')::uuid;fp:=public.combat_v2_sha256(p);
 PERFORM pg_advisory_xact_lock(hashtextextended('panel-request:'||uid::text||':'||key::text,731));
 SELECT * INTO prior FROM combat_panel_private.request_receipts WHERE principal_user=uid AND request_key=key;
 IF FOUND THEN IF prior.command_fingerprint IS DISTINCT FROM fp THEN RAISE EXCEPTION 'panel_request_key_conflict' USING ERRCODE='22023';END IF;
  RETURN jsonb_set(prior.viewer_envelope,'{receipt,replayed}','true',false);END IF;
 SELECT * INTO o FROM combat_panel_private.offers WHERE id=(p->>'offer_id')::uuid AND principal_user=uid;
 IF o.id IS NULL OR o.kind<>'administration' OR o.operation<>'administration' OR p->>'operation' IS DISTINCT FROM 'administration'
 OR o.source_payload->>'adapter' IS DISTINCT FROM 'master_v2' OR o.source_payload->>'dispatch' IS DISTINCT FROM 'staff_native_roster'
 OR o.requires_role OR length(btrim(coalesce(p->>'narrative_text','')))<>0 THEN RAISE EXCEPTION 'panel_offer_not_available' USING ERRCODE='42501';END IF;
 SELECT * INTO STRICT c FROM combat_panel_private.contexts WHERE id=o.context_id AND principal_user=uid;
 IF c.activity_kind<>'master_v2' OR c.round_id IS NOT NULL OR c.location_id IS DISTINCT FROM(p->>'location_id')::uuid
 OR c.activity_id IS DISTINCT FROM(p->>'activity_id')::uuid THEN RAISE EXCEPTION 'panel_activity_scope_invalid' USING ERRCODE='22023';END IF;
 SELECT * INTO STRICT m FROM public.master_v2_sessions WHERE id=(o.source_payload->>'master_session_id')::uuid AND location_id=c.location_id;
 pgs:=ARRAY['2a877f02-4993-4e65-9172-7d29f08c5b86'::uuid,'6bceee99-974f-426b-8d92-38b43b4a4267'::uuid];
 PERFORM 1 FROM public.locations WHERE id=m.location_id FOR UPDATE;
 PERFORM 1 FROM public.characters ch WHERE ch.id=ANY(pgs) ORDER BY ch.id FOR KEY SHARE;
 PERFORM combat_gate_private.master_claim_assert(m.id,m.location_id);
 PERFORM public.master_v2_lock_scope(m.id);
 SELECT * INTO STRICT m FROM public.master_v2_sessions WHERE id=m.id FOR UPDATE;
 env:=combat_panel_private.master_projection(c.location_id,c.command_actor_id);
 PERFORM 1 FROM combat_panel_private.contexts WHERE id=c.id FOR UPDATE;
 c:=combat_panel_private.owned_context(c.id,(p->>'context_version')::bigint);
 SELECT * INTO STRICT o FROM combat_panel_private.offers WHERE id=o.id FOR UPDATE;
 IF o.state<>'offered' OR o.context_version IS DISTINCT FROM c.context_version OR o.source_fingerprint IS DISTINCT FROM c.source_fingerprint
 OR o.scene_version IS DISTINCT FROM c.scene_version OR o.actor_id IS DISTINCT FROM c.command_actor_id
 OR m.control_version::text IS DISTINCT FROM o.source_payload->>'control_version'
 OR NOT combat_v2_staff_nb_internal.preparation_allowed(m.id) THEN RAISE EXCEPTION 'staff_nb_context_stale' USING ERRCODE='40001';END IF;
 SELECT coalesce(array_agg(value::uuid),'{}') INTO selected FROM jsonb_array_elements_text(p->'selected_option_ids');
 resolved:=combat_panel_private.resolve_selections(o.id,selected,p->'inputs');
 IF cardinality(selected)<>1 OR resolved->'inputs' IS DISTINCT FROM '{}'::jsonb
 OR jsonb_array_length(resolved->'groups')<>1 OR jsonb_array_length(resolved#>'{groups,0,options}')<>1 THEN RAISE EXCEPTION 'panel_selection_invalid' USING ERRCODE='22023';END IF;
 payload:=resolved#>'{groups,0,options,0,payload}';
 IF jsonb_typeof(payload) IS DISTINCT FROM 'object' OR(SELECT count(*) FROM jsonb_object_keys(payload))<>1
 OR NOT payload?'staff_roster_source_id' THEN RAISE EXCEPTION 'panel_selection_not_offered' USING ERRCODE='22023';END IF;
 source_id:=(payload->>'staff_roster_source_id')::uuid;
 SELECT * INTO STRICT origin FROM combat_v2_staff_nb_internal.roster_sources WHERE id=source_id FOR UPDATE;
 IF origin.state<>'offered' OR origin.context_id IS DISTINCT FROM c.id OR origin.context_version IS DISTINCT FROM c.context_version
 OR origin.master_session_id IS DISTINCT FROM m.id OR origin.master_control_version IS DISTINCT FROM m.control_version
 OR origin.principal_user IS DISTINCT FROM uid OR origin.source_sha256 IS DISTINCT FROM public.combat_v2_sha256(origin.source)
 OR origin.source->>'scene_version' IS DISTINCT FROM c.scene_version::text
 OR origin.source->>'source_fingerprint' IS DISTINCT FROM c.source_fingerprint
 OR origin.source->'tuple' IS DISTINCT FROM combat_v2_staff_nb_internal.choice(origin.mechanical_version_id)
 THEN RAISE EXCEPTION 'staff_nb_origin_stale' USING ERRCODE='40001';END IF;
 -- Same lock order as the native NB caller; every value below comes from the sealed server origin.
 tuple:=origin.source->'tuple';

 IF(SELECT count(*) FROM public.characters ch WHERE ch.id=ANY(pgs) AND ch.vita>0 AND public._combat_presente(ch.user_id,m.location_id))<>2
 OR NOT EXISTS(SELECT 1 FROM public.characters WHERE id=ANY(pgs) AND user_id=uid)
 OR NOT combat_consumer_private.staff_test_allowed(m.location_id,ARRAY(SELECT DISTINCT x FROM(
  SELECT ch.user_id x FROM public.characters ch WHERE ch.id=ANY(pgs) UNION SELECT uid) users ORDER BY x),false)
 OR EXISTS(SELECT 1 FROM public.combat_sessions WHERE location_id=m.location_id AND state='aperto')
 OR EXISTS(SELECT 1 FROM public.combat_v2_sessions WHERE location_id=m.location_id AND user_test_context_id IS NULL AND state NOT IN('chiuso','annullato'))
 THEN RAISE EXCEPTION 'staff_nb_scene_unavailable' USING ERRCODE='42501';END IF;
 actors:=jsonb_build_array(jsonb_build_object('client_ref',client_id,'provider','ninja_book','offer_ref',native_offer));
 teams:=(origin.source->'pg_teams')||jsonb_build_object(client_id::text,'B');
 ev:=public.combat_v2_event_begin(m.id,key,'master_v2_encounter_open_ninja_book_v1',
  jsonb_build_object('pg',pgs,'actors',actors,'teams',teams,'staff_combat_source',origin.id),m.control_version);
 IF(ev->>'replay')::boolean THEN RAISE EXCEPTION 'staff_nb_native_replay_without_panel_receipt' USING ERRCODE='40001';END IF;
 eid:=(ev->>'event_id')::uuid;
 INSERT INTO combat_v2_staff_nb_internal.admissions(source_id,master_session_id,request_id,principal_user,transaction_id,backend_pid,event_id,offer_ref)
 VALUES(origin.id,m.id,key,uid,txid_current(),pg_backend_pid(),eid,native_offer);
 INSERT INTO public.master_v2_nb_actor_offers_v1(offer_ref,master_session_id,mission_id,source_kind,quest_episode_id,quest_source_sha256,staff_combat_source_id,
 recipient_kind,recipient_user,created_by,recipient_service_capability,created_by_service_capability,
 narrative_template_id,narrative_version_id,mechanical_template_id,mechanical_version_id,
 expected_master_control_version,expected_narrative_template_control_version,expected_narrative_version_control_version,
 expected_binding_control_version,expected_mechanical_template_control_version,expected_mechanical_version_control_version,
 expected_narrative_sha256,expected_mechanical_sha256,lifecycle_state,expires_at)
 VALUES(native_offer,m.id,NULL,'staff_combat',NULL,NULL,origin.id,'human',uid,uid,NULL,NULL,
 (tuple->>'narrative_template_id')::uuid,(tuple->>'narrative_version_id')::uuid,(tuple->>'mechanical_template_id')::uuid,(tuple->>'mechanical_version_id')::uuid,
 m.control_version,(tuple->>'narrative_template_control_version')::bigint,(tuple->>'narrative_version_control_version')::bigint,
 (tuple->>'binding_control_version')::bigint,(tuple->>'mechanical_template_control_version')::bigint,(tuple->>'mechanical_version_control_version')::bigint,
 tuple->>'narrative_sha256',tuple->>'mechanical_sha256','offerta',clock_timestamp()+interval '15 minutes');
 -- Separate Staff admission, never a bypass through assert_human_open or c395/c407.
 result:=combat_v2_staff_nb_internal.native_construct(m.id,pgs,actors,teams,key,eid);
 enc:=(result#>>'{data,encounter_id}')::uuid;round_id:=(result#>>'{data,round_id}')::uuid;
 SELECT * INTO STRICT m FROM public.master_v2_sessions WHERE id=m.id;
 IF enc IS NULL OR round_id IS NULL OR NOT combat_v2_staff_nb_internal.setup_protected(enc,origin.id) THEN
  RAISE EXCEPTION 'staff_nb_setup_protection_not_proven' USING ERRCODE='42501';END IF;
 SELECT id INTO STRICT pg_caster FROM public.combat_v2_actors WHERE session_id=enc AND actor_kind='pg' AND character_id=pgs[1] AND team_key='A';
 SELECT id INTO STRICT pg_target FROM public.combat_v2_actors WHERE session_id=enc AND actor_kind='pg' AND character_id=pgs[2] AND team_key='B';
 SELECT a.id INTO STRICT npc FROM public.combat_v2_actors a JOIN public.combat_v2_provider_instances_v1 pv ON pv.id=a.provider_instance_v1_id
 WHERE a.session_id=enc AND a.actor_kind='png' AND a.team_key='B' AND a.controller_user=uid AND a.companion_id IS NULL
 AND pv.offer_ref=native_offer AND pv.provider='ninja_book' AND pv.session_id=enc;
 IF(SELECT count(*) FROM public.combat_v2_actors WHERE session_id=enc)<>3 THEN RAISE EXCEPTION 'staff_nb_roster_invalid';END IF;
 SELECT * INTO STRICT pi FROM public.combat_v2_provider_instances_v1 WHERE offer_ref=native_offer AND session_id=enc;
 IF pi.source_sha256 IS DISTINCT FROM tuple->>'mechanical_sha256' OR pi.snapshot_sha256 IS DISTINCT FROM public.combat_v2_sha256(pi.snapshot)
 OR pi.snapshot->'abilities' IS DISTINCT FROM tuple->'abilities' THEN RAISE EXCEPTION 'staff_nb_provider_freeze_invalid';END IF;
 v_receipt:=jsonb_build_object('contract','staff-nb-roster/1','source_id',origin.id,'source_sha256',origin.source_sha256,'master_session_id',m.id,
 'master_control_version',m.control_version,'session_id',enc,'round_id',round_id,'principal_user',uid,'provider_instance_id',pi.id,
 'provider_snapshot_sha256',pi.snapshot_sha256,'source_actor_id',pg_caster,'target_actor_id',pg_target,'kai_actor_id',npc,
 'actors',(SELECT jsonb_agg(jsonb_build_object('actor_id',a.id,'character_id',a.character_id,'actor_kind',a.actor_kind,'controller_user',a.controller_user,
 'controller_version',a.controller_version,'team_key',a.team_key) ORDER BY a.id) FROM public.combat_v2_actors a WHERE a.session_id=enc),
 'tuple',tuple,'values_written',false,'admission_stage','setup','setup_protected',true,
 'simulation_policy','staff_test_no_persistent_resources_v1',
 'pools_verified_at_admission',combat_v2_staff_nb_internal.mechanics_ready(enc));
 UPDATE combat_v2_staff_nb_internal.admissions AS admission SET encounter_id=enc,receipt=v_receipt,receipt_sha256=public.combat_v2_sha256(v_receipt) WHERE admission.source_id=origin.id;
 UPDATE combat_v2_staff_nb_internal.roster_sources SET state='consumed' WHERE id=origin.id;
 UPDATE combat_panel_private.offers SET state='consumed',consumed_request_key=key WHERE id=o.id AND state='offered';
 env:=combat_panel_private.master_projection(c.location_id,npc);
 v_receipt:=jsonb_build_object('receipt_id',eid,'request_key',key,'operation',o.operation,'replayed',false,
 'activity_id',c.activity_id,'round_id',round_id,'context_version_before',c.context_version,'context_version_after',env#>'{context,version}',
 'declaration_id',NULL,'report_id',NULL,'values_written',false,'display_events','[]'::jsonb);
 env:=env||jsonb_build_object('receipt',v_receipt);
 INSERT INTO combat_panel_private.request_receipts(principal_user,request_key,command_fingerprint,offer_id,event_id,viewer_envelope)
 VALUES(uid,key,fp,o.id,eid,env);RETURN env;
END $nb$;
CREATE FUNCTION combat_v2_staff_nb_internal.roster_receipt(p_session uuid) RETURNS jsonb LANGUAGE plpgsql STABLE SECURITY DEFINER SET search_path='' AS $nb$
DECLARE ad combat_v2_staff_nb_internal.admissions%ROWTYPE;origin combat_v2_staff_nb_internal.roster_sources%ROWTYPE;
 s public.combat_v2_sessions%ROWTYPE;m public.master_v2_sessions%ROWTYPE;r jsonb;actual jsonb;
BEGIN
 SELECT * INTO ad FROM combat_v2_staff_nb_internal.admissions WHERE encounter_id=p_session;
 IF ad.source_id IS NULL OR ad.receipt IS NULL OR ad.receipt_sha256 IS DISTINCT FROM public.combat_v2_sha256(ad.receipt) THEN RETURN NULL;END IF;
 SELECT * INTO STRICT origin FROM combat_v2_staff_nb_internal.roster_sources WHERE id=ad.source_id;
 SELECT * INTO STRICT s FROM public.combat_v2_sessions WHERE id=p_session;
 SELECT * INTO STRICT m FROM public.master_v2_sessions WHERE id=s.master_session_id;
 r:=ad.receipt;
 IF r->>'admission_stage' IS DISTINCT FROM 'setup' OR r->'setup_protected' IS DISTINCT FROM 'true'::jsonb
 OR r->>'simulation_policy' IS DISTINCT FROM 'staff_test_no_persistent_resources_v1'
 OR origin.state<>'consumed' OR origin.source_sha256 IS DISTINCT FROM public.combat_v2_sha256(origin.source)
 OR r->>'source_sha256' IS DISTINCT FROM origin.source_sha256 OR r->'tuple' IS DISTINCT FROM origin.source->'tuple'
 OR s.master_session_id IS DISTINCT FROM ad.master_session_id OR s.source_kind<>'master' OR s.state<>'in_corso' OR s.closed_at IS NOT NULL
 OR s.user_test_context_id IS NOT NULL OR s.location_id<>'0b85f354-9cdb-47e1-baf9-3d266bb7e06b'::uuid
 OR public.combat_v2_values_written(s.id) IS DISTINCT FROM false OR NOT combat_v2_staff_nb_internal.mechanics_ready(s.id)
 OR NOT EXISTS(SELECT 1 FROM public.locations WHERE id=s.location_id AND is_test AND is_active)
 OR m.master_user IS DISTINCT FROM ad.principal_user OR m.master_user::text IS DISTINCT FROM r->>'principal_user'
 OR m.control_version::text IS DISTINCT FROM r->>'master_control_version' OR m.owner_kind<>'human' OR m.tipo<>'duello'
 OR m.mission_id IS NOT NULL OR m.quest_kind IS NOT NULL OR m.stato<>'in_corso' OR m.closed_at IS NOT NULL OR m.suspended_at IS NOT NULL
 OR NOT EXISTS(SELECT 1 FROM combat_panel_private.master_panel_sessions WHERE master_session_id=m.id AND policy_id='staff_test_no_persistent_resources_v1')
 OR EXISTS(SELECT 1 FROM public.mission_run_state WHERE master_session_id=m.id)
 OR EXISTS(SELECT 1 FROM combat_consumer_private.narrative_authorities WHERE master_session_id=m.id)
 OR EXISTS(SELECT 1 FROM exam_human_private.native_bindings WHERE master_session_id=m.id)
 OR EXISTS(SELECT 1 FROM exam_regia_private.bindings WHERE combat_session_id=s.id)
 OR EXISTS(SELECT 1 FROM mission_factory_owner.quest_run_sources WHERE session_id=m.id) THEN RETURN NULL;END IF;
 SELECT jsonb_agg(jsonb_build_object('actor_id',a.id,'character_id',a.character_id,'actor_kind',a.actor_kind,'controller_user',a.controller_user,
 'controller_version',a.controller_version,'team_key',a.team_key) ORDER BY a.id) INTO actual FROM public.combat_v2_actors a WHERE a.session_id=s.id;
 IF actual IS DISTINCT FROM r->'actors' OR jsonb_array_length(actual)<>3
 OR(SELECT count(*) FROM public.combat_v2_actors WHERE session_id=s.id AND actor_kind='pg' AND companion_id IS NULL
 AND character_id IN('2a877f02-4993-4e65-9172-7d29f08c5b86'::uuid,'6bceee99-974f-426b-8d92-38b43b4a4267'::uuid))<>2
 OR NOT EXISTS(SELECT 1 FROM public.combat_v2_actors WHERE id=(r->>'source_actor_id')::uuid AND session_id=s.id
 AND character_id='2a877f02-4993-4e65-9172-7d29f08c5b86'::uuid AND actor_kind='pg' AND team_key='A')
 OR NOT EXISTS(SELECT 1 FROM public.combat_v2_actors WHERE id=(r->>'target_actor_id')::uuid AND session_id=s.id
 AND character_id='6bceee99-974f-426b-8d92-38b43b4a4267'::uuid AND actor_kind='pg' AND team_key='B')
 OR NOT EXISTS(SELECT 1 FROM public.combat_v2_actors a JOIN public.combat_v2_provider_instances_v1 pv ON pv.id=a.provider_instance_v1_id
 JOIN public.master_v2_nb_actor_offers_v1 o ON o.offer_ref=pv.offer_ref
 WHERE a.id=(r->>'kai_actor_id')::uuid AND a.session_id=s.id AND a.actor_kind='png' AND a.team_key='B' AND a.companion_id IS NULL
 AND a.controller_user=ad.principal_user AND pv.id=(r->>'provider_instance_id')::uuid AND pv.session_id=s.id AND pv.provider='ninja_book'
 AND pv.snapshot_sha256=r->>'provider_snapshot_sha256' AND pv.snapshot_sha256=public.combat_v2_sha256(pv.snapshot)
 AND pv.source_sha256=r#>>'{tuple,mechanical_sha256}' AND pv.mechanical_version_ref=(r#>>'{tuple,mechanical_version_id}')::uuid
 AND pv.narrative_version_ref=(r#>>'{tuple,narrative_version_id}')::uuid AND o.staff_combat_source_id=ad.source_id
 AND o.master_session_id=m.id AND o.source_kind='staff_combat' AND o.offer_ref=ad.offer_ref AND o.lifecycle_state='consumata'
 AND o.consumed_event_id=ad.event_id AND o.recipient_kind='human' AND o.recipient_user=ad.principal_user) THEN RETURN NULL;END IF;
 RETURN r;
END $nb$;
CREATE FUNCTION combat_v2_staff_nb_internal.kai_frozen_authority(p_actor uuid) RETURNS jsonb LANGUAGE plpgsql STABLE SECURITY DEFINER SET search_path='' AS $nb$
DECLARE a public.combat_v2_actors%ROWTYPE;r jsonb;tuple jsonb;proof jsonb;kai jsonb;
BEGIN
 SELECT * INTO a FROM public.combat_v2_actors WHERE id=p_actor AND actor_kind='png' AND companion_id IS NULL;
 IF a.id IS NULL THEN RETURN NULL;END IF;
 r:=combat_v2_staff_nb_internal.roster_receipt(a.session_id);tuple:=r->'tuple';
 IF r IS NULL OR r->>'kai_actor_id' IS DISTINCT FROM a.id::text OR r->>'principal_user' IS DISTINCT FROM a.controller_user::text

 OR jsonb_typeof(a.mechanics_snapshot->'mente') IS DISTINCT FROM 'number' OR jsonb_typeof(a.mechanics_snapshot->'genjutsu') IS DISTINCT FROM 'number'
 OR a.mechanics_snapshot->'mente' IS DISTINCT FROM tuple#>'{stats,mente}' OR a.mechanics_snapshot->'genjutsu' IS DISTINCT FROM tuple#>'{stats,genjutsu}'
 OR(a.mechanics_snapshot->>'mente')::numeric<20 OR a.mechanics_snapshot->'abilities' IS DISTINCT FROM tuple->'abilities'
 THEN RETURN NULL;END IF;
 IF(SELECT count(*) FROM jsonb_array_elements(a.mechanics_snapshot->'abilities') x WHERE x->>'source'='jutsu' AND x->>'id'='9f12fc98-bc97-4b95-9bcc-7ce359ebbe4f')<>1 THEN RETURN NULL;END IF;
 SELECT value INTO STRICT kai FROM jsonb_array_elements(a.mechanics_snapshot->'abilities') WHERE value->>'source'='jutsu' AND value->>'id'='9f12fc98-bc97-4b95-9bcc-7ce359ebbe4f';
 IF kai IS DISTINCT FROM tuple->'kai' OR kai->'chakra_cost' IS DISTINCT FROM '0'::jsonb THEN RETURN NULL;END IF;
 proof:=jsonb_build_object('contract','staff-nb-kai/1','source_id',r->'source_id','source_sha256',r->'source_sha256',
 'provider_instance_id',r->'provider_instance_id','provider_snapshot_sha256',r->'provider_snapshot_sha256',
 'tuple',tuple,'actor_id',a.id,'session_id',a.session_id,'controller_user',a.controller_user,'controller_version',a.controller_version,
 'target_actor_id',r->'target_actor_id','mente',a.mechanics_snapshot->'mente','genjutsu',a.mechanics_snapshot->'genjutsu','kai',kai);
 RETURN proof;
END $nb$;
CREATE FUNCTION combat_v2_staff_nb_internal.kai_contact(p_actor uuid,p_target uuid) RETURNS jsonb LANGUAGE plpgsql STABLE SECURITY DEFINER SET search_path='' AS $nb$
DECLARE proof jsonb;a public.combat_v2_actors%ROWTYPE;t public.combat_v2_actors%ROWTYPE;
 i combat_spatial.arena_instances%ROWTYPE;ab combat_spatial.actor_states%ROWTYPE;tb combat_spatial.actor_states%ROWTYPE;
BEGIN
 proof:=combat_v2_staff_nb_internal.kai_frozen_authority(p_actor);
 IF proof IS NULL OR proof->>'target_actor_id' IS DISTINCT FROM p_target::text THEN RETURN NULL;END IF;
 SELECT * INTO STRICT a FROM public.combat_v2_actors WHERE id=p_actor;
 SELECT * INTO t FROM public.combat_v2_actors WHERE id=p_target AND actor_kind='pg' AND companion_id IS NULL AND state='attivo';
 IF t.id IS NULL OR a.state<>'attivo' OR coalesce((a.mechanics_snapshot->>'vita')::numeric,0)<=0 OR a.session_id IS DISTINCT FROM t.session_id OR a.team_key IS DISTINCT FROM t.team_key
 OR coalesce((t.mechanics_snapshot->>'vita')::numeric,0)<=0 THEN RETURN NULL;END IF;
 SELECT * INTO i FROM combat_spatial.arena_instances WHERE encounter_id=a.session_id AND context_source='panel_master' AND state='open';
 IF i.instance_id IS NULL THEN RETURN NULL;END IF;
 SELECT * INTO ab FROM combat_spatial.actor_states WHERE instance_id=i.instance_id AND actor_id=a.id AND state='active';
 SELECT * INTO tb FROM combat_spatial.actor_states WHERE instance_id=i.instance_id AND actor_id=t.id AND state='active';
 IF ab.actor_id IS NULL OR tb.actor_id IS NULL OR NOT EXISTS(SELECT 1 FROM combat_spatial.viewer_grants WHERE instance_id=i.instance_id
 AND viewer_principal_id=exam_regia_private.actor_principal(a.id,a.controller_user) AND subject_actor_id=t.id AND can_view_map)
 OR combat_spatial.distance_m(ab.x_m,ab.y_m,tb.x_m,tb.y_m)>2
 OR combat_spatial.path_first_block_t(i.instance_id,a.id,ab.x_m,ab.y_m,tb.x_m,tb.y_m,t.id)<1 THEN RETURN NULL;END IF;
 RETURN jsonb_build_object('self',false,'instance_id',i.instance_id,'actor_body_version',ab.body_version,'target_body_version',tb.body_version,
 'actor_x',ab.x_m,'actor_y',ab.y_m,'target_x',tb.x_m,'target_y',tb.y_m,'staff_nb_proof_sha256',public.combat_v2_sha256(proof));
END $nb$;
CREATE FUNCTION clan_aburame_private.verme_manifest_v1()
RETURNS jsonb LANGUAGE plpgsql STABLE SECURITY DEFINER SET search_path='' AS $f$
DECLARE priv jsonb;shared jsonb;rels jsonb;trigs jsonb;
BEGIN
 SELECT coalesce(jsonb_agg(jsonb_build_object('signature',p.oid::regprocedure::text,
  'ddl_sha256',encode(extensions.digest(convert_to(pg_get_functiondef(p.oid),'UTF8'),'sha256'),'hex'),
  'owner',pg_get_userbyid(p.proowner),'acl',p.proacl::text) ORDER BY p.oid::regprocedure::text),'[]') INTO priv
 FROM pg_proc p JOIN pg_namespace n ON n.oid=p.pronamespace WHERE n.nspname='clan_aburame_private' AND p.proname LIKE 'verme\_%' ESCAPE '\';
 SELECT coalesce(jsonb_agg(jsonb_build_object('signature',p.oid::regprocedure::text,
  'ddl_sha256',encode(extensions.digest(convert_to(pg_get_functiondef(p.oid),'UTF8'),'sha256'),'hex'),
  'owner',pg_get_userbyid(p.proowner),'acl',p.proacl::text) ORDER BY p.oid::regprocedure::text),'[]') INTO shared
 FROM pg_proc p WHERE p.oid IN(SELECT to_regprocedure(value#>>'{}') FROM jsonb_array_elements($sigs$["clan_aburame_private.actor_ability(uuid,text,uuid,boolean,jsonb)","clan_aburame_private.consumer_options(jsonb)","clan_aburame_private.master_offers(uuid,bigint,jsonb)","clan_aburame_private.commit_control(jsonb,jsonb,combat_consumer_private.activities,combat_consumer_private.offers,uuid)","clan_aburame_private.commit_master_stop(jsonb)","public.combat_v2_action_declare(uuid,uuid,jsonb,text,uuid)","public._combat_calcola(text,jsonb,jsonb,text,text,integer,text,integer,integer,integer,integer,boolean)","clan_aburame_private.attack_power_source(uuid,uuid)","combat_effects_private.lifecycle_open(uuid,uuid)","public.combat_v2_round_resolve(uuid,uuid)","combat_panel_private.narrative_declaration_facts(uuid)","combat_consumer_private.narrative_declaration_supported(uuid)","combat_consumer_private.narrative_context(uuid)","combat_panel_private.narrative_ordinary_context(uuid)","combat_consumer_private.commit_exchange(jsonb,jsonb)","combat_panel_private.consumer_commit_authoritative(jsonb)","combat_consumer_private.validate_narrative_result(jsonb)","public.combat_consumer_narrative_claim_v1(uuid,text,uuid)","public.combat_consumer_narrative_complete_v1(uuid,jsonb,uuid)","combat_consumer_private.after_publish(uuid,uuid)","combat_v2_multitarget_internal.resolve_parent(uuid,uuid,uuid,boolean)","combat_panel_private.master_options(uuid,uuid,bigint)"]$sigs$::jsonb));
 SELECT coalesce(jsonb_agg(jsonb_build_object('name',n.nspname||'.'||c.relname,'owner',pg_get_userbyid(c.relowner),
  'acl',c.relacl::text,'rls',c.relrowsecurity,'force_rls',c.relforcerowsecurity,
  'columns',(SELECT jsonb_agg(jsonb_build_object('number',a.attnum,'name',a.attname,'type',format_type(a.atttypid,a.atttypmod),'not_null',a.attnotnull,
   'default',pg_get_expr(d.adbin,d.adrelid)) ORDER BY a.attnum) FROM pg_attribute a LEFT JOIN pg_attrdef d ON d.adrelid=a.attrelid AND d.adnum=a.attnum
   WHERE a.attrelid=c.oid AND a.attnum>0 AND NOT a.attisdropped),
  'constraints',(SELECT coalesce(jsonb_agg(jsonb_build_object('name',k.conname,'definition',pg_get_constraintdef(k.oid)) ORDER BY k.conname),'[]')
   FROM pg_constraint k WHERE k.conrelid=c.oid)) ORDER BY c.relname),'[]') INTO rels
 FROM pg_class c JOIN pg_namespace n ON n.oid=c.relnamespace WHERE n.nspname='clan_aburame_private' AND c.relkind='r' AND c.relname LIKE 'verme\_%' ESCAPE '\';
 SELECT coalesce(jsonb_agg(jsonb_build_object('table',t.tgrelid::regclass::text,'name',t.tgname,'enabled',t.tgenabled::text,
  'definition',pg_get_triggerdef(t.oid,true)) ORDER BY t.tgrelid::regclass::text,t.tgname),'[]') INTO trigs FROM pg_trigger t
 WHERE NOT t.tgisinternal AND t.tgname IN('aburame_verme_end_session_v1','aburame_verme_end_actor_v1');
 IF jsonb_array_length(priv)<>16 OR jsonb_array_length(shared)<>22 OR jsonb_array_length(rels)<>5 OR jsonb_array_length(trigs)<>2
 THEN RAISE EXCEPTION 'aburame_manifest_coverage_drift';END IF;
 -- Ordine canonico documentato: privati, condivisi, relazioni+trigger; conteggi verificati sopra, senza duplicarli nella Root.
 RETURN jsonb_build_array(public.combat_v2_sha256(priv),public.combat_v2_sha256(shared),
  public.combat_v2_sha256(jsonb_build_object('relations',rels,'triggers',trigs)));
END $f$;
CREATE FUNCTION clan_aburame_private.verme_release_v1()
RETURNS boolean LANGUAGE plpgsql STABLE SECURITY DEFINER SET search_path='' AS $f$
DECLARE rr mission_factory_owner.editor_release_readiness%ROWTYPE;r jsonb;d jsonb;edge boolean;
BEGIN
 IF NOT EXISTS(SELECT 1 FROM clan_aburame_private.verme_gate_v1 WHERE singleton AND(staff_enabled OR public_enabled)) THEN RETURN false;END IF;
 SELECT * INTO STRICT rr FROM mission_factory_owner.editor_release_readiness WHERE singleton;
 r:=rr.canonical_preimage::jsonb;d:=r#>'{db_core,catalogo_families}';
 IF d IS NULL OR to_jsonb(public.combat_v2_sha256(d))IS DISTINCT FROM r#>'{config,catalogo_families}'
 OR jsonb_typeof(d) IS DISTINCT FROM 'array' OR jsonb_array_length(d)<>5 OR d->0 IS DISTINCT FROM '1'::jsonb OR d#>'{4,1}'IS DISTINCT FROM '1'::jsonb
 OR coalesce(d->>1,'')!~'^[0-9a-f]{64}$'
 OR rr.state NOT IN('enabled','prepared') OR rr.scope<>'staff' OR NOT rr.staff_guards_verified OR NOT rr.published_assets_verified
 OR rr.observed_revision_sha256 IS DISTINCT FROM rr.revision_sha256
 OR encode(extensions.digest(convert_to(rr.canonical_preimage,'UTF8'),'sha256'),'hex') IS DISTINCT FROM rr.revision_sha256
 OR octet_length(rr.canonical_preimage)>524288
 OR r#>>'{db_core,sha256}' IS DISTINCT FROM public.combat_v2_sha256((r->'db_core')-'sha256')
 OR r#>>'{config,sha256}' IS DISTINCT FROM public.combat_v2_sha256((r->'config')-'sha256')
 OR NOT clan_innata_private.catalogo_eligibility_release_v1()
 OR EXISTS(SELECT 1 FROM clan_aburame_private.verme_gate_v1 WHERE singleton AND public_enabled)
 THEN RAISE EXCEPTION 'aburame_source_root_drift';END IF;
 SELECT EXISTS(SELECT 1 FROM jsonb_array_elements(r->'edge_bundles') b CROSS JOIN LATERAL jsonb_array_elements(b->'files') f
 WHERE b->>'name'='combat_narratore_ai' AND f->>'name'='facts.ts' AND f->>'sha256'=d->>3) INTO edge;
 IF NOT edge THEN RAISE EXCEPTION 'aburame_source_edge_identity_drift';END IF;
 RETURN true;
END $f$;
CREATE FUNCTION clan_aburame_private.verme_scope_v1(p_actor uuid)
RETURNS text LANGUAGE plpgsql STABLE SECURITY DEFINER SET search_path='' AS $f$
DECLARE a public.combat_v2_actors%ROWTYPE; p clan_aburame_private.verme_staff_profiles_v1%ROWTYPE;
BEGIN
 SELECT * INTO a FROM public.combat_v2_actors WHERE id=p_actor AND actor_kind='pg' AND companion_id IS NULL AND state='attivo';
 IF a.id IS NULL THEN RETURN NULL;END IF;
 SELECT * INTO p FROM clan_aburame_private.verme_staff_profiles_v1 WHERE actor_id=a.id AND session_id=a.session_id;
 IF clan_aburame_private.verme_staff_scope_v1(a.id) AND p.actor_id IS NOT NULL
 AND p.controller_user=a.controller_user AND p.controller_version=a.controller_version
 AND p.profile_sha256=public.combat_v2_sha256(p.profile)
 AND a.mechanics_snapshot->'verme_staff_profile'=p.profile
 AND (a.mechanics_snapshot->>'kekkei_genkai')::integer=55 THEN RETURN 'simulation';END IF;
 IF EXISTS(SELECT 1 FROM clan_aburame_private.verme_gate_v1 WHERE singleton AND public_enabled)
 AND clan_aburame_private.public_scope(a.id)
 AND EXISTS(SELECT 1 FROM public.characters c WHERE c.id=a.character_id AND c.user_id=a.controller_user
 AND public._grade_rank(c.rank)>=public._grade_rank('Chunin') AND c.kekkei_genkai>=55)
 AND EXISTS(SELECT 1 FROM public.character_abilities x WHERE x.character_id=a.character_id
 AND x.technique_id='2f06b6f8-341f-472b-be04-ad48fcf2c412'::uuid AND x.state='attiva')
 AND EXISTS(SELECT 1 FROM public.character_abilities x WHERE x.character_id=a.character_id
 AND x.technique_id='d2d98dad-fb9f-4ff1-b6b2-3d3f2d222fae'::uuid AND x.state='attiva')
 AND NOT EXISTS(SELECT 1 FROM public.combat_v2_sessions s WHERE s.id=a.session_id AND s.closed_at IS NOT NULL)
 THEN IF clan_aburame_private.verme_release_v1() THEN
  IF clan_aburame_private.simulation_scope(a.id) THEN RETURN 'simulation';END IF;
  IF public.combat_v2_values_written(a.session_id) AND NOT combat_panel_private.uses_simulated_pools(a.session_id) THEN RETURN 'persistent';END IF;
 END IF;END IF;
 RETURN NULL;
END $f$;
CREATE FUNCTION clan_aburame_private.verme_event_v1(p_key text,p_session uuid,p_round uuid,p_actor uuid,p_target uuid,p_declaration uuid,p_kind text,p_facts jsonb)
RETURNS void LANGUAGE plpgsql SECURITY DEFINER SET search_path='' AS $f$
DECLARE e clan_aburame_private.verme_events_v1%ROWTYPE;
BEGIN
 SELECT * INTO e FROM clan_aburame_private.verme_events_v1 WHERE event_key=p_key;
 IF FOUND THEN
 IF e.session_id IS DISTINCT FROM p_session OR e.round_id IS DISTINCT FROM p_round OR e.actor_id IS DISTINCT FROM p_actor
 OR e.target_actor_id IS DISTINCT FROM p_target OR e.declaration_id IS DISTINCT FROM p_declaration OR e.kind<>p_kind
 OR e.facts IS DISTINCT FROM p_facts OR e.facts_sha256<>public.combat_v2_sha256(p_facts)
 THEN RAISE EXCEPTION 'aburame_verme_event_conflict';END IF;RETURN;END IF;
 INSERT INTO clan_aburame_private.verme_events_v1 VALUES(p_key,p_session,p_round,p_actor,p_target,p_declaration,p_kind,p_facts,public.combat_v2_sha256(p_facts),clock_timestamp());
END $f$;
CREATE FUNCTION clan_aburame_private.verme_staff_prepare_v1(p_actor uuid,p_request uuid)
RETURNS jsonb LANGUAGE plpgsql SECURITY DEFINER SET search_path='' AS $f$
DECLARE a public.combat_v2_actors%ROWTYPE; old clan_aburame_private.verme_staff_profiles_v1%ROWTYPE;p jsonb;ability jsonb;abilities jsonb;scope jsonb;
BEGIN
 SELECT * INTO STRICT a FROM public.combat_v2_actors WHERE id=p_actor FOR UPDATE;
 IF p_request IS NULL OR exam_regia_private.current_principal() IS NULL
 OR exam_regia_private.actor_principal(a.id,a.controller_user) IS DISTINCT FROM exam_regia_private.current_principal()
 OR NOT clan_aburame_private.verme_staff_scope_v1(a.id) THEN RAISE EXCEPTION 'aburame_verme_staff_scope' USING ERRCODE='42501';END IF;
 SELECT * INTO old FROM clan_aburame_private.verme_staff_profiles_v1 WHERE actor_id=a.id;
 IF FOUND THEN
 IF old.session_id<>a.session_id OR old.controller_user<>a.controller_user OR old.controller_version<>a.controller_version
 OR a.mechanics_snapshot->'verme_staff_profile' IS DISTINCT FROM old.profile THEN RAISE EXCEPTION 'aburame_verme_staff_profile_conflict';END IF;
 RETURN old.profile;END IF;
 IF EXISTS(SELECT 1 FROM public.combat_v2_declarations d JOIN public.combat_v2_rounds r ON r.id=d.round_id
 WHERE r.session_id=a.session_id AND d.actor_id=a.id) THEN RAISE EXCEPTION 'aburame_verme_prepare_before_actions';END IF;
 p:=jsonb_build_object('contract','aburame-verme-staff/1','actor_id',a.id,'session_id',a.session_id,
 'controller_version',a.controller_version,'request_key',p_request,'kg',55,'simulation',true,'values_written',false);
 ability:=jsonb_build_object('source','clan','id','2f06b6f8-341f-472b-be04-ad48fcf2c412','name','Insetto Verme Velenoso','kind','ninjutsu',
 'range','contatto','usage','principale','chakra_cost',10,'damage_base',10,'defensive',false,'di_scena',false,'consumption_type','ad_utilizzo');
 SELECT coalesce(jsonb_agg(v),'[]') INTO abilities FROM jsonb_array_elements(coalesce(a.mechanics_snapshot->'abilities','[]'))v
 WHERE NOT(v->>'source'='clan' AND v->>'id'='2f06b6f8-341f-472b-be04-ad48fcf2c412');
 INSERT INTO clan_aburame_private.verme_staff_profiles_v1(actor_id,session_id,controller_user,controller_version,request_key,original_snapshot_sha256,profile,profile_sha256)
 VALUES(a.id,a.session_id,a.controller_user,a.controller_version,p_request,public.combat_v2_sha256(a.mechanics_snapshot),p,public.combat_v2_sha256(p));
 UPDATE public.combat_v2_actors SET mechanics_snapshot=jsonb_set(jsonb_set(jsonb_set(mechanics_snapshot,'{kekkei_genkai}','55',false),'{abilities}',abilities||jsonb_build_array(ability),true),'{verme_staff_profile}',p,true) WHERE id=a.id;
 -- initialize is idempotent and never fills an already initialized colony.
 PERFORM clan_aburame_private.colony_transition(a.character_id,a.session_id,'simulation','initialize',a.id,0,NULL,0,55);
 PERFORM clan_aburame_private.verme_event_v1('staff:'||a.id,a.session_id,NULL,a.id,NULL,NULL,'staff_prepared',p);
 RETURN p;
END $f$;
CREATE FUNCTION clan_aburame_private.verme_meta_v1(p_actor uuid,p_defense boolean)
RETURNS jsonb LANGUAGE plpgsql STABLE SECURITY DEFINER SET search_path='' AS $f$
DECLARE a public.combat_v2_actors%ROWTYPE;kind text;scope uuid;available bigint;kg integer;nin integer;
BEGIN
 IF p_defense THEN RETURN NULL;END IF;kind:=clan_aburame_private.verme_scope_v1(p_actor);IF kind IS NULL THEN RETURN NULL;END IF;
 SELECT * INTO STRICT a FROM public.combat_v2_actors WHERE id=p_actor;
 scope:=CASE WHEN kind='simulation' THEN a.session_id ELSE a.character_id END;
 kg:=(a.mechanics_snapshot->>'kekkei_genkai')::integer;nin:=(a.mechanics_snapshot->>'ninjutsu')::integer;
 IF kg IS NULL OR kg<55 OR nin IS NULL OR nin<0 THEN RETURN NULL;END IF;
 SELECT c.living-coalesce((SELECT sum(s.allocated-s.lost) FROM clan_aburame_private.colony_sources s
 WHERE s.owner_id=c.owner_id AND s.scope_id=c.scope_id AND s.state='active'),0) INTO available
 FROM clan_aburame_private.colonies c WHERE c.owner_id=a.character_id AND c.scope_id=scope;
 IF available IS NULL OR available<5 THEN RETURN NULL;END IF;
 RETURN jsonb_build_object('source','clan','id','2f06b6f8-341f-472b-be04-ad48fcf2c412','name','Insetto Verme Velenoso','kind','ninjutsu',
 'range','contatto','usage','principale','chakra_cost',10,'damage_base',10,'defensive',false,'di_scena',false,'diversivo',false,
 'consumption_type','ad_utilizzo','aburame_verme_version','aburame-verme/1','colony_cost',5,'kg',kg,'ninjutsu',nin,
 'pool',kg+nin,'power',25+(kg+nin)/10,'scope_kind',kind,'targeting',jsonb_build_object('mode','single','max_targets',1));
END $f$;
CREATE FUNCTION clan_aburame_private.verme_bind_v1(p_declaration uuid)
RETURNS void LANGUAGE plpgsql SECURITY DEFINER SET search_path='' AS $f$
DECLARE d public.combat_v2_declarations%ROWTYPE;a public.combat_v2_actors%ROWTYPE;m jsonb;s uuid;kind text;
BEGIN
 SELECT * INTO STRICT d FROM public.combat_v2_declarations WHERE id=p_declaration;
 IF d.sanitized_intent#>>'{server_ability,aburame_verme_version}' IS DISTINCT FROM 'aburame-verme/1' THEN RETURN;END IF;
 SELECT * INTO STRICT a FROM public.combat_v2_actors WHERE id=d.actor_id FOR UPDATE;
 IF d.kind<>'attacco' OR d.sanitized_intent->>'ability_source' IS DISTINCT FROM 'clan'
 OR d.sanitized_intent->>'ability_id' IS DISTINCT FROM '2f06b6f8-341f-472b-be04-ad48fcf2c412'
 OR d.target_actor_id IS NULL OR d.target_actor_id=a.id
 OR d.controller_user_snapshot IS DISTINCT FROM exam_regia_private.actor_principal(a.id,a.controller_user)
 OR d.controller_version_snapshot<>a.controller_version OR NOT combat_panel_private.target_geometry_valid(a.id,d.target_actor_id,2)
 OR (SELECT count(*) FROM public.combat_v2_attack_targets WHERE attack_declaration_id=d.id)<>1 THEN RAISE EXCEPTION 'aburame_verme_binding_invalid';END IF;
 IF EXISTS(SELECT 1 FROM clan_aburame_private.verme_sources_v1 WHERE declaration_id=d.id) THEN
  IF NOT EXISTS(SELECT 1 FROM clan_aburame_private.verme_sources_v1 x WHERE x.declaration_id=d.id AND x.request_key=d.request_key
   AND x.actor_id=d.actor_id AND x.target_actor_id=d.target_actor_id AND x.controller_user=a.controller_user AND x.declaration_principal=d.controller_user_snapshot
   AND x.controller_version=d.controller_version_snapshot AND x.profile=d.sanitized_intent->'server_ability'
   AND x.profile_sha256=public.combat_v2_sha256(x.profile)) THEN RAISE EXCEPTION 'aburame_verme_replay_conflict';END IF;
  RETURN;
 END IF;
 m:=clan_aburame_private.verme_meta_v1(a.id,false);
 IF m IS NULL OR NOT((d.sanitized_intent->'server_ability') @> m) OR d.cost_snapshot->'chakra'<>'10'::jsonb OR d.cost_snapshot->'damage_base'<>'10'::jsonb
 THEN RAISE EXCEPTION 'aburame_verme_profile_changed';END IF;
 m:=d.sanitized_intent->'server_ability';
 kind:=m->>'scope_kind';s:=CASE WHEN kind='simulation' THEN a.session_id ELSE a.character_id END;
 -- Disponibilità verificata da verme_meta; la quota viene allocata soltanto al resolve, prima del costo.
 INSERT INTO clan_aburame_private.verme_sources_v1(declaration_id,session_id,round_id,actor_id,target_actor_id,owner_character_id,
 scope_id,scope_kind,request_key,controller_user,declaration_principal,controller_version,profile,profile_sha256)
 VALUES(d.id,a.session_id,d.round_id,a.id,d.target_actor_id,a.character_id,s,kind,d.request_key,a.controller_user,d.controller_user_snapshot,d.controller_version_snapshot,m,public.combat_v2_sha256(m));
 PERFORM clan_aburame_private.verme_event_v1('prepared:'||d.id,a.session_id,d.round_id,a.id,d.target_actor_id,d.id,'prepared',
 jsonb_build_object('contract','aburame-verme/1','colony_required',5,'chakra_frozen',10));
END $f$;
CREATE FUNCTION clan_aburame_private.verme_frozen_v1(p_declaration uuid)
RETURNS jsonb LANGUAGE plpgsql STABLE SECURITY DEFINER SET search_path='' AS $f$
DECLARE x clan_aburame_private.verme_sources_v1%ROWTYPE;d public.combat_v2_declarations%ROWTYPE;a public.combat_v2_actors%ROWTYPE;
BEGIN
 SELECT * INTO x FROM clan_aburame_private.verme_sources_v1 WHERE declaration_id=p_declaration;
 IF NOT FOUND THEN RETURN NULL;END IF;
 SELECT * INTO STRICT d FROM public.combat_v2_declarations WHERE id=x.declaration_id;
 SELECT * INTO STRICT a FROM public.combat_v2_actors WHERE id=x.actor_id;
 IF x.profile_sha256<>public.combat_v2_sha256(x.profile) OR x.request_key<>d.request_key OR x.round_id<>d.round_id
 OR x.actor_id<>d.actor_id OR x.target_actor_id<>d.target_actor_id OR x.declaration_principal<>d.controller_user_snapshot
 OR x.controller_version<>d.controller_version_snapshot OR d.sanitized_intent->'server_ability' IS DISTINCT FROM x.profile
 THEN RAISE EXCEPTION 'aburame_verme_source_binding_changed';END IF;
 IF x.state='prepared' AND x.colony_reserved AND NOT EXISTS(SELECT 1 FROM clan_aburame_private.colony_sources c
 WHERE c.owner_id=x.owner_character_id AND c.scope_id=x.scope_id AND c.source_id=x.declaration_id AND c.allocated=5 AND c.state='active')
 THEN RAISE EXCEPTION 'aburame_verme_colony_binding_invalid';END IF;
 IF x.state<>'prepared' OR a.state<>'attivo' OR a.controller_user<>x.controller_user OR a.controller_version<>x.controller_version
 OR(x.colony_reserved AND EXISTS(SELECT 1 FROM clan_aburame_private.colony_sources c WHERE c.owner_id=x.owner_character_id
  AND c.scope_id=x.scope_id AND c.source_id=x.declaration_id AND c.allocated=c.lost)) THEN
 RETURN x.profile||jsonb_build_object('source_lost',true);END IF;
 RETURN x.profile;
END $f$;
CREATE FUNCTION clan_aburame_private.verme_finish_v1(p_declaration uuid,p_target uuid,p_native_success boolean,p_damage integer)
RETURNS jsonb LANGUAGE plpgsql SECURITY DEFINER SET search_path='' AS $f$
DECLARE x clan_aburame_private.verme_sources_v1%ROWTYPE;t public.combat_v2_actors%ROWTYPE;c jsonb;p clan_aburame_private.verme_poison_v1%ROWTYPE;
  applied boolean:=false;refreshed boolean:=false;v_result jsonb;release_receipt jsonb;returned integer:=0;
BEGIN
 SELECT * INTO x FROM clan_aburame_private.verme_sources_v1 WHERE declaration_id=p_declaration FOR UPDATE;
 IF NOT FOUND THEN RETURN NULL;END IF;
 IF x.result IS NOT NULL THEN RETURN x.result;END IF;
 IF(x.scope_kind='simulation' AND(public.combat_v2_values_written(x.session_id) OR NOT combat_panel_private.uses_simulated_pools(x.session_id)))
 OR(x.scope_kind='persistent' AND(NOT public.combat_v2_values_written(x.session_id) OR combat_panel_private.uses_simulated_pools(x.session_id)))
 THEN RAISE EXCEPTION 'aburame_verme_frozen_pool_mode_changed';END IF;
 IF x.target_actor_id<>p_target OR p_damage IS NULL OR p_damage<0 THEN RAISE EXCEPTION 'aburame_verme_result_invalid';END IF;
 IF p_native_success AND p_damage>0 AND NOT x.colony_reserved THEN RAISE EXCEPTION 'aburame_verme_reservation_required';END IF;
 SELECT * INTO STRICT t FROM public.combat_v2_actors WHERE id=p_target AND session_id=x.session_id FOR UPDATE;
 IF x.state='prepared' AND p_native_success AND p_damage>0 AND t.state='attivo'
 AND coalesce((clan_aburame_private.verme_frozen_v1(x.declaration_id)->>'source_lost')::boolean,false)=false THEN
 c:=combat_effects_private.personal_turn(t.session_id,t.id);
 SELECT * INTO p FROM clan_aburame_private.verme_poison_v1 WHERE session_id=x.session_id AND target_actor_id=t.id FOR UPDATE;
 refreshed:=p.id IS NOT NULL AND p.remaining_turns>0;
 INSERT INTO clan_aburame_private.verme_poison_v1(session_id,target_actor_id,source_actor_id,source_declaration_id,excluded_turn_id)
 VALUES(x.session_id,t.id,x.actor_id,x.declaration_id,CASE WHEN c->>'is_current'='true' THEN (c->>'turn_id')::uuid ELSE NULL END)
 ON CONFLICT(session_id,target_actor_id) DO UPDATE SET source_actor_id=excluded.source_actor_id,source_declaration_id=excluded.source_declaration_id,
 excluded_turn_id=excluded.excluded_turn_id,remaining_turns=2,generation=clan_aburame_private.verme_poison_v1.generation+1,end_reason=NULL,updated_at=clock_timestamp();
 applied:=true;
 END IF;
 IF x.state='prepared' AND x.colony_reserved THEN
  release_receipt:=clan_aburame_private.colony_transition(x.owner_character_id,x.scope_id,x.scope_kind,'release',x.declaration_id,1,x.declaration_id,0,NULL);
  returned:=(release_receipt->>'returned')::integer;
 END IF;
 v_result:=jsonb_build_object('contract','aburame-verme/1','source_actor_id',x.actor_id,'target_actor_id',t.id,'toxin_applied',applied,
 'toxin_refreshed',refreshed,'remaining_target_turns',CASE WHEN applied THEN 2 ELSE 0 END,'colony_reserved',CASE WHEN x.colony_reserved THEN 5 ELSE 0 END,'colony_returned',returned,'damage_applied',p_damage);
 UPDATE clan_aburame_private.verme_sources_v1 SET state='resolved',result=v_result,ended_at=clock_timestamp() WHERE declaration_id=x.declaration_id;
 PERFORM clan_aburame_private.verme_event_v1('released:'||x.declaration_id,x.session_id,x.round_id,x.actor_id,t.id,x.declaration_id,'released',v_result);
 IF applied THEN PERFORM clan_aburame_private.verme_event_v1('poison:'||x.declaration_id,x.session_id,x.round_id,x.actor_id,t.id,x.declaration_id,
 CASE WHEN refreshed THEN 'poison_refreshed' ELSE 'poison_applied' END,v_result);END IF;
 RETURN v_result;
END $f$;
CREATE FUNCTION clan_aburame_private.verme_tick_v1(p_session uuid,p_actor uuid,p_turn uuid,p_adapter text)
RETURNS void LANGUAGE plpgsql SECURITY DEFINER SET search_path='' AS $f$
DECLARE a public.combat_v2_actors%ROWTYPE;p clan_aburame_private.verme_poison_v1%ROWTYPE;x clan_aburame_private.verme_sources_v1%ROWTYPE;c jsonb;key text;
 before_hp integer;after_hp integer;reduction integer;damage integer;prior text;facts jsonb;
BEGIN
 PERFORM combat_effects_private.lock_context(p_session);
 SELECT * INTO p FROM clan_aburame_private.verme_poison_v1 WHERE session_id=p_session AND target_actor_id=p_actor AND remaining_turns>0 FOR UPDATE;
 IF p.id IS NULL OR p.excluded_turn_id=p_turn THEN RETURN;END IF;
 SELECT * INTO STRICT x FROM clan_aburame_private.verme_sources_v1 WHERE declaration_id=p.source_declaration_id AND session_id=p_session;
 IF(x.scope_kind='simulation' AND(public.combat_v2_values_written(p_session) OR NOT combat_panel_private.uses_simulated_pools(p_session)))
 OR(x.scope_kind='persistent' AND(NOT public.combat_v2_values_written(p_session) OR combat_panel_private.uses_simulated_pools(p_session)))
 THEN RAISE EXCEPTION 'aburame_verme_frozen_pool_mode_changed';END IF;
 SELECT * INTO STRICT a FROM public.combat_v2_actors WHERE id=p_actor AND session_id=p_session FOR UPDATE;
 c:=combat_effects_private.personal_turn(p_session,p_actor);
 IF p_turn IS NULL OR c->>'turn_id' IS DISTINCT FROM p_turn::text OR c->>'adapter' IS DISTINCT FROM p_adapter
 OR c->>'is_current' IS DISTINCT FROM 'true' OR c->>'phase' IS DISTINCT FROM 'action' THEN RAISE EXCEPTION 'aburame_verme_native_turn_required';END IF;
 key:='tick:'||p.id||':'||p.generation||':'||p_turn;
 IF EXISTS(SELECT 1 FROM clan_aburame_private.verme_events_v1 WHERE event_key=key) OR p.last_tick_turn_id=p_turn THEN RETURN;END IF;
 IF a.state<>'attivo' THEN UPDATE clan_aburame_private.verme_poison_v1 SET remaining_turns=0,end_reason='target_inoperative',updated_at=clock_timestamp() WHERE id=p.id;RETURN;END IF;
 before_hp:=(a.mechanics_snapshot->>'vita')::integer;
 IF before_hp IS NULL OR before_hp<=0 OR (a.mechanics_snapshot->>'resistenza')::integer IS NULL THEN RAISE EXCEPTION 'aburame_verme_target_snapshot_invalid';END IF;
 -- Tossina derivata: nessun dado, contributo statistiche zero, bonus margine zero.
 reduction:=greatest(0,(a.mechanics_snapshot->>'resistenza')::integer/40);damage:=greatest(1,5-reduction);after_hp:=greatest(0,before_hp-damage);
 facts:=jsonb_build_object('contract','aburame-verme/1','source_actor_id',p.source_actor_id,'target_actor_id',a.id,
 'toxin_tick',true,'damage_base',5,'resistance_reduction',reduction,'damage_applied',before_hp-after_hp,'turn_id',p_turn,
 'remaining_target_turns',CASE WHEN after_hp=0 THEN 0 ELSE p.remaining_turns-1 END,'ko',after_hp=0);
 UPDATE clan_aburame_private.verme_poison_v1 SET remaining_turns=CASE WHEN after_hp=0 THEN 0 ELSE remaining_turns-1 END,
 end_reason=CASE WHEN after_hp=0 THEN 'target_inoperative' WHEN remaining_turns=1 THEN 'duration_complete' ELSE NULL END,
 last_tick_turn_id=p_turn,updated_at=clock_timestamp() WHERE id=p.id;
 PERFORM clan_aburame_private.verme_event_v1(key,p_session,(c->>'round_id')::uuid,p.source_actor_id,a.id,p.source_declaration_id,'poison_tick',facts);
 UPDATE public.combat_v2_actors SET mechanics_snapshot=jsonb_set(mechanics_snapshot,'{vita}',to_jsonb(after_hp),false),
 state=CASE WHEN after_hp=0 THEN 'fuori' ELSE state END WHERE id=a.id;
 IF public.combat_v2_values_written(p_session) AND a.actor_kind='pg' THEN
 prior:=current_setting('app.allow_vita_delta',true);PERFORM set_config('app.allow_vita_delta','1',true);
 UPDATE public.characters SET vita=after_hp WHERE id=a.character_id;PERFORM set_config('app.allow_vita_delta',coalesce(prior,''),true);END IF;
END $f$;
CREATE FUNCTION clan_aburame_private.verme_end_context_v1()
RETURNS trigger LANGUAGE plpgsql SECURITY DEFINER SET search_path='' AS $f$
DECLARE sid uuid;x clan_aburame_private.verme_sources_v1%ROWTYPE;p clan_aburame_private.verme_poison_v1%ROWTYPE;r uuid;reason text;f jsonb;release_receipt jsonb;
BEGIN
 IF TG_TABLE_NAME='combat_v2_sessions' THEN sid:=NEW.id;IF NEW.closed_at IS NULL AND NEW.state NOT IN('annullato','chiuso','risolto') THEN RETURN NEW;END IF;
 ELSIF TG_TABLE_NAME='combat_v2_actors' THEN sid:=NEW.session_id;IF NEW.state='attivo' THEN RETURN NEW;END IF;
 ELSE RAISE EXCEPTION 'aburame_verme_lifecycle_table';END IF;
 FOR x IN SELECT * FROM clan_aburame_private.verme_sources_v1 WHERE session_id=sid AND state='prepared'
 AND(TG_TABLE_NAME='combat_v2_sessions' OR actor_id=NEW.id) ORDER BY declaration_id FOR UPDATE LOOP
 release_receipt:=NULL;
 IF x.colony_reserved THEN release_receipt:=clan_aburame_private.colony_transition(x.owner_character_id,x.scope_id,x.scope_kind,'release',x.declaration_id,1,x.declaration_id,0,NULL);END IF;
 f:=jsonb_build_object('contract','aburame-verme/1','source_lost',true,'toxin_applied',false,'toxin_refreshed',false,'remaining_target_turns',0,'damage_applied',0,
 'colony_returned',coalesce((release_receipt->>'returned')::integer,0));
 UPDATE clan_aburame_private.verme_sources_v1 SET state='ended',ended_at=clock_timestamp(),result=f WHERE declaration_id=x.declaration_id;
 PERFORM clan_aburame_private.verme_event_v1('released:'||x.declaration_id,x.session_id,x.round_id,x.actor_id,x.target_actor_id,x.declaration_id,'released',f);
 END LOOP;
 -- KO del caster non cancella tossine già applicate ad altri attori.
 reason:=CASE WHEN TG_TABLE_NAME='combat_v2_sessions' THEN 'combat_end' ELSE 'target_inoperative' END;
 SELECT id INTO r FROM public.combat_v2_rounds WHERE session_id=sid ORDER BY round_no DESC LIMIT 1;
 FOR p IN SELECT * FROM clan_aburame_private.verme_poison_v1 WHERE session_id=sid AND remaining_turns>0
 AND(TG_TABLE_NAME='combat_v2_sessions' OR target_actor_id=NEW.id) ORDER BY target_actor_id FOR UPDATE LOOP
  UPDATE clan_aburame_private.verme_poison_v1 SET remaining_turns=0,end_reason=reason,updated_at=clock_timestamp() WHERE id=p.id;
  PERFORM clan_aburame_private.verme_event_v1('end:'||p.id||':'||p.generation||':'||reason,sid,r,p.source_actor_id,p.target_actor_id,p.source_declaration_id,'poison_end',
   jsonb_build_object('contract','aburame-verme/1','reason',reason,'remaining_target_turns',0,'ko',reason='target_inoperative'));
 END LOOP;
 RETURN NEW;
END $f$;
CREATE FUNCTION clan_aburame_private.verme_reserve_round_v1(p_round uuid)
RETURNS void LANGUAGE plpgsql SECURITY DEFINER SET search_path='' AS $f$
DECLARE x clan_aburame_private.verme_sources_v1%ROWTYPE;m jsonb;
BEGIN
 FOR x IN SELECT * FROM clan_aburame_private.verme_sources_v1 WHERE round_id=p_round AND state='prepared' ORDER BY owner_character_id,declaration_id FOR UPDATE LOOP
  m:=clan_aburame_private.verme_frozen_v1(x.declaration_id);
  IF m->>'source_lost'='true' OR x.colony_reserved THEN CONTINUE;END IF;
  -- Allocate controlla la disponibilità sotto lock Colonia prima che il resolver impegni chakra e principale.
  PERFORM clan_aburame_private.colony_transition(x.owner_character_id,x.scope_id,x.scope_kind,'allocate',x.request_key,0,x.declaration_id,5,NULL);
  UPDATE clan_aburame_private.verme_sources_v1 SET colony_reserved=true WHERE declaration_id=x.declaration_id;
 END LOOP;
END $f$;
CREATE FUNCTION clan_aburame_private.verme_settle_round_v1(p_round uuid)
RETURNS void LANGUAGE plpgsql SECURITY DEFINER SET search_path='' AS $f$
DECLARE x clan_aburame_private.verme_sources_v1%ROWTYPE;
BEGIN
 -- Anche bersaglio già KO o attacco superfluo restituiscono la sola quota propria, senza rimborsi chakra.
 FOR x IN SELECT * FROM clan_aburame_private.verme_sources_v1 WHERE round_id=p_round AND state='prepared' ORDER BY declaration_id FOR UPDATE LOOP
  PERFORM clan_aburame_private.verme_finish_v1(x.declaration_id,x.target_actor_id,false,0);
 END LOOP;
END $f$;
CREATE OR REPLACE FUNCTION clan_akimichi_private.common_scope_v1(p_actor uuid,p_ability uuid)
RETURNS jsonb LANGUAGE plpgsql STABLE SECURITY DEFINER SET search_path='' AS $fn$
DECLARE a public.combat_v2_actors%ROWTYPE;s jsonb;p clan_akimichi_private.common_staff_profiles_v1%ROWTYPE;
 v_grade text;v_kg integer;v_level uuid;
BEGIN
 IF p_ability IS NULL OR p_ability NOT IN('f5f26cb5-9b6f-44b3-94bc-c329a0a88b93'::uuid,'687b058a-807d-4cf7-8bcf-21147931b0f6'::uuid) THEN RETURN NULL;END IF;
 SELECT * INTO a FROM public.combat_v2_actors WHERE id=p_actor AND actor_kind='pg' AND companion_id IS NULL AND state='attivo';
 IF NOT FOUND OR coalesce((a.mechanics_snapshot->>'vita')::integer,0)<=0 THEN RETURN NULL;END IF;
 s:=clan_akimichi_private.scope_for_actor(a.id,'3b4c4fd0-c0c2-46a0-a387-f47a95ef7dda');
 IF s IS NULL THEN RETURN NULL;END IF;
 v_kg:=CASE WHEN p_ability='f5f26cb5-9b6f-44b3-94bc-c329a0a88b93' THEN 70 ELSE 50 END;
 IF (s->>'permanent_kg')::integer<v_kg THEN RETURN NULL;END IF;
 IF (s->>'simulated')::boolean THEN
  IF NOT clan_akimichi_private.common_staff_scope_v1(a.id) THEN RETURN NULL;END IF;
  SELECT * INTO p FROM clan_akimichi_private.common_staff_profiles_v1 WHERE actor_id=a.id AND session_id=a.session_id;
  IF NOT FOUND OR p.character_id IS DISTINCT FROM a.character_id OR p.controller_user IS DISTINCT FROM a.controller_user
   OR p.controller_version IS DISTINCT FROM a.controller_version OR p.profile_sha256 IS DISTINCT FROM public.combat_v2_sha256(p.profile)
   OR p.profile->>'contract' IS DISTINCT FROM 'akimichi-common/1'
   OR p.profile IS DISTINCT FROM a.mechanics_snapshot->'akimichi_common_staff_profile' THEN RETURN NULL;END IF;
 ELSE
  IF NOT EXISTS(SELECT 1 FROM clan_akimichi_private.common_gate_v1 WHERE singleton AND public_enabled
   AND CASE WHEN p_ability='f5f26cb5-9b6f-44b3-94bc-c329a0a88b93'::uuid THEN super_public_enabled ELSE cellular_public_enabled END)
  THEN RETURN NULL;END IF;
  v_grade:=CASE WHEN p_ability='f5f26cb5-9b6f-44b3-94bc-c329a0a88b93' THEN 'Jonin' ELSE 'Chunin' END;
  v_level:=CASE WHEN v_grade='Jonin' THEN 'dd2026b4-bffc-490e-8646-be411d4746b3'::uuid ELSE '09097efd-e162-4cae-a644-5e643fe94f8c'::uuid END;
  IF NOT EXISTS(SELECT 1 FROM public.characters c WHERE c.id=a.character_id AND c.user_id=a.controller_user
    AND c.clan='Akimichi' AND public._grade_rank(c.rank)>=public._grade_rank(v_grade))
   OR NOT EXISTS(SELECT 1 FROM public.character_abilities b WHERE b.character_id=a.character_id AND b.technique_id=p_ability AND b.state='attiva')
   OR NOT EXISTS(SELECT 1 FROM public.character_abilities b WHERE b.character_id=a.character_id AND b.technique_id=v_level AND b.state='attiva')
   OR(p_ability='687b058a-807d-4cf7-8bcf-21147931b0f6' AND NOT EXISTS(SELECT 1 FROM public.character_abilities b
     WHERE b.character_id=a.character_id AND b.technique_id='214af896-15f8-43e6-858b-614d2851dd3b' AND b.state='attiva'))
  THEN RETURN NULL;END IF;
 END IF;
 RETURN s;
END $fn$;
CREATE OR REPLACE FUNCTION clan_akimichi_private.common_prepare_staff_v1(p_actor uuid,p_context uuid,p_request uuid)
RETURNS jsonb LANGUAGE plpgsql SECURITY DEFINER SET search_path='' AS $fn$
DECLARE a public.combat_v2_actors%ROWTYPE;c combat_panel_private.contexts%ROWTYPE;profile jsonb;defs jsonb;
 res integer;kg integer:=70;init uuid;
BEGIN
 SELECT * INTO STRICT a FROM public.combat_v2_actors WHERE id=p_actor FOR UPDATE;
 SELECT * INTO STRICT c FROM combat_panel_private.contexts WHERE id=p_context AND command_actor_id=a.id AND principal_user=auth.uid();
 IF NOT public.is_staff() OR a.controller_user IS DISTINCT FROM auth.uid()
  OR NOT clan_akimichi_private.common_staff_scope_v1(a.id)
  OR c.activity_id IS DISTINCT FROM a.session_id OR c.round_id IS NULL
  OR NOT combat_panel_private.cure_turn_clear_v1(c.round_id,a.id)
  OR EXISTS(SELECT 1 FROM clan_akimichi_private.staff_profiles WHERE actor_id=a.id)
  OR EXISTS(SELECT 1 FROM clan_akimichi_private.common_staff_profiles_v1 WHERE actor_id=a.id)
  OR EXISTS(SELECT 1 FROM clan_akimichi_private.forms WHERE actor_id=a.id AND active)
  OR (combat_panel_private.movement_budget(a.id,c.round_id)->>'spent_m')::numeric IS DISTINCT FROM 0
 THEN RAISE EXCEPTION 'AKIMICHI_COMMON_STAFF_PREPARATION_INVALID' USING ERRCODE='42501';END IF;
 IF a.mechanics_snapshot->>'resistenza' !~ '^[0-9]{1,6}$' THEN RAISE EXCEPTION 'AKIMICHI_COMMON_RESISTANCE_REQUIRED';END IF;
 res:=(a.mechanics_snapshot->>'resistenza')::integer;
 profile:=jsonb_build_object('contract','akimichi-common/1','context',c.id,'controller',a.controller_user,
  'controller_version',a.controller_version,'kg',kg,'resistance',res,'techniques',jsonb_build_array(
   'f5f26cb5-9b6f-44b3-94bc-c329a0a88b93','687b058a-807d-4cf7-8bcf-21147931b0f6'));
 SELECT jsonb_agg(jsonb_build_object('source','clan','id',t.id,'name',t.name,'kind','fisico','usage',t.uso,
   'range',t.gittata,'chakra_cost',0,'damage_base',0,'defensive',t.difensiva,'di_scena',false,'diversivo',false) ORDER BY t.id)
 INTO defs FROM public.clan_techniques t WHERE t.id IN(
  'bc2569b5-eab4-44b4-9843-c199724caff4'::uuid,'3b4c4fd0-c0c2-46a0-a387-f47a95ef7dda'::uuid,
  '214af896-15f8-43e6-858b-614d2851dd3b'::uuid,'f5f26cb5-9b6f-44b3-94bc-c329a0a88b93'::uuid,'687b058a-807d-4cf7-8bcf-21147931b0f6'::uuid) AND t.is_active;
 IF jsonb_array_length(defs) IS DISTINCT FROM 5 THEN RAISE EXCEPTION 'AKIMICHI_COMMON_CATALOG_REQUIRED';END IF;
 INSERT INTO clan_akimichi_private.staff_profiles VALUES(a.session_id,a.id,a.character_id,kg,res);
 init:=md5('akimichi-common-staff/1|'||a.id::text||'|'||p_request::text)::uuid;
 PERFORM clan_akimichi_private.apply_calorie_event(a.character_id,a.session_id,true,init,'initialize',kg,res);
 INSERT INTO clan_akimichi_private.common_staff_profiles_v1(actor_id,session_id,context_id,character_id,controller_user,
  controller_version,request_key,profile,profile_sha256)
 VALUES(a.id,a.session_id,c.id,a.character_id,a.controller_user,a.controller_version,p_request,profile,public.combat_v2_sha256(profile));
 UPDATE public.combat_v2_actors SET mechanics_snapshot=jsonb_set(jsonb_set(jsonb_set(mechanics_snapshot,
  '{kekkei_genkai}',to_jsonb(kg),true),'{abilities}',coalesce((SELECT jsonb_agg(v) FROM jsonb_array_elements(
   coalesce(mechanics_snapshot->'abilities','[]'))v WHERE v->>'id' NOT IN(
    'bc2569b5-eab4-44b4-9843-c199724caff4','3b4c4fd0-c0c2-46a0-a387-f47a95ef7dda','214af896-15f8-43e6-858b-614d2851dd3b',
    'f5f26cb5-9b6f-44b3-94bc-c329a0a88b93','687b058a-807d-4cf7-8bcf-21147931b0f6')),'[]')||defs,true),
   '{akimichi_common_staff_profile}',profile,true) WHERE id=a.id;
 RETURN jsonb_build_object('prepared',true,'values_written',false,'profile_sha256',public.combat_v2_sha256(profile));
END $fn$;
CREATE OR REPLACE FUNCTION clan_akimichi_private.common_modifiers_v1(p_form text,p_kg integer,p_force integer,p_resistance integer)
RETURNS jsonb LANGUAGE plpgsql IMMUTABLE STRICT SET search_path='' AS $fn$
BEGIN
 IF p_form NOT IN('base','super') OR least(p_kg,p_force,p_resistance)<0 THEN RAISE EXCEPTION 'AKIMICHI_COMMON_MODIFIERS_INVALID';END IF;
 RETURN jsonb_build_object('form',p_form,'mass',CASE WHEN p_form='super' THEN(p_kg+p_force)/20 ELSE(p_kg+p_force)/30 END,
 'physical_resilience',CASE WHEN p_form='super' THEN(p_kg+p_resistance)/30 ELSE(p_kg+p_resistance)/40 END,
 'calorie_cost',CASE WHEN p_form='super' THEN 15 ELSE 5 END,'chakra_cost',0);
END $fn$;
CREATE OR REPLACE FUNCTION clan_akimichi_private.common_set_form_v1(p_actor uuid,p_event uuid,p_form text)
RETURNS jsonb LANGUAGE plpgsql SECURITY DEFINER SET search_path='' AS $fn$
DECLARE a public.combat_v2_actors%ROWTYPE;f clan_akimichi_private.forms%ROWTYPE;s jsonb;modifiers jsonb;debit jsonb;result jsonb;
 previous clan_akimichi_private.common_form_commands_v1%ROWTYPE;turn_id uuid;cost integer;
BEGIN
 IF p_event IS NULL OR p_form IS NULL OR p_form NOT IN('base','super','off') OR auth.uid() IS NULL THEN RAISE EXCEPTION 'AKIMICHI_COMMON_FORM_COMMAND_INVALID' USING ERRCODE='42501';END IF;
 SELECT * INTO STRICT a FROM public.combat_v2_actors WHERE id=p_actor FOR UPDATE;
 IF a.controller_user IS DISTINCT FROM auth.uid() THEN RAISE EXCEPTION 'AKIMICHI_COMMON_FORM_OWNER' USING ERRCODE='42501';END IF;
 SELECT * INTO previous FROM clan_akimichi_private.common_form_commands_v1 WHERE actor_id=a.id AND session_id=a.session_id AND event_id=p_event;
 IF FOUND THEN IF previous.form_kind<>p_form THEN RAISE EXCEPTION 'AKIMICHI_COMMON_FORM_REPLAY_CONFLICT';END IF;RETURN previous.result;END IF;
 s:=clan_akimichi_private.common_scope_v1(a.id,'f5f26cb5-9b6f-44b3-94bc-c329a0a88b93');
 IF s IS NULL OR (s->>'is_turn_owner')::boolean IS DISTINCT FROM true OR s->>'phase'<>'action'
  OR EXISTS(SELECT 1 FROM public.combat_v2_declarations d WHERE d.round_id=(s->>'round')::uuid AND d.actor_id=a.id)
  OR NOT combat_panel_private.human_duel_turn_allowed((s->>'round')::uuid,a.id)
  OR (combat_panel_private.movement_budget(a.id,(s->>'round')::uuid)->>'spent_m')::numeric IS DISTINCT FROM 0
 THEN RAISE EXCEPTION 'AKIMICHI_COMMON_FORM_WINDOW' USING ERRCODE='55000';END IF;
 turn_id:=(s->>'turn')::uuid;
 SELECT * INTO f FROM clan_akimichi_private.forms WHERE actor_id=a.id AND session_id=a.session_id FOR UPDATE;
 IF p_form='off' THEN
  IF NOT coalesce(f.active,false) THEN RAISE EXCEPTION 'AKIMICHI_COMMON_FORM_NOT_ACTIVE';END IF;
  PERFORM clan_akimichi_private.end_form(a.id,a.session_id,'deactivated');cost:=0;
 ELSE
  IF (coalesce(f.active,false) AND f.form_kind=p_form) OR f.activation_turn=turn_id
   OR EXISTS(SELECT 1 FROM clan_akimichi_private.common_form_commands_v1 q WHERE q.actor_id=a.id AND q.session_id=a.session_id AND q.result->>'turn'=turn_id::text)
   OR EXISTS(SELECT 1 FROM clan_akimichi_private.form_commands q WHERE q.actor_id=a.id AND q.session_id=a.session_id AND q.result->>'turn'=turn_id::text)
  THEN RAISE EXCEPTION 'AKIMICHI_COMMON_FORM_CHANGED_THIS_TURN';END IF;
  IF NOT EXISTS(SELECT 1 FROM combat_spatial.arena_instances i JOIN combat_spatial.actor_states b ON b.instance_id=i.instance_id
    WHERE i.encounter_id=a.session_id AND i.state='open' AND b.actor_id=a.id AND b.state='active')
  THEN RAISE EXCEPTION 'AKIMICHI_COMMON_FORM_BODY_UNAVAILABLE';END IF;
  modifiers:=clan_akimichi_private.common_modifiers_v1(p_form,(a.mechanics_snapshot->>'kekkei_genkai')::integer,
   (a.mechanics_snapshot->>'forza')::integer,(a.mechanics_snapshot->>'resistenza')::integer);
  IF modifiers IS NULL THEN RAISE EXCEPTION 'AKIMICHI_COMMON_FORM_STATS_REQUIRED';END IF;
  cost:=(modifiers->>'calorie_cost')::integer;
  PERFORM 1 FROM clan_akimichi_private.calorie_reserves c WHERE c.owner_id=(s->>'owner')::uuid AND c.scope_id=(s->>'scope')::uuid FOR UPDATE;
  IF coalesce(clan_akimichi_private.common_calorie_balance_v1((s->>'owner')::uuid,(s->>'scope')::uuid,NULL,a.id),-1)<cost
  THEN RAISE EXCEPTION 'AKIMICHI_COMMON_FORM_CALORIES_INSUFFICIENT';END IF;
  debit:=clan_akimichi_private.apply_calorie_event((s->>'owner')::uuid,(s->>'scope')::uuid,(s->>'simulated')::boolean,p_event,
   CASE WHEN p_form='super' THEN 'super_activate' ELSE 'activate' END,(s->>'permanent_kg')::integer,(s->>'permanent_resistance')::integer);
  IF (debit->>'accepted')::boolean IS DISTINCT FROM true THEN RAISE EXCEPTION 'AKIMICHI_COMMON_FORM_CALORIES_INSUFFICIENT';END IF;
  INSERT INTO clan_akimichi_private.forms(actor_id,session_id,activation_turn,last_paid_turn,activation_event,mass,resilience,active,form_kind)
  VALUES(a.id,a.session_id,turn_id,turn_id,p_event,(modifiers->>'mass')::integer,(modifiers->>'physical_resilience')::integer,true,p_form)
  ON CONFLICT(actor_id) DO UPDATE SET activation_turn=excluded.activation_turn,last_paid_turn=excluded.last_paid_turn,
   activation_event=excluded.activation_event,mass=excluded.mass,resilience=excluded.resilience,active=true,ended_reason=NULL,form_kind=excluded.form_kind
  WHERE clan_akimichi_private.forms.session_id=excluded.session_id;
  IF NOT FOUND THEN RAISE EXCEPTION 'AKIMICHI_COMMON_FORM_SESSION_CONFLICT';END IF;
 END IF;
 result:=jsonb_build_object('contract','akimichi-common/1','form',p_form,'turn',turn_id,'active',p_form<>'off',
  'spent_calories',cost,'values_written',cost>0 AND NOT(s->>'simulated')::boolean);
 INSERT INTO clan_akimichi_private.common_form_commands_v1 VALUES(a.id,a.session_id,p_event,p_form,result);
 UPDATE clan_akimichi_private.common_pending_upkeep_v1 SET state='replaced'
 WHERE actor_id=a.id AND session_id=a.session_id AND personal_turn_id=turn_id AND state='pending';
 RETURN result;
END $fn$;
CREATE OR REPLACE FUNCTION clan_akimichi_private.common_defer_upkeep_v1(p_actor uuid,p_turn uuid)
RETURNS boolean LANGUAGE plpgsql SECURITY DEFINER SET search_path='' AS $fn$
DECLARE f clan_akimichi_private.forms%ROWTYPE;s jsonb;amount integer;cost integer;
BEGIN
 SELECT * INTO f FROM clan_akimichi_private.forms WHERE actor_id=p_actor AND active FOR UPDATE;
 IF NOT FOUND OR f.last_paid_turn=p_turn THEN RETURN false;END IF;
 s:=clan_akimichi_private.common_scope_v1(p_actor,'f5f26cb5-9b6f-44b3-94bc-c329a0a88b93');
 IF s IS NULL THEN RETURN false;END IF;
 IF p_turn IS NULL OR (s->>'turn')::uuid IS DISTINCT FROM p_turn OR(s->>'is_turn_owner')::boolean IS DISTINCT FROM true
 OR s->>'phase' IS DISTINCT FROM 'action' THEN RAISE EXCEPTION 'AKIMICHI_COMMON_UPKEEP_WINDOW';END IF;
 cost:=CASE WHEN f.form_kind='super' THEN 15 ELSE 5 END;
 SELECT current_amount INTO amount FROM clan_akimichi_private.calorie_reserves
 WHERE owner_id=(s->>'owner')::uuid AND scope_id=(s->>'scope')::uuid FOR UPDATE;
 IF coalesce(amount,0)<cost THEN
  PERFORM clan_akimichi_private.end_form(p_actor,f.session_id,'insufficient_calories');
  RETURN true;
 END IF;
 INSERT INTO clan_akimichi_private.common_pending_upkeep_v1(actor_id,session_id,personal_turn_id,form_kind)
 VALUES(p_actor,f.session_id,p_turn,f.form_kind) ON CONFLICT DO NOTHING;
 RETURN true;
END $fn$;
CREATE OR REPLACE FUNCTION clan_akimichi_private.common_flush_upkeep_v1(p_actor uuid)
RETURNS void LANGUAGE plpgsql SECURITY DEFINER SET search_path='' AS $fn$
DECLARE q clan_akimichi_private.common_pending_upkeep_v1%ROWTYPE;f clan_akimichi_private.forms%ROWTYPE;s jsonb;r jsonb;event uuid;
BEGIN
 SELECT * INTO q FROM clan_akimichi_private.common_pending_upkeep_v1 WHERE actor_id=p_actor AND state='pending' FOR UPDATE;
 IF NOT FOUND THEN RETURN;END IF;
 SELECT * INTO f FROM clan_akimichi_private.forms WHERE actor_id=p_actor AND session_id=q.session_id AND active FOR UPDATE;
 IF NOT FOUND THEN
  UPDATE clan_akimichi_private.common_pending_upkeep_v1 SET state='ended' WHERE actor_id=q.actor_id AND session_id=q.session_id AND personal_turn_id=q.personal_turn_id;RETURN;
 END IF;
 s:=clan_akimichi_private.common_scope_v1(p_actor,'f5f26cb5-9b6f-44b3-94bc-c329a0a88b93');
 IF s IS NULL THEN
  PERFORM clan_akimichi_private.end_form(p_actor,q.session_id,'source_unavailable');
  UPDATE clan_akimichi_private.common_pending_upkeep_v1 SET state='ended' WHERE actor_id=q.actor_id AND session_id=q.session_id AND personal_turn_id=q.personal_turn_id;RETURN;
 END IF;
 IF(s->>'turn')::uuid IS DISTINCT FROM q.personal_turn_id OR(s->>'is_turn_owner')::boolean IS DISTINCT FROM true
  OR s->>'phase' IS DISTINCT FROM 'action' OR f.form_kind IS DISTINCT FROM q.form_kind
 THEN RAISE EXCEPTION 'AKIMICHI_COMMON_UPKEEP_STALE';END IF;
 event:=md5('akimichi-expansion-upkeep/1|'||p_actor::text||'|'||q.personal_turn_id::text)::uuid;
 r:=clan_akimichi_private.apply_calorie_event((s->>'owner')::uuid,(s->>'scope')::uuid,(s->>'simulated')::boolean,event,
  CASE WHEN f.form_kind='super' THEN 'super_upkeep' ELSE 'upkeep' END,(s->>'permanent_kg')::integer,(s->>'permanent_resistance')::integer);
 IF(r->>'accepted')::boolean IS TRUE THEN
  UPDATE clan_akimichi_private.forms SET last_paid_turn=q.personal_turn_id WHERE actor_id=p_actor AND session_id=q.session_id;
 ELSE PERFORM clan_akimichi_private.end_form(p_actor,q.session_id,'insufficient_calories');END IF;
 UPDATE clan_akimichi_private.common_pending_upkeep_v1 SET state=CASE WHEN(r->>'accepted')::boolean IS TRUE THEN 'paid' ELSE 'ended' END,
 receipt=r WHERE actor_id=q.actor_id AND session_id=q.session_id AND personal_turn_id=q.personal_turn_id;
END $fn$;
CREATE OR REPLACE FUNCTION clan_akimichi_private.cellular_meta_v1(p_actor uuid)
RETURNS jsonb LANGUAGE plpgsql STABLE SECURITY DEFINER SET search_path='' AS $fn$
DECLARE s jsonb;r integer;
BEGIN
 s:=clan_akimichi_private.common_scope_v1(p_actor,'687b058a-807d-4cf7-8bcf-21147931b0f6');
 IF s IS NULL THEN RETURN NULL;END IF;
 IF combat_panel_private.nara_controlled_v1(p_actor) THEN RETURN NULL;END IF;
 IF combat_panel_private.cure_turn_used_v1((s->>'round')::uuid,p_actor) THEN RETURN NULL;END IF;
 r:=clan_akimichi_private.common_calorie_balance_v1((s->>'owner')::uuid,(s->>'scope')::uuid,NULL);
 IF coalesce(r,0)<10 THEN RETURN NULL;END IF;
 RETURN jsonb_build_object('source','clan','id','687b058a-807d-4cf7-8bcf-21147931b0f6','name','Espansione Difensiva Cellulare',
  'kind','taijutsu','usage','difesa','defensive',true,'range','contatto','chakra_cost',0,'damage_base',0,
  'consumption_type','ad_utilizzo','di_scena',false,'diversivo',false,'akimichi_cellular_contract','akimichi-cellular/1',
  'targeting',jsonb_build_object('mode','self','max_targets',1));
END $fn$;
CREATE OR REPLACE FUNCTION clan_akimichi_private.cellular_bind_v1(p_defense uuid)
RETURNS void LANGUAGE plpgsql SECURITY DEFINER SET search_path='' AS $fn$
DECLARE d public.combat_v2_declarations%ROWTYPE;a public.combat_v2_actors%ROWTYPE;s jsonb;prof jsonb;kg integer;res integer;patt jsonb;
BEGIN
 SELECT * INTO STRICT d FROM public.combat_v2_declarations WHERE id=p_defense;
 IF d.sanitized_intent->>'ability_source' IS DISTINCT FROM 'clan' OR d.sanitized_intent->>'ability_id' IS DISTINCT FROM '687b058a-807d-4cf7-8bcf-21147931b0f6' THEN RETURN;END IF;
 SELECT * INTO STRICT a FROM public.combat_v2_actors WHERE id=d.actor_id FOR UPDATE;
 IF d.kind<>'difesa' OR d.target_actor_id IS DISTINCT FROM a.id OR d.sanitized_intent->>'reaction'<>'tecnica'
  OR d.sanitized_intent#>>'{server_ability,akimichi_cellular_contract}' IS DISTINCT FROM 'akimichi-cellular/1'
  OR clan_akimichi_private.cellular_meta_v1(a.id) IS NULL
  OR NOT EXISTS(SELECT 1 FROM clan_akimichi_private.common_attack_powers_v1 p
    JOIN public.combat_v2_declarations attack ON attack.id=p.declaration_id AND attack.round_id=d.round_id AND attack.kind='attacco'
    JOIN public.combat_v2_attack_targets t ON t.attack_declaration_id=attack.id AND t.target_actor_id=a.id AND t.state='coperta'
    JOIN public.combat_v2_defense_coverages cv ON cv.attack_target_id=t.id AND cv.defense_declaration_id=d.id AND cv.mode='self'
    WHERE p.declaration_id=d.parent_attack_id AND p.source_sha256=public.combat_v2_sha256(p.profile)
     AND p.declaration_sha256=clan_hyuga_private.juken_declaration_fingerprint(attack.id)
     AND lower(coalesce(attack.sanitized_intent#>>'{server_ability,kind}','fisico'))='fisico'
     AND coalesce((attack.cost_snapshot->>'damage_base')::integer,0)>0
     AND attack.sanitized_intent->'target_fili' IS DISTINCT FROM 'true'::jsonb)
  OR d.controller_version_snapshot IS DISTINCT FROM a.controller_version
 THEN RAISE EXCEPTION 'AKIMICHI_CELLULAR_DECLARATION_INVALID';END IF;
 s:=clan_akimichi_private.common_scope_v1(a.id,'687b058a-807d-4cf7-8bcf-21147931b0f6');
 SELECT profile INTO STRICT patt FROM clan_akimichi_private.common_attack_powers_v1 WHERE declaration_id=d.parent_attack_id;
 kg:=(a.mechanics_snapshot->>'kekkei_genkai')::integer;res:=(a.mechanics_snapshot->>'resistenza')::integer;
 prof:=jsonb_build_object('contract','akimichi-cellular/1','declaration_sha256',clan_hyuga_private.juken_declaration_fingerprint(d.id),
  'kg',kg,'resistance',res,'pool',kg+res,'power_base',25,'power_contribution',(kg+res)/10,'power',25+(kg+res)/10,
  'attack_power_source',patt,'chakra_cost',0,'calorie_cost',10,'self_only',true);
 INSERT INTO clan_akimichi_private.cellular_sources_v1(declaration_id,attack_declaration_id,actor_id,session_id,round_id,
  owner_id,scope_id,simulated,controller_version,permanent_kg,permanent_resistance,profile,source_sha256)
 VALUES(d.id,d.parent_attack_id,a.id,a.session_id,d.round_id,(s->>'owner')::uuid,(s->>'scope')::uuid,(s->>'simulated')::boolean,
  a.controller_version,(s->>'permanent_kg')::integer,(s->>'permanent_resistance')::integer,prof,public.combat_v2_sha256(prof));
 PERFORM clan_akimichi_private.common_admit_calories_v1(d.id);
END $fn$;
CREATE OR REPLACE FUNCTION clan_akimichi_private.cellular_pay_v1(p_defense uuid)
RETURNS void LANGUAGE plpgsql SECURITY DEFINER SET search_path='' AS $fn$
DECLARE s clan_akimichi_private.cellular_sources_v1%ROWTYPE;d public.combat_v2_declarations%ROWTYPE;a public.combat_v2_actors%ROWTYPE;q jsonb;
BEGIN
 SELECT * INTO s FROM clan_akimichi_private.cellular_sources_v1 WHERE declaration_id=p_defense FOR UPDATE;
 IF NOT FOUND OR s.calorie_receipt IS NOT NULL THEN RETURN;END IF;
 SELECT * INTO STRICT d FROM public.combat_v2_declarations WHERE id=p_defense;
 SELECT * INTO STRICT a FROM public.combat_v2_actors WHERE id=s.actor_id AND session_id=s.session_id FOR UPDATE;
 IF d.state IS DISTINCT FROM 'congelata' OR NOT clan_akimichi_private.cellular_source_valid_v1(d.id)
  OR a.controller_version IS DISTINCT FROM s.controller_version OR a.character_id IS DISTINCT FROM s.owner_id
  OR s.simulated IS DISTINCT FROM (NOT public.combat_v2_values_written(s.session_id))
  OR(s.simulated AND NOT combat_panel_private.uses_simulated_pools(s.session_id))
 THEN RAISE EXCEPTION 'AKIMICHI_CELLULAR_PAYMENT_BINDING_INVALID';END IF;
 q:=clan_akimichi_private.apply_calorie_event(s.owner_id,s.scope_id,s.simulated,d.id,'cellular',s.permanent_kg,s.permanent_resistance);
 IF (q->>'accepted')::boolean IS DISTINCT FROM true THEN RAISE EXCEPTION 'AKIMICHI_CELLULAR_CALORIES_INSUFFICIENT';END IF;
 UPDATE clan_akimichi_private.cellular_sources_v1 SET calorie_receipt=q WHERE declaration_id=d.id;
END $fn$;
CREATE OR REPLACE FUNCTION clan_akimichi_private.cellular_snapshot_v1(p_defense uuid,p_native jsonb)
RETURNS jsonb LANGUAGE plpgsql STABLE SECURITY DEFINER SET search_path='' AS $fn$
DECLARE s clan_akimichi_private.cellular_sources_v1%ROWTYPE;
BEGIN
 SELECT * INTO s FROM clan_akimichi_private.cellular_sources_v1 WHERE declaration_id=p_defense;
 IF NOT FOUND THEN RETURN p_native;END IF;
 IF NOT clan_akimichi_private.cellular_source_valid_v1(p_defense) THEN RAISE EXCEPTION 'AKIMICHI_CELLULAR_SOURCE_CORRUPT';END IF;
 RETURN p_native||jsonb_build_object('velocita',s.profile->'kg','taijutsu',s.profile->'resistance');
END $fn$;
CREATE OR REPLACE FUNCTION clan_akimichi_private.cellular_calculate_v1(p_defense uuid,p_native jsonb,p_final_margin integer,p_base integer)
RETURNS jsonb LANGUAGE plpgsql STABLE SECURITY DEFINER SET search_path='' AS $fn$
DECLARE s clan_akimichi_private.cellular_sources_v1%ROWTYPE;pa numeric;pd numeric;raw_damage bigint;
 numerator numeric;denominator numeric;residual bigint;damage integer;won boolean;
BEGIN
 SELECT * INTO s FROM clan_akimichi_private.cellular_sources_v1 WHERE declaration_id=p_defense;
 IF NOT FOUND THEN RETURN NULL;END IF;
 IF NOT clan_akimichi_private.cellular_source_valid_v1(p_defense) OR s.calorie_receipt IS NULL
 THEN RAISE EXCEPTION 'AKIMICHI_CELLULAR_SOURCE_NOT_PAID';END IF;
 pa:=(s.profile#>>'{attack_power_source,power}')::numeric;pd:=(s.profile->>'power')::numeric;
 IF pa IS NULL OR pd IS NULL OR pa<1 OR pd<1 OR p_final_margin IS NULL THEN RAISE EXCEPTION 'AKIMICHI_CELLULAR_POWER_INVALID';END IF;
 won:=p_final_margin<0;
 raw_damage:=greatest(1,p_base+(p_native->>'off')::integer/4+CASE WHEN won THEN 0 ELSE coalesce((p_native->>'bonus_margine')::integer,0) END);
 numerator:=raw_damage::numeric*CASE WHEN won THEN pa-least(pd,pa) ELSE 2*pa-least(pd,pa) END;
 denominator:=CASE WHEN won THEN 4*pa ELSE 2*pa END;
 residual:=div(numerator+denominator-1,denominator)::bigint;
 damage:=CASE WHEN residual=0 THEN 0 ELSE least(65,greatest(1,residual-coalesce((p_native->>'riduzione')::integer,0))) END;
 RETURN jsonb_build_object('version','akimichi-cellular-result/1','defense_declaration_id',s.declaration_id,
  'attack_declaration_id',s.attack_declaration_id,'defense_won',won,'power_defense',pd,'power_attack',pa,
  'power_base',25,'power_contribution',s.profile->'power_contribution','damage_before_reduction',raw_damage,
  'residual_before_protections',residual,'native_resistance_and_tenuta_reduction',p_native->'riduzione',
  'damage_after',damage,'replaces_grazing',true,'calorie_cost',10,'chakra_cost',0,'source_sha256',s.source_sha256);
END $fn$;
CREATE OR REPLACE FUNCTION clan_akimichi_private.common_admit_calories_v1(p_declaration uuid)
RETURNS void LANGUAGE plpgsql SECURITY DEFINER SET search_path='' AS $fn$
DECLARE d public.combat_v2_declarations%ROWTYPE;a public.combat_v2_actors%ROWTYPE;s jsonb;balance integer;v_scope uuid;v_owner uuid;
BEGIN
 SELECT * INTO STRICT d FROM public.combat_v2_declarations WHERE id=p_declaration;
 IF d.sanitized_intent->>'ability_source' IS DISTINCT FROM 'clan' THEN RETURN;END IF;
 IF d.sanitized_intent->>'ability_id'='214af896-15f8-43e6-858b-614d2851dd3b' THEN
  IF clan_akimichi_private.common_scope_v1(d.actor_id,'f5f26cb5-9b6f-44b3-94bc-c329a0a88b93') IS NULL
   AND clan_akimichi_private.common_scope_v1(d.actor_id,'687b058a-807d-4cf7-8bcf-21147931b0f6') IS NULL THEN RETURN;END IF;
  s:=clan_akimichi_private.scope_for_actor(d.actor_id,'214af896-15f8-43e6-858b-614d2851dd3b');
 ELSIF d.sanitized_intent->>'ability_id'='687b058a-807d-4cf7-8bcf-21147931b0f6' THEN
  IF combat_panel_private.cure_turn_used_v1(d.round_id,d.actor_id) THEN
   RAISE EXCEPTION 'cure_turn_has_no_technique_reaction' USING ERRCODE='42501';END IF;
  s:=clan_akimichi_private.common_scope_v1(d.actor_id,'687b058a-807d-4cf7-8bcf-21147931b0f6');
 ELSE RETURN;END IF;
 IF current_setting('transaction_isolation') IS DISTINCT FROM 'read committed' THEN
  RAISE EXCEPTION 'AKIMICHI_COMMON_COMMITMENT_ISOLATION_INVALID' USING ERRCODE='55000';END IF;
 SELECT * INTO STRICT a FROM public.combat_v2_actors WHERE id=d.actor_id FOR UPDATE;
 IF s IS NULL OR(s->>'round')::uuid IS DISTINCT FROM d.round_id OR d.controller_version_snapshot IS DISTINCT FROM a.controller_version
 THEN RAISE EXCEPTION 'AKIMICHI_COMMON_COMMITMENT_SCOPE_INVALID';END IF;
 -- Same character lock order as the native resolver, before the calorie row.
 PERFORM 1 FROM public.characters pg WHERE pg.id IN(SELECT participant.character_id FROM public.combat_v2_actors participant
  WHERE participant.session_id=a.session_id AND participant.character_id IS NOT NULL) ORDER BY pg.id FOR UPDATE;
 v_owner:=(s->>'owner')::uuid;v_scope:=(s->>'scope')::uuid;
 PERFORM 1 FROM clan_akimichi_private.calorie_reserves c WHERE c.owner_id=v_owner AND c.scope_id=v_scope
  AND c.simulated=(s->>'simulated')::boolean FOR UPDATE;
 IF NOT FOUND THEN RAISE EXCEPTION 'AKIMICHI_COMMON_CALORIE_RESERVE_MISSING';END IF;
 balance:=clan_akimichi_private.common_calorie_balance_v1(v_owner,v_scope,d.id);
 IF balance IS NULL OR balance<10 THEN RAISE EXCEPTION 'AKIMICHI_COMMON_CALORIE_COMMITMENT_INSUFFICIENT' USING ERRCODE='55000';END IF;
END $fn$;
CREATE OR REPLACE FUNCTION clan_akimichi_private.common_preflight_calories_v1(p_round uuid)
RETURNS void LANGUAGE plpgsql SECURITY DEFINER SET search_path='' AS $fn$
DECLARE q record;balance integer;
BEGIN
 FOR q IN SELECT DISTINCT t.owner_id,t.scope_id FROM(
  SELECT s.owner_id,s.scope_id FROM clan_akimichi_private.cellular_sources_v1 s WHERE s.round_id=p_round
  UNION ALL
  SELECT s.owner_id,s.scope_id FROM clan_akimichi_private.partial_sources s WHERE s.round_id=p_round
  AND(clan_akimichi_private.common_scope_v1(s.actor_id,'f5f26cb5-9b6f-44b3-94bc-c329a0a88b93') IS NOT NULL
   OR clan_akimichi_private.common_scope_v1(s.actor_id,'687b058a-807d-4cf7-8bcf-21147931b0f6') IS NOT NULL)
 )t ORDER BY t.owner_id,t.scope_id LOOP
  PERFORM 1 FROM clan_akimichi_private.calorie_reserves c WHERE c.owner_id=q.owner_id AND c.scope_id=q.scope_id FOR UPDATE;
  balance:=clan_akimichi_private.common_calorie_balance_v1(q.owner_id,q.scope_id,NULL);
  IF balance IS NULL OR balance<0 THEN RAISE EXCEPTION 'AKIMICHI_COMMON_CALORIE_COMMITMENT_INSUFFICIENT' USING ERRCODE='55000';END IF;
 END LOOP;
END $fn$;
-- Same intrinsic map authority as the native producer, evaluated for the
-- defender's actor/controller. No caller POV, impersonation or new view grant.
CREATE OR REPLACE FUNCTION clan_akimichi_private.super_direct_visible_v1(p_declaration uuid,p_defender uuid)
RETURNS boolean LANGUAGE plpgsql STABLE SECURITY DEFINER SET search_path='' AS $fn$
DECLARE d public.combat_v2_declarations%ROWTYPE;r public.combat_v2_rounds%ROWTYPE;s public.combat_v2_sessions%ROWTYPE;
 defender public.combat_v2_actors%ROWTYPE;caster public.combat_v2_actors%ROWTYPE;origin public.combat_v2_actors%ROWTYPE;
 arena combat_spatial.arena_instances%ROWTYPE;body combat_spatial.actor_states%ROWTYPE;ctx combat_consumer_private.activities%ROWTYPE;
 principal uuid;origin_id uuid;origin_valid boolean;hidden jsonb;visible_map jsonb;principals uuid[];
BEGIN
 SELECT * INTO d FROM public.combat_v2_declarations WHERE id=p_declaration AND kind='attacco';
 IF NOT FOUND THEN RETURN false;END IF;
 SELECT * INTO STRICT r FROM public.combat_v2_rounds WHERE id=d.round_id;
 SELECT * INTO s FROM public.combat_v2_sessions WHERE id=r.session_id AND closed_at IS NULL AND state='in_corso';
 IF NOT FOUND THEN RETURN false;END IF;
 SELECT * INTO defender FROM public.combat_v2_actors WHERE id=p_defender AND session_id=s.id AND state='attivo' AND actor_kind='pg' AND companion_id IS NULL;
 SELECT * INTO caster FROM public.combat_v2_actors WHERE id=d.actor_id AND session_id=s.id AND state='attivo';
 IF defender.id IS NULL OR caster.id IS NULL THEN RETURN false;END IF;
 principal:=exam_regia_private.actor_principal(defender.id,defender.controller_user);
 IF principal IS NULL THEN RETURN false;END IF;
 SELECT m.companion_actor_id,m.profile_sha256=public.combat_v2_sha256(m.profile) INTO origin_id,origin_valid
 FROM clan_marionettisti_private.offensive_profiles m WHERE m.declaration_id=d.id;
 IF FOUND THEN IF origin_valid IS DISTINCT FROM true THEN RETURN false;END IF;
 ELSE origin_id:=caster.id;END IF;
 SELECT * INTO origin FROM public.combat_v2_actors WHERE id=origin_id AND session_id=s.id AND state='attivo';
 IF NOT FOUND OR(SELECT count(*) FROM combat_spatial.arena_instances WHERE encounter_id=s.id AND state='open')<>1 THEN RETURN false;END IF;
 SELECT * INTO arena FROM combat_spatial.arena_instances WHERE encounter_id=s.id AND state='open';
 SELECT * INTO body FROM combat_spatial.actor_states WHERE instance_id=arena.instance_id AND actor_id=origin.id AND state='active';
 IF NOT FOUND OR NOT EXISTS(SELECT 1 FROM combat_spatial.actor_states WHERE instance_id=arena.instance_id AND actor_id=defender.id AND state='active')
 OR combat_spatial.template_errors(arena.template_key,arena.template_version) IS DISTINCT FROM '[]'::jsonb THEN RETURN false;END IF;

 IF s.source_kind='ordinary' AND s.master_session_id IS NULL AND arena.context_source='ordinary' THEN
  SELECT * INTO ctx FROM combat_consumer_private.activities WHERE session_id=s.id AND location_id=s.location_id
   AND user_test_context_id IS NULL AND phase IN('action','defense','resolved');
  IF NOT FOUND OR s.user_test_context_id IS NOT NULL
   OR(SELECT session_id FROM combat_consumer_private.activities WHERE location_id=s.location_id AND user_test_context_id IS NULL AND phase<>'closed'
     ORDER BY created_at DESC LIMIT 1) IS DISTINCT FROM s.id
   OR(SELECT count(*) FROM combat_consumer_private.members WHERE session_id=s.id)<>2
   OR NOT EXISTS(SELECT 1 FROM combat_consumer_private.members m JOIN public.characters pg ON pg.id=m.character_id AND pg.user_id=defender.controller_user
    WHERE m.session_id=s.id AND m.actor_id=defender.id AND defender.character_id=pg.id AND principal=defender.controller_user)
   OR NOT EXISTS(SELECT 1 FROM combat_consumer_private.members m JOIN public.characters pg ON pg.id=m.character_id AND pg.user_id=caster.controller_user
    WHERE m.session_id=s.id AND m.actor_id=caster.id AND caster.character_id=pg.id AND caster.actor_kind='pg' AND caster.companion_id IS NULL)
   OR EXISTS(SELECT 1 FROM combat_consumer_private.members m LEFT JOIN public.combat_v2_actors a ON a.id=m.actor_id AND a.session_id=m.session_id
    WHERE m.session_id=s.id AND(a.id IS NULL OR a.actor_kind<>'pg' OR a.companion_id IS NOT NULL OR a.character_id IS DISTINCT FROM m.character_id))
   OR NOT mission_creation_owner.map_binding_ordinary_template_allowed(arena.template_key,arena.template_version,s.id)
   OR EXISTS(SELECT 1 FROM public.combat_sessions legacy WHERE legacy.location_id=s.location_id AND legacy.state='aperto')
  THEN RETURN false;END IF;
  SELECT array_agg(a.controller_user ORDER BY a.id) INTO principals FROM combat_consumer_private.members m
   JOIN public.combat_v2_actors a ON a.id=m.actor_id AND a.session_id=m.session_id WHERE m.session_id=s.id;
  IF NOT EXISTS(SELECT 1 FROM public.locations l WHERE l.id=s.location_id AND l.is_active AND(
    (l.is_test AND ctx.policy_id='staff_test_no_persistent_resources_v1' AND combat_consumer_private.staff_test_allowed(l.id,principals,false)
     AND combat_effects_private.staff_session_allowed(s.id) AND combat_panel_private.uses_simulated_pools(s.id) AND NOT public.combat_v2_values_written(s.id))
    OR(NOT l.is_test AND NOT l.is_exam_room AND ctx.policy_id='free_duel_nonlethal_real_resources_v1'
     AND EXISTS(SELECT 1 FROM combat_consumer_private.runtime_config WHERE singleton AND enabled)))) THEN RETURN false;END IF;
  -- Native ordinary maps expose member PG bodies. A companion origin still
  -- needs its own native ownership/grant; membership of its controller is not a grant.
  IF origin.companion_id IS NULL AND origin.actor_kind='pg' THEN
   IF NOT EXISTS(SELECT 1 FROM combat_consumer_private.members WHERE session_id=s.id AND actor_id=origin.id) THEN RETURN false;END IF;
  ELSIF origin.controller_user IS DISTINCT FROM principal AND NOT EXISTS(SELECT 1 FROM combat_spatial.viewer_grants
   WHERE instance_id=arena.instance_id AND subject_actor_id=origin.id AND viewer_principal_id=principal AND can_view_map) THEN RETURN false;
  END IF;
 ELSIF s.source_kind='master' AND arena.context_source='panel_master' THEN
  -- Same active-body/grant selection as combat_spatial.map_projection. Do not
  -- evaluate unrelated object/anchor projections under the resolver's caller.
  IF NOT EXISTS(SELECT 1 FROM combat_spatial.viewer_grants WHERE instance_id=arena.instance_id AND subject_actor_id=origin.id
   AND viewer_principal_id=principal AND can_view_map) THEN RETURN false;END IF;
 ELSE RETURN false;END IF;

 -- This is the existing immutable mask projection, fed only verified native
 -- bodies and the defender's controller. An opaque original is not visible.
 SELECT jsonb_build_object('formations',coalesce(jsonb_agg(jsonb_build_object('actor_id',f.actor_id,'original_index',NULL)),'[]')) INTO hidden
 FROM combat_panel_private.multiplication_formations f JOIN public.combat_v2_actors a ON a.id=f.actor_id AND a.session_id=f.session_id
 WHERE f.session_id=s.id AND f.instance_id=arena.instance_id AND f.state='active'
 AND exam_regia_private.actor_principal(a.id,a.controller_user) IS DISTINCT FROM principal;
 visible_map:=combat_panel_private.multiplication_mask_map(jsonb_build_object('pov',jsonb_build_object('actor_id',defender.id),
  'actors',jsonb_build_array(jsonb_build_object('actor_id',origin.id))),hidden);
 RETURN EXISTS(SELECT 1 FROM jsonb_array_elements(coalesce(visible_map->'actors','[]')) a WHERE a->>'actor_id'=origin.id::text);
END $fn$;
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
   IF a.mechanics_snapshot->>'forza' !~ '^[0-9]+$' OR a.mechanics_snapshot->>'taijutsu' !~ '^[0-9]+$'
    OR a.mechanics_snapshot->>'forza' IS NULL OR a.mechanics_snapshot->>'taijutsu' IS NULL THEN RAISE EXCEPTION 'rotation_hand_statistics_invalid'; END IF;
   pool:=(a.mechanics_snapshot->>'forza')::bigint+(a.mechanics_snapshot->>'taijutsu')::bigint;
   native_hash:=public.combat_v2_sha256(jsonb_build_object('forza',a.mechanics_snapshot->'forza','taijutsu',a.mechanics_snapshot->'taijutsu'));
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
CREATE OR REPLACE FUNCTION clan_akimichi_private.common_panel_offers_v1(p_context uuid,p_expected bigint,p_view jsonb)
RETURNS void LANGUAGE plpgsql SECURITY DEFINER SET search_path='' AS $fn$
DECLARE c combat_panel_private.contexts%ROWTYPE;a public.combat_v2_actors%ROWTYPE;f clan_akimichi_private.forms%ROWTYPE;
 oid uuid;gid uuid;x record;phase text;form text;label text;calories integer;scope jsonb;can_change boolean;
BEGIN
 c:=combat_panel_private.owned_context(p_context,p_expected);
 IF c.round_id IS NULL OR c.command_actor_id IS NULL OR c.activity_kind NOT IN('ordinary_v2','master_v2') THEN RETURN;END IF;
 SELECT * INTO a FROM public.combat_v2_actors WHERE id=c.command_actor_id AND session_id=c.activity_id
 AND controller_user=auth.uid() AND actor_kind='pg' AND companion_id IS NULL AND state='attivo';
 IF NOT FOUND THEN RETURN;END IF;
 phase:=p_view#>>'{context,phase}';
 IF phase='action' AND combat_panel_private.cure_turn_clear_v1(c.round_id,a.id)
  AND coalesce((combat_panel_private.owner_turn_context(a.id)->>'can_move')::boolean,false)
  AND (combat_panel_private.movement_budget(a.id,c.round_id)->>'spent_m')::numeric=0 THEN
  IF public.is_staff() AND clan_akimichi_private.common_staff_scope_v1(a.id)
   AND NOT EXISTS(SELECT 1 FROM clan_akimichi_private.staff_profiles WHERE actor_id=a.id)
   AND NOT EXISTS(SELECT 1 FROM clan_akimichi_private.common_staff_profiles_v1 WHERE actor_id=a.id)
   AND NOT EXISTS(SELECT 1 FROM combat_panel_private.offers WHERE context_id=c.id AND context_version=c.context_version AND state='offered'
     AND source_payload->>'dispatch'='akimichi_common_profile') THEN
    PERFORM combat_panel_private.create_offer(c.id,c.context_version,'control','control','Prepara prova: Super Espansione e Difesa Cellulare',false,
     jsonb_build_object('adapter',c.activity_kind,'dispatch','akimichi_common_profile','contract','akimichi-common/1'));
  END IF;
  scope:=clan_akimichi_private.common_scope_v1(a.id,'f5f26cb5-9b6f-44b3-94bc-c329a0a88b93');
  IF scope IS NOT NULL THEN
   calories:=clan_akimichi_private.common_calorie_balance_v1((scope->>'owner')::uuid,(scope->>'scope')::uuid,NULL,a.id);
   SELECT * INTO f FROM clan_akimichi_private.forms WHERE actor_id=a.id AND session_id=a.session_id AND active;
   can_change:=f.activation_turn IS DISTINCT FROM(scope->>'turn')::uuid
    AND NOT EXISTS(SELECT 1 FROM clan_akimichi_private.common_form_commands_v1 q WHERE q.actor_id=a.id AND q.session_id=a.session_id AND q.result->>'turn'=scope->>'turn')
    AND NOT EXISTS(SELECT 1 FROM clan_akimichi_private.form_commands q WHERE q.actor_id=a.id AND q.session_id=a.session_id AND q.result->>'turn'=scope->>'turn');
   FOR form,label IN SELECT * FROM(VALUES('super','Super Espansione · 15 calorie'),('base','Passa a Espansione · 5 calorie'),('off','Disattiva espansione · nessun costo')) q(v,l) LOOP
    IF (form='super' AND can_change AND(f.actor_id IS NULL OR f.form_kind<>'super') AND calories>=15)
      OR(form='base' AND can_change AND(f.actor_id IS NULL OR f.form_kind='super') AND calories>=5)
      OR(form='off' AND f.actor_id IS NOT NULL) THEN
     IF NOT EXISTS(SELECT 1 FROM combat_panel_private.offers WHERE context_id=c.id AND context_version=c.context_version AND state='offered'
      AND source_payload->>'dispatch'='akimichi_common_form' AND source_payload->>'form'=form) THEN
      PERFORM combat_panel_private.create_offer(c.id,c.context_version,'control','control',label,false,
       jsonb_build_object('adapter',c.activity_kind,'dispatch','akimichi_common_form','contract','akimichi-common/1','form',form));
     END IF;
    END IF;
   END LOOP;
  END IF;
 END IF;
 -- Native one-reaction rules remain authoritative, including immobilized bodies.
 IF phase<>'defense' OR combat_panel_private.cure_turn_used_v1(c.round_id,a.id) OR clan_akimichi_private.cellular_meta_v1(a.id) IS NULL
 OR EXISTS(SELECT 1 FROM public.combat_v2_declarations d WHERE d.round_id=c.round_id AND d.actor_id=a.id AND d.kind IN('difesa','nessuna'))
 OR EXISTS(SELECT 1 FROM combat_panel_private.offers WHERE context_id=c.id AND context_version=c.context_version AND state='offered'
   AND source_payload->>'dispatch'='akimichi_cellular') THEN RETURN;END IF;
 FOR x IN SELECT d.id FROM public.combat_v2_declarations d WHERE d.round_id=c.round_id
  AND clan_akimichi_private.cellular_attack_eligible_v1(a.id,d.id) ORDER BY d.created_at,d.id LOOP
  IF oid IS NULL THEN
   oid:=combat_panel_private.create_offer(c.id,c.context_version,'defense','defend','Espansione Difensiva Cellulare · 10 calorie',true,
    jsonb_build_object('adapter',c.activity_kind,'dispatch','akimichi_cellular','contract','akimichi-common/1'));
   INSERT INTO combat_panel_private.choice_groups(offer_id,label,selection_mode,purpose,min_selected,max_selected,ordinal)
   VALUES(oid,'Attacco da assorbire','single','target',1,1,0) RETURNING id INTO gid;
  END IF;
  INSERT INTO combat_panel_private.choice_options(offer_id,group_id,label,source_payload,ordinal)
  VALUES(oid,gid,'Assorbi l’attacco fisico',jsonb_build_object('attack_id',x.id),0);
 END LOOP;
END $fn$;
CREATE OR REPLACE FUNCTION clan_akimichi_private.common_panel_commit_v1(p_command jsonb)
 RETURNS jsonb
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO ''
AS $function$
DECLARE p jsonb;uid uuid:=auth.uid();key uuid;fp text;eid uuid:=gen_random_uuid();
 prior combat_panel_private.request_receipts%ROWTYPE;o combat_panel_private.offers%ROWTYPE;
 c combat_panel_private.contexts%ROWTYPE;a public.combat_v2_actors%ROWTYPE;
 activity combat_consumer_private.activities%ROWTYPE;report public.combat_v2_round_reports%ROWTYPE;
 env jsonb;resolved jsonb;selected uuid[];payload jsonb;intent jsonb;result jsonb;receipt jsonb;
 target_id uuid;declaration uuid;resolve_key uuid;label text;target_label text;display_event jsonb;
 profile boolean;ability jsonb;proof text;dispatch text;attack_id uuid;form text;
BEGIN
 IF uid IS NULL THEN RAISE EXCEPTION 'panel_authentication_required' USING ERRCODE='28000';END IF;
 p:=combat_panel_private.validate_command(p_command);key:=(p->>'request_key')::uuid;fp:=public.combat_v2_sha256(p);
 PERFORM pg_advisory_xact_lock(hashtextextended('panel-request:'||uid::text||':'||key::text,731));
 SELECT * INTO prior FROM combat_panel_private.request_receipts WHERE principal_user=uid AND request_key=key;
 IF FOUND THEN
  IF prior.command_fingerprint<>fp THEN RAISE EXCEPTION 'panel_request_key_conflict' USING ERRCODE='22023';END IF;
  RETURN jsonb_set(prior.viewer_envelope,'{receipt,replayed}','true',false);
 END IF;
 SELECT * INTO o FROM combat_panel_private.offers WHERE id=(p->>'offer_id')::uuid AND principal_user=uid;
 dispatch:=o.source_payload->>'dispatch';profile:=dispatch<>'akimichi_cellular';
 IF o.id IS NULL OR dispatch NOT IN('akimichi_common_profile','akimichi_common_form','akimichi_cellular')
 OR o.source_payload->>'contract' IS DISTINCT FROM 'akimichi-common/1'
 OR o.source_payload->>'adapter' NOT IN('ordinary_v2','master_v2')
 OR(profile AND(o.kind<>'control' OR o.operation<>'control'))
 OR(NOT profile AND(o.kind<>'defense' OR o.operation<>'defend')) THEN
  RAISE EXCEPTION 'panel_offer_not_available' USING ERRCODE='42501';END IF;
 SELECT * INTO STRICT c FROM combat_panel_private.contexts WHERE id=o.context_id AND principal_user=uid;
 IF c.round_id IS NULL OR c.activity_kind IS DISTINCT FROM o.source_payload->>'adapter'
 OR c.location_id IS DISTINCT FROM(p->>'location_id')::uuid OR c.activity_id IS DISTINCT FROM(p->>'activity_id')::uuid THEN
  RAISE EXCEPTION 'panel_activity_scope_invalid' USING ERRCODE='22023';END IF;
 PERFORM public.combat_v2_lock_round(c.round_id);
 IF c.activity_kind='ordinary_v2' THEN env:=combat_panel_private.ordinary_projection(c.location_id,c.command_actor_id);
 ELSE env:=combat_panel_private.master_projection(c.location_id,c.command_actor_id);END IF;
 IF env->>'status' IS DISTINCT FROM 'ready' THEN RAISE EXCEPTION 'panel_source_not_ready' USING ERRCODE='40001';END IF;
 c:=combat_panel_private.owned_context(c.id,(p->>'context_version')::bigint);
 SELECT * INTO STRICT o FROM combat_panel_private.offers WHERE id=o.id FOR UPDATE;
 IF o.state<>'offered' OR o.context_version<>c.context_version OR o.source_fingerprint IS DISTINCT FROM c.source_fingerprint
 OR o.scene_version IS DISTINCT FROM c.scene_version OR o.actor_id IS DISTINCT FROM c.command_actor_id THEN
  RAISE EXCEPTION 'panel_offer_not_available' USING ERRCODE='40001';END IF;
 SELECT * INTO STRICT a FROM public.combat_v2_actors WHERE id=o.actor_id AND session_id=c.activity_id
 AND controller_user=uid AND actor_kind='pg' AND companion_id IS NULL AND state='attivo' FOR UPDATE;
 IF dispatch='akimichi_common_profile' AND(NOT public.is_staff() OR NOT clan_akimichi_private.common_staff_scope_v1(a.id)) THEN
  RAISE EXCEPTION 'AKIMICHI_COMMON_STAFF_SCOPE_REQUIRED' USING ERRCODE='42501';END IF;
 SELECT coalesce(array_agg(value::uuid),'{}') INTO selected FROM jsonb_array_elements_text(p->'selected_option_ids');
 resolved:=combat_panel_private.resolve_selections(o.id,selected,p->'inputs');
 IF resolved->'inputs' IS DISTINCT FROM '{}'::jsonb THEN RAISE EXCEPTION 'panel_input_not_offered' USING ERRCODE='22023';END IF;
 IF profile THEN
  IF o.requires_role OR length(btrim(p->>'narrative_text'))<>0 OR cardinality(selected)<>0 THEN
   RAISE EXCEPTION 'AKIMICHI_COMMON_CONTROL_INVALID' USING ERRCODE='22023';END IF;
  IF dispatch='akimichi_common_profile' THEN
   result:=clan_akimichi_private.common_prepare_staff_v1(a.id,c.id,key);
  ELSE
   form:=o.source_payload->>'form';
   result:=clan_akimichi_private.common_set_form_v1(a.id,key,form);
  END IF;
  IF c.activity_kind='ordinary_v2' THEN
   UPDATE combat_consumer_private.activities SET context_version=context_version+1,last_action_at=clock_timestamp() WHERE session_id=c.activity_id;
  END IF;
  UPDATE combat_panel_private.contexts SET context_version=context_version+1,updated_at=clock_timestamp() WHERE id=c.id;
 ELSE
  IF NOT o.requires_role OR length(btrim(p->>'narrative_text'))=0 THEN
   RAISE EXCEPTION 'panel_role_required' USING ERRCODE='22023';END IF;
  FOR payload IN SELECT choice->'payload' FROM jsonb_array_elements(resolved->'groups') AS groups(g)
   CROSS JOIN LATERAL jsonb_array_elements(g->'options') AS choices(choice) LOOP
   IF payload ? 'attack_id' AND payload-ARRAY['attack_id']='{}'::jsonb AND attack_id IS NULL THEN
    attack_id:=(payload->>'attack_id')::uuid;
   ELSE RAISE EXCEPTION 'AKIMICHI_CELLULAR_SELECTION_INVALID' USING ERRCODE='22023';END IF;
  END LOOP;
  IF attack_id IS NULL OR NOT clan_akimichi_private.cellular_attack_eligible_v1(a.id,attack_id) THEN
   RAISE EXCEPTION 'AKIMICHI_CELLULAR_ATTACK_REQUIRED';END IF;
  intent:=jsonb_build_object('reaction','tecnica','ability_source','clan','ability_id','687b058a-807d-4cf7-8bcf-21147931b0f6','target_actor',a.id);
  IF c.activity_kind='ordinary_v2' THEN
   SELECT * INTO STRICT activity FROM combat_consumer_private.activities WHERE session_id=c.activity_id AND exchange_id=c.round_id FOR UPDATE;
   IF activity.phase<>'defense' THEN RAISE EXCEPTION 'AKIMICHI_CELLULAR_PHASE_STALE' USING ERRCODE='40001';END IF;
   INSERT INTO combat_consumer_private.dispatch_authorizations VALUES(key,c.round_id,a.character_id,txid_current(),'defend','prepared');
  END IF;
  result:=public.combat_v2_defense_declare(c.round_id,attack_id,a.id,intent,p->>'narrative_text',key);
  declaration:=(result#>>'{data,defense_id}')::uuid;
  IF declaration IS NULL OR NOT clan_akimichi_private.cellular_source_valid_v1(declaration) THEN
   RAISE EXCEPTION 'AKIMICHI_CELLULAR_BINDING_MISSING';END IF;
  target_id:=a.id;
  IF c.activity_kind='ordinary_v2' THEN
   UPDATE combat_consumer_private.dispatch_authorizations SET state='consumed' WHERE request_key=key AND round_id=c.round_id AND operation='defend';
   IF combat_v2_multitarget_internal.round_complete(c.round_id) THEN
    resolve_key:=gen_random_uuid();
    INSERT INTO combat_consumer_private.dispatch_authorizations VALUES(resolve_key,c.round_id,a.character_id,txid_current(),'resolve','prepared');
    PERFORM public.combat_v2_round_resolve(c.round_id,resolve_key);
    UPDATE combat_consumer_private.dispatch_authorizations SET state='consumed' WHERE request_key=resolve_key AND round_id=c.round_id AND operation='resolve';
    SELECT * INTO STRICT report FROM public.combat_v2_round_reports WHERE round_id=c.round_id;
    UPDATE combat_consumer_private.activities SET phase='resolved' WHERE session_id=c.activity_id;
   END IF;
   PERFORM combat_consumer_private.record_message(declaration,public.post_message(c.location_id,p->>'narrative_text',null,null,null));
   UPDATE combat_consumer_private.activities SET context_version=context_version+1,last_action_at=clock_timestamp() WHERE session_id=c.activity_id;
  ELSE
   PERFORM combat_panel_private.publish_master_declaration(declaration,p->>'narrative_text');
   SELECT * INTO report FROM public.combat_v2_round_reports WHERE round_id=c.round_id;
  END IF;
 END IF;
 SELECT value->>'display_name' INTO label FROM jsonb_array_elements(env->'actors') WHERE value->>'actor_id'=a.id::text;
 SELECT value->>'display_name' INTO target_label FROM jsonb_array_elements(env->'actors') WHERE value->>'actor_id'=target_id::text;
 display_event:=jsonb_build_object('event_id',eid,'event_kind',CASE WHEN profile THEN 'control_changed' ELSE 'defense_resolved' END,
 'actor_id',a.id,'display_name',label,'label_version',c.context_version,'target_actor_id',target_id,
 'target_display_name',target_label,'target_label_version',CASE WHEN target_id IS NOT NULL THEN c.context_version END,
 'summary',CASE WHEN dispatch='akimichi_common_profile' THEN 'Prova Akimichi preparata' WHEN profile THEN 'Forma corporea aggiornata' ELSE 'Difesa Cellulare registrata' END);
 IF c.activity_kind='ordinary_v2' THEN env:=combat_panel_private.ordinary_projection(c.location_id,a.id);
 ELSE env:=combat_panel_private.master_projection(c.location_id,a.id);END IF;
 receipt:=jsonb_build_object('receipt_id',eid,'request_key',key,'operation',o.operation,'replayed',false,
 'activity_id',c.activity_id,'round_id',c.round_id,'context_version_before',o.context_version,
 'context_version_after',env#>'{context,version}','declaration_id',declaration,'report_id',report.id,
 'values_written',coalesce(report.values_written,false),'display_events',jsonb_build_array(display_event));
 env:=jsonb_set(env,'{receipt}',receipt);
 UPDATE combat_panel_private.offers SET state='consumed',consumed_request_key=key WHERE id=o.id;
 INSERT INTO combat_panel_private.request_receipts(principal_user,request_key,command_fingerprint,offer_id,event_id,viewer_envelope)
 VALUES(uid,key,fp,o.id,eid,env);
 RETURN env;
END $function$;
CREATE OR REPLACE FUNCTION clan_akimichi_private.common_result_label_v1(p jsonb)
RETURNS text LANGUAGE plpgsql IMMUTABLE SET search_path='' AS $fn$
DECLARE c jsonb;
BEGIN
 c:=coalesce(p->'akimichi_cellular',p#>'{calculation,akimichi_cellular}');
 IF c->>'version'='akimichi-cellular-result/1' AND c->>'source_sha256' ~ '^[0-9a-f]{64}$'
 AND c->'calorie_cost'='10'::jsonb AND c->'chakra_cost'='0'::jsonb AND(c->>'damage_after') ~ '^[0-9]+$' THEN
  RETURN ' · Difesa Cellulare: '||CASE WHEN(c->>'damage_after')::integer=0 THEN 'assorbimento completo' ELSE 'assorbimento parziale' END||' · 10 calorie';
 END IF;
 IF p#>'{calculation,akimichi_form,super_form}'='true'::jsonb THEN
  RETURN ' · profilo corporeo di Super Espansione applicato';
 END IF;
 RETURN '';
END $fn$;
CREATE FUNCTION clan_sabaku_private.armor_absorb_packet_v1(p_actor uuid,p_round uuid,p_event uuid,p_target uuid,p_damage integer)
 RETURNS jsonb
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO ''
AS $function$
DECLARE t public.combat_v2_attack_targets%ROWTYPE; s clan_sabaku_private.armor_states%ROWTYPE; r clan_sabaku_private.reserves%ROWTYPE;
 e clan_sabaku_private.armor_events%ROWTYPE; eid uuid:=gen_random_uuid(); result jsonb; fp text; catalog jsonb;
BEGIN
 IF p_damage IS NULL OR p_damage<0 THEN RAISE EXCEPTION 'armor_damage_invalid'; END IF;
 IF p_actor IS NULL OR p_round IS NULL OR p_event IS NULL OR NOT EXISTS(SELECT 1 FROM public.combat_v2_actors a JOIN public.combat_v2_rounds rr ON rr.session_id=a.session_id WHERE a.id=p_actor AND rr.id=p_round) THEN RAISE EXCEPTION 'armor_packet_scope_invalid';END IF;
 t.target_actor_id:=p_actor;t.round_id:=p_round;t.id:=p_target;
 SELECT * INTO s FROM clan_sabaku_private.armor_states WHERE actor_id=t.target_actor_id FOR UPDATE;
 IF s.id IS NULL THEN RETURN jsonb_build_object('damage_after',p_damage); END IF;
 fp:=public.combat_v2_sha256(jsonb_build_object('target',p_event,'damage_before',p_damage));
 SELECT * INTO e FROM clan_sabaku_private.armor_events WHERE armor_id=s.id AND event_kind='hit' AND event_key=p_event;
 IF FOUND THEN IF e.fingerprint<>fp THEN RAISE EXCEPTION 'armor_damage_conflict' USING ERRCODE='40001'; END IF; RETURN e.result; END IF;
 IF NOT s.active OR p_damage=0 THEN RETURN jsonb_build_object('damage_after',p_damage); END IF;
 IF NOT clan_sabaku_private.armor_eligible(t.target_actor_id) THEN PERFORM clan_sabaku_private.armor_stop(t.target_actor_id,'release_disabled',p_event); RETURN jsonb_build_object('damage_after',p_damage); END IF;
 SELECT * INTO STRICT r FROM clan_sabaku_private.reserves WHERE id=s.reserve_id FOR UPDATE;
 IF s.held<>2 OR r.committed_amount<2 OR r.current_amount<2 OR NOT s.enabled THEN RAISE EXCEPTION 'armor_held_sand_drift'; END IF;
 UPDATE clan_sabaku_private.reserves SET current_amount=current_amount-2,committed_amount=committed_amount-2,state_version=state_version+1 WHERE id=r.id;
 UPDATE clan_sabaku_private.armor_states SET active=false,held=0,state_version=state_version+1,off_reason='consumed' WHERE id=s.id;
 SELECT jsonb_build_object('technique_id',id,'name',name,'description',description,'effect',danno_effetto) INTO STRICT catalog FROM public.clan_techniques WHERE id='bb9bd1d4-e0b2-4e20-9bd4-48d14fe8344d';
 result:=jsonb_build_object('version','sabaku-armor/2','armor_id',s.id,'actor_id',t.target_actor_id,'attack_target_id',t.id,
  'damage_before',p_damage,'protection',s.protection,'absorbed',least(p_damage,s.protection),'damage_after',greatest(0,p_damage-s.protection),
  'sand_consumed',2,'sand_recommitted',0,'enabled_after',true,'active_after',false,'restore_pending',true,'catalog',catalog);
 INSERT INTO clan_sabaku_private.armor_events(id,armor_id,event_kind,event_key,fingerprint,round_id,attack_target_id,result)
 VALUES(eid,s.id,'hit',p_event,fp,t.round_id,t.id,result);
 INSERT INTO clan_sabaku_private.sand_ledger(armor_event_id,event_kind,amount) VALUES(eid,'consume',2);
 RETURN result;
END $function$;
CREATE FUNCTION combat_panel_private.nara_adv_prepare_v1(p_actor uuid,p_round uuid) RETURNS void LANGUAGE plpgsql SECURITY DEFINER SET search_path='' AS $f$
DECLARE a public.combat_v2_actors%ROWTYPE;p jsonb;t jsonb;
BEGIN
 SELECT * INTO STRICT a FROM public.combat_v2_actors WHERE id=p_actor FOR UPDATE;
 IF auth.uid() IS NULL OR a.controller_user IS DISTINCT FROM auth.uid() OR NOT public.is_staff() OR NOT combat_panel_private.nara_adv_scope_v1(a.id)
 OR clan_innata_narrative_private.staff_profile_actor_v1(a.id)->>'family' IS DISTINCT FROM 'nara' OR combat_panel_private.nara_controlled_v1(a.id)
 OR combat_panel_private.cure_turn_used_v1(p_round,a.id)
 OR NOT EXISTS(SELECT 1 FROM public.combat_v2_rounds r WHERE r.id=p_round AND r.session_id=a.session_id AND r.phase='raccolta_azioni') OR EXISTS(SELECT 1 FROM public.combat_v2_declarations d JOIN public.combat_v2_rounds r ON r.id=d.round_id WHERE r.session_id=a.session_id)
 THEN RAISE EXCEPTION 'NARA_ADV_STAFF_PREP_SCOPE' USING ERRCODE='42501';END IF;
 SELECT profile INTO p FROM combat_panel_private.nara_adv_staff_v1 WHERE actor_id=a.id;
 IF FOUND THEN IF p IS DISTINCT FROM a.mechanics_snapshot->'nara_adv_profile' THEN RAISE EXCEPTION 'NARA_ADV_PROFILE_DRIFT';END IF;RETURN;END IF;
 p:=jsonb_build_object('contract','nara-strangolamento/1','actor',a.id,'session',a.session_id,'controller',a.controller_user,'controller_version',a.controller_version,'kg',55,'tier',2,'technique','0a15282f-d6b5-4ee3-ad52-7fac2525444d');
 INSERT INTO combat_panel_private.nara_adv_staff_v1 VALUES(a.id,a.session_id,a.controller_user,a.controller_version,p,public.combat_v2_sha256(p));
 UPDATE public.combat_v2_actors SET mechanics_snapshot=mechanics_snapshot||jsonb_build_object('kekkei_genkai',55,'nara_adv_profile',p) WHERE id=a.id;
END $f$;
CREATE FUNCTION combat_panel_private.nara_strangle_meta_v1(p_actor uuid) RETURNS jsonb LANGUAGE plpgsql STABLE SECURITY DEFINER SET search_path='' AS $f$
DECLARE a public.combat_v2_actors%ROWTYPE;p combat_panel_private.nara_adv_staff_v1%ROWTYPE;e combat_panel_private.immobilizations%ROWTYPE;launch jsonb;turn_fact jsonb;
BEGIN
 IF NOT combat_panel_private.nara_adv_scope_v1(p_actor) THEN RETURN NULL;END IF;
 SELECT * INTO a FROM public.combat_v2_actors WHERE id=p_actor AND state='attivo';
 SELECT * INTO p FROM combat_panel_private.nara_adv_staff_v1 WHERE actor_id=a.id AND session_id=a.session_id;
 IF p.actor_id IS NULL OR p.controller_user IS DISTINCT FROM a.controller_user OR p.controller_version IS DISTINCT FROM a.controller_version OR p.profile_sha256 IS DISTINCT FROM public.combat_v2_sha256(p.profile) OR p.profile IS DISTINCT FROM a.mechanics_snapshot->'nara_adv_profile'
 OR coalesce(combat_panel_private.nara_shadow_level_v1(a.id),0)<2 OR(a.mechanics_snapshot->>'kekkei_genkai')::integer<55 OR (a.mechanics_snapshot->>'chakra')::integer<10 OR(a.mechanics_snapshot->>'vita')::integer<=0 THEN RETURN NULL;END IF;
 turn_fact:=combat_effects_private.personal_turn(a.session_id,a.id);
 IF turn_fact->>'is_current' IS DISTINCT FROM 'true' OR turn_fact->>'phase' IS DISTINCT FROM 'action' OR turn_fact->>'useful' IS DISTINCT FROM 'true'
 OR combat_panel_private.cure_turn_used_v1((turn_fact->>'round_id')::uuid,a.id) OR combat_panel_private.nara_owner_choice_v1(a.id)->'upkeep_due'='true'::jsonb THEN RETURN NULL;END IF;
 SELECT i.* INTO e FROM combat_panel_private.immobilizations i JOIN combat_panel_private.nara_body_control_v1 n ON n.effect_id=i.id WHERE i.session_id=a.session_id AND i.source_actor_id=a.id AND i.state='active';
 IF e.id IS NULL OR EXISTS(SELECT 1 FROM combat_panel_private.nara_strangle_sources_v1 WHERE parent_id=e.id AND state IN('prepared','active')) THEN RETURN NULL;END IF;
 launch:=combat_panel_private.nara_frozen_launch_v1(e.source_declaration_id);
 IF launch IS NULL OR NOT combat_panel_private.nara_frozen_segment_current_v1(a.session_id,e.source_declaration_id,launch) OR NOT EXISTS(SELECT 1 FROM public.combat_v2_actors WHERE id=e.target_actor_id AND session_id=a.session_id AND state='attivo') THEN RETURN NULL;END IF;
 RETURN jsonb_build_object('source','clan','id','0a15282f-d6b5-4ee3-ad52-7fac2525444d','name','Strangolamento dell''Ombra','kind','fisico','usage','principale','chakra_cost',10,'damage_base',10,'nara_strangle_contract','nara-strangolamento/1','parent_id',e.id,'target_actor_id',e.target_actor_id,'parent_declaration',e.source_declaration_id,'chain_version',public.combat_v2_sha256(launch),'kg',(a.mechanics_snapshot->>'kekkei_genkai')::integer,'ninjutsu',(a.mechanics_snapshot->>'ninjutsu')::integer,'power',25+((a.mechanics_snapshot->>'kekkei_genkai')::integer+(a.mechanics_snapshot->>'ninjutsu')::integer)/10,'turn_id',turn_fact->'turn_id');
END $f$;
CREATE FUNCTION combat_panel_private.nara_strangle_action_meta_v1(p_round uuid,p_actor uuid,p_intent jsonb) RETURNS jsonb LANGUAGE plpgsql STABLE SECURITY DEFINER SET search_path='' AS $f$
DECLARE m jsonb;
BEGIN
 IF p_intent->>'ability_source' IS DISTINCT FROM 'clan' OR p_intent->>'ability_id' IS DISTINCT FROM '0a15282f-d6b5-4ee3-ad52-7fac2525444d' THEN RETURN NULL;END IF;
 m:=combat_panel_private.nara_strangle_meta_v1(p_actor);
 IF m IS NULL OR p_intent->>'kind'<>'utilita' OR p_intent-ARRAY['kind','ability_source','ability_id','target_actor']<>'{}'::jsonb OR p_intent->>'target_actor' IS DISTINCT FROM m->>'target_actor_id'
 OR (combat_effects_private.personal_turn((SELECT session_id FROM public.combat_v2_actors WHERE id=p_actor),p_actor)->>'round_id')::uuid IS DISTINCT FROM p_round THEN RAISE EXCEPTION 'NARA_STRANGLE_NOT_AVAILABLE' USING ERRCODE='42501';END IF;
 RETURN m;
END $f$;
CREATE FUNCTION combat_panel_private.nara_strangle_bind_v1(p_declaration uuid) RETURNS void LANGUAGE plpgsql SECURITY DEFINER SET search_path='' AS $f$
DECLARE d public.combat_v2_declarations%ROWTYPE;m jsonb;s uuid;
BEGIN
 SELECT * INTO STRICT d FROM public.combat_v2_declarations WHERE id=p_declaration;
 IF d.sanitized_intent#>>'{server_ability,nara_strangle_contract}' IS DISTINCT FROM 'nara-strangolamento/1' THEN RETURN;END IF;
 m:=d.sanitized_intent->'server_ability';SELECT session_id INTO s FROM public.combat_v2_rounds WHERE id=d.round_id;
 IF NOT combat_panel_private.nara_adv_scope_v1(d.actor_id) OR m->>'nara_strangle_contract' IS DISTINCT FROM 'nara-strangolamento/1' OR d.controller_version_snapshot IS DISTINCT FROM(SELECT controller_version FROM public.combat_v2_actors WHERE id=d.actor_id) OR d.cost_snapshot->'chakra' IS DISTINCT FROM '10'::jsonb OR d.kind<>'utilita' OR d.target_actor_id::text IS DISTINCT FROM m->>'target_actor_id' THEN RAISE EXCEPTION 'NARA_STRANGLE_BIND_INVALID';END IF;
 INSERT INTO combat_panel_private.nara_strangle_sources_v1(declaration_id,session_id,actor_id,target_actor_id,parent_id,profile,profile_sha256,activation_turn)VALUES(d.id,s,d.actor_id,d.target_actor_id,(m->>'parent_id')::uuid,m,public.combat_v2_sha256(m),(m->>'turn_id')::uuid);
END $f$;
CREATE FUNCTION combat_panel_private.nara_strangle_lifecycle_v1(p_session uuid) RETURNS void LANGUAGE plpgsql SECURITY DEFINER SET search_path='' AS $f$
BEGIN
 UPDATE combat_panel_private.nara_strangle_sources_v1 x SET state='ended',end_reason='parent_or_actor_ended' WHERE session_id=p_session AND state IN('prepared','active') AND NOT combat_panel_private.nara_strangle_parent_valid_v1(x.declaration_id);
END $f$;
-- The packet is paid/resolved through the original pools. No client damage or second RNG.
CREATE FUNCTION combat_panel_private.nara_strangle_packet_v1(p_declaration uuid,p_round uuid,p_turn uuid,p_kind text) RETURNS jsonb LANGUAGE plpgsql SECURITY DEFINER SET search_path='' AS $f$
DECLARE x combat_panel_private.nara_strangle_sources_v1%ROWTYPE;t public.combat_v2_actors%ROWTYPE;a public.combat_v2_actors%ROWTYPE;eid uuid;prior combat_panel_private.nara_strangle_events_v1%ROWTYPE;damage integer;red integer;tenuta integer;before_hp integer;after_hp integer;armor jsonb;facts jsonb;
BEGIN
 IF p_kind NOT IN('activation','upkeep') OR p_turn IS NULL THEN RAISE EXCEPTION 'NARA_STRANGLE_PACKET_IDENTITY';END IF;
 SELECT * INTO STRICT x FROM combat_panel_private.nara_strangle_sources_v1 WHERE declaration_id=p_declaration FOR UPDATE;
 eid:=md5('nara-strangolamento/1|'||x.declaration_id||'|'||p_kind||'|'||p_turn)::uuid;
 SELECT * INTO prior FROM combat_panel_private.nara_strangle_events_v1 WHERE event_id=eid;
 IF FOUND THEN IF prior.facts_sha256 IS DISTINCT FROM public.combat_v2_sha256(prior.facts) THEN RAISE EXCEPTION 'NARA_STRANGLE_RECEIPT_DRIFT';END IF;RETURN prior.facts;END IF;
 IF NOT combat_panel_private.nara_adv_pool_v1(x.session_id) OR public.combat_v2_values_written(x.session_id) OR NOT combat_panel_private.uses_simulated_pools(x.session_id) THEN RAISE EXCEPTION 'NARA_STRANGLE_POOL_MODE_CHANGED' USING ERRCODE='42501';END IF;
 IF NOT combat_panel_private.nara_strangle_parent_valid_v1(x.declaration_id) THEN
  UPDATE combat_panel_private.nara_strangle_sources_v1 SET state='ended',end_reason='parent_or_actor_ended' WHERE declaration_id=x.declaration_id AND state IN('prepared','active');
  facts:=jsonb_build_object('contract','nara-strangolamento/1','kind',p_kind,'applied',false,'damage',0,'ko',false,'reason','parent_or_actor_ended');
 ELSE
  SELECT * INTO STRICT a FROM public.combat_v2_actors WHERE id=x.actor_id FOR UPDATE;SELECT * INTO STRICT t FROM public.combat_v2_actors WHERE id=x.target_actor_id FOR UPDATE;
  IF p_kind='upkeep' AND(a.mechanics_snapshot->>'chakra')::integer<10 THEN
   UPDATE combat_panel_private.nara_strangle_sources_v1 SET state='ended',end_reason='insufficient_child_chakra' WHERE declaration_id=x.declaration_id AND state IN('prepared','active');
   facts:=jsonb_build_object('contract','nara-strangolamento/1','kind',p_kind,'applied',false,'damage',0,'ko',false,'reason','insufficient_child_chakra');
  ELSE
   IF p_kind='upkeep' THEN UPDATE public.combat_v2_actors SET mechanics_snapshot=jsonb_set(mechanics_snapshot,'{chakra}',to_jsonb((mechanics_snapshot->>'chakra')::integer-10),false) WHERE id=a.id;END IF;
   before_hp:=(t.mechanics_snapshot->>'vita')::integer;red:=greatest(0,(t.mechanics_snapshot->>'resistenza')::integer/20);
   SELECT coalesce(max(f.resilience),0) INTO tenuta FROM clan_akimichi_private.forms f WHERE f.actor_id=t.id AND f.session_id=x.session_id AND f.active;
   damage:=least(65,greatest(1,10+greatest((x.profile->>'kg')::integer,(x.profile->>'ninjutsu')::integer)/4-red-tenuta));
   armor:=clan_sabaku_private.armor_absorb_packet_v1(t.id,p_round,eid,NULL,damage);
   damage:=(armor->>'damage_after')::integer;after_hp:=greatest(0,before_hp-damage);
   UPDATE combat_panel_private.nara_strangle_sources_v1 SET state=CASE WHEN after_hp=0 THEN 'ended' ELSE 'active' END,end_reason=CASE WHEN after_hp=0 THEN 'target_inoperative' ELSE NULL END WHERE declaration_id=x.declaration_id AND state IN('prepared','active');
   UPDATE public.combat_v2_actors SET mechanics_snapshot=jsonb_set(mechanics_snapshot,'{vita}',to_jsonb(after_hp),false),state=CASE WHEN after_hp=0 THEN 'fuori' ELSE state END WHERE id=t.id;
   facts:=jsonb_build_object('contract','nara-strangolamento/1','kind',p_kind,'applied',true,'damage',before_hp-after_hp,'ko',after_hp=0,'reason','packet_applied');
   facts:=facts||jsonb_build_object('parent_id',x.parent_id,'chain_version',x.profile->'chain_version','power',x.profile->'power','damage_base',10,'stat_contribution',greatest((x.profile->>'kg')::integer,(x.profile->>'ninjutsu')::integer)/4,'resistance_reduction',red,'tenuta',tenuta,'armor',armor,'chakra_cost',10,'values_written',false);
  END IF;
 END IF;
 facts:=facts||jsonb_build_object('chakra_cost',CASE WHEN p_kind='activation' OR facts->'applied'='true'::jsonb THEN 10 ELSE 0 END,'values_written',false);
 INSERT INTO combat_panel_private.nara_strangle_events_v1 VALUES(eid,x.declaration_id,x.session_id,p_round,p_turn,p_kind,facts,public.combat_v2_sha256(facts),clock_timestamp());
 RETURN facts;
END $f$;
CREATE FUNCTION combat_panel_private.nara_strangle_resolve_v1(p_declaration uuid) RETURNS jsonb LANGUAGE plpgsql SECURITY DEFINER SET search_path='' AS $f$
DECLARE x combat_panel_private.nara_strangle_sources_v1%ROWTYPE;d public.combat_v2_declarations%ROWTYPE;
BEGIN
 SELECT * INTO STRICT x FROM combat_panel_private.nara_strangle_sources_v1 WHERE declaration_id=p_declaration;SELECT * INTO STRICT d FROM public.combat_v2_declarations WHERE id=x.declaration_id;
 IF d.state<>'congelata' OR NOT EXISTS(SELECT 1 FROM public.combat_v2_resource_ledger WHERE declaration_id=d.id AND resource_kind='chakra' AND committed_amount=10 AND is_simulated) THEN RAISE EXCEPTION 'NARA_STRANGLE_NATIVE_COST_REQUIRED';END IF;
 RETURN jsonb_build_object('nara_strangle',combat_panel_private.nara_strangle_packet_v1(d.id,d.round_id,x.activation_turn,'activation'));
END $f$;
CREATE FUNCTION combat_panel_private.nara_strangle_turn_v1(p_session uuid,p_actor uuid,p_turn uuid,p_adapter text) RETURNS void LANGUAGE plpgsql SECURITY DEFINER SET search_path='' AS $f$
DECLARE x combat_panel_private.nara_strangle_sources_v1%ROWTYPE;c jsonb;parent_receipt jsonb;
BEGIN
 PERFORM combat_panel_private.nara_strangle_lifecycle_v1(p_session);
 SELECT * INTO x FROM combat_panel_private.nara_strangle_sources_v1 WHERE session_id=p_session AND actor_id=p_actor AND state='active' FOR UPDATE;
 IF NOT FOUND OR x.activation_turn=p_turn THEN RETURN;END IF;
 c:=combat_effects_private.personal_turn(p_session,p_actor);
 IF c->>'useful' IS DISTINCT FROM 'true' THEN RETURN;END IF;
 IF c->>'turn_id' IS DISTINCT FROM p_turn::text OR c->>'adapter' IS DISTINCT FROM p_adapter OR c->>'is_current' IS DISTINCT FROM 'true' OR c->>'phase' IS DISTINCT FROM 'action' THEN RAISE EXCEPTION 'NARA_STRANGLE_NATIVE_TURN_REQUIRED';END IF;
 parent_receipt:=combat_panel_private.nara_settle_upkeep_v1(p_session,p_actor,x.parent_id,p_turn);
 IF NOT combat_panel_private.nara_strangle_parent_valid_v1(x.declaration_id) THEN PERFORM combat_panel_private.nara_strangle_lifecycle_v1(p_session);RETURN;END IF;
 PERFORM combat_panel_private.nara_strangle_packet_v1(x.declaration_id,(c->>'round_id')::uuid,p_turn,'upkeep');
END $f$;
CREATE FUNCTION combat_panel_private.nara_strangle_facts_revision_v1(p_facts jsonb) RETURNS text LANGUAGE plpgsql IMMUTABLE SECURITY DEFINER SET search_path='' AS $f$
DECLARE n jsonb;e jsonb;ar jsonb;seen text[]:='{}';k text;
BEGIN
 n:=p_facts->'nara_strangle_server';
 IF NOT mission_factory_owner.keys_exact_v2(n,ARRAY['version','events']) OR n->>'version' IS DISTINCT FROM 'nara-strangolamento-facts/1' OR jsonb_typeof(n->'events') IS DISTINCT FROM 'array' THEN RAISE EXCEPTION 'NARA_STRANGLE_FACTS_SCHEMA';END IF;
 IF jsonb_array_length(n->'events') NOT BETWEEN 1 AND 4 THEN RAISE EXCEPTION 'NARA_STRANGLE_FACTS_COUNT';END IF;
 FOR e IN SELECT value FROM jsonb_array_elements(n->'events') LOOP
  IF NOT mission_factory_owner.keys_exact_v2(e-'armor',ARRAY['event_key','kind','source_actor_id','target_actor_id','applied','damage','ko','reason'])
  OR coalesce(e->>'kind','') NOT IN('activation','upkeep','ended') OR coalesce(e->>'reason','') NOT IN('packet_applied','parent_or_actor_ended','insufficient_child_chakra','target_inoperative')
  OR jsonb_typeof(e->'applied')IS DISTINCT FROM 'boolean' OR jsonb_typeof(e->'ko')IS DISTINCT FROM 'boolean'
  OR jsonb_typeof(e->'damage')IS DISTINCT FROM 'number' OR coalesce(e->>'damage','')!~'^[0-9]{1,2}$' THEN RAISE EXCEPTION 'NARA_STRANGLE_FACTS_EVENT';END IF;
  FOREACH k IN ARRAY ARRAY['event_key','source_actor_id','target_actor_id'] LOOP
   IF jsonb_typeof(e->k)IS DISTINCT FROM 'string' OR coalesce(e->>k,'')!~'^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$' THEN RAISE EXCEPTION 'NARA_STRANGLE_FACTS_ACTOR';END IF;
  END LOOP;
  IF e->>'event_key'=ANY(seen) OR e->>'source_actor_id'=e->>'target_actor_id' OR(e->>'damage')::integer>65
  OR(e->'applied'='true'::jsonb)IS DISTINCT FROM(e->>'reason'='packet_applied') OR(e->'applied'='false'::jsonb AND e->'damage'<>'0'::jsonb)
  OR(e->'ko'='true'::jsonb AND(e->'applied'<>'true'::jsonb OR(e->>'damage')::integer=0)) THEN RAISE EXCEPTION 'NARA_STRANGLE_FACTS_OUTCOME';END IF;
  IF e->>'kind'='ended'AND(e->'applied'<>'false'::jsonb OR e->'ko'<>'false'::jsonb OR e?'armor'OR e->>'reason'='packet_applied')OR e->>'kind'<>'ended'AND e->>'reason'='target_inoperative'THEN RAISE EXCEPTION 'NARA_STRANGLE_TERMINAL_FACTS';END IF;
  seen:=array_append(seen,e->>'event_key');
  IF e?'armor' THEN
   ar:=e->'armor';
   IF NOT mission_factory_owner.keys_exact_v2(ar,ARRAY['version','actor_id','damage_before','absorbed','damage_after','sand_consumed','active_after','restore_pending'])
   OR ar->>'version'IS DISTINCT FROM 'sabaku-armor/2' OR ar->>'actor_id'IS DISTINCT FROM e->>'target_actor_id'
   OR ar->'sand_consumed'IS DISTINCT FROM '2'::jsonb OR ar->'active_after'IS DISTINCT FROM 'false'::jsonb OR ar->'restore_pending'IS DISTINCT FROM 'true'::jsonb OR e->'applied'IS DISTINCT FROM 'true'::jsonb THEN RAISE EXCEPTION 'NARA_STRANGLE_ARMOR_FACTS_SCHEMA';END IF;
   FOREACH k IN ARRAY ARRAY['damage_before','absorbed','damage_after'] LOOP
    IF jsonb_typeof(ar->k)IS DISTINCT FROM 'number' OR coalesce(ar->>k,'')!~'^[0-9]{1,2}$' OR(ar->>k)::integer>65 THEN RAISE EXCEPTION 'NARA_STRANGLE_ARMOR_FACTS_AMOUNT';END IF;
   END LOOP;
   IF(ar->>'damage_before')::integer<1 OR(ar->>'absorbed')::integer+(ar->>'damage_after')::integer<>(ar->>'damage_before')::integer OR(e->>'damage')::integer>(ar->>'damage_after')::integer THEN RAISE EXCEPTION 'NARA_STRANGLE_ARMOR_FACTS_OUTCOME';END IF;
  END IF;
 END LOOP;
 IF p_facts->>'kind'='lifecycle'AND(NOT mission_factory_owner.keys_exact_v2(p_facts-'aburame_verme_server',ARRAY['schema_version','kind','result','nara_strangle_server'])OR p_facts->>'schema_version'IS DISTINCT FROM 'combat-narrative-facts/1'OR p_facts->'result'IS DISTINCT FROM '{}'::jsonb OR NOT EXISTS(SELECT 1 FROM jsonb_array_elements(n->'events')z WHERE z->>'kind'='upkeep'AND z->'ko'='true'::jsonb)AND NOT EXISTS(SELECT 1 FROM jsonb_array_elements(coalesce(p_facts#>'{aburame_verme_server,events}','[]'::jsonb))z WHERE z->>'kind'='poison_tick'AND z->'ko'='true'::jsonb))THEN RAISE EXCEPTION 'NARA_STRANGLE_LIFECYCLE_FACTS';END IF;
 RETURN 'combat-facts/4';
END $f$;
CREATE FUNCTION combat_panel_private.nara_strangle_facts_v1(p_round uuid,p_actor uuid DEFAULT NULL) RETURNS jsonb LANGUAGE plpgsql STABLE SECURITY DEFINER SET search_path='' AS $f$
DECLARE result jsonb;
BEGIN
 IF EXISTS(SELECT 1 FROM combat_panel_private.nara_strangle_events_v1 e WHERE e.round_id=p_round AND e.facts_sha256 IS DISTINCT FROM public.combat_v2_sha256(e.facts)) THEN RAISE EXCEPTION 'NARA_STRANGLE_FROZEN_FACTS_DRIFT';END IF;
 SELECT CASE WHEN count(*)=0 THEN '{}'::jsonb ELSE jsonb_build_object('nara_strangle_server',jsonb_build_object('version','nara-strangolamento-facts/1','events',jsonb_agg(
  jsonb_build_object('event_key',e.event_id,'kind',e.kind,'source_actor_id',x.actor_id,'target_actor_id',x.target_actor_id,'applied',e.facts->'applied','damage',e.facts->'damage','ko',e.facts->'ko','reason',e.facts->'reason')
  ||CASE WHEN e.facts#>>'{armor,version}'='sabaku-armor/2' THEN jsonb_build_object('armor',jsonb_build_object('version','sabaku-armor/2','actor_id',e.facts#>'{armor,actor_id}','damage_before',e.facts#>'{armor,damage_before}','absorbed',e.facts#>'{armor,absorbed}','damage_after',e.facts#>'{armor,damage_after}','sand_consumed',e.facts#>'{armor,sand_consumed}','active_after',e.facts#>'{armor,active_after}','restore_pending',e.facts#>'{armor,restore_pending}')) ELSE '{}'::jsonb END
  ORDER BY CASE WHEN e.kind='ended'THEN 1 ELSE 0 END,e.created_at,e.event_id))) END INTO result FROM combat_panel_private.nara_strangle_events_v1 e JOIN combat_panel_private.nara_strangle_sources_v1 x ON x.declaration_id=e.source_declaration WHERE e.round_id=p_round AND(p_actor IS NULL OR(e.kind<>'ended'AND x.actor_id=p_actor)OR(e.kind='ended'AND e.facts->>'narrator_actor_id'=p_actor::text));
 IF result?'nara_strangle_server' THEN PERFORM combat_panel_private.nara_strangle_facts_revision_v1(result);END IF;
 RETURN result;
END $f$;
CREATE FUNCTION combat_panel_private.nara_adv_history_guard_v1() RETURNS trigger LANGUAGE plpgsql SECURITY DEFINER SET search_path='' AS $f$
BEGIN
 IF TG_OP='DELETE' THEN RAISE EXCEPTION 'NARA_ADV_HISTORY_PRESERVED';END IF;
 IF TG_TABLE_NAME='nara_strangle_sources_v1' AND (to_jsonb(NEW)-ARRAY['state','end_reason'])=(to_jsonb(OLD)-ARRAY['state','end_reason']) AND(OLD.state<>'ended' OR NEW IS NOT DISTINCT FROM OLD) THEN RETURN NEW;END IF;
 RAISE EXCEPTION 'NARA_ADV_FROZEN_SOURCE_IMMUTABLE';
END $f$;
CREATE FUNCTION combat_panel_private.nara_strangle_end_event_v1() RETURNS trigger LANGUAGE plpgsql SECURITY DEFINER SET search_path='' AS $f$
DECLARE eid uuid;r uuid;t uuid;c jsonb;f jsonb;narrator_actor uuid;
BEGIN
 IF OLD.state='ended' OR NEW.state<>'ended' THEN RETURN NEW;END IF;
 eid:=md5('nara-strangolamento/1|'||NEW.declaration_id||'|ended')::uuid;
 SELECT e.turn_id INTO t FROM combat_panel_private.nara_strangle_events_v1 e WHERE e.source_declaration=NEW.declaration_id ORDER BY e.created_at DESC,e.event_id DESC LIMIT 1;
 t:=coalesce(t,NEW.activation_turn);
 IF EXISTS(SELECT 1 FROM public.combat_v2_actors a JOIN public.combat_v2_sessions s ON s.id=a.session_id WHERE a.id=NEW.actor_id AND a.state='attivo'AND s.state='in_corso'AND s.closed_at IS NULL)THEN
  c:=combat_effects_private.personal_turn(NEW.session_id,NEW.actor_id);t:=coalesce((c->>'turn_id')::uuid,t);
 END IF;
 SELECT q.id INTO STRICT r FROM public.combat_v2_rounds q WHERE q.session_id=NEW.session_id
 ORDER BY EXISTS(SELECT 1 FROM public.combat_v2_round_reports rep WHERE rep.round_id=q.id),q.round_no DESC LIMIT 1;
 SELECT ac.turn_actor_id INTO narrator_actor FROM combat_consumer_private.activities ac WHERE ac.session_id=NEW.session_id AND ac.exchange_id=r;
 IF narrator_actor IS NULL THEN narrator_actor:=combat_panel_private.human_duel_turn_actor(r);END IF;
 f:=jsonb_build_object('contract','nara-strangolamento/1','kind','ended','applied',false,'damage',0,'ko',false,'reason',NEW.end_reason,'parent_id',NEW.parent_id,'chain_version',NEW.profile->'chain_version','native_round_id',r,'native_turn_id',t,'narrator_actor_id',coalesce(narrator_actor,NEW.actor_id),'values_written',false);
 INSERT INTO combat_panel_private.nara_strangle_events_v1 VALUES(eid,NEW.declaration_id,NEW.session_id,r,t,'ended',f,public.combat_v2_sha256(f),clock_timestamp())ON CONFLICT(event_id)DO NOTHING;
 RETURN NEW;
END $f$;
CREATE FUNCTION combat_panel_private.nara_strangle_terminal_report_v1(p_round uuid) RETURNS boolean LANGUAGE plpgsql SECURITY DEFINER SET search_path='' AS $f$
DECLARE r public.combat_v2_rounds%ROWTYPE;s public.combat_v2_sessions%ROWTYPE;c combat_consumer_private.activities%ROWTYPE;f jsonb;rep jsonb;rid uuid;rep_sha text;effects jsonb;
BEGIN
 SELECT * INTO r FROM public.combat_v2_rounds WHERE id=p_round FOR UPDATE;
 IF r.id IS NULL THEN RETURN false;END IF;
 IF NOT EXISTS(SELECT 1 FROM combat_panel_private.nara_strangle_events_v1 e WHERE e.round_id=r.id AND e.kind='upkeep'AND e.facts->'ko'='true'::jsonb)AND NOT EXISTS(SELECT 1 FROM clan_aburame_private.verme_events_v1 e WHERE e.round_id=r.id AND e.kind='poison_tick'AND e.facts->'ko'='true'::jsonb AND e.facts_sha256=public.combat_v2_sha256(e.facts))THEN RETURN false;END IF;
 SELECT * INTO STRICT s FROM public.combat_v2_sessions WHERE id=r.session_id FOR UPDATE;
 IF NOT combat_panel_private.nara_adv_pool_v1(s.id)OR(SELECT count(*)FROM public.combat_v2_actors WHERE session_id=s.id AND state='attivo'AND companion_id IS NULL)>=2 THEN RETURN false;END IF;
 IF EXISTS(SELECT 1 FROM public.combat_v2_declarations WHERE round_id=r.id)THEN IF NOT EXISTS(SELECT 1 FROM combat_consumer_private.activities WHERE session_id=s.id)THEN RETURN false;END IF;RAISE EXCEPTION 'NARA_STRANGLE_TERMINAL_REQUIRES_EMPTY_NATIVE_ROUND';END IF;
 SELECT * INTO c FROM combat_consumer_private.activities WHERE session_id=s.id FOR UPDATE;
 IF c.session_id IS NOT NULL AND(c.exchange_id IS DISTINCT FROM r.id OR c.phase NOT IN('action','resolved'))THEN RAISE EXCEPTION 'NARA_STRANGLE_TERMINAL_CONTEXT_DRIFT';END IF;
 IF EXISTS(SELECT 1 FROM public.combat_v2_round_reports WHERE round_id=r.id)THEN RETURN true;END IF;
 IF r.phase<>'raccolta_azioni'OR s.state<>'in_corso'OR s.closed_at IS NOT NULL THEN RAISE EXCEPTION 'NARA_STRANGLE_TERMINAL_WINDOW';END IF;
 UPDATE public.combat_v2_rounds SET phase='risoluzione'WHERE id=r.id;
 effects:=combat_effects_private.lifecycle_before_report(r.id);
 f:=combat_panel_private.nara_strangle_facts_v1(r.id)||clan_aburame_private.verme_narrative_v1(r.id,NULL);
 rep:=jsonb_build_object('catalogo_lifecycle_contract','catalogo-lifecycle-report/1','round_id',r.id,'initial_actors',NULL,'effects_lifecycle',effects,'final_actors',(SELECT jsonb_agg(jsonb_build_object('actor',a.id,'state',a.state,'position_m',a.position_m,'mechanics',a.mechanics_snapshot)ORDER BY a.id)FROM public.combat_v2_actors a WHERE a.session_id=s.id),'native_akimichi_forms',(SELECT coalesce(jsonb_agg(to_jsonb(fm)ORDER BY fm.actor_id),'[]'::jsonb)FROM clan_akimichi_private.forms fm JOIN public.combat_v2_actors aa ON aa.id=fm.actor_id AND aa.session_id=fm.session_id WHERE fm.session_id=s.id AND NOT fm.active AND fm.ended_reason='actor_inoperative'AND aa.state<>'attivo'),'declarations','[]'::jsonb,'attack_targets','[]'::jsonb,'defense_coverages','[]'::jsonb,'ledger',(SELECT coalesce(jsonb_agg(clan_marionettisti_private.ledger_wire(l)ORDER BY l.created_at,l.id),'[]'::jsonb)FROM public.combat_v2_resource_ledger l WHERE l.round_id=r.id),'values_written',false,'engine_version',r.engine_version,'resolver_version',r.resolver_version,'order_version',r.order_version,'quality_version',r.quality_version)||f;
 rep_sha:=public.combat_v2_sha256(rep);
 INSERT INTO public.combat_v2_round_reports(round_id,mechanics,mechanics_sha256,values_written,engine_version,resolver_version,order_version,quality_version)VALUES(r.id,rep,rep_sha,false,r.engine_version,r.resolver_version,r.order_version,r.quality_version)RETURNING id INTO rid;
 UPDATE public.combat_v2_rounds SET phase='risolto',state='risolto',resolved_at=clock_timestamp(),report_id=rid WHERE id=r.id;
 IF c.session_id IS NOT NULL THEN UPDATE combat_consumer_private.activities SET phase='resolved',context_version=context_version+1,last_action_at=clock_timestamp()WHERE session_id=s.id;END IF;
 UPDATE combat_consumer_private.offers SET state='revoked'WHERE session_id=s.id AND state='offered';
 RETURN true;
END $f$;
CREATE FUNCTION combat_panel_private.nara_strangle_lifecycle_context_v1(p_round uuid) RETURNS jsonb LANGUAGE plpgsql STABLE SECURITY DEFINER SET search_path='' AS $f$
DECLARE c combat_consumer_private.activities%ROWTYPE;rep public.combat_v2_round_reports%ROWTYPE;e combat_panel_private.nara_strangle_sources_v1%ROWTYPE;source_actor uuid;target_actor uuid;source public.characters%ROWTYPE;target public.characters%ROWTYPE;facts jsonb;prior text;place text;
BEGIN
 SELECT * INTO rep FROM public.combat_v2_round_reports WHERE round_id=p_round AND narration_state='attesa';
 IF rep.id IS NULL OR rep.mechanics->>'catalogo_lifecycle_contract'IS DISTINCT FROM 'catalogo-lifecycle-report/1'THEN RETURN NULL;END IF;
 SELECT * INTO STRICT c FROM combat_consumer_private.activities WHERE exchange_id=p_round AND phase='resolved';
 IF rep.mechanics_sha256 IS DISTINCT FROM public.combat_v2_sha256(rep.mechanics)OR EXISTS(SELECT 1 FROM public.combat_v2_declarations WHERE round_id=p_round)THEN RAISE EXCEPTION 'NARA_STRANGLE_LIFECYCLE_REPORT_DRIFT';END IF;
 facts:=jsonb_build_object('schema_version','combat-narrative-facts/1','kind','lifecycle','result','{}'::jsonb)||CASE WHEN rep.mechanics?'nara_strangle_server'THEN jsonb_build_object('nara_strangle_server',rep.mechanics->'nara_strangle_server')ELSE '{}'::jsonb END||CASE WHEN rep.mechanics?'aburame_verme_server'THEN jsonb_build_object('aburame_verme_server',rep.mechanics->'aburame_verme_server')ELSE '{}'::jsonb END;
 IF facts?'nara_strangle_server'THEN PERFORM combat_panel_private.nara_strangle_facts_revision_v1(facts);END IF;
 IF rep.mechanics->'nara_strangle_server'IS DISTINCT FROM combat_panel_private.nara_strangle_facts_v1(p_round)->'nara_strangle_server'OR rep.mechanics->'aburame_verme_server'IS DISTINCT FROM clan_aburame_private.verme_narrative_v1(p_round,NULL)->'aburame_verme_server'THEN RAISE EXCEPTION 'NARA_STRANGLE_LIFECYCLE_FROZEN_DRIFT';END IF;
 SELECT z.actor_id,z.target_actor_id INTO source_actor,target_actor FROM clan_aburame_private.verme_events_v1 z WHERE z.round_id=p_round AND z.kind='poison_tick'AND z.facts->'ko'='true'::jsonb ORDER BY z.created_at,z.event_key LIMIT 1;
 IF source_actor IS NULL THEN SELECT x.actor_id,x.target_actor_id INTO STRICT source_actor,target_actor FROM combat_panel_private.nara_strangle_sources_v1 x WHERE x.declaration_id=(SELECT z.source_declaration FROM combat_panel_private.nara_strangle_events_v1 z WHERE z.round_id=p_round AND z.kind='upkeep'AND z.facts->'ko'='true'::jsonb LIMIT 1);END IF;
 SELECT ch.* INTO STRICT source FROM public.characters ch JOIN combat_consumer_private.members m ON m.character_id=ch.id WHERE m.session_id=c.session_id AND m.actor_id=source_actor;
 SELECT ch.* INTO STRICT target FROM public.characters ch JOIN combat_consumer_private.members m ON m.character_id=ch.id WHERE m.session_id=c.session_id AND m.actor_id=target_actor;
 SELECT name INTO STRICT place FROM public.locations WHERE id=c.location_id;
 SELECT n.body INTO prior FROM public.combat_v2_narratives n JOIN public.combat_v2_rounds r ON r.id=n.round_id WHERE r.session_id=c.session_id AND r.id<>p_round AND r.state='narrato'ORDER BY r.round_no DESC LIMIT 1;
 RETURN jsonb_build_object('ordinary',true,'genere','azione_risolta','non_offensivo',true,'autore',jsonb_build_object('nome',source.name,'sesso',source.sex),'testimone',jsonb_build_object('nome',target.name,'sesso',target.sex),'luogo',place,'tecnica',left('Effetti periodici già applicati'||CASE WHEN jsonb_array_length(coalesce(rep.mechanics->'native_akimichi_forms','[]'::jsonb))>0 THEN ' · Espansione Akimichi cessata con il corpo non operativo'ELSE ''END,300),'fatti',facts,'movimento','assente','reazione',NULL,'player_reports','{}'::jsonb,'gia_visto',left(coalesce(prior,''),400),'model','gpt-6-luna');
END $f$;
CREATE FUNCTION combat_panel_private.nara_adv_offers_v1(p_context uuid,p_version bigint,p_view jsonb) RETURNS void LANGUAGE plpgsql SECURITY DEFINER SET search_path='' AS $f$
DECLARE c combat_panel_private.contexts%ROWTYPE;a public.combat_v2_actors%ROWTYPE;m jsonb;
BEGIN
 c:=combat_panel_private.owned_context(p_context,p_version);
 IF c.activity_kind NOT IN('ordinary_v2','master_v2') OR c.round_id IS NULL OR p_view#>>'{context,phase}' IS DISTINCT FROM 'action' THEN RETURN;END IF;
 SELECT * INTO a FROM public.combat_v2_actors WHERE id=c.command_actor_id AND session_id=c.activity_id AND controller_user=auth.uid();
 IF NOT FOUND OR NOT combat_panel_private.nara_adv_scope_v1(a.id) THEN RETURN;END IF;
 IF public.is_staff() AND clan_innata_narrative_private.staff_profile_actor_v1(a.id)->>'family'='nara'
 AND NOT EXISTS(SELECT 1 FROM combat_panel_private.nara_adv_staff_v1 WHERE actor_id=a.id)
 AND NOT EXISTS(SELECT 1 FROM public.combat_v2_declarations d JOIN public.combat_v2_rounds r ON r.id=d.round_id WHERE r.session_id=a.session_id)
 AND NOT EXISTS(SELECT 1 FROM combat_panel_private.offers WHERE context_id=c.id AND context_version=c.context_version AND state='offered' AND source_payload->>'dispatch'='nara_adv_prepare') THEN
  PERFORM combat_panel_private.create_offer(c.id,c.context_version,'control','control','Prepara prova: Strangolamento dell''Ombra (KG55 · L2)',false,jsonb_build_object('adapter',c.activity_kind,'dispatch','nara_adv_prepare','contract','nara-strangolamento/1'));
 END IF;
 m:=combat_panel_private.nara_strangle_meta_v1(a.id);
 IF m IS NOT NULL AND NOT EXISTS(SELECT 1 FROM public.combat_v2_declarations WHERE round_id=c.round_id AND actor_id=a.id AND kind IN('attacco','utilita','movimento','passa'))
 AND NOT EXISTS(SELECT 1 FROM combat_panel_private.offers WHERE context_id=c.id AND context_version=c.context_version AND state='offered' AND source_payload->>'dispatch'='nara_strangle') THEN
  PERFORM combat_panel_private.create_offer(c.id,c.context_version,'action','declare','Strangolamento dell''Ombra · 10 chakra',true,jsonb_build_object('adapter',c.activity_kind,'dispatch','nara_strangle','contract','nara-strangolamento/1','parent_id',m->'parent_id','target_actor_id',m->'target_actor_id'));
 END IF;
END $f$;
CREATE FUNCTION combat_panel_private.nara_adv_commit_v1(p_command jsonb) RETURNS jsonb LANGUAGE plpgsql SECURITY DEFINER SET search_path='' AS $f$
DECLARE p jsonb;uid uuid:=auth.uid();key uuid;fp text;o combat_panel_private.offers%ROWTYPE;c combat_panel_private.contexts%ROWTYPE;a public.combat_v2_actors%ROWTYPE;prior combat_panel_private.request_receipts%ROWTYPE;env jsonb;receipt jsonb;result jsonb;intent jsonb;m jsonb;decl uuid;eid uuid:=gen_random_uuid();resolve_key uuid;report public.combat_v2_round_reports%ROWTYPE;prep boolean;
BEGIN
 IF uid IS NULL THEN RAISE EXCEPTION 'panel_authentication_required' USING ERRCODE='28000';END IF;
 p:=combat_panel_private.validate_command(p_command);key:=(p->>'request_key')::uuid;fp:=public.combat_v2_sha256(p);
 PERFORM pg_advisory_xact_lock(hashtextextended('panel-request:'||uid||':'||key,731));
 SELECT * INTO prior FROM combat_panel_private.request_receipts WHERE principal_user=uid AND request_key=key;
 IF FOUND THEN IF prior.command_fingerprint<>fp THEN RAISE EXCEPTION 'panel_request_key_conflict';END IF;RETURN jsonb_set(prior.viewer_envelope,'{receipt,replayed}','true',false);END IF;
 SELECT * INTO o FROM combat_panel_private.offers WHERE id=(p->>'offer_id')::uuid AND principal_user=uid;
 prep:=o.source_payload->>'dispatch'='nara_adv_prepare';
 IF o.id IS NULL OR o.source_payload->>'dispatch' NOT IN('nara_adv_prepare','nara_strangle') OR o.source_payload->>'contract' IS DISTINCT FROM 'nara-strangolamento/1' OR o.source_payload->>'adapter' NOT IN('ordinary_v2','master_v2') OR(prep AND(o.kind<>'control' OR o.operation<>'control')) OR(NOT prep AND(o.kind<>'action' OR o.operation<>'declare')) THEN RAISE EXCEPTION 'panel_offer_not_available' USING ERRCODE='42501';END IF;
 SELECT * INTO STRICT c FROM combat_panel_private.contexts WHERE id=o.context_id AND principal_user=uid;
 IF c.round_id IS NULL OR c.location_id IS DISTINCT FROM(p->>'location_id')::uuid OR c.activity_id IS DISTINCT FROM(p->>'activity_id')::uuid OR c.activity_kind IS DISTINCT FROM o.source_payload->>'adapter' THEN RAISE EXCEPTION 'panel_activity_scope_invalid';END IF;
 PERFORM public.combat_v2_lock_round(c.round_id);
 IF c.activity_kind='ordinary_v2' THEN env:=combat_panel_private.ordinary_projection(c.location_id,c.command_actor_id);ELSE env:=combat_panel_private.master_projection(c.location_id,c.command_actor_id);END IF;
 IF env->>'status' IS DISTINCT FROM 'ready' THEN RAISE EXCEPTION 'panel_source_not_ready';END IF;
 c:=combat_panel_private.owned_context(c.id,(p->>'context_version')::bigint);
 SELECT * INTO STRICT o FROM combat_panel_private.offers WHERE id=o.id FOR UPDATE;
 IF o.state<>'offered' OR o.context_version<>c.context_version OR o.source_fingerprint IS DISTINCT FROM c.source_fingerprint OR o.scene_version IS DISTINCT FROM c.scene_version OR o.actor_id IS DISTINCT FROM c.command_actor_id THEN RAISE EXCEPTION 'panel_offer_not_available';END IF;
 SELECT * INTO STRICT a FROM public.combat_v2_actors WHERE id=o.actor_id AND session_id=c.activity_id AND controller_user=uid FOR UPDATE;
 IF NOT combat_panel_private.nara_adv_scope_v1(a.id) OR p->'selected_option_ids' IS DISTINCT FROM '[]'::jsonb OR p->'inputs' IS DISTINCT FROM '[]'::jsonb THEN RAISE EXCEPTION 'NARA_ADV_COMMAND_INVALID' USING ERRCODE='42501';END IF;
 IF prep THEN
  IF o.requires_role OR length(btrim(p->>'narrative_text'))<>0 THEN RAISE EXCEPTION 'NARA_ADV_PREP_ROLE_INVALID';END IF;
  PERFORM combat_panel_private.nara_adv_prepare_v1(a.id,c.round_id);
 ELSE
  IF NOT o.requires_role OR length(btrim(p->>'narrative_text'))=0 THEN RAISE EXCEPTION 'panel_role_required';END IF;
  m:=combat_panel_private.nara_strangle_meta_v1(a.id);
  IF m IS NULL OR m->'parent_id' IS DISTINCT FROM o.source_payload->'parent_id' OR m->'target_actor_id' IS DISTINCT FROM o.source_payload->'target_actor_id' THEN RAISE EXCEPTION 'NARA_STRANGLE_PARENT_CHANGED';END IF;
  intent:=jsonb_build_object('kind','utilita','ability_source','clan','ability_id','0a15282f-d6b5-4ee3-ad52-7fac2525444d','target_actor',m->'target_actor_id');
  IF c.activity_kind='ordinary_v2' THEN
   INSERT INTO combat_consumer_private.dispatch_authorizations VALUES(key,c.round_id,a.character_id,txid_current(),'declare','prepared');
  END IF;
  result:=public.combat_v2_action_declare(c.round_id,a.id,intent,p->>'narrative_text',key);decl:=(result#>>'{data,declaration_id}')::uuid;
  IF decl IS NULL THEN SELECT id INTO decl FROM public.combat_v2_declarations WHERE round_id=c.round_id AND actor_id=a.id AND request_key=key;END IF;
  IF NOT EXISTS(SELECT 1 FROM combat_panel_private.nara_strangle_sources_v1 WHERE declaration_id=decl) THEN RAISE EXCEPTION 'NARA_STRANGLE_BINDING_REQUIRED';END IF;
  IF c.activity_kind='ordinary_v2' THEN
   UPDATE combat_consumer_private.dispatch_authorizations SET state='consumed' WHERE request_key=key AND round_id=c.round_id;
   IF combat_v2_multitarget_internal.round_complete(c.round_id) THEN
    resolve_key:=gen_random_uuid();INSERT INTO combat_consumer_private.dispatch_authorizations VALUES(resolve_key,c.round_id,a.character_id,txid_current(),'resolve','prepared');
    PERFORM public.combat_v2_round_resolve(c.round_id,resolve_key);
    UPDATE combat_consumer_private.dispatch_authorizations SET state='consumed' WHERE request_key=resolve_key AND round_id=c.round_id;
    UPDATE combat_consumer_private.activities SET phase='resolved' WHERE session_id=c.activity_id;
   END IF;
   PERFORM combat_consumer_private.record_message(decl,public.post_message(c.location_id,p->>'narrative_text',null,null,null));
  ELSE PERFORM combat_panel_private.publish_master_declaration(decl,p->>'narrative_text');END IF;
 END IF;
 UPDATE combat_panel_private.offers SET state='revoked' WHERE context_id=c.id AND context_version=c.context_version AND state='offered' AND id<>o.id;
 UPDATE combat_panel_private.contexts SET context_version=context_version+1,updated_at=clock_timestamp() WHERE id=c.id;
 IF c.activity_kind='ordinary_v2' THEN
  UPDATE combat_consumer_private.activities SET context_version=context_version+1,last_action_at=clock_timestamp() WHERE session_id=c.activity_id;
  env:=combat_panel_private.ordinary_projection(c.location_id,a.id);
 ELSE env:=combat_panel_private.master_projection(c.location_id,a.id);END IF;
 SELECT * INTO report FROM public.combat_v2_round_reports WHERE round_id=c.round_id;
 receipt:=jsonb_build_object('receipt_id',eid,'request_key',key,'operation',o.operation,'replayed',false,'activity_id',c.activity_id,'round_id',c.round_id,'context_version_before',o.context_version,'context_version_after',env#>'{context,version}','declaration_id',decl,'report_id',report.id,'values_written',false,'display_events','[]'::jsonb);
 env:=jsonb_set(env,'{receipt}',receipt);UPDATE combat_panel_private.offers SET state='consumed',consumed_request_key=key WHERE id=o.id;
 INSERT INTO combat_panel_private.request_receipts(principal_user,request_key,command_fingerprint,offer_id,event_id,viewer_envelope)VALUES(uid,key,fp,o.id,eid,env);RETURN env;
END $f$;
CREATE FUNCTION combat_panel_private.nara_strangle_lifecycle_trigger_v1() RETURNS trigger LANGUAGE plpgsql SECURITY DEFINER SET search_path='' AS $f$
BEGIN
 IF TG_TABLE_SCHEMA='combat_spatial' THEN PERFORM combat_panel_private.nara_strangle_lifecycle_v1((SELECT encounter_id FROM combat_spatial.arena_instances WHERE instance_id=NEW.instance_id));
 ELSE PERFORM combat_panel_private.nara_strangle_lifecycle_v1(NEW.session_id);END IF;RETURN NEW;
END $f$;
CREATE FUNCTION combat_v2_staff_nb_internal.preparation_allowed(p_master uuid) RETURNS boolean LANGUAGE sql STABLE SECURITY DEFINER SET search_path='' AS $nb$
 SELECT clan_innata_private.catalogo_eligibility_release_v1()AND EXISTS(SELECT 1 FROM public.master_v2_sessions m JOIN public.locations l ON l.id=m.location_id
 JOIN combat_panel_private.master_panel_sessions mp ON mp.master_session_id=m.id
 JOIN combat_v2_staff_nb_internal.gate g ON g.singleton
 WHERE m.id=p_master AND m.master_user=auth.uid() AND auth.uid() IS NOT NULL AND public.is_staff()
 AND m.owner_kind='human' AND m.tipo='duello' AND m.mission_id IS NULL AND m.quest_kind IS NULL
 AND m.stato='preparazione' AND m.closed_at IS NULL AND m.suspended_at IS NULL
 AND l.id='0b85f354-9cdb-47e1-baf9-3d266bb7e06b'::uuid AND l.is_test AND l.is_active
 AND mp.policy_id='staff_test_no_persistent_resources_v1' AND g.staff_enabled AND NOT g.public_enabled
 AND NOT EXISTS(SELECT 1 FROM public.mission_run_state x WHERE x.master_session_id=m.id)
 AND NOT EXISTS(SELECT 1 FROM combat_consumer_private.narrative_authorities x WHERE x.master_session_id=m.id)
 AND NOT EXISTS(SELECT 1 FROM exam_human_private.native_bindings x WHERE x.master_session_id=m.id)
 AND NOT EXISTS(SELECT 1 FROM mission_factory_owner.quest_run_sources x WHERE x.session_id=m.id)
 AND NOT EXISTS(SELECT 1 FROM public.combat_v2_sessions x WHERE x.master_session_id=m.id)
 AND NOT EXISTS(SELECT 1 FROM public.master_v2_participants x WHERE x.session_id=m.id)
 AND NOT EXISTS(SELECT 1 FROM combat_panel_private.staff_prepared_duel_rosters_v1 x WHERE x.master_session_id=m.id)
 AND NOT EXISTS(SELECT 1 FROM combat_v2_staff_nb_internal.admissions x WHERE x.master_session_id=m.id))
$nb$;
CREATE FUNCTION combat_v2_staff_nb_internal.pg_scope(p_actor uuid) RETURNS boolean LANGUAGE sql STABLE SECURITY DEFINER SET search_path='' AS $nb$
 SELECT EXISTS(SELECT 1 FROM public.combat_v2_actors a CROSS JOIN LATERAL(SELECT combat_v2_staff_nb_internal.roster_receipt(a.session_id) r) proof
 WHERE a.id=p_actor AND a.actor_kind='pg' AND a.companion_id IS NULL AND a.state='attivo' AND proof.r IS NOT NULL
 AND a.id IN((proof.r->>'source_actor_id')::uuid,(proof.r->>'target_actor_id')::uuid)
 AND EXISTS(SELECT 1 FROM combat_v2_staff_nb_internal.gate WHERE singleton AND staff_enabled AND NOT public_enabled))
$nb$;
CREATE FUNCTION combat_v2_staff_nb_internal.kai_authority(p_actor uuid) RETURNS jsonb LANGUAGE sql STABLE SECURITY DEFINER SET search_path='' AS $nb$
 SELECT combat_v2_staff_nb_internal.kai_frozen_authority(a.id) FROM public.combat_v2_actors a
 WHERE a.id=p_actor AND a.actor_kind='png' AND a.state='attivo' AND coalesce((a.mechanics_snapshot->>'vita')::numeric,0)>0
 AND EXISTS(SELECT 1 FROM combat_v2_staff_nb_internal.gate WHERE singleton AND staff_enabled AND NOT public_enabled)
$nb$;
CREATE FUNCTION clan_aburame_private.verme_report_v1(p_round uuid,p_declaration uuid DEFAULT NULL)
RETURNS jsonb LANGUAGE sql STABLE SECURITY DEFINER SET search_path='' AS $f$
 SELECT coalesce(jsonb_agg(jsonb_build_object('event_key',e.event_key,'kind',e.kind,'facts',e.facts) ORDER BY e.created_at,e.event_key),'[]')
 FROM clan_aburame_private.verme_events_v1 e WHERE e.round_id=p_round
 AND(p_declaration IS NULL OR e.declaration_id=p_declaration) AND e.kind<>'staff_prepared'
 AND e.facts_sha256=public.combat_v2_sha256(e.facts)
$f$;
CREATE FUNCTION clan_aburame_private.verme_narrative_v1(p_round uuid,p_declaration uuid DEFAULT NULL)
RETURNS jsonb LANGUAGE sql STABLE SECURITY DEFINER SET search_path='' AS $f$
 SELECT CASE WHEN count(*)=0 THEN '{}'::jsonb ELSE jsonb_build_object('aburame_verme_server',jsonb_build_object(
  'version','aburame-verme-narrative/1','events',jsonb_agg(jsonb_build_object(
   'event_key',e.event_key,'kind',CASE WHEN e.kind='released' THEN 'injection_resolved' ELSE e.kind END,
   'source_actor_id',e.actor_id,'target_actor_id',e.target_actor_id,
   'source',coalesce(sc.name,nullif(sa.mechanics_snapshot->>'name',''),'Combattente'),
   'target',coalesce(tc.name,nullif(ta.mechanics_snapshot->>'name',''),'Combattente'),
   'applied',CASE WHEN e.kind='released' THEN coalesce((e.facts->>'toxin_applied')::boolean,false) ELSE false END,
   'refreshed',CASE WHEN e.kind='released' THEN coalesce((e.facts->>'toxin_refreshed')::boolean,false) ELSE false END,
   'remaining_target_turns',coalesce((e.facts->>'remaining_target_turns')::integer,0),
   'ko',coalesce((e.facts->>'ko')::boolean,false)) ORDER BY e.created_at,e.event_key))) END
 FROM clan_aburame_private.verme_events_v1 e
 JOIN public.combat_v2_actors sa ON sa.id=e.actor_id JOIN public.combat_v2_actors ta ON ta.id=e.target_actor_id
 LEFT JOIN public.characters sc ON sc.id=sa.character_id LEFT JOIN public.characters tc ON tc.id=ta.character_id
 WHERE e.round_id=p_round AND e.kind IN('released','poison_tick','poison_end')
 AND(p_declaration IS NULL OR e.declaration_id=p_declaration OR e.kind IN('poison_tick','poison_end'))
 AND e.facts_sha256=public.combat_v2_sha256(e.facts)
$f$;
CREATE OR REPLACE FUNCTION clan_akimichi_private.common_staff_scope_v1(p_actor uuid)
RETURNS boolean LANGUAGE sql STABLE SECURITY DEFINER SET search_path='' AS $fn$
 SELECT clan_innata_private.catalogo_eligibility_release_v1()AND EXISTS(SELECT 1 FROM public.combat_v2_actors a
 JOIN public.combat_v2_sessions s ON s.id=a.session_id
 JOIN public.locations l ON l.id=s.location_id
 WHERE a.id=p_actor AND a.actor_kind='pg' AND a.companion_id IS NULL
 AND a.character_id IN('6bceee99-974f-426b-8d92-38b43b4a4267'::uuid,'2a877f02-4993-4e65-9172-7d29f08c5b86'::uuid)
 AND a.controller_user IS NOT NULL AND a.state='attivo'
 AND s.location_id='0b85f354-9cdb-47e1-baf9-3d266bb7e06b'::uuid
 AND s.state='in_corso' AND s.closed_at IS NULL AND s.source_kind IN('ordinary','master')
 AND NOT EXISTS(SELECT 1 FROM public.mission_run_state mr WHERE mr.master_session_id=s.master_session_id)AND NOT EXISTS(SELECT 1 FROM mission_generic_owner.run_bindings rb WHERE rb.master_session_id=s.master_session_id)AND NOT EXISTS(SELECT 1 FROM mission_narrative_internal.scene_runtime_v1 sr WHERE sr.master_session_id=s.master_session_id AND sr.is_active)
 AND s.user_test_context_id IS NULL AND l.is_active AND l.is_test
 AND combat_effects_private.staff_session_allowed(s.id)
 AND combat_panel_private.uses_simulated_pools(s.id) AND NOT public.combat_v2_values_written(s.id)
 AND NOT EXISTS(SELECT 1 FROM exam_regia_private.bindings b WHERE b.combat_session_id=s.id)
 AND NOT EXISTS(SELECT 1 FROM public.master_v2_sessions m WHERE m.id=s.master_session_id
   AND(m.owner_kind<>'human' OR m.tipo<>'duello' OR m.mission_id IS NOT NULL))
 AND (SELECT count(*) FROM public.combat_v2_actors q WHERE q.session_id=s.id AND q.actor_kind='pg' AND q.companion_id IS NULL)=2
 AND NOT EXISTS(SELECT 1 FROM public.combat_v2_actors q WHERE q.session_id=s.id AND
  (q.actor_kind<>'pg' OR q.companion_id IS NOT NULL OR q.character_id NOT IN
   ('6bceee99-974f-426b-8d92-38b43b4a4267'::uuid,'2a877f02-4993-4e65-9172-7d29f08c5b86'::uuid)))
 AND EXISTS(SELECT 1 FROM clan_akimichi_private.common_gate_v1 g WHERE g.singleton AND g.staff_enabled))
$fn$;
CREATE OR REPLACE FUNCTION clan_akimichi_private.cellular_attack_eligible_v1(p_actor uuid,p_attack uuid)
RETURNS boolean LANGUAGE sql STABLE SECURITY DEFINER SET search_path='' AS $fn$
 SELECT EXISTS(SELECT 1 FROM public.combat_v2_declarations d
 JOIN public.combat_v2_actors a ON a.id=p_actor AND a.session_id=(SELECT session_id FROM public.combat_v2_rounds WHERE id=d.round_id)
 JOIN clan_akimichi_private.common_attack_powers_v1 p ON p.declaration_id=d.id
 WHERE d.id=p_attack AND d.kind='attacco' AND d.state IN('inviata','congelata')
 AND p.source_sha256=public.combat_v2_sha256(p.profile)
 AND p.declaration_sha256=clan_hyuga_private.juken_declaration_fingerprint(d.id)
 AND lower(coalesce(d.sanitized_intent#>>'{server_ability,kind}','fisico'))='fisico'
 AND coalesce((d.cost_snapshot->>'damage_base')::integer,0)>0 AND d.sanitized_intent->'target_fili' IS DISTINCT FROM 'true'::jsonb
 AND combat_v2_genjutsu_internal.defense_intent_allowed(d.id,jsonb_build_object('reaction','tecnica','ability_source','clan','ability_id','687b058a-807d-4cf7-8bcf-21147931b0f6'))
 AND EXISTS(SELECT 1 FROM public.combat_v2_attack_targets t WHERE t.attack_declaration_id=d.id AND t.target_actor_id=a.id AND t.state='attesa_difesa')
 AND clan_akimichi_private.cellular_meta_v1(a.id) IS NOT NULL)
$fn$;
CREATE OR REPLACE FUNCTION clan_akimichi_private.cellular_source_valid_v1(p_defense uuid)
RETURNS boolean LANGUAGE sql STABLE SECURITY DEFINER SET search_path='' AS $fn$
 SELECT EXISTS(SELECT 1 FROM clan_akimichi_private.cellular_sources_v1 s JOIN public.combat_v2_declarations d ON d.id=s.declaration_id
 WHERE s.declaration_id=p_defense AND s.source_sha256=public.combat_v2_sha256(s.profile)
 AND s.profile->>'declaration_sha256'=clan_hyuga_private.juken_declaration_fingerprint(d.id)
 AND d.parent_attack_id=s.attack_declaration_id AND d.actor_id=s.actor_id AND d.round_id=s.round_id
 AND d.target_actor_id=s.actor_id AND d.controller_version_snapshot=s.controller_version)
$fn$;
-- Accepted native sources are commitments: no second wallet or refund path.
CREATE OR REPLACE FUNCTION clan_akimichi_private.common_calorie_balance_v1(p_owner uuid,p_scope uuid,p_exclude uuid DEFAULT NULL,p_replaces_upkeep uuid DEFAULT NULL)
RETURNS integer LANGUAGE sql STABLE SECURITY DEFINER SET search_path='' AS $fn$
 SELECT c.current_amount-coalesce((SELECT sum(q.cost)::integer FROM(
  SELECT s.declaration_id,10 AS cost FROM clan_akimichi_private.partial_sources s
  JOIN public.combat_v2_declarations d ON d.id=s.declaration_id AND d.state IN('inviata','congelata')
  JOIN public.combat_v2_sessions cs ON cs.id=s.session_id AND cs.closed_at IS NULL AND cs.state='in_corso'
  JOIN public.combat_v2_rounds r ON r.id=s.round_id AND r.state NOT IN('risolto','narrazione','narrato')
  WHERE s.owner_id=p_owner AND s.scope_id=p_scope AND s.declaration_id IS DISTINCT FROM p_exclude
   AND NOT EXISTS(SELECT 1 FROM clan_akimichi_private.calorie_receipts receipt WHERE receipt.owner_id=s.owner_id AND receipt.scope_id=s.scope_id
    AND receipt.event_id=s.declaration_id AND receipt.request->>'operation'='partial' AND receipt.result->'accepted'='true'::jsonb)
  UNION ALL
  SELECT s.declaration_id,10 AS cost FROM clan_akimichi_private.cellular_sources_v1 s
  JOIN public.combat_v2_declarations d ON d.id=s.declaration_id AND d.state IN('inviata','congelata')
  JOIN public.combat_v2_sessions cs ON cs.id=s.session_id AND cs.closed_at IS NULL AND cs.state='in_corso'
  JOIN public.combat_v2_rounds r ON r.id=s.round_id AND r.state NOT IN('risolto','narrazione','narrato')
  WHERE s.owner_id=p_owner AND s.scope_id=p_scope AND s.declaration_id IS DISTINCT FROM p_exclude AND s.calorie_receipt IS NULL
   AND NOT EXISTS(SELECT 1 FROM clan_akimichi_private.calorie_receipts receipt WHERE receipt.owner_id=s.owner_id AND receipt.scope_id=s.scope_id
    AND receipt.event_id=s.declaration_id AND receipt.request->>'operation'='cellular' AND receipt.result->'accepted'='true'::jsonb)
  UNION ALL
  SELECT NULL::uuid,CASE WHEN u.form_kind='super' THEN 15 ELSE 5 END AS cost
  FROM clan_akimichi_private.common_pending_upkeep_v1 u
  JOIN clan_akimichi_private.forms f ON f.actor_id=u.actor_id AND f.session_id=u.session_id AND f.active AND f.form_kind=u.form_kind
   AND f.last_paid_turn IS DISTINCT FROM u.personal_turn_id
  JOIN public.combat_v2_actors a ON a.id=u.actor_id AND a.session_id=u.session_id AND a.character_id=p_owner AND a.state='attivo'
  JOIN public.combat_v2_sessions cs ON cs.id=u.session_id AND cs.closed_at IS NULL AND cs.state='in_corso'
  WHERE u.state='pending' AND u.actor_id IS DISTINCT FROM p_replaces_upkeep
   AND((c.simulated AND c.scope_id=u.session_id) OR(NOT c.simulated AND c.scope_id=a.character_id))
   AND NOT EXISTS(SELECT 1 FROM clan_akimichi_private.calorie_receipts receipt WHERE receipt.owner_id=p_owner AND receipt.scope_id=p_scope
    AND receipt.event_id=md5('akimichi-expansion-upkeep/1|'||a.id::text||'|'||u.personal_turn_id::text)::uuid
    AND receipt.request->>'operation' IN('upkeep','super_upkeep') AND receipt.result->'accepted'='true'::jsonb)
 )q),0) FROM clan_akimichi_private.calorie_reserves c WHERE c.owner_id=p_owner AND c.scope_id=p_scope
$fn$;
CREATE FUNCTION combat_panel_private.nara_adv_pool_v1(p_session uuid) RETURNS boolean LANGUAGE sql STABLE SECURITY DEFINER SET search_path='' AS $f$
 SELECT clan_innata_private.catalogo_eligibility_release_v1()AND EXISTS(SELECT 1 FROM public.combat_v2_sessions s JOIN public.locations l ON l.id=s.location_id WHERE s.id=p_session AND s.location_id='0b85f354-9cdb-47e1-baf9-3d266bb7e06b' AND l.is_test AND l.is_active AND s.closed_at IS NULL AND s.state='in_corso' AND s.user_test_context_id IS NULL AND s.source_kind IN('ordinary','master') AND(s.source_kind='ordinary'OR(EXISTS(SELECT 1 FROM public.master_v2_sessions m WHERE m.id=s.master_session_id AND m.owner_kind='human'AND m.tipo='duello'AND m.mission_id IS NULL)AND NOT EXISTS(SELECT 1 FROM public.mission_run_state mr WHERE mr.master_session_id=s.master_session_id)AND NOT EXISTS(SELECT 1 FROM mission_generic_owner.run_bindings rb WHERE rb.master_session_id=s.master_session_id)AND NOT EXISTS(SELECT 1 FROM mission_narrative_internal.scene_runtime_v1 sr WHERE sr.master_session_id=s.master_session_id AND sr.is_active)))AND combat_effects_private.staff_session_allowed(s.id) AND combat_panel_private.uses_simulated_pools(s.id) AND NOT public.combat_v2_values_written(s.id)
 AND(SELECT count(*) FROM public.combat_v2_actors a WHERE a.session_id=s.id)=2 AND NOT EXISTS(SELECT 1 FROM public.combat_v2_actors a WHERE a.session_id=s.id AND(a.actor_kind<>'pg' OR a.companion_id IS NOT NULL OR a.character_id NOT IN('2a877f02-4993-4e65-9172-7d29f08c5b86','6bceee99-974f-426b-8d92-38b43b4a4267'))))
$f$;
CREATE FUNCTION combat_panel_private.nara_strangle_parent_valid_v1(p_declaration uuid) RETURNS boolean LANGUAGE sql STABLE SECURITY DEFINER SET search_path='' AS $f$
 SELECT EXISTS(SELECT 1 FROM combat_panel_private.nara_strangle_sources_v1 x JOIN combat_panel_private.immobilizations e ON e.id=x.parent_id AND e.session_id=x.session_id AND e.source_actor_id=x.actor_id AND e.target_actor_id=x.target_actor_id AND e.state='active'
 JOIN combat_panel_private.nara_body_control_v1 n ON n.effect_id=e.id
 JOIN public.combat_v2_sessions s ON s.id=x.session_id AND s.closed_at IS NULL AND s.state='in_corso'
 JOIN public.combat_v2_actors a ON a.id=x.actor_id AND a.session_id=s.id AND a.state='attivo' AND(a.mechanics_snapshot->>'vita')::integer>0
 JOIN public.combat_v2_declarations own ON own.id=x.declaration_id AND own.controller_version_snapshot=a.controller_version AND own.controller_user_snapshot=a.controller_user
 JOIN public.combat_v2_actors t ON t.id=x.target_actor_id AND t.session_id=s.id AND t.state='attivo' AND(t.mechanics_snapshot->>'vita')::integer>0
 WHERE x.declaration_id=p_declaration AND x.state IN('prepared','active') AND x.profile_sha256=public.combat_v2_sha256(x.profile)
 AND n.launch_sha256=x.profile->>'chain_version' AND e.source_declaration_id::text=x.profile->>'parent_declaration'
 AND combat_panel_private.nara_frozen_segment_current_v1(x.session_id,e.source_declaration_id,combat_panel_private.nara_frozen_launch_v1(e.source_declaration_id)))
$f$;
CREATE FUNCTION clan_aburame_private.verme_staff_scope_v1(p_actor uuid)
RETURNS boolean LANGUAGE sql STABLE SECURITY DEFINER SET search_path='' AS $f$
 SELECT CASE WHEN EXISTS(SELECT 1 FROM clan_aburame_private.verme_gate_v1 WHERE singleton AND staff_enabled)
 AND combat_panel_private.cure_staff_execution_scope_v1(p_actor)AND combat_panel_private.nara_adv_pool_v1((SELECT session_id FROM public.combat_v2_actors WHERE id=p_actor)) THEN clan_aburame_private.verme_release_v1() ELSE false END
 AND EXISTS(SELECT 1 FROM public.combat_v2_actors a JOIN public.combat_v2_sessions s ON s.id=a.session_id
 WHERE a.id=p_actor AND a.state='attivo' AND s.closed_at IS NULL
 AND combat_panel_private.uses_simulated_pools(s.id) AND NOT public.combat_v2_values_written(s.id))
$f$;
CREATE OR REPLACE FUNCTION clan_akimichi_private.cellular_mark_v1(p_defense uuid,p_native jsonb)
RETURNS jsonb LANGUAGE sql STABLE SECURITY DEFINER SET search_path='' AS $fn$
 SELECT CASE WHEN clan_akimichi_private.cellular_source_valid_v1(p_defense)
 THEN p_native||jsonb_build_object('akimichi_cellular_source',p_defense) ELSE p_native END
$fn$;
CREATE FUNCTION combat_panel_private.nara_adv_protected_v1(p_actor uuid) RETURNS boolean LANGUAGE sql STABLE SECURITY DEFINER SET search_path='' AS $f$
 SELECT EXISTS(SELECT 1 FROM public.combat_v2_actors a JOIN public.combat_v2_sessions s ON s.id=a.session_id
 WHERE a.id=p_actor AND combat_panel_private.nara_staff_scope_v1(a.id) AND combat_panel_private.nara_adv_pool_v1(a.session_id) AND a.actor_kind='pg' AND a.companion_id IS NULL
 AND a.character_id IN('2a877f02-4993-4e65-9172-7d29f08c5b86','6bceee99-974f-426b-8d92-38b43b4a4267')
 AND (SELECT count(*) FROM public.combat_v2_actors q WHERE q.session_id=s.id)=2
 AND NOT EXISTS(SELECT 1 FROM public.combat_v2_actors q WHERE q.session_id=s.id AND(q.actor_kind<>'pg' OR q.companion_id IS NOT NULL OR q.character_id NOT IN('2a877f02-4993-4e65-9172-7d29f08c5b86','6bceee99-974f-426b-8d92-38b43b4a4267'))))
$f$;
CREATE OR REPLACE FUNCTION clan_akimichi_private.common_source_root_v1()
RETURNS jsonb LANGUAGE sql STABLE SECURITY DEFINER SET search_path='' AS $fn$
WITH expected_functions(signature) AS(VALUES
('clan_akimichi_private.cellular_attack_eligible_v1(uuid,uuid)'),
('clan_akimichi_private.cellular_bind_v1(uuid)'),
('clan_akimichi_private.cellular_calculate_v1(uuid,jsonb,integer,integer)'),
('clan_akimichi_private.cellular_mark_v1(uuid,jsonb)'),
('clan_akimichi_private.cellular_meta_v1(uuid)'),
('clan_akimichi_private.cellular_pay_v1(uuid)'),
('clan_akimichi_private.cellular_snapshot_v1(uuid,jsonb)'),
('clan_akimichi_private.cellular_source_valid_v1(uuid)'),
('clan_akimichi_private.common_admit_calories_v1(uuid)'),
('clan_akimichi_private.common_attack_power_freeze_v1(uuid)'),
('clan_akimichi_private.common_calorie_balance_v1(uuid,uuid,uuid,uuid)'),
('clan_akimichi_private.common_defer_upkeep_v1(uuid,uuid)'),
('clan_akimichi_private.common_flush_upkeep_v1(uuid)'),
('clan_akimichi_private.common_modifiers_v1(text,integer,integer,integer)'),
('clan_akimichi_private.common_panel_commit_v1(jsonb)'),
('clan_akimichi_private.common_panel_offers_v1(uuid,bigint,jsonb)'),
('clan_akimichi_private.common_preflight_calories_v1(uuid)'),
('clan_akimichi_private.common_prepare_staff_v1(uuid,uuid,uuid)'),
('clan_akimichi_private.common_result_label_v1(jsonb)'),
('clan_akimichi_private.common_scope_v1(uuid,uuid)'),
('clan_akimichi_private.common_set_form_v1(uuid,uuid,text)'),
('clan_akimichi_private.common_source_root_v1()'),
('clan_akimichi_private.common_staff_scope_v1(uuid)'),
('clan_akimichi_private.super_direct_visible_v1(uuid,uuid)')), expected_tables(name) AS(VALUES
('clan_akimichi_private.cellular_sources_v1'),
('clan_akimichi_private.common_attack_powers_v1'),
('clan_akimichi_private.common_form_commands_v1'),
('clan_akimichi_private.common_gate_v1'),
('clan_akimichi_private.common_pending_upkeep_v1'),
('clan_akimichi_private.common_staff_profiles_v1')), function_objects AS(
 SELECT e.signature,p.oid,md5(pg_get_functiondef(p.oid)) body_md5,
 public.combat_v2_sha256(to_jsonb(pg_get_functiondef(p.oid))) body_json_sha256,
 pg_get_userbyid(p.proowner) owner_name,to_jsonb(p.proacl) acl,p.prosecdef security_definer,p.proconfig config
 FROM expected_functions e LEFT JOIN pg_proc p ON p.oid=to_regprocedure(e.signature)
), table_objects AS(
 SELECT e.name,c.oid,pg_get_userbyid(c.relowner) owner_name,to_jsonb(c.relacl) acl,c.relrowsecurity rls,
 (SELECT jsonb_agg(jsonb_build_object('name',a.attname,'type',format_type(a.atttypid,a.atttypmod),'not_null',a.attnotnull,
  'default',pg_get_expr(d.adbin,d.adrelid)) ORDER BY a.attnum)
 FROM pg_attribute a LEFT JOIN pg_attrdef d ON d.adrelid=a.attrelid AND d.adnum=a.attnum
 WHERE a.attrelid=c.oid AND a.attnum>0 AND NOT a.attisdropped) columns,
 (SELECT jsonb_agg(jsonb_build_object('name',q.conname,'definition',pg_get_constraintdef(q.oid)) ORDER BY q.conname)
 FROM pg_constraint q WHERE q.conrelid=c.oid) constraints,
 (SELECT jsonb_agg(pg_get_indexdef(i.indexrelid) ORDER BY i.indexrelid::regclass::text)
 FROM pg_index i WHERE i.indrelid=c.oid) indexes,
 (SELECT jsonb_agg(jsonb_build_object('name',pol.polname,'command',pol.polcmd,'roles',pol.polroles,
  'using',pg_get_expr(pol.polqual,pol.polrelid),'check',pg_get_expr(pol.polwithcheck,pol.polrelid)) ORDER BY pol.polname)
 FROM pg_policy pol WHERE pol.polrelid=c.oid) policies
 FROM expected_tables e LEFT JOIN pg_class c ON c.oid=to_regclass(e.name)
), material AS(SELECT jsonb_build_object('contract','akimichi-common/1',
 'functions',(SELECT jsonb_agg(to_jsonb(f)-'oid' ORDER BY signature) FROM function_objects f),
 'tables',(SELECT jsonb_agg(to_jsonb(t)-'oid' ORDER BY name) FROM table_objects t),
 'form_kind_column',(SELECT jsonb_build_object('type',data_type,'nullable',is_nullable,'default',column_default)
   FROM information_schema.columns WHERE table_schema='clan_akimichi_private' AND table_name='forms' AND column_name='form_kind'),
 'form_kind_constraint',(SELECT pg_get_constraintdef(q.oid) FROM pg_constraint q WHERE q.conrelid='clan_akimichi_private.forms'::regclass AND q.conname='akimichi_form_kind_v1'),
 'gate',(SELECT to_jsonb(g) FROM clan_akimichi_private.common_gate_v1 g WHERE singleton),
 'catalog',(SELECT jsonb_agg(jsonb_build_object('id',t.id,'sha256',public.combat_v2_sha256(to_jsonb(t))) ORDER BY t.id)
   FROM public.clan_techniques t WHERE id IN('f5f26cb5-9b6f-44b3-94bc-c329a0a88b93','687b058a-807d-4cf7-8bcf-21147931b0f6'))) m)
 SELECT jsonb_build_object('version','akimichi-common-source-root/1','component_sha256',public.combat_v2_sha256(m),
 'function_count',(SELECT count(oid) FROM function_objects),'table_count',(SELECT count(oid) FROM table_objects),
 'complete',(SELECT count(oid)=24 FROM function_objects) AND(SELECT count(oid)=6 AND bool_and(rls) FROM table_objects)
  AND jsonb_typeof(m->'form_kind_column')='object' AND jsonb_typeof(m->'form_kind_constraint')='string' AND jsonb_array_length(m->'catalog')=2)
 FROM material
$fn$;
CREATE FUNCTION combat_panel_private.nara_adv_scope_v1(p_actor uuid) RETURNS boolean LANGUAGE sql STABLE SECURITY DEFINER SET search_path='' AS $f$ SELECT combat_panel_private.nara_adv_protected_v1(p_actor) AND EXISTS(SELECT 1 FROM combat_panel_private.nara_adv_gate_v1 WHERE singleton AND staff_enabled AND NOT public_enabled) $f$;
CREATE TRIGGER staff_nb_origin_immutable BEFORE UPDATE ON combat_v2_staff_nb_internal.roster_sources
 FOR EACH ROW EXECUTE FUNCTION combat_v2_staff_nb_internal.origin_guard();
CREATE TRIGGER aburame_verme_end_session_v1 AFTER UPDATE OF state,closed_at ON public.combat_v2_sessions
 FOR EACH ROW EXECUTE FUNCTION clan_aburame_private.verme_end_context_v1();
CREATE TRIGGER aburame_verme_end_actor_v1 AFTER UPDATE OF state ON public.combat_v2_actors
 FOR EACH ROW EXECUTE FUNCTION clan_aburame_private.verme_end_context_v1();
CREATE TRIGGER nara_strangle_snapshot_guard_v1 BEFORE UPDATE OR DELETE ON combat_panel_private.nara_strangle_sources_v1 FOR EACH ROW EXECUTE FUNCTION combat_panel_private.nara_adv_history_guard_v1();
CREATE TRIGGER nara_strangle_events_guard_v1 BEFORE UPDATE OR DELETE ON combat_panel_private.nara_strangle_events_v1 FOR EACH ROW EXECUTE FUNCTION combat_panel_private.nara_adv_history_guard_v1();
CREATE TRIGGER nara_strangle_staff_guard_v1 BEFORE UPDATE OR DELETE ON combat_panel_private.nara_adv_staff_v1 FOR EACH ROW EXECUTE FUNCTION combat_panel_private.nara_adv_history_guard_v1();
CREATE TRIGGER nara_strangle_ended_event_v1 AFTER UPDATE OF state ON combat_panel_private.nara_strangle_sources_v1 FOR EACH ROW WHEN(OLD.state IS DISTINCT FROM NEW.state AND NEW.state='ended')EXECUTE FUNCTION combat_panel_private.nara_strangle_end_event_v1();
CREATE TRIGGER nara_strangle_parent_end_v1 AFTER UPDATE OF state ON combat_panel_private.immobilizations FOR EACH ROW WHEN(OLD.state IS DISTINCT FROM NEW.state) EXECUTE FUNCTION combat_panel_private.nara_strangle_lifecycle_trigger_v1();
CREATE TRIGGER nara_strangle_geometry_end_v1 AFTER UPDATE OF x_m,y_m,state ON combat_spatial.actor_states FOR EACH ROW WHEN(OLD.x_m IS DISTINCT FROM NEW.x_m OR OLD.y_m IS DISTINCT FROM NEW.y_m OR OLD.state IS DISTINCT FROM NEW.state) EXECUTE FUNCTION combat_panel_private.nara_strangle_lifecycle_trigger_v1();
REVOKE ALL ON SCHEMA combat_v2_staff_nb_internal FROM PUBLIC,anon,authenticated,service_role;
GRANT USAGE ON SCHEMA combat_v2_staff_nb_internal TO postgres;
REVOKE ALL ON combat_v2_staff_nb_internal.gate FROM PUBLIC,anon,authenticated,service_role;
REVOKE ALL ON combat_v2_staff_nb_internal.roster_sources FROM PUBLIC,anon,authenticated,service_role;
REVOKE ALL ON combat_v2_staff_nb_internal.admissions FROM PUBLIC,anon,authenticated,service_role;
GRANT SELECT,UPDATE ON combat_v2_staff_nb_internal.gate TO postgres;
GRANT SELECT,INSERT,UPDATE ON combat_v2_staff_nb_internal.roster_sources,combat_v2_staff_nb_internal.admissions TO postgres;
REVOKE ALL ON FUNCTION combat_v2_staff_nb_internal.origin_guard() FROM PUBLIC,anon,authenticated,service_role;
GRANT EXECUTE ON FUNCTION combat_v2_staff_nb_internal.origin_guard() TO postgres;
REVOKE ALL ON FUNCTION combat_v2_staff_nb_internal.preparation_allowed(uuid) FROM PUBLIC,anon,authenticated,service_role;
GRANT EXECUTE ON FUNCTION combat_v2_staff_nb_internal.preparation_allowed(uuid) TO postgres;
REVOKE ALL ON FUNCTION combat_v2_staff_nb_internal.choice(uuid) FROM PUBLIC,anon,authenticated,service_role;
GRANT EXECUTE ON FUNCTION combat_v2_staff_nb_internal.choice(uuid) TO postgres;
REVOKE ALL ON FUNCTION combat_v2_staff_nb_internal.roster_offers(uuid,bigint,uuid) FROM PUBLIC,anon,authenticated,service_role;
GRANT EXECUTE ON FUNCTION combat_v2_staff_nb_internal.roster_offers(uuid,bigint,uuid) TO postgres;
REVOKE ALL ON FUNCTION combat_v2_staff_nb_internal.native_construct(uuid,uuid[],jsonb,jsonb,uuid,uuid) FROM PUBLIC,anon,authenticated,service_role;
GRANT EXECUTE ON FUNCTION combat_v2_staff_nb_internal.native_construct(uuid,uuid[],jsonb,jsonb,uuid,uuid) TO postgres;
REVOKE ALL ON FUNCTION combat_v2_staff_nb_internal.mechanics_ready(uuid) FROM PUBLIC,anon,authenticated,service_role;
GRANT EXECUTE ON FUNCTION combat_v2_staff_nb_internal.mechanics_ready(uuid) TO postgres;
REVOKE ALL ON FUNCTION combat_v2_staff_nb_internal.setup_protected(uuid,uuid) FROM PUBLIC,anon,authenticated,service_role;
GRANT EXECUTE ON FUNCTION combat_v2_staff_nb_internal.setup_protected(uuid,uuid) TO postgres;
REVOKE ALL ON FUNCTION combat_v2_staff_nb_internal.commit_roster(jsonb) FROM PUBLIC,anon,authenticated,service_role;
GRANT EXECUTE ON FUNCTION combat_v2_staff_nb_internal.commit_roster(jsonb) TO postgres;
REVOKE ALL ON FUNCTION combat_v2_staff_nb_internal.roster_receipt(uuid) FROM PUBLIC,anon,authenticated,service_role;
GRANT EXECUTE ON FUNCTION combat_v2_staff_nb_internal.roster_receipt(uuid) TO postgres;
REVOKE ALL ON FUNCTION combat_v2_staff_nb_internal.pg_scope(uuid) FROM PUBLIC,anon,authenticated,service_role;
GRANT EXECUTE ON FUNCTION combat_v2_staff_nb_internal.pg_scope(uuid) TO postgres;
REVOKE ALL ON FUNCTION combat_v2_staff_nb_internal.kai_frozen_authority(uuid) FROM PUBLIC,anon,authenticated,service_role;
GRANT EXECUTE ON FUNCTION combat_v2_staff_nb_internal.kai_frozen_authority(uuid) TO postgres;
REVOKE ALL ON FUNCTION combat_v2_staff_nb_internal.kai_authority(uuid) FROM PUBLIC,anon,authenticated,service_role;
GRANT EXECUTE ON FUNCTION combat_v2_staff_nb_internal.kai_authority(uuid) TO postgres;
REVOKE ALL ON FUNCTION combat_v2_staff_nb_internal.kai_contact(uuid,uuid) FROM PUBLIC,anon,authenticated,service_role;
GRANT EXECUTE ON FUNCTION combat_v2_staff_nb_internal.kai_contact(uuid,uuid) TO postgres;
REVOKE ALL ON clan_aburame_private.verme_gate_v1,clan_aburame_private.verme_staff_profiles_v1,
 clan_aburame_private.verme_sources_v1,clan_aburame_private.verme_poison_v1,clan_aburame_private.verme_events_v1
 FROM PUBLIC,anon,authenticated,service_role;
-- Solo chiamanti server proprietari: nessuna RPC, tabella o funzione nuova visibile al client.
REVOKE ALL ON FUNCTION clan_aburame_private.verme_manifest_v1(),clan_aburame_private.verme_release_v1(),clan_aburame_private.verme_staff_scope_v1(uuid),clan_aburame_private.verme_scope_v1(uuid),
 clan_aburame_private.verme_event_v1(text,uuid,uuid,uuid,uuid,uuid,text,jsonb),clan_aburame_private.verme_staff_prepare_v1(uuid,uuid),
 clan_aburame_private.verme_meta_v1(uuid,boolean),clan_aburame_private.verme_bind_v1(uuid),clan_aburame_private.verme_frozen_v1(uuid),
 clan_aburame_private.verme_finish_v1(uuid,uuid,boolean,integer),clan_aburame_private.verme_tick_v1(uuid,uuid,uuid,text),
 clan_aburame_private.verme_end_context_v1(),clan_aburame_private.verme_report_v1(uuid,uuid),
 clan_aburame_private.verme_reserve_round_v1(uuid),clan_aburame_private.verme_settle_round_v1(uuid),
 clan_aburame_private.verme_narrative_v1(uuid,uuid) FROM PUBLIC,anon,authenticated,service_role;
REVOKE ALL ON TABLE clan_akimichi_private.common_gate_v1 FROM PUBLIC,anon,authenticated,service_role;
GRANT ALL ON TABLE clan_akimichi_private.common_gate_v1 TO postgres;
REVOKE ALL ON TABLE clan_akimichi_private.common_staff_profiles_v1 FROM PUBLIC,anon,authenticated,service_role;
GRANT ALL ON TABLE clan_akimichi_private.common_staff_profiles_v1 TO postgres;
REVOKE ALL ON TABLE clan_akimichi_private.common_form_commands_v1 FROM PUBLIC,anon,authenticated,service_role;
GRANT ALL ON TABLE clan_akimichi_private.common_form_commands_v1 TO postgres;
REVOKE ALL ON TABLE clan_akimichi_private.common_attack_powers_v1 FROM PUBLIC,anon,authenticated,service_role;
GRANT ALL ON TABLE clan_akimichi_private.common_attack_powers_v1 TO postgres;
REVOKE ALL ON TABLE clan_akimichi_private.common_pending_upkeep_v1 FROM PUBLIC,anon,authenticated,service_role;
GRANT ALL ON TABLE clan_akimichi_private.common_pending_upkeep_v1 TO postgres;
REVOKE ALL ON TABLE clan_akimichi_private.cellular_sources_v1 FROM PUBLIC,anon,authenticated,service_role;
GRANT ALL ON TABLE clan_akimichi_private.cellular_sources_v1 TO postgres;
REVOKE ALL ON FUNCTION clan_akimichi_private.common_staff_scope_v1(uuid) FROM PUBLIC,anon,authenticated,service_role;
GRANT EXECUTE ON FUNCTION clan_akimichi_private.common_staff_scope_v1(uuid) TO postgres;
REVOKE ALL ON FUNCTION clan_akimichi_private.common_scope_v1(uuid,uuid) FROM PUBLIC,anon,authenticated,service_role;
GRANT EXECUTE ON FUNCTION clan_akimichi_private.common_scope_v1(uuid,uuid) TO postgres;
REVOKE ALL ON FUNCTION clan_akimichi_private.common_prepare_staff_v1(uuid,uuid,uuid) FROM PUBLIC,anon,authenticated,service_role;
GRANT EXECUTE ON FUNCTION clan_akimichi_private.common_prepare_staff_v1(uuid,uuid,uuid) TO postgres;
REVOKE ALL ON FUNCTION clan_akimichi_private.common_modifiers_v1(text,integer,integer,integer) FROM PUBLIC,anon,authenticated,service_role;
GRANT EXECUTE ON FUNCTION clan_akimichi_private.common_modifiers_v1(text,integer,integer,integer) TO postgres;
REVOKE ALL ON FUNCTION clan_akimichi_private.common_set_form_v1(uuid,uuid,text) FROM PUBLIC,anon,authenticated,service_role;
GRANT EXECUTE ON FUNCTION clan_akimichi_private.common_set_form_v1(uuid,uuid,text) TO postgres;
REVOKE ALL ON FUNCTION clan_akimichi_private.common_defer_upkeep_v1(uuid,uuid) FROM PUBLIC,anon,authenticated,service_role;
GRANT EXECUTE ON FUNCTION clan_akimichi_private.common_defer_upkeep_v1(uuid,uuid) TO postgres;
REVOKE ALL ON FUNCTION clan_akimichi_private.common_flush_upkeep_v1(uuid) FROM PUBLIC,anon,authenticated,service_role;
GRANT EXECUTE ON FUNCTION clan_akimichi_private.common_flush_upkeep_v1(uuid) TO postgres;
REVOKE ALL ON FUNCTION clan_akimichi_private.cellular_meta_v1(uuid) FROM PUBLIC,anon,authenticated,service_role;
GRANT EXECUTE ON FUNCTION clan_akimichi_private.cellular_meta_v1(uuid) TO postgres;
REVOKE ALL ON FUNCTION clan_akimichi_private.cellular_attack_eligible_v1(uuid,uuid) FROM PUBLIC,anon,authenticated,service_role;
GRANT EXECUTE ON FUNCTION clan_akimichi_private.cellular_attack_eligible_v1(uuid,uuid) TO postgres;
REVOKE ALL ON FUNCTION clan_akimichi_private.cellular_bind_v1(uuid) FROM PUBLIC,anon,authenticated,service_role;
GRANT EXECUTE ON FUNCTION clan_akimichi_private.cellular_bind_v1(uuid) TO postgres;
REVOKE ALL ON FUNCTION clan_akimichi_private.cellular_source_valid_v1(uuid) FROM PUBLIC,anon,authenticated,service_role;
GRANT EXECUTE ON FUNCTION clan_akimichi_private.cellular_source_valid_v1(uuid) TO postgres;
REVOKE ALL ON FUNCTION clan_akimichi_private.cellular_pay_v1(uuid) FROM PUBLIC,anon,authenticated,service_role;
GRANT EXECUTE ON FUNCTION clan_akimichi_private.cellular_pay_v1(uuid) TO postgres;
REVOKE ALL ON FUNCTION clan_akimichi_private.cellular_snapshot_v1(uuid,jsonb) FROM PUBLIC,anon,authenticated,service_role;
GRANT EXECUTE ON FUNCTION clan_akimichi_private.cellular_snapshot_v1(uuid,jsonb) TO postgres;
REVOKE ALL ON FUNCTION clan_akimichi_private.cellular_mark_v1(uuid,jsonb) FROM PUBLIC,anon,authenticated,service_role;
GRANT EXECUTE ON FUNCTION clan_akimichi_private.cellular_mark_v1(uuid,jsonb) TO postgres;
REVOKE ALL ON FUNCTION clan_akimichi_private.cellular_calculate_v1(uuid,jsonb,integer,integer) FROM PUBLIC,anon,authenticated,service_role;
GRANT EXECUTE ON FUNCTION clan_akimichi_private.cellular_calculate_v1(uuid,jsonb,integer,integer) TO postgres;
REVOKE ALL ON FUNCTION clan_akimichi_private.common_calorie_balance_v1(uuid,uuid,uuid,uuid) FROM PUBLIC,anon,authenticated,service_role;
GRANT EXECUTE ON FUNCTION clan_akimichi_private.common_calorie_balance_v1(uuid,uuid,uuid,uuid) TO postgres;
REVOKE ALL ON FUNCTION clan_akimichi_private.common_admit_calories_v1(uuid) FROM PUBLIC,anon,authenticated,service_role;
GRANT EXECUTE ON FUNCTION clan_akimichi_private.common_admit_calories_v1(uuid) TO postgres;
REVOKE ALL ON FUNCTION clan_akimichi_private.common_preflight_calories_v1(uuid) FROM PUBLIC,anon,authenticated,service_role;
GRANT EXECUTE ON FUNCTION clan_akimichi_private.common_preflight_calories_v1(uuid) TO postgres;
REVOKE ALL ON FUNCTION clan_akimichi_private.super_direct_visible_v1(uuid,uuid) FROM PUBLIC,anon,authenticated,service_role;
GRANT EXECUTE ON FUNCTION clan_akimichi_private.super_direct_visible_v1(uuid,uuid) TO postgres;
REVOKE ALL ON FUNCTION clan_akimichi_private.common_attack_power_freeze_v1(uuid) FROM PUBLIC,anon,authenticated,service_role;
GRANT EXECUTE ON FUNCTION clan_akimichi_private.common_attack_power_freeze_v1(uuid) TO postgres;
REVOKE ALL ON FUNCTION clan_akimichi_private.common_panel_offers_v1(uuid,bigint,jsonb) FROM PUBLIC,anon,authenticated,service_role;
GRANT EXECUTE ON FUNCTION clan_akimichi_private.common_panel_offers_v1(uuid,bigint,jsonb) TO postgres;
REVOKE ALL ON FUNCTION clan_akimichi_private.common_panel_commit_v1(jsonb) FROM PUBLIC,anon,authenticated,service_role;
GRANT EXECUTE ON FUNCTION clan_akimichi_private.common_panel_commit_v1(jsonb) TO postgres;
REVOKE ALL ON FUNCTION clan_akimichi_private.common_result_label_v1(jsonb) FROM PUBLIC,anon,authenticated,service_role;
GRANT EXECUTE ON FUNCTION clan_akimichi_private.common_result_label_v1(jsonb) TO postgres;
REVOKE ALL ON FUNCTION clan_akimichi_private.common_source_root_v1() FROM PUBLIC,anon,authenticated,service_role;
GRANT EXECUTE ON FUNCTION clan_akimichi_private.common_source_root_v1() TO postgres;
REVOKE ALL ON TABLE combat_panel_private.nara_adv_gate_v1 FROM PUBLIC,anon,authenticated,service_role;
GRANT ALL ON TABLE combat_panel_private.nara_adv_gate_v1 TO postgres;
REVOKE ALL ON TABLE combat_panel_private.nara_adv_staff_v1 FROM PUBLIC,anon,authenticated,service_role;
GRANT ALL ON TABLE combat_panel_private.nara_adv_staff_v1 TO postgres;
REVOKE ALL ON TABLE combat_panel_private.nara_strangle_sources_v1 FROM PUBLIC,anon,authenticated,service_role;
GRANT ALL ON TABLE combat_panel_private.nara_strangle_sources_v1 TO postgres;
REVOKE ALL ON TABLE combat_panel_private.nara_strangle_events_v1 FROM PUBLIC,anon,authenticated,service_role;
GRANT ALL ON TABLE combat_panel_private.nara_strangle_events_v1 TO postgres;
REVOKE ALL ON FUNCTION clan_sabaku_private.armor_absorb_packet_v1(uuid,uuid,uuid,uuid,integer) FROM PUBLIC,anon,authenticated,service_role;
GRANT EXECUTE ON FUNCTION clan_sabaku_private.armor_absorb_packet_v1(uuid,uuid,uuid,uuid,integer) TO postgres;
REVOKE ALL ON FUNCTION combat_panel_private.nara_adv_pool_v1(uuid) FROM PUBLIC,anon,authenticated,service_role;
GRANT EXECUTE ON FUNCTION combat_panel_private.nara_adv_pool_v1(uuid) TO postgres;
REVOKE ALL ON FUNCTION combat_panel_private.nara_adv_protected_v1(uuid) FROM PUBLIC,anon,authenticated,service_role;
GRANT EXECUTE ON FUNCTION combat_panel_private.nara_adv_protected_v1(uuid) TO postgres;
REVOKE ALL ON FUNCTION combat_panel_private.nara_adv_scope_v1(uuid) FROM PUBLIC,anon,authenticated,service_role;
GRANT EXECUTE ON FUNCTION combat_panel_private.nara_adv_scope_v1(uuid) TO postgres;
REVOKE ALL ON FUNCTION combat_panel_private.nara_adv_prepare_v1(uuid,uuid) FROM PUBLIC,anon,authenticated,service_role;
GRANT EXECUTE ON FUNCTION combat_panel_private.nara_adv_prepare_v1(uuid,uuid) TO postgres;
REVOKE ALL ON FUNCTION combat_panel_private.nara_strangle_meta_v1(uuid) FROM PUBLIC,anon,authenticated,service_role;
GRANT EXECUTE ON FUNCTION combat_panel_private.nara_strangle_meta_v1(uuid) TO postgres;
REVOKE ALL ON FUNCTION combat_panel_private.nara_strangle_action_meta_v1(uuid,uuid,jsonb) FROM PUBLIC,anon,authenticated,service_role;
GRANT EXECUTE ON FUNCTION combat_panel_private.nara_strangle_action_meta_v1(uuid,uuid,jsonb) TO postgres;
REVOKE ALL ON FUNCTION combat_panel_private.nara_strangle_bind_v1(uuid) FROM PUBLIC,anon,authenticated,service_role;
GRANT EXECUTE ON FUNCTION combat_panel_private.nara_strangle_bind_v1(uuid) TO postgres;
REVOKE ALL ON FUNCTION combat_panel_private.nara_strangle_parent_valid_v1(uuid) FROM PUBLIC,anon,authenticated,service_role;
GRANT EXECUTE ON FUNCTION combat_panel_private.nara_strangle_parent_valid_v1(uuid) TO postgres;
REVOKE ALL ON FUNCTION combat_panel_private.nara_strangle_lifecycle_v1(uuid) FROM PUBLIC,anon,authenticated,service_role;
GRANT EXECUTE ON FUNCTION combat_panel_private.nara_strangle_lifecycle_v1(uuid) TO postgres;
REVOKE ALL ON FUNCTION combat_panel_private.nara_strangle_packet_v1(uuid,uuid,uuid,text) FROM PUBLIC,anon,authenticated,service_role;
GRANT EXECUTE ON FUNCTION combat_panel_private.nara_strangle_packet_v1(uuid,uuid,uuid,text) TO postgres;
REVOKE ALL ON FUNCTION combat_panel_private.nara_strangle_resolve_v1(uuid) FROM PUBLIC,anon,authenticated,service_role;
GRANT EXECUTE ON FUNCTION combat_panel_private.nara_strangle_resolve_v1(uuid) TO postgres;
REVOKE ALL ON FUNCTION combat_panel_private.nara_strangle_turn_v1(uuid,uuid,uuid,text) FROM PUBLIC,anon,authenticated,service_role;
GRANT EXECUTE ON FUNCTION combat_panel_private.nara_strangle_turn_v1(uuid,uuid,uuid,text) TO postgres;
REVOKE ALL ON FUNCTION combat_panel_private.nara_strangle_facts_revision_v1(jsonb) FROM PUBLIC,anon,authenticated,service_role;
GRANT EXECUTE ON FUNCTION combat_panel_private.nara_strangle_facts_revision_v1(jsonb) TO postgres;
REVOKE ALL ON FUNCTION combat_panel_private.nara_strangle_facts_v1(uuid,uuid) FROM PUBLIC,anon,authenticated,service_role;
GRANT EXECUTE ON FUNCTION combat_panel_private.nara_strangle_facts_v1(uuid,uuid) TO postgres;
REVOKE ALL ON FUNCTION combat_panel_private.nara_adv_history_guard_v1() FROM PUBLIC,anon,authenticated,service_role;
GRANT EXECUTE ON FUNCTION combat_panel_private.nara_adv_history_guard_v1() TO postgres;
REVOKE ALL ON FUNCTION combat_panel_private.nara_strangle_end_event_v1() FROM PUBLIC,anon,authenticated,service_role;
GRANT EXECUTE ON FUNCTION combat_panel_private.nara_strangle_end_event_v1() TO postgres;
REVOKE ALL ON FUNCTION combat_panel_private.nara_strangle_terminal_report_v1(uuid) FROM PUBLIC,anon,authenticated,service_role;
GRANT EXECUTE ON FUNCTION combat_panel_private.nara_strangle_terminal_report_v1(uuid) TO postgres;
REVOKE ALL ON FUNCTION combat_panel_private.nara_strangle_lifecycle_context_v1(uuid) FROM PUBLIC,anon,authenticated,service_role;
GRANT EXECUTE ON FUNCTION combat_panel_private.nara_strangle_lifecycle_context_v1(uuid) TO postgres;
REVOKE ALL ON FUNCTION combat_panel_private.nara_adv_offers_v1(uuid,bigint,jsonb) FROM PUBLIC,anon,authenticated,service_role;
GRANT EXECUTE ON FUNCTION combat_panel_private.nara_adv_offers_v1(uuid,bigint,jsonb) TO postgres;
REVOKE ALL ON FUNCTION combat_panel_private.nara_adv_commit_v1(jsonb) FROM PUBLIC,anon,authenticated,service_role;
GRANT EXECUTE ON FUNCTION combat_panel_private.nara_adv_commit_v1(jsonb) TO postgres;
REVOKE ALL ON FUNCTION combat_panel_private.nara_strangle_lifecycle_trigger_v1() FROM PUBLIC,anon,authenticated,service_role;
GRANT EXECUTE ON FUNCTION combat_panel_private.nara_strangle_lifecycle_trigger_v1() TO postgres;
CREATE OR REPLACE FUNCTION clan_aburame_private.actor_ability(p_actor uuid, p_source text, p_ability uuid, p_defense boolean, p_fallback jsonb)
 RETURNS jsonb
 LANGUAGE plpgsql
 STABLE SECURITY DEFINER
 SET search_path TO ''
AS $function$
DECLARE ct public.clan_techniques%ROWTYPE;
BEGIN
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
 IF family<>'akimichi-partial/1' THEN power:=power+clan_akimichi_private.body_attack_mass(d.id); END IF;
 element:=lower(coalesce(prof->>'element',d.sanitized_intent#>>'{server_ability,element}',''));
 IF power IS NULL OR power<1 THEN RETURN NULL;END IF;
 RETURN jsonb_build_object('version','aburame-attack-power/1','declaration_id',d.id,'family',family,'power',power,
  'element',CASE WHEN element IN ('fuoco','katon') THEN 'katon' WHEN element IN ('fulmine','raiton') THEN 'raiton' WHEN element IN ('acqua','suiton') THEN 'suiton' ELSE NULL END,
  'source_sha256',public.combat_v2_sha256(jsonb_build_object('declaration_id',d.id,'family',family,'power',power,'profile',prof)));
END $function$;
CREATE OR REPLACE FUNCTION clan_aburame_private.commit_control(p jsonb, prepared jsonb, p_ctx combat_consumer_private.activities, p_offer combat_consumer_private.offers, p_event uuid)
 RETURNS jsonb
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO ''
AS $function$
DECLARE actor uuid:=(prepared->>'actor_id')::uuid;cid uuid:=(prepared->>'principal_character_id')::uuid;key uuid:=(p->>'request_key')::uuid;env jsonb;receipt jsonb;label jsonb;
BEGIN
 IF p_offer.source_payload->>'aburame_operation'='verme_staff_prepare' THEN
  PERFORM clan_aburame_private.verme_staff_prepare_v1(actor,key);
 ELSIF p_offer.source_payload->>'aburame_operation'='release_stop' THEN
  PERFORM clan_aburame_private.stop_release(actor,(p_offer.source_payload->>'source_id')::uuid);
 ELSE RAISE EXCEPTION 'aburame_control_operation_invalid'; END IF;
 UPDATE combat_consumer_private.activities SET context_version=context_version+1,last_action_at=clock_timestamp() WHERE session_id=p_ctx.session_id;
 UPDATE combat_consumer_private.offers SET state='consumed',consumed_request_key=key WHERE id=p_offer.id;
 env:=combat_consumer_private.state_projection(p_ctx.location_id);label:=combat_consumer_private.display_label(p_ctx.session_id,actor,actor,NULL);
 receipt:=jsonb_build_object('receipt_id',p_event,'request_key',key,'operation','control','replayed',false,'activity_id',p_ctx.session_id,'exchange_id',p_ctx.exchange_id,'context_version_before',p_ctx.context_version,'context_version_after',p_ctx.context_version+1,'declaration_id',NULL,'report_id',NULL,'report_sha256',NULL,'values_written',false,'display_events',jsonb_build_array(combat_consumer_private.validate_display_event(jsonb_build_object('event_id',p_event,'event_kind','control_changed','actor_id',actor,'display_name',label->>'display_name','label_version',label->'label_version','target_actor_id',NULL,'target_display_name',NULL,'target_label_version',NULL,'summary',CASE WHEN p_offer.source_payload->>'aburame_operation'='verme_staff_prepare' THEN 'Profilo Insetto Verme Velenoso pronto nella sola simulazione Staff.' ELSE 'Liberazione dei Kikaichū interrotta.' END))));
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
 IF o.source_payload->>'aburame_operation'='verme_staff_prepare' THEN
  result:=clan_aburame_private.verme_staff_prepare_v1(a.id,key);
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
  'target_actor_id',NULL,'target_display_name',NULL,'target_label_version',NULL,'summary',CASE WHEN o.source_payload->>'aburame_operation'='verme_staff_prepare' THEN 'Profilo Insetto Verme Velenoso pronto nella sola simulazione Staff.' ELSE 'Liberazione dei Kikaichū interrotta' END);
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
CREATE OR REPLACE FUNCTION clan_akimichi_private.apply_calorie_event(p_owner uuid, p_scope uuid, p_simulated boolean, p_event uuid, p_operation text, p_permanent_kg integer, p_permanent_resistance integer, p_meal_receipt uuid DEFAULT NULL::uuid, p_meal_at timestamp with time zone DEFAULT NULL::timestamp with time zone)
 RETURNS jsonb
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO ''
AS $function$
DECLARE
  r clan_akimichi_private.calorie_reserves%ROWTYPE;
  previous_receipt clan_akimichi_private.calorie_receipts%ROWTYPE;
  target_maximum integer;
  amount_before integer;
  amount_after integer;
  maximum_before integer;
  revision_before bigint;
  day_used date;
  day_for_meal date;
  successful_meal uuid;
  requested_cost integer;
  accepted boolean := true;
  reason text;
  event_request jsonb;
  event_result jsonb;
BEGIN
  IF p_owner IS NULL OR p_scope IS NULL OR p_event IS NULL OR p_simulated IS NULL
    OR (p_scope <> p_owner) IS DISTINCT FROM p_simulated
    OR p_operation IS NULL OR p_operation NOT IN
      ('initialize', 'reconcile_maximum', 'activate', 'upkeep', 'partial', 'meal', 'super_activate', 'super_upkeep', 'cellular')
    OR (p_operation = 'meal' AND (p_meal_receipt IS NULL OR p_meal_at IS NULL OR NOT isfinite(p_meal_at)))
    OR (p_operation <> 'meal' AND (p_meal_receipt IS NOT NULL OR p_meal_at IS NOT NULL))
  THEN
    RAISE EXCEPTION 'AKIMICHI_INVALID_CALORIE_EVENT' USING ERRCODE = '22023';
  END IF;

  target_maximum := clan_akimichi_private.calorie_maximum(p_permanent_kg, p_permanent_resistance);
  IF target_maximum IS NULL THEN
    RAISE EXCEPTION 'AKIMICHI_MISSING_PERMANENT_STATS' USING ERRCODE = '22023';
  END IF;
  event_request := jsonb_build_object(
    'operation', p_operation, 'simulated', p_simulated,
    'permanent_kg', p_permanent_kg, 'permanent_resistance', p_permanent_resistance,
    'meal_receipt', p_meal_receipt, 'meal_epoch', extract(epoch FROM p_meal_at)
  );

  IF p_operation = 'initialize' THEN
    INSERT INTO clan_akimichi_private.calorie_reserves(owner_id, scope_id, simulated, maximum, current_amount)
    VALUES (p_owner, p_scope, p_simulated, target_maximum, target_maximum)
    ON CONFLICT (owner_id, scope_id) DO NOTHING;
  END IF;

  SELECT * INTO r FROM clan_akimichi_private.calorie_reserves
  WHERE owner_id = p_owner AND scope_id = p_scope FOR UPDATE;
  IF NOT FOUND OR r.simulated IS DISTINCT FROM p_simulated THEN
    RAISE EXCEPTION 'AKIMICHI_RESERVE_NOT_INITIALIZED' USING ERRCODE = '55000';
  END IF;

  SELECT * INTO previous_receipt FROM clan_akimichi_private.calorie_receipts
  WHERE owner_id = p_owner AND scope_id = p_scope AND event_id = p_event;
  IF FOUND THEN
    IF previous_receipt.request IS DISTINCT FROM event_request THEN
      RAISE EXCEPTION 'AKIMICHI_EVENT_CONFLICT' USING ERRCODE = '40001';
    END IF;
    RETURN previous_receipt.result;
  END IF;

  amount_before := r.current_amount;
  amount_after := amount_before;
  maximum_before := r.maximum;
  revision_before := r.revision;
  day_used := r.refilled_day;

  CASE p_operation
    WHEN 'initialize' THEN
      target_maximum := maximum_before;
    WHEN 'reconcile_maximum' THEN
      amount_after := least(amount_before, target_maximum);
    ELSE
      IF target_maximum <> maximum_before THEN
        RAISE EXCEPTION 'AKIMICHI_MAXIMUM_RECONCILIATION_REQUIRED' USING ERRCODE = '55000';
      END IF;
      IF p_operation = 'meal' THEN
        day_for_meal := ((p_meal_at AT TIME ZONE 'Europe/Rome') - interval '6 hours')::date;
        IF day_used IS NOT NULL AND day_for_meal <= day_used THEN
          accepted := false;
          reason := 'daily_use_exhausted';
        ELSIF amount_before = maximum_before THEN
          accepted := false;
          reason := 'already_full';
        ELSE
          amount_after := maximum_before;
          day_used := day_for_meal;
          successful_meal := p_meal_receipt;
        END IF;
      ELSE
        requested_cost := CASE WHEN p_operation IN ('super_activate','super_upkeep') THEN 15 WHEN p_operation IN ('partial','cellular') THEN 10 ELSE 5 END;
        IF amount_before < requested_cost THEN
          accepted := false;
          reason := 'insufficient_calories';
        ELSE
          amount_after := amount_before - requested_cost;
        END IF;
      END IF;
  END CASE;

  IF (amount_after, target_maximum, day_used) IS DISTINCT FROM (amount_before, maximum_before, r.refilled_day) THEN
    UPDATE clan_akimichi_private.calorie_reserves
    SET current_amount = amount_after, maximum = target_maximum, refilled_day = day_used, revision = revision_before + 1
    WHERE owner_id = p_owner AND scope_id = p_scope RETURNING * INTO r;
  END IF;

  event_result := jsonb_build_object(
    'contract', 'akimichi-calorie-event/1', 'event_id', p_event, 'operation', p_operation,
    'accepted', accepted, 'reason', reason, 'delta', amount_after - amount_before,
    'current', r.current_amount, 'maximum', r.maximum, 'revision', r.revision
  );
  INSERT INTO clan_akimichi_private.calorie_receipts(owner_id, scope_id, event_id, request, result, meal_receipt_id)
  VALUES (p_owner, p_scope, p_event, event_request, event_result, successful_meal);
  RETURN event_result;
END;
$function$;
CREATE OR REPLACE FUNCTION clan_akimichi_private.begin_personal_turn(p_actor uuid, p_personal_turn uuid)
 RETURNS void
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO ''
AS $function$
DECLARE
  form clan_akimichi_private.forms%ROWTYPE;
  scope jsonb;
  debit jsonb;
  event_id uuid;
BEGIN
  SELECT * INTO form FROM clan_akimichi_private.forms WHERE actor_id = p_actor AND active FOR UPDATE;
  IF NOT FOUND OR form.last_paid_turn = p_personal_turn THEN RETURN; END IF;
  IF p_personal_turn IS NULL THEN RAISE EXCEPTION 'AKIMICHI_UPKEEP_TURN_MISSING' USING ERRCODE = '22023'; END IF;
  scope := CASE WHEN form.form_kind='super' THEN clan_akimichi_private.common_scope_v1(p_actor,'f5f26cb5-9b6f-44b3-94bc-c329a0a88b93') ELSE clan_akimichi_private.scope_for_actor(p_actor, '3b4c4fd0-c0c2-46a0-a387-f47a95ef7dda') END;
  IF scope IS NULL THEN
    UPDATE clan_akimichi_private.forms SET active = false, ended_reason = 'source_unavailable' WHERE actor_id = p_actor;
    RETURN;
  END IF;
  IF (scope->>'is_turn_owner')::boolean IS DISTINCT FROM true OR scope->>'phase' IS DISTINCT FROM 'action'
    OR (scope->>'turn')::uuid IS DISTINCT FROM p_personal_turn
  THEN RAISE EXCEPTION 'AKIMICHI_UPKEEP_WINDOW_INVALID' USING ERRCODE = '55000'; END IF;

  IF combat_panel_private.human_duel_turn_allowed((scope->>'round')::uuid, p_actor) IS DISTINCT FROM true THEN
    RETURN;
  END IF;

  IF clan_akimichi_private.common_defer_upkeep_v1(p_actor,p_personal_turn) THEN RETURN;END IF;
  event_id := md5('akimichi-expansion-upkeep/1|' || p_actor::text || '|' || p_personal_turn::text)::uuid;
  debit := clan_akimichi_private.apply_calorie_event(
    (scope->>'owner')::uuid, (scope->>'scope')::uuid, (scope->>'simulated')::boolean,
    event_id, CASE WHEN form.form_kind='super' THEN 'super_upkeep' ELSE 'upkeep' END, (scope->>'permanent_kg')::integer, (scope->>'permanent_resistance')::integer
  );
  IF (debit->>'accepted')::boolean IS TRUE THEN
    UPDATE clan_akimichi_private.forms SET last_paid_turn = p_personal_turn WHERE actor_id = p_actor;
  ELSE
    UPDATE clan_akimichi_private.forms SET active = false, ended_reason = 'insufficient_calories' WHERE actor_id = p_actor;
  END IF;
END;
$function$;
CREATE OR REPLACE FUNCTION clan_akimichi_private.bind_partial(p_declaration uuid)
 RETURNS void
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO ''
AS $function$
DECLARE
  d public.combat_v2_declarations%ROWTYPE;
  a public.combat_v2_actors%ROWTYPE;
  scope jsonb;
  mass_value integer;
BEGIN
  SELECT * INTO STRICT d FROM public.combat_v2_declarations WHERE id = p_declaration;
  IF d.sanitized_intent->>'ability_source' IS DISTINCT FROM 'clan'
    OR d.sanitized_intent->>'ability_id' IS DISTINCT FROM '214af896-15f8-43e6-858b-614d2851dd3b'
    OR NOT clan_akimichi_private.replacement_applies(d.actor_id)
  THEN RETURN; END IF;
  IF d.kind IS DISTINCT FROM 'attacco' OR d.state IS DISTINCT FROM 'inviata'
    OR d.sanitized_intent#>>'{server_ability,akimichi_partial_contract}' IS DISTINCT FROM 'akimichi-partial/1'
    OR d.cost_snapshot->>'chakra' IS DISTINCT FROM '0' OR d.cost_snapshot->>'damage_base' IS DISTINCT FROM '20'
    OR d.target_actor_id IS NULL
    OR (SELECT count(*) FROM public.combat_v2_attack_targets t WHERE t.attack_declaration_id = d.id) <> 1
    OR NOT EXISTS (SELECT 1 FROM public.combat_v2_attack_targets t WHERE t.attack_declaration_id = d.id
      AND t.round_id = d.round_id AND t.target_actor_id = d.target_actor_id)
  THEN RAISE EXCEPTION 'AKIMICHI_PARTIAL_DECLARATION_INVALID' USING ERRCODE = '22023'; END IF;
  SELECT * INTO STRICT a FROM public.combat_v2_actors WHERE id = d.actor_id FOR UPDATE;
  scope := clan_akimichi_private.scope_for_actor(a.id, '214af896-15f8-43e6-858b-614d2851dd3b');
  IF scope IS NULL OR (scope->>'round')::uuid IS DISTINCT FROM d.round_id
    OR d.controller_version_snapshot IS DISTINCT FROM a.controller_version
  THEN RAISE EXCEPTION 'AKIMICHI_PARTIAL_SCOPE_INVALID' USING ERRCODE = '42501'; END IF;
  SELECT f.mass INTO mass_value FROM clan_akimichi_private.forms f
  WHERE f.actor_id = a.id AND f.session_id = a.session_id AND f.active;
  INSERT INTO clan_akimichi_private.partial_sources(
    declaration_id, session_id, round_id, actor_id, target_id, owner_id, scope_id, simulated,
    permanent_kg, permanent_resistance, declaration_sha256, kg, taijutsu, mass)
  VALUES (d.id, a.session_id, d.round_id, d.actor_id, d.target_actor_id,
    (scope->>'owner')::uuid, (scope->>'scope')::uuid, (scope->>'simulated')::boolean,
    (scope->>'permanent_kg')::integer, (scope->>'permanent_resistance')::integer,
    combat_effects_private.declaration_fingerprint(d.id),
    (a.mechanics_snapshot->>'kekkei_genkai')::integer, (a.mechanics_snapshot->>'taijutsu')::integer, coalesce(mass_value, 0));
  PERFORM clan_akimichi_private.common_admit_calories_v1(d.id);
END;
$function$;
CREATE OR REPLACE FUNCTION clan_akimichi_private.end_form(p_actor uuid, p_session uuid, p_reason text)
 RETURNS void
 LANGUAGE sql
 SECURITY DEFINER
 SET search_path TO ''
AS $function$
  UPDATE clan_akimichi_private.forms SET active = false, ended_reason = coalesce(p_reason, 'session_closed')
  WHERE actor_id = p_actor AND session_id = p_session AND active;
  UPDATE clan_akimichi_private.common_pending_upkeep_v1 SET state='ended'
  WHERE actor_id=p_actor AND session_id=p_session AND state='pending';
$function$;
CREATE OR REPLACE FUNCTION clan_akimichi_private.form_change_offer(p_actor uuid)
 RETURNS jsonb
 LANGUAGE plpgsql
 STABLE SECURITY DEFINER
 SET search_path TO ''
AS $function$
DECLARE
  scope jsonb;
  r clan_akimichi_private.calorie_reserves%ROWTYPE;
  f clan_akimichi_private.forms%ROWTYPE;
  turn_id uuid;
BEGIN
  IF auth.uid() IS NULL OR NOT EXISTS (
    SELECT 1 FROM public.combat_v2_actors a
    WHERE a.id = p_actor AND exam_regia_private.actor_principal(a.id, a.controller_user) = auth.uid()
  ) THEN RETURN NULL; END IF;
  IF clan_akimichi_private.common_scope_v1(p_actor,'f5f26cb5-9b6f-44b3-94bc-c329a0a88b93') IS NOT NULL THEN RETURN NULL;END IF;
  scope := clan_akimichi_private.scope_for_actor(p_actor, '3b4c4fd0-c0c2-46a0-a387-f47a95ef7dda');
  IF scope IS NULL OR (scope->>'is_turn_owner')::boolean IS DISTINCT FROM true OR scope->>'phase' IS DISTINCT FROM 'action'
    OR EXISTS (SELECT 1 FROM public.combat_v2_declarations d
      WHERE d.round_id = (scope->>'round')::uuid AND d.actor_id = p_actor)
  THEN RETURN NULL; END IF;
  SELECT * INTO r FROM clan_akimichi_private.calorie_reserves
  WHERE owner_id = (scope->>'owner')::uuid AND scope_id = (scope->>'scope')::uuid;
  IF NOT FOUND THEN RETURN NULL; END IF;
  SELECT * INTO f FROM clan_akimichi_private.forms WHERE actor_id = p_actor AND session_id = (scope->>'session')::uuid;
  turn_id := (scope->>'turn')::uuid;
  IF coalesce(f.active, false) THEN
    RETURN jsonb_build_object('operation', 'deactivate', 'label', 'Disattiva Espansione · gratuito', 'turn', turn_id);
  END IF;
  IF combat_panel_private.human_duel_turn_allowed((scope->>'round')::uuid, p_actor) IS DISTINCT FROM true
    OR r.current_amount < 5 OR f.activation_turn = turn_id OR EXISTS (
    SELECT 1 FROM clan_akimichi_private.form_commands c
    WHERE c.actor_id = p_actor AND c.session_id = (scope->>'session')::uuid AND c.result->>'turn' = turn_id::text
  ) OR (combat_panel_private.movement_budget(p_actor, (scope->>'round')::uuid)->>'spent_m')::numeric IS DISTINCT FROM 0
  THEN RETURN NULL; END IF;
  RETURN jsonb_build_object('operation', 'activate', 'label',
    'Attiva Espansione · 5 Calorie (Riserva ' || r.current_amount || '/' || r.maximum || ')', 'turn', turn_id);
END;
$function$;
CREATE OR REPLACE FUNCTION clan_akimichi_private.form_impact(p_declaration uuid, p_defender uuid, p_target uuid, p_kind text, p_reaction text, p_defense_discipline text, p_native jsonb)
 RETURNS jsonb
 LANGUAGE plpgsql
 STABLE SECURITY DEFINER
 SET search_path TO ''
AS $function$
DECLARE
  d public.combat_v2_declarations%ROWTYPE;
  v_actor_id uuid;
  v_session_id uuid;
  defender_principal uuid;
  target_resilience integer := 0;
  mass_bonus integer;
  speed_penalty integer := 0;
  native_margin integer;
  new_margin integer;
  hit_modifier integer;
  direct boolean;
BEGIN
  SELECT * INTO STRICT d FROM public.combat_v2_declarations WHERE id=p_declaration;
  SELECT a.id,a.session_id INTO STRICT v_actor_id,v_session_id FROM public.combat_v2_actors a WHERE a.id=d.actor_id;
  IF NOT EXISTS (
    SELECT 1 FROM clan_akimichi_private.forms f WHERE f.session_id=v_session_id
      AND f.actor_id IN (v_actor_id,p_defender,p_target) AND f.active
  ) THEN RETURN p_native; END IF;
  mass_bonus := clan_akimichi_private.body_attack_mass(d.id);
  IF p_kind='fisico' THEN
    SELECT coalesce(max(f.resilience),0) INTO target_resilience FROM clan_akimichi_private.forms f
    WHERE f.session_id=v_session_id AND f.actor_id=p_target AND f.active;
  END IF;
  IF NOT(p_native ? 'akimichi_cellular_source') AND (p_reaction IN ('schivata','parata') OR (p_reaction='tecnica' AND p_defense_discipline='taijutsu')) THEN
    IF EXISTS(SELECT 1 FROM clan_akimichi_private.forms f WHERE f.session_id=v_session_id AND f.actor_id=p_defender AND f.active) THEN
      direct := (
        p_kind='ninjutsu'
        AND coalesce(d.sanitized_intent#>>'{server_ability,targeting,mode}','single') IN ('single','singolo')
        AND (SELECT count(*) FROM public.combat_v2_attack_targets t WHERE t.attack_declaration_id=d.id)=1
        AND NOT EXISTS (SELECT 1 FROM clan_uchiha_private.fireball_sources x
          WHERE x.declaration_id=d.id AND coalesce((x.profile->>'area_radius_m')::numeric,0)>0)
        AND coalesce((d.sanitized_intent#>>'{server_ability,targeting,area_radius_m}')::numeric,0)=0
      ) OR (
        p_kind='fisico'
        AND d.sanitized_intent#>>'{server_ability,akimichi_delivery}'='physical_projectile/1'
      );
      IF direct THEN
        SELECT exam_regia_private.actor_principal(a.id,a.controller_user) INTO defender_principal
        FROM public.combat_v2_actors a WHERE a.id=p_defender AND a.session_id=v_session_id AND a.state='attivo';
        IF EXISTS(SELECT 1 FROM clan_akimichi_private.forms x WHERE x.actor_id=p_defender AND x.session_id=v_session_id AND x.active AND x.form_kind='super') THEN
          IF clan_akimichi_private.super_direct_visible_v1(p_declaration,p_defender) THEN speed_penalty:=2;END IF;
        ELSE
        IF EXISTS (
          SELECT 1 FROM combat_spatial.arena_instances i
          JOIN combat_spatial.viewer_grants v ON v.instance_id=i.instance_id
          WHERE i.encounter_id=v_session_id AND i.state='open' AND v.viewer_principal_id=defender_principal
            AND v.subject_actor_id=v_actor_id AND v.can_view_map
        ) THEN speed_penalty := 1; END IF;
        END IF;
      END IF;
    END IF;
  END IF;
  IF mass_bonus=0 AND speed_penalty=0 AND target_resilience=0 THEN RETURN p_native; END IF;
  native_margin := (p_native->>'margine')::integer;
  hit_modifier := coalesce((p_native->>'mod_risonanza')::integer,0);
  IF native_margin IS NULL OR (p_native->>'atk_tot')::integer IS NULL
    OR (p_native->>'def_tot')::integer IS NULL OR (p_native->>'riduzione')::integer IS NULL
  THEN RAISE EXCEPTION 'AKIMICHI_IMPACT_NATIVE_CALC_INVALID' USING ERRCODE='22023'; END IF;
  new_margin := native_margin + speed_penalty;
  RETURN p_native || jsonb_build_object(
    'akimichi_form',jsonb_build_object('body_mass',mass_bonus,'target_resilience',target_resilience,'visible_direct_speed_penalty',speed_penalty)||CASE WHEN EXISTS(SELECT 1 FROM clan_akimichi_private.forms x WHERE x.session_id=v_session_id AND x.actor_id IN(v_actor_id,p_defender,p_target) AND x.active AND x.form_kind='super') THEN jsonb_build_object('super_form',true) ELSE '{}'::jsonb END,
    'def_tot',(p_native->>'def_tot')::integer-speed_penalty,
    'riduzione',(p_native->>'riduzione')::integer+target_resilience,
    'margine',new_margin,'hit_margin',new_margin+hit_modifier,'damage_margin',new_margin,
    'bonus_margine',CASE WHEN new_margin+hit_modifier<0 OR new_margin<5 THEN 0 WHEN new_margin<10 THEN 3 WHEN new_margin<15 THEN 6 ELSE 10 END
  );
END;
$function$;
CREATE OR REPLACE FUNCTION clan_akimichi_private.movement_maximum(p_actor uuid, p_ordinary_max numeric)
 RETURNS numeric
 LANGUAGE sql
 STABLE SECURITY DEFINER
 SET search_path TO ''
AS $function$
  SELECT CASE WHEN p_ordinary_max>0 AND EXISTS (SELECT 1 FROM clan_akimichi_private.forms f
    JOIN public.combat_v2_actors a ON a.id = f.actor_id AND a.session_id = f.session_id AND a.state = 'attivo'
    WHERE f.actor_id = p_actor AND f.active)
  THEN greatest(1,floor(p_ordinary_max * CASE WHEN EXISTS(SELECT 1 FROM clan_akimichi_private.forms x WHERE x.actor_id=p_actor AND x.active AND x.form_kind='super') THEN 0.5 ELSE 0.75 END)) ELSE p_ordinary_max END;
$function$;
CREATE OR REPLACE FUNCTION clan_akimichi_private.partial_meta(p_actor uuid, p_meta jsonb)
 RETURNS jsonb
 LANGUAGE plpgsql
 STABLE SECURITY DEFINER
 SET search_path TO ''
AS $function$
DECLARE
  scope jsonb;
  available integer;
BEGIN
  IF p_meta->>'source' IS DISTINCT FROM 'clan'
    OR p_meta->>'id' IS DISTINCT FROM '214af896-15f8-43e6-858b-614d2851dd3b'
  THEN RETURN NULL; END IF;
  scope := clan_akimichi_private.scope_for_actor(p_actor, '214af896-15f8-43e6-858b-614d2851dd3b');
  IF scope IS NULL THEN RETURN NULL; END IF;
  SELECT current_amount INTO available FROM clan_akimichi_private.calorie_reserves
  WHERE owner_id = (scope->>'owner')::uuid AND scope_id = (scope->>'scope')::uuid
    AND simulated = (scope->>'simulated')::boolean;
  IF clan_akimichi_private.common_scope_v1(p_actor,'f5f26cb5-9b6f-44b3-94bc-c329a0a88b93') IS NOT NULL
    OR clan_akimichi_private.common_scope_v1(p_actor,'687b058a-807d-4cf7-8bcf-21147931b0f6') IS NOT NULL THEN
    -- Metadata for an already admitted main excludes that same source;
    -- the native main slot and the locked bind still prevent a second spend.
    available:=clan_akimichi_private.common_calorie_balance_v1((scope->>'owner')::uuid,(scope->>'scope')::uuid,
      (SELECT s.declaration_id FROM clan_akimichi_private.partial_sources s
       JOIN public.combat_v2_declarations d ON d.id=s.declaration_id AND d.state IN('inviata','congelata')
       WHERE s.actor_id=p_actor AND s.round_id=(scope->>'round')::uuid LIMIT 1));
  END IF;
  IF coalesce(available, 0) < 10 THEN RETURN NULL; END IF;
  RETURN p_meta || jsonb_build_object(
    'kind', 'fisico', 'usage', 'principale', 'chakra_cost', 0, 'damage_base', 20,
    'range', 'corta', 'akimichi_partial_contract', 'akimichi-partial/1', 'defensive', false,
    'consumption_type', 'ad_utilizzo', 'di_scena', false, 'diversivo', false
  );
END;
$function$;
CREATE OR REPLACE FUNCTION clan_akimichi_private.set_form(p_actor uuid, p_event uuid, p_enable boolean)
 RETURNS jsonb
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO ''
AS $function$
DECLARE
  a public.combat_v2_actors%ROWTYPE;
  form clan_akimichi_private.forms%ROWTYPE;
  prior clan_akimichi_private.form_commands%ROWTYPE;
  scope jsonb;
  modifiers jsonb;
  debit jsonb;
  result jsonb;
  turn_id uuid;
BEGIN
  IF p_event IS NULL OR p_enable IS NULL OR auth.uid() IS NULL THEN
    RAISE EXCEPTION 'AKIMICHI_FORM_COMMAND_INVALID' USING ERRCODE = '42501';
  END IF;
  SELECT * INTO STRICT a FROM public.combat_v2_actors WHERE id = p_actor FOR UPDATE;
  IF exam_regia_private.actor_principal(a.id, a.controller_user) IS DISTINCT FROM auth.uid() THEN
    RAISE EXCEPTION 'AKIMICHI_FORM_OWNER_REQUIRED' USING ERRCODE = '42501';
  END IF;
  SELECT * INTO prior FROM clan_akimichi_private.form_commands
  WHERE actor_id = a.id AND session_id = a.session_id AND event_id = p_event;
  IF FOUND THEN
    IF prior.enabled IS DISTINCT FROM p_enable THEN
      RAISE EXCEPTION 'AKIMICHI_FORM_COMMAND_CONFLICT' USING ERRCODE = '40001';
    END IF;
    RETURN prior.result;
  END IF;

  scope := clan_akimichi_private.scope_for_actor(a.id, '3b4c4fd0-c0c2-46a0-a387-f47a95ef7dda');
  IF scope IS NULL OR (scope->>'is_turn_owner')::boolean IS DISTINCT FROM true
    OR scope->>'phase' IS DISTINCT FROM 'action'
    OR EXISTS (SELECT 1 FROM public.combat_v2_declarations d
      WHERE d.round_id = (scope->>'round')::uuid AND d.actor_id = a.id)
  THEN RAISE EXCEPTION 'AKIMICHI_FORM_WINDOW_CLOSED' USING ERRCODE = '55000'; END IF;
  turn_id := (scope->>'turn')::uuid;

  SELECT * INTO form FROM clan_akimichi_private.forms WHERE actor_id = a.id AND session_id = a.session_id FOR UPDATE;
  IF p_enable AND coalesce(form.active, false) THEN
    RAISE EXCEPTION 'AKIMICHI_FORM_ALREADY_ACTIVE' USING ERRCODE = '55000';
  END IF;
  IF p_enable AND (form.activation_turn = turn_id OR EXISTS (
    SELECT 1 FROM clan_akimichi_private.form_commands c
    WHERE c.actor_id = a.id AND c.session_id = a.session_id AND c.result->>'turn' = turn_id::text
  )) THEN RAISE EXCEPTION 'AKIMICHI_FORM_CHANGED_THIS_TURN' USING ERRCODE = '55000'; END IF;

  IF p_enable THEN
    IF combat_panel_private.human_duel_turn_allowed((scope->>'round')::uuid, a.id) IS DISTINCT FROM true THEN
      RAISE EXCEPTION 'AKIMICHI_FORM_WINDOW_CLOSED' USING ERRCODE = '55000';
    END IF;
    IF (combat_panel_private.movement_budget(a.id, (scope->>'round')::uuid)->>'spent_m')::numeric IS DISTINCT FROM 0
    THEN RAISE EXCEPTION 'AKIMICHI_FORM_TURN_ALREADY_STARTED' USING ERRCODE = '55000'; END IF;
    -- No new footprint: the active native body remains at the same position
    -- with its existing radius. Missing native geometry rejects activation.
    IF NOT EXISTS (
      SELECT 1 FROM combat_spatial.arena_instances i
      JOIN combat_spatial.actor_states b ON b.instance_id = i.instance_id AND b.actor_id = a.id AND b.state = 'active'
      WHERE i.encounter_id = a.session_id AND i.state = 'open'
    ) THEN RAISE EXCEPTION 'AKIMICHI_FORM_BODY_UNAVAILABLE' USING ERRCODE = '55000'; END IF;
    modifiers := clan_akimichi_private.expansion_modifiers(
      (a.mechanics_snapshot->>'kekkei_genkai')::integer,
      (a.mechanics_snapshot->>'forza')::integer,
      (a.mechanics_snapshot->>'resistenza')::integer, 0
    );
    IF modifiers IS NULL THEN RAISE EXCEPTION 'AKIMICHI_FORM_STATS_MISSING' USING ERRCODE = '22023'; END IF;
    debit := clan_akimichi_private.apply_calorie_event(
      (scope->>'owner')::uuid, (scope->>'scope')::uuid, (scope->>'simulated')::boolean,
      p_event, 'activate', (scope->>'permanent_kg')::integer, (scope->>'permanent_resistance')::integer
    );
    IF (debit->>'accepted')::boolean IS DISTINCT FROM true THEN
      RAISE EXCEPTION 'AKIMICHI_FORM_CALORIES_INSUFFICIENT' USING ERRCODE = '55000';
    END IF;
    INSERT INTO clan_akimichi_private.forms(actor_id, session_id, activation_turn, last_paid_turn, activation_event, mass, resilience, active, form_kind)
    VALUES (a.id, a.session_id, turn_id, turn_id, p_event, (modifiers->>'mass')::integer, (modifiers->>'physical_resilience')::integer, true, 'base')
    ON CONFLICT (actor_id) DO UPDATE
      SET activation_turn = excluded.activation_turn, last_paid_turn = excluded.last_paid_turn,
          activation_event = excluded.activation_event, mass = excluded.mass,
          resilience = excluded.resilience, active = true, ended_reason = NULL, form_kind = 'base'
    WHERE clan_akimichi_private.forms.session_id = excluded.session_id;
    IF NOT FOUND THEN RAISE EXCEPTION 'AKIMICHI_FORM_SESSION_CONFLICT' USING ERRCODE = '40001'; END IF;
  ELSE
    UPDATE clan_akimichi_private.forms SET active = false, ended_reason = 'deactivated'
    WHERE actor_id = a.id AND session_id = a.session_id AND active;
    IF NOT FOUND THEN RAISE EXCEPTION 'AKIMICHI_FORM_NOT_ACTIVE' USING ERRCODE = '55000'; END IF;
  END IF;
  result := jsonb_build_object('active', p_enable, 'turn', turn_id, 'spent_calories', CASE WHEN p_enable THEN 5 ELSE 0 END,
    'values_written', p_enable AND NOT (scope->>'simulated')::boolean);
  INSERT INTO clan_akimichi_private.form_commands(actor_id, session_id, event_id, enabled, result)
  VALUES (a.id, a.session_id, p_event, p_enable, result);
  RETURN result;
END;
$function$;
CREATE OR REPLACE FUNCTION clan_sabaku_private.armor_absorb(p_target uuid, p_damage integer)
 RETURNS jsonb
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO ''
AS $function$
DECLARE t public.combat_v2_attack_targets%ROWTYPE;
BEGIN
 SELECT * INTO STRICT t FROM public.combat_v2_attack_targets WHERE id=p_target;
 RETURN clan_sabaku_private.armor_absorb_packet_v1(t.target_actor_id,t.round_id,t.id,t.id,p_damage);
END;
$function$;
CREATE OR REPLACE FUNCTION clan_sabaku_private.armor_narrative_round(p_round uuid)
 RETURNS jsonb
 LANGUAGE plpgsql
 STABLE SECURITY DEFINER
 SET search_path TO ''
AS $function$
DECLARE r public.combat_v2_round_reports%ROWTYPE; fact jsonb; sources jsonb:='[]'; events jsonb:='[]'; catalog jsonb; content jsonb;
BEGIN
 IF NOT EXISTS(SELECT 1 FROM clan_sabaku_private.armor_events WHERE round_id=p_round AND event_kind='hit' AND attack_target_id IS NOT NULL) THEN RETURN '{}'::jsonb; END IF;
 SELECT * INTO STRICT r FROM public.combat_v2_round_reports WHERE round_id=p_round;
 IF r.mechanics_sha256 IS DISTINCT FROM public.combat_v2_sha256(r.mechanics) OR r.mechanics->'sabaku_armor' IS DISTINCT FROM clan_sabaku_private.armor_round_facts(p_round) THEN RAISE EXCEPTION 'armor_narrative_report_drift'; END IF;
 IF NOT EXISTS(SELECT 1 FROM combat_consumer_private.activities WHERE session_id=(SELECT session_id FROM public.combat_v2_rounds WHERE id=p_round)) THEN RETURN '{}'::jsonb; END IF;
 FOR fact IN SELECT value FROM jsonb_array_elements(r.mechanics->'sabaku_armor') LOOP
  IF NOT EXISTS(SELECT 1 FROM public.combat_v2_attack_targets t JOIN combat_consumer_private.members m ON m.actor_id=t.target_actor_id
   WHERE t.id=(fact->>'attack_target_id')::uuid AND t.round_id=p_round AND t.target_actor_id=(fact->>'actor_id')::uuid
    AND t.outcome#>'{raw,sabaku_armor}'=fact AND t.outcome->'damage_applied'=fact->'damage_after') THEN RAISE EXCEPTION 'armor_narrative_target_drift'; END IF;
  catalog:=fact->'catalog'; content:=jsonb_build_object('id',catalog->'technique_id','name',catalog->'name','description',catalog->'description','danno_effetto',catalog->'effect');
  IF NOT EXISTS(SELECT 1 FROM jsonb_array_elements(sources) x WHERE x->'actor_id'=fact->'actor_id') THEN
   sources:=sources||jsonb_build_array(jsonb_build_object('catalog','clan_techniques','technique_id',catalog->'technique_id','actor_id',fact->'actor_id',
    'mapping_version','ordinary-armor-tech/2','source_sha256',public.combat_v2_sha256(content),'content',content)); END IF;
  events:=events||jsonb_build_array(jsonb_build_object('actor_id',fact->'actor_id','tecnica','Armatura di Sabbia','impatto','colpo_raggiunge_armatura',
   'danno_prima',fact->'damage_before','assorbito',fact->'absorbed','danno_ai_pv',fact->'damage_after',
   'protezione',CASE WHEN fact->>'damage_after'='0' THEN 'assorbimento_completo' ELSE 'assorbimento_parziale' END,
   'dopo_urto','sabbia_consumata_ripristino_al_turno_successivo'));
 END LOOP;
 RETURN jsonb_build_object('fonti_tecniche',sources,'armatura_server',jsonb_build_object('version','ordinary-armor-narrative/2','events',events));
END $function$;
CREATE OR REPLACE FUNCTION clan_sabaku_private.armor_round_facts(p_round uuid)
 RETURNS jsonb
 LANGUAGE sql
 STABLE SECURITY DEFINER
 SET search_path TO ''
AS $function$
 SELECT coalesce(jsonb_agg(e.result ORDER BY e.created_at,e.id),'[]'::jsonb)
 FROM clan_sabaku_private.armor_events e WHERE e.round_id=p_round AND e.event_kind='hit' AND e.attack_target_id IS NOT NULL
$function$;
CREATE OR REPLACE FUNCTION combat_consumer_private.after_publish(p_round uuid, p_next uuid)
 RETURNS void
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO ''
AS $function$
declare ctx combat_consumer_private.activities%rowtype; r public.combat_v2_rounds%rowtype;
  next_actor uuid;
begin
  if not combat_consumer_private.owns_round(p_round) then return; end if;
  select * into r from public.combat_v2_rounds where id=p_round;
  select * into ctx from combat_consumer_private.activities where session_id=r.session_id for update;
  if ctx.exchange_id is distinct from p_round or ctx.phase<>'resolved' or r.state<>'narrato'
    or not exists(select 1 from public.combat_v2_round_reports where round_id=p_round
      and narration_state='pubblicata' and message_id is not null) then
    raise exception 'ordinary_publication_state_invalid';
  end if;
  if p_next is null then
    if (select count(*) from public.combat_v2_actors where session_id=ctx.session_id and state='attivo' and companion_id is null)>=2 then
      raise exception 'ordinary_next_missing';
    end if;
    perform combat_consumer_private.close_session(ctx.session_id);
    perform combat_effects_private.lifecycle_session_end(ctx.session_id);
    return;
  end if;
  if not exists(select 1 from public.combat_v2_rounds where id=p_next and session_id=ctx.session_id
    and round_no=r.round_no+1 and phase='raccolta_azioni') then
    raise exception 'ordinary_next_invalid';
  end if;
  select m.actor_id into next_actor from combat_consumer_private.members m
    join public.combat_v2_actors a on a.id=m.actor_id and a.session_id=m.session_id
    where m.session_id=ctx.session_id and m.actor_id<>ctx.turn_actor_id and a.state='attivo';
  if next_actor is null then raise exception 'ordinary_next_actor_invalid'; end if;
  update combat_consumer_private.activities set exchange_id=p_next,turn_actor_id=next_actor,
    round_no=ctx.round_no+case when mod(r.round_no,2)=0 then 1 else 0 end,
    phase='action',context_version=context_version+1,last_action_at=clock_timestamp()
    where session_id=ctx.session_id;
  perform combat_effects_private.lifecycle_open(ctx.session_id,next_actor);
  IF combat_panel_private.nara_strangle_terminal_report_v1(p_next)THEN RETURN;END IF;
  IF EXISTS(SELECT 1 FROM clan_hoki_private.combat_events e
    JOIN public.combat_v2_actors a ON a.id=e.actor_id AND a.session_id=e.session_id
    WHERE e.session_id=ctx.session_id AND e.round_id=p_next AND e.actor_id=next_actor
      AND e.kind='poison_tick' AND e.facts->'ko'='true'::jsonb AND a.state<>'attivo')
 THEN
    -- Keep the tick's native turn for audit, but expose the last published round.
    UPDATE combat_consumer_private.activities SET exchange_id=p_round,turn_actor_id=ctx.turn_actor_id,
      round_no=ctx.round_no WHERE session_id=ctx.session_id;
    PERFORM combat_consumer_private.close_session(ctx.session_id);
    RETURN;
  END IF;
  update combat_consumer_private.offers set state='revoked'
    where session_id=ctx.session_id and state='offered';
end $function$;
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
    IF offer.source_payload->>'aburame_operation' IN('release_stop','verme_staff_prepare') THEN
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
     and (p->>'edge_revision',p->>'validator_revision') is distinct from ('ordinary-facts/1','combat-facts/4'))
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
CREATE OR REPLACE FUNCTION combat_effects_private.lifecycle_actor_end(p_actor uuid)
 RETURNS void
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO ''
AS $function$
DECLARE a public.combat_v2_actors%ROWTYPE;
BEGIN
 SELECT * INTO STRICT a FROM public.combat_v2_actors WHERE id=p_actor;
 PERFORM combat_panel_private.nara_strangle_lifecycle_v1(a.session_id);
 IF a.state<>'attivo' THEN PERFORM clan_hoki_private.end_actor(a.session_id,a.id); END IF;
 IF a.state='attivo' OR (
   NOT EXISTS(SELECT 1 FROM combat_effects_private.effect_applications
     WHERE session_id=a.session_id AND target_actor_id=a.id AND state IN ('pending','active'))
   AND NOT EXISTS(SELECT 1 FROM clan_akimichi_private.forms
     WHERE session_id=a.session_id AND actor_id=a.id AND active)
 ) THEN RETURN;END IF;
 -- Nessun gate intake: gli effetti già congelati vanno terminati anche in recovery.
 PERFORM combat_effects_private.end_actor(a.session_id,a.id);
END $function$;
CREATE OR REPLACE FUNCTION combat_effects_private.lifecycle_open(p_session uuid, p_actor uuid)
 RETURNS void
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO ''
AS $function$
DECLARE c jsonb; pending_effect boolean;
BEGIN
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
CREATE OR REPLACE FUNCTION combat_effects_private.lifecycle_session_end(p_session uuid)
 RETURNS void
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO ''
AS $function$
DECLARE s public.combat_v2_sessions%ROWTYPE;
BEGIN
 SELECT * INTO STRICT s FROM public.combat_v2_sessions WHERE id=p_session;
 PERFORM combat_panel_private.nara_strangle_lifecycle_v1(s.id);
 IF s.closed_at IS NOT NULL OR s.state IN ('chiusa','annullata','chiuso','annullato')
 THEN
  PERFORM clan_hoki_private.end_session(s.id);
  PERFORM clan_hoki_private.recover_after_session(s.id);
 END IF;
 IF NOT EXISTS(SELECT 1 FROM combat_effects_private.effect_applications
  WHERE session_id=s.id AND state IN ('pending','active'))
  AND NOT EXISTS(SELECT 1 FROM clan_akimichi_private.forms WHERE session_id=s.id AND active) THEN RETURN;END IF;
 IF s.closed_at IS NULL AND s.state NOT IN ('chiusa','annullata') THEN
  RAISE EXCEPTION 'effects_session_not_terminal';END IF;
 PERFORM combat_effects_private.end_context(s.id,CASE WHEN s.state IN ('annullato','annullata') THEN 'cancelled' ELSE 'combat_end' END);
END $function$;
CREATE OR REPLACE FUNCTION combat_effects_private.personal_turn_end(p_session uuid, p_actor uuid, p_turn uuid, p_adapter text)
 RETURNS jsonb
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO ''
AS $function$
DECLARE e combat_effects_private.effect_applications%ROWTYPE;effect_id uuid;c jsonb;ek text;turn_key text;res jsonb;all_res jsonb:='[]';old_event combat_effects_private.effect_events%ROWTYPE;
BEGIN
 IF p_session IS NULL OR p_actor IS NULL OR p_turn IS NULL OR p_adapter IS NULL THEN RAISE EXCEPTION 'effects_turn_input_invalid';END IF;
 turn_key:='turn-end:'||p_session::text||':'||p_actor::text||':'||p_adapter||':'||p_turn::text;
 PERFORM 1 FROM public.combat_v2_sessions WHERE id=p_session FOR UPDATE;
 SELECT * INTO old_event FROM combat_effects_private.effect_events WHERE event_key=turn_key;
 IF FOUND THEN
  IF old_event.result_sha256 IS DISTINCT FROM public.combat_v2_sha256(old_event.result) THEN RAISE EXCEPTION 'effects_turn_replay_conflict';END IF;
  RETURN old_event.result->'effects';END IF;
 PERFORM combat_effects_private.lock_context(p_session);
 PERFORM 1 FROM public.combat_v2_actors WHERE id=p_actor AND session_id=p_session FOR UPDATE;
 c:=combat_effects_private.personal_turn(p_session,p_actor);
 IF p_turn IS NULL OR c->>'turn_id' IS DISTINCT FROM p_turn::text OR c->>'adapter' IS DISTINCT FROM p_adapter THEN
  RAISE EXCEPTION 'effects_current_native_turn_required';END IF;
 IF p_adapter='ordinary_v2' AND c->>'is_current' IS DISTINCT FROM 'true' THEN RAISE EXCEPTION 'effects_wrong_actor_turn';END IF;
  PERFORM clan_akimichi_private.common_flush_upkeep_v1(p_actor);
  PERFORM combat_v2_genjutsu_internal.turn_end(p_session,p_actor,p_turn,p_adapter);
 FOR effect_id IN SELECT id FROM combat_effects_private.effect_applications WHERE session_id=p_session AND target_actor_id=p_actor
  AND adapter=p_adapter AND state IN ('pending','active') AND excluded_turn_id IS DISTINCT FROM p_turn ORDER BY id LOOP
  -- Il saldo precedente può avere provocato KO e terminato gli altri effetti.
  -- Non riutilizzare la riga materializzata dal cursore prima di quel lifecycle.
  IF EXISTS(SELECT 1 FROM public.combat_v2_actors WHERE id=p_actor AND session_id=p_session AND state<>'attivo') THEN
   PERFORM combat_effects_private.end_actor(p_session,p_actor);
  END IF;
  SELECT * INTO STRICT e FROM combat_effects_private.effect_applications WHERE id=effect_id FOR UPDATE;
  IF e.state NOT IN ('pending','active') THEN
   SELECT * INTO STRICT old_event FROM combat_effects_private.effect_events
    WHERE event_key='terminate:'||e.id::text AND effect_events.effect_id=e.id AND kind='termination';
   IF e.state<>'ended' OR old_event.source_declaration_id IS DISTINCT FROM e.source_declaration_id
    OR old_event.result->>'reason' IS DISTINCT FROM e.end_reason
    OR old_event.result_sha256 IS DISTINCT FROM public.combat_v2_sha256(old_event.result) THEN
    RAISE EXCEPTION 'effects_terminal_receipt_required';END IF;
   all_res:=all_res||jsonb_build_array(old_event.result);
   CONTINUE;
  END IF;
  IF e.reserved_comparison IS NOT NULL THEN RAISE EXCEPTION 'effects_comparison_must_settle_before_turn_end';END IF;
  IF e.family='apertura_difensiva_1' THEN
   ek:='retain:'||e.id::text||':'||p_adapter||':'||p_turn::text;
   res:=jsonb_build_object('effect_id',e.id,'family',e.family,'retained',true,'turn_id',p_turn,'adapter',p_adapter,'expires','first_compatible_defense_or_context_end');
   PERFORM combat_effects_private.record_event(ek,e.id,e.source_declaration_id,'turn_end',res);
   all_res:=all_res||jsonb_build_array(res);
   CONTINUE;
  END IF;
  IF e.due_turn_id IS NOT NULL AND e.due_turn_id<>p_turn THEN RAISE EXCEPTION 'effects_missed_turn_settlement';END IF;
  IF e.due_turn_id IS NULL THEN
   UPDATE combat_effects_private.effect_applications SET due_turn_id=p_turn,state='active',state_version=state_version+1 WHERE id=e.id;
  END IF;
  ek:='end:'||e.id::text||':'||p_adapter||':'||p_turn::text;
  IF e.family='bruciatura_lieve' THEN
   IF to_regprocedure('combat_effects_private.settle_burn(uuid,uuid,text)') IS NULL THEN
    RAISE EXCEPTION 'effects_burn_settlement_required' USING ERRCODE='55000';END IF;
   EXECUTE 'SELECT combat_effects_private.settle_burn($1,$2,$3)' INTO res USING e.id,p_turn,p_adapter;
   IF res IS NULL OR NOT EXISTS(SELECT 1 FROM combat_effects_private.effect_applications WHERE id=e.id AND state IN ('expired','ended'))
    OR NOT EXISTS(SELECT 1 FROM combat_effects_private.effect_events ev WHERE ev.effect_id=e.id AND ev.kind='save') THEN
    RAISE EXCEPTION 'effects_burn_settlement_incomplete';END IF;
  ELSE
   res:=jsonb_build_object('effect_id',e.id,'family',e.family,'expired',true,'turn_id',p_turn,'adapter',p_adapter);
   UPDATE combat_effects_private.effect_applications SET state='expired',charges=0,state_version=state_version+1,
    ended_at=clock_timestamp(),end_reason='personal_turn_end' WHERE id=e.id;
  END IF;
  PERFORM combat_effects_private.record_event(ek,e.id,e.source_declaration_id,'turn_end',res);
  all_res:=all_res||jsonb_build_array(res);
 END LOOP;
 PERFORM combat_effects_private.record_event(turn_key,NULL,NULL,'turn_end',
  jsonb_build_object('session_id',p_session,'actor_id',p_actor,'turn_id',p_turn,'adapter',p_adapter,'effects',all_res));
 RETURN all_res;
END $function$;
CREATE OR REPLACE FUNCTION combat_panel_private.catalog_result_label_v1(p jsonb)
 RETURNS text
 LANGUAGE plpgsql
 IMMUTABLE
 SET search_path TO ''
AS $function$
DECLARE g jsonb;r jsonb;
BEGIN
 IF clan_akimichi_private.common_result_label_v1(p)<>'' THEN RETURN clan_akimichi_private.common_result_label_v1(p);END IF;
 IF p->>'cure_contract'='palmo-curativo/1' THEN
  IF p->>'reason'='healed' AND jsonb_typeof(p->'healing_applied')='number' THEN
   RETURN ' · Palmo Curativo: recuperati '||(p->>'healing_applied')||' PV'
    ||CASE WHEN p->'revived'='true'::jsonb THEN ' · torna operativo, senza turno aggiuntivo' ELSE '' END;
  END IF;
  RETURN ' · Palmo Curativo: cura non applicata'
   ||CASE p->>'reason' WHEN 'healer_ko' THEN ' · medico fuori combattimento'
    WHEN 'controller_changed' THEN ' · controllo dell’attore cambiato'
    WHEN 'target_no_longer_eligible_or_in_contact' THEN ' · bersaglio non più idoneo o a contatto'
    WHEN 'already_full' THEN ' · PV già al massimo' ELSE '' END;
 END IF;
 IF p#>>'{nara_strangle,contract}'='nara-strangolamento/1' THEN RETURN ' · Strangolamento dell’Ombra: '||CASE WHEN p#>'{nara_strangle,applied}'='true'::jsonb THEN p#>>'{nara_strangle,damage}'||' PV inflitti' ELSE 'nessun danno: legame non valido o mantenimento non disponibile' END;END IF;
 g:=p->'genjutsu_server';
 IF g->>'contract'='paralisi-movement/1' THEN
  RETURN ' · Paralisi illusoria: '||CASE g->>'reason'
   WHEN 'applied' THEN 'applicata al solo movimento del prossimo turno; azione e reazioni consentite restano disponibili'
   WHEN 'mental_contest_lost' THEN 'resistenza mentale riuscita, nessun blocco'
   WHEN 'kai_negated' THEN 'Dispersione riuscita, applicazione negata'
   WHEN 'already_active_no_refresh' THEN 'effetto già presente, non prolungato'
   WHEN 'target_inoperative' THEN 'bersaglio già fuori combattimento, nessun effetto'
   ELSE 'nessun danno ai PV' END;
 END IF;
 r:=p->'mental_release';
 IF r->>'contract'='paralisi-release/1' THEN
  RETURN ' · '||CASE WHEN r->>'mode'='kai' THEN 'Dispersione' ELSE 'Contesa mentale di liberazione' END||': '
   ||CASE r->>'reason' WHEN 'released' THEN 'blocco scelto sciolto'
    WHEN 'contest_failed' THEN 'contesa non riuscita'
    WHEN 'kai_below_power' THEN 'rilascio non riuscito'
    WHEN 'contact_lost' THEN 'contatto perso, nessuna liberazione'
    WHEN 'actor_inoperative' THEN 'personaggio già fuori combattimento'
    WHEN 'effect_ended' THEN 'effetto scelto già terminato'
    ELSE 'esito nel referto' END
   ||' · principale consumata, nessuna azione aggiuntiva';
 END IF;
 RETURN '';
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
        and stop_offer.source_payload->>'aburame_operation' IN('release_stop','verme_staff_prepare')
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
CREATE OR REPLACE FUNCTION combat_panel_private.master_admin_offers(p_context uuid, p_expected bigint, p_source jsonb)
 RETURNS void
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO ''
AS $function$
DECLARE c combat_panel_private.contexts%ROWTYPE; m public.master_v2_sessions%ROWTYPE;
 r public.combat_v2_rounds%ROWTYPE; item jsonb; oid uuid; gid uuid; score integer; base jsonb; permitted boolean; candidate record;
BEGIN
 c:=combat_panel_private.owned_context(p_context,p_expected);
 SELECT * INTO m FROM public.master_v2_sessions WHERE id=(p_source#>>'{master,id}')::uuid AND location_id=c.location_id;
 IF m.id IS NULL OR (m.master_user IS DISTINCT FROM auth.uid() AND NOT public.combat_v2_is_admin(auth.uid())) THEN RETURN; END IF;
 IF m.stato IN ('chiusa','annullata') THEN RETURN; END IF;
 PERFORM combat_panel_private.master_placement_offers(c.id,c.context_version,p_source);
 SELECT * INTO r FROM public.combat_v2_rounds WHERE id=c.round_id;
 base:=jsonb_build_object('adapter','master_v2','master_session_id',m.id,'control_version',m.control_version);
 IF NOT EXISTS(SELECT 1 FROM public.combat_v2_sessions WHERE master_session_id=m.id AND state NOT IN ('risolto','chiuso','annullato'))
   AND NOT EXISTS(SELECT 1 FROM public.combat_v2_sessions s JOIN public.combat_v2_rounds cr ON cr.session_id=s.id
     WHERE s.master_session_id=m.id AND cr.state<>'narrato' AND NOT (s.state='chiuso' AND clan_hoki_private.master_ko_successor(cr.id)))
   AND NOT EXISTS(SELECT 1 FROM public.locations l WHERE l.id=c.location_id AND l.is_test
     AND (m.mission_id IS NOT NULL OR EXISTS(SELECT 1 FROM public.mission_run_state WHERE master_session_id=m.id))) THEN
   oid:=combat_panel_private.create_offer(c.id,c.context_version,'administration','administration','Chiudi attivita',false,
     base||jsonb_build_object('dispatch','activity_close'));
   IF m.tipo='quest' THEN
     gid:=combat_panel_private.add_group(oid,'Esito della missione','generic','single',1,1);
     PERFORM combat_panel_private.add_choice(gid,'Successo',jsonb_build_object('close_outcome','successo'));
     PERFORM combat_panel_private.add_choice(gid,'Fallimento',jsonb_build_object('close_outcome','fallimento'));
   END IF;
   IF EXISTS(SELECT 1 FROM public.locations WHERE id=c.location_id AND NOT is_test) THEN
     gid:=combat_panel_private.add_group(oid,'Role in chat','mode','single',1,1);
     PERFORM combat_panel_private.add_choice(gid,'Lascia aperta la role',jsonb_build_object('close_role',false));
     PERFORM combat_panel_private.add_choice(gid,'Concludi anche la role',jsonb_build_object('close_role',true));
   END IF;
   PERFORM combat_panel_private.add_input(oid,'Nota conclusiva','close_note',false,5000);
 END IF;
 IF m.stato IN ('preparazione','in_corso','sospesa') THEN
   IF m.master_user=auth.uid() AND EXISTS(SELECT 1 FROM public.profiles
     WHERE id<>auth.uid() AND role IN ('master','admin')) THEN
     oid:=combat_panel_private.create_offer(c.id,c.context_version,'administration','administration','Consegna a un altro Master',false,
       base||jsonb_build_object('dispatch','handover'));
     gid:=combat_panel_private.add_group(oid,'Nuovo Master','generic','single',1,1);
     FOR candidate IN SELECT id,username FROM public.profiles WHERE id<>auth.uid() AND role IN ('master','admin') ORDER BY username,id LOOP
       PERFORM combat_panel_private.add_choice(gid,coalesce(nullif(candidate.username,''),'Master'),jsonb_build_object('new_master',candidate.id));
     END LOOP;
     PERFORM combat_panel_private.add_input(oid,'Motivo della consegna','reason',true,500);
   END IF;
   IF public.combat_v2_is_admin(auth.uid()) AND m.master_user IS DISTINCT FROM auth.uid() THEN
     oid:=combat_panel_private.create_offer(c.id,c.context_version,'administration','administration','Subentra come Master',false,
       base||jsonb_build_object('dispatch','override'));
     PERFORM combat_panel_private.add_input(oid,'Motivo del subentro','reason',true,500);
   END IF;
   IF NOT(m.tipo='quest' AND m.mission_id IS NOT NULL) AND NOT EXISTS(
     SELECT 1 FROM public.mission_run_state WHERE master_session_id=m.id) THEN
     oid:=combat_panel_private.create_offer(c.id,c.context_version,'administration','administration','Chiudi scena',false,
       base||jsonb_build_object('dispatch','scene_close'));
     PERFORM combat_panel_private.add_input(oid,'Motivo della chiusura','reason',true,500);
   END IF;
 END IF;
 IF m.stato='sospesa' AND m.master_user=auth.uid() THEN
   PERFORM combat_panel_private.create_offer(c.id,c.context_version,'administration','administration','Riprendi',false,
     base||jsonb_build_object('dispatch','resume'));
 ELSIF m.stato IN ('preparazione','in_corso') THEN
   oid:=combat_panel_private.create_offer(c.id,c.context_version,'administration','administration','Sospendi',false,
     base||jsonb_build_object('dispatch','suspend'));
   gid:=combat_panel_private.add_group(oid,'Modalità','mode','single',1,1);
   IF NOT EXISTS(SELECT 1 FROM public.combat_v2_sessions s JOIN public.combat_v2_rounds cr ON cr.session_id=s.id
     WHERE s.master_session_id=m.id AND cr.state<>'narrato' AND NOT (s.state='chiuso' AND clan_hoki_private.master_ko_successor(cr.id))) THEN
     PERFORM combat_panel_private.add_choice(gid,'Pausa a fine round',jsonb_build_object('suspend_mode','normale'));
   END IF;
   PERFORM combat_panel_private.add_choice(gid,'Pausa immediata',jsonb_build_object('suspend_mode','emergenza'));
   PERFORM combat_panel_private.add_input(oid,'Motivo','reason',true,500);
 END IF;
 PERFORM combat_v2_staff_nb_internal.roster_offers(c.id,c.context_version,m.id);
 IF m.master_user IS DISTINCT FROM auth.uid() OR m.stato='sospesa' OR r.id IS NULL THEN RETURN; END IF;
 IF r.evaluation_mode='umana' AND r.state NOT IN ('congelato','risoluzione','risolto','narrazione','narrato') THEN
   FOR item IN SELECT value FROM jsonb_array_elements(p_source->'ratings_pending') LOOP
     oid:=combat_panel_private.create_offer(c.id,c.context_version,'administration','administration',
       'Valuta '||(item->>'actor_name')||' · '||(item->>'kind'),false,
       base||jsonb_build_object('dispatch','rating','declaration_id',item->'declaration_id'));
     gid:=combat_panel_private.add_group(oid,'Valutazione','generic','single',1,1);
     FOR score IN -3..3 LOOP
       PERFORM combat_panel_private.add_choice(gid,score::text,jsonb_build_object('rating_value',score));
     END LOOP;
     PERFORM combat_panel_private.add_input(oid,'Motivazione','reason',false,500);
   END LOOP;
 END IF;
 IF r.state NOT IN ('risolto','narrazione','narrato','risoluzione') THEN
   permitted:=(SELECT count(*) FROM public.combat_v2_declarations WHERE round_id=r.id
     AND kind IN ('attacco','movimento','utilita','passa'))=combat_consumer_private.expected_main_count(r.id)
     AND combat_v2_multitarget_internal.round_complete(r.id)
     AND (r.evaluation_mode='neutra' OR NOT EXISTS(SELECT 1 FROM public.combat_v2_declarations d
       JOIN public.combat_v2_actors a ON a.id=d.actor_id AND a.actor_kind='pg'
       WHERE d.round_id=r.id AND d.kind IN ('attacco','difesa') AND NOT EXISTS(
         SELECT 1 FROM public.combat_v2_ratings x WHERE x.declaration_id=d.id AND x.is_active)));
   IF permitted THEN
     PERFORM combat_panel_private.create_offer(c.id,c.context_version,'administration','administration','Risolvi round',false,
       base||jsonb_build_object('dispatch','resolve'));
   END IF;
 ELSIF r.state IN ('risolto','narrazione') THEN
   PERFORM combat_panel_private.create_offer(c.id,c.context_version,'administration','administration','Pubblica esito del round',true,
     base||jsonb_build_object('dispatch','narrate'));
 END IF;
END $function$;
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
CREATE OR REPLACE FUNCTION combat_panel_private.nara_shadow_level_v1(p_actor uuid)
 RETURNS integer
 LANGUAGE plpgsql
 STABLE SECURITY DEFINER
 SET search_path TO ''
AS $function$
DECLARE
  actor public.combat_v2_actors%ROWTYPE;
  profile jsonb;
  level_id record;
  acquired_level integer;
BEGIN
  SELECT a.* INTO actor
  FROM public.combat_v2_actors a
  JOIN public.combat_v2_sessions s ON s.id = a.session_id
  WHERE a.id = p_actor AND a.state = 'attivo' AND a.companion_id IS NULL
    AND s.state = 'in_corso' AND s.closed_at IS NULL;
  IF NOT FOUND THEN
    RETURN NULL;
  END IF;

  IF actor.actor_kind = 'pg' AND combat_panel_private.nara_adv_scope_v1(actor.id) AND EXISTS(SELECT 1 FROM combat_panel_private.nara_adv_staff_v1 p WHERE p.actor_id=actor.id AND p.session_id=actor.session_id AND p.controller_user=actor.controller_user AND p.controller_version=actor.controller_version AND p.profile=actor.mechanics_snapshot->'nara_adv_profile' AND p.profile_sha256=public.combat_v2_sha256(p.profile)) THEN RETURN 2;END IF;
  IF actor.actor_kind = 'pg' THEN
    profile := clan_innata_narrative_private.staff_profile_actor_v1(actor.id);
    IF profile->>'family' = 'nara' AND profile->>'lifecycle_kind' = 'passive_permission'
      AND profile->>'tier' IN ('1','2','3','4') THEN
      RETURN (profile->>'tier')::integer;
    END IF;
    SELECT max(t.level) INTO acquired_level
    FROM public.characters c
    JOIN public.character_abilities owned ON owned.character_id = c.id AND owned.state = 'attiva'
    JOIN public.clan_techniques t ON t.id = owned.technique_id
    WHERE c.id = actor.character_id AND c.user_id = actor.controller_user AND c.clan = 'Nara'
      AND t.is_active AND t.is_innata AND t.clan = 'Nara'
      AND t.id IN (
        '20341270-6241-45cd-9633-437d3ce80447'::uuid,
        '32d0749c-6167-45da-8880-bb3f60dd401f'::uuid,
        'a4704025-1ef8-43c9-9e5b-113582a7e621'::uuid,
        '6c56bb2f-4936-4c43-873e-dde65fe42d2b'::uuid
      )
      AND t.level BETWEEN 1 AND 4
      AND EXISTS (
        SELECT 1
        FROM jsonb_array_elements(coalesce(actor.mechanics_snapshot->'abilities','[]'::jsonb)) x
        WHERE x->>'source' = 'clan' AND x->>'id' = t.id::text
      );
    RETURN acquired_level;
  END IF;

  IF actor.actor_kind = 'png' THEN
    FOR level_id IN
      SELECT * FROM (VALUES
        (4,'6c56bb2f-4936-4c43-873e-dde65fe42d2b'::uuid),
        (3,'a4704025-1ef8-43c9-9e5b-113582a7e621'::uuid),
        (2,'32d0749c-6167-45da-8880-bb3f60dd401f'::uuid),
        (1,'20341270-6241-45cd-9633-437d3ce80447'::uuid)
      ) AS v(level, technique_id) ORDER BY level DESC
    LOOP
      IF clan_innata_narrative_private.png_profile_valid_v1(actor.id,level_id.technique_id) THEN
        RETURN level_id.level;
      END IF;
    END LOOP;
  END IF;

  RETURN NULL;
END;
$function$;
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
CREATE OR REPLACE FUNCTION combat_spatial.movement_commit(p_capability uuid, p_request_key uuid, p_root uuid)
 RETURNS jsonb
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO ''
AS $function$
declare c combat_spatial.movement_capabilities%rowtype; i combat_spatial.arena_instances%rowtype; a combat_spatial.actor_states%rowtype;
  ch combat_spatial.movement_semantic_choices%rowtype; fp text; replay jsonb; t numeric; ex numeric; ey numeric; eid uuid; result jsonb; limit_x numeric; limit_y numeric; shared boolean; regions jsonb; terrain jsonb; cost_cap combat_panel_private.movement_cost_capabilities%rowtype; clone_endpoint jsonb;grid_endpoint jsonb;
begin
  fp:=combat_spatial.server_fingerprint('movement_commit',jsonb_build_object('capability',p_capability,'root',p_root));
  replay:=combat_spatial.receipt_replay(p_request_key,'movement_commit',fp); if replay is not null then return replay; end if;
  select * into strict c from combat_spatial.movement_capabilities where capability_id=p_capability;
  perform 1 from public.combat_v2_sessions s join combat_spatial.arena_instances ai on ai.encounter_id=s.id where ai.instance_id=c.instance_id for update of s;
  perform 1 from public.combat_v2_actors ca join combat_spatial.arena_instances ai on ai.encounter_id=ca.session_id where ai.instance_id=c.instance_id order by ca.id for update of ca;
  select * into strict i from combat_spatial.arena_instances where instance_id=c.instance_id for update;
  select * into strict a from combat_spatial.actor_states where instance_id=c.instance_id and actor_id=c.actor_id for update;
  select * into strict ch from combat_spatial.movement_semantic_choices where instance_id=c.instance_id and actor_id=c.actor_id and choice_key=c.choice_key;
  if c.state<>'offered' or a.body_version<>c.actor_body_version or ch.choice_version<>c.choice_version then raise exception 'spatial_capability_stale'; end if;
  PERFORM clan_akimichi_private.common_flush_upkeep_v1(c.actor_id);
  shared:=combat_panel_private.shared_movement_scope(i.instance_id);
  if shared then
    if combat_panel_private.movement_block_reason(a.actor_id) is not null then
      raise exception 'panel_body_movement_blocked' using errcode='40001';
    end if;
    if i.state<>'open' or a.state<>'active' or not ch.enabled
      or (a.x_m,a.y_m) is distinct from (c.start_x_m,c.start_y_m)
      or combat_spatial.distance_m(c.start_x_m,c.start_y_m,c.end_x_m,c.end_y_m)>ch.max_budget_m then
      raise exception 'panel_movement_capability_invalid' using errcode='40001';
    end if;
    -- Resta sul prefisso accettato: la scomparsa di un ostacolo non estende
    -- la distanza scelta. Un nuovo ostacolo puo soltanto accorciare quel path.
    select * into cost_cap from combat_panel_private.movement_cost_capabilities where capability_id=c.capability_id;
    regions:=combat_panel_private.movement_regions_for_body(i.instance_id,c.actor_id);
    if cost_cap.capability_id is null or cost_cap.regions_fingerprint<>md5(regions::text) then
      raise exception 'panel_movement_terrain_stale' using errcode='40001'; end if;
    limit_x:=c.end_x_m; limit_y:=c.end_y_m;
  else limit_x:=ch.endpoint_x_m; limit_y:=ch.endpoint_y_m; end if;
  grid_endpoint:=combat_panel_private.melee_contact_integer_endpoint(c.instance_id,c.actor_id,c.choice_key,a.x_m,a.y_m,limit_x,limit_y,
    CASE WHEN shared THEN least(cost_cap.budget_m,ch.max_budget_m) ELSE ch.max_budget_m END,
    CASE WHEN shared THEN regions ELSE '[]'::jsonb END);
  ex:=(grid_endpoint->>'x_m')::numeric;ey:=(grid_endpoint->>'y_m')::numeric;
  if shared then
    clone_endpoint:=clan_sabaku_private.clone_movement_intercept(c.capability_id,p_root,ex,ey);
    ex:=round((clone_endpoint->>'x_m')::numeric); ey:=round((clone_endpoint->>'y_m')::numeric);
  end if;
  if combat_panel_private.melee_contact_path_t(c.instance_id,c.actor_id,c.choice_key,a.x_m,a.y_m,ex,ey)<1 then
    raise exception 'integer_movement_final_point_invalid' using errcode='40001'; end if;
  if shared then
    terrain:=combat_panel_private.impervious_path_profile(a.x_m,a.y_m,ex,ey,regions);
    if (terrain->>'required_budget_m')::numeric>least(cost_cap.budget_m,ch.max_budget_m)+0.000000001 then
      raise exception 'panel_movement_terrain_budget_exceeded' using errcode='40001'; end if;
  end if;
  eid:=md5(c.instance_id::text||p_root::text||p_capability::text)::uuid;
  update combat_spatial.actor_states set x_m=ex,y_m=ey,body_version=body_version+1 where instance_id=c.instance_id and actor_id=c.actor_id returning x_m,y_m into ex,ey;
  update combat_spatial.arena_instances set map_version=map_version+1 where instance_id=c.instance_id;
  update combat_spatial.movement_capabilities set state='committed' where capability_id=p_capability;
  insert into combat_spatial.spatial_events values(eid,c.instance_id,'movement_settled',p_root,c.actor_id,null,
    jsonb_build_object('body_version',a.body_version),jsonb_build_object('body_version',a.body_version+1,'d_eff_m',round(combat_spatial.distance_m(a.x_m,a.y_m,ex,ey),0)),
    jsonb_build_object('before','posizione iniziale','impact','percorso assestato','after','posizione finale'),clock_timestamp());
  if shared then
    insert into combat_panel_private.movement_cost_receipts(event_id,capability_id,distance_m,cost_m)
      values(eid,c.capability_id,(terrain->>'distance_m')::numeric,
        greatest((terrain->>'distance_m')::numeric,least((terrain->>'required_budget_m')::numeric,cost_cap.budget_m,ch.max_budget_m)));
  end if;
  result:=jsonb_build_object('event_id',eid,'status','committed','d_eff_m',round(combat_spatial.distance_m(a.x_m,a.y_m,ex,ey),0),'replayed',false);
  insert into combat_spatial.request_receipts values(p_request_key,'movement_commit',fp,result,clock_timestamp()); return result;
end $function$;
CREATE OR REPLACE FUNCTION combat_v2_genjutsu_internal.ally_contact(p_actor uuid, p_target uuid)
 RETURNS jsonb
 LANGUAGE plpgsql
 STABLE SECURITY DEFINER
 SET search_path TO ''
AS $function$
DECLARE a public.combat_v2_actors%ROWTYPE;t public.combat_v2_actors%ROWTYPE;
 i combat_spatial.arena_instances%ROWTYPE;ab combat_spatial.actor_states%ROWTYPE;tb combat_spatial.actor_states%ROWTYPE;
BEGIN
 IF EXISTS(SELECT 1 FROM public.combat_v2_actors WHERE id=p_actor AND actor_kind='png') THEN
  RETURN combat_v2_staff_nb_internal.kai_contact(p_actor,p_target);END IF;
 SELECT * INTO a FROM public.combat_v2_actors WHERE id=p_actor;
 SELECT * INTO t FROM public.combat_v2_actors WHERE id=p_target;
 IF a.id IS NULL OR t.id IS NULL OR a.session_id IS DISTINCT FROM t.session_id
  OR a.team_key IS DISTINCT FROM t.team_key OR a.actor_kind<>'pg' OR t.actor_kind<>'pg'
  OR a.companion_id IS NOT NULL OR t.companion_id IS NOT NULL OR a.state<>'attivo' OR t.state<>'attivo'
  OR coalesce((a.mechanics_snapshot->>'vita')::integer,0)<=0 OR coalesce((t.mechanics_snapshot->>'vita')::integer,0)<=0 THEN RETURN NULL;END IF;
 IF a.id=t.id THEN RETURN jsonb_build_object('self',true,'actor_id',a.id,'controller_version',a.controller_version);END IF;
 SELECT * INTO i FROM combat_spatial.arena_instances WHERE encounter_id=a.session_id AND context_source IN('ordinary','panel_master') AND state='open';
 IF i.instance_id IS NULL THEN RETURN NULL;END IF;
 SELECT * INTO ab FROM combat_spatial.actor_states WHERE instance_id=i.instance_id AND actor_id=a.id AND state='active';
 SELECT * INTO tb FROM combat_spatial.actor_states WHERE instance_id=i.instance_id AND actor_id=t.id AND state='active';
 IF ab.actor_id IS NULL OR tb.actor_id IS NULL OR NOT EXISTS(SELECT 1 FROM combat_spatial.viewer_grants
  WHERE instance_id=i.instance_id AND viewer_principal_id=exam_regia_private.actor_principal(a.id,a.controller_user)
  AND subject_actor_id=t.id AND can_view_map) THEN RETURN NULL;END IF;
 IF combat_spatial.distance_m(ab.x_m,ab.y_m,tb.x_m,tb.y_m)>2
  OR combat_spatial.path_first_block_t(i.instance_id,a.id,ab.x_m,ab.y_m,tb.x_m,tb.y_m,t.id)<1 THEN RETURN NULL;END IF;
 RETURN jsonb_build_object('self',false,'instance_id',i.instance_id,'actor_body_version',ab.body_version,'target_body_version',tb.body_version,
  'actor_x',ab.x_m,'actor_y',ab.y_m,'target_x',tb.x_m,'target_y',tb.y_m);
END $function$;
CREATE OR REPLACE FUNCTION combat_v2_genjutsu_internal.master_options(p_context uuid, p_expected bigint)
 RETURNS void
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO ''
AS $function$
DECLARE c combat_panel_private.contexts%ROWTYPE;ri jsonb;
BEGIN
 c:=combat_panel_private.owned_context(p_context,p_expected);
 IF c.activity_kind<>'master_v2' OR c.command_actor_id IS NULL OR NOT (combat_v2_genjutsu_internal.runtime_allowed(c.command_actor_id) OR combat_v2_staff_nb_internal.kai_authority(c.command_actor_id) IS NOT NULL) THEN RETURN;END IF;
 PERFORM combat_v2_genjutsu_internal.open_turn(c.activity_id,c.command_actor_id);
 IF combat_v2_genjutsu_internal.preset_ready(c.command_actor_id) AND NOT EXISTS(SELECT 1 FROM combat_panel_private.offers
  WHERE context_id=c.id AND context_version=c.context_version AND state='offered' AND source_payload->>'dispatch'='other_control'
  AND source_payload->>'technique_id'='31d5d554-44d1-4042-9920-3ddd3bedff7e') THEN
  PERFORM combat_panel_private.create_offer(c.id,c.context_version,'control','control','Prepara prova: Paralisi illusoria',false,
   jsonb_build_object('adapter','master_v2','dispatch','other_control','other_operation','staff_profile','technique_id','31d5d554-44d1-4042-9920-3ddd3bedff7e'::uuid));
 END IF;
 FOR ri IN SELECT value FROM jsonb_array_elements(combat_v2_genjutsu_internal.release_intents(c.command_actor_id)) LOOP
  IF NOT EXISTS(SELECT 1 FROM combat_panel_private.offers o WHERE o.context_id=c.id AND o.context_version=c.context_version AND o.state='offered'
   AND o.source_payload->>'genjutsu_release_version'='paralisi-release/1' AND o.source_payload->'intent'=ri->'intent') THEN
   PERFORM combat_panel_private.create_offer(c.id,c.context_version,'action','declare',ri->>'label',true,
    jsonb_build_object('adapter','master_v2','dispatch','action','kind','utilita','genjutsu_release_version','paralisi-release/1','intent',ri->'intent'));
  END IF;
 END LOOP;
 -- Ordinary action offers for Master come from actor_meta through the unchanged action producer;
 -- no new public command or choice group is introduced.
END $function$;
CREATE OR REPLACE FUNCTION combat_v2_genjutsu_internal.release_intents(p_actor uuid)
 RETURNS jsonb
 LANGUAGE plpgsql
 STABLE SECURITY DEFINER
 SET search_path TO ''
AS $function$
DECLARE a public.combat_v2_actors%ROWTYPE;t public.combat_v2_actors%ROWTYPE;e combat_v2_genjutsu_internal.effects%ROWTYPE;out jsonb:='[]';kai boolean;c jsonb;
BEGIN
 SELECT * INTO a FROM public.combat_v2_actors WHERE id=p_actor AND controller_user=exam_regia_private.current_principal();
 IF a.id IS NULL OR NOT (combat_v2_genjutsu_internal.runtime_allowed(a.id) OR combat_v2_staff_nb_internal.kai_authority(a.id) IS NOT NULL) THEN RETURN out;END IF;
 c:=combat_effects_private.personal_turn(a.session_id,a.id);IF c->>'useful' IS DISTINCT FROM 'true' THEN RETURN out;END IF;
 kai:=CASE WHEN a.actor_kind='png' THEN combat_v2_staff_nb_internal.kai_authority(a.id) IS NOT NULL ELSE public.combat_v2_actor_ability(a.id,'jutsu','9f12fc98-bc97-4b95-9bcc-7ce359ebbe4f'::uuid,true) IS NOT NULL END;
 FOR e IN SELECT * FROM combat_v2_genjutsu_internal.effects WHERE session_id=a.session_id AND state='active' ORDER BY id LOOP
  IF e.target_actor_id=a.id THEN
   out:=out||jsonb_build_array(jsonb_build_object('label','Spezza la paralisi · contesa mentale','intent',jsonb_build_object('kind','utilita','ability_source','clan',
    'ability_id','31d5d554-44d1-4042-9920-3ddd3bedff7e'::uuid,'target_actor',a.id)));
  END IF;
  SELECT * INTO STRICT t FROM public.combat_v2_actors WHERE id=e.target_actor_id;
  IF kai AND combat_v2_genjutsu_internal.ally_contact(a.id,t.id) IS NOT NULL THEN
   out:=out||jsonb_build_array(jsonb_build_object('label',CASE WHEN t.id=a.id THEN 'Dispersione · libera te stesso' ELSE 'Dispersione · libera il compagno' END,
    'intent',jsonb_build_object('kind','utilita','ability_source','jutsu','ability_id','9f12fc98-bc97-4b95-9bcc-7ce359ebbe4f'::uuid,'target_actor',t.id)));
  END IF;
 END LOOP;RETURN out;
END $function$;
CREATE OR REPLACE FUNCTION combat_v2_genjutsu_internal.release_meta(p_round uuid, p_actor uuid, p_request uuid, p_intent jsonb)
 RETURNS jsonb
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO ''
AS $function$
DECLARE a public.combat_v2_actors%ROWTYPE;e combat_v2_genjutsu_internal.effects%ROWTYPE;old combat_v2_genjutsu_internal.release_plans%ROWTYPE;
 source jsonb;m jsonb;mode text;chosen jsonb;
BEGIN
 IF p_intent->>'kind' IS DISTINCT FROM 'utilita' OR NOT (
  (p_intent->>'ability_source'='clan' AND p_intent->>'ability_id'='31d5d554-44d1-4042-9920-3ddd3bedff7e') OR
  (p_intent->>'ability_source'='jutsu' AND p_intent->>'ability_id'='9f12fc98-bc97-4b95-9bcc-7ce359ebbe4f')) THEN RETURN NULL;END IF;
 IF p_request IS NULL OR exam_regia_private.current_principal() IS NULL THEN RAISE EXCEPTION 'paralisi_release_auth_required';END IF;
 SELECT * INTO STRICT a FROM public.combat_v2_actors WHERE id=p_actor AND controller_user=exam_regia_private.current_principal();
 PERFORM combat_effects_private.lock_context(a.session_id);
 PERFORM 1 FROM public.combat_v2_rounds WHERE id=p_round AND session_id=a.session_id AND phase='raccolta_azioni' FOR UPDATE;
 IF NOT FOUND OR public.combat_v2_sanitize_intent(p_intent,false) IS DISTINCT FROM p_intent THEN RAISE EXCEPTION 'paralisi_release_round_invalid';END IF;
 SELECT value INTO chosen FROM jsonb_array_elements(combat_v2_genjutsu_internal.release_intents(a.id)) WHERE value->'intent'=p_intent;
 IF chosen IS NULL THEN RAISE EXCEPTION 'paralisi_release_not_offered' USING ERRCODE='42501';END IF;
 SELECT * INTO STRICT e FROM combat_v2_genjutsu_internal.effects WHERE session_id=a.session_id AND target_actor_id=(p_intent->>'target_actor')::uuid AND state='active' FOR UPDATE;
 IF jsonb_typeof(e.profile->'source_pool') IS DISTINCT FROM 'number' OR jsonb_typeof(a.mechanics_snapshot->'mente') IS DISTINCT FROM 'number'
  OR jsonb_typeof(a.mechanics_snapshot->'genjutsu') IS DISTINCT FROM 'number' THEN RAISE EXCEPTION 'paralisi_release_snapshot_invalid';END IF;
 mode:=CASE WHEN p_intent->>'ability_source'='jutsu' THEN 'kai' ELSE 'contest' END;
 m:=jsonb_build_object('genjutsu_release_version','paralisi-release/1','kind','abilita','usage','principale','chakra_cost',0,'damage_base',0,
  'release_mode',mode,'effect_id',e.id,'target_actor_id',e.target_actor_id,'source_pool',e.profile->'source_pool');
 IF a.actor_kind='png' AND (mode<>'kai' OR combat_v2_staff_nb_internal.kai_authority(a.id) IS NULL) THEN RAISE EXCEPTION 'staff_nb_release_authority_invalid' USING ERRCODE='42501';END IF;
 source:=jsonb_build_object('session_id',a.session_id,'round_id',p_round,'actor_id',a.id,'principal',exam_regia_private.current_principal(),
  'controller_version',a.controller_version,'intent',p_intent,'meta',m,'mente',a.mechanics_snapshot->'mente','genjutsu',a.mechanics_snapshot->'genjutsu','contact',CASE WHEN mode='kai' THEN combat_v2_genjutsu_internal.ally_contact(a.id,e.target_actor_id) ELSE NULL END);
 IF a.actor_kind='png' THEN source:=source||jsonb_build_object('provider_proof',combat_v2_staff_nb_internal.kai_authority(a.id));END IF;
 SELECT * INTO old FROM combat_v2_genjutsu_internal.release_plans WHERE actor_id=a.id AND round_id=p_round;
 IF FOUND THEN
  IF old.request_id IS DISTINCT FROM p_request OR old.source IS DISTINCT FROM source OR old.transaction_id<>txid_current() THEN RAISE EXCEPTION 'paralisi_release_conflict';END IF;RETURN m;
 END IF;
 INSERT INTO combat_v2_genjutsu_internal.release_plans(actor_id,round_id,request_id,effect_id,source,source_sha256,transaction_id)
 VALUES(a.id,p_round,p_request,e.id,source,public.combat_v2_sha256(source),txid_current());RETURN m;
END $function$;
CREATE OR REPLACE FUNCTION combat_v2_genjutsu_internal.resolve_release(p_declaration uuid)
 RETURNS jsonb
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO ''
AS $function$
DECLARE p combat_v2_genjutsu_internal.release_plans%ROWTYPE;d public.combat_v2_declarations%ROWTYPE;e combat_v2_genjutsu_internal.effects%ROWTYPE;
 a public.combat_v2_actors%ROWTYPE;ok boolean;calc jsonb;res jsonb;entropy bytea;ctx text;dice integer[];margin integer;rng jsonb;
BEGIN
 SELECT * INTO STRICT d FROM public.combat_v2_declarations WHERE id=p_declaration FOR UPDATE;
 SELECT * INTO STRICT p FROM combat_v2_genjutsu_internal.release_plans WHERE declaration_id=d.id FOR UPDATE;
 IF p.result IS NOT NULL THEN IF p.result_sha256 IS DISTINCT FROM public.combat_v2_sha256(p.result) THEN RAISE EXCEPTION 'paralisi_release_receipt_invalid';END IF;RETURN p.result;END IF;
 IF d.kind<>'utilita' OR d.state<>'congelata' OR p.source_sha256 IS DISTINCT FROM public.combat_v2_sha256(p.source)
  OR p.declaration_sha256 IS DISTINCT FROM combat_effects_private.declaration_fingerprint(d.id)
  OR NOT EXISTS(SELECT 1 FROM public.combat_v2_rounds WHERE id=d.round_id AND phase='risoluzione') THEN RAISE EXCEPTION 'paralisi_release_source_invalid';END IF;
 SELECT * INTO STRICT a FROM public.combat_v2_actors WHERE id=d.actor_id FOR UPDATE;
 SELECT * INTO STRICT e FROM combat_v2_genjutsu_internal.effects WHERE id=p.effect_id FOR UPDATE;
 IF a.controller_version::text IS DISTINCT FROM p.source->>'controller_version' OR a.controller_user::text IS DISTINCT FROM p.source->>'principal' THEN RAISE EXCEPTION 'paralisi_release_controller_stale';END IF;
 IF a.actor_kind='png' AND (p.source#>>'{meta,release_mode}' IS DISTINCT FROM 'kai' OR p.source->'provider_proof' IS NULL
  OR p.source->'provider_proof' IS DISTINCT FROM combat_v2_staff_nb_internal.kai_frozen_authority(a.id)) THEN
  RAISE EXCEPTION 'staff_nb_release_frozen_proof_invalid' USING ERRCODE='42501';END IF;
 IF a.state<>'attivo' OR e.state<>'active' THEN
  res:=jsonb_build_object('kind','utilita','mental_release',jsonb_build_object('contract','paralisi-release/1','effect_id',e.id,'mode',CASE WHEN p.source#>>'{meta,release_mode}'='kai' THEN 'kai' ELSE 'mental_contest' END,'attempted',false,'released',false,'still_blocked',e.state='active','reason',CASE WHEN a.state<>'attivo' THEN 'actor_inoperative' ELSE 'effect_ended' END,'main_consumed',true,'chakra_cost',0,'damage_applied',0));
 ELSE
  IF p.source#>>'{meta,release_mode}'='kai' THEN
   IF combat_v2_genjutsu_internal.ally_contact(a.id,e.target_actor_id) IS NULL THEN
    ok:=false;calc:=jsonb_build_object('reason','contact_lost','success',false);
   ELSE ok:=(p.source->>'mente')::numeric>=20;calc:=jsonb_build_object('mode','kai','mente',p.source->'mente','power',20,'success',ok);END IF;
  ELSE
   ctx:='combat-v2/paralisi-release/1:'||a.session_id::text||':'||d.round_id::text||':'||d.id::text;
   entropy:=extensions.gen_random_bytes(32);
   dice:=ARRAY[public.combat_v2_derive_d10(entropy,ctx,1),public.combat_v2_derive_d10(entropy,ctx,2),public.combat_v2_derive_d10(entropy,ctx,3),public.combat_v2_derive_d10(entropy,ctx,4)];
   margin:=floor(((p.source->>'mente')::numeric+(p.source->>'genjutsu')::numeric)/5)::integer+dice[1]+dice[2]
    -floor((e.profile->>'source_pool')::numeric/5)::integer-dice[3]-dice[4];ok:=margin>=0;
   calc:=jsonb_build_object('mode','mental_contest','release_pool',(p.source->>'mente')::numeric+(p.source->>'genjutsu')::numeric,
    'source_pool',e.profile->'source_pool','margin',margin,'success',ok,'damage_applied',0);
   rng:=combat_v2_private.rng_seal(a.session_id,d.round_id,d.id,'escape',ctx,entropy,calc);
  END IF;
  IF ok THEN UPDATE combat_v2_genjutsu_internal.effects SET state='ended',state_version=state_version+1,ended_at=clock_timestamp(),end_reason='mental_release' WHERE id=e.id AND state_version=e.state_version;END IF;
  res:=jsonb_build_object('kind','utilita','mental_release',jsonb_build_object('contract','paralisi-release/1','effect_id',e.id,'mode',CASE WHEN p.source#>>'{meta,release_mode}'='kai' THEN 'kai' ELSE 'mental_contest' END,'attempted',true,'released',ok,'still_blocked',NOT ok,'reason',CASE WHEN ok THEN 'released' WHEN calc->>'reason'='contact_lost' THEN 'contact_lost' WHEN p.source#>>'{meta,release_mode}'='kai' THEN 'kai_below_power' ELSE 'contest_failed' END,'main_consumed',true,'chakra_cost',0,'damage_applied',0),'rng_audit',rng);
  PERFORM combat_v2_genjutsu_internal.record_event('release:'||d.id::text,e.id,res);
 END IF;
 UPDATE combat_v2_genjutsu_internal.release_plans SET result=res,result_sha256=public.combat_v2_sha256(res) WHERE actor_id=p.actor_id AND round_id=p.round_id;RETURN res;
END $function$;
CREATE OR REPLACE FUNCTION combat_v2_genjutsu_internal.scope(p_actor uuid)
 RETURNS boolean
 LANGUAGE sql
 STABLE SECURITY DEFINER
 SET search_path TO ''
AS $function$
 SELECT (EXISTS(SELECT 1 FROM public.combat_v2_actors a
 JOIN public.combat_v2_sessions s ON s.id=a.session_id
 JOIN public.locations l ON l.id=s.location_id
 JOIN combat_v2_genjutsu_internal.gate g ON g.singleton
 LEFT JOIN combat_consumer_private.activities ca ON ca.session_id=s.id
 LEFT JOIN combat_panel_private.master_panel_sessions mp ON mp.master_session_id=s.master_session_id
 LEFT JOIN public.master_v2_sessions m ON m.id=s.master_session_id
 WHERE a.id=p_actor AND a.actor_kind='pg' AND a.companion_id IS NULL AND a.state='attivo'
 AND a.character_id IN('2a877f02-4993-4e65-9172-7d29f08c5b86'::uuid,'6bceee99-974f-426b-8d92-38b43b4a4267'::uuid)
 AND a.controller_user IS NOT NULL
 AND s.state='in_corso' AND s.closed_at IS NULL AND s.user_test_context_id IS NULL
 AND l.id='0b85f354-9cdb-47e1-baf9-3d266bb7e06b'::uuid AND l.is_test AND l.is_active
 AND public.combat_v2_values_written(s.id) IS FALSE AND combat_panel_private.uses_simulated_pools(s.id)
 AND combat_effects_private.staff_session_allowed(s.id)
 AND g.enabled AND g.staff_enabled
 AND (SELECT count(*) FROM public.combat_v2_actors x WHERE x.session_id=s.id)=2
 AND (SELECT count(DISTINCT x.character_id) FROM public.combat_v2_actors x WHERE x.session_id=s.id)=2
 AND NOT EXISTS(SELECT 1 FROM public.combat_v2_actors x WHERE x.session_id=s.id AND
  (x.actor_kind<>'pg' OR x.companion_id IS NOT NULL OR x.character_id NOT IN
   ('2a877f02-4993-4e65-9172-7d29f08c5b86'::uuid,'6bceee99-974f-426b-8d92-38b43b4a4267'::uuid)))
 AND NOT EXISTS(SELECT 1 FROM public.mission_run_state ms WHERE ms.master_session_id=s.master_session_id)
 AND NOT EXISTS(SELECT 1 FROM combat_consumer_private.narrative_authorities na WHERE na.master_session_id=s.master_session_id)
 AND NOT EXISTS(SELECT 1 FROM exam_human_private.native_bindings b WHERE b.master_session_id=s.master_session_id)
 AND NOT EXISTS(SELECT 1 FROM exam_regia_private.bindings b WHERE b.combat_session_id=s.id)
 AND NOT EXISTS(SELECT 1 FROM mission_factory_owner.quest_run_sources q WHERE q.session_id=s.master_session_id)
 AND ((s.source_kind='ordinary' AND s.master_session_id IS NULL AND ca.user_test_context_id IS NULL
  AND ca.phase NOT IN('setup','closed','suspended') AND ca.policy_id='staff_test_no_persistent_resources_v1'
  AND EXISTS(SELECT 1 FROM combat_consumer_private.members cm WHERE cm.session_id=s.id AND cm.actor_id=a.id AND cm.character_id=a.character_id))
 OR(s.source_kind='master' AND m.owner_kind='human' AND m.tipo='duello' AND m.mission_id IS NULL AND m.quest_kind IS NULL
  AND m.stato='in_corso' AND m.closed_at IS NULL AND m.suspended_at IS NULL AND mp.policy_id='staff_test_no_persistent_resources_v1')))) OR (EXISTS(SELECT 1 FROM combat_v2_genjutsu_internal.gate WHERE singleton AND enabled AND staff_enabled) AND combat_v2_staff_nb_internal.pg_scope(p_actor))
$function$;
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
   fb_defense_snapshot:=combat_facing_private.defense_snapshot(p_attack,t.id,defender.id,clan_akimichi_private.cellular_snapshot_v1(def.id,case when tar.companion_id is not null then clan_marionettisti_private.defense_snapshot(defender.id,tar.id,reaction) else defender.mechanics_snapshot end),reaction);
   IF nara_launch IS NOT NULL AND (
     hyuga_juken IS NOT NULL OR hyuga_profile IS NOT NULL OR fireball_profile IS NOT NULL
     OR kind<>'ninjutsu' OR base<>0
   ) THEN RAISE EXCEPTION 'nara_native_profile_conflict' USING ERRCODE='55000'; END IF;
   calc:=clan_inuzuka_private.attack_calculate(p_attack,hyuga_juken->'profile',kind,
    CASE WHEN nara_launch IS NULL THEN att.mechanics_snapshot ELSE
      att.mechanics_snapshot||jsonb_build_object('mente',nara_launch->'kg','ninjutsu',nara_launch->'ninjutsu') END,
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
CREATE OR REPLACE FUNCTION mission_factory_owner.quest_combat_offer_source_guard_v1()
 RETURNS trigger
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO ''
AS $function$
declare q mission_factory_owner.quest_run_sources%rowtype;
  m public.master_v2_sessions%rowtype;
  r public.mission_run_state%rowtype;
  c mission_ai_service_owner.capabilities%rowtype;
  d mission_generic_owner.definitions%rowtype;
  nb_origin combat_v2_staff_nb_internal.roster_sources%rowtype;
  nb_admission combat_v2_staff_nb_internal.admissions%rowtype;
  nb_context combat_panel_private.contexts%rowtype;nb_tuple jsonb;
begin
  if tg_op='UPDATE' then
    if (old.source_kind,old.master_session_id,old.mission_id,
        old.quest_episode_id,old.quest_source_sha256,
        old.narrative_template_id,old.narrative_version_id,
        old.mechanical_template_id,old.mechanical_version_id)
       is distinct from
       (new.source_kind,new.master_session_id,new.mission_id,
        new.quest_episode_id,new.quest_source_sha256,
        new.narrative_template_id,new.narrative_version_id,
        new.mechanical_template_id,new.mechanical_version_id)
    then raise exception 'MF_QUEST_OFFER_IDENTITY_IMMUTABLE' using errcode='42501'; end if;
  end if;
  -- Exact additional origin: no Quest OR bypass and no source-kind-only return.
  if new.source_kind='staff_combat' then
    if auth.uid() is null or not public.is_staff() or tg_op not in('INSERT','UPDATE')
       or new.staff_combat_source_id is null or new.mission_id is not null
       or new.quest_episode_id is not null or new.quest_source_sha256 is not null
       or new.recipient_kind is distinct from 'human' or new.recipient_user is distinct from auth.uid()
       or new.created_by is distinct from auth.uid() or new.recipient_service_capability is not null
       or new.created_by_service_capability is not null
    then raise exception 'STAFF_NB_OFFER_AUTHORITY_REQUIRED' using errcode='42501';end if;
    if tg_op='UPDATE' and old.staff_combat_source_id is distinct from new.staff_combat_source_id
    then raise exception 'STAFF_NB_OFFER_ORIGIN_IMMUTABLE' using errcode='42501';end if;
    select * into strict nb_origin from combat_v2_staff_nb_internal.roster_sources
      where id=new.staff_combat_source_id and master_session_id=new.master_session_id for share;
    select * into strict nb_admission from combat_v2_staff_nb_internal.admissions
      where source_id=nb_origin.id and master_session_id=nb_origin.master_session_id and offer_ref=new.offer_ref for share;
    select * into strict m from public.master_v2_sessions where id=new.master_session_id for share;
    select * into strict nb_context from combat_panel_private.contexts where id=nb_origin.context_id for share;
    nb_tuple:=nb_origin.source->'tuple';
    if nb_origin.state is distinct from 'offered' or nb_origin.principal_user is distinct from auth.uid()
       or nb_origin.master_control_version is distinct from m.control_version
       or nb_origin.source_sha256 is distinct from public.combat_v2_sha256(nb_origin.source)
       or nb_origin.source->>'contract' is distinct from 'staff-nb-roster/1'
       or nb_origin.source->>'master_session_id' is distinct from m.id::text
       or nb_origin.source->>'master_control_version' is distinct from m.control_version::text
       or nb_origin.source->>'principal_user' is distinct from auth.uid()::text
       or nb_origin.source->>'context_id' is distinct from nb_context.id::text
       or nb_origin.source->>'context_version' is distinct from nb_context.context_version::text
       or nb_origin.source->>'scene_version' is distinct from nb_context.scene_version::text
       or nb_origin.source->>'source_fingerprint' is distinct from nb_context.source_fingerprint
       or nb_context.principal_user is distinct from auth.uid() or nb_context.activity_kind is distinct from 'master_v2'
       or nb_context.round_id is not null or nb_context.location_id is distinct from m.location_id
       or nb_admission.transaction_id is distinct from txid_current() or nb_admission.backend_pid is distinct from pg_backend_pid()
       or nb_admission.principal_user is distinct from auth.uid() or nb_admission.encounter_id is not null
       or nb_admission.receipt is not null or nb_admission.receipt_sha256 is not null
       or not exists(select 1 from public.combat_v2_events e where e.id=nb_admission.event_id
          and e.scope_id=m.id and e.request_key=nb_admission.request_id)
       or m.master_user is distinct from auth.uid() or m.owner_kind is distinct from 'human'
       or m.tipo is distinct from 'duello' or m.stato is distinct from 'preparazione'
       or m.mission_id is not null or m.quest_kind is not null or m.closed_at is not null or m.suspended_at is not null
       or not exists(select 1 from public.locations l where l.id=m.location_id
          and l.id='0b85f354-9cdb-47e1-baf9-3d266bb7e06b'::uuid and l.is_test and l.is_active)
       or not exists(select 1 from combat_panel_private.master_panel_sessions p
          where p.master_session_id=m.id and p.location_id=m.location_id and p.policy_id='staff_test_no_persistent_resources_v1')
       or not exists(select 1 from combat_v2_staff_nb_internal.gate g where g.singleton and g.staff_enabled and not g.public_enabled)
       or exists(select 1 from mission_factory_owner.quest_run_sources x where x.session_id=m.id)
       or exists(select 1 from public.mission_run_state x where x.master_session_id=m.id)
       or exists(select 1 from combat_consumer_private.narrative_authorities x where x.master_session_id=m.id)
       or exists(select 1 from exam_human_private.native_bindings x where x.master_session_id=m.id)
       or nb_tuple is null or nb_tuple is distinct from combat_v2_staff_nb_internal.choice(nb_origin.mechanical_version_id)
    then raise exception 'STAFF_NB_OFFER_ORIGIN_SCOPE_INVALID' using errcode='42501';end if;
    if (new.narrative_template_id,new.narrative_version_id,new.mechanical_template_id,new.mechanical_version_id,
        new.expected_master_control_version,new.expected_narrative_template_control_version,new.expected_narrative_version_control_version,
        new.expected_binding_control_version,new.expected_mechanical_template_control_version,new.expected_mechanical_version_control_version,
        new.expected_narrative_sha256,new.expected_mechanical_sha256)
       is distinct from
       ((nb_tuple->>'narrative_template_id')::uuid,(nb_tuple->>'narrative_version_id')::uuid,
        (nb_tuple->>'mechanical_template_id')::uuid,(nb_tuple->>'mechanical_version_id')::uuid,m.control_version,
        (nb_tuple->>'narrative_template_control_version')::bigint,(nb_tuple->>'narrative_version_control_version')::bigint,
        (nb_tuple->>'binding_control_version')::bigint,(nb_tuple->>'mechanical_template_control_version')::bigint,
        (nb_tuple->>'mechanical_version_control_version')::bigint,nb_tuple->>'narrative_sha256',nb_tuple->>'mechanical_sha256')
       or new.expires_at<=clock_timestamp()
    then raise exception 'STAFF_NB_OFFER_TUPLE_INVALID' using errcode='40001';end if;
    if tg_op='INSERT' then
      if new.lifecycle_state is distinct from 'offerta' or new.consumed_event_id is not null or new.consumed_at is not null
      then raise exception 'STAFF_NB_OFFER_INITIAL_STATE_INVALID' using errcode='42501';end if;
    elsif old.lifecycle_state is distinct from 'offerta' or new.lifecycle_state is distinct from 'consumata'
       or new.consumed_event_id is distinct from nb_admission.event_id or new.consumed_at is null
       or new.control_version is distinct from old.control_version+1
    then raise exception 'STAFF_NB_OFFER_CONSUMPTION_INVALID' using errcode='42501';end if;
    return new;
  end if;
  if new.source_kind='mission' then return new; end if;
  perform mission_factory_owner.quest_run_source_assert_v1(new.master_session_id);
  select * into strict q from mission_factory_owner.quest_run_sources
    where session_id=new.master_session_id for share;
  select * into strict m from public.master_v2_sessions
    where id=new.master_session_id for share;
  select * into strict r from public.mission_run_state
    where master_session_id=new.master_session_id for share;
  select * into strict d from mission_generic_owner.definitions
    where id=q.definition_id for share;
  IF mission_factory_owner.c395_human_mode_v1(new.master_session_id) THEN
    PERFORM mission_factory_owner.c407_active_v1(new.master_session_id,'admission');
    IF auth.uid() IS NULL OR auth.role() IS DISTINCT FROM 'authenticated'
       OR m.master_user IS DISTINCT FROM auth.uid() OR m.owner_kind IS DISTINCT FROM 'human'
       OR q.state IS DISTINCT FROM 'started' OR m.stato IS DISTINCT FROM 'in_corso'
       OR m.closed_at IS NOT NULL OR m.suspended_at IS NOT NULL
       OR new.source_kind IS DISTINCT FROM 'quest' OR new.mission_id IS NOT NULL
       OR new.recipient_kind IS DISTINCT FROM 'human' OR new.recipient_user IS DISTINCT FROM m.master_user
       OR new.recipient_service_capability IS NOT NULL OR new.created_by_service_capability IS NOT NULL
       OR new.created_by IS DISTINCT FROM auth.uid()
       OR new.quest_episode_id IS DISTINCT FROM q.episode_id OR new.quest_source_sha256 IS DISTINCT FROM q.source_sha256
       OR m.tipo IS DISTINCT FROM 'quest' OR m.mission_id IS NOT NULL
       OR r.source_kind IS DISTINCT FROM 'quest' OR r.quest_episode_id IS DISTINCT FROM q.episode_id
       OR r.plan_version_id IS DISTINCT FROM q.plan_version_id OR r.current_step_key IS NULL
       OR r.run_phase IS DISTINCT FROM 'in_corso' OR (tg_op='INSERT' AND new.expected_master_control_version IS DISTINCT FROM m.control_version)
       OR NOT EXISTS(SELECT 1 FROM jsonb_array_elements(d.definition->'scenes') sc,
          LATERAL jsonb_array_elements(sc.value->'encounters') en,
          LATERAL jsonb_array_elements(en.value->'actors') actor
          JOIN public.nb_mechanical_bindings binding ON binding.id=(actor.value->>'mechanical_binding_id')::uuid
          WHERE sc.value->>'step_key'=r.current_step_key AND actor.value->>'combat'='true'
          AND (actor.value->>'narrative_template_id')::uuid=new.narrative_template_id
          AND (actor.value->>'narrative_version_id')::uuid=new.narrative_version_id
          AND binding.narrative_template_id=new.narrative_template_id
          AND binding.narrative_version_id=new.narrative_version_id
          AND binding.mechanical_template_id=new.mechanical_template_id
          AND binding.mechanical_version_id=new.mechanical_version_id
          AND binding.active AND binding.lifecycle_state='approved'
          AND mission_generic_owner.binding_is_pinned(new.master_session_id,binding.id))
    THEN RAISE EXCEPTION 'MF_QUEST_HUMAN_OFFER_SOURCE_INVALID' USING ERRCODE='42501';END IF;
    RETURN new;
  END IF;
  select * into strict c from mission_ai_service_owner.capabilities
    where id=mission_factory_owner.quest_capability_assert_v1(new.master_session_id)
      and id=new.recipient_service_capability for share;
  if q.state<>'started' or new.recipient_kind<>'ai_service'
     or new.recipient_user is not null or new.created_by is not null
     or new.created_by_service_capability is distinct from c.id
     or new.quest_episode_id is distinct from q.episode_id
     or new.quest_source_sha256 is distinct from q.source_sha256
     or m.tipo<>'quest' or m.mission_id is not null
     or m.owner_kind<>'ai_service' or m.stato<>'in_corso'
     or r.source_kind<>'quest' or r.quest_episode_id is distinct from q.episode_id
     or r.plan_version_id is distinct from q.plan_version_id
     or r.current_step_key is null or r.run_phase<>'in_corso'
     or c.master_session_id is distinct from q.session_id or c.state<>'active'
     or not exists(select 1 from jsonb_array_elements(d.definition->'scenes') sc,
          lateral jsonb_array_elements(sc.value->'encounters') en,
          lateral jsonb_array_elements(en.value->'actors') actor
       where sc.value->>'step_key'=r.current_step_key
         and actor.value->>'combat'='true'
         and (actor.value->>'narrative_template_id')::uuid=new.narrative_template_id
         and (actor.value->>'narrative_version_id')::uuid=new.narrative_version_id
         and (actor.value->>'mechanical_binding_id')::uuid in
           (select b.id from public.nb_mechanical_bindings b
             where b.narrative_template_id=new.narrative_template_id
               and b.narrative_version_id=new.narrative_version_id
               and b.mechanical_template_id=new.mechanical_template_id
               and b.mechanical_version_id=new.mechanical_version_id
               and b.active and b.lifecycle_state='approved'))
  then raise exception 'MF_QUEST_OFFER_SOURCE_INVALID' using errcode='42501'; end if;
  return new;
end; $function$;
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
    'edge_revision',case when payload->>'genere'='rinuncia' then 'ordinary-rinuncia/1' when payload->>'genere'='azione_risolta' then 'ordinary-facts/1' else 'ordinary-adapter/1' end,'validator_revision',case when payload->>'genere'='rinuncia' then 'combat-rinuncia/1' when payload->>'genere'='azione_risolta' then CASE WHEN payload->'fatti' ? 'nara_strangle_server' THEN combat_panel_private.nara_strangle_facts_revision_v1(payload->'fatti') WHEN payload->'fatti' ? 'aburame_verme_server' THEN 'combat-facts/3' WHEN payload->'fatti' ?| ARRAY['genjutsu_server','genjutsu_events'] OR payload#>'{fatti,result}' ?| ARRAY['healing','mental_release'] THEN 'combat-facts/2' ELSE 'combat-facts/1' END else 'combat-narratore-v18-existing/1' end,
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
    case when claim.context_payload->>'genere'='rinuncia' then 'combat-rinuncia/1' when claim.context_payload->>'genere'='azione_risolta' then CASE WHEN claim.context_payload->'fatti' ? 'nara_strangle_server' THEN combat_panel_private.nara_strangle_facts_revision_v1(claim.context_payload->'fatti') WHEN claim.context_payload->'fatti' ? 'aburame_verme_server' THEN 'combat-facts/3' WHEN claim.context_payload->'fatti' ?| ARRAY['genjutsu_server','genjutsu_events'] OR claim.context_payload#>'{fatti,result}' ?| ARRAY['healing','mental_release'] THEN 'combat-facts/2' ELSE 'combat-facts/1' END else 'combat-narratore-v18-existing/1' end) then
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
CREATE OR REPLACE FUNCTION public.combat_v2_actor_ability(p_actor uuid, p_source text, p_ability uuid, p_defense boolean DEFAULT false)
 RETURNS jsonb
 LANGUAGE sql
 STABLE SECURITY DEFINER
 SET search_path TO ''
AS $function$
 SELECT CASE WHEN p_source='clan'AND p_ability='0a15282f-d6b5-4ee3-ad52-7fac2525444d'::uuid THEN NULL::jsonb WHEN p_source='clan' AND p_ability='f5f26cb5-9b6f-44b3-94bc-c329a0a88b93'::uuid THEN NULL::jsonb
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
CREATE OR REPLACE FUNCTION public.combat_v2_defense_declare(p_round uuid, p_attack_declaration uuid, p_actor uuid, p_intent jsonb, p_text text, p_request_key uuid)
 RETURNS jsonb
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO ''
AS $function$
declare v_uid uuid:=exam_regia_private.current_principal(); v_service boolean:=false; v_service_actor uuid; v_r public.combat_v2_rounds%rowtype; v_a public.combat_v2_actors%rowtype; v_atk public.combat_v2_declarations%rowtype;
  v_i jsonb; v_reaction text; v_source text; v_ability uuid; v_meta jsonb; v_cost int:=0; v_event jsonb; v_event_id uuid; v_id uuid; v_result jsonb; v_existing public.combat_v2_events%rowtype; v_payload jsonb; v_fp text;
begin
  if v_uid is null then delete from mission_exchange_combat_owner.service_defense_permits p where p.request_key=p_request_key and p.round_id=p_round and p.attack_id=p_attack_declaration and p.actor_id=p_actor and p.intent_sha256=encode(extensions.digest(convert_to(p_intent::text,'UTF8'),'sha256'),'hex') returning true,p.capability_id into v_service,v_service_actor;if not coalesce(v_service,false)then perform public.combat_v2_fail('autenticazione_richiesta','Autenticazione richiesta.',401,p_request_key,'{}');end if;end if;
  perform public.combat_v2_lock_round(p_round);
  perform exam_regia_private.assert_actor_dispatch(p_round,p_actor,p_request_key);
  select * into v_r from public.combat_v2_rounds where id=p_round for update;
  select * into v_a from public.combat_v2_actors where id=p_actor for update;
  if v_a.companion_id is not null then perform public.combat_v2_fail('compagno_senza_turno','Il compagno non dichiara azioni autonome.',409,p_request_key,'{}'); end if;
  select * into v_atk from public.combat_v2_declarations where id=p_attack_declaration for update;
  perform combat_consumer_private.assert_dispatch(p_round,p_request_key,'defend');
  perform public.combat_v2_assert_operational(p_round,p_request_key,false);
  if v_r.id is null or v_a.id is null or v_atk.id is null or v_atk.round_id<>p_round then
    perform public.combat_v2_fail('bersaglio_non_valido','Difesa non collegata a questo attore.',422,p_request_key,'{}'); end if;
  if v_r.phase<>'raccolta_difese' then perform public.combat_v2_fail('fase_non_valida','Il round non raccoglie difese.',409,p_request_key,'{}'); end if;
  IF v_a.actor_kind='png' AND EXISTS(SELECT 1 FROM user_testroom_common_private.contexts WHERE id=v_a.session_id) THEN
    PERFORM user_testroom_common_private.assert_png_defense(p_round,p_attack_declaration,p_actor,p_intent,p_request_key);
  ELSE if not v_service and exam_regia_private.actor_principal(v_a.id,v_a.controller_user)<>v_uid then perform public.combat_v2_fail('attore_non_controllato','Non controlli questo attore.',403,p_request_key,'{}'); end if; END IF;
    v_i := public.combat_v2_sanitize_intent(p_intent,true); v_i:=clan_inuzuka_private.defense_guard(p_actor,v_i);
  IF NOT combat_v2_genjutsu_internal.defense_intent_allowed(p_attack_declaration,v_i) THEN RAISE EXCEPTION 'paralisi_defense_not_offered';END IF;
  perform clan_marionettisti_private.assert_jutsu_source(p_actor,v_i->>'ability_source',(v_i->>'ability_id')::uuid);
  v_payload:=jsonb_build_object('attack',p_attack_declaration,'actor',p_actor,'intent',v_i,'text',coalesce(p_text,''));
  v_fp:=public.combat_v2_sha256(jsonb_build_object('operation','combat_v2_defense_declare','payload',v_payload,'caller',exam_regia_private.current_principal(),'scope',p_round));
  select * into v_existing from public.combat_v2_events where scope_id=p_round and request_key=p_request_key for update;
  if v_existing.id is not null then
    if v_existing.operation_kind is distinct from 'combat_v2_defense_declare'
       or v_existing.request_fingerprint is distinct from v_fp then
      perform public.combat_v2_fail('request_key_conflict','La chiave richiesta e gia associata a una difesa diversa.',409,p_request_key,'{}');
    end if;
    if v_existing.status='completata' then return v_existing.result; end if;
    perform public.combat_v2_fail('operazione_in_corso','Operazione gia in corso.',409,p_request_key,'{}');
  end if;
  if exists(select 1 from public.combat_v2_declarations d join public.combat_v2_declarations x on x.id=d.parent_attack_id where d.round_id=p_round and d.kind='difesa' and d.actor_id=p_actor) then
    perform public.combat_v2_fail('azione_non_disponibile','La reazione del round è già stata usata.',409,p_request_key,'{}'); end if;
  IF EXISTS(SELECT 1 FROM public.combat_v2_attack_targets mt
   WHERE mt.attack_declaration_id=p_attack_declaration
     AND combat_panel_private.multiplication_no_defense(mt.id))
   AND NOT EXISTS(SELECT 1 FROM public.combat_v2_attack_targets mt
    WHERE mt.attack_declaration_id=p_attack_declaration
      AND NOT combat_panel_private.multiplication_no_defense(mt.id)) THEN
    perform public.combat_v2_fail('difesa_non_richiesta','Il colpo non richiede una difesa.',409,p_request_key,'{}');
  END IF;
  v_reaction:=v_i->>'reaction';
  IF combat_panel_private.nara_controlled_v1(p_actor) AND v_reaction IS DISTINCT FROM 'nessuna' THEN
    PERFORM public.combat_v2_fail('azione_non_disponibile','Il corpo è sotto controllo.',409,p_request_key,'{}');
  END IF;
  -- [MISSION-GUARD-003] I resolver V2 dedicati non sono ancora collegati.
  if v_reaction in ('sostituzione','copie') then
    perform public.combat_v2_fail('profilo_runtime_non_disponibile','Questa difesa richiede il proprio resolver.',422,p_request_key,'{}');
  end if;
  if v_reaction='tecnica' then
    v_source:=v_i->>'ability_source'; v_ability:=(v_i->>'ability_id')::uuid;
    if v_ability='31b15861-fb78-4f8a-ac1c-ebf2d957c32e'::uuid then
      perform public.combat_v2_fail('profilo_runtime_non_disponibile','Sostituzione richiede un’offerta spaziale valida.',422,p_request_key,'{}');
    end if;
    PERFORM combat_v2_elemental_internal.scudo_prepare_native(p_round,p_attack_declaration,p_actor,p_request_key,v_i);
    v_meta:=combat_v2_elemental_internal.scudo_declaration_meta(p_round,p_attack_declaration,p_actor,p_request_key,v_i);
    IF v_meta IS NULL THEN
      v_meta:=combat_v2_multitarget_internal.enrich_ability_v1(public.combat_v2_actor_ability(p_actor,v_source,v_ability,true));
    END IF;
    if v_meta is null then perform public.combat_v2_fail('opzione_non_offerta','Tecnica difensiva non offerta.',422,p_request_key,'{}'); end if;
    if v_ability='9f12fc98-bc97-4b95-9bcc-7ce359ebbe4f'::uuid
       and lower(coalesce(v_atk.sanitized_intent#>>'{server_ability,kind}','')) not like '%genjutsu%' then
      perform public.combat_v2_fail('opzione_non_offerta','Dispersione è disponibile soltanto contro Genjutsu.',422,p_request_key,'{}');
    end if;
    v_cost:=coalesce((v_meta->>'chakra_cost')::int,0);
  elsif v_reaction='sostituzione' then v_cost:=5;
  end if;
  v_event:=public.combat_v2_event_begin(p_round,p_request_key,'combat_v2_defense_declare',v_payload,null);
  if (v_event->>'replay')::boolean then return v_event->'result'; end if; v_event_id:=(v_event->>'event_id')::uuid;
  insert into public.combat_v2_declarations(round_id,actor_id,kind,parent_attack_id,target_actor_id,sanitized_intent,declaration_text,controller_user_snapshot,controller_version_snapshot,request_key,cost_snapshot)
  values(p_round,p_actor,'difesa',p_attack_declaration,case when clan_marionettisti_private.defends_body(p_actor,v_atk.target_actor_id,v_reaction) then v_atk.target_actor_id else p_actor end,v_i||case when v_meta is null then '{}'::jsonb else jsonb_build_object('server_ability',v_meta) end,
    coalesce(p_text,''),coalesce(v_uid,v_service_actor),v_a.controller_version,p_request_key,clan_hyuga_private.sedici_cost_snapshot(p_actor,jsonb_build_object('chakra',v_cost))) returning id into v_id;
  PERFORM combat_v2_elemental_internal.scudo_bind_source(v_id);
  PERFORM clan_hyuga_private.rotation_freeze(v_id);
  PERFORM clan_akimichi_private.cellular_bind_v1(v_id);
  insert into public.combat_v2_declarations(round_id,actor_id,kind,parent_attack_id,target_actor_id,sanitized_intent,declaration_text,controller_user_snapshot,controller_version_snapshot,request_key,cost_snapshot)
  select p_round,p_actor,'nessuna',x.id,p_actor,jsonb_build_object('reaction','nessuna'),'',coalesce(v_uid,v_service_actor),v_a.controller_version,gen_random_uuid(),'{}'::jsonb
    from public.combat_v2_declarations x
   where x.round_id=p_round and x.kind='attacco' and exists(select 1 from public.combat_v2_attack_targets mt
     where mt.attack_declaration_id=x.id and mt.round_id=p_round
       and mt.target_actor_id=p_actor and mt.state='attesa_difesa'
       and not combat_panel_private.multiplication_no_defense(mt.id)
       and not exists(select 1 from public.combat_v2_defense_coverages c where c.attack_target_id=mt.id)) and x.id<>p_attack_declaration
     and not exists(select 1 from public.combat_v2_declarations d where d.parent_attack_id=x.id and d.actor_id=p_actor);
  -- The owner's round reaction also covers the decision on its mission puppet.
  -- Record native no-defense declarations for the other attacks on that puppet.
  IF v_a.actor_kind='png' AND auth.uid() IS NULL
     AND v_uid=mission_generic_owner.actor_principal(p_actor) THEN
    INSERT INTO public.combat_v2_declarations(round_id,actor_id,kind,parent_attack_id,target_actor_id,
      sanitized_intent,declaration_text,controller_user_snapshot,controller_version_snapshot,request_key,cost_snapshot)
    SELECT DISTINCT ON (target.attack_declaration_id)
      p_round,p_actor,'nessuna',target.attack_declaration_id,target.target_actor_id,
      jsonb_build_object('reaction','nessuna'),'',v_uid,v_a.controller_version,gen_random_uuid(),'{}'::jsonb
    FROM public.combat_v2_attack_targets target
    JOIN public.combat_v2_declarations attack
      ON attack.id=target.attack_declaration_id AND attack.round_id=target.round_id AND attack.kind='attacco'
    WHERE target.round_id=p_round AND target.state='attesa_difesa'
      AND target.attack_declaration_id<>p_attack_declaration
      AND NOT combat_panel_private.multiplication_no_defense(target.id)
      AND mission_generic_owner.mission_companion_defense_owner_v1(v_a.session_id,target.target_actor_id)=p_actor
      AND NOT EXISTS (SELECT 1 FROM public.combat_v2_defense_coverages coverage
        WHERE coverage.attack_target_id=target.id)
      AND NOT EXISTS (SELECT 1 FROM public.combat_v2_declarations response
        WHERE response.parent_attack_id=target.attack_declaration_id AND response.actor_id=p_actor
          AND response.kind IN ('difesa','nessuna'))
    ORDER BY target.attack_declaration_id,target.ordinal;
  END IF;
  v_result:=public.combat_v2_envelope(p_request_key,jsonb_build_object('defense_id',v_id));
  return public.combat_v2_event_complete(v_event_id,v_result);
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
        fb_defense_snapshot:=combat_facing_private.defense_snapshot(v_d.id,multiplication_target,v_def.actor_id,clan_akimichi_private.cellular_snapshot_v1(v_def.id,clan_aburame_private.clone_defense_snapshot(v_def.id,clan_hyuga_private.rotation_defense_snapshot(v_def.id,clan_marionettisti_private.defense_snapshot(v_def.actor_id,v_tar.id,v_reaction)))),v_reaction);
        IF nara_launch IS NOT NULL AND (
          hyuga_juken IS NOT NULL OR hyuga_profile IS NOT NULL OR fireball_profile IS NOT NULL
          OR v_kind<>'ninjutsu' OR v_base<>0
        ) THEN RAISE EXCEPTION 'nara_native_profile_conflict' USING ERRCODE='55000'; END IF;
        v_calc:=clan_inuzuka_private.attack_calculate(v_d.id,hyuga_juken->'profile',v_kind,
          CASE WHEN nara_launch IS NULL THEN v_att.mechanics_snapshot ELSE
            v_att.mechanics_snapshot||jsonb_build_object('mente',nara_launch->'kg','ninjutsu',nara_launch->'ninjutsu') END,
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
CREATE OR REPLACE FUNCTION public.master_v2_encounter_open_ninja_book_v1_human_ai_core(p_master_session uuid, p_pg_ids uuid[], p_actor_offers jsonb, p_team_map jsonb, p_request_key uuid)
 RETURNS jsonb
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO ''
AS $function$
declare
  v_uid uuid:=auth.uid(); v_m public.master_v2_sessions%rowtype; v_event jsonb; v_event_id uuid;
  v_enc uuid; v_round uuid; v_pg uuid; v_snap jsonb; v_team text; v_spec jsonb;
  v_offer public.master_v2_nb_actor_offers_v1%rowtype; v_nt public.nb_templates%rowtype;
  v_nv public.nb_template_versions%rowtype; v_b public.nb_mechanical_bindings%rowtype;
  v_mt public.nb_mechanical_templates%rowtype; v_mv public.nb_mechanical_versions%rowtype;
  v_instance uuid; v_mode text; v_result jsonb; v_count integer; v_client uuid; v_offer_ref uuid; v_quest_source mission_factory_owner.quest_run_sources; v_is_human_quest boolean; v_custom_bundle uuid;
begin
  perform mission_creation_owner.assert_human_open(p_master_session,p_request_key,p_pg_ids,p_actor_offers,p_team_map);
  if v_uid is null then perform public.master_v2_nb_fail_v1('autenticazione_richiesta','Autenticazione richiesta.',401,p_request_key); end if;
  select * into v_m from public.master_v2_sessions where id=p_master_session;
  if v_m.id is null then perform public.master_v2_nb_fail_v1('sessione_inesistente','Sessione Master inesistente.',404,p_request_key); end if;
  if v_m.master_user<>v_uid and NOT mission_generic_owner.regia_entry_permit_valid_v1(p_master_session,p_request_key) then perform public.master_v2_nb_fail_v1('master_non_proprietario','Solo il Master corrente può aprire lo scontro.',403,p_request_key); end if;
  v_is_human_quest:=mission_factory_owner.c395_human_mode_v1(p_master_session);
  IF v_is_human_quest THEN SELECT * INTO STRICT v_quest_source FROM mission_factory_owner.quest_run_sources WHERE session_id=p_master_session FOR SHARE;PERFORM mission_factory_owner.c407_active_v1(p_master_session,'admission');END IF;
  if v_m.tipo<>'quest' or (NOT v_is_human_quest AND v_m.mission_id is null) OR (v_is_human_quest AND (v_m.mission_id IS NOT NULL OR v_quest_source.state IS DISTINCT FROM 'started')) or v_m.stato not in ('preparazione','in_corso') then
    perform public.master_v2_nb_fail_v1('sessione_non_operativa','Sessione missione non operativa.',409,p_request_key);
  end if;
  if p_pg_ids is null or cardinality(p_pg_ids)<1 or cardinality(p_pg_ids)>12
     or p_actor_offers is null or jsonb_typeof(p_actor_offers)<>'array'
     or jsonb_array_length(p_actor_offers)<1 or jsonb_array_length(p_actor_offers)>12
     or p_team_map is null or jsonb_typeof(p_team_map)<>'object' then
    perform public.master_v2_nb_fail_v1('intento_non_valido','Elenco attori non valido.',422,p_request_key);
  end if;
  select count(distinct x) into v_count from unnest(p_pg_ids) x;
  if v_count<>cardinality(p_pg_ids) then perform public.master_v2_nb_fail_v1('intento_non_valido','PG duplicato.',422,p_request_key); end if;
  if exists(select 1 from public.characters c where c.id=any(p_pg_ids) and c.user_id=v_uid) and not (public.is_staff() and exists(select 1 from public.locations l where l.id=v_m.location_id and l.is_test)) then
    perform public.master_v2_nb_fail_v1('attore_non_controllato','Il Master corrente non può essere un attore PG.',422,p_request_key);
  end if;
  if (select count(*) from public.characters c where c.id=any(p_pg_ids))<>cardinality(p_pg_ids) then
    perform public.master_v2_nb_fail_v1('intento_non_valido','Uno o più PG non esistono.',422,p_request_key);
  end if;
  if exists(select 1 from jsonb_array_elements(p_actor_offers) x
    where jsonb_typeof(x)<>'object' or public.combat_v2_has_forbidden_key(x)
       or exists(select 1 from jsonb_object_keys(x) k where k not in ('client_ref','provider','offer_ref'))
       or (select count(*) from jsonb_object_keys(x))<>3) then
    perform public.master_v2_nb_fail_v1('campo_meccanico_vietato','Payload provider non valido.',422,p_request_key);
  end if;
  if exists(select 1 from jsonb_array_elements(p_actor_offers) x where x->>'provider'<>'ninja_book') then
    perform public.master_v2_nb_fail_v1('riferimento_provider_non_valido','Provider non valido.',422,p_request_key);
  end if;
  begin
    if (select count(distinct (x->>'client_ref')::uuid) from jsonb_array_elements(p_actor_offers) x)<>jsonb_array_length(p_actor_offers)
       or (select count(distinct (x->>'offer_ref')::uuid) from jsonb_array_elements(p_actor_offers) x)<>jsonb_array_length(p_actor_offers) then
      perform public.master_v2_nb_fail_v1('intento_non_valido','Identità provider duplicata.',422,p_request_key);
    end if;
  exception when invalid_text_representation then
    perform public.master_v2_nb_fail_v1('intento_non_valido','Riferimento provider non valido.',422,p_request_key);
  end;
  if (select count(*) from jsonb_object_keys(p_team_map))<>
       cardinality(p_pg_ids)+jsonb_array_length(p_actor_offers)
     or exists(select 1 from jsonb_object_keys(p_team_map) k
       where not (k=any(array(select x::text from unnest(p_pg_ids) x))
                  or k=any(array(select x->>'client_ref' from jsonb_array_elements(p_actor_offers) x)))) then
    perform public.master_v2_nb_fail_v1('intento_non_valido','Mappa squadre non esatta.',422,p_request_key);
  end if;

  perform 1 from public.locations l where l.id=v_m.location_id order by l.id for update;
  perform combat_gate_private.master_claim_assert(p_master_session,v_m.location_id);
  perform 1 from public.characters c where c.id=any(p_pg_ids) order by c.id for key share;
  perform public.master_v2_lock_scope(p_master_session);
  select * into v_m from public.master_v2_sessions where id=p_master_session for update;
  if v_m.master_user<>v_uid and NOT mission_generic_owner.regia_entry_permit_valid_v1(p_master_session,p_request_key) then perform public.master_v2_nb_fail_v1('master_non_proprietario','Controllo Master cambiato durante l’apertura.',409,p_request_key); end if;
  if v_m.tipo<>'quest' or v_m.stato not in ('preparazione','in_corso') then
    perform public.master_v2_nb_fail_v1('sessione_non_operativa','Sessione non più operativa.',409,p_request_key);
  end if;
  v_event:=public.combat_v2_event_begin(p_master_session,p_request_key,
    'master_v2_encounter_open_ninja_book_v1',jsonb_build_object('pg',p_pg_ids,'actors',p_actor_offers,'teams',p_team_map),v_m.control_version);
  if (v_event->>'replay')::boolean then
    v_event_id:=(v_event->>'event_id')::uuid;
    insert into public.master_v2_nb_offer_audit_v1(offer_ref,event_id,action,actor_user)
    select (x->>'offer_ref')::uuid,v_event_id,'replay',v_uid from jsonb_array_elements(p_actor_offers) x
    on conflict do nothing;
    return v_event->'result';
  end if;
  v_event_id:=(v_event->>'event_id')::uuid;
  if exists(select 1 from public.combat_sessions where location_id=v_m.location_id and state='aperto')
     or exists(select 1 from public.combat_v2_sessions where location_id=v_m.location_id AND user_test_context_id IS NULL and state not in ('chiuso','annullato')) then
    perform public.master_v2_nb_fail_v1('scontro_gia_aperto_nel_luogo','Esiste già uno scontro nel luogo.',409,p_request_key);
  end if;

  -- Ordine lock: sessione Master -> offer UUID -> narrative/binding/mechanical UUID.
  perform 1 from public.master_v2_nb_actor_offers_v1 o
   where o.offer_ref in (select (x->>'offer_ref')::uuid from jsonb_array_elements(p_actor_offers) x)
   order by o.offer_ref for update;
  if (select count(*) from public.master_v2_nb_actor_offers_v1 o
      where o.offer_ref in (select (x->>'offer_ref')::uuid from jsonb_array_elements(p_actor_offers) x))<>jsonb_array_length(p_actor_offers) then
    perform public.master_v2_nb_fail_v1('opzione_non_offerta','Opzione non offerta.',422,p_request_key);
  end if;
  perform 1 from public.nb_template_versions v where v.id in(
    select o.narrative_version_id from public.master_v2_nb_actor_offers_v1 o
    where o.offer_ref in(select (x->>'offer_ref')::uuid from jsonb_array_elements(p_actor_offers)x)) order by v.id for update;
  perform 1 from public.nb_templates t where t.id in(
    select o.narrative_template_id from public.master_v2_nb_actor_offers_v1 o
    where o.offer_ref in(select (x->>'offer_ref')::uuid from jsonb_array_elements(p_actor_offers)x)) order by t.id for update;
  perform 1 from public.nb_mechanical_bindings b where b.narrative_version_id in(
    select o.narrative_version_id from public.master_v2_nb_actor_offers_v1 o
    where o.offer_ref in(select (x->>'offer_ref')::uuid from jsonb_array_elements(p_actor_offers)x)) order by b.id for update;
  perform 1 from public.nb_mechanical_versions v where v.id in(
    select o.mechanical_version_id from public.master_v2_nb_actor_offers_v1 o
    where o.offer_ref in(select (x->>'offer_ref')::uuid from jsonb_array_elements(p_actor_offers)x)) order by v.id for update;
  perform 1 from public.nb_mechanical_templates t where t.id in(
    select o.mechanical_template_id from public.master_v2_nb_actor_offers_v1 o
    where o.offer_ref in(select (x->>'offer_ref')::uuid from jsonb_array_elements(p_actor_offers)x)) order by t.id for update;

  -- Risolve e congela tutto prima del primo INSERT di sessione/istanza.
  for v_spec in select value from jsonb_array_elements(p_actor_offers) order by value->>'offer_ref' loop
    v_client:=(v_spec->>'client_ref')::uuid; v_offer_ref:=(v_spec->>'offer_ref')::uuid;
    select * into v_offer from public.master_v2_nb_actor_offers_v1 where offer_ref=v_offer_ref;
    if v_offer.master_session_id<>p_master_session OR (v_is_human_quest AND (v_offer.source_kind IS DISTINCT FROM 'quest' OR v_offer.mission_id IS NOT NULL OR v_offer.quest_episode_id IS DISTINCT FROM v_quest_source.episode_id OR v_offer.quest_source_sha256 IS DISTINCT FROM v_quest_source.source_sha256)) OR (NOT v_is_human_quest AND (v_offer.source_kind IS DISTINCT FROM 'mission' OR v_offer.mission_id IS DISTINCT FROM v_m.mission_id))
       or v_offer.recipient_user<>v_m.master_user or v_offer.lifecycle_state<>'offerta'
       or v_offer.expires_at<=clock_timestamp() then
      perform public.master_v2_nb_fail_v1('opzione_non_offerta','Opzione non offerta.',422,p_request_key);
    end if;
    select * into v_nv from public.nb_template_versions where id=v_offer.narrative_version_id and template_id=v_offer.narrative_template_id;
    select * into v_nt from public.nb_templates where id=v_offer.narrative_template_id;
    select * into v_b from public.nb_mechanical_bindings where narrative_version_id=v_offer.narrative_version_id;
    select * into v_mv from public.nb_mechanical_versions where id=v_offer.mechanical_version_id and template_id=v_offer.mechanical_template_id;
    select * into v_mt from public.nb_mechanical_templates where id=v_offer.mechanical_template_id;

    -- Canonical custom bundle must pass the Human Native Staff gate before any insert.
    IF v_mv.profile_kind='npc_custom' AND v_is_human_quest AND v_m.owner_kind='human'
      AND ((v_m.location_id='0b85f354-9cdb-47e1-baf9-3d266bb7e06b'::uuid AND v_quest_source.availability_scope='staff' AND v_quest_source.execution_context='staff_simulation') OR (v_quest_source.availability_scope='public' AND mission_factory_owner.human_ordinary_source_v1(p_master_session,true) IS NOT NULL)) THEN
      IF (SELECT count(*) FROM png_builder_internal.bundles custom_bundle JOIN png_builder_internal.npc_custom_combat_attests custom_attest ON custom_attest.bundle_id=custom_bundle.id
          WHERE custom_bundle.template_id=v_offer.narrative_template_id AND custom_bundle.narrative_version_id=v_offer.narrative_version_id
          AND custom_bundle.mechanical_version_id=v_offer.mechanical_version_id AND custom_bundle.mechanical_binding_id=v_b.id
          AND custom_bundle.status='certified' AND custom_bundle.ownership_mode='adopted' AND custom_bundle.disabled_at IS NULL)<>1
      THEN PERFORM public.master_v2_nb_fail_v1('opzione_non_offerta','Bundle PNG non disponibile.',422,p_request_key);END IF;
      SELECT custom_bundle.id INTO STRICT v_custom_bundle FROM png_builder_internal.bundles custom_bundle JOIN png_builder_internal.npc_custom_combat_attests custom_attest ON custom_attest.bundle_id=custom_bundle.id
       WHERE custom_bundle.template_id=v_offer.narrative_template_id AND custom_bundle.narrative_version_id=v_offer.narrative_version_id
       AND custom_bundle.mechanical_version_id=v_offer.mechanical_version_id AND custom_bundle.mechanical_binding_id=v_b.id
       AND custom_bundle.status='certified' AND custom_bundle.ownership_mode='adopted' AND custom_bundle.disabled_at IS NULL;
      PERFORM mission_factory_owner.npc_custom_combat_runtime_assert_v1(p_master_session,NULL,v_offer_ref,v_custom_bundle);
    END IF;
    if v_nt.id is null or v_nv.id is null or v_b.id is null or v_mt.id is null or v_mv.id is null
       or v_nt.lifecycle_state<>'approved' or v_nt.current_version_id<>v_nv.id or v_nv.review_state<>'approved'
       or v_b.lifecycle_state<>'approved' or not v_b.active
       or v_b.mechanical_template_id<>v_mt.id or v_b.mechanical_version_id<>v_mv.id
       or v_mt.lifecycle_state<>'approved' or not v_mt.active or v_mt.current_version_id<>v_mv.id
       or v_mv.review_state<>'approved' then
      perform public.master_v2_nb_fail_v1('opzione_non_offerta','Opzione non offerta.',422,p_request_key);
    end if;
    if v_offer.expected_master_control_version<>v_m.control_version
       or v_offer.expected_narrative_template_control_version<>v_nt.control_version
       or v_offer.expected_narrative_version_control_version<>v_nv.control_version
       or v_offer.expected_binding_control_version<>v_b.control_version
       or v_offer.expected_mechanical_template_control_version<>v_mt.control_version
       or v_offer.expected_mechanical_version_control_version<>v_mv.control_version
       or v_offer.expected_narrative_sha256<>v_nv.content_sha256
       or v_offer.expected_mechanical_sha256<>v_mv.content_sha256 then
      perform public.master_v2_nb_fail_v1('versione_provider_obsoleta','L’offerta provider è obsoleta.',409,p_request_key);
    end if;
    v_team:=nullif(btrim(p_team_map->>v_client::text),'');
    if v_team is null then perform public.master_v2_nb_fail_v1('intento_non_valido','Squadra provider mancante.',422,p_request_key); end if;
  end loop;

  RETURN combat_v2_staff_nb_internal.native_construct(p_master_session,p_pg_ids,p_actor_offers,p_team_map,p_request_key,v_event_id);
end
$function$;
CREATE OR REPLACE FUNCTION combat_panel_private.publish_master_declaration(p_declaration uuid, p_text text)
 RETURNS uuid
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO ''
AS $function$
DECLARE a public.combat_v2_actors%ROWTYPE; d public.combat_v2_declarations%ROWTYPE;
  location uuid; v_message_id uuid; guided_before text;
  human_window boolean:=false; human_stage boolean:=false; human_pg_resolved boolean:=false; native_private boolean:=false; native_pg_resolved boolean:=false; human_png_pass_resolved boolean:=false; human_genjutsu_resolved boolean:=false; staff_nb_kai_resolved boolean:=false;
BEGIN
 SELECT * INTO STRICT d FROM public.combat_v2_declarations WHERE id=p_declaration FOR UPDATE;
  SELECT a0.* INTO a FROM public.combat_v2_actors a0
    JOIN public.combat_v2_rounds r ON r.id=d.round_id AND r.session_id=a0.session_id
    JOIN public.combat_v2_sessions s ON s.id=r.session_id AND s.source_kind='master'
    WHERE a0.id=d.actor_id AND exam_regia_private.actor_principal(a0.id,a0.controller_user)=exam_regia_private.current_principal() AND a0.companion_id IS NULL;
  SELECT EXISTS(SELECT 1 FROM mission_generic_owner.regia_human_windows_v1 hw
    WHERE hw.next_round_id=d.round_id AND hw.state IN('private','published')) INTO human_window;
  IF a.actor_kind='png' AND human_window THEN
    SELECT EXISTS(SELECT 1
      FROM mission_generic_owner.regia_human_stage_permits_v1 hp
      JOIN mission_generic_owner.regia_human_windows_v1 hw
        ON hw.next_round_id=hp.round_id AND hw.master_session_id=hp.master_session_id
      JOIN mission_generic_owner.unified_round_windows uw
        ON uw.round_id=hp.round_id AND uw.batch_id=hw.batch_id
         AND uw.master_session_id=hw.master_session_id
      JOIN public.combat_v2_sessions cs ON cs.id=a.session_id
         AND cs.master_session_id=hw.master_session_id
      JOIN public.master_v2_sessions ms ON ms.id=hw.master_session_id
      WHERE hp.round_id=d.round_id AND hp.actor_id=d.actor_id
        AND hp.request_key=d.request_key AND hp.principal_id=auth.uid()
        AND hp.transaction_id=txid_current() AND hp.backend_pid=pg_backend_pid()
        AND hw.encounter_id=cs.id AND ms.owner_kind='human'
        AND ms.closed_at IS NULL AND ms.master_user=auth.uid()
        AND ms.location_id='0b85f354-9cdb-47e1-baf9-3d266bb7e06b'::uuid
        AND d.controller_user_snapshot=hp.principal_id
        AND d.controller_version_snapshot=a.controller_version
        AND ((hw.state='private' AND hw.side='png' AND uw.side='png'
              AND uw.publication_id IS NULL AND d.actor_id=ANY(uw.expected_actor_ids)
              AND d.kind IN('attacco','movimento','utilita','passa'))
          OR (hw.state='published' AND hw.side='pg' AND uw.side='pg'
              AND uw.publication_id IS NOT NULL AND d.kind IN('difesa','nessuna'))))
      INTO human_stage;
  END IF;
  -- PG Human needs no Master permit. A resolved non-offensive declaration is
  -- accepted only when the published PG window and completed native action
  -- receipt identify this same actor, request, text and controller version.
   IF a.actor_kind='pg' AND d.state='risolta'
     AND d.kind IN ('utilita','movimento','passa')
     AND nullif(btrim(d.declaration_text),'') IS NOT NULL THEN
     SELECT EXISTS(SELECT 1
       FROM mission_generic_owner.regia_human_windows_v1 hw
       JOIN mission_generic_owner.unified_round_windows uw
         ON uw.round_id=hw.next_round_id AND uw.batch_id=hw.batch_id
           AND uw.master_session_id=hw.master_session_id
       JOIN public.combat_v2_sessions cs ON cs.id=hw.encounter_id
         AND cs.master_session_id=hw.master_session_id
       JOIN public.master_v2_sessions ms ON ms.id=hw.master_session_id
       JOIN public.locations loc ON loc.id=ms.location_id
       JOIN public.combat_v2_events ev ON ev.scope_id=d.round_id
         AND ev.request_key=d.request_key AND ev.operation_kind='combat_v2_action_declare'
       WHERE hw.next_round_id=d.round_id AND hw.state='published' AND hw.side='pg'
         AND hw.encounter_id=a.session_id AND uw.side='pg'
         AND uw.publication_id IS NOT NULL AND d.actor_id=ANY(uw.expected_actor_ids)
         AND ms.owner_kind='human' AND ms.closed_at IS NULL AND ms.stato='in_corso'
         AND ms.location_id='0b85f354-9cdb-47e1-baf9-3d266bb7e06b'::uuid
         AND loc.is_active AND loc.is_test
         AND ev.status='completata' AND ev.caller=auth.uid()
         AND ev.result#>>'{data,declaration_id}'=d.id::text
         AND ev.result#>>'{data,phase}'='risolto'
         AND ev.result#>'{data,auto_resolution}' IS NOT NULL
         AND ev.result#>'{data,auto_resolution}'<>'null'::jsonb)
       INTO human_pg_resolved;
   END IF;
  -- A Native PG main may already be resolved by action_declare in this same
  -- transaction. Admit only its exact completed event and protected report.
  IF a.actor_kind='pg' AND d.state='risolta' AND d.kind IN('attacco','utilita','movimento','passa')
   AND auth.uid() IS NOT NULL AND nullif(btrim(d.declaration_text),'') IS NOT NULL
   AND mission_narrative_internal.scene_native_round_bound_v1(
    (SELECT master_session_id FROM public.combat_v2_sessions WHERE id=a.session_id),d.round_id)
  THEN
   SELECT EXISTS(SELECT 1 FROM public.combat_v2_events accepted
    JOIN public.combat_v2_rounds rr ON rr.id=d.round_id AND rr.session_id=a.session_id
    JOIN public.combat_v2_round_reports report ON report.id=rr.report_id AND report.round_id=rr.id
    WHERE accepted.scope_id=d.round_id AND accepted.request_key=d.request_key
     AND accepted.operation_kind='combat_v2_action_declare' AND accepted.status='completata'
     AND accepted.caller=auth.uid() AND accepted.caller=d.controller_user_snapshot
     AND accepted.result#>>'{data,declaration_id}'=d.id::text AND accepted.result#>>'{data,phase}'='risolto'
     AND accepted.result#>>'{data,auto_resolution,data,report_id}'=report.id::text
     AND rr.state='risolto' AND rr.resolved_at IS NOT NULL AND report.narration_state='attesa'
     AND NOT report.values_written AND report.mechanics_sha256=public.combat_v2_sha256(report.mechanics))
   INTO native_pg_resolved;
  END IF;
  -- Roleless human-Master PNG Passa may auto-resolve the complete round before
  -- this publisher. Admit only the exact completed native event, with Cure's
  -- existing Staff/public scopes; no mission, exam or service staging extension.
  IF a.actor_kind='png' AND d.state='risolta' AND d.kind='passa'
   AND d.declaration_text='' AND coalesce(p_text,'')=''
   AND auth.uid() IS NOT NULL AND a.controller_user=auth.uid() THEN
   SELECT EXISTS(SELECT 1 FROM public.combat_v2_events accepted
    JOIN public.combat_v2_rounds rr ON rr.id=d.round_id AND rr.session_id=a.session_id
    JOIN public.combat_v2_sessions ss ON ss.id=rr.session_id
    JOIN public.master_v2_sessions ms ON ms.id=ss.master_session_id
    JOIN public.combat_v2_round_reports report ON report.id=rr.report_id AND report.round_id=rr.id
    WHERE ss.source_kind='master' AND ss.state='in_corso' AND ss.closed_at IS NULL
     AND ms.owner_kind='human' AND ms.tipo='duello' AND ms.master_user=auth.uid()
     AND ms.mission_id IS NULL AND ms.closed_at IS NULL AND ms.suspended_at IS NULL
     AND accepted.scope_id=d.round_id AND accepted.request_key=d.request_key
     AND accepted.operation_kind='combat_v2_action_declare' AND accepted.status='completata'
     AND accepted.caller=auth.uid() AND accepted.caller=d.controller_user_snapshot
     AND accepted.result#>>'{data,declaration_id}'=d.id::text AND accepted.result#>>'{data,phase}'='risolto'
     AND accepted.result#>>'{data,auto_resolution,data,report_id}'=report.id::text
     AND rr.state='risolto' AND rr.resolved_at IS NOT NULL AND report.narration_state='attesa'
     AND report.values_written IS NOT DISTINCT FROM public.combat_v2_values_written(ss.id)
     AND report.mechanics_sha256=public.combat_v2_sha256(report.mechanics)
     AND EXISTS(SELECT 1 FROM public.combat_v2_actors scoped_pg
       WHERE scoped_pg.session_id=ss.id AND scoped_pg.actor_kind='pg'
        AND(scoped_pg.companion_id IS NULL)
        AND(combat_panel_private.cure_staff_scope_v1(scoped_pg.id)
         OR combat_panel_private.cure_persistent_scope_v1(scoped_pg.id)))
     AND NOT EXISTS(SELECT 1 FROM mission_generic_owner.unified_round_windows uw WHERE uw.round_id=rr.id)
     AND NOT EXISTS(SELECT 1 FROM exam_regia_private.bindings eb WHERE eb.combat_session_id=ss.id))
   INTO human_png_pass_resolved;
  END IF;
  -- A protected Human duel may resolve a native release main immediately.
  -- Accept its role only from this transaction's frozen release plan and the
  -- exact completed action event/report. No arbitrary resolved PG action.
  IF a.actor_kind='pg' AND d.state='risolta' AND d.kind='utilita'
   AND auth.uid() IS NOT NULL AND a.controller_user=auth.uid()
   AND nullif(btrim(d.declaration_text),'') IS NOT NULL
   AND d.sanitized_intent#>>'{server_ability,genjutsu_release_version}'='paralisi-release/1'
  THEN
   SELECT EXISTS(SELECT 1
    FROM public.combat_v2_rounds rr
    JOIN public.combat_v2_sessions ss ON ss.id=rr.session_id
    JOIN public.master_v2_sessions ms ON ms.id=ss.master_session_id
    JOIN public.locations loc ON loc.id=ss.location_id
    JOIN public.combat_v2_events accepted ON accepted.scope_id=rr.id
    JOIN public.combat_v2_round_reports report ON report.id=rr.report_id AND report.round_id=rr.id
    JOIN combat_v2_genjutsu_internal.release_plans rp ON rp.declaration_id=d.id
    WHERE rr.id=d.round_id AND rr.session_id=a.session_id
     AND ss.source_kind='master' AND ss.state='in_corso' AND ss.closed_at IS NULL
     AND ms.owner_kind='human' AND ms.tipo='duello' AND ms.stato='in_corso'
     AND ms.closed_at IS NULL AND ms.suspended_at IS NULL AND ms.mission_id IS NULL
     AND ms.quest_kind IS NULL AND ss.location_id=ms.location_id
     AND loc.id='0b85f354-9cdb-47e1-baf9-3d266bb7e06b'::uuid AND loc.is_active AND loc.is_test
     AND combat_panel_private.human_duel_round(rr.id)
     AND combat_panel_private.uses_simulated_pools(ss.id)
     AND public.combat_v2_values_written(ss.id) IS FALSE
     AND combat_v2_genjutsu_internal.runtime_allowed(a.id)
     AND NOT EXISTS(SELECT 1 FROM mission_generic_owner.unified_round_windows uw WHERE uw.round_id=rr.id)
     AND NOT EXISTS(SELECT 1 FROM exam_regia_private.bindings eb WHERE eb.combat_session_id=ss.id)
     AND accepted.request_key=d.request_key AND accepted.operation_kind='combat_v2_action_declare'
     AND accepted.status='completata' AND accepted.caller=auth.uid()
     AND accepted.caller=d.controller_user_snapshot
     AND accepted.result#>>'{data,declaration_id}'=d.id::text
     AND accepted.result#>>'{data,phase}'='risolto'
     AND accepted.result#>>'{data,auto_resolution,data,report_id}'=report.id::text
     AND rr.state='risolto' AND rr.resolved_at IS NOT NULL AND report.narration_state='attesa'
     AND report.values_written IS FALSE AND report.mechanics_sha256=public.combat_v2_sha256(report.mechanics)
     AND rp.actor_id=a.id AND rp.round_id=rr.id AND rp.request_id=d.request_key
     AND rp.transaction_id=txid_current()
     AND rp.source_sha256=public.combat_v2_sha256(rp.source)
     AND rp.result IS NOT NULL AND rp.result_sha256=public.combat_v2_sha256(rp.result)
     AND rp.source->'intent'=d.sanitized_intent-'server_ability'
     AND rp.source->'meta'=d.sanitized_intent->'server_ability'
     AND rp.source->>'principal'=auth.uid()::text
     AND rp.source->>'controller_version'=a.controller_version::text
     AND d.controller_version_snapshot=a.controller_version
     AND d.cost_snapshot->'chakra'='0'::jsonb
     AND d.declaration_text=coalesce(p_text,''))
    INTO human_genjutsu_resolved;
  END IF;
  -- Only the approved Staff NB actor's frozen Kai release may have auto-resolved.
  IF a.actor_kind='png'AND d.state='risolta'AND d.kind='utilita'
   AND auth.uid()IS NOT NULL AND a.controller_user=auth.uid()
   AND d.sanitized_intent->>'ability_source'='jutsu'
   AND d.sanitized_intent->>'ability_id'='9f12fc98-bc97-4b95-9bcc-7ce359ebbe4f'
   AND d.sanitized_intent#>>'{server_ability,genjutsu_release_version}'='paralisi-release/1'
   AND d.sanitized_intent#>>'{server_ability,release_mode}'='kai'
   AND nullif(btrim(d.declaration_text),'')IS NOT NULL THEN
   SELECT EXISTS(SELECT 1 FROM public.combat_v2_rounds rr
    JOIN public.combat_v2_sessions ss ON ss.id=rr.session_id
    JOIN public.master_v2_sessions ms ON ms.id=ss.master_session_id
    JOIN public.locations loc ON loc.id=ss.location_id
    JOIN public.combat_v2_events accepted ON accepted.scope_id=rr.id
    JOIN public.combat_v2_round_reports report ON report.id=rr.report_id AND report.round_id=rr.id
    JOIN combat_v2_genjutsu_internal.release_plans rp ON rp.declaration_id=d.id
    JOIN combat_v2_staff_nb_internal.admissions ad ON ad.encounter_id=ss.id
    JOIN public.combat_v2_actors target ON target.id=d.target_actor_id AND target.session_id=ss.id
    WHERE rr.id=d.round_id AND rr.session_id=a.session_id
     AND ss.source_kind='master'AND ss.state='in_corso'AND ss.closed_at IS NULL
     AND ms.owner_kind='human'AND ms.tipo='duello'AND ms.master_user=auth.uid()
     AND ms.stato='in_corso'AND ms.closed_at IS NULL AND ms.suspended_at IS NULL
     AND ms.mission_id IS NULL AND ms.quest_kind IS NULL AND ms.location_id=ss.location_id
     AND loc.id='0b85f354-9cdb-47e1-baf9-3d266bb7e06b'AND loc.is_active AND loc.is_test
     AND combat_v2_staff_nb_internal.mechanics_ready(ss.id)
     AND ad.receipt IS NOT NULL AND ad.receipt_sha256=public.combat_v2_sha256(ad.receipt)
     AND combat_v2_staff_nb_internal.roster_receipt(ss.id)=ad.receipt
     AND target.actor_kind='pg'AND target.companion_id IS NULL AND target.team_key=a.team_key
     AND public.combat_v2_values_written(ss.id)IS FALSE AND combat_panel_private.uses_simulated_pools(ss.id)
     AND NOT EXISTS(SELECT 1 FROM mission_generic_owner.unified_round_windows uw WHERE uw.round_id=rr.id)
     AND NOT EXISTS(SELECT 1 FROM public.mission_run_state mr WHERE mr.master_session_id=ms.id)
     AND NOT EXISTS(SELECT 1 FROM mission_generic_owner.run_bindings rb WHERE rb.master_session_id=ms.id)
     AND NOT EXISTS(SELECT 1 FROM mission_narrative_internal.scene_runtime_v1 sr WHERE sr.master_session_id=ms.id AND sr.is_active)
     AND NOT EXISTS(SELECT 1 FROM exam_regia_private.bindings eb WHERE eb.combat_session_id=ss.id)
     AND accepted.request_key=d.request_key AND accepted.operation_kind='combat_v2_action_declare'
     AND accepted.status='completata'AND accepted.caller=auth.uid()AND accepted.caller=d.controller_user_snapshot
     AND accepted.result#>>'{data,declaration_id}'=d.id::text AND accepted.result#>>'{data,phase}'='risolto'
     AND accepted.result#>>'{data,auto_resolution,data,report_id}'=report.id::text
     AND rr.state='risolto'AND rr.resolved_at IS NOT NULL AND report.narration_state='attesa'
     AND report.values_written IS FALSE AND report.mechanics_sha256=public.combat_v2_sha256(report.mechanics)
     AND rp.actor_id=a.id AND rp.round_id=rr.id AND rp.request_id=d.request_key AND rp.transaction_id=txid_current()
     AND rp.source_sha256=public.combat_v2_sha256(rp.source)
     AND rp.result IS NOT NULL AND rp.result_sha256=public.combat_v2_sha256(rp.result)AND rp.result=d.outcome
     AND rp.source->'intent'=d.sanitized_intent-'server_ability'AND rp.source->'meta'=d.sanitized_intent->'server_ability'
     AND rp.source->>'principal'=auth.uid()::text AND rp.source->>'controller_version'=a.controller_version::text
     AND rp.source->'provider_proof'IS NOT NULL
     AND rp.source#>>'{provider_proof,contract}'='staff-nb-kai/1'
     AND rp.source->'provider_proof'=combat_v2_staff_nb_internal.kai_frozen_authority(a.id)
     AND rp.source#>>'{provider_proof,target_actor_id}'=target.id::text
     AND jsonb_typeof(rp.source->'contact')='object'AND rp.source#>'{contact,self}'='false'::jsonb
     AND rp.source#>>'{contact,staff_nb_proof_sha256}'=public.combat_v2_sha256(rp.source->'provider_proof')
     AND rp.result#>>'{mental_release,mode}'='kai'AND rp.result#>'{mental_release,main_consumed}'='true'::jsonb
     AND rp.result#>'{mental_release,chakra_cost}'='0'::jsonb AND rp.result#>'{mental_release,damage_applied}'='0'::jsonb
     AND d.controller_version_snapshot=a.controller_version AND d.cost_snapshot->'chakra'='0'::jsonb
     AND d.declaration_text=coalesce(p_text,''))INTO staff_nb_kai_resolved;
  END IF;
  -- Native PNG defences remain private until the complete round Fato.
  -- This publisher runs before the final choice/request receipts exist: bind the
  -- live transaction permit; combat_narrative_source later verifies the completed receipts.
  IF a.actor_kind='png' AND d.kind IN('difesa','nessuna','attacco','movimento','utilita','passa')
   AND mission_narrative_internal.scene_native_round_bound_v1(
     (SELECT master_session_id FROM public.combat_v2_sessions WHERE id=a.session_id),d.round_id)
  THEN
   IF auth.uid() IS NOT NULL OR NOT public.combat_v2_is_service() OR NOT EXISTS(
    SELECT 1 FROM mission_generic_owner.panel_permits pp
    JOIN mission_generic_owner.panel_choices pc ON pc.work_id=pp.work_id
      AND pc.master_session_id=pp.master_session_id AND pc.encounter_id=pp.encounter_id
      AND pc.actor_id=pp.actor_id AND pc.principal_id=pp.principal_id AND pc.request_key=pp.request_key
    JOIN mission_generic_owner.work_items wi ON wi.id=pc.work_id
      AND wi.master_session_id=pc.master_session_id AND wi.encounter_id=pc.encounter_id
    WHERE pp.encounter_id=a.session_id AND pp.actor_id=a.id AND pp.request_key=d.request_key
      AND pp.principal_id=exam_regia_private.current_principal()
      AND pp.operation='commit' AND pp.consumed_at IS NULL
      AND pp.transaction_id=txid_current() AND pp.backend_pid=pg_backend_pid()
      AND pc.consumed_at IS NULL AND pc.controller_version=a.controller_version
      AND wi.kind='choice' AND wi.state='provider_started'
      AND wi.dispatch_receipt_id IS NOT NULL)
   THEN RAISE EXCEPTION 'NATIVE_PRIVATE_INTENT_AUTHORITY' USING ERRCODE='42501';END IF;
   native_private:=true;
  END IF;
   IF a.id IS NULL OR d.controller_user_snapshot IS DISTINCT FROM exam_regia_private.current_principal()
     OR d.controller_version_snapshot<>a.controller_version
     OR (d.state<>'inviata' AND NOT native_private AND NOT exam_human_private.round_declaration_permit_v1(d.id)
       AND NOT (
         (d.state='risolta' AND a.actor_kind='png'
           AND EXISTS(SELECT 1 FROM mission_generic_owner.unified_round_windows uw WHERE uw.round_id=d.round_id)
           AND (mission_generic_owner.unified_service_staging(d.round_id) OR human_stage))
         OR (d.state='risolta' AND a.actor_kind='pg'
           AND ((d.kind='passa' AND d.declaration_text='')
             OR (d.kind IN ('utilita','movimento','passa')
               AND nullif(btrim(d.declaration_text),'') IS NOT NULL
               AND EXISTS(SELECT 1 FROM mission_generic_owner.unified_round_windows uw2
                 JOIN mission_generic_owner.flow_staff_sessions fs2 ON fs2.master_session_id=uw2.master_session_id AND fs2.enabled
                 JOIN public.master_v2_sessions ms2 ON ms2.id=fs2.master_session_id
                   AND ms2.owner_kind='ai_service' AND ms2.closed_at IS NULL
                 JOIN public.locations l2 ON l2.id=ms2.location_id AND l2.is_test
                 WHERE uw2.round_id=d.round_id AND uw2.side='pg' AND uw2.publication_id IS NOT NULL
                   AND ms2.id=(SELECT master_session_id FROM public.combat_v2_sessions WHERE id=a.session_id))))
           AND (EXISTS(SELECT 1 FROM mission_generic_owner.unified_round_windows uw WHERE uw.round_id=d.round_id)
             OR combat_panel_private.human_duel_round(d.round_id)))
         OR human_pg_resolved OR native_pg_resolved OR human_png_pass_resolved OR human_genjutsu_resolved OR staff_nb_kai_resolved))
     OR d.declaration_text IS DISTINCT FROM coalesce(p_text,'') THEN
     RAISE EXCEPTION 'panel_role_declaration_scope_invalid' USING ERRCODE='42501'; END IF;
  SELECT location_id INTO STRICT location FROM public.combat_v2_sessions WHERE id=a.session_id;
  IF native_private THEN RETURN NULL;END IF;
  IF a.actor_kind='png' AND exam_human_private.round_declaration_permit_v1(d.id) THEN RETURN NULL; END IF;
  IF a.actor_kind='png' AND human_window THEN
    IF NOT human_stage THEN RAISE EXCEPTION 'REGIA_FATO_PENDING' USING ERRCODE='42501'; END IF;
    RETURN NULL;
  END IF;

 IF a.actor_kind='png' AND EXISTS(
  SELECT 1 FROM mission_generic_owner.unified_batches ub
   WHERE ub.master_session_id=(SELECT master_session_id FROM public.combat_v2_sessions WHERE id=a.session_id)
     AND ub.state IN ('preparing','ready') AND ub.composition_kind='entry_png'
     AND ub.payload->>'schema_version'='mission-generic-narration/4')
  AND (mission_generic_owner.principal_in_session(
   (SELECT master_session_id FROM public.combat_v2_sessions WHERE id=a.session_id),exam_regia_private.current_principal())
   AND mission_generic_owner.actor_principal(a.id)=exam_regia_private.current_principal()) IS NOT TRUE
 THEN RAISE EXCEPTION 'MRS_V4_PUBLISHER_PRINCIPAL_INVALID' USING ERRCODE='42501'; END IF;

 IF a.actor_kind='png' AND mission_generic_owner.principal_in_session(
  (SELECT master_session_id FROM public.combat_v2_sessions WHERE id=a.session_id),exam_regia_private.current_principal())
  AND mission_generic_owner.actor_principal(a.id)=exam_regia_private.current_principal() THEN
  IF nullif(btrim(p_text),'') IS NULL THEN RAISE EXCEPTION 'MG_PNG_ATTEMPT_EMPTY'; END IF;
  IF mission_generic_owner.try_stage_deferred_png_v4(d.id,p_text) THEN RETURN NULL; END IF;
   -- Only the protected Mission Generic Staff path can defer this public text.
   -- Entry PNG v4 keeps its separate sealed-slot publisher and cannot fall through.
   IF EXISTS(SELECT 1 FROM mission_generic_owner.unified_round_windows uw
      JOIN mission_generic_owner.unified_batches ub ON ub.id=uw.batch_id
      JOIN mission_generic_owner.flow_staff_sessions fs ON fs.master_session_id=ub.master_session_id AND fs.enabled
      JOIN public.master_v2_sessions ms ON ms.id=fs.master_session_id
       AND ms.owner_kind='ai_service' AND ms.closed_at IS NULL
      JOIN public.locations loc ON loc.id=ms.location_id AND loc.id=location AND loc.is_test
      WHERE uw.round_id=d.round_id AND ub.master_session_id=(SELECT master_session_id FROM public.combat_v2_sessions WHERE id=a.session_id)
        AND NOT (ub.composition_kind='entry_png' AND ub.payload->>'schema_version'='mission-generic-narration/4'))
   THEN RETURN NULL; END IF;
  INSERT INTO public.messages(location_id,character_id,author_name,body,kind)
   VALUES(location,NULL,'Fato',p_text,'fato') RETURNING id INTO v_message_id;
  INSERT INTO combat_consumer_private.declaration_messages
   VALUES(d.id,v_message_id,public._combat_narrative_sha(v_message_id));
  RETURN v_message_id;
 END IF;
 IF a.actor_kind='png' AND EXISTS(SELECT 1 FROM exam_regia_private.bindings b
 WHERE b.png_actor_id=a.id AND b.combat_session_id=a.session_id
 AND b.service_principal_id=exam_regia_private.current_principal() AND b.state='active') THEN
  -- La dichiarazione resta immutabile; testo PNG pubblicato soltanto via ricevuta SESSION.
  RETURN NULL;
 END IF;
 IF a.actor_kind='pg' AND exam_regia_private.is_bound(a.session_id) THEN
  IF length(btrim(coalesce(p_text,'')))=0 THEN RETURN NULL; END IF;
  v_message_id:=public._esame_testo_candidato(a.session_id,p_text);
  PERFORM combat_consumer_private.record_message(d.id,v_message_id);
  RETURN v_message_id;
 END IF;
 IF length(btrim(coalesce(p_text,'')))=0 THEN RETURN NULL; END IF;
 IF a.actor_kind='pg' THEN
   guided_before:=current_setting('app.combat_guidata',true);
   PERFORM set_config('app.combat_guidata','1',true);
   BEGIN
     v_message_id:=public.post_message(location,p_text,NULL,NULL,NULL);
   EXCEPTION WHEN OTHERS THEN
     PERFORM set_config('app.combat_guidata',coalesce(guided_before,''),true); RAISE;
   END;
   PERFORM set_config('app.combat_guidata',coalesce(guided_before,''),true);
   PERFORM combat_consumer_private.record_message(d.id,v_message_id);
 ELSIF a.actor_kind='png' THEN
   v_message_id:=public.post_fato_manual(location,p_text);
   IF NOT EXISTS(SELECT 1 FROM public.messages m JOIN public.fato_manual_audit f ON f.message_id=m.id
     WHERE m.id=v_message_id AND m.location_id=location AND m.kind='fato' AND m.character_id IS NULL
       AND f.actor_user=exam_regia_private.current_principal() AND f.location_id=location) THEN
     RAISE EXCEPTION 'panel_role_message_scope_invalid' USING ERRCODE='42501'; END IF;
   INSERT INTO combat_consumer_private.declaration_messages
     VALUES(d.id,v_message_id,public._combat_narrative_sha(v_message_id));
 ELSE RAISE EXCEPTION 'panel_role_actor_kind_invalid' USING ERRCODE='22023'; END IF;
 RETURN v_message_id;
END $function$;
CREATE OR REPLACE FUNCTION clan_innata_private.eligibility_release_assert()
 RETURNS void
 LANGUAGE plpgsql
 STABLE SECURITY DEFINER
 SET search_path TO 'pg_catalog', 'public', 'clan_innata_private'
AS $function$
declare v_marionetta boolean:=false; v_panel boolean:=false; v_catalogo boolean:=false;
begin
 v_catalogo:=clan_innata_private.catalogo_eligibility_release_v1();

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
   ('public.combat_v2_character_snapshot(uuid)',case when v_marionetta then '20c680c16a5ba1adedada1b9dcb6b5ee2f91bf01ddbdd9c0d40064d9d2d57ee3' else '323d6dd5a1cfac2ad6535fb73a4aefb03d33c7aa2894b9196489c17880046f87' end,'postgres:EXECUTE:false,service_role:EXECUTE:false'),
   ('public.combat_v2_actor_ability(uuid,text,uuid,boolean)',CASE WHEN v_catalogo THEN '512afb87dcdaaae4c394ea5eff500bcbf12123dea43ee13588e84fb5c19563d8' ELSE 'cb9e81c2b23aedb968eafa00f15dc3de188e57a5e72f04805a2d0617934575a7'END,'postgres:EXECUTE:false,service_role:EXECUTE:false'),
   ('public.combat_v2_round_options(uuid,uuid)',case when v_panel then '0b3acc15933027fa840ca03c0d02f082aecf6f2ccedcdefd737127bed1d853d1' when v_marionetta then '6b9012a057baa9bc06b201ce6bcc5b8d8bb4a832ae9a462444c5e3ef55e0c8cb' else '3be90b0da7f02c826ffdfcd594d2132a4af9128291e3417278ad6adac88f6129' end,'authenticated:EXECUTE:false,postgres:EXECUTE:false,service_role:EXECUTE:false')),
  observed as(select e.*,encode(extensions.digest(convert_to(pg_get_functiondef(e.sig::regprocedure),'UTF8'),'sha256'),'hex') actual_sha,p.proowner,p.prosecdef,p.proconfig,(select string_agg(coalesce(r.rolname,'PUBLIC')||':'||x.privilege_type||':'||x.is_grantable,',' order by coalesce(r.rolname,'PUBLIC'),x.privilege_type,x.is_grantable) from aclexplode(coalesce(p.proacl,acldefault('f',p.proowner))) x left join pg_roles r on r.oid=x.grantee) actual_acl from expected e join pg_proc p on p.oid=e.sig::regprocedure)
  select 1 from observed where actual_sha is distinct from sha or actual_acl is distinct from acl or proowner<>'postgres'::regrole or not prosecdef or proconfig is distinct from array['search_path=""'])
 then raise exception 'runtime_eligibility_full_seal_drift';end if;
 if encode(extensions.digest(convert_to(pg_get_functiondef('public.character_elementi(uuid)'::regprocedure),'UTF8'),'sha256'),'hex') is distinct from '2e62fad3aa654ab452c516549ca82068dd33f6496a3c1e17e3a8c805a8ddacd7'
 then raise exception 'runtime_eligibility_character_elementi_drift';end if;

 IF EXISTS(WITH expected(sig,hash,sd) AS (VALUES ('combat_v2_elemental_internal.other_meta(uuid)','18a6130387a81b22c993feaaf2613612',true),('combat_v2_elemental_internal.other_staff_binding(uuid,uuid)','cb15a27f82e60cf2ace2f22de4ca1e73',true),('combat_v2_elemental_internal.other_png_owned(uuid,uuid)','1730fa382f3f2da21b05ba43e1876330',true),('combat_v2_elemental_internal.other_profile(uuid,uuid)',CASE WHEN v_catalogo THEN 'dd1e62e9052469fae4c98fed245c730a' ELSE 'f71b7422e1af07cfb2784137d5d05f03'END,true),('combat_v2_elemental_internal.other_ability_meta(uuid,jsonb)',CASE WHEN v_catalogo THEN 'aa3d6fe2cb785a3a132a7b281bdab70a' ELSE '07a3babec6e05865d9265b09c22d0859' END,true),('combat_v2_elemental_internal.other_staff_bind(uuid,uuid,uuid)','a4fb778f33ab73c31e63904f51299985',true),('combat_v2_elemental_internal.other_geometry(uuid,uuid,pg_catalog.bool)','8776c899d5534308eb256de2ba451ae8',true),('combat_v2_elemental_internal.other_prepare_native(uuid,uuid,uuid,jsonb,pg_catalog.bool,jsonb)',CASE WHEN v_catalogo THEN '6e54b476b36ca716cf8c14f33ef9667e' ELSE '0e93d6425a2e8a151765040279758310'END,true),('combat_v2_elemental_internal.other_declaration_meta(uuid,uuid,uuid,jsonb)','d37f38beb455ecfbcda7a63962013542',true),('combat_v2_elemental_internal.other_bind_source(uuid)','35714da91f1df0f2d90d5921099e1177',true),('combat_v2_elemental_internal.other_source_valid(uuid)','20b96bb421f4bfbd3eb74a33294a3080',true),('combat_v2_elemental_internal.other_prepare_ordinary(uuid,uuid,uuid)','bb260ba226bc3557058820bdd5cacc93',true),('combat_v2_elemental_internal.other_prepare_master(uuid,uuid,uuid[],jsonb,jsonb)','1159e41bd29afbed0f8a5e828a0a79de',true),('combat_v2_elemental_internal.other_preset_ready(uuid,uuid)','eda00ca66bd5e24d1ac8cd1e620bf9c4',true),('combat_v2_elemental_internal.other_quote(uuid,uuid)','d50b47aedacd9734f5561067a3d62ba8',true),('combat_v2_elemental_internal.other_target_visible(uuid,uuid,pg_catalog.numeric)','f4440fc78dec1369349183c0957b1d1e',true),('combat_v2_elemental_internal.other_offer_label(uuid,jsonb,text)','4d40c4838291ae873d83ee544a4b0044',true),('combat_v2_elemental_internal.other_draw_range(uuid,uuid,pg_catalog.bool)','4856b88270f39cc66a656ec4a679d8d3',true),('combat_v2_elemental_internal.other_substitution_available(uuid)','a89a389d107dc8ad30a007f25ef1981a',true),('combat_v2_elemental_internal.other_substitution_options(jsonb)','5c08c47feed36d8c9c7f2d44f2ab9309',true),('combat_v2_elemental_internal.other_consumer_options(jsonb)',CASE WHEN v_catalogo THEN '8423c49ce8a83f2b19361b82a53fa9f4' ELSE '204fe2a77ba4c45cc862113859836151'END,true),('combat_v2_elemental_internal.other_ordinary_copy_offers(uuid,pg_catalog.int8,jsonb)','00bec9479f3d07cac011cc6139e27ad1',true),('combat_v2_elemental_internal.other_master_options(uuid,pg_catalog.int8)',CASE WHEN v_catalogo THEN '0c79a6a78b76b9e9ef8028d75e514af7' ELSE '13cd420ffe7d757af62bc723f27ce8b3'END,true),('combat_v2_elemental_internal.other_control_target(text,uuid,uuid)',CASE WHEN v_catalogo THEN 'b1af00f3eab38ed9e74836c5441616d7' ELSE 'b811c5e103dd67321aa8a2e3c601efbf'END,true),('combat_v2_elemental_internal.other_control_apply(text,uuid,uuid,uuid)',CASE WHEN v_catalogo THEN '4cf97ca72ff52f1bd33445ba54c8dd16' ELSE '63e4716e93d126611ca0490fe218fc57'END,true),('combat_v2_elemental_internal.other_prepare_callback(text,uuid,uuid,uuid,uuid[],jsonb,jsonb)','44d80129a84b21ab9345adfb4864736f',true),('combat_v2_elemental_internal.other_commit_control(jsonb,jsonb)','21538535df526b17d42dc91c7a3d4013',true),('combat_v2_elemental_internal.other_commit_master_control(jsonb)','c1690a97d6d6398360a401098588e56a',true),('combat_v2_elemental_internal.other_comparison(uuid,uuid,jsonb,pg_catalog.int4)','3b918a70932e681e148f7a90028f2d1c',true),('combat_v2_elemental_internal.other_force_from_outcome(uuid,uuid)','429727092531f7f07cfa99e06c7808d6',true),('combat_v2_elemental_internal.other_narrative_supported(uuid)','4a0d496f8d0528005aa3309ed60e3d0b',true),('combat_v2_elemental_internal.other_narrative_projection(uuid)','8ff935d763f4e4aeac25c3d6d017ecd3',true),('combat_v2_elemental_internal.scudo_profile(uuid)','92cfb95b3f56d8249d56c7d574e38d26',true),('combat_v2_elemental_internal.scudo_prepare_defense(uuid,uuid,uuid,uuid,uuid,jsonb)','b5808b034b5a3bcf50b7bcb8336d212a',true),('combat_v2_elemental_internal.scudo_declaration_meta(uuid,uuid,uuid,uuid,jsonb)','c27749ce44a439b3d59361a59e2337e9',true),('combat_v2_elemental_internal.scudo_bind_source(uuid)','cb840b147ea888fbfa57e3e55be49697',true),('combat_v2_elemental_internal.scudo_source_valid(uuid)','eacac569a8408d9e081344eebe12f9e2',true),('combat_v2_elemental_internal.scudo_meta(uuid)','92d3214d9de700399b263d1ee9ba8f93',true),('combat_v2_elemental_internal.scudo_staff_binding(uuid,uuid)','bf78d306e9a024a88ab453b9e8317671',true),('combat_v2_elemental_internal.scudo_staff_bind(uuid,uuid,uuid)','5f0c851bc78380fd88f246ca65fdb7fe',true),('combat_v2_elemental_internal.scudo_preset_ready(uuid,uuid)','b822c5fd7f3b549d455bbbcbe9e985c5',true),('combat_v2_elemental_internal.scudo_control_target(text,uuid,uuid)','014ec28c115fd3712b43d4253ffc39a9',true),('combat_v2_elemental_internal.scudo_control_apply(text,uuid,uuid,uuid)','2730009defb70b8c045be6430f496967',true),('combat_v2_elemental_internal.scudo_commit_control(jsonb,jsonb)','8b86c31c9d637aeb01beeb1c2fa2d1e7',true),('combat_v2_elemental_internal.scudo_commit_master_control(jsonb)','9bde876c7796180ea80bea206fe5829f',true),('combat_v2_elemental_internal.scudo_ability_meta(uuid,jsonb)','029b589a7af1a873e58cd3435bee3343',true),('combat_v2_elemental_internal.scudo_quote(uuid)','5c768cd419a7166e6e23420d5af3164b',true),('combat_v2_elemental_internal.scudo_consumer_options(jsonb)','e84aa35091f26367645f35a8815c78b1',true),('combat_v2_elemental_internal.scudo_master_options(uuid,pg_catalog.int8)','33fb2ed8a14cb05a3414e7be89556659',true),('combat_v2_elemental_internal.scudo_prepare_native(uuid,uuid,uuid,uuid,jsonb)','df51b64ad4443f0acdde37fbfdd5284e',true),('combat_v2_elemental_internal.scudo_narrative(uuid)','c580ef1cdbaff1598a7863603aa5c9a3',true),('combat_v2_elemental_internal.scarica_contact_range(uuid,uuid)','f92feff3bb5167ba034931dcb3832f4e',true),('combat_v2_elemental_internal.scarica_contact_witness(uuid,uuid,uuid,uuid)','34fb9bc5836831510ebd6e300e60a408',true),('combat_v2_elemental_internal.scarica_source_contact_valid(uuid)','57ed0bac1c1d36d8fd259010ceab4538',true)) SELECT 1 FROM expected e LEFT JOIN pg_proc p ON p.oid=to_regprocedure(e.sig) WHERE p.oid IS NULL OR md5(p.prosrc) IS DISTINCT FROM e.hash OR p.prosecdef IS DISTINCT FROM e.sd OR p.proowner IS DISTINCT FROM 'postgres'::regrole OR p.proconfig IS DISTINCT FROM ARRAY['search_path=""'] OR p.proacl IS DISTINCT FROM '{postgres=X/postgres}'::aclitem[]) THEN RAISE EXCEPTION 'runtime_elemental_complete_helper_drift';END IF;
end $function$;
CREATE OR REPLACE FUNCTION clan_innata_private.catalogo_eligibility_release_v1()
 RETURNS boolean
 LANGUAGE plpgsql
 STABLE SECURITY DEFINER
 SET search_path TO ''
AS $function$
DECLARE
 rr mission_factory_owner.editor_release_readiness%ROWTYPE;root jsonb;binding jsonb;amendment jsonb;
 params constant jsonb:=$compat_metadata${"expected_alias_count":7,"shared_functions":[{"oid":"42942","signature":"combat_consumer_private.narrative_context(uuid)","source_md5":"84031451f48f40639d7f2a1fe8e957d3","ddl_md5":"3f67e976ddab257ce59ec1785a0365fb","abi":{"acl":"{postgres=X/postgres}","oid":"42942","kind":"f","owner":"postgres","config":["search_path=\"\""],"secdef":true,"strict":false,"nspname":"combat_consumer_private","proname":"narrative_context","returns":"jsonb","language":"plpgsql","parallel":"u","arg_modes":null,"arg_names":["p_round"],"arg_types":"2950","leakproof":false,"signature":"combat_consumer_private.narrative_context(uuid)","volatility":"s"}},{"oid":"46723","signature":"combat_consumer_private.narrative_declaration_supported(uuid)","source_md5":"1ed7184037cedfef9d606dfd7090e7a4","ddl_md5":"9d2cad68a149da7f97c177bcf51d73c0","abi":{"acl":"{postgres=X/postgres}","oid":"46723","kind":"f","owner":"postgres","config":["search_path=\"\""],"secdef":true,"strict":false,"nspname":"combat_consumer_private","proname":"narrative_declaration_supported","returns":"boolean","language":"plpgsql","parallel":"u","arg_modes":null,"arg_names":["p_declaration"],"arg_types":"2950","leakproof":false,"signature":"combat_consumer_private.narrative_declaration_supported(uuid)","volatility":"s"}},{"oid":"42968","signature":"combat_consumer_private.validate_narrative_result(jsonb)","source_md5":"6664101fcd222bd583e9ae8cf7b2b7fc","ddl_md5":"097d6805ce2b21e21fc9aa7fe2a5a9ca","abi":{"acl":"{postgres=X/postgres}","oid":"42968","kind":"f","owner":"postgres","config":["search_path=\"\""],"secdef":false,"strict":false,"nspname":"combat_consumer_private","proname":"validate_narrative_result","returns":"void","language":"plpgsql","parallel":"u","arg_modes":null,"arg_names":["p"],"arg_types":"3802","leakproof":false,"signature":"combat_consumer_private.validate_narrative_result(jsonb)","volatility":"i"}},{"oid":"52137","signature":"combat_effects_private.lifecycle_before_report(uuid)","source_md5":"bc4009af6a274d51e6b96fc51f7a7a78","ddl_md5":"ee929b8e4bb4efcd584e7755aa5df682","abi":{"acl":"{postgres=X/postgres}","oid":"52137","kind":"f","owner":"postgres","config":["search_path=\"\""],"secdef":true,"strict":false,"nspname":"combat_effects_private","proname":"lifecycle_before_report","returns":"jsonb","language":"plpgsql","parallel":"u","arg_modes":null,"arg_names":["p_round"],"arg_types":"2950","leakproof":false,"signature":"combat_effects_private.lifecycle_before_report(uuid)","volatility":"v"}},{"oid":"52136","signature":"combat_effects_private.lifecycle_main_end(uuid)","source_md5":"a1948e8ce4fc505fc23e4e4089958507","ddl_md5":"0b743c53cb23a3402542468dc3096430","abi":{"acl":"{postgres=X/postgres}","oid":"52136","kind":"f","owner":"postgres","config":["search_path=\"\""],"secdef":true,"strict":false,"nspname":"combat_effects_private","proname":"lifecycle_main_end","returns":"jsonb","language":"plpgsql","parallel":"u","arg_modes":null,"arg_names":["p_declaration"],"arg_types":"2950","leakproof":false,"signature":"combat_effects_private.lifecycle_main_end(uuid)","volatility":"v"}},{"oid":"52133","signature":"combat_effects_private.lifecycle_open(uuid,uuid)","source_md5":"25b975033c044147b540a6e6492f1b85","ddl_md5":"531b5e14f873e40a1b5042f40ea1b15d","abi":{"acl":"{postgres=X/postgres}","oid":"52133","kind":"f","owner":"postgres","config":["search_path=\"\""],"secdef":true,"strict":false,"nspname":"combat_effects_private","proname":"lifecycle_open","returns":"void","language":"plpgsql","parallel":"u","arg_modes":null,"arg_names":["p_session","p_actor"],"arg_types":"2950 2950","leakproof":false,"signature":"combat_effects_private.lifecycle_open(uuid,uuid)","volatility":"v"}},{"oid":"51910","signature":"combat_effects_private.personal_turn_end(uuid,uuid,uuid,text)","source_md5":"29f0a8df88c6bed279f650d49a706699","ddl_md5":"9e8138c513fa0c8824ca9c5d48aa3d54","abi":{"acl":"{postgres=X/postgres}","oid":"51910","kind":"f","owner":"postgres","config":["search_path=\"\""],"secdef":true,"strict":false,"nspname":"combat_effects_private","proname":"personal_turn_end","returns":"jsonb","language":"plpgsql","parallel":"u","arg_modes":null,"arg_names":["p_session","p_actor","p_turn","p_adapter"],"arg_types":"2950 2950 2950 25","leakproof":false,"signature":"combat_effects_private.personal_turn_end(uuid,uuid,uuid,text)","volatility":"v"}},{"oid":"51906","signature":"combat_effects_private.personal_turn_start(uuid,uuid,uuid,text)","source_md5":"e7ec43224a4640d00c53bad72ac0132d","ddl_md5":"d023d8a651a5e8ef8fdb1cc834b93391","abi":{"acl":"{postgres=X/postgres}","oid":"51906","kind":"f","owner":"postgres","config":["search_path=\"\""],"secdef":true,"strict":false,"nspname":"combat_effects_private","proname":"personal_turn_start","returns":"void","language":"plpgsql","parallel":"u","arg_modes":null,"arg_names":["p_session","p_actor","p_turn","p_adapter"],"arg_types":"2950 2950 2950 25","leakproof":false,"signature":"combat_effects_private.personal_turn_start(uuid,uuid,uuid,text)","volatility":"v"}},{"oid":"44942","signature":"combat_panel_private.commit_master_actor(jsonb)","source_md5":"0c39121bcbd32a49608e4d925560ba41","ddl_md5":"b531bb7f50d4346a09e822b2f2e95144","abi":{"acl":"{postgres=X/postgres}","oid":"44942","kind":"f","owner":"postgres","config":["search_path=\"\""],"secdef":true,"strict":false,"nspname":"combat_panel_private","proname":"commit_master_actor","returns":"jsonb","language":"plpgsql","parallel":"u","arg_modes":null,"arg_names":["p_command"],"arg_types":"3802","leakproof":false,"signature":"combat_panel_private.commit_master_actor(jsonb)","volatility":"v"}},{"oid":"45916","signature":"combat_panel_private.immobilization_actor_lifecycle()","source_md5":"5244a1f635ad7d7336d24140d288b82a","ddl_md5":"f8677e282d09ca9015c01de07391f1bc","abi":{"acl":"{postgres=X/postgres}","oid":"45916","kind":"f","owner":"postgres","config":["search_path=\"\""],"secdef":true,"strict":false,"nspname":"combat_panel_private","proname":"immobilization_actor_lifecycle","returns":"trigger","language":"plpgsql","parallel":"u","arg_modes":null,"arg_names":null,"arg_types":"","leakproof":false,"signature":"combat_panel_private.immobilization_actor_lifecycle()","volatility":"v"}},{"oid":"45918","signature":"combat_panel_private.immobilization_session_lifecycle()","source_md5":"a4671931aa6e908a94af2ad2d788d933","ddl_md5":"38bc9bc060bc1af88cf087f5e4a687bb","abi":{"acl":"{postgres=X/postgres}","oid":"45918","kind":"f","owner":"postgres","config":["search_path=\"\""],"secdef":true,"strict":false,"nspname":"combat_panel_private","proname":"immobilization_session_lifecycle","returns":"trigger","language":"plpgsql","parallel":"u","arg_modes":null,"arg_names":null,"arg_types":"","leakproof":false,"signature":"combat_panel_private.immobilization_session_lifecycle()","volatility":"v"}},{"oid":"44940","signature":"combat_panel_private.master_options(uuid,uuid,bigint)","source_md5":"daccab39aa3e67a4c1a361860b8adbdf","ddl_md5":"d48e2877b5b38f53724dcb75368c7464","abi":{"acl":"{postgres=X/postgres}","oid":"44940","kind":"f","owner":"postgres","config":["search_path=\"\""],"secdef":true,"strict":false,"nspname":"combat_panel_private","proname":"master_options","returns":"jsonb","language":"plpgsql","parallel":"u","arg_modes":null,"arg_names":["p_location","p_actor","p_expected"],"arg_types":"2950 2950 20","leakproof":false,"signature":"combat_panel_private.master_options(uuid,uuid,bigint)","volatility":"v"}},{"oid":"45000","signature":"combat_panel_private.movement_block_reason(uuid)","source_md5":"9cd995d873f2ae85f3cac5c0d7ff21ad","ddl_md5":"4830deea719904406d11aa4b05cfd764","abi":{"acl":"{postgres=X/postgres}","oid":"45000","kind":"f","owner":"postgres","config":["search_path=\"\""],"secdef":true,"strict":false,"nspname":"combat_panel_private","proname":"movement_block_reason","returns":"text","language":"plpgsql","parallel":"u","arg_modes":null,"arg_names":["p_body"],"arg_types":"2950","leakproof":false,"signature":"combat_panel_private.movement_block_reason(uuid)","volatility":"s"}},{"oid":"46019","signature":"combat_panel_private.narrative_declaration_facts(uuid)","source_md5":"89ee0fe9b71918c3ba0cf25f7a334f45","ddl_md5":"4650bb589eddf6b71249114fe08c5844","abi":{"acl":"{postgres=X/postgres}","oid":"46019","kind":"f","owner":"postgres","config":["search_path=\"\""],"secdef":true,"strict":false,"nspname":"combat_panel_private","proname":"narrative_declaration_facts","returns":"jsonb","language":"plpgsql","parallel":"u","arg_modes":null,"arg_names":["p_declaration"],"arg_types":"2950","leakproof":false,"signature":"combat_panel_private.narrative_declaration_facts(uuid)","volatility":"s"}},{"oid":"46020","signature":"combat_panel_private.narrative_ordinary_context(uuid)","source_md5":"13ad2618307934e63c1ad96186957971","ddl_md5":"a811eaf1eafd4203b019825e4d84b2dc","abi":{"acl":"{postgres=X/postgres}","oid":"46020","kind":"f","owner":"postgres","config":["search_path=\"\""],"secdef":true,"strict":false,"nspname":"combat_panel_private","proname":"narrative_ordinary_context","returns":"jsonb","language":"plpgsql","parallel":"u","arg_modes":null,"arg_names":["p_round"],"arg_types":"2950","leakproof":false,"signature":"combat_panel_private.narrative_ordinary_context(uuid)","volatility":"s"}},{"oid":"46018","signature":"combat_panel_private.narrative_outcome_facts(jsonb)","source_md5":"988cc3b61d0ebf41effda90d32e173b5","ddl_md5":"a4d973f30fbd64ace5540ea3438c8e26","abi":{"acl":"{postgres=X/postgres}","oid":"46018","kind":"f","owner":"postgres","config":["search_path=\"\""],"secdef":false,"strict":false,"nspname":"combat_panel_private","proname":"narrative_outcome_facts","returns":"jsonb","language":"plpgsql","parallel":"u","arg_modes":null,"arg_names":["p_outcome"],"arg_types":"3802","leakproof":false,"signature":"combat_panel_private.narrative_outcome_facts(jsonb)","volatility":"s"}},{"oid":"44669","signature":"combat_panel_private.ordinary_options(uuid,uuid,bigint)","source_md5":"4c23fa161abb816fb0f10d50f2642630","ddl_md5":"a75ca48f390505fa9daa33800876b945","abi":{"acl":"{postgres=X/postgres}","oid":"44669","kind":"f","owner":"postgres","config":["search_path=\"\""],"secdef":true,"strict":false,"nspname":"combat_panel_private","proname":"ordinary_options","returns":"jsonb","language":"plpgsql","parallel":"u","arg_modes":null,"arg_names":["p_location","p_actor","p_expected"],"arg_types":"2950 2950 20","leakproof":false,"signature":"combat_panel_private.ordinary_options(uuid,uuid,bigint)","volatility":"v"}},{"oid":"44955","signature":"combat_panel_private.round_details_from_source(jsonb,jsonb,jsonb)","source_md5":"23722822d09c8d2a12a5121d04c141a6","ddl_md5":"883d64a10bb28250187b01e96e2dcf5e","abi":{"acl":"{postgres=X/postgres}","oid":"44955","kind":"f","owner":"postgres","config":["search_path=\"\""],"secdef":false,"strict":false,"nspname":"combat_panel_private","proname":"round_details_from_source","returns":"jsonb","language":"plpgsql","parallel":"u","arg_modes":null,"arg_names":["p_source","p_roster","p_offers"],"arg_types":"3802 3802 3802","leakproof":false,"signature":"combat_panel_private.round_details_from_source(jsonb,jsonb,jsonb)","volatility":"i"}},{"oid":"46316","signature":"combat_panel_private.round_options_authoritative(uuid,uuid)","source_md5":"7cf9d8be18c9dab5f75b62c74a5e9e37","ddl_md5":"7758a51d9039673ab98462102c44f888","abi":{"acl":"{postgres=X/postgres}","oid":"46316","kind":"f","owner":"postgres","config":["search_path=\"\""],"secdef":true,"strict":false,"nspname":"combat_panel_private","proname":"round_options_authoritative","returns":"jsonb","language":"plpgsql","parallel":"u","arg_modes":null,"arg_names":["p_round","p_actor"],"arg_types":"2950 2950","leakproof":false,"signature":"combat_panel_private.round_options_authoritative(uuid,uuid)","volatility":"v"}},{"oid":"61967","signature":"combat_v2_elemental_internal.other_consumer_options(jsonb)","source_md5":"8423c49ce8a83f2b19361b82a53fa9f4","ddl_md5":"0d57fa274c2b6b63dc5ed1ef0a7c8ca9","abi":{"acl":"{postgres=X/postgres}","oid":"61967","kind":"f","owner":"postgres","config":["search_path=\"\""],"secdef":true,"strict":false,"nspname":"combat_v2_elemental_internal","proname":"other_consumer_options","returns":"jsonb","language":"plpgsql","parallel":"u","arg_modes":null,"arg_names":["p"],"arg_types":"3802","leakproof":false,"signature":"combat_v2_elemental_internal.other_consumer_options(jsonb)","volatility":"v"}},{"oid":"61972","signature":"combat_v2_elemental_internal.other_control_apply(text,uuid,uuid,uuid)","source_md5":"4cf97ca72ff52f1bd33445ba54c8dd16","ddl_md5":"9066a8a35e086727ed0240ea05fce684","abi":{"acl":"{postgres=X/postgres}","oid":"61972","kind":"f","owner":"postgres","config":["search_path=\"\""],"secdef":true,"strict":false,"nspname":"combat_v2_elemental_internal","proname":"other_control_apply","returns":"jsonb","language":"plpgsql","parallel":"u","arg_modes":null,"arg_names":["p_adapter","p_offer","p_actor","p_request"],"arg_types":"25 2950 2950 2950","leakproof":false,"signature":"combat_v2_elemental_internal.other_control_apply(text,uuid,uuid,uuid)","volatility":"v"}},{"oid":"61971","signature":"combat_v2_elemental_internal.other_control_target(text,uuid,uuid)","source_md5":"b1af00f3eab38ed9e74836c5441616d7","ddl_md5":"03724449dfc52ef8fcf4f89ae6eabb34","abi":{"acl":"{postgres=X/postgres}","oid":"61971","kind":"f","owner":"postgres","config":["search_path=\"\""],"secdef":true,"strict":false,"nspname":"combat_v2_elemental_internal","proname":"other_control_target","returns":"uuid","language":"plpgsql","parallel":"u","arg_modes":null,"arg_names":["p_adapter","p_offer","p_actor"],"arg_types":"25 2950 2950","leakproof":false,"signature":"combat_v2_elemental_internal.other_control_target(text,uuid,uuid)","volatility":"v"}},{"oid":"61970","signature":"combat_v2_elemental_internal.other_master_options(uuid,bigint)","source_md5":"0c79a6a78b76b9e9ef8028d75e514af7","ddl_md5":"38e2e92e5566275950c270ef5a8fe3d6","abi":{"acl":"{postgres=X/postgres}","oid":"61970","kind":"f","owner":"postgres","config":["search_path=\"\""],"secdef":true,"strict":false,"nspname":"combat_v2_elemental_internal","proname":"other_master_options","returns":"void","language":"plpgsql","parallel":"u","arg_modes":null,"arg_names":["p_context","p_expected"],"arg_types":"2950 20","leakproof":false,"signature":"combat_v2_elemental_internal.other_master_options(uuid,bigint)","volatility":"v"}},{"oid":"61954","signature":"combat_v2_elemental_internal.other_prepare_native(uuid,uuid,uuid,jsonb,boolean,jsonb)","source_md5":"6e54b476b36ca716cf8c14f33ef9667e","ddl_md5":"98acc6f2f9fcb26b47f3e6e830763e42","abi":{"acl":"{postgres=X/postgres}","oid":"61954","kind":"f","owner":"postgres","config":["search_path=\"\""],"secdef":true,"strict":false,"nspname":"combat_v2_elemental_internal","proname":"other_prepare_native","returns":"jsonb","language":"plpgsql","parallel":"u","arg_modes":null,"arg_names":["p_round","p_actor","p_request","p_intent","p_push","p_native_ref"],"arg_types":"2950 2950 2950 3802 16 3802","leakproof":false,"signature":"combat_v2_elemental_internal.other_prepare_native(uuid,uuid,uuid,jsonb,boolean,jsonb)","volatility":"v"}},{"oid":"61950","signature":"combat_v2_elemental_internal.other_profile(uuid,uuid)","source_md5":"dd1e62e9052469fae4c98fed245c730a","ddl_md5":"0959ae18dc9357f65d8d8169e39b0cb2","abi":{"acl":"{postgres=X/postgres}","oid":"61950","kind":"f","owner":"postgres","config":["search_path=\"\""],"secdef":true,"strict":false,"nspname":"combat_v2_elemental_internal","proname":"other_profile","returns":"jsonb","language":"plpgsql","parallel":"u","arg_modes":null,"arg_names":["p_actor","p_technique"],"arg_types":"2950 2950","leakproof":false,"signature":"combat_v2_elemental_internal.other_profile(uuid,uuid)","volatility":"s"}},{"oid":"39291","signature":"combat_v2_multitarget_internal.resolve_parent(uuid,uuid,uuid,boolean)","source_md5":"ea4552d934017752fa4c97e6a2480bbf","ddl_md5":"f0c0e87e074c953e6aacd51656f4f6d7","abi":{"acl":"{postgres=X/postgres}","oid":"39291","kind":"f","owner":"postgres","config":["search_path=\"\""],"secdef":true,"strict":false,"nspname":"combat_v2_multitarget_internal","proname":"resolve_parent","returns":"jsonb","language":"plpgsql","parallel":"u","arg_modes":null,"arg_names":["p_session","p_round","p_attack","p_values"],"arg_types":"2950 2950 2950 16","leakproof":false,"signature":"combat_v2_multitarget_internal.resolve_parent(uuid,uuid,uuid,boolean)","volatility":"v"}},{"oid":"42947","signature":"public.combat_consumer_narrative_claim_v1(uuid,text,uuid)","source_md5":"c144d4c43e22c5e3eb516e0d46ebf65a","ddl_md5":"2c521aac41eeea3d0a843ff05c5b1e24","abi":{"acl":"{postgres=X/postgres,service_role=X/postgres}","oid":"42947","kind":"f","owner":"postgres","config":["search_path=\"\""],"secdef":true,"strict":false,"nspname":"public","proname":"combat_consumer_narrative_claim_v1","returns":"jsonb","language":"plpgsql","parallel":"u","arg_modes":null,"arg_names":["p_round","p_report_sha256","p_request_key"],"arg_types":"2950 25 2950","leakproof":false,"signature":"public.combat_consumer_narrative_claim_v1(uuid,text,uuid)","volatility":"v"}},{"oid":"42969","signature":"public.combat_consumer_narrative_complete_v1(uuid,jsonb,uuid)","source_md5":"ca906d6285eee8a8617e0cb3db70f6f9","ddl_md5":"e56749f8d49bc345ebda55a833b0ae00","abi":{"acl":"{postgres=X/postgres,service_role=X/postgres}","oid":"42969","kind":"f","owner":"postgres","config":["search_path=\"\""],"secdef":true,"strict":false,"nspname":"public","proname":"combat_consumer_narrative_complete_v1","returns":"jsonb","language":"plpgsql","parallel":"u","arg_modes":null,"arg_names":["p_claim","p_result","p_request_key"],"arg_types":"2950 3802 2950","leakproof":false,"signature":"public.combat_consumer_narrative_complete_v1(uuid,jsonb,uuid)","volatility":"v"}},{"oid":"44808","signature":"public.combat_panel_commit_v1(jsonb)","source_md5":"9c98707e4d76a4e0a23b5e7efb504ab2","ddl_md5":"488795f7305371ce8238b2a61f42fd4c","abi":{"acl":"{postgres=X/postgres,authenticated=X/postgres}","oid":"44808","kind":"f","owner":"postgres","config":["search_path=\"\""],"secdef":true,"strict":false,"nspname":"public","proname":"combat_panel_commit_v1","returns":"jsonb","language":"plpgsql","parallel":"u","arg_modes":null,"arg_names":["p_command"],"arg_types":"3802","leakproof":false,"signature":"public.combat_panel_commit_v1(jsonb)","volatility":"v"}},{"oid":"31324","signature":"public.combat_v2_action_declare(uuid,uuid,jsonb,text,uuid)","source_md5":"77f98c15d1778bd7cc5e6fdfe8d221b8","ddl_md5":"91afc68d5d1419ed20d63b9c20fe14ea","abi":{"acl":"{postgres=X/postgres,authenticated=X/postgres,service_role=X/postgres}","oid":"31324","kind":"f","owner":"postgres","config":["search_path=\"\""],"secdef":true,"strict":false,"nspname":"public","proname":"combat_v2_action_declare","returns":"jsonb","language":"plpgsql","parallel":"u","arg_modes":null,"arg_names":["p_round","p_actor","p_intent","p_text","p_request_key"],"arg_types":"2950 2950 3802 25 2950","leakproof":false,"signature":"public.combat_v2_action_declare(uuid,uuid,jsonb,text,uuid)","volatility":"v"}},{"oid":"31311","signature":"public.combat_v2_actor_ability(uuid,text,uuid,boolean)","source_md5":"0ca27d8dd57a67f255016e0d13008b1f","ddl_md5":"0d2c8fafaf5a660558709d0b64ed1665","abi":{"acl":"{postgres=X/postgres,service_role=X/postgres}","oid":"31311","kind":"f","owner":"postgres","config":["search_path=\"\""],"secdef":true,"strict":false,"nspname":"public","proname":"combat_v2_actor_ability","returns":"jsonb","language":"sql","parallel":"u","arg_modes":null,"arg_names":["p_actor","p_source","p_ability","p_defense"],"arg_types":"2950 25 2950 16","leakproof":false,"signature":"public.combat_v2_actor_ability(uuid,text,uuid,boolean)","volatility":"s"}},{"oid":"31326","signature":"public.combat_v2_defense_declare(uuid,uuid,uuid,jsonb,text,uuid)","source_md5":"446494ad3becd44a65b241967810e589","ddl_md5":"5a97231f154dab9e97c2a03b0cc142ac","abi":{"acl":"{postgres=X/postgres,authenticated=X/postgres,service_role=X/postgres}","oid":"31326","kind":"f","owner":"postgres","config":["search_path=\"\""],"secdef":true,"strict":false,"nspname":"public","proname":"combat_v2_defense_declare","returns":"jsonb","language":"plpgsql","parallel":"u","arg_modes":null,"arg_names":["p_round","p_attack_declaration","p_actor","p_intent","p_text","p_request_key"],"arg_types":"2950 2950 2950 3802 25 2950","leakproof":false,"signature":"public.combat_v2_defense_declare(uuid,uuid,uuid,jsonb,text,uuid)","volatility":"v"}},{"oid":"31331","signature":"public.combat_v2_round_resolve(uuid,uuid)","source_md5":"4cf0eb3077ada0bb5e628bd89fef4dc3","ddl_md5":"a2572e624c5c977e1c4d20086fa22ec4","abi":{"acl":"{postgres=X/postgres,service_role=X/postgres,authenticated=X/postgres}","oid":"31331","kind":"f","owner":"postgres","config":["search_path=\"\""],"secdef":true,"strict":false,"nspname":"public","proname":"combat_v2_round_resolve","returns":"jsonb","language":"plpgsql","parallel":"u","arg_modes":null,"arg_names":["p_round","p_request_key"],"arg_types":"2950 2950","leakproof":false,"signature":"public.combat_v2_round_resolve(uuid,uuid)","volatility":"v"}},{"oid":"19700","signature":"public.post_heal(uuid,uuid)","source_md5":"dcde447ee079472efa4fd41c1c911633","ddl_md5":"9fb236d5f72312f6fb33587a2981e427","abi":{"acl":"{postgres=X/postgres,service_role=X/postgres,authenticated=X/postgres}","oid":"19700","kind":"f","owner":"postgres","config":["search_path=public"],"secdef":true,"strict":false,"nspname":"public","proname":"post_heal","returns":"text","language":"plpgsql","parallel":"u","arg_modes":null,"arg_names":["p_location","p_target_user"],"arg_types":"2950 2950","leakproof":false,"signature":"public.post_heal(uuid,uuid)","volatility":"v"}}],"private_functions":[{"signature":"combat_panel_private.catalog_lifecycle_lines_v1(jsonb,jsonb)","source_md5":"8a472424ef8d1bc4d04283d18a0d049e"},{"signature":"combat_panel_private.catalog_result_label_v1(jsonb)","source_md5":"eb0798e0d80f5b1215949f4d6d6445bd"},{"signature":"combat_panel_private.cure_bind_v1(uuid)","source_md5":"a9c1bde3a9b0de30c44312b12be60eff"},{"signature":"combat_panel_private.cure_commit_v1(jsonb)","source_md5":"61532836e90ed32ae807b92ee6632b71"},{"signature":"combat_panel_private.cure_contact_v1(uuid,uuid)","source_md5":"21de7dd5e62b5403b50065d2635e20bf"},{"signature":"combat_panel_private.cure_declaration_meta_v1(uuid,uuid,uuid,jsonb)","source_md5":"9fdec7a42f67372bc1f2e2f408f16ba1"},{"signature":"combat_panel_private.cure_defense_guard_v1()","source_md5":"72b7362b50720f93672dfa1ab96338bc"},{"signature":"combat_panel_private.cure_frozen_turn_valid_v1(uuid,uuid)","source_md5":"7785ea336dd4a1deb9dd19487756d638"},{"signature":"combat_panel_private.cure_narrative_facts_v1(uuid)","source_md5":"a32f97cddb31ccf9581ba328f1e94e49"},{"signature":"combat_panel_private.cure_neutral_preset_v1(uuid,uuid,uuid,jsonb)","source_md5":"0f48477bfc086b98e113e2dd70bba0de"},{"signature":"combat_panel_private.cure_note_voluntary_v1(uuid,uuid,text,text)","source_md5":"669353b795c5f327bdcd338c9990716d"},{"signature":"combat_panel_private.cure_offers_v1(uuid,bigint,jsonb)","source_md5":"db137b63815164ffd8435bcf87ce245c"},{"signature":"combat_panel_private.cure_persistent_execution_scope_v1(uuid)","source_md5":"ea6a91fa5940c0d3680a36c4ee962880"},{"signature":"combat_panel_private.cure_persistent_scope_v1(uuid)","source_md5":"4fdb37eb54e15b3da2845a41809ccc57"},{"signature":"combat_panel_private.cure_prepare_v1(uuid,uuid,uuid,uuid)","source_md5":"bf7f19036a2846412374c68950126ac5"},{"signature":"combat_panel_private.cure_profile_v1(uuid)","source_md5":"88ec3750ea8aa0661eaa573747325e87"},{"signature":"combat_panel_private.cure_resolve_v1(uuid)","source_md5":"d385538828e19526af5e59dc8d18f167"},{"signature":"combat_panel_private.cure_staff_execution_scope_v1(uuid)","source_md5":"9adc4dfa74e700f54ba58d8691fb8f76"},{"signature":"combat_panel_private.cure_staff_scope_v1(uuid)","source_md5":"343140ae23ba4787fa511d1e6f27092e"},{"signature":"combat_panel_private.cure_turn_clear_v1(uuid,uuid)","source_md5":"ff5fac17361830d01e19aeba05430328"},{"signature":"combat_panel_private.cure_turn_used_v1(uuid,uuid)","source_md5":"11badbd523e79faba44fa282150be54b"},{"signature":"combat_panel_private.cure_voluntary_receipt_guard_v1()","source_md5":"08bacb86944bec00bc213eddf9815dca"},{"signature":"combat_v2_genjutsu_internal.actor_meta(uuid)","source_md5":"df3798ced5e32f7cb5aef4283fd88a00"},{"signature":"combat_v2_genjutsu_internal.ally_contact(uuid,uuid)","source_md5":"32dcc6e95e61d7e9fe2389a398a07334"},{"signature":"combat_v2_genjutsu_internal.bind_release(uuid)","source_md5":"1c6bfe3e32950c77afbb8c7b91a21078"},{"signature":"combat_v2_genjutsu_internal.bind_source(uuid)","source_md5":"80c79fc14b48e386b5920d021d537ba7"},{"signature":"combat_v2_genjutsu_internal.binding(uuid)","source_md5":"404fc795700a7fbe3334464c97a5058b"},{"signature":"combat_v2_genjutsu_internal.comparison(uuid,uuid,jsonb)","source_md5":"e63a4943d52d01b719d9693039c18d6c"},{"signature":"combat_v2_genjutsu_internal.consumer_options(jsonb)","source_md5":"c8daec5fcb19dc88267f7ceab87a2be8"},{"signature":"combat_v2_genjutsu_internal.declaration_events(uuid)","source_md5":"194b5c80d8e4779c66f0fdb8c50f1de3"},{"signature":"combat_v2_genjutsu_internal.declaration_meta(uuid,uuid,uuid,jsonb)","source_md5":"1dadbb12c0a1965b0461133ca0efc5d3"},{"signature":"combat_v2_genjutsu_internal.decorate_outcome(uuid,uuid,jsonb)","source_md5":"d0160238be06fafb4ce521553d4e745a"},{"signature":"combat_v2_genjutsu_internal.defense_intent_allowed(uuid,jsonb)","source_md5":"bf261ee2a0f55a52a8bb9462333058bd"},{"signature":"combat_v2_genjutsu_internal.end_context(uuid,uuid)","source_md5":"9d931f4ac19d9170e6119458d4825b23"},{"signature":"combat_v2_genjutsu_internal.event_binding(uuid,jsonb)","source_md5":"8b3b23a81afc7c2092902373cedbe0d2"},{"signature":"combat_v2_genjutsu_internal.event_public(text)","source_md5":"ecaea9744e8960072a32e7908856f9c0"},{"signature":"combat_v2_genjutsu_internal.kai_defense_valid(uuid,uuid)","source_md5":"1ab8564f473d8a008ba29e8095a4a6de"},{"signature":"combat_v2_genjutsu_internal.master_options(uuid,bigint)","source_md5":"c9fbd722ccef5bc57cbabb67651a788f"},{"signature":"combat_v2_genjutsu_internal.movement_blocked(uuid)","source_md5":"8a243e907877525d58c71429cfbb8f98"},{"signature":"combat_v2_genjutsu_internal.narrative_facts(uuid)","source_md5":"de22bbd83e9ab8edb6a025e5131edde0"},{"signature":"combat_v2_genjutsu_internal.narrative_supported(uuid)","source_md5":"8c498c00f438621c617ae6132318ab66"},{"signature":"combat_v2_genjutsu_internal.open_turn(uuid,uuid)","source_md5":"701defaed0c81b0a6f4ccef2857a4a42"},{"signature":"combat_v2_genjutsu_internal.panel_options(uuid,bigint)","source_md5":"cb344a077d919955ef0f570ba9313d35"},{"signature":"combat_v2_genjutsu_internal.prepare(uuid,uuid,uuid,jsonb)","source_md5":"7275b845d7140c81fd2ec2ac48d3cd91"},{"signature":"combat_v2_genjutsu_internal.preset_ready(uuid)","source_md5":"b087938ff9bdc51ee5518c72beb88c04"},{"signature":"combat_v2_genjutsu_internal.profile()","source_md5":"87cf137eefa6f81cd178c039859c1c45"},{"signature":"combat_v2_genjutsu_internal.quote(uuid)","source_md5":"28ff62253407034032035e6acd8a2b6b"},{"signature":"combat_v2_genjutsu_internal.raw_attack_facts(uuid)","source_md5":"da147cc5595cac875224cbbebfe82ef8"},{"signature":"combat_v2_genjutsu_internal.real_owned(uuid)","source_md5":"f6e8ecb85aeb3c938cdc71eb0cbf80cd"},{"signature":"combat_v2_genjutsu_internal.record_event(text,uuid,jsonb)","source_md5":"9ba46dc99acb5e3063e0d813b55d0f3f"},{"signature":"combat_v2_genjutsu_internal.release_intents(uuid)","source_md5":"269945acde9a25aa53dc34e473366430"},{"signature":"combat_v2_genjutsu_internal.release_meta(uuid,uuid,uuid,jsonb)","source_md5":"9ebfc24d33a07eeb5b9a59eb85fd694e"},{"signature":"combat_v2_genjutsu_internal.report_facts(uuid)","source_md5":"03c90f3dd07812d1061c7037216304d9"},{"signature":"combat_v2_genjutsu_internal.report_projection(uuid)","source_md5":"d3c2e36c0248730650a6c6c4b34d1e47"},{"signature":"combat_v2_genjutsu_internal.resolution_enter(uuid,uuid)","source_md5":"c45574805f3171628ef99392fa255eb2"},{"signature":"combat_v2_genjutsu_internal.resolution_leave()","source_md5":"612f97c08785e572226423ed5c1f68ed"},{"signature":"combat_v2_genjutsu_internal.resolve_release(uuid)","source_md5":"0e5d351b87010bb3eaa271cb63099661"},{"signature":"combat_v2_genjutsu_internal.runtime_allowed(uuid)","source_md5":"8512b2d982094a3b339de4ec3bfd3327"},{"signature":"combat_v2_genjutsu_internal.scope(uuid)","source_md5":"ca9d5c5a82c1eeb64af358016ac50c1f"},{"signature":"combat_v2_genjutsu_internal.source_valid(uuid)","source_md5":"84ca595cfd34b8467b69c0256e94e254"},{"signature":"combat_v2_genjutsu_internal.staff_bind(uuid,uuid)","source_md5":"b8b6261b5c8f7df3c91400d5969d8eae"},{"signature":"combat_v2_genjutsu_internal.success(jsonb,integer,boolean)","source_md5":"90faca8a42e9f7f54726276f5a1e94bf"},{"signature":"combat_v2_genjutsu_internal.turn_end(uuid,uuid,uuid,text)","source_md5":"5130f380992a3585b502934e2833e716"},{"signature":"combat_v2_genjutsu_internal.turn_start(uuid,uuid,uuid,text)","source_md5":"b1781f3637f8c3414a9dd2c4038869c2"},{"signature":"combat_v2_genjutsu_internal.validate_attack_facts(jsonb)","source_md5":"0c6434b64a325213dbf8d18c603ed061"},{"signature":"combat_v2_genjutsu_internal.validate_release_facts(jsonb)","source_md5":"a46a047fa733321603e24a6102d7183d"}],"relations":[{"name":"combat_panel_private.cure_gate_v1","columns":[{"name":"singleton","type":"boolean","not_null":true,"default":"true"},{"name":"staff_enabled","type":"boolean","not_null":true,"default":"false"},{"name":"public_enabled","type":"boolean","not_null":true,"default":"false"},{"name":"contract_version","type":"text","not_null":true,"default":"'palmo-curativo/1'::text"}]},{"name":"combat_panel_private.cure_ledger_v1","columns":[{"name":"declaration_id","type":"uuid","not_null":true,"default":null},{"name":"session_id","type":"uuid","not_null":true,"default":null},{"name":"round_id","type":"uuid","not_null":true,"default":null},{"name":"actor_id","type":"uuid","not_null":true,"default":null},{"name":"target_actor_id","type":"uuid","not_null":true,"default":null},{"name":"hp_before","type":"integer","not_null":true,"default":null},{"name":"hp_after","type":"integer","not_null":true,"default":null},{"name":"hp_max","type":"integer","not_null":true,"default":null},{"name":"expected_gain","type":"integer","not_null":true,"default":null},{"name":"committed_gain","type":"integer","not_null":true,"default":null},{"name":"applied_real_gain","type":"integer","not_null":true,"default":"0"},{"name":"is_simulated","type":"boolean","not_null":true,"default":null},{"name":"facts","type":"jsonb","not_null":true,"default":null},{"name":"created_at","type":"timestamp with time zone","not_null":true,"default":"clock_timestamp()"}]},{"name":"combat_panel_private.cure_preparations_v1","columns":[{"name":"request_key","type":"uuid","not_null":true,"default":null},{"name":"transaction_id","type":"bigint","not_null":true,"default":null},{"name":"session_id","type":"uuid","not_null":true,"default":null},{"name":"round_id","type":"uuid","not_null":true,"default":null},{"name":"actor_id","type":"uuid","not_null":true,"default":null},{"name":"target_actor_id","type":"uuid","not_null":true,"default":null},{"name":"controller_user","type":"uuid","not_null":true,"default":null},{"name":"controller_version","type":"bigint","not_null":true,"default":null},{"name":"source","type":"jsonb","not_null":true,"default":null},{"name":"source_sha256","type":"text","not_null":true,"default":null},{"name":"declaration_id","type":"uuid","not_null":false,"default":null},{"name":"created_at","type":"timestamp with time zone","not_null":true,"default":"clock_timestamp()"}]},{"name":"combat_panel_private.cure_staff_profiles_v1","columns":[{"name":"actor_id","type":"uuid","not_null":true,"default":null},{"name":"session_id","type":"uuid","not_null":true,"default":null},{"name":"context_id","type":"uuid","not_null":true,"default":null},{"name":"controller_user","type":"uuid","not_null":true,"default":null},{"name":"controller_version","type":"bigint","not_null":true,"default":null},{"name":"ability","type":"jsonb","not_null":true,"default":null},{"name":"proof_sha256","type":"text","not_null":true,"default":null},{"name":"request_key","type":"uuid","not_null":true,"default":null},{"name":"created_at","type":"timestamp with time zone","not_null":true,"default":"clock_timestamp()"}]},{"name":"combat_panel_private.cure_voluntary_actions_v1","columns":[{"name":"actor_id","type":"uuid","not_null":true,"default":null},{"name":"round_id","type":"uuid","not_null":true,"default":null},{"name":"source_kind","type":"text","not_null":true,"default":null},{"name":"source_key","type":"text","not_null":true,"default":null},{"name":"created_at","type":"timestamp with time zone","not_null":true,"default":"clock_timestamp()"}]},{"name":"combat_v2_genjutsu_internal.effects","columns":[{"name":"id","type":"uuid","not_null":true,"default":"gen_random_uuid()"},{"name":"session_id","type":"uuid","not_null":true,"default":null},{"name":"source_declaration_id","type":"uuid","not_null":true,"default":null},{"name":"source_attack_target_id","type":"uuid","not_null":true,"default":null},{"name":"source_actor_id","type":"uuid","not_null":true,"default":null},{"name":"target_actor_id","type":"uuid","not_null":true,"default":null},{"name":"profile","type":"jsonb","not_null":true,"default":null},{"name":"source_outcome_sha256","type":"text","not_null":true,"default":null},{"name":"adapter","type":"text","not_null":true,"default":null},{"name":"excluded_turn_id","type":"uuid","not_null":false,"default":null},{"name":"due_turn_id","type":"uuid","not_null":false,"default":null},{"name":"state","type":"text","not_null":true,"default":null},{"name":"state_version","type":"bigint","not_null":true,"default":"1"},{"name":"created_at","type":"timestamp with time zone","not_null":true,"default":"clock_timestamp()"},{"name":"ended_at","type":"timestamp with time zone","not_null":false,"default":null},{"name":"end_reason","type":"text","not_null":false,"default":null}]},{"name":"combat_v2_genjutsu_internal.events","columns":[{"name":"event_key","type":"text","not_null":true,"default":null},{"name":"effect_id","type":"uuid","not_null":false,"default":null},{"name":"result","type":"jsonb","not_null":true,"default":null},{"name":"result_sha256","type":"text","not_null":true,"default":null},{"name":"binding","type":"jsonb","not_null":true,"default":null},{"name":"binding_sha256","type":"text","not_null":true,"default":null},{"name":"created_at","type":"timestamp with time zone","not_null":true,"default":"clock_timestamp()"}]},{"name":"combat_v2_genjutsu_internal.gate","columns":[{"name":"singleton","type":"boolean","not_null":true,"default":null},{"name":"enabled","type":"boolean","not_null":true,"default":null},{"name":"staff_enabled","type":"boolean","not_null":true,"default":null},{"name":"public_enabled","type":"boolean","not_null":true,"default":null},{"name":"version","type":"integer","not_null":true,"default":null}]},{"name":"combat_v2_genjutsu_internal.preparations","columns":[{"name":"actor_id","type":"uuid","not_null":true,"default":null},{"name":"round_id","type":"uuid","not_null":true,"default":null},{"name":"request_id","type":"uuid","not_null":true,"default":null},{"name":"transaction_id","type":"bigint","not_null":true,"default":null},{"name":"source","type":"jsonb","not_null":true,"default":null},{"name":"source_sha256","type":"text","not_null":true,"default":null}]},{"name":"combat_v2_genjutsu_internal.release_plans","columns":[{"name":"actor_id","type":"uuid","not_null":true,"default":null},{"name":"round_id","type":"uuid","not_null":true,"default":null},{"name":"request_id","type":"uuid","not_null":true,"default":null},{"name":"effect_id","type":"uuid","not_null":true,"default":null},{"name":"source","type":"jsonb","not_null":true,"default":null},{"name":"source_sha256","type":"text","not_null":true,"default":null},{"name":"transaction_id","type":"bigint","not_null":true,"default":null},{"name":"declaration_id","type":"uuid","not_null":false,"default":null},{"name":"declaration_sha256","type":"text","not_null":false,"default":null},{"name":"result","type":"jsonb","not_null":false,"default":null},{"name":"result_sha256","type":"text","not_null":false,"default":null}]},{"name":"combat_v2_genjutsu_internal.sources","columns":[{"name":"declaration_id","type":"uuid","not_null":true,"default":null},{"name":"session_id","type":"uuid","not_null":true,"default":null},{"name":"source","type":"jsonb","not_null":true,"default":null},{"name":"declaration_sha256","type":"text","not_null":true,"default":null},{"name":"source_sha256","type":"text","not_null":true,"default":null}]},{"name":"combat_v2_genjutsu_internal.staff_receipts","columns":[{"name":"actor_id","type":"uuid","not_null":true,"default":null},{"name":"session_id","type":"uuid","not_null":true,"default":null},{"name":"controller_user","type":"uuid","not_null":true,"default":null},{"name":"controller_version","type":"bigint","not_null":true,"default":null},{"name":"request_id","type":"uuid","not_null":true,"default":null},{"name":"receipt","type":"jsonb","not_null":true,"default":null},{"name":"receipt_sha256","type":"text","not_null":true,"default":null}]}],"triggers":[{"table":"clan_akimichi_private.form_commands","name":"cure_voluntary_receipt_v1","function":"combat_panel_private.cure_voluntary_receipt_guard_v1()","type":7},{"table":"clan_hoki_private.combat_events","name":"cure_voluntary_receipt_v1","function":"combat_panel_private.cure_voluntary_receipt_guard_v1()","type":7},{"table":"clan_innata_combat_private.combat_receipts","name":"cure_voluntary_receipt_v1","function":"combat_panel_private.cure_voluntary_receipt_guard_v1()","type":7},{"table":"clan_inuzuka_private.movement_receipts","name":"cure_voluntary_receipt_v1","function":"combat_panel_private.cure_voluntary_receipt_guard_v1()","type":7},{"table":"clan_marionettisti_private.control_events","name":"cure_voluntary_receipt_v1","function":"combat_panel_private.cure_voluntary_receipt_guard_v1()","type":7},{"table":"clan_marionettisti_private.movement_receipts","name":"cure_voluntary_receipt_v1","function":"combat_panel_private.cure_voluntary_receipt_guard_v1()","type":7},{"table":"clan_sabaku_private.armor_events","name":"cure_voluntary_receipt_v1","function":"combat_panel_private.cure_voluntary_receipt_guard_v1()","type":7},{"table":"combat_panel_private.master_movement_receipts","name":"cure_voluntary_receipt_v1","function":"combat_panel_private.cure_voluntary_receipt_guard_v1()","type":7},{"table":"combat_panel_private.request_receipts","name":"cure_voluntary_receipt_v1","function":"combat_panel_private.cure_voluntary_receipt_guard_v1()","type":7},{"table":"public.combat_v2_declarations","name":"cure_turn_defense_guard_v1","function":"combat_panel_private.cure_defense_guard_v1()","type":7}],"native_functions":[{"signature":"public.combat_v2_substitution_options_v1(uuid)","source_md5":"913cfd7a596794334b9b3ec8baa103a2","owner":"postgres","acl":"{postgres=X/postgres,authenticated=X/postgres}","config":["search_path=\"\""],"secdef":true,"volatility":"v","strict":false,"parallel":"u","language":"plpgsql","returns":"jsonb","arg_names":["p_attack_declaration"],"arg_modes":null,"arg_types":"2950","ddl_md5":"1dc4d3088d39991411d875ec662c5123"},{"signature":"public.combat_v2_substitution_round_offers_v1(uuid,uuid)","source_md5":"7f3c2e198105d066aceb762872f51a3d","owner":"postgres","acl":"{postgres=X/postgres,authenticated=X/postgres}","config":["search_path=\"\""],"secdef":true,"volatility":"v","strict":false,"parallel":"u","language":"plpgsql","returns":"jsonb","arg_names":["p_round","p_actor"],"arg_modes":null,"arg_types":"2950 2950","ddl_md5":"3a2b1781cc15da44f69cb940e527e864"},{"signature":"public.combat_v2_substitution_select_v1(uuid,uuid)","source_md5":"209648a06d537ad5b8870bdf8fe5c4cb","owner":"postgres","acl":"{postgres=X/postgres,authenticated=X/postgres}","config":["search_path=\"\""],"secdef":true,"volatility":"v","strict":false,"parallel":"u","language":"plpgsql","returns":"jsonb","arg_names":["p_substitution_option_id","p_request_key"],"arg_modes":null,"arg_types":"2950 2950","ddl_md5":"f2f454ef2248e5f310fdfade6e868657"}]}$compat_metadata$::jsonb;
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
 IF EXISTS(WITH expected(sig,sha,acl)AS(VALUES ('combat_panel_private.mask_native_state(jsonb)','1d2f6ad44b2ff1e9c15d897e38fee54b67c744411081f906bc33a26a42600dac','postgres:EXECUTE:false'),('combat_v2_elemental_internal.other_ability_meta(uuid,jsonb)','15fab8ec94575b4a0e163cfbdcc46272b02d47d772daa262de5483a43b18f5ac','postgres:EXECUTE:false'),('combat_panel_private.round_options_authoritative(uuid,uuid)','22bd8c8faf60ba44a644bf9ccd0f69ab8a5715383c79ff6014509dfd02290554','postgres:EXECUTE:false'),('combat_v2_elemental_internal.eligible_v1(uuid,uuid,boolean)','a5161f2993a4e0ce51864ac67ea88ba3fa6966457da1caf4ca390f17c2b1d8e9','postgres:EXECUTE:false,service_role:EXECUTE:false'),('combat_v2_elemental_internal.is_target_v1(uuid)','8af6bdfc87b76ed118b596f7c7885c6de849c5d89140f61cdd1845047cbd5724','postgres:EXECUTE:false,service_role:EXECUTE:false'),('public.combat_v2_actor_ability(uuid,text,uuid,boolean)','512afb87dcdaaae4c394ea5eff500bcbf12123dea43ee13588e84fb5c19563d8','postgres:EXECUTE:false,service_role:EXECUTE:false'),('public.combat_v2_character_snapshot(uuid)','20c680c16a5ba1adedada1b9dcb6b5ee2f91bf01ddbdd9c0d40064d9d2d57ee3','postgres:EXECUTE:false,service_role:EXECUTE:false'),('public.combat_v2_round_options(uuid,uuid)','0b3acc15933027fa840ca03c0d02f082aecf6f2ccedcdefd737127bed1d853d1','authenticated:EXECUTE:false,postgres:EXECUTE:false,service_role:EXECUTE:false'))SELECT 1 FROM expected e LEFT JOIN pg_proc p ON p.oid=to_regprocedure(e.sig)
 WHERE p.oid IS NULL OR encode(extensions.digest(convert_to(pg_get_functiondef(p.oid),'UTF8'),'sha256'),'hex')IS DISTINCT FROM e.sha
 OR p.proowner IS DISTINCT FROM 'postgres'::regrole OR p.prosecdef IS DISTINCT FROM true OR p.proconfig IS DISTINCT FROM ARRAY['search_path=""']
 OR(SELECT string_agg(coalesce(r.rolname,'PUBLIC')||':'||x.privilege_type||':'||x.is_grantable,','ORDER BY coalesce(r.rolname,'PUBLIC'),x.privilege_type,x.is_grantable)
 FROM aclexplode(coalesce(p.proacl,acldefault('f',p.proowner)))x LEFT JOIN pg_roles r ON r.oid=x.grantee)IS DISTINCT FROM e.acl)
 THEN RAISE EXCEPTION 'catalogo_eligibility_owning_port_drift';END IF;
 amendment:=root#>'{db_core,cure_command_amendment}';
 IF amendment->>'schema_version'IS DISTINCT FROM 'cure-command-amendment/1'OR coalesce(amendment->>'state','')NOT IN('active_amendment','inert_recovery')
 OR amendment->>'active_repair_kind'IS DISTINCT FROM 'paralisi-label-dispatch/1'
 OR amendment->>'commit_source_md5'IS DISTINCT FROM '61532836e90ed32ae807b92ee6632b71'
 OR amendment->>'normalized_source_identity_sha256'IS DISTINCT FROM 'fd23ca0e8178bfa52a6b6253f846f82d19578f87c465dfc0fabd2624d8c72960'
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
 OR root#>'{db_core,catalogo_families,2}'IS DISTINCT FROM (SELECT jsonb_build_array(public.combat_v2_sha256((SELECT coalesce(jsonb_agg(jsonb_build_object('signature',n.nspname||'.'||p.proname||'('||oidvectortypes(p.proargtypes)||')','source_md5',md5(p.prosrc),'ddl_md5',md5(pg_get_functiondef(p.oid)),'owner',pg_get_userbyid(p.proowner),'acl',p.proacl::text,'config',p.proconfig,'secdef',p.prosecdef,'strict',p.proisstrict,'parallel',p.proparallel::text,'volatility',p.provolatile::text,'returns',pg_get_function_result(p.oid),'language',l.lanname)ORDER BY n.nspname,p.proname,oidvectortypes(p.proargtypes)),'[]'::jsonb)FROM pg_proc p JOIN pg_namespace n ON n.oid=p.pronamespace JOIN pg_language l ON l.oid=p.prolang WHERE p.oid IN(to_regprocedure('combat_v2_staff_nb_internal.origin_guard()'),to_regprocedure('combat_v2_staff_nb_internal.preparation_allowed(uuid)'),to_regprocedure('combat_v2_staff_nb_internal.choice(uuid)'),to_regprocedure('combat_v2_staff_nb_internal.roster_offers(uuid,bigint,uuid)'),to_regprocedure('combat_v2_staff_nb_internal.native_construct(uuid,uuid[],jsonb,jsonb,uuid,uuid)'),to_regprocedure('combat_v2_staff_nb_internal.mechanics_ready(uuid)'),to_regprocedure('combat_v2_staff_nb_internal.setup_protected(uuid,uuid)'),to_regprocedure('combat_v2_staff_nb_internal.commit_roster(jsonb)'),to_regprocedure('combat_v2_staff_nb_internal.roster_receipt(uuid)'),to_regprocedure('combat_v2_staff_nb_internal.pg_scope(uuid)'),to_regprocedure('combat_v2_staff_nb_internal.kai_frozen_authority(uuid)'),to_regprocedure('combat_v2_staff_nb_internal.kai_authority(uuid)'),to_regprocedure('combat_v2_staff_nb_internal.kai_contact(uuid,uuid)'),to_regprocedure('clan_aburame_private.verme_manifest_v1()'),to_regprocedure('clan_aburame_private.verme_release_v1()'),to_regprocedure('clan_aburame_private.verme_staff_scope_v1(uuid)'),to_regprocedure('clan_aburame_private.verme_scope_v1(uuid)'),to_regprocedure('clan_aburame_private.verme_event_v1(text,uuid,uuid,uuid,uuid,uuid,text,jsonb)'),to_regprocedure('clan_aburame_private.verme_staff_prepare_v1(uuid,uuid)'),to_regprocedure('clan_aburame_private.verme_meta_v1(uuid,boolean)'),to_regprocedure('clan_aburame_private.verme_bind_v1(uuid)'),to_regprocedure('clan_aburame_private.verme_frozen_v1(uuid)'),to_regprocedure('clan_aburame_private.verme_finish_v1(uuid,uuid,boolean,integer)'),to_regprocedure('clan_aburame_private.verme_tick_v1(uuid,uuid,uuid,text)'),to_regprocedure('clan_aburame_private.verme_end_context_v1()'),to_regprocedure('clan_aburame_private.verme_report_v1(uuid,uuid)'),to_regprocedure('clan_aburame_private.verme_reserve_round_v1(uuid)'),to_regprocedure('clan_aburame_private.verme_settle_round_v1(uuid)'),to_regprocedure('clan_aburame_private.verme_narrative_v1(uuid,uuid)'),to_regprocedure('clan_akimichi_private.common_staff_scope_v1(uuid)'),to_regprocedure('clan_akimichi_private.common_scope_v1(uuid,uuid)'),to_regprocedure('clan_akimichi_private.common_prepare_staff_v1(uuid,uuid,uuid)'),to_regprocedure('clan_akimichi_private.common_modifiers_v1(text,integer,integer,integer)'),to_regprocedure('clan_akimichi_private.common_set_form_v1(uuid,uuid,text)'),to_regprocedure('clan_akimichi_private.common_defer_upkeep_v1(uuid,uuid)'),to_regprocedure('clan_akimichi_private.common_flush_upkeep_v1(uuid)'),to_regprocedure('clan_akimichi_private.cellular_meta_v1(uuid)'),to_regprocedure('clan_akimichi_private.cellular_attack_eligible_v1(uuid,uuid)'),to_regprocedure('clan_akimichi_private.cellular_bind_v1(uuid)'),to_regprocedure('clan_akimichi_private.cellular_source_valid_v1(uuid)'),to_regprocedure('clan_akimichi_private.cellular_pay_v1(uuid)'),to_regprocedure('clan_akimichi_private.cellular_snapshot_v1(uuid,jsonb)'),to_regprocedure('clan_akimichi_private.cellular_mark_v1(uuid,jsonb)'),to_regprocedure('clan_akimichi_private.cellular_calculate_v1(uuid,jsonb,integer,integer)'),to_regprocedure('clan_akimichi_private.common_calorie_balance_v1(uuid,uuid,uuid,uuid)'),to_regprocedure('clan_akimichi_private.common_admit_calories_v1(uuid)'),to_regprocedure('clan_akimichi_private.common_preflight_calories_v1(uuid)'),to_regprocedure('clan_akimichi_private.super_direct_visible_v1(uuid,uuid)'),to_regprocedure('clan_akimichi_private.common_attack_power_freeze_v1(uuid)'),to_regprocedure('clan_akimichi_private.common_panel_offers_v1(uuid,bigint,jsonb)'),to_regprocedure('clan_akimichi_private.common_panel_commit_v1(jsonb)'),to_regprocedure('clan_akimichi_private.common_result_label_v1(jsonb)'),to_regprocedure('clan_akimichi_private.common_source_root_v1()'),to_regprocedure('clan_sabaku_private.armor_absorb_packet_v1(uuid,uuid,uuid,uuid,integer)'),to_regprocedure('combat_panel_private.nara_adv_pool_v1(uuid)'),to_regprocedure('combat_panel_private.nara_adv_protected_v1(uuid)'),to_regprocedure('combat_panel_private.nara_adv_scope_v1(uuid)'),to_regprocedure('combat_panel_private.nara_adv_prepare_v1(uuid,uuid)'),to_regprocedure('combat_panel_private.nara_strangle_meta_v1(uuid)'),to_regprocedure('combat_panel_private.nara_strangle_action_meta_v1(uuid,uuid,jsonb)'),to_regprocedure('combat_panel_private.nara_strangle_bind_v1(uuid)'),to_regprocedure('combat_panel_private.nara_strangle_parent_valid_v1(uuid)'),to_regprocedure('combat_panel_private.nara_strangle_lifecycle_v1(uuid)'),to_regprocedure('combat_panel_private.nara_strangle_packet_v1(uuid,uuid,uuid,text)'),to_regprocedure('combat_panel_private.nara_strangle_resolve_v1(uuid)'),to_regprocedure('combat_panel_private.nara_strangle_turn_v1(uuid,uuid,uuid,text)'),to_regprocedure('combat_panel_private.nara_strangle_facts_revision_v1(jsonb)'),to_regprocedure('combat_panel_private.nara_strangle_facts_v1(uuid,uuid)'),to_regprocedure('combat_panel_private.nara_adv_history_guard_v1()'),to_regprocedure('combat_panel_private.nara_strangle_end_event_v1()'),to_regprocedure('combat_panel_private.nara_strangle_terminal_report_v1(uuid)'),to_regprocedure('combat_panel_private.nara_strangle_lifecycle_context_v1(uuid)'),to_regprocedure('combat_panel_private.nara_adv_offers_v1(uuid,bigint,jsonb)'),to_regprocedure('combat_panel_private.nara_adv_commit_v1(jsonb)'),to_regprocedure('combat_panel_private.nara_strangle_lifecycle_trigger_v1()')))),public.combat_v2_sha256((SELECT coalesce(jsonb_agg(jsonb_build_object('signature',n.nspname||'.'||p.proname||'('||oidvectortypes(p.proargtypes)||')','source_md5',md5(p.prosrc),'ddl_md5',md5(pg_get_functiondef(p.oid)),'owner',pg_get_userbyid(p.proowner),'acl',p.proacl::text,'config',p.proconfig,'secdef',p.prosecdef,'strict',p.proisstrict,'parallel',p.proparallel::text,'volatility',p.provolatile::text,'returns',pg_get_function_result(p.oid),'language',l.lanname)ORDER BY n.nspname,p.proname,oidvectortypes(p.proargtypes)),'[]'::jsonb)FROM pg_proc p JOIN pg_namespace n ON n.oid=p.pronamespace JOIN pg_language l ON l.oid=p.prolang WHERE p.oid IN(to_regprocedure('clan_aburame_private.actor_ability(uuid,text,uuid,boolean,jsonb)'),to_regprocedure('clan_aburame_private.attack_power_source(uuid,uuid)'),to_regprocedure('clan_aburame_private.commit_control(jsonb,jsonb,combat_consumer_private.activities,combat_consumer_private.offers,uuid)'),to_regprocedure('clan_aburame_private.commit_master_stop(jsonb)'),to_regprocedure('clan_aburame_private.consumer_options(jsonb)'),to_regprocedure('clan_aburame_private.master_offers(uuid,bigint,jsonb)'),to_regprocedure('clan_akimichi_private.apply_calorie_event(uuid,uuid,boolean,uuid,text,integer,integer,uuid,timestamp with time zone)'),to_regprocedure('clan_akimichi_private.begin_personal_turn(uuid,uuid)'),to_regprocedure('clan_akimichi_private.bind_partial(uuid)'),to_regprocedure('clan_akimichi_private.end_form(uuid,uuid,text)'),to_regprocedure('clan_akimichi_private.form_change_offer(uuid)'),to_regprocedure('clan_akimichi_private.form_impact(uuid,uuid,uuid,text,text,text,jsonb)'),to_regprocedure('clan_akimichi_private.movement_maximum(uuid,numeric)'),to_regprocedure('clan_akimichi_private.partial_meta(uuid,jsonb)'),to_regprocedure('clan_akimichi_private.set_form(uuid,uuid,boolean)'),to_regprocedure('clan_sabaku_private.armor_absorb(uuid,integer)'),to_regprocedure('clan_sabaku_private.armor_narrative_round(uuid)'),to_regprocedure('clan_sabaku_private.armor_round_facts(uuid)'),to_regprocedure('combat_consumer_private.after_publish(uuid,uuid)'),to_regprocedure('combat_consumer_private.commit_exchange(jsonb,jsonb)'),to_regprocedure('combat_consumer_private.narrative_context(uuid)'),to_regprocedure('combat_consumer_private.narrative_declaration_supported(uuid)'),to_regprocedure('combat_consumer_private.validate_narrative_result(jsonb)'),to_regprocedure('combat_effects_private.lifecycle_actor_end(uuid)'),to_regprocedure('combat_effects_private.lifecycle_open(uuid,uuid)'),to_regprocedure('combat_effects_private.lifecycle_session_end(uuid)'),to_regprocedure('combat_effects_private.personal_turn_end(uuid,uuid,uuid,text)'),to_regprocedure('combat_panel_private.catalog_result_label_v1(jsonb)'),to_regprocedure('combat_panel_private.consumer_commit_authoritative(jsonb)'),to_regprocedure('combat_panel_private.master_admin_offers(uuid,bigint,jsonb)'),to_regprocedure('combat_panel_private.master_options(uuid,uuid,bigint)'),to_regprocedure('combat_panel_private.nara_shadow_level_v1(uuid)'),to_regprocedure('combat_panel_private.narrative_declaration_facts(uuid)'),to_regprocedure('combat_panel_private.narrative_ordinary_context(uuid)'),to_regprocedure('combat_panel_private.ordinary_options(uuid,uuid,bigint)'),to_regprocedure('combat_spatial.movement_commit(uuid,uuid,uuid)'),to_regprocedure('combat_v2_genjutsu_internal.ally_contact(uuid,uuid)'),to_regprocedure('combat_v2_genjutsu_internal.master_options(uuid,bigint)'),to_regprocedure('combat_v2_genjutsu_internal.release_intents(uuid)'),to_regprocedure('combat_v2_genjutsu_internal.release_meta(uuid,uuid,uuid,jsonb)'),to_regprocedure('combat_v2_genjutsu_internal.resolve_release(uuid)'),to_regprocedure('combat_v2_genjutsu_internal.scope(uuid)'),to_regprocedure('combat_v2_multitarget_internal.resolve_parent(uuid,uuid,uuid,boolean)'),to_regprocedure('mission_factory_owner.quest_combat_offer_source_guard_v1()'),to_regprocedure('public._combat_calcola(text,jsonb,jsonb,text,text,integer,text,integer,integer,integer,integer,boolean)'),to_regprocedure('public.combat_consumer_narrative_claim_v1(uuid,text,uuid)'),to_regprocedure('public.combat_consumer_narrative_complete_v1(uuid,jsonb,uuid)'),to_regprocedure('public.combat_panel_commit_v1(jsonb)'),to_regprocedure('public.combat_v2_action_declare(uuid,uuid,jsonb,text,uuid)'),to_regprocedure('public.combat_v2_actor_ability(uuid,text,uuid,boolean)'),to_regprocedure('public.combat_v2_defense_declare(uuid,uuid,uuid,jsonb,text,uuid)'),to_regprocedure('public.combat_v2_round_resolve(uuid,uuid)'),to_regprocedure('public.master_v2_encounter_open_ninja_book_v1_human_ai_core(uuid,uuid[],jsonb,jsonb,uuid)'),to_regprocedure('combat_panel_private.publish_master_declaration(uuid,text)'),to_regprocedure('clan_innata_private.eligibility_release_assert()')))),public.combat_v2_sha256((SELECT jsonb_build_object('tables',(SELECT jsonb_agg(jsonb_build_object('schema',n.nspname,'name',c.relname,'owner',pg_get_userbyid(c.relowner),'acl',c.relacl::text,'rls',c.relrowsecurity,'force_rls',c.relforcerowsecurity,'columns',(SELECT jsonb_agg(jsonb_build_object('name',a.attname,'type',format_type(a.atttypid,a.atttypmod),'notnull',a.attnotnull,'default',pg_get_expr(d.adbin,d.adrelid),'identity',a.attidentity,'generated',a.attgenerated)ORDER BY a.attnum)FROM pg_attribute a LEFT JOIN pg_attrdef d ON d.adrelid=a.attrelid AND d.adnum=a.attnum WHERE a.attrelid=c.oid AND a.attnum>0 AND NOT a.attisdropped),'constraints',(SELECT coalesce(jsonb_agg(jsonb_build_object('name',q.conname,'definition',pg_get_constraintdef(q.oid),'validated',q.convalidated,'deferrable',q.condeferrable,'deferred',q.condeferred)ORDER BY q.conname),'[]'::jsonb)FROM pg_constraint q WHERE q.conrelid=c.oid),'indexes',(SELECT coalesce(jsonb_agg(jsonb_build_object('name',ci.relname,'definition',pg_get_indexdef(i.indexrelid),'valid',i.indisvalid,'ready',i.indisready,'live',i.indislive)ORDER BY ci.relname),'[]'::jsonb)FROM pg_index i JOIN pg_class ci ON ci.oid=i.indexrelid WHERE i.indrelid=c.oid),'triggers',(SELECT coalesce(jsonb_agg(pg_get_triggerdef(t.oid)ORDER BY t.tgname),'[]'::jsonb)FROM pg_trigger t WHERE t.tgrelid=c.oid AND NOT t.tgisinternal),'policies',(SELECT coalesce(jsonb_agg(jsonb_build_object('name',p.polname,'cmd',p.polcmd,'roles',p.polroles,'using',pg_get_expr(p.polqual,p.polrelid),'check',pg_get_expr(p.polwithcheck,p.polrelid))ORDER BY p.polname),'[]'::jsonb)FROM pg_policy p WHERE p.polrelid=c.oid))ORDER BY n.nspname,c.relname)FROM pg_class c JOIN pg_namespace n ON n.oid=c.relnamespace WHERE c.oid IN(to_regclass('combat_v2_staff_nb_internal.gate'),to_regclass('combat_v2_staff_nb_internal.roster_sources'),to_regclass('combat_v2_staff_nb_internal.admissions'),to_regclass('clan_aburame_private.verme_gate_v1'),to_regclass('clan_aburame_private.verme_staff_profiles_v1'),to_regclass('clan_aburame_private.verme_sources_v1'),to_regclass('clan_aburame_private.verme_poison_v1'),to_regclass('clan_aburame_private.verme_events_v1'),to_regclass('clan_akimichi_private.common_gate_v1'),to_regclass('clan_akimichi_private.common_staff_profiles_v1'),to_regclass('clan_akimichi_private.common_form_commands_v1'),to_regclass('clan_akimichi_private.common_attack_powers_v1'),to_regclass('clan_akimichi_private.common_pending_upkeep_v1'),to_regclass('clan_akimichi_private.cellular_sources_v1'),to_regclass('combat_panel_private.nara_adv_gate_v1'),to_regclass('combat_panel_private.nara_adv_staff_v1'),to_regclass('combat_panel_private.nara_strangle_sources_v1'),to_regclass('combat_panel_private.nara_strangle_events_v1'),to_regclass('public.master_v2_nb_actor_offers_v1'),to_regclass('clan_akimichi_private.forms'))),'catalog',(SELECT jsonb_agg(jsonb_build_object('id',t.id,'sha256',public.combat_v2_sha256(to_jsonb(t)))ORDER BY t.id)FROM public.clan_techniques t WHERE id IN('0a15282f-d6b5-4ee3-ad52-7fac2525444d','f5f26cb5-9b6f-44b3-94bc-c329a0a88b93','687b058a-807d-4cf7-8bcf-21147931b0f6')),'NBtuples',(SELECT jsonb_build_object('mechanical',(SELECT jsonb_agg(jsonb_build_object('id',v.id,'template_id',v.template_id,'content_sha256',v.content_sha256)ORDER BY v.id)FROM public.nb_mechanical_versions v WHERE v.id IN('31da0000-0000-4000-8000-000000000111','31da0000-0000-4000-8000-000000000112')),'narrative',(SELECT jsonb_agg(jsonb_build_object('id',v.id,'template_id',v.template_id,'content_sha256',v.content_sha256)ORDER BY v.id)FROM public.nb_template_versions v WHERE v.id IN('31da0000-0000-4000-8000-000000000211','31da0000-0000-4000-8000-000000000212')))),'new_triggers',(SELECT jsonb_agg(jsonb_build_object('table',e->>'table','name',t.tgname,'function',t.tgfoid::regprocedure::text,'enabled',t.tgenabled::text,'type',t.tgtype,'definition',pg_get_triggerdef(t.oid),'args_sha256',encode(extensions.digest(t.tgargs,'sha256'),'hex'))ORDER BY e->>'table',e->>'name')FROM jsonb_array_elements($joint_triggers$[{"table":"combat_v2_staff_nb_internal.roster_sources","name":"staff_nb_origin_immutable"},{"table":"public.combat_v2_sessions","name":"aburame_verme_end_session_v1"},{"table":"public.combat_v2_actors","name":"aburame_verme_end_actor_v1"},{"table":"combat_panel_private.nara_strangle_sources_v1","name":"nara_strangle_snapshot_guard_v1"},{"table":"combat_panel_private.nara_strangle_events_v1","name":"nara_strangle_events_guard_v1"},{"table":"combat_panel_private.nara_adv_staff_v1","name":"nara_strangle_staff_guard_v1"},{"table":"combat_panel_private.nara_strangle_sources_v1","name":"nara_strangle_ended_event_v1"},{"table":"combat_panel_private.immobilizations","name":"nara_strangle_parent_end_v1"},{"table":"combat_spatial.actor_states","name":"nara_strangle_geometry_end_v1"}]$joint_triggers$::jsonb)e JOIN pg_trigger t ON t.tgrelid=to_regclass(e->>'table')AND t.tgname=e->>'name'AND NOT t.tgisinternal),'NBnamespace',(SELECT jsonb_build_object('owner',pg_get_userbyid(nspowner),'acl',nspacl::text)FROM pg_namespace WHERE nspname='combat_v2_staff_nb_internal'))))))
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
 IF EXISTS(SELECT 1 FROM jsonb_array_elements($joint_expected$[{"signature":"combat_v2_staff_nb_internal.origin_guard()","source_md5":"1140049388497d2060a5559fbdcdfd1f","security_definer":true},{"signature":"combat_v2_staff_nb_internal.preparation_allowed(uuid)","source_md5":"48d0ce9a5a617b90a8d8b7484ff846c5","security_definer":true},{"signature":"combat_v2_staff_nb_internal.choice(uuid)","source_md5":"e0a9c9957b9f831a44e956fc1faa8000","security_definer":true},{"signature":"combat_v2_staff_nb_internal.roster_offers(uuid,bigint,uuid)","source_md5":"2d4f9396d3f6f3acb29d4b57dee65347","security_definer":true},{"signature":"combat_v2_staff_nb_internal.native_construct(uuid,uuid[],jsonb,jsonb,uuid,uuid)","source_md5":"9f45926f70f911af516c1a3f6899ed81","security_definer":true},{"signature":"combat_v2_staff_nb_internal.mechanics_ready(uuid)","source_md5":"d0be038e05e3baea60270c52050db778","security_definer":true},{"signature":"combat_v2_staff_nb_internal.setup_protected(uuid,uuid)","source_md5":"7543230450e0d5b9c985823fe0740b51","security_definer":true},{"signature":"combat_v2_staff_nb_internal.commit_roster(jsonb)","source_md5":"b8f661504a015b20e292eeb13990f499","security_definer":true},{"signature":"combat_v2_staff_nb_internal.roster_receipt(uuid)","source_md5":"4bf43be7f3ed838c3a2fdc64a5e2b85b","security_definer":true},{"signature":"combat_v2_staff_nb_internal.pg_scope(uuid)","source_md5":"3df42b0dd768a6291bd9096a58bf5d08","security_definer":true},{"signature":"combat_v2_staff_nb_internal.kai_frozen_authority(uuid)","source_md5":"95dd90e5eb49840c142d52ffe452a9a8","security_definer":true},{"signature":"combat_v2_staff_nb_internal.kai_authority(uuid)","source_md5":"ccff2cd6a0b988da8f62fcd63a1056e9","security_definer":true},{"signature":"combat_v2_staff_nb_internal.kai_contact(uuid,uuid)","source_md5":"ef2313c0fd4eb2ad78579b8ee0981a6e","security_definer":true},{"signature":"clan_aburame_private.verme_manifest_v1()","source_md5":"d959e35164cb3b91dae5af370e202f10","security_definer":true},{"signature":"clan_aburame_private.verme_release_v1()","source_md5":"1df436e50d123cfaf302edec8f72baea","security_definer":true},{"signature":"clan_aburame_private.verme_staff_scope_v1(uuid)","source_md5":"d4a8c0421eb673be663d716e9a4beab4","security_definer":true},{"signature":"clan_aburame_private.verme_scope_v1(uuid)","source_md5":"6e513c685ae41e3f932bf12601ef5949","security_definer":true},{"signature":"clan_aburame_private.verme_event_v1(text,uuid,uuid,uuid,uuid,uuid,text,jsonb)","source_md5":"b4c4a3c168d647e4607e526ee8808c08","security_definer":true},{"signature":"clan_aburame_private.verme_staff_prepare_v1(uuid,uuid)","source_md5":"4288e5eed6eb7b949746d4972bd7c6ff","security_definer":true},{"signature":"clan_aburame_private.verme_meta_v1(uuid,boolean)","source_md5":"03b0d2b2fe63168c4989cc7a733fa3d8","security_definer":true},{"signature":"clan_aburame_private.verme_bind_v1(uuid)","source_md5":"374b96652f29e70732937dee4e9edb7d","security_definer":true},{"signature":"clan_aburame_private.verme_frozen_v1(uuid)","source_md5":"60b6d1187a64c8afe1c7182fab1366ab","security_definer":true},{"signature":"clan_aburame_private.verme_finish_v1(uuid,uuid,boolean,integer)","source_md5":"15522dc52e63348477b2066bd48aae57","security_definer":true},{"signature":"clan_aburame_private.verme_tick_v1(uuid,uuid,uuid,text)","source_md5":"e383a9cb056c4f39f7d22480970149ee","security_definer":true},{"signature":"clan_aburame_private.verme_end_context_v1()","source_md5":"349317d7764d5ca425c7eb588d257ae1","security_definer":true},{"signature":"clan_aburame_private.verme_report_v1(uuid,uuid)","source_md5":"87e095eb88e29760a8678756d28e39ab","security_definer":true},{"signature":"clan_aburame_private.verme_reserve_round_v1(uuid)","source_md5":"85c89cf0d8b8f55e1db50073c17b5f93","security_definer":true},{"signature":"clan_aburame_private.verme_settle_round_v1(uuid)","source_md5":"53a6b0101059a9cfc462e9327e7c395a","security_definer":true},{"signature":"clan_aburame_private.verme_narrative_v1(uuid,uuid)","source_md5":"d31a97fbe8289c33e32546e1381fb9dd","security_definer":true},{"signature":"clan_akimichi_private.common_staff_scope_v1(uuid)","source_md5":"5b99799e661c5192445ed8c3c80e3315","security_definer":true},{"signature":"clan_akimichi_private.common_scope_v1(uuid,uuid)","source_md5":"b96176036ce4a9e56041ba0ea13a8b12","security_definer":true},{"signature":"clan_akimichi_private.common_prepare_staff_v1(uuid,uuid,uuid)","source_md5":"dce7a5ef3b37dbeb5cd48edf0546c254","security_definer":true},{"signature":"clan_akimichi_private.common_modifiers_v1(text,integer,integer,integer)","source_md5":"5bb71bbae1cc67857e73daa0d790a6cd","security_definer":false},{"signature":"clan_akimichi_private.common_set_form_v1(uuid,uuid,text)","source_md5":"446f6580947bc1a6b7be66ad7559ec5c","security_definer":true},{"signature":"clan_akimichi_private.common_defer_upkeep_v1(uuid,uuid)","source_md5":"cfc4c1f9fdad1ce6da9acef0e9adb23d","security_definer":true},{"signature":"clan_akimichi_private.common_flush_upkeep_v1(uuid)","source_md5":"8fe8dda8a8aafb08e8aa4b5f9bc919a2","security_definer":true},{"signature":"clan_akimichi_private.cellular_meta_v1(uuid)","source_md5":"c7b3f3fce412a1ac01ccfd188e94fe7a","security_definer":true},{"signature":"clan_akimichi_private.cellular_attack_eligible_v1(uuid,uuid)","source_md5":"1b365e150fb330c54c3094c07bb8874a","security_definer":true},{"signature":"clan_akimichi_private.cellular_bind_v1(uuid)","source_md5":"621f9037c8b7c1d575b4d9635085d706","security_definer":true},{"signature":"clan_akimichi_private.cellular_source_valid_v1(uuid)","source_md5":"ad9eac644c136fcde991a93633902b0d","security_definer":true},{"signature":"clan_akimichi_private.cellular_pay_v1(uuid)","source_md5":"843a172c962fe592f00172d8cfed7aef","security_definer":true},{"signature":"clan_akimichi_private.cellular_snapshot_v1(uuid,jsonb)","source_md5":"953342a7d013006a4cf812682285b6b0","security_definer":true},{"signature":"clan_akimichi_private.cellular_mark_v1(uuid,jsonb)","source_md5":"0fb789ae313a680dd4e83eb0e51444e2","security_definer":true},{"signature":"clan_akimichi_private.cellular_calculate_v1(uuid,jsonb,integer,integer)","source_md5":"0ea4f400225ddeef1c231ce879965c53","security_definer":true},{"signature":"clan_akimichi_private.common_calorie_balance_v1(uuid,uuid,uuid,uuid)","source_md5":"8d61faeead0597de3a87adfd548c16ff","security_definer":true},{"signature":"clan_akimichi_private.common_admit_calories_v1(uuid)","source_md5":"798c20833ceffaa85e36c0ef3bf47561","security_definer":true},{"signature":"clan_akimichi_private.common_preflight_calories_v1(uuid)","source_md5":"1960fb6064b16c1dbf91ef88161e93f6","security_definer":true},{"signature":"clan_akimichi_private.super_direct_visible_v1(uuid,uuid)","source_md5":"8fe89b774ef59f9ac66e27be00861d42","security_definer":true},{"signature":"clan_akimichi_private.common_attack_power_freeze_v1(uuid)","source_md5":"a0aef8c5b85e4afcc2a32a95800f6e27","security_definer":true},{"signature":"clan_akimichi_private.common_panel_offers_v1(uuid,bigint,jsonb)","source_md5":"289d91af1d8f0e84b4948edc3141edc6","security_definer":true},{"signature":"clan_akimichi_private.common_panel_commit_v1(jsonb)","source_md5":"43cdfb2f44029f5b220f13bff1b6e5d3","security_definer":true},{"signature":"clan_akimichi_private.common_result_label_v1(jsonb)","source_md5":"49598647a5f77b06747d266e8ae57f28","security_definer":false},{"signature":"clan_akimichi_private.common_source_root_v1()","source_md5":"219f76417a82622471b6d5689e3cd5fd","security_definer":true},{"signature":"clan_sabaku_private.armor_absorb_packet_v1(uuid,uuid,uuid,uuid,integer)","source_md5":"bce137fc38ae8f4d2333944a0bf081f7","security_definer":true},{"signature":"combat_panel_private.nara_adv_pool_v1(uuid)","source_md5":"e299333ced84428fb1f927ab42066a5b","security_definer":true},{"signature":"combat_panel_private.nara_adv_protected_v1(uuid)","source_md5":"13073c7a30b26f5a913c0149821e79ac","security_definer":true},{"signature":"combat_panel_private.nara_adv_scope_v1(uuid)","source_md5":"879b81f9d619ba3ab9253539c931874d","security_definer":true},{"signature":"combat_panel_private.nara_adv_prepare_v1(uuid,uuid)","source_md5":"bd29ec1a52a65e7c7efed66a41fc2125","security_definer":true},{"signature":"combat_panel_private.nara_strangle_meta_v1(uuid)","source_md5":"fe6d88539668bd145ea61525f35e2afa","security_definer":true},{"signature":"combat_panel_private.nara_strangle_action_meta_v1(uuid,uuid,jsonb)","source_md5":"15336a6189c6ede2f2240a03d9b10575","security_definer":true},{"signature":"combat_panel_private.nara_strangle_bind_v1(uuid)","source_md5":"5599670a3de573542f1fc5033d03db99","security_definer":true},{"signature":"combat_panel_private.nara_strangle_parent_valid_v1(uuid)","source_md5":"c73c8de463dbdee906910324c0302e94","security_definer":true},{"signature":"combat_panel_private.nara_strangle_lifecycle_v1(uuid)","source_md5":"99263809c05247500fad36e74b6c0643","security_definer":true},{"signature":"combat_panel_private.nara_strangle_packet_v1(uuid,uuid,uuid,text)","source_md5":"8c36b78f9f7c70bcbafec66edd29da80","security_definer":true},{"signature":"combat_panel_private.nara_strangle_resolve_v1(uuid)","source_md5":"8a966d5cafecd1245c155d69a88b3e9b","security_definer":true},{"signature":"combat_panel_private.nara_strangle_turn_v1(uuid,uuid,uuid,text)","source_md5":"6855e493411aa494c1166d985d965363","security_definer":true},{"signature":"combat_panel_private.nara_strangle_facts_revision_v1(jsonb)","source_md5":"b1949dfaa702714a3b72df2a94265c4d","security_definer":true},{"signature":"combat_panel_private.nara_strangle_facts_v1(uuid,uuid)","source_md5":"537f2221e2a89b5e7f10ef09640d2d2b","security_definer":true},{"signature":"combat_panel_private.nara_adv_history_guard_v1()","source_md5":"69b1e8d5b246aed2234dc1247a5d0e27","security_definer":true},{"signature":"combat_panel_private.nara_strangle_end_event_v1()","source_md5":"1e2ae345ecfa2150a12f607677102ecc","security_definer":true},{"signature":"combat_panel_private.nara_strangle_terminal_report_v1(uuid)","source_md5":"e23e524a71d5a3ef9fb6a89df0d72193","security_definer":true},{"signature":"combat_panel_private.nara_strangle_lifecycle_context_v1(uuid)","source_md5":"b3be34f23b3a6f6fc4d3a6709e1b041d","security_definer":true},{"signature":"combat_panel_private.nara_adv_offers_v1(uuid,bigint,jsonb)","source_md5":"6b25543eea4b107627050aef23f11c0f","security_definer":true},{"signature":"combat_panel_private.nara_adv_commit_v1(jsonb)","source_md5":"b57fd70e77171c807a44e5834acdfb86","security_definer":true},{"signature":"combat_panel_private.nara_strangle_lifecycle_trigger_v1()","source_md5":"15b727456c2551117972133a24862a25","security_definer":true}]$joint_expected$::jsonb)e LEFT JOIN pg_proc p ON p.oid=to_regprocedure(e->>'signature')WHERE p.oid IS NULL OR md5(p.prosrc)IS DISTINCT FROM e->>'source_md5'OR p.proowner<>'postgres'::regrole OR p.prosecdef IS DISTINCT FROM(e->>'security_definer')::boolean OR p.proconfig IS DISTINCT FROM ARRAY['search_path=""']OR has_function_privilege('anon',p.oid,'EXECUTE')OR has_function_privilege('authenticated',p.oid,'EXECUTE')OR has_function_privilege('service_role',p.oid,'EXECUTE'))THEN RAISE EXCEPTION 'JOINT_CATALOG_PRIVATE_BODY_OR_ACL_DRIFT';END IF;
 IF(SELECT count(*)FROM pg_proc p JOIN pg_namespace n ON n.oid=p.pronamespace WHERE n.nspname='clan_aburame_private'AND p.proname LIKE 'verme\_%'ESCAPE'\')<>16
 OR(SELECT count(*)FROM pg_class c JOIN pg_namespace n ON n.oid=c.relnamespace WHERE n.nspname='clan_aburame_private'AND c.relkind='r'AND c.relname LIKE 'verme\_%'ESCAPE'\')<>5
 OR(SELECT count(*)FROM pg_trigger WHERE NOT tgisinternal AND tgname IN('aburame_verme_end_session_v1','aburame_verme_end_actor_v1'))<>2
 OR(SELECT count(*)FROM pg_proc WHERE pronamespace='combat_v2_staff_nb_internal'::regnamespace AND prokind='f')<>13
 OR(SELECT count(*)FROM pg_class WHERE relnamespace='combat_v2_staff_nb_internal'::regnamespace AND relkind='r')<>3
 OR(SELECT count(*)FROM pg_class WHERE oid IN(to_regclass('combat_v2_staff_nb_internal.gate'),to_regclass('combat_v2_staff_nb_internal.roster_sources'),to_regclass('combat_v2_staff_nb_internal.admissions'),to_regclass('clan_aburame_private.verme_gate_v1'),to_regclass('clan_aburame_private.verme_staff_profiles_v1'),to_regclass('clan_aburame_private.verme_sources_v1'),to_regclass('clan_aburame_private.verme_poison_v1'),to_regclass('clan_aburame_private.verme_events_v1'),to_regclass('clan_akimichi_private.common_gate_v1'),to_regclass('clan_akimichi_private.common_staff_profiles_v1'),to_regclass('clan_akimichi_private.common_form_commands_v1'),to_regclass('clan_akimichi_private.common_attack_powers_v1'),to_regclass('clan_akimichi_private.common_pending_upkeep_v1'),to_regclass('clan_akimichi_private.cellular_sources_v1'),to_regclass('combat_panel_private.nara_adv_gate_v1'),to_regclass('combat_panel_private.nara_adv_staff_v1'),to_regclass('combat_panel_private.nara_strangle_sources_v1'),to_regclass('combat_panel_private.nara_strangle_events_v1'),to_regclass('public.master_v2_nb_actor_offers_v1'),to_regclass('clan_akimichi_private.forms')))<>20
 OR(SELECT count(*)FROM jsonb_array_elements($joint_triggers$[{"table":"combat_v2_staff_nb_internal.roster_sources","name":"staff_nb_origin_immutable"},{"table":"public.combat_v2_sessions","name":"aburame_verme_end_session_v1"},{"table":"public.combat_v2_actors","name":"aburame_verme_end_actor_v1"},{"table":"combat_panel_private.nara_strangle_sources_v1","name":"nara_strangle_snapshot_guard_v1"},{"table":"combat_panel_private.nara_strangle_events_v1","name":"nara_strangle_events_guard_v1"},{"table":"combat_panel_private.nara_adv_staff_v1","name":"nara_strangle_staff_guard_v1"},{"table":"combat_panel_private.nara_strangle_sources_v1","name":"nara_strangle_ended_event_v1"},{"table":"combat_panel_private.immobilizations","name":"nara_strangle_parent_end_v1"},{"table":"combat_spatial.actor_states","name":"nara_strangle_geometry_end_v1"}]$joint_triggers$::jsonb)e JOIN pg_trigger t ON t.tgrelid=to_regclass(e->>'table')AND t.tgname=e->>'name'AND NOT t.tgisinternal AND t.tgenabled='O')<>9
 THEN RAISE EXCEPTION 'JOINT_CATALOG_COMPONENT_COVERAGE';END IF;
 RETURN true;
END $function$;
-- Metadata changes only these two identities; their native availability remains gated.
UPDATE public.clan_techniques SET
 name='Espansione Difensiva Cellulare',uso='difesa',difensiva=true,
 chakra_cost=0,consumption_type='ad_utilizzo',req_grade='Chunin',req_stat='Kekkei Genkai',req_stat_value=50,
 req_tecnica='214af896-15f8-43e6-858b-614d2851dd3b'::uuid,requirements=$t$Arte dell'Espansione L2 · Espansione Parziale acquisita · Kekkei Genkai ≥ 50$t$,
 bersaglio='Sé stesso',tipo_azione='Reazione difensiva',gittata='contatto',colpisce_formazione=false,
 potenza=25,danno_base=0,trainings_required=2,xp_cost=100,
 durata='Una fonte offensiva',portata='Solo il proprio corpo',ricarica=NULL,
 difesa='Sostituisce la difesa ordinaria: un solo tiro KG + Resistenza; nessun contrattacco.',
 danno_effetto=$t$10 calorie per uso, chakra 0. Pdef base 25 + contributo del pool KG+Resistenza secondo la pipeline speciale comune. Dopo la difesa si applicano una volta Resistenza, protezioni fisiche e Tenuta eventualmente già attiva.$t$,
 description=$t$L'Akimichi addensa e indurisce localmente i tessuti per assorbire una singola fonte di danno fisico. È una reazione sul proprio corpo: costa 10 calorie, nessun chakra, nessuna azione principale e nessun mantenimento. Non richiede né attiva Espansione, non conferisce Massa, attacchi o contrattacchi. Usa il pool Kekkei Genkai + Resistenza e la pipeline delle difese speciali, sostituendo il tiro ordinario. Copre contatto, armi, taglio, perforazione, proiettili e Ninjutsu fisici, aree fisiche, collisioni e cadute. Non copre Genjutsu, energia elementale pura, veleno, soffocamento, danni interni, drain o fonti senza danno. Richiede coscienza e la reazione disponibile; non richiede mani libere o mobilità. Se il corpo è già espanso, Tenuta si applica nella fase ordinaria senza duplicazioni.$t$
WHERE id='687b058a-807d-4cf7-8bcf-21147931b0f6';
UPDATE public.clan_techniques SET
 uso='rapida',difensiva=false,chakra_cost=0,consumption_type='per_turno',req_grade='Jonin',
 req_stat='Kekkei Genkai',req_stat_value=70,req_tecnica='3b4c4fd0-c0c2-46a0-a387-f47a95ef7dda'::uuid,
 requirements=$t$Arte dell'Espansione L3 · Espansione acquisita · Kekkei Genkai ≥ 70$t$,
 bersaglio='Sé stesso',tipo_azione='Controllo a inizio turno personale, senza azione principale',
 colpisce_formazione=false,potenza=NULL,danno_base=0,trainings_required=3,xp_cost=150,
 durata='Sostenuta; 15 calorie a turno',portata='Il proprio corpo; nessuna portata offensiva aggiunta',ricarica=NULL,
 danno_effetto=$t$Massa = floor((KG+Forza)/20); Tenuta = floor((KG+Resistenza)/30), sostitutive della forma base. Movimento max(1,floor(normale/2)). Penalità -2 una volta alle difese basate su Velocità contro proiettili fisici o Ninjutsu diretti visibili.$t$,
 description=$t$L'Akimichi assume una forma corporea superiore, alternativa all'Espansione base. Si attiva a inizio turno personale, senza azione principale: costa 15 calorie, incluse quelle del primo turno, poi 15 per ogni mantenimento; chakra 0. Può essere attivata direttamente. Il cambio verso Super costa 15 calorie, il ritorno alla base 5; le forme non si sommano e non producono rimborsi. La disattivazione è gratuita. Una richiesta invalida conserva la forma precedente e il suo normale mantenimento; se le calorie non bastano, la forma termina prima delle azioni. Massa e Tenuta superiori sostituiscono quelle base. Il movimento è dimezzato, minimo un metro se quello ordinario è positivo; le difese su Velocità subiscono -2 solo contro proiettili fisici e Ninjutsu diretti visibili. Sono esclusi contatto, Genjutsu, aree, ambiente e attacchi non percepiti. La forma soddisfa il requisito corpo espanso, ma non aggiunge portata, area, bersagli, sfondamento, sbalzo, immunità, PV o riserva calorica. Ogni attacco richiede la propria fonte autorizzata.$t$
WHERE id='f5f26cb5-9b6f-44b3-94bc-c329a0a88b93';
-- TARGET approved HANDOFF3040–3100; D_base and Potenza are different fields.
UPDATE public.clan_techniques SET danno_base=10,potenza=25,chakra_cost=10,xp_cost=125,trainings_required=2,req_stat_value=55,req_grade='Chunin',req_tecnica='db51e5ae-8b90-4c3a-a51d-962eb9e19b38',disciplina='Ninjutsu',uso='principale',difensiva=false,consumption_type='per_turno',
 requirements=$txt$Manipolazione dell'Ombra L2 e Possesso dell'Ombra acquisiti · Chunin · Kekkei Genkai almeno55$txt$,
 description=$txt$Dal Possesso dell'Ombra già attivo sul medesimo bersaglio si sollevano mani d'ombra che comprimono il collo. L'attivazione consuma la principale e10 chakra, senza un secondo tiro di aggancio. Il mantenimento autonomo costa10 chakra nei successivi turni personali del Nara, dopo la validità e il mantenimento del Possesso padre. Ogni pagamento valido applica un solo packet fisico; la cessazione del Possesso termina anche lo Strangolamento. Nessun silenzio, perdita di chakra del bersaglio o morte automatica.$txt$,
 danno_effetto=$txt$D_base10. Potenza base25; Potenza effettiva25+floor((KG+Ninjutsu)/10), distinta dal danno. Danno10+floor(max(KG,Ninjutsu)/4) meno riduzioni fisiche; nessun bonus margine, minimo1 salvo negazione totale e cap comune65. Un packet all'attivazione e uno per mantenimento valido10CK, massimo uno per turno personale. Una sola istanza attiva per Possesso, senza stack o refresh. Statistiche proprie congelate; il padre resta distinto. Se mancano i10CK termina soltanto il figlio, senza costo negativo o rimborso. Il bersaglio conserva le liberazioni e protezioni autorizzate dal server.$txt$
WHERE id='0a15282f-d6b5-4ee3-ad52-7fac2525444d';

DO $catalogo_root$
DECLARE
 expected_parameters_sha256 constant text:='__JOINT_CATALOG_PARAMETERS_SHA256__';
 old_root_sha text;
 old_row_sha text;
 generic_ezbr constant text:='9a6889802cfa17c99a556538cccd4ad7ef75274d32adccbc192c23d257aa3e76';
 baseline_combat_ezbr constant text:='79bdb113f0203e5b0578a1211fb43f1c5cfb6b3bb5585714b4d9b5475ce27a11';
 rr mission_factory_owner.editor_release_readiness%ROWTYPE;
 prior_release mission_public_owner.release_admissions_v1%ROWTYPE;
 prior_qualification mission_public_owner.public_qualification_attestations_v1%ROWTYPE;
 params jsonb;review jsonb;binding jsonb;before_root jsonb;root jsonb;core jsonb;cfg jsonb;identity jsonb;runtime_before jsonb;expected_ui jsonb;
 shared_manifest jsonb:='[]';private_manifest jsonb:='[]';relation_manifest jsonb:='[]';trigger_manifest jsonb:='[]';
 item jsonb;h jsonb;abi jsonb;cols jsonb;descriptor jsonb;next_descriptor jsonb;alias_row record;kv record;
 relation_oid oid;function_oid oid;actual_count integer;affected integer;aliases integer:=0;
 old_generic jsonb;old_combat jsonb;edge_receipt jsonb;edge_files jsonb;base_files jsonb;changed_files jsonb;
 db_stored text;db_old_recomputed text;db_sha text;shared_sha text;private_sha text;relations_sha text;
 config_sha text;identity_sha text;root_text text;new_root_sha text;bindings jsonb;qualification jsonb;
 content_row mission_public_owner.mission_content_admissions_v1%ROWTYPE;content_request uuid;content_payload jsonb;
 changed_headers jsonb;native_manifest jsonb;pending_paths text[]:=ARRAY['["db_core"]'];current_path text[];stack_size integer;
 raw_bytes bytea;compact_bytes bytea:=''::bytea;byte_chunks bytea[]:='{}';byte_chunk bytea:=''::bytea;
 byte_index integer;byte_value integer;inside_string boolean:=false;escaped boolean:=false;
 profile_row record;profile_state jsonb;schema_name text;name_only text;
 namespace_uuid constant uuid:='9ebf5297-66c5-5a19-b35a-589b626e4a4f';
BEGIN
 IF current_user<>'postgres' OR session_user<>'postgres' OR auth.uid() IS NOT NULL THEN
  RAISE EXCEPTION 'CATALOGO_ROOT_OPERATOR_REQUIRED';END IF;
 PERFORM set_config('search_path','',true);
 IF NOT pg_try_advisory_xact_lock(hashtextextended('C1266:GENERIC-AI:AVAILABILITY',0)) THEN
  RAISE EXCEPTION 'CATALOGO_ROOT_AVAILABILITY_BUSY';END IF;
 params:=nullif(current_setting('app.joint_catalog_parameters',true),'')::jsonb;old_root_sha:=params#>>'{expected_current,root_sha256}';old_row_sha:=params#>>'{expected_current,root_row_sha256}';
 SELECT * INTO STRICT rr FROM mission_factory_owner.editor_release_readiness WHERE singleton FOR UPDATE NOWAIT;
 IF rr.revision_sha256<>old_root_sha OR rr.observed_revision_sha256 IS DISTINCT FROM old_root_sha
 OR public.combat_v2_sha256(to_jsonb(rr))<>old_row_sha
 OR encode(extensions.digest(convert_to(rr.canonical_preimage,'UTF8'),'sha256'),'hex')<>old_root_sha
 OR octet_length(rr.canonical_preimage)<>(params#>>'{expected_current,root_bytes}')::integer THEN RAISE EXCEPTION 'CATALOGO_ROOT_BASELINE_DRIFT';END IF;
 IF EXISTS(SELECT 1 FROM public.combat_v2_sessions WHERE state='in_corso' AND closed_at IS NULL)
 OR EXISTS(SELECT 1 FROM public.master_v2_sessions WHERE stato NOT IN('chiusa','annullata') AND closed_at IS NULL) THEN
  RAISE EXCEPTION 'CATALOGO_ROOT_REQUIRES_QUIESCENCE';END IF;
 params:=nullif(current_setting('app.joint_catalog_parameters',true),'')::jsonb;
 IF expected_parameters_sha256 !~ '^[0-9a-f]{64}$' OR params IS NULL
 OR public.combat_v2_sha256(params)<>expected_parameters_sha256
 OR params->>'schema_version' IS DISTINCT FROM 'joint-catalog-parameters/1' THEN
  RAISE EXCEPTION 'CATALOGO_ROOT_REVIEWED_PARAMETERS_REQUIRED';END IF;
 review:=params->'review';
 IF NOT mission_factory_owner.keys_exact_v2(review,ARRAY['ref','sha256','P0','P1','P2']) THEN
  RAISE EXCEPTION 'CATALOGO_ROOT_REVIEW_SHAPE';END IF;
 IF nullif(review->>'ref','') IS NULL OR octet_length(to_jsonb(review->>'ref')::text)>42 OR coalesce(review->>'sha256','')!~'^[0-9a-f]{64}$'
 OR review->'P0' IS DISTINCT FROM '0'::jsonb OR review->'P1' IS DISTINCT FROM '0'::jsonb OR review->'P2' IS DISTINCT FROM '0'::jsonb
 OR coalesce(params->>'source_bundle_sha256','')!~'^[0-9a-f]{64}$'
 OR params#>>'{baseline_custody,sha256}' IS DISTINCT FROM old_root_sha
 OR nullif(params#>>'{baseline_custody,ref}','') IS NULL
 OR params#>>'{compatibility,scope}' IS DISTINCT FROM 'existing_mission_capabilities_only'
 OR params#>'{compatibility,new_techniques_staff_pass}' IS DISTINCT FROM 'false'::jsonb
 OR coalesce(params#>>'{compatibility,sha256}','')!~'^[0-9a-f]{64}$'
 OR nullif(params#>>'{compatibility,ref}','') IS NULL THEN RAISE EXCEPTION 'CATALOGO_ROOT_REVIEW_SCOPE_REQUIRED';END IF;
 LOCK TABLE mission_public_owner.release_admissions_v1,mission_public_owner.public_qualification_attestations_v1,
  mission_public_owner.engine_profile_events_v1,mission_public_owner.mission_content_admissions_v1,
  mission_public_owner.party_launch_runtime_v1 IN SHARE ROW EXCLUSIVE MODE NOWAIT;
 before_root:=rr.canonical_preimage::jsonb;root:=before_root;
 -- Il JSON runtime è riletto esplicitamente per il CAS finale e conserva entrambi i booleani.
 SELECT to_jsonb(x) INTO STRICT runtime_before FROM mission_public_owner.party_launch_runtime_v1 x WHERE singleton FOR UPDATE;
 IF runtime_before IS DISTINCT FROM jsonb_build_object('singleton',true,'staff_enabled',true,'public_enabled',true,'release_sha256',old_root_sha) THEN
  RAISE EXCEPTION 'CATALOGO_ROOT_PARTY_BASELINE';END IF;
 SELECT value INTO STRICT old_generic FROM jsonb_array_elements(before_root->'edge_bundles') WHERE value->>'name'='mission_generic_ai';
 SELECT value INTO STRICT old_combat FROM jsonb_array_elements(before_root->'edge_bundles') WHERE value->>'name'='combat_narratore_ai';
 IF old_generic->>'ezbr_sha256'<>generic_ezbr OR old_generic->'version'<>'168'::jsonb
 OR(params->>'mode'='source'AND(old_combat->'version'IS DISTINCT FROM '45'::jsonb OR old_combat->>'ezbr_sha256'IS DISTINCT FROM baseline_combat_ezbr))
 OR(params->>'mode'='recovery'AND(old_combat->'version'IS DISTINCT FROM params#>'{edge_receipt,version}' OR old_combat->>'ezbr_sha256'IS DISTINCT FROM params#>>'{edge_receipt,ezbr_sha256}'))
 OR public.combat_v2_sha256(root->'ui')<>'cd76714cb188ea3f69189ac5dd793304acdc2179da724aad852f961d12ab3014' THEN
  RAISE EXCEPTION 'CATALOGO_ROOT_UNRELATED_SURFACE_DRIFT';END IF;
 edge_receipt:=params->'edge_receipt';
 IF NOT mission_factory_owner.keys_exact_v2(edge_receipt,ARRAY['version','ezbr_sha256','deployment_receipt_sha256','bundle_content_sha256','verify_jwt','import_map','entrypoint_path'])
 OR jsonb_typeof(edge_receipt->'version')IS DISTINCT FROM 'number' OR(edge_receipt->>'version')!~'^[0-9]+$'OR(edge_receipt->>'version')::integer<=45 OR edge_receipt->'verify_jwt'IS DISTINCT FROM 'false'::jsonb OR edge_receipt->'import_map'IS DISTINCT FROM 'false'::jsonb OR coalesce(edge_receipt->>'entrypoint_path','')NOT LIKE '%/source/combat_narratore_ai/index.ts' OR coalesce(edge_receipt->>'ezbr_sha256','')!~'^[0-9a-f]{64}$'
 OR coalesce(edge_receipt->>'deployment_receipt_sha256','')!~'^[0-9a-f]{64}$'
 OR edge_receipt->>'bundle_content_sha256'IS DISTINCT FROM '5ced8545d74d3aee24de041f6664bc33940d30658095e38d4b4f613ba069b5c5'THEN RAISE EXCEPTION 'JOINT_ACTUAL_REVIEWED_EDGE_RECEIPT_REQUIRED';END IF;
 edge_files:=$joint_edge_files$[{"name":"adattatore.ts","sha256":"32bf2b017f70f2b3733992d99ca868405a812c35f725c64cf66adb4f5ebc851d","bytes":19495},{"name":"common.mjs","sha256":"c73d6fa04bf22c521b502387adb261c599996e58f309ddb3b5a64dd3f56e6cc4","bytes":8305},{"name":"count.mjs","sha256":"77791e0fa712967ba7818dee45964af6e4cda1673e1f4673c0238ff387ee335f","bytes":4494},{"name":"diagnostics.ts","sha256":"5846012ec1d57cffa8a54b17dd7a3efe61a91971cdf2b97f8afe67220ebba5ce","bytes":2964},{"name":"editorial.mjs","sha256":"8d6c00b9ebc16bfff9f17c7e9670292397f266b24f4664d299c5a3e58d692766","bytes":7802},{"name":"facts.ts","sha256":"7c261e6fee5b1f608bb8bf4caccbf28e7f409eadd9e866165bbf65f27b9d411a","bytes":36210},{"name":"flow.mjs","sha256":"ceefabdb6bd9e3cfe7e85c31b4a3805f76fbf7dae11ab0ad51994e9deff7722d","bytes":5332},{"name":"index.ts","sha256":"c02e347b84556199dd883cb59e5057ff2803ff3da29d0c01e0899ba82fe6d2c3","bytes":71473},{"name":"lifecycle.mjs","sha256":"5f7299124083a5b57ce75e6fb0b917fb6cabba0a369a2d78649e31eb4ccb0d6c","bytes":7147},{"name":"orchestra.ts","sha256":"47134473ddf7153499f7ce6056b3f892af4166df86fd614cf94b4ff2d9ba4e0f","bytes":1177},{"name":"ordinary.ts","sha256":"456e734e9dd96858a44e5d86fb15d76acbff13a2727be64288fbff1601c9f502","bytes":8946},{"name":"recovery.ts","sha256":"dadcba58f18fac2aa6fba6f921a556c4653ddfa7eb6042feacd0c5e6dc554692","bytes":1081},{"name":"repertorio.json","sha256":"86b291f40f3baadb5fbe7e984e5f01e2fe910b7c645d1a77dd13a41970a4e37e","bytes":14845},{"name":"rinuncia.ts","sha256":"30832b9dd830dc32074fb5b96d6062811520cc73169d629e3c08f8dd1b00a421","bytes":3421},{"name":"runtime.ts","sha256":"c49dba1ff22b2d4d507b8e1a446319fd03f1ddd82cc1555494f6b638d991ec2e","bytes":9292},{"name":"scene.mjs","sha256":"f4cfa79821a27ac026960fde6460bd8562f8ec527698e3a3290004018d9d5301","bytes":7517},{"name":"transport.ts","sha256":"590d7e2e2d289d904ea1015049e0723236634dcce7c306ef651b125219f8ad1f","bytes":4913},{"name":"user_test.mjs","sha256":"26b1a843cd9470c173f4a0c0a259013cd08b58a3482b699fe7af5daec18be9ba","bytes":3238}]$joint_edge_files$::jsonb;
 root:=jsonb_set(root,'{edge_bundles}',(SELECT jsonb_agg(CASE WHEN b->>'name'='combat_narratore_ai'THEN b||jsonb_build_object('version',edge_receipt->'version','ezbr_sha256',edge_receipt->'ezbr_sha256','deployment_receipt_sha256',edge_receipt->'deployment_receipt_sha256','files',edge_files)ELSE b END ORDER BY ordinal)FROM jsonb_array_elements(root->'edge_bundles')WITH ORDINALITY a(b,ordinal)),false);
 db_stored:=root#>>'{db_core,sha256}';db_old_recomputed:=public.combat_v2_sha256((root->'db_core')-'sha256');
 IF db_stored IS DISTINCT FROM params#>>'{expected_current,db_sha256}' OR db_old_recomputed IS DISTINCT FROM db_stored
 OR root#>>'{config,sha256}'<>public.combat_v2_sha256((root->'config')-'sha256') THEN
  RAISE EXCEPTION 'CATALOGO_ROOT_HASH_RECONCILIATION_DRIFT';END IF;

SELECT jsonb_agg(jsonb_build_object('oid',p.oid::text,'signature',p.oid::regprocedure::text,'source_md5',md5(p.prosrc),'ddl_md5',md5(pg_get_functiondef(p.oid)),
 'owner',pg_get_userbyid(p.proowner),'acl',p.proacl::text,'config',p.proconfig,'secdef',p.prosecdef,'volatility',p.provolatile::text,
 'language',l.lanname,'strict',p.proisstrict,'parallel',p.proparallel::text,'kind',p.prokind::text,'returns',pg_get_function_result(p.oid),
 'arg_names',p.proargnames,'arg_modes',p.proargmodes,'arg_types',p.proargtypes::text,'leakproof',p.proleakproof,'nspname',n.nspname,'proname',p.proname)
 ORDER BY p.oid::regprocedure::text) INTO shared_manifest FROM pg_proc p JOIN pg_namespace n ON n.oid=p.pronamespace JOIN pg_language l ON l.oid=p.prolang
 WHERE p.prokind='f'AND p.oid IN('combat_consumer_private.narrative_context(uuid)'::regprocedure,'combat_consumer_private.narrative_declaration_supported(uuid)'::regprocedure,'combat_consumer_private.validate_narrative_result(jsonb)'::regprocedure,'combat_effects_private.lifecycle_before_report(uuid)'::regprocedure,'combat_effects_private.lifecycle_main_end(uuid)'::regprocedure,'combat_effects_private.lifecycle_open(uuid,uuid)'::regprocedure,'combat_effects_private.personal_turn_end(uuid,uuid,uuid,text)'::regprocedure,'combat_effects_private.personal_turn_start(uuid,uuid,uuid,text)'::regprocedure,'combat_panel_private.commit_master_actor(jsonb)'::regprocedure,'combat_panel_private.immobilization_actor_lifecycle()'::regprocedure,'combat_panel_private.immobilization_session_lifecycle()'::regprocedure,'combat_panel_private.master_options(uuid,uuid,bigint)'::regprocedure,'combat_panel_private.movement_block_reason(uuid)'::regprocedure,'combat_panel_private.narrative_declaration_facts(uuid)'::regprocedure,'combat_panel_private.narrative_ordinary_context(uuid)'::regprocedure,'combat_panel_private.narrative_outcome_facts(jsonb)'::regprocedure,'combat_panel_private.ordinary_options(uuid,uuid,bigint)'::regprocedure,'combat_panel_private.round_details_from_source(jsonb,jsonb,jsonb)'::regprocedure,'combat_panel_private.round_options_authoritative(uuid,uuid)'::regprocedure,'combat_v2_elemental_internal.other_consumer_options(jsonb)'::regprocedure,'combat_v2_elemental_internal.other_control_apply(text,uuid,uuid,uuid)'::regprocedure,'combat_v2_elemental_internal.other_control_target(text,uuid,uuid)'::regprocedure,'combat_v2_elemental_internal.other_master_options(uuid,bigint)'::regprocedure,'combat_v2_elemental_internal.other_prepare_native(uuid,uuid,uuid,jsonb,boolean,jsonb)'::regprocedure,'combat_v2_elemental_internal.other_profile(uuid,uuid)'::regprocedure,'combat_v2_multitarget_internal.resolve_parent(uuid,uuid,uuid,boolean)'::regprocedure,'public.combat_consumer_narrative_claim_v1(uuid,text,uuid)'::regprocedure,'public.combat_consumer_narrative_complete_v1(uuid,jsonb,uuid)'::regprocedure,'public.combat_panel_commit_v1(jsonb)'::regprocedure,'public.combat_v2_action_declare(uuid,uuid,jsonb,text,uuid)'::regprocedure,'public.combat_v2_actor_ability(uuid,text,uuid,boolean)'::regprocedure,'public.combat_v2_defense_declare(uuid,uuid,uuid,jsonb,text,uuid)'::regprocedure,'public.combat_v2_round_resolve(uuid,uuid)'::regprocedure,'public.post_heal(uuid,uuid)'::regprocedure);
SELECT coalesce(jsonb_agg(jsonb_build_object('signature',p.oid::regprocedure::text,'source_md5',md5(p.prosrc),'ddl_md5',md5(pg_get_functiondef(p.oid)),
 'owner',pg_get_userbyid(p.proowner),'acl',p.proacl::text,'config',p.proconfig,'secdef',p.prosecdef,'volatility',p.provolatile::text,'language',l.lanname,
 'strict',p.proisstrict,'parallel',p.proparallel::text,'returns',pg_get_function_result(p.oid),'arg_names',p.proargnames,'arg_modes',p.proargmodes,'arg_types',p.proargtypes::text)
 ORDER BY p.oid::regprocedure::text),'[]'::jsonb) INTO private_manifest FROM pg_proc p JOIN pg_namespace n ON n.oid=p.pronamespace JOIN pg_language l ON l.oid=p.prolang
 WHERE p.prokind='f'AND(n.nspname='combat_v2_genjutsu_internal'OR(n.nspname='combat_panel_private'AND(p.proname LIKE 'cure\_%'ESCAPE'\'OR p.proname IN('catalog_result_label_v1','catalog_lifecycle_lines_v1'))));
SELECT jsonb_agg(jsonb_build_object('signature',p.oid::regprocedure::text,'source_md5',md5(p.prosrc),'ddl_md5',md5(pg_get_functiondef(p.oid)),
 'owner',pg_get_userbyid(p.proowner),'acl',p.proacl::text,'config',p.proconfig,'secdef',p.prosecdef,'volatility',p.provolatile::text,
 'language',l.lanname,'strict',p.proisstrict,'parallel',p.proparallel::text,'returns',pg_get_function_result(p.oid),
 'arg_names',p.proargnames,'arg_modes',p.proargmodes,'arg_types',p.proargtypes::text)ORDER BY p.oid::regprocedure::text)
  INTO native_manifest FROM pg_proc p JOIN pg_language l ON l.oid=p.prolang WHERE p.prokind='f'AND p.oid IN('public.combat_v2_substitution_options_v1(uuid)'::regprocedure,'public.combat_v2_substitution_round_offers_v1(uuid,uuid)'::regprocedure,'public.combat_v2_substitution_select_v1(uuid,uuid)'::regprocedure);
SELECT jsonb_agg(jsonb_build_object('signature',p.oid::regprocedure::text,'source_md5',md5(p.prosrc),'ddl_md5',md5(pg_get_functiondef(p.oid)),
 'owner',pg_get_userbyid(p.proowner),'secdef',p.prosecdef,'config',p.proconfig,'acl',p.proacl::text,'volatility',p.provolatile::text)ORDER BY p.oid::regprocedure::text)
  INTO trigger_manifest FROM pg_proc p WHERE p.oid IN('combat_panel_private.round_options_authoritative(uuid,uuid)'::regprocedure,'public.combat_v2_substitution_options_v1(uuid)'::regprocedure,'public.combat_v2_substitution_round_offers_v1(uuid,uuid)'::regprocedure,'public.combat_v2_substitution_select_v1(uuid,uuid)'::regprocedure,'clan_innata_private.catalogo_eligibility_release_v1()'::regprocedure,'combat_panel_private.publish_master_declaration(uuid,text)'::regprocedure);
SELECT jsonb_agg(jsonb_build_object('oid',p.oid::text,'signature',p.oid::regprocedure::text,'source_md5',md5(p.prosrc),'ddl_md5',md5(pg_get_functiondef(p.oid)),
 'owner',pg_get_userbyid(p.proowner),'acl',p.proacl::text,'config',p.proconfig,'secdef',p.prosecdef,'volatility',p.provolatile::text,
 'language',l.lanname,'strict',p.proisstrict,'parallel',p.proparallel::text,'kind',p.prokind::text,'returns',pg_get_function_result(p.oid),
 'arg_names',p.proargnames,'arg_modes',p.proargmodes,'arg_types',p.proargtypes::text,'leakproof',p.proleakproof,'nspname',n.nspname,'proname',p.proname)
 ORDER BY p.oid::regprocedure::text) INTO changed_headers FROM pg_proc p JOIN pg_namespace n ON n.oid=p.pronamespace JOIN pg_language l ON l.oid=p.prolang
 WHERE p.prokind='f'AND p.oid IN('clan_aburame_private.actor_ability(uuid,text,uuid,boolean,jsonb)'::regprocedure,'clan_aburame_private.attack_power_source(uuid,uuid)'::regprocedure,'clan_aburame_private.commit_control(jsonb,jsonb,combat_consumer_private.activities,combat_consumer_private.offers,uuid)'::regprocedure,'clan_aburame_private.commit_master_stop(jsonb)'::regprocedure,'clan_aburame_private.consumer_options(jsonb)'::regprocedure,'clan_aburame_private.master_offers(uuid,bigint,jsonb)'::regprocedure,'clan_akimichi_private.apply_calorie_event(uuid,uuid,boolean,uuid,text,integer,integer,uuid,timestamp with time zone)'::regprocedure,'clan_akimichi_private.begin_personal_turn(uuid,uuid)'::regprocedure,'clan_akimichi_private.bind_partial(uuid)'::regprocedure,'clan_akimichi_private.end_form(uuid,uuid,text)'::regprocedure,'clan_akimichi_private.form_change_offer(uuid)'::regprocedure,'clan_akimichi_private.form_impact(uuid,uuid,uuid,text,text,text,jsonb)'::regprocedure,'clan_akimichi_private.movement_maximum(uuid,numeric)'::regprocedure,'clan_akimichi_private.partial_meta(uuid,jsonb)'::regprocedure,'clan_akimichi_private.set_form(uuid,uuid,boolean)'::regprocedure,'clan_sabaku_private.armor_absorb(uuid,integer)'::regprocedure,'clan_sabaku_private.armor_narrative_round(uuid)'::regprocedure,'clan_sabaku_private.armor_round_facts(uuid)'::regprocedure,'combat_consumer_private.after_publish(uuid,uuid)'::regprocedure,'combat_consumer_private.commit_exchange(jsonb,jsonb)'::regprocedure,'combat_consumer_private.narrative_context(uuid)'::regprocedure,'combat_consumer_private.narrative_declaration_supported(uuid)'::regprocedure,'combat_consumer_private.validate_narrative_result(jsonb)'::regprocedure,'combat_effects_private.lifecycle_actor_end(uuid)'::regprocedure,'combat_effects_private.lifecycle_open(uuid,uuid)'::regprocedure,'combat_effects_private.lifecycle_session_end(uuid)'::regprocedure,'combat_effects_private.personal_turn_end(uuid,uuid,uuid,text)'::regprocedure,'combat_panel_private.catalog_result_label_v1(jsonb)'::regprocedure,'combat_panel_private.consumer_commit_authoritative(jsonb)'::regprocedure,'combat_panel_private.master_admin_offers(uuid,bigint,jsonb)'::regprocedure,'combat_panel_private.master_options(uuid,uuid,bigint)'::regprocedure,'combat_panel_private.nara_shadow_level_v1(uuid)'::regprocedure,'combat_panel_private.narrative_declaration_facts(uuid)'::regprocedure,'combat_panel_private.narrative_ordinary_context(uuid)'::regprocedure,'combat_panel_private.ordinary_options(uuid,uuid,bigint)'::regprocedure,'combat_spatial.movement_commit(uuid,uuid,uuid)'::regprocedure,'combat_v2_genjutsu_internal.ally_contact(uuid,uuid)'::regprocedure,'combat_v2_genjutsu_internal.master_options(uuid,bigint)'::regprocedure,'combat_v2_genjutsu_internal.release_intents(uuid)'::regprocedure,'combat_v2_genjutsu_internal.release_meta(uuid,uuid,uuid,jsonb)'::regprocedure,'combat_v2_genjutsu_internal.resolve_release(uuid)'::regprocedure,'combat_v2_genjutsu_internal.scope(uuid)'::regprocedure,'combat_v2_multitarget_internal.resolve_parent(uuid,uuid,uuid,boolean)'::regprocedure,'mission_factory_owner.quest_combat_offer_source_guard_v1()'::regprocedure,'public._combat_calcola(text,jsonb,jsonb,text,text,integer,text,integer,integer,integer,integer,boolean)'::regprocedure,'public.combat_consumer_narrative_claim_v1(uuid,text,uuid)'::regprocedure,'public.combat_consumer_narrative_complete_v1(uuid,jsonb,uuid)'::regprocedure,'public.combat_panel_commit_v1(jsonb)'::regprocedure,'public.combat_v2_action_declare(uuid,uuid,jsonb,text,uuid)'::regprocedure,'public.combat_v2_actor_ability(uuid,text,uuid,boolean)'::regprocedure,'public.combat_v2_defense_declare(uuid,uuid,uuid,jsonb,text,uuid)'::regprocedure,'public.combat_v2_round_resolve(uuid,uuid)'::regprocedure,'public.master_v2_encounter_open_ninja_book_v1_human_ai_core(uuid,uuid[],jsonb,jsonb,uuid)'::regprocedure,'combat_panel_private.publish_master_declaration(uuid,text)'::regprocedure,'clan_innata_private.eligibility_release_assert()'::regprocedure,'clan_innata_private.catalogo_eligibility_release_v1()'::regprocedure);
SELECT jsonb_agg(jsonb_build_object('signature',p.oid::regprocedure::text,'source_md5',md5(p.prosrc),'ddl_md5',md5(pg_get_functiondef(p.oid)),
 'owner',pg_get_userbyid(p.proowner),'secdef',p.prosecdef,'config',p.proconfig,'acl',p.proacl::text,'volatility',p.provolatile::text)ORDER BY p.oid::regprocedure::text)
  INTO relation_manifest FROM pg_proc p WHERE p.oid IN('clan_innata_private.eligibility_release_assert()'::regprocedure,'clan_innata_private.catalogo_eligibility_release_v1()'::regprocedure);
 shared_sha:=public.combat_v2_sha256(shared_manifest);private_sha:=public.combat_v2_sha256(private_manifest);
 IF jsonb_array_length(shared_manifest)<>34 OR jsonb_array_length(private_manifest)<>66 OR jsonb_array_length(native_manifest)<>3
 OR jsonb_array_length(changed_headers)<>56 OR jsonb_array_length(relation_manifest)<>2 OR shared_sha<>'3702b953c74cf10baa983027cfc04d38013b9384cc01a516cf89deed84f671f9'OR private_sha<>'960a4eec86ad8890114b658f67bb46ce06bba486a3d90977d801165183e5cfde'
 OR public.combat_v2_sha256(native_manifest)<>'2d903f7977adb0086633ebe09f6e8b9994bdf2b17218a14ae3a2eac837b6581f'THEN RAISE EXCEPTION 'cure_reaction_post_manifest_drift';END IF;
 IF jsonb_array_length(trigger_manifest)<>6 OR public.combat_v2_sha256(trigger_manifest)<>'c914caac7ff68c721f3aa03f0551718b2986f4f93bb6016a1381ddfcf4ac9b70'THEN RAISE EXCEPTION 'palmo_completion_peer6_drift';END IF;
 -- Update every existing touched-OID alias; ABI remains byte-exact.
 WHILE coalesce(cardinality(pending_paths),0)>0 LOOP
  stack_size:=cardinality(pending_paths);SELECT ARRAY(SELECT jsonb_array_elements_text(pending_paths[stack_size]::jsonb))INTO current_path;
  pending_paths:=pending_paths[1:stack_size-1];descriptor:=root#>current_path;
  IF jsonb_typeof(descriptor)='object'THEN
   SELECT value INTO h FROM jsonb_array_elements(changed_headers)WHERE value->>'oid'=descriptor->>'oid';
   IF descriptor?'oid'AND h IS NOT NULL THEN
    FOR kv IN SELECT key,value FROM jsonb_each(descriptor)WHERE key=ANY(ARRAY['owner','acl','config','secdef','strict','language','parallel','arg_modes','arg_names','arg_types','leakproof','returns','volatility','kind','signature','nspname','proname'])LOOP
     IF kv.value IS DISTINCT FROM h->kv.key THEN RAISE EXCEPTION 'cure_reaction_alias_abi';END IF;
    END LOOP;
    next_descriptor:=descriptor;
    IF descriptor?'source_md5'THEN next_descriptor:=jsonb_set(next_descriptor,'{source_md5}',h->'source_md5',false);END IF;
    IF descriptor?'ddl_md5'THEN next_descriptor:=jsonb_set(next_descriptor,'{ddl_md5}',h->'ddl_md5',false);END IF;
    root:=jsonb_set(root,current_path,next_descriptor,false);aliases:=aliases+1;
   ELSE
    FOR kv IN SELECT key,value FROM jsonb_each(descriptor)WHERE jsonb_typeof(value)IN('object','array')LOOP pending_paths:=array_append(pending_paths,to_jsonb(array_append(current_path,kv.key))::text);END LOOP;
   END IF;
  ELSIF jsonb_typeof(descriptor)='array'THEN
   FOR kv IN SELECT(ord-1)::text AS key,value FROM jsonb_array_elements(descriptor)WITH ORDINALITY x(value,ord)WHERE jsonb_typeof(value)IN('object','array')LOOP pending_paths:=array_append(pending_paths,to_jsonb(array_append(current_path,kv.key))::text);END LOOP;
  END IF;
 END LOOP;
 IF aliases<>7 THEN RAISE EXCEPTION 'staff_entry_repairs_alias_count';END IF;
 binding:=$joint_amendment${"state":"active_amendment","review":{"P0":0,"P1":0,"P2":0,"ref":"PARALISI_LABEL_INTEGRATED_REVIEW.json#R1","sha256":"9e3c2322a9213e8a3d4de359af3cc3a19890bb0f9becc6df6e91858c332e6758"},"parent_root":"df85a212a00f218f6ba8435a267b012d382584bd9e23afbe0abb21f911f2d53b","availability":{"cure_staff_enabled":true,"cure_public_enabled":false,"paralisi_staff_enabled":true,"paralisi_public_enabled":false},"schema_version":"cure-command-amendment/1","commit_source_md5":"61532836e90ed32ae807b92ee6632b71","helper_source_md5":"ad51c1f5795748a6edb6c4ffce5f7760","active_repair_kind":"paralisi-label-dispatch/1","neutral_source_md5":"0f48477bfc086b98e113e2dd70bba0de","source_bundle_sha256":"7d33185066673f2cf833a14c7e9e42dfd95b39eb5b1520c520ad403a53d9411d","shared_manifest_sha256":"3702b953c74cf10baa983027cfc04d38013b9384cc01a516cf89deed84f671f9","functions_manifest_sha256":"c914caac7ff68c721f3aa03f0551718b2986f4f93bb6016a1381ddfcf4ac9b70","normalized_source_identity":{"qa_state":"FOUR_FAMILIES_NOT_RUN","staff_pass":false,"parent_root":"df85a212a00f218f6ba8435a267b012d382584bd9e23afbe0abb21f911f2d53b","public_enabled":false,"schema_version":"catalogo-joint-family/1","publisher_source_md5":"c5b951689347cfd4f36ac097a601994a","shared_manifest_sha256":"3702b953c74cf10baa983027cfc04d38013b9384cc01a516cf89deed84f671f9","paralisi_label_source_sha256":"0705927fad1de34d8422b68fb4eda5c96fc7b000a77367a3a8ec0e9d15cfa02f","previous_source_bundle_sha256":"7d33185066673f2cf833a14c7e9e42dfd95b39eb5b1520c520ad403a53d9411d","native_functions_manifest_sha256":"2d903f7977adb0086633ebe09f6e8b9994bdf2b17218a14ae3a2eac837b6581f","private_functions_manifest_sha256":"960a4eec86ad8890114b658f67bb46ce06bba486a3d90977d801165183e5cfde","previous_amendment_identity_sha256":"d546d804f62d30f01e50c12cffb2a4472dfc52e12f1e38e8a8e96e1e9af5ff62"},"base_compat_source_bundle_sha256":"654f8fff2f42019ffc4b3ccc6c467fff443ba81f00c7aa020fbd6d7950e2445e","native_functions_manifest_sha256":"2d903f7977adb0086633ebe09f6e8b9994bdf2b17218a14ae3a2eac837b6581f","normalized_source_identity_sha256":"fd23ca0e8178bfa52a6b6253f846f82d19578f87c465dfc0fabd2624d8c72960","private_functions_manifest_sha256":"960a4eec86ad8890114b658f67bb46ce06bba486a3d90977d801165183e5cfde","base_catalogo_source_bundle_sha256":"825a1c14a59281fb3168430a993e9f2dbbbc41042f5169638d2e9c1e8e9868a5","base_private_functions_manifest_sha256":"3eb9bba89fc99206710cd079207631f4949dec9893a38d97d7d46e07386b5cc0","previous_cure_command_source_bundle_sha256":"680f9d1d43250a7a62ad29537a6d0b2ac13abfdc06f510372c669794b15a403d"}$joint_amendment$::jsonb;
 binding:=binding||jsonb_build_object('state','active_amendment','source_bundle_sha256',params->'source_bundle_sha256','review',review,
   'availability',(SELECT jsonb_build_object('cure_staff_enabled',c.staff_enabled,'cure_public_enabled',c.public_enabled,
    'paralisi_staff_enabled',g.staff_enabled,'paralisi_public_enabled',g.public_enabled)
    FROM combat_panel_private.cure_gate_v1 c CROSS JOIN combat_v2_genjutsu_internal.gate g WHERE c.singleton AND g.singleton));
 root:=jsonb_set(root,'{db_core,cure_command_amendment}',binding,false);root:=jsonb_set(root,'{config,cure_command_amendment}',binding,false);
 cfg:=root#>'{db_core,catalogo_eligibility_compat}';
 cfg:=cfg||jsonb_build_object('shared_manifest_sha256',shared_sha,'private_functions_manifest_sha256',private_sha,'helper_source_md5','ad51c1f5795748a6edb6c4ffce5f7760','guard_source_md5','78dd10959830241cf446b1cd738dbd2d',
  'active_amendment_source_bundle_sha256',binding->'source_bundle_sha256','functions',relation_manifest,'functions_manifest_sha256',public.combat_v2_sha256(relation_manifest));
 root:=jsonb_set(root,'{db_core,catalogo_eligibility_compat}',cfg,false);root:=jsonb_set(root,'{config,catalogo_eligibility_compat}',cfg,false);
 descriptor:=jsonb_build_object('schema_version','paralisi-label/1','leaf_sha256','0705927fad1de34d8422b68fb4eda5c96fc7b000a77367a3a8ec0e9d15cfa02f',
  'source_bundle_sha256',params->'source_bundle_sha256','state','active','review',review);
 root:=jsonb_set(root,'{db_core,paralisi_label}',descriptor,true);
 root:=jsonb_set(root,'{config,paralisi_label}',descriptor,true);
 descriptor:=jsonb_build_array(1,params->'source_bundle_sha256',(SELECT jsonb_build_array(public.combat_v2_sha256((SELECT coalesce(jsonb_agg(jsonb_build_object('signature',n.nspname||'.'||p.proname||'('||oidvectortypes(p.proargtypes)||')','source_md5',md5(p.prosrc),'ddl_md5',md5(pg_get_functiondef(p.oid)),'owner',pg_get_userbyid(p.proowner),'acl',p.proacl::text,'config',p.proconfig,'secdef',p.prosecdef,'strict',p.proisstrict,'parallel',p.proparallel::text,'volatility',p.provolatile::text,'returns',pg_get_function_result(p.oid),'language',l.lanname)ORDER BY n.nspname,p.proname,oidvectortypes(p.proargtypes)),'[]'::jsonb)FROM pg_proc p JOIN pg_namespace n ON n.oid=p.pronamespace JOIN pg_language l ON l.oid=p.prolang WHERE p.oid IN(to_regprocedure('combat_v2_staff_nb_internal.origin_guard()'),to_regprocedure('combat_v2_staff_nb_internal.preparation_allowed(uuid)'),to_regprocedure('combat_v2_staff_nb_internal.choice(uuid)'),to_regprocedure('combat_v2_staff_nb_internal.roster_offers(uuid,bigint,uuid)'),to_regprocedure('combat_v2_staff_nb_internal.native_construct(uuid,uuid[],jsonb,jsonb,uuid,uuid)'),to_regprocedure('combat_v2_staff_nb_internal.mechanics_ready(uuid)'),to_regprocedure('combat_v2_staff_nb_internal.setup_protected(uuid,uuid)'),to_regprocedure('combat_v2_staff_nb_internal.commit_roster(jsonb)'),to_regprocedure('combat_v2_staff_nb_internal.roster_receipt(uuid)'),to_regprocedure('combat_v2_staff_nb_internal.pg_scope(uuid)'),to_regprocedure('combat_v2_staff_nb_internal.kai_frozen_authority(uuid)'),to_regprocedure('combat_v2_staff_nb_internal.kai_authority(uuid)'),to_regprocedure('combat_v2_staff_nb_internal.kai_contact(uuid,uuid)'),to_regprocedure('clan_aburame_private.verme_manifest_v1()'),to_regprocedure('clan_aburame_private.verme_release_v1()'),to_regprocedure('clan_aburame_private.verme_staff_scope_v1(uuid)'),to_regprocedure('clan_aburame_private.verme_scope_v1(uuid)'),to_regprocedure('clan_aburame_private.verme_event_v1(text,uuid,uuid,uuid,uuid,uuid,text,jsonb)'),to_regprocedure('clan_aburame_private.verme_staff_prepare_v1(uuid,uuid)'),to_regprocedure('clan_aburame_private.verme_meta_v1(uuid,boolean)'),to_regprocedure('clan_aburame_private.verme_bind_v1(uuid)'),to_regprocedure('clan_aburame_private.verme_frozen_v1(uuid)'),to_regprocedure('clan_aburame_private.verme_finish_v1(uuid,uuid,boolean,integer)'),to_regprocedure('clan_aburame_private.verme_tick_v1(uuid,uuid,uuid,text)'),to_regprocedure('clan_aburame_private.verme_end_context_v1()'),to_regprocedure('clan_aburame_private.verme_report_v1(uuid,uuid)'),to_regprocedure('clan_aburame_private.verme_reserve_round_v1(uuid)'),to_regprocedure('clan_aburame_private.verme_settle_round_v1(uuid)'),to_regprocedure('clan_aburame_private.verme_narrative_v1(uuid,uuid)'),to_regprocedure('clan_akimichi_private.common_staff_scope_v1(uuid)'),to_regprocedure('clan_akimichi_private.common_scope_v1(uuid,uuid)'),to_regprocedure('clan_akimichi_private.common_prepare_staff_v1(uuid,uuid,uuid)'),to_regprocedure('clan_akimichi_private.common_modifiers_v1(text,integer,integer,integer)'),to_regprocedure('clan_akimichi_private.common_set_form_v1(uuid,uuid,text)'),to_regprocedure('clan_akimichi_private.common_defer_upkeep_v1(uuid,uuid)'),to_regprocedure('clan_akimichi_private.common_flush_upkeep_v1(uuid)'),to_regprocedure('clan_akimichi_private.cellular_meta_v1(uuid)'),to_regprocedure('clan_akimichi_private.cellular_attack_eligible_v1(uuid,uuid)'),to_regprocedure('clan_akimichi_private.cellular_bind_v1(uuid)'),to_regprocedure('clan_akimichi_private.cellular_source_valid_v1(uuid)'),to_regprocedure('clan_akimichi_private.cellular_pay_v1(uuid)'),to_regprocedure('clan_akimichi_private.cellular_snapshot_v1(uuid,jsonb)'),to_regprocedure('clan_akimichi_private.cellular_mark_v1(uuid,jsonb)'),to_regprocedure('clan_akimichi_private.cellular_calculate_v1(uuid,jsonb,integer,integer)'),to_regprocedure('clan_akimichi_private.common_calorie_balance_v1(uuid,uuid,uuid,uuid)'),to_regprocedure('clan_akimichi_private.common_admit_calories_v1(uuid)'),to_regprocedure('clan_akimichi_private.common_preflight_calories_v1(uuid)'),to_regprocedure('clan_akimichi_private.super_direct_visible_v1(uuid,uuid)'),to_regprocedure('clan_akimichi_private.common_attack_power_freeze_v1(uuid)'),to_regprocedure('clan_akimichi_private.common_panel_offers_v1(uuid,bigint,jsonb)'),to_regprocedure('clan_akimichi_private.common_panel_commit_v1(jsonb)'),to_regprocedure('clan_akimichi_private.common_result_label_v1(jsonb)'),to_regprocedure('clan_akimichi_private.common_source_root_v1()'),to_regprocedure('clan_sabaku_private.armor_absorb_packet_v1(uuid,uuid,uuid,uuid,integer)'),to_regprocedure('combat_panel_private.nara_adv_pool_v1(uuid)'),to_regprocedure('combat_panel_private.nara_adv_protected_v1(uuid)'),to_regprocedure('combat_panel_private.nara_adv_scope_v1(uuid)'),to_regprocedure('combat_panel_private.nara_adv_prepare_v1(uuid,uuid)'),to_regprocedure('combat_panel_private.nara_strangle_meta_v1(uuid)'),to_regprocedure('combat_panel_private.nara_strangle_action_meta_v1(uuid,uuid,jsonb)'),to_regprocedure('combat_panel_private.nara_strangle_bind_v1(uuid)'),to_regprocedure('combat_panel_private.nara_strangle_parent_valid_v1(uuid)'),to_regprocedure('combat_panel_private.nara_strangle_lifecycle_v1(uuid)'),to_regprocedure('combat_panel_private.nara_strangle_packet_v1(uuid,uuid,uuid,text)'),to_regprocedure('combat_panel_private.nara_strangle_resolve_v1(uuid)'),to_regprocedure('combat_panel_private.nara_strangle_turn_v1(uuid,uuid,uuid,text)'),to_regprocedure('combat_panel_private.nara_strangle_facts_revision_v1(jsonb)'),to_regprocedure('combat_panel_private.nara_strangle_facts_v1(uuid,uuid)'),to_regprocedure('combat_panel_private.nara_adv_history_guard_v1()'),to_regprocedure('combat_panel_private.nara_strangle_end_event_v1()'),to_regprocedure('combat_panel_private.nara_strangle_terminal_report_v1(uuid)'),to_regprocedure('combat_panel_private.nara_strangle_lifecycle_context_v1(uuid)'),to_regprocedure('combat_panel_private.nara_adv_offers_v1(uuid,bigint,jsonb)'),to_regprocedure('combat_panel_private.nara_adv_commit_v1(jsonb)'),to_regprocedure('combat_panel_private.nara_strangle_lifecycle_trigger_v1()')))),public.combat_v2_sha256((SELECT coalesce(jsonb_agg(jsonb_build_object('signature',n.nspname||'.'||p.proname||'('||oidvectortypes(p.proargtypes)||')','source_md5',md5(p.prosrc),'ddl_md5',md5(pg_get_functiondef(p.oid)),'owner',pg_get_userbyid(p.proowner),'acl',p.proacl::text,'config',p.proconfig,'secdef',p.prosecdef,'strict',p.proisstrict,'parallel',p.proparallel::text,'volatility',p.provolatile::text,'returns',pg_get_function_result(p.oid),'language',l.lanname)ORDER BY n.nspname,p.proname,oidvectortypes(p.proargtypes)),'[]'::jsonb)FROM pg_proc p JOIN pg_namespace n ON n.oid=p.pronamespace JOIN pg_language l ON l.oid=p.prolang WHERE p.oid IN(to_regprocedure('clan_aburame_private.actor_ability(uuid,text,uuid,boolean,jsonb)'),to_regprocedure('clan_aburame_private.attack_power_source(uuid,uuid)'),to_regprocedure('clan_aburame_private.commit_control(jsonb,jsonb,combat_consumer_private.activities,combat_consumer_private.offers,uuid)'),to_regprocedure('clan_aburame_private.commit_master_stop(jsonb)'),to_regprocedure('clan_aburame_private.consumer_options(jsonb)'),to_regprocedure('clan_aburame_private.master_offers(uuid,bigint,jsonb)'),to_regprocedure('clan_akimichi_private.apply_calorie_event(uuid,uuid,boolean,uuid,text,integer,integer,uuid,timestamp with time zone)'),to_regprocedure('clan_akimichi_private.begin_personal_turn(uuid,uuid)'),to_regprocedure('clan_akimichi_private.bind_partial(uuid)'),to_regprocedure('clan_akimichi_private.end_form(uuid,uuid,text)'),to_regprocedure('clan_akimichi_private.form_change_offer(uuid)'),to_regprocedure('clan_akimichi_private.form_impact(uuid,uuid,uuid,text,text,text,jsonb)'),to_regprocedure('clan_akimichi_private.movement_maximum(uuid,numeric)'),to_regprocedure('clan_akimichi_private.partial_meta(uuid,jsonb)'),to_regprocedure('clan_akimichi_private.set_form(uuid,uuid,boolean)'),to_regprocedure('clan_sabaku_private.armor_absorb(uuid,integer)'),to_regprocedure('clan_sabaku_private.armor_narrative_round(uuid)'),to_regprocedure('clan_sabaku_private.armor_round_facts(uuid)'),to_regprocedure('combat_consumer_private.after_publish(uuid,uuid)'),to_regprocedure('combat_consumer_private.commit_exchange(jsonb,jsonb)'),to_regprocedure('combat_consumer_private.narrative_context(uuid)'),to_regprocedure('combat_consumer_private.narrative_declaration_supported(uuid)'),to_regprocedure('combat_consumer_private.validate_narrative_result(jsonb)'),to_regprocedure('combat_effects_private.lifecycle_actor_end(uuid)'),to_regprocedure('combat_effects_private.lifecycle_open(uuid,uuid)'),to_regprocedure('combat_effects_private.lifecycle_session_end(uuid)'),to_regprocedure('combat_effects_private.personal_turn_end(uuid,uuid,uuid,text)'),to_regprocedure('combat_panel_private.catalog_result_label_v1(jsonb)'),to_regprocedure('combat_panel_private.consumer_commit_authoritative(jsonb)'),to_regprocedure('combat_panel_private.master_admin_offers(uuid,bigint,jsonb)'),to_regprocedure('combat_panel_private.master_options(uuid,uuid,bigint)'),to_regprocedure('combat_panel_private.nara_shadow_level_v1(uuid)'),to_regprocedure('combat_panel_private.narrative_declaration_facts(uuid)'),to_regprocedure('combat_panel_private.narrative_ordinary_context(uuid)'),to_regprocedure('combat_panel_private.ordinary_options(uuid,uuid,bigint)'),to_regprocedure('combat_spatial.movement_commit(uuid,uuid,uuid)'),to_regprocedure('combat_v2_genjutsu_internal.ally_contact(uuid,uuid)'),to_regprocedure('combat_v2_genjutsu_internal.master_options(uuid,bigint)'),to_regprocedure('combat_v2_genjutsu_internal.release_intents(uuid)'),to_regprocedure('combat_v2_genjutsu_internal.release_meta(uuid,uuid,uuid,jsonb)'),to_regprocedure('combat_v2_genjutsu_internal.resolve_release(uuid)'),to_regprocedure('combat_v2_genjutsu_internal.scope(uuid)'),to_regprocedure('combat_v2_multitarget_internal.resolve_parent(uuid,uuid,uuid,boolean)'),to_regprocedure('mission_factory_owner.quest_combat_offer_source_guard_v1()'),to_regprocedure('public._combat_calcola(text,jsonb,jsonb,text,text,integer,text,integer,integer,integer,integer,boolean)'),to_regprocedure('public.combat_consumer_narrative_claim_v1(uuid,text,uuid)'),to_regprocedure('public.combat_consumer_narrative_complete_v1(uuid,jsonb,uuid)'),to_regprocedure('public.combat_panel_commit_v1(jsonb)'),to_regprocedure('public.combat_v2_action_declare(uuid,uuid,jsonb,text,uuid)'),to_regprocedure('public.combat_v2_actor_ability(uuid,text,uuid,boolean)'),to_regprocedure('public.combat_v2_defense_declare(uuid,uuid,uuid,jsonb,text,uuid)'),to_regprocedure('public.combat_v2_round_resolve(uuid,uuid)'),to_regprocedure('public.master_v2_encounter_open_ninja_book_v1_human_ai_core(uuid,uuid[],jsonb,jsonb,uuid)'),to_regprocedure('combat_panel_private.publish_master_declaration(uuid,text)'),to_regprocedure('clan_innata_private.eligibility_release_assert()')))),public.combat_v2_sha256((SELECT jsonb_build_object('tables',(SELECT jsonb_agg(jsonb_build_object('schema',n.nspname,'name',c.relname,'owner',pg_get_userbyid(c.relowner),'acl',c.relacl::text,'rls',c.relrowsecurity,'force_rls',c.relforcerowsecurity,'columns',(SELECT jsonb_agg(jsonb_build_object('name',a.attname,'type',format_type(a.atttypid,a.atttypmod),'notnull',a.attnotnull,'default',pg_get_expr(d.adbin,d.adrelid),'identity',a.attidentity,'generated',a.attgenerated)ORDER BY a.attnum)FROM pg_attribute a LEFT JOIN pg_attrdef d ON d.adrelid=a.attrelid AND d.adnum=a.attnum WHERE a.attrelid=c.oid AND a.attnum>0 AND NOT a.attisdropped),'constraints',(SELECT coalesce(jsonb_agg(jsonb_build_object('name',q.conname,'definition',pg_get_constraintdef(q.oid),'validated',q.convalidated,'deferrable',q.condeferrable,'deferred',q.condeferred)ORDER BY q.conname),'[]'::jsonb)FROM pg_constraint q WHERE q.conrelid=c.oid),'indexes',(SELECT coalesce(jsonb_agg(jsonb_build_object('name',ci.relname,'definition',pg_get_indexdef(i.indexrelid),'valid',i.indisvalid,'ready',i.indisready,'live',i.indislive)ORDER BY ci.relname),'[]'::jsonb)FROM pg_index i JOIN pg_class ci ON ci.oid=i.indexrelid WHERE i.indrelid=c.oid),'triggers',(SELECT coalesce(jsonb_agg(pg_get_triggerdef(t.oid)ORDER BY t.tgname),'[]'::jsonb)FROM pg_trigger t WHERE t.tgrelid=c.oid AND NOT t.tgisinternal),'policies',(SELECT coalesce(jsonb_agg(jsonb_build_object('name',p.polname,'cmd',p.polcmd,'roles',p.polroles,'using',pg_get_expr(p.polqual,p.polrelid),'check',pg_get_expr(p.polwithcheck,p.polrelid))ORDER BY p.polname),'[]'::jsonb)FROM pg_policy p WHERE p.polrelid=c.oid))ORDER BY n.nspname,c.relname)FROM pg_class c JOIN pg_namespace n ON n.oid=c.relnamespace WHERE c.oid IN(to_regclass('combat_v2_staff_nb_internal.gate'),to_regclass('combat_v2_staff_nb_internal.roster_sources'),to_regclass('combat_v2_staff_nb_internal.admissions'),to_regclass('clan_aburame_private.verme_gate_v1'),to_regclass('clan_aburame_private.verme_staff_profiles_v1'),to_regclass('clan_aburame_private.verme_sources_v1'),to_regclass('clan_aburame_private.verme_poison_v1'),to_regclass('clan_aburame_private.verme_events_v1'),to_regclass('clan_akimichi_private.common_gate_v1'),to_regclass('clan_akimichi_private.common_staff_profiles_v1'),to_regclass('clan_akimichi_private.common_form_commands_v1'),to_regclass('clan_akimichi_private.common_attack_powers_v1'),to_regclass('clan_akimichi_private.common_pending_upkeep_v1'),to_regclass('clan_akimichi_private.cellular_sources_v1'),to_regclass('combat_panel_private.nara_adv_gate_v1'),to_regclass('combat_panel_private.nara_adv_staff_v1'),to_regclass('combat_panel_private.nara_strangle_sources_v1'),to_regclass('combat_panel_private.nara_strangle_events_v1'),to_regclass('public.master_v2_nb_actor_offers_v1'),to_regclass('clan_akimichi_private.forms'))),'catalog',(SELECT jsonb_agg(jsonb_build_object('id',t.id,'sha256',public.combat_v2_sha256(to_jsonb(t)))ORDER BY t.id)FROM public.clan_techniques t WHERE id IN('0a15282f-d6b5-4ee3-ad52-7fac2525444d','f5f26cb5-9b6f-44b3-94bc-c329a0a88b93','687b058a-807d-4cf7-8bcf-21147931b0f6')),'NBtuples',(SELECT jsonb_build_object('mechanical',(SELECT jsonb_agg(jsonb_build_object('id',v.id,'template_id',v.template_id,'content_sha256',v.content_sha256)ORDER BY v.id)FROM public.nb_mechanical_versions v WHERE v.id IN('31da0000-0000-4000-8000-000000000111','31da0000-0000-4000-8000-000000000112')),'narrative',(SELECT jsonb_agg(jsonb_build_object('id',v.id,'template_id',v.template_id,'content_sha256',v.content_sha256)ORDER BY v.id)FROM public.nb_template_versions v WHERE v.id IN('31da0000-0000-4000-8000-000000000211','31da0000-0000-4000-8000-000000000212')))),'new_triggers',(SELECT jsonb_agg(jsonb_build_object('table',e->>'table','name',t.tgname,'function',t.tgfoid::regprocedure::text,'enabled',t.tgenabled::text,'type',t.tgtype,'definition',pg_get_triggerdef(t.oid),'args_sha256',encode(extensions.digest(t.tgargs,'sha256'),'hex'))ORDER BY e->>'table',e->>'name')FROM jsonb_array_elements($joint_triggers$[{"table":"combat_v2_staff_nb_internal.roster_sources","name":"staff_nb_origin_immutable"},{"table":"public.combat_v2_sessions","name":"aburame_verme_end_session_v1"},{"table":"public.combat_v2_actors","name":"aburame_verme_end_actor_v1"},{"table":"combat_panel_private.nara_strangle_sources_v1","name":"nara_strangle_snapshot_guard_v1"},{"table":"combat_panel_private.nara_strangle_events_v1","name":"nara_strangle_events_guard_v1"},{"table":"combat_panel_private.nara_adv_staff_v1","name":"nara_strangle_staff_guard_v1"},{"table":"combat_panel_private.nara_strangle_sources_v1","name":"nara_strangle_ended_event_v1"},{"table":"combat_panel_private.immobilizations","name":"nara_strangle_parent_end_v1"},{"table":"combat_spatial.actor_states","name":"nara_strangle_geometry_end_v1"}]$joint_triggers$::jsonb)e JOIN pg_trigger t ON t.tgrelid=to_regclass(e->>'table')AND t.tgname=e->>'name'AND NOT t.tgisinternal),'NBnamespace',(SELECT jsonb_build_object('owner',pg_get_userbyid(nspowner),'acl',nspacl::text)FROM pg_namespace WHERE nspname='combat_v2_staff_nb_internal')))))),'7c261e6fee5b1f608bb8bf4caccbf28e7f409eadd9e866165bbf65f27b9d411a',CASE WHEN params->>'mode'='source'THEN '[1,1,1,1]'::jsonb ELSE '[0,0,0,0]'::jsonb END);
 root:=jsonb_set(root,'{db_core,catalogo_families}',descriptor,true);
 root:=jsonb_set(root,'{config,catalogo_families}',to_jsonb(public.combat_v2_sha256(descriptor)),true);
 core:=root->'db_core';db_sha:=public.combat_v2_sha256(core-'sha256');core:=jsonb_set(core,'{sha256}',to_jsonb(db_sha),false);root:=jsonb_set(root,'{db_core}',core,false);
 cfg:=root->'config';config_sha:=public.combat_v2_sha256(cfg-'sha256');cfg:=jsonb_set(cfg,'{sha256}',to_jsonb(config_sha),false);root:=jsonb_set(root,'{config}',cfg,false);
 expected_ui:=before_root->'ui';
 IF public.combat_v2_sha256(expected_ui)IS DISTINCT FROM 'cd76714cb188ea3f69189ac5dd793304acdc2179da724aad852f961d12ab3014' THEN RAISE EXCEPTION 'cure_entry_recovery_ui_drift';END IF;
 identity:=jsonb_build_object('schema_version','joint-catalog-code-identity/1','parent_root',old_root_sha,'parent_code_identity',before_root#>'{contract,code_identity_sha256}',
  'normalized_amendment_identity_sha256',binding->'normalized_source_identity_sha256','active_shared_manifest_sha256',shared_sha,
  'active_private_functions_manifest_sha256',private_sha,'native_functions_manifest_sha256',binding->'native_functions_manifest_sha256',
  'source_bundle_sha256',params->'source_bundle_sha256','db_sha256',db_sha,'client_sha256',public.combat_v2_sha256(root->'ui'),'ui_graph_sha256',root#>>'{ui,import_graph_sha256}','amendment_state',binding->'state');
 identity_sha:=public.combat_v2_sha256(identity);root:=jsonb_set(root,'{contract,code_identity_sha256}',to_jsonb(identity_sha),false);
 root:=jsonb_set(root,'{recovery,semantic_identity_sha256}',to_jsonb(identity_sha),false);
 root:=jsonb_set(root,'{recovery,cure_command_amendment}',jsonb_build_object('parent_root',old_root_sha,'state',binding->'state',
  'previous_semantic_identity',before_root#>'{recovery,semantic_identity_sha256}','policy','forward_catalog_gates_off_keep_code_history'),false);
 IF root->'ui'IS DISTINCT FROM expected_ui OR(SELECT jsonb_agg(b ORDER BY ordinal)FROM jsonb_array_elements(root->'edge_bundles')WITH ORDINALITY a(b,ordinal)WHERE b->>'name'<>'combat_narratore_ai')IS DISTINCT FROM(SELECT jsonb_agg(b ORDER BY ordinal)FROM jsonb_array_elements(before_root->'edge_bundles')WITH ORDINALITY a(b,ordinal)WHERE b->>'name'<>'combat_narratore_ai')
 OR(root->'config')-ARRAY['sha256','cure_command_amendment','catalogo_eligibility_compat','paralisi_label','catalogo_families']IS DISTINCT FROM(before_root->'config')-ARRAY['sha256','cure_command_amendment','catalogo_eligibility_compat','paralisi_label','catalogo_families']
 OR root#>'{db_core,catalogo_completo}'IS DISTINCT FROM before_root#>'{db_core,catalogo_completo}'THEN RAISE EXCEPTION 'cure_reaction_unrelated_config_changed';END IF;
 -- Lexer UTF8 a byte, memoria limitata: non usa token SQL, sort o aggregati.
 -- Si scarta soltanto whitespace JSON ASCII esterno alle stringhe.
 -- Gli escape e ogni byte interno alle stringhe restano identici; niente NFC.
 raw_bytes:=convert_to(root::text,'UTF8');
 IF octet_length(raw_bytes)>1048576 THEN RAISE EXCEPTION 'CATALOGO_ROOT_SERIALIZATION_INPUT_CAP';END IF;
 FOR byte_index IN 0..octet_length(raw_bytes)-1 LOOP
  byte_value:=get_byte(raw_bytes,byte_index);
  IF inside_string THEN
   IF escaped THEN escaped:=false;
   ELSIF byte_value=92 THEN escaped:=true;
   ELSIF byte_value=34 THEN inside_string:=false;END IF;
  ELSE
   IF byte_value=34 THEN inside_string:=true;
   ELSIF byte_value IN(9,10,13,32) THEN CONTINUE;END IF;
  END IF;
  byte_chunk:=byte_chunk||substring(raw_bytes FROM byte_index+1 FOR 1);
  IF octet_length(byte_chunk)>=4096 THEN
   byte_chunks:=array_append(byte_chunks,byte_chunk);byte_chunk:=''::bytea;
  END IF;
 END LOOP;
 IF inside_string OR escaped THEN RAISE EXCEPTION 'CATALOGO_ROOT_SERIALIZATION_STRING_STATE';END IF;
 IF octet_length(byte_chunk)>0 THEN byte_chunks:=array_append(byte_chunks,byte_chunk);END IF;
 FOREACH byte_chunk IN ARRAY byte_chunks LOOP compact_bytes:=compact_bytes||byte_chunk;END LOOP;
 root_text:=convert_from(compact_bytes,'UTF8');
 IF root_text IS NULL OR root_text::jsonb IS DISTINCT FROM root THEN RAISE EXCEPTION 'CATALOGO_ROOT_COMPACT_SERIALIZATION';END IF;
 IF octet_length(root_text)>524288 THEN RAISE EXCEPTION 'CATALOGO_ROOT_BYTES_CAP:%',octet_length(root_text);END IF;
 new_root_sha:=encode(extensions.digest(convert_to(root_text,'UTF8'),'sha256'),'hex');

 -- Baseline missione validata prima del passaggio; niente nuove capability.
 IF mission_public_owner.engine_qualification_v1(old_root_sha,true)IS NULL THEN RAISE EXCEPTION 'CATALOGO_ROOT_PREVIOUS_MISSION_UNQUALIFIED';END IF;
 SELECT * INTO STRICT prior_release FROM mission_public_owner.release_admissions_v1 WHERE release_sha256=old_root_sha FOR SHARE;
 SELECT * INTO STRICT prior_qualification FROM mission_public_owner.public_qualification_attestations_v1 WHERE release_sha256=old_root_sha FOR SHARE;
 IF(SELECT count(*)FROM mission_public_owner.mission_content_admissions_v1 WHERE engine_release_sha256=old_root_sha)<>2
 OR(SELECT public.combat_v2_sha256(jsonb_agg(to_jsonb(c)ORDER BY c.mission_id,c.request_key))FROM mission_public_owner.mission_content_admissions_v1 c WHERE engine_release_sha256=old_root_sha)
 IS DISTINCT FROM params->>'expected_content_admission_rows_sha256'
 THEN RAISE EXCEPTION 'FIX_ELIGIBILITY_CONTENT_BASELINE';END IF;
 FOR content_row IN SELECT * FROM mission_public_owner.mission_content_admissions_v1 WHERE engine_release_sha256=old_root_sha FOR SHARE LOOP
  IF mission_public_owner.content_admission_v1(content_row.mission_id,old_root_sha,content_row.publication_request,true)IS NULL THEN
   RAISE EXCEPTION 'CATALOGO_ROOT_PREVIOUS_CONTENT_UNQUALIFIED';END IF;
 END LOOP;
 bindings:=jsonb_build_object('db_sha256',db_sha,'edge_sha256',generic_ezbr,'client_sha256',public.combat_v2_sha256(root->'ui'),'configuration_sha256',config_sha);
 UPDATE mission_factory_owner.editor_release_readiness SET canonical_preimage=root_text,revision_sha256=new_root_sha,
  observed_revision_sha256=new_root_sha,client_build='mission-factory-admin/2:'||new_root_sha,
  independent_review_ref=review->>'ref',updated_at=clock_timestamp()
  WHERE singleton AND revision_sha256=old_root_sha AND public.combat_v2_sha256(to_jsonb(editor_release_readiness))=old_row_sha;
 GET DIAGNOSTICS affected=ROW_COUNT;IF affected<>1 THEN RAISE EXCEPTION 'CATALOGO_ROOT_ROW_CAS';END IF;
 INSERT INTO mission_public_owner.release_admissions_v1(release_sha256,db_sha256,edge_sha256,client_sha256,configuration_sha256,
  contract_version,independent_review_ref,staff_evidence_ref,qualified_at,public_enabled)
 VALUES(new_root_sha,db_sha,generic_ezbr,bindings->>'client_sha256',config_sha,prior_release.contract_version,
  review->>'ref',prior_release.staff_evidence_ref,prior_release.qualified_at,prior_release.public_enabled);
 FOR profile_row IN SELECT DISTINCT ON(profile_key)* FROM mission_public_owner.engine_profile_events_v1
  WHERE engine_release_sha256=old_root_sha ORDER BY profile_key,control_version DESC LOOP
  IF profile_row.profile_key IS DISTINCT FROM prior_qualification.payload->>'authoring_profile' THEN
   RAISE EXCEPTION 'CATALOGO_ROOT_UNQUALIFIED_PROFILE_CARRYFORWARD';END IF;
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
 OR mission_public_owner.engine_qualification_v1(new_root_sha,true)IS NULL THEN RAISE EXCEPTION 'CATALOGO_ROOT_MISSION_CARRYFORWARD_INVALID';END IF;
 FOR content_row IN SELECT * FROM mission_public_owner.mission_content_admissions_v1 WHERE engine_release_sha256=old_root_sha ORDER BY mission_id LOOP
  content_request:=extensions.uuid_generate_v5(content_row.request_key,new_root_sha||':catalogo-compatible-adoption');
  content_payload:=content_row.payload||jsonb_build_object('request_key',content_request,'engine_release_sha256',new_root_sha,'created_at',clock_timestamp());
  INSERT INTO mission_public_owner.mission_content_admissions_v1(request_key,mission_id,config_version,engine_release_sha256,publication_request,payload,payload_sha256)
  VALUES(content_request,content_row.mission_id,content_row.config_version,new_root_sha,content_row.publication_request,content_payload,mission_factory_owner.sha(content_payload));
  IF mission_public_owner.content_admission_v1(content_row.mission_id,new_root_sha,content_row.publication_request,true)IS NULL THEN
   RAISE EXCEPTION 'CATALOGO_ROOT_CONTENT_CARRYFORWARD_INVALID';END IF;
 END LOOP;
 UPDATE mission_public_owner.party_launch_runtime_v1 x SET release_sha256=new_root_sha WHERE singleton AND to_jsonb(x)=runtime_before;
 GET DIAGNOSTICS affected=ROW_COUNT;IF affected<>1 THEN RAISE EXCEPTION 'CATALOGO_ROOT_PARTY_RUNTIME_CAS';END IF;
 IF NOT EXISTS(SELECT 1 FROM mission_public_owner.party_launch_runtime_v1 x WHERE singleton
  AND to_jsonb(x)=jsonb_set(runtime_before,'{release_sha256}',to_jsonb(new_root_sha),false))THEN RAISE EXCEPTION 'CATALOGO_ROOT_PARTY_FLAGS_CHANGED';END IF;
 IF(SELECT to_jsonb(g)FROM combat_v2_genjutsu_internal.gate g WHERE singleton)IS DISTINCT FROM current_setting('app.cure_reaction_paralisi_gate_before')::jsonb THEN RAISE EXCEPTION 'cure_reaction_paralisi_gate_changed';END IF;
 IF(SELECT to_jsonb(g)FROM combat_panel_private.cure_gate_v1 g WHERE singleton)IS DISTINCT FROM current_setting('app.cure_reaction_cure_gate_before')::jsonb THEN RAISE EXCEPTION 'palmo_completion_cure_gate_changed';END IF;
 IF jsonb_build_object('aburame_genin',(SELECT to_jsonb(g)FROM clan_aburame_private.release_gate g WHERE singleton),'nara_genin',(SELECT to_jsonb(g)FROM combat_panel_private.nara_launch_gate_v1 g WHERE singleton),'akimichi_genin',(SELECT to_jsonb(g)FROM clan_akimichi_private.release_gate g WHERE singleton))IS DISTINCT FROM current_setting('app.joint_catalog_native_gates_before')::jsonb THEN RAISE EXCEPTION 'JOINT_NATIVE_GATES_CHANGED';END IF;
 UPDATE combat_v2_staff_nb_internal.gate SET staff_enabled=(params->>'mode'='source'),public_enabled=false WHERE singleton;
 UPDATE clan_aburame_private.verme_gate_v1 SET staff_enabled=(params->>'mode'='source'),public_enabled=false WHERE singleton;
 UPDATE clan_akimichi_private.common_gate_v1 SET staff_enabled=(params->>'mode'='source'),public_enabled=false,super_public_enabled=false,cellular_public_enabled=false WHERE singleton;
 UPDATE combat_panel_private.nara_adv_gate_v1 SET staff_enabled=(params->>'mode'='source'),public_enabled=false WHERE singleton;
 IF NOT clan_innata_private.catalogo_eligibility_release_v1()THEN RAISE EXCEPTION 'FIX_ELIGIBILITY_BRANCH_NOT_ADMITTED';END IF;
 PERFORM clan_innata_private.eligibility_release_assert();
 PERFORM set_config('app.joint_catalog_result',jsonb_build_object('root_sha256',new_root_sha,'root_bytes',octet_length(root_text),
  'db_sha256',db_sha,'configuration_sha256',config_sha,'code_identity_sha256',identity_sha,'aliases_updated',aliases,
  'amendment_identity_sha256',binding->'normalized_source_identity_sha256','active_shared_manifest_sha256',shared_sha,'active_private_functions_manifest_sha256',private_sha,
  'new_techniques_staff_pass',false,'provider_calls',0)::text,true);
END $catalogo_root$;

COMMIT;
