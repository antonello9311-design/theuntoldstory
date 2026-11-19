BEGIN;
DO $cure_reaction_preflight$
DECLARE pin constant text:='__PALMO_COMPLETION_PARAMETERS_SHA256__';p jsonb;r mission_factory_owner.editor_release_readiness%ROWTYPE;n integer;
BEGIN
 IF current_user<>'postgres'OR session_user<>'postgres'OR auth.uid()IS NOT NULL THEN RAISE EXCEPTION 'cure_reaction_operator';END IF;
 PERFORM set_config('search_path','',true);p:=nullif(current_setting('app.palmo_completion_parameters',true),'')::jsonb;
 IF pin!~'^[0-9a-f]{64}$'OR p IS NULL OR public.combat_v2_sha256(p)<>pin OR p->>'schema_version'IS DISTINCT FROM 'palmo-completion-parameters/1'
 THEN RAISE EXCEPTION 'cure_reaction_parameters_required';END IF;
 IF NOT pg_try_advisory_xact_lock(hashtextextended('C1266:GENERIC-AI:AVAILABILITY',0))THEN RAISE EXCEPTION 'cure_reaction_busy';END IF;
 SELECT * INTO STRICT r FROM mission_factory_owner.editor_release_readiness WHERE singleton FOR UPDATE NOWAIT;
 IF encode(extensions.digest(convert_to(r.canonical_preimage,'UTF8'),'sha256'),'hex')IS DISTINCT FROM r.revision_sha256 THEN RAISE EXCEPTION 'cure_reaction_raw_root_drift';END IF;
 IF EXISTS(SELECT 1 FROM public.combat_v2_sessions WHERE state='in_corso'AND closed_at IS NULL)
 OR EXISTS(SELECT 1 FROM public.master_v2_sessions WHERE stato NOT IN('chiusa','annullata')AND closed_at IS NULL)
 THEN RAISE EXCEPTION 'cure_reaction_native_quiescence_required';END IF;
 IF EXISTS(SELECT 1 FROM combat_panel_private.cure_gate_v1 WHERE public_enabled)
 OR EXISTS(SELECT 1 FROM combat_v2_genjutsu_internal.gate WHERE public_enabled)
 THEN RAISE EXCEPTION 'cure_reaction_public_opening_out_of_scope';END IF;
 IF NOT EXISTS(SELECT 1 FROM combat_panel_private.cure_gate_v1 WHERE singleton AND contract_version='palmo-curativo/1')
 OR NOT EXISTS(SELECT 1 FROM combat_v2_genjutsu_internal.gate WHERE singleton AND version=1)THEN RAISE EXCEPTION 'cure_reaction_gate_row_required';END IF;
 PERFORM set_config('app.cure_reaction_cure_gate_before',(SELECT to_jsonb(g)::text FROM combat_panel_private.cure_gate_v1 g WHERE singleton),true);
 PERFORM set_config('app.cure_reaction_paralisi_gate_before',(SELECT to_jsonb(g)::text FROM combat_v2_genjutsu_internal.gate g WHERE singleton),true);
 IF md5((SELECT prosrc FROM pg_proc WHERE oid='combat_panel_private.cure_commit_v1(jsonb)'::regprocedure))IS DISTINCT FROM '61532836e90ed32ae807b92ee6632b71'
 THEN RAISE EXCEPTION 'cure_reaction_committer_must_remain_unchanged';END IF;
 IF md5((SELECT prosrc FROM pg_proc WHERE oid='clan_innata_private.eligibility_release_assert()'::regprocedure))IS DISTINCT FROM '250e7511806ab0fe07b6bf24b2a1770a'
 THEN RAISE EXCEPTION 'cure_reaction_guard_must_remain_unchanged';END IF;
 IF r.revision_sha256 IS DISTINCT FROM p#>>'{expected_current,root_sha256}'OR r.observed_revision_sha256 IS DISTINCT FROM r.revision_sha256
 OR public.combat_v2_sha256(to_jsonb(r))IS DISTINCT FROM p#>>'{expected_current,root_row_sha256}'
 OR octet_length(r.canonical_preimage)IS DISTINCT FROM(p#>>'{expected_current,root_bytes}')::integer
 THEN RAISE EXCEPTION 'cure_reaction_recovery_root_drift';END IF;
 IF r.revision_sha256 IS DISTINCT FROM '21c3e8e6f9aae4b2dbe9e5169a9f6e2c3bced79e32d251c1ff6eaecf2b2a3c66'OR public.combat_v2_sha256(to_jsonb(r))IS DISTINCT FROM '265efaa5944f652eb1ffa2a7a57472158ff1ec8d97271fa33ef5787c5c16ba01'THEN RAISE EXCEPTION 'palmo_completion_original_baseline';END IF;
 IF NOT EXISTS(SELECT 1 FROM combat_panel_private.cure_gate_v1 WHERE singleton AND staff_enabled AND NOT public_enabled)
 OR NOT EXISTS(SELECT 1 FROM combat_v2_genjutsu_internal.gate WHERE singleton AND staff_enabled AND NOT public_enabled)THEN RAISE EXCEPTION 'palmo_completion_initial_staff_gates';END IF;
 IF NOT clan_innata_private.catalogo_eligibility_release_v1()THEN RAISE EXCEPTION 'cure_reaction_recovery_current_peer_seal';END IF;
 -- Only Cure sources: no forced resolution, expiry, close or snapshot rewrite.
 IF EXISTS(SELECT 1 FROM public.combat_v2_sessions s WHERE s.id IN(
  SELECT session_id FROM combat_panel_private.cure_preparations_v1 UNION SELECT session_id FROM combat_panel_private.cure_staff_profiles_v1)
  AND(s.closed_at IS NULL OR s.state NOT IN('risolto','chiuso','annullato')))
 OR EXISTS(SELECT 1 FROM public.master_v2_sessions m JOIN public.combat_v2_sessions s ON s.master_session_id=m.id
  WHERE s.id IN(SELECT session_id FROM combat_panel_private.cure_preparations_v1 UNION SELECT session_id FROM combat_panel_private.cure_staff_profiles_v1)
  AND(m.closed_at IS NULL OR m.stato NOT IN('chiusa','annullata')))
 THEN RAISE EXCEPTION 'cure_reaction_recovery_requires_native_cure_session_close';END IF;
 IF EXISTS(SELECT 1 FROM combat_panel_private.cure_preparations_v1 x JOIN public.combat_v2_declarations d ON d.id=x.declaration_id
  WHERE d.state NOT IN('risolta','superflua','annullata')
  AND NOT coalesce((d.state='inviata' AND d.outcome IS NULL
   AND d.kind='utilita'
   AND d.sanitized_intent->>'ability_source'='clan'
   AND d.sanitized_intent->>'ability_id'='c47814d2-ef27-4967-87ad-da633b0f4d78'
   AND x.request_key=d.request_key AND x.target_actor_id=d.target_actor_id
   AND x.controller_user=d.controller_user_snapshot AND x.controller_version=d.controller_version_snapshot
   AND x.source=d.sanitized_intent->'server_ability' AND x.source_sha256=public.combat_v2_sha256(x.source)
   AND x.source->>'source'='clan' AND x.source->>'id'='c47814d2-ef27-4967-87ad-da633b0f4d78'
   AND x.source->>'cure_contract'='palmo-curativo/1' AND x.source->'chakra_cost'='20'::jsonb
   AND x.source->>'scope_kind'IN('simulation','persistent')
   AND EXISTS(SELECT 1 FROM public.combat_v2_actors bound_actor JOIN public.combat_v2_actors bound_target
    ON bound_target.id=x.target_actor_id AND bound_target.session_id=x.session_id
    WHERE bound_actor.id=x.actor_id AND bound_actor.session_id=x.session_id)
   AND d.round_id=x.round_id AND d.actor_id=x.actor_id
   AND d.sanitized_intent#>>'{server_ability,cure_contract}'='palmo-curativo/1'
   AND EXISTS(SELECT 1 FROM public.combat_v2_rounds stopped_round
    JOIN public.combat_v2_sessions stopped_session ON stopped_session.id=stopped_round.session_id
    LEFT JOIN public.master_v2_sessions stopped_master ON stopped_master.id=stopped_session.master_session_id
    WHERE stopped_round.id=x.round_id AND stopped_round.session_id=x.session_id
     AND stopped_session.state='annullato' AND stopped_session.closed_at IS NOT NULL
     AND((stopped_session.source_kind='master' AND stopped_master.owner_kind='human'
       AND stopped_master.tipo='duello' AND stopped_master.mission_id IS NULL
       AND stopped_master.stato='annullata' AND stopped_master.closed_at IS NOT NULL)
      OR(stopped_session.source_kind='ordinary' AND stopped_session.master_session_id IS NULL
       AND EXISTS(SELECT 1 FROM combat_consumer_private.activities stopped_activity
        WHERE stopped_activity.session_id=stopped_session.id AND stopped_activity.phase='closed')))
     AND NOT EXISTS(SELECT 1 FROM combat_consumer_private.activities live_activity
      WHERE live_activity.session_id=stopped_session.id AND live_activity.phase IS DISTINCT FROM 'closed'))
   AND NOT EXISTS(SELECT 1 FROM combat_panel_private.cure_ledger_v1 frozen_effect WHERE frozen_effect.declaration_id=d.id)
   AND NOT EXISTS(SELECT 1 FROM public.combat_v2_round_reports frozen_report WHERE frozen_report.round_id=x.round_id)),false))
 OR EXISTS(SELECT 1 FROM public.combat_v2_round_reports x JOIN public.combat_v2_rounds q ON q.id=x.round_id
  WHERE x.narration_state='attesa'AND q.session_id IN(SELECT session_id FROM combat_panel_private.cure_preparations_v1))
 OR EXISTS(SELECT 1 FROM combat_consumer_private.narrative_claims x WHERE x.state='claimed'AND x.session_id IN(SELECT session_id FROM combat_panel_private.cure_preparations_v1))
 OR EXISTS(SELECT 1 FROM combat_consumer_private.scene_attempts_v2 x JOIN public.combat_v2_rounds q ON q.id=x.round_id
  WHERE x.state NOT IN('published','failed')AND q.session_id IN(SELECT session_id FROM combat_panel_private.cure_preparations_v1))
 OR EXISTS(SELECT 1 FROM combat_consumer_private.dispatch_authorizations x JOIN public.combat_v2_rounds q ON q.id=x.round_id
  WHERE x.state='prepared'AND q.session_id IN(SELECT session_id FROM combat_panel_private.cure_preparations_v1))
 OR EXISTS(SELECT 1 FROM combat_consumer_private.publish_authorizations x JOIN combat_consumer_private.narrative_claims c ON c.request_key=x.request_key
  WHERE x.state='prepared'AND c.session_id IN(SELECT session_id FROM combat_panel_private.cure_preparations_v1))
 THEN RAISE EXCEPTION 'cure_reaction_recovery_requires_native_settlement';END IF;
 IF encode(extensions.digest(convert_to(pg_get_functiondef('combat_panel_private.round_options_authoritative(uuid,uuid)'::regprocedure),'UTF8'),'sha256'),'hex')<>'8202022a72be61ee4353130124718e8840a9c949e53cd9d4484301a52985ad7f'THEN RAISE EXCEPTION 'cure_reaction_recovery_function_drift';END IF;
 IF encode(extensions.digest(convert_to(pg_get_functiondef('public.combat_v2_substitution_options_v1(uuid)'::regprocedure),'UTF8'),'sha256'),'hex')<>'f4e1872fb68c1628baab16fae97e96f1a98d3f0a6e9a6fde191259984e4d222c'THEN RAISE EXCEPTION 'cure_reaction_recovery_function_drift';END IF;
 IF encode(extensions.digest(convert_to(pg_get_functiondef('public.combat_v2_substitution_round_offers_v1(uuid,uuid)'::regprocedure),'UTF8'),'sha256'),'hex')<>'a7c66d2e072f3f80704571c559de29df8316f4cdee1864c13842fdd06a8b7432'THEN RAISE EXCEPTION 'cure_reaction_recovery_function_drift';END IF;
 IF encode(extensions.digest(convert_to(pg_get_functiondef('public.combat_v2_substitution_select_v1(uuid,uuid)'::regprocedure),'UTF8'),'sha256'),'hex')<>'6890fd39ba417eb6a685a9ce7264b178ea9dacaca63f0e24ba2176915e1e740b'THEN RAISE EXCEPTION 'cure_reaction_recovery_function_drift';END IF;
 IF encode(extensions.digest(convert_to(pg_get_functiondef('clan_innata_private.catalogo_eligibility_release_v1()'::regprocedure),'UTF8'),'sha256'),'hex')<>'9a1dfefa5ffe5d7612401a1dd9c736621ce2dbe54592ca0f73cd5b367bc52fb8'THEN RAISE EXCEPTION 'cure_reaction_recovery_function_drift';END IF;
 IF md5((SELECT prosrc FROM pg_proc WHERE oid='combat_panel_private.cure_defense_guard_v1()'::regprocedure))IS DISTINCT FROM '72b7362b50720f93672dfa1ab96338bc'THEN RAISE EXCEPTION 'cure_reaction_preserved_function_drift';END IF;
 IF md5((SELECT prosrc FROM pg_proc WHERE oid='combat_panel_private.cure_turn_used_v1(uuid,uuid)'::regprocedure))IS DISTINCT FROM '11badbd523e79faba44fa282150be54b'THEN RAISE EXCEPTION 'cure_reaction_preserved_function_drift';END IF;
 IF md5((SELECT prosrc FROM pg_proc WHERE oid='combat_panel_private.cure_neutral_preset_v1(uuid,uuid,uuid,jsonb)'::regprocedure))IS DISTINCT FROM '0f48477bfc086b98e113e2dd70bba0de'THEN RAISE EXCEPTION 'cure_reaction_preserved_function_drift';END IF;
 IF encode(extensions.digest(convert_to(pg_get_functiondef('combat_panel_private.cure_contact_v1(uuid,uuid)'::regprocedure),'UTF8'),'sha256'),'hex')IS DISTINCT FROM 'bf83ec4740cace7d9169333e8de908e7c51af0fd2ea0953fc84849786e1999ae'THEN RAISE EXCEPTION 'palmo_completion_function_drift:%','combat_panel_private.cure_contact_v1(uuid,uuid)';END IF;
 IF encode(extensions.digest(convert_to(pg_get_functiondef('combat_panel_private.cure_offers_v1(uuid,bigint,jsonb)'::regprocedure),'UTF8'),'sha256'),'hex')IS DISTINCT FROM 'a192013b5156ab59e9c6ce9526ee19178e15e2bbd3d1dedd75ebe9629288ea1a'THEN RAISE EXCEPTION 'palmo_completion_function_drift:%','combat_panel_private.cure_offers_v1(uuid,bigint,jsonb)';END IF;
 IF encode(extensions.digest(convert_to(pg_get_functiondef('combat_panel_private.publish_master_declaration(uuid,text)'::regprocedure),'UTF8'),'sha256'),'hex')IS DISTINCT FROM 'a4ad1f0fd7784b1b619d0672761e88dbd5b44d56b82acf404ae4bc47c376f60d'THEN RAISE EXCEPTION 'palmo_completion_function_drift:%','combat_panel_private.publish_master_declaration(uuid,text)';END IF;
 IF encode(extensions.digest(convert_to(pg_get_functiondef('clan_innata_private.catalogo_eligibility_release_v1()'::regprocedure),'UTF8'),'sha256'),'hex')IS DISTINCT FROM '9a1dfefa5ffe5d7612401a1dd9c736621ce2dbe54592ca0f73cd5b367bc52fb8'THEN RAISE EXCEPTION 'palmo_completion_function_drift:%','clan_innata_private.catalogo_eligibility_release_v1()';END IF;
END $cure_reaction_preflight$;
DO $cure_neutral_patch$
DECLARE ps constant jsonb:=$cure_hunks$[{"signature":"combat_panel_private.cure_contact_v1(uuid,uuid)","before_ddl_sha256":"bf83ec4740cace7d9169333e8de908e7c51af0fd2ea0953fc84849786e1999ae","after_ddl_sha256":"94e8edaf1ce243a8dd19cb3458d44b15a72423039548fa06d648420e3250a675","before_source_md5":"878069c4d7dca1bc0ddade6b22f35c7d","after_source_md5":"a11beefff5632280291395f9b4d9cad6","hunks":[{"before":" IF a.id IS NULL OR t.id IS NULL OR a.session_id<>t.session_id OR a.team_key<>t.team_key","after":" IF a.id IS NULL OR t.id IS NULL OR t.actor_kind IS DISTINCT FROM 'pg'\n  OR a.session_id<>t.session_id OR a.team_key<>t.team_key"}],"inverse_exact":true,"header_ABI_unchanged":true},{"signature":"combat_panel_private.cure_offers_v1(uuid,bigint,jsonb)","before_ddl_sha256":"a192013b5156ab59e9c6ce9526ee19178e15e2bbd3d1dedd75ebe9629288ea1a","after_ddl_sha256":"4f64818727570eba0e455db6c098c2bbd8cc92b15a4c7535d8026644c0ae0bbd","before_source_md5":"66a3d715a7ca7f77ef3f36cd121fd5ec","after_source_md5":"db137b63815164ffd8435bcf87ce245c","hunks":[{"before":" FOR t IN SELECT * FROM public.combat_v2_actors WHERE session_id=a.session_id AND team_key=a.team_key\n AND companion_id IS NULL","after":" FOR t IN SELECT * FROM public.combat_v2_actors WHERE session_id=a.session_id AND team_key=a.team_key\n AND actor_kind='pg' AND companion_id IS NULL"}],"inverse_exact":true,"header_ABI_unchanged":true},{"signature":"combat_panel_private.publish_master_declaration(uuid,text)","before_ddl_sha256":"a4ad1f0fd7784b1b619d0672761e88dbd5b44d56b82acf404ae4bc47c376f60d","after_ddl_sha256":"377cb7bcbc4d5ec3fb1c7fd49e2fa59552e5f2ba55dc4435b5eb21bbd4590c6b","before_source_md5":"e0fd1218564894f3d710fbd87c766dd7","after_source_md5":"5bc0eeaea3b3b64578105067b4b40c28","hunks":[{"before":"native_pg_resolved boolean:=false;","after":"native_pg_resolved boolean:=false; human_png_pass_resolved boolean:=false;"},{"before":"  -- Native PNG defences remain private until the complete round Fato.","after":"  -- Roleless human-Master PNG Passa may auto-resolve the complete round before\n  -- this publisher. Admit only the exact completed native event, with Cure's\n  -- existing Staff/public scopes; no mission, exam or service staging extension.\n  IF a.actor_kind='png' AND d.state='risolta' AND d.kind='passa'\n   AND d.declaration_text='' AND coalesce(p_text,'')=''\n   AND auth.uid() IS NOT NULL AND a.controller_user=auth.uid() THEN\n   SELECT EXISTS(SELECT 1 FROM public.combat_v2_events accepted\n    JOIN public.combat_v2_rounds rr ON rr.id=d.round_id AND rr.session_id=a.session_id\n    JOIN public.combat_v2_sessions ss ON ss.id=rr.session_id\n    JOIN public.master_v2_sessions ms ON ms.id=ss.master_session_id\n    JOIN public.combat_v2_round_reports report ON report.id=rr.report_id AND report.round_id=rr.id\n    WHERE ss.source_kind='master' AND ss.state='in_corso' AND ss.closed_at IS NULL\n     AND ms.owner_kind='human' AND ms.tipo='duello' AND ms.master_user=auth.uid()\n     AND ms.mission_id IS NULL AND ms.closed_at IS NULL AND ms.suspended_at IS NULL\n     AND accepted.scope_id=d.round_id AND accepted.request_key=d.request_key\n     AND accepted.operation_kind='combat_v2_action_declare' AND accepted.status='completata'\n     AND accepted.caller=auth.uid() AND accepted.caller=d.controller_user_snapshot\n     AND accepted.result#>>'{data,declaration_id}'=d.id::text AND accepted.result#>>'{data,phase}'='risolto'\n     AND accepted.result#>>'{data,auto_resolution,data,report_id}'=report.id::text\n     AND rr.state='risolto' AND rr.resolved_at IS NOT NULL AND report.narration_state='attesa'\n     AND report.values_written IS NOT DISTINCT FROM public.combat_v2_values_written(ss.id)\n     AND report.mechanics_sha256=public.combat_v2_sha256(report.mechanics)\n     AND EXISTS(SELECT 1 FROM public.combat_v2_actors scoped_pg\n       WHERE scoped_pg.session_id=ss.id AND scoped_pg.actor_kind='pg'\n        AND(scoped_pg.companion_id IS NULL)\n        AND(combat_panel_private.cure_staff_scope_v1(scoped_pg.id)\n         OR combat_panel_private.cure_persistent_scope_v1(scoped_pg.id)))\n     AND NOT EXISTS(SELECT 1 FROM mission_generic_owner.unified_round_windows uw WHERE uw.round_id=rr.id)\n     AND NOT EXISTS(SELECT 1 FROM exam_regia_private.bindings eb WHERE eb.combat_session_id=ss.id))\n   INTO human_png_pass_resolved;\n  END IF;\n  -- Native PNG defences remain private until the complete round Fato."},{"before":"OR human_pg_resolved OR native_pg_resolved))","after":"OR human_pg_resolved OR native_pg_resolved OR human_png_pass_resolved))"}],"inverse_exact":true,"header_ABI_unchanged":true},{"signature":"clan_innata_private.catalogo_eligibility_release_v1()","before_ddl_sha256":"9a1dfefa5ffe5d7612401a1dd9c736621ce2dbe54592ca0f73cd5b367bc52fb8","after_ddl_sha256":"5c6d0b8482ced37b7459eefb5f1a3c5dca3e37f2cfab83f11ef8fda414d147a9","before_source_md5":"4eed429acb898bc526a5b7b8c21c5334","after_source_md5":"13d099eb15a2759534507b75f85570d7","hunks":[{"before":"{\"signature\":\"combat_panel_private.cure_contact_v1(uuid,uuid)\",\"source_md5\":\"878069c4d7dca1bc0ddade6b22f35c7d\"}","after":"{\"signature\":\"combat_panel_private.cure_contact_v1(uuid,uuid)\",\"source_md5\":\"a11beefff5632280291395f9b4d9cad6\"}"},{"before":"{\"signature\":\"combat_panel_private.cure_offers_v1(uuid,bigint,jsonb)\",\"source_md5\":\"66a3d715a7ca7f77ef3f36cd121fd5ec\"}","after":"{\"signature\":\"combat_panel_private.cure_offers_v1(uuid,bigint,jsonb)\",\"source_md5\":\"db137b63815164ffd8435bcf87ce245c\"}"},{"before":"amendment->>'active_repair_kind'IS DISTINCT FROM 'cure-reaction-turn/1'","after":"amendment->>'active_repair_kind'IS DISTINCT FROM 'palmo-completion/1'"},{"before":"amendment->>'normalized_source_identity_sha256'IS DISTINCT FROM 'e00efa15142faaa8c07767231e969224273f43b838e733b9a61d70f1e326bc2b'","after":"amendment->>'normalized_source_identity_sha256'IS DISTINCT FROM '7c24a6b523c5f05714bfd0f085e4963664486b2b064f4dde850e3a09bd66b248'"},{"before":"'clan_innata_private.catalogo_eligibility_release_v1()'::regprocedure);","after":"'clan_innata_private.catalogo_eligibility_release_v1()'::regprocedure,'combat_panel_private.publish_master_declaration(uuid,text)'::regprocedure);"},{"before":"jsonb_array_length(changed_manifest)<>5","after":"jsonb_array_length(changed_manifest)<>6"}],"inverse_exact":true,"header_ABI_unchanged":true}]$cure_hunks$::jsonb;p jsonb;h jsonb;s text;actual text;
BEGIN
 FOR p IN SELECT value FROM jsonb_array_elements(ps)LOOP
  s:=pg_get_functiondef(to_regprocedure(p->>'signature'));
  IF s IS NULL OR encode(extensions.digest(convert_to(s,'UTF8'),'sha256'),'hex')IS DISTINCT FROM p->>'before_ddl_sha256'
  THEN RAISE EXCEPTION 'cure_neutral_patch_preimage:%',p->>'signature';END IF;
 END LOOP;
 FOR p IN SELECT value FROM jsonb_array_elements(ps)LOOP
  s:=pg_get_functiondef(to_regprocedure(p->>'signature'));
  FOR h IN SELECT value FROM jsonb_array_elements(p->'hunks')LOOP
   IF length(h->>'before')=0 OR(length(s)-length(replace(s,h->>'before','')))/length(h->>'before')<>1
   THEN RAISE EXCEPTION 'cure_neutral_patch_anchor:%',p->>'signature';END IF;
   s:=replace(s,h->>'before',h->>'after');
  END LOOP;
  IF encode(extensions.digest(convert_to(s,'UTF8'),'sha256'),'hex')IS DISTINCT FROM p->>'after_ddl_sha256'THEN RAISE EXCEPTION 'cure_neutral_patch_composition';END IF;
  EXECUTE s;
  SELECT prosrc INTO STRICT actual FROM pg_proc WHERE oid=to_regprocedure(p->>'signature');
  IF md5(actual)IS DISTINCT FROM p->>'after_source_md5'OR encode(extensions.digest(convert_to(pg_get_functiondef(to_regprocedure(p->>'signature')),'UTF8'),'sha256'),'hex')IS DISTINCT FROM p->>'after_ddl_sha256'
  THEN RAISE EXCEPTION 'cure_neutral_patch_postimage:%',p->>'signature';END IF;
 END LOOP;
END $cure_neutral_patch$;

-- SOURCE ONLY: Palmo target-PG and exact roleless human PNG Passa; current SafeRecovery settlement retained.
-- Base825a/compat654f/commandE14/neutral0780 remain provenance; current manifest is amended explicitly.
-- Congelare app.palmo_completion_parameters e finalizzare il pin dopo review pertinente della capsule.
DO $catalogo_root$
DECLARE
 expected_parameters_sha256 constant text:='__PALMO_COMPLETION_PARAMETERS_SHA256__';
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
 params:=nullif(current_setting('app.palmo_completion_parameters',true),'')::jsonb;old_root_sha:=params#>>'{expected_current,root_sha256}';old_row_sha:=params#>>'{expected_current,root_row_sha256}';
 SELECT * INTO STRICT rr FROM mission_factory_owner.editor_release_readiness WHERE singleton FOR UPDATE NOWAIT;
 IF rr.revision_sha256<>old_root_sha OR rr.observed_revision_sha256 IS DISTINCT FROM old_root_sha
 OR public.combat_v2_sha256(to_jsonb(rr))<>old_row_sha
 OR encode(extensions.digest(convert_to(rr.canonical_preimage,'UTF8'),'sha256'),'hex')<>old_root_sha
 OR octet_length(rr.canonical_preimage)<>(params#>>'{expected_current,root_bytes}')::integer THEN RAISE EXCEPTION 'CATALOGO_ROOT_BASELINE_DRIFT';END IF;
 IF EXISTS(SELECT 1 FROM public.combat_v2_sessions WHERE state='in_corso' AND closed_at IS NULL)
 OR EXISTS(SELECT 1 FROM public.master_v2_sessions WHERE stato NOT IN('chiusa','annullata') AND closed_at IS NULL) THEN
  RAISE EXCEPTION 'CATALOGO_ROOT_REQUIRES_QUIESCENCE';END IF;
 params:=nullif(current_setting('app.palmo_completion_parameters',true),'')::jsonb;
 IF expected_parameters_sha256 !~ '^[0-9a-f]{64}$' OR params IS NULL
 OR public.combat_v2_sha256(params)<>expected_parameters_sha256
 OR params->>'schema_version' IS DISTINCT FROM 'palmo-completion-parameters/1' THEN
  RAISE EXCEPTION 'CATALOGO_ROOT_REVIEWED_PARAMETERS_REQUIRED';END IF;
 review:=params->'review';
 IF NOT mission_factory_owner.keys_exact_v2(review,ARRAY['ref','sha256','P0','P1','P2']) THEN
  RAISE EXCEPTION 'CATALOGO_ROOT_REVIEW_SHAPE';END IF;
 IF nullif(review->>'ref','') IS NULL OR octet_length(to_jsonb(review->>'ref')::text)>258 OR coalesce(review->>'sha256','')!~'^[0-9a-f]{64}$'
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
 OR public.combat_v2_sha256(root->'ui')<>'cd76714cb188ea3f69189ac5dd793304acdc2179da724aad852f961d12ab3014' THEN
  RAISE EXCEPTION 'CATALOGO_ROOT_UNRELATED_SURFACE_DRIFT';END IF;
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
 WHERE p.prokind='f'AND p.oid IN('combat_panel_private.cure_contact_v1(uuid,uuid)'::regprocedure,'combat_panel_private.cure_offers_v1(uuid,bigint,jsonb)'::regprocedure,'combat_panel_private.publish_master_declaration(uuid,text)'::regprocedure,'clan_innata_private.catalogo_eligibility_release_v1()'::regprocedure);
SELECT jsonb_agg(jsonb_build_object('signature',p.oid::regprocedure::text,'source_md5',md5(p.prosrc),'ddl_md5',md5(pg_get_functiondef(p.oid)),
 'owner',pg_get_userbyid(p.proowner),'secdef',p.prosecdef,'config',p.proconfig,'acl',p.proacl::text,'volatility',p.provolatile::text)ORDER BY p.oid::regprocedure::text)
  INTO relation_manifest FROM pg_proc p WHERE p.oid IN('clan_innata_private.eligibility_release_assert()'::regprocedure,'clan_innata_private.catalogo_eligibility_release_v1()'::regprocedure);
 shared_sha:=public.combat_v2_sha256(shared_manifest);private_sha:=public.combat_v2_sha256(private_manifest);
 IF jsonb_array_length(shared_manifest)<>34 OR jsonb_array_length(private_manifest)<>66 OR jsonb_array_length(native_manifest)<>3
 OR jsonb_array_length(changed_headers)<>4 OR jsonb_array_length(relation_manifest)<>2 OR shared_sha<>'8f5350768fd6b922001f0f3ec84631852d36391e9858ef9df5a5c35cc4c9a8f9'OR private_sha<>'76557d4553fdf695dd17c1216a85d5b06b211c52d2d765f6db8be9ac2653da2f'
 OR public.combat_v2_sha256(native_manifest)<>'2d903f7977adb0086633ebe09f6e8b9994bdf2b17218a14ae3a2eac837b6581f'THEN RAISE EXCEPTION 'cure_reaction_post_manifest_drift';END IF;
 IF jsonb_array_length(trigger_manifest)<>6 OR public.combat_v2_sha256(trigger_manifest)<>'cc922634b01cc30d8b050c5b0c5e3c423d81555e7d5bebd200bb51f3589d825a'THEN RAISE EXCEPTION 'palmo_completion_peer6_drift';END IF;
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
 IF aliases<>1 THEN RAISE EXCEPTION 'palmo_completion_alias_count';END IF;
 binding:=$palmo_amendment${"state":"active_amendment","parent_root":"21c3e8e6f9aae4b2dbe9e5169a9f6e2c3bced79e32d251c1ff6eaecf2b2a3c66","schema_version":"cure-command-amendment/1","commit_source_md5":"61532836e90ed32ae807b92ee6632b71","helper_source_md5":"13d099eb15a2759534507b75f85570d7","active_repair_kind":"palmo-completion/1","neutral_source_md5":"0f48477bfc086b98e113e2dd70bba0de","shared_manifest_sha256":"8f5350768fd6b922001f0f3ec84631852d36391e9858ef9df5a5c35cc4c9a8f9","functions_manifest_sha256":"cc922634b01cc30d8b050c5b0c5e3c423d81555e7d5bebd200bb51f3589d825a","normalized_source_identity":{"schema_version":"palmo-completion-peer-amendment/1","parent_root":"21c3e8e6f9aae4b2dbe9e5169a9f6e2c3bced79e32d251c1ff6eaecf2b2a3c66","previous_source_bundle_sha256":"c92d6b79e108e73d6194085bacf0bc6cddb4af74b1661e019ee5516ebc6ba0ce","previous_amendment_identity_sha256":"e00efa15142faaa8c07767231e969224273f43b838e733b9a61d70f1e326bc2b","private_functions_manifest_sha256":"76557d4553fdf695dd17c1216a85d5b06b211c52d2d765f6db8be9ac2653da2f","shared_manifest_sha256":"8f5350768fd6b922001f0f3ec84631852d36391e9858ef9df5a5c35cc4c9a8f9","native_functions_manifest_sha256":"2d903f7977adb0086633ebe09f6e8b9994bdf2b17218a14ae3a2eac837b6581f","publisher_source_md5":"5bc0eeaea3b3b64578105067b4b40c28","qa_state":"NOT_RUN","staff_pass":false,"public_enabled":false},"base_compat_source_bundle_sha256":"654f8fff2f42019ffc4b3ccc6c467fff443ba81f00c7aa020fbd6d7950e2445e","native_functions_manifest_sha256":"2d903f7977adb0086633ebe09f6e8b9994bdf2b17218a14ae3a2eac837b6581f","normalized_source_identity_sha256":"7c24a6b523c5f05714bfd0f085e4963664486b2b064f4dde850e3a09bd66b248","private_functions_manifest_sha256":"76557d4553fdf695dd17c1216a85d5b06b211c52d2d765f6db8be9ac2653da2f","base_catalogo_source_bundle_sha256":"825a1c14a59281fb3168430a993e9f2dbbbc41042f5169638d2e9c1e8e9868a5","base_private_functions_manifest_sha256":"3eb9bba89fc99206710cd079207631f4949dec9893a38d97d7d46e07386b5cc0","previous_cure_command_source_bundle_sha256":"e14b2a7fd1bbe0d0dad34c12d2176bc1347e6860e205f142d9098f4ae3d559dc"}$palmo_amendment$::jsonb;
 binding:=binding||jsonb_build_object('state','active_amendment','source_bundle_sha256',params->'source_bundle_sha256','review',review,
   'availability',(SELECT jsonb_build_object('cure_staff_enabled',c.staff_enabled,'cure_public_enabled',c.public_enabled,
    'paralisi_staff_enabled',g.staff_enabled,'paralisi_public_enabled',g.public_enabled)
    FROM combat_panel_private.cure_gate_v1 c CROSS JOIN combat_v2_genjutsu_internal.gate g WHERE c.singleton AND g.singleton));
 root:=jsonb_set(root,'{db_core,cure_command_amendment}',binding,false);root:=jsonb_set(root,'{config,cure_command_amendment}',binding,false);
 cfg:=root#>'{db_core,catalogo_eligibility_compat}';
 cfg:=cfg||jsonb_build_object('shared_manifest_sha256',shared_sha,'private_functions_manifest_sha256',private_sha,'helper_source_md5','13d099eb15a2759534507b75f85570d7',
  'active_amendment_source_bundle_sha256',binding->'source_bundle_sha256','functions',relation_manifest,'functions_manifest_sha256',public.combat_v2_sha256(relation_manifest));
 root:=jsonb_set(root,'{db_core,catalogo_eligibility_compat}',cfg,false);root:=jsonb_set(root,'{config,catalogo_eligibility_compat}',cfg,false);
 core:=root->'db_core';db_sha:=public.combat_v2_sha256(core-'sha256');core:=jsonb_set(core,'{sha256}',to_jsonb(db_sha),false);root:=jsonb_set(root,'{db_core}',core,false);
 cfg:=root->'config';config_sha:=public.combat_v2_sha256(cfg-'sha256');cfg:=jsonb_set(cfg,'{sha256}',to_jsonb(config_sha),false);root:=jsonb_set(root,'{config}',cfg,false);
 expected_ui:=before_root->'ui';
 IF public.combat_v2_sha256(expected_ui)IS DISTINCT FROM 'cd76714cb188ea3f69189ac5dd793304acdc2179da724aad852f961d12ab3014' THEN RAISE EXCEPTION 'cure_entry_recovery_ui_drift';END IF;
 identity:=jsonb_build_object('schema_version','palmo-completion-code-identity/1','parent_root',old_root_sha,'parent_code_identity',before_root#>'{contract,code_identity_sha256}',
  'normalized_amendment_identity_sha256',binding->'normalized_source_identity_sha256','active_shared_manifest_sha256',shared_sha,
  'active_private_functions_manifest_sha256',private_sha,'native_functions_manifest_sha256',binding->'native_functions_manifest_sha256',
  'source_bundle_sha256',params->'source_bundle_sha256','db_sha256',db_sha,'client_sha256',public.combat_v2_sha256(root->'ui'),'ui_graph_sha256',root#>>'{ui,import_graph_sha256}','amendment_state',binding->'state');
 identity_sha:=public.combat_v2_sha256(identity);root:=jsonb_set(root,'{contract,code_identity_sha256}',to_jsonb(identity_sha),false);
 root:=jsonb_set(root,'{recovery,semantic_identity_sha256}',to_jsonb(identity_sha),false);
 root:=jsonb_set(root,'{recovery,cure_command_amendment}',jsonb_build_object('parent_root',old_root_sha,'state',binding->'state',
  'previous_semantic_identity',before_root#>'{recovery,semantic_identity_sha256}','policy','forward_cure_off_keep_palmo_completion'),false);
 IF root->'ui'IS DISTINCT FROM expected_ui OR root->'edge_bundles'IS DISTINCT FROM before_root->'edge_bundles'
 OR(root->'config')-ARRAY['sha256','cure_command_amendment','catalogo_eligibility_compat']IS DISTINCT FROM(before_root->'config')-ARRAY['sha256','cure_command_amendment','catalogo_eligibility_compat']
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
 IF NOT clan_innata_private.catalogo_eligibility_release_v1()THEN RAISE EXCEPTION 'FIX_ELIGIBILITY_BRANCH_NOT_ADMITTED';END IF;
 PERFORM set_config('app.palmo_completion_result',jsonb_build_object('root_sha256',new_root_sha,'root_bytes',octet_length(root_text),
  'db_sha256',db_sha,'configuration_sha256',config_sha,'code_identity_sha256',identity_sha,'aliases_updated',aliases,
  'amendment_identity_sha256',binding->'normalized_source_identity_sha256','active_shared_manifest_sha256',shared_sha,'active_private_functions_manifest_sha256',private_sha,
  'new_techniques_staff_pass',false,'provider_calls',0)::text,true);
END $catalogo_root$;

COMMIT;
