BEGIN;
SET LOCAL search_path TO pg_catalog,public,extensions;
SET LOCAL lock_timeout='5s';
SET LOCAL statement_timeout='30s';
-- Candidate only. Integrate after independent review with Root recomposition in one transaction.
-- This block inserts only the missing cursor. It never calls publication, progression or provider.
DO $role_opening_recovery$
DECLARE
 sid constant uuid := '44078c5f-7001-4129-9506-e2f34e68c8ac';
 fato constant uuid := '34c34697-768a-493a-b180-1045fcc4ea22';
 publication constant uuid := '3bbc6032-323a-4174-a720-c0779cd69883';
 m public.master_v2_sessions%ROWTYPE;
 r public.mission_run_state%ROWTYPE;
 b mission_generic_owner.board_starts%ROWTYPE;
 q jsonb; inserted_count integer;
BEGIN
 PERFORM public.master_v2_lock_scope(sid);
 SELECT * INTO STRICT m FROM public.master_v2_sessions WHERE id=sid FOR UPDATE;
 SELECT * INTO STRICT r FROM public.mission_run_state WHERE master_session_id=sid FOR UPDATE;
 SELECT * INTO STRICT b FROM mission_generic_owner.board_starts WHERE master_session_id=sid FOR UPDATE;
 PERFORM 1 FROM mission_generic_owner.work_items WHERE master_session_id=sid ORDER BY id FOR UPDATE;
 PERFORM 1 FROM public.mission_run_outbox WHERE master_session_id=sid ORDER BY event_id FOR UPDATE;
 PERFORM 1 FROM public.mission_run_publications WHERE id=publication FOR SHARE;
 PERFORM 1 FROM public.mission_run_messages WHERE publication_id=publication FOR SHARE;
 PERFORM 1 FROM public.messages WHERE id=fato FOR SHARE;
 PERFORM 1 FROM mission_generic_owner.flow_staff_sessions WHERE master_session_id=sid FOR SHARE;
 PERFORM 1 FROM mission_generic_owner.manual_staff_admissions_v1 WHERE master_session_id=sid FOR SHARE;

 IF     (SELECT md5(to_jsonb(t)::text) FROM public.master_v2_sessions t WHERE id='44078c5f-7001-4129-9506-e2f34e68c8ac'::uuid) IS DISTINCT FROM '5ca67539cf541a2de917d3ecbd8c8fae' OR
    (SELECT md5(to_jsonb(t)::text) FROM public.mission_run_state t WHERE master_session_id='44078c5f-7001-4129-9506-e2f34e68c8ac'::uuid) IS DISTINCT FROM '1b79987c06fbcab663ecc2e9b2ea35c9' OR
    (SELECT md5(to_jsonb(t)::text) FROM mission_generic_owner.board_starts t WHERE master_session_id='44078c5f-7001-4129-9506-e2f34e68c8ac'::uuid) IS DISTINCT FROM '3a71cbcc14cc75afed79ba255a1be30a' OR
    (SELECT md5(to_jsonb(t)::text) FROM mission_generic_owner.work_items t WHERE id='245aea9b-ee14-4511-8223-fe1fdeda5ff3'::uuid) IS DISTINCT FROM '1bf1a8077e8c7e983a1493658c48c05c' OR
    (SELECT md5(to_jsonb(t)::text) FROM public.mission_run_publications t WHERE id='3bbc6032-323a-4174-a720-c0779cd69883'::uuid) IS DISTINCT FROM 'ae626d2e4d519a8f13bbe6c604a4f2b5' OR
    (SELECT md5(to_jsonb(t)::text) FROM public.messages t WHERE id='34c34697-768a-493a-b180-1045fcc4ea22'::uuid) IS DISTINCT FROM 'f57155d9297a110a5c8495c854d02cdc'
 THEN RAISE EXCEPTION 'MANUAL_OPENING_RECOVERY_BASELINE_DRIFT' USING ERRCODE='40001'; END IF;
 IF     EXISTS(SELECT 1 FROM mission_generic_owner.role_window_cursors WHERE master_session_id=sid) OR
    EXISTS(SELECT 1 FROM mission_generic_owner.role_submissions WHERE master_session_id=sid) OR
    EXISTS(SELECT 1 FROM mission_generic_owner.unified_batches WHERE master_session_id=sid) OR
    EXISTS(SELECT 1 FROM mission_generic_owner.encounters WHERE master_session_id=sid)
 OR (SELECT count(*) FROM mission_generic_owner.work_items WHERE master_session_id=sid)<>1
 OR (SELECT count(*) FROM public.mission_run_outbox WHERE master_session_id=sid)<>1
 OR (SELECT count(*) FROM public.mission_run_publications WHERE master_session_id=sid)<>1
 THEN RAISE EXCEPTION 'MANUAL_OPENING_RECOVERY_NOT_PRISTINE' USING ERRCODE='40001'; END IF;

 q:=mission_generic_owner.manual_staff_scope_v1(sid);
 IF q IS NULL OR public.combat_v2_sha256(q) IS DISTINCT FROM 'e25a356c70fcb49e7e6261056b7d6ab54ed37caa277756addf2f7681a64fe728'
 OR m.location_id IS DISTINCT FROM '0b85f354-9cdb-47e1-baf9-3d266bb7e06b'::uuid
 OR m.owner_kind IS DISTINCT FROM 'ai_service' OR m.closed_at IS NOT NULL
 OR m.stato IS DISTINCT FROM 'in_corso' OR m.control_version IS DISTINCT FROM 2
 OR r.run_phase IS DISTINCT FROM 'in_corso' OR r.control_version IS DISTINCT FROM 1
 OR r.current_step_key IS DISTINCT FROM 'inizio'
 OR b.simulation IS DISTINCT FROM TRUE OR b.state IS DISTINCT FROM 'published'
 OR b.event_id IS DISTINCT FROM 'c2f4543d-2c39-4e01-a35b-a4ef93be9111'::uuid
 OR r.last_event_id IS DISTINCT FROM b.event_id
 OR NOT EXISTS(SELECT 1 FROM mission_generic_owner.flow_staff_sessions fs WHERE fs.master_session_id=sid AND fs.enabled)
 OR NOT EXISTS(SELECT 1 FROM public.locations l WHERE l.id=m.location_id AND l.is_test)
 OR NOT EXISTS(SELECT 1 FROM mission_generic_owner.work_items w WHERE w.id='245aea9b-ee14-4511-8223-fe1fdeda5ff3'::uuid
   AND w.master_session_id=sid AND w.state='completed' AND w.kind='narration'
   AND w.revision=1 AND w.message_id=fato AND w.authority_receipt_id=b.id
   AND w.receipt_id='4c8def38-0ea6-4b27-bcac-3c6e5d854798'::uuid)
 THEN RAISE EXCEPTION 'MANUAL_OPENING_RECOVERY_SCOPE_DRIFT' USING ERRCODE='40001'; END IF;

 IF NOT EXISTS(SELECT 1 FROM public.mission_run_outbox o
  JOIN public.mission_run_publications p ON p.id=o.publication_id AND p.master_session_id=sid AND p.event_id=b.event_id
  JOIN public.mission_run_messages mm ON mm.publication_id=p.id
  JOIN public.messages msg ON msg.id=mm.message_id
  WHERE o.master_session_id=sid AND o.event_id=b.event_id AND o.state='published'
   AND o.event_version_after=1 AND o.step_key=r.current_step_key AND o.publication_id=publication
   AND p.status='committed' AND p.expected_event_version_after=1 AND p.expected_step_key=r.current_step_key
   AND mm.message_id=fato AND msg.location_id=m.location_id AND msg.kind='fato' AND msg.recipient_user IS NULL
   AND mm.body_sha256=p.body_sha256
   AND p.body_sha256=encode(extensions.digest(convert_to(msg.body,'UTF8'),'sha256'),'hex'))
 OR (SELECT count(*) FROM public.mission_run_messages WHERE publication_id=publication)<>1
 THEN RAISE EXCEPTION 'MANUAL_OPENING_RECOVERY_PUBLICATION_DRIFT' USING ERRCODE='40001'; END IF;

 INSERT INTO mission_generic_owner.role_window_cursors
   (master_session_id,window_epoch,role_revision,opening_fato_id,last_published_fato_id)
 VALUES(sid,1,0,fato,fato);
 GET DIAGNOSTICS inserted_count=ROW_COUNT;
 IF inserted_count<>1 THEN RAISE EXCEPTION 'MANUAL_OPENING_RECOVERY_INSERT_DRIFT'; END IF;
 IF     (SELECT md5(to_jsonb(t)::text) FROM public.master_v2_sessions t WHERE id='44078c5f-7001-4129-9506-e2f34e68c8ac'::uuid) IS DISTINCT FROM '5ca67539cf541a2de917d3ecbd8c8fae' OR
    (SELECT md5(to_jsonb(t)::text) FROM public.mission_run_state t WHERE master_session_id='44078c5f-7001-4129-9506-e2f34e68c8ac'::uuid) IS DISTINCT FROM '1b79987c06fbcab663ecc2e9b2ea35c9' OR
    (SELECT md5(to_jsonb(t)::text) FROM mission_generic_owner.board_starts t WHERE master_session_id='44078c5f-7001-4129-9506-e2f34e68c8ac'::uuid) IS DISTINCT FROM '3a71cbcc14cc75afed79ba255a1be30a' OR
    (SELECT md5(to_jsonb(t)::text) FROM mission_generic_owner.work_items t WHERE id='245aea9b-ee14-4511-8223-fe1fdeda5ff3'::uuid) IS DISTINCT FROM '1bf1a8077e8c7e983a1493658c48c05c' OR
    (SELECT md5(to_jsonb(t)::text) FROM public.mission_run_publications t WHERE id='3bbc6032-323a-4174-a720-c0779cd69883'::uuid) IS DISTINCT FROM 'ae626d2e4d519a8f13bbe6c604a4f2b5' OR
    (SELECT md5(to_jsonb(t)::text) FROM public.messages t WHERE id='34c34697-768a-493a-b180-1045fcc4ea22'::uuid) IS DISTINCT FROM 'f57155d9297a110a5c8495c854d02cdc'
 THEN RAISE EXCEPTION 'MANUAL_OPENING_RECOVERY_CHANGED_HISTORY' USING ERRCODE='40001'; END IF;
 IF NOT EXISTS(SELECT 1 FROM mission_generic_owner.role_window_cursors c
  WHERE c.master_session_id=sid AND c.window_epoch=1 AND c.role_revision=0
  AND c.opening_fato_id=fato AND c.last_published_fato_id=fato)
 THEN RAISE EXCEPTION 'MANUAL_OPENING_RECOVERY_POSTCONDITION'; END IF;
END $role_opening_recovery$;

COMMIT;
