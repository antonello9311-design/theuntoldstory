-- INERT AGGREGATE SOURCE. Independent final review binding and explicit Main apply remain required.
BEGIN;
SET LOCAL TIME ZONE 'UTC';
SET LOCAL lock_timeout='5s';
SET LOCAL statement_timeout='60s';
DO $integrated_source_only$ BEGIN RAISE EXCEPTION 'TACTICS_INTEGRATED_REVIEW_PENDING_NOT_INSTALLABLE';END $integrated_source_only$;
CREATE TEMP TABLE tactics_review ON COMMIT DROP AS SELECT '{"ref": null, "state": "PENDING", "sha256": null, "findings": null, "source_sha256": "70532b3233ce24e12d18396eacb02e71db5a215df46f6ef88f60160a71384cca"}'::jsonb doc;
DO $integrated_pre$ BEGIN
PERFORM 1 FROM mission_factory_owner.editor_release_readiness WHERE singleton FOR UPDATE NOWAIT;
PERFORM 1 FROM mission_public_owner.party_launch_runtime_v1 WHERE singleton FOR UPDATE NOWAIT;
PERFORM 1 FROM public.locations WHERE id='0b85f354-9cdb-47e1-baf9-3d266bb7e06b'::uuid FOR UPDATE NOWAIT;
IF NOT coalesce((current_user='postgres'AND session_user='postgres'AND auth.uid()IS NULL),false)THEN RAISE EXCEPTION 'TACTICS_INTEGRATED_OPERATOR';END IF;
IF NOT coalesce(((SELECT (to_jsonb(r)-'canonical_preimage')='{"scope": "staff", "state": "enabled", "singleton": true, "created_at": "2026-10-03T04:40:35.016709+00:00", "updated_at": "2026-11-07T14:02:11.571083+00:00", "client_build": "mission-factory-admin/2:e9d24578201d8f0b086e9fc079fb657f5d41364145218d8385e878aa659769ce", "revision_sha256": "e9d24578201d8f0b086e9fc079fb657f5d41364145218d8385e878aa659769ce", "staff_guards_verified": true, "independent_review_ref": "TACTICS-COVERAGE-UI:4af0570ea78b8d79c4b924a5cb42cf20b1c1e57c2b601e742b5421b426524af9", "observed_revision_sha256": "e9d24578201d8f0b086e9fc079fb657f5d41364145218d8385e878aa659769ce", "published_assets_verified": true}'::jsonb AND public.combat_v2_sha256(r.canonical_preimage::jsonb)='e9d24578201d8f0b086e9fc079fb657f5d41364145218d8385e878aa659769ce' FROM mission_factory_owner.editor_release_readiness r WHERE singleton)),false)THEN RAISE EXCEPTION 'TACTICS_INTEGRATED_ROOT_CAS';END IF;
IF NOT coalesce(((SELECT to_jsonb(p)='{"singleton": true, "staff_enabled": true, "public_enabled": true, "release_sha256": "e9d24578201d8f0b086e9fc079fb657f5d41364145218d8385e878aa659769ce"}'::jsonb FROM mission_public_owner.party_launch_runtime_v1 p WHERE singleton)),false)THEN RAISE EXCEPTION 'TACTICS_INTEGRATED_PARTY_CAS';END IF;
IF NOT coalesce((NOT EXISTS(SELECT 1 FROM public.combat_v2_sessions WHERE location_id='0b85f354-9cdb-47e1-baf9-3d266bb7e06b'::uuid AND closed_at IS NULL)AND NOT EXISTS(SELECT 1 FROM public.master_v2_sessions WHERE location_id='0b85f354-9cdb-47e1-baf9-3d266bb7e06b'::uuid AND stato NOT IN('chiusa','annullata'))),false)THEN RAISE EXCEPTION 'TACTICS_INTEGRATED_STAFF_QUIET';END IF;
IF NOT coalesce((clock_timestamp()<'2026-11-07T20:30:58.461822Z'::timestamptz),false)THEN RAISE EXCEPTION 'TACTICS_INTEGRATED_CAMPAIGN_WINDOW';END IF;
IF NOT coalesce(((SELECT body='{"gates": {"hyuga": {"revision": "hyuga-lifecycle/1", "singleton": true, "staff_enabled": true, "master_enabled": true, "public_enabled": true, "sharingan_public_enabled": true}, "facing": {"revision": 2, "singleton": true, "staff_enabled": true, "public_enabled": false, "contract_version": "byakugan-facing/1"}, "innata": {"singleton": true, "staff_enabled": true, "public_enabled": true, "control_version": 3}, "tactics": {"version": 2, "singleton": true, "staff_enabled": true, "master_enabled": false, "generic_enabled": false, "ordinary_enabled": false, "revision_reference": "combat-multiplication-tactics/1"}}, "party": {"audit": {"count": 15, "sha256": "03dc7df003e07762401e24c464ff3543081a424b7fb7ca4d20886c5c2d0f4748"}, "scopes": {"count": 3, "sha256": "61366c0724bb589da46cb154aadfad99f68b573a1aee75c504a93291dc584f27"}, "bookings": {"count": 11, "sha256": "886f1a0f09e0dab1dd8cb8bfb6b1af8109216d58e42cbf446f87a04d58801cb9"}, "applicants": {"count": 11, "sha256": "6736d2e3446d2b0314c967331947a95c529bc40da44f4f7f9f71252b33aea6fa"}, "activations": {"count": 5, "sha256": "387307b3df5875dd582aa9e937d27763c048a16b398679cff4438e17d1bc4eed"}, "simulation_sources": {"count": 17, "sha256": "e28d627ac21a5fc4f50b28bd90b6492cbb411945322419c5ef8b2f492db1ade0"}}, "real_pg": "cca57a1c2c679a6c45e03323c16e5349daa7de960435ba095b75c7436d81b831", "scorta_masters": "7a3b9f5f68acca9dc6379ce950f326097f3a59b9c0508878d3a9d276527437e0", "scorta_mission": "2982dcb378be32a118d171bc3ab16d4906ee26d7f015a8dd4298c0587796dbda"}'::jsonb FROM (SELECT clock_timestamp() AS captured_at,jsonb_build_object(
 'real_pg',(SELECT public.combat_v2_sha256(coalesce(jsonb_agg(to_jsonb(c)-'updated_at'-'last_regen_at' ORDER BY c.id),'[]'::jsonb)) FROM public.characters c WHERE c.id IN('6bceee99-974f-426b-8d92-38b43b4a4267'::uuid,'f335b077-34a1-41c3-94aa-58ec674b649b'::uuid,'2a877f02-4993-4e65-9172-7d29f08c5b86'::uuid)),
 'scorta_mission',(SELECT public.combat_v2_sha256(to_jsonb(m)) FROM public.missions m WHERE m.id='db1588ae-50f2-4c0e-9028-0b94155d94b1'::uuid),
 'scorta_masters',(SELECT public.combat_v2_sha256(coalesce(jsonb_agg(to_jsonb(m) ORDER BY m.id),'[]'::jsonb)) FROM public.master_v2_sessions m WHERE m.mission_id='db1588ae-50f2-4c0e-9028-0b94155d94b1'::uuid),
 'gates',jsonb_build_object(
 'innata',(SELECT to_jsonb(g) FROM clan_innata_narrative_private.gate_v1 g WHERE singleton),
 'hyuga',(SELECT to_jsonb(g) FROM clan_hyuga_private.release_gate g WHERE singleton),
 'facing',(SELECT to_jsonb(g) FROM combat_facing_private.release_gate g WHERE singleton),
 'tactics',(SELECT to_jsonb(g) FROM combat_panel_private.multiplication_tactics_release_gate g WHERE singleton)),
 'party',(SELECT p.capture->'custody' FROM (WITH root AS(SELECT revision_sha256,canonical_preimage::jsonb body FROM mission_factory_owner.editor_release_readiness WHERE singleton),
protected_missions(id)AS(VALUES('6d6c216a-222d-4cba-b2fc-f3e0c199c195'::uuid),('db1588ae-50f2-4c0e-9028-0b94155d94b1'::uuid) UNION SELECT mission_id FROM mission_public_owner.party_launch_scopes_v1),
protected_activations(id)AS(SELECT id FROM mission_ai_board_owner.activations WHERE mission_id IN(SELECT id FROM protected_missions))
SELECT jsonb_build_object('schema_version','innata-all-party-live-capture/1','captured_at',clock_timestamp(),'root_revision',(SELECT revision_sha256 FROM root),
'runtime',(SELECT to_jsonb(x)FROM mission_public_owner.party_launch_runtime_v1 x WHERE singleton),
'client_capsule',(SELECT body#>'{config,party_launch_staff_client}'FROM root),
'client_sha256',(SELECT public.combat_v2_sha256(body->'ui')FROM root),
'edge_bundles_sha256',(SELECT public.combat_v2_sha256(body->'edge_bundles')FROM root),
'capsule_client_matches_ui',(SELECT body#>>'{config,party_launch_staff_client,client_sha256}'=public.combat_v2_sha256(body->'ui')FROM root),
'capsule_edge_matches_bundles',(SELECT body#>>'{config,party_launch_staff_client,edge_bundles_sha256}'=public.combat_v2_sha256(body->'edge_bundles')FROM root),
'custody',jsonb_build_object(
'scopes',(SELECT jsonb_build_object('count',count(*),'sha256',public.combat_v2_sha256(coalesce(jsonb_agg(to_jsonb(x)ORDER BY to_jsonb(x)::text),'[]'::jsonb)))FROM mission_public_owner.party_launch_scopes_v1 x),
'bookings',(SELECT jsonb_build_object('count',count(*),'sha256',public.combat_v2_sha256(coalesce(jsonb_agg(to_jsonb(x)ORDER BY to_jsonb(x)::text),'[]'::jsonb)))FROM public.mission_bookings x WHERE mission_id IN(SELECT id FROM protected_missions)),
'activations',(SELECT jsonb_build_object('count',count(*),'sha256',public.combat_v2_sha256(coalesce(jsonb_agg(to_jsonb(x)ORDER BY to_jsonb(x)::text),'[]'::jsonb)))FROM mission_ai_board_owner.activations x WHERE mission_id IN(SELECT id FROM protected_missions)),
'applicants',(SELECT jsonb_build_object('count',count(*),'sha256',public.combat_v2_sha256(coalesce(jsonb_agg(to_jsonb(x)ORDER BY to_jsonb(x)::text),'[]'::jsonb)))FROM mission_ai_board_owner.applicants x WHERE activation_id IN(SELECT id FROM protected_activations)),
'audit',(SELECT jsonb_build_object('count',count(*),'sha256',public.combat_v2_sha256(coalesce(jsonb_agg(to_jsonb(x)ORDER BY to_jsonb(x)::text),'[]'::jsonb)))FROM mission_ai_board_owner.audit x WHERE activation_id IN(SELECT id FROM protected_activations)),
'simulation_sources',(SELECT jsonb_build_object('count',count(*),'sha256',public.combat_v2_sha256(coalesce(jsonb_agg(to_jsonb(x)ORDER BY to_jsonb(x)::text),'[]'::jsonb)))FROM mission_generic_owner.simulation_sources x WHERE source_mission_id='6d6c216a-222d-4cba-b2fc-f3e0c199c195'::uuid OR carrier_mission_id IN(SELECT id FROM protected_missions))
))capture) p)
) AS body)c)),false)THEN RAISE EXCEPTION 'TACTICS_INTEGRATED_CUSTODY_BASELINE';END IF;
IF NOT coalesce(((SELECT count(*)=1 AND bool_and(to_jsonb(x)='{"db_sha256": "23dd060e0167bebde1208a95072afcaaa548270ed0dd57c504ad51d0977775ad", "created_at": "2026-11-07T14:02:11.620249+00:00", "edge_sha256": "89358158910378b7bd29661bf39f1680ff05e2af0aa32e4dc45e80359b771350", "qualified_at": "2026-11-07T14:02:11.620248+00:00", "client_sha256": "8d4ca65e3fd9d137364a38353726c7873063197167be6a453de9d0e30c59b9b2", "public_enabled": true, "release_sha256": "e9d24578201d8f0b086e9fc079fb657f5d41364145218d8385e878aa659769ce", "contract_version": "mission-public-admission/1", "staff_evidence_ref": "AUTHORIZED_TEST_MANIFEST:sha256:64bdfd1d1afe956ea88f7b4d9e00dfe03613794c3931dd9ec90ceb42209d0b98", "configuration_sha256": "0a229568fd1bc4f08b71a6d93bdc8733319a3b8b71ce5a2d7558ecd7a9ab0d34", "independent_review_ref": "TACTICS-COVERAGE-UI:4af0570ea78b8d79c4b924a5cb42cf20b1c1e57c2b601e742b5421b426524af9"}'::jsonb)FROM mission_public_owner.release_admissions_v1 x WHERE release_sha256='e9d24578201d8f0b086e9fc079fb657f5d41364145218d8385e878aa659769ce')),false)THEN RAISE EXCEPTION 'TACTICS_INTEGRATED_ADMISSION_CAS';END IF;
IF NOT coalesce(((SELECT count(*)=1 AND bool_and(to_jsonb(x)='{"payload": {"bindings": {"db_sha256": "23dd060e0167bebde1208a95072afcaaa548270ed0dd57c504ad51d0977775ad", "edge_sha256": "89358158910378b7bd29661bf39f1680ff05e2af0aa32e4dc45e80359b771350", "client_sha256": "8d4ca65e3fd9d137364a38353726c7873063197167be6a453de9d0e30c59b9b2", "configuration_sha256": "0a229568fd1bc4f08b71a6d93bdc8733319a3b8b71ce5a2d7558ecd7a9ab0d34"}, "capabilities": [{"key": "mission.narrative.scene", "usage": "phase_transition", "family": "narrative", "qualified": true, "evidence_ref": "/private/tmp/tus-c1266-full86-20261102/db-cause38/FINAL_POSTFLIGHT.json", "phase_allowed": true, "evidence_sha256": "fd8bde6f2a840d70b7a166379b50ce510cc7cd45b5a0750cfd588f612298f888", "allowed_content_kinds": ["mission"]}, {"key": "mission.combat.encounter", "usage": "phase_transition", "family": "combat", "qualified": true, "evidence_ref": "/private/tmp/tus-c1266-full86-20261102/db-cause38/FINAL_POSTFLIGHT.json", "phase_allowed": true, "evidence_sha256": "fd8bde6f2a840d70b7a166379b50ce510cc7cd45b5a0750cfd588f612298f888", "allowed_content_kinds": ["mission"]}], "reuse_evidence": {"scope": "Public native contract compatibility with new gated Staff branches; no fresh clean runtime claim", "source_component": {"scope": "EditorOnly", "schema": "editor-panel-composed-source/1", "base_root": "f7aebda96092a1fd71e26ddda35da84b34e3b0144d14e64ca5da31737feec512", "source_files": {"EDITOR_MISSIONI_RECOVERY.sql": "1abc3e3db469fcfefce80a4e385c276f3b6ffdc9f7d1a15ad8a36b19cc2d16bb", "EDITOR_MISSIONI_ENGINE_SOURCE.sql": "600b181a9a32e3285978e883bc28b1b3c9d8c612a3cb93d7388e63a07101f323", "EDITOR_MISSIONI_AUTHORING_SOURCE.sql": "f56c4c03f09ee387d7490b599b3a164a29dc741de51e0901dcc8e4f31a3710a4"}, "no_content_creation": true, "new_mission_QA_claim": false, "source_review_sha256": "68e618cf186b056d11b45b0e274fe829afa4043d986fb27a68bc485ec0208c2c", "function_identity_contract": "pg-oid/resolved-regprocedure/1", "LAND_GenericUI_Edge_unchanged": true, "baseline_descriptor_reconciliation": {"schema": "editor-root-alias-reconciliation/1", "aliases": [{"path": ["db_core", "reader"], "authority": "Existing f7 all_function_headers, matching unchanged live diagnostic; no body changed", "proof_paths": [["db_core", "all_function_headers", "107"], ["db_core", "c1266_functions", "90"]], "old_descriptor": {"acl": "{postgres=X/postgres,service_role=X/postgres}", "oid": "308755", "owner": "postgres", "config": ["search_path=\"\""], "secdef": true, "ddl_md5": "f50ea1ca8ae51be85347c731c486b1d3", "signature": "mission_generic_director_narration_next_v1(uuid,jsonb,uuid)", "source_md5": "ed3c36b73f286d077e7641deb79fd79a"}, "current_descriptor": {"acl": "{postgres=X/postgres,service_role=X/postgres}", "oid": "308755", "owner": "postgres", "config": ["search_path=\"\""], "secdef": true, "ddl_md5": "1810130dfa582fe506de8215170088d3", "signature": "mission_generic_director_narration_next_v1(uuid,jsonb,uuid)", "source_md5": "9daaaa9bc4a0ea30b022d2a7cd6d3456"}, "authoritative_descriptor": {"acl": "{postgres=X/postgres,service_role=X/postgres}", "oid": 308755, "owner": "postgres", "config": ["search_path=\"\""], "secdef": true, "ddl_md5": "1810130dfa582fe506de8215170088d3", "language": "plpgsql", "signature": "public.mission_generic_director_narration_next_v1(uuid,jsonb,uuid)", "source_md5": "9daaaa9bc4a0ea30b022d2a7cd6d3456", "volatility": "v"}}, {"path": ["db_core", "tick_writer"], "authority": "Existing f7 all_function_headers, matching unchanged live diagnostic; no body changed", "proof_paths": [["db_core", "all_function_headers", "62"]], "old_descriptor": {"acl": "{postgres=X/postgres,service_role=X/postgres}", "oid": "109829", "owner": "postgres", "config": ["search_path=\"\""], "secdef": true, "ddl_md5": "deed503323977aab3d4d0175a0e5c0e4", "signature": "mission_generic_staff_tick_v1(uuid,uuid,text,uuid)", "source_md5": "872497f9001b5f80ff8b66ce94a90336"}, "current_descriptor": {"acl": "{postgres=X/postgres,service_role=X/postgres}", "oid": "109829", "owner": "postgres", "config": ["search_path=\"\""], "secdef": true, "ddl_md5": "9ed5587c3843179b3052f638376820d9", "signature": "mission_generic_staff_tick_v1(uuid,uuid,text,uuid)", "source_md5": "337ec76aee4b8d282ab5dee40dc29dac"}, "authoritative_descriptor": {"acl": "{postgres=X/postgres,service_role=X/postgres}", "oid": 109829, "owner": "postgres", "config": ["search_path=\"\""], "secdef": true, "ddl_md5": "9ed5587c3843179b3052f638376820d9", "language": "plpgsql", "signature": "public.mission_generic_staff_tick_v1(uuid,uuid,text,uuid)", "source_md5": "337ec76aee4b8d282ab5dee40dc29dac", "volatility": "v"}}, {"path": ["db_core", "cached_recovery"], "authority": "Existing f7 all_function_headers, matching unchanged live diagnostic; no body changed", "proof_paths": [["db_core", "all_function_headers", "72"]], "old_descriptor": {"acl": "{postgres=X/postgres,service_role=X/postgres}", "oid": "150538", "owner": "postgres", "config": ["search_path=\"\""], "secdef": true, "ddl_md5": "e5af9b73f6de99fcfa8ebf6853857228", "signature": "mission_generic_staff_republish_failed_v1(uuid,uuid,uuid)", "source_md5": "bd247db309ef2b683850a30df1b93c38"}, "current_descriptor": {"acl": "{postgres=X/postgres,service_role=X/postgres}", "oid": "150538", "owner": "postgres", "config": ["search_path=\"\"", "statement_timeout=30s"], "secdef": true, "ddl_md5": "3d1013c453de2762a7ddd27b7a2ca691", "signature": "mission_generic_staff_republish_failed_v1(uuid,uuid,uuid)", "source_md5": "b718f0f920e7169065b0fef492b85d67"}, "authoritative_descriptor": {"acl": "{postgres=X/postgres,service_role=X/postgres}", "oid": 150538, "owner": "postgres", "config": ["search_path=\"\"", "statement_timeout=30s"], "secdef": true, "ddl_md5": "3d1013c453de2762a7ddd27b7a2ca691", "language": "plpgsql", "signature": "public.mission_generic_staff_republish_failed_v1(uuid,uuid,uuid)", "source_md5": "b718f0f920e7169065b0fef492b85d67", "volatility": "v"}}], "baseline_root": "f7aebda96092a1fd71e26ddda35da84b34e3b0144d14e64ca5da31737feec512", "diagnostic_sha256": "f41f0a6c18ee9647950eda4d04c9857f79bc2f19cd66ad9019e80a3ef6dd499d"}}, "historical_status": "FAILED_NONCLEAN_WITH_SCOPED_RECOVERY", "new_mission_QA_claim": false, "accepted_user_decision": {"ref": "management/candidati/NARRATORE-UNIFICATO_2026-09-02/candidato/exam_human_master/C1266_PUBLIC87_RELEASE_DECISION.json", "scope": "DiscussioniV9_already_played_narrator", "sha256": "8227b41536cfd34fcb1200bf12cd52adff31b14ce379e2881ff1d50cd50d5c00", "decision": "OPEN_ALREADY_TESTED_VERSION_WITH_REVIEWED_PUBLIC_WIRING", "new_qa_requested": false, "clean_runtime_claim": false}, "combat_innata_component": {"contracts": ["mission-role-command/3", "mission-role-submit/2", "byakugan-facing/1", "combat-multiplication-tactics/1"], "availability": "staff_only_world_new_features_false", "review_inputs": {"/Users/antonello/Desktop/theuntoldstory/management/candidati/COMBAT-COMPOSITE_2026-09-01/candidato/INNATA_BRIDGE_REVIEW.json": "f3f686a8fd37242d7e4a28e8ee9dad2d5b96176dc489d0028dba475c83735562", "/Users/antonello/Desktop/theuntoldstory/management/candidati/COMBAT-COMPOSITE_2026-09-01/candidato/INNATA_UPKEEP_REVIEW.json": "cc5e024b90545c5ec8df8398e482d219c7ff2f449d07f263aabd7e38d98eb8fb", "/Users/antonello/Desktop/theuntoldstory/management/candidati/COMBAT-COMPOSITE_2026-09-01/candidato/COMBAT_CURRENT_RELEASE_REVIEW.json": "c0df6909c47d4344ccc49678b19ea9c0fd563ee19f6242cb3d4788cf5d046a0c", "/Users/antonello/Desktop/theuntoldstory/management/candidati/COMBAT-COMPOSITE_2026-09-01/candidato/COMBAT_COMPONENTS_SOURCE_REVIEW.json": "82b7307e774461dc3b3d27fde329a7693e964bedbf4aa603705d355cbe781f41", "/Users/antonello/Desktop/theuntoldstory/management/candidati/COMBAT-COMPOSITE_2026-09-01/candidato/COMBAT_INNATA_SEAL_CLOSURE_REVIEW.json": "c3b92f8f93d5b15811fe4787cc42cadb263e8b588f504a8fbaca1dce984bb276", "/Users/antonello/Desktop/theuntoldstory/management/candidati/NARRATORE-UNIFICATO_2026-09-02/candidato/exam_human_master/COMBAT_MISSIONI_UI_REVIEW2.json": "e4f8c25ab6db9931aaeba8689c4af82352dbeeb7f233e3ec2f2ea56a3c61ad3a"}, "source_inputs": {"/Users/antonello/Desktop/theuntoldstory/management/candidati/COMBAT-COMPOSITE_2026-09-01/candidato/FACING_SOURCE.sql": "96a3941ea227bf64d365826a8f0886b7bf8a98396c8f75e40167f157d399970e", "/Users/antonello/Desktop/theuntoldstory/management/candidati/COMBAT-COMPOSITE_2026-09-01/candidato/INNATA_LIFECYCLE_SOURCE.sql": "a8002313cfbc3dcc60112278ec69b9fe2fe42db9380f57ba34ea640a24044ed1", "/Users/antonello/Desktop/theuntoldstory/management/candidati/COMBAT-COMPOSITE_2026-09-01/candidato/COMBAT_TACTICS_CANDIDATO.sql": "22312a8ea771140a49d906a4fcce2bf05d285e9b3a9fdfb1007a72570e52a38a", "/Users/antonello/Desktop/theuntoldstory/management/candidati/COMBAT-COMPOSITE_2026-09-01/candidato/INNATA_INTEGRAZIONE_SOURCE.sql": "229115a889fd663c631a6d13311901fd53a14dc373f76f4ab52d749d2cae363a", "/Users/antonello/Desktop/theuntoldstory/management/candidati/COMBAT-COMPOSITE_2026-09-01/candidato/INNATA_ELIGIBILITY_COMPAT_SOURCE.sql": "47045f209564829fd5009af8ce68a395d83649a45f4d37ee531198179968b894"}, "schema_version": "combat-innata-integrated-component/1", "consumer_inputs": {"/Users/antonello/Desktop/theuntoldstory/management/candidati/NARRATORE-UNIFICATO_2026-09-02/candidato/exam_human_master/INNATA_COMMAND_LAND.html": "ed6e01805df4f11da916b2310b9af9b9ac5a6fa1bfb6e61126d31124d88290ce", "/Users/antonello/Desktop/theuntoldstory/management/candidati/NARRATORE-UNIFICATO_2026-09-02/candidato/exam_human_master/INNATA_COMMAND_REVIEW.md": "a04a97919dddcd614a5b27c7c71daec145321cacf54d10fbaa1212cc7c445b4c", "/Users/antonello/Desktop/theuntoldstory/management/candidati/NARRATORE-UNIFICATO_2026-09-02/candidato/exam_human_master/COMBAT_MISSIONI_REGOLE.md": "737a624b3883681459090369156567d8c8665d68fde333fa5d44ca1bffdfa5c2", "/Users/antonello/Desktop/theuntoldstory/management/candidati/NARRATORE-UNIFICATO_2026-09-02/candidato/exam_human_master/COMBAT_MISSIONI_ADMIN.html": "871552ea63704813c65d7157daca023879e16a6e2fbd27975b4153a8c3b6e393", "/Users/antonello/Desktop/theuntoldstory/management/candidati/NARRATORE-UNIFICATO_2026-09-02/candidato/exam_human_master/COMBAT_MISSIONI_EDITOR.mjs": "bbc1f44089aab17f29585459a350ea2615194cc6aec1a01ce83c7097652dfea6", "/Users/antonello/Desktop/theuntoldstory/management/candidati/NARRATORE-UNIFICATO_2026-09-02/candidato/exam_human_master/COMBAT_MISSIONI_regole.html": "e69d00d5ca446d6bf4af5e0f070e4adea14592ab0cc1adb2a22d642fa85d865e", "/Users/antonello/Desktop/theuntoldstory/management/candidati/NARRATORE-UNIFICATO_2026-09-02/candidato/exam_human_master/COMBAT_MISSIONI_CREATION.mjs": "8a6e0f5b50ba58164ee1491086509169d39ba4b59efb9caf91dac5ce92bf4fd3", "/Users/antonello/Desktop/theuntoldstory/management/candidati/NARRATORE-UNIFICATO_2026-09-02/candidato/exam_human_master/INNATA_COMMAND_GENERIC_UI.mjs": "e7f32894f96f304af494eae7d56e6ef11b6680aff6a41f24df8420a22025d63b", "/Users/antonello/Desktop/theuntoldstory/management/candidati/NARRATORE-UNIFICATO_2026-09-02/candidato/exam_human_master/INNATA_COMMAND_EDGE_FILES.json": "33276144f4b9352b5f3b30c841e8985247aac735ab70ce95dd84762a9f23af8e", "/Users/antonello/Desktop/theuntoldstory/management/candidati/NARRATORE-UNIFICATO_2026-09-02/candidato/exam_human_master/INNATA_COMMAND_CONSUMERS_MANIFEST.json": "ce2cdc2286ccd3902294faa1d71e8367095a86ba3bb8582b08d7e8902ebb455a"}, "capture_provenance": {"all_ok": true, "extra_rows": 698, "extra_query_sha256": "8aa4503f64222d0e3a85d510480f2569d7085e3c307036f01969785e26958279", "actualB_file_sha256": "fc8dae2b68322e2ad6ab5ff7e82f3394b8473fb6c4a8ecdd72a90cc152571291", "extra_actual_file_sha256": "e11993185cd47554dc99b437ac23458d86f0c0f756e0419a13ad962ca297b7dd"}, "new_mission_QA_claim": false, "parent_editor_release": "b21c59c642be4734803859a2a28df51f7412cd9bbef8c8606a80a7e4553e9060", "cumulative_counters_preserved": true}, "origin_qualification_sha256": "fd8bde6f2a840d70b7a166379b50ce510cc7cd45b5a0750cfd588f612298f888", "origin_qualification_release": "f7aebda96092a1fd71e26ddda35da84b34e3b0144d14e64ca5da31737feec512"}, "schema_version": "mission-engine-qualification/1", "revision_sha256": "e9d24578201d8f0b086e9fc079fb657f5d41364145218d8385e878aa659769ce", "runtime_profile": "mission-narrative-admission/4 + provider-input/6 + scene-public/2", "legacy_adoptions": [{"mission_id": "6d6c216a-222d-4cba-b2fc-f3e0c199c195", "capability_sha256": "46d1f0d2c3c0d5769f465e1bdc6ce34ba97d7a485923128729080156bc8b90e7", "publication_request": "3ff627ec-dbee-423a-9879-8e37f7ad5510", "origin_release_sha256": "f7aebda96092a1fd71e26ddda35da84b34e3b0144d14e64ca5da31737feec512", "source_content_sha256": "f5ea8c75ac7ce660f6b29214427d13aa971be9fa576ac246a12890e4a970b605"}], "authoring_profile": "mission-ai-authoring/1", "financial_profile": {"limits": {"http_limit": 28, "generation_limit": 14, "input_tokens_limit": 24000, "output_tokens_limit": 20000, "scene_cost_budget_usd": "0.3136"}, "pricing": {"model": "gpt-6-luna", "store": false, "reasoning_effort": "high", "input_usd_million": 0.1, "max_output_tokens": 20000, "output_usd_million": 0.5, "count_upper_cost_usd": "0.0124", "generation_upper_cost_usd": "0.0124"}, "world_mode": "scene_finite", "schema_version": "mission-scene-financial-evidence/1", "staff_spend_usd": "0.15927630", "tariff_evidence_sha256": "d7bc0f5b501cbc9d956e681556e05a367c54a6caa7aa050020a95b6daf1354d3", "financial_qualification_sha256": "d8da6486b29f5e6b57272eb9d21660518cdcb57f12ed69209e12f32c37e2d5c0"}, "independent_review": {"P0": 0, "P1": 0, "P2": 0, "ref": "TACTICS-COVERAGE-UI:4af0570ea78b8d79c4b924a5cb42cf20b1c1e57c2b601e742b5421b426524af9", "sha256": "4af0570ea78b8d79c4b924a5cb42cf20b1c1e57c2b601e742b5421b426524af9"}}, "created_at": "2026-11-07T14:02:11.632534+00:00", "created_by": "postgres", "request_key": "ccf4fcc5-3879-5efc-87f3-026287288146", "payload_sha256": "b740c73f14094ae8ba76bdeb7297ab245d84ac7a08b3de89e309f75f88db037c", "release_sha256": "e9d24578201d8f0b086e9fc079fb657f5d41364145218d8385e878aa659769ce", "positive_staff_evidence_ref": "/private/tmp/tus-c1266-full86-20261102/db-cause38/FINAL_POSTFLIGHT.json", "authorized_test_manifest_ref": "/private/tmp/tus-c1266-full86-20261102/PLAN.json"}'::jsonb)FROM mission_public_owner.public_qualification_attestations_v1 x WHERE release_sha256='e9d24578201d8f0b086e9fc079fb657f5d41364145218d8385e878aa659769ce')),false)THEN RAISE EXCEPTION 'TACTICS_INTEGRATED_QUALIFICATION_CAS';END IF;
IF NOT coalesce(((SELECT coalesce(jsonb_agg(to_jsonb(x)ORDER BY event_id),'[]'::jsonb)='[{"reason": "Preserve existing authority during reviewed coverage UI grouping correction", "event_id": "3b7a3f5d-b827-5819-b850-50b681814c80", "actor_user": null, "created_at": "2026-11-07T14:02:11.630145+00:00", "profile_key": "mission-ai-authoring/1", "control_version": 1, "runtime_enabled": true, "authoring_enabled": true, "engine_release_sha256": "e9d24578201d8f0b086e9fc079fb657f5d41364145218d8385e878aa659769ce", "expected_control_version": 0}]'::jsonb FROM mission_public_owner.engine_profile_events_v1 x WHERE engine_release_sha256='e9d24578201d8f0b086e9fc079fb657f5d41364145218d8385e878aa659769ce')),false)THEN RAISE EXCEPTION 'TACTICS_INTEGRATED_PROFILES_CAS';END IF;
IF NOT coalesce(((SELECT coalesce(jsonb_agg(to_jsonb(x)ORDER BY request_key),'[]'::jsonb)='[{"payload": {"kind": "compatible_adoption", "PG_count": 2, "PNG_count": 2, "created_at": "2026-11-07T14:02:11.636107+00:00", "created_by": "f0856d53-83a6-4de0-bc0c-12c87916e665", "mission_id": "6d6c216a-222d-4cba-b2fc-f3e0c199c195", "plan_sha256": "285d6315d7a011e970610cb192d6bbbd3cc2b8bd40a6e6d2e843287ee0992199", "request_key": "594e9ce5-2274-52d3-8fa9-bf1be850bfbf", "definition_id": "11bd5367-fc6f-5ec6-bf91-0142b2368824", "config_version": 1, "schema_version": "mission-content-admission/1", "map_refs_sha256": "53e735d376934c0ce6c0155463bcebc8ea59e3c5576dcd5ffc8b3db04a1793ca", "npc_refs_sha256": "3aed0f00241c72371adde5e9dcf7276129f069be212eb0ad31c06785a07e2de7", "plan_version_id": "4da7191e-689f-5aa1-b377-cfdda0da5278", "supported_modes": ["ai"], "capability_sha256": "46d1f0d2c3c0d5769f465e1bdc6ce34ba97d7a485923128729080156bc8b90e7", "definition_sha256": "4124a2ff1cd6e3d61b668ec5b341ed18a5e856e3f6140e6b1c5cf3ae703e5ca8", "media_refs_sha256": "04b0a7d1801e6cdbca4045abd0a8787a771db9dc30c93c4b794f8f6ddcaf3022", "publication_request": "3ff627ec-dbee-423a-9879-8e37f7ad5510", "preview_basis_sha256": "4d2f2f0d49b7d2be79d1c71ade8fdc265674b8bffe7a03a0031e1c131afc5c80", "engine_release_sha256": "e9d24578201d8f0b086e9fc079fb657f5d41364145218d8385e878aa659769ce", "origin_release_sha256": "f7aebda96092a1fd71e26ddda35da84b34e3b0144d14e64ca5da31737feec512", "source_content_sha256": "f5ea8c75ac7ce660f6b29214427d13aa971be9fa576ac246a12890e4a970b605", "validation_contract_sha256": "cd80595f65294072378b3a3bd2ac18148ab75e3099c260562ba1272e04c3f7e3", "required_capabilities_sha256": "49fe134f561273f28e8071b63c45886341371b67d028f06e6b7d8f8d4108e817"}, "created_at": "2026-11-07T14:02:11.636454+00:00", "mission_id": "6d6c216a-222d-4cba-b2fc-f3e0c199c195", "request_key": "594e9ce5-2274-52d3-8fa9-bf1be850bfbf", "config_version": 1, "payload_sha256": "b9de43b31a3ece64088aab7276e0148c4bb90e66a56070491b41420199ffa512", "publication_request": "3ff627ec-dbee-423a-9879-8e37f7ad5510", "engine_release_sha256": "e9d24578201d8f0b086e9fc079fb657f5d41364145218d8385e878aa659769ce"}]'::jsonb FROM mission_public_owner.mission_content_admissions_v1 x WHERE engine_release_sha256='e9d24578201d8f0b086e9fc079fb657f5d41364145218d8385e878aa659769ce')),false)THEN RAISE EXCEPTION 'TACTICS_INTEGRATED_CONTENTS_CAS';END IF;
IF NOT coalesce(((SELECT doc->>'state'='qualified'AND doc->>'ref'IS NOT NULL AND doc->>'sha256'~'^[0-9a-f]{64}$'AND doc->'findings'='{"P0":0,"P1":0,"P2":0}'::jsonb AND doc->>'source_sha256'='70532b3233ce24e12d18396eacb02e71db5a215df46f6ef88f60160a71384cca' FROM pg_temp.tactics_review)),false)THEN RAISE EXCEPTION 'TACTICS_INTEGRATED_FINAL_REVIEW_BINDING';END IF;
END $integrated_pre$;
CREATE TEMP TABLE tactics_custody ON COMMIT DROP AS SELECT clock_timestamp() AS captured_at,jsonb_build_object(
 'real_pg',(SELECT public.combat_v2_sha256(coalesce(jsonb_agg(to_jsonb(c)-'updated_at'-'last_regen_at' ORDER BY c.id),'[]'::jsonb)) FROM public.characters c WHERE c.id IN('6bceee99-974f-426b-8d92-38b43b4a4267'::uuid,'f335b077-34a1-41c3-94aa-58ec674b649b'::uuid,'2a877f02-4993-4e65-9172-7d29f08c5b86'::uuid)),
 'scorta_mission',(SELECT public.combat_v2_sha256(to_jsonb(m)) FROM public.missions m WHERE m.id='db1588ae-50f2-4c0e-9028-0b94155d94b1'::uuid),
 'scorta_masters',(SELECT public.combat_v2_sha256(coalesce(jsonb_agg(to_jsonb(m) ORDER BY m.id),'[]'::jsonb)) FROM public.master_v2_sessions m WHERE m.mission_id='db1588ae-50f2-4c0e-9028-0b94155d94b1'::uuid),
 'gates',jsonb_build_object(
 'innata',(SELECT to_jsonb(g) FROM clan_innata_narrative_private.gate_v1 g WHERE singleton),
 'hyuga',(SELECT to_jsonb(g) FROM clan_hyuga_private.release_gate g WHERE singleton),
 'facing',(SELECT to_jsonb(g) FROM combat_facing_private.release_gate g WHERE singleton),
 'tactics',(SELECT to_jsonb(g) FROM combat_panel_private.multiplication_tactics_release_gate g WHERE singleton)),
 'party',(SELECT p.capture->'custody' FROM (WITH root AS(SELECT revision_sha256,canonical_preimage::jsonb body FROM mission_factory_owner.editor_release_readiness WHERE singleton),
protected_missions(id)AS(VALUES('6d6c216a-222d-4cba-b2fc-f3e0c199c195'::uuid),('db1588ae-50f2-4c0e-9028-0b94155d94b1'::uuid) UNION SELECT mission_id FROM mission_public_owner.party_launch_scopes_v1),
protected_activations(id)AS(SELECT id FROM mission_ai_board_owner.activations WHERE mission_id IN(SELECT id FROM protected_missions))
SELECT jsonb_build_object('schema_version','innata-all-party-live-capture/1','captured_at',clock_timestamp(),'root_revision',(SELECT revision_sha256 FROM root),
'runtime',(SELECT to_jsonb(x)FROM mission_public_owner.party_launch_runtime_v1 x WHERE singleton),
'client_capsule',(SELECT body#>'{config,party_launch_staff_client}'FROM root),
'client_sha256',(SELECT public.combat_v2_sha256(body->'ui')FROM root),
'edge_bundles_sha256',(SELECT public.combat_v2_sha256(body->'edge_bundles')FROM root),
'capsule_client_matches_ui',(SELECT body#>>'{config,party_launch_staff_client,client_sha256}'=public.combat_v2_sha256(body->'ui')FROM root),
'capsule_edge_matches_bundles',(SELECT body#>>'{config,party_launch_staff_client,edge_bundles_sha256}'=public.combat_v2_sha256(body->'edge_bundles')FROM root),
'custody',jsonb_build_object(
'scopes',(SELECT jsonb_build_object('count',count(*),'sha256',public.combat_v2_sha256(coalesce(jsonb_agg(to_jsonb(x)ORDER BY to_jsonb(x)::text),'[]'::jsonb)))FROM mission_public_owner.party_launch_scopes_v1 x),
'bookings',(SELECT jsonb_build_object('count',count(*),'sha256',public.combat_v2_sha256(coalesce(jsonb_agg(to_jsonb(x)ORDER BY to_jsonb(x)::text),'[]'::jsonb)))FROM public.mission_bookings x WHERE mission_id IN(SELECT id FROM protected_missions)),
'activations',(SELECT jsonb_build_object('count',count(*),'sha256',public.combat_v2_sha256(coalesce(jsonb_agg(to_jsonb(x)ORDER BY to_jsonb(x)::text),'[]'::jsonb)))FROM mission_ai_board_owner.activations x WHERE mission_id IN(SELECT id FROM protected_missions)),
'applicants',(SELECT jsonb_build_object('count',count(*),'sha256',public.combat_v2_sha256(coalesce(jsonb_agg(to_jsonb(x)ORDER BY to_jsonb(x)::text),'[]'::jsonb)))FROM mission_ai_board_owner.applicants x WHERE activation_id IN(SELECT id FROM protected_activations)),
'audit',(SELECT jsonb_build_object('count',count(*),'sha256',public.combat_v2_sha256(coalesce(jsonb_agg(to_jsonb(x)ORDER BY to_jsonb(x)::text),'[]'::jsonb)))FROM mission_ai_board_owner.audit x WHERE activation_id IN(SELECT id FROM protected_activations)),
'simulation_sources',(SELECT jsonb_build_object('count',count(*),'sha256',public.combat_v2_sha256(coalesce(jsonb_agg(to_jsonb(x)ORDER BY to_jsonb(x)::text),'[]'::jsonb)))FROM mission_generic_owner.simulation_sources x WHERE source_mission_id='6d6c216a-222d-4cba-b2fc-f3e0c199c195'::uuid OR carrier_mission_id IN(SELECT id FROM protected_missions))
))capture) p)
) AS body;

-- FROZEN CODE MATERIAL: only the separate reviewed aggregate installer is executable.
-- PRIVATE SOURCE ONLY: NOT_INSTALLABLE_ROOT_REVIEW_AND_S16_CLOSE_PENDING.
-- Native future context may descend from admitted origin820c; no future UUID is invented.
-- Do not remove this STOP until exact integrated Root/Admin and independent review qualify the package.
-- Component source STOP is replaced by the aggregate installer STOP.

DO $fenice_cas$ DECLARE expected jsonb;actual jsonb;BEGIN
 IF to_regprocedure('clan_innata_narrative_private.fenice_staff_proof_v1(uuid)')IS NOT NULL THEN RAISE EXCEPTION 'FENICE_HELPER_ALREADY_EXISTS';END IF;
 FOR expected IN SELECT value FROM jsonb_array_elements('[{"oid":665885,"signature":"clan_innata_narrative_private.staff_profile_bind_v1(uuid,uuid)","owner":"postgres","acl":"{postgres=X/postgres}","proconfig":["search_path=\"\""],"prosecdef":true,"provolatile":"v","ddl_md5":"492484888b32bd02c453a604c77a2e15","language":"plpgsql"},{"oid":31311,"signature":"public.combat_v2_actor_ability(uuid,text,uuid,boolean)","owner":"postgres","acl":"{postgres=X/postgres,service_role=X/postgres}","proconfig":["search_path=\"\""],"prosecdef":true,"provolatile":"s","ddl_md5":"ec79a59f561042dee9eac224926afe28","language":"sql"}]'::jsonb)LOOP
 SELECT jsonb_build_object('oid',p.oid::bigint,'signature',replace(n.nspname||'.'||p.proname||'('||oidvectortypes(p.proargtypes)||')',' ',''),
 'owner',pg_get_userbyid(p.proowner),'acl',p.proacl::text,'proconfig',to_jsonb(p.proconfig),'prosecdef',p.prosecdef,'provolatile',p.provolatile,
 'language',l.lanname,'ddl_md5',md5(pg_get_functiondef(p.oid)))INTO actual FROM pg_proc p JOIN pg_namespace n ON n.oid=p.pronamespace
 JOIN pg_language l ON l.oid=p.prolang WHERE p.oid=(expected->>'oid')::oid;
 IF actual IS DISTINCT FROM expected THEN RAISE EXCEPTION 'FENICE_BASELINE_CAS_DRIFT: %',expected->>'signature';END IF;END LOOP;
END $fenice_cas$;


-- SOURCE ONLY, parent Root e9d24578201d8f0b086e9fc079fb657f5d41364145218d8385e878aa659769ce.
-- NOT INSTALLABLE: integrated Root/Admin/review/live CAS and own S16 close proof are required.
-- Component source STOP is replaced by the aggregate installer STOP.

DO $t3_perf_cas$ DECLARE expected jsonb;actual jsonb;BEGIN
 FOR expected IN SELECT value FROM jsonb_array_elements('[{"oid":44935,"schema":"combat_panel_private","proname":"add_choice","args":"p_group uuid, p_label text, p_payload jsonb, p_distance numeric, p_direction text","owner":"postgres","acl":"{postgres=X/postgres}","proconfig":["search_path=\"\""],"prosecdef":true,"provolatile":"v","language":"plpgsql","ddl_md5":"bf10a590d59722b07b08cfa6cee42cce"},{"oid":44934,"schema":"combat_panel_private","proname":"add_group","args":"p_offer uuid, p_label text, p_purpose text, p_mode text, p_min integer, p_max integer, p_dependency uuid","owner":"postgres","acl":"{postgres=X/postgres}","proconfig":["search_path=\"\""],"prosecdef":true,"provolatile":"v","language":"plpgsql","ddl_md5":"c8ab455a415cebf8c64042c969417f02"},{"oid":45632,"schema":"combat_panel_private","proname":"multiplication_add_layout_groups","args":"p_offer uuid, p_dependency uuid, p_layouts jsonb","owner":"postgres","acl":"{postgres=X/postgres}","proconfig":["search_path=\"\""],"prosecdef":true,"provolatile":"v","language":"plpgsql","ddl_md5":"f2515609aa9a224d7f2ff542a3f503c1"},{"oid":44654,"schema":"combat_panel_private","proname":"owned_context","args":"p_context uuid, p_expected bigint","owner":"postgres","acl":"{postgres=X/postgres}","proconfig":["search_path=\"\""],"prosecdef":true,"provolatile":"s","language":"plpgsql","ddl_md5":"0e0b91899d48c1ca7d5a84d7a3c5ab1a"},{"oid":46301,"schema":"combat_panel_private","proname":"body_visible_to_viewer","args":"p_instance uuid, p_actor uuid","owner":"postgres","acl":"{postgres=X/postgres}","proconfig":["search_path=\"\""],"prosecdef":true,"provolatile":"s","language":"plpgsql","ddl_md5":"799e4bca3ff05feb4b94f07992778aa6"},{"oid":45714,"schema":"combat_panel_private","proname":"multiplication_layout_options_for_figure","args":"p_actor uuid, p_copies integer, p_mode text, p_target uuid, p_formation uuid, p_version bigint, p_index integer","owner":"postgres","acl":"{postgres=X/postgres}","proconfig":["search_path=\"\""],"prosecdef":true,"provolatile":"v","language":"plpgsql","ddl_md5":"7b36f3d868c85c3941f120844c286dd9"},{"oid":45633,"schema":"combat_panel_private","proname":"multiplication_offers","args":"p_context uuid, p_expected bigint, p_view jsonb","owner":"postgres","acl":"{postgres=X/postgres}","proconfig":["search_path=\"\""],"prosecdef":true,"provolatile":"v","language":"plpgsql","ddl_md5":"dbbfccc95dade54d951a4a5e62a3806b"},{"oid":45722,"schema":"combat_panel_private","proname":"multiplication_target_geometry_for_body","args":"p_actor uuid, p_target uuid, p_source uuid","owner":"postgres","acl":"{postgres=X/postgres}","proconfig":["search_path=\"\""],"prosecdef":true,"provolatile":"s","language":"plpgsql","ddl_md5":"e73f7c394502436b0a315b5b0ecbd8c8"},{"oid":45638,"schema":"combat_panel_private","proname":"multiplication_target_figure","args":"p_actor uuid, p_target uuid, p_formation uuid, p_version bigint, p_index integer","owner":"postgres","acl":"{postgres=X/postgres}","proconfig":["search_path=\"\""],"prosecdef":true,"provolatile":"s","language":"plpgsql","ddl_md5":"05bdfab8c01966de7b16f5465bc6f010"},{"oid":45637,"schema":"combat_panel_private","proname":"multiplication_target_geometry","args":"p_actor uuid, p_target uuid","owner":"postgres","acl":"{postgres=X/postgres}","proconfig":["search_path=\"\""],"prosecdef":true,"provolatile":"s","language":"plpgsql","ddl_md5":"931416e56edb3af79537a8fd3d4b1be9"},{"oid":45543,"schema":"combat_panel_private","proname":"multiplication_random_figure","args":"p_count integer, p_seed bytea","owner":"postgres","acl":"{postgres=X/postgres}","proconfig":["search_path=\"\""],"prosecdef":true,"provolatile":"i","language":"plpgsql","ddl_md5":"9d90310f9b09edcf34b62bc9c9cdab8c"},{"oid":51621,"schema":"combat_panel_private","proname":"multiplication_tactics_allowed","args":"p_actor uuid","owner":"postgres","acl":"{postgres=X/postgres}","proconfig":["search_path=\"\""],"prosecdef":true,"provolatile":"s","language":"sql","ddl_md5":"86d93a7e6f27d8e7adf6f852f8ef3de3"}]'::jsonb) LOOP
  SELECT jsonb_build_object('oid',p.oid::bigint,'schema',n.nspname,'proname',p.proname,'args',pg_get_function_identity_arguments(p.oid),
   'owner',pg_get_userbyid(p.proowner),'acl',p.proacl::text,'proconfig',to_jsonb(p.proconfig),'prosecdef',p.prosecdef,
   'provolatile',p.provolatile,'language',l.lanname,'ddl_md5',md5(pg_get_functiondef(p.oid))) INTO actual
  FROM pg_proc p JOIN pg_namespace n ON n.oid=p.pronamespace JOIN pg_language l ON l.oid=p.prolang WHERE p.oid=(expected->>'oid')::oid;
  IF actual IS DISTINCT FROM expected THEN RAISE EXCEPTION 'T3_PERF_FUNCTION_CAS_DRIFT: %',expected->>'proname';END IF;
 END LOOP;
 FOR expected IN SELECT value FROM jsonb_array_elements('[{"acl":"{postgres=arwdDxtm/postgres}","oid":44556,"rls":true,"name":"combat_panel_private.choice_groups","owner":"postgres","force_rls":false,"columns_sha":"fee6bc136e517b02de6c6f2acfa0b226","triggers_sha":"d751713988987e9331980363e24189ce","constraints_sha":"533ae9013d64846c1f38d474c7583ed1"},{"acl":"{postgres=arwdDxtm/postgres}","oid":44581,"rls":true,"name":"combat_panel_private.choice_options","owner":"postgres","force_rls":false,"columns_sha":"99db1bcb56a36b28d4206abd37f9ac8e","triggers_sha":"d751713988987e9331980363e24189ce","constraints_sha":"13d7e8c4146413a7e2e35466433b8244"}]'::jsonb) LOOP
  SELECT jsonb_build_object('oid',c.oid::bigint,'name',n.nspname||'.'||c.relname,'owner',pg_get_userbyid(c.relowner),'acl',c.relacl::text,
   'rls',c.relrowsecurity,'force_rls',c.relforcerowsecurity,
   'columns_sha',md5((SELECT jsonb_agg(jsonb_build_object('n',a.attnum,'name',a.attname,'type',pg_catalog.format_type(a.atttypid,a.atttypmod),
    'not_null',a.attnotnull,'default',pg_get_expr(d.adbin,d.adrelid))ORDER BY a.attnum)::text FROM pg_attribute a
    LEFT JOIN pg_attrdef d ON d.adrelid=a.attrelid AND d.adnum=a.attnum WHERE a.attrelid=c.oid AND a.attnum>0 AND NOT a.attisdropped)),
   'constraints_sha',md5((SELECT jsonb_agg(jsonb_build_object('name',co.conname,'def',pg_get_constraintdef(co.oid))ORDER BY co.conname)::text
    FROM pg_constraint co WHERE co.conrelid=c.oid)),
   'triggers_sha',md5(coalesce((SELECT jsonb_agg(pg_get_triggerdef(t.oid)ORDER BY t.tgname)::text FROM pg_trigger t
    WHERE t.tgrelid=c.oid AND NOT t.tgisinternal),'[]'))) INTO actual
  FROM pg_class c JOIN pg_namespace n ON n.oid=c.relnamespace WHERE c.oid=(expected->>'oid')::oid;
  IF actual IS DISTINCT FROM expected THEN RAISE EXCEPTION 'T3_PERF_TABLE_CAS_DRIFT: %',expected->>'name';END IF;
 END LOOP;
END $t3_perf_cas$;


CREATE OR REPLACE FUNCTION clan_innata_narrative_private.fenice_staff_proof_v1(p_actor uuid)
 RETURNS jsonb LANGUAGE plpgsql STABLE SECURITY DEFINER SET search_path TO ''
AS $function$
DECLARE a public.combat_v2_actors;s public.combat_v2_sessions;c clan_innata_narrative_private.contexts_v1;
 origin clan_innata_narrative_private.contexts_v1;t public.clan_techniques;sel jsonb;ability jsonb;prior jsonb;proof jsonb;ids uuid[];controllers uuid[];n integer;valid_chain boolean;
BEGIN
 IF statement_timestamp()<'2026-11-07T19:00:58.461822Z'::timestamptz
 OR statement_timestamp()>='2026-11-07T20:30:58.461822Z'::timestamptz THEN RETURN NULL;END IF;
 SELECT * INTO a FROM public.combat_v2_actors WHERE id=p_actor AND actor_kind='pg' AND companion_id IS NULL AND state='attivo'
 AND character_id='2a877f02-4993-4e65-9172-7d29f08c5b86'::uuid AND controller_user='15448f47-3b43-416f-a703-dbe7a74d36ce'::uuid;
 IF a.id IS NULL THEN RETURN NULL;END IF;
 SELECT * INTO s FROM public.combat_v2_sessions WHERE id=a.session_id;
 SELECT * INTO c FROM clan_innata_narrative_private.contexts_v1 WHERE context_id=(a.mechanics_snapshot#>>'{innata_staff_profile,context_id}')::uuid;
 SELECT * INTO origin FROM clan_innata_narrative_private.contexts_v1 WHERE context_id='820c5cbf-b2da-466b-bd5c-ecd03be8414c'::uuid;
 IF c.context_id IS NULL OR origin.context_id IS NULL OR c.context_id=origin.context_id
 OR s.location_id IS DISTINCT FROM '0b85f354-9cdb-47e1-baf9-3d266bb7e06b'::uuid
 OR s.created_at<'2026-11-07T19:00:58.461822Z'::timestamptz OR s.closed_at IS NOT NULL OR s.state IN('chiusa','annullata','sospeso')
 OR public.combat_v2_values_written(s.id) OR NOT c.active OR c.character_id IS DISTINCT FROM a.character_id
 OR c.location_id IS DISTINCT FROM s.location_id OR c.master_session_id IS DISTINCT FROM s.master_session_id
 OR c.scope_key IS DISTINCT FROM coalesce(c.master_session_id,c.location_id)
 OR(c.bound_combat_session_id IS NOT NULL AND c.bound_combat_session_id<>s.id)
 OR c.staff_ability_profile IS DISTINCT FROM origin.staff_ability_profile
 OR c.staff_ability_profile->>'profile_key' IS DISTINCT FROM 'byakugan-l3'
 OR c.staff_ability_profile->>'version' IS DISTINCT FROM '7'
 OR c.staff_ability_profile->>'created_by' IS DISTINCT FROM a.controller_user::text
 OR clan_innata_narrative_private.staff_profile_actor_v1(a.id)->>'profile_key' IS DISTINCT FROM 'byakugan-l3'
 OR(clan_innata_private.combat_context(a.id)).policy_id IS DISTINCT FROM 'staff_test_no_persistent_resources_v1'
 OR(clan_innata_private.combat_context(a.id)).activity_kind NOT IN('ordinary_v2','master_v2') THEN RETURN NULL;END IF;
 WITH RECURSIVE chain AS(
  SELECT c.context_id id,c.previous_context_id prev,ARRAY[c.context_id]path,true ok,c.created_at node_at
  UNION ALL
  SELECT x.context_id,x.previous_context_id,k.path||x.context_id,
   k.ok AND x.character_id=a.character_id AND x.location_id=s.location_id
   AND x.scope_key=coalesce(x.master_session_id,x.location_id) AND x.created_at<=k.node_at
   AND x.staff_ability_profile=origin.staff_ability_profile
   AND(x.bound_combat_session_id IS NULL OR EXISTS(SELECT 1 FROM public.combat_v2_sessions old
    WHERE old.id=x.bound_combat_session_id AND old.closed_at IS NOT NULL AND old.location_id=s.location_id
    AND NOT public.combat_v2_values_written(old.id))),x.created_at
  FROM chain k JOIN clan_innata_narrative_private.contexts_v1 x ON x.context_id=k.prev
  WHERE k.id<>origin.context_id AND cardinality(k.path)<16 AND NOT x.context_id=ANY(k.path))
 SELECT EXISTS(SELECT 1 FROM chain WHERE id=origin.context_id AND ok)INTO valid_chain;
 IF NOT valid_chain THEN RETURN NULL;END IF;
 SELECT e INTO sel FROM jsonb_array_elements(c.staff_ability_profile->'journal')e
 WHERE e->>'request_key'='707100f5-67b9-456b-8ee6-bda488ecd3fb'
 AND e->>'fingerprint'='87ec8a45674d8309f602710ec29880e2570ccbe1f4e68ba00c9fc91649a29400'
 AND e->>'api_version'='2' AND e#>>'{result,context_id}'='d92a97b8-8484-4957-8ccb-ce61c8920128'
 AND e#>>'{result,profile_version}'='7';
 IF sel IS NULL THEN RETURN NULL;END IF;
 SELECT array_agg(DISTINCT character_id ORDER BY character_id),array_agg(DISTINCT controller_user ORDER BY controller_user),count(*)
 INTO ids,controllers,n FROM public.combat_v2_actors WHERE session_id=s.id AND actor_kind='pg';
 IF n<>2 OR ids IS DISTINCT FROM ARRAY['2a877f02-4993-4e65-9172-7d29f08c5b86'::uuid,'6bceee99-974f-426b-8d92-38b43b4a4267'::uuid]
 OR controllers IS DISTINCT FROM ARRAY['15448f47-3b43-416f-a703-dbe7a74d36ce'::uuid,'f0856d53-83a6-4de0-bc0c-12c87916e665'::uuid]
 OR NOT combat_consumer_private.staff_test_allowed(s.location_id,controllers,false)THEN RETURN NULL;END IF;
 SELECT * INTO t FROM public.clan_techniques WHERE id='6cc40917-1719-4759-9ba8-3064b806c24e'::uuid;
 IF(t.is_active AND t.macro='clan'AND t.clan='Uchiha'AND t.uso='principale'AND t.req_grade='Genin'
 AND t.req_stat='Kekkei Genkai'AND t.req_stat_value=40 AND t.req_tecnica IS NULL AND t.req_elements IS NULL
 AND t.requirements='Grande Palla di Fuoco · grado Genin · Kekkei Genkai ≥ 40'
 AND t.chakra_cost=5 AND t.danno_base=15 AND t.gittata='media'AND t.consumption_type='ad_utilizzo'
 AND NOT t.difensiva AND NOT t.di_scena AND NOT t.is_innata
 AND coalesce((a.mechanics_snapshot->>'kekkei_genkai')::integer,0)>=40
 AND public._grade_rank(clan_innata_narrative_private.staff_profile_actor_v1(a.id)->>'required_grade')>=public._grade_rank('Genin'))IS DISTINCT FROM true
 THEN RETURN NULL;END IF;
 ability:=combat_v2_multitarget_internal.enrich_ability_v1(jsonb_build_object('source','clan','id',t.id,'name',t.name,'kind',t.category,
 'usage',t.uso,'defensive',false,'di_scena',false,'diversivo',false,'consumption_type',t.consumption_type,'range',t.gittata,
 'chakra_cost',t.chakra_cost,'damage_base',t.danno_base,'element','Fuoco'));
 IF ability->'targeting'IS DISTINCT FROM '{"mode":"multi","affects":"enemies_only","geometry":"per_target_line","selection":"manual","max_targets":3,"damage_policy":"full_each","schema_version":"combat-targeting/1.1","geometry_status":"ready"}'::jsonb THEN RETURN NULL;END IF;
 SELECT coalesce(jsonb_agg(x.value ORDER BY x.ordinality),'[]'::jsonb)INTO prior
 FROM jsonb_array_elements(coalesce(a.mechanics_snapshot->'abilities','[]'::jsonb))WITH ORDINALITY x(value,ordinality)
 WHERE NOT(x.value->>'source'='clan'AND x.value->>'id'=t.id::text);
 proof:=jsonb_build_object('schema_version','staff-fenice-dependency/1','campaign','COMBAT-TACTICS-FACING-F3MAX2-20261107',
 'origin_context',origin.context_id,'context_id',c.context_id,'selection_request',sel->'request_key','selection_receipt_sha256',public.combat_v2_sha256(sel),
 'profile_version',7,'actor_id',a.id,'session_id',s.id,'character_id',a.character_id,'controller_user',a.controller_user,'controller_version',a.controller_version,
 'abilities_before_sha256',public.combat_v2_sha256(prior),'ability',ability,'is_test',true,'values_written',false,'chakra_spent',0,'main_action_consumed',false,'statistics_changed',false,
 'simulated_requirements',jsonb_build_object('clan_permission','Uchiha','element_permission','Fuoco','grade_minimum','Genin','kekkei_genkai_minimum',40,
 'prerequisite_permission','1260dbc8-ab0c-4b2b-9b94-909d39b7ffbe','prerequisite_ability_granted',false));
 RETURN proof||jsonb_build_object('sha256',public.combat_v2_sha256(proof));
END $function$;
ALTER FUNCTION clan_innata_narrative_private.fenice_staff_proof_v1(uuid) OWNER TO postgres;
REVOKE ALL ON FUNCTION clan_innata_narrative_private.fenice_staff_proof_v1(uuid) FROM PUBLIC,anon,authenticated,service_role;

CREATE OR REPLACE FUNCTION clan_innata_narrative_private.staff_profile_bind_v1(p_context uuid, p_actor uuid)
 RETURNS void
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO ''
AS $function$
DECLARE c clan_innata_narrative_private.contexts_v1;a public.combat_v2_actors;s public.combat_v2_sessions;d jsonb;mark jsonb;snap jsonb;ability jsonb;prior clan_sabaku_private.reserves;req uuid;fenice jsonb;
BEGIN
 SELECT * INTO STRICT c FROM clan_innata_narrative_private.contexts_v1 WHERE context_id=p_context FOR UPDATE;
 IF c.staff_ability_profile->>'profile_key'IS NULL THEN RETURN;END IF;
 SELECT * INTO STRICT a FROM public.combat_v2_actors WHERE id=p_actor AND character_id=c.character_id AND actor_kind='pg'AND companion_id IS NULL FOR UPDATE;
 SELECT * INTO STRICT s FROM public.combat_v2_sessions WHERE id=a.session_id;
 IF s.location_id IS DISTINCT FROM '0b85f354-9cdb-47e1-baf9-3d266bb7e06b'::uuid OR c.location_id<>s.location_id OR public.combat_v2_values_written(s.id)
 OR NOT EXISTS(SELECT 1 FROM public.characters ch JOIN public.profiles pr ON pr.id=ch.user_id WHERE ch.id=a.character_id AND ch.user_id=a.controller_user
 AND pr.role IN('admin','master')AND c.staff_ability_profile->>'created_by'=ch.user_id::text)
 THEN RAISE EXCEPTION 'INNATA_STAFF_ONLY' USING ERRCODE='42501';END IF;
 d:=clan_innata_narrative_private.profile_definition_v2(c.staff_ability_profile->>'profile_key');
 IF EXISTS(SELECT 1 FROM clan_innata_narrative_private.states_v1 WHERE context_id=c.context_id AND active AND technique_id<>(d->>'technique_id')::uuid)
 THEN RAISE EXCEPTION 'INNATA_PROFILE_ACTIVE' USING ERRCODE='55000';END IF;
 mark:=jsonb_build_object('context_id',c.context_id,'profile_version',(c.staff_ability_profile->>'version')::bigint,'profile_key',d->'profile_key','technique_id',d->'technique_id',
 'actor_id',a.id,'session_id',s.id,'character_id',a.character_id,'controller_user',a.controller_user);
 IF d->>'lifecycle_kind'='passive_permission'THEN
  snap:=a.mechanics_snapshot;
  SELECT coalesce(jsonb_agg(x ORDER BY x->>'name'),'[]'::jsonb)INTO ability FROM jsonb_array_elements(coalesce(snap->'abilities','[]'::jsonb))x
   WHERE NOT(x->>'source'='clan'AND x->>'id' IN('94c45ec9-78c7-423e-9045-4b4cf2104b15','d2d98dad-fb9f-4ff1-b6b2-3d3f2d222fae','6d264e00-1db3-4daa-b7cc-e5f011e1dab1','2fb3e027-a4ff-4058-9d5d-0212facb3f68','bc2569b5-eab4-44b4-9843-c199724caff4','09097efd-e162-4cae-a644-5e643fe94f8c','dd2026b4-bffc-490e-8646-be411d4746b3','fdf79ce1-1c5b-44c4-aaa1-789be08e01de','ed808bc6-57f6-4853-80bf-9e6985ca0cc3','41254b82-5b5e-46e9-9820-b3d604bbe38f','2fb9e210-225d-460a-a9f9-39ee64f8fce1','ab64415a-cca3-472f-9203-84ad60c09405','4a527ff2-0420-4da9-bc1f-5489c753b285','8e20bafe-cb3c-4967-b9c7-2a4bca694996','9b384de3-35f0-43c0-b145-94f985fa758a','a50808fa-e7cd-45ee-b4d4-33ad8c65d472','b0748ef4-bea8-4d85-95a1-7d9db1b4381c','843031ac-521a-4c5b-832e-37a0398a9862','537945fc-b7a3-4661-8144-e3fbcd6b24d0','d48b7246-44bf-4ecc-a4dc-a9bb705c331a','4d742b75-2592-4379-81c0-07ddf436f32b','6e4b8efc-e324-404a-a8c7-b4c39b8070b8','559606f3-f3a0-401d-9e8c-7685624bb880','7fef3cc6-ec43-49a2-a740-cd9f4ee1c31a','20341270-6241-45cd-9633-437d3ce80447','32d0749c-6167-45da-8880-bb3f60dd401f','a4704025-1ef8-43c9-9e5b-113582a7e621','6c56bb2f-4936-4c43-873e-dde65fe42d2b','001f907c-8f32-4758-8a16-ad1730e72c59','e6cc70fa-7ef3-4eaf-afb7-4ca6f588c2b4','efd15ad1-c1ae-4495-aaa5-0f9415f4be0a','e0456437-21d5-4a04-9d8a-9bffbf87c26d','4056f62d-77f3-47f9-8ecb-9a7799682a9d','65b30dec-6f9f-459e-b78c-49173d74f251','f3673da7-42c9-497e-abe1-1c0982429f35','1ab6d359-f337-45ed-839c-4e626d2e2819'));
  ability:=ability||jsonb_build_array(jsonb_build_object('source','clan','id',d->'technique_id','name',d->'name','kind','abilita',
   'usage','passiva','consumption_type','passiva','chakra_cost',NULL,'defensive',false,'di_scena',false,'diversivo',false));
  snap:=jsonb_set(snap,'{abilities}',ability,true)||jsonb_build_object('innata_staff_profile',mark,'innata_staff_required_grade',d->'required_grade',
   'innata_permission_fact',clan_innata_narrative_private.permission_fact_v2(c.context_id));
  -- Permission does not alter statistics; required KG/grade remain simulated eligibility metadata only.
  UPDATE public.combat_v2_actors SET mechanics_snapshot=snap WHERE id=a.id;
  IF clan_innata_narrative_private.staff_profile_actor_v1(a.id)IS NULL THEN RAISE EXCEPTION 'INNATA_PERMISSION_BIND_INVALID' USING ERRCODE='42501';END IF;
  RETURN;
 END IF;
 SELECT jsonb_build_object('source','clan','id',t.id,'name',t.name,'kind',coalesce(t.category,'fisico'),'usage',t.uso,'defensive',coalesce(t.difensiva,false),
 'di_scena',coalesce(t.di_scena,false),'diversivo',false,'consumption_type','per_turno','range',t.gittata,'chakra_cost',q.activation_cost,'damage_base',coalesce(t.danno_base,0))INTO ability
 FROM public.clan_techniques t JOIN clan_innata_narrative_private.config_quotes_v1 q ON q.technique_id=t.id WHERE t.id=(d->>'technique_id')::uuid;
 SELECT coalesce(jsonb_agg(x ORDER BY x->>'name'),'[]'::jsonb)INTO snap FROM jsonb_array_elements(coalesce(a.mechanics_snapshot->'abilities','[]'::jsonb))x
 WHERE NOT EXISTS(SELECT 1 FROM public.clan_techniques t WHERE t.id::text=x->>'id'AND x->>'source'='clan'AND(t.is_innata OR t.id IN('94c45ec9-78c7-423e-9045-4b4cf2104b15'::uuid,'d2d98dad-fb9f-4ff1-b6b2-3d3f2d222fae'::uuid,'6d264e00-1db3-4daa-b7cc-e5f011e1dab1'::uuid,'2fb3e027-a4ff-4058-9d5d-0212facb3f68'::uuid,'bc2569b5-eab4-44b4-9843-c199724caff4'::uuid,'09097efd-e162-4cae-a644-5e643fe94f8c'::uuid,'dd2026b4-bffc-490e-8646-be411d4746b3'::uuid,'fdf79ce1-1c5b-44c4-aaa1-789be08e01de'::uuid,'ed808bc6-57f6-4853-80bf-9e6985ca0cc3'::uuid,'41254b82-5b5e-46e9-9820-b3d604bbe38f'::uuid,'2fb9e210-225d-460a-a9f9-39ee64f8fce1'::uuid,'ab64415a-cca3-472f-9203-84ad60c09405'::uuid,'4a527ff2-0420-4da9-bc1f-5489c753b285'::uuid,'8e20bafe-cb3c-4967-b9c7-2a4bca694996'::uuid,'9b384de3-35f0-43c0-b145-94f985fa758a'::uuid,'a50808fa-e7cd-45ee-b4d4-33ad8c65d472'::uuid,'b0748ef4-bea8-4d85-95a1-7d9db1b4381c'::uuid,'843031ac-521a-4c5b-832e-37a0398a9862'::uuid,'537945fc-b7a3-4661-8144-e3fbcd6b24d0'::uuid,'d48b7246-44bf-4ecc-a4dc-a9bb705c331a'::uuid,'4d742b75-2592-4379-81c0-07ddf436f32b'::uuid,'6e4b8efc-e324-404a-a8c7-b4c39b8070b8'::uuid,'559606f3-f3a0-401d-9e8c-7685624bb880'::uuid,'7fef3cc6-ec43-49a2-a740-cd9f4ee1c31a'::uuid,'20341270-6241-45cd-9633-437d3ce80447'::uuid,'32d0749c-6167-45da-8880-bb3f60dd401f'::uuid,'a4704025-1ef8-43c9-9e5b-113582a7e621'::uuid,'6c56bb2f-4936-4c43-873e-dde65fe42d2b'::uuid,'001f907c-8f32-4758-8a16-ad1730e72c59'::uuid,'e6cc70fa-7ef3-4eaf-afb7-4ca6f588c2b4'::uuid,'efd15ad1-c1ae-4495-aaa5-0f9415f4be0a'::uuid,'e0456437-21d5-4a04-9d8a-9bffbf87c26d'::uuid,'4056f62d-77f3-47f9-8ecb-9a7799682a9d'::uuid,'65b30dec-6f9f-459e-b78c-49173d74f251'::uuid,'f3673da7-42c9-497e-abe1-1c0982429f35'::uuid,'1ab6d359-f337-45ed-839c-4e626d2e2819'::uuid)));
 snap:=jsonb_set(a.mechanics_snapshot,'{abilities}',snap||jsonb_build_array(ability),false);
 snap:=jsonb_set(snap,'{kekkei_genkai}',to_jsonb((d->>'required_kg')::integer),false);
 snap:=snap||jsonb_build_object('innata_staff_profile',mark,'innata_staff_required_grade',d->'required_grade');
 UPDATE public.combat_v2_actors SET mechanics_snapshot=snap WHERE id=a.id;
 req:=extensions.uuid_generate_v5(c.context_id,a.id::text||':innata-profile:'||(c.staff_ability_profile->>'version'));
 IF d->>'profile_key'='sabaku-l1' THEN
  INSERT INTO clan_sabaku_private.staff_profiles(session_id,actor_id,request_id,receipt_id,bind_result)
  VALUES(s.id,a.id,req,req,jsonb_build_object('operation','staff_profile','profile_context',c.context_id,'profile_version',c.staff_ability_profile->'version','is_test',true,'values_written',false));
  IF NOT EXISTS(SELECT 1 FROM clan_sabaku_private.reserves WHERE session_id=s.id AND actor_id=a.id AND is_test)THEN
   SELECT r.* INTO prior FROM clan_sabaku_private.reserves r JOIN public.combat_v2_sessions cs ON cs.id=r.session_id
   WHERE r.character_id=a.character_id AND r.is_test AND cs.location_id=s.location_id AND cs.closed_at IS NOT NULL ORDER BY cs.closed_at DESC LIMIT 1;
   INSERT INTO clan_sabaku_private.reserves(character_id,session_id,actor_id,is_test,capacity,current_amount)
   VALUES(a.character_id,s.id,a.id,true,15,CASE WHEN prior.id IS NULL THEN 15 ELSE least(15,prior.current_amount)END);
  END IF;
 ELSE
  INSERT INTO clan_hyuga_private.staff_profiles(session_id,actor_id,profile_version,created_request,is_active)
  VALUES(s.id,a.id,(d->>'profile_key')||'/1',req,true);
 END IF;
 IF clan_innata_narrative_private.staff_profile_actor_v1(a.id)IS NULL THEN RAISE EXCEPTION 'INNATA_PROFILE_BIND_INVALID' USING ERRCODE='42501';END IF;
 fenice:=clan_innata_narrative_private.fenice_staff_proof_v1(a.id);
 IF fenice IS NOT NULL THEN
  SELECT mechanics_snapshot INTO snap FROM public.combat_v2_actors WHERE id=a.id FOR UPDATE;
  IF snap ? 'fenice_staff_dependency'AND snap->'fenice_staff_dependency'IS DISTINCT FROM fenice
  THEN RAISE EXCEPTION 'FENICE_RECEIPT_CONFLICT' USING ERRCODE='22023';END IF;
  SELECT coalesce(jsonb_agg(x.value ORDER BY x.ordinality),'[]'::jsonb)INTO ability
  FROM jsonb_array_elements(snap->'abilities')WITH ORDINALITY x(value,ordinality)
  WHERE NOT(x.value->>'source'='clan'AND x.value->>'id'='6cc40917-1719-4759-9ba8-3064b806c24e');
  UPDATE public.combat_v2_actors SET mechanics_snapshot=jsonb_set(snap,'{abilities}',ability||jsonb_build_array(fenice->'ability'),false)
   ||jsonb_build_object('fenice_staff_dependency',fenice)WHERE id=a.id;
 END IF;

END $function$
;

CREATE OR REPLACE FUNCTION public.combat_v2_actor_ability(p_actor uuid, p_source text, p_ability uuid, p_defense boolean DEFAULT false)
 RETURNS jsonb
 LANGUAGE sql
 STABLE SECURITY DEFINER
 SET search_path TO ''
AS $function$
 SELECT CASE WHEN p_source='clan'AND p_ability='6cc40917-1719-4759-9ba8-3064b806c24e'::uuid
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

CREATE OR REPLACE FUNCTION combat_panel_private.multiplication_add_layout_groups(p_offer uuid, p_dependency uuid, p_layouts jsonb)
 RETURNS void
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO ''
AS $function$
DECLARE held_offer combat_panel_private.offers%ROWTYPE;held_context combat_panel_private.contexts%ROWTYPE;optimized_batch boolean:=false;
 staged_groups combat_panel_private.choice_groups[]:=ARRAY[]::combat_panel_private.choice_groups[];
 staged_options combat_panel_private.choice_options[]:=ARRAY[]::combat_panel_private.choice_options[];
 choice_ordinals jsonb:='{}'::jsonb;group_ordinal integer;choice_ordinal integer;staged_choice uuid;
 direction_group uuid; direction_option uuid; layout_group uuid; layout_option uuid; original_group uuid;
 layout jsonb; original jsonb; dir record; label text; private_index integer; private_figures jsonb;
BEGIN
 IF jsonb_typeof(p_layouts) IS DISTINCT FROM 'array' OR jsonb_array_length(p_layouts)=0 THEN
   RAISE EXCEPTION 'panel_multiplication_layouts_missing' USING ERRCODE='22023'; END IF;
 -- Same owner/state/context authority as add_group, held for the complete batch.
 SELECT * INTO STRICT held_offer FROM combat_panel_private.offers WHERE id=p_offer
  AND principal_user=exam_regia_private.current_principal() AND state='offered' FOR UPDATE;
 held_context:=combat_panel_private.owned_context(held_offer.context_id,held_offer.context_version);
 optimized_batch:=combat_panel_private.multiplication_tactics_allowed(held_context.command_actor_id);
 SELECT coalesce(max(ordinal)+1,0) INTO group_ordinal
  FROM combat_panel_private.choice_groups WHERE offer_id=held_offer.id;
 IF EXISTS(SELECT 1 FROM jsonb_array_elements(p_layouts) x WHERE x->>'endpoint_layout'='true') THEN
  IF EXISTS(SELECT 1 FROM jsonb_array_elements(p_layouts) x WHERE x->>'endpoint_layout' IS DISTINCT FROM 'true') THEN
   RAISE EXCEPTION 'panel_multiplication_endpoint_layout_mixed' USING ERRCODE='22023'; END IF;
  -- Il raggruppamento nativo può associare più capability allo stesso layout.
  -- Ogni alternativa resta una scelta distinta, con il proprio insieme bersagli sigillato.
  IF EXISTS(SELECT 1 FROM jsonb_array_elements(p_layouts) l
    WHERE jsonb_typeof(l->'original_options') IS DISTINCT FROM 'array'
       OR jsonb_array_length(l->'original_options')=0) THEN
   RAISE EXCEPTION 'panel_multiplication_endpoint_original_invalid' USING ERRCODE='22023'; END IF;
  SELECT jsonb_agg(jsonb_set(l.value,'{original_options}',jsonb_build_array(o.value))
    ORDER BY l.ordinal,o.ordinal) INTO p_layouts
   FROM jsonb_array_elements(p_layouts) WITH ORDINALITY l(value,ordinal)
   CROSS JOIN LATERAL jsonb_array_elements(l.value->'original_options') WITH ORDINALITY o(value,ordinal);
  IF optimized_batch THEN
   direction_group:=pg_catalog.gen_random_uuid();
   staged_groups:=array_append(staged_groups,ROW(direction_group,p_offer,'Distanza dal bersaglio','single','movement_direction',1,1,p_dependency,group_ordinal)::combat_panel_private.choice_groups);
   group_ordinal:=group_ordinal+1;
  ELSE
   direction_group:=combat_panel_private.add_group(p_offer,'Distanza dal bersaglio','movement_direction','single',1,1,p_dependency);
  END IF;
  FOR dir IN SELECT DISTINCT (value->>'target_distance_m')::integer AS gap FROM jsonb_array_elements(p_layouts) ORDER BY gap LOOP
   IF dir.gap NOT IN (0,1,2) THEN RAISE EXCEPTION 'panel_multiplication_endpoint_gap_invalid' USING ERRCODE='22023';END IF;
   IF optimized_batch THEN
    direction_option:=pg_catalog.gen_random_uuid();
    choice_ordinal:=coalesce((choice_ordinals->>(direction_group)::text)::integer,0);
    staged_options:=array_append(staged_options,ROW(direction_option,p_offer,direction_group,'Termina a '||dir.gap||' m',dir.gap,NULL,'{}'::jsonb,choice_ordinal)::combat_panel_private.choice_options);
    choice_ordinals:=jsonb_set(choice_ordinals,ARRAY[(direction_group)::text],to_jsonb(choice_ordinal+1),true);
   ELSE
    direction_option:=combat_panel_private.add_choice(direction_group,'Termina a '||dir.gap||' m','{}'::jsonb,dir.gap,NULL);
   END IF;
   IF optimized_batch THEN
    layout_group:=pg_catalog.gen_random_uuid();
    staged_groups:=array_append(staged_groups,ROW(layout_group,p_offer,'Punto d’arrivo','single','movement_distance',1,1,direction_option,group_ordinal)::combat_panel_private.choice_groups);
    group_ordinal:=group_ordinal+1;
   ELSE
    layout_group:=combat_panel_private.add_group(p_offer,'Punto d’arrivo','movement_distance','single',1,1,direction_option);
   END IF;
   FOR layout IN SELECT value FROM jsonb_array_elements(p_layouts) WHERE (value->>'target_distance_m')::integer=dir.gap
    ORDER BY (value->>'extent_m')::numeric,(value->>'endpoint_x_m')::numeric,(value->>'endpoint_y_m')::numeric LOOP
    IF jsonb_array_length(layout->'original_options')<>1 THEN RAISE EXCEPTION 'panel_multiplication_endpoint_original_invalid' USING ERRCODE='22023';END IF;
    -- Permutazione solo dopo l'aggregazione native draw_layouts e prima del payload offerta.
    -- La geometria canonica interna non viene consegnata con indiceoriginale fisso.
    private_index:=combat_panel_private.multiplication_random_figure(jsonb_array_length(layout->'figures'),extensions.gen_random_bytes(32));
    SELECT jsonb_agg((f.value-'figure_index')||jsonb_build_object('figure_index',
       1+mod((f.value->>'figure_index')::integer+private_index-2,jsonb_array_length(layout->'figures')))
       ORDER BY 1+mod((f.value->>'figure_index')::integer+private_index-2,jsonb_array_length(layout->'figures')))
     INTO private_figures FROM jsonb_array_elements(layout->'figures') f;
    IF optimized_batch THEN
     layout_option:=pg_catalog.gen_random_uuid();
     choice_ordinal:=coalesce((choice_ordinals->>(layout_group)::text)::integer,0);
     staged_options:=array_append(staged_options,ROW(layout_option,p_offer,layout_group,'Arrivo ('||(layout->>'endpoint_x_m')||', '||(layout->>'endpoint_y_m')||') · percorso '||(layout->>'extent_m')||' m',(layout->>'extent_m')::numeric,NULL::text,jsonb_build_object('multiplication_figures',private_figures),choice_ordinal)::combat_panel_private.choice_options);
     choice_ordinals:=jsonb_set(choice_ordinals,ARRAY[(layout_group)::text],to_jsonb(choice_ordinal+1),true);
    ELSE
     layout_option:=combat_panel_private.add_choice(layout_group,'Arrivo ('||(layout->>'endpoint_x_m')||', '||(layout->>'endpoint_y_m')||') · percorso '||(layout->>'extent_m')||' m',
      jsonb_build_object('multiplication_figures',private_figures),(layout->>'extent_m')::numeric);
    END IF;
    IF optimized_batch THEN
     original_group:=pg_catalog.gen_random_uuid();
     staged_groups:=array_append(staged_groups,ROW(original_group,p_offer,'Originale · arrivo scelto','single','generic',1,1,layout_option,group_ordinal)::combat_panel_private.choice_groups);
     group_ordinal:=group_ordinal+1;
    ELSE
     original_group:=combat_panel_private.add_group(p_offer,'Originale · arrivo scelto','generic','single',1,1,layout_option);
    END IF;
    original:=(layout->'original_options'->0)||jsonb_build_object('figure_index',private_index);
    IF optimized_batch THEN
     staged_choice:=pg_catalog.gen_random_uuid();
     choice_ordinal:=coalesce((choice_ordinals->>(original_group)::text)::integer,0);
     staged_options:=array_append(staged_options,ROW(staged_choice,p_offer,original_group,'Arrivo selezionato · distanza finale '||(original->>'target_distance_m')||' m',(original->>'distance_m')::numeric,NULL::text,jsonb_build_object('multiplication_original',original->'figure_index','multiplication_movement_capability_id',original->'movement_capability_id',
        'multiplication_endpoint_gap_m',original->'target_distance_m','multiplication_endpoint_contract','assault-endpoint/1')
       ||CASE WHEN original ? 'assault_draw' THEN jsonb_build_object('multiplication_assault_draw',original->'assault_draw') ELSE '{}'::jsonb END,choice_ordinal)::combat_panel_private.choice_options);
     choice_ordinals:=jsonb_set(choice_ordinals,ARRAY[(original_group)::text],to_jsonb(choice_ordinal+1),true);
    ELSE
     PERFORM combat_panel_private.add_choice(original_group,'Arrivo selezionato · distanza finale '||(original->>'target_distance_m')||' m',
      jsonb_build_object('multiplication_original',original->'figure_index','multiplication_movement_capability_id',original->'movement_capability_id',
        'multiplication_endpoint_gap_m',original->'target_distance_m','multiplication_endpoint_contract','assault-endpoint/1')
       ||CASE WHEN original ? 'assault_draw' THEN jsonb_build_object('multiplication_assault_draw',original->'assault_draw') ELSE '{}'::jsonb END,
      (original->>'distance_m')::numeric);
    END IF;
   END LOOP;
  END LOOP;
 IF optimized_batch THEN
 -- Native same-offer dependency FK is DEFERRABLE INITIALLY DEFERRED.
 -- All new parent groups exist before inserting their options; no constraint is disabled.
 INSERT INTO combat_panel_private.choice_groups(id,offer_id,label,selection_mode,purpose,min_selected,max_selected,depends_on,ordinal)
  SELECT r.id,r.offer_id,r.label,r.selection_mode,r.purpose,r.min_selected,r.max_selected,r.depends_on,r.ordinal
  FROM unnest(staged_groups) r;
 INSERT INTO combat_panel_private.choice_options(id,offer_id,group_id,label,distance_m,direction,source_payload,ordinal)
  SELECT r.id,r.offer_id,r.group_id,r.label,r.distance_m,r.direction,r.source_payload,r.ordinal
  FROM unnest(staged_options) r;
 END IF;
  RETURN;
 END IF;
 IF optimized_batch THEN
  direction_group:=pg_catalog.gen_random_uuid();
  staged_groups:=array_append(staged_groups,ROW(direction_group,p_offer,'Direzione delle figure','single','movement_direction',1,1,p_dependency,group_ordinal)::combat_panel_private.choice_groups);
  group_ordinal:=group_ordinal+1;
 ELSE
  direction_group:=combat_panel_private.add_group(p_offer,'Direzione delle figure','movement_direction','single',1,1,p_dependency);
 END IF;
 FOR dir IN SELECT DISTINCT value->>'direction' AS code FROM jsonb_array_elements(p_layouts) ORDER BY code LOOP
   label:=CASE dir.code WHEN 'up' THEN 'Nord' WHEN 'down' THEN 'Sud' WHEN 'right' THEN 'Est' WHEN 'left' THEN 'Ovest' END;
   IF label IS NULL THEN RAISE EXCEPTION 'panel_multiplication_direction_invalid' USING ERRCODE='22023'; END IF;
   IF optimized_batch THEN
    direction_option:=pg_catalog.gen_random_uuid();
    choice_ordinal:=coalesce((choice_ordinals->>(direction_group)::text)::integer,0);
    staged_options:=array_append(staged_options,ROW(direction_option,p_offer,direction_group,label,NULL,dir.code,'{}'::jsonb,choice_ordinal)::combat_panel_private.choice_options);
    choice_ordinals:=jsonb_set(choice_ordinals,ARRAY[(direction_group)::text],to_jsonb(choice_ordinal+1),true);
   ELSE
    direction_option:=combat_panel_private.add_choice(direction_group,label,'{}'::jsonb,NULL,dir.code);
   END IF;
   IF optimized_batch THEN
    layout_group:=pg_catalog.gen_random_uuid();
    staged_groups:=array_append(staged_groups,ROW(layout_group,p_offer,'Disposizione delle figure','single','movement_distance',1,1,direction_option,group_ordinal)::combat_panel_private.choice_groups);
    group_ordinal:=group_ordinal+1;
   ELSE
    layout_group:=combat_panel_private.add_group(p_offer,'Disposizione delle figure','movement_distance','single',1,1,direction_option);
   END IF;
   FOR layout IN SELECT value FROM jsonb_array_elements(p_layouts) WHERE value->>'direction'=dir.code ORDER BY (value->>'extent_m')::numeric LOOP
     IF optimized_batch THEN
      layout_option:=pg_catalog.gen_random_uuid();
      choice_ordinal:=coalesce((choice_ordinals->>(layout_group)::text)::integer,0);
      staged_options:=array_append(staged_options,ROW(layout_option,p_offer,layout_group,'Figure fino a '||(layout->>'extent_m')||' m',(layout->>'extent_m')::numeric,NULL::text,jsonb_build_object('multiplication_figures',layout->'figures'),choice_ordinal)::combat_panel_private.choice_options);
      choice_ordinals:=jsonb_set(choice_ordinals,ARRAY[(layout_group)::text],to_jsonb(choice_ordinal+1),true);
     ELSE
      layout_option:=combat_panel_private.add_choice(layout_group,'Figure fino a '||(layout->>'extent_m')||' m',
       jsonb_build_object('multiplication_figures',layout->'figures'),(layout->>'extent_m')::numeric);
     END IF;
     IF optimized_batch THEN
      original_group:=pg_catalog.gen_random_uuid();
      staged_groups:=array_append(staged_groups,ROW(original_group,p_offer,'Originale · scelta privata','single','generic',1,1,layout_option,group_ordinal)::combat_panel_private.choice_groups);
      group_ordinal:=group_ordinal+1;
     ELSE
      original_group:=combat_panel_private.add_group(p_offer,'Originale · scelta privata','generic','single',1,1,layout_option);
     END IF;
     FOR original IN SELECT value FROM jsonb_array_elements(layout->'original_options') ORDER BY (value->>'figure_index')::integer LOOP
       IF optimized_batch THEN
        staged_choice:=pg_catalog.gen_random_uuid();
        choice_ordinal:=coalesce((choice_ordinals->>(original_group)::text)::integer,0);
        staged_options:=array_append(staged_options,ROW(staged_choice,p_offer,original_group,'Figura '||(original->>'figure_index')||CASE WHEN original->>'target_distance_m' IS NOT NULL THEN ' · termina a '||(original->>'target_distance_m')||' m' ELSE ' · spostamento '||round((original->>'distance_m')::numeric,2)||' m' END,(original->>'distance_m')::numeric,NULL::text,jsonb_build_object('multiplication_original',original->'figure_index','multiplication_movement_capability_id',original->'movement_capability_id')
          ||CASE WHEN original ? 'assault_draw' THEN jsonb_build_object('multiplication_assault_draw',original->'assault_draw') ELSE '{}'::jsonb END,choice_ordinal)::combat_panel_private.choice_options);
        choice_ordinals:=jsonb_set(choice_ordinals,ARRAY[(original_group)::text],to_jsonb(choice_ordinal+1),true);
       ELSE
        PERFORM combat_panel_private.add_choice(original_group,'Figura '||(original->>'figure_index')||CASE WHEN original->>'target_distance_m' IS NOT NULL THEN ' · termina a '||(original->>'target_distance_m')||' m' ELSE ' · spostamento '||round((original->>'distance_m')::numeric,2)||' m' END,
         jsonb_build_object('multiplication_original',original->'figure_index','multiplication_movement_capability_id',original->'movement_capability_id')
          ||CASE WHEN original ? 'assault_draw' THEN jsonb_build_object('multiplication_assault_draw',original->'assault_draw') ELSE '{}'::jsonb END,
         (original->>'distance_m')::numeric);
       END IF;
     END LOOP;
   END LOOP;
 END LOOP;
 IF optimized_batch THEN
 -- Native same-offer dependency FK is DEFERRABLE INITIALLY DEFERRED.
 -- All new parent groups exist before inserting their options; no constraint is disabled.
 INSERT INTO combat_panel_private.choice_groups(id,offer_id,label,selection_mode,purpose,min_selected,max_selected,depends_on,ordinal)
  SELECT r.id,r.offer_id,r.label,r.selection_mode,r.purpose,r.min_selected,r.max_selected,r.depends_on,r.ordinal
  FROM unnest(staged_groups) r;
 INSERT INTO combat_panel_private.choice_options(id,offer_id,group_id,label,distance_m,direction,source_payload,ordinal)
  SELECT r.id,r.offer_id,r.group_id,r.label,r.distance_m,r.direction,r.source_payload,r.ordinal
  FROM unnest(staged_options) r;
 END IF;
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
 reuse_target_geometry boolean:=false;valid boolean; can_move boolean; x numeric; y numeric; d numeric; target_radius numeric; target_gap numeric; key text; prefix text; cid uuid;
BEGIN
 IF exam_regia_private.current_principal() IS NULL THEN RAISE EXCEPTION 'panel_authentication_required' USING ERRCODE='28000'; END IF;
 IF num_nonnulls(p_formation,p_version,p_index) NOT IN (0,3)
   OR (p_formation IS NOT NULL AND p_mode NOT IN ('assalto','copertura')) THEN
   RAISE EXCEPTION 'panel_multiplication_target_selection_invalid' USING ERRCODE='22023'; END IF;
 IF p_mode IS NULL OR p_mode NOT IN ('diversivo','copertura','assalto')
   OR (p_mode IN ('assalto','copertura')) IS DISTINCT FROM (p_target IS NOT NULL) THEN
   RAISE EXCEPTION 'panel_multiplication_mode_invalid' USING ERRCODE='22023'; END IF;
 SELECT * INTO STRICT a FROM public.combat_v2_actors WHERE id=p_actor AND exam_regia_private.actor_principal(id,controller_user)=exam_regia_private.current_principal()
   AND companion_id IS NULL AND state='attivo';
 reuse_target_geometry:=combat_panel_private.multiplication_tactics_allowed(a.id);
 IF p_mode<>'assalto' AND NOT reuse_target_geometry THEN RETURN layouts; END IF;
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
 IF p_mode IN ('assalto','copertura') THEN
   IF NOT EXISTS(SELECT 1 FROM public.combat_v2_actors t WHERE t.id=p_target AND t.session_id=a.session_id AND t.state='attivo' AND t.team_key<>a.team_key)
     OR ((NOT reuse_target_geometry OR p_formation IS NULL)
      AND NOT combat_panel_private.body_visible_to_viewer(i.instance_id,p_target)) THEN RETURN layouts; END IF;
   -- Released formed-target geometry below verifies canonical visibility once.
   -- Scopes not admitted by the existing Tactics gate keep legacy helper calls.
   IF p_formation IS NOT NULL THEN
     IF NOT EXISTS(SELECT 1 FROM combat_panel_private.multiplication_formations f
       WHERE f.id=p_formation AND f.actor_id=p_target AND f.state='active' AND f.state_version=p_version
         AND f.mode IN ('copertura','diversivo','assalto')) THEN RETURN layouts; END IF;
     IF reuse_target_geometry THEN
     target_geometry:=combat_panel_private.multiplication_target_geometry(a.id,p_target);
     IF target_geometry IS NULL THEN
       -- Preserve invisible -> no layout, and visible stale -> 40001.
       IF NOT combat_panel_private.body_visible_to_viewer(i.instance_id,p_target) THEN RETURN layouts; END IF;
       RAISE EXCEPTION 'panel_multiplication_target_stale' USING ERRCODE='40001';
     END IF;
     IF target_geometry->>'formation_id' IS DISTINCT FROM p_formation::text
       OR target_geometry->>'state_version' IS DISTINCT FROM p_version::text THEN
       RAISE EXCEPTION 'panel_multiplication_target_stale' USING ERRCODE='40001';END IF;
     SELECT value INTO figure FROM jsonb_array_elements(target_geometry->'figures')
       WHERE (value->>'figure_index')::integer=p_index;
     IF figure IS NULL THEN RAISE EXCEPTION 'panel_multiplication_target_figure_invalid' USING ERRCODE='22023';END IF;
     target_geometry:=(target_geometry-'figures')||jsonb_build_object('figure',figure);
     ELSE
     target_geometry:=combat_panel_private.multiplication_target_figure(a.id,p_target,p_formation,p_version,p_index);
     END IF;
     target_x:=(target_geometry#>>'{figure,x_m}')::numeric;target_y:=(target_geometry#>>'{figure,y_m}')::numeric;
   ELSE
     IF EXISTS(SELECT 1 FROM combat_panel_private.multiplication_formations WHERE actor_id=p_target AND state='active') THEN RETURN layouts; END IF;
     SELECT tb.x_m,tb.y_m INTO STRICT target_x,target_y FROM combat_spatial.actor_states tb
       WHERE tb.instance_id=i.instance_id AND tb.actor_id=p_target AND tb.state='active';
   END IF;
   SELECT footprint_radius_m INTO STRICT target_radius FROM combat_spatial.actor_states WHERE instance_id=i.instance_id AND actor_id=p_target AND state='active';
 END IF;
 IF p_mode='assalto' THEN
  -- Scope congelato: niente movimento+Assalto verso una copia distante.
  -- Le figure gia' nella portata fisica attuale restano selezionabili.
  IF p_formation IS NOT NULL
    AND (target_x-b.x_m)^2+(target_y-b.y_m)^2>(b.footprint_radius_m+target_radius+2)^2 THEN
   RETURN '[]'::jsonb;
  END IF;
  RETURN combat_panel_private.multiplication_assault_endpoint_layouts(i.instance_id,a.id,p_target,
   target_x,target_y,target_radius,CASE WHEN can_move THEN least(remaining,5) ELSE 0 END,
   'assalto:'||rid||':'||coalesce(p_formation::text,'-')||':'||coalesce(p_version,0)||':'||coalesce(p_index,0),
   p_copies,(profile->>'copy_cap')::integer);
 END IF;
 prefix:='multiplication:'||(profile->>'round_id')||':'||b.body_version||':'||remaining||':';
 IF p_mode='copertura' THEN
  prefix:='multiplication-cover:'||p_target||':'||coalesce(p_formation::text,'-')||':'||coalesce(p_version,0)||':'||coalesce(p_index,0)
    ||':'||(profile->>'round_id')||':'||b.body_version||':'||remaining||':';
 END IF;
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
    IF p_mode='copertura' AND (d<>5
      OR (x-b.x_m)*(target_x-b.x_m)+(y-b.y_m)*(target_y-b.y_m)>=0
      OR combat_spatial.distance_m(x,y,target_x,target_y)<=combat_spatial.distance_m(b.x_m,b.y_m,target_x,target_y)) THEN CONTINUE; END IF;
    IF p_mode='assalto' AND (round(greatest(0,combat_spatial.distance_m(x,y,target_x,target_y)-b.footprint_radius_m-target_radius),8) NOT IN (0,1,2)
      OR (x-b.x_m)*(target_x-b.x_m)+(y-b.y_m)*(target_y-b.y_m)<0
      OR (target_x-x)*(target_x-b.x_m)+(target_y-y)*(target_y-b.y_m)<0
      OR combat_spatial.path_first_block_t(i.instance_id,a.id,x,y,target_x,target_y,p_target)<1) THEN CONTINUE; END IF;
    key:=prefix||md5(jsonb_build_object('x',x,'y',y)::text);
    target_gap:=CASE WHEN p_mode='assalto' THEN round(greatest(0,combat_spatial.distance_m(x,y,target_x,target_y)-b.footprint_radius_m-target_radius),8) ELSE NULL END;
    available:=available||jsonb_build_array(jsonb_build_object('figure_index',figure->'figure_index','choice_key',key,'distance_m',d,'target_distance_m',target_gap,'x_m',x,'y_m',y));
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
      'distance_m',option_row->'distance_m','target_distance_m',option_row->'target_distance_m','movement_capability_id',cid)); END IF;
  END LOOP;
  IF jsonb_array_length(available)>0 THEN bound:=bound||jsonb_build_array(jsonb_set(layout,'{original_options}',available)); END IF;
 END LOOP;
 RETURN bound;
END $function$;

-- SOURCE ONLY: exact derived seal metadata member, integrated after the five qualified functional DDL.
-- No arbitrary expected SHA. Old code/ABI/CAS are fixed; new member is derived from the already-qualified actor's actual normalized DDL.
DO $eligibility_seal_pre$ BEGIN
 IF NOT coalesce((SELECT jsonb_build_object('oid',p.oid::bigint,'signature',replace(n.nspname||'.'||p.proname||'('||oidvectortypes(p.proargtypes)||')',' ',''),
 'owner',pg_get_userbyid(p.proowner),'acl',p.proacl::text,'proconfig',to_jsonb(p.proconfig),'prosecdef',p.prosecdef,'volatility',p.provolatile::text,
 'parallel',p.proparallel::text,'strict',p.proisstrict,'leakproof',p.proleakproof,'arg_types',p.proargtypes::text,'all_arg_types',to_jsonb(p.proallargtypes),
 'arg_names',to_jsonb(p.proargnames),'arg_modes',to_jsonb(p.proargmodes),'nargs',p.pronargs,'default_arg_count',p.pronargdefaults,
 'defaults',pg_get_expr(p.proargdefaults,0),'return_oid',p.prorettype::text,'returns_set',p.proretset,'variadic_type',p.provariadic::text,
 'arguments',pg_get_function_arguments(p.oid),'returns',pg_get_function_result(p.oid),'language',l.lanname,
 'ddl_md5',md5(pg_get_functiondef(p.oid)),'source_md5',md5(p.prosrc))
 FROM pg_proc p JOIN pg_namespace n ON n.oid=p.pronamespace JOIN pg_language l ON l.oid=p.prolang WHERE p.oid=41419)='{"oid":41419,"signature":"clan_innata_private.eligibility_release_assert()","owner":"postgres","acl":"{postgres=X/postgres}","proconfig":["search_path=pg_catalog, public, clan_innata_private"],"prosecdef":true,"volatility":"s","parallel":"u","strict":false,"leakproof":false,"arg_types":"","all_arg_types":null,"arg_names":null,"arg_modes":null,"nargs":0,"default_arg_count":0,"defaults":null,"return_oid":"2278","returns_set":false,"variadic_type":"0","arguments":"","returns":"void","language":"plpgsql","ddl_md5":"8de6ce1265be1420cc2e89479a8bac98","source_md5":"0c3c825c5b71f775ca7dc51f2ebdbf85"}'::jsonb,false)THEN RAISE EXCEPTION 'ELIGIBILITY_SEAL_BASELINE_CAS';END IF;
 IF encode(extensions.digest(convert_to(pg_get_functiondef(41419),'UTF8'),'sha256'),'hex')<>'1fbfe144883e6ecbe40c59d74c7c30ff347cb49ccda3f17e876a157921a7d993' THEN RAISE EXCEPTION 'ELIGIBILITY_SEAL_BASELINE_FULL_SHA';END IF;
END $eligibility_seal_pre$;
DO $eligibility_seal_derive$
DECLARE before_ddl text;before_src text;actor_sha text;after_ddl text;after_src text;
BEGIN
 IF NOT coalesce((SELECT jsonb_build_object('oid',p.oid::bigint,'signature',replace(n.nspname||'.'||p.proname||'('||oidvectortypes(p.proargtypes)||')',' ',''),
 'owner',pg_get_userbyid(p.proowner),'acl',p.proacl::text,'proconfig',to_jsonb(p.proconfig),'prosecdef',p.prosecdef,'volatility',p.provolatile::text,
 'parallel',p.proparallel::text,'strict',p.proisstrict,'leakproof',p.proleakproof,'arg_types',p.proargtypes::text,'all_arg_types',to_jsonb(p.proallargtypes),
 'arg_names',to_jsonb(p.proargnames),'arg_modes',to_jsonb(p.proargmodes),'nargs',p.pronargs,'default_arg_count',p.pronargdefaults,
 'defaults',pg_get_expr(p.proargdefaults,0),'return_oid',p.prorettype::text,'returns_set',p.proretset,'variadic_type',p.provariadic::text,
 'arguments',pg_get_function_arguments(p.oid),'returns',pg_get_function_result(p.oid),'language',l.lanname,
 'ddl_md5',md5(pg_get_functiondef(p.oid)),'source_md5',md5(p.prosrc))
 FROM pg_proc p JOIN pg_namespace n ON n.oid=p.pronamespace JOIN pg_language l ON l.oid=p.prolang WHERE p.oid=41419)='{"oid":41419,"signature":"clan_innata_private.eligibility_release_assert()","owner":"postgres","acl":"{postgres=X/postgres}","proconfig":["search_path=pg_catalog, public, clan_innata_private"],"prosecdef":true,"volatility":"s","parallel":"u","strict":false,"leakproof":false,"arg_types":"","all_arg_types":null,"arg_names":null,"arg_modes":null,"nargs":0,"default_arg_count":0,"defaults":null,"return_oid":"2278","returns_set":false,"variadic_type":"0","arguments":"","returns":"void","language":"plpgsql","ddl_md5":"8de6ce1265be1420cc2e89479a8bac98","source_md5":"0c3c825c5b71f775ca7dc51f2ebdbf85"}'::jsonb,false)THEN RAISE EXCEPTION 'ELIGIBILITY_SEAL_BASELINE_CAS';END IF;
 IF NOT coalesce((SELECT jsonb_build_object('oid',p.oid::bigint,'signature',replace(n.nspname||'.'||p.proname||'('||oidvectortypes(p.proargtypes)||')',' ',''),
 'owner',pg_get_userbyid(p.proowner),'acl',p.proacl::text,'proconfig',to_jsonb(p.proconfig),'prosecdef',p.prosecdef,'volatility',p.provolatile::text,
 'parallel',p.proparallel::text,'strict',p.proisstrict,'leakproof',p.proleakproof,'arg_types',p.proargtypes::text,'all_arg_types',to_jsonb(p.proallargtypes),
 'arg_names',to_jsonb(p.proargnames),'arg_modes',to_jsonb(p.proargmodes),'nargs',p.pronargs,'default_arg_count',p.pronargdefaults,
 'defaults',pg_get_expr(p.proargdefaults,0),'return_oid',p.prorettype::text,'returns_set',p.proretset,'variadic_type',p.provariadic::text,
 'arguments',pg_get_function_arguments(p.oid),'returns',pg_get_function_result(p.oid),'language',l.lanname,
 'ddl_md5',md5(pg_get_functiondef(p.oid)),'source_md5',md5(p.prosrc))
 FROM pg_proc p JOIN pg_namespace n ON n.oid=p.pronamespace JOIN pg_language l ON l.oid=p.prolang WHERE p.oid=31311)-'ddl_md5'='{"oid":31311,"signature":"public.combat_v2_actor_ability(uuid,text,uuid,boolean)","owner":"postgres","acl":"{postgres=X/postgres,service_role=X/postgres}","proconfig":["search_path=\"\""],"prosecdef":true,"volatility":"s","parallel":"u","strict":false,"leakproof":false,"arg_types":"2950 25 2950 16","all_arg_types":null,"arg_names":["p_actor","p_source","p_ability","p_defense"],"arg_modes":null,"nargs":4,"default_arg_count":1,"defaults":"false","return_oid":"3802","returns_set":false,"variadic_type":"0","arguments":"p_actor uuid, p_source text, p_ability uuid, p_defense boolean DEFAULT false","returns":"jsonb","language":"sql","source_md5":"b6180f3bc0d3ec90d2c18dac3c6f54e8"}'::jsonb,false)THEN RAISE EXCEPTION 'ELIGIBILITY_ACTOR_APPROVED_SOURCE_ABI_REQUIRED';END IF;
 SELECT pg_get_functiondef(p.oid),p.prosrc INTO STRICT before_ddl,before_src FROM pg_proc p WHERE p.oid=41419;
 IF encode(extensions.digest(convert_to(before_ddl,'UTF8'),'sha256'),'hex')<>'1fbfe144883e6ecbe40c59d74c7c30ff347cb49ccda3f17e876a157921a7d993'
 OR(length(before_ddl)-length(replace(before_ddl,'b2f5397b7fba0fe0ce6a12d9e07a0164a2364507aacfc3327d0da7be1ad9e74a','')))/64<>1
 OR(length(before_src)-length(replace(before_src,'b2f5397b7fba0fe0ce6a12d9e07a0164a2364507aacfc3327d0da7be1ad9e74a','')))/64<>1 THEN RAISE EXCEPTION 'ELIGIBILITY_SEAL_PROVENANCE';END IF;
 actor_sha:=encode(extensions.digest(convert_to(pg_get_functiondef(31311),'UTF8'),'sha256'),'hex');
 IF actor_sha!~'^[0-9a-f]{64}$'OR actor_sha='b2f5397b7fba0fe0ce6a12d9e07a0164a2364507aacfc3327d0da7be1ad9e74a' THEN RAISE EXCEPTION 'ELIGIBILITY_DERIVED_ACTOR_MEMBER_INVALID';END IF;
 EXECUTE replace(before_ddl,'b2f5397b7fba0fe0ce6a12d9e07a0164a2364507aacfc3327d0da7be1ad9e74a',actor_sha);
 SELECT pg_get_functiondef(p.oid),p.prosrc INTO STRICT after_ddl,after_src FROM pg_proc p WHERE p.oid=41419;
 IF after_ddl IS DISTINCT FROM replace(before_ddl,'b2f5397b7fba0fe0ce6a12d9e07a0164a2364507aacfc3327d0da7be1ad9e74a',actor_sha)
 OR after_src IS DISTINCT FROM replace(before_src,'b2f5397b7fba0fe0ce6a12d9e07a0164a2364507aacfc3327d0da7be1ad9e74a',actor_sha)
 OR((SELECT jsonb_build_object('oid',p.oid::bigint,'signature',replace(n.nspname||'.'||p.proname||'('||oidvectortypes(p.proargtypes)||')',' ',''),
 'owner',pg_get_userbyid(p.proowner),'acl',p.proacl::text,'proconfig',to_jsonb(p.proconfig),'prosecdef',p.prosecdef,'volatility',p.provolatile::text,
 'parallel',p.proparallel::text,'strict',p.proisstrict,'leakproof',p.proleakproof,'arg_types',p.proargtypes::text,'all_arg_types',to_jsonb(p.proallargtypes),
 'arg_names',to_jsonb(p.proargnames),'arg_modes',to_jsonb(p.proargmodes),'nargs',p.pronargs,'default_arg_count',p.pronargdefaults,
 'defaults',pg_get_expr(p.proargdefaults,0),'return_oid',p.prorettype::text,'returns_set',p.proretset,'variadic_type',p.provariadic::text,
 'arguments',pg_get_function_arguments(p.oid),'returns',pg_get_function_result(p.oid),'language',l.lanname,
 'ddl_md5',md5(pg_get_functiondef(p.oid)),'source_md5',md5(p.prosrc))
 FROM pg_proc p JOIN pg_namespace n ON n.oid=p.pronamespace JOIN pg_language l ON l.oid=p.prolang WHERE p.oid=41419)-ARRAY['ddl_md5','source_md5'])IS DISTINCT FROM('{"oid":41419,"signature":"clan_innata_private.eligibility_release_assert()","owner":"postgres","acl":"{postgres=X/postgres}","proconfig":["search_path=pg_catalog, public, clan_innata_private"],"prosecdef":true,"volatility":"s","parallel":"u","strict":false,"leakproof":false,"arg_types":"","all_arg_types":null,"arg_names":null,"arg_modes":null,"nargs":0,"default_arg_count":0,"defaults":null,"return_oid":"2278","returns_set":false,"variadic_type":"0","arguments":"","returns":"void","language":"plpgsql","ddl_md5":"8de6ce1265be1420cc2e89479a8bac98","source_md5":"0c3c825c5b71f775ca7dc51f2ebdbf85"}'::jsonb-ARRAY['ddl_md5','source_md5'])
 THEN RAISE EXCEPTION 'ELIGIBILITY_SEAL_EXACT_SUBSTITUTION_REQUIRED';END IF;
END $eligibility_seal_derive$;

CREATE TEMP TABLE tactics_projected ON COMMIT DROP AS -- SOURCE_ONLY. READONLY SELECT for the owner AFTER the reviewed Fenice DDL in one transaction.
-- Not executed by this generator; returns zero rows until all three source/ABI/ACL guards match.
WITH targets(signature,expected_source_md5,old_ddl_md5,contract,expected_oid) AS(VALUES
('clan_innata_narrative_private.fenice_staff_proof_v1(uuid)','6ebcfee584480f0b6129789e631044d6',NULL,'{"acl": "{postgres=X/postgres}", "owner": "postgres", "config": ["search_path=\"\""], "secdef": true, "strict": false, "language": "plpgsql", "parallel": "u", "leakproof": false, "volatility": "s"}'::jsonb,NULL),
('clan_innata_narrative_private.staff_profile_bind_v1(uuid,uuid)','547bdbb6bda2165fa7a29e798491825b','492484888b32bd02c453a604c77a2e15','{"acl": "{postgres=X/postgres}", "owner": "postgres", "config": ["search_path=\"\""], "secdef": true, "strict": false, "language": "plpgsql", "parallel": "u", "leakproof": false, "volatility": "v"}'::jsonb,'665885'),
('clan_innata_private.eligibility_release_assert()',md5(replace('
declare v_marionetta boolean:=false; v_panel boolean:=false;
begin

 -- La porta pubblica aggiornata è ammessa solo insieme al suo producer
 -- originale privato e alla redazione esatta: corpi, autorità e ACL pinzati.
 with expected(sig,sha,acl) as(values (''public.combat_v2_round_options(uuid,uuid)'',''0b3acc15933027fa840ca03c0d02f082aecf6f2ccedcdefd737127bed1d853d1'',''authenticated:EXECUTE:false,postgres:EXECUTE:false,service_role:EXECUTE:false''),(''combat_panel_private.round_options_authoritative(uuid,uuid)'',''879b5d69f1ca6a8f9cc28421699b77d649e3e277f4130a40308ca3acfc8a895c'',''postgres:EXECUTE:false''),(''combat_panel_private.mask_native_state(jsonb)'',''1d2f6ad44b2ff1e9c15d897e38fee54b67c744411081f906bc33a26a42600dac'',''postgres:EXECUTE:false'')),
 observed as(select e.*,p.oid,p.proowner,p.prosecdef,p.proconfig,
   case when p.oid is null then null else encode(extensions.digest(convert_to(pg_get_functiondef(p.oid),''UTF8''),''sha256''),''hex'') end actual_sha,
   (select string_agg(coalesce(r.rolname,''PUBLIC'')||'':''||x.privilege_type||'':''||x.is_grantable,'','' order by coalesce(r.rolname,''PUBLIC''),x.privilege_type,x.is_grantable)
     from aclexplode(coalesce(p.proacl,acldefault(''f'',p.proowner))) x left join pg_roles r on r.oid=x.grantee) actual_acl
   from expected e left join pg_proc p on p.oid=to_regprocedure(e.sig))
 select count(*)=3 and bool_and(coalesce(oid is not null and actual_sha=sha and actual_acl=acl
   and proowner=''postgres''::regrole and prosecdef and proconfig=array[''search_path=""''],false))
 into v_panel from observed;
 if exists(select 1 from supabase_migrations.schema_migrations where name=''marionetta_ordinary_staff_001'' or version=''20260907084651'') then
   if (select count(*) from supabase_migrations.schema_migrations where name=''marionetta_ordinary_staff_001'' or version=''20260907084651'')<>1
     or not exists(select 1 from supabase_migrations.schema_migrations where version=''20260907084651'' and name=''marionetta_ordinary_staff_001''
       and cardinality(statements)=1 and encode(extensions.digest(convert_to(array_to_string(statements,''''),''UTF8''),''sha256''),''hex'')=''3d3b6643c1b513728ee8e2366fbde983aa374cf9d330f0976d71c5f122318f17'') then
     raise exception ''runtime_eligibility_marionetta_release_drift''; end if;
   v_marionetta:=true;
 end if;
 if (select count(*) from supabase_migrations.schema_migrations where version=''20260902055751'' and name=''genin_elemental_eligibility_common_009'' and cardinality(statements)=1 and encode(extensions.digest(convert_to(array_to_string(statements,''''),''UTF8''),''sha256''),''hex'')=''e2ca4e296401307496cdc1ed108f4cf22ee4469a34072172c7b9855063a97c2e'')<>1
 or (select count(*) from supabase_migrations.schema_migrations where version between ''20260902005704'' and ''20260902055751'')<>4
 or (select count(*) from supabase_migrations.schema_migrations where name=''clan_genin_innata_common_release_seal_eligibility_018'')>1
 or ((select count(*) from supabase_migrations.schema_migrations where name=''clan_genin_innata_common_release_seal_eligibility_018'')=0 and ((select count(*) from supabase_migrations.schema_migrations)<>452 or (select version from supabase_migrations.schema_migrations order by version desc limit 1) is distinct from ''20260902055751''))
 or ((select count(*) from supabase_migrations.schema_migrations where name=''clan_genin_innata_common_release_seal_eligibility_018'')=1 and not exists(select 1 from supabase_migrations.schema_migrations where name=''clan_genin_innata_common_release_seal_eligibility_018'' and version~''^[0-9]{14}$'' and version>''20260902055751'' and cardinality(statements)=1))
 then raise exception ''runtime_eligibility_history_drift'';end if;
 if to_regnamespace(''combat_v2_elemental_internal'') is null
 or (select count(*) from pg_proc p where p.pronamespace=''combat_v2_elemental_internal''::regnamespace)<>91
 or (select pg_get_userbyid(n.nspowner)||''|''||coalesce(n.nspacl::text,'''') from pg_namespace n where n.oid=''combat_v2_elemental_internal''::regnamespace) is distinct from ''postgres|{postgres=UC/postgres,service_role=U/postgres}''
 then raise exception ''runtime_eligibility_schema_drift'';end if;

 -- Rilascio Suiton verificato: insieme chiuso di 35 helper aggiuntivi.
 -- I due helper storici mantengono le verifiche originali sottostanti.
 if (select count(*) from supabase_migrations.schema_migrations
     where version=''20260912191445'' and name=''elementali_staff_suiton_install_20260912_1912''
       and cardinality(statements)=1
       and encode(extensions.digest(convert_to(array_to_string(statements,''''),''UTF8''),''sha256''),''hex'')=''e7bd1cb6dea7505399fc9dbce5b39ec5078eb9474f55990def7502a68fbbdb18'')<>1
 then raise exception ''runtime_eligibility_suiton_release_drift'';end if;
 if exists(
  with expected(sig,sha,definer) as(values
   (''combat_v2_elemental_internal.comparison_channels(uuid,uuid,uuid,jsonb,integer,uuid)'', ''4db77777b8277750fb1468b8789915facbf71864d81f2647dedad6a0d40f26f8'', true),
   (''combat_v2_elemental_internal.comparison_reserve(uuid,uuid,uuid)'', ''712095a7757a2828bed68307408edba803169e8465b1f31b62e3b408b04749df'', true),
   (''combat_v2_elemental_internal.suiton_ability_meta(uuid,jsonb)'', ''8856c83e2aac23fbac02b3fa893caf0f0809234bf8a7ff42aeac6b246db14838'', true),
   (''combat_v2_elemental_internal.suiton_bind_source(uuid)'', ''1fd85f165e897d3e90ddb0f04bc2c5523b73587f26d1037e0ab45635ac1208f5'', true),
   (''combat_v2_elemental_internal.suiton_commit_control(jsonb,jsonb)'', ''aca8de9ce4d1caf737ea789d11aeb5de4e8a55be2840f4700eb0daaa8b5357dc'', true),
   (''combat_v2_elemental_internal.suiton_commit_master_control(jsonb)'', ''8e3dc679cced28892d6270a5310d49b975b9da9e483cfff635140db331e0e43d'', true),
   (''combat_v2_elemental_internal.suiton_consumer_options(jsonb)'', ''82231c040ab41b619f29616499fad90e6d6efebfc614bebe67e8b91c82081ca5'', true),
   (''combat_v2_elemental_internal.suiton_control_apply(text,uuid,uuid,uuid)'', ''15c8ce32ece8af8c407bac7e46fbbb414184fd87bfb3e1238a3b4e461f43ba39'', true),
   (''combat_v2_elemental_internal.suiton_control_target(text,uuid,uuid)'', ''83833b6ff5f114c3b870c3767565d00ea829bbf85f02606f034e197e4c37ab03'', true),
   (''combat_v2_elemental_internal.suiton_declaration_meta(uuid,uuid,uuid,jsonb)'', ''7b13ed2ad7acc320c88350a5ec0fd2d9155614f51b5ea6682094e88e6bfbba36'', true),
   (''combat_v2_elemental_internal.suiton_draw_range(uuid,uuid,boolean)'', ''b178d00a882a8e2cff719795874d1a553e4478f0369ef6eb5a9ed4e20ccb71f4'', true),
   (''combat_v2_elemental_internal.suiton_force_from_outcome(uuid,uuid)'', ''aa3b68e633cc12f401505a6ba3492e92e94c44598940bf90e7c70473e90ca7f0'', true),
   (''combat_v2_elemental_internal.suiton_geometry(uuid,uuid,boolean)'', ''422ce58f19b0c0d9692fbf639f409f54b45d054b6c3f01e580b8be1f43222288'', true),
   (''combat_v2_elemental_internal.suiton_master_options(uuid,bigint)'', ''a2359c02aaeb2192ecef01fae57d05f6fb548d0c245380494915427341499d5f'', true),
   (''combat_v2_elemental_internal.suiton_meta(uuid)'', ''65375ebe226f598927e0873b228d0daaa9f239249f6b2e9196ad4ae5a2282f7b'', true),
   (''combat_v2_elemental_internal.suiton_narrative_facts(uuid)'', ''b6936b0bd08eee059ae94cffcdd3c2e7319b3aa6f7430e38a91bfc088cd49901'', true),
   (''combat_v2_elemental_internal.suiton_narrative_projection(uuid)'', ''d34e9dc4d467ab47f8a263d837b8f00d6f0f3f02c7b59d1b4063ce1aa7022276'', true),
   (''combat_v2_elemental_internal.suiton_narrative_supported(uuid)'', ''660838edb1eef2ba8afbab180edf21ec295170aa36b0122e163fc17c59f42a48'', true),
   (''combat_v2_elemental_internal.suiton_offer_label(uuid,jsonb,text)'', ''71ef19352a96939de8a8034cc821f79326a0d33eb0fa4c673a4aabe6f8aa1fe0'', true),
   (''combat_v2_elemental_internal.suiton_ordinary_copy_offers(uuid,bigint,jsonb)'', ''3392390a180bee9b10b58495a32d889d05da52cfdec5611c47c7769599fbaef5'', true),
   (''combat_v2_elemental_internal.suiton_png_owned(uuid,uuid)'', ''b2d3877e7497adbdc4a76139d2627ac0744b192a0823d54dbc90afaabf6bd659'', true),
   (''combat_v2_elemental_internal.suiton_prepare_callback(text,uuid,uuid,uuid,uuid[],jsonb,jsonb)'', ''973b09c57a37f9721e216f8dfd4b1e0dbfc29d80c8cb4615a175603366e36c87'', true),
   (''combat_v2_elemental_internal.suiton_prepare_master(uuid,uuid,uuid[],jsonb,jsonb)'', ''9ef708a90471da085ffb0d804f31a010f021ce227d43b40060ecd8e7cb707b12'', true),
   (''combat_v2_elemental_internal.suiton_prepare_native(uuid,uuid,uuid,jsonb,boolean,jsonb)'', ''1b5986868ba2679c2ebd8dbf824a22cee4190ec4c0e17852d089ab8093e78655'', true),
   (''combat_v2_elemental_internal.suiton_prepare_ordinary(uuid,uuid,uuid)'', ''b3c5628855bd2c213c268d209219559a362c67f399133e15186eaf3e78497ad3'', true),
   (''combat_v2_elemental_internal.suiton_preset_ready(uuid,uuid)'', ''c65ac30e5d1b1a8bf88ee73e636a15da683f9ae3f97c124ae9b5b9199a386ec7'', true),
   (''combat_v2_elemental_internal.suiton_profile(uuid,uuid)'', ''f8174ccbe1808bedc756e452c4fb8cf7cd9f9f6629fe627ed473b36d516a65c6'', true),
   (''combat_v2_elemental_internal.suiton_quote(uuid,uuid)'', ''900157dfaaf19810d4d21a4138a9a63c77ae6cc460d0d296425556a6efa653a1'', true),
   (''combat_v2_elemental_internal.suiton_source_valid(uuid)'', ''d937562a6537b70bf92233e0f3a3182ff346a93c7a586d73139febe7370d5969'', true),
   (''combat_v2_elemental_internal.suiton_staff_bind(uuid,uuid,uuid)'', ''09bcc66bf8d7cf5e5f04f41cc6b071841a6472d9cf45d750f789d679fdf3a576'', true),
   (''combat_v2_elemental_internal.suiton_staff_binding(uuid,uuid)'', ''fbbf2c198e245b92424046ed58bc79c7b2d4ff440e82722ab90187de89d20152'', true),
   (''combat_v2_elemental_internal.suiton_substitution_available(uuid)'', ''7535c6c3c7366a23e22f697c5eb20bf8e3cd422208909881ab32327106b5ee1a'', true),
   (''combat_v2_elemental_internal.suiton_substitution_options(jsonb)'', ''3d07b691098cdf4b698ed8822ab4c554de722a90d586b917dad59a0131fe3aaa'', true),
   (''combat_v2_elemental_internal.suiton_target_visible(uuid,uuid,numeric)'', ''5eff813391e64689028888e8449b89abcf2486601428e72c5917e59ffb72769d'', true),
   (''combat_v2_elemental_internal.technique_profile_v1(uuid)'', ''6446b74bbe092d8627820dc064d778aaf188eec6c7dd28e79e985843b995bd93'', false)),
  observed as(select e.*,p.oid,p.proowner,p.prosecdef,p.proconfig,
   case when p.oid is null then null else encode(extensions.digest(convert_to(pg_get_functiondef(p.oid),''UTF8''),''sha256''),''hex'') end actual_sha,
   (select string_agg(coalesce(r.rolname,''PUBLIC'')||'':''||x.privilege_type||'':''||x.is_grantable,'','' order by coalesce(r.rolname,''PUBLIC''),x.privilege_type,x.is_grantable)
    from aclexplode(coalesce(p.proacl,acldefault(''f'',p.proowner))) x left join pg_roles r on r.oid=x.grantee) actual_acl
   from expected e left join pg_proc p on p.oid=to_regprocedure(e.sig))
  select 1 from observed where oid is null or actual_sha is distinct from sha
   or proowner is distinct from ''postgres''::regrole or prosecdef is distinct from definer
   or proconfig is distinct from array[''search_path=""'']
   or actual_acl is distinct from ''postgres:EXECUTE:false''
 ) then raise exception ''runtime_eligibility_suiton_helper_drift'';end if;

 if exists(
  with expected(sig,sha,acl) as(values
   (''combat_v2_elemental_internal.is_target_v1(uuid)'',''8af6bdfc87b76ed118b596f7c7885c6de849c5d89140f61cdd1845047cbd5724'',''postgres:EXECUTE:false,service_role:EXECUTE:false''),
   (''combat_v2_elemental_internal.eligible_v1(uuid,uuid,boolean)'',''a5161f2993a4e0ce51864ac67ea88ba3fa6966457da1caf4ca390f17c2b1d8e9'',''postgres:EXECUTE:false,service_role:EXECUTE:false''),
   (''public.combat_v2_character_snapshot(uuid)'',case when v_marionetta then ''20c680c16a5ba1adedada1b9dcb6b5ee2f91bf01ddbdd9c0d40064d9d2d57ee3'' else ''323d6dd5a1cfac2ad6535fb73a4aefb03d33c7aa2894b9196489c17880046f87'' end,''postgres:EXECUTE:false,service_role:EXECUTE:false''),
   (''public.combat_v2_actor_ability(uuid,text,uuid,boolean)'',''b2f5397b7fba0fe0ce6a12d9e07a0164a2364507aacfc3327d0da7be1ad9e74a'',''postgres:EXECUTE:false,service_role:EXECUTE:false''),
   (''public.combat_v2_round_options(uuid,uuid)'',case when v_panel then ''0b3acc15933027fa840ca03c0d02f082aecf6f2ccedcdefd737127bed1d853d1'' when v_marionetta then ''6b9012a057baa9bc06b201ce6bcc5b8d8bb4a832ae9a462444c5e3ef55e0c8cb'' else ''3be90b0da7f02c826ffdfcd594d2132a4af9128291e3417278ad6adac88f6129'' end,''authenticated:EXECUTE:false,postgres:EXECUTE:false,service_role:EXECUTE:false'')),
  observed as(select e.*,encode(extensions.digest(convert_to(pg_get_functiondef(e.sig::regprocedure),''UTF8''),''sha256''),''hex'') actual_sha,p.proowner,p.prosecdef,p.proconfig,(select string_agg(coalesce(r.rolname,''PUBLIC'')||'':''||x.privilege_type||'':''||x.is_grantable,'','' order by coalesce(r.rolname,''PUBLIC''),x.privilege_type,x.is_grantable) from aclexplode(coalesce(p.proacl,acldefault(''f'',p.proowner))) x left join pg_roles r on r.oid=x.grantee) actual_acl from expected e join pg_proc p on p.oid=e.sig::regprocedure)
  select 1 from observed where actual_sha is distinct from sha or actual_acl is distinct from acl or proowner<>''postgres''::regrole or not prosecdef or proconfig is distinct from array[''search_path=""''])
 then raise exception ''runtime_eligibility_full_seal_drift'';end if;
 if encode(extensions.digest(convert_to(pg_get_functiondef(''public.character_elementi(uuid)''::regprocedure),''UTF8''),''sha256''),''hex'') is distinct from ''2e62fad3aa654ab452c516549ca82068dd33f6496a3c1e17e3a8c805a8ddacd7''
 then raise exception ''runtime_eligibility_character_elementi_drift'';end if;

 IF EXISTS(WITH expected(sig,hash,sd) AS (VALUES (''combat_v2_elemental_internal.other_meta(uuid)'',''18a6130387a81b22c993feaaf2613612'',true),(''combat_v2_elemental_internal.other_staff_binding(uuid,uuid)'',''cb15a27f82e60cf2ace2f22de4ca1e73'',true),(''combat_v2_elemental_internal.other_png_owned(uuid,uuid)'',''1730fa382f3f2da21b05ba43e1876330'',true),(''combat_v2_elemental_internal.other_profile(uuid,uuid)'',''f71b7422e1af07cfb2784137d5d05f03'',true),(''combat_v2_elemental_internal.other_ability_meta(uuid,jsonb)'',''07a3babec6e05865d9265b09c22d0859'',true),(''combat_v2_elemental_internal.other_staff_bind(uuid,uuid,uuid)'',''a4fb778f33ab73c31e63904f51299985'',true),(''combat_v2_elemental_internal.other_geometry(uuid,uuid,pg_catalog.bool)'',''8776c899d5534308eb256de2ba451ae8'',true),(''combat_v2_elemental_internal.other_prepare_native(uuid,uuid,uuid,jsonb,pg_catalog.bool,jsonb)'',''0e93d6425a2e8a151765040279758310'',true),(''combat_v2_elemental_internal.other_declaration_meta(uuid,uuid,uuid,jsonb)'',''d37f38beb455ecfbcda7a63962013542'',true),(''combat_v2_elemental_internal.other_bind_source(uuid)'',''35714da91f1df0f2d90d5921099e1177'',true),(''combat_v2_elemental_internal.other_source_valid(uuid)'',''20b96bb421f4bfbd3eb74a33294a3080'',true),(''combat_v2_elemental_internal.other_prepare_ordinary(uuid,uuid,uuid)'',''bb260ba226bc3557058820bdd5cacc93'',true),(''combat_v2_elemental_internal.other_prepare_master(uuid,uuid,uuid[],jsonb,jsonb)'',''1159e41bd29afbed0f8a5e828a0a79de'',true),(''combat_v2_elemental_internal.other_preset_ready(uuid,uuid)'',''eda00ca66bd5e24d1ac8cd1e620bf9c4'',true),(''combat_v2_elemental_internal.other_quote(uuid,uuid)'',''d50b47aedacd9734f5561067a3d62ba8'',true),(''combat_v2_elemental_internal.other_target_visible(uuid,uuid,pg_catalog.numeric)'',''f4440fc78dec1369349183c0957b1d1e'',true),(''combat_v2_elemental_internal.other_offer_label(uuid,jsonb,text)'',''4d40c4838291ae873d83ee544a4b0044'',true),(''combat_v2_elemental_internal.other_draw_range(uuid,uuid,pg_catalog.bool)'',''4856b88270f39cc66a656ec4a679d8d3'',true),(''combat_v2_elemental_internal.other_substitution_available(uuid)'',''a89a389d107dc8ad30a007f25ef1981a'',true),(''combat_v2_elemental_internal.other_substitution_options(jsonb)'',''5c08c47feed36d8c9c7f2d44f2ab9309'',true),(''combat_v2_elemental_internal.other_consumer_options(jsonb)'',''204fe2a77ba4c45cc862113859836151'',true),(''combat_v2_elemental_internal.other_ordinary_copy_offers(uuid,pg_catalog.int8,jsonb)'',''00bec9479f3d07cac011cc6139e27ad1'',true),(''combat_v2_elemental_internal.other_master_options(uuid,pg_catalog.int8)'',''13cd420ffe7d757af62bc723f27ce8b3'',true),(''combat_v2_elemental_internal.other_control_target(text,uuid,uuid)'',''b811c5e103dd67321aa8a2e3c601efbf'',true),(''combat_v2_elemental_internal.other_control_apply(text,uuid,uuid,uuid)'',''63e4716e93d126611ca0490fe218fc57'',true),(''combat_v2_elemental_internal.other_prepare_callback(text,uuid,uuid,uuid,uuid[],jsonb,jsonb)'',''44d80129a84b21ab9345adfb4864736f'',true),(''combat_v2_elemental_internal.other_commit_control(jsonb,jsonb)'',''21538535df526b17d42dc91c7a3d4013'',true),(''combat_v2_elemental_internal.other_commit_master_control(jsonb)'',''c1690a97d6d6398360a401098588e56a'',true),(''combat_v2_elemental_internal.other_comparison(uuid,uuid,jsonb,pg_catalog.int4)'',''3b918a70932e681e148f7a90028f2d1c'',true),(''combat_v2_elemental_internal.other_force_from_outcome(uuid,uuid)'',''429727092531f7f07cfa99e06c7808d6'',true),(''combat_v2_elemental_internal.other_narrative_supported(uuid)'',''4a0d496f8d0528005aa3309ed60e3d0b'',true),(''combat_v2_elemental_internal.other_narrative_projection(uuid)'',''8ff935d763f4e4aeac25c3d6d017ecd3'',true),(''combat_v2_elemental_internal.scudo_profile(uuid)'',''92cfb95b3f56d8249d56c7d574e38d26'',true),(''combat_v2_elemental_internal.scudo_prepare_defense(uuid,uuid,uuid,uuid,uuid,jsonb)'',''b5808b034b5a3bcf50b7bcb8336d212a'',true),(''combat_v2_elemental_internal.scudo_declaration_meta(uuid,uuid,uuid,uuid,jsonb)'',''c27749ce44a439b3d59361a59e2337e9'',true),(''combat_v2_elemental_internal.scudo_bind_source(uuid)'',''cb840b147ea888fbfa57e3e55be49697'',true),(''combat_v2_elemental_internal.scudo_source_valid(uuid)'',''eacac569a8408d9e081344eebe12f9e2'',true),(''combat_v2_elemental_internal.scudo_meta(uuid)'',''92d3214d9de700399b263d1ee9ba8f93'',true),(''combat_v2_elemental_internal.scudo_staff_binding(uuid,uuid)'',''bf78d306e9a024a88ab453b9e8317671'',true),(''combat_v2_elemental_internal.scudo_staff_bind(uuid,uuid,uuid)'',''5f0c851bc78380fd88f246ca65fdb7fe'',true),(''combat_v2_elemental_internal.scudo_preset_ready(uuid,uuid)'',''b822c5fd7f3b549d455bbbcbe9e985c5'',true),(''combat_v2_elemental_internal.scudo_control_target(text,uuid,uuid)'',''014ec28c115fd3712b43d4253ffc39a9'',true),(''combat_v2_elemental_internal.scudo_control_apply(text,uuid,uuid,uuid)'',''2730009defb70b8c045be6430f496967'',true),(''combat_v2_elemental_internal.scudo_commit_control(jsonb,jsonb)'',''8b86c31c9d637aeb01beeb1c2fa2d1e7'',true),(''combat_v2_elemental_internal.scudo_commit_master_control(jsonb)'',''9bde876c7796180ea80bea206fe5829f'',true),(''combat_v2_elemental_internal.scudo_ability_meta(uuid,jsonb)'',''029b589a7af1a873e58cd3435bee3343'',true),(''combat_v2_elemental_internal.scudo_quote(uuid)'',''5c768cd419a7166e6e23420d5af3164b'',true),(''combat_v2_elemental_internal.scudo_consumer_options(jsonb)'',''e84aa35091f26367645f35a8815c78b1'',true),(''combat_v2_elemental_internal.scudo_master_options(uuid,pg_catalog.int8)'',''33fb2ed8a14cb05a3414e7be89556659'',true),(''combat_v2_elemental_internal.scudo_prepare_native(uuid,uuid,uuid,uuid,jsonb)'',''df51b64ad4443f0acdde37fbfdd5284e'',true),(''combat_v2_elemental_internal.scudo_narrative(uuid)'',''c580ef1cdbaff1598a7863603aa5c9a3'',true),(''combat_v2_elemental_internal.scarica_contact_range(uuid,uuid)'',''f92feff3bb5167ba034931dcb3832f4e'',true),(''combat_v2_elemental_internal.scarica_contact_witness(uuid,uuid,uuid,uuid)'',''34fb9bc5836831510ebd6e300e60a408'',true),(''combat_v2_elemental_internal.scarica_source_contact_valid(uuid)'',''57ed0bac1c1d36d8fd259010ceab4538'',true)) SELECT 1 FROM expected e LEFT JOIN pg_proc p ON p.oid=to_regprocedure(e.sig) WHERE p.oid IS NULL OR md5(p.prosrc) IS DISTINCT FROM e.hash OR p.prosecdef IS DISTINCT FROM e.sd OR p.proowner IS DISTINCT FROM ''postgres''::regrole OR p.proconfig IS DISTINCT FROM ARRAY[''search_path=""''] OR p.proacl IS DISTINCT FROM ''{postgres=X/postgres}''::aclitem[]) THEN RAISE EXCEPTION ''runtime_elemental_complete_helper_drift'';END IF;
end ','b2f5397b7fba0fe0ce6a12d9e07a0164a2364507aacfc3327d0da7be1ad9e74a',encode(extensions.digest(convert_to(pg_get_functiondef('public.combat_v2_actor_ability(uuid,text,uuid,boolean)'::regprocedure),'UTF8'),'sha256'),'hex'))),'8de6ce1265be1420cc2e89479a8bac98','{"acl": "{postgres=X/postgres}", "nargs": 0, "owner": "postgres", "config": ["search_path=pg_catalog, public, clan_innata_private"], "secdef": true, "strict": false, "defaults": null, "language": "plpgsql", "parallel": "u", "arg_modes": null, "arg_names": null, "arg_types": "", "leakproof": false, "return_oid": "2278", "volatility": "s", "returns_set": false, "variadic_type": "0", "default_arg_count": 0}'::jsonb,'41419'),
('combat_panel_private.multiplication_add_layout_groups(uuid,uuid,jsonb)','a7b90e33513fff4685afb46a21e57b8f','f2515609aa9a224d7f2ff542a3f503c1','{"acl": "{postgres=X/postgres}", "owner": "postgres", "config": ["search_path=\"\""], "secdef": true, "strict": false, "language": "plpgsql", "parallel": "u", "leakproof": false, "volatility": "v"}'::jsonb,'45632'),
('combat_panel_private.multiplication_layout_options_for_figure(uuid,integer,text,uuid,uuid,bigint,integer)','3e4184f1bfe0bafe5cde44b08e552b1a','7b36f3d868c85c3941f120844c286dd9','{"acl": "{postgres=X/postgres}", "owner": "postgres", "config": ["search_path=\"\""], "secdef": true, "strict": false, "language": "plpgsql", "parallel": "u", "leakproof": false, "volatility": "v"}'::jsonb,'45714'),
('public.combat_v2_actor_ability(uuid,text,uuid,boolean)','b6180f3bc0d3ec90d2c18dac3c6f54e8','ec79a59f561042dee9eac224926afe28','{"acl": "{postgres=X/postgres,service_role=X/postgres}", "owner": "postgres", "config": ["search_path=\"\""], "secdef": true, "strict": false, "language": "sql", "parallel": "u", "leakproof": false, "volatility": "s"}'::jsonb,'31311')),
fn AS MATERIALIZED(
 SELECT t.signature,t.expected_source_md5,t.old_ddl_md5,t.contract,t.expected_oid,p.*,n.nspname,l.lanname,
 pg_get_functiondef(p.oid) actual_ddl,pg_get_userbyid(p.proowner) function_owner
 FROM targets t JOIN pg_proc p ON p.oid=to_regprocedure(t.signature)
 JOIN pg_namespace n ON n.oid=p.pronamespace JOIN pg_language l ON l.oid=p.prolang),
headers AS MATERIALIZED(
 SELECT signature,expected_source_md5,old_ddl_md5,contract,expected_oid,
 jsonb_build_object('signature',signature,'oid',oid::text,'nspname',nspname,'proname',proname,'kind',prokind::text,
 'owner',function_owner,'acl',proacl::text,'language',lanname,'config',to_jsonb(proconfig),'secdef',prosecdef,
 'volatility',provolatile::text,'parallel',proparallel::text,'strict',proisstrict,'leakproof',proleakproof,
 'arg_types',proargtypes::text,'all_arg_types',to_jsonb(proallargtypes),'arg_modes',to_jsonb(proargmodes),'arg_names',to_jsonb(proargnames),
 'nargs',pronargs,'default_arg_count',pronargdefaults,'defaults',pg_get_expr(proargdefaults,0),
 'variadic_type',provariadic::text,'return_oid',prorettype::text,'returns_set',proretset,
 'arguments',pg_get_function_arguments(oid),'returns',pg_get_function_result(oid),
 'ddl_md5',md5(actual_ddl),'source_md5',md5(prosrc),'ddl_sha256',encode(extensions.digest(convert_to(actual_ddl,'UTF8'),'sha256'),'hex'),
 'source_sha256',encode(extensions.digest(convert_to(prosrc,'UTF8'),'sha256'),'hex'),
 'ddl_bytes',octet_length(actual_ddl),'source_bytes',octet_length(prosrc))h
 FROM fn),
guard AS MATERIALIZED(
 SELECT count(*)=6 AND bool_and(h->>'source_md5'=expected_source_md5 AND h @> contract
 AND(expected_oid IS NULL OR h->>'oid'=expected_oid)
 AND(old_ddl_md5 IS NULL OR h->>'ddl_md5'<>old_ddl_md5))ok FROM headers),
bundle AS MATERIALIZED(
 SELECT jsonb_build_object('schema_version','tactics-staff-function-proof/1','functions',jsonb_agg(h ORDER BY signature))full_header_manifest,
 jsonb_object_agg(signature,h) target_bodies_after FROM headers HAVING count(*)=6),
witness AS MATERIALIZED(
 SELECT b.*,jsonb_build_object('sha256',public.combat_v2_sha256(full_header_manifest),'source_sha256','70532b3233ce24e12d18396eacb02e71db5a215df46f6ef88f60160a71384cca')compact
 FROM bundle b CROSS JOIN guard g WHERE g.ok),
baseline AS MATERIALIZED(
 SELECT canonical_preimage::jsonb prior FROM mission_factory_owner.editor_release_readiness
 WHERE singleton AND revision_sha256='e9d24578201d8f0b086e9fc079fb657f5d41364145218d8385e878aa659769ce' AND observed_revision_sha256=revision_sha256
 AND public.combat_v2_sha256(canonical_preimage::jsonb)='e9d24578201d8f0b086e9fc079fb657f5d41364145218d8385e878aa659769ce'
 AND octet_length((canonical_preimage::jsonb)::text)=523935),
patched AS MATERIALIZED(
 SELECT prior,w.*,jsonb_set(jsonb_set(jsonb_set(jsonb_set(jsonb_set(jsonb_set(prior,ARRAY['db_core','innata_all_clan_functions','665885','ddl_md5'],target_bodies_after->'clan_innata_narrative_private.staff_profile_bind_v1(uuid,uuid)'->'ddl_md5',false),ARRAY['db_core','innata_all_clan_functions','665885','source_md5'],target_bodies_after->'clan_innata_narrative_private.staff_profile_bind_v1(uuid,uuid)'->'source_md5',false),ARRAY['db_core','innata_staff_profile_functions','665885','ddl_md5'],target_bodies_after->'clan_innata_narrative_private.staff_profile_bind_v1(uuid,uuid)'->'ddl_md5',false),ARRAY['db_core','innata_staff_profile_functions','665885','source_md5'],target_bodies_after->'clan_innata_narrative_private.staff_profile_bind_v1(uuid,uuid)'->'source_md5',false),ARRAY['db_core','combat_innata_functions','41419','ddl_md5'],target_bodies_after->'clan_innata_private.eligibility_release_assert()'->'ddl_md5',false),ARRAY['db_core','combat_innata_functions','41419','source_md5'],target_bodies_after->'clan_innata_private.eligibility_release_assert()'->'source_md5',false) j FROM baseline CROSS JOIN witness w WHERE NOT(prior->'db_core'?'tactics_staff')),
with_proof AS MATERIALIZED(SELECT prior,full_header_manifest,target_bodies_after,compact,jsonb_set(j,'{db_core,tactics_staff}',compact,true)j FROM patched),
final AS MATERIALIZED(SELECT prior,full_header_manifest,target_bodies_after,compact,
 jsonb_set(j,'{db_core,sha256}',to_jsonb(public.combat_v2_sha256((j->'db_core')-'sha256')),false)successor FROM with_proof)
SELECT jsonb_build_object('schema_version','tactics-root-projection/1','source_sha256','70532b3233ce24e12d18396eacb02e71db5a215df46f6ef88f60160a71384cca',
 'parent_revision','e9d24578201d8f0b086e9fc079fb657f5d41364145218d8385e878aa659769ce','full_header_manifest',full_header_manifest,'target_bodies_after',target_bodies_after,'compact',compact,
 'successor',successor,'canonical_preimage',successor::text,'revision_sha256',public.combat_v2_sha256(successor),
 'root_bytes',octet_length(successor::text),'db_sha256',successor#>>'{db_core,sha256}',
 'untouched_outside_db_core',(successor-'db_core')=(prior-'db_core')) AS tactics_projection
FROM final WHERE octet_length(successor::text)<524288 AND(successor-'db_core')=(prior-'db_core');
DO $integrated_adopt$
DECLARE tf_body text;tf_root jsonb;tf_bindings jsonb;tf_payload jsonb;tf_cert uuid;tf_count integer;tf_newRoot text;tf_review_ref text;tf_review_sha text;
BEGIN
IF NOT coalesce(((SELECT count(*)=1 AND bool_and((tactics_projection->>'root_bytes')::integer=524117 AND tactics_projection->>'source_sha256'='70532b3233ce24e12d18396eacb02e71db5a215df46f6ef88f60160a71384cca' AND(tactics_projection->>'untouched_outside_db_core')::boolean)FROM pg_temp.tactics_projected)),false)THEN RAISE EXCEPTION 'TACTICS_INTEGRATED_PROJECTED_ROOT';END IF;
 SELECT tactics_projection->>'canonical_preimage',tactics_projection->'successor',tactics_projection->>'revision_sha256'INTO STRICT tf_body,tf_root,tf_newRoot FROM pg_temp.tactics_projected;
 SELECT doc->>'ref',doc->>'sha256'INTO STRICT tf_review_ref,tf_review_sha FROM pg_temp.tactics_review;
 UPDATE mission_factory_owner.editor_release_readiness SET canonical_preimage=tf_body,
 revision_sha256=tf_newRoot,observed_revision_sha256=tf_newRoot,client_build='mission-factory-admin/2:'||tf_newRoot,
 independent_review_ref=tf_review_ref,updated_at=clock_timestamp() WHERE singleton AND revision_sha256='e9d24578201d8f0b086e9fc079fb657f5d41364145218d8385e878aa659769ce';
 IF NOT coalesce((FOUND),false) THEN RAISE EXCEPTION 'COVERAGE_ROOT_CAS_WRITE'; END IF;
 tf_bindings:=jsonb_build_object('db_sha256',tf_root#>>'{db_core,sha256}','edge_sha256',tf_root#>>'{edge_bundles,0,ezbr_sha256}',
 'client_sha256',public.combat_v2_sha256(tf_root->'ui'),'configuration_sha256',tf_root#>>'{config,sha256}');
 INSERT INTO mission_public_owner.release_admissions_v1(release_sha256,db_sha256,edge_sha256,client_sha256,configuration_sha256,
 contract_version,independent_review_ref,staff_evidence_ref,qualified_at,public_enabled)
 SELECT tf_newRoot,tf_bindings->>'db_sha256',tf_bindings->>'edge_sha256',tf_bindings->>'client_sha256',
 tf_bindings->>'configuration_sha256',a.contract_version,tf_review_ref,a.staff_evidence_ref,clock_timestamp(),a.public_enabled
 FROM mission_public_owner.release_admissions_v1 a WHERE a.release_sha256='e9d24578201d8f0b086e9fc079fb657f5d41364145218d8385e878aa659769ce';
 IF NOT coalesce((FOUND),false) THEN RAISE EXCEPTION 'COVERAGE_ADMISSION'; END IF;
 INSERT INTO mission_public_owner.engine_profile_events_v1(event_id,engine_release_sha256,profile_key,expected_control_version,
 control_version,authoring_enabled,runtime_enabled,reason)
 SELECT extensions.uuid_generate_v5('3ff627ec-dbee-423a-9879-8e37f7ad5510'::uuid,tf_newRoot||':profile:1'),tf_newRoot,p.profile_key,p.expected_control_version,
 p.control_version,p.authoring_enabled,p.runtime_enabled,'Preserve qualified predecessor scope during reviewed Staff tactics dependency/performance adoption; no new public tactics QA'
 FROM mission_public_owner.engine_profile_events_v1 p WHERE p.engine_release_sha256='e9d24578201d8f0b086e9fc079fb657f5d41364145218d8385e878aa659769ce' AND p.profile_key='mission-ai-authoring/1'
 AND p.expected_control_version=0 AND p.control_version=1 AND p.authoring_enabled AND p.runtime_enabled;
 GET DIAGNOSTICS tf_count=ROW_COUNT;IF NOT coalesce((tf_count=1),false) THEN RAISE EXCEPTION 'COVERAGE_PROFILE'; END IF;
 SELECT q.payload||jsonb_build_object('revision_sha256',tf_newRoot,'bindings',tf_bindings,
 'independent_review',jsonb_build_object('ref',tf_review_ref,'sha256',tf_review_sha,'P0',0,'P1',0,'P2',0))
 INTO STRICT tf_payload FROM mission_public_owner.public_qualification_attestations_v1 q WHERE q.release_sha256='e9d24578201d8f0b086e9fc079fb657f5d41364145218d8385e878aa659769ce';
 INSERT INTO mission_public_owner.public_qualification_attestations_v1(release_sha256,request_key,payload,payload_sha256,
 positive_staff_evidence_ref,authorized_test_manifest_ref,created_by)
 SELECT tf_newRoot,extensions.uuid_generate_v5('3ff627ec-dbee-423a-9879-8e37f7ad5510'::uuid,tf_newRoot||':qualification'),tf_payload,mission_factory_owner.sha(tf_payload),
 q.positive_staff_evidence_ref,q.authorized_test_manifest_ref,q.created_by
 FROM mission_public_owner.public_qualification_attestations_v1 q WHERE q.release_sha256='e9d24578201d8f0b086e9fc079fb657f5d41364145218d8385e878aa659769ce';
 IF NOT coalesce((FOUND),false) THEN RAISE EXCEPTION 'COVERAGE_QUALIFICATION'; END IF;
 tf_cert:=extensions.uuid_generate_v5('3ff627ec-dbee-423a-9879-8e37f7ad5510'::uuid,tf_newRoot||':content-adoption');
 SELECT c.payload||jsonb_build_object('request_key',tf_cert,'engine_release_sha256',tf_newRoot,'created_at',clock_timestamp())
 INTO STRICT tf_payload FROM mission_public_owner.mission_content_admissions_v1 c WHERE c.engine_release_sha256='e9d24578201d8f0b086e9fc079fb657f5d41364145218d8385e878aa659769ce';
 INSERT INTO mission_public_owner.mission_content_admissions_v1(request_key,mission_id,config_version,engine_release_sha256,
 publication_request,payload,payload_sha256)
 SELECT tf_cert,c.mission_id,c.config_version,tf_newRoot,c.publication_request,tf_payload,mission_factory_owner.sha(tf_payload)
 FROM mission_public_owner.mission_content_admissions_v1 c WHERE c.engine_release_sha256='e9d24578201d8f0b086e9fc079fb657f5d41364145218d8385e878aa659769ce'
 AND c.mission_id='6d6c216a-222d-4cba-b2fc-f3e0c199c195'::uuid AND c.publication_request='3ff627ec-dbee-423a-9879-8e37f7ad5510'::uuid;
 IF NOT coalesce((FOUND),false) THEN RAISE EXCEPTION 'COVERAGE_CONTENT'; END IF;
 UPDATE mission_public_owner.party_launch_runtime_v1 SET release_sha256=tf_newRoot
 WHERE singleton AND release_sha256='e9d24578201d8f0b086e9fc079fb657f5d41364145218d8385e878aa659769ce' AND staff_enabled AND public_enabled;
 IF NOT coalesce((FOUND),false) THEN RAISE EXCEPTION 'COVERAGE_PARTY_CAS_WRITE'; END IF;
 IF NOT coalesce((mission_public_owner.engine_qualification_v1(tf_newRoot,true) IS NOT NULL),false) THEN RAISE EXCEPTION 'COVERAGE_NEW_ENGINE'; END IF;
 IF NOT coalesce((mission_public_owner.content_admission_v1('6d6c216a-222d-4cba-b2fc-f3e0c199c195'::uuid,tf_newRoot,'3ff627ec-dbee-423a-9879-8e37f7ad5510'::uuid,true) IS NOT NULL),false) THEN RAISE EXCEPTION 'COVERAGE_NEW_CONTENT'; END IF;

 PERFORM clan_innata_private.runtime_release_assert();
END $integrated_adopt$;

CREATE TEMP TABLE tactics_after_proof ON COMMIT DROP AS WITH targets(signature,expected_source_md5,old_ddl_md5,contract,expected_oid) AS(VALUES
('clan_innata_narrative_private.fenice_staff_proof_v1(uuid)','6ebcfee584480f0b6129789e631044d6',NULL,'{"acl": "{postgres=X/postgres}", "owner": "postgres", "config": ["search_path=\"\""], "secdef": true, "strict": false, "language": "plpgsql", "parallel": "u", "leakproof": false, "volatility": "s"}'::jsonb,NULL),
('clan_innata_narrative_private.staff_profile_bind_v1(uuid,uuid)','547bdbb6bda2165fa7a29e798491825b','492484888b32bd02c453a604c77a2e15','{"acl": "{postgres=X/postgres}", "owner": "postgres", "config": ["search_path=\"\""], "secdef": true, "strict": false, "language": "plpgsql", "parallel": "u", "leakproof": false, "volatility": "v"}'::jsonb,'665885'),
('clan_innata_private.eligibility_release_assert()',md5(replace('
declare v_marionetta boolean:=false; v_panel boolean:=false;
begin

 -- La porta pubblica aggiornata è ammessa solo insieme al suo producer
 -- originale privato e alla redazione esatta: corpi, autorità e ACL pinzati.
 with expected(sig,sha,acl) as(values (''public.combat_v2_round_options(uuid,uuid)'',''0b3acc15933027fa840ca03c0d02f082aecf6f2ccedcdefd737127bed1d853d1'',''authenticated:EXECUTE:false,postgres:EXECUTE:false,service_role:EXECUTE:false''),(''combat_panel_private.round_options_authoritative(uuid,uuid)'',''879b5d69f1ca6a8f9cc28421699b77d649e3e277f4130a40308ca3acfc8a895c'',''postgres:EXECUTE:false''),(''combat_panel_private.mask_native_state(jsonb)'',''1d2f6ad44b2ff1e9c15d897e38fee54b67c744411081f906bc33a26a42600dac'',''postgres:EXECUTE:false'')),
 observed as(select e.*,p.oid,p.proowner,p.prosecdef,p.proconfig,
   case when p.oid is null then null else encode(extensions.digest(convert_to(pg_get_functiondef(p.oid),''UTF8''),''sha256''),''hex'') end actual_sha,
   (select string_agg(coalesce(r.rolname,''PUBLIC'')||'':''||x.privilege_type||'':''||x.is_grantable,'','' order by coalesce(r.rolname,''PUBLIC''),x.privilege_type,x.is_grantable)
     from aclexplode(coalesce(p.proacl,acldefault(''f'',p.proowner))) x left join pg_roles r on r.oid=x.grantee) actual_acl
   from expected e left join pg_proc p on p.oid=to_regprocedure(e.sig))
 select count(*)=3 and bool_and(coalesce(oid is not null and actual_sha=sha and actual_acl=acl
   and proowner=''postgres''::regrole and prosecdef and proconfig=array[''search_path=""''],false))
 into v_panel from observed;
 if exists(select 1 from supabase_migrations.schema_migrations where name=''marionetta_ordinary_staff_001'' or version=''20260907084651'') then
   if (select count(*) from supabase_migrations.schema_migrations where name=''marionetta_ordinary_staff_001'' or version=''20260907084651'')<>1
     or not exists(select 1 from supabase_migrations.schema_migrations where version=''20260907084651'' and name=''marionetta_ordinary_staff_001''
       and cardinality(statements)=1 and encode(extensions.digest(convert_to(array_to_string(statements,''''),''UTF8''),''sha256''),''hex'')=''3d3b6643c1b513728ee8e2366fbde983aa374cf9d330f0976d71c5f122318f17'') then
     raise exception ''runtime_eligibility_marionetta_release_drift''; end if;
   v_marionetta:=true;
 end if;
 if (select count(*) from supabase_migrations.schema_migrations where version=''20260902055751'' and name=''genin_elemental_eligibility_common_009'' and cardinality(statements)=1 and encode(extensions.digest(convert_to(array_to_string(statements,''''),''UTF8''),''sha256''),''hex'')=''e2ca4e296401307496cdc1ed108f4cf22ee4469a34072172c7b9855063a97c2e'')<>1
 or (select count(*) from supabase_migrations.schema_migrations where version between ''20260902005704'' and ''20260902055751'')<>4
 or (select count(*) from supabase_migrations.schema_migrations where name=''clan_genin_innata_common_release_seal_eligibility_018'')>1
 or ((select count(*) from supabase_migrations.schema_migrations where name=''clan_genin_innata_common_release_seal_eligibility_018'')=0 and ((select count(*) from supabase_migrations.schema_migrations)<>452 or (select version from supabase_migrations.schema_migrations order by version desc limit 1) is distinct from ''20260902055751''))
 or ((select count(*) from supabase_migrations.schema_migrations where name=''clan_genin_innata_common_release_seal_eligibility_018'')=1 and not exists(select 1 from supabase_migrations.schema_migrations where name=''clan_genin_innata_common_release_seal_eligibility_018'' and version~''^[0-9]{14}$'' and version>''20260902055751'' and cardinality(statements)=1))
 then raise exception ''runtime_eligibility_history_drift'';end if;
 if to_regnamespace(''combat_v2_elemental_internal'') is null
 or (select count(*) from pg_proc p where p.pronamespace=''combat_v2_elemental_internal''::regnamespace)<>91
 or (select pg_get_userbyid(n.nspowner)||''|''||coalesce(n.nspacl::text,'''') from pg_namespace n where n.oid=''combat_v2_elemental_internal''::regnamespace) is distinct from ''postgres|{postgres=UC/postgres,service_role=U/postgres}''
 then raise exception ''runtime_eligibility_schema_drift'';end if;

 -- Rilascio Suiton verificato: insieme chiuso di 35 helper aggiuntivi.
 -- I due helper storici mantengono le verifiche originali sottostanti.
 if (select count(*) from supabase_migrations.schema_migrations
     where version=''20260912191445'' and name=''elementali_staff_suiton_install_20260912_1912''
       and cardinality(statements)=1
       and encode(extensions.digest(convert_to(array_to_string(statements,''''),''UTF8''),''sha256''),''hex'')=''e7bd1cb6dea7505399fc9dbce5b39ec5078eb9474f55990def7502a68fbbdb18'')<>1
 then raise exception ''runtime_eligibility_suiton_release_drift'';end if;
 if exists(
  with expected(sig,sha,definer) as(values
   (''combat_v2_elemental_internal.comparison_channels(uuid,uuid,uuid,jsonb,integer,uuid)'', ''4db77777b8277750fb1468b8789915facbf71864d81f2647dedad6a0d40f26f8'', true),
   (''combat_v2_elemental_internal.comparison_reserve(uuid,uuid,uuid)'', ''712095a7757a2828bed68307408edba803169e8465b1f31b62e3b408b04749df'', true),
   (''combat_v2_elemental_internal.suiton_ability_meta(uuid,jsonb)'', ''8856c83e2aac23fbac02b3fa893caf0f0809234bf8a7ff42aeac6b246db14838'', true),
   (''combat_v2_elemental_internal.suiton_bind_source(uuid)'', ''1fd85f165e897d3e90ddb0f04bc2c5523b73587f26d1037e0ab45635ac1208f5'', true),
   (''combat_v2_elemental_internal.suiton_commit_control(jsonb,jsonb)'', ''aca8de9ce4d1caf737ea789d11aeb5de4e8a55be2840f4700eb0daaa8b5357dc'', true),
   (''combat_v2_elemental_internal.suiton_commit_master_control(jsonb)'', ''8e3dc679cced28892d6270a5310d49b975b9da9e483cfff635140db331e0e43d'', true),
   (''combat_v2_elemental_internal.suiton_consumer_options(jsonb)'', ''82231c040ab41b619f29616499fad90e6d6efebfc614bebe67e8b91c82081ca5'', true),
   (''combat_v2_elemental_internal.suiton_control_apply(text,uuid,uuid,uuid)'', ''15c8ce32ece8af8c407bac7e46fbbb414184fd87bfb3e1238a3b4e461f43ba39'', true),
   (''combat_v2_elemental_internal.suiton_control_target(text,uuid,uuid)'', ''83833b6ff5f114c3b870c3767565d00ea829bbf85f02606f034e197e4c37ab03'', true),
   (''combat_v2_elemental_internal.suiton_declaration_meta(uuid,uuid,uuid,jsonb)'', ''7b13ed2ad7acc320c88350a5ec0fd2d9155614f51b5ea6682094e88e6bfbba36'', true),
   (''combat_v2_elemental_internal.suiton_draw_range(uuid,uuid,boolean)'', ''b178d00a882a8e2cff719795874d1a553e4478f0369ef6eb5a9ed4e20ccb71f4'', true),
   (''combat_v2_elemental_internal.suiton_force_from_outcome(uuid,uuid)'', ''aa3b68e633cc12f401505a6ba3492e92e94c44598940bf90e7c70473e90ca7f0'', true),
   (''combat_v2_elemental_internal.suiton_geometry(uuid,uuid,boolean)'', ''422ce58f19b0c0d9692fbf639f409f54b45d054b6c3f01e580b8be1f43222288'', true),
   (''combat_v2_elemental_internal.suiton_master_options(uuid,bigint)'', ''a2359c02aaeb2192ecef01fae57d05f6fb548d0c245380494915427341499d5f'', true),
   (''combat_v2_elemental_internal.suiton_meta(uuid)'', ''65375ebe226f598927e0873b228d0daaa9f239249f6b2e9196ad4ae5a2282f7b'', true),
   (''combat_v2_elemental_internal.suiton_narrative_facts(uuid)'', ''b6936b0bd08eee059ae94cffcdd3c2e7319b3aa6f7430e38a91bfc088cd49901'', true),
   (''combat_v2_elemental_internal.suiton_narrative_projection(uuid)'', ''d34e9dc4d467ab47f8a263d837b8f00d6f0f3f02c7b59d1b4063ce1aa7022276'', true),
   (''combat_v2_elemental_internal.suiton_narrative_supported(uuid)'', ''660838edb1eef2ba8afbab180edf21ec295170aa36b0122e163fc17c59f42a48'', true),
   (''combat_v2_elemental_internal.suiton_offer_label(uuid,jsonb,text)'', ''71ef19352a96939de8a8034cc821f79326a0d33eb0fa4c673a4aabe6f8aa1fe0'', true),
   (''combat_v2_elemental_internal.suiton_ordinary_copy_offers(uuid,bigint,jsonb)'', ''3392390a180bee9b10b58495a32d889d05da52cfdec5611c47c7769599fbaef5'', true),
   (''combat_v2_elemental_internal.suiton_png_owned(uuid,uuid)'', ''b2d3877e7497adbdc4a76139d2627ac0744b192a0823d54dbc90afaabf6bd659'', true),
   (''combat_v2_elemental_internal.suiton_prepare_callback(text,uuid,uuid,uuid,uuid[],jsonb,jsonb)'', ''973b09c57a37f9721e216f8dfd4b1e0dbfc29d80c8cb4615a175603366e36c87'', true),
   (''combat_v2_elemental_internal.suiton_prepare_master(uuid,uuid,uuid[],jsonb,jsonb)'', ''9ef708a90471da085ffb0d804f31a010f021ce227d43b40060ecd8e7cb707b12'', true),
   (''combat_v2_elemental_internal.suiton_prepare_native(uuid,uuid,uuid,jsonb,boolean,jsonb)'', ''1b5986868ba2679c2ebd8dbf824a22cee4190ec4c0e17852d089ab8093e78655'', true),
   (''combat_v2_elemental_internal.suiton_prepare_ordinary(uuid,uuid,uuid)'', ''b3c5628855bd2c213c268d209219559a362c67f399133e15186eaf3e78497ad3'', true),
   (''combat_v2_elemental_internal.suiton_preset_ready(uuid,uuid)'', ''c65ac30e5d1b1a8bf88ee73e636a15da683f9ae3f97c124ae9b5b9199a386ec7'', true),
   (''combat_v2_elemental_internal.suiton_profile(uuid,uuid)'', ''f8174ccbe1808bedc756e452c4fb8cf7cd9f9f6629fe627ed473b36d516a65c6'', true),
   (''combat_v2_elemental_internal.suiton_quote(uuid,uuid)'', ''900157dfaaf19810d4d21a4138a9a63c77ae6cc460d0d296425556a6efa653a1'', true),
   (''combat_v2_elemental_internal.suiton_source_valid(uuid)'', ''d937562a6537b70bf92233e0f3a3182ff346a93c7a586d73139febe7370d5969'', true),
   (''combat_v2_elemental_internal.suiton_staff_bind(uuid,uuid,uuid)'', ''09bcc66bf8d7cf5e5f04f41cc6b071841a6472d9cf45d750f789d679fdf3a576'', true),
   (''combat_v2_elemental_internal.suiton_staff_binding(uuid,uuid)'', ''fbbf2c198e245b92424046ed58bc79c7b2d4ff440e82722ab90187de89d20152'', true),
   (''combat_v2_elemental_internal.suiton_substitution_available(uuid)'', ''7535c6c3c7366a23e22f697c5eb20bf8e3cd422208909881ab32327106b5ee1a'', true),
   (''combat_v2_elemental_internal.suiton_substitution_options(jsonb)'', ''3d07b691098cdf4b698ed8822ab4c554de722a90d586b917dad59a0131fe3aaa'', true),
   (''combat_v2_elemental_internal.suiton_target_visible(uuid,uuid,numeric)'', ''5eff813391e64689028888e8449b89abcf2486601428e72c5917e59ffb72769d'', true),
   (''combat_v2_elemental_internal.technique_profile_v1(uuid)'', ''6446b74bbe092d8627820dc064d778aaf188eec6c7dd28e79e985843b995bd93'', false)),
  observed as(select e.*,p.oid,p.proowner,p.prosecdef,p.proconfig,
   case when p.oid is null then null else encode(extensions.digest(convert_to(pg_get_functiondef(p.oid),''UTF8''),''sha256''),''hex'') end actual_sha,
   (select string_agg(coalesce(r.rolname,''PUBLIC'')||'':''||x.privilege_type||'':''||x.is_grantable,'','' order by coalesce(r.rolname,''PUBLIC''),x.privilege_type,x.is_grantable)
    from aclexplode(coalesce(p.proacl,acldefault(''f'',p.proowner))) x left join pg_roles r on r.oid=x.grantee) actual_acl
   from expected e left join pg_proc p on p.oid=to_regprocedure(e.sig))
  select 1 from observed where oid is null or actual_sha is distinct from sha
   or proowner is distinct from ''postgres''::regrole or prosecdef is distinct from definer
   or proconfig is distinct from array[''search_path=""'']
   or actual_acl is distinct from ''postgres:EXECUTE:false''
 ) then raise exception ''runtime_eligibility_suiton_helper_drift'';end if;

 if exists(
  with expected(sig,sha,acl) as(values
   (''combat_v2_elemental_internal.is_target_v1(uuid)'',''8af6bdfc87b76ed118b596f7c7885c6de849c5d89140f61cdd1845047cbd5724'',''postgres:EXECUTE:false,service_role:EXECUTE:false''),
   (''combat_v2_elemental_internal.eligible_v1(uuid,uuid,boolean)'',''a5161f2993a4e0ce51864ac67ea88ba3fa6966457da1caf4ca390f17c2b1d8e9'',''postgres:EXECUTE:false,service_role:EXECUTE:false''),
   (''public.combat_v2_character_snapshot(uuid)'',case when v_marionetta then ''20c680c16a5ba1adedada1b9dcb6b5ee2f91bf01ddbdd9c0d40064d9d2d57ee3'' else ''323d6dd5a1cfac2ad6535fb73a4aefb03d33c7aa2894b9196489c17880046f87'' end,''postgres:EXECUTE:false,service_role:EXECUTE:false''),
   (''public.combat_v2_actor_ability(uuid,text,uuid,boolean)'',''b2f5397b7fba0fe0ce6a12d9e07a0164a2364507aacfc3327d0da7be1ad9e74a'',''postgres:EXECUTE:false,service_role:EXECUTE:false''),
   (''public.combat_v2_round_options(uuid,uuid)'',case when v_panel then ''0b3acc15933027fa840ca03c0d02f082aecf6f2ccedcdefd737127bed1d853d1'' when v_marionetta then ''6b9012a057baa9bc06b201ce6bcc5b8d8bb4a832ae9a462444c5e3ef55e0c8cb'' else ''3be90b0da7f02c826ffdfcd594d2132a4af9128291e3417278ad6adac88f6129'' end,''authenticated:EXECUTE:false,postgres:EXECUTE:false,service_role:EXECUTE:false'')),
  observed as(select e.*,encode(extensions.digest(convert_to(pg_get_functiondef(e.sig::regprocedure),''UTF8''),''sha256''),''hex'') actual_sha,p.proowner,p.prosecdef,p.proconfig,(select string_agg(coalesce(r.rolname,''PUBLIC'')||'':''||x.privilege_type||'':''||x.is_grantable,'','' order by coalesce(r.rolname,''PUBLIC''),x.privilege_type,x.is_grantable) from aclexplode(coalesce(p.proacl,acldefault(''f'',p.proowner))) x left join pg_roles r on r.oid=x.grantee) actual_acl from expected e join pg_proc p on p.oid=e.sig::regprocedure)
  select 1 from observed where actual_sha is distinct from sha or actual_acl is distinct from acl or proowner<>''postgres''::regrole or not prosecdef or proconfig is distinct from array[''search_path=""''])
 then raise exception ''runtime_eligibility_full_seal_drift'';end if;
 if encode(extensions.digest(convert_to(pg_get_functiondef(''public.character_elementi(uuid)''::regprocedure),''UTF8''),''sha256''),''hex'') is distinct from ''2e62fad3aa654ab452c516549ca82068dd33f6496a3c1e17e3a8c805a8ddacd7''
 then raise exception ''runtime_eligibility_character_elementi_drift'';end if;

 IF EXISTS(WITH expected(sig,hash,sd) AS (VALUES (''combat_v2_elemental_internal.other_meta(uuid)'',''18a6130387a81b22c993feaaf2613612'',true),(''combat_v2_elemental_internal.other_staff_binding(uuid,uuid)'',''cb15a27f82e60cf2ace2f22de4ca1e73'',true),(''combat_v2_elemental_internal.other_png_owned(uuid,uuid)'',''1730fa382f3f2da21b05ba43e1876330'',true),(''combat_v2_elemental_internal.other_profile(uuid,uuid)'',''f71b7422e1af07cfb2784137d5d05f03'',true),(''combat_v2_elemental_internal.other_ability_meta(uuid,jsonb)'',''07a3babec6e05865d9265b09c22d0859'',true),(''combat_v2_elemental_internal.other_staff_bind(uuid,uuid,uuid)'',''a4fb778f33ab73c31e63904f51299985'',true),(''combat_v2_elemental_internal.other_geometry(uuid,uuid,pg_catalog.bool)'',''8776c899d5534308eb256de2ba451ae8'',true),(''combat_v2_elemental_internal.other_prepare_native(uuid,uuid,uuid,jsonb,pg_catalog.bool,jsonb)'',''0e93d6425a2e8a151765040279758310'',true),(''combat_v2_elemental_internal.other_declaration_meta(uuid,uuid,uuid,jsonb)'',''d37f38beb455ecfbcda7a63962013542'',true),(''combat_v2_elemental_internal.other_bind_source(uuid)'',''35714da91f1df0f2d90d5921099e1177'',true),(''combat_v2_elemental_internal.other_source_valid(uuid)'',''20b96bb421f4bfbd3eb74a33294a3080'',true),(''combat_v2_elemental_internal.other_prepare_ordinary(uuid,uuid,uuid)'',''bb260ba226bc3557058820bdd5cacc93'',true),(''combat_v2_elemental_internal.other_prepare_master(uuid,uuid,uuid[],jsonb,jsonb)'',''1159e41bd29afbed0f8a5e828a0a79de'',true),(''combat_v2_elemental_internal.other_preset_ready(uuid,uuid)'',''eda00ca66bd5e24d1ac8cd1e620bf9c4'',true),(''combat_v2_elemental_internal.other_quote(uuid,uuid)'',''d50b47aedacd9734f5561067a3d62ba8'',true),(''combat_v2_elemental_internal.other_target_visible(uuid,uuid,pg_catalog.numeric)'',''f4440fc78dec1369349183c0957b1d1e'',true),(''combat_v2_elemental_internal.other_offer_label(uuid,jsonb,text)'',''4d40c4838291ae873d83ee544a4b0044'',true),(''combat_v2_elemental_internal.other_draw_range(uuid,uuid,pg_catalog.bool)'',''4856b88270f39cc66a656ec4a679d8d3'',true),(''combat_v2_elemental_internal.other_substitution_available(uuid)'',''a89a389d107dc8ad30a007f25ef1981a'',true),(''combat_v2_elemental_internal.other_substitution_options(jsonb)'',''5c08c47feed36d8c9c7f2d44f2ab9309'',true),(''combat_v2_elemental_internal.other_consumer_options(jsonb)'',''204fe2a77ba4c45cc862113859836151'',true),(''combat_v2_elemental_internal.other_ordinary_copy_offers(uuid,pg_catalog.int8,jsonb)'',''00bec9479f3d07cac011cc6139e27ad1'',true),(''combat_v2_elemental_internal.other_master_options(uuid,pg_catalog.int8)'',''13cd420ffe7d757af62bc723f27ce8b3'',true),(''combat_v2_elemental_internal.other_control_target(text,uuid,uuid)'',''b811c5e103dd67321aa8a2e3c601efbf'',true),(''combat_v2_elemental_internal.other_control_apply(text,uuid,uuid,uuid)'',''63e4716e93d126611ca0490fe218fc57'',true),(''combat_v2_elemental_internal.other_prepare_callback(text,uuid,uuid,uuid,uuid[],jsonb,jsonb)'',''44d80129a84b21ab9345adfb4864736f'',true),(''combat_v2_elemental_internal.other_commit_control(jsonb,jsonb)'',''21538535df526b17d42dc91c7a3d4013'',true),(''combat_v2_elemental_internal.other_commit_master_control(jsonb)'',''c1690a97d6d6398360a401098588e56a'',true),(''combat_v2_elemental_internal.other_comparison(uuid,uuid,jsonb,pg_catalog.int4)'',''3b918a70932e681e148f7a90028f2d1c'',true),(''combat_v2_elemental_internal.other_force_from_outcome(uuid,uuid)'',''429727092531f7f07cfa99e06c7808d6'',true),(''combat_v2_elemental_internal.other_narrative_supported(uuid)'',''4a0d496f8d0528005aa3309ed60e3d0b'',true),(''combat_v2_elemental_internal.other_narrative_projection(uuid)'',''8ff935d763f4e4aeac25c3d6d017ecd3'',true),(''combat_v2_elemental_internal.scudo_profile(uuid)'',''92cfb95b3f56d8249d56c7d574e38d26'',true),(''combat_v2_elemental_internal.scudo_prepare_defense(uuid,uuid,uuid,uuid,uuid,jsonb)'',''b5808b034b5a3bcf50b7bcb8336d212a'',true),(''combat_v2_elemental_internal.scudo_declaration_meta(uuid,uuid,uuid,uuid,jsonb)'',''c27749ce44a439b3d59361a59e2337e9'',true),(''combat_v2_elemental_internal.scudo_bind_source(uuid)'',''cb840b147ea888fbfa57e3e55be49697'',true),(''combat_v2_elemental_internal.scudo_source_valid(uuid)'',''eacac569a8408d9e081344eebe12f9e2'',true),(''combat_v2_elemental_internal.scudo_meta(uuid)'',''92d3214d9de700399b263d1ee9ba8f93'',true),(''combat_v2_elemental_internal.scudo_staff_binding(uuid,uuid)'',''bf78d306e9a024a88ab453b9e8317671'',true),(''combat_v2_elemental_internal.scudo_staff_bind(uuid,uuid,uuid)'',''5f0c851bc78380fd88f246ca65fdb7fe'',true),(''combat_v2_elemental_internal.scudo_preset_ready(uuid,uuid)'',''b822c5fd7f3b549d455bbbcbe9e985c5'',true),(''combat_v2_elemental_internal.scudo_control_target(text,uuid,uuid)'',''014ec28c115fd3712b43d4253ffc39a9'',true),(''combat_v2_elemental_internal.scudo_control_apply(text,uuid,uuid,uuid)'',''2730009defb70b8c045be6430f496967'',true),(''combat_v2_elemental_internal.scudo_commit_control(jsonb,jsonb)'',''8b86c31c9d637aeb01beeb1c2fa2d1e7'',true),(''combat_v2_elemental_internal.scudo_commit_master_control(jsonb)'',''9bde876c7796180ea80bea206fe5829f'',true),(''combat_v2_elemental_internal.scudo_ability_meta(uuid,jsonb)'',''029b589a7af1a873e58cd3435bee3343'',true),(''combat_v2_elemental_internal.scudo_quote(uuid)'',''5c768cd419a7166e6e23420d5af3164b'',true),(''combat_v2_elemental_internal.scudo_consumer_options(jsonb)'',''e84aa35091f26367645f35a8815c78b1'',true),(''combat_v2_elemental_internal.scudo_master_options(uuid,pg_catalog.int8)'',''33fb2ed8a14cb05a3414e7be89556659'',true),(''combat_v2_elemental_internal.scudo_prepare_native(uuid,uuid,uuid,uuid,jsonb)'',''df51b64ad4443f0acdde37fbfdd5284e'',true),(''combat_v2_elemental_internal.scudo_narrative(uuid)'',''c580ef1cdbaff1598a7863603aa5c9a3'',true),(''combat_v2_elemental_internal.scarica_contact_range(uuid,uuid)'',''f92feff3bb5167ba034931dcb3832f4e'',true),(''combat_v2_elemental_internal.scarica_contact_witness(uuid,uuid,uuid,uuid)'',''34fb9bc5836831510ebd6e300e60a408'',true),(''combat_v2_elemental_internal.scarica_source_contact_valid(uuid)'',''57ed0bac1c1d36d8fd259010ceab4538'',true)) SELECT 1 FROM expected e LEFT JOIN pg_proc p ON p.oid=to_regprocedure(e.sig) WHERE p.oid IS NULL OR md5(p.prosrc) IS DISTINCT FROM e.hash OR p.prosecdef IS DISTINCT FROM e.sd OR p.proowner IS DISTINCT FROM ''postgres''::regrole OR p.proconfig IS DISTINCT FROM ARRAY[''search_path=""''] OR p.proacl IS DISTINCT FROM ''{postgres=X/postgres}''::aclitem[]) THEN RAISE EXCEPTION ''runtime_elemental_complete_helper_drift'';END IF;
end ','b2f5397b7fba0fe0ce6a12d9e07a0164a2364507aacfc3327d0da7be1ad9e74a',encode(extensions.digest(convert_to(pg_get_functiondef('public.combat_v2_actor_ability(uuid,text,uuid,boolean)'::regprocedure),'UTF8'),'sha256'),'hex'))),'8de6ce1265be1420cc2e89479a8bac98','{"acl": "{postgres=X/postgres}", "nargs": 0, "owner": "postgres", "config": ["search_path=pg_catalog, public, clan_innata_private"], "secdef": true, "strict": false, "defaults": null, "language": "plpgsql", "parallel": "u", "arg_modes": null, "arg_names": null, "arg_types": "", "leakproof": false, "return_oid": "2278", "volatility": "s", "returns_set": false, "variadic_type": "0", "default_arg_count": 0}'::jsonb,'41419'),
('combat_panel_private.multiplication_add_layout_groups(uuid,uuid,jsonb)','a7b90e33513fff4685afb46a21e57b8f','f2515609aa9a224d7f2ff542a3f503c1','{"acl": "{postgres=X/postgres}", "owner": "postgres", "config": ["search_path=\"\""], "secdef": true, "strict": false, "language": "plpgsql", "parallel": "u", "leakproof": false, "volatility": "v"}'::jsonb,'45632'),
('combat_panel_private.multiplication_layout_options_for_figure(uuid,integer,text,uuid,uuid,bigint,integer)','3e4184f1bfe0bafe5cde44b08e552b1a','7b36f3d868c85c3941f120844c286dd9','{"acl": "{postgres=X/postgres}", "owner": "postgres", "config": ["search_path=\"\""], "secdef": true, "strict": false, "language": "plpgsql", "parallel": "u", "leakproof": false, "volatility": "v"}'::jsonb,'45714'),
('public.combat_v2_actor_ability(uuid,text,uuid,boolean)','b6180f3bc0d3ec90d2c18dac3c6f54e8','ec79a59f561042dee9eac224926afe28','{"acl": "{postgres=X/postgres,service_role=X/postgres}", "owner": "postgres", "config": ["search_path=\"\""], "secdef": true, "strict": false, "language": "sql", "parallel": "u", "leakproof": false, "volatility": "s"}'::jsonb,'31311')),
fn AS MATERIALIZED(
 SELECT t.signature,t.expected_source_md5,t.old_ddl_md5,t.contract,t.expected_oid,p.*,n.nspname,l.lanname,
 pg_get_functiondef(p.oid) actual_ddl,pg_get_userbyid(p.proowner) function_owner
 FROM targets t JOIN pg_proc p ON p.oid=to_regprocedure(t.signature)
 JOIN pg_namespace n ON n.oid=p.pronamespace JOIN pg_language l ON l.oid=p.prolang),
headers AS MATERIALIZED(
 SELECT signature,expected_source_md5,old_ddl_md5,contract,expected_oid,
 jsonb_build_object('signature',signature,'oid',oid::text,'nspname',nspname,'proname',proname,'kind',prokind::text,
 'owner',function_owner,'acl',proacl::text,'language',lanname,'config',to_jsonb(proconfig),'secdef',prosecdef,
 'volatility',provolatile::text,'parallel',proparallel::text,'strict',proisstrict,'leakproof',proleakproof,
 'arg_types',proargtypes::text,'all_arg_types',to_jsonb(proallargtypes),'arg_modes',to_jsonb(proargmodes),'arg_names',to_jsonb(proargnames),
 'nargs',pronargs,'default_arg_count',pronargdefaults,'defaults',pg_get_expr(proargdefaults,0),
 'variadic_type',provariadic::text,'return_oid',prorettype::text,'returns_set',proretset,
 'arguments',pg_get_function_arguments(oid),'returns',pg_get_function_result(oid),
 'ddl_md5',md5(actual_ddl),'source_md5',md5(prosrc),'ddl_sha256',encode(extensions.digest(convert_to(actual_ddl,'UTF8'),'sha256'),'hex'),
 'source_sha256',encode(extensions.digest(convert_to(prosrc,'UTF8'),'sha256'),'hex'),
 'ddl_bytes',octet_length(actual_ddl),'source_bytes',octet_length(prosrc))h
 FROM fn),
guard AS MATERIALIZED(
 SELECT count(*)=6 AND bool_and(h->>'source_md5'=expected_source_md5 AND h @> contract
 AND(expected_oid IS NULL OR h->>'oid'=expected_oid)
 AND(old_ddl_md5 IS NULL OR h->>'ddl_md5'<>old_ddl_md5))ok FROM headers),
bundle AS MATERIALIZED(
 SELECT jsonb_build_object('schema_version','tactics-staff-function-proof/1','functions',jsonb_agg(h ORDER BY signature))full_header_manifest,
 jsonb_object_agg(signature,h) target_bodies_after FROM headers HAVING count(*)=6),
witness AS MATERIALIZED(
 SELECT b.*,jsonb_build_object('sha256',public.combat_v2_sha256(full_header_manifest),'source_sha256','70532b3233ce24e12d18396eacb02e71db5a215df46f6ef88f60160a71384cca')compact
 FROM bundle b CROSS JOIN guard g WHERE g.ok) SELECT jsonb_build_object('full_header_manifest',full_header_manifest,'compact',compact)proof FROM witness;
DO $integrated_post$ DECLARE p jsonb;r mission_factory_owner.editor_release_readiness;BEGIN
 SELECT tactics_projection INTO STRICT p FROM pg_temp.tactics_projected;
 SELECT * INTO STRICT r FROM mission_factory_owner.editor_release_readiness WHERE singleton;
IF NOT coalesce((r.revision_sha256=p->>'revision_sha256'AND r.observed_revision_sha256=r.revision_sha256 AND r.canonical_preimage=p->>'canonical_preimage'AND public.combat_v2_sha256(r.canonical_preimage::jsonb)=r.revision_sha256 AND octet_length(r.canonical_preimage)=524117 AND(public.combat_v2_sha256((r.canonical_preimage::jsonb->'db_core')-'sha256'))=r.canonical_preimage::jsonb#>>'{db_core,sha256}'AND(SELECT count(*)=1 AND bool_and(proof->'compact'=r.canonical_preimage::jsonb#>'{db_core,tactics_staff}'AND proof->'full_header_manifest'=p->'full_header_manifest')FROM pg_temp.tactics_after_proof)),false)THEN RAISE EXCEPTION 'TACTICS_INTEGRATED_ROOT_AND_FULL_BUNDLE';END IF;
IF NOT coalesce(((SELECT body FROM pg_temp.tactics_custody)=(SELECT body FROM (SELECT clock_timestamp() AS captured_at,jsonb_build_object(
 'real_pg',(SELECT public.combat_v2_sha256(coalesce(jsonb_agg(to_jsonb(c)-'updated_at'-'last_regen_at' ORDER BY c.id),'[]'::jsonb)) FROM public.characters c WHERE c.id IN('6bceee99-974f-426b-8d92-38b43b4a4267'::uuid,'f335b077-34a1-41c3-94aa-58ec674b649b'::uuid,'2a877f02-4993-4e65-9172-7d29f08c5b86'::uuid)),
 'scorta_mission',(SELECT public.combat_v2_sha256(to_jsonb(m)) FROM public.missions m WHERE m.id='db1588ae-50f2-4c0e-9028-0b94155d94b1'::uuid),
 'scorta_masters',(SELECT public.combat_v2_sha256(coalesce(jsonb_agg(to_jsonb(m) ORDER BY m.id),'[]'::jsonb)) FROM public.master_v2_sessions m WHERE m.mission_id='db1588ae-50f2-4c0e-9028-0b94155d94b1'::uuid),
 'gates',jsonb_build_object(
 'innata',(SELECT to_jsonb(g) FROM clan_innata_narrative_private.gate_v1 g WHERE singleton),
 'hyuga',(SELECT to_jsonb(g) FROM clan_hyuga_private.release_gate g WHERE singleton),
 'facing',(SELECT to_jsonb(g) FROM combat_facing_private.release_gate g WHERE singleton),
 'tactics',(SELECT to_jsonb(g) FROM combat_panel_private.multiplication_tactics_release_gate g WHERE singleton)),
 'party',(SELECT p.capture->'custody' FROM (WITH root AS(SELECT revision_sha256,canonical_preimage::jsonb body FROM mission_factory_owner.editor_release_readiness WHERE singleton),
protected_missions(id)AS(VALUES('6d6c216a-222d-4cba-b2fc-f3e0c199c195'::uuid),('db1588ae-50f2-4c0e-9028-0b94155d94b1'::uuid) UNION SELECT mission_id FROM mission_public_owner.party_launch_scopes_v1),
protected_activations(id)AS(SELECT id FROM mission_ai_board_owner.activations WHERE mission_id IN(SELECT id FROM protected_missions))
SELECT jsonb_build_object('schema_version','innata-all-party-live-capture/1','captured_at',clock_timestamp(),'root_revision',(SELECT revision_sha256 FROM root),
'runtime',(SELECT to_jsonb(x)FROM mission_public_owner.party_launch_runtime_v1 x WHERE singleton),
'client_capsule',(SELECT body#>'{config,party_launch_staff_client}'FROM root),
'client_sha256',(SELECT public.combat_v2_sha256(body->'ui')FROM root),
'edge_bundles_sha256',(SELECT public.combat_v2_sha256(body->'edge_bundles')FROM root),
'capsule_client_matches_ui',(SELECT body#>>'{config,party_launch_staff_client,client_sha256}'=public.combat_v2_sha256(body->'ui')FROM root),
'capsule_edge_matches_bundles',(SELECT body#>>'{config,party_launch_staff_client,edge_bundles_sha256}'=public.combat_v2_sha256(body->'edge_bundles')FROM root),
'custody',jsonb_build_object(
'scopes',(SELECT jsonb_build_object('count',count(*),'sha256',public.combat_v2_sha256(coalesce(jsonb_agg(to_jsonb(x)ORDER BY to_jsonb(x)::text),'[]'::jsonb)))FROM mission_public_owner.party_launch_scopes_v1 x),
'bookings',(SELECT jsonb_build_object('count',count(*),'sha256',public.combat_v2_sha256(coalesce(jsonb_agg(to_jsonb(x)ORDER BY to_jsonb(x)::text),'[]'::jsonb)))FROM public.mission_bookings x WHERE mission_id IN(SELECT id FROM protected_missions)),
'activations',(SELECT jsonb_build_object('count',count(*),'sha256',public.combat_v2_sha256(coalesce(jsonb_agg(to_jsonb(x)ORDER BY to_jsonb(x)::text),'[]'::jsonb)))FROM mission_ai_board_owner.activations x WHERE mission_id IN(SELECT id FROM protected_missions)),
'applicants',(SELECT jsonb_build_object('count',count(*),'sha256',public.combat_v2_sha256(coalesce(jsonb_agg(to_jsonb(x)ORDER BY to_jsonb(x)::text),'[]'::jsonb)))FROM mission_ai_board_owner.applicants x WHERE activation_id IN(SELECT id FROM protected_activations)),
'audit',(SELECT jsonb_build_object('count',count(*),'sha256',public.combat_v2_sha256(coalesce(jsonb_agg(to_jsonb(x)ORDER BY to_jsonb(x)::text),'[]'::jsonb)))FROM mission_ai_board_owner.audit x WHERE activation_id IN(SELECT id FROM protected_activations)),
'simulation_sources',(SELECT jsonb_build_object('count',count(*),'sha256',public.combat_v2_sha256(coalesce(jsonb_agg(to_jsonb(x)ORDER BY to_jsonb(x)::text),'[]'::jsonb)))FROM mission_generic_owner.simulation_sources x WHERE source_mission_id='6d6c216a-222d-4cba-b2fc-f3e0c199c195'::uuid OR carrier_mission_id IN(SELECT id FROM protected_missions))
))capture) p)
) AS body)c)),false)THEN RAISE EXCEPTION 'TACTICS_INTEGRATED_CUSTODY_PRESERVED';END IF;
IF NOT coalesce((NOT EXISTS(SELECT 1 FROM public.combat_v2_sessions WHERE location_id='0b85f354-9cdb-47e1-baf9-3d266bb7e06b'::uuid AND closed_at IS NULL)AND NOT EXISTS(SELECT 1 FROM public.master_v2_sessions WHERE location_id='0b85f354-9cdb-47e1-baf9-3d266bb7e06b'::uuid AND stato NOT IN('chiusa','annullata'))),false)THEN RAISE EXCEPTION 'TACTICS_INTEGRATED_STAFF_STILL_QUIET';END IF;
IF NOT coalesce((clock_timestamp()<'2026-11-07T20:30:58.461822Z'::timestamptz),false)THEN RAISE EXCEPTION 'TACTICS_INTEGRATED_CAMPAIGN_STILL_WITHIN_WINDOW';END IF;
IF NOT coalesce(((SELECT count(*)=1 AND bool_and(to_jsonb(x)='{"db_sha256": "23dd060e0167bebde1208a95072afcaaa548270ed0dd57c504ad51d0977775ad", "created_at": "2026-11-07T14:02:11.620249+00:00", "edge_sha256": "89358158910378b7bd29661bf39f1680ff05e2af0aa32e4dc45e80359b771350", "qualified_at": "2026-11-07T14:02:11.620248+00:00", "client_sha256": "8d4ca65e3fd9d137364a38353726c7873063197167be6a453de9d0e30c59b9b2", "public_enabled": true, "release_sha256": "e9d24578201d8f0b086e9fc079fb657f5d41364145218d8385e878aa659769ce", "contract_version": "mission-public-admission/1", "staff_evidence_ref": "AUTHORIZED_TEST_MANIFEST:sha256:64bdfd1d1afe956ea88f7b4d9e00dfe03613794c3931dd9ec90ceb42209d0b98", "configuration_sha256": "0a229568fd1bc4f08b71a6d93bdc8733319a3b8b71ce5a2d7558ecd7a9ab0d34", "independent_review_ref": "TACTICS-COVERAGE-UI:4af0570ea78b8d79c4b924a5cb42cf20b1c1e57c2b601e742b5421b426524af9"}'::jsonb)FROM mission_public_owner.release_admissions_v1 x WHERE release_sha256='e9d24578201d8f0b086e9fc079fb657f5d41364145218d8385e878aa659769ce')),false)THEN RAISE EXCEPTION 'TACTICS_INTEGRATED_ADMISSION_CAS_PRESERVED';END IF;
IF NOT coalesce(((SELECT count(*)=1 AND bool_and(to_jsonb(x)='{"payload": {"bindings": {"db_sha256": "23dd060e0167bebde1208a95072afcaaa548270ed0dd57c504ad51d0977775ad", "edge_sha256": "89358158910378b7bd29661bf39f1680ff05e2af0aa32e4dc45e80359b771350", "client_sha256": "8d4ca65e3fd9d137364a38353726c7873063197167be6a453de9d0e30c59b9b2", "configuration_sha256": "0a229568fd1bc4f08b71a6d93bdc8733319a3b8b71ce5a2d7558ecd7a9ab0d34"}, "capabilities": [{"key": "mission.narrative.scene", "usage": "phase_transition", "family": "narrative", "qualified": true, "evidence_ref": "/private/tmp/tus-c1266-full86-20261102/db-cause38/FINAL_POSTFLIGHT.json", "phase_allowed": true, "evidence_sha256": "fd8bde6f2a840d70b7a166379b50ce510cc7cd45b5a0750cfd588f612298f888", "allowed_content_kinds": ["mission"]}, {"key": "mission.combat.encounter", "usage": "phase_transition", "family": "combat", "qualified": true, "evidence_ref": "/private/tmp/tus-c1266-full86-20261102/db-cause38/FINAL_POSTFLIGHT.json", "phase_allowed": true, "evidence_sha256": "fd8bde6f2a840d70b7a166379b50ce510cc7cd45b5a0750cfd588f612298f888", "allowed_content_kinds": ["mission"]}], "reuse_evidence": {"scope": "Public native contract compatibility with new gated Staff branches; no fresh clean runtime claim", "source_component": {"scope": "EditorOnly", "schema": "editor-panel-composed-source/1", "base_root": "f7aebda96092a1fd71e26ddda35da84b34e3b0144d14e64ca5da31737feec512", "source_files": {"EDITOR_MISSIONI_RECOVERY.sql": "1abc3e3db469fcfefce80a4e385c276f3b6ffdc9f7d1a15ad8a36b19cc2d16bb", "EDITOR_MISSIONI_ENGINE_SOURCE.sql": "600b181a9a32e3285978e883bc28b1b3c9d8c612a3cb93d7388e63a07101f323", "EDITOR_MISSIONI_AUTHORING_SOURCE.sql": "f56c4c03f09ee387d7490b599b3a164a29dc741de51e0901dcc8e4f31a3710a4"}, "no_content_creation": true, "new_mission_QA_claim": false, "source_review_sha256": "68e618cf186b056d11b45b0e274fe829afa4043d986fb27a68bc485ec0208c2c", "function_identity_contract": "pg-oid/resolved-regprocedure/1", "LAND_GenericUI_Edge_unchanged": true, "baseline_descriptor_reconciliation": {"schema": "editor-root-alias-reconciliation/1", "aliases": [{"path": ["db_core", "reader"], "authority": "Existing f7 all_function_headers, matching unchanged live diagnostic; no body changed", "proof_paths": [["db_core", "all_function_headers", "107"], ["db_core", "c1266_functions", "90"]], "old_descriptor": {"acl": "{postgres=X/postgres,service_role=X/postgres}", "oid": "308755", "owner": "postgres", "config": ["search_path=\"\""], "secdef": true, "ddl_md5": "f50ea1ca8ae51be85347c731c486b1d3", "signature": "mission_generic_director_narration_next_v1(uuid,jsonb,uuid)", "source_md5": "ed3c36b73f286d077e7641deb79fd79a"}, "current_descriptor": {"acl": "{postgres=X/postgres,service_role=X/postgres}", "oid": "308755", "owner": "postgres", "config": ["search_path=\"\""], "secdef": true, "ddl_md5": "1810130dfa582fe506de8215170088d3", "signature": "mission_generic_director_narration_next_v1(uuid,jsonb,uuid)", "source_md5": "9daaaa9bc4a0ea30b022d2a7cd6d3456"}, "authoritative_descriptor": {"acl": "{postgres=X/postgres,service_role=X/postgres}", "oid": 308755, "owner": "postgres", "config": ["search_path=\"\""], "secdef": true, "ddl_md5": "1810130dfa582fe506de8215170088d3", "language": "plpgsql", "signature": "public.mission_generic_director_narration_next_v1(uuid,jsonb,uuid)", "source_md5": "9daaaa9bc4a0ea30b022d2a7cd6d3456", "volatility": "v"}}, {"path": ["db_core", "tick_writer"], "authority": "Existing f7 all_function_headers, matching unchanged live diagnostic; no body changed", "proof_paths": [["db_core", "all_function_headers", "62"]], "old_descriptor": {"acl": "{postgres=X/postgres,service_role=X/postgres}", "oid": "109829", "owner": "postgres", "config": ["search_path=\"\""], "secdef": true, "ddl_md5": "deed503323977aab3d4d0175a0e5c0e4", "signature": "mission_generic_staff_tick_v1(uuid,uuid,text,uuid)", "source_md5": "872497f9001b5f80ff8b66ce94a90336"}, "current_descriptor": {"acl": "{postgres=X/postgres,service_role=X/postgres}", "oid": "109829", "owner": "postgres", "config": ["search_path=\"\""], "secdef": true, "ddl_md5": "9ed5587c3843179b3052f638376820d9", "signature": "mission_generic_staff_tick_v1(uuid,uuid,text,uuid)", "source_md5": "337ec76aee4b8d282ab5dee40dc29dac"}, "authoritative_descriptor": {"acl": "{postgres=X/postgres,service_role=X/postgres}", "oid": 109829, "owner": "postgres", "config": ["search_path=\"\""], "secdef": true, "ddl_md5": "9ed5587c3843179b3052f638376820d9", "language": "plpgsql", "signature": "public.mission_generic_staff_tick_v1(uuid,uuid,text,uuid)", "source_md5": "337ec76aee4b8d282ab5dee40dc29dac", "volatility": "v"}}, {"path": ["db_core", "cached_recovery"], "authority": "Existing f7 all_function_headers, matching unchanged live diagnostic; no body changed", "proof_paths": [["db_core", "all_function_headers", "72"]], "old_descriptor": {"acl": "{postgres=X/postgres,service_role=X/postgres}", "oid": "150538", "owner": "postgres", "config": ["search_path=\"\""], "secdef": true, "ddl_md5": "e5af9b73f6de99fcfa8ebf6853857228", "signature": "mission_generic_staff_republish_failed_v1(uuid,uuid,uuid)", "source_md5": "bd247db309ef2b683850a30df1b93c38"}, "current_descriptor": {"acl": "{postgres=X/postgres,service_role=X/postgres}", "oid": "150538", "owner": "postgres", "config": ["search_path=\"\"", "statement_timeout=30s"], "secdef": true, "ddl_md5": "3d1013c453de2762a7ddd27b7a2ca691", "signature": "mission_generic_staff_republish_failed_v1(uuid,uuid,uuid)", "source_md5": "b718f0f920e7169065b0fef492b85d67"}, "authoritative_descriptor": {"acl": "{postgres=X/postgres,service_role=X/postgres}", "oid": 150538, "owner": "postgres", "config": ["search_path=\"\"", "statement_timeout=30s"], "secdef": true, "ddl_md5": "3d1013c453de2762a7ddd27b7a2ca691", "language": "plpgsql", "signature": "public.mission_generic_staff_republish_failed_v1(uuid,uuid,uuid)", "source_md5": "b718f0f920e7169065b0fef492b85d67", "volatility": "v"}}], "baseline_root": "f7aebda96092a1fd71e26ddda35da84b34e3b0144d14e64ca5da31737feec512", "diagnostic_sha256": "f41f0a6c18ee9647950eda4d04c9857f79bc2f19cd66ad9019e80a3ef6dd499d"}}, "historical_status": "FAILED_NONCLEAN_WITH_SCOPED_RECOVERY", "new_mission_QA_claim": false, "accepted_user_decision": {"ref": "management/candidati/NARRATORE-UNIFICATO_2026-09-02/candidato/exam_human_master/C1266_PUBLIC87_RELEASE_DECISION.json", "scope": "DiscussioniV9_already_played_narrator", "sha256": "8227b41536cfd34fcb1200bf12cd52adff31b14ce379e2881ff1d50cd50d5c00", "decision": "OPEN_ALREADY_TESTED_VERSION_WITH_REVIEWED_PUBLIC_WIRING", "new_qa_requested": false, "clean_runtime_claim": false}, "combat_innata_component": {"contracts": ["mission-role-command/3", "mission-role-submit/2", "byakugan-facing/1", "combat-multiplication-tactics/1"], "availability": "staff_only_world_new_features_false", "review_inputs": {"/Users/antonello/Desktop/theuntoldstory/management/candidati/COMBAT-COMPOSITE_2026-09-01/candidato/INNATA_BRIDGE_REVIEW.json": "f3f686a8fd37242d7e4a28e8ee9dad2d5b96176dc489d0028dba475c83735562", "/Users/antonello/Desktop/theuntoldstory/management/candidati/COMBAT-COMPOSITE_2026-09-01/candidato/INNATA_UPKEEP_REVIEW.json": "cc5e024b90545c5ec8df8398e482d219c7ff2f449d07f263aabd7e38d98eb8fb", "/Users/antonello/Desktop/theuntoldstory/management/candidati/COMBAT-COMPOSITE_2026-09-01/candidato/COMBAT_CURRENT_RELEASE_REVIEW.json": "c0df6909c47d4344ccc49678b19ea9c0fd563ee19f6242cb3d4788cf5d046a0c", "/Users/antonello/Desktop/theuntoldstory/management/candidati/COMBAT-COMPOSITE_2026-09-01/candidato/COMBAT_COMPONENTS_SOURCE_REVIEW.json": "82b7307e774461dc3b3d27fde329a7693e964bedbf4aa603705d355cbe781f41", "/Users/antonello/Desktop/theuntoldstory/management/candidati/COMBAT-COMPOSITE_2026-09-01/candidato/COMBAT_INNATA_SEAL_CLOSURE_REVIEW.json": "c3b92f8f93d5b15811fe4787cc42cadb263e8b588f504a8fbaca1dce984bb276", "/Users/antonello/Desktop/theuntoldstory/management/candidati/NARRATORE-UNIFICATO_2026-09-02/candidato/exam_human_master/COMBAT_MISSIONI_UI_REVIEW2.json": "e4f8c25ab6db9931aaeba8689c4af82352dbeeb7f233e3ec2f2ea56a3c61ad3a"}, "source_inputs": {"/Users/antonello/Desktop/theuntoldstory/management/candidati/COMBAT-COMPOSITE_2026-09-01/candidato/FACING_SOURCE.sql": "96a3941ea227bf64d365826a8f0886b7bf8a98396c8f75e40167f157d399970e", "/Users/antonello/Desktop/theuntoldstory/management/candidati/COMBAT-COMPOSITE_2026-09-01/candidato/INNATA_LIFECYCLE_SOURCE.sql": "a8002313cfbc3dcc60112278ec69b9fe2fe42db9380f57ba34ea640a24044ed1", "/Users/antonello/Desktop/theuntoldstory/management/candidati/COMBAT-COMPOSITE_2026-09-01/candidato/COMBAT_TACTICS_CANDIDATO.sql": "22312a8ea771140a49d906a4fcce2bf05d285e9b3a9fdfb1007a72570e52a38a", "/Users/antonello/Desktop/theuntoldstory/management/candidati/COMBAT-COMPOSITE_2026-09-01/candidato/INNATA_INTEGRAZIONE_SOURCE.sql": "229115a889fd663c631a6d13311901fd53a14dc373f76f4ab52d749d2cae363a", "/Users/antonello/Desktop/theuntoldstory/management/candidati/COMBAT-COMPOSITE_2026-09-01/candidato/INNATA_ELIGIBILITY_COMPAT_SOURCE.sql": "47045f209564829fd5009af8ce68a395d83649a45f4d37ee531198179968b894"}, "schema_version": "combat-innata-integrated-component/1", "consumer_inputs": {"/Users/antonello/Desktop/theuntoldstory/management/candidati/NARRATORE-UNIFICATO_2026-09-02/candidato/exam_human_master/INNATA_COMMAND_LAND.html": "ed6e01805df4f11da916b2310b9af9b9ac5a6fa1bfb6e61126d31124d88290ce", "/Users/antonello/Desktop/theuntoldstory/management/candidati/NARRATORE-UNIFICATO_2026-09-02/candidato/exam_human_master/INNATA_COMMAND_REVIEW.md": "a04a97919dddcd614a5b27c7c71daec145321cacf54d10fbaa1212cc7c445b4c", "/Users/antonello/Desktop/theuntoldstory/management/candidati/NARRATORE-UNIFICATO_2026-09-02/candidato/exam_human_master/COMBAT_MISSIONI_REGOLE.md": "737a624b3883681459090369156567d8c8665d68fde333fa5d44ca1bffdfa5c2", "/Users/antonello/Desktop/theuntoldstory/management/candidati/NARRATORE-UNIFICATO_2026-09-02/candidato/exam_human_master/COMBAT_MISSIONI_ADMIN.html": "871552ea63704813c65d7157daca023879e16a6e2fbd27975b4153a8c3b6e393", "/Users/antonello/Desktop/theuntoldstory/management/candidati/NARRATORE-UNIFICATO_2026-09-02/candidato/exam_human_master/COMBAT_MISSIONI_EDITOR.mjs": "bbc1f44089aab17f29585459a350ea2615194cc6aec1a01ce83c7097652dfea6", "/Users/antonello/Desktop/theuntoldstory/management/candidati/NARRATORE-UNIFICATO_2026-09-02/candidato/exam_human_master/COMBAT_MISSIONI_regole.html": "e69d00d5ca446d6bf4af5e0f070e4adea14592ab0cc1adb2a22d642fa85d865e", "/Users/antonello/Desktop/theuntoldstory/management/candidati/NARRATORE-UNIFICATO_2026-09-02/candidato/exam_human_master/COMBAT_MISSIONI_CREATION.mjs": "8a6e0f5b50ba58164ee1491086509169d39ba4b59efb9caf91dac5ce92bf4fd3", "/Users/antonello/Desktop/theuntoldstory/management/candidati/NARRATORE-UNIFICATO_2026-09-02/candidato/exam_human_master/INNATA_COMMAND_GENERIC_UI.mjs": "e7f32894f96f304af494eae7d56e6ef11b6680aff6a41f24df8420a22025d63b", "/Users/antonello/Desktop/theuntoldstory/management/candidati/NARRATORE-UNIFICATO_2026-09-02/candidato/exam_human_master/INNATA_COMMAND_EDGE_FILES.json": "33276144f4b9352b5f3b30c841e8985247aac735ab70ce95dd84762a9f23af8e", "/Users/antonello/Desktop/theuntoldstory/management/candidati/NARRATORE-UNIFICATO_2026-09-02/candidato/exam_human_master/INNATA_COMMAND_CONSUMERS_MANIFEST.json": "ce2cdc2286ccd3902294faa1d71e8367095a86ba3bb8582b08d7e8902ebb455a"}, "capture_provenance": {"all_ok": true, "extra_rows": 698, "extra_query_sha256": "8aa4503f64222d0e3a85d510480f2569d7085e3c307036f01969785e26958279", "actualB_file_sha256": "fc8dae2b68322e2ad6ab5ff7e82f3394b8473fb6c4a8ecdd72a90cc152571291", "extra_actual_file_sha256": "e11993185cd47554dc99b437ac23458d86f0c0f756e0419a13ad962ca297b7dd"}, "new_mission_QA_claim": false, "parent_editor_release": "b21c59c642be4734803859a2a28df51f7412cd9bbef8c8606a80a7e4553e9060", "cumulative_counters_preserved": true}, "origin_qualification_sha256": "fd8bde6f2a840d70b7a166379b50ce510cc7cd45b5a0750cfd588f612298f888", "origin_qualification_release": "f7aebda96092a1fd71e26ddda35da84b34e3b0144d14e64ca5da31737feec512"}, "schema_version": "mission-engine-qualification/1", "revision_sha256": "e9d24578201d8f0b086e9fc079fb657f5d41364145218d8385e878aa659769ce", "runtime_profile": "mission-narrative-admission/4 + provider-input/6 + scene-public/2", "legacy_adoptions": [{"mission_id": "6d6c216a-222d-4cba-b2fc-f3e0c199c195", "capability_sha256": "46d1f0d2c3c0d5769f465e1bdc6ce34ba97d7a485923128729080156bc8b90e7", "publication_request": "3ff627ec-dbee-423a-9879-8e37f7ad5510", "origin_release_sha256": "f7aebda96092a1fd71e26ddda35da84b34e3b0144d14e64ca5da31737feec512", "source_content_sha256": "f5ea8c75ac7ce660f6b29214427d13aa971be9fa576ac246a12890e4a970b605"}], "authoring_profile": "mission-ai-authoring/1", "financial_profile": {"limits": {"http_limit": 28, "generation_limit": 14, "input_tokens_limit": 24000, "output_tokens_limit": 20000, "scene_cost_budget_usd": "0.3136"}, "pricing": {"model": "gpt-6-luna", "store": false, "reasoning_effort": "high", "input_usd_million": 0.1, "max_output_tokens": 20000, "output_usd_million": 0.5, "count_upper_cost_usd": "0.0124", "generation_upper_cost_usd": "0.0124"}, "world_mode": "scene_finite", "schema_version": "mission-scene-financial-evidence/1", "staff_spend_usd": "0.15927630", "tariff_evidence_sha256": "d7bc0f5b501cbc9d956e681556e05a367c54a6caa7aa050020a95b6daf1354d3", "financial_qualification_sha256": "d8da6486b29f5e6b57272eb9d21660518cdcb57f12ed69209e12f32c37e2d5c0"}, "independent_review": {"P0": 0, "P1": 0, "P2": 0, "ref": "TACTICS-COVERAGE-UI:4af0570ea78b8d79c4b924a5cb42cf20b1c1e57c2b601e742b5421b426524af9", "sha256": "4af0570ea78b8d79c4b924a5cb42cf20b1c1e57c2b601e742b5421b426524af9"}}, "created_at": "2026-11-07T14:02:11.632534+00:00", "created_by": "postgres", "request_key": "ccf4fcc5-3879-5efc-87f3-026287288146", "payload_sha256": "b740c73f14094ae8ba76bdeb7297ab245d84ac7a08b3de89e309f75f88db037c", "release_sha256": "e9d24578201d8f0b086e9fc079fb657f5d41364145218d8385e878aa659769ce", "positive_staff_evidence_ref": "/private/tmp/tus-c1266-full86-20261102/db-cause38/FINAL_POSTFLIGHT.json", "authorized_test_manifest_ref": "/private/tmp/tus-c1266-full86-20261102/PLAN.json"}'::jsonb)FROM mission_public_owner.public_qualification_attestations_v1 x WHERE release_sha256='e9d24578201d8f0b086e9fc079fb657f5d41364145218d8385e878aa659769ce')),false)THEN RAISE EXCEPTION 'TACTICS_INTEGRATED_QUALIFICATION_CAS_PRESERVED';END IF;
IF NOT coalesce(((SELECT coalesce(jsonb_agg(to_jsonb(x)ORDER BY event_id),'[]'::jsonb)='[{"reason": "Preserve existing authority during reviewed coverage UI grouping correction", "event_id": "3b7a3f5d-b827-5819-b850-50b681814c80", "actor_user": null, "created_at": "2026-11-07T14:02:11.630145+00:00", "profile_key": "mission-ai-authoring/1", "control_version": 1, "runtime_enabled": true, "authoring_enabled": true, "engine_release_sha256": "e9d24578201d8f0b086e9fc079fb657f5d41364145218d8385e878aa659769ce", "expected_control_version": 0}]'::jsonb FROM mission_public_owner.engine_profile_events_v1 x WHERE engine_release_sha256='e9d24578201d8f0b086e9fc079fb657f5d41364145218d8385e878aa659769ce')),false)THEN RAISE EXCEPTION 'TACTICS_INTEGRATED_PROFILES_CAS_PRESERVED';END IF;
IF NOT coalesce(((SELECT coalesce(jsonb_agg(to_jsonb(x)ORDER BY request_key),'[]'::jsonb)='[{"payload": {"kind": "compatible_adoption", "PG_count": 2, "PNG_count": 2, "created_at": "2026-11-07T14:02:11.636107+00:00", "created_by": "f0856d53-83a6-4de0-bc0c-12c87916e665", "mission_id": "6d6c216a-222d-4cba-b2fc-f3e0c199c195", "plan_sha256": "285d6315d7a011e970610cb192d6bbbd3cc2b8bd40a6e6d2e843287ee0992199", "request_key": "594e9ce5-2274-52d3-8fa9-bf1be850bfbf", "definition_id": "11bd5367-fc6f-5ec6-bf91-0142b2368824", "config_version": 1, "schema_version": "mission-content-admission/1", "map_refs_sha256": "53e735d376934c0ce6c0155463bcebc8ea59e3c5576dcd5ffc8b3db04a1793ca", "npc_refs_sha256": "3aed0f00241c72371adde5e9dcf7276129f069be212eb0ad31c06785a07e2de7", "plan_version_id": "4da7191e-689f-5aa1-b377-cfdda0da5278", "supported_modes": ["ai"], "capability_sha256": "46d1f0d2c3c0d5769f465e1bdc6ce34ba97d7a485923128729080156bc8b90e7", "definition_sha256": "4124a2ff1cd6e3d61b668ec5b341ed18a5e856e3f6140e6b1c5cf3ae703e5ca8", "media_refs_sha256": "04b0a7d1801e6cdbca4045abd0a8787a771db9dc30c93c4b794f8f6ddcaf3022", "publication_request": "3ff627ec-dbee-423a-9879-8e37f7ad5510", "preview_basis_sha256": "4d2f2f0d49b7d2be79d1c71ade8fdc265674b8bffe7a03a0031e1c131afc5c80", "engine_release_sha256": "e9d24578201d8f0b086e9fc079fb657f5d41364145218d8385e878aa659769ce", "origin_release_sha256": "f7aebda96092a1fd71e26ddda35da84b34e3b0144d14e64ca5da31737feec512", "source_content_sha256": "f5ea8c75ac7ce660f6b29214427d13aa971be9fa576ac246a12890e4a970b605", "validation_contract_sha256": "cd80595f65294072378b3a3bd2ac18148ab75e3099c260562ba1272e04c3f7e3", "required_capabilities_sha256": "49fe134f561273f28e8071b63c45886341371b67d028f06e6b7d8f8d4108e817"}, "created_at": "2026-11-07T14:02:11.636454+00:00", "mission_id": "6d6c216a-222d-4cba-b2fc-f3e0c199c195", "request_key": "594e9ce5-2274-52d3-8fa9-bf1be850bfbf", "config_version": 1, "payload_sha256": "b9de43b31a3ece64088aab7276e0148c4bb90e66a56070491b41420199ffa512", "publication_request": "3ff627ec-dbee-423a-9879-8e37f7ad5510", "engine_release_sha256": "e9d24578201d8f0b086e9fc079fb657f5d41364145218d8385e878aa659769ce"}]'::jsonb FROM mission_public_owner.mission_content_admissions_v1 x WHERE engine_release_sha256='e9d24578201d8f0b086e9fc079fb657f5d41364145218d8385e878aa659769ce')),false)THEN RAISE EXCEPTION 'TACTICS_INTEGRATED_CONTENTS_CAS_PRESERVED';END IF;
IF NOT coalesce(((SELECT (to_jsonb(party_live)-'release_sha256')='{"singleton": true, "staff_enabled": true, "public_enabled": true}'::jsonb AND party_live.release_sha256=r.revision_sha256 FROM mission_public_owner.party_launch_runtime_v1 party_live WHERE singleton)),false)THEN RAISE EXCEPTION 'TACTICS_INTEGRATED_PARTY_FLAGS_PRESERVED';END IF;
END $integrated_post$;
SELECT tactics_projection AS integrated_postddl_capture FROM pg_temp.tactics_projected;
ROLLBACK;
