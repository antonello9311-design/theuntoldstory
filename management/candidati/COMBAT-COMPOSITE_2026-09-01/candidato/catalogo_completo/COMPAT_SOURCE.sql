BEGIN;
SELECT set_config('app.fix_eligibility_parameters',$fix_capsule${
  "schema_version": "fix-eligibility-parameters/1",
  "source_bundle_sha256": "654f8fff2f42019ffc4b3ccc6c467fff443ba81f00c7aa020fbd6d7950e2445e",
  "baseline_custody": {
    "ref": "compat_root.baseline.json#canonical_preimage/rawUTF8",
    "sha256": "f460be0a321e1640d7993a15285cf1b6352166cda41e991f0c644f29bd6a3658"
  },
  "compatibility": {
    "ref": "fix_eligibility.proposal.md#Root e recovery integrate",
    "sha256": "276209f1a4a5161f0bbcfea62aabada9a55e195b9d66e6a680ad84bc86c9169f",
    "scope": "existing_mission_capabilities_only",
    "new_techniques_staff_pass": false
  },
  "expected_content_admission_rows_sha256": "a7fb19e1b113f473ba00b2e645b5371a0e3021bed4058f419290581decaf5fff",
  "review": {
    "ref": "management/candidati/COMBAT-COMPOSITE_2026-09-01/candidato/catalogo_completo/COMPAT_REVIEW.json#R1",
    "sha256": "98dbb1734600c4a14ea7b437ab9d0703ec7963800b1a5e4b6f4077cc47c8db31",
    "P0": 0,
    "P1": 0,
    "P2": 0
  }
}$fix_capsule$,true);
-- SOURCE ONLY: guard+helper and the new forward Root footer MUST share one transaction.
-- Do not execute this fragment without that reviewed footer: helper otherwise returns legacy/fails closed.
DO $compat_preflight$
BEGIN
 IF current_user<>'postgres'OR session_user<>'postgres'OR auth.uid()IS NOT NULL THEN RAISE EXCEPTION 'eligibility_compat_operator';END IF;
 IF md5((SELECT prosrc FROM pg_proc WHERE oid='clan_innata_private.eligibility_release_assert()'::regprocedure))<>'aa255a3bf133ec952d75fbfa6ac01c3e'
 OR to_regprocedure('clan_innata_private.catalogo_eligibility_release_v1()')IS NOT NULL THEN RAISE EXCEPTION 'eligibility_compat_baseline_drift';END IF;
 IF EXISTS(SELECT 1 FROM public.combat_v2_sessions WHERE state='in_corso'AND closed_at IS NULL)
 OR EXISTS(SELECT 1 FROM public.master_v2_sessions WHERE stato NOT IN('chiusa','annullata')AND closed_at IS NULL)
 THEN RAISE EXCEPTION 'eligibility_compat_requires_native_quiescence';END IF;
END $compat_preflight$;
CREATE FUNCTION clan_innata_private.catalogo_eligibility_release_v1()
RETURNS boolean LANGUAGE plpgsql STABLE SECURITY DEFINER SET search_path='' AS $compat$
DECLARE
 rr mission_factory_owner.editor_release_readiness%ROWTYPE;root jsonb;binding jsonb;
 params constant jsonb:=$compat_metadata${"expected_alias_count":7,"shared_functions":[{"oid":"42942","signature":"combat_consumer_private.narrative_context(uuid)","source_md5":"bb4d81831292676d2e50e16d14f3192c","ddl_md5":"b94718dd0bd16443163b82057d27da82","abi":{"acl":"{postgres=X/postgres}","oid":"42942","kind":"f","owner":"postgres","config":["search_path=\"\""],"secdef":true,"strict":false,"nspname":"combat_consumer_private","proname":"narrative_context","returns":"jsonb","language":"plpgsql","parallel":"u","arg_modes":null,"arg_names":["p_round"],"arg_types":"2950","leakproof":false,"signature":"combat_consumer_private.narrative_context(uuid)","volatility":"s"}},{"oid":"46723","signature":"combat_consumer_private.narrative_declaration_supported(uuid)","source_md5":"b2d2c4047c4f63cb104effede756b4b8","ddl_md5":"7e8aa5b6991c26251bcc1ca3dcc834ca","abi":{"acl":"{postgres=X/postgres}","oid":"46723","kind":"f","owner":"postgres","config":["search_path=\"\""],"secdef":true,"strict":false,"nspname":"combat_consumer_private","proname":"narrative_declaration_supported","returns":"boolean","language":"plpgsql","parallel":"u","arg_modes":null,"arg_names":["p_declaration"],"arg_types":"2950","leakproof":false,"signature":"combat_consumer_private.narrative_declaration_supported(uuid)","volatility":"s"}},{"oid":"42968","signature":"combat_consumer_private.validate_narrative_result(jsonb)","source_md5":"a1ce0576cc6ca82207301ae0bbc21904","ddl_md5":"0cfd40e8d0b43add0d4cc25e6c8767b7","abi":{"acl":"{postgres=X/postgres}","oid":"42968","kind":"f","owner":"postgres","config":["search_path=\"\""],"secdef":false,"strict":false,"nspname":"combat_consumer_private","proname":"validate_narrative_result","returns":"void","language":"plpgsql","parallel":"u","arg_modes":null,"arg_names":["p"],"arg_types":"3802","leakproof":false,"signature":"combat_consumer_private.validate_narrative_result(jsonb)","volatility":"i"}},{"oid":"52137","signature":"combat_effects_private.lifecycle_before_report(uuid)","source_md5":"bc4009af6a274d51e6b96fc51f7a7a78","ddl_md5":"ee929b8e4bb4efcd584e7755aa5df682","abi":{"acl":"{postgres=X/postgres}","oid":"52137","kind":"f","owner":"postgres","config":["search_path=\"\""],"secdef":true,"strict":false,"nspname":"combat_effects_private","proname":"lifecycle_before_report","returns":"jsonb","language":"plpgsql","parallel":"u","arg_modes":null,"arg_names":["p_round"],"arg_types":"2950","leakproof":false,"signature":"combat_effects_private.lifecycle_before_report(uuid)","volatility":"v"}},{"oid":"52136","signature":"combat_effects_private.lifecycle_main_end(uuid)","source_md5":"a1948e8ce4fc505fc23e4e4089958507","ddl_md5":"0b743c53cb23a3402542468dc3096430","abi":{"acl":"{postgres=X/postgres}","oid":"52136","kind":"f","owner":"postgres","config":["search_path=\"\""],"secdef":true,"strict":false,"nspname":"combat_effects_private","proname":"lifecycle_main_end","returns":"jsonb","language":"plpgsql","parallel":"u","arg_modes":null,"arg_names":["p_declaration"],"arg_types":"2950","leakproof":false,"signature":"combat_effects_private.lifecycle_main_end(uuid)","volatility":"v"}},{"oid":"52133","signature":"combat_effects_private.lifecycle_open(uuid,uuid)","source_md5":"f94e3ef794064277d596354feba2cd50","ddl_md5":"9a45b13e8d31dd58447d212b28031fe0","abi":{"acl":"{postgres=X/postgres}","oid":"52133","kind":"f","owner":"postgres","config":["search_path=\"\""],"secdef":true,"strict":false,"nspname":"combat_effects_private","proname":"lifecycle_open","returns":"void","language":"plpgsql","parallel":"u","arg_modes":null,"arg_names":["p_session","p_actor"],"arg_types":"2950 2950","leakproof":false,"signature":"combat_effects_private.lifecycle_open(uuid,uuid)","volatility":"v"}},{"oid":"51910","signature":"combat_effects_private.personal_turn_end(uuid,uuid,uuid,text)","source_md5":"125e376708eaccc758e7887a9bcef705","ddl_md5":"53f87f6235e1f557317df936effbcd74","abi":{"acl":"{postgres=X/postgres}","oid":"51910","kind":"f","owner":"postgres","config":["search_path=\"\""],"secdef":true,"strict":false,"nspname":"combat_effects_private","proname":"personal_turn_end","returns":"jsonb","language":"plpgsql","parallel":"u","arg_modes":null,"arg_names":["p_session","p_actor","p_turn","p_adapter"],"arg_types":"2950 2950 2950 25","leakproof":false,"signature":"combat_effects_private.personal_turn_end(uuid,uuid,uuid,text)","volatility":"v"}},{"oid":"51906","signature":"combat_effects_private.personal_turn_start(uuid,uuid,uuid,text)","source_md5":"e7ec43224a4640d00c53bad72ac0132d","ddl_md5":"d023d8a651a5e8ef8fdb1cc834b93391","abi":{"acl":"{postgres=X/postgres}","oid":"51906","kind":"f","owner":"postgres","config":["search_path=\"\""],"secdef":true,"strict":false,"nspname":"combat_effects_private","proname":"personal_turn_start","returns":"void","language":"plpgsql","parallel":"u","arg_modes":null,"arg_names":["p_session","p_actor","p_turn","p_adapter"],"arg_types":"2950 2950 2950 25","leakproof":false,"signature":"combat_effects_private.personal_turn_start(uuid,uuid,uuid,text)","volatility":"v"}},{"oid":"44942","signature":"combat_panel_private.commit_master_actor(jsonb)","source_md5":"0c39121bcbd32a49608e4d925560ba41","ddl_md5":"b531bb7f50d4346a09e822b2f2e95144","abi":{"acl":"{postgres=X/postgres}","oid":"44942","kind":"f","owner":"postgres","config":["search_path=\"\""],"secdef":true,"strict":false,"nspname":"combat_panel_private","proname":"commit_master_actor","returns":"jsonb","language":"plpgsql","parallel":"u","arg_modes":null,"arg_names":["p_command"],"arg_types":"3802","leakproof":false,"signature":"combat_panel_private.commit_master_actor(jsonb)","volatility":"v"}},{"oid":"45916","signature":"combat_panel_private.immobilization_actor_lifecycle()","source_md5":"5244a1f635ad7d7336d24140d288b82a","ddl_md5":"f8677e282d09ca9015c01de07391f1bc","abi":{"acl":"{postgres=X/postgres}","oid":"45916","kind":"f","owner":"postgres","config":["search_path=\"\""],"secdef":true,"strict":false,"nspname":"combat_panel_private","proname":"immobilization_actor_lifecycle","returns":"trigger","language":"plpgsql","parallel":"u","arg_modes":null,"arg_names":null,"arg_types":"","leakproof":false,"signature":"combat_panel_private.immobilization_actor_lifecycle()","volatility":"v"}},{"oid":"45918","signature":"combat_panel_private.immobilization_session_lifecycle()","source_md5":"a4671931aa6e908a94af2ad2d788d933","ddl_md5":"38bc9bc060bc1af88cf087f5e4a687bb","abi":{"acl":"{postgres=X/postgres}","oid":"45918","kind":"f","owner":"postgres","config":["search_path=\"\""],"secdef":true,"strict":false,"nspname":"combat_panel_private","proname":"immobilization_session_lifecycle","returns":"trigger","language":"plpgsql","parallel":"u","arg_modes":null,"arg_names":null,"arg_types":"","leakproof":false,"signature":"combat_panel_private.immobilization_session_lifecycle()","volatility":"v"}},{"oid":"44940","signature":"combat_panel_private.master_options(uuid,uuid,bigint)","source_md5":"84c29f6a84fbe579caf5bb3fec7a2382","ddl_md5":"c11111f77595c311b997d46a98eb30fa","abi":{"acl":"{postgres=X/postgres}","oid":"44940","kind":"f","owner":"postgres","config":["search_path=\"\""],"secdef":true,"strict":false,"nspname":"combat_panel_private","proname":"master_options","returns":"jsonb","language":"plpgsql","parallel":"u","arg_modes":null,"arg_names":["p_location","p_actor","p_expected"],"arg_types":"2950 2950 20","leakproof":false,"signature":"combat_panel_private.master_options(uuid,uuid,bigint)","volatility":"v"}},{"oid":"45000","signature":"combat_panel_private.movement_block_reason(uuid)","source_md5":"9cd995d873f2ae85f3cac5c0d7ff21ad","ddl_md5":"4830deea719904406d11aa4b05cfd764","abi":{"acl":"{postgres=X/postgres}","oid":"45000","kind":"f","owner":"postgres","config":["search_path=\"\""],"secdef":true,"strict":false,"nspname":"combat_panel_private","proname":"movement_block_reason","returns":"text","language":"plpgsql","parallel":"u","arg_modes":null,"arg_names":["p_body"],"arg_types":"2950","leakproof":false,"signature":"combat_panel_private.movement_block_reason(uuid)","volatility":"s"}},{"oid":"46019","signature":"combat_panel_private.narrative_declaration_facts(uuid)","source_md5":"f4639eff179e6fdf1f998c0656ada09d","ddl_md5":"40d6973235b85e949ebbdd6ff06790eb","abi":{"acl":"{postgres=X/postgres}","oid":"46019","kind":"f","owner":"postgres","config":["search_path=\"\""],"secdef":true,"strict":false,"nspname":"combat_panel_private","proname":"narrative_declaration_facts","returns":"jsonb","language":"plpgsql","parallel":"u","arg_modes":null,"arg_names":["p_declaration"],"arg_types":"2950","leakproof":false,"signature":"combat_panel_private.narrative_declaration_facts(uuid)","volatility":"s"}},{"oid":"46020","signature":"combat_panel_private.narrative_ordinary_context(uuid)","source_md5":"37d04042d9ee9cfec4ac237c7d9a5f37","ddl_md5":"c6eacfaec260f73134ad6f066021b4e2","abi":{"acl":"{postgres=X/postgres}","oid":"46020","kind":"f","owner":"postgres","config":["search_path=\"\""],"secdef":true,"strict":false,"nspname":"combat_panel_private","proname":"narrative_ordinary_context","returns":"jsonb","language":"plpgsql","parallel":"u","arg_modes":null,"arg_names":["p_round"],"arg_types":"2950","leakproof":false,"signature":"combat_panel_private.narrative_ordinary_context(uuid)","volatility":"s"}},{"oid":"46018","signature":"combat_panel_private.narrative_outcome_facts(jsonb)","source_md5":"988cc3b61d0ebf41effda90d32e173b5","ddl_md5":"a4d973f30fbd64ace5540ea3438c8e26","abi":{"acl":"{postgres=X/postgres}","oid":"46018","kind":"f","owner":"postgres","config":["search_path=\"\""],"secdef":false,"strict":false,"nspname":"combat_panel_private","proname":"narrative_outcome_facts","returns":"jsonb","language":"plpgsql","parallel":"u","arg_modes":null,"arg_names":["p_outcome"],"arg_types":"3802","leakproof":false,"signature":"combat_panel_private.narrative_outcome_facts(jsonb)","volatility":"s"}},{"oid":"44669","signature":"combat_panel_private.ordinary_options(uuid,uuid,bigint)","source_md5":"4337c8fe49127d7d72edc0789fc0352b","ddl_md5":"c88bca3336e5a3e37cd81b4693b373b4","abi":{"acl":"{postgres=X/postgres}","oid":"44669","kind":"f","owner":"postgres","config":["search_path=\"\""],"secdef":true,"strict":false,"nspname":"combat_panel_private","proname":"ordinary_options","returns":"jsonb","language":"plpgsql","parallel":"u","arg_modes":null,"arg_names":["p_location","p_actor","p_expected"],"arg_types":"2950 2950 20","leakproof":false,"signature":"combat_panel_private.ordinary_options(uuid,uuid,bigint)","volatility":"v"}},{"oid":"44955","signature":"combat_panel_private.round_details_from_source(jsonb,jsonb,jsonb)","source_md5":"23722822d09c8d2a12a5121d04c141a6","ddl_md5":"883d64a10bb28250187b01e96e2dcf5e","abi":{"acl":"{postgres=X/postgres}","oid":"44955","kind":"f","owner":"postgres","config":["search_path=\"\""],"secdef":false,"strict":false,"nspname":"combat_panel_private","proname":"round_details_from_source","returns":"jsonb","language":"plpgsql","parallel":"u","arg_modes":null,"arg_names":["p_source","p_roster","p_offers"],"arg_types":"3802 3802 3802","leakproof":false,"signature":"combat_panel_private.round_details_from_source(jsonb,jsonb,jsonb)","volatility":"i"}},{"oid":"46316","signature":"combat_panel_private.round_options_authoritative(uuid,uuid)","source_md5":"4def81b4f389a7ddb85703d582e8b404","ddl_md5":"b185a37e712f6c7b789bb844608b576c","abi":{"acl":"{postgres=X/postgres}","oid":"46316","kind":"f","owner":"postgres","config":["search_path=\"\""],"secdef":true,"strict":false,"nspname":"combat_panel_private","proname":"round_options_authoritative","returns":"jsonb","language":"plpgsql","parallel":"u","arg_modes":null,"arg_names":["p_round","p_actor"],"arg_types":"2950 2950","leakproof":false,"signature":"combat_panel_private.round_options_authoritative(uuid,uuid)","volatility":"v"}},{"oid":"61967","signature":"combat_v2_elemental_internal.other_consumer_options(jsonb)","source_md5":"8423c49ce8a83f2b19361b82a53fa9f4","ddl_md5":"0d57fa274c2b6b63dc5ed1ef0a7c8ca9","abi":{"acl":"{postgres=X/postgres}","oid":"61967","kind":"f","owner":"postgres","config":["search_path=\"\""],"secdef":true,"strict":false,"nspname":"combat_v2_elemental_internal","proname":"other_consumer_options","returns":"jsonb","language":"plpgsql","parallel":"u","arg_modes":null,"arg_names":["p"],"arg_types":"3802","leakproof":false,"signature":"combat_v2_elemental_internal.other_consumer_options(jsonb)","volatility":"v"}},{"oid":"61972","signature":"combat_v2_elemental_internal.other_control_apply(text,uuid,uuid,uuid)","source_md5":"4cf97ca72ff52f1bd33445ba54c8dd16","ddl_md5":"9066a8a35e086727ed0240ea05fce684","abi":{"acl":"{postgres=X/postgres}","oid":"61972","kind":"f","owner":"postgres","config":["search_path=\"\""],"secdef":true,"strict":false,"nspname":"combat_v2_elemental_internal","proname":"other_control_apply","returns":"jsonb","language":"plpgsql","parallel":"u","arg_modes":null,"arg_names":["p_adapter","p_offer","p_actor","p_request"],"arg_types":"25 2950 2950 2950","leakproof":false,"signature":"combat_v2_elemental_internal.other_control_apply(text,uuid,uuid,uuid)","volatility":"v"}},{"oid":"61971","signature":"combat_v2_elemental_internal.other_control_target(text,uuid,uuid)","source_md5":"b1af00f3eab38ed9e74836c5441616d7","ddl_md5":"03724449dfc52ef8fcf4f89ae6eabb34","abi":{"acl":"{postgres=X/postgres}","oid":"61971","kind":"f","owner":"postgres","config":["search_path=\"\""],"secdef":true,"strict":false,"nspname":"combat_v2_elemental_internal","proname":"other_control_target","returns":"uuid","language":"plpgsql","parallel":"u","arg_modes":null,"arg_names":["p_adapter","p_offer","p_actor"],"arg_types":"25 2950 2950","leakproof":false,"signature":"combat_v2_elemental_internal.other_control_target(text,uuid,uuid)","volatility":"v"}},{"oid":"61970","signature":"combat_v2_elemental_internal.other_master_options(uuid,bigint)","source_md5":"0c79a6a78b76b9e9ef8028d75e514af7","ddl_md5":"38e2e92e5566275950c270ef5a8fe3d6","abi":{"acl":"{postgres=X/postgres}","oid":"61970","kind":"f","owner":"postgres","config":["search_path=\"\""],"secdef":true,"strict":false,"nspname":"combat_v2_elemental_internal","proname":"other_master_options","returns":"void","language":"plpgsql","parallel":"u","arg_modes":null,"arg_names":["p_context","p_expected"],"arg_types":"2950 20","leakproof":false,"signature":"combat_v2_elemental_internal.other_master_options(uuid,bigint)","volatility":"v"}},{"oid":"61954","signature":"combat_v2_elemental_internal.other_prepare_native(uuid,uuid,uuid,jsonb,boolean,jsonb)","source_md5":"6e54b476b36ca716cf8c14f33ef9667e","ddl_md5":"98acc6f2f9fcb26b47f3e6e830763e42","abi":{"acl":"{postgres=X/postgres}","oid":"61954","kind":"f","owner":"postgres","config":["search_path=\"\""],"secdef":true,"strict":false,"nspname":"combat_v2_elemental_internal","proname":"other_prepare_native","returns":"jsonb","language":"plpgsql","parallel":"u","arg_modes":null,"arg_names":["p_round","p_actor","p_request","p_intent","p_push","p_native_ref"],"arg_types":"2950 2950 2950 3802 16 3802","leakproof":false,"signature":"combat_v2_elemental_internal.other_prepare_native(uuid,uuid,uuid,jsonb,boolean,jsonb)","volatility":"v"}},{"oid":"61950","signature":"combat_v2_elemental_internal.other_profile(uuid,uuid)","source_md5":"dd1e62e9052469fae4c98fed245c730a","ddl_md5":"0959ae18dc9357f65d8d8169e39b0cb2","abi":{"acl":"{postgres=X/postgres}","oid":"61950","kind":"f","owner":"postgres","config":["search_path=\"\""],"secdef":true,"strict":false,"nspname":"combat_v2_elemental_internal","proname":"other_profile","returns":"jsonb","language":"plpgsql","parallel":"u","arg_modes":null,"arg_names":["p_actor","p_technique"],"arg_types":"2950 2950","leakproof":false,"signature":"combat_v2_elemental_internal.other_profile(uuid,uuid)","volatility":"s"}},{"oid":"39291","signature":"combat_v2_multitarget_internal.resolve_parent(uuid,uuid,uuid,boolean)","source_md5":"e9c7eb293c1791e36ba5fe70204af224","ddl_md5":"e494d3c9c4ee71bbdc81751c030ae3f7","abi":{"acl":"{postgres=X/postgres}","oid":"39291","kind":"f","owner":"postgres","config":["search_path=\"\""],"secdef":true,"strict":false,"nspname":"combat_v2_multitarget_internal","proname":"resolve_parent","returns":"jsonb","language":"plpgsql","parallel":"u","arg_modes":null,"arg_names":["p_session","p_round","p_attack","p_values"],"arg_types":"2950 2950 2950 16","leakproof":false,"signature":"combat_v2_multitarget_internal.resolve_parent(uuid,uuid,uuid,boolean)","volatility":"v"}},{"oid":"42947","signature":"public.combat_consumer_narrative_claim_v1(uuid,text,uuid)","source_md5":"1b51f51abc7ee3201a994c520fbcc64c","ddl_md5":"63c1f412532da4ecfc6a82a5aca7bdfa","abi":{"acl":"{postgres=X/postgres,service_role=X/postgres}","oid":"42947","kind":"f","owner":"postgres","config":["search_path=\"\""],"secdef":true,"strict":false,"nspname":"public","proname":"combat_consumer_narrative_claim_v1","returns":"jsonb","language":"plpgsql","parallel":"u","arg_modes":null,"arg_names":["p_round","p_report_sha256","p_request_key"],"arg_types":"2950 25 2950","leakproof":false,"signature":"public.combat_consumer_narrative_claim_v1(uuid,text,uuid)","volatility":"v"}},{"oid":"42969","signature":"public.combat_consumer_narrative_complete_v1(uuid,jsonb,uuid)","source_md5":"2d60a9af131230e7f40ff99ed6456180","ddl_md5":"f9f6185f3de24ed7ae34aa2c0c5e7173","abi":{"acl":"{postgres=X/postgres,service_role=X/postgres}","oid":"42969","kind":"f","owner":"postgres","config":["search_path=\"\""],"secdef":true,"strict":false,"nspname":"public","proname":"combat_consumer_narrative_complete_v1","returns":"jsonb","language":"plpgsql","parallel":"u","arg_modes":null,"arg_names":["p_claim","p_result","p_request_key"],"arg_types":"2950 3802 2950","leakproof":false,"signature":"public.combat_consumer_narrative_complete_v1(uuid,jsonb,uuid)","volatility":"v"}},{"oid":"44808","signature":"public.combat_panel_commit_v1(jsonb)","source_md5":"ce0c32cce5f6da141e20c015aba9e880","ddl_md5":"7c285429ea93b118c2d390e5a62cbe90","abi":{"acl":"{postgres=X/postgres,authenticated=X/postgres}","oid":"44808","kind":"f","owner":"postgres","config":["search_path=\"\""],"secdef":true,"strict":false,"nspname":"public","proname":"combat_panel_commit_v1","returns":"jsonb","language":"plpgsql","parallel":"u","arg_modes":null,"arg_names":["p_command"],"arg_types":"3802","leakproof":false,"signature":"public.combat_panel_commit_v1(jsonb)","volatility":"v"}},{"oid":"31324","signature":"public.combat_v2_action_declare(uuid,uuid,jsonb,text,uuid)","source_md5":"56a48200d4a15178b63e52445cb42ba7","ddl_md5":"6fdd865937ad47382b686820332e78b6","abi":{"acl":"{postgres=X/postgres,authenticated=X/postgres,service_role=X/postgres}","oid":"31324","kind":"f","owner":"postgres","config":["search_path=\"\""],"secdef":true,"strict":false,"nspname":"public","proname":"combat_v2_action_declare","returns":"jsonb","language":"plpgsql","parallel":"u","arg_modes":null,"arg_names":["p_round","p_actor","p_intent","p_text","p_request_key"],"arg_types":"2950 2950 3802 25 2950","leakproof":false,"signature":"public.combat_v2_action_declare(uuid,uuid,jsonb,text,uuid)","volatility":"v"}},{"oid":"31311","signature":"public.combat_v2_actor_ability(uuid,text,uuid,boolean)","source_md5":"6bc1065e07011266fead520f4b7d3b47","ddl_md5":"12183e1b698dbbbf8b904c6a24d89a51","abi":{"acl":"{postgres=X/postgres,service_role=X/postgres}","oid":"31311","kind":"f","owner":"postgres","config":["search_path=\"\""],"secdef":true,"strict":false,"nspname":"public","proname":"combat_v2_actor_ability","returns":"jsonb","language":"sql","parallel":"u","arg_modes":null,"arg_names":["p_actor","p_source","p_ability","p_defense"],"arg_types":"2950 25 2950 16","leakproof":false,"signature":"public.combat_v2_actor_ability(uuid,text,uuid,boolean)","volatility":"s"}},{"oid":"31326","signature":"public.combat_v2_defense_declare(uuid,uuid,uuid,jsonb,text,uuid)","source_md5":"7e947fd7937ec49f19101a58d95432d8","ddl_md5":"568d4c124fee6d53dedd1d6e9eb6e9bd","abi":{"acl":"{postgres=X/postgres,authenticated=X/postgres,service_role=X/postgres}","oid":"31326","kind":"f","owner":"postgres","config":["search_path=\"\""],"secdef":true,"strict":false,"nspname":"public","proname":"combat_v2_defense_declare","returns":"jsonb","language":"plpgsql","parallel":"u","arg_modes":null,"arg_names":["p_round","p_attack_declaration","p_actor","p_intent","p_text","p_request_key"],"arg_types":"2950 2950 2950 3802 25 2950","leakproof":false,"signature":"public.combat_v2_defense_declare(uuid,uuid,uuid,jsonb,text,uuid)","volatility":"v"}},{"oid":"31331","signature":"public.combat_v2_round_resolve(uuid,uuid)","source_md5":"954c762bcaf8a4638d51a9061a275f24","ddl_md5":"ab38f8891a4f0d663410276047ea254d","abi":{"acl":"{postgres=X/postgres,service_role=X/postgres,authenticated=X/postgres}","oid":"31331","kind":"f","owner":"postgres","config":["search_path=\"\""],"secdef":true,"strict":false,"nspname":"public","proname":"combat_v2_round_resolve","returns":"jsonb","language":"plpgsql","parallel":"u","arg_modes":null,"arg_names":["p_round","p_request_key"],"arg_types":"2950 2950","leakproof":false,"signature":"public.combat_v2_round_resolve(uuid,uuid)","volatility":"v"}},{"oid":"19700","signature":"public.post_heal(uuid,uuid)","source_md5":"dcde447ee079472efa4fd41c1c911633","ddl_md5":"9fb236d5f72312f6fb33587a2981e427","abi":{"acl":"{postgres=X/postgres,service_role=X/postgres,authenticated=X/postgres}","oid":"19700","kind":"f","owner":"postgres","config":["search_path=public"],"secdef":true,"strict":false,"nspname":"public","proname":"post_heal","returns":"text","language":"plpgsql","parallel":"u","arg_modes":null,"arg_names":["p_location","p_target_user"],"arg_types":"2950 2950","leakproof":false,"signature":"public.post_heal(uuid,uuid)","volatility":"v"}}],"private_functions":[{"signature":"combat_panel_private.catalog_lifecycle_lines_v1(jsonb,jsonb)","source_md5":"8a472424ef8d1bc4d04283d18a0d049e"},{"signature":"combat_panel_private.catalog_result_label_v1(jsonb)","source_md5":"acae3722db638c3e8449b39f627fcfca"},{"signature":"combat_panel_private.cure_bind_v1(uuid)","source_md5":"a9c1bde3a9b0de30c44312b12be60eff"},{"signature":"combat_panel_private.cure_commit_v1(jsonb)","source_md5":"5690d47226fc9ae7bd5aca96ced8d079"},{"signature":"combat_panel_private.cure_contact_v1(uuid,uuid)","source_md5":"878069c4d7dca1bc0ddade6b22f35c7d"},{"signature":"combat_panel_private.cure_declaration_meta_v1(uuid,uuid,uuid,jsonb)","source_md5":"9fdec7a42f67372bc1f2e2f408f16ba1"},{"signature":"combat_panel_private.cure_defense_guard_v1()","source_md5":"72b7362b50720f93672dfa1ab96338bc"},{"signature":"combat_panel_private.cure_frozen_turn_valid_v1(uuid,uuid)","source_md5":"7785ea336dd4a1deb9dd19487756d638"},{"signature":"combat_panel_private.cure_narrative_facts_v1(uuid)","source_md5":"a32f97cddb31ccf9581ba328f1e94e49"},{"signature":"combat_panel_private.cure_neutral_preset_v1(uuid,uuid,uuid,jsonb)","source_md5":"0ecd6867dd7f24deb4b58a76743517de"},{"signature":"combat_panel_private.cure_note_voluntary_v1(uuid,uuid,text,text)","source_md5":"669353b795c5f327bdcd338c9990716d"},{"signature":"combat_panel_private.cure_offers_v1(uuid,bigint,jsonb)","source_md5":"66a3d715a7ca7f77ef3f36cd121fd5ec"},{"signature":"combat_panel_private.cure_persistent_execution_scope_v1(uuid)","source_md5":"ea6a91fa5940c0d3680a36c4ee962880"},{"signature":"combat_panel_private.cure_persistent_scope_v1(uuid)","source_md5":"4fdb37eb54e15b3da2845a41809ccc57"},{"signature":"combat_panel_private.cure_prepare_v1(uuid,uuid,uuid,uuid)","source_md5":"bf7f19036a2846412374c68950126ac5"},{"signature":"combat_panel_private.cure_profile_v1(uuid)","source_md5":"88ec3750ea8aa0661eaa573747325e87"},{"signature":"combat_panel_private.cure_resolve_v1(uuid)","source_md5":"d385538828e19526af5e59dc8d18f167"},{"signature":"combat_panel_private.cure_staff_execution_scope_v1(uuid)","source_md5":"9adc4dfa74e700f54ba58d8691fb8f76"},{"signature":"combat_panel_private.cure_staff_scope_v1(uuid)","source_md5":"343140ae23ba4787fa511d1e6f27092e"},{"signature":"combat_panel_private.cure_turn_clear_v1(uuid,uuid)","source_md5":"ff5fac17361830d01e19aeba05430328"},{"signature":"combat_panel_private.cure_turn_used_v1(uuid,uuid)","source_md5":"11badbd523e79faba44fa282150be54b"},{"signature":"combat_panel_private.cure_voluntary_receipt_guard_v1()","source_md5":"08bacb86944bec00bc213eddf9815dca"},{"signature":"combat_v2_genjutsu_internal.actor_meta(uuid)","source_md5":"df3798ced5e32f7cb5aef4283fd88a00"},{"signature":"combat_v2_genjutsu_internal.ally_contact(uuid,uuid)","source_md5":"09fe1a174c9e813dcf541f1ad41a7016"},{"signature":"combat_v2_genjutsu_internal.bind_release(uuid)","source_md5":"1c6bfe3e32950c77afbb8c7b91a21078"},{"signature":"combat_v2_genjutsu_internal.bind_source(uuid)","source_md5":"80c79fc14b48e386b5920d021d537ba7"},{"signature":"combat_v2_genjutsu_internal.binding(uuid)","source_md5":"404fc795700a7fbe3334464c97a5058b"},{"signature":"combat_v2_genjutsu_internal.comparison(uuid,uuid,jsonb)","source_md5":"e63a4943d52d01b719d9693039c18d6c"},{"signature":"combat_v2_genjutsu_internal.consumer_options(jsonb)","source_md5":"c8daec5fcb19dc88267f7ceab87a2be8"},{"signature":"combat_v2_genjutsu_internal.declaration_events(uuid)","source_md5":"194b5c80d8e4779c66f0fdb8c50f1de3"},{"signature":"combat_v2_genjutsu_internal.declaration_meta(uuid,uuid,uuid,jsonb)","source_md5":"1dadbb12c0a1965b0461133ca0efc5d3"},{"signature":"combat_v2_genjutsu_internal.decorate_outcome(uuid,uuid,jsonb)","source_md5":"d0160238be06fafb4ce521553d4e745a"},{"signature":"combat_v2_genjutsu_internal.defense_intent_allowed(uuid,jsonb)","source_md5":"bf261ee2a0f55a52a8bb9462333058bd"},{"signature":"combat_v2_genjutsu_internal.end_context(uuid,uuid)","source_md5":"9d931f4ac19d9170e6119458d4825b23"},{"signature":"combat_v2_genjutsu_internal.event_binding(uuid,jsonb)","source_md5":"8b3b23a81afc7c2092902373cedbe0d2"},{"signature":"combat_v2_genjutsu_internal.event_public(text)","source_md5":"ecaea9744e8960072a32e7908856f9c0"},{"signature":"combat_v2_genjutsu_internal.kai_defense_valid(uuid,uuid)","source_md5":"1ab8564f473d8a008ba29e8095a4a6de"},{"signature":"combat_v2_genjutsu_internal.master_options(uuid,bigint)","source_md5":"0111ecc9e4034eb295e5a898cd4cd88e"},{"signature":"combat_v2_genjutsu_internal.movement_blocked(uuid)","source_md5":"8a243e907877525d58c71429cfbb8f98"},{"signature":"combat_v2_genjutsu_internal.narrative_facts(uuid)","source_md5":"de22bbd83e9ab8edb6a025e5131edde0"},{"signature":"combat_v2_genjutsu_internal.narrative_supported(uuid)","source_md5":"8c498c00f438621c617ae6132318ab66"},{"signature":"combat_v2_genjutsu_internal.open_turn(uuid,uuid)","source_md5":"701defaed0c81b0a6f4ccef2857a4a42"},{"signature":"combat_v2_genjutsu_internal.panel_options(uuid,bigint)","source_md5":"cb344a077d919955ef0f570ba9313d35"},{"signature":"combat_v2_genjutsu_internal.prepare(uuid,uuid,uuid,jsonb)","source_md5":"7275b845d7140c81fd2ec2ac48d3cd91"},{"signature":"combat_v2_genjutsu_internal.preset_ready(uuid)","source_md5":"b087938ff9bdc51ee5518c72beb88c04"},{"signature":"combat_v2_genjutsu_internal.profile()","source_md5":"87cf137eefa6f81cd178c039859c1c45"},{"signature":"combat_v2_genjutsu_internal.quote(uuid)","source_md5":"28ff62253407034032035e6acd8a2b6b"},{"signature":"combat_v2_genjutsu_internal.raw_attack_facts(uuid)","source_md5":"da147cc5595cac875224cbbebfe82ef8"},{"signature":"combat_v2_genjutsu_internal.real_owned(uuid)","source_md5":"f6e8ecb85aeb3c938cdc71eb0cbf80cd"},{"signature":"combat_v2_genjutsu_internal.record_event(text,uuid,jsonb)","source_md5":"9ba46dc99acb5e3063e0d813b55d0f3f"},{"signature":"combat_v2_genjutsu_internal.release_intents(uuid)","source_md5":"e1ddaf358a32b03d0ae3aed3023d57a7"},{"signature":"combat_v2_genjutsu_internal.release_meta(uuid,uuid,uuid,jsonb)","source_md5":"1d0416d6f715524c8ac1374dbabae55d"},{"signature":"combat_v2_genjutsu_internal.report_facts(uuid)","source_md5":"03c90f3dd07812d1061c7037216304d9"},{"signature":"combat_v2_genjutsu_internal.report_projection(uuid)","source_md5":"d3c2e36c0248730650a6c6c4b34d1e47"},{"signature":"combat_v2_genjutsu_internal.resolution_enter(uuid,uuid)","source_md5":"c45574805f3171628ef99392fa255eb2"},{"signature":"combat_v2_genjutsu_internal.resolution_leave()","source_md5":"612f97c08785e572226423ed5c1f68ed"},{"signature":"combat_v2_genjutsu_internal.resolve_release(uuid)","source_md5":"cb9fcdd4ff035ca7938144412be57e2c"},{"signature":"combat_v2_genjutsu_internal.runtime_allowed(uuid)","source_md5":"8512b2d982094a3b339de4ec3bfd3327"},{"signature":"combat_v2_genjutsu_internal.scope(uuid)","source_md5":"17ac15ea8ea5a734ff4eb0cc9d6e7f34"},{"signature":"combat_v2_genjutsu_internal.source_valid(uuid)","source_md5":"84ca595cfd34b8467b69c0256e94e254"},{"signature":"combat_v2_genjutsu_internal.staff_bind(uuid,uuid)","source_md5":"b8b6261b5c8f7df3c91400d5969d8eae"},{"signature":"combat_v2_genjutsu_internal.success(jsonb,integer,boolean)","source_md5":"90faca8a42e9f7f54726276f5a1e94bf"},{"signature":"combat_v2_genjutsu_internal.turn_end(uuid,uuid,uuid,text)","source_md5":"5130f380992a3585b502934e2833e716"},{"signature":"combat_v2_genjutsu_internal.turn_start(uuid,uuid,uuid,text)","source_md5":"b1781f3637f8c3414a9dd2c4038869c2"},{"signature":"combat_v2_genjutsu_internal.validate_attack_facts(jsonb)","source_md5":"0c6434b64a325213dbf8d18c603ed061"},{"signature":"combat_v2_genjutsu_internal.validate_release_facts(jsonb)","source_md5":"a46a047fa733321603e24a6102d7183d"}],"relations":[{"name":"combat_panel_private.cure_gate_v1","columns":[{"name":"singleton","type":"boolean","not_null":true,"default":"true"},{"name":"staff_enabled","type":"boolean","not_null":true,"default":"false"},{"name":"public_enabled","type":"boolean","not_null":true,"default":"false"},{"name":"contract_version","type":"text","not_null":true,"default":"'palmo-curativo/1'::text"}]},{"name":"combat_panel_private.cure_ledger_v1","columns":[{"name":"declaration_id","type":"uuid","not_null":true,"default":null},{"name":"session_id","type":"uuid","not_null":true,"default":null},{"name":"round_id","type":"uuid","not_null":true,"default":null},{"name":"actor_id","type":"uuid","not_null":true,"default":null},{"name":"target_actor_id","type":"uuid","not_null":true,"default":null},{"name":"hp_before","type":"integer","not_null":true,"default":null},{"name":"hp_after","type":"integer","not_null":true,"default":null},{"name":"hp_max","type":"integer","not_null":true,"default":null},{"name":"expected_gain","type":"integer","not_null":true,"default":null},{"name":"committed_gain","type":"integer","not_null":true,"default":null},{"name":"applied_real_gain","type":"integer","not_null":true,"default":"0"},{"name":"is_simulated","type":"boolean","not_null":true,"default":null},{"name":"facts","type":"jsonb","not_null":true,"default":null},{"name":"created_at","type":"timestamp with time zone","not_null":true,"default":"clock_timestamp()"}]},{"name":"combat_panel_private.cure_preparations_v1","columns":[{"name":"request_key","type":"uuid","not_null":true,"default":null},{"name":"transaction_id","type":"bigint","not_null":true,"default":null},{"name":"session_id","type":"uuid","not_null":true,"default":null},{"name":"round_id","type":"uuid","not_null":true,"default":null},{"name":"actor_id","type":"uuid","not_null":true,"default":null},{"name":"target_actor_id","type":"uuid","not_null":true,"default":null},{"name":"controller_user","type":"uuid","not_null":true,"default":null},{"name":"controller_version","type":"bigint","not_null":true,"default":null},{"name":"source","type":"jsonb","not_null":true,"default":null},{"name":"source_sha256","type":"text","not_null":true,"default":null},{"name":"declaration_id","type":"uuid","not_null":false,"default":null},{"name":"created_at","type":"timestamp with time zone","not_null":true,"default":"clock_timestamp()"}]},{"name":"combat_panel_private.cure_staff_profiles_v1","columns":[{"name":"actor_id","type":"uuid","not_null":true,"default":null},{"name":"session_id","type":"uuid","not_null":true,"default":null},{"name":"context_id","type":"uuid","not_null":true,"default":null},{"name":"controller_user","type":"uuid","not_null":true,"default":null},{"name":"controller_version","type":"bigint","not_null":true,"default":null},{"name":"ability","type":"jsonb","not_null":true,"default":null},{"name":"proof_sha256","type":"text","not_null":true,"default":null},{"name":"request_key","type":"uuid","not_null":true,"default":null},{"name":"created_at","type":"timestamp with time zone","not_null":true,"default":"clock_timestamp()"}]},{"name":"combat_panel_private.cure_voluntary_actions_v1","columns":[{"name":"actor_id","type":"uuid","not_null":true,"default":null},{"name":"round_id","type":"uuid","not_null":true,"default":null},{"name":"source_kind","type":"text","not_null":true,"default":null},{"name":"source_key","type":"text","not_null":true,"default":null},{"name":"created_at","type":"timestamp with time zone","not_null":true,"default":"clock_timestamp()"}]},{"name":"combat_v2_genjutsu_internal.effects","columns":[{"name":"id","type":"uuid","not_null":true,"default":"gen_random_uuid()"},{"name":"session_id","type":"uuid","not_null":true,"default":null},{"name":"source_declaration_id","type":"uuid","not_null":true,"default":null},{"name":"source_attack_target_id","type":"uuid","not_null":true,"default":null},{"name":"source_actor_id","type":"uuid","not_null":true,"default":null},{"name":"target_actor_id","type":"uuid","not_null":true,"default":null},{"name":"profile","type":"jsonb","not_null":true,"default":null},{"name":"source_outcome_sha256","type":"text","not_null":true,"default":null},{"name":"adapter","type":"text","not_null":true,"default":null},{"name":"excluded_turn_id","type":"uuid","not_null":false,"default":null},{"name":"due_turn_id","type":"uuid","not_null":false,"default":null},{"name":"state","type":"text","not_null":true,"default":null},{"name":"state_version","type":"bigint","not_null":true,"default":"1"},{"name":"created_at","type":"timestamp with time zone","not_null":true,"default":"clock_timestamp()"},{"name":"ended_at","type":"timestamp with time zone","not_null":false,"default":null},{"name":"end_reason","type":"text","not_null":false,"default":null}]},{"name":"combat_v2_genjutsu_internal.events","columns":[{"name":"event_key","type":"text","not_null":true,"default":null},{"name":"effect_id","type":"uuid","not_null":false,"default":null},{"name":"result","type":"jsonb","not_null":true,"default":null},{"name":"result_sha256","type":"text","not_null":true,"default":null},{"name":"binding","type":"jsonb","not_null":true,"default":null},{"name":"binding_sha256","type":"text","not_null":true,"default":null},{"name":"created_at","type":"timestamp with time zone","not_null":true,"default":"clock_timestamp()"}]},{"name":"combat_v2_genjutsu_internal.gate","columns":[{"name":"singleton","type":"boolean","not_null":true,"default":null},{"name":"enabled","type":"boolean","not_null":true,"default":null},{"name":"staff_enabled","type":"boolean","not_null":true,"default":null},{"name":"public_enabled","type":"boolean","not_null":true,"default":null},{"name":"version","type":"integer","not_null":true,"default":null}]},{"name":"combat_v2_genjutsu_internal.preparations","columns":[{"name":"actor_id","type":"uuid","not_null":true,"default":null},{"name":"round_id","type":"uuid","not_null":true,"default":null},{"name":"request_id","type":"uuid","not_null":true,"default":null},{"name":"transaction_id","type":"bigint","not_null":true,"default":null},{"name":"source","type":"jsonb","not_null":true,"default":null},{"name":"source_sha256","type":"text","not_null":true,"default":null}]},{"name":"combat_v2_genjutsu_internal.release_plans","columns":[{"name":"actor_id","type":"uuid","not_null":true,"default":null},{"name":"round_id","type":"uuid","not_null":true,"default":null},{"name":"request_id","type":"uuid","not_null":true,"default":null},{"name":"effect_id","type":"uuid","not_null":true,"default":null},{"name":"source","type":"jsonb","not_null":true,"default":null},{"name":"source_sha256","type":"text","not_null":true,"default":null},{"name":"transaction_id","type":"bigint","not_null":true,"default":null},{"name":"declaration_id","type":"uuid","not_null":false,"default":null},{"name":"declaration_sha256","type":"text","not_null":false,"default":null},{"name":"result","type":"jsonb","not_null":false,"default":null},{"name":"result_sha256","type":"text","not_null":false,"default":null}]},{"name":"combat_v2_genjutsu_internal.sources","columns":[{"name":"declaration_id","type":"uuid","not_null":true,"default":null},{"name":"session_id","type":"uuid","not_null":true,"default":null},{"name":"source","type":"jsonb","not_null":true,"default":null},{"name":"declaration_sha256","type":"text","not_null":true,"default":null},{"name":"source_sha256","type":"text","not_null":true,"default":null}]},{"name":"combat_v2_genjutsu_internal.staff_receipts","columns":[{"name":"actor_id","type":"uuid","not_null":true,"default":null},{"name":"session_id","type":"uuid","not_null":true,"default":null},{"name":"controller_user","type":"uuid","not_null":true,"default":null},{"name":"controller_version","type":"bigint","not_null":true,"default":null},{"name":"request_id","type":"uuid","not_null":true,"default":null},{"name":"receipt","type":"jsonb","not_null":true,"default":null},{"name":"receipt_sha256","type":"text","not_null":true,"default":null}]}],"triggers":[{"table":"clan_akimichi_private.form_commands","name":"cure_voluntary_receipt_v1","function":"combat_panel_private.cure_voluntary_receipt_guard_v1()","type":7},{"table":"clan_hoki_private.combat_events","name":"cure_voluntary_receipt_v1","function":"combat_panel_private.cure_voluntary_receipt_guard_v1()","type":7},{"table":"clan_innata_combat_private.combat_receipts","name":"cure_voluntary_receipt_v1","function":"combat_panel_private.cure_voluntary_receipt_guard_v1()","type":7},{"table":"clan_inuzuka_private.movement_receipts","name":"cure_voluntary_receipt_v1","function":"combat_panel_private.cure_voluntary_receipt_guard_v1()","type":7},{"table":"clan_marionettisti_private.control_events","name":"cure_voluntary_receipt_v1","function":"combat_panel_private.cure_voluntary_receipt_guard_v1()","type":7},{"table":"clan_marionettisti_private.movement_receipts","name":"cure_voluntary_receipt_v1","function":"combat_panel_private.cure_voluntary_receipt_guard_v1()","type":7},{"table":"clan_sabaku_private.armor_events","name":"cure_voluntary_receipt_v1","function":"combat_panel_private.cure_voluntary_receipt_guard_v1()","type":7},{"table":"combat_panel_private.master_movement_receipts","name":"cure_voluntary_receipt_v1","function":"combat_panel_private.cure_voluntary_receipt_guard_v1()","type":7},{"table":"combat_panel_private.request_receipts","name":"cure_voluntary_receipt_v1","function":"combat_panel_private.cure_voluntary_receipt_guard_v1()","type":7},{"table":"public.combat_v2_declarations","name":"cure_turn_defense_guard_v1","function":"combat_panel_private.cure_defense_guard_v1()","type":7}]}$compat_metadata$::jsonb;
 shared_manifest jsonb:='[]';private_manifest jsonb:='[]';relation_manifest jsonb:='[]';trigger_manifest jsonb:='[]';
 item jsonb;h jsonb;abi jsonb;cols jsonb;descriptor jsonb;next_descriptor jsonb;kv record;
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
 IF EXISTS(WITH expected(sig,sha,acl)AS(VALUES ('combat_panel_private.mask_native_state(jsonb)','1d2f6ad44b2ff1e9c15d897e38fee54b67c744411081f906bc33a26a42600dac','postgres:EXECUTE:false'),('combat_panel_private.round_options_authoritative(uuid,uuid)','624a967648709007df47703ef643166f641bc75bd412c475e277543ebba68d7e','postgres:EXECUTE:false'),('combat_v2_elemental_internal.eligible_v1(uuid,uuid,boolean)','a5161f2993a4e0ce51864ac67ea88ba3fa6966457da1caf4ca390f17c2b1d8e9','postgres:EXECUTE:false,service_role:EXECUTE:false'),('combat_v2_elemental_internal.is_target_v1(uuid)','8af6bdfc87b76ed118b596f7c7885c6de849c5d89140f61cdd1845047cbd5724','postgres:EXECUTE:false,service_role:EXECUTE:false'),('public.combat_v2_actor_ability(uuid,text,uuid,boolean)','3f86b9972ead72801b6a4c392d2b180d011ca2605075855cd21a59b848f665e4','postgres:EXECUTE:false,service_role:EXECUTE:false'),('public.combat_v2_character_snapshot(uuid)','20c680c16a5ba1adedada1b9dcb6b5ee2f91bf01ddbdd9c0d40064d9d2d57ee3','postgres:EXECUTE:false,service_role:EXECUTE:false'),('public.combat_v2_round_options(uuid,uuid)','0b3acc15933027fa840ca03c0d02f082aecf6f2ccedcdefd737127bed1d853d1','authenticated:EXECUTE:false,postgres:EXECUTE:false,service_role:EXECUTE:false'))SELECT 1 FROM expected e LEFT JOIN pg_proc p ON p.oid=to_regprocedure(e.sig)
 WHERE p.oid IS NULL OR encode(extensions.digest(convert_to(pg_get_functiondef(p.oid),'UTF8'),'sha256'),'hex')IS DISTINCT FROM e.sha
 OR p.proowner IS DISTINCT FROM 'postgres'::regrole OR p.prosecdef IS DISTINCT FROM true OR p.proconfig IS DISTINCT FROM ARRAY['search_path=""']
 OR(SELECT string_agg(coalesce(r.rolname,'PUBLIC')||':'||x.privilege_type||':'||x.is_grantable,','ORDER BY coalesce(r.rolname,'PUBLIC'),x.privilege_type,x.is_grantable)
 FROM aclexplode(coalesce(p.proacl,acldefault('f',p.proowner)))x LEFT JOIN pg_roles r ON r.oid=x.grantee)IS DISTINCT FROM e.acl)
 THEN RAISE EXCEPTION 'catalogo_eligibility_owning_port_drift';END IF;
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

 IF shared_sha IS DISTINCT FROM root#>>'{db_core,catalogo_completo,shared_manifest_sha256}'
 OR private_sha IS DISTINCT FROM root#>>'{db_core,catalogo_completo,private_functions_manifest_sha256}'
 OR relations_sha IS DISTINCT FROM root#>>'{db_core,catalogo_completo,relations_manifest_sha256}'
 OR shared_sha IS DISTINCT FROM binding->>'shared_manifest_sha256'
 OR private_sha IS DISTINCT FROM binding->>'private_functions_manifest_sha256'
 OR relations_sha IS DISTINCT FROM binding->>'relations_manifest_sha256'
 THEN RAISE EXCEPTION 'catalogo_eligibility_integrated_manifest_drift';END IF;
 RETURN true;
END $compat$;
REVOKE ALL ON FUNCTION clan_innata_private.catalogo_eligibility_release_v1() FROM PUBLIC,anon,authenticated,service_role;
GRANT EXECUTE ON FUNCTION clan_innata_private.catalogo_eligibility_release_v1() TO postgres;
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
   ('public.combat_v2_actor_ability(uuid,text,uuid,boolean)',CASE WHEN v_catalogo THEN '3f86b9972ead72801b6a4c392d2b180d011ca2605075855cd21a59b848f665e4' ELSE 'cb9e81c2b23aedb968eafa00f15dc3de188e57a5e72f04805a2d0617934575a7'END,'postgres:EXECUTE:false,service_role:EXECUTE:false'),
   ('public.combat_v2_round_options(uuid,uuid)',case when v_panel then '0b3acc15933027fa840ca03c0d02f082aecf6f2ccedcdefd737127bed1d853d1' when v_marionetta then '6b9012a057baa9bc06b201ce6bcc5b8d8bb4a832ae9a462444c5e3ef55e0c8cb' else '3be90b0da7f02c826ffdfcd594d2132a4af9128291e3417278ad6adac88f6129' end,'authenticated:EXECUTE:false,postgres:EXECUTE:false,service_role:EXECUTE:false')),
  observed as(select e.*,encode(extensions.digest(convert_to(pg_get_functiondef(e.sig::regprocedure),'UTF8'),'sha256'),'hex') actual_sha,p.proowner,p.prosecdef,p.proconfig,(select string_agg(coalesce(r.rolname,'PUBLIC')||':'||x.privilege_type||':'||x.is_grantable,',' order by coalesce(r.rolname,'PUBLIC'),x.privilege_type,x.is_grantable) from aclexplode(coalesce(p.proacl,acldefault('f',p.proowner))) x left join pg_roles r on r.oid=x.grantee) actual_acl from expected e join pg_proc p on p.oid=e.sig::regprocedure)
  select 1 from observed where actual_sha is distinct from sha or actual_acl is distinct from acl or proowner<>'postgres'::regrole or not prosecdef or proconfig is distinct from array['search_path=""'])
 then raise exception 'runtime_eligibility_full_seal_drift';end if;
 if encode(extensions.digest(convert_to(pg_get_functiondef('public.character_elementi(uuid)'::regprocedure),'UTF8'),'sha256'),'hex') is distinct from '2e62fad3aa654ab452c516549ca82068dd33f6496a3c1e17e3a8c805a8ddacd7'
 then raise exception 'runtime_eligibility_character_elementi_drift';end if;

 IF EXISTS(WITH expected(sig,hash,sd) AS (VALUES ('combat_v2_elemental_internal.other_meta(uuid)','18a6130387a81b22c993feaaf2613612',true),('combat_v2_elemental_internal.other_staff_binding(uuid,uuid)','cb15a27f82e60cf2ace2f22de4ca1e73',true),('combat_v2_elemental_internal.other_png_owned(uuid,uuid)','1730fa382f3f2da21b05ba43e1876330',true),('combat_v2_elemental_internal.other_profile(uuid,uuid)',CASE WHEN v_catalogo THEN 'dd1e62e9052469fae4c98fed245c730a' ELSE 'f71b7422e1af07cfb2784137d5d05f03'END,true),('combat_v2_elemental_internal.other_ability_meta(uuid,jsonb)','07a3babec6e05865d9265b09c22d0859',true),('combat_v2_elemental_internal.other_staff_bind(uuid,uuid,uuid)','a4fb778f33ab73c31e63904f51299985',true),('combat_v2_elemental_internal.other_geometry(uuid,uuid,pg_catalog.bool)','8776c899d5534308eb256de2ba451ae8',true),('combat_v2_elemental_internal.other_prepare_native(uuid,uuid,uuid,jsonb,pg_catalog.bool,jsonb)',CASE WHEN v_catalogo THEN '6e54b476b36ca716cf8c14f33ef9667e' ELSE '0e93d6425a2e8a151765040279758310'END,true),('combat_v2_elemental_internal.other_declaration_meta(uuid,uuid,uuid,jsonb)','d37f38beb455ecfbcda7a63962013542',true),('combat_v2_elemental_internal.other_bind_source(uuid)','35714da91f1df0f2d90d5921099e1177',true),('combat_v2_elemental_internal.other_source_valid(uuid)','20b96bb421f4bfbd3eb74a33294a3080',true),('combat_v2_elemental_internal.other_prepare_ordinary(uuid,uuid,uuid)','bb260ba226bc3557058820bdd5cacc93',true),('combat_v2_elemental_internal.other_prepare_master(uuid,uuid,uuid[],jsonb,jsonb)','1159e41bd29afbed0f8a5e828a0a79de',true),('combat_v2_elemental_internal.other_preset_ready(uuid,uuid)','eda00ca66bd5e24d1ac8cd1e620bf9c4',true),('combat_v2_elemental_internal.other_quote(uuid,uuid)','d50b47aedacd9734f5561067a3d62ba8',true),('combat_v2_elemental_internal.other_target_visible(uuid,uuid,pg_catalog.numeric)','f4440fc78dec1369349183c0957b1d1e',true),('combat_v2_elemental_internal.other_offer_label(uuid,jsonb,text)','4d40c4838291ae873d83ee544a4b0044',true),('combat_v2_elemental_internal.other_draw_range(uuid,uuid,pg_catalog.bool)','4856b88270f39cc66a656ec4a679d8d3',true),('combat_v2_elemental_internal.other_substitution_available(uuid)','a89a389d107dc8ad30a007f25ef1981a',true),('combat_v2_elemental_internal.other_substitution_options(jsonb)','5c08c47feed36d8c9c7f2d44f2ab9309',true),('combat_v2_elemental_internal.other_consumer_options(jsonb)',CASE WHEN v_catalogo THEN '8423c49ce8a83f2b19361b82a53fa9f4' ELSE '204fe2a77ba4c45cc862113859836151'END,true),('combat_v2_elemental_internal.other_ordinary_copy_offers(uuid,pg_catalog.int8,jsonb)','00bec9479f3d07cac011cc6139e27ad1',true),('combat_v2_elemental_internal.other_master_options(uuid,pg_catalog.int8)',CASE WHEN v_catalogo THEN '0c79a6a78b76b9e9ef8028d75e514af7' ELSE '13cd420ffe7d757af62bc723f27ce8b3'END,true),('combat_v2_elemental_internal.other_control_target(text,uuid,uuid)',CASE WHEN v_catalogo THEN 'b1af00f3eab38ed9e74836c5441616d7' ELSE 'b811c5e103dd67321aa8a2e3c601efbf'END,true),('combat_v2_elemental_internal.other_control_apply(text,uuid,uuid,uuid)',CASE WHEN v_catalogo THEN '4cf97ca72ff52f1bd33445ba54c8dd16' ELSE '63e4716e93d126611ca0490fe218fc57'END,true),('combat_v2_elemental_internal.other_prepare_callback(text,uuid,uuid,uuid,uuid[],jsonb,jsonb)','44d80129a84b21ab9345adfb4864736f',true),('combat_v2_elemental_internal.other_commit_control(jsonb,jsonb)','21538535df526b17d42dc91c7a3d4013',true),('combat_v2_elemental_internal.other_commit_master_control(jsonb)','c1690a97d6d6398360a401098588e56a',true),('combat_v2_elemental_internal.other_comparison(uuid,uuid,jsonb,pg_catalog.int4)','3b918a70932e681e148f7a90028f2d1c',true),('combat_v2_elemental_internal.other_force_from_outcome(uuid,uuid)','429727092531f7f07cfa99e06c7808d6',true),('combat_v2_elemental_internal.other_narrative_supported(uuid)','4a0d496f8d0528005aa3309ed60e3d0b',true),('combat_v2_elemental_internal.other_narrative_projection(uuid)','8ff935d763f4e4aeac25c3d6d017ecd3',true),('combat_v2_elemental_internal.scudo_profile(uuid)','92cfb95b3f56d8249d56c7d574e38d26',true),('combat_v2_elemental_internal.scudo_prepare_defense(uuid,uuid,uuid,uuid,uuid,jsonb)','b5808b034b5a3bcf50b7bcb8336d212a',true),('combat_v2_elemental_internal.scudo_declaration_meta(uuid,uuid,uuid,uuid,jsonb)','c27749ce44a439b3d59361a59e2337e9',true),('combat_v2_elemental_internal.scudo_bind_source(uuid)','cb840b147ea888fbfa57e3e55be49697',true),('combat_v2_elemental_internal.scudo_source_valid(uuid)','eacac569a8408d9e081344eebe12f9e2',true),('combat_v2_elemental_internal.scudo_meta(uuid)','92d3214d9de700399b263d1ee9ba8f93',true),('combat_v2_elemental_internal.scudo_staff_binding(uuid,uuid)','bf78d306e9a024a88ab453b9e8317671',true),('combat_v2_elemental_internal.scudo_staff_bind(uuid,uuid,uuid)','5f0c851bc78380fd88f246ca65fdb7fe',true),('combat_v2_elemental_internal.scudo_preset_ready(uuid,uuid)','b822c5fd7f3b549d455bbbcbe9e985c5',true),('combat_v2_elemental_internal.scudo_control_target(text,uuid,uuid)','014ec28c115fd3712b43d4253ffc39a9',true),('combat_v2_elemental_internal.scudo_control_apply(text,uuid,uuid,uuid)','2730009defb70b8c045be6430f496967',true),('combat_v2_elemental_internal.scudo_commit_control(jsonb,jsonb)','8b86c31c9d637aeb01beeb1c2fa2d1e7',true),('combat_v2_elemental_internal.scudo_commit_master_control(jsonb)','9bde876c7796180ea80bea206fe5829f',true),('combat_v2_elemental_internal.scudo_ability_meta(uuid,jsonb)','029b589a7af1a873e58cd3435bee3343',true),('combat_v2_elemental_internal.scudo_quote(uuid)','5c768cd419a7166e6e23420d5af3164b',true),('combat_v2_elemental_internal.scudo_consumer_options(jsonb)','e84aa35091f26367645f35a8815c78b1',true),('combat_v2_elemental_internal.scudo_master_options(uuid,pg_catalog.int8)','33fb2ed8a14cb05a3414e7be89556659',true),('combat_v2_elemental_internal.scudo_prepare_native(uuid,uuid,uuid,uuid,jsonb)','df51b64ad4443f0acdde37fbfdd5284e',true),('combat_v2_elemental_internal.scudo_narrative(uuid)','c580ef1cdbaff1598a7863603aa5c9a3',true),('combat_v2_elemental_internal.scarica_contact_range(uuid,uuid)','f92feff3bb5167ba034931dcb3832f4e',true),('combat_v2_elemental_internal.scarica_contact_witness(uuid,uuid,uuid,uuid)','34fb9bc5836831510ebd6e300e60a408',true),('combat_v2_elemental_internal.scarica_source_contact_valid(uuid)','57ed0bac1c1d36d8fd259010ceab4538',true)) SELECT 1 FROM expected e LEFT JOIN pg_proc p ON p.oid=to_regprocedure(e.sig) WHERE p.oid IS NULL OR md5(p.prosrc) IS DISTINCT FROM e.hash OR p.prosecdef IS DISTINCT FROM e.sd OR p.proowner IS DISTINCT FROM 'postgres'::regrole OR p.proconfig IS DISTINCT FROM ARRAY['search_path=""'] OR p.proacl IS DISTINCT FROM '{postgres=X/postgres}'::aclitem[]) THEN RAISE EXCEPTION 'runtime_elemental_complete_helper_drift';END IF;
end $function$;

-- SOURCE ONLY · footer forward della riparazione eligibility; non installer autonomo.
-- Catalogo825a già installato; soltanto helper/guard repair devono precedere questo footer nella stessa transazione.
-- Congelare app.fix_eligibility_parameters e finalizzare il pin dopo review pertinente della capsule.
DO $catalogo_root$
DECLARE
 expected_parameters_sha256 constant text:='c6fa6c3cb1357545b6e7e284b42bf4f274cfe15275cac17e9ee8f544f0431416';
 old_root_sha constant text:='f460be0a321e1640d7993a15285cf1b6352166cda41e991f0c644f29bd6a3658';
 old_row_sha constant text:='794d8d3c71c0e7a7e2a3f9a7bded6f1d03420095aa52fb4ceabb4970c7c92d4f';
 generic_ezbr constant text:='9a6889802cfa17c99a556538cccd4ad7ef75274d32adccbc192c23d257aa3e76';
 baseline_combat_ezbr constant text:='79bdb113f0203e5b0578a1211fb43f1c5cfb6b3bb5585714b4d9b5475ce27a11';
 rr mission_factory_owner.editor_release_readiness%ROWTYPE;
 prior_release mission_public_owner.release_admissions_v1%ROWTYPE;
 prior_qualification mission_public_owner.public_qualification_attestations_v1%ROWTYPE;
 params jsonb;review jsonb;binding jsonb;before_root jsonb;root jsonb;core jsonb;cfg jsonb;identity jsonb;runtime_before jsonb;
 shared_manifest jsonb:='[]';private_manifest jsonb:='[]';relation_manifest jsonb:='[]';trigger_manifest jsonb:='[]';
 item jsonb;h jsonb;abi jsonb;cols jsonb;descriptor jsonb;next_descriptor jsonb;alias_row record;kv record;
 relation_oid oid;function_oid oid;actual_count integer;affected integer;aliases integer:=0;
 old_generic jsonb;old_combat jsonb;edge_receipt jsonb;edge_files jsonb;base_files jsonb;changed_files jsonb;
 db_stored text;db_old_recomputed text;db_sha text;shared_sha text;private_sha text;relations_sha text;
 config_sha text;identity_sha text;root_text text;new_root_sha text;bindings jsonb;qualification jsonb;
 content_row mission_public_owner.mission_content_admissions_v1%ROWTYPE;content_request uuid;content_payload jsonb;
 pending_paths text[]:=ARRAY['["db_core"]'];current_path text[];stack_size integer;
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
 SELECT * INTO STRICT rr FROM mission_factory_owner.editor_release_readiness WHERE singleton FOR UPDATE NOWAIT;
 IF rr.revision_sha256<>old_root_sha OR rr.observed_revision_sha256 IS DISTINCT FROM old_root_sha
 OR public.combat_v2_sha256(to_jsonb(rr))<>old_row_sha
 OR encode(extensions.digest(convert_to(rr.canonical_preimage,'UTF8'),'sha256'),'hex')<>old_root_sha
 OR octet_length(rr.canonical_preimage)<>509525 THEN RAISE EXCEPTION 'CATALOGO_ROOT_BASELINE_DRIFT';END IF;
 IF EXISTS(SELECT 1 FROM public.combat_v2_sessions WHERE state='in_corso' AND closed_at IS NULL)
 OR EXISTS(SELECT 1 FROM public.master_v2_sessions WHERE stato NOT IN('chiusa','annullata') AND closed_at IS NULL) THEN
  RAISE EXCEPTION 'CATALOGO_ROOT_REQUIRES_QUIESCENCE';END IF;
 params:=nullif(current_setting('app.fix_eligibility_parameters',true),'')::jsonb;
 IF expected_parameters_sha256 !~ '^[0-9a-f]{64}$' OR params IS NULL
 OR public.combat_v2_sha256(params)<>expected_parameters_sha256
 OR params->>'schema_version' IS DISTINCT FROM 'fix-eligibility-parameters/1' THEN
  RAISE EXCEPTION 'CATALOGO_ROOT_REVIEWED_PARAMETERS_REQUIRED';END IF;
 review:=params->'review';
 IF NOT mission_factory_owner.keys_exact_v2(review,ARRAY['ref','sha256','P0','P1','P2']) THEN
  RAISE EXCEPTION 'CATALOGO_ROOT_REVIEW_SHAPE';END IF;
 IF nullif(review->>'ref','') IS NULL OR coalesce(review->>'sha256','')!~'^[0-9a-f]{64}$'
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
 OR old_combat->'version'IS DISTINCT FROM '45'::jsonb OR old_combat->>'ezbr_sha256'IS DISTINCT FROM '79bdb113f0203e5b0578a1211fb43f1c5cfb6b3bb5585714b4d9b5475ce27a11'
 OR public.combat_v2_sha256(root->'ui')<>'4d4d1f127b97483ee3bf8ec64bc618196cfe2ef2b2193c00b409c53acee90708' THEN
  RAISE EXCEPTION 'CATALOGO_ROOT_UNRELATED_SURFACE_DRIFT';END IF;
 db_stored:=root#>>'{db_core,sha256}';db_old_recomputed:=public.combat_v2_sha256((root->'db_core')-'sha256');
 IF db_stored<>'4f3bb78fdb3040133962640167396a0f739a44235cd4de42b2bcfa1e8cb573e2' OR db_old_recomputed IS DISTINCT FROM db_stored
 OR root#>>'{config,sha256}'<>public.combat_v2_sha256((root->'config')-'sha256') THEN
  RAISE EXCEPTION 'CATALOGO_ROOT_HASH_RECONCILIATION_DRIFT';END IF;

 -- Riparazione separata: il catalogo base825a e i suoi34/66/12/10 restano immutati.
 SELECT md5(prosrc),md5(pg_get_functiondef(oid))INTO STRICT identity_sha,db_sha FROM pg_proc
  WHERE oid='clan_innata_private.eligibility_release_assert()'::regprocedure;
 IF identity_sha IS DISTINCT FROM '250e7511806ab0fe07b6bf24b2a1770a' THEN RAISE EXCEPTION 'FIX_ELIGIBILITY_GUARD_DRIFT';END IF;
 root:=jsonb_set(root,'{db_core,combat_innata_functions,41419,source_md5}',to_jsonb(identity_sha),false);
 root:=jsonb_set(root,'{db_core,combat_innata_functions,41419,ddl_md5}',to_jsonb(db_sha),false);aliases:=1;
 SELECT md5(prosrc)INTO STRICT identity_sha FROM pg_proc WHERE oid='clan_innata_private.catalogo_eligibility_release_v1()'::regprocedure;
 IF identity_sha IS DISTINCT FROM 'bde885b7cec62845d6e21d8116a07dbd' THEN RAISE EXCEPTION 'FIX_ELIGIBILITY_HELPER_DRIFT';END IF;
 binding:=$repair_binding${"schema_version":"catalogo-eligibility-compat/1","state":"active_compatibility","parent_root":"f460be0a321e1640d7993a15285cf1b6352166cda41e991f0c644f29bd6a3658","base_catalogo_source_bundle_sha256":"825a1c14a59281fb3168430a993e9f2dbbbc41042f5169638d2e9c1e8e9868a5","source_bundle_sha256":"__FIX_SOURCE_BUNDLE_SHA256__","guard_source_md5":"250e7511806ab0fe07b6bf24b2a1770a","helper_source_md5":"bde885b7cec62845d6e21d8116a07dbd","normalized_source_identity":{"schema_version":"catalogo-eligibility-peer-identity/1","parent_root":"f460be0a321e1640d7993a15285cf1b6352166cda41e991f0c644f29bd6a3658","base_catalogo_source_bundle_sha256":"825a1c14a59281fb3168430a993e9f2dbbbc41042f5169638d2e9c1e8e9868a5","shared_manifest_sha256":"e4867513a34fa5b9b7c0bbd90fff6129fce16c386eb54cb68018355371c7ee48","private_functions_manifest_sha256":"3eb9bba89fc99206710cd079207631f4949dec9893a38d97d7d46e07386b5cc0","relations_manifest_sha256":"ff6758e43b2e6902077209c21540690f104403379fa70232bb4f516cae376710","parent_qa_state":"BLOCKED_BASE","qa_state":"NOT_RUN","staff_pass":false,"public_enabled":false},"normalized_source_identity_sha256":"17fd985dfe72c4c6ad3638c01ad019a1f3deb1c21f587a6a0e98c39458e6550f","shared_manifest_sha256":"e4867513a34fa5b9b7c0bbd90fff6129fce16c386eb54cb68018355371c7ee48","private_functions_manifest_sha256":"3eb9bba89fc99206710cd079207631f4949dec9893a38d97d7d46e07386b5cc0","relations_manifest_sha256":"ff6758e43b2e6902077209c21540690f104403379fa70232bb4f516cae376710","review":{"ref":"__INDEPENDENT_REVIEW_REF__","sha256":"__INDEPENDENT_REVIEW_SHA256__","P0":null,"P1":null,"P2":null}}$repair_binding$::jsonb;
 binding:=jsonb_set(binding,'{source_bundle_sha256}',params->'source_bundle_sha256',false);
 binding:=jsonb_set(binding,'{review}',review,false);
 SELECT jsonb_agg(jsonb_build_object('signature',p.oid::regprocedure::text,'source_md5',md5(p.prosrc),'ddl_md5',md5(pg_get_functiondef(p.oid)),
  'owner',pg_get_userbyid(p.proowner),'secdef',p.prosecdef,'config',p.proconfig,'acl',p.proacl::text,'volatility',p.provolatile::text)
  ORDER BY p.oid::regprocedure::text)INTO private_manifest FROM pg_proc p
 WHERE p.oid IN('clan_innata_private.eligibility_release_assert()'::regprocedure,'clan_innata_private.catalogo_eligibility_release_v1()'::regprocedure);
 binding:=binding||jsonb_build_object('functions',private_manifest,'functions_manifest_sha256',public.combat_v2_sha256(private_manifest));

 core:=(root->'db_core')||jsonb_build_object('catalogo_eligibility_compat',binding);
 db_sha:=public.combat_v2_sha256(core-'sha256');core:=jsonb_set(core,'{sha256}',to_jsonb(db_sha),false);root:=jsonb_set(root,'{db_core}',core,false);
 cfg:=(root->'config')||jsonb_build_object('catalogo_eligibility_compat',binding);
 config_sha:=public.combat_v2_sha256(cfg-'sha256');cfg:=jsonb_set(cfg,'{sha256}',to_jsonb(config_sha),false);root:=jsonb_set(root,'{config}',cfg,false);
 identity:=jsonb_build_object('schema_version','catalogo-eligibility-code-identity/1','parent_root',old_root_sha,
  'parent_code_identity',before_root#>'{contract,code_identity_sha256}','peer_identity_sha256',binding->'normalized_source_identity_sha256',
  'source_bundle_sha256',params->'source_bundle_sha256','db_sha256',db_sha);
 identity_sha:=public.combat_v2_sha256(identity);
 root:=jsonb_set(root,'{contract,code_identity_sha256}',to_jsonb(identity_sha),false);
 root:=jsonb_set(root,'{recovery,semantic_identity_sha256}',to_jsonb(identity_sha),false);
 root:=jsonb_set(root,'{recovery,catalogo_eligibility_compat}',jsonb_build_object('state','forward_repair','parent_root',old_root_sha,
  'previous_semantic_identity',before_root#>'{recovery,semantic_identity_sha256}','preserve_objects_and_history',true,
  'recovery','catalogo_inverse34_then_forward_inert_binding'),true);
 IF root->'ui'IS DISTINCT FROM before_root->'ui'OR root->'edge_bundles'IS DISTINCT FROM before_root->'edge_bundles'
 OR(root->'config')-ARRAY['sha256','catalogo_eligibility_compat']IS DISTINCT FROM(before_root->'config')-'sha256'
 OR root#>'{db_core,catalogo_completo}'IS DISTINCT FROM before_root#>'{db_core,catalogo_completo}'
 THEN RAISE EXCEPTION 'FIX_ELIGIBILITY_UNRELATED_CONFIG_CHANGED';END IF;
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
 IF NOT clan_innata_private.catalogo_eligibility_release_v1()THEN RAISE EXCEPTION 'FIX_ELIGIBILITY_BRANCH_NOT_ADMITTED';END IF;
 PERFORM set_config('app.fix_eligibility_result',jsonb_build_object('root_sha256',new_root_sha,'root_bytes',octet_length(root_text),
  'db_sha256',db_sha,'configuration_sha256',config_sha,'code_identity_sha256',identity_sha,'aliases_updated',aliases,
  'peer_identity_sha256',binding->'normalized_source_identity_sha256',
  'new_techniques_staff_pass',false,'provider_calls',0)::text,true);
END $catalogo_root$;

COMMIT;
