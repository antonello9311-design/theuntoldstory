-- Named data recovery. No restart, new incipit, provider call or JWT impersonation.
BEGIN;
SET LOCAL search_path TO pg_catalog,public,extensions;
SET LOCAL lock_timeout='5s';
SET LOCAL statement_timeout='60s';
DO $literal_recovery$
DECLARE before_state jsonb; after_state jsonb; expected jsonb; before_extra jsonb; after_extra jsonb;
 w mission_generic_owner.work_items; result_row jsonb; message_ref uuid;
 batch_before jsonb; window_before jsonb; cursor_before jsonb; audit_before jsonb; audit_after jsonb;
 q text; rq text; actual_headers jsonb; recorded_headers jsonb;
BEGIN
 IF session_user<>'postgres' OR auth.uid() IS NOT NULL OR coalesce(auth.role(),'')<>''
 THEN RAISE EXCEPTION 'C1266_LITERAL_RECOVERY_AUTH' USING ERRCODE='42501'; END IF;
 PERFORM pg_advisory_xact_lock(hashtextextended('C1266:GENERIC-AI:AVAILABILITY',0));
 PERFORM 1 FROM mission_generic_owner.role_window_cursors WHERE master_session_id='44078c5f-7001-4129-9506-e2f34e68c8ac' FOR UPDATE;
 PERFORM 1 FROM public.master_v2_sessions WHERE id='44078c5f-7001-4129-9506-e2f34e68c8ac' FOR UPDATE;
 SELECT * INTO STRICT w FROM mission_generic_owner.work_items WHERE id='8da0b3ea-3de5-4f1c-9cf9-740b54a33647' AND master_session_id='44078c5f-7001-4129-9506-e2f34e68c8ac' FOR UPDATE;
 -- Idempotent retry returns only the publication already recorded by this recovery.
 IF w.state='completed' THEN
  IF NOT EXISTS(SELECT 1 FROM mission_narrative_internal.dispatch_audit a
    JOIN mission_generic_owner.unified_segment_publications_v4 p ON p.work_id=w.id AND p.message_id=w.message_id
    WHERE a.receipt_id=w.dispatch_receipt_id AND a.event_code='staff_literal_recovery_completed'
      AND a.details->>'work_id'=w.id::text AND a.details->>'message_id'=w.message_id::text
      AND a.details->>'original_result_sha256'='c540de05a0a5b7c5c3760b951b1d278863a5e13ce74c184f61106890e3cd8564')
  THEN RAISE EXCEPTION 'C1266_LITERAL_RECOVERY_COMPLETED_DRIFT'; END IF;
  RETURN;
 END IF;
 PERFORM 1 FROM public.mission_run_state WHERE master_session_id='44078c5f-7001-4129-9506-e2f34e68c8ac' FOR UPDATE;
 PERFORM 1 FROM mission_generic_owner.unified_batches WHERE id='5d54201e-913a-44c8-9d30-7fe776cf63aa' FOR UPDATE;
 PERFORM 1 FROM mission_generic_owner.unified_source_windows WHERE id=(SELECT source_window_id FROM mission_generic_owner.unified_batches WHERE id=w.authority_receipt_id) FOR UPDATE;
 PERFORM 1 FROM mission_narrative_internal.dispatch_receipts WHERE id=w.dispatch_receipt_id FOR SHARE;
 q:='SELECT jsonb_build_object(
''captured_at'',clock_timestamp(),
''writer_extra'',(select jsonb_build_object(''result_sha'',public.combat_v2_sha256(result),''result_raw'',result->>''raw_sha256'',''result_ok'',result->''ok'',''segments_count'',jsonb_array_length(result->''segments''),''finalized_at'',finalized_at) from mission_generic_owner.work_items where id=''8da0b3ea-3de5-4f1c-9cf9-740b54a33647''),
''batch'',(select (to_jsonb(b)-''context''-''payload''-''decision'')||jsonb_build_object(''decision_computed_sha256'',public.combat_v2_sha256(b.decision)) from mission_generic_owner.unified_batches b where id=''5d54201e-913a-44c8-9d30-7fe776cf63aa''),
''root'',(SELECT to_jsonb(r) FROM mission_factory_owner.editor_release_readiness r WHERE singleton),
''headers'',(SELECT jsonb_agg(jsonb_build_object(''signature'',h->>''signature'',''oid'',p.oid::bigint,''owner'',pg_get_userbyid(p.proowner),''acl'',p.proacl::text,''config'',to_jsonb(p.proconfig),''secdef'',p.prosecdef,''volatility'',p.provolatile::text,''language'',l.lanname,''source_md5'',md5(p.prosrc),''ddl_md5'',md5(pg_get_functiondef(p.oid))) ORDER BY h->>''signature'') FROM mission_factory_owner.editor_release_readiness r CROSS JOIN LATERAL jsonb_array_elements(r.canonical_preimage::jsonb#>''{db_core,all_function_headers}'') h LEFT JOIN pg_proc p ON p.oid=to_regprocedure(h->>''signature'') LEFT JOIN pg_language l ON l.oid=p.prolang WHERE singleton),
''g2'',(SELECT to_jsonb(c) FROM mission_factory_owner.c464_control c WHERE singleton),
''admissions'',(SELECT jsonb_agg(to_jsonb(a) ORDER BY actor_user) FROM mission_factory_owner.provider_authoring_admissions a),
''authoring_runtime'',(SELECT to_jsonb(a) FROM mission_factory_owner.provider_authoring_runtime a WHERE singleton),
''runtime_policy'',(SELECT to_jsonb(a) FROM mission_generic_owner.runtime_policy a WHERE singleton),
''provider_policy'',(SELECT to_jsonb(a) FROM mission_generic_owner.provider_policy a WHERE singleton),
''flow_gate'',(SELECT to_jsonb(a) FROM mission_generic_owner.flow_runtime_gate a WHERE singleton),
''session'',(SELECT jsonb_build_object(''id'',id,''stato'',stato,''control_version'',control_version,''mission_id'',mission_id,''created_at'',created_at,''closed_at'',closed_at) FROM public.master_v2_sessions WHERE id=''44078c5f-7001-4129-9506-e2f34e68c8ac''),
''work'',(SELECT jsonb_build_object(''id'',id,''state'',state,''lease_id'',lease_id,''lease_expires_at'',lease_expires_at,''authorization_id'',authorization_id,''dispatch_id'',dispatch_id,''receipt_id'',receipt_id,''message_id'',message_id,''payload_sha256'',payload_sha256,''result_sha256'',result_sha256,''revision'',revision,''event_id'',event_id,''request_key'',request_key,''dispatch_receipt_id'',dispatch_receipt_id) FROM mission_generic_owner.work_items WHERE id=''8da0b3ea-3de5-4f1c-9cf9-740b54a33647''),
''audit'',(SELECT jsonb_agg(jsonb_build_object(''event_code'',event_code,''details_md5'',md5(details::text)) ORDER BY event_code) FROM mission_narrative_internal.dispatch_audit WHERE receipt_id=''9950ebc2-e189-41d8-99ab-66d111f3629f''),
''calls'',(SELECT jsonb_agg(jsonb_build_object(''id'',id,''call_no'',call_no,''state'',state,''sent_at'',sent_at,''settled_at'',settled_at,''reserved_usd'',reserved_usd,''charged_usd'',charged_usd) ORDER BY id) FROM staff_ai_quota_private.calls WHERE scope_id=''44078c5f-7001-4129-9506-e2f34e68c8ac''),
''manual_admission'',(SELECT admission_sha256 FROM mission_generic_owner.manual_staff_admissions_v1 WHERE master_session_id=''44078c5f-7001-4129-9506-e2f34e68c8ac'')
,
''opening_header'',(SELECT jsonb_build_object(''signature'',''mission_generic_owner.opening_published(uuid,uuid)'',''oid'',p.oid::bigint,''owner'',pg_get_userbyid(p.proowner),''acl'',p.proacl::text,''config'',to_jsonb(p.proconfig),''secdef'',p.prosecdef,''volatility'',p.provolatile::text,''language'',l.lanname,''source_md5'',md5(p.prosrc),''ddl_md5'',md5(pg_get_functiondef(p.oid))) FROM pg_proc p JOIN pg_language l ON l.oid=p.prolang WHERE p.oid=''mission_generic_owner.opening_published(uuid,uuid)''::regprocedure),
''cursor'',(SELECT to_jsonb(c) FROM mission_generic_owner.role_window_cursors c WHERE master_session_id=''44078c5f-7001-4129-9506-e2f34e68c8ac''),
''cursor_triggers'',(SELECT coalesce(jsonb_agg(pg_get_triggerdef(t.oid) ORDER BY t.tgname),''[]''::jsonb) FROM pg_trigger t WHERE tgrelid=''mission_generic_owner.role_window_cursors''::regclass AND NOT tgisinternal),
''preserved'',(SELECT jsonb_build_object(
 ''master'',(SELECT md5(to_jsonb(x)::text) FROM public.master_v2_sessions x WHERE id=''44078c5f-7001-4129-9506-e2f34e68c8ac''),
 ''run'',(SELECT md5(to_jsonb(x)::text) FROM public.mission_run_state x WHERE master_session_id=''44078c5f-7001-4129-9506-e2f34e68c8ac''),
 ''board'',(SELECT md5(to_jsonb(x)::text) FROM mission_generic_owner.board_starts x WHERE master_session_id=''44078c5f-7001-4129-9506-e2f34e68c8ac''),
 ''works'',(SELECT jsonb_agg(md5(to_jsonb(x)::text) ORDER BY id) FROM mission_generic_owner.work_items x WHERE master_session_id=''44078c5f-7001-4129-9506-e2f34e68c8ac''),
 ''outbox'',(SELECT jsonb_agg(md5(to_jsonb(x)::text) ORDER BY event_id) FROM public.mission_run_outbox x WHERE master_session_id=''44078c5f-7001-4129-9506-e2f34e68c8ac''),
 ''publications'',(SELECT jsonb_agg(md5(to_jsonb(x)::text) ORDER BY id) FROM public.mission_run_publications x WHERE master_session_id=''44078c5f-7001-4129-9506-e2f34e68c8ac''),
 ''message'',(SELECT md5(to_jsonb(x)::text) FROM public.messages x WHERE id=''34c34697-768a-493a-b180-1045fcc4ea22''),
 ''roles'',(SELECT count(*) FROM mission_generic_owner.role_submissions WHERE master_session_id=''44078c5f-7001-4129-9506-e2f34e68c8ac''),
 ''batches'',(SELECT count(*) FROM mission_generic_owner.unified_batches WHERE master_session_id=''44078c5f-7001-4129-9506-e2f34e68c8ac''),
 ''encounters'',(SELECT count(*) FROM mission_generic_owner.encounters WHERE master_session_id=''44078c5f-7001-4129-9506-e2f34e68c8ac''))),
''protected'',(SELECT protected_projection-''captured_at'' FROM (WITH targets(label,character_id) AS (VALUES (''pg_tamako'',''f335b077-34a1-41c3-94aa-58ec674b649b''::uuid),(''pg_riuji'',''6bceee99-974f-426b-8d92-38b43b4a4267''::uuid)), resources AS (select t.label,c.rank,c.vita,c.vita_max,c.chakra,c.chakra_max,c.exp,c.xp_lifetime,c.money,c.pool_concesso,c.unspent_points,md5(jsonb_build_array(c.taijutsu,c.ninjutsu,c.genjutsu,c.forza,c.velocita,c.mente,c.resistenza,c.fuuinjutsu,c.kekkei_genkai,c.lealta,c.via,c.fama,c.slot_extra)::text) stats_md5,(select count(*) from public.character_inventory x where x.character_id=c.id) inventory_count,(select md5(coalesce(jsonb_agg(jsonb_build_array(x.id,x.item_id,x.quantity,x.created_at) order by x.id),''[]''::jsonb)::text) from public.character_inventory x where x.character_id=c.id) inventory_md5,(select count(*) from public.lesson_progress x where x.user_id=c.user_id) lesson_count,(select md5(coalesce(jsonb_agg(jsonb_build_array(x.id,x.lesson_id,x.completed_at) order by x.id),''[]''::jsonb)::text) from public.lesson_progress x where x.user_id=c.user_id) lesson_md5,(select count(*) from public.character_jutsu x where x.user_id=c.user_id) jutsu_count,(select md5(coalesce(jsonb_agg(jsonb_build_array(x.id,x.jutsu_id,x.source,x.learned_at) order by x.id),''[]''::jsonb)::text) from public.character_jutsu x where x.user_id=c.user_id) jutsu_md5,(select count(*) from public.character_abilities x where x.character_id=c.id) ability_count,(select md5(coalesce(jsonb_agg(jsonb_build_array(x.id,x.technique_id,x.state,x.sessions_done,x.started_at,x.activated_at) order by x.id),''[]''::jsonb)::text) from public.character_abilities x where x.character_id=c.id) ability_md5,(select count(*) from public.character_perks x where x.character_id=c.id) perk_count,(select md5(coalesce(jsonb_agg(jsonb_build_array(x.id,x.tipo,x.dettaglio,x.costo,x.grado_tecnica,x.created_at) order by x.id),''[]''::jsonb)::text) from public.character_perks x where x.character_id=c.id) perk_md5,(select count(*) from public.esame_prove x where x.candidate_user=c.user_id and x.stato=''aperta'') legacy_exam_open,(select count(*) from exam_regia_private.bindings x where x.owner_user=c.user_id and x.state<>''closed'') legacy_binding_open,md5(jsonb_build_array(c.clan,c.element,c.element2,c.cercoterio,c.sigillo)::text) identity_build_md5 from targets t join public.characters c on c.id=t.character_id order by t.label) select jsonb_build_object(''schema_version'',''c1266-protected-projection/1'',''captured_at'',clock_timestamp(),
''pg_count'',count(*),''fields_per_pg'',(select count(*) from jsonb_object_keys((select to_jsonb(x)-''label'' from resources x limit 1))),''protected_field_count'',count(*)*(select count(*) from jsonb_object_keys((select to_jsonb(x)-''label'' from resources x limit 1))),''projection_sha256'',public.combat_v2_sha256(jsonb_agg(to_jsonb(r) order by label))) as protected_projection from resources r) p)
) AS baseline';
 EXECUTE q INTO before_state;
 expected:='{"work":{"id":"8da0b3ea-3de5-4f1c-9cf9-740b54a33647","state":"failed","event_id":"5d54201e-913a-44c8-9d30-7fe776cf63aa","lease_id":"b1850717-f391-4112-98eb-2831d33b0b30","revision":1,"message_id":null,"receipt_id":"fe7b5f7a-264d-438f-bb51-8334d848f3c8","dispatch_id":"160c7668-ad08-4936-a12a-6e2ae3241944","request_key":"074c0b38-bbde-40e9-ad40-cd1d56fb8e5a","result_sha256":"c540de05a0a5b7c5c3760b951b1d278863a5e13ce74c184f61106890e3cd8564","payload_sha256":"3a3c7ff74551e3f8dec6b63b879b857ab33837aef2603306b2ebdbfd322bac87","authorization_id":"caeecc6d-cfcf-4ae6-a5f3-b27ec51c1057","lease_expires_at":"2026-10-22T11:06:49.815681+00:00","dispatch_receipt_id":"9950ebc2-e189-41d8-99ab-66d111f3629f"},"audit":[{"event_code":"c1266_async_owner_v1","details_md5":"1273e2efae84f8ca747f63dd0df27870"},{"event_code":"c8_count_started","details_md5":"d8b77423a6918f32d83b878519f2f6e7"},{"event_code":"c8_count_success","details_md5":"3ca7a320695a265fe68de70e48f4ffe0"},{"event_code":"generic_finalized","details_md5":"af18cc795a9d2dd3b16e067d9adca9c0"},{"event_code":"provider_started","details_md5":"99914b932bd37a50b983c5e7c90ae93b"}],"batch":{"id":"5d54201e-913a-44c8-9d30-7fe776cf63aa","route":null,"state":"ready","pg_team":null,"step_key":"inizio","created_at":"2026-10-22T11:00:39.91738+00:00","entry_side":null,"message_id":null,"encounter_id":null,"published_at":null,"encounter_key":null,"next_round_id":null,"payload_sha256":"3a3c7ff74551e3f8dec6b63b879b857ab33837aef2603306b2ebdbfd322bac87","writer_work_id":"8da0b3ea-3de5-4f1c-9cf9-740b54a33647","decision_sha256":"f1d580d210b4a7d160ff89e04150e6867ce09c1fa32c86b4eb2b737f5186b750","source_round_id":null,"composition_kind":"narrative_continuation","decision_work_id":"f470a88c-3e64-41be-9a1c-a9e627faef9c","source_report_id":null,"source_window_id":"f470a88c-3e64-41be-9a1c-a9e627faef9c","master_session_id":"44078c5f-7001-4129-9506-e2f34e68c8ac","run_control_version":1,"secondary_report_id":null,"selected_actor_keys":[],"decision_computed_sha256":"f1d580d210b4a7d160ff89e04150e6867ce09c1fa32c86b4eb2b737f5186b750"},"calls":[{"id":"3dd15b3b-74e1-402b-b3bd-4b4b92f267f1","state":"unknown_billable","call_no":2,"sent_at":"2026-10-22T10:59:09.21937+00:00","settled_at":null,"charged_usd":null,"reserved_usd":0.0124},{"id":"7ed9ae1d-e1fe-4c4a-be84-1bef7de875c3","state":"unknown_billable","call_no":2,"sent_at":"2026-10-21T15:58:58.546104+00:00","settled_at":null,"charged_usd":null,"reserved_usd":0.0124},{"id":"87354550-971b-401c-a84c-d703fc6228cc","state":"settled","call_no":1,"sent_at":"2026-10-22T11:00:54.173253+00:00","settled_at":"2026-10-22T11:02:06.185623+00:00","charged_usd":0.0039338,"reserved_usd":0.0124},{"id":"ac2441a7-cfc4-4e38-8b20-38615917912a","state":"unknown_billable","call_no":2,"sent_at":"2026-10-22T11:00:50.82397+00:00","settled_at":null,"charged_usd":null,"reserved_usd":0.0124},{"id":"b966cf30-50ed-434c-b647-706c31ff8ea1","state":"settled","call_no":1,"sent_at":"2026-10-21T16:36:20.389944+00:00","settled_at":"2026-10-21T16:36:34.145084+00:00","charged_usd":0.0009667,"reserved_usd":0.0124},{"id":"e1d20c64-377f-4595-a5e7-605b6b19b4e5","state":"settled","call_no":1,"sent_at":"2026-10-22T10:59:14.492274+00:00","settled_at":"2026-10-22T11:00:40.013042+00:00","charged_usd":0.0062801,"reserved_usd":0.0124}],"cursor":{"updated_at":"2026-10-22T10:59:02.81569+00:00","window_epoch":1,"role_revision":2,"opening_fato_id":"34c34697-768a-493a-b180-1045fcc4ea22","master_session_id":"44078c5f-7001-4129-9506-e2f34e68c8ac","last_published_fato_id":"34c34697-768a-493a-b180-1045fcc4ea22"},"session":{"id":"44078c5f-7001-4129-9506-e2f34e68c8ac","stato":"in_corso","closed_at":null,"created_at":"2026-10-21T15:58:52.641123+00:00","mission_id":"9056909c-466c-4ec7-aee3-1bbb54c4c597","control_version":2},"flow_gate":{"singleton":true,"public_enabled":false},"preserved":{"run":"1b79987c06fbcab663ecc2e9b2ea35c9","board":"3a71cbcc14cc75afed79ba255a1be30a","roles":2,"works":["1bf1a8077e8c7e983a1493658c48c05c","30a239de099a427f506c341801549ba7","6820220fc9896ce844318c9289ce33be"],"master":"5ca67539cf541a2de917d3ecbd8c8fae","outbox":["c7bc703cb6b9a22b933173ed81d7e0b4"],"batches":1,"message":"f57155d9297a110a5c8495c854d02cdc","encounters":0,"publications":["ae626d2e4d519a8f13bbe6c604a4f2b5"]},"protected":{"pg_count":2,"fields_per_pg":24,"schema_version":"c1266-protected-projection/1","projection_sha256":"d72929c381929cd4ba05a777ba416a584bd9999a97cc4b10a9a65d5ad44d7383","protected_field_count":48},"writer_extra":{"result_ok":true,"result_raw":"5bb644e1e59217756c11d28879d7309ceafaa04d76b60afe7e3a0e10f8aa2ee9","result_sha":"514156423647274196abccda69d8f7ac94fee2a949d026526d50027f3f6aba03","finalized_at":"2026-10-22T11:02:06.188912+00:00","segments_count":1},"opening_header":{"acl":"{postgres=X/postgres}","oid":50310,"owner":"postgres","config":["search_path=\"\""],"secdef":true,"ddl_md5":"b80e800872818bf4a92a55b603cfbef3","language":"plpgsql","signature":"mission_generic_owner.opening_published(uuid,uuid)","source_md5":"564a839826790256aaa4d9e62f26ab47","volatility":"v"},"runtime_policy":{"mode":"test","singleton":true,"provider_max_calls":14,"provider_max_cost_usd":0.156688},"cursor_triggers":["CREATE TRIGGER trg_role_supersede_unstarted_v4 AFTER UPDATE OF role_revision ON mission_generic_owner.role_window_cursors FOR EACH ROW EXECUTE FUNCTION mission_generic_owner.role_supersede_unstarted_v4()"],"provider_policy":{"enabled":true,"singleton":true,"max_run_calls":14,"run_budget_usd":0.732032,"max_daily_calls":14,"daily_budget_usd":0.732032,"max_global_calls":41,"global_budget_usd":0.8194225,"editor_reserve_bytes":4096,"input_capacity_bytes":49152},"manual_admission":"e25a356c70fcb49e7e6261056b7d6ab54ed37caa277756addf2f7681a64fe728","authoring_runtime":{"enabled":false,"qualified":true,"singleton":true,"edge_qualified":true,"release_sha256":"06c87c0d0e107c0c7bc9c56e916c0e15f221801babf0badb7739ddde6804b5b6","count_upper_cost_usd":0.0124,"count_qualification_sha256":"d8da6486b29f5e6b57272eb9d21660518cdcb57f12ed69209e12f32c37e2d5c0"}}'::jsonb;
 IF before_state-ARRAY['captured_at','root','headers','g2','admissions']::text[] IS DISTINCT FROM expected-ARRAY['captured_at','root','headers','g2','admissions']::text[] THEN RAISE EXCEPTION 'C1266_LITERAL_RECOVERY_BASELINE_DRIFT' USING ERRCODE='40001'; END IF;
 IF before_state#>>'{root,revision_sha256}' IS DISTINCT FROM before_state#>>'{root,observed_revision_sha256}'
 OR before_state#>>'{root,revision_sha256}' IS DISTINCT FROM encode(extensions.digest(convert_to(before_state#>>'{root,canonical_preimage}','UTF8'),'sha256'),'hex')
 OR (before_state#>>'{root,canonical_preimage}')::jsonb#>>'{config,literal_repetition_recovery,source,sha256}' IS DISTINCT FROM '898671263f78df803354a76fd3f12538350c16ada100e3abf7aabd6830a8bd4c'
 THEN RAISE EXCEPTION 'C1266_LITERAL_RECOVERY_ROOT' USING ERRCODE='40001'; END IF;
 SELECT jsonb_agg(h ORDER BY h->>'signature') INTO recorded_headers
 FROM jsonb_array_elements((before_state#>>'{root,canonical_preimage}')::jsonb#>'{db_core,all_function_headers}') h;
 IF before_state->'headers' IS DISTINCT FROM recorded_headers THEN RAISE EXCEPTION 'C1266_LITERAL_RECOVERY_HEADERS' USING ERRCODE='40001'; END IF;
 SELECT to_jsonb(x) INTO STRICT batch_before FROM mission_generic_owner.unified_batches x WHERE id=w.authority_receipt_id;
 SELECT to_jsonb(x) INTO STRICT window_before FROM mission_generic_owner.unified_source_windows x WHERE id=(batch_before->>'source_window_id')::uuid;
 SELECT to_jsonb(x) INTO STRICT cursor_before FROM mission_generic_owner.role_window_cursors x WHERE master_session_id=w.master_session_id;
 SELECT coalesce(jsonb_agg(to_jsonb(x) ORDER BY id),'[]'::jsonb) INTO audit_before
 FROM mission_narrative_internal.dispatch_audit x WHERE receipt_id=w.dispatch_receipt_id;
 rq:='SELECT jsonb_build_object(
 ''other_works'',(SELECT jsonb_agg(md5(to_jsonb(x)::text) ORDER BY id) FROM mission_generic_owner.work_items x WHERE master_session_id=''44078c5f-7001-4129-9506-e2f34e68c8ac'' AND id<>''8da0b3ea-3de5-4f1c-9cf9-740b54a33647''),
 ''roles'',(SELECT jsonb_agg(md5(to_jsonb(x)::text) ORDER BY message_id) FROM mission_generic_owner.role_submissions x WHERE master_session_id=''44078c5f-7001-4129-9506-e2f34e68c8ac''),
 ''dispatch'',(SELECT jsonb_agg(md5(to_jsonb(x)::text) ORDER BY id) FROM mission_narrative_internal.dispatch_receipts x WHERE master_session_id=''44078c5f-7001-4129-9506-e2f34e68c8ac''),
 ''attempts'',(SELECT jsonb_agg(md5(to_jsonb(x)::text) ORDER BY x.id) FROM mission_narrative_internal.dispatch_attempts x JOIN mission_narrative_internal.dispatch_receipts dr ON dr.id=x.receipt_id WHERE dr.master_session_id=''44078c5f-7001-4129-9506-e2f34e68c8ac''),
 ''authorizations'',(SELECT jsonb_agg(md5(to_jsonb(x)::text) ORDER BY x.id) FROM mission_narrative_internal.provider_authorizations x JOIN mission_narrative_internal.dispatch_receipts dr ON dr.id=x.receipt_id WHERE dr.master_session_id=''44078c5f-7001-4129-9506-e2f34e68c8ac''),
 ''messages'',(SELECT coalesce(jsonb_agg(md5(to_jsonb(x)::text) ORDER BY x.id),''[]''::jsonb) FROM public.messages x WHERE x.location_id=''0b85f354-9cdb-47e1-baf9-3d266bb7e06b'' AND x.id IS DISTINCT FROM $1),
 ''pubs'',(SELECT coalesce(jsonb_agg(md5(to_jsonb(x)::text) ORDER BY x.work_id),''[]''::jsonb) FROM mission_generic_owner.unified_segment_publications_v4 x JOIN mission_generic_owner.work_items w ON w.id=x.work_id WHERE w.master_session_id=''44078c5f-7001-4129-9506-e2f34e68c8ac'' AND x.work_id<>''8da0b3ea-3de5-4f1c-9cf9-740b54a33647'')
)'; EXECUTE rq INTO before_extra USING NULL::uuid;
 result_row:=mission_generic_owner.unified_publish_v4(w.id,w.result,w.request_key,w.result_sha256);
 message_ref:=(result_row->>'message_id')::uuid;
 IF message_ref IS NULL THEN RAISE EXCEPTION 'C1266_LITERAL_RECOVERY_PUBLICATION_MISSING'; END IF;
 EXECUTE rq INTO after_extra USING message_ref;
 IF before_extra IS DISTINCT FROM after_extra THEN RAISE EXCEPTION 'C1266_LITERAL_RECOVERY_UNEXPECTED_EFFECT'; END IF;
 EXECUTE q INTO after_state;
 IF (before_state-ARRAY['captured_at','work','writer_extra','audit','batch','cursor','preserved']::text[])
 IS DISTINCT FROM (after_state-ARRAY['captured_at','work','writer_extra','audit','batch','cursor','preserved']::text[])
 OR ((before_state->'preserved')-'works') IS DISTINCT FROM ((after_state->'preserved')-'works')
 THEN RAISE EXCEPTION 'C1266_LITERAL_RECOVERY_PROTECTED_OR_HISTORY_CHANGED'; END IF;
 SELECT coalesce(jsonb_agg(to_jsonb(x) ORDER BY id),'[]'::jsonb) INTO audit_after
 FROM mission_narrative_internal.dispatch_audit x WHERE receipt_id=w.dispatch_receipt_id
   AND event_code<>'staff_literal_recovery_completed';
 IF audit_before IS DISTINCT FROM audit_after THEN RAISE EXCEPTION 'C1266_LITERAL_RECOVERY_ORIGINAL_AUDIT_CHANGED'; END IF;
 IF (SELECT count(*) FROM mission_narrative_internal.dispatch_audit WHERE receipt_id=w.dispatch_receipt_id AND event_code='staff_literal_recovery_completed')<>1
 OR NOT EXISTS(SELECT 1 FROM mission_narrative_internal.dispatch_audit a WHERE a.receipt_id=w.dispatch_receipt_id
   AND a.event_code='staff_literal_recovery_completed' AND a.details->'original_result' IS NOT DISTINCT FROM w.result
   AND a.details->>'original_result_sha256'=w.result_sha256 AND a.details->>'message_id'=message_ref::text)
 THEN RAISE EXCEPTION 'C1266_LITERAL_RECOVERY_ORIGINAL_RESULT'; END IF;
 IF NOT EXISTS(SELECT 1 FROM mission_generic_owner.work_items x WHERE x.id=w.id
   AND x.state='completed' AND x.message_id=message_ref
   AND x.finalized_at IS NOT DISTINCT FROM w.finalized_at
   AND (to_jsonb(x)-ARRAY['state','message_id','result','result_sha256']::text[])
     IS NOT DISTINCT FROM (to_jsonb(w)-ARRAY['state','message_id','result','result_sha256']::text[])
   AND x.result IS NOT DISTINCT FROM w.result||jsonb_build_object('text',result_row->>'text','continuity',result_row->'continuity')
   AND x.result_sha256=public.combat_v2_sha256(x.result))
 THEN RAISE EXCEPTION 'C1266_LITERAL_RECOVERY_WORK_POST'; END IF;
 IF NOT EXISTS(SELECT 1 FROM mission_generic_owner.unified_batches x WHERE x.id=w.authority_receipt_id
   AND x.state='published' AND x.message_id=message_ref AND x.published_at IS NOT NULL
   AND (to_jsonb(x)-ARRAY['state','message_id','published_at']::text[])
     IS NOT DISTINCT FROM (batch_before-ARRAY['state','message_id','published_at']::text[]))
 OR NOT EXISTS(SELECT 1 FROM mission_generic_owner.unified_source_windows x WHERE x.id=(window_before->>'id')::uuid
   AND x.consumed_message_id=message_ref AND (to_jsonb(x)-'consumed_message_id') IS NOT DISTINCT FROM (window_before-'consumed_message_id'))
 OR NOT EXISTS(SELECT 1 FROM mission_generic_owner.role_window_cursors x WHERE x.master_session_id=w.master_session_id
   AND x.window_epoch=2 AND x.role_revision=0 AND x.last_published_fato_id=message_ref
   AND (to_jsonb(x)-ARRAY['window_epoch','role_revision','last_published_fato_id','updated_at']::text[])
     IS NOT DISTINCT FROM (cursor_before-ARRAY['window_epoch','role_revision','last_published_fato_id','updated_at']::text[]))
 THEN RAISE EXCEPTION 'C1266_LITERAL_RECOVERY_CURSOR_BATCH_POST'; END IF;
 IF (SELECT count(*) FROM mission_generic_owner.unified_segment_publications_v4 WHERE work_id=w.id)<>1
 OR NOT EXISTS(SELECT 1 FROM mission_generic_owner.unified_segment_publications_v4 p
    JOIN public.messages m ON m.id=p.message_id
    WHERE p.work_id=w.id AND p.batch_id=w.authority_receipt_id AND p.message_id=message_ref
     AND p.raw_result_sha256=w.result_sha256 AND p.segments_sha256=public.combat_v2_sha256(w.result->'segments')
     AND p.final_text_sha256=encode(extensions.digest(convert_to(m.body,'UTF8'),'sha256'),'hex')
     AND m.kind='fato' AND m.sender_user IS NULL AND m.recipient_user IS NULL AND m.character_id IS NULL
     AND m.location_id='0b85f354-9cdb-47e1-baf9-3d266bb7e06b' AND m.body=result_row->>'text')
 THEN RAISE EXCEPTION 'C1266_LITERAL_RECOVERY_PUBLICATION_POST'; END IF;
END $literal_recovery$;
COMMIT;
