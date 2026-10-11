BEGIN;SET LOCAL lock_timeout='5s';SET LOCAL statement_timeout='60s';DO $ctx24ddl$DECLARE actual jsonb;BEGIN IF current_user<>'postgres' THEN RAISE EXCEPTION 'C24_OWNER';END IF;LOCK TABLE mission_factory_owner.editor_release_readiness,mission_factory_owner.c464_control,mission_factory_owner.provider_authoring_runtime,mission_factory_owner.provider_authoring_admissions IN SHARE ROW EXCLUSIVE MODE;
SELECT to_jsonb(x) INTO actual FROM mission_factory_owner.editor_release_readiness x WHERE singleton FOR UPDATE;IF actual IS DISTINCT FROM $ctx24${"canonical_preimage":"{\"config\":{\"bind_arena_alias_fix\":{\"bind_source_md5\":\"c7efaaf5c649a5d69f3d1f620f8bec2c\",\"cached_source_md5\":\"bd247db309ef2b683850a30df1b93c38\",\"message_id\":\"c652fc9f-53e2-422b-8188-ae9645225b60\",\"old_R\":\"a084916bfbe5a5ae521a1125d27970c16c01b7b7c9e32511635b3a5c20ac428c\",\"old_receipts_history_unchanged\":true,\"review_ref\":\"/Users/antonello/Desktop/theuntoldstory/management/candidati/NARRATORE-UNIFICATO_2026-09-02/candidato/exam_human_master/C1264_C889_ALIAS_STAGE_REVIEW.json\",\"review_sha256\":\"59f44ce8605b549f65b901d70320799eea47d8187a534c2be11aeaa3cd05ada3\",\"same_batch\":\"08512119-3bfd-4df7-adbc-0686f5edf5b7\",\"same_work\":\"86e5b361-9d82-aee8-a840-b09a83126fc0\",\"schema_version\":\"c1264-bind-arena-alias-fix/1\"},\"c889_native_combat_alias_fix\":{\"cached_ddl_md5\":\"e5af9b73f6de99fcfa8ebf6853857228\",\"cached_source_md5\":\"bd247db309ef2b683850a30df1b93c38\",\"same_authority_sha256\":\"ab4d2f01e012c4b296fec02e97546a3e3e31946b56eb270417243449e9f73ac4\",\"schema_version\":\"c889-native-combat-alias-fix/1\",\"stage_actual_ref\":\"/Users/antonello/Desktop/theuntoldstory/management/candidati/NARRATORE-UNIFICATO_2026-09-02/candidato/exam_human_master/C1264_C889_ALIAS_STAGE_ACTUAL.json\",\"stage_actual_sha256\":\"35461732636e1ef8dd5d26fff44d449f5010c2c5e6f5d7ccfb98f96ab60b10fb\",\"stage_review_ref\":\"/Users/antonello/Desktop/theuntoldstory/management/candidati/NARRATORE-UNIFICATO_2026-09-02/candidato/exam_human_master/C1264_C889_ALIAS_STAGE_REVIEW.json\",\"stage_review_sha256\":\"59f44ce8605b549f65b901d70320799eea47d8187a534c2be11aeaa3cd05ada3\",\"whole_registration_review_pending\":true},\"c889_native_combat_recovery\":{\"batch_id\":\"32e674f6-f1b8-4273-973e-7da88ed2c5b9\",\"cached_source_md5\":\"bd247db309ef2b683850a30df1b93c38\",\"old_work_id\":\"c88958e7-8983-4332-a14e-095076f967f4\",\"review_ref\":\"/Users/antonello/Desktop/theuntoldstory/management/candidati/NARRATORE-UNIFICATO_2026-09-02/candidato/exam_human_master/C1264_C889_ALIAS_STAGE_REVIEW.json\",\"review_sha256\":\"59f44ce8605b549f65b901d70320799eea47d8187a534c2be11aeaa3cd05ada3\",\"scene_id\":\"ce7bc0e0-c8ed-48dd-a9ec-58c02022a7b9\",\"schema_version\":\"c889-native-combat-recovery/1\",\"terminal_source_md5\":\"ad4b5e7689bbde32557d249c406cab74\"},\"count_overflow_fix\":{\"Count_accounting_preserved\":true,\"cursor_changed\":false,\"edge_bundle_sha256\":\"dd4e0be57f211028490f2fe9e4f03b06ded0d4a3e35942a58dfadbafaa543a9a\",\"input_tokens_limit\":12000,\"retry_source_md5\":\"bd22f6fad77b53108536518a54df3806\",\"review_ref\":\"/Users/antonello/Desktop/theuntoldstory/management/candidati/NARRATORE-UNIFICATO_2026-09-02/candidato/exam_human_master/C1264_C889_ACTUAL_COMPONENT_REVIEW.json\",\"review_sha256\":\"d85c5b5342cbfe3fa3a96caaba458f061c4562ca750309acd79f833cfab80325\",\"runtime_module_sha256\":\"529cd43b7a9222ae53d3225f557f267feb920fb94d51ec64e9c3544660274fc6\",\"scene_id\":\"ce7bc0e0-c8ed-48dd-a9ec-58c02022a7b9\",\"schema_version\":\"c1264-count-overflow-fix/1\",\"terminal_source_md5\":\"ad4b5e7689bbde32557d249c406cab74\"},\"count_qualification_sha256\":\"80b45307f57704c2ac97666bda2847605484d2436cdb5a88fd96439eac0cf0ab\",\"director_window_progression_fix\":{\"edge_bundle_sha256\":\"e1e2f8e9d3be237077b186167f6479beda78fb3c36f07377e916ccd6d6f4813b\",\"reader_source_md5\":\"936e83d16c6ba8f9482f78e9de18ef94\",\"release_verifier_source_md5\":\"b02cd4955e82142913aea184e5a2039a\",\"retry_source_md5\":\"33042fac5df248b8b42caa0f9edc81ee\",\"review_ref\":\"/private/tmp/regia-count-c1263/complete/ACTUAL_COMPONENT_REVIEW.json\",\"review_sha256\":\"53fbb32cd1a9509e358684f67134bbf0ddbdb3fde12c1dae553693a650149fb4\",\"runtime_module_sha256\":\"c1c2c928f95d25fd4bb606bae550077a751d054a58a7b6d68ecd54b7f2491818\",\"schema_version\":\"c1259-director-window-progression-fix/1\"},\"narration_recovery_fix\":{\"cached_source_md5\":\"bd247db309ef2b683850a30df1b93c38\",\"child_reader_source_md5\":\"936e83d16c6ba8f9482f78e9de18ef94\",\"http_sha256\":\"2e0b59a1a02b6f7a5236c4503aba13dd2ece326cbb1d2872fff5036a4cded247\",\"input_limit\":12000,\"old_writer_id\":\"42341080-7f78-494e-9adf-85de7cfce038\",\"review_ref\":\"/Users/antonello/Desktop/theuntoldstory/management/candidati/NARRATORE-UNIFICATO_2026-09-02/candidato/exam_human_master/C1264_C889_ALIAS_STAGE_REVIEW.json\",\"review_sha256\":\"59f44ce8605b549f65b901d70320799eea47d8187a534c2be11aeaa3cd05ada3\",\"runtime_sha256\":\"529cd43b7a9222ae53d3225f557f267feb920fb94d51ec64e9c3544660274fc6\",\"same_batch_facts_roles_history_accounting_preserved\":true,\"scene_id\":\"ce7bc0e0-c8ed-48dd-a9ec-58c02022a7b9\",\"schema_version\":\"c1264-narration-recovery/1\",\"terminal_source_md5\":\"ad4b5e7689bbde32557d249c406cab74\"},\"predecessor_C1263\":{\"history_rewritten\":false,\"payload_sha256\":\"772a8e1deb25bfabfed4ab29a01c8a96f884fcee5daaa0ccf598a4e084702fbd\",\"release_sha256\":\"cbcd8b6e843c2271bcab9c0bc4ab26f38cf56a0b7890bc5bc8845a569a1ed528\",\"work_id\":\"0ceab5df-d10c-47f2-a4c7-4efa120e163b\"},\"predecessor_C1264_AGG1\":{\"history_rewritten\":false,\"release_sha256\":\"77e1d0c44a2fe7e2127bc37542305424a418945f85826a2d5d7b2ca570a57967\"},\"predecessor_C1264_AGG3\":{\"history_rewritten\":false,\"release_sha256\":\"64baca98674be76e898a35b86ab1153cfe3dfb35e94e6193273a01ccd60d0436\"},\"predecessor_C889\":{\"old_receipts_payload_count_history_unchanged\":true,\"old_work_id\":\"c88958e7-8983-4332-a14e-095076f967f4\",\"origin_R\":\"a084916bfbe5a5ae521a1125d27970c16c01b7b7c9e32511635b3a5c20ac428c\",\"same_batch_id\":\"32e674f6-f1b8-4273-973e-7da88ed2c5b9\"},\"predecessor_C889_ALIAS\":{\"cached_source_md5\":\"6e205a8b02a22037965703a986993f8b\",\"old_count_reports_receipts_history_unchanged\":true,\"origin_R\":\"06f5f2eba4e3e5ccb920a92ca35ac48f2aa3e9e0048bcfc8c57f9510c1a9a250\",\"qualified_source_provenance\":{\"bind_arena_alias_fix\":{\"bind_source_md5\":\"c7efaaf5c649a5d69f3d1f620f8bec2c\",\"cached_source_md5\":\"6e205a8b02a22037965703a986993f8b\",\"message_id\":\"c652fc9f-53e2-422b-8188-ae9645225b60\",\"old_R\":\"a084916bfbe5a5ae521a1125d27970c16c01b7b7c9e32511635b3a5c20ac428c\",\"old_receipts_history_unchanged\":true,\"review_ref\":\"/Users/antonello/Desktop/theuntoldstory/management/candidati/NARRATORE-UNIFICATO_2026-09-02/candidato/exam_human_master/C1264_C889_ACTUAL_COMPONENT_REVIEW.json\",\"review_sha256\":\"d85c5b5342cbfe3fa3a96caaba458f061c4562ca750309acd79f833cfab80325\",\"same_batch\":\"08512119-3bfd-4df7-adbc-0686f5edf5b7\",\"same_work\":\"86e5b361-9d82-aee8-a840-b09a83126fc0\",\"schema_version\":\"c1264-bind-arena-alias-fix/1\"},\"c889_native_combat_recovery\":{\"batch_id\":\"32e674f6-f1b8-4273-973e-7da88ed2c5b9\",\"cached_source_md5\":\"6e205a8b02a22037965703a986993f8b\",\"old_work_id\":\"c88958e7-8983-4332-a14e-095076f967f4\",\"review_ref\":\"/Users/antonello/Desktop/theuntoldstory/management/candidati/NARRATORE-UNIFICATO_2026-09-02/candidato/exam_human_master/C1264_C889_ACTUAL_COMPONENT_REVIEW.json\",\"review_sha256\":\"d85c5b5342cbfe3fa3a96caaba458f061c4562ca750309acd79f833cfab80325\",\"scene_id\":\"ce7bc0e0-c8ed-48dd-a9ec-58c02022a7b9\",\"schema_version\":\"c889-native-combat-recovery/1\",\"terminal_source_md5\":\"ad4b5e7689bbde32557d249c406cab74\"},\"narration_recovery_fix\":{\"cached_source_md5\":\"6e205a8b02a22037965703a986993f8b\",\"child_reader_source_md5\":\"936e83d16c6ba8f9482f78e9de18ef94\",\"http_sha256\":\"2e0b59a1a02b6f7a5236c4503aba13dd2ece326cbb1d2872fff5036a4cded247\",\"input_limit\":12000,\"old_writer_id\":\"42341080-7f78-494e-9adf-85de7cfce038\",\"review_ref\":\"/Users/antonello/Desktop/theuntoldstory/management/candidati/NARRATORE-UNIFICATO_2026-09-02/candidato/exam_human_master/C1264_C889_ACTUAL_COMPONENT_REVIEW.json\",\"review_sha256\":\"d85c5b5342cbfe3fa3a96caaba458f061c4562ca750309acd79f833cfab80325\",\"runtime_sha256\":\"529cd43b7a9222ae53d3225f557f267feb920fb94d51ec64e9c3544660274fc6\",\"same_batch_facts_roles_history_accounting_preserved\":true,\"scene_id\":\"ce7bc0e0-c8ed-48dd-a9ec-58c02022a7b9\",\"schema_version\":\"c1264-narration-recovery/1\",\"terminal_source_md5\":\"ad4b5e7689bbde32557d249c406cab74\"}}},\"predecessor_C889_REVIEW_BINDING\":{\"observed_qa_ref\":{\"path\":\"/Users/antonello/Desktop/theuntoldstory/management/candidati/NARRATORE-UNIFICATO_2026-09-02/candidato/exam_human_master/C1264_C889_ALIAS_FATO_ACTUAL.json\",\"sha256\":\"a9355301ff7e3fa29955a247bf62cfa35e5efefb457abc1a1a4f4894079a58c1\"},\"observed_regression\":\"P1 c726 review binding mismatch caused normal cached SCOPE rejection; zero provider. Prior static review is not runtime PASS.\",\"old_active_binding\":{\"composed_review_ref\":\"/Users/antonello/Desktop/theuntoldstory/management/candidati/NARRATORE-UNIFICATO_2026-09-02/candidato/exam_human_master/C1264_C889_ACTUAL_COMPONENT_REVIEW.json\",\"composed_review_sha256\":\"d85c5b5342cbfe3fa3a96caaba458f061c4562ca750309acd79f833cfab80325\"},\"origin_R\":\"ea4bf38630a2ca27a87485f06ab92d92d4bdb087517ea7e99c452956a0cee53a\",\"previous_static_final_review_prefix\":\"051a\"},\"predecessor_compatibility\":{\"failed_work_id\":\"08fd12a0-7da9-4ba5-902a-dc50e1c7c304\",\"immutable_binding_sha256\":\"49817335c60ce9d4b47bc5d81c6950f622635c7fb232264ab54736349124f567\",\"origin_R\":\"61eb04f05f102a72ca7c55a0fd90ed98c2e17144b295678c73af55911be32821\",\"receipt_role_window_history_rewritten\":false,\"scene_id\":\"ce7bc0e0-c8ed-48dd-a9ec-58c02022a7b9\",\"work_contract_was_null\":true},\"staff_finite_ia_budget\":{\"composed_review_ref\":\"/Users/antonello/Desktop/theuntoldstory/management/candidati/NARRATORE-UNIFICATO_2026-09-02/candidato/exam_human_master/C1264_C889_ALIAS_STAGE_REVIEW.json\",\"composed_review_sha256\":\"59f44ce8605b549f65b901d70320799eea47d8187a534c2be11aeaa3cd05ada3\",\"count_reserve_contract_sha256\":\"b242ee7fcc6655fa951e8697acfbee4d6ba92b42b177fcbcf6a9b08d004661b2\",\"count_upper_cost_usd\":\"0.0112\",\"dispatch_admit_body_md5\":\"77a3272ce67fb6ccdaf36bf433ebd128\",\"generation_limit\":14,\"max_campaign_reserved_usd\":\"0.3136\",\"max_cumulative_http_calls\":28,\"native_g2_source_sha256\":\"4f58bb7fb726c870a489b9db6ea088719e0b2e6153b2b3f98bf6d8be928e1b50\",\"schema_version\":\"c717-staff-finite-ia-budget-policy/1\"},\"staff_tick_receipt_fix\":{\"contract_sha256\":\"6802f4da3db72b1a948c3cda04aed3d66020b2158632988df0a61cece9b6779c\",\"review_ref\":\"/Users/antonello/Desktop/theuntoldstory/management/candidati/NARRATORE-UNIFICATO_2026-09-02/candidato/exam_human_master/C1264_AGG2_STAGE_REVIEW.json\",\"review_sha256\":\"66b6a7e70a64becde237e66b4f14abcdcf2478e4c14df903c3809b04440044fc\",\"room_reader_source_md5\":\"8d0f61235bbc246d9ce43c129212923a\",\"scene_id\":\"ce7bc0e0-c8ed-48dd-a9ec-58c02022a7b9\",\"schema_version\":\"mission-generic-staff-tick-status/2\",\"tick_writer_unchanged\":true}},\"contract\":{\"authority_sha256\":\"ab4d2f01e012c4b296fec02e97546a3e3e31946b56eb270417243449e9f73ac4\",\"scope\":\"same_staff_scene_2PG_2PNG\",\"version\":\"C1264-C889-NATIVE-COMBAT-ALIAS2\"},\"db_core\":{\"cursor\":{\"acl\":\"{postgres=X/postgres}\",\"config\":[\"search_path=\\\"\\\"\"],\"ddl_md5\":\"ad7a76bdafcf332c6e8a93a5b48c05f0\",\"oid\":\"50400\",\"owner\":\"postgres\",\"secdef\":true,\"signature\":\"mission_generic_owner.narrative_context(uuid,text,uuid,timestamp with time zone,jsonb)\",\"source_md5\":\"fff570453d252f866c8c210c957baafe\"},\"migration_id\":\"C1264-C889-NATIVE-COMBAT-ALIAS2\",\"pins\":[{\"acl\":\"{postgres=X/postgres}\",\"config\":[\"search_path=\\\"\\\"\"],\"ddl_md5\":\"d44620dfc250eb3e0a5c487516867ce0\",\"oid\":\"49996\",\"owner\":\"postgres\",\"secdef\":true,\"signature\":\"mission_generic_owner.assert_runtime(uuid)\",\"source_md5\":\"930968cfd8b60793c2fea52cb74b4f7a\"},{\"acl\":\"{postgres=X/postgres}\",\"config\":[\"search_path=\\\"\\\"\"],\"ddl_md5\":\"fc0490e48f8362133523728a1759df0c\",\"oid\":\"50397\",\"owner\":\"postgres\",\"secdef\":true,\"signature\":\"mission_generic_owner.dispatch_admit(uuid,integer,numeric)\",\"source_md5\":\"77a3272ce67fb6ccdaf36bf433ebd128\"},{\"acl\":\"{postgres=X/postgres}\",\"config\":[\"search_path=\\\"\\\"\"],\"ddl_md5\":\"26c9e1d305f277d6bd590660850bfe74\",\"oid\":\"50464\",\"owner\":\"postgres\",\"secdef\":true,\"signature\":\"mission_generic_owner.provider_ready(uuid)\",\"source_md5\":\"f161edc978ce0f21ac353ff14279b003\"},{\"acl\":\"{postgres=X/postgres}\",\"config\":[\"search_path=\\\"\\\"\"],\"ddl_md5\":\"816d0a2c00b96c1fdb1308be88c6a27d\",\"oid\":\"50466\",\"owner\":\"postgres\",\"secdef\":true,\"signature\":\"mission_generic_owner.provider_native_assert(uuid,text)\",\"source_md5\":\"52031528c884ac193351b634d5d776fb\"},{\"acl\":\"{postgres=X/postgres}\",\"config\":[\"search_path=\\\"\\\"\"],\"ddl_md5\":\"c32f199a4d92cefb1b88d551434cc853\",\"oid\":\"109102\",\"owner\":\"postgres\",\"secdef\":true,\"signature\":\"mission_creation_owner.human_peaceful_route(uuid,bigint)\",\"source_md5\":\"c51239bfd9671f9aeaf44ca0c7dc3ece\"},{\"acl\":\"{postgres=X/postgres}\",\"config\":[\"search_path=\\\"\\\"\"],\"ddl_md5\":\"7295c845bdd660c28167e54631d99f47\",\"oid\":\"109964\",\"owner\":\"postgres\",\"secdef\":true,\"signature\":\"mission_generic_owner.role_source_released_v4(uuid)\",\"source_md5\":\"d968a1d102d06d9c108bd13fbf97167c\"},{\"acl\":\"{postgres=X/postgres,authenticated=X/postgres}\",\"config\":[\"search_path=\\\"\\\"\"],\"ddl_md5\":\"248c81f5f6df6e955f5b1bfb7320a139\",\"oid\":\"150480\",\"owner\":\"postgres\",\"secdef\":true,\"signature\":\"mission_staff_retry_failed_director_v1(uuid,uuid)\",\"source_md5\":\"bd22f6fad77b53108536518a54df3806\"},{\"acl\":\"{postgres=X/postgres}\",\"config\":[\"search_path=\\\"\\\"\"],\"ddl_md5\":\"d53ef5fc2b33dab40c6884d57bacd00a\",\"oid\":\"151693\",\"owner\":\"postgres\",\"secdef\":true,\"signature\":\"exam_human_private.execution_guard_v1()\",\"source_md5\":\"5252edd2446f3cbd8cf1430433765ced\"},{\"acl\":\"{postgres=X/postgres}\",\"config\":[\"search_path=\\\"\\\"\"],\"ddl_md5\":\"af27b23b89777c6a9a7633534c361df1\",\"oid\":\"151715\",\"owner\":\"postgres\",\"secdef\":true,\"signature\":\"exam_human_private.ordinary_ready_v1(uuid)\",\"source_md5\":\"437bbf2009d8ecdfdb6b00bfdffa80cb\"},{\"acl\":\"{postgres=X/postgres}\",\"config\":[\"search_path=\\\"\\\"\"],\"ddl_md5\":\"6c764152a8333516ea15d6525c4671f0\",\"oid\":\"276293\",\"owner\":\"postgres\",\"secdef\":true,\"signature\":\"mission_factory_owner.staff_release_sha_v1()\",\"source_md5\":\"ce3a7fcdee8c5df66b987ead979d4f67\"},{\"acl\":\"{postgres=X/postgres}\",\"config\":[\"search_path=\\\"\\\"\"],\"ddl_md5\":\"dfb64d7b4e155c400396b96937832ef1\",\"oid\":\"276449\",\"owner\":\"postgres\",\"secdef\":true,\"signature\":\"mission_factory_owner.provider_authoring_assert_v1(uuid)\",\"source_md5\":\"667d9ec32f6f2fc4e978ec8f51c1f543\"},{\"acl\":\"{postgres=X/postgres}\",\"config\":[\"search_path=\\\"\\\"\"],\"ddl_md5\":\"a8abce831a4c7673f5805f9531cab4f8\",\"oid\":\"276510\",\"owner\":\"postgres\",\"secdef\":true,\"signature\":\"exam_human_private.suna_template_assert_v1(boolean)\",\"source_md5\":\"135d50321cbaa7ca9dedc23770e1c7f9\"},{\"acl\":\"{postgres=X/postgres}\",\"config\":[\"search_path=\\\"\\\"\"],\"ddl_md5\":\"17c0ebed78afecc80ae54dcb88cb1737\",\"oid\":\"276557\",\"owner\":\"postgres\",\"secdef\":true,\"signature\":\"mission_public_owner.human_session_allowed_v1(uuid)\",\"source_md5\":\"2c7fd64ec85fbbe088ece645c72c4be0\"},{\"acl\":\"{postgres=X/postgres}\",\"config\":[\"search_path=\\\"\\\"\"],\"ddl_md5\":\"a4008e6956bef5e845136b5eeba25c39\",\"oid\":\"278278\",\"owner\":\"postgres\",\"secdef\":true,\"signature\":\"mission_generic_owner.c8_policy_snapshot_v1()\",\"source_md5\":\"ce9f390c94120dc6583b1825e8a36dfe\"},{\"acl\":\"{postgres=X/postgres,service_role=X/postgres}\",\"config\":[\"search_path=\\\"\\\"\"],\"ddl_md5\":\"8490e1555fd56ecf97209421884b99e6\",\"oid\":\"278279\",\"owner\":\"postgres\",\"secdef\":true,\"signature\":\"mission_generic_input_count_start_v1(uuid,uuid,text,text)\",\"source_md5\":\"c73c9d6087e82ebda02663b81d944511\"},{\"acl\":\"{postgres=X/postgres,service_role=X/postgres}\",\"config\":[\"search_path=\\\"\\\"\"],\"ddl_md5\":\"30a96cb1a26a1ae84ac174db22fc2995\",\"oid\":\"278281\",\"owner\":\"postgres\",\"secdef\":true,\"signature\":\"mission_generic_input_count_finish_v1(uuid,uuid,uuid,text,jsonb)\",\"source_md5\":\"53786cb127e29c89bd5fec436bddbf3b\"},{\"acl\":\"{postgres=X/postgres}\",\"config\":[\"search_path=\\\"\\\"\"],\"ddl_md5\":\"9f00ffa4d9fb803bb16ae69ea3502429\",\"oid\":\"278750\",\"owner\":\"postgres\",\"secdef\":true,\"signature\":\"mission_factory_owner.qc2_policy_assert_v1(uuid)\",\"source_md5\":\"c25140aca98bf9ad01201727300697a7\"},{\"acl\":\"{postgres=X/postgres}\",\"config\":[\"search_path=\\\"\\\"\"],\"ddl_md5\":\"b273cc0cb36748cfa011c364df6e72ad\",\"oid\":\"300418\",\"owner\":\"postgres\",\"secdef\":true,\"signature\":\"mission_generic_owner.c726_factory_staff_runtime_v1(uuid)\",\"source_md5\":\"a388ed795cda483eb814e3657823e7af\"}],\"reader\":{\"acl\":\"{postgres=X/postgres,service_role=X/postgres}\",\"config\":[\"search_path=\\\"\\\"\"],\"ddl_md5\":\"957ce2d38419e14c1729a59029935947\",\"oid\":\"308755\",\"owner\":\"postgres\",\"secdef\":true,\"signature\":\"mission_generic_director_narration_next_v1(uuid,jsonb,uuid)\",\"source_md5\":\"936e83d16c6ba8f9482f78e9de18ef94\"},\"target_bodies\":[{\"acl\":\"{postgres=X/postgres,service_role=X/postgres}\",\"config\":[\"search_path=\\\"\\\"\"],\"ddl_md5\":\"d7be5dd6614e00006b19dcb607b47ac3\",\"oid\":\"50409\",\"owner\":\"postgres\",\"secdef\":true,\"signature\":\"mission_generic_dispatch_status_v1(uuid,jsonb)\",\"source_md5\":\"2d118c8cb81b15f1b59402f502d2dc55\"},{\"acl\":\"{postgres=X/postgres,service_role=X/postgres}\",\"config\":[\"search_path=\\\"\\\"\"],\"ddl_md5\":\"d044f8e56394990aa46ae33ea3e12b8f\",\"oid\":\"50410\",\"owner\":\"postgres\",\"secdef\":true,\"signature\":\"mission_generic_dispatch_claim_v1(uuid,jsonb)\",\"source_md5\":\"09a75d0daf28f38cf6e3f2bf7c7d1865\"},{\"acl\":\"{postgres=X/postgres,authenticated=X/postgres}\",\"config\":[\"search_path=\\\"\\\"\"],\"ddl_md5\":\"00f7f3288da6d8d45319d75f7c8ade3e\",\"oid\":\"50484\",\"owner\":\"postgres\",\"secdef\":true,\"signature\":\"mission_generic_room_state_v1(uuid)\",\"source_md5\":\"8d0f61235bbc246d9ce43c129212923a\"},{\"acl\":\"{postgres=X/postgres}\",\"config\":[\"search_path=\\\"\\\"\"],\"ddl_md5\":\"7295c845bdd660c28167e54631d99f47\",\"oid\":\"109964\",\"owner\":\"postgres\",\"secdef\":true,\"signature\":\"mission_generic_owner.role_source_released_v4(uuid)\",\"source_md5\":\"d968a1d102d06d9c108bd13fbf97167c\"},{\"acl\":\"{postgres=X/postgres,authenticated=X/postgres}\",\"config\":[\"search_path=\\\"\\\"\"],\"ddl_md5\":\"248c81f5f6df6e955f5b1bfb7320a139\",\"oid\":\"150480\",\"owner\":\"postgres\",\"secdef\":true,\"signature\":\"mission_staff_retry_failed_director_v1(uuid,uuid)\",\"source_md5\":\"bd22f6fad77b53108536518a54df3806\"},{\"acl\":\"{postgres=X/postgres}\",\"config\":[\"search_path=\\\"\\\"\"],\"ddl_md5\":\"4fd3054b232421df9398b8c1359512f4\",\"oid\":\"261520\",\"owner\":\"postgres\",\"secdef\":true,\"signature\":\"mission_staff_abort_private.source_v1(uuid)\",\"source_md5\":\"1f73a4af64288375b2958def5ee21923\"},{\"acl\":\"{postgres=X/postgres}\",\"config\":[\"search_path=\\\"\\\"\"],\"ddl_md5\":\"a0987a77e721336eca8cc8b73891ef39\",\"oid\":\"261521\",\"owner\":\"postgres\",\"secdef\":true,\"signature\":\"mission_staff_abort_private.quiescent_v1(uuid)\",\"source_md5\":\"9e34ab6eed1e2f444a316d0b5ac719e9\"},{\"acl\":\"{postgres=X/postgres,authenticated=X/postgres}\",\"config\":[\"search_path=\\\"\\\"\"],\"ddl_md5\":\"518dc28a889dc531a8f2dd5c5d8701d4\",\"oid\":\"261524\",\"owner\":\"postgres\",\"secdef\":true,\"signature\":\"mission_staff_simulation_abort_v1(uuid,bigint,bigint,uuid)\",\"source_md5\":\"e5186651b4bdabb04dcb27a412c8d8d1\"},{\"acl\":\"{postgres=X/postgres,service_role=X/postgres}\",\"config\":[\"search_path=\\\"\\\"\"],\"ddl_md5\":\"fe6091d58cf94d0a6c1c42bbee3c095c\",\"oid\":\"308779\",\"owner\":\"postgres\",\"secdef\":true,\"signature\":\"mission_generic_owner.count_overflow_terminal_v1(uuid,uuid)\",\"source_md5\":\"ad4b5e7689bbde32557d249c406cab74\"},{\"acl\":\"{postgres=X/postgres,service_role=X/postgres}\",\"config\":[\"search_path=\\\"\\\"\"],\"ddl_md5\":\"e5af9b73f6de99fcfa8ebf6853857228\",\"oid\":\"150538\",\"owner\":\"postgres\",\"secdef\":true,\"signature\":\"mission_generic_staff_republish_failed_v1(uuid,uuid,uuid)\",\"source_md5\":\"bd247db309ef2b683850a30df1b93c38\"},{\"acl\":\"{postgres=X/postgres}\",\"config\":[\"search_path=\\\"\\\"\"],\"ddl_md5\":\"a7b152820563030497ba2b7c13ce3bad\",\"oid\":\"50120\",\"owner\":\"postgres\",\"secdef\":true,\"signature\":\"mission_generic_owner.bind_arena_native(uuid,uuid,uuid)\",\"source_md5\":\"c7efaaf5c649a5d69f3d1f620f8bec2c\"}],\"tick_writer\":{\"acl\":\"{postgres=X/postgres,service_role=X/postgres}\",\"config\":[\"search_path=\\\"\\\"\"],\"ddl_md5\":\"deed503323977aab3d4d0175a0e5c0e4\",\"oid\":\"109829\",\"owner\":\"postgres\",\"secdef\":true,\"signature\":\"mission_generic_staff_tick_v1(uuid,uuid,text,uuid)\",\"source_md5\":\"872497f9001b5f80ff8b66ce94a90336\"}},\"edge_bundles\":[{\"entrypoint_path\":\"/tmp/user_fn_tyhyxkslteigibktluml_a3ff986d-9390-4d88-9ef0-2bf3eabb1c96_61/source/mission-generic-index.ts\",\"ezbr_sha256\":\"dd4e0be57f211028490f2fe9e4f03b06ded0d4a3e35942a58dfadbafaa543a9a\",\"files\":[{\"bytes\":4393,\"name\":\"mission-generic-index.ts\",\"sha256\":\"98e2b6027f818600901348691bb8a6d50f2f3ae44c44b6a8afafd5bd93d3bfa4\"},{\"bytes\":15623,\"name\":\"mission-generic-http.mjs\",\"sha256\":\"2e0b59a1a02b6f7a5236c4503aba13dd2ece326cbb1d2872fff5036a4cded247\"},{\"bytes\":160351,\"name\":\"mission-generic-runtime.mjs\",\"sha256\":\"529cd43b7a9222ae53d3225f557f267feb920fb94d51ec64e9c3544660274fc6\"},{\"bytes\":5369,\"name\":\"exam_regia17/edge/src/shared-scene/editorial.mjs\",\"sha256\":\"8f04bfc747c1d3acf93960e9ba2ac295d27ab0baf552e9e35d35b13d203b8300\"},{\"bytes\":9284,\"name\":\"exam_regia17/edge/src/shared-scene/common.mjs\",\"sha256\":\"8b8ecc621a0753567ae3c5b8f8dc01ea958bd6a2284ad893449415f81cc7f7dd\"},{\"bytes\":6700,\"name\":\"exam_regia17/edge/src/shared-scene/scene.mjs\",\"sha256\":\"be436f9ad4bfca637f7bbc9a35e51bcbcc5e66128d5069b3f4300fcb6c90c5e7\"},{\"bytes\":6765,\"name\":\"exam_regia17/edge/src/shared-scene/staff-common.mjs\",\"sha256\":\"e316c7569c3bd79fbdac21322fd1dc7027a213578ceb022a89fbd50546ea0ed7\"},{\"bytes\":7437,\"name\":\"exam_regia17/edge/src/shared-scene/narrative-master.mjs\",\"sha256\":\"1560429c7c503d4d9dd78ef22c58394c8781fa9efed7d2ba61863d29630983a2\"},{\"bytes\":3947,\"name\":\"exam_regia17/edge/src/contracts.mjs\",\"sha256\":\"0ad88b84c3e083fc6cb333119d603daf23b3cd465d30285fba6aba5b1bb2f3b7\"},{\"bytes\":9237,\"name\":\"mission-generic-choice.mjs\",\"sha256\":\"7690b4e5ac91ea6bc7573ba238ee5883f2175935856833ca584759f7f20fe776\"},{\"bytes\":14018,\"name\":\"exam_regia17/edge/src/shared-panel/validate.mjs\",\"sha256\":\"972533fbe65ecfa7a954a5610d6ee6aedb317f4d99955a0a0ed1fecb715e613d\"},{\"bytes\":2611,\"name\":\"exam_regia17/edge/src/shared-panel/multiplication.mjs\",\"sha256\":\"d038e1052633d6ba8df80526a4b4b4a29be8b96024248619400008e5c2b1f7fe\"},{\"bytes\":2418,\"name\":\"mission-director-narration-read.mjs\",\"sha256\":\"90ff76fbd5e22225e31e6ae74929259d9e0a4f7cec0a0957dae2b7720ad99a42\"},{\"bytes\":1238,\"name\":\"exam_regia17/edge/src/provider.mjs\",\"sha256\":\"f7e5671ca353b15d7f8b9a427cef4e596d07296b41970e1776939bdd7b77c0dc\"}],\"import_map\":false,\"verify_jwt\":false,\"version\":61}],\"recovery\":{\"body_restore_allowed\":false,\"gate_hold_recipe_sha256\":\"d42e0644dacac2cbdd043dd94f374a5efba0c50f09e15963f17a77a1aaeffe50\",\"sha256\":\"d42e0644dacac2cbdd043dd94f374a5efba0c50f09e15963f17a77a1aaeffe50\"},\"schema_version\":\"mission-factory-release-tuple/1\",\"ui\":{\"commit\":\"6ddc6f952bbe53e9361f8d6e6b5f7c8a3ae6af06\",\"evidence\":\"singleassetblob571 verified remote; other2assets unchanged; PagesSuccess then hardreload normalStaffFirefox; C889technicalterminal0Gen andscopedRoleRecovery rendered\",\"files\":{\"land.html\":\"ed5739864f636f36426840665522bb8bdaae91dc\",\"mission-creation-ui.mjs\":\"d2a3df10cfa2cca33d4138e8c58917303eb99e67\",\"mission-generic-ui.mjs\":{\"bytes\":73882,\"git_blob\":\"571c23fadfd47b0c14eb8cbf9439ff88a530b20b\",\"sha256\":\"5d4474652999ce950ee8660a53a7e0261a4a10092a5ec9b01de215b41f93539d\"}},\"pages_conclusion\":\"success\",\"pages_run\":38161332916,\"tree\":\"75ef9f996f1d3f9d2d320f2e084806201f9878c2\",\"verified\":true}}","client_build":"mission-factory-admin/2:1c514d62805fa988e00e994789f23cc272a86cf021646fdbe086d1c43b1e0b03","created_at":"2026-10-03T04:40:35.016709+00:00","independent_review_ref":"/Users/antonello/Desktop/theuntoldstory/management/candidati/NARRATORE-UNIFICATO_2026-09-02/candidato/exam_human_master/C1264_C889_ALIAS_STAGE_REVIEW.json","observed_revision_sha256":"1c514d62805fa988e00e994789f23cc272a86cf021646fdbe086d1c43b1e0b03","published_assets_verified":true,"revision_sha256":"1c514d62805fa988e00e994789f23cc272a86cf021646fdbe086d1c43b1e0b03","scope":"staff","singleton":true,"staff_guards_verified":true,"state":"enabled","updated_at":"2026-10-11T18:56:05.290612+00:00"}$ctx24$::jsonb THEN RAISE EXCEPTION 'C24_CFG_CAS';END IF;
SELECT to_jsonb(x) INTO actual FROM mission_factory_owner.c464_control x WHERE singleton FOR UPDATE;IF actual IS DISTINCT FROM $ctx24${"authoring_enabled":false,"complete":true,"expires_at":"2026-10-11T19:11:05.289704+00:00","release_sha256":"1c514d62805fa988e00e994789f23cc272a86cf021646fdbe086d1c43b1e0b03","review_sha256":"59f44ce8605b549f65b901d70320799eea47d8187a534c2be11aeaa3cd05ada3","root_authority_sha256":"ab4d2f01e012c4b296fec02e97546a3e3e31946b56eb270417243449e9f73ac4","runtime_enabled":false,"singleton":true,"source_sha256":"4f58bb7fb726c870a489b9db6ea088719e0b2e6153b2b3f98bf6d8be928e1b50"}$ctx24$::jsonb THEN RAISE EXCEPTION 'C24_CFG_CAS';END IF;
SELECT to_jsonb(x) INTO actual FROM mission_factory_owner.provider_authoring_runtime x WHERE singleton FOR UPDATE;IF actual IS DISTINCT FROM $ctx24${"count_qualification_sha256":"80b45307f57704c2ac97666bda2847605484d2436cdb5a88fd96439eac0cf0ab","count_upper_cost_usd":0.0112,"edge_qualified":true,"enabled":false,"qualified":true,"release_sha256":"1c514d62805fa988e00e994789f23cc272a86cf021646fdbe086d1c43b1e0b03","singleton":true}$ctx24$::jsonb THEN RAISE EXCEPTION 'C24_CFG_CAS';END IF;
SELECT jsonb_agg(to_jsonb(x) ORDER BY actor_user) INTO actual FROM mission_factory_owner.provider_authoring_admissions x;IF actual IS DISTINCT FROM $ctx24$[{"actor_user":"b4952ed5-5ce0-49c0-9f2b-8fd5dcd89b4b","enabled":false,"expires_at":"2026-10-11T19:11:05.289704+00:00","location_id":"0b85f354-9cdb-47e1-baf9-3d266bb7e06b","release_sha256":"1c514d62805fa988e00e994789f23cc272a86cf021646fdbe086d1c43b1e0b03"},{"actor_user":"f0856d53-83a6-4de0-bc0c-12c87916e665","enabled":false,"expires_at":"2026-10-11T19:11:05.289704+00:00","location_id":"0b85f354-9cdb-47e1-baf9-3d266bb7e06b","release_sha256":"1c514d62805fa988e00e994789f23cc272a86cf021646fdbe086d1c43b1e0b03"}]$ctx24$::jsonb THEN RAISE EXCEPTION 'C24_ACTORS_CAS';END IF;
IF EXISTS(SELECT 1 FROM mission_factory_owner.c464_control WHERE singleton AND(runtime_enabled OR authoring_enabled)) OR EXISTS(SELECT 1 FROM mission_factory_owner.provider_authoring_runtime WHERE singleton AND enabled) OR EXISTS(SELECT 1 FROM mission_factory_owner.provider_authoring_admissions WHERE enabled) THEN RAISE EXCEPTION 'C24_GATES_OFF';END IF;IF mission_staff_abort_private.quiescent_v1('ce7bc0e0-c8ed-48dd-a9ec-58c02022a7b9'::uuid) IS DISTINCT FROM TRUE THEN RAISE EXCEPTION 'C24_INFLIGHT';END IF;
IF NOT EXISTS(SELECT 1 FROM pg_proc WHERE oid=109982 AND md5(prosrc)=$ctx24$d6a735631b64a6dcf032262438872f83$ctx24$ AND md5(pg_get_functiondef(oid))=$ctx24$d618a5528e529ba073867da5d49d98e9$ctx24$ AND pg_get_userbyid(proowner)=$ctx24$postgres$ctx24$ AND proacl::text=$ctx24${postgres=X/postgres}$ctx24$ AND to_jsonb(proconfig)=$ctx24$["search_path=\"\""]$ctx24$::jsonb) THEN RAISE EXCEPTION 'C24_SOURCE_CAS';END IF;
IF NOT EXISTS(SELECT 1 FROM pg_proc WHERE oid=51406 AND md5(prosrc)=$ctx24$589fdce36505fc0e75b2d89844ceb2ca$ctx24$ AND md5(pg_get_functiondef(oid))=$ctx24$862b5d09f53f860d13b1b735d717e7b1$ctx24$ AND pg_get_userbyid(proowner)=$ctx24$postgres$ctx24$ AND proacl::text=$ctx24${postgres=X/postgres}$ctx24$ AND to_jsonb(proconfig)=$ctx24$["search_path=\"\""]$ctx24$::jsonb) THEN RAISE EXCEPTION 'C24_SOURCE_CAS';END IF;
IF NOT EXISTS(SELECT 1 FROM pg_proc WHERE oid=277634 AND md5(prosrc)=$ctx24$94bbe64f3573cc78cfd5dd6f675428e7$ctx24$ AND md5(pg_get_functiondef(oid))=$ctx24$3b2f07b9efaa2260de3e785b154a9fb3$ctx24$ AND pg_get_userbyid(proowner)=$ctx24$postgres$ctx24$ AND proacl::text=$ctx24${postgres=X/postgres}$ctx24$ AND to_jsonb(proconfig)=$ctx24$["search_path=\"\""]$ctx24$::jsonb) THEN RAISE EXCEPTION 'C24_SOURCE_CAS';END IF;
IF NOT EXISTS(SELECT 1 FROM pg_proc WHERE oid=50410 AND md5(prosrc)=$ctx24$09a75d0daf28f38cf6e3f2bf7c7d1865$ctx24$ AND md5(pg_get_functiondef(oid))=$ctx24$d044f8e56394990aa46ae33ea3e12b8f$ctx24$ AND pg_get_userbyid(proowner)=$ctx24$postgres$ctx24$ AND proacl::text=$ctx24${postgres=X/postgres,service_role=X/postgres}$ctx24$ AND to_jsonb(proconfig)=$ctx24$["search_path=\"\""]$ctx24$::jsonb) THEN RAISE EXCEPTION 'C24_SOURCE_CAS';END IF;
IF NOT EXISTS(SELECT 1 FROM pg_proc WHERE oid=278279 AND md5(prosrc)=$ctx24$c73c9d6087e82ebda02663b81d944511$ctx24$ AND md5(pg_get_functiondef(oid))=$ctx24$8490e1555fd56ecf97209421884b99e6$ctx24$ AND pg_get_userbyid(proowner)=$ctx24$postgres$ctx24$ AND proacl::text=$ctx24${postgres=X/postgres,service_role=X/postgres}$ctx24$ AND to_jsonb(proconfig)=$ctx24$["search_path=\"\""]$ctx24$::jsonb) THEN RAISE EXCEPTION 'C24_SOURCE_CAS';END IF;
IF NOT EXISTS(SELECT 1 FROM pg_proc WHERE oid=300418 AND md5(prosrc)=$ctx24$a388ed795cda483eb814e3657823e7af$ctx24$ AND md5(pg_get_functiondef(oid))=$ctx24$b273cc0cb36748cfa011c364df6e72ad$ctx24$ AND pg_get_userbyid(proowner)=$ctx24$postgres$ctx24$ AND proacl::text=$ctx24${postgres=X/postgres}$ctx24$ AND to_jsonb(proconfig)=$ctx24$["search_path=\"\""]$ctx24$::jsonb) THEN RAISE EXCEPTION 'C24_SOURCE_CAS';END IF;
IF NOT EXISTS(SELECT 1 FROM pg_proc WHERE oid=308779 AND md5(prosrc)=$ctx24$ad4b5e7689bbde32557d249c406cab74$ctx24$ AND md5(pg_get_functiondef(oid))=$ctx24$fe6091d58cf94d0a6c1c42bbee3c095c$ctx24$ AND pg_get_userbyid(proowner)=$ctx24$postgres$ctx24$ AND proacl::text=$ctx24${postgres=X/postgres,service_role=X/postgres}$ctx24$ AND to_jsonb(proconfig)=$ctx24$["search_path=\"\""]$ctx24$::jsonb) THEN RAISE EXCEPTION 'C24_SOURCE_CAS';END IF;
IF NOT EXISTS(SELECT 1 FROM pg_proc WHERE oid=278282 AND md5(prosrc)=$ctx24$5c24662b6c4aedb72b7bb8f8ba36a149$ctx24$ AND md5(pg_get_functiondef(oid))=$ctx24$bf9c8605ce57fb8f9e9a0505def428cd$ctx24$ AND pg_get_userbyid(proowner)=$ctx24$postgres$ctx24$ AND proacl::text=$ctx24${postgres=X/postgres}$ctx24$ AND to_jsonb(proconfig)=$ctx24$["search_path=\"\""]$ctx24$::jsonb) THEN RAISE EXCEPTION 'C24_SOURCE_CAS';END IF;
IF NOT EXISTS(SELECT 1 FROM pg_proc WHERE oid=50412 AND md5(prosrc)=$ctx24$9c8cb42dd0588ffee052cb0a1e65f29d$ctx24$ AND md5(pg_get_functiondef(oid))=$ctx24$91709f6c576a847ee170aa6e6650493b$ctx24$) THEN RAISE EXCEPTION 'C24_AUTHORIZE_SOURCE_CAS';END IF;
IF NOT EXISTS(SELECT 1 FROM mission_generic_owner.work_items w WHERE w.id='48e1bdcd-f044-be8c-1923-54d38e7e822c'::uuid AND w.state='ready' AND w.dispatch_receipt_id IS NULL AND w.authorization_id IS NULL AND w.dispatch_id IS NULL AND (EXISTS(SELECT 1 FROM mission_generic_owner.work_items c24old JOIN mission_generic_owner.unified_batches c24batch ON c24batch.id=w.authority_receipt_id
 JOIN mission_narrative_internal.dispatch_receipts c24receipt ON c24receipt.id=c24old.dispatch_receipt_id
 WHERE c24old.id='c88958e7-8983-4332-a14e-095076f967f4'::uuid AND w.id='48e1bdcd-f044-be8c-1923-54d38e7e822c'::uuid AND w.master_session_id='ce7bc0e0-c8ed-48dd-a9ec-58c02022a7b9'::uuid
 AND w.id=md5('C889:work:'||c24old.id::text)::uuid AND w.event_id=md5('C889:event:'||c24old.id::text)::uuid AND w.request_key=md5('C889:request:'||c24old.id::text)::uuid
 AND w.dedupe_key='c889-count-reissue:'||c24old.id::text AND w.kind='narration' AND w.payload->>'schema_version'='mission-generic-narration/3'
 AND c24batch.id='32e674f6-f1b8-4273-973e-7da88ed2c5b9'::uuid AND c24batch.master_session_id=w.master_session_id AND c24batch.writer_work_id=w.id AND c24batch.state IN('ready','published') AND c24batch.message_id IS NOT DISTINCT FROM w.message_id
 AND c24batch.composition_kind='combat_resolved_no_pending' AND c24batch.source_window_id IS NULL AND c24batch.next_round_id IS NULL
 AND c24old.master_session_id=w.master_session_id AND c24old.authority_receipt_id=c24batch.id AND c24old.state='failed'
 AND c24old.result->>'schema_version'='mission-count-overflow-failure/1' AND c24old.result->>'failure_code'='MISSION_INPUT_COUNT_OVERFLOW'
 AND c24old.result->>'input_tokens'='14811' AND c24old.result->>'max_input_tokens'='12000' AND c24old.result->>'generation_http_calls'='0'
 AND c24old.result_sha256=public.combat_v2_sha256(c24old.result) AND c24old.authorization_id IS NULL AND c24old.dispatch_id IS NULL
 AND w.payload=c24old.payload AND w.payload=c24batch.payload AND w.payload_sha256=c24old.payload_sha256 AND w.payload_sha256=c24batch.payload_sha256
 AND w.payload_sha256='da8c38c23db1c04ceaaaedfb7b5ead1b43c18c1ee60b069696ba36d832c9da78'
 AND w.run_control_version=c24old.run_control_version AND w.definition_sha256=c24old.definition_sha256 AND w.revision=c24old.revision
 AND c24receipt.status='failed' AND c24receipt.finalized_at IS NOT NULL AND c24receipt.dispatch_count=0 AND c24receipt.charged_cost_usd=0
 AND NOT EXISTS(SELECT 1 FROM mission_narrative_internal.dispatch_attempts c24attempt WHERE c24attempt.receipt_id=c24receipt.id)
 AND NOT EXISTS(SELECT 1 FROM mission_narrative_internal.provider_authorizations c24auth WHERE c24auth.receipt_id=c24receipt.id)
 AND EXISTS(SELECT 1 FROM mission_narrative_internal.dispatch_audit c24audit WHERE c24audit.receipt_id=c24receipt.id AND c24audit.event_code='generic_count_overflow_terminal'
  AND c24audit.details->>'work_id'=c24old.id::text AND c24audit.details->>'receipt_id'=c24old.receipt_id::text AND c24audit.details->>'result_sha256'=c24old.result_sha256)
 AND EXISTS(SELECT 1 FROM mission_narrative_internal.dispatch_audit c24audit WHERE c24audit.receipt_id=c24receipt.id AND c24audit.event_code='c889_count_narration_reissued'
  AND c24audit.details->>'old_work_id'=c24old.id::text AND c24audit.details->>'work_id'=w.id::text AND c24audit.details->>'batch_id'=c24batch.id::text
  AND c24audit.details->>'payload_sha256'=w.payload_sha256 AND c24audit.details->>'generation_http_calls'='0')))) THEN RAISE EXCEPTION 'C24_ISSUED_READY_CHANGED';END IF;
IF to_regprocedure('mission_generic_owner.c8_context24_scope_v1(uuid)') IS NOT NULL OR to_regprocedure('mission_generic_owner.c8_policy_snapshot_v1(uuid)') IS NOT NULL THEN RAISE EXCEPTION 'C24_NEW_SIGNATURE_EXISTS';END IF;
EXECUTE $newscope$CREATE OR REPLACE FUNCTION mission_generic_owner.c8_context24_scope_v1(p_work uuid) RETURNS boolean LANGUAGE plpgsql STABLE SECURITY DEFINER SET search_path TO '' AS $function$
DECLARE w mission_generic_owner.work_items;ctx jsonb;cfg mission_factory_owner.editor_release_readiness;ctl mission_factory_owner.c464_control;fr mission_factory_owner.provider_authoring_runtime;adm mission_generic_owner.dispatch_admissions;binding mission_generic_owner.run_bindings;proof text;
BEGIN
 IF p_work IS DISTINCT FROM '48e1bdcd-f044-be8c-1923-54d38e7e822c'::uuid THEN RETURN false;END IF;
 SELECT * INTO STRICT w FROM mission_generic_owner.work_items WHERE id=p_work;
 IF NOT (EXISTS(SELECT 1 FROM mission_generic_owner.work_items c24old JOIN mission_generic_owner.unified_batches c24batch ON c24batch.id=w.authority_receipt_id
 JOIN mission_narrative_internal.dispatch_receipts c24receipt ON c24receipt.id=c24old.dispatch_receipt_id
 WHERE c24old.id='c88958e7-8983-4332-a14e-095076f967f4'::uuid AND w.id='48e1bdcd-f044-be8c-1923-54d38e7e822c'::uuid AND w.master_session_id='ce7bc0e0-c8ed-48dd-a9ec-58c02022a7b9'::uuid
 AND w.id=md5('C889:work:'||c24old.id::text)::uuid AND w.event_id=md5('C889:event:'||c24old.id::text)::uuid AND w.request_key=md5('C889:request:'||c24old.id::text)::uuid
 AND w.dedupe_key='c889-count-reissue:'||c24old.id::text AND w.kind='narration' AND w.payload->>'schema_version'='mission-generic-narration/3'
 AND c24batch.id='32e674f6-f1b8-4273-973e-7da88ed2c5b9'::uuid AND c24batch.master_session_id=w.master_session_id AND c24batch.writer_work_id=w.id AND c24batch.state IN('ready','published') AND c24batch.message_id IS NOT DISTINCT FROM w.message_id
 AND c24batch.composition_kind='combat_resolved_no_pending' AND c24batch.source_window_id IS NULL AND c24batch.next_round_id IS NULL
 AND c24old.master_session_id=w.master_session_id AND c24old.authority_receipt_id=c24batch.id AND c24old.state='failed'
 AND c24old.result->>'schema_version'='mission-count-overflow-failure/1' AND c24old.result->>'failure_code'='MISSION_INPUT_COUNT_OVERFLOW'
 AND c24old.result->>'input_tokens'='14811' AND c24old.result->>'max_input_tokens'='12000' AND c24old.result->>'generation_http_calls'='0'
 AND c24old.result_sha256=public.combat_v2_sha256(c24old.result) AND c24old.authorization_id IS NULL AND c24old.dispatch_id IS NULL
 AND w.payload=c24old.payload AND w.payload=c24batch.payload AND w.payload_sha256=c24old.payload_sha256 AND w.payload_sha256=c24batch.payload_sha256
 AND w.payload_sha256='da8c38c23db1c04ceaaaedfb7b5ead1b43c18c1ee60b069696ba36d832c9da78'
 AND w.run_control_version=c24old.run_control_version AND w.definition_sha256=c24old.definition_sha256 AND w.revision=c24old.revision
 AND c24receipt.status='failed' AND c24receipt.finalized_at IS NOT NULL AND c24receipt.dispatch_count=0 AND c24receipt.charged_cost_usd=0
 AND NOT EXISTS(SELECT 1 FROM mission_narrative_internal.dispatch_attempts c24attempt WHERE c24attempt.receipt_id=c24receipt.id)
 AND NOT EXISTS(SELECT 1 FROM mission_narrative_internal.provider_authorizations c24auth WHERE c24auth.receipt_id=c24receipt.id)
 AND EXISTS(SELECT 1 FROM mission_narrative_internal.dispatch_audit c24audit WHERE c24audit.receipt_id=c24receipt.id AND c24audit.event_code='generic_count_overflow_terminal'
  AND c24audit.details->>'work_id'=c24old.id::text AND c24audit.details->>'receipt_id'=c24old.receipt_id::text AND c24audit.details->>'result_sha256'=c24old.result_sha256)
 AND EXISTS(SELECT 1 FROM mission_narrative_internal.dispatch_audit c24audit WHERE c24audit.receipt_id=c24receipt.id AND c24audit.event_code='c889_count_narration_reissued'
  AND c24audit.details->>'old_work_id'=c24old.id::text AND c24audit.details->>'work_id'=w.id::text AND c24audit.details->>'batch_id'=c24batch.id::text
  AND c24audit.details->>'payload_sha256'=w.payload_sha256 AND c24audit.details->>'generation_http_calls'='0'))) THEN RETURN false;END IF;
 SELECT * INTO STRICT cfg FROM mission_factory_owner.editor_release_readiness WHERE singleton;SELECT * INTO STRICT ctl FROM mission_factory_owner.c464_control WHERE singleton;SELECT * INTO STRICT fr FROM mission_factory_owner.provider_authoring_runtime WHERE singleton;
 SELECT * INTO STRICT adm FROM mission_generic_owner.dispatch_admissions WHERE master_session_id=w.master_session_id;SELECT * INTO STRICT binding FROM mission_generic_owner.run_bindings WHERE master_session_id=w.master_session_id;
 ctx:=cfg.canonical_preimage::jsonb#>'{config,c889_context24_policy}';
 IF ctx IS NULL OR ctx->>'schema_version' IS DISTINCT FROM 'c889-context24-policy/1' OR ctx->>'scene_id' IS DISTINCT FROM w.master_session_id::text OR ctx->>'work_id' IS DISTINCT FROM w.id::text
 OR ctx->>'input_tokens_limit' IS DISTINCT FROM '24000' OR ctx->>'output_tokens_limit' IS DISTINCT FROM '20000'
 OR ctx->>'count_upper_cost_usd' IS DISTINCT FROM '0.0124' OR ctx->>'generation_upper_cost_usd' IS DISTINCT FROM '0.0124'
 OR ctx->>'count_reserve_contract_sha256' IS DISTINCT FROM '13421de48d6dddbb8c6628fd6a294b90746b3d2b79e56bf617456a5d3cc8e090' OR (ctx->>'financial_qualification_sha256' ~ '^[a-f0-9]{64}$') IS DISTINCT FROM TRUE
 OR ctx->>'financial_qualification_sha256'='80b45307f57704c2ac97666bda2847605484d2436cdb5a88fd96439eac0cf0ab'
 OR mission_generic_owner.c8_policy_snapshot_v1()->>'model' IS DISTINCT FROM 'gpt-6-luna' OR mission_generic_owner.c8_policy_snapshot_v1()->>'reasoning_effort' IS DISTINCT FROM 'high' OR mission_generic_owner.c8_policy_snapshot_v1()->>'store' IS DISTINCT FROM 'false' OR mission_generic_owner.c8_policy_snapshot_v1()->>'max_output_tokens' IS DISTINCT FROM '20000' OR (mission_generic_owner.c8_policy_snapshot_v1()->>'input_usd_million')::numeric IS DISTINCT FROM 0.1 OR (mission_generic_owner.c8_policy_snapshot_v1()->>'output_usd_million')::numeric IS DISTINCT FROM 0.5
 OR NOT ctl.complete OR ctl.authoring_enabled OR ctl.release_sha256<>cfg.revision_sha256 OR fr.release_sha256<>cfg.revision_sha256 OR cfg.observed_revision_sha256<>cfg.revision_sha256
 OR encode(extensions.digest(convert_to(cfg.canonical_preimage,'UTF8'),'sha256'),'hex')<>cfg.revision_sha256 OR cfg.scope<>'staff'
 OR NOT fr.qualified OR NOT fr.edge_qualified OR fr.count_upper_cost_usd<>0.0124 OR fr.count_qualification_sha256 IS DISTINCT FROM ctx->>'financial_qualification_sha256'
 OR adm.call_limit<>14 OR adm.cost_budget_usd<>0.3136 OR NOT adm.c7_budget_enforced OR adm.c8_count_upper_cost_usd<>0.0124 OR adm.c8_count_qualification_sha256 IS DISTINCT FROM fr.count_qualification_sha256
 OR binding.snapshot_sha256<>'49817335c60ce9d4b47bc5d81c6950f622635c7fb232264ab54736349124f567' OR binding.snapshot_sha256<>mission_internal.fingerprint(binding.snapshot)
 THEN RETURN false;END IF;
 proof:=encode(extensions.digest(convert_to(jsonb_build_object('schema_version','c889-context24-native-admission/1','count_contract_sha256','13421de48d6dddbb8c6628fd6a294b90746b3d2b79e56bf617456a5d3cc8e090','session_id',w.master_session_id,'work_id',w.id,'binding_sha256',binding.snapshot_sha256,'count_qualification_sha256',fr.count_qualification_sha256,'generation_limit',14,'http_limit',28,'cost','0.3136','input_tokens_limit',24000,'output_tokens_limit',20000,'count_upper_cost_usd','0.0124','generation_upper_cost_usd','0.0124')::text,'UTF8'),'sha256'),'hex');
 RETURN adm.c7_budget_qualification_sha256=proof;
END $function$;
REVOKE ALL ON FUNCTION mission_generic_owner.c8_context24_scope_v1(uuid) FROM PUBLIC,anon,authenticated;
GRANT EXECUTE ON FUNCTION mission_generic_owner.c8_context24_scope_v1(uuid) TO service_role;
CREATE OR REPLACE FUNCTION mission_generic_owner.c8_policy_snapshot_v1(p_work uuid) RETURNS jsonb LANGUAGE sql STABLE SECURITY DEFINER SET search_path TO '' AS $function$
 SELECT CASE WHEN mission_generic_owner.c8_context24_scope_v1(p_work) THEN mission_generic_owner.c8_policy_snapshot_v1()||jsonb_build_object('max_input_tokens',24000,'max_output_tokens',20000) ELSE mission_generic_owner.c8_policy_snapshot_v1() END;
$function$;
REVOKE ALL ON FUNCTION mission_generic_owner.c8_policy_snapshot_v1(uuid) FROM PUBLIC,anon,authenticated;
GRANT EXECUTE ON FUNCTION mission_generic_owner.c8_policy_snapshot_v1(uuid) TO service_role;
$newscope$;
EXECUTE $targetddl$CREATE OR REPLACE FUNCTION mission_generic_owner.role_native_combat_work_class_v4(p_work uuid)
 RETURNS text
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO ''
AS $function$
DECLARE w mission_generic_owner.work_items;
BEGIN
 PERFORM mission_ai_board_owner.service_only();
 SELECT * INTO STRICT w FROM mission_generic_owner.work_items WHERE id=p_work;
 IF NOT EXISTS (
   SELECT 1 FROM mission_generic_owner.role_window_cursors cursor
   JOIN mission_generic_owner.flow_staff_sessions staff
     ON staff.master_session_id=cursor.master_session_id
   JOIN public.master_v2_sessions master ON master.id=cursor.master_session_id
   JOIN public.locations location ON location.id=master.location_id
   WHERE cursor.master_session_id=w.master_session_id AND staff.enabled
     AND master.owner_kind='ai_service' AND location.is_test
 ) OR w.payload_sha256 IS DISTINCT FROM public.combat_v2_sha256(w.payload)
 THEN RETURN NULL; END IF;

 IF w.kind='choice' AND w.payload->>'schema_version'='mission-generic-choice/1' THEN
   IF EXISTS (
     SELECT 1 FROM mission_generic_owner.panel_choices panel
     JOIN mission_generic_owner.encounters encounter
       ON encounter.encounter_id=panel.encounter_id
      AND encounter.master_session_id=panel.master_session_id
     JOIN public.combat_v2_rounds round_row
       ON round_row.id=(panel.legal_options#>>'{context,round_id}')::uuid
      AND round_row.session_id=encounter.encounter_id
     JOIN mission_generic_owner.unified_round_windows round_window
       ON round_window.round_id=round_row.id
      AND round_window.master_session_id=encounter.master_session_id
     JOIN mission_generic_owner.unified_batches source_batch
       ON source_batch.id=round_window.batch_id
      AND source_batch.master_session_id=encounter.master_session_id
      AND source_batch.encounter_id=encounter.encounter_id
     WHERE panel.id=w.authority_receipt_id AND panel.work_id=w.id
       AND panel.master_session_id=w.master_session_id
       AND panel.encounter_id=w.encounter_id
       AND panel.actor_id=(w.payload->>'actor_id')::uuid
       AND panel.request_key=(w.payload->>'command_request_key')::uuid
       AND panel.id=(w.payload->>'capability_id')::uuid
       AND panel.context_version=(w.payload->>'context_version')::bigint
       AND panel.legal_options=w.payload->'legal_options'
       AND panel.options_sha256=public.combat_v2_sha256(panel.legal_options)
       AND panel.legal_options#>>'{context,activity_id}'=encounter.encounter_id::text
       AND w.payload->>'combat_session_id'=encounter.encounter_id::text
       AND w.payload->>'round_id'=round_row.id::text
       AND w.step_key=encounter.step_key
       AND w.run_control_version=encounter.run_control_version
       AND (
         (round_window.publication_id=source_batch.message_id
          AND source_batch.state='published')
         OR
         (round_window.publication_id IS NULL
          AND source_batch.message_id IS NULL
          AND source_batch.state='preparing'
          AND source_batch.entry_side='png'
          AND source_batch.source_window_id IS NULL
          AND source_batch.source_report_id IS NOT NULL
          AND source_batch.next_round_id=round_row.id
          AND source_batch.decision_work_id IS NULL
          AND EXISTS (
            SELECT 1 FROM public.combat_v2_rounds prior_round
            JOIN public.combat_v2_round_reports prior_report
              ON prior_report.id=source_batch.source_report_id
             AND prior_report.round_id=prior_round.id
            WHERE prior_round.id=source_batch.source_round_id
              AND prior_round.session_id=encounter.encounter_id
              AND prior_round.staff_private_successor_source
              AND prior_round.state='risolto'
          ))
       )
       AND EXISTS (
         SELECT 1 FROM jsonb_array_elements(encounter.actor_map) actor_entry
         WHERE actor_entry->>'actor_id'=panel.actor_id::text
       )
       AND EXISTS (
         SELECT 1 FROM public.combat_v2_actors actor_row
         WHERE actor_row.id=panel.actor_id
           AND actor_row.session_id=encounter.encounter_id
           AND actor_row.actor_kind='png'
       )
   ) THEN RETURN 'native_combat_choice'; END IF;
   RETURN NULL;
 END IF;

 IF w.kind='narration' AND w.payload->>'schema_version'='mission-generic-narration/3'
   AND w.payload->>'mode'='unified'
   AND w.payload->'source_windows'='[]'::jsonb
 THEN
   IF EXISTS (
     SELECT 1 FROM mission_generic_owner.unified_batches batch
     JOIN mission_generic_owner.encounters encounter
       ON encounter.encounter_id=batch.encounter_id
      AND encounter.master_session_id=batch.master_session_id
     JOIN public.combat_v2_rounds source_round ON source_round.id=batch.source_round_id
       AND source_round.session_id=batch.encounter_id
     JOIN public.combat_v2_round_reports source_report
       ON source_report.id=batch.source_report_id
      AND source_report.round_id=source_round.id
     WHERE batch.id=w.authority_receipt_id
       AND batch.writer_work_id=w.id AND (
         w.event_id=batch.id OR (EXISTS(SELECT 1 FROM mission_generic_owner.work_items c24old JOIN mission_generic_owner.unified_batches c24batch ON c24batch.id=w.authority_receipt_id
 JOIN mission_narrative_internal.dispatch_receipts c24receipt ON c24receipt.id=c24old.dispatch_receipt_id
 WHERE c24old.id='c88958e7-8983-4332-a14e-095076f967f4'::uuid AND w.id='48e1bdcd-f044-be8c-1923-54d38e7e822c'::uuid AND w.master_session_id='ce7bc0e0-c8ed-48dd-a9ec-58c02022a7b9'::uuid
 AND w.id=md5('C889:work:'||c24old.id::text)::uuid AND w.event_id=md5('C889:event:'||c24old.id::text)::uuid AND w.request_key=md5('C889:request:'||c24old.id::text)::uuid
 AND w.dedupe_key='c889-count-reissue:'||c24old.id::text AND w.kind='narration' AND w.payload->>'schema_version'='mission-generic-narration/3'
 AND c24batch.id='32e674f6-f1b8-4273-973e-7da88ed2c5b9'::uuid AND c24batch.master_session_id=w.master_session_id AND c24batch.writer_work_id=w.id AND c24batch.state IN('ready','published') AND c24batch.message_id IS NOT DISTINCT FROM w.message_id
 AND c24batch.composition_kind='combat_resolved_no_pending' AND c24batch.source_window_id IS NULL AND c24batch.next_round_id IS NULL
 AND c24old.master_session_id=w.master_session_id AND c24old.authority_receipt_id=c24batch.id AND c24old.state='failed'
 AND c24old.result->>'schema_version'='mission-count-overflow-failure/1' AND c24old.result->>'failure_code'='MISSION_INPUT_COUNT_OVERFLOW'
 AND c24old.result->>'input_tokens'='14811' AND c24old.result->>'max_input_tokens'='12000' AND c24old.result->>'generation_http_calls'='0'
 AND c24old.result_sha256=public.combat_v2_sha256(c24old.result) AND c24old.authorization_id IS NULL AND c24old.dispatch_id IS NULL
 AND w.payload=c24old.payload AND w.payload=c24batch.payload AND w.payload_sha256=c24old.payload_sha256 AND w.payload_sha256=c24batch.payload_sha256
 AND w.payload_sha256='da8c38c23db1c04ceaaaedfb7b5ead1b43c18c1ee60b069696ba36d832c9da78'
 AND w.run_control_version=c24old.run_control_version AND w.definition_sha256=c24old.definition_sha256 AND w.revision=c24old.revision
 AND c24receipt.status='failed' AND c24receipt.finalized_at IS NOT NULL AND c24receipt.dispatch_count=0 AND c24receipt.charged_cost_usd=0
 AND NOT EXISTS(SELECT 1 FROM mission_narrative_internal.dispatch_attempts c24attempt WHERE c24attempt.receipt_id=c24receipt.id)
 AND NOT EXISTS(SELECT 1 FROM mission_narrative_internal.provider_authorizations c24auth WHERE c24auth.receipt_id=c24receipt.id)
 AND EXISTS(SELECT 1 FROM mission_narrative_internal.dispatch_audit c24audit WHERE c24audit.receipt_id=c24receipt.id AND c24audit.event_code='generic_count_overflow_terminal'
  AND c24audit.details->>'work_id'=c24old.id::text AND c24audit.details->>'receipt_id'=c24old.receipt_id::text AND c24audit.details->>'result_sha256'=c24old.result_sha256)
 AND EXISTS(SELECT 1 FROM mission_narrative_internal.dispatch_audit c24audit WHERE c24audit.receipt_id=c24receipt.id AND c24audit.event_code='c889_count_narration_reissued'
  AND c24audit.details->>'old_work_id'=c24old.id::text AND c24audit.details->>'work_id'=w.id::text AND c24audit.details->>'batch_id'=c24batch.id::text
  AND c24audit.details->>'payload_sha256'=w.payload_sha256 AND c24audit.details->>'generation_http_calls'='0'))) OR (
           w.dedupe_key='unified:'||batch.id||':staff-audit-requeue-1'
           AND EXISTS (
             SELECT 1 FROM mission_generic_owner.work_items prior
             WHERE prior.master_session_id=w.master_session_id
               AND prior.event_id=batch.id
               AND prior.authority_receipt_id=batch.id
               AND prior.kind='narration' AND prior.state='failed'
               AND prior.payload_sha256=w.payload_sha256
               AND prior.result->'failure_codes'='["MISSION_PROFILE_AUDIT_INVALID"]'::jsonb
           )
         )
       )
       AND batch.master_session_id=w.master_session_id
       AND batch.source_window_id IS NULL
       AND batch.decision_work_id IS NULL AND batch.decision IS NULL
       AND batch.composition_kind IN (
         'combat_defense_resolved','combat_exit','combat_resolved_no_pending')
       AND batch.next_round_id IS NULL
       AND w.encounter_id=batch.encounter_id
       AND w.step_key=batch.step_key AND w.step_key=encounter.step_key
       AND w.run_control_version=batch.run_control_version
       AND w.run_control_version=encounter.run_control_version
       AND w.payload=batch.payload AND w.payload_sha256=batch.payload_sha256
       AND w.payload->>'batch_id'=batch.id::text
       AND w.payload->>'composition_kind'=batch.composition_kind
       AND (batch.secondary_report_id IS NULL OR EXISTS (
         SELECT 1 FROM public.combat_v2_round_reports secondary_report
         JOIN public.combat_v2_rounds secondary_round
           ON secondary_round.id=secondary_report.round_id
         WHERE secondary_report.id=batch.secondary_report_id
           AND secondary_round.session_id=batch.encounter_id
       ))
   ) THEN RETURN 'native_combat_narration'; END IF;
   RETURN NULL;
 END IF;

 RETURN NULL;
END $function$
$targetddl$;
EXECUTE $targetddl$CREATE OR REPLACE FUNCTION mission_generic_owner.receipt_input_cap(p_receipt uuid, p_legacy_cap integer)
 RETURNS integer
 LANGUAGE plpgsql
 STABLE SECURITY DEFINER
 SET search_path TO ''
AS $function$
declare receipt mission_narrative_internal.dispatch_receipts;work mission_generic_owner.work_items;env jsonb;narrative_contract jsonb;
begin
 select * into strict receipt from mission_narrative_internal.dispatch_receipts where id=p_receipt;
 -- Other native events keep the exact capacity selected by their central policy.
 if receipt.event_kind<>'mission_generic_event' then return p_legacy_cap;end if;
 select * into strict work from mission_generic_owner.work_items
 where id=receipt.authority_receipt_id and dispatch_receipt_id=receipt.id;
 if receipt.renderer_version<>'mission-generic-runtime/1'
 or receipt.master_session_id<>work.master_session_id or receipt.request_key<>work.request_key
 then raise exception 'MUC_RECEIPT_SCOPE' using errcode='42501';end if;
 env:=jsonb_build_object('work_id',work.id,'master_session_id',work.master_session_id,'event_id',work.event_id,
 'authority_receipt_id',work.authority_receipt_id,'payload_sha256',work.payload_sha256,
 'definition_sha256',work.definition_sha256,'revision',work.revision);
 narrative_contract:=mission_public_owner.work_contract_v1(work.id);
 if narrative_contract is not null then env:=env||jsonb_build_object('narrative_admission',narrative_contract);end if;
 if receipt.envelope is distinct from env or receipt.envelope_sha256 is distinct from public.combat_v2_sha256(env)
 or receipt.authority_sha256 is distinct from public.combat_v2_sha256(env)
 then raise exception 'MUC_RECEIPT_BINDING' using errcode='42501';end if;
 if mission_generic_owner.c8_context24_scope_v1(work.id) then return 24000;end if;
 if exists(select 1 from mission_generic_owner.dispatch_admissions where master_session_id=work.master_session_id and c7_budget_enforced) then return p_legacy_cap;end if;
 return (mission_generic_owner.capacity()->>'input_capacity_bytes')::integer;
end $function$
$targetddl$;
EXECUTE $targetddl$CREATE OR REPLACE FUNCTION mission_generic_owner.c7_run_budget_v1(p_session uuid, p_next boolean, p_current_work uuid DEFAULT NULL::uuid)
 RETURNS jsonb
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO ''
AS $function$
declare a mission_generic_owner.dispatch_admissions;g mission_generic_owner.provider_policy;
 pol mission_narrative_internal.runtime_policy;spent numeric;calls bigint;bound numeric;capcost numeric;capcalls integer;ok boolean;
begin
 perform mission_ai_board_owner.service_only();
 -- C9: freeze policy DML through proof, Native reserve and authorization.
 LOCK TABLE mission_narrative_internal.runtime_policy IN SHARE MODE;
 -- Same admission/policy locks at claim and all subsequent boundaries.
 select * into strict pol from mission_narrative_internal.runtime_policy where singleton;
 select * into strict a from mission_generic_owner.dispatch_admissions where master_session_id=p_session for update;
 select * into strict g from mission_generic_owner.provider_policy where singleton for share;
 if not a.c7_budget_enforced then return jsonb_build_object('enforced',false,'allowed',true,'remaining_calls',a.call_limit-a.calls_authorized);end if;
 if a.c7_budget_qualification_sha256 is null or a.call_limit<1 or a.cost_budget_usd<=0
 then raise exception 'MGPG_C7_BUDGET_UNQUALIFIED' using errcode='55000';end if;
 IF p_session='ce7bc0e0-c8ed-48dd-a9ec-58c02022a7b9'::uuid AND mission_generic_owner.c8_context24_scope_v1('48e1bdcd-f044-be8c-1923-54d38e7e822c'::uuid) THEN pol.max_input_tokens:=24000;pol.max_output_tokens:=20000;END IF;
 bound:=(pol.max_input_tokens*pol.input_usd_million+pol.max_output_tokens*pol.output_usd_million)/1000000;
 capcost:=least(g.run_budget_usd,a.cost_budget_usd,coalesce(pol.run_budget_usd,g.run_budget_usd));
 capcalls:=2*least(g.max_run_calls,a.call_limit);
 -- A claimed Native work is already a logical reservation, even before reserve HTTP.
 -- Its bound is represented by existing work state; a receipt/attempt is not counted twice.
 select coalesce(sum(case when d.status in('success','fallback','unknown_billable')
   then coalesce(d.charged_cost_usd,d.upper_bound_cost_usd,0)
   when wi.state in('claimed','authorized','provider_started') then greatest(coalesce(d.upper_bound_cost_usd,0),bound)
   else coalesce(d.upper_bound_cost_usd,0) end + case when ca.details is not null then (ca.details->>'count_upper_cost_usd')::numeric when wi.state in('claimed','authorized','provider_started') then coalesce(a.c8_count_upper_cost_usd,0) else 0 end),0),
 coalesce(sum(case when wi.state in('claimed','authorized','provider_started') then 2 else (case when ca.details is not null then 1 else 0 end)+(case when d.upper_bound_cost_usd is not null or exists(select 1 from mission_narrative_internal.dispatch_attempts da where da.receipt_id=d.id) then 1 else 0 end) end),0)
 into spent,calls from mission_generic_owner.work_items wi
 left join mission_narrative_internal.dispatch_receipts d on d.id=wi.dispatch_receipt_id
 left join mission_narrative_internal.dispatch_audit ca on ca.receipt_id=d.id and ca.event_code='c8_count_started'
 where wi.master_session_id=p_session and (p_current_work is null or wi.id<>p_current_work)
 and (wi.dispatch_receipt_id is not null or wi.state in('claimed','authorized','provider_started'));
 calls:=greatest(calls,a.calls_authorized-case when p_current_work is not null and exists(
  select 1 from mission_generic_owner.work_items wi where wi.id=p_current_work and wi.authorization_id is not null) then 1 else 0 end);
 ok:=a.enabled and g.enabled and a.c8_count_qualification_sha256 is not null and a.c8_count_upper_cost_usd is not null and bound>=0 and bound<'Infinity'::numeric and capcost>0 and capcalls>0
 and spent+case when p_next then bound+a.c8_count_upper_cost_usd else 0 end<=capcost
 and calls+case when p_next then 2 else 0 end<=capcalls;
 return jsonb_build_object('enforced',true,'allowed',ok,'remaining_calls',greatest(0,capcalls-calls),
 'spent_usd',spent,'upper_bound_next_usd',bound,'call_limit',capcalls,'cost_limit_usd',capcost,
 'qualification_sha256',a.c7_budget_qualification_sha256,'count_upper_cost_usd',a.c8_count_upper_cost_usd,'count_qualification_sha256',a.c8_count_qualification_sha256,'http_slots_per_generation',2);
end $function$
$targetddl$;
EXECUTE $targetddl$CREATE OR REPLACE FUNCTION public.mission_generic_dispatch_claim_v1(p_user uuid, p_request jsonb)
 RETURNS jsonb
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO ''
AS $function$
declare w mission_generic_owner.work_items;a mission_generic_owner.dispatch_admissions;pol mission_narrative_internal.runtime_policy;
 d mission_narrative_internal.dispatch_receipts;
 dr uuid;env jsonb;fp text;limits jsonb;staff_calls bigint; narrative_contract jsonb;c7_budget jsonb;
begin
 perform mission_ai_board_owner.service_only();
 -- C9: freeze policy DML through proof, Native reserve and authorization.
 LOCK TABLE mission_narrative_internal.runtime_policy IN SHARE MODE;
 perform mission_generic_owner.dispatch_user((p_request->>'master_session_id')::uuid,p_user);
 if (p_request->>'master_session_id')='b70b23cf-bad8-475d-a56a-d9c549e35d84' then
   raise exception 'MRS_STAFF_SUNA_TICK_PAUSED' using errcode='55000';
 end if;
 perform 1 from mission_generic_owner.role_window_cursors
   where master_session_id=(p_request->>'master_session_id')::uuid for update;
 perform 1 from public.master_v2_sessions where id=(p_request->>'master_session_id')::uuid for update;
 select * into strict w from mission_generic_owner.work_items where master_session_id=(p_request->>'master_session_id')::uuid
 and event_id=(p_request->>'event_id')::uuid and request_key=(p_request->>'request_key')::uuid and revision=(p_request->>'expected_revision')::bigint for update;
 if mission_generic_owner.count_overflow_terminal_v1(w.id,p_user) then return jsonb_build_object('state','failed','granted_now',false);end if;
 if w.state='claimed' and w.master_session_id='ce7bc0e0-c8ed-48dd-a9ec-58c02022a7b9'::uuid then return jsonb_build_object('state','claimed','granted_now',false);end if;
 perform mission_generic_owner.role_dispatch_assert_v4(w.id);
 IF EXISTS(SELECT 1 FROM public.master_v2_sessions s726 WHERE s726.id=w.master_session_id AND s726.owner_kind='ai_service' AND s726.location_id='0b85f354-9cdb-47e1-baf9-3d266bb7e06b'::uuid AND (EXISTS(SELECT 1 FROM mission_generic_owner.flow_staff_sessions f726 WHERE f726.master_session_id=s726.id AND f726.enabled) OR EXISTS(SELECT 1 FROM mission_factory_owner.quest_run_sources q726 WHERE q726.session_id=s726.id AND q726.availability_scope='staff' AND q726.execution_context='staff_simulation'))) AND NOT mission_academy_owner.staff_carrier_runtime(w.master_session_id) AND NOT mission_generic_owner.c726_factory_staff_runtime_v1(w.master_session_id) THEN RAISE EXCEPTION 'C726_FACTORY_STAFF_SCOPE_CLOSED' USING ERRCODE='42501';END IF;

 if w.state='failed' and w.kind='choice' and public.combat_v2_is_service()
   and mission_academy_owner.staff_carrier_runtime(w.master_session_id) then
   env:=mission_generic_owner.staff_cached_choice_recover(w.id);
   if env->>'state'='completed' then
     return jsonb_build_object('state','completed','granted_now',false);
   end if;
 end if;
 if w.state='claimed' and w.lease_expires_at<=clock_timestamp() then
  select * into d from mission_narrative_internal.dispatch_receipts where id=w.dispatch_receipt_id for update;
  if found and w.authorization_id is null and w.dispatch_id is null
   and d.status='claimed' and d.dispatch_count=0 and d.charged_cost_usd=0
   and d.upper_bound_cost_usd is null and d.master_session_id=w.master_session_id
   and d.authority_receipt_id=w.id and d.event_kind='mission_generic_event'
   and d.renderer_version='mission-generic-runtime/1' and d.request_key=w.request_key
   and not exists(select 1 from mission_narrative_internal.dispatch_attempts where receipt_id=d.id)
   and not exists(select 1 from mission_narrative_internal.provider_authorizations where receipt_id=d.id)
   and not exists(select 1 from mission_narrative_internal.dispatch_audit where receipt_id=d.id and event_code='c8_count_started')
  then
   update mission_narrative_internal.dispatch_receipts set updated_at=clock_timestamp() where id=d.id;
   insert into mission_narrative_internal.dispatch_audit(receipt_id,event_code,details)
   values(d.id,'generic_pre_provider_claim_reissued',jsonb_build_object('work_id',w.id,
    'provider_calls',0,'charged_cost_usd',0,'expired_lease_id',w.lease_id));
   update mission_generic_owner.work_items set state='ready',
    lease_id=null,lease_expires_at=null where id=w.id returning * into w;
   dr:=d.id;
  end if;
 end if;
 if w.state<>'ready' then return jsonb_build_object('state',w.state,'granted_now',false);end if;
 c7_budget:=mission_generic_owner.c7_run_budget_v1(w.master_session_id,true,null);
 if c7_budget->>'allowed'='false' then
  perform mission_generic_owner.c7_run_budget_stop_v1(w.master_session_id);
  return jsonb_build_object('state','ready','granted_now',false,'reason_code','MGPG_C7_RUN_BUDGET_STOP','provider_calls_remaining',0);
 end if;
 perform mission_generic_owner.work_assert(w);
 select * into strict a from mission_generic_owner.dispatch_admissions where master_session_id=w.master_session_id for share;
 select * into strict pol from mission_narrative_internal.runtime_policy where singleton for share;
 perform mission_generic_owner.provider_ready(w.id);
 -- Byte transport limits remain independent from Native token policy.
 pol.max_input_tokens:=(mission_generic_owner.capacity()->>'input_capacity_bytes')::integer;
 if not a.enabled or (not mission_academy_owner.staff_carrier_runtime(w.master_session_id) and a.calls_authorized>=a.call_limit) or (not pol.enabled and w.master_session_id<>'93d78313-abde-4087-9eb7-7b96bc0fa089'::uuid and not mission_academy_owner.staff_carrier_runtime(w.master_session_id) and not mission_generic_owner.c726_factory_staff_runtime_v1(w.master_session_id)) or pol.model<>'gpt-6-luna' or pol.reasoning_effort<>'high' or pol.store
 then raise exception 'MGD_PROVIDER_CLOSED';end if;
 if mission_academy_owner.staff_carrier_runtime(w.master_session_id) then
  select count(*) into staff_calls
  from mission_narrative_internal.dispatch_receipts receipt
  join public.master_v2_sessions s on s.id=receipt.master_session_id
  where receipt.event_kind='mission_generic_event' and receipt.renderer_version='mission-generic-runtime/1'
    and receipt.created_at>=clock_timestamp()-interval '30 days'
    and s.location_id='0b85f354-9cdb-47e1-baf9-3d266bb7e06b'::uuid and s.owner_kind='ai_service'
    and exists(select 1 from mission_narrative_internal.dispatch_attempts t where t.receipt_id=receipt.id);
  if staff_calls>=1000 then raise exception 'MGPG_STAFF_ROLLING_BUDGET_EXHAUSTED';end if;
 end if;
 limits:=jsonb_build_object('provider_calls_remaining',case when c7_budget->>'enforced'='true' then least((c7_budget->>'remaining_calls')::integer/2,a.call_limit-a.calls_authorized) when staff_calls is null then a.call_limit-a.calls_authorized else 1000-staff_calls end,'max_output_tokens',least(20000,pol.max_output_tokens),
  'max_input_bytes',case when w.kind='director' and (mission_academy_owner.staff_carrier_runtime(w.master_session_id) OR mission_generic_owner.c726_factory_staff_runtime_v1(w.master_session_id)) then 65536 else least(49152,pol.max_input_tokens) end,'max_request_bytes',case when w.kind='narration' and (mission_academy_owner.staff_carrier_runtime(w.master_session_id) OR mission_generic_owner.c726_factory_staff_runtime_v1(w.master_session_id)) then 131072 when w.kind='director' and (mission_academy_owner.staff_carrier_runtime(w.master_session_id) OR mission_generic_owner.c726_factory_staff_runtime_v1(w.master_session_id)) then 65536 else least(65536,pol.max_input_tokens) end,
  'transport_max_chars',5000,'provider_timeout_ms',120000);
 if octet_length(w.payload::text)>(limits->>'max_input_bytes')::integer then raise exception 'MGD_CONTEXT_OVERFLOW';end if;
 narrative_contract:=mission_public_owner.work_contract_issue_v1(w.id);
 env:=jsonb_build_object('work_id',w.id,'master_session_id',w.master_session_id,'event_id',w.event_id,'authority_receipt_id',w.authority_receipt_id,
  'payload_sha256',w.payload_sha256,'definition_sha256',w.definition_sha256,'revision',w.revision);
 if narrative_contract is not null then env:=env||jsonb_build_object('narrative_admission',narrative_contract);end if;
 fp:=mission_internal.fingerprint(p_request);
 if dr is null then
 insert into mission_narrative_internal.dispatch_receipts(master_session_id,authority_receipt_id,event_kind,renderer_version,request_key,
  request_fingerprint,authority_sha256,envelope,envelope_sha256,status)
 values(w.master_session_id,w.id,'mission_generic_event','mission-generic-runtime/1',w.request_key,fp,
  public.combat_v2_sha256(env),env,public.combat_v2_sha256(env),'claimed') returning id into dr;
 end if;
 update mission_generic_owner.work_items set state='claimed',dispatch_receipt_id=dr,lease_id=gen_random_uuid(),
  lease_expires_at=clock_timestamp()+interval '180 seconds' where id=w.id returning * into w;
 return jsonb_build_object('state','claimed','granted_now',true,'work',jsonb_build_object('schema_version','mission-generic-work/1',
  'work_id',w.id,'master_session_id',w.master_session_id,'event_id',w.event_id,'request_key',w.request_key,'revision',w.revision,
  'step_key',w.step_key,'run_control_version',w.run_control_version,'definition_sha256',w.definition_sha256,
  'encounter_id',w.encounter_id,'authority_receipt_id',w.authority_receipt_id,'kind',w.kind,'lease_id',w.lease_id,
  'server_now',clock_timestamp(),'lease_expires_at',w.lease_expires_at,'payload_sha256',w.payload_sha256,'payload',w.payload,'limits',limits,
  'narrative_admission',narrative_contract,'narrative_admission_sha256',case when narrative_contract is not null then public.combat_v2_sha256(narrative_contract) end,
  'provider_input_contract',case when a.c7_budget_enforced then case when mission_generic_owner.c8_context24_scope_v1(w.id) then jsonb_build_object('schema_version','mission-generic-provider-input/3','input_tokens_limit',24000,'policy_version',pol.policy_version,'http_calls_per_generation',2,'scope',jsonb_build_object('schema_version','c889-context24-work-scope/1','session_id',w.master_session_id,'work_id',w.id,'batch_id',w.authority_receipt_id,'old_work_id','c88958e7-8983-4332-a14e-095076f967f4','financial_qualification_sha256',a.c8_count_qualification_sha256,'count_reserve_usd','0.0124','generation_reserve_usd','0.0124'),'pricing',jsonb_build_object('model',pol.model,'reasoning_effort',pol.reasoning_effort,'store',pol.store,'max_output_tokens',20000,'input_usd_million',pol.input_usd_million,'output_usd_million',pol.output_usd_million,'count_upper_cost_usd','0.0124','generation_upper_cost_usd','0.0124'),'byte_bounds',jsonb_build_object('max_input_bytes',limits->'max_input_bytes','max_request_bytes',limits->'max_request_bytes')) else jsonb_build_object('schema_version','mission-generic-provider-input/1','input_tokens_limit',(select max_input_tokens from mission_narrative_internal.runtime_policy where singleton),'policy_version',pol.policy_version,'http_calls_per_generation',2)  end else null end,
  'narrative_profile',case when narrative_contract is not null then narrative_contract->>'editorial_profile' when w.kind in('narration','director') and (mission_academy_owner.staff_carrier_runtime(w.master_session_id) OR mission_generic_owner.c726_factory_staff_runtime_v1(w.master_session_id))
    then 'cinematic_master_1' else 'legacy' end) - case when not a.c7_budget_enforced then 'provider_input_contract' else '__no_key__' end);
end $function$
$targetddl$;
EXECUTE $targetddl$CREATE OR REPLACE FUNCTION public.mission_generic_input_count_start_v1(p_work uuid, p_lease uuid, p_payload_text text, p_payload_sha text)
 RETURNS jsonb
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO ''
AS $function$
DECLARE w mission_generic_owner.work_items;r mission_narrative_internal.dispatch_receipts;a mission_generic_owner.dispatch_admissions;pol mission_narrative_internal.runtime_policy;payload jsonb;projection jsonb;snap jsonb;details jsonb;old_details jsonb;measurement uuid:=gen_random_uuid();request_limit integer;count_quota jsonb;count_ticket uuid;count_staff boolean;
BEGIN
 perform mission_ai_board_owner.service_only();
 -- C9: freeze policy DML through proof, Native reserve and authorization.
 LOCK TABLE mission_narrative_internal.runtime_policy IN SHARE MODE;
 select * into strict pol from mission_narrative_internal.runtime_policy where singleton;

 -- Same scene-before-work order as Native claim/authorize.
 perform 1 from mission_generic_owner.role_window_cursors where master_session_id=(select master_session_id from mission_generic_owner.work_items where id=p_work) for update;
 perform 1 from public.master_v2_sessions where id=(select master_session_id from mission_generic_owner.work_items where id=p_work) for update; select * into strict w from mission_generic_owner.work_items where id=p_work for update;
 select * into strict a from mission_generic_owner.dispatch_admissions where master_session_id=w.master_session_id for update;
 select * into strict r from mission_narrative_internal.dispatch_receipts where id=w.dispatch_receipt_id for update;
 pol.max_input_tokens:=(mission_generic_owner.c8_policy_snapshot_v1(w.id)->>'max_input_tokens')::integer;
 perform mission_generic_owner.work_assert(w);perform mission_generic_owner.role_dispatch_assert_v4(w.id);perform mission_generic_owner.provider_ready(w.id);
 IF EXISTS(SELECT 1 FROM public.master_v2_sessions s726 WHERE s726.id=w.master_session_id AND s726.owner_kind='ai_service' AND s726.location_id='0b85f354-9cdb-47e1-baf9-3d266bb7e06b'::uuid AND (EXISTS(SELECT 1 FROM mission_generic_owner.flow_staff_sessions f726 WHERE f726.master_session_id=s726.id AND f726.enabled) OR EXISTS(SELECT 1 FROM mission_factory_owner.quest_run_sources q726 WHERE q726.session_id=s726.id AND q726.availability_scope='staff' AND q726.execution_context='staff_simulation'))) AND NOT mission_academy_owner.staff_carrier_runtime(w.master_session_id) AND NOT mission_generic_owner.c726_factory_staff_runtime_v1(w.master_session_id) THEN RAISE EXCEPTION 'C726_FACTORY_STAFF_SCOPE_CLOSED' USING ERRCODE='42501';END IF;

 if not a.c7_budget_enforced or a.c8_count_upper_cost_usd is null or a.c8_count_qualification_sha256 is null then raise exception 'C8_COUNT_TARIFF_UNQUALIFIED' using errcode='55000';end if;
 if w.state<>'claimed' or w.lease_id is distinct from p_lease or w.lease_expires_at<=clock_timestamp() or r.status<>'claimed' or r.authority_receipt_id<>w.id or r.master_session_id<>w.master_session_id or r.request_key<>w.request_key or r.event_kind<>'mission_generic_event' or r.renderer_version<>'mission-generic-runtime/1' or r.dispatch_count<>0 or w.authorization_id is not null or w.dispatch_id is not null or exists(select 1 from mission_narrative_internal.dispatch_attempts where receipt_id=r.id) or exists(select 1 from mission_narrative_internal.provider_authorizations where receipt_id=r.id) then raise exception 'C8_COUNT_SCOPE' using errcode='40001';end if;
 if p_payload_text is null or p_payload_sha !~ '^[0-9a-f]{64}$' or p_payload_sha is distinct from encode(extensions.digest(convert_to(p_payload_text,'UTF8'),'sha256'),'hex') then raise exception 'C8_COUNT_REQUEST_HASH' using errcode='22023';end if;
 payload:=p_payload_text::jsonb;
 request_limit:=case when w.kind='narration' and (mission_academy_owner.staff_carrier_runtime(w.master_session_id) OR mission_generic_owner.c726_factory_staff_runtime_v1(w.master_session_id)) then 131072 when w.kind='director' and (mission_academy_owner.staff_carrier_runtime(w.master_session_id) OR mission_generic_owner.c726_factory_staff_runtime_v1(w.master_session_id)) then 65536 else least(65536,(mission_generic_owner.capacity()->>'input_capacity_bytes')::integer) end;
 if octet_length(p_payload_text)>request_limit or not(payload ?& array['model','input','reasoning','text','store','max_output_tokens']) or payload-'model'-'input'-'reasoning'-'text'-'store'-'max_output_tokens'<>'{}'::jsonb or payload->>'model' is distinct from pol.model or payload->'reasoning' is distinct from jsonb_build_object('effort',pol.reasoning_effort) or payload->'store' is distinct from 'false'::jsonb or payload->'max_output_tokens' is distinct from to_jsonb(pol.max_output_tokens) or jsonb_typeof(payload->'input')<>'array' or jsonb_typeof(payload->'text')<>'object' then raise exception 'C8_COUNT_REQUEST_POLICY' using errcode='22023';end if;
 snap:=mission_generic_owner.c8_policy_snapshot_v1(w.id);projection:=payload-'store'-'max_output_tokens';
 select da.details into old_details from mission_narrative_internal.dispatch_audit da where da.receipt_id=r.id and da.event_code='c8_count_started';
 if found then
  if old_details->>'generation_request_sha256' is distinct from p_payload_sha or old_details->>'lease_id' is distinct from p_lease::text then raise exception 'C8_COUNT_REPLAY_CONFLICT' using errcode='40001';end if;
  return jsonb_build_object('schema_version','mission-generic-count-start/1','work_id',w.id,'measurement_id',old_details->>'measurement_id','granted_now',false,'generation_request_sha256',p_payload_sha,'count_request_sha256',old_details->>'count_request_sha256','model',old_details#>>'{policy_snapshot,model}','policy_version',(old_details#>>'{policy_snapshot,policy_version}')::integer,'max_input_tokens',(old_details#>>'{policy_snapshot,max_input_tokens}')::integer,'max_output_tokens',(old_details#>>'{policy_snapshot,max_output_tokens}')::integer,'policy_snapshot_sha256',old_details->>'policy_snapshot_sha256','count_http_calls',1,'generation_http_calls',0);
 end if;
 if (mission_generic_owner.c7_run_budget_v1(w.master_session_id,true,w.id)->>'allowed')='false' then raise exception 'MGPG_C7_RUN_BUDGET_STOP' using errcode='55000';end if;
 PERFORM mission_generic_owner.c758_ordinary_budget_assert_v1(w.master_session_id,w.id);
 count_staff:=(mission_academy_owner.staff_carrier_runtime(w.master_session_id) OR mission_generic_owner.c726_factory_staff_runtime_v1(w.master_session_id) OR mission_generic_owner.c758_admission_proof_v1(w.master_session_id));
 if count_staff then
  count_quota:=staff_ai_quota_private.reserve('mission_generic_ai',r.id,2,w.master_session_id,pol.model,a.c8_count_upper_cost_usd);
  if count_quota->>'granted_now' IS DISTINCT FROM 'true' OR count_quota->>'state' IS DISTINCT FROM 'reserved' OR count_quota->>'may_send_http' IS DISTINCT FROM 'false' OR coalesce(count_quota->>'call_id','') !~ '^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$' then raise exception 'C748_COUNT_QUOTA_FRESH_RESERVATION_REQUIRED' using errcode='55000';end if;
  count_ticket:=(count_quota->>'call_id')::uuid;count_quota:=staff_ai_quota_private.mark_sent(count_ticket);
  if count_quota->>'may_send_http' IS DISTINCT FROM 'true' OR count_quota->>'state' IS DISTINCT FROM 'sent' OR count_quota->>'call_id' IS DISTINCT FROM count_ticket::text then raise exception 'C748_COUNT_QUOTA_SENT_NO_HTTP' using errcode='55000';end if;
 end if;
 details:=jsonb_build_object('work_id',w.id,'lease_id',p_lease,'measurement_id',measurement,'generation_request_sha256',p_payload_sha,'generation_request_bytes',octet_length(p_payload_text),'generation_request_text',p_payload_text,'count_projection',projection,'count_request_sha256',public.combat_v2_sha256(projection),'policy_snapshot',snap,'policy_snapshot_sha256',public.combat_v2_sha256(snap),'count_upper_cost_usd',a.c8_count_upper_cost_usd,'count_qualification_sha256',a.c8_count_qualification_sha256,'count_http_calls_reserved',1,'generation_http_calls_reserved',1,'shared_count_ticket',count_ticket,'shared_count_scope',w.master_session_id,'shared_count_source',r.id,'shared_count_call_no',CASE WHEN count_staff THEN 2 ELSE NULL END);
 insert into mission_narrative_internal.dispatch_audit(receipt_id,event_code,details) values(r.id,'c8_count_started',details);
 return jsonb_build_object('schema_version','mission-generic-count-start/1','work_id',w.id,'measurement_id',measurement,'granted_now',true,'generation_request_sha256',p_payload_sha,'count_request_sha256',public.combat_v2_sha256(projection),'model',pol.model,'policy_version',pol.policy_version,'max_input_tokens',pol.max_input_tokens,'max_output_tokens',pol.max_output_tokens,'policy_snapshot_sha256',public.combat_v2_sha256(snap),'count_http_calls',0,'generation_http_calls',0);
END $function$
$targetddl$;
EXECUTE $targetddl$CREATE OR REPLACE FUNCTION mission_generic_owner.c726_factory_staff_runtime_v1(p_session uuid)
 RETURNS boolean
 LANGUAGE sql
 STABLE SECURITY DEFINER
 SET search_path TO ''
AS $function$
 SELECT EXISTS(
 SELECT 1
 FROM public.master_v2_sessions ss
 JOIN public.locations ll ON ll.id=ss.location_id
 LEFT JOIN mission_generic_owner.flow_staff_sessions fs ON fs.master_session_id=ss.id AND fs.enabled
 JOIN mission_generic_owner.run_bindings rb ON rb.master_session_id=ss.id
 JOIN mission_generic_owner.dispatch_admissions da ON da.master_session_id=ss.id
 JOIN mission_factory_owner.c464_control cc ON cc.singleton
 JOIN mission_factory_owner.editor_release_readiness rr ON rr.singleton
 JOIN mission_factory_owner.provider_authoring_runtime fr ON fr.singleton
 JOIN mission_factory_owner.provider_authoring_admissions fa ON EXISTS(SELECT 1 FROM public.master_v2_participants owner_mp JOIN public.characters owner_ch ON owner_ch.id=owner_mp.character_id AND owner_ch.user_id=owner_mp.user_id_snapshot WHERE owner_mp.session_id=ss.id AND owner_mp.engagement_state='attivo' AND owner_ch.user_id=fa.actor_user)
 JOIN public.profiles owner_profile ON owner_profile.id=fa.actor_user AND owner_profile.role IN('admin','master')
 JOIN mission_narrative_internal.runtime_policy np ON np.singleton
 JOIN staff_ai_quota_private.runtime qr ON qr.singleton
 WHERE ss.id=p_session AND ss.owner_kind='ai_service' AND ss.closed_at IS NULL
 AND ss.location_id='0b85f354-9cdb-47e1-baf9-3d266bb7e06b'::uuid AND ll.is_test AND ll.is_active
 AND fa.actor_user IN('f0856d53-83a6-4de0-bc0c-12c87916e665'::uuid,'b4952ed5-5ce0-49c0-9f2b-8fd5dcd89b4b'::uuid)
 AND fa.enabled AND fa.location_id=ss.location_id AND fa.expires_at>statement_timestamp() AND fa.release_sha256=rr.revision_sha256
 AND public._combat_presente(fa.actor_user,ss.location_id) IS TRUE
 AND (fs.master_session_id IS NOT NULL OR EXISTS(SELECT 1 FROM mission_factory_owner.quest_run_sources source_q JOIN mission_factory_owner.quest_episodes source_ep ON source_ep.id=source_q.episode_id WHERE source_q.session_id=ss.id AND source_q.location_id=ss.location_id AND source_q.availability_scope='staff' AND source_q.execution_context='staff_simulation' AND source_q.staff_release_sha256=rr.revision_sha256 AND source_q.source_sha256=source_ep.source_sha256 AND source_ep.source_sha256=mission_factory_owner.sha(source_ep.source_document) AND rb.snapshot IS NOT DISTINCT FROM mission_factory_owner.quest_binding_projection_v1(source_q)))
 AND rb.snapshot_sha256=mission_internal.fingerprint(rb.snapshot)
 AND da.enabled AND da.call_limit=14 AND da.calls_authorized BETWEEN 0 AND da.call_limit
 AND da.cost_budget_usd=0.3136 AND da.c7_budget_enforced IS TRUE
 AND (da.c8_count_upper_cost_usd=0.0112 OR ((ss.id='ce7bc0e0-c8ed-48dd-a9ec-58c02022a7b9'::uuid AND mission_generic_owner.c8_context24_scope_v1('48e1bdcd-f044-be8c-1923-54d38e7e822c'::uuid)) AND da.c8_count_upper_cost_usd=0.0124)) AND da.c8_count_qualification_sha256~'^[a-f0-9]{64}$'
 AND(da.c7_budget_qualification_sha256=encode(extensions.digest(convert_to(jsonb_build_object('schema_version','c717-native-staff-admission-proof/1','count_contract_sha256','b242ee7fcc6655fa951e8697acfbee4d6ba92b42b177fcbcf6a9b08d004661b2','session_id',ss.id,'binding_sha256',rb.snapshot_sha256,'count_qualification_sha256',da.c8_count_qualification_sha256,'generation_limit',14,'http_limit',28,'cost','0.3136')::text,'UTF8'),'sha256'),'hex')
 OR (ss.id='ce7bc0e0-c8ed-48dd-a9ec-58c02022a7b9'::uuid AND mission_generic_owner.c8_context24_scope_v1('48e1bdcd-f044-be8c-1923-54d38e7e822c'::uuid)) OR(mission_generic_owner.c758_admission_proof_v1(ss.id)IS TRUE AND EXISTS(
 SELECT 1 FROM mission_generic_owner.ordinary_economic_qa_receipts_v1 eq
 WHERE eq.enabled AND eq.expires_at>statement_timestamp() AND eq.release_sha256=rr.revision_sha256 AND eq.location_id=ss.location_id
 AND eq.qualification_sha256=mission_factory_owner.sha(eq.qualification_payload)
 AND eq.qualification_sha256=mission_generic_owner.c777_execution_context_v1(ss.id,false)->>'qa_receipt_sha256'
 AND eq.qualification_payload->>'schema_version'='c777-candidate-qualification/2'
 AND eq.qualification_payload->>'economic_mode'='ordinary'AND eq.qualification_payload->>'resource_scope'='staff_simulation'
 AND eq.qualification_payload->>'review_ref'=rr.independent_review_ref
 AND eq.qualification_payload->>'count_qualification_sha256'=da.c8_count_qualification_sha256
 AND eq.qualification_payload->>'economic_contract_sha256'='297861ae85a2e237065835141d0eb734620ae0145d0d834d4ca7d4e6478e3e6b'
 AND eq.source_sha256=mission_generic_owner.c777_execution_context_v1(ss.id,false)->>'source_sha256'
 AND fa.actor_user=ANY(eq.actor_ids))))
 AND (SELECT count(*) FROM public.master_v2_participants mp WHERE mp.session_id=ss.id AND mp.engagement_state='attivo') BETWEEN 1 AND 4
 AND NOT EXISTS(SELECT 1 FROM public.master_v2_participants mp LEFT JOIN public.characters ch ON ch.id=mp.character_id LEFT JOIN public.profiles pg_role ON pg_role.id=ch.user_id WHERE mp.session_id=ss.id AND mp.engagement_state='attivo' AND (ch.id IS NULL OR ch.user_id IS DISTINCT FROM mp.user_id_snapshot OR ch.user_id IS NULL OR ch.user_id NOT IN('f0856d53-83a6-4de0-bc0c-12c87916e665'::uuid,'b4952ed5-5ce0-49c0-9f2b-8fd5dcd89b4b'::uuid) OR pg_role.role IS NULL OR pg_role.role NOT IN('admin','master') OR public._combat_presente(ch.user_id,ss.location_id) IS DISTINCT FROM TRUE))
 AND cc.complete AND cc.runtime_enabled AND cc.expires_at>statement_timestamp()
 AND cc.source_sha256='4f58bb7fb726c870a489b9db6ea088719e0b2e6153b2b3f98bf6d8be928e1b50'
 AND cc.root_authority_sha256~'^[a-f0-9]{64}$'
 AND rr.scope='staff' AND rr.state='enabled' AND rr.revision_sha256=rr.observed_revision_sha256
 AND rr.staff_guards_verified AND rr.published_assets_verified
 AND encode(extensions.digest(convert_to(rr.canonical_preimage,'UTF8'),'sha256'),'hex')=rr.revision_sha256
 AND cc.release_sha256=rr.revision_sha256
 AND cc.review_sha256=rr.canonical_preimage::jsonb#>>'{config,staff_finite_ia_budget,composed_review_sha256}'
 AND rr.independent_review_ref=rr.canonical_preimage::jsonb#>>'{config,staff_finite_ia_budget,composed_review_ref}'
 AND (rr.canonical_preimage::jsonb#>>'{config,staff_finite_ia_budget,count_reserve_contract_sha256}'='b242ee7fcc6655fa951e8697acfbee4d6ba92b42b177fcbcf6a9b08d004661b2' OR ((ss.id='ce7bc0e0-c8ed-48dd-a9ec-58c02022a7b9'::uuid AND mission_generic_owner.c8_context24_scope_v1('48e1bdcd-f044-be8c-1923-54d38e7e822c'::uuid)) AND rr.canonical_preimage::jsonb#>>'{config,staff_finite_ia_budget,count_reserve_contract_sha256}'='13421de48d6dddbb8c6628fd6a294b90746b3d2b79e56bf617456a5d3cc8e090'))
 AND rr.canonical_preimage::jsonb#>>'{config,staff_finite_ia_budget,dispatch_admit_body_md5}'=(SELECT md5(pp.prosrc) FROM pg_catalog.pg_proc pp WHERE pp.oid='mission_generic_owner.dispatch_admit(uuid,integer,numeric)'::regprocedure)
 AND fr.enabled AND fr.qualified AND fr.edge_qualified AND fr.release_sha256=rr.revision_sha256
 AND (fr.count_upper_cost_usd=0.0112 OR ((ss.id='ce7bc0e0-c8ed-48dd-a9ec-58c02022a7b9'::uuid AND mission_generic_owner.c8_context24_scope_v1('48e1bdcd-f044-be8c-1923-54d38e7e822c'::uuid)) AND fr.count_upper_cost_usd=0.0124)) AND fr.count_qualification_sha256=da.c8_count_qualification_sha256
 AND np.policy_version=2 AND np.model='gpt-6-luna' AND np.reasoning_effort='high' AND np.store IS FALSE
 AND np.max_input_tokens=12000 AND np.max_output_tokens=20000 AND np.input_usd_million=0.1 AND np.output_usd_million=0.5
 AND qr.enabled AND NOT qr.admissions_paused
 );
$function$
$targetddl$;
EXECUTE $targetddl$CREATE OR REPLACE FUNCTION mission_generic_owner.count_overflow_terminal_v1(p_work uuid,p_user uuid)
RETURNS boolean LANGUAGE plpgsql SECURITY DEFINER SET search_path TO '' AS $function$
DECLARE w mission_generic_owner.work_items;d mission_narrative_internal.dispatch_receipts;st jsonb;pr jsonb;c staff_ai_quota_private.calls;res jsonb;out_receipt uuid;expected_input integer:=12000;expected_reserve numeric:=0.0112;
BEGIN
 PERFORM mission_ai_board_owner.service_only();
 SELECT * INTO STRICT w FROM mission_generic_owner.work_items WHERE id=p_work FOR UPDATE;
 IF w.master_session_id<>'ce7bc0e0-c8ed-48dd-a9ec-58c02022a7b9'::uuid OR w.kind NOT IN('director','narration') THEN RETURN false;END IF;
 PERFORM mission_generic_owner.dispatch_user(w.master_session_id,p_user);
 IF NOT EXISTS(SELECT 1 FROM public.profiles p WHERE p.id=p_user AND p.role IN('admin','master'))
 OR p_user NOT IN('f0856d53-83a6-4de0-bc0c-12c87916e665'::uuid,'b4952ed5-5ce0-49c0-9f2b-8fd5dcd89b4b'::uuid)
 OR NOT EXISTS(SELECT 1 FROM public.master_v2_sessions m WHERE m.id=w.master_session_id AND m.owner_kind='ai_service' AND m.location_id='0b85f354-9cdb-47e1-baf9-3d266bb7e06b'::uuid AND m.closed_at IS NULL)
 OR EXISTS(SELECT 1 FROM mission_factory_owner.quest_run_sources WHERE session_id=w.master_session_id)
 OR NOT EXISTS(SELECT 1 FROM mission_generic_owner.run_bindings rb WHERE rb.master_session_id=w.master_session_id AND rb.snapshot_sha256='49817335c60ce9d4b47bc5d81c6950f622635c7fb232264ab54736349124f567' AND rb.snapshot_sha256=mission_internal.fingerprint(rb.snapshot)) THEN RETURN false;END IF;

 IF w.kind='narration' AND NOT (EXISTS(
 SELECT 1 FROM mission_generic_owner.unified_batches b
 JOIN mission_generic_owner.unified_source_windows s ON s.id=b.source_window_id
 JOIN mission_generic_owner.work_items parent ON parent.id=b.decision_work_id
 WHERE b.id=w.authority_receipt_id AND b.writer_work_id=w.id AND b.master_session_id=w.master_session_id
 AND b.state='ready' AND b.message_id IS NULL AND b.payload=w.payload AND b.payload_sha256=w.payload_sha256
 AND w.payload_sha256=public.combat_v2_sha256(w.payload) AND w.payload->>'schema_version'='mission-generic-narration/4'
 AND w.payload->>'mode'='unified' AND w.payload#>>'{publication_barrier,closed}'='true'
 AND w.payload#>'{publication_barrier,required_receipt_ids}'=w.payload#>'{publication_barrier,receipt_ids}'
 AND w.payload#>'{publication_barrier,receipt_ids}' @> jsonb_build_array(b.id)
 AND w.payload->>'preparation_receipt_id'=b.id::text
 AND w.payload->'director_proposal'=b.decision AND b.decision_sha256=public.combat_v2_sha256(b.decision)
 AND s.master_session_id=w.master_session_id AND s.work_id=parent.id
 AND s.superseded_at IS NULL AND s.consumed_message_id IS NULL
 AND parent.kind='director' AND parent.state='completed' AND parent.finalized_at IS NOT NULL
 AND parent.result->>'ok'='true' AND parent.result->'decision'=b.decision
 AND parent.payload_sha256=public.combat_v2_sha256(parent.payload)
 AND s.source_sha256=parent.payload_sha256 AND s.definition_sha256=w.definition_sha256
 AND b.step_key=w.step_key AND b.run_control_version=w.run_control_version
 AND w.message_id IS NULL
 AND NOT EXISTS(SELECT 1 FROM mission_generic_owner.unified_segment_publications_v4 pub WHERE pub.work_id=w.id)
 ) OR  EXISTS(SELECT 1 FROM mission_generic_owner.unified_batches b
 WHERE b.id=w.authority_receipt_id AND b.id='32e674f6-f1b8-4273-973e-7da88ed2c5b9'::uuid
 AND b.master_session_id=w.master_session_id AND b.writer_work_id=w.id AND b.state='ready' AND b.message_id IS NULL
 AND b.composition_kind='combat_resolved_no_pending' AND b.source_window_id IS NULL AND b.next_round_id IS NULL
 AND b.encounter_id='28af57fd-aaea-4036-8881-e3df39e23092'::uuid AND b.run_control_version=4
 AND b.source_report_id='5b5f46db-c1e2-4ad6-b0f1-dc9563e81eb0'::uuid AND b.secondary_report_id='a5355e32-d780-490d-97fa-2767af05db7f'::uuid
 AND b.source_round_id='f7e9fdaf-8681-4034-ab96-3e668a176956'::uuid
 AND b.payload=w.payload AND b.payload_sha256=w.payload_sha256 AND w.payload_sha256=public.combat_v2_sha256(w.payload)
 AND w.payload->>'schema_version'='mission-generic-narration/3' AND w.payload->>'mode'='unified'
 AND w.payload->>'composition_kind'=b.composition_kind AND w.payload->>'batch_id'=b.id::text
 AND w.payload->>'preparation_receipt_id'=b.id::text AND w.payload->>'next_state_receipt_id'=b.id::text
 AND w.payload->'publication_barrier'=jsonb_build_object('closed',true,'required_receipt_ids',jsonb_build_array(b.id,b.source_report_id,b.secondary_report_id),'receipt_ids',jsonb_build_array(b.id,b.source_report_id,b.secondary_report_id))
 AND public.combat_v2_sha256(w.payload#>'{resolved_scenes,0}')='8ffc1e7abc84f8db7da30e3af234ab6e574106464cb760fa4204891291af3f53' AND public.combat_v2_sha256(w.payload#>'{resolved_scenes,1}')='37de1843c7c1967d25a564e2cd682bc2e4baae20d996aac647365529e0ae06bb' AND jsonb_array_length(w.payload->'resolved_scenes')=2 AND w.payload->'pending_offensives'='[]'::jsonb AND w.payload->'source_windows'='[]'::jsonb
 AND NOT EXISTS(SELECT 1 FROM jsonb_array_elements(w.payload->'resolved_scenes') item
 WHERE NOT EXISTS(SELECT 1 FROM public.combat_v2_round_reports rp JOIN public.combat_v2_rounds cr ON cr.id=rp.round_id
 WHERE rp.id=CASE WHEN (item#>>'{scene_binding,report_sha256}')=(SELECT mechanics_sha256 FROM public.combat_v2_round_reports WHERE id=b.source_report_id) THEN b.source_report_id ELSE b.secondary_report_id END
 AND item->>'schema_version'='mission-generic-narration/2' AND item->>'mode'='combat'
 AND item#>>'{scene_binding,session_id}'=b.encounter_id::text AND item#>>'{scene_binding,control_version}'=b.run_control_version::text
 AND item#>>'{scene_binding,round_id}'=cr.id::text AND item#>>'{scene_binding,report_sha256}'=rp.mechanics_sha256
 AND item#>>'{scene,snapshot_sha256}'=public.combat_v2_sha256(item#>'{scene,snapshot}')
 AND item#>>'{scene_binding,scene_sha256}'=item#>>'{scene,snapshot_sha256}'
 AND item->'barrier'=jsonb_build_object('closed',true,'required_receipt_ids',jsonb_build_array(rp.id),'receipt_ids',jsonb_build_array(rp.id))
 AND cr.session_id=b.encounter_id AND cr.report_id=rp.id AND cr.state='risolto' AND cr.resolved_at IS NOT NULL
 AND rp.narration_state='attesa' AND rp.mechanics_sha256=public.combat_v2_sha256(rp.mechanics) AND rp.values_written IS FALSE))
 AND NOT EXISTS(SELECT 1 FROM mission_generic_owner.unified_report_publications pub WHERE pub.report_id IN(b.source_report_id,b.secondary_report_id))
 AND public.combat_v2_values_written(b.encounter_id) IS FALSE AND combat_panel_private.uses_simulated_pools(b.encounter_id) IS TRUE
 AND EXISTS(SELECT 1 FROM public.mission_run_state r WHERE r.master_session_id=w.master_session_id AND r.run_phase='in_corso' AND r.current_step_key=b.step_key AND r.control_version=b.run_control_version)
 )) THEN RETURN false;END IF;
 IF w.state='failed' AND w.result->>'schema_version'='mission-count-overflow-failure/1' AND EXISTS(SELECT 1 FROM mission_narrative_internal.dispatch_audit a WHERE a.receipt_id=w.dispatch_receipt_id AND a.event_code='generic_count_overflow_terminal' AND a.details->>'work_id'=w.id::text AND a.details->>'result_sha256'=w.result_sha256) THEN RETURN true;END IF;
 IF w.state<>'claimed' THEN RETURN false;END IF;
 IF w.id='48e1bdcd-f044-be8c-1923-54d38e7e822c'::uuid AND mission_generic_owner.c8_context24_scope_v1(w.id) THEN expected_input:=24000;expected_reserve:=0.0124;END IF;
 SELECT a.details INTO st FROM mission_narrative_internal.dispatch_audit a WHERE a.receipt_id=w.dispatch_receipt_id AND a.event_code='c8_count_started';IF NOT FOUND THEN RETURN false;END IF;
 SELECT a.details INTO pr FROM mission_narrative_internal.dispatch_audit a WHERE a.receipt_id=w.dispatch_receipt_id AND a.event_code='c8_count_success';IF NOT FOUND THEN RETURN false;END IF;
 IF pr->>'state' IS DISTINCT FROM 'success' OR pr->>'generation_allowed' IS DISTINCT FROM 'false' THEN RETURN false;END IF;
 SELECT * INTO STRICT d FROM mission_narrative_internal.dispatch_receipts WHERE id=w.dispatch_receipt_id FOR UPDATE;
 IF st->>'work_id' IS DISTINCT FROM w.id::text OR st->>'lease_id' IS DISTINCT FROM w.lease_id::text
 OR st->>'measurement_id' IS DISTINCT FROM pr->>'measurement_id'
 OR pr->>'schema_version' IS DISTINCT FROM 'mission-generic-count-proof/1' OR pr->>'work_id' IS DISTINCT FROM w.id::text
 OR pr->>'state' IS DISTINCT FROM 'success' OR pr->>'generation_allowed' IS DISTINCT FROM 'false'
 OR pr->>'count_http_calls' IS DISTINCT FROM '1' OR pr->>'generation_http_calls' IS DISTINCT FROM '0'
 OR (pr->>'input_tokens' ~ '^[0-9]+$') IS DISTINCT FROM TRUE OR pr->>'max_input_tokens' IS DISTINCT FROM expected_input::text
 OR (pr->>'input_tokens')::numeric<=(pr->>'max_input_tokens')::numeric
 OR pr->>'generation_request_sha256' IS DISTINCT FROM st->>'generation_request_sha256'
 OR pr->>'policy_snapshot_sha256' IS DISTINCT FROM st->>'policy_snapshot_sha256'
 OR st#>>'{policy_snapshot,max_input_tokens}' IS DISTINCT FROM expected_input::text
 OR encode(extensions.digest(convert_to(st->>'generation_request_text','UTF8'),'sha256'),'hex') IS DISTINCT FROM st->>'generation_request_sha256'

 OR w.authorization_id IS NOT NULL OR w.dispatch_id IS NOT NULL
 OR d.status<>'claimed' OR d.dispatch_count<>0 OR d.charged_cost_usd IS DISTINCT FROM 0 OR d.upper_bound_cost_usd IS NOT NULL
 OR d.master_session_id<>w.master_session_id OR d.authority_receipt_id<>w.id OR d.request_key<>w.request_key
 OR d.event_kind<>'mission_generic_event' OR d.renderer_version<>'mission-generic-runtime/1'
 OR d.envelope->>'payload_sha256' IS DISTINCT FROM w.payload_sha256
 OR EXISTS(SELECT 1 FROM mission_narrative_internal.dispatch_attempts a WHERE a.receipt_id=d.id)
 OR EXISTS(SELECT 1 FROM mission_narrative_internal.provider_authorizations a WHERE a.receipt_id=d.id)
 OR EXISTS(SELECT 1 FROM staff_ai_quota_private.calls a WHERE a.source_id=d.id AND a.producer='mission_generic_ai' AND a.call_no=1)
 THEN RAISE EXCEPTION 'C1264_COUNT_OVERFLOW_BINDING' USING ERRCODE='40001';END IF;
 SELECT * INTO STRICT c FROM staff_ai_quota_private.calls WHERE id=(st->>'shared_count_ticket')::uuid FOR UPDATE;
 IF c.producer IS DISTINCT FROM 'mission_generic_ai' OR c.scope_id IS DISTINCT FROM w.master_session_id OR c.source_id IS DISTINCT FROM d.id
 OR c.call_no IS DISTINCT FROM 2 OR c.state IS DISTINCT FROM 'unknown_billable' OR c.charged_usd IS NOT NULL
 OR c.reserved_usd IS DISTINCT FROM (st->>'count_upper_cost_usd')::numeric OR c.reserved_usd IS DISTINCT FROM expected_reserve
 OR c.model IS DISTINCT FROM st#>>'{policy_snapshot,model}' THEN RAISE EXCEPTION 'C1264_COUNT_SHARED_BINDING' USING ERRCODE='40001';END IF;
 out_receipt:=gen_random_uuid();res:=jsonb_build_object('schema_version','mission-count-overflow-failure/1','work_id',w.id,'master_session_id',w.master_session_id,'ok',false,'failure_code','MISSION_INPUT_COUNT_OVERFLOW','failure_codes',jsonb_build_array('MISSION_INPUT_COUNT_OVERFLOW'),'outcome_uncertain',false,'provider_calls',0,'generation_http_calls',0,'generation_charged_cost_usd',0,'count_http_calls',1,'count_cost_state','unknown_billable','count_reserve_usd',c.reserved_usd,'measurement_id',pr->>'measurement_id','input_tokens',(pr->>'input_tokens')::integer,'max_input_tokens',expected_input);
 UPDATE mission_narrative_internal.dispatch_receipts SET status='failed',finalized_at=clock_timestamp(),updated_at=clock_timestamp() WHERE id=d.id;
 UPDATE mission_generic_owner.work_items SET state='failed',result=res,result_sha256=public.combat_v2_sha256(res),receipt_id=out_receipt,finalized_at=clock_timestamp() WHERE id=w.id;
 INSERT INTO mission_narrative_internal.dispatch_audit(receipt_id,event_code,details) VALUES(d.id,'generic_count_overflow_terminal',jsonb_build_object('schema_version','c1264-count-overflow-terminal/1','work_id',w.id,'receipt_id',out_receipt,'source_window_id',w.authority_receipt_id,'payload_sha256',w.payload_sha256,'measurement_id',pr->>'measurement_id','generation_request_sha256',pr->>'generation_request_sha256','result_sha256',public.combat_v2_sha256(res),'count_ticket',c.id,'count_reserve_usd',c.reserved_usd,'generation_http_calls',0));
 RETURN true;
END $function$;
REVOKE ALL ON FUNCTION mission_generic_owner.count_overflow_terminal_v1(uuid,uuid) FROM PUBLIC,anon,authenticated;
GRANT EXECUTE ON FUNCTION mission_generic_owner.count_overflow_terminal_v1(uuid,uuid) TO service_role;
$targetddl$;
EXECUTE $targetddl$CREATE OR REPLACE FUNCTION mission_generic_owner.c8_input_proof_assert_v1(p_work uuid, p_lease uuid, p_policy jsonb)
 RETURNS jsonb
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO ''
AS $function$
DECLARE w mission_generic_owner.work_items;sd jsonb;pf jsonb;snap jsonb;
BEGIN
 -- C9: freeze policy DML through proof, Native reserve and authorization.
 LOCK TABLE mission_narrative_internal.runtime_policy IN SHARE MODE;
 select * into strict w from mission_generic_owner.work_items where id=p_work;
 select da.details into strict sd from mission_narrative_internal.dispatch_audit da where da.receipt_id=w.dispatch_receipt_id and da.event_code='c8_count_started';
 select da.details into strict pf from mission_narrative_internal.dispatch_audit da where da.receipt_id=w.dispatch_receipt_id and da.event_code='c8_count_success';
 snap:=mission_generic_owner.c8_policy_snapshot_v1(w.id);
 if p_policy is null or not(p_policy ?& array['model','reasoning_effort','max_output_tokens','store','payload_sha256','input_measurement_id','provider_request_sha256']) or p_policy-'model'-'reasoning_effort'-'max_output_tokens'-'store'-'payload_sha256'-'input_measurement_id'-'provider_request_sha256'<>'{}'::jsonb or sd->>'measurement_id' is distinct from p_policy->>'input_measurement_id' or sd->>'generation_request_sha256' is distinct from p_policy->>'provider_request_sha256' or sd->>'lease_id' is distinct from p_lease::text or pf->>'measurement_id' is distinct from sd->>'measurement_id' or pf->>'generation_allowed' is distinct from 'true' or sd->>'policy_snapshot_sha256' is distinct from public.combat_v2_sha256(snap) or exists(select 1 from mission_narrative_internal.dispatch_audit where receipt_id=w.dispatch_receipt_id and event_code='c8_count_unknown') then raise exception 'C8_INPUT_PROOF_STALE' using errcode='40001';end if;
 return pf;
END $function$
$targetddl$;
END $ctx24ddl$;COMMIT;
