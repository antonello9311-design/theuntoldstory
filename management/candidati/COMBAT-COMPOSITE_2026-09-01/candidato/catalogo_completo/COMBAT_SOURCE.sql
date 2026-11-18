-- COMPONENT: preflight
-- SOURCE TEMPLATE · NON INSTALLABILE FINCHÉ CAPSULE/REVIEW/PIN NON SONO FINALIZZATI.
-- Una sola transazione; nessun test funzionale SQL o modifiche a schede reali.
BEGIN;
DO $cc_preflight$
DECLARE params jsonb:=$cc_final_params${
  "schema_version": "catalogo-footer-parameters/1",
  "expected_alias_count": 7,
  "shared_functions": [
    {
      "oid": "42942",
      "signature": "combat_consumer_private.narrative_context(uuid)",
      "source_md5": "bb4d81831292676d2e50e16d14f3192c",
      "ddl_md5": "b94718dd0bd16443163b82057d27da82",
      "abi": {
        "acl": "{postgres=X/postgres}",
        "oid": "42942",
        "kind": "f",
        "owner": "postgres",
        "config": [
          "search_path=\"\""
        ],
        "secdef": true,
        "strict": false,
        "nspname": "combat_consumer_private",
        "proname": "narrative_context",
        "returns": "jsonb",
        "language": "plpgsql",
        "parallel": "u",
        "arg_modes": null,
        "arg_names": [
          "p_round"
        ],
        "arg_types": "2950",
        "leakproof": false,
        "signature": "combat_consumer_private.narrative_context(uuid)",
        "volatility": "s"
      }
    },
    {
      "oid": "46723",
      "signature": "combat_consumer_private.narrative_declaration_supported(uuid)",
      "source_md5": "b2d2c4047c4f63cb104effede756b4b8",
      "ddl_md5": "7e8aa5b6991c26251bcc1ca3dcc834ca",
      "abi": {
        "acl": "{postgres=X/postgres}",
        "oid": "46723",
        "kind": "f",
        "owner": "postgres",
        "config": [
          "search_path=\"\""
        ],
        "secdef": true,
        "strict": false,
        "nspname": "combat_consumer_private",
        "proname": "narrative_declaration_supported",
        "returns": "boolean",
        "language": "plpgsql",
        "parallel": "u",
        "arg_modes": null,
        "arg_names": [
          "p_declaration"
        ],
        "arg_types": "2950",
        "leakproof": false,
        "signature": "combat_consumer_private.narrative_declaration_supported(uuid)",
        "volatility": "s"
      }
    },
    {
      "oid": "42968",
      "signature": "combat_consumer_private.validate_narrative_result(jsonb)",
      "source_md5": "a1ce0576cc6ca82207301ae0bbc21904",
      "ddl_md5": "0cfd40e8d0b43add0d4cc25e6c8767b7",
      "abi": {
        "acl": "{postgres=X/postgres}",
        "oid": "42968",
        "kind": "f",
        "owner": "postgres",
        "config": [
          "search_path=\"\""
        ],
        "secdef": false,
        "strict": false,
        "nspname": "combat_consumer_private",
        "proname": "validate_narrative_result",
        "returns": "void",
        "language": "plpgsql",
        "parallel": "u",
        "arg_modes": null,
        "arg_names": [
          "p"
        ],
        "arg_types": "3802",
        "leakproof": false,
        "signature": "combat_consumer_private.validate_narrative_result(jsonb)",
        "volatility": "i"
      }
    },
    {
      "oid": "52137",
      "signature": "combat_effects_private.lifecycle_before_report(uuid)",
      "source_md5": "bc4009af6a274d51e6b96fc51f7a7a78",
      "ddl_md5": "ee929b8e4bb4efcd584e7755aa5df682",
      "abi": {
        "acl": "{postgres=X/postgres}",
        "oid": "52137",
        "kind": "f",
        "owner": "postgres",
        "config": [
          "search_path=\"\""
        ],
        "secdef": true,
        "strict": false,
        "nspname": "combat_effects_private",
        "proname": "lifecycle_before_report",
        "returns": "jsonb",
        "language": "plpgsql",
        "parallel": "u",
        "arg_modes": null,
        "arg_names": [
          "p_round"
        ],
        "arg_types": "2950",
        "leakproof": false,
        "signature": "combat_effects_private.lifecycle_before_report(uuid)",
        "volatility": "v"
      }
    },
    {
      "oid": "52136",
      "signature": "combat_effects_private.lifecycle_main_end(uuid)",
      "source_md5": "a1948e8ce4fc505fc23e4e4089958507",
      "ddl_md5": "0b743c53cb23a3402542468dc3096430",
      "abi": {
        "acl": "{postgres=X/postgres}",
        "oid": "52136",
        "kind": "f",
        "owner": "postgres",
        "config": [
          "search_path=\"\""
        ],
        "secdef": true,
        "strict": false,
        "nspname": "combat_effects_private",
        "proname": "lifecycle_main_end",
        "returns": "jsonb",
        "language": "plpgsql",
        "parallel": "u",
        "arg_modes": null,
        "arg_names": [
          "p_declaration"
        ],
        "arg_types": "2950",
        "leakproof": false,
        "signature": "combat_effects_private.lifecycle_main_end(uuid)",
        "volatility": "v"
      }
    },
    {
      "oid": "52133",
      "signature": "combat_effects_private.lifecycle_open(uuid,uuid)",
      "source_md5": "f94e3ef794064277d596354feba2cd50",
      "ddl_md5": "9a45b13e8d31dd58447d212b28031fe0",
      "abi": {
        "acl": "{postgres=X/postgres}",
        "oid": "52133",
        "kind": "f",
        "owner": "postgres",
        "config": [
          "search_path=\"\""
        ],
        "secdef": true,
        "strict": false,
        "nspname": "combat_effects_private",
        "proname": "lifecycle_open",
        "returns": "void",
        "language": "plpgsql",
        "parallel": "u",
        "arg_modes": null,
        "arg_names": [
          "p_session",
          "p_actor"
        ],
        "arg_types": "2950 2950",
        "leakproof": false,
        "signature": "combat_effects_private.lifecycle_open(uuid,uuid)",
        "volatility": "v"
      }
    },
    {
      "oid": "51910",
      "signature": "combat_effects_private.personal_turn_end(uuid,uuid,uuid,text)",
      "source_md5": "125e376708eaccc758e7887a9bcef705",
      "ddl_md5": "53f87f6235e1f557317df936effbcd74",
      "abi": {
        "acl": "{postgres=X/postgres}",
        "oid": "51910",
        "kind": "f",
        "owner": "postgres",
        "config": [
          "search_path=\"\""
        ],
        "secdef": true,
        "strict": false,
        "nspname": "combat_effects_private",
        "proname": "personal_turn_end",
        "returns": "jsonb",
        "language": "plpgsql",
        "parallel": "u",
        "arg_modes": null,
        "arg_names": [
          "p_session",
          "p_actor",
          "p_turn",
          "p_adapter"
        ],
        "arg_types": "2950 2950 2950 25",
        "leakproof": false,
        "signature": "combat_effects_private.personal_turn_end(uuid,uuid,uuid,text)",
        "volatility": "v"
      }
    },
    {
      "oid": "51906",
      "signature": "combat_effects_private.personal_turn_start(uuid,uuid,uuid,text)",
      "source_md5": "e7ec43224a4640d00c53bad72ac0132d",
      "ddl_md5": "d023d8a651a5e8ef8fdb1cc834b93391",
      "abi": {
        "acl": "{postgres=X/postgres}",
        "oid": "51906",
        "kind": "f",
        "owner": "postgres",
        "config": [
          "search_path=\"\""
        ],
        "secdef": true,
        "strict": false,
        "nspname": "combat_effects_private",
        "proname": "personal_turn_start",
        "returns": "void",
        "language": "plpgsql",
        "parallel": "u",
        "arg_modes": null,
        "arg_names": [
          "p_session",
          "p_actor",
          "p_turn",
          "p_adapter"
        ],
        "arg_types": "2950 2950 2950 25",
        "leakproof": false,
        "signature": "combat_effects_private.personal_turn_start(uuid,uuid,uuid,text)",
        "volatility": "v"
      }
    },
    {
      "oid": "44942",
      "signature": "combat_panel_private.commit_master_actor(jsonb)",
      "source_md5": "0c39121bcbd32a49608e4d925560ba41",
      "ddl_md5": "b531bb7f50d4346a09e822b2f2e95144",
      "abi": {
        "acl": "{postgres=X/postgres}",
        "oid": "44942",
        "kind": "f",
        "owner": "postgres",
        "config": [
          "search_path=\"\""
        ],
        "secdef": true,
        "strict": false,
        "nspname": "combat_panel_private",
        "proname": "commit_master_actor",
        "returns": "jsonb",
        "language": "plpgsql",
        "parallel": "u",
        "arg_modes": null,
        "arg_names": [
          "p_command"
        ],
        "arg_types": "3802",
        "leakproof": false,
        "signature": "combat_panel_private.commit_master_actor(jsonb)",
        "volatility": "v"
      }
    },
    {
      "oid": "45916",
      "signature": "combat_panel_private.immobilization_actor_lifecycle()",
      "source_md5": "5244a1f635ad7d7336d24140d288b82a",
      "ddl_md5": "f8677e282d09ca9015c01de07391f1bc",
      "abi": {
        "acl": "{postgres=X/postgres}",
        "oid": "45916",
        "kind": "f",
        "owner": "postgres",
        "config": [
          "search_path=\"\""
        ],
        "secdef": true,
        "strict": false,
        "nspname": "combat_panel_private",
        "proname": "immobilization_actor_lifecycle",
        "returns": "trigger",
        "language": "plpgsql",
        "parallel": "u",
        "arg_modes": null,
        "arg_names": null,
        "arg_types": "",
        "leakproof": false,
        "signature": "combat_panel_private.immobilization_actor_lifecycle()",
        "volatility": "v"
      }
    },
    {
      "oid": "45918",
      "signature": "combat_panel_private.immobilization_session_lifecycle()",
      "source_md5": "a4671931aa6e908a94af2ad2d788d933",
      "ddl_md5": "38bc9bc060bc1af88cf087f5e4a687bb",
      "abi": {
        "acl": "{postgres=X/postgres}",
        "oid": "45918",
        "kind": "f",
        "owner": "postgres",
        "config": [
          "search_path=\"\""
        ],
        "secdef": true,
        "strict": false,
        "nspname": "combat_panel_private",
        "proname": "immobilization_session_lifecycle",
        "returns": "trigger",
        "language": "plpgsql",
        "parallel": "u",
        "arg_modes": null,
        "arg_names": null,
        "arg_types": "",
        "leakproof": false,
        "signature": "combat_panel_private.immobilization_session_lifecycle()",
        "volatility": "v"
      }
    },
    {
      "oid": "44940",
      "signature": "combat_panel_private.master_options(uuid,uuid,bigint)",
      "source_md5": "84c29f6a84fbe579caf5bb3fec7a2382",
      "ddl_md5": "c11111f77595c311b997d46a98eb30fa",
      "abi": {
        "acl": "{postgres=X/postgres}",
        "oid": "44940",
        "kind": "f",
        "owner": "postgres",
        "config": [
          "search_path=\"\""
        ],
        "secdef": true,
        "strict": false,
        "nspname": "combat_panel_private",
        "proname": "master_options",
        "returns": "jsonb",
        "language": "plpgsql",
        "parallel": "u",
        "arg_modes": null,
        "arg_names": [
          "p_location",
          "p_actor",
          "p_expected"
        ],
        "arg_types": "2950 2950 20",
        "leakproof": false,
        "signature": "combat_panel_private.master_options(uuid,uuid,bigint)",
        "volatility": "v"
      }
    },
    {
      "oid": "45000",
      "signature": "combat_panel_private.movement_block_reason(uuid)",
      "source_md5": "9cd995d873f2ae85f3cac5c0d7ff21ad",
      "ddl_md5": "4830deea719904406d11aa4b05cfd764",
      "abi": {
        "acl": "{postgres=X/postgres}",
        "oid": "45000",
        "kind": "f",
        "owner": "postgres",
        "config": [
          "search_path=\"\""
        ],
        "secdef": true,
        "strict": false,
        "nspname": "combat_panel_private",
        "proname": "movement_block_reason",
        "returns": "text",
        "language": "plpgsql",
        "parallel": "u",
        "arg_modes": null,
        "arg_names": [
          "p_body"
        ],
        "arg_types": "2950",
        "leakproof": false,
        "signature": "combat_panel_private.movement_block_reason(uuid)",
        "volatility": "s"
      }
    },
    {
      "oid": "46019",
      "signature": "combat_panel_private.narrative_declaration_facts(uuid)",
      "source_md5": "f4639eff179e6fdf1f998c0656ada09d",
      "ddl_md5": "40d6973235b85e949ebbdd6ff06790eb",
      "abi": {
        "acl": "{postgres=X/postgres}",
        "oid": "46019",
        "kind": "f",
        "owner": "postgres",
        "config": [
          "search_path=\"\""
        ],
        "secdef": true,
        "strict": false,
        "nspname": "combat_panel_private",
        "proname": "narrative_declaration_facts",
        "returns": "jsonb",
        "language": "plpgsql",
        "parallel": "u",
        "arg_modes": null,
        "arg_names": [
          "p_declaration"
        ],
        "arg_types": "2950",
        "leakproof": false,
        "signature": "combat_panel_private.narrative_declaration_facts(uuid)",
        "volatility": "s"
      }
    },
    {
      "oid": "46020",
      "signature": "combat_panel_private.narrative_ordinary_context(uuid)",
      "source_md5": "37d04042d9ee9cfec4ac237c7d9a5f37",
      "ddl_md5": "c6eacfaec260f73134ad6f066021b4e2",
      "abi": {
        "acl": "{postgres=X/postgres}",
        "oid": "46020",
        "kind": "f",
        "owner": "postgres",
        "config": [
          "search_path=\"\""
        ],
        "secdef": true,
        "strict": false,
        "nspname": "combat_panel_private",
        "proname": "narrative_ordinary_context",
        "returns": "jsonb",
        "language": "plpgsql",
        "parallel": "u",
        "arg_modes": null,
        "arg_names": [
          "p_round"
        ],
        "arg_types": "2950",
        "leakproof": false,
        "signature": "combat_panel_private.narrative_ordinary_context(uuid)",
        "volatility": "s"
      }
    },
    {
      "oid": "46018",
      "signature": "combat_panel_private.narrative_outcome_facts(jsonb)",
      "source_md5": "988cc3b61d0ebf41effda90d32e173b5",
      "ddl_md5": "a4d973f30fbd64ace5540ea3438c8e26",
      "abi": {
        "acl": "{postgres=X/postgres}",
        "oid": "46018",
        "kind": "f",
        "owner": "postgres",
        "config": [
          "search_path=\"\""
        ],
        "secdef": false,
        "strict": false,
        "nspname": "combat_panel_private",
        "proname": "narrative_outcome_facts",
        "returns": "jsonb",
        "language": "plpgsql",
        "parallel": "u",
        "arg_modes": null,
        "arg_names": [
          "p_outcome"
        ],
        "arg_types": "3802",
        "leakproof": false,
        "signature": "combat_panel_private.narrative_outcome_facts(jsonb)",
        "volatility": "s"
      }
    },
    {
      "oid": "44669",
      "signature": "combat_panel_private.ordinary_options(uuid,uuid,bigint)",
      "source_md5": "4337c8fe49127d7d72edc0789fc0352b",
      "ddl_md5": "c88bca3336e5a3e37cd81b4693b373b4",
      "abi": {
        "acl": "{postgres=X/postgres}",
        "oid": "44669",
        "kind": "f",
        "owner": "postgres",
        "config": [
          "search_path=\"\""
        ],
        "secdef": true,
        "strict": false,
        "nspname": "combat_panel_private",
        "proname": "ordinary_options",
        "returns": "jsonb",
        "language": "plpgsql",
        "parallel": "u",
        "arg_modes": null,
        "arg_names": [
          "p_location",
          "p_actor",
          "p_expected"
        ],
        "arg_types": "2950 2950 20",
        "leakproof": false,
        "signature": "combat_panel_private.ordinary_options(uuid,uuid,bigint)",
        "volatility": "v"
      }
    },
    {
      "oid": "44955",
      "signature": "combat_panel_private.round_details_from_source(jsonb,jsonb,jsonb)",
      "source_md5": "23722822d09c8d2a12a5121d04c141a6",
      "ddl_md5": "883d64a10bb28250187b01e96e2dcf5e",
      "abi": {
        "acl": "{postgres=X/postgres}",
        "oid": "44955",
        "kind": "f",
        "owner": "postgres",
        "config": [
          "search_path=\"\""
        ],
        "secdef": false,
        "strict": false,
        "nspname": "combat_panel_private",
        "proname": "round_details_from_source",
        "returns": "jsonb",
        "language": "plpgsql",
        "parallel": "u",
        "arg_modes": null,
        "arg_names": [
          "p_source",
          "p_roster",
          "p_offers"
        ],
        "arg_types": "3802 3802 3802",
        "leakproof": false,
        "signature": "combat_panel_private.round_details_from_source(jsonb,jsonb,jsonb)",
        "volatility": "i"
      }
    },
    {
      "oid": "46316",
      "signature": "combat_panel_private.round_options_authoritative(uuid,uuid)",
      "source_md5": "4def81b4f389a7ddb85703d582e8b404",
      "ddl_md5": "b185a37e712f6c7b789bb844608b576c",
      "abi": {
        "acl": "{postgres=X/postgres}",
        "oid": "46316",
        "kind": "f",
        "owner": "postgres",
        "config": [
          "search_path=\"\""
        ],
        "secdef": true,
        "strict": false,
        "nspname": "combat_panel_private",
        "proname": "round_options_authoritative",
        "returns": "jsonb",
        "language": "plpgsql",
        "parallel": "u",
        "arg_modes": null,
        "arg_names": [
          "p_round",
          "p_actor"
        ],
        "arg_types": "2950 2950",
        "leakproof": false,
        "signature": "combat_panel_private.round_options_authoritative(uuid,uuid)",
        "volatility": "v"
      }
    },
    {
      "oid": "61967",
      "signature": "combat_v2_elemental_internal.other_consumer_options(jsonb)",
      "source_md5": "8423c49ce8a83f2b19361b82a53fa9f4",
      "ddl_md5": "0d57fa274c2b6b63dc5ed1ef0a7c8ca9",
      "abi": {
        "acl": "{postgres=X/postgres}",
        "oid": "61967",
        "kind": "f",
        "owner": "postgres",
        "config": [
          "search_path=\"\""
        ],
        "secdef": true,
        "strict": false,
        "nspname": "combat_v2_elemental_internal",
        "proname": "other_consumer_options",
        "returns": "jsonb",
        "language": "plpgsql",
        "parallel": "u",
        "arg_modes": null,
        "arg_names": [
          "p"
        ],
        "arg_types": "3802",
        "leakproof": false,
        "signature": "combat_v2_elemental_internal.other_consumer_options(jsonb)",
        "volatility": "v"
      }
    },
    {
      "oid": "61972",
      "signature": "combat_v2_elemental_internal.other_control_apply(text,uuid,uuid,uuid)",
      "source_md5": "4cf97ca72ff52f1bd33445ba54c8dd16",
      "ddl_md5": "9066a8a35e086727ed0240ea05fce684",
      "abi": {
        "acl": "{postgres=X/postgres}",
        "oid": "61972",
        "kind": "f",
        "owner": "postgres",
        "config": [
          "search_path=\"\""
        ],
        "secdef": true,
        "strict": false,
        "nspname": "combat_v2_elemental_internal",
        "proname": "other_control_apply",
        "returns": "jsonb",
        "language": "plpgsql",
        "parallel": "u",
        "arg_modes": null,
        "arg_names": [
          "p_adapter",
          "p_offer",
          "p_actor",
          "p_request"
        ],
        "arg_types": "25 2950 2950 2950",
        "leakproof": false,
        "signature": "combat_v2_elemental_internal.other_control_apply(text,uuid,uuid,uuid)",
        "volatility": "v"
      }
    },
    {
      "oid": "61971",
      "signature": "combat_v2_elemental_internal.other_control_target(text,uuid,uuid)",
      "source_md5": "b1af00f3eab38ed9e74836c5441616d7",
      "ddl_md5": "03724449dfc52ef8fcf4f89ae6eabb34",
      "abi": {
        "acl": "{postgres=X/postgres}",
        "oid": "61971",
        "kind": "f",
        "owner": "postgres",
        "config": [
          "search_path=\"\""
        ],
        "secdef": true,
        "strict": false,
        "nspname": "combat_v2_elemental_internal",
        "proname": "other_control_target",
        "returns": "uuid",
        "language": "plpgsql",
        "parallel": "u",
        "arg_modes": null,
        "arg_names": [
          "p_adapter",
          "p_offer",
          "p_actor"
        ],
        "arg_types": "25 2950 2950",
        "leakproof": false,
        "signature": "combat_v2_elemental_internal.other_control_target(text,uuid,uuid)",
        "volatility": "v"
      }
    },
    {
      "oid": "61970",
      "signature": "combat_v2_elemental_internal.other_master_options(uuid,bigint)",
      "source_md5": "0c79a6a78b76b9e9ef8028d75e514af7",
      "ddl_md5": "38e2e92e5566275950c270ef5a8fe3d6",
      "abi": {
        "acl": "{postgres=X/postgres}",
        "oid": "61970",
        "kind": "f",
        "owner": "postgres",
        "config": [
          "search_path=\"\""
        ],
        "secdef": true,
        "strict": false,
        "nspname": "combat_v2_elemental_internal",
        "proname": "other_master_options",
        "returns": "void",
        "language": "plpgsql",
        "parallel": "u",
        "arg_modes": null,
        "arg_names": [
          "p_context",
          "p_expected"
        ],
        "arg_types": "2950 20",
        "leakproof": false,
        "signature": "combat_v2_elemental_internal.other_master_options(uuid,bigint)",
        "volatility": "v"
      }
    },
    {
      "oid": "61954",
      "signature": "combat_v2_elemental_internal.other_prepare_native(uuid,uuid,uuid,jsonb,boolean,jsonb)",
      "source_md5": "6e54b476b36ca716cf8c14f33ef9667e",
      "ddl_md5": "98acc6f2f9fcb26b47f3e6e830763e42",
      "abi": {
        "acl": "{postgres=X/postgres}",
        "oid": "61954",
        "kind": "f",
        "owner": "postgres",
        "config": [
          "search_path=\"\""
        ],
        "secdef": true,
        "strict": false,
        "nspname": "combat_v2_elemental_internal",
        "proname": "other_prepare_native",
        "returns": "jsonb",
        "language": "plpgsql",
        "parallel": "u",
        "arg_modes": null,
        "arg_names": [
          "p_round",
          "p_actor",
          "p_request",
          "p_intent",
          "p_push",
          "p_native_ref"
        ],
        "arg_types": "2950 2950 2950 3802 16 3802",
        "leakproof": false,
        "signature": "combat_v2_elemental_internal.other_prepare_native(uuid,uuid,uuid,jsonb,boolean,jsonb)",
        "volatility": "v"
      }
    },
    {
      "oid": "61950",
      "signature": "combat_v2_elemental_internal.other_profile(uuid,uuid)",
      "source_md5": "dd1e62e9052469fae4c98fed245c730a",
      "ddl_md5": "0959ae18dc9357f65d8d8169e39b0cb2",
      "abi": {
        "acl": "{postgres=X/postgres}",
        "oid": "61950",
        "kind": "f",
        "owner": "postgres",
        "config": [
          "search_path=\"\""
        ],
        "secdef": true,
        "strict": false,
        "nspname": "combat_v2_elemental_internal",
        "proname": "other_profile",
        "returns": "jsonb",
        "language": "plpgsql",
        "parallel": "u",
        "arg_modes": null,
        "arg_names": [
          "p_actor",
          "p_technique"
        ],
        "arg_types": "2950 2950",
        "leakproof": false,
        "signature": "combat_v2_elemental_internal.other_profile(uuid,uuid)",
        "volatility": "s"
      }
    },
    {
      "oid": "39291",
      "signature": "combat_v2_multitarget_internal.resolve_parent(uuid,uuid,uuid,boolean)",
      "source_md5": "e9c7eb293c1791e36ba5fe70204af224",
      "ddl_md5": "e494d3c9c4ee71bbdc81751c030ae3f7",
      "abi": {
        "acl": "{postgres=X/postgres}",
        "oid": "39291",
        "kind": "f",
        "owner": "postgres",
        "config": [
          "search_path=\"\""
        ],
        "secdef": true,
        "strict": false,
        "nspname": "combat_v2_multitarget_internal",
        "proname": "resolve_parent",
        "returns": "jsonb",
        "language": "plpgsql",
        "parallel": "u",
        "arg_modes": null,
        "arg_names": [
          "p_session",
          "p_round",
          "p_attack",
          "p_values"
        ],
        "arg_types": "2950 2950 2950 16",
        "leakproof": false,
        "signature": "combat_v2_multitarget_internal.resolve_parent(uuid,uuid,uuid,boolean)",
        "volatility": "v"
      }
    },
    {
      "oid": "42947",
      "signature": "public.combat_consumer_narrative_claim_v1(uuid,text,uuid)",
      "source_md5": "1b51f51abc7ee3201a994c520fbcc64c",
      "ddl_md5": "63c1f412532da4ecfc6a82a5aca7bdfa",
      "abi": {
        "acl": "{postgres=X/postgres,service_role=X/postgres}",
        "oid": "42947",
        "kind": "f",
        "owner": "postgres",
        "config": [
          "search_path=\"\""
        ],
        "secdef": true,
        "strict": false,
        "nspname": "public",
        "proname": "combat_consumer_narrative_claim_v1",
        "returns": "jsonb",
        "language": "plpgsql",
        "parallel": "u",
        "arg_modes": null,
        "arg_names": [
          "p_round",
          "p_report_sha256",
          "p_request_key"
        ],
        "arg_types": "2950 25 2950",
        "leakproof": false,
        "signature": "public.combat_consumer_narrative_claim_v1(uuid,text,uuid)",
        "volatility": "v"
      }
    },
    {
      "oid": "42969",
      "signature": "public.combat_consumer_narrative_complete_v1(uuid,jsonb,uuid)",
      "source_md5": "2d60a9af131230e7f40ff99ed6456180",
      "ddl_md5": "f9f6185f3de24ed7ae34aa2c0c5e7173",
      "abi": {
        "acl": "{postgres=X/postgres,service_role=X/postgres}",
        "oid": "42969",
        "kind": "f",
        "owner": "postgres",
        "config": [
          "search_path=\"\""
        ],
        "secdef": true,
        "strict": false,
        "nspname": "public",
        "proname": "combat_consumer_narrative_complete_v1",
        "returns": "jsonb",
        "language": "plpgsql",
        "parallel": "u",
        "arg_modes": null,
        "arg_names": [
          "p_claim",
          "p_result",
          "p_request_key"
        ],
        "arg_types": "2950 3802 2950",
        "leakproof": false,
        "signature": "public.combat_consumer_narrative_complete_v1(uuid,jsonb,uuid)",
        "volatility": "v"
      }
    },
    {
      "oid": "44808",
      "signature": "public.combat_panel_commit_v1(jsonb)",
      "source_md5": "ce0c32cce5f6da141e20c015aba9e880",
      "ddl_md5": "7c285429ea93b118c2d390e5a62cbe90",
      "abi": {
        "acl": "{postgres=X/postgres,authenticated=X/postgres}",
        "oid": "44808",
        "kind": "f",
        "owner": "postgres",
        "config": [
          "search_path=\"\""
        ],
        "secdef": true,
        "strict": false,
        "nspname": "public",
        "proname": "combat_panel_commit_v1",
        "returns": "jsonb",
        "language": "plpgsql",
        "parallel": "u",
        "arg_modes": null,
        "arg_names": [
          "p_command"
        ],
        "arg_types": "3802",
        "leakproof": false,
        "signature": "public.combat_panel_commit_v1(jsonb)",
        "volatility": "v"
      }
    },
    {
      "oid": "31324",
      "signature": "public.combat_v2_action_declare(uuid,uuid,jsonb,text,uuid)",
      "source_md5": "56a48200d4a15178b63e52445cb42ba7",
      "ddl_md5": "6fdd865937ad47382b686820332e78b6",
      "abi": {
        "acl": "{postgres=X/postgres,authenticated=X/postgres,service_role=X/postgres}",
        "oid": "31324",
        "kind": "f",
        "owner": "postgres",
        "config": [
          "search_path=\"\""
        ],
        "secdef": true,
        "strict": false,
        "nspname": "public",
        "proname": "combat_v2_action_declare",
        "returns": "jsonb",
        "language": "plpgsql",
        "parallel": "u",
        "arg_modes": null,
        "arg_names": [
          "p_round",
          "p_actor",
          "p_intent",
          "p_text",
          "p_request_key"
        ],
        "arg_types": "2950 2950 3802 25 2950",
        "leakproof": false,
        "signature": "public.combat_v2_action_declare(uuid,uuid,jsonb,text,uuid)",
        "volatility": "v"
      }
    },
    {
      "oid": "31311",
      "signature": "public.combat_v2_actor_ability(uuid,text,uuid,boolean)",
      "source_md5": "6bc1065e07011266fead520f4b7d3b47",
      "ddl_md5": "12183e1b698dbbbf8b904c6a24d89a51",
      "abi": {
        "acl": "{postgres=X/postgres,service_role=X/postgres}",
        "oid": "31311",
        "kind": "f",
        "owner": "postgres",
        "config": [
          "search_path=\"\""
        ],
        "secdef": true,
        "strict": false,
        "nspname": "public",
        "proname": "combat_v2_actor_ability",
        "returns": "jsonb",
        "language": "sql",
        "parallel": "u",
        "arg_modes": null,
        "arg_names": [
          "p_actor",
          "p_source",
          "p_ability",
          "p_defense"
        ],
        "arg_types": "2950 25 2950 16",
        "leakproof": false,
        "signature": "public.combat_v2_actor_ability(uuid,text,uuid,boolean)",
        "volatility": "s"
      }
    },
    {
      "oid": "31326",
      "signature": "public.combat_v2_defense_declare(uuid,uuid,uuid,jsonb,text,uuid)",
      "source_md5": "7e947fd7937ec49f19101a58d95432d8",
      "ddl_md5": "568d4c124fee6d53dedd1d6e9eb6e9bd",
      "abi": {
        "acl": "{postgres=X/postgres,authenticated=X/postgres,service_role=X/postgres}",
        "oid": "31326",
        "kind": "f",
        "owner": "postgres",
        "config": [
          "search_path=\"\""
        ],
        "secdef": true,
        "strict": false,
        "nspname": "public",
        "proname": "combat_v2_defense_declare",
        "returns": "jsonb",
        "language": "plpgsql",
        "parallel": "u",
        "arg_modes": null,
        "arg_names": [
          "p_round",
          "p_attack_declaration",
          "p_actor",
          "p_intent",
          "p_text",
          "p_request_key"
        ],
        "arg_types": "2950 2950 2950 3802 25 2950",
        "leakproof": false,
        "signature": "public.combat_v2_defense_declare(uuid,uuid,uuid,jsonb,text,uuid)",
        "volatility": "v"
      }
    },
    {
      "oid": "31331",
      "signature": "public.combat_v2_round_resolve(uuid,uuid)",
      "source_md5": "954c762bcaf8a4638d51a9061a275f24",
      "ddl_md5": "ab38f8891a4f0d663410276047ea254d",
      "abi": {
        "acl": "{postgres=X/postgres,service_role=X/postgres,authenticated=X/postgres}",
        "oid": "31331",
        "kind": "f",
        "owner": "postgres",
        "config": [
          "search_path=\"\""
        ],
        "secdef": true,
        "strict": false,
        "nspname": "public",
        "proname": "combat_v2_round_resolve",
        "returns": "jsonb",
        "language": "plpgsql",
        "parallel": "u",
        "arg_modes": null,
        "arg_names": [
          "p_round",
          "p_request_key"
        ],
        "arg_types": "2950 2950",
        "leakproof": false,
        "signature": "public.combat_v2_round_resolve(uuid,uuid)",
        "volatility": "v"
      }
    },
    {
      "oid": "19700",
      "signature": "public.post_heal(uuid,uuid)",
      "source_md5": "dcde447ee079472efa4fd41c1c911633",
      "ddl_md5": "9fb236d5f72312f6fb33587a2981e427",
      "abi": {
        "acl": "{postgres=X/postgres,service_role=X/postgres,authenticated=X/postgres}",
        "oid": "19700",
        "kind": "f",
        "owner": "postgres",
        "config": [
          "search_path=public"
        ],
        "secdef": true,
        "strict": false,
        "nspname": "public",
        "proname": "post_heal",
        "returns": "text",
        "language": "plpgsql",
        "parallel": "u",
        "arg_modes": null,
        "arg_names": [
          "p_location",
          "p_target_user"
        ],
        "arg_types": "2950 2950",
        "leakproof": false,
        "signature": "public.post_heal(uuid,uuid)",
        "volatility": "v"
      }
    }
  ],
  "private_functions": [
    {
      "signature": "combat_panel_private.catalog_lifecycle_lines_v1(jsonb,jsonb)",
      "source_md5": "8a472424ef8d1bc4d04283d18a0d049e"
    },
    {
      "signature": "combat_panel_private.catalog_result_label_v1(jsonb)",
      "source_md5": "acae3722db638c3e8449b39f627fcfca"
    },
    {
      "signature": "combat_panel_private.cure_bind_v1(uuid)",
      "source_md5": "a9c1bde3a9b0de30c44312b12be60eff"
    },
    {
      "signature": "combat_panel_private.cure_commit_v1(jsonb)",
      "source_md5": "5690d47226fc9ae7bd5aca96ced8d079"
    },
    {
      "signature": "combat_panel_private.cure_contact_v1(uuid,uuid)",
      "source_md5": "878069c4d7dca1bc0ddade6b22f35c7d"
    },
    {
      "signature": "combat_panel_private.cure_declaration_meta_v1(uuid,uuid,uuid,jsonb)",
      "source_md5": "9fdec7a42f67372bc1f2e2f408f16ba1"
    },
    {
      "signature": "combat_panel_private.cure_defense_guard_v1()",
      "source_md5": "72b7362b50720f93672dfa1ab96338bc"
    },
    {
      "signature": "combat_panel_private.cure_frozen_turn_valid_v1(uuid,uuid)",
      "source_md5": "7785ea336dd4a1deb9dd19487756d638"
    },
    {
      "signature": "combat_panel_private.cure_narrative_facts_v1(uuid)",
      "source_md5": "a32f97cddb31ccf9581ba328f1e94e49"
    },
    {
      "signature": "combat_panel_private.cure_neutral_preset_v1(uuid,uuid,uuid,jsonb)",
      "source_md5": "0ecd6867dd7f24deb4b58a76743517de"
    },
    {
      "signature": "combat_panel_private.cure_note_voluntary_v1(uuid,uuid,text,text)",
      "source_md5": "669353b795c5f327bdcd338c9990716d"
    },
    {
      "signature": "combat_panel_private.cure_offers_v1(uuid,bigint,jsonb)",
      "source_md5": "66a3d715a7ca7f77ef3f36cd121fd5ec"
    },
    {
      "signature": "combat_panel_private.cure_persistent_execution_scope_v1(uuid)",
      "source_md5": "ea6a91fa5940c0d3680a36c4ee962880"
    },
    {
      "signature": "combat_panel_private.cure_persistent_scope_v1(uuid)",
      "source_md5": "4fdb37eb54e15b3da2845a41809ccc57"
    },
    {
      "signature": "combat_panel_private.cure_prepare_v1(uuid,uuid,uuid,uuid)",
      "source_md5": "bf7f19036a2846412374c68950126ac5"
    },
    {
      "signature": "combat_panel_private.cure_profile_v1(uuid)",
      "source_md5": "88ec3750ea8aa0661eaa573747325e87"
    },
    {
      "signature": "combat_panel_private.cure_resolve_v1(uuid)",
      "source_md5": "d385538828e19526af5e59dc8d18f167"
    },
    {
      "signature": "combat_panel_private.cure_staff_execution_scope_v1(uuid)",
      "source_md5": "9adc4dfa74e700f54ba58d8691fb8f76"
    },
    {
      "signature": "combat_panel_private.cure_staff_scope_v1(uuid)",
      "source_md5": "343140ae23ba4787fa511d1e6f27092e"
    },
    {
      "signature": "combat_panel_private.cure_turn_clear_v1(uuid,uuid)",
      "source_md5": "ff5fac17361830d01e19aeba05430328"
    },
    {
      "signature": "combat_panel_private.cure_turn_used_v1(uuid,uuid)",
      "source_md5": "11badbd523e79faba44fa282150be54b"
    },
    {
      "signature": "combat_panel_private.cure_voluntary_receipt_guard_v1()",
      "source_md5": "08bacb86944bec00bc213eddf9815dca"
    },
    {
      "signature": "combat_v2_genjutsu_internal.actor_meta(uuid)",
      "source_md5": "df3798ced5e32f7cb5aef4283fd88a00"
    },
    {
      "signature": "combat_v2_genjutsu_internal.ally_contact(uuid,uuid)",
      "source_md5": "09fe1a174c9e813dcf541f1ad41a7016"
    },
    {
      "signature": "combat_v2_genjutsu_internal.bind_release(uuid)",
      "source_md5": "1c6bfe3e32950c77afbb8c7b91a21078"
    },
    {
      "signature": "combat_v2_genjutsu_internal.bind_source(uuid)",
      "source_md5": "80c79fc14b48e386b5920d021d537ba7"
    },
    {
      "signature": "combat_v2_genjutsu_internal.binding(uuid)",
      "source_md5": "404fc795700a7fbe3334464c97a5058b"
    },
    {
      "signature": "combat_v2_genjutsu_internal.comparison(uuid,uuid,jsonb)",
      "source_md5": "e63a4943d52d01b719d9693039c18d6c"
    },
    {
      "signature": "combat_v2_genjutsu_internal.consumer_options(jsonb)",
      "source_md5": "c8daec5fcb19dc88267f7ceab87a2be8"
    },
    {
      "signature": "combat_v2_genjutsu_internal.declaration_events(uuid)",
      "source_md5": "194b5c80d8e4779c66f0fdb8c50f1de3"
    },
    {
      "signature": "combat_v2_genjutsu_internal.declaration_meta(uuid,uuid,uuid,jsonb)",
      "source_md5": "1dadbb12c0a1965b0461133ca0efc5d3"
    },
    {
      "signature": "combat_v2_genjutsu_internal.decorate_outcome(uuid,uuid,jsonb)",
      "source_md5": "d0160238be06fafb4ce521553d4e745a"
    },
    {
      "signature": "combat_v2_genjutsu_internal.defense_intent_allowed(uuid,jsonb)",
      "source_md5": "bf261ee2a0f55a52a8bb9462333058bd"
    },
    {
      "signature": "combat_v2_genjutsu_internal.end_context(uuid,uuid)",
      "source_md5": "9d931f4ac19d9170e6119458d4825b23"
    },
    {
      "signature": "combat_v2_genjutsu_internal.event_binding(uuid,jsonb)",
      "source_md5": "8b3b23a81afc7c2092902373cedbe0d2"
    },
    {
      "signature": "combat_v2_genjutsu_internal.event_public(text)",
      "source_md5": "ecaea9744e8960072a32e7908856f9c0"
    },
    {
      "signature": "combat_v2_genjutsu_internal.kai_defense_valid(uuid,uuid)",
      "source_md5": "1ab8564f473d8a008ba29e8095a4a6de"
    },
    {
      "signature": "combat_v2_genjutsu_internal.master_options(uuid,bigint)",
      "source_md5": "0111ecc9e4034eb295e5a898cd4cd88e"
    },
    {
      "signature": "combat_v2_genjutsu_internal.movement_blocked(uuid)",
      "source_md5": "8a243e907877525d58c71429cfbb8f98"
    },
    {
      "signature": "combat_v2_genjutsu_internal.narrative_facts(uuid)",
      "source_md5": "de22bbd83e9ab8edb6a025e5131edde0"
    },
    {
      "signature": "combat_v2_genjutsu_internal.narrative_supported(uuid)",
      "source_md5": "8c498c00f438621c617ae6132318ab66"
    },
    {
      "signature": "combat_v2_genjutsu_internal.open_turn(uuid,uuid)",
      "source_md5": "701defaed0c81b0a6f4ccef2857a4a42"
    },
    {
      "signature": "combat_v2_genjutsu_internal.panel_options(uuid,bigint)",
      "source_md5": "cb344a077d919955ef0f570ba9313d35"
    },
    {
      "signature": "combat_v2_genjutsu_internal.prepare(uuid,uuid,uuid,jsonb)",
      "source_md5": "7275b845d7140c81fd2ec2ac48d3cd91"
    },
    {
      "signature": "combat_v2_genjutsu_internal.preset_ready(uuid)",
      "source_md5": "b087938ff9bdc51ee5518c72beb88c04"
    },
    {
      "signature": "combat_v2_genjutsu_internal.profile()",
      "source_md5": "87cf137eefa6f81cd178c039859c1c45"
    },
    {
      "signature": "combat_v2_genjutsu_internal.quote(uuid)",
      "source_md5": "28ff62253407034032035e6acd8a2b6b"
    },
    {
      "signature": "combat_v2_genjutsu_internal.raw_attack_facts(uuid)",
      "source_md5": "da147cc5595cac875224cbbebfe82ef8"
    },
    {
      "signature": "combat_v2_genjutsu_internal.real_owned(uuid)",
      "source_md5": "f6e8ecb85aeb3c938cdc71eb0cbf80cd"
    },
    {
      "signature": "combat_v2_genjutsu_internal.record_event(text,uuid,jsonb)",
      "source_md5": "9ba46dc99acb5e3063e0d813b55d0f3f"
    },
    {
      "signature": "combat_v2_genjutsu_internal.release_intents(uuid)",
      "source_md5": "e1ddaf358a32b03d0ae3aed3023d57a7"
    },
    {
      "signature": "combat_v2_genjutsu_internal.release_meta(uuid,uuid,uuid,jsonb)",
      "source_md5": "1d0416d6f715524c8ac1374dbabae55d"
    },
    {
      "signature": "combat_v2_genjutsu_internal.report_facts(uuid)",
      "source_md5": "03c90f3dd07812d1061c7037216304d9"
    },
    {
      "signature": "combat_v2_genjutsu_internal.report_projection(uuid)",
      "source_md5": "d3c2e36c0248730650a6c6c4b34d1e47"
    },
    {
      "signature": "combat_v2_genjutsu_internal.resolution_enter(uuid,uuid)",
      "source_md5": "c45574805f3171628ef99392fa255eb2"
    },
    {
      "signature": "combat_v2_genjutsu_internal.resolution_leave()",
      "source_md5": "612f97c08785e572226423ed5c1f68ed"
    },
    {
      "signature": "combat_v2_genjutsu_internal.resolve_release(uuid)",
      "source_md5": "cb9fcdd4ff035ca7938144412be57e2c"
    },
    {
      "signature": "combat_v2_genjutsu_internal.runtime_allowed(uuid)",
      "source_md5": "8512b2d982094a3b339de4ec3bfd3327"
    },
    {
      "signature": "combat_v2_genjutsu_internal.scope(uuid)",
      "source_md5": "17ac15ea8ea5a734ff4eb0cc9d6e7f34"
    },
    {
      "signature": "combat_v2_genjutsu_internal.source_valid(uuid)",
      "source_md5": "84ca595cfd34b8467b69c0256e94e254"
    },
    {
      "signature": "combat_v2_genjutsu_internal.staff_bind(uuid,uuid)",
      "source_md5": "b8b6261b5c8f7df3c91400d5969d8eae"
    },
    {
      "signature": "combat_v2_genjutsu_internal.success(jsonb,integer,boolean)",
      "source_md5": "90faca8a42e9f7f54726276f5a1e94bf"
    },
    {
      "signature": "combat_v2_genjutsu_internal.turn_end(uuid,uuid,uuid,text)",
      "source_md5": "5130f380992a3585b502934e2833e716"
    },
    {
      "signature": "combat_v2_genjutsu_internal.turn_start(uuid,uuid,uuid,text)",
      "source_md5": "b1781f3637f8c3414a9dd2c4038869c2"
    },
    {
      "signature": "combat_v2_genjutsu_internal.validate_attack_facts(jsonb)",
      "source_md5": "0c6434b64a325213dbf8d18c603ed061"
    },
    {
      "signature": "combat_v2_genjutsu_internal.validate_release_facts(jsonb)",
      "source_md5": "a46a047fa733321603e24a6102d7183d"
    }
  ],
  "relations": [
    {
      "name": "combat_panel_private.cure_gate_v1",
      "columns": [
        {
          "name": "singleton",
          "type": "boolean",
          "not_null": true,
          "default": "true"
        },
        {
          "name": "staff_enabled",
          "type": "boolean",
          "not_null": true,
          "default": "false"
        },
        {
          "name": "public_enabled",
          "type": "boolean",
          "not_null": true,
          "default": "false"
        },
        {
          "name": "contract_version",
          "type": "text",
          "not_null": true,
          "default": "'palmo-curativo/1'::text"
        }
      ]
    },
    {
      "name": "combat_panel_private.cure_ledger_v1",
      "columns": [
        {
          "name": "declaration_id",
          "type": "uuid",
          "not_null": true,
          "default": null
        },
        {
          "name": "session_id",
          "type": "uuid",
          "not_null": true,
          "default": null
        },
        {
          "name": "round_id",
          "type": "uuid",
          "not_null": true,
          "default": null
        },
        {
          "name": "actor_id",
          "type": "uuid",
          "not_null": true,
          "default": null
        },
        {
          "name": "target_actor_id",
          "type": "uuid",
          "not_null": true,
          "default": null
        },
        {
          "name": "hp_before",
          "type": "integer",
          "not_null": true,
          "default": null
        },
        {
          "name": "hp_after",
          "type": "integer",
          "not_null": true,
          "default": null
        },
        {
          "name": "hp_max",
          "type": "integer",
          "not_null": true,
          "default": null
        },
        {
          "name": "expected_gain",
          "type": "integer",
          "not_null": true,
          "default": null
        },
        {
          "name": "committed_gain",
          "type": "integer",
          "not_null": true,
          "default": null
        },
        {
          "name": "applied_real_gain",
          "type": "integer",
          "not_null": true,
          "default": "0"
        },
        {
          "name": "is_simulated",
          "type": "boolean",
          "not_null": true,
          "default": null
        },
        {
          "name": "facts",
          "type": "jsonb",
          "not_null": true,
          "default": null
        },
        {
          "name": "created_at",
          "type": "timestamp with time zone",
          "not_null": true,
          "default": "clock_timestamp()"
        }
      ]
    },
    {
      "name": "combat_panel_private.cure_preparations_v1",
      "columns": [
        {
          "name": "request_key",
          "type": "uuid",
          "not_null": true,
          "default": null
        },
        {
          "name": "transaction_id",
          "type": "bigint",
          "not_null": true,
          "default": null
        },
        {
          "name": "session_id",
          "type": "uuid",
          "not_null": true,
          "default": null
        },
        {
          "name": "round_id",
          "type": "uuid",
          "not_null": true,
          "default": null
        },
        {
          "name": "actor_id",
          "type": "uuid",
          "not_null": true,
          "default": null
        },
        {
          "name": "target_actor_id",
          "type": "uuid",
          "not_null": true,
          "default": null
        },
        {
          "name": "controller_user",
          "type": "uuid",
          "not_null": true,
          "default": null
        },
        {
          "name": "controller_version",
          "type": "bigint",
          "not_null": true,
          "default": null
        },
        {
          "name": "source",
          "type": "jsonb",
          "not_null": true,
          "default": null
        },
        {
          "name": "source_sha256",
          "type": "text",
          "not_null": true,
          "default": null
        },
        {
          "name": "declaration_id",
          "type": "uuid",
          "not_null": false,
          "default": null
        },
        {
          "name": "created_at",
          "type": "timestamp with time zone",
          "not_null": true,
          "default": "clock_timestamp()"
        }
      ]
    },
    {
      "name": "combat_panel_private.cure_staff_profiles_v1",
      "columns": [
        {
          "name": "actor_id",
          "type": "uuid",
          "not_null": true,
          "default": null
        },
        {
          "name": "session_id",
          "type": "uuid",
          "not_null": true,
          "default": null
        },
        {
          "name": "context_id",
          "type": "uuid",
          "not_null": true,
          "default": null
        },
        {
          "name": "controller_user",
          "type": "uuid",
          "not_null": true,
          "default": null
        },
        {
          "name": "controller_version",
          "type": "bigint",
          "not_null": true,
          "default": null
        },
        {
          "name": "ability",
          "type": "jsonb",
          "not_null": true,
          "default": null
        },
        {
          "name": "proof_sha256",
          "type": "text",
          "not_null": true,
          "default": null
        },
        {
          "name": "request_key",
          "type": "uuid",
          "not_null": true,
          "default": null
        },
        {
          "name": "created_at",
          "type": "timestamp with time zone",
          "not_null": true,
          "default": "clock_timestamp()"
        }
      ]
    },
    {
      "name": "combat_panel_private.cure_voluntary_actions_v1",
      "columns": [
        {
          "name": "actor_id",
          "type": "uuid",
          "not_null": true,
          "default": null
        },
        {
          "name": "round_id",
          "type": "uuid",
          "not_null": true,
          "default": null
        },
        {
          "name": "source_kind",
          "type": "text",
          "not_null": true,
          "default": null
        },
        {
          "name": "source_key",
          "type": "text",
          "not_null": true,
          "default": null
        },
        {
          "name": "created_at",
          "type": "timestamp with time zone",
          "not_null": true,
          "default": "clock_timestamp()"
        }
      ]
    },
    {
      "name": "combat_v2_genjutsu_internal.effects",
      "columns": [
        {
          "name": "id",
          "type": "uuid",
          "not_null": true,
          "default": "gen_random_uuid()"
        },
        {
          "name": "session_id",
          "type": "uuid",
          "not_null": true,
          "default": null
        },
        {
          "name": "source_declaration_id",
          "type": "uuid",
          "not_null": true,
          "default": null
        },
        {
          "name": "source_attack_target_id",
          "type": "uuid",
          "not_null": true,
          "default": null
        },
        {
          "name": "source_actor_id",
          "type": "uuid",
          "not_null": true,
          "default": null
        },
        {
          "name": "target_actor_id",
          "type": "uuid",
          "not_null": true,
          "default": null
        },
        {
          "name": "profile",
          "type": "jsonb",
          "not_null": true,
          "default": null
        },
        {
          "name": "source_outcome_sha256",
          "type": "text",
          "not_null": true,
          "default": null
        },
        {
          "name": "adapter",
          "type": "text",
          "not_null": true,
          "default": null
        },
        {
          "name": "excluded_turn_id",
          "type": "uuid",
          "not_null": false,
          "default": null
        },
        {
          "name": "due_turn_id",
          "type": "uuid",
          "not_null": false,
          "default": null
        },
        {
          "name": "state",
          "type": "text",
          "not_null": true,
          "default": null
        },
        {
          "name": "state_version",
          "type": "bigint",
          "not_null": true,
          "default": "1"
        },
        {
          "name": "created_at",
          "type": "timestamp with time zone",
          "not_null": true,
          "default": "clock_timestamp()"
        },
        {
          "name": "ended_at",
          "type": "timestamp with time zone",
          "not_null": false,
          "default": null
        },
        {
          "name": "end_reason",
          "type": "text",
          "not_null": false,
          "default": null
        }
      ]
    },
    {
      "name": "combat_v2_genjutsu_internal.events",
      "columns": [
        {
          "name": "event_key",
          "type": "text",
          "not_null": true,
          "default": null
        },
        {
          "name": "effect_id",
          "type": "uuid",
          "not_null": false,
          "default": null
        },
        {
          "name": "result",
          "type": "jsonb",
          "not_null": true,
          "default": null
        },
        {
          "name": "result_sha256",
          "type": "text",
          "not_null": true,
          "default": null
        },
        {
          "name": "binding",
          "type": "jsonb",
          "not_null": true,
          "default": null
        },
        {
          "name": "binding_sha256",
          "type": "text",
          "not_null": true,
          "default": null
        },
        {
          "name": "created_at",
          "type": "timestamp with time zone",
          "not_null": true,
          "default": "clock_timestamp()"
        }
      ]
    },
    {
      "name": "combat_v2_genjutsu_internal.gate",
      "columns": [
        {
          "name": "singleton",
          "type": "boolean",
          "not_null": true,
          "default": null
        },
        {
          "name": "enabled",
          "type": "boolean",
          "not_null": true,
          "default": null
        },
        {
          "name": "staff_enabled",
          "type": "boolean",
          "not_null": true,
          "default": null
        },
        {
          "name": "public_enabled",
          "type": "boolean",
          "not_null": true,
          "default": null
        },
        {
          "name": "version",
          "type": "integer",
          "not_null": true,
          "default": null
        }
      ]
    },
    {
      "name": "combat_v2_genjutsu_internal.preparations",
      "columns": [
        {
          "name": "actor_id",
          "type": "uuid",
          "not_null": true,
          "default": null
        },
        {
          "name": "round_id",
          "type": "uuid",
          "not_null": true,
          "default": null
        },
        {
          "name": "request_id",
          "type": "uuid",
          "not_null": true,
          "default": null
        },
        {
          "name": "transaction_id",
          "type": "bigint",
          "not_null": true,
          "default": null
        },
        {
          "name": "source",
          "type": "jsonb",
          "not_null": true,
          "default": null
        },
        {
          "name": "source_sha256",
          "type": "text",
          "not_null": true,
          "default": null
        }
      ]
    },
    {
      "name": "combat_v2_genjutsu_internal.release_plans",
      "columns": [
        {
          "name": "actor_id",
          "type": "uuid",
          "not_null": true,
          "default": null
        },
        {
          "name": "round_id",
          "type": "uuid",
          "not_null": true,
          "default": null
        },
        {
          "name": "request_id",
          "type": "uuid",
          "not_null": true,
          "default": null
        },
        {
          "name": "effect_id",
          "type": "uuid",
          "not_null": true,
          "default": null
        },
        {
          "name": "source",
          "type": "jsonb",
          "not_null": true,
          "default": null
        },
        {
          "name": "source_sha256",
          "type": "text",
          "not_null": true,
          "default": null
        },
        {
          "name": "transaction_id",
          "type": "bigint",
          "not_null": true,
          "default": null
        },
        {
          "name": "declaration_id",
          "type": "uuid",
          "not_null": false,
          "default": null
        },
        {
          "name": "declaration_sha256",
          "type": "text",
          "not_null": false,
          "default": null
        },
        {
          "name": "result",
          "type": "jsonb",
          "not_null": false,
          "default": null
        },
        {
          "name": "result_sha256",
          "type": "text",
          "not_null": false,
          "default": null
        }
      ]
    },
    {
      "name": "combat_v2_genjutsu_internal.sources",
      "columns": [
        {
          "name": "declaration_id",
          "type": "uuid",
          "not_null": true,
          "default": null
        },
        {
          "name": "session_id",
          "type": "uuid",
          "not_null": true,
          "default": null
        },
        {
          "name": "source",
          "type": "jsonb",
          "not_null": true,
          "default": null
        },
        {
          "name": "declaration_sha256",
          "type": "text",
          "not_null": true,
          "default": null
        },
        {
          "name": "source_sha256",
          "type": "text",
          "not_null": true,
          "default": null
        }
      ]
    },
    {
      "name": "combat_v2_genjutsu_internal.staff_receipts",
      "columns": [
        {
          "name": "actor_id",
          "type": "uuid",
          "not_null": true,
          "default": null
        },
        {
          "name": "session_id",
          "type": "uuid",
          "not_null": true,
          "default": null
        },
        {
          "name": "controller_user",
          "type": "uuid",
          "not_null": true,
          "default": null
        },
        {
          "name": "controller_version",
          "type": "bigint",
          "not_null": true,
          "default": null
        },
        {
          "name": "request_id",
          "type": "uuid",
          "not_null": true,
          "default": null
        },
        {
          "name": "receipt",
          "type": "jsonb",
          "not_null": true,
          "default": null
        },
        {
          "name": "receipt_sha256",
          "type": "text",
          "not_null": true,
          "default": null
        }
      ]
    }
  ],
  "triggers": [
    {
      "table": "clan_akimichi_private.form_commands",
      "name": "cure_voluntary_receipt_v1",
      "function": "combat_panel_private.cure_voluntary_receipt_guard_v1()",
      "type": 7
    },
    {
      "table": "clan_hoki_private.combat_events",
      "name": "cure_voluntary_receipt_v1",
      "function": "combat_panel_private.cure_voluntary_receipt_guard_v1()",
      "type": 7
    },
    {
      "table": "clan_innata_combat_private.combat_receipts",
      "name": "cure_voluntary_receipt_v1",
      "function": "combat_panel_private.cure_voluntary_receipt_guard_v1()",
      "type": 7
    },
    {
      "table": "clan_inuzuka_private.movement_receipts",
      "name": "cure_voluntary_receipt_v1",
      "function": "combat_panel_private.cure_voluntary_receipt_guard_v1()",
      "type": 7
    },
    {
      "table": "clan_marionettisti_private.control_events",
      "name": "cure_voluntary_receipt_v1",
      "function": "combat_panel_private.cure_voluntary_receipt_guard_v1()",
      "type": 7
    },
    {
      "table": "clan_marionettisti_private.movement_receipts",
      "name": "cure_voluntary_receipt_v1",
      "function": "combat_panel_private.cure_voluntary_receipt_guard_v1()",
      "type": 7
    },
    {
      "table": "clan_sabaku_private.armor_events",
      "name": "cure_voluntary_receipt_v1",
      "function": "combat_panel_private.cure_voluntary_receipt_guard_v1()",
      "type": 7
    },
    {
      "table": "combat_panel_private.master_movement_receipts",
      "name": "cure_voluntary_receipt_v1",
      "function": "combat_panel_private.cure_voluntary_receipt_guard_v1()",
      "type": 7
    },
    {
      "table": "combat_panel_private.request_receipts",
      "name": "cure_voluntary_receipt_v1",
      "function": "combat_panel_private.cure_voluntary_receipt_guard_v1()",
      "type": 7
    },
    {
      "table": "public.combat_v2_declarations",
      "name": "cure_turn_defense_guard_v1",
      "function": "combat_panel_private.cure_defense_guard_v1()",
      "type": 7
    }
  ],
  "edge_expected_files": [
    {
      "name": "adattatore.ts",
      "bytes": 19495,
      "sha256": "32bf2b017f70f2b3733992d99ca868405a812c35f725c64cf66adb4f5ebc851d"
    },
    {
      "name": "common.mjs",
      "bytes": 8305,
      "sha256": "c73d6fa04bf22c521b502387adb261c599996e58f309ddb3b5a64dd3f56e6cc4"
    },
    {
      "name": "count.mjs",
      "bytes": 4494,
      "sha256": "77791e0fa712967ba7818dee45964af6e4cda1673e1f4673c0238ff387ee335f"
    },
    {
      "name": "diagnostics.ts",
      "bytes": 2964,
      "sha256": "5846012ec1d57cffa8a54b17dd7a3efe61a91971cdf2b97f8afe67220ebba5ce"
    },
    {
      "name": "editorial.mjs",
      "bytes": 7802,
      "sha256": "8d6c00b9ebc16bfff9f17c7e9670292397f266b24f4664d299c5a3e58d692766"
    },
    {
      "name": "facts.ts",
      "bytes": 27653,
      "sha256": "7ef1d1842994e161c07eea7176bde7acc5eed8341ea71534f883d05affa23150"
    },
    {
      "name": "flow.mjs",
      "bytes": 5332,
      "sha256": "ceefabdb6bd9e3cfe7e85c31b4a3805f76fbf7dae11ab0ad51994e9deff7722d"
    },
    {
      "name": "index.ts",
      "bytes": 71473,
      "sha256": "c02e347b84556199dd883cb59e5057ff2803ff3da29d0c01e0899ba82fe6d2c3"
    },
    {
      "name": "lifecycle.mjs",
      "bytes": 7147,
      "sha256": "5f7299124083a5b57ce75e6fb0b917fb6cabba0a369a2d78649e31eb4ccb0d6c"
    },
    {
      "name": "orchestra.ts",
      "bytes": 1177,
      "sha256": "47134473ddf7153499f7ce6056b3f892af4166df86fd614cf94b4ff2d9ba4e0f"
    },
    {
      "name": "ordinary.ts",
      "bytes": 8946,
      "sha256": "456e734e9dd96858a44e5d86fb15d76acbff13a2727be64288fbff1601c9f502"
    },
    {
      "name": "recovery.ts",
      "bytes": 1081,
      "sha256": "dadcba58f18fac2aa6fba6f921a556c4653ddfa7eb6042feacd0c5e6dc554692"
    },
    {
      "name": "repertorio.json",
      "bytes": 14845,
      "sha256": "86b291f40f3baadb5fbe7e984e5f01e2fe910b7c645d1a77dd13a41970a4e37e"
    },
    {
      "name": "rinuncia.ts",
      "bytes": 3421,
      "sha256": "30832b9dd830dc32074fb5b96d6062811520cc73169d629e3c08f8dd1b00a421"
    },
    {
      "name": "runtime.ts",
      "bytes": 9292,
      "sha256": "c49dba1ff22b2d4d507b8e1a446319fd03f1ddd82cc1555494f6b638d991ec2e"
    },
    {
      "name": "scene.mjs",
      "bytes": 7517,
      "sha256": "f4cfa79821a27ac026960fde6460bd8562f8ec527698e3a3290004018d9d5301"
    },
    {
      "name": "transport.ts",
      "bytes": 4913,
      "sha256": "590d7e2e2d289d904ea1015049e0723236634dcce7c306ef651b125219f8ad1f"
    },
    {
      "name": "user_test.mjs",
      "bytes": 3238,
      "sha256": "26b1a843cd9470c173f4a0c0a259013cd08b58a3482b699fe7af5daec18be9ba"
    }
  ],
  "baseline_edge_files": [
    {
      "name": "adattatore.ts",
      "bytes": 19495,
      "sha256": "32bf2b017f70f2b3733992d99ca868405a812c35f725c64cf66adb4f5ebc851d"
    },
    {
      "name": "common.mjs",
      "bytes": 8305,
      "sha256": "c73d6fa04bf22c521b502387adb261c599996e58f309ddb3b5a64dd3f56e6cc4"
    },
    {
      "name": "count.mjs",
      "bytes": 4494,
      "sha256": "77791e0fa712967ba7818dee45964af6e4cda1673e1f4673c0238ff387ee335f"
    },
    {
      "name": "diagnostics.ts",
      "bytes": 2964,
      "sha256": "5846012ec1d57cffa8a54b17dd7a3efe61a91971cdf2b97f8afe67220ebba5ce"
    },
    {
      "name": "editorial.mjs",
      "bytes": 7672,
      "sha256": "b1a16910eabecdf5dc73e1d8ddf956dd4dc46954dce471ea5e687731b02251c8"
    },
    {
      "name": "facts.ts",
      "bytes": 15258,
      "sha256": "4af6be7e1b7bd548169dd6f630ae2be0ae95812e1c431b2737e2e66764774c72"
    },
    {
      "name": "flow.mjs",
      "bytes": 5332,
      "sha256": "ceefabdb6bd9e3cfe7e85c31b4a3805f76fbf7dae11ab0ad51994e9deff7722d"
    },
    {
      "name": "index.ts",
      "bytes": 71473,
      "sha256": "c02e347b84556199dd883cb59e5057ff2803ff3da29d0c01e0899ba82fe6d2c3"
    },
    {
      "name": "lifecycle.mjs",
      "bytes": 7147,
      "sha256": "5f7299124083a5b57ce75e6fb0b917fb6cabba0a369a2d78649e31eb4ccb0d6c"
    },
    {
      "name": "orchestra.ts",
      "bytes": 1177,
      "sha256": "47134473ddf7153499f7ce6056b3f892af4166df86fd614cf94b4ff2d9ba4e0f"
    },
    {
      "name": "ordinary.ts",
      "bytes": 8921,
      "sha256": "a2887cc35072944b68d6863f867c0eab78278dc945fc84edbb0beea8938125b9"
    },
    {
      "name": "recovery.ts",
      "bytes": 1081,
      "sha256": "dadcba58f18fac2aa6fba6f921a556c4653ddfa7eb6042feacd0c5e6dc554692"
    },
    {
      "name": "repertorio.json",
      "bytes": 14845,
      "sha256": "86b291f40f3baadb5fbe7e984e5f01e2fe910b7c645d1a77dd13a41970a4e37e"
    },
    {
      "name": "rinuncia.ts",
      "bytes": 3421,
      "sha256": "30832b9dd830dc32074fb5b96d6062811520cc73169d629e3c08f8dd1b00a421"
    },
    {
      "name": "runtime.ts",
      "bytes": 9292,
      "sha256": "c49dba1ff22b2d4d507b8e1a446319fd03f1ddd82cc1555494f6b638d991ec2e"
    },
    {
      "name": "scene.mjs",
      "bytes": 7517,
      "sha256": "f4cfa79821a27ac026960fde6460bd8562f8ec527698e3a3290004018d9d5301"
    },
    {
      "name": "transport.ts",
      "bytes": 4913,
      "sha256": "590d7e2e2d289d904ea1015049e0723236634dcce7c306ef651b125219f8ad1f"
    },
    {
      "name": "user_test.mjs",
      "bytes": 3238,
      "sha256": "26b1a843cd9470c173f4a0c0a259013cd08b58a3482b699fe7af5daec18be9ba"
    }
  ],
  "edge_receipt": {
    "name": "combat_narratore_ai",
    "status": "ACTIVE",
    "version": 45,
    "verify_jwt": false,
    "baseline_version": 44,
    "baseline_ezbr_sha256": "50e0173983134aa94687408d51c7026d6ad1c64f8e0c474424aedaf653ecc028",
    "ezbr_sha256": "79bdb113f0203e5b0578a1211fb43f1c5cfb6b3bb5585714b4d9b5475ce27a11",
    "readback_verified": true,
    "files": [
      {
        "name": "adattatore.ts",
        "bytes": 19495,
        "sha256": "32bf2b017f70f2b3733992d99ca868405a812c35f725c64cf66adb4f5ebc851d"
      },
      {
        "name": "common.mjs",
        "bytes": 8305,
        "sha256": "c73d6fa04bf22c521b502387adb261c599996e58f309ddb3b5a64dd3f56e6cc4"
      },
      {
        "name": "count.mjs",
        "bytes": 4494,
        "sha256": "77791e0fa712967ba7818dee45964af6e4cda1673e1f4673c0238ff387ee335f"
      },
      {
        "name": "diagnostics.ts",
        "bytes": 2964,
        "sha256": "5846012ec1d57cffa8a54b17dd7a3efe61a91971cdf2b97f8afe67220ebba5ce"
      },
      {
        "name": "editorial.mjs",
        "bytes": 7802,
        "sha256": "8d6c00b9ebc16bfff9f17c7e9670292397f266b24f4664d299c5a3e58d692766"
      },
      {
        "name": "facts.ts",
        "bytes": 27653,
        "sha256": "7ef1d1842994e161c07eea7176bde7acc5eed8341ea71534f883d05affa23150"
      },
      {
        "name": "flow.mjs",
        "bytes": 5332,
        "sha256": "ceefabdb6bd9e3cfe7e85c31b4a3805f76fbf7dae11ab0ad51994e9deff7722d"
      },
      {
        "name": "index.ts",
        "bytes": 71473,
        "sha256": "c02e347b84556199dd883cb59e5057ff2803ff3da29d0c01e0899ba82fe6d2c3"
      },
      {
        "name": "lifecycle.mjs",
        "bytes": 7147,
        "sha256": "5f7299124083a5b57ce75e6fb0b917fb6cabba0a369a2d78649e31eb4ccb0d6c"
      },
      {
        "name": "orchestra.ts",
        "bytes": 1177,
        "sha256": "47134473ddf7153499f7ce6056b3f892af4166df86fd614cf94b4ff2d9ba4e0f"
      },
      {
        "name": "ordinary.ts",
        "bytes": 8946,
        "sha256": "456e734e9dd96858a44e5d86fb15d76acbff13a2727be64288fbff1601c9f502"
      },
      {
        "name": "recovery.ts",
        "bytes": 1081,
        "sha256": "dadcba58f18fac2aa6fba6f921a556c4653ddfa7eb6042feacd0c5e6dc554692"
      },
      {
        "name": "repertorio.json",
        "bytes": 14845,
        "sha256": "86b291f40f3baadb5fbe7e984e5f01e2fe910b7c645d1a77dd13a41970a4e37e"
      },
      {
        "name": "rinuncia.ts",
        "bytes": 3421,
        "sha256": "30832b9dd830dc32074fb5b96d6062811520cc73169d629e3c08f8dd1b00a421"
      },
      {
        "name": "runtime.ts",
        "bytes": 9292,
        "sha256": "c49dba1ff22b2d4d507b8e1a446319fd03f1ddd82cc1555494f6b638d991ec2e"
      },
      {
        "name": "scene.mjs",
        "bytes": 7517,
        "sha256": "f4cfa79821a27ac026960fde6460bd8562f8ec527698e3a3290004018d9d5301"
      },
      {
        "name": "transport.ts",
        "bytes": 4913,
        "sha256": "590d7e2e2d289d904ea1015049e0723236634dcce7c306ef651b125219f8ad1f"
      },
      {
        "name": "user_test.mjs",
        "bytes": 3238,
        "sha256": "26b1a843cd9470c173f4a0c0a259013cd08b58a3482b699fe7af5daec18be9ba"
      }
    ],
    "scene_contract": "Scene1",
    "scene_contract_changed": false,
    "receipt_ref": "management/candidati/COMBAT-COMPOSITE_2026-09-01/candidato/catalogo_completo/RUNTIME_REVIEW.json#edge_actual_deployment_receipt/raw_utf8",
    "receipt_sha256": "e6d0b09b9f31dbd889fb0b88f64e31f491d9b94d08e4771276c4b543316674e5"
  },
  "source_bundle_sha256": "825a1c14a59281fb3168430a993e9f2dbbbc41042f5169638d2e9c1e8e9868a5",
  "baseline_custody": {
    "ref": "management/candidati/COMBAT-COMPOSITE_2026-09-01/candidato/catalogo_completo/RUNTIME_BASELINE.json#root/canonical_preimage",
    "sha256": "73712255c70f9560614d1e602bd770b3937138e3f383f636c1aa7f791ea6d335"
  },
  "compatibility": {
    "ref": "management/candidati/COMBAT-COMPOSITE_2026-09-01/candidato/catalogo_completo/RUNTIME_REVIEW.json#final_bundle_template_reviews/review_final_bundle_counter1.json/raw_utf8",
    "sha256": "4cc2c55a3dfc338d53af7b13c8a33beab6d7a6ba374e99890659615e1f364d51",
    "scope": "existing_mission_capabilities_only",
    "new_techniques_staff_pass": false
  },
  "review": {
    "ref": "management/candidati/COMBAT-COMPOSITE_2026-09-01/candidato/catalogo_completo/RUNTIME_REVIEW.json#root_normalized_capsule_review/raw_utf8",
    "sha256": "5b53b276bb80a4e4ddbe404d6b74f24ad58e738a8f3e229761d2df8b2548fdf2",
    "P0": 0,
    "P1": 0,
    "P2": 0
  }
}
$cc_final_params$::jsonb;r record;item jsonb;
BEGIN
 IF current_user<>'postgres' OR session_user<>'postgres' OR auth.uid() IS NOT NULL THEN
  RAISE EXCEPTION 'CC_OPERATOR_REQUIRED';END IF;
 PERFORM set_config('search_path','',true);
 IF NOT pg_try_advisory_xact_lock(hashtextextended('C1266:GENERIC-AI:AVAILABILITY',0)) THEN
  RAISE EXCEPTION 'CC_AVAILABILITY_BUSY';END IF;
 SELECT * INTO STRICT r FROM mission_factory_owner.editor_release_readiness WHERE singleton FOR UPDATE NOWAIT;
 IF r.revision_sha256<>'73712255c70f9560614d1e602bd770b3937138e3f383f636c1aa7f791ea6d335'
 OR r.observed_revision_sha256 IS DISTINCT FROM r.revision_sha256
 OR public.combat_v2_sha256(to_jsonb(r))<>'22028c166794c52118ec79f8cf7e741e012d0b227555ffb317ab709f60d081c5'
 THEN RAISE EXCEPTION 'CC_ROOT_BASELINE_DRIFT';END IF;
 IF EXISTS(SELECT 1 FROM public.combat_v2_sessions WHERE state='in_corso' AND closed_at IS NULL)
 OR EXISTS(SELECT 1 FROM public.master_v2_sessions WHERE stato NOT IN('chiusa','annullata') AND closed_at IS NULL) THEN
  RAISE EXCEPTION 'CC_REQUIRES_QUIESCENCE';END IF;
 IF to_regnamespace('combat_v2_genjutsu_internal') IS NOT NULL THEN RAISE EXCEPTION 'CC_NEW_SCHEMA_COLLISION';END IF;
 FOR item IN SELECT value FROM jsonb_array_elements(params->'private_functions') LOOP
  IF to_regprocedure(item->>'signature') IS NOT NULL THEN RAISE EXCEPTION 'CC_NEW_FUNCTION_COLLISION:%',item->>'signature';END IF;
 END LOOP;
 FOR item IN SELECT value FROM jsonb_array_elements(params->'relations') LOOP
  IF to_regclass(item->>'name') IS NOT NULL THEN RAISE EXCEPTION 'CC_NEW_RELATION_COLLISION:%',item->>'name';END IF;
 END LOOP;
 PERFORM set_config('app.catalogo_footer_parameters',params::text,true);
END $cc_preflight$;

-- COMPONENT: paralisi_private
-- PARALISI/1 + lifecycle-report/1 · SOURCE ONLY. No execution authorization is implied.
-- Shared core/Root hooks are composed only by PM from paralisi_contract.md.
-- This file creates private adapter functions, never public RPC/character grants.
DO $guard$
BEGIN
 IF to_regnamespace('combat_v2_genjutsu_internal') IS NOT NULL THEN
  RAISE EXCEPTION 'paralisi_namespace_already_exists';
 END IF;
 IF NOT EXISTS(SELECT 1 FROM public.clan_techniques WHERE id='31d5d554-44d1-4042-9920-3ddd3bedff7e'::uuid
  AND is_active AND uso='principale' AND disciplina='Genjutsu' AND grado='C'
  AND chakra_cost=10 AND danno_base=0 AND potenza=20 AND gittata='corta') THEN
  RAISE EXCEPTION 'paralisi_catalog_baseline_drift';
 END IF;
END $guard$;
CREATE SCHEMA combat_v2_genjutsu_internal AUTHORIZATION postgres;
REVOKE ALL ON SCHEMA combat_v2_genjutsu_internal FROM PUBLIC,anon,authenticated,service_role;
CREATE TABLE combat_v2_genjutsu_internal.gate(
 singleton boolean PRIMARY KEY CHECK(singleton),enabled boolean NOT NULL,staff_enabled boolean NOT NULL,
 public_enabled boolean NOT NULL CHECK(NOT public_enabled OR enabled),version integer NOT NULL CHECK(version=1));
INSERT INTO combat_v2_genjutsu_internal.gate VALUES(true,true,true,false,1);
CREATE TABLE combat_v2_genjutsu_internal.staff_receipts(
 actor_id uuid NOT NULL REFERENCES public.combat_v2_actors(id),session_id uuid NOT NULL REFERENCES public.combat_v2_sessions(id),
 controller_user uuid NOT NULL,controller_version bigint NOT NULL,request_id uuid NOT NULL,receipt jsonb NOT NULL,
 receipt_sha256 text NOT NULL CHECK(receipt_sha256 ~ '^[0-9a-f]{64}$'),
 PRIMARY KEY(actor_id,controller_version),UNIQUE(actor_id,request_id));
CREATE TABLE combat_v2_genjutsu_internal.preparations(
 actor_id uuid NOT NULL REFERENCES public.combat_v2_actors(id),round_id uuid NOT NULL REFERENCES public.combat_v2_rounds(id),
 request_id uuid NOT NULL,transaction_id bigint NOT NULL,source jsonb NOT NULL CHECK(jsonb_typeof(source)='object'),
 source_sha256 text NOT NULL CHECK(source_sha256 ~ '^[0-9a-f]{64}$'),PRIMARY KEY(actor_id,round_id,request_id));
CREATE TABLE combat_v2_genjutsu_internal.sources(
 declaration_id uuid PRIMARY KEY REFERENCES public.combat_v2_declarations(id),
 session_id uuid NOT NULL REFERENCES public.combat_v2_sessions(id),source jsonb NOT NULL,
 declaration_sha256 text NOT NULL CHECK(declaration_sha256 ~ '^[0-9a-f]{64}$'),
 source_sha256 text NOT NULL CHECK(source_sha256 ~ '^[0-9a-f]{64}$'));
CREATE TABLE combat_v2_genjutsu_internal.effects(
 id uuid PRIMARY KEY DEFAULT gen_random_uuid(),session_id uuid NOT NULL REFERENCES public.combat_v2_sessions(id),
 source_declaration_id uuid NOT NULL REFERENCES combat_v2_genjutsu_internal.sources(declaration_id),
 source_attack_target_id uuid NOT NULL UNIQUE REFERENCES public.combat_v2_attack_targets(id),
 source_actor_id uuid NOT NULL REFERENCES public.combat_v2_actors(id),target_actor_id uuid NOT NULL REFERENCES public.combat_v2_actors(id),
 profile jsonb NOT NULL,source_outcome_sha256 text NOT NULL CHECK(source_outcome_sha256 ~ '^[0-9a-f]{64}$'),
 adapter text NOT NULL CHECK(adapter IN('ordinary_v2','master_v2')),excluded_turn_id uuid,due_turn_id uuid,
 state text NOT NULL CHECK(state IN('pending','active','expired','ended')),state_version bigint NOT NULL DEFAULT 1 CHECK(state_version>0),
 created_at timestamptz NOT NULL DEFAULT clock_timestamp(),ended_at timestamptz,end_reason text,
 CHECK(due_turn_id IS NULL OR due_turn_id IS DISTINCT FROM excluded_turn_id));
CREATE TABLE combat_v2_genjutsu_internal.events(
 event_key text PRIMARY KEY,effect_id uuid REFERENCES combat_v2_genjutsu_internal.effects(id),
 result jsonb NOT NULL,result_sha256 text NOT NULL CHECK(result_sha256 ~ '^[0-9a-f]{64}$'),
 binding jsonb NOT NULL CHECK(jsonb_typeof(binding)='object'),binding_sha256 text NOT NULL CHECK(binding_sha256 ~ '^[0-9a-f]{64}$'),
 created_at timestamptz NOT NULL DEFAULT clock_timestamp());

CREATE FUNCTION combat_v2_genjutsu_internal.profile() RETURNS jsonb LANGUAGE sql IMMUTABLE SET search_path='' AS $f$
 SELECT '{"schema_version":"paralisi-movement/1","catalog_technique_id":"31d5d554-44d1-4042-9920-3ddd3bedff7e","source":"clan","id":"31d5d554-44d1-4042-9920-3ddd3bedff7e","name":"Paralisi illusoria","kind":"genjutsu","usage":"principale","defensive":false,"di_scena":false,"diversivo":false,"consumption_type":"ad_utilizzo","rank":"C","range":"corta","range_m":10,"chakra_cost":10,"damage_base":0,"power":20,"requires_seals":true,"element":null,"genjutsu_profile_version":"paralisi-movement/1","effect":{"kind":"movement_block","duration":"next_target_personal_turn","main_action_blocked":false,"reactions_blocked":false,"damage_policy":"NO_HP_DAMAGE","stacking":"no_stack_no_refresh"},"description":"Su confronto mentale riuscito impedisce il movimento nel prossimo turno personale del bersaglio; azione principale e difese restano disponibili.","limits":"Un solo bersaglio PG, nessun danno PV. Prima disponibilità soltanto Staff. Non è una presa fisica."}'::jsonb
$f$;
CREATE FUNCTION combat_v2_genjutsu_internal.scope(p_actor uuid) RETURNS boolean LANGUAGE sql STABLE SECURITY DEFINER SET search_path='' AS $f$
 SELECT EXISTS(SELECT 1 FROM public.combat_v2_actors a
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
  AND m.stato='in_corso' AND m.closed_at IS NULL AND m.suspended_at IS NULL AND mp.policy_id='staff_test_no_persistent_resources_v1')))
$f$;
CREATE FUNCTION combat_v2_genjutsu_internal.runtime_allowed(p_actor uuid) RETURNS boolean LANGUAGE sql STABLE SECURITY DEFINER SET search_path='' AS $f$
 SELECT EXISTS(SELECT 1 FROM public.combat_v2_actors a
 JOIN public.combat_v2_sessions s ON s.id=a.session_id
 JOIN public.locations l ON l.id=s.location_id
 JOIN combat_v2_genjutsu_internal.gate g ON g.singleton
 JOIN public.characters ch ON ch.id=a.character_id AND ch.user_id=a.controller_user
 LEFT JOIN combat_consumer_private.activities ca ON ca.session_id=s.id
 LEFT JOIN combat_panel_private.master_panel_sessions mp ON mp.master_session_id=s.master_session_id
 LEFT JOIN public.master_v2_sessions m ON m.id=s.master_session_id
 WHERE a.id=p_actor AND a.actor_kind='pg' AND a.companion_id IS NULL AND a.state='attivo'
 AND a.controller_user IS NOT NULL AND s.state='in_corso' AND s.closed_at IS NULL AND g.enabled
 AND CASE WHEN s.location_id='0b85f354-9cdb-47e1-baf9-3d266bb7e06b'::uuid
  THEN combat_v2_genjutsu_internal.scope(a.id)
 ELSE g.public_enabled AND s.user_test_context_id IS NULL
  AND l.is_active AND l.is_test IS FALSE
  AND public.combat_v2_values_written(s.id) IS TRUE AND NOT combat_panel_private.uses_simulated_pools(s.id)
  AND NOT EXISTS(SELECT 1 FROM public.mission_run_state ms WHERE ms.master_session_id=s.master_session_id)
  AND NOT EXISTS(SELECT 1 FROM combat_consumer_private.narrative_authorities na WHERE na.master_session_id=s.master_session_id)
  AND NOT EXISTS(SELECT 1 FROM exam_regia_private.bindings b WHERE b.combat_session_id=s.id)
  AND NOT EXISTS(SELECT 1 FROM exam_human_private.native_bindings b WHERE b.master_session_id=s.master_session_id)
  AND NOT EXISTS(SELECT 1 FROM mission_factory_owner.quest_run_sources q WHERE q.session_id=s.master_session_id)
  AND ((s.source_kind='ordinary' AND s.master_session_id IS NULL AND ca.user_test_context_id IS NULL
   AND ca.phase NOT IN('setup','closed','suspended') AND ca.policy_id='free_duel_nonlethal_real_resources_v1'
   AND EXISTS(SELECT 1 FROM combat_consumer_private.members cm WHERE cm.session_id=s.id AND cm.actor_id=a.id AND cm.character_id=a.character_id))
  OR(s.source_kind='master' AND m.owner_kind='human' AND m.tipo='duello' AND m.mission_id IS NULL AND m.quest_kind IS NULL
   AND m.stato='in_corso' AND m.closed_at IS NULL AND m.suspended_at IS NULL AND mp.policy_id='master_game_resources_v1'))
 END)
$f$;
CREATE FUNCTION combat_v2_genjutsu_internal.real_owned(p_actor uuid) RETURNS boolean LANGUAGE sql STABLE SECURITY DEFINER SET search_path='' AS $f$
 SELECT EXISTS(SELECT 1 FROM public.combat_v2_actors a JOIN public.characters ch ON ch.id=a.character_id AND ch.user_id=a.controller_user
 JOIN public.character_abilities ca ON ca.character_id=ch.id AND ca.technique_id='31d5d554-44d1-4042-9920-3ddd3bedff7e'::uuid AND ca.state='attiva'
 JOIN public.clan_techniques t ON t.id=ca.technique_id AND t.is_active AND t.uso='principale' AND t.disciplina='Genjutsu'
 WHERE a.id=p_actor AND a.actor_kind='pg' AND a.companion_id IS NULL AND public._grade_rank(ch.rank)>=public._grade_rank('Genin')
 AND ch.genjutsu>=25 AND jsonb_typeof(a.mechanics_snapshot->'genjutsu')='number' AND (a.mechanics_snapshot->>'genjutsu')::numeric>=25
 AND EXISTS(SELECT 1 FROM jsonb_array_elements(coalesce(a.mechanics_snapshot->'abilities','[]')) x
  WHERE x->>'source'='clan' AND x->>'id'='31d5d554-44d1-4042-9920-3ddd3bedff7e'))
$f$;
CREATE FUNCTION combat_v2_genjutsu_internal.binding(p_actor uuid) RETURNS jsonb LANGUAGE sql STABLE SECURITY DEFINER SET search_path='' AS $f$
 SELECT r.receipt FROM combat_v2_genjutsu_internal.staff_receipts r JOIN public.combat_v2_actors a ON a.id=r.actor_id
 WHERE a.id=p_actor AND combat_v2_genjutsu_internal.scope(a.id) AND r.session_id=a.session_id
 AND r.controller_user=a.controller_user AND r.controller_version=a.controller_version
 AND r.receipt_sha256=public.combat_v2_sha256(r.receipt)
 AND r.receipt->'ability'=combat_v2_genjutsu_internal.profile()
 AND EXISTS(SELECT 1 FROM jsonb_array_elements(coalesce(a.mechanics_snapshot->'abilities','[]')) x WHERE x=r.receipt->'ability')
$f$;
CREATE FUNCTION combat_v2_genjutsu_internal.preset_ready(p_actor uuid) RETURNS boolean LANGUAGE plpgsql STABLE SECURITY DEFINER SET search_path='' AS $f$
DECLARE a public.combat_v2_actors%ROWTYPE;c jsonb;
BEGIN
 SELECT * INTO a FROM public.combat_v2_actors WHERE id=p_actor AND controller_user=exam_regia_private.current_principal();
 IF a.id IS NULL OR NOT combat_v2_genjutsu_internal.scope(a.id) OR combat_v2_genjutsu_internal.binding(a.id) IS NOT NULL
  OR EXISTS(SELECT 1 FROM combat_v2_genjutsu_internal.staff_receipts WHERE actor_id=a.id AND controller_version=a.controller_version)
  OR clan_sabaku_private.narrative_pending(a.session_id) THEN RETURN false;END IF;
 c:=combat_effects_private.personal_turn(a.session_id,a.id);
 RETURN coalesce(c->>'useful'='true' AND jsonb_typeof(a.mechanics_snapshot->'genjutsu')='number'
  AND (a.mechanics_snapshot->>'genjutsu')::numeric>=25,false);
END $f$;
CREATE FUNCTION combat_v2_genjutsu_internal.staff_bind(p_actor uuid,p_request uuid) RETURNS jsonb LANGUAGE plpgsql SECURITY DEFINER SET search_path='' AS $f$
DECLARE a public.combat_v2_actors%ROWTYPE;old combat_v2_genjutsu_internal.staff_receipts%ROWTYPE;abilities jsonb;before_abilities jsonb;res jsonb;
BEGIN
 IF exam_regia_private.current_principal() IS NULL OR p_request IS NULL THEN RAISE EXCEPTION 'paralisi_auth_required' USING ERRCODE='42501';END IF;
 SELECT * INTO STRICT a FROM public.combat_v2_actors WHERE id=p_actor AND controller_user=exam_regia_private.current_principal();
 PERFORM combat_effects_private.lock_context(a.session_id);
 SELECT * INTO STRICT a FROM public.combat_v2_actors WHERE id=p_actor AND controller_user=exam_regia_private.current_principal() FOR UPDATE;
 IF NOT combat_v2_genjutsu_internal.scope(a.id) THEN RAISE EXCEPTION 'paralisi_staff_only' USING ERRCODE='42501';END IF;
 SELECT * INTO old FROM combat_v2_genjutsu_internal.staff_receipts WHERE actor_id=a.id AND request_id=p_request;
 IF FOUND THEN
  IF old.controller_version IS DISTINCT FROM a.controller_version OR combat_v2_genjutsu_internal.binding(a.id) IS NULL THEN
   RAISE EXCEPTION 'paralisi_binding_replay_conflict' USING ERRCODE='40001';END IF;
  RETURN old.receipt||jsonb_build_object('replayed',true);
 END IF;
 IF NOT combat_v2_genjutsu_internal.preset_ready(a.id) THEN RAISE EXCEPTION 'paralisi_preset_not_available' USING ERRCODE='42501';END IF;
 before_abilities:=coalesce(a.mechanics_snapshot->'abilities','[]');
 SELECT coalesce(jsonb_agg(value ORDER BY ord),'[]') INTO abilities FROM jsonb_array_elements(coalesce(a.mechanics_snapshot->'abilities','[]')) WITH ORDINALITY x(value,ord)
 WHERE value->>'source' IS DISTINCT FROM 'clan' OR value->>'id' IS DISTINCT FROM '31d5d554-44d1-4042-9920-3ddd3bedff7e';
 abilities:=abilities||jsonb_build_array(combat_v2_genjutsu_internal.profile());
 res:=jsonb_build_object('schema_version','paralisi-staff-binding/1','actor_id',a.id,'session_id',a.session_id,'controller_version',a.controller_version,
  'request_id',p_request,'ability',combat_v2_genjutsu_internal.profile(),'abilities_before',before_abilities,'abilities_after',abilities,'values_written',false,'statistics_changed',false,'main_action_consumed',false,'chakra_spent',0);
 INSERT INTO combat_v2_genjutsu_internal.staff_receipts VALUES(a.id,a.session_id,a.controller_user,a.controller_version,p_request,res,public.combat_v2_sha256(res));
 UPDATE public.combat_v2_actors SET mechanics_snapshot=jsonb_set(mechanics_snapshot,'{abilities}',abilities,true) WHERE id=a.id AND controller_version=a.controller_version;
 RETURN res||jsonb_build_object('replayed',false);
END $f$;
CREATE FUNCTION combat_v2_genjutsu_internal.actor_meta(p_actor uuid) RETURNS jsonb LANGUAGE plpgsql STABLE SECURITY DEFINER SET search_path='' AS $f$
DECLARE a public.combat_v2_actors%ROWTYPE;
BEGIN
 SELECT * INTO a FROM public.combat_v2_actors WHERE id=p_actor;
 IF a.id IS NULL OR NOT combat_v2_genjutsu_internal.runtime_allowed(a.id)
  OR (CASE WHEN combat_effects_private.staff_session_allowed(a.session_id) THEN combat_v2_genjutsu_internal.binding(a.id) IS NULL
     ELSE NOT combat_v2_genjutsu_internal.real_owned(a.id) END)
  OR jsonb_typeof(a.mechanics_snapshot->'genjutsu') IS DISTINCT FROM 'number'
  OR (a.mechanics_snapshot->>'genjutsu')::numeric<25 THEN RETURN NULL;END IF;
 RETURN combat_v2_genjutsu_internal.profile();
END $f$;
CREATE FUNCTION combat_v2_genjutsu_internal.quote(p_actor uuid) RETURNS jsonb LANGUAGE plpgsql STABLE SECURITY DEFINER SET search_path='' AS $f$
DECLARE a public.combat_v2_actors%ROWTYPE;q jsonb;reserved numeric;
BEGIN
 IF combat_v2_genjutsu_internal.actor_meta(p_actor) IS NULL THEN RETURN NULL;END IF;
 SELECT * INTO STRICT a FROM public.combat_v2_actors WHERE id=p_actor;
 q:=clan_hyuga_private.sedici_cost_quote(a.id,10);
 SELECT coalesce(sum((d.cost_snapshot->>'chakra')::numeric),0) INTO reserved FROM public.combat_v2_declarations d
 WHERE d.actor_id=a.id AND d.round_id=(clan_innata_private.combat_context(a.id)).exchange_id AND d.state NOT IN('risolta','superflua','annullata');
 IF jsonb_typeof(q->'total') IS DISTINCT FROM 'number' OR jsonb_typeof(a.mechanics_snapshot->'chakra') IS DISTINCT FROM 'number'
 OR (a.mechanics_snapshot->>'chakra')::numeric-reserved<(q->>'total')::numeric THEN RETURN NULL;END IF;
 RETURN q;
END $f$;
CREATE FUNCTION combat_v2_genjutsu_internal.prepare(p_round uuid,p_actor uuid,p_request uuid,p_intent jsonb) RETURNS jsonb LANGUAGE plpgsql SECURITY DEFINER SET search_path='' AS $f$
DECLARE a public.combat_v2_actors%ROWTYPE;pr combat_v2_genjutsu_internal.preparations%ROWTYPE;s jsonb;t uuid;
BEGIN
 IF p_request IS NULL OR exam_regia_private.current_principal() IS NULL THEN RAISE EXCEPTION 'paralisi_auth_required' USING ERRCODE='42501';END IF;
 SELECT * INTO STRICT a FROM public.combat_v2_actors WHERE id=p_actor AND controller_user=exam_regia_private.current_principal();
 PERFORM combat_effects_private.lock_context(a.session_id);
 PERFORM 1 FROM public.combat_v2_rounds WHERE id=p_round AND session_id=a.session_id AND phase='raccolta_azioni' FOR UPDATE;
 IF NOT FOUND THEN RAISE EXCEPTION 'paralisi_round_stale' USING ERRCODE='40001';END IF;
 SELECT * INTO STRICT a FROM public.combat_v2_actors WHERE id=p_actor AND controller_user=exam_regia_private.current_principal() FOR UPDATE;
 IF combat_v2_genjutsu_internal.quote(a.id) IS NULL THEN RAISE EXCEPTION 'paralisi_not_offered' USING ERRCODE='42501';END IF;
 t:=(p_intent->>'target_actor')::uuid;
 IF public.combat_v2_sanitize_intent(p_intent,false) IS DISTINCT FROM p_intent OR p_intent->>'kind' IS DISTINCT FROM 'attacco'
  OR p_intent->>'ability_source' IS DISTINCT FROM 'clan' OR p_intent->>'ability_id' IS DISTINCT FROM '31d5d554-44d1-4042-9920-3ddd3bedff7e'
  OR t IS NULL OR t=a.id OR NOT combat_v2_genjutsu_internal.runtime_allowed(t)
  OR NOT EXISTS(SELECT 1 FROM public.combat_v2_actors WHERE id=t AND session_id=a.session_id)
  OR (p_intent?'target_actor_ids' AND p_intent->'target_actor_ids' IS DISTINCT FROM jsonb_build_array(t))
  OR NOT combat_v2_elemental_internal.other_target_visible(a.id,t,10)
  OR EXISTS(SELECT 1 FROM combat_panel_private.multiplication_formations WHERE actor_id=t AND state='active')
 THEN RAISE EXCEPTION 'paralisi_target_or_intent_invalid' USING ERRCODE='22023';END IF;
 s:=jsonb_build_object('schema_version','paralisi-source/1','session_id',a.session_id,'round_id',p_round,'actor_id',a.id,'target_actor_id',t,
  'request_id',p_request,'principal_id',exam_regia_private.current_principal(),'controller_version',a.controller_version,
  'intent',p_intent,'ability_meta',combat_v2_genjutsu_internal.actor_meta(a.id),
  'geometry',combat_v2_elemental_internal.other_geometry(a.id,t,false),'quote',combat_v2_genjutsu_internal.quote(a.id));
 SELECT * INTO pr FROM combat_v2_genjutsu_internal.preparations WHERE actor_id=a.id AND round_id=p_round AND request_id=p_request;
 IF FOUND THEN
  IF pr.transaction_id<>txid_current() OR pr.source IS DISTINCT FROM s OR pr.source_sha256 IS DISTINCT FROM public.combat_v2_sha256(s) THEN
   RAISE EXCEPTION 'paralisi_preparation_conflict' USING ERRCODE='40001';END IF;RETURN s;
 END IF;
 INSERT INTO combat_v2_genjutsu_internal.preparations VALUES(a.id,p_round,p_request,txid_current(),s,public.combat_v2_sha256(s));
 RETURN s;
END $f$;
CREATE FUNCTION combat_v2_genjutsu_internal.declaration_meta(p_round uuid,p_actor uuid,p_request uuid,p_intent jsonb) RETURNS jsonb LANGUAGE plpgsql STABLE SECURITY DEFINER SET search_path='' AS $f$
DECLARE p combat_v2_genjutsu_internal.preparations%ROWTYPE;
BEGIN
 SELECT * INTO p FROM combat_v2_genjutsu_internal.preparations WHERE actor_id=p_actor AND round_id=p_round AND request_id=p_request;
 IF NOT FOUND THEN RETURN NULL;END IF;
 IF p.transaction_id<>txid_current() OR p.source_sha256 IS DISTINCT FROM public.combat_v2_sha256(p.source)
  OR p.source->'intent' IS DISTINCT FROM p_intent OR p.source->>'principal_id' IS DISTINCT FROM exam_regia_private.current_principal()::text
  OR NOT EXISTS(SELECT 1 FROM public.combat_v2_actors a WHERE a.id=p_actor AND a.controller_user=exam_regia_private.current_principal()
   AND a.controller_version::text=p.source->>'controller_version' AND combat_v2_genjutsu_internal.runtime_allowed(a.id)) THEN RAISE EXCEPTION 'paralisi_preparation_required';END IF;
 RETURN p.source->'ability_meta';
END $f$;
CREATE FUNCTION combat_v2_genjutsu_internal.bind_source(p_declaration uuid) RETURNS void LANGUAGE plpgsql SECURITY DEFINER SET search_path='' AS $f$
DECLARE d public.combat_v2_declarations%ROWTYPE;p combat_v2_genjutsu_internal.preparations%ROWTYPE;s combat_v2_genjutsu_internal.sources%ROWTYPE;fp text;seal text;
BEGIN
 SELECT * INTO STRICT d FROM public.combat_v2_declarations WHERE id=p_declaration;
 IF d.sanitized_intent#>>'{server_ability,genjutsu_profile_version}' IS DISTINCT FROM 'paralisi-movement/1' THEN RETURN;END IF;
 PERFORM combat_effects_private.lock_context((SELECT session_id FROM public.combat_v2_actors WHERE id=d.actor_id));
 SELECT * INTO STRICT d FROM public.combat_v2_declarations WHERE id=p_declaration FOR UPDATE;
 SELECT * INTO STRICT p FROM combat_v2_genjutsu_internal.preparations WHERE actor_id=d.actor_id AND round_id=d.round_id AND request_id=d.request_key;
 fp:=combat_effects_private.declaration_fingerprint(d.id);seal:=public.combat_v2_sha256(jsonb_build_object('source',p.source,'declaration',d.id,'fingerprint',fp));
 SELECT * INTO s FROM combat_v2_genjutsu_internal.sources WHERE declaration_id=d.id;
 IF FOUND THEN IF s.source_sha256 IS DISTINCT FROM seal THEN RAISE EXCEPTION 'paralisi_source_conflict';END IF;RETURN;END IF;
 IF p.transaction_id<>txid_current() OR p.source_sha256 IS DISTINCT FROM public.combat_v2_sha256(p.source)
  OR d.kind<>'attacco' OR (d.sanitized_intent-'server_ability') IS DISTINCT FROM p.source->'intent'
  OR d.sanitized_intent->'server_ability' IS DISTINCT FROM p.source->'ability_meta'
  OR d.controller_user_snapshot::text IS DISTINCT FROM p.source->>'principal_id'
  OR d.controller_version_snapshot::text IS DISTINCT FROM p.source->>'controller_version'
  OR d.cost_snapshot->'chakra' IS DISTINCT FROM p.source#>'{ability_meta,chakra_cost}'
  OR d.cost_snapshot->'technique_cost' IS DISTINCT FROM p.source->'quote'
  OR to_jsonb(clan_hyuga_private.sedici_frozen_cost(d.actor_id,d.cost_snapshot)) IS DISTINCT FROM p.source#>'{quote,total}'
  OR d.cost_snapshot->'damage_base' IS DISTINCT FROM '0'::jsonb THEN RAISE EXCEPTION 'paralisi_source_freeze_invalid';END IF;
 INSERT INTO combat_v2_genjutsu_internal.sources VALUES(d.id,(p.source->>'session_id')::uuid,p.source,fp,seal);
END $f$;
CREATE FUNCTION combat_v2_genjutsu_internal.source_valid(p_declaration uuid) RETURNS boolean LANGUAGE sql STABLE SECURITY DEFINER SET search_path='' AS $f$
 SELECT EXISTS(SELECT 1 FROM combat_v2_genjutsu_internal.sources s JOIN public.combat_v2_declarations d ON d.id=s.declaration_id
 WHERE s.declaration_id=p_declaration AND s.declaration_sha256=combat_effects_private.declaration_fingerprint(d.id)
 AND s.source_sha256=public.combat_v2_sha256(jsonb_build_object('source',s.source,'declaration',d.id,'fingerprint',s.declaration_sha256))
 AND s.source->'ability_meta'=combat_v2_genjutsu_internal.profile()
 AND d.sanitized_intent->'server_ability'=s.source->'ability_meta'
 AND d.actor_id::text=s.source->>'actor_id' AND d.target_actor_id::text=s.source->>'target_actor_id'
 AND d.round_id::text=s.source->>'round_id' AND d.cost_snapshot->'damage_base'='0'::jsonb
)
$f$;
-- Pure helper: native dice/quality remain upstream, before existing RNG sealing.
CREATE FUNCTION combat_v2_genjutsu_internal.comparison(p_attack uuid,p_defense uuid,p_calc jsonb) RETURNS jsonb LANGUAGE plpgsql STABLE SECURITY DEFINER SET search_path='' AS $f$
DECLARE d public.combat_v2_declarations%ROWTYPE;def public.combat_v2_declarations%ROWTYPE;a public.combat_v2_actors%ROWTYPE;ok boolean;
BEGIN
 SELECT * INTO STRICT d FROM public.combat_v2_declarations WHERE id=p_attack;
 IF d.sanitized_intent#>>'{server_ability,genjutsu_profile_version}' IS DISTINCT FROM 'paralisi-movement/1' THEN RETURN p_calc;END IF;
 IF NOT combat_v2_genjutsu_internal.source_valid(d.id) OR NOT EXISTS(SELECT 1 FROM public.combat_v2_actors x WHERE x.id=d.actor_id AND x.controller_version=d.controller_version_snapshot AND x.controller_user=d.controller_user_snapshot) THEN RAISE EXCEPTION 'paralisi_frozen_source_required';END IF;
 SELECT * INTO def FROM public.combat_v2_declarations WHERE id=p_defense;
 IF (p_calc->>'pool_att')::numeric IS NULL OR (p_calc->>'pool_dif')::numeric IS NULL THEN RAISE EXCEPTION 'paralisi_mental_pools_required';END IF;
 IF def.sanitized_intent->>'reaction'='tecnica' THEN
  IF def.sanitized_intent->>'ability_source' IS DISTINCT FROM 'jutsu'
    OR def.sanitized_intent->>'ability_id' IS DISTINCT FROM '9f12fc98-bc97-4b95-9bcc-7ce359ebbe4f' THEN RAISE EXCEPTION 'paralisi_incompatible_defense';END IF;
  SELECT * INTO STRICT a FROM public.combat_v2_actors WHERE id=def.actor_id;
  IF jsonb_typeof(a.mechanics_snapshot->'mente') IS DISTINCT FROM 'number' THEN RAISE EXCEPTION 'paralisi_defense_snapshot_invalid';END IF;
  ok:=(a.mechanics_snapshot->>'mente')::numeric>=20;
  RETURN p_calc||jsonb_build_object('paralisi',jsonb_build_object('contract','paralisi-movement/1','dispersion_attempted',true,
    'dispersion_success',ok,'dispersion_power',20,'dispersion_mente',a.mechanics_snapshot->'mente'),'danno_grezzo',0,'danno_applicato',0,'striscio',false,'cap_attivo',false);
 END IF;
 RETURN p_calc||jsonb_build_object('paralisi',jsonb_build_object('contract','paralisi-movement/1','dispersion_attempted',false),'danno_grezzo',0,'danno_applicato',0,'striscio',false,'cap_attivo',false);
END $f$;
CREATE FUNCTION combat_v2_genjutsu_internal.success(p_calc jsonb,p_final integer,p_intercepted boolean) RETURNS boolean LANGUAGE sql IMMUTABLE SET search_path='' AS $f$
 SELECT CASE WHEN p_calc#>>'{paralisi,contract}' IS DISTINCT FROM 'paralisi-movement/1' THEN NULL
 WHEN coalesce(p_intercepted,false) THEN false
 WHEN p_calc#>'{paralisi,dispersion_attempted}'='true'::jsonb THEN NOT (p_calc#>>'{paralisi,dispersion_success}')::boolean
 ELSE p_final>=0 END
$f$;
CREATE FUNCTION combat_v2_genjutsu_internal.decorate_outcome(p_declaration uuid,p_attack_target uuid,p_outcome jsonb) RETURNS jsonb LANGUAGE plpgsql SECURITY DEFINER SET search_path='' AS $f$
DECLARE d public.combat_v2_declarations%ROWTYPE;t public.combat_v2_attack_targets%ROWTYPE;e combat_v2_genjutsu_internal.effects%ROWTYPE;
 c jsonb;ex uuid;h text;res jsonb;
BEGIN
 SELECT * INTO STRICT d FROM public.combat_v2_declarations WHERE id=p_declaration;
 IF d.sanitized_intent#>>'{server_ability,genjutsu_profile_version}' IS DISTINCT FROM 'paralisi-movement/1' THEN RETURN p_outcome;END IF;
 IF NOT combat_v2_genjutsu_internal.source_valid(d.id) OR jsonb_typeof(p_outcome->'success') IS DISTINCT FROM 'boolean'
  OR p_outcome->'damage_applied' IS DISTINCT FROM '0'::jsonb OR jsonb_typeof(p_outcome#>'{raw,pool_att}') IS DISTINCT FROM 'number' THEN RAISE EXCEPTION 'paralisi_native_zero_damage_required';END IF;
 SELECT * INTO STRICT t FROM public.combat_v2_attack_targets WHERE id=p_attack_target AND attack_declaration_id=d.id;
 PERFORM combat_effects_private.lock_context((SELECT session_id FROM public.combat_v2_actors WHERE id=d.actor_id));
 h:=public.combat_v2_sha256(p_outcome);
 SELECT * INTO e FROM combat_v2_genjutsu_internal.effects WHERE source_attack_target_id=t.id FOR UPDATE;
 IF FOUND THEN
  IF e.source_outcome_sha256 IS DISTINCT FROM h THEN RAISE EXCEPTION 'paralisi_outcome_replay_conflict';END IF;
  RETURN p_outcome||jsonb_build_object('genjutsu_server',jsonb_build_object('effect_id',e.id,'contract','paralisi-movement/1','applied',true,'kai_negated',false,'movement_only',true,'reason','applied'));
 END IF;
 IF NOT (p_outcome->>'success')::boolean THEN RETURN p_outcome||jsonb_build_object('genjutsu_server',jsonb_build_object('contract','paralisi-movement/1','effect_id',NULL,'applied',false,'kai_negated',coalesce(p_outcome#>'{raw,paralisi,dispersion_success}'='true'::jsonb,false),'movement_only',true,'reason',CASE WHEN p_outcome#>'{raw,paralisi,dispersion_success}'='true'::jsonb THEN 'kai_negated' ELSE 'mental_contest_lost' END));END IF;
 c:=combat_effects_private.personal_turn((SELECT session_id FROM public.combat_v2_actors WHERE id=t.target_actor_id),t.target_actor_id);
 -- Exactly the existing effect clock convention: exclude an already current target turn.
 ex:=CASE WHEN c->>'is_current'='true' THEN (c->>'turn_id')::uuid ELSE NULL END;
 IF EXISTS(SELECT 1 FROM combat_v2_genjutsu_internal.effects WHERE target_actor_id=t.target_actor_id AND state IN('pending','active')) THEN
  RETURN p_outcome||jsonb_build_object('genjutsu_server',jsonb_build_object('contract','paralisi-movement/1','effect_id',NULL,'applied',false,'kai_negated',false,'movement_only',true,'reason','already_active_no_refresh'));
 END IF;
 INSERT INTO combat_v2_genjutsu_internal.effects(session_id,source_declaration_id,source_attack_target_id,source_actor_id,target_actor_id,
  profile,source_outcome_sha256,adapter,excluded_turn_id,state)
 VALUES((c->>'session_id')::uuid,d.id,t.id,d.actor_id,t.target_actor_id,combat_v2_genjutsu_internal.profile()||jsonb_build_object('source_pool',p_outcome#>'{raw,pool_att}'),h,c->>'adapter',ex,'pending') RETURNING * INTO e;
 res:=jsonb_build_object('effect_id',e.id,'contract','paralisi-movement/1','applied',true,'kai_negated',false,'movement_only',true,'reason','applied');
 PERFORM combat_v2_genjutsu_internal.record_event('apply:'||t.id::text,e.id,res);
 RETURN p_outcome||jsonb_build_object('genjutsu_server',res);
END $f$;
CREATE FUNCTION combat_v2_genjutsu_internal.turn_start(p_session uuid,p_actor uuid,p_turn uuid,p_adapter text) RETURNS void LANGUAGE plpgsql SECURITY DEFINER SET search_path='' AS $f$
DECLARE c jsonb;e combat_v2_genjutsu_internal.effects%ROWTYPE;
BEGIN
 PERFORM combat_effects_private.lock_context(p_session);c:=combat_effects_private.personal_turn(p_session,p_actor);
 IF p_turn IS NULL OR c->>'turn_id' IS DISTINCT FROM p_turn::text OR c->>'adapter' IS DISTINCT FROM p_adapter OR c->>'is_current' IS DISTINCT FROM 'true' THEN
  RAISE EXCEPTION 'paralisi_native_turn_required';END IF;
 FOR e IN SELECT * FROM combat_v2_genjutsu_internal.effects WHERE session_id=p_session AND target_actor_id=p_actor AND state='pending'
  AND adapter=p_adapter AND excluded_turn_id IS DISTINCT FROM p_turn ORDER BY id FOR UPDATE LOOP
  UPDATE combat_v2_genjutsu_internal.effects SET state='active',due_turn_id=p_turn,state_version=state_version+1 WHERE id=e.id AND state_version=e.state_version;
  PERFORM combat_v2_genjutsu_internal.record_event('start:'||e.id::text||':'||p_turn::text,e.id,jsonb_build_object('effect_id',e.id,'turn_id',p_turn,'movement_only',true));
 END LOOP;
END $f$;
CREATE FUNCTION combat_v2_genjutsu_internal.turn_end(p_session uuid,p_actor uuid,p_turn uuid,p_adapter text) RETURNS void LANGUAGE plpgsql SECURITY DEFINER SET search_path='' AS $f$
DECLARE c jsonb;e combat_v2_genjutsu_internal.effects%ROWTYPE;
BEGIN
 PERFORM combat_effects_private.lock_context(p_session);c:=combat_effects_private.personal_turn(p_session,p_actor);
 IF p_turn IS NULL OR c->>'turn_id' IS DISTINCT FROM p_turn::text OR c->>'adapter' IS DISTINCT FROM p_adapter THEN RAISE EXCEPTION 'paralisi_native_turn_required';END IF;
 FOR e IN SELECT * FROM combat_v2_genjutsu_internal.effects WHERE session_id=p_session AND target_actor_id=p_actor AND adapter=p_adapter
  AND state IN('pending','active') AND excluded_turn_id IS DISTINCT FROM p_turn ORDER BY id FOR UPDATE LOOP
  IF e.due_turn_id IS NOT NULL AND e.due_turn_id<>p_turn THEN RAISE EXCEPTION 'paralisi_missed_settlement';END IF;
  UPDATE combat_v2_genjutsu_internal.effects SET state='expired',due_turn_id=coalesce(due_turn_id,p_turn),ended_at=clock_timestamp(),
   end_reason='target_personal_turn_end',state_version=state_version+1 WHERE id=e.id AND state_version=e.state_version;
  PERFORM combat_v2_genjutsu_internal.record_event('end:'||e.id::text||':'||p_turn::text,e.id,jsonb_build_object('effect_id',e.id,'turn_id',p_turn,'expired',true));
 END LOOP;
END $f$;
CREATE FUNCTION combat_v2_genjutsu_internal.movement_blocked(p_actor uuid) RETURNS boolean LANGUAGE sql STABLE SECURITY DEFINER SET search_path='' AS $f$
 SELECT EXISTS(SELECT 1 FROM combat_v2_genjutsu_internal.effects e JOIN public.combat_v2_sessions s ON s.id=e.session_id
 JOIN public.combat_v2_actors a ON a.id=e.target_actor_id WHERE a.id=p_actor AND a.state='attivo'
 AND s.state IN('in_corso','sospeso') AND e.state='active')
$f$;
CREATE FUNCTION combat_v2_genjutsu_internal.end_context(p_session uuid,p_actor uuid DEFAULT NULL) RETURNS void LANGUAGE plpgsql SECURITY DEFINER SET search_path='' AS $f$
DECLARE e combat_v2_genjutsu_internal.effects%ROWTYPE;
BEGIN
 PERFORM 1 FROM public.combat_v2_sessions WHERE id=p_session FOR UPDATE;
 FOR e IN SELECT * FROM combat_v2_genjutsu_internal.effects WHERE session_id=p_session AND state IN('pending','active')
  AND (p_actor IS NULL OR target_actor_id=p_actor OR source_actor_id=p_actor) ORDER BY id FOR UPDATE LOOP
  UPDATE combat_v2_genjutsu_internal.effects SET state='ended',ended_at=clock_timestamp(),end_reason=CASE WHEN p_actor IS NULL THEN 'combat_end' ELSE 'actor_inoperative' END,
   state_version=state_version+1 WHERE id=e.id AND state_version=e.state_version;
  PERFORM combat_v2_genjutsu_internal.record_event('terminate:'||e.id::text,e.id,jsonb_build_object('effect_id',e.id,'ended',true,'actor_id',p_actor));
 END LOOP;
END $f$;

CREATE FUNCTION combat_v2_genjutsu_internal.open_turn(p_session uuid,p_actor uuid) RETURNS void LANGUAGE plpgsql SECURITY DEFINER SET search_path='' AS $f$
DECLARE c jsonb;
BEGIN
 IF NOT EXISTS(SELECT 1 FROM combat_v2_genjutsu_internal.effects WHERE session_id=p_session AND target_actor_id=p_actor AND state='pending') THEN RETURN;END IF;
 c:=combat_effects_private.personal_turn(p_session,p_actor);
 IF c->>'useful'='true' AND c->>'is_current'='true' THEN
  PERFORM combat_v2_genjutsu_internal.turn_start(p_session,p_actor,(c->>'turn_id')::uuid,c->>'adapter');
 END IF;
END $f$;
CREATE FUNCTION combat_v2_genjutsu_internal.consumer_options(p jsonb) RETURNS jsonb LANGUAGE plpgsql SECURITY DEFINER SET search_path='' AS $f$
DECLARE aid uuid:=(p#>>'{viewer,actor_id}')::uuid;sid uuid:=(p#>>'{context,activity_id}')::uuid;
 a public.combat_v2_actors%ROWTYPE;c combat_consumer_private.activities%ROWTYPE;t uuid;offers jsonb:=coalesce(p->'offers','[]');q jsonb;ri jsonb;
BEGIN
 IF aid IS NULL OR sid IS NULL OR p->>'status' IS DISTINCT FROM 'ready' THEN RETURN p;END IF;
 SELECT * INTO a FROM public.combat_v2_actors WHERE id=aid AND session_id=sid AND controller_user=exam_regia_private.current_principal() AND state='attivo';
 SELECT * INTO c FROM combat_consumer_private.activities WHERE session_id=sid AND phase='action' AND turn_actor_id=aid;
 IF a.id IS NULL OR c.session_id IS NULL OR NOT combat_v2_genjutsu_internal.runtime_allowed(aid) THEN RETURN p;END IF;
 PERFORM combat_v2_genjutsu_internal.open_turn(sid,aid);
 IF combat_v2_genjutsu_internal.preset_ready(aid) THEN
  offers:=offers||jsonb_build_array(combat_consumer_private.offer_exchange(sid,aid,NULL,(p#>>'{context,scene_version}')::integer,
   'control','Prepara prova: Paralisi illusoria',jsonb_build_object('other_operation','staff_profile','technique_id','31d5d554-44d1-4042-9920-3ddd3bedff7e'::uuid)));
 END IF;
 FOR ri IN SELECT value FROM jsonb_array_elements(combat_v2_genjutsu_internal.release_intents(aid)) LOOP
  offers:=offers||jsonb_build_array(combat_consumer_private.offer_exchange(sid,aid,(ri#>>'{intent,target_actor}')::uuid,(p#>>'{context,scene_version}')::integer,
   'declare',ri->>'label',jsonb_build_object('intent',ri->'intent')));
 END LOOP;
 q:=combat_v2_genjutsu_internal.quote(aid);
 IF q IS NOT NULL THEN
  FOR t IN SELECT x.actor_id FROM combat_consumer_private.members x WHERE x.session_id=sid AND x.actor_id<>aid LOOP
   IF NOT combat_v2_genjutsu_internal.runtime_allowed(t) OR NOT combat_v2_elemental_internal.other_target_visible(aid,t,10)
    OR EXISTS(SELECT 1 FROM combat_panel_private.multiplication_formations WHERE actor_id=t AND state='active') THEN CONTINUE;END IF;
   offers:=offers||jsonb_build_array(combat_consumer_private.offer_exchange(sid,aid,t,(p#>>'{context,scene_version}')::integer,
    'declare','Paralisi illusoria · '||(q->>'total')||' chakra · solo movimento',jsonb_build_object('intent',jsonb_build_object(
     'kind','attacco','ability_source','clan','ability_id','31d5d554-44d1-4042-9920-3ddd3bedff7e'::uuid,'target_actor',t))));
  END LOOP;
 END IF;
 RETURN jsonb_set(p,'{offers}',offers);
END $f$;
CREATE FUNCTION combat_v2_genjutsu_internal.master_options(p_context uuid,p_expected bigint) RETURNS void LANGUAGE plpgsql SECURITY DEFINER SET search_path='' AS $f$
DECLARE c combat_panel_private.contexts%ROWTYPE;ri jsonb;
BEGIN
 c:=combat_panel_private.owned_context(p_context,p_expected);
 IF c.activity_kind<>'master_v2' OR c.command_actor_id IS NULL OR NOT combat_v2_genjutsu_internal.runtime_allowed(c.command_actor_id) THEN RETURN;END IF;
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
END $f$;
CREATE TABLE combat_v2_genjutsu_internal.release_plans(
 actor_id uuid NOT NULL REFERENCES public.combat_v2_actors(id),round_id uuid NOT NULL REFERENCES public.combat_v2_rounds(id),
 request_id uuid NOT NULL,effect_id uuid NOT NULL REFERENCES combat_v2_genjutsu_internal.effects(id),
 source jsonb NOT NULL CHECK(jsonb_typeof(source)='object'),source_sha256 text NOT NULL CHECK(source_sha256 ~ '^[0-9a-f]{64}$'),transaction_id bigint NOT NULL,
 declaration_id uuid UNIQUE REFERENCES public.combat_v2_declarations(id),declaration_sha256 text,result jsonb,result_sha256 text,
 PRIMARY KEY(actor_id,round_id),UNIQUE(actor_id,request_id),
 CHECK((declaration_id IS NULL)=(declaration_sha256 IS NULL)),CHECK((result IS NULL)=(result_sha256 IS NULL)),
 CHECK(declaration_sha256 IS NULL OR declaration_sha256 ~ '^[0-9a-f]{64}$'),CHECK(result_sha256 IS NULL OR result_sha256 ~ '^[0-9a-f]{64}$'));
CREATE FUNCTION combat_v2_genjutsu_internal.ally_contact(p_actor uuid,p_target uuid) RETURNS jsonb LANGUAGE plpgsql STABLE SECURITY DEFINER SET search_path='' AS $f$
DECLARE a public.combat_v2_actors%ROWTYPE;t public.combat_v2_actors%ROWTYPE;
 i combat_spatial.arena_instances%ROWTYPE;ab combat_spatial.actor_states%ROWTYPE;tb combat_spatial.actor_states%ROWTYPE;
BEGIN
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
END $f$;
CREATE FUNCTION combat_v2_genjutsu_internal.release_intents(p_actor uuid) RETURNS jsonb LANGUAGE plpgsql STABLE SECURITY DEFINER SET search_path='' AS $f$
DECLARE a public.combat_v2_actors%ROWTYPE;t public.combat_v2_actors%ROWTYPE;e combat_v2_genjutsu_internal.effects%ROWTYPE;out jsonb:='[]';kai boolean;c jsonb;
BEGIN
 SELECT * INTO a FROM public.combat_v2_actors WHERE id=p_actor AND controller_user=exam_regia_private.current_principal();
 IF a.id IS NULL OR NOT combat_v2_genjutsu_internal.runtime_allowed(a.id) THEN RETURN out;END IF;
 c:=combat_effects_private.personal_turn(a.session_id,a.id);IF c->>'useful' IS DISTINCT FROM 'true' THEN RETURN out;END IF;
 kai:=public.combat_v2_actor_ability(a.id,'jutsu','9f12fc98-bc97-4b95-9bcc-7ce359ebbe4f'::uuid,true) IS NOT NULL;
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
END $f$;
CREATE FUNCTION combat_v2_genjutsu_internal.release_meta(p_round uuid,p_actor uuid,p_request uuid,p_intent jsonb) RETURNS jsonb LANGUAGE plpgsql SECURITY DEFINER SET search_path='' AS $f$
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
 source:=jsonb_build_object('session_id',a.session_id,'round_id',p_round,'actor_id',a.id,'principal',exam_regia_private.current_principal(),
  'controller_version',a.controller_version,'intent',p_intent,'meta',m,'mente',a.mechanics_snapshot->'mente','genjutsu',a.mechanics_snapshot->'genjutsu','contact',CASE WHEN mode='kai' THEN combat_v2_genjutsu_internal.ally_contact(a.id,e.target_actor_id) ELSE NULL END);
 SELECT * INTO old FROM combat_v2_genjutsu_internal.release_plans WHERE actor_id=a.id AND round_id=p_round;
 IF FOUND THEN
  IF old.request_id IS DISTINCT FROM p_request OR old.source IS DISTINCT FROM source OR old.transaction_id<>txid_current() THEN RAISE EXCEPTION 'paralisi_release_conflict';END IF;RETURN m;
 END IF;
 INSERT INTO combat_v2_genjutsu_internal.release_plans(actor_id,round_id,request_id,effect_id,source,source_sha256,transaction_id)
 VALUES(a.id,p_round,p_request,e.id,source,public.combat_v2_sha256(source),txid_current());RETURN m;
END $f$;
CREATE FUNCTION combat_v2_genjutsu_internal.bind_release(p_declaration uuid) RETURNS void LANGUAGE plpgsql SECURITY DEFINER SET search_path='' AS $f$
DECLARE d public.combat_v2_declarations%ROWTYPE;p combat_v2_genjutsu_internal.release_plans%ROWTYPE;
BEGIN
 SELECT * INTO STRICT d FROM public.combat_v2_declarations WHERE id=p_declaration;
 IF d.sanitized_intent#>>'{server_ability,genjutsu_release_version}' IS DISTINCT FROM 'paralisi-release/1' THEN RETURN;END IF;
 SELECT * INTO STRICT p FROM combat_v2_genjutsu_internal.release_plans WHERE actor_id=d.actor_id AND round_id=d.round_id AND request_id=d.request_key FOR UPDATE;
 IF p.transaction_id<>txid_current() OR p.source_sha256 IS DISTINCT FROM public.combat_v2_sha256(p.source)
  OR d.kind<>'utilita' OR (d.sanitized_intent-'server_ability') IS DISTINCT FROM p.source->'intent'
  OR d.sanitized_intent->'server_ability' IS DISTINCT FROM p.source->'meta' OR d.cost_snapshot->'chakra' IS DISTINCT FROM '0'::jsonb
  OR d.controller_user_snapshot::text IS DISTINCT FROM p.source->>'principal'
  OR d.controller_version_snapshot::text IS DISTINCT FROM p.source->>'controller_version' THEN RAISE EXCEPTION 'paralisi_release_freeze_invalid';END IF;
 UPDATE combat_v2_genjutsu_internal.release_plans SET declaration_id=d.id,declaration_sha256=combat_effects_private.declaration_fingerprint(d.id)
 WHERE actor_id=p.actor_id AND round_id=p.round_id;
END $f$;
CREATE FUNCTION combat_v2_genjutsu_internal.resolve_release(p_declaration uuid) RETURNS jsonb LANGUAGE plpgsql SECURITY DEFINER SET search_path='' AS $f$
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
END $f$;

CREATE FUNCTION combat_v2_genjutsu_internal.defense_intent_allowed(p_attack uuid,p_intent jsonb) RETURNS boolean LANGUAGE sql STABLE SECURITY DEFINER SET search_path='' AS $f$
 SELECT CASE WHEN NOT EXISTS(SELECT 1 FROM combat_v2_genjutsu_internal.sources WHERE declaration_id=p_attack) THEN true ELSE
 combat_v2_genjutsu_internal.source_valid(p_attack) AND (p_intent->>'reaction' IN('schivata','nessuna') OR
 (p_intent->>'reaction'='tecnica' AND p_intent->>'ability_source'='jutsu' AND p_intent->>'ability_id'='9f12fc98-bc97-4b95-9bcc-7ce359ebbe4f')) END
$f$;
CREATE FUNCTION combat_v2_genjutsu_internal.kai_defense_valid(p_attack uuid,p_defense uuid) RETURNS boolean LANGUAGE sql STABLE SECURITY DEFINER SET search_path='' AS $f$
 SELECT combat_v2_genjutsu_internal.source_valid(p_attack) AND EXISTS(SELECT 1 FROM public.combat_v2_declarations d
 WHERE d.id=p_defense AND d.parent_attack_id=p_attack AND d.kind='difesa' AND d.sanitized_intent->>'reaction'='tecnica'
 AND d.sanitized_intent->>'ability_source'='jutsu' AND d.sanitized_intent->>'ability_id'='9f12fc98-bc97-4b95-9bcc-7ce359ebbe4f')
$f$;
CREATE FUNCTION combat_v2_genjutsu_internal.panel_options(p_context uuid,p_expected bigint) RETURNS void LANGUAGE plpgsql SECURITY DEFINER SET search_path='' AS $f$
DECLARE c combat_panel_private.contexts%ROWTYPE;o combat_panel_private.offers%ROWTYPE;payload jsonb;reaction text;
BEGIN
 c:=combat_panel_private.owned_context(p_context,p_expected);
 IF c.command_actor_id IS NULL OR NOT EXISTS(SELECT 1 FROM public.combat_v2_attack_targets t JOIN combat_v2_genjutsu_internal.sources s ON s.declaration_id=t.attack_declaration_id
  WHERE t.round_id=c.round_id AND t.target_actor_id=c.command_actor_id AND t.state='attesa_difesa') THEN RETURN;END IF;
 IF EXISTS(SELECT 1 FROM public.combat_v2_attack_targets t WHERE t.round_id=c.round_id AND t.target_actor_id=c.command_actor_id AND t.state='attesa_difesa'
  AND NOT EXISTS(SELECT 1 FROM combat_v2_genjutsu_internal.sources s WHERE s.declaration_id=t.attack_declaration_id)) THEN RETURN;END IF;
 FOR o IN SELECT * FROM combat_panel_private.offers WHERE context_id=c.id AND context_version=c.context_version AND state='offered' AND kind='defense' FOR UPDATE LOOP
  payload:=o.source_payload;
  IF c.activity_kind='ordinary_v2' THEN SELECT source_payload INTO payload FROM combat_consumer_private.offers WHERE id=(o.source_payload->>'source_offer_id')::uuid;END IF;
  reaction:=coalesce(payload->>'reaction',payload#>>'{intent,reaction}');
  IF reaction='schivata' THEN UPDATE combat_panel_private.offers SET label='Resisti all’illusione · confronto mentale' WHERE id=o.id;
  ELSIF reaction='nessuna' THEN NULL;
  ELSIF reaction='tecnica' AND coalesce(payload->>'ability_id',payload#>>'{intent,ability_id}')='9f12fc98-bc97-4b95-9bcc-7ce359ebbe4f' THEN NULL;
  ELSE UPDATE combat_panel_private.offers SET state='revoked' WHERE id=o.id AND state='offered';END IF;
 END LOOP;
END $f$;

CREATE FUNCTION combat_v2_genjutsu_internal.validate_attack_facts(p jsonb) RETURNS jsonb LANGUAGE plpgsql IMMUTABLE SET search_path='' AS $f$
BEGIN
 IF jsonb_typeof(p) IS DISTINCT FROM 'object' OR p->>'contract' IS DISTINCT FROM 'paralisi-movement/1'
  OR p-ARRAY['contract','effect_id','applied','kai_negated','movement_only','reason'] IS DISTINCT FROM '{}'::jsonb
  OR jsonb_typeof(p->'applied') IS DISTINCT FROM 'boolean' OR jsonb_typeof(p->'kai_negated') IS DISTINCT FROM 'boolean'
  OR p->'movement_only' IS DISTINCT FROM 'true'::jsonb
  OR p->>'reason' IS NULL OR p->>'reason' NOT IN('applied','mental_contest_lost','kai_negated','already_active_no_refresh','target_inoperative')
  OR ((p->>'applied')::boolean AND (p->>'effect_id' IS NULL OR (p->>'kai_negated')::boolean))
  OR ((p->>'kai_negated')::boolean AND p->>'reason'<>'kai_negated') THEN RAISE EXCEPTION 'paralisi_narrative_attack_invalid';END IF;
 IF p->>'effect_id' IS NOT NULL THEN PERFORM (p->>'effect_id')::uuid;END IF;RETURN p;
END $f$;
CREATE FUNCTION combat_v2_genjutsu_internal.validate_release_facts(p jsonb) RETURNS jsonb LANGUAGE plpgsql IMMUTABLE SET search_path='' AS $f$
DECLARE k text;
BEGIN
 IF jsonb_typeof(p) IS DISTINCT FROM 'object' OR p->>'contract' IS DISTINCT FROM 'paralisi-release/1'
  OR p-ARRAY['contract','effect_id','mode','attempted','released','still_blocked','reason','main_consumed','chakra_cost','damage_applied'] IS DISTINCT FROM '{}'::jsonb
  OR p->>'mode' IS NULL OR p->>'mode' NOT IN('mental_contest','kai')
  OR p->>'reason' IS NULL OR p->>'reason' NOT IN('released','contest_failed','kai_below_power','contact_lost','actor_inoperative','effect_ended')
  OR p->'main_consumed' IS DISTINCT FROM 'true'::jsonb OR p->'chakra_cost' IS DISTINCT FROM '0'::jsonb
  OR p->'damage_applied' IS DISTINCT FROM '0'::jsonb OR p->>'effect_id' IS NULL THEN RAISE EXCEPTION 'paralisi_narrative_release_invalid';END IF;
 FOREACH k IN ARRAY ARRAY['attempted','released','still_blocked'] LOOP
  IF jsonb_typeof(p->k) IS DISTINCT FROM 'boolean' THEN RAISE EXCEPTION 'paralisi_narrative_release_invalid';END IF;
 END LOOP;
 IF (p->>'released')::boolean AND ((p->>'still_blocked')::boolean OR NOT (p->>'attempted')::boolean OR p->>'reason'<>'released') THEN RAISE EXCEPTION 'paralisi_narrative_release_conflict';END IF;
 PERFORM (p->>'effect_id')::uuid;RETURN p;
END $f$;
CREATE FUNCTION combat_v2_genjutsu_internal.raw_attack_facts(p_declaration uuid) RETURNS jsonb LANGUAGE plpgsql STABLE SECURITY DEFINER SET search_path='' AS $f$
DECLARE d public.combat_v2_declarations%ROWTYPE;t public.combat_v2_attack_targets%ROWTYPE;
BEGIN
 SELECT * INTO STRICT d FROM public.combat_v2_declarations WHERE id=p_declaration;
 IF EXISTS(SELECT 1 FROM combat_v2_genjutsu_internal.sources WHERE declaration_id=d.id) THEN
  IF d.state NOT IN('risolta','superflua') OR NOT combat_v2_genjutsu_internal.source_valid(d.id)
   OR (SELECT count(*) FROM public.combat_v2_attack_targets WHERE attack_declaration_id=d.id)<>1 THEN RAISE EXCEPTION 'paralisi_narrative_source_invalid';END IF;
  IF d.state='superflua' THEN
   IF d.outcome->>'reason' IS DISTINCT FROM 'bersaglio_gia_fuori' THEN RAISE EXCEPTION 'paralisi_narrative_superfluous_invalid';END IF;
   RETURN jsonb_build_object('genjutsu_server',jsonb_build_object('contract','paralisi-movement/1','effect_id',NULL,'applied',false,'kai_negated',false,'movement_only',true,'reason','target_inoperative'));
  END IF;
  SELECT * INTO STRICT t FROM public.combat_v2_attack_targets WHERE attack_declaration_id=d.id AND state='risolta';
  IF t.outcome->'damage_applied' IS DISTINCT FROM '0'::jsonb THEN RAISE EXCEPTION 'paralisi_narrative_damage_conflict';END IF;
  RETURN jsonb_build_object('genjutsu_server',combat_v2_genjutsu_internal.validate_attack_facts(t.outcome->'genjutsu_server'));
 END IF;RETURN '{}'::jsonb;
END $f$;

-- Aggregata integrazione lifecycle/report/reader. SOURCE ONLY, non installer autonomo.
-- Il contesto transazionale nomina la dichiarazione realmente in esecuzione nel resolver.
-- Nessun valore meccanico proviene dal GUC; tutti gli identificatori sono rivalidati sul clock nativo.
CREATE FUNCTION combat_v2_genjutsu_internal.resolution_enter(p_round uuid,p_declaration uuid) RETURNS void LANGUAGE plpgsql SECURITY DEFINER SET search_path='' AS $f$
DECLARE d public.combat_v2_declarations%ROWTYPE;r public.combat_v2_rounds%ROWTYPE;
BEGIN
 SELECT * INTO STRICT d FROM public.combat_v2_declarations WHERE id=p_declaration AND round_id=p_round;
 SELECT * INTO STRICT r FROM public.combat_v2_rounds WHERE id=p_round AND phase='risoluzione';
 IF NOT EXISTS(SELECT 1 FROM combat_v2_genjutsu_internal.effects WHERE session_id=r.session_id AND state IN('pending','active'))
  AND NOT EXISTS(SELECT 1 FROM combat_v2_genjutsu_internal.sources s JOIN public.combat_v2_declarations z ON z.id=s.declaration_id WHERE z.round_id=r.id)
  AND NOT EXISTS(SELECT 1 FROM combat_v2_genjutsu_internal.release_plans WHERE round_id=r.id) THEN
  PERFORM combat_v2_genjutsu_internal.resolution_leave();RETURN;END IF;
 IF d.state='annullata' THEN PERFORM combat_v2_genjutsu_internal.resolution_leave();RETURN;END IF;
 IF d.kind NOT IN('attacco','utilita','passa','movimento') OR d.state NOT IN('congelata','risolta','superflua') THEN
  RAISE EXCEPTION 'paralisi_resolution_declaration_invalid';END IF;
 IF EXISTS(SELECT 1 FROM public.combat_v2_round_reports WHERE round_id=r.id) OR NOT (
  EXISTS(SELECT 1 FROM combat_consumer_private.activities c WHERE c.session_id=r.session_id AND c.exchange_id=r.id AND c.turn_actor_id=d.actor_id)
  OR EXISTS(SELECT 1 FROM combat_panel_private.actor_turns t WHERE t.round_id=r.id AND t.actor_id=d.actor_id AND t.main_declaration_id=d.id)) THEN
  RAISE EXCEPTION 'paralisi_resolution_native_binding_required';END IF;
 PERFORM set_config('combat_v2_genjutsu_internal.resolution',jsonb_build_object('transaction_id',txid_current()::text,
  'round_id',r.id,'declaration_id',d.id,'session_id',r.session_id)::text,true);
END $f$;
CREATE FUNCTION combat_v2_genjutsu_internal.resolution_leave() RETURNS void LANGUAGE plpgsql SECURITY DEFINER SET search_path='' AS $f$
BEGIN PERFORM set_config('combat_v2_genjutsu_internal.resolution','',true);END $f$;

CREATE FUNCTION combat_v2_genjutsu_internal.event_binding(p_effect uuid,p_result jsonb) RETURNS jsonb LANGUAGE plpgsql STABLE SECURITY DEFINER SET search_path='' AS $f$
DECLARE e combat_v2_genjutsu_internal.effects%ROWTYPE;d public.combat_v2_declarations%ROWTYPE;
 r public.combat_v2_rounds%ROWTYPE;c jsonb;cur text;turn_id uuid;anchor uuid;decl uuid;adapter text;
BEGIN
 SELECT * INTO STRICT e FROM combat_v2_genjutsu_internal.effects WHERE id=p_effect;
 cur:=nullif(current_setting('combat_v2_genjutsu_internal.resolution',true),'');
 IF cur IS NOT NULL THEN
  c:=cur::jsonb;
  IF c->>'transaction_id' IS DISTINCT FROM txid_current()::text OR c->>'session_id' IS DISTINCT FROM e.session_id::text THEN
   RAISE EXCEPTION 'paralisi_resolution_context_conflict';END IF;
  SELECT * INTO STRICT d FROM public.combat_v2_declarations WHERE id=(c->>'declaration_id')::uuid
   AND round_id=(c->>'round_id')::uuid AND state IN('congelata','risolta','superflua');
  SELECT * INTO STRICT r FROM public.combat_v2_rounds WHERE id=d.round_id AND session_id=e.session_id AND phase='risoluzione';
  IF EXISTS(SELECT 1 FROM public.combat_v2_round_reports WHERE round_id=r.id) THEN RAISE EXCEPTION 'paralisi_event_after_report';END IF;
  SELECT t.id INTO turn_id FROM combat_panel_private.actor_turns t
   WHERE t.round_id=r.id AND t.actor_id=d.actor_id AND t.main_declaration_id=d.id;
  IF turn_id IS NULL THEN
   IF NOT EXISTS(SELECT 1 FROM combat_consumer_private.activities a WHERE a.session_id=e.session_id AND a.exchange_id=r.id AND a.turn_actor_id=d.actor_id) THEN
    RAISE EXCEPTION 'paralisi_resolution_clock_missing';END IF;
   turn_id:=r.id;adapter:='ordinary_v2';
  ELSE adapter:='master_v2';END IF;
  anchor:=d.actor_id;decl:=d.id;
 ELSE
  -- Turn start/end carries its exact native turn. No created_at interval or latest-row heuristic.
  IF p_result->>'turn_id' IS NOT NULL THEN
   turn_id:=(p_result->>'turn_id')::uuid;anchor:=e.target_actor_id;adapter:=e.adapter;
   IF adapter='ordinary_v2' THEN
    SELECT rr.* INTO STRICT r FROM public.combat_v2_rounds rr JOIN combat_consumer_private.activities a
     ON a.exchange_id=rr.id AND a.session_id=rr.session_id
     WHERE rr.id=turn_id AND rr.session_id=e.session_id AND a.turn_actor_id=anchor;
   ELSE
    SELECT rr.* INTO STRICT r FROM public.combat_v2_rounds rr JOIN combat_panel_private.actor_turns t ON t.round_id=rr.id
     WHERE t.id=turn_id AND t.actor_id=anchor AND rr.session_id=e.session_id;
   END IF;
  ELSE
   -- KO/upkeep outside an executing declaration binds to the actual current native clock.
   IF EXISTS(SELECT 1 FROM public.combat_v2_sessions WHERE id=e.session_id AND state IN('risolto','chiuso','annullato')) THEN
    RETURN jsonb_build_object('schema_version','paralisi-event-binding/1','session_id',e.session_id,'round_id',NULL,'declaration_id',NULL,'anchor_actor_id',NULL,'turn_id',NULL,'adapter',e.adapter,'audit_only',true);
   END IF;
   c:=combat_effects_private.personal_turn(e.session_id,e.target_actor_id);
   SELECT * INTO STRICT r FROM public.combat_v2_rounds WHERE id=(c->>'round_id')::uuid AND session_id=e.session_id;
   adapter:=c->>'adapter';turn_id:=(c->>'turn_id')::uuid;
   IF adapter='ordinary_v2' THEN
    SELECT a.turn_actor_id INTO STRICT anchor FROM combat_consumer_private.activities a WHERE a.exchange_id=r.id AND a.session_id=e.session_id;
    IF turn_id IS DISTINCT FROM r.id THEN RAISE EXCEPTION 'paralisi_ordinary_clock_mismatch';END IF;
   ELSE
    SELECT t.actor_id INTO STRICT anchor FROM combat_panel_private.actor_turns t WHERE t.id=turn_id AND t.round_id=r.id AND t.actor_id=e.target_actor_id;
   END IF;
  END IF;
  IF EXISTS(SELECT 1 FROM public.combat_v2_round_reports WHERE round_id=r.id) THEN
   RETURN jsonb_build_object('schema_version','paralisi-event-binding/1','session_id',e.session_id,'round_id',NULL,'declaration_id',NULL,'anchor_actor_id',NULL,'turn_id',NULL,'adapter',adapter,'audit_only',true);
  END IF;
  IF adapter='master_v2' THEN SELECT main_declaration_id INTO decl FROM combat_panel_private.actor_turns WHERE id=turn_id AND round_id=r.id AND actor_id=anchor;
  ELSE SELECT id INTO decl FROM public.combat_v2_declarations WHERE round_id=r.id AND actor_id=anchor AND kind IN('attacco','utilita','passa','movimento') AND state NOT IN('annullata');END IF;
 END IF;
 RETURN jsonb_build_object('schema_version','paralisi-event-binding/1','session_id',e.session_id,'round_id',r.id,'declaration_id',decl,
  'anchor_actor_id',anchor,'turn_id',turn_id,'adapter',adapter,'audit_only',false);
END $f$;

CREATE OR REPLACE FUNCTION combat_v2_genjutsu_internal.record_event(p_key text,p_effect uuid,p_result jsonb) RETURNS jsonb LANGUAGE plpgsql SECURITY DEFINER SET search_path='' AS $f$
DECLARE old combat_v2_genjutsu_internal.events%ROWTYPE;b jsonb;version bigint;
BEGIN
 SELECT * INTO old FROM combat_v2_genjutsu_internal.events WHERE event_key=p_key;
 IF FOUND THEN
  IF old.effect_id IS DISTINCT FROM p_effect OR old.result IS DISTINCT FROM p_result
   OR old.result_sha256 IS DISTINCT FROM public.combat_v2_sha256(old.result)
   OR old.binding_sha256 IS DISTINCT FROM public.combat_v2_sha256(old.binding) THEN RAISE EXCEPTION 'paralisi_event_conflict';END IF;
  RETURN old.result;
 END IF;
 SELECT state_version INTO STRICT version FROM combat_v2_genjutsu_internal.effects WHERE id=p_effect;
 b:=combat_v2_genjutsu_internal.event_binding(p_effect,p_result)||jsonb_build_object('effect_version',version);
 INSERT INTO combat_v2_genjutsu_internal.events(event_key,effect_id,result,result_sha256,binding,binding_sha256)
 VALUES(p_key,p_effect,p_result,public.combat_v2_sha256(p_result),b,public.combat_v2_sha256(b));RETURN p_result;
END $f$;

CREATE FUNCTION combat_v2_genjutsu_internal.event_public(p_key text) RETURNS jsonb LANGUAGE plpgsql STABLE SECURITY DEFINER SET search_path='' AS $f$
DECLARE v combat_v2_genjutsu_internal.events%ROWTYPE;e combat_v2_genjutsu_internal.effects%ROWTYPE;
 kind text;reason text;after_state text;rr jsonb;turn_id uuid;
BEGIN
 SELECT * INTO STRICT v FROM combat_v2_genjutsu_internal.events WHERE event_key=p_key;
 SELECT * INTO STRICT e FROM combat_v2_genjutsu_internal.effects WHERE id=v.effect_id;
 IF v.result_sha256 IS DISTINCT FROM public.combat_v2_sha256(v.result)
  OR v.binding_sha256 IS DISTINCT FROM public.combat_v2_sha256(v.binding)
  OR v.binding->>'schema_version' IS DISTINCT FROM 'paralisi-event-binding/1'
  OR v.binding->>'session_id' IS DISTINCT FROM e.session_id::text
  OR jsonb_typeof(v.binding->'effect_version') IS DISTINCT FROM 'number' OR (v.binding->>'effect_version')::bigint<1
  OR NOT combat_v2_genjutsu_internal.source_valid(e.source_declaration_id) THEN RAISE EXCEPTION 'paralisi_public_event_receipt_invalid';END IF;
 IF v.binding->'audit_only'='true'::jsonb THEN RETURN NULL;END IF;
 turn_id:=(v.binding->>'turn_id')::uuid;
 IF p_key LIKE 'apply:%' THEN
  IF p_key IS DISTINCT FROM 'apply:'||e.source_attack_target_id::text THEN RAISE EXCEPTION 'paralisi_public_event_key_invalid';END IF;
  rr:=combat_v2_genjutsu_internal.validate_attack_facts(v.result);
  IF rr->'applied' IS DISTINCT FROM 'true'::jsonb OR rr->>'effect_id' IS DISTINCT FROM e.id::text THEN RAISE EXCEPTION 'paralisi_public_apply_invalid';END IF;
  kind:='applied';reason:='applied';after_state:='pending';
 ELSIF p_key LIKE 'start:%' THEN
  IF p_key IS DISTINCT FROM 'start:'||e.id::text||':'||turn_id::text THEN RAISE EXCEPTION 'paralisi_public_event_key_invalid';END IF;
  IF v.result-ARRAY['effect_id','turn_id','movement_only'] IS DISTINCT FROM '{}'::jsonb OR v.result->'movement_only' IS DISTINCT FROM 'true'::jsonb
   OR v.result->>'turn_id' IS DISTINCT FROM turn_id::text THEN RAISE EXCEPTION 'paralisi_public_start_invalid';END IF;
  kind:='movement_block_started';reason:='target_turn_started';after_state:='active';
 ELSIF p_key LIKE 'end:%' THEN
  IF p_key IS DISTINCT FROM 'end:'||e.id::text||':'||turn_id::text THEN RAISE EXCEPTION 'paralisi_public_event_key_invalid';END IF;
  IF v.result-ARRAY['effect_id','turn_id','expired'] IS DISTINCT FROM '{}'::jsonb OR v.result->'expired' IS DISTINCT FROM 'true'::jsonb
   OR v.result->>'turn_id' IS DISTINCT FROM turn_id::text THEN RAISE EXCEPTION 'paralisi_public_end_invalid';END IF;
  kind:='movement_block_expired';reason:='target_personal_turn_end';after_state:='expired';
 ELSIF p_key LIKE 'terminate:%' THEN
  IF p_key IS DISTINCT FROM 'terminate:'||e.id::text THEN RAISE EXCEPTION 'paralisi_public_event_key_invalid';END IF;
  IF v.result-ARRAY['effect_id','ended','actor_id'] IS DISTINCT FROM '{}'::jsonb OR v.result->'ended' IS DISTINCT FROM 'true'::jsonb THEN RAISE EXCEPTION 'paralisi_public_terminal_invalid';END IF;
  kind:='movement_block_ended';after_state:='ended';
  reason:=CASE WHEN v.result->>'actor_id' IS NULL THEN 'combat_end' WHEN v.result->>'actor_id'=e.source_actor_id::text THEN 'source_inoperative'
   WHEN v.result->>'actor_id'=e.target_actor_id::text THEN 'target_inoperative' ELSE NULL END;
  IF reason IS NULL THEN RAISE EXCEPTION 'paralisi_public_terminal_actor_invalid';END IF;
 ELSIF p_key LIKE 'release:%' THEN
  IF p_key IS DISTINCT FROM 'release:'||(v.binding->>'declaration_id') THEN RAISE EXCEPTION 'paralisi_public_event_key_invalid';END IF;
  rr:=combat_v2_genjutsu_internal.validate_release_facts(v.result->'mental_release');
  IF rr->'released' IS DISTINCT FROM 'true'::jsonb THEN RETURN NULL;END IF;
  kind:='movement_block_released';after_state:='ended';reason:=CASE WHEN rr->>'mode'='kai' THEN 'kai_released' ELSE 'mental_contest_released' END;
 ELSE RAISE EXCEPTION 'paralisi_public_event_kind_unknown';END IF;
 IF v.result->>'effect_id' IS DISTINCT FROM e.id::text AND p_key NOT LIKE 'release:%' THEN RAISE EXCEPTION 'paralisi_public_effect_mismatch';END IF;
 RETURN jsonb_build_object('event_id',public.combat_v2_sha256(to_jsonb(p_key)),'effect_id',e.id,'source_actor_id',e.source_actor_id,
  'target_actor_id',e.target_actor_id,'source_declaration_id',e.source_declaration_id,'kind',kind,'reason',reason,'state_after',after_state,
  'movement_blocked_after',after_state='active','turn_id',turn_id);
END $f$;

CREATE FUNCTION combat_v2_genjutsu_internal.declaration_events(p_declaration uuid) RETURNS jsonb LANGUAGE plpgsql STABLE SECURITY DEFINER SET search_path='' AS $f$
DECLARE d public.combat_v2_declarations%ROWTYPE;v combat_v2_genjutsu_internal.events%ROWTYPE;anchor uuid;pub jsonb;
 result jsonb:='[]'::jsonb;seen text[]:='{}';versions text[]:='{}';version_key text;sid uuid;n integer;
BEGIN
 SELECT * INTO STRICT d FROM public.combat_v2_declarations WHERE id=p_declaration;
 SELECT session_id INTO STRICT sid FROM public.combat_v2_rounds WHERE id=d.round_id;
 FOR v IN SELECT * FROM combat_v2_genjutsu_internal.events WHERE binding->>'round_id'=d.round_id::text AND binding->'audit_only'='false'::jsonb
  ORDER BY (binding->>'effect_version')::bigint,effect_id,event_key LOOP
  IF v.binding->>'session_id' IS DISTINCT FROM sid::text THEN RAISE EXCEPTION 'paralisi_event_session_mismatch';END IF;
  anchor:=(v.binding->>'declaration_id')::uuid;
  IF anchor IS NULL THEN
   IF v.binding->>'adapter'='master_v2' THEN
    SELECT t.main_declaration_id INTO anchor FROM combat_panel_private.actor_turns t
     WHERE t.id=(v.binding->>'turn_id')::uuid AND t.round_id=d.round_id AND t.actor_id=(v.binding->>'anchor_actor_id')::uuid;
   ELSE
    SELECT count(*),min(z.id::text)::uuid INTO n,anchor FROM public.combat_v2_declarations z
     JOIN combat_consumer_private.activities c ON c.exchange_id=z.round_id AND c.turn_actor_id=z.actor_id AND c.session_id=sid
     WHERE z.round_id=d.round_id AND z.actor_id=(v.binding->>'anchor_actor_id')::uuid AND z.kind IN('attacco','utilita','passa','movimento') AND z.state NOT IN('annullata');
    IF n<>1 THEN RAISE EXCEPTION 'paralisi_event_native_main_not_unique';END IF;
   END IF;
  END IF;
  IF anchor IS NULL OR NOT EXISTS(SELECT 1 FROM public.combat_v2_declarations z WHERE z.id=anchor AND z.round_id=d.round_id
   AND z.actor_id=(v.binding->>'anchor_actor_id')::uuid AND z.kind IN('attacco','utilita','passa','movimento') AND z.state IN('risolta','superflua')) THEN
   RAISE EXCEPTION 'paralisi_event_native_declaration_missing';END IF;
  IF anchor<>d.id THEN CONTINUE;END IF;
  pub:=combat_v2_genjutsu_internal.event_public(v.event_key);IF pub IS NULL THEN CONTINUE;END IF;
  -- Same native roster projection as Flow participant_id and scene_snapshot_v2 actors[].id.
  IF EXISTS(SELECT 1 FROM combat_consumer_private.activities WHERE session_id=sid) THEN
   IF NOT EXISTS(SELECT 1 FROM combat_consumer_private.members WHERE session_id=sid AND actor_id=(pub->>'source_actor_id')::uuid)
    OR NOT EXISTS(SELECT 1 FROM combat_consumer_private.members WHERE session_id=sid AND actor_id=(pub->>'target_actor_id')::uuid) THEN
    RAISE EXCEPTION 'paralisi_event_actor_not_public_member';END IF;
  ELSE
   IF NOT EXISTS(SELECT 1 FROM public.combat_v2_actors WHERE id=(pub->>'source_actor_id')::uuid AND session_id=sid AND actor_kind='pg' AND companion_id IS NULL)
    OR NOT EXISTS(SELECT 1 FROM public.combat_v2_actors WHERE id=(pub->>'target_actor_id')::uuid AND session_id=sid AND actor_kind='pg' AND companion_id IS NULL) THEN
    RAISE EXCEPTION 'paralisi_event_actor_not_session_roster';END IF;
  END IF;
  version_key:=v.effect_id::text||':'||(v.binding->>'effect_version');
  IF pub->>'event_id'=ANY(seen) OR version_key=ANY(versions) OR cardinality(seen)>=64 THEN RAISE EXCEPTION 'paralisi_event_public_bound_exceeded';END IF;
  seen:=array_append(seen,pub->>'event_id');versions:=array_append(versions,version_key);result:=result||jsonb_build_array(pub);
 END LOOP;RETURN result;
END $f$;

CREATE FUNCTION combat_v2_genjutsu_internal.report_projection(p_declaration uuid) RETURNS jsonb LANGUAGE plpgsql STABLE SECURITY DEFINER SET search_path='' AS $f$
DECLARE d public.combat_v2_declarations%ROWTYPE;p combat_v2_genjutsu_internal.release_plans%ROWTYPE;
 a jsonb:='null'::jsonb;r jsonb:='null'::jsonb;events jsonb;
BEGIN
 SELECT * INTO STRICT d FROM public.combat_v2_declarations WHERE id=p_declaration;
 IF d.state NOT IN('risolta','superflua') THEN RETURN '{}'::jsonb;END IF;
 IF EXISTS(SELECT 1 FROM combat_v2_genjutsu_internal.sources WHERE declaration_id=d.id) THEN
  a:=combat_v2_genjutsu_internal.raw_attack_facts(d.id)->'genjutsu_server';END IF;
 SELECT * INTO p FROM combat_v2_genjutsu_internal.release_plans WHERE declaration_id=d.id;
 IF FOUND THEN
  IF d.state<>'risolta' OR p.result IS DISTINCT FROM d.outcome OR p.result_sha256 IS DISTINCT FROM public.combat_v2_sha256(p.result)
   OR p.declaration_sha256 IS DISTINCT FROM combat_effects_private.declaration_fingerprint(d.id)
   OR p.source_sha256 IS DISTINCT FROM public.combat_v2_sha256(p.source) THEN RAISE EXCEPTION 'paralisi_release_report_binding_invalid';END IF;
  r:=combat_v2_genjutsu_internal.validate_release_facts(p.result->'mental_release');
 END IF;
 events:=combat_v2_genjutsu_internal.declaration_events(d.id);
 IF a='null'::jsonb AND r='null'::jsonb AND events='[]'::jsonb THEN RETURN '{}'::jsonb;END IF;
 RETURN jsonb_build_object('contract','paralisi-report/1','round_id',d.round_id,'declaration_id',d.id,'attack',a,'release',r,'events',events);
END $f$;

CREATE FUNCTION combat_v2_genjutsu_internal.report_facts(p_declaration uuid) RETURNS jsonb LANGUAGE plpgsql STABLE SECURITY DEFINER SET search_path='' AS $f$
DECLARE d public.combat_v2_declarations%ROWTYPE;rr public.combat_v2_round_reports%ROWTYPE;entry jsonb;expected jsonb;n integer;
BEGIN
 SELECT * INTO STRICT d FROM public.combat_v2_declarations WHERE id=p_declaration;
 SELECT h.* INTO rr FROM public.combat_v2_rounds r JOIN public.combat_v2_round_reports h ON h.id=r.report_id AND h.round_id=r.id WHERE r.id=d.round_id;
 IF rr.id IS NULL THEN RETURN '{}'::jsonb;END IF;
 IF rr.mechanics_sha256 IS DISTINCT FROM public.combat_v2_sha256(rr.mechanics) THEN RAISE EXCEPTION 'paralisi_report_hash_invalid';END IF;
 SELECT count(*) INTO n FROM jsonb_array_elements(rr.mechanics->'declarations') x WHERE x->>'id'=d.id::text;
 IF n<>1 THEN RAISE EXCEPTION 'paralisi_report_declaration_not_unique';END IF;
 SELECT x INTO STRICT entry FROM jsonb_array_elements(rr.mechanics->'declarations') x WHERE x->>'id'=d.id::text;
 expected:=combat_v2_genjutsu_internal.report_projection(d.id);
 IF expected='{}'::jsonb AND coalesce(entry->'genjutsu_facts','{}'::jsonb)='{}'::jsonb THEN RETURN '{}'::jsonb;END IF;
 IF entry->'genjutsu_facts' IS DISTINCT FROM expected OR entry->>'actor' IS DISTINCT FROM d.actor_id::text
  OR entry->>'kind' IS DISTINCT FROM d.kind OR entry->>'state' IS DISTINCT FROM d.state OR entry->'outcome' IS DISTINCT FROM d.outcome THEN
  RAISE EXCEPTION 'paralisi_report_event_binding_invalid';END IF;
 RETURN expected;
END $f$;

CREATE OR REPLACE FUNCTION combat_v2_genjutsu_internal.narrative_facts(p_declaration uuid) RETURNS jsonb LANGUAGE plpgsql STABLE SECURITY DEFINER SET search_path='' AS $f$
DECLARE f jsonb;result jsonb:='{}'::jsonb;
BEGIN
 f:=combat_v2_genjutsu_internal.report_facts(p_declaration);IF f='{}'::jsonb THEN RETURN result;END IF;
 IF f->'attack'<>'null'::jsonb THEN result:=result||jsonb_build_object('genjutsu_server',f->'attack');END IF;
 IF f->'release'<>'null'::jsonb THEN result:=result||jsonb_build_object('result',jsonb_build_object('mental_release',f->'release'));END IF;
 IF jsonb_array_length(f->'events')>0 THEN result:=result||jsonb_build_object('genjutsu_events',jsonb_build_object('contract','paralisi-events/1',
  'round_id',f->'round_id','declaration_id',f->'declaration_id','events',f->'events'));END IF;RETURN result;
END $f$;
CREATE OR REPLACE FUNCTION combat_v2_genjutsu_internal.narrative_supported(p_declaration uuid) RETURNS boolean LANGUAGE plpgsql STABLE SECURITY DEFINER SET search_path='' AS $f$
DECLARE f jsonb;
BEGIN f:=combat_v2_genjutsu_internal.report_facts(p_declaration);RETURN f<>'{}'::jsonb;END $f$;


-- Never expose helpers or tables. New client surfaces use existing guarded panel RPCs.
DO $close$
DECLARE r record;
BEGIN
 FOR r IN SELECT c.relname FROM pg_class c JOIN pg_namespace n ON n.oid=c.relnamespace WHERE n.nspname='combat_v2_genjutsu_internal' AND c.relkind='r' LOOP
  EXECUTE format('ALTER TABLE combat_v2_genjutsu_internal.%I ENABLE ROW LEVEL SECURITY',r.relname);
  EXECUTE format('ALTER TABLE combat_v2_genjutsu_internal.%I FORCE ROW LEVEL SECURITY',r.relname);
  EXECUTE format('REVOKE ALL ON TABLE combat_v2_genjutsu_internal.%I FROM PUBLIC,anon,authenticated,service_role',r.relname);
 END LOOP;
 FOR r IN SELECT p.oid::regprocedure f FROM pg_proc p JOIN pg_namespace n ON n.oid=p.pronamespace WHERE n.nspname='combat_v2_genjutsu_internal' LOOP
  EXECUTE format('ALTER FUNCTION %s OWNER TO postgres',r.f);
  EXECUTE format('REVOKE ALL ON FUNCTION %s FROM PUBLIC,anon,authenticated,service_role',r.f);
 END LOOP;
END $close$;

-- COMPONENT: cure_private
-- SOURCE ONLY palmo-curativo/1. Non eseguire separatamente dai hook e dalla Root composta.
-- Nessun nuovo GRANT client; RLS e ACL private esplicite; entrambi i gate OFF.
CREATE TABLE combat_panel_private.cure_gate_v1 (
 singleton boolean PRIMARY KEY DEFAULT true CHECK(singleton),
 staff_enabled boolean NOT NULL DEFAULT false,
 public_enabled boolean NOT NULL DEFAULT false,
 contract_version text NOT NULL DEFAULT 'palmo-curativo/1' CHECK(contract_version='palmo-curativo/1')
);
INSERT INTO combat_panel_private.cure_gate_v1(singleton) VALUES(true);
CREATE TABLE combat_panel_private.cure_staff_profiles_v1 (
 actor_id uuid PRIMARY KEY REFERENCES public.combat_v2_actors(id),
 session_id uuid NOT NULL REFERENCES public.combat_v2_sessions(id),
 context_id uuid NOT NULL REFERENCES combat_panel_private.contexts(id),
 controller_user uuid NOT NULL,
 controller_version bigint NOT NULL CHECK(controller_version>0),
 ability jsonb NOT NULL CHECK(jsonb_typeof(ability)='object'),
 proof_sha256 text NOT NULL CHECK(proof_sha256 ~ '^[0-9a-f]{64}$'),
 request_key uuid NOT NULL UNIQUE,
 created_at timestamptz NOT NULL DEFAULT clock_timestamp()
);
CREATE TABLE combat_panel_private.cure_preparations_v1 (
 request_key uuid PRIMARY KEY,
 transaction_id bigint NOT NULL,
 session_id uuid NOT NULL REFERENCES public.combat_v2_sessions(id),
 round_id uuid NOT NULL REFERENCES public.combat_v2_rounds(id),
 actor_id uuid NOT NULL REFERENCES public.combat_v2_actors(id),
 target_actor_id uuid NOT NULL REFERENCES public.combat_v2_actors(id),
 controller_user uuid NOT NULL,
 controller_version bigint NOT NULL CHECK(controller_version>0),
 source jsonb NOT NULL CHECK(jsonb_typeof(source)='object'),
 source_sha256 text NOT NULL CHECK(source_sha256 ~ '^[0-9a-f]{64}$'),
 declaration_id uuid UNIQUE REFERENCES public.combat_v2_declarations(id),
 created_at timestamptz NOT NULL DEFAULT clock_timestamp(),
 UNIQUE(round_id,actor_id,request_key)
);
CREATE TABLE combat_panel_private.cure_ledger_v1 (
 declaration_id uuid PRIMARY KEY REFERENCES public.combat_v2_declarations(id),
 session_id uuid NOT NULL REFERENCES public.combat_v2_sessions(id),
 round_id uuid NOT NULL REFERENCES public.combat_v2_rounds(id),
 actor_id uuid NOT NULL REFERENCES public.combat_v2_actors(id),
 target_actor_id uuid NOT NULL REFERENCES public.combat_v2_actors(id),
 hp_before integer NOT NULL CHECK(hp_before>=0),
 hp_after integer NOT NULL CHECK(hp_after>=hp_before),
 hp_max integer NOT NULL CHECK(hp_max>=hp_after),
 expected_gain integer NOT NULL CHECK(expected_gain>0),
 committed_gain integer NOT NULL CHECK(committed_gain>=0 AND committed_gain<=expected_gain),
 applied_real_gain integer NOT NULL DEFAULT 0 CHECK(applied_real_gain>=0 AND applied_real_gain<=committed_gain),
 is_simulated boolean NOT NULL,
 facts jsonb NOT NULL CHECK(jsonb_typeof(facts)='object'),
 created_at timestamptz NOT NULL DEFAULT clock_timestamp(),
 CHECK(hp_after-hp_before=committed_gain),
 CHECK((is_simulated AND applied_real_gain=0) OR(NOT is_simulated AND applied_real_gain=committed_gain))
);
ALTER TABLE combat_panel_private.cure_gate_v1 ENABLE ROW LEVEL SECURITY;
ALTER TABLE combat_panel_private.cure_staff_profiles_v1 ENABLE ROW LEVEL SECURITY;
ALTER TABLE combat_panel_private.cure_preparations_v1 ENABLE ROW LEVEL SECURITY;
ALTER TABLE combat_panel_private.cure_ledger_v1 ENABLE ROW LEVEL SECURITY;
REVOKE ALL ON TABLE combat_panel_private.cure_gate_v1,combat_panel_private.cure_staff_profiles_v1,
 combat_panel_private.cure_preparations_v1,combat_panel_private.cure_ledger_v1 FROM PUBLIC,anon,authenticated;


-- Autorità simmetrica sulle operazioni volontarie, comprese porte native dirette.
-- I tick upkeep/KO/chiusura/release automatici non sono azioni volontarie.
CREATE TABLE combat_panel_private.cure_voluntary_actions_v1 (
 actor_id uuid NOT NULL REFERENCES public.combat_v2_actors(id),
 round_id uuid NOT NULL REFERENCES public.combat_v2_rounds(id),
 source_kind text NOT NULL,
 source_key text NOT NULL,
 created_at timestamptz NOT NULL DEFAULT clock_timestamp(),
 PRIMARY KEY(actor_id,round_id,source_kind,source_key)
);
ALTER TABLE combat_panel_private.cure_voluntary_actions_v1 ENABLE ROW LEVEL SECURITY;
REVOKE ALL ON TABLE combat_panel_private.cure_voluntary_actions_v1 FROM PUBLIC,anon,authenticated;


-- Lo stesso adapter e resolver sono predisposti per il rilascio dopo Staff PASS.
-- Il gate pubblico resta OFF; nessun enable è contenuto qui.
CREATE OR REPLACE FUNCTION combat_panel_private.cure_persistent_execution_scope_v1(p_actor uuid)
RETURNS boolean LANGUAGE sql STABLE SECURITY DEFINER SET search_path='' AS $cure$
 SELECT EXISTS(SELECT 1 FROM public.combat_v2_actors a
 JOIN public.combat_v2_sessions s ON s.id=a.session_id
 JOIN public.locations l ON l.id=s.location_id
 JOIN public.characters c ON c.id=a.character_id AND c.user_id=a.controller_user
 LEFT JOIN combat_consumer_private.activities ca ON ca.session_id=s.id
 LEFT JOIN combat_panel_private.master_panel_sessions mp ON mp.master_session_id=s.master_session_id
 LEFT JOIN public.master_v2_sessions m ON m.id=s.master_session_id
 WHERE a.id=p_actor AND a.actor_kind='pg' AND a.companion_id IS NULL
 AND s.state='in_corso' AND s.closed_at IS NULL AND s.user_test_context_id IS NULL
 AND l.is_active AND l.is_test IS FALSE AND public.combat_v2_values_written(s.id)
 AND NOT combat_panel_private.uses_simulated_pools(s.id)
 AND coalesce(c.corporation,'') ~* 'medic'
 AND EXISTS(SELECT 1 FROM public.character_abilities ca JOIN public.clan_techniques t ON t.id=ca.technique_id
  WHERE ca.character_id=c.id AND ca.state='attiva' AND t.id='c47814d2-ef27-4967-87ad-da633b0f4d78'
  AND t.is_active AND t.uso='principale' AND t.gittata='contatto' AND t.chakra_cost=20 AND t.danno_base=0)
 AND NOT EXISTS(SELECT 1 FROM public.mission_run_state ms WHERE ms.master_session_id=s.master_session_id)
 AND NOT EXISTS(SELECT 1 FROM combat_consumer_private.narrative_authorities na WHERE na.master_session_id=s.master_session_id)
 AND NOT EXISTS(SELECT 1 FROM exam_regia_private.bindings b WHERE b.combat_session_id=s.id)
 AND NOT EXISTS(SELECT 1 FROM exam_human_private.native_bindings b WHERE b.master_session_id=s.master_session_id)
 AND ((s.source_kind='ordinary' AND s.master_session_id IS NULL AND ca.user_test_context_id IS NULL
  AND ca.phase NOT IN('setup','closed','suspended') AND ca.policy_id='free_duel_nonlethal_real_resources_v1'
  AND EXISTS(SELECT 1 FROM combat_consumer_private.members cm WHERE cm.session_id=s.id AND cm.actor_id=a.id AND cm.character_id=a.character_id))
 OR(s.source_kind='master' AND m.owner_kind='human' AND m.tipo='duello' AND m.mission_id IS NULL
  AND m.closed_at IS NULL AND m.suspended_at IS NULL AND mp.policy_id='master_game_resources_v1')));
$cure$;
REVOKE ALL ON FUNCTION combat_panel_private.cure_persistent_execution_scope_v1(uuid) FROM PUBLIC,anon,authenticated;

CREATE OR REPLACE FUNCTION combat_panel_private.cure_persistent_scope_v1(p_actor uuid)
RETURNS boolean LANGUAGE sql STABLE SECURITY DEFINER SET search_path='' AS $cure$
 SELECT EXISTS(SELECT 1 FROM combat_panel_private.cure_gate_v1 WHERE singleton AND public_enabled)
 AND combat_panel_private.cure_persistent_execution_scope_v1(p_actor);
$cure$;
REVOKE ALL ON FUNCTION combat_panel_private.cure_persistent_scope_v1(uuid) FROM PUBLIC,anon,authenticated;

CREATE OR REPLACE FUNCTION combat_panel_private.cure_staff_execution_scope_v1(p_actor uuid)
RETURNS boolean LANGUAGE sql STABLE SECURITY DEFINER SET search_path='' AS $cure$
 SELECT EXISTS(SELECT 1 FROM public.combat_v2_actors a
 JOIN public.combat_v2_sessions s ON s.id=a.session_id
 JOIN public.locations l ON l.id=s.location_id
 LEFT JOIN combat_consumer_private.activities ca ON ca.session_id=s.id
 LEFT JOIN combat_panel_private.master_panel_sessions mp ON mp.master_session_id=s.master_session_id
 LEFT JOIN public.master_v2_sessions m ON m.id=s.master_session_id
 WHERE a.id=p_actor AND a.actor_kind='pg' AND a.companion_id IS NULL
 AND a.character_id IN('2a877f02-4993-4e65-9172-7d29f08c5b86'::uuid,'6bceee99-974f-426b-8d92-38b43b4a4267'::uuid)
 AND a.controller_user IS NOT NULL
 AND s.state='in_corso' AND s.closed_at IS NULL AND s.user_test_context_id IS NULL
 AND l.id='0b85f354-9cdb-47e1-baf9-3d266bb7e06b'::uuid AND l.is_test AND l.is_active
 AND public.combat_v2_values_written(s.id) IS FALSE AND combat_panel_private.uses_simulated_pools(s.id)
 AND combat_effects_private.staff_session_allowed(s.id)
 AND NOT EXISTS(SELECT 1 FROM public.combat_v2_actors x WHERE x.session_id=s.id AND x.actor_kind='pg'
   AND x.character_id NOT IN('2a877f02-4993-4e65-9172-7d29f08c5b86'::uuid,'6bceee99-974f-426b-8d92-38b43b4a4267'::uuid))
 AND NOT EXISTS(SELECT 1 FROM public.mission_run_state ms WHERE ms.master_session_id=s.master_session_id)
 AND NOT EXISTS(SELECT 1 FROM combat_consumer_private.narrative_authorities na WHERE na.master_session_id=s.master_session_id)
 AND NOT EXISTS(SELECT 1 FROM exam_human_private.native_bindings b WHERE b.master_session_id=s.master_session_id)
 AND ((s.source_kind='ordinary' AND s.master_session_id IS NULL AND ca.user_test_context_id IS NULL
  AND ca.phase NOT IN('setup','closed','suspended') AND ca.policy_id='staff_test_no_persistent_resources_v1'
  AND EXISTS(SELECT 1 FROM combat_consumer_private.members cm WHERE cm.session_id=s.id AND cm.actor_id=a.id AND cm.character_id=a.character_id))
 OR(s.source_kind='master' AND m.owner_kind='human' AND m.tipo='duello' AND m.mission_id IS NULL
  AND m.closed_at IS NULL AND m.suspended_at IS NULL AND mp.policy_id='staff_test_no_persistent_resources_v1')));
$cure$;

CREATE OR REPLACE FUNCTION combat_panel_private.cure_staff_scope_v1(p_actor uuid)
RETURNS boolean LANGUAGE sql STABLE SECURITY DEFINER SET search_path='' AS $cure$
 SELECT EXISTS(SELECT 1 FROM combat_panel_private.cure_gate_v1 WHERE singleton AND staff_enabled)
 AND combat_panel_private.cure_staff_execution_scope_v1(p_actor);
$cure$;
REVOKE ALL ON FUNCTION combat_panel_private.cure_staff_execution_scope_v1(uuid) FROM PUBLIC,anon,authenticated;

CREATE OR REPLACE FUNCTION combat_panel_private.cure_profile_v1(p_actor uuid)
RETURNS jsonb LANGUAGE sql STABLE SECURITY DEFINER SET search_path='' AS $cure$
 SELECT jsonb_build_object('source','clan','id','c47814d2-ef27-4967-87ad-da633b0f4d78','name','Palmo Curativo',
  'kind','Medica','usage','principale','defensive',false,'di_scena',false,'diversivo',false,
  'consumption_type','ad_utilizzo','range','contatto','chakra_cost',20,'damage_base',0)
 WHERE combat_panel_private.cure_persistent_scope_v1(p_actor)
 AND EXISTS(SELECT 1 FROM public.combat_v2_actors a CROSS JOIN LATERAL jsonb_array_elements(
  coalesce(a.mechanics_snapshot->'abilities','[]')) v WHERE a.id=p_actor
  AND v->>'source'='clan' AND v->>'id'='c47814d2-ef27-4967-87ad-da633b0f4d78')
 UNION ALL
 SELECT p.ability FROM combat_panel_private.cure_staff_profiles_v1 p
 JOIN public.combat_v2_actors a ON a.id=p.actor_id AND a.session_id=p.session_id
  AND a.controller_user=p.controller_user AND a.controller_version=p.controller_version
 WHERE p.actor_id=p_actor AND combat_panel_private.cure_staff_scope_v1(a.id)
 AND a.mechanics_snapshot->'cure_staff_profile'=jsonb_build_object('contract','palmo-curativo/1',
   'context_id',p.context_id,'proof_sha256',p.proof_sha256)
 AND (SELECT count(*) FROM jsonb_array_elements(coalesce(a.mechanics_snapshot->'abilities','[]')) v WHERE v=p.ability)=1;
$cure$;

CREATE OR REPLACE FUNCTION combat_panel_private.cure_contact_v1(p_actor uuid,p_target uuid)
RETURNS jsonb LANGUAGE plpgsql STABLE SECURITY DEFINER SET search_path='' AS $cure$
DECLARE a public.combat_v2_actors%ROWTYPE;t public.combat_v2_actors%ROWTYPE;
 i combat_spatial.arena_instances%ROWTYPE;ab combat_spatial.actor_states%ROWTYPE;tb combat_spatial.actor_states%ROWTYPE;
BEGIN
 SELECT * INTO a FROM public.combat_v2_actors WHERE id=p_actor;
 SELECT * INTO t FROM public.combat_v2_actors WHERE id=p_target;
 IF a.id IS NULL OR t.id IS NULL OR a.session_id<>t.session_id OR a.team_key<>t.team_key
  OR a.state<>'attivo' OR coalesce((a.mechanics_snapshot->>'vita')::integer,0)<=0
  OR t.state NOT IN('attivo','fuori') OR t.companion_id IS NOT NULL
  OR (t.state='fuori' AND coalesce((t.mechanics_snapshot->>'vita')::integer,-1)<>0)
  OR jsonb_typeof(t.mechanics_snapshot->'vita') IS DISTINCT FROM 'number'
  OR jsonb_typeof(t.mechanics_snapshot->'vita_max') IS DISTINCT FROM 'number'
  OR (t.mechanics_snapshot->>'vita')::integer<0
  OR (t.mechanics_snapshot->>'vita_max')::integer<=0
  OR (t.mechanics_snapshot->>'vita')::integer>(t.mechanics_snapshot->>'vita_max')::integer THEN RETURN NULL; END IF;
 SELECT * INTO i FROM combat_spatial.arena_instances WHERE encounter_id=a.session_id
  AND context_source IN('ordinary','panel_master') AND state='open';
 IF i.instance_id IS NULL THEN RETURN NULL; END IF;
 SELECT * INTO ab FROM combat_spatial.actor_states WHERE instance_id=i.instance_id AND actor_id=a.id AND state='active';
 SELECT * INTO tb FROM combat_spatial.actor_states WHERE instance_id=i.instance_id AND actor_id=t.id AND state='active';
 IF ab.actor_id IS NULL OR tb.actor_id IS NULL OR NOT EXISTS(SELECT 1 FROM combat_spatial.viewer_grants
  WHERE instance_id=i.instance_id AND viewer_principal_id=exam_regia_private.actor_principal(a.id,a.controller_user)
  AND subject_actor_id=t.id AND can_view_map) THEN RETURN NULL; END IF;
 IF a.id<>t.id AND (combat_spatial.distance_m(ab.x_m,ab.y_m,tb.x_m,tb.y_m)>2
  OR combat_spatial.path_first_block_t(i.instance_id,a.id,ab.x_m,ab.y_m,tb.x_m,tb.y_m,t.id)<1) THEN RETURN NULL;END IF;
 RETURN jsonb_build_object('instance_id',i.instance_id,'actor_body_version',ab.body_version,
  'target_body_version',tb.body_version,'actor_x',ab.x_m,'actor_y',ab.y_m,'target_x',tb.x_m,'target_y',tb.y_m);
END $cure$;

CREATE OR REPLACE FUNCTION combat_panel_private.cure_turn_used_v1(p_round uuid,p_actor uuid)
RETURNS boolean LANGUAGE sql STABLE SECURITY DEFINER SET search_path='' AS $cure$
 SELECT EXISTS(SELECT 1 FROM public.combat_v2_declarations d WHERE d.round_id=p_round AND d.actor_id=p_actor
  AND d.sanitized_intent#>>'{server_ability,cure_contract}'='palmo-curativo/1');
$cure$;

-- Classificazione unica usata dal trigger e dalla lettura indipendente del turno.
-- Sono prove del server: offerta privata consumata, richiesta e binding/ricevuta
-- del preparatore. Nessun flag preso dal command o dalla prosa del client.
CREATE OR REPLACE FUNCTION combat_panel_private.cure_neutral_preset_v1(
 p_offer uuid,p_request uuid,p_principal uuid,p_envelope jsonb)
RETURNS boolean LANGUAGE plpgsql STABLE SECURITY DEFINER SET search_path='' AS $cure$
DECLARE o combat_panel_private.offers%ROWTYPE;c combat_panel_private.contexts%ROWTYPE;
 a public.combat_v2_actors%ROWTYPE;original combat_consumer_private.offers%ROWTYPE;
 raw jsonb;receipt jsonb;binding jsonb;proof jsonb;ability jsonb;expected jsonb;
 domain text;tbl text;version text;opkey text;dispatch text;operation text;tid uuid;
BEGIN
 SELECT * INTO o FROM combat_panel_private.offers WHERE id=p_offer AND principal_user=p_principal
  AND kind='control' AND operation='control' AND requires_role IS FALSE
  AND state='consumed' AND consumed_request_key=p_request;
 IF o.id IS NULL THEN RETURN false;END IF;
 SELECT * INTO c FROM combat_panel_private.contexts WHERE id=o.context_id AND principal_user=p_principal;
 SELECT * INTO a FROM public.combat_v2_actors WHERE id=o.actor_id AND session_id=c.activity_id;
 IF a.id IS NULL OR c.command_actor_id IS DISTINCT FROM a.id
 OR NOT combat_panel_private.cure_staff_execution_scope_v1(a.id) THEN RETURN false;END IF;
 receipt:=p_envelope->'receipt';
 IF receipt->>'request_key' IS DISTINCT FROM p_request::text OR receipt->>'operation' IS DISTINCT FROM 'control'
 OR receipt->'values_written' IS DISTINCT FROM 'false'::jsonb
 OR coalesce(receipt->'declaration_id','null'::jsonb) IS DISTINCT FROM 'null'::jsonb
 OR coalesce(receipt->'report_id','null'::jsonb) IS DISTINCT FROM 'null'::jsonb THEN RETURN false;END IF;
 IF o.source_payload=jsonb_build_object('adapter',c.activity_kind,'dispatch','cure_staff_profile','cure_contract','palmo-curativo/1') THEN
  -- Palmo usa l'offerta comune direttamente, anche in ordinario.
  SELECT to_jsonb(p) INTO binding FROM combat_panel_private.cure_staff_profiles_v1 p
   WHERE p.actor_id=a.id AND p.session_id=a.session_id AND p.context_id=c.id
    AND p.controller_user=p_principal AND p.request_key=p_request;
  RETURN binding IS NOT NULL AND binding->>'proof_sha256'=public.combat_v2_sha256(jsonb_build_object(
   'contract','palmo-curativo/1','actor_id',a.id,'session_id',a.session_id,'context_id',c.id,
   'controller',p_principal,'controller_version',binding->'controller_version','ability',binding->'ability'));
 END IF;

 IF c.activity_kind='master_v2' THEN
  raw:=o.source_payload;
  IF raw->>'adapter' IS DISTINCT FROM 'master_v2' THEN RETURN false;END IF;
 ELSIF c.activity_kind='ordinary_v2' THEN
  SELECT * INTO original FROM combat_consumer_private.offers
   WHERE id=(o.source_payload->>'source_offer_id')::uuid AND operation='control'
    AND session_id=c.activity_id AND state='consumed' AND consumed_request_key=p_request;
  IF original.id IS NULL OR o.source_payload IS DISTINCT FROM jsonb_build_object('adapter','ordinary_v2',
   'source_offer_id',original.id,'source_context_version',original.context_version,
   'source_exchange_id',original.exchange_id,'source_activity_id',coalesce(original.session_id,original.invitation_id))
   OR NOT EXISTS(SELECT 1 FROM public.characters ch WHERE ch.id=original.principal_character_id AND ch.user_id=p_principal)
  THEN RETURN false;END IF;
  raw:=original.source_payload;
 ELSE RETURN false;END IF;


 -- Solo le forme esatte emesse dai producer esistenti sono candidati preset.
 IF raw ? 'other_operation' THEN opkey:='other_operation';dispatch:='other_control';
 ELSIF raw ? 'suiton_operation' THEN opkey:='suiton_operation';dispatch:='suiton_control';
 ELSIF raw ? 'scudo_operation' THEN opkey:='scudo_operation';dispatch:='scudo_control';
 ELSIF raw ? 'hyuga_operation' THEN opkey:='hyuga_operation';dispatch:='hyuga_control';
 ELSIF raw ? 'sharingan_operation' THEN opkey:='sharingan_operation';dispatch:='sharingan_control';
 ELSIF raw ? 'inuzuka_operation' THEN opkey:='inuzuka_operation';dispatch:='inuzuka_control';
 ELSE RETURN false;END IF;
 operation:=raw->>opkey;
 IF opkey IN('other_operation','suiton_operation','scudo_operation') THEN
  IF operation IS DISTINCT FROM 'staff_profile' THEN RETURN false;END IF;
  tid:=(raw->>'technique_id')::uuid;
  IF tid IS NULL THEN RETURN false;END IF;
  expected:=jsonb_build_object(opkey,'staff_profile','technique_id',tid);
  IF opkey='other_operation' THEN
   IF tid='31d5d554-44d1-4042-9920-3ddd3bedff7e'::uuid THEN
    domain:='paralisi';tbl:='combat_v2_genjutsu_internal.staff_receipts';version:='paralisi-staff-binding/1';
   ELSIF tid IN('f1440a58-ee95-53dc-8ed5-a53543d970ce'::uuid,'f0fdbc8e-5cf3-5c9b-af2a-e52869fa8dfc'::uuid,
    '65719592-7de9-5aa1-8d59-e8da2338d45b'::uuid,'96927a19-9908-59da-9f17-2611e031bd8d'::uuid,'9ac77d79-9894-5388-9753-70538ac5eaa3'::uuid) THEN
    domain:='taijutsu';tbl:='combat_v2_taijutsu_internal.taijutsu_staff_receipts';version:='taijutsu-staff-preset/1';
   ELSE domain:='other';tbl:='combat_v2_elemental_internal.other_staff_receipts';version:='other-staff-preset/1';END IF;
  ELSIF opkey='suiton_operation' THEN domain:='suiton';tbl:='combat_v2_elemental_internal.suiton_staff_receipts';version:='suiton-staff-preset/1';
  ELSE domain:='scudo';tbl:='combat_v2_elemental_internal.scudo_staff_receipts';version:='scudo-staff-preset/1';END IF;
 ELSIF opkey IN('hyuga_operation','sharingan_operation') THEN
  IF operation NOT IN('staff_profile','offensive_profile','katon_profile') THEN RETURN false;END IF;
  expected:=jsonb_build_object(opkey,operation,'expected_state',0);
  IF opkey='hyuga_operation' AND operation='staff_profile' THEN domain:='byakugan';tbl:='clan_hyuga_private.staff_profile_changes';
  ELSIF opkey='sharingan_operation' AND operation='staff_profile' THEN domain:='sharingan';tbl:='clan_hyuga_private.staff_profile_changes';
  ELSIF opkey='hyuga_operation' AND operation='offensive_profile' THEN domain:='hyuga_offensive';tbl:='clan_hyuga_private.offensive_staff_receipts';
  ELSIF opkey='sharingan_operation' AND operation='katon_profile' THEN domain:='katon';tbl:='clan_uchiha_private.fireball_staff_receipts';
  ELSE RETURN false;END IF;
 ELSE
  IF operation IS DISTINCT FROM 'staff_profile' THEN RETURN false;END IF;
  domain:='inuzuka';expected:=jsonb_build_object('inuzuka_operation','staff_profile');
 END IF;
 IF c.activity_kind='master_v2' THEN expected:=expected||jsonb_build_object('adapter','master_v2','dispatch',dispatch);END IF;
 IF raw IS DISTINCT FROM expected THEN RETURN false;END IF;
 IF domain='inuzuka' THEN
  IF c.activity_kind='ordinary_v2' THEN
   SELECT r.viewer_envelope->'receipt' INTO receipt FROM combat_consumer_private.request_receipts r
    WHERE r.principal_character_id=original.principal_character_id AND r.request_key=p_request AND r.operation='control';
  END IF;
  RETURN receipt->'values_written'='false'::jsonb AND receipt->>'request_key'=p_request::text
   AND receipt->'inuzuka'=jsonb_build_object('operation','staff_profile','actor_id',a.id,'values_written',false,
    'abilities',jsonb_build_array('b0748ef4-bea8-4d85-95a1-7d9db1b4381c','c11ecd52-43cd-479b-8d5d-08187beba56e','b076a976-c75b-4b5a-8813-b0e8e2c3af03'));
 END IF;
 -- tbl è scelto esclusivamente dalla whitelist sopra, mai dal client.
 IF to_regclass(tbl) IS NULL THEN RETURN false;END IF;
 EXECUTE 'SELECT to_jsonb(r) FROM '||tbl||' r WHERE actor_id=$1 AND request_id=$2 AND session_id=$3'
  INTO binding USING a.id,p_request,a.session_id;
 IF binding IS NULL THEN RETURN false;END IF;
 IF domain IN('byakugan','sharingan','hyuga_offensive','katon') THEN
  proof:=binding->'result';
  IF proof->'values_written' IS DISTINCT FROM 'false'::jsonb
   OR proof->'main_action_consumed' IS DISTINCT FROM 'false'::jsonb OR proof->'chakra_spent' IS DISTINCT FROM '0'::jsonb THEN RETURN false;END IF;
  IF domain IN('byakugan','sharingan') THEN
   RETURN proof->>'contract_version'='eyes-staff-profile/2'
    AND binding->>'profile_version'=CASE domain WHEN 'byakugan' THEN 'byakugan-l1/1' ELSE 'sharingan-l1/1' END
    AND proof->'is_test'='true'::jsonb;
  ELSIF domain='hyuga_offensive' THEN RETURN proof->>'schema'='hyuga-offensive-staff/1' AND proof->'is_test'='true'::jsonb;
  ELSE
   RETURN proof->>'schema'='katon-staff-profile/1' AND proof->'statistics_changed'='false'::jsonb
    AND binding->>'controller_user'=p_principal::text
    AND binding->>'receipt_sha256'=public.combat_v2_sha256(jsonb_build_object('actor',a.id,'session',a.session_id,
     'request',p_request,'controller',p_principal,'version',binding->'controller_version',
     'common_profile_request',binding->'common_profile_request','abilities_before',binding->'abilities_before',
     'abilities_after',binding->'abilities_after','requirements',binding->'simulated_requirements','result',proof));
  END IF;
 END IF;
 proof:=binding->'receipt';ability:=CASE WHEN domain='paralisi' THEN proof->'ability' ELSE proof->'granted_ability' END;
 IF binding->>'controller_user' IS DISTINCT FROM p_principal::text
 OR proof->'controller_version' IS DISTINCT FROM binding->'controller_version'
 OR (domain<>'paralisi' AND binding->>'technique_id' IS DISTINCT FROM tid::text)
 OR binding->>'receipt_sha256' IS DISTINCT FROM public.combat_v2_sha256(proof)
 OR proof->>'schema_version' IS DISTINCT FROM version OR proof->>'actor_id' IS DISTINCT FROM a.id::text
 OR proof->>'session_id' IS DISTINCT FROM a.session_id::text OR proof->>'request_id' IS DISTINCT FROM p_request::text
 OR proof->'values_written' IS DISTINCT FROM 'false'::jsonb OR proof->'statistics_changed' IS DISTINCT FROM 'false'::jsonb
 OR proof->'main_action_consumed' IS DISTINCT FROM 'false'::jsonb OR proof->'chakra_spent' IS DISTINCT FROM '0'::jsonb
 OR ability->>'source' IS DISTINCT FROM 'clan' OR ability->>'id' IS DISTINCT FROM tid::text
 OR jsonb_typeof(proof->'abilities_before') IS DISTINCT FROM 'array'
 OR jsonb_typeof(proof->'abilities_after') IS DISTINCT FROM 'array' THEN RETURN false;END IF;
 SELECT coalesce(jsonb_agg(v ORDER BY ord),'[]') INTO expected
 FROM jsonb_array_elements(proof->'abilities_before') WITH ORDINALITY x(v,ord)
 WHERE v->>'source' IS DISTINCT FROM 'clan' OR v->>'id' IS DISTINCT FROM tid::text;
 RETURN proof->'abilities_after'=expected||jsonb_build_array(ability);
EXCEPTION WHEN invalid_text_representation THEN RETURN false;
END $cure$;
REVOKE ALL ON FUNCTION combat_panel_private.cure_neutral_preset_v1(uuid,uuid,uuid,jsonb) FROM PUBLIC,anon,authenticated;

CREATE OR REPLACE FUNCTION combat_panel_private.cure_frozen_turn_valid_v1(p_round uuid,p_actor uuid)
RETURNS boolean LANGUAGE sql STABLE SECURITY DEFINER SET search_path='' AS $cure$
 SELECT EXISTS(SELECT 1 FROM combat_panel_private.cure_preparations_v1 p
 JOIN public.combat_v2_declarations d ON d.id=p.declaration_id AND d.round_id=p.round_id AND d.actor_id=p.actor_id
 JOIN public.combat_v2_actors a ON a.id=p.actor_id AND a.session_id=p.session_id
 JOIN public.combat_v2_rounds r ON r.id=p.round_id AND r.session_id=p.session_id
 WHERE p.round_id=p_round AND p.actor_id=p_actor AND d.kind='utilita'
 AND d.state IN('inviata','congelata','risolta','superflua')
 AND d.target_actor_id=p.target_actor_id AND d.request_key=p.request_key
 AND d.controller_user_snapshot=p.controller_user AND d.controller_version_snapshot=p.controller_version
 AND d.sanitized_intent->'server_ability'=p.source
 AND p.source_sha256=public.combat_v2_sha256(p.source)
 AND p.source->>'cure_contract'='palmo-curativo/1'
 AND p.source->>'id'='c47814d2-ef27-4967-87ad-da633b0f4d78'
 AND p.source->>'source'='clan' AND p.source->'chakra_cost'='20'::jsonb
 AND CASE p.source->>'scope_kind' WHEN 'simulation' THEN combat_panel_private.cure_staff_execution_scope_v1(a.id)
  WHEN 'persistent' THEN combat_panel_private.cure_persistent_execution_scope_v1(a.id) ELSE false END);
$cure$;
REVOKE ALL ON FUNCTION combat_panel_private.cure_frozen_turn_valid_v1(uuid,uuid) FROM PUBLIC,anon,authenticated;

CREATE OR REPLACE FUNCTION combat_panel_private.cure_turn_clear_v1(p_round uuid,p_actor uuid)
RETURNS boolean LANGUAGE sql STABLE SECURITY DEFINER SET search_path='' AS $cure$
 SELECT NOT EXISTS(SELECT 1 FROM public.combat_v2_declarations d WHERE d.round_id=p_round AND d.actor_id=p_actor)
 AND NOT EXISTS(SELECT 1 FROM combat_panel_private.cure_voluntary_actions_v1 v WHERE v.round_id=p_round AND v.actor_id=p_actor)
 AND NOT EXISTS(SELECT 1 FROM clan_innata_combat_private.combat_receipts r WHERE r.round_id=p_round AND r.actor_id=p_actor
  AND r.operation IN('activate','deactivate','transport','armor_activate'))
 AND coalesce((combat_panel_private.movement_budget(p_actor,p_round)->>'spent_m')::numeric,0)=0
 AND NOT EXISTS(SELECT 1 FROM combat_panel_private.request_receipts r
 JOIN combat_panel_private.offers o ON o.id=r.offer_id
 WHERE o.actor_id=p_actor AND r.viewer_envelope#>>'{receipt,round_id}'=p_round::text
 AND o.kind='control' AND NOT combat_panel_private.cure_neutral_preset_v1(o.id,r.request_key,r.principal_user,r.viewer_envelope));
$cure$;

CREATE OR REPLACE FUNCTION combat_panel_private.cure_prepare_v1(p_round uuid,p_actor uuid,p_target uuid,p_request uuid)
RETURNS void LANGUAGE plpgsql SECURITY DEFINER SET search_path='' AS $cure$
DECLARE a public.combat_v2_actors%ROWTYPE; profile jsonb; contact jsonb; source jsonb; amount integer;cost integer;
BEGIN
 SELECT * INTO STRICT a FROM public.combat_v2_actors WHERE id=p_actor FOR UPDATE;
 PERFORM pg_advisory_xact_lock(hashtextextended('cure-turn:'||p_round::text||':'||p_actor::text,731));
 profile:=combat_panel_private.cure_profile_v1(a.id);contact:=combat_panel_private.cure_contact_v1(a.id,p_target);
 IF profile IS NULL OR contact IS NULL OR NOT combat_panel_private.cure_turn_clear_v1(p_round,a.id)
  OR exam_regia_private.actor_principal(a.id,a.controller_user) IS DISTINCT FROM auth.uid()
  OR NOT EXISTS(SELECT 1 FROM public.combat_v2_rounds r WHERE r.id=p_round AND r.session_id=a.session_id
   AND r.phase='raccolta_azioni') OR NOT combat_panel_private.human_duel_turn_allowed(p_round,a.id)
  OR NOT coalesce((combat_panel_private.owner_turn_context(a.id)->>'can_move')::boolean,false) THEN
   RAISE EXCEPTION 'cure_action_not_available' USING ERRCODE='42501'; END IF;
 IF jsonb_typeof(a.mechanics_snapshot->'mente') IS DISTINCT FROM 'number'
 OR jsonb_typeof(a.mechanics_snapshot->'ninjutsu') IS DISTINCT FROM 'number'
 OR (a.mechanics_snapshot->>'mente')::numeric<>trunc((a.mechanics_snapshot->>'mente')::numeric)
 OR (a.mechanics_snapshot->>'ninjutsu')::numeric<>trunc((a.mechanics_snapshot->>'ninjutsu')::numeric)
 THEN RAISE EXCEPTION 'cure_stats_invalid' USING ERRCODE='22023';END IF;
 amount:=((a.mechanics_snapshot->>'mente')::integer+(a.mechanics_snapshot->>'ninjutsu')::integer)/3;
 cost:=(clan_hyuga_private.sedici_cost_quote(a.id,20)->>'total')::integer;
 IF amount<=0 OR cost IS NULL OR cost<20 OR coalesce((a.mechanics_snapshot->>'chakra')::integer,0)<cost
 OR NOT EXISTS(SELECT 1 FROM public.combat_v2_actors t WHERE t.id=p_target
  AND (t.mechanics_snapshot->>'vita')::integer<(t.mechanics_snapshot->>'vita_max')::integer) THEN
  RAISE EXCEPTION 'cure_resource_not_available' USING ERRCODE='22023';END IF;
 source:=jsonb_build_object('source','clan','id','c47814d2-ef27-4967-87ad-da633b0f4d78',
  'name','Palmo Curativo','kind','Medica','usage','principale','defensive',false,'di_scena',false,
  'consumption_type','ad_utilizzo','range','contatto','chakra_cost',20,'damage_base',0,
  'cure_contract','palmo-curativo/1','expected_gain',amount,'target_actor_id',p_target,
  'scope_kind',CASE WHEN combat_panel_private.cure_staff_scope_v1(a.id) THEN 'simulation' ELSE 'persistent' END,
  'controller_version',a.controller_version,'profile_sha256',public.combat_v2_sha256(profile),'contact',contact);
 INSERT INTO combat_panel_private.cure_preparations_v1(request_key,transaction_id,session_id,round_id,actor_id,
 target_actor_id,controller_user,controller_version,source,source_sha256)
 VALUES(p_request,txid_current(),a.session_id,p_round,a.id,p_target,auth.uid(),a.controller_version,source,public.combat_v2_sha256(source));
END $cure$;

CREATE OR REPLACE FUNCTION combat_panel_private.cure_declaration_meta_v1(p_round uuid,p_actor uuid,p_request uuid,p_intent jsonb)
RETURNS jsonb LANGUAGE plpgsql STABLE SECURITY DEFINER SET search_path='' AS $cure$
DECLARE p combat_panel_private.cure_preparations_v1%ROWTYPE;
BEGIN
 IF p_intent->>'ability_id' IS DISTINCT FROM 'c47814d2-ef27-4967-87ad-da633b0f4d78' THEN RETURN NULL;END IF;
 IF p_intent->>'kind' IS DISTINCT FROM 'utilita' OR p_intent->>'ability_source' IS DISTINCT FROM 'clan'
 OR p_intent-ARRAY['kind','ability_source','ability_id','target_actor'] IS DISTINCT FROM '{}'::jsonb THEN
  RAISE EXCEPTION 'cure_intent_not_offered' USING ERRCODE='22023';END IF;
 SELECT * INTO p FROM combat_panel_private.cure_preparations_v1 WHERE request_key=p_request
 AND transaction_id=txid_current() AND round_id=p_round AND actor_id=p_actor
 AND target_actor_id=(p_intent->>'target_actor')::uuid AND controller_user=auth.uid() AND declaration_id IS NULL;
 IF p.request_key IS NULL OR p.source_sha256<>public.combat_v2_sha256(p.source)
 OR combat_panel_private.cure_profile_v1(p_actor) IS NULL
 OR combat_panel_private.cure_contact_v1(p_actor,p.target_actor_id) IS DISTINCT FROM p.source->'contact'
 OR NOT combat_panel_private.cure_turn_clear_v1(p_round,p_actor) THEN
  RAISE EXCEPTION 'cure_preparation_required' USING ERRCODE='42501';END IF;
 RETURN p.source;
END $cure$;

CREATE OR REPLACE FUNCTION combat_panel_private.cure_bind_v1(p_declaration uuid)
RETURNS void LANGUAGE plpgsql SECURITY DEFINER SET search_path='' AS $cure$
DECLARE d public.combat_v2_declarations%ROWTYPE;
BEGIN
 SELECT * INTO STRICT d FROM public.combat_v2_declarations WHERE id=p_declaration;
 IF d.sanitized_intent#>>'{server_ability,cure_contract}' IS DISTINCT FROM 'palmo-curativo/1' THEN RETURN;END IF;
 UPDATE combat_panel_private.cure_preparations_v1 SET declaration_id=d.id
 WHERE request_key=d.request_key AND transaction_id=txid_current() AND declaration_id IS NULL
 AND round_id=d.round_id AND actor_id=d.actor_id AND target_actor_id=d.target_actor_id
 AND source=d.sanitized_intent->'server_ability' AND controller_user=d.controller_user_snapshot
 AND controller_version=d.controller_version_snapshot;
 IF NOT FOUND THEN RAISE EXCEPTION 'cure_source_binding_invalid' USING ERRCODE='42501';END IF;
END $cure$;

CREATE OR REPLACE FUNCTION combat_panel_private.cure_resolve_v1(p_declaration uuid)
RETURNS jsonb LANGUAGE plpgsql SECURITY DEFINER SET search_path='' AS $cure$
DECLARE d public.combat_v2_declarations%ROWTYPE;p combat_panel_private.cure_preparations_v1%ROWTYPE;
 a public.combat_v2_actors%ROWTYPE;t public.combat_v2_actors%ROWTYPE;facts jsonb;reason text;
 before_hp integer;after_hp integer;max_hp integer;amount integer;gain integer:=0;real_values boolean;
BEGIN
 SELECT l.facts INTO facts FROM combat_panel_private.cure_ledger_v1 l WHERE l.declaration_id=p_declaration;
 IF FOUND THEN RETURN facts;END IF;
 SELECT * INTO STRICT d FROM public.combat_v2_declarations WHERE id=p_declaration FOR UPDATE;
 SELECT * INTO STRICT p FROM combat_panel_private.cure_preparations_v1 WHERE declaration_id=d.id;
 SELECT * INTO STRICT a FROM public.combat_v2_actors WHERE id=d.actor_id FOR UPDATE;
 SELECT * INTO STRICT t FROM public.combat_v2_actors WHERE id=p.target_actor_id FOR UPDATE;
 IF d.kind<>'utilita' OR d.state<>'congelata' OR p.actor_id<>a.id OR p.session_id<>a.session_id
 OR p.round_id<>d.round_id OR p.source IS DISTINCT FROM d.sanitized_intent->'server_ability'
 OR p.source_sha256<>public.combat_v2_sha256(p.source) OR d.target_actor_id<>t.id
 OR NOT (CASE p.source->>'scope_kind' WHEN 'simulation' THEN combat_panel_private.cure_staff_execution_scope_v1(a.id)
  WHEN 'persistent' THEN combat_panel_private.cure_persistent_execution_scope_v1(a.id) ELSE false END)
 OR NOT EXISTS(SELECT 1 FROM public.combat_v2_resource_ledger l WHERE l.declaration_id=d.id
 AND l.actor_id=a.id AND l.resource_kind='chakra'
 AND l.is_simulated IS NOT DISTINCT FROM NOT public.combat_v2_values_written(a.session_id)
 AND l.applied_amount=CASE WHEN public.combat_v2_values_written(a.session_id) THEN l.committed_amount ELSE 0 END
 AND l.committed_amount=clan_hyuga_private.sedici_frozen_cost(a.id,d.cost_snapshot)) THEN
  RAISE EXCEPTION 'cure_frozen_source_invalid' USING ERRCODE='42501';END IF;
 real_values:=public.combat_v2_values_written(a.session_id);
 amount:=(p.source->>'expected_gain')::integer;
 before_hp:=(t.mechanics_snapshot->>'vita')::integer;max_hp:=(t.mechanics_snapshot->>'vita_max')::integer;
 IF a.controller_user IS DISTINCT FROM p.controller_user OR a.controller_version<>p.controller_version THEN reason:='controller_changed';
 ELSIF a.state<>'attivo' OR (a.mechanics_snapshot->>'vita')::integer<=0 THEN reason:='healer_ko';
 ELSIF combat_panel_private.cure_contact_v1(a.id,t.id) IS NULL THEN reason:='target_no_longer_eligible_or_in_contact';
 ELSE gain:=least(amount,greatest(0,max_hp-before_hp));reason:=CASE WHEN gain>0 THEN 'healed' ELSE 'already_full' END;END IF;
 after_hp:=before_hp+gain;
 IF gain>0 THEN
  IF real_values AND t.actor_kind='pg' THEN
   PERFORM set_config('app.allow_vita_delta','1',true);
   UPDATE public.characters SET vita=after_hp WHERE id=t.character_id AND vita=before_hp;
   IF NOT FOUND THEN RAISE EXCEPTION 'cure_target_pool_drift' USING ERRCODE='40001';END IF;
   PERFORM set_config('app.allow_vita_delta','0',true);
  END IF;
  UPDATE public.combat_v2_actors SET mechanics_snapshot=jsonb_set(mechanics_snapshot,'{vita}',to_jsonb(after_hp),false),
   state=CASE WHEN state='fuori' AND before_hp=0 THEN 'attivo' ELSE state END WHERE id=t.id;
 END IF;
 facts:=jsonb_build_object('cure_contract','palmo-curativo/1','technique_id','c47814d2-ef27-4967-87ad-da633b0f4d78',
 'source_actor_id',a.id,'target_actor_id',t.id,'reason',reason,'expected_gain',amount,'healing_applied',gain,
 'target_hp_before',before_hp,'target_hp_after',after_hp,'target_hp_max',max_hp,
 'revived',gain>0 AND t.state='fuori' AND before_hp=0,'new_turn_in_current_round',false,
 'turn_consumed',true,'values_written',real_values,'source_sha256',p.source_sha256);
 INSERT INTO combat_panel_private.cure_ledger_v1(declaration_id,session_id,round_id,actor_id,target_actor_id,
 hp_before,hp_after,hp_max,expected_gain,committed_gain,applied_real_gain,is_simulated,facts)
 VALUES(d.id,a.session_id,d.round_id,a.id,t.id,before_hp,after_hp,max_hp,amount,gain,CASE WHEN real_values THEN gain ELSE 0 END,NOT real_values,facts);
 RETURN facts;
END $cure$;

CREATE OR REPLACE FUNCTION combat_panel_private.cure_defense_guard_v1()
RETURNS trigger LANGUAGE plpgsql SECURITY DEFINER SET search_path='' AS $cure$
BEGIN
 IF NEW.kind IN('attacco','movimento','utilita','passa') AND combat_panel_private.cure_turn_used_v1(NEW.round_id,NEW.actor_id) THEN
  RAISE EXCEPTION 'cure_turn_has_no_other_main_action' USING ERRCODE='42501';END IF;
 IF NEW.kind IN('difesa','nessuna') AND combat_panel_private.cure_turn_used_v1(NEW.round_id,NEW.actor_id)
 AND (coalesce(NEW.sanitized_intent->>'reaction','nessuna') NOT IN('schivata','parata','nessuna')
  OR NEW.sanitized_intent ? 'ability_id') THEN
  RAISE EXCEPTION 'cure_turn_has_no_technique_reaction' USING ERRCODE='42501';END IF;
 RETURN NEW;
END $cure$;
CREATE TRIGGER cure_turn_defense_guard_v1 BEFORE INSERT ON public.combat_v2_declarations
 FOR EACH ROW EXECUTE FUNCTION combat_panel_private.cure_defense_guard_v1();

CREATE OR REPLACE FUNCTION combat_panel_private.cure_offers_v1(p_context uuid,p_expected bigint,p_view jsonb)
RETURNS void LANGUAGE plpgsql SECURITY DEFINER SET search_path='' AS $cure$
DECLARE c combat_panel_private.contexts%ROWTYPE;a public.combat_v2_actors%ROWTYPE;t public.combat_v2_actors%ROWTYPE;
 oid uuid;gid uuid;label text;targets jsonb:='[]';x jsonb;
BEGIN
 c:=combat_panel_private.owned_context(p_context,p_expected);
 IF c.round_id IS NULL OR c.command_actor_id IS NULL OR c.activity_kind NOT IN('ordinary_v2','master_v2') THEN RETURN;END IF;
 SELECT * INTO a FROM public.combat_v2_actors WHERE id=c.command_actor_id;
 IF NOT(combat_panel_private.cure_staff_scope_v1(a.id) OR combat_panel_private.cure_persistent_scope_v1(a.id)) OR a.state<>'attivo'
 OR a.controller_user IS DISTINCT FROM auth.uid()
 OR p_view#>>'{context,phase}'<>'action' OR NOT combat_panel_private.cure_turn_clear_v1(c.round_id,a.id)
 OR NOT coalesce((combat_panel_private.owner_turn_context(a.id)->>'can_move')::boolean,false) THEN RETURN;END IF;
 IF combat_panel_private.cure_profile_v1(a.id) IS NULL THEN
  IF public.is_staff() AND combat_panel_private.cure_staff_scope_v1(a.id)
  AND NOT EXISTS(SELECT 1 FROM combat_panel_private.cure_staff_profiles_v1 WHERE actor_id=a.id)
  AND NOT EXISTS(SELECT 1 FROM combat_panel_private.offers WHERE context_id=c.id AND context_version=c.context_version
   AND state='offered' AND source_payload->>'dispatch'='cure_staff_profile') THEN
   PERFORM combat_panel_private.create_offer(c.id,c.context_version,'control','control','Prepara prova: Palmo Curativo',false,
    jsonb_build_object('adapter',c.activity_kind,'dispatch','cure_staff_profile','cure_contract','palmo-curativo/1'));
  END IF;RETURN;
 END IF;
 IF coalesce((a.mechanics_snapshot->>'chakra')::integer,0)<(clan_hyuga_private.sedici_cost_quote(a.id,20)->>'total')::integer THEN RETURN;END IF;
 FOR t IN SELECT * FROM public.combat_v2_actors WHERE session_id=a.session_id AND team_key=a.team_key
 AND companion_id IS NULL AND state IN('attivo','fuori') ORDER BY id LOOP
  SELECT value->>'display_name' INTO label FROM jsonb_array_elements(p_view->'actors') WHERE value->>'actor_id'=t.id::text;
  IF nullif(btrim(label),'') IS NOT NULL AND combat_panel_private.cure_contact_v1(a.id,t.id) IS NOT NULL
  AND (t.mechanics_snapshot->>'vita')::integer<(t.mechanics_snapshot->>'vita_max')::integer THEN
   targets:=targets||jsonb_build_array(jsonb_build_object('target',t.id,'label',label));
  END IF;
 END LOOP;
 IF jsonb_array_length(targets)=0 OR EXISTS(SELECT 1 FROM combat_panel_private.offers WHERE context_id=c.id
 AND context_version=c.context_version AND state='offered' AND source_payload->>'dispatch'='cure_action') THEN RETURN;END IF;
 oid:=combat_panel_private.create_offer(c.id,c.context_version,'action','declare','Palmo Curativo · '||(clan_hyuga_private.sedici_cost_quote(a.id,20)->>'total')||' chakra · turno intero',true,
  jsonb_build_object('adapter',c.activity_kind,'dispatch','cure_action','kind','utilita','cure_contract','palmo-curativo/1'));
 INSERT INTO combat_panel_private.choice_groups(offer_id,label,selection_mode,purpose,min_selected,max_selected,ordinal)
 VALUES(oid,'Chi curi','single','target',1,1,0) RETURNING id INTO gid;
 FOR x IN SELECT value FROM jsonb_array_elements(targets) LOOP
  INSERT INTO combat_panel_private.choice_options(offer_id,group_id,label,source_payload,ordinal)
  VALUES(oid,gid,x->>'label',jsonb_build_object('cure_target_actor_id',x->'target'),0);
 END LOOP;
END $cure$;

-- Helper interni: niente EXECUTE client anche se cambiano i default ACL.
REVOKE ALL ON FUNCTION combat_panel_private.cure_staff_scope_v1(uuid),combat_panel_private.cure_profile_v1(uuid),
 combat_panel_private.cure_contact_v1(uuid,uuid),combat_panel_private.cure_turn_used_v1(uuid,uuid),
 combat_panel_private.cure_turn_clear_v1(uuid,uuid),combat_panel_private.cure_prepare_v1(uuid,uuid,uuid,uuid),
 combat_panel_private.cure_declaration_meta_v1(uuid,uuid,uuid,jsonb),combat_panel_private.cure_bind_v1(uuid),
 combat_panel_private.cure_resolve_v1(uuid),combat_panel_private.cure_defense_guard_v1(),
 combat_panel_private.cure_offers_v1(uuid,bigint,jsonb) FROM PUBLIC,anon,authenticated;

CREATE OR REPLACE FUNCTION combat_panel_private.cure_note_voluntary_v1(p_actor uuid,p_round uuid,p_source text,p_key text)
RETURNS void LANGUAGE plpgsql SECURITY DEFINER SET search_path='' AS $cure$
BEGIN
 IF p_actor IS NULL OR p_round IS NULL OR p_key IS NULL THEN RETURN;END IF;
 -- Il turno già accettato resta protetto dopo OFF, con fonte congelata esatta.
 PERFORM pg_advisory_xact_lock(hashtextextended('cure-turn:'||p_round::text||':'||p_actor::text,731));
 IF combat_panel_private.cure_frozen_turn_valid_v1(p_round,p_actor) THEN
  RAISE EXCEPTION 'cure_turn_has_no_other_voluntary_action' USING ERRCODE='42501';END IF;
 -- La sola presenza di PG/abilità non autorizza un nuovo audit.
 IF NOT(combat_panel_private.cure_staff_scope_v1(p_actor) OR combat_panel_private.cure_persistent_scope_v1(p_actor))
 OR NOT EXISTS(SELECT 1 FROM public.combat_v2_actors a JOIN public.combat_v2_rounds r ON r.session_id=a.session_id
  WHERE a.id=p_actor AND r.id=p_round) THEN RETURN;END IF;
 INSERT INTO combat_panel_private.cure_voluntary_actions_v1(actor_id,round_id,source_kind,source_key)
 VALUES(p_actor,p_round,p_source,p_key) ON CONFLICT DO NOTHING;
END $cure$;

CREATE OR REPLACE FUNCTION combat_panel_private.cure_voluntary_receipt_guard_v1()
RETURNS trigger LANGUAGE plpgsql SECURITY DEFINER SET search_path='' AS $cure$
DECLARE e jsonb:=to_jsonb(NEW);a uuid;r uuid;k text;source text:=TG_TABLE_SCHEMA||'.'||TG_TABLE_NAME;
 o combat_panel_private.offers%ROWTYPE;
BEGIN
 IF source='clan_innata_combat_private.combat_receipts' THEN
  IF e->>'operation' NOT IN('activate','deactivate','transport','armor_activate') THEN RETURN NEW;END IF;
  a:=(e->>'actor_id')::uuid;r:=(e->>'round_id')::uuid;k:=e->>'receipt_id';
 ELSIF source='clan_hoki_private.combat_events' THEN
  IF e->>'kind'<>'body_on' THEN RETURN NEW;END IF;
  a:=(e->>'actor_id')::uuid;r:=(e->>'round_id')::uuid;k:=e->>'event_key';
 ELSIF source='clan_akimichi_private.form_commands' THEN
  a:=(e->>'actor_id')::uuid;k:=e->>'event_id';
 ELSIF source='clan_sabaku_private.armor_events' THEN
  IF NOT(e->>'event_kind'='activate' OR(e->>'event_kind'='off' AND e#>>'{result,off_reason}'='manual_off')) THEN RETURN NEW;END IF;
  SELECT actor_id INTO a FROM clan_sabaku_private.armor_states WHERE id=(e->>'armor_id')::uuid;
  r:=(e->>'round_id')::uuid;k:=e->>'id';
 ELSIF source='clan_marionettisti_private.control_events' THEN
  IF e->>'kind'<>'relinked' THEN RETURN NEW;END IF;
  a:=(e->>'owner_actor_id')::uuid;r:=(e->>'round_id')::uuid;k:=e->>'event_id';
 ELSIF source IN('clan_marionettisti_private.movement_receipts','clan_inuzuka_private.movement_receipts',
  'combat_panel_private.master_movement_receipts') THEN
  a:=(e->>'owner_actor_id')::uuid;r:=(e->>'round_id')::uuid;k:=coalesce(e->>'request_key',e->>'declaration_id');
 ELSIF source='combat_panel_private.request_receipts' THEN
  SELECT * INTO o FROM combat_panel_private.offers WHERE id=(e->>'offer_id')::uuid;
  IF o.kind<>'control' OR combat_panel_private.cure_neutral_preset_v1(o.id,
   (e->>'request_key')::uuid,(e->>'principal_user')::uuid,e->'viewer_envelope') THEN RETURN NEW;END IF;
  a:=o.actor_id;SELECT round_id INTO r FROM combat_panel_private.contexts WHERE id=o.context_id;k:=e->>'request_key';
 ELSE RAISE EXCEPTION 'cure_voluntary_receipt_source_unknown';END IF;
 IF r IS NULL AND a IS NOT NULL THEN r:=(combat_panel_private.owner_turn_context(a)->>'round_id')::uuid;END IF;
 PERFORM combat_panel_private.cure_note_voluntary_v1(a,r,source,k);
 RETURN NEW;
END $cure$;
CREATE TRIGGER cure_voluntary_receipt_v1 BEFORE INSERT ON clan_innata_combat_private.combat_receipts
 FOR EACH ROW EXECUTE FUNCTION combat_panel_private.cure_voluntary_receipt_guard_v1();
CREATE TRIGGER cure_voluntary_receipt_v1 BEFORE INSERT ON clan_hoki_private.combat_events
 FOR EACH ROW EXECUTE FUNCTION combat_panel_private.cure_voluntary_receipt_guard_v1();
CREATE TRIGGER cure_voluntary_receipt_v1 BEFORE INSERT ON clan_akimichi_private.form_commands
 FOR EACH ROW EXECUTE FUNCTION combat_panel_private.cure_voluntary_receipt_guard_v1();
CREATE TRIGGER cure_voluntary_receipt_v1 BEFORE INSERT ON clan_sabaku_private.armor_events
 FOR EACH ROW EXECUTE FUNCTION combat_panel_private.cure_voluntary_receipt_guard_v1();
CREATE TRIGGER cure_voluntary_receipt_v1 BEFORE INSERT ON clan_marionettisti_private.control_events
 FOR EACH ROW EXECUTE FUNCTION combat_panel_private.cure_voluntary_receipt_guard_v1();
CREATE TRIGGER cure_voluntary_receipt_v1 BEFORE INSERT ON clan_marionettisti_private.movement_receipts
 FOR EACH ROW EXECUTE FUNCTION combat_panel_private.cure_voluntary_receipt_guard_v1();
CREATE TRIGGER cure_voluntary_receipt_v1 BEFORE INSERT ON clan_inuzuka_private.movement_receipts
 FOR EACH ROW EXECUTE FUNCTION combat_panel_private.cure_voluntary_receipt_guard_v1();
CREATE TRIGGER cure_voluntary_receipt_v1 BEFORE INSERT ON combat_panel_private.master_movement_receipts
 FOR EACH ROW EXECUTE FUNCTION combat_panel_private.cure_voluntary_receipt_guard_v1();
CREATE TRIGGER cure_voluntary_receipt_v1 BEFORE INSERT ON combat_panel_private.request_receipts
 FOR EACH ROW EXECUTE FUNCTION combat_panel_private.cure_voluntary_receipt_guard_v1();
REVOKE ALL ON FUNCTION combat_panel_private.cure_note_voluntary_v1(uuid,uuid,text,text),
 combat_panel_private.cure_voluntary_receipt_guard_v1() FROM PUBLIC,anon,authenticated;

CREATE OR REPLACE FUNCTION combat_panel_private.cure_commit_v1(p_command jsonb)
RETURNS jsonb LANGUAGE plpgsql SECURITY DEFINER SET search_path='' AS $cure$
DECLARE p jsonb;uid uuid:=auth.uid();key uuid;fp text;eid uuid:=gen_random_uuid();
 prior combat_panel_private.request_receipts%ROWTYPE;o combat_panel_private.offers%ROWTYPE;
 c combat_panel_private.contexts%ROWTYPE;a public.combat_v2_actors%ROWTYPE;
 activity combat_consumer_private.activities%ROWTYPE;report public.combat_v2_round_reports%ROWTYPE;
 env jsonb;resolved jsonb;selected uuid[];payload jsonb;intent jsonb;result jsonb;receipt jsonb;
 target_id uuid;declaration uuid;resolve_key uuid;label text;target_label text;display_event jsonb;
 profile boolean;ability jsonb;proof text;
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
 profile:=o.source_payload->>'dispatch'='cure_staff_profile';
 IF o.id IS NULL OR o.source_payload->>'dispatch' NOT IN('cure_staff_profile','cure_action')
 OR o.source_payload->>'adapter' NOT IN('ordinary_v2','master_v2')
 OR (profile AND(o.kind<>'control' OR o.operation<>'control'))
 OR(NOT profile AND(o.kind<>'action' OR o.operation<>'declare'))
 OR p->>'operation' IS DISTINCT FROM o.operation THEN
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
 IF (profile AND (NOT public.is_staff() OR NOT combat_panel_private.cure_staff_scope_v1(a.id)))
 OR (NOT profile AND combat_panel_private.cure_profile_v1(a.id) IS NULL) THEN
  RAISE EXCEPTION 'cure_staff_scope_required' USING ERRCODE='42501';END IF;
 SELECT coalesce(array_agg(value::uuid),'{}') INTO selected FROM jsonb_array_elements_text(p->'selected_option_ids');
 resolved:=combat_panel_private.resolve_selections(o.id,selected,p->'inputs');
 IF resolved->'inputs' IS DISTINCT FROM '{}'::jsonb THEN RAISE EXCEPTION 'panel_input_not_offered' USING ERRCODE='22023';END IF;
 IF profile THEN
  IF o.requires_role OR length(btrim(p->>'narrative_text'))<>0 OR cardinality(selected)<>0
  OR NOT combat_panel_private.cure_turn_clear_v1(c.round_id,a.id)
  OR NOT coalesce((combat_panel_private.owner_turn_context(a.id)->>'can_move')::boolean,false)
  OR EXISTS(SELECT 1 FROM combat_panel_private.cure_staff_profiles_v1 WHERE actor_id=a.id) THEN
   RAISE EXCEPTION 'cure_staff_profile_not_available' USING ERRCODE='40001';END IF;
  IF NOT EXISTS(SELECT 1 FROM public.clan_techniques t WHERE t.id='c47814d2-ef27-4967-87ad-da633b0f4d78'
   AND t.is_active AND t.uso='principale' AND t.gittata='contatto' AND t.chakra_cost=20 AND t.danno_base=0) THEN
   RAISE EXCEPTION 'cure_catalog_drift' USING ERRCODE='40001';END IF;
  ability:=jsonb_build_object('source','clan','id','c47814d2-ef27-4967-87ad-da633b0f4d78','name','Palmo Curativo',
   'kind','Medica','usage','principale','defensive',false,'di_scena',false,'diversivo',false,
   'consumption_type','ad_utilizzo','range','contatto','chakra_cost',20,'damage_base',0);
  proof:=public.combat_v2_sha256(jsonb_build_object('contract','palmo-curativo/1','actor_id',a.id,
   'session_id',a.session_id,'context_id',c.id,'controller',uid,'controller_version',a.controller_version,'ability',ability));
  INSERT INTO combat_panel_private.cure_staff_profiles_v1(actor_id,session_id,context_id,controller_user,
   controller_version,ability,proof_sha256,request_key)
  VALUES(a.id,a.session_id,c.id,uid,a.controller_version,ability,proof,key);
  UPDATE public.combat_v2_actors SET mechanics_snapshot=jsonb_set(
   jsonb_set(mechanics_snapshot,'{abilities}',coalesce((SELECT jsonb_agg(v) FROM jsonb_array_elements(
    coalesce(mechanics_snapshot->'abilities','[]')) v WHERE v->>'id'<>'c47814d2-ef27-4967-87ad-da633b0f4d78'),'[]')||jsonb_build_array(ability),true),
   '{cure_staff_profile}',jsonb_build_object('contract','palmo-curativo/1','context_id',c.id,'proof_sha256',proof),true)
  WHERE id=a.id;
  IF c.activity_kind='ordinary_v2' THEN
   UPDATE combat_consumer_private.activities SET context_version=context_version+1,last_action_at=clock_timestamp() WHERE session_id=c.activity_id;
  END IF;
  UPDATE combat_panel_private.contexts SET context_version=context_version+1,updated_at=clock_timestamp() WHERE id=c.id;
 ELSE
  IF NOT o.requires_role OR length(btrim(p->>'narrative_text'))=0 THEN
   RAISE EXCEPTION 'panel_role_required' USING ERRCODE='22023';END IF;
  FOR payload IN SELECT choice->'payload' FROM jsonb_array_elements(resolved->'groups') AS groups(g)
   CROSS JOIN LATERAL jsonb_array_elements(g->'options') AS choices(choice) LOOP
   IF payload ? 'cure_target_actor_id' AND payload-ARRAY['cure_target_actor_id']='{}'::jsonb AND target_id IS NULL THEN
    target_id:=(payload->>'cure_target_actor_id')::uuid;
   ELSE RAISE EXCEPTION 'cure_target_selection_invalid' USING ERRCODE='22023';END IF;
  END LOOP;
  IF target_id IS NULL THEN RAISE EXCEPTION 'cure_target_required' USING ERRCODE='22023';END IF;
  PERFORM combat_panel_private.cure_prepare_v1(c.round_id,a.id,target_id,key);
  intent:=jsonb_build_object('kind','utilita','ability_source','clan','ability_id','c47814d2-ef27-4967-87ad-da633b0f4d78','target_actor',target_id);
  IF c.activity_kind='ordinary_v2' THEN
   SELECT * INTO STRICT activity FROM combat_consumer_private.activities WHERE session_id=c.activity_id AND exchange_id=c.round_id FOR UPDATE;
   IF activity.phase<>'action' OR activity.turn_actor_id<>a.id THEN RAISE EXCEPTION 'cure_turn_stale' USING ERRCODE='40001';END IF;
   INSERT INTO combat_consumer_private.dispatch_authorizations VALUES(key,c.round_id,a.character_id,txid_current(),'declare','prepared');
  END IF;
  result:=public.combat_v2_action_declare(c.round_id,a.id,intent,p->>'narrative_text',key);
  declaration:=(result#>>'{data,declaration_id}')::uuid;
  IF declaration IS NULL OR NOT EXISTS(SELECT 1 FROM combat_panel_private.cure_preparations_v1
   WHERE request_key=key AND declaration_id=declaration) THEN RAISE EXCEPTION 'cure_binding_missing';END IF;
  IF c.activity_kind='ordinary_v2' THEN
   UPDATE combat_consumer_private.dispatch_authorizations SET state='consumed' WHERE request_key=key AND round_id=c.round_id AND operation='declare';
   UPDATE combat_consumer_private.activities SET phase='defense' WHERE session_id=c.activity_id;
   resolve_key:=gen_random_uuid();
   INSERT INTO combat_consumer_private.dispatch_authorizations VALUES(resolve_key,c.round_id,a.character_id,txid_current(),'resolve','prepared');
   PERFORM public.combat_v2_round_resolve(c.round_id,resolve_key);
   UPDATE combat_consumer_private.dispatch_authorizations SET state='consumed' WHERE request_key=resolve_key AND round_id=c.round_id AND operation='resolve';
   SELECT * INTO STRICT report FROM public.combat_v2_round_reports WHERE round_id=c.round_id;
   UPDATE combat_consumer_private.activities SET phase='resolved' WHERE session_id=c.activity_id;
   PERFORM combat_consumer_private.record_message(declaration,public.post_message(c.location_id,p->>'narrative_text',null,null,null));
   UPDATE combat_consumer_private.activities SET context_version=context_version+1,last_action_at=clock_timestamp() WHERE session_id=c.activity_id;
  ELSE
   PERFORM combat_panel_private.publish_master_declaration(declaration,p->>'narrative_text');
   SELECT * INTO report FROM public.combat_v2_round_reports WHERE round_id=c.round_id;
  END IF;
 END IF;
 SELECT value->>'display_name' INTO label FROM jsonb_array_elements(env->'actors') WHERE value->>'actor_id'=a.id::text;
 SELECT value->>'display_name' INTO target_label FROM jsonb_array_elements(env->'actors') WHERE value->>'actor_id'=target_id::text;
 display_event:=jsonb_build_object('event_id',eid,'event_kind',CASE WHEN profile THEN 'control_changed' ELSE 'action_declared' END,
 'actor_id',a.id,'display_name',label,'label_version',c.context_version,'target_actor_id',target_id,
 'target_display_name',target_label,'target_label_version',CASE WHEN target_id IS NOT NULL THEN c.context_version END,
 'summary',CASE WHEN profile THEN 'Prova del Palmo Curativo preparata' ELSE 'Palmo Curativo registrato' END);
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
END $cure$;
REVOKE ALL ON FUNCTION combat_panel_private.cure_commit_v1(jsonb) FROM PUBLIC,anon,authenticated;

CREATE OR REPLACE FUNCTION combat_panel_private.cure_narrative_facts_v1(p_declaration uuid)
RETURNS jsonb LANGUAGE sql STABLE SECURITY DEFINER SET search_path='' AS $cure$
 SELECT jsonb_build_object('result',jsonb_build_object('healing',jsonb_build_object(
  'schema_version','palmo-curativo-narrative/1',
  'target',CASE WHEN l.target_actor_id=l.actor_id THEN 'self' ELSE 'ally' END,
  'applied',l.committed_gain>0,'revived',l.facts->'revived',
  'reason',CASE l.facts->>'reason' WHEN 'controller_changed' THEN 'control_lost'
   WHEN 'target_no_longer_eligible_or_in_contact' THEN 'target_unavailable' ELSE l.facts->>'reason' END)))
 FROM combat_panel_private.cure_ledger_v1 l
 JOIN public.combat_v2_declarations d ON d.id=l.declaration_id AND d.kind='utilita' AND d.state='risolta'
  AND d.round_id=l.round_id AND d.actor_id=l.actor_id AND d.target_actor_id=l.target_actor_id
 JOIN combat_panel_private.cure_preparations_v1 p ON p.declaration_id=d.id
  AND p.round_id=d.round_id AND p.actor_id=d.actor_id AND p.target_actor_id=d.target_actor_id
 JOIN public.combat_v2_round_reports rr ON rr.round_id=d.round_id
 WHERE d.id=p_declaration AND d.outcome=l.facts
 AND d.sanitized_intent->'server_ability'=p.source
 AND p.source_sha256=public.combat_v2_sha256(p.source)
 AND l.facts->>'source_sha256'=p.source_sha256
 AND l.facts->>'cure_contract'='palmo-curativo/1'
 AND rr.mechanics_sha256=public.combat_v2_sha256(rr.mechanics)
 AND EXISTS(SELECT 1 FROM jsonb_array_elements(rr.mechanics->'declarations') rd
  WHERE rd->>'id'=d.id::text AND rd->'outcome'=l.facts)
 AND EXISTS(SELECT 1 FROM public.combat_v2_resource_ledger cost WHERE cost.declaration_id=d.id
  AND cost.actor_id=d.actor_id AND cost.resource_kind='chakra'
  AND cost.committed_amount=clan_hyuga_private.sedici_frozen_cost(d.actor_id,d.cost_snapshot)
  AND cost.is_simulated=l.is_simulated AND cost.applied_amount=CASE WHEN l.is_simulated THEN 0 ELSE cost.committed_amount END);
$cure$;
REVOKE ALL ON FUNCTION combat_panel_private.cure_narrative_facts_v1(uuid) FROM PUBLIC,anon,authenticated;

-- COMPONENT: report_helpers
-- Formatter puro dei soli risultati congelati nel report. Nessuna lettura DB.
CREATE FUNCTION combat_panel_private.catalog_result_label_v1(p jsonb)
RETURNS text LANGUAGE plpgsql IMMUTABLE SET search_path='' AS $label$
DECLARE g jsonb;r jsonb;
BEGIN
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
END $label$;
REVOKE ALL ON FUNCTION combat_panel_private.catalog_result_label_v1(jsonb) FROM PUBLIC,anon,authenticated,service_role;
GRANT EXECUTE ON FUNCTION combat_panel_private.catalog_result_label_v1(jsonb) TO postgres;

CREATE FUNCTION combat_panel_private.catalog_lifecycle_lines_v1(p jsonb,p_roster jsonb)
RETURNS jsonb LANGUAGE plpgsql IMMUTABLE SET search_path='' AS $label$
DECLARE e jsonb;lines jsonb:='[]'::jsonb;source_name text;target_name text;line text;
BEGIN
 IF p->>'contract' IS DISTINCT FROM 'paralisi-report/1' OR jsonb_typeof(p->'events') IS DISTINCT FROM 'array' THEN RETURN lines;END IF;
 FOR e IN SELECT value FROM jsonb_array_elements(p->'events') LOOP
  SELECT value->>'display_name' INTO source_name FROM jsonb_array_elements(p_roster) WHERE value->>'actor_id'=e->>'source_actor_id';
  SELECT value->>'display_name' INTO target_name FROM jsonb_array_elements(p_roster) WHERE value->>'actor_id'=e->>'target_actor_id';
  -- Do not name an actor absent from the same projected roster.
  IF source_name IS NULL OR target_name IS NULL THEN CONTINUE;END IF;
  line:=CASE e->>'kind'
   WHEN 'applied' THEN target_name||' · illusione applicata da '||source_name||', blocco previsto nel prossimo turno personale'
   WHEN 'movement_block_started' THEN target_name||' · blocco mentale del movimento attivo in questo turno'
   WHEN 'movement_block_expired' THEN target_name||' · fine del blocco mentale per scadenza del turno'
   WHEN 'movement_block_released' THEN target_name||' · blocco mentale sciolto con '||CASE e->>'reason' WHEN 'kai_released' THEN 'Dispersione' ELSE 'contesa mentale' END
   WHEN 'movement_block_ended' THEN target_name||' · blocco mentale terminato: '||CASE e->>'reason'
    WHEN 'source_inoperative' THEN source_name||' è fuori combattimento'
    WHEN 'target_inoperative' THEN 'bersaglio fuori combattimento'
    WHEN 'combat_end' THEN 'scontro concluso' ELSE 'effetto concluso' END
   ELSE NULL END;
  IF line IS NOT NULL THEN lines:=lines||jsonb_build_array(line);END IF;
 END LOOP;
 RETURN lines;
END $label$;
REVOKE ALL ON FUNCTION combat_panel_private.catalog_lifecycle_lines_v1(jsonb,jsonb) FROM PUBLIC,anon,authenticated,service_role;
GRANT EXECUTE ON FUNCTION combat_panel_private.catalog_lifecycle_lines_v1(jsonb,jsonb) TO postgres;

-- COMPONENT: shared_exact_deltas
-- Exact shared-function delta. Integrate only with the reviewed family/Root/Edge plan.
DO $cc_shared$
DECLARE patches jsonb:=$cc_hunks$[{"signature":"public.combat_v2_action_declare(uuid,uuid,jsonb,text,uuid)","before_sha256":"75d97156e8cf34775d830d9cef7aa18ab421e752b423abc9eb4a64860568e72b","after_sha256":"a6031c7e390241dd7fad8e81be90ae8f3dc57e2283e742c19047d046c9e93f6d","after_source_md5":"56a48200d4a15178b63e52445cb42ba7","hunks":[{"before":"AS $function$\ndeclare v_uid uuid:=exam_regia_private.current_principal(); v_service boolean:=false; v_service_actor uuid; v_r public.combat_v2_rounds%rowtype; v_a public.combat_v2_actors%rowtype; v_t public.combat_v2_actors%rowtype;\n  fireball clan_uchiha_private.fireball_preparations%ROWTYPE; clone_meta jsonb; escape_meta jsonb; aburame_meta jsonb;  multiplication_aim_valid boolean; multiplication_meta jsonb; v_i jsonb; v_kind text; v_target uuid; v_source text; v_ability uuid; v_meta jsonb; v_cost int:=0; v_base int:=10;\n  v_nara_native boolean := false;\n  v_nara_public_enabled boolean;\n  v_nara_public_activated_at timestamptz;\n","after":"AS $function$\ndeclare v_uid uuid:=exam_regia_private.current_principal(); v_service boolean:=false; v_service_actor uuid; v_r public.combat_v2_rounds%rowtype; v_a public.combat_v2_actors%rowtype; v_t public.combat_v2_actors%rowtype;\n  fireball clan_uchiha_private.fireball_preparations%ROWTYPE; clone_meta jsonb; escape_meta jsonb; aburame_meta jsonb;  multiplication_aim_valid boolean; multiplication_meta jsonb; v_i jsonb; v_kind text; v_target uuid; v_source text; v_ability uuid; v_meta jsonb; v_cost int:=0; v_base int:=10;\n  cure_meta jsonb;\n    genjutsu_release_meta jsonb;\n  v_nara_native boolean := false;\n  v_nara_public_enabled boolean;\n  v_nara_public_activated_at timestamptz;\n","occurrences":1},{"before":"  if not v_service and exam_regia_private.actor_principal(v_a.id,v_a.controller_user)<>v_uid then perform public.combat_v2_fail('attore_non_controllato','Non controlli questo attore.',403,p_request_key,'{}'); end if;\n  if v_a.state<>'attivo' then perform public.combat_v2_fail('azione_non_disponibile','Attore non attivo.',409,p_request_key,'{}'); end if;\n  v_i:=public.combat_v2_sanitize_intent(p_intent,false); v_kind:=v_i->>'kind';\n  v_has_fili:=v_i ? 'target_fili';\n  if v_has_fili and (\n    v_kind<>'attacco' or v_i ? 'move_m' or v_i->>'ability_source' not in ('arma','clan','jutsu')\n","after":"  if not v_service and exam_regia_private.actor_principal(v_a.id,v_a.controller_user)<>v_uid then perform public.combat_v2_fail('attore_non_controllato','Non controlli questo attore.',403,p_request_key,'{}'); end if;\n  if v_a.state<>'attivo' then perform public.combat_v2_fail('azione_non_disponibile','Attore non attivo.',409,p_request_key,'{}'); end if;\n  v_i:=public.combat_v2_sanitize_intent(p_intent,false); v_kind:=v_i->>'kind';\n  cure_meta:=combat_panel_private.cure_declaration_meta_v1(p_round,p_actor,p_request_key,v_i);\n  IF cure_meta IS NOT NULL THEN\n    v_target:=(v_i->>'target_actor')::uuid;v_meta:=cure_meta;v_cost:=20;v_base:=0;\n  END IF;\n    IF (v_kind='movimento' OR coalesce((v_i->>'move_m')::numeric,0)<>0) AND combat_v2_genjutsu_internal.movement_blocked(p_actor) THEN RAISE EXCEPTION 'paralisi_movement_blocked';END IF;\n  v_has_fili:=v_i ? 'target_fili';\n  if v_has_fili and (\n    v_kind<>'attacco' or v_i ? 'move_m' or v_i->>'ability_source' not in ('arma','clan','jutsu')\n","occurrences":1},{"before":"      ELSIF v_source='clan' AND combat_v2_elemental_internal.suiton_profile(p_actor,v_ability) IS NOT NULL THEN\n        v_meta:=combat_v2_elemental_internal.suiton_declaration_meta(p_round,p_actor,p_request_key,v_i);\n        IF v_meta IS NULL THEN RAISE EXCEPTION 'suiton_preparation_required';END IF;\n      ELSIF v_source='clan' AND combat_v2_elemental_internal.other_profile(p_actor,v_ability) IS NOT NULL THEN\n        v_meta:=combat_v2_elemental_internal.other_declaration_meta(p_round,p_actor,p_request_key,v_i);\n        IF v_meta IS NULL THEN RAISE EXCEPTION 'other_preparation_required';END IF;\n","after":"      ELSIF v_source='clan' AND combat_v2_elemental_internal.suiton_profile(p_actor,v_ability) IS NOT NULL THEN\n        v_meta:=combat_v2_elemental_internal.suiton_declaration_meta(p_round,p_actor,p_request_key,v_i);\n        IF v_meta IS NULL THEN RAISE EXCEPTION 'suiton_preparation_required';END IF;\n            ELSIF v_source='clan' AND v_ability='31d5d554-44d1-4042-9920-3ddd3bedff7e'::uuid THEN\n        v_meta:=combat_v2_genjutsu_internal.declaration_meta(p_round,p_actor,p_request_key,v_i);\n        IF v_meta IS NULL THEN RAISE EXCEPTION 'paralisi_preparation_required';END IF;\n      ELSIF v_source='clan' AND combat_v2_elemental_internal.other_profile(p_actor,v_ability) IS NOT NULL THEN\n        v_meta:=combat_v2_elemental_internal.other_declaration_meta(p_round,p_actor,p_request_key,v_i);\n        IF v_meta IS NULL THEN RAISE EXCEPTION 'other_preparation_required';END IF;\n","occurrences":1},{"before":"  IF multiplication_meta IS NOT NULL THEN\n    v_meta:=multiplication_meta; v_cost:=(v_meta->>'chakra_cost')::integer; v_base:=(v_meta->>'damage_base')::integer;\n  END IF;\n  escape_meta:=combat_panel_private.immobilization_escape_meta(p_round,p_actor,p_request_key,v_i);\n  IF escape_meta IS NOT NULL THEN\n    IF multiplication_meta IS NOT NULL THEN RAISE EXCEPTION 'immobilization_escape_action_conflict' USING ERRCODE='22023'; END IF;\n","after":"  IF multiplication_meta IS NOT NULL THEN\n    v_meta:=multiplication_meta; v_cost:=(v_meta->>'chakra_cost')::integer; v_base:=(v_meta->>'damage_base')::integer;\n  END IF;\n    IF v_kind='utilita' THEN\n    genjutsu_release_meta:=combat_v2_genjutsu_internal.release_meta(p_round,p_actor,p_request_key,v_i);\n    IF genjutsu_release_meta IS NOT NULL THEN v_meta:=genjutsu_release_meta;v_target:=(v_i->>'target_actor')::uuid;v_cost:=0;v_base:=0;END IF;\n  END IF;\n  escape_meta:=combat_panel_private.immobilization_escape_meta(p_round,p_actor,p_request_key,v_i);\n  IF escape_meta IS NOT NULL THEN\n    IF multiplication_meta IS NOT NULL THEN RAISE EXCEPTION 'immobilization_escape_action_conflict' USING ERRCODE='22023'; END IF;\n","occurrences":1},{"before":"    update clan_marionettisti_private.ocular_sever_authorizations_v1\n      set proof=v_fili_source where request_key=p_request_key and transaction_id=txid_current();\n  end if;\n  v_event:=public.combat_v2_event_begin(p_round,p_request_key,'combat_v2_action_declare',jsonb_build_object('actor',p_actor,'intent',v_i,'text',coalesce(p_text,'')),null);\n  if (v_event->>'replay')::boolean then return v_event->'result'; end if; v_event_id:=(v_event->>'event_id')::uuid;\n  insert into public.combat_v2_declarations(round_id,actor_id,kind,target_actor_id,sanitized_intent,declaration_text,controller_user_snapshot,controller_version_snapshot,request_key,cost_snapshot)\n  values(p_round,p_actor,v_kind,v_target,v_i||case when v_meta is null then '{}'::jsonb else jsonb_build_object('server_ability',v_meta) end,\n    coalesce(p_text,''),coalesce(v_uid,v_service_actor),v_a.controller_version,p_request_key,clan_hyuga_private.sedici_cost_snapshot(p_actor,jsonb_build_object('chakra',v_cost,'damage_base',v_base))) returning id into v_id;\n  IF v_source='arma' THEN\n    PERFORM combat_panel_private.shuriken_spend_v1(v_id,p_request_key);\n  END IF;\n","after":"    update clan_marionettisti_private.ocular_sever_authorizations_v1\n      set proof=v_fili_source where request_key=p_request_key and transaction_id=txid_current();\n  end if;\n  IF cure_meta IS NOT NULL AND (v_meta IS DISTINCT FROM cure_meta OR v_cost<>20 OR v_base<>0) THEN\n    RAISE EXCEPTION 'cure_action_family_conflict' USING ERRCODE='22023';\n  END IF;\n  v_event:=public.combat_v2_event_begin(p_round,p_request_key,'combat_v2_action_declare',jsonb_build_object('actor',p_actor,'intent',v_i,'text',coalesce(p_text,'')),null);\n  if (v_event->>'replay')::boolean then return v_event->'result'; end if; v_event_id:=(v_event->>'event_id')::uuid;\n  insert into public.combat_v2_declarations(round_id,actor_id,kind,target_actor_id,sanitized_intent,declaration_text,controller_user_snapshot,controller_version_snapshot,request_key,cost_snapshot)\n  values(p_round,p_actor,v_kind,v_target,v_i||case when v_meta is null then '{}'::jsonb else jsonb_build_object('server_ability',v_meta) end,\n    coalesce(p_text,''),coalesce(v_uid,v_service_actor),v_a.controller_version,p_request_key,clan_hyuga_private.sedici_cost_snapshot(p_actor,jsonb_build_object('chakra',v_cost,'damage_base',v_base))) returning id into v_id;\n  PERFORM combat_panel_private.cure_bind_v1(v_id);\n  IF v_source='arma' THEN\n    PERFORM combat_panel_private.shuriken_spend_v1(v_id,p_request_key);\n  END IF;\n","occurrences":1},{"before":"  PERFORM clan_hyuga_private.sedici_freeze(v_id);\n  PERFORM clan_uchiha_private.fireball_freeze(v_id); PERFORM clan_inuzuka_private.zanna_freeze(v_id);\n  PERFORM combat_v2_elemental_internal.suiton_bind_source(v_id);\n  PERFORM combat_v2_elemental_internal.other_bind_source(v_id);\n  if v_kind='attacco' and v_source='clan' and v_ability='e361f7c3-f90b-47ec-bfee-ccbda21257d9'::uuid then\n    perform clan_marionettisti_private.freeze_offensive_profile(v_id);\n  end if;\n","after":"  PERFORM clan_hyuga_private.sedici_freeze(v_id);\n  PERFORM clan_uchiha_private.fireball_freeze(v_id); PERFORM clan_inuzuka_private.zanna_freeze(v_id);\n  PERFORM combat_v2_elemental_internal.suiton_bind_source(v_id);\n    PERFORM combat_v2_elemental_internal.other_bind_source(v_id);\n  PERFORM combat_v2_genjutsu_internal.bind_source(v_id);\n  PERFORM combat_v2_genjutsu_internal.bind_release(v_id);\n  if v_kind='attacco' and v_source='clan' and v_ability='e361f7c3-f90b-47ec-bfee-ccbda21257d9'::uuid then\n    perform clan_marionettisti_private.freeze_offensive_profile(v_id);\n  end if;\n","occurrences":1}]},{"signature":"public.combat_v2_round_resolve(uuid,uuid)","before_sha256":"4f2f9020cb2a264bc4058b1edeb2eed3bb4b33faae40fd878584cda896985a85","after_sha256":"c3242f7ef7d828b88e349996e08c52c73758be0a4848fad7329fa9e0be437daa","after_source_md5":"954c762bcaf8a4638d51a9061a275f24","hunks":[{"before":"    ORDER BY d.actor_id,d.id;\n  update public.combat_v2_rounds set phase='risoluzione',state='risoluzione' where id=p_round;\n  for v_d in select * from public.combat_v2_declarations where round_id=p_round and kind in ('attacco','movimento','utilita','passa') and state<>'risolta' order by order_no loop\n    movement_calc:=NULL;aburame_calc:=NULL;\n    select * into v_att from public.combat_v2_actors where id=v_d.actor_id for update;\n    if v_d.kind='movimento' then\n","after":"    ORDER BY d.actor_id,d.id;\n  update public.combat_v2_rounds set phase='risoluzione',state='risoluzione' where id=p_round;\n  for v_d in select * from public.combat_v2_declarations where round_id=p_round and kind in ('attacco','movimento','utilita','passa') and state<>'risolta' order by order_no loop\n    PERFORM combat_v2_genjutsu_internal.resolution_enter(p_round,v_d.id);\n    movement_calc:=NULL;aburame_calc:=NULL;\n    select * into v_att from public.combat_v2_actors where id=v_d.actor_id for update;\n    if v_d.kind='movimento' then\n","occurrences":1},{"before":"        multiplication_effect:=combat_panel_private.multiplication_effect(multiplication_facts,v_reaction);\n        v_reaction:=multiplication_effect->>'effective_reaction';\n        -- [MISSION-GUARD-006] Guard locale dopo la lettura concorrente.\n        if v_reaction in ('copie','tecnica') AND NOT EXISTS(SELECT 1 FROM clan_hyuga_private.rotation_sources rs WHERE rs.declaration_id=v_def.id) AND NOT combat_v2_elemental_internal.scudo_source_valid(v_def.id) AND NOT clan_aburame_private.clone_source_valid(v_def.id) then\n          perform public.combat_v2_fail('profilo_runtime_non_disponibile','La difesa speciale non ha un resolver V2 attivo.',409,p_request_key,'{}');\n        end if;\n        v_kind:=lower(coalesce(v_meta->>'kind','fisico')); if v_kind not in ('fisico','ninjutsu','genjutsu') then v_kind:='fisico'; end if;\n","after":"        multiplication_effect:=combat_panel_private.multiplication_effect(multiplication_facts,v_reaction);\n        v_reaction:=multiplication_effect->>'effective_reaction';\n        -- [MISSION-GUARD-006] Guard locale dopo la lettura concorrente.\n        if v_reaction in ('copie','tecnica') AND NOT EXISTS(SELECT 1 FROM clan_hyuga_private.rotation_sources rs WHERE rs.declaration_id=v_def.id) AND NOT combat_v2_elemental_internal.scudo_source_valid(v_def.id) AND NOT clan_aburame_private.clone_source_valid(v_def.id) AND NOT combat_v2_genjutsu_internal.kai_defense_valid(v_d.id,v_def.id) then\n          perform public.combat_v2_fail('profilo_runtime_non_disponibile','La difesa speciale non ha un resolver V2 attivo.',409,p_request_key,'{}');\n        end if;\n        v_kind:=lower(coalesce(v_meta->>'kind','fisico')); if v_kind not in ('fisico','ninjutsu','genjutsu') then v_kind:='fisico'; end if;\n","occurrences":1},{"before":"            'danno_grezzo',0,'danno_applicato',0,'striscio',false,'cap_attivo',false);\n        END IF;\n        v_calc:=v_calc||jsonb_build_object('mod_assalto',multiplication_effect->'assault_bonus','mod_mira',0);\n        v_rng:=combat_v2_private.rng_seal(v_s.id,p_round,v_d.id,'attack',v_rng_context,v_entropy,\n          jsonb_build_object(\n            'dice_attack',jsonb_build_array(v_a1,v_a2),\n","after":"            'danno_grezzo',0,'danno_applicato',0,'striscio',false,'cap_attivo',false);\n        END IF;\n        v_calc:=v_calc||jsonb_build_object('mod_assalto',multiplication_effect->'assault_bonus','mod_mira',0);\n                v_calc:=combat_v2_genjutsu_internal.comparison(v_d.id,v_def.id,v_calc);\n        v_rng:=combat_v2_private.rng_seal(v_s.id,p_round,v_d.id,'attack',v_rng_context,v_entropy,\n          jsonb_build_object(\n            'dice_attack',jsonb_build_array(v_a1,v_a2),\n","occurrences":1},{"before":"        END IF;\n        -- B5: credito originario dopo il danno nativo, prima di Rotazione/armatura/PV.\n        IF nara_launch IS NOT NULL THEN v_damage:=0; END IF;\n        elemental_cap:=combat_effects_private.capture_source_cap(v_d.id,v_damage);\n        IF elemental_cap<>'{}'::jsonb THEN\n          v_calc:=v_calc||jsonb_build_object('common_effects',\n","after":"        END IF;\n        -- B5: credito originario dopo il danno nativo, prima di Rotazione/armatura/PV.\n        IF nara_launch IS NOT NULL THEN v_damage:=0; END IF;\n                IF v_calc#>>'{paralisi,contract}'='paralisi-movement/1' THEN v_damage:=0;END IF;\n        elemental_cap:=combat_effects_private.capture_source_cap(v_d.id,v_damage);\n        IF elemental_cap<>'{}'::jsonb THEN\n          v_calc:=v_calc||jsonb_build_object('common_effects',\n","occurrences":1},{"before":"          v_damage:=0;\n          v_calc:=v_calc||jsonb_build_object('danno_grezzo',0,'danno_applicato',0,'striscio',false,'cap_attivo',false);\n        END IF;\n        v_calc:=v_calc||jsonb_build_object('sabaku_armor',clan_sabaku_private.armor_absorb(multiplication_target,v_damage));\n        v_damage:=(v_calc#>>'{sabaku_armor,damage_after}')::integer;\n        IF NOT (v_calc->'sabaku_armor' ? 'version') THEN v_calc:=v_calc-'sabaku_armor'; END IF;\n        v_new_hp:=greatest(0,coalesce((v_tar.mechanics_snapshot->>'vita')::int,0)-v_damage);\n        update public.combat_v2_actors set mechanics_snapshot=jsonb_set(mechanics_snapshot,'{vita}',to_jsonb(v_new_hp),false),state=case when v_new_hp=0 then 'fuori' else state end where id=v_tar.id;\n        if v_values and v_tar.actor_kind='pg' and v_damage>0 then\n","after":"          v_damage:=0;\n          v_calc:=v_calc||jsonb_build_object('danno_grezzo',0,'danno_applicato',0,'striscio',false,'cap_attivo',false);\n        END IF;\n                IF v_calc#>>'{paralisi,contract}' IS DISTINCT FROM 'paralisi-movement/1' THEN\n        v_calc:=v_calc||jsonb_build_object('sabaku_armor',clan_sabaku_private.armor_absorb(multiplication_target,v_damage));\n        v_damage:=(v_calc#>>'{sabaku_armor,damage_after}')::integer;\n        IF NOT (v_calc->'sabaku_armor' ? 'version') THEN v_calc:=v_calc-'sabaku_armor'; END IF;\n        END IF;\n        v_new_hp:=greatest(0,coalesce((v_tar.mechanics_snapshot->>'vita')::int,0)-v_damage);\n        update public.combat_v2_actors set mechanics_snapshot=jsonb_set(mechanics_snapshot,'{vita}',to_jsonb(v_new_hp),false),state=case when v_new_hp=0 then 'fuori' else state end where id=v_tar.id;\n        if v_values and v_tar.actor_kind='pg' and v_damage>0 then\n","occurrences":1},{"before":"           ELSE v_final>=0 AND NOT (multiplication_effect->>'copy_intercepted')::boolean END)\n          THEN 0 ELSE least(9,coalesce((mechanics_snapshot->>'slancio')::int,0)+3) END),true) where id=v_att.id;\n        elemental_order_outcome:=jsonb_build_object('raw',v_calc,'rng_audit',v_rng,'rating_attack',v_vote_a,'rating_defense',v_vote_d,\n          'quality_correction',v_corr,'quality_applicable',v_reaction<>'sostituzione','threshold_margin',v_final,'success',CASE WHEN akimichi_partial.declaration_id IS NOT NULL THEN (v_calc->>'colpito')::boolean\n            ELSE v_final>=0 AND v_reaction<>'sostituzione' AND NOT (multiplication_effect->>'copy_intercepted')::boolean END,\n          'damage_applied',v_damage,'target_hp_after',v_new_hp,'ko',v_new_hp=0,'copies_outcome',case when v_reaction='copie' and v_final<0 then 'copia_colpita' when v_reaction='copie' then 'originale_individuato' end)||CASE WHEN jsonb_array_length(multiplication_facts)>0 THEN jsonb_build_object(\n            'multiplication',multiplication_facts,'multiplication_effect',multiplication_effect) ELSE '{}'::jsonb END;\n","after":"           ELSE v_final>=0 AND NOT (multiplication_effect->>'copy_intercepted')::boolean END)\n          THEN 0 ELSE least(9,coalesce((mechanics_snapshot->>'slancio')::int,0)+3) END),true) where id=v_att.id;\n        elemental_order_outcome:=jsonb_build_object('raw',v_calc,'rng_audit',v_rng,'rating_attack',v_vote_a,'rating_defense',v_vote_d,\n          'quality_correction',v_corr,'quality_applicable',v_reaction<>'sostituzione','threshold_margin',v_final,'success',CASE WHEN v_calc#>>'{paralisi,contract}'='paralisi-movement/1' THEN combat_v2_genjutsu_internal.success(v_calc,v_final,(multiplication_effect->>'copy_intercepted')::boolean) WHEN akimichi_partial.declaration_id IS NOT NULL THEN (v_calc->>'colpito')::boolean\n            ELSE v_final>=0 AND v_reaction<>'sostituzione' AND NOT (multiplication_effect->>'copy_intercepted')::boolean END,\n          'damage_applied',v_damage,'target_hp_after',v_new_hp,'ko',v_new_hp=0,'copies_outcome',case when v_reaction='copie' and v_final<0 then 'copia_colpita' when v_reaction='copie' then 'originale_individuato' end)||CASE WHEN jsonb_array_length(multiplication_facts)>0 THEN jsonb_build_object(\n            'multiplication',multiplication_facts,'multiplication_effect',multiplication_effect) ELSE '{}'::jsonb END;\n","occurrences":1},{"before":"            nara_facts:=combat_panel_private.nara_record_control_v1(elemental_target,elemental_order_outcome);\n            elemental_order_outcome:=elemental_order_outcome||jsonb_build_object('nara_possession',nara_facts);\n          END IF;\n          UPDATE public.combat_v2_attack_targets SET state='risolta',outcome=elemental_order_outcome WHERE id=elemental_target;\n          PERFORM combat_effects_private.settle_native_target(v_d.id,elemental_target);\n        END LOOP;\n","after":"            nara_facts:=combat_panel_private.nara_record_control_v1(elemental_target,elemental_order_outcome);\n            elemental_order_outcome:=elemental_order_outcome||jsonb_build_object('nara_possession',nara_facts);\n          END IF;\n                    elemental_order_outcome:=combat_v2_genjutsu_internal.decorate_outcome(v_d.id,elemental_target,elemental_order_outcome);\n          UPDATE public.combat_v2_attack_targets SET state='risolta',outcome=elemental_order_outcome WHERE id=elemental_target;\n          PERFORM combat_effects_private.settle_native_target(v_d.id,elemental_target);\n        END LOOP;\n","occurrences":1},{"before":"      END IF;\n\n      PERFORM clan_hyuga_private.rotation_finish(v_d.id,p_request_key);\n    elsif v_d.kind='utilita' AND EXISTS(SELECT 1 FROM clan_sabaku_private.clone_plans WHERE declaration_id=v_d.id) THEN\n      v_calc:=clan_sabaku_private.clone_resolve_creation(v_d.id);\n      update public.combat_v2_declarations set state='risolta',outcome=v_calc where id=v_d.id;\n","after":"      END IF;\n\n      PERFORM clan_hyuga_private.rotation_finish(v_d.id,p_request_key);\n    elsif v_d.kind='utilita' AND v_d.sanitized_intent#>>'{server_ability,cure_contract}'='palmo-curativo/1' THEN\n      v_calc:=combat_panel_private.cure_resolve_v1(v_d.id);\n      update public.combat_v2_declarations set state='risolta',outcome=v_calc where id=v_d.id;\n        elsif v_d.kind='utilita' AND v_d.sanitized_intent#>>'{server_ability,genjutsu_release_version}'='paralisi-release/1' THEN\n      v_calc:=combat_v2_genjutsu_internal.resolve_release(v_d.id);\n      update public.combat_v2_declarations set state='risolta',outcome=v_calc where id=v_d.id;\n    elsif v_d.kind='utilita' AND EXISTS(SELECT 1 FROM clan_sabaku_private.clone_plans WHERE declaration_id=v_d.id) THEN\n      v_calc:=clan_sabaku_private.clone_resolve_creation(v_d.id);\n      update public.combat_v2_declarations set state='risolta',outcome=v_calc where id=v_d.id;\n","occurrences":1},{"before":"    WHERE t.round_id=p_round ORDER BY t.id LOOP\n    PERFORM clan_hyuga_private.sedici_apply_result(sedici_target);\n  END LOOP;\n  effects_lifecycle:=combat_effects_private.lifecycle_before_report(p_round);\n  v_after:=(select jsonb_agg(jsonb_build_object('actor',a.id,'state',a.state,'position_m',a.position_m,'mechanics',a.mechanics_snapshot) order by a.id) from public.combat_v2_actors a where a.session_id=v_s.id);\n  v_report:=jsonb_build_object('initial_actors',v_before,'final_actors',v_after,'effects_lifecycle',effects_lifecycle,\n    'hyuga_effects',clan_hyuga_private.sedici_round_facts(p_round),\n    'declarations',(select jsonb_agg(jsonb_build_object('id',d.id,'actor',d.actor_id,'kind',d.kind,'target',d.target_actor_id,'parent',d.parent_attack_id,'order',d.order_no,'state',d.state,'cost',d.cost_snapshot||jsonb_build_object('chakra',clan_hyuga_private.sedici_frozen_cost(d.actor_id,d.cost_snapshot)),'outcome',d.outcome,'scudo_facts',CASE WHEN d.kind='difesa' AND d.state='risolta' AND combat_v2_elemental_internal.scudo_source_valid(d.id) THEN combat_v2_elemental_internal.scudo_narrative(d.id) ELSE '{}'::jsonb END,'elemental_facts',CASE WHEN combat_v2_elemental_internal.other_narrative_supported(d.id) THEN combat_v2_elemental_internal.other_narrative_projection(d.id) ELSE '{}'::jsonb END,'suiton_facts',CASE WHEN combat_v2_elemental_internal.suiton_narrative_supported(d.id)\n      THEN combat_v2_elemental_internal.suiton_narrative_projection(d.id)||jsonb_build_object(\n        'target_actor_id',(SELECT s.target_actor_id FROM combat_v2_elemental_internal.suiton_sources s WHERE s.declaration_id=d.id))\n      ELSE NULL END) order by d.order_no nulls last,d.id) from public.combat_v2_declarations d where d.round_id=p_round),\n","after":"    WHERE t.round_id=p_round ORDER BY t.id LOOP\n    PERFORM clan_hyuga_private.sedici_apply_result(sedici_target);\n  END LOOP;\n  PERFORM combat_v2_genjutsu_internal.resolution_leave();\n  effects_lifecycle:=combat_effects_private.lifecycle_before_report(p_round);\n  v_after:=(select jsonb_agg(jsonb_build_object('actor',a.id,'state',a.state,'position_m',a.position_m,'mechanics',a.mechanics_snapshot) order by a.id) from public.combat_v2_actors a where a.session_id=v_s.id);\n  v_report:=jsonb_build_object('initial_actors',v_before,'final_actors',v_after,'effects_lifecycle',effects_lifecycle,\n    'hyuga_effects',clan_hyuga_private.sedici_round_facts(p_round),\n    'declarations',(select jsonb_agg(jsonb_build_object('id',d.id,'actor',d.actor_id,'kind',d.kind,'target',d.target_actor_id,'parent',d.parent_attack_id,'order',d.order_no,'state',d.state,'cost',d.cost_snapshot||jsonb_build_object('chakra',clan_hyuga_private.sedici_frozen_cost(d.actor_id,d.cost_snapshot)),'outcome',d.outcome,'genjutsu_facts',combat_v2_genjutsu_internal.report_projection(d.id),'scudo_facts',CASE WHEN d.kind='difesa' AND d.state='risolta' AND combat_v2_elemental_internal.scudo_source_valid(d.id) THEN combat_v2_elemental_internal.scudo_narrative(d.id) ELSE '{}'::jsonb END,'elemental_facts',CASE WHEN combat_v2_elemental_internal.other_narrative_supported(d.id) THEN combat_v2_elemental_internal.other_narrative_projection(d.id) ELSE '{}'::jsonb END,'suiton_facts',CASE WHEN combat_v2_elemental_internal.suiton_narrative_supported(d.id)\n      THEN combat_v2_elemental_internal.suiton_narrative_projection(d.id)||jsonb_build_object(\n        'target_actor_id',(SELECT s.target_actor_id FROM combat_v2_elemental_internal.suiton_sources s WHERE s.declaration_id=d.id))\n      ELSE NULL END) order by d.order_no nulls last,d.id) from public.combat_v2_declarations d where d.round_id=p_round),\n","occurrences":1}]},{"signature":"combat_panel_private.round_options_authoritative(uuid,uuid)","before_sha256":"879b5d69f1ca6a8f9cc28421699b77d649e3e277f4130a40308ca3acfc8a895c","after_sha256":"624a967648709007df47703ef643166f641bc75bd412c475e277543ebba68d7e","after_source_md5":"4def81b4f389a7ddb85703d582e8b404","hunks":[{"before":"    'abilities',(\n      select coalesce(jsonb_agg(combat_v2_multitarget_internal.enrich_ability_v1(combat_v2_elemental_internal.other_ability_meta(p_actor,combat_v2_elemental_internal.suiton_ability_meta(p_actor,e.value))) order by e.ord),'[]'::jsonb)\n      from jsonb_array_elements(coalesce(v_a.mechanics_snapshot->'abilities','[]'::jsonb)) with ordinality e(value,ord)\n      where e.value->>'id'<>'31b15861-fb78-4f8a-ac1c-ebf2d957c32e'\n        and (not combat_v2_elemental_internal.is_target_v1((e.value->>'id')::uuid)\n          or (v_r.phase='raccolta_azioni' and (combat_v2_elemental_internal.eligible_v1(v_a.character_id,(e.value->>'id')::uuid,false)\n            or (e.value->>'source'='clan' and coalesce(combat_v2_elemental_internal.suiton_profile(p_actor,(e.value->>'id')::uuid),combat_v2_elemental_internal.other_profile(p_actor,(e.value->>'id')::uuid)) IS NOT NULL)))\n","after":"    'abilities',(\n      select coalesce(jsonb_agg(combat_v2_multitarget_internal.enrich_ability_v1(combat_v2_elemental_internal.other_ability_meta(p_actor,combat_v2_elemental_internal.suiton_ability_meta(p_actor,e.value))) order by e.ord),'[]'::jsonb)\n      from jsonb_array_elements(coalesce(v_a.mechanics_snapshot->'abilities','[]'::jsonb)) with ordinality e(value,ord)\n      where e.value->>'id' NOT IN('31b15861-fb78-4f8a-ac1c-ebf2d957c32e','c47814d2-ef27-4967-87ad-da633b0f4d78')\n        and (not combat_v2_elemental_internal.is_target_v1((e.value->>'id')::uuid)\n          or (v_r.phase='raccolta_azioni' and (combat_v2_elemental_internal.eligible_v1(v_a.character_id,(e.value->>'id')::uuid,false)\n            or (e.value->>'source'='clan' and coalesce(combat_v2_elemental_internal.suiton_profile(p_actor,(e.value->>'id')::uuid),combat_v2_elemental_internal.other_profile(p_actor,(e.value->>'id')::uuid)) IS NOT NULL)))\n","occurrences":1}]},{"signature":"public.combat_v2_actor_ability(uuid,text,uuid,boolean)","before_sha256":"cb9e81c2b23aedb968eafa00f15dc3de188e57a5e72f04805a2d0617934575a7","after_sha256":"3f86b9972ead72801b6a4c392d2b180d011ca2605075855cd21a59b848f665e4","after_source_md5":"6bc1065e07011266fead520f4b7d3b47","hunks":[{"before":" STABLE SECURITY DEFINER\n SET search_path TO ''\nAS $function$\n SELECT CASE WHEN p_source='clan' AND p_ability='127f3854-4183-4354-a654-f59320d8807e' AND clan_hoki_private.routes_ability(p_actor,p_ability) THEN clan_hoki_private.needle_ability(p_actor,p_defense)\n WHEN p_source='clan' AND p_ability='c8d32b00-3917-41a6-8906-388e7b9efcc7' AND clan_hoki_private.routes_ability(p_actor,p_ability) THEN NULL\n WHEN p_source='clan' AND p_ability='3b4c4fd0-c0c2-46a0-a387-f47a95ef7dda'::uuid AND clan_akimichi_private.replacement_applies(p_actor) THEN NULL::jsonb\n WHEN p_source='clan' AND p_ability='214af896-15f8-43e6-858b-614d2851dd3b'::uuid AND clan_akimichi_private.replacement_applies(p_actor) THEN\n","after":" STABLE SECURITY DEFINER\n SET search_path TO ''\nAS $function$\n SELECT CASE WHEN p_source='clan' AND p_ability='c47814d2-ef27-4967-87ad-da633b0f4d78'::uuid THEN NULL::jsonb\n WHEN p_source='clan' AND p_ability='31d5d554-44d1-4042-9920-3ddd3bedff7e'::uuid THEN CASE WHEN p_defense THEN NULL::jsonb ELSE combat_v2_genjutsu_internal.actor_meta(p_actor) END\n WHEN p_source='clan' AND p_ability='127f3854-4183-4354-a654-f59320d8807e' AND clan_hoki_private.routes_ability(p_actor,p_ability) THEN clan_hoki_private.needle_ability(p_actor,p_defense)\n WHEN p_source='clan' AND p_ability='c8d32b00-3917-41a6-8906-388e7b9efcc7' AND clan_hoki_private.routes_ability(p_actor,p_ability) THEN NULL\n WHEN p_source='clan' AND p_ability='3b4c4fd0-c0c2-46a0-a387-f47a95ef7dda'::uuid AND clan_akimichi_private.replacement_applies(p_actor) THEN NULL::jsonb\n WHEN p_source='clan' AND p_ability='214af896-15f8-43e6-858b-614d2851dd3b'::uuid AND clan_akimichi_private.replacement_applies(p_actor) THEN\n","occurrences":1}]},{"signature":"combat_panel_private.master_options(uuid,uuid,bigint)","before_sha256":"a930c6b91112cf8e04daceac46154bcbb5549e21b5ec954bd60f3f0fdd1bb7f7","after_sha256":"155b2a279cbef5f31ee7ee332f7844fe928ba3394cd43439906972f51129ca32","after_source_md5":"84c29f6a84fbe579caf5bb3fec7a2382","hunks":[{"before":" PERFORM combat_panel_private.multiplication_offers(c.id,c.context_version,env);\n PERFORM combat_panel_private.immobilization_escape_offers(c.id,c.context_version,env);\n PERFORM combat_panel_private.nara_control_offers_v1(c.id,c.context_version,env);\n PERFORM clan_sabaku_private.clone_offers(c.id,c.context_version,env);\n PERFORM clan_sabaku_private.flow_master_offers(c.id,c.context_version,env);\n PERFORM clan_hyuga_private.rotation_panel_offers(c.id,c.context_version);\n","after":" PERFORM combat_panel_private.multiplication_offers(c.id,c.context_version,env);\n PERFORM combat_panel_private.immobilization_escape_offers(c.id,c.context_version,env);\n PERFORM combat_panel_private.nara_control_offers_v1(c.id,c.context_version,env);\n PERFORM combat_panel_private.cure_offers_v1(c.id,c.context_version,env);\n PERFORM clan_sabaku_private.clone_offers(c.id,c.context_version,env);\n PERFORM clan_sabaku_private.flow_master_offers(c.id,c.context_version,env);\n PERFORM clan_hyuga_private.rotation_panel_offers(c.id,c.context_version);\n","occurrences":1},{"before":"   WHERE context_id=c.id AND context_version=c.context_version AND state='offered' AND kind='action'\n    AND source_payload->>'kind'='passa' AND NOT requires_role;\n END IF;\n SELECT coalesce(jsonb_agg(combat_panel_private.offer_projection(id) ORDER BY created_at,id),'[]') INTO offers\n   FROM combat_panel_private.offers WHERE context_id=c.id AND context_version=c.context_version AND state='offered';\n RETURN clan_aburame_private.consumer_projection(jsonb_set(combat_panel_private.attach_rating_offers(jsonb_set(env,'{offers}',offers),c.id),\n   '{movement_explanations}',coalesce(combat_panel_private.movement_explanations(c.id,c.context_version),'null'::jsonb)));\n","after":"   WHERE context_id=c.id AND context_version=c.context_version AND state='offered' AND kind='action'\n    AND source_payload->>'kind'='passa' AND NOT requires_role;\n END IF;\n   PERFORM combat_v2_genjutsu_internal.panel_options(c.id,c.context_version);\n  SELECT coalesce(jsonb_agg(combat_panel_private.offer_projection(id) ORDER BY created_at,id),'[]') INTO offers\n   FROM combat_panel_private.offers WHERE context_id=c.id AND context_version=c.context_version AND state='offered';\n RETURN clan_aburame_private.consumer_projection(jsonb_set(combat_panel_private.attach_rating_offers(jsonb_set(env,'{offers}',offers),c.id),\n   '{movement_explanations}',coalesce(combat_panel_private.movement_explanations(c.id,c.context_version),'null'::jsonb)));\n","occurrences":1}]},{"signature":"combat_panel_private.ordinary_options(uuid,uuid,bigint)","before_sha256":"a6c6e6c4cc2cefce4819c0925cc8211f4f0fce9c9e77e7f4e3462b5cee42e88e","after_sha256":"c814662051a0c6cdbeab0c020f4d2fb13cc124e66cdf2860130343a7b598f632","after_source_md5":"4337c8fe49127d7d72edc0789fc0352b","hunks":[{"before":" IF c.location_id='0b85f354-9cdb-47e1-baf9-3d266bb7e06b'::uuid THEN PERFORM set_config('application_name','TUS_PERF helper_immobilization',true); END IF; -- INUZUKA-DISPATCH-DIAG020\n PERFORM combat_panel_private.immobilization_escape_offers(c.id,c.context_version,env);\n PERFORM combat_panel_private.nara_control_offers_v1(c.id,c.context_version,env);\n IF c.location_id='0b85f354-9cdb-47e1-baf9-3d266bb7e06b'::uuid THEN PERFORM set_config('application_name','TUS_PERF helper_clone',true); END IF; -- INUZUKA-DISPATCH-DIAG020\n PERFORM clan_sabaku_private.clone_offers(c.id,c.context_version,env);\n PERFORM clan_sabaku_private.flow_ordinary_figure_offers(c.id,c.context_version,env);\n","after":" IF c.location_id='0b85f354-9cdb-47e1-baf9-3d266bb7e06b'::uuid THEN PERFORM set_config('application_name','TUS_PERF helper_immobilization',true); END IF; -- INUZUKA-DISPATCH-DIAG020\n PERFORM combat_panel_private.immobilization_escape_offers(c.id,c.context_version,env);\n PERFORM combat_panel_private.nara_control_offers_v1(c.id,c.context_version,env);\n PERFORM combat_panel_private.cure_offers_v1(c.id,c.context_version,env);\n IF c.location_id='0b85f354-9cdb-47e1-baf9-3d266bb7e06b'::uuid THEN PERFORM set_config('application_name','TUS_PERF helper_clone',true); END IF; -- INUZUKA-DISPATCH-DIAG020\n PERFORM clan_sabaku_private.clone_offers(c.id,c.context_version,env);\n PERFORM clan_sabaku_private.flow_ordinary_figure_offers(c.id,c.context_version,env);\n","occurrences":1},{"before":"  PERFORM combat_panel_private.master_open_offers(c.id,c.context_version);\n END IF;\n PERFORM set_config('application_name','TUS_PERF render_offers',true); -- INUZUKA-ORDINARY-DIAG018\n SELECT coalesce(jsonb_agg(combat_panel_private.offer_projection(id) ORDER BY created_at,id),'[]'::jsonb)\n   INTO rendered FROM combat_panel_private.offers WHERE context_id=c.id\n     AND context_version=c.context_version AND state='offered';\n PERFORM set_config('application_name','TUS_PERF movement_explanations',true); -- INUZUKA-ORDINARY-DIAG018\n","after":"  PERFORM combat_panel_private.master_open_offers(c.id,c.context_version);\n END IF;\n PERFORM set_config('application_name','TUS_PERF render_offers',true); -- INUZUKA-ORDINARY-DIAG018\n   PERFORM combat_v2_genjutsu_internal.panel_options(c.id,c.context_version);\n  SELECT coalesce(jsonb_agg(combat_panel_private.offer_projection(id) ORDER BY created_at,id),'[]'::jsonb)\n   INTO rendered FROM combat_panel_private.offers WHERE context_id=c.id\n     AND context_version=c.context_version AND state='offered';\n PERFORM set_config('application_name','TUS_PERF movement_explanations',true); -- INUZUKA-ORDINARY-DIAG018\n","occurrences":1}]},{"signature":"public.combat_panel_commit_v1(jsonb)","before_sha256":"cd89190904e879eb762d052e3055f32bbf8911b7e326f1d9b2de3a1e6879271d","after_sha256":"2b4660b431f9824cef1ed59b7f299998e8a7be06f66d18cb8c2e5b734c841fbe","after_source_md5":"ce0c32cce5f6da141e20c015aba9e880","hunks":[{"before":" IF reason IS NOT NULL THEN RAISE EXCEPTION 'panel_access_rejected' USING ERRCODE='42501'; END IF;\n IF adapter IS DISTINCT FROM combat_panel_private.location_adapter((p->>'location_id')::uuid) THEN\n   RAISE EXCEPTION 'panel_context_stale' USING ERRCODE='40001'; END IF;\n IF offer.kind='administration' AND offer.operation='open'\n   AND offer.source_payload->>'dispatch'='master_session_open' THEN\n   RETURN combat_panel_private.commit_master_open(p); END IF;\n","after":" IF reason IS NOT NULL THEN RAISE EXCEPTION 'panel_access_rejected' USING ERRCODE='42501'; END IF;\n IF adapter IS DISTINCT FROM combat_panel_private.location_adapter((p->>'location_id')::uuid) THEN\n   RAISE EXCEPTION 'panel_context_stale' USING ERRCODE='40001'; END IF;\n IF offer.source_payload->>'dispatch' IN('cure_staff_profile','cure_action') THEN\n   RETURN combat_panel_private.cure_commit_v1(p);\n END IF;\n IF offer.kind='administration' AND offer.operation='open'\n   AND offer.source_payload->>'dispatch'='master_session_open' THEN\n   RETURN combat_panel_private.commit_master_open(p); END IF;\n","occurrences":1}]},{"signature":"combat_panel_private.movement_block_reason(uuid)","before_sha256":"de90f13017b31fb70235bed7685d78cc22239d7cd3123e6f0433fb57798655ef","after_sha256":"2cb55e145c05b8df468706297d83bff59461027b7c2f958f90b6688a3b84695b","after_source_md5":"9cd995d873f2ae85f3cac5c0d7ff21ad","hunks":[{"before":" SELECT * INTO STRICT a FROM public.combat_v2_actors WHERE id=p_body;\n IF a.state<>'attivo' OR coalesce((a.mechanics_snapshot->>'vita')::numeric,0)<=0 THEN\n   RETURN 'actor_inoperative'; END IF;\n IF combat_panel_private.immobilization_active(a.id) THEN RETURN 'immobilized'; END IF;\n IF a.mechanics_snapshot ? 'mobility' THEN\n   mobility:=a.mechanics_snapshot->'mobility';\n   IF jsonb_typeof(mobility) IS DISTINCT FROM 'object'\n","after":" SELECT * INTO STRICT a FROM public.combat_v2_actors WHERE id=p_body;\n IF a.state<>'attivo' OR coalesce((a.mechanics_snapshot->>'vita')::numeric,0)<=0 THEN\n   RETURN 'actor_inoperative'; END IF;\n IF EXISTS(SELECT 1 FROM public.combat_v2_rounds r WHERE r.session_id=a.session_id\n  AND r.phase IN('raccolta_azioni','raccolta_difese','congelato','risoluzione')\n  AND combat_panel_private.cure_turn_used_v1(r.id,a.id)) THEN RETURN 'healing_turn';END IF;\n IF combat_panel_private.immobilization_active(a.id) THEN RETURN 'immobilized'; END IF;\n IF combat_v2_genjutsu_internal.movement_blocked(a.id) THEN RETURN 'genjutsu_movement_blocked';END IF;\n IF a.mechanics_snapshot ? 'mobility' THEN\n   mobility:=a.mechanics_snapshot->'mobility';\n   IF jsonb_typeof(mobility) IS DISTINCT FROM 'object'\n","occurrences":1}]},{"signature":"public.post_heal(uuid,uuid)","before_sha256":"54c980f8e2a5cad89f9f539538e565db2d71397453eac61db51577eb0b3e2ce6","after_sha256":"4526d6a2a7dcbbb472696adf9fa2d0130dfdf9a75ef049a77f9b6086336888bc","after_source_md5":"dcde447ee079472efa4fd41c1c911633","hunks":[{"before":"  if v_test and not public._puo_test_room() then raise exception 'La Test Room è riservata allo staff'; end if;\n  select * into a from public.characters where user_id=auth.uid() limit 1;\n  if a.id is null then raise exception 'nessun personaggio associato'; end if;\n  if not v_staff and not (coalesce(a.corporation,'') ~* 'medic') then\n    raise exception 'Solo un ninja medico (corporazione Medico) può curare con il Palmo Curativo.';\n  end if;\n","after":"  if v_test and not public._puo_test_room() then raise exception 'La Test Room è riservata allo staff'; end if;\n  select * into a from public.characters where user_id=auth.uid() limit 1;\n  if a.id is null then raise exception 'nessun personaggio associato'; end if;\n  if exists(select 1 from public.combat_v2_actors x join public.combat_v2_sessions s on s.id=x.session_id\n    left join public.characters tc on tc.id=x.character_id\n    where s.state='in_corso' and s.closed_at is null and x.state<>'ritirato'\n      and(x.character_id=a.id or (p_target_user is not null and tc.user_id=p_target_user))) then\n    raise exception 'Durante uno scontro usa il Palmo Curativo dal pannello Combat.';\n  end if;\n  if not v_staff and not (coalesce(a.corporation,'') ~* 'medic') then\n    raise exception 'Solo un ninja medico (corporazione Medico) può curare con il Palmo Curativo.';\n  end if;\n","occurrences":1}]},{"signature":"combat_consumer_private.narrative_declaration_supported(uuid)","before_sha256":"533659e65d69a083e0fbd298b7fda56604065acb7319fab83307c760ce8110a7","after_sha256":"70689a25d0c08f7915d7405f88e733b334e19c689b0e094f8ef40b02e5d39843","after_source_md5":"b2d2c4047c4f63cb104effede756b4b8","hunks":[{"before":"BEGIN\n SELECT * INTO d FROM public.combat_v2_declarations WHERE id=p_declaration;\n IF d.id IS NULL THEN RETURN false; END IF;\n IF d.kind='attacco' AND EXISTS(SELECT 1 FROM clan_sabaku_private.flow_sources WHERE declaration_id=d.id AND round_id=d.round_id AND actor_id=d.actor_id) THEN\n   flow:=combat_consumer_private.narrative_flow_round_v1(d.round_id);\n   RETURN jsonb_array_length(flow#>'{flussi_server,events}')=1;\n","after":"BEGIN\n SELECT * INTO d FROM public.combat_v2_declarations WHERE id=p_declaration;\n IF d.id IS NULL THEN RETURN false; END IF;\n IF d.sanitized_intent#>>'{server_ability,cure_contract}'='palmo-curativo/1' THEN\n   RETURN combat_panel_private.cure_narrative_facts_v1(d.id) IS NOT NULL;\n END IF;\n IF EXISTS(SELECT 1 FROM combat_v2_genjutsu_internal.sources WHERE declaration_id=d.id) OR EXISTS(SELECT 1 FROM combat_v2_genjutsu_internal.release_plans WHERE declaration_id=d.id) THEN RETURN combat_v2_genjutsu_internal.narrative_supported(d.id);END IF;\n IF combat_v2_genjutsu_internal.narrative_supported(d.id) THEN RETURN true;END IF;\n IF d.kind='attacco' AND EXISTS(SELECT 1 FROM clan_sabaku_private.flow_sources WHERE declaration_id=d.id AND round_id=d.round_id AND actor_id=d.actor_id) THEN\n   flow:=combat_consumer_private.narrative_flow_round_v1(d.round_id);\n   RETURN jsonb_array_length(flow#>'{flussi_server,events}')=1;\n","occurrences":1}]},{"signature":"combat_panel_private.narrative_declaration_facts(uuid)","before_sha256":"e581cf8e03dbe16dbe6fe1eabf8ab4c69826b3d789b8535be04d33fb3a0d64db","after_sha256":"8574c88360502e4a6e84541cb0da05af25fb5a1b5b907577de0840d303675bb1","after_source_md5":"f4639eff179e6fdf1f998c0656ada09d","hunks":[{"before":" t public.combat_v2_attack_targets%ROWTYPE; facts jsonb; targets jsonb:='[]'::jsonb;\nBEGIN\n SELECT * INTO STRICT d FROM public.combat_v2_declarations WHERE id=p_declaration;\n IF d.state<>'risolta' AND NOT (d.state='superflua' AND (combat_v2_elemental_internal.suiton_narrative_supported(d.id) OR combat_v2_elemental_internal.other_narrative_supported(d.id))) THEN\n   RAISE EXCEPTION 'panel_narrative_declaration_unresolved' USING ERRCODE='55000'; END IF;\n facts:=jsonb_build_object('schema_version','combat-narrative-facts/1','kind',d.kind,\n   'result',CASE WHEN d.state='superflua' THEN jsonb_build_object('attack_result','not_executed') ELSE combat_panel_private.narrative_outcome_facts(d.outcome) END);\n SELECT * INTO f FROM combat_panel_private.multiplication_formations WHERE declaration_id=d.id;\n IF FOUND THEN\n   -- Soltanto il modo dichiarato, immutabile; mai stato attuale o figura originale.\n","after":" t public.combat_v2_attack_targets%ROWTYPE; facts jsonb; targets jsonb:='[]'::jsonb;\nBEGIN\n SELECT * INTO STRICT d FROM public.combat_v2_declarations WHERE id=p_declaration;\n IF d.state<>'risolta' AND NOT (d.state='superflua' AND (combat_v2_elemental_internal.suiton_narrative_supported(d.id) OR combat_v2_elemental_internal.other_narrative_supported(d.id) OR combat_v2_genjutsu_internal.narrative_supported(d.id))) THEN\n   RAISE EXCEPTION 'panel_narrative_declaration_unresolved' USING ERRCODE='55000'; END IF;\n facts:=jsonb_build_object('schema_version','combat-narrative-facts/1','kind',d.kind,\n   'result',CASE WHEN d.state='superflua' THEN jsonb_build_object('attack_result','not_executed') ELSE combat_panel_private.narrative_outcome_facts(d.outcome) END);\n IF d.sanitized_intent#>>'{server_ability,cure_contract}'='palmo-curativo/1' THEN\n   IF combat_panel_private.cure_narrative_facts_v1(d.id) IS NULL THEN\n     RAISE EXCEPTION 'cure_narrative_source_invalid' USING ERRCODE='55000';END IF;\n   facts:=facts||combat_panel_private.cure_narrative_facts_v1(d.id);\n END IF;\n SELECT * INTO f FROM combat_panel_private.multiplication_formations WHERE declaration_id=d.id;\n IF FOUND THEN\n   -- Soltanto il modo dichiarato, immutabile; mai stato attuale o figura originale.\n","occurrences":1},{"before":"    FROM combat_v2_elemental_internal.suiton_sources s WHERE s.declaration_id=d.id));\n END IF;\n IF combat_v2_elemental_internal.other_narrative_supported(d.id) THEN facts:=facts||combat_v2_elemental_internal.other_narrative_projection(d.id);END IF;\n RETURN combat_panel_private.multiplication_diversivo_narrative(d.id)||clan_hyuga_private.rotation_narrative_facts(d.id)||clan_uchiha_private.fireball_narrative(d.id)||clan_hyuga_private.sedici_narrative_facts(d.id)||facts||combat_panel_private.narrative_clone_facts(d.id)||clan_innata_private.illusion_narrative_facts(d.id)||clan_sabaku_private.armor_narrative_declaration(d.id)||combat_v2_elemental_internal.scudo_narrative(d.id);\nEND $function$\n","after":"    FROM combat_v2_elemental_internal.suiton_sources s WHERE s.declaration_id=d.id));\n END IF;\n IF combat_v2_elemental_internal.other_narrative_supported(d.id) THEN facts:=facts||combat_v2_elemental_internal.other_narrative_projection(d.id);END IF;\n  facts:=facts||combat_v2_genjutsu_internal.narrative_facts(d.id);\n RETURN combat_panel_private.multiplication_diversivo_narrative(d.id)||clan_hyuga_private.rotation_narrative_facts(d.id)||clan_uchiha_private.fireball_narrative(d.id)||clan_hyuga_private.sedici_narrative_facts(d.id)||facts||combat_panel_private.narrative_clone_facts(d.id)||clan_innata_private.illusion_narrative_facts(d.id)||clan_sabaku_private.armor_narrative_declaration(d.id)||combat_v2_elemental_internal.scudo_narrative(d.id);\nEND $function$\n","occurrences":1}]},{"signature":"combat_consumer_private.narrative_context(uuid)","before_sha256":"4afdd7ba45910dc98b4d41ae5aa54153caabea15f2ae81c63412eefd4c74660e","after_sha256":"23bed326056c73dbde6d5a46e3d3b962384493cfab0283a35f1649292bd78cbf","after_source_md5":"bb4d81831292676d2e50e16d14f3192c","hunks":[{"before":"  link combat_consumer_private.declaration_messages%rowtype; reports jsonb:='{}';\n  distance numeric; outcome text; prior text; location_name text; movement numeric:=0;\nbegin\n  IF EXISTS(SELECT 1 FROM public.combat_v2_declarations d WHERE d.round_id=p_round\n    AND d.sanitized_intent#>>'{server_ability,nara_launch,schema_version}'='nara-possession/1'\n    AND combat_panel_private.nara_ordinary_narrative_fact_v1(d.id) IS NOT NULL) THEN\n","after":"  link combat_consumer_private.declaration_messages%rowtype; reports jsonb:='{}';\n  distance numeric; outcome text; prior text; location_name text; movement numeric:=0;\nbegin\n  IF EXISTS(SELECT 1 FROM combat_panel_private.cure_ledger_v1 l WHERE l.round_id=p_round\n    AND combat_panel_private.cure_narrative_facts_v1(l.declaration_id) IS NOT NULL) THEN\n    RETURN combat_panel_private.narrative_ordinary_context(p_round);\n  END IF;\n  IF EXISTS(SELECT 1 FROM public.combat_v2_declarations z WHERE z.round_id=p_round AND combat_v2_genjutsu_internal.narrative_supported(z.id)) THEN RETURN combat_panel_private.narrative_ordinary_context(p_round);END IF;\n  IF EXISTS(SELECT 1 FROM public.combat_v2_declarations d WHERE d.round_id=p_round\n    AND d.sanitized_intent#>>'{server_ability,nara_launch,schema_version}'='nara-possession/1'\n    AND combat_panel_private.nara_ordinary_narrative_fact_v1(d.id) IS NOT NULL) THEN\n","occurrences":1}]},{"signature":"combat_panel_private.narrative_ordinary_context(uuid)","before_sha256":"40dadbd106f83d19a48e33f5ea940a6ee24062c97436292897b06b1a4f6ceeeb","after_sha256":"bd9ba81d6af8995121dcdd651789bf08e87ffd87157ec525a8e789f615e9411e","after_source_md5":"37d04042d9ee9cfec4ac237c7d9a5f37","hunks":[{"before":"     'targets',jsonb_build_array(jsonb_build_object('ordinal',1,'result',flow#>'{flussi_server,events,0,targets,0,result}')))\n     ||combat_panel_private.narrative_clone_facts(d.id);\n ELSE facts:=combat_panel_private.narrative_declaration_facts(d.id); END IF;\n IF d.kind='utilita' AND d.outcome#>>'{aburame_escape,version}'='aburame-escape/1' THEN\n   facts:=facts||jsonb_build_object('result',jsonb_build_object('escape',jsonb_build_object(\n     'success',d.outcome#>'{aburame_escape,success}','source','aburame')));\n","after":"     'targets',jsonb_build_array(jsonb_build_object('ordinal',1,'result',flow#>'{flussi_server,events,0,targets,0,result}')))\n     ||combat_panel_private.narrative_clone_facts(d.id);\n ELSE facts:=combat_panel_private.narrative_declaration_facts(d.id); END IF;\n -- Flow has its own facts branch: append the same immutable lifecycle projection there too.\n facts:=facts||combat_v2_genjutsu_internal.narrative_facts(d.id);\n IF d.kind='utilita' AND d.outcome#>>'{aburame_escape,version}'='aburame-escape/1' THEN\n   facts:=facts||jsonb_build_object('result',jsonb_build_object('escape',jsonb_build_object(\n     'success',d.outcome#>'{aburame_escape,success}','source','aburame')));\n","occurrences":1},{"before":"   WHERE m.session_id=c.session_id AND m.actor_id=d.actor_id;\n SELECT ch.* INTO STRICT target FROM public.characters ch JOIN combat_consumer_private.members m ON m.character_id=ch.id\n   WHERE m.session_id=c.session_id AND m.actor_id<>d.actor_id;\n IF nullif(btrim(source.name),'') IS NULL OR nullif(btrim(target.name),'') IS NULL THEN\n   RAISE EXCEPTION 'ordinary_narrative_projection_missing'; END IF;\n nara_fact:=combat_panel_private.nara_ordinary_narrative_fact_v1(d.id);\n","after":"   WHERE m.session_id=c.session_id AND m.actor_id=d.actor_id;\n SELECT ch.* INTO STRICT target FROM public.characters ch JOIN combat_consumer_private.members m ON m.character_id=ch.id\n   WHERE m.session_id=c.session_id AND m.actor_id<>d.actor_id;\n  IF d.outcome?'mental_release' THEN\n  SELECT ch.* INTO STRICT target FROM public.characters ch JOIN public.combat_v2_actors aa ON aa.character_id=ch.id WHERE aa.id=d.target_actor_id;\n END IF;\n IF nullif(btrim(source.name),'') IS NULL OR nullif(btrim(target.name),'') IS NULL THEN\n   RAISE EXCEPTION 'ordinary_narrative_projection_missing'; END IF;\n nara_fact:=combat_panel_private.nara_ordinary_narrative_fact_v1(d.id);\n","occurrences":1},{"before":"   AND e.event_kind='movement_settled' AND (e.after_state->>'d_eff_m')::numeric>0\n   AND (e.root_id=d.request_key OR EXISTS(SELECT 1 FROM combat_consumer_private.offers o WHERE o.id=e.root_id AND o.exchange_id=p_round)));\n technique:=CASE\n   WHEN d.sanitized_intent->'target_fili'='true'::jsonb THEN\n     (d.sanitized_intent#>>'{server_ability,name}')||' contro i Fili di Chakra. '||\n     CASE WHEN d.outcome->'fili_recisi'='true'::jsonb THEN 'I Fili vengono recisi.'\n          ELSE 'I Fili restano collegati.' END||' La marionetta non è colpita.'\n   WHEN facts ? 'elemental_technique' THEN facts#>>'{elemental_technique,name}' WHEN facts ? 'suiton_technique' THEN facts#>>'{suiton_technique,name}' WHEN flow ? 'flussi_server' THEN 'Flusso di Sabbia' WHEN facts ? 'projectile_fireball' THEN facts#>>'{projectile_fireball,name}' WHEN facts ? 'sedici_chiusure' THEN\n    (SELECT name FROM public.clan_techniques WHERE id='031d5ecc-86ee-4d21-85f1-6b76fc57cef9'::uuid)\n   WHEN clan_akimichi_private.narrative_partial_valid(d.id) THEN 'Espansione Parziale'\n   WHEN nara_fact IS NOT NULL THEN 'Possesso dell''Ombra'\n","after":"   AND e.event_kind='movement_settled' AND (e.after_state->>'d_eff_m')::numeric>0\n   AND (e.root_id=d.request_key OR EXISTS(SELECT 1 FROM combat_consumer_private.offers o WHERE o.id=e.root_id AND o.exchange_id=p_round)));\n technique:=CASE\n   WHEN facts#>>'{result,healing,schema_version}'='palmo-curativo-narrative/1' THEN 'Palmo Curativo'\n   WHEN d.sanitized_intent->'target_fili'='true'::jsonb THEN\n     (d.sanitized_intent#>>'{server_ability,name}')||' contro i Fili di Chakra. '||\n     CASE WHEN d.outcome->'fili_recisi'='true'::jsonb THEN 'I Fili vengono recisi.'\n          ELSE 'I Fili restano collegati.' END||' La marionetta non è colpita.'\n       WHEN facts ? 'genjutsu_server' THEN 'Paralisi illusoria'\n    WHEN facts#>'{result,mental_release}' IS NOT NULL THEN CASE WHEN facts#>>'{result,mental_release,mode}'='kai' THEN 'Dispersione' ELSE 'Liberazione dalla paralisi' END\n    WHEN facts ? 'elemental_technique' THEN facts#>>'{elemental_technique,name}' WHEN facts ? 'suiton_technique' THEN facts#>>'{suiton_technique,name}' WHEN flow ? 'flussi_server' THEN 'Flusso di Sabbia' WHEN facts ? 'projectile_fireball' THEN facts#>>'{projectile_fireball,name}' WHEN facts ? 'sedici_chiusure' THEN\n    (SELECT name FROM public.clan_techniques WHERE id='031d5ecc-86ee-4d21-85f1-6b76fc57cef9'::uuid)\n   WHEN clan_akimichi_private.narrative_partial_valid(d.id) THEN 'Espansione Parziale'\n   WHEN nara_fact IS NOT NULL THEN 'Possesso dell''Ombra'\n","occurrences":1}]},{"signature":"combat_v2_elemental_internal.other_consumer_options(jsonb)","before_sha256":"589ac24f464b2823972ddeda122bbd3a1a13f513324ce69d2824a117162fb6a5","after_sha256":"7157e625a868198203c80ffc341ceba2ab4486092749e82e1710765da9f95df2","after_source_md5":"8423c49ce8a83f2b19361b82a53fa9f4","hunks":[{"before":"   offers:=offers||jsonb_build_array(offer);\n  END LOOP;\n END LOOP;\n RETURN combat_v2_taijutsu_internal.consumer_options(jsonb_set(p,'{offers}',offers));\nEND $function$\n","after":"   offers:=offers||jsonb_build_array(offer);\n  END LOOP;\n END LOOP;\n  RETURN combat_v2_genjutsu_internal.consumer_options(combat_v2_taijutsu_internal.consumer_options(jsonb_set(p,'{offers}',offers)));\nEND $function$\n","occurrences":1}]},{"signature":"combat_v2_elemental_internal.other_master_options(uuid,bigint)","before_sha256":"3b38641819eb57a2962b19d7228c459d7dda352877cfda941ec96c1be4868759","after_sha256":"e16f4de72e378f9d74f69c02dadfa8381dd4a87a0f63a9f4c80afd7abc0064c5","after_source_md5":"0c79a6a78b76b9e9ef8028d75e514af7","hunks":[{"before":"  PERFORM combat_panel_private.add_choice(gid,'Non spingere',jsonb_build_object('other_push_requested',false));\n  PERFORM combat_panel_private.add_choice(gid,'Spingi fino a 3 m',jsonb_build_object('other_push_requested',true));\n END LOOP;\n PERFORM combat_v2_taijutsu_internal.master_options(c.id,c.context_version);\nEND $function$\n","after":"  PERFORM combat_panel_private.add_choice(gid,'Non spingere',jsonb_build_object('other_push_requested',false));\n  PERFORM combat_panel_private.add_choice(gid,'Spingi fino a 3 m',jsonb_build_object('other_push_requested',true));\n END LOOP;\n  PERFORM combat_v2_taijutsu_internal.master_options(c.id,c.context_version);\n PERFORM combat_v2_genjutsu_internal.master_options(c.id,c.context_version);\nEND $function$\n","occurrences":1}]},{"signature":"combat_v2_elemental_internal.other_control_target(text,uuid,uuid)","before_sha256":"b478ed855af2e8fe904cc7eddd4c8c5c21a956eb4100b63fd83d0c05ac750b8f","after_sha256":"eb9ac30003f21bd3891f6b0da2877a96934da2e22754d379a3ffc246b2b65651","after_source_md5":"b1af00f3eab38ed9e74836c5441616d7","hunks":[{"before":"  IF payload IS DISTINCT FROM jsonb_build_object('adapter','master_v2','dispatch','other_control','other_operation','staff_profile','technique_id',tid)\n   THEN RAISE EXCEPTION 'other_control_payload_invalid';END IF;\n ELSE RAISE EXCEPTION 'other_control_adapter_invalid';END IF;\n IF tid IN ('f1440a58-ee95-53dc-8ed5-a53543d970ce'::uuid,'f0fdbc8e-5cf3-5c9b-af2a-e52869fa8dfc'::uuid,'65719592-7de9-5aa1-8d59-e8da2338d45b'::uuid,'96927a19-9908-59da-9f17-2611e031bd8d'::uuid,'9ac77d79-9894-5388-9753-70538ac5eaa3'::uuid) THEN\n  IF NOT combat_v2_taijutsu_internal.preset_ready(a.id,tid) THEN RAISE EXCEPTION 'other_control_not_available';END IF;\n ELSIF NOT combat_v2_elemental_internal.other_preset_ready(a.id,tid) THEN RAISE EXCEPTION 'other_control_not_available';END IF;\n RETURN tid;\n","after":"  IF payload IS DISTINCT FROM jsonb_build_object('adapter','master_v2','dispatch','other_control','other_operation','staff_profile','technique_id',tid)\n   THEN RAISE EXCEPTION 'other_control_payload_invalid';END IF;\n ELSE RAISE EXCEPTION 'other_control_adapter_invalid';END IF;\n  IF tid='31d5d554-44d1-4042-9920-3ddd3bedff7e'::uuid THEN\n  IF NOT combat_v2_genjutsu_internal.preset_ready(a.id) THEN RAISE EXCEPTION 'paralisi_control_not_available';END IF;\n ELSIF tid IN ('f1440a58-ee95-53dc-8ed5-a53543d970ce'::uuid,'f0fdbc8e-5cf3-5c9b-af2a-e52869fa8dfc'::uuid,'65719592-7de9-5aa1-8d59-e8da2338d45b'::uuid,'96927a19-9908-59da-9f17-2611e031bd8d'::uuid,'9ac77d79-9894-5388-9753-70538ac5eaa3'::uuid) THEN\n  IF NOT combat_v2_taijutsu_internal.preset_ready(a.id,tid) THEN RAISE EXCEPTION 'other_control_not_available';END IF;\n ELSIF NOT combat_v2_elemental_internal.other_preset_ready(a.id,tid) THEN RAISE EXCEPTION 'other_control_not_available';END IF;\n RETURN tid;\n","occurrences":1}]},{"signature":"combat_v2_elemental_internal.other_control_apply(text,uuid,uuid,uuid)","before_sha256":"56e837bb6590c05a04f37be8a842c1a42cc514576feabd71aaad0fd6951123c0","after_sha256":"a920bc4b7b3c5b2fd19b0ace6ff07eea9bf9871790e2a055f3dbeb28fa48c9af","after_source_md5":"4cf97ca72ff52f1bd33445ba54c8dd16","hunks":[{"before":"DECLARE tid uuid;\nBEGIN\n tid:=combat_v2_elemental_internal.other_control_target(p_adapter,p_offer,p_actor);\n IF tid IN ('f1440a58-ee95-53dc-8ed5-a53543d970ce'::uuid,'f0fdbc8e-5cf3-5c9b-af2a-e52869fa8dfc'::uuid,'65719592-7de9-5aa1-8d59-e8da2338d45b'::uuid,'96927a19-9908-59da-9f17-2611e031bd8d'::uuid,'9ac77d79-9894-5388-9753-70538ac5eaa3'::uuid) THEN RETURN combat_v2_taijutsu_internal.staff_bind(p_actor,tid,p_request);END IF;\n RETURN combat_v2_elemental_internal.other_staff_bind(p_actor,tid,p_request);\nEND $function$\n","after":"DECLARE tid uuid;\nBEGIN\n tid:=combat_v2_elemental_internal.other_control_target(p_adapter,p_offer,p_actor);\n  IF tid='31d5d554-44d1-4042-9920-3ddd3bedff7e'::uuid THEN RETURN combat_v2_genjutsu_internal.staff_bind(p_actor,p_request);END IF;\n IF tid IN ('f1440a58-ee95-53dc-8ed5-a53543d970ce'::uuid,'f0fdbc8e-5cf3-5c9b-af2a-e52869fa8dfc'::uuid,'65719592-7de9-5aa1-8d59-e8da2338d45b'::uuid,'96927a19-9908-59da-9f17-2611e031bd8d'::uuid,'9ac77d79-9894-5388-9753-70538ac5eaa3'::uuid) THEN RETURN combat_v2_taijutsu_internal.staff_bind(p_actor,tid,p_request);END IF;\n RETURN combat_v2_elemental_internal.other_staff_bind(p_actor,tid,p_request);\nEND $function$\n","occurrences":1}]},{"signature":"combat_v2_elemental_internal.other_profile(uuid,uuid)","before_sha256":"7fc95dc887fb52cb447d6ce79132a2cb031dd408f692ddfe067bace16627d847","after_sha256":"d5580f9d48d8fda49bfc205815644bc4eae1fc43f27725f006cb2614a5ce9c0c","after_source_md5":"dd1e62e9052469fae4c98fed245c730a","hunks":[{"before":"AS $function$\nDECLARE a public.combat_v2_actors%ROWTYPE;p jsonb;public_admitted boolean:=false;\nBEGIN\n IF p_technique IN ('f1440a58-ee95-53dc-8ed5-a53543d970ce'::uuid,'f0fdbc8e-5cf3-5c9b-af2a-e52869fa8dfc'::uuid,'65719592-7de9-5aa1-8d59-e8da2338d45b'::uuid,'96927a19-9908-59da-9f17-2611e031bd8d'::uuid,'9ac77d79-9894-5388-9753-70538ac5eaa3'::uuid) THEN RETURN combat_v2_taijutsu_internal.profile(p_actor,p_technique);END IF;\n IF NOT EXISTS(SELECT 1 FROM combat_v2_elemental_internal.other_gates WHERE technique_id=p_technique AND enabled) THEN RETURN NULL;END IF;\n SELECT * INTO a FROM public.combat_v2_actors WHERE id=p_actor AND actor_kind IN ('pg','png') AND companion_id IS NULL AND state='attivo';\n","after":"AS $function$\nDECLARE a public.combat_v2_actors%ROWTYPE;p jsonb;public_admitted boolean:=false;\nBEGIN\n  IF p_technique='31d5d554-44d1-4042-9920-3ddd3bedff7e'::uuid THEN RETURN combat_v2_genjutsu_internal.actor_meta(p_actor);END IF;\n IF p_technique IN ('f1440a58-ee95-53dc-8ed5-a53543d970ce'::uuid,'f0fdbc8e-5cf3-5c9b-af2a-e52869fa8dfc'::uuid,'65719592-7de9-5aa1-8d59-e8da2338d45b'::uuid,'96927a19-9908-59da-9f17-2611e031bd8d'::uuid,'9ac77d79-9894-5388-9753-70538ac5eaa3'::uuid) THEN RETURN combat_v2_taijutsu_internal.profile(p_actor,p_technique);END IF;\n IF NOT EXISTS(SELECT 1 FROM combat_v2_elemental_internal.other_gates WHERE technique_id=p_technique AND enabled) THEN RETURN NULL;END IF;\n SELECT * INTO a FROM public.combat_v2_actors WHERE id=p_actor AND actor_kind IN ('pg','png') AND companion_id IS NULL AND state='attivo';\n","occurrences":1}]},{"signature":"combat_v2_elemental_internal.other_prepare_native(uuid,uuid,uuid,jsonb,boolean,jsonb)","before_sha256":"ecf752816b63ed17200df9207ff5825658b51dc7488e3c9f2aa16c527d376914","after_sha256":"07e2d6d2d1ac438df81658d686c3f7e1680ffcbeae0cb8054a2dc3f7771c2efd","after_source_md5":"6e54b476b36ca716cf8c14f33ef9667e","hunks":[{"before":" SELECT * INTO STRICT a FROM public.combat_v2_actors WHERE id=a.id AND exam_regia_private.actor_principal(id,controller_user)=exam_regia_private.current_principal() FOR UPDATE;\n IF public.combat_v2_sanitize_intent(p_intent,false) IS DISTINCT FROM p_intent OR p_intent->>'kind' IS DISTINCT FROM 'attacco'\n  OR p_intent->>'ability_source' IS DISTINCT FROM 'clan' THEN RAISE EXCEPTION 'other_prepare_intent_invalid';END IF;\n tid:=(p_intent->>'ability_id')::uuid;target:=(p_intent->>'target_actor')::uuid;\n p:=combat_v2_elemental_internal.other_profile(a.id,tid);\n IF p IS NULL OR target IS NULL OR (p_push AND tid<>'d5605069-b381-41ad-8e6a-9c24a314c58f'::uuid)\n  OR (p_intent?'target_actor_ids' AND p_intent->'target_actor_ids' IS DISTINCT FROM jsonb_build_array(target)) THEN RAISE EXCEPTION 'other_profile_or_target_invalid';END IF;\n","after":" SELECT * INTO STRICT a FROM public.combat_v2_actors WHERE id=a.id AND exam_regia_private.actor_principal(id,controller_user)=exam_regia_private.current_principal() FOR UPDATE;\n IF public.combat_v2_sanitize_intent(p_intent,false) IS DISTINCT FROM p_intent OR p_intent->>'kind' IS DISTINCT FROM 'attacco'\n  OR p_intent->>'ability_source' IS DISTINCT FROM 'clan' THEN RAISE EXCEPTION 'other_prepare_intent_invalid';END IF;\n  tid:=(p_intent->>'ability_id')::uuid;target:=(p_intent->>'target_actor')::uuid;\n IF tid='31d5d554-44d1-4042-9920-3ddd3bedff7e'::uuid THEN\n  IF p_push THEN RAISE EXCEPTION 'paralisi_push_invalid';END IF;\n  RETURN combat_v2_genjutsu_internal.prepare(p_round,p_actor,p_request,p_intent);END IF;\n p:=combat_v2_elemental_internal.other_profile(a.id,tid);\n IF p IS NULL OR target IS NULL OR (p_push AND tid<>'d5605069-b381-41ad-8e6a-9c24a314c58f'::uuid)\n  OR (p_intent?'target_actor_ids' AND p_intent->'target_actor_ids' IS DISTINCT FROM jsonb_build_array(target)) THEN RAISE EXCEPTION 'other_profile_or_target_invalid';END IF;\n","occurrences":1}]},{"signature":"public.combat_v2_defense_declare(uuid,uuid,uuid,jsonb,text,uuid)","before_sha256":"222c8d7f8b37a07079726dfb5ea98396568cb43667e40337b44f713f3fa9005a","after_sha256":"f92e4d4bf5e6e22d79b64204471083ed07be97404e2961f5a57ab2956a098265","after_source_md5":"7e947fd7937ec49f19101a58d95432d8","hunks":[{"before":"  IF v_a.actor_kind='png' AND EXISTS(SELECT 1 FROM user_testroom_common_private.contexts WHERE id=v_a.session_id) THEN\n    PERFORM user_testroom_common_private.assert_png_defense(p_round,p_attack_declaration,p_actor,p_intent,p_request_key);\n  ELSE if not v_service and exam_regia_private.actor_principal(v_a.id,v_a.controller_user)<>v_uid then perform public.combat_v2_fail('attore_non_controllato','Non controlli questo attore.',403,p_request_key,'{}'); end if; END IF;\n  v_i := public.combat_v2_sanitize_intent(p_intent,true); v_i:=clan_inuzuka_private.defense_guard(p_actor,v_i);\n  perform clan_marionettisti_private.assert_jutsu_source(p_actor,v_i->>'ability_source',(v_i->>'ability_id')::uuid);\n  v_payload:=jsonb_build_object('attack',p_attack_declaration,'actor',p_actor,'intent',v_i,'text',coalesce(p_text,''));\n  v_fp:=public.combat_v2_sha256(jsonb_build_object('operation','combat_v2_defense_declare','payload',v_payload,'caller',exam_regia_private.current_principal(),'scope',p_round));\n","after":"  IF v_a.actor_kind='png' AND EXISTS(SELECT 1 FROM user_testroom_common_private.contexts WHERE id=v_a.session_id) THEN\n    PERFORM user_testroom_common_private.assert_png_defense(p_round,p_attack_declaration,p_actor,p_intent,p_request_key);\n  ELSE if not v_service and exam_regia_private.actor_principal(v_a.id,v_a.controller_user)<>v_uid then perform public.combat_v2_fail('attore_non_controllato','Non controlli questo attore.',403,p_request_key,'{}'); end if; END IF;\n    v_i := public.combat_v2_sanitize_intent(p_intent,true); v_i:=clan_inuzuka_private.defense_guard(p_actor,v_i);\n  IF NOT combat_v2_genjutsu_internal.defense_intent_allowed(p_attack_declaration,v_i) THEN RAISE EXCEPTION 'paralisi_defense_not_offered';END IF;\n  perform clan_marionettisti_private.assert_jutsu_source(p_actor,v_i->>'ability_source',(v_i->>'ability_id')::uuid);\n  v_payload:=jsonb_build_object('attack',p_attack_declaration,'actor',p_actor,'intent',v_i,'text',coalesce(p_text,''));\n  v_fp:=public.combat_v2_sha256(jsonb_build_object('operation','combat_v2_defense_declare','payload',v_payload,'caller',exam_regia_private.current_principal(),'scope',p_round));\n","occurrences":1}]},{"signature":"combat_v2_multitarget_internal.resolve_parent(uuid,uuid,uuid,boolean)","before_sha256":"fc41488db82e1c7a81052cc673d00d7ea3597dee0ee846ceb6e9aa7b619f7d93","after_sha256":"8cdb1857a2418dcd3e06006688642c2e7da90782593a52ddf0f0e093e62a9de2","after_source_md5":"e9c7eb293c1791e36ba5fe70204af224","hunks":[{"before":"       'danno_applicato',0,'striscio',false,'cap_attivo',false);\n   END IF;\n   calc:=calc||jsonb_build_object('mod_assalto',multiplication_effect->'assault_bonus','mod_mira',0);\n   rng:=jsonb_build_object('scheme','combat-v2-child-derive/1.0','child_id',t.id,\n    'commitment',encode(extensions.digest(entropy,'sha256'),'hex'),\n    'shared_offensive_roll',fireball_profile IS NOT NULL,'dice_attack',jsonb_build_array(a1,a2),'dice_defense',jsonb_build_array(d1,d2));\n","after":"       'danno_applicato',0,'striscio',false,'cap_attivo',false);\n   END IF;\n   calc:=calc||jsonb_build_object('mod_assalto',multiplication_effect->'assault_bonus','mod_mira',0);\n       calc:=combat_v2_genjutsu_internal.comparison(d.id,def.id,calc);\n   rng:=jsonb_build_object('scheme','combat-v2-child-derive/1.0','child_id',t.id,\n    'commitment',encode(extensions.digest(entropy,'sha256'),'hex'),\n    'shared_offensive_roll',fireball_profile IS NOT NULL,'dice_attack',jsonb_build_array(a1,a2),'dice_defense',jsonb_build_array(d1,d2));\n","occurrences":1},{"before":"     damage:=0;\n     calc:=calc||jsonb_build_object('danno_grezzo',0,'danno_applicato',0,'striscio',false,'cap_attivo',false);\n   END IF;\n   elemental_cap:=combat_effects_private.capture_source_cap(d.id,damage);\n   IF elemental_cap<>'{}'::jsonb THEN\n     calc:=calc||jsonb_build_object('common_effects',\n       coalesce(calc->'common_effects','{}'::jsonb)||elemental_cap);\n   END IF;\n   calc:=calc||jsonb_build_object('sabaku_armor',clan_sabaku_private.armor_absorb(t.id,damage));\n   damage:=(calc#>>'{sabaku_armor,damage_after}')::integer;\n   IF NOT (calc->'sabaku_armor' ? 'version') THEN calc:=calc-'sabaku_armor'; END IF;\n   hp:=greatest(0,coalesce((tar.mechanics_snapshot->>'vita')::int,0)-damage);\n   update public.combat_v2_actors set mechanics_snapshot=jsonb_set(mechanics_snapshot,'{vita}',to_jsonb(hp),false),state=case when hp=0 then'fuori'else state end where id=tar.id;\n   if p_values and tar.actor_kind='pg'and damage>0 then perform set_config('app.allow_vita_delta','1',true);update public.characters set vita=hp where id=tar.character_id;perform set_config('app.allow_vita_delta','0',true);end if;\n","after":"     damage:=0;\n     calc:=calc||jsonb_build_object('danno_grezzo',0,'danno_applicato',0,'striscio',false,'cap_attivo',false);\n   END IF;\n       IF calc#>>'{paralisi,contract}'='paralisi-movement/1' THEN damage:=0;END IF;\n    elemental_cap:=combat_effects_private.capture_source_cap(d.id,damage);\n   IF elemental_cap<>'{}'::jsonb THEN\n     calc:=calc||jsonb_build_object('common_effects',\n       coalesce(calc->'common_effects','{}'::jsonb)||elemental_cap);\n   END IF;\n    IF calc#>>'{paralisi,contract}' IS DISTINCT FROM 'paralisi-movement/1' THEN\n    calc:=calc||jsonb_build_object('sabaku_armor',clan_sabaku_private.armor_absorb(t.id,damage));\n    damage:=(calc#>>'{sabaku_armor,damage_after}')::integer;\n    IF NOT (calc->'sabaku_armor' ? 'version') THEN calc:=calc-'sabaku_armor'; END IF;\n    END IF;\n   hp:=greatest(0,coalesce((tar.mechanics_snapshot->>'vita')::int,0)-damage);\n   update public.combat_v2_actors set mechanics_snapshot=jsonb_set(mechanics_snapshot,'{vita}',to_jsonb(hp),false),state=case when hp=0 then'fuori'else state end where id=tar.id;\n   if p_values and tar.actor_kind='pg'and damage>0 then perform set_config('app.allow_vita_delta','1',true);update public.characters set vita=hp where id=tar.character_id;perform set_config('app.allow_vita_delta','0',true);end if;\n","occurrences":1},{"before":"      any_success:=fili_hit;\n      child_outcome:=child_outcome||jsonb_build_object('success',fili_hit,'fili_recisi',fili_hit);\n    END IF;\n    receipt:=combat_v2_multitarget_internal.sha(child_outcome);\n   update public.combat_v2_attack_targets set state='risolta',outcome=child_outcome,rng_receipt_sha256=receipt where id=t.id;\n  end if;\n","after":"      any_success:=fili_hit;\n      child_outcome:=child_outcome||jsonb_build_object('success',fili_hit,'fili_recisi',fili_hit);\n    END IF;\n        IF calc#>>'{paralisi,contract}'='paralisi-movement/1' THEN\n      child_outcome:=child_outcome||jsonb_build_object('success',combat_v2_genjutsu_internal.success(calc,final,(multiplication_effect->>'copy_intercepted')::boolean));\n      any_success:=(child_outcome->>'success')::boolean;\n    END IF;\n    child_outcome:=combat_v2_genjutsu_internal.decorate_outcome(d.id,t.id,child_outcome);\n    receipt:=combat_v2_multitarget_internal.sha(child_outcome);\n   update public.combat_v2_attack_targets set state='risolta',outcome=child_outcome,rng_receipt_sha256=receipt where id=t.id;\n  end if;\n","occurrences":1}]},{"signature":"combat_effects_private.lifecycle_open(uuid,uuid)","before_sha256":"adf5d791bd877d686ef05e652582c5a395922e3179a7acc613980a6751a664f1","after_sha256":"26c16b32c97ca05507c47861c77096d4e6f0328339af6e257bfea3f4615dbaa1","after_source_md5":"f94e3ef794064277d596354feba2cd50","hunks":[{"before":" END IF;\n PERFORM combat_panel_private.nara_release_unfunded_v1(p_session,p_actor);\n -- Nessuna apertura/gate e nessun turno nuovo: si osserva il turno già creato nativamente.\n pending_effect:=EXISTS(SELECT 1 FROM combat_effects_private.effect_applications\n  WHERE session_id=p_session AND target_actor_id=p_actor AND state='pending');\n IF NOT pending_effect AND NOT EXISTS(SELECT 1 FROM clan_akimichi_private.forms\n","after":" END IF;\n PERFORM combat_panel_private.nara_release_unfunded_v1(p_session,p_actor);\n -- Nessuna apertura/gate e nessun turno nuovo: si osserva il turno già creato nativamente.\n  PERFORM combat_v2_genjutsu_internal.open_turn(p_session,p_actor);\n pending_effect:=EXISTS(SELECT 1 FROM combat_effects_private.effect_applications\n  WHERE session_id=p_session AND target_actor_id=p_actor AND state='pending');\n IF NOT pending_effect AND NOT EXISTS(SELECT 1 FROM clan_akimichi_private.forms\n","occurrences":1}]},{"signature":"combat_effects_private.personal_turn_start(uuid,uuid,uuid,text)","before_sha256":"deb5bb05aa256aa3bb92ad6e357c5ad3e75457b5c76a98647e8e90f7cd0050c6","after_sha256":"365a9956174c02e2d64bdba1d1551b39d7eece4ccd7a7a3949b86cf39a910231","after_source_md5":"e7ec43224a4640d00c53bad72ac0132d","hunks":[{"before":" c:=combat_effects_private.personal_turn(p_session,p_actor);\n IF p_turn IS NULL OR c->>'turn_id' IS DISTINCT FROM p_turn::text OR c->>'adapter' IS DISTINCT FROM p_adapter\n  OR c->>'is_current' IS DISTINCT FROM 'true' THEN RAISE EXCEPTION 'effects_native_turn_required';END IF;\n PERFORM clan_akimichi_private.begin_personal_turn(p_actor,p_turn);\n FOR e IN SELECT * FROM combat_effects_private.effect_applications WHERE session_id=p_session AND target_actor_id=p_actor\n  AND state='pending' AND adapter=p_adapter AND excluded_turn_id IS DISTINCT FROM p_turn ORDER BY id FOR UPDATE LOOP\n  ek:='start:'||e.id::text||':'||p_adapter||':'||p_turn::text;\n","after":" c:=combat_effects_private.personal_turn(p_session,p_actor);\n IF p_turn IS NULL OR c->>'turn_id' IS DISTINCT FROM p_turn::text OR c->>'adapter' IS DISTINCT FROM p_adapter\n  OR c->>'is_current' IS DISTINCT FROM 'true' THEN RAISE EXCEPTION 'effects_native_turn_required';END IF;\n  PERFORM clan_akimichi_private.begin_personal_turn(p_actor,p_turn);\n PERFORM combat_v2_genjutsu_internal.turn_start(p_session,p_actor,p_turn,p_adapter);\n FOR e IN SELECT * FROM combat_effects_private.effect_applications WHERE session_id=p_session AND target_actor_id=p_actor\n  AND state='pending' AND adapter=p_adapter AND excluded_turn_id IS DISTINCT FROM p_turn ORDER BY id FOR UPDATE LOOP\n  ek:='start:'||e.id::text||':'||p_adapter||':'||p_turn::text;\n","occurrences":1}]},{"signature":"combat_effects_private.personal_turn_end(uuid,uuid,uuid,text)","before_sha256":"37b9de37d255d0b9a8139b88273fc74ef618f68b5adaa8044326a3ab6b84bedc","after_sha256":"0a0d05ad60a0877f2ef48100f0154ee29c10a8e9ad8c57d291855077ce860b04","after_source_md5":"125e376708eaccc758e7887a9bcef705","hunks":[{"before":" IF p_turn IS NULL OR c->>'turn_id' IS DISTINCT FROM p_turn::text OR c->>'adapter' IS DISTINCT FROM p_adapter THEN\n  RAISE EXCEPTION 'effects_current_native_turn_required';END IF;\n IF p_adapter='ordinary_v2' AND c->>'is_current' IS DISTINCT FROM 'true' THEN RAISE EXCEPTION 'effects_wrong_actor_turn';END IF;\n FOR effect_id IN SELECT id FROM combat_effects_private.effect_applications WHERE session_id=p_session AND target_actor_id=p_actor\n  AND adapter=p_adapter AND state IN ('pending','active') AND excluded_turn_id IS DISTINCT FROM p_turn ORDER BY id LOOP\n  -- Il saldo precedente può avere provocato KO e terminato gli altri effetti.\n","after":" IF p_turn IS NULL OR c->>'turn_id' IS DISTINCT FROM p_turn::text OR c->>'adapter' IS DISTINCT FROM p_adapter THEN\n  RAISE EXCEPTION 'effects_current_native_turn_required';END IF;\n IF p_adapter='ordinary_v2' AND c->>'is_current' IS DISTINCT FROM 'true' THEN RAISE EXCEPTION 'effects_wrong_actor_turn';END IF;\n  PERFORM combat_v2_genjutsu_internal.turn_end(p_session,p_actor,p_turn,p_adapter);\n FOR effect_id IN SELECT id FROM combat_effects_private.effect_applications WHERE session_id=p_session AND target_actor_id=p_actor\n  AND adapter=p_adapter AND state IN ('pending','active') AND excluded_turn_id IS DISTINCT FROM p_turn ORDER BY id LOOP\n  -- Il saldo precedente può avere provocato KO e terminato gli altri effetti.\n","occurrences":1}]},{"signature":"combat_effects_private.lifecycle_main_end(uuid)","before_sha256":"1ce706b8e5f88d9b10cc56a793a2e6a4ff05c8b0ad45fee4cf399c4677f705d3","after_sha256":"ddfcd03e86e004fdde6a53b8e2d049c06368137bc8ea14870a311b249edc5b89","after_source_md5":"a1948e8ce4fc505fc23e4e4089958507","hunks":[{"before":" receipt_key:='turn-end:'||a.session_id::text||':'||a.id::text||':master_v2:'||t.id::text;\n IF NOT EXISTS(SELECT 1 FROM combat_effects_private.effect_applications WHERE session_id=a.session_id\n  AND target_actor_id=a.id AND state IN ('pending','active'))\n  AND NOT EXISTS(SELECT 1 FROM combat_effects_private.effect_events WHERE event_key=receipt_key) THEN RETURN '[]'::jsonb;END IF;\n PERFORM 1 FROM public.combat_v2_sessions WHERE id=a.session_id FOR UPDATE;\n SELECT * INTO STRICT a FROM public.combat_v2_actors WHERE id=a.id FOR UPDATE;\n","after":" receipt_key:='turn-end:'||a.session_id::text||':'||a.id::text||':master_v2:'||t.id::text;\n IF NOT EXISTS(SELECT 1 FROM combat_effects_private.effect_applications WHERE session_id=a.session_id\n  AND target_actor_id=a.id AND state IN ('pending','active'))\n    AND NOT EXISTS(SELECT 1 FROM combat_v2_genjutsu_internal.effects WHERE session_id=a.session_id AND target_actor_id=a.id AND state IN('pending','active'))\n  AND NOT EXISTS(SELECT 1 FROM combat_effects_private.effect_events WHERE event_key=receipt_key) THEN RETURN '[]'::jsonb;END IF;\n PERFORM 1 FROM public.combat_v2_sessions WHERE id=a.session_id FOR UPDATE;\n SELECT * INTO STRICT a FROM public.combat_v2_actors WHERE id=a.id FOR UPDATE;\n","occurrences":1}]},{"signature":"combat_effects_private.lifecycle_before_report(uuid)","before_sha256":"786c24e26c8f351293032929169c5b40a05f64645a87d4ea397a675233c1e667","after_sha256":"c23f9201be999f3eee07720790c9c0408868689409cae7fe5b2e9b3badb09dd6","after_source_md5":"bc4009af6a274d51e6b96fc51f7a7a78","hunks":[{"before":" FROM public.combat_v2_actors stopped JOIN clan_akimichi_private.forms f\n  ON f.actor_id=stopped.id AND f.session_id=stopped.session_id AND f.active\n WHERE stopped.session_id=r.session_id AND stopped.state<>'attivo' ORDER BY stopped.id;\n IF NOT EXISTS(SELECT 1 FROM combat_effects_private.effect_applications WHERE session_id=r.session_id)\n  THEN RETURN result;END IF;\n PERFORM 1 FROM public.combat_v2_sessions WHERE id=r.session_id FOR UPDATE;\n SELECT * INTO STRICT r FROM public.combat_v2_rounds WHERE id=p_round FOR UPDATE;\n IF r.phase<>'risoluzione' OR EXISTS(SELECT 1 FROM public.combat_v2_round_reports WHERE round_id=r.id)\n","after":" FROM public.combat_v2_actors stopped JOIN clan_akimichi_private.forms f\n  ON f.actor_id=stopped.id AND f.session_id=stopped.session_id AND f.active\n WHERE stopped.session_id=r.session_id AND stopped.state<>'attivo' ORDER BY stopped.id;\n  IF NOT EXISTS(SELECT 1 FROM combat_effects_private.effect_applications WHERE session_id=r.session_id)\n AND NOT EXISTS(SELECT 1 FROM combat_v2_genjutsu_internal.effects WHERE session_id=r.session_id AND state IN('pending','active'))\n THEN RETURN result;END IF;\n PERFORM 1 FROM public.combat_v2_sessions WHERE id=r.session_id FOR UPDATE;\n SELECT * INTO STRICT r FROM public.combat_v2_rounds WHERE id=p_round FOR UPDATE;\n IF r.phase<>'risoluzione' OR EXISTS(SELECT 1 FROM public.combat_v2_round_reports WHERE round_id=r.id)\n","occurrences":1}]},{"signature":"combat_panel_private.immobilization_actor_lifecycle()","before_sha256":"255f02227f03bf0ab05e4a6922c69ceeb9b3746f57de1e4bf1fccbc140db13fc","after_sha256":"a1d0042f04d19c1d11f43201d5195fde49874087d225d08e078731e0bf036762","after_source_md5":"5244a1f635ad7d7336d24140d288b82a","hunks":[{"before":" SET search_path TO ''\nAS $function$\nBEGIN\n IF NEW.state<>'attivo' THEN\n   PERFORM combat_panel_private.nara_end_source_v1(NEW.session_id,NEW.id);\n   UPDATE combat_panel_private.immobilizations SET state='released',release_reason='target_inoperative',released_at=clock_timestamp()\n     WHERE target_actor_id=NEW.id AND session_id=NEW.session_id AND state='active';\n","after":" SET search_path TO ''\nAS $function$\nBEGIN\n  IF NEW.state<>'attivo' THEN\n   PERFORM combat_v2_genjutsu_internal.end_context(NEW.session_id,NEW.id);\n   PERFORM combat_panel_private.nara_end_source_v1(NEW.session_id,NEW.id);\n   UPDATE combat_panel_private.immobilizations SET state='released',release_reason='target_inoperative',released_at=clock_timestamp()\n     WHERE target_actor_id=NEW.id AND session_id=NEW.session_id AND state='active';\n","occurrences":1}]},{"signature":"combat_panel_private.immobilization_session_lifecycle()","before_sha256":"ef3bd87e5658b1c11228ed33bf2c41b3180adb98db5e3bcb15d92c4f4aca7679","after_sha256":"2154f1c2587bc5c18371857df27287465e50876b8bf801be632df88f2f823ebb","after_source_md5":"a4671931aa6e908a94af2ad2d788d933","hunks":[{"before":" SET search_path TO ''\nAS $function$\nBEGIN\n IF NEW.state IN ('risolto','chiuso','annullato') THEN\n   UPDATE combat_panel_private.immobilizations SET state='released',release_reason='combat_end',released_at=clock_timestamp()\n     WHERE session_id=NEW.id AND state='active';\n END IF;\n","after":" SET search_path TO ''\nAS $function$\nBEGIN\n  IF NEW.state IN ('risolto','chiuso','annullato') THEN\n   PERFORM combat_v2_genjutsu_internal.end_context(NEW.id);\n   UPDATE combat_panel_private.immobilizations SET state='released',release_reason='combat_end',released_at=clock_timestamp()\n     WHERE session_id=NEW.id AND state='active';\n END IF;\n","occurrences":1}]},{"signature":"combat_panel_private.commit_master_actor(jsonb)","before_sha256":"c782aa6df91954a6ad1f298bfa0bc8cf99f4cd0362d2ba5741502d63c7f13843","after_sha256":"cb4f99dbe0652ca96fb3251283deaa7aed960506324406c2f29dee0c5891548f","after_source_md5":"0c39121bcbd32a49608e4d925560ba41","hunks":[{"before":"     intent:=intent||jsonb_build_object('target_actor',targets[1],'target_actor_ids',targets,\n       'ability_source',o.source_payload->'ability_source');\n     IF o.source_payload ? 'ability_id' THEN intent:=intent||jsonb_build_object('ability_id',o.source_payload->'ability_id'); END IF;\n   ELSIF intent->>'kind'='utilita' AND o.source_payload->>'aburame_escape'='true' THEN\n     intent:=intent||jsonb_build_object('ability_source','clan','ability_id','f5e9af24-70f1-49f6-a7ca-74f59256336e');\n   ELSIF dispatch='movement' THEN\n","after":"     intent:=intent||jsonb_build_object('target_actor',targets[1],'target_actor_ids',targets,\n       'ability_source',o.source_payload->'ability_source');\n     IF o.source_payload ? 'ability_id' THEN intent:=intent||jsonb_build_object('ability_id',o.source_payload->'ability_id'); END IF;\n      ELSIF intent->>'kind'='utilita' AND o.source_payload->>'genjutsu_release_version'='paralisi-release/1' THEN\n     intent:=o.source_payload->'intent';\n   ELSIF intent->>'kind'='utilita' AND o.source_payload->>'aburame_escape'='true' THEN\n     intent:=intent||jsonb_build_object('ability_source','clan','ability_id','f5e9af24-70f1-49f6-a7ca-74f59256336e');\n   ELSIF dispatch='movement' THEN\n","occurrences":1}]},{"signature":"combat_panel_private.narrative_outcome_facts(jsonb)","before_sha256":"e340992649d7f880146368b6308bbeb169f2d5dac131123ed4a1a8fb2c0d7b97","after_sha256":"5e7aeee612c63b7abafd3d0e1c035ead6f9a76ba7af79fa7f1f37ea91f4bf58e","after_source_md5":"988cc3b61d0ebf41effda90d32e173b5","hunks":[{"before":"BEGIN\n IF jsonb_typeof(p_outcome) IS DISTINCT FROM 'object' THEN\n   RAISE EXCEPTION 'panel_narrative_outcome_invalid' USING ERRCODE='22023'; END IF;\n escape:=p_outcome->'immobilization_escape';\n IF escape IS NOT NULL THEN\n   IF escape->>'schema_version' IS DISTINCT FROM 'immobilization-escape/1'\n","after":"BEGIN\n IF jsonb_typeof(p_outcome) IS DISTINCT FROM 'object' THEN\n   RAISE EXCEPTION 'panel_narrative_outcome_invalid' USING ERRCODE='22023'; END IF;\n  IF p_outcome?'mental_release' THEN RETURN jsonb_build_object('mental_release',combat_v2_genjutsu_internal.validate_release_facts(p_outcome->'mental_release'));END IF;\n escape:=p_outcome->'immobilization_escape';\n IF escape IS NOT NULL THEN\n   IF escape->>'schema_version' IS DISTINCT FROM 'immobilization-escape/1'\n","occurrences":1}]},{"signature":"public.combat_consumer_narrative_claim_v1(uuid,text,uuid)","before_sha256":"39bb511d4ce031e21e7e23781945d227ff83801d0cd03fb9e237ed0f643b83bd","after_sha256":"59c76b57d6d92fed8e92894a0ff54d8aeadec995e213c04b7087804648b4cfeb","after_source_md5":"1b51f51abc7ee3201a994c520fbcc64c","hunks":[{"before":"  return jsonb_build_object('claim_id',claim.id,'should_call_provider',true,'state',claim.state,\n    'report_id',claim.report_id,'round_id',claim.round_id,\n    'report_sha256',claim.report_sha256,'context_sha256',claim.context_sha256,'control_version',claim.control_version,\n    'edge_revision',case when payload->>'genere'='rinuncia' then 'ordinary-rinuncia/1' when payload->>'genere'='azione_risolta' then 'ordinary-facts/1' else 'ordinary-adapter/1' end,'validator_revision',case when payload->>'genere'='rinuncia' then 'combat-rinuncia/1' when payload->>'genere'='azione_risolta' then 'combat-facts/1' else 'combat-narratore-v18-existing/1' end,\n    'provider','openai','model','gpt-6-luna','expires_at',claim.expires_at,'context',payload);\nend $function$\n","after":"  return jsonb_build_object('claim_id',claim.id,'should_call_provider',true,'state',claim.state,\n    'report_id',claim.report_id,'round_id',claim.round_id,\n    'report_sha256',claim.report_sha256,'context_sha256',claim.context_sha256,'control_version',claim.control_version,\n    'edge_revision',case when payload->>'genere'='rinuncia' then 'ordinary-rinuncia/1' when payload->>'genere'='azione_risolta' then 'ordinary-facts/1' else 'ordinary-adapter/1' end,'validator_revision',case when payload->>'genere'='rinuncia' then 'combat-rinuncia/1' when payload->>'genere'='azione_risolta' then CASE WHEN payload->'fatti' ?| ARRAY['genjutsu_server','genjutsu_events'] OR payload#>'{fatti,result}' ?| ARRAY['healing','mental_release'] THEN 'combat-facts/2' ELSE 'combat-facts/1' END else 'combat-narratore-v18-existing/1' end,\n    'provider','openai','model','gpt-6-luna','expires_at',claim.expires_at,'context',payload);\nend $function$\n","occurrences":1}]},{"signature":"combat_consumer_private.validate_narrative_result(jsonb)","before_sha256":"6f0013380298dfb1b92fd933b9d90cfc6000e3961725af4d3d7f9b28d700e420","after_sha256":"9ba51ad9979fbe88745d94981bd77df0ba2ce36e12f5591bc4df8b6f774413b7","after_source_md5":"a1ce0576cc6ca82207301ae0bbc21904","hunks":[{"before":"  if p->>'schema_version' is distinct from 'ordinary-narrative-result/1'\n    or ((p->>'edge_revision',p->>'validator_revision') is distinct from ('ordinary-adapter/1','combat-narratore-v18-existing/1')\n     and (p->>'edge_revision',p->>'validator_revision') is distinct from ('ordinary-rinuncia/1','combat-rinuncia/1')\n     and (p->>'edge_revision',p->>'validator_revision') is distinct from ('ordinary-facts/1','combat-facts/1'))\n    or p->>'provider' is distinct from 'openai' or p->>'model' is distinct from 'gpt-6-luna'\n    or p->>'status' is null or p->>'status' not in ('succeeded','failed')\n    or jsonb_typeof(p->'validation_passed')<>'boolean' then raise exception 'narrative_result_contract_invalid'; end if;\n","after":"  if p->>'schema_version' is distinct from 'ordinary-narrative-result/1'\n    or ((p->>'edge_revision',p->>'validator_revision') is distinct from ('ordinary-adapter/1','combat-narratore-v18-existing/1')\n     and (p->>'edge_revision',p->>'validator_revision') is distinct from ('ordinary-rinuncia/1','combat-rinuncia/1')\n     and (p->>'edge_revision',p->>'validator_revision') is distinct from ('ordinary-facts/1','combat-facts/1')\n     and (p->>'edge_revision',p->>'validator_revision') is distinct from ('ordinary-facts/1','combat-facts/2'))\n    or p->>'provider' is distinct from 'openai' or p->>'model' is distinct from 'gpt-6-luna'\n    or p->>'status' is null or p->>'status' not in ('succeeded','failed')\n    or jsonb_typeof(p->'validation_passed')<>'boolean' then raise exception 'narrative_result_contract_invalid'; end if;\n","occurrences":1}]},{"signature":"public.combat_consumer_narrative_complete_v1(uuid,jsonb,uuid)","before_sha256":"ad21ed95bee40c3d4594a4a484aa6426736b25ecdb1b60fe1255f5cecd3674c3","after_sha256":"c14523e95544182275336ca9c14a2bf88d0b048858a96fe8772bf8a0f00c905c","after_source_md5":"2d60a9af131230e7f40ff99ed6456180","hunks":[{"before":"  select * into claim from combat_consumer_private.narrative_claims where id=p_claim for update;\n  if (p_result->>'edge_revision',p_result->>'validator_revision') is distinct from\n   (case when claim.context_payload->>'genere'='rinuncia' then 'ordinary-rinuncia/1' when claim.context_payload->>'genere'='azione_risolta' then 'ordinary-facts/1' else 'ordinary-adapter/1' end,\n    case when claim.context_payload->>'genere'='rinuncia' then 'combat-rinuncia/1' when claim.context_payload->>'genere'='azione_risolta' then 'combat-facts/1' else 'combat-narratore-v18-existing/1' end) then\n   raise exception 'rinuncia_result_context_revision_mismatch';end if;\n  fingerprint:=public.combat_v2_sha256(p_result);\n  if claim.completion_sha256 is not null then\n","after":"  select * into claim from combat_consumer_private.narrative_claims where id=p_claim for update;\n  if (p_result->>'edge_revision',p_result->>'validator_revision') is distinct from\n   (case when claim.context_payload->>'genere'='rinuncia' then 'ordinary-rinuncia/1' when claim.context_payload->>'genere'='azione_risolta' then 'ordinary-facts/1' else 'ordinary-adapter/1' end,\n    case when claim.context_payload->>'genere'='rinuncia' then 'combat-rinuncia/1' when claim.context_payload->>'genere'='azione_risolta' then CASE WHEN claim.context_payload->'fatti' ?| ARRAY['genjutsu_server','genjutsu_events'] OR claim.context_payload#>'{fatti,result}' ?| ARRAY['healing','mental_release'] THEN 'combat-facts/2' ELSE 'combat-facts/1' END else 'combat-narratore-v18-existing/1' end) then\n   raise exception 'rinuncia_result_context_revision_mismatch';end if;\n  fingerprint:=public.combat_v2_sha256(p_result);\n  if claim.completion_sha256 is not null then\n","occurrences":1}]},{"signature":"combat_panel_private.round_details_from_source(jsonb,jsonb,jsonb)","before_sha256":"18226d79403426a558f067107c367711534a5ad6b5f403250cbf0f4e96c3a885","after_sha256":"d5fd49d727a7e9529bf6e58d3b5c7783215af04cafaecf8ef706ae0c592e37c5","after_source_md5":"23722822d09c8d2a12a5121d04c141a6","hunks":[{"before":"         line:=actor_name||' → '||target_name;\n         IF jsonb_typeof(child->'success')='boolean' THEN line:=line||CASE WHEN (child->>'success')::boolean THEN ': attacco riuscito' ELSE ': attacco non riuscito' END; END IF;\n         IF jsonb_typeof(child->'damage_applied')='number' THEN line:=line||' · danno '||(child->>'damage_applied'); END IF;\n         line:=line||combat_panel_private.multiplication_result_label(child);\n         lines:=lines||jsonb_build_array(line);\n       END LOOP;\n","after":"         line:=actor_name||' → '||target_name;\n         IF jsonb_typeof(child->'success')='boolean' THEN line:=line||CASE WHEN (child->>'success')::boolean THEN ': attacco riuscito' ELSE ': attacco non riuscito' END; END IF;\n         IF jsonb_typeof(child->'damage_applied')='number' THEN line:=line||' · danno '||(child->>'damage_applied'); END IF;\n         line:=line||combat_panel_private.catalog_result_label_v1(child);\n         line:=line||combat_panel_private.multiplication_result_label(child);\n         lines:=lines||jsonb_build_array(line);\n       END LOOP;\n","occurrences":1},{"before":"       IF jsonb_typeof(outcome->'movement_m')='number' THEN line:=line||': '||(outcome->>'movement_m')::numeric::integer::text||' m'; END IF;\n       IF jsonb_typeof(outcome->'success')='boolean' THEN line:=line||CASE WHEN (outcome->>'success')::boolean THEN ': riuscito' ELSE ': non riuscito' END; END IF;\n       IF jsonb_typeof(outcome->'damage_applied')='number' THEN line:=line||' · danno '||(outcome->>'damage_applied'); END IF;\n       line:=line||combat_panel_private.multiplication_result_label(outcome);\n       line:=line||combat_panel_private.immobilization_result_label(outcome);\n       lines:=lines||jsonb_build_array(line);\n     END IF;\n     -- Fatti congelati nel report prima del suo hash; nessuna lettura DB nel formatter IMMUTABLE.\n     suiton:=d#>'{suiton_facts,suiton_server}';\n     IF jsonb_typeof(suiton)='object' THEN\n","after":"       IF jsonb_typeof(outcome->'movement_m')='number' THEN line:=line||': '||(outcome->>'movement_m')::numeric::integer::text||' m'; END IF;\n       IF jsonb_typeof(outcome->'success')='boolean' THEN line:=line||CASE WHEN (outcome->>'success')::boolean THEN ': riuscito' ELSE ': non riuscito' END; END IF;\n       IF jsonb_typeof(outcome->'damage_applied')='number' THEN line:=line||' · danno '||(outcome->>'damage_applied'); END IF;\n       line:=line||combat_panel_private.catalog_result_label_v1(outcome);\n       line:=line||combat_panel_private.multiplication_result_label(outcome);\n       line:=line||combat_panel_private.immobilization_result_label(outcome);\n       lines:=lines||jsonb_build_array(line);\n     END IF;\n     lines:=lines||combat_panel_private.catalog_lifecycle_lines_v1(d->'genjutsu_facts',p_roster);\n     -- Fatti congelati nel report prima del suo hash; nessuna lettura DB nel formatter IMMUTABLE.\n     suiton:=d#>'{suiton_facts,suiton_server}';\n     IF jsonb_typeof(suiton)='object' THEN\n","occurrences":1}]}]$cc_hunks$::jsonb;f jsonb;h jsonb;src text;current_text text;
BEGIN
 -- Check EVERY baseline before replacing any shared body.
 FOR f IN SELECT value FROM jsonb_array_elements(patches) LOOP
  IF to_regprocedure(f->>'signature') IS NULL THEN RAISE EXCEPTION 'CC_SHARED_SIGNATURE_MISSING:%',f->>'signature';END IF;
  src:=pg_get_functiondef((f->>'signature')::regprocedure);
  IF encode(extensions.digest(convert_to(src,'UTF8'),'sha256'),'hex')<>f->>'before_sha256' THEN RAISE EXCEPTION 'CC_SHARED_BASELINE_DRIFT:%',f->>'signature';END IF;
 END LOOP;
 FOR f IN SELECT value FROM jsonb_array_elements(patches) LOOP
  src:=pg_get_functiondef((f->>'signature')::regprocedure);
  FOR h IN SELECT value FROM jsonb_array_elements(f->'hunks') LOOP
   IF coalesce(length(h->>'before'),0)=0 OR (length(src)-length(replace(src,h->>'before','')))/length(h->>'before')<>1 THEN RAISE EXCEPTION 'CC_SHARED_ANCHOR_NOT_UNIQUE:%',f->>'signature';END IF;
   src:=replace(src,h->>'before',h->>'after');
  END LOOP;
  IF encode(extensions.digest(convert_to(src,'UTF8'),'sha256'),'hex')<>f->>'after_sha256' THEN RAISE EXCEPTION 'CC_SHARED_COMPOSITION_MISMATCH:%',f->>'signature';END IF;
  EXECUTE src;
  SELECT prosrc INTO STRICT current_text FROM pg_proc WHERE oid=(f->>'signature')::regprocedure;
  IF md5(current_text)<>f->>'after_source_md5' OR encode(extensions.digest(convert_to(pg_get_functiondef((f->>'signature')::regprocedure),'UTF8'),'sha256'),'hex')<>f->>'after_sha256' THEN RAISE EXCEPTION 'CC_SHARED_POSTIMAGE_MISMATCH:%',f->>'signature';END IF;
 END LOOP;
END $cc_shared$;

-- COMPONENT: root_footer
-- SOURCE ONLY · footer della transazione integrata PM, non installer autonomo.
-- Private Paralisi/Cure e hook composti devono già appartenere alla stessa transazione.
-- Congelare app.catalogo_footer_parameters e sostituire SOLO il pin qui sotto prima della review.
DO $catalogo_root$
DECLARE
 expected_parameters_sha256 constant text:='881af77f32b1990651b1c803e0d1d53e297b7176c121b1b1a651de15fb7ea399';
 old_root_sha constant text:='73712255c70f9560614d1e602bd770b3937138e3f383f636c1aa7f791ea6d335';
 old_row_sha constant text:='22028c166794c52118ec79f8cf7e741e012d0b227555ffb317ab709f60d081c5';
 generic_ezbr constant text:='9a6889802cfa17c99a556538cccd4ad7ef75274d32adccbc192c23d257aa3e76';
 baseline_combat_ezbr constant text:='50e0173983134aa94687408d51c7026d6ad1c64f8e0c474424aedaf653ecc028';
 rr mission_factory_owner.editor_release_readiness%ROWTYPE;
 prior_release mission_public_owner.release_admissions_v1%ROWTYPE;
 prior_qualification mission_public_owner.public_qualification_attestations_v1%ROWTYPE;
 params jsonb;review jsonb;before_root jsonb;root jsonb;core jsonb;cfg jsonb;identity jsonb;runtime_before jsonb;
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
 OR octet_length(rr.canonical_preimage)<>505228 THEN RAISE EXCEPTION 'CATALOGO_ROOT_BASELINE_DRIFT';END IF;
 IF EXISTS(SELECT 1 FROM public.combat_v2_sessions WHERE state='in_corso' AND closed_at IS NULL)
 OR EXISTS(SELECT 1 FROM public.master_v2_sessions WHERE stato NOT IN('chiusa','annullata') AND closed_at IS NULL) THEN
  RAISE EXCEPTION 'CATALOGO_ROOT_REQUIRES_QUIESCENCE';END IF;
 params:=nullif(current_setting('app.catalogo_footer_parameters',true),'')::jsonb;
 IF expected_parameters_sha256 !~ '^[0-9a-f]{64}$' OR params IS NULL
 OR public.combat_v2_sha256(params)<>expected_parameters_sha256
 OR params->>'schema_version' IS DISTINCT FROM 'catalogo-footer-parameters/1' THEN
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
 IF jsonb_typeof(params->'shared_functions') IS DISTINCT FROM 'array' OR jsonb_array_length(params->'shared_functions')<34
 OR jsonb_typeof(params->'private_functions') IS DISTINCT FROM 'array' OR jsonb_array_length(params->'private_functions')=0
 OR jsonb_typeof(params->'relations') IS DISTINCT FROM 'array' OR jsonb_array_length(params->'relations')=0
 OR jsonb_typeof(params->'triggers') IS DISTINCT FROM 'array' OR jsonb_array_length(params->'triggers')<>10 THEN
  RAISE EXCEPTION 'CATALOGO_ROOT_MANIFEST_SHAPES';END IF;
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
 OR old_combat IS DISTINCT FROM jsonb_build_object('name','combat_narratore_ai','source_sha256','7ee0ae0ecafcb6b595abea3687b494481c23b37bd8d8b5e4e2b306bc35360d4b')
 OR public.combat_v2_sha256(root->'ui')<>'4d4d1f127b97483ee3bf8ec64bc618196cfe2ef2b2193c00b409c53acee90708' THEN
  RAISE EXCEPTION 'CATALOGO_ROOT_UNRELATED_SURFACE_DRIFT';END IF;
 db_stored:=root#>>'{db_core,sha256}';db_old_recomputed:=public.combat_v2_sha256((root->'db_core')-'sha256');
 IF db_stored<>'9078a5554c59be20674c55adbaf1c41206d9cc17290f0480ad8f7f1a17637959'
 OR db_old_recomputed<>'fa5ff6109896202bafb614ea9af41f4aa2bbbfe8b5f563a08e9d43ab1d2c19dc'
 OR root#>>'{config,sha256}'<>public.combat_v2_sha256((root->'config')-'sha256') THEN
  RAISE EXCEPTION 'CATALOGO_ROOT_HASH_RECONCILIATION_DRIFT';END IF;

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

 edge_receipt:=params->'edge_receipt';edge_files:=params->'edge_expected_files';base_files:=params->'baseline_edge_files';
 IF edge_receipt->>'name' IS DISTINCT FROM 'combat_narratore_ai' OR edge_receipt->>'status' IS DISTINCT FROM 'ACTIVE'
 OR edge_receipt->'baseline_version' IS DISTINCT FROM '44'::jsonb OR edge_receipt->>'baseline_ezbr_sha256' IS DISTINCT FROM baseline_combat_ezbr
 OR jsonb_typeof(edge_receipt->'version') IS DISTINCT FROM 'number' OR(edge_receipt->>'version')::integer<=44
 OR edge_receipt->'verify_jwt' IS DISTINCT FROM 'false'::jsonb OR edge_receipt->'readback_verified' IS DISTINCT FROM 'true'::jsonb
 OR coalesce(edge_receipt->>'ezbr_sha256','')!~'^[0-9a-f]{64}$' OR coalesce(edge_receipt->>'receipt_sha256','')!~'^[0-9a-f]{64}$'
 OR nullif(edge_receipt->>'receipt_ref','') IS NULL OR edge_receipt->>'scene_contract' IS DISTINCT FROM 'Scene1'
 OR edge_receipt->'scene_contract_changed' IS DISTINCT FROM 'false'::jsonb
 OR edge_receipt->'files' IS DISTINCT FROM edge_files OR jsonb_typeof(edge_files) IS DISTINCT FROM 'array'
 OR jsonb_typeof(base_files) IS DISTINCT FROM 'array' OR jsonb_array_length(edge_files)<>18 OR jsonb_array_length(base_files)<>18 THEN
  RAISE EXCEPTION 'CATALOGO_ROOT_EDGE_RECEIPT_REQUIRED';END IF;
 IF EXISTS(SELECT 1 FROM jsonb_array_elements(edge_files) f WHERE coalesce(f->>'sha256','')!~'^[0-9a-f]{64}$'
  OR jsonb_typeof(f->'bytes')IS DISTINCT FROM 'number' OR(f->>'bytes')::integer<0)
 OR(SELECT count(DISTINCT f->>'name')FROM jsonb_array_elements(edge_files)f)<>18
 OR EXISTS(SELECT f->>'name' FROM jsonb_array_elements(edge_files)f EXCEPT SELECT f->>'name'FROM jsonb_array_elements(base_files)f)
 THEN RAISE EXCEPTION 'CATALOGO_ROOT_EDGE_FILESET';END IF;
 SELECT jsonb_agg(to_jsonb(f->>'name') ORDER BY f->>'name') INTO changed_files FROM jsonb_array_elements(edge_files)f
 JOIN jsonb_array_elements(base_files)b ON b->>'name'=f->>'name' WHERE f IS DISTINCT FROM b;
 IF changed_files IS DISTINCT FROM '["editorial.mjs","facts.ts","ordinary.ts"]'::jsonb THEN
  RAISE EXCEPTION 'CATALOGO_ROOT_EDGE_DIFF_SCOPE';END IF;
 root:=jsonb_set(root,'{edge_bundles}',(SELECT jsonb_agg(CASE WHEN b->>'name'='combat_narratore_ai' THEN
  jsonb_build_object('name','combat_narratore_ai','status','ACTIVE','version',edge_receipt->'version','verify_jwt',edge_receipt->'verify_jwt',
   'ezbr_sha256',edge_receipt->'ezbr_sha256','files',edge_files,'deployment_receipt_sha256',edge_receipt->'receipt_sha256',
   'legacy_source_sha256',old_combat->'source_sha256')ELSE b END ORDER BY ord)
  FROM jsonb_array_elements(root->'edge_bundles')WITH ORDINALITY x(b,ord)),false);

 -- Disponibilità iniziale: le nuove tecniche non ereditano le qualifiche missione.
 IF NOT EXISTS(SELECT 1 FROM combat_v2_genjutsu_internal.gate WHERE singleton AND enabled AND staff_enabled AND NOT public_enabled AND version=1)
 THEN RAISE EXCEPTION 'CATALOGO_ROOT_PARALISI_INITIAL_GATE';END IF;
 UPDATE combat_panel_private.cure_gate_v1 SET staff_enabled=true WHERE singleton AND staff_enabled IS FALSE
  AND public_enabled IS FALSE AND contract_version='palmo-curativo/1';
 GET DIAGNOSTICS affected=ROW_COUNT;IF affected<>1 THEN RAISE EXCEPTION 'CATALOGO_ROOT_CURE_INITIAL_GATE_CAS';END IF;
 core:=root->'db_core';core:=core||jsonb_build_object('catalogo_completo',jsonb_build_object('schema_version','catalogo-db-manifests/1',
  'state','staff_candidate_not_runtime_qualified','shared_manifest_sha256',shared_sha,'private_functions_manifest_sha256',private_sha,
  'relations_manifest_sha256',relations_sha,'source_bundle_sha256',params->'source_bundle_sha256',
  'shared_count',jsonb_array_length(shared_manifest),'private_function_count',jsonb_array_length(private_manifest),'relation_count',jsonb_array_length(relation_manifest)));
 db_sha:=public.combat_v2_sha256(core-'sha256');core:=jsonb_set(core,'{sha256}',to_jsonb(db_sha),true);root:=jsonb_set(root,'{db_core}',core,false);
 identity:=jsonb_build_object('schema_version','catalogo-integrated-identity/1','parent_root',old_root_sha,
  'db_sha256',db_sha,'shared_manifest_sha256',shared_sha,'private_functions_manifest_sha256',private_sha,'relations_manifest_sha256',relations_sha,
  'source_bundle_sha256',params->'source_bundle_sha256','combat_edge_receipt_sha256',edge_receipt->'receipt_sha256',
  'db_hash_reconciliation',jsonb_build_object('previous_stored',db_stored,'previous_recomputed',db_old_recomputed),
  'new_techniques',jsonb_build_object('staff_enabled',true,'public_enabled',false,'staff_pass',false,'qa_state','NOT_RUN'),
  'compatibility_sha256',params#>'{compatibility,sha256}','provider_calls',0);
 identity_sha:=public.combat_v2_sha256(identity);cfg:=(root->'config')||jsonb_build_object('catalogo_completo',identity);
 config_sha:=public.combat_v2_sha256(cfg-'sha256');cfg:=jsonb_set(cfg,'{sha256}',to_jsonb(config_sha),false);root:=jsonb_set(root,'{config}',cfg,false);
 root:=jsonb_set(root,'{contract,code_identity_sha256}',to_jsonb(identity_sha),false);
 root:=jsonb_set(root,'{recovery,semantic_identity_sha256}',to_jsonb(identity_sha),false);
 root:=jsonb_set(root,'{recovery,catalogo_completo}',jsonb_build_object('policy','forward_inert_only','history_keep',true,
  'parent_root',old_root_sha,'previous_semantic_identity',before_root#>'{recovery,semantic_identity_sha256}',
  'inverse_hooks_required',true,'native_close_own_tests_required',true,'preserve_objects_and_audit',true),true);
 IF root->'ui' IS DISTINCT FROM before_root->'ui'
 OR(root->'config')-ARRAY['sha256','catalogo_completo'] IS DISTINCT FROM(before_root->'config')-'sha256'
 OR NOT EXISTS(SELECT 1 FROM jsonb_array_elements(root->'edge_bundles')b WHERE b=old_generic)
 THEN RAISE EXCEPTION 'CATALOGO_ROOT_UNRELATED_CONFIGURATION_CHANGED';END IF;
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
 IF (SELECT count(*)FROM mission_public_owner.mission_content_admissions_v1 WHERE engine_release_sha256=old_root_sha)<>2
 OR EXISTS(SELECT 1 FROM mission_public_owner.mission_content_admissions_v1 c WHERE c.engine_release_sha256=old_root_sha
  AND NOT((c.mission_id='6d6c216a-222d-4cba-b2fc-f3e0c199c195'::uuid AND c.config_version=1 AND c.payload_sha256='faeca906f6fc209da03907d27f19879d4e86d7affb5e20e7a4ad60e391908491')
   OR(c.mission_id='a3a8430f-6a3d-4d46-9a75-271d5458406d'::uuid AND c.config_version=1 AND c.payload_sha256='2423c354eafd93ace64f08bb1c55ece1a5431560766a530b7108115a4362d420')))
 THEN RAISE EXCEPTION 'CATALOGO_ROOT_CONTENT_BASELINE';END IF;
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
 PERFORM set_config('app.catalogo_footer_result',jsonb_build_object('root_sha256',new_root_sha,'root_bytes',octet_length(root_text),
  'db_sha256',db_sha,'configuration_sha256',config_sha,'code_identity_sha256',identity_sha,'aliases_updated',aliases,
  'shared_manifest_sha256',shared_sha,'private_functions_manifest_sha256',private_sha,'relations_manifest_sha256',relations_sha,
  'new_techniques_staff_pass',false,'provider_calls',0)::text,true);
END $catalogo_root$;

COMMIT;
