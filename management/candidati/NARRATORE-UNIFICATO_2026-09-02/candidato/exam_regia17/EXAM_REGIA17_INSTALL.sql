
BEGIN;
DO $slot_before$ BEGIN
 IF pg_get_indexdef(to_regclass('public.combat_v2_rounds_unico_attivo_idx')) IS DISTINCT FROM
 'CREATE UNIQUE INDEX combat_v2_rounds_unico_attivo_idx ON public.combat_v2_rounds USING btree (session_id) WHERE (state <> ''narrato''::text)'
 OR EXISTS(SELECT 1 FROM pg_attribute WHERE attrelid='public.combat_v2_rounds'::regclass AND attname='exam_captured_receipt_id' AND NOT attisdropped)
 THEN RAISE EXCEPTION 'exam_slot_baseline_drift'; END IF;
END $slot_before$;
DO $pins$ DECLARE expected record; actual record; BEGIN
 FOR expected IN SELECT * FROM (VALUES ('clan_sabaku_private','clone_attach_map','p_view jsonb','dfe807ce8a8a1dcbb92d9c8ce639d8e3','postgres','{postgres=X/postgres}','true','s','["search_path=\"\""]'),
('clan_sabaku_private','master_control_offers','p_context uuid, p_expected bigint','5076d99ceac7163a8cda2c8f3f36ec8c','postgres','{postgres=X/postgres}','true','v','["search_path=\"\""]'),
('combat_consumer_private','expected_main_count','p_round uuid','93b755b9e95f4fc53168c52e3932ce15','postgres','{postgres=X/postgres}','true','s','["search_path=\"\""]'),
('combat_consumer_private','narrative_tech_sources_v1','p_claim uuid','6d7cbbfbd1ecbae7f8efad6e7eeaca36','postgres','{postgres=X/postgres}','true','s','["search_path=\"\""]'),
('combat_gate_private','engagement_insert_guard','','717f57d7d9d61d333249e700f250c350','postgres','{postgres=X/postgres}','false','v','["search_path=\"\""]'),
('combat_panel_private','access_reason','p_location uuid, p_adapter text','4616c18ba0bdae3c6664a270d4b54980','postgres','{postgres=X/postgres}','true','s','["search_path=\"\""]'),
('combat_panel_private','add_choice','p_group uuid, p_label text, p_payload jsonb, p_distance numeric, p_direction text','d46463fcb4c38023ecac85ff1879889e','postgres','{postgres=X/postgres}','true','v','["search_path=\"\""]'),
('combat_panel_private','add_group','p_offer uuid, p_label text, p_purpose text, p_mode text, p_min integer, p_max integer, p_dependency uuid','0a48d2bd29237d77b6817f6e3b5ba5c7','postgres','{postgres=X/postgres}','true','v','["search_path=\"\""]'),
('combat_panel_private','add_input','p_offer uuid, p_label text, p_source_key text, p_required boolean, p_max integer','3f656caaa56acd1a5fcc7450ad725618','postgres','{postgres=X/postgres}','true','v','["search_path=\"\""]'),
('combat_panel_private','assert_master_ready','p_encounter uuid','0e505988789553760b446866ed0c03bf','postgres','{postgres=X/postgres}','true','s','["search_path=\"\""]'),
('combat_panel_private','attach_rating_offers','p_envelope jsonb, p_context uuid','1386f61a14e5ff5dd6e6bf96e799a60f','postgres','{postgres=X/postgres}','true','s','["search_path=\"\""]'),
('combat_panel_private','bind_master_movement','p_declaration uuid','62f42327ff4cccc0bc2b5a2885594d5a','postgres','{postgres=X/postgres}','true','v','["search_path=\"\""]'),
('combat_panel_private','body_visible_to_viewer','p_instance uuid, p_actor uuid','edc4e353722437fc5d17e7918c02b12c','postgres','{postgres=X/postgres}','true','s','["search_path=\"\""]'),
('combat_panel_private','commit_master_actor','p_command jsonb','2a548f9137060b34c4d89afed0c500aa','postgres','{postgres=X/postgres}','true','v','["search_path=\"\""]'),
('combat_panel_private','commit_multiplication','p_command jsonb','a415da4d32476aa1cb90a7edccb1e231','postgres','{postgres=X/postgres}','true','v','["search_path=\"\""]'),
('combat_panel_private','controller_version_valid','p_actor uuid, p_version bigint, p_principal uuid','e7f2319abaeb7b43aed42c02636f2d52','postgres','{postgres=X/postgres}','true','s','["search_path=\"\""]'),
('combat_panel_private','enroll_master','p_master uuid','ce3010ce93859ea3e0f08a31e8e27841','postgres','{postgres=X/postgres}','true','v','["search_path=\"\""]'),
('combat_panel_private','ensure_actor_turn','p_round uuid, p_actor uuid','215e1b2770873a4108bcbd780bf37fe5','postgres','{postgres=X/postgres}','true','v','["search_path=\"\""]'),
('combat_panel_private','immobilization_escape_meta','p_round uuid, p_actor uuid, p_request uuid, p_intent jsonb','e15673b3e6db4b26fe7e9a6f7940ca2c','postgres','{postgres=X/postgres}','true','s','["search_path=\"\""]'),
('combat_panel_private','immobilization_escape_offers','p_context uuid, p_expected bigint, p_view jsonb','10d1c679247786b51c0ef5162f3bd8f5','postgres','{postgres=X/postgres}','true','v','["search_path=\"\""]'),
('combat_panel_private','instance_terrain_map_objects','p_instance uuid, p_actor uuid','f84436a3ae1a3a0eda468b5f9d718cca','postgres','{postgres=X/postgres}','true','s','["search_path=\"\""]'),
('combat_panel_private','mask_native_state','p_result jsonb','7b4402eddd86fb78626bb3fa95b98fad','postgres','{postgres=X/postgres}','true','s','["search_path=\"\""]'),
('combat_panel_private','master_actor_offers','p_context uuid, p_expected bigint, p_view jsonb, p_source jsonb','b39d6c80aff42dc8e390e9c2b2f8b394','postgres','{postgres=X/postgres}','true','v','["search_path=\"\""]'),
('combat_panel_private','master_companion_bind_offers','p_context uuid, p_expected bigint','e9a861f5f68aa2006b9b852732c793d2','postgres','{postgres=X/postgres}','true','v','["search_path=\"\""]'),
('combat_panel_private','master_map','p_encounter uuid, p_actor uuid','6b370f3970c743e8ebde629d53ff4591','postgres','{postgres=X/postgres}','true','s','["search_path=\"\""]'),
('combat_panel_private','master_movement_budget','p_round uuid, p_actor uuid','dbe3af1c45f818fac37d257b033444c8','postgres','{postgres=X/postgres}','true','s','["search_path=\"\""]'),
('combat_panel_private','master_movement_intent','p_round uuid, p_actor uuid, p_request uuid, p_intent jsonb','939e2a67452a8a43491628c3c3e54d4e','postgres','{postgres=X/postgres}','true','v','["search_path=\"\""]'),
('combat_panel_private','master_movement_options','p_round uuid, p_actor uuid','863db0a8bfb2ce4e2576bf98396e0291','postgres','{postgres=X/postgres}','true','v','["search_path=\"\""]'),
('combat_panel_private','master_options','p_location uuid, p_actor uuid, p_expected bigint','b144b05f0b1fed5307b7cdc419dc889f','postgres','{postgres=X/postgres}','true','v','["search_path=\"\""]'),
('combat_panel_private','master_projection','p_location uuid, p_actor uuid','c9b4fc35801b675ed7a8042426fdaed1','postgres','{postgres=X/postgres}','true','v','["search_path=\"\""]'),
('combat_panel_private','master_state_authoritative','p_location uuid','75bfb1807f4941a7b89f8816f98002c8','postgres','{postgres=X/postgres}','true','s','["search_path=\"\""]'),
('combat_panel_private','movement_budget','p_owner uuid, p_round uuid','9d28b603b9bfe11aaa2653554f4f0c4a','postgres','{postgres=X/postgres}','true','s','["search_path=\"\""]'),
('combat_panel_private','movement_explanations','p_context uuid, p_expected bigint','4b099087c088ee48f0c344a68fcef38c','postgres','{postgres=X/postgres}','true','s','["search_path=\"\""]'),
('combat_panel_private','multiplication_actor_profile','p_actor uuid','ae1c065dcea82548cb954768b2bffce4','postgres','{postgres=X/postgres}','true','s','["search_path=\"\""]'),
('combat_panel_private','multiplication_add_defense_figures','p_offer uuid, p_defender uuid, p_attack_target uuid, p_dependency uuid','1123a75e17af41ea3bcebbac78b6a139','postgres','{postgres=X/postgres}','true','v','["search_path=\"\""]'),
('combat_panel_private','multiplication_attack_aim_valid','p_round uuid, p_actor uuid, p_target uuid, p_request uuid, p_range numeric','625c81005d6ccdf46b56ccc2172770b7','postgres','{postgres=X/postgres}','true','v','["search_path=\"\""]'),
('combat_panel_private','multiplication_attack_facts','p_target uuid','49d9e03c5f48645f5039f9ce76d5c601','postgres','{postgres=X/postgres}','true','v','["search_path=\"\""]'),
('combat_panel_private','multiplication_bind_attack_aims','p_declaration uuid','ba0e40772b0fd5ba0cf50d1a73964114','postgres','{postgres=X/postgres}','true','v','["search_path=\"\""]'),
('combat_panel_private','multiplication_companion_attack_source','p_round uuid, p_owner uuid, p_target uuid, p_request uuid, p_declaration uuid','81912b6eb237e16731789191cdb9ca01','postgres','{postgres=X/postgres}','true','v','["search_path=\"\""]'),
('combat_panel_private','multiplication_companion_target_geometry','p_round uuid, p_owner uuid, p_target uuid','951ab035e129496347720484b83b8b36','postgres','{postgres=X/postgres}','true','v','["search_path=\"\""]'),
('combat_panel_private','multiplication_declaration_meta','p_round uuid, p_actor uuid, p_request uuid, p_intent jsonb, p_meta jsonb','eca263cd41830d1203cc1b07ae2df77c','postgres','{postgres=X/postgres}','true','s','["search_path=\"\""]'),
('combat_panel_private','multiplication_effect','p_facts jsonb, p_reaction text','9672d253616b896c3c2960eb3cd2596a','postgres','{postgres=X/postgres}','true','s','["search_path=\"\""]'),
('combat_panel_private','multiplication_layout_options_for_figure','p_actor uuid, p_copies integer, p_mode text, p_target uuid, p_formation uuid, p_version bigint, p_index integer','ce4d91d36434dfb1945768177c99e573','postgres','{postgres=X/postgres}','true','v','["search_path=\"\""]'),
('combat_panel_private','multiplication_offers','p_context uuid, p_expected bigint, p_view jsonb','a580a113d5ac0564ee70f6aa9f173015','postgres','{postgres=X/postgres}','true','v','["search_path=\"\""]'),
('combat_panel_private','multiplication_prepare_assault_draw','p_round uuid, p_actor uuid, p_target uuid, p_formation uuid, p_version bigint, p_indices jsonb, p_copies integer, p_figures jsonb, p_original integer, p_request uuid','9b5b095d2d4a59ca3d7a0b6fce3cb762','postgres','{postgres=X/postgres}','true','v','["search_path=\"\""]'),
('combat_panel_private','multiplication_prepare_attack_aim_for_source','p_round uuid, p_actor uuid, p_target uuid, p_formation uuid, p_version bigint, p_index integer, p_request uuid, p_companion boolean','627a5e38a57305b637cfcd0edb6162f3','postgres','{postgres=X/postgres}','true','v','["search_path=\"\""]'),
('combat_panel_private','multiplication_prepare_attack_draw','p_round uuid, p_actor uuid, p_target uuid, p_formation uuid, p_version bigint, p_indices jsonb, p_range numeric, p_request uuid, p_companion boolean','9122dbc06cfdb0ccd12f010d737a3616','postgres','{postgres=X/postgres}','true','v','["search_path=\"\""]'),
('combat_panel_private','multiplication_prepare_declaration','p_round uuid, p_actor uuid, p_mode text, p_copies integer, p_figures jsonb, p_original integer, p_target uuid, p_movement uuid, p_request uuid','697d6481412b8769e87789abaeb67422','postgres','{postgres=X/postgres}','true','v','["search_path=\"\""]'),
('combat_panel_private','multiplication_register_choice','p_formation uuid, p_target uuid, p_chooser uuid, p_index integer, p_request uuid','2418bcbdb4be2a123f413cd839ddd85f','postgres','{postgres=X/postgres}','true','v','["search_path=\"\""]'),
('combat_panel_private','multiplication_register_defense_selections','p_round uuid, p_defender uuid, p_request uuid, p_resolved jsonb, p_defense uuid, p_parent_attack uuid','a877b573bb51a65a8beffd2edb45d99f','postgres','{postgres=X/postgres}','true','v','["search_path=\"\""]'),
('combat_panel_private','multiplication_target_geometry_for_body','p_actor uuid, p_target uuid, p_source uuid','d393293c064bb50d3daa94bc95c31ff2','postgres','{postgres=X/postgres}','true','s','["search_path=\"\""]'),
('combat_panel_private','multiplication_view','p_location uuid, p_visible_bodies jsonb','6a140a12a7aad2286ae763043d9dd642','postgres','{postgres=X/postgres}','true','s','["search_path=\"\""]'),
('combat_panel_private','narrative_outcome_facts','p_outcome jsonb','2e728f0c6ffa8af0e55d1a90592514c4','postgres','{postgres=X/postgres}','false','s','["search_path=\"\""]'),
('combat_panel_private','offer_projection','p_offer uuid','791ac67b7ff022891ed40f0c6f2eaf95','postgres','{postgres=X/postgres}','true','s','["search_path=\"\""]'),
('combat_panel_private','owned_context','p_context uuid, p_expected bigint','6ed4bd0196c6e8d44865ff89a46e3a01','postgres','{postgres=X/postgres}','true','s','["search_path=\"\""]'),
('combat_panel_private','owner_turn_context','p_actor uuid','56291b63933136f509c818dd58c4bf10','postgres','{postgres=X/postgres}','true','s','["search_path=\"\""]'),
('combat_panel_private','prepare_master_movement','p_round uuid, p_actor uuid, p_capability uuid, p_request uuid','269110ef0aa63ce1b4afb9c3bf9d70e2','postgres','{postgres=X/postgres}','true','v','["search_path=\"\""]'),
('combat_panel_private','publish_master_declaration','p_declaration uuid, p_text text','d10c9862dff8aac3b078ffeb4b72b76e','postgres','{postgres=X/postgres}','true','v','["search_path=\"\""]'),
('combat_panel_private','refresh_context','p_location uuid, p_actor uuid, p_activity_kind text, p_activity uuid, p_round uuid, p_scene_version bigint, p_source_facts jsonb','f6c0ae53074ba545267a234745105bdd','postgres','{postgres=X/postgres}','true','v','["search_path=\"\""]'),
('combat_panel_private','resolve_master_movement','p_declaration uuid, p_root uuid','14a8b5852d089d218d3ad9eb8bd69035','postgres','{postgres=X/postgres}','true','v','["search_path=\"\""]'),
('combat_panel_private','resolve_selections','p_offer uuid, p_ids uuid[], p_inputs jsonb','736a5970c981e20260bf51dc9dff0bc2','postgres','{postgres=X/postgres}','true','s','["search_path=\"\""]'),
('combat_panel_private','round_options_authoritative','p_round uuid, p_actor uuid','032305378c1112db9c8cff3a5da25e0b','postgres','{postgres=X/postgres}','true','v','["search_path=\"\""]'),
('combat_panel_private','sync_master_scene','p_encounter uuid','8de9e5c64e06118ad010c5329278c9d2','postgres','{postgres=X/postgres}','true','v','["search_path=\"\""]'),
('combat_panel_private','target_geometry_valid','p_actor uuid, p_target uuid, p_range numeric','2f8c5e0ea900e5b851d64b96e887f1ac','postgres','{postgres=X/postgres}','true','s','["search_path=\"\""]'),
('combat_panel_private','uses_simulated_pools','p_session uuid','056d23937b3b8cca0182be0d4c70371a','postgres','{postgres=X/postgres}','true','v','["search_path=\"\""]'),
('combat_spatial','exchange_owner_receipt','p_instance uuid, p_round uuid','1eb4d337f6161fd33e56d71588b547f2','postgres','{postgres=X/postgres,service_role=X/postgres}','true','s','["search_path=\"\""]'),
('combat_spatial','movement_commit','p_capability uuid, p_request_key uuid, p_root uuid','0df0095cc3a9c8010cd2a17c6fed1501','postgres','{postgres=X/postgres}','true','v','["search_path=\"\""]'),
('combat_spatial','movement_options','p_instance uuid, p_actor uuid, p_budget numeric','cea9561628547a87b83cbda9e69822c3','postgres','{postgres=X/postgres}','true','v','["search_path=\"\""]'),
('combat_spatial','substitution_combat_context_v1','p_attack uuid','0285d63fbd123875d107a3750add6851','postgres','{postgres=X/postgres}','true','s','["search_path=\"\""]'),
('combat_spatial','substitution_commit','p_capability uuid, p_request_key uuid, p_root uuid','8930462fa9e17aced83bc41cc14a786a','postgres','{postgres=X/postgres}','true','v','["search_path=\"\""]'),
('combat_spatial','substitution_options','p_instance uuid, p_window uuid, p_actor uuid, p_profile text, p_round integer','1ac773e2a6869947807ac4c81081fde8','postgres','{postgres=X/postgres}','true','v','["search_path=\"\""]'),
('combat_v2_multitarget_internal','resolve_parent','p_session uuid, p_round uuid, p_attack uuid, p_values boolean','949b86c23215f9788b96876d32402dd5','postgres','{postgres=X/postgres}','true','v','["search_path=\"\""]'),
('mission_exam_private','bind_class_session','','77985f038b751b7ebb80fb65a3054f96','postgres','{postgres=X/postgres}','true','v','["search_path=\"\""]'),
('mission_exchange_owner','assert_exact_pinset','','ca89ca57b6637572d1ff23c0a3394c99','postgres','{postgres=X/postgres,service_role=X/postgres}','true','v','["search_path=\"\""]'),
('public','_esame_png_gioca','p_prova uuid, p_opzione text, p_da text','cdf89be394ec84ad8b0f814164e13e71','postgres','{postgres=X/postgres,service_role=X/postgres}','true','v','["search_path=public"]'),
('public','_esame_prova_azione_esegui','p_prova uuid, p_azione jsonb, p_testo text','42e9bd5c1582af79cc41515aa618e75b','postgres','{postgres=X/postgres,service_role=X/postgres}','true','v','["search_path=public"]'),
('public','_esame_risolvi','p_prova uuid, p_azione jsonb, p_chi text','cf59330608a4c98d2b9c02901004708d','postgres','{postgres=X/postgres,service_role=X/postgres}','true','v','["search_path=public"]'),
('public','_esame_session_claim','p_bozza uuid, p_user uuid','7900b5d85ab0a2541e310f61a1868709','postgres','{postgres=X/postgres,service_role=X/postgres}','true','v','["search_path=\"\""]'),
('public','_esame_session_scope','p_prova uuid, p_user uuid','59fa3e0471f3090a377857fd3cff5255','postgres','{postgres=X/postgres,service_role=X/postgres}','true','s','["search_path=\"\""]'),
('public','combat_v2_action_declare','p_round uuid, p_actor uuid, p_intent jsonb, p_text text, p_request_key uuid','eef86ce2f45c6c754bd82b9f54036dcc','postgres','{postgres=X/postgres,authenticated=X/postgres,service_role=X/postgres}','true','v','["search_path=\"\""]'),
('public','combat_v2_defense_declare','p_round uuid, p_attack_declaration uuid, p_actor uuid, p_intent jsonb, p_text text, p_request_key uuid','cbf7394019bc7e356857530856aae390','postgres','{postgres=X/postgres,authenticated=X/postgres,service_role=X/postgres}','true','v','["search_path=\"\""]'),
('public','combat_v2_event_begin','p_scope uuid, p_request_key uuid, p_operation text, p_payload jsonb, p_control_version bigint','013bb0e822efc32413dc136e90a6e35a','postgres','{postgres=X/postgres,service_role=X/postgres}','true','v','["search_path=\"\""]'),
('public','combat_v2_exchange_context_valid','p_master uuid, p_session uuid, p_round uuid, p_team text','343c62aeae56ea542ec48542d3d11afa','postgres','{postgres=X/postgres,service_role=X/postgres}','true','s','["search_path=\"\""]'),
('public','combat_v2_exchange_counter_intent_owner','p_session uuid, p_round uuid, p_roster_sha text','4da2a7b76449232d88e4642e1c400dbb','postgres','{postgres=X/postgres,service_role=X/postgres}','true','s','["search_path=\"\""]'),
('public','combat_v2_exchange_owner_receipt','p_round uuid','61ab7c91801664175d48af9287abe3bd','postgres','{postgres=X/postgres,service_role=X/postgres}','true','s','["search_path=\"\""]'),
('public','combat_v2_exchange_roster_owner','p_session uuid','f8279250e3a0ad2a253f36bbcc6bd850','postgres','{postgres=X/postgres,service_role=X/postgres}','true','s','["search_path=\"\""]'),
('public','combat_v2_narrative_store','p_round uuid, p_kind text, p_text text, p_request_key uuid, p_author uuid','0e73f64916cb78337d524079bfec6fef','postgres','{postgres=X/postgres}','true','v','["search_path=\"\""]'),
('public','combat_v2_round_resolve','p_round uuid, p_request_key uuid','1dc067800a5da14fc01382566ae62f82','postgres','{postgres=X/postgres,service_role=X/postgres,authenticated=X/postgres}','true','v','["search_path=\"\""]'),
('public','combat_v2_substitution_options_v1','p_attack_declaration uuid','9413873cceec8199e13fdae8a1af0157','postgres','{postgres=X/postgres,authenticated=X/postgres}','true','v','["search_path=\"\""]'),
('public','combat_v2_substitution_select_v1','p_substitution_option_id uuid, p_request_key uuid','5c172fbe513d692b45398f889879ec99','postgres','{postgres=X/postgres,authenticated=X/postgres}','true','v','["search_path=\"\""]'),
('public','combat_v2_values_written','p_session uuid','843e9ef632c305142e1825513f5c1da5','postgres','{postgres=X/postgres,service_role=X/postgres}','true','s','["search_path=\"\""]'),
('public','esame_avvia','p_location uuid','582eb4120071454d23aee82900817fcf','postgres','{postgres=X/postgres,service_role=X/postgres,authenticated=X/postgres}','true','v','["search_path=public"]'),
('public','esame_prova_uscita','p_prova uuid, p_testo text','f88e3d482dd8fe941f4d6614f2519ebe','postgres','{postgres=X/postgres,service_role=X/postgres,authenticated=X/postgres}','true','v','["search_path=public"]'),
('public','exam_substitution_commit_v1','p_prova uuid, p_substitution_option_id uuid, p_request_key uuid','84f6cb8cc3a85d2a5dc9de7381f07714','postgres','{postgres=X/postgres,service_role=X/postgres}','true','v','["search_path=\"\""]'),
('public','mission_exchange_v3_capture','cy uuid, ph text, r uuid, k uuid','3a8e3cc416e1eccefb3746ca2048adc8','postgres','{postgres=X/postgres,service_role=X/postgres}','true','v','["search_path=\"\""]'),
('public','mission_exchange_v3_counter_intent_prepare','cy uuid, cr uuid, k uuid','e0fb836a593491e2a657e54b2123bc71','postgres','{postgres=X/postgres,service_role=X/postgres}','true','v','["search_path=\"\""]'),
('public','mission_exchange_v3_counter_open','cy uuid, cr uuid, pub uuid, k uuid','0b55b78dda05f1a1ae46a71540e930a9','postgres','{postgres=X/postgres,service_role=X/postgres}','true','v','["search_path=\"\""]'),
('public','mission_exchange_v3_cycle_close','cy uuid, pub uuid, k uuid','8c0bab06264aece74c45ccde670ea8a8','postgres','{postgres=X/postgres,service_role=X/postgres}','true','v','["search_path=\"\""]'),
('public','mission_exchange_v3_cycle_open','m uuid, co uuid, sp uuid, pr uuid, k uuid','2a11060cd08b36c9bb7e87bca53e9cc7','postgres','{postgres=X/postgres,service_role=X/postgres}','true','v','["search_path=\"\""]'),
('public','mission_exchange_v3_publication_bind','cy uuid, rid uuid, dr uuid, pub uuid, k uuid','ab2cf8ba41515d6a42b3bbd04e6482c4','postgres','{postgres=X/postgres,service_role=X/postgres}','true','v','["search_path=\"\""]')) x(schema_name,proname,args,definition_md5,owner_name,acl,security_definer,volatility,configuration) LOOP
  SELECT md5(pg_get_functiondef(p.oid)) definition_md5,pg_get_userbyid(p.proowner) owner_name,coalesce(p.proacl::text,'') acl,p.prosecdef::text security_definer,p.provolatile::text volatility,coalesce(to_jsonb(p.proconfig),'null'::jsonb) configuration INTO actual
  FROM pg_proc p JOIN pg_namespace n ON n.oid=p.pronamespace
  WHERE n.nspname=expected.schema_name AND p.proname=expected.proname AND pg_get_function_identity_arguments(p.oid)=expected.args;
  IF actual.definition_md5 IS DISTINCT FROM expected.definition_md5 OR actual.owner_name IS DISTINCT FROM expected.owner_name
  OR actual.acl IS DISTINCT FROM expected.acl OR actual.security_definer IS DISTINCT FROM expected.security_definer
  OR actual.volatility IS DISTINCT FROM expected.volatility OR actual.configuration IS DISTINCT FROM expected.configuration::jsonb
  THEN RAISE EXCEPTION 'exam_regia_baseline_drift: %.%(%)',expected.schema_name,expected.proname,expected.args; END IF;
 END LOOP;
END $pins$;

CREATE SCHEMA IF NOT EXISTS exam_regia_private;
REVOKE ALL ON SCHEMA exam_regia_private FROM PUBLIC,anon,authenticated,service_role;
CREATE TABLE exam_regia_private.runtime (
 singleton boolean PRIMARY KEY DEFAULT true CHECK(singleton), enabled boolean NOT NULL DEFAULT false,
 provider_enabled boolean NOT NULL DEFAULT false, version text NOT NULL DEFAULT 'EXAM-REGIA17/1',
 provider_call_cap integer NOT NULL DEFAULT 17 CHECK(provider_call_cap BETWEEN 1 AND 17));
INSERT INTO exam_regia_private.runtime(singleton) VALUES(true);
CREATE TABLE exam_regia_private.admissions (
 id uuid PRIMARY KEY DEFAULT gen_random_uuid(), owner_user uuid NOT NULL, character_id uuid NOT NULL REFERENCES public.characters(id),
 location_id uuid NOT NULL REFERENCES public.locations(id),
 template_key text NOT NULL, template_version integer NOT NULL, CHECK(template_key='exam_konoha_10x10_v1' AND template_version=1), surface text NOT NULL CHECK(surface IN ('konoha','staff_test','user_test')),
 enabled boolean NOT NULL DEFAULT false, expires_at timestamptz NOT NULL,
 UNIQUE(owner_user,character_id,location_id), FOREIGN KEY(template_key,template_version) REFERENCES combat_spatial.arena_templates);
ALTER TABLE mission_exam_private.open_requests ADD COLUMN exam_regia_admission_id uuid REFERENCES exam_regia_private.admissions(id);
CREATE TABLE exam_regia_private.bindings (
 prova_id uuid PRIMARY KEY REFERENCES public.esame_prove(id) DEFERRABLE INITIALLY DEFERRED,
 admission_id uuid NOT NULL REFERENCES exam_regia_private.admissions(id),
 native_arena_binding_id uuid NOT NULL REFERENCES combat_spatial.mission_bindings(binding_id),
 class_session_id uuid UNIQUE NOT NULL REFERENCES public.academy_class_sessions(id) DEFERRABLE INITIALLY DEFERRED,
 master_session_id uuid UNIQUE NOT NULL REFERENCES public.master_v2_sessions(id) DEFERRABLE INITIALLY DEFERRED,
 combat_session_id uuid UNIQUE NOT NULL REFERENCES public.combat_v2_sessions(id) DEFERRABLE INITIALLY DEFERRED,
 player_actor_id uuid UNIQUE NOT NULL REFERENCES public.combat_v2_actors(id) DEFERRABLE INITIALLY DEFERRED,
 png_actor_id uuid UNIQUE NOT NULL REFERENCES public.combat_v2_actors(id) DEFERRABLE INITIALLY DEFERRED,
 owner_user uuid NOT NULL, character_id uuid NOT NULL REFERENCES public.characters(id), location_id uuid NOT NULL REFERENCES public.locations(id),
 service_principal_id uuid UNIQUE NOT NULL DEFAULT gen_random_uuid(),
 request_key uuid NOT NULL, policy_id text NOT NULL DEFAULT 'exam_protected_no_persistent_resources_v1'
 CHECK(policy_id='exam_protected_no_persistent_resources_v1'), state text NOT NULL DEFAULT 'opening'
 CHECK(state IN ('opening','active','paused','congedo','closed')),
 control_version bigint NOT NULL DEFAULT 1 CHECK(control_version>0),
 receipt_id uuid NOT NULL DEFAULT gen_random_uuid(), receipt_kind text NOT NULL DEFAULT 'opening'
 CHECK(receipt_kind IN ('opening','choice','narration','player','complete')),
 created_at timestamptz NOT NULL DEFAULT clock_timestamp(), updated_at timestamptz NOT NULL DEFAULT clock_timestamp(),
 closed_at timestamptz, close_reason text, UNIQUE(owner_user,request_key),
 CHECK(player_actor_id<>png_actor_id), CHECK((state='closed')=(closed_at IS NOT NULL)));
CREATE UNIQUE INDEX exam_regia_one_active_owner ON exam_regia_private.bindings(owner_user) WHERE state<>'closed';
CREATE UNIQUE INDEX exam_regia_one_active_location ON exam_regia_private.bindings(location_id) WHERE state<>'closed';
CREATE TABLE exam_regia_private.execution_permits (
 id uuid PRIMARY KEY DEFAULT gen_random_uuid(), prova_id uuid NOT NULL REFERENCES exam_regia_private.bindings,
 actor_id uuid NOT NULL, principal_id uuid NOT NULL, transaction_id bigint NOT NULL, backend_pid integer NOT NULL,
 operation text NOT NULL CHECK(operation IN ('options','commit','resolve','exchange','release_party')), request_key uuid NOT NULL,
 created_at timestamptz NOT NULL DEFAULT clock_timestamp(), consumed_at timestamptz,
 UNIQUE(transaction_id,backend_pid,prova_id,request_key,operation));
CREATE TABLE exam_regia_private.receipts (
 id uuid PRIMARY KEY, prova_id uuid NOT NULL REFERENCES exam_regia_private.bindings,
 kind text NOT NULL CHECK(kind IN ('opening','choice','narration')), round_id uuid REFERENCES public.combat_v2_rounds(id),
 phase text, draft_id uuid UNIQUE, payload jsonb, payload_sha text,
 committed_command jsonb, command_receipt_id uuid, published_at timestamptz, created_at timestamptz NOT NULL DEFAULT clock_timestamp());
CREATE TABLE exam_regia_private.ai_capabilities (
 id uuid PRIMARY KEY DEFAULT gen_random_uuid(), prova_id uuid NOT NULL REFERENCES exam_regia_private.bindings,
 receipt_id uuid NOT NULL REFERENCES exam_regia_private.receipts, actor_id uuid NOT NULL, request_key uuid NOT NULL,
 context_version bigint NOT NULL, controller_version bigint NOT NULL, legal_options jsonb NOT NULL,
 source_sha256 text NOT NULL, expires_at timestamptz NOT NULL, consumed_at timestamptz,
 command_sha256 text, result jsonb, UNIQUE(receipt_id));
CREATE TABLE exam_regia_private.profile_templates (
 profile_id uuid NOT NULL REFERENCES public.esame_png_profili(id), source_sha256 text NOT NULL,
 template_id uuid UNIQUE NOT NULL REFERENCES public.png_templates(id), persona text NOT NULL, snapshot jsonb NOT NULL,
 created_at timestamptz NOT NULL DEFAULT clock_timestamp(), PRIMARY KEY(profile_id,source_sha256));
CREATE FUNCTION exam_regia_private.native_open_allowed(p_user uuid,p_character uuid,p_location uuid) RETURNS boolean
LANGUAGE sql VOLATILE SECURITY DEFINER SET search_path='' AS $fn$
 SELECT p_user IS NOT NULL AND p_user=auth.uid() AND EXISTS(
 SELECT 1 FROM mission_exam_private.open_requests q JOIN exam_regia_private.admissions a ON a.id=q.exam_regia_admission_id
 JOIN exam_regia_private.runtime rt ON rt.singleton AND rt.enabled
 JOIN public.characters c ON c.id=a.character_id AND c.user_id=a.owner_user
 JOIN public.locations l ON l.id=a.location_id AND l.is_active AND l.is_test
 WHERE q.owner_user=p_user AND q.transaction_id=txid_current()
 AND a.owner_user=p_user AND a.character_id=p_character AND a.location_id=p_location
 AND a.surface IN ('staff_test','user_test') AND a.enabled AND a.expires_at>clock_timestamp()
 AND public._combat_presente(p_user,p_location));
$fn$;
CREATE FUNCTION exam_regia_private.same_exam_entry(p_character uuid,p_session uuid) RETURNS boolean
LANGUAGE plpgsql VOLATILE SECURITY DEFINER SET search_path='' AS $fn$
DECLARE entry exam_regia_private.bindings%ROWTYPE; activity jsonb;
BEGIN
 SELECT b.* INTO entry FROM exam_regia_private.bindings b
 JOIN mission_exam_private.protected_sessions q ON q.prova_id=b.prova_id AND q.class_session_id=b.class_session_id
 JOIN mission_exam_private.open_requests req ON req.class_session_id=b.class_session_id AND req.owner_user=b.owner_user
 JOIN exam_regia_private.admissions a ON a.id=b.admission_id
 WHERE b.character_id=p_character AND b.owner_user=auth.uid() AND b.state='opening'
 AND p_session IN (b.master_session_id,b.combat_session_id) AND req.transaction_id=txid_current()
 AND q.state='active' AND q.character_id=b.character_id AND q.owner_user=b.owner_user AND q.location_id=b.location_id
 AND (a.owner_user,a.character_id,a.location_id)=(b.owner_user,b.character_id,b.location_id)
 AND a.enabled AND a.expires_at>clock_timestamp();
 IF NOT FOUND THEN RETURN false; END IF;
 activity:=public._attivita_impegno(p_character);
 IF activity->>'modalita' IS DISTINCT FROM 'esame' OR activity->>'attivita_id' IS DISTINCT FROM entry.prova_id::text THEN RETURN false; END IF;
 RETURN NOT EXISTS(SELECT 1 FROM public.esame_prove p WHERE p.candidate_character=p_character AND p.stato='aperta' AND p.id<>entry.prova_id)
 AND NOT EXISTS(SELECT 1 FROM public.combat_v2_actors a JOIN public.combat_v2_sessions s ON s.id=a.session_id
 WHERE a.character_id=p_character AND a.state='attivo' AND s.closed_at IS NULL AND s.id<>entry.combat_session_id)
 AND NOT EXISTS(SELECT 1 FROM public.master_v2_participants p JOIN public.master_v2_sessions m ON m.id=p.session_id
 WHERE p.character_id=p_character AND p.engagement_state IN ('attivo','sospeso') AND m.closed_at IS NULL AND m.id<>entry.master_session_id);
END $fn$;
CREATE FUNCTION exam_regia_private.assert_no_legacy(p_prova uuid) RETURNS void
LANGUAGE plpgsql SECURITY DEFINER SET search_path='' AS $fn$
BEGIN
 IF EXISTS(SELECT 1 FROM exam_regia_private.bindings WHERE prova_id=p_prova) THEN
 RAISE EXCEPTION 'exam_regia_legacy_engine_disabled' USING ERRCODE='42501'; END IF;
END $fn$;
CREATE FUNCTION exam_regia_private.actor_principal(p_actor uuid,p_user uuid) RETURNS uuid
LANGUAGE sql STABLE SECURITY DEFINER SET search_path='' AS $fn$
 SELECT coalesce(p_user,(SELECT b.service_principal_id FROM exam_regia_private.bindings b
  WHERE b.png_actor_id=p_actor AND b.state<>'closed'));
$fn$;
CREATE FUNCTION exam_regia_private.current_principal() RETURNS uuid
LANGUAGE plpgsql STABLE SECURITY DEFINER SET search_path='' AS $fn$
DECLARE principal uuid;
BEGIN
 IF auth.uid() IS NOT NULL THEN RETURN auth.uid(); END IF;
 IF NOT public.combat_v2_is_service() OR NOT EXISTS(SELECT 1 FROM exam_regia_private.runtime WHERE singleton AND enabled) THEN RETURN NULL; END IF;
 SELECT p.principal_id INTO principal FROM exam_regia_private.execution_permits p
 JOIN exam_regia_private.bindings b ON b.prova_id=p.prova_id AND b.png_actor_id=p.actor_id
  AND b.service_principal_id=p.principal_id AND b.state IN ('active','paused')
 JOIN public.combat_v2_sessions s ON s.id=b.combat_session_id AND s.master_session_id=b.master_session_id
  AND s.source_kind='master' AND NOT s.lesiva AND s.closed_at IS NULL
 JOIN public.master_v2_sessions m ON m.id=b.master_session_id AND m.owner_kind='ai_service'
  AND m.master_user IS NULL AND m.closed_at IS NULL
 WHERE p.transaction_id=txid_current() AND p.backend_pid=pg_backend_pid() AND p.consumed_at IS NULL
  AND p.created_at>clock_timestamp()-interval '150 seconds';
 IF principal IS NULL THEN RETURN NULL; END IF;
 IF (SELECT count(DISTINCT p.principal_id) FROM exam_regia_private.execution_permits p
  WHERE p.transaction_id=txid_current() AND p.backend_pid=pg_backend_pid() AND p.consumed_at IS NULL)>1
 THEN RAISE EXCEPTION 'exam_regia_ambiguous_authority' USING ERRCODE='42501'; END IF;
 RETURN principal;
END $fn$;
CREATE FUNCTION exam_regia_private.is_bound(p_encounter uuid) RETURNS boolean
LANGUAGE sql STABLE SECURITY DEFINER SET search_path='' AS $fn$
 SELECT EXISTS(SELECT 1 FROM exam_regia_private.bindings b JOIN public.combat_v2_sessions s ON s.id=b.combat_session_id
 JOIN public.master_v2_sessions m ON m.id=b.master_session_id WHERE b.combat_session_id=p_encounter
 AND s.source_kind='master' AND NOT s.lesiva AND s.master_session_id=m.id AND m.owner_kind='ai_service'
 AND m.master_user IS NULL);
$fn$;
CREATE FUNCTION exam_regia_private.assert_owner(p_prova uuid,p_allow_closed boolean DEFAULT false)
RETURNS exam_regia_private.bindings LANGUAGE plpgsql SECURITY DEFINER SET search_path='' AS $fn$
DECLARE b exam_regia_private.bindings%ROWTYPE;
BEGIN
 IF auth.uid() IS NULL THEN RAISE EXCEPTION 'exam_regia_auth_required' USING ERRCODE='42501'; END IF;
 SELECT * INTO b FROM exam_regia_private.bindings WHERE prova_id=p_prova AND owner_user=auth.uid() FOR UPDATE;
 IF NOT FOUND OR (NOT p_allow_closed AND b.state='closed') OR NOT EXISTS(SELECT 1 FROM public.characters c
  WHERE c.id=b.character_id AND c.user_id=auth.uid())
 THEN RAISE EXCEPTION 'exam_regia_not_owned' USING ERRCODE='42501'; END IF;
 RETURN b;
END $fn$;
CREATE FUNCTION exam_regia_private.is_private_template(p_id uuid) RETURNS boolean
LANGUAGE sql STABLE SECURITY DEFINER SET search_path='' AS $fn$
 SELECT EXISTS(SELECT 1 FROM exam_regia_private.profile_templates WHERE template_id=p_id);
$fn$;
GRANT USAGE ON SCHEMA exam_regia_private TO authenticated;
GRANT EXECUTE ON FUNCTION exam_regia_private.is_private_template(uuid) TO authenticated;
CREATE POLICY exam_regia_private_template_hidden ON public.png_templates AS RESTRICTIVE FOR SELECT TO authenticated
 USING (NOT exam_regia_private.is_private_template(id));
CREATE TABLE exam_regia_private.exchange_links (
 cycle_id uuid PRIMARY KEY REFERENCES mission_exchange_v3.cycles(id),
 prova_id uuid NOT NULL REFERENCES exam_regia_private.bindings(prova_id),
 logical_round integer NOT NULL CHECK(logical_round BETWEEN 1 AND 4),
 UNIQUE(prova_id,logical_round));
CREATE FUNCTION exam_regia_private.logical_round_no(p_round uuid) RETURNS integer
LANGUAGE sql STABLE SECURITY DEFINER SET search_path='' AS $x$
 SELECT CASE WHEN EXISTS(SELECT 1 FROM exam_regia_private.bindings b WHERE b.combat_session_id=r.session_id)
 THEN (r.round_no+1)/2 ELSE r.round_no END FROM public.combat_v2_rounds r WHERE r.id=p_round;
$x$;
CREATE FUNCTION exam_regia_private.logical_round_ids(p_round uuid) RETURNS uuid[]
LANGUAGE sql STABLE SECURITY DEFINER SET search_path='' AS $x$
 SELECT CASE WHEN EXISTS(SELECT 1 FROM exam_regia_private.bindings b WHERE b.combat_session_id=r.session_id)
 THEN ARRAY(SELECT z.id FROM public.combat_v2_rounds z WHERE z.session_id=r.session_id AND (z.round_no+1)/2=(r.round_no+1)/2)
 ELSE ARRAY[p_round] END FROM public.combat_v2_rounds r WHERE r.id=p_round;
$x$;
CREATE FUNCTION exam_regia_private.is_turn_actor(p_round uuid,p_actor uuid) RETURNS boolean
LANGUAGE sql STABLE SECURITY DEFINER SET search_path='' AS $x$
 SELECT EXISTS(SELECT 1 FROM exam_regia_private.bindings b JOIN public.combat_v2_rounds r ON r.session_id=b.combat_session_id
 WHERE r.id=p_round AND p_actor=CASE WHEN r.round_no%2=1 THEN b.player_actor_id ELSE b.png_actor_id END);
$x$;
CREATE FUNCTION exam_regia_private.exchange_scope(p_scope uuid) RETURNS uuid
LANGUAGE sql STABLE SECURITY DEFINER SET search_path='' AS $x$
 SELECT b.prova_id FROM exam_regia_private.bindings b WHERE p_scope IN(b.prova_id,b.combat_session_id,b.master_session_id)
 OR EXISTS(SELECT 1 FROM public.combat_v2_rounds r WHERE r.id=p_scope AND r.session_id=b.combat_session_id)
 OR EXISTS(SELECT 1 FROM mission_exchange_v3.cycles c WHERE c.id=p_scope AND c.combat_session_id=b.combat_session_id);
$x$;
CREATE FUNCTION exam_regia_private.exchange_context_valid(p_master uuid,p_session uuid,p_round uuid) RETURNS boolean
LANGUAGE sql STABLE SECURITY DEFINER SET search_path='' AS $x$
 SELECT EXISTS(SELECT 1 FROM exam_regia_private.bindings b JOIN public.combat_v2_sessions s ON s.id=b.combat_session_id
 JOIN public.combat_v2_rounds r ON r.session_id=s.id WHERE b.master_session_id=p_master AND s.id=p_session AND r.id=p_round
 AND b.state='active' AND s.source_kind='master' AND NOT s.lesiva AND s.state='in_corso' AND s.closed_at IS NULL
 AND r.round_no BETWEEN 1 AND 8 AND r.state IN('raccolta_azioni','raccolta_difese','risolto'));
$x$;
CREATE TABLE exam_regia_private.exchange_composition_seals (
 signature text PRIMARY KEY, legacy_seal text NOT NULL, before_fingerprint text NOT NULL,
 after_definition_md5 text NOT NULL, after_fingerprint text NOT NULL, owner_name text NOT NULL, acl text NOT NULL);
CREATE FUNCTION exam_regia_private.seal_composition_valid(p_signature text,p_seal text,p_actual text) RETURNS boolean
LANGUAGE sql STABLE SECURITY DEFINER SET search_path='' AS $x$
 SELECT EXISTS(SELECT 1 FROM exam_regia_private.exchange_composition_seals cs
 JOIN pg_proc proc ON proc.oid=to_regprocedure(CASE WHEN position('.' in split_part(cs.signature,'(',1))=0 THEN 'public.' ELSE '' END||cs.signature)
 WHERE cs.signature=p_signature AND cs.legacy_seal=p_seal AND cs.after_fingerprint=p_actual
 AND md5(pg_get_functiondef(proc.oid))=cs.after_definition_md5 AND pg_get_userbyid(proc.proowner)=cs.owner_name AND proc.proacl::text=cs.acl);
$x$;
DO $before_seal$ BEGIN IF mission_exchange_combat_owner.function_fingerprint('public.combat_v2_action_declare(uuid,uuid,jsonb,text,uuid)'::regprocedure) IS DISTINCT FROM '9597f8eb8d9da0352377dfaca0ab54f9c18b3484c04b418a656da04ac6838c09' THEN RAISE EXCEPTION 'exam_exchange_before_seal_drift'; END IF; END $before_seal$;
DO $before_seal$ BEGIN IF mission_exchange_combat_owner.function_fingerprint('public.combat_v2_exchange_context_valid(uuid,uuid,uuid,text)'::regprocedure) IS DISTINCT FROM '35f413c79b2ad810211d723403b9f97e8e6a320b97f753d782fb233b0e826153' THEN RAISE EXCEPTION 'exam_exchange_before_seal_drift'; END IF; END $before_seal$;
DO $before_seal$ BEGIN IF mission_exchange_combat_owner.function_fingerprint('public.combat_v2_exchange_roster_owner(uuid)'::regprocedure) IS DISTINCT FROM 'd5f70048576aae10d0e01c8212d5bc0a559450dfe950c43b36e63cd59c7d6dd8' THEN RAISE EXCEPTION 'exam_exchange_before_seal_drift'; END IF; END $before_seal$;
DO $before_seal$ BEGIN IF mission_exchange_combat_owner.function_fingerprint('public.combat_v2_exchange_owner_receipt(uuid)'::regprocedure) IS DISTINCT FROM '37f0d8da32390252f46e104fa0a5fc15b6ff983a5d614f826d77f8a8fb6b2b57' THEN RAISE EXCEPTION 'exam_exchange_before_seal_drift'; END IF; END $before_seal$;
DO $before_seal$ BEGIN IF mission_exchange_combat_owner.function_fingerprint('public.combat_v2_exchange_counter_intent_owner(uuid,uuid,text)'::regprocedure) IS DISTINCT FROM 'd66240fefb0d528c2dc3cb7840b0252f4406a2bb4b978a48b88ad2a128313ef6' THEN RAISE EXCEPTION 'exam_exchange_before_seal_drift'; END IF; END $before_seal$;
ALTER TABLE public.combat_v2_rounds ADD COLUMN exam_captured_receipt_id uuid;
ALTER TABLE mission_exchange_v3.receipts ADD CONSTRAINT exam_receipt_round_identity UNIQUE(id,combat_round_id);
ALTER TABLE public.combat_v2_rounds ADD CONSTRAINT exam_captured_receipt_round_fk
 FOREIGN KEY(exam_captured_receipt_id,id) REFERENCES mission_exchange_v3.receipts(id,combat_round_id);

ALTER TABLE combat_panel_private.master_panel_sessions DROP CONSTRAINT master_panel_sessions_policy_id_check;
ALTER TABLE combat_panel_private.master_panel_sessions ADD CONSTRAINT master_panel_sessions_policy_id_check CHECK(policy_id IN ('staff_test_no_persistent_resources_v1','master_game_resources_v1','exam_protected_no_persistent_resources_v1'));
ALTER TABLE combat_panel_private.master_scene_profiles DROP CONSTRAINT master_scene_profiles_policy_id_check;
ALTER TABLE combat_panel_private.master_scene_profiles ADD CONSTRAINT master_scene_profiles_policy_id_check CHECK(policy_id IN ('staff_test_no_persistent_resources_v1','master_game_resources_v1','exam_protected_no_persistent_resources_v1'));
ALTER TABLE combat_panel_private.master_scene_claims DROP CONSTRAINT master_scene_claims_policy_id_check;
ALTER TABLE combat_panel_private.master_scene_claims ADD CONSTRAINT master_scene_claims_policy_id_check CHECK(policy_id IN ('staff_test_no_persistent_resources_v1','master_game_resources_v1','exam_protected_no_persistent_resources_v1'));
CREATE OR REPLACE FUNCTION clan_sabaku_private.clone_attach_map(p_view jsonb)
 RETURNS jsonb
 LANGUAGE plpgsql
 STABLE SECURITY DEFINER
 SET search_path TO ''
AS $function$
DECLARE arena_id uuid; objects jsonb; c record; item jsonb; owner_name text;
BEGIN
 IF p_view->>'status' IS DISTINCT FROM 'ready' OR p_view->'map' IS NULL OR p_view->'map'='null'::jsonb THEN RETURN p_view; END IF;
 IF exam_regia_private.current_principal() IS NULL THEN RAISE EXCEPTION 'sabaku_clone_map_auth_required' USING ERRCODE='42501'; END IF;
 SELECT instance_id INTO arena_id FROM combat_spatial.arena_instances
   WHERE encounter_id=(p_view#>>'{context,activity_id}')::uuid AND state='open' AND context_source IN ('ordinary','panel_master');
 IF arena_id IS NULL THEN RETURN p_view; END IF;
 objects:='[]'::jsonb;
 FOR c IN SELECT * FROM clan_sabaku_private.clones WHERE instance_id=arena_id AND state<>'ended' ORDER BY created_at,id LOOP
   SELECT value->>'display_name' INTO owner_name FROM jsonb_array_elements(p_view->'actors') WHERE value->>'actor_id'=c.actor_id::text;
   IF owner_name IS NULL OR NOT combat_panel_private.body_visible_to_viewer(arena_id,c.actor_id) THEN CONTINUE; END IF;
   item:=jsonb_build_object('clone_id',c.id,'owner_actor_id',c.actor_id,'owner_name',owner_name,
     'state',c.state,'x_m',c.x_m,'y_m',c.y_m,'trigger_radius_m',2);
   objects:=objects||jsonb_build_array(item);
 END LOOP;
 RETURN jsonb_set(p_view,'{map,sabaku_clones}',objects);
END $function$;
CREATE OR REPLACE FUNCTION clan_sabaku_private.master_control_offers(p_context uuid, p_expected bigint)
 RETURNS void
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO ''
AS $function$
DECLARE c combat_panel_private.contexts%ROWTYPE; scope jsonb;
 a public.combat_v2_actors%ROWTYPE; s clan_innata_combat_private.combat_state%ROWTYPE;
 operation text; label text;
BEGIN
 c:=combat_panel_private.owned_context(p_context,p_expected);
 IF c.activity_kind<>'master_v2' OR c.command_actor_id IS NULL THEN RETURN; END IF;
 SELECT * INTO STRICT a FROM public.combat_v2_actors WHERE id=c.command_actor_id AND session_id=c.activity_id
   AND exam_regia_private.actor_principal(id,controller_user)=exam_regia_private.current_principal();
 IF clan_sabaku_private.master_bind_ready(a.id) THEN
   PERFORM combat_panel_private.create_offer(c.id,c.context_version,'control','control',
     'Prepara la prova Sabaku: giara personale',false,jsonb_build_object('adapter','master_v2',
       'dispatch','sabaku_control','sabaku_operation','staff_profile','expected_state',0));
   RETURN;
 END IF;
 BEGIN scope:=clan_innata_private.combat_actor_context(a.id);
 EXCEPTION WHEN insufficient_privilege THEN RETURN; END;
 s:=clan_innata_private.combat_state_read(a.id);
 IF s.active THEN operation:='deactivate'; label:='Spegni Controllo della Sabbia · gratuito';
 ELSIF scope->>'phase'='action' AND coalesce((a.mechanics_snapshot->>'chakra')::integer,0)>=5
   AND NOT EXISTS(SELECT 1 FROM clan_marionettisti_private.links WHERE owner_actor_id=a.id AND state='connected') THEN
   operation:='activate'; label:='Attiva Controllo della Sabbia · 5 chakra';
 END IF;
 IF operation IS NOT NULL THEN
   PERFORM combat_panel_private.create_offer(c.id,c.context_version,'control','control',label,false,
     jsonb_build_object('adapter','master_v2','dispatch','sabaku_control','sabaku_operation',operation,'expected_state',s.state_version));
 END IF;
 IF clan_sabaku_private.transport_ready(a.id) THEN
   PERFORM combat_panel_private.create_offer(c.id,c.context_version,'control','control',
     'Trasporto della Sabbia · 5 chakra, 5 sabbia',false,jsonb_build_object('adapter','master_v2',
       'dispatch','sabaku_control','sabaku_operation','transport','expected_state',s.state_version));
 END IF;
END $function$;
CREATE OR REPLACE FUNCTION combat_consumer_private.expected_main_count(p_round uuid)
 RETURNS integer
 LANGUAGE sql
 STABLE SECURITY DEFINER
 SET search_path TO ''
AS $function$
 select case when exam_regia_private.is_bound((select session_id from public.combat_v2_rounds where id=p_round)) OR combat_consumer_private.owns_round(p_round) then 1 else
   (select count(*)::integer from public.combat_v2_actors a join public.combat_v2_rounds r
     on r.session_id=a.session_id where r.id=p_round and a.state='attivo' and clan_marionettisti_private.can_declare(a.id)) end
$function$;
CREATE OR REPLACE FUNCTION combat_consumer_private.narrative_tech_sources_v1(p_claim uuid)
 RETURNS jsonb
 LANGUAGE plpgsql
 STABLE SECURITY DEFINER
 SET search_path TO ''
AS $function$
DECLARE claim combat_consumer_private.narrative_claims%ROWTYPE;
  unit public.combat_v2_rounds%ROWTYPE; ref record; event record; content jsonb;
  exam_scope boolean:=false; exam_owner uuid;
  sources jsonb:='[]'; endings jsonb:='[]'; native_id uuid; source_kind text; multiplication_seen uuid[]:=ARRAY[]::uuid[];
BEGIN
 SELECT er.round_id,rr.session_id,rr.report_id,eb.owner_user INTO claim.round_id,claim.session_id,claim.report_id,exam_owner
 FROM exam_regia_private.receipts er JOIN exam_regia_private.bindings eb ON eb.prova_id=er.prova_id AND eb.receipt_id=er.id
 JOIN public.combat_v2_rounds rr ON rr.id=er.round_id AND rr.session_id=eb.combat_session_id
 JOIN mission_exchange_v3.receipts xr ON xr.combat_round_id=rr.id
 JOIN public.combat_v2_round_reports rp ON rp.id=rr.report_id AND rp.round_id=rr.id
 WHERE er.id=p_claim AND er.kind='narration' AND eb.state='active' AND rr.state IN('risolto','narrazione','narrato')
 AND rp.values_written=false AND rp.mechanics_sha256=public.combat_v2_sha256(rp.mechanics)
 AND xr.combat_owner->>'report_sha256'=rp.mechanics_sha256 AND exam_regia_private.is_bound(rr.session_id);
 exam_scope:=FOUND;
 IF exam_scope THEN
  IF auth.uid() IS NOT NULL OR NOT public.combat_v2_is_service() THEN RAISE EXCEPTION 'exam_tech_service_required' USING ERRCODE='42501'; END IF;
  SELECT * INTO STRICT unit FROM public.combat_v2_rounds WHERE id=claim.round_id;
 ELSE
 SELECT * INTO STRICT claim FROM combat_consumer_private.narrative_claims WHERE id=p_claim;
 SELECT * INTO STRICT unit FROM public.combat_v2_rounds WHERE id=claim.round_id;
 IF unit.session_id IS DISTINCT FROM claim.session_id OR claim.context_payload->>'ordinary' IS DISTINCT FROM 'true'
   OR claim.context_payload->>'genere' IS DISTINCT FROM 'azione_risolta' THEN
   RAISE EXCEPTION 'narrative_tech_scope_invalid' USING ERRCODE='22023';
 END IF;
 IF NOT EXISTS(SELECT 1 FROM combat_consumer_private.activities staff_activity
      JOIN public.combat_v2_sessions staff_session ON staff_session.id=staff_activity.session_id
      JOIN public.locations staff_location ON staff_location.id=staff_activity.location_id
      WHERE staff_activity.session_id=claim.session_id AND staff_activity.exchange_id=claim.round_id
        AND staff_activity.phase='resolved' AND staff_activity.policy_id='staff_test_no_persistent_resources_v1'
        AND staff_session.source_kind='ordinary' AND staff_session.location_id=staff_activity.location_id
        AND staff_location.is_test AND NOT public.combat_v2_values_written(staff_session.id)
        AND combat_consumer_private.staff_test_allowed(staff_location.id,
          (SELECT array_agg(actor.controller_user ORDER BY actor.id)
           FROM combat_consumer_private.members member JOIN public.combat_v2_actors actor
             ON actor.id=member.actor_id AND actor.session_id=member.session_id
             AND actor.character_id=member.character_id
           WHERE member.session_id=claim.session_id),false)) THEN
   RAISE EXCEPTION 'narrative_tech_staff_scope_required' USING ERRCODE='42501';
 END IF;
 END IF;
 -- Native rows certify use: no role-text/name lookup, no inventory scan.
 FOR ref IN
  SELECT DISTINCT x.catalog,x.actor_id FROM (
   SELECT 'clan_techniques'::text catalog,d.actor_id
    FROM public.combat_v2_declarations d
    WHERE d.round_id=claim.round_id AND d.state='risolta'
      AND d.outcome->'sabaku_clone'->>'schema_version'='sabaku-clone/1'
      AND d.kind='utilita'
   UNION
   SELECT 'clan_techniques',c.actor_id FROM clan_sabaku_private.clone_captures cc
    JOIN clan_sabaku_private.clones c ON c.id=cc.clone_id
    WHERE cc.round_id=claim.round_id AND c.session_id=claim.session_id
   UNION
   SELECT 'jutsu',f.actor_id FROM combat_panel_private.multiplication_formations f
    JOIN public.combat_v2_declarations d ON d.id=f.declaration_id
    WHERE f.session_id=claim.session_id AND d.round_id=claim.round_id AND d.state='risolta'
   UNION
   SELECT 'jutsu',f.actor_id FROM combat_panel_private.multiplication_resolutions mr
    JOIN combat_panel_private.multiplication_formations f ON f.id=mr.formation_id
    JOIN public.combat_v2_attack_targets t ON t.id=mr.attack_target_id
    JOIN public.combat_v2_declarations d ON d.id=t.attack_declaration_id
    WHERE f.session_id=claim.session_id AND d.round_id=claim.round_id AND d.state='risolta'
      AND t.state IN('risolta','superflua')
   UNION
   SELECT 'jutsu',f.actor_id FROM clan_sabaku_private.clone_captures cc
    JOIN combat_panel_private.multiplication_formations f ON f.id=cc.formation_id
    WHERE cc.round_id=claim.round_id AND f.session_id=claim.session_id
  ) x ORDER BY x.catalog,x.actor_id
 LOOP
  IF NOT EXISTS(SELECT 1 FROM combat_consumer_private.members m
    WHERE m.session_id=claim.session_id AND m.actor_id=ref.actor_id) AND NOT (exam_scope AND EXISTS(SELECT 1 FROM exam_regia_private.bindings eb WHERE eb.combat_session_id=claim.session_id AND ref.actor_id IN(eb.player_actor_id,eb.png_actor_id))) THEN
   RAISE EXCEPTION 'narrative_tech_actor_not_in_scene' USING ERRCODE='22023';
  END IF;
  IF ref.catalog='clan_techniques' THEN
   native_id:='617484d6-af7b-41c3-a37f-615b22818421';
   SELECT jsonb_build_object('id',id,'name',name,'description',description,'danno_effetto',danno_effetto)
     INTO STRICT content FROM public.clan_techniques WHERE id=native_id;
  ELSE
   native_id:='c6e31b7b-38fe-4b4f-b3c7-05f3e922d193';
   SELECT jsonb_build_object('id',id,'name_it',name_it,'effect',effect,'limits',limits)
     INTO STRICT content FROM public.jutsu WHERE id=native_id;
  END IF;
  sources:=sources||jsonb_build_array(jsonb_build_object('catalog',ref.catalog,'technique_id',native_id,
    'actor_id',ref.actor_id,'mapping_version','ordinary-tech/1','source_sha256',
    encode(extensions.digest(convert_to(content::text,'UTF8'),'sha256'),'hex'),'content',content));
 END LOOP;
 -- Terminal event only when the native capture and native terminal state agree.
 -- No original index, figures, coordinates, dice, private stats, or inference from damage.
 FOR event IN
  SELECT cc.id,cc.copy_hit,cc.result,c.actor_id,c.state,c.end_reason,c.ended_at,cc.created_at
  FROM clan_sabaku_private.clone_captures cc JOIN clan_sabaku_private.clones c ON c.id=cc.clone_id
  WHERE cc.round_id=claim.round_id AND c.session_id=claim.session_id
  ORDER BY cc.created_at,cc.id
 LOOP
  IF event.result->>'schema_version' IS DISTINCT FROM 'sabaku-clone-capture/1'
    OR event.result->'copy_hit' IS DISTINCT FROM to_jsonb(event.copy_hit)
    OR jsonb_typeof(event.result->'success') IS DISTINCT FROM 'boolean' THEN
   RAISE EXCEPTION 'narrative_tech_capture_invalid' USING ERRCODE='22023';
  END IF;
  IF event.result->'success'='false'::jsonb THEN
   IF event.state IS DISTINCT FROM 'ended' OR event.ended_at IS NULL
    OR event.ended_at<event.created_at
    OR event.end_reason IS DISTINCT FROM (CASE WHEN event.copy_hit THEN 'copy_triggered' ELSE 'capture_failed' END) THEN
    RAISE EXCEPTION 'narrative_tech_terminal_event_missing' USING ERRCODE='22023';
   END IF;
   endings:=endings||jsonb_build_array(jsonb_build_object('tecnica','Clone di Sabbia','actor_id',event.actor_id,
      'stato','terminato','causa',event.end_reason));
  END IF;
 END LOOP;

 -- Moltiplicazione: immutable resolution receipt + exact resolved target/round.
 -- Native terminal state alone is insufficient; never infer an ending from damage.
 FOR event IN
  SELECT mr.formation_id, mr.attack_target_id, mr.facts, mr.receipt_sha256,
    mr.created_at AS receipt_at, mr.choice_kind, mr.outcome AS choice_outcome,
    f.actor_id, f.mode, f.state AS formation_state, f.terminal_reason, f.ended_at,
    f.declaration_id AS formation_declaration, t.state AS target_state,
    t.target_actor_id, t.outcome AS target_outcome,
    d.id AS attack_id, d.actor_id AS attacker_id, d.state AS attack_state
  FROM combat_panel_private.multiplication_resolutions mr
  JOIN combat_panel_private.multiplication_formations f ON f.id=mr.formation_id
  JOIN public.combat_v2_attack_targets t ON t.id=mr.attack_target_id
  JOIN public.combat_v2_declarations d ON d.id=t.attack_declaration_id
  WHERE f.session_id=claim.session_id AND t.round_id=claim.round_id
    AND d.round_id=claim.round_id
  ORDER BY mr.formation_id, mr.created_at, mr.attack_target_id
 LOOP
  IF unit.resolved_at IS NULL OR unit.report_id IS DISTINCT FROM claim.report_id
    OR unit.phase NOT IN ('risolto','narrato')
    OR event.attack_state IS DISTINCT FROM 'risolta'
    OR event.target_state IS DISTINCT FROM 'risolta'
    OR jsonb_typeof(event.facts) IS DISTINCT FROM 'object'
    OR event.facts->>'schema_version' IS DISTINCT FROM 'combat-multiplication-resolution/1'
    OR event.facts->'formation_id' IS DISTINCT FROM to_jsonb(event.formation_id)
    OR event.facts->'attack_target_id' IS DISTINCT FROM to_jsonb(event.attack_target_id)
    OR event.facts->>'mode' IS DISTINCT FROM event.mode
    OR event.facts->>'choice_kind' IS DISTINCT FROM event.choice_kind
    OR event.facts->>'outcome' IS DISTINCT FROM event.choice_outcome
    OR event.choice_outcome NOT IN ('original_found','copy_hit')
    OR event.receipt_sha256 IS DISTINCT FROM public.combat_v2_sha256(event.facts)
    OR jsonb_typeof(event.target_outcome->'multiplication') IS DISTINCT FROM 'array'
    OR NOT EXISTS (
      SELECT 1 FROM jsonb_array_elements(CASE
        WHEN jsonb_typeof(event.target_outcome->'multiplication')='array'
        THEN event.target_outcome->'multiplication' ELSE '[]'::jsonb END) item
      WHERE item - 'role' = event.facts
    ) THEN
   RAISE EXCEPTION 'narrative_multiplication_receipt_invalid' USING ERRCODE='22023';
  END IF;
  IF event.formation_state IS DISTINCT FROM 'consumed'
    OR event.ended_at IS NULL OR event.ended_at < event.receipt_at
    OR event.ended_at > unit.resolved_at
    OR event.terminal_reason IS DISTINCT FROM (CASE
      WHEN event.mode='assalto' AND event.formation_declaration=event.attack_id
        AND event.actor_id=event.attacker_id THEN 'assault_resolved'
      ELSE 'first_attack' END)
    OR NOT (
      event.actor_id=event.target_actor_id OR
      (event.mode='assalto' AND event.formation_declaration=event.attack_id
        AND event.actor_id=event.attacker_id)
    )
    OR NOT EXISTS (SELECT 1 FROM combat_consumer_private.members m
      WHERE m.session_id=claim.session_id AND m.actor_id=event.actor_id) AND NOT (exam_scope AND EXISTS(SELECT 1 FROM exam_regia_private.bindings eb WHERE eb.combat_session_id=claim.session_id AND event.actor_id IN(eb.player_actor_id,eb.png_actor_id))) THEN
   RAISE EXCEPTION 'narrative_multiplication_terminal_event_invalid' USING ERRCODE='22023';
  END IF;
  IF NOT event.formation_id=ANY(multiplication_seen) THEN
   endings:=endings||jsonb_build_array(jsonb_build_object(
     'tecnica','Moltiplicazione del corpo','actor_id',event.actor_id,
     'stato','terminato','causa',CASE event.terminal_reason
       WHEN 'first_attack' THEN 'primo_attacco_risolto'
       WHEN 'assault_resolved' THEN 'assalto_risolto' END));
   multiplication_seen:=array_append(multiplication_seen,event.formation_id);
  END IF;
 END LOOP;
 IF exam_scope THEN
  -- Exact native usage, public catalog fields only. Basic substitution has an explicit native catalog identity.
  FOR ref IN SELECT DISTINCT d.actor_id,CASE WHEN d.sanitized_intent->>'reaction'='sostituzione'
    THEN '31b15861-fb78-4f8a-ac1c-ebf2d957c32e'::uuid ELSE (d.sanitized_intent->>'ability_id')::uuid END AS technique_id
   FROM public.combat_v2_declarations d WHERE d.round_id=claim.round_id AND d.state='risolta'
   AND (d.sanitized_intent->>'reaction'='sostituzione' OR (d.sanitized_intent->>'ability_source'='jutsu'
    AND d.sanitized_intent->>'ability_id'~* '^[0-9a-f]{8}(-[0-9a-f]{4}){3}-[0-9a-f]{12}$'))
  LOOP
   IF NOT EXISTS(SELECT 1 FROM jsonb_array_elements(sources) s WHERE s->>'actor_id'=ref.actor_id::text AND s->>'technique_id'=ref.technique_id::text) THEN
    SELECT jsonb_build_object('id',id,'name_it',name_it,'effect',effect,'limits',limits) INTO STRICT content FROM public.jutsu WHERE id=ref.technique_id;
    sources:=sources||jsonb_build_array(jsonb_build_object('catalog','jutsu','technique_id',ref.technique_id,'actor_id',ref.actor_id,
     'mapping_version','exam-native-tech/1','source_sha256',encode(extensions.digest(convert_to(content::text,'UTF8'),'sha256'),'hex'),'content',content));
   END IF;
  END LOOP;
 END IF;
 RETURN jsonb_build_object('fonti_tecniche',sources,'conclusioni_effetti_server',endings);
END $function$;
CREATE OR REPLACE FUNCTION combat_gate_private.engagement_insert_guard()
 RETURNS trigger
 LANGUAGE plpgsql
 SET search_path TO ''
AS $function$
declare v_allowed_same_master boolean:=false;
begin
  if new.character_id is null then return new; end if;
  -- La sessione/claim è già stata inserita dalla RPC esterna; da qui in poi
  -- i personaggi sono acquisiti per UUID prima delle risorse successive.
  perform 1 from public.characters c where c.id=new.character_id
   order by c.id for key share;
  if tg_table_name='combat_v2_actors' then
    select exists(
      select 1 from public.combat_v2_sessions s
      join public.master_v2_participants p
        on p.session_id=s.master_session_id and p.character_id=new.character_id
       and p.engagement_state in ('attivo','sospeso')
      where s.id=new.session_id and s.source_kind='master'
    ) into v_allowed_same_master;
  elsif tg_table_name='master_v2_participants' then
    select exists(
      select 1 from public.combat_v2_sessions s
      join public.combat_v2_actors a
        on a.session_id=s.id and a.character_id=new.character_id and a.state='attivo'
      where s.master_session_id=new.session_id and s.source_kind='master'
        and s.state in ('in_corso','sospeso')
    ) into v_allowed_same_master;
  end if;
  if public._personaggio_impegnato_meccanicamente(new.character_id)
     and not v_allowed_same_master
     and not exam_regia_private.same_exam_entry(new.character_id,new.session_id) then
    raise exception using errcode='P0001', message='personaggio_impegnato';
  end if;
  return new;
end
$function$;
CREATE OR REPLACE FUNCTION combat_panel_private.access_reason(p_location uuid, p_adapter text)
 RETURNS text
 LANGUAGE plpgsql
 STABLE SECURITY DEFINER
 SET search_path TO ''
AS $function$
DECLARE is_test boolean; gate combat_panel_private.release_gate%ROWTYPE;
BEGIN
 IF p_adapter='master_v2' AND EXISTS(SELECT 1 FROM exam_regia_private.bindings b
 WHERE b.location_id=p_location AND b.state<>'closed' AND ((b.owner_user=auth.uid() AND public._combat_presente(auth.uid(),p_location)) OR (auth.uid() IS NULL AND b.service_principal_id=exam_regia_private.current_principal())))
 THEN RETURN NULL; END IF;
 IF exam_regia_private.current_principal() IS NULL THEN RETURN 'authentication_required'; END IF;
 IF p_adapter NOT IN ('ordinary_v2','master_v2') OR p_adapter IS NULL THEN RETURN 'adapter_unavailable'; END IF;
 SELECT l.is_test INTO is_test FROM public.locations l WHERE l.id=p_location AND l.is_active;
 IF NOT FOUND OR NOT coalesce(public._combat_presente(exam_regia_private.current_principal(),p_location),false) THEN RETURN 'location_unavailable'; END IF;
 SELECT * INTO STRICT gate FROM combat_panel_private.release_gate WHERE singleton;
 IF is_test THEN
   IF NOT gate.staff_enabled THEN RETURN 'release_not_enabled'; END IF;
   IF NOT combat_consumer_private.staff_test_allowed(p_location,ARRAY[exam_regia_private.current_principal()],false) THEN RETURN 'staff_scope_not_allowed'; END IF;
 ELSIF (p_adapter='ordinary_v2' AND NOT gate.ordinary_enabled) OR (p_adapter='master_v2' AND NOT gate.master_enabled) THEN
   RETURN 'release_not_enabled';
 END IF;
 RETURN NULL;
END $function$;
CREATE OR REPLACE FUNCTION combat_panel_private.add_choice(p_group uuid, p_label text, p_payload jsonb, p_distance numeric DEFAULT NULL::numeric, p_direction text DEFAULT NULL::text)
 RETURNS uuid
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO ''
AS $function$
DECLARE g combat_panel_private.choice_groups%ROWTYPE; cid uuid;
BEGIN
 SELECT g0.* INTO STRICT g FROM combat_panel_private.choice_groups g0 JOIN combat_panel_private.offers o
   ON o.id=g0.offer_id AND o.principal_user=exam_regia_private.current_principal() AND o.state='offered' WHERE g0.id=p_group FOR UPDATE OF o;
 INSERT INTO combat_panel_private.choice_options(offer_id,group_id,label,source_payload,distance_m,direction,ordinal)
   SELECT g.offer_id,g.id,p_label,p_payload,p_distance,p_direction,coalesce(max(ordinal)+1,0)
   FROM combat_panel_private.choice_options WHERE group_id=g.id RETURNING id INTO cid;
 RETURN cid;
END $function$;
CREATE OR REPLACE FUNCTION combat_panel_private.add_group(p_offer uuid, p_label text, p_purpose text, p_mode text, p_min integer, p_max integer, p_dependency uuid DEFAULT NULL::uuid)
 RETURNS uuid
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO ''
AS $function$
DECLARE o combat_panel_private.offers%ROWTYPE; gid uuid;
BEGIN
 SELECT * INTO STRICT o FROM combat_panel_private.offers WHERE id=p_offer
   AND principal_user=exam_regia_private.current_principal() AND state='offered' FOR UPDATE;
 PERFORM combat_panel_private.owned_context(o.context_id,o.context_version);
 INSERT INTO combat_panel_private.choice_groups(offer_id,label,purpose,selection_mode,min_selected,max_selected,depends_on,ordinal)
   SELECT o.id,p_label,p_purpose,p_mode,p_min,p_max,p_dependency,coalesce(max(ordinal)+1,0)
     FROM combat_panel_private.choice_groups WHERE offer_id=o.id RETURNING id INTO gid;
 RETURN gid;
END $function$;
CREATE OR REPLACE FUNCTION combat_panel_private.add_input(p_offer uuid, p_label text, p_source_key text, p_required boolean, p_max integer)
 RETURNS void
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO ''
AS $function$
BEGIN
 PERFORM 1 FROM combat_panel_private.offers WHERE id=p_offer AND principal_user=exam_regia_private.current_principal() AND state='offered' FOR UPDATE;
 IF NOT FOUND THEN RAISE EXCEPTION 'panel_offer_not_available' USING ERRCODE='42501'; END IF;
 INSERT INTO combat_panel_private.input_fields(offer_id,label,value_type,required,max_length,source_key,ordinal)
   SELECT p_offer,p_label,'text',p_required,p_max,p_source_key,coalesce(max(ordinal)+1,0)
   FROM combat_panel_private.input_fields WHERE offer_id=p_offer;
END $function$;
CREATE OR REPLACE FUNCTION combat_panel_private.assert_master_ready(p_encounter uuid)
 RETURNS void
 LANGUAGE plpgsql
 STABLE SECURITY DEFINER
 SET search_path TO ''
AS $function$
DECLARE s public.combat_v2_sessions%ROWTYPE; iid uuid;
BEGIN
 SELECT * INTO STRICT s FROM public.combat_v2_sessions WHERE id=p_encounter;
 IF s.source_kind<>'master' OR NOT EXISTS(SELECT 1 FROM combat_panel_private.master_panel_sessions
   WHERE master_session_id=s.master_session_id) THEN RETURN; END IF;
 SELECT instance_id INTO iid FROM combat_spatial.arena_instances
   WHERE encounter_id=s.id AND master_session_id=s.master_session_id AND context_source='panel_master' AND state='open';
 IF iid IS NULL OR EXISTS(SELECT 1 FROM public.combat_v2_actors a WHERE a.session_id=s.id AND a.state='attivo'
   AND NOT EXISTS(SELECT 1 FROM combat_spatial.actor_states b WHERE b.instance_id=iid AND b.actor_id=a.id
     AND b.state='active' AND b.controller_principal_id IS NOT DISTINCT FROM exam_regia_private.actor_principal(a.id,a.controller_user))) THEN
   RAISE EXCEPTION 'panel_master_placement_required' USING ERRCODE='40001'; END IF;
END $function$;
CREATE OR REPLACE FUNCTION combat_panel_private.attach_rating_offers(p_envelope jsonb, p_context uuid)
 RETURNS jsonb
 LANGUAGE plpgsql
 STABLE SECURITY DEFINER
 SET search_path TO ''
AS $function$
DECLARE details jsonb; declarations jsonb; c combat_panel_private.contexts%ROWTYPE;
BEGIN
 details:=p_envelope->'round_details'; IF jsonb_typeof(details) IS DISTINCT FROM 'object' THEN RETURN p_envelope; END IF;
 c:=combat_panel_private.owned_context(p_context,(p_envelope#>>'{context,version}')::bigint);
 SELECT coalesce(jsonb_agg(jsonb_set(d,'{rating_offer_id}',coalesce((SELECT to_jsonb(o.id) FROM combat_panel_private.offers o
   WHERE o.context_id=c.id AND o.context_version=c.context_version AND o.principal_user=exam_regia_private.current_principal() AND o.state='offered'
     AND o.source_payload->>'dispatch'='rating' AND o.source_payload->>'declaration_id'=d->>'declaration_id' LIMIT 1),'null'::jsonb)) ORDER BY ordinal),'[]')
   INTO declarations FROM jsonb_array_elements(details->'declarations') WITH ORDINALITY AS x(d,ordinal);
 RETURN jsonb_set(p_envelope,'{round_details,declarations}',declarations);
END $function$;
CREATE OR REPLACE FUNCTION combat_panel_private.bind_master_movement(p_declaration uuid)
 RETURNS void
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO ''
AS $function$
DECLARE d public.combat_v2_declarations%ROWTYPE;
BEGIN
 SELECT * INTO STRICT d FROM public.combat_v2_declarations WHERE id=p_declaration;
 IF d.kind<>'movimento' OR d.sanitized_intent->>'movement_contract' IS DISTINCT FROM 'combat-panel-movement/1' THEN RETURN; END IF;
 UPDATE combat_panel_private.master_movement_plans SET declaration_id=d.id,state='declared'
   WHERE request_key=d.request_key AND actor_id=d.actor_id AND round_id=d.round_id
     AND principal_user=exam_regia_private.current_principal() AND controller_version=d.controller_version_snapshot AND state='prepared';
 IF NOT FOUND THEN RAISE EXCEPTION 'panel_movement_plan_missing' USING ERRCODE='22023'; END IF;
END $function$;
CREATE OR REPLACE FUNCTION combat_panel_private.body_visible_to_viewer(p_instance uuid, p_actor uuid)
 RETURNS boolean
 LANGUAGE plpgsql
 STABLE SECURITY DEFINER
 SET search_path TO ''
AS $function$
DECLARE i combat_spatial.arena_instances%ROWTYPE; s public.combat_v2_sessions%ROWTYPE;
 b combat_spatial.actor_states%ROWTYPE; src jsonb; native_map jsonb; round_no integer;
BEGIN
 IF exam_regia_private.current_principal() IS NULL THEN RETURN false; END IF;
 SELECT * INTO i FROM combat_spatial.arena_instances WHERE instance_id=p_instance AND state='open';
 IF NOT FOUND THEN RETURN false; END IF;
 SELECT * INTO s FROM public.combat_v2_sessions WHERE id=i.encounter_id
   AND closed_at IS NULL AND state NOT IN ('chiuso','annullato');
 IF NOT FOUND THEN RETURN false; END IF;
 SELECT * INTO b FROM combat_spatial.actor_states WHERE instance_id=i.instance_id AND actor_id=p_actor AND state='active';
 IF NOT FOUND OR NOT EXISTS(SELECT 1 FROM public.combat_v2_actors WHERE id=b.actor_id AND session_id=s.id AND state='attivo') THEN RETURN false; END IF;
 IF i.context_source='ordinary' AND EXISTS(SELECT 1 FROM combat_consumer_private.activities
   WHERE session_id=s.id AND location_id=s.location_id AND phase<>'closed') THEN
   -- Projection privata già soggetta ad accesso, presenza, policy e membership.
   -- Il grant geometrico del POV non deve essere scambiato per un grant nemico.
   src:=combat_consumer_private.state_projection(s.location_id);
   RETURN src->>'status'='ready' AND src#>>'{context,activity_id}'=s.id::text
     AND EXISTS(SELECT 1 FROM jsonb_array_elements(coalesce(src#>'{map,actors}','[]')) a
       WHERE a->>'actor_id'=p_actor::text);
 ELSIF i.context_source='panel_master' THEN
   src:=public.master_v2_ui_state(s.location_id)->'data';
   IF src#>>'{encounter,id}' IS DISTINCT FROM s.id::text THEN RETURN false; END IF;
   round_no:=coalesce((src#>>'{round,no}')::integer,1);
   native_map:=combat_spatial.map_projection(i.instance_id,exam_regia_private.current_principal(),round_no);
   RETURN EXISTS(SELECT 1 FROM jsonb_array_elements(coalesce(native_map->'actors','[]')) a
     WHERE a->>'subject'=b.projection_subject_id::text);
 END IF;
 RETURN false;
END $function$;
CREATE OR REPLACE FUNCTION combat_panel_private.commit_master_actor(p_command jsonb)
 RETURNS jsonb
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO ''
AS $function$
DECLARE p jsonb; uid uuid:=exam_regia_private.current_principal(); key uuid; fp text; receipt_id uuid:=gen_random_uuid();
 prior combat_panel_private.request_receipts%ROWTYPE; o combat_panel_private.offers%ROWTYPE;
 c combat_panel_private.contexts%ROWTYPE; a public.combat_v2_actors%ROWTYPE;
 env jsonb; resolved jsonb; selected uuid[]; payload jsonb; intent jsonb; result jsonb; receipt jsonb;
 targets uuid[]:='{}'; coverages uuid[]:='{}'; primary_attack uuid; movement uuid; substitution uuid;
 declaration uuid; label text; target_label text; event jsonb; dispatch text;
BEGIN
 IF uid IS NULL THEN RAISE EXCEPTION 'panel_authentication_required' USING ERRCODE='28000'; END IF;
 p:=combat_panel_private.validate_command(p_command); key:=(p->>'request_key')::uuid; fp:=public.combat_v2_sha256(p);
 PERFORM pg_advisory_xact_lock(hashtextextended('panel-request:'||uid::text||':'||key::text,731));
 SELECT * INTO prior FROM combat_panel_private.request_receipts WHERE principal_user=uid AND request_key=key;
 IF prior.request_key IS NOT NULL THEN
   IF prior.command_fingerprint<>fp THEN RAISE EXCEPTION 'panel_request_key_conflict' USING ERRCODE='22023'; END IF;
   RETURN jsonb_set(prior.viewer_envelope,'{receipt,replayed}','true',false);
 END IF;
 SELECT * INTO o FROM combat_panel_private.offers WHERE id=(p->>'offer_id')::uuid AND principal_user=uid;
 IF o.id IS NULL OR o.source_payload->>'adapter' IS DISTINCT FROM 'master_v2'
   OR o.kind NOT IN ('action','defense') THEN RAISE EXCEPTION 'panel_offer_not_available' USING ERRCODE='42501'; END IF;
 SELECT * INTO STRICT c FROM combat_panel_private.contexts WHERE id=o.context_id AND principal_user=uid;
 IF c.activity_kind<>'master_v2' OR c.round_id IS NULL
   OR c.location_id IS DISTINCT FROM (p->>'location_id')::uuid OR c.activity_id IS DISTINCT FROM (p->>'activity_id')::uuid THEN
   RAISE EXCEPTION 'panel_activity_scope_invalid' USING ERRCODE='22023'; END IF;
 PERFORM public.combat_v2_lock_round(c.round_id);
 env:=combat_panel_private.master_projection(c.location_id,c.command_actor_id);
 PERFORM 1 FROM combat_panel_private.contexts WHERE id=c.id FOR UPDATE;
 c:=combat_panel_private.owned_context(c.id,(p->>'context_version')::bigint);
 SELECT * INTO STRICT o FROM combat_panel_private.offers WHERE id=o.id FOR UPDATE;
 IF o.state<>'offered' OR o.context_version<>c.context_version OR o.source_fingerprint IS DISTINCT FROM c.source_fingerprint
   OR o.scene_version IS DISTINCT FROM c.scene_version OR o.actor_id IS DISTINCT FROM c.command_actor_id THEN
   RAISE EXCEPTION 'panel_offer_not_available' USING ERRCODE='40001'; END IF;
 IF o.requires_role AND length(btrim(p->>'narrative_text'))=0 THEN RAISE EXCEPTION 'panel_role_required' USING ERRCODE='22023'; END IF;
 SELECT * INTO STRICT a FROM public.combat_v2_actors WHERE id=o.actor_id AND session_id=c.activity_id
   AND exam_regia_private.actor_principal(id,controller_user)=uid AND companion_id IS NULL AND state='attivo' FOR UPDATE;
 SELECT coalesce(array_agg(value::uuid),'{}') INTO selected FROM jsonb_array_elements_text(p->'selected_option_ids');
 resolved:=combat_panel_private.resolve_selections(o.id,selected,p->'inputs');
 FOR payload IN SELECT choice->'payload' FROM jsonb_array_elements(resolved->'groups') AS groups(g)
   CROSS JOIN LATERAL jsonb_array_elements(g->'options') AS choices(choice) LOOP
   IF payload ? 'attack_target_id' THEN
     coverages:=array_append(coverages,(payload->>'attack_target_id')::uuid);
     primary_attack:=coalesce(primary_attack,(payload->>'attack_declaration_id')::uuid);
   ELSIF payload ? 'target_actor_id' THEN targets:=array_append(targets,(payload->>'target_actor_id')::uuid);
   END IF;
   IF payload ? 'movement_capability_id' THEN
     IF movement IS NOT NULL THEN RAISE EXCEPTION 'panel_movement_selection_conflict' USING ERRCODE='22023'; END IF;
     movement:=(payload->>'movement_capability_id')::uuid;
   END IF;
   IF payload ? 'substitution_option_id' THEN
     IF substitution IS NOT NULL THEN RAISE EXCEPTION 'panel_substitution_selection_conflict' USING ERRCODE='22023'; END IF;
     substitution:=(payload->>'substitution_option_id')::uuid;
   END IF;
 END LOOP;
 dispatch:=o.source_payload->>'dispatch';
 IF dispatch IN ('action','movement') THEN
   intent:=jsonb_build_object('kind',o.source_payload->'kind');
   IF intent->>'kind'='attacco' THEN
     IF cardinality(targets)=0 THEN RAISE EXCEPTION 'panel_target_required' USING ERRCODE='22023'; END IF;
     intent:=intent||jsonb_build_object('target_actor',targets[1],'target_actor_ids',targets,
       'ability_source',o.source_payload->'ability_source');
     IF o.source_payload ? 'ability_id' THEN intent:=intent||jsonb_build_object('ability_id',o.source_payload->'ability_id'); END IF;
   ELSIF dispatch='movement' THEN
     IF movement IS NULL THEN RAISE EXCEPTION 'panel_movement_required' USING ERRCODE='22023'; END IF;
     PERFORM combat_panel_private.prepare_master_movement(c.round_id,a.id,movement,key);
   END IF;
   IF intent->>'kind'='attacco' THEN
     PERFORM combat_panel_private.multiplication_prepare_selected_aims(c.round_id,a.id,key,targets,resolved);
   END IF;
   result:=public.combat_v2_action_declare(c.round_id,a.id,intent,p->>'narrative_text',key);
   declaration:=(result#>>'{data,declaration_id}')::uuid;
 ELSIF dispatch='defense' THEN
   IF cardinality(coverages)=0 OR primary_attack IS NULL THEN RAISE EXCEPTION 'panel_coverage_required' USING ERRCODE='22023'; END IF;
   intent:=jsonb_build_object('reaction',o.source_payload->'reaction','attack_target_ids',coverages);
   IF o.source_payload ? 'ability_id' THEN intent:=intent||jsonb_build_object(
     'ability_source',o.source_payload->'ability_source','ability_id',o.source_payload->'ability_id'); END IF;
   result:=public.combat_v2_defense_declare(c.round_id,primary_attack,a.id,intent,p->>'narrative_text',key);
   declaration:=(result#>>'{data,defense_id}')::uuid;
 ELSIF dispatch='substitution' THEN
   IF substitution IS NULL THEN RAISE EXCEPTION 'panel_substitution_required' USING ERRCODE='22023'; END IF;
   PERFORM clan_marionettisti_private.assert_jutsu_source(a.id,'jutsu','31b15861-fb78-4f8a-ac1c-ebf2d957c32e');
   IF EXISTS(SELECT 1 FROM combat_spatial.request_receipts WHERE request_key=key) THEN
     RAISE EXCEPTION 'panel_request_key_conflict' USING ERRCODE='22023'; END IF;
   result:=public.combat_v2_substitution_select_v1(substitution,key);
   declaration:=(result->>'defense_declaration_id')::uuid;
   -- Il selector vivo crea il testo vuoto. Completa solo la dichiarazione
   -- appena creata, ancora inviata e controllata, nella stessa transazione.
   UPDATE public.combat_v2_declarations SET declaration_text=p->>'narrative_text'
     WHERE id=declaration AND round_id=c.round_id AND actor_id=a.id AND request_key=key
       AND controller_user_snapshot=uid AND state='inviata' AND declaration_text='';
   IF NOT FOUND THEN RAISE EXCEPTION 'panel_substitution_declaration_invalid' USING ERRCODE='22023'; END IF;
 ELSE RAISE EXCEPTION 'panel_dispatch_not_available' USING ERRCODE='22023'; END IF;
 IF declaration IS NULL THEN RAISE EXCEPTION 'panel_source_receipt_invalid' USING ERRCODE='22023'; END IF;
 IF o.operation='defend' THEN
   PERFORM combat_panel_private.multiplication_register_defense_selections(c.round_id,a.id,key,resolved,declaration); END IF;
 PERFORM combat_panel_private.publish_master_declaration(declaration,p->>'narrative_text');
 SELECT value->>'display_name' INTO label FROM jsonb_array_elements(env->'actors') WHERE value->>'actor_id'=a.id::text;
 IF cardinality(targets)>0 THEN
   SELECT value->>'display_name' INTO target_label FROM jsonb_array_elements(env->'actors') WHERE value->>'actor_id'=targets[1]::text;
 END IF;
 event:=jsonb_build_object('event_id',receipt_id,'event_kind','action_declared','actor_id',a.id,'display_name',label,
   'label_version',c.context_version,'target_actor_id',CASE WHEN target_label IS NOT NULL THEN targets[1] END,
   'target_display_name',target_label,'target_label_version',CASE WHEN target_label IS NOT NULL THEN c.context_version END,
   'summary',CASE WHEN o.operation='defend' THEN 'Difesa registrata' ELSE 'Azione registrata' END);
 env:=combat_panel_private.master_projection(c.location_id,a.id);
 receipt:=jsonb_build_object('receipt_id',receipt_id,'request_key',key,'operation',o.operation,'replayed',false,
   'activity_id',c.activity_id,'round_id',c.round_id,'context_version_before',o.context_version,
   'context_version_after',env#>'{context,version}','declaration_id',declaration,'report_id',NULL,
   'values_written',false,'display_events',jsonb_build_array(event));
 env:=jsonb_set(env,'{receipt}',receipt);
 UPDATE combat_panel_private.offers SET state='consumed',consumed_request_key=key WHERE id=o.id;
 INSERT INTO combat_panel_private.request_receipts(principal_user,request_key,command_fingerprint,offer_id,event_id,viewer_envelope)
   VALUES(uid,key,fp,o.id,receipt_id,env);
 RETURN env;
END $function$;
CREATE OR REPLACE FUNCTION combat_panel_private.commit_multiplication(p_command jsonb)
 RETURNS jsonb
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO ''
AS $function$
DECLARE p jsonb; uid uuid:=exam_regia_private.current_principal(); key uuid; fp text; event_id uuid:=gen_random_uuid();
 prior combat_panel_private.request_receipts%ROWTYPE; o combat_panel_private.offers%ROWTYPE;
 c combat_panel_private.contexts%ROWTYPE; a public.combat_v2_actors%ROWTYPE;
 activity combat_consumer_private.activities%ROWTYPE; report public.combat_v2_round_reports%ROWTYPE;
 env jsonb; resolved jsonb; selected uuid[]; payload jsonb; intent jsonb; result jsonb; receipt jsonb;
 mode text; copies integer; figures jsonb; original integer; target uuid; movement uuid; assault_draw jsonb; explicit_target boolean:=false;
 declaration uuid; resolve_key uuid; label text; target_label text; display_event jsonb;
BEGIN
 IF uid IS NULL THEN RAISE EXCEPTION 'panel_authentication_required' USING ERRCODE='28000'; END IF;
 p:=combat_panel_private.validate_command(p_command);key:=(p->>'request_key')::uuid;fp:=public.combat_v2_sha256(p);
 PERFORM pg_advisory_xact_lock(hashtextextended('panel-request:'||uid::text||':'||key::text,731));
 SELECT * INTO prior FROM combat_panel_private.request_receipts WHERE principal_user=uid AND request_key=key;
 IF prior.request_key IS NOT NULL THEN
   IF prior.command_fingerprint<>fp THEN RAISE EXCEPTION 'panel_request_key_conflict' USING ERRCODE='22023'; END IF;
   RETURN jsonb_set(prior.viewer_envelope,'{receipt,replayed}','true',false);
 END IF;
 SELECT * INTO o FROM combat_panel_private.offers WHERE id=(p->>'offer_id')::uuid AND principal_user=uid;
 IF o.id IS NULL OR o.kind<>'action' OR o.operation<>'declare'
   OR o.source_payload->>'dispatch' IS DISTINCT FROM 'multiplication'
   OR o.source_payload->>'adapter' IS NULL OR o.source_payload->>'adapter' NOT IN ('ordinary_v2','master_v2') THEN
   RAISE EXCEPTION 'panel_offer_not_available' USING ERRCODE='42501'; END IF;
 SELECT * INTO STRICT c FROM combat_panel_private.contexts WHERE id=o.context_id AND principal_user=uid;
 IF c.round_id IS NULL OR c.activity_kind IS DISTINCT FROM o.source_payload->>'adapter'
   OR c.location_id IS DISTINCT FROM (p->>'location_id')::uuid OR c.activity_id IS DISTINCT FROM (p->>'activity_id')::uuid THEN
   RAISE EXCEPTION 'panel_activity_scope_invalid' USING ERRCODE='22023'; END IF;
 PERFORM public.combat_v2_lock_round(c.round_id);
 IF c.activity_kind='ordinary_v2' THEN env:=combat_panel_private.ordinary_projection(c.location_id,c.command_actor_id);
 ELSE env:=combat_panel_private.master_projection(c.location_id,c.command_actor_id); END IF;
 IF env->>'status' IS DISTINCT FROM 'ready' THEN RAISE EXCEPTION 'panel_source_not_ready' USING ERRCODE='40001'; END IF;
 PERFORM 1 FROM combat_panel_private.contexts WHERE id=c.id FOR UPDATE;
 c:=combat_panel_private.owned_context(c.id,(p->>'context_version')::bigint);
 SELECT * INTO STRICT o FROM combat_panel_private.offers WHERE id=o.id FOR UPDATE;
 IF o.state<>'offered' OR o.context_version<>c.context_version OR o.source_fingerprint IS DISTINCT FROM c.source_fingerprint
   OR o.scene_version IS DISTINCT FROM c.scene_version OR o.actor_id IS DISTINCT FROM c.command_actor_id THEN
   RAISE EXCEPTION 'panel_offer_not_available' USING ERRCODE='40001'; END IF;
 IF NOT o.requires_role OR length(btrim(p->>'narrative_text'))=0 THEN
   RAISE EXCEPTION 'panel_role_required' USING ERRCODE='22023'; END IF;
 SELECT * INTO STRICT a FROM public.combat_v2_actors WHERE id=o.actor_id AND session_id=c.activity_id
   AND exam_regia_private.actor_principal(id,controller_user)=uid AND companion_id IS NULL AND state='attivo' FOR UPDATE;
 SELECT coalesce(array_agg(value::uuid),'{}') INTO selected FROM jsonb_array_elements_text(p->'selected_option_ids');
 resolved:=combat_panel_private.resolve_selections(o.id,selected,p->'inputs');
 IF resolved->'inputs' IS DISTINCT FROM '{}'::jsonb THEN RAISE EXCEPTION 'panel_input_not_offered' USING ERRCODE='22023'; END IF;
 FOR payload IN SELECT choice->'payload' FROM jsonb_array_elements(resolved->'groups') AS groups(g)
   CROSS JOIN LATERAL jsonb_array_elements(g->'options') AS choices(choice) LOOP
   IF payload ? 'multiplication_assault_draw' THEN
    IF assault_draw IS NOT NULL THEN RAISE EXCEPTION 'panel_multiplication_selection_conflict' USING ERRCODE='22023'; END IF;
    assault_draw:=payload->'multiplication_assault_draw';
   END IF;
   IF payload ? 'multiplication_attack_target' THEN explicit_target:=true; END IF;
   IF payload ? 'multiplication_mode' THEN
     IF mode IS NOT NULL THEN RAISE EXCEPTION 'panel_multiplication_selection_conflict' USING ERRCODE='22023'; END IF;
     mode:=payload->>'multiplication_mode';
   END IF;
   IF payload ? 'multiplication_copies' THEN
     IF copies IS NOT NULL THEN RAISE EXCEPTION 'panel_multiplication_selection_conflict' USING ERRCODE='22023'; END IF;
     copies:=(payload->>'multiplication_copies')::integer;
   END IF;
   IF payload ? 'multiplication_figures' THEN
     IF figures IS NOT NULL THEN RAISE EXCEPTION 'panel_multiplication_selection_conflict' USING ERRCODE='22023'; END IF;
     figures:=payload->'multiplication_figures';
   END IF;
   IF payload ? 'multiplication_original' THEN
     IF original IS NOT NULL THEN RAISE EXCEPTION 'panel_multiplication_selection_conflict' USING ERRCODE='22023'; END IF;
     original:=(payload->>'multiplication_original')::integer;
     movement:=(payload->>'multiplication_movement_capability_id')::uuid;
   END IF;
   IF payload ? 'target_actor_id' THEN
     IF target IS NOT NULL THEN RAISE EXCEPTION 'panel_multiplication_selection_conflict' USING ERRCODE='22023'; END IF;
     target:=(payload->>'target_actor_id')::uuid;
   END IF;
 END LOOP;
 IF mode IS NULL OR copies IS NULL OR figures IS NULL OR original IS NULL THEN
   RAISE EXCEPTION 'panel_multiplication_selection_incomplete' USING ERRCODE='22023'; END IF;
 IF mode IS DISTINCT FROM 'assalto' THEN
   RAISE EXCEPTION 'panel_multiplication_mode_paused' USING ERRCODE='22023'; END IF;
 -- Nessuna scrittura alle risorse: piano/movimento/nativa/chat stanno nella
 -- stessa TX del gateway, il cui handler annulla anche gli effetti parziali.
 IF assault_draw IS NOT NULL AND (mode IS DISTINCT FROM 'assalto' OR explicit_target
  OR assault_draw->>'target_actor_id' IS DISTINCT FROM target::text) THEN
  RAISE EXCEPTION 'panel_multiplication_selection_conflict' USING ERRCODE='22023'; END IF;
 IF mode='assalto' THEN
  IF assault_draw IS NOT NULL THEN
   PERFORM combat_panel_private.multiplication_prepare_assault_draw(c.round_id,a.id,target,
    (assault_draw->>'formation_id')::uuid,(assault_draw->>'state_version')::bigint,
    assault_draw->'eligible_indices',copies,figures,original,key);
  ELSE
   PERFORM combat_panel_private.multiplication_prepare_selected_aims(c.round_id,a.id,key,ARRAY[target],resolved);
  END IF;
 END IF;
 PERFORM combat_panel_private.multiplication_prepare_declaration(c.round_id,a.id,mode,copies,figures,original,target,movement,key);
 IF movement IS NOT NULL AND clan_sabaku_private.clone_movement_interruption(movement) IS NOT NULL THEN
   IF c.activity_kind='ordinary_v2' THEN
     UPDATE combat_consumer_private.activities SET context_version=context_version+1,last_action_at=clock_timestamp()
       WHERE session_id=c.activity_id;
   END IF;
   SELECT value->>'display_name' INTO label FROM jsonb_array_elements(env->'actors') WHERE value->>'actor_id'=a.id::text;
   display_event:=combat_consumer_private.validate_display_event(jsonb_build_object('event_id',event_id,'event_kind','movement',
     'actor_id',a.id,'display_name',label,'label_version',c.context_version,'target_actor_id',null,'target_display_name',null,
     'target_label_version',null,'summary','La presa interrompe lo spostamento prima della Moltiplicazione. L’azione principale resta disponibile.'));
   IF c.activity_kind='ordinary_v2' THEN env:=combat_panel_private.ordinary_projection(c.location_id,a.id);
   ELSE env:=combat_panel_private.master_projection(c.location_id,a.id); END IF;
   receipt:=jsonb_build_object('receipt_id',event_id,'request_key',key,'operation','declare','replayed',false,
     'activity_id',c.activity_id,'round_id',c.round_id,'context_version_before',o.context_version,
     'context_version_after',env#>'{context,version}','declaration_id',null,'report_id',null,'values_written',false,
     'display_events',jsonb_build_array(display_event));
   env:=jsonb_set(env,'{receipt}',receipt);
   UPDATE combat_panel_private.offers SET state='consumed',consumed_request_key=key WHERE id=o.id;
   INSERT INTO combat_panel_private.request_receipts(principal_user,request_key,command_fingerprint,offer_id,event_id,viewer_envelope)
     VALUES(uid,key,fp,o.id,event_id,env);
   RETURN env;
 END IF;

 intent:=jsonb_build_object('kind',CASE WHEN mode='assalto' THEN 'attacco' ELSE 'utilita' END);
 IF mode='assalto' THEN intent:=intent||jsonb_build_object('target_actor',target,'ability_source','mano'); END IF;
 IF c.activity_kind='ordinary_v2' THEN
   SELECT * INTO STRICT activity FROM combat_consumer_private.activities WHERE session_id=c.activity_id AND exchange_id=c.round_id FOR UPDATE;
   IF a.actor_kind<>'pg' OR a.character_id IS NULL OR activity.phase<>'action' OR activity.turn_actor_id<>a.id THEN
     RAISE EXCEPTION 'panel_multiplication_turn_stale' USING ERRCODE='40001'; END IF;
   INSERT INTO combat_consumer_private.dispatch_authorizations
     VALUES(key,c.round_id,a.character_id,txid_current(),'declare','prepared');
 END IF;
 -- assert_dispatch e tutte le guardie native restano obbligatorie.
 result:=public.combat_v2_action_declare(c.round_id,a.id,intent,p->>'narrative_text',key);
 declaration:=(result#>>'{data,declaration_id}')::uuid;
 IF declaration IS NULL OR NOT EXISTS(SELECT 1 FROM combat_panel_private.multiplication_declaration_plans
     WHERE request_key=key AND declaration_id=declaration AND formation_id IS NOT NULL) THEN
   RAISE EXCEPTION 'panel_multiplication_binding_missing'; END IF;
 IF c.activity_kind='ordinary_v2' THEN
   UPDATE combat_consumer_private.dispatch_authorizations SET state='consumed'
     WHERE request_key=key AND round_id=c.round_id AND operation='declare';
   UPDATE combat_consumer_private.activities SET phase='defense' WHERE session_id=c.activity_id;
   IF mode<>'assalto' THEN
     resolve_key:=gen_random_uuid();
     INSERT INTO combat_consumer_private.dispatch_authorizations
       VALUES(resolve_key,c.round_id,a.character_id,txid_current(),'resolve','prepared');
     PERFORM public.combat_v2_round_resolve(c.round_id,resolve_key);
     UPDATE combat_consumer_private.dispatch_authorizations SET state='consumed'
       WHERE request_key=resolve_key AND round_id=c.round_id AND operation='resolve';
     SELECT * INTO STRICT report FROM public.combat_v2_round_reports WHERE round_id=c.round_id;
     UPDATE combat_consumer_private.activities SET phase='resolved' WHERE session_id=c.activity_id;
   END IF;
   PERFORM combat_consumer_private.record_message(declaration,public.post_message(c.location_id,p->>'narrative_text',null,null,null));
   UPDATE combat_consumer_private.activities SET context_version=context_version+1,last_action_at=clock_timestamp() WHERE session_id=c.activity_id;
 ELSE PERFORM combat_panel_private.publish_master_declaration(declaration,p->>'narrative_text'); END IF;
 SELECT value->>'display_name' INTO label FROM jsonb_array_elements(env->'actors') WHERE value->>'actor_id'=a.id::text;
 IF target IS NOT NULL THEN SELECT value->>'display_name' INTO target_label FROM jsonb_array_elements(env->'actors') WHERE value->>'actor_id'=target::text; END IF;
 display_event:=jsonb_build_object('event_id',event_id,'event_kind','action_declared','actor_id',a.id,'display_name',label,
   'label_version',c.context_version,'target_actor_id',CASE WHEN target_label IS NOT NULL THEN target END,
   'target_display_name',target_label,'target_label_version',CASE WHEN target_label IS NOT NULL THEN c.context_version END,
   'summary','Moltiplicazione registrata');
 IF c.activity_kind='ordinary_v2' THEN env:=combat_panel_private.ordinary_projection(c.location_id,a.id);
 ELSE env:=combat_panel_private.master_projection(c.location_id,a.id); END IF;
 receipt:=jsonb_build_object('receipt_id',event_id,'request_key',key,'operation','declare','replayed',false,
   'activity_id',c.activity_id,'round_id',c.round_id,'context_version_before',o.context_version,
   'context_version_after',env#>'{context,version}','declaration_id',declaration,'report_id',report.id,
   'values_written',coalesce(report.values_written,false),'display_events',jsonb_build_array(display_event));
 env:=jsonb_set(env,'{receipt}',receipt);
 UPDATE combat_panel_private.offers SET state='consumed',consumed_request_key=key WHERE id=o.id;
 INSERT INTO combat_panel_private.request_receipts(principal_user,request_key,command_fingerprint,offer_id,event_id,viewer_envelope)
   VALUES(uid,key,fp,o.id,event_id,env);
 RETURN env;
END $function$;
CREATE OR REPLACE FUNCTION combat_panel_private.controller_version_valid(p_actor uuid, p_version bigint, p_principal uuid DEFAULT NULL::uuid)
 RETURNS boolean
 LANGUAGE plpgsql
 STABLE SECURITY DEFINER
 SET search_path TO ''
AS $function$
DECLARE a public.combat_v2_actors%ROWTYPE; m public.master_v2_sessions%ROWTYPE;
 cp record; tr record; actor_snapshot jsonb; actor_version bigint; master_version bigint; principal uuid; valid boolean;
BEGIN
 IF EXISTS(SELECT 1 FROM exam_regia_private.bindings b WHERE b.png_actor_id=p_actor AND b.service_principal_id=p_principal AND b.state<>'closed') THEN
 RETURN EXISTS(SELECT 1 FROM public.combat_v2_actors regia_actor WHERE regia_actor.id=p_actor AND regia_actor.controller_user IS NULL AND regia_actor.controller_version=p_version);
 END IF;
 SELECT * INTO a FROM public.combat_v2_actors WHERE id=p_actor;
 IF a.id IS NULL OR p_version IS NULL THEN RETURN false; END IF;
 IF a.controller_version=p_version THEN RETURN p_principal IS NULL OR exam_regia_private.actor_principal(a.id,a.controller_user)=p_principal; END IF;
 IF a.actor_kind<>'png' OR p_version>a.controller_version OR NOT combat_panel_private.has_master_geometry(a.session_id) THEN RETURN false; END IF;
 SELECT ms.* INTO STRICT m FROM public.master_v2_sessions ms JOIN public.combat_v2_sessions s
   ON s.master_session_id=ms.id WHERE s.id=a.session_id;
 FOR cp IN SELECT ck.* FROM public.master_v2_mechanical_checkpoints ck
   WHERE ck.master_session_id=m.id AND ck.version<m.control_version ORDER BY ck.version DESC,ck.created_at DESC LOOP
   IF cp.sha256 IS DISTINCT FROM public.combat_v2_sha256(cp.payload) THEN CONTINUE; END IF;
   SELECT av.value INTO actor_snapshot FROM jsonb_array_elements(cp.payload->'encounters') e(value)
     CROSS JOIN LATERAL jsonb_array_elements(e.value->'actors') av(value)
     WHERE e.value->>'id'=a.session_id::text AND av.value->>'id'=a.id::text;
   IF actor_snapshot IS NULL OR (actor_snapshot->>'controller_version')::bigint IS DISTINCT FROM p_version
     OR (p_principal IS NOT NULL AND (actor_snapshot->>'controller_user')::uuid IS DISTINCT FROM p_principal) THEN CONTINUE; END IF;
   actor_version:=p_version; master_version:=cp.version; principal:=(actor_snapshot->>'controller_user')::uuid;
   IF principal IS DISTINCT FROM (cp.payload#>>'{master,master_user}')::uuid
     OR master_version IS DISTINCT FROM (cp.payload#>>'{master,control_version}')::bigint THEN CONTINUE; END IF;
   valid:=true;
   FOR tr IN SELECT t.* FROM public.master_v2_transfers t WHERE t.session_id=m.id
     AND t.version_before>=cp.version AND t.version_after<=m.control_version ORDER BY t.version_before,t.id LOOP
     IF tr.kind NOT IN ('consegna','admin_override') OR tr.version_before<>master_version
       OR tr.version_after<>master_version+1 OR tr.previous_master IS DISTINCT FROM principal
       OR tr.new_master IS NULL OR NOT EXISTS(SELECT 1 FROM public.master_v2_mechanical_checkpoints ck
         WHERE ck.id=tr.checkpoint_id AND ck.master_session_id=m.id AND ck.sha256=public.combat_v2_sha256(ck.payload)) THEN
       valid:=false; EXIT;
     END IF;
     actor_version:=actor_version+1; master_version:=tr.version_after; principal:=tr.new_master;
   END LOOP;
   IF valid AND master_version=m.control_version AND actor_version=a.controller_version
     AND principal=exam_regia_private.actor_principal(a.id,a.controller_user) AND principal=m.master_user THEN RETURN true; END IF;
 END LOOP;
 RETURN false;
END $function$;
CREATE OR REPLACE FUNCTION combat_panel_private.enroll_master(p_master uuid)
 RETURNS void
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO ''
AS $function$
DECLARE m public.master_v2_sessions%ROWTYPE; enrolled combat_panel_private.master_panel_sessions%ROWTYPE; policy text;
BEGIN
 SELECT * INTO STRICT m FROM public.master_v2_sessions WHERE id=p_master FOR UPDATE;
 IF EXISTS(SELECT 1 FROM exam_regia_private.bindings b WHERE b.master_session_id=m.id AND b.state<>'closed') THEN
   IF m.owner_kind<>'ai_service' OR m.master_user IS NOT NULL THEN RAISE EXCEPTION 'exam_regia_owner_drift' USING ERRCODE='42501'; END IF;
   INSERT INTO combat_panel_private.master_panel_sessions(master_session_id,location_id,policy_id)
    VALUES(m.id,m.location_id,'exam_protected_no_persistent_resources_v1') ON CONFLICT(master_session_id) DO NOTHING;
   RETURN;
 END IF;
 SELECT * INTO enrolled FROM combat_panel_private.master_panel_sessions WHERE master_session_id=m.id;
 policy:=coalesce(enrolled.policy_id,combat_panel_private.master_entry_policy(m.location_id));
 IF policy IS NULL THEN RETURN; END IF;
 -- Le sessioni IA restano nel loro percorso nominato; una sessione gia
 -- registrata non puo cambiare owner_kind per sottrarsi ai vincoli.
 IF m.owner_kind<>'human' THEN
   IF enrolled.master_session_id IS NOT NULL THEN RAISE EXCEPTION 'panel_master_owner_kind_changed' USING ERRCODE='42501'; END IF;
   RETURN;
 END IF;
 IF enrolled.master_session_id IS NOT NULL AND enrolled.location_id<>m.location_id THEN
   RAISE EXCEPTION 'panel_master_location_changed' USING ERRCODE='42501'; END IF;
 IF policy='staff_test_no_persistent_resources_v1' THEN
   IF m.mission_id IS NOT NULL OR EXISTS(SELECT 1 FROM public.mission_run_state WHERE master_session_id=m.id)
     OR NOT combat_consumer_private.staff_test_allowed(m.location_id,ARRAY[m.master_user],false) THEN
     RAISE EXCEPTION 'panel_staff_master_scope_invalid' USING ERRCODE='42501'; END IF;
 END IF;
 INSERT INTO combat_panel_private.master_panel_sessions(master_session_id,location_id,policy_id)
   VALUES(m.id,m.location_id,policy) ON CONFLICT(master_session_id) DO NOTHING;
END $function$;
CREATE OR REPLACE FUNCTION combat_panel_private.ensure_actor_turn(p_round uuid, p_actor uuid)
 RETURNS uuid
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO ''
AS $function$
DECLARE r public.combat_v2_rounds%ROWTYPE; a public.combat_v2_actors%ROWTYPE; result uuid;
BEGIN
 SELECT * INTO STRICT r FROM public.combat_v2_rounds WHERE id=p_round;
 SELECT * INTO STRICT a FROM public.combat_v2_actors WHERE id=p_actor AND session_id=r.session_id;
 IF exam_regia_private.is_bound(r.session_id) AND NOT exam_regia_private.is_turn_actor(r.id,a.id) THEN RETURN NULL; END IF;
 IF NOT EXISTS(SELECT 1 FROM public.combat_v2_sessions s
   JOIN combat_panel_private.master_panel_sessions registered ON registered.master_session_id=s.master_session_id
   JOIN public.master_v2_sessions m ON m.id=s.master_session_id
   WHERE s.id=r.session_id AND m.stato NOT IN ('chiusa','annullata')) THEN RETURN NULL; END IF;
 SELECT id INTO result FROM combat_panel_private.actor_turns WHERE round_id=r.id AND actor_id=a.id;
 IF result IS NOT NULL THEN RETURN result; END IF;
 IF r.phase<>'raccolta_azioni' OR a.state<>'attivo' OR a.companion_id IS NOT NULL THEN RETURN NULL; END IF;
 INSERT INTO combat_panel_private.actor_turns(round_id,actor_id) VALUES(r.id,a.id)
   ON CONFLICT(round_id,actor_id) DO NOTHING;
 SELECT id INTO STRICT result FROM combat_panel_private.actor_turns WHERE round_id=r.id AND actor_id=a.id;
 RETURN result;
END $function$;
CREATE OR REPLACE FUNCTION combat_panel_private.immobilization_escape_meta(p_round uuid, p_actor uuid, p_request uuid, p_intent jsonb)
 RETURNS jsonb
 LANGUAGE plpgsql
 STABLE SECURITY DEFINER
 SET search_path TO ''
AS $function$
DECLARE plan combat_panel_private.immobilization_escape_plans%ROWTYPE;
BEGIN
 SELECT * INTO plan FROM combat_panel_private.immobilization_escape_plans WHERE round_id=p_round AND actor_id=p_actor AND request_key=p_request;
 IF plan.id IS NULL THEN RETURN NULL; END IF;
 IF plan.controller_user IS DISTINCT FROM exam_regia_private.current_principal() OR p_intent IS DISTINCT FROM jsonb_build_object('kind','utilita')
   OR NOT EXISTS(SELECT 1 FROM public.combat_v2_actors WHERE id=p_actor AND exam_regia_private.actor_principal(id,controller_user)=exam_regia_private.current_principal() AND controller_version=plan.controller_version)
   OR NOT EXISTS(SELECT 1 FROM combat_panel_private.immobilizations WHERE id=plan.effect_id AND target_actor_id=p_actor AND state='active') THEN
   RAISE EXCEPTION 'immobilization_escape_plan_stale' USING ERRCODE='40001'; END IF;
 RETURN jsonb_build_object('source','system','name','Tenta di liberarti','kind','utilita','chakra_cost',0,
   'damage_base',0,'immobilization_escape_version','immobilization-escape/1');
END $function$;
CREATE OR REPLACE FUNCTION combat_panel_private.immobilization_escape_offers(p_context uuid, p_expected bigint, p_view jsonb)
 RETURNS void
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO ''
AS $function$
DECLARE c combat_panel_private.contexts%ROWTYPE; a public.combat_v2_actors%ROWTYPE;
 effect record; offer_id uuid; group_id uuid; ordinal integer:=0;
BEGIN
 c:=combat_panel_private.owned_context(p_context,p_expected);
 IF c.round_id IS NULL OR c.command_actor_id IS NULL OR c.activity_kind IS NULL
   OR c.activity_kind NOT IN ('ordinary_v2','master_v2')
   OR p_view#>>'{context,phase}' IS DISTINCT FROM 'action'
   OR p_view#>>'{viewer,command_actor_id}' IS DISTINCT FROM c.command_actor_id::text
   OR p_view#>>'{viewer,can_command}' IS DISTINCT FROM 'true' THEN RETURN; END IF;
 SELECT * INTO STRICT a FROM public.combat_v2_actors WHERE id=c.command_actor_id AND session_id=c.activity_id
   AND exam_regia_private.actor_principal(id,controller_user)=exam_regia_private.current_principal();
 IF a.actor_kind<>'pg' OR a.companion_id IS NOT NULL OR a.state<>'attivo'
   OR NOT combat_panel_private.immobilization_active(a.id)
   OR EXISTS(SELECT 1 FROM public.combat_v2_declarations WHERE round_id=c.round_id AND actor_id=a.id
     AND kind IN ('attacco','movimento','utilita','passa')) THEN RETURN; END IF;
 IF c.activity_kind='ordinary_v2' AND NOT EXISTS(SELECT 1 FROM combat_consumer_private.activities
   WHERE session_id=c.activity_id AND exchange_id=c.round_id AND turn_actor_id=a.id AND phase='action') THEN RETURN; END IF;
 IF EXISTS(SELECT 1 FROM combat_panel_private.offers WHERE context_id=c.id AND context_version=c.context_version
   AND state='offered' AND source_payload->>'dispatch'='immobilization_escape') THEN RETURN; END IF;
 offer_id:=combat_panel_private.create_offer(c.id,c.context_version,'action','declare','Tenta di liberarti',true,
   jsonb_build_object('adapter',c.activity_kind,'dispatch','immobilization_escape','kind','utilita'));
 group_id:=combat_panel_private.add_group(offer_id,'Presa da sciogliere','mode','single',1,1);
 FOR effect IN SELECT id FROM combat_panel_private.immobilizations WHERE target_actor_id=a.id AND session_id=c.activity_id
   AND state='active' ORDER BY created_at,id LOOP
   ordinal:=ordinal+1;
   PERFORM combat_panel_private.add_choice(group_id,'Presa '||ordinal::text,
     jsonb_build_object('immobilization_effect_id',effect.id));
 END LOOP;
END $function$;
CREATE OR REPLACE FUNCTION combat_panel_private.instance_terrain_map_objects(p_instance uuid, p_actor uuid)
 RETURNS jsonb
 LANGUAGE plpgsql
 STABLE SECURITY DEFINER
 SET search_path TO ''
AS $function$
DECLARE i combat_spatial.arena_instances%ROWTYPE;b combat_spatial.actor_states%ROWTYPE;
 config combat_panel_private.instance_terrain_configs%ROWTYPE;result jsonb;
BEGIN
 IF exam_regia_private.current_principal() IS NULL THEN RAISE EXCEPTION 'panel_authentication_required' USING ERRCODE='28000'; END IF;
 SELECT * INTO STRICT i FROM combat_spatial.arena_instances WHERE instance_id=p_instance AND state='open';
 IF NOT combat_panel_private.shared_movement_scope(i.instance_id)
  OR NOT EXISTS(SELECT 1 FROM combat_spatial.viewer_grants WHERE instance_id=i.instance_id
    AND viewer_principal_id=exam_regia_private.current_principal() AND can_view_map AND can_view_objects) THEN RETURN '[]'::jsonb; END IF;
 IF p_actor IS NOT NULL THEN
  SELECT * INTO STRICT b FROM combat_spatial.actor_states WHERE instance_id=i.instance_id AND actor_id=p_actor
   AND controller_principal_id=exam_regia_private.current_principal() AND state='active';
 ELSIF NOT EXISTS(SELECT 1 FROM public.combat_v2_sessions s WHERE s.id=i.encounter_id AND s.source_kind='master') THEN
  RAISE EXCEPTION 'panel_observer_pov_not_authorized' USING ERRCODE='42501';
 END IF;
 SELECT * INTO config FROM combat_panel_private.instance_terrain_configs
  WHERE instance_id=i.instance_id ORDER BY map_version DESC LIMIT 1;
 SELECT coalesce(jsonb_agg(jsonb_build_object(
   'object_id',md5('instance-terrain:'||i.instance_id::text||':'||config.map_version||':'||(r.value->>'key'))::uuid,
   'label',r.value->>'label','state','available','shape_kind',r.value->>'shape_kind','shape',r.value->'shape',
   'x_m',center.x,'y_m',center.y,
   'radius_m',CASE WHEN r.value->>'shape_kind'='circle' THEN (r.value#>>'{shape,radius}')::numeric ELSE NULL END,
   'distance_from_viewer_m',CASE WHEN b.actor_id IS NULL THEN NULL ELSE
    round(combat_spatial.distance_m(b.x_m,b.y_m,center.x,center.y),2) END,
   'substitution_anchor_available',false,'is_impervious',true) ORDER BY r.value->>'key'),'[]'::jsonb)
 INTO result FROM jsonb_array_elements(coalesce(config.regions,'[]'::jsonb)) AS r(value)
 CROSS JOIN LATERAL (SELECT (combat_spatial.shape_center(r.value->>'shape_kind',r.value->'shape'))[0]::numeric AS x,
  (combat_spatial.shape_center(r.value->>'shape_kind',r.value->'shape'))[1]::numeric AS y) center;
 RETURN result;
END $function$;
CREATE OR REPLACE FUNCTION combat_panel_private.mask_native_state(p_result jsonb)
 RETURNS jsonb
 LANGUAGE plpgsql
 STABLE SECURITY DEFINER
 SET search_path TO ''
AS $function$
DECLARE sid uuid; actors jsonb; list_key text;
BEGIN
 IF exam_regia_private.current_principal() IS NULL THEN RAISE EXCEPTION 'panel_authentication_required' USING ERRCODE='28000'; END IF;
 sid:=coalesce(p_result#>>'{data,session,id}',p_result#>>'{data,encounter,id}')::uuid;
 IF sid IS NULL AND jsonb_typeof(p_result#>'{data,actor}')='string' THEN
   SELECT session_id INTO sid FROM public.combat_v2_actors WHERE id=(p_result#>>'{data,actor}')::uuid;
 END IF;
 IF sid IS NULL THEN RETURN p_result; END IF;
 FOREACH list_key IN ARRAY ARRAY['actors','targets'] LOOP
 IF jsonb_typeof(p_result#>ARRAY['data',list_key]) IS DISTINCT FROM 'array' THEN CONTINUE; END IF;
 SELECT coalesce(jsonb_agg(CASE WHEN a ? 'position_m' AND EXISTS(
   SELECT 1 FROM combat_panel_private.multiplication_formations f
   JOIN public.combat_v2_actors owner ON owner.id=f.actor_id AND owner.session_id=f.session_id
   WHERE f.session_id=sid AND f.actor_id=(a->>'id')::uuid AND f.state='active'
     AND exam_regia_private.actor_principal(owner.id,owner.controller_user) IS DISTINCT FROM exam_regia_private.current_principal())
   THEN jsonb_set(a,'{position_m}','null') ELSE a END ORDER BY n),'[]')
 INTO actors FROM jsonb_array_elements(p_result#>ARRAY['data',list_key]) WITH ORDINALITY q(a,n);
 p_result:=jsonb_set(p_result,ARRAY['data',list_key],actors);
 END LOOP;
 RETURN p_result;
END $function$;
CREATE OR REPLACE FUNCTION combat_panel_private.master_actor_offers(p_context uuid, p_expected bigint, p_view jsonb, p_source jsonb)
 RETURNS void
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO ''
AS $function$
DECLARE c combat_panel_private.contexts%ROWTYPE; a public.combat_v2_actors%ROWTYPE;
 defense_target_id uuid; figure_geometry jsonb; target_choice uuid; meta jsonb; item jsonb; pending jsonb; moves jsonb; one jsonb; target record;
 oid uuid; gid uuid; directions uuid; direction_id uuid; target_id uuid;
 cap integer; minimum integer; n integer; chakra numeric; cost numeric; ability_range numeric;
 mode text; reaction text; label text; dir text; payload jsonb; legal jsonb;
BEGIN
 c:=combat_panel_private.owned_context(p_context,p_expected);
 IF c.activity_kind<>'master_v2' OR c.command_actor_id IS NULL OR c.round_id IS NULL THEN RETURN; END IF;
 SELECT * INTO STRICT a FROM public.combat_v2_actors WHERE id=c.command_actor_id AND session_id=c.activity_id
   AND exam_regia_private.actor_principal(id,controller_user)=exam_regia_private.current_principal() AND companion_id IS NULL;
 IF a.state<>'attivo' THEN RETURN; END IF;
 IF p_view#>>'{viewer,command_actor_id}' IS DISTINCT FROM a.id::text
   OR p_source->>'actor' IS DISTINCT FROM a.id::text OR p_source->>'round' IS DISTINCT FROM c.round_id::text THEN
   RAISE EXCEPTION 'panel_master_source_scope_invalid' USING ERRCODE='22023'; END IF;
 IF NOT combat_panel_private.has_master_geometry(a.session_id) THEN RETURN; END IF;
 SELECT greatest(0,coalesce((a.mechanics_snapshot->>'chakra')::numeric,0)-coalesce(sum((d.cost_snapshot->>'chakra')::numeric),0))
   INTO chakra FROM public.combat_v2_declarations d WHERE d.round_id=c.round_id AND d.actor_id=a.id
     AND d.state NOT IN ('superflua','risolta');
 IF p_view#>>'{context,phase}'='action' AND NOT EXISTS(SELECT 1 FROM public.combat_v2_declarations
   WHERE round_id=c.round_id AND actor_id=a.id AND kind IN ('attacco','movimento','utilita','passa')) THEN
   FOR meta IN SELECT value FROM jsonb_array_elements(jsonb_build_array(jsonb_build_object(
     'source','mano','name','Colpo a mano','kind','fisico','chakra_cost',0,'damage_base',10))||coalesce(p_source->'abilities','[]')) LOOP
     IF meta->>'source'='clan' AND meta->>'id'='617484d6-af7b-41c3-a37f-615b22818421' THEN CONTINUE; END IF;
     cost:=coalesce((meta->>'chakra_cost')::numeric,0);
     IF cost>chakra THEN CONTINUE; END IF;
     IF meta->>'source'<>'mano' AND (coalesce(meta->>'usage','') NOT IN ('principale','rapida')
       OR coalesce((meta->>'defensive')::boolean,false) OR coalesce((meta->>'di_scena')::boolean,false)
       OR coalesce((meta->>'diversivo')::boolean,false) OR coalesce(meta->>'consumption_type','ad_utilizzo')='passiva') THEN CONTINUE; END IF;
     -- Eleggibilità Fili e resolver speciali restano autorità del dominio.
     BEGIN
       PERFORM clan_marionettisti_private.assert_jutsu_source(a.id,meta->>'source',(meta->>'id')::uuid);
     EXCEPTION WHEN SQLSTATE '22023' THEN
       IF SQLERRM='fili_other_jutsu_unavailable' THEN CONTINUE; ELSE RAISE; END IF;
     END;
     ability_range:=CASE WHEN meta->>'source'='clan' AND meta->>'id'='e361f7c3-f90b-47ec-bfee-ccbda21257d9' THEN 3 WHEN meta->>'source'='mano' THEN 2 ELSE public._fascia_metri(meta->>'range') END;
     legal:='[]';
     FOR item IN SELECT value FROM jsonb_array_elements(p_source->'targets') LOOP
       target_id:=(item->>'id')::uuid;
       figure_geometry:=NULL;
       IF EXISTS(SELECT 1 FROM combat_panel_private.multiplication_formations WHERE actor_id=target_id AND state='active') THEN
         IF NOT EXISTS(SELECT 1 FROM combat_panel_private.multiplication_formations f WHERE f.actor_id=target_id AND f.state='active' AND f.mode IN ('diversivo','copertura','assalto')) THEN CONTINUE; END IF;
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
           WHERE (value->>'distance_m')::numeric<=ability_range AND (value->>'path_clear')::boolean) THEN CONTINUE; END IF;
       ELSIF meta->>'source'='clan' AND meta->>'id'='e361f7c3-f90b-47ec-bfee-ccbda21257d9' THEN
       BEGIN
         PERFORM clan_marionettisti_private.attack_source(c.round_id,a.id,target_id);
       EXCEPTION WHEN SQLSTATE 'P0002' THEN CONTINUE;
         WHEN SQLSTATE '22023' THEN
           IF SQLERRM IN ('marionetta_actor_target_invalid','marionetta_link_unavailable',
             'marionetta_module_unavailable','marionetta_attack_out_of_range') THEN CONTINUE; ELSE RAISE; END IF;
       END;
     ELSIF NOT combat_panel_private.target_geometry_valid(a.id,target_id,ability_range) THEN CONTINUE; END IF;
       SELECT value->>'display_name' INTO label FROM jsonb_array_elements(p_view->'actors') WHERE value->>'actor_id'=target_id::text;
       IF label IS NOT NULL THEN legal:=legal||jsonb_build_array(jsonb_build_object('target_actor_id',target_id,'label',label,'figure_geometry',figure_geometry)); END IF;
     END LOOP;
     IF jsonb_array_length(legal)=0 THEN CONTINUE; END IF;
     cap:=1;
     FOR n IN 2..(CASE WHEN meta->>'source'='clan' AND meta->>'id'='e361f7c3-f90b-47ec-bfee-ccbda21257d9'
       THEN 1 ELSE least(3,jsonb_array_length(legal)) END) LOOP
       IF coalesce(combat_v2_multitarget_internal.attack_profile_ok(meta,n),false) THEN cap:=n; END IF;
     END LOOP;
     payload:=jsonb_build_object('adapter','master_v2','dispatch','action','kind','attacco','ability_source',meta->'source');
     IF meta->>'source'<>'mano' THEN payload:=payload||jsonb_build_object('ability_id',meta->'id'); END IF;
     oid:=combat_panel_private.create_offer(c.id,c.context_version,'action','declare',meta->>'name',true,payload);
     gid:=combat_panel_private.add_group(oid,'Bersaglio','target',CASE WHEN cap>1 THEN 'multiple' ELSE 'single' END,1,cap);
     FOR item IN SELECT value FROM jsonb_array_elements(legal) LOOP
       target_choice:=combat_panel_private.add_choice(gid,item->>'label',jsonb_build_object('target_actor_id',item->'target_actor_id'));
       IF jsonb_typeof(item->'figure_geometry')='object' THEN
         PERFORM combat_panel_private.multiplication_add_attack_figures(oid,target_choice,item->'figure_geometry',ability_range,item->>'label');
       END IF;
     END LOOP;
   END LOOP;
   moves:=combat_panel_private.master_movement_options(c.round_id,a.id);
   IF jsonb_array_length(moves)>0 THEN
     oid:=combat_panel_private.create_offer(c.id,c.context_version,'action','declare','Movimento',true,
       jsonb_build_object('adapter','master_v2','dispatch','movement','kind','movimento'));
     directions:=combat_panel_private.add_group(oid,'Direzione','movement_direction','single',1,1);
     FOREACH dir IN ARRAY ARRAY['up','right','down','left'] LOOP
       IF NOT EXISTS(SELECT 1 FROM jsonb_array_elements(moves) WHERE value->>'direction'=dir) THEN CONTINUE; END IF;
       direction_id:=combat_panel_private.add_choice(directions,CASE dir WHEN 'up' THEN 'Su' WHEN 'right' THEN 'Destra' WHEN 'down' THEN 'Giù' ELSE 'Sinistra' END,
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
     reaction:=coalesce(meta->>'reaction','tecnica');
     IF reaction='tecnica' AND NOT coalesce((meta->>'defensive')::boolean,false) THEN CONTINUE; END IF;
     cost:=coalesce((meta->>'chakra_cost')::numeric,0); IF cost>chakra THEN CONTINUE; END IF;
     BEGIN
       PERFORM clan_marionettisti_private.assert_jutsu_source(a.id,meta->>'source',(meta->>'id')::uuid);
     EXCEPTION WHEN SQLSTATE '22023' THEN
       IF SQLERRM='fili_other_jutsu_unavailable' THEN CONTINUE; ELSE RAISE; END IF;
     END;
     mode:=CASE WHEN reaction IN ('schivata','parata','nessuna') THEN 'self' ELSE coalesce(meta#>>'{targeting,mode}','self') END;
     IF mode NOT IN ('self','intercept','multi_protect') THEN CONTINUE; END IF;
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
     oid:=combat_panel_private.create_offer(c.id,c.context_version,'defense','defend',meta->>'name',true,payload);
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
   IF chakra>=5 THEN
     FOR pending IN SELECT value FROM jsonb_array_elements(coalesce(p_source->'substitution_offers','[]')) LOOP
       IF jsonb_array_length(coalesce(pending#>'{offer,options}','[]'))=0 THEN CONTINUE; END IF;
       oid:=combat_panel_private.create_offer(c.id,c.context_version,'defense','defend','Sostituzione',true,
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
END $function$;
CREATE OR REPLACE FUNCTION combat_panel_private.master_companion_bind_offers(p_context uuid, p_expected bigint)
 RETURNS void
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO ''
AS $function$
DECLARE c combat_panel_private.contexts%ROWTYPE; a public.combat_v2_actors%ROWTYPE;
 placement jsonb; source record;
BEGIN
 c:=combat_panel_private.owned_context(p_context,p_expected);
 IF c.activity_kind<>'master_v2' OR c.command_actor_id IS NULL OR c.round_id IS NULL THEN RETURN; END IF;
 SELECT * INTO STRICT a FROM public.combat_v2_actors WHERE id=c.command_actor_id
   AND session_id=c.activity_id AND exam_regia_private.actor_principal(id,controller_user)=exam_regia_private.current_principal() AND companion_id IS NULL;
 IF a.actor_kind<>'pg' OR a.state<>'attivo' OR EXISTS(SELECT 1 FROM public.combat_v2_actors b
   JOIN clan_marionettisti_private.sources s ON s.id=b.companion_id
   WHERE b.session_id=a.session_id AND s.owner_character_id=a.character_id)
   OR EXISTS(SELECT 1 FROM public.combat_v2_declarations d JOIN public.combat_v2_rounds r ON r.id=d.round_id
     WHERE r.session_id=a.session_id AND d.actor_id=a.id)
   OR EXISTS(SELECT 1 FROM clan_sabaku_private.staff_profiles WHERE session_id=a.session_id AND actor_id=a.id) THEN RETURN; END IF;
 IF NOT public.combat_v2_values_written(a.session_id) AND EXISTS(
   SELECT 1 FROM public.combat_v2_actors WHERE session_id=a.session_id AND actor_kind='pg'
     AND character_id NOT IN ('6bceee99-974f-426b-8d92-38b43b4a4267'::uuid,'2a877f02-4993-4e65-9172-7d29f08c5b86'::uuid)) THEN RETURN; END IF;
 placement:=combat_panel_private.master_companion_placement(a.id);
 IF placement IS NULL THEN RETURN; END IF;
 IF NOT public.combat_v2_values_written(a.session_id) THEN
   IF combat_panel_private.master_staff_companion_scope(a.session_id)
     AND EXISTS(SELECT 1 FROM clan_marionettisti_private.release_gate WHERE singleton AND staff_enabled)
     AND NOT EXISTS(SELECT 1 FROM clan_marionettisti_private.sources WHERE session_id=a.session_id AND owner_actor_id=a.id) THEN
     PERFORM combat_panel_private.create_offer(c.id,c.context_version,'control','control','Prepara la prova Marionetta L1',false,
       jsonb_build_object('adapter','master_v2','dispatch','companion_control','companion_operation','bind',
         'source_id',NULL,'placement',placement));
   END IF;
 ELSIF clan_marionettisti_private.owner_eligible(a.id,false) THEN
   FOR source IN SELECT src.id,cc.name FROM clan_marionettisti_private.sources src
     JOIN clan_marionettisti_private.chassis h ON h.companion_id=src.id AND h.operational AND h.footprint_radius_m=0.5
     JOIN public.character_companions cc ON cc.id=src.real_companion_id AND cc.character_id=a.character_id
       AND cc.kind='marionetta' AND cc.is_active
     WHERE src.source_kind='real' AND src.owner_character_id=a.character_id AND src.is_active
       AND NOT EXISTS(SELECT 1 FROM public.combat_v2_actors b JOIN public.combat_v2_sessions s ON s.id=b.session_id
         WHERE b.companion_id=src.id AND s.closed_at IS NULL) ORDER BY src.id LOOP
     PERFORM combat_panel_private.create_offer(c.id,c.context_version,'control','control',
       'Collega la marionetta · '||source.name,false,jsonb_build_object('adapter','master_v2',
         'dispatch','companion_control','companion_operation','bind','source_id',source.id,'placement',placement));
   END LOOP;
 END IF;
END $function$;
CREATE OR REPLACE FUNCTION combat_panel_private.master_map(p_encounter uuid, p_actor uuid)
 RETURNS jsonb
 LANGUAGE plpgsql
 STABLE SECURITY DEFINER
 SET search_path TO ''
AS $function$
DECLARE s public.combat_v2_sessions%ROWTYPE; i combat_spatial.arena_instances%ROWTYPE;
 src jsonb; raw_map jsonb; pov combat_spatial.actor_states%ROWTYPE;
 actors jsonb; objects jsonb; round_no integer;
BEGIN
 IF exam_regia_private.current_principal() IS NULL THEN RAISE EXCEPTION 'panel_authentication_required' USING ERRCODE='28000'; END IF;
 SELECT * INTO STRICT s FROM public.combat_v2_sessions WHERE id=p_encounter AND source_kind='master';
 -- La normale porta verifica Master/admin/partecipante correnti, prima di
 -- leggere i grant geometrici. Un grant storico non riapre una sessione.
 src:=public.master_v2_ui_state(s.location_id)->'data';
 IF src#>>'{encounter,id}' IS DISTINCT FROM s.id::text THEN
   RAISE EXCEPTION 'panel_master_encounter_not_current' USING ERRCODE='42501'; END IF;
 SELECT * INTO i FROM combat_spatial.arena_instances WHERE encounter_id=s.id AND state='open';
 IF i.instance_id IS NULL THEN RETURN NULL; END IF;
 IF p_actor IS NULL THEN
   IF NOT(coalesce((src#>>'{viewer,is_master}')::boolean,false) OR coalesce((src#>>'{viewer,is_admin}')::boolean,false)) THEN
     RAISE EXCEPTION 'panel_observer_pov_not_authorized' USING ERRCODE='42501'; END IF;
 ELSE
   IF NOT EXISTS(SELECT 1 FROM public.combat_v2_actors WHERE id=p_actor AND session_id=s.id
     AND exam_regia_private.actor_principal(id,controller_user)=exam_regia_private.current_principal() AND companion_id IS NULL) THEN
     RAISE EXCEPTION 'panel_actor_not_controlled' USING ERRCODE='42501'; END IF;
   SELECT * INTO pov FROM combat_spatial.actor_states WHERE instance_id=i.instance_id AND actor_id=p_actor AND state='active';
   IF pov.actor_id IS NULL THEN RETURN NULL; END IF;
 END IF;
 IF NOT EXISTS(SELECT 1 FROM combat_spatial.viewer_grants WHERE instance_id=i.instance_id
   AND viewer_principal_id=exam_regia_private.current_principal() AND can_view_map) THEN RETURN NULL; END IF;
 round_no:=coalesce((src#>>'{round,no}')::integer,1);
 PERFORM combat_panel_private.impervious_regions(i.instance_id);
 raw_map:=combat_spatial.map_projection(i.instance_id,exam_regia_private.current_principal(),round_no);
 -- Gli UUID subject della projection sono opachi: mapparli sul lato server
 -- soltanto fra i corpi gia autorizzati dal grant, mai ricostruiti nel client.
 SELECT coalesce(jsonb_agg(jsonb_build_object('actor_id',b.actor_id,'x_m',b.x_m,'y_m',b.y_m,
   'radius_m',b.footprint_radius_m,'body_only',a.companion_id IS NOT NULL) ORDER BY b.actor_id),'[]'::jsonb)
 INTO actors FROM jsonb_array_elements(raw_map->'actors') AS item(value)
 JOIN combat_spatial.actor_states b ON b.instance_id=i.instance_id AND b.projection_subject_id=(value->>'subject')::uuid
 JOIN public.combat_v2_actors a ON a.id=b.actor_id AND a.session_id=s.id;
 IF p_actor IS NOT NULL AND NOT EXISTS(SELECT 1 FROM jsonb_array_elements(actors) AS a(value)
   WHERE value->>'actor_id'=p_actor::text) THEN RETURN NULL; END IF;
 SELECT coalesce(jsonb_agg(jsonb_build_object('object_id',item.value->'object',
   'label',item.value->'label','state',os.state,'shape_kind',o.shape_kind,'shape',geometry.shape,
   'x_m',center.x,'y_m',center.y,'radius_m',CASE WHEN o.shape_kind='circle' THEN (geometry.shape->>'radius')::numeric ELSE NULL END,
   'distance_from_viewer_m',CASE WHEN pov.actor_id IS NULL THEN NULL ELSE
     round(combat_spatial.distance_m(pov.x_m,pov.y_m,center.x,center.y),2) END,
   'substitution_anchor_available',o.substitutable AND os.state='available',
   'is_impervious',o.is_impervious AND os.state='available') ORDER BY o.object_key),'[]'::jsonb)
 INTO objects FROM jsonb_array_elements(raw_map->'objects') AS item(value)
 JOIN combat_spatial.object_states os ON os.instance_id=i.instance_id
   AND md5(i.instance_id::text||os.object_key||os.state_version)::uuid=(item.value->>'object')::uuid
 JOIN combat_spatial.arena_objects o ON o.template_key=i.template_key AND o.template_version=i.template_version AND o.object_key=os.object_key
 CROSS JOIN LATERAL (SELECT CASE WHEN os.state='consumed_non_substitutable' AND o.shape_kind='circle'
   THEN o.shape||jsonb_build_object('cx',os.proxy_x_m,'cy',os.proxy_y_m) ELSE o.shape END AS shape) geometry
 CROSS JOIN LATERAL (SELECT (combat_spatial.shape_center(o.shape_kind,geometry.shape))[0]::numeric AS x,
   (combat_spatial.shape_center(o.shape_kind,geometry.shape))[1]::numeric AS y) center;
 objects:=objects||combat_panel_private.instance_terrain_map_objects(i.instance_id,p_actor);
 RETURN jsonb_build_object('schema_version','combat-map/2','map_version',i.map_version,'readonly',true,
   'label','Arena di combattimento','bounds',jsonb_build_object('width_m',raw_map#>'{bounds,width_m}',
     'height_m',raw_map#>'{bounds,height_m}'),'actors',actors,'objects',objects,
   'pov',CASE WHEN pov.actor_id IS NULL THEN NULL ELSE jsonb_build_object('actor_id',pov.actor_id,
     'x_m',pov.x_m,'y_m',pov.y_m,'radius_m',pov.footprint_radius_m) END);
END $function$;
CREATE OR REPLACE FUNCTION combat_panel_private.master_movement_intent(p_round uuid, p_actor uuid, p_request uuid, p_intent jsonb)
 RETURNS jsonb
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO ''
AS $function$
DECLARE plan combat_panel_private.master_movement_plans%ROWTYPE;
BEGIN
 SELECT * INTO STRICT plan FROM combat_panel_private.master_movement_plans WHERE request_key=p_request
   AND round_id=p_round AND actor_id=p_actor AND principal_user=exam_regia_private.current_principal() AND state='prepared' FOR UPDATE;
 IF p_intent IS DISTINCT FROM jsonb_build_object('kind','movimento') THEN
   RAISE EXCEPTION 'panel_movement_intent_invalid' USING ERRCODE='22023'; END IF;
 RETURN p_intent||jsonb_build_object('move_m',plan.planned_m,'movement_contract','combat-panel-movement/1');
END $function$;
CREATE OR REPLACE FUNCTION combat_panel_private.master_movement_options(p_round uuid, p_actor uuid)
 RETURNS jsonb
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO ''
AS $function$
DECLARE a public.combat_v2_actors%ROWTYPE; r public.combat_v2_rounds%ROWTYPE;
 b combat_spatial.actor_states%ROWTYPE; iid uuid; budget jsonb; remaining numeric;
 candidate record; key text; keys text[]:='{}'; item jsonb; out jsonb:='[]'; direction text;
BEGIN
 IF exam_regia_private.current_principal() IS NULL THEN RAISE EXCEPTION 'panel_authentication_required' USING ERRCODE='28000'; END IF;
 PERFORM public.combat_v2_lock_round(p_round);
 SELECT * INTO STRICT r FROM public.combat_v2_rounds WHERE id=p_round;
 SELECT * INTO STRICT a FROM public.combat_v2_actors WHERE id=p_actor AND session_id=r.session_id
   AND exam_regia_private.actor_principal(id,controller_user)=exam_regia_private.current_principal() AND companion_id IS NULL;
 IF r.phase<>'raccolta_azioni' OR a.state<>'attivo' OR EXISTS(
   SELECT 1 FROM public.combat_v2_declarations WHERE round_id=r.id AND actor_id=a.id
     AND kind IN ('attacco','movimento','utilita','passa')) THEN RETURN out; END IF;
 budget:=combat_panel_private.master_movement_budget(r.id,a.id); remaining:=(budget->>'remaining_m')::numeric;
 IF remaining<=0 THEN RETURN out; END IF;
 SELECT instance_id INTO STRICT iid FROM combat_spatial.arena_instances
   WHERE encounter_id=a.session_id AND context_source='panel_master' AND state='open';
 SELECT * INTO STRICT b FROM combat_spatial.actor_states WHERE instance_id=iid AND actor_id=a.id AND state='active';
 IF b.controller_principal_id IS DISTINCT FROM exam_regia_private.current_principal() THEN
   RAISE EXCEPTION 'panel_movement_controller_stale' USING ERRCODE='40001'; END IF;
 FOR candidate IN SELECT d.dx,d.dy,d.direction,m.metres FROM
   (VALUES(1,0,'right'),(-1,0,'left'),(0,1,'down'),(0,-1,'up'))d(dx,dy,direction)
   CROSS JOIN LATERAL generate_series(1,floor(remaining)::integer)m(metres) LOOP
   key:='panel:'||r.id||':'||b.body_version||':'||candidate.direction||':'||candidate.metres;
   keys:=array_append(keys,key);
   INSERT INTO combat_spatial.movement_semantic_choices(instance_id,actor_id,choice_key,
     endpoint_x_m,endpoint_y_m,max_budget_m,choice_version,enabled)
     VALUES(iid,a.id,key,b.x_m+candidate.dx*candidate.metres,b.y_m+candidate.dy*candidate.metres,remaining,1,true)
     ON CONFLICT(instance_id,actor_id,choice_key) DO NOTHING;
 END LOOP;
 UPDATE combat_spatial.movement_semantic_choices SET enabled=false,choice_version=choice_version+1
   WHERE instance_id=iid AND actor_id=a.id AND enabled AND left(choice_key,6)='panel:' AND NOT(choice_key=ANY(keys));
 FOR item IN SELECT value FROM jsonb_array_elements(combat_spatial.movement_options(iid,a.id,remaining)) LOOP
   IF item->>'intent'=ANY(keys) AND (item->>'distance_m')::numeric>0 THEN
     direction:=split_part(item->>'intent',':',4);
     out:=out||jsonb_build_array(jsonb_build_object('capability_id',item->'option_id',
       'direction',direction,'distance_m',item->'distance_m'));
   END IF;
 END LOOP;
 RETURN out;
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
 IF NOT EXISTS(SELECT 1 FROM combat_panel_private.offers WHERE context_id=c.id AND context_version=c.context_version AND state='offered') THEN
   IF c.command_actor_id IS NOT NULL AND c.round_id IS NOT NULL THEN
     -- La versione richiesta e gia validata sotto lock del round.
     -- Upkeep e inizializzazione autorizzati precedono il catalogo delle azioni.
     PERFORM clan_sabaku_private.prepare_master_owner(c.command_actor_id);
     PERFORM combat_panel_private.prepare_master_companion(c.command_actor_id);
     source:=public.combat_v2_round_options(c.round_id,c.command_actor_id)->'data';
     env:=combat_panel_private.master_projection(p_location,c.command_actor_id);
     SELECT * INTO STRICT c FROM combat_panel_private.contexts WHERE id=c.id
       AND principal_user=exam_regia_private.current_principal() FOR UPDATE;
     PERFORM combat_panel_private.master_actor_offers(c.id,c.context_version,env,source);
     PERFORM combat_panel_private.master_companion_bind_offers(c.id,c.context_version);
     PERFORM combat_panel_private.master_companion_control_offers(c.id,c.context_version,source);
   END IF;
   PERFORM clan_sabaku_private.master_control_offers(c.id,c.context_version);
   IF NOT exam_regia_private.is_bound(c.activity_id) THEN PERFORM combat_panel_private.master_admin_offers(c.id,c.context_version,public.master_v2_ui_state(p_location)->'data'); END IF;
 END IF;
 PERFORM combat_panel_private.multiplication_offers(c.id,c.context_version,env);
 PERFORM combat_panel_private.immobilization_escape_offers(c.id,c.context_version,env);
 PERFORM clan_sabaku_private.clone_offers(c.id,c.context_version,env);
 PERFORM combat_panel_private.master_open_offers(c.id,c.context_version);
 SELECT coalesce(jsonb_agg(combat_panel_private.offer_projection(id) ORDER BY created_at,id),'[]') INTO offers
   FROM combat_panel_private.offers WHERE context_id=c.id AND context_version=c.context_version AND state='offered';
 RETURN jsonb_set(combat_panel_private.attach_rating_offers(jsonb_set(env,'{offers}',offers),c.id),
   '{movement_explanations}',coalesce(combat_panel_private.movement_explanations(c.id,c.context_version),'null'::jsonb));
END $function$;
CREATE OR REPLACE FUNCTION combat_panel_private.master_projection(p_location uuid, p_actor uuid DEFAULT NULL::uuid)
 RETURNS jsonb
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO ''
AS $function$
DECLARE multiplication jsonb; src jsonb; c combat_panel_private.contexts%ROWTYPE; sid uuid; mid uuid; rid uuid; actor uuid;
 is_master boolean; is_admin boolean; is_test boolean; simulated boolean; policy text; phase text; phase_label text;
 controlled jsonb:='[]'; roster jsonb:='[]'; item jsonb; resources jsonb; map_view jsonb:=null;
 companion_view jsonb:=null; sabaku_view jsonb:=null; narrative_view jsonb:=null; narrative_meta jsonb; meta public.combat_v2_actors%ROWTYPE;
 actor_state text; distance numeric; body_only boolean; due boolean; selected boolean;
BEGIN
 src:=public.master_v2_ui_state(p_location)->'data';
 is_master:=coalesce((src#>>'{viewer,is_master}')::boolean,false);
 is_admin:=coalesce((src#>>'{viewer,is_admin}')::boolean,false);
 mid:=(src#>>'{master,id}')::uuid;
 IF mid IS NULL THEN is_master:=coalesce(public.master_v2_is_master(exam_regia_private.current_principal()),false); END IF; sid:=(src#>>'{encounter,id}')::uuid; rid:=(src#>>'{round,id}')::uuid;
 SELECT coalesce(l.is_test,false) INTO is_test FROM public.locations l WHERE l.id=p_location AND l.is_active;
 IF NOT FOUND THEN RAISE EXCEPTION 'panel_location_not_available' USING ERRCODE='42501'; END IF;
 FOR item IN SELECT value FROM jsonb_array_elements(src->'actors') LOOP
   IF coalesce((item->>'mine')::boolean,false) AND EXISTS(SELECT 1 FROM public.combat_v2_actors
     WHERE id=(item->>'id')::uuid AND session_id=sid AND exam_regia_private.actor_principal(id,controller_user)=exam_regia_private.current_principal() AND companion_id IS NULL) THEN
     controlled:=controlled||jsonb_build_array(jsonb_build_object('actor_id',item->'id','label',item->'name'));
   END IF;
 END LOOP;
 actor:=p_actor;
 IF actor IS NULL AND NOT(is_master OR is_admin) AND jsonb_array_length(controlled)>0 THEN
   actor:=(controlled#>>'{0,actor_id}')::uuid;
 END IF;
 IF actor IS NOT NULL AND NOT EXISTS(SELECT 1 FROM jsonb_array_elements(controlled) AS a(value)
   WHERE value->>'actor_id'=actor::text) THEN
   RAISE EXCEPTION 'panel_actor_not_controlled' USING ERRCODE='42501'; END IF;
 phase:=CASE WHEN src#>>'{master,stato}'='sospesa' OR src#>>'{encounter,state}'='sospeso' THEN 'suspended'
   WHEN sid IS NULL OR rid IS NULL THEN 'setup'
   WHEN NOT EXISTS(SELECT 1 FROM combat_spatial.arena_instances WHERE encounter_id=sid)
     AND NOT EXISTS(SELECT 1 FROM public.combat_v2_declarations d JOIN public.combat_v2_rounds r ON r.id=d.round_id WHERE r.session_id=sid) THEN 'setup'
   ELSE CASE src#>>'{round,phase}' WHEN 'raccolta_azioni' THEN 'action' WHEN 'raccolta_difese' THEN 'defense'
     WHEN 'congelato' THEN 'review' WHEN 'valutazione' THEN 'review' WHEN 'risoluzione' THEN 'resolving'
     WHEN 'risolto' THEN 'resolved' WHEN 'narrazione' THEN 'resolved' WHEN 'narrato' THEN 'resolved' ELSE NULL END END;
 IF phase IS NULL THEN RAISE EXCEPTION 'panel_master_phase_unsupported' USING ERRCODE='22023'; END IF;
 phase_label:=CASE phase WHEN 'setup' THEN 'Preparazione dello scontro' WHEN 'action' THEN 'Raccolta delle azioni'
   WHEN 'defense' THEN 'Raccolta delle difese' WHEN 'review' THEN 'Valutazione del Master'
   WHEN 'resolving' THEN 'Risoluzione in corso' WHEN 'resolved' THEN 'Esito del round' ELSE 'Scontro sospeso' END;
 simulated:=CASE WHEN sid IS NULL THEN is_test ELSE NOT public.combat_v2_values_written(sid) END;
 policy:=CASE WHEN exam_regia_private.is_bound(sid) THEN 'exam_protected_no_persistent_resources_v1' WHEN is_test THEN 'staff_test_no_persistent_resources_v1' ELSE 'master_game_resources_v1' END;
 IF sid IS NOT NULL AND (actor IS NOT NULL OR is_master OR is_admin) THEN
   map_view:=combat_panel_private.master_map(sid,actor);
 END IF;
 FOR item IN SELECT value FROM jsonb_array_elements(src->'actors') LOOP
   SELECT * INTO STRICT meta FROM public.combat_v2_actors WHERE id=(item->>'id')::uuid AND session_id=sid;
   body_only:=meta.companion_id IS NOT NULL;
   actor_state:=CASE item->>'state' WHEN 'attivo' THEN 'active' WHEN 'fuori' THEN 'out' WHEN 'ritirato' THEN 'withdrawn' ELSE NULL END;
   IF actor_state IS NULL THEN RAISE EXCEPTION 'panel_actor_state_unsupported' USING ERRCODE='22023'; END IF;
   selected:=actor IS NOT NULL AND meta.id=actor;
   resources:=NULL;
   IF jsonb_typeof(item#>'{resources,vita}')='number' AND jsonb_typeof(item#>'{resources,vita_max}')='number'
     AND jsonb_typeof(item#>'{resources,chakra}')='number' AND jsonb_typeof(item#>'{resources,chakra_max}')='number'
     AND (item#>>'{resources,vita}')::numeric BETWEEN 0 AND (item#>>'{resources,vita_max}')::numeric
     AND (item#>>'{resources,chakra}')::numeric BETWEEN 0 AND (item#>>'{resources,chakra_max}')::numeric THEN
     resources:=jsonb_build_object('pv',jsonb_build_object('current',item#>'{resources,vita}','max',item#>'{resources,vita_max}'),
       'chakra',jsonb_build_object('current',item#>'{resources,chakra}','max',item#>'{resources,chakra_max}'),'simulated',simulated);
   END IF;
   distance:=NULL;
   IF jsonb_typeof(map_view->'pov')='object' AND NOT selected THEN
     SELECT round(combat_spatial.distance_m((map_view#>>'{pov,x_m}')::numeric,(map_view#>>'{pov,y_m}')::numeric,
       (value->>'x_m')::numeric,(value->>'y_m')::numeric),2) INTO distance
       FROM jsonb_array_elements(map_view->'actors') WHERE value->>'actor_id'=meta.id::text;
   END IF;
   -- Il compagno resta passivo: risponde il controllore tramite le stesse
   -- difese ammesse dal consumer, anche con Fili recisi (Nessuna difesa).
   due:=NOT body_only AND actor_state='active' AND phase='defense'
     AND (is_master OR is_admin OR exam_regia_private.actor_principal(meta.id,meta.controller_user)=exam_regia_private.current_principal())
     AND NOT EXISTS(SELECT 1 FROM public.combat_v2_declarations d
       WHERE d.round_id=rid AND d.actor_id=meta.id AND d.kind IN ('difesa','nessuna'))
     AND EXISTS(SELECT 1 FROM public.combat_v2_attack_targets t
       WHERE t.round_id=rid AND t.state='attesa_difesa' AND (
         t.target_actor_id=meta.id OR (
           EXISTS(SELECT 1 FROM jsonb_array_elements(coalesce(map_view->'actors','[]')) v
             WHERE v->>'actor_id'=t.target_actor_id::text)
           AND clan_marionettisti_private.defends_body(meta.id,t.target_actor_id,'nessuna'))));
   roster:=roster||jsonb_build_array(jsonb_build_object('actor_id',meta.id,
     'kind',CASE WHEN body_only THEN 'companion' ELSE meta.actor_kind END,'body_only',body_only,
     'display_name',CASE WHEN body_only THEN to_jsonb('Marionetta'::text) ELSE item->'name' END,'team',item->'team','state',actor_state,'mine',selected,
     'action_due',NOT body_only AND actor_state='active' AND phase='action' AND NOT coalesce((item->>'has_action')::boolean,false),
     'defense_due',due,'resources',resources,'distance_from_viewer_m',distance));
 END LOOP;
 IF sid IS NOT NULL AND rid IS NOT NULL THEN
   narrative_meta:=combat_panel_private.narrative_details(p_location,sid,rid);
   narrative_view:=jsonb_build_object('schema_version','combat-panel-narrative/1','activity_id',sid,'round_id',rid,
     'mode','human','state',CASE WHEN narrative_meta#>>'{last_published,round_id}'=rid::text THEN 'published'
       WHEN phase='resolved' THEN 'waiting' ELSE 'idle' END,'reason_code',null,
     'report_id',narrative_meta->'report_id','report_sha256',narrative_meta->'report_sha256',
     'last_published',narrative_meta->'last_published');
 END IF;
 multiplication:=combat_panel_private.multiplication_view(p_location,map_view->'actors');
 map_view:=combat_panel_private.multiplication_mask_map(map_view,multiplication);
 roster:=combat_panel_private.multiplication_mask_roster(roster,multiplication);
 -- Versione fissa per il fingerprint: non dipende dalla versione che genera.
 companion_view:=combat_panel_private.master_companion_projection(actor);
 sabaku_view:=clan_sabaku_private.master_panel_projection(actor,1);
 c:=combat_panel_private.refresh_context(p_location,actor,
   CASE WHEN coalesce(sid,mid) IS NULL THEN NULL ELSE 'master_v2' END,coalesce(sid,mid),rid,
   (map_view->>'map_version')::bigint,jsonb_build_object('multiplication',multiplication,'is_master',is_master,'is_admin',is_admin,'source',src,'map',map_view,'narrative',narrative_view,'sabaku',sabaku_view,'companion',companion_view));
 RETURN clan_sabaku_private.clone_attach_map(jsonb_build_object('schema_version','combat-panel/1','status','ready','reason_code',null,
   'context',jsonb_build_object('activity_id',coalesce(sid,mid),'activity_kind',c.activity_kind,
     'location_id',p_location,'round_id',rid,'round_no',to_jsonb(exam_regia_private.logical_round_no(rid)),'phase',phase,'phase_label',phase_label,
     'version',c.context_version,'scene_version',c.scene_version,'policy_id',policy,'simulated',simulated),
   'viewer',jsonb_build_object('command_actor_id',actor,'controlled_actors',controlled,'is_master',is_master,
     'is_admin',is_admin,'can_command',is_master OR is_admin OR (actor IS NOT NULL AND phase IN ('action','defense'))),
   'actors',roster,'map',map_view,'offers','[]'::jsonb,'movement_explanations',null,
   'multiplication',multiplication,'companion',companion_view,'sabaku_transport',CASE WHEN sabaku_view IS NULL THEN NULL
     ELSE jsonb_set(sabaku_view,'{context_version}',to_jsonb(c.context_version)) END,'narrative',narrative_view,
   'round_details',combat_panel_private.round_details_from_source(src,roster),'receipt',null));
END $function$;
CREATE OR REPLACE FUNCTION combat_panel_private.master_state_authoritative(p_location uuid)
 RETURNS jsonb
 LANGUAGE plpgsql
 STABLE SECURITY DEFINER
 SET search_path TO ''
AS $function$
declare
  v_uid uuid:=exam_regia_private.current_principal();
  v_m public.master_v2_sessions%rowtype;
  v_s public.combat_v2_sessions%rowtype;
  v_r public.combat_v2_rounds%rowtype;
  v_is_admin boolean:=false;
  v_is_master boolean:=false;
  v_is_participant boolean:=false;
begin
  if v_uid is null then
    perform public.combat_v2_fail('autenticazione_richiesta','Autenticazione richiesta.',401,null,'{}');
  end if;

  select * into v_m
    from public.master_v2_sessions
   where location_id=p_location and stato not in ('chiusa','annullata')
   order by created_at desc limit 1;

  if v_m.id is null then
    return public.combat_v2_envelope(null,jsonb_build_object(
      'viewer',jsonb_build_object('is_master',false,'is_admin',public.combat_v2_is_admin(v_uid)),
      'master',null,'encounter',null,'actors','[]'::jsonb,'round',null,
      'declarations','[]'::jsonb,'pending_defenses','[]'::jsonb,
      'ratings_pending','[]'::jsonb,'report',null));
  end if;

  v_is_admin:=public.combat_v2_is_admin(v_uid);
  v_is_master:=coalesce(v_m.master_user=v_uid,false);
  select exists(
    select 1 from public.master_v2_participants p
     where p.session_id=v_m.id and p.user_id_snapshot=v_uid
       and p.engagement_state in ('attivo','sospeso')
  ) into v_is_participant;

  v_is_participant:=v_is_participant OR EXISTS(SELECT 1 FROM exam_regia_private.bindings b
 WHERE b.master_session_id=v_m.id AND b.service_principal_id=v_uid AND b.state<>'closed'
 AND v_uid=exam_regia_private.current_principal());
  if not (v_is_master or v_is_admin or v_is_participant) then
    perform public.combat_v2_fail('master_non_proprietario','Sessione non accessibile.',403,null,'{}');
  end if;

  select * into v_s
    from public.combat_v2_sessions
   where master_session_id=v_m.id and state not in ('chiuso','annullato')
   order by created_at desc limit 1;

  if v_s.id is not null then
    select * into v_r
      from public.combat_v2_rounds
     where session_id=v_s.id
     order by round_no desc limit 1;
  end if;

  return public.combat_v2_envelope(null,jsonb_build_object(
    'viewer',jsonb_build_object(
      'is_master',v_is_master,
      'is_admin',v_is_admin,
      'is_participant',v_is_participant),
    'master',jsonb_build_object(
      'id',v_m.id,'location_id',v_m.location_id,'tipo',v_m.tipo,
      'stato',v_m.stato,
      'control_version',v_m.control_version,'mission_id',v_m.mission_id,
      'titolo',v_m.titolo,'suspended_at',v_m.suspended_at),
    'encounter',case when v_s.id is null then null else jsonb_build_object(
      'id',v_s.id,'state',v_s.state,'source_kind',v_s.source_kind,
      'location_id',v_s.location_id,'lesiva',v_s.lesiva) end,
    'actors',case when v_s.id is null then '[]'::jsonb else coalesce((
      select jsonb_agg(jsonb_build_object(
        'id',a.id,
        'kind',a.actor_kind,
        'name',coalesce(c.name,p.nome,pi.nome,'Attore'),
        'character_id',a.character_id,
        'team',a.team_key,
        'state',a.state,
        'position_m',a.position_m,
        'initiative',a.initiative_snapshot,
        'mine',exam_regia_private.actor_principal(a.id,a.controller_user)=v_uid,
        'has_action',exists(
          select 1 from public.combat_v2_declarations d
           where d.round_id=v_r.id and d.actor_id=a.id
             and d.kind in ('attacco','movimento','utilita','passa')),
        'reaction_used',exists(
          select 1 from public.combat_v2_declarations d
           join public.combat_v2_declarations x on x.id=d.parent_attack_id
           where d.round_id=v_r.id and d.kind='difesa'
             and x.target_actor_id=a.id),
        'resources',case when v_is_master or v_is_admin or exam_regia_private.actor_principal(a.id,a.controller_user)=v_uid
          then jsonb_build_object(
            'vita',a.mechanics_snapshot->'vita',
            'vita_max',a.mechanics_snapshot->'vita_max',
            'chakra',a.mechanics_snapshot->'chakra',
            'chakra_max',a.mechanics_snapshot->'chakra_max')
          else null end
      ) order by a.initiative_snapshot desc,a.id)
      from public.combat_v2_actors a
      left join public.characters c on c.id=a.character_id
      left join public.combat_v2_png_instances p on p.id=a.png_instance_id left join public.combat_v2_provider_instances_v1 pi on pi.id=a.provider_instance_v1_id
      where a.session_id=v_s.id
    ),'[]'::jsonb) end,
    'round',case when v_r.id is null then null else jsonb_build_object(
      'id',v_r.id,'no',v_r.round_no,'phase',v_r.phase,'state',v_r.state,
      'evaluation_mode',v_r.evaluation_mode,'report_id',v_r.report_id,
      'resolved_at',v_r.resolved_at,'narrated_at',v_r.narrated_at) end,
    'declarations',case when v_r.id is null then '[]'::jsonb else coalesce((
      select jsonb_agg(jsonb_build_object(
        'id',d.id,'actor_id',d.actor_id,'actor_name',coalesce(ac.name,ap.nome,aip.nome,'Attore'),
        'actor_kind',aa.actor_kind,'kind',d.kind,
        'target_actor_id',d.target_actor_id,'target_name',coalesce(tc.name,tp.nome,tip.nome,'Attore'),
        'parent_attack_id',d.parent_attack_id,'targets',(select coalesce(jsonb_agg(jsonb_build_object('attack_target_id',t.id,'ordinal',t.ordinal,'target_actor_id',t.target_actor_id,'state',t.state,'outcome',case when v_r.state in('risolto','narrazione','narrato')then t.outcome else null end)order by t.ordinal),'[]'::jsonb)from public.combat_v2_attack_targets t where t.attack_declaration_id=d.id),'coverage',(select coalesce(jsonb_agg(jsonb_build_object('attack_target_id',c.attack_target_id,'protected_actor_id',c.protected_actor_id,'mode',c.mode,'state',c.state)order by c.id),'[]'::jsonb)from public.combat_v2_defense_coverages c where c.defense_declaration_id=d.id),'state',d.state,'order_no',d.order_no,
        'text',case when v_is_master or v_is_admin or exam_regia_private.actor_principal(aa.id,aa.controller_user)=v_uid
                         or exam_regia_private.actor_principal(ta.id,ta.controller_user)=v_uid or v_r.state in ('risolto','narrazione','narrato')
                    then d.declaration_text else '' end,
        'choice',jsonb_strip_nulls(jsonb_build_object(
          'kind',d.sanitized_intent->>'kind',
          'reaction',d.sanitized_intent->>'reaction',
          'ability_name',d.sanitized_intent->'server_ability'->>'name')),
        'rating',case
          when rr.id is null then null
          when v_is_admin or (rr.source<>'revisione_admin' and (v_is_master or exam_regia_private.actor_principal(aa.id,aa.controller_user)=v_uid))
          then jsonb_build_object('id',rr.id,'value',rr.value,'reason',rr.reason,
                                 'source',rr.source,'created_at',rr.created_at)
          else null end
      ) order by d.order_no nulls last,d.created_at,d.id)
      from public.combat_v2_declarations d
      join public.combat_v2_actors aa on aa.id=d.actor_id
      left join public.characters ac on ac.id=aa.character_id
      left join public.combat_v2_png_instances ap on ap.id=aa.png_instance_id left join public.combat_v2_provider_instances_v1 aip on aip.id=aa.provider_instance_v1_id
      left join public.combat_v2_actors ta on ta.id=d.target_actor_id
      left join public.characters tc on tc.id=ta.character_id
      left join public.combat_v2_png_instances tp on tp.id=ta.png_instance_id left join public.combat_v2_provider_instances_v1 tip on tip.id=ta.provider_instance_v1_id
      left join lateral (
        select r0.* from public.combat_v2_ratings r0
         where r0.declaration_id=d.id and r0.is_active
         order by r0.created_at desc limit 1
      ) rr on true
      where d.round_id=v_r.id
        and (v_is_master or v_is_admin or exam_regia_private.actor_principal(aa.id,aa.controller_user)=v_uid
             or exam_regia_private.actor_principal(ta.id,ta.controller_user)=v_uid or v_r.state in ('risolto','narrazione','narrato'))
    ),'[]'::jsonb) end,
    'pending_defenses',case when v_r.id is null then '[]'::jsonb else coalesce((
      select jsonb_agg(jsonb_build_object(
        'attack_declaration_id',d.id,
        'attacker_actor_id',d.actor_id,
        'attacker_name',coalesce(ac.name,ap.nome,aip.nome,'Attore'),
        'target_actor_id',d.target_actor_id,
        'target_name',coalesce(tc.name,tp.nome,tip.nome,'Attore'),
        'text',case when v_is_master or v_is_admin or exam_regia_private.actor_principal(ta.id,ta.controller_user)=v_uid
                    then d.declaration_text else '' end
      ) order by d.created_at,d.id)
      from public.combat_v2_declarations d
      join public.combat_v2_actors aa on aa.id=d.actor_id
      left join public.characters ac on ac.id=aa.character_id
      left join public.combat_v2_png_instances ap on ap.id=aa.png_instance_id left join public.combat_v2_provider_instances_v1 aip on aip.id=aa.provider_instance_v1_id
      join public.combat_v2_actors ta on ta.id=d.target_actor_id
      left join public.characters tc on tc.id=ta.character_id
      left join public.combat_v2_png_instances tp on tp.id=ta.png_instance_id left join public.combat_v2_provider_instances_v1 tip on tip.id=ta.provider_instance_v1_id
      where d.round_id=v_r.id and d.kind='attacco'
        and not exists(select 1 from public.combat_v2_declarations x
                        where x.parent_attack_id=d.id and x.kind in ('difesa','nessuna'))
        and (v_is_master or v_is_admin or exam_regia_private.actor_principal(ta.id,ta.controller_user)=v_uid)
    ),'[]'::jsonb) end,
    'ratings_pending',case when not (v_is_master or v_is_admin) or v_r.id is null
      then '[]'::jsonb else coalesce((
        select jsonb_agg(jsonb_build_object(
          'declaration_id',d.id,'kind',d.kind,
          'actor_id',d.actor_id,'actor_name',c.name,
          'text',d.declaration_text
        ) order by d.created_at,d.id)
        from public.combat_v2_declarations d
        join public.combat_v2_actors a on a.id=d.actor_id and a.actor_kind='pg'
        join public.characters c on c.id=a.character_id
        where d.round_id=v_r.id and d.kind in ('attacco','difesa')
          and not exists(select 1 from public.combat_v2_ratings x
                          where x.declaration_id=d.id and x.is_active)
      ),'[]'::jsonb) end,
    'report',case when v_r.id is null or not (v_is_master or v_is_admin) then null else (
      select jsonb_build_object(
        'id',q.id,'sha256',q.mechanics_sha256,'mechanics',q.mechanics,
        'values_written',q.values_written,'narration_state',q.narration_state,
        'narrator_kind',q.narrator_kind,'created_at',q.created_at)
      from public.combat_v2_round_reports q where q.round_id=v_r.id
    ) end
  ));
end
$function$;
CREATE OR REPLACE FUNCTION combat_panel_private.movement_budget(p_owner uuid, p_round uuid)
 RETURNS jsonb
 LANGUAGE plpgsql
 STABLE SECURITY DEFINER
 SET search_path TO ''
AS $function$
DECLARE a public.combat_v2_actors%ROWTYPE; base numeric; spent numeric; bonus numeric:=0;
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
 base:=floor((a.mechanics_snapshot->>'velocita')::numeric/10)*5;
 -- Ogni percorso conserva la sua ricevuta sorgente. PG e marionetta
 -- consumano entrambi quella del medesimo owner; il movimento principale
 -- Master ha la ricevuta della dichiarazione, mai una seconda contabilita.
 SELECT coalesce(sum(cost_m),0) INTO spent FROM (
   SELECT combat_panel_private.movement_event_cost((result->>'event_id')::uuid,distance_m) AS cost_m FROM clan_marionettisti_private.movement_receipts WHERE owner_actor_id=a.id AND round_id=ANY(exam_regia_private.logical_round_ids(p_round))
   UNION ALL
   SELECT combat_panel_private.movement_event_cost(spatial_event_id,distance_m) AS cost_m FROM combat_panel_private.master_movement_receipts WHERE owner_actor_id=a.id AND round_id=ANY(exam_regia_private.logical_round_ids(p_round))
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
 RETURN jsonb_build_object('base_m',base,'spent_m',spent,'movement_max_flat_m',bonus,
   'maximum_m',base+bonus,'remaining_m',CASE WHEN a.state='attivo' THEN greatest(0,base+bonus-spent) ELSE 0 END);
END $function$;
CREATE OR REPLACE FUNCTION combat_panel_private.movement_explanations(p_context uuid, p_expected bigint)
 RETURNS jsonb
 LANGUAGE plpgsql
 STABLE SECURITY DEFINER
 SET search_path TO ''
AS $function$
DECLARE c combat_panel_private.contexts%ROWTYPE; a public.combat_v2_actors%ROWTYPE;
 o combat_panel_private.offers%ROWTYPE; q record; original combat_consumer_private.offers%ROWTYPE;
 cap combat_spatial.movement_capabilities%ROWTYPE; body combat_spatial.actor_states%ROWTYPE;
 choice combat_spatial.movement_semantic_choices%ROWTYPE; iid uuid; capid uuid; parent_source_offer uuid;
 budget jsonb; general jsonb; reasons jsonb; entries jsonb:='[]'; block text;
 desired numeric; effective numeric; own_turn boolean; regions jsonb; terrain jsonb; visible_areas boolean; block_t numeric; cost_cap combat_panel_private.movement_cost_capabilities%ROWTYPE;
BEGIN
 c:=combat_panel_private.owned_context(p_context,p_expected);
 IF c.command_actor_id IS NULL OR c.round_id IS NULL THEN RETURN NULL; END IF;
 SELECT * INTO STRICT a FROM public.combat_v2_actors WHERE id=c.command_actor_id
   AND session_id=c.activity_id AND exam_regia_private.actor_principal(id,controller_user)=exam_regia_private.current_principal() AND companion_id IS NULL;
 SELECT instance_id INTO iid FROM combat_spatial.arena_instances
   WHERE encounter_id=c.activity_id AND state='open';
 IF iid IS NULL OR a.state<>'attivo' THEN RETURN NULL; END IF;
 own_turn:=CASE c.activity_kind WHEN 'ordinary_v2' THEN EXISTS(
   SELECT 1 FROM combat_consumer_private.activities WHERE session_id=c.activity_id
     AND exchange_id=c.round_id AND turn_actor_id=a.id AND phase='action')
   WHEN 'master_v2' THEN EXISTS(SELECT 1 FROM combat_panel_private.actor_turns t
     JOIN public.combat_v2_rounds r ON r.id=t.round_id
     WHERE t.round_id=c.round_id AND t.actor_id=a.id AND t.state='ready' AND r.phase='raccolta_azioni')
   ELSE false END;
 budget:=combat_panel_private.movement_budget(a.id,c.round_id);
 visible_areas:=EXISTS(SELECT 1 FROM combat_spatial.viewer_grants WHERE instance_id=iid
   AND viewer_principal_id=exam_regia_private.current_principal() AND can_view_map AND can_view_objects);
 FOR o IN SELECT * FROM combat_panel_private.offers WHERE context_id=c.id
   AND principal_user=exam_regia_private.current_principal() AND actor_id=a.id AND context_version=c.context_version
   AND source_fingerprint=c.source_fingerprint AND scene_version IS NOT DISTINCT FROM c.scene_version
   AND state='offered' ORDER BY created_at,id LOOP
   general:='[]'; block:=NULL;
   -- Anche quando il movimento e impedito, la causa puo accompagnare
   -- un'azione valida. Non si crea un falso comando di movimento eseguibile.
   IF own_turn AND o.kind='action' AND o.operation='declare' THEN
     block:=combat_panel_private.movement_block_reason(a.id);
     IF block IS NOT NULL THEN
       general:=jsonb_build_array(jsonb_build_object('kind','blocked','source_kind','undisclosed',
         'label','Il personaggio non può spostarsi nelle condizioni attuali.','amount_m',NULL));
     END IF;
     IF (budget->>'spent_m')::numeric>0 THEN
       general:=general||jsonb_build_array(jsonb_build_object('kind','budget_reduction','source_kind','undisclosed',
         'label','Movimento già utilizzato in questo turno, compresi i compagni che condividono il budget.',
         'amount_m',(budget->>'spent_m')::numeric));
     END IF;
     IF jsonb_array_length(general)>0 THEN
       entries:=entries||jsonb_build_array(jsonb_build_object('offer_id',o.id,'option_id',NULL,
         'effective_distance_m',CASE WHEN block IS NOT NULL THEN 0 ELSE NULL END,'reasons',general));
     END IF;
   END IF;
   FOR q IN SELECT x.* FROM combat_panel_private.choice_options x
     JOIN combat_panel_private.choice_groups g ON g.id=x.group_id AND g.offer_id=x.offer_id
     WHERE x.offer_id=o.id AND (g.purpose='movement_distance'
       OR x.source_payload->>'movement_capability_id' IS NOT NULL
       OR x.source_payload->>'multiplication_movement_capability_id' IS NOT NULL) ORDER BY g.ordinal,x.ordinal LOOP
     -- Prima dell'estrazione non esiste un unico percorso cui attribuire un sovraccosto.
     -- Distanza e candidati sono convalidati dal commit comune; il ledger conserva il costo effettivo.
     IF q.source_payload ? 'multiplication_random_sources' OR q.source_payload ? 'multiplication_figures' THEN CONTINUE; END IF;
     -- La disposizione descrive le copie; soltanto la scelta dell'originale possiede la capability del corpo.
     capid:=NULL;
     IF q.source_payload->>'movement_capability_id' IS NOT NULL THEN
       capid:=(q.source_payload->>'movement_capability_id')::uuid;
     ELSIF q.source_payload->>'multiplication_movement_capability_id' IS NOT NULL THEN
       capid:=(q.source_payload->>'multiplication_movement_capability_id')::uuid;
     ELSIF o.source_payload->>'adapter'='master_v2' THEN
       capid:=(q.source_payload->>'movement_capability_id')::uuid;
     ELSIF o.source_payload->>'adapter'='ordinary_v2' THEN
       parent_source_offer:=(o.source_payload->>'source_offer_id')::uuid;
       IF parent_source_offer IS NULL AND q.source_payload ? 'movement_offer_id' THEN
         -- Follow only this option's own dependency chain inside the same offer.
         WITH RECURSIVE lineage AS (
           SELECT x.id,x.group_id,x.source_payload,ARRAY[x.id] AS visited,0 AS depth
           FROM combat_panel_private.choice_options x WHERE x.id=q.id AND x.offer_id=o.id
           UNION ALL
           SELECT parent.id,parent.group_id,parent.source_payload,l.visited||parent.id,l.depth+1
           FROM lineage l JOIN combat_panel_private.choice_groups g ON g.id=l.group_id AND g.offer_id=o.id
           JOIN combat_panel_private.choice_options parent ON parent.id=g.depends_on AND parent.offer_id=o.id
           WHERE NOT parent.id=ANY(l.visited)
         ) SELECT (source_payload->>'source_offer_id')::uuid INTO parent_source_offer
           FROM lineage WHERE source_payload->>'source_offer_id' IS NOT NULL ORDER BY depth LIMIT 1;
       END IF;
       SELECT * INTO original FROM combat_consumer_private.offers WHERE
         id=coalesce((q.source_payload->>'movement_offer_id')::uuid,(q.source_payload->>'source_offer_id')::uuid)
         AND session_id=c.activity_id AND exchange_id=c.round_id AND location_id=c.location_id
         AND principal_character_id=a.character_id AND state='offered'
         AND context_version=(o.source_payload->>'source_context_version')::bigint
         AND scene_version IS NOT DISTINCT FROM c.scene_version;
       IF original.id IS NOT NULL AND (
         (q.source_payload ? 'movement_offer_id' AND original.offer_kind='movement'
           AND parent_source_offer IS NOT NULL AND original.parent_offer_id=parent_source_offer)
         OR (q.source_payload ? 'source_offer_id' AND original.operation='control'
           AND original.source_payload->>'marionetta_operation'='move')) THEN
         capid:=(original.source_payload->>'capability_id')::uuid;
       END IF;
     END IF;
     SELECT * INTO cap FROM combat_spatial.movement_capabilities
       WHERE capability_id=capid AND instance_id=iid AND state='offered';
     SELECT * INTO body FROM combat_spatial.actor_states WHERE instance_id=iid AND actor_id=cap.actor_id;
     SELECT * INTO choice FROM combat_spatial.movement_semantic_choices
       WHERE instance_id=iid AND actor_id=cap.actor_id AND choice_key=cap.choice_key;
     IF cap.capability_id IS NULL OR body.state IS DISTINCT FROM 'active'
       OR body.controller_principal_id IS DISTINCT FROM exam_regia_private.current_principal()
       OR cap.actor_body_version IS DISTINCT FROM body.body_version
       OR cap.choice_version IS DISTINCT FROM choice.choice_version OR NOT coalesce(choice.enabled,false)
       OR cap.map_version IS DISTINCT FROM c.scene_version
       OR (cap.start_x_m,cap.start_y_m) IS DISTINCT FROM (body.x_m,body.y_m)
       OR (cap.actor_id IS DISTINCT FROM a.id AND NOT EXISTS(
         SELECT 1 FROM clan_marionettisti_private.links WHERE owner_actor_id=a.id
           AND companion_actor_id=cap.actor_id AND state='connected')) THEN
       RAISE EXCEPTION 'panel_movement_explanation_source_changed' USING ERRCODE='40001'; END IF;
     IF combat_panel_private.movement_block_reason(cap.actor_id) IS NOT NULL THEN
       RAISE EXCEPTION 'panel_movement_explanation_body_changed' USING ERRCODE='40001'; END IF;
     effective:=round(combat_spatial.distance_m(cap.start_x_m,cap.start_y_m,cap.end_x_m,cap.end_y_m),2);
     desired:=combat_spatial.distance_m(cap.start_x_m,cap.start_y_m,choice.endpoint_x_m,choice.endpoint_y_m);
     IF q.distance_m IS DISTINCT FROM effective THEN
       RAISE EXCEPTION 'panel_movement_explanation_distance_changed' USING ERRCODE='40001'; END IF;
     regions:=combat_panel_private.movement_regions_for_body(iid,cap.actor_id);
     SELECT * INTO cost_cap FROM combat_panel_private.movement_cost_capabilities WHERE capability_id=cap.capability_id;
     IF cost_cap.capability_id IS NULL OR cost_cap.regions_fingerprint<>md5(regions::text) THEN
       RAISE EXCEPTION 'panel_movement_explanation_terrain_changed' USING ERRCODE='40001'; END IF;
     terrain:=combat_panel_private.impervious_path_profile(cap.start_x_m,cap.start_y_m,cap.end_x_m,cap.end_y_m,regions);
     reasons:='[]';
     IF (terrain->>'impervious_distance_m')::numeric>0 THEN
       reasons:=jsonb_build_array(jsonb_build_object('kind','path_surcharge',
         'source_kind',CASE WHEN visible_areas THEN 'environment' ELSE 'undisclosed' END,
         'label',CASE WHEN visible_areas THEN 'Il tratto nelle aree impervie consuma movimento doppio.'
           ELSE 'Il percorso richiede movimento aggiuntivo per le condizioni attuali.' END,
         'amount_m',CASE WHEN visible_areas THEN round((terrain->>'impervious_distance_m')::numeric,2) ELSE NULL END));
     END IF;
     IF effective<round(desired,2) THEN
       block_t:=combat_spatial.path_first_block_t(iid,cap.actor_id,cap.start_x_m,cap.start_y_m,choice.endpoint_x_m,choice.endpoint_y_m);
       -- Un ostacolo successivo al limite del budget non ha fermato questo movimento.
       IF block_t<1 AND (terrain->>'distance_m')::numeric+0.000000001>=desired*block_t THEN
         reasons:=reasons||jsonb_build_array(jsonb_build_object('kind','blocked','source_kind','undisclosed',
           'label','Il percorso si arresta prima della destinazione per i limiti attuali dello scontro.',
           'amount_m',NULL));
       END IF;
     END IF;
     entries:=entries||jsonb_build_array(jsonb_build_object('offer_id',o.id,'option_id',q.id,
       'effective_distance_m',effective,'reasons',reasons));
   END LOOP;
 END LOOP;
 RETURN jsonb_build_object('contract_version','movement-explanations/2',
   'context_version',c.context_version,'entries',entries);
END $function$;
CREATE OR REPLACE FUNCTION combat_panel_private.multiplication_actor_profile(p_actor uuid)
 RETURNS jsonb
 LANGUAGE plpgsql
 STABLE SECURITY DEFINER
 SET search_path TO ''
AS $function$
DECLARE a public.combat_v2_actors%ROWTYPE; s public.combat_v2_sessions%ROWTYPE;
 ctx jsonb; ability jsonb; rank_name text; nij numeric; chakra numeric; reserved numeric;
 copy_cap integer; options jsonb; rid uuid;
BEGIN
 IF exam_regia_private.current_principal() IS NULL THEN RAISE EXCEPTION 'panel_authentication_required' USING ERRCODE='28000'; END IF;
 SELECT * INTO a FROM public.combat_v2_actors WHERE id=p_actor AND exam_regia_private.actor_principal(id,controller_user)=exam_regia_private.current_principal()
   AND companion_id IS NULL AND state='attivo';
 IF a.id IS NULL THEN RETURN NULL; END IF;
 SELECT * INTO s FROM public.combat_v2_sessions WHERE id=a.session_id AND closed_at IS NULL AND state='in_corso';
 IF s.id IS NULL THEN RETURN NULL; END IF;
 ctx:=combat_panel_private.owner_turn_context(a.id);
 IF ctx IS NULL OR ctx->>'activity_kind' NOT IN ('ordinary_v2','master_v2')
   OR NOT coalesce((ctx->>'can_move')::boolean,false) THEN RETURN NULL; END IF;
 rid:=(ctx->>'round_id')::uuid;
 IF rid IS NULL OR ctx->>'personal_turn_id' IS NULL OR EXISTS(
   SELECT 1 FROM public.combat_v2_declarations WHERE round_id=rid AND actor_id=a.id
     AND kind IN ('attacco','movimento','utilita','passa')) THEN RETURN NULL; END IF;
 IF combat_panel_private.access_reason(s.location_id,ctx->>'activity_kind') IS NOT NULL THEN RETURN NULL; END IF;
 ability:=public.combat_v2_actor_ability(a.id,'jutsu','c6e31b7b-38fe-4b4f-b3c7-05f3e922d193',false);
 IF ability IS NULL THEN RETURN NULL; END IF;
 -- La guardia Fili resta quella rilasciata: nessuna eccezione Moltiplicazione.
 BEGIN
   PERFORM clan_marionettisti_private.assert_jutsu_source(a.id,'jutsu','c6e31b7b-38fe-4b4f-b3c7-05f3e922d193');
 EXCEPTION WHEN SQLSTATE '22023' THEN
   IF SQLERRM='fili_other_jutsu_unavailable' THEN RETURN NULL; ELSE RAISE; END IF;
 END;
 IF ability->>'usage' IS DISTINCT FROM 'principale'
   OR ability->'diversivo' IS DISTINCT FROM 'true'::jsonb
   OR ability->'chakra_cost' IS DISTINCT FROM '10'::jsonb THEN
   RAISE EXCEPTION 'panel_multiplication_catalog_changed' USING ERRCODE='22023'; END IF;
 IF a.actor_kind='pg' THEN
   SELECT c.rank INTO rank_name FROM public.characters c WHERE c.id=a.character_id AND c.user_id=exam_regia_private.current_principal();
   IF rank_name IS NULL OR rank_name NOT IN ('Deshi','Genin','Chunin','Jonin','Jonin Speciale','Kage','Sannin') THEN
     RAISE EXCEPTION 'panel_multiplication_rank_unavailable' USING ERRCODE='22023'; END IF;
 ELSIF a.actor_kind='png' THEN
   -- Il grado D..S non viene convertito in un rango PG. L'istanza
   -- registrata fornisce lo snapshot server e il Ninjutsu della formula.
   IF NOT EXISTS(SELECT 1 FROM public.combat_v2_png_instances i
     WHERE i.id=a.png_instance_id AND i.session_id=a.session_id) THEN
     RAISE EXCEPTION 'panel_multiplication_npc_source_unavailable' USING ERRCODE='22023'; END IF;
 ELSE RAISE EXCEPTION 'panel_multiplication_actor_kind_invalid' USING ERRCODE='22023';
 END IF;
 IF jsonb_typeof(a.mechanics_snapshot->'ninjutsu') IS DISTINCT FROM 'number'
   OR jsonb_typeof(a.mechanics_snapshot->'chakra') IS DISTINCT FROM 'number' THEN
   RAISE EXCEPTION 'panel_multiplication_resources_invalid' USING ERRCODE='22023'; END IF;
 nij:=(a.mechanics_snapshot->>'ninjutsu')::numeric; chakra:=(a.mechanics_snapshot->>'chakra')::numeric;
 IF nij<0 OR nij<>trunc(nij) OR nij>2147483647 OR chakra<0
   OR nij IN ('NaN'::numeric,'Infinity'::numeric,'-Infinity'::numeric)
   OR chakra IN ('NaN'::numeric,'Infinity'::numeric,'-Infinity'::numeric) THEN
   RAISE EXCEPTION 'panel_multiplication_resources_invalid' USING ERRCODE='22023'; END IF;
 copy_cap:=CASE WHEN a.actor_kind='pg' THEN public._copie_cap(nij::integer,rank_name)
   ELSE nij::integer/10 END;
 SELECT coalesce(sum((d.cost_snapshot->>'chakra')::numeric),0) INTO reserved
   FROM public.combat_v2_declarations d WHERE d.round_id=rid AND d.actor_id=a.id;
 IF reserved<0 THEN RAISE EXCEPTION 'panel_multiplication_cost_snapshot_invalid' USING ERRCODE='22023'; END IF;
 SELECT coalesce(jsonb_agg(jsonb_build_object('copies',n,'chakra_cost',10+5*n) ORDER BY n),'[]'::jsonb)
   INTO options FROM generate_series(1,greatest(0,least(copy_cap,floor((chakra-reserved-10)/5)))::integer) n;
 RETURN jsonb_build_object('schema_version','combat-multiplication-profile/2',
   'activity_kind',ctx->'activity_kind','session_id',s.id,'round_id',rid,
   'personal_turn_id',ctx->'personal_turn_id','actor_id',a.id,'controller_version',a.controller_version,
   'ability_id','c6e31b7b-38fe-4b4f-b3c7-05f3e922d193','base_cost',10,'per_copy_cost',5,
   'copy_cap',copy_cap,'available',jsonb_array_length(options)>0,'copy_options',options);
END $function$;
CREATE OR REPLACE FUNCTION combat_panel_private.multiplication_add_defense_figures(p_offer uuid, p_defender uuid, p_attack_target uuid, p_dependency uuid DEFAULT NULL::uuid)
 RETURNS void
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO ''
AS $function$
DECLARE o combat_panel_private.offers%ROWTYPE; target public.combat_v2_attack_targets%ROWTYPE;
 attack public.combat_v2_declarations%ROWTYPE; formation record; geometry jsonb; figure jsonb; gid uuid;
BEGIN
 SELECT * INTO STRICT o FROM combat_panel_private.offers WHERE id=p_offer AND principal_user=exam_regia_private.current_principal()
   AND actor_id=p_defender AND kind='defense' AND operation='defend' AND state='offered';
 SELECT t.* INTO target FROM public.combat_v2_attack_targets t JOIN combat_panel_private.contexts c
   ON c.id=o.context_id AND c.round_id=t.round_id WHERE t.id=p_attack_target;
 IF target.id IS NULL THEN RETURN; END IF;
 SELECT * INTO STRICT attack FROM public.combat_v2_declarations WHERE id=target.attack_declaration_id AND round_id=target.round_id;
 SELECT f.id,f.state_version INTO formation FROM combat_panel_private.multiplication_formations f
   WHERE f.declaration_id=attack.id AND f.actor_id=attack.actor_id AND f.mode='assalto' AND f.state='active';
 IF NOT FOUND THEN RETURN; END IF;
 geometry:=combat_panel_private.multiplication_target_geometry(p_defender,attack.actor_id);
 IF geometry IS NULL OR geometry->>'formation_id' IS DISTINCT FROM formation.id::text
   OR geometry->>'state_version' IS DISTINCT FROM formation.state_version::text THEN RETURN; END IF;
 gid:=combat_panel_private.add_group(o.id,'Figura da contrastare (facoltativa)','generic','single',0,1,p_dependency);
 PERFORM combat_panel_private.add_choice(gid,'Estrazione del server',jsonb_build_object('multiplication_defense_choice',
   jsonb_build_object('formation_id',formation.id,'state_version',formation.state_version,'attack_target_id',target.id,'figure_index',NULL)));
 FOR figure IN SELECT value FROM jsonb_array_elements(geometry->'figures') ORDER BY (value->>'figure_index')::integer LOOP
   PERFORM combat_panel_private.add_choice(gid,'Figura '||(figure->>'figure_index'),jsonb_build_object('multiplication_defense_choice',
     jsonb_build_object('formation_id',formation.id,'state_version',formation.state_version,
       'attack_target_id',target.id,'figure_index',figure->'figure_index')));
 END LOOP;
END $function$;
CREATE OR REPLACE FUNCTION combat_panel_private.multiplication_attack_aim_valid(p_round uuid, p_actor uuid, p_target uuid, p_request uuid, p_range numeric)
 RETURNS boolean
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO ''
AS $function$
DECLARE aim combat_panel_private.multiplication_attack_aims%ROWTYPE; geometry jsonb;
BEGIN
 SELECT * INTO aim FROM combat_panel_private.multiplication_attack_aims
   WHERE request_key=p_request AND target_actor_id=p_target;
 IF aim.request_key IS NULL THEN
   -- NULL conserva il percorso nativo solo quando non esiste una formazione.
   IF EXISTS(SELECT 1 FROM combat_panel_private.multiplication_formations WHERE actor_id=p_target AND state='active') THEN RETURN false; END IF;
   RETURN NULL;
 END IF;
 IF aim.round_id IS DISTINCT FROM p_round OR aim.actor_id IS DISTINCT FROM p_actor
   OR aim.principal_user IS DISTINCT FROM exam_regia_private.current_principal() OR aim.prepared_transaction<>txid_current()
   OR aim.attack_target_id IS NOT NULL OR NOT EXISTS(SELECT 1 FROM public.combat_v2_actors
     WHERE id=p_actor AND exam_regia_private.actor_principal(id,controller_user)=exam_regia_private.current_principal() AND controller_version=aim.controller_version AND state='attivo') THEN RETURN false; END IF;
 IF p_range IS NULL OR p_range<0 OR p_range IN ('NaN'::numeric,'Infinity'::numeric,'-Infinity'::numeric) THEN RETURN false; END IF;
 IF aim.geometry->>'attack_origin'='marionetta' THEN
  geometry:=combat_panel_private.multiplication_companion_target_figure(p_round,p_actor,p_target,aim.formation_id,aim.formation_version,aim.selected_index);
  RETURN geometry IS NOT DISTINCT FROM aim.geometry AND (geometry#>>'{figure,distance_m}')::numeric<=least(p_range,3)
   AND (geometry#>>'{figure,path_clear}')::boolean;
 END IF;
 geometry:=combat_panel_private.multiplication_target_figure(p_actor,p_target,aim.formation_id,aim.formation_version,aim.selected_index);
 IF geometry IS DISTINCT FROM aim.geometry THEN RETURN false; END IF;
 RETURN combat_panel_private.multiplication_target_in_range(p_actor,p_target,aim.formation_id,aim.formation_version,aim.selected_index,p_range);
END $function$;
CREATE OR REPLACE FUNCTION combat_panel_private.multiplication_bind_attack_aims(p_declaration uuid)
 RETURNS void
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO ''
AS $function$
DECLARE d public.combat_v2_declarations%ROWTYPE; aim combat_panel_private.multiplication_attack_aims%ROWTYPE;
 target_id uuid; chosen_choice uuid; choice_key uuid;
BEGIN
 SELECT * INTO STRICT d FROM public.combat_v2_declarations WHERE id=p_declaration;
 FOR aim IN SELECT * FROM combat_panel_private.multiplication_attack_aims WHERE request_key=d.request_key
   ORDER BY target_actor_id FOR UPDATE LOOP
   IF d.kind<>'attacco' OR aim.round_id<>d.round_id OR aim.actor_id<>d.actor_id
     OR aim.principal_user IS DISTINCT FROM exam_regia_private.current_principal() OR aim.prepared_transaction<>txid_current()
     OR aim.controller_version<>d.controller_version_snapshot THEN
     RAISE EXCEPTION 'panel_multiplication_aim_binding_invalid' USING ERRCODE='40001'; END IF;
   IF coalesce(aim.geometry->>'attack_origin'='marionetta',false) IS DISTINCT FROM
    coalesce(d.sanitized_intent->>'ability_source'='clan' AND d.sanitized_intent->>'ability_id'='e361f7c3-f90b-47ec-bfee-ccbda21257d9',false) THEN
    RAISE EXCEPTION 'panel_attack_origin_mismatch' USING ERRCODE='22023'; END IF;
   SELECT id INTO target_id FROM public.combat_v2_attack_targets
     WHERE attack_declaration_id=d.id AND target_actor_id=aim.target_actor_id AND round_id=d.round_id;
   IF target_id IS NULL THEN RAISE EXCEPTION 'panel_multiplication_aim_target_missing' USING ERRCODE='22023'; END IF;
   IF aim.attack_target_id IS NOT NULL THEN
     IF aim.attack_target_id<>target_id THEN RAISE EXCEPTION 'panel_multiplication_aim_binding_conflict' USING ERRCODE='22023'; END IF;
     CONTINUE;
   END IF;
   choice_key:=md5('multiplication-aim:'||d.request_key||':'||aim.formation_id||':'||aim.target_actor_id)::uuid;
   chosen_choice:=combat_panel_private.multiplication_register_choice(aim.formation_id,target_id,d.actor_id,aim.selected_index,choice_key);
   UPDATE combat_panel_private.multiplication_attack_aims SET attack_target_id=target_id,choice_id=chosen_choice
     WHERE request_key=aim.request_key AND target_actor_id=aim.target_actor_id;
 END LOOP;
END $function$;
CREATE OR REPLACE FUNCTION combat_panel_private.multiplication_companion_attack_source(p_round uuid, p_owner uuid, p_target uuid, p_request uuid, p_declaration uuid)
 RETURNS jsonb
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO ''
AS $function$
DECLARE aim combat_panel_private.multiplication_attack_aims%ROWTYPE;
 geometry jsonb; target_version bigint;
BEGIN
 SELECT * INTO aim FROM combat_panel_private.multiplication_attack_aims
  WHERE request_key=p_request AND target_actor_id=p_target;
 IF aim.request_key IS NULL THEN
   IF EXISTS(SELECT 1 FROM combat_panel_private.multiplication_formations
     WHERE actor_id=p_target AND state='active') THEN
     RAISE EXCEPTION 'panel_multiplication_target_choice_required' USING ERRCODE='22023';
   END IF;
   RETURN clan_marionettisti_private.attack_source(p_round,p_owner,p_target);
 END IF;
 IF aim.round_id IS DISTINCT FROM p_round OR aim.actor_id IS DISTINCT FROM p_owner
  OR aim.principal_user IS DISTINCT FROM exam_regia_private.current_principal() OR aim.prepared_transaction<>txid_current()
  OR aim.geometry->>'attack_origin' IS DISTINCT FROM 'marionetta'
  OR NOT EXISTS(SELECT 1 FROM public.combat_v2_actors WHERE id=p_owner AND state='attivo'
    AND exam_regia_private.actor_principal(id,controller_user)=exam_regia_private.current_principal() AND controller_version=aim.controller_version) THEN
   RAISE EXCEPTION 'panel_multiplication_aim_stale' USING ERRCODE='40001';
 END IF;
 IF p_declaration IS NULL THEN
   IF aim.attack_target_id IS NOT NULL THEN
     RAISE EXCEPTION 'panel_multiplication_aim_already_bound' USING ERRCODE='40001';
   END IF;
 ELSE
   IF aim.choice_id IS NULL OR NOT EXISTS(SELECT 1 FROM public.combat_v2_attack_targets t
     JOIN public.combat_v2_declarations d ON d.id=t.attack_declaration_id
     WHERE t.id=aim.attack_target_id AND t.attack_declaration_id=p_declaration
       AND t.round_id=p_round AND t.target_actor_id=p_target
       AND d.actor_id=p_owner AND d.request_key=p_request AND d.kind='attacco'
       AND d.sanitized_intent->>'ability_source'='clan'
       AND d.sanitized_intent->>'ability_id'='e361f7c3-f90b-47ec-bfee-ccbda21257d9') THEN
     RAISE EXCEPTION 'panel_multiplication_aim_binding_invalid' USING ERRCODE='40001';
   END IF;
 END IF;
 geometry:=combat_panel_private.multiplication_companion_target_figure(
  p_round,p_owner,p_target,aim.formation_id,aim.formation_version,aim.selected_index);
 IF geometry IS DISTINCT FROM aim.geometry OR (geometry#>>'{figure,distance_m}')::numeric>3
   OR NOT (geometry#>>'{figure,path_clear}')::boolean THEN
   RAISE EXCEPTION 'marionetta_attack_out_of_range' USING ERRCODE='22023';
 END IF;
 SELECT source_body_version INTO STRICT target_version
  FROM combat_panel_private.multiplication_formations WHERE id=aim.formation_id;
 RETURN jsonb_build_object('instance_id',geometry->'instance_id',
   'companion_actor_id',geometry->'source_actor_id','link_version',geometry->'link_version',
   'source_body_version',geometry->'source_body_version',
   'target_body_version',target_version,'map_version',geometry->'map_version',
   'multiplication_attack_target',jsonb_build_object(
     'formation_id',aim.formation_id,'formation_version',aim.formation_version,
     'figure_index',aim.selected_index,'x_m',geometry#>'{figure,x_m}',
     'y_m',geometry#>'{figure,y_m}'));
END $function$;
CREATE OR REPLACE FUNCTION combat_panel_private.multiplication_companion_target_geometry(p_round uuid, p_owner uuid, p_target uuid)
 RETURNS jsonb
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO ''
AS $function$
DECLARE origin jsonb; geometry jsonb;
BEGIN
 IF exam_regia_private.current_principal() IS NULL OR NOT EXISTS(SELECT 1 FROM public.combat_v2_actors
  WHERE id=p_owner AND state='attivo' AND exam_regia_private.actor_principal(id,controller_user)=exam_regia_private.current_principal() AND companion_id IS NULL) THEN
  RAISE EXCEPTION 'panel_authentication_required' USING ERRCODE='28000'; END IF;
 origin:=clan_marionettisti_private.attack_origin(p_round,p_owner,p_target);
 geometry:=combat_panel_private.multiplication_target_geometry_for_body(p_owner,p_target,(origin->>'companion_actor_id')::uuid);
 IF geometry IS NULL OR geometry->>'instance_id' IS DISTINCT FROM origin->>'instance_id'
  OR geometry->>'map_version' IS DISTINCT FROM origin->>'map_version'
  OR geometry->>'source_body_version' IS DISTINCT FROM origin->>'source_body_version' THEN RETURN NULL; END IF;
 RETURN geometry||jsonb_build_object('attack_origin','marionetta','link_version',origin->'link_version');
END $function$;
CREATE OR REPLACE FUNCTION combat_panel_private.multiplication_declaration_meta(p_round uuid, p_actor uuid, p_request uuid, p_intent jsonb, p_meta jsonb)
 RETURNS jsonb
 LANGUAGE plpgsql
 STABLE SECURITY DEFINER
 SET search_path TO ''
AS $function$
DECLARE plan combat_panel_private.multiplication_declaration_plans%ROWTYPE;
 a public.combat_v2_actors%ROWTYPE;
BEGIN
 SELECT * INTO plan FROM combat_panel_private.multiplication_declaration_plans WHERE request_key=p_request;
 IF plan.request_key IS NULL THEN RETURN NULL; END IF;
 SELECT * INTO STRICT a FROM public.combat_v2_actors WHERE id=p_actor;
 IF plan.principal_user IS DISTINCT FROM exam_regia_private.current_principal() OR exam_regia_private.actor_principal(a.id,a.controller_user) IS DISTINCT FROM exam_regia_private.current_principal()
   OR plan.prepared_transaction<>txid_current() OR plan.declaration_id IS NOT NULL
   OR plan.round_id<>p_round OR plan.actor_id<>p_actor OR plan.controller_version<>a.controller_version
   OR p_intent->>'kind' IS DISTINCT FROM (CASE WHEN plan.mode='assalto' THEN 'attacco' ELSE 'utilita' END)
   OR (p_intent->>'target_actor')::uuid IS DISTINCT FROM plan.target_actor_id
   OR (plan.mode='assalto' AND coalesce(p_intent->>'ability_source','mano')<>'mano')
   OR p_intent ? 'ability_id' OR p_intent ? 'target_actor_ids' THEN
   RAISE EXCEPTION 'panel_multiplication_declaration_mismatch' USING ERRCODE='42501'; END IF;
 PERFORM clan_marionettisti_private.assert_jutsu_source(a.id,'jutsu','c6e31b7b-38fe-4b4f-b3c7-05f3e922d193');
 IF NOT EXISTS(SELECT 1 FROM combat_spatial.actor_states WHERE instance_id=plan.instance_id AND actor_id=a.id
     AND body_version=plan.source_body_version AND state='active') THEN
   RAISE EXCEPTION 'panel_multiplication_body_stale' USING ERRCODE='40001'; END IF;
 -- Il colpo usa il profilo fisico nativo. Il costo della tecnica viene
 -- scritto una volta nel cost_snapshot e consumato dal ledger normale.
 RETURN coalesce(p_meta,'{}'::jsonb)||jsonb_build_object('name','Moltiplicazione del corpo',
   'chakra_cost',plan.chakra_cost,'damage_base',CASE WHEN plan.mode='assalto' THEN 10 ELSE 0 END,
   'multiplication_mode',plan.mode,'multiplication_copies',plan.copies);
END $function$;
CREATE OR REPLACE FUNCTION combat_panel_private.multiplication_layout_options_for_figure(p_actor uuid, p_copies integer, p_mode text, p_target uuid, p_formation uuid, p_version bigint, p_index integer)
 RETURNS jsonb
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO ''
AS $function$
DECLARE a public.combat_v2_actors%ROWTYPE; b combat_spatial.actor_states%ROWTYPE;
 i combat_spatial.arena_instances%ROWTYPE; template combat_spatial.arena_templates%ROWTYPE;
 target_x numeric; target_y numeric; target_geometry jsonb; profile jsonb; budget jsonb; remaining numeric;
 direction record; rid uuid; figures jsonb; figure jsonb; available jsonb; layouts jsonb:='[]'::jsonb;
 bound jsonb:='[]'::jsonb; layout jsonb; option_row jsonb; native jsonb;
 valid boolean; can_move boolean; x numeric; y numeric; d numeric; key text; prefix text; cid uuid;
BEGIN
 IF exam_regia_private.current_principal() IS NULL THEN RAISE EXCEPTION 'panel_authentication_required' USING ERRCODE='28000'; END IF;
 IF num_nonnulls(p_formation,p_version,p_index) NOT IN (0,3)
   OR (p_formation IS NOT NULL AND p_mode IS DISTINCT FROM 'assalto') THEN
   RAISE EXCEPTION 'panel_multiplication_target_selection_invalid' USING ERRCODE='22023'; END IF;
 IF p_mode IS NULL OR p_mode NOT IN ('diversivo','copertura','assalto')
   OR (p_mode='assalto') IS DISTINCT FROM (p_target IS NOT NULL) THEN
   RAISE EXCEPTION 'panel_multiplication_mode_invalid' USING ERRCODE='22023'; END IF;
 SELECT * INTO STRICT a FROM public.combat_v2_actors WHERE id=p_actor AND exam_regia_private.actor_principal(id,controller_user)=exam_regia_private.current_principal()
   AND companion_id IS NULL AND state='attivo';
 profile:=combat_panel_private.multiplication_actor_profile(a.id);
 IF profile IS NULL OR NOT EXISTS(SELECT 1 FROM jsonb_array_elements(profile->'copy_options') WHERE (value->>'copies')::integer=p_copies) THEN RETURN layouts; END IF;
 rid:=(profile->>'round_id')::uuid;
 PERFORM public.combat_v2_lock_round(rid);
 profile:=combat_panel_private.multiplication_actor_profile(a.id);
 IF profile IS NULL OR profile->>'round_id' IS DISTINCT FROM rid::text
   OR NOT EXISTS(SELECT 1 FROM jsonb_array_elements(profile->'copy_options') WHERE (value->>'copies')::integer=p_copies) THEN RETURN layouts; END IF;
 SELECT * INTO STRICT i FROM combat_spatial.arena_instances WHERE encounter_id=a.session_id AND state='open' FOR UPDATE;
 SELECT * INTO STRICT b FROM combat_spatial.actor_states WHERE instance_id=i.instance_id AND actor_id=a.id AND state='active';
 IF b.controller_principal_id IS DISTINCT FROM exam_regia_private.current_principal() OR NOT combat_panel_private.shared_movement_scope(i.instance_id) THEN
   RAISE EXCEPTION 'panel_multiplication_controller_stale' USING ERRCODE='40001'; END IF;
 SELECT * INTO STRICT template FROM combat_spatial.arena_templates WHERE template_key=i.template_key AND template_version=i.template_version;
 budget:=combat_panel_private.movement_budget(a.id,(profile->>'round_id')::uuid);remaining:=(budget->>'remaining_m')::numeric;
 can_move:=remaining>0 AND (budget->>'spent_m')::numeric=0 AND combat_panel_private.movement_block_reason(a.id) IS NULL;
 IF p_mode='assalto' THEN
   IF NOT EXISTS(SELECT 1 FROM public.combat_v2_actors t WHERE t.id=p_target AND t.session_id=a.session_id AND t.state='attivo' AND t.team_key<>a.team_key)
     OR NOT combat_panel_private.body_visible_to_viewer(i.instance_id,p_target) THEN RETURN layouts; END IF;
   IF p_formation IS NOT NULL THEN
     IF NOT EXISTS(SELECT 1 FROM combat_panel_private.multiplication_formations f
       WHERE f.id=p_formation AND f.actor_id=p_target AND f.state='active' AND f.state_version=p_version
         AND f.mode IN ('copertura','diversivo','assalto')) THEN RETURN layouts; END IF;
     target_geometry:=combat_panel_private.multiplication_target_figure(a.id,p_target,p_formation,p_version,p_index);
     target_x:=(target_geometry#>>'{figure,x_m}')::numeric;target_y:=(target_geometry#>>'{figure,y_m}')::numeric;
   ELSE
     IF EXISTS(SELECT 1 FROM combat_panel_private.multiplication_formations WHERE actor_id=p_target AND state='active') THEN RETURN layouts; END IF;
     SELECT tb.x_m,tb.y_m INTO STRICT target_x,target_y FROM combat_spatial.actor_states tb
       WHERE tb.instance_id=i.instance_id AND tb.actor_id=p_target AND tb.state='active';
   END IF;
 END IF;
 prefix:='multiplication:'||(profile->>'round_id')||':'||b.body_version||':'||remaining||':';
 FOR direction IN SELECT * FROM (VALUES(1,0,'right'),(-1,0,'left'),(0,1,'down'),(0,-1,'up')) x(dx,dy,label) LOOP
  -- Le copie possono disporsi entro5m anche se il corpo resta fermo e non ha budget.
  FOR extent IN 1..(CASE WHEN can_move THEN greatest(5,floor(remaining)::integer) ELSE 5 END) LOOP
   figures:=combat_panel_private.multiplication_line_figures(b.x_m,b.y_m,direction.dx,direction.dy,extent,p_copies);
   available:='[]'::jsonb;valid:=true;
   FOR figure IN SELECT value FROM jsonb_array_elements(figures) LOOP
    x:=(figure->>'x_m')::numeric;y:=(figure->>'y_m')::numeric;d:=combat_spatial.distance_m(b.x_m,b.y_m,x,y);
    IF x NOT BETWEEN b.footprint_radius_m AND template.width_m-b.footprint_radius_m
      OR y NOT BETWEEN b.footprint_radius_m AND template.height_m-b.footprint_radius_m
      OR (d>0 AND combat_spatial.path_first_block_t(i.instance_id,a.id,b.x_m,b.y_m,x,y)<1) THEN valid:=false;EXIT; END IF;
    -- Ratifica08/09: a0m soltanto la figura coincidente con il corpo attuale.
    IF d>0 AND (NOT can_move OR d>remaining) THEN CONTINUE; END IF;
    IF p_mode='assalto' AND (mod(d,5)<>0
      OR combat_spatial.distance_m(x,y,target_x,target_y)>2
      OR (x-b.x_m)*(target_x-b.x_m)+(y-b.y_m)*(target_y-b.y_m)<0
      OR (target_x-x)*(target_x-b.x_m)+(target_y-y)*(target_y-b.y_m)<0
      OR combat_spatial.path_first_block_t(i.instance_id,a.id,x,y,target_x,target_y,p_target)<1) THEN CONTINUE; END IF;
    key:=prefix||md5(jsonb_build_object('x',x,'y',y)::text);
    available:=available||jsonb_build_array(jsonb_build_object('figure_index',figure->'figure_index','choice_key',key,'distance_m',d,'x_m',x,'y_m',y));
   END LOOP;
   IF valid AND jsonb_array_length(available)>0 THEN
    layouts:=layouts||jsonb_build_array(jsonb_build_object('direction',direction.label,'extent_m',extent,'figures',figures,'original_options',available));
    FOR option_row IN SELECT value FROM jsonb_array_elements(available) LOOP
     IF (option_row->>'distance_m')::numeric=0 THEN CONTINUE; END IF;
     INSERT INTO combat_spatial.movement_semantic_choices(instance_id,actor_id,choice_key,endpoint_x_m,endpoint_y_m,max_budget_m,choice_version,enabled)
      VALUES(i.instance_id,a.id,option_row->>'choice_key',(option_row->>'x_m')::numeric,(option_row->>'y_m')::numeric,remaining,1,true)
      ON CONFLICT(instance_id,actor_id,choice_key) DO NOTHING;
    END LOOP;
   END IF;
  END LOOP;
 END LOOP;
 IF jsonb_array_length(layouts)=0 THEN RETURN layouts; END IF;
 -- Una sola chiamata nativa per questa combinazione, non una per figura.
 native:='[]'::jsonb;
 IF can_move AND EXISTS(SELECT 1 FROM jsonb_array_elements(layouts) l
   CROSS JOIN LATERAL jsonb_array_elements(l->'original_options') o WHERE (o->>'distance_m')::numeric>0) THEN
   native:=combat_spatial.movement_options(i.instance_id,a.id,remaining); END IF;
 FOR layout IN SELECT value FROM jsonb_array_elements(layouts) LOOP
  available:='[]'::jsonb;
  FOR option_row IN SELECT value FROM jsonb_array_elements(layout->'original_options') LOOP
   IF (option_row->>'distance_m')::numeric=0 THEN
     IF ((option_row->>'x_m')::numeric,(option_row->>'y_m')::numeric) IS DISTINCT FROM (b.x_m,b.y_m) THEN
       RAISE EXCEPTION 'panel_multiplication_stationary_original_invalid' USING ERRCODE='22023'; END IF;
     available:=available||jsonb_build_array(jsonb_build_object('figure_index',option_row->'figure_index',
       'distance_m',0,'movement_capability_id',NULL));
     CONTINUE;
   END IF;
   cid:=NULL;
   SELECT c.capability_id INTO cid FROM combat_spatial.movement_capabilities c
    WHERE c.instance_id=i.instance_id AND c.actor_id=a.id AND c.choice_key=option_row->>'choice_key'
     AND c.actor_body_version=b.body_version AND c.map_version=i.map_version AND c.state='offered'
     AND c.end_x_m=(option_row->>'x_m')::numeric AND c.end_y_m=(option_row->>'y_m')::numeric
     AND EXISTS(SELECT 1 FROM jsonb_array_elements(native) WHERE value->>'option_id'=c.capability_id::text);
   IF cid IS NOT NULL THEN available:=available||jsonb_build_array(jsonb_build_object('figure_index',option_row->'figure_index',
      'distance_m',option_row->'distance_m','movement_capability_id',cid)); END IF;
  END LOOP;
  IF jsonb_array_length(available)>0 THEN bound:=bound||jsonb_build_array(jsonb_set(layout,'{original_options}',available)); END IF;
 END LOOP;
 RETURN bound;
END $function$;
CREATE OR REPLACE FUNCTION combat_panel_private.multiplication_offers(p_context uuid, p_expected bigint, p_view jsonb)
 RETURNS void
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO ''
AS $function$
DECLARE c combat_panel_private.contexts%ROWTYPE; a public.combat_v2_actors%ROWTYPE; profile jsonb;
 quantity jsonb; layouts jsonb; target_layouts jsonb; assault jsonb; variants jsonb:='[]'::jsonb; target record; variant jsonb; target_item jsonb;
 oid uuid; copies_group uuid; copies_option uuid; mode_group uuid; mode_option uuid; target_group uuid; target_option uuid;
 draw_layouts jsonb; label text; mode text; target_geometry jsonb; target_figure jsonb; figure_variants jsonb; figure_variant jsonb; figure_group uuid; figure_option uuid;
BEGIN
 c:=combat_panel_private.owned_context(p_context,p_expected);
 IF c.command_actor_id IS NULL OR c.round_id IS NULL OR p_view#>>'{context,phase}' IS DISTINCT FROM 'action'
   OR c.activity_kind NOT IN ('ordinary_v2','master_v2') THEN RETURN; END IF;
 -- Revoca soltanto la cache privata precedente che esponeva le modalita in pausa.
 UPDATE combat_panel_private.offers old_offer SET state='revoked'
 WHERE old_offer.context_id=c.id AND old_offer.context_version=c.context_version
   AND old_offer.state='offered' AND old_offer.source_payload->>'dispatch'='multiplication'
   AND EXISTS(SELECT 1 FROM combat_panel_private.choice_options old_choice
     WHERE old_choice.offer_id=old_offer.id AND old_choice.source_payload->>'multiplication_mode' IN ('copertura','diversivo'));
 IF EXISTS(SELECT 1 FROM combat_panel_private.offers WHERE context_id=c.id AND context_version=c.context_version
   AND state='offered' AND source_payload->>'dispatch'='multiplication') THEN RETURN; END IF;
 SELECT * INTO STRICT a FROM public.combat_v2_actors WHERE id=c.command_actor_id AND session_id=c.activity_id
   AND exam_regia_private.actor_principal(id,controller_user)=exam_regia_private.current_principal() AND state='attivo' AND companion_id IS NULL;
 profile:=combat_panel_private.multiplication_actor_profile(a.id);
 IF profile IS NULL OR NOT coalesce((profile->>'available')::boolean,false)
   OR profile->>'round_id' IS DISTINCT FROM c.round_id::text THEN RETURN; END IF;
 FOR quantity IN SELECT value FROM jsonb_array_elements(profile->'copy_options') LOOP
   layouts:='[]'::jsonb; -- Copertura e Diversivo in pausa: nessuna capability generata.
   assault:='[]'::jsonb;
   FOR target IN SELECT other.id,roster.value->>'display_name' AS label
     FROM public.combat_v2_actors other
     JOIN LATERAL jsonb_array_elements(p_view->'actors') roster(value) ON roster.value->>'actor_id'=other.id::text
     WHERE other.session_id=a.session_id AND other.state='attivo' AND other.team_key<>a.team_key
     ORDER BY other.id LOOP
     IF EXISTS(SELECT 1 FROM combat_panel_private.multiplication_formations WHERE actor_id=target.id AND state='active') THEN
       IF NOT EXISTS(SELECT 1 FROM combat_panel_private.multiplication_formations f
         WHERE f.actor_id=target.id AND f.state='active' AND f.mode IN ('copertura','diversivo','assalto')) THEN CONTINUE; END IF;
       target_geometry:=combat_panel_private.multiplication_target_geometry(a.id,target.id);
       IF target_geometry IS NULL THEN CONTINUE; END IF;
       figure_variants:='[]'::jsonb;
       FOR target_figure IN SELECT value FROM jsonb_array_elements(target_geometry->'figures') ORDER BY (value->>'figure_index')::integer LOOP
         target_layouts:=combat_panel_private.multiplication_layout_options_for_figure(a.id,(quantity->>'copies')::integer,'assalto',target.id,
           (target_geometry->>'formation_id')::uuid,(target_geometry->>'state_version')::bigint,(target_figure->>'figure_index')::integer);
         IF jsonb_array_length(target_layouts)>0 THEN
           figure_variants:=figure_variants||jsonb_build_array(jsonb_build_object('layouts',target_layouts,
             'selection',jsonb_build_object('target_actor_id',target.id,'formation_id',target_geometry->'formation_id',
               'state_version',target_geometry->'state_version','figure_index',target_figure->'figure_index')));
         END IF;
       END LOOP;
       IF jsonb_array_length(figure_variants)>0 THEN
         assault:=assault||jsonb_build_array(jsonb_build_object('target_actor_id',target.id,'label',target.label,'figure_variants',figure_variants)); END IF;
     ELSE
       target_layouts:=combat_panel_private.multiplication_layout_options(a.id,(quantity->>'copies')::integer,'assalto',target.id);
       IF jsonb_array_length(target_layouts)>0 THEN
         assault:=assault||jsonb_build_array(jsonb_build_object('target_actor_id',target.id,'label',target.label,'layouts',target_layouts)); END IF;
     END IF;
   END LOOP;
   IF jsonb_array_length(layouts)>0 OR jsonb_array_length(assault)>0 THEN
     variants:=variants||jsonb_build_array(quantity||jsonb_build_object('layouts',layouts,'assault',assault));
   END IF;
 END LOOP;
 IF jsonb_array_length(variants)=0 THEN RETURN; END IF;
 INSERT INTO combat_panel_private.offers(context_id,principal_user,actor_id,context_version,scene_version,source_fingerprint,
   kind,operation,label,requires_role,source_payload)
 VALUES(c.id,exam_regia_private.current_principal(),a.id,c.context_version,c.scene_version,c.source_fingerprint,'action','declare','Moltiplicazione del corpo',true,
   jsonb_build_object('adapter',c.activity_kind,'dispatch','multiplication','assault_only_release','assault-only/1')) RETURNING id INTO oid;
 copies_group:=combat_panel_private.add_group(oid,'Copie e costo totale','copies','single',1,1);
 FOR variant IN SELECT value FROM jsonb_array_elements(variants) LOOP
   copies_option:=combat_panel_private.add_choice(copies_group,(variant->>'copies')||CASE WHEN (variant->>'copies')::integer=1 THEN ' copia · ' ELSE ' copie · ' END||(variant->>'chakra_cost')||' chakra',
     jsonb_build_object('multiplication_copies',variant->'copies'));
   mode_group:=combat_panel_private.add_group(oid,'Modalità','mode','single',1,1,copies_option);
   IF jsonb_array_length(variant->'assault')>0 THEN
     mode_option:=combat_panel_private.add_choice(mode_group,'Assalto',jsonb_build_object('multiplication_mode','assalto'));
     target_group:=combat_panel_private.add_group(oid,'Bersaglio','target','single',1,1,mode_option);
     FOR target_item IN SELECT value FROM jsonb_array_elements(variant->'assault') LOOP
       target_option:=combat_panel_private.add_choice(target_group,target_item->>'label',jsonb_build_object('target_actor_id',target_item->'target_actor_id'));
       IF jsonb_typeof(target_item->'figure_variants')='array' THEN
         figure_group:=combat_panel_private.add_group(oid,'Figura di '||(target_item->>'label'),'generic','single',1,1,target_option);
         draw_layouts:=combat_panel_private.multiplication_assault_draw_layouts(target_item->'figure_variants');
         IF jsonb_array_length(draw_layouts)>0 THEN
          figure_option:=combat_panel_private.add_choice(figure_group,'Estrazione del server','{}'::jsonb);
          PERFORM combat_panel_private.multiplication_add_layout_groups(oid,figure_option,draw_layouts);
         END IF;
         FOR figure_variant IN SELECT value FROM jsonb_array_elements(target_item->'figure_variants') LOOP
           figure_option:=combat_panel_private.add_choice(figure_group,'Figura '||(figure_variant#>>'{selection,figure_index}'),
             jsonb_build_object('multiplication_attack_target',figure_variant->'selection'));
           PERFORM combat_panel_private.multiplication_add_layout_groups(oid,figure_option,figure_variant->'layouts');
         END LOOP;
       ELSE PERFORM combat_panel_private.multiplication_add_layout_groups(oid,target_option,target_item->'layouts'); END IF;
     END LOOP;
   END IF;
 END LOOP;
END $function$;
CREATE OR REPLACE FUNCTION combat_panel_private.multiplication_prepare_assault_draw(p_round uuid, p_actor uuid, p_target uuid, p_formation uuid, p_version bigint, p_indices jsonb, p_copies integer, p_figures jsonb, p_original integer, p_request uuid)
 RETURNS void
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO ''
AS $function$
DECLARE geometry jsonb;profile jsonb;original jsonb;figure jsonb;
 body combat_spatial.actor_states%ROWTYPE;instance combat_spatial.arena_instances%ROWTYPE;
 old combat_panel_private.multiplication_attack_aims%ROWTYPE;
 endpoint_x numeric;endpoint_y numeric;target_x numeric;target_y numeric;distance numeric;
 eligible integer[]:=ARRAY[]::integer[];seed bytea;idx integer;
BEGIN
 IF exam_regia_private.current_principal() IS NULL OR p_request IS NULL THEN
  RAISE EXCEPTION 'panel_authentication_required' USING ERRCODE='28000'; END IF;
 IF jsonb_typeof(p_indices) IS DISTINCT FROM 'array' THEN
  RAISE EXCEPTION 'panel_multiplication_draw_invalid' USING ERRCODE='22023'; END IF;
 PERFORM public.combat_v2_lock_round(p_round);
 profile:=combat_panel_private.multiplication_actor_profile(p_actor);
 IF profile IS NULL OR NOT coalesce((profile->>'available')::boolean,false)
  OR profile->>'round_id' IS DISTINCT FROM p_round::text
  OR NOT combat_panel_private.multiplication_formation_valid(p_figures,p_copies,(profile->>'copy_cap')::integer,p_original) THEN
  RAISE EXCEPTION 'panel_multiplication_formation_invalid' USING ERRCODE='22023'; END IF;
 geometry:=combat_panel_private.multiplication_target_geometry(p_actor,p_target);
 IF geometry IS NULL OR geometry->>'formation_id' IS DISTINCT FROM p_formation::text
  OR geometry->>'state_version' IS DISTINCT FROM p_version::text THEN
  RAISE EXCEPTION 'panel_multiplication_draw_stale' USING ERRCODE='40001'; END IF;
 SELECT * INTO STRICT instance FROM combat_spatial.arena_instances
  WHERE instance_id=(geometry->>'instance_id')::uuid AND state='open' FOR UPDATE;
 SELECT * INTO STRICT body FROM combat_spatial.actor_states WHERE instance_id=instance.instance_id
  AND actor_id=p_actor AND state='active' AND controller_principal_id=exam_regia_private.current_principal();
 SELECT value INTO STRICT original FROM jsonb_array_elements(p_figures) WHERE (value->>'figure_index')::integer=p_original;
 endpoint_x:=(original->>'x_m')::numeric;endpoint_y:=(original->>'y_m')::numeric;
 distance:=combat_spatial.distance_m(body.x_m,body.y_m,endpoint_x,endpoint_y);
 IF mod(distance,5)<>0 THEN RAISE EXCEPTION 'panel_multiplication_assault_contact_invalid' USING ERRCODE='22023'; END IF;
 FOR figure IN SELECT value FROM jsonb_array_elements(geometry->'figures') ORDER BY (value->>'figure_index')::integer LOOP
  target_x:=(figure->>'x_m')::numeric;target_y:=(figure->>'y_m')::numeric;
  IF combat_spatial.distance_m(endpoint_x,endpoint_y,target_x,target_y)<=2
   AND (endpoint_x-body.x_m)*(target_x-body.x_m)+(endpoint_y-body.y_m)*(target_y-body.y_m)>=0
   AND (target_x-endpoint_x)*(target_x-body.x_m)+(target_y-endpoint_y)*(target_y-body.y_m)>=0
   AND combat_spatial.path_first_block_t(instance.instance_id,p_actor,endpoint_x,endpoint_y,target_x,target_y,p_target)>=1 THEN
   eligible:=array_append(eligible,(figure->>'figure_index')::integer);
  END IF;
 END LOOP;
 IF cardinality(eligible)=0 OR p_indices IS DISTINCT FROM to_jsonb(eligible) THEN
  RAISE EXCEPTION 'panel_multiplication_draw_stale' USING ERRCODE='40001'; END IF;
 SELECT * INTO old FROM combat_panel_private.multiplication_attack_aims
  WHERE request_key=p_request AND target_actor_id=p_target FOR UPDATE;
 IF old.request_key IS NOT NULL THEN
  IF old.random_seed IS NULL OR old.random_indices IS DISTINCT FROM eligible OR old.random_range_m IS DISTINCT FROM 2::numeric THEN
   RAISE EXCEPTION 'panel_request_key_conflict' USING ERRCODE='22023'; END IF;
  seed:=old.random_seed;
 ELSE seed:=extensions.gen_random_bytes(32); END IF;
 idx:=eligible[combat_panel_private.multiplication_random_figure(cardinality(eligible),seed)];
 PERFORM combat_panel_private.multiplication_prepare_attack_aim_for_source(
  p_round,p_actor,p_target,p_formation,p_version,idx,p_request,false);
 IF old.request_key IS NULL THEN
  UPDATE combat_panel_private.multiplication_attack_aims SET random_seed=seed,random_indices=eligible,random_range_m=2
   WHERE request_key=p_request AND target_actor_id=p_target AND prepared_transaction=txid_current()
    AND principal_user=exam_regia_private.current_principal() AND attack_target_id IS NULL;
  IF NOT FOUND THEN RAISE EXCEPTION 'panel_multiplication_draw_binding_invalid' USING ERRCODE='40001'; END IF;
 END IF;
END $function$;
CREATE OR REPLACE FUNCTION combat_panel_private.multiplication_prepare_attack_aim_for_source(p_round uuid, p_actor uuid, p_target uuid, p_formation uuid, p_version bigint, p_index integer, p_request uuid, p_companion boolean)
 RETURNS void
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO ''
AS $function$
DECLARE a public.combat_v2_actors%ROWTYPE; r public.combat_v2_rounds%ROWTYPE;
 f combat_panel_private.multiplication_formations%ROWTYPE;
 old combat_panel_private.multiplication_attack_aims%ROWTYPE; geometry jsonb; fp text;
BEGIN
 IF exam_regia_private.current_principal() IS NULL OR p_request IS NULL THEN RAISE EXCEPTION 'panel_authentication_required' USING ERRCODE='28000'; END IF;
 PERFORM public.combat_v2_lock_round(p_round);
 SELECT * INTO STRICT r FROM public.combat_v2_rounds WHERE id=p_round;
 SELECT * INTO STRICT a FROM public.combat_v2_actors WHERE id=p_actor AND session_id=r.session_id
   AND exam_regia_private.actor_principal(id,controller_user)=exam_regia_private.current_principal() AND state='attivo' AND companion_id IS NULL FOR UPDATE;
 IF r.phase<>'raccolta_azioni' THEN RAISE EXCEPTION 'panel_multiplication_aim_phase_invalid' USING ERRCODE='40001'; END IF;
 SELECT * INTO STRICT f FROM combat_panel_private.multiplication_formations WHERE id=p_formation
   AND actor_id=p_target AND session_id=r.session_id AND state='active' AND state_version=p_version FOR UPDATE;
 -- La formazione bersagliata usa il ruolo target, anche se è un Assalto attivo.
 IF f.mode NOT IN ('diversivo','copertura','assalto') THEN
   RAISE EXCEPTION 'panel_multiplication_aim_mode_invalid' USING ERRCODE='22023'; END IF;
 IF p_companion IS NULL THEN RAISE EXCEPTION 'panel_attack_origin_invalid' USING ERRCODE='22023'; END IF;
 IF p_companion THEN
  geometry:=combat_panel_private.multiplication_companion_target_figure(r.id,a.id,p_target,f.id,f.state_version,p_index);
 ELSE geometry:=combat_panel_private.multiplication_target_figure(a.id,p_target,f.id,f.state_version,p_index); END IF;
 fp:=public.combat_v2_sha256(jsonb_build_object('round',r.id,'actor',a.id,'target',p_target,
   'formation',f.id,'version',f.state_version,'index',p_index,'controller_version',a.controller_version)
 ||CASE WHEN p_companion THEN jsonb_build_object('attack_origin','marionetta','source_actor_id',geometry->'source_actor_id','link_version',geometry->'link_version') ELSE '{}'::jsonb END);
 SELECT * INTO old FROM combat_panel_private.multiplication_attack_aims WHERE request_key=p_request AND target_actor_id=p_target;
 IF old.request_key IS NOT NULL THEN
   IF old.principal_user<>exam_regia_private.current_principal() OR old.fingerprint<>fp THEN
     RAISE EXCEPTION 'panel_request_key_conflict' USING ERRCODE='22023'; END IF;
   IF old.prepared_transaction<>txid_current() OR old.geometry IS DISTINCT FROM geometry THEN
     RAISE EXCEPTION 'panel_multiplication_aim_stale' USING ERRCODE='40001'; END IF;
   RETURN;
 END IF;
 INSERT INTO combat_panel_private.multiplication_attack_aims
   (request_key,target_actor_id,round_id,actor_id,principal_user,prepared_transaction,controller_version,
    formation_id,formation_version,selected_index,geometry,fingerprint)
 VALUES(p_request,p_target,r.id,a.id,exam_regia_private.current_principal(),txid_current(),a.controller_version,f.id,f.state_version,p_index,geometry,fp);
END $function$;
CREATE OR REPLACE FUNCTION combat_panel_private.multiplication_prepare_attack_draw(p_round uuid, p_actor uuid, p_target uuid, p_formation uuid, p_version bigint, p_indices jsonb, p_range numeric, p_request uuid, p_companion boolean)
 RETURNS void
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO ''
AS $function$
DECLARE geometry jsonb;eligible integer[];expected jsonb;seed bytea;idx integer;
 old combat_panel_private.multiplication_attack_aims%ROWTYPE;
BEGIN
 IF exam_regia_private.current_principal() IS NULL OR p_request IS NULL THEN
  RAISE EXCEPTION 'panel_authentication_required' USING ERRCODE='28000'; END IF;
 IF p_companion IS NULL OR p_range IS NULL OR p_range<0
  OR p_range IN ('NaN'::numeric,'Infinity'::numeric,'-Infinity'::numeric)
  OR jsonb_typeof(p_indices) IS DISTINCT FROM 'array' THEN
  RAISE EXCEPTION 'panel_multiplication_draw_invalid' USING ERRCODE='22023'; END IF;
 PERFORM public.combat_v2_lock_round(p_round);
 IF p_companion THEN
  geometry:=combat_panel_private.multiplication_companion_target_geometry(p_round,p_actor,p_target);
 ELSE geometry:=combat_panel_private.multiplication_target_geometry(p_actor,p_target); END IF;
 IF geometry IS NULL OR geometry->>'formation_id' IS DISTINCT FROM p_formation::text
  OR geometry->>'state_version' IS DISTINCT FROM p_version::text THEN
  RAISE EXCEPTION 'panel_multiplication_draw_stale' USING ERRCODE='40001'; END IF;
 SELECT array_agg((value->>'figure_index')::integer ORDER BY (value->>'figure_index')::integer)
  INTO eligible FROM jsonb_array_elements(geometry->'figures')
  WHERE (value->>'distance_m')::numeric<=p_range AND (value->>'path_clear')::boolean;
 expected:=to_jsonb(eligible);
 IF coalesce(cardinality(eligible),0)=0 OR p_indices IS DISTINCT FROM expected THEN
  RAISE EXCEPTION 'panel_multiplication_draw_stale' USING ERRCODE='40001'; END IF;
 SELECT * INTO old FROM combat_panel_private.multiplication_attack_aims
  WHERE request_key=p_request AND target_actor_id=p_target FOR UPDATE;
 IF old.request_key IS NOT NULL THEN
  IF old.random_seed IS NULL OR old.random_indices IS DISTINCT FROM eligible OR old.random_range_m IS DISTINCT FROM p_range THEN
   RAISE EXCEPTION 'panel_request_key_conflict' USING ERRCODE='22023'; END IF;
  seed:=old.random_seed;
 ELSE seed:=extensions.gen_random_bytes(32); END IF;
 idx:=eligible[combat_panel_private.multiplication_random_figure(cardinality(eligible),seed)];
 PERFORM combat_panel_private.multiplication_prepare_attack_aim_for_source(
  p_round,p_actor,p_target,p_formation,p_version,idx,p_request,p_companion);
 IF old.request_key IS NULL THEN
  UPDATE combat_panel_private.multiplication_attack_aims
   SET random_seed=seed,random_indices=eligible,random_range_m=p_range
   WHERE request_key=p_request AND target_actor_id=p_target AND attack_target_id IS NULL
    AND prepared_transaction=txid_current() AND principal_user=exam_regia_private.current_principal();
  IF NOT FOUND THEN RAISE EXCEPTION 'panel_multiplication_draw_binding_invalid' USING ERRCODE='40001'; END IF;
 END IF;
END $function$;
CREATE OR REPLACE FUNCTION combat_panel_private.multiplication_prepare_declaration(p_round uuid, p_actor uuid, p_mode text, p_copies integer, p_figures jsonb, p_original integer, p_target uuid, p_movement uuid, p_request uuid)
 RETURNS void
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO ''
AS $function$
DECLARE a public.combat_v2_actors%ROWTYPE; b combat_spatial.actor_states%ROWTYPE;
 i combat_spatial.arena_instances%ROWTYPE; template combat_spatial.arena_templates%ROWTYPE;
 aim combat_panel_private.multiplication_attack_aims%ROWTYPE; target_geometry jsonb; target_x numeric; target_y numeric;
 cap combat_spatial.movement_capabilities%ROWTYPE; plan combat_panel_private.multiplication_declaration_plans%ROWTYPE;
 profile jsonb; original jsonb; budget jsonb; movement jsonb; origin_x numeric; origin_y numeric;
 endpoint_x numeric; endpoint_y numeric; distance numeric; fp text; cost integer; f jsonb;
BEGIN
 IF exam_regia_private.current_principal() IS NULL OR p_request IS NULL THEN RAISE EXCEPTION 'panel_authentication_required' USING ERRCODE='28000'; END IF;
 IF p_mode IS NULL OR p_mode NOT IN ('diversivo','copertura','assalto')
   OR (p_mode='assalto') IS DISTINCT FROM (p_target IS NOT NULL) THEN
   RAISE EXCEPTION 'panel_multiplication_mode_invalid' USING ERRCODE='22023'; END IF;
 PERFORM public.combat_v2_lock_round(p_round);
 SELECT * INTO aim FROM combat_panel_private.multiplication_attack_aims
   WHERE request_key=p_request AND target_actor_id=p_target FOR UPDATE;
 IF aim.request_key IS NOT NULL AND (p_mode IS DISTINCT FROM 'assalto' OR aim.actor_id<>p_actor OR aim.round_id<>p_round
   OR aim.principal_user IS DISTINCT FROM exam_regia_private.current_principal() OR aim.prepared_transaction<>txid_current()
   OR aim.attack_target_id IS NOT NULL) THEN
   RAISE EXCEPTION 'panel_multiplication_assault_aim_invalid' USING ERRCODE='40001'; END IF;
 fp:=public.combat_v2_sha256(jsonb_build_object('round',p_round,'actor',p_actor,'mode',p_mode,
   'copies',p_copies,'figures',p_figures,'original',p_original,'target',p_target,'movement',p_movement)
     ||CASE WHEN aim.request_key IS NULL THEN '{}'::jsonb ELSE jsonb_build_object('target_formation',aim.formation_id,
       'target_formation_version',aim.formation_version,'target_figure',aim.selected_index) END);
 SELECT * INTO plan FROM combat_panel_private.multiplication_declaration_plans WHERE request_key=p_request;
 IF plan.request_key IS NOT NULL THEN
   IF plan.principal_user<>exam_regia_private.current_principal() OR plan.fingerprint<>fp THEN
     RAISE EXCEPTION 'panel_request_key_conflict' USING ERRCODE='22023'; END IF;
   IF plan.declaration_id IS NULL AND plan.prepared_transaction<>txid_current() THEN
     RAISE EXCEPTION 'panel_multiplication_plan_abandoned' USING ERRCODE='40001'; END IF;
   RETURN;
 END IF;
 SELECT * INTO STRICT a FROM public.combat_v2_actors WHERE id=p_actor AND exam_regia_private.actor_principal(id,controller_user)=exam_regia_private.current_principal()
   AND companion_id IS NULL AND state='attivo' FOR UPDATE;
 profile:=combat_panel_private.multiplication_actor_profile(a.id);
 IF profile IS NULL OR profile->>'round_id' IS DISTINCT FROM p_round::text
   OR NOT coalesce((profile->>'available')::boolean,false) THEN
   RAISE EXCEPTION 'panel_multiplication_not_available' USING ERRCODE='40001'; END IF;
 SELECT (value->>'chakra_cost')::integer INTO cost FROM jsonb_array_elements(profile->'copy_options')
   WHERE (value->>'copies')::integer=p_copies;
 IF cost IS NULL OR NOT combat_panel_private.multiplication_formation_valid(p_figures,p_copies,(profile->>'copy_cap')::integer,p_original) THEN
   RAISE EXCEPTION 'panel_multiplication_formation_invalid' USING ERRCODE='22023'; END IF;
 SELECT * INTO STRICT i FROM combat_spatial.arena_instances WHERE encounter_id=a.session_id AND state='open' FOR UPDATE;
 IF NOT combat_panel_private.shared_movement_scope(i.instance_id) THEN
   RAISE EXCEPTION 'panel_multiplication_scene_invalid' USING ERRCODE='42501'; END IF;
 SELECT * INTO STRICT template FROM combat_spatial.arena_templates WHERE template_key=i.template_key AND template_version=i.template_version;
 SELECT * INTO STRICT b FROM combat_spatial.actor_states WHERE instance_id=i.instance_id AND actor_id=a.id AND state='active' FOR UPDATE;
 IF b.controller_principal_id IS DISTINCT FROM exam_regia_private.current_principal() THEN
   RAISE EXCEPTION 'panel_multiplication_controller_stale' USING ERRCODE='40001'; END IF;
 FOR f IN SELECT value FROM jsonb_array_elements(p_figures) LOOP
   IF (f->>'x_m')::numeric NOT BETWEEN b.footprint_radius_m AND template.width_m-b.footprint_radius_m
     OR (f->>'y_m')::numeric NOT BETWEEN b.footprint_radius_m AND template.height_m-b.footprint_radius_m THEN
     RAISE EXCEPTION 'panel_multiplication_figure_outside_arena' USING ERRCODE='22023'; END IF;
 END LOOP;
 SELECT value INTO STRICT original FROM jsonb_array_elements(p_figures) WHERE (value->>'figure_index')::integer=p_original;
 origin_x:=b.x_m; origin_y:=b.y_m; endpoint_x:=(original->>'x_m')::numeric; endpoint_y:=(original->>'y_m')::numeric;
 distance:=combat_spatial.distance_m(origin_x,origin_y,endpoint_x,endpoint_y);
 budget:=combat_panel_private.movement_budget(a.id,p_round);
 IF distance>0 THEN
   IF p_movement IS NULL OR (budget->>'spent_m')::numeric>0 OR distance>(budget->>'remaining_m')::numeric
     OR combat_panel_private.movement_block_reason(a.id) IS NOT NULL THEN
     RAISE EXCEPTION 'panel_multiplication_single_movement_required' USING ERRCODE='22023'; END IF;
   SELECT * INTO STRICT cap FROM combat_spatial.movement_capabilities WHERE capability_id=p_movement FOR UPDATE;
   IF cap.instance_id<>i.instance_id OR cap.actor_id<>a.id OR cap.state<>'offered'
     OR cap.actor_body_version<>b.body_version OR cap.map_version<>i.map_version
     OR (cap.start_x_m,cap.start_y_m,cap.end_x_m,cap.end_y_m) IS DISTINCT FROM (origin_x,origin_y,endpoint_x,endpoint_y)
     OR combat_spatial.path_first_block_t(i.instance_id,a.id,origin_x,origin_y,endpoint_x,endpoint_y)<1 THEN
     RAISE EXCEPTION 'panel_multiplication_movement_stale' USING ERRCODE='40001'; END IF;
 ELSIF p_movement IS NOT NULL THEN
   RAISE EXCEPTION 'panel_multiplication_zero_movement_capability' USING ERRCODE='22023'; END IF;
 IF p_mode='assalto' THEN
   PERFORM 1 FROM public.combat_v2_actors WHERE id=p_target AND session_id=a.session_id
     AND state='attivo' AND team_key<>a.team_key FOR KEY SHARE;
   IF NOT FOUND THEN RAISE EXCEPTION 'panel_multiplication_target_invalid' USING ERRCODE='22023'; END IF;
   IF aim.request_key IS NOT NULL THEN
     target_geometry:=combat_panel_private.multiplication_target_figure(a.id,p_target,aim.formation_id,aim.formation_version,aim.selected_index);
     IF target_geometry IS DISTINCT FROM aim.geometry THEN RAISE EXCEPTION 'panel_multiplication_aim_stale' USING ERRCODE='40001'; END IF;
     target_x:=(target_geometry#>>'{figure,x_m}')::numeric;target_y:=(target_geometry#>>'{figure,y_m}')::numeric;
   ELSE
     IF EXISTS(SELECT 1 FROM combat_panel_private.multiplication_formations WHERE actor_id=p_target AND state='active') THEN
       RAISE EXCEPTION 'panel_multiplication_target_choice_required' USING ERRCODE='22023'; END IF;
     SELECT tb.x_m,tb.y_m INTO STRICT target_x,target_y FROM combat_spatial.actor_states tb
       WHERE tb.instance_id=i.instance_id AND tb.actor_id=p_target AND tb.state='active';
   END IF;
   IF combat_panel_private.body_visible_to_viewer(i.instance_id,p_target) IS DISTINCT FROM true
     OR combat_spatial.distance_m(endpoint_x,endpoint_y,target_x,target_y)>2
     OR (endpoint_x-origin_x)*(target_x-origin_x)+(endpoint_y-origin_y)*(target_y-origin_y)<0
     OR (target_x-endpoint_x)*(target_x-origin_x)+(target_y-endpoint_y)*(target_y-origin_y)<0
     OR combat_spatial.path_first_block_t(i.instance_id,a.id,endpoint_x,endpoint_y,target_x,target_y,p_target)<1 THEN
     RAISE EXCEPTION 'panel_multiplication_assault_contact_invalid' USING ERRCODE='22023'; END IF;
 END IF;
 IF distance>0 THEN
   movement:=combat_spatial.movement_commit(cap.capability_id,
     md5(p_request::text||':multiplication-movement')::uuid,p_request);
   IF combat_panel_private.movement_event_cost((movement->>'event_id')::uuid,distance)>(budget->>'remaining_m')::numeric THEN
     RAISE EXCEPTION 'panel_multiplication_movement_budget_exceeded' USING ERRCODE='40001'; END IF;
   IF clan_sabaku_private.clone_movement_interruption(cap.capability_id) IS NOT NULL THEN
     PERFORM clan_sabaku_private.clone_record_interrupted_movement(cap.capability_id,p_round,a.id);
     RETURN;
   END IF;
   SELECT * INTO STRICT b FROM combat_spatial.actor_states WHERE instance_id=i.instance_id AND actor_id=a.id;
   IF (b.x_m,b.y_m) IS DISTINCT FROM (endpoint_x,endpoint_y) THEN
     RAISE EXCEPTION 'panel_multiplication_original_not_reached' USING ERRCODE='40001'; END IF;
 END IF;
 IF aim.request_key IS NOT NULL THEN
   -- Solo la geometria cambia dopo il movimento autorizzato della stessa TX.
   -- Figura, formazione, versione e controllore restano quelli sigillati.
   target_geometry:=combat_panel_private.multiplication_target_figure(a.id,p_target,aim.formation_id,aim.formation_version,aim.selected_index);
   UPDATE combat_panel_private.multiplication_attack_aims SET geometry=target_geometry
     WHERE request_key=p_request AND target_actor_id=p_target AND actor_id=a.id
       AND prepared_transaction=txid_current() AND attack_target_id IS NULL;
   IF NOT FOUND THEN RAISE EXCEPTION 'panel_multiplication_assault_aim_invalid' USING ERRCODE='40001'; END IF;
 END IF;
 INSERT INTO combat_panel_private.multiplication_declaration_plans(request_key,principal_user,prepared_transaction,
   round_id,actor_id,instance_id,controller_version,source_body_version,mode,copies,copy_cap,chakra_cost,figures,
   original_index,target_actor_id,movement_event_id,movement_m,fingerprint)
 VALUES(p_request,exam_regia_private.current_principal(),txid_current(),p_round,a.id,i.instance_id,a.controller_version,b.body_version,
   p_mode,p_copies,(profile->>'copy_cap')::integer,cost,p_figures,p_original,p_target,(movement->>'event_id')::uuid,distance,fp);
END $function$;
CREATE OR REPLACE FUNCTION combat_panel_private.multiplication_register_choice(p_formation uuid, p_target uuid, p_chooser uuid, p_index integer, p_request uuid)
 RETURNS uuid
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO ''
AS $function$
DECLARE f combat_panel_private.multiplication_formations%ROWTYPE; a public.combat_v2_actors%ROWTYPE;
 old combat_panel_private.multiplication_choices%ROWTYPE; rid uuid; fp text; result uuid;
BEGIN
 IF exam_regia_private.current_principal() IS NULL OR p_request IS NULL THEN RAISE EXCEPTION 'panel_authentication_required' USING ERRCODE='28000'; END IF;
 SELECT round_id INTO STRICT rid FROM public.combat_v2_attack_targets WHERE id=p_target;
 PERFORM public.combat_v2_lock_round(rid);
 SELECT * INTO STRICT f FROM combat_panel_private.multiplication_formations WHERE id=p_formation FOR UPDATE;
 SELECT * INTO STRICT a FROM public.combat_v2_actors WHERE id=p_chooser AND session_id=f.session_id AND exam_regia_private.actor_principal(id,controller_user)=exam_regia_private.current_principal();
 IF combat_panel_private.multiplication_chooser(f.id,p_target) IS DISTINCT FROM a.id THEN
   RAISE EXCEPTION 'panel_multiplication_choice_not_owned' USING ERRCODE='42501'; END IF;
 IF p_index IS NOT NULL AND NOT EXISTS(SELECT 1 FROM jsonb_array_elements(f.figures) x WHERE (x->>'figure_index')::integer=p_index) THEN
   RAISE EXCEPTION 'panel_multiplication_figure_not_offered' USING ERRCODE='22023'; END IF;
 fp:=public.combat_v2_sha256(jsonb_build_object('formation',f.id,'target',p_target,'chooser',a.id,
   'controller_version',a.controller_version,'figure',p_index));
 SELECT * INTO old FROM combat_panel_private.multiplication_choices WHERE formation_id=f.id AND attack_target_id=p_target;
 IF old.id IS NOT NULL THEN
   IF old.request_key<>p_request OR old.fingerprint<>fp THEN RAISE EXCEPTION 'panel_request_key_conflict' USING ERRCODE='22023'; END IF;
   RETURN old.id;
 END IF;
 IF f.state<>'active' OR EXISTS(SELECT 1 FROM public.combat_v2_rounds WHERE id=rid AND state IN ('risoluzione','risolto','narrazione','narrato'))
   OR EXISTS(SELECT 1 FROM combat_panel_private.multiplication_resolutions WHERE formation_id=f.id AND attack_target_id=p_target) THEN
   RAISE EXCEPTION 'panel_multiplication_choice_closed' USING ERRCODE='40001'; END IF;
 INSERT INTO combat_panel_private.multiplication_choices(formation_id,attack_target_id,chooser_actor_id,controller_version,selected_index,request_key,fingerprint)
   VALUES(f.id,p_target,a.id,a.controller_version,p_index,p_request,fp) RETURNING id INTO result;
 -- Solo conferma opaca: nessun esito o hash del segreto prima del resolver.
 RETURN result;
END $function$;
CREATE OR REPLACE FUNCTION combat_panel_private.multiplication_register_defense_selections(p_round uuid, p_defender uuid, p_request uuid, p_resolved jsonb, p_defense uuid DEFAULT NULL::uuid, p_parent_attack uuid DEFAULT NULL::uuid)
 RETURNS void
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO ''
AS $function$
DECLARE payload jsonb; selection jsonb; target public.combat_v2_attack_targets%ROWTYPE;
 f combat_panel_private.multiplication_formations%ROWTYPE; choice_key uuid; item_key text; seen text[]:=ARRAY[]::text[];
BEGIN
 IF exam_regia_private.current_principal() IS NULL OR p_request IS NULL THEN RAISE EXCEPTION 'panel_authentication_required' USING ERRCODE='28000'; END IF;
 PERFORM public.combat_v2_lock_round(p_round);
 FOR payload IN SELECT choice->'payload' FROM jsonb_array_elements(p_resolved->'groups') AS groups(g)
   CROSS JOIN LATERAL jsonb_array_elements(g->'options') AS choices(choice) LOOP
   IF NOT payload ? 'multiplication_defense_choice' THEN CONTINUE; END IF;
   selection:=payload->'multiplication_defense_choice';
   SELECT * INTO STRICT target FROM public.combat_v2_attack_targets WHERE id=(selection->>'attack_target_id')::uuid AND round_id=p_round;
   SELECT * INTO STRICT f FROM combat_panel_private.multiplication_formations WHERE id=(selection->>'formation_id')::uuid
     AND declaration_id=target.attack_declaration_id AND mode='assalto' AND state='active'
     AND state_version=(selection->>'state_version')::bigint FOR UPDATE;
   item_key:=f.id||':'||target.id;
   IF item_key=ANY(seen) THEN RAISE EXCEPTION 'panel_multiplication_defense_choice_conflict' USING ERRCODE='22023'; END IF;
   seen:=array_append(seen,item_key);
   IF p_defense IS NOT NULL THEN
     IF NOT EXISTS(SELECT 1 FROM public.combat_v2_defense_coverages coverage
       JOIN public.combat_v2_declarations d ON d.id=coverage.defense_declaration_id
       WHERE d.id=p_defense AND d.round_id=p_round AND d.actor_id=p_defender
         AND d.controller_user_snapshot=exam_regia_private.current_principal() AND d.kind IN ('difesa','nessuna')
         AND coverage.attack_target_id=target.id) THEN
       RAISE EXCEPTION 'panel_multiplication_defense_scope_invalid' USING ERRCODE='42501'; END IF;
   ELSE
     -- Ordinary dichiara e risolve nella stessa porta. Prima della chiamata
     -- è ammessa soltanto la scelta del bersaglio che difende se stesso.
     IF target.target_actor_id<>p_defender OR target.attack_declaration_id IS DISTINCT FROM p_parent_attack
       OR NOT EXISTS(SELECT 1 FROM combat_consumer_private.activities c
         JOIN combat_consumer_private.members m ON m.session_id=c.session_id
         JOIN public.characters ch ON ch.id=m.character_id AND ch.user_id=exam_regia_private.current_principal()
         WHERE c.exchange_id=p_round AND c.phase='defense' AND c.turn_actor_id<>p_defender
           AND m.actor_id=p_defender) THEN
       RAISE EXCEPTION 'panel_multiplication_defense_scope_invalid' USING ERRCODE='42501'; END IF;
   END IF;
   choice_key:=md5('multiplication-defense:'||p_request||':'||f.id||':'||target.id)::uuid;
   PERFORM combat_panel_private.multiplication_register_choice(f.id,target.id,p_defender,
     (selection->>'figure_index')::integer,choice_key);
 END LOOP;
END $function$;
CREATE OR REPLACE FUNCTION combat_panel_private.multiplication_target_geometry_for_body(p_actor uuid, p_target uuid, p_source uuid)
 RETURNS jsonb
 LANGUAGE plpgsql
 STABLE SECURITY DEFINER
 SET search_path TO ''
AS $function$
DECLARE a public.combat_v2_actors%ROWTYPE; t public.combat_v2_actors%ROWTYPE;
 i combat_spatial.arena_instances%ROWTYPE; b combat_spatial.actor_states%ROWTYPE;
 formation record; figure jsonb; points jsonb:='[]'::jsonb; x numeric; y numeric; owner_body_version bigint;
BEGIN
 IF exam_regia_private.current_principal() IS NULL THEN RAISE EXCEPTION 'panel_authentication_required' USING ERRCODE='28000'; END IF;
 SELECT * INTO STRICT a FROM public.combat_v2_actors WHERE id=p_actor
   AND exam_regia_private.actor_principal(id,controller_user)=exam_regia_private.current_principal() AND state='attivo';
 SELECT * INTO t FROM public.combat_v2_actors WHERE id=p_target AND session_id=a.session_id
   AND state='attivo' AND team_key<>a.team_key;
 IF t.id IS NULL THEN RETURN NULL; END IF;
 SELECT arena.* INTO i FROM combat_spatial.arena_instances arena
   JOIN public.combat_v2_sessions s ON s.id=arena.encounter_id
   WHERE arena.encounter_id=a.session_id AND arena.state='open'
     AND s.closed_at IS NULL AND s.state NOT IN ('chiuso','annullato');
 IF i.instance_id IS NULL OR NOT combat_panel_private.shared_movement_scope(i.instance_id)
   OR NOT combat_panel_private.body_visible_to_viewer(i.instance_id,t.id) THEN RETURN NULL; END IF;
 SELECT * INTO b FROM combat_spatial.actor_states WHERE instance_id=i.instance_id AND actor_id=p_source
   AND state='active' AND controller_principal_id=exam_regia_private.current_principal();
 IF b.actor_id IS NULL THEN RETURN NULL; END IF;
 SELECT body_version INTO owner_body_version FROM combat_spatial.actor_states
   WHERE instance_id=i.instance_id AND actor_id=a.id AND state='active' AND controller_principal_id=exam_regia_private.current_principal();
 IF owner_body_version IS NULL THEN RETURN NULL; END IF;
 -- Non si legge l'indice originale, né si usa la posizione del corpo nemico.
 SELECT f.id,f.state_version,f.figures INTO formation
 FROM combat_panel_private.multiplication_formations f
 WHERE f.actor_id=t.id AND f.session_id=a.session_id AND f.instance_id=i.instance_id AND f.state='active'
   AND EXISTS(SELECT 1 FROM combat_spatial.actor_states tb WHERE tb.instance_id=i.instance_id
     AND tb.actor_id=t.id AND tb.state='active' AND tb.body_version=f.source_body_version);
 IF NOT FOUND THEN RETURN NULL; END IF;
 FOR figure IN SELECT value FROM jsonb_array_elements(formation.figures)
   ORDER BY (value->>'figure_index')::integer LOOP
   x:=(figure->>'x_m')::numeric; y:=(figure->>'y_m')::numeric;
   points:=points||jsonb_build_array(jsonb_build_object('figure_index',(figure->>'figure_index')::integer,
     'x_m',x,'y_m',y,'distance_m',combat_spatial.distance_m(b.x_m,b.y_m,x,y),
     'path_clear',combat_spatial.path_first_block_t(i.instance_id,b.actor_id,b.x_m,b.y_m,x,y,t.id)>=1));
 END LOOP;
 RETURN jsonb_build_object('schema_version','combat-multiplication-target-geometry/1',
   'formation_id',formation.id,'state_version',formation.state_version,'target_actor_id',t.id,
   'instance_id',i.instance_id,'map_version',i.map_version,'actor_body_version',owner_body_version,'source_actor_id',b.actor_id,'source_body_version',b.body_version,'figures',points);
END $function$;
CREATE OR REPLACE FUNCTION combat_panel_private.multiplication_view(p_location uuid, p_visible_bodies jsonb)
 RETURNS jsonb
 LANGUAGE plpgsql
 STABLE SECURITY DEFINER
 SET search_path TO ''
AS $function$
DECLARE formations jsonb;
BEGIN
 IF exam_regia_private.current_principal() IS NULL THEN RAISE EXCEPTION 'panel_authentication_required' USING ERRCODE='28000'; END IF;
 IF jsonb_typeof(p_visible_bodies) IS DISTINCT FROM 'array' THEN RETURN NULL; END IF;
 SELECT coalesce(jsonb_agg(jsonb_build_object(
   'formation_id',f.id,'actor_id',f.actor_id,'mode',f.mode,'state_version',f.state_version,
   'figures',(combat_panel_private.multiplication_formation_projection(f.figures,f.copy_count,f.copy_cap,f.original_index))->'figures',
   'original_index',CASE WHEN exam_regia_private.actor_principal(a.id,a.controller_user)=exam_regia_private.current_principal() THEN f.original_index END)
   ORDER BY f.actor_id,f.id),'[]'::jsonb) INTO formations
 FROM combat_panel_private.multiplication_formations f
 JOIN public.combat_v2_actors a ON a.id=f.actor_id AND a.session_id=f.session_id
 JOIN public.combat_v2_sessions s ON s.id=f.session_id AND s.location_id=p_location
 JOIN combat_spatial.arena_instances i ON i.instance_id=f.instance_id AND i.encounter_id=s.id
 WHERE f.state='active' AND a.state='attivo' AND s.closed_at IS NULL
   AND s.state NOT IN ('chiuso','annullato') AND i.state='open'
   AND EXISTS(SELECT 1 FROM jsonb_array_elements(p_visible_bodies) b WHERE b->>'actor_id'=a.id::text)
   AND combat_panel_private.body_visible_to_viewer(i.instance_id,a.id);
 IF jsonb_array_length(formations)=0 THEN RETURN NULL; END IF;
 RETURN jsonb_build_object('schema_version','combat-multiplication-view/1','formations',formations);
END $function$;
CREATE OR REPLACE FUNCTION combat_panel_private.offer_projection(p_offer uuid)
 RETURNS jsonb
 LANGUAGE plpgsql
 STABLE SECURITY DEFINER
 SET search_path TO ''
AS $function$
DECLARE o combat_panel_private.offers%ROWTYPE; c combat_panel_private.contexts%ROWTYPE;
 groups jsonb; fields jsonb;
BEGIN
 IF exam_regia_private.current_principal() IS NULL THEN RAISE EXCEPTION 'panel_authentication_required' USING ERRCODE='28000'; END IF;
 SELECT * INTO STRICT o FROM combat_panel_private.offers WHERE id=p_offer;
 c:=combat_panel_private.owned_context(o.context_id,o.context_version);
 IF o.principal_user IS DISTINCT FROM exam_regia_private.current_principal() OR o.state<>'offered'
  OR o.source_fingerprint IS DISTINCT FROM c.source_fingerprint
  OR o.scene_version IS DISTINCT FROM c.scene_version THEN
   RAISE EXCEPTION 'panel_offer_not_available' USING ERRCODE='42501'; END IF;
 SELECT coalesce(jsonb_agg(jsonb_build_object('group_id',g.id,'label',g.label,
   'selection_mode',g.selection_mode,'purpose',g.purpose,'min_selected',g.min_selected,'max_selected',g.max_selected,
   'depends_on',g.depends_on,'options',(SELECT coalesce(jsonb_agg(jsonb_build_object(
     'option_id',x.id,'label',x.label,'distance_m',x.distance_m,'direction',x.direction) ORDER BY x.ordinal),'[]'::jsonb)
     FROM combat_panel_private.choice_options x WHERE x.group_id=g.id AND x.offer_id=o.id)) ORDER BY g.ordinal),'[]'::jsonb)
  INTO groups FROM combat_panel_private.choice_groups g WHERE g.offer_id=o.id;
 SELECT coalesce(jsonb_agg(jsonb_build_object('input_id',f.id,'label',f.label,
   'value_type',f.value_type,'required',f.required,'max_length',f.max_length) ORDER BY f.ordinal),'[]'::jsonb)
  INTO fields FROM combat_panel_private.input_fields f WHERE f.offer_id=o.id;
 RETURN jsonb_build_object('offer_id',o.id,'kind',o.kind,'operation',o.operation,
   'actor_id',o.actor_id,'label',o.label,'context_version',o.context_version,'scene_version',o.scene_version,
   'requires_role',o.requires_role,'choices',groups,'input_fields',fields);
END $function$;
CREATE OR REPLACE FUNCTION combat_panel_private.owned_context(p_context uuid, p_expected bigint)
 RETURNS combat_panel_private.contexts
 LANGUAGE plpgsql
 STABLE SECURITY DEFINER
 SET search_path TO ''
AS $function$
DECLARE c combat_panel_private.contexts%ROWTYPE;
BEGIN
 IF exam_regia_private.current_principal() IS NULL THEN RAISE EXCEPTION 'panel_authentication_required' USING ERRCODE='28000'; END IF;
 SELECT * INTO c FROM combat_panel_private.contexts WHERE id=p_context AND principal_user=exam_regia_private.current_principal();
 IF c.id IS NULL THEN RAISE EXCEPTION 'panel_context_not_owned' USING ERRCODE='42501'; END IF;
 IF p_expected IS NULL OR c.context_version<>p_expected THEN
   RAISE EXCEPTION 'panel_context_stale' USING ERRCODE='40001'; END IF;
 RETURN c;
END $function$;
CREATE OR REPLACE FUNCTION combat_panel_private.prepare_master_movement(p_round uuid, p_actor uuid, p_capability uuid, p_request uuid)
 RETURNS void
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO ''
AS $function$
DECLARE a public.combat_v2_actors%ROWTYPE; r public.combat_v2_rounds%ROWTYPE;
 c combat_spatial.movement_capabilities%ROWTYPE; b combat_spatial.actor_states%ROWTYPE;
 i combat_spatial.arena_instances%ROWTYPE; ch combat_spatial.movement_semantic_choices%ROWTYPE;
 remaining numeric; distance numeric;
BEGIN
 IF exam_regia_private.current_principal() IS NULL THEN RAISE EXCEPTION 'panel_authentication_required' USING ERRCODE='28000'; END IF;
 PERFORM public.combat_v2_lock_round(p_round);
 SELECT * INTO STRICT r FROM public.combat_v2_rounds WHERE id=p_round;
 SELECT * INTO STRICT a FROM public.combat_v2_actors WHERE id=p_actor AND session_id=r.session_id
   AND exam_regia_private.actor_principal(id,controller_user)=exam_regia_private.current_principal() AND companion_id IS NULL AND state='attivo';
 IF r.phase<>'raccolta_azioni' THEN RAISE EXCEPTION 'panel_movement_phase_invalid' USING ERRCODE='40001'; END IF;
 SELECT * INTO STRICT c FROM combat_spatial.movement_capabilities WHERE capability_id=p_capability AND actor_id=a.id;
 SELECT * INTO STRICT i FROM combat_spatial.arena_instances WHERE instance_id=c.instance_id
   AND encounter_id=a.session_id AND context_source='panel_master' AND state='open' FOR UPDATE;
 SELECT * INTO STRICT b FROM combat_spatial.actor_states WHERE instance_id=i.instance_id AND actor_id=a.id AND state='active' FOR UPDATE;
 SELECT * INTO STRICT ch FROM combat_spatial.movement_semantic_choices WHERE instance_id=i.instance_id
   AND actor_id=a.id AND choice_key=c.choice_key;
 remaining:=(combat_panel_private.master_movement_budget(r.id,a.id)->>'remaining_m')::numeric;
 distance:=combat_spatial.distance_m(c.start_x_m,c.start_y_m,c.end_x_m,c.end_y_m);
 IF b.controller_principal_id IS DISTINCT FROM exam_regia_private.current_principal()
   OR c.state<>'offered' OR c.actor_body_version<>b.body_version OR c.map_version<>i.map_version
   OR c.choice_version<>ch.choice_version OR NOT ch.enabled
   OR left(c.choice_key,length('panel:'||r.id||':'))<>'panel:'||r.id||':'
   OR (c.start_x_m,c.start_y_m) IS DISTINCT FROM (b.x_m,b.y_m)
   OR distance<=0 OR distance>least(remaining,ch.max_budget_m)
   OR (c.end_x_m<>c.start_x_m AND c.end_y_m<>c.start_y_m) THEN
   RAISE EXCEPTION 'panel_movement_option_stale' USING ERRCODE='40001'; END IF;
 INSERT INTO combat_panel_private.master_movement_plans(request_key,principal_user,round_id,actor_id,
   instance_id,capability_id,dx,dy,planned_m,controller_version)
 VALUES(p_request,exam_regia_private.current_principal(),r.id,a.id,i.instance_id,c.capability_id,
   sign(c.end_x_m-c.start_x_m)::integer,sign(c.end_y_m-c.start_y_m)::integer,distance,a.controller_version);
END $function$;
CREATE OR REPLACE FUNCTION combat_panel_private.publish_master_declaration(p_declaration uuid, p_text text)
 RETURNS uuid
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO ''
AS $function$
DECLARE a public.combat_v2_actors%ROWTYPE; d public.combat_v2_declarations%ROWTYPE;
 location uuid; v_message_id uuid; guided_before text;
BEGIN
 SELECT * INTO STRICT d FROM public.combat_v2_declarations WHERE id=p_declaration FOR UPDATE;
 SELECT a0.* INTO a FROM public.combat_v2_actors a0
   JOIN public.combat_v2_rounds r ON r.id=d.round_id AND r.session_id=a0.session_id
   JOIN public.combat_v2_sessions s ON s.id=r.session_id AND s.source_kind='master'
   WHERE a0.id=d.actor_id AND exam_regia_private.actor_principal(a0.id,a0.controller_user)=exam_regia_private.current_principal() AND a0.companion_id IS NULL;
 IF a.id IS NULL OR d.controller_user_snapshot IS DISTINCT FROM exam_regia_private.current_principal()
   OR d.controller_version_snapshot<>a.controller_version OR d.state<>'inviata'
   OR d.declaration_text IS DISTINCT FROM coalesce(p_text,'') THEN
   RAISE EXCEPTION 'panel_role_declaration_scope_invalid' USING ERRCODE='42501'; END IF;
 SELECT location_id INTO STRICT location FROM public.combat_v2_sessions WHERE id=a.session_id;

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
CREATE OR REPLACE FUNCTION combat_panel_private.refresh_context(p_location uuid, p_actor uuid, p_activity_kind text, p_activity uuid, p_round uuid, p_scene_version bigint, p_source_facts jsonb)
 RETURNS combat_panel_private.contexts
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO ''
AS $function$
DECLARE uid uuid:=exam_regia_private.current_principal(); c combat_panel_private.contexts%ROWTYPE; fp text;
BEGIN
 IF uid IS NULL THEN RAISE EXCEPTION 'panel_authentication_required' USING ERRCODE='28000'; END IF;
 IF p_source_facts IS NULL OR jsonb_typeof(p_source_facts) IS DISTINCT FROM 'object'
  OR p_location IS NULL THEN RAISE EXCEPTION 'panel_context_source_invalid' USING ERRCODE='22023'; END IF;
 IF p_actor IS NOT NULL AND NOT EXISTS(SELECT 1 FROM public.combat_v2_actors
   WHERE id=p_actor AND exam_regia_private.actor_principal(id,controller_user)=uid AND session_id=p_activity) THEN
   RAISE EXCEPTION 'panel_actor_not_controlled' USING ERRCODE='42501'; END IF;
 IF p_round IS NOT NULL AND NOT EXISTS(SELECT 1 FROM public.combat_v2_rounds
   WHERE id=p_round AND session_id=p_activity) THEN
   RAISE EXCEPTION 'panel_round_scope_invalid' USING ERRCODE='22023'; END IF;
 -- p_source_facts e composto dall'adattatore su dati server, senza timestamp
 -- volatili o ID di offerte appena generate; mai ricevuto dal browser.
 fp:=public.combat_v2_sha256(jsonb_build_object('location',p_location,'actor',p_actor,
   'kind',p_activity_kind,'activity',p_activity,'round',p_round,'scene',p_scene_version,'facts',p_source_facts,'immobilizations',
     (SELECT coalesce(jsonb_agg(jsonb_build_object('id',e.id,'state',e.state,'pool',e.source_pool) ORDER BY e.id),'[]'::jsonb)
      FROM combat_panel_private.immobilizations e WHERE e.target_actor_id=p_actor AND e.session_id=p_activity),
     'sabaku_clones',(SELECT coalesce(jsonb_agg(jsonb_build_object('id',cl.id,'state',cl.state,'version',cl.state_version) ORDER BY cl.id),'[]'::jsonb)
       FROM clan_sabaku_private.clones cl WHERE cl.session_id=p_activity AND cl.state<>'ended')));
 INSERT INTO combat_panel_private.contexts(location_id,principal_user,command_actor_id,
   activity_kind,activity_id,round_id,scene_version,source_fingerprint)
  VALUES(p_location,uid,p_actor,p_activity_kind,p_activity,p_round,p_scene_version,fp)
  ON CONFLICT(location_id,principal_user,command_actor_id) DO NOTHING;
 SELECT * INTO STRICT c FROM combat_panel_private.contexts
   WHERE location_id=p_location AND principal_user=uid AND command_actor_id IS NOT DISTINCT FROM p_actor FOR UPDATE;
 IF c.source_fingerprint<>fp THEN
   UPDATE combat_panel_private.contexts SET activity_kind=p_activity_kind,activity_id=p_activity,
     round_id=p_round,scene_version=p_scene_version,source_fingerprint=fp,
     context_version=context_version+1,updated_at=clock_timestamp()
    WHERE id=c.id RETURNING * INTO c;
   UPDATE combat_panel_private.offers SET state='revoked'
    WHERE context_id=c.id AND state='offered' AND context_version<>c.context_version;
 END IF;
 RETURN c;
END $function$;
CREATE OR REPLACE FUNCTION combat_panel_private.resolve_master_movement(p_declaration uuid, p_root uuid)
 RETURNS jsonb
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO ''
AS $function$
DECLARE plan combat_panel_private.master_movement_plans%ROWTYPE; d public.combat_v2_declarations%ROWTYPE;
 a public.combat_v2_actors%ROWTYPE; b combat_spatial.actor_states%ROWTYPE; after_body combat_spatial.actor_states%ROWTYPE;
 remaining numeric; metres numeric; actual numeric:=0; key text; item jsonb; movement_result jsonb; spatial jsonb; reason text;
BEGIN
 SELECT * INTO STRICT plan FROM combat_panel_private.master_movement_plans WHERE declaration_id=p_declaration FOR UPDATE;
 IF plan.state='resolved' THEN RETURN plan.result; END IF;
 SELECT * INTO STRICT d FROM public.combat_v2_declarations WHERE id=plan.declaration_id AND round_id=plan.round_id FOR UPDATE;
 SELECT * INTO STRICT a FROM public.combat_v2_actors WHERE id=plan.actor_id FOR UPDATE;
 IF d.actor_id<>a.id OR d.kind<>'movimento' OR d.sanitized_intent->>'movement_contract' IS DISTINCT FROM 'combat-panel-movement/1'
   OR NOT combat_panel_private.controller_version_valid(a.id,plan.controller_version,plan.principal_user) OR d.state<>'congelata'
   OR NOT EXISTS(SELECT 1 FROM public.combat_v2_rounds WHERE id=plan.round_id AND session_id=a.session_id AND phase='risoluzione') THEN
   RAISE EXCEPTION 'panel_movement_resolution_scope_invalid' USING ERRCODE='22023'; END IF;
 PERFORM 1 FROM combat_spatial.arena_instances WHERE instance_id=plan.instance_id AND encounter_id=a.session_id AND state='open' FOR UPDATE;
 IF NOT FOUND THEN RAISE EXCEPTION 'panel_master_geometry_required' USING ERRCODE='22023'; END IF;
 SELECT * INTO STRICT b FROM combat_spatial.actor_states WHERE instance_id=plan.instance_id AND actor_id=a.id FOR UPDATE;
 IF b.controller_principal_id IS DISTINCT FROM exam_regia_private.actor_principal(a.id,a.controller_user) THEN
   RAISE EXCEPTION 'panel_movement_controller_stale' USING ERRCODE='40001'; END IF;
 remaining:=(combat_panel_private.master_movement_budget(plan.round_id,a.id)->>'remaining_m')::numeric;
 metres:=least(plan.planned_m,remaining);
 reason:=combat_panel_private.movement_block_reason(a.id);
 IF reason IS NOT NULL THEN NULL;
 ELSIF b.state<>'active' THEN reason:='actor_inoperative';
 ELSIF metres<=0 THEN reason:='movement_budget_exhausted';
 ELSE
   -- Mantiene la direzione dichiarata, assesta il percorso dalla posizione
   -- effettiva nel proprio ordine di risoluzione, rispettando i blocchi attuali.
   key:='panel-resolve:'||d.id;
   INSERT INTO combat_spatial.movement_semantic_choices(instance_id,actor_id,choice_key,
     endpoint_x_m,endpoint_y_m,max_budget_m,choice_version,enabled)
     VALUES(plan.instance_id,a.id,key,b.x_m+plan.dx*metres,b.y_m+plan.dy*metres,remaining,1,true);
   SELECT value INTO item FROM jsonb_array_elements(combat_spatial.movement_options(plan.instance_id,a.id,remaining))
     WHERE value->>'intent'=key AND (value->>'distance_m')::numeric>0;
   IF item IS NULL THEN reason:='path_blocked';
   ELSE
     spatial:=combat_spatial.movement_commit((item->>'option_id')::uuid,
       md5(p_root::text||':panel-movement:'||d.id)::uuid,d.id);
     SELECT * INTO STRICT after_body FROM combat_spatial.actor_states WHERE instance_id=b.instance_id AND actor_id=b.actor_id;
     actual:=combat_spatial.distance_m(b.x_m,b.y_m,after_body.x_m,after_body.y_m);
     IF actual>metres OR combat_panel_private.movement_event_cost((spatial->>'event_id')::uuid,actual)>remaining THEN RAISE EXCEPTION 'panel_movement_budget_exceeded' USING ERRCODE='22023'; END IF;
   END IF;
 END IF;
 INSERT INTO combat_panel_private.master_movement_receipts(declaration_id,round_id,owner_actor_id,body_actor_id,spatial_event_id,distance_m)
   VALUES(d.id,d.round_id,a.id,a.id,(spatial->>'event_id')::uuid,actual);
 movement_result:=jsonb_build_object('movement_contract','combat-panel-movement/1','movement_m',round(actual,2),
   'planned_m',round(plan.planned_m,2),'reason_code',reason,'spatial_event_id',spatial->'event_id');
 UPDATE combat_panel_private.master_movement_plans SET state='resolved',result=movement_result WHERE request_key=plan.request_key;
 RETURN movement_result;
END $function$;
CREATE OR REPLACE FUNCTION combat_panel_private.resolve_selections(p_offer uuid, p_ids uuid[], p_inputs jsonb)
 RETURNS jsonb
 LANGUAGE plpgsql
 STABLE SECURITY DEFINER
 SET search_path TO ''
AS $function$
DECLARE o combat_panel_private.offers%ROWTYPE; g combat_panel_private.choice_groups%ROWTYPE;
 f combat_panel_private.input_fields%ROWTYPE; selected_count integer; item jsonb; value jsonb;
 chosen jsonb; result_groups jsonb:='[]'; result_inputs jsonb:='{}'; active_group boolean;
BEGIN
 IF exam_regia_private.current_principal() IS NULL THEN RAISE EXCEPTION 'panel_authentication_required' USING ERRCODE='28000'; END IF;
 SELECT * INTO STRICT o FROM combat_panel_private.offers WHERE id=p_offer;
 IF o.principal_user IS DISTINCT FROM exam_regia_private.current_principal() OR o.state<>'offered' THEN
   RAISE EXCEPTION 'panel_offer_not_available' USING ERRCODE='42501'; END IF;
 IF p_ids IS NULL OR array_position(p_ids,NULL) IS NOT NULL
  OR cardinality(p_ids)<>(SELECT count(DISTINCT x) FROM unnest(p_ids) AS x)
  OR jsonb_typeof(p_inputs) IS DISTINCT FROM 'array' THEN
   RAISE EXCEPTION 'panel_selection_invalid' USING ERRCODE='22023'; END IF;
 IF EXISTS(SELECT 1 FROM unnest(p_ids) AS wanted(id) WHERE NOT EXISTS(
   SELECT 1 FROM combat_panel_private.choice_options x WHERE x.id=wanted.id AND x.offer_id=o.id)) THEN
   RAISE EXCEPTION 'panel_selection_not_offered' USING ERRCODE='22023'; END IF;
 -- La FK lega ogni dipendenza alla stessa offerta; questo controllo rifiuta
 -- anche cicli, che renderebbero impossibile una selezione completa.
 IF EXISTS(WITH RECURSIVE deps AS (
   SELECT id,depends_on,ARRAY[id] AS visited,false AS cycle FROM combat_panel_private.choice_groups WHERE offer_id=o.id
   UNION ALL
   SELECT parent.id,parent.depends_on,d.visited||parent.id,parent.id=ANY(d.visited)
   FROM deps d JOIN combat_panel_private.choice_options option_row ON option_row.id=d.depends_on
   JOIN combat_panel_private.choice_groups parent ON parent.id=option_row.group_id
   WHERE NOT d.cycle
 ) SELECT 1 FROM deps WHERE cycle) THEN
   RAISE EXCEPTION 'panel_choice_dependency_cycle'; END IF;
 FOR g IN SELECT * FROM combat_panel_private.choice_groups WHERE offer_id=o.id ORDER BY ordinal LOOP
   active_group:=g.depends_on IS NULL OR g.depends_on=ANY(p_ids);
   SELECT count(*),coalesce(jsonb_agg(jsonb_build_object('option_id',x.id,'payload',x.source_payload) ORDER BY x.ordinal),'[]'::jsonb)
    INTO selected_count,chosen FROM combat_panel_private.choice_options x
    WHERE x.offer_id=o.id AND x.group_id=g.id AND x.id=ANY(p_ids);
   IF (active_group AND (selected_count<g.min_selected OR selected_count>g.max_selected))
     OR (NOT active_group AND selected_count<>0) THEN
     RAISE EXCEPTION 'panel_choice_cardinality_or_dependency_invalid' USING ERRCODE='22023'; END IF;
   IF active_group THEN result_groups:=result_groups||jsonb_build_array(jsonb_build_object('group_id',g.id,'options',chosen)); END IF;
 END LOOP;
 FOR item IN SELECT x.value FROM jsonb_array_elements(p_inputs) AS x LOOP
   IF jsonb_typeof(item) IS DISTINCT FROM 'object' OR NOT(item ?& ARRAY['input_id','value']) THEN
     RAISE EXCEPTION 'panel_input_shape_invalid' USING ERRCODE='22023'; END IF;
   IF NOT EXISTS(SELECT 1 FROM combat_panel_private.input_fields WHERE offer_id=o.id AND id=(item->>'input_id')::uuid) THEN
     RAISE EXCEPTION 'panel_input_not_offered' USING ERRCODE='22023'; END IF;
 END LOOP;
 FOR f IN SELECT * FROM combat_panel_private.input_fields WHERE offer_id=o.id ORDER BY ordinal LOOP
   SELECT count(*),jsonb_agg(x.value->'value')->0 INTO selected_count,value
    FROM jsonb_array_elements(p_inputs) AS x WHERE (x.value->>'input_id')::uuid=f.id;
   IF selected_count>1 OR (f.required AND selected_count<>1) THEN
     RAISE EXCEPTION 'panel_input_cardinality_invalid' USING ERRCODE='22023'; END IF;
   IF selected_count=0 THEN CONTINUE; END IF;
   IF (f.value_type='text' AND (jsonb_typeof(value) IS DISTINCT FROM 'string'
      OR length(value#>>'{}')>f.max_length OR (f.required AND length(btrim(value#>>'{}'))=0)))
     OR (f.value_type='boolean' AND jsonb_typeof(value) IS DISTINCT FROM 'boolean') THEN
     RAISE EXCEPTION 'panel_input_value_invalid' USING ERRCODE='22023'; END IF;
   result_inputs:=result_inputs||jsonb_build_object(f.source_key,value);
 END LOOP;
 -- Dati privati per il dispatcher. Non restituire questa shape da una RPC.
 RETURN jsonb_build_object('groups',result_groups,'inputs',result_inputs);
END $function$;
CREATE OR REPLACE FUNCTION combat_panel_private.round_options_authoritative(p_round uuid, p_actor uuid)
 RETURNS jsonb
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO ''
AS $function$
declare v_uid uuid:=exam_regia_private.current_principal(); v_a public.combat_v2_actors%rowtype; v_r public.combat_v2_rounds%rowtype;
begin
  select * into v_a from public.combat_v2_actors where id=p_actor;
  if v_a.companion_id is not null then perform public.combat_v2_fail('compagno_senza_turno','Comandi disponibili soltanto al controllore.',409,null,'{}'); end if;
  select * into v_r from public.combat_v2_rounds where id=p_round;
  if v_a.id is null or v_r.id is null or v_a.session_id<>v_r.session_id then perform public.combat_v2_fail('opzione_non_offerta','Attore o round non valido.',422,null,'{}'); end if;
  if exam_regia_private.actor_principal(v_a.id,v_a.controller_user)<>v_uid then perform public.combat_v2_fail('attore_non_controllato','Non controlli questo attore.',403,null,'{}'); end if;
  return public.combat_v2_envelope(null,jsonb_build_object('round',p_round,'actor',p_actor,'phase',v_r.phase,
    'abilities',(
      select coalesce(jsonb_agg(combat_v2_multitarget_internal.enrich_ability_v1(e.value) order by e.ord),'[]'::jsonb)
      from jsonb_array_elements(coalesce(v_a.mechanics_snapshot->'abilities','[]'::jsonb)) with ordinality e(value,ord)
      where e.value->>'id'<>'31b15861-fb78-4f8a-ac1c-ebf2d957c32e'
        and (not combat_v2_elemental_internal.is_target_v1((e.value->>'id')::uuid)
          or (v_r.phase='raccolta_azioni' and combat_v2_elemental_internal.eligible_v1(v_a.character_id,(e.value->>'id')::uuid,false))
          or (v_r.phase='raccolta_difese' and combat_v2_elemental_internal.eligible_v1(v_a.character_id,(e.value->>'id')::uuid,true)))
        and not (v_r.phase='raccolta_difese' and e.value->>'id'='9f12fc98-bc97-4b95-9bcc-7ce359ebbe4f' and not exists (
          select 1 from public.combat_v2_attack_targets mt join public.combat_v2_declarations ad on ad.id=mt.attack_declaration_id
          where mt.round_id=p_round and mt.target_actor_id=p_actor and mt.state='attesa_difesa'
            and lower(coalesce(ad.sanitized_intent#>>'{server_ability,kind}','')) like '%genjutsu%'))
    ),
    'targeting_contract','combat-targeting/1.1','pending_attack_targets',(select coalesce(jsonb_agg(jsonb_build_object('attack_target_id',t.id,'attack_declaration_id',t.attack_declaration_id,'target_actor_id',t.target_actor_id)order by t.created_at,t.ordinal),'[]'::jsonb)from public.combat_v2_attack_targets t join public.combat_v2_actors x on x.id=t.target_actor_id where t.round_id=p_round and t.state='attesa_difesa'and(x.id=p_actor or x.team_key=v_a.team_key) and (not clan_marionettisti_private.is_dedicated_scene(v_a.session_id) or clan_marionettisti_private.actor_visible(v_a.session_id,x.id,v_uid))),
    'targets',(select coalesce(jsonb_agg(jsonb_build_object('id',x.id,'team',x.team_key,'state',x.state,'position_m',case when clan_marionettisti_private.is_dedicated_scene(v_a.session_id) then null else x.position_m end)),'[]'::jsonb) from public.combat_v2_actors x where x.session_id=v_a.session_id and x.id<>v_a.id and x.team_key<>v_a.team_key and (x.companion_id is null or x.state='attivo') and (not clan_marionettisti_private.is_dedicated_scene(v_a.session_id) or clan_marionettisti_private.actor_visible(v_a.session_id,x.id,v_uid))),
    'reactions',jsonb_build_array('schivata','parata','nessuna'),'substitution_offers',public.combat_v2_substitution_round_offers_v1(p_round,p_actor)) || case when clan_marionettisti_private.is_dedicated_scene(v_a.session_id) then jsonb_build_object('companion_controls',clan_marionettisti_private.relink_options(p_round,p_actor)) else '{}'::jsonb end);
end
$function$;
CREATE OR REPLACE FUNCTION combat_panel_private.sync_master_scene(p_encounter uuid)
 RETURNS void
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO ''
AS $function$
DECLARE s public.combat_v2_sessions%ROWTYPE; m public.master_v2_sessions%ROWTYPE;
 i combat_spatial.arena_instances%ROWTYPE; claim combat_panel_private.master_scene_claims%ROWTYPE;
 changed integer:=0; n integer; terminal boolean;
BEGIN
 SELECT * INTO i FROM combat_spatial.arena_instances WHERE encounter_id=p_encounter AND context_source='panel_master' FOR UPDATE;
 IF NOT FOUND THEN RETURN; END IF;
 SELECT * INTO STRICT s FROM public.combat_v2_sessions WHERE id=i.encounter_id;
 SELECT * INTO STRICT m FROM public.master_v2_sessions WHERE id=i.master_session_id;
 SELECT * INTO STRICT claim FROM combat_panel_private.master_scene_claims WHERE id=i.panel_claim_id;
 terminal:=s.state IN ('chiuso','annullato') OR s.closed_at IS NOT NULL OR m.stato IN ('chiusa','annullata') OR m.closed_at IS NOT NULL;
 IF terminal THEN
   UPDATE combat_spatial.arena_instances SET state='closed',map_version=map_version+1 WHERE instance_id=i.instance_id AND state='open';
   UPDATE combat_spatial.actor_states SET state='removed',body_version=body_version+1 WHERE instance_id=i.instance_id AND state='active';
   UPDATE combat_spatial.viewer_grants SET can_view_map=false,can_view_objects=false,grant_version=grant_version+1
     WHERE instance_id=i.instance_id AND (can_view_map OR can_view_objects);
   UPDATE combat_spatial.movement_semantic_choices SET enabled=false,choice_version=choice_version+1 WHERE instance_id=i.instance_id AND enabled;
   UPDATE combat_spatial.movement_capabilities SET state='stale' WHERE instance_id=i.instance_id AND state='offered';
   UPDATE combat_spatial.defense_windows SET state='closed',window_version=window_version+1 WHERE instance_id=i.instance_id AND state='open';
   UPDATE combat_spatial.substitution_capabilities SET state='expired' WHERE instance_id=i.instance_id AND state='offered';
   UPDATE combat_spatial.substitution_activity_links SET state='closed' WHERE instance_id=i.instance_id AND state IN ('offered','selected');
   UPDATE combat_spatial.substitution_activity_options o SET state='expired'
     FROM combat_spatial.substitution_activity_links l WHERE l.link_id=o.link_id AND l.instance_id=i.instance_id AND o.state='offered';
   UPDATE combat_spatial.substitution_activity_options o SET state='stale'
     FROM combat_spatial.substitution_activity_links l WHERE l.link_id=o.link_id AND l.instance_id=i.instance_id AND o.state='selected';
   UPDATE combat_panel_private.offers o SET state='revoked' FROM combat_panel_private.contexts c
     WHERE c.id=o.context_id AND c.activity_id IN (s.id,m.id) AND o.state='offered';
   RETURN;
 END IF;
 IF i.state<>'open' THEN RAISE EXCEPTION 'panel_closed_arena_cannot_resume' USING ERRCODE='22023'; END IF;
 UPDATE combat_spatial.actor_states b SET controller_principal_id=exam_regia_private.actor_principal(a.id,a.controller_user),body_version=b.body_version+1
   FROM public.combat_v2_actors a WHERE b.instance_id=i.instance_id AND a.id=b.actor_id AND a.session_id=s.id
     AND b.controller_principal_id IS DISTINCT FROM exam_regia_private.actor_principal(a.id,a.controller_user);
 GET DIAGNOSTICS n=ROW_COUNT; changed:=changed+n;
 -- Un precedente Master non conserva la visibilità privilegiata. Rimane
 -- soltanto la visibilità che gli spetta come eventuale controllore PG.
 WITH wanted AS (
   SELECT b.actor_id,viewers.uid,true AS map_allowed,
     viewers.uid=m.master_user OR claim.visibility_mode='participants' AS objects_allowed
   FROM combat_spatial.actor_states b CROSS JOIN LATERAL (
     SELECT m.master_user AS uid WHERE m.master_user IS NOT NULL
     UNION SELECT exam_regia_private.actor_principal(a.id,a.controller_user) FROM public.combat_v2_actors a WHERE a.session_id=s.id AND exam_regia_private.actor_principal(a.id,a.controller_user) IS NOT NULL
       AND (claim.visibility_mode='participants' OR a.id=b.actor_id)
   ) viewers WHERE b.instance_id=i.instance_id
 ) UPDATE combat_spatial.viewer_grants g SET can_view_map=false,can_view_objects=false,grant_version=g.grant_version+1
   WHERE g.instance_id=i.instance_id AND (g.can_view_map OR g.can_view_objects) AND NOT EXISTS(
     SELECT 1 FROM wanted w WHERE w.uid=g.viewer_principal_id AND w.actor_id=g.subject_actor_id);
 GET DIAGNOSTICS n=ROW_COUNT; changed:=changed+n;
 INSERT INTO combat_spatial.viewer_grants AS existing(instance_id,viewer_principal_id,subject_actor_id,can_view_map,can_view_objects,grant_version)
   SELECT i.instance_id,viewers.uid,b.actor_id,true,viewers.uid=m.master_user OR claim.visibility_mode='participants',1
   FROM combat_spatial.actor_states b CROSS JOIN LATERAL (
     SELECT m.master_user AS uid WHERE m.master_user IS NOT NULL
     UNION SELECT exam_regia_private.actor_principal(a.id,a.controller_user) FROM public.combat_v2_actors a WHERE a.session_id=s.id AND exam_regia_private.actor_principal(a.id,a.controller_user) IS NOT NULL
       AND (claim.visibility_mode='participants' OR a.id=b.actor_id)
   ) viewers WHERE b.instance_id=i.instance_id
   ON CONFLICT(instance_id,viewer_principal_id,subject_actor_id) DO UPDATE
     SET can_view_map=EXCLUDED.can_view_map,can_view_objects=EXCLUDED.can_view_objects,grant_version=existing.grant_version+1
     WHERE (existing.can_view_map,existing.can_view_objects) IS DISTINCT FROM (EXCLUDED.can_view_map,EXCLUDED.can_view_objects);
 GET DIAGNOSTICS n=ROW_COUNT; changed:=changed+n;
 IF changed>0 THEN
   -- Il subentro cambia authority/grant, non la geometria. Non invalidare
   -- con una finta versione spaziale le difese PG gia selezionate.
   -- Il contesto UI cambia grazie alla versione Master e le offerte scadono.
   UPDATE combat_panel_private.offers o SET state='revoked' FROM combat_panel_private.contexts c
     WHERE c.id=o.context_id AND c.activity_id IN (s.id,m.id) AND o.state='offered';
 END IF;
END $function$;
CREATE OR REPLACE FUNCTION combat_panel_private.target_geometry_valid(p_actor uuid, p_target uuid, p_range numeric)
 RETURNS boolean
 LANGUAGE plpgsql
 STABLE SECURITY DEFINER
 SET search_path TO ''
AS $function$
DECLARE a public.combat_v2_actors%ROWTYPE; t public.combat_v2_actors%ROWTYPE;
 i combat_spatial.arena_instances%ROWTYPE; ab combat_spatial.actor_states%ROWTYPE; tb combat_spatial.actor_states%ROWTYPE;
BEGIN
 SELECT * INTO STRICT a FROM public.combat_v2_actors WHERE id=p_actor;
 SELECT * INTO STRICT t FROM public.combat_v2_actors WHERE id=p_target;
 IF a.session_id<>t.session_id OR a.state<>'attivo' OR t.state<>'attivo'
   OR a.team_key=t.team_key OR p_range IS NULL OR p_range<0 OR p_range IN ('NaN'::numeric,'Infinity'::numeric) THEN RETURN false; END IF;
 SELECT * INTO i FROM combat_spatial.arena_instances WHERE encounter_id=a.session_id AND context_source='panel_master' AND state='open';
 IF i.instance_id IS NULL THEN RETURN false; END IF;
 -- Solo un bersaglio visibile al controllore diventa una scelta autorizzata.
 IF NOT EXISTS(SELECT 1 FROM combat_spatial.viewer_grants WHERE instance_id=i.instance_id
   AND viewer_principal_id=exam_regia_private.actor_principal(a.id,a.controller_user) AND subject_actor_id=t.id AND can_view_map) THEN RETURN false; END IF;
 SELECT * INTO ab FROM combat_spatial.actor_states WHERE instance_id=i.instance_id AND actor_id=a.id AND state='active';
 SELECT * INTO tb FROM combat_spatial.actor_states WHERE instance_id=i.instance_id AND actor_id=t.id AND state='active';
 IF ab.actor_id IS NULL OR tb.actor_id IS NULL THEN RETURN false; END IF;
 RETURN combat_spatial.distance_m(ab.x_m,ab.y_m,tb.x_m,tb.y_m)<=p_range
   AND combat_spatial.path_first_block_t(i.instance_id,a.id,ab.x_m,ab.y_m,tb.x_m,tb.y_m,t.id)>=1;
END $function$;
CREATE OR REPLACE FUNCTION combat_panel_private.uses_simulated_pools(p_session uuid)
 RETURNS boolean
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO ''
AS $function$
DECLARE loc uuid; principals uuid[];
BEGIN
 IF exam_regia_private.is_bound(p_session) THEN RETURN true; END IF;
 SELECT s.location_id INTO loc FROM public.combat_v2_sessions s
   JOIN public.locations l ON l.id=s.location_id AND l.is_active AND l.is_test
   JOIN combat_spatial.arena_instances i ON i.encounter_id=s.id AND i.context_source='panel_master'
   JOIN combat_panel_private.master_scene_claims c ON c.id=i.panel_claim_id AND c.encounter_id=s.id
     AND c.master_session_id=s.master_session_id AND c.policy_id='staff_test_no_persistent_resources_v1'
   WHERE s.id=p_session AND s.source_kind='master';
 IF loc IS NOT NULL THEN
   SELECT array_agg(DISTINCT controller_user) INTO principals FROM public.combat_v2_actors WHERE session_id=p_session;
   IF NOT combat_consumer_private.staff_test_allowed(loc,principals,false)
     OR EXISTS(SELECT 1 FROM public.combat_v2_actors a LEFT JOIN public.characters c ON c.id=a.character_id
       WHERE a.session_id=p_session AND a.actor_kind='pg' AND (c.id IS NULL OR c.user_id IS DISTINCT FROM exam_regia_private.actor_principal(a.id,a.controller_user))) THEN
     RAISE EXCEPTION 'panel_staff_resource_scope_invalid' USING ERRCODE='42501'; END IF;
   RETURN true;
 END IF;
 -- Il ramo Marionettisti continua a usare la propria autorita senza modificarla.
 IF clan_marionettisti_private.is_staff_scene(p_session) THEN RETURN true; END IF;
 -- Estensione ordinaria: solo la policy Staff nativa, mai il solo flag is_test.
 IF EXISTS (
   SELECT 1 FROM public.combat_v2_sessions ss
   JOIN combat_consumer_private.activities act ON act.session_id=ss.id
   WHERE ss.id=p_session AND ss.source_kind='ordinary'
     AND act.policy_id='staff_test_no_persistent_resources_v1'
 ) THEN
   SELECT ss.location_id INTO loc
   FROM public.combat_v2_sessions ss
   JOIN combat_consumer_private.activities act
     ON act.session_id=ss.id AND act.location_id=ss.location_id
   JOIN public.locations room ON room.id=ss.location_id AND room.is_active AND room.is_test
   WHERE ss.id=p_session AND ss.source_kind='ordinary'
     AND ss.closed_at IS NULL AND act.closed_at IS NULL AND act.phase<>'closed'
     AND ss.state NOT IN ('chiuso','risolto','annullato')
     AND act.policy_id='staff_test_no_persistent_resources_v1'
     AND NOT public.combat_v2_values_written(ss.id);
   SELECT array_agg(DISTINCT actor_row.controller_user ORDER BY actor_row.controller_user)
   INTO principals FROM public.combat_v2_actors actor_row WHERE actor_row.session_id=p_session;
   IF loc IS NULL OR cardinality(principals) IS DISTINCT FROM 2
     OR array_position(principals,NULL) IS NOT NULL
     OR (SELECT count(*) FROM public.combat_v2_actors WHERE session_id=p_session)<>2
     OR (SELECT count(*) FROM combat_consumer_private.members WHERE session_id=p_session)<>2
     OR (SELECT count(*) FROM public.combat_v2_actors actor_row
       JOIN combat_consumer_private.members member_row
         ON member_row.session_id=actor_row.session_id AND member_row.actor_id=actor_row.id
           AND member_row.character_id=actor_row.character_id
       JOIN public.characters character_row
         ON character_row.id=actor_row.character_id AND character_row.user_id=actor_row.controller_user
       WHERE actor_row.session_id=p_session AND actor_row.actor_kind='pg'
         AND actor_row.companion_id IS NULL)<>2
     OR combat_consumer_private.staff_test_allowed(loc,principals,false) IS DISTINCT FROM true THEN
     RAISE EXCEPTION 'panel_staff_resource_scope_invalid' USING ERRCODE='42501';
   END IF;
   RETURN true;
 END IF;
 RETURN false;
END $function$;
CREATE OR REPLACE FUNCTION combat_spatial.exchange_owner_receipt(p_instance uuid, p_round uuid)
 RETURNS jsonb
 LANGUAGE plpgsql
 STABLE SECURITY DEFINER
 SET search_path TO ''
AS $function$
  declare i record;t record;actors jsonb;events jsonb;valid boolean;exact_events boolean;fp text;
  begin
   IF exam_regia_private.is_bound((SELECT encounter_id FROM combat_spatial.arena_instances WHERE instance_id=p_instance)) THEN RETURN exam_regia_private.exchange_spatial_receipt(p_instance,p_round); END IF;
   select * into strict i from combat_spatial.arena_instances where instance_id=p_instance and state='open';
   select * into strict t from combat_spatial.arena_templates where template_key=i.template_key and template_version=i.template_version;
   select jsonb_agg(a.actor_id order by a.actor_id),count(*)=4 and count(distinct a.actor_id)=4 and count(*)filter(where a.actor_kind='PG')=2 and count(*)filter(where a.actor_kind='PNG')=2 and bool_and(a.footprint_radius_m>0 and a.body_version>0 and a.x_m-a.footprint_radius_m>=0 and a.y_m-a.footprint_radius_m>=0 and a.x_m+a.footprint_radius_m<=t.width_m and a.y_m+a.footprint_radius_m<=t.height_m)
    into actors,valid from combat_spatial.actor_states a where a.instance_id=p_instance and a.state='active';
   select jsonb_agg(jsonb_build_object('event_id',e.event_id,'actor_id',e.actor_id,'event_kind',e.event_kind,'before',e.before_state,'after',e.after_state,'request_key',q.request_key,'operation',q.operation,'request_fingerprint',q.request_fingerprint)order by e.actor_id),
    count(*)=4 and count(distinct e.actor_id)=4 and bool_and(e.root_id=p_round and e.event_kind='exchange_state' and q.operation='exchange_state' and q.request_fingerprint~'^[0-9a-f]{64}$' and q.result->>'event_id'=e.event_id::text and q.result->>'instance_id'=p_instance::text and q.result->>'root_id'=p_round::text and q.result->>'actor_id'=e.actor_id::text and(q.result->>'map_version')::int=i.map_version and(e.before_state->>'body_version')::int>0 and(e.after_state->>'body_version')::int=a.body_version and(e.before_state->>'x_m')::numeric-a.footprint_radius_m>=0 and(e.before_state->>'y_m')::numeric-a.footprint_radius_m>=0 and(e.before_state->>'x_m')::numeric+a.footprint_radius_m<=t.width_m and(e.before_state->>'y_m')::numeric+a.footprint_radius_m<=t.height_m and(e.after_state->>'x_m')::numeric-a.footprint_radius_m>=0 and(e.after_state->>'y_m')::numeric-a.footprint_radius_m>=0 and(e.after_state->>'x_m')::numeric+a.footprint_radius_m<=t.width_m and(e.after_state->>'y_m')::numeric+a.footprint_radius_m<=t.height_m)
    into events,exact_events from combat_spatial.spatial_events e join combat_spatial.request_receipts q on q.result->>'event_id'=e.event_id::text join combat_spatial.actor_states a on a.instance_id=e.instance_id and a.actor_id=e.actor_id where e.instance_id=p_instance and e.root_id=p_round;
   if coalesce(valid,false)is not true or coalesce(exact_events,false)is not true or(select jsonb_agg(to_jsonb(x->>'actor_id')order by x->>'actor_id')from jsonb_array_elements(events)x)<>actors then raise exception'G2_SPATIAL_OWNER_DRIFT'using errcode='23514';end if;
   fp:=encode(extensions.digest(convert_to(jsonb_build_object('instance',p_instance,'round',p_round,'master',i.master_session_id,'encounter',i.encounter_id,'template',i.template_key,'template_version',i.template_version,'map_version',i.map_version,'bounds',jsonb_build_object('width_m',t.width_m,'height_m',t.height_m),'actors',actors,'events',events)::text,'UTF8'),'sha256'),'hex');
   return jsonb_build_object('schema_version','combat-spatial-exchange-owner/1.0','instance_id',p_instance,'round_id',p_round,'master_session_id',i.master_session_id,'encounter_id',i.encounter_id,'template_key',i.template_key,'template_version',i.template_version,'map_version',i.map_version,'bounds',jsonb_build_object('width_m',t.width_m,'height_m',t.height_m),'actor_ids',actors,'events',events,'bounds_valid',true,'events_exact',true,'owner_fingerprint',fp);
  end$function$;
CREATE OR REPLACE FUNCTION combat_spatial.substitution_combat_context_v1(p_attack uuid)
 RETURNS jsonb
 LANGUAGE plpgsql
 STABLE SECURITY DEFINER
 SET search_path TO ''
AS $function$
declare
  d public.combat_v2_declarations%rowtype;
  r public.combat_v2_rounds%rowtype;
  s public.combat_v2_sessions%rowtype;
  a public.combat_v2_actors%rowtype;
  i combat_spatial.arena_instances%rowtype;
  ability jsonb; profile text; source_sha text;
begin
  select * into strict d from public.combat_v2_declarations
   where id=p_attack and kind='attacco' and state in ('inviata','congelata');
  select * into strict r from public.combat_v2_rounds where id=d.round_id;
  select * into strict s from public.combat_v2_sessions where id=r.session_id and state in ('in_corso','preparazione');
  select * into strict a from public.combat_v2_actors
   where id=d.target_actor_id and session_id=s.id and state='attivo';
  select * into strict i from combat_spatial.arena_instances
   where state='open' and master_session_id=s.master_session_id;
  if r.phase not in ('raccolta_difese','congelato','risoluzione') then
    raise exception using errcode='23514',message='substitution_parent_window_invalid';
  end if;
  select x into ability from jsonb_array_elements(coalesce(a.mechanics_snapshot->'abilities','[]'::jsonb)) x
   where x->>'source'='jutsu' and x->>'id'='31b15861-fb78-4f8a-ac1c-ebf2d957c32e'
     and x->>'usage'='difesa' and coalesce((x->>'defensive')::boolean,false)
     and coalesce((x->>'chakra_cost')::integer,-1)=5;
  if ability is null then raise exception using errcode='23514',message='substitution_source_not_owned_or_active'; end if;
  if a.actor_kind='pg' and not exists(
    select 1 from public.characters c
    join public.character_jutsu cj on cj.user_id=c.user_id
    join public.jutsu j on j.id=cj.jutsu_id
    where c.id=a.character_id and j.id='31b15861-fb78-4f8a-ac1c-ebf2d957c32e'::uuid
      and j.is_active and j.chakra_cost=5 and j.action_type='reazione' and j.uso='difesa' and j.difensiva
  ) then raise exception using errcode='23514',message='substitution_source_not_owned_or_active'; end if;
  if coalesce((a.mechanics_snapshot->>'chakra')::integer,0)<5 then
    raise exception using errcode='23514',message='substitution_resource_or_reaction_unavailable';
  end if;
  profile:=combat_spatial.substitution_range_profile_v1(coalesce((a.mechanics_snapshot->>'ninjutsu')::integer,0));
  source_sha:=encode(extensions.digest(convert_to(
    'common-substitution-source/1.0:'||jsonb_build_object(
      'actor',a.id,'character',a.character_id,'controller_version',a.controller_version,
      'jutsu','31b15861-fb78-4f8a-ac1c-ebf2d957c32e','ability',ability,
      'ninjutsu',a.mechanics_snapshot->'ninjutsu','chakra',a.mechanics_snapshot->'chakra',
      'round',r.id,'round_no',exam_regia_private.logical_round_no(r.id),'instance',i.instance_id)::text,'UTF8'),'sha256'),'hex');
  return jsonb_build_object('instance_id',i.instance_id,'combat_session_id',s.id,'round_id',r.id,
    'round_no',exam_regia_private.logical_round_no(r.id),'attack_id',d.id,'defender_actor_id',a.id,'controller_user',exam_regia_private.actor_principal(a.id,a.controller_user),
    'controller_version',a.controller_version,'ninjutsu',coalesce((a.mechanics_snapshot->>'ninjutsu')::integer,0),
    'chakra',coalesce((a.mechanics_snapshot->>'chakra')::integer,0),'source_profile_id',profile,
    'source_snapshot_sha256',source_sha,'actor_kind',a.actor_kind,'character_id',a.character_id);
end
$function$;
CREATE OR REPLACE FUNCTION mission_exam_private.bind_class_session()
 RETURNS trigger
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO ''
AS $function$
DECLARE req mission_exam_private.open_requests%ROWTYPE; cap integer;
BEGIN
  SELECT * INTO req FROM mission_exam_private.open_requests
    WHERE transaction_id=txid_current() AND owner_user=NEW.started_by AND class_session_id IS NULL FOR UPDATE;
  IF NOT FOUND THEN RETURN NEW; END IF;
  IF req.exam_regia_admission_id IS NOT NULL THEN
    IF NOT EXISTS(SELECT 1 FROM exam_regia_private.admissions a WHERE a.id=req.exam_regia_admission_id
      AND exam_regia_private.native_open_allowed(req.owner_user,a.character_id,NEW.location_id)) THEN
      RAISE EXCEPTION 'exam_regia_native_open_scope' USING ERRCODE='42501'; END IF;
    UPDATE mission_exam_private.open_requests SET class_session_id=NEW.id WHERE request_id=req.request_id;
    SELECT rt.provider_call_cap INTO STRICT cap FROM exam_regia_private.runtime rt JOIN mission_exam_private.release_gate gate ON gate.singleton AND gate.enabled WHERE rt.singleton AND rt.enabled;
    INSERT INTO mission_exam_private.protected_sessions(class_session_id,owner_user,character_id,location_id,request_id,provider_call_cap,policy_version)
    SELECT NEW.id,req.owner_user,a.character_id,NEW.location_id,req.request_id,cap,'exam_protected_no_persistent_resources_v1'
    FROM exam_regia_private.admissions a WHERE a.id=req.exam_regia_admission_id;
    RETURN NEW;
  END IF;
  IF auth.uid() IS DISTINCT FROM req.owner_user
    OR NEW.location_id<>'df83cd65-b13d-49d6-ad77-a44f35d5ea00'::uuid THEN
    RAISE EXCEPTION 'mission_session_open_scope' USING ERRCODE='42501'; END IF;
  SELECT coalesce((SELECT rt.provider_call_cap FROM exam_regia_private.runtime rt
    WHERE rt.singleton AND rt.enabled AND EXISTS(SELECT 1 FROM exam_regia_private.admissions ad
     WHERE ad.owner_user=req.owner_user AND ad.character_id='f335b077-34a1-41c3-94aa-58ec674b649b'::uuid
     AND ad.location_id=NEW.location_id AND ad.surface='konoha' AND ad.enabled AND ad.expires_at>clock_timestamp())),g.provider_call_cap)
    INTO STRICT cap FROM mission_exam_private.release_gate g WHERE g.singleton AND g.enabled;
  INSERT INTO mission_exam_private.protected_sessions
    (class_session_id,owner_user,character_id,location_id,request_id,provider_call_cap)
    VALUES(NEW.id,req.owner_user,'f335b077-34a1-41c3-94aa-58ec674b649b',NEW.location_id,req.request_id,cap);
  UPDATE mission_exam_private.open_requests SET class_session_id=NEW.id WHERE request_id=req.request_id;
  RETURN NEW;
END $function$;
CREATE OR REPLACE FUNCTION mission_exchange_owner.assert_exact_pinset()
 RETURNS void
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO ''
AS $function$
declare r record;actual text;resolved regprocedure;begin
 for r in select signature,object_fingerprint from mission_exchange_combat_owner.release_function_seals loop
  resolved:=to_regprocedure(case when position('.'in split_part(r.signature,'(',1))=0 then'public.'||r.signature else r.signature end);
  if resolved is null then raise exception 'G1_PINSET_OBJECT_MISSING:%',r.signature;end if;
  actual:=mission_exchange_combat_owner.function_fingerprint(resolved);
  if actual is distinct from r.object_fingerprint AND NOT exam_regia_private.seal_composition_valid(r.signature,r.object_fingerprint,actual) then raise exception 'G1_PINSET_DRIFT:%',r.signature;end if;
 end loop;
end$function$;
CREATE OR REPLACE FUNCTION public._esame_png_gioca(p_prova uuid, p_opzione text, p_da text)
 RETURNS jsonb
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO 'public'
AS $function$
declare
  v public.esame_prove%rowtype;
  v_int jsonb; v_sc jsonb;
  v_metri numeric; v_pos int; v_id uuid;
  v_spatial jsonb;
begin
  perform exam_regia_private.assert_no_legacy(p_prova);
  select * into v from public.esame_prove where id = p_prova for update;
  if not found or v.stato <> 'aperta' then
    return jsonb_build_object('versione',1,'ok',false,'motivo','prova non aperta');
  end if;
  if p_opzione is null or btrim(p_opzione) = '' then
    return jsonb_build_object('versione',1,'ok',false,'motivo','nessuna mossa da giocare');
  end if;

  -- L'elenco si RIDERIVA dallo stato vivo: non si esegue quello memorizzato.
  v_spatial:=public._esame_spatial_snapshot_v1(p_prova);
  -- Fra la scrittura dell'elenco e questa riga la prova non può essere
  -- avanzata (lo scontrino lo impedisce), ma se un giorno lo fosse, si
  -- eseguirebbe comunque ciò che è legale ADESSO.
  v_int := public._esame_png_intenzioni(p_prova)->'intenzioni';
  v_sc  := public._esame_png_traduci(v_int, p_opzione);
  if v_sc is null then
    return jsonb_build_object('versione',1,'ok',false,
                              'motivo','intenzione non disponibile');
  end if;
  if v_spatial is not null and v_sc->>'reazione'='sostituzione'
     and p_opzione is distinct from v_sc->>'intenzione_id'
     and p_opzione is distinct from v_sc->>'chiave' then
    return jsonb_build_object('versione',1,'ok',false,'motivo','seleziona l''intenzione esatta della Sostituzione');
  end if;
  if v_sc->>'rapida' is not null then
    return jsonb_build_object('versione',1,'ok',false,
                              'motivo','le azioni rapide sono state ritirate');
  end if;

  -- ── lo scontrino si consuma QUI, prima di qualunque effetto ──────────────
  update public.esame_prove
     set opzioni_png = null, opzioni_id = null, opzioni_at = null
   where id = p_prova;

  -- ── metà difensiva: la reazione risolve subito ───────────────────────────
  if v_sc->>'genere' = 'reazione' then
    return public._esame_risolvi(p_prova,
      jsonb_build_object('tipo','difesa',
                         'reazione',      v_sc->>'reazione',
                         'option_id',     v_sc->>'option_id',
                         'opzione_id',    v_sc->>'reazione',
                         'intenzione_id', v_sc->>'intenzione_id',
                         'scelta_da',     p_da),
      'png');
  end if;

  -- ── [017-R1] il diversivo: delega, e la delega è il punto ────────────────
  -- Non riscrivo qui il riposizionamento: `_esame_diversivo` è l'unico posto in
  -- cui il diversivo diventa stato, per i due lati del tavolo. Due copie della
  -- stessa regola divergono; una sola no — ed è la stessa ragione per cui il
  -- verso del movimento si calcola in un punto solo.
  --
  -- ⚠️ Sta PRIMA del movimento ordinario, e non è un dettaglio: un'intenzione
  -- di genere `diversivo` non porta mai un movimento (lo garantisce
  -- `_esame_png_intenzioni`), ma se un giorno lo portasse, eseguire il
  -- movimento e POI delegare vorrebbe dire che `_esame_diversivo` calcola il
  -- tetto anti-stallo su una distanza diversa da quella che ha visto chi ha
  -- offerto. Il rifiuto è meglio della doppia contabilità.
  if v_sc->>'genere' = 'diversivo' then
    return public._esame_diversivo(p_prova, 'png', v_sc->>'direzione', null, p_da);
  end if;

  -- ── il movimento, se il turno ne prevede uno ─────────────────────────────
  -- [ADDENDUM] la posizione la calcola `_esame_muove`: si ferma sul bersaglio,
  -- non scavalca, e rispetta il campo. Qui NON si somma più un verso ai metri —
  -- era la forma esatta del difetto, scritta sull'altro lato del tavolo.
  if v_sc->>'movimento' is not null then
    v_metri := greatest(0, coalesce((v_sc->>'metri')::numeric, 0));
    if v_spatial is not null then
      perform public._esame_spatial_move_commit_v1(p_prova,'png',v_metri,v_sc->>'movimento'='avanti',
        md5('exam-png-move|'||p_prova::text||'|'||v.scambio::text||'|'||v.meta)::uuid);
    else
    v_pos   := public._esame_bordo(public._esame_muove(v.pos_png, v.pos_candidato, v_metri::int,
                                   v_sc->>'movimento' = 'avanti'));
    -- [ADDENDUM decisione 5] una richiesta vecchia o manipolata che non
    -- cambierebbe niente si rifiuta PRIMA di consumare: lo scontrino è già
    -- stato consumato sopra, ma movimento, azione, chakra e contatori no — e
    -- non devono esserlo. Il turno resta al PNG e il ripiego lo rigioca.
    if v_pos = v.pos_png then
      return jsonb_build_object('versione',1,'ok',false,
               'motivo','quel movimento non cambierebbe la posizione');
    end if;
    end if;
    update public.esame_prove
       set pos_png = case when v_spatial is null then v_pos else pos_png end, usato_spostamento = true
     where id = p_prova;
  end if;

  -- ── la manovra: CHIUDE la metà e passa il turno al candidato ─────────────
  -- Non riapre l'elenco, non scrive uno scambio, non consuma un gradino. È
  -- l'unica forma di turno che non dichiara una principale (decisione PM 3), e
  -- `manovre_png` la conta: a due manovre consecutive il server smette di
  -- offrire l'arretramento, e da lì la distanza può solo calare.
  if v_sc->>'genere' = 'manovra' then
    update public.esame_prove
       set manovre_png       = manovre_png + 1,
           meta              = 'candidato',
           fase              = 'attacco',
           usato_principale  = false,
           usato_rapida      = false,
           usato_spostamento = false,
           -- Il candidato riceve il proprio turno: copie non usate scadono.
           copie_attive_cand = false,
           copie_scambio_cand = null
     where id = p_prova;
    return jsonb_build_object('versione',1,'ok',true,'genere','manovra',
             'intenzione', v_sc->>'intenzione_id',
             'chiave',     v_sc->>'chiave',
             'attende','azione del candidato');
  end if;

  -- ── la principale: resta in attesa della reazione del candidato ──────────
  if (v_sc->>'principale') like 'jutsu:%' then
    v_id := substring(v_sc->>'principale' from 7)::uuid;
  end if;

  update public.esame_prove
     set usato_principale = true,
         fase             = 'difesa',
         manovre_png      = 0,
         pend_azione = jsonb_build_object(
           'tipo','attacco',
           'spatial_before_version',v_spatial->'map_version',
           'principale', jsonb_build_object(
              'fonte', case when v_id is null then 'colpo' else 'jutsu' end,
              'id',    v_id),
           'opzione_id',    v_sc->>'principale',
           'intenzione_id', v_sc->>'intenzione_id',
           'chiave',        v_sc->>'chiave',
           'scelta_da',     p_da)
   where id = p_prova;

  return jsonb_build_object('versione',1,'ok',true,'genere','turno',
           'intenzione', v_sc->>'intenzione_id',
           'chiave',     v_sc->>'chiave',
           'mossa',      v_sc->>'principale',
           'attende','reazione del candidato');
end
$function$;
CREATE OR REPLACE FUNCTION public._esame_prova_azione_esegui(p_prova uuid, p_azione jsonb, p_testo text)
 RETURNS jsonb
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO 'public'
AS $function$
declare
  v public.esame_prove%rowtype; v_uid uuid := auth.uid();
  v_op jsonb; v_tipo text; v_fonte text; v_id uuid; v_sposta int; v_rapida text;
  v_reaz text; v_voce jsonb; v_maxm int; v_dist numeric; v_portata int; v_costo int; v_nome text;
  v_spatial jsonb; v_move jsonb;
  v_c public.characters%rowtype; v_opzione text; v_verso int; v_rifiuto text;
  -- [ADDENDUM] la posizione risultante, e la fotografia di INIZIO METÀ che
  -- `_esame_risolvi` scriverà nel referto. Viaggiano in `pend_azione` invece che
  -- in due colonne di `esame_prove`: è lo stesso trasporto che RUNTIME-AUDIT-011
  -- usa per `narr`, e una variabile non attraversa due transazioni.
  v_pos_new int; v_pc0 int; v_pp0 int;
  -- [038] il messaggio del candidato, salvato nella STESSA transazione
  -- dell'azione strutturata. È il fatto 1 di QA-037: due testi da 940 e
  -- 927 caratteri salvati, e `storia: []` nel payload. Erano due gesti.
  v_msg uuid; v_testo text; v_res jsonb;
begin
  perform exam_regia_private.assert_no_legacy(p_prova);
  perform 1 from public.esame_prove where id=p_prova for update;
  if exists(select 1 from public.esame_supervisione where prova=p_prova and not player_ready and not publishing) then
    raise exception 'Esito in revisione: attendi la pubblicazione dello staff';
  end if;
  if v_uid is null then raise exception 'non autenticato'; end if;
  select * into v from public.esame_prove where id = p_prova for update;
  if not found then raise exception 'La prova non esiste più'; end if;
  if v.candidate_user <> v_uid then raise exception 'Questa non è la tua prova'; end if;
  if v.stato <> 'aperta' then raise exception 'La prova non è più aperta'; end if;
  if exists (select 1 from public.esame_narrazione_cicli c
              where c.prova_id=p_prova and c.ruolo='png_esito' and c.stato='aperta') then
    raise exception 'Il narratore sta completando l''esito della tua difesa.';
  end if;
  select * into v_c from public.characters where id = v.candidate_character;

  -- ⚠️ QUI, prima di qualunque movimento: dopo, `v` viene riletta e questi
  -- due numeri sarebbero già quelli di dopo.
  v_pc0 := v.pos_candidato; v_pp0 := v.pos_png;
  v_spatial:=public._esame_spatial_snapshot_v1(p_prova);

  -- ═══ [038] IL TESTO DEL CANDIDATO, ATOMICO CON L'AZIONE ═══════════════════
  -- Prima di ogni ramo, e dentro il `for update` della prova: o entrano tutti e
  -- due o non entra nessuno dei due. Il client non può indicare un messaggio
  -- altrui perché non indica nessun messaggio — lo SCRIVE questa porta, con
  -- l'utente e il personaggio già validati sopra.
  --
  -- Il tetto è 2.500 e SOLLEVA invece di troncare: un testo tagliato è un testo
  -- rotto pubblicato in chat, e il giocatore non saprebbe perché. Il client ha
  -- già il proprio contatore; questa è la rete, non la regola.
  -- [A10 §D] Qui si CONTROLLA soltanto. La pubblicazione è più giù, nei
  -- punti in cui l'azione non può più essere rifiutata: un testo scritto
  -- prima della validazione resta in aula anche quando il gesto non è
  -- mai avvenuto, perché il rifiuto di gittata non solleva.
  v_testo := nullif(btrim(coalesce(p_testo,'')),'');
  if v_testo is not null then
    if length(v_testo) > 5000 then
      raise exception 'Il testo supera i 5.000 caratteri (ne hai scritti %).', length(v_testo);
    end if;
  end if;
  v_tipo := lower(coalesce(p_azione->>'tipo',''));
  v_op   := public._esame_prova_opzioni(p_prova, 'candidato');
  v_dist := case when v_spatial is null then abs(v.pos_png-v.pos_candidato)
                 else (v_spatial->>'distance_m')::numeric end;

  -- ── il candidato REAGISCE (metà d'attacco del PNG) ──────────────────────
  if v.meta = 'png' and v.fase = 'difesa' then
    if v_tipo <> 'difesa' then raise exception 'non è il tuo turno'; end if;
    v_reaz := lower(coalesce(p_azione->>'reazione','schivata'));
    if v_reaz = 'guardia' then
      raise exception 'La Guardia è stata ritirata: scegli una reazione di difesa.';
    end if;
    if v_reaz = 'copie' and (p_azione ? 'tecnica' or p_azione ? 'posizione') then
      raise exception 'Le copie non accettano tecnica, posizione o valori dal client.';
    end if;
    select e into v_voce from jsonb_array_elements(v_op->'reazioni') e
     where e->>'chiave'=v_reaz
       and (v_spatial is null or v_reaz<>'sostituzione' or e->>'option_id'=p_azione->>'option_id')
       and (v_reaz<>'tecnica' or e->>'id'=coalesce(p_azione->>'tecnica',''));
    if v_voce is null then raise exception 'tecnica non disponibile o non ancora attiva'; end if;
    if not coalesce((v_voce->>'disponibile')::boolean,false) then
      if v.beat < 3 and v_reaz = 'sostituzione' then
        raise exception 'In questa prova non ancora: %', v_voce->>'motivo_no';
      end if;
      if v_reaz = 'sostituzione' and v.sost_round_cand is not null then
        raise exception 'La Sostituzione non si usa due turni di fila.';
      end if;
      raise exception '%', coalesce(v_voce->>'motivo_no','tecnica non disponibile o non ancora attiva');
    end if;
    v_msg := public._esame_testo_candidato(p_prova, v_testo);   -- [A10 §D]
    return public._esame_risolvi(p_prova,
      jsonb_build_object('tipo','difesa','reazione',v_reaz,
                         'option_id',case when v_reaz='sostituzione' then v_voce->>'option_id' end,
                         'tecnica',case when v_reaz='tecnica' then v_voce->>'id' else null end,
                         'opzione_id',case when v_reaz='tecnica' then v_reaz||':'||(v_voce->>'id') else v_reaz end,
                         'scelta_da','candidato'),
      'candidato');
  end if;

  -- ── il candidato ATTACCA ────────────────────────────────────────────────
  if not (v.meta = 'candidato' and v.fase = 'attacco') then
    raise exception 'non è il tuo turno';
  end if;
  if v_tipo not in ('attacco','manovra') then raise exception 'non è il tuo turno'; end if;

  -- ── [031] nessuna principale legale: avvicina e chiude la metà ─────────────
  -- Contratto: {"tipo":"manovra","manovra":"avvicinamento"}.
  -- Il client sceglie una chiave chiusa, mai metri o posizione. La legalità
  -- viene ricalcolata dallo stato bloccato; un secondo invio serializza dietro
  -- il FOR UPDATE e trova il turno già passato.
  if v_tipo = 'manovra' then
    if (p_azione - array['tipo','manovra']::text[]) <> '{}'::jsonb then
      raise exception 'La manovra non accetta metri, posizione, tecnica o altri valori.';
    end if;
    select e into v_voce
      from jsonb_array_elements(coalesce(v_op->'manovre','[]'::jsonb)) e
     where e->>'chiave' = lower(btrim(coalesce(p_azione->>'manovra','')));
    if v_voce is null or not coalesce((v_voce->>'disponibile')::boolean,false) then
      raise exception 'manovra non disponibile: esiste ancora una continuazione legale';
    end if;

    v_maxm := (coalesce(v_c.velocita,0) / 10) * 5;
    if v_spatial is not null then
      v_move:=public._esame_spatial_move_commit_v1(p_prova,'candidato',v_maxm,true,
        md5('exam-manovra|'||p_prova::text||'|'||v.scambio::text||'|'||v.meta)::uuid);
    else
    v_pos_new := public._esame_bordo(public._esame_muove(v.pos_candidato, v.pos_png, v_maxm, true));
    if v_pos_new = v.pos_candidato then
      raise exception 'manovra non disponibile: nessun avvicinamento utile';
    end if;
    end if;

    update public.esame_prove
       set pos_candidato      = case when v_spatial is null then v_pos_new else pos_candidato end,
           -- È un cambio di distanza reale: la condotta deve vederlo, come
           -- vede il riposizionamento del Diversivo.
           spostamenti_cand   = spostamenti_cand + 1,
           meta               = 'png',
           fase               = 'attacco',
           usato_principale   = false,
           usato_rapida       = false,
           usato_spostamento  = false,
           pend_azione        = null,
           -- Nessun attacco è arrivato: le copie del PNG scadono quando
           -- comincia il successivo turno d'attacco del proprietario.
           copie_attive_png   = false,
           copie_scambio_png  = null,
           opzioni_png = null, opzioni_id = null, opzioni_at = null
     where id = p_prova
       and stato = 'aperta' and meta = 'candidato' and fase = 'attacco'
       and not usato_principale and not usato_spostamento;
    if not found then
      raise exception 'manovra già consumata o turno già passato';
    end if;

    v_msg := public._esame_testo_candidato(p_prova, v_testo);   -- [A10 §D]
    perform public._esame_png_turno(p_prova);
    return public._esame_stato_json(p_prova)
      || jsonb_build_object('manovra', jsonb_build_object(
           'genere','manovra','chiave','avvicinamento','esito','misura chiusa'));
  end if;
  if p_azione ? 'rapida' and p_azione->'rapida' is not null
     and p_azione->'rapida' <> 'null'::jsonb then
    raise exception 'La Guardia è stata ritirata: l''Esame non offre azioni rapide.';
  end if;

  -- Moltiplicazione governa da sola la propria posizione; nessun movimento
  -- separato può precederla nella stessa azione.
  if lower(coalesce(p_azione->'principale'->>'fonte',''))='moltiplicazione'
     and p_azione ? 'spostamento' then
    raise exception 'Moltiplicazione non accetta uno spostamento separato';
  end if;

  -- spostamento, se dichiarato: si applica PRIMA dell'attacco, come nel motore.
  v_sposta := coalesce((p_azione->>'spostamento')::int, 0);
  if v_sposta <> 0 then
    if v.usato_spostamento then raise exception 'hai già usato lo spostamento in questo round'; end if;
    v_maxm := coalesce((v_op->'spostamento'->>'max_metri')::int, 0);
    if abs(v_sposta) > v_maxm then
      raise exception 'con Velocità % ti muovi al massimo di % metri', v_c.velocita, v_maxm;
    end if;
    -- positivo = avvicinarsi, negativo = allontanarsi. Il client dice quanti
    -- metri e da che parte; DOVE si finisce lo decide il server, e lo decide in
    -- una sede sola — la stessa del PNG e dello scontro ordinario.
    if v_spatial is not null then
      v_move:=public._esame_spatial_move_commit_v1(p_prova,'candidato',abs(v_sposta),v_sposta>0,
        md5('exam-spostamento|'||p_prova::text||'|'||v.scambio::text||'|'||v.meta)::uuid);
    else
    v_pos_new := public._esame_bordo(public._esame_muove(v.pos_candidato, v.pos_png,
                                     abs(v_sposta), v_sposta > 0));
    -- [ADDENDUM decisione 5] zero cambiamenti = rifiuto, e PRIMA di consumare.
    -- ⚠️ `raise` e non un rifiuto silenzioso: qui siamo dentro la porta del
    -- giocatore, e un `update` a zero righe gli lascerebbe l'interfaccia ferma
    -- senza sapere perché. Non c'è nessun contatore da salvare da un rollback:
    -- fin qui la transazione non ha scritto niente.
    if v_pos_new = v.pos_candidato then
      raise exception 'Da qui quello spostamento non cambierebbe la posizione.';
    end if;
    end if;
    update public.esame_prove
       set pos_candidato = case when v_spatial is null then v_pos_new else pos_candidato end,
           usato_spostamento = true,
           spostamenti_cand = spostamenti_cand + 1
     where id = p_prova;
    select * into v from public.esame_prove where id = p_prova;
    v_dist := case when v_spatial is null then abs(v.pos_png-v.pos_candidato)
                   else (v_move->'after'->>'distance_m')::numeric end;
    v_op := public._esame_prova_opzioni(p_prova, 'candidato');
  end if;

  if v.usato_principale then raise exception 'hai già speso l''azione principale'; end if;

  -- ── [017-R1] il diversivo: una PAROLA, mai una posizione ────────────────
  -- Il client manda `{"principale":{"fonte":"diversivo","direzione":"ritirata"}}`.
  -- Non manda metri, non manda una posizione finale, e non c'è nessun parametro
  -- da cui potrebbe. La direzione si valida contro l'elenco che il server ha
  -- appena calcolato: è la stessa forma dello scontrino del Narratore.
  if lower(coalesce(p_azione->'principale'->>'fonte','')) = 'diversivo' then
    select e into v_voce from jsonb_array_elements(v_op->'diversivi') e
     where e->>'chiave' = lower(btrim(coalesce(p_azione->'principale'->>'direzione','')));
    if v_voce is null then
      raise exception 'quella direzione non è fra quelle offerte in questo momento';
    end if;
    if not coalesce((v_voce->>'disponibile')::boolean, false) then
      raise exception '%', coalesce(v_voce->>'motivo_no', 'quel diversivo non è disponibile adesso');
    end if;
    v_msg := public._esame_testo_candidato(p_prova, v_testo);   -- [A10 §D]
    v_res := public._esame_diversivo(p_prova, 'candidato', v_voce->>'chiave',
                                     (v_voce->>'id')::uuid, 'candidato');
    if not coalesce((v_res->>'ok')::boolean, false) then
      raise exception '%', coalesce(v_res->>'motivo', 'diversivo rifiutato');
    end if;
    return v_res;
  end if;

  v_fonte := lower(coalesce(p_azione->'principale'->>'fonte','colpo'));

  if v_fonte='moltiplicazione' then
    if ((p_azione->'principale') - array['fonte','id','modalita','copie','direzione','originale_idx']::text[])<>'{}'::jsonb then
      raise exception 'Moltiplicazione contiene campi non autorizzati';
    end if;
    v_msg := public._esame_testo_candidato(p_prova, v_testo);   -- [A10 §D]
    return public._esame_moltiplicazione_candidato(
      p_prova,p_azione->'principale'->>'modalita',
      nullif(p_azione->'principale'->>'copie','')::integer,
      p_azione->'principale'->>'direzione',
      nullif(p_azione->'principale'->>'originale_idx','')::integer);
  end if;

  if v_fonte = 'scena' then
    v_id := nullif(p_azione->'principale'->>'id','')::uuid;
    select e into v_voce
      from jsonb_array_elements(coalesce(v_op->'principali','[]'::jsonb)) e
     where e->>'fonte' = 'scena' and (e->>'id')::uuid = v_id;
    if v_voce is null or not coalesce((v_voce->>'disponibile')::boolean,false) then
      raise exception '%', coalesce(v_voce->>'motivo_no','tecnica di scena non disponibile');
    end if;
    v_costo := coalesce((v_voce->>'chakra')::int,0);
    v_nome := v_voce->>'nome';
    if v_costo > v.ck_cand then
      raise exception 'Chakra insufficiente: servono % (ne hai %)', v_costo, v.ck_cand;
    end if;

    update public.esame_prove
       set ck_cand = greatest(0, ck_cand - v_costo),
           meta = 'png', fase = 'attacco',
           usato_principale = false, usato_rapida = false, usato_spostamento = false,
           pend_azione = null, opzioni_png = null, opzioni_id = null, opzioni_at = null
     where id = p_prova and stato = 'aperta' and meta = 'candidato' and fase = 'attacco';
    if not found then raise exception 'turno già passato'; end if;
    v_msg := public._esame_testo_candidato(p_prova, v_testo);   -- [A10 §D]
    perform public._esame_png_turno(p_prova);
    return public._esame_stato_json(p_prova)
      || jsonb_build_object('tecnica_scena', jsonb_build_object(
           'id',v_id,'nome',v_nome,'chakra_speso',v_costo,'danno',0));
  end if;

  if v_fonte = 'colpo' then
    v_portata := 2; v_costo := 0; v_opzione := 'colpo';
    if v_dist > v_portata then
      -- ⚠️ SCELTA DICHIARATA, e ratificabile dal PM. Qui NON si solleva: si
      --    registra il rifiuto e si restituisce la frase del motore. È il solo
      --    modo perché l'osservazione «ha attaccato da fuori portata più di una
      --    volta» (§7.2) possa scattare: un'eccezione annulla la transazione e
      --    con essa il contatore, e l'osservazione non scatterebbe mai — cioè
      --    il difetto che la R1.2 ha appena tolto dall'altra riga del §7.2.
      --    Nulla viene speso e la prova non avanza.
      v_rifiuto := v_c.name || ' è a ' || v_dist || ' metri: «Colpo a mani nude» arriva a ' || v_portata || '.';
      update public.esame_prove set rifiuti_gittata = rifiuti_gittata + 1 where id = p_prova;
      return public._esame_stato_json(p_prova) || jsonb_build_object('rifiuto', v_rifiuto);
    end if;
  elsif v_fonte in ('jutsu','clan','innata') then
    v_id := nullif(p_azione->'principale'->>'id','')::uuid;
    select e into v_voce from jsonb_array_elements(v_op->'principali') e where (e->>'id')::uuid = v_id;
    if v_voce is null then
      select e into v_voce from jsonb_array_elements(v_op->'innate') e where (e->>'id')::uuid = v_id;
    end if;
    if v_voce is null then
      -- [017-R1] il rifiuto PARLANTE: la tecnica esiste, il giocatore ce l'ha,
      -- ma non è un attacco. Senza questo ramo il messaggio sarebbe «tecnica
      -- non disponibile», che è vero e inutile — e il pulsante di oggi manda
      -- proprio questo.
      if exists (select 1 from public.jutsu j
                  where j.id = v_id and j.is_active and coalesce(j.diversivo,false)) then
        raise exception '«%» non è un attacco: crea copie illusorie per coprire uno spostamento. Si gioca scegliendo una direzione.',
          (select name_it from public.jutsu where id = v_id);
      end if;
      -- [042-B0] il rifiuto PARLANTE per la tecnica di scena: esiste, il
      -- candidato la possiede, ma non è un attacco.
      if exists (select 1 from public.jutsu j
                  where j.id = v_id and j.is_active and coalesce(j.di_scena,false)) then
        raise exception '«%» è una tecnica di scena: si usa fuori dallo scontro e non può essere dichiarata come attacco.',
          (select name_it from public.jutsu where id = v_id);
      end if;
      raise exception 'tecnica non disponibile o non ancora attiva';
    end if;
    v_portata := coalesce((v_voce->>'portata_m')::int, 30);
    v_costo   := coalesce((v_voce->>'chakra')::int, 0);
    v_opzione := 'jutsu:' || v_id::text;
    if v_dist > v_portata then
      v_rifiuto := v_c.name || ' è a ' || v_dist || ' metri: «' || (v_voce->>'nome') || '» arriva a ' || v_portata || '.';
      update public.esame_prove set rifiuti_gittata = rifiuti_gittata + 1 where id = p_prova;
      return public._esame_stato_json(p_prova) || jsonb_build_object('rifiuto', v_rifiuto);
    end if;
    if v_costo > v.ck_cand then
      raise exception 'Chakra insufficiente: servono % (ne hai %)', v_costo, v.ck_cand;
    end if;
    if not coalesce((v_voce->>'disponibile')::boolean,false) then
      raise exception '%', coalesce(v_voce->>'motivo_no','tecnica non disponibile o non ancora attiva');
    end if;
  else
    raise exception 'tecnica non disponibile o non ancora attiva';
  end if;

  -- L'attacco è dichiarato: resta in attesa della reazione del PNG. Il turno
  -- del PNG non dipende dal browser (§7.3): lo spinge esame_prova_tick.
  update public.esame_prove
     set usato_principale = true,
         fase = 'difesa',
         pend_azione = jsonb_build_object(
           'tipo','attacco',
           'principale', jsonb_build_object('fonte', v_fonte, 'id', v_id),
           'opzione_id', v_opzione, 'scelta_da', 'candidato',
           'spatial_before_version',v_spatial->'map_version',
           'pos_cand_prima', case when v_spatial is null then v_pc0 end,
           'pos_png_prima', case when v_spatial is null then v_pp0 end)
   where id = p_prova;

  v_msg := public._esame_testo_candidato(p_prova, v_testo);   -- [A10 §D]
  perform public._esame_png_turno(p_prova);
  return public._esame_stato_json(p_prova);
end
$function$;
CREATE OR REPLACE FUNCTION public._esame_risolvi(p_prova uuid, p_azione jsonb, p_chi text)
 RETURNS jsonb
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO 'public'
AS $function$
declare
  v public.esame_prove%rowtype;
  v_prof public.esame_png_profili%rowtype;
  v_c public.characters%rowtype;
  v_att jsonb;                       -- l'attacco dichiarato e in attesa
  v_chi_att text; v_png_att boolean;
  v_kind text := 'fisico'; v_base int := 0; v_tech text := 'Colpo a mani nude';
  v_elem text; v_gittata text := 'contatto'; v_portata int := 2;
  v_reaz text; v_dif_disc text; v_dif_tech text;
  v_a jsonb; v_d jsonb; v_calc jsonb;
  v_dist numeric; v_dado_a int; v_dado_d int;
  v_spatial_before jsonb; v_spatial_after jsonb;
  v_spatial_start jsonb; v_spatial_event uuid;
  v_pv int; v_pv_max int; v_slancio int; v_slancio_next int;
  v_ck_costo int := 0; v_ck_reaz int := 0;
  v_ordine int; v_colpito boolean; v_striscio boolean; v_appl int; v_ko boolean := false;
  v_nome_att text; v_nome_dif text; v_esito text; v_base_frase text; v_frase text;
  v_loc uuid; v_copie_attive boolean := false; v_esito_copie text;
  v_assalto boolean := false; v_copie_att int := 0; v_mod_assalto int := 0; v_esito_assalto text;
  v_originale_idx int := 0; v_bersaglio_idx int := 0;
  -- [038] la ricevuta del ciclo, la riga di scambio appena scritta e il
  -- testo composto. `v_frase` resta: è ancora la voce del ripiego.
  v_ciclo public.esame_narrazione_cicli%rowtype; v_scambio_id uuid;
  v_app text; v_testo text; v_mid uuid; v_ruolo_png text;
  v_esito_ciclo uuid; v_esito_ricevuta uuid;
  v_finale boolean := false; v_finale_tipo text; v_senza_forze jsonb;
  v_scambio_risolto int;
  -- [BANCO 038] l'intestazione AZIONE e l'etichetta chiusa della
  -- reazione, per il ripiego in difesa.
  v_az text; v_et text; v_referto jsonb; v_dist_lab text; v_danno_lab text;
  v_sost_comune jsonb;
  -- [001] la ricevuta arricchita: bersaglio, conseguenza, gravità, ancora,
  -- movimento, iniziativa — fatti del server, in parole.
  v_zona text; v_conseg text; v_grav text; v_ancora jsonb; v_pos_dif int;
  v_movimento text; v_pc_prima int; v_pp_prima int;
begin
  perform exam_regia_private.assert_no_legacy(p_prova);
  select * into v from public.esame_prove where id = p_prova for update;
  if not found then raise exception 'La prova non esiste più'; end if;
  v_spatial_before:=public._esame_spatial_snapshot_v1(p_prova);
  if v_spatial_before is null then
    return public._esame_risolvi_legacy_v1(p_prova,p_azione,p_chi);
  end if;
  if v.stato <> 'aperta' then raise exception 'La prova non è più aperta'; end if;
  select * into v_prof from public.esame_png_profili where id = v.profilo_id;
  select * into v_c from public.characters where id = v.candidate_character;
  select location_id into v_loc from public.academy_class_sessions where id = v.class_session_id;

  v_att := coalesce(v.pend_azione, '{}'::jsonb);
  v_chi_att := case when v.meta = 'png' then 'png' else 'candidato' end;
  v_png_att := (v_chi_att = 'png');
  if lower(coalesce(p_chi,'')) = v_chi_att then
    raise exception 'Chi attacca non può anche reagire: la metà di scambio è mal composta.';
  end if;

  v_nome_att := case when v_png_att then v_prof.nome else v_c.name end;
  v_nome_dif := case when v_png_att then v_c.name else v_prof.nome end;
  v_dist := (v_spatial_before->>'distance_m')::numeric;

  -- ── che cosa attacca ────────────────────────────────────────────────────
  -- ── [017-R1] la terza rete: un diversivo non arriva MAI fin qui ─────────
  -- Gli unici scrittori di `pend_azione` sono `esame_prova_azione` e
  -- `_esame_png_gioca`, ed entrambi sono guardati. Se questo ramo si accende, un
  -- chiamante è regredito — e la scelta è fra una prova ferma e una prova che
  -- infligge danno con una tecnica che per regolamento non ne fa.
  -- ⚠️ SOLLEVA di proposito: scostamento dichiarato (§3 di
  -- `03_DECISIONI_E_SCOSTAMENTI.md`). Una prova ferma si vede; il danno
  -- silenzioso è esattamente il difetto che stiamo chiudendo.
  if (v_att->'principale'->>'fonte') = 'jutsu'
     and exists (select 1 from public.jutsu j
                  where j.id = (v_att->'principale'->>'id')::uuid
                    and coalesce(j.diversivo,false)) then
    raise exception 'Un diversivo non può essere risolto come attacco: la metà è mal composta.';
  end if;

  -- [042-B0] gemella, per la tecnica di scena.
  if (v_att->'principale'->>'fonte') = 'jutsu'
     and exists (select 1 from public.jutsu j
                  where j.id = (v_att->'principale'->>'id')::uuid
                    and coalesce(j.di_scena,false)) then
    raise exception 'Una tecnica di scena non può essere risolta come attacco: la metà è mal composta.';
  end if;

  v_assalto := (v_att->'principale'->>'fonte')='moltiplicazione'
               and (v_att->'principale'->>'modalita')='assalto';
  if v_assalto then
    v_kind:='fisico'; v_base:=10; v_tech:='Moltiplicazione del corpo · Assalto';
    v_elem:=null; v_gittata:='contatto'; v_portata:=2; v_ck_costo:=0;
    v_copie_att:=greatest(1,least(4,coalesce((v_att->'principale'->>'copie')::int,1)));
    v_originale_idx:=coalesce((v_att->'principale'->>'originale_idx')::int,0);
    if v_originale_idx<1 or v_originale_idx>v_copie_att+1 then
      raise exception 'L''Assalto non contiene un originale valido.';
    end if;
    v_bersaglio_idx:=1+mod(public._esame_dado(
      v.seme,public._esame_indice(v.scambio,v.meta,v_chi_att,'assalto')),v_copie_att+1);
    if v_bersaglio_idx=v_originale_idx then
      v_esito_assalto:='originale_individuato'; v_mod_assalto:=0;
    else
      v_esito_assalto:='copia_colpita'; v_mod_assalto:=public._copie_bonus(v_copie_att);
    end if;
  elsif (v_att->'principale'->>'fonte') = 'jutsu' then
    select lower(j.category), coalesce(j.damage_base,0), j.name_it, j.nature,
           coalesce(j.gittata,'media'), public._fascia_metri(coalesce(j.gittata,'media')),
           coalesce(j.chakra_cost,0)
      into v_kind, v_base, v_tech, v_elem, v_gittata, v_portata, v_ck_costo
      from public.jutsu j where j.id = (v_att->'principale'->>'id')::uuid;
  else
    v_kind := 'fisico'; v_base := 10; v_tech := 'Colpo a mani nude';
    v_elem := null; v_gittata := 'contatto'; v_portata := 2; v_ck_costo := 0;
  end if;

  -- ── come si reagisce ────────────────────────────────────────────────────
  v_reaz := lower(coalesce(p_azione->>'reazione','schivata'));
  if v_reaz not in ('schivata','parata','sostituzione','tecnica','copie') then
    raise exception 'reazione non valida';
  end if;
  if v_reaz = 'sostituzione' then
    v_sost_comune := public._esame_sostituzione_commit_comune_v1(
      p_prova,
      nullif(p_azione->>'option_id','')::uuid,
      p_chi
    );
    v_spatial_after:=public._esame_spatial_snapshot_v1(p_prova);
  end if;
  v_copie_attive := case when v_png_att then coalesce(v.copie_attive_cand,false)
                         else coalesce(v.copie_attive_png,false) end;
  if v_reaz = 'copie' and not v_copie_attive then
    raise exception 'Le copie non sono più attive.';
  end if;
  if v_reaz = 'sostituzione' then
    -- [V1.1 · decisione 11] il costo si legge dalla riga vera, non si scrive 0.
    select j.name_it, lower(j.category), coalesce(j.chakra_cost,0)
      into v_dif_tech, v_dif_disc, v_ck_reaz
      from public.jutsu j
     where j.is_active and j.difensiva and j.action_type = 'reazione' limit 1;
    v_dif_tech := coalesce(v_dif_tech, 'Sostituzione');
    v_dif_disc := coalesce(v_dif_disc, 'ninjutsu');
  elsif v_reaz='tecnica' then
    if v_kind<>'genjutsu' then
      raise exception 'Dispersione si usa soltanto come difesa da un Genjutsu.';
    end if;
    select j.name_it,lower(j.category),coalesce(j.chakra_cost,0)
      into v_dif_tech,v_dif_disc,v_ck_reaz
      from public.jutsu j
     where j.id=nullif(p_azione->>'tecnica','')::uuid
       and j.is_active and j.name_it='Dispersione' and j.uso='difesa' and j.difensiva
       and ((v_png_att and exists(select 1 from public.character_jutsu cj
                                  where cj.jutsu_id=j.id and cj.user_id=v.candidate_user))
         or (not v_png_att and j.id=any(v_prof.repertorio)))
     limit 1;
    if v_dif_tech is null then
      raise exception 'Dispersione non posseduta o non disponibile.';
    end if;
  end if;

  -- ── i dadi: deterministici, dal seme della prova ────────────────────────
  v_dado_a := public._esame_dado(v.seme, public._esame_indice(v.scambio, v.meta, v_chi_att, 'att'));
  v_dado_d := public._esame_dado(v.seme, public._esame_indice(v.scambio, v.meta, v_chi_att, 'dif'));

  -- ── i due corpi, con lo Slancio dentro il json dell'ATTACCANTE ──────────
  v_slancio := case when v_png_att then v.slancio_png else v.slancio_cand end;
  if v_png_att then
    v_a := public._esame_corpo_json(v.profilo_id, v_slancio);
    v_d := public._esame_char_json(v.candidate_character, 0);
  else
    v_a := public._esame_char_json(v.candidate_character, case when v_assalto then 0 else v_slancio end);
    v_d := public._esame_corpo_json(v.profilo_id, 0);
  end if;

  v_d := v_d || jsonb_build_object('copie_n',case when v_png_att then v.copie_n_cand else v.copie_n_png end);
  v_calc := public._combat_calcola(
    v_kind, v_a, v_d, v_reaz, v_dif_disc, v_base, v_elem,
    v_dado_a, v_dado_d, v_mod_assalto, 0, false);

  if v_assalto and v_esito_assalto='copia_colpita' then
    v_d := v_d || jsonb_build_object(
      'velocita',0,'taijutsu',0,'mente',0,'ninjutsu',0,'genjutsu',0,'fuuinjutsu',0,'copie_n',0);
    v_calc := public._combat_calcola(
      v_kind,v_a,v_d,'nessuna',null,v_base,v_elem,
      v_dado_a,0,0,0,false);
  end if;

  v_colpito  := (v_calc->>'colpito')::boolean;
  v_striscio := (v_calc->>'striscio')::boolean;
  v_appl     := (v_calc->>'danno_applicato')::int;
  if v_reaz = 'sostituzione' then
    v_colpito := false;
    v_striscio := false;
    v_appl := 0;
  end if;
  v_esito_copie := case when v_assalto then v_esito_assalto else nullif(v_calc->>'esito_copie','') end;

  -- ── le risorse SIMULATE: qui, e in nessun altro posto ───────────────────
  if v_png_att then
    v_pv := greatest(0, v.pv_cand - v_appl);  v_pv_max := v.pv_cand_max;
  else
    v_pv := greatest(0, v.pv_png  - v_appl);  v_pv_max := v.pv_png_max;
  end if;
  v_ko := (v_pv = 0);

  -- [001] i fatti in parole, decisi QUI e scritti sullo scambio.
  v_danno_lab := case when v_ko then 'fuori combattimento'
                      when v_appl = 0 then 'nessuno'
                      when v_appl <= greatest(1, v_pv_max / 10) then 'lieve'
                      when v_appl <= greatest(1, v_pv_max / 4) then 'serio'
                      else 'grave' end;
  v_zona   := case when not v_png_att then public._esame_zona_dichiarata((select m.body from public.esame_narrazione_cicli c2 join public.messages m on m.id = c2.pg_message_id  where c2.prova_id = p_prova and c2.ruolo = 'png_difende' order by c2.created_at desc limit 1), v.seme, public._esame_indice(v.scambio, v.meta, v_chi_att, 'att')) end;
  v_zona   := coalesce(v_zona, public._esame_zona(v.seme, v.scambio, v.meta, v_chi_att, v_kind)); -- [005] testo del candidato prima del dado
  v_grav   := case when v_colpito or v_striscio or v_ko then v_danno_lab else 'nessuno' end;
  v_conseg := case when v_colpito or v_striscio or v_ko
                   then public._esame_conseguenza(v_danno_lab, v_zona, v_ko) else 'nessuna' end;
  v_pos_dif := case when v_png_att then v.pos_candidato else v.pos_png end;
  v_ancora := case when v_reaz = 'sostituzione' then jsonb_build_object(
    'id', v_sost_comune#>>'{exchange_identity,substitution_event_id}',
    'nome', coalesce(v_sost_comune#>>'{narrator_projection,anchor_semantic_label}',
                     'ancora autorizzata'),
    'esito', 'consumed_non_substitutable'
  ) else null end;

  -- ── lo Slancio, con la regola del motore: +3 se non va a segno, tetto 9 ──
  if v_colpito then v_slancio_next := 0; else v_slancio_next := least(9, v_slancio + 3); end if;

  select coalesce(max(ordine),0) + 1 into v_ordine from public.esame_scambi where prova_id = p_prova;

  insert into public.esame_scambi (
    prova_id, profilo_id, scambio, meta, ordine, chi_attacca,
    attacker_name, defender_name, kind, tech_name, base, elemento, gittata, distanza,
    reazione, dif_tech_name, dif_disciplina,
    pool_att, pool_dif, dado_att, dado_dif, mod_mira, mod_guardia, mod_colto,
    mod_elem_att, mod_elem_dif, atk_tot, def_tot, margine, bonus_margine, off,
    riduzione_div, riduzione, danno_grezzo, danno_applicato, cap_attivo, colpito, ko,
    chakra_dichiarato, striscio, mod_slancio, slancio_successivo, esito_copie,
    opzione_scelta, scelta_da,
    pos_cand_prima, pos_png_prima, pos_cand, pos_png,
    bersaglio, conseguenza, gravita, ancora)
  values (
    p_prova, v.profilo_id, v.scambio, v.meta, v_ordine, v_chi_att,
    v_nome_att, v_nome_dif, v_kind, v_tech, v_base, v_elem, v_gittata, v_dist,
    v_reaz, v_dif_tech, v_dif_disc,
    (v_calc->>'pool_att')::int, (v_calc->>'pool_dif')::int,
    (v_calc->>'dado_att')::int, (v_calc->>'dado_dif')::int,
    (v_calc->>'mod_mira')::int, (v_calc->>'mod_guardia')::int, (v_calc->>'mod_colto')::int,
    (v_calc->>'mod_elem_att')::int, (v_calc->>'mod_elem_dif')::int,
    (v_calc->>'atk_tot')::int, (v_calc->>'def_tot')::int, (v_calc->>'margine')::int,
    (v_calc->>'bonus_margine')::int, (v_calc->>'off')::int,
    (v_calc->>'riduzione_div')::int, (v_calc->>'riduzione')::int,
    (v_calc->>'danno_grezzo')::int, v_appl, (v_calc->>'cap_attivo')::boolean,
    v_colpito, v_ko,
    v_ck_costo, v_striscio, (v_calc->>'mod_slancio')::int, v_slancio_next, v_esito_copie,
    coalesce(v_att->>'opzione_id', p_azione->>'opzione_id'),
    coalesce(v_att->>'scelta_da', p_azione->>'scelta_da', 'candidato'),
    -- «prima» viaggia dentro `pend_azione`, scritto da chi ha aperto la metà;
    -- se manca (una metà aperta da un corpo vecchio) si ripiega sullo stato di
    -- adesso, che è onesto: dice «non risulta nessun movimento».
    null, null, null, null,
    v_zona, v_conseg, v_grav, v_ancora->>'id')
  returning id into v_scambio_id;

  -- ── la voce: si racconta con le parole di riserva se l'IA non ha parlato ─
  v_esito := case
    when v_esito_copie = 'copia_colpita' then 'copia_colpita'
    when v_esito_copie = 'originale_individuato' then 'originale_individuato'
    when v_reaz = 'sostituzione' and not v_colpito then 'sostituito'
    when v_colpito then 'colpito'
    when v_striscio then 'sfiorato'
    when v_reaz = 'parata' then 'parato'
    when v_reaz = 'schivata' then 'schivato'
    else 'mancato' end;
  -- ═══ [038] LA VOCE UNICA · si pubblica SOLO la branca che è accaduta ═══
  --
  -- 🔴 Che cosa faceva questo blocco, e perché era sbagliato in due modi:
  --    (a) pubblicava con `_esame_post(v_loc, v_prof.nome, …)`, cioè con il
  --        NOME DEL PNG come autore — il difetto che il contratto chiude;
  --    (b) la guardia `if v_png_att` faceva sì che una difesa del PNG non
  --        venisse MAI narrata. È il fatto 2 di QA-037: «difesa complessa,
  --        nessun esito narrato». Non era una svista del modello: era questa
  --        riga.
  --
  -- Adesso: la prosa della branca reale viene dalla ricevuta, l'appendice la
  -- costruisce il server, e l'autore è sempre e solo «Il narratore».
  v_base_frase := (case when v_png_att then 'png_att' else 'cand_att' end) || '.'
               || (case when v_kind = 'fisico' then 'colpo' else 'tecnica' end) || '.' || v_esito;

  v_app := public._esame_appendice(v_scambio_id, public._esame_ciclo_numeri());

  -- La ricevuta viva di questo ciclo. `accettata` = il modello ha parlato ed è
  -- stato validato; `ripiego` = il modello è muto e la voce viene dal catalogo.
  select * into v_ciclo from public.esame_narrazione_cicli
   where prova_id = p_prova and stato in ('accettata','ripiego')
   order by created_at desc, id desc limit 1;

  if v_ciclo.id is not null
     and v_ciclo.stato = 'accettata'
     and v_ciclo.esiti ? v_esito then
    -- ⚠️ Il sigillo si ricontrolla QUI, sotto lock, prima di pubblicare. Non
    --    difende da un attaccante — chi scrive la tabella riscrive il sigillo —
    --    difende da NOI: una migrazione futura che tocchi `esiti` senza passare
    --    dal validatore fa diventare rossa la ricevuta invece di pubblicare
    --    prosa che nessuno ha validato.
    if v_ciclo.receipt_sha256 is distinct from public._esame_ricevuta_sigillo(
         v_ciclo.opzioni_id, v_ciclo.intenzione_id, v_ciclo.azione_png,
         v_ciclo.esiti, v_ciclo.esiti_attesi) then
      raise exception 'La ricevuta % non corrisponde al proprio sigillo: non pubblico.', v_ciclo.opzioni_id;
    end if;
    v_frase := v_ciclo.esiti->>v_esito;
  else
    -- Il ripiego: la frase del catalogo, con la regola di sempre. La differenza
    -- col passato è che adesso esce in TUTTI E DUE i ruoli, non solo quando il
    -- PNG attaccava.
    v_frase := public._esame_frase(p_prova, v_base_frase, v_ordine,
                 jsonb_build_object('attaccante', v_nome_att, 'difensore', v_nome_dif, 'tecnica', v_tech));
  end if;

  v_ruolo_png := coalesce(v_ciclo.ruolo, case when v_png_att then 'png_attacca' else 'png_difende' end);

  if v_frase is not null and btrim(v_frase) <> '' then
    if v_ruolo_png = 'png_difende' then
      -- UN messaggio solo: AZIONE + ESITO. L'azione è già stata validata e non
      -- è mai stata pubblicata da sola — è il punto del contratto §3.
      --
      -- 🔴 [BANCO 038 · difetto 5] IL RIPIEGO IN DIFESA HA LA STESSA FORMA.
      --    Col modello muto `azione_png` è nullo, e il ramo `else ''` faceva
      --    uscire il SOLO `ESITO`: due forme diverse per lo stesso momento
      --    della scena, e un'asimmetria col ripiego in attacco — che l'AZIONE
      --    la scrive, e per una ragione dichiarata («senza, il candidato
      --    riceverebbe un turno da difendere senza avere letto nessun
      --    attacco»). Qui vale identica: senza AZIONE il giocatore non legge
      --    mai che cosa il PNG ha TENTATO, solo com'è finita.
      --    L'etichetta è testo chiuso, e si legge dalla stessa porta che offre
      --    le reazioni: due elenchi delle stesse parole divergono.
      -- 🔴 «Kazane parata.» muore qui. Non era una frase: era un'etichetta con
      --    un punto in fondo, e attaccata alla prosa del modello produceva due
      --    voci nello stesso messaggio. Il ripiego adesso scrive una frase
      --    intera, con soggetto e verbo, scelta da un elenco CHIUSO del server.
      if coalesce(btrim(v_ciclo.azione_png),'') <> '' then
        v_az := btrim(v_ciclo.azione_png);
      else
        v_az := v_nome_dif || case lower(coalesce(v_reaz,''))
                  when 'parata'       then ' porta le braccia a coprirsi.'
                  when 'schivata'     then ' sposta il peso per uscire dalla traiettoria.'
                  when 'sostituzione' then ' tenta la Sostituzione.'
                  when 'copie'        then ' lascia che le sagome gli si chiudano davanti.'
                  else                     ' reagisce.' end;
      end if;
      -- 🔴 [A5] L'APPENDICE NON SI PUBBLICA PIÙ, NÉ IN MEZZO NÉ IN CODA.
      --    La A4 l'aveva spostata dopo la chiusura narrativa e questo bastava
      --    a togliere il difetto dell'INTERRUZIONE, non quello che Antonello
      --    aveva segnalato: «l'esito dev'essere prosa uniforme dal principio
      --    alla fine». Un tag `((Riuji → Kazane · Colpo · 0 m))` in fondo al
      --    messaggio resta un referto tecnico dentro la chat, e resta la cosa
      --    che rompe la voce del Narratore.
      --
      -- 🟢 `v_app` NON sparisce: continua a essere calcolata e finisce
      --    integra dentro `v_referto.appendice`, che è l'audit. Cambia solo
      --    che cosa vede il giocatore. Il referto autoritativo non si perde —
      --    era il vincolo esplicito della review.
      v_testo := regexp_replace(
        concat_ws(' ', public._esame_chiudi(v_az), public._esame_chiudi(v_frase)),
        '[[:space:]]+', ' ', 'g');
    else
      -- Il PNG aveva attaccato: l'AZIONE è già in chat da minuti, e qui esce
      -- soltanto l'ESITO — dalla STESSA risposta modello, senza una seconda
      -- chiamata. È il §4 del contratto.
      -- [A5] anche qui: solo prosa. L'appendice vive nel referto.
      v_testo := regexp_replace(
        public._esame_chiudi(v_frase),
        '[[:space:]]+', ' ', 'g');
    end if;
    -- [095/27] L'esito di una difesa del candidato non viene pubblicato
    -- prima che il Narratore abbia ricevuto il testo reale della difesa.
    v_mid := null;
  end if;

  -- La ricevuta si CONSUMA: una seconda difesa non può pubblicare un secondo
  -- ESITO (gate E-25).
  --
  -- ⚠️ CORREZIONE DEL BANCO (inversione D7a). La prima stesura di questo
  --    commento diceva che `where stato in (…)` era «la condizione che rende
  --    l'aggiornamento idempotente». È FALSO, e l'inversione lo ha dimostrato:
  --    toglierla non accende niente, perché la SELECT che carica `v_ciclo`
  --    dieci righe più su filtra GIÀ sugli stessi due stati — quindi qui la
  --    riga è codice morto difensivo, non la guardia.
  --    La guardia vera è quella SELECT, insieme al `for update` sulla prova.
  --    La riga resta perché costa nulla e protegge da una riscrittura futura
  --    della SELECT, ma chiamarla «la condizione» era esattamente il genere di
  --    commento che fa cercare il difetto nel posto sbagliato.
  -- ── il REFERTO: i fatti chiusi, senza un solo numero autoritativo ──────
  if v_reaz = 'sostituzione' then
    v_et := 'Sostituzione · ' || coalesce(
      v_sost_comune#>>'{narrator_projection,anchor_semantic_label}',
      'ancora autorizzata'
    );
  else
    select e->>'nome' into v_et
      from jsonb_array_elements(
             public._esame_prova_opzioni(p_prova,
               case when v_png_att then 'candidato' else 'png' end)->'reazioni') e
     where e->>'chiave' = v_reaz;
  end if;

  v_spatial_after:=coalesce(v_spatial_after,public._esame_spatial_snapshot_v1(p_prova));
  v_spatial_start:=public._esame_spatial_snapshot_version_v1(p_prova,
    coalesce((v_att->>'spatial_before_version')::int,(v_spatial_before->>'map_version')::int));
  select se.event_id into strict v_spatial_event from combat_spatial.spatial_events se
    where se.instance_id=(v_spatial_after->>'instance_id')::uuid
      and (se.after_state->'exam_spatial'->>'map_version')::int=(v_spatial_after->>'map_version')::int;
  v_movimento := coalesce(nullif(concat_ws('; ',
    case when v_spatial_start->'candidate' is distinct from v_spatial_after->'candidate'
      then v_c.name||' ha cambiato posizione' end,
    case when v_spatial_start->'png' is distinct from v_spatial_after->'png'
      then v_prof.nome||' ha cambiato posizione' end), ''), 'nessuno');
  v_dist_lab := case when v_dist <= 2 then 'a contatto'
                     when v_dist <= 10 then 'a corta distanza'
                     when v_dist <= 30 then 'a media distanza'
                     else 'a lunga distanza' end;
  v_danno_lab := case when v_ko then 'fuori combattimento'
                      when v_appl = 0 then 'nessuno'
                      when v_appl <= greatest(1, v_pv_max / 10) then 'lieve'
                      when v_appl <= greatest(1, v_pv_max / 4) then 'serio'
                      else 'grave' end;
  v_referto := jsonb_build_object(
    '_spatial_audit',jsonb_build_object('scambio_id',v_scambio_id,'event_id',v_spatial_event,
      'before_version',v_spatial_start->'map_version','impact_version',v_spatial_before->'map_version',
      'after_version',v_spatial_after->'map_version'),
    'ruolo_png',      v_ruolo_png,
    'attaccante',     v_nome_att,
    'difensore',      v_nome_dif,
    'tecnica',        v_tech,
    'genere_attacco', v_kind,
    'reazione',       v_reaz,
    'reazione_nome',  coalesce(v_et, 'una reazione'),
    'esito',          v_esito,
    'colpito',        v_colpito,
    'di_striscio',    v_striscio,
    'fuori_combattimento', v_ko,
    'danno',          v_danno_lab,
    'distanza',       v_dist_lab,
    'appendice',      nullif(btrim(coalesce(v_app,'')),''),
    -- [001] la ricevuta arricchita (P1): fatti del server, solo parole.
    'bersaglio',      v_zona,
    'bersaglio_su',   case when v_esito_copie = 'copia_colpita' then 'una copia di ' || v_nome_dif else v_nome_dif end,
    'conseguenza',    v_conseg,
    'gravita',        v_grav,
    'postura_difensore', case when v_colpito or v_ko then public._esame_postura(v_danno_lab, v_ko) else 'in guardia' end,
    'movimento',      v_movimento,
    'iniziativa',     case when v_png_att then 'passa a ' || v_nome_dif else 'passa a ' || v_nome_att end,
    'scambio',        case v.scambio when 1 then 'primo' when 2 then 'secondo' when 3 then 'terzo' else 'ultimo' end,
    'ancora',         v_ancora,
    'segni',          public._esame_segni(p_prova, v_ordine));

  if v_ciclo.id is not null then
    update public.esame_narrazione_cicli
       -- [090-CICLI:2:INIZIO]
     -- Se il motore ha prodotto un esito che l'elenco congelato non
     -- prevedeva, l'elenco si AMPLIA invece di far saltare la transazione.
     -- L'esito e' legittimo per costruzione: viene da `_esame_esiti_reazione`
     -- della reazione davvero giocata. Il CHECK resta severo com'era:
     -- cambia chi lo rispetta, non quanto e' severo.
     -- ⚠️ Nella stessa UPDATE il lato destro legge la riga VECCHIA, quindi
     --    `esiti_attesi` qui e' ancora quello di prima: ed e' cio' che serve.
     -- ⚠️ `array_append` e non `esiti_attesi || v_esito`: Postgres legge il
     --    secondo come array||array e fallisce con «malformed array literal».
     --    E' la trappola §3 delle convenzioni, ripresa in flagrante dal banco.
     set stato = 'risolta',
         esiti_attesi = case when v_esito = any(esiti_attesi) then esiti_attesi
                             else (select array_agg(distinct x order by x)
                                     from unnest(array_append(esiti_attesi, v_esito)) x) end,
         esiti_ampliati = esiti_ampliati or not (v_esito = any(esiti_attesi)),
         esito_reale = v_esito, referto = v_referto,
     -- [090-CICLI:2:FINE]
           testo_esito = nullif(btrim(v_testo),'') ,
           result_message_id = coalesce(v_mid, result_message_id),
           resolved_at = now()
     where id = v_ciclo.id and stato in ('accettata','ripiego');
  end if;

  -- ── avanzamento della macchina a stati (§5.2) ───────────────────────────
  v_scambio_risolto := v.scambio;
  update public.esame_prove set
    pv_cand = case when v_png_att then v_pv else pv_cand end,
    pv_png  = case when v_png_att then pv_png else v_pv end,
    slancio_cand = case when v_png_att then slancio_cand else v_slancio_next end,
    slancio_png  = case when v_png_att then v_slancio_next else slancio_png end,
    -- Sostituzione e relativo cooldown sono gia committati dalla porta comune.
    sost_round_cand = sost_round_cand,
    sost_round_png  = sost_round_png,
    sost_usata_cand = sost_usata_cand,
    ck_cand = case when v_png_att and v_reaz = 'tecnica' then greatest(0, ck_cand - v_ck_reaz)
                   when (not v_png_att) then greatest(0, ck_cand - v_ck_costo) else ck_cand end,
    ck_png  = case when (not v_png_att) and v_reaz = 'tecnica' then greatest(0, ck_png  - v_ck_reaz)
                   when v_png_att then greatest(0, ck_png - v_ck_costo) else ck_png end,
    tecnica_png_usata = tecnica_png_usata or (v_png_att and v_kind <> 'fisico'),
    -- Il primo attacco diretto consuma le copie del difensore, anche quando
    -- sceglie Schivata, Parata o Sostituzione.
    copie_attive_cand = case
      when v_png_att then false
      when v_assalto then false
      else copie_attive_cand end,
    copie_attive_png  = case when v_png_att then copie_attive_png else false end,
    copie_n_cand = case
      when v_png_att then 0
      when v_assalto then 0
      else copie_n_cand end,
    copie_n_png  = case when v_png_att then copie_n_png else 0 end,
    copie_scambio_cand = case
      when v_png_att then null
      when v_assalto then null
      else copie_scambio_cand end,
    copie_scambio_png  = case when v_png_att then copie_scambio_png else null end,
    copie_salvate_cand = copie_salvate_cand
      + case when v_png_att and v_esito_copie = 'copia_colpita' then 1 else 0 end,
    pend_azione = null,
    opzioni_png = null, opzioni_id = null, opzioni_at = null,
    usato_principale = false, usato_rapida = false, usato_spostamento = false,
    -- fine della metà: se attaccava il candidato tocca al PNG, altrimenti si
    -- chiude lo scambio e si sale di gradino.
    meta    = case when v_png_att then 'candidato' else 'png' end,
    fase    = 'attacco',
    scambio = case when v_png_att then least(4, v.scambio + 1) else v.scambio end,
    beat    = case when v_png_att then least(4, v.scambio + 1) else v.beat end,
    -- Le colonne Guardia sono storiche: non vengono più scritte.
    guardia_cand = guardia_cand,
    guardia_png  = guardia_png
  where id = p_prova;

  -- KO simulato o QUARTO scambio finito: si chiude come «done», non come persa.
  -- (Il contratto è a quattro round: vedi `di_scambi` in `_esame_stato_json` e
  --  il vincolo `esame_prove_scambio_beat`, allargato a 1..4 dal §7.)
  -- Si rilegge la fotografia DOPO costi e danni: il chakra arrivato a zero
  -- è una condizione terminale tanto quanto i PV, anche se l'ultimo colpo non
  -- ha prodotto un KO fisico.
  select * into v from public.esame_prove where id=p_prova;
  v_finale := v.pv_cand<=0 or v.pv_png<=0 or v.ck_cand<=0 or v.ck_png<=0
               or (v_png_att and v_scambio_risolto>=4);

  if v_finale then
    v_finale_tipo := case
      when v.pv_cand<=0 or v.pv_png<=0 or v.ck_cand<=0 or v.ck_png<=0
        then 'sfinimento'
      else 'quattro_round' end;
    v_senza_forze := coalesce((select jsonb_agg(nome order by nome) from (
      select v_c.name nome where v.pv_cand<=0 or v.ck_cand<=0
      union all
      select v_prof.nome where v.pv_png<=0 or v.ck_png<=0
    ) q),'[]'::jsonb);
    v_referto := v_referto || jsonb_build_object(
      'finale_tipo',v_finale_tipo,
      'senza_forze',v_senza_forze,
      'chiusura_richiesta','ultimo esito e intervento del Sensei nello stesso racconto',
      'iniziativa','la prova si chiude');

    v_esito_ciclo := gen_random_uuid();
    v_esito_ricevuta := gen_random_uuid();
    insert into public.esame_narrazione_cicli
      (id,prova_id,opzioni_id,ruolo,stato,pg_message_id,
       esiti,esiti_attesi,testo_esito,referto,created_at)
    values
      (v_esito_ciclo,p_prova,v_esito_ricevuta,'png_finale','aperta',
       (select pg_message_id from public.esame_prove where id=p_prova),
       '{}'::jsonb,array[]::text[],nullif(btrim(v_testo),''),v_referto,now());
    update public.esame_prove set
      meta='narratore', fase='finale', pend_azione=null,
      opzioni_id=v_esito_ricevuta, opzioni_at=now(),
      opzioni_png=jsonb_build_object('intenzioni',jsonb_build_array(jsonb_build_object(
        'intenzione_id','narra_finale','chiave','narra_finale',
        'etichetta','Concludi l''Esame','genere','finale',
        'esiti_possibili','[]'::jsonb)))
    where id=p_prova;
  elsif v_png_att then
    -- La meccanica è già chiusa e il candidato avrebbe di nuovo l'offensiva,
    -- ma l'azione resta bloccata finché questo esito non è stato pubblicato.
    v_esito_ciclo := gen_random_uuid();
    v_esito_ricevuta := gen_random_uuid();
    insert into public.esame_narrazione_cicli
      (id,prova_id,opzioni_id,ruolo,stato,pg_message_id,
       esiti,esiti_attesi,testo_esito,referto,created_at)
    values
      (v_esito_ciclo,p_prova,v_esito_ricevuta,'png_esito','aperta',
       (select pg_message_id from public.esame_prove where id=p_prova),
       '{}'::jsonb,array[]::text[],nullif(btrim(v_testo),''),v_referto,now());
    update public.esame_prove set
      opzioni_id=v_esito_ricevuta, opzioni_at=now(),
      opzioni_png=jsonb_build_object('intenzioni',jsonb_build_array(jsonb_build_object(
        'intenzione_id','narra_esito','chiave','narra_esito',
        'etichetta','Racconta l''esito della difesa','genere','esito',
        'esiti_possibili','[]'::jsonb)))
    where id=p_prova;
  else
    perform public._esame_png_turno(p_prova);
  end if;

  return jsonb_build_object('versione',1,'ordine',v_ordine,'esito',v_esito,
                            'esito_copie',v_esito_copie,
                            'colpito',v_colpito,'striscio',v_striscio,'danno',v_appl,
                            'spatial_receipt',case when v_reaz = 'sostituzione'
                              then v_sost_comune else null end);
end
$function$;
CREATE OR REPLACE FUNCTION public._esame_session_claim(p_bozza uuid, p_user uuid)
 RETURNS jsonb
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO ''
AS $function$
DECLARE b public.esame_supervisione_bozze%ROWTYPE;
  q mission_exam_private.protected_sessions%ROWTYPE; payload jsonb;
BEGIN
 IF EXISTS(SELECT 1 FROM public.esame_supervisione_bozze regia_draft JOIN exam_regia_private.bindings regia_binding ON regia_binding.prova_id=regia_draft.prova WHERE regia_draft.id=p_bozza AND regia_draft.tipo<>'apertura') THEN
  RETURN exam_regia_private.claim(p_bozza,p_user);
 END IF;
  SELECT * INTO STRICT b FROM public.esame_supervisione_bozze WHERE id=p_bozza;
  PERFORM 1 FROM public.esame_prove WHERE id=b.prova FOR UPDATE;
  PERFORM 1 FROM public.esame_supervisione WHERE prova=b.prova FOR UPDATE;
  SELECT * INTO STRICT q FROM mission_exam_private.protected_sessions
    WHERE prova_id=b.prova AND owner_user=p_user FOR UPDATE;
  SELECT * INTO STRICT b FROM public.esame_supervisione_bozze WHERE id=p_bozza FOR UPDATE;
  IF b.autore IS DISTINCT FROM p_user OR NOT public._esame_session_scope(b.prova,p_user)
    THEN RAISE EXCEPTION 'mission_session_scope_denied' USING ERRCODE='42501'; END IF;
  IF EXISTS(SELECT 1 FROM mission_exam_private.dispatches WHERE prova_id=b.prova AND receipt_id=b.ricevuta)
    THEN RAISE EXCEPTION 'mission_session_already_dispatched' USING ERRCODE='55000'; END IF;
  IF q.provider_calls>=q.provider_call_cap
    THEN RAISE EXCEPTION 'mission_session_call_limit' USING ERRCODE='55000'; END IF;
  -- L'authority già esistente congela il payload e verifica stato/ricevuta.
  -- La transazione intera torna indietro se qualunque check fallisce.
  payload:=public._esame_supervisione_claim(p_bozza,p_user);
  INSERT INTO mission_exam_private.dispatches(prova_id,receipt_id,draft_id)
    VALUES(b.prova,b.ricevuta,b.id);
  UPDATE mission_exam_private.protected_sessions SET provider_calls=provider_calls+1
    WHERE class_session_id=q.class_session_id;
  RETURN payload;
END $function$;
CREATE OR REPLACE FUNCTION public._esame_session_scope(p_prova uuid, p_user uuid)
 RETURNS boolean
 LANGUAGE sql
 STABLE SECURITY DEFINER
 SET search_path TO ''
AS $function$
 SELECT (p_user IS NOT NULL AND EXISTS (
    SELECT 1 FROM public.esame_prove v
    JOIN public.academy_class_sessions s ON s.id=v.class_session_id
    JOIN public.characters c ON c.id=v.candidate_character AND c.user_id=v.candidate_user
    JOIN public.locations l ON l.id=s.location_id
    JOIN public.esame_supervisione h ON h.prova=v.id AND h.chiusa_at IS NULL
    WHERE v.id=p_prova AND v.candidate_user=p_user AND v.stato='aperta'
      AND s.state<>'closed' AND l.is_active
      AND (
        EXISTS (SELECT 1 FROM mission_exam_private.protected_sessions q
          WHERE q.class_session_id=s.id AND q.prova_id=v.id
            AND q.owner_user=p_user AND q.character_id=c.id AND q.location_id=l.id
            AND q.policy_version='tamako-konoha-no-progression/1' AND q.state='active'
            AND c.id='f335b077-34a1-41c3-94aa-58ec674b649b'::uuid
            AND l.id='df83cd65-b13d-49d6-ad77-a44f35d5ea00'::uuid
            AND NOT l.is_test AND l.is_exam_room AND l.is_academy)
        OR (
          l.id='0b85f354-9cdb-47e1-baf9-3d266bb7e06b'::uuid
          AND l.is_test AND l.is_exam_room AND l.is_academy
          AND lower(c.name) IN ('riuji','testperfunzioni')
          AND EXISTS(SELECT 1 FROM public.profiles p WHERE p.id=p_user AND p.role IN ('admin','master'))
        )
      )
  )) OR (p_user IS NOT NULL AND EXISTS(
 SELECT 1 FROM exam_regia_private.bindings b JOIN public.esame_prove v ON v.id=b.prova_id
 JOIN public.characters c ON c.id=b.character_id AND c.user_id=b.owner_user
 JOIN public.esame_supervisione h ON h.prova=b.prova_id AND h.chiusa_at IS NULL
 WHERE b.prova_id=p_prova AND b.owner_user=p_user AND b.state IN ('opening','active','paused','congedo') AND v.stato='aperta'));
$function$;
CREATE OR REPLACE FUNCTION public.combat_v2_action_declare(p_round uuid, p_actor uuid, p_intent jsonb, p_text text, p_request_key uuid)
 RETURNS jsonb
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO ''
AS $function$
declare v_uid uuid:=exam_regia_private.current_principal(); v_service boolean:=false; v_service_actor uuid; v_r public.combat_v2_rounds%rowtype; v_a public.combat_v2_actors%rowtype; v_t public.combat_v2_actors%rowtype;
  clone_meta jsonb; escape_meta jsonb;  multiplication_aim_valid boolean; multiplication_meta jsonb; v_i jsonb; v_kind text; v_target uuid; v_source text; v_ability uuid; v_meta jsonb; v_cost int:=0; v_base int:=10;
  v_event jsonb; v_event_id uuid; v_id uuid; v_result jsonb; v_total int; v_done int; v_max_range int;
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
  if not v_service and exam_regia_private.actor_principal(v_a.id,v_a.controller_user)<>v_uid then perform public.combat_v2_fail('attore_non_controllato','Non controlli questo attore.',403,p_request_key,'{}'); end if;
  if v_a.state<>'attivo' then perform public.combat_v2_fail('azione_non_disponibile','Attore non attivo.',409,p_request_key,'{}'); end if;
  v_i:=public.combat_v2_sanitize_intent(p_intent,false); v_kind:=v_i->>'kind';
  perform clan_marionettisti_private.assert_jutsu_source(p_actor,v_i->>'ability_source',(v_i->>'ability_id')::uuid);
  if v_kind='attacco' then
    v_target:=(v_i->>'target_actor')::uuid;
    select * into v_t from public.combat_v2_actors t
      where t.id=v_target and t.session_id=v_a.session_id and t.state='attivo' and t.team_key<>v_a.team_key;
    if v_t.id is null then
      perform public.combat_v2_fail('bersaglio_non_valido','Bersaglio non valido.',422,p_request_key,'{}'); end if;
    v_source:=coalesce(v_i->>'ability_source','mano');
    if v_source='mano' then
      if v_i ? 'ability_id' then perform public.combat_v2_fail('intento_non_valido','Il colpo a mano non usa ability_id.',422,p_request_key,'{}'); end if;
      v_meta:=jsonb_build_object('source','mano','name','Colpo','kind','fisico','chakra_cost',0,'damage_base',10,'element',null);
    elsif v_source in ('clan','jutsu') then
      v_ability:=(v_i->>'ability_id')::uuid; v_meta:=combat_v2_multitarget_internal.enrich_ability_v1(public.combat_v2_actor_ability(p_actor,v_source,v_ability,false));
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
         or coalesce((v_meta->>'diversivo')::boolean,false)
         or coalesce(v_meta->>'consumption_type','ad_utilizzo')='passiva' then
        perform public.combat_v2_fail('profilo_runtime_non_disponibile','Questa tecnica richiede il proprio resolver.',422,p_request_key,'{}');
      end if;
      v_max_range:=public._fascia_metri(v_meta->>'range');
      multiplication_aim_valid:=combat_panel_private.multiplication_attack_aim_valid(p_round,p_actor,v_target,p_request_key,v_max_range);
      if not (v_source='clan' and v_ability='e361f7c3-f90b-47ec-bfee-ccbda21257d9'::uuid) and
        (case when multiplication_aim_valid is not null then not multiplication_aim_valid
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
  multiplication_meta:=combat_panel_private.multiplication_declaration_meta(p_round,p_actor,p_request_key,v_i,v_meta);
  IF multiplication_meta IS NOT NULL THEN
    v_meta:=multiplication_meta; v_cost:=(v_meta->>'chakra_cost')::integer; v_base:=(v_meta->>'damage_base')::integer;
  END IF;
  escape_meta:=combat_panel_private.immobilization_escape_meta(p_round,p_actor,p_request_key,v_i);
  IF escape_meta IS NOT NULL THEN
    IF multiplication_meta IS NOT NULL THEN RAISE EXCEPTION 'immobilization_escape_action_conflict' USING ERRCODE='22023'; END IF;
    v_meta:=escape_meta; v_cost:=0; v_base:=0;
  END IF;
  clone_meta:=clan_sabaku_private.clone_declaration_meta(p_round,p_actor,p_request_key,v_i);
  IF clone_meta IS NOT NULL THEN
    IF multiplication_meta IS NOT NULL OR escape_meta IS NOT NULL THEN RAISE EXCEPTION 'sabaku_clone_action_conflict' USING ERRCODE='22023'; END IF;
    v_meta:=clone_meta; v_cost:=5; v_base:=0;
  END IF;
  v_event:=public.combat_v2_event_begin(p_round,p_request_key,'combat_v2_action_declare',jsonb_build_object('actor',p_actor,'intent',v_i,'text',coalesce(p_text,'')),null);
  if (v_event->>'replay')::boolean then return v_event->'result'; end if; v_event_id:=(v_event->>'event_id')::uuid;
  insert into public.combat_v2_declarations(round_id,actor_id,kind,target_actor_id,sanitized_intent,declaration_text,controller_user_snapshot,controller_version_snapshot,request_key,cost_snapshot)
  values(p_round,p_actor,v_kind,v_target,v_i||case when v_meta is null then '{}'::jsonb else jsonb_build_object('server_ability',v_meta) end,
    coalesce(p_text,''),coalesce(v_uid,v_service_actor),v_a.controller_version,p_request_key,jsonb_build_object('chakra',v_cost,'damage_base',v_base)) returning id into v_id;
  perform combat_panel_private.multiplication_bind_declaration(v_id);
  perform combat_panel_private.immobilization_bind_escape(v_id);
  perform clan_sabaku_private.clone_bind(v_id);
  perform combat_panel_private.multiplication_bind_attack_aims(v_id);
  perform combat_panel_private.bind_master_movement(v_id);
  if v_kind='attacco' and v_source='clan' and v_ability='e361f7c3-f90b-47ec-bfee-ccbda21257d9'::uuid then
    perform clan_marionettisti_private.freeze_offensive_profile(v_id);
  end if;
  v_total:=combat_consumer_private.expected_main_count(p_round);
  select count(*) into v_done from public.combat_v2_declarations where round_id=p_round and kind in ('attacco','movimento','utilita','passa');
  if v_done=v_total then update public.combat_v2_rounds set phase='raccolta_difese',state='raccolta_difese' where id=p_round; end if;
  v_result:=public.combat_v2_envelope(p_request_key,jsonb_build_object('declaration_id',v_id,'target_ids',(select coalesce(jsonb_agg(t.target_actor_id order by t.ordinal),'[]'::jsonb)from public.combat_v2_attack_targets t where t.attack_declaration_id=v_id),'phase',case when v_done=v_total then 'raccolta_difese' else 'raccolta_azioni' end));
  return public.combat_v2_event_complete(v_event_id,v_result);
end $function$;
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
  if not v_service and exam_regia_private.actor_principal(v_a.id,v_a.controller_user)<>v_uid then perform public.combat_v2_fail('attore_non_controllato','Non controlli questo attore.',403,p_request_key,'{}'); end if;
  v_i := public.combat_v2_sanitize_intent(p_intent,true);
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
  v_reaction:=v_i->>'reaction';
  -- [MISSION-GUARD-003] I resolver V2 dedicati non sono ancora collegati.
  if v_reaction in ('sostituzione','copie') then
    perform public.combat_v2_fail('profilo_runtime_non_disponibile','Questa difesa richiede il proprio resolver.',422,p_request_key,'{}');
  end if;
  if v_reaction='tecnica' then
    v_source:=v_i->>'ability_source'; v_ability:=(v_i->>'ability_id')::uuid;
    if v_ability='31b15861-fb78-4f8a-ac1c-ebf2d957c32e'::uuid then
      perform public.combat_v2_fail('profilo_runtime_non_disponibile','Sostituzione richiede un’offerta spaziale valida.',422,p_request_key,'{}');
    end if;
    v_meta:=combat_v2_multitarget_internal.enrich_ability_v1(public.combat_v2_actor_ability(p_actor,v_source,v_ability,true));
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
    coalesce(p_text,''),coalesce(v_uid,v_service_actor),v_a.controller_version,p_request_key,jsonb_build_object('chakra',v_cost)) returning id into v_id;
  insert into public.combat_v2_declarations(round_id,actor_id,kind,parent_attack_id,target_actor_id,sanitized_intent,declaration_text,controller_user_snapshot,controller_version_snapshot,request_key,cost_snapshot)
  select p_round,p_actor,'nessuna',x.id,p_actor,jsonb_build_object('reaction','nessuna'),'',coalesce(v_uid,v_service_actor),v_a.controller_version,gen_random_uuid(),'{}'::jsonb
    from public.combat_v2_declarations x
   where x.round_id=p_round and x.kind='attacco' and exists(select 1 from public.combat_v2_attack_targets mt
     where mt.attack_declaration_id=x.id and mt.round_id=p_round
       and mt.target_actor_id=p_actor and mt.state='attesa_difesa'
       and not exists(select 1 from public.combat_v2_defense_coverages c where c.attack_target_id=mt.id)) and x.id<>p_attack_declaration
     and not exists(select 1 from public.combat_v2_declarations d where d.parent_attack_id=x.id and d.actor_id=p_actor);
  v_result:=public.combat_v2_envelope(p_request_key,jsonb_build_object('defense_id',v_id));
  return public.combat_v2_event_complete(v_event_id,v_result);
end
$function$;
CREATE OR REPLACE FUNCTION public.combat_v2_event_begin(p_scope uuid, p_request_key uuid, p_operation text, p_payload jsonb, p_control_version bigint DEFAULT NULL::bigint)
 RETURNS jsonb
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO ''
AS $function$
declare v_fp text; v_event public.combat_v2_events%rowtype; v_caller uuid:=auth.uid();
begin
  perform exam_regia_private.assert_event_dispatch(p_scope,p_request_key,p_operation);
  if p_request_key is null then perform public.combat_v2_fail('chiave_idempotenza_non_valida','Chiave di idempotenza obbligatoria.',422,null,'{}'); end if;
  v_fp:=public.combat_v2_sha256(jsonb_build_object('operation',p_operation,'payload',coalesce(p_payload,'{}'::jsonb),'caller',v_caller,'scope',p_scope));
  select * into v_event from public.combat_v2_events where scope_id=p_scope and request_key=p_request_key for update;
  if v_event.id is not null then
    if v_event.request_fingerprint<>v_fp or v_event.operation_kind<>p_operation then
      perform public.combat_v2_fail('chiave_riusata_per_altra_operazione','La chiave è già associata a un altro payload.',409,p_request_key,'{}');
    end if;
    if v_event.status='completata' then return jsonb_build_object('replay',true,'result',v_event.result,'event_id',v_event.id); end if;
    if v_event.status='in_corso' and p_operation<>'master_v2_close' then
      perform public.combat_v2_fail('operazione_in_corso','Operazione già in corso.',409,p_request_key,'{}');
    end if;
    return jsonb_build_object('replay',false,'resume',true,'event_id',v_event.id);
  end if;
  insert into public.combat_v2_events(scope_id,request_key,operation_kind,request_fingerprint,caller,control_version)
  values(p_scope,p_request_key,p_operation,v_fp,v_caller,p_control_version) returning id into v_event.id;
  return jsonb_build_object('replay',false,'resume',false,'event_id',v_event.id);
end $function$;
CREATE OR REPLACE FUNCTION public.combat_v2_exchange_context_valid(p_master uuid, p_session uuid, p_round uuid, p_team text)
 RETURNS boolean
 LANGUAGE sql
 STABLE SECURITY DEFINER
 SET search_path TO ''
AS $function$
 select p_team in('party','hostile') and (exam_regia_private.exchange_context_valid(p_master,p_session,p_round) OR exists(
  select 1 from public.combat_v2_sessions s
  join public.combat_v2_rounds r on r.session_id=s.id
  where s.id=p_session and s.master_session_id=p_master and r.id=p_round
    and s.state='aperto' and r.state in('raccolta_azioni','raccolta_difese','risolto')))$function$;
CREATE OR REPLACE FUNCTION public.combat_v2_exchange_counter_intent_owner(p_session uuid, p_round uuid, p_roster_sha text)
 RETURNS jsonb
 LANGUAGE plpgsql
 STABLE SECURITY DEFINER
 SET search_path TO ''
AS $function$
declare x mission_exchange_combat_owner.counter_intent_receipts%rowtype;ro jsonb;expected text;begin
 IF exam_regia_private.is_bound(p_session) THEN RETURN exam_regia_private.counter_source(p_session,p_round,p_roster_sha); END IF;
 ro:=public.combat_v2_exchange_roster_owner(p_session);expected:=encode(extensions.digest(convert_to('mission-exchange-roster/1.0:'||ro::text,'UTF8'),'sha256'),'hex');
 if p_roster_sha is distinct from expected then raise exception using errcode='23514',message='G1_COUNTER_ROSTER_DRIFT';end if;
 select*into strict x from mission_exchange_combat_owner.counter_intent_receipts
 where session_id=p_session and round_id=p_round;
 return jsonb_build_object('schema_version','combat-v2-counter-intent-owner/1.0',
  'session_id',x.session_id,'round_id',x.round_id,'roster_sha256',p_roster_sha,
  'actor_id',x.actor_id,'target_actor_id',x.target_actor_id,'target_actor_ids',(select coalesce(jsonb_agg(t.target_actor_id order by t.ordinal),'[]'::jsonb)from public.combat_v2_attack_targets t where t.attack_declaration_id=x.declaration_id),'declaration_id',x.declaration_id,
  'persona_authority_id',x.persona_authority_id,'persona_digest',x.persona_digest,
  'intent',x.sanitized_intent,'outcome_status','pending','owner_receipt_id',x.request_key,
  'owner_receipt_sha256',encode(extensions.digest(convert_to(jsonb_build_object(
    'request_key',x.request_key,'fingerprint',x.request_fingerprint,'declaration',x.declaration_id,
    'persona_digest',x.persona_digest,'intent_sha256',x.intent_sha256)::text,'UTF8'),'sha256'),'hex'));
end$function$;
CREATE OR REPLACE FUNCTION public.combat_v2_exchange_owner_receipt(p_round uuid)
 RETURNS jsonb
 LANGUAGE plpgsql
 STABLE SECURITY DEFINER
 SET search_path TO ''
AS $function$
declare r public.combat_v2_rounds%rowtype;rep public.combat_v2_round_reports%rowtype;actors jsonb;ex jsonb;fp text;
begin
 select*into strict r from public.combat_v2_rounds where id=p_round;
 select*into strict rep from public.combat_v2_round_reports where id=r.report_id and round_id=r.id;
 if encode(extensions.digest(convert_to(rep.mechanics::text,'UTF8'),'sha256'),'hex')is distinct from rep.mechanics_sha256 or rep.values_written is not false then raise exception'G1_REPORT_DRIFT';end if;
 select jsonb_agg(id order by id)into actors from public.combat_v2_actors where session_id=r.session_id and (state='attivo' OR exam_regia_private.is_bound(r.session_id));
 select jsonb_agg(jsonb_build_object('attack_id',a.id,'attack_target_id',t.id,'child_ordinal',t.ordinal,'attacker_id',a.actor_id,
  'target_id',t.target_actor_id,'defense_id',d.id,'defender_id',d.actor_id,'protected_actor_id',c.protected_actor_id,
  'coverage_mode',c.mode,'intent',a.sanitized_intent,'defense',d.sanitized_intent,'cost',a.cost_snapshot,'outcome',t.outcome)
  order by a.order_no,t.ordinal,t.id)into ex
 from public.combat_v2_declarations a join public.combat_v2_attack_targets t on t.attack_declaration_id=a.id
 join public.combat_v2_defense_coverages c on c.attack_target_id=t.id
 join public.combat_v2_declarations d on d.id=c.defense_declaration_id
 where a.round_id=p_round and a.kind='attacco';
 IF exam_regia_private.is_bound(r.session_id) THEN ex:=coalesce(ex,'[]'::jsonb); END IF;
 fp:=encode(extensions.digest(convert_to(jsonb_build_object('round',p_round,'report',rep.id,'report_sha',rep.mechanics_sha256,
  'actors',actors,'exchanges',ex,'engine',rep.engine_version,'resolver',rep.resolver_version,'order',rep.order_version,'quality',rep.quality_version)::text,'UTF8'),'sha256'),'hex');
 return jsonb_build_object('schema_version','combat-v2-exchange-owner/1.1','round_id',p_round,'session_id',r.session_id,
  'report_id',rep.id,'report_sha256',rep.mechanics_sha256,'engine_version',rep.engine_version,'resolver_version',rep.resolver_version,
  'order_version',rep.order_version,'quality_version',rep.quality_version,'actor_ids',actors,'exchanges',coalesce(ex,'[]'::jsonb),
  'defender_target_exact',not exists(select 1 from public.combat_v2_defense_coverages c where c.round_id=p_round and c.protected_actor_id is distinct from(select target_actor_id from public.combat_v2_attack_targets where id=c.attack_target_id)),
  'owner_fingerprint',fp);
end$function$;
CREATE OR REPLACE FUNCTION public.combat_v2_exchange_roster_owner(p_session uuid)
 RETURNS jsonb
 LANGUAGE plpgsql
 STABLE SECURITY DEFINER
 SET search_path TO ''
AS $function$
declare members jsonb;ids jsonb;fp text;begin
 IF exam_regia_private.is_bound(p_session) THEN RETURN exam_regia_private.exchange_roster(p_session); END IF;
 select jsonb_agg(jsonb_build_object(
   'actor_id',a.id,'character_id',a.character_id,'actor_kind',upper(a.actor_kind),
   'team_key',case when a.team_key='konoha'then'party'else a.team_key end,
   'controller_kind',case when a.actor_kind='pg'then'player'else'ai_service'end,
   'controller_user',a.controller_user,
   'persona_digest',case when a.actor_kind='png' then encode(extensions.digest(convert_to(
     'persona-source-snapshot/1.0:'||jsonb_build_object('authority',i.narrative_version_ref,
     'source_sha256',i.source_sha256,'snapshot_sha256',i.snapshot_sha256)::text,'UTF8'),'sha256'),'hex')else null end)
   order by a.id),jsonb_agg(a.id order by a.id)
 into members,ids from public.combat_v2_actors a
 left join public.combat_v2_provider_instances_v1 i on i.id=a.provider_instance_v1_id and i.session_id=a.session_id
 where a.session_id=p_session and a.state='attivo';
 if members is null or jsonb_array_length(members)<>4 or jsonb_array_length(ids)<>4
  or(select count(distinct x->>'actor_id')from jsonb_array_elements(members)x)<>4
  or(select count(distinct x->>'character_id')from jsonb_array_elements(members)x)<>4
  or(select count(distinct x->>'controller_user')from jsonb_array_elements(members)x where x->>'team_key'='party'and x->>'actor_kind'='PG')<>2
  or(select count(*)from jsonb_array_elements(members)x where x->>'team_key'='party'and x->>'actor_kind'='PG'and x->>'controller_kind'='player'and x->>'controller_user'~'^[0-9a-f-]{36}$')<>2
  or(select count(*)from jsonb_array_elements(members)x where x->>'team_key'='hostile'and x->>'actor_kind'='PNG'and x->>'controller_kind'='ai_service'and x->'controller_user'='null'::jsonb and x->>'persona_digest'~'^[0-9a-f]{64}$')<>2
  or exists(select 1 from public.combat_v2_actors a left join public.combat_v2_provider_instances_v1 i on i.id=a.provider_instance_v1_id and i.session_id=a.session_id where a.session_id=p_session and a.state='attivo'and a.actor_kind='png'and(i.id is null or i.narrative_version_ref is null or i.source_sha256 is null or i.source_sha256!~'^[0-9a-f]{64}$'or i.snapshot_sha256 is null or i.snapshot_sha256!~'^[0-9a-f]{64}$'))
 then raise exception using errcode='23514',message='G1_ROSTER_EXACT_DRIFT';end if;
 fp:=encode(extensions.digest(convert_to(jsonb_build_object('session_id',p_session,'actor_members',members,'actor_ids',ids)::text,'UTF8'),'sha256'),'hex');
 return jsonb_build_object('schema_version','combat-v2-exchange-roster/1.0','session_id',p_session,'actor_members',members,'actor_ids',ids,'owner_fingerprint',fp);
end$function$;
CREATE OR REPLACE FUNCTION public.combat_v2_narrative_store(p_round uuid, p_kind text, p_text text, p_request_key uuid, p_author uuid)
 RETURNS jsonb
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO ''
AS $function$
declare
  v_r public.combat_v2_rounds%rowtype;
  v_rep public.combat_v2_round_reports%rowtype;
  v_location uuid;
  v_narrative_id uuid;
  v_message_id uuid;
  v_result jsonb;
  v_next uuid;
  v_active_teams int;
begin
  perform exam_regia_private.assert_publish(p_round,p_text,p_request_key);
  perform public.combat_v2_lock_round(p_round);
  select * into v_r from public.combat_v2_rounds where id=p_round for update;
  select * into v_rep from public.combat_v2_round_reports where round_id=p_round for update;
  perform public.combat_v2_assert_operational(p_round,p_request_key,true);
  perform combat_consumer_private.before_publish(p_round,p_kind,p_text,p_request_key,p_author);

  if v_r.id is null or v_rep.id is null or v_r.state<>'risolto' then
    perform public.combat_v2_fail('referto_non_completo','Il round non ha un referto risolto.',409,p_request_key,'{}');
  end if;
  if v_rep.narration_state='pubblicata' then
    perform public.combat_v2_fail('round_gia_narrato','Il round è già narrato.',409,p_request_key,'{}');
  end if;
  if length(btrim(coalesce(p_text,''))) not between 1 and 5000 then
    perform public.combat_v2_fail('intento_non_valido','Testo narrativo non valido.',422,p_request_key,'{}');
  end if;

  select s.location_id into v_location
    from public.combat_v2_sessions s
   where s.id=v_r.session_id;
  if v_location is null then
    perform public.combat_v2_fail('sessione_inesistente','Sessione inesistente.',404,p_request_key,'{}');
  end if;

  insert into public.combat_v2_narratives(
    round_id,report_id,kind,body,author_user,request_key
  ) values(
    p_round,v_rep.id,p_kind,btrim(p_text),p_author,p_request_key
  ) returning id into v_narrative_id;

  -- Nessun sender_user e nessun character_id: in chat parla Fato; l'identità
  -- reale resta nell'audit combat_v2_narratives.author_user. Il trigger REC
  -- ignora la riga perché character_id è nullo.
  insert into public.messages(location_id,character_id,author_name,body,kind)
  values(v_location,null,'Fato',btrim(p_text),'fato')
  returning id into v_message_id;

  update public.combat_v2_round_reports
     set narration_state='pubblicata',
         narrator_kind=case when p_kind='fato_umano' then 'umano' else 'ia' end,
         message_id=v_message_id,
         narrated_at=clock_timestamp()
   where id=v_rep.id;

  update public.combat_v2_rounds
     set phase='narrato',state='narrato',narrated_at=clock_timestamp()
   where id=p_round;

  select count(distinct team_key) into v_active_teams
    from public.combat_v2_actors
   where session_id=v_r.session_id and state='attivo' and companion_id is null;

  if exam_regia_private.round_is_final(p_round) then v_active_teams:=0; end if;
  IF exam_regia_private.is_bound(v_r.session_id) AND EXISTS(SELECT 1 FROM public.combat_v2_rounds xn WHERE xn.session_id=v_r.session_id AND xn.round_no=v_r.round_no+1) THEN
    SELECT xn.id INTO STRICT v_next FROM public.combat_v2_rounds xn WHERE xn.session_id=v_r.session_id AND xn.round_no=v_r.round_no+1;
    PERFORM exam_regia_private.assert_successor(v_r.id,v_next);
  ELSIF v_active_teams>=2 then
    insert into public.combat_v2_rounds(session_id,round_no,evaluation_mode)
    values(v_r.session_id,v_r.round_no+1,v_r.evaluation_mode)
    returning id into v_next;
  else
    update public.combat_v2_sessions set state='risolto' where id=v_r.session_id;
  end if;

  v_result:=public.combat_v2_envelope(p_request_key,jsonb_build_object(
    'narrative_id',v_narrative_id,
    'message_id',v_message_id,
    'next_round_id',v_next,
    'encounter_resolved',v_active_teams<2
  ));
  perform combat_consumer_private.after_publish(p_round,v_next);
  return v_result;
end
$function$;
CREATE OR REPLACE FUNCTION public.combat_v2_substitution_options_v1(p_attack_declaration uuid)
 RETURNS jsonb
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO ''
AS $function$
declare
  uid uuid:=exam_regia_private.current_principal(); ctx jsonb; iid uuid; wid uuid; lid uuid; raw jsonb; item jsonb;
  v_phase text;
begin
  if uid is null then raise exception using errcode='28000',message='autenticazione_richiesta'; end if;
  ctx:=combat_spatial.substitution_combat_context_v1(p_attack_declaration);
  if (ctx->>'controller_user')::uuid is distinct from uid then
    raise exception using errcode='42501',message='attore_non_controllato';
  end if;
  -- L'offerta appartiene esclusivamente alla finestra raccolta_difese.
  -- Il lock del round precede ogni materializzazione e impedisce che un
  -- freeze concorrente lasci link/capability tardivi.
  select r.phase into strict v_phase
  from public.combat_v2_rounds r
  where r.id=(ctx->>'round_id')::uuid
  for update;
  if v_phase is distinct from 'raccolta_difese' then
    raise exception using errcode='23514',message='substitution_parent_window_invalid';
  end if;
  if exists(select 1 from public.combat_v2_declarations d
    where d.round_id=(ctx->>'round_id')::uuid and d.actor_id=(ctx->>'defender_actor_id')::uuid
      and d.kind in ('difesa','nessuna')) then
    return jsonb_build_object('schema_version','common-substitution-options/1.0','available',false,
      'reason_code','substitution_resource_or_reaction_unavailable','options','[]'::jsonb);
  end if;
  iid:=(ctx->>'instance_id')::uuid;
  wid:=md5(iid::text||p_attack_declaration::text||(ctx->>'defender_actor_id'))::uuid;
  lid:=md5('combat_v2|'||iid::text||'|'||p_attack_declaration::text)::uuid;
  insert into combat_spatial.defense_windows(instance_id,defense_window_id,defender_actor_id,round_no,state,window_version)
  values(iid,wid,(ctx->>'defender_actor_id')::uuid,(ctx->>'round_no')::integer,'open',1)
  on conflict(instance_id,defense_window_id) do nothing;
  if not exists(select 1 from combat_spatial.defense_windows
    where instance_id=iid and defense_window_id=wid and defender_actor_id=(ctx->>'defender_actor_id')::uuid
      and round_no=(ctx->>'round_no')::integer and state='open') then
    raise exception using errcode='23514',message='substitution_parent_window_invalid';
  end if;
  insert into combat_spatial.substitution_activity_links(
    link_id,activity_kind,instance_id,defense_window_id,activity_session_id,activity_round_id,
    attack_declaration_id,defender_actor_id,source_jutsu_id,source_profile_id,source_ninjutsu,
    source_chakra,source_snapshot_sha256,activity_round_no,activity_version,state)
  values(lid,'combat_v2',iid,wid,(ctx->>'combat_session_id')::uuid,(ctx->>'round_id')::uuid,
    p_attack_declaration,(ctx->>'defender_actor_id')::uuid,'31b15861-fb78-4f8a-ac1c-ebf2d957c32e',
    ctx->>'source_profile_id',(ctx->>'ninjutsu')::integer,(ctx->>'chakra')::integer,
    ctx->>'source_snapshot_sha256',(ctx->>'round_no')::integer,(ctx->>'controller_version')::integer,'offered')
  on conflict(activity_kind,activity_round_id,attack_declaration_id,defender_actor_id) do nothing;
  raw:=combat_spatial.substitution_options(iid,wid,(ctx->>'defender_actor_id')::uuid,
    ctx->>'source_profile_id',(ctx->>'round_no')::integer);
  for item in select value from jsonb_array_elements(raw) loop
    insert into combat_spatial.substitution_activity_options(capability_id,link_id,state)
    values((item->>'option_id')::uuid,lid,'offered') on conflict(capability_id) do nothing;
  end loop;
  return jsonb_build_object('schema_version','common-substitution-options/1.0',
    'available',jsonb_array_length(raw)>0,
    'reason_code',case when jsonb_array_length(raw)=0 then 'substitution_no_legal_anchor' end,
    'options',raw);
end
$function$;
CREATE OR REPLACE FUNCTION public.combat_v2_substitution_select_v1(p_substitution_option_id uuid, p_request_key uuid)
 RETURNS jsonb
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO ''
AS $function$
declare
  uid uuid:=exam_regia_private.current_principal(); x record; fp text; replay jsonb; did uuid; result jsonb;
begin
  if uid is null then raise exception using errcode='28000',message='autenticazione_richiesta'; end if;
  if p_request_key is null then
    raise exception using errcode='22004',message='substitution_request_key_required';
  end if;
  -- La request key viene serializzata prima della prima lettura receipt e
  -- prima di qualunque lookup dell'opzione. Un retry identico attende qui,
  -- rilegge la receipt e restituisce il medesimo payload canonico.
  perform pg_advisory_xact_lock(hashtextextended(
    'common-substitution-select-request:'||p_request_key::text,0));
  perform exam_regia_private.assert_substitution_dispatch(p_substitution_option_id,p_request_key);
  fp:=combat_spatial.server_fingerprint('combat_v2_substitution_select_v1',
    jsonb_build_object('option_id',p_substitution_option_id));
  replay:=combat_spatial.receipt_replay(p_request_key,'combat_v2_substitution_select_v1',fp);
  if replay is not null then return replay-'replayed'; end if;
  select o.capability_id,o.state option_state,l.*,c.state capability_state,exam_regia_private.actor_principal(a.id,a.controller_user) AS controller_user,a.controller_version
    into strict x
  from combat_spatial.substitution_activity_options o
  join combat_spatial.substitution_activity_links l on l.link_id=o.link_id
  join combat_spatial.substitution_capabilities c on c.capability_id=o.capability_id
  join public.combat_v2_actors a on a.id=l.defender_actor_id
  join public.combat_v2_rounds r on r.id=l.activity_round_id
  where o.capability_id=p_substitution_option_id and l.activity_kind='combat_v2'
    and r.phase='raccolta_difese'
  for update of o,l,c,a;
  perform exam_regia_private.assert_actor_dispatch(x.activity_round_id,x.defender_actor_id,p_request_key);
  if x.controller_user is distinct from uid then raise exception using errcode='42501',message='attore_non_controllato'; end if;
  if x.option_state<>'offered' or x.capability_state<>'offered' or x.state<>'offered' then
    raise exception using errcode='23514',message='substitution_option_stale';
  end if;
  if exists(select 1 from public.combat_v2_declarations d
     where d.round_id=x.activity_round_id and d.actor_id=x.defender_actor_id and d.kind in ('difesa','nessuna')) then
    raise exception using errcode='23514',message='substitution_resource_or_reaction_unavailable';
  end if;
  did:=gen_random_uuid();
  insert into public.combat_v2_declarations(
    id,round_id,actor_id,kind,parent_attack_id,target_actor_id,sanitized_intent,declaration_text,
    controller_user_snapshot,controller_version_snapshot,request_key,state,cost_snapshot)
  values(did,x.activity_round_id,x.defender_actor_id,'difesa',x.attack_declaration_id,x.defender_actor_id,
    jsonb_build_object('reaction','sostituzione','defense_mode','self','substitution_option_id',p_substitution_option_id,
      'server_ability',jsonb_build_object('source','jutsu','id','31b15861-fb78-4f8a-ac1c-ebf2d957c32e',
        'name','Sostituzione','kind','ninjutsu','usage','difesa','defensive',true,'chakra_cost',5,
        'targeting',jsonb_build_object('schema_version','combat-defense-targeting/1.1',
          'mode','self','affects','self_only','geometry_status','ready'))),
    '',uid,x.controller_version,p_request_key,'inviata',jsonb_build_object('chakra',5));
  update combat_spatial.substitution_activity_options
     set state='selected',selected_defense_declaration_id=did,selection_request_key=p_request_key
   where capability_id=p_substitution_option_id;
  update combat_spatial.substitution_activity_links set state='selected' where link_id=x.link_id;
  update combat_spatial.substitution_activity_options set state='expired'
   where link_id=x.link_id and capability_id<>p_substitution_option_id and state='offered';
  update combat_spatial.substitution_capabilities set state='expired'
   where instance_id=x.instance_id and defense_window_id=x.defense_window_id
     and capability_id<>p_substitution_option_id and state='offered';
  result:=jsonb_build_object('schema_version','common-substitution-selection/1.0',
    'defense_declaration_id',did,'substitution_option_id',p_substitution_option_id);
  insert into combat_spatial.request_receipts values(p_request_key,'combat_v2_substitution_select_v1',fp,result,clock_timestamp());
  return result;
end
$function$;
CREATE OR REPLACE FUNCTION public.esame_avvia(p_location uuid)
 RETURNS uuid
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO 'public'
AS $function$
declare
  v_uid uuid := auth.uid();
  v_loc record; v_char record; v_lesson record; v_agent record;
  v_village text; v_steps int; v_sess uuid; v_aperta uuid;
  v_tot_reg int; v_done_reg int;
  -- [038-R2] la deroga di collaudo: si calcola UNA volta, subito dopo
  -- aver letto il luogo, e da lì in poi si legge soltanto. Ricalcolarla
  -- nei due punti in cui serve vorrebbe dire due letture della stessa
  -- cosa, che è il modo in cui questa famiglia di difetti si riproduce.
  v_deroga boolean := false;
  -- [002] deroga di collaudo completa: Test Room + staff.
  v_test_staff boolean := false;
begin
  if v_uid is null then raise exception 'non autenticato'; end if;

  select id, name, rank, village into v_char
    from public.characters where user_id = v_uid limit 1;
  if v_char.id is null then raise exception 'Ti serve un personaggio'; end if;

  select * into v_loc from public.locations
   where id = p_location
     and (is_active
          or (id = '1ed40f52-7bff-4aa1-85a1-28b24f5804b2'::uuid
              and v_uid = 'f0856d53-83a6-4de0-bc0c-12c87916e665'::uuid));

  -- ═══ [038-R2 · decisione PM 1] LA DEROGA DI COLLAUDO ═════════════════════
  -- Tre condizioni in `and`, e nessuna è ridondante:
  --   · il luogo esiste ed è ATTIVO — è già nella `select` qui sopra, e la
  --     deroga non la tocca: un luogo spento resta spento;
  --   · `is_test = true` — una riga sola in tutto il database, la Test Room;
  --   · `is_staff()` — che a sua volta pretende `auth.uid()` non nullo, quindi
  --     un utente autenticato con `profiles.role in ('master','admin')`.
  --
  -- ⚠️ `is_staff()` è `SECURITY DEFINER` e legge `auth.uid()`: dentro questa
  --    funzione, anch'essa `SECURITY DEFINER`, `auth.uid()` continua a leggere
  --    il JWT del chiamante e non l'identità del proprietario. È il motivo per
  --    cui la deroga NON si apre a una chiamata di servizio senza `sub` — e il
  --    banco lo prova, perché «un GRANT non è una capacità».
  v_deroga := (coalesce(v_loc.is_test, false) and (public.is_staff() or public._ai_narrative_exam_qa_grant_allows_131m(v_uid,v_char.id,v_loc.id)))
              or (v_loc.id = '1ed40f52-7bff-4aa1-85a1-28b24f5804b2'::uuid
                  and v_uid = 'f0856d53-83a6-4de0-bc0c-12c87916e665'::uuid);

  -- [002] Nella Test Room lo staff prova l'esame con qualunque PG: le barriere
  --       del candidato (villaggio, grado, lezioni) non si applicano. Solo qui.
  v_deroga := v_deroga OR exam_regia_private.native_open_allowed(v_uid,v_char.id,v_loc.id);
  v_test_staff := coalesce(v_loc.is_test, false) and public.is_staff();

  if v_loc.id is null or not (coalesce(v_loc.is_exam_room,false) or v_deroga) then
    raise exception 'Qui non si tengono esami';
  end if;

  -- [108] Serializza soltanto gli avvii nella stessa sala. La transazione non
  -- contiene chiamate esterne e il lock vive per pochi millisecondi.
  perform pg_advisory_xact_lock(hashtextextended('esame_avvia:'||p_location::text,0));

  v_village := coalesce(nullif(lower(btrim(v_loc.region)),''), 'konoha');

  -- [PREREQ-001 · lower() 1 di 3] locations.region è minuscolo,
  -- characters.village è maiuscolo: senza lower() da entrambe le parti il
  -- confronto è sempre falso. Vedi PREFLIGHT di DB-003 §5.1.
  -- ⚠️ Errore NON previsto dai nove del §6a: aggiunto di iniziativa, dichiarato
  --    nell'handoff perché il PM lo ratifichi (Discovery §10, punto 10).
  if not v_test_staff and lower(btrim(coalesce(v_char.village,''))) is distinct from v_village then
    raise exception 'Questo esame non è del tuo villaggio';
  end if;

  if not v_test_staff and coalesce(v_char.rank,'Deshi') <> 'Deshi' then
    raise exception 'Hai già il grado di Genin';
  end if;

  -- Idempotenza (Discovery §7): un doppio invio o un rientro ritrovano la
  -- propria sessione aperta invece di aprirne una seconda nella sala di riserva.
  select s.id into v_aperta
    from public.academy_class_sessions s
    join public.academy_lessons l on l.id = s.lesson_id
    join public.academy_class_participants p on p.session_id = s.id and p.user_id = v_uid
   where s.state <> 'closed' and coalesce(l.is_exam,false)
   order by s.created_at desc limit 1;
  if v_aperta is not null then
    -- Recupero idempotente: la stessa porta riallinea e apre l'eventuale
    -- sessione rimasta enrolling, senza creare un secondo owner o una prova.
    perform public.esame_prova_apri(v_aperta);
    return v_aperta;
  end if;

  -- Prerequisito, verificato QUI e non solo a valle (§6a). Sta prima della
  -- disponibilità della riga EXAM perché riguarda il candidato e non il
  -- sistema: resta vero anche a esame contenuto.
  select count(*) filter (where not al.is_exam),
         count(*) filter (where not al.is_exam and pp.lesson_id is not null)
    into v_tot_reg, v_done_reg
    from public.academy_lessons al
    left join public.lesson_progress pp on pp.lesson_id = al.id and pp.user_id = v_uid
   where al.is_active;
  if not v_test_staff and not (coalesce(v_tot_reg,0) > 0 and v_done_reg = v_tot_reg) then
    raise exception 'Non hai ancora finito le lezioni';
  end if;

  -- La lezione la sceglie il server, non il client.
  -- [038-R2] la seconda barriera. `is_exam` resta CONGIUNTO: la deroga allarga
  -- soltanto `is_active`, quindi nessuna lezione ordinaria spenta entra qui.
  -- ⚠️ `order by is_active desc` PRIMA di `ordinal`: se un giorno esistessero
  --    due lezioni d'esame, una accesa e una spenta, senza questa riga la
  --    deroga potrebbe far scegliere la spenta a chi aveva diritto alla accesa.
  --    Così la deroga può solo AGGIUNGERE un ripiego, mai cambiare la scelta
  --    che il percorso normale avrebbe fatto.
  select * into v_lesson from public.academy_lessons
   where is_exam and (is_active or v_deroga)
   order by is_active desc, ordinal limit 1;
  if v_lesson.id is null then raise exception 'L''esame non è disponibile'; end if;

  if exists (select 1 from public.academy_class_sessions
              where location_id = p_location and state <> 'closed') then
    raise exception 'C''è già un esame in corso in questa sala';
  end if;

  select coalesce(max(step),0) into v_steps
    from public.academy_lesson_script
   where lesson_id = v_lesson.id and lower(btrim(village)) = v_village;
  if v_steps = 0 then raise exception 'Esame senza contenuti'; end if;

  if coalesce(v_loc.is_exam_room,false) or v_deroga then
    -- Sessione contenitore compatibile con il client, gia' sul passo della prova.
    -- `ai_blocked_at` esclude academy_sensei_ai; `step_at` futuro impedisce
    -- l'avanzamento automatico Accademia durante il banco reale.
    insert into public.academy_class_sessions
      (location_id, village, lesson_id, lesson_code, lesson_title,
       sensei_name, total_steps, started_by, starter_name, sensei_agent_id,
       state, step, step_at, ai_blocked_at, ai_block_reason)
    values
      (p_location, v_village, v_lesson.id, v_lesson.code, v_lesson.title,
       null, v_steps, v_uid, v_char.name, null,
       'teaching',
       (select max(sc.step) from public.academy_lesson_script sc
         where sc.lesson_id = v_lesson.id
           and lower(btrim(sc.village)) = v_village
           and coalesce(sc.valuta,false)),
       now() + interval '24 hours', now(), 'staff')
    returning id into v_sess;
  else
    select a.id, a.name into v_agent from public.ai_agents a
     where a.kind = 'sensei' and a.is_active
       and lower(btrim(a.village)) = v_village
       and not exists (select 1 from public.academy_class_sessions s
                        where s.state <> 'closed' and s.sensei_agent_id = a.id)
     order by (-ln(random()) / greatest(a.weight,1)) asc limit 1;
    if v_agent.id is null then
      select a.id, a.name into v_agent from public.ai_agents a
       where a.kind = 'sensei' and a.is_active
         and lower(btrim(a.village)) = v_village
       order by (-ln(random()) / greatest(a.weight,1)) asc limit 1;
    end if;
    if v_agent.id is null then
      raise exception 'In questo villaggio non c''è nessun maestro attivo';
    end if;

    insert into public.academy_class_sessions
      (location_id, village, lesson_id, lesson_code, lesson_title,
       sensei_name, total_steps, started_by, starter_name, sensei_agent_id)
    values
      (p_location, v_village, v_lesson.id, v_lesson.code, v_lesson.title,
       v_agent.name, v_steps, v_uid, v_char.name, v_agent.id)
    returning id into v_sess;
  end if;

  insert into public.academy_class_participants
    (session_id, user_id, character_id, character_name, kind)
  values (v_sess, v_uid, v_char.id, v_char.name, 'student');

  -- [108] Sessione, partecipante e prova nascono nella stessa transazione.
  -- Se la prova non può aprirsi, anche il contenitore viene annullato: nessun
  -- player resta più quindici minuti davanti a una sessione dimezzata.
  perform public.esame_prova_apri(v_sess);

  return v_sess;
end $function$;
CREATE OR REPLACE FUNCTION public.esame_prova_uscita(p_prova uuid, p_testo text)
 RETURNS jsonb
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO 'public'
AS $function$
declare
  v_uid uuid:=auth.uid(); v public.esame_prove%rowtype;
  v_testo text; v_chiusura jsonb; v_is_test boolean:=false; v_esito text;
begin
  perform exam_regia_private.assert_no_legacy(p_prova);
  perform 1 from public.esame_prove where id=p_prova for update;
  if exists(select 1 from public.esame_supervisione where prova=p_prova and not player_ready and not publishing) then
    raise exception 'Esito in revisione: attendi la pubblicazione dello staff';
  end if;
  if v_uid is null then raise exception 'non autenticato'; end if;
  select * into v from public.esame_prove where id=p_prova for update;
  if not found then raise exception 'La prova non esiste più'; end if;
  if v.candidate_user<>v_uid then raise exception 'Questa non è la tua prova'; end if;
  if v.stato='conclusa' then return public._esame_stato_json(p_prova); end if;
  if v.stato<>'aperta' or v.meta<>'candidato' or v.fase<>'uscita' then
    raise exception 'L''uscita non è ancora il passo di questo esame';
  end if;
  if exists (select 1 from public.esame_narrazione_cicli c
              where c.prova_id=p_prova and c.stato in ('aperta','accettata')) then
    raise exception 'Il narratore sta ancora concludendo l''esame';
  end if;

  v_testo:=nullif(btrim(coalesce(p_testo,'')),'');
  if v_testo is null then raise exception 'Scrivi la role con cui lasci l''aula'; end if;
  if length(v_testo)>5000 then
    raise exception 'Il testo supera i 5.000 caratteri (ne hai scritti %).',length(v_testo);
  end if;
  perform public._esame_testo_candidato(p_prova,v_testo);

  select coalesce(l.is_test,false) into v_is_test
    from public.academy_class_sessions s
    join public.locations l on l.id=s.location_id
   where s.id=v.class_session_id;

  perform public._esame_valuta(p_prova);
  if v_is_test or mission_exam_private.is_protected(p_prova) then
    v_esito:=public._esame_classifica(v.class_session_id);
    update public.academy_class_participants
       set esito=v_esito
     where session_id=v.class_session_id and user_id=v.candidate_user;
    update public.academy_class_sessions
       set step=greatest(coalesce(step,0),coalesce(total_steps,0)), step_at=now(),
           state='closed',closed_at=now(),close_reason='done',force_next=false
     where id=v.class_session_id;
    v_chiusura:=jsonb_build_object('ok',true,'isolata',true,'esito',v_esito,
                                   'xp',0,'grado_modificato',false);
  else
    update public.academy_class_sessions
       set step=greatest(coalesce(step,0),coalesce(total_steps,0)), step_at=now()
     where id=v.class_session_id and state<>'closed';
    v_chiusura:=public.esame_chiudi(v.class_session_id)::jsonb;
  end if;

  if mission_exam_private.is_protected(p_prova) then
    update mission_exam_private.protected_sessions set state='closed',closed_at=clock_timestamp() where prova_id=p_prova;
    update public.esame_supervisione set chiusa_at=clock_timestamp(),motivo_chiusura='session_completed',
      player_ready=false,publishing=false,idle_deadline=null where prova=p_prova;
    update public.esame_supervisione_prenotazioni reservation set is_active=false
      from public.esame_supervisione hold_row
      where hold_row.prova=p_prova and reservation.id=hold_row.prenotazione
        and reservation.prova=p_prova and reservation.is_active;
  end if;
  return public._esame_stato_json(p_prova)
    || jsonb_build_object('uscita_registrata',true,'chiusura',v_chiusura);
end
$function$;
CREATE OR REPLACE FUNCTION public.exam_substitution_commit_v1(p_prova uuid, p_substitution_option_id uuid, p_request_key uuid)
 RETURNS jsonb
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO ''
AS $function$
declare x record; ctx jsonb; fp text; replay jsonb; spatial jsonb; v_event_id uuid; payload jsonb; p public.esame_prove%rowtype; result jsonb;
begin
  perform exam_regia_private.assert_no_legacy(p_prova);
  if current_user not in ('postgres','service_role') then raise exception using errcode='42501',message='service_role_required'; end if;
  perform pg_advisory_xact_lock(hashtextextended('exam-substitution-commit:'||p_request_key::text,0));
  select o.capability_id,o.link_id,o.state option_state,l.state link_state,
    l.source_snapshot_sha256,l.attack_declaration_id,l.instance_id,
    s.defender_key,s.source_application_id,s.state source_state into strict x
  from combat_spatial.substitution_activity_options o join combat_spatial.substitution_activity_links l using(link_id)
  join combat_spatial.exam_substitution_sources_v1 s on s.source_application_id=l.attack_declaration_id
  where o.capability_id=p_substitution_option_id and l.activity_kind='exam_genin' and l.activity_session_id=p_prova
  for update of o,l,s;
  fp:=combat_spatial.server_fingerprint('exam_substitution_commit_v1',jsonb_build_object('prova',p_prova,'option',p_substitution_option_id,'source',x.source_application_id));
  replay:=combat_spatial.receipt_replay(p_request_key,'exam_substitution_commit_v1',fp);
  if replay is not null then return replay-'replayed'; end if;
  ctx:=combat_spatial.exam_substitution_context_v1(p_prova,x.source_application_id);
  if ctx->>'source_snapshot_sha256' is distinct from x.source_snapshot_sha256
     or x.option_state<>'offered' or x.link_state<>'offered' or x.source_state<>'open' then
    raise exception using errcode='23514',message='exam_substitution_option_stale'; end if;
  select * into strict p from public.esame_prove where id=p_prova for update;
  spatial:=combat_spatial.substitution_commit(p_substitution_option_id,md5(p_request_key::text||'|spatial')::uuid,x.source_application_id);
  v_event_id:=(spatial->>'event_id')::uuid;
  if x.defender_key='candidate' then
    update public.esame_prove set ck_cand=ck_cand-5,sost_round_cand=scambio,sost_usata_cand=true,updated_at=clock_timestamp()
      where id=p_prova and ck_cand>=5;
  else
    update public.esame_prove set ck_png=ck_png-5,sost_round_png=scambio,updated_at=clock_timestamp()
      where id=p_prova and ck_png>=5;
  end if;
  if not found then raise exception using errcode='23514',message='exam_substitution_resource_unavailable'; end if;
  select e.narrator_payload into strict payload from combat_spatial.spatial_events e where e.event_id=v_event_id;
  update combat_spatial.substitution_activity_options set selected_defense_declaration_id=x.source_application_id,
    selection_request_key=p_request_key,state='committed' where capability_id=p_substitution_option_id;
  update combat_spatial.substitution_activity_links set state='committed' where link_id=x.link_id;
  update combat_spatial.exam_substitution_sources_v1 set state='committed',committed_event_id=v_event_id,narrator_payload=payload
    where source_application_id=x.source_application_id;
  result:=jsonb_build_object('schema_version','common-substitution-resolution/1.0','status','committed','event_id',v_event_id,
    'canonical_outcome','negato_sostituzione','damage_applied',0,'chakra_committed',5,'narrator_payload',payload);
  insert into combat_spatial.request_receipts values(p_request_key,'exam_substitution_commit_v1',fp,result,clock_timestamp());
  return result;
end
$function$;
CREATE OR REPLACE FUNCTION public.mission_exchange_v3_capture(cy uuid, ph text, r uuid, k uuid)
 RETURNS jsonb
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO ''
AS $function$
declare
  c mission_exchange_v3.cycles%rowtype;
  co jsonb;
  sp jsonb;
  fp text;
  o jsonb;
  ord integer;
  ni text;
  id uuid;
  rh text;
  res jsonb;
  expected_owner_fingerprint text;
  expected_actors jsonb;
  expected_exchange_count integer;
begin
  IF exam_regia_private.exchange_scope(cy) IS NOT NULL THEN PERFORM exam_regia_private.assert_exchange(cy); ELSE perform mission_ai_service_owner.service_only(); END IF;
  IF exam_regia_private.exchange_scope(cy) IS NULL THEN perform mission_exchange_owner.assert_exact_pinset(); END IF;
  perform pg_catalog.pg_advisory_xact_lock(pg_catalog.hashtextextended(cy::text,2));
  select * into strict c from mission_exchange_v3.cycles z where z.id=cy for update;

  if ph='party_offense' and r=c.party_round_id then ord:=1;ni:='hostile';
  elsif ph='hostile_counter' and r=c.counter_round_id then ord:=2;ni:='party';
  else raise exception using errcode='23514',message='exchange_capture_order_invalid';
  end if;

  co:=public.combat_v2_exchange_owner_receipt(r);
  sp:=combat_spatial.exchange_owner_receipt(c.spatial_instance_id,r);

  select pg_catalog.jsonb_agg(a.id order by a.id)
    into expected_actors
    from public.combat_v2_actors a
   where a.session_id=c.combat_session_id and (a.state='attivo' OR exam_regia_private.is_bound(c.combat_session_id));

  select pg_catalog.count(*)
    into expected_exchange_count
    from public.combat_v2_declarations a
    join public.combat_v2_attack_targets t on t.attack_declaration_id=a.id
    join public.combat_v2_defense_coverages cv on cv.attack_target_id=t.id
    join public.combat_v2_declarations d on d.id=cv.defense_declaration_id
   where a.round_id=r and a.kind='attacco';

  expected_owner_fingerprint:=pg_catalog.encode(extensions.digest(pg_catalog.convert_to(
    pg_catalog.jsonb_build_object(
      'round',co->'round_id','report',co->'report_id','report_sha',co->'report_sha256',
      'actors',co->'actor_ids','exchanges',co->'exchanges','engine',co->'engine_version',
      'resolver',co->'resolver_version','order',co->'order_version','quality',co->'quality_version'
    )::text,'UTF8'),'sha256'),'hex');

  if pg_catalog.jsonb_typeof(co) is distinct from 'object'
     or (select pg_catalog.array_agg(x order by x) from pg_catalog.jsonb_object_keys(co)x)
        is distinct from array['actor_ids','defender_target_exact','engine_version','exchanges','order_version','owner_fingerprint','quality_version','report_id','report_sha256','resolver_version','round_id','schema_version','session_id']::text[]
     or co->>'schema_version' is distinct from 'combat-v2-exchange-owner/1.1'
     or co->>'round_id' is distinct from r::text
     or co->>'session_id' is distinct from c.combat_session_id::text
     or pg_catalog.jsonb_typeof(co->'actor_ids') is distinct from 'array'
     or co->'actor_ids' is distinct from expected_actors
     or co->'actor_ids' is distinct from sp->'actor_ids'
     or co->'actor_ids' is distinct from c.roster_owner->'actor_ids'
     or pg_catalog.jsonb_typeof(co->'exchanges') is distinct from 'array'
     or pg_catalog.jsonb_array_length(co->'exchanges')<>expected_exchange_count
     or coalesce(co->>'report_sha256','')!~'^[0-9a-f]{64}$'
     or coalesce(co->>'owner_fingerprint','')!~'^[0-9a-f]{64}$'
     or co->>'owner_fingerprint' is distinct from expected_owner_fingerprint
     or co->'defender_target_exact' is distinct from 'true'::jsonb
     or not exists(
       select 1
         from public.combat_v2_rounds rr
         join public.combat_v2_round_reports rep on rep.id=rr.report_id and rep.round_id=rr.id
        where rr.id=r
          and rep.id::text=co->>'report_id'
          and rep.mechanics_sha256=co->>'report_sha256'
          and pg_catalog.encode(extensions.digest(pg_catalog.convert_to(rep.mechanics::text,'UTF8'),'sha256'),'hex')=rep.mechanics_sha256
          and rep.values_written is false
          and rep.engine_version=co->>'engine_version'
          and rep.resolver_version=co->>'resolver_version'
          and rep.order_version=co->>'order_version'
          and rep.quality_version=co->>'quality_version')
     or exists(
       select 1
         from pg_catalog.jsonb_array_elements(co->'exchanges') x
         left join public.combat_v2_declarations a
           on a.id::text=x->>'attack_id' and a.round_id=r and a.kind='attacco'
         left join public.combat_v2_attack_targets t
           on t.id::text=x->>'attack_target_id' and t.attack_declaration_id=a.id
         left join public.combat_v2_defense_coverages cv
           on cv.attack_target_id=t.id
         left join public.combat_v2_declarations d
           on d.id=cv.defense_declaration_id
        where pg_catalog.jsonb_typeof(x) is distinct from 'object'
           or (select pg_catalog.array_agg(z order by z) from pg_catalog.jsonb_object_keys(x)z)
              is distinct from array['attack_id','attack_target_id','attacker_id','child_ordinal','cost','coverage_mode','defender_id','defense','defense_id','intent','outcome','protected_actor_id','target_id']::text[]
           or a.id is null or t.id is null or cv.attack_target_id is null or d.id is null
           or x->>'child_ordinal' is distinct from t.ordinal::text
           or x->>'attacker_id' is distinct from a.actor_id::text
           or x->>'target_id' is distinct from t.target_actor_id::text
           or x->>'defense_id' is distinct from d.id::text
           or x->>'defender_id' is distinct from d.actor_id::text
           or x->>'protected_actor_id' is distinct from cv.protected_actor_id::text
           or x->>'coverage_mode' is distinct from cv.mode
           or x->'intent' is distinct from a.sanitized_intent
           or x->'defense' is distinct from d.sanitized_intent
           or x->'cost' is distinct from a.cost_snapshot
           or x->'outcome' is distinct from t.outcome)
     or (select pg_catalog.count(distinct x->>'attack_target_id') from pg_catalog.jsonb_array_elements(co->'exchanges')x)<>expected_exchange_count
     or (select pg_catalog.count(distinct (x->>'attack_id',x->>'child_ordinal')) from pg_catalog.jsonb_array_elements(co->'exchanges')x)<>expected_exchange_count
     or sp->>'schema_version' is distinct from 'combat-spatial-exchange-owner/1.0'
     or sp->>'round_id' is distinct from r::text
     or sp->>'instance_id' is distinct from c.spatial_instance_id::text
     or coalesce(sp->>'owner_fingerprint','')!~'^[0-9a-f]{64}$'
     or sp->'bounds_valid' is distinct from 'true'::jsonb
     or sp->'events_exact' is distinct from 'true'::jsonb
     or (ord=2 and NOT (exam_regia_private.is_bound(c.combat_session_id) AND exam_regia_private.counter_is_nonattack(cy,r)) and not exists(
       select 1
         from mission_exchange_v3.counter_intents ci
         join lateral pg_catalog.jsonb_array_elements(co->'exchanges')x on true
        where ci.cycle_id=c.id
          and x->>'attack_id'=ci.declaration_id::text
          and x->>'attacker_id'=ci.actor_id::text
          and x->>'target_id'=ci.target_actor_id::text
          and x->'intent' is not distinct from ci.intent))
  then raise exception using errcode='23514',message='exchange_owner_receipt_invalid';
  end if;

  fp:=mission_exchange_v3.sha('mission-exchange-request/7.0',pg_catalog.jsonb_build_object(
    'operation','capture','cycle',cy,'phase',ph,'round',r,
    'combat_fp',co->>'owner_fingerprint','spatial_fp',sp->>'owner_fingerprint'));
  o:=mission_exchange_v3.replay(k,'capture',fp);
  if o is not null then return o; end if;
  if (ord=1 and c.state<>'party_open') or (ord=2 and c.state<>'counter_open')
  then raise exception using errcode='23514',message='exchange_capture_order_invalid'; end if;

  rh:=mission_exchange_v3.sha('mission-exchange-receipt/4.0',pg_catalog.jsonb_build_object(
    'cycle',cy,'ordinal',ord,'phase',ph,'round',r,'combat',co,'spatial',sp,'initiative_after',ni));
  id:=gen_random_uuid();
  res:=pg_catalog.jsonb_build_object('receipt_id',id,'receipt_sha256',rh,'ordinal',ord,'initiative_after',ni,'replay',false);
  insert into mission_exchange_v3.requests values(k,'capture',fp,res,default);
  insert into mission_exchange_v3.receipts values(id,cy,ord,ph,r,co,sp,ni,rh,k);
  update mission_exchange_v3.cycles
     set state=case ord when 1 then'party_captured'else'counter_captured'end,initiative=ni
   where mission_exchange_v3.cycles.id=cy;
  return res;
end
$function$;
CREATE OR REPLACE FUNCTION public.mission_exchange_v3_counter_intent_prepare(cy uuid, cr uuid, k uuid)
 RETURNS jsonb
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO ''
AS $function$declare c mission_exchange_v3.cycles%rowtype;x jsonb;fp text;o jsonb;id uuid;ih text;res jsonb;begin IF exam_regia_private.exchange_scope(cy) IS NOT NULL THEN PERFORM exam_regia_private.assert_exchange(cy); ELSE perform mission_ai_service_owner.service_only(); END IF;IF exam_regia_private.exchange_scope(cy) IS NULL THEN perform mission_exchange_owner.assert_exact_pinset(); END IF;perform pg_advisory_xact_lock(hashtextextended(cy::text,4));select * into strict c from mission_exchange_v3.cycles z where z.id=cy for update;x:=public.combat_v2_exchange_counter_intent_owner(c.combat_session_id,cr,c.roster_sha256);if x->>'schema_version' is distinct from 'combat-v2-counter-intent-owner/1.0'or x->>'round_id' is distinct from cr::text or x->>'session_id' is distinct from c.combat_session_id::text or x->>'roster_sha256' is distinct from c.roster_sha256 or x->>'outcome_status' is distinct from 'pending'or coalesce(x->>'owner_receipt_sha256','')!~'^[0-9a-f]{64}$'or not exists(select 1 from jsonb_array_elements(c.roster_owner->'actor_members')a where a->>'actor_id'=x->>'actor_id'and a->>'team_key'='hostile'and a->>'persona_digest'=x->>'persona_digest')or not exists(select 1 from jsonb_array_elements(c.roster_owner->'actor_members')a where a->>'actor_id'=x->>'target_actor_id'and a->>'team_key'='party')then raise exception using errcode='23514',message='exchange_counter_intent_invalid';end if;ih:=mission_exchange_v3.sha('mission-exchange-counter-intent/1.0',x);fp:=mission_exchange_v3.sha('mission-exchange-request/7.0',jsonb_build_object('operation','counter_intent_prepare','cycle',cy,'round',cr,'intent_sha',ih,'owner_receipt_sha',x->>'owner_receipt_sha256'));o:=mission_exchange_v3.replay(k,'counter_intent_prepare',fp);if o is not null then return o;end if;if c.state<>'party_captured'or not public.combat_v2_exchange_round_successor(c.party_round_id,cr,c.combat_session_id)then raise exception using errcode='23514',message='exchange_counter_order_invalid';end if;id:=gen_random_uuid();res:=jsonb_build_object('counter_intent_id',id,'intent_sha256',ih,'state','counter_intent_ready','replay',false);insert into mission_exchange_v3.requests values(k,'counter_intent_prepare',fp,res,default);insert into mission_exchange_v3.counter_intents values(id,cy,cr,(x->>'actor_id')::uuid,(x->>'target_actor_id')::uuid,(x->>'declaration_id')::uuid,(x->>'persona_authority_id')::uuid,x->>'persona_digest',x->'intent',ih,(x->>'owner_receipt_id')::uuid,x->>'owner_receipt_sha256',k);update mission_exchange_v3.cycles set counter_round_id=cr,state='counter_intent_ready',initiative='hostile'where mission_exchange_v3.cycles.id=cy;return res;end$function$;
CREATE OR REPLACE FUNCTION public.mission_exchange_v3_counter_open(cy uuid, cr uuid, pub uuid, k uuid)
 RETURNS jsonb
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO ''
AS $function$declare c mission_exchange_v3.cycles%rowtype;fp text;o jsonb;res jsonb;begin IF exam_regia_private.exchange_scope(cy) IS NOT NULL THEN PERFORM exam_regia_private.assert_exchange(cy); ELSE perform mission_ai_service_owner.service_only(); END IF;IF exam_regia_private.exchange_scope(cy) IS NULL THEN perform mission_exchange_owner.assert_exact_pinset(); END IF;perform pg_advisory_xact_lock(hashtextextended(cy::text,6));select * into strict c from mission_exchange_v3.cycles z where z.id=cy for update;fp:=mission_exchange_v3.sha('mission-exchange-request/7.0',jsonb_build_object('operation','counter_open','cycle',cy,'round',cr,'publication',pub));o:=mission_exchange_v3.replay(k,'counter_open',fp);if o is not null then return o;end if;if c.state<>'counter_intent_ready'or c.counter_round_id is distinct from cr or not exists(select 1 from mission_exchange_v3.publication_bindings where cycle_id=cy and ordinal=1 and publication_id=pub)then raise exception using errcode='23514',message='exchange_counter_open_invalid';end if;res:=jsonb_build_object('cycle_id',cy,'state','counter_open','initiative','hostile','replay',false);insert into mission_exchange_v3.requests values(k,'counter_open',fp,res,default);update mission_exchange_v3.cycles set state='counter_open'where mission_exchange_v3.cycles.id=cy;return res;end$function$;
CREATE OR REPLACE FUNCTION public.mission_exchange_v3_cycle_close(cy uuid, pub uuid, k uuid)
 RETURNS jsonb
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO ''
AS $function$declare c mission_exchange_v3.cycles%rowtype;fp text;o jsonb;res jsonb;begin IF exam_regia_private.exchange_scope(cy) IS NOT NULL THEN PERFORM exam_regia_private.assert_exchange(cy); ELSE perform mission_ai_service_owner.service_only(); END IF;IF exam_regia_private.exchange_scope(cy) IS NULL THEN perform mission_exchange_owner.assert_exact_pinset(); END IF;perform pg_advisory_xact_lock(hashtextextended(cy::text,7));select * into strict c from mission_exchange_v3.cycles z where z.id=cy for update;fp:=mission_exchange_v3.sha('mission-exchange-request/7.0',jsonb_build_object('operation','cycle_close','cycle',cy,'publication',pub));o:=mission_exchange_v3.replay(k,'cycle_close',fp);if o is not null then return o;end if;if (c.state<>'counter_captured' AND NOT (c.state='party_captured' AND exam_regia_private.round_is_final(c.party_round_id)))or not exists(select 1 from mission_exchange_v3.publication_bindings where cycle_id=cy and ordinal=CASE WHEN c.state='party_captured' AND exam_regia_private.round_is_final(c.party_round_id) THEN 1 ELSE 2 END and publication_id=pub)then raise exception using errcode='23514',message='exchange_cycle_close_invalid';end if;res:=jsonb_build_object('cycle_id',cy,'state','complete','initiative','party','next_cycle_allowed',true,'replay',false);insert into mission_exchange_v3.requests values(k,'cycle_close',fp,res,default);update mission_exchange_v3.cycles set state='complete',initiative='party'where mission_exchange_v3.cycles.id=cy;return res;end$function$;
CREATE OR REPLACE FUNCTION public.mission_exchange_v3_cycle_open(m uuid, co uuid, sp uuid, pr uuid, k uuid)
 RETURNS jsonb
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO ''
AS $function$declare fp text;o jsonb;id uuid;res jsonb;ro jsonb;rs text;begin IF exam_regia_private.exchange_scope(co) IS NOT NULL THEN PERFORM exam_regia_private.assert_exchange(co); ELSE perform mission_ai_service_owner.service_only(); END IF;IF exam_regia_private.exchange_scope(co) IS NULL THEN perform mission_exchange_owner.assert_exact_pinset(); END IF;perform pg_advisory_xact_lock(hashtextextended(co::text||pr::text,0));ro:=public.combat_v2_exchange_roster_owner(co);IF exam_regia_private.is_bound(co) THEN PERFORM exam_regia_private.assert_exchange_roster(co,ro); ELSE if ro->>'schema_version' is distinct from 'combat-v2-exchange-roster/1.0' or jsonb_array_length(ro->'actor_members')<>4 or (select count(*)from jsonb_array_elements(ro->'actor_members')x where x->>'team_key'='party' and x->>'actor_kind'='PG' and x->>'controller_kind'='player')<>2 or (select count(*)from jsonb_array_elements(ro->'actor_members')x where x->>'team_key'='hostile' and x->>'actor_kind'='PNG' and x->>'controller_kind'='ai_service' and coalesce(x->>'persona_digest','')~'^[0-9a-f]{64}$')<>2 or (select count(distinct x->>'actor_id')from jsonb_array_elements(ro->'actor_members')x)<>4 or(select count(distinct x->>'character_id')from jsonb_array_elements(ro->'actor_members')x)<>4 or coalesce(ro->>'owner_fingerprint','')!~'^[0-9a-f]{64}$' then raise exception using errcode='23514',message='exchange_roster_invalid';end if; END IF;rs:=mission_exchange_v3.sha('mission-exchange-roster/1.0',ro);fp:=mission_exchange_v3.sha('mission-exchange-request/7.0',jsonb_build_object('operation','cycle_open','master',m,'combat',co,'spatial',sp,'round',pr,'roster_sha',rs));o:=mission_exchange_v3.replay(k,'cycle_open',fp);if o is not null then return o;end if;if not public.combat_v2_exchange_context_valid(m,co,pr,'party') or not combat_spatial.exchange_context_valid(sp,m,co)then raise exception using errcode='23514',message='exchange_context_invalid';end if;id:=gen_random_uuid();res:=jsonb_build_object('cycle_id',id,'state','party_open','initiative','party','roster_sha256',rs,'replay',false);insert into mission_exchange_v3.requests values(k,'cycle_open',fp,res,default);insert into mission_exchange_v3.cycles values(id,m,co,sp,pr,null,'party_open','party',ro,rs,k);return res;end$function$;
CREATE OR REPLACE FUNCTION public.mission_exchange_v3_publication_bind(cy uuid, rid uuid, dr uuid, pub uuid, k uuid)
 RETURNS jsonb
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO ''
AS $function$declare c mission_exchange_v3.cycles%rowtype;e mission_exchange_v3.receipts%rowtype;s jsonb;fp text;o jsonb;bh text;id uuid;res jsonb;begin IF exam_regia_private.exchange_scope(cy) IS NOT NULL THEN PERFORM exam_regia_private.assert_exchange(cy); ELSE perform mission_ai_service_owner.service_only(); END IF;IF exam_regia_private.exchange_scope(cy) IS NULL THEN perform mission_exchange_owner.assert_exact_pinset(); END IF;perform pg_advisory_xact_lock(hashtextextended(cy::text,5));select * into strict c from mission_exchange_v3.cycles z where z.id=cy for update;select * into strict e from mission_exchange_v3.receipts z where z.id=rid and z.cycle_id=cy;IF exam_regia_private.is_bound(c.combat_session_id) THEN s:=exam_regia_private.publication_source(cy,rid,dr,pub); ELSE s:=public.mission_exchange_v3_surface_get(rid);if not mission_narrative_internal.exchange_publication_exact(c.master_session_id,rid,e.receipt_sha256,s->>'projection_sha256',dr,pub)then raise exception using errcode='23514',message='exchange_publication_invalid';end if; END IF;fp:=mission_exchange_v3.sha('mission-exchange-request/7.0',jsonb_build_object('operation','publication_bind','cycle',cy,'receipt',rid,'receipt_sha',e.receipt_sha256,'surface_sha',s->>'projection_sha256','dispatch',dr,'publication',pub));o:=mission_exchange_v3.replay(k,'publication_bind',fp);if o is not null then return o;end if;if(e.ordinal=1 and c.state<>'counter_intent_ready' AND NOT (c.state='party_captured' AND exam_regia_private.round_is_final(e.combat_round_id)))or(e.ordinal=2 and c.state<>'counter_captured')then raise exception using errcode='23514',message='exchange_publication_invalid';end if;bh:=mission_exchange_v3.sha('mission-exchange-publication/4.0',jsonb_build_object('cycle',cy,'receipt',rid,'surface_sha',s->>'projection_sha256','dispatch',dr,'publication',pub,'ordinal',e.ordinal));id:=gen_random_uuid();res:=jsonb_build_object('binding_id',id,'binding_sha256',bh,'ordinal',e.ordinal,'replay',false);insert into mission_exchange_v3.requests values(k,'publication_bind',fp,res,default);insert into mission_exchange_v3.publication_bindings values(id,cy,rid,dr,pub,e.ordinal,bh,k);return res;end$function$;
DO $after_seal$ BEGIN IF md5(pg_get_functiondef('public.combat_v2_action_declare(uuid,uuid,jsonb,text,uuid)'::regprocedure)) IS DISTINCT FROM '71a7adff7edd9d57068f4e924c34e771' THEN RAISE EXCEPTION 'exam_exchange_after_definition_drift'; END IF; END $after_seal$;
INSERT INTO exam_regia_private.exchange_composition_seals VALUES('combat_v2_action_declare(uuid,uuid,jsonb,text,uuid)','8d659e3088d2bc20afe1f0c18896e752af2ab5afed07c8dacd70feb533f51a12','9597f8eb8d9da0352377dfaca0ab54f9c18b3484c04b418a656da04ac6838c09','71a7adff7edd9d57068f4e924c34e771',mission_exchange_combat_owner.function_fingerprint('public.combat_v2_action_declare(uuid,uuid,jsonb,text,uuid)'::regprocedure),'postgres','{postgres=X/postgres,authenticated=X/postgres,service_role=X/postgres}');
DO $after_seal$ BEGIN IF md5(pg_get_functiondef('public.combat_v2_exchange_context_valid(uuid,uuid,uuid,text)'::regprocedure)) IS DISTINCT FROM 'e80c353e223bd5ca3c4206acaf18b073' THEN RAISE EXCEPTION 'exam_exchange_after_definition_drift'; END IF; END $after_seal$;
INSERT INTO exam_regia_private.exchange_composition_seals VALUES('combat_v2_exchange_context_valid(uuid,uuid,uuid,text)','35f413c79b2ad810211d723403b9f97e8e6a320b97f753d782fb233b0e826153','35f413c79b2ad810211d723403b9f97e8e6a320b97f753d782fb233b0e826153','e80c353e223bd5ca3c4206acaf18b073',mission_exchange_combat_owner.function_fingerprint('public.combat_v2_exchange_context_valid(uuid,uuid,uuid,text)'::regprocedure),'postgres','{postgres=X/postgres,service_role=X/postgres}');
DO $after_seal$ BEGIN IF md5(pg_get_functiondef('public.combat_v2_exchange_roster_owner(uuid)'::regprocedure)) IS DISTINCT FROM 'd7e19c4117f2cf87d816eddcb55c2ced' THEN RAISE EXCEPTION 'exam_exchange_after_definition_drift'; END IF; END $after_seal$;
INSERT INTO exam_regia_private.exchange_composition_seals VALUES('combat_v2_exchange_roster_owner(uuid)','d5f70048576aae10d0e01c8212d5bc0a559450dfe950c43b36e63cd59c7d6dd8','d5f70048576aae10d0e01c8212d5bc0a559450dfe950c43b36e63cd59c7d6dd8','d7e19c4117f2cf87d816eddcb55c2ced',mission_exchange_combat_owner.function_fingerprint('public.combat_v2_exchange_roster_owner(uuid)'::regprocedure),'postgres','{postgres=X/postgres,service_role=X/postgres}');
DO $after_seal$ BEGIN IF md5(pg_get_functiondef('public.combat_v2_exchange_owner_receipt(uuid)'::regprocedure)) IS DISTINCT FROM 'f9c7caaea99c3491daa4433c2de84eb2' THEN RAISE EXCEPTION 'exam_exchange_after_definition_drift'; END IF; END $after_seal$;
INSERT INTO exam_regia_private.exchange_composition_seals VALUES('combat_v2_exchange_owner_receipt(uuid)','37f0d8da32390252f46e104fa0a5fc15b6ff983a5d614f826d77f8a8fb6b2b57','37f0d8da32390252f46e104fa0a5fc15b6ff983a5d614f826d77f8a8fb6b2b57','f9c7caaea99c3491daa4433c2de84eb2',mission_exchange_combat_owner.function_fingerprint('public.combat_v2_exchange_owner_receipt(uuid)'::regprocedure),'postgres','{postgres=X/postgres,service_role=X/postgres}');
DO $after_seal$ BEGIN IF md5(pg_get_functiondef('public.combat_v2_exchange_counter_intent_owner(uuid,uuid,text)'::regprocedure)) IS DISTINCT FROM '722bcdc072d1bfcdab79302b28baccea' THEN RAISE EXCEPTION 'exam_exchange_after_definition_drift'; END IF; END $after_seal$;
INSERT INTO exam_regia_private.exchange_composition_seals VALUES('combat_v2_exchange_counter_intent_owner(uuid,uuid,text)','d66240fefb0d528c2dc3cb7840b0252f4406a2bb4b978a48b88ad2a128313ef6','d66240fefb0d528c2dc3cb7840b0252f4406a2bb4b978a48b88ad2a128313ef6','722bcdc072d1bfcdab79302b28baccea',mission_exchange_combat_owner.function_fingerprint('public.combat_v2_exchange_counter_intent_owner(uuid,uuid,text)'::regprocedure),'postgres','{postgres=X/postgres,service_role=X/postgres}');

CREATE FUNCTION exam_regia_private.geometry_errors(p_prova uuid) RETURNS jsonb
LANGUAGE plpgsql STABLE SECURITY DEFINER SET search_path='' AS $geometry$
DECLARE b exam_regia_private.bindings%ROWTYPE; a exam_regia_private.admissions%ROWTYPE; t combat_spatial.arena_templates%ROWTYPE;
 errors text[]:='{}'; slots jsonb; objects jsonb;
BEGIN
 SELECT * INTO STRICT b FROM exam_regia_private.bindings WHERE prova_id=p_prova;
 SELECT * INTO STRICT a FROM exam_regia_private.admissions WHERE id=b.admission_id;
 IF a.template_key<>'exam_konoha_10x10_v1' OR a.template_version<>1 OR b.policy_id<>'exam_protected_no_persistent_resources_v1'
 THEN RETURN jsonb_build_array('exam_canonical_template_required'); END IF;
 SELECT * INTO STRICT t FROM combat_spatial.arena_templates WHERE template_key=a.template_key AND template_version=a.template_version;
 SELECT coalesce(jsonb_agg(to_jsonb(s) ORDER BY slot_key),'[]') INTO slots FROM combat_spatial.arena_slots s
 WHERE template_key=t.template_key AND template_version=t.template_version;
 SELECT coalesce(jsonb_agg(to_jsonb(o) ORDER BY object_key),'[]') INTO objects FROM combat_spatial.arena_objects o
 WHERE template_key=t.template_key AND template_version=t.template_version;
 IF to_jsonb(t) IS DISTINCT FROM '{"status":"ready","width_m":10,"height_m":10,"template_key":"exam_konoha_10x10_v1","geometry_hash":"fa8e1d8d2097d9c2a7b75dd8abe42ae5","actor_radius_m":0.5,"contract_version":"exam-arena/1","template_version":1,"required_shape_keys":["A1","A2","A3","A4","A5","A6","A7","A8"],"source_asset_sha256":"1ac91f308fcce1f866c4f90f0686808f1b42e55981f8a83c6b08196488cf0b7d","geometry_contract_id":"exam-konoha-ratified-geometry","geometry_contract_version":1}'::jsonb THEN errors:=array_append(errors,'exam_template_metadata_drift'); END IF;
 IF slots IS DISTINCT FROM '[{"x_m":2,"y_m":5,"slot_key":"PG-A","actor_kind":"PG","template_key":"exam_konoha_10x10_v1","template_version":1},{"x_m":7,"y_m":5,"slot_key":"PNG-A","actor_kind":"PNG","template_key":"exam_konoha_10x10_v1","template_version":1}]'::jsonb THEN errors:=array_append(errors,'exam_exact_two_slots_drift'); END IF;
 IF objects IS DISTINCT FROM '[{"shape":{"cx":1.5,"cy":8,"radius":0.25},"lifecycle":"portable_single_use","object_key":"A1","shape_hash":"391afe057ab571c83c60add42ad2c5e04bd6fd44326d4dc9234363b0b5d3e61d","shape_kind":"circle","object_kind":"substitution_anchor","template_key":"exam_konoha_10x10_v1","is_impervious":false,"substitutable":true,"semantic_label":"palo di legno","blocks_movement":true,"geometry_version":1,"template_version":1},{"shape":{"cx":3,"cy":7,"radius":0.3},"lifecycle":"portable_single_use","object_key":"A2","shape_hash":"4a66874d7a569066726fae099b0c2b2102b1672a9944d4986303bd775ea4f5e3","shape_kind":"circle","object_kind":"substitution_anchor","template_key":"exam_konoha_10x10_v1","is_impervious":false,"substitutable":true,"semantic_label":"cassa di legno piccola","blocks_movement":true,"geometry_version":1,"template_version":1},{"shape":{"cx":6.5,"cy":7.5,"radius":0.25},"lifecycle":"portable_single_use","object_key":"A3","shape_hash":"d2ab92863e0464592455334fc2c4436f050340691a90738a2c53481de21cf94a","shape_kind":"circle","object_kind":"substitution_anchor","template_key":"exam_konoha_10x10_v1","is_impervious":false,"substitutable":true,"semantic_label":"cavalletto di ferro","blocks_movement":true,"geometry_version":1,"template_version":1},{"shape":{"cx":7.5,"cy":6,"radius":0.35},"lifecycle":"portable_single_use","object_key":"A4","shape_hash":"2540fb5e4493ebfed2fc3c611aab0b92ca80171031333409c7f300680f960d5d","shape_kind":"circle","object_kind":"substitution_anchor","template_key":"exam_konoha_10x10_v1","is_impervious":false,"substitutable":true,"semantic_label":"cilindro blu","blocks_movement":true,"geometry_version":1,"template_version":1},{"shape":{"cx":8.5,"cy":5,"radius":0.4},"lifecycle":"portable_single_use","object_key":"A5","shape_hash":"7e7b2ce2f789c209e235c10f09c1df4c6f634653d25e412375b9771b177c188f","shape_kind":"circle","object_kind":"substitution_anchor","template_key":"exam_konoha_10x10_v1","is_impervious":false,"substitutable":true,"semantic_label":"cassa di legno grande","blocks_movement":true,"geometry_version":1,"template_version":1},{"shape":{"cx":1,"cy":2.5,"radius":0.6},"lifecycle":"portable_single_use","object_key":"A6","shape_hash":"568d61efda60fd00cd0572cfa15a462acd2abb7e9663490f24fed50afc27e482","shape_kind":"circle","object_kind":"substitution_anchor","template_key":"exam_konoha_10x10_v1","is_impervious":false,"substitutable":true,"semantic_label":"rotoli di stuoia","blocks_movement":true,"geometry_version":1,"template_version":1},{"shape":{"cx":4.5,"cy":3,"radius":0.25},"lifecycle":"portable_single_use","object_key":"A7","shape_hash":"628337f9c308dd30e993778c843864b4a5ff3a49fab0cc0139d91ce5127c0f43","shape_kind":"circle","object_kind":"substitution_anchor","template_key":"exam_konoha_10x10_v1","is_impervious":false,"substitutable":true,"semantic_label":"cavalletto di legno","blocks_movement":true,"geometry_version":1,"template_version":1},{"shape":{"cx":5.5,"cy":3.5,"radius":0.25},"lifecycle":"portable_single_use","object_key":"A8","shape_hash":"be043feb232f1f1a77efa5bd40f39510116a5eb94b163c7a8e6487c68dd5dd33","shape_kind":"circle","object_kind":"substitution_anchor","template_key":"exam_konoha_10x10_v1","is_impervious":false,"substitutable":true,"semantic_label":"secondo cavalletto di legno","blocks_movement":true,"geometry_version":1,"template_version":1}]'::jsonb THEN errors:=array_append(errors,'exam_exact_eight_anchors_drift'); END IF;
 IF t.geometry_hash IS DISTINCT FROM combat_spatial.geometry_fingerprint(t.template_key,t.template_version)
 THEN errors:=array_append(errors,'exam_geometry_hash_drift'); END IF;
 IF EXISTS(SELECT 1 FROM combat_spatial.arena_slots s WHERE s.template_key=t.template_key AND s.template_version=t.template_version
 AND NOT clan_marionettisti_private.scene_slot_legal(t.template_key,t.template_version,round(s.x_m),round(s.y_m),t.actor_radius_m))
 THEN errors:=array_append(errors,'exam_spawn_clearance'); END IF;
 RETURN to_jsonb(errors);
END $geometry$;


-- Factory e lifecycle usano le schede Esame esistenti, senza effetti permanenti.
CREATE FUNCTION exam_regia_private.profile_snapshot(p_profile uuid)
RETURNS exam_regia_private.profile_templates LANGUAGE plpgsql SECURITY DEFINER SET search_path='' AS $fn$
DECLARE e public.esame_png_profili%ROWTYPE; a public.ai_agents%ROWTYPE;
 row exam_regia_private.profile_templates%ROWTYPE; snap jsonb; abilities jsonb; src text; tid uuid;
BEGIN
 SELECT * INTO STRICT e FROM public.esame_png_profili WHERE id=p_profile AND is_active FOR SHARE;
 SELECT * INTO STRICT a FROM public.ai_agents WHERE id=e.agent_id AND is_active FOR SHARE;
 SELECT coalesce(jsonb_agg(jsonb_build_object('source','jutsu','id',j.id,'name',j.name_it,
  'kind',coalesce(j.category,'fisico'),'usage',j.uso,'defensive',coalesce(j.difensiva,false),
  'di_scena',coalesce(j.di_scena,false),'diversivo',coalesce(j.diversivo,false),
  'consumption_type','ad_utilizzo','range',j.gittata,'chakra_cost',coalesce(j.chakra_cost,0),
  'damage_base',coalesce(j.damage_base,0),'element',j.nature) ORDER BY j.id),'[]'::jsonb)
 INTO abilities FROM public.jutsu j WHERE j.id=ANY(e.repertorio) AND j.is_active;
 IF jsonb_array_length(abilities)<>cardinality(e.repertorio) THEN
  RAISE EXCEPTION 'exam_regia_profile_catalog_incomplete' USING ERRCODE='55000'; END IF;
 abilities:=combat_v2_multitarget_internal.enrich_abilities_v1(abilities);
 snap:=jsonb_build_object('name',e.nome,'vita',e.vita_max,'vita_max',e.vita_max,
  'chakra',e.chakra_max,'chakra_max',e.chakra_max,'taijutsu',e.taijutsu,'ninjutsu',e.ninjutsu,
  'genjutsu',e.genjutsu,'forza',e.forza,'velocita',e.velocita,'mente',e.mente,
  'resistenza',e.resistenza,'fuuinjutsu',e.fuuinjutsu,'slancio',0,'abilities',abilities);
 src:=public.combat_v2_sha256(jsonb_build_object('profile',to_jsonb(e),'persona',a.persona,'snapshot',snap));
 PERFORM pg_advisory_xact_lock(hashtextextended('exam-regia-template:'||p_profile::text,731));
 SELECT * INTO row FROM exam_regia_private.profile_templates WHERE profile_id=p_profile AND source_sha256=src;
 IF FOUND THEN RETURN row; END IF;
 INSERT INTO public.png_templates(nome,epiteto,grado,taijutsu,ninjutsu,genjutsu,forza,velocita,mente,resistenza,
  fuuinjutsu,vita_max,chakra_max,abilita,note,is_active,created_by)
 VALUES(e.nome,e.epiteto,'D',e.taijutsu,e.ninjutsu,e.genjutsu,e.forza,e.velocita,e.mente,e.resistenza,
  e.fuuinjutsu,e.vita_max,e.chakra_max,abilities,'Fonte Esame '||e.id::text||' @ '||src,false,NULL) RETURNING id INTO tid;
 INSERT INTO exam_regia_private.profile_templates(profile_id,source_sha256,template_id,persona,snapshot)
 VALUES(e.id,src,tid,a.persona::text,snap) RETURNING * INTO row;
 RETURN row;
END $fn$;

CREATE FUNCTION exam_regia_private.bind_geometry(p_prova uuid)
RETURNS uuid LANGUAGE plpgsql SECURITY DEFINER SET search_path='' AS $fn$
DECLARE b exam_regia_private.bindings%ROWTYPE; adm exam_regia_private.admissions%ROWTYPE;
 arena combat_spatial.arena_instances%ROWTYPE; t combat_spatial.arena_templates%ROWTYPE;
 pid uuid:=gen_random_uuid(); scene_claim uuid:=gen_random_uuid();
BEGIN
 SELECT * INTO STRICT b FROM exam_regia_private.bindings WHERE prova_id=p_prova FOR UPDATE;
 SELECT * INTO STRICT adm FROM exam_regia_private.admissions WHERE id=b.admission_id;
 SELECT * INTO STRICT arena FROM combat_spatial.arena_instances WHERE instance_id=md5('exam-instance|'||p_prova)::uuid FOR UPDATE;
 SELECT * INTO STRICT t FROM combat_spatial.arena_templates WHERE template_key=adm.template_key AND template_version=adm.template_version;
 IF arena.encounter_id<>b.combat_session_id OR arena.master_session_id<>b.master_session_id OR arena.state<>'open'
 OR arena.binding_id IS DISTINCT FROM b.native_arena_binding_id OR arena.template_key<>adm.template_key OR arena.template_version<>adm.template_version OR arena.panel_claim_id IS NOT NULL
 OR exam_regia_private.geometry_errors(p_prova)<>'[]'::jsonb
 OR (SELECT count(*) FROM combat_spatial.actor_states WHERE instance_id=arena.instance_id)<>2
 OR NOT EXISTS(SELECT 1 FROM combat_spatial.actor_states WHERE instance_id=arena.instance_id AND actor_id=b.player_actor_id
 AND actor_kind='PG' AND controller_principal_id=b.owner_user AND projection_subject_id=b.character_id AND state='active')
 OR NOT EXISTS(SELECT 1 FROM combat_spatial.actor_states st JOIN public.esame_prove p ON p.id=b.prova_id
 WHERE st.instance_id=arena.instance_id AND st.actor_id=b.png_actor_id AND st.actor_kind='PNG' AND st.projection_subject_id=p.profilo_id AND st.state='active')
 THEN RAISE EXCEPTION 'exam_regia_native_geometry_mismatch' USING ERRCODE='40001'; END IF;
 INSERT INTO combat_panel_private.master_scene_profiles(id,location_id,label,template_key,template_version,
 geometry_fingerprint,policy_id,visibility_mode,enabled)
 VALUES(pid,b.location_id,'Prova Genin',t.template_key,t.template_version,t.geometry_hash,b.policy_id,'participants',false);
 INSERT INTO combat_panel_private.master_scene_claims(id,profile_id,profile_version,master_session_id,encounter_id,
 template_key,template_version,authority_principal_id,authority_control_version,geometry_fingerprint,roster_fingerprint,policy_id,visibility_mode)
 VALUES(scene_claim,pid,1,b.master_session_id,b.combat_session_id,t.template_key,t.template_version,b.service_principal_id,1,
 t.geometry_hash,combat_panel_private.master_roster_fingerprint(b.combat_session_id),b.policy_id,'participants');
 UPDATE combat_spatial.arena_instances SET context_source='panel_master',panel_claim_id=scene_claim,binding_id=NULL WHERE instance_id=arena.instance_id;
 UPDATE combat_spatial.actor_states SET controller_principal_id=b.service_principal_id WHERE instance_id=arena.instance_id AND actor_id=b.png_actor_id;
 INSERT INTO combat_spatial.viewer_grants(instance_id,viewer_principal_id,subject_actor_id,can_view_map,can_view_objects,grant_version)
 SELECT arena.instance_id,b.service_principal_id,st.actor_id,true,true,1
 FROM combat_spatial.actor_states st WHERE st.instance_id=arena.instance_id;
 UPDATE public.combat_v2_actors a SET position_m=st.x_m::integer FROM combat_spatial.actor_states st
 WHERE st.instance_id=arena.instance_id AND a.id=st.actor_id AND a.session_id=b.combat_session_id;
 RETURN arena.instance_id;
END $fn$;

-- Le tre estensioni sono vincolate alla riga nuova già attestata, mai a is_test da solo.
ALTER TABLE mission_exam_private.protected_sessions DROP CONSTRAINT protected_sessions_character_id_check;
ALTER TABLE mission_exam_private.protected_sessions DROP CONSTRAINT protected_sessions_location_id_check;
ALTER TABLE mission_exam_private.protected_sessions DROP CONSTRAINT protected_sessions_policy_version_check;
CREATE FUNCTION exam_regia_private.protected_binding_valid(p_class uuid,p_owner uuid,p_character uuid,p_location uuid)
RETURNS boolean LANGUAGE sql VOLATILE SECURITY DEFINER SET search_path='' AS $fn$
 SELECT EXISTS(SELECT 1 FROM exam_regia_private.bindings b JOIN exam_regia_private.admissions a ON a.id=b.admission_id
 WHERE b.class_session_id=p_class AND b.owner_user=p_owner AND b.character_id=p_character AND b.location_id=p_location
 AND (a.owner_user,a.character_id,a.location_id)=(b.owner_user,b.character_id,b.location_id))
 OR EXISTS(SELECT 1 FROM mission_exam_private.open_requests req JOIN exam_regia_private.admissions a ON a.id=req.exam_regia_admission_id
 WHERE req.class_session_id=p_class AND req.owner_user=p_owner AND req.transaction_id=txid_current()
 AND (a.owner_user,a.character_id,a.location_id)=(p_owner,p_character,p_location)
 AND exam_regia_private.native_open_allowed(p_owner,p_character,p_location));
$fn$;
ALTER TABLE mission_exam_private.protected_sessions ADD CONSTRAINT protected_sessions_character_id_check CHECK(
 character_id='f335b077-34a1-41c3-94aa-58ec674b649b'::uuid OR exam_regia_private.protected_binding_valid(class_session_id,owner_user,character_id,location_id));
ALTER TABLE mission_exam_private.protected_sessions ADD CONSTRAINT protected_sessions_location_id_check CHECK(
 location_id='df83cd65-b13d-49d6-ad77-a44f35d5ea00'::uuid OR exam_regia_private.protected_binding_valid(class_session_id,owner_user,character_id,location_id));
ALTER TABLE mission_exam_private.protected_sessions ADD CONSTRAINT protected_sessions_policy_version_check CHECK(
 policy_version='tamako-konoha-no-progression/1' OR (policy_version='exam_protected_no_persistent_resources_v1'
 AND exam_regia_private.protected_binding_valid(class_session_id,owner_user,character_id,location_id)));

CREATE FUNCTION public.esame_regia_readiness(p_location uuid) RETURNS jsonb
LANGUAGE plpgsql STABLE SECURITY DEFINER SET search_path='' AS $fn$
DECLARE adm exam_regia_private.admissions%ROWTYPE; runtime exam_regia_private.runtime%ROWTYPE;
 b exam_regia_private.bindings%ROWTYPE; ready boolean:=false; reason text; eligible boolean:=false;
BEGIN
 SELECT * INTO STRICT runtime FROM exam_regia_private.runtime WHERE singleton;
 IF auth.uid() IS NOT NULL AND p_location IS NOT NULL THEN
  SELECT a.* INTO adm FROM exam_regia_private.admissions a JOIN public.characters c ON c.id=a.character_id AND c.user_id=a.owner_user
   JOIN public.locations l ON l.id=a.location_id AND l.is_active WHERE a.owner_user=auth.uid()
   AND a.location_id=p_location AND a.enabled AND a.expires_at>clock_timestamp();
  eligible:=FOUND;
 END IF;
 IF eligible THEN
  SELECT * INTO b FROM exam_regia_private.bindings WHERE owner_user=auth.uid() AND state<>'closed';
  ready:=runtime.enabled AND EXISTS(SELECT 1 FROM public.esame_png_profili e
   JOIN public.ai_agents agent ON agent.id=e.agent_id AND agent.is_active WHERE e.is_active)
   AND EXISTS(SELECT 1 FROM combat_spatial.arena_templates t WHERE t.template_key=adm.template_key
    AND t.template_version=adm.template_version AND t.status='ready');
  IF NOT runtime.enabled THEN reason:='release_not_enabled';
  ELSIF EXISTS(SELECT 1 FROM public.master_v2_sessions m WHERE m.location_id=p_location AND m.stato NOT IN ('chiusa','annullata')
    AND m.id IS DISTINCT FROM b.master_session_id)
   OR EXISTS(SELECT 1 FROM public.combat_v2_sessions s WHERE s.location_id=p_location AND s.closed_at IS NULL
    AND s.state NOT IN ('chiuso','annullato') AND s.id IS DISTINCT FROM b.combat_session_id)
   OR EXISTS(SELECT 1 FROM public.combat_sessions s WHERE s.location_id=p_location AND s.state='aperto')
   OR EXISTS(SELECT 1 FROM public.academy_class_sessions s WHERE s.location_id=p_location AND s.state<>'closed'
    AND s.id IS DISTINCT FROM b.class_session_id) THEN ready:=false;reason:='location_busy';
  ELSIF NOT ready THEN reason:='sources_not_ready'; END IF;
 ELSE reason:='not_eligible'; END IF;
 RETURN jsonb_build_object('ok',true,'version','EXAM-REGIA17/1','eligible',eligible,'ready',ready,'protected',eligible,
  'location_id',p_location,'candidate_character',adm.character_id,'existing_prova',b.prova_id,'reason',reason,
  'budget',CASE WHEN eligible THEN jsonb_build_object('used',0,'limit',runtime.provider_call_cap) ELSE NULL END,
  'capabilities',jsonb_build_object('common_combat',ready,'movement',ready,'substitution',ready,'multiplication',ready,'ai_controller',ready));
END $fn$;

CREATE FUNCTION exam_regia_private.binding_wire(p_prova uuid) RETURNS jsonb
LANGUAGE sql STABLE SECURITY DEFINER SET search_path='' AS $fn$
 SELECT jsonb_build_object('master_session_id',b.master_session_id,'combat_session_id',b.combat_session_id,
 'player_actor_id',b.player_actor_id,'png_actor_id',b.png_actor_id,'profile_id',p.profilo_id,
 'arena',jsonb_build_object('template_key',i.template_key,'template_version',i.template_version))
 FROM exam_regia_private.bindings b JOIN public.esame_prove p ON p.id=b.prova_id
 JOIN combat_spatial.arena_instances i ON i.encounter_id=b.combat_session_id WHERE b.prova_id=p_prova;
$fn$;
CREATE FUNCTION exam_regia_private.attach_native(p_prova uuid,p_request uuid) RETURNS jsonb
LANGUAGE plpgsql SECURITY DEFINER SET search_path='' AS $fn$
DECLARE b exam_regia_private.bindings%ROWTYPE; adm exam_regia_private.admissions%ROWTYPE;
 proof public.esame_prove%ROWTYPE; q mission_exam_private.protected_sessions%ROWTYPE; h public.esame_supervisione%ROWTYPE;
 c public.characters%ROWTYPE; e public.esame_png_profili%ROWTYPE; cache exam_regia_private.profile_templates%ROWTYPE;
 pg jsonb; png uuid:=gen_random_uuid(); rid uuid:=gen_random_uuid(); master uuid:=md5('exam-master|'||p_prova)::uuid;
 pa uuid:=md5('exam-candidate|'||p_prova)::uuid; na uuid:=md5('exam-png|'||p_prova)::uuid;
BEGIN
 SELECT * INTO STRICT proof FROM public.esame_prove WHERE id=p_prova AND candidate_user=auth.uid() AND stato='aperta' FOR UPDATE;
 SELECT * INTO STRICT q FROM mission_exam_private.protected_sessions WHERE prova_id=proof.id AND state='active' AND owner_user=auth.uid() FOR UPDATE;
 SELECT * INTO STRICT h FROM public.esame_supervisione WHERE prova=proof.id AND chiusa_at IS NULL FOR UPDATE;
 SELECT * INTO STRICT adm FROM exam_regia_private.admissions WHERE owner_user=auth.uid() AND character_id=proof.candidate_character
 AND location_id=q.location_id AND enabled AND expires_at>clock_timestamp() FOR SHARE;
 IF q.request_id<>p_request OR q.class_session_id<>proof.class_session_id OR q.character_id<>proof.candidate_character
 OR h.apertura_pubblicata OR h.apertura_ricevuta IS NULL OR h.player_ready OR h.publishing
 OR NOT EXISTS(SELECT 1 FROM mission_exam_private.open_requests req WHERE req.request_id=p_request AND req.class_session_id=proof.class_session_id
 AND req.owner_user=auth.uid() AND req.transaction_id=txid_current())
 OR EXISTS(SELECT 1 FROM public.esame_supervisione_bozze WHERE prova=proof.id)
 OR EXISTS(SELECT 1 FROM public.esame_scambi WHERE prova_id=proof.id)
 THEN RAISE EXCEPTION 'exam_regia_native_fresh_open_required' USING ERRCODE='42501'; END IF;
 SELECT * INTO STRICT c FROM public.characters WHERE id=proof.candidate_character AND user_id=auth.uid();
 SELECT * INTO STRICT e FROM public.esame_png_profili WHERE id=proof.profilo_id;
 cache:=exam_regia_private.profile_snapshot(proof.profilo_id);
 pg:=public.combat_v2_character_snapshot(c.id)||jsonb_build_object('vita',proof.pv_cand,'vita_max',proof.pv_cand_max,
 'chakra',proof.ck_cand,'chakra_max',proof.ck_cand_max);
 INSERT INTO exam_regia_private.bindings(prova_id,admission_id,native_arena_binding_id,class_session_id,master_session_id,combat_session_id,
 player_actor_id,png_actor_id,owner_user,character_id,location_id,request_key,receipt_id)
 VALUES(proof.id,adm.id,(SELECT binding_id FROM combat_spatial.arena_instances WHERE encounter_id=proof.id),proof.class_session_id,master,proof.id,pa,na,auth.uid(),c.id,q.location_id,p_request,h.apertura_ricevuta)
 RETURNING * INTO b;
 INSERT INTO public.master_v2_sessions(id,location_id,tipo,owner_kind,master_user,titolo,stato)
 VALUES(master,q.location_id,'duello','ai_service',NULL,'Prova Genin','preparazione');
 INSERT INTO public.combat_v2_sessions(id,source_kind,master_session_id,location_id,state,lesiva)
 VALUES(proof.id,'master',master,q.location_id,'in_corso',false);
 INSERT INTO public.master_v2_participants(session_id,character_id,user_id_snapshot) VALUES(master,c.id,auth.uid());
 INSERT INTO public.combat_v2_png_instances(id,session_id,template_id,client_ref,nome,snapshot)
 VALUES(png,proof.id,cache.template_id,na,e.nome,cache.snapshot);
 INSERT INTO public.combat_v2_actors(id,session_id,actor_kind,character_id,png_instance_id,controller_user,team_key,initiative_snapshot,mechanics_snapshot)
 VALUES(pa,proof.id,'pg',c.id,NULL,auth.uid(),'candidato',c.velocita,pg),(na,proof.id,'png',NULL,png,NULL,'sfidante',e.velocita,cache.snapshot);
 INSERT INTO public.combat_v2_rounds(id,session_id,round_no,evaluation_mode) VALUES(rid,proof.id,1,'neutra');
 PERFORM combat_panel_private.enroll_master(master);
 PERFORM exam_regia_private.bind_geometry(proof.id);
 UPDATE public.master_v2_sessions SET stato='in_corso' WHERE id=master;
 RETURN jsonb_build_object('ok',true,'version','EXAM-REGIA17/1','prova',proof.id,'class_session_id',proof.class_session_id,
 'protected',true,'binding',exam_regia_private.binding_wire(proof.id),'budget',jsonb_build_object('used',q.provider_calls,'limit',q.provider_call_cap));
END $fn$;
CREATE FUNCTION public.esame_regia_open(p_location uuid,p_request uuid) RETURNS jsonb
LANGUAGE plpgsql SECURITY DEFINER SET search_path='' AS $fn$
DECLARE ready jsonb; native jsonb; adm exam_regia_private.admissions%ROWTYPE; b exam_regia_private.bindings%ROWTYPE; sess uuid; proof uuid;
BEGIN
 IF auth.uid() IS NULL OR p_location IS NULL OR p_request IS NULL THEN RAISE EXCEPTION 'exam_regia_auth_required' USING ERRCODE='42501'; END IF;
 PERFORM pg_advisory_xact_lock(hashtextextended('exam-regia-owner:'||auth.uid()::text,731));
 PERFORM 1 FROM public.locations WHERE id=p_location AND is_active FOR UPDATE;
 SELECT * INTO b FROM exam_regia_private.bindings WHERE owner_user=auth.uid() AND request_key=p_request;
 IF FOUND THEN
 IF b.state='closed' OR b.location_id<>p_location THEN RAISE EXCEPTION 'exam_regia_request_closed_or_conflict' USING ERRCODE='55000'; END IF;
 RETURN jsonb_build_object('ok',true,'version','EXAM-REGIA17/1','prova',b.prova_id,'class_session_id',b.class_session_id,
 'protected',true,'binding',exam_regia_private.binding_wire(b.prova_id),'budget',public.esame_regia_state(b.prova_id)->'budget'); END IF;
 ready:=public.esame_regia_readiness(p_location);
 IF ready->>'eligible'<>'true' OR ready->>'ready'<>'true' OR NOT coalesce(public._combat_presente(auth.uid(),p_location),false)
 THEN RAISE EXCEPTION 'exam_regia_not_ready' USING ERRCODE='55000'; END IF;
 IF EXISTS(SELECT 1 FROM public.esame_prove WHERE candidate_user=auth.uid() AND stato='aperta')
 OR EXISTS(SELECT 1 FROM exam_regia_private.bindings WHERE owner_user=auth.uid() AND state<>'closed')
 THEN RAISE EXCEPTION 'exam_regia_existing_activity' USING ERRCODE='55000'; END IF;
 SELECT * INTO STRICT adm FROM exam_regia_private.admissions WHERE owner_user=auth.uid() AND location_id=p_location
 AND enabled AND expires_at>clock_timestamp() FOR SHARE;
 IF adm.surface='konoha' THEN
 native:=public.esame_session_open(p_request); proof:=(native->>'prova')::uuid;
 ELSE
 INSERT INTO mission_exam_private.open_requests(request_id,owner_user,transaction_id,exam_regia_admission_id)
 VALUES(p_request,auth.uid(),txid_current(),adm.id);
 INSERT INTO public.esame_supervisione_prenotazioni(personaggio,luogo,autore) VALUES(adm.character_id,p_location,auth.uid());
 sess:=public.esame_avvia(p_location);
 SELECT q.prova_id INTO STRICT proof FROM mission_exam_private.protected_sessions q
 WHERE q.class_session_id=sess AND q.owner_user=auth.uid() AND q.state='active';
 END IF;
 RETURN exam_regia_private.attach_native(proof,p_request);
END $fn$;


CREATE FUNCTION exam_regia_private.round_is_final(p_round uuid) RETURNS boolean
LANGUAGE sql STABLE SECURITY DEFINER SET search_path='' AS $fn$
 SELECT EXISTS(SELECT 1 FROM public.combat_v2_rounds r JOIN exam_regia_private.bindings b ON b.combat_session_id=r.session_id
 WHERE r.id=p_round AND r.exam_captured_receipt_id IS NULL AND (r.round_no>=8 OR EXISTS(SELECT 1 FROM public.combat_v2_actors a WHERE a.session_id=r.session_id
 AND a.companion_id IS NULL AND (a.state<>'attivo' OR (a.mechanics_snapshot->>'vita')::integer<=0 OR (a.mechanics_snapshot->>'chakra')::integer<=0))));
$fn$;
CREATE FUNCTION exam_regia_private.assert_actor_dispatch(p_round uuid,p_actor uuid,p_request uuid) RETURNS void
LANGUAGE plpgsql SECURITY DEFINER SET search_path='' AS $fn$
DECLARE b exam_regia_private.bindings%ROWTYPE;
BEGIN
 SELECT x.* INTO b FROM exam_regia_private.bindings x JOIN public.combat_v2_rounds r ON r.session_id=x.combat_session_id WHERE r.id=p_round;
 IF NOT FOUND THEN RETURN; END IF;
 IF NOT EXISTS(SELECT 1 FROM exam_regia_private.runtime WHERE singleton AND enabled)
 OR b.state<>'active' OR p_actor NOT IN (b.player_actor_id,b.png_actor_id)
 OR NOT EXISTS(SELECT 1 FROM exam_regia_private.execution_permits p WHERE p.prova_id=b.prova_id AND p.actor_id=p_actor
  AND p.principal_id=exam_regia_private.current_principal() AND p.request_key=p_request AND p.operation='commit'
  AND p.transaction_id=txid_current() AND p.backend_pid=pg_backend_pid() AND p.consumed_at IS NULL) THEN
 RAISE EXCEPTION 'exam_regia_command_port_required' USING ERRCODE='42501'; END IF;
END $fn$;
CREATE FUNCTION exam_regia_private.assert_substitution_dispatch(p_option uuid,p_request uuid) RETURNS void
LANGUAGE plpgsql SECURITY DEFINER SET search_path='' AS $fn$
DECLARE link record;
BEGIN
 SELECT l.activity_round_id,l.defender_actor_id INTO link FROM combat_spatial.substitution_activity_options o
 JOIN combat_spatial.substitution_activity_links l ON l.link_id=o.link_id
 JOIN public.combat_v2_rounds r ON r.id=l.activity_round_id
 JOIN exam_regia_private.bindings b ON b.combat_session_id=r.session_id
 WHERE o.capability_id=p_option;
 IF FOUND THEN PERFORM exam_regia_private.assert_actor_dispatch(link.activity_round_id,link.defender_actor_id,p_request); END IF;
END $fn$;
CREATE FUNCTION exam_regia_private.assert_event_dispatch(p_scope uuid,p_request uuid,p_operation text) RETURNS void
LANGUAGE plpgsql SECURITY DEFINER SET search_path='' AS $fn$
DECLARE b exam_regia_private.bindings%ROWTYPE; expected text;
BEGIN
 SELECT x.* INTO b FROM exam_regia_private.bindings x WHERE x.master_session_id=p_scope OR x.combat_session_id=p_scope
 OR EXISTS(SELECT 1 FROM public.combat_v2_rounds r WHERE r.id=p_scope AND r.session_id=x.combat_session_id);
 IF NOT FOUND THEN RETURN; END IF;
 expected:=CASE p_operation WHEN 'combat_v2_round_resolve' THEN 'resolve'
  WHEN 'combat_v2_action_declare' THEN 'commit' WHEN 'combat_v2_defense_declare' THEN 'commit' END;
 IF NOT EXISTS(SELECT 1 FROM exam_regia_private.runtime WHERE singleton AND enabled)
 OR b.state<>'active' OR expected IS NULL OR NOT EXISTS(SELECT 1 FROM exam_regia_private.execution_permits p
 WHERE p.prova_id=b.prova_id AND p.operation=expected AND p.request_key=p_request
 AND p.principal_id=exam_regia_private.current_principal() AND p.transaction_id=txid_current()
 AND p.backend_pid=pg_backend_pid() AND p.consumed_at IS NULL
 AND p.created_at>clock_timestamp()-interval '150 seconds'
 AND (expected<>'resolve' OR (auth.uid() IS NULL AND public.combat_v2_is_service())))
 THEN RAISE EXCEPTION 'exam_regia_native_port_required' USING ERRCODE='42501'; END IF;
END $fn$;
CREATE FUNCTION exam_regia_private.advance(p_prova uuid) RETURNS void
LANGUAGE plpgsql SECURITY DEFINER SET search_path='' AS $fn$
DECLARE b exam_regia_private.bindings%ROWTYPE; r public.combat_v2_rounds%ROWTYPE; next_kind text; receipt uuid;
BEGIN
 SELECT * INTO STRICT b FROM exam_regia_private.bindings WHERE prova_id=p_prova FOR UPDATE;
 IF b.state IN ('opening','closed','paused','congedo') THEN RETURN; END IF;
 SELECT * INTO STRICT r FROM public.combat_v2_rounds WHERE session_id=b.combat_session_id ORDER BY round_no DESC LIMIT 1;
 IF r.state IN ('risolto','narrazione') THEN next_kind:='narration';
 ELSIF r.phase='raccolta_azioni' THEN
  IF NOT EXISTS(SELECT 1 FROM public.combat_v2_declarations WHERE round_id=r.id AND actor_id=b.player_actor_id
   AND kind IN ('attacco','movimento','utilita','passa')) THEN next_kind:='player';
  ELSIF NOT EXISTS(SELECT 1 FROM public.combat_v2_declarations WHERE round_id=r.id AND actor_id=b.png_actor_id
   AND kind IN ('attacco','movimento','utilita','passa')) THEN next_kind:='choice';
  ELSE RAISE EXCEPTION 'exam_regia_native_phase_stale' USING ERRCODE='55000'; END IF;
 ELSE
  IF EXISTS(SELECT 1 FROM public.combat_v2_attack_targets WHERE round_id=r.id AND target_actor_id=b.png_actor_id AND state='attesa_difesa') THEN
   next_kind:='choice';
  ELSIF EXISTS(SELECT 1 FROM public.combat_v2_attack_targets WHERE round_id=r.id AND target_actor_id=b.player_actor_id AND state='attesa_difesa') THEN
   next_kind:='player';
  ELSIF combat_v2_multitarget_internal.round_complete(r.id) THEN next_kind:='narration';
  ELSE RAISE EXCEPTION 'exam_regia_incomplete_round' USING ERRCODE='55000'; END IF;
 END IF;
 IF next_kind IN ('choice','narration') THEN
  receipt:=gen_random_uuid();
  INSERT INTO exam_regia_private.receipts(id,prova_id,kind,round_id,phase) VALUES(receipt,b.prova_id,next_kind,r.id,r.phase);
 ELSE receipt:=gen_random_uuid(); END IF;
 UPDATE exam_regia_private.bindings SET receipt_id=receipt,receipt_kind=next_kind,updated_at=clock_timestamp()
 WHERE prova_id=b.prova_id;
 UPDATE public.esame_prove SET opzioni_id=receipt,opzioni_at=clock_timestamp(),scambio=least(r.round_no,4),beat=least(r.round_no,4),
 meta='candidato',fase='attacco',updated_at=clock_timestamp() WHERE id=b.prova_id;
 UPDATE public.esame_supervisione SET player_ready=next_kind='player',publishing=false,idle_deadline=NULL WHERE prova=b.prova_id;
END $fn$;

CREATE FUNCTION public.esame_regia_state(p_prova uuid) RETURNS jsonb
LANGUAGE plpgsql SECURITY DEFINER SET search_path='' AS $fn$
DECLARE b exam_regia_private.bindings%ROWTYPE; h public.esame_supervisione%ROWTYPE;
 q mission_exam_private.protected_sessions%ROWTYPE; d public.esame_supervisione_bozze%ROWTYPE; r public.combat_v2_rounds%ROWTYPE;
 next_step text; player boolean; native_state jsonb;
BEGIN
 b:=exam_regia_private.assert_owner(p_prova,true);
 SELECT * INTO STRICT h FROM public.esame_supervisione WHERE prova=p_prova;
 SELECT * INTO STRICT q FROM mission_exam_private.protected_sessions WHERE prova_id=p_prova;
 SELECT * INTO r FROM public.combat_v2_rounds WHERE session_id=b.combat_session_id ORDER BY round_no DESC LIMIT 1;
 IF b.receipt_kind='narration' THEN SELECT rr.* INTO STRICT r FROM public.combat_v2_rounds rr JOIN exam_regia_private.receipts qr ON qr.round_id=rr.id WHERE qr.id=b.receipt_id; END IF;
 SELECT * INTO d FROM public.esame_supervisione_bozze WHERE prova=p_prova AND ricevuta=b.receipt_id;
 player:=b.state IN ('active','congedo') AND b.receipt_kind='player' AND h.apertura_pubblicata AND h.player_ready AND NOT h.publishing;
 next_step:=CASE WHEN b.state='closed' THEN 'complete' WHEN b.state='paused' OR d.stato='errore' THEN 'paused'
 WHEN h.publishing OR d.stato='generazione' THEN 'waiting' WHEN d.stato='pronta' THEN 'publish'
 WHEN player THEN 'player' WHEN d.stato='autorizzata' THEN 'generate'
 WHEN b.receipt_kind IN ('opening','choice','narration') AND d.id IS NULL THEN 'authorize' ELSE 'waiting' END;
 IF b.state='opening' THEN
 native_state:=public.esame_session_state(p_prova);
 RETURN native_state||jsonb_build_object('version','EXAM-REGIA17/1','status','opening','phase','opening','next',next_step,
 'round_no',exam_regia_private.logical_round_no(r.id),'max_rounds',4,'exchange',exam_regia_private.exchange_wire(r.id),'binding',exam_regia_private.binding_wire(b.prova_id));
 END IF;
 RETURN jsonb_build_object('ok',true,'version','EXAM-REGIA17/1','prova',p_prova,'protected',true,'status',b.state,
 'phase',CASE WHEN b.state='congedo' THEN 'uscita' ELSE b.receipt_kind END,'next',next_step,'receipt_id',b.receipt_id,
 'player_ready',player,'publishing',h.publishing,'opening_published',h.apertura_pubblicata,'closed',b.state='closed',
 'round_no',exam_regia_private.logical_round_no(r.id),'max_rounds',4,'exchange',exam_regia_private.exchange_wire(r.id),'binding',exam_regia_private.binding_wire(b.prova_id),
 'budget',jsonb_build_object('used',q.provider_calls,'limit',q.provider_call_cap),
 'draft',CASE WHEN d.id IS NULL THEN NULL ELSE jsonb_build_object('id',d.id,'status',d.stato,'sha',d.sha,
 'result_ok',coalesce(d.risultato->>'ok'='true',false),'publishable',coalesce(d.risultato->>'publishable'='true',false),
 'version',d.risultato->>'validator_version') END,'error',CASE WHEN d.stato='errore' THEN 'generation_error' ELSE NULL END);
END $fn$;

CREATE FUNCTION exam_regia_private.panel_binding(p_location uuid,p_actor uuid,p_command boolean DEFAULT false)
RETURNS exam_regia_private.bindings LANGUAGE plpgsql SECURITY DEFINER SET search_path='' AS $fn$
DECLARE b exam_regia_private.bindings%ROWTYPE;
BEGIN
 SELECT x.* INTO b FROM exam_regia_private.bindings x WHERE x.owner_user=auth.uid() AND x.location_id=p_location AND x.state<>'closed' FOR UPDATE;
 IF NOT FOUND OR (p_actor IS NOT NULL AND p_actor<>b.player_actor_id) THEN
 RAISE EXCEPTION 'exam_regia_actor_not_owned' USING ERRCODE='42501'; END IF;
 IF p_command AND (NOT EXISTS(SELECT 1 FROM exam_regia_private.runtime WHERE singleton AND enabled) OR b.state<>'active' OR b.receipt_kind<>'player'
 OR NOT coalesce(public._combat_presente(auth.uid(),b.location_id),false)
 OR NOT EXISTS(SELECT 1 FROM public.esame_supervisione h WHERE h.prova=b.prova_id AND h.player_ready AND h.apertura_pubblicata AND NOT h.publishing))
 THEN RAISE EXCEPTION 'exam_regia_player_not_ready' USING ERRCODE='55000'; END IF;
 RETURN b;
END $fn$;
CREATE FUNCTION exam_regia_private.filter_options(p_envelope jsonb) RETURNS jsonb
LANGUAGE plpgsql SECURITY DEFINER SET search_path='' AS $fn$
DECLARE c uuid; result jsonb;
BEGIN
 SELECT id INTO STRICT c FROM combat_panel_private.contexts WHERE principal_user=exam_regia_private.current_principal()
 AND activity_id=(p_envelope#>>'{context,activity_id}')::uuid
 AND command_actor_id=(p_envelope#>>'{viewer,command_actor_id}')::uuid
 AND context_version=(p_envelope#>>'{context,version}')::bigint;
 UPDATE combat_panel_private.offers SET state='revoked' WHERE context_id=c AND state='offered'
 AND (kind='administration' OR source_payload->>'kind'='passa' OR source_payload->>'reaction'='nessuna');
 SELECT coalesce(jsonb_agg(e.value ORDER BY e.ordinality),'[]'::jsonb) INTO result
 FROM jsonb_array_elements(p_envelope->'offers') WITH ORDINALITY e(value,ordinality)
 JOIN combat_panel_private.offers o ON o.id=(e.value->>'offer_id')::uuid AND o.context_id=c AND o.state='offered';
 RETURN jsonb_set(p_envelope,'{offers}',result);
END $fn$;
CREATE FUNCTION public.esame_regia_panel_state(p_location uuid,p_actor uuid DEFAULT NULL) RETURNS jsonb
LANGUAGE plpgsql SECURITY DEFINER SET search_path='' AS $fn$
DECLARE b exam_regia_private.bindings%ROWTYPE; env jsonb; h public.esame_supervisione%ROWTYPE;
BEGIN
 b:=exam_regia_private.panel_binding(p_location,p_actor,false);
 env:=combat_panel_private.master_projection(p_location,b.player_actor_id);
 IF env#>>'{context,activity_id}' IS DISTINCT FROM b.combat_session_id::text
 OR env#>>'{context,policy_id}' IS DISTINCT FROM b.policy_id OR env#>>'{context,simulated}' IS DISTINCT FROM 'true' THEN
 RAISE EXCEPTION 'exam_regia_panel_binding_drift' USING ERRCODE='42501'; END IF;
 SELECT * INTO STRICT h FROM public.esame_supervisione WHERE prova=b.prova_id;
 RETURN jsonb_set(env,'{viewer,can_command}',to_jsonb(b.state='active' AND b.receipt_kind='player' AND h.player_ready AND h.apertura_pubblicata AND NOT h.publishing));
END $fn$;
CREATE FUNCTION public.esame_regia_panel_options(p_location uuid,p_actor uuid,p_context_version bigint) RETURNS jsonb
LANGUAGE plpgsql SECURITY DEFINER SET search_path='' AS $fn$
DECLARE b exam_regia_private.bindings%ROWTYPE;
BEGIN
 b:=exam_regia_private.panel_binding(p_location,p_actor,true);
 RETURN exam_regia_private.filter_options(combat_panel_private.master_options(p_location,b.player_actor_id,p_context_version));
END $fn$;
CREATE FUNCTION public.esame_regia_panel_commit(p_command jsonb) RETURNS jsonb
LANGUAGE plpgsql SECURITY DEFINER SET search_path='' AS $fn$
DECLARE cmd jsonb; b exam_regia_private.bindings%ROWTYPE; o combat_panel_private.offers%ROWTYPE;
 env jsonb; permit uuid; prior combat_panel_private.request_receipts%ROWTYPE;
BEGIN
 cmd:=combat_panel_private.validate_command(p_command);
 SELECT * INTO b FROM exam_regia_private.bindings WHERE owner_user=auth.uid()
 AND location_id=(cmd->>'location_id')::uuid AND combat_session_id=(cmd->>'activity_id')::uuid FOR UPDATE;
 IF NOT FOUND THEN RAISE EXCEPTION 'exam_regia_activity_mismatch' USING ERRCODE='42501'; END IF;
 PERFORM exam_regia_private.assert_owner(b.prova_id,true);
 PERFORM pg_advisory_xact_lock(hashtextextended('panel-request:'||auth.uid()::text||':'||(cmd->>'request_key'),731));
 SELECT * INTO prior FROM combat_panel_private.request_receipts WHERE principal_user=auth.uid() AND request_key=(cmd->>'request_key')::uuid;
 IF FOUND THEN
  IF prior.command_fingerprint<>public.combat_v2_sha256(cmd) OR prior.viewer_envelope#>>'{receipt,activity_id}' IS DISTINCT FROM b.combat_session_id::text
  THEN RAISE EXCEPTION 'panel_request_key_conflict' USING ERRCODE='22023'; END IF;
  RETURN jsonb_set(prior.viewer_envelope,'{receipt,replayed}','true',false);
 END IF;
 b:=exam_regia_private.panel_binding((cmd->>'location_id')::uuid,NULL,true);
 IF cmd->>'activity_id' IS DISTINCT FROM b.combat_session_id::text THEN RAISE EXCEPTION 'exam_regia_activity_mismatch' USING ERRCODE='42501'; END IF;
 SELECT * INTO STRICT o FROM combat_panel_private.offers WHERE id=(cmd->>'offer_id')::uuid AND actor_id=b.player_actor_id AND principal_user=auth.uid();
 IF o.kind='administration' OR o.source_payload->>'kind'='passa' OR o.source_payload->>'reaction'='nessuna' THEN
 RAISE EXCEPTION 'exam_regia_command_forbidden' USING ERRCODE='42501'; END IF;
 INSERT INTO exam_regia_private.execution_permits(prova_id,actor_id,principal_id,transaction_id,backend_pid,operation,request_key)
 VALUES(b.prova_id,b.player_actor_id,b.owner_user,txid_current(),pg_backend_pid(),'commit',(cmd->>'request_key')::uuid) RETURNING id INTO permit;
 env:=CASE WHEN o.source_payload->>'dispatch'='multiplication' THEN combat_panel_private.commit_multiplication(cmd)
 ELSE combat_panel_private.commit_master_actor(cmd) END;
 UPDATE exam_regia_private.execution_permits SET consumed_at=clock_timestamp() WHERE id=permit;
 PERFORM exam_regia_private.advance(b.prova_id);
 RETURN env;
END $fn$;
CREATE FUNCTION public.esame_regia_authorize(p_prova uuid,p_ricevuta uuid) RETURNS uuid
LANGUAGE plpgsql SECURITY DEFINER SET search_path='' AS $fn$
DECLARE b exam_regia_private.bindings%ROWTYPE; r exam_regia_private.receipts%ROWTYPE; bid uuid;
 q mission_exam_private.protected_sessions%ROWTYPE;
BEGIN
 b:=exam_regia_private.assert_owner(p_prova);
 IF b.state='opening' THEN RETURN public.esame_session_authorize(p_prova,p_ricevuta); END IF;
 IF b.state<>'active' OR b.receipt_kind NOT IN ('opening','choice','narration') OR b.receipt_id IS DISTINCT FROM p_ricevuta
 THEN RAISE EXCEPTION 'exam_regia_receipt_not_current' USING ERRCODE='40001'; END IF;
 SELECT * INTO STRICT r FROM exam_regia_private.receipts WHERE id=p_ricevuta AND prova_id=p_prova FOR UPDATE;
 SELECT * INTO STRICT q FROM mission_exam_private.protected_sessions WHERE prova_id=p_prova FOR UPDATE;
 SELECT id INTO bid FROM public.esame_supervisione_bozze WHERE prova=p_prova AND ricevuta=p_ricevuta;
 IF bid IS NOT NULL THEN RETURN bid; END IF;
 IF q.provider_calls>=q.provider_call_cap THEN RAISE EXCEPTION 'mission_session_call_limit' USING ERRCODE='55000'; END IF;
 INSERT INTO public.esame_supervisione_bozze(prova,ricevuta,tipo,autore)
 VALUES(p_prova,p_ricevuta,CASE WHEN r.kind='opening' THEN 'apertura' ELSE 'ciclo' END,auth.uid()) RETURNING id INTO bid;
 UPDATE exam_regia_private.receipts SET draft_id=bid WHERE id=r.id;
 RETURN bid;
END $fn$;


CREATE FUNCTION public.esame_regia_ai_options(p_prova uuid,p_actor uuid,p_request uuid) RETURNS jsonb
LANGUAGE plpgsql SECURITY DEFINER SET search_path='' AS $fn$
DECLARE b exam_regia_private.bindings%ROWTYPE; r exam_regia_private.receipts%ROWTYPE; cap exam_regia_private.ai_capabilities%ROWTYPE;
 permit uuid; env jsonb; actor public.combat_v2_actors%ROWTYPE; persona text;
BEGIN
 IF NOT public.combat_v2_is_service() OR auth.uid() IS NOT NULL OR p_request IS NULL THEN
 RAISE EXCEPTION 'exam_regia_service_required' USING ERRCODE='42501'; END IF;
 SELECT * INTO STRICT b FROM exam_regia_private.bindings WHERE prova_id=p_prova FOR UPDATE;
 IF b.state<>'active' OR b.png_actor_id<>p_actor OR b.receipt_kind<>'choice' THEN
 RAISE EXCEPTION 'exam_regia_png_scope_invalid' USING ERRCODE='42501'; END IF;
 SELECT * INTO STRICT r FROM exam_regia_private.receipts WHERE id=b.receipt_id AND prova_id=b.prova_id AND kind='choice' FOR UPDATE;
 SELECT * INTO cap FROM exam_regia_private.ai_capabilities WHERE receipt_id=r.id FOR UPDATE;
 IF FOUND THEN
  IF cap.actor_id<>p_actor OR cap.request_key<>p_request OR cap.expires_at<=clock_timestamp() THEN
  RAISE EXCEPTION 'exam_regia_capability_stale' USING ERRCODE='40001'; END IF;
 ELSE
  SELECT * INTO STRICT actor FROM public.combat_v2_actors WHERE id=b.png_actor_id AND session_id=b.combat_session_id
   AND actor_kind='png' AND controller_user IS NULL AND character_id IS NULL AND state='attivo';
  INSERT INTO exam_regia_private.execution_permits(prova_id,actor_id,principal_id,transaction_id,backend_pid,operation,request_key)
  VALUES(b.prova_id,b.png_actor_id,b.service_principal_id,txid_current(),pg_backend_pid(),'options',p_request) RETURNING id INTO permit;
  env:=combat_panel_private.master_projection(b.location_id,b.png_actor_id);
  env:=exam_regia_private.filter_options(combat_panel_private.master_options(b.location_id,b.png_actor_id,(env#>>'{context,version}')::bigint));
  IF env#>>'{context,activity_id}'<>b.combat_session_id::text OR env#>>'{viewer,command_actor_id}'<>b.png_actor_id::text
   OR env#>>'{context,policy_id}'<>b.policy_id OR env#>>'{context,simulated}'<>'true' OR jsonb_array_length(env->'offers')=0
  THEN RAISE EXCEPTION 'exam_regia_png_options_unavailable' USING ERRCODE='55000'; END IF;
  INSERT INTO exam_regia_private.ai_capabilities(prova_id,receipt_id,actor_id,request_key,context_version,controller_version,
   legal_options,source_sha256,expires_at)
  VALUES(b.prova_id,r.id,b.png_actor_id,p_request,(env#>>'{context,version}')::bigint,actor.controller_version,env,
   public.combat_v2_sha256(env),clock_timestamp()+interval '150 seconds') RETURNING * INTO cap;
  UPDATE exam_regia_private.execution_permits SET consumed_at=clock_timestamp() WHERE id=permit;
 END IF;
 SELECT cache.persona INTO STRICT persona FROM public.combat_v2_actors a JOIN public.combat_v2_png_instances i ON i.id=a.png_instance_id
 JOIN exam_regia_private.profile_templates cache ON cache.template_id=i.template_id WHERE a.id=b.png_actor_id AND a.session_id=b.combat_session_id;
 RETURN jsonb_build_object('ok',true,'version','EXAM-REGIA17/1','prova',b.prova_id,'actor_id',cap.actor_id,
 'receipt_id',r.id,'context_version',cap.context_version,'request_key',cap.request_key,
 'choice_context',jsonb_build_object('round_id',r.round_id,'phase',r.phase),'persona',persona,
 'legal_options',cap.legal_options,'capability_id',cap.id);
END $fn$;
CREATE FUNCTION public.esame_regia_ai_commit(p_prova uuid,p_capability uuid,p_command jsonb) RETURNS jsonb
LANGUAGE plpgsql SECURITY DEFINER SET search_path='' AS $fn$
DECLARE b exam_regia_private.bindings%ROWTYPE; cap exam_regia_private.ai_capabilities%ROWTYPE;
 cmd jsonb; o combat_panel_private.offers%ROWTYPE; permit uuid; env jsonb; v_result jsonb; fp text;
BEGIN
 IF NOT public.combat_v2_is_service() OR auth.uid() IS NOT NULL THEN RAISE EXCEPTION 'exam_regia_service_required' USING ERRCODE='42501'; END IF;
 SELECT * INTO STRICT b FROM exam_regia_private.bindings WHERE prova_id=p_prova FOR UPDATE;
 SELECT * INTO STRICT cap FROM exam_regia_private.ai_capabilities WHERE id=p_capability AND prova_id=p_prova FOR UPDATE;
 cmd:=combat_panel_private.validate_command(p_command);fp:=public.combat_v2_sha256(cmd);
 IF cap.consumed_at IS NOT NULL THEN
  IF cap.command_sha256<>fp THEN RAISE EXCEPTION 'exam_regia_replay_conflict' USING ERRCODE='22023'; END IF;
  RETURN cap.result||jsonb_build_object('replayed',true);
 END IF;
 IF b.state<>'active' OR cap.receipt_id<>b.receipt_id OR b.receipt_kind<>'choice' OR cap.actor_id<>b.png_actor_id
 OR cap.expires_at<=clock_timestamp() OR cap.request_key IS DISTINCT FROM (cmd->>'request_key')::uuid
 OR cap.context_version IS DISTINCT FROM (cmd->>'context_version')::bigint
 OR b.combat_session_id IS DISTINCT FROM (cmd->>'activity_id')::uuid OR b.location_id IS DISTINCT FROM (cmd->>'location_id')::uuid
 OR cap.source_sha256 IS DISTINCT FROM public.combat_v2_sha256(cap.legal_options)
 OR NOT EXISTS(SELECT 1 FROM public.combat_v2_actors a WHERE a.id=cap.actor_id AND a.session_id=b.combat_session_id
 AND a.controller_user IS NULL AND a.character_id IS NULL AND a.actor_kind='png' AND a.controller_version=cap.controller_version)
 THEN RAISE EXCEPTION 'exam_regia_capability_stale' USING ERRCODE='40001'; END IF;
 SELECT * INTO STRICT o FROM combat_panel_private.offers WHERE id=(cmd->>'offer_id')::uuid
 AND actor_id=b.png_actor_id AND principal_user=b.service_principal_id AND state='offered';
 IF o.kind='administration' OR o.source_payload->>'kind'='passa' OR o.source_payload->>'reaction'='nessuna'
 OR NOT EXISTS(SELECT 1 FROM jsonb_array_elements(cap.legal_options->'offers') v WHERE v->>'offer_id'=o.id::text)
 THEN RAISE EXCEPTION 'exam_regia_command_forbidden' USING ERRCODE='42501'; END IF;
 INSERT INTO exam_regia_private.execution_permits(prova_id,actor_id,principal_id,transaction_id,backend_pid,operation,request_key)
 VALUES(b.prova_id,b.png_actor_id,b.service_principal_id,txid_current(),pg_backend_pid(),'commit',cap.request_key) RETURNING id INTO permit;
 env:=CASE WHEN o.source_payload->>'dispatch'='multiplication' THEN combat_panel_private.commit_multiplication(cmd)
 ELSE combat_panel_private.commit_master_actor(cmd) END;
 UPDATE exam_regia_private.execution_permits SET consumed_at=clock_timestamp() WHERE id=permit;
 v_result:=jsonb_build_object('ok',true,'version','EXAM-REGIA17/1','prova',b.prova_id,
 'receipt_id',env#>'{receipt,receipt_id}','replayed',false,'next','publish');
 UPDATE exam_regia_private.ai_capabilities SET consumed_at=clock_timestamp(),command_sha256=fp,result=v_result WHERE id=cap.id;
 UPDATE exam_regia_private.receipts SET committed_command=cmd,command_receipt_id=(env#>>'{receipt,receipt_id}')::uuid WHERE id=cap.receipt_id;
 RETURN v_result;
END $fn$;
CREATE FUNCTION exam_regia_private.claim(p_bozza uuid,p_user uuid) RETURNS jsonb
LANGUAGE plpgsql SECURITY DEFINER SET search_path='' AS $fn$
DECLARE d public.esame_supervisione_bozze%ROWTYPE; b exam_regia_private.bindings%ROWTYPE;
 r exam_regia_private.receipts%ROWTYPE; q mission_exam_private.protected_sessions%ROWTYPE;
 h public.esame_supervisione%ROWTYPE; payload jsonb; regia jsonb; claim jsonb; choice jsonb:=NULL; scene jsonb:=NULL;
 round public.combat_v2_rounds%ROWTYPE; permit uuid; digest text;
BEGIN
 IF NOT public.combat_v2_is_service() OR auth.uid() IS NOT NULL OR p_user IS NULL THEN
 RAISE EXCEPTION 'exam_regia_service_required' USING ERRCODE='42501'; END IF;
 SELECT * INTO STRICT d FROM public.esame_supervisione_bozze WHERE id=p_bozza;
 SELECT * INTO STRICT b FROM exam_regia_private.bindings WHERE prova_id=d.prova AND owner_user=p_user FOR UPDATE;
 PERFORM 1 FROM public.esame_prove WHERE id=b.prova_id AND candidate_user=p_user FOR UPDATE;
 SELECT * INTO STRICT h FROM public.esame_supervisione WHERE prova=b.prova_id FOR UPDATE;
 SELECT * INTO STRICT q FROM mission_exam_private.protected_sessions WHERE prova_id=b.prova_id FOR UPDATE;
 SELECT * INTO STRICT d FROM public.esame_supervisione_bozze WHERE id=p_bozza FOR UPDATE;
 SELECT * INTO STRICT r FROM exam_regia_private.receipts WHERE id=b.receipt_id AND draft_id=d.id FOR UPDATE;
 IF b.state<>'active' OR d.autore IS DISTINCT FROM p_user OR d.ricevuta IS DISTINCT FROM b.receipt_id
 OR d.stato<>'autorizzata' OR h.player_ready OR h.publishing
 OR NOT EXISTS(SELECT 1 FROM public.characters WHERE id=b.character_id AND user_id=p_user)
 OR NOT EXISTS(SELECT 1 FROM exam_regia_private.runtime WHERE singleton AND enabled AND provider_enabled)
 OR EXISTS(SELECT 1 FROM mission_exam_private.dispatches WHERE prova_id=b.prova_id AND receipt_id=r.id)
 OR q.provider_calls>=q.provider_call_cap THEN RAISE EXCEPTION 'exam_regia_claim_denied' USING ERRCODE='42501'; END IF;
 IF r.kind='choice' AND r.phase='prepare_counter' THEN
  PERFORM exam_regia_private.prepare_counter(r.id);
  SELECT * INTO STRICT r FROM exam_regia_private.receipts WHERE id=r.id;
  SELECT * INTO STRICT b FROM exam_regia_private.bindings WHERE prova_id=b.prova_id;
 END IF;
 SELECT * INTO STRICT round FROM public.combat_v2_rounds WHERE id=r.round_id AND session_id=b.combat_session_id FOR UPDATE;
 IF r.kind='opening' THEN payload:=h.apertura_fatti;
 ELSIF r.kind='choice' THEN
  choice:=public.esame_regia_ai_options(b.prova_id,b.png_actor_id,r.id);
  choice:=jsonb_build_object('actor_id',choice->'actor_id','capability_id',choice->'capability_id',
   'request_key',choice->'request_key','context_version',choice->'context_version','legal_options',choice->'legal_options','persona',choice->'persona','choice_context',choice->'choice_context');
  payload:=jsonb_build_object('version','EXAM-REGIA17/1','ricevuta',r.id,'kind',r.kind);
 ELSIF r.kind='narration' THEN
  PERFORM exam_regia_private.resolve_capture(b.prova_id,round.id,md5('exam-resolve|'||round.id::text)::uuid);
  scene:=exam_regia_private.scene(b.prova_id,round.id);
  payload:=jsonb_build_object('version','EXAM-REGIA17/1','ricevuta',r.id,'kind',r.kind);
 ELSE RAISE EXCEPTION 'exam_regia_receipt_kind_invalid'; END IF;
 IF payload IS NULL THEN RAISE EXCEPTION 'exam_regia_payload_missing'; END IF;
 regia:=jsonb_build_object('version','EXAM-REGIA17/1','kind',r.kind,
 'binding',jsonb_build_object('prova_id',b.prova_id,'combat_session_id',b.combat_session_id,'master_session_id',b.master_session_id,
 'round_id',round.id,'control_version',b.control_version),'budget',jsonb_build_object('used',q.provider_calls+1,'limit',q.provider_call_cap),
 'lease_expires_at',clock_timestamp()+interval '150 seconds','choice',choice,'scene',scene->'scene','scene_binding',scene->'scene_binding',
 'exchange',exam_regia_private.exchange_wire(round.id),'pending_attack',CASE WHEN r.kind='narration' THEN exam_regia_private.pending_wire(round.id) ELSE NULL END,
 'final',r.kind='narration' AND exam_regia_private.round_is_final(round.id));
 claim:=jsonb_build_object('bozza',d.id,'prova',b.prova_id,'tipo',d.tipo,'ricevuta',r.id,'payload',payload,'regia',regia);
 digest:=public.combat_v2_sha256(claim);
 claim:=claim||jsonb_build_object('payload_sha',digest);
 INSERT INTO mission_exam_private.dispatches(prova_id,receipt_id,draft_id) VALUES(b.prova_id,r.id,d.id);
 UPDATE mission_exam_private.protected_sessions SET provider_calls=provider_calls+1 WHERE class_session_id=q.class_session_id;
 UPDATE public.esame_supervisione_bozze SET stato='generazione',claimed_at=clock_timestamp(),payload=claim,payload_sha=digest WHERE id=d.id;
 UPDATE exam_regia_private.receipts SET payload=claim,payload_sha=digest WHERE id=r.id;
 RETURN claim;
END $fn$;
CREATE FUNCTION public._esame_regia_deposit(p_bozza uuid,p_user uuid,p_payload_sha text,p_risultato jsonb) RETURNS jsonb
LANGUAGE plpgsql SECURITY DEFINER SET search_path='' AS $fn$
DECLARE b exam_regia_private.bindings%ROWTYPE; d public.esame_supervisione_bozze%ROWTYPE;
 r exam_regia_private.receipts%ROWTYPE; result jsonb; sig text;
BEGIN
 IF NOT public.combat_v2_is_service() OR auth.uid() IS NOT NULL THEN RAISE EXCEPTION 'exam_regia_service_required' USING ERRCODE='42501'; END IF;
 SELECT * INTO STRICT d FROM public.esame_supervisione_bozze WHERE id=p_bozza;
 SELECT * INTO STRICT b FROM exam_regia_private.bindings WHERE prova_id=d.prova AND owner_user=p_user FOR UPDATE;
 SELECT * INTO STRICT d FROM public.esame_supervisione_bozze WHERE id=p_bozza FOR UPDATE;
 SELECT * INTO STRICT r FROM exam_regia_private.receipts WHERE id=d.ricevuta AND prova_id=b.prova_id FOR UPDATE;
 IF b.state<>'active' OR b.receipt_id<>r.id OR d.autore IS DISTINCT FROM p_user OR d.stato<>'generazione'
 OR d.claimed_at IS NULL OR d.claimed_at<=clock_timestamp()-interval '150 seconds'
 OR d.payload_sha IS DISTINCT FROM p_payload_sha OR r.payload_sha IS DISTINCT FROM p_payload_sha
 OR d.payload IS DISTINCT FROM r.payload OR public.combat_v2_sha256(d.payload-'payload_sha') IS DISTINCT FROM p_payload_sha
 OR jsonb_typeof(p_risultato)<>'object' OR p_risultato->>'validator_version' IS DISTINCT FROM 'MISSION-EXAM-SESSION-001'
 OR jsonb_typeof(p_risultato->'ok') IS DISTINCT FROM 'boolean' OR jsonb_typeof(p_risultato->'publishable') IS DISTINCT FROM 'boolean'
 OR (p_risultato->>'ok'='true' AND p_risultato->>'publishable'<>'true')
 THEN RAISE EXCEPTION 'exam_regia_deposit_stale_or_invalid' USING ERRCODE='40001'; END IF;
 IF p_risultato->>'ok'='true' AND r.kind='choice' AND
 (r.command_receipt_id IS NULL OR p_risultato->>'command_receipt_id' IS DISTINCT FROM r.command_receipt_id::text) THEN
 RAISE EXCEPTION 'exam_regia_command_receipt_missing' USING ERRCODE='40001'; END IF;
 IF p_risultato->>'ok'='true' AND r.kind IN ('opening','narration') AND
 (jsonb_typeof(p_risultato->'testo') IS DISTINCT FROM 'string' OR length(btrim(p_risultato->>'testo')) NOT BETWEEN 1 AND 5000) THEN
 RAISE EXCEPTION 'exam_regia_text_invalid' USING ERRCODE='22023'; END IF;
 result:=public._esame_supervisione_deposita(d.id,p_risultato);
 SELECT sha INTO sig FROM public.esame_supervisione_bozze WHERE id=d.id;
 IF p_risultato->>'ok'<>'true' THEN UPDATE exam_regia_private.bindings SET state='paused' WHERE prova_id=b.prova_id; END IF;
 RETURN jsonb_build_object('ok',true,'version','EXAM-REGIA17/1','prova',b.prova_id,'bozza',d.id,'sha',sig,
 'result_ok',p_risultato->'ok','publishable',p_risultato->'publishable');
END $fn$;


CREATE TABLE exam_regia_private.exit_receipts (
 prova_id uuid PRIMARY KEY REFERENCES exam_regia_private.bindings, request_key uuid UNIQUE NOT NULL,
 owner_user uuid NOT NULL, text_sha256 text NOT NULL, message_id uuid REFERENCES public.messages(id),
 receipt_id uuid UNIQUE NOT NULL DEFAULT gen_random_uuid(), result jsonb, created_at timestamptz NOT NULL DEFAULT clock_timestamp());
CREATE FUNCTION exam_regia_private.assert_publish(p_round uuid,p_text text,p_request uuid) RETURNS void
LANGUAGE plpgsql SECURITY DEFINER SET search_path='' AS $fn$
DECLARE b exam_regia_private.bindings%ROWTYPE;
BEGIN
 SELECT x.* INTO b FROM exam_regia_private.bindings x JOIN public.combat_v2_rounds r ON r.session_id=x.combat_session_id WHERE r.id=p_round;
 IF NOT FOUND THEN RETURN; END IF;
 IF b.state<>'active' OR auth.uid() IS DISTINCT FROM b.owner_user OR NOT EXISTS(
 SELECT 1 FROM exam_regia_private.receipts r JOIN public.esame_supervisione_bozze d ON d.id=r.draft_id
 JOIN public.esame_supervisione h ON h.prova=d.prova WHERE r.id=b.receipt_id AND r.kind='narration'
 AND r.round_id=p_round AND d.id=p_request AND d.stato='pronta' AND d.autore=b.owner_user
 AND d.risultato->>'testo'=btrim(p_text) AND d.risultato->'ok'='true'::jsonb
 AND d.risultato->'publishable'='true'::jsonb AND h.publishing AND h.chiusa_at IS NULL)
 THEN RAISE EXCEPTION 'exam_regia_publish_port_required' USING ERRCODE='42501'; END IF;
END $fn$;
CREATE FUNCTION public.esame_regia_publish(p_bozza uuid,p_sha text) RETURNS jsonb
LANGUAGE plpgsql SECURITY DEFINER SET search_path='' AS $fn$
DECLARE b exam_regia_private.bindings%ROWTYPE; d public.esame_supervisione_bozze%ROWTYPE;
 r exam_regia_private.receipts%ROWTYPE; h public.esame_supervisione%ROWTYPE;
 mid uuid; native jsonb; txt text; final boolean; report public.combat_v2_round_reports%ROWTYPE;
BEGIN
 SELECT * INTO STRICT d FROM public.esame_supervisione_bozze WHERE id=p_bozza;
 b:=exam_regia_private.assert_owner(d.prova,true);
 SELECT * INTO STRICT d FROM public.esame_supervisione_bozze WHERE id=p_bozza FOR UPDATE;
 IF d.tipo='apertura' THEN
  IF d.ricevuta IS DISTINCT FROM (SELECT apertura_ricevuta FROM public.esame_supervisione WHERE prova=b.prova_id) THEN
  RAISE EXCEPTION 'exam_regia_native_opening_receipt_mismatch' USING ERRCODE='40001'; END IF;
  IF d.stato='pubblicata' THEN
   SELECT * INTO STRICT h FROM public.esame_supervisione WHERE prova=b.prova_id FOR UPDATE;
   IF d.autore IS DISTINCT FROM auth.uid() OR d.sha IS DISTINCT FROM p_sha
   OR d.approvata_da IS DISTINCT FROM b.owner_user OR d.pubblicata_at IS NULL OR NOT h.apertura_pubblicata
   OR d.ricevuta IS DISTINCT FROM h.apertura_ricevuta OR d.payload IS DISTINCT FROM h.apertura_fatti
   OR public._esame_supervisione_hash(d.payload) IS DISTINCT FROM d.payload_sha
   OR public._esame_supervisione_hash(jsonb_build_object('ricevuta',d.ricevuta,'payload_sha',d.payload_sha,'risultato',d.risultato)) IS DISTINCT FROM d.sha
   OR d.risultato->'ok' IS DISTINCT FROM 'true'::jsonb OR d.risultato->'publishable' IS DISTINCT FROM 'true'::jsonb
   OR d.risultato->>'validator_version' IS DISTINCT FROM 'MISSION-EXAM-SESSION-001'
   THEN RAISE EXCEPTION 'exam_regia_native_opening_replay_invalid' USING ERRCODE='40001'; END IF;
   RETURN jsonb_build_object('ok',true,'pubblicato',true,'publication_label','apertura',
    'prova',b.prova_id,'version','EXAM-REGIA17/1','replayed',true);
  END IF;
  native:=public.esame_session_publish(p_bozza,p_sha);
  IF NOT EXISTS(SELECT 1 FROM public.esame_supervisione WHERE prova=b.prova_id AND apertura_pubblicata)
  THEN RAISE EXCEPTION 'exam_regia_native_opening_not_published'; END IF;
  IF b.state='opening' THEN
   UPDATE exam_regia_private.bindings SET state='active' WHERE prova_id=b.prova_id;
   PERFORM exam_regia_private.advance(b.prova_id);
  END IF;
  RETURN native||jsonb_build_object('prova',b.prova_id,'version','EXAM-REGIA17/1');
 END IF;
 SELECT * INTO STRICT r FROM exam_regia_private.receipts WHERE id=d.ricevuta AND prova_id=b.prova_id FOR UPDATE;
 IF d.stato='pubblicata' AND d.autore=auth.uid() AND d.sha=p_sha AND r.published_at IS NOT NULL THEN
 RETURN jsonb_build_object('ok',true,'pubblicato',true,'prova',b.prova_id,'version','EXAM-REGIA17/1','replayed',true); END IF;
 SELECT * INTO STRICT h FROM public.esame_supervisione WHERE prova=b.prova_id FOR UPDATE;
 IF b.state<>'active' OR d.autore IS DISTINCT FROM auth.uid() OR d.stato<>'pronta' OR d.sha IS DISTINCT FROM p_sha
 OR b.receipt_id<>r.id OR d.payload_sha IS DISTINCT FROM r.payload_sha OR d.payload IS DISTINCT FROM r.payload
 OR public.combat_v2_sha256(d.payload-'payload_sha') IS DISTINCT FROM d.payload_sha
 OR public._esame_supervisione_hash(jsonb_build_object('ricevuta',d.ricevuta,'payload_sha',d.payload_sha,'risultato',d.risultato)) IS DISTINCT FROM d.sha
 OR d.risultato->'ok' IS DISTINCT FROM 'true'::jsonb OR d.risultato->'publishable' IS DISTINCT FROM 'true'::jsonb
 OR d.risultato->>'validator_version' IS DISTINCT FROM 'MISSION-EXAM-SESSION-001' OR h.publishing
 THEN RAISE EXCEPTION 'exam_regia_publish_stale' USING ERRCODE='40001'; END IF;
 UPDATE public.esame_supervisione SET publishing=true WHERE prova=b.prova_id;
 txt:=btrim(d.risultato->>'testo');
 IF r.kind='opening' THEN
  IF h.apertura_pubblicata OR d.payload->'payload' IS DISTINCT FROM h.apertura_fatti THEN
  RAISE EXCEPTION 'exam_regia_opening_source_drift' USING ERRCODE='40001'; END IF;
  mid:=public._esame_supervisione_post(b.prova_id,b.location_id,txt);
  UPDATE public.esame_supervisione SET apertura_pubblicata=true WHERE prova=b.prova_id;
 ELSIF r.kind='choice' THEN
  IF r.command_receipt_id IS NULL OR d.risultato->>'command_receipt_id'<>r.command_receipt_id::text THEN
  RAISE EXCEPTION 'exam_regia_command_receipt_missing' USING ERRCODE='40001'; END IF;
  -- La scelta PNG viene attestata qui; il testo offensivo appare nel FatoA con intento pending.
 ELSIF r.kind='narration' THEN
  SELECT * INTO STRICT report FROM public.combat_v2_round_reports WHERE round_id=r.round_id FOR UPDATE;
  IF report.mechanics_sha256 IS DISTINCT FROM (d.payload#>>'{regia,scene_binding,report_sha256}') OR report.values_written THEN
  RAISE EXCEPTION 'exam_regia_report_drift' USING ERRCODE='40001'; END IF;
  final:=exam_regia_private.round_is_final(r.round_id);
  native:=public.combat_v2_narrative_store(r.round_id,'fato_ia',txt,d.id,NULL);
  mid:=(native#>>'{data,message_id}')::uuid;
  IF mid IS NULL THEN RAISE EXCEPTION 'exam_regia_narrative_not_published'; END IF;
  IF final THEN
   UPDATE exam_regia_private.bindings SET state='congedo',receipt_kind='player',receipt_id=gen_random_uuid(),updated_at=clock_timestamp()
    WHERE prova_id=b.prova_id;
   UPDATE public.esame_prove SET meta='candidato',fase='uscita',updated_at=clock_timestamp() WHERE id=b.prova_id;
  END IF;
 ELSE RAISE EXCEPTION 'exam_regia_receipt_kind_invalid'; END IF;
 UPDATE exam_regia_private.receipts SET published_at=clock_timestamp() WHERE id=r.id;
 UPDATE public.esame_supervisione_bozze SET stato='pubblicata',approvata_da=auth.uid(),pubblicata_at=clock_timestamp() WHERE id=d.id;
 UPDATE public.esame_supervisione SET publishing=false,player_ready=coalesce(final,false),idle_deadline=NULL WHERE prova=b.prova_id;
 IF r.kind='narration' THEN PERFORM exam_regia_private.exchange_after_publish(b.prova_id,r.round_id,d.id,(native#>>'{data,narrative_id}')::uuid); END IF;
 IF NOT coalesce(final,false) THEN PERFORM exam_regia_private.advance(b.prova_id); END IF;
 RETURN jsonb_build_object('ok',true,'pubblicato',true,'prova',b.prova_id,'version','EXAM-REGIA17/1','message_id',mid,'replayed',false);
END $fn$;
CREATE FUNCTION exam_regia_private.close_native() RETURNS trigger
LANGUAGE plpgsql SECURITY DEFINER SET search_path='' AS $fn$
DECLARE b exam_regia_private.bindings%ROWTYPE;
BEGIN
 IF NEW.state<>'closed' THEN RETURN NEW; END IF;
 SELECT * INTO b FROM exam_regia_private.bindings WHERE class_session_id=NEW.class_session_id FOR UPDATE;
 IF NOT FOUND OR b.state='closed' THEN RETURN NEW; END IF;
 UPDATE exam_regia_private.bindings SET state='closed',receipt_kind='complete',closed_at=clock_timestamp(),
 close_reason='protected_session_closed',control_version=control_version+1,updated_at=clock_timestamp() WHERE prova_id=b.prova_id;
 UPDATE public.combat_v2_sessions SET state='chiuso',closed_at=clock_timestamp() WHERE id=b.combat_session_id AND closed_at IS NULL;
 UPDATE public.master_v2_sessions SET stato='chiusa',closed_at=clock_timestamp(),close_reason='exam_protected_close'
  WHERE id=b.master_session_id AND closed_at IS NULL;
 PERFORM combat_panel_private.sync_master_scene(b.combat_session_id);
 UPDATE public.master_v2_participants SET engagement_state='concluso' WHERE session_id=b.master_session_id AND engagement_state IN ('attivo','sospeso');
 UPDATE exam_regia_private.execution_permits SET consumed_at=clock_timestamp() WHERE prova_id=b.prova_id AND consumed_at IS NULL;
 RETURN NEW;
END $fn$;
CREATE TRIGGER exam_regia_close AFTER UPDATE OF state ON mission_exam_private.protected_sessions
 FOR EACH ROW EXECUTE FUNCTION exam_regia_private.close_native();
CREATE FUNCTION public.esame_regia_close(p_prova uuid,p_request uuid) RETURNS jsonb
LANGUAGE plpgsql SECURITY DEFINER SET search_path='' AS $fn$
DECLARE b exam_regia_private.bindings%ROWTYPE; res jsonb;
BEGIN
 b:=exam_regia_private.assert_owner(p_prova,true);
 res:=public.esame_session_close(p_prova,p_request);
 IF NOT EXISTS(SELECT 1 FROM exam_regia_private.bindings WHERE prova_id=p_prova AND state='closed')
 THEN RAISE EXCEPTION 'exam_regia_close_not_confirmed'; END IF;
 RETURN res||jsonb_build_object('version','EXAM-REGIA17/1');
END $fn$;
CREATE FUNCTION public.esame_regia_exit(p_prova uuid,p_request uuid,p_text text) RETURNS jsonb
LANGUAGE plpgsql SECURITY DEFINER SET search_path='' AS $fn$
DECLARE b exam_regia_private.bindings%ROWTYPE; prior exam_regia_private.exit_receipts%ROWTYPE;
 fp text; mid uuid; guided text; res jsonb;
BEGIN
 IF p_request IS NULL OR nullif(btrim(p_text),'') IS NULL OR length(p_text)>5000 THEN
 RAISE EXCEPTION 'exam_regia_exit_text_invalid' USING ERRCODE='22023'; END IF;
 b:=exam_regia_private.assert_owner(p_prova,true); fp:=public.combat_v2_sha256(to_jsonb(btrim(p_text)));
 SELECT * INTO prior FROM exam_regia_private.exit_receipts WHERE prova_id=p_prova OR request_key=p_request FOR UPDATE;
 IF FOUND THEN
  IF prior.prova_id<>p_prova OR prior.owner_user IS DISTINCT FROM auth.uid() OR prior.request_key<>p_request
  OR prior.text_sha256<>fp OR prior.result IS NULL THEN RAISE EXCEPTION 'exam_regia_exit_replay_conflict' USING ERRCODE='22023'; END IF;
  RETURN prior.result||jsonb_build_object('replayed',true);
 END IF;
 IF b.state<>'congedo' OR NOT coalesce(public._combat_presente(auth.uid(),b.location_id),false)
 OR NOT EXISTS(SELECT 1 FROM exam_regia_private.receipts r JOIN public.esame_supervisione_bozze d ON d.id=r.draft_id
 WHERE r.prova_id=b.prova_id AND r.kind='narration' AND r.published_at IS NOT NULL AND d.stato='pubblicata'
 AND d.payload#>>'{regia,final}'='true') THEN RAISE EXCEPTION 'exam_regia_exit_not_ready' USING ERRCODE='55000'; END IF;
 INSERT INTO exam_regia_private.exit_receipts(prova_id,request_key,owner_user,text_sha256)
 VALUES(p_prova,p_request,auth.uid(),fp) RETURNING * INTO prior;
 mid:=public._esame_testo_candidato(b.prova_id,btrim(p_text));
 IF NOT EXISTS(SELECT 1 FROM public.messages WHERE id=mid AND character_id=b.character_id AND sender_user=b.owner_user
 AND location_id=b.location_id AND body=btrim(p_text)) THEN RAISE EXCEPTION 'exam_regia_exit_message_invalid'; END IF;
 UPDATE public.esame_prove SET stato='conclusa',closed_at=clock_timestamp(),close_reason='done',opzioni_png=NULL,opzioni_id=NULL
 WHERE id=b.prova_id AND stato='aperta';
 res:=public.esame_regia_close(b.prova_id,p_request);
 res:=res||jsonb_build_object('message_id',mid,'receipt_id',prior.receipt_id,'replayed',false);
 UPDATE exam_regia_private.exit_receipts SET message_id=mid,result=res WHERE prova_id=p_prova;
 RETURN res;
END $fn$;

CREATE FUNCTION exam_regia_private.permit_exchange(p_prova uuid) RETURNS void
LANGUAGE plpgsql SECURITY DEFINER SET search_path='' AS $x$
DECLARE b exam_regia_private.bindings%ROWTYPE;
BEGIN
 SELECT * INTO STRICT b FROM exam_regia_private.bindings WHERE prova_id=p_prova AND state IN('active','congedo');
 INSERT INTO exam_regia_private.execution_permits(prova_id,actor_id,principal_id,transaction_id,backend_pid,operation,request_key)
 VALUES(b.prova_id,b.png_actor_id,b.service_principal_id,txid_current(),pg_backend_pid(),'exchange',gen_random_uuid());
END $x$;
CREATE FUNCTION exam_regia_private.assert_exchange(p_scope uuid) RETURNS void
LANGUAGE plpgsql SECURITY DEFINER SET search_path='' AS $x$
DECLARE b exam_regia_private.bindings%ROWTYPE;
BEGIN
 SELECT * INTO STRICT b FROM exam_regia_private.bindings WHERE prova_id=exam_regia_private.exchange_scope(p_scope) FOR UPDATE;
 IF b.state NOT IN('active','congedo') OR NOT exam_regia_private.is_bound(b.combat_session_id)
 OR NOT EXISTS(SELECT 1 FROM exam_regia_private.runtime WHERE singleton AND enabled)
 OR NOT EXISTS(SELECT 1 FROM mission_exam_private.protected_sessions q WHERE q.prova_id=b.prova_id AND q.owner_user=b.owner_user AND q.state='active')
 OR NOT ((auth.uid() IS NOT NULL AND auth.uid()=b.owner_user) OR (auth.uid() IS NULL AND public.combat_v2_is_service()))
 THEN RAISE EXCEPTION 'exam_exchange_authority_invalid' USING ERRCODE='42501'; END IF;
 UPDATE exam_regia_private.execution_permits ep SET consumed_at=clock_timestamp() WHERE ep.id=(
  SELECT ep0.id FROM exam_regia_private.execution_permits ep0 WHERE ep0.prova_id=b.prova_id AND ep0.operation='exchange'
  AND ep0.actor_id=b.png_actor_id AND ep0.principal_id=b.service_principal_id AND ep0.transaction_id=txid_current()
  AND ep0.backend_pid=pg_backend_pid() AND ep0.consumed_at IS NULL AND ep0.created_at>clock_timestamp()-interval '150 seconds'
  ORDER BY ep0.created_at,ep0.id LIMIT 1 FOR UPDATE);
 IF NOT FOUND THEN RAISE EXCEPTION 'exam_exchange_permit_required' USING ERRCODE='42501'; END IF;
END $x$;
CREATE FUNCTION exam_regia_private.exchange_roster(p_session uuid) RETURNS jsonb
LANGUAGE plpgsql STABLE SECURITY DEFINER SET search_path='' AS $x$
DECLARE b exam_regia_private.bindings%ROWTYPE; members jsonb; ids jsonb;
BEGIN
 SELECT * INTO STRICT b FROM exam_regia_private.bindings WHERE combat_session_id=p_session;
 SELECT jsonb_agg(jsonb_build_object('actor_id',a.id,'character_id',a.character_id,'actor_kind',upper(a.actor_kind),
 'team_key',CASE WHEN a.id=b.player_actor_id THEN 'party' ELSE 'hostile' END,
 'controller_kind',CASE WHEN a.id=b.player_actor_id THEN 'player' ELSE 'ai_service' END,'controller_user',a.controller_user,
 'persona_digest',CASE WHEN a.id=b.png_actor_id THEN cache.source_sha256 ELSE NULL END) ORDER BY a.id),jsonb_agg(a.id ORDER BY a.id)
 INTO members,ids FROM public.combat_v2_actors a LEFT JOIN public.combat_v2_png_instances i ON i.id=a.png_instance_id
 LEFT JOIN exam_regia_private.profile_templates cache ON cache.template_id=i.template_id
 WHERE a.session_id=b.combat_session_id AND a.id IN(b.player_actor_id,b.png_actor_id)
 AND ((a.id=b.player_actor_id AND a.actor_kind='pg' AND a.character_id=b.character_id AND a.controller_user=b.owner_user)
 OR (a.id=b.png_actor_id AND a.actor_kind='png' AND a.character_id IS NULL AND a.controller_user IS NULL AND cache.source_sha256~'^[0-9a-f]{64}$'));
 IF jsonb_array_length(members) IS DISTINCT FROM 2 THEN RAISE EXCEPTION 'exam_exchange_roster_invalid'; END IF;
 RETURN jsonb_build_object('schema_version','combat-v2-exchange-roster/1.0','session_id',p_session,'actor_members',members,'actor_ids',ids,
 'owner_fingerprint',public.combat_v2_sha256(jsonb_build_object('session_id',p_session,'actor_members',members,'actor_ids',ids)));
END $x$;
CREATE FUNCTION exam_regia_private.assert_exchange_roster(p_session uuid,p_roster jsonb) RETURNS void
LANGUAGE plpgsql SECURITY DEFINER SET search_path='' AS $x$
BEGIN
 IF p_roster IS DISTINCT FROM exam_regia_private.exchange_roster(p_session) THEN RAISE EXCEPTION 'exam_exchange_roster_drift'; END IF;
END $x$;
CREATE FUNCTION exam_regia_private.exchange_spatial_receipt(p_instance uuid,p_round uuid) RETURNS jsonb
LANGUAGE plpgsql STABLE SECURITY DEFINER SET search_path='' AS $x$
DECLARE b exam_regia_private.bindings%ROWTYPE;i combat_spatial.arena_instances%ROWTYPE;t combat_spatial.arena_templates%ROWTYPE;
 actors jsonb; events jsonb; bodies jsonb; valid boolean; payload jsonb;
BEGIN
 SELECT * INTO STRICT i FROM combat_spatial.arena_instances WHERE instance_id=p_instance AND state='open';
 SELECT * INTO STRICT b FROM exam_regia_private.bindings WHERE combat_session_id=i.encounter_id AND master_session_id=i.master_session_id;
 SELECT * INTO STRICT t FROM combat_spatial.arena_templates WHERE template_key=i.template_key AND template_version=i.template_version;
 IF NOT EXISTS(SELECT 1 FROM public.combat_v2_rounds r JOIN public.combat_v2_round_reports q ON q.id=r.report_id AND q.round_id=r.id
 WHERE r.id=p_round AND r.session_id=b.combat_session_id AND r.state IN('risolto','narrazione','narrato') AND NOT q.values_written)
 THEN RAISE EXCEPTION 'exam_exchange_spatial_unresolved'; END IF;
 SELECT jsonb_agg(a.actor_id ORDER BY a.actor_id),jsonb_agg(jsonb_build_object('actor_id',a.actor_id,'x_m',a.x_m,'y_m',a.y_m,
 'body_version',a.body_version,'state',a.state) ORDER BY a.actor_id),count(*)=2 AND bool_and(a.footprint_radius_m>0 AND a.body_version>0
 AND a.x_m-a.footprint_radius_m>=0 AND a.y_m-a.footprint_radius_m>=0 AND a.x_m+a.footprint_radius_m<=t.width_m
 AND a.y_m+a.footprint_radius_m<=t.height_m) INTO actors,bodies,valid FROM combat_spatial.actor_states a
 WHERE a.instance_id=p_instance AND a.actor_id IN(b.player_actor_id,b.png_actor_id);
 IF valid IS DISTINCT FROM true THEN RAISE EXCEPTION 'exam_exchange_spatial_bounds'; END IF;
 -- Solo eventi realmente emessi dai moduli; lo snapshot non si spaccia per exchange_state.
 SELECT coalesce(jsonb_agg(jsonb_build_object('event_id',e.event_id,'actor_id',e.actor_id,'event_kind',e.event_kind,
 'before',e.before_state,'after',e.after_state) ORDER BY e.event_id),'[]'::jsonb) INTO events FROM combat_spatial.spatial_events e
 WHERE e.instance_id=p_instance AND (e.root_id=p_round OR EXISTS(SELECT 1 FROM public.combat_v2_declarations d WHERE d.round_id=p_round AND d.id=e.root_id)
 OR EXISTS(SELECT 1 FROM combat_spatial.substitution_activity_links l WHERE l.activity_round_id=p_round AND l.attack_declaration_id=e.root_id));
 payload:=jsonb_build_object('instance',p_instance,'round',p_round,'master',i.master_session_id,'encounter',i.encounter_id,
 'template',i.template_key,'template_version',i.template_version,'map_version',i.map_version,
 'bounds',jsonb_build_object('width_m',t.width_m,'height_m',t.height_m),'actors',actors,'events',events,'bodies',bodies);
 RETURN jsonb_build_object('schema_version','combat-spatial-exchange-owner/1.0','instance_id',p_instance,'round_id',p_round,
 'master_session_id',i.master_session_id,'encounter_id',i.encounter_id,'template_key',i.template_key,'template_version',i.template_version,
 'map_version',i.map_version,'bounds',payload->'bounds','actor_ids',actors,'events',events,'bounds_valid',true,'events_exact',true,
 'owner_fingerprint',public.combat_v2_sha256(payload));
END $x$;
CREATE FUNCTION exam_regia_private.exchange_wire(p_round uuid) RETURNS jsonb
LANGUAGE sql STABLE SECURITY DEFINER SET search_path='' AS $x$
 SELECT jsonb_build_object('schema_version','exam-exchange/1','cycle_id',c.id,'ordinal',CASE WHEN c.party_round_id=r.id THEN 1 ELSE 2 END,
 'logical_round',l.logical_round,'exchange_round_id',r.id,'report_id',r.report_id,'receipt_id',e.id,'receipt_sha256',e.receipt_sha256,
 'terminal',r.state IN('risolto','narrazione','narrato') AND exam_regia_private.round_is_final(r.id)) FROM public.combat_v2_rounds r
 JOIN exam_regia_private.exchange_links l ON l.prova_id=r.session_id AND l.logical_round=(r.round_no+1)/2
 JOIN mission_exchange_v3.cycles c ON c.id=l.cycle_id
 LEFT JOIN mission_exchange_v3.receipts e ON e.cycle_id=c.id AND e.combat_round_id=r.id WHERE r.id=p_round;
$x$;
CREATE FUNCTION exam_regia_private.pending_wire(p_round uuid) RETURNS jsonb
LANGUAGE plpgsql STABLE SECURITY DEFINER SET search_path='' AS $x$
DECLARE c mission_exchange_v3.cycles%ROWTYPE;ci mission_exchange_v3.counter_intents%ROWTYPE;
 d public.combat_v2_declarations%ROWTYPE;q exam_regia_private.receipts%ROWTYPE;label text;
BEGIN
 SELECT * INTO c FROM mission_exchange_v3.cycles WHERE party_round_id=p_round;
 IF NOT FOUND OR exam_regia_private.round_is_final(p_round) THEN RETURN NULL; END IF;
 SELECT * INTO STRICT ci FROM mission_exchange_v3.counter_intents WHERE cycle_id=c.id;
 SELECT * INTO STRICT d FROM public.combat_v2_declarations WHERE id=ci.declaration_id AND round_id=c.counter_round_id;
 SELECT * INTO STRICT q FROM exam_regia_private.receipts WHERE round_id=d.round_id AND kind='choice'
 AND command_receipt_id=ci.owner_receipt_id AND published_at IS NOT NULL;
 SELECT o.label INTO STRICT label FROM combat_panel_private.offers o WHERE o.id=(q.committed_command->>'offer_id')::uuid;
 RETURN jsonb_build_object('schema_version','exam-counter-intent/1','cycle_id',c.id,'exchange_round_id',c.counter_round_id,
 'declaration_id',d.id,'actor_id',d.actor_id,'target_actor_ids',(SELECT coalesce(jsonb_agg(t.target_actor_id ORDER BY t.ordinal),'[]'::jsonb)
 FROM public.combat_v2_attack_targets t WHERE t.attack_declaration_id=d.id),'source_id',q.command_receipt_id,
 'source_sha256',encode(extensions.digest(convert_to(d.declaration_text,'UTF8'),'sha256'),'hex'),
 'command_sha256',public.combat_v2_sha256(q.committed_command),'intent_sha256',ci.intent_sha256,
 'action_kind',d.kind,'action_label',label,'narrative_text',d.declaration_text,'resolution_status','pending');
END $x$;
CREATE FUNCTION exam_regia_private.resolve_capture(p_prova uuid,p_round uuid,p_key uuid) RETURNS void
LANGUAGE plpgsql SECURITY DEFINER SET search_path='' AS $x$
DECLARE b exam_regia_private.bindings%ROWTYPE;r public.combat_v2_rounds%ROWTYPE;c mission_exchange_v3.cycles%ROWTYPE;permit uuid;
BEGIN
 IF auth.uid() IS NOT NULL OR NOT public.combat_v2_is_service() THEN RAISE EXCEPTION 'exam_exchange_resolve_service'; END IF;
 SELECT * INTO STRICT b FROM exam_regia_private.bindings WHERE prova_id=p_prova AND state='active' FOR UPDATE;
 SELECT * INTO STRICT r FROM public.combat_v2_rounds WHERE id=p_round AND session_id=b.combat_session_id FOR UPDATE;
 SELECT * INTO STRICT c FROM mission_exchange_v3.cycles WHERE p_round IN(party_round_id,counter_round_id);
 IF r.state NOT IN('risolto','narrazione','narrato') THEN
  INSERT INTO exam_regia_private.execution_permits(prova_id,actor_id,principal_id,transaction_id,backend_pid,operation,request_key)
  VALUES(b.prova_id,b.png_actor_id,b.service_principal_id,txid_current(),pg_backend_pid(),'resolve',p_key) RETURNING id INTO permit;
  PERFORM public.combat_v2_round_resolve(p_round,p_key);
  UPDATE exam_regia_private.execution_permits SET consumed_at=clock_timestamp() WHERE id=permit;
 END IF;
 IF NOT EXISTS(SELECT 1 FROM mission_exchange_v3.receipts WHERE cycle_id=c.id AND combat_round_id=p_round) THEN
 PERFORM exam_regia_private.permit_exchange(b.prova_id);
  PERFORM public.mission_exchange_v3_capture(c.id,CASE WHEN c.party_round_id=p_round THEN 'party_offense' ELSE 'hostile_counter' END,
   p_round,md5('exam-capture|'||p_round::text)::uuid);
 END IF;
END $x$;
CREATE FUNCTION exam_regia_private.prepare_counter(p_receipt uuid) RETURNS void
LANGUAGE plpgsql SECURITY DEFINER SET search_path='' AS $x$
DECLARE q exam_regia_private.receipts%ROWTYPE;b exam_regia_private.bindings%ROWTYPE;r public.combat_v2_rounds%ROWTYPE;next_id uuid;
BEGIN
 SELECT * INTO STRICT q FROM exam_regia_private.receipts WHERE id=p_receipt AND kind='choice' AND phase='prepare_counter' FOR UPDATE;
 SELECT * INTO STRICT b FROM exam_regia_private.bindings WHERE prova_id=q.prova_id AND receipt_id=q.id FOR UPDATE;
 SELECT * INTO STRICT r FROM public.combat_v2_rounds WHERE id=q.round_id;
 PERFORM exam_regia_private.resolve_capture(b.prova_id,r.id,md5('exam-resolve|'||r.id::text)::uuid);
 IF exam_regia_private.round_is_final(r.id) THEN
  UPDATE exam_regia_private.receipts SET kind='narration',phase='risolto' WHERE id=q.id;
  UPDATE exam_regia_private.bindings SET receipt_kind='narration' WHERE prova_id=b.prova_id;
 ELSE
  PERFORM exam_regia_private.release_party_slot(b.prova_id,r.id,(SELECT er.id FROM mission_exchange_v3.receipts er WHERE er.combat_round_id=r.id AND er.ordinal=1));
  SELECT id INTO next_id FROM public.combat_v2_rounds WHERE session_id=r.session_id AND round_no=r.round_no+1;
  IF next_id IS NULL THEN
   INSERT INTO public.combat_v2_rounds(session_id,round_no,evaluation_mode) VALUES(r.session_id,r.round_no+1,r.evaluation_mode) RETURNING id INTO next_id;
  END IF;
  UPDATE exam_regia_private.receipts SET round_id=next_id,phase='raccolta_azioni' WHERE id=q.id;
 END IF;
END $x$;
CREATE FUNCTION exam_regia_private.exchange_after_publish(p_prova uuid,p_round uuid,p_draft uuid,p_publication uuid) RETURNS void
LANGUAGE plpgsql SECURITY DEFINER SET search_path='' AS $x$
DECLARE c mission_exchange_v3.cycles%ROWTYPE;e mission_exchange_v3.receipts%ROWTYPE;
BEGIN
 SELECT * INTO STRICT c FROM mission_exchange_v3.cycles WHERE p_round IN(party_round_id,counter_round_id) AND combat_session_id=p_prova;
 SELECT * INTO STRICT e FROM mission_exchange_v3.receipts WHERE cycle_id=c.id AND combat_round_id=p_round;
 PERFORM exam_regia_private.permit_exchange(p_prova);
 PERFORM public.mission_exchange_v3_publication_bind(c.id,e.id,p_draft,p_publication,md5('exam-pub-bind|'||p_round::text)::uuid);
 IF e.ordinal=2 OR exam_regia_private.round_is_final(p_round) THEN
 PERFORM exam_regia_private.permit_exchange(p_prova);
  PERFORM public.mission_exchange_v3_cycle_close(c.id,p_publication,md5('exam-cycle-close|'||c.id::text)::uuid);
 ELSE
 PERFORM exam_regia_private.permit_exchange(p_prova);
  PERFORM public.mission_exchange_v3_counter_open(c.id,c.counter_round_id,p_publication,md5('exam-counter-open|'||c.id::text)::uuid);
 END IF;
END $x$;
CREATE FUNCTION exam_regia_private.counter_source(p_session uuid,p_round uuid,p_roster_sha text) RETURNS jsonb
LANGUAGE plpgsql STABLE SECURITY DEFINER SET search_path='' AS $x$
DECLARE b exam_regia_private.bindings%ROWTYPE;d public.combat_v2_declarations%ROWTYPE;q exam_regia_private.receipts%ROWTYPE;
 cap exam_regia_private.ai_capabilities%ROWTYPE;profile exam_regia_private.profile_templates%ROWTYPE; ro jsonb;
BEGIN
 SELECT * INTO STRICT b FROM exam_regia_private.bindings WHERE combat_session_id=p_session;
 ro:=exam_regia_private.exchange_roster(p_session);
 IF p_roster_sha IS DISTINCT FROM mission_exchange_v3.sha('mission-exchange-roster/1.0',ro) THEN RAISE EXCEPTION 'exam_exchange_roster_sha'; END IF;
 SELECT * INTO STRICT d FROM public.combat_v2_declarations WHERE round_id=p_round AND actor_id=b.png_actor_id AND kind IN('attacco','movimento','utilita');
 SELECT qr.* INTO STRICT q FROM exam_regia_private.receipts qr WHERE qr.prova_id=b.prova_id AND qr.round_id=p_round AND qr.kind='choice'
 AND (qr.committed_command->>'request_key')::uuid=d.request_key AND qr.published_at IS NOT NULL;
 SELECT * INTO STRICT cap FROM exam_regia_private.ai_capabilities WHERE receipt_id=q.id AND consumed_at IS NOT NULL
 AND command_sha256=public.combat_v2_sha256(q.committed_command) AND actor_id=b.png_actor_id AND prova_id=b.prova_id AND q.committed_command->>'narrative_text'=d.declaration_text;
 IF NOT EXISTS(SELECT 1 FROM combat_panel_private.request_receipts cr WHERE cr.principal_user=b.service_principal_id AND cr.request_key=d.request_key
 AND cr.command_fingerprint=cap.command_sha256
 AND cr.viewer_envelope#>>'{receipt,receipt_id}'=q.command_receipt_id::text AND cr.viewer_envelope#>>'{receipt,declaration_id}'=d.id::text)
 THEN RAISE EXCEPTION 'exam_exchange_counter_receipt_invalid'; END IF;
 SELECT cache.* INTO STRICT profile FROM exam_regia_private.profile_templates cache JOIN public.combat_v2_png_instances i ON i.template_id=cache.template_id
 JOIN public.combat_v2_actors a ON a.png_instance_id=i.id WHERE a.id=b.png_actor_id;
 RETURN jsonb_build_object('schema_version','combat-v2-counter-intent-owner/1.0','session_id',p_session,'round_id',p_round,
 'roster_sha256',p_roster_sha,'actor_id',d.actor_id,'target_actor_id',coalesce(d.target_actor_id,b.player_actor_id),
 'declaration_id',d.id,'persona_authority_id',profile.profile_id,'persona_digest',profile.source_sha256,'intent',d.sanitized_intent,
 'outcome_status','pending','owner_receipt_id',q.command_receipt_id,'owner_receipt_sha256',public.combat_v2_sha256(
 jsonb_build_object('command',q.committed_command,'receipt',q.command_receipt_id,'declaration',d.id,'persona',profile.source_sha256)));
END $x$;
CREATE FUNCTION exam_regia_private.counter_is_nonattack(p_cycle uuid,p_round uuid) RETURNS boolean
LANGUAGE sql STABLE SECURITY DEFINER SET search_path='' AS $x$
 SELECT EXISTS(SELECT 1 FROM mission_exchange_v3.counter_intents ci JOIN public.combat_v2_declarations d ON d.id=ci.declaration_id
 JOIN public.combat_v2_rounds r ON r.id=d.round_id JOIN exam_regia_private.bindings b ON b.combat_session_id=r.session_id
 WHERE ci.cycle_id=p_cycle AND d.round_id=p_round AND d.actor_id=b.png_actor_id AND d.kind IN('movimento','utilita')
 AND d.state='risolta' AND ci.intent=d.sanitized_intent AND ci.actor_id=d.actor_id);
$x$;
CREATE FUNCTION exam_regia_private.assert_successor(p_prior uuid,p_next uuid) RETURNS void
LANGUAGE plpgsql SECURITY DEFINER SET search_path='' AS $x$
BEGIN
 IF NOT EXISTS(SELECT 1 FROM mission_exchange_v3.cycles c JOIN exam_regia_private.exchange_links x ON x.cycle_id=c.id
 WHERE c.party_round_id=p_prior AND c.counter_round_id=p_next AND c.state='counter_intent_ready'
 AND public.combat_v2_exchange_round_successor(p_prior,p_next,c.combat_session_id))
 THEN RAISE EXCEPTION 'exam_exchange_successor_not_attested'; END IF;
END $x$;
CREATE FUNCTION exam_regia_private.publication_source(p_cycle uuid,p_receipt uuid,p_draft uuid,p_publication uuid) RETURNS jsonb
LANGUAGE plpgsql STABLE SECURITY DEFINER SET search_path='' AS $x$
DECLARE q record;
BEGIN
 SELECT d.payload#>>'{regia,scene_binding,scene_sha256}' AS scene_sha INTO STRICT q FROM mission_exchange_v3.receipts e
 JOIN mission_exchange_v3.cycles c ON c.id=e.cycle_id JOIN exam_regia_private.bindings b ON b.combat_session_id=c.combat_session_id
 JOIN exam_regia_private.receipts r ON r.prova_id=b.prova_id AND r.round_id=e.combat_round_id AND r.kind='narration'
 JOIN public.esame_supervisione_bozze d ON d.id=r.draft_id
 JOIN public.combat_v2_narratives n ON n.round_id=e.combat_round_id AND n.request_key=d.id
 JOIN public.combat_v2_round_reports rep ON rep.id=n.report_id AND rep.round_id=e.combat_round_id
 JOIN public.messages m ON m.id=rep.message_id AND m.location_id=b.location_id AND m.kind='fato'
 WHERE e.cycle_id=p_cycle AND e.id=p_receipt AND d.id=p_draft AND n.id=p_publication AND d.stato='pubblicata'
 AND d.approvata_da=b.owner_user AND d.autore=b.owner_user AND r.published_at IS NOT NULL
 AND d.risultato->>'testo'=n.body AND m.body=n.body AND rep.narration_state='pubblicata'
 AND e.combat_owner->>'report_sha256'=rep.mechanics_sha256
 AND public._esame_supervisione_hash(jsonb_build_object('ricevuta',d.ricevuta,'payload_sha',d.payload_sha,'risultato',d.risultato))=d.sha;
 RETURN jsonb_build_object('projection_sha256',q.scene_sha);
END $x$;

CREATE OR REPLACE FUNCTION exam_regia_private.advance(p_prova uuid) RETURNS void
LANGUAGE plpgsql SECURITY DEFINER SET search_path='' AS $x$
DECLARE b exam_regia_private.bindings%ROWTYPE;r public.combat_v2_rounds%ROWTYPE;c mission_exchange_v3.cycles%ROWTYPE;
 q exam_regia_private.receipts%ROWTYPE;opened jsonb;receipt uuid;next_kind text;next_phase text;next_round uuid;logical integer;
BEGIN
 SELECT * INTO STRICT b FROM exam_regia_private.bindings WHERE prova_id=p_prova FOR UPDATE;
 IF b.state IN('opening','closed','paused','congedo') THEN RETURN; END IF;
 SELECT * INTO STRICT r FROM public.combat_v2_rounds WHERE session_id=b.combat_session_id ORDER BY round_no DESC LIMIT 1;
 logical:=(r.round_no+1)/2;
 SELECT c0.* INTO c FROM mission_exchange_v3.cycles c0 JOIN exam_regia_private.exchange_links l ON l.cycle_id=c0.id
 WHERE l.prova_id=b.prova_id AND l.logical_round=logical FOR UPDATE OF c0;
 IF NOT FOUND THEN
  IF r.round_no%2<>1 OR logical>4 THEN RAISE EXCEPTION 'exam_exchange_cycle_order'; END IF;
 PERFORM exam_regia_private.permit_exchange(b.prova_id);
  opened:=public.mission_exchange_v3_cycle_open(b.master_session_id,b.combat_session_id,md5('exam-instance|'||b.prova_id::text)::uuid,
   r.id,md5('exam-cycle-open|'||r.id::text)::uuid);
  INSERT INTO exam_regia_private.exchange_links(cycle_id,prova_id,logical_round) VALUES((opened->>'cycle_id')::uuid,b.prova_id,logical);
  SELECT * INTO STRICT c FROM mission_exchange_v3.cycles WHERE id=(opened->>'cycle_id')::uuid;
 END IF;
 next_round:=r.id;next_phase:=r.phase;
 IF c.state='party_open' THEN
  IF NOT EXISTS(SELECT 1 FROM public.combat_v2_declarations WHERE round_id=c.party_round_id AND actor_id=b.player_actor_id
   AND kind IN('attacco','movimento','utilita')) THEN next_kind:='player';
  ELSIF EXISTS(SELECT 1 FROM public.combat_v2_attack_targets t WHERE t.round_id=c.party_round_id AND t.target_actor_id=b.png_actor_id AND t.state='attesa_difesa' AND NOT EXISTS(SELECT 1 FROM public.combat_v2_defense_coverages cv WHERE cv.attack_target_id=t.id)) THEN next_kind:='choice';
  ELSE next_kind:='choice';next_phase:='prepare_counter'; END IF;
 ELSIF c.state IN('party_captured','counter_intent_ready') THEN
  IF c.state='party_captured' THEN
   SELECT * INTO q FROM exam_regia_private.receipts WHERE prova_id=b.prova_id AND round_id=r.id AND kind='choice'
    AND committed_command IS NOT NULL AND published_at IS NOT NULL;
   IF q.id IS NULL THEN RAISE EXCEPTION 'exam_exchange_counter_choice_unpublished'; END IF;
 PERFORM exam_regia_private.permit_exchange(b.prova_id);
   PERFORM public.mission_exchange_v3_counter_intent_prepare(c.id,r.id,md5('exam-counter-intent|'||r.id::text)::uuid);
  END IF;
  next_kind:='narration';next_round:=c.party_round_id;next_phase:='risolto';
 ELSIF c.state='counter_open' THEN
  IF EXISTS(SELECT 1 FROM public.combat_v2_attack_targets t WHERE t.round_id=c.counter_round_id AND t.target_actor_id=b.player_actor_id AND t.state='attesa_difesa' AND NOT EXISTS(SELECT 1 FROM public.combat_v2_defense_coverages cv WHERE cv.attack_target_id=t.id)) THEN next_kind:='player';
  ELSE next_kind:='narration'; END IF;
  next_round:=c.counter_round_id;
 ELSE RAISE EXCEPTION 'exam_exchange_state_not_actionable'; END IF;
 receipt:=gen_random_uuid();
 IF next_kind IN('choice','narration') THEN
  INSERT INTO exam_regia_private.receipts(id,prova_id,kind,round_id,phase) VALUES(receipt,b.prova_id,next_kind,next_round,next_phase);
 END IF;
 UPDATE exam_regia_private.bindings SET receipt_id=receipt,receipt_kind=next_kind,updated_at=clock_timestamp() WHERE prova_id=b.prova_id;
 UPDATE public.esame_prove SET opzioni_id=receipt,opzioni_at=clock_timestamp(),scambio=logical,beat=logical,
 meta='candidato',fase=CASE WHEN c.state='counter_open' THEN 'difesa' ELSE 'attacco' END,updated_at=clock_timestamp() WHERE id=b.prova_id;
 UPDATE public.esame_supervisione SET player_ready=next_kind='player',publishing=false,idle_deadline=NULL WHERE prova=b.prova_id;
END $x$;

-- EXAM-REGIA17-SCENE-001. Modulo candidato, da incorporare nel BUILD del DB owner.
-- Solo letture: VOLATILE permette di osservare il resolver già eseguito nello
-- stesso claim/transazione. La funzione non risolve e non pubblica alcunché.
CREATE OR REPLACE FUNCTION exam_regia_private.scene(p_prova uuid,p_round uuid)
RETURNS jsonb LANGUAGE plpgsql VOLATILE SECURITY DEFINER SET search_path='' AS $scene$
DECLARE
 b exam_regia_private.bindings%ROWTYPE; s public.combat_v2_sessions%ROWTYPE;
 r public.combat_v2_rounds%ROWTYPE; rep public.combat_v2_round_reports%ROWTYPE;
 pg public.combat_v2_actors%ROWTYPE; npc public.combat_v2_actors%ROWTYPE;
 inst public.combat_v2_png_instances%ROWTYPE; profile exam_regia_private.profile_templates%ROWTYPE;
 place public.locations%ROWTYPE; d public.combat_v2_declarations%ROWTYPE; row record;
 pg_name text; body text; source_id text; source_hash text; technique text; ability uuid;
 actors jsonb; actions jsonb:='[]'; sources jsonb:='[]'; facts jsonb:='[]'; spatial jsonb:='[]';
 projected jsonb; recorded jsonb; narrator jsonb; snapshot jsonb; candidate jsonb; output jsonb;
 final_round boolean; previous_count integer:=0; included integer:=0; declaration_count integer:=0;
BEGIN
 IF NOT public.combat_v2_is_service() OR auth.uid() IS NOT NULL OR p_prova IS NULL OR p_round IS NULL THEN
  RAISE EXCEPTION 'exam_regia_scene_service_required' USING ERRCODE='42501';
 END IF;
 SELECT * INTO STRICT b FROM exam_regia_private.bindings WHERE prova_id=p_prova;
 SELECT * INTO STRICT s FROM public.combat_v2_sessions WHERE id=b.combat_session_id;
 SELECT * INTO STRICT r FROM public.combat_v2_rounds WHERE id=p_round AND session_id=s.id;
 SELECT * INTO STRICT rep FROM public.combat_v2_round_reports WHERE round_id=r.id AND id=r.report_id;
 IF b.state<>'active' OR b.policy_id<>'exam_protected_no_persistent_resources_v1' OR b.control_version<1
  OR s.source_kind<>'master' OR s.master_session_id IS DISTINCT FROM b.master_session_id
  OR s.location_id IS DISTINCT FROM b.location_id OR s.lesiva IS DISTINCT FROM false
  OR public.combat_v2_values_written(s.id) IS DISTINCT FROM false
  OR r.state NOT IN ('risolto','narrazione','narrato') OR r.resolved_at IS NULL OR r.round_no NOT BETWEEN 1 AND 8
  OR rep.values_written IS DISTINCT FROM false OR rep.mechanics->'values_written' IS DISTINCT FROM 'false'::jsonb
  OR rep.mechanics_sha256 IS DISTINCT FROM public.combat_v2_sha256(rep.mechanics)
  OR NOT EXISTS(SELECT 1 FROM public.master_v2_sessions m WHERE m.id=b.master_session_id
    AND m.owner_kind='ai_service' AND m.master_user IS NULL AND m.location_id=b.location_id)
 THEN RAISE EXCEPTION 'exam_regia_scene_binding_invalid' USING ERRCODE='55000'; END IF;
 SELECT * INTO STRICT pg FROM public.combat_v2_actors WHERE id=b.player_actor_id AND session_id=s.id
  AND actor_kind='pg' AND character_id=b.character_id AND controller_user=b.owner_user;
 SELECT * INTO STRICT npc FROM public.combat_v2_actors WHERE id=b.png_actor_id AND session_id=s.id
  AND actor_kind='png' AND character_id IS NULL AND controller_user IS NULL;
 IF pg.id=npc.id OR (SELECT count(*) FROM public.combat_v2_actors WHERE session_id=s.id)<>2 THEN
  RAISE EXCEPTION 'exam_regia_scene_roster_invalid' USING ERRCODE='55000'; END IF;
 SELECT name INTO STRICT pg_name FROM public.characters WHERE id=b.character_id AND user_id=b.owner_user;
 SELECT * INTO STRICT inst FROM public.combat_v2_png_instances WHERE id=npc.png_instance_id AND session_id=s.id;
 SELECT * INTO STRICT profile FROM exam_regia_private.profile_templates WHERE template_id=inst.template_id;
 SELECT * INTO STRICT place FROM public.locations WHERE id=b.location_id;
 IF nullif(btrim(pg_name),'') IS NULL OR nullif(btrim(inst.nome),'') IS NULL
  OR nullif(btrim(profile.persona),'') IS NULL OR nullif(btrim(place.name),'') IS NULL
  OR profile.source_sha256 !~ '^[0-9a-f]{64}$' THEN
  RAISE EXCEPTION 'exam_regia_scene_identity_invalid' USING ERRCODE='55000'; END IF;
 actors:=jsonb_build_array(
  jsonb_build_object('id',pg.id,'name',pg_name,'kind','PG','persona',NULL,'may_speak',false),
  jsonb_build_object('id',npc.id,'name',inst.nome,'kind','PNG','persona',profile.persona,'may_speak',true));

 -- Le fonti setting precedono le role: ordine richiesto da buildScene invariato.
 IF nullif(btrim(place.description),'') IS NOT NULL THEN
  body:=place.description;
  sources:=sources||jsonb_build_array(jsonb_build_object('id','location:'||place.id,'session_id',s.id,
   'round_id',r.id,'kind','setting','actor_id',NULL,'sequence',r.round_no,'body',body,
   'sha256',encode(extensions.digest(convert_to(body,'UTF8'),'sha256'),'hex'),'visibility','public','complete',true));
 END IF;
 -- L'incipit è già pubblico: ricevuta e sigillo SESSION, nessuna scansione chat.
 FOR row IN SELECT z.id,z.risultato,z.sha,z.ricevuta,z.payload_sha FROM public.esame_supervisione_bozze z
 JOIN public.esame_supervisione h ON h.prova=z.prova AND h.apertura_ricevuta=z.ricevuta
 WHERE z.prova=b.prova_id AND z.tipo='apertura' AND z.stato='pubblicata' AND h.apertura_pubblicata
 ORDER BY z.autorizzata_at,z.id
 LOOP
  IF row.sha IS DISTINCT FROM public._esame_supervisione_hash(jsonb_build_object(
   'ricevuta',row.ricevuta,'payload_sha',row.payload_sha,'risultato',row.risultato))
   OR row.risultato->'ok' IS DISTINCT FROM 'true'::jsonb OR row.risultato->'publishable' IS DISTINCT FROM 'true'::jsonb
   THEN RAISE EXCEPTION 'exam_regia_scene_opening_changed' USING ERRCODE='55000'; END IF;
  body:=btrim(row.risultato->>'testo');
  IF nullif(body,'') IS NULL THEN RAISE EXCEPTION 'exam_regia_scene_opening_empty' USING ERRCODE='55000'; END IF;
  sources:=sources||jsonb_build_array(jsonb_build_object('id','opening:'||row.id,'session_id',s.id,
   'round_id',r.id,'kind','setting','actor_id',NULL,'sequence',0,'body',body,
   'sha256',encode(extensions.digest(convert_to(body,'UTF8'),'sha256'),'hex'),'visibility','public','complete',true));
 END LOOP;
 IF (SELECT count(*) FROM public.esame_supervisione_bozze z JOIN public.esame_supervisione h
 ON h.prova=z.prova AND h.apertura_ricevuta=z.ricevuta WHERE z.prova=b.prova_id
 AND z.tipo='apertura' AND z.stato='pubblicata' AND h.apertura_pubblicata)<>1 THEN
  RAISE EXCEPTION 'exam_regia_scene_opening_missing' USING ERRCODE='55000'; END IF;
 final_round:=exam_regia_private.round_is_final(r.id);
 IF final_round THEN
  body:='Lo scontro della prova Genin è concluso. Il Sensei invita il candidato al congedo. La prova è protetta: nessuna promozione, premio o modifica alla scheda reale.';
  sources:=sources||jsonb_build_array(jsonb_build_object('id','exam-final:'||r.id,'session_id',s.id,
   'round_id',r.id,'kind','setting','actor_id',NULL,'sequence',r.round_no,'body',body,
   'sha256',encode(extensions.digest(convert_to(body,'UTF8'),'sha256'),'hex'),'visibility','public','complete',true));
 END IF;

 IF jsonb_typeof(rep.mechanics->'declarations') IS DISTINCT FROM 'array' OR EXISTS(
  SELECT 1 FROM public.combat_v2_declarations x WHERE x.round_id=r.id AND
   (x.actor_id NOT IN(pg.id,npc.id) OR x.kind NOT IN('attacco','utilita','movimento','difesa') OR x.state NOT IN('risolta','superflua')))
 THEN RAISE EXCEPTION 'exam_regia_scene_declarations_invalid' USING ERRCODE='55000'; END IF;
 FOR d IN SELECT * FROM public.combat_v2_declarations WHERE round_id=r.id
  ORDER BY CASE WHEN kind='difesa' THEN 1 ELSE 0 END,order_no NULLS LAST,id
 LOOP
  SELECT value INTO STRICT recorded FROM jsonb_array_elements(rep.mechanics->'declarations') WHERE value->>'id'=d.id::text;
  IF recorded->>'actor' IS DISTINCT FROM d.actor_id::text OR recorded->>'kind' IS DISTINCT FROM d.kind
   OR recorded->>'state' IS DISTINCT FROM d.state OR recorded->'outcome' IS DISTINCT FROM d.outcome THEN
   RAISE EXCEPTION 'exam_regia_scene_report_declaration_changed' USING ERRCODE='55000'; END IF;
  IF d.actor_id=pg.id THEN
   SELECT m.id::text,m.body INTO STRICT source_id,body FROM combat_consumer_private.declaration_messages link
    JOIN public.messages m ON m.id=link.message_id WHERE link.declaration_id=d.id
    AND m.location_id=b.location_id AND m.character_id=b.character_id AND m.sender_user=b.owner_user
    AND m.recipient_user IS NULL AND m.kind NOT IN ('whisper','motore')
    AND public._combat_narrative_sha(m.id)=link.message_sha256;
  ELSE
   -- Fonte PNG pubblicabile autorizzata dalla capacità consumata. La difesa
   -- non ha un messaggio anticipato; non si fabbrica il collegamento a messages.
   IF NOT EXISTS(SELECT 1 FROM exam_regia_private.ai_capabilities cap
    JOIN exam_regia_private.receipts q ON q.id=cap.receipt_id AND q.prova_id=cap.prova_id
    JOIN combat_panel_private.request_receipts rr ON rr.principal_user=b.service_principal_id
     AND rr.request_key=cap.request_key
    WHERE cap.prova_id=b.prova_id AND cap.actor_id=npc.id AND cap.consumed_at IS NOT NULL
     AND cap.request_key=d.request_key AND q.round_id=r.id AND q.kind='choice' AND q.command_receipt_id IS NOT NULL
     AND q.published_at IS NOT NULL AND q.committed_command->>'request_key'=d.request_key::text
     AND q.committed_command->>'narrative_text'=d.declaration_text
     AND cap.command_sha256=public.combat_v2_sha256(q.committed_command)
     AND rr.command_fingerprint=cap.command_sha256
     AND rr.viewer_envelope#>>'{receipt,receipt_id}'=q.command_receipt_id::text
     AND rr.viewer_envelope#>>'{receipt,declaration_id}'=d.id::text)
   THEN RAISE EXCEPTION 'exam_regia_scene_png_source_invalid' USING ERRCODE='55000'; END IF;
   source_id:='declaration:'||d.id;body:=d.declaration_text;
  END IF;
  IF nullif(btrim(body),'') IS NULL THEN RAISE EXCEPTION 'exam_regia_scene_role_empty' USING ERRCODE='55000'; END IF;
  source_hash:=encode(extensions.digest(convert_to(body,'UTF8'),'sha256'),'hex');
  actions:=actions||jsonb_build_array(jsonb_build_object('actor_id',d.actor_id,'role',CASE WHEN d.kind='difesa' THEN 'difesa' ELSE 'azione' END,'source_id',source_id));
  sources:=sources||jsonb_build_array(jsonb_build_object('id',source_id,'session_id',s.id,'round_id',r.id,
   'kind','role','actor_id',d.actor_id,'sequence',r.round_no,'body',body,'sha256',source_hash,'visibility','public','complete',true));
  declaration_count:=declaration_count+1;
  IF d.state='risolta' THEN projected:=combat_panel_private.narrative_declaration_facts(d.id);
  ELSE projected:=jsonb_build_object('schema_version','combat-narrative-facts/1','kind',d.kind,
   'execution','not_executed','result',combat_panel_private.narrative_outcome_facts(d.outcome)); END IF;
  technique:=NULL;ability:=NULL;
  IF d.sanitized_intent->>'ability_id' ~* '^[0-9a-f]{8}(-[0-9a-f]{4}){3}-[0-9a-f]{12}$' THEN
   ability:=(d.sanitized_intent->>'ability_id')::uuid;
   IF d.sanitized_intent->>'ability_source'='jutsu' THEN SELECT name_it INTO technique FROM public.jutsu WHERE id=ability;
   ELSIF d.sanitized_intent->>'ability_source'='clan' THEN SELECT name INTO technique FROM public.clan_techniques WHERE id=ability; END IF;
  END IF;
  IF projected ? 'multiplication_created' THEN technique:='Moltiplicazione'; END IF;
  facts:=facts||jsonb_build_array(jsonb_build_object('actor_id',d.actor_id,'target_actor_id',d.target_actor_id,
   'role',CASE WHEN d.kind='difesa' THEN 'difesa' ELSE 'azione' END,'source_id',source_id,
   'technique',technique,'reaction',CASE WHEN d.kind='difesa' THEN d.sanitized_intent->>'reaction' ELSE NULL END,
   'facts',projected));
  IF d.kind='movimento' AND d.state='risolta' THEN
   -- Distanza assestata del movimento, già esito nativo; nessuna posizione o
   -- figura originale. Gli stati before/after del kernel restano privati.
   IF d.outcome ? 'movement_m' AND (jsonb_typeof(d.outcome->'movement_m')<>'number' OR (d.outcome->>'movement_m')::numeric<0) THEN
    RAISE EXCEPTION 'exam_regia_scene_movement_invalid' USING ERRCODE='55000'; END IF;
   spatial:=spatial||jsonb_build_array(jsonb_build_object('actor_id',d.actor_id,'kind','movement',
    'distance_m',d.outcome->'movement_m','reason',d.outcome->'reason_code'));
  END IF;
 END LOOP;
 IF declaration_count<>jsonb_array_length(rep.mechanics->'declarations') OR
  (SELECT count(*) FROM public.combat_v2_declarations WHERE round_id=r.id AND kind<>'difesa')<>1 OR
  NOT EXISTS(SELECT 1 FROM public.combat_v2_declarations WHERE round_id=r.id AND kind<>'difesa'
   AND actor_id=CASE WHEN r.round_no%2=1 THEN pg.id ELSE npc.id END) OR
  NOT EXISTS(SELECT 1 FROM mission_exchange_v3.receipts e WHERE e.combat_round_id=r.id AND e.combat_owner->>'report_sha256'=rep.mechanics_sha256) THEN
  RAISE EXCEPTION 'exam_regia_scene_actions_incomplete' USING ERRCODE='55000'; END IF;

 -- Substitution receipt è già proiezione narratore del resolver. Selezioniamo
 -- solo identità del difensore, esito e descrizioni semantiche; niente indici,
 -- coordinate, before/after_state o interi mechanics_snapshot.
 IF jsonb_typeof(rep.mechanics->'substitution_receipts') IS DISTINCT FROM 'array' THEN
  RAISE EXCEPTION 'exam_regia_scene_substitution_missing' USING ERRCODE='55000'; END IF;
 FOR recorded IN SELECT value FROM jsonb_array_elements(rep.mechanics->'substitution_receipts') LOOP
  narrator:=recorded->'narrator_payload';
  IF recorded->>'round_id' IS DISTINCT FROM r.id::text OR recorded->>'actor_id' IS NULL OR recorded->>'actor_id' NOT IN(pg.id::text,npc.id::text)
   OR recorded->>'event_kind' IS DISTINCT FROM 'substitution_committed'
   OR narrator->>'schema_version' IS DISTINCT FROM 'common-substitution-narrator/1.0'
   OR narrator#>>'{impact,outcome}' IS NULL OR narrator#>>'{impact,outcome}' NOT IN('negato_sostituzione','reazione_spesa_su_copia')
   OR narrator#>>'{impact,proxy}' IS DISTINCT FROM 'semantic_non_actor'
   OR narrator#>>'{after,state}' IS DISTINCT FROM 'defender_relocated'
   OR nullif(btrim(narrator#>>'{anchor,semantic_label}'),'') IS NULL
   OR nullif(btrim(narrator#>>'{after,semantic_region}'),'') IS NULL THEN
   RAISE EXCEPTION 'exam_regia_scene_substitution_invalid' USING ERRCODE='55000'; END IF;
  spatial:=spatial||jsonb_build_array(jsonb_build_object('actor_id',recorded->'actor_id','kind','substitution',
   'outcome',narrator#>'{impact,outcome}','anchor',narrator#>'{anchor,semantic_label}',
   'after',narrator#>'{after,semantic_region}'));
 END LOOP;

 SELECT count(*) INTO previous_count FROM public.combat_v2_narratives n
  JOIN public.combat_v2_rounds old ON old.id=n.round_id AND old.session_id=s.id
  JOIN public.combat_v2_round_reports q ON q.id=n.report_id AND q.round_id=old.id
  WHERE old.round_no<r.round_no AND old.state='narrato' AND q.narration_state='pubblicata';
 snapshot:=jsonb_build_object('schema_version','combat-scene/1','session_id',s.id,'round_id',r.id,
  'report_sha256',rep.mechanics_sha256,'control_version',b.control_version,'location',place.name,
  'actors',actors,'actions',actions,'resolved_facts',(jsonb_build_object('schema_version','exam-regia-resolved-facts/1',
    'round_no',exam_regia_private.logical_round_no(r.id),'final',final_round,'declarations',facts,'spatial',spatial)||combat_consumer_private.narrative_tech_sources_v1(b.receipt_id))::text,'sources',sources,
  'selection',jsonb_build_object('max_input_bytes',49152,'previous_available',previous_count,'previous_included',0));
 IF octet_length(snapshot::text)>49152 THEN RAISE EXCEPTION 'scene_required_context_overflow' USING ERRCODE='54000'; END IF;
 FOR row IN SELECT n.id,n.round_id,n.body,old.round_no,q.message_id FROM public.combat_v2_narratives n
  JOIN public.combat_v2_rounds old ON old.id=n.round_id AND old.session_id=s.id
  JOIN public.combat_v2_round_reports q ON q.id=n.report_id AND q.round_id=old.id
  WHERE old.round_no<r.round_no AND old.state='narrato' AND q.narration_state='pubblicata'
  ORDER BY old.round_no DESC,n.id
 LOOP
  IF nullif(btrim(row.body),'') IS NULL OR NOT EXISTS(SELECT 1 FROM public.messages m
   WHERE m.id=row.message_id AND m.location_id=b.location_id AND m.character_id IS NULL AND m.sender_user IS NULL
   AND m.recipient_user IS NULL AND m.kind='fato' AND m.body=row.body) THEN
   RAISE EXCEPTION 'exam_regia_scene_previous_changed' USING ERRCODE='55000'; END IF;
  candidate:=jsonb_set(snapshot,'{sources}',(snapshot->'sources')||jsonb_build_array(jsonb_build_object(
   'id',row.id,'session_id',s.id,'round_id',row.round_id,'kind','fato','actor_id',NULL,'sequence',row.round_no,
   'body',row.body,'sha256',encode(extensions.digest(convert_to(row.body,'UTF8'),'sha256'),'hex'),'visibility','public','complete',true)));
  candidate:=jsonb_set(candidate,'{selection,previous_included}',to_jsonb(included+1));
  IF octet_length(candidate::text)<=49152 THEN included:=included+1;snapshot:=candidate; END IF;
 END LOOP;
 source_hash:=public.combat_v2_sha256(snapshot);
 output:=jsonb_build_object('scene',jsonb_build_object('snapshot',snapshot,'snapshot_sha256',source_hash),
  'scene_binding',jsonb_build_object('session_id',s.id,'round_id',r.id,'report_sha256',rep.mechanics_sha256,
   'control_version',b.control_version,'hash_authority','combat_v2_sha256/jsonb','scene_sha256',source_hash));
 RETURN output;
END $scene$;
REVOKE ALL ON FUNCTION exam_regia_private.scene(uuid,uuid) FROM PUBLIC,anon,authenticated;
GRANT EXECUTE ON FUNCTION exam_regia_private.scene(uuid,uuid) TO service_role;

CREATE FUNCTION exam_regia_private.binding_identity_guard() RETURNS trigger
LANGUAGE plpgsql SECURITY DEFINER SET search_path='' AS $fn$
BEGIN
 IF TG_OP='UPDATE' AND (NEW.prova_id,NEW.admission_id,NEW.class_session_id,NEW.master_session_id,NEW.combat_session_id,
 NEW.player_actor_id,NEW.png_actor_id,NEW.owner_user,NEW.character_id,NEW.location_id,NEW.service_principal_id,NEW.request_key,NEW.policy_id)
 IS DISTINCT FROM (OLD.prova_id,OLD.admission_id,OLD.class_session_id,OLD.master_session_id,OLD.combat_session_id,
 OLD.player_actor_id,OLD.png_actor_id,OLD.owner_user,OLD.character_id,OLD.location_id,OLD.service_principal_id,OLD.request_key,OLD.policy_id)
 THEN RAISE EXCEPTION 'exam_regia_binding_identity_immutable' USING ERRCODE='42501'; END IF;
 IF TG_OP='UPDATE' AND OLD.state='closed' AND NEW IS DISTINCT FROM OLD
 THEN RAISE EXCEPTION 'exam_regia_closed_immutable' USING ERRCODE='42501'; END IF;
 IF NOT EXISTS(SELECT 1 FROM exam_regia_private.admissions a JOIN public.characters c ON c.id=a.character_id
 WHERE a.id=NEW.admission_id AND (a.owner_user,a.character_id,a.location_id)=(NEW.owner_user,NEW.character_id,NEW.location_id)
 AND c.user_id=NEW.owner_user) OR NEW.service_principal_id=NEW.owner_user
 THEN RAISE EXCEPTION 'exam_regia_binding_identity_invalid' USING ERRCODE='42501'; END IF;
 RETURN NEW;
END $fn$;
CREATE TRIGGER exam_regia_binding_identity BEFORE INSERT OR UPDATE ON exam_regia_private.bindings
 FOR EACH ROW EXECUTE FUNCTION exam_regia_private.binding_identity_guard();
CREATE FUNCTION exam_regia_private.captured_slot_guard() RETURNS trigger
LANGUAGE plpgsql SECURITY DEFINER SET search_path='' AS $slot$
DECLARE b exam_regia_private.bindings%ROWTYPE;c mission_exchange_v3.cycles%ROWTYPE;e mission_exchange_v3.receipts%ROWTYPE;
 rep public.combat_v2_round_reports%ROWTYPE;permit uuid;
BEGIN
 IF TG_OP='INSERT' THEN
  IF NEW.exam_captured_receipt_id IS NOT NULL THEN RAISE EXCEPTION 'exam_slot_insert_forbidden' USING ERRCODE='42501'; END IF;
  RETURN NEW;
 END IF;
 IF OLD.exam_captured_receipt_id IS NOT NULL THEN
  IF NEW.exam_captured_receipt_id IS DISTINCT FROM OLD.exam_captured_receipt_id
   OR (NEW.id,NEW.session_id,NEW.round_no,NEW.report_id,NEW.resolved_at) IS DISTINCT FROM
      (OLD.id,OLD.session_id,OLD.round_no,OLD.report_id,OLD.resolved_at)
   OR NEW.state NOT IN('risolto','narrato') OR NEW.phase NOT IN('risolto','narrato')
  THEN RAISE EXCEPTION 'exam_slot_identity_immutable' USING ERRCODE='42501'; END IF;
  IF NEW.state='narrato' AND OLD.state<>'narrato' AND NOT EXISTS(
   SELECT 1 FROM public.combat_v2_round_reports rp JOIN public.combat_v2_narratives n ON n.report_id=rp.id AND n.round_id=NEW.id
   WHERE rp.id=NEW.report_id AND rp.round_id=NEW.id AND rp.narration_state='pubblicata' AND rp.message_id IS NOT NULL)
  THEN RAISE EXCEPTION 'exam_slot_publication_required' USING ERRCODE='23514'; END IF;
  RETURN NEW;
 END IF;
 IF NEW.exam_captured_receipt_id IS NULL THEN RETURN NEW; END IF;
 IF auth.uid() IS NOT NULL OR NOT public.combat_v2_is_service()
  OR (to_jsonb(NEW)-'exam_captured_receipt_id') IS DISTINCT FROM (to_jsonb(OLD)-'exam_captured_receipt_id')
 THEN RAISE EXCEPTION 'exam_slot_service_only' USING ERRCODE='42501'; END IF;
 SELECT * INTO STRICT b FROM exam_regia_private.bindings WHERE combat_session_id=NEW.session_id FOR UPDATE;
 SELECT * INTO STRICT e FROM mission_exchange_v3.receipts WHERE id=NEW.exam_captured_receipt_id;
 SELECT * INTO STRICT c FROM mission_exchange_v3.cycles WHERE id=e.cycle_id FOR UPDATE;
 SELECT * INTO STRICT rep FROM public.combat_v2_round_reports WHERE id=NEW.report_id AND round_id=NEW.id;
 IF b.state<>'active' OR NOT exam_regia_private.is_bound(NEW.session_id)
  OR NOT EXISTS(SELECT 1 FROM mission_exam_private.protected_sessions ps WHERE ps.class_session_id=b.class_session_id AND ps.closed_at IS NULL)
  OR exam_regia_private.round_is_final(NEW.id) OR NEW.state<>'risolto' OR NEW.phase<>'risolto' OR NEW.resolved_at IS NULL OR NEW.round_no%2<>1
  OR c.combat_session_id<>NEW.session_id OR c.party_round_id<>NEW.id OR c.state<>'party_captured'
  OR c.counter_round_id IS NOT NULL OR e.ordinal<>1 OR e.combat_round_id<>NEW.id
  OR rep.values_written IS DISTINCT FROM false OR rep.mechanics_sha256 IS DISTINCT FROM (e.combat_owner->>'report_sha256')
  OR NOT EXISTS(SELECT 1 FROM exam_regia_private.exchange_links l WHERE l.prova_id=b.prova_id AND l.cycle_id=c.id
   AND l.logical_round=(NEW.round_no+1)/2 AND NOT EXISTS(SELECT 1 FROM exam_regia_private.exchange_links later
    WHERE later.prova_id=l.prova_id AND later.logical_round>l.logical_round))
 THEN RAISE EXCEPTION 'exam_slot_capture_invalid' USING ERRCODE='23514'; END IF;
 SELECT ep.id INTO permit FROM exam_regia_private.execution_permits ep
 WHERE ep.prova_id=b.prova_id AND ep.actor_id=b.png_actor_id AND ep.principal_id=b.service_principal_id
  AND ep.operation='release_party' AND ep.request_key=e.id AND ep.transaction_id=txid_current()
  AND ep.backend_pid=pg_backend_pid() AND ep.consumed_at IS NULL AND ep.created_at>clock_timestamp()-interval '150 seconds' FOR UPDATE;
 IF permit IS NULL THEN RAISE EXCEPTION 'exam_slot_permit_required' USING ERRCODE='42501'; END IF;
 UPDATE exam_regia_private.execution_permits SET consumed_at=clock_timestamp() WHERE id=permit;
 RETURN NEW;
END $slot$;
CREATE TRIGGER exam_captured_slot_guard BEFORE INSERT OR UPDATE ON public.combat_v2_rounds
 FOR EACH ROW EXECUTE FUNCTION exam_regia_private.captured_slot_guard();
CREATE FUNCTION exam_regia_private.release_party_slot(p_prova uuid,p_round uuid,p_receipt uuid) RETURNS void
LANGUAGE plpgsql SECURITY DEFINER SET search_path='' AS $slot$
DECLARE b exam_regia_private.bindings%ROWTYPE;c mission_exchange_v3.cycles%ROWTYPE;r public.combat_v2_rounds%ROWTYPE;
BEGIN
 IF auth.uid() IS NOT NULL OR NOT public.combat_v2_is_service() THEN RAISE EXCEPTION 'exam_slot_service_only' USING ERRCODE='42501'; END IF;
 SELECT * INTO STRICT b FROM exam_regia_private.bindings WHERE prova_id=p_prova AND state='active' FOR UPDATE;
 SELECT cy.* INTO STRICT c FROM mission_exchange_v3.cycles cy JOIN mission_exchange_v3.receipts e ON e.cycle_id=cy.id
 WHERE e.id=p_receipt AND e.ordinal=1 AND e.combat_round_id=p_round AND cy.combat_session_id=b.combat_session_id FOR UPDATE OF cy;
 SELECT * INTO STRICT r FROM public.combat_v2_rounds WHERE id=p_round AND session_id=b.combat_session_id FOR UPDATE;
 IF r.exam_captured_receipt_id=p_receipt THEN RETURN; END IF;
 IF r.exam_captured_receipt_id IS NOT NULL THEN RAISE EXCEPTION 'exam_slot_receipt_conflict' USING ERRCODE='23505'; END IF;
 INSERT INTO exam_regia_private.execution_permits(prova_id,actor_id,principal_id,transaction_id,backend_pid,operation,request_key)
 VALUES(b.prova_id,b.png_actor_id,b.service_principal_id,txid_current(),pg_backend_pid(),'release_party',p_receipt);
 UPDATE public.combat_v2_rounds SET exam_captured_receipt_id=p_receipt WHERE id=p_round;
END $slot$;
DROP INDEX public.combat_v2_rounds_unico_attivo_idx;
CREATE UNIQUE INDEX combat_v2_rounds_unico_attivo_idx ON public.combat_v2_rounds(session_id)
 WHERE state<>'narrato' AND exam_captured_receipt_id IS NULL;
CREATE UNIQUE INDEX exam_captured_party_pending_idx ON public.combat_v2_rounds(session_id)
 WHERE state<>'narrato' AND exam_captured_receipt_id IS NOT NULL;


DO $secure$
DECLARE r record;
BEGIN
 ALTER SCHEMA exam_regia_private OWNER TO postgres;
 FOR r IN SELECT tablename FROM pg_tables WHERE schemaname='exam_regia_private' LOOP
  EXECUTE format('ALTER TABLE exam_regia_private.%I OWNER TO postgres',r.tablename);
  EXECUTE format('ALTER TABLE exam_regia_private.%I ENABLE ROW LEVEL SECURITY',r.tablename);
  EXECUTE format('REVOKE ALL ON TABLE exam_regia_private.%I FROM PUBLIC,anon,authenticated,service_role',r.tablename);
 END LOOP;
 FOR r IN SELECT p.oid::regprocedure sig FROM pg_proc p JOIN pg_namespace n ON n.oid=p.pronamespace WHERE n.nspname='exam_regia_private' LOOP
  EXECUTE format('ALTER FUNCTION %s OWNER TO postgres',r.sig);
  EXECUTE format('REVOKE ALL ON FUNCTION %s FROM PUBLIC,anon,authenticated,service_role',r.sig);
 END LOOP;
END $secure$;
GRANT EXECUTE ON FUNCTION exam_regia_private.is_private_template(uuid) TO authenticated;

DO $ports$
DECLARE r record;
BEGIN
 FOR r IN SELECT p.oid::regprocedure sig,p.proname FROM pg_proc p JOIN pg_namespace n ON n.oid=p.pronamespace
 WHERE n.nspname='public' AND p.proname=ANY(ARRAY['_esame_regia_deposit','esame_regia_ai_commit','esame_regia_ai_options','esame_regia_authorize','esame_regia_close','esame_regia_exit','esame_regia_open','esame_regia_panel_commit','esame_regia_panel_options','esame_regia_panel_state','esame_regia_publish','esame_regia_readiness','esame_regia_state']::text[]) LOOP
  EXECUTE format('ALTER FUNCTION %s OWNER TO postgres',r.sig);
  EXECUTE format('REVOKE ALL ON FUNCTION %s FROM PUBLIC,anon,authenticated,service_role',r.sig);
  EXECUTE format('GRANT EXECUTE ON FUNCTION %s TO %I',r.sig,CASE WHEN r.proname=ANY(ARRAY['_esame_regia_deposit','esame_regia_ai_commit','esame_regia_ai_options']::text[]) THEN 'service_role' ELSE 'authenticated' END);
 END LOOP;
END $ports$;
COMMIT;
