-- Human34 aggregatedcorrection1 CONDITIONAL binder; only after reviewed Human34 install AND firstactualterminalconfirmed AND normalUIsecondprepare. No SID2 invented. Same exact sourcecontrols/newRoot authority required.
-- CONDITIONAL SOURCE: second own prepared scene only after first closure. Root must supply genuine fresh reviewed evidence after normal UI prepare.
-- No apply, no Auth impersonation, no session start or Native optin insertion.
BEGIN;
SET LOCAL search_path=pg_catalog;
SET LOCAL lock_timeout='5s';
DO $human_c463$
DECLARE
 ev jsonb:=nullif(current_setting('tus_human_c463.root_evidence',true),'')::jsonb;
 ctrl mission_factory_owner.c463_optin_control;
 human_ctrl mission_factory_owner.c444_runtime_control;
 kind_ctrl mission_factory_owner.c416_kind_admission;
 master_row public.master_v2_sessions;
 source_row mission_factory_owner.quest_run_sources;
 binding_row mission_factory_owner.c384_human_bindings;
 prepared_row mission_factory_owner.c395_prepared_sources;
 runtime_row public.mission_run_state;
 prev_source mission_factory_owner.quest_run_sources;prev_master public.master_v2_sessions;prev_binding mission_factory_owner.c384_human_bindings;terminal_row mission_factory_owner.quest_terminal_receipts;prev_episode mission_factory_owner.quest_episodes;prev_arc mission_factory_owner.quest_arcs;prev_runtime public.mission_run_state;terminal_event public.mission_run_events;terminal_outbox public.mission_run_outbox;has_next boolean;
 actor_ids uuid[];sid uuid;lease_end timestamptz;changed integer;pin jsonb;actual jsonb;
BEGIN
 IF current_user IS DISTINCT FROM 'postgres' OR ev IS NULL
 OR NOT mission_factory_owner.keys_exact_v2(ev,ARRAY['schema_version','operation','session_id','previous_session_id','protected_postflight_sha256','previous_terminal_sha256','source_getter_proof_sha256','expected_protected_md5','prepare_request_key','expected_source_sha256','expected_control_version','expected_c463','expected_c444','expected_c416','review_sha256','review_findings','authority_sha256','authority_ref','review_ref','permit_expires_at','function_pins','prepare_receipt_sha256','baseline_sha256','integrated_manifest_sha256'])
 OR (ev->>'schema_version') IS DISTINCT FROM 'human-land-c463-root/1'
 OR (ev->>'operation') IS DISTINCT FROM 'append_second_prepared_human_session'
 OR (ev->'review_findings') IS DISTINCT FROM '[0,0,0]'::jsonb
 OR coalesce(ev->>'review_sha256','') !~ '^[0-9a-f]{64}$'
 OR coalesce(ev->>'authority_sha256','') !~ '^[0-9a-f]{64}$'
 OR nullif(btrim(ev->>'authority_ref'),'') IS NULL
 OR nullif(btrim(ev->>'review_ref'),'') IS NULL
 OR (ev->>'session_id') IS NULL OR (ev->>'prepare_request_key') IS NULL
 OR coalesce(ev->>'expected_source_sha256','') !~ '^[0-9a-f]{64}$'
 OR (ev->>'expected_control_version') IS DISTINCT FROM '1'
 OR coalesce(ev->>'prepare_receipt_sha256','') !~ '^[0-9a-f]{64}$'
 OR coalesce(ev->>'baseline_sha256','') !~ '^[0-9a-f]{64}$'
 OR coalesce(ev->>'integrated_manifest_sha256','') !~ '^[0-9a-f]{64}$'
 OR (ev->>'session_id')::uuid=(ev->>'prepare_request_key')::uuid
 OR (ev->>'previous_session_id')::uuid IS NULL OR (ev->>'previous_session_id')::uuid=(ev->>'session_id')::uuid
 OR coalesce(ev->>'protected_postflight_sha256','') !~ '^[0-9a-f]{64}$'
 OR coalesce(ev->>'previous_terminal_sha256','') !~ '^[0-9a-f]{64}$'
 OR coalesce(ev->>'source_getter_proof_sha256','expected_protected_md5','') !~ '^[0-9a-f]{64}$'
 OR (ev->>'permit_expires_at') IS NULL
 OR (ev->>'permit_expires_at')::timestamptz<=statement_timestamp()
 OR (ev->>'permit_expires_at')::timestamptz>statement_timestamp()+interval '15 minutes'
 THEN RAISE EXCEPTION 'HUMAN_C463_GENUINE_PREPARED_ROOT_SCOPE_REQUIRED';END IF;
 sid:=(ev->>'session_id')::uuid;
 PERFORM pg_advisory_xact_lock(hashtextextended('human-land-c463-bind',13102026));
 LOCK TABLE mission_factory_owner.c463_optin_control,mission_factory_owner.c444_runtime_control,
 mission_factory_owner.c416_kind_admission,mission_factory_owner.c384_control,mission_factory_owner.c395_control,mission_factory_owner.c407_control,mission_factory_owner.c412_control IN SHARE ROW EXCLUSIVE MODE;
 SELECT * INTO STRICT ctrl FROM mission_factory_owner.c463_optin_control WHERE singleton FOR UPDATE;
 SELECT * INTO STRICT human_ctrl FROM mission_factory_owner.c444_runtime_control WHERE singleton FOR SHARE;
 SELECT * INTO STRICT kind_ctrl FROM mission_factory_owner.c416_kind_admission WHERE singleton FOR SHARE;
 IF to_jsonb(ctrl) IS DISTINCT FROM (ev->'expected_c463')
 OR to_jsonb(human_ctrl) IS DISTINCT FROM (ev->'expected_c444')
 OR to_jsonb(kind_ctrl) IS DISTINCT FROM (ev->'expected_c416')
 OR NOT ctrl.enabled OR ctrl.master_user_ids IS DISTINCT FROM ARRAY['f0856d53-83a6-4de0-bc0c-12c87916e665']::uuid[]
 OR ctrl.session_ids IS DISTINCT FROM ARRAY[(ev->>'previous_session_id')::uuid]
 OR ctrl.bound_at IS NULL OR ctrl.bound_at>statement_timestamp() OR ctrl.expires_at<=statement_timestamp() OR ctrl.review_sha256 IS NULL
 OR NOT human_ctrl.enabled OR human_ctrl.bound_at>statement_timestamp() OR human_ctrl.expires_at<=statement_timestamp()
 OR NOT kind_ctrl.enabled OR kind_ctrl.bound_at>statement_timestamp() OR kind_ctrl.expires_at<=statement_timestamp()
 OR mission_factory_owner.c416_kind_live_v1() IS DISTINCT FROM true OR mission_factory_owner.c444_enabled_v1() IS DISTINCT FROM true
 OR cardinality(kind_ctrl.allowed_auth_ids) IS DISTINCT FROM 2
 OR NOT(kind_ctrl.allowed_auth_ids @> ARRAY['f0856d53-83a6-4de0-bc0c-12c87916e665','b4952ed5-5ce0-49c0-9f2b-8fd5dcd89b4b']::uuid[])
 THEN RAISE EXCEPTION 'HUMAN_C463_CONTROL_BASELINE_DRIFT';END IF;
 IF jsonb_build_object('c384',(SELECT to_jsonb(x) FROM mission_factory_owner.c384_control x),'c395',(SELECT to_jsonb(x) FROM mission_factory_owner.c395_control x),'c407',(SELECT to_jsonb(x) FROM mission_factory_owner.c407_control x),'c412',(SELECT to_jsonb(x) FROM mission_factory_owner.c412_control x)) IS DISTINCT FROM $controls${"c384":{"enabled":true,"singleton":true},"c395":{"singleton":true,"start_enabled":true,"prepare_enabled":true},"c407":{"singleton":true,"d100_enabled":true,"review_sha256":"01c12d07cb0d08a04a3a853e4aed9fb154298a879f7ab446a04bfc51147768ac","admission_enabled":true,"manual_fato_enabled":true},"c412":{"singleton":true,"review_sha256":"01c12d07cb0d08a04a3a853e4aed9fb154298a879f7ab446a04bfc51147768ac","runtime_enabled":true,"terminal_enabled":true,"authoring_enabled":true}}$controls$::jsonb THEN RAISE EXCEPTION 'HUMAN_C463_FOUR_CONTROL_DRIFT';END IF;
 IF (ev->'function_pins') IS DISTINCT FROM $pins$[{"acl":"{postgres=X/postgres,service_role=X/postgres}","oid":"31313","owner":"postgres","config":["search_path=\"\""],"secdef":true,"strict":false,"ddl_md5":"b6e04b4d804ca90d1883a105097cfeee","returns":"void","body_md5":"15ffdb5fb1046d4dec87b51fe02a07c9","defaults":null,"language":"plpgsql","parallel":"u","arg_modes":null,"arg_names":["p_session"],"signature":"public.master_v2_lock_scope(uuid)","volatility":"v","input_types":"2950","returns_set":false,"all_arg_types":null,"default_count":0},{"acl":"{postgres=X/postgres}","oid":"43060","owner":"postgres","config":["search_path=\"\""],"secdef":true,"strict":false,"ddl_md5":"255e8d73cdd7c3814132d71f0f45b1b5","returns":"boolean","body_md5":"6c865d07f0cb55b7d1f1a14a3f6e12b6","defaults":"false","language":"sql","parallel":"u","arg_modes":null,"arg_names":["p_location","p_principals","p_provider"],"signature":"combat_consumer_private.staff_test_allowed(uuid,uuid[],boolean)","volatility":"s","input_types":"2950 2951 16","returns_set":false,"all_arg_types":null,"default_count":1},{"acl":"{postgres=X/postgres}","oid":"279627","owner":"postgres","config":["search_path=\"\""],"secdef":true,"strict":false,"ddl_md5":"fd612670979a9f7bbc91ee3bc5367920","returns":"jsonb","body_md5":"56dc0aaf7b5cde324f58947752510d50","defaults":null,"language":"plpgsql","parallel":"u","arg_modes":null,"arg_names":["p_session"],"signature":"mission_factory_owner.c395_source_assert_v1(uuid)","volatility":"v","input_types":"2950","returns_set":false,"all_arg_types":null,"default_count":0},{"acl":"{postgres=X/postgres}","oid":"279634","owner":"postgres","config":["search_path=\"\""],"secdef":true,"strict":false,"ddl_md5":"1e98938354fcb8e27cf826ab90f22770","returns":"void","body_md5":"ef0a29b5053665ad13f2df4fb57cccd3","defaults":null,"language":"plpgsql","parallel":"u","arg_modes":null,"arg_names":["p_session"],"signature":"mission_factory_owner.c407_identity_v1(uuid)","volatility":"s","input_types":"2950","returns_set":false,"all_arg_types":null,"default_count":0},{"acl":"{postgres=X/postgres}","oid":"279635","owner":"postgres","config":["search_path=\"\""],"secdef":true,"strict":false,"ddl_md5":"81648004bde571b78c0161701574b22c","returns":"void","body_md5":"ee1cd8d251f1eebbc056baf69b019239","defaults":null,"language":"plpgsql","parallel":"u","arg_modes":null,"arg_names":["p_session","p_gate"],"signature":"mission_factory_owner.c407_active_v1(uuid,text)","volatility":"v","input_types":"2950 25","returns_set":false,"all_arg_types":null,"default_count":0},{"acl":"{postgres=X/postgres}","oid":"279676","owner":"postgres","config":["search_path=\"\""],"secdef":true,"strict":false,"ddl_md5":"ca836584b84f114ede05277e91610235","returns":"boolean","body_md5":"96766167969aff87b3b11452fd15c598","defaults":null,"language":"sql","parallel":"u","arg_modes":null,"arg_names":null,"signature":"mission_factory_owner.c416_kind_live_v1()","volatility":"s","input_types":"","returns_set":false,"all_arg_types":null,"default_count":0},{"acl":"{postgres=X/postgres}","oid":"279768","owner":"postgres","config":["search_path=\"\""],"secdef":true,"strict":false,"ddl_md5":"2b8d0af96cf3601f48bbfe9f862c9823","returns":"boolean","body_md5":"75fcad93b0da5fee0fc6b7af652a5e85","defaults":null,"language":"sql","parallel":"u","arg_modes":null,"arg_names":null,"signature":"mission_factory_owner.c444_enabled_v1()","volatility":"s","input_types":"","returns_set":false,"all_arg_types":null,"default_count":0},{"acl":"{postgres=X/postgres}","oid":"279866","owner":"postgres","config":["search_path=\"\""],"secdef":true,"strict":false,"ddl_md5":"460a6fef179423578c2782fd8091c2f6","returns":"trigger","body_md5":"4f4fe435034cb4a33f8a58107b1c3c4f","defaults":null,"language":"plpgsql","parallel":"u","arg_modes":null,"arg_names":null,"signature":"mission_factory_owner.c463_optin_journal_guard_v1()","volatility":"v","input_types":"","returns_set":false,"all_arg_types":null,"default_count":0},{"acl":"{postgres=X/postgres}","oid":"279871","owner":"postgres","config":["search_path=\"\""],"secdef":true,"strict":false,"ddl_md5":"60108d2c094296d32c8dcad541d54428","returns":"jsonb","body_md5":"020dee2782683a69b1d1ca9237609db9","defaults":null,"language":"plpgsql","parallel":"u","arg_modes":null,"arg_names":["p_session"],"signature":"mission_factory_owner.c463_optin_identity_v1(uuid)","volatility":"s","input_types":"2950","returns_set":false,"all_arg_types":null,"default_count":0},{"acl":"{postgres=X/postgres,authenticated=X/postgres}","oid":"279873","owner":"postgres","config":["search_path=\"\""],"secdef":true,"strict":false,"ddl_md5":"958a643b431c4a7612b88ac865bf52d8","returns":"jsonb","body_md5":"843f235c8e31de941a2023c0d7a50765","defaults":null,"language":"plpgsql","parallel":"u","arg_modes":null,"arg_names":["p_session","p_request"],"signature":"public.mission_factory_quest_human_regia_optin_receipt_v1(uuid,uuid)","volatility":"s","input_types":"2950 2950","returns_set":false,"all_arg_types":null,"default_count":0},{"acl":"{postgres=X/postgres,authenticated=X/postgres}","oid":"279875","owner":"postgres","config":["search_path=\"\""],"secdef":true,"strict":false,"ddl_md5":"2aa278f951180e9430b9bcee31d0338f","returns":"jsonb","body_md5":"e02138befd9ab9267faaa3582afb1ad1","defaults":null,"language":"plpgsql","parallel":"u","arg_modes":null,"arg_names":["p_session","p_expected_control_version","p_expected_source_sha256","p_request"],"signature":"public.mission_factory_quest_human_regia_optin_v1(uuid,bigint,text,uuid)","volatility":"v","input_types":"2950 20 25 2950","returns_set":false,"all_arg_types":null,"default_count":0},{"acl":"{postgres=X/postgres}","oid":"279880","owner":"postgres","config":["search_path=\"\""],"secdef":true,"strict":false,"ddl_md5":"0715b34161c0e9499fea59b62f8910df","returns":"void","body_md5":"2f767c1ed8560bfd4bf96c8b04681d2a","defaults":null,"language":"plpgsql","parallel":"u","arg_modes":null,"arg_names":null,"signature":"mission_factory_owner.c463_optin_complete_assert_v1()","volatility":"v","input_types":"","returns_set":false,"all_arg_types":null,"default_count":0},{"acl":"{postgres=X/postgres}","oid":"279790","owner":"postgres","config":["search_path=\"\""],"secdef":true,"strict":false,"ddl_md5":"21af9f5aa02865b3ab5894e466e0f657","returns":"jsonb","body_md5":"cbbc333b9f46016de31ca4d804b5cd26","defaults":null,"language":"plpgsql","parallel":"u","arg_modes":null,"arg_names":["p_session"],"signature":"mission_factory_owner.c444_terminal_confirmed_v1(uuid)","volatility":"v","input_types":"2950","returns_set":false,"all_arg_types":null,"default_count":0}]$pins$::jsonb THEN RAISE EXCEPTION 'HUMAN_C463_REVIEWED_PINS_REQUIRED';END IF;
 FOR pin IN SELECT value FROM jsonb_array_elements($pins$[{"acl":"{postgres=X/postgres,service_role=X/postgres}","oid":"31313","owner":"postgres","config":["search_path=\"\""],"secdef":true,"strict":false,"ddl_md5":"b6e04b4d804ca90d1883a105097cfeee","returns":"void","body_md5":"15ffdb5fb1046d4dec87b51fe02a07c9","defaults":null,"language":"plpgsql","parallel":"u","arg_modes":null,"arg_names":["p_session"],"signature":"public.master_v2_lock_scope(uuid)","volatility":"v","input_types":"2950","returns_set":false,"all_arg_types":null,"default_count":0},{"acl":"{postgres=X/postgres}","oid":"43060","owner":"postgres","config":["search_path=\"\""],"secdef":true,"strict":false,"ddl_md5":"255e8d73cdd7c3814132d71f0f45b1b5","returns":"boolean","body_md5":"6c865d07f0cb55b7d1f1a14a3f6e12b6","defaults":"false","language":"sql","parallel":"u","arg_modes":null,"arg_names":["p_location","p_principals","p_provider"],"signature":"combat_consumer_private.staff_test_allowed(uuid,uuid[],boolean)","volatility":"s","input_types":"2950 2951 16","returns_set":false,"all_arg_types":null,"default_count":1},{"acl":"{postgres=X/postgres}","oid":"279627","owner":"postgres","config":["search_path=\"\""],"secdef":true,"strict":false,"ddl_md5":"fd612670979a9f7bbc91ee3bc5367920","returns":"jsonb","body_md5":"56dc0aaf7b5cde324f58947752510d50","defaults":null,"language":"plpgsql","parallel":"u","arg_modes":null,"arg_names":["p_session"],"signature":"mission_factory_owner.c395_source_assert_v1(uuid)","volatility":"v","input_types":"2950","returns_set":false,"all_arg_types":null,"default_count":0},{"acl":"{postgres=X/postgres}","oid":"279634","owner":"postgres","config":["search_path=\"\""],"secdef":true,"strict":false,"ddl_md5":"1e98938354fcb8e27cf826ab90f22770","returns":"void","body_md5":"ef0a29b5053665ad13f2df4fb57cccd3","defaults":null,"language":"plpgsql","parallel":"u","arg_modes":null,"arg_names":["p_session"],"signature":"mission_factory_owner.c407_identity_v1(uuid)","volatility":"s","input_types":"2950","returns_set":false,"all_arg_types":null,"default_count":0},{"acl":"{postgres=X/postgres}","oid":"279635","owner":"postgres","config":["search_path=\"\""],"secdef":true,"strict":false,"ddl_md5":"81648004bde571b78c0161701574b22c","returns":"void","body_md5":"ee1cd8d251f1eebbc056baf69b019239","defaults":null,"language":"plpgsql","parallel":"u","arg_modes":null,"arg_names":["p_session","p_gate"],"signature":"mission_factory_owner.c407_active_v1(uuid,text)","volatility":"v","input_types":"2950 25","returns_set":false,"all_arg_types":null,"default_count":0},{"acl":"{postgres=X/postgres}","oid":"279676","owner":"postgres","config":["search_path=\"\""],"secdef":true,"strict":false,"ddl_md5":"ca836584b84f114ede05277e91610235","returns":"boolean","body_md5":"96766167969aff87b3b11452fd15c598","defaults":null,"language":"sql","parallel":"u","arg_modes":null,"arg_names":null,"signature":"mission_factory_owner.c416_kind_live_v1()","volatility":"s","input_types":"","returns_set":false,"all_arg_types":null,"default_count":0},{"acl":"{postgres=X/postgres}","oid":"279768","owner":"postgres","config":["search_path=\"\""],"secdef":true,"strict":false,"ddl_md5":"2b8d0af96cf3601f48bbfe9f862c9823","returns":"boolean","body_md5":"75fcad93b0da5fee0fc6b7af652a5e85","defaults":null,"language":"sql","parallel":"u","arg_modes":null,"arg_names":null,"signature":"mission_factory_owner.c444_enabled_v1()","volatility":"s","input_types":"","returns_set":false,"all_arg_types":null,"default_count":0},{"acl":"{postgres=X/postgres}","oid":"279866","owner":"postgres","config":["search_path=\"\""],"secdef":true,"strict":false,"ddl_md5":"460a6fef179423578c2782fd8091c2f6","returns":"trigger","body_md5":"4f4fe435034cb4a33f8a58107b1c3c4f","defaults":null,"language":"plpgsql","parallel":"u","arg_modes":null,"arg_names":null,"signature":"mission_factory_owner.c463_optin_journal_guard_v1()","volatility":"v","input_types":"","returns_set":false,"all_arg_types":null,"default_count":0},{"acl":"{postgres=X/postgres}","oid":"279871","owner":"postgres","config":["search_path=\"\""],"secdef":true,"strict":false,"ddl_md5":"60108d2c094296d32c8dcad541d54428","returns":"jsonb","body_md5":"020dee2782683a69b1d1ca9237609db9","defaults":null,"language":"plpgsql","parallel":"u","arg_modes":null,"arg_names":["p_session"],"signature":"mission_factory_owner.c463_optin_identity_v1(uuid)","volatility":"s","input_types":"2950","returns_set":false,"all_arg_types":null,"default_count":0},{"acl":"{postgres=X/postgres,authenticated=X/postgres}","oid":"279873","owner":"postgres","config":["search_path=\"\""],"secdef":true,"strict":false,"ddl_md5":"958a643b431c4a7612b88ac865bf52d8","returns":"jsonb","body_md5":"843f235c8e31de941a2023c0d7a50765","defaults":null,"language":"plpgsql","parallel":"u","arg_modes":null,"arg_names":["p_session","p_request"],"signature":"public.mission_factory_quest_human_regia_optin_receipt_v1(uuid,uuid)","volatility":"s","input_types":"2950 2950","returns_set":false,"all_arg_types":null,"default_count":0},{"acl":"{postgres=X/postgres,authenticated=X/postgres}","oid":"279875","owner":"postgres","config":["search_path=\"\""],"secdef":true,"strict":false,"ddl_md5":"2aa278f951180e9430b9bcee31d0338f","returns":"jsonb","body_md5":"e02138befd9ab9267faaa3582afb1ad1","defaults":null,"language":"plpgsql","parallel":"u","arg_modes":null,"arg_names":["p_session","p_expected_control_version","p_expected_source_sha256","p_request"],"signature":"public.mission_factory_quest_human_regia_optin_v1(uuid,bigint,text,uuid)","volatility":"v","input_types":"2950 20 25 2950","returns_set":false,"all_arg_types":null,"default_count":0},{"acl":"{postgres=X/postgres}","oid":"279880","owner":"postgres","config":["search_path=\"\""],"secdef":true,"strict":false,"ddl_md5":"0715b34161c0e9499fea59b62f8910df","returns":"void","body_md5":"2f767c1ed8560bfd4bf96c8b04681d2a","defaults":null,"language":"plpgsql","parallel":"u","arg_modes":null,"arg_names":null,"signature":"mission_factory_owner.c463_optin_complete_assert_v1()","volatility":"v","input_types":"","returns_set":false,"all_arg_types":null,"default_count":0},{"acl":"{postgres=X/postgres}","oid":"279790","owner":"postgres","config":["search_path=\"\""],"secdef":true,"strict":false,"ddl_md5":"21af9f5aa02865b3ab5894e466e0f657","returns":"jsonb","body_md5":"cbbc333b9f46016de31ca4d804b5cd26","defaults":null,"language":"plpgsql","parallel":"u","arg_modes":null,"arg_names":["p_session"],"signature":"mission_factory_owner.c444_terminal_confirmed_v1(uuid)","volatility":"v","input_types":"2950","returns_set":false,"all_arg_types":null,"default_count":0}]$pins$::jsonb) LOOP
 SELECT jsonb_build_object('signature',p.oid::regprocedure::text,'oid',p.oid::text,'owner',pg_get_userbyid(p.proowner),'acl',p.proacl::text,'config',p.proconfig,'secdef',p.prosecdef,'volatility',p.provolatile,'input_types',p.proargtypes::text,'all_arg_types',p.proallargtypes,'arg_modes',p.proargmodes,'arg_names',p.proargnames,'returns',p.prorettype::regtype::text,'returns_set',p.proretset,'language',l.lanname,'parallel',p.proparallel,'strict',p.proisstrict,'default_count',p.pronargdefaults,'defaults',pg_get_expr(p.proargdefaults,0),'body_md5',md5(p.prosrc),'ddl_md5',md5(pg_get_functiondef(p.oid))) INTO STRICT actual FROM pg_proc p JOIN pg_language l ON l.oid=p.prolang WHERE p.oid=(pin->>'oid')::oid;
 IF actual IS DISTINCT FROM pin THEN RAISE EXCEPTION 'HUMAN_C463_ACTUAL_FUNCTION_DRIFT';END IF;
 END LOOP;
 PERFORM 1 FROM public.locations WHERE id='0b85f354-9cdb-47e1-baf9-3d266bb7e06b'::uuid FOR UPDATE;
 PERFORM public.master_v2_lock_scope(sid);
 SELECT * INTO STRICT master_row FROM public.master_v2_sessions WHERE id=sid FOR UPDATE;
 SELECT * INTO STRICT source_row FROM mission_factory_owner.quest_run_sources WHERE session_id=sid FOR UPDATE;
 SELECT * INTO STRICT binding_row FROM mission_factory_owner.c384_human_bindings WHERE session_id=sid FOR SHARE;
 SELECT * INTO STRICT prepared_row FROM mission_factory_owner.c395_prepared_sources WHERE session_id=sid FOR SHARE;
 SELECT * INTO STRICT runtime_row FROM public.mission_run_state WHERE master_session_id=sid FOR SHARE;
 SELECT array_agg(c.user_id ORDER BY roster.ord) INTO actor_ids
 FROM unnest(source_row.roster_character_ids) WITH ORDINALITY roster(id,ord)
 JOIN public.characters c ON c.id=roster.id;
 IF master_row.master_user IS DISTINCT FROM 'f0856d53-83a6-4de0-bc0c-12c87916e665'::uuid
 OR binding_row.assigned_master IS DISTINCT FROM master_row.master_user
 OR prepared_row.assigned_master IS DISTINCT FROM master_row.master_user
 OR master_row.tipo IS DISTINCT FROM 'quest' OR master_row.owner_kind IS DISTINCT FROM 'human'
 OR master_row.mission_id IS NOT NULL OR master_row.stato IS DISTINCT FROM 'preparazione'
 OR master_row.closed_at IS NOT NULL OR master_row.suspended_at IS NOT NULL
 OR master_row.location_id IS DISTINCT FROM '0b85f354-9cdb-47e1-baf9-3d266bb7e06b'::uuid
 OR master_row.control_version<>1 OR source_row.control_version<>1 OR runtime_row.control_version<>1
 OR source_row.state IS DISTINCT FROM 'prepared' OR source_row.start_request_key IS NOT NULL
 OR source_row.prepare_request_key IS DISTINCT FROM (ev->>'prepare_request_key')::uuid
 OR prepared_row.prepare_request IS DISTINCT FROM source_row.prepare_request_key
 OR source_row.source_sha256 IS DISTINCT FROM (ev->>'expected_source_sha256')
 OR source_row.location_id IS DISTINCT FROM master_row.location_id
 OR source_row.availability_scope IS DISTINCT FROM 'staff' OR source_row.execution_context IS DISTINCT FROM 'staff_simulation'
 OR runtime_row.run_phase IS DISTINCT FROM 'preparazione' OR runtime_row.source_kind IS DISTINCT FROM 'quest'
 OR runtime_row.mission_id IS NOT NULL OR runtime_row.quest_episode_id IS DISTINCT FROM source_row.episode_id
 OR runtime_row.plan_version_id IS DISTINCT FROM source_row.plan_version_id
 OR cardinality(actor_ids) IS DISTINCT FROM cardinality(source_row.roster_character_ids)
 OR cardinality(actor_ids) IS DISTINCT FROM 2
 OR (SELECT count(DISTINCT u) FROM unnest(actor_ids)u)<>2
 OR source_row.staff_release_sha256 IS DISTINCT FROM '37dac90525b249f53fc0404b50adb4ed92df0123649326c99260bf656119d806'
 OR source_row.episode_ordinal IS DISTINCT FROM 2
 OR NOT EXISTS(SELECT 1 FROM mission_factory_owner.quest_episodes e WHERE e.id=source_row.episode_id AND e.arc_id=source_row.arc_id AND e.ordinal=2 AND e.source_sha256=source_row.source_sha256 AND e.source_sha256=mission_factory_owner.sha(e.source_document) AND e.member_character_ids=source_row.roster_character_ids)
 OR source_row.roster_snapshot_sha256 IS DISTINCT FROM mission_factory_owner.sha(to_jsonb(source_row.roster_character_ids))
 OR binding_row.episode_id IS DISTINCT FROM source_row.episode_id OR binding_row.source_sha256 IS DISTINCT FROM source_row.source_sha256
 OR binding_row.binding_sha256 IS DISTINCT FROM mission_factory_owner.sha(binding_row.binding_snapshot)
 OR NOT(actor_ids <@ ARRAY['f0856d53-83a6-4de0-bc0c-12c87916e665','b4952ed5-5ce0-49c0-9f2b-8fd5dcd89b4b']::uuid[])
 OR NOT EXISTS(SELECT 1 FROM public.locations WHERE id=master_row.location_id AND is_active AND is_test)
 OR combat_consumer_private.staff_test_allowed(master_row.location_id,array_append(actor_ids,master_row.master_user),false) IS DISTINCT FROM true
 OR EXISTS(SELECT 1 FROM mission_creation_owner.human_encounters WHERE master_session_id=sid)
 OR EXISTS(SELECT 1 FROM public.combat_v2_sessions WHERE master_session_id=sid AND state NOT IN('chiuso','annullato'))
 OR EXISTS(SELECT 1 FROM mission_generic_owner.regia_human_session_optins_v1 WHERE master_session_id=sid)
 THEN RAISE EXCEPTION 'HUMAN_C463_NOT_EXACT_OWN_PROTECTED_PREPARED_SCOPE';END IF;
 PERFORM public.master_v2_lock_scope((ev->>'previous_session_id')::uuid);
  select * into prev_source from mission_factory_owner.quest_run_sources
    where session_id=(ev->>'previous_session_id')::uuid for share;
  if prev_source.session_id is null or prev_source.state<>'terminal' or prev_source.terminal_receipt_id is null
  then RAISE EXCEPTION 'HUMAN_C463_PREVIOUS_NOT_TERMINAL';end if;
  select * into terminal_row from mission_factory_owner.quest_terminal_receipts
    where id=prev_source.terminal_receipt_id and session_id=(ev->>'previous_session_id')::uuid for share;
  select * into prev_episode from mission_factory_owner.quest_episodes
    where id=prev_source.episode_id for share;
  select * into prev_arc from mission_factory_owner.quest_arcs
    where id=prev_source.arc_id for share;
  select * into prev_master from public.master_v2_sessions
    where id=(ev->>'previous_session_id')::uuid for share;
  select * into prev_runtime from public.mission_run_state
    where master_session_id=(ev->>'previous_session_id')::uuid for share;
  select * into terminal_event from public.mission_run_events
    where id=terminal_row.close_event_id and master_session_id=(ev->>'previous_session_id')::uuid for share;
  select * into terminal_outbox from public.mission_run_outbox
    where event_id=terminal_row.close_event_id and master_session_id=(ev->>'previous_session_id')::uuid for share;
  select exists(select 1 from mission_factory_owner.quest_episodes ne
    where ne.arc_id=prev_source.arc_id and ne.ordinal=prev_episode.ordinal+1) into has_next;
  if terminal_row.id is null or prev_episode.id is null or prev_arc.id is null or prev_master.id is null
     or prev_runtime.master_session_id is null or terminal_event.id is null or terminal_outbox.event_id is null
     or terminal_row.episode_id is distinct from prev_source.episode_id
     or terminal_row.source_sha256 is distinct from prev_source.source_sha256
     or terminal_row.decision_receipt_id::text is distinct from
       terminal_event.result->>'decision_receipt_id'
     or terminal_row.outcome is distinct from terminal_event.result->>'outcome'
     or terminal_row.receipt->>'schema_version' is distinct from 'quest-episode-terminal/1'
     or terminal_row.receipt->>'native_terminal_receipt_id' is distinct from terminal_row.id::text
     or terminal_row.receipt->>'request_key' is distinct from terminal_row.request_key::text
     or terminal_row.receipt->>'outcome' is distinct from terminal_row.outcome
     or terminal_row.continuity_public_sha256 is distinct from
       mission_factory_owner.sha(terminal_row.continuity_public)
     or terminal_row.continuity_private_sha256 is distinct from
       mission_factory_owner.sha(terminal_row.continuity_private)
     or terminal_event.operation_kind<>'close' or terminal_event.status<>'committed'
     or terminal_event.request_key_sha256 is distinct from
       mission_internal.request_key_sha256(terminal_row.request_key)
     or terminal_event.result->>'schema_version' is distinct from 'quest-native-close/1'
     or terminal_event.plan_version_id is distinct from prev_source.plan_version_id
     or terminal_outbox.state<>'published' or terminal_outbox.publication_id is distinct from terminal_row.publication_id
     or not exists(select 1 from public.mission_run_publications p
       where p.id=terminal_row.publication_id and p.event_id=terminal_event.id
         and p.master_session_id=(ev->>'previous_session_id')::uuid and p.status='committed')
     or not exists(select 1 from public.mission_run_messages msg
       where msg.publication_id=terminal_row.publication_id)
     or prev_master.stato<>'chiusa' or prev_master.closed_at is null
     or prev_runtime.source_kind is distinct from 'quest'
     or prev_runtime.quest_episode_id is distinct from prev_source.episode_id
     or prev_runtime.plan_version_id is distinct from prev_source.plan_version_id
     or prev_runtime.last_event_id is distinct from terminal_event.id
     or prev_runtime.control_version is distinct from terminal_event.version_after+1
     or prev_runtime.run_phase is distinct from
       (case when terminal_row.outcome='success' then 'conclusa' else 'fallita' end)
     or prev_episode.arc_id is distinct from prev_source.arc_id
     or prev_episode.source_sha256 is distinct from prev_source.source_sha256
     or prev_episode.terminal_receipt is distinct from terminal_row.receipt
     or prev_episode.state is distinct from
       (case when terminal_row.outcome='success' then 'completed' else 'failed' end)
     or (not has_next and prev_arc.state is distinct from (case when terminal_row.outcome='failure' then 'failed' else 'completed' end))
     or (has_next and prev_arc.state not in('in_progress','completed','failed'))
  then RAISE EXCEPTION 'HUMAN_C463_PREVIOUS_NOT_TERMINAL';end if;
 SELECT * INTO STRICT prev_binding FROM mission_factory_owner.c384_human_bindings WHERE session_id=(ev->>'previous_session_id')::uuid FOR SHARE;
 IF prev_master.master_user IS DISTINCT FROM master_row.master_user OR prev_master.owner_kind IS DISTINCT FROM 'human' OR prev_master.tipo IS DISTINCT FROM 'quest' OR prev_master.location_id IS DISTINCT FROM master_row.location_id OR prev_master.closed_at IS NULL
 OR prev_source.episode_ordinal IS DISTINCT FROM 1 OR prev_source.arc_id IS DISTINCT FROM source_row.arc_id
 OR prev_source.roster_character_ids IS DISTINCT FROM source_row.roster_character_ids
 OR prev_source.availability_scope IS DISTINCT FROM 'staff' OR prev_source.execution_context IS DISTINCT FROM 'staff_simulation'
 OR prev_binding.assigned_master IS DISTINCT FROM master_row.master_user OR prev_binding.lineage_id IS DISTINCT FROM binding_row.lineage_id OR prev_binding.authoring_version IS DISTINCT FROM binding_row.authoring_version
 OR source_row.previous_episode_terminal_receipt_id IS DISTINCT FROM terminal_row.id
 OR source_row.continuity_sha256 IS DISTINCT FROM terminal_row.continuity_private_sha256
 OR terminal_row.continuity_private_sha256 IS DISTINCT FROM mission_factory_owner.sha(terminal_row.continuity_private)
 OR mission_factory_owner.sha(terminal_row.receipt) IS DISTINCT FROM ev->>'previous_terminal_sha256'
 OR EXISTS(SELECT 1 FROM public.combat_v2_sessions c WHERE c.master_session_id=prev_master.id AND c.state NOT IN('chiuso','annullato'))
 THEN RAISE EXCEPTION 'HUMAN_C463_SECOND_CONTINUITY_SCOPE';END IF;
 IF ((WITH targets(label,character_id) AS (VALUES ('pg_tamako','f335b077-34a1-41c3-94aa-58ec674b649b'::uuid),('master_riuji','6bceee99-974f-426b-8d92-38b43b4a4267'::uuid)), resources AS (select t.label,c.rank,c.vita,c.vita_max,c.chakra,c.chakra_max,c.exp,c.xp_lifetime,c.money,c.pool_concesso,c.unspent_points,md5(jsonb_build_array(c.taijutsu,c.ninjutsu,c.genjutsu,c.forza,c.velocita,c.mente,c.resistenza,c.fuuinjutsu,c.kekkei_genkai,c.lealta,c.via,c.fama,c.slot_extra)::text) stats_md5,(select count(*) from public.character_inventory x where x.character_id=c.id) inventory_count,(select md5(coalesce(jsonb_agg(jsonb_build_array(x.id,x.item_id,x.quantity,x.created_at) order by x.id),'[]'::jsonb)::text) from public.character_inventory x where x.character_id=c.id) inventory_md5,(select count(*) from public.lesson_progress x where x.user_id=c.user_id) lesson_count,(select md5(coalesce(jsonb_agg(jsonb_build_array(x.id,x.lesson_id,x.completed_at) order by x.id),'[]'::jsonb)::text) from public.lesson_progress x where x.user_id=c.user_id) lesson_md5,(select count(*) from public.character_jutsu x where x.user_id=c.user_id) jutsu_count,(select md5(coalesce(jsonb_agg(jsonb_build_array(x.id,x.jutsu_id,x.source,x.learned_at) order by x.id),'[]'::jsonb)::text) from public.character_jutsu x where x.user_id=c.user_id) jutsu_md5,(select count(*) from public.character_abilities x where x.character_id=c.id) ability_count,(select md5(coalesce(jsonb_agg(jsonb_build_array(x.id,x.technique_id,x.state,x.sessions_done,x.started_at,x.activated_at) order by x.id),'[]'::jsonb)::text) from public.character_abilities x where x.character_id=c.id) ability_md5,(select count(*) from public.character_perks x where x.character_id=c.id) perk_count,(select md5(coalesce(jsonb_agg(jsonb_build_array(x.id,x.tipo,x.dettaglio,x.costo,x.grado_tecnica,x.created_at) order by x.id),'[]'::jsonb)::text) from public.character_perks x where x.character_id=c.id) perk_md5,(select count(*) from public.esame_prove x where x.candidate_user=c.user_id and x.stato='aperta') legacy_exam_open,(select count(*) from exam_regia_private.bindings x where x.owner_user=c.user_id and x.state<>'closed') legacy_binding_open,md5(jsonb_build_array(c.clan,c.element,c.element2,c.cercoterio,c.sigillo)::text) identity_build_md5 from targets t join public.characters c on c.id=t.character_id order by t.label) select jsonb_build_object('at',clock_timestamp(),'protected_md5',md5(jsonb_agg(to_jsonb(r) order by label)::text),'rows',count(*),'fields_per_pg',(select count(*) from jsonb_object_keys((select to_jsonb(x)-'label' from resources x limit 1)))) from resources r))->>'protected_md5' IS DISTINCT FROM ev->>'expected_protected_md5' THEN RAISE EXCEPTION 'HUMAN_C463_SECOND_PROTECTED_RESOURCES_CHANGED';END IF;
 lease_end:=least(human_ctrl.expires_at,kind_ctrl.expires_at);
 IF ctrl.expires_at>lease_end OR ctrl.expires_at<=statement_timestamp() THEN RAISE EXCEPTION 'HUMAN_C463_SECOND_NO_LEASE_EXTENSION';END IF;
 lease_end:=ctrl.expires_at;
 IF lease_end<=statement_timestamp() THEN RAISE EXCEPTION 'HUMAN_C463_LEASE_EXPIRED';END IF;
 -- Existing CHECK requires exactly 120 minutes. Inherit the Human window, never renew it.
 UPDATE mission_factory_owner.c463_optin_control SET session_ids=array_append(ctrl.session_ids,sid) WHERE singleton;
 GET DIAGNOSTICS changed=ROW_COUNT;IF changed<>1 THEN RAISE EXCEPTION 'HUMAN_C463_UPDATE_COUNT';END IF;
 IF NOT EXISTS(SELECT 1 FROM mission_factory_owner.c463_optin_control c WHERE c.singleton AND c.enabled AND c.master_user_ids=ARRAY[master_row.master_user] AND c.session_ids=array_append(ctrl.session_ids,sid) AND c.bound_at<=statement_timestamp() AND c.expires_at=lease_end AND c.expires_at<=human_ctrl.expires_at AND c.expires_at<=kind_ctrl.expires_at AND c.review_sha256=ctrl.review_sha256 AND c.bound_at=ctrl.bound_at) THEN RAISE EXCEPTION 'HUMAN_C463_POSTIMAGE';END IF;
 IF (SELECT to_jsonb(c)-'session_ids' FROM mission_factory_owner.c463_optin_control c WHERE singleton) IS DISTINCT FROM (to_jsonb(ctrl)-'session_ids') THEN RAISE EXCEPTION 'HUMAN_C463_SECOND_UNRELATED_CONTROL_DRIFT';END IF;
END $human_c463$;
COMMIT;
