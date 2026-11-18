BEGIN;
DO $cure_neutral_preflight$
DECLARE pin constant text:='__CURE_NEUTRAL_PARAMETERS_SHA256__';p jsonb;r mission_factory_owner.editor_release_readiness%ROWTYPE;n integer;
BEGIN
 IF current_user<>'postgres'OR session_user<>'postgres'OR auth.uid()IS NOT NULL THEN RAISE EXCEPTION 'cure_neutral_operator';END IF;
 PERFORM set_config('search_path','',true);p:=nullif(current_setting('app.cure_neutral_parameters',true),'')::jsonb;
 IF pin!~'^[0-9a-f]{64}$'OR p IS NULL OR public.combat_v2_sha256(p)<>pin OR p->>'schema_version'IS DISTINCT FROM 'cure-neutral-recovery-parameters/1'
 THEN RAISE EXCEPTION 'cure_neutral_parameters_required';END IF;
 IF NOT pg_try_advisory_xact_lock(hashtextextended('C1266:GENERIC-AI:AVAILABILITY',0))THEN RAISE EXCEPTION 'cure_neutral_busy';END IF;
 SELECT * INTO STRICT r FROM mission_factory_owner.editor_release_readiness WHERE singleton FOR UPDATE NOWAIT;
 IF encode(extensions.digest(convert_to(r.canonical_preimage,'UTF8'),'sha256'),'hex')IS DISTINCT FROM r.revision_sha256 THEN RAISE EXCEPTION 'cure_neutral_raw_root_drift';END IF;
 IF EXISTS(SELECT 1 FROM public.combat_v2_sessions WHERE state='in_corso'AND closed_at IS NULL)
 OR EXISTS(SELECT 1 FROM public.master_v2_sessions WHERE stato NOT IN('chiusa','annullata')AND closed_at IS NULL)
 THEN RAISE EXCEPTION 'cure_neutral_native_quiescence_required';END IF;
 IF EXISTS(SELECT 1 FROM combat_panel_private.cure_gate_v1 WHERE public_enabled)
 OR EXISTS(SELECT 1 FROM combat_v2_genjutsu_internal.gate WHERE public_enabled)
 THEN RAISE EXCEPTION 'cure_neutral_public_opening_out_of_scope';END IF;
 IF NOT EXISTS(SELECT 1 FROM combat_panel_private.cure_gate_v1 WHERE singleton AND contract_version='palmo-curativo/1')
 OR NOT EXISTS(SELECT 1 FROM combat_v2_genjutsu_internal.gate WHERE singleton AND version=1)THEN RAISE EXCEPTION 'cure_neutral_gate_row_required';END IF;
 PERFORM set_config('app.cure_neutral_cure_gate_before',(SELECT to_jsonb(g)::text FROM combat_panel_private.cure_gate_v1 g WHERE singleton),true);
 PERFORM set_config('app.cure_neutral_paralisi_gate_before',(SELECT to_jsonb(g)::text FROM combat_v2_genjutsu_internal.gate g WHERE singleton),true);
 IF md5((SELECT prosrc FROM pg_proc WHERE oid='combat_panel_private.cure_commit_v1(jsonb)'::regprocedure))<>'61532836e90ed32ae807b92ee6632b71'
 THEN RAISE EXCEPTION 'cure_neutral_committer_must_remain_unchanged';END IF;
 IF md5((SELECT prosrc FROM pg_proc WHERE oid='clan_innata_private.eligibility_release_assert()'::regprocedure))<>'250e7511806ab0fe07b6bf24b2a1770a'
 THEN RAISE EXCEPTION 'cure_neutral_guard_must_remain_unchanged';END IF;
 IF r.revision_sha256 IS DISTINCT FROM p#>>'{expected_current,root_sha256}'OR r.observed_revision_sha256 IS DISTINCT FROM r.revision_sha256
 OR public.combat_v2_sha256(to_jsonb(r))IS DISTINCT FROM p#>>'{expected_current,root_row_sha256}'
 OR octet_length(r.canonical_preimage)IS DISTINCT FROM(p#>>'{expected_current,root_bytes}')::integer
 THEN RAISE EXCEPTION 'cure_neutral_recovery_root_drift';END IF;
 IF NOT clan_innata_private.catalogo_eligibility_release_v1()THEN RAISE EXCEPTION 'cure_neutral_recovery_current_peer_seal';END IF;
 -- Only Cure sources: no forced resolution, expiry, close or snapshot rewrite.
 IF EXISTS(SELECT 1 FROM public.combat_v2_sessions s WHERE s.id IN(
  SELECT session_id FROM combat_panel_private.cure_preparations_v1 UNION SELECT session_id FROM combat_panel_private.cure_staff_profiles_v1)
  AND(s.closed_at IS NULL OR s.state NOT IN('risolto','chiuso','annullato')))
 OR EXISTS(SELECT 1 FROM public.master_v2_sessions m JOIN public.combat_v2_sessions s ON s.master_session_id=m.id
  WHERE s.id IN(SELECT session_id FROM combat_panel_private.cure_preparations_v1 UNION SELECT session_id FROM combat_panel_private.cure_staff_profiles_v1)
  AND(m.closed_at IS NULL OR m.stato NOT IN('chiusa','annullata')))
 THEN RAISE EXCEPTION 'cure_neutral_recovery_requires_native_cure_session_close';END IF;
 IF EXISTS(SELECT 1 FROM combat_panel_private.cure_preparations_v1 x JOIN public.combat_v2_declarations d ON d.id=x.declaration_id
  WHERE d.state NOT IN('risolta','superflua','annullata'))
 OR EXISTS(SELECT 1 FROM public.combat_v2_round_reports x JOIN public.combat_v2_rounds q ON q.id=x.round_id
  WHERE x.narration_state='attesa'AND q.session_id IN(SELECT session_id FROM combat_panel_private.cure_preparations_v1))
 OR EXISTS(SELECT 1 FROM combat_consumer_private.narrative_claims x WHERE x.state='claimed'AND x.session_id IN(SELECT session_id FROM combat_panel_private.cure_preparations_v1))
 OR EXISTS(SELECT 1 FROM combat_consumer_private.scene_attempts_v2 x JOIN public.combat_v2_rounds q ON q.id=x.round_id
  WHERE x.state NOT IN('published','failed')AND q.session_id IN(SELECT session_id FROM combat_panel_private.cure_preparations_v1))
 OR EXISTS(SELECT 1 FROM combat_consumer_private.dispatch_authorizations x JOIN public.combat_v2_rounds q ON q.id=x.round_id
  WHERE x.state='prepared'AND q.session_id IN(SELECT session_id FROM combat_panel_private.cure_preparations_v1))
 OR EXISTS(SELECT 1 FROM combat_consumer_private.publish_authorizations x JOIN combat_consumer_private.narrative_claims c ON c.request_key=x.request_key
  WHERE x.state='prepared'AND c.session_id IN(SELECT session_id FROM combat_panel_private.cure_preparations_v1))
 THEN RAISE EXCEPTION 'cure_neutral_recovery_requires_native_settlement';END IF;
 UPDATE combat_panel_private.cure_gate_v1 SET staff_enabled=false,public_enabled=false WHERE singleton;
 GET DIAGNOSTICS n=ROW_COUNT;IF n<>1 THEN RAISE EXCEPTION 'cure_neutral_recovery_gate_count';END IF;
END $cure_neutral_preflight$;
DO $neutral_recovery_functions$BEGIN
 IF encode(extensions.digest(convert_to(pg_get_functiondef('combat_panel_private.cure_neutral_preset_v1(uuid,uuid,uuid,jsonb)'::regprocedure),'UTF8'),'sha256'),'hex')<>'f8e03fdefd092338169c8c374e04825af8e135458fb3d1221865bdbc3cc2a339'THEN RAISE EXCEPTION 'cure_neutral_recovery_function_drift';END IF;
 IF encode(extensions.digest(convert_to(pg_get_functiondef('clan_innata_private.catalogo_eligibility_release_v1()'::regprocedure),'UTF8'),'sha256'),'hex')<>'8a67e8f7362d127ecbbc837e9d7a6255f5b235218e852c8a49d10c8e1926c297'THEN RAISE EXCEPTION 'cure_neutral_recovery_function_drift';END IF;
END $neutral_recovery_functions$;
-- SOURCE ONLY · footer forward della riparazione eligibility; non installer autonomo.
-- Catalogo825a già installato; soltanto helper/guard repair devono precedere questo footer nella stessa transazione.
-- Congelare app.cure_neutral_parameters e finalizzare il pin dopo review pertinente della capsule.
DO $catalogo_root$
DECLARE
 expected_parameters_sha256 constant text:='__CURE_NEUTRAL_PARAMETERS_SHA256__';
 old_root_sha text;
 old_row_sha text;
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
 params:=nullif(current_setting('app.cure_neutral_parameters',true),'')::jsonb;old_root_sha:=params#>>'{expected_current,root_sha256}';old_row_sha:=params#>>'{expected_current,root_row_sha256}';
 SELECT * INTO STRICT rr FROM mission_factory_owner.editor_release_readiness WHERE singleton FOR UPDATE NOWAIT;
 IF rr.revision_sha256<>old_root_sha OR rr.observed_revision_sha256 IS DISTINCT FROM old_root_sha
 OR public.combat_v2_sha256(to_jsonb(rr))<>old_row_sha
 OR encode(extensions.digest(convert_to(rr.canonical_preimage,'UTF8'),'sha256'),'hex')<>old_root_sha
 OR octet_length(rr.canonical_preimage)<>(params#>>'{expected_current,root_bytes}')::integer THEN RAISE EXCEPTION 'CATALOGO_ROOT_BASELINE_DRIFT';END IF;
 IF EXISTS(SELECT 1 FROM public.combat_v2_sessions WHERE state='in_corso' AND closed_at IS NULL)
 OR EXISTS(SELECT 1 FROM public.master_v2_sessions WHERE stato NOT IN('chiusa','annullata') AND closed_at IS NULL) THEN
  RAISE EXCEPTION 'CATALOGO_ROOT_REQUIRES_QUIESCENCE';END IF;
 params:=nullif(current_setting('app.cure_neutral_parameters',true),'')::jsonb;
 IF expected_parameters_sha256 !~ '^[0-9a-f]{64}$' OR params IS NULL
 OR public.combat_v2_sha256(params)<>expected_parameters_sha256
 OR params->>'schema_version' IS DISTINCT FROM 'cure-neutral-recovery-parameters/1' THEN
  RAISE EXCEPTION 'CATALOGO_ROOT_REVIEWED_PARAMETERS_REQUIRED';END IF;
 review:=params->'review';
 IF NOT mission_factory_owner.keys_exact_v2(review,ARRAY['ref','sha256','P0','P1','P2']) THEN
  RAISE EXCEPTION 'CATALOGO_ROOT_REVIEW_SHAPE';END IF;
 IF nullif(review->>'ref','') IS NULL OR octet_length(to_jsonb(review->>'ref')::text)>514 OR coalesce(review->>'sha256','')!~'^[0-9a-f]{64}$'
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
 IF db_stored IS DISTINCT FROM params#>>'{expected_current,db_sha256}' OR db_old_recomputed IS DISTINCT FROM db_stored
 OR root#>>'{config,sha256}'<>public.combat_v2_sha256((root->'config')-'sha256') THEN
  RAISE EXCEPTION 'CATALOGO_ROOT_HASH_RECONCILIATION_DRIFT';END IF;

 -- Base825a/654f/e14b provenance; current neutral revision reuses the existing amendment slot.
 SELECT coalesce(jsonb_agg(jsonb_build_object('signature',p.oid::regprocedure::text,'source_md5',md5(p.prosrc),'ddl_md5',md5(pg_get_functiondef(p.oid)),
 'owner',pg_get_userbyid(p.proowner),'acl',p.proacl::text,'config',p.proconfig,'secdef',p.prosecdef,'volatility',p.provolatile::text,'language',l.lanname,
 'strict',p.proisstrict,'parallel',p.proparallel::text,'returns',pg_get_function_result(p.oid),'arg_names',p.proargnames,'arg_modes',p.proargmodes,'arg_types',p.proargtypes::text)
 ORDER BY p.oid::regprocedure::text),'[]'::jsonb) INTO private_manifest FROM pg_proc p JOIN pg_namespace n ON n.oid=p.pronamespace JOIN pg_language l ON l.oid=p.prolang
 WHERE p.prokind='f'AND(n.nspname='combat_v2_genjutsu_internal'OR(n.nspname='combat_panel_private'AND(p.proname LIKE 'cure\_%'ESCAPE'\'OR p.proname IN('catalog_result_label_v1','catalog_lifecycle_lines_v1'))));private_sha:=public.combat_v2_sha256(private_manifest);
 IF jsonb_array_length(private_manifest)<>66 THEN RAISE EXCEPTION 'cure_neutral_private66_count';END IF;
 SELECT jsonb_agg(jsonb_build_object('signature',p.oid::regprocedure::text,'source_md5',md5(p.prosrc),'ddl_md5',md5(pg_get_functiondef(p.oid)),
 'owner',pg_get_userbyid(p.proowner),'secdef',p.prosecdef,'config',p.proconfig,'acl',p.proacl::text,'volatility',p.provolatile::text)ORDER BY p.oid::regprocedure::text)
  INTO trigger_manifest FROM pg_proc p WHERE p.oid IN('combat_panel_private.cure_neutral_preset_v1(uuid,uuid,uuid,jsonb)'::regprocedure,'clan_innata_private.catalogo_eligibility_release_v1()'::regprocedure);
 SELECT jsonb_agg(jsonb_build_object('signature',p.oid::regprocedure::text,'source_md5',md5(p.prosrc),'ddl_md5',md5(pg_get_functiondef(p.oid)),
 'owner',pg_get_userbyid(p.proowner),'secdef',p.prosecdef,'config',p.proconfig,'acl',p.proacl::text,'volatility',p.provolatile::text)ORDER BY p.oid::regprocedure::text)
  INTO relation_manifest FROM pg_proc p WHERE p.oid IN('clan_innata_private.eligibility_release_assert()'::regprocedure,'clan_innata_private.catalogo_eligibility_release_v1()'::regprocedure);
  binding:=(root#>'{db_core,cure_command_amendment}')||jsonb_build_object('state','inert_recovery',
  'recovery_source_bundle_sha256',params->'source_bundle_sha256','private_functions_manifest_sha256',private_sha,
  'functions',trigger_manifest,'functions_manifest_sha256',public.combat_v2_sha256(trigger_manifest),
  'availability',jsonb_build_object('cure_staff_enabled',false,'cure_public_enabled',false,'paralisi_unchanged',true));
 root:=jsonb_set(root,'{db_core,cure_command_amendment}',binding,false);root:=jsonb_set(root,'{config,cure_command_amendment}',binding,false);
 cfg:=root#>'{db_core,catalogo_eligibility_compat}';
 cfg:=cfg||jsonb_build_object('private_functions_manifest_sha256',private_sha,'helper_source_md5','9dd463238ba358947054d12f95e935cd',
  'active_amendment_source_bundle_sha256',binding->'source_bundle_sha256','active_amendment_contract','cure-command-amendment/1',
  'functions',relation_manifest,'functions_manifest_sha256',public.combat_v2_sha256(relation_manifest));
 root:=jsonb_set(root,'{db_core,catalogo_eligibility_compat}',cfg,false);root:=jsonb_set(root,'{config,catalogo_eligibility_compat}',cfg,false);

 core:=root->'db_core';db_sha:=public.combat_v2_sha256(core-'sha256');core:=jsonb_set(core,'{sha256}',to_jsonb(db_sha),false);root:=jsonb_set(root,'{db_core}',core,false);
 cfg:=root->'config';config_sha:=public.combat_v2_sha256(cfg-'sha256');cfg:=jsonb_set(cfg,'{sha256}',to_jsonb(config_sha),false);root:=jsonb_set(root,'{config}',cfg,false);
 identity:=jsonb_build_object('schema_version','cure-neutral-code-identity/1','parent_root',old_root_sha,'parent_code_identity',before_root#>'{contract,code_identity_sha256}',
  'normalized_amendment_identity_sha256',binding->'normalized_source_identity_sha256','active_private_functions_manifest_sha256',private_sha,
  'source_bundle_sha256',params->'source_bundle_sha256','db_sha256',db_sha,'amendment_state',binding->'state');
 identity_sha:=public.combat_v2_sha256(identity);root:=jsonb_set(root,'{contract,code_identity_sha256}',to_jsonb(identity_sha),false);
 root:=jsonb_set(root,'{recovery,semantic_identity_sha256}',to_jsonb(identity_sha),false);
 root:=jsonb_set(root,'{recovery,cure_neutral_revision}',jsonb_build_object('parent_root',old_root_sha,'state',binding->'state',
  'previous_semantic_identity',before_root#>'{recovery,semantic_identity_sha256}','policy','forward_cure_off_keep_neutral_alias_fix'),true);
 IF root->'ui'IS DISTINCT FROM before_root->'ui'OR root->'edge_bundles'IS DISTINCT FROM before_root->'edge_bundles'
 OR(root->'config')-ARRAY['sha256','cure_command_amendment','catalogo_eligibility_compat']IS DISTINCT FROM(before_root->'config')-ARRAY['sha256','cure_command_amendment','catalogo_eligibility_compat']
 OR root#>'{db_core,catalogo_completo}'IS DISTINCT FROM before_root#>'{db_core,catalogo_completo}'
 THEN RAISE EXCEPTION 'cure_neutral_unrelated_config_changed';END IF;
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
 IF NOT EXISTS(SELECT 1 FROM combat_panel_private.cure_gate_v1 WHERE singleton AND NOT staff_enabled AND NOT public_enabled)THEN RAISE EXCEPTION 'cure_neutral_recovery_cure_gate_not_off';END IF;
 IF(SELECT to_jsonb(g)FROM combat_v2_genjutsu_internal.gate g WHERE singleton)IS DISTINCT FROM current_setting('app.cure_neutral_paralisi_gate_before')::jsonb THEN RAISE EXCEPTION 'cure_neutral_paralisi_gate_changed';END IF;
 IF NOT clan_innata_private.catalogo_eligibility_release_v1()THEN RAISE EXCEPTION 'cure_neutral_peer_branch_not_admitted';END IF;
 PERFORM set_config('app.cure_neutral_result',jsonb_build_object('root_sha256',new_root_sha,'root_bytes',octet_length(root_text),
  'db_sha256',db_sha,'configuration_sha256',config_sha,'code_identity_sha256',identity_sha,'aliases_updated',aliases,
  'amendment_identity_sha256',binding->'normalized_source_identity_sha256','active_private_functions_manifest_sha256',private_sha,
  'new_techniques_staff_pass',false,'provider_calls',0)::text,true);
END $catalogo_root$;

COMMIT;
