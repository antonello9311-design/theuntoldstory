-- H1/H2 R1 forward recovery. Retain new DDL and UI, stop only four tested gates.
BEGIN;
SET LOCAL search_path='';
DO $joint_fix_pre$
DECLARE rr mission_factory_owner.editor_release_readiness%ROWTYPE;p jsonb;f jsonb;
BEGIN
 IF current_user<>'postgres'OR session_user<>'postgres'OR auth.uid()IS NOT NULL THEN RAISE EXCEPTION 'JOINT_FIX_OPERATOR_REQUIRED';END IF;
 IF NOT pg_try_advisory_xact_lock(hashtextextended('C1266:GENERIC-AI:AVAILABILITY',0))THEN RAISE EXCEPTION 'JOINT_FIX_AVAILABILITY_BUSY';END IF;
 p:=nullif(current_setting('app.h1h2_r1_parameters',true),'')::jsonb;
 SELECT * INTO STRICT rr FROM mission_factory_owner.editor_release_readiness WHERE singleton FOR UPDATE NOWAIT;
 LOCK TABLE public.master_v2_sessions,public.combat_v2_sessions,combat_consumer_private.invitations
  IN SHARE MODE NOWAIT;
 IF EXISTS(SELECT 1 FROM combat_consumer_private.invitations
  WHERE state='pending' AND location_id='0b85f354-9cdb-47e1-baf9-3d266bb7e06b'::uuid)
 THEN RAISE EXCEPTION 'H1H2_R1_PENDING_INVITATIONS';END IF;
 IF rr.revision_sha256 IS DISTINCT FROM p#>>'{expected_current,root_sha256}'OR public.combat_v2_sha256(to_jsonb(rr))IS DISTINCT FROM p#>>'{expected_current,root_row_sha256}'THEN RAISE EXCEPTION 'JOINT_FIX_BASELINE_DRIFT';END IF;
 IF EXISTS(SELECT 1 FROM public.combat_v2_sessions WHERE closed_at IS NULL AND state IN('preparazione','in_corso','sospeso'))OR EXISTS(SELECT 1 FROM public.master_v2_sessions WHERE closed_at IS NULL AND stato NOT IN('chiusa','annullata'))THEN RAISE EXCEPTION 'JOINT_FIX_REQUIRES_QUIESCENCE';END IF;
 PERFORM set_config('app.cure_reaction_paralisi_gate_before',(SELECT to_jsonb(g)::text FROM combat_v2_genjutsu_internal.gate g WHERE singleton),true);
 PERFORM set_config('app.cure_reaction_cure_gate_before',(SELECT to_jsonb(g)::text FROM combat_panel_private.cure_gate_v1 g WHERE singleton),true);
 PERFORM set_config('app.joint_fix_native_gates_before',jsonb_build_object('aburame_genin',(SELECT to_jsonb(g)FROM clan_aburame_private.release_gate g WHERE singleton),'nara_genin',(SELECT to_jsonb(g)FROM combat_panel_private.nara_launch_gate_v1 g WHERE singleton),'akimichi_genin',(SELECT to_jsonb(g)FROM clan_akimichi_private.release_gate g WHERE singleton))::text,true);
 IF jsonb_build_object('cure',(SELECT to_jsonb(g)FROM combat_panel_private.cure_gate_v1 g WHERE singleton),'genjutsu',(SELECT to_jsonb(g)FROM combat_v2_genjutsu_internal.gate g WHERE singleton),'NB',(SELECT to_jsonb(g)FROM combat_v2_staff_nb_internal.gate g WHERE singleton),'ABU',(SELECT to_jsonb(g)FROM clan_aburame_private.verme_gate_v1 g WHERE singleton),'AKI',(SELECT to_jsonb(g)FROM clan_akimichi_private.common_gate_v1 g WHERE singleton),'NARA',(SELECT to_jsonb(g)FROM combat_panel_private.nara_adv_gate_v1 g WHERE singleton))IS DISTINCT FROM p->'expected_gates'THEN RAISE EXCEPTION 'JOINT_FIX_BASELINE_GATES_DRIFT';END IF;
 FOR f IN SELECT value FROM jsonb_array_elements($fix_expected$[{"signature":"clan_akimichi_private.common_panel_commit_v1(jsonb)","oid":"685925","source_md5":"91e55c736eefba25100199b9c05e9fc5","ddl_sha256":"9e83117a37bac5a258171e72cb491da4b23ea803d0e4994f07f925394ee1b670","owner":"postgres","acl":"{postgres=X/postgres}","config":["search_path=\"\""],"secdef":true},{"signature":"clan_innata_private.catalogo_eligibility_release_v1()","oid":"684829","source_md5":"25c59286ca2abe9d6c27e15214f8c90c","ddl_sha256":"cffa08771a8a6880e80b78bdec964d227abd373dc7367848810aae8c39fca8cf","owner":"postgres","acl":"{postgres=X/postgres}","config":["search_path=\"\""],"secdef":true}]$fix_expected$::jsonb)LOOP
 IF md5((SELECT prosrc FROM pg_proc WHERE oid=to_regprocedure(f->>'signature')))IS DISTINCT FROM f->>'source_md5'OR encode(extensions.digest(convert_to(pg_get_functiondef(to_regprocedure(f->>'signature')),'UTF8'),'sha256'),'hex')IS DISTINCT FROM f->>'ddl_sha256'
 OR NOT EXISTS(SELECT 1 FROM pg_proc pp WHERE pp.oid=to_regprocedure(f->>'signature')AND pp.oid::text=f->>'oid'AND pg_get_userbyid(pp.proowner)=f->>'owner'AND pp.proacl::text IS NOT DISTINCT FROM f->>'acl'AND coalesce(to_jsonb(pp.proconfig),'null'::jsonb)IS NOT DISTINCT FROM f->'config'AND pp.prosecdef=(f->>'secdef')::boolean)THEN RAISE EXCEPTION 'JOINT_FIX_OWNING_DRIFT:%',f->>'signature';END IF;
 END LOOP;
 IF p->>'mode'IS DISTINCT FROM 'recovery'OR rr.canonical_preimage::jsonb#>>'{db_core,catalogo_families,1}'IS DISTINCT FROM p->>'source_bundle_sha256'THEN RAISE EXCEPTION 'JOINT_FIX_RECOVERY_SCOPE_DRIFT';END IF;IF NOT clan_innata_private.catalogo_eligibility_release_v1() THEN RAISE EXCEPTION 'H1H2_R1_RECOVERY_BASELINE_ELIGIBILITY';END IF;IF EXISTS(SELECT 1 FROM combat_v2_staff_nb_internal.admissions ad JOIN public.combat_v2_sessions ss ON ss.id=ad.encounter_id WHERE ss.closed_at IS NULL OR ss.state NOT IN('chiuso','chiusa','annullato','annullata'))OR EXISTS(SELECT 1 FROM combat_v2_staff_nb_internal.admissions ad JOIN public.combat_v2_rounds rr ON rr.session_id=ad.encounter_id JOIN public.combat_v2_declarations dd ON dd.round_id=rr.id WHERE dd.state NOT IN('risolta','annullata','superflua'))THEN RAISE EXCEPTION 'JOINT_FIX_RECOVERY_NATIVE_NB_CLOSURE_REQUIRED';END IF;
END $joint_fix_pre$;

DO $catalogo_root$
DECLARE
 expected_parameters_sha256 constant text:='__H1H2_R1_PARAMETERS_SHA256__';
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
 params:=nullif(current_setting('app.h1h2_r1_parameters',true),'')::jsonb;old_root_sha:=params#>>'{expected_current,root_sha256}';old_row_sha:=params#>>'{expected_current,root_row_sha256}';
 SELECT * INTO STRICT rr FROM mission_factory_owner.editor_release_readiness WHERE singleton FOR UPDATE NOWAIT;
 IF rr.revision_sha256<>old_root_sha OR rr.observed_revision_sha256 IS DISTINCT FROM old_root_sha
 OR public.combat_v2_sha256(to_jsonb(rr))<>old_row_sha
 OR encode(extensions.digest(convert_to(rr.canonical_preimage,'UTF8'),'sha256'),'hex')<>old_root_sha
 OR octet_length(rr.canonical_preimage)<>(params#>>'{expected_current,root_bytes}')::integer THEN RAISE EXCEPTION 'CATALOGO_ROOT_BASELINE_DRIFT';END IF;
 IF EXISTS(SELECT 1 FROM public.combat_v2_sessions WHERE state='in_corso' AND closed_at IS NULL)
 OR EXISTS(SELECT 1 FROM public.master_v2_sessions WHERE stato NOT IN('chiusa','annullata') AND closed_at IS NULL) THEN
  RAISE EXCEPTION 'CATALOGO_ROOT_REQUIRES_QUIESCENCE';END IF;
 params:=nullif(current_setting('app.h1h2_r1_parameters',true),'')::jsonb;
 IF expected_parameters_sha256 !~ '^[0-9a-f]{64}$' OR params IS NULL
 OR public.combat_v2_sha256(params)<>expected_parameters_sha256
 OR params->>'schema_version' IS DISTINCT FROM 'joint-fix-h1h2-r1-parameters/1' THEN
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
 OR old_combat->'version'IS DISTINCT FROM '46'::jsonb OR old_combat->>'ezbr_sha256'IS DISTINCT FROM '1bdcde5a74ae789c610e7469a7906a419bb363b189b58133939ebb91db6c1775'
 OR public.combat_v2_sha256(root->'ui') IS DISTINCT FROM params#>>'{expected_current,ui_sha256}'
 OR (params->>'mode'='source' AND public.combat_v2_sha256(root->'ui') IS DISTINCT FROM 'f5f2272fa1adbb8fc7aeef852884601e50f155e9ba0920958458c0a3c66ff705')
 OR (params->>'mode'='recovery' AND (root#>>'{ui,files,land.html,sha256}' IS DISTINCT FROM '7d48cd18580ae4fd84d35ae566a8c26fd8b380b0f4b4bb80def3d346f50b7d68'
   OR root#>>'{ui,build}' IS DISTINCT FROM 'staff-ninjabook-preparation-20261120-2')) THEN
  RAISE EXCEPTION 'CATALOGO_ROOT_UNRELATED_SURFACE_DRIFT';END IF;
 db_stored:=root#>>'{db_core,sha256}';db_old_recomputed:=public.combat_v2_sha256((root->'db_core')-'sha256');
 IF db_stored IS DISTINCT FROM params#>>'{expected_current,db_sha256}' OR db_old_recomputed IS DISTINCT FROM db_stored
 OR root#>>'{config,sha256}'<>public.combat_v2_sha256((root->'config')-'sha256') THEN
  RAISE EXCEPTION 'CATALOGO_ROOT_HASH_RECONCILIATION_DRIFT';END IF;

 edge_receipt:=params->'client_receipt';
 IF NOT mission_factory_owner.keys_exact_v2(edge_receipt,ARRAY['published','filename','sha256','bytes','build','git_commit','publication_receipt_sha256','domain_evidence_sha256'])
 OR edge_receipt->'published'IS DISTINCT FROM 'true'::jsonb OR edge_receipt->>'filename'IS DISTINCT FROM 'land.html'
 OR edge_receipt->>'sha256'IS DISTINCT FROM '7d48cd18580ae4fd84d35ae566a8c26fd8b380b0f4b4bb80def3d346f50b7d68'OR edge_receipt->'bytes'IS DISTINCT FROM '2469945'::jsonb
 OR edge_receipt->>'build'IS DISTINCT FROM 'staff-ninjabook-preparation-20261120-2'OR coalesce(edge_receipt->>'git_commit','')!~'^[0-9a-f]{40}$'
 OR coalesce(edge_receipt->>'publication_receipt_sha256','')!~'^[0-9a-f]{64}$'OR coalesce(edge_receipt->>'domain_evidence_sha256','')!~'^[0-9a-f]{64}$'
 THEN RAISE EXCEPTION 'JOINT_FIX_ACTUAL_REVIEWED_CLIENT_RECEIPT_REQUIRED';END IF;
 expected_ui:=before_root->'ui';
 IF expected_ui->>'import_graph_sha256' IS DISTINCT FROM public.combat_v2_sha256(expected_ui->'staff_preparation_fix_graph')
 OR expected_ui->>'import_graph_sha256' IS DISTINCT FROM params#>>'{expected_current,ui_graph_sha256}'
 THEN RAISE EXCEPTION 'H1H2_R1_PARENT_CLIENT_GRAPH_DRIFT';END IF;
 IF params->>'mode'='source'THEN
  descriptor:=jsonb_build_array(1,expected_ui->'import_graph_sha256','7d48cd18580ae4fd84d35ae566a8c26fd8b380b0f4b4bb80def3d346f50b7d68');
  expected_ui:=jsonb_set(expected_ui,'{staff_preparation_fix_graph}',descriptor,true);
  expected_ui:=jsonb_set(expected_ui,'{import_graph_sha256}',to_jsonb(public.combat_v2_sha256(descriptor)),false);
  expected_ui:=jsonb_set(expected_ui,'{files,land.html}',jsonb_build_object('bytes',2469945,'sha256','7d48cd18580ae4fd84d35ae566a8c26fd8b380b0f4b4bb80def3d346f50b7d68'),false);
  expected_ui:=jsonb_set(expected_ui,'{build}',to_jsonb('staff-ninjabook-preparation-20261120-2'::text),false);
  expected_ui:=jsonb_set(expected_ui,'{git_head}',edge_receipt->'git_commit',false);
 ELSE
  IF expected_ui#>>'{files,land.html,sha256}'IS DISTINCT FROM '7d48cd18580ae4fd84d35ae566a8c26fd8b380b0f4b4bb80def3d346f50b7d68'OR expected_ui->>'git_head'IS DISTINCT FROM edge_receipt->>'git_commit'THEN RAISE EXCEPTION 'JOINT_FIX_RECOVERY_CLIENT_DRIFT';END IF;
 END IF;
 IF expected_ui->>'import_graph_sha256' IS DISTINCT FROM params->>'expected_target_graph_sha256'
 OR expected_ui#>>'{files,land.html,sha256}' IS DISTINCT FROM edge_receipt->>'sha256'
 OR (params->>'mode'='recovery' AND expected_ui IS DISTINCT FROM before_root->'ui')
 THEN RAISE EXCEPTION 'H1H2_R1_TARGET_CLIENT_GRAPH_DRIFT';END IF;
 root:=jsonb_set(root,'{ui}',expected_ui,false);

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
 WHERE p.prokind='f'AND p.oid IN('clan_akimichi_private.common_panel_commit_v1(jsonb)'::regprocedure,'clan_innata_private.catalogo_eligibility_release_v1()'::regprocedure);
SELECT jsonb_agg(jsonb_build_object('signature',p.oid::regprocedure::text,'source_md5',md5(p.prosrc),'ddl_md5',md5(pg_get_functiondef(p.oid)),
 'owner',pg_get_userbyid(p.proowner),'secdef',p.prosecdef,'config',p.proconfig,'acl',p.proacl::text,'volatility',p.provolatile::text)ORDER BY p.oid::regprocedure::text)
  INTO relation_manifest FROM pg_proc p WHERE p.oid IN('clan_innata_private.eligibility_release_assert()'::regprocedure,'clan_innata_private.catalogo_eligibility_release_v1()'::regprocedure);
  shared_sha:=public.combat_v2_sha256(shared_manifest);private_sha:=public.combat_v2_sha256(private_manifest);
 IF jsonb_array_length(shared_manifest) IS DISTINCT FROM 34
 OR jsonb_array_length(private_manifest) IS DISTINCT FROM 66
 OR jsonb_array_length(native_manifest) IS DISTINCT FROM 3
 OR shared_sha IS DISTINCT FROM '3702b953c74cf10baa983027cfc04d38013b9384cc01a516cf89deed84f671f9'
 OR private_sha IS DISTINCT FROM '1812035a87056dbc458dc86e4c725d15f28194d33fc2ca10db6e129ebb3d9305'
 OR public.combat_v2_sha256(native_manifest) IS DISTINCT FROM '2d903f7977adb0086633ebe09f6e8b9994bdf2b17218a14ae3a2eac837b6581f'
 THEN RAISE EXCEPTION 'cure_reaction_post_manifest_drift';END IF;
 IF jsonb_array_length(trigger_manifest) IS DISTINCT FROM 6
 OR public.combat_v2_sha256(trigger_manifest) IS DISTINCT FROM '826157d1b279d1e1e220e12ecf84e8e9c10a3541fb8dde5c80e6f8afe38d61c2'
 THEN RAISE EXCEPTION 'palmo_completion_peer6_drift';END IF;
 -- Update every existing touched-OID alias; ABI remains byte-exact.
 IF jsonb_array_length(changed_headers) IS DISTINCT FROM 2
 OR public.combat_v2_sha256(changed_headers) IS DISTINCT FROM '17e2aed405016f642cb14d9862b72ef78d1c5bb18e2e9915785ee5375d69a6d2'
 THEN RAISE EXCEPTION 'H1H2_R2_OWNING_HEADERS_DRIFT';END IF;
 IF jsonb_array_length(relation_manifest) IS DISTINCT FROM 2 OR public.combat_v2_sha256(relation_manifest) IS DISTINCT FROM '8032a0d0e92efe05a7cbffe20aef977fe8cab7003333c095b18f15afb34bfc96'
 THEN RAISE EXCEPTION 'H1H2_R1_COMPAT_DESCRIPTOR_DRIFT';END IF;
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
 IF aliases<>0 THEN RAISE EXCEPTION 'staff_entry_repairs_alias_count';END IF;
 binding:=$joint_fix_amendment${"state":"active_amendment","review":{"P0":0,"P1":0,"P2":0,"ref":"JOINT_FIX_REVIEW.json","sha256":"fc6517f7270f78daa2463aef84d00c64b0b11a2f325dac9a537b8bddc4308900"},"parent_root":"4987b6ec7f9de174a3e9e785e15cba1cf7d1238b9814ce2db2b38aea6634768a","availability":{"cure_staff_enabled":true,"cure_public_enabled":false,"paralisi_staff_enabled":true,"paralisi_public_enabled":false},"schema_version":"cure-command-amendment/1","commit_source_md5":"61532836e90ed32ae807b92ee6632b71","helper_source_md5":"25c59286ca2abe9d6c27e15214f8c90c","active_repair_kind":"paralisi-label-dispatch/1","neutral_source_md5":"dd236ae4c47770d25fd79cb2e9707d1f","source_bundle_sha256":"e7673ed8199195e312e936ff79b68542bfb720bd189436cd63404cf59bee5a34","shared_manifest_sha256":"3702b953c74cf10baa983027cfc04d38013b9384cc01a516cf89deed84f671f9","functions_manifest_sha256":"826157d1b279d1e1e220e12ecf84e8e9c10a3541fb8dde5c80e6f8afe38d61c2","normalized_source_identity":{"qa_state":"H1_H2_R1_NOT_RUN","staff_pass":false,"parent_root":"4987b6ec7f9de174a3e9e785e15cba1cf7d1238b9814ce2db2b38aea6634768a","public_enabled":false,"schema_version":"catalogo-joint-family/1","publisher_source_md5":"c5b951689347cfd4f36ac097a601994a","shared_manifest_sha256":"3702b953c74cf10baa983027cfc04d38013b9384cc01a516cf89deed84f671f9","paralisi_label_source_sha256":"0705927fad1de34d8422b68fb4eda5c96fc7b000a77367a3a8ec0e9d15cfa02f","previous_source_bundle_sha256":"e7673ed8199195e312e936ff79b68542bfb720bd189436cd63404cf59bee5a34","native_functions_manifest_sha256":"2d903f7977adb0086633ebe09f6e8b9994bdf2b17218a14ae3a2eac837b6581f","private_functions_manifest_sha256":"1812035a87056dbc458dc86e4c725d15f28194d33fc2ca10db6e129ebb3d9305","previous_amendment_identity_sha256":"ae65c725b5c70c1f5468f6b61a68c46dc431a8ce22dcd5b17c6d6b7e4219a607","akimichi_common_commit_source_md5":"91e55c736eefba25100199b9c05e9fc5"},"base_compat_source_bundle_sha256":"654f8fff2f42019ffc4b3ccc6c467fff443ba81f00c7aa020fbd6d7950e2445e","native_functions_manifest_sha256":"2d903f7977adb0086633ebe09f6e8b9994bdf2b17218a14ae3a2eac837b6581f","normalized_source_identity_sha256":"e15919762cc27a609fa6938653354e0e1e328c0cabfa4914378fb03d908c7338","private_functions_manifest_sha256":"1812035a87056dbc458dc86e4c725d15f28194d33fc2ca10db6e129ebb3d9305","base_catalogo_source_bundle_sha256":"825a1c14a59281fb3168430a993e9f2dbbbc41042f5169638d2e9c1e8e9868a5","base_private_functions_manifest_sha256":"3eb9bba89fc99206710cd079207631f4949dec9893a38d97d7d46e07386b5cc0","previous_cure_command_source_bundle_sha256":"e7673ed8199195e312e936ff79b68542bfb720bd189436cd63404cf59bee5a34"}$joint_fix_amendment$::jsonb;
 binding:=binding||jsonb_build_object('state','active_amendment','source_bundle_sha256',params->'source_bundle_sha256','review',review,
   'availability',(SELECT jsonb_build_object('cure_staff_enabled',c.staff_enabled,'cure_public_enabled',c.public_enabled,
    'paralisi_staff_enabled',g.staff_enabled,'paralisi_public_enabled',g.public_enabled)
    FROM combat_panel_private.cure_gate_v1 c CROSS JOIN combat_v2_genjutsu_internal.gate g WHERE c.singleton AND g.singleton));
 root:=jsonb_set(root,'{db_core,cure_command_amendment}',binding,false);root:=jsonb_set(root,'{config,cure_command_amendment}',binding,false);
 cfg:=root#>'{db_core,catalogo_eligibility_compat}';
 cfg:=cfg||jsonb_build_object('shared_manifest_sha256',shared_sha,'private_functions_manifest_sha256',private_sha,'helper_source_md5','25c59286ca2abe9d6c27e15214f8c90c','guard_source_md5','78dd10959830241cf446b1cd738dbd2d',
  'active_amendment_source_bundle_sha256',binding->'source_bundle_sha256','functions',relation_manifest,'functions_manifest_sha256',public.combat_v2_sha256(relation_manifest));
 root:=jsonb_set(root,'{db_core,catalogo_eligibility_compat}',cfg,false);root:=jsonb_set(root,'{config,catalogo_eligibility_compat}',cfg,false);
 descriptor:=jsonb_build_object('schema_version','paralisi-label/1','leaf_sha256','0705927fad1de34d8422b68fb4eda5c96fc7b000a77367a3a8ec0e9d15cfa02f',
  'source_bundle_sha256',params->'source_bundle_sha256','state','active','review',review);
 root:=jsonb_set(root,'{db_core,paralisi_label}',descriptor,true);
 root:=jsonb_set(root,'{config,paralisi_label}',descriptor,true);
 descriptor:=jsonb_build_array(1,params->'source_bundle_sha256',(SELECT jsonb_build_array(public.combat_v2_sha256((SELECT coalesce(jsonb_agg(jsonb_build_object('signature',n.nspname||'.'||p.proname||'('||oidvectortypes(p.proargtypes)||')','source_md5',md5(p.prosrc),'ddl_md5',md5(pg_get_functiondef(p.oid)),'owner',pg_get_userbyid(p.proowner),'acl',p.proacl::text,'config',p.proconfig,'secdef',p.prosecdef,'strict',p.proisstrict,'parallel',p.proparallel::text,'volatility',p.provolatile::text,'returns',pg_get_function_result(p.oid),'language',l.lanname)ORDER BY n.nspname,p.proname,oidvectortypes(p.proargtypes)),'[]'::jsonb)FROM pg_proc p JOIN pg_namespace n ON n.oid=p.pronamespace JOIN pg_language l ON l.oid=p.prolang WHERE p.oid IN(to_regprocedure('combat_v2_staff_nb_internal.origin_guard()'),to_regprocedure('combat_v2_staff_nb_internal.preparation_allowed(uuid)'),to_regprocedure('combat_v2_staff_nb_internal.choice(uuid)'),to_regprocedure('combat_v2_staff_nb_internal.roster_offers(uuid,bigint,uuid)'),to_regprocedure('combat_v2_staff_nb_internal.native_construct(uuid,uuid[],jsonb,jsonb,uuid,uuid)'),to_regprocedure('combat_v2_staff_nb_internal.mechanics_ready(uuid)'),to_regprocedure('combat_v2_staff_nb_internal.setup_protected(uuid,uuid)'),to_regprocedure('combat_v2_staff_nb_internal.commit_roster(jsonb)'),to_regprocedure('combat_v2_staff_nb_internal.roster_receipt(uuid)'),to_regprocedure('combat_v2_staff_nb_internal.pg_scope(uuid)'),to_regprocedure('combat_v2_staff_nb_internal.kai_frozen_authority(uuid)'),to_regprocedure('combat_v2_staff_nb_internal.kai_authority(uuid)'),to_regprocedure('combat_v2_staff_nb_internal.kai_contact(uuid,uuid)'),to_regprocedure('clan_aburame_private.verme_manifest_v1()'),to_regprocedure('clan_aburame_private.verme_release_v1()'),to_regprocedure('clan_aburame_private.verme_staff_scope_v1(uuid)'),to_regprocedure('clan_aburame_private.verme_scope_v1(uuid)'),to_regprocedure('clan_aburame_private.verme_event_v1(text,uuid,uuid,uuid,uuid,uuid,text,jsonb)'),to_regprocedure('clan_aburame_private.verme_staff_prepare_v1(uuid,uuid)'),to_regprocedure('clan_aburame_private.verme_meta_v1(uuid,boolean)'),to_regprocedure('clan_aburame_private.verme_bind_v1(uuid)'),to_regprocedure('clan_aburame_private.verme_frozen_v1(uuid)'),to_regprocedure('clan_aburame_private.verme_finish_v1(uuid,uuid,boolean,integer)'),to_regprocedure('clan_aburame_private.verme_tick_v1(uuid,uuid,uuid,text)'),to_regprocedure('clan_aburame_private.verme_end_context_v1()'),to_regprocedure('clan_aburame_private.verme_report_v1(uuid,uuid)'),to_regprocedure('clan_aburame_private.verme_reserve_round_v1(uuid)'),to_regprocedure('clan_aburame_private.verme_settle_round_v1(uuid)'),to_regprocedure('clan_aburame_private.verme_narrative_v1(uuid,uuid)'),to_regprocedure('clan_akimichi_private.common_staff_scope_v1(uuid)'),to_regprocedure('clan_akimichi_private.common_scope_v1(uuid,uuid)'),to_regprocedure('clan_akimichi_private.common_prepare_staff_v1(uuid,uuid,uuid)'),to_regprocedure('clan_akimichi_private.common_modifiers_v1(text,integer,integer,integer)'),to_regprocedure('clan_akimichi_private.common_set_form_v1(uuid,uuid,text)'),to_regprocedure('clan_akimichi_private.common_defer_upkeep_v1(uuid,uuid)'),to_regprocedure('clan_akimichi_private.common_flush_upkeep_v1(uuid)'),to_regprocedure('clan_akimichi_private.cellular_meta_v1(uuid)'),to_regprocedure('clan_akimichi_private.cellular_attack_eligible_v1(uuid,uuid)'),to_regprocedure('clan_akimichi_private.cellular_bind_v1(uuid)'),to_regprocedure('clan_akimichi_private.cellular_source_valid_v1(uuid)'),to_regprocedure('clan_akimichi_private.cellular_pay_v1(uuid)'),to_regprocedure('clan_akimichi_private.cellular_snapshot_v1(uuid,jsonb)'),to_regprocedure('clan_akimichi_private.cellular_mark_v1(uuid,jsonb)'),to_regprocedure('clan_akimichi_private.cellular_calculate_v1(uuid,jsonb,integer,integer)'),to_regprocedure('clan_akimichi_private.common_calorie_balance_v1(uuid,uuid,uuid,uuid)'),to_regprocedure('clan_akimichi_private.common_admit_calories_v1(uuid)'),to_regprocedure('clan_akimichi_private.common_preflight_calories_v1(uuid)'),to_regprocedure('clan_akimichi_private.super_direct_visible_v1(uuid,uuid)'),to_regprocedure('clan_akimichi_private.common_attack_power_freeze_v1(uuid)'),to_regprocedure('clan_akimichi_private.common_panel_offers_v1(uuid,bigint,jsonb)'),to_regprocedure('clan_akimichi_private.common_panel_commit_v1(jsonb)'),to_regprocedure('clan_akimichi_private.common_result_label_v1(jsonb)'),to_regprocedure('clan_akimichi_private.common_source_root_v1()'),to_regprocedure('clan_sabaku_private.armor_absorb_packet_v1(uuid,uuid,uuid,uuid,integer)'),to_regprocedure('combat_panel_private.nara_adv_pool_v1(uuid)'),to_regprocedure('combat_panel_private.nara_adv_protected_v1(uuid)'),to_regprocedure('combat_panel_private.nara_adv_scope_v1(uuid)'),to_regprocedure('combat_panel_private.nara_adv_prepare_v1(uuid,uuid)'),to_regprocedure('combat_panel_private.nara_strangle_meta_v1(uuid)'),to_regprocedure('combat_panel_private.nara_strangle_action_meta_v1(uuid,uuid,jsonb)'),to_regprocedure('combat_panel_private.nara_strangle_bind_v1(uuid)'),to_regprocedure('combat_panel_private.nara_strangle_parent_valid_v1(uuid)'),to_regprocedure('combat_panel_private.nara_strangle_lifecycle_v1(uuid)'),to_regprocedure('combat_panel_private.nara_strangle_packet_v1(uuid,uuid,uuid,text)'),to_regprocedure('combat_panel_private.nara_strangle_resolve_v1(uuid)'),to_regprocedure('combat_panel_private.nara_strangle_turn_v1(uuid,uuid,uuid,text)'),to_regprocedure('combat_panel_private.nara_strangle_facts_revision_v1(jsonb)'),to_regprocedure('combat_panel_private.nara_strangle_facts_v1(uuid,uuid)'),to_regprocedure('combat_panel_private.nara_adv_history_guard_v1()'),to_regprocedure('combat_panel_private.nara_strangle_end_event_v1()'),to_regprocedure('combat_panel_private.nara_strangle_terminal_report_v1(uuid)'),to_regprocedure('combat_panel_private.nara_strangle_lifecycle_context_v1(uuid)'),to_regprocedure('combat_panel_private.nara_adv_offers_v1(uuid,bigint,jsonb)'),to_regprocedure('combat_panel_private.nara_adv_commit_v1(jsonb)'),to_regprocedure('combat_panel_private.nara_strangle_lifecycle_trigger_v1()')))),public.combat_v2_sha256((SELECT coalesce(jsonb_agg(jsonb_build_object('signature',n.nspname||'.'||p.proname||'('||oidvectortypes(p.proargtypes)||')','source_md5',md5(p.prosrc),'ddl_md5',md5(pg_get_functiondef(p.oid)),'owner',pg_get_userbyid(p.proowner),'acl',p.proacl::text,'config',p.proconfig,'secdef',p.prosecdef,'strict',p.proisstrict,'parallel',p.proparallel::text,'volatility',p.provolatile::text,'returns',pg_get_function_result(p.oid),'language',l.lanname)ORDER BY n.nspname,p.proname,oidvectortypes(p.proargtypes)),'[]'::jsonb)FROM pg_proc p JOIN pg_namespace n ON n.oid=p.pronamespace JOIN pg_language l ON l.oid=p.prolang WHERE p.oid IN(to_regprocedure('clan_aburame_private.actor_ability(uuid,text,uuid,boolean,jsonb)'),to_regprocedure('clan_aburame_private.attack_power_source(uuid,uuid)'),to_regprocedure('clan_aburame_private.commit_control(jsonb,jsonb,combat_consumer_private.activities,combat_consumer_private.offers,uuid)'),to_regprocedure('clan_aburame_private.commit_master_stop(jsonb)'),to_regprocedure('clan_aburame_private.consumer_options(jsonb)'),to_regprocedure('clan_aburame_private.master_offers(uuid,bigint,jsonb)'),to_regprocedure('clan_akimichi_private.apply_calorie_event(uuid,uuid,boolean,uuid,text,integer,integer,uuid,timestamp with time zone)'),to_regprocedure('clan_akimichi_private.begin_personal_turn(uuid,uuid)'),to_regprocedure('clan_akimichi_private.bind_partial(uuid)'),to_regprocedure('clan_akimichi_private.end_form(uuid,uuid,text)'),to_regprocedure('clan_akimichi_private.form_change_offer(uuid)'),to_regprocedure('clan_akimichi_private.form_impact(uuid,uuid,uuid,text,text,text,jsonb)'),to_regprocedure('clan_akimichi_private.movement_maximum(uuid,numeric)'),to_regprocedure('clan_akimichi_private.partial_meta(uuid,jsonb)'),to_regprocedure('clan_akimichi_private.set_form(uuid,uuid,boolean)'),to_regprocedure('clan_sabaku_private.armor_absorb(uuid,integer)'),to_regprocedure('clan_sabaku_private.armor_narrative_round(uuid)'),to_regprocedure('clan_sabaku_private.armor_round_facts(uuid)'),to_regprocedure('combat_consumer_private.after_publish(uuid,uuid)'),to_regprocedure('combat_consumer_private.commit_exchange(jsonb,jsonb)'),to_regprocedure('combat_consumer_private.narrative_context(uuid)'),to_regprocedure('combat_consumer_private.narrative_declaration_supported(uuid)'),to_regprocedure('combat_consumer_private.validate_narrative_result(jsonb)'),to_regprocedure('combat_effects_private.lifecycle_actor_end(uuid)'),to_regprocedure('combat_effects_private.lifecycle_open(uuid,uuid)'),to_regprocedure('combat_effects_private.lifecycle_session_end(uuid)'),to_regprocedure('combat_effects_private.personal_turn_end(uuid,uuid,uuid,text)'),to_regprocedure('combat_panel_private.catalog_result_label_v1(jsonb)'),to_regprocedure('combat_panel_private.consumer_commit_authoritative(jsonb)'),to_regprocedure('combat_panel_private.master_admin_offers(uuid,bigint,jsonb)'),to_regprocedure('combat_panel_private.master_options(uuid,uuid,bigint)'),to_regprocedure('combat_panel_private.nara_shadow_level_v1(uuid)'),to_regprocedure('combat_panel_private.narrative_declaration_facts(uuid)'),to_regprocedure('combat_panel_private.narrative_ordinary_context(uuid)'),to_regprocedure('combat_panel_private.ordinary_options(uuid,uuid,bigint)'),to_regprocedure('combat_spatial.movement_commit(uuid,uuid,uuid)'),to_regprocedure('combat_v2_genjutsu_internal.ally_contact(uuid,uuid)'),to_regprocedure('combat_v2_genjutsu_internal.master_options(uuid,bigint)'),to_regprocedure('combat_v2_genjutsu_internal.release_intents(uuid)'),to_regprocedure('combat_v2_genjutsu_internal.release_meta(uuid,uuid,uuid,jsonb)'),to_regprocedure('combat_v2_genjutsu_internal.resolve_release(uuid)'),to_regprocedure('combat_v2_genjutsu_internal.scope(uuid)'),to_regprocedure('combat_v2_multitarget_internal.resolve_parent(uuid,uuid,uuid,boolean)'),to_regprocedure('mission_factory_owner.quest_combat_offer_source_guard_v1()'),to_regprocedure('public._combat_calcola(text,jsonb,jsonb,text,text,integer,text,integer,integer,integer,integer,boolean)'),to_regprocedure('public.combat_consumer_narrative_claim_v1(uuid,text,uuid)'),to_regprocedure('public.combat_consumer_narrative_complete_v1(uuid,jsonb,uuid)'),to_regprocedure('public.combat_panel_commit_v1(jsonb)'),to_regprocedure('public.combat_v2_action_declare(uuid,uuid,jsonb,text,uuid)'),to_regprocedure('public.combat_v2_actor_ability(uuid,text,uuid,boolean)'),to_regprocedure('public.combat_v2_defense_declare(uuid,uuid,uuid,jsonb,text,uuid)'),to_regprocedure('public.combat_v2_round_resolve(uuid,uuid)'),to_regprocedure('public.master_v2_encounter_open_ninja_book_v1_human_ai_core(uuid,uuid[],jsonb,jsonb,uuid)'),to_regprocedure('combat_panel_private.publish_master_declaration(uuid,text)'),to_regprocedure('clan_innata_private.eligibility_release_assert()'),to_regprocedure('combat_panel_private.cure_neutral_preset_v1(uuid,uuid,uuid,jsonb)'),to_regprocedure('combat_panel_private.master_actor_offers(uuid,bigint,jsonb,jsonb)')))),public.combat_v2_sha256((SELECT jsonb_build_object('tables',(SELECT jsonb_agg(jsonb_build_object('schema',n.nspname,'name',c.relname,'owner',pg_get_userbyid(c.relowner),'acl',c.relacl::text,'rls',c.relrowsecurity,'force_rls',c.relforcerowsecurity,'columns',(SELECT jsonb_agg(jsonb_build_object('name',a.attname,'type',format_type(a.atttypid,a.atttypmod),'notnull',a.attnotnull,'default',pg_get_expr(d.adbin,d.adrelid),'identity',a.attidentity,'generated',a.attgenerated)ORDER BY a.attnum)FROM pg_attribute a LEFT JOIN pg_attrdef d ON d.adrelid=a.attrelid AND d.adnum=a.attnum WHERE a.attrelid=c.oid AND a.attnum>0 AND NOT a.attisdropped),'constraints',(SELECT coalesce(jsonb_agg(jsonb_build_object('name',q.conname,'definition',pg_get_constraintdef(q.oid),'validated',q.convalidated,'deferrable',q.condeferrable,'deferred',q.condeferred)ORDER BY q.conname),'[]'::jsonb)FROM pg_constraint q WHERE q.conrelid=c.oid),'indexes',(SELECT coalesce(jsonb_agg(jsonb_build_object('name',ci.relname,'definition',pg_get_indexdef(i.indexrelid),'valid',i.indisvalid,'ready',i.indisready,'live',i.indislive)ORDER BY ci.relname),'[]'::jsonb)FROM pg_index i JOIN pg_class ci ON ci.oid=i.indexrelid WHERE i.indrelid=c.oid),'triggers',(SELECT coalesce(jsonb_agg(pg_get_triggerdef(t.oid)ORDER BY t.tgname),'[]'::jsonb)FROM pg_trigger t WHERE t.tgrelid=c.oid AND NOT t.tgisinternal),'policies',(SELECT coalesce(jsonb_agg(jsonb_build_object('name',p.polname,'cmd',p.polcmd,'roles',p.polroles,'using',pg_get_expr(p.polqual,p.polrelid),'check',pg_get_expr(p.polwithcheck,p.polrelid))ORDER BY p.polname),'[]'::jsonb)FROM pg_policy p WHERE p.polrelid=c.oid))ORDER BY n.nspname,c.relname)FROM pg_class c JOIN pg_namespace n ON n.oid=c.relnamespace WHERE c.oid IN(to_regclass('combat_v2_staff_nb_internal.gate'),to_regclass('combat_v2_staff_nb_internal.roster_sources'),to_regclass('combat_v2_staff_nb_internal.admissions'),to_regclass('clan_aburame_private.verme_gate_v1'),to_regclass('clan_aburame_private.verme_staff_profiles_v1'),to_regclass('clan_aburame_private.verme_sources_v1'),to_regclass('clan_aburame_private.verme_poison_v1'),to_regclass('clan_aburame_private.verme_events_v1'),to_regclass('clan_akimichi_private.common_gate_v1'),to_regclass('clan_akimichi_private.common_staff_profiles_v1'),to_regclass('clan_akimichi_private.common_form_commands_v1'),to_regclass('clan_akimichi_private.common_attack_powers_v1'),to_regclass('clan_akimichi_private.common_pending_upkeep_v1'),to_regclass('clan_akimichi_private.cellular_sources_v1'),to_regclass('combat_panel_private.nara_adv_gate_v1'),to_regclass('combat_panel_private.nara_adv_staff_v1'),to_regclass('combat_panel_private.nara_strangle_sources_v1'),to_regclass('combat_panel_private.nara_strangle_events_v1'),to_regclass('public.master_v2_nb_actor_offers_v1'),to_regclass('clan_akimichi_private.forms'))),'catalog',(SELECT jsonb_agg(jsonb_build_object('id',t.id,'sha256',public.combat_v2_sha256(to_jsonb(t)))ORDER BY t.id)FROM public.clan_techniques t WHERE id IN('0a15282f-d6b5-4ee3-ad52-7fac2525444d','f5f26cb5-9b6f-44b3-94bc-c329a0a88b93','687b058a-807d-4cf7-8bcf-21147931b0f6')),'NBtuples',(SELECT jsonb_build_object('mechanical',(SELECT jsonb_agg(jsonb_build_object('id',v.id,'template_id',v.template_id,'content_sha256',v.content_sha256)ORDER BY v.id)FROM public.nb_mechanical_versions v WHERE v.id IN('31da0000-0000-4000-8000-000000000111','31da0000-0000-4000-8000-000000000112')),'narrative',(SELECT jsonb_agg(jsonb_build_object('id',v.id,'template_id',v.template_id,'content_sha256',v.content_sha256)ORDER BY v.id)FROM public.nb_template_versions v WHERE v.id IN('31da0000-0000-4000-8000-000000000211','31da0000-0000-4000-8000-000000000212')))),'new_triggers',(SELECT jsonb_agg(jsonb_build_object('table',e->>'table','name',t.tgname,'function',t.tgfoid::regprocedure::text,'enabled',t.tgenabled::text,'type',t.tgtype,'definition',pg_get_triggerdef(t.oid),'args_sha256',encode(extensions.digest(t.tgargs,'sha256'),'hex'))ORDER BY e->>'table',e->>'name')FROM jsonb_array_elements($joint_triggers$[{"table":"combat_v2_staff_nb_internal.roster_sources","name":"staff_nb_origin_immutable"},{"table":"public.combat_v2_sessions","name":"aburame_verme_end_session_v1"},{"table":"public.combat_v2_actors","name":"aburame_verme_end_actor_v1"},{"table":"combat_panel_private.nara_strangle_sources_v1","name":"nara_strangle_snapshot_guard_v1"},{"table":"combat_panel_private.nara_strangle_events_v1","name":"nara_strangle_events_guard_v1"},{"table":"combat_panel_private.nara_adv_staff_v1","name":"nara_strangle_staff_guard_v1"},{"table":"combat_panel_private.nara_strangle_sources_v1","name":"nara_strangle_ended_event_v1"},{"table":"combat_panel_private.immobilizations","name":"nara_strangle_parent_end_v1"},{"table":"combat_spatial.actor_states","name":"nara_strangle_geometry_end_v1"}]$joint_triggers$::jsonb)e JOIN pg_trigger t ON t.tgrelid=to_regclass(e->>'table')AND t.tgname=e->>'name'AND NOT t.tgisinternal),'NBnamespace',(SELECT jsonb_build_object('owner',pg_get_userbyid(nspowner),'acl',nspacl::text)FROM pg_namespace WHERE nspname='combat_v2_staff_nb_internal')))))),'7c261e6fee5b1f608bb8bf4caccbf28e7f409eadd9e866165bbf65f27b9d411a',CASE WHEN params->>'mode'='source'THEN '[1,1,1,1]'::jsonb ELSE '[0,0,0,0]'::jsonb END);
 IF descriptor->2 IS DISTINCT FROM $fix_expected_metadata$["41ce2e8ba9af1ec7a274dabb00e05b6941e793a1e228d3fea7f0387bbc7c3f3a","2a71b84a4b3ff95700cf8db71b14ede7297cacf0adb16104ee3bf380c1860580","2b38e6014a0723bb02cfcb37ba6b14fcbc609e5a5a428d8dd63e240e18926fc9"]$fix_expected_metadata$::jsonb THEN RAISE EXCEPTION 'JOINT_FIX_AFTER_METADATA_DRIFT';END IF;
 root:=jsonb_set(root,'{db_core,catalogo_families}',descriptor,true);
 root:=jsonb_set(root,'{config,catalogo_families}',to_jsonb(public.combat_v2_sha256(descriptor)),true);
 core:=root->'db_core';db_sha:=public.combat_v2_sha256(core-'sha256');core:=jsonb_set(core,'{sha256}',to_jsonb(db_sha),false);root:=jsonb_set(root,'{db_core}',core,false);
 cfg:=root->'config';config_sha:=public.combat_v2_sha256(cfg-'sha256');cfg:=jsonb_set(cfg,'{sha256}',to_jsonb(config_sha),false);root:=jsonb_set(root,'{config}',cfg,false);
 identity:=jsonb_build_object('schema_version','joint-fix-code-identity/1','parent_root',old_root_sha,'parent_code_identity',before_root#>'{contract,code_identity_sha256}',
  'normalized_amendment_identity_sha256',binding->'normalized_source_identity_sha256','active_shared_manifest_sha256',shared_sha,
  'active_private_functions_manifest_sha256',private_sha,'native_functions_manifest_sha256',binding->'native_functions_manifest_sha256',
  'source_bundle_sha256',params->'source_bundle_sha256','db_sha256',db_sha,'client_sha256',public.combat_v2_sha256(root->'ui'),'ui_graph_sha256',root#>>'{ui,import_graph_sha256}','amendment_state',binding->'state');
 identity_sha:=public.combat_v2_sha256(identity);root:=jsonb_set(root,'{contract,code_identity_sha256}',to_jsonb(identity_sha),false);
 root:=jsonb_set(root,'{recovery,semantic_identity_sha256}',to_jsonb(identity_sha),false);
 root:=jsonb_set(root,'{recovery,cure_command_amendment}',jsonb_build_object('parent_root',old_root_sha,'state',binding->'state',
  'previous_semantic_identity',before_root#>'{recovery,semantic_identity_sha256}','policy','forward_fix_gates_off_keep_code_client_history'),false);
 IF root->'ui'IS DISTINCT FROM expected_ui OR root->'edge_bundles'IS DISTINCT FROM before_root->'edge_bundles'
 OR(root->'config')-ARRAY['sha256','cure_command_amendment','catalogo_eligibility_compat','paralisi_label','catalogo_families']IS DISTINCT FROM(before_root->'config')-ARRAY['sha256','cure_command_amendment','catalogo_eligibility_compat','paralisi_label','catalogo_families']
 OR (root->'db_core')-ARRAY['sha256','cure_command_amendment','catalogo_eligibility_compat','paralisi_label','catalogo_families']
  IS DISTINCT FROM (before_root->'db_core')-ARRAY['sha256','cure_command_amendment','catalogo_eligibility_compat','paralisi_label','catalogo_families']
 OR (root->'contract')-'code_identity_sha256' IS DISTINCT FROM (before_root->'contract')-'code_identity_sha256'
 OR (root->'recovery')-ARRAY['semantic_identity_sha256','cure_command_amendment']
  IS DISTINCT FROM (before_root->'recovery')-ARRAY['semantic_identity_sha256','cure_command_amendment']
 THEN RAISE EXCEPTION 'H1H2_R1_UNRELATED_ROOT_CHANGED';END IF;
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
 IF public.combat_v2_sha256(mission_public_owner.engine_qualification_v1(old_root_sha,true))
    IS DISTINCT FROM params->>'expected_mission_qualification_sha256'
 THEN RAISE EXCEPTION 'H1H2_R1_MISSION_QUALIFICATION_DRIFT';END IF;
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
 OR public.combat_v2_sha256(qualification->'capabilities') IS DISTINCT FROM params->>'expected_mission_capabilities_sha256'
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
 IF jsonb_build_object('aburame_genin',(SELECT to_jsonb(g)FROM clan_aburame_private.release_gate g WHERE singleton),'nara_genin',(SELECT to_jsonb(g)FROM combat_panel_private.nara_launch_gate_v1 g WHERE singleton),'akimichi_genin',(SELECT to_jsonb(g)FROM clan_akimichi_private.release_gate g WHERE singleton))IS DISTINCT FROM current_setting('app.joint_fix_native_gates_before')::jsonb THEN RAISE EXCEPTION 'JOINT_NATIVE_GATES_CHANGED';END IF;
 IF params->>'mode'='recovery'THEN
 UPDATE combat_v2_staff_nb_internal.gate SET staff_enabled=false,public_enabled=false WHERE singleton;
 UPDATE clan_aburame_private.verme_gate_v1 SET staff_enabled=false,public_enabled=false WHERE singleton;
 UPDATE clan_akimichi_private.common_gate_v1 SET staff_enabled=false,public_enabled=false,super_public_enabled=false,cellular_public_enabled=false WHERE singleton;
 UPDATE combat_panel_private.nara_adv_gate_v1 SET staff_enabled=false,public_enabled=false WHERE singleton;
 END IF;
  IF jsonb_build_object(
  'cure',(SELECT to_jsonb(g) FROM combat_panel_private.cure_gate_v1 g WHERE singleton),
  'genjutsu',(SELECT to_jsonb(g) FROM combat_v2_genjutsu_internal.gate g WHERE singleton),
  'NB',(SELECT to_jsonb(g) FROM combat_v2_staff_nb_internal.gate g WHERE singleton),
  'ABU',(SELECT to_jsonb(g) FROM clan_aburame_private.verme_gate_v1 g WHERE singleton),
  'AKI',(SELECT to_jsonb(g) FROM clan_akimichi_private.common_gate_v1 g WHERE singleton),
  'NARA',(SELECT to_jsonb(g) FROM combat_panel_private.nara_adv_gate_v1 g WHERE singleton)) IS DISTINCT FROM (CASE WHEN params->>'mode'='source' THEN params->'expected_gates'
   ELSE jsonb_set(jsonb_set(jsonb_set(jsonb_set(params->'expected_gates','{NB,staff_enabled}','false',false),
        '{ABU,staff_enabled}','false',false),'{AKI,staff_enabled}','false',false),'{NARA,staff_enabled}','false',false) END)
 THEN RAISE EXCEPTION 'H1H2_R1_GATE_TRANSITION_DRIFT';END IF;
 IF NOT clan_innata_private.catalogo_eligibility_release_v1()THEN RAISE EXCEPTION 'FIX_ELIGIBILITY_BRANCH_NOT_ADMITTED';END IF;
 PERFORM clan_innata_private.eligibility_release_assert();
 PERFORM set_config('app.h1h2_r1_result',jsonb_build_object('root_sha256',new_root_sha,'root_bytes',octet_length(root_text),
  'db_sha256',db_sha,'configuration_sha256',config_sha,'code_identity_sha256',identity_sha,'aliases_updated',aliases,
  'amendment_identity_sha256',binding->'normalized_source_identity_sha256','active_shared_manifest_sha256',shared_sha,'active_private_functions_manifest_sha256',private_sha,
  'new_techniques_staff_pass',false,'provider_calls',0)::text,true);
END $catalogo_root$;

COMMIT;
