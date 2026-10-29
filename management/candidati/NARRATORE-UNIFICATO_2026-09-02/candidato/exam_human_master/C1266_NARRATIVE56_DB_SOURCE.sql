BEGIN;
DO $$
BEGIN
 IF (SELECT revision_sha256 FROM mission_factory_owner.editor_release_readiness WHERE singleton) IS DISTINCT FROM
  'a9e35776c3c35cfbbab884e5b5cd01355370bbf8c716e7faf2af79ac85adb8b7' THEN RAISE EXCEPTION 'N56_ROOT_BASELINE_DRIFT';END IF;
 IF to_regclass('mission_narrative_internal.scene_runtime_v1') IS NOT NULL OR to_regclass('mission_narrative_internal.scene_sources_v1') IS NOT NULL
 THEN RAISE EXCEPTION 'N56_SCHEMA_ALREADY_PRESENT_RECONCILE';END IF;
 IF (SELECT md5(prosrc) FROM pg_proc WHERE oid=to_regprocedure('mission_generic_owner.enqueue_opening(uuid,uuid)')) IS DISTINCT FROM 'e9aee3094a4d6a8fb78bfe430aab0f4f' THEN RAISE EXCEPTION 'N56_SOURCE_DRIFT: mission_generic_owner.enqueue_opening(uuid,uuid)';END IF;
 IF (SELECT md5(prosrc) FROM pg_proc WHERE oid=to_regprocedure('mission_generic_owner.combat_narrative_source(uuid,uuid)')) IS DISTINCT FROM '670e15713ca24a0d604f5637779f0d2d' THEN RAISE EXCEPTION 'N56_SOURCE_DRIFT: mission_generic_owner.combat_narrative_source(uuid,uuid)';END IF;
 IF (SELECT md5(prosrc) FROM pg_proc WHERE oid=to_regprocedure('public.trg_role_autojoin()')) IS DISTINCT FROM '929c414c2e4fe75f3c70c8b0c8f57c1d' THEN RAISE EXCEPTION 'N56_SOURCE_DRIFT: public.trg_role_autojoin()';END IF;
 IF (SELECT md5(prosrc) FROM pg_proc WHERE oid=to_regprocedure('exam_human_private.narrative_message_guard_v1()')) IS DISTINCT FROM '3b40878296ad66ed9e0824f84ac4bd41' THEN RAISE EXCEPTION 'N56_SOURCE_DRIFT: exam_human_private.narrative_message_guard_v1()';END IF;
 IF (SELECT md5(prosrc) FROM pg_proc WHERE oid=to_regprocedure('mission_generic_owner.role_dispatch_assert_v4(uuid)')) IS DISTINCT FROM 'bec2f274babec7ba8cbaf4df02557b6e' THEN RAISE EXCEPTION 'N56_SOURCE_DRIFT: mission_generic_owner.role_dispatch_assert_v4(uuid)';END IF;
 IF (SELECT md5(prosrc) FROM pg_proc WHERE oid=to_regprocedure('public.mission_generic_room_state_v1(uuid)')) IS DISTINCT FROM 'b6e3cb5bd91dadb64de7d87defbbd107' THEN RAISE EXCEPTION 'N56_SOURCE_DRIFT: public.mission_generic_room_state_v1(uuid)';END IF;
 IF (SELECT md5(prosrc) FROM pg_proc WHERE oid=to_regprocedure('mission_generic_owner.opening_published(uuid,uuid)')) IS DISTINCT FROM '564a839826790256aaa4d9e62f26ab47' THEN RAISE EXCEPTION 'N56_SOURCE_DRIFT: mission_generic_owner.opening_published(uuid,uuid)';END IF;
 IF (SELECT md5(prosrc) FROM pg_proc WHERE oid=to_regprocedure('mission_generic_owner.progress_step(uuid,uuid,uuid)')) IS DISTINCT FROM '3cba812e6ee4964a7502d228ec7ef606' THEN RAISE EXCEPTION 'N56_SOURCE_DRIFT: mission_generic_owner.progress_step(uuid,uuid,uuid)';END IF;
 IF (SELECT md5(prosrc) FROM pg_proc WHERE oid=to_regprocedure('mission_generic_owner.work_assert(mission_generic_owner.work_items)')) IS DISTINCT FROM '707dbdf70e0d46a0ed615741452f3213' THEN RAISE EXCEPTION 'N56_SOURCE_DRIFT: mission_generic_owner.work_assert(mission_generic_owner.work_items)';END IF;
 IF (SELECT md5(prosrc) FROM pg_proc WHERE oid=to_regprocedure('mission_public_owner.enqueue_combat_unified_v1(uuid,uuid,uuid)')) IS DISTINCT FROM 'd49b6d2842d881a1e31e1c37eb3a5aef' THEN RAISE EXCEPTION 'N56_SOURCE_DRIFT: mission_public_owner.enqueue_combat_unified_v1(uuid,uuid,uuid)';END IF;
 IF (SELECT md5(prosrc) FROM pg_proc WHERE oid=to_regprocedure('mission_public_owner.role_capture_scope_v1(uuid)')) IS DISTINCT FROM '4cc7a57d01e1db9f59cbd47aa8e0c646' THEN RAISE EXCEPTION 'N56_SOURCE_DRIFT: mission_public_owner.role_capture_scope_v1(uuid)';END IF;
 IF (SELECT md5(prosrc) FROM pg_proc WHERE oid=to_regprocedure('public.mission_role_submit_v1(uuid,uuid,text)')) IS DISTINCT FROM 'c0ac73ec6efcfcf9ad1e05bf63ebe07f' THEN RAISE EXCEPTION 'N56_SOURCE_DRIFT: public.mission_role_submit_v1(uuid,uuid,text)';END IF;
 IF (SELECT md5(prosrc) FROM pg_proc WHERE oid=to_regprocedure('mission_public_owner.work_contract_issue_v1(uuid)')) IS DISTINCT FROM '96cc578850da9a7123fd8492c75602a0' THEN RAISE EXCEPTION 'N56_SOURCE_DRIFT: mission_public_owner.work_contract_issue_v1(uuid)';END IF;
 IF (SELECT md5(prosrc) FROM pg_proc WHERE oid=to_regprocedure('public.mission_generic_dispatch_finalize_v1(uuid,text,text,text)')) IS DISTINCT FROM '47b8efb9717984f70f20ec3022d049a8' THEN RAISE EXCEPTION 'N56_SOURCE_DRIFT: public.mission_generic_dispatch_finalize_v1(uuid,text,text,text)';END IF;
 IF (SELECT md5(prosrc) FROM pg_proc WHERE oid=to_regprocedure('public.mission_generic_event_next_v1(uuid,bigint,uuid)')) IS DISTINCT FROM '2defe7b34abadd38005fe432195fc995' THEN RAISE EXCEPTION 'N56_SOURCE_DRIFT: public.mission_generic_event_next_v1(uuid,bigint,uuid)';END IF;
 IF (SELECT md5(prosrc) FROM pg_proc WHERE oid=to_regprocedure('mission_generic_owner.event_capture_v1()')) IS DISTINCT FROM '55c32514629ce5f56d9faf742253665b' THEN RAISE EXCEPTION 'N56_SOURCE_DRIFT: mission_generic_owner.event_capture_v1()';END IF;
 IF (SELECT md5(prosrc) FROM pg_proc WHERE oid=to_regprocedure('mission_generic_owner.staff_finish_status_v1(uuid,uuid)')) IS DISTINCT FROM '496ff7c942af614e5f44dec8fad8faaf' THEN RAISE EXCEPTION 'N56_SOURCE_DRIFT: mission_generic_owner.staff_finish_status_v1(uuid,uuid)';END IF;
 IF (SELECT md5(prosrc) FROM pg_proc WHERE oid=to_regprocedure('public.mission_generic_staff_finish_v1(uuid,uuid,text,uuid,uuid)')) IS DISTINCT FROM '35c8a9509c2ab85d9180461b791da6f0' THEN RAISE EXCEPTION 'N56_SOURCE_DRIFT: public.mission_generic_staff_finish_v1(uuid,uuid,text,uuid,uuid)';END IF;
 IF (SELECT md5(prosrc) FROM pg_proc WHERE oid=to_regprocedure('mission_generic_owner.finish_scope(uuid,uuid,text)')) IS DISTINCT FROM 'd1504d8571091ab195d849d7603aded6' THEN RAISE EXCEPTION 'N56_SOURCE_DRIFT: mission_generic_owner.finish_scope(uuid,uuid,text)';END IF;
 IF (SELECT md5(prosrc) FROM pg_proc WHERE oid=to_regprocedure('mission_generic_owner.combat_publish(uuid,text,uuid)')) IS DISTINCT FROM '7c81e1badee7486352ea879b2086ac06' THEN RAISE EXCEPTION 'N56_SOURCE_DRIFT: mission_generic_owner.combat_publish(uuid,text,uuid)';END IF;
END $$;
CREATE TABLE mission_narrative_internal.scene_runtime_v1 (id uuid PRIMARY KEY DEFAULT gen_random_uuid(), master_session_id uuid NOT NULL UNIQUE REFERENCES public.master_v2_sessions (id), is_active boolean NOT NULL DEFAULT TRUE, snapshot jsonb NOT NULL CHECK (jsonb_typeof(snapshot) = 'object'), snapshot_sha256 text NOT NULL CHECK (snapshot_sha256 ~ '^[a-f0-9]{64}$'), state_version bigint NOT NULL DEFAULT 0 CHECK (state_version >= 0), current_phase_key text NOT NULL, mode text NOT NULL DEFAULT 'narrative' CHECK (mode IN ('narrative', 'combat_pending', 'combat', 'closed')), arena_by_phase jsonb NOT NULL DEFAULT CAST('{}' AS jsonb) CHECK (jsonb_typeof(arena_by_phase) = 'object'), arena_receipt jsonb, arena_phase_key text, arena_receipt_sha256 text CHECK (arena_receipt_sha256 ~ '^[a-f0-9]{64}$'), encounter_key text, turn_owner text NOT NULL DEFAULT 'players' CHECK (turn_owner IN ('players', 'fato', 'combat', 'closed')), scene_memory jsonb CHECK (scene_memory IS NULL OR jsonb_typeof(scene_memory) = 'object'), last_publication_id uuid REFERENCES public.messages (id) ON DELETE SET NULL, last_publication_sha256 text CHECK (last_publication_sha256 ~ '^[a-f0-9]{64}$'), last_fati jsonb NOT NULL DEFAULT CAST('[]' AS jsonb) CHECK (jsonb_typeof(last_fati) = 'array'), origin_failed_director_id uuid REFERENCES mission_generic_owner.work_items (id), created_at timestamptz NOT NULL DEFAULT clock_timestamp(), updated_at timestamptz NOT NULL DEFAULT clock_timestamp());
CREATE TABLE mission_narrative_internal.scene_sources_v1 (id uuid PRIMARY KEY, scene_id uuid NOT NULL REFERENCES mission_narrative_internal.scene_runtime_v1 (id), request_kind text NOT NULL DEFAULT 'narration' CHECK (request_kind IN ('narration', 'initial_opening', 'combat_entry')), board_start_receipt_id uuid REFERENCES mission_generic_owner.board_starts (id), work_id uuid UNIQUE REFERENCES mission_generic_owner.work_items (id) DEFERRABLE INITIALLY DEFERRED, actor_user_id uuid NOT NULL REFERENCES public.profiles (id), state_version bigint NOT NULL CHECK (state_version >= 0), source_revision text NOT NULL CHECK (source_revision ~ '^[a-f0-9]{64}$'), snapshot_sha256 text NOT NULL CHECK (snapshot_sha256 ~ '^[a-f0-9]{64}$'), accepted_role_ids uuid[] NOT NULL, accepted_roles_sha256 text NOT NULL CHECK (accepted_roles_sha256 ~ '^[a-f0-9]{64}$'), last_publication_id uuid, last_publication_sha256 text CHECK (last_publication_sha256 ~ '^[a-f0-9]{64}$'), current_phase_key text NOT NULL, scene_memory_sha256 text NOT NULL CHECK (scene_memory_sha256 ~ '^[a-f0-9]{64}$'), payload_sha256 text NOT NULL CHECK (payload_sha256 ~ '^[a-f0-9]{64}$'), published_message_id uuid, publication_next_step text, technical_request jsonb, technical_receipt jsonb, message_permit_id uuid, message_permit_sha256 text CHECK (message_permit_sha256 ~ '^[a-f0-9]{64}$'), message_permit_txid bigint, message_permit_backend integer, CHECK ((request_kind = 'narration' AND work_id IS NOT NULL AND cardinality(accepted_role_ids) > 0 AND technical_request IS NULL AND board_start_receipt_id IS NULL) OR (request_kind = 'initial_opening' AND work_id IS NOT NULL AND cardinality(accepted_role_ids) = 0 AND technical_request IS NULL AND board_start_receipt_id IS NOT NULL) OR (request_kind = 'combat_entry' AND work_id IS NULL AND cardinality(accepted_role_ids) = 0 AND jsonb_typeof(technical_request) = 'object')), retired_at timestamptz, retired_reason text, created_at timestamptz NOT NULL DEFAULT clock_timestamp(), UNIQUE (scene_id, state_version, source_revision));
CREATE UNIQUE INDEX scene56_one_pending_source ON mission_narrative_internal.scene_sources_v1 (scene_id) WHERE published_message_id IS NULL AND technical_receipt IS NULL AND retired_at IS NULL;
ALTER TABLE mission_narrative_internal.scene_runtime_v1 ENABLE ROW LEVEL SECURITY ;
ALTER TABLE mission_narrative_internal.scene_sources_v1 ENABLE ROW LEVEL SECURITY ;
REVOKE ALL PRIVILEGES ON TABLE mission_narrative_internal.scene_runtime_v1, mission_narrative_internal.scene_sources_v1 FROM PUBLIC, anon, authenticated, service_role;
CREATE OR REPLACE FUNCTION mission_narrative_internal.scene_source_assert_v1(p_work uuid) RETURNS jsonb LANGUAGE plpgsql SECURITY DEFINER SET search_path TO '' AS $$
DECLARE w mission_generic_owner.work_items; s mission_narrative_internal.scene_sources_v1;
 r mission_narrative_internal.scene_runtime_v1; role_body jsonb; src jsonb;
BEGIN
 PERFORM mission_ai_board_owner.service_only();
 SELECT * INTO STRICT w FROM mission_generic_owner.work_items WHERE id=p_work;
 IF NOT EXISTS(SELECT 1 FROM mission_factory_owner.editor_release_readiness root56 WHERE root56.singleton AND root56.state='enabled' AND root56.scope='staff' AND root56.revision_sha256=root56.observed_revision_sha256 AND root56.canonical_preimage::jsonb#>'{config,c1266_narrative_scene}'='{"schema_version":"mission-narrative-scene-policy/1","enabled":true,"scope":"staff"}'::jsonb) THEN RAISE EXCEPTION 'SCENE56_DISABLED' USING ERRCODE='42501';END IF;
 IF w.kind<>'narration' OR w.payload->>'schema_version'<>'mission-narrative-scene/1'
  OR w.payload->>'mode'<>'narrative_scene' THEN RAISE EXCEPTION 'SCENE56_WORK_TYPE' USING ERRCODE='22023';END IF;
 PERFORM mission_generic_owner.work_assert(w);
 SELECT * INTO STRICT s FROM mission_narrative_internal.scene_sources_v1 WHERE work_id=w.id;
 SELECT * INTO STRICT r FROM mission_narrative_internal.scene_runtime_v1 WHERE id=s.scene_id;
 IF NOT r.is_active OR r.mode<>'narrative' OR r.master_session_id<>w.master_session_id
  OR r.state_version<>s.state_version OR r.current_phase_key<>s.current_phase_key
  OR r.snapshot_sha256<>s.snapshot_sha256 OR public.combat_v2_sha256(r.snapshot)<>r.snapshot_sha256
  OR r.last_publication_id IS DISTINCT FROM s.last_publication_id
  OR r.last_publication_sha256 IS DISTINCT FROM s.last_publication_sha256
  OR public.combat_v2_sha256(coalesce(r.scene_memory,'null'::jsonb))<>s.scene_memory_sha256
  OR s.retired_at IS NOT NULL OR s.published_message_id IS NOT NULL
  OR s.id<>w.authority_receipt_id OR s.payload_sha256<>w.payload_sha256
  OR w.payload_sha256<>public.combat_v2_sha256(w.payload)
  OR w.payload->>'source_window_id'<>s.id::text
  OR w.payload->>'scene_id'<>r.id::text
  OR w.payload->>'source_revision'<>s.source_revision
  OR w.payload->>'state_version'<>s.state_version::text
  OR w.payload->>'snapshot_sha256'<>s.snapshot_sha256
  OR w.payload->'snapshot' IS DISTINCT FROM r.snapshot
 THEN RAISE EXCEPTION 'SCENE56_SOURCE_CHANGED' USING ERRCODE='PT409';END IF;
 SELECT jsonb_agg(jsonb_build_object('message_id',rs.message_id,'user_id',rs.user_id,
  'character_id',rs.character_id,'sequence',rs.submission_order,'body',m.body,'body_sha256',rs.body_sha256)
  ORDER BY rs.submission_order,rs.message_id) INTO role_body
 FROM mission_generic_owner.role_submissions rs JOIN public.messages m ON m.id=rs.message_id
 WHERE rs.master_session_id=w.master_session_id AND rs.message_id=ANY(s.accepted_role_ids)
 AND rs.valid IS TRUE AND rs.invalid_reason IS NULL
 AND EXISTS(SELECT 1 FROM public.master_v2_participants part
  WHERE part.session_id=rs.master_session_id AND part.user_id_snapshot=rs.user_id
   AND part.character_id=rs.character_id AND part.left_at IS NULL AND part.engagement_state='attivo')
 AND EXISTS(SELECT 1 FROM jsonb_array_elements(r.snapshot->'players') captured_player
  WHERE captured_player->>'user_id'=rs.user_id::text AND captured_player->>'character_id'=rs.character_id::text)
 AND m.character_id=rs.character_id AND m.kind='say' AND m.recipient_user IS NULL
 AND m.location_id=(SELECT sess.location_id FROM public.master_v2_sessions sess WHERE sess.id=rs.master_session_id)
 AND encode(extensions.digest(convert_to(m.body,'UTF8'),'sha256'),'hex')=rs.body_sha256;
 role_body:=coalesce(role_body,'[]'::jsonb);
 IF jsonb_array_length(role_body)<>cardinality(s.accepted_role_ids)
  OR role_body IS DISTINCT FROM w.payload->'accepted_roles'
  OR public.combat_v2_sha256(role_body)<>s.accepted_roles_sha256
 THEN RAISE EXCEPTION 'SCENE56_ACCEPTED_ROLE_CHANGED' USING ERRCODE='PT409';END IF;
 src:=jsonb_build_object('schema_version','mission-narrative-scene-source/1','scene_id',r.id,
  'snapshot_sha256',s.snapshot_sha256,'state_version',s.state_version,'source_revision',s.source_revision,
  'accepted_role_ids',to_jsonb(s.accepted_role_ids),'accepted_roles_sha256',s.accepted_roles_sha256,
  'last_publication_id',s.last_publication_id,'last_publication_sha256',s.last_publication_sha256,
  'current_phase_key',s.current_phase_key,'scene_memory_sha256',s.scene_memory_sha256);
 RETURN src;
END $$;
REVOKE ALL PRIVILEGES ON FUNCTION mission_narrative_internal.scene_source_assert_v1 (uuid) FROM PUBLIC, anon, authenticated;
GRANT EXECUTE ON FUNCTION mission_narrative_internal.scene_source_assert_v1 (uuid) TO service_role;
CREATE OR REPLACE FUNCTION mission_narrative_internal.scene_prepare_v1(p_session uuid, p_user uuid, p_request uuid) RETURNS jsonb LANGUAGE plpgsql SECURITY DEFINER SET search_path TO '' AS $$
DECLARE r mission_narrative_internal.scene_runtime_v1; s mission_narrative_internal.scene_sources_v1;
 m public.master_v2_sessions; run public.mission_run_state; b mission_generic_owner.run_bindings;
 cursor_row mission_generic_owner.role_window_cursors; ids uuid[]; roles jsonb; payload jsonb;
 source_sha text; wid uuid; sw uuid; w mission_generic_owner.work_items;
BEGIN
 PERFORM mission_ai_board_owner.service_only();
 IF p_user IS NULL OR p_request IS NULL THEN RAISE EXCEPTION 'SCENE56_PREPARE_AUTHORITY' USING ERRCODE='42501';END IF;
 PERFORM 1 FROM public.locations WHERE id=(SELECT location_id FROM public.master_v2_sessions WHERE id=p_session) FOR UPDATE;
 -- Lock order is shared with role acceptance, publication and explicit Combat entry.
 SELECT * INTO STRICT cursor_row FROM mission_generic_owner.role_window_cursors WHERE master_session_id=p_session FOR UPDATE;
 SELECT * INTO STRICT r FROM mission_narrative_internal.scene_runtime_v1 WHERE master_session_id=p_session FOR UPDATE;
 SELECT * INTO STRICT m FROM public.master_v2_sessions WHERE id=p_session FOR UPDATE;
 SELECT * INTO STRICT run FROM public.mission_run_state WHERE master_session_id=p_session FOR UPDATE;
 SELECT * INTO STRICT b FROM mission_generic_owner.run_bindings WHERE master_session_id=p_session;
 IF NOT r.is_active OR r.mode<>'narrative' OR m.owner_kind<>'ai_service' OR m.closed_at IS NOT NULL
  OR m.suspended_at IS NOT NULL OR r.current_phase_key<>run.current_step_key
  OR NOT EXISTS(SELECT 1 FROM public.locations WHERE id=m.location_id AND is_test AND is_active)
  OR NOT EXISTS(SELECT 1 FROM public.master_v2_participants WHERE session_id=p_session
    AND user_id_snapshot=p_user AND left_at IS NULL AND engagement_state='attivo')
 THEN RAISE EXCEPTION 'SCENE56_PREPARE_SCOPE' USING ERRCODE='42501';END IF;
 SELECT * INTO s FROM mission_narrative_internal.scene_sources_v1 WHERE scene_id=r.id
 AND published_message_id IS NULL AND technical_receipt IS NULL AND retired_at IS NULL;
 IF FOUND THEN
  IF s.request_kind='combat_entry' THEN RETURN jsonb_build_object('state','combat_entry_pending','work_id',null);END IF;
  SELECT * INTO STRICT w FROM mission_generic_owner.work_items WHERE id=s.work_id;
  RETURN jsonb_build_object('work_id',w.id,'state',w.state,'request_key',w.request_key,'replayed',true);
 END IF;
 -- Roles are already authenticated captures. No parser or legal-action interpretation.
 SELECT array_agg(q.message_id ORDER BY q.submission_order,q.message_id),jsonb_agg(jsonb_build_object(
  'message_id',q.message_id,'user_id',q.user_id,'character_id',q.character_id,'sequence',q.submission_order,
  'body',q.body,'body_sha256',q.body_sha256) ORDER BY q.submission_order,q.message_id) INTO ids,roles
 FROM (SELECT DISTINCT ON(rs.user_id,rs.character_id) rs.*,msg.body
  FROM mission_generic_owner.role_submissions rs JOIN public.messages msg ON msg.id=rs.message_id
  JOIN public.master_v2_participants part ON part.session_id=rs.master_session_id
    AND part.user_id_snapshot=rs.user_id AND part.character_id=rs.character_id
  WHERE rs.master_session_id=p_session AND rs.window_epoch=cursor_row.window_epoch
   AND part.left_at IS NULL AND part.engagement_state='attivo'
   AND rs.valid IS TRUE AND rs.invalid_reason IS NULL
   AND EXISTS(SELECT 1 FROM jsonb_array_elements(r.snapshot->'players') captured_player
    WHERE captured_player->>'user_id'=rs.user_id::text AND captured_player->>'character_id'=rs.character_id::text)
   AND msg.character_id=rs.character_id AND msg.kind='say' AND msg.recipient_user IS NULL
   AND msg.location_id=m.location_id
   AND encode(extensions.digest(convert_to(msg.body,'UTF8'),'sha256'),'hex')=rs.body_sha256
  ORDER BY rs.user_id,rs.character_id,rs.accepted_at DESC,rs.message_id DESC) q;
 IF cardinality(ids) IS NULL OR EXISTS(SELECT 1 FROM public.master_v2_participants part
  WHERE part.session_id=p_session AND part.left_at IS NULL AND part.engagement_state='attivo'
  AND NOT EXISTS(SELECT 1 FROM mission_generic_owner.role_submissions rs
   WHERE rs.master_session_id=p_session AND rs.window_epoch=cursor_row.window_epoch
    AND rs.user_id=part.user_id_snapshot AND rs.character_id=part.character_id AND rs.message_id=ANY(ids)))
 THEN RETURN jsonb_build_object('state','waiting_roles','work_id',null);END IF;
 source_sha:=public.combat_v2_sha256(jsonb_build_object('scene_id',r.id,'state_version',r.state_version,
  'snapshot_sha256',r.snapshot_sha256,'phase',r.current_phase_key,'accepted_roles',roles,
  'last_publication_id',r.last_publication_id,'last_publication_sha256',r.last_publication_sha256,
  'scene_memory',r.scene_memory));
 sw:=mission_ai_service_owner.uuid5(r.id,'narrative-source:'||source_sha);
 wid:=mission_ai_service_owner.uuid5(sw,'narrative-work');
 payload:=jsonb_build_object('schema_version','mission-narrative-scene/1','mode','narrative_scene',
  'scene_id',r.id,'source_window_id',sw,'source_revision',source_sha,'state_version',r.state_version,
  'snapshot_sha256',r.snapshot_sha256,'snapshot',r.snapshot,'current_phase_key',r.current_phase_key,
  'scene_memory',r.scene_memory,'accepted_roles',roles,'last_publication',
  CASE WHEN r.last_publication_id IS NULL THEN 'null'::jsonb ELSE jsonb_build_object(
   'message_id',r.last_publication_id,'body_sha256',r.last_publication_sha256) END,'last_fati',r.last_fati);
 INSERT INTO mission_narrative_internal.scene_sources_v1(id,scene_id,work_id,actor_user_id,state_version,
  source_revision,snapshot_sha256,accepted_role_ids,accepted_roles_sha256,last_publication_id,
  last_publication_sha256,current_phase_key,scene_memory_sha256,payload_sha256)
 VALUES(sw,r.id,wid,p_user,r.state_version,source_sha,r.snapshot_sha256,ids,public.combat_v2_sha256(roles),
  r.last_publication_id,r.last_publication_sha256,r.current_phase_key,
  public.combat_v2_sha256(coalesce(r.scene_memory,'null'::jsonb)),public.combat_v2_sha256(payload));
 INSERT INTO mission_generic_owner.work_items(id,master_session_id,event_id,dedupe_key,step_key,
  run_control_version,definition_sha256,authority_receipt_id,kind,revision,payload,payload_sha256)
 VALUES(wid,p_session,sw,'narrative:'||sw,run.current_step_key,run.control_version,b.snapshot_sha256,
  sw,'narration',run.control_version,payload,public.combat_v2_sha256(payload));
 UPDATE mission_narrative_internal.scene_runtime_v1 SET turn_owner='fato',updated_at=clock_timestamp() WHERE id=r.id;
 PERFORM mission_narrative_internal.scene_source_assert_v1(wid);
 RETURN jsonb_build_object('work_id',wid,'state','narration_ready','replayed',false);
END $$;
REVOKE ALL PRIVILEGES ON FUNCTION mission_narrative_internal.scene_prepare_v1 (uuid, uuid, uuid) FROM PUBLIC, anon, authenticated;
GRANT EXECUTE ON FUNCTION mission_narrative_internal.scene_prepare_v1 (uuid, uuid, uuid) TO service_role;
CREATE OR REPLACE FUNCTION mission_narrative_internal.scene_message_permitted_v1(p_message public.messages) RETURNS boolean LANGUAGE plpgsql STABLE SECURITY DEFINER SET search_path TO '' AS $$
DECLARE sid uuid;nonce text:=current_setting('app.mission_role_command_v2',true);
BEGIN
 IF p_message.recipient_user IS NOT NULL THEN RETURN false;END IF;
 IF p_message.kind='say' AND p_message.character_id IS NOT NULL AND auth.uid() IS NOT NULL
  AND p_message.sender_user=auth.uid() AND nonce~'^[a-fA-F0-9]{8}(-[a-fA-F0-9]{4}){3}-[a-fA-F0-9]{12}$' THEN
  RETURN EXISTS(SELECT 1 FROM mission_generic_owner.role_commands_v2 cmd
   JOIN mission_narrative_internal.scene_runtime_v1 scene ON scene.master_session_id=cmd.master_session_id
   JOIN public.master_v2_sessions ms ON ms.id=scene.master_session_id
   JOIN mission_generic_owner.role_window_cursors cur ON cur.master_session_id=ms.id
   JOIN public.master_v2_participants part ON part.session_id=ms.id AND part.character_id=cmd.character_id
    AND part.user_id_snapshot=cmd.user_id
   JOIN public.characters ch ON ch.id=cmd.character_id AND ch.user_id=cmd.user_id
   WHERE cmd.request_key=nonce::uuid AND cmd.user_id=auth.uid() AND cmd.character_id=p_message.character_id
    AND cmd.state='pending' AND cmd.origin_txid=txid_current() AND cmd.origin_backend=pg_backend_pid()
    AND cmd.body_sha256=encode(extensions.digest(convert_to(p_message.body,'UTF8'),'sha256'),'hex')
    AND cmd.window_epoch=cur.window_epoch AND scene.is_active AND scene.mode='narrative'
    AND ms.owner_kind='ai_service' AND ms.closed_at IS NULL
    AND ms.location_id=p_message.location_id AND part.left_at IS NULL AND part.engagement_state='attivo'
    AND current_setting('app.mission_role_session',true)=ms.id::text
    AND current_setting('app.mission_role_character',true)=cmd.character_id::text);
 END IF;
 IF p_message.kind='fato' AND p_message.character_id IS NULL AND p_message.sender_user IS NULL
  AND auth.role()='service_role' THEN
  RETURN EXISTS(SELECT 1 FROM mission_narrative_internal.scene_sources_v1 src
   JOIN mission_narrative_internal.scene_runtime_v1 scene ON scene.id=src.scene_id
   JOIN public.master_v2_sessions ms ON ms.id=scene.master_session_id
   JOIN mission_generic_owner.work_items work ON work.id=src.work_id
   WHERE src.request_kind IN('narration','initial_opening') AND src.message_permit_id=p_message.id
    AND src.message_permit_txid=txid_current() AND src.message_permit_backend=pg_backend_pid()
    AND src.message_permit_sha256=encode(extensions.digest(convert_to(p_message.body,'UTF8'),'sha256'),'hex')
    AND src.published_message_id IS NULL AND src.retired_at IS NULL
    AND work.kind='narration' AND work.state='provider_started'
    AND scene.is_active AND scene.mode='narrative' AND scene.turn_owner='fato'
    AND scene.state_version=src.state_version AND ms.location_id=p_message.location_id
    AND ms.owner_kind='ai_service' AND ms.closed_at IS NULL);
 END IF;
 RETURN false;
END $$;
REVOKE ALL PRIVILEGES ON FUNCTION mission_narrative_internal.scene_message_permitted_v1 (public.messages) FROM PUBLIC, anon, authenticated, service_role;
CREATE OR REPLACE FUNCTION mission_narrative_internal.scene_initialize_v1(p_session uuid, p_actor uuid) RETURNS uuid LANGUAGE plpgsql SECURITY DEFINER SET search_path TO '' AS $$
DECLARE m public.master_v2_sessions;run public.mission_run_state;b mission_generic_owner.run_bindings;
 r mission_narrative_internal.scene_runtime_v1;root mission_factory_owner.editor_release_readiness;
 c jsonb;doc jsonb;ed jsonb;step jsonb;phase jsonb;scene jsonb;item jsonb;setting jsonb;
 phases jsonb:='[]';npcs jsonb;players jsonb;tokens jsonb;arena_map jsonb:='{}';ar jsonb;receipt jsonb;
 snap jsonb;sid uuid;last_id uuid;last_sha text;history jsonb;version bigint:=0;ek text;ecount integer;
BEGIN
 IF p_actor IS NULL OR (auth.uid() IS DISTINCT FROM p_actor AND auth.role() IS DISTINCT FROM 'service_role') THEN
  RAISE EXCEPTION 'SCENE56_INIT_ACTOR' USING ERRCODE='42501';END IF;
 PERFORM 1 FROM public.locations WHERE id=(SELECT location_id FROM public.master_v2_sessions WHERE id=p_session) FOR UPDATE;
 SELECT * INTO STRICT m FROM public.master_v2_sessions WHERE id=p_session FOR UPDATE;
 SELECT * INTO STRICT run FROM public.mission_run_state WHERE master_session_id=p_session FOR UPDATE;
 SELECT * INTO STRICT b FROM mission_generic_owner.run_bindings WHERE master_session_id=p_session;
 SELECT * INTO r FROM mission_narrative_internal.scene_runtime_v1 WHERE master_session_id=p_session FOR UPDATE;
 IF FOUND THEN
  IF NOT r.is_active OR r.snapshot_sha256<>public.combat_v2_sha256(r.snapshot) THEN RAISE EXCEPTION 'SCENE56_CACHE_CHANGED' USING ERRCODE='PT409';END IF;
  RETURN r.id;
 END IF;
 SELECT * INTO STRICT root FROM mission_factory_owner.editor_release_readiness WHERE singleton;
 IF root.state<>'enabled' OR root.scope<>'staff' OR NOT root.staff_guards_verified OR NOT root.published_assets_verified
  OR root.independent_review_ref IS NULL OR root.revision_sha256 IS DISTINCT FROM root.observed_revision_sha256
  OR root.revision_sha256 IS DISTINCT FROM encode(extensions.digest(convert_to(root.canonical_preimage,'UTF8'),'sha256'),'hex')
  OR root.canonical_preimage::jsonb#>'{config,c1266_narrative_scene}' IS DISTINCT FROM
   '{"schema_version":"mission-narrative-scene-policy/1","enabled":true,"scope":"staff"}'::jsonb
  OR m.owner_kind<>'ai_service' OR m.closed_at IS NOT NULL OR m.suspended_at IS NOT NULL
  OR NOT EXISTS(SELECT 1 FROM public.locations WHERE id=m.location_id AND is_test AND is_active)
  OR NOT EXISTS(SELECT 1 FROM public.master_v2_participants WHERE session_id=m.id AND user_id_snapshot=p_actor AND left_at IS NULL AND engagement_state='attivo')
  OR NOT EXISTS(SELECT 1 FROM mission_generic_owner.board_starts WHERE master_session_id=m.id AND simulation AND state IN('prepared','published'))
  OR mission_generic_owner.manual_staff_scope_v1(m.id) IS NULL
  OR b.snapshot_sha256 IS DISTINCT FROM mission_internal.fingerprint(b.snapshot)
 THEN RAISE EXCEPTION 'SCENE56_INIT_SCOPE' USING ERRCODE='42501';END IF;
 c:=b.snapshot->'creation';doc:=c->'document';ed:=doc->'editorial';
 IF jsonb_typeof(c) IS DISTINCT FROM 'object' OR b.snapshot->>'creation_sha256' IS DISTINCT FROM mission_internal.fingerprint(c)
  OR c->>'document_sha256' IS DISTINCT FROM mission_internal.fingerprint(doc)
  OR jsonb_typeof(doc#>'{plan,steps}') IS DISTINCT FROM 'array'
 THEN RAISE EXCEPTION 'SCENE56_FROZEN_SOURCE_UNSUPPORTED_OR_CHANGED' USING ERRCODE='PT409';END IF;
 IF EXISTS(SELECT 1 FROM jsonb_array_elements(doc#>'{plan,steps}')step WHERE NOT EXISTS(SELECT 1 FROM public.mission_plan_steps identity_step WHERE identity_step.plan_version_id=run.plan_version_id AND identity_step.step_key=step->>'step_key')) THEN RAISE EXCEPTION 'SCENE56_PHASE_IDENTITY_CHANGED' USING ERRCODE='PT409';END IF;
 -- Read approved narrative fields once. No mechanical template/binding/stat/move read.
 IF EXISTS(SELECT 1 FROM jsonb_array_elements(doc#>'{plan,definition,scenes}') ds,
   LATERAL jsonb_array_elements(ds->'actors') actor
   LEFT JOIN public.nb_template_versions nv ON nv.id=(actor->>'narrative_version_id')::uuid
   WHERE nv.id IS NULL OR nv.review_state<>'approved') THEN
  RAISE EXCEPTION 'SCENE56_NPC_VERSION_NOT_APPROVED' USING ERRCODE='42501';END IF;
 IF EXISTS(SELECT actor->>'actor_key' FROM jsonb_array_elements(doc#>'{plan,definition,scenes}') ds,
  LATERAL jsonb_array_elements(ds->'actors')actor GROUP BY actor->>'actor_key'
  HAVING count(DISTINCT actor->>'narrative_version_id')<>1) THEN
  RAISE EXCEPTION 'SCENE56_NPC_VERSION_SOURCE_AMBIGUOUS' USING ERRCODE='22023';END IF;
 SELECT coalesce(jsonb_agg(jsonb_build_object('actor_key',a.actor_key,'name',nv.skeleton#>>'{identity,name}',
  'narrative_version_id',nv.id,'profile',jsonb_build_object('skeleton',nv.skeleton,'fallback_profile',nv.fallback_profile),
  'knowledge',nv.knowledge_boundary) ORDER BY a.actor_key),'[]'::jsonb) INTO npcs
 FROM(SELECT DISTINCT actor->>'actor_key' actor_key,(actor->>'narrative_version_id')::uuid version_id
  FROM jsonb_array_elements(doc#>'{plan,definition,scenes}')ds,LATERAL jsonb_array_elements(ds->'actors')actor)a
 JOIN public.nb_template_versions nv ON nv.id=a.version_id AND nv.review_state='approved';
 SELECT coalesce(jsonb_agg(jsonb_build_object('user_id',p.user_id_snapshot,'character_id',p.character_id,'name',ch.name)
  ORDER BY p.character_id),'[]'::jsonb) INTO players FROM public.master_v2_participants p
 JOIN public.characters ch ON ch.id=p.character_id AND ch.user_id=p.user_id_snapshot
 WHERE p.session_id=m.id AND p.left_at IS NULL AND p.engagement_state='attivo';
 -- Effective arena receipts use the same frozen fields as the live Creation arena reader.
 FOR ar IN SELECT x FROM jsonb_array_elements(coalesce(c->'arenas','[]'::jsonb))x LOOP
  SELECT count(*),min(enc->>'encounter_key') INTO ecount,ek
   FROM jsonb_array_elements(b.snapshot#>'{definition,scenes}')ds,LATERAL jsonb_array_elements(ds->'encounters')enc
   WHERE ds->>'step_key'=ar->>'step_key';
  IF ecount<>1 THEN RAISE EXCEPTION 'SCENE56_CURRENT_MAP_ENCOUNTER_AMBIGUOUS' USING ERRCODE='22023';END IF;
  receipt:=jsonb_build_object('schema_version','universal-arena-state/1','status','ready','master_session_id',m.id,
   'mission_id',m.mission_id,'location_id',m.location_id,'origin','mission_phase','template_key',ar->>'template_key',
   'template_version',ar->'template_version','zone_key',ar->>'zone_key','catalog_sha256',ar->>'catalog_sha256','frozen_at',b.attached_at);
  arena_map:=arena_map||jsonb_build_object(ar->>'step_key',jsonb_build_object('receipt',receipt,
   'receipt_sha256',public.combat_v2_sha256(receipt),'encounter_key',ek));
 END LOOP;
 FOR step IN SELECT x FROM jsonb_array_elements(doc#>'{plan,steps}')x LOOP
  SELECT x INTO scene FROM jsonb_array_elements(coalesce(ed->'scenes','[]'::jsonb))x WHERE x->>'step_key'=step->>'step_key';
  SELECT coalesce(jsonb_agg(q.token ORDER BY q.ord,q.token),'[]'::jsonb) INTO tokens FROM(
   SELECT 'stay'::text token,0 ord UNION
   SELECT CASE WHEN dest->>'kind'='mechanical' THEN 'combat:' ELSE 'scene:' END||(tr->>'to_step_key'),1
    FROM jsonb_array_elements(doc#>'{plan,transitions}')tr
    JOIN LATERAL jsonb_array_elements(doc#>'{plan,steps}')dest ON dest->>'step_key'=tr->>'to_step_key'
    WHERE tr->>'from_step_key'=step->>'step_key'
   UNION SELECT 'combat:'||(step->>'step_key'),1 WHERE arena_map ? (step->>'step_key')
   UNION SELECT 'complete',2 WHERE EXISTS(SELECT 1 FROM jsonb_array_elements(doc#>'{plan,terminal_steps}')t WHERE t->>'step_key'=step->>'step_key')
  )q;
  phase:=jsonb_build_object('phase_key',step->>'step_key','kind',CASE WHEN step->>'kind'='mechanical' THEN 'combat' ELSE 'narrative' END,
   'objective',coalesce(step->>'public_objective',''),'entry_public',coalesce(scene->>'entry_public',''),
   'plot_private',coalesce(ed->>'plot_private',''),'notes',jsonb_build_object('director_notes',scene->'director_notes',
    'actors',coalesce(scene->'actors','[]'::jsonb),'consequences',coalesce(scene->'consequences','[]'::jsonb),'setting',scene->'setting')::text,
   'next_steps',tokens);
  phases:=phases||jsonb_build_array(phase);
 END LOOP;
 setting:=jsonb_build_object('name',coalesce(ed#>>'{setting,name}',''),'description',coalesce(ed#>>'{setting,description}',''));
 snap:=jsonb_build_object('schema_version','mission-narrative-scene-snapshot/1','mission',jsonb_build_object(
  'mission_id',m.mission_id,'title',doc#>>'{mission,title}','premise',coalesce(doc#>>'{mission,briefing}','')),
  'setting',setting,'phases',phases,'npcs',npcs,'players',players);
 SELECT coalesce(jsonb_agg(q.obj ORDER BY q.seq),'[]'::jsonb),coalesce(max(q.seq),0) INTO history,version FROM(
  SELECT jsonb_build_object('message_id',t.message_id,'sequence',t.seq,'body',t.body,'body_sha256',t.sha)obj,t.seq
  FROM(SELECT w.message_id,msg.body,encode(extensions.digest(convert_to(msg.body,'UTF8'),'sha256'),'hex')sha,
   row_number()OVER(ORDER BY msg.created_at,msg.id)seq FROM mission_generic_owner.work_items w
   JOIN public.messages msg ON msg.id=w.message_id AND msg.kind='fato' AND msg.recipient_user IS NULL
   WHERE w.master_session_id=m.id AND w.kind='narration' AND w.state='completed' AND w.receipt_id IS NOT NULL)t
  ORDER BY t.seq DESC LIMIT 4)q;
 SELECT (x->>'message_id')::uuid,x->>'body_sha256' INTO last_id,last_sha FROM jsonb_array_elements(history)x
 ORDER BY (x->>'sequence')::bigint DESC LIMIT 1;
 sid:=mission_ai_service_owner.uuid5(m.id,'narrative-scene-v1');
 receipt:=mission_creation_owner.arena_state(m.id); -- Classified exact body: frozen map metadata only, once at load.
 IF receipt->>'status'='ready' AND receipt IS DISTINCT FROM arena_map#>ARRAY[run.current_step_key,'receipt'] THEN
  RAISE EXCEPTION 'SCENE56_EFFECTIVE_ARENA_CHANGED' USING ERRCODE='PT409';END IF;
 INSERT INTO mission_narrative_internal.scene_runtime_v1(id,master_session_id,snapshot,snapshot_sha256,state_version,
  current_phase_key,mode,turn_owner,last_publication_id,last_publication_sha256,last_fati,arena_by_phase,
  arena_receipt,arena_phase_key,arena_receipt_sha256,encounter_key)
 VALUES(sid,m.id,snap,public.combat_v2_sha256(snap),version,run.current_step_key,'narrative','players',last_id,last_sha,history,arena_map,
  CASE WHEN receipt->>'status'='ready' THEN receipt ELSE NULL END,
  CASE WHEN receipt->>'status'='ready' THEN run.current_step_key ELSE NULL END,
  CASE WHEN receipt->>'status'='ready' THEN public.combat_v2_sha256(receipt) ELSE NULL END,
  CASE WHEN receipt->>'status'='ready' THEN arena_map#>>ARRAY[run.current_step_key,'encounter_key'] ELSE NULL END);
 RETURN sid;
END $$;
REVOKE ALL PRIVILEGES ON FUNCTION mission_narrative_internal.scene_initialize_v1 (uuid, uuid) FROM PUBLIC, anon, authenticated, service_role;
CREATE OR REPLACE FUNCTION mission_narrative_internal.scene_initial_opening_v1(p_session uuid, p_start uuid, p_actor uuid) RETURNS jsonb LANGUAGE plpgsql SECURITY DEFINER SET search_path TO '' AS $$
DECLARE r mission_narrative_internal.scene_runtime_v1;s mission_generic_owner.board_starts;
 run public.mission_run_state;b mission_generic_owner.run_bindings;w mission_generic_owner.work_items;
 sid uuid;sw uuid;wid uuid;rev text;payload jsonb;
BEGIN
 sid:=mission_narrative_internal.scene_initialize_v1(p_session,p_actor);
 SELECT * INTO STRICT r FROM mission_narrative_internal.scene_runtime_v1 WHERE id=sid FOR UPDATE;
 SELECT * INTO STRICT s FROM mission_generic_owner.board_starts WHERE id=p_start AND master_session_id=p_session FOR UPDATE;
 SELECT * INTO STRICT run FROM public.mission_run_state WHERE master_session_id=p_session;
 SELECT * INTO STRICT b FROM mission_generic_owner.run_bindings WHERE master_session_id=p_session;
 IF NOT s.simulation OR s.state<>'prepared' OR r.last_publication_id IS NOT NULL OR r.state_version<>0
  OR run.run_phase<>'preparazione' THEN RAISE EXCEPTION 'SCENE56_INITIAL_OPENING_SOURCE' USING ERRCODE='PT409';END IF;
 sw:=mission_ai_service_owner.uuid5(s.id,'narrative-scene-initial-opening');wid:=mission_ai_service_owner.uuid5(sw,'narrative-work');
 rev:=public.combat_v2_sha256(jsonb_build_object('scene_id',sid,'board_start_receipt',s.id,
  'board_start_sha256',s.snapshot_sha256,'snapshot_sha256',r.snapshot_sha256,'state_version',0));
 payload:=jsonb_build_object('schema_version','mission-narrative-scene/1','mode','narrative_scene',
  'scene_id',sid,'source_window_id',sw,'source_revision',rev,'state_version',0,'snapshot_sha256',r.snapshot_sha256,
  'snapshot',r.snapshot,'current_phase_key',r.current_phase_key,'scene_memory',NULL,'accepted_roles','[]'::jsonb,
  'last_publication',NULL,'last_fati','[]'::jsonb);
 INSERT INTO mission_narrative_internal.scene_sources_v1(id,scene_id,request_kind,board_start_receipt_id,work_id,
  actor_user_id,state_version,source_revision,snapshot_sha256,accepted_role_ids,accepted_roles_sha256,
  current_phase_key,scene_memory_sha256,payload_sha256)
 VALUES(sw,sid,'initial_opening',s.id,wid,p_actor,0,rev,r.snapshot_sha256,ARRAY[]::uuid[],public.combat_v2_sha256('[]'::jsonb),
  r.current_phase_key,public.combat_v2_sha256('null'::jsonb),public.combat_v2_sha256(payload));
 INSERT INTO mission_generic_owner.work_items(id,master_session_id,event_id,dedupe_key,step_key,run_control_version,
  definition_sha256,authority_receipt_id,kind,revision,payload,payload_sha256)
 VALUES(wid,p_session,sw,'opening:'||s.id,run.current_step_key,run.control_version,b.snapshot_sha256,sw,
  'narration',run.control_version,payload,public.combat_v2_sha256(payload)) RETURNING * INTO w;
 UPDATE mission_narrative_internal.scene_runtime_v1 SET turn_owner='fato',updated_at=clock_timestamp() WHERE id=sid;
 RETURN mission_generic_owner.work_status(w);
END $$;
REVOKE ALL PRIVILEGES ON FUNCTION mission_narrative_internal.scene_initial_opening_v1 (uuid, uuid, uuid) FROM PUBLIC, anon, authenticated, service_role;
CREATE OR REPLACE FUNCTION mission_narrative_internal.scene_publish_v1(p_work uuid, p_result jsonb) RETURNS jsonb LANGUAGE plpgsql SECURITY DEFINER SET search_path TO '' AS $$
DECLARE w mission_generic_owner.work_items;s mission_narrative_internal.scene_sources_v1;
 r mission_narrative_internal.scene_runtime_v1;m public.master_v2_sessions;run public.mission_run_state;
 bs mission_generic_owner.board_starts;ev public.mission_run_events;ob public.mission_run_outbox;
 upd jsonb;phase jsonb;step text;target text;memory jsonb;mid uuid;body_sha text;pub uuid;opened jsonb;history jsonb;
BEGIN
 PERFORM mission_ai_board_owner.service_only();
 PERFORM 1 FROM public.locations WHERE id=(SELECT master.location_id FROM public.master_v2_sessions master JOIN mission_generic_owner.work_items work ON work.master_session_id=master.id WHERE work.id=p_work) FOR UPDATE;
 SELECT * INTO STRICT w FROM mission_generic_owner.work_items WHERE id=p_work FOR UPDATE;
 PERFORM 1 FROM mission_generic_owner.role_window_cursors WHERE master_session_id=w.master_session_id FOR UPDATE;
 SELECT * INTO STRICT s FROM mission_narrative_internal.scene_sources_v1 WHERE work_id=w.id FOR UPDATE;
 SELECT * INTO STRICT r FROM mission_narrative_internal.scene_runtime_v1 WHERE id=s.scene_id FOR UPDATE;
 SELECT * INTO STRICT m FROM public.master_v2_sessions WHERE id=w.master_session_id FOR UPDATE;
 SELECT * INTO STRICT run FROM public.mission_run_state WHERE master_session_id=w.master_session_id FOR UPDATE;
 IF s.published_message_id IS NOT NULL THEN
  IF NOT EXISTS(SELECT 1 FROM public.messages WHERE id=s.published_message_id AND kind='fato'
   AND location_id=m.location_id AND body=p_result->>'text') THEN RAISE EXCEPTION 'SCENE56_PUBLICATION_REPLAY_CONFLICT' USING ERRCODE='PT409';END IF;
  RETURN jsonb_build_object('message_id',s.published_message_id,'replayed',true);
 END IF;
 PERFORM mission_narrative_internal.scene_source_assert_v1(w.id);
 upd:=p_result->'scene_update';memory:=upd->'scene_memory';step:=upd->>'next_step';
 SELECT x INTO STRICT phase FROM jsonb_array_elements(r.snapshot->'phases')x WHERE x->>'phase_key'=r.current_phase_key;
 IF p_result->'ok' IS DISTINCT FROM 'true'::jsonb OR jsonb_typeof(p_result->'text') IS DISTINCT FROM 'string'
  OR length(p_result->>'text') NOT BETWEEN 1 AND 5000
  OR NOT mission_factory_owner.keys_exact_v2(upd,ARRAY['schema_version','scene_id','source_window_id','source_revision','state_version','snapshot_sha256','next_step','scene_memory'])
  OR upd->>'schema_version' IS DISTINCT FROM 'mission-narrative-scene-update/1'
  OR upd->>'scene_id' IS DISTINCT FROM r.id::text OR upd->>'source_window_id' IS DISTINCT FROM s.id::text
  OR upd->>'source_revision' IS DISTINCT FROM s.source_revision
  OR upd->>'state_version' IS DISTINCT FROM s.state_version::text
  OR upd->>'snapshot_sha256' IS DISTINCT FROM s.snapshot_sha256
  OR (phase->'next_steps' ? step) IS DISTINCT FROM true
  OR (s.request_kind='initial_opening' AND step IS DISTINCT FROM 'stay')
  OR NOT mission_factory_owner.keys_exact_v2(memory,ARRAY['state','known','open','used'])
  OR jsonb_typeof(memory->'state') IS DISTINCT FROM 'string' OR length(memory->>'state')>600
  OR jsonb_typeof(memory->'known') IS DISTINCT FROM 'array' OR jsonb_typeof(memory->'open') IS DISTINCT FROM 'array'
  OR jsonb_typeof(memory->'used') IS DISTINCT FROM 'array'
 THEN RAISE EXCEPTION 'SCENE56_RESULT_TECHNICAL_SHAPE' USING ERRCODE='22023';END IF;
 IF jsonb_array_length(memory->'known')>16 OR jsonb_array_length(memory->'open')>10 OR jsonb_array_length(memory->'used')>20
  OR EXISTS(SELECT 1 FROM jsonb_array_elements(memory->'known')x WHERE jsonb_typeof(x)<>'string' OR length(x#>>'{}')>180)
  OR EXISTS(SELECT 1 FROM jsonb_array_elements(memory->'open')x WHERE jsonb_typeof(x)<>'string' OR length(x#>>'{}')>180)
  OR EXISTS(SELECT 1 FROM jsonb_array_elements(memory->'used')x WHERE jsonb_typeof(x)<>'string' OR length(x#>>'{}')>90)
 THEN RAISE EXCEPTION 'SCENE56_MEMORY_TECHNICAL_BOUND' USING ERRCODE='22023';END IF;
 target:=CASE WHEN step IN('stay','complete') THEN r.current_phase_key ELSE substring(step from position(':' in step)+1) END;
 IF NOT EXISTS(SELECT 1 FROM jsonb_array_elements(r.snapshot->'phases')x WHERE x->>'phase_key'=target)
 THEN RAISE EXCEPTION 'SCENE56_PHASE_REFERENCE' USING ERRCODE='22023';END IF;
 mid:=gen_random_uuid();body_sha:=encode(extensions.digest(convert_to(p_result->>'text','UTF8'),'sha256'),'hex');
 UPDATE mission_narrative_internal.scene_sources_v1 SET message_permit_id=mid,message_permit_sha256=body_sha,
  message_permit_txid=txid_current(),message_permit_backend=pg_backend_pid(),publication_next_step=step WHERE id=s.id;
 INSERT INTO public.messages(id,location_id,character_id,author_name,body,kind,sender_user,recipient_user,created_at)
 VALUES(mid,m.location_id,NULL,'Fato',p_result->>'text','fato',NULL,NULL,clock_timestamp());
 IF s.request_kind='initial_opening' THEN
  SELECT * INTO STRICT bs FROM mission_generic_owner.board_starts WHERE id=s.board_start_receipt_id AND master_session_id=w.master_session_id FOR UPDATE;
  SELECT * INTO STRICT ev FROM public.mission_run_events WHERE id=bs.event_id AND master_session_id=w.master_session_id FOR UPDATE;
  SELECT * INTO STRICT ob FROM public.mission_run_outbox WHERE event_id=ev.id AND master_session_id=w.master_session_id FOR UPDATE;
  IF NOT bs.simulation OR ev.status<>'committed' OR ob.state<>'pending' OR ev.version_after<>w.run_control_version
   OR ob.event_version_after<>ev.version_after OR ev.step_after<>w.step_key OR ob.step_key<>w.step_key
   OR ob.context_fingerprint<>ev.context_fingerprint THEN RAISE EXCEPTION 'SCENE56_OPENING_SOURCE_CHANGED' USING ERRCODE='PT409';END IF;
  pub:=gen_random_uuid();
  INSERT INTO public.mission_run_publications(id,master_session_id,event_id,request_key_sha256,request_fingerprint,source,
   expected_run_control_version,expected_event_version_after,expected_step_key,context_fingerprint,body_sha256,status)
  VALUES(pub,w.master_session_id,ev.id,mission_internal.request_key_sha256(w.request_key),
   mission_internal.fingerprint(jsonb_build_object('schema_version','mission-narrative-scene-publication/1','work_id',w.id,
    'source_id',s.id,'payload_sha256',w.payload_sha256,'body_sha256',body_sha)),
   'model',w.run_control_version,ev.version_after,w.step_key,ev.context_fingerprint,body_sha,'committed');
  INSERT INTO public.mission_run_messages(publication_id,message_id,body_sha256) VALUES(pub,mid,body_sha);
  PERFORM set_config('app.mission_outbox_publish','on',true);
  UPDATE public.mission_run_outbox SET state='published',publication_id=pub,published_at=clock_timestamp() WHERE event_id=ev.id;
  PERFORM set_config('app.mission_outbox_publish','off',true);
 END IF;
 SELECT coalesce(jsonb_agg(q.x ORDER BY (q.x->>'sequence')::bigint),'[]'::jsonb) INTO history FROM(
  SELECT x FROM jsonb_array_elements(r.last_fati||jsonb_build_array(jsonb_build_object('message_id',mid,
   'sequence',r.state_version+1,'body',p_result->>'text','body_sha256',body_sha)))x
  ORDER BY (x->>'sequence')::bigint DESC LIMIT 4)q;
 UPDATE mission_narrative_internal.scene_runtime_v1 SET current_phase_key=target,scene_memory=memory,
  last_publication_id=mid,last_publication_sha256=body_sha,last_fati=history,updated_at=clock_timestamp()
 WHERE id=r.id;
 IF target IS DISTINCT FROM r.current_phase_key THEN
  UPDATE mission_narrative_internal.scene_runtime_v1 SET
   arena_receipt=arena_by_phase#>ARRAY[target,'receipt'],
   arena_phase_key=CASE WHEN arena_by_phase ? target THEN target ELSE NULL END,
   arena_receipt_sha256=arena_by_phase#>>ARRAY[target,'receipt_sha256'],
   encounter_key=arena_by_phase#>>ARRAY[target,'encounter_key'] WHERE id=r.id;
 END IF;
 UPDATE mission_narrative_internal.scene_sources_v1 SET published_message_id=mid WHERE id=s.id;
 IF s.request_kind='initial_opening' THEN PERFORM mission_generic_owner.opening_published(w.master_session_id,pub);END IF;
 -- Only technical phase/control changes. The live trigger catalogue proves panel_mission_entry
 -- runs only on INSERT/UPDATE master_session_id, never on these phase/control columns.
 IF s.request_kind<>'initial_opening' THEN
  UPDATE public.mission_run_state SET current_step_key=target,control_version=control_version+1,updated_at=clock_timestamp()
   WHERE master_session_id=w.master_session_id AND control_version=run.control_version;
  IF NOT FOUND THEN RAISE EXCEPTION 'SCENE56_PHASE_CAS' USING ERRCODE='PT409';END IF;
 END IF;
 IF left(step,7)='combat:' THEN
  opened:=mission_narrative_internal.scene_open_current_v1(s.id,w.request_key);
 ELSE
  UPDATE mission_narrative_internal.scene_runtime_v1 SET state_version=state_version+1,
   mode=CASE WHEN step='complete' THEN 'closed' ELSE 'narrative' END,
   turn_owner=CASE WHEN step='complete' THEN 'closed' ELSE 'players' END WHERE id=r.id;
  IF step='complete' THEN
   UPDATE public.mission_run_state SET run_phase='conclusa',updated_at=clock_timestamp() WHERE master_session_id=w.master_session_id;
  END IF;
 END IF;
 IF s.request_kind<>'initial_opening' THEN PERFORM mission_generic_owner.role_window_advance_v1(w.master_session_id,mid);END IF;
 RETURN jsonb_build_object('message_id',mid,'replayed',false,'next_step',step,'combat_open',opened);
END $$;
REVOKE ALL PRIVILEGES ON FUNCTION mission_narrative_internal.scene_publish_v1 (uuid, jsonb) FROM PUBLIC, anon, authenticated;
GRANT EXECUTE ON FUNCTION mission_narrative_internal.scene_publish_v1 (uuid, jsonb) TO service_role;
CREATE OR REPLACE FUNCTION mission_narrative_internal.scene_combat_publication_sync_v1(p_work uuid, p_message uuid, p_publication jsonb) RETURNS void LANGUAGE plpgsql SECURITY DEFINER SET search_path TO '' AS $$
DECLARE w mission_generic_owner.work_items;r mission_narrative_internal.scene_runtime_v1;run public.mission_run_state;
 msg public.messages;history jsonb;memory jsonb;leaving boolean;
BEGIN
 PERFORM mission_ai_board_owner.service_only();
 SELECT * INTO STRICT w FROM mission_generic_owner.work_items WHERE id=p_work;
 SELECT * INTO r FROM mission_narrative_internal.scene_runtime_v1 WHERE master_session_id=w.master_session_id AND is_active FOR UPDATE;
 IF NOT FOUND THEN RETURN;END IF;
 IF r.last_publication_id=p_message THEN RETURN;END IF;
 IF r.mode<>'combat' THEN RAISE EXCEPTION 'SCENE56_NATIVE_PUBLICATION_MODE' USING ERRCODE='42501';END IF;
 SELECT * INTO STRICT msg FROM public.messages WHERE id=p_message AND kind='fato' AND recipient_user IS NULL;
 SELECT * INTO STRICT run FROM public.mission_run_state WHERE master_session_id=w.master_session_id;
 IF NOT EXISTS(SELECT 1 FROM mission_narrative_internal.scene_sources_v1 src
  JOIN mission_generic_owner.encounters enc ON enc.master_session_id=w.master_session_id
   AND enc.encounter_id=(src.technical_receipt->>'encounter_id')::uuid
  JOIN public.master_v2_sessions master ON master.id=enc.master_session_id AND master.location_id=msg.location_id
  WHERE src.scene_id=r.id AND src.technical_receipt->>'schema_version'='mission-narrative-combat-opening/1'
   AND w.encounter_id=enc.encounter_id)
  OR NOT (EXISTS(SELECT 1 FROM mission_generic_owner.unified_batches batch WHERE batch.writer_work_id=w.id AND batch.message_id=p_message AND batch.state='published')
   OR (w.payload->>'mode'='combat' AND EXISTS(SELECT 1 FROM public.combat_v2_round_reports report WHERE report.id=w.authority_receipt_id AND report.message_id=p_message)))
 THEN RAISE EXCEPTION 'SCENE56_NATIVE_PUBLICATION_SOURCE' USING ERRCODE='42501';END IF;
 leaving:=run.current_step_key IS DISTINCT FROM r.current_phase_key OR run.control_version IS DISTINCT FROM w.run_control_version;
 memory:=p_publication->'continuity';
 IF memory IS NULL OR NOT mission_factory_owner.keys_exact_v2(memory,ARRAY['state','known','open','used']) THEN memory:=r.scene_memory;END IF;
 SELECT coalesce(jsonb_agg(q.x ORDER BY (q.x->>'sequence')::bigint),'[]'::jsonb) INTO history FROM(
  SELECT x FROM jsonb_array_elements(r.last_fati||jsonb_build_array(jsonb_build_object('message_id',msg.id,
   'sequence',r.state_version+1,'body',msg.body,'body_sha256',encode(extensions.digest(convert_to(msg.body,'UTF8'),'sha256'),'hex'))))x
  ORDER BY (x->>'sequence')::bigint DESC LIMIT 4)q;
 UPDATE mission_narrative_internal.scene_runtime_v1 SET current_phase_key=run.current_step_key,
  mode=CASE WHEN leaving THEN 'narrative' ELSE 'combat' END,
  turn_owner=CASE WHEN leaving THEN 'players' ELSE 'combat' END,state_version=state_version+1,
  scene_memory=memory,last_publication_id=msg.id,last_publication_sha256=encode(extensions.digest(convert_to(msg.body,'UTF8'),'sha256'),'hex'),
  last_fati=history,updated_at=clock_timestamp(),
  arena_receipt=CASE WHEN leaving THEN arena_by_phase#>ARRAY[run.current_step_key,'receipt'] ELSE arena_receipt END,
  arena_phase_key=CASE WHEN leaving THEN CASE WHEN arena_by_phase ? run.current_step_key THEN run.current_step_key ELSE NULL END ELSE arena_phase_key END,
  arena_receipt_sha256=CASE WHEN leaving THEN arena_by_phase#>>ARRAY[run.current_step_key,'receipt_sha256'] ELSE arena_receipt_sha256 END,
  encounter_key=CASE WHEN leaving THEN arena_by_phase#>>ARRAY[run.current_step_key,'encounter_key'] ELSE encounter_key END
 WHERE id=r.id;
END $$;
REVOKE ALL PRIVILEGES ON FUNCTION mission_narrative_internal.scene_combat_publication_sync_v1 (uuid, uuid, jsonb) FROM PUBLIC, anon, authenticated;
GRANT EXECUTE ON FUNCTION mission_narrative_internal.scene_combat_publication_sync_v1 (uuid, uuid, jsonb) TO service_role;
CREATE OR REPLACE FUNCTION mission_narrative_internal.scene_finish_proof_v1(p_session uuid, p_user uuid) RETURNS jsonb LANGUAGE plpgsql STABLE SECURITY DEFINER SET search_path TO '' AS $$
DECLARE r mission_narrative_internal.scene_runtime_v1;s mission_narrative_internal.scene_sources_v1;
 w mission_generic_owner.work_items;m public.master_v2_sessions;run public.mission_run_state;
 items jsonb;rev text;k uuid;reason text:='scope_closed';
BEGIN
 SELECT * INTO r FROM mission_narrative_internal.scene_runtime_v1 WHERE master_session_id=p_session AND is_active;
 IF NOT FOUND THEN RETURN NULL;END IF;
 SELECT * INTO m FROM public.master_v2_sessions WHERE id=p_session;
 SELECT * INTO run FROM public.mission_run_state WHERE master_session_id=p_session;
 IF p_user IS NULL OR m.owner_kind<>'ai_service' OR m.master_user IS NOT NULL
  OR m.location_id<>'0b85f354-9cdb-47e1-baf9-3d266bb7e06b'::uuid
  OR NOT EXISTS(SELECT 1 FROM public.locations WHERE id=m.location_id AND is_test AND is_active)
  OR NOT EXISTS(SELECT 1 FROM mission_generic_owner.board_starts WHERE master_session_id=m.id AND simulation AND state='published')
  OR NOT EXISTS(SELECT 1 FROM public.profiles profile JOIN public.master_v2_participants part ON part.user_id_snapshot=profile.id
   JOIN public.characters ch ON ch.id=part.character_id AND ch.user_id=profile.id
   WHERE profile.id=p_user AND profile.role IN('admin','master') AND part.session_id=m.id)
 THEN RETURN NULL;END IF;
 IF r.mode<>'closed' OR r.turn_owner<>'closed' OR run.run_phase<>'conclusa' THEN reason:='waiting_final_publication';
 ELSIF EXISTS(SELECT 1 FROM mission_generic_owner.work_items x WHERE x.master_session_id=m.id AND x.state NOT IN('completed','failed'))
  OR EXISTS(SELECT 1 FROM mission_narrative_internal.dispatch_attempts attempt JOIN mission_generic_owner.work_items x ON x.dispatch_receipt_id=attempt.receipt_id
   WHERE x.master_session_id=m.id AND attempt.status IN('reserved','authorized','provider_started','unknown_billable'))
  OR EXISTS(SELECT 1 FROM staff_ai_quota_private.calls call WHERE call.scope_id=m.id AND call.state IN('reserved','sent','unknown_billable')
   AND NOT (call.producer='mission_generic_ai' AND call.call_no=2 AND call.state='unknown_billable'
    AND call.sent_at IS NOT NULL AND call.reserved_usd>0 AND call.charged_usd IS NULL
    AND EXISTS(SELECT 1 FROM mission_narrative_internal.dispatch_receipts counted_dr
     JOIN mission_generic_owner.work_items counted_work ON counted_work.dispatch_receipt_id=counted_dr.id AND counted_work.master_session_id=call.scope_id
     JOIN staff_ai_quota_private.calls counted_gen ON counted_gen.producer=call.producer AND counted_gen.source_id=call.source_id AND counted_gen.scope_id=call.scope_id AND counted_gen.call_no=1
     JOIN mission_narrative_internal.dispatch_audit counted_audit ON counted_audit.receipt_id=counted_dr.id AND counted_audit.event_code='c8_count_success'
     WHERE counted_dr.id=call.source_id AND counted_dr.master_session_id=call.scope_id AND counted_dr.status='success'
      AND counted_dr.dispatch_count=1 AND counted_dr.finalized_at IS NOT NULL
      AND counted_work.state IN('completed','failed') AND counted_work.finalized_at IS NOT NULL
      AND counted_gen.state='settled' AND counted_gen.settled_at IS NOT NULL AND counted_gen.charged_usd=counted_dr.charged_cost_usd
      AND counted_audit.details->>'work_id'=counted_work.id::text AND counted_audit.details->>'state'='success'
      AND counted_audit.details->'generation_allowed'='true'::jsonb AND counted_audit.details->>'count_http_calls'='1'
      AND counted_audit.details->>'generation_http_calls'='0')))
  OR EXISTS(SELECT 1 FROM public.mission_run_outbox WHERE master_session_id=m.id AND state IN('pending','human_directed'))
  OR EXISTS(SELECT 1 FROM mission_narrative_internal.scene_sources_v1 WHERE scene_id=r.id AND published_message_id IS NULL AND technical_receipt IS NULL AND retired_at IS NULL)
 THEN reason:='work_pending';
 ELSIF EXISTS(SELECT 1 FROM public.combat_v2_sessions WHERE master_session_id=m.id AND (state<>'chiuso' OR closed_at IS NULL)) THEN reason:='combat_pending';
 ELSE
  SELECT * INTO s FROM mission_narrative_internal.scene_sources_v1 WHERE scene_id=r.id AND published_message_id=r.last_publication_id AND publication_next_step='complete';
  SELECT * INTO w FROM mission_generic_owner.work_items WHERE id=s.work_id;
  IF s.id IS NULL OR w.id IS NULL OR w.state<>'completed' OR w.kind<>'narration' OR w.message_id IS DISTINCT FROM r.last_publication_id
   OR w.result#>>'{scene_update,next_step}' IS DISTINCT FROM 'complete' OR w.result->'ok' IS DISTINCT FROM 'true'::jsonb
   OR run.current_step_key IS DISTINCT FROM r.current_phase_key OR run.control_version IS DISTINCT FROM w.run_control_version+1
   OR NOT EXISTS(SELECT 1 FROM public.messages msg WHERE msg.id=r.last_publication_id AND msg.location_id=m.location_id
    AND msg.kind='fato' AND msg.recipient_user IS NULL AND msg.body=w.result->>'text'
    AND encode(extensions.digest(convert_to(msg.body,'UTF8'),'sha256'),'hex')=r.last_publication_sha256)
  THEN reason:='waiting_final_publication';
  ELSIF EXISTS(SELECT 1 FROM mission_generic_owner.work_items x WHERE x.master_session_id=m.id AND
   (x.finalized_at IS NULL OR x.receipt_id IS NULL OR x.result_sha256 IS NULL OR x.result_sha256!~'^[a-f0-9]{64}$'
    OR (x.state='failed' AND x.message_id IS NOT NULL)
    OR (coalesce(x.result->>'provider_calls','0')='1' AND NOT EXISTS(
     SELECT 1 FROM mission_narrative_internal.dispatch_receipts receipt
     JOIN mission_narrative_internal.dispatch_attempts attempt ON attempt.receipt_id=receipt.id
     WHERE receipt.id=x.dispatch_receipt_id AND receipt.master_session_id=m.id AND receipt.status='success' AND receipt.finalized_at IS NOT NULL
      AND attempt.status='success' AND attempt.cost_basis='exact' AND attempt.finalized_at IS NOT NULL
      AND (EXISTS(SELECT 1 FROM mission_narrative_internal.provider_outputs_v1 output
        WHERE output.work_id=x.id AND output.dispatch_receipt_id=receipt.id AND output.raw_sha256=x.result->>'raw_sha256')
       OR (x.kind='narration' AND x.state='completed' AND x.step_key='inizio' AND x.dedupe_key='opening:'||x.event_id::text
        AND x.result->>'schema_version'='mission-generic-result/1' AND x.result->>'provider_status'='completed'
        AND x.result->'outcome_uncertain'='false'::jsonb AND x.result->>'raw_sha256'~'^[a-f0-9]{64}$'
        AND x.payload_sha256=public.combat_v2_sha256(x.payload)
        AND EXISTS(SELECT 1 FROM mission_narrative_internal.dispatch_audit opening_audit
         JOIN public.messages opening_msg ON opening_msg.id=x.message_id AND opening_msg.location_id=m.location_id
          AND opening_msg.kind='fato' AND opening_msg.recipient_user IS NULL AND opening_msg.body=x.result->>'text'
         JOIN staff_ai_quota_private.calls opening_gen ON opening_gen.producer='mission_generic_ai' AND opening_gen.source_id=receipt.id
          AND opening_gen.scope_id=m.id AND opening_gen.call_no=1 AND opening_gen.state='settled'
          AND opening_gen.settled_at IS NOT NULL AND opening_gen.charged_usd=receipt.charged_cost_usd
         WHERE opening_audit.receipt_id=receipt.id AND opening_audit.event_code='generic_finalized'
          AND opening_audit.details->>'work_id'=x.id::text AND opening_audit.details->>'receipt_id'=x.receipt_id::text
          AND opening_audit.details->>'message_id'=x.message_id::text AND opening_audit.details->>'state'='completed'
          AND opening_audit.details->'stale'='false'::jsonb AND opening_audit.details->'outcome_uncertain'='false'::jsonb
          AND opening_audit.details->>'cost_basis'='exact' AND opening_audit.details->>'result_sha256'=x.result_sha256
          AND opening_audit.details->>'result_jsonb_sha256'=public.combat_v2_sha256(x.result))))))))
  THEN reason:='history_unreconciled';
  ELSE
   SELECT coalesce(jsonb_agg(jsonb_build_object('work_id',x.id,'kind',x.kind,'state',x.state,'receipt_id',x.receipt_id,
    'dispatch_receipt_id',x.dispatch_receipt_id,'result_sha256',x.result_sha256,'raw_sha256',x.result->>'raw_sha256',
    'message_id',x.message_id,'disposition',CASE WHEN x.state='failed' THEN 'original_failure_preserved' ELSE 'completed' END)
    ORDER BY x.id),'[]'::jsonb) INTO items FROM mission_generic_owner.work_items x WHERE x.master_session_id=m.id;
   rev:=public.combat_v2_sha256(jsonb_build_object('schema_version','mission-narrative-scene-finish-source/1',
    'scene_id',r.id,'state_version',r.state_version,'snapshot_sha256',r.snapshot_sha256,'phase',r.current_phase_key,
    'publication_id',r.last_publication_id,'publication_sha256',r.last_publication_sha256,'final_work',w.id,
    'result_sha256',w.result_sha256,'history_sha256',public.combat_v2_sha256(items)));
   k:=mission_ai_service_owner.uuid5(m.id,'mission-staff-finish/1:'||rev||':'||r.last_publication_id::text);reason:='ready';
  END IF;
 END IF;
 RETURN jsonb_build_object('schema_version','mission-narrative-scene-finish-proof/1','master_session_id',m.id,
  'can_finish',reason='ready','reason',reason,'source_revision',rev,'publication_id',r.last_publication_id,
  'request_key',k,'history_items',items);
END $$;
REVOKE ALL PRIVILEGES ON FUNCTION mission_narrative_internal.scene_finish_proof_v1 (uuid, uuid) FROM PUBLIC, anon, authenticated, service_role;
CREATE OR REPLACE FUNCTION mission_generic_owner.combat_narrative_source(p_session uuid, p_event uuid) RETURNS jsonb LANGUAGE plpgsql SECURITY DEFINER SET search_path TO '' AS $$
declare scene56_runtime mission_narrative_internal.scene_runtime_v1;scene56_npc jsonb;scene56_last public.messages;
 e mission_generic_owner.encounters%rowtype; b mission_generic_owner.run_bindings%rowtype;
 run public.mission_run_state%rowtype; s public.combat_v2_sessions%rowtype;
 r public.combat_v2_rounds%rowtype; rep public.combat_v2_round_reports%rowtype;
 a public.combat_v2_actors%rowtype; d public.combat_v2_declarations%rowtype;
 place public.locations%rowtype; row record; item jsonb; projected jsonb; narrator jsonb;
 roleless jsonb:='[]'; actors jsonb:='[]'; actions jsonb:='[]'; sources jsonb:='[]'; facts jsonb:='[]'; spatial jsonb:='[]';
 snapshot jsonb; candidate jsonb; scenehash text; body text; sid text; pname text; persona text;
 prior_count integer:=0; included integer:=0;director jsonb;loc text;setting_body text;setting_id text;actor_key text;payload jsonb;knowledge jsonb;knowledge_context jsonb:='[]';input_cap integer;continuity_snapshot jsonb;
begin
 if auth.uid() is not null or not public.combat_v2_is_service() then raise exception 'MG_SERVICE_REQUIRED' using errcode='42501';end if;
 perform mission_generic_owner.assert_runtime(p_session);
 input_cap:=(mission_generic_owner.capacity()->>'input_capacity_bytes')::integer;
 select * into strict b from mission_generic_owner.run_bindings where master_session_id=p_session;
 select * into strict run from public.mission_run_state where master_session_id=p_session;
 select * into strict rep from public.combat_v2_round_reports where id=p_event;
 perform public.combat_v2_lock_round(rep.round_id);
 select * into strict r from public.combat_v2_rounds where id=rep.round_id and report_id=rep.id;
 select * into strict s from public.combat_v2_sessions where id=r.session_id and master_session_id=p_session;
 select * into strict e from mission_generic_owner.encounters where encounter_id=s.id and master_session_id=p_session;
 select * into strict place from public.locations where id=s.location_id;
 if e.step_key<>run.current_step_key or e.run_control_version<>run.control_version
  or b.snapshot_sha256 is distinct from mission_internal.fingerprint(b.snapshot)
  or r.state<>'risolto' or r.resolved_at is null or rep.narration_state<>'attesa'
  or rep.mechanics_sha256 is distinct from public.combat_v2_sha256(rep.mechanics)
  or jsonb_typeof(rep.mechanics->'declarations') is distinct from 'array'
  or (place.is_test and (rep.values_written or public.combat_v2_values_written(s.id)))
 then raise exception 'MG_COMBAT_SOURCE_STALE' using errcode='55000';end if;
 SELECT * INTO scene56_runtime FROM mission_narrative_internal.scene_runtime_v1 WHERE master_session_id=p_session AND is_active;
 director:=mission_creation_owner.director_context(p_session,run.current_step_key);
 if director is null then
  loc:=place.name;setting_body:=place.description;setting_id:='location:'||place.id;
 else
  loc:=case when nullif(btrim(director#>>'{setting,name}'),'') is not null then director#>>'{setting,name}' else 'Ambientazione della missione' end;
  setting_body:=director#>>'{setting,description}';
  setting_id:='mission-setting:'||p_session||':'||run.current_step_key;
  if director->>'schema_version' is distinct from 'mission-director-context/1'
   or nullif(btrim(loc),'') is null or nullif(btrim(setting_body),'') is null
  then raise exception 'MC_DIRECTOR_CONTEXT_INVALID';end if;
 end if;
 for a in select * from public.combat_v2_actors where session_id=s.id order by id loop
  persona:=null;pname:=null;
  if a.actor_kind='pg' then
   select name into strict pname from public.characters where id=a.character_id and user_id=a.controller_user;
  elsif a.actor_kind='png' then
    IF scene56_runtime.id IS NOT NULL THEN
     SELECT map->>'actor_key' INTO STRICT actor_key FROM jsonb_array_elements(e.actor_map)map WHERE map->>'actor_id'=a.id::text;
     SELECT npc INTO STRICT scene56_npc FROM jsonb_array_elements(scene56_runtime.snapshot->'npcs')npc WHERE npc->>'actor_key'=actor_key;
     pname:=scene56_npc->>'name';
     persona:=jsonb_build_object('voice',scene56_npc#>'{profile,skeleton,voice}',
      'gestures',scene56_npc#>'{profile,skeleton,gestures}',
      'life_core',scene56_npc#>'{profile,skeleton}',
      'conduct',scene56_npc#>'{profile,skeleton,conduct}',
      'forbidden',scene56_npc#>'{profile,skeleton,forbidden}')::text;
     knowledge:=jsonb_build_object('actor_id',a.id,'knowledge_limits',scene56_npc#>'{profile,skeleton,knowledge_limits}',
      'knowledge_boundary',scene56_npc->'knowledge');
    ELSE
   select pi.nome,(jsonb_build_object('voice',nv.skeleton->'voice','gestures',nv.skeleton->'gestures',
    'life_core',jsonb_build_object(
    'background',jsonb_strip_nulls(jsonb_build_object('role',nv.skeleton#>'{identity,role}','origin',nv.skeleton#>'{identity,origin}')),
    'motivations',nv.skeleton->'motivations','goals',nv.skeleton->'goals','fears',nv.skeleton->'fears',
    'fragility',nv.skeleton->'fragility','resilience',nv.skeleton->'resilience',
    'character_errors',nv.skeleton->'character_errors','recovery',nv.skeleton->'recovery',
    'relationships',nv.skeleton->'relationships',
    'continuity',jsonb_strip_nulls(jsonb_build_object('emotional',nv.skeleton#>'{continuity,emotional}',
      'relational',nv.skeleton#>'{continuity,relational}','emotional_endings',nv.skeleton#>'{continuity,emotional_endings}')))) || case when mission_academy_owner.staff_carrier_runtime(p_session) then jsonb_build_object('conduct',nv.skeleton->'conduct','forbidden',nv.skeleton->'forbidden') else '{}'::jsonb end)::text,
    jsonb_build_object('actor_id',a.id,'knowledge_limits',nv.skeleton->'knowledge_limits','knowledge_boundary',nv.knowledge_boundary)
    into strict pname,persona,knowledge
    from public.combat_v2_provider_instances_v1 pi join public.nb_template_versions nv on nv.id=pi.narrative_version_ref
    where pi.id=a.provider_instance_v1_id and pi.session_id=s.id;
    END IF;
   if director is not null then
    select x->>'actor_key' into strict actor_key from jsonb_array_elements(e.actor_map) x
     where x->>'actor_id'=a.id::text;
    -- The mapping identifies the approved actor for its private phase notes.
    -- It carries no secret or additional actor authority.
    persona:=(persona::jsonb||jsonb_build_object('mission_actor_key',actor_key))::text;
    knowledge_context:=knowledge_context||jsonb_build_array(knowledge||jsonb_build_object('actor_key',actor_key));
   end if;
  else raise exception 'MG_SCENE_ACTOR_UNSUPPORTED'  using errcode='55000';end if;
  if nullif(btrim(pname),'') is null then raise exception 'MG_SCENE_IDENTITY_MISSING';end if;
  actors:=actors||jsonb_build_array(jsonb_build_object('id',a.id,'name',pname,'kind',upper(a.actor_kind),
    'persona',persona,'may_speak',a.actor_kind='png'));
 end loop;
 if nullif(btrim(setting_body),'') is not null then
  body:=setting_body;
  sources:=jsonb_build_array(jsonb_build_object('id',setting_id,'session_id',s.id,'round_id',r.id,
   'kind','setting','actor_id',null,'sequence',0,'body',body,
   'sha256',encode(extensions.digest(convert_to(body,'UTF8'),'sha256'),'hex'),'visibility','public','complete',true));
 end if;
 -- Staff reads this publication in the certified delta, not twice as a setting.
 -- Legacy public path remains unchanged.
 if not mission_generic_owner.flow_scope_enabled(p_session) then
 -- Only public mission publications tied to this run, never an unfiltered chat.
 for row in select w.id,w.result->>'text' body,
 case when w.payload->>'mode'='unified' then coalesce(w.message_id,(select urp.message_id
  from mission_generic_owner.unified_report_publications urp join mission_generic_owner.unified_batches ub on ub.id=urp.batch_id
  where ub.id=w.authority_receipt_id and ub.master_session_id=w.master_session_id and ub.writer_work_id=w.id
   and ub.state='published' and ub.message_id=urp.message_id and urp.primary_report and urp.report_id=ub.source_report_id))
 else w.message_id end message_id from mission_generic_owner.work_items w
  where w.master_session_id=p_session and w.kind='narration' and w.state='completed' and w.payload->>'mode' in('mission','unified')
  order by w.created_at desc limit 1 loop
  if nullif(btrim(row.body),'') is null or not exists(select 1 from public.messages m where m.id=row.message_id
    and m.location_id=place.id and m.recipient_user is null and m.kind='fato' and m.body=row.body)
  then raise exception 'MG_SCENE_CONTINUITY_CHANGED';end if;
  sources:=sources||jsonb_build_array(jsonb_build_object('id','mission:'||row.id,'session_id',s.id,'round_id',r.id,
   'kind','setting','actor_id',null,'sequence',0,'body',row.body,
   'sha256',encode(extensions.digest(convert_to(row.body,'UTF8'),'sha256'),'hex'),'visibility','public','complete',true));
 end loop;
 end if;
 IF scene56_runtime.id IS NOT NULL AND scene56_runtime.last_publication_id IS NOT NULL THEN
  SELECT * INTO STRICT scene56_last FROM public.messages WHERE id=scene56_runtime.last_publication_id
   AND location_id=place.id AND kind='fato' AND recipient_user IS NULL;
  IF encode(extensions.digest(convert_to(scene56_last.body,'UTF8'),'sha256'),'hex') IS DISTINCT FROM scene56_runtime.last_publication_sha256
   THEN RAISE EXCEPTION 'SCENE56_COMBAT_CONTINUITY_CHANGED' USING ERRCODE='PT409';END IF;
  sources:=sources||jsonb_build_array(jsonb_build_object('id','mission:'||scene56_last.id,'session_id',s.id,'round_id',r.id,
   'kind','setting','actor_id',NULL,'sequence',0,'body',scene56_last.body,'sha256',scene56_runtime.last_publication_sha256,
   'visibility','public','complete',true));
 END IF;
 for d in select * from public.combat_v2_declarations where round_id=r.id order by order_no nulls last,id loop
  select value into strict item from jsonb_array_elements(rep.mechanics->'declarations') where value->>'id'=d.id::text;
  if item->>'actor' is distinct from d.actor_id::text or item->>'kind' is distinct from d.kind
   or item->>'state' is distinct from d.state or item->'outcome' is distinct from d.outcome
   or d.state not in('risolta','superflua') then raise exception 'MG_SCENE_REPORT_CHANGED';end if;
  if d.state='risolta' then projected:=combat_panel_private.narrative_declaration_facts(d.id);
  else
   projected:=jsonb_build_object('execution','not_executed','result',combat_panel_private.narrative_outcome_facts(d.outcome));
   IF d.state='superflua' AND combat_v2_elemental_internal.suiton_narrative_supported(d.id) THEN
    projected:=projected||combat_v2_elemental_internal.suiton_narrative_projection(d.id)||jsonb_build_object('suiton_technique',(SELECT jsonb_build_object('name',s.profile->'name','description',s.profile->'effect_description','limits',s.profile->'limits','provenance','elementali-frozen-tech/1') FROM combat_v2_elemental_internal.suiton_sources s WHERE s.declaration_id=d.id));
   END IF;
  end if;
  IF d.state='superflua' AND combat_v2_elemental_internal.other_narrative_supported(d.id) THEN projected:=projected||combat_v2_elemental_internal.other_narrative_projection(d.id);END IF;
  facts:=facts||jsonb_build_array(jsonb_build_object('declaration_id',d.id,'actor_id',d.actor_id,
   'target_actor_id',d.target_actor_id,'kind',d.kind,'facts',projected));
  -- Automatic missing-defence receipts are facts, not a newly invented role.
  if d.kind='nessuna' and coalesce(d.declaration_text,'')='' then continue;end if;
  select * into strict a from public.combat_v2_actors where id=d.actor_id and session_id=s.id;
  select m.id::text,m.body into sid,body from combat_consumer_private.declaration_messages l
   join public.messages m on m.id=l.message_id where l.declaration_id=d.id and m.location_id=place.id
    and m.recipient_user is null and m.kind not in('whisper','motore')
    and public._combat_narrative_sha(m.id)=l.message_sha256
    and ((a.actor_kind='pg' and m.character_id=a.character_id and (
        m.sender_user=a.controller_user
        or (m.sender_user is null and exists(select 1 from combat_panel_private.request_receipts q
          where q.principal_user=a.controller_user and q.request_key=d.request_key
            and q.viewer_envelope#>>'{receipt,declaration_id}'=d.id::text))))
      or (a.actor_kind='png' and m.character_id is null and m.sender_user is null and m.kind='fato'));
  if sid is null and a.actor_kind='png' and exists(select 1 from mission_generic_owner.unified_round_windows uw where uw.round_id=d.round_id)
   and not exists(select 1 from mission_generic_owner.unified_round_windows rw
    join mission_generic_owner.unified_batches batch_row on batch_row.id=rw.batch_id
    where rw.round_id=d.round_id and batch_row.payload->>'schema_version'='mission-generic-narration/4'
      and batch_row.composition_kind='entry_png') then
   select 'choice:'||w.id::text,w.result#>>'{command,narrative_text}' into strict sid,body
   from mission_generic_owner.panel_choices c
   join mission_generic_owner.work_items w on w.id=c.work_id and w.master_session_id=p_session
   join mission_narrative_internal.dispatch_audit da on da.receipt_id=w.dispatch_receipt_id and da.event_code='generic_finalized'
   join combat_panel_private.request_receipts q on q.principal_user=c.principal_id and q.request_key=c.request_key
   where c.encounter_id=s.id and c.actor_id=a.id and c.request_key=d.request_key and c.consumed_at is not null
    and c.result=q.viewer_envelope and c.command_sha256=q.command_fingerprint
    and q.viewer_envelope#>>'{receipt,declaration_id}'=d.id::text
    and w.kind='choice' and w.state='completed'
    and da.details->>'result_sha256'=w.result_sha256
    and da.details->>'result_jsonb_sha256'=public.combat_v2_sha256(w.result)
    and w.result#>>'{command,narrative_text}'=d.declaration_text;
  end if;
  if a.actor_kind='png' and not exists(select 1 from mission_generic_owner.panel_choices c
    join combat_panel_private.request_receipts q on q.principal_user=c.principal_id and q.request_key=c.request_key
    where c.encounter_id=s.id and c.actor_id=a.id and c.request_key=d.request_key and c.consumed_at is not null
    and c.result=q.viewer_envelope and c.command_sha256=q.command_fingerprint
    and q.viewer_envelope#>>'{receipt,declaration_id}'=d.id::text)
  then raise exception 'MG_SCENE_PNG_RECEIPT_MISSING';end if;
  if a.actor_kind='png' and exists(select 1 from mission_generic_owner.unified_round_windows urw where urw.round_id=r.id) then
   if exists(select 1 from mission_generic_owner.unified_round_windows rw
      join mission_generic_owner.unified_batches batch_row on batch_row.id=rw.batch_id
      where rw.round_id=d.round_id and batch_row.payload->>'schema_version'='mission-generic-narration/4'
       and batch_row.composition_kind='entry_png') then
    select v.source_id::text,v.body into sid,body
     from mission_generic_owner.verified_deferred_source_v4(d.id) v;
    if sid is null then raise exception 'MRS_V4_SCENE_DEFERRED_SOURCE_MISSING';end if;
   else
    sid:=d.id::text;body:=d.declaration_text;
   end if;
  end if;
  if d.kind='passa' and coalesce(btrim(d.declaration_text),'')='' and exists(select 1 from mission_generic_owner.unified_round_windows urw where urw.round_id=r.id) then
   roleless:=roleless||jsonb_build_array(mission_generic_owner.unified_roleless_receipt(d.id));continue;
  end if;
  if sid is null or nullif(btrim(body),'') is null then raise exception 'MG_SCENE_ROLE_MISSING';end if;
  actions:=actions||jsonb_build_array(jsonb_build_object('actor_id',a.id,'role',case when d.kind='difesa' then 'difesa' else 'azione' end,'source_id',sid));
  sources:=sources||jsonb_build_array(jsonb_build_object('id',sid,'session_id',s.id,'round_id',r.id,'kind','role',
   'actor_id',a.id,'sequence',r.round_no,'body',body,'sha256',encode(extensions.digest(convert_to(body,'UTF8'),'sha256'),'hex'),
   'visibility','public','complete',true));
 end loop;
 if (jsonb_array_length(actions)=0 and jsonb_array_length(roleless)=0) or jsonb_array_length(facts)<>jsonb_array_length(rep.mechanics->'declarations')
 then raise exception 'MG_SCENE_BARRIER_INCOMPLETE';end if;
 for item in select value from jsonb_array_elements(coalesce(rep.mechanics->'substitution_receipts','[]')) loop
  narrator:=item->'narrator_payload';
  if item->>'round_id' is distinct from r.id::text or narrator->>'schema_version' is distinct from 'common-substitution-narrator/1.0'
   or not exists(select 1 from jsonb_array_elements(actors) ar where ar->>'id'=item->>'actor_id')
  then raise exception 'MG_SCENE_SUBSTITUTION_CHANGED';end if;
  spatial:=spatial||jsonb_build_array(jsonb_build_object('actor_id',item->'actor_id','kind','substitution',
   'outcome',narrator#>'{impact,outcome}','anchor',narrator#>'{anchor,semantic_label}','after',narrator#>'{after,semantic_region}'));
 end loop;
 select count(*) into prior_count from public.combat_v2_narratives n join public.combat_v2_rounds old on old.id=n.round_id
   join public.combat_v2_round_reports q on q.id=n.report_id where old.session_id=s.id and old.round_no<r.round_no
   and old.state='narrato' and q.narration_state='pubblicata';
 if mission_generic_owner.flow_scope_enabled(p_session) then
  continuity_snapshot:=mission_generic_owner.continuity_snapshot(p_session);
 end if;
 snapshot:=jsonb_build_object('schema_version','combat-scene/1','session_id',s.id,'round_id',r.id,
  'report_sha256',rep.mechanics_sha256,'control_version',run.control_version,'location',loc,'actors',actors,'actions',actions,
  'resolved_facts',jsonb_build_object('schema_version','mission-generic-resolved-facts/1','round_no',r.round_no,
   'declarations',facts,'spatial',spatial)::text,'sources',sources,
  'selection',jsonb_build_object('max_input_bytes',input_cap,'previous_available',prior_count,'previous_included',0));
 if octet_length(snapshot::text)>input_cap then raise exception 'MG_SCENE_REQUIRED_CONTEXT_OVERFLOW' using errcode='54000';end if;
 if not mission_generic_owner.flow_scope_enabled(p_session) then
 for row in select n.id,n.round_id,n.body,old.round_no,q.message_id from public.combat_v2_narratives n
  join public.combat_v2_rounds old on old.id=n.round_id and old.session_id=s.id
  join public.combat_v2_round_reports q on q.id=n.report_id and q.round_id=old.id
  where old.round_no<r.round_no and old.state='narrato' and q.narration_state='pubblicata' and not exists(select 1 from mission_generic_owner.unified_report_publications urp where urp.report_id=q.id and not urp.primary_report) order by old.round_no desc,n.id loop
  if not exists(select 1 from public.messages m where m.id=row.message_id and m.location_id=place.id and m.body=row.body
    and m.character_id is null and m.sender_user is null and m.recipient_user is null and m.kind='fato')
  then raise exception 'MG_SCENE_PREVIOUS_CHANGED';end if;
  candidate:=jsonb_set(snapshot,'{sources}',snapshot->'sources'||jsonb_build_array(jsonb_build_object('id',row.id,
   'session_id',s.id,'round_id',row.round_id,'kind','fato','actor_id',null,'sequence',row.round_no,'body',row.body,
   'sha256',encode(extensions.digest(convert_to(row.body,'UTF8'),'sha256'),'hex'),'visibility','public','complete',true)));
  candidate:=jsonb_set(candidate,'{selection,previous_included}',to_jsonb(included+1));
  if octet_length(candidate::text)<=input_cap then snapshot:=candidate;included:=included+1;end if;
 end loop;
 end if;
 scenehash:=public.combat_v2_sha256(snapshot);
 payload:=jsonb_build_object('schema_version',case when director is null then 'mission-generic-narration/1' else 'mission-generic-narration/2' end,
   'mode','combat','scene',jsonb_build_object('snapshot',snapshot,'snapshot_sha256',scenehash),
   'scene_binding',jsonb_build_object('session_id',s.id,'round_id',r.id,'report_sha256',rep.mechanics_sha256,
    'control_version',run.control_version,'hash_authority','combat_v2_sha256/jsonb','scene_sha256',scenehash),
   'barrier',jsonb_build_object('closed',true,'required_receipt_ids',jsonb_build_array(rep.id),'receipt_ids',jsonb_build_array(rep.id)));
 if director is not null then
  payload:=payload||jsonb_build_object('director_context',director,'knowledge_context',knowledge_context,
   'source_cursor',jsonb_build_object('scope','combat_declarations','through',r.resolved_at));
 end if;
 if continuity_snapshot is not null then
  payload:=payload||jsonb_build_object('continuity',continuity_snapshot->'continuity',
   'history_chain_sha256',continuity_snapshot->'history_chain_sha256',
   'history_count',continuity_snapshot->'history_count',
   'continuity_delta',continuity_snapshot->'delta');
 end if;
 if jsonb_array_length(roleless)>0 then payload:=payload||jsonb_build_object('roleless_declarations',roleless);end if;
 return jsonb_build_object('master_session_id',p_session,'step_key',run.current_step_key,'run_control_version',run.control_version,
  'encounter_id',s.id,'authority_receipt_id',rep.id,'payload',payload);
end $$;
CREATE OR REPLACE FUNCTION mission_generic_owner.combat_publish(p_work uuid, p_text text, p_request uuid) RETURNS jsonb LANGUAGE plpgsql SECURITY DEFINER SET search_path TO '' AS $$
declare w mission_generic_owner.work_items%rowtype; source jsonb; result jsonb;route56 jsonb;tr56 mission_generic_owner.trigger_receipts;ev56 public.mission_run_events;ob56 public.mission_run_outbox;pub56 uuid;sha56 text;
begin
 if auth.uid() is not null or not public.combat_v2_is_service() then raise exception 'MG_SERVICE_REQUIRED' using errcode='42501';end if;
 select * into strict w from mission_generic_owner.work_items where id=p_work for update;
 if w.kind<>'narration' or w.payload->>'mode'<>'combat' or w.state<>'provider_started' or w.request_key<>p_request
  or w.lease_expires_at<=clock_timestamp() or w.payload_sha256<>public.combat_v2_sha256(w.payload)
 then raise exception 'MG_PUBLISH_WORK_INVALID';end if;
 source:=mission_generic_owner.combat_narrative_source(w.master_session_id,w.authority_receipt_id);
 if source->'payload' is distinct from w.payload then raise exception 'MG_PUBLISH_SOURCE_CHANGED';end if;
 result:=public.combat_v2_narrative_store((w.payload#>>'{scene_binding,round_id}')::uuid,'fato_ia',p_text,p_request,null);
 IF EXISTS(SELECT 1 FROM mission_narrative_internal.scene_runtime_v1 WHERE master_session_id=w.master_session_id AND is_active)
  AND EXISTS(SELECT 1 FROM public.combat_v2_sessions WHERE id=w.encounter_id AND state='risolto') THEN
  route56:=mission_generic_owner.advance_combat_terminal(w.master_session_id,w.encounter_id);
  SELECT * INTO STRICT tr56 FROM mission_generic_owner.trigger_receipts WHERE id=(route56->>'authority_receipt_id')::uuid AND master_session_id=w.master_session_id;
  SELECT * INTO STRICT ev56 FROM public.mission_run_events WHERE id=(tr56.result->>'event_id')::uuid AND status='committed';
  SELECT * INTO STRICT ob56 FROM public.mission_run_outbox WHERE event_id=ev56.id AND state='pending' FOR UPDATE;
  IF ob56.master_session_id<>w.master_session_id OR ob56.context_fingerprint<>ev56.context_fingerprint
   OR ob56.step_key<>ev56.step_after OR ob56.event_version_after<>ev56.version_after THEN
   RAISE EXCEPTION 'SCENE56_COMBAT_TERMINAL_OUTBOX_CHANGED' USING ERRCODE='PT409';END IF;
  sha56:=encode(extensions.digest(convert_to(p_text,'UTF8'),'sha256'),'hex');pub56:=gen_random_uuid();
  INSERT INTO public.mission_run_publications(id,master_session_id,event_id,request_key_sha256,request_fingerprint,source,
   expected_run_control_version,expected_event_version_after,expected_step_key,context_fingerprint,body_sha256,status)
  VALUES(pub56,w.master_session_id,ev56.id,mission_internal.request_key_sha256(p_request),
   mission_internal.fingerprint(jsonb_build_object('work',w.id,'report',w.authority_receipt_id,'body',sha56)),
   'model',ev56.version_after,ev56.version_after,ev56.step_after,ev56.context_fingerprint,sha56,'committed');
  INSERT INTO public.mission_run_messages(publication_id,message_id,body_sha256) VALUES(pub56,(result#>>'{data,message_id}')::uuid,sha56);
  PERFORM set_config('app.mission_outbox_publish','on',true);
  UPDATE public.mission_run_outbox SET state='published',publication_id=pub56,published_at=clock_timestamp() WHERE event_id=ev56.id;
  PERFORM set_config('app.mission_outbox_publish','off',true);
 END IF;
 return (result->'data')||CASE WHEN route56 IS NULL THEN '{}'::jsonb ELSE jsonb_build_object('transition',route56) END;
end $$;
CREATE OR REPLACE FUNCTION public.mission_generic_dispatch_finalize_v1(p_work uuid, p_finalize_token text, p_result_text text, p_result_sha text) RETURNS jsonb LANGUAGE plpgsql SECURITY DEFINER SET search_path TO '' SET statement_timeout TO '30s' AS $$
declare w mission_generic_owner.work_items;d mission_narrative_internal.dispatch_receipts;z mission_narrative_internal.provider_authorizations;
 pol mission_narrative_internal.runtime_policy;a mission_narrative_internal.dispatch_attempts;
 ok boolean;stale boolean:=false;metrics jsonb;actual numeric;basis text;receipt uuid:=gen_random_uuid();msg uuid;cr jsonb;
 p_result jsonb;tr mission_generic_owner.trigger_receipts;ev public.mission_run_events;ob public.mission_run_outbox;
 publication uuid;bodysha text;bs mission_generic_owner.board_starts;
 application_error text;application_error_code text;outcome_uncertain boolean:=false;stale_role boolean:=false;role_revision text;
 retained mission_narrative_internal.provider_outputs_v1; admission jsonb; free_prose boolean:=false; raw_json jsonb; carried jsonb;
 c726_factory_settlement boolean:=false;shared_on boolean;shared_call staff_ai_quota_private.calls%rowtype;
begin
 perform mission_ai_board_owner.service_only();
 IF EXISTS(SELECT 1 FROM mission_narrative_internal.scene_runtime_v1 scene56 JOIN mission_generic_owner.work_items work56 ON work56.master_session_id=scene56.master_session_id WHERE work56.id=p_work AND scene56.is_active) THEN
  PERFORM 1 FROM public.locations WHERE id=(SELECT m56.location_id FROM public.master_v2_sessions m56 JOIN mission_generic_owner.work_items w56 ON w56.master_session_id=m56.id WHERE w56.id=p_work) FOR UPDATE;
 END IF;
 if exists(select 1 from mission_generic_owner.role_window_cursors c
   where c.master_session_id=(select master_session_id from mission_generic_owner.work_items where id=p_work)) then
   perform 1 from mission_generic_owner.role_window_cursors c
     where c.master_session_id=(select master_session_id from mission_generic_owner.work_items where id=p_work)
     for update;
   IF NOT EXISTS(SELECT 1 FROM mission_generic_owner.work_items WHERE id=p_work AND kind='narration' AND payload->>'schema_version'='mission-narrative-scene/1' AND payload->>'mode'='narrative_scene') THEN
   role_revision:=mission_generic_owner.role_source_revision_v1(
     (select master_session_id from mission_generic_owner.work_items where id=p_work));
   END IF;
 end if;
 perform 1 from public.locations where id=(select q.location_id from mission_factory_owner.quest_run_sources q join mission_generic_owner.work_items wi_lock on wi_lock.master_session_id=q.session_id where wi_lock.id=p_work) for update;
 perform 1 from public.master_v2_sessions where id=(select master_session_id from mission_generic_owner.work_items where id=p_work) for update;
 if p_result_text is null or octet_length(p_result_text)>65536
 or encode(extensions.digest(convert_to(p_result_text,'UTF8'),'sha256'),'hex') is distinct from p_result_sha
 then raise exception 'MGD_RESULT_HASH';end if;
 p_result:=p_result_text::jsonb;
 select * into strict w from mission_generic_owner.work_items where id=p_work for update;
 if w.state in('completed','failed','uncertain') then
  if w.state='completed'
    and w.kind='narration'
    and w.payload->>'schema_version'='mission-generic-narration/4' then
    if not exists(select 1 from mission_generic_owner.unified_segment_publications_v4 pub
      where pub.work_id=w.id and pub.raw_result_sha256=p_result_sha)
    then raise exception 'MGD_FINALIZE_CONFLICT' using errcode='40001';end if;
  elsif w.result_sha256 is distinct from p_result_sha then
    raise exception 'MGD_FINALIZE_CONFLICT' using errcode='40001';
  end if;
  return mission_generic_owner.work_status(w);
 end if;
 select * into strict d from mission_narrative_internal.dispatch_receipts where id=w.dispatch_receipt_id for update;
 select * into strict z from mission_narrative_internal.provider_authorizations where id=w.authorization_id and receipt_id=d.id for update;
 select * into strict a from mission_narrative_internal.dispatch_attempts where id=z.attempt_id for update;
 select * into strict pol from mission_narrative_internal.runtime_policy where singleton for share;
 if w.state<>'provider_started' or d.status<>'provider_started' or z.finalize_token_sha256 is distinct from mission_narrative_internal.token_sha(p_finalize_token)
 or p_result->>'schema_version' is distinct from (case when w.payload->>'schema_version'='mission-generic-narration/4' then 'mission-generic-result/2' else 'mission-generic-result/1' end) or p_result->>'work_id' is distinct from w.id::text
 or p_result->>'master_session_id' is distinct from w.master_session_id::text or p_result->>'event_id' is distinct from w.event_id::text
 or p_result->>'request_key' is distinct from w.request_key::text or (p_result->>'revision')::bigint is distinct from w.revision
 or p_result->>'authority_receipt_id' is distinct from w.authority_receipt_id::text or p_result->>'definition_sha256' is distinct from w.definition_sha256
 or p_result->>'payload_sha256' is distinct from w.payload_sha256 or p_result->>'kind' is distinct from w.kind
 or p_result->>'authorization_id' is distinct from w.authorization_id::text or p_result->>'dispatch_id' is distinct from w.dispatch_id::text
 or p_result->>'model' is distinct from pol.model or coalesce(p_result_sha,'')!~'^[0-9a-f]{64}$'
 or p_result->>'runtime_version' is distinct from (case when w.payload->>'schema_version'='mission-generic-narration/4' then 'mission-generic-runtime/2' else 'mission-generic-runtime/1' end)
 or p_result->>'provider_calls' not in('0','1')
 or jsonb_typeof(p_result->'outcome_uncertain') is distinct from 'boolean'
 or (p_result->>'outcome_uncertain'='true' and p_result->>'ok' is distinct from 'false')
 or (p_result->>'ok'='true' and p_result->>'provider_calls' is distinct from '1')
 then raise exception 'MGD_FINALIZE_BINDING';end if;
 SELECT EXISTS(SELECT 1 FROM staff_ai_quota_private.calls qc726 JOIN mission_generic_owner.dispatch_admissions da726 ON da726.master_session_id=w.master_session_id JOIN mission_generic_owner.run_bindings rb726 ON rb726.master_session_id=da726.master_session_id WHERE qc726.producer='mission_generic_ai' AND qc726.source_id=d.id AND qc726.call_no=1 AND qc726.scope_id=w.master_session_id AND qc726.state IN('reserved','sent','unknown_billable') AND da726.c7_budget_enforced AND da726.call_limit=14 AND da726.cost_budget_usd=0.3136 AND da726.c8_count_upper_cost_usd=0.0112 AND da726.c8_count_qualification_sha256~'^[a-f0-9]{64}$' AND rb726.snapshot_sha256=mission_internal.fingerprint(rb726.snapshot) AND da726.c7_budget_qualification_sha256=encode(extensions.digest(convert_to(jsonb_build_object('schema_version','c717-native-staff-admission-proof/1','count_contract_sha256','b242ee7fcc6655fa951e8697acfbee4d6ba92b42b177fcbcf6a9b08d004661b2','session_id',w.master_session_id,'binding_sha256',rb726.snapshot_sha256,'count_qualification_sha256',da726.c8_count_qualification_sha256,'generation_limit',14,'http_limit',28,'cost','0.3136')::text,'UTF8'),'sha256'),'hex')) INTO c726_factory_settlement;

 if (d.envelope->'narrative_admission') is distinct from mission_public_owner.work_contract_v1(w.id)
 then raise exception 'NARRATIVE_FINALIZE_ADMISSION_BINDING' using errcode='40001';end if;
 -- The exact canonical string is hashed before JSONB parsing; no JS/JSONB equivalence assumption.
 metrics:=p_result->'usage';
 if jsonb_typeof(metrics) is distinct from 'object' then metrics:='{}';end if;
 if jsonb_typeof(metrics)='object' and mission_generic_owner.keys_valid(metrics,array['input_tokens','output_tokens','reasoning_tokens','total_tokens'])
 and not exists(select 1 from jsonb_each_text(metrics) where value!~'^[0-9]+$')
 and (metrics->>'reasoning_tokens')::numeric<=(metrics->>'output_tokens')::numeric
 and (metrics->>'total_tokens')::numeric=(metrics->>'input_tokens')::numeric+(metrics->>'output_tokens')::numeric then
  actual:=((metrics->>'input_tokens')::numeric*pol.input_usd_million+(metrics->>'output_tokens')::numeric*pol.output_usd_million)/1000000;basis:='exact';
 else actual:=d.upper_bound_cost_usd;basis:='upper_bound';end if;
 if actual>d.upper_bound_cost_usd then stale:=true;end if;
 
begin perform mission_generic_owner.work_assert(w); exception when others then stale:=true;end;
if role_revision is not null then
  if w.kind='director'
     and w.payload#>>'{context,source_revision}' is distinct from role_revision then
    stale_role:=true;stale:=true;
  elsif w.kind='narration' and w.payload->>'schema_version'='mission-generic-narration/4'
     and w.payload->>'source_revision' is distinct from role_revision then
    stale_role:=true;stale:=true;
  end if;
end if;

 outcome_uncertain:=(p_result->>'outcome_uncertain')::boolean;
 ok:=coalesce((p_result->>'ok')::boolean,false) and not outcome_uncertain and not stale and w.lease_expires_at>clock_timestamp();
 admission:=mission_public_owner.work_contract_v1(w.id);
 free_prose:=coalesce(admission->'features' ? 'free_narrative_v1',false);
 -- Result application is a subtransaction: failures roll back every domain write,
 -- while the outer transaction still records the provider receipt and real cost.
 begin
 IF ok AND admission->'features' ? 'provider_output_retention_v1' THEN
  SELECT * INTO STRICT retained FROM mission_narrative_internal.provider_outputs_v1 r
    WHERE r.id=(p_result->>'output_receipt_id')::uuid AND r.work_id=w.id
      AND r.authorization_id=w.authorization_id AND r.dispatch_id=w.dispatch_id
      AND r.dispatch_receipt_id=w.dispatch_receipt_id AND r.raw_sha256=p_result->>'raw_sha256';
  IF retained.raw_sha256<>encode(extensions.digest(convert_to(retained.raw_output,'UTF8'),'sha256'),'hex')
  THEN RAISE EXCEPTION 'MGD_RETAINED_OUTPUT_HASH';END IF;
 END IF;
 IF ok AND free_prose THEN
  IF w.kind<>'narration' OR w.payload->>'schema_version'<>'mission-generic-narration/4'
    OR NOT(admission->'features' ? 'provider_output_retention_v1')
  THEN RAISE EXCEPTION 'MGD_FREE_PROSE_SCOPE';END IF;
  raw_json:=retained.raw_output::jsonb;
  IF jsonb_typeof(raw_json->'testo') IS DISTINCT FROM 'string'
    OR btrim(raw_json->>'testo')='' OR p_result->>'text' IS DISTINCT FROM raw_json->>'testo'
  THEN RAISE EXCEPTION 'MGD_FREE_PROSE_TEXT_BINDING';END IF;
  carried:=w.payload#>'{source_context,continuity}';
  IF jsonb_typeof(carried) IS DISTINCT FROM 'object' THEN carried:='{"state":"","known":[],"open":[],"used":[]}'::jsonb;END IF;
  carried:=jsonb_build_object('state',carried->'state','known',carried->'known','open',carried->'open','used',carried->'used');
  p_result:=p_result||jsonb_build_object('text',null,'profile_audit',null,
    'segments',jsonb_build_array(jsonb_build_object('kind','prose','text',raw_json->>'testo','slot_id',null,'actor_key',null))||
      coalesce((SELECT jsonb_agg(jsonb_build_object('kind','offense_slot','text',null,'slot_id',slot->>'slot_id','actor_key',slot->>'actor_key') ORDER BY slot->>'actor_key') FROM jsonb_array_elements(w.payload->'offense_slots') slot),'[]'::jsonb),
    'continuity_draft',carried,'history_anchor',jsonb_build_object('chain_sha256',w.payload#>>'{source_context,history_chain_sha256}','count',(w.payload#>>'{source_context,history_count}')::bigint));
 END IF;
 if ok AND w.kind='narration' AND EXISTS(SELECT 1 FROM mission_narrative_internal.scene_runtime_v1 WHERE master_session_id=w.master_session_id AND is_active) THEN
  NULL; -- N56 has technical/Native publication checks; editorial repetition never blocks a paid turn.
 elsif ok and w.kind='narration' and mission_generic_owner.flow_scope_enabled(w.master_session_id)
    and w.payload->>'schema_version' is distinct from 'mission-generic-narration/4' then
  if jsonb_typeof(p_result->'text') is distinct from 'string' then raise exception 'MGD_NARRATIVE_TEXT_SHAPE';end if;
  perform mission_generic_owner.assert_no_literal_reuse(w.master_session_id,p_result->>'text');
 end if;
 if ok and w.kind='director' then
  if p_result->'command' is distinct from 'null'::jsonb or p_result->'text' is distinct from 'null'::jsonb
  then raise exception 'MUF_DIRECTOR_RESULT_SHAPE';end if;
  cr:=mission_generic_owner.unified_director_commit(w.id,p_result->'decision');
 elsif ok AND w.kind='narration' AND w.payload->>'schema_version'='mission-narrative-scene/1' AND w.payload->>'mode'='narrative_scene' THEN
  cr:=mission_narrative_internal.scene_publish_v1(w.id,p_result);msg:=(cr->>'message_id')::uuid;
 elsif ok and w.kind='narration' and w.payload->>'mode'='unified' then
  if w.payload->>'schema_version'='mission-generic-narration/4' then
    cr:=mission_generic_owner.unified_publish_v4(w.id,p_result,w.request_key,p_result_sha);
    msg:=(cr->>'message_id')::uuid;
    p_result:=p_result||jsonb_build_object('text',cr->>'text','continuity',cr->'continuity');
  else
    if jsonb_typeof(p_result->'text') is distinct from 'string' then raise exception 'MUF_WRITER_RESULT_SHAPE';end if;
    cr:=mission_generic_owner.unified_publish(w.id,p_result->>'text',w.request_key);msg:=(cr->>'message_id')::uuid;
  end if;
  IF EXISTS(SELECT 1 FROM mission_narrative_internal.scene_runtime_v1 WHERE master_session_id=w.master_session_id AND is_active) THEN
   PERFORM mission_narrative_internal.scene_combat_publication_sync_v1(w.id,msg,cr);
  END IF;
 elsif ok and w.kind='choice' then
  if p_result ? 'peaceful_exit' then
   if not mission_generic_owner.keys_valid(p_result->'peaceful_exit',
      array['schema_version','intent','pg_declaration_ids','agreement_summary'])
    or p_result#>>'{peaceful_exit,schema_version}' is distinct from 'mission-peaceful-proposal/1'
    or p_result#>>'{peaceful_exit,intent}' not in ('none','accept')
    or jsonb_typeof(p_result#>'{peaceful_exit,pg_declaration_ids}') is distinct from 'array'
    or jsonb_typeof(p_result#>'{peaceful_exit,agreement_summary}') is distinct from 'string'
    or (p_result#>>'{peaceful_exit,intent}'='none' and
      (jsonb_array_length(p_result#>'{peaceful_exit,pg_declaration_ids}')<>0
       or p_result#>>'{peaceful_exit,agreement_summary}'<>''))
    or (p_result#>>'{peaceful_exit,intent}'='accept' and
      (jsonb_array_length(p_result#>'{peaceful_exit,pg_declaration_ids}')=0
       or length(btrim(p_result#>>'{peaceful_exit,agreement_summary}')) not between 8 and 500))
   then raise exception 'MUP_CHOICE_PEACEFUL_SHAPE';end if;
  end if;
  if d.envelope#>>'{narrative_admission,schema_version}' IN('mission-narrative-admission/2','mission-narrative-admission/3') then
   cr:=mission_public_owner.choice_commit_v2(w.id,(w.payload->>'capability_id')::uuid,p_result->'command',p_result->'peaceful_exit');
  else
   cr:=mission_generic_owner.choice_commit(w.id,(w.payload->>'capability_id')::uuid,p_result->'command');
  end if;
  if cr is null or not exists(select 1 from mission_generic_owner.panel_choices pc
   join combat_panel_private.request_receipts rr on rr.principal_user=pc.principal_id and rr.request_key=pc.request_key
   where pc.work_id=w.id and pc.id=(w.payload->>'capability_id')::uuid and pc.consumed_at is not null
    and pc.result=cr and rr.viewer_envelope=cr and rr.event_id is not null
    and rr.offer_id=(p_result#>>'{command,offer_id}')::uuid
    and pc.command_sha256=public.combat_v2_sha256(combat_panel_private.validate_command(p_result->'command')))
  then raise exception 'MGD_COMMAND_RECEIPT_MISSING';end if;
 elsif ok then
  if w.payload#>>'{barrier,closed}' is distinct from 'true'
   or exists(select 1 from jsonb_array_elements_text(w.payload#>'{barrier,required_receipt_ids}') id
    where not(w.payload#>'{barrier,receipt_ids}' ? id))
   or jsonb_typeof(p_result->'text') is distinct from 'string' or length(btrim(p_result->>'text')) not between 1 and 5000
  then raise exception 'MGD_NARRATIVE_BARRIER';end if;
  if w.payload->>'source_kind'='quest' and w.payload#>>'{quest_lifecycle,phase}' in('opening','terminal') then
   cr:=mission_factory_owner.quest_work_publish_v1(w.id,p_result->>'text');
   msg:=(cr->>'message_id')::uuid;
   if msg is null then raise exception 'MF_QUEST_PUBLICATION_MESSAGE_MISSING';end if;
  elsif w.payload->>'mode'='combat' then
   cr:=mission_generic_owner.combat_publish(w.id,p_result->>'text',w.request_key);
   msg:=(cr->>'message_id')::uuid;
   if msg is null or not exists(select 1 from public.messages m join public.master_v2_sessions s on s.location_id=m.location_id
    where s.id=w.master_session_id and m.id=msg) then raise exception 'MGD_COMBAT_PUBLICATION_MISSING';end if;
   IF EXISTS(SELECT 1 FROM mission_narrative_internal.scene_runtime_v1 WHERE master_session_id=w.master_session_id AND is_active) THEN
    PERFORM mission_narrative_internal.scene_combat_publication_sync_v1(w.id,msg,cr);
   END IF;
  elsif w.payload->>'mode'='mission' then
   insert into public.messages(location_id,character_id,author_name,body,kind,sender_user,recipient_user,created_at)
   select location_id,null,'Fato',p_result->>'text','fato',null,null,clock_timestamp() from public.master_v2_sessions where id=w.master_session_id returning id into msg;
   if w.payload ? 'opening_start_receipt_id' then
    select * into strict bs from mission_generic_owner.board_starts where id=w.authority_receipt_id and master_session_id=w.master_session_id for update;
    select * into strict ev from public.mission_run_events where id=bs.event_id and master_session_id=w.master_session_id for update;
   else
    select * into strict tr from mission_generic_owner.trigger_receipts where id=w.authority_receipt_id and master_session_id=w.master_session_id;
    select * into strict ev from public.mission_run_events where id=(tr.result->>'event_id')::uuid and master_session_id=w.master_session_id for update;
   end if;
   select * into strict ob from public.mission_run_outbox where event_id=ev.id and master_session_id=w.master_session_id for update;
   if ev.status<>'committed' or ob.state<>'pending' or ev.version_after<>w.run_control_version
    or ob.event_version_after<>ev.version_after or ev.step_after<>w.step_key or ob.step_key<>w.step_key
    or ob.context_fingerprint<>ev.context_fingerprint then raise exception 'MGD_OUTBOX_STALE';end if;
   bodysha:=encode(extensions.digest(convert_to(p_result->>'text','UTF8'),'sha256'),'hex');
   publication:=gen_random_uuid();
   insert into public.mission_run_publications(id,master_session_id,event_id,request_key_sha256,request_fingerprint,source,
    expected_run_control_version,expected_event_version_after,expected_step_key,context_fingerprint,body_sha256,status)
   values(publication,w.master_session_id,ev.id,mission_internal.request_key_sha256(w.request_key),
    mission_internal.fingerprint(jsonb_build_object('schema_version','mission-generic-publication/1','work_id',w.id,'event_id',ev.id,
    'payload_sha256',w.payload_sha256,'body_sha256',bodysha)),'model',w.run_control_version,ev.version_after,w.step_key,ev.context_fingerprint,bodysha,'committed');
   insert into public.mission_run_messages(publication_id,message_id,body_sha256) values(publication,msg,bodysha);
   -- Same guarded outbox transition as native publication; no invented reveal grants.
   perform set_config('app.mission_outbox_publish','on',true);
   update public.mission_run_outbox set state='published',publication_id=publication,published_at=clock_timestamp() where event_id=ev.id;
   perform set_config('app.mission_outbox_publish','off',true);
   if w.payload ? 'opening_start_receipt_id' then
    perform mission_generic_owner.opening_published(w.master_session_id,publication);
   end if;
  else raise exception 'MGD_NARRATIVE_MODE';
  end if;
 end if;
 exception when others then
  application_error:=SQLSTATE;
  application_error_code:=case when SQLSTATE='22023' and SQLERRM='MG_FATO_LITERAL_REPETITION' then 'MG_FATO_LITERAL_REPETITION'
   WHEN SQLSTATE IN('P0001','40001','42501') AND SQLERRM IN('C1266_PEER_BATCH_PROVENANCE','C1266_PEER_CONTRACT_BINDING','C1266_PEER_EVIDENCE_BINDING','C1266_PEER_FEATURE_SCOPE','C1266_PEER_INTERPRETATION_VERSION_REQUIRED','C1266_PEER_NULL_REQUIRED','C1266_PEER_ORDER_BINDING','C1266_PEER_ORDER_COVERAGE','C1266_PEER_OWN_MOVEMENT_REQUIRED','C1266_PEER_REFERENCE_BINDING','C1266_PEER_REFERENCE_SHAPE','C1266_PEER_SUBMISSION_ORDER_BINDING','C1266_PEER_TEMPORAL_SHAPE','C1266_PEER4_BATCH_FULL_PROJECTION','C1266_PEER4_EFFECT_INVALID','C1266_PEER4_IMMEDIATE_ANCHOR','C1266_PEER4_IMMEDIATE_LIMIT','C1266_PEER4_IMMEDIATE_SHAPE','C1266_PEER4_PROJECTION_IMMEDIATE','C1266_PEER4_ROLE_BINDING','C1266_PEER4_UNKNOWN_BINDING','C1266_PEER4_UNKNOWN_EVIDENCE','C1266_PEER4_VALID_ROSTER_REQUIRED','C1266_PEER4_WRITER_FULL_PROJECTION')
    AND EXISTS(SELECT 1 FROM mission_public_owner.work_contracts_v1 peer_wc
 JOIN mission_factory_owner.editor_release_readiness peer_rr ON peer_rr.singleton
 WHERE peer_wc.work_id=w.id AND peer_wc.master_session_id=w.master_session_id AND peer_wc.scope='staff_mission'
 AND peer_wc.contract_sha256=public.combat_v2_sha256(peer_wc.contract)
 AND peer_wc.contract->>'schema_version'='mission-narrative-admission/3'
 AND peer_wc.contract->'features' ? 'role_intents_v2'
 AND peer_wc.contract->'features' ? 'execution_authority_v1'
 AND peer_wc.contract#>>'{source_attestation,role_intents,schema_version}'='mission-role-intent-attestation/4'
 AND peer_wc.contract#>>'{source_attestation,role_intents,temporal_contract_sha256}'='0603ab23e76750b5babeb41421bc84b551b959945f21267ffd7169140732f1e8'
 AND peer_wc.contract#>>'{source_attestation,role_intents,peer_confirmation,schema_version}'='mission-peer-confirmation-contract/2'
 AND (peer_wc.contract#>>'{source_attestation,execution_authority,schema_version}'='c1266-work-execution-attestation/1' OR ((mission_generic_owner.c1266_historical_work_v1(peer_wc.work_id)->>'schema_version'='c1266-work-execution-attestation/2') AND peer_wc.contract#>'{source_attestation,execution_authority}'=mission_generic_owner.c1266_historical_work_v1(peer_wc.work_id)))
 AND peer_wc.contract#>>'{source_attestation,execution_authority,execution_context}'='staff_mission'
 AND peer_wc.contract#>>'{source_attestation,execution_authority,admission,kind}'='staff_finite'
 AND peer_wc.contract#>>'{source_attestation,execution_authority,admission,resource_scope}'='staff_simulation'
 AND (peer_wc.contract#>>'{source_attestation,execution_authority,source_scope,mission_id}'='5878822d-dc03-4ac2-ad0b-1547f0ab3fc0' OR ((mission_generic_owner.c1266_historical_work_v1(peer_wc.work_id)->>'schema_version'='c1266-work-execution-attestation/2') AND peer_wc.contract#>'{source_attestation,execution_authority}'=mission_generic_owner.c1266_historical_work_v1(peer_wc.work_id)))
 AND peer_wc.contract#>>'{source_attestation,execution_authority,admission,location_id}'='0b85f354-9cdb-47e1-baf9-3d266bb7e06b'
 AND peer_wc.contract#>>'{source_attestation,execution_authority,release_sha256}'=peer_wc.release_sha256
 AND peer_wc.contract#>>'{source_attestation,execution_authority,binding_sha256}'=peer_wc.definition_sha256
 AND (peer_rr.revision_sha256=peer_wc.release_sha256 OR ((mission_generic_owner.c1266_historical_work_v1(peer_wc.work_id)->>'schema_version'='c1266-work-execution-attestation/2') AND peer_wc.contract#>'{source_attestation,execution_authority}'=mission_generic_owner.c1266_historical_work_v1(peer_wc.work_id)))
 AND ((CASE WHEN ((mission_generic_owner.c1266_historical_work_v1(peer_wc.work_id)->>'schema_version'='c1266-work-execution-attestation/2') AND peer_wc.contract#>'{source_attestation,execution_authority}'=mission_generic_owner.c1266_historical_work_v1(peer_wc.work_id)) THEN mission_generic_owner.c1266_historical_work_v1(peer_wc.work_id)#>>'{source_qualification,campaign_id}' ELSE peer_rr.canonical_preimage::jsonb#>>'{config,c1266_staff_campaign,campaign_id}' END)='7ce1a932-d339-5914-93d1-3f4698686c2c' OR (CASE WHEN ((mission_generic_owner.c1266_historical_work_v1(peer_wc.work_id)->>'schema_version'='c1266-work-execution-attestation/2') AND peer_wc.contract#>'{source_attestation,execution_authority}'=mission_generic_owner.c1266_historical_work_v1(peer_wc.work_id)) THEN mission_generic_owner.c1266_historical_work_v1(peer_wc.work_id)#>>'{source_qualification,campaign_id}' ELSE peer_rr.canonical_preimage::jsonb#>>'{config,c1266_staff_campaign,campaign_id}' END)='e3579a26-560d-5d1d-bfbd-649df53a73c7' OR (CASE WHEN ((mission_generic_owner.c1266_historical_work_v1(peer_wc.work_id)->>'schema_version'='c1266-work-execution-attestation/2') AND peer_wc.contract#>'{source_attestation,execution_authority}'=mission_generic_owner.c1266_historical_work_v1(peer_wc.work_id)) THEN mission_generic_owner.c1266_historical_work_v1(peer_wc.work_id)#>>'{source_qualification,campaign_id}' ELSE peer_rr.canonical_preimage::jsonb#>>'{config,c1266_staff_campaign,campaign_id}' END)='a85c7787-7cd4-4998-9ecc-8086e2c84d7b' OR (CASE WHEN ((mission_generic_owner.c1266_historical_work_v1(peer_wc.work_id)->>'schema_version'='c1266-work-execution-attestation/2') AND peer_wc.contract#>'{source_attestation,execution_authority}'=mission_generic_owner.c1266_historical_work_v1(peer_wc.work_id)) THEN mission_generic_owner.c1266_historical_work_v1(peer_wc.work_id)#>>'{source_qualification,campaign_id}' ELSE peer_rr.canonical_preimage::jsonb#>>'{config,c1266_staff_campaign,campaign_id}' END)='b2fc5e28-072b-41f2-8dd8-cb5a35a13092')
 AND (peer_wc.contract#>>'{source_attestation,execution_authority,admission,grant_id}'=peer_rr.canonical_preimage::jsonb#>>'{config,c1266_staff_campaign,grant_id}' OR ((mission_generic_owner.c1266_historical_work_v1(peer_wc.work_id)->>'schema_version'='c1266-work-execution-attestation/2') AND peer_wc.contract#>'{source_attestation,execution_authority}'=mission_generic_owner.c1266_historical_work_v1(peer_wc.work_id)))
 AND ((w.kind='director' AND w.payload->>'schema_version'='mission-director-work/4' AND w.payload#>>'{peer_confirmation,schema_version}'='mission-peer-confirmation-contract/2') OR(w.kind='narration' AND w.payload->>'schema_version'='mission-generic-narration/4' AND w.payload->>'mode'='unified' AND w.payload#>>'{role_interpretation,schema_version}'='mission-role-interpretation/4' AND w.payload#>>'{role_disposition,schema_version}'='mission-role-disposition/4'))) THEN SQLERRM
   WHEN SQLSTATE IN('P0001','40001','42501') AND SQLERRM IN('C1266_PEER_BATCH_PROVENANCE','C1266_PEER_CONTRACT_BINDING','C1266_PEER_EVIDENCE_BINDING','C1266_PEER_FEATURE_SCOPE','C1266_PEER_INTERPRETATION_VERSION_REQUIRED','C1266_PEER_NULL_REQUIRED','C1266_PEER_ORDER_BINDING','C1266_PEER_ORDER_COVERAGE','C1266_PEER_OWN_MOVEMENT_REQUIRED','C1266_PEER_REFERENCE_BINDING','C1266_PEER_REFERENCE_SHAPE','C1266_PEER_SUBMISSION_ORDER_BINDING','C1266_PEER_TEMPORAL_SHAPE')
    AND EXISTS(SELECT 1 FROM mission_public_owner.work_contracts_v1 peer_wc
 JOIN mission_factory_owner.editor_release_readiness peer_rr ON peer_rr.singleton
 WHERE peer_wc.work_id=w.id AND peer_wc.master_session_id=w.master_session_id AND peer_wc.scope='staff_mission'
 AND peer_wc.contract_sha256=public.combat_v2_sha256(peer_wc.contract)
 AND peer_wc.contract->>'schema_version'='mission-narrative-admission/3'
 AND peer_wc.contract->'features' ? 'role_intents_v2'
 AND peer_wc.contract->'features' ? 'execution_authority_v1'
 AND peer_wc.contract#>>'{source_attestation,role_intents,schema_version}'='mission-role-intent-attestation/3'
 AND peer_wc.contract#>>'{source_attestation,role_intents,temporal_contract_sha256}'='3fdeaa942bcf3ba217a976f7b0896f4594721fa45cde9ff8ed7bddf15391feda'
 AND peer_wc.contract#>>'{source_attestation,role_intents,peer_confirmation,schema_version}'='mission-peer-confirmation-contract/1'
 AND (peer_wc.contract#>>'{source_attestation,execution_authority,schema_version}'='c1266-work-execution-attestation/1' OR ((mission_generic_owner.c1266_historical_work_v1(peer_wc.work_id)->>'schema_version'='c1266-work-execution-attestation/2') AND peer_wc.contract#>'{source_attestation,execution_authority}'=mission_generic_owner.c1266_historical_work_v1(peer_wc.work_id)))
 AND peer_wc.contract#>>'{source_attestation,execution_authority,execution_context}'='staff_mission'
 AND peer_wc.contract#>>'{source_attestation,execution_authority,admission,kind}'='staff_finite'
 AND peer_wc.contract#>>'{source_attestation,execution_authority,admission,resource_scope}'='staff_simulation'
 AND (peer_wc.contract#>>'{source_attestation,execution_authority,source_scope,mission_id}'='5878822d-dc03-4ac2-ad0b-1547f0ab3fc0' OR ((mission_generic_owner.c1266_historical_work_v1(peer_wc.work_id)->>'schema_version'='c1266-work-execution-attestation/2') AND peer_wc.contract#>'{source_attestation,execution_authority}'=mission_generic_owner.c1266_historical_work_v1(peer_wc.work_id)))
 AND peer_wc.contract#>>'{source_attestation,execution_authority,admission,location_id}'='0b85f354-9cdb-47e1-baf9-3d266bb7e06b'
 AND peer_wc.contract#>>'{source_attestation,execution_authority,release_sha256}'=peer_wc.release_sha256
 AND peer_wc.contract#>>'{source_attestation,execution_authority,binding_sha256}'=peer_wc.definition_sha256
 AND (peer_rr.revision_sha256=peer_wc.release_sha256 OR ((mission_generic_owner.c1266_historical_work_v1(peer_wc.work_id)->>'schema_version'='c1266-work-execution-attestation/2') AND peer_wc.contract#>'{source_attestation,execution_authority}'=mission_generic_owner.c1266_historical_work_v1(peer_wc.work_id)))
 AND ((CASE WHEN ((mission_generic_owner.c1266_historical_work_v1(peer_wc.work_id)->>'schema_version'='c1266-work-execution-attestation/2') AND peer_wc.contract#>'{source_attestation,execution_authority}'=mission_generic_owner.c1266_historical_work_v1(peer_wc.work_id)) THEN mission_generic_owner.c1266_historical_work_v1(peer_wc.work_id)#>>'{source_qualification,campaign_id}' ELSE peer_rr.canonical_preimage::jsonb#>>'{config,c1266_staff_campaign,campaign_id}' END)='bedc09e2-559b-586d-a38b-cd600b419cd3' OR (CASE WHEN ((mission_generic_owner.c1266_historical_work_v1(peer_wc.work_id)->>'schema_version'='c1266-work-execution-attestation/2') AND peer_wc.contract#>'{source_attestation,execution_authority}'=mission_generic_owner.c1266_historical_work_v1(peer_wc.work_id)) THEN mission_generic_owner.c1266_historical_work_v1(peer_wc.work_id)#>>'{source_qualification,campaign_id}' ELSE peer_rr.canonical_preimage::jsonb#>>'{config,c1266_staff_campaign,campaign_id}' END)='4c316c8c-3d92-5757-815e-dedcb0ac2f24')
 AND (peer_wc.contract#>>'{source_attestation,execution_authority,admission,grant_id}'=peer_rr.canonical_preimage::jsonb#>>'{config,c1266_staff_campaign,grant_id}' OR ((mission_generic_owner.c1266_historical_work_v1(peer_wc.work_id)->>'schema_version'='c1266-work-execution-attestation/2') AND peer_wc.contract#>'{source_attestation,execution_authority}'=mission_generic_owner.c1266_historical_work_v1(peer_wc.work_id)))
 AND ((w.kind='director' AND w.payload->>'schema_version'='mission-director-work/4' AND w.payload#>>'{peer_confirmation,schema_version}'='mission-peer-confirmation-contract/1') OR(w.kind='narration' AND w.payload->>'schema_version'='mission-generic-narration/4' AND w.payload->>'mode'='unified' AND w.payload#>>'{role_interpretation,schema_version}'='mission-role-interpretation/3' AND w.payload#>>'{role_disposition,schema_version}'='mission-role-disposition/3'))) THEN SQLERRM
   else null end;
  ok:=false;msg:=null;cr:=null;publication:=null;
 end;
 if mission_academy_owner.staff_carrier_runtime(w.master_session_id) OR c726_factory_settlement OR mission_generic_owner.c758_admission_proof_v1(w.master_session_id) then
   select enabled into strict shared_on from staff_ai_quota_private.runtime where singleton;
   select * into shared_call from staff_ai_quota_private.calls
       where producer='mission_generic_ai' and source_id=d.id and call_no=1
         and scope_id=w.master_session_id for update;
   if shared_call.id is not null then
     if shared_call.state='reserved' and p_result->>'provider_calls'='0' then
       perform staff_ai_quota_private.no_http(shared_call.id);
       actual:=0;basis:='exact';
     elsif shared_call.state='sent' and basis='exact'
       and p_result->>'provider_calls'='1' then
       perform staff_ai_quota_private.settle(shared_call.id,
         (metrics->>'input_tokens')::integer,(metrics->>'output_tokens')::integer);
     elsif shared_call.state in('sent','unknown_billable') then
       perform staff_ai_quota_private.unknown_billable(shared_call.id);
     else
       raise exception 'STAFF_GENERIC_SETTLEMENT_STATE' using errcode='40001';
     end if;
   elsif shared_on then
     raise exception 'STAFF_GENERIC_SETTLEMENT_MISSING' using errcode='40001';
   end if;
 end if;
 update mission_narrative_internal.dispatch_attempts set status=case when basis='exact' then 'success' else 'unknown_billable' end,
  actual_cost_usd=actual,cost_basis=basis,input_tokens=case when basis='exact' then (metrics->>'input_tokens')::int end,
  output_tokens=case when basis='exact' then (metrics->>'output_tokens')::int end,reasoning_tokens=case when basis='exact' then (metrics->>'reasoning_tokens')::int end,
  total_tokens=case when basis='exact' then (metrics->>'total_tokens')::int end,finalized_at=clock_timestamp() where id=a.id;
 update mission_narrative_internal.dispatch_receipts set status=case when basis='exact' then 'success' else 'unknown_billable' end,
  charged_cost_usd=actual,lease_token_sha256=null,lease_expires_at=null,finalized_at=clock_timestamp(),updated_at=clock_timestamp() where id=d.id;
 update mission_narrative_internal.provider_authorizations set finalize_token_sha256=null where id=z.id;
 update mission_generic_owner.work_items set state=case when outcome_uncertain then 'uncertain' when ok then 'completed' else 'failed' end,result=p_result,result_sha256=case
    when ok and msg is not null and w.kind='narration'
      and w.payload->>'schema_version'='mission-generic-narration/4'
    then public.combat_v2_sha256(p_result)
    else p_result_sha end,

  receipt_id=receipt,message_id=msg,finalized_at=clock_timestamp() where id=w.id returning * into w;
 if stale_role then
   if w.kind='director' then
     update mission_generic_owner.unified_source_windows
       set superseded_at=clock_timestamp(),superseded_reason='role_revision_changed'
       where work_id=w.id and consumed_message_id is null and superseded_at is null;
   elsif w.kind='narration' then
     update mission_generic_owner.unified_source_windows uw
       set superseded_at=clock_timestamp(),superseded_reason='role_revision_changed'
       from mission_generic_owner.unified_batches ub
       where ub.id=w.authority_receipt_id and uw.id=ub.source_window_id
         and uw.consumed_message_id is null and uw.superseded_at is null;
   end if;
 end if;

 insert into mission_narrative_internal.dispatch_audit(receipt_id,event_code,details) values(d.id,'generic_finalized',jsonb_build_object(
  'work_id',w.id,'receipt_id',receipt,'message_id',msg,'result_jsonb_sha256',public.combat_v2_sha256(p_result),'result_sha256',p_result_sha,
  'command_receipt',cr,'cost_basis',basis,'stale',stale,'state',w.state,
  'outcome_uncertain',outcome_uncertain,'application_error_sqlstate',application_error,
  'application_error_code',application_error_code));
 return mission_generic_owner.work_status(w);
end;
$$;
CREATE OR REPLACE FUNCTION mission_public_owner.enqueue_combat_unified_v1(p_session uuid, p_report uuid, p_user uuid) RETURNS jsonb LANGUAGE plpgsql SECURITY DEFINER SET search_path TO '' AS $$
DECLARE source jsonb;rep public.combat_v2_round_reports;rw mission_generic_owner.unified_round_windows;batch uuid;
BEGIN
 PERFORM mission_ai_board_owner.service_only();
 PERFORM mission_generic_owner.dispatch_user(p_session,p_user);
 PERFORM public.master_v2_lock_scope(p_session);
 source:=mission_generic_owner.combat_narrative_source(p_session,p_report);
 IF jsonb_array_length(coalesce(source#>'{payload,roleless_declarations}','[]'::jsonb))=0 THEN
  PERFORM mission_generic_owner.enqueue_combat(p_session,p_report);
  RETURN mission_generic_owner.progress_result(p_session,p_user,'narration_ready');
 END IF;
 IF EXISTS(SELECT 1 FROM public.combat_v2_round_reports report
  JOIN public.combat_v2_rounds round ON round.id=report.round_id
  JOIN mission_narrative_internal.scene_runtime_v1 cache ON cache.master_session_id=p_session AND cache.is_active AND cache.mode='combat'
  JOIN mission_narrative_internal.scene_sources_v1 src ON src.scene_id=cache.id
  WHERE report.id=p_report AND src.technical_receipt->>'schema_version'='mission-narrative-combat-opening/1'
   AND src.technical_receipt->>'opening_round_id'=round.id::text
   AND src.technical_receipt->>'encounter_id'=round.session_id::text) THEN
  -- The player uses mechanics first and may still be writing their justification.
  -- Waiting precedes any Count/Generation. A real opening receipt is not a fake unified window.
  RETURN mission_generic_owner.progress_result(p_session,p_user,'waiting_player');
 END IF;
 SELECT * INTO STRICT rep FROM public.combat_v2_round_reports WHERE id=p_report FOR UPDATE;
 SELECT * INTO rw FROM mission_generic_owner.unified_round_windows WHERE round_id=rep.round_id FOR UPDATE;
 -- A mechanical report cannot invent a prior turn/cohort or a publication receipt.
 IF rw.round_id IS NULL OR rw.master_session_id IS DISTINCT FROM p_session OR rw.publication_id IS NULL
 THEN RAISE EXCEPTION 'NARRATIVE_ROLELESS_NATIVE_WINDOW_MISSING' USING ERRCODE='40001'; END IF;
 IF EXISTS(SELECT 1 FROM mission_generic_owner.work_items WHERE master_session_id=p_session
   AND dedupe_key='combat:'||p_report AND state NOT IN('completed','failed'))
 THEN RAISE EXCEPTION 'NARRATIVE_ROLELESS_PREEXISTING_WORK' USING ERRCODE='40001'; END IF;
 batch:=mission_generic_owner.unified_prepare_resolved(p_session,rep.round_id);
 -- Native preparation gathers all legal PNG commands and writes one /3 batch.
 -- The /4 narrative entry producer remains separate; no synthetic role is added.
 RETURN mission_generic_owner.unified_advance(p_session,p_user,mission_ai_service_owner.uuid5(batch,'roleless-native-progress'));
END $$;
CREATE OR REPLACE FUNCTION mission_generic_owner.enqueue_opening(p_session uuid, p_start uuid) RETURNS jsonb LANGUAGE plpgsql SECURITY DEFINER SET search_path TO '' AS $$
declare s mission_generic_owner.board_starts%rowtype;m public.master_v2_sessions%rowtype;r public.mission_run_state%rowtype;
 b mission_generic_owner.run_bindings%rowtype;e public.mission_run_events%rowtype;ob public.mission_run_outbox%rowtype;
 w mission_generic_owner.work_items%rowtype;obj text;ctx jsonb;payload jsonb;briefing text;title text;
begin
 select * into strict m from public.master_v2_sessions where id=p_session for update;
 perform mission_generic_owner.assert_runtime(p_session);
 select * into strict s from mission_generic_owner.board_starts where id=p_start and master_session_id=p_session;
 select * into w from mission_generic_owner.work_items where master_session_id=p_session and dedupe_key='opening:'||s.id;
 if found then return mission_generic_owner.work_status(w);end if;
 select * into strict r from public.mission_run_state where master_session_id=p_session;
 select * into strict b from mission_generic_owner.run_bindings where master_session_id=p_session;
 select * into strict e from public.mission_run_events where id=s.event_id and master_session_id=p_session;
 select * into strict ob from public.mission_run_outbox where event_id=e.id and master_session_id=p_session;
 if s.state<>'prepared' or s.snapshot_sha256<>mission_internal.fingerprint(s.snapshot)
 or m.stato<>'preparazione' or m.closed_at is not null or r.run_phase<>'preparazione'
 or e.operation_kind<>'bind' or e.status<>'committed' or e.version_after<>r.control_version
 or r.control_version<>1 or e.step_after<>r.current_step_key or ob.state<>'pending'
 or ob.event_version_after<>e.version_after or ob.step_key<>e.step_after or ob.context_fingerprint<>e.context_fingerprint
 or not exists(select 1 from public.master_v2_participants mp where mp.session_id=p_session and mp.left_at is null)
 then raise exception 'MGD_OPENING_SOURCE_INVALID';end if;
 IF s.simulation AND EXISTS(SELECT 1 FROM mission_factory_owner.editor_release_readiness root56
  WHERE root56.singleton AND root56.state='enabled' AND root56.scope='staff'
  AND root56.canonical_preimage::jsonb#>'{config,c1266_narrative_scene}'=
   '{"schema_version":"mission-narrative-scene-policy/1","enabled":true,"scope":"staff"}'::jsonb) THEN
  RETURN mission_narrative_internal.scene_initial_opening_v1(p_session,p_start,auth.uid());
 END IF;
 select public_objective into strict obj from public.mission_plan_steps where plan_version_id=r.plan_version_id and step_key=r.current_step_key;
 select mi.title,mi.briefing into strict title,briefing from public.missions mi where mi.id=m.mission_id;
 -- New complete missions use the frozen opening metadata; edits to the
 -- mission catalogue do not alter an already prepared opening.
 if mission_creation_owner.director_context(p_session,r.current_step_key) is not null then
  title:=s.snapshot->>'title';briefing:=s.snapshot->>'briefing';
  if nullif(btrim(title),'') is null or nullif(btrim(briefing),'') is null
  then raise exception 'MC_OPENING_METADATA_MISSING';end if;
 end if;
 ctx:=mission_generic_owner.narrative_context(p_session,r.current_step_key,s.id,s.created_at,
  jsonb_build_object('missione',title,'incarico',briefing,'obiettivo_iniziale',obj,
  'nota_autorita','È l’apertura della missione. L’incarico non è completato; parole, azioni e decisioni dei PG restano ai giocatori.'));
 payload:=jsonb_build_object('schema_version',case when ctx->>'schema_version'='mission-narrative-context/2' then 'mission-generic-narration/2' else 'mission-generic-narration/1' end,'mode','mission','opening_start_receipt_id',s.id,
  'barrier',jsonb_build_object('closed',true,'required_receipt_ids',jsonb_build_array(s.id,e.id),'receipt_ids',jsonb_build_array(s.id,e.id)),
  'context',ctx);
 insert into mission_generic_owner.work_items(master_session_id,event_id,dedupe_key,step_key,run_control_version,definition_sha256,
  authority_receipt_id,kind,revision,payload,payload_sha256)
 values(p_session,s.id,'opening:'||s.id,r.current_step_key,r.control_version,b.snapshot_sha256,s.id,'narration',r.control_version,
  payload,public.combat_v2_sha256(payload)) returning * into w;
 return mission_generic_owner.work_status(w);
end;
$$;
CREATE OR REPLACE FUNCTION mission_generic_owner.event_capture_v1() RETURNS trigger LANGUAGE plpgsql SECURITY DEFINER SET search_path TO '' AS $$
DECLARE src jsonb;oldsrc jsonb;tab text:=TG_TABLE_SCHEMA||'.'||TG_TABLE_NAME;
 sid uuid;loc uuid;source_id uuid;source_sha text;ai_domain text;ek uuid;ev bigint;cfg jsonb;
 hash_work mission_generic_owner.work_items;hash_old_work mission_generic_owner.work_items;rootrow mission_generic_owner.event_outbox_v1;request_id bigint;affected integer;
 hp jsonb;hphase text;htargets jsonb:='[]'::jsonb;ht record;hdomains text[];huids uuid[];hlocs uuid[];hsid uuid;huid uuid;hreason text:='changed';
BEGIN
 src:=CASE WHEN TG_OP='DELETE' THEN to_jsonb(OLD) ELSE to_jsonb(NEW) END;
 oldsrc:=CASE WHEN TG_OP='UPDATE' THEN to_jsonb(OLD) ELSE NULL END;
 IF TG_NARGS<>1 OR TG_ARGV[0] NOT IN('ai','hint') THEN RAISE EXCEPTION 'EVENT42_TRIGGER_MODE' USING ERRCODE='22023';END IF;
 IF TG_ARGV[0]='hint' THEN
 -- Constraint triggers run after source commands. This branch never mutates/locks source rows.
 IF TG_OP='UPDATE' AND src IS NOT DISTINCT FROM oldsrc THEN RETURN NEW;END IF;
 BEGIN
 SELECT value::jsonb INTO hp FROM public.app_settings WHERE key='land_event_delivery_v1';
 IF hp->>'schema_version' IS DISTINCT FROM 'land-event-delivery-policy/1'
 OR NOT mission_factory_owner.keys_exact_v2(hp,ARRAY['schema_version','phase','revision'])
 OR hp->>'phase' NOT IN('off','staff','global') THEN
 RAISE EXCEPTION 'EVENT42_DISPLAY_POLICY_INVALID' USING ERRCODE='22023';END IF;
 EXCEPTION
 WHEN query_canceled THEN
  RAISE LOG 'EVENT42_HINT_CONFIG_SKIPPED';
  IF TG_OP='DELETE' THEN RETURN OLD;END IF;RETURN NEW;
 WHEN OTHERS THEN
  IF SQLSTATE='42501' OR left(SQLSTATE,2) IN('28','0L','0P') THEN RAISE;END IF;
  RAISE LOG 'EVENT42_HINT_CONFIG_SKIPPED';
  IF TG_OP='DELETE' THEN RETURN OLD;END IF;RETURN NEW;
 END;
 hphase:=hp->>'phase';
 -- Only a real policy mutation may notify while off; never writes private outbox or schedules AI.
 IF hphase='off' AND NOT(tab='public.app_settings' AND src->>'key'='land_event_delivery_v1') THEN
 IF TG_OP='DELETE' THEN RETURN OLD;END IF;RETURN NEW;END IF;
 -- Flush only the two captured named mandatory constraints at this deferred callback.
 -- Original pending training guards and round FK checks execute before hint audience or slot locks.
 -- Keep IMMEDIATE for remaining end-TX callbacks: any newly queued training guard executes
 -- synchronously before returning to metadata-only hints. Never invoke its business helper here.
 IF current_setting('app.event42_hint_constraints_flush_tx',true) IS DISTINCT FROM txid_current()::text THEN
  SET CONSTRAINTS public.training_nonlethal_resource_guard, mission_generic_owner.unified_round_windows_round_id_fkey IMMEDIATE;
  PERFORM set_config('app.event42_hint_constraints_flush_tx',txid_current()::text,true);
 END IF;
 BEGIN
 hdomains:=ARRAY[]::text[];huids:=ARRAY[]::uuid[];hlocs:=ARRAY[]::uuid[];
 IF tab='public.app_settings' THEN
  IF src->>'key'='land_event_delivery_v1' THEN
   hdomains:=ARRAY['catalog'];SELECT array_agg(id ORDER BY id) INTO huids FROM public.profiles;
  ELSIF src->>'key'='flash_news' THEN
   hdomains:=ARRAY['news'];
   IF hphase='global' THEN
    htargets:=jsonb_build_array(jsonb_build_object('audience','authenticated','recipient_user',NULL,'domain','news','location_id',NULL,'session_id',NULL,'reason','changed'));
   ELSE SELECT array_agg(id ORDER BY id) INTO huids FROM public.profiles WHERE role IN('admin','master');END IF;
  ELSIF src->>'key'='map_villages' THEN
   hdomains:=ARRAY['catalog'];SELECT array_agg(id ORDER BY id) INTO huids FROM public.profiles;
  ELSE IF TG_OP='DELETE' THEN RETURN OLD;END IF;RETURN NEW;END IF;
 ELSIF tab='public.direct_messages' THEN
  huids:=ARRAY[(src->>'sender_user')::uuid,(src->>'recipient_user')::uuid,(oldsrc->>'sender_user')::uuid,(oldsrc->>'recipient_user')::uuid];hdomains:=ARRAY['mail'];
 ELSIF tab='public.calendar_events' THEN
  huids:=ARRAY[(src->>'user_id')::uuid,(oldsrc->>'user_id')::uuid];hdomains:=ARRAY['calendar'];
 ELSIF tab='public.mission_bookings' THEN
  SELECT array_agg(user_id ORDER BY user_id) INTO huids FROM public.characters
   WHERE id=(src->>'character_id')::uuid OR id=(oldsrc->>'character_id')::uuid;
  hdomains:=ARRAY['calendar'];
 ELSIF tab='public.missions' THEN
  SELECT array_agg(c.user_id ORDER BY c.user_id) INTO huids FROM public.mission_bookings b
   JOIN public.characters c ON c.id=b.character_id WHERE b.mission_id=(src->>'id')::uuid;
  hdomains:=ARRAY['calendar','catalog'];
 ELSIF tab='public.characters' THEN
  huids:=ARRAY[(src->>'user_id')::uuid,(oldsrc->>'user_id')::uuid];hdomains:=ARRAY['character'];
  IF TG_OP<>'UPDATE' OR(src->'name',src->'cognome',src->'avatar_url',src->'clan') IS DISTINCT FROM
   (oldsrc->'name',oldsrc->'cognome',oldsrc->'avatar_url',oldsrc->'clan') THEN
   SELECT coalesce(htargets,'[]'::jsonb)||coalesce(jsonb_agg(jsonb_build_object('audience','own','recipient_user',p.id,
    'domain','catalog','location_id',NULL,'session_id',NULL,'reason','changed') ORDER BY p.id),'[]'::jsonb) INTO htargets
   FROM public.profiles p JOIN public.presence pr ON pr.user_id=p.id
   WHERE pr.last_seen>clock_timestamp()-interval '8 minutes' AND(hphase='global' OR p.role IN('admin','master'));
  END IF;
 ELSIF tab='public.profiles' THEN
  huids:=ARRAY[(src->>'id')::uuid];hdomains:=ARRAY['catalog'];
 ELSIF tab='public.locations' THEN
  SELECT array_agg(id ORDER BY id) INTO huids FROM public.profiles;hdomains:=ARRAY['catalog'];
 ELSIF tab IN('public.training_sessions','public.character_abilities') THEN
  SELECT array_agg(user_id ORDER BY user_id) INTO huids FROM public.characters WHERE id=(src->>'character_id')::uuid;
  hdomains:=ARRAY['training','character'];
 ELSIF tab='public.presence' THEN
  -- Mere identical heartbeat has no UI state change. Reappearance after TTL is a real delta.
  IF TG_OP='UPDATE' AND (src->'user_id',src->'location_id',src->'status',src->'left_logged') IS NOT DISTINCT FROM
    (oldsrc->'user_id',oldsrc->'location_id',oldsrc->'status',oldsrc->'left_logged')
    AND (oldsrc->>'last_seen')::timestamptz>clock_timestamp()-interval '8 minutes' THEN RETURN NEW;END IF;
  hdomains:=ARRAY['presence'];
  SELECT array_agg(p.user_id ORDER BY p.user_id) INTO huids FROM public.presence p
   WHERE p.last_seen>clock_timestamp()-interval '8 minutes';
 ELSIF tab='public.presence_events' THEN
  hdomains:=ARRAY['presence'];SELECT array_agg(p.user_id ORDER BY p.user_id) INTO huids FROM public.presence p
   WHERE p.last_seen>clock_timestamp()-interval '8 minutes';
 ELSIF tab='public.messages' THEN
  hdomains:=ARRAY['chat','scene','academy','exam'];hlocs:=ARRAY[(src->>'location_id')::uuid];
  IF src->>'kind'='whisper' THEN
   -- The underlying messages_read policy permits parties or Staff, no room-wide whisper timing leak.
   SELECT array_agg(p.id ORDER BY p.id) INTO huids FROM public.profiles p
    WHERE p.id IN((src->>'sender_user')::uuid,(src->>'recipient_user')::uuid) OR p.role IN('admin','master');
   hlocs:=ARRAY[]::uuid[];
  ELSIF src->>'kind'='motore' THEN
   SELECT array_agg(p.id ORDER BY p.id) INTO huids FROM public.profiles p JOIN public.presence pr ON pr.user_id=p.id
    WHERE p.role IN('admin','master') AND pr.location_id=(src->>'location_id')::uuid
    AND pr.last_seen>clock_timestamp()-interval '8 minutes';hlocs:=ARRAY[]::uuid[];
  END IF;
 ELSIF tab IN('public.role_sessions','public.role_session_participants') THEN
  hdomains:=ARRAY['role_archive'];
  IF tab='public.role_sessions' THEN hsid:=(src->>'id')::uuid;hlocs:=ARRAY[(src->>'location_id')::uuid];
  ELSE hsid:=(src->>'session_id')::uuid;huids:=ARRAY[(src->>'user_id')::uuid];END IF;
  SELECT coalesce(huids,ARRAY[]::uuid[])||coalesce(array_agg(p.user_id ORDER BY p.user_id),ARRAY[]::uuid[]) INTO huids
   FROM public.role_session_participants p WHERE p.session_id=hsid;
 ELSIF tab IN('public.academy_class_sessions','public.academy_class_participants') THEN
  hdomains:=ARRAY['academy'];
  IF tab='public.academy_class_sessions' THEN hsid:=(src->>'id')::uuid;hlocs:=ARRAY[(src->>'location_id')::uuid];
  ELSE hsid:=(src->>'session_id')::uuid;
   SELECT ARRAY[location_id] INTO hlocs FROM public.academy_class_sessions WHERE id=hsid;END IF;
  SELECT array_agg(user_id ORDER BY user_id) INTO huids FROM public.academy_class_participants WHERE session_id=hsid;
 ELSIF tab='public.esame_prove' THEN
  hdomains:=ARRAY['exam'];hsid:=(src->>'class_session_id')::uuid;
  SELECT array_agg(p.id ORDER BY p.id) INTO huids FROM public.profiles p
   WHERE p.id=(src->>'candidate_user')::uuid OR p.role IN('admin','master');
 ELSIF tab IN('public.master_v2_sessions','public.master_v2_participants') THEN
  hdomains:=ARRAY['scene'];
  IF tab='public.master_v2_sessions' THEN
   hsid:=(src->>'id')::uuid;hlocs:=ARRAY[(src->>'location_id')::uuid,(oldsrc->>'location_id')::uuid];
  ELSE hsid:=(src->>'session_id')::uuid;huids:=ARRAY[(src->>'user_id_snapshot')::uuid,(oldsrc->>'user_id_snapshot')::uuid];
   SELECT ARRAY[location_id] INTO hlocs FROM public.master_v2_sessions WHERE id=hsid;END IF;
 ELSIF tab IN('public.combat_v2_round_reports','public.combat_v2_declarations','public.combat_v2_defense_coverages','public.combat_v2_ratings') THEN
  hdomains:=ARRAY['scene'];
  SELECT cs.master_session_id,ARRAY[cs.location_id] INTO hsid,hlocs FROM public.combat_v2_rounds cr
   JOIN public.combat_v2_sessions cs ON cs.id=cr.session_id WHERE cr.id=(src->>'round_id')::uuid;
 ELSIF tab IN('mission_generic_owner.unified_batches','mission_generic_owner.role_submissions','mission_generic_owner.event_outbox_v1','public.mission_run_state','mission_generic_owner.work_items') THEN
  hdomains:=ARRAY['scene'];hsid:=(src->>'master_session_id')::uuid;
  SELECT ARRAY[location_id] INTO hlocs FROM public.master_v2_sessions WHERE id=hsid;
  IF tab='mission_generic_owner.unified_batches' AND src->>'state'='published' AND src->>'message_id' IS NOT NULL THEN hreason:='published';END IF;
  IF tab='mission_generic_owner.event_outbox_v1' AND src->>'state'='terminal' THEN hreason:='closed';END IF;
 ELSE RAISE EXCEPTION 'EVENT42_HINT_SOURCE_UNDECLARED' USING ERRCODE='22023';END IF;
 -- Entitlement resolution is SELECT-only. Recipients were already legitimate viewers/owners;
 -- no source identity/content escapes into a shared notification.
 SELECT coalesce(huids,ARRAY[]::uuid[])||coalesce(array_agg(pr.user_id ORDER BY pr.user_id),ARRAY[]::uuid[]) INTO huids
 FROM public.presence pr WHERE pr.location_id=ANY(coalesce(hlocs,ARRAY[]::uuid[]))
 AND pr.last_seen>clock_timestamp()-interval '8 minutes';
 SELECT htargets||coalesce(jsonb_agg(jsonb_build_object('audience','own','recipient_user',q.id,'domain',d,
  'location_id',CASE WHEN tab='public.messages' THEN(src->>'location_id')::uuid WHEN cardinality(hlocs)=1 THEN hlocs[1] ELSE NULL END,'session_id',hsid,'reason',hreason) ORDER BY q.id,d),'[]'::jsonb) INTO htargets
 FROM public.profiles q CROSS JOIN unnest(hdomains) d
 WHERE q.id=ANY(coalesce(huids,ARRAY[]::uuid[]))
 AND(hphase='global' OR q.role IN('admin','master') OR(tab='public.app_settings' AND src->>'key'='land_event_delivery_v1'));
 IF jsonb_array_length(htargets)>0 THEN
  -- Single global metadata serialization, acquired only in deferred hint callbacks after source writes.
  -- Existing deferred source-writing callbacks/SET CONSTRAINTS must be absent per catalogue/source preflight.
  PERFORM pg_advisory_xact_lock(hashtextextended('C1266:LAND:DEFERRED-HINT-SLOTS',0));
  FOR ht IN SELECT DISTINCT t.audience,t.recipient_user,t.domain,t.location_id,t.session_id,t.reason
   FROM jsonb_to_recordset(htargets) AS t(audience text,recipient_user uuid,domain text,location_id uuid,session_id uuid,reason text)
   ORDER BY t.recipient_user NULLS FIRST,t.domain,t.location_id NULLS FIRST,t.session_id NULLS FIRST,t.reason LOOP
   INSERT INTO public.mission_land_events_v1(audience,recipient_user,domain,location_id,session_id,reason)
   VALUES(ht.audience,ht.recipient_user,ht.domain,ht.location_id,ht.session_id,ht.reason)
   ON CONFLICT(recipient_user,domain) DO UPDATE SET audience=EXCLUDED.audience,location_id=EXCLUDED.location_id,
    session_id=EXCLUDED.session_id,reason=EXCLUDED.reason,revision=DEFAULT,updated_at=clock_timestamp();
  END LOOP;
 END IF;
 EXCEPTION
 WHEN query_canceled THEN
  -- Only cancellation originating inside optional notification work is contained.
  RAISE LOG 'EVENT42_HINT_AUX_SKIPPED';
 WHEN OTHERS THEN
  -- No Auth/privilege errors are downgraded. Private AI/security/budget and mandatory
  -- resource/FK checks are outside this optional block and never flow through it.
  IF SQLSTATE='42501' OR left(SQLSTATE,2) IN('28','0L','0P') THEN RAISE;END IF;
  RAISE LOG 'EVENT42_HINT_AUX_SKIPPED';
 END;
 IF TG_OP='DELETE' THEN RETURN OLD;END IF;RETURN NEW;

 END IF;

 -- Audited completion is a real server event; never rewrite NEW/OLD audit records.
 IF tab='mission_narrative_internal.dispatch_audit' THEN
  IF TG_OP<>'INSERT' OR src->>'event_code' IS DISTINCT FROM 'generic_finalized'
   OR coalesce(src#>>'{details,work_id}','')!~'^[a-fA-F0-9]{8}(-[a-fA-F0-9]{4}){3}-[a-fA-F0-9]{12}$'
  THEN RETURN NEW;END IF;
  SELECT * INTO hash_work FROM mission_generic_owner.work_items hp_source_work
   WHERE hp_source_work.id=(src#>>'{details,work_id}')::uuid
   AND hp_source_work.dispatch_receipt_id=(src->>'receipt_id')::uuid;
  IF NOT FOUND THEN RETURN NEW;END IF;
  IF hash_work.state NOT IN('completed','failed') OR hash_work.receipt_id IS NULL OR hash_work.finalized_at IS NULL
   OR src#>>'{details,receipt_id}' IS DISTINCT FROM hash_work.receipt_id::text
   OR src#>>'{details,state}' IS DISTINCT FROM hash_work.state
   OR src#>'{details,message_id}' IS DISTINCT FROM coalesce(to_jsonb(hash_work.message_id),'null'::jsonb)
   OR src#>>'{details,result_jsonb_sha256}' IS DISTINCT FROM public.combat_v2_sha256(hash_work.result)
   OR((src#>>'{details,result_sha256}'=hash_work.result_sha256)
     OR(hash_work.kind='narration' AND hash_work.payload->>'schema_version'='mission-generic-narration/4'
        AND hash_work.result_sha256=public.combat_v2_sha256(hash_work.result))) IS DISTINCT FROM TRUE
  THEN RETURN NEW;END IF;
  tab:='mission_generic_owner.work_items';src:=to_jsonb(hash_work);
 ELSIF tab='mission_generic_owner.work_items' THEN
  hash_work:=NEW;
  IF TG_OP='UPDATE' THEN hash_old_work:=OLD;END IF;
 END IF;
 IF tab IN('mission_generic_owner.role_submissions','mission_generic_owner.unified_batches','mission_generic_owner.work_items') THEN
  sid:=(src->>'master_session_id')::uuid;
 ELSIF tab='public.mission_run_state' THEN sid:=NEW.master_session_id;
 ELSIF tab IN('public.combat_v2_round_reports','public.combat_v2_declarations','public.combat_v2_defense_coverages','public.combat_v2_ratings') THEN
  SELECT cs.master_session_id INTO sid FROM public.combat_v2_rounds cr
  JOIN public.combat_v2_sessions cs ON cs.id=cr.session_id WHERE cr.id=(src->>'round_id')::uuid;
 ELSE RAISE EXCEPTION 'EVENT42_TRIGGER_SOURCE' USING ERRCODE='22023';END IF;
 IF sid IS NULL THEN RETURN NEW;END IF;
 SELECT location_id INTO loc FROM public.master_v2_sessions WHERE id=sid;
 IF loc IS DISTINCT FROM '0b85f354-9cdb-47e1-baf9-3d266bb7e06b'::uuid THEN RETURN NEW;END IF;
 IF tab IN('public.combat_v2_declarations','public.combat_v2_defense_coverages','public.combat_v2_ratings','public.combat_v2_round_reports') THEN
  NULL; /* Display hint deferred; no public slot lock in source/worker body. */
 END IF;
 -- No bootstrap/backfill from role/report/Room. Root exists only after accepted normal AI Staff start.
 SELECT * INTO rootrow FROM mission_generic_owner.event_outbox_v1 WHERE master_session_id=sid
 AND event_domain='start' AND event_key=root_event_key AND event_version=1;
 IF NOT FOUND THEN RETURN NEW;END IF;
 SELECT rr.canonical_preimage::jsonb#>'{config,c1266_server_events}' INTO cfg
 FROM mission_factory_owner.editor_release_readiness rr WHERE rr.singleton AND rr.state='enabled' AND rr.scope='staff';
 IF cfg->>'schema_version' IS DISTINCT FROM 'c1266-server-events/1' THEN RETURN NEW;END IF;
 IF tab='mission_generic_owner.work_items' THEN
 IF hash_work.state IN('completed','failed')
 AND hash_work.receipt_id IS NOT NULL AND hash_work.finalized_at IS NOT NULL
 AND (hash_work.result_sha256=public.combat_v2_sha256(hash_work.result) OR EXISTS(
 SELECT 1 FROM mission_narrative_internal.dispatch_audit hp_finalized
 WHERE hp_finalized.receipt_id=hash_work.dispatch_receipt_id AND hp_finalized.event_code='generic_finalized'
 AND hp_finalized.details->>'work_id'=hash_work.id::text
 AND hp_finalized.details->>'receipt_id'=hash_work.receipt_id::text
 AND hp_finalized.details->>'state'=hash_work.state
 AND hp_finalized.details->'message_id' IS NOT DISTINCT FROM coalesce(to_jsonb(hash_work.message_id),'null'::jsonb)
 AND hp_finalized.details->>'result_sha256'=hash_work.result_sha256
 AND hp_finalized.details->>'result_jsonb_sha256'=public.combat_v2_sha256(hash_work.result))) THEN
 UPDATE mission_generic_owner.event_outbox_v1 own_event SET
 state=CASE WHEN hash_work.state='failed' AND((hash_work.kind='director' AND hash_work.result->'failure_codes' ? 'MISSION_PROVIDER_OUTPUT_RETENTION_FAILED')
  OR(hash_work.kind='narration' AND hash_work.result->'ok'='true'::jsonb AND hash_work.result->>'provider_calls'='1'))
 THEN 'uncertain' ELSE 'terminal' END,updated_at=clock_timestamp()
 WHERE own_event.master_session_id=sid AND own_event.work_id=hash_work.id AND own_event.root_event_key=rootrow.root_event_key
 AND own_event.canonical_request=jsonb_build_object('schema_version','mission-generic-request/1','master_session_id',hash_work.master_session_id,
 'event_id',hash_work.event_id,'request_key',hash_work.request_key,'expected_revision',hash_work.revision);
 END IF;
 END IF;
 IF tab='mission_generic_owner.role_submissions' THEN
  ai_domain:='role_window';source_id:=NEW.message_id;source_sha:=public.combat_v2_sha256(to_jsonb(NEW));
  ev:=nextval(pg_get_serial_sequence('mission_generic_owner.event_outbox_v1','event_version'));
  ek:=mission_ai_service_owner.uuid5(sid,'server-event:role-window:'||NEW.window_epoch::text);
 ELSIF tab='mission_generic_owner.unified_batches' THEN
  IF NEW.state='published' AND NEW.message_id IS NOT NULL AND(TG_OP='INSERT' OR OLD.message_id IS DISTINCT FROM NEW.message_id) THEN
   NULL; /* Display hint deferred; no public slot lock in source/worker body. */RETURN NEW;END IF;
  IF NEW.writer_work_id IS NULL OR(TG_OP='UPDATE' AND OLD.writer_work_id IS NOT DISTINCT FROM NEW.writer_work_id)
   OR NOT EXISTS(SELECT 1 FROM mission_generic_owner.work_items w WHERE w.id=NEW.writer_work_id
    AND w.master_session_id=sid AND w.kind='narration' AND w.state='ready' AND w.authority_receipt_id=NEW.id)
   OR NOT EXISTS(SELECT 1 FROM mission_generic_owner.event_outbox_v1 parent
     WHERE parent.master_session_id=sid AND parent.root_event_key=rootrow.root_event_key
      AND parent.work_id=NEW.decision_work_id) THEN RETURN NEW;END IF;
  ai_domain:='writer_ready';source_id:=NEW.writer_work_id;ev:=1;
  SELECT payload_sha256 INTO source_sha FROM mission_generic_owner.work_items WHERE id=source_id;
  ek:=mission_ai_service_owner.uuid5(source_id,'server-event:writer-ready');
 ELSIF tab='public.mission_run_state' THEN
  IF TG_OP='INSERT' OR(OLD.current_step_key IS NOT DISTINCT FROM NEW.current_step_key
   AND OLD.control_version IS NOT DISTINCT FROM NEW.control_version AND OLD.run_phase IS NOT DISTINCT FROM NEW.run_phase) THEN RETURN NEW;END IF;
  IF NEW.run_phase NOT IN('preparazione','in_corso') THEN
   NULL; /* Display hint deferred; no public slot lock in source/worker body. */RETURN NEW;END IF;
  IF EXISTS(SELECT 1 FROM mission_narrative_internal.scene_runtime_v1 WHERE master_session_id=sid AND is_active) THEN RETURN NEW;END IF;
  ai_domain:='phase';source_id:=coalesce(NEW.last_event_id,mission_ai_service_owner.uuid5(sid,'phase:'||NEW.control_version::text));
  source_sha:=public.combat_v2_sha256(jsonb_build_object('step',NEW.current_step_key,'control',NEW.control_version,'plan',NEW.plan_sha256));
  ev:=NEW.control_version;ek:=mission_ai_service_owner.uuid5(sid,'server-event:phase:'||NEW.current_step_key);
 ELSIF tab='public.combat_v2_round_reports' THEN
  IF NEW.narration_state<>'attesa' OR NEW.message_id IS NOT NULL THEN RETURN NEW;END IF;
  ai_domain:='native_report';source_id:=NEW.id;ev:=1;source_sha:=NEW.mechanics_sha256;
  ek:=mission_ai_service_owner.uuid5(NEW.id,'server-event:native-report');
 ELSIF tab IN('public.combat_v2_declarations','public.combat_v2_defense_coverages','public.combat_v2_ratings') THEN
  IF tab='public.combat_v2_declarations' AND NOT EXISTS(SELECT 1 FROM public.combat_v2_actors a
   WHERE a.id=(src->>'actor_id')::uuid AND a.actor_kind='pg') THEN RETURN NEW;END IF;
  IF tab='public.combat_v2_defense_coverages' AND NOT EXISTS(SELECT 1 FROM public.combat_v2_declarations dd
   JOIN public.combat_v2_actors a ON a.id=dd.actor_id WHERE dd.id=(src->>'defense_declaration_id')::uuid
    AND a.actor_kind='pg') THEN RETURN NEW;END IF;
  IF tab='public.combat_v2_ratings' AND(src->'is_active' IS DISTINCT FROM 'true'::jsonb
   OR(TG_OP='UPDATE' AND oldsrc->'is_active'='true'::jsonb)) THEN RETURN NEW;END IF;
  ai_domain:='native_input';source_id:=(src->>'id')::uuid;source_sha:=public.combat_v2_sha256(src);
  ek:=mission_ai_service_owner.uuid5((src->>'round_id')::uuid,'server-event:native-input');
  -- A sequence version prevents concurrent accepted PG actions coalescing into a lost wake.
  ev:=nextval(pg_get_serial_sequence('mission_generic_owner.event_outbox_v1','event_version'));
 ELSIF tab='mission_generic_owner.work_items' THEN
  IF hash_work.state='failed' AND(TG_OP='INSERT' OR hash_old_work.state IS DISTINCT FROM hash_work.state) THEN
   NULL; /* Display hint deferred; no public slot lock in source/worker body. */RETURN NEW;END IF;
  IF hash_work.kind<>'choice' OR hash_work.state<>'completed' OR hash_work.receipt_id IS NULL OR hash_work.finalized_at IS NULL
   OR ((hash_work.result_sha256=public.combat_v2_sha256(hash_work.result) OR EXISTS(
 SELECT 1 FROM mission_narrative_internal.dispatch_audit hp_finalized
 WHERE hp_finalized.receipt_id=hash_work.dispatch_receipt_id AND hp_finalized.event_code='generic_finalized'
 AND hp_finalized.details->>'work_id'=hash_work.id::text
 AND hp_finalized.details->>'receipt_id'=hash_work.receipt_id::text
 AND hp_finalized.details->>'state'=hash_work.state
 AND hp_finalized.details->'message_id' IS NOT DISTINCT FROM coalesce(to_jsonb(hash_work.message_id),'null'::jsonb)
 AND hp_finalized.details->>'result_sha256'=hash_work.result_sha256
 AND hp_finalized.details->>'result_jsonb_sha256'=public.combat_v2_sha256(hash_work.result)))) IS DISTINCT FROM TRUE
   OR(TG_OP='UPDATE' AND hash_old_work.state='completed') THEN RETURN NEW;END IF;
  ai_domain:='native_choice';source_id:=hash_work.id;source_sha:=hash_work.result_sha256;ev:=1;
  ek:=mission_ai_service_owner.uuid5(hash_work.id,'server-event:native-choice');
 END IF;
 IF ek IS NULL OR source_sha IS NULL OR ev IS NULL OR ev<1 THEN RETURN NEW;END IF;
 IF cfg->>'endpoint' IS DISTINCT FROM 'https://tyhyxkslteigibktluml.supabase.co/functions/v1/mission_generic_ai'
 THEN RAISE EXCEPTION 'EVENT42_ENDPOINT_REJECTED' USING ERRCODE='42501'; END IF;
 INSERT INTO mission_generic_owner.event_outbox_v1(event_key,event_version,master_session_id,event_domain,
 source_id,source_sha256,root_event_key,root_request_key,root_principal,root_receipt_sha256)
 VALUES(ek,ev,sid,ai_domain,source_id,source_sha,rootrow.root_event_key,rootrow.root_request_key,
 rootrow.root_principal,rootrow.root_receipt_sha256)
 ON CONFLICT(event_key,event_version) DO NOTHING;
 GET DIAGNOSTICS affected=ROW_COUNT;
 IF affected=1 THEN
 IF cfg->'enabled'='true'::jsonb THEN
 request_id:=net.http_post(cfg->>'endpoint',jsonb_build_object('schema_version','mission-event-wake/2',
 'event_key',ek,'event_version',ev),'{}'::jsonb,
 jsonb_build_object('Content-Type','application/json','x-tus-server-event','event42'),5000);
 UPDATE mission_generic_owner.event_outbox_v1 SET wake_request_id=request_id
 WHERE event_key=ek AND event_version=ev;
 END IF;
 END IF;
 IF affected=1 THEN NULL; /* Display hint deferred; no public slot lock in source/worker body. */END IF;
 RETURN NEW;
END $$;
CREATE OR REPLACE FUNCTION public.mission_generic_event_next_v1(p_event_key uuid, p_event_version bigint, p_claim_id uuid) RETURNS jsonb LANGUAGE plpgsql SECURITY DEFINER SET search_path TO '' SET statement_timeout TO '20s' AS $$
DECLARE scene56_entry_progress jsonb;scene56_runtime mission_narrative_internal.scene_runtime_v1;scene56_prepared jsonb;
 e mission_generic_owner.event_outbox_v1;cfg jsonb;progress jsonb;candidate jsonb;flow jsonb;writer46 jsonb;
 event43_observed_work uuid:=NULL;event43_observed_request jsonb:=NULL;
 writer48_source_work mission_generic_owner.work_items;writer48_terminal_event mission_generic_owner.event_outbox_v1;
 writer48_source_request jsonb;writer48_event_after jsonb;writer48_child_request jsonb:=NULL;writer48_child_id uuid:=NULL;
 w mission_generic_owner.work_items;req uuid;outcome text;native_claim jsonb;role_source_user uuid;native_mode text;paid_action boolean:=false;
BEGIN
 PERFORM mission_ai_board_owner.service_only();
 PERFORM pg_advisory_xact_lock_shared(hashtextextended('C1266:GENERIC-AI:AVAILABILITY',0));
 SELECT * INTO e FROM mission_generic_owner.event_outbox_v1 WHERE event_key=p_event_key AND event_version=p_event_version FOR UPDATE;
 IF NOT FOUND OR e.claim_id IS DISTINCT FROM p_claim_id OR p_claim_id IS NULL OR e.claimed_at IS NULL
 THEN RAISE EXCEPTION 'EVENT42_CLAIM_REJECTED' USING ERRCODE='42501'; END IF;
 IF e.next_result IS NOT NULL THEN RETURN jsonb_set(jsonb_set(jsonb_set(e.next_result,'{state}','"uncertain"'::jsonb),'{request}','null'::jsonb),'{native_claim}','null'::jsonb); END IF;
 IF e.state<>'running' OR e.claim_expires_at<=clock_timestamp() THEN RAISE EXCEPTION 'EVENT42_CLAIM_EXPIRED' USING ERRCODE='42501';END IF;
 SELECT rr.canonical_preimage::jsonb#>'{config,c1266_server_events}' INTO cfg
 FROM mission_factory_owner.editor_release_readiness rr
 WHERE rr.singleton AND rr.state='enabled' AND rr.scope='staff'
 AND rr.revision_sha256=rr.observed_revision_sha256;
 IF cfg->>'schema_version' IS DISTINCT FROM 'c1266-server-events/1'
 OR cfg->'enabled' IS DISTINCT FROM 'true'::jsonb THEN
 RAISE EXCEPTION 'EVENT42_MODE_DISABLED' USING ERRCODE='42501'; END IF;
 IF NOT EXISTS(SELECT 1 FROM public.master_v2_sessions m JOIN public.locations l ON l.id=m.location_id
 WHERE m.id=e.master_session_id AND m.owner_kind='ai_service' AND m.master_user IS NULL
 AND m.closed_at IS NULL AND m.suspended_at IS NULL AND m.stato IN('preparazione','in_corso')
 AND l.id='0b85f354-9cdb-47e1-baf9-3d266bb7e06b'::uuid AND l.is_test AND l.is_active)
 OR NOT EXISTS(SELECT 1 FROM public.profiles p WHERE p.id=e.root_principal AND p.role IN('admin','master'))
 OR NOT EXISTS(SELECT 1 FROM mission_generic_owner.start_claims sc
 JOIN mission_generic_owner.board_starts bs ON bs.request_key=sc.request_key
 WHERE sc.request_key=e.root_request_key AND sc.actor_user_id=e.root_principal
 AND sc.session_id=e.master_session_id AND bs.master_session_id=e.master_session_id
 AND public.combat_v2_sha256(bs.result)=e.root_receipt_sha256)
 OR mission_generic_owner.manual_staff_scope_v1(e.master_session_id) IS NULL
 THEN RAISE EXCEPTION 'EVENT42_SCOPE_REJECTED' USING ERRCODE='42501'; END IF;

 IF EXISTS(SELECT 1 FROM mission_narrative_internal.scene_runtime_v1 WHERE master_session_id=e.master_session_id AND is_active) THEN
  PERFORM 1 FROM public.locations WHERE id=(SELECT location_id FROM public.master_v2_sessions WHERE id=e.master_session_id) FOR UPDATE;
 END IF;
 PERFORM 1 FROM mission_generic_owner.role_window_cursors WHERE master_session_id=e.master_session_id FOR UPDATE;
 -- New Scene lanes retain service/cfg/root/principal scope above and take their own
 -- cursor→scene→master/run locks. Do not enter legacy progression for narrative.
 SELECT * INTO scene56_runtime FROM mission_narrative_internal.scene_runtime_v1 WHERE master_session_id=e.master_session_id AND is_active;
 IF FOUND THEN
  scene56_entry_progress:=mission_narrative_internal.scene_player_entry_event_v1(p_event_key,p_event_version,p_claim_id);
  IF scene56_entry_progress IS NOT NULL THEN
   UPDATE mission_generic_owner.event_outbox_v1 SET next_result=scene56_entry_progress,updated_at=clock_timestamp()
    WHERE event_key=p_event_key AND event_version=p_event_version;
   RETURN scene56_entry_progress;
  END IF;
  IF scene56_runtime.mode IN('narrative','closed','combat_pending') THEN
   outcome:='waiting';candidate:=NULL;native_claim:=NULL;
   IF scene56_runtime.mode='narrative' AND e.event_domain IN('start','role_window') THEN
    IF e.event_domain='role_window' AND NOT EXISTS(SELECT 1 FROM mission_generic_owner.role_submissions sub
     JOIN mission_generic_owner.role_window_cursors cur ON cur.master_session_id=sub.master_session_id AND cur.window_epoch=sub.window_epoch
     WHERE sub.master_session_id=e.master_session_id AND sub.message_id=e.source_id
      AND public.combat_v2_sha256(to_jsonb(sub))=e.source_sha256) THEN
     RAISE EXCEPTION 'SCENE56_ROLE_EVENT_SOURCE' USING ERRCODE='42501';END IF;
    IF e.event_domain='start' THEN
     SELECT wi.* INTO w FROM mission_generic_owner.work_items wi JOIN mission_narrative_internal.scene_sources_v1 src ON src.work_id=wi.id
      WHERE src.scene_id=scene56_runtime.id AND src.request_kind='initial_opening' AND src.retired_at IS NULL;
    ELSE
     scene56_prepared:=mission_narrative_internal.scene_prepare_v1(e.master_session_id,e.root_principal,
      mission_ai_service_owner.uuid5(e.event_key,'server-event/1:'||e.event_version::text));
     IF scene56_prepared->>'work_id' IS NOT NULL THEN
      SELECT * INTO STRICT w FROM mission_generic_owner.work_items WHERE id=(scene56_prepared->>'work_id')::uuid;
     END IF;
    END IF;
    IF w.id IS NOT NULL THEN
     candidate:=jsonb_build_object('schema_version','mission-generic-request/1','master_session_id',w.master_session_id,
      'event_id',w.event_id,'request_key',w.request_key,'expected_revision',w.revision);
     IF e.work_id IS NOT NULL AND (e.work_id IS DISTINCT FROM w.id OR e.canonical_request IS DISTINCT FROM candidate) THEN
      RAISE EXCEPTION 'SCENE56_EVENT_WORK_REBIND_FORBIDDEN' USING ERRCODE='42501';END IF;
     IF w.state='ready' AND w.lease_id IS NULL THEN
      -- The unchanged dispatcher requires this current-transaction event permit.
      -- Bind only the locked current claim and never overwrite a partial/different pair.
      UPDATE mission_generic_owner.event_outbox_v1 bound_event
       SET work_id=w.id,canonical_request=candidate,claim_txid=txid_current(),claim_backend=pg_backend_pid(),
        updated_at=clock_timestamp()
       WHERE bound_event.event_key=e.event_key AND bound_event.event_version=e.event_version
        AND bound_event.master_session_id=e.master_session_id AND bound_event.master_session_id=w.master_session_id
        AND bound_event.claim_id=p_claim_id AND bound_event.claim_id=e.claim_id
        AND bound_event.state='running' AND bound_event.claim_expires_at>clock_timestamp()
        AND bound_event.root_principal=e.root_principal AND bound_event.root_request_key=e.root_request_key
        AND bound_event.root_receipt_sha256=e.root_receipt_sha256
        AND ((bound_event.work_id IS NULL AND bound_event.canonical_request IS NULL)
         OR (bound_event.work_id=w.id AND bound_event.canonical_request=candidate))
       RETURNING bound_event.* INTO e;
      IF NOT FOUND THEN RAISE EXCEPTION 'SCENE56_EVENT_BIND_CAS_CONFLICT' USING ERRCODE='PT409';END IF;
      native_claim:=public.mission_generic_dispatch_claim_v1(e.root_principal,candidate);
      IF native_claim->>'state'='claimed' AND native_claim->'granted_now'='true'::jsonb THEN
       native_claim:=jsonb_build_object('mode','normal','body',native_claim);outcome:='dispatch';
      ELSE outcome:='uncertain';candidate:=NULL;native_claim:=NULL;END IF;
     ELSIF w.state IN('claimed','authorized','provider_started','failed') THEN
      outcome:='uncertain';candidate:=NULL;
     ELSE outcome:='waiting';candidate:=NULL;END IF;
    END IF;
   END IF;
   progress:=jsonb_build_object('schema_version','mission-event-next/1','event_key',e.event_key,'event_version',e.event_version,
    'claim_id',e.claim_id,'master_session_id',e.master_session_id,'state',outcome,'request',candidate,'native_claim',native_claim);
   UPDATE mission_generic_owner.event_outbox_v1 SET next_result=jsonb_set(progress,'{native_claim}','null'::jsonb),
    native_claim_sha256=CASE WHEN native_claim IS NOT NULL THEN public.combat_v2_sha256(native_claim) ELSE native_claim_sha256 END,
    work_id=CASE WHEN outcome='dispatch' THEN w.id ELSE work_id END,
    canonical_request=CASE WHEN outcome='dispatch' THEN candidate ELSE canonical_request END,updated_at=clock_timestamp()
    WHERE event_key=e.event_key AND event_version=e.event_version;
   RETURN progress;
  END IF;
 END IF;
 PERFORM public.master_v2_lock_scope(e.master_session_id);
 IF EXISTS(SELECT 1 FROM public.mission_run_state r WHERE r.master_session_id=e.master_session_id AND r.run_phase NOT IN('preparazione','in_corso'))
 OR EXISTS(SELECT 1 FROM mission_generic_owner.unified_batches b WHERE b.master_session_id=e.master_session_id AND b.state='needs_review') THEN
 outcome:='waiting';
 ELSE
 IF EXISTS(SELECT 1 FROM mission_generic_owner.event_outbox_v1 newer WHERE newer.event_key=e.event_key AND newer.event_version>e.event_version) THEN outcome:='waiting';END IF;
 IF e.event_domain='role_window' THEN
 IF NOT EXISTS(SELECT 1 FROM mission_generic_owner.role_submissions c JOIN mission_generic_owner.role_window_cursors rc
 ON rc.master_session_id=c.master_session_id AND rc.window_epoch=c.window_epoch
 WHERE c.master_session_id=e.master_session_id AND c.message_id=e.source_id
 AND public.combat_v2_sha256(to_jsonb(c))=e.source_sha256) THEN outcome:='waiting';END IF;
 SELECT user_id INTO role_source_user FROM mission_generic_owner.role_submissions WHERE master_session_id=e.master_session_id AND message_id=e.source_id;
 IF e.work_id IS NULL THEN flow:=mission_generic_owner.role_flow_status_v1(e.master_session_id,role_source_user); ELSE flow:=jsonb_build_object('flow_reason','ready_to_evaluate');END IF;
 IF flow->>'flow_reason' IS DISTINCT FROM 'ready_to_evaluate' THEN outcome:='waiting';END IF;
 END IF;
 IF e.event_domain='phase' AND NOT EXISTS(SELECT 1 FROM public.mission_run_state fresh
 WHERE fresh.master_session_id=e.master_session_id AND fresh.control_version=e.event_version
 AND public.combat_v2_sha256(jsonb_build_object('step',fresh.current_step_key,'control',fresh.control_version,'plan',fresh.plan_sha256))=e.source_sha256) THEN outcome:='waiting';END IF;
 IF outcome IS NULL THEN
 req:=mission_ai_service_owner.uuid5(e.event_key,'server-event/1:'||e.event_version::text);
 -- A writer_ready event caused by this exact reissue observes its own source child, including after publication.
 -- It never uses an unrelated current work or invokes progression to manufacture another turn.
 IF e.event_domain='writer_ready' AND e.work_id IS NULL AND e.canonical_request IS NULL THEN
 SELECT cw.id,jsonb_build_object('schema_version','mission-generic-request/1','master_session_id',cw.master_session_id,
  'event_id',cw.event_id,'request_key',cw.request_key,'expected_revision',cw.revision)
 INTO writer48_child_id,writer48_child_request
 FROM mission_generic_owner.work_items cw JOIN mission_narrative_internal.dispatch_audit ca
  ON ca.details->>'successor_work_id'=cw.id::text AND ca.event_code='staff_writer_count_overflow_reissued_v1'
 JOIN LATERAL(SELECT mission_generic_owner.writer_count_reissue_proof_v1((ca.details->>'old_work_id')::uuid,NULL) proof) lp
  ON lp.proof->>'successor_work_id'=cw.id::text AND lp.proof->>'master_session_id'=cw.master_session_id::text
 WHERE cw.id=e.source_id AND cw.master_session_id=e.master_session_id AND cw.payload_sha256=e.source_sha256
  AND cw.kind='narration' AND ca.details->>'owner_user_id'=e.root_principal::text;
 END IF;
 -- Existing producer owns every wait/choice/report/transition rule. No client booleans.
 IF writer48_child_request IS NOT NULL THEN candidate:=writer48_child_request;
 ELSIF e.work_id IS NOT NULL AND e.canonical_request IS NOT NULL THEN
 candidate:=e.canonical_request;
 ELSE
 candidate:=public.mission_generic_dispatch_next_v1(e.master_session_id,e.root_principal)->'request';
 IF candidate IS NULL OR candidate='null'::jsonb THEN
 candidate:=NULL;progress:=mission_generic_owner.progress_step(e.master_session_id,e.root_principal,req);
 END IF;
 END IF;
 IF candidate IS NULL THEN candidate:=progress->'dispatch';END IF;
 IF candidate IS NULL OR candidate='null'::jsonb THEN
 candidate:=public.mission_generic_dispatch_next_v1(e.master_session_id,e.root_principal)->'request';
 END IF;
 IF candidate IS NOT NULL AND candidate<>'null'::jsonb THEN
 IF NOT mission_factory_owner.keys_exact_v2(candidate,ARRAY['schema_version','master_session_id','event_id','request_key','expected_revision'])
 OR candidate->>'schema_version'<>'mission-generic-request/1' OR candidate->>'master_session_id'<>e.master_session_id::text THEN
 RAISE EXCEPTION 'EVENT42_REQUEST_REJECTED' USING ERRCODE='42501';END IF;
 SELECT * INTO STRICT w FROM mission_generic_owner.work_items WHERE master_session_id=e.master_session_id
 AND event_id=(candidate->>'event_id')::uuid AND request_key=(candidate->>'request_key')::uuid
 AND revision=(candidate->>'expected_revision')::integer;
 IF e.recovery_request_key IS NOT NULL AND (mission_generic_owner.director_incomplete_reissue_proof_v1(w.id,e.root_principal)->'can_reissue'='true'::jsonb) IS TRUE THEN
 writer48_source_work:=w;writer48_source_request:=candidate;
 IF e.work_id IS DISTINCT FROM w.id OR e.canonical_request IS DISTINCT FROM candidate OR e.settle_result IS NOT NULL THEN
  RAISE EXCEPTION 'EVENT50_REISSUE_SOURCE_DRIFT' USING ERRCODE='42501';END IF;
 writer46:=mission_generic_owner.director_incomplete_reissue_v1(w.id,e.root_principal);candidate:=writer46->'request';
 IF writer46->>'schema_version' IS DISTINCT FROM 'mission-director-incomplete-reissue-result/1'
 OR NOT mission_factory_owner.keys_exact_v2(candidate,ARRAY['schema_version','master_session_id','event_id','request_key','expected_revision'])
 OR candidate->>'schema_version' IS DISTINCT FROM 'mission-generic-request/1' OR candidate->>'master_session_id' IS DISTINCT FROM e.master_session_id::text
 THEN RAISE EXCEPTION 'EVENT50_REISSUE_REQUEST' USING ERRCODE='42501';END IF;
 SELECT * INTO STRICT w FROM mission_generic_owner.work_items WHERE id=(writer46->>'successor_work_id')::uuid
  AND master_session_id=e.master_session_id AND event_id=(candidate->>'event_id')::uuid
  AND request_key=(candidate->>'request_key')::uuid AND revision=(candidate->>'expected_revision')::bigint;
 UPDATE mission_generic_owner.event_outbox_v1 ev50 SET work_id=w.id,canonical_request=candidate,
 claim_txid=txid_current(),claim_backend=pg_backend_pid(),updated_at=clock_timestamp()
 WHERE ev50.event_key=e.event_key AND ev50.event_version=e.event_version AND to_jsonb(ev50)=to_jsonb(e)
  AND ev50.state='running' AND ev50.claim_id=p_claim_id AND ev50.claim_expires_at>clock_timestamp()
 RETURNING to_jsonb(ev50) INTO writer48_event_after;
 IF NOT FOUND THEN RAISE EXCEPTION 'EVENT50_REISSUE_FENCE_CAS' USING ERRCODE='40001';END IF;
 INSERT INTO mission_narrative_internal.dispatch_audit(receipt_id,event_code,details)
 VALUES(writer48_source_work.dispatch_receipt_id,'staff_director_incomplete_event_rebound_v1',jsonb_build_object(
  'schema_version','mission-director-incomplete-event-rebind/1','event_key',e.event_key,'event_version',e.event_version,
  'claim_id',e.claim_id,'recovery_request_key',e.recovery_request_key,'root_principal',e.root_principal,
  'old_work_id',writer48_source_work.id,'old_request_sha256',public.combat_v2_sha256(writer48_source_request),
  'successor_work_id',w.id,'successor_request_sha256',public.combat_v2_sha256(candidate),
  'reissue_audit_sha256',writer46->>'audit_sha256','source_event_snapshot',to_jsonb(e),
  'source_event_sha256',public.combat_v2_sha256(to_jsonb(e)),'rebound_event_sha256',public.combat_v2_sha256(writer48_event_after)));
 native_claim:=public.mission_generic_dispatch_claim_v1(e.root_principal,candidate);native_mode:='normal';
 ELSIF e.recovery_request_key IS NOT NULL AND mission_generic_owner.writer_count_reissue_proof_v1(w.id,e.root_principal) IS NOT NULL THEN
 writer48_source_work:=w;writer48_source_request:=candidate;
 IF e.work_id IS DISTINCT FROM w.id OR e.canonical_request IS DISTINCT FROM candidate OR e.settle_result IS NOT NULL THEN
  RAISE EXCEPTION 'EVENT48_REISSUE_SOURCE_DRIFT' USING ERRCODE='42501';END IF;
 writer46:=mission_generic_owner.writer_count_reissue_v1(w.id,e.root_principal);candidate:=writer46->'request';
 IF writer46->>'schema_version' IS DISTINCT FROM 'mission-writer-count-reissue-result/1'
 OR NOT mission_factory_owner.keys_exact_v2(candidate,ARRAY['schema_version','master_session_id','event_id','request_key','expected_revision'])
 OR candidate->>'schema_version' IS DISTINCT FROM 'mission-generic-request/1' OR candidate->>'master_session_id' IS DISTINCT FROM e.master_session_id::text
 THEN RAISE EXCEPTION 'EVENT46_WRITER_REISSUE_REJECTED' USING ERRCODE='42501';END IF;
 SELECT * INTO STRICT w FROM mission_generic_owner.work_items WHERE id=(writer46->>'successor_work_id')::uuid
  AND master_session_id=e.master_session_id AND event_id=(candidate->>'event_id')::uuid
  AND request_key=(candidate->>'request_key')::uuid AND revision=(candidate->>'expected_revision')::bigint;
 -- Count terminalization legitimately closes the old event via event_capture. Transfer only this still-live explicit claim.
 SELECT * INTO STRICT writer48_terminal_event FROM mission_generic_owner.event_outbox_v1
  WHERE event_key=e.event_key AND event_version=e.event_version FOR UPDATE;
 IF writer48_terminal_event.state NOT IN('running','terminal')
 OR (writer48_source_work.state='claimed' AND writer48_terminal_event.state IS DISTINCT FROM 'terminal')
 OR to_jsonb(writer48_terminal_event)-ARRAY['state','updated_at'] IS DISTINCT FROM to_jsonb(e)-ARRAY['state','updated_at']
 OR writer48_terminal_event.claim_id IS DISTINCT FROM p_claim_id OR writer48_terminal_event.claim_expires_at<=clock_timestamp()
 OR writer48_terminal_event.recovery_request_key IS NULL
 OR writer46->>'old_work_id' IS DISTINCT FROM writer48_source_work.id::text
 OR writer46->>'audit_sha256' IS DISTINCT FROM mission_generic_owner.writer_count_reissue_proof_v1(writer48_source_work.id,NULL)->>'audit_sha256'
 THEN RAISE EXCEPTION 'EVENT48_REISSUE_FENCE_DRIFT' USING ERRCODE='42501';END IF;
 UPDATE mission_generic_owner.event_outbox_v1 ev48 SET state='running',claim_txid=txid_current(),claim_backend=pg_backend_pid(),
  claim_history=ev48.claim_history||jsonb_build_array(jsonb_build_object('claim_id',ev48.claim_id,'expires_at',ev48.claim_expires_at,
   'state',ev48.state,'recovery_request_key',ev48.recovery_request_key,'settle_result',ev48.settle_result,
   'next_result_sha256',CASE WHEN ev48.next_result IS NULL THEN NULL ELSE public.combat_v2_sha256(ev48.next_result) END)),
  work_id=w.id,canonical_request=candidate,updated_at=clock_timestamp()
 WHERE ev48.event_key=e.event_key AND ev48.event_version=e.event_version AND to_jsonb(ev48)=to_jsonb(writer48_terminal_event)
  AND ev48.claim_id=p_claim_id AND ev48.claim_expires_at>clock_timestamp()
 RETURNING to_jsonb(ev48) INTO writer48_event_after;
 IF NOT FOUND THEN RAISE EXCEPTION 'EVENT48_REISSUE_FENCE_CAS_LOST' USING ERRCODE='40001';END IF;
 INSERT INTO mission_narrative_internal.dispatch_audit(receipt_id,event_code,details)
 VALUES(writer48_source_work.dispatch_receipt_id,'staff_writer_count_event_rebound_v1',jsonb_build_object(
  'schema_version','mission-writer-count-event-rebind/1','event_key',e.event_key,'event_version',e.event_version,
  'claim_id',e.claim_id,'recovery_request_key',e.recovery_request_key,'root_principal',e.root_principal,
  'root_receipt_sha256',e.root_receipt_sha256,'source_id',e.source_id,'source_sha256',e.source_sha256,
  'old_work_id',writer48_source_work.id,'old_request_sha256',public.combat_v2_sha256(writer48_source_request),
  'successor_work_id',w.id,'successor_request_sha256',public.combat_v2_sha256(candidate),
  'reissue_audit_sha256',writer46->>'audit_sha256','terminal_event_snapshot',to_jsonb(writer48_terminal_event),
  'terminal_event_sha256',public.combat_v2_sha256(to_jsonb(writer48_terminal_event)),
  'rebound_event_sha256',public.combat_v2_sha256(writer48_event_after)));
 -- The ordinary dispatcher still requires running state, same principal, live nonce/lease and this transaction/backend.
 native_claim:=public.mission_generic_dispatch_claim_v1(e.root_principal,candidate);native_mode:='normal';
 ELSIF e.recovery_request_key IS NOT NULL AND w.state='failed' AND w.kind='director'
 AND(mission_generic_owner.retained_director_adoption_v1(w.id,false)->>'owner_user_id'=e.root_principal::text) IS TRUE THEN
 native_claim:=jsonb_build_object('mode','retained_director','body',jsonb_build_object('schema_version','mission-retained-director-recovery/1',
 'mode','prepare','master_session_id',w.master_session_id,'work_id',w.id));outcome:='dispatch';paid_action:=true;
 ELSIF e.recovery_request_key IS NOT NULL AND w.state='failed' AND w.kind='narration'
 AND w.result->'ok'='true'::jsonb AND w.result->>'provider_calls'='1' AND w.result->'outcome_uncertain'='false'::jsonb
 AND (w.result_sha256=public.combat_v2_sha256(w.result) OR EXISTS(
 SELECT 1 FROM mission_narrative_internal.dispatch_audit hp_finalized
 WHERE hp_finalized.receipt_id=w.dispatch_receipt_id AND hp_finalized.event_code='generic_finalized'
 AND hp_finalized.details->>'work_id'=w.id::text
 AND hp_finalized.details->>'receipt_id'=w.receipt_id::text
 AND hp_finalized.details->>'state'=w.state
 AND hp_finalized.details->'message_id' IS NOT DISTINCT FROM coalesce(to_jsonb(w.message_id),'null'::jsonb)
 AND hp_finalized.details->>'result_sha256'=w.result_sha256
 AND hp_finalized.details->>'result_jsonb_sha256'=public.combat_v2_sha256(w.result))) THEN
 native_claim:=jsonb_build_object('mode','cached_publication','body',jsonb_build_object('schema_version','mission-generic-staff-cached-publication/1',
 'master_session_id',w.master_session_id,'work_id',w.id));outcome:='dispatch';paid_action:=true;
 ELSIF e.recovery_request_key IS NOT NULL AND w.state='claimed' AND w.lease_expires_at<=clock_timestamp()
 AND EXISTS(SELECT 1 FROM mission_narrative_internal.dispatch_audit a WHERE a.receipt_id=w.dispatch_receipt_id AND a.event_code='c8_count_success'
  AND a.details->'generation_allowed'='true'::jsonb AND a.details->'generation_http_calls'='0'::jsonb)
 AND w.authorization_id IS NULL AND w.dispatch_id IS NULL AND w.result IS NULL
 AND NOT EXISTS(SELECT 1 FROM mission_narrative_internal.dispatch_attempts da WHERE da.receipt_id=w.dispatch_receipt_id)
 AND NOT EXISTS(SELECT 1 FROM mission_narrative_internal.provider_authorizations pa WHERE pa.receipt_id=w.dispatch_receipt_id)
 AND NOT EXISTS(SELECT 1 FROM mission_narrative_internal.dispatch_audit a WHERE a.receipt_id=w.dispatch_receipt_id AND a.event_code='c8_count_unknown') THEN
 -- Existing RPC owns all Count/source/request/prices/ticket/current-authority checks and grants the real replacement lease.
 native_claim:=public.mission_generic_counted_resume_v1(e.root_principal,candidate);native_mode:='counted_resume';
 ELSIF(w.state='ready' AND w.lease_id IS NULL OR w.state='claimed' AND w.lease_expires_at<=clock_timestamp())
 AND w.authorization_id IS NULL AND w.dispatch_id IS NULL AND w.result IS NULL AND w.receipt_id IS NULL
 AND NOT EXISTS(SELECT 1 FROM mission_narrative_internal.dispatch_audit a WHERE a.receipt_id=w.dispatch_receipt_id AND a.event_code='c8_count_started')
 AND NOT EXISTS(SELECT 1 FROM mission_narrative_internal.provider_authorizations pa WHERE pa.receipt_id=w.dispatch_receipt_id)
 AND NOT EXISTS(SELECT 1 FROM mission_narrative_internal.dispatch_attempts da WHERE da.receipt_id=w.dispatch_receipt_id) THEN
 UPDATE mission_generic_owner.event_outbox_v1 SET claim_txid=txid_current(),claim_backend=pg_backend_pid(),
 work_id=w.id,canonical_request=candidate WHERE event_key=e.event_key AND event_version=e.event_version;
 native_claim:=public.mission_generic_dispatch_claim_v1(e.root_principal,candidate);native_mode:='normal';
 ELSE
  -- Observe existing in-flight work only; no lease, claim, dispatch or replay is granted.
  IF writer48_child_id IS NOT NULL AND w.id=writer48_child_id AND candidate=writer48_child_request THEN
   event43_observed_work:=w.id;event43_observed_request:=candidate;
   IF w.state IN('completed','failed') AND w.receipt_id IS NOT NULL AND w.finalized_at IS NOT NULL
    AND(w.result_sha256=public.combat_v2_sha256(w.result) OR EXISTS(SELECT 1 FROM mission_narrative_internal.dispatch_audit wf
     WHERE wf.receipt_id=w.dispatch_receipt_id AND wf.event_code='generic_finalized' AND wf.details->>'work_id'=w.id::text
      AND wf.details->>'receipt_id'=w.receipt_id::text AND wf.details->>'state'=w.state
      AND wf.details->>'result_sha256'=w.result_sha256 AND wf.details->>'result_jsonb_sha256'=public.combat_v2_sha256(w.result)))
   THEN outcome:='terminal';ELSE outcome:='uncertain';END IF;
  ELSIF e.event_domain='native_input' AND e.work_id IS NULL AND e.canonical_request IS NULL
   AND w.kind='narration' AND w.state IN('claimed','authorized','provider_started')
   AND candidate=jsonb_build_object('schema_version','mission-generic-request/1',
   'master_session_id',w.master_session_id,'event_id',w.event_id,
   'request_key',w.request_key,'expected_revision',w.revision)
   AND EXISTS(
   WITH event43_sources AS MATERIALIZED (SELECT src.round_id,src.declaration_id,src.coverage_id,src.source_kind
 FROM (
 SELECT dc.round_id,dc.defense_declaration_id AS declaration_id,dc.id AS coverage_id,'coverage'::text AS source_kind
 FROM public.combat_v2_defense_coverages dc
 JOIN public.combat_v2_declarations dd ON dd.id=dc.defense_declaration_id AND dd.round_id=dc.round_id
 JOIN public.combat_v2_actors aa ON aa.id=dd.actor_id AND aa.actor_kind='pg'
 WHERE dc.id=e.source_id AND e.source_sha256 IN(
 public.combat_v2_sha256(to_jsonb(dc)),
 public.combat_v2_sha256(jsonb_set(to_jsonb(dc),'{state}','"dichiarata"'::jsonb)))
 UNION ALL
 SELECT rt.round_id,rt.declaration_id,NULL::uuid,'rating'::text
 FROM public.combat_v2_ratings rt
 JOIN public.combat_v2_declarations dd ON dd.id=rt.declaration_id AND dd.round_id=rt.round_id
 WHERE rt.id=e.source_id AND rt.is_active
 AND e.source_sha256 IN(public.combat_v2_sha256(to_jsonb(rt)),
 public.combat_v2_sha256(jsonb_set(to_jsonb(rt),'{frozen_at}','null'::jsonb)))
 UNION ALL
 SELECT dd.round_id,dd.id,NULL::uuid,'declaration'::text
 FROM public.combat_v2_declarations dd JOIN public.combat_v2_actors aa ON aa.id=dd.actor_id AND aa.actor_kind='pg'
 WHERE dd.id=e.source_id AND e.source_sha256=public.combat_v2_sha256(to_jsonb(dd))
 ) src)
   SELECT 1 FROM event43_sources event43_src
   JOIN public.combat_v2_rounds event43_round ON event43_round.id=event43_src.round_id
   JOIN public.combat_v2_sessions event43_enc ON event43_enc.id=event43_round.session_id
    AND event43_enc.master_session_id=e.master_session_id
   JOIN public.master_v2_sessions event43_master ON event43_master.id=e.master_session_id
    AND event43_master.location_id=event43_enc.location_id
   JOIN mission_generic_owner.work_items event43_observed
    ON event43_observed.id=w.id AND event43_observed.master_session_id=e.master_session_id
    AND event43_observed.kind='narration' AND event43_observed.state IN('claimed','authorized','provider_started')
    AND event43_observed.event_id=w.event_id AND event43_observed.request_key=w.request_key
    AND event43_observed.revision=w.revision AND event43_observed.authority_receipt_id=w.authority_receipt_id
    AND event43_observed.encounter_id=event43_enc.id
   JOIN mission_generic_owner.unified_batches event43_batch
    ON event43_batch.master_session_id=e.master_session_id AND event43_batch.encounter_id=event43_enc.id
    AND event43_batch.source_round_id=event43_round.id
    AND event43_batch.source_report_id=event43_round.report_id
   WHERE (SELECT count(*) FROM event43_sources)=1
   AND e.event_key=mission_ai_service_owner.uuid5(event43_round.id,'server-event:native-input')
   AND e.created_at<=event43_batch.created_at
   AND event43_batch.id=w.event_id AND event43_batch.id=w.authority_receipt_id
   AND event43_batch.writer_work_id=w.id AND event43_batch.encounter_id=w.encounter_id
   AND event43_batch.state IN('preparing','ready') AND event43_batch.retired_at IS NULL
   AND event43_batch.message_id IS NULL
   AND NOT EXISTS(SELECT 1 FROM mission_generic_owner.unified_batches event43_other
    WHERE event43_other.master_session_id=e.master_session_id
    AND event43_other.source_round_id=event43_round.id AND event43_other.id<>event43_batch.id
    AND event43_other.retired_at IS NULL AND event43_other.state IN('preparing','ready','published'))
   ) THEN event43_observed_work:=w.id;event43_observed_request:=candidate;END IF;
  IF outcome IS NULL THEN outcome:='uncertain';END IF;candidate:=NULL;
 END IF;
 IF NOT paid_action AND native_mode IS NOT NULL THEN
 IF native_claim->>'state'='claimed' AND native_claim->'granted_now'='true'::jsonb THEN
 native_claim:=jsonb_build_object('mode',native_mode,'body',native_claim);outcome:='dispatch';
 ELSE outcome:='uncertain';candidate:=NULL;native_claim:=NULL;END IF;
 END IF;
 ELSE outcome:='waiting';candidate:=NULL; END IF;
 END IF;
 END IF;
 progress:=jsonb_build_object('schema_version','mission-event-next/1','event_key',e.event_key,'event_version',e.event_version,
 'claim_id',e.claim_id,'master_session_id',e.master_session_id,'state',outcome,'request',candidate,'native_claim',native_claim);
 UPDATE mission_generic_owner.event_outbox_v1 SET next_result=jsonb_set(progress,'{native_claim}','null'::jsonb),native_claim_sha256=CASE WHEN native_claim IS NOT NULL THEN public.combat_v2_sha256(native_claim) ELSE native_claim_sha256 END,
 work_id=CASE WHEN outcome='dispatch' THEN w.id
 WHEN event43_observed_work IS NOT NULL AND work_id IS NULL AND canonical_request IS NULL THEN event43_observed_work ELSE work_id END,
 canonical_request=CASE WHEN outcome='dispatch' THEN candidate
 WHEN event43_observed_work IS NOT NULL AND work_id IS NULL AND canonical_request IS NULL THEN event43_observed_request ELSE canonical_request END,updated_at=clock_timestamp()
 WHERE event_key=e.event_key AND event_version=e.event_version;
 RETURN progress;
END $$;
CREATE OR REPLACE FUNCTION mission_generic_owner.finish_scope(p_session uuid, p_cap uuid, p_outcome text) RETURNS boolean LANGUAGE plpgsql SECURITY DEFINER SET search_path TO '' AS $$
declare m public.master_v2_sessions;r public.mission_run_state;b mission_generic_owner.board_starts;
 settings jsonb;sim boolean;principals uuid[];permit56 boolean:=false;receipt56 mission_generic_owner.staff_finish_receipts_v1;proof56 jsonb;
begin
 perform mission_ai_service_owner.service_only();
 perform mission_generic_owner.assert_runtime(p_session);
 perform mission_ai_service_owner.assert_capability(p_session,p_cap);
 select * into strict m from public.master_v2_sessions where id=p_session for update;
 select * into strict r from public.mission_run_state where master_session_id=p_session for update;
 select * into strict b from mission_generic_owner.board_starts where master_session_id=p_session and capability_id=p_cap;
 IF EXISTS(SELECT 1 FROM mission_narrative_internal.scene_runtime_v1 WHERE master_session_id=p_session AND is_active) THEN
  SELECT * INTO receipt56 FROM mission_generic_owner.staff_finish_receipts_v1 WHERE master_session_id=p_session
   AND state='preparing' AND transaction_id=txid_current();
  IF receipt56.request_key IS NOT NULL THEN
   proof56:=mission_narrative_internal.scene_finish_proof_v1(p_session,receipt56.actor_user_id);
   permit56:=proof56->'can_finish'='true'::jsonb
    AND receipt56.source_revision=proof56->>'source_revision'
    AND receipt56.publication_id=(proof56->>'publication_id')::uuid
    AND receipt56.request_key=(proof56->>'request_key')::uuid
    AND receipt56.history_proof=proof56->'history_items'
    AND receipt56.history_proof_sha256=public.combat_v2_sha256(proof56->'history_items');
  END IF;
 END IF;
 settings:=mission_generic_owner.run_plan_settings(p_session);
 if m.owner_kind<>'ai_service' or m.master_user is not null or m.mission_id is null or m.suspended_at is not null
 or m.stato not in('in_corso','chiusura','chiusa') or r.run_phase not in('in_corso','conclusa','fallita')
 or (r.run_phase<>'in_corso' and r.run_phase<>(case when p_outcome='success' then 'conclusa' else 'fallita' end))
 or b.state<>'published' or b.snapshot_sha256<>mission_internal.fingerprint(b.snapshot)
 or (select count(*) from jsonb_array_elements(settings->'terminal_steps') x
   where x->>'step_key'=r.current_step_key and x->>'outcome'=p_outcome)<>1
 or exists(select 1 from public.mission_run_outbox where master_session_id=p_session and state='pending')
 or (exists(select 1 from mission_generic_owner.work_items where master_session_id=p_session and state<>'completed') AND (CASE WHEN EXISTS(SELECT 1 FROM mission_narrative_internal.scene_runtime_v1 WHERE master_session_id=p_session AND is_active) THEN permit56 ELSE mission_generic_owner.staff_finish_permit_v1(p_session) END) IS DISTINCT FROM true)
 or exists(select 1 from public.combat_v2_sessions where master_session_id=p_session and (state<>'chiuso' or closed_at is null))
 or exists(select 1 from public.combat_v2_sessions s join public.combat_v2_rounds rr on rr.session_id=s.id
  where s.master_session_id=p_session and rr.state<>'narrato')
 then raise exception 'MGP_FINISH_AUTHORITY' using errcode='42501';end if;
 -- Il Fato conclusivo è quello della visita terminale oppure della transizione
 -- terminale pubblicata insieme al suo evento autorevole nello stesso batch.
 if not exists(select 1 from mission_generic_owner.work_items w where w.master_session_id=p_session
 and w.kind='narration' and w.state='completed' and w.step_key=r.current_step_key
 and w.run_control_version=case when r.run_phase='in_corso' then r.control_version else r.control_version-1 end
 and w.message_id is not null)
 and not exists(
   select 1 from public.mission_run_events ev
   join public.mission_run_publications pub on pub.event_id=ev.id
     and pub.master_session_id=ev.master_session_id and pub.status='committed'
     and pub.source='model' and pub.expected_step_key=ev.step_after
     and pub.expected_event_version_after=ev.version_after
     and pub.expected_run_control_version=ev.version_after
     and pub.context_fingerprint=ev.context_fingerprint
   join public.mission_run_messages rm on rm.publication_id=pub.id
     and rm.body_sha256=pub.body_sha256
   join public.messages msg on msg.id=rm.message_id and msg.kind='fato'
     and msg.location_id=m.location_id
     and encode(extensions.digest(convert_to(msg.body,'UTF8'),'sha256'),'hex')=rm.body_sha256
   join mission_generic_owner.work_items w on w.message_id=msg.id
     and w.master_session_id=ev.master_session_id
     and w.kind='narration' and w.state='completed'
     and w.step_key=ev.step_before and w.run_control_version=ev.version_before
   join mission_generic_owner.unified_batches ub on ub.writer_work_id=w.id
     and ub.master_session_id=ev.master_session_id and ub.state='published'
     and ub.message_id=msg.id
   where ev.master_session_id=p_session and ev.operation_kind='transition'
     and ev.status='committed' and ev.step_after=r.current_step_key
     and ev.version_after=case when r.run_phase='in_corso' then r.control_version else r.control_version-1 end
     and ev.plan_version_id=r.plan_version_id
     and (
       (ub.step_key=ev.step_after and ub.run_control_version=ev.version_after
         and ub.route->>'event_id'=ev.id::text)
       or
       (ub.composition_kind='combat_exit' and ub.step_key=ev.step_before
         and ub.run_control_version=ev.version_before
         and ub.route->>'to_step_key'=ev.step_after
         and ub.route->>'transition_key'=ev.transition_key)
     )
 )
 then raise exception 'MGP_FINISH_NARRATION_BARRIER';end if;
 select is_test into strict sim from public.locations where id=m.location_id and is_active;
 if b.simulation is distinct from sim then raise exception 'MGP_FINISH_SIMULATION_DRIFT';end if;
 if sim then
  select array_agg(distinct p.user_id_snapshot) into principals from public.master_v2_participants p
  join public.characters c on c.id=p.character_id and c.user_id=p.user_id_snapshot where p.session_id=p_session;
  if m.location_id<>'0b85f354-9cdb-47e1-baf9-3d266bb7e06b'::uuid
  or coalesce(cardinality(principals),0)=0 or combat_consumer_private.staff_test_allowed(m.location_id,principals,false) is distinct from true
  or not exists(select 1 from mission_generic_owner.simulation_sources x where x.carrier_mission_id=m.mission_id
   and x.source_sha256~'^[0-9a-f]{64}$')
  then raise exception 'MGP_FINISH_PROTECTED_SOURCE' using errcode='42501';end if;
 else
  if exists(select 1 from mission_generic_owner.simulation_sources where carrier_mission_id=m.mission_id)
  then raise exception 'MGP_FINISH_CARRIER_IN_REAL_ROOM';end if;
  -- Il premiato è esattamente il roster reale congelato, non un nuovo iscritto.
  if (select array_agg(character_id order by character_id) from public.mission_bookings where mission_id=m.mission_id
       and status in('iscritto','completata','fallita')) is distinct from
     (select array_agg(character_id order by character_id) from public.master_v2_participants where session_id=p_session)
  then raise exception 'MGP_FINISH_BOOKING_ROSTER_DRIFT';end if;
 end if;
 return sim;
end $$;
CREATE OR REPLACE FUNCTION exam_human_private.narrative_message_guard_v1() RETURNS trigger LANGUAGE plpgsql SECURITY DEFINER SET search_path TO '' AS $$
declare r exam_human_private.requests%rowtype; p exam_human_private.narrative_permits%rowtype;
 ns exam_human_private.narrative_state%rowtype;
 op exam_human_private.round_opening_publication_permits_v1%ROWTYPE;
 barrier_master uuid; barrier_actor uuid; barrier_state jsonb;
begin
 IF TG_OP='INSERT' AND mission_narrative_internal.scene_message_permitted_v1(NEW) THEN RETURN NEW;END IF;

 if tg_op='INSERT' then
   select permit.* into op from exam_human_private.round_opening_publication_permits_v1 permit
     join exam_human_private.round_publication_windows_v1 w on w.id=permit.window_id
     join exam_human_private.requests e on e.id=permit.exam_id
     where permit.active and permit.transaction_id=txid_current()
       and permit.backend_pid=pg_backend_pid() and permit.actor_user=auth.uid()
       and e.master_user=auth.uid() and e.state='combat'
       and e.location_id=new.location_id
       and w.exam_id=e.id and w.state='private' and w.side='png'
       and w.source_round_id is null
       and new.kind='fato' and new.character_id is null
       and new.recipient_user is null and new.companion_id is null
       and new.companion_body is null
       and permit.body_sha256=public.combat_v2_sha256(jsonb_build_object('body',btrim(new.body)))
     for update of permit;
   if op.id is not null then
     update exam_human_private.round_opening_publication_permits_v1
       set message_id=new.id where id=op.id and message_id is null;
     if not found then raise exception 'REGIA_OPENING_MESSAGE_DUPLICATE'; end if;
     return new;
   end if;
 end if;
 -- C1244: una role pubblica PG rispetta la stessa ricevuta del Fato Native.
 -- Il ruolo Staff/Master non esenta il suo PG; whisper, PNG e Fato restano fuori.
 if tg_op='INSERT' and new.kind='say' and new.character_id is not null
   and new.recipient_user is null and auth.uid() is not null then
  select m.id,a.id into barrier_master,barrier_actor
   from public.master_v2_sessions m
   join public.locations l on l.id=m.location_id
   join public.combat_v2_sessions s on s.master_session_id=m.id
   join public.combat_v2_actors a on a.session_id=s.id
   join public.characters c on c.id=a.character_id and c.user_id=auth.uid()
   join public.master_v2_participants participant on participant.session_id=m.id
    and participant.character_id=c.id and participant.user_id_snapshot=auth.uid()
    and participant.left_at is null and participant.engagement_state='attivo'
   where m.location_id=new.location_id and m.owner_kind='human'
    and m.closed_at is null and m.stato in ('in_corso','sospesa')
    and l.id='0b85f354-9cdb-47e1-baf9-3d266bb7e06b'::uuid
    and l.is_active and l.is_test
    and s.state not in ('chiuso','annullato')
    and a.character_id=new.character_id and a.actor_kind='pg'
    and a.controller_user=auth.uid() and a.state='attivo' and a.companion_id is null
    and not exists(select 1 from exam_human_private.requests e
      where e.master_session_id=m.id and e.state not in ('closed','cancelled'))
    and (exists(select 1 from mission_generic_owner.regia_human_session_optins_v1 opt
          where opt.master_session_id=m.id and opt.actor_user=m.master_user)
      or exists(select 1 from mission_generic_owner.regia_human_admissions_v1 adm
          where adm.master_session_id=m.id and adm.encounter_id=s.id)
      or exists(select 1 from mission_generic_owner.unified_round_windows uw
          join public.combat_v2_rounds ur on ur.id=uw.round_id
          where uw.master_session_id=m.id and ur.session_id=s.id))
   order by s.created_at desc,a.id limit 1 for update of m;
  if barrier_master is not null then
   -- Stesso primo lock di preparazione/pubblicazione: non una lettura UI obsoleta.
   begin
    barrier_state:=public.regia_round_publication_state_v1(barrier_master,barrier_actor);
   exception when others then
    raise exception 'REGIA_FATO_PENDING' using errcode='55000';
   end;
   if jsonb_typeof(barrier_state) is distinct from 'object'
     or barrier_state->>'schema_version' is distinct from 'regia-round-publication-state/1'
     or barrier_state->>'status' is distinct from 'ready'
     or jsonb_typeof(barrier_state->'public') is distinct from 'object'
     or barrier_state#>>'{public,schema_version}' is distinct from 'regia-round-public/1'
     or not (barrier_state->'public' ? 'reason_code')
     or barrier_state#>'{public,reason_code}' is distinct from 'null'::jsonb
     or jsonb_typeof(barrier_state#>'{public,permissions}') is distinct from 'object'
     or jsonb_typeof(barrier_state#>'{public,permissions,main}') is distinct from 'boolean'
     or jsonb_typeof(barrier_state#>'{public,permissions,defense}') is distinct from 'boolean'
     or jsonb_typeof(barrier_state#>'{public,permissions,reaction}') is distinct from 'boolean'
   then raise exception 'REGIA_FATO_PENDING' using errcode='55000'; end if;
  end if;
 end if;
 if tg_op='INSERT' and exam_human_private.round_message_v1(new) then return new; end if;
 if tg_op<>'INSERT' then
  if exists(select 1 from exam_human_private.round_messages where message_id=old.id) then raise exception 'EHM_ROUND_HISTORY_IMMUTABLE'; end if;
  if exists(select 1 from exam_human_private.narrative_events where message_id=old.id)
  then raise exception 'EHM_NARRATIVE_HISTORY_IMMUTABLE'; end if;
  if tg_op='DELETE' then return old; end if;
  if exists(select 1 from exam_human_private.requests q join exam_human_private.native_bindings b on b.exam_request_id=q.id
   where q.location_id=new.location_id and q.state not in ('closed','cancelled')
    and (new.character_id=q.character_id or auth.uid()=q.master_user or new.kind in ('fato','png','motore')))
  then raise exception 'EHM_DEDICATED_NARRATIVE_PORT_REQUIRED'; end if;
  return new;
 end if;
 select q.* into r from exam_human_private.requests q join exam_human_private.native_bindings b on b.exam_request_id=q.id
 where q.location_id=new.location_id and q.state not in ('closed','cancelled')
  and (new.character_id=q.character_id or auth.uid()=q.master_user or new.kind in ('fato','png','motore'));
 if not found then return new; end if;
 select x.* into p from exam_human_private.narrative_permits x
 join exam_human_private.narrative_operations o using(exam_id,request_key)
 where x.exam_id=r.id and x.actor_user=auth.uid() and x.transaction_id=txid_current()
  and x.backend_pid=pg_backend_pid() and x.message_id is null and o.receipt is null for update of x;
 if not found or new.body is distinct from p.body or new.recipient_user is not null
  or new.companion_id is not null or new.companion_body is not null
  or (p.operation='role' and (new.character_id is distinct from r.character_id or new.kind<>'say' or p.actor_user<>r.owner_user))
  or (p.operation in ('incipit','esito','combat_return','finale') and (new.character_id is not null or new.kind<>'fato' or p.actor_user<>r.master_user))
 then raise exception 'EHM_DEDICATED_NARRATIVE_PORT_REQUIRED' using errcode='42501'; end if;
 select * into ns from exam_human_private.narrative_state where exam_id=r.id;
 insert into exam_human_private.narrative_events(message_id,exam_id,request_key,ordinal,operation,actor_user,consumes_role)
 values(new.id,r.id,p.request_key,coalesce(ns.ordinal,0)+1,p.operation,p.actor_user,
  case when p.operation in('esito','finale') then ns.pending_role else null end);
 update exam_human_private.narrative_permits set message_id=new.id where exam_id=r.id and request_key=p.request_key;
 return new;
end $$;
CREATE OR REPLACE FUNCTION mission_generic_owner.opening_published(p_session uuid, p_publication uuid) RETURNS void LANGUAGE plpgsql SECURITY DEFINER SET search_path TO '' AS $$
declare s mission_generic_owner.board_starts;r public.mission_run_state;m public.master_v2_sessions;
begin
 select * into strict m from public.master_v2_sessions where id=p_session for update;
 select * into strict r from public.mission_run_state where master_session_id=p_session for update;
 select * into strict s from mission_generic_owner.board_starts where master_session_id=p_session for update;
 if not exists(select 1 from public.mission_run_outbox o where o.event_id=s.event_id and o.master_session_id=p_session
  and o.publication_id=p_publication and o.state='published' and o.event_version_after=1)
 then raise exception 'MGB_OPENING_NOT_PUBLISHED' using errcode='40001';end if;
 IF EXISTS(SELECT 1 FROM mission_narrative_internal.scene_runtime_v1 WHERE master_session_id=p_session AND is_active) AND NOT s.simulation THEN RAISE EXCEPTION 'SCENE56_OPENING_NOT_STAFF' USING ERRCODE='42501';END IF;
 if s.state='published' then return;end if;
 if s.state<>'prepared' or m.stato<>'preparazione' or r.run_phase<>'preparazione' or m.control_version<>1 or r.control_version<>1
 then raise exception 'MGB_OPENING_STATE_DRIFT' using errcode='40001';end if;
 update public.master_v2_sessions set stato='in_corso',control_version=2 where id=p_session;
 update public.mission_run_state set run_phase='in_corso',updated_at=clock_timestamp() where master_session_id=p_session;
 update mission_ai_service_owner.capabilities set expected_control_version=2 where id=s.capability_id and state='active';
 if not found then raise exception 'MGB_OPENING_CAPABILITY_DRIFT' using errcode='40001';end if;
 if not s.simulation then
  update mission_ai_board_owner.weekly_quota set state='consumed',consumed_at=clock_timestamp()
   where activation_id=s.activation_id and state='reserved';
  update public.missions set status='programmata',master_id=null where id=m.mission_id;
 end if;
 update mission_ai_board_owner.activations set state='started',started_at=clock_timestamp(),control_version=control_version+1 where id=s.activation_id;
 update mission_generic_owner.board_starts set state='published',published_at=clock_timestamp() where id=s.id;
 IF EXISTS(SELECT 1 FROM mission_narrative_internal.scene_runtime_v1 runtime
  JOIN mission_narrative_internal.scene_sources_v1 src ON src.scene_id=runtime.id
  JOIN public.mission_run_messages mm ON mm.publication_id=p_publication AND mm.message_id=src.published_message_id
  WHERE runtime.master_session_id=p_session AND runtime.is_active AND src.request_kind='initial_opening'
   AND src.board_start_receipt_id=s.id AND src.message_permit_txid=txid_current()
   AND src.message_permit_backend=pg_backend_pid()) THEN
  INSERT INTO mission_generic_owner.role_window_cursors(master_session_id,window_epoch,role_revision,opening_fato_id,last_published_fato_id)
  SELECT p_session,1,0,mm.message_id,mm.message_id FROM public.mission_run_messages mm WHERE mm.publication_id=p_publication;
  IF NOT FOUND THEN RAISE EXCEPTION 'SCENE56_OPENING_MESSAGE_MISSING' USING ERRCODE='PT409';END IF;
  RETURN;
 END IF;

 if (s.simulation
    and exists(select 1 from mission_generic_owner.flow_staff_sessions fs
      join public.mission_run_state run_state
        on run_state.master_session_id=fs.master_session_id
      join public.master_v2_sessions master_session
        on master_session.id=fs.master_session_id
      join public.locations staff_location
        on staff_location.id=master_session.location_id
      join mission_generic_owner.simulation_sources source_binding
        on source_binding.carrier_mission_id=master_session.mission_id
      join mission_generic_owner.role_v4_plan_opt_ins optin
        on optin.plan_version_id=source_binding.source_plan_version_id
       and optin.enabled
      join public.mission_plan_versions source_version
        on source_version.id=source_binding.source_plan_version_id
       and source_version.stato='approvata'
      join public.mission_plans source_plan
        on source_plan.id=source_version.plan_id
       and source_plan.mission_id=source_binding.source_mission_id
      join public.mission_plan_versions carrier_version
        on carrier_version.id=run_state.plan_version_id
       and carrier_version.stato='approvata'
      join public.mission_plans carrier_plan
        on carrier_plan.id=carrier_version.plan_id
       and carrier_plan.mission_id=master_session.mission_id
      where fs.master_session_id=p_session and fs.enabled
        and master_session.owner_kind='ai_service'
        and master_session.closed_at is null
        and staff_location.is_test))
    OR (s.simulation
      AND m.location_id='0b85f354-9cdb-47e1-baf9-3d266bb7e06b'::uuid
      AND m.owner_kind='ai_service' AND m.closed_at IS NULL
      AND EXISTS(SELECT 1 FROM mission_generic_owner.flow_staff_sessions fs
        WHERE fs.master_session_id=p_session AND fs.enabled)
      AND mission_generic_owner.manual_staff_scope_v1(p_session) IS NOT NULL)
    OR mission_public_owner.staff_role_session_v2(p_session)
    OR mission_public_owner.role_session_allowed_v1(p_session) then
   insert into mission_generic_owner.role_window_cursors
     (master_session_id,window_epoch,role_revision,opening_fato_id,
      last_published_fato_id)
   select p_session,1,0,mm.message_id,mm.message_id
     from public.mission_run_messages mm
     where mm.publication_id=p_publication;
   if not found then raise exception 'MRS_V4_OPENING_MESSAGE_MISSING';end if;
 end if;
end;
$$;
CREATE OR REPLACE FUNCTION mission_generic_owner.progress_step(p_session uuid, p_user uuid, p_request uuid) RETURNS jsonb LANGUAGE plpgsql SECURITY DEFINER SET search_path TO '' AS $$
declare m public.master_v2_sessions;r public.mission_run_state;e mission_generic_owner.encounters;
 s public.combat_v2_sessions;roundrow public.combat_v2_rounds;rep public.combat_v2_round_reports;
 sc jsonb;spec jsonb;settings jsonb;term jsonb;cap uuid;actor uuid;res jsonb;n integer;pending jsonb;c7_budget jsonb;c21_owned boolean;
begin
 perform mission_ai_board_owner.service_only();
 -- C9: freeze policy DML through proof, Native reserve and authorization.
 LOCK TABLE mission_narrative_internal.runtime_policy IN SHARE MODE;
 perform 1 from public.locations where id=(select location_id from mission_factory_owner.quest_run_sources where session_id=p_session) for update;
 if p_request is null then raise exception 'MGP_REQUEST_REQUIRED';end if;
 perform mission_generic_owner.dispatch_user(p_session,p_user);
 perform public.master_v2_lock_scope(p_session);
 select * into strict m from public.master_v2_sessions where id=p_session for update;
 perform mission_generic_owner.assert_runtime(p_session);
 select * into strict r from public.mission_run_state where master_session_id=p_session for update;
 if m.closed_at is not null then return jsonb_build_object('schema_version','mission-generic-progress/1','master_session_id',p_session,'state','closed','dispatch',null);end if;
 c21_owned:=(EXISTS(SELECT 1 FROM mission_public_owner.work_contracts_v1 sticky_wc
 WHERE sticky_wc.master_session_id=p_session AND sticky_wc.scope='staff_mission'
 AND sticky_wc.contract_sha256=public.combat_v2_sha256(sticky_wc.contract)
 AND sticky_wc.contract->>'schema_version'='mission-narrative-admission/3'
 AND sticky_wc.contract->'features' ? 'execution_authority_v1'
 AND (sticky_wc.contract#>>'{source_attestation,execution_authority,schema_version}'='c1266-work-execution-attestation/1' OR ((mission_generic_owner.c1266_historical_work_v1(sticky_wc.work_id)->>'schema_version'='c1266-work-execution-attestation/2') AND sticky_wc.contract#>'{source_attestation,execution_authority}'=mission_generic_owner.c1266_historical_work_v1(sticky_wc.work_id)))
 AND sticky_wc.contract#>>'{source_attestation,execution_authority,execution_context}'='staff_mission'
 AND sticky_wc.contract#>>'{source_attestation,execution_authority,admission,kind}'='staff_finite'
 AND sticky_wc.contract#>>'{source_attestation,execution_authority,admission,resource_scope}'='staff_simulation'
 AND (sticky_wc.contract#>>'{source_attestation,execution_authority,source_scope,mission_id}'='5878822d-dc03-4ac2-ad0b-1547f0ab3fc0' OR ((mission_generic_owner.c1266_historical_work_v1(sticky_wc.work_id)->>'schema_version'='c1266-work-execution-attestation/2') AND sticky_wc.contract#>'{source_attestation,execution_authority}'=mission_generic_owner.c1266_historical_work_v1(sticky_wc.work_id)))
 AND sticky_wc.contract#>>'{source_attestation,execution_authority,release_sha256}'=sticky_wc.release_sha256
 AND sticky_wc.contract#>>'{source_attestation,execution_authority,binding_sha256}'=sticky_wc.definition_sha256) OR EXISTS(SELECT 1 FROM mission_generic_owner.simulation_sources ss21
 JOIN mission_generic_owner.board_starts bs21 ON bs21.request_key=ss21.request_key
 JOIN mission_generic_owner.start_claims sc22 ON sc22.session_id=bs21.master_session_id
 JOIN mission_generic_owner.run_bindings rb21 ON rb21.master_session_id=bs21.master_session_id
 JOIN public.master_v2_sessions ms21 ON ms21.id=bs21.master_session_id
  AND ms21.mission_id=ss21.carrier_mission_id
 WHERE NOT EXISTS(SELECT 1 FROM mission_generic_owner.manual_staff_admissions_v1 manual_source WHERE manual_source.master_session_id=bs21.master_session_id) AND bs21.master_session_id=p_session
 AND ms21.owner_kind='ai_service' AND ms21.master_user IS NULL
 AND ms21.location_id='0b85f354-9cdb-47e1-baf9-3d266bb7e06b'::uuid
 AND (ss21.source_mission_id='5878822d-dc03-4ac2-ad0b-1547f0ab3fc0'::uuid OR (mission_generic_owner.c1266_staff_source_scope_v1(bs21.master_session_id) IS NOT NULL AND ss21.source_mission_id::text=mission_generic_owner.c1266_staff_source_scope_v1(bs21.master_session_id)#>>'{source_scope,mission_id}'))
 AND sc22.state='bound' AND sc22.simulation
 AND sc22.mission_id=ms21.mission_id AND sc22.location_id=ms21.location_id
 AND sc22.request_key=bs21.request_key
 AND bs21.simulation AND bs21.snapshot->'simulation'='true'::jsonb
 AND bs21.snapshot_sha256=mission_internal.fingerprint(bs21.snapshot)
 AND bs21.snapshot->>'schema_version'='mission-generic-opening-source/1'
 AND bs21.snapshot->>'mission_id'=ss21.carrier_mission_id::text
 AND bs21.snapshot->>'location_id'='0b85f354-9cdb-47e1-baf9-3d266bb7e06b'
 AND rb21.snapshot_sha256=mission_internal.fingerprint(rb21.snapshot)
 AND rb21.snapshot->>'schema_version'='mission-generic-run/1'));
 c7_budget:=mission_generic_owner.c7_run_budget_v1(p_session,
 CASE WHEN c21_owned THEN false ELSE
 not exists(select 1 from mission_generic_owner.work_items pending_work where pending_work.master_session_id=p_session
 and pending_work.state in('claimed','authorized','provider_started')) END,null);
 if c7_budget->>'allowed'='false' then
  IF c21_owned THEN INSERT INTO public.mission_run_audit(master_session_id,event_code,metadata) VALUES(p_session,'C1266_CAMPAIGN_PROVIDER_STOP',jsonb_build_object('reason_code',c7_budget->>'reason_code','stop_causes',c7_budget->'stop_causes','boundary','progress'));END IF;
  perform mission_generic_owner.c7_run_budget_stop_v1(p_session);
  return jsonb_build_object('schema_version','mission-generic-progress/1','master_session_id',p_session,'state','paused','dispatch',null,'reason_code','MGPG_C7_RUN_BUDGET_STOP');
 end if;
 select id into strict cap from mission_ai_service_owner.capabilities where master_session_id=p_session and state='active';
 pending:=public.mission_generic_dispatch_next_v1(p_session,p_user);
 if pending->'request' is not null then return mission_generic_owner.progress_result(p_session,p_user,'work_pending');end if;
 if m.stato='preparazione' and r.run_phase='preparazione' and exists(select 1 from mission_generic_owner.work_items
 where master_session_id=p_session and state='failed' and payload ? 'opening_start_receipt_id') then
  res:=mission_generic_owner.abort_opening(p_session,p_user,mission_ai_service_owner.uuid5(p_session,'generic-abort-opening'));
  return jsonb_build_object('schema_version','mission-generic-progress/1','master_session_id',p_session,'state','aborted','dispatch',null);
 end if;
 if m.stato<>'in_corso' or m.suspended_at is not null or r.run_phase<>'in_corso'
 then return mission_generic_owner.progress_result(p_session,p_user,'paused');end if;
 perform mission_generic_owner.assert_combat_scope(p_session,cap);
 if exists(select 1 from mission_generic_owner.work_items wi where wi.master_session_id=p_session
 and wi.step_key=r.current_step_key and wi.run_control_version=r.control_version and wi.state='failed'
 and not (wi.kind='narration' AND wi.result->>'schema_version'='c1266-count-terminal-failure/1'
  AND wi.result->>'failure_code'='MISSION_INPUT_COUNT_OVERFLOW' AND EXISTS(
   SELECT 1 FROM LATERAL(SELECT mission_generic_owner.writer_count_reissue_proof_v1(wi.id,NULL) proof) solved49
   WHERE solved49.proof->>'schema_version'='mission-writer-count-reissue-proof/1'
    AND solved49.proof->>'old_work_id'=wi.id::text AND solved49.proof->>'master_session_id'=wi.master_session_id::text
    AND solved49.proof->'published'='true'::jsonb))
 and not (wi.kind='director' AND wi.result->'failure_codes' ? 'MISSION_PROVIDER_OUTPUT_RETENTION_FAILED'
  AND mission_generic_owner.retained_director_adoption_v1(wi.id,true) IS NOT NULL)
 and not (wi.kind='narration' AND wi.payload->>'schema_version'='mission-generic-narration/3'
  AND wi.result->>'schema_version'='mission-generic-pre-provider-failure/1'
  AND wi.result->>'failure_code'='request_validation_failed'
  AND wi.result->>'provider_calls'='0' AND wi.result->>'charged_cost_usd'='0'
  AND EXISTS(
   SELECT 1
   FROM LATERAL(SELECT mission_generic_owner.combat_narration_reissue_proof_v1(wi.id,p_user) x) native_reissue
   JOIN mission_generic_owner.work_items successor ON successor.id=(native_reissue.x->>'successor_work_id')::uuid
     AND successor.master_session_id=wi.master_session_id AND successor.authority_receipt_id=wi.authority_receipt_id
     AND successor.kind='narration' AND successor.state='completed' AND successor.finalized_at IS NOT NULL
     AND successor.receipt_id IS NOT NULL AND successor.result_sha256 ~ '^[0-9a-f]{64}$'
     AND successor.payload=wi.payload AND successor.payload_sha256=wi.payload_sha256
   JOIN mission_narrative_internal.dispatch_receipts native_receipt ON native_receipt.id=successor.dispatch_receipt_id
     AND native_receipt.master_session_id=p_session AND native_receipt.authority_receipt_id=successor.id
     AND native_receipt.request_key=successor.request_key AND native_receipt.status='success' AND native_receipt.finalized_at IS NOT NULL
     AND native_receipt.request_fingerprint=mission_internal.fingerprint(jsonb_build_object('schema_version','mission-generic-request/1','master_session_id',successor.master_session_id,'event_id',successor.event_id,'request_key',successor.request_key,'expected_revision',successor.revision))
     AND native_receipt.envelope_sha256=public.combat_v2_sha256(native_receipt.envelope)
     AND native_receipt.authority_sha256=native_receipt.envelope_sha256
   JOIN mission_generic_owner.unified_batches native_batch ON native_batch.id=successor.authority_receipt_id
     AND native_batch.master_session_id=p_session AND native_batch.writer_work_id=successor.id
     AND native_batch.retired_at IS NULL AND native_batch.state='published' AND native_batch.published_at IS NOT NULL
     AND native_batch.message_id=successor.message_id AND native_batch.source_window_id IS NULL
     AND native_batch.payload=successor.payload AND native_batch.payload_sha256=successor.payload_sha256
   JOIN public.combat_v2_round_reports native_report ON native_report.id=native_batch.source_report_id
     AND native_report.round_id=native_batch.source_round_id
     AND native_report.narration_state='pubblicata' AND native_report.message_id=successor.message_id
     AND native_report.values_written IS FALSE
     AND native_report.mechanics_sha256=public.combat_v2_sha256(native_report.mechanics)
   JOIN public.combat_v2_rounds native_round ON native_round.id=native_report.round_id
     AND native_round.session_id=native_batch.encounter_id AND native_round.state='narrato'
   JOIN mission_generic_owner.unified_report_publications native_publication ON native_publication.report_id=native_report.id
     AND native_publication.round_id=native_round.id AND native_publication.batch_id=native_batch.id
     AND native_publication.primary_report AND native_publication.message_id=successor.message_id
   JOIN public.messages native_message ON native_message.id=successor.message_id AND native_message.kind='fato'
     AND native_message.location_id=m.location_id AND native_message.character_id IS NULL AND native_message.recipient_user IS NULL
     AND native_message.body=successor.result->>'text'
   JOIN public.combat_v2_narratives native_narrative ON native_narrative.report_id=native_report.id
     AND native_narrative.round_id=native_round.id AND native_narrative.request_key=successor.request_key
     AND native_narrative.kind='fato_ia' AND native_narrative.author_user IS NULL AND native_narrative.body=native_message.body
   WHERE native_reissue.x->>'schema_version'='mission-combat-narration-reissue-proof/1'
     AND native_reissue.x->>'published'='true'
     AND native_reissue.x->>'master_session_id'=p_session::text AND native_reissue.x->>'failed_work_id'=wi.id::text
     AND native_reissue.x->>'batch_id'=native_batch.id::text
     AND native_reissue.x->>'payload_sha256'=wi.payload_sha256
     AND mission_generic_owner.c1266_historical_work_v1(successor.id)->>'schema_version'='c1266-work-execution-attestation/3'
     AND EXISTS(SELECT 1 FROM mission_narrative_internal.dispatch_audit finalized
       WHERE finalized.receipt_id=native_receipt.id AND finalized.event_code='generic_finalized'
         AND finalized.details->>'work_id'=successor.id::text AND finalized.details->>'receipt_id'=successor.receipt_id::text
         AND finalized.details->>'message_id'=native_message.id::text AND finalized.details->>'state'='completed'
         AND finalized.details->>'result_sha256'=successor.result_sha256
         AND finalized.details->>'result_jsonb_sha256'=public.combat_v2_sha256(successor.result)
         AND finalized.details->>'stale'='false' AND finalized.details->>'outcome_uncertain'='false'
         AND finalized.details->'application_error_sqlstate'='null'::jsonb)
     AND (native_batch.secondary_report_id IS NULL OR EXISTS(
       SELECT 1 FROM public.combat_v2_round_reports secondary_report
       JOIN mission_generic_owner.unified_report_publications secondary_publication
         ON secondary_publication.report_id=secondary_report.id AND secondary_publication.round_id=secondary_report.round_id
         AND secondary_publication.batch_id=native_batch.id AND NOT secondary_publication.primary_report
         AND secondary_publication.message_id=native_message.id
       WHERE secondary_report.id=native_batch.secondary_report_id AND secondary_report.narration_state='pubblicata'
         AND secondary_report.message_id IS NULL AND secondary_report.values_written IS FALSE
         AND secondary_report.mechanics_sha256=public.combat_v2_sha256(secondary_report.mechanics)))
  ))
 and NOT ((wi.id='e76f31f2-eded-495e-9c5f-f03461c5cc3a'::uuid AND wi.master_session_id='44078c5f-7001-4129-9506-e2f34e68c8ac'::uuid AND wi.kind='director' AND wi.state='failed' AND wi.message_id IS NULL
 AND wi.payload_sha256='f962403b87a5c6bf6930818e4d5655e57451d1adebbd404702f4a75ae7bcf03a' AND wi.payload_sha256=public.combat_v2_sha256(wi.payload)
 AND wi.result_sha256='73c3158fe44061c34b1dc410daec3fda85cd98ee3fadbbc063bbfdea5982571d' AND public.combat_v2_sha256(wi.result)='cee81d0c273baaf64705be7b53c884778f063bcd739461c777666cdcbd440ad4'
 AND wi.result->>'ok'='true' AND wi.result->>'provider_calls'='1' AND wi.result->>'outcome_uncertain'='false'
 AND EXISTS(SELECT 1 FROM mission_public_owner.work_contracts_v1 wc WHERE wc.work_id=wi.id AND wc.contract_sha256='ad13df1382af67d4af779f9f16790085468f3c14a9dd9c2c16d145477038f302' AND wc.contract_sha256=public.combat_v2_sha256(wc.contract) AND wc.release_sha256='feaf314957d5dab65a2420748e935015e5aa2e16fb2aed996e38e11e57189243' AND wc.contract->'features'?'provider_output_retention_v1')
 AND EXISTS(SELECT 1 FROM mission_narrative_internal.provider_outputs_v1 raw WHERE raw.id=(wi.result->>'output_receipt_id')::uuid AND raw.work_id=wi.id AND raw.authorization_id=wi.authorization_id AND raw.dispatch_id=wi.dispatch_id AND raw.dispatch_receipt_id=wi.dispatch_receipt_id AND raw.raw_sha256=wi.result->>'raw_sha256' AND raw.raw_sha256=encode(extensions.digest(convert_to(raw.raw_output,'UTF8'),'sha256'),'hex'))
 AND EXISTS(SELECT 1 FROM mission_narrative_internal.dispatch_receipts dr JOIN mission_narrative_internal.dispatch_audit fa ON fa.receipt_id=dr.id AND fa.event_code='generic_finalized'
  JOIN staff_ai_quota_private.calls q ON q.producer='mission_generic_ai' AND q.source_id=dr.id AND q.scope_id=wi.master_session_id AND q.call_no=1 AND q.state='settled' AND q.charged_usd=dr.charged_cost_usd
 WHERE dr.id=wi.dispatch_receipt_id AND dr.master_session_id=wi.master_session_id AND dr.authority_receipt_id=wi.id AND dr.request_key=wi.request_key AND dr.status='success' AND dr.dispatch_count=1 AND dr.finalized_at IS NOT NULL
 AND fa.details->>'work_id'=wi.id::text AND fa.details->>'receipt_id'=wi.receipt_id::text AND fa.details->>'result_sha256'=wi.result_sha256 AND fa.details->>'result_jsonb_sha256'=public.combat_v2_sha256(wi.result)
 AND fa.details->>'application_error_sqlstate'='23505' AND fa.details->'command_receipt'='null'::jsonb AND fa.details->>'stale'='false' AND fa.details->>'outcome_uncertain'='false')) AND EXISTS(SELECT 1 FROM mission_narrative_internal.dispatch_audit ap JOIN mission_generic_owner.unified_batches ab ON ab.decision_work_id=wi.id AND ab.master_session_id=wi.master_session_id
 JOIN mission_generic_owner.work_items aw ON aw.id=ab.writer_work_id AND aw.master_session_id=wi.master_session_id AND aw.authority_receipt_id=ab.id AND aw.kind='narration'
 WHERE ap.receipt_id=wi.dispatch_receipt_id AND ap.event_code='c1266_saved_director_applied' AND ap.details->>'schema_version'='c1266-saved-director-application/1'
 AND ap.details->>'master_session_id'=wi.master_session_id::text AND ap.details->>'work_id'=wi.id::text AND ap.details->>'result_sha256'=wi.result_sha256 AND ap.details->>'batch_id'=ab.id::text AND ap.details->>'writer_work_id'=aw.id::text AND ap.details->>'generation_http_calls'='0' AND ap.details->>'failed_work_preserved'='true'
 AND ab.retired_at IS NULL AND ab.state='published' AND aw.state='completed' AND ab.message_id=aw.message_id AND EXISTS(SELECT 1 FROM public.messages pm JOIN mission_generic_owner.unified_source_windows ps ON ps.id=ab.source_window_id AND ps.consumed_message_id=pm.id JOIN mission_generic_owner.unified_segment_publications_v4 pp ON pp.work_id=aw.id AND pp.message_id=pm.id WHERE pm.id=aw.message_id AND pm.kind='fato' AND pm.recipient_user IS NULL AND pm.body=aw.result->>'text')))
 and NOT (wi.kind='director' AND wi.state='failed' AND wi.result->>'ok'='true'
 AND wi.payload_sha256=public.combat_v2_sha256(wi.payload)
 AND EXISTS(SELECT 1 FROM mission_narrative_internal.dispatch_receipts healed_dr
  JOIN mission_narrative_internal.dispatch_audit healed_a ON healed_a.receipt_id=healed_dr.id AND healed_a.event_code='c1266_saved_director_applied'
  JOIN mission_narrative_internal.dispatch_audit healed_f ON healed_f.receipt_id=healed_dr.id AND healed_f.event_code='generic_finalized'
  JOIN mission_generic_owner.unified_batches healed_b ON healed_b.decision_work_id=wi.id AND healed_b.master_session_id=p_session
  JOIN mission_generic_owner.unified_source_windows healed_s ON healed_s.id=healed_b.source_window_id AND healed_s.work_id=wi.id AND healed_s.master_session_id=p_session
  JOIN mission_generic_owner.work_items healed_writer ON healed_writer.id=healed_b.writer_work_id AND healed_writer.master_session_id=p_session AND healed_writer.authority_receipt_id=healed_b.id
  JOIN public.messages healed_msg ON healed_msg.id=healed_writer.message_id AND healed_msg.kind='fato' AND healed_msg.recipient_user IS NULL AND healed_msg.body=healed_writer.result->>'text'
  WHERE healed_dr.id=wi.dispatch_receipt_id AND healed_dr.master_session_id=p_session AND healed_dr.authority_receipt_id=wi.id AND healed_dr.request_key=wi.request_key
   AND healed_dr.status='success' AND healed_dr.dispatch_count=1 AND healed_dr.finalized_at IS NOT NULL
   AND healed_a.details->>'schema_version'='c1266-saved-director-application/1' AND healed_a.details->>'master_session_id'=p_session::text
   AND healed_a.details->>'work_id'=wi.id::text AND healed_a.details->>'result_sha256'=wi.result_sha256
   AND healed_a.details->>'batch_id'=healed_b.id::text AND healed_a.details->>'writer_work_id'=healed_writer.id::text
   AND healed_a.details->>'generation_http_calls'='0' AND healed_a.details->>'failed_work_preserved'='true'
   AND healed_f.details->>'work_id'=wi.id::text AND healed_f.details->>'receipt_id'=wi.receipt_id::text
   AND healed_f.details->>'result_sha256'=wi.result_sha256 AND healed_f.details->>'result_jsonb_sha256'=public.combat_v2_sha256(wi.result)
   AND healed_b.state='published' AND healed_b.published_at IS NOT NULL AND healed_b.message_id=healed_writer.message_id
   AND healed_s.consumed_message_id=healed_b.message_id AND healed_s.superseded_at IS NULL
   AND healed_s.source_sha256=wi.payload_sha256 AND healed_writer.kind='narration' AND healed_writer.state='completed'
   AND healed_writer.payload=healed_b.payload AND healed_writer.payload_sha256=healed_b.payload_sha256
   AND healed_writer.payload_sha256=public.combat_v2_sha256(healed_writer.payload)
   AND EXISTS(SELECT 1 FROM mission_generic_owner.unified_segment_publications_v4 healed_pub WHERE healed_pub.work_id=healed_writer.id AND healed_pub.message_id=healed_msg.id)
   AND EXISTS(SELECT 1 FROM staff_ai_quota_private.calls healed_q WHERE healed_q.producer='mission_generic_ai' AND healed_q.scope_id=p_session AND healed_q.source_id=healed_dr.id AND healed_q.call_no=1 AND healed_q.state='settled' AND healed_q.charged_usd=healed_dr.charged_cost_usd)))
 and not (wi.id='849c4dac-280f-4331-9d6e-4197445f5ae4'::uuid
   and wi.kind='narration'
   and wi.authority_receipt_id='44639b01-ea89-4368-847c-0e40c6eaf9cc'::uuid
   and wi.result->'failure_codes'='["MISSION_PROFILE_AUDIT_INVALID"]'::jsonb
   and wi.payload_sha256=public.combat_v2_sha256(wi.payload)
   and exists (
     select 1 from mission_generic_owner.unified_batches recovered
     join mission_generic_owner.work_items successor on successor.id=recovered.writer_work_id
     join mission_generic_owner.flow_staff_sessions staff on staff.master_session_id=recovered.master_session_id and staff.enabled
     join public.master_v2_sessions session on session.id=staff.master_session_id and session.owner_kind='ai_service' and session.closed_at is null
     join public.locations location on location.id=session.location_id and location.is_test
     where recovered.id=wi.authority_receipt_id and recovered.master_session_id=p_session
       and recovered.state='published' and recovered.message_id is not null
       and recovered.payload_sha256=wi.payload_sha256
       and successor.id='6027edf0-355d-47c9-b88c-9a9e1a2d795b'::uuid
       and successor.master_session_id=p_session and successor.kind='narration'
       and successor.state='completed' and successor.message_id=recovered.message_id
       and successor.authority_receipt_id=recovered.id
       and successor.payload_sha256=recovered.payload_sha256
   ))
 and not exists(select 1 from mission_generic_owner.unified_source_windows released_source
   join mission_generic_owner.role_window_cursors staff_cursor
     on staff_cursor.master_session_id=released_source.master_session_id
   where (released_source.work_id=wi.id
     or exists(select 1 from mission_generic_owner.unified_batches released_batch
       where released_batch.source_window_id=released_source.id
         and released_batch.writer_work_id=wi.id))
     and released_source.master_session_id=p_session
     and mission_generic_owner.role_source_released_v4(released_source.id))
 and not (wi.id='d7c28505-7b5e-4e80-a148-3dceb6884174'::uuid
   and p_session='b70b23cf-bad8-475d-a56a-d9c549e35d84'::uuid
   and mission_generic_owner.flow_scope_enabled(p_session)
   and wi.kind='director' and wi.result->>'ok'='true'
   and wi.result_sha256='103cb96c6026f2dd043eaa3486bb39dac68a1765a7d01995ca5dcaefb5b46b3d'
   and exists(select 1 from mission_generic_owner.unified_batches repaired
      where repaired.decision_work_id=wi.id and repaired.source_window_id=wi.authority_receipt_id
       and repaired.master_session_id=p_session and repaired.step_key=wi.step_key
       and repaired.run_control_version=wi.run_control_version
       and repaired.composition_kind='narrative_continuation'
       and repaired.decision=wi.result->'decision'
       and repaired.decision_sha256=public.combat_v2_sha256(wi.result->'decision')
       and repaired.writer_work_id is not null and repaired.state in('ready','published')))
 and not (p_session='b70b23cf-bad8-475d-a56a-d9c549e35d84'::uuid
   and mission_generic_owner.flow_scope_enabled(p_session)
   and exists(select 1 from mission_generic_owner.unified_source_windows superseded
     where superseded.id=wi.id and superseded.work_id=wi.id
       and superseded.master_session_id=p_session
       and superseded.superseded_at is not null and superseded.consumed_message_id is null))
 and (wi.result->>'schema_version'='mission-generic-pre-provider-failure/1'
  and wi.result->>'failure_code'='request_validation_failed'
  and wi.result->>'provider_calls'='0' and wi.result->>'charged_cost_usd'='0'
  and wi.result_sha256=public.combat_v2_sha256(wi.result)
  and wi.payload_sha256=public.combat_v2_sha256(wi.payload)
  and (select count(*) from public.mission_run_audit qa
   join mission_generic_owner.work_items rw on rw.id::text=qa.metadata->>'new_work_id'
   join mission_generic_owner.unified_batches ub on ub.id=wi.authority_receipt_id and ub.writer_work_id=rw.id
   where qa.master_session_id=p_session and qa.event_code='QA_PREPROVIDER_NARRATION_RECOVERED'
    and qa.metadata->>'failed_work_id'=wi.id::text and qa.metadata->>'batch_id'=ub.id::text
    and qa.metadata->>'recovery_dedupe'=rw.dedupe_key
    and rw.master_session_id=wi.master_session_id and rw.authority_receipt_id=wi.authority_receipt_id
    and rw.kind=wi.kind and rw.state='completed' and ub.master_session_id=wi.master_session_id
    and ub.state='published' and rw.payload=ub.payload and rw.payload_sha256=ub.payload_sha256
    and rw.payload_sha256=public.combat_v2_sha256(rw.payload))=1) is not true
  and not (
    wi.id='3076c471-37c5-438e-8f50-0a790b787e05'::uuid
    and wi.kind='choice'
    and p_session='93d78313-abde-4087-9eb7-7b96bc0fa089'::uuid
    and wi.encounter_id='deadfef6-5b16-4921-aa86-b86ffad6f2f2'::uuid
    and wi.payload->>'actor_id'='1f662f89-447a-4cd3-9873-a5953a0e0d91'
    and wi.payload->>'round_id'='44061137-17a3-43fa-9225-d29aaa26e58a'
    and (
      (
        (select md5(prosrc) from pg_proc where oid='mission_generic_owner.enqueue_choice(uuid,uuid,uuid)'::regprocedure)
          ='76a88f0e93752e1456c90d160a7a855d'
        and exists (
          select 1 from mission_generic_owner.unified_batches ub
          where ub.master_session_id=p_session
            and ub.id='fbfc8e29-8724-4241-b2fe-22dbc17eb9e7'::uuid
            and ub.encounter_id=wi.encounter_id
            and ub.state='preparing' and ub.entry_side='png'
            and ub.next_round_id='44061137-17a3-43fa-9225-d29aaa26e58a'::uuid
        )
        and not exists (
          select 1 from mission_generic_owner.work_items rw
          where rw.master_session_id=p_session
            and rw.dedupe_key=wi.dedupe_key||':recovery:'||wi.id::text
        )
        and not exists (
          select 1 from public.combat_v2_declarations d
          where d.round_id='44061137-17a3-43fa-9225-d29aaa26e58a'::uuid
            and d.actor_id='1f662f89-447a-4cd3-9873-a5953a0e0d91'::uuid
        )
      )
      or exists (
        select 1 from mission_generic_owner.work_items rw
        where rw.master_session_id=p_session
          and rw.dedupe_key=wi.dedupe_key||':recovery:'||wi.id::text
          and rw.kind='choice' and rw.state='completed'
          and rw.encounter_id=wi.encounter_id
          and rw.payload->>'actor_id'=wi.payload->>'actor_id'
          and rw.payload->>'round_id'=wi.payload->>'round_id'
          and rw.payload_sha256=public.combat_v2_sha256(rw.payload)
          and rw.result_sha256=public.combat_v2_sha256(rw.result)
          and exists (
            select 1 from public.combat_v2_declarations d
            where d.round_id='44061137-17a3-43fa-9225-d29aaa26e58a'::uuid
              and d.actor_id='1f662f89-447a-4cd3-9873-a5953a0e0d91'::uuid
          )
      )
    )
  )
)
 then return mission_generic_owner.progress_result(p_session,p_user,'needs_attention');end if;
 if exists(select 1 from public.mission_run_outbox uo where uo.master_session_id=p_session and uo.state='pending' and not exists(select 1 from mission_generic_owner.unified_batches ub where ub.master_session_id=p_session and ub.state='preparing' and ub.route->>'event_id'=uo.event_id::text))
 then return mission_generic_owner.progress_result(p_session,p_user,'narration_pending');end if;
 if not exists(select 1 from mission_factory_owner.quest_run_sources where session_id=p_session) then
 res:=mission_rapid_owner.try_native_terminal(p_session);
 if res is not null then return mission_generic_owner.progress_result(p_session,p_user,'transitioned');end if;
 settings:=mission_generic_owner.run_plan_settings(p_session);
 select count(*),jsonb_agg(x)->0 into n,term from jsonb_array_elements(settings->'terminal_steps') x where x->>'step_key'=r.current_step_key;
 if n>1 then raise exception 'MGP_PLAN_TERMINAL_AMBIGUOUS';end if;
 if n=1 AND mission_generic_owner.staff_finish_policy_v1(p_session) IS DISTINCT FROM true then
  res:=mission_generic_owner.finish_mission(p_session,term->>'outcome');
  return jsonb_build_object('schema_version','mission-generic-progress/1','master_session_id',p_session,'state','closed','dispatch',null);
 end if;
 end if;
 res:=mission_generic_owner.unified_advance(p_session,p_user,p_request);
 if res is not null then return res;end if;
 sc:=mission_generic_owner.scene(p_session,r.current_step_key);
 select count(*) into n from mission_generic_owner.encounters x join public.combat_v2_sessions y on y.id=x.encounter_id
 where x.master_session_id=p_session and y.closed_at is null;
 if n>1 then raise exception 'MGP_MULTIPLE_ACTIVE_ENCOUNTERS';end if;
 select x.* into e from mission_generic_owner.encounters x join public.combat_v2_sessions y on y.id=x.encounter_id
 where x.master_session_id=p_session and y.closed_at is null;
 if e.encounter_id is null then
  select count(*),jsonb_agg(x)->0 into n,spec from jsonb_array_elements(sc->'encounters') x
  where not exists(select 1 from mission_generic_owner.encounters z where z.master_session_id=p_session
   and z.step_key=r.current_step_key and z.run_control_version=r.control_version and z.encounter_key=x->>'encounter_key');
  if n=0 then return mission_generic_owner.progress_result(p_session,p_user,'waiting_choice');end if;
  if n>1 then raise exception 'MGP_ENCOUNTER_OPEN_POINT_AMBIGUOUS' using errcode='22023';end if;
  res:=public.mission_generic_combat_open_v1(p_session,spec->>'encounter_key',r.control_version,
    mission_ai_service_owner.uuid5(p_session,'encounter:'||r.control_version||':'||(spec->>'encounter_key')));
  select * into strict e from mission_generic_owner.encounters where encounter_id=(res->>'encounter_id')::uuid;
 end if;
 if e.step_key<>r.current_step_key or e.run_control_version<>r.control_version then raise exception 'MGP_ENCOUNTER_VISIT_DRIFT';end if;
 select * into strict s from public.combat_v2_sessions where id=e.encounter_id for update;
 if s.state='risolto' then
  res:=mission_generic_owner.advance_combat_terminal(p_session,s.id);
  return mission_generic_owner.progress_result(p_session,p_user,'transitioned');
 end if;
 if s.state<>'in_corso' then raise exception 'MGP_ENCOUNTER_STATE';end if;
 select * into strict roundrow from public.combat_v2_rounds where session_id=s.id order by round_no desc limit 1 for update;
 if roundrow.state in('risolto','narrazione') then
  select * into strict rep from public.combat_v2_round_reports where round_id=roundrow.id;
  if rep.narration_state<>'attesa' then raise exception 'MGP_REPORT_STATE';end if;
  return mission_public_owner.enqueue_combat_unified_v1(p_session,rep.id,p_user);
 end if;
 -- Common offre difese soltanto nella fase nativa raccolta_difese. Un target
 -- già creato durante raccolta_azioni non anticipa la scelta del PNG.
 select a.id into actor from public.combat_v2_actors a where a.session_id=s.id and a.actor_kind='png' and a.state='attivo'
 and roundrow.phase='raccolta_difese' and roundrow.state='raccolta_difese'
 and exists(select 1 from jsonb_array_elements(e.actor_map) x where x->>'actor_id'=a.id::text and x->>'mechanical_binding_id' is not null)
 and exists(select 1 from public.combat_v2_attack_targets t where t.round_id=roundrow.id and t.target_actor_id=a.id
  and not exists(select 1 from public.combat_v2_defense_coverages c where c.attack_target_id=t.id)) order by a.id limit 1;
 if actor is not null then
  res:=mission_generic_owner.enqueue_choice(p_session,s.id,actor);
  return mission_generic_owner.progress_result(p_session,p_user,'choice_ready');
 end if;
 if exists(select 1 from public.combat_v2_actors a where a.session_id=s.id and a.actor_kind='pg' and a.state='attivo'
 and clan_marionettisti_private.can_declare(a.id) and not exists(select 1 from public.combat_v2_declarations d
  where d.round_id=roundrow.id and d.actor_id=a.id and d.kind in('attacco','movimento','utilita','passa')))
 then return mission_generic_owner.progress_result(p_session,p_user,'waiting_player');end if;
 -- La barriera PG precedente resta obbligatoria; ogni PNG riceve una
 -- principale soltanto se manca e il round raccoglie ancora azioni.
 IF mission_narrative_internal.scene_opening_receipt_v1(roundrow.id) IS NULL THEN
 select a.id into actor from public.combat_v2_actors a where a.session_id=s.id and a.actor_kind='png' and a.state='attivo'
 and roundrow.phase='raccolta_azioni' and roundrow.state='raccolta_azioni'
 and clan_marionettisti_private.can_declare(a.id)
 and exists(select 1 from jsonb_array_elements(e.actor_map) x where x->>'actor_id'=a.id::text and x->>'mechanical_binding_id' is not null)
 and not exists(select 1 from public.combat_v2_declarations d where d.round_id=roundrow.id and d.actor_id=a.id
 and d.kind in('attacco','movimento','utilita','passa')) order by a.id limit 1;
 ELSE actor:=NULL;END IF;
 if actor is not null then
  res:=mission_generic_owner.enqueue_choice(p_session,s.id,actor);
  return mission_generic_owner.progress_result(p_session,p_user,'choice_ready');
 end if;
 if (select count(*) from public.combat_v2_declarations where round_id=roundrow.id and kind in('attacco','movimento','utilita','passa'))
 <>combat_consumer_private.expected_main_count(roundrow.id)
 then return mission_generic_owner.progress_result(p_session,p_user,'waiting_player');end if;
 if not combat_v2_multitarget_internal.round_complete(roundrow.id)
 then return mission_generic_owner.progress_result(p_session,p_user,'waiting_defense');end if;
 if roundrow.evaluation_mode<>'neutra' and exists(select 1 from public.combat_v2_declarations d
 join public.combat_v2_actors a on a.id=d.actor_id where d.round_id=roundrow.id and a.actor_kind='pg' and d.kind in('attacco','difesa')
 and not exists(select 1 from public.combat_v2_ratings x where x.declaration_id=d.id and x.is_active))
 then return mission_generic_owner.progress_result(p_session,p_user,'waiting_quality');end if;
 -- Neutra: il resolver nativo registra zero con fonte neutralita_sistema. Nessun voto IA.
 if (select is_test from public.locations where id=m.location_id) and (public.combat_v2_values_written(s.id)
 or not combat_panel_private.uses_simulated_pools(s.id)) then raise exception 'MGP_SIMULATION_SCOPE' using errcode='42501';end if;
 res:=public.combat_v2_round_resolve(roundrow.id,mission_ai_service_owner.uuid5(roundrow.id,'generic-resolve'));
 select * into strict rep from public.combat_v2_round_reports where id=(res#>>'{data,report_id}')::uuid and round_id=roundrow.id;
 return mission_public_owner.enqueue_combat_unified_v1(p_session,rep.id,p_user);
end $$;
CREATE OR REPLACE FUNCTION public.trg_role_autojoin() RETURNS trigger LANGUAGE plpgsql SECURITY DEFINER SET search_path TO 'public' AS $$
declare
  v_sess uuid; v_uid uuid; v_cname text;
  v_gettone text; v_len int := -1;
  v_lname text; v_ltest boolean;
  v_quando timestamptz := coalesce(NEW.created_at, now());
begin
 IF TG_OP='INSERT' AND mission_narrative_internal.scene_message_permitted_v1(NEW) THEN RETURN NEW;END IF;

  if exists(select 1 from exam_human_private.narrative_events where message_id=NEW.id) or exists(select 1 from exam_human_private.round_messages where message_id=NEW.id) then
    perform set_config('app.role_turno','',true); return NEW;
  end if;
  if exists(select 1 from mission_exam_private.protected_messages pm where pm.message_id=NEW.id) then
    perform set_config('app.role_turno','',true); return NEW;
  end if;
  -- [ROLE-REC-AUTOSTART-006] Il gettone si legge e si consuma SEMPRE, per primo,
  -- anche quando questa riga non ne ha diritto: e' monouso per costruzione, cosi'
  -- nessun messaggio inserito dopo, nella stessa transazione, puo' ereditarlo.
  -- Lo deposita soltanto post_message, subito prima del proprio insert, e porta
  -- il conteggio che ha calcolato il server: il luogo davanti ai due punti, la
  -- lunghezza dopo. Nessun'altra funzione che scrive in messages lo deposita,
  -- quindi un tiro di dado, un referto o una riga d'Accademia non aprono REC.
  v_gettone := nullif(current_setting('app.role_turno', true), '');
  if v_gettone is not null then
    perform set_config('app.role_turno', '', true);
    if split_part(v_gettone, ':', 1) = NEW.location_id::text then
      v_len := coalesce(nullif(split_part(v_gettone, ':', 2), '')::int, -1);
    end if;
  end if;

  if not public._role_msg_valido(NEW.kind, NEW.character_id, NEW.recipient_user) then
    return NEW;
  end if;

  select id into v_sess from public.role_sessions
   where location_id = NEW.location_id and closed_at is null
   order by started_at desc limit 1;

  select user_id, name into v_uid, v_cname from public.characters where id = NEW.character_id;
  if v_uid is null then return NEW; end if;

  if v_sess is null then
    -- [ROLE-REC-AUTOSTART-006] Apertura automatica della REC generale. Tre porte,
    -- tutte chiuse per difetto: serve il gettone di post_message, quel conteggio
    -- deve arrivare alla soglia, e il luogo non puo' essere una stanza di prova.
    -- Se anche una sola manca si esce come prima, senza registrare niente: e'
    -- esattamente il comportamento precedente a questa migrazione.
    if v_len < public._role_soglia_apertura() then return NEW; end if;

    select l.name, coalesce(l.is_test,false) into v_lname, v_ltest
      from public.locations l where l.id = NEW.location_id;
    if not found or v_ltest then return NEW; end if;

    -- record_from prende il created_at del messaggio che apre, non now(): il turno
    -- che ha aperto la REC deve cadere DENTRO la finestra, mai un istante prima.
    insert into public.role_sessions
        (location_id, location_name, started_by, starter_name, title, started_at, record_from)
    values (NEW.location_id, v_lname, v_uid, v_cname,
            'Role · ' || coalesce(v_lname,'Luogo'), v_quando, v_quando)
    on conflict (location_id) where closed_at is null do nothing
    returning id into v_sess;

    -- Corsa fra due primi turni nello stesso luogo: chi arriva secondo aspetta
    -- l'indice unico parziale, non inserisce niente, e qui rilegge la REC che ha
    -- aperto l'altro. Da li' in poi prende la strada normale del conteggio, e
    -- ciascuno dei due messaggi vale un turno, una volta sola.
    if v_sess is null then
      select id into v_sess from public.role_sessions
       where location_id = NEW.location_id and closed_at is null
       order by started_at desc limit 1;
    end if;
    if v_sess is null then return NEW; end if;
  end if;

  -- strada veloce
  update public.role_session_participants
     set message_count    = message_count + 1,
         last_message_at  = greatest(coalesce(last_message_at, NEW.created_at), NEW.created_at),
         first_message_at = least(coalesce(first_message_at, NEW.created_at), NEW.created_at)
   where session_id = v_sess and user_id = v_uid and ha_contribuito;
  if found then return NEW; end if;

  -- strada lenta: la sessione deve essere ancora aperta, e resta bloccata
  -- fino alla fine di questa transazione.
  perform 1 from public.role_sessions
   where id = v_sess and closed_at is null for no key update;
  if not found then return NEW; end if;

  insert into public.role_session_participants
      (session_id, user_id, character_id, character_name,
       message_count, first_message_at, last_message_at)
  values (v_sess, v_uid, NEW.character_id, v_cname,
       1, NEW.created_at, NEW.created_at)
  on conflict (session_id, user_id) do update
     set message_count    = role_session_participants.message_count + 1,
         first_message_at = least(coalesce(role_session_participants.first_message_at, NEW.created_at), NEW.created_at),
         last_message_at  = greatest(coalesce(role_session_participants.last_message_at, NEW.created_at), NEW.created_at),
         character_id     = coalesce(role_session_participants.character_id, NEW.character_id),
         character_name   = coalesce(role_session_participants.character_name, v_cname);
  return NEW;
end; $$;
CREATE OR REPLACE FUNCTION mission_public_owner.role_capture_scope_v1(p_session uuid) RETURNS boolean LANGUAGE sql STABLE SECURITY DEFINER SET search_path TO '' AS $$
 select CASE WHEN EXISTS(SELECT 1 FROM mission_narrative_internal.scene_runtime_v1 s JOIN public.master_v2_sessions m ON m.id=s.master_session_id JOIN public.locations l ON l.id=m.location_id WHERE s.master_session_id=p_session AND s.is_active AND m.owner_kind='ai_service' AND m.closed_at IS NULL AND l.is_test) THEN true ELSE exists(select 1 from mission_generic_owner.flow_staff_sessions fs
 join public.master_v2_sessions m on m.id=fs.master_session_id
 join public.locations l on l.id=m.location_id
 where fs.master_session_id=p_session and fs.enabled and m.owner_kind='ai_service'
 and m.closed_at is null and l.is_test)
 or mission_public_owner.role_session_allowed_v1(p_session) END;
$$;
CREATE OR REPLACE FUNCTION mission_generic_owner.role_dispatch_assert_v4(p_work uuid) RETURNS void LANGUAGE plpgsql SECURITY DEFINER SET search_path TO '' AS $$
DECLARE w mission_generic_owner.work_items; rev text;
BEGIN
  PERFORM mission_ai_board_owner.service_only();
  SELECT * INTO STRICT w FROM mission_generic_owner.work_items WHERE id=p_work;
  IF w.kind='narration' AND w.payload->>'schema_version'='mission-narrative-scene/1'
   AND w.payload->>'mode'='narrative_scene' THEN
   PERFORM mission_narrative_internal.scene_source_assert_v1(w.id);RETURN;
  END IF;
  IF w.payload->>'source_kind'='quest' AND w.payload#>>'{quest_lifecycle,phase}'='terminal' THEN
    PERFORM mission_generic_owner.work_assert(w);
    PERFORM mission_factory_owner.quest_lifecycle_assert_v1(w);
    RETURN;
  END IF;
  IF NOT EXISTS(SELECT 1 FROM mission_generic_owner.role_window_cursors
     WHERE master_session_id=w.master_session_id) THEN
    IF w.master_session_id='b70b23cf-bad8-475d-a56a-d9c549e35d84'::uuid
      OR w.payload->>'schema_version'='mission-generic-narration/4'
      OR (w.kind='director' AND w.payload#>>'{context,source_revision}' IS NOT NULL)
    THEN RAISE EXCEPTION 'MRS_V4_CURSOR_REQUIRED' USING ERRCODE='P0001'; END IF;
    RETURN;
  END IF;
  rev:=mission_generic_owner.role_source_revision_v1(w.master_session_id);
  IF mission_generic_owner.role_native_combat_work_class_v4(w.id) IS NOT NULL THEN
    RETURN;
  END IF;
  IF w.kind='director' AND w.payload->>'schema_version'='mission-director-work/4' THEN
   IF NOT mission_generic_owner.c1266_role_scope_v2(w.master_session_id,true)
    OR mission_generic_owner.c1266_role_work_attest_v2(w.id) IS NULL
    OR w.payload#>>'{context,source_revision}' IS DISTINCT FROM rev THEN RAISE EXCEPTION 'C1266_TEMPORAL_DISPATCH_STALE' USING ERRCODE='P0001';END IF;
   RETURN;
  END IF;
  IF w.kind='director' AND w.payload->>'schema_version'='mission-director-work/3' THEN
    IF NOT mission_generic_owner.c1266_role_scope_v1(w.master_session_id,true)
     OR mission_generic_owner.c1266_role_work_attest_v1(w.id) IS NULL
     OR w.payload#>>'{context,source_revision}' IS DISTINCT FROM rev THEN RAISE EXCEPTION 'C1266_DIRECTOR5_STALE' USING ERRCODE='P0001';END IF;
    RETURN;
  END IF;
  IF w.kind='director' THEN
    IF w.payload->>'schema_version'<>'mission-director-work/2'
      OR w.payload#>>'{context,source_revision}' IS DISTINCT FROM rev
    THEN RAISE EXCEPTION 'MRS_V4_DISPATCH_STALE_DIRECTOR' USING ERRCODE='P0001'; END IF;
  ELSIF w.kind='narration' THEN
    IF w.payload->>'schema_version'<>'mission-generic-narration/4'
      OR w.payload->>'source_revision' IS DISTINCT FROM rev
    THEN RAISE EXCEPTION 'MRS_V4_DISPATCH_STALE_NARRATION' USING ERRCODE='P0001'; END IF;
  ELSE
    RAISE EXCEPTION 'MRS_V4_DISPATCH_LEGACY_KIND' USING ERRCODE='P0001';
  END IF;
END;
$$;
CREATE OR REPLACE FUNCTION public.mission_role_submit_v1(p_session uuid, p_character uuid, p_body text) RETURNS jsonb LANGUAGE plpgsql SECURITY DEFINER SET search_path TO '' AS $$
DECLARE u uuid := auth.uid(); m public.master_v2_sessions%ROWTYPE;
        l public.locations%ROWTYPE; mid uuid; ch uuid;
        submission mission_generic_owner.role_submissions%ROWTYPE;
        previous_guided text := current_setting('app.combat_guidata',true);
        scene56 boolean:=false;
        rc37_scope boolean:=false;rc37_enabled boolean:=false;rc37_cmd jsonb;rc37_key uuid;
        rc37_epoch bigint;rc37_expected uuid;rc37_latest uuid;rc37_body text;
        rc37_body_sha text;rc37_request_sha text;rc37_receipt jsonb;
        rc37_cursor mission_generic_owner.role_window_cursors%ROWTYPE;
        rc37_row mission_generic_owner.role_commands_v2%ROWTYPE;
        rc37_previous_nonce text:=current_setting('app.mission_role_command_v2',true);
BEGIN
  IF u IS NULL THEN RAISE EXCEPTION 'ROLE_SUBMIT_AUTH_REQUIRED' USING ERRCODE='42501'; END IF;
  SELECT * INTO STRICT m FROM public.master_v2_sessions WHERE id=p_session;
  SELECT * INTO STRICT l FROM public.locations WHERE id=m.location_id;
  scene56:=EXISTS(SELECT 1 FROM mission_narrative_internal.scene_runtime_v1 WHERE master_session_id=p_session AND is_active AND mode<>'combat');
  rc37_scope:=l.id='0b85f354-9cdb-47e1-baf9-3d266bb7e06b'::uuid AND l.is_test
    AND EXISTS(SELECT 1 FROM public.profiles rp37 WHERE rp37.id=u AND rp37.role IN('admin','master'));
  IF rc37_scope THEN
    BEGIN rc37_cmd:=p_body::jsonb;
    EXCEPTION WHEN invalid_text_representation THEN rc37_cmd:=NULL;
    END;
  END IF;
  IF scene56 AND (NOT rc37_scope OR rc37_cmd->>'schema_version' IS DISTINCT FROM 'mission-role-command/2') THEN RAISE EXCEPTION 'SCENE56_ROLE_COMMAND_REQUIRED' USING ERRCODE='22023';END IF;
  IF rc37_scope AND rc37_cmd->>'schema_version'='mission-role-command/2' THEN
    IF jsonb_typeof(rc37_cmd) IS DISTINCT FROM 'object'
      OR rc37_cmd->>'schema_version' IS DISTINCT FROM 'mission-role-command/2'
      OR (SELECT count(*) FROM jsonb_object_keys(rc37_cmd))<>5
      OR NOT(rc37_cmd ?& ARRAY['schema_version','request_key','window_epoch','expected_own_latest','body'])
      OR jsonb_typeof(rc37_cmd->'request_key') IS DISTINCT FROM 'string'
      OR NOT(coalesce(rc37_cmd->>'request_key','') ~ '^[a-fA-F0-9]{8}(-[a-fA-F0-9]{4}){3}-[a-fA-F0-9]{12}$')
      OR jsonb_typeof(rc37_cmd->'window_epoch') IS DISTINCT FROM 'number'
      OR NOT(coalesce(rc37_cmd->>'window_epoch','') ~ '^[0-9]{1,16}$')
      OR (rc37_cmd->>'window_epoch')::numeric>9007199254740991
      OR NOT(rc37_cmd->'expected_own_latest'='null'::jsonb OR
        (jsonb_typeof(rc37_cmd->'expected_own_latest')='string' AND
         coalesce(rc37_cmd->>'expected_own_latest','') ~ '^[a-fA-F0-9]{8}(-[a-fA-F0-9]{4}){3}-[a-fA-F0-9]{12}$'))
      OR jsonb_typeof(rc37_cmd->'body') IS DISTINCT FROM 'string'
      OR nullif(btrim(rc37_cmd->>'body'),'') IS NULL
    THEN RAISE EXCEPTION 'ROLE_COMMAND_SHAPE_INVALID' USING ERRCODE='22023'; END IF;
    rc37_key:=(rc37_cmd->>'request_key')::uuid;rc37_epoch:=(rc37_cmd->>'window_epoch')::bigint;
    rc37_expected:=(rc37_cmd->>'expected_own_latest')::uuid;rc37_body:=rc37_cmd->>'body';
    rc37_body_sha:=encode(extensions.digest(convert_to(rc37_body,'UTF8'),'sha256'),'hex');
    rc37_request_sha:=public.combat_v2_sha256(jsonb_build_object('master_session_id',p_session,'user_id',u,
      'character_id',p_character,'command',rc37_cmd));
    IF p_character IS NULL OR NOT EXISTS(SELECT 1 FROM public.characters rp37_ch WHERE rp37_ch.id=p_character AND rp37_ch.user_id=u)
    THEN RAISE EXCEPTION 'ROLE_SUBMIT_CHARACTER_INVALID' USING ERRCODE='42501'; END IF;
    IF scene56 THEN PERFORM 1 FROM public.locations WHERE id=m.location_id FOR UPDATE;END IF;
    SELECT * INTO rc37_cursor FROM mission_generic_owner.role_window_cursors rp37_cursor
      WHERE rp37_cursor.master_session_id=p_session FOR UPDATE;
    IF NOT FOUND THEN RAISE EXCEPTION 'ROLE_SUBMIT_SCOPE_CLOSED' USING ERRCODE='42501'; END IF;
    SELECT * INTO rc37_row FROM mission_generic_owner.role_commands_v2 rp37_command
      WHERE rp37_command.master_session_id=p_session AND rp37_command.user_id=u
       AND rp37_command.character_id=p_character AND rp37_command.request_key=rc37_key;
    IF FOUND THEN
      IF rc37_row.request_sha256 IS DISTINCT FROM rc37_request_sha OR rc37_row.body_sha256 IS DISTINCT FROM rc37_body_sha
       OR rc37_row.window_epoch IS DISTINCT FROM rc37_epoch OR rc37_row.expected_own_latest IS DISTINCT FROM rc37_expected
      THEN RAISE EXCEPTION 'ROLE_COMMAND_NONCE_CONFLICT' USING ERRCODE='22023'; END IF;
      IF rc37_row.state IS DISTINCT FROM 'accepted' OR rc37_row.receipt_sha256 IS DISTINCT FROM public.combat_v2_sha256(rc37_row.receipt)
       OR NOT EXISTS(SELECT 1 FROM mission_generic_owner.role_submissions rp37_replay
        WHERE rp37_replay.master_session_id=p_session AND rp37_replay.message_id=rc37_row.message_id
         AND rp37_replay.user_id=u AND rp37_replay.character_id=p_character
         AND rp37_replay.window_epoch=rc37_epoch AND rp37_replay.body_sha256=rc37_body_sha)
      THEN RAISE EXCEPTION 'ROLE_COMMAND_RECEIPT_INVALID' USING ERRCODE='42501'; END IF;
      RETURN rc37_row.receipt||jsonb_build_object('replayed',true);
    END IF;
    SELECT coalesce(rr37.canonical_preimage::jsonb#>'{config,c1266_role_command_v2}'=
      jsonb_build_object('schema_version','mission-role-command-policy/1','enabled',true),false)
      INTO rc37_enabled FROM mission_factory_owner.editor_release_readiness rr37
      WHERE rr37.singleton AND rr37.state='enabled' AND rr37.scope='staff';
    IF rc37_enabled IS DISTINCT FROM true THEN RAISE EXCEPTION 'ROLE_COMMAND_DISABLED' USING ERRCODE='42501'; END IF;
    SELECT * INTO STRICT m FROM public.master_v2_sessions WHERE id=p_session;
    IF scene56 THEN
     PERFORM 1 FROM mission_narrative_internal.scene_runtime_v1 WHERE master_session_id=p_session AND is_active AND mode='narrative' AND turn_owner='players' FOR UPDATE;
     IF NOT FOUND THEN RAISE EXCEPTION 'SCENE56_NOT_PLAYER_TURN' USING ERRCODE='42501';END IF;
    END IF;
    IF m.location_id IS DISTINCT FROM l.id OR m.closed_at IS NOT NULL OR m.owner_kind<>'ai_service'
      OR NOT mission_public_owner.role_capture_scope_v1(m.id)
      OR NOT EXISTS(SELECT 1 FROM public.master_v2_participants rp37_part
        WHERE rp37_part.session_id=m.id AND rp37_part.user_id_snapshot=u
          AND rp37_part.character_id=p_character AND rp37_part.left_at IS NULL AND rp37_part.engagement_state='attivo')
      OR (CASE WHEN scene56 THEN false ELSE EXISTS(SELECT 1 FROM mission_generic_owner.encounters rp37_enc JOIN public.combat_v2_sessions rp37_cs
        ON rp37_cs.id=rp37_enc.encounter_id WHERE rp37_enc.master_session_id=p_session AND rp37_cs.closed_at IS NULL) END)
    THEN RAISE EXCEPTION 'ROLE_SUBMIT_SCOPE_CLOSED' USING ERRCODE='42501'; END IF;
    SELECT rp37_latest.message_id INTO rc37_latest FROM mission_generic_owner.role_submissions rp37_latest
      WHERE rp37_latest.master_session_id=p_session AND rp37_latest.window_epoch=rc37_cursor.window_epoch
        AND rp37_latest.user_id=u AND rp37_latest.character_id=p_character
      ORDER BY rp37_latest.accepted_at DESC,rp37_latest.message_id DESC LIMIT 1;
    IF rc37_cursor.window_epoch IS DISTINCT FROM rc37_epoch OR rc37_latest IS DISTINCT FROM rc37_expected
    THEN RAISE EXCEPTION 'ROLE_COMMAND_CONTEXT_CHANGED' USING ERRCODE='P0001'; END IF;
    INSERT INTO mission_generic_owner.role_commands_v2(master_session_id,user_id,character_id,request_key,
      window_epoch,expected_own_latest,body_sha256,request_sha256,origin_txid,origin_backend,state)
    VALUES(p_session,u,p_character,rc37_key,rc37_epoch,rc37_expected,rc37_body_sha,rc37_request_sha,txid_current(),pg_backend_pid(),'pending');
    PERFORM set_config('app.mission_role_session',p_session::text,true);
    PERFORM set_config('app.mission_role_character',p_character::text,true);
    PERFORM set_config('app.mission_role_command_v2',rc37_key::text,true);
    PERFORM set_config('app.combat_guidata','1',true);
    IF scene56 THEN
     INSERT INTO public.messages(location_id,character_id,author_name,body,kind,sender_user,recipient_user,created_at)
     SELECT m.location_id,ch56.id,ch56.name,rc37_body,'say',u,NULL,clock_timestamp()
     FROM public.characters ch56 WHERE ch56.id=p_character AND ch56.user_id=u RETURNING id INTO mid;
     IF mid IS NULL THEN RAISE EXCEPTION 'ROLE_SUBMIT_CHARACTER_DRIFT' USING ERRCODE='42501';END IF;
    ELSE
    mid:=public.post_message(m.location_id,rc37_body,NULL,NULL,NULL);
    END IF;
    PERFORM set_config('app.combat_guidata',coalesce(previous_guided,''),true);
    PERFORM set_config('app.mission_role_session','',true);
    PERFORM set_config('app.mission_role_character','',true);
    PERFORM set_config('app.mission_role_command_v2',coalesce(rc37_previous_nonce,''),true);
    SELECT character_id INTO STRICT ch FROM public.messages WHERE id=mid;
    IF ch IS DISTINCT FROM p_character THEN RAISE EXCEPTION 'ROLE_SUBMIT_CHARACTER_DRIFT' USING ERRCODE='P0001'; END IF;
    SELECT * INTO STRICT submission FROM mission_generic_owner.role_submissions rp37_submission
      WHERE rp37_submission.master_session_id=p_session AND rp37_submission.message_id=mid;
    IF submission.user_id IS DISTINCT FROM u OR submission.character_id IS DISTINCT FROM p_character
      OR submission.window_epoch IS DISTINCT FROM rc37_epoch OR submission.body_sha256 IS DISTINCT FROM rc37_body_sha
    THEN RAISE EXCEPTION 'ROLE_COMMAND_CAPTURE_INVALID' USING ERRCODE='42501'; END IF;
    rc37_receipt:=jsonb_build_object('schema_version','mission-role-submit/2','master_session_id',p_session,
      'message_id',mid,'accepted',true,'mission_valid',submission.valid,'invalid_reason',submission.invalid_reason,
      'source_revision',CASE WHEN scene56 THEN (SELECT public.combat_v2_sha256(jsonb_build_object('scene_id',s56.id,'state_version',s56.state_version,'epoch',c56.window_epoch,'role_revision',c56.role_revision)) FROM mission_narrative_internal.scene_runtime_v1 s56 JOIN mission_generic_owner.role_window_cursors c56 ON c56.master_session_id=s56.master_session_id WHERE s56.master_session_id=p_session) ELSE mission_generic_owner.role_source_revision_v1(p_session) END,
      'request_key',rc37_key,'replayed',false,'status','accepted');
    UPDATE mission_generic_owner.role_commands_v2 SET state='accepted',message_id=mid,receipt=rc37_receipt,
      receipt_sha256=public.combat_v2_sha256(rc37_receipt),accepted_at=submission.accepted_at
      WHERE master_session_id=p_session AND user_id=u AND character_id=p_character AND request_key=rc37_key
        AND state='pending' AND origin_txid=txid_current() AND origin_backend=pg_backend_pid();
    IF NOT FOUND THEN RAISE EXCEPTION 'ROLE_COMMAND_RECEIPT_INVALID' USING ERRCODE='42501'; END IF;
    RETURN rc37_receipt;
  END IF;
  IF m.closed_at IS NOT NULL OR m.owner_kind<>'ai_service' OR NOT mission_public_owner.role_capture_scope_v1(m.id)
    OR NOT EXISTS(SELECT 1 FROM mission_generic_owner.role_window_cursors c
      WHERE c.master_session_id=m.id)
  THEN RAISE EXCEPTION 'ROLE_SUBMIT_SCOPE_CLOSED' USING ERRCODE='42501'; END IF;
  IF p_character IS NULL OR NOT EXISTS(SELECT 1 FROM public.characters
    WHERE id=p_character AND user_id=u)
  THEN RAISE EXCEPTION 'ROLE_SUBMIT_CHARACTER_INVALID' USING ERRCODE='42501'; END IF;
  IF NOT EXISTS(SELECT 1 FROM public.master_v2_participants mp
    WHERE mp.session_id=m.id AND mp.user_id_snapshot=u
      AND mp.character_id=p_character AND mp.left_at IS NULL
      AND mp.engagement_state='attivo')
  THEN RAISE EXCEPTION 'ROLE_SUBMIT_NOT_PARTICIPANT' USING ERRCODE='42501'; END IF;
  IF nullif(btrim(coalesce(p_body,'')),'') IS NULL
  THEN RAISE EXCEPTION 'ROLE_SUBMIT_EMPTY' USING ERRCODE='22023'; END IF;

  -- Serialize role acceptance with publication before rechecking Combat authority.
  PERFORM 1 FROM mission_generic_owner.role_window_cursors c
    WHERE c.master_session_id=p_session FOR UPDATE;
  IF NOT FOUND THEN RAISE EXCEPTION 'ROLE_SUBMIT_SCOPE_CLOSED' USING ERRCODE='42501'; END IF;
  SELECT * INTO STRICT m FROM public.master_v2_sessions WHERE id=p_session;
  IF m.location_id IS DISTINCT FROM l.id
    OR m.closed_at IS NOT NULL OR m.owner_kind<>'ai_service'
    OR NOT mission_public_owner.role_capture_scope_v1(m.id)
    OR EXISTS(SELECT 1 FROM mission_generic_owner.encounters ge JOIN public.combat_v2_sessions cs ON cs.id=ge.encounter_id
      WHERE ge.master_session_id=p_session AND cs.closed_at IS NULL)
  THEN RAISE EXCEPTION 'ROLE_SUBMIT_SCOPE_CLOSED' USING ERRCODE='42501'; END IF;

  PERFORM set_config('app.mission_role_session',p_session::text,true);
  PERFORM set_config('app.mission_role_character',p_character::text,true);
  -- Il messaggio di missione e' narrativo, non una dichiarazione del motore
  -- legacy Combat nella stanza condivisa. Preserva il flag del chiamante.
  PERFORM set_config('app.combat_guidata','1',true);
  mid:=public.post_message(m.location_id,p_body,NULL,NULL,NULL);
  PERFORM set_config('app.combat_guidata',coalesce(previous_guided,''),true);
  PERFORM set_config('app.mission_role_session','',true);
  PERFORM set_config('app.mission_role_character','',true);
  SELECT character_id INTO STRICT ch FROM public.messages WHERE id=mid;
  IF ch IS DISTINCT FROM p_character
  THEN RAISE EXCEPTION 'ROLE_SUBMIT_CHARACTER_DRIFT' USING ERRCODE='40001'; END IF;
  SELECT * INTO STRICT submission FROM mission_generic_owner.role_submissions
    WHERE master_session_id=p_session AND message_id=mid;
  RETURN jsonb_build_object('schema_version','mission-role-submit/1',
    'master_session_id',p_session,'message_id',mid,
    'accepted',true,'mission_valid',submission.valid,
    'invalid_reason',submission.invalid_reason,
    'source_revision',mission_generic_owner.role_source_revision_v1(p_session));
END;
$$;
CREATE OR REPLACE FUNCTION public.mission_generic_room_state_v1(p_location uuid) RETURNS jsonb LANGUAGE plpgsql SECURITY DEFINER SET search_path TO '' AS $$
declare scene56 mission_narrative_internal.scene_runtime_v1;surface56 jsonb;public56 jsonb;event56 jsonb;caps56 jsonb;
 uid uuid:=auth.uid();m public.master_v2_sessions;r public.mission_run_state;vchoices jsonb;
 staff boolean;participant boolean;objective text;active boolean; uf_work mission_generic_owner.work_items;uf_processing jsonb;uf_rounds jsonb;uf_progress_key text;uf_state text;uf_marker jsonb;uf_review boolean;
 academy boolean;flow_state text;flow_publication uuid;role_diag jsonb;
 private_source_step text;private_pending boolean:=false;combat_recovery jsonb;
 staff_tick_view jsonb:=NULL;st_revision text;st_tick mission_generic_owner.staff_progress_ticks_v1;st_receipt mission_generic_owner.progress_receipts;
 st_work record;st_source record;st_dispatch jsonb;st_next_key uuid;st_original_key uuid;st_owner boolean:=false;
 st_valid boolean:=false;st_released boolean:=false;st_blocked boolean:=false;st_resume boolean:=false;
 st_ack_predecessor uuid:=NULL;st_candidate_predecessor uuid:=NULL;
 st_depth integer:=0;st_state text;st_public_state text;st_recovery uuid;st_effective_id uuid;
 st_budget_a mission_generic_owner.dispatch_admissions;st_budget_g mission_generic_owner.provider_policy;st_budget_p record;
 mb_read_recovery boolean:=false;mb_mode boolean:=false; st_spent numeric;st_http bigint;st_bound numeric;st_cap_cost numeric;st_cap_http integer;st_budget_ok boolean:=false;
 opening_resume49 jsonb:=NULL;opening_claim_resume6 jsonb:=NULL;
 journal_settlements jsonb:=NULL;
 retained_handoff jsonb:=NULL;retained_row record;
 c26_count_view jsonb:=NULL;c26_driver jsonb:=NULL;c26_proof jsonb;c26_kind text;c26_revision text;c26_phase_kind text;
  nw_original_sha text;nw_original_key uuid;nw_mode boolean:=false;
 budget1_effective numeric;budget1_policy numeric;
 role_command_capability jsonb:=NULL;role_command_enabled boolean:=false;event42_mode boolean:=false;
begin
 if uid is null then raise exception 'authentication_required' using errcode='28000';end if;
 staff:=exists(select 1 from public.profiles where id=uid and role in('admin','master'));
 select s.* into m from public.master_v2_sessions s join mission_generic_owner.run_bindings b on b.master_session_id=s.id
 where s.location_id=p_location and s.closed_at is null and s.owner_kind='ai_service'
 and (staff or exists(select 1 from public.master_v2_participants p join public.characters c on c.id=p.character_id and c.user_id=uid
  where p.session_id=s.id and p.user_id_snapshot=uid and p.left_at is null)) order by s.created_at desc limit 1;
 if m.id is null then return null;end if;
 perform mission_generic_owner.assert_runtime(m.id);
 select * into strict r from public.mission_run_state where master_session_id=m.id;
 SELECT * INTO scene56 FROM mission_narrative_internal.scene_runtime_v1 WHERE master_session_id=m.id AND is_active;
 IF FOUND THEN
  public56:=jsonb_build_object('schema_version','mission-narrative-scene-public/1','scene_id',scene56.id,
   'state_version',scene56.state_version,'mode',scene56.mode,'last_publication_id',scene56.last_publication_id);
  surface56:=mission_narrative_internal.scene_entry_surface_v1(m.id,uid);
  IF scene56.mode<>'combat' THEN
   SELECT jsonb_build_object('schema_version','mission-role-submit-capability/2',
    'enabled',scene56.mode='narrative' AND scene56.turn_owner='players',
    'contexts',coalesce(jsonb_agg(jsonb_build_object('character_id',p.character_id,'window_epoch',cur.window_epoch,
     'own_latest_message_id',(SELECT rs.message_id FROM mission_generic_owner.role_submissions rs
      WHERE rs.master_session_id=m.id AND rs.window_epoch=cur.window_epoch AND rs.user_id=uid
       AND rs.character_id=p.character_id ORDER BY rs.accepted_at DESC,rs.message_id DESC LIMIT 1)) ORDER BY p.character_id),'[]'::jsonb))
   INTO caps56 FROM public.master_v2_participants p JOIN public.characters ch ON ch.id=p.character_id AND ch.user_id=uid
   JOIN mission_generic_owner.role_window_cursors cur ON cur.master_session_id=p.session_id
   WHERE p.session_id=m.id AND p.user_id_snapshot=uid AND p.left_at IS NULL AND p.engagement_state='attivo';
   SELECT jsonb_build_object('event_key',es.event_key,'event_version',es.event_version,'state',es.state,
    'can_recover',es.root_principal=uid AND scene56.mode<>'closed'
     AND (es.state<>'running' OR es.claim_expires_at<=clock_timestamp())
     AND (es.work_id IS NULL OR EXISTS(SELECT 1 FROM mission_generic_owner.work_items ew
      WHERE ew.id=es.work_id AND ew.state='ready' AND ew.lease_id IS NULL))) INTO event56
   FROM mission_generic_owner.event_outbox_v1 es WHERE es.master_session_id=m.id
   ORDER BY es.created_at DESC,es.event_key DESC,es.event_version DESC LIMIT 1;
   RETURN jsonb_build_object('session_id',m.id,'step_key',scene56.current_phase_key,
    'objective',(SELECT x->>'objective' FROM jsonb_array_elements(scene56.snapshot->'phases')x WHERE x->>'phase_key'=scene56.current_phase_key),
    'narrative_scene',public56,'role_submit_capability',caps56,'server_event_mode','server_event_v1',
    'server_event_status',event56,'combat_surface',surface56,'staff_finish',mission_generic_owner.staff_finish_status_v1(m.id,uid));
  END IF;
 END IF;
 select sw.step_key into private_source_step from mission_generic_owner.unified_batches pending_batch
 join mission_generic_owner.unified_source_windows sw on sw.id=pending_batch.source_window_id
 where pending_batch.master_session_id=m.id AND pending_batch.composition_kind='entry_png'
   AND pending_batch.state IN('preparing','ready') AND pending_batch.retired_at IS NULL AND pending_batch.message_id IS NULL
   AND pending_batch.encounter_id IS NOT NULL
 order by pending_batch.created_at desc,pending_batch.id desc limit 1;
 private_pending:=private_source_step IS NOT NULL;
 participant:=exists(select 1 from public.master_v2_participants p join public.characters c on c.id=p.character_id and c.user_id=uid
 where p.session_id=m.id and p.user_id_snapshot=uid and p.left_at is null);
 event42_mode:=EXISTS(SELECT 1 FROM mission_generic_owner.event_outbox_v1 mode42 WHERE mode42.master_session_id=m.id AND mode42.event_domain='start');
 -- Quest uses its own native source (mission_id is NULL). No private context is emitted.
 academy:=mission_creation_owner.director_context(m.id,r.current_step_key) is not null
 or exists(select 1 from mission_factory_owner.quest_run_sources qs
   join public.mission_plan_versions pv on pv.id=qs.plan_version_id
   join public.mission_plans qp on qp.id=pv.plan_id
   join mission_generic_owner.run_bindings qb on qb.master_session_id=qs.session_id
   join mission_generic_owner.definitions qd on qd.id=qb.definition_id
   join public.locations ql on ql.id=qs.location_id
   where qs.session_id=m.id and qs.state in('prepared','opening_pending','uncertain','started')
    and m.mission_id is null and m.tipo='quest' and qs.location_id=m.location_id
    and qs.plan_version_id=r.plan_version_id and qp.source_kind='quest'
    and qp.quest_episode_id=qs.episode_id and qp.quest_source_sha256=qs.source_sha256
    and qd.id=qs.definition_id and qd.plan_version_id=qs.plan_version_id
    and qd.plan_sha256=r.plan_sha256 and qb.snapshot_sha256=mission_internal.fingerprint(qb.snapshot)
    and qd.definition_sha256=mission_internal.fingerprint(qd.definition)
    and ql.id='0b85f354-9cdb-47e1-baf9-3d266bb7e06b'::uuid and ql.is_active and ql.is_test);
 select public_objective into objective from public.mission_plan_steps where plan_version_id=r.plan_version_id
   and step_key=coalesce(private_source_step,r.current_step_key);
 if participant and not academy then vchoices:=public.mission_generic_choices_v1(m.id);
 else vchoices:=jsonb_build_object('choices','[]'::jsonb);end if;
 active:=m.stato in('preparazione','in_corso') and m.suspended_at is null and r.run_phase in('preparazione','in_corso');
 -- Public metadata only; no work payload, private intent, role or provider configuration.
 WITH room_session_source_rows AS MATERIALIZED (
  SELECT room_source.id,room_source.work_id
  FROM mission_generic_owner.unified_source_windows room_source
  WHERE room_source.master_session_id=m.id
 ), room_released_sources AS MATERIALIZED (
  SELECT room_source_row.id,room_source_row.work_id
  FROM room_session_source_rows room_source_row
  WHERE mission_generic_owner.role_source_released_v4(room_source_row.id)
 )
 select uf_candidate.* into uf_work from mission_generic_owner.work_items uf_candidate
where uf_candidate.master_session_id=m.id
 and not exists(
   select 1 from room_released_sources superseded_role
   left join mission_generic_owner.unified_batches superseded_batch
     on superseded_batch.source_window_id=superseded_role.id
   where (superseded_role.work_id=uf_candidate.id
       or superseded_batch.writer_work_id=uf_candidate.id))
 and not (m.id='b70b23cf-bad8-475d-a56a-d9c549e35d84'::uuid
   and mission_generic_owner.flow_scope_enabled(m.id)
   and exists(select 1 from mission_generic_owner.unified_source_windows superseded
     where superseded.id=uf_candidate.id and superseded.superseded_at is not null))
 and not (
  m.id='93d78313-abde-4087-9eb7-7b96bc0fa089'::uuid
  and m.location_id='6c737082-8fc7-4fd8-b246-30297a1ed1af'::uuid
  and uf_candidate.id='3076c471-37c5-438e-8f50-0a790b787e05'::uuid
  and uf_candidate.kind='choice' and uf_candidate.state='failed'
  and uf_candidate.encounter_id='deadfef6-5b16-4921-aa86-b86ffad6f2f2'::uuid
  and uf_candidate.step_key=r.current_step_key
  and uf_candidate.run_control_version=r.control_version
  and uf_candidate.payload->>'actor_id'='1f662f89-447a-4cd3-9873-a5953a0e0d91'
  and uf_candidate.payload->>'round_id'='44061137-17a3-43fa-9225-d29aaa26e58a'
  and uf_candidate.payload_sha256=public.combat_v2_sha256(uf_candidate.payload)
  and uf_candidate.result_sha256=public.combat_v2_sha256(uf_candidate.result)
  and uf_candidate.result->>'schema_version'='mission-generic-pre-provider-failure/1'
  and uf_candidate.result->>'failure_code'='request_validation_failed'
  and uf_candidate.result->>'provider_calls'='0'
  and uf_candidate.result->>'charged_cost_usd'='0'
  and (select md5(prosrc) from pg_proc where oid='mission_generic_owner.enqueue_choice(uuid,uuid,uuid)'::regprocedure)
      ='76a88f0e93752e1456c90d160a7a855d'
  and exists (
    select 1 from mission_generic_owner.unified_batches ub
    where ub.id='fbfc8e29-8724-4241-b2fe-22dbc17eb9e7'::uuid
      and ub.master_session_id=m.id and ub.encounter_id=uf_candidate.encounter_id
      and ub.state='preparing' and ub.entry_side='png'
      and ub.next_round_id='44061137-17a3-43fa-9225-d29aaa26e58a'::uuid
  )
  and not exists (
    select 1 from mission_generic_owner.work_items rw
    where rw.master_session_id=m.id
      and rw.dedupe_key=uf_candidate.dedupe_key||':recovery:'||uf_candidate.id::text
  )
  and not exists (
    select 1 from public.combat_v2_declarations d
    where d.round_id='44061137-17a3-43fa-9225-d29aaa26e58a'::uuid
      and d.actor_id='1f662f89-447a-4cd3-9873-a5953a0e0d91'::uuid
  )
 )
 order by (uf_candidate.state not in('completed','failed')) desc,
  case when uf_candidate.state not in('completed','failed') then uf_candidate.created_at end asc,
  uf_candidate.created_at desc,uf_candidate.id limit 1;
 if uf_work.id is not null then
  uf_state:=case when uf_work.state in('claimed','authorized','provider_started')
    and uf_work.lease_expires_at<=statement_timestamp() then 'uncertain' else uf_work.state end;
  uf_processing:=jsonb_build_object('schema_version','mission-generic-processing/1',
   'work_id',uf_work.id,'event_id',uf_work.event_id,'request_key',uf_work.request_key,
   'revision',uf_work.revision,'state',uf_state,'created_at',uf_work.created_at,
   'finalized_at',uf_work.finalized_at,'message_id',uf_work.message_id,
   'request',jsonb_build_object('schema_version','mission-generic-request/1',
    'master_session_id',m.id,'event_id',uf_work.event_id,'request_key',uf_work.request_key,
    'expected_revision',uf_work.revision));
 end if;
 -- Freeze only identities/states needed to wake progress, never the clock. Include
 -- declarations because a completed defense may advance mechanics without a run transition.
 select coalesce(jsonb_agg(jsonb_build_object('encounter_id',uf_enc.id,'state',uf_enc.state,
  'rounds',coalesce((select jsonb_agg(jsonb_build_object('round_id',uf_r.id,'phase',uf_r.phase,
    'state',uf_r.state,'report_id',uf_r.report_id,'narrated_at',uf_r.narrated_at,
    'declarations',coalesce((select jsonb_agg(jsonb_build_array(uf_d.id,uf_d.state) order by uf_d.id)
       from public.combat_v2_declarations uf_d where uf_d.round_id=uf_r.id),'[]'::jsonb)) order by uf_r.round_no)
   from (select uf_round.* from public.combat_v2_rounds uf_round where uf_round.session_id=uf_enc.id
     order by uf_round.round_no desc limit 2) uf_r),'[]'::jsonb)) order by uf_enc.id),'[]'::jsonb)
 into uf_rounds from public.combat_v2_sessions uf_enc
 where uf_enc.master_session_id=m.id and uf_enc.closed_at is null
 and not exists(select 1 from mission_generic_owner.unified_batches hidden_batch
   where hidden_batch.encounter_id=uf_enc.id and hidden_batch.source_window_id is not null
     and hidden_batch.composition_kind='entry_png' AND hidden_batch.retired_at IS NULL and hidden_batch.state in('preparing','ready')
     and hidden_batch.message_id is null);
 uf_marker:=mission_generic_owner.unified_progress_marker(m.id);
 if private_pending then uf_marker:=jsonb_set(uf_marker,'{batch}','null'::jsonb,false);end if;
 uf_review:=coalesce((uf_marker->>'review_required')::boolean,false);
 if academy and m.stato='in_corso' and r.run_phase='in_corso' then
  select rw.publication_id into flow_publication
  from mission_generic_owner.unified_round_windows rw
  join public.combat_v2_rounds cr on cr.id=rw.round_id
  join public.combat_v2_sessions cs on cs.id=cr.session_id
  where rw.master_session_id=m.id and rw.publication_id is not null
   and cs.closed_at is null and cs.state='in_corso'
  order by cr.round_no desc,rw.round_id desc limit 1;
  if flow_publication is not null then flow_state:='combat_started';
  else
   select ub.message_id into flow_publication
   from mission_generic_owner.unified_batches ub
   where ub.master_session_id=m.id and ub.step_key=r.current_step_key
    and ub.run_control_version=r.control_version and ub.state='published'
    and ub.route is not null and ub.encounter_id is null
   order by ub.published_at desc,ub.id desc limit 1;
   if uf_work.state in('claimed','authorized','provider_started')
or exists(select 1 from mission_generic_owner.unified_batches ub
     where ub.master_session_id=m.id AND ub.retired_at IS NULL and ub.state in('preparing','ready','needs_review')
       and not mission_generic_owner.role_source_released_v4(ub.source_window_id))
    or exists(select 1 from mission_generic_owner.unified_source_windows sw
     where sw.master_session_id=m.id and sw.consumed_message_id is null
      AND NOT(sw.superseded_at IS NOT NULL AND mission_generic_owner.role_source_released_v4(sw.id))
      and (m.id<>'b70b23cf-bad8-475d-a56a-d9c549e35d84'::uuid
        or not mission_generic_owner.flow_scope_enabled(m.id) or sw.superseded_at is null))
   then flow_state:='evaluating';flow_publication:=null;
   elsif flow_publication is not null and not exists(
    select 1 from public.messages role_msg
    where role_msg.location_id=m.location_id and role_msg.kind='say'
     and role_msg.recipient_user is null
     and role_msg.created_at>(select scene_msg.created_at from public.messages scene_msg where scene_msg.id=flow_publication)
     and exists(select 1 from public.master_v2_participants mp
      join public.characters c on c.id=mp.character_id and c.user_id=mp.user_id_snapshot
      where mp.session_id=m.id and mp.character_id=role_msg.character_id
       and mp.joined_at<=role_msg.created_at and (mp.left_at is null or mp.left_at>role_msg.created_at)))
   then flow_state:='new_scene';
   else flow_state:='waiting_roles';flow_publication:=null;end if;
  end if;
 end if;
 if private_pending then
  flow_state:='evaluating';flow_publication:=null;
  vchoices:=jsonb_build_object('choices','[]'::jsonb);
 end if;
 mb_read_recovery:=staff AND participant AND academy AND active
  AND p_location='0b85f354-9cdb-47e1-baf9-3d266bb7e06b'::uuid AND m.id='44078c5f-7001-4129-9506-e2f34e68c8ac'::uuid
  AND m.stato='in_corso' AND r.run_phase='in_corso'
  AND mission_generic_owner.manual_staff_count_limit_v1(m.id)='none'
  AND mission_generic_owner.role_source_revision_v1(m.id)='24db5db8da7ede254e6d719b587c4fa04dce6b9d1c920396251adb85d0f6294c'
  AND EXISTS(SELECT 1 FROM mission_generic_owner.staff_progress_ticks_v1 pt JOIN mission_generic_owner.progress_receipts pp
   ON pp.request_key=pt.request_key AND pp.master_session_id=pt.master_session_id AND pp.actor_user_id=pt.actor_user_id AND pp.result_sha256=pt.result_sha256 AND pp.result_sha256=public.combat_v2_sha256(pp.result)
   WHERE pt.master_session_id=m.id AND pt.request_key='9e48a416-9261-4399-9e4e-a82b8a3d3a48'::uuid
    AND pt.source_revision='24db5db8da7ede254e6d719b587c4fa04dce6b9d1c920396251adb85d0f6294c'
    AND pt.actor_user_id='b4952ed5-5ce0-49c0-9f2b-8fd5dcd89b4b'::uuid AND pt.staff_user_id=pt.actor_user_id
    AND pt.result_sha256='b27ed0db18a45d371931f015be0cd0fa060ed3f99b8d5843e8cbef45ecfbb2f8'
    AND mission_factory_owner.keys_exact_v2(pp.result,ARRAY['schema_version','master_session_id','state','dispatch','reason_code'])
    AND pp.result->>'schema_version'='mission-generic-progress/1' AND pp.result->>'master_session_id'=m.id::text
    AND pp.result->>'state'='paused' AND pp.result->>'reason_code'='MGPG_C7_RUN_BUDGET_STOP' AND pp.result->'dispatch'='null'::jsonb);
 IF academy AND (mission_public_owner.role_capture_scope_v1(m.id) OR mb_read_recovery)
 
THEN
  IF EXISTS(SELECT 1 FROM mission_generic_owner.role_window_cursors c
    WHERE c.master_session_id=m.id) THEN
    role_diag:=mission_generic_owner.role_flow_status_v1(m.id,uid);
  ELSE
    role_diag:=mission_generic_owner.role_status_snapshot_v1(m.id,uid,flow_state,uf_processing,uf_review);
  END IF;
  IF m.id='b70b23cf-bad8-475d-a56a-d9c549e35d84'::uuid
    AND role_diag IS NOT NULL THEN
    role_diag:=role_diag||jsonb_build_object('flow_reason','review_required',
      'next_actor','staff','flow_detail',null);
  END IF;
END IF;
  -- C1266: new finite source opt-in, proved from server start/admission, not a client state heuristic.
  IF staff AND participant AND p_location='0b85f354-9cdb-47e1-baf9-3d266bb7e06b'::uuid THEN
   c26_proof:=CASE WHEN EXISTS(SELECT 1 FROM mission_generic_owner.manual_staff_admissions_v1 ma WHERE ma.master_session_id=m.id) THEN mission_generic_owner.manual_staff_scope_v1(m.id) ELSE mission_generic_owner.c1266_clean_staff_admission_v1(m.id,true,false) END;
  END IF;
  IF c26_proof IS NOT NULL THEN
   c26_revision:=mission_generic_owner.role_source_revision_v1(m.id);
   SELECT st.kind INTO c26_phase_kind FROM public.mission_plan_steps st
    WHERE st.plan_version_id=r.plan_version_id AND st.step_key=coalesce(private_source_step,r.current_step_key);
   c26_kind:='none';
   IF EXISTS(SELECT 1 FROM mission_generic_owner.manual_staff_admissions_v1 ma WHERE ma.master_session_id=m.id) AND role_diag IS NULL THEN c26_revision:=NULL;END IF;
   -- Native is the currently bound mechanical FSM with a published native entry/window.
   -- No work is required: this includes gathering PG declarations/defenses after a Fato.
   IF NOT private_pending AND EXISTS(
    SELECT 1 FROM mission_generic_owner.encounters ee
    JOIN public.combat_v2_sessions cs ON cs.id=ee.encounter_id AND cs.master_session_id=m.id
    JOIN public.mission_plan_steps ps ON ps.plan_version_id=r.plan_version_id AND ps.step_key=ee.step_key AND ps.kind='mechanical'
    JOIN public.combat_v2_rounds cr ON cr.session_id=cs.id
    JOIN mission_generic_owner.unified_round_windows rw ON rw.round_id=cr.id AND rw.master_session_id=m.id
    JOIN mission_generic_owner.unified_batches ub ON ub.id=rw.batch_id AND ub.master_session_id=m.id
    JOIN public.messages pubmsg ON pubmsg.id=rw.publication_id AND pubmsg.id=ub.message_id
     AND pubmsg.kind='fato' AND pubmsg.recipient_user IS NULL AND pubmsg.location_id=p_location
    WHERE ee.master_session_id=m.id AND ee.step_key=r.current_step_key AND ee.run_control_version=r.control_version
     AND cs.closed_at IS NULL AND cs.state NOT IN('chiuso','annullato') AND ub.state='published') THEN
    -- Native progress does not capture narrative role submissions. Reuse the canonical
    -- read-only snapshot only after this sealed scene and published mechanical FSM proof.
    IF role_diag IS NULL AND EXISTS(SELECT 1 FROM mission_generic_owner.manual_staff_admissions_v1 ma WHERE ma.master_session_id=m.id) THEN
     role_diag:=mission_generic_owner.role_status_snapshot_v1(m.id,uid,flow_state,uf_processing,uf_review);
     IF mission_factory_owner.keys_exact_v2(role_diag,ARRAY['flow_reason','next_actor','roles_received','roles_required','source_revision','flow_detail'])
      AND jsonb_typeof(role_diag->'flow_reason')='string' AND role_diag->>'flow_reason'='published'
      AND jsonb_typeof(role_diag->'next_actor')='string' AND role_diag->>'next_actor'='none'
      AND jsonb_typeof(role_diag->'roles_received')='number' AND role_diag->>'roles_received' ~ '^[0-4]$'
      AND jsonb_typeof(role_diag->'roles_required')='number' AND role_diag->>'roles_required' ~ '^[1-4]$'
      AND (role_diag->>'roles_received')::integer<=(role_diag->>'roles_required')::integer
      AND jsonb_typeof(role_diag->'source_revision')='string' AND role_diag->>'source_revision' ~ '^[0-9a-f]{64}$'
      AND role_diag->'flow_detail'='null'::jsonb THEN
      c26_revision:=role_diag->>'source_revision';c26_kind:='native';
     ELSE
      -- No partial role/driver contract and no generic tick when the snapshot is invalid.
      role_diag:=NULL;c26_revision:=NULL;c26_kind:='none';uf_review:=true;
     END IF;
    ELSE c26_kind:='native';END IF;
   ELSIF c26_phase_kind='narrative' AND active
    AND c26_revision ~ '^[0-9a-f]{64}$'
    AND role_diag->>'source_revision'=c26_revision
    AND (mission_public_owner.role_capture_scope_v1(m.id) OR mb_read_recovery) THEN
    -- Includes legitimate ready_to_evaluate with no work: kind follows the narrative FSM, not absence of a job.
    c26_kind:='tick';
   END IF;
   -- A qualified manual scene without a role cursor keeps the existing
   -- read-only fallback revision. This does not grant a tick or create a cursor.
   IF c26_kind='none' AND c26_revision IS NULL
    AND EXISTS(SELECT 1 FROM mission_generic_owner.manual_staff_admissions_v1 ma WHERE ma.master_session_id=m.id)
    AND role_diag->>'source_revision' ~ '^[0-9a-f]{64}$' THEN
    c26_revision:=role_diag->>'source_revision';
   END IF;
  END IF;
 -- C1264 AGG2: read-only receipt summary, confined to the existing protected scene.
 IF (m.id='ce7bc0e0-c8ed-48dd-a9ec-58c02022a7b9'::uuid OR (c26_proof IS NOT NULL AND c26_kind='tick'))
  AND p_location='0b85f354-9cdb-47e1-baf9-3d266bb7e06b'::uuid AND staff AND participant
  AND (EXISTS(SELECT 1 FROM mission_generic_owner.manual_staff_admissions_v1 ma WHERE ma.master_session_id=m.id) OR uid IN('f0856d53-83a6-4de0-bc0c-12c87916e665'::uuid,'b4952ed5-5ce0-49c0-9f2b-8fd5dcd89b4b'::uuid))
  AND (EXISTS(SELECT 1 FROM mission_generic_owner.flow_staff_sessions f WHERE f.master_session_id=m.id AND f.enabled) OR (m.id='44078c5f-7001-4129-9506-e2f34e68c8ac'::uuid AND mission_generic_owner.manual_staff_count_limit_v1(m.id)='none'
 AND EXISTS(SELECT 1 FROM mission_generic_owner.staff_progress_ticks_v1 bt JOIN mission_generic_owner.progress_receipts bp ON bp.request_key=bt.request_key AND bp.master_session_id=bt.master_session_id AND bp.actor_user_id=bt.actor_user_id AND bp.result_sha256=bt.result_sha256 AND bp.result_sha256=public.combat_v2_sha256(bp.result)
 WHERE bt.master_session_id=m.id AND bt.request_key='9e48a416-9261-4399-9e4e-a82b8a3d3a48'::uuid AND bt.source_revision='24db5db8da7ede254e6d719b587c4fa04dce6b9d1c920396251adb85d0f6294c' AND bt.actor_user_id='b4952ed5-5ce0-49c0-9f2b-8fd5dcd89b4b'::uuid AND bt.staff_user_id=bt.actor_user_id AND bt.result_sha256='b27ed0db18a45d371931f015be0cd0fa060ed3f99b8d5843e8cbef45ecfbb2f8'
 AND mission_factory_owner.keys_exact_v2(bp.result,ARRAY['schema_version','master_session_id','state','dispatch','reason_code']) AND bp.result->>'schema_version'='mission-generic-progress/1' AND bp.result->>'master_session_id'=m.id::text AND bp.result->>'state'='paused' AND bp.result->>'reason_code'='MGPG_C7_RUN_BUDGET_STOP' AND bp.result->'dispatch'='null'::jsonb)))
  AND EXISTS(SELECT 1 FROM public.locations l WHERE l.id=p_location AND l.is_test AND l.is_active)
  AND role_diag->>'source_revision' ~ '^[0-9a-f]{64}$'
  AND role_diag->>'source_revision'=mission_generic_owner.role_source_revision_v1(m.id) THEN
  st_revision:=role_diag->>'source_revision';st_state:='absent';
  SELECT * INTO st_tick FROM mission_generic_owner.staff_progress_ticks_v1 t
    WHERE t.master_session_id=m.id AND t.source_revision=st_revision;
  IF FOUND THEN
   st_original_key:=st_tick.request_key;st_owner:=coalesce(st_tick.actor_user_id=uid,false);st_state:='blocked';
   IF st_original_key IS NOT NULL AND st_tick.result_sha256 ~ '^[0-9a-f]{64}$'
    AND EXISTS(SELECT 1 FROM public.master_v2_participants mp JOIN public.characters ch ON ch.id=mp.character_id AND ch.user_id=mp.user_id_snapshot
      JOIN public.profiles tp ON tp.id=mp.user_id_snapshot AND tp.role IN('admin','master')
      WHERE mp.session_id=m.id AND mp.user_id_snapshot=st_tick.actor_user_id AND mp.left_at IS NULL)
    AND EXISTS(SELECT 1 FROM public.profiles sp WHERE sp.id=st_tick.staff_user_id AND sp.role IN('admin','master')) THEN
    SELECT * INTO st_receipt FROM mission_generic_owner.progress_receipts pr
     WHERE pr.request_key=st_original_key AND pr.master_session_id=m.id AND pr.actor_user_id=st_tick.actor_user_id
      AND pr.result_sha256=st_tick.result_sha256 AND pr.result_sha256=public.combat_v2_sha256(pr.result);
    st_valid:=FOUND;
    IF st_valid AND st_tick.request_key='9e48a416-9261-4399-9e4e-a82b8a3d3a48'::uuid AND st_revision='24db5db8da7ede254e6d719b587c4fa04dce6b9d1c920396251adb85d0f6294c' AND (m.id='44078c5f-7001-4129-9506-e2f34e68c8ac'::uuid AND mission_generic_owner.manual_staff_count_limit_v1(m.id)='none'
 AND EXISTS(SELECT 1 FROM mission_generic_owner.staff_progress_ticks_v1 bt JOIN mission_generic_owner.progress_receipts bp ON bp.request_key=bt.request_key AND bp.master_session_id=bt.master_session_id AND bp.actor_user_id=bt.actor_user_id AND bp.result_sha256=bt.result_sha256 AND bp.result_sha256=public.combat_v2_sha256(bp.result)
 WHERE bt.master_session_id=m.id AND bt.request_key='9e48a416-9261-4399-9e4e-a82b8a3d3a48'::uuid AND bt.source_revision='24db5db8da7ede254e6d719b587c4fa04dce6b9d1c920396251adb85d0f6294c' AND bt.actor_user_id='b4952ed5-5ce0-49c0-9f2b-8fd5dcd89b4b'::uuid AND bt.staff_user_id=bt.actor_user_id AND bt.result_sha256='b27ed0db18a45d371931f015be0cd0fa060ed3f99b8d5843e8cbef45ecfbb2f8'
 AND mission_factory_owner.keys_exact_v2(bp.result,ARRAY['schema_version','master_session_id','state','dispatch','reason_code']) AND bp.result->>'schema_version'='mission-generic-progress/1' AND bp.result->>'master_session_id'=m.id::text AND bp.result->>'state'='paused' AND bp.result->>'reason_code'='MGPG_C7_RUN_BUDGET_STOP' AND bp.result->'dispatch'='null'::jsonb)) THEN
     mb_mode:=true;nw_mode:=true;nw_original_sha:=st_receipt.result_sha256;nw_original_key:=st_tick.request_key;st_recovery:=nw_original_key;st_next_key:=mission_ai_service_owner.uuid5(st_tick.request_key,'mission-staff-budget-only-resume/1:'||st_revision);
     IF EXISTS(SELECT 1 FROM mission_generic_owner.progress_receipts nr WHERE nr.request_key=st_next_key) THEN
      SELECT * INTO st_receipt FROM mission_generic_owner.progress_receipts nr WHERE nr.request_key=st_next_key AND nr.master_session_id=m.id AND nr.actor_user_id=st_tick.actor_user_id AND nr.result_sha256=public.combat_v2_sha256(nr.result);
      st_valid:=FOUND;IF NOT st_valid THEN st_blocked:=true;END IF;
     ELSE st_state:='no_work_released';st_valid:=false;END IF;
    END IF;
    IF st_valid AND NOT mb_mode AND (mission_factory_owner.keys_exact_v2(st_receipt.result,ARRAY['schema_version','master_session_id','state','dispatch'])
 AND st_receipt.result->>'schema_version'='mission-generic-progress/1' AND st_receipt.result->>'master_session_id'=m.id::text
 AND st_receipt.result->>'state'='needs_attention' AND st_receipt.result->'dispatch'='null'::jsonb
 AND EXISTS(SELECT 1 FROM mission_generic_owner.work_items healed 
 WHERE healed.master_session_id=m.id AND healed.created_at<st_tick.created_at AND (healed.kind='director' AND healed.state='failed' AND healed.result->>'ok'='true'
 AND healed.payload_sha256=public.combat_v2_sha256(healed.payload)
 AND EXISTS(SELECT 1 FROM mission_narrative_internal.dispatch_receipts healed_dr
  JOIN mission_narrative_internal.dispatch_audit healed_a ON healed_a.receipt_id=healed_dr.id AND healed_a.event_code='c1266_saved_director_applied'
  JOIN mission_narrative_internal.dispatch_audit healed_f ON healed_f.receipt_id=healed_dr.id AND healed_f.event_code='generic_finalized'
  JOIN mission_generic_owner.unified_batches healed_b ON healed_b.decision_work_id=healed.id AND healed_b.master_session_id=m.id
  JOIN mission_generic_owner.unified_source_windows healed_s ON healed_s.id=healed_b.source_window_id AND healed_s.work_id=healed.id AND healed_s.master_session_id=m.id
  JOIN mission_generic_owner.work_items healed_writer ON healed_writer.id=healed_b.writer_work_id AND healed_writer.master_session_id=m.id AND healed_writer.authority_receipt_id=healed_b.id
  JOIN public.messages healed_msg ON healed_msg.id=healed_writer.message_id AND healed_msg.kind='fato' AND healed_msg.recipient_user IS NULL AND healed_msg.body=healed_writer.result->>'text'
  WHERE healed_dr.id=healed.dispatch_receipt_id AND healed_dr.master_session_id=m.id AND healed_dr.authority_receipt_id=healed.id AND healed_dr.request_key=healed.request_key
   AND healed_dr.status='success' AND healed_dr.dispatch_count=1 AND healed_dr.finalized_at IS NOT NULL
   AND healed_a.details->>'schema_version'='c1266-saved-director-application/1' AND healed_a.details->>'master_session_id'=m.id::text
   AND healed_a.details->>'work_id'=healed.id::text AND healed_a.details->>'result_sha256'=healed.result_sha256
   AND healed_a.details->>'batch_id'=healed_b.id::text AND healed_a.details->>'writer_work_id'=healed_writer.id::text
   AND healed_a.details->>'generation_http_calls'='0' AND healed_a.details->>'failed_work_preserved'='true'
   AND healed_f.details->>'work_id'=healed.id::text AND healed_f.details->>'receipt_id'=healed.receipt_id::text
   AND healed_f.details->>'result_sha256'=healed.result_sha256 AND healed_f.details->>'result_jsonb_sha256'=public.combat_v2_sha256(healed.result)
   AND healed_b.state='published' AND healed_b.published_at IS NOT NULL AND healed_b.message_id=healed_writer.message_id
   AND healed_s.consumed_message_id=healed_b.message_id AND healed_s.superseded_at IS NULL
   AND healed_s.source_sha256=healed.payload_sha256 AND healed_writer.kind='narration' AND healed_writer.state='completed'
   AND healed_writer.payload=healed_b.payload AND healed_writer.payload_sha256=healed_b.payload_sha256
   AND healed_writer.payload_sha256=public.combat_v2_sha256(healed_writer.payload)
   AND EXISTS(SELECT 1 FROM mission_generic_owner.unified_segment_publications_v4 healed_pub WHERE healed_pub.work_id=healed_writer.id AND healed_pub.message_id=healed_msg.id)
   AND EXISTS(SELECT 1 FROM staff_ai_quota_private.calls healed_q WHERE healed_q.producer='mission_generic_ai' AND healed_q.scope_id=m.id AND healed_q.source_id=healed_dr.id AND healed_q.call_no=1 AND healed_q.state='settled' AND healed_q.charged_usd=healed_dr.charged_cost_usd))))) THEN
     nw_mode:=true;nw_original_sha:=st_receipt.result_sha256;nw_original_key:=st_tick.request_key;
     st_next_key:=mission_ai_service_owner.uuid5(st_tick.request_key,'mission-staff-no-dispatch-resume/1:'||st_revision);st_recovery:=nw_original_key;
     IF m.id='44078c5f-7001-4129-9506-e2f34e68c8ac'::uuid AND st_revision='ac9aedbd59dcb835d717f4ddb6ce195e3c2a9d640df576667290fa38b7e6cbbb' AND mission_generic_owner.role_source_released_v4('433ace05-5265-4aad-96a3-5567b6e3480a'::uuid)
      AND EXISTS(SELECT 1 FROM mission_generic_owner.progress_receipts rr WHERE rr.request_key=mission_ai_service_owner.uuid5('310493d3-92d2-4645-ba85-ab42f57dbf9d'::uuid,'mission-staff-unpublished-reinterpretation/1:ac9aedbd59dcb835d717f4ddb6ce195e3c2a9d640df576667290fa38b7e6cbbb') AND rr.master_session_id=m.id AND rr.actor_user_id=st_tick.actor_user_id AND rr.result_sha256=public.combat_v2_sha256(rr.result)) THEN st_next_key:=mission_ai_service_owner.uuid5('310493d3-92d2-4645-ba85-ab42f57dbf9d'::uuid,'mission-staff-unpublished-reinterpretation/1:ac9aedbd59dcb835d717f4ddb6ce195e3c2a9d640df576667290fa38b7e6cbbb');END IF;
     IF EXISTS(SELECT 1 FROM mission_generic_owner.progress_receipts nr WHERE nr.request_key=st_next_key) THEN
      SELECT * INTO st_receipt FROM mission_generic_owner.progress_receipts nr WHERE nr.request_key=st_next_key AND nr.master_session_id=m.id AND nr.actor_user_id=st_tick.actor_user_id AND nr.result_sha256=public.combat_v2_sha256(nr.result);
      st_valid:=FOUND;IF NOT st_valid THEN st_blocked:=true;END IF;
     ELSE st_state:='no_work_released';st_valid:=false;
     END IF;
    END IF;
    WHILE st_valid LOOP
     st_dispatch:=st_receipt.result->'dispatch';
     IF st_receipt.result->>'schema_version' IS DISTINCT FROM 'mission-generic-progress/1'
      OR jsonb_typeof(st_dispatch) IS DISTINCT FROM 'object'
      OR NOT(st_dispatch ?& ARRAY['schema_version','master_session_id','event_id','request_key','expected_revision'])
      OR st_dispatch-'schema_version'-'master_session_id'-'event_id'-'request_key'-'expected_revision'<>'{}'::jsonb
      OR st_dispatch->>'schema_version' IS DISTINCT FROM 'mission-generic-request/1'
      OR st_dispatch->>'master_session_id' IS DISTINCT FROM m.id::text
      OR (st_dispatch->>'event_id' ~ '^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$') IS DISTINCT FROM TRUE
      OR (st_dispatch->>'request_key' ~ '^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$') IS DISTINCT FROM TRUE
      OR jsonb_typeof(st_dispatch->'expected_revision') IS DISTINCT FROM 'number'
      OR (st_dispatch->>'expected_revision' ~ '^[1-9][0-9]*$') IS DISTINCT FROM TRUE THEN st_blocked:=true;EXIT;END IF;
     IF (st_dispatch->>'expected_revision')::numeric>9223372036854775807 THEN st_blocked:=true;EXIT;END IF;
     SELECT w.id,w.master_session_id,w.event_id,w.request_key,w.revision,w.kind,w.state,w.authority_receipt_id,w.finalized_at,w.created_at,w.lease_expires_at,w.step_key,w.run_control_version,w.definition_sha256 INTO st_work
      FROM mission_generic_owner.work_items w WHERE w.event_id=(st_dispatch->>'event_id')::uuid
       AND w.master_session_id=m.id AND w.request_key=(st_dispatch->>'request_key')::uuid AND w.revision=(st_dispatch->>'expected_revision')::bigint;
     IF NOT FOUND THEN st_blocked:=true;EXIT;END IF;
     -- ACK belongs only to this effective validated successor, never to a computed next key.
     st_ack_predecessor:=st_candidate_predecessor;
     st_effective_id:=st_work.id;st_public_state:=CASE WHEN st_work.state IN('claimed','authorized','provider_started') AND st_work.lease_expires_at<=statement_timestamp() THEN 'uncertain' ELSE st_work.state END;
     st_state:='attested';st_released:=false;st_next_key:=NULL;st_recovery:=NULL;
     IF st_work.kind='director' AND st_work.id=(st_dispatch->>'event_id')::uuid AND st_work.state='failed' AND st_work.finalized_at IS NOT NULL THEN
      SELECT sw.id,sw.master_session_id,sw.work_id,sw.superseded_reason,sw.consumed_message_id,sw.context->>'source_revision' AS source_revision,sw.step_key,sw.run_control_version,sw.definition_sha256 INTO st_source
       FROM mission_generic_owner.unified_source_windows sw WHERE sw.id=st_work.authority_receipt_id AND sw.work_id=st_work.id AND sw.master_session_id=m.id;
      IF FOUND AND st_source.source_revision=st_revision AND (st_source.superseded_reason IN('staff_failed_director_validation_retry','staff_failed_director_count_overflow_retry') OR (st_source.id IN('d460a7be-a3a2-4ad8-9d3b-d2e929f2947e'::uuid,'f4f7185e-4aae-4edd-ac24-65f8dcfa36f5'::uuid) AND st_source.master_session_id='44078c5f-7001-4129-9506-e2f34e68c8ac'::uuid AND st_source.superseded_reason='staff_preprovider_request_retry'))
       AND st_source.consumed_message_id IS NULL AND mission_generic_owner.role_source_released_v4(st_source.id) THEN
       st_released:=true;st_state:='released';st_recovery:=st_work.id;
       IF st_source.superseded_reason='staff_failed_director_count_overflow_retry' THEN st_next_key:=mission_ai_service_owner.uuid5(st_work.id,'mission-staff-count-overflow-retry/1:'||st_revision);
       ELSIF st_depth=0 THEN st_next_key:=mission_ai_service_owner.uuid5(st_work.id,'mission-staff-released-director-retry/1:'||st_revision);
       ELSIF st_depth=1 THEN st_next_key:=mission_ai_service_owner.uuid5(st_work.id,'mission-staff-db-context-retry/2:'||st_revision);END IF;
      END IF;
     END IF;
     IF st_next_key IS NULL THEN EXIT;END IF;
     SELECT * INTO st_receipt FROM mission_generic_owner.progress_receipts pr WHERE pr.request_key=st_next_key;
     IF NOT FOUND THEN EXIT;END IF;
     IF st_receipt.master_session_id IS DISTINCT FROM m.id OR st_receipt.actor_user_id IS DISTINCT FROM st_tick.actor_user_id
      OR st_receipt.result_sha256 IS DISTINCT FROM public.combat_v2_sha256(st_receipt.result) THEN st_blocked:=true;EXIT;END IF;
     st_candidate_predecessor:=st_work.id;
     st_depth:=st_depth+1;
    END LOOP;
    IF st_blocked OR (NOT st_valid AND st_state<>'no_work_released') THEN st_state:='blocked';st_effective_id:=NULL;st_public_state:=NULL;st_next_key:=NULL;st_recovery:=NULL;st_released:=false;st_ack_predecessor:=NULL;END IF;
   END IF;
  END IF;
  -- Own admission plus the same runtime gates: closure never disables the receipt read itself.
  IF st_state='released' THEN
  IF st_owner AND st_next_key IS NOT NULL AND active AND NOT uf_review
   AND m.stato='in_corso' AND r.run_phase='in_corso' AND role_diag->>'flow_reason'='ready_to_evaluate'
   AND st_work.step_key=r.current_step_key AND st_source.step_key=r.current_step_key
   AND st_work.run_control_version=r.control_version AND st_source.run_control_version=r.control_version
   AND st_work.definition_sha256=st_source.definition_sha256
   AND mission_generic_owner.c726_factory_staff_runtime_v1(m.id) IS TRUE
   AND mission_generic_owner.flow_scope_enabled(m.id) IS TRUE
   AND EXISTS(SELECT 1 FROM mission_factory_owner.provider_authoring_admissions fa
     JOIN mission_factory_owner.editor_release_readiness rr ON rr.singleton
     WHERE fa.actor_user=uid AND fa.location_id=m.location_id AND fa.enabled
      AND ((EXISTS(SELECT 1 FROM mission_generic_owner.manual_staff_admissions_v1 ma WHERE ma.master_session_id=m.id AND m.id='44078c5f-7001-4129-9506-e2f34e68c8ac'::uuid AND st_source.id IN('d460a7be-a3a2-4ad8-9d3b-d2e929f2947e'::uuid,'f4f7185e-4aae-4edd-ac24-65f8dcfa36f5'::uuid) AND st_source.superseded_reason='staff_preprovider_request_retry' AND mission_generic_owner.c1266_execution_authority_v1(m.id,false,true)#>>'{admission,schema_version}'='c1266-staff-admission-authority/3' AND mission_generic_owner.c1266_execution_authority_v1(m.id,false,true)->>'release_sha256'=rr.revision_sha256 AND mission_generic_owner.c1266_execution_authority_v1(m.id,false,true)->>'binding_sha256'=st_work.definition_sha256) OR mission_generic_owner.manual_staff_template_policy_v1(m.id) IS NOT NULL OR fa.expires_at>statement_timestamp() OR (mission_generic_owner.c1266_staff_source_scope_v1(m.id) IS NOT NULL AND mission_generic_owner.c1266_staff_source_scope_v1(m.id)#>>'{campaign_snapshot,time_policy,mode}'='budget_or_explicit_stop')) OR ((rr.canonical_preimage::jsonb#>'{config,c1266_staff_campaign}'='{"maxGen":17,"maxUSD":"0.4216","maxHTTP":34,"grant_id":"b925043a-c1b3-434b-8fb4-f335903b2af0","maxCount":17,"residual":{"gen":17,"usd":"0.4395760","http":34,"count":17},"max_pairs":17,"expires_at":"2026-10-20T15:12:18.393948+00:00","not_before":"2026-10-20T14:12:18.393948+00:00","campaign_id":"b2fc5e28-072b-41f2-8dd8-cb5a35a13092","location_id":"0b85f354-9cdb-47e1-baf9-3d266bb7e06b","work_seconds":360,"schema_version":"c1266-staff-campaign/2","cleanup_seconds":360,"history_baseline":{"gen":33,"usd":"0.5524240","http":69,"count":36},"history_scope_ids":["0b1fa6b5-d9c4-4ea3-9ec8-76b1b21e0a0a","21fb8bf3-1df9-4bbf-b2d6-cf7b003b8f30","a853d33f-eecf-484b-b85c-5dc12c25d080","d25d886e-e4f8-4cfe-b8f2-729e96f355d7","c21baa1a-cdac-4401-9131-493eef208a21","780bc131-229e-4142-b1f9-4c6a39b6d070","ef12969b-0958-473c-9016-53052af9d579","2067ace7-c975-4e6c-a621-f82ac23ed18d","6c8d9647-b0de-4c2c-a7e0-6c4a6239ee86","41ec7f9e-9c2c-4476-be14-3ba57a573bc5","8b814fa7-fcdb-4035-9ddb-5bea247aeb36"],"time_policy":{"mode":"budget_or_explicit_stop","expires_at_role":"historical_provenance"}}'::jsonb AND rr.canonical_preimage::jsonb#>'{config,c1266_clean_staff}'='{"grant_id":"b925043a-c1b3-434b-8fb4-f335903b2af0","expires_at":"2026-10-20T15:12:18.393948+00:00","not_before":"2026-10-20T14:12:18.393948+00:00","location_id":"0b85f354-9cdb-47e1-baf9-3d266bb7e06b","source_sha256":"eca0639f48346ed0c1fac786c136f557920b61310c38d85f22a5e6a7837231bd","schema_version":"c1266-clean-staff-admission-policy/2","source_mission_id":"5878822d-dc03-4ac2-ad0b-1547f0ab3fc0","source_plan_version_id":"24b1e44a-5597-4fb0-95bd-fb13647764b2","c7_budget_qualification":{"model":"gpt-6-luna","store":false,"http_limit":28,"schema_version":"c1266-clean-staff-budget-qualification/1","generation_limit":14,"reasoning_effort":"high","input_usd_million":0.1,"input_tokens_limit":24000,"output_usd_million":0.5,"output_tokens_limit":20000,"count_upper_cost_usd":"0.0124","scene_cost_budget_usd":"0.3136","generation_upper_cost_usd":"0.0124","count_qualification_sha256":"d8da6486b29f5e6b57272eb9d21660518cdcb57f12ed69209e12f32c37e2d5c0","count_reserve_contract_sha256":"13421de48d6dddbb8c6628fd6a294b90746b3d2b79e56bf617456a5d3cc8e090"},"c7_budget_qualification_sha256":"39af421ce9035831c695f0c8d8bc8157cdfd09918b8b81072433e9031b248959","campaign_id":"b2fc5e28-072b-41f2-8dd8-cb5a35a13092","time_policy":{"mode":"budget_or_explicit_stop","expires_at_role":"historical_provenance"}}'::jsonb) AND fa.expires_at=(rr.canonical_preimage::jsonb#>>'{config,c1266_staff_campaign,expires_at}')::timestamptz AND ((mission_factory_owner.keys_exact_v2(mission_generic_owner.c1266_execution_authority_v1(m.id,false,true)->'admission',ARRAY['schema_version','kind','resource_scope','finite_admission_sha256','grant_id','not_before','expires_at','location_id','campaign_id','time_policy']) AND mission_generic_owner.c1266_execution_authority_v1(m.id,false,true)->'admission'->>'schema_version'='c1266-staff-admission-authority/2' AND mission_generic_owner.c1266_execution_authority_v1(m.id,false,true)->'admission'->>'kind'='staff_finite' AND mission_generic_owner.c1266_execution_authority_v1(m.id,false,true)->'admission'->>'resource_scope'='staff_simulation' AND mission_generic_owner.c1266_execution_authority_v1(m.id,false,true)->'admission'->>'campaign_id'='b2fc5e28-072b-41f2-8dd8-cb5a35a13092' AND mission_generic_owner.c1266_execution_authority_v1(m.id,false,true)->'admission'->>'grant_id'='b925043a-c1b3-434b-8fb4-f335903b2af0' AND mission_generic_owner.c1266_execution_authority_v1(m.id,false,true)->'admission'->>'not_before'='2026-10-20T14:12:18.393948+00:00' AND mission_generic_owner.c1266_execution_authority_v1(m.id,false,true)->'admission'->>'expires_at'='2026-10-20T15:12:18.393948+00:00' AND mission_generic_owner.c1266_execution_authority_v1(m.id,false,true)->'admission'->>'location_id'='0b85f354-9cdb-47e1-baf9-3d266bb7e06b' AND mission_generic_owner.c1266_execution_authority_v1(m.id,false,true)->'admission'->'time_policy'='{"mode":"budget_or_explicit_stop","expires_at_role":"historical_provenance"}'::jsonb AND (mission_generic_owner.c1266_execution_authority_v1(m.id,false,true)->'admission'->>'finite_admission_sha256' ~ '^[a-f0-9]{64}$') IS TRUE) IS TRUE))) AND fa.release_sha256=rr.revision_sha256)
   AND mission_staff_abort_private.quiescent_v1(m.id) IS TRUE
   AND NOT EXISTS(SELECT 1 FROM mission_generic_owner.work_items newer WHERE newer.master_session_id=m.id AND newer.created_at>st_work.created_at)
   AND NOT EXISTS(SELECT 1 FROM mission_generic_owner.work_items w WHERE w.master_session_id=m.id AND w.state IN('ready','claimed','authorized','provider_started','uncertain'))
   AND NOT EXISTS(SELECT 1 FROM mission_generic_owner.unified_source_windows sw WHERE sw.master_session_id=m.id AND sw.consumed_message_id IS NULL AND sw.superseded_at IS NULL)
   AND NOT EXISTS(SELECT 1 FROM public.combat_v2_sessions cs WHERE cs.master_session_id=m.id AND cs.closed_at IS NULL)
   AND NOT EXISTS(SELECT 1 FROM jsonb_array_elements(mission_generic_owner.run_plan_settings(m.id)->'terminal_steps') term WHERE term->>'step_key'=r.current_step_key) THEN
   -- Read-only Native C7 arithmetic; never invoke a service-only reserve/consume helper from this reader.
   SELECT * INTO STRICT st_budget_a FROM mission_generic_owner.dispatch_admissions WHERE master_session_id=m.id;
   SELECT * INTO STRICT st_budget_g FROM mission_generic_owner.provider_policy WHERE singleton;
   SELECT pol.max_input_tokens,pol.max_output_tokens,pol.input_usd_million,pol.output_usd_million,pol.run_budget_usd INTO STRICT st_budget_p FROM mission_narrative_internal.runtime_policy pol WHERE singleton;
   st_bound:=(st_budget_p.max_input_tokens*st_budget_p.input_usd_million+st_budget_p.max_output_tokens*st_budget_p.output_usd_million)/1000000;
   budget1_effective:=mission_generic_owner.effective_admission_usd_cap_v1(m.id);
 budget1_policy:=CASE WHEN m.id='44078c5f-7001-4129-9506-e2f34e68c8ac'::uuid AND st_budget_a.cost_budget_usd=0.3136::numeric AND budget1_effective=1.00::numeric THEN greatest(st_budget_g.run_budget_usd,budget1_effective) ELSE st_budget_g.run_budget_usd END;
 st_cap_cost:=least(budget1_policy,budget1_effective,coalesce(st_budget_p.run_budget_usd,budget1_policy));
   st_cap_http:=2*least(st_budget_g.max_run_calls,st_budget_a.call_limit);
   SELECT coalesce(sum(CASE WHEN d.status IN('success','fallback','unknown_billable') THEN coalesce(d.charged_cost_usd,d.upper_bound_cost_usd,0)
    WHEN wi.state IN('claimed','authorized','provider_started') THEN greatest(coalesce(d.upper_bound_cost_usd,0),st_bound) ELSE coalesce(d.upper_bound_cost_usd,0) END
    + CASE WHEN ca.details IS NOT NULL THEN (ca.details->>'count_upper_cost_usd')::numeric WHEN wi.state IN('claimed','authorized','provider_started') THEN coalesce(st_budget_a.c8_count_upper_cost_usd,0) ELSE 0 END),0),
    coalesce(sum(CASE WHEN wi.state IN('claimed','authorized','provider_started') THEN 2 ELSE (CASE WHEN ca.details IS NOT NULL THEN 1 ELSE 0 END)+(CASE WHEN d.upper_bound_cost_usd IS NOT NULL OR EXISTS(SELECT 1 FROM mission_narrative_internal.dispatch_attempts da WHERE da.receipt_id=d.id) THEN 1 ELSE 0 END) END),0)
   INTO st_spent,st_http FROM mission_generic_owner.work_items wi LEFT JOIN mission_narrative_internal.dispatch_receipts d ON d.id=wi.dispatch_receipt_id
    LEFT JOIN mission_narrative_internal.dispatch_audit ca ON ca.receipt_id=d.id AND ca.event_code='c8_count_started'
    WHERE wi.master_session_id=m.id AND (wi.dispatch_receipt_id IS NOT NULL OR wi.state IN('claimed','authorized','provider_started'));
   st_http:=greatest(st_http,st_budget_a.calls_authorized);
   st_budget_ok:=st_budget_a.enabled AND st_budget_g.enabled AND st_budget_a.c7_budget_enforced
    AND st_budget_a.c7_budget_qualification_sha256 IS NOT NULL AND st_budget_a.c8_count_qualification_sha256 IS NOT NULL
    AND st_budget_a.c8_count_upper_cost_usd IS NOT NULL AND st_bound>=0 AND st_bound<'Infinity'::numeric AND st_cap_cost>0 AND (mission_generic_owner.manual_staff_count_limit_v1(m.id)='none' OR st_cap_http>0)
    AND (mission_generic_owner.c1266_staff_scene_policy_v1(m.id) IS NOT NULL OR (st_spent+st_bound+st_budget_a.c8_count_upper_cost_usd<=st_cap_cost AND (mission_generic_owner.manual_staff_count_limit_v1(m.id)='none' OR st_http+2<=st_cap_http)));
   st_resume:=st_budget_ok IS TRUE;
  END IF;
  END IF;
  IF nw_mode AND st_state='no_work_released' THEN
   st_resume:=st_owner AND active AND NOT uf_review AND m.stato='in_corso' AND r.run_phase='in_corso'
    AND role_diag->>'flow_reason'='ready_to_evaluate' AND mission_generic_owner.flow_scope_enabled(m.id)
    AND EXISTS(SELECT 1 FROM mission_generic_owner.manual_staff_admissions_v1 ma WHERE ma.master_session_id=m.id)
    AND mission_generic_owner.c1266_execution_authority_v1(m.id,false,true)->>'runtime_authorized'='true'
    AND NOT EXISTS(SELECT 1 FROM mission_generic_owner.work_items aw WHERE aw.master_session_id=m.id AND aw.state IN('ready','claimed','authorized','provider_started','uncertain'))
    AND NOT EXISTS(SELECT 1 FROM mission_generic_owner.unified_source_windows aw WHERE aw.master_session_id=m.id AND aw.superseded_at IS NULL AND aw.consumed_message_id IS NULL)
    AND NOT EXISTS(SELECT 1 FROM public.combat_v2_sessions ac WHERE ac.master_session_id=m.id AND ac.closed_at IS NULL);
  END IF;
  IF mb_mode AND st_state='no_work_released' THEN
   SELECT * INTO STRICT st_budget_a FROM mission_generic_owner.dispatch_admissions WHERE master_session_id=m.id;
   SELECT * INTO STRICT st_budget_g FROM mission_generic_owner.provider_policy WHERE singleton;
   SELECT pol.max_input_tokens,pol.max_output_tokens,pol.input_usd_million,pol.output_usd_million,pol.run_budget_usd INTO STRICT st_budget_p FROM mission_narrative_internal.runtime_policy pol WHERE singleton;
   st_bound:=(24000*st_budget_p.input_usd_million+20000*st_budget_p.output_usd_million)/1000000;
   budget1_effective:=mission_generic_owner.effective_admission_usd_cap_v1(m.id);
 budget1_policy:=CASE WHEN m.id='44078c5f-7001-4129-9506-e2f34e68c8ac'::uuid AND st_budget_a.cost_budget_usd=0.3136::numeric AND budget1_effective=1.00::numeric THEN greatest(st_budget_g.run_budget_usd,budget1_effective) ELSE st_budget_g.run_budget_usd END;
 st_cap_cost:=least(budget1_policy,budget1_effective,coalesce(st_budget_p.run_budget_usd,budget1_policy));
   SELECT coalesce(sum(CASE WHEN d.status IN('success','fallback','unknown_billable') THEN coalesce(d.charged_cost_usd,d.upper_bound_cost_usd,0) ELSE coalesce(d.upper_bound_cost_usd,0) END+CASE WHEN ca.details IS NOT NULL THEN (ca.details->>'count_upper_cost_usd')::numeric ELSE 0 END),0),coalesce(sum((CASE WHEN ca.details IS NOT NULL THEN 1 ELSE 0 END)+(CASE WHEN d.upper_bound_cost_usd IS NOT NULL OR EXISTS(SELECT 1 FROM mission_narrative_internal.dispatch_attempts da WHERE da.receipt_id=d.id) THEN 1 ELSE 0 END)),0) INTO st_spent,st_http
   FROM mission_generic_owner.work_items wi LEFT JOIN mission_narrative_internal.dispatch_receipts d ON d.id=wi.dispatch_receipt_id LEFT JOIN mission_narrative_internal.dispatch_audit ca ON ca.receipt_id=d.id AND ca.event_code='c8_count_started' WHERE wi.master_session_id=m.id;
   st_resume:=st_owner AND active AND NOT uf_review AND m.stato='in_corso' AND r.run_phase='in_corso' AND st_budget_g.enabled AND role_diag->>'flow_reason'='ready_to_evaluate'
    AND st_budget_a.c7_budget_enforced AND st_budget_a.call_limit=14 AND st_budget_a.calls_authorized=0 AND st_http=28 AND st_budget_a.cost_budget_usd=0.3136
    AND st_spent+st_bound+st_budget_a.c8_count_upper_cost_usd<=st_cap_cost
    AND NOT EXISTS(SELECT 1 FROM mission_generic_owner.work_items aw WHERE aw.master_session_id=m.id AND aw.state IN('ready','claimed','authorized','provider_started','uncertain'))
    AND NOT EXISTS(SELECT 1 FROM mission_generic_owner.unified_source_windows aw WHERE aw.master_session_id=m.id AND aw.superseded_at IS NULL AND aw.consumed_message_id IS NULL)
    AND NOT EXISTS(SELECT 1 FROM public.combat_v2_sessions aw WHERE aw.master_session_id=m.id AND aw.closed_at IS NULL);
  END IF;
  staff_tick_view:=jsonb_build_object('schema_version','mission-generic-staff-tick-status/2','master_session_id',m.id,
   'source_revision',st_revision,'request_key',st_original_key,'owned_by_me',st_owner,'state',st_state,
   'work_id',st_effective_id,'work_state',st_public_state,'retry_request_key',st_next_key,
   'can_resume',st_resume,'recovery_key',st_recovery,
   'acknowledged_retry_from_work_id',st_ack_predecessor);
  IF nw_mode THEN
   staff_tick_view:=staff_tick_view||jsonb_build_object('schema_version','mission-generic-staff-tick-status/3','recovery_kind','no_work_progress_receipt','original_result_sha256',nw_original_sha,
    'recovery_key',nw_original_key,'retry_request_key',CASE WHEN mb_mode THEN mission_ai_service_owner.uuid5(st_tick.request_key,'mission-staff-budget-only-resume/1:'||st_revision) ELSE mission_ai_service_owner.uuid5(st_tick.request_key,'mission-staff-no-dispatch-resume/1:'||st_revision) END,'acknowledged_recovery_key',CASE WHEN st_state='attested' AND NOT st_blocked AND st_effective_id IS NOT NULL THEN nw_original_key ELSE NULL END,
    'can_resume',CASE WHEN st_state='no_work_released' THEN st_resume ELSE false END);
  END IF;

 END IF;


 IF NOT event42_mode AND staff AND participant AND p_location='0b85f354-9cdb-47e1-baf9-3d266bb7e06b'::uuid THEN
  journal_settlements:=mission_generic_owner.staff_journal_settlements_v1(m.id,uid);
 END IF;
 IF NOT event42_mode AND uf_work.id IS NOT NULL THEN opening_resume49:=mission_generic_owner.opening_ready_resume_proof_v1(uf_work.id,uid);END IF;
 IF NOT event42_mode AND uf_work.id IS NOT NULL THEN opening_claim_resume6:=mission_generic_owner.opening_claim_resume_proof_v1(uf_work.id,uid);END IF;
 IF NOT event42_mode AND uf_work.id IS NOT NULL THEN c26_count_view:=mission_generic_owner.c1266_count_reconciliation_v1(uf_work.id,uid,false);END IF;
 uf_progress_key:=public.combat_v2_sha256(jsonb_build_object('session_id',m.id,
  'master_version',m.control_version,'master_state',m.stato,'run_version',r.control_version,
  'run_phase',r.run_phase,'step_key',coalesce(private_source_step,r.current_step_key),'processing',uf_processing,
  'choice_context',vchoices,'mechanical_state',uf_rounds,'unified',uf_marker,
  'flow_state',flow_state,'flow_publication_id',flow_publication));
 IF role_diag IS NOT NULL THEN uf_progress_key:=public.combat_v2_sha256(jsonb_build_object('base',uf_progress_key,'source_revision',role_diag->>'source_revision')); END IF;
  IF c26_proof IS NOT NULL THEN
   c26_driver:=jsonb_build_object('schema_version','mission-driver-state/1','master_session_id',m.id,
    'source_revision',c26_revision,'kind',c26_kind,
    'tick_status',CASE WHEN c26_kind='tick' THEN staff_tick_view ELSE NULL END);
   uf_progress_key:=public.combat_v2_sha256(jsonb_build_object('base',uf_progress_key,'driver_state',c26_driver));
  END IF;
 IF c26_count_view IS NOT NULL THEN uf_progress_key:=public.combat_v2_sha256(jsonb_build_object('base',uf_progress_key,'count_reconciliation',c26_count_view));END IF;
 IF opening_resume49 IS NOT NULL THEN uf_progress_key:=public.combat_v2_sha256(jsonb_build_object('base',uf_progress_key,'opening_ready_resume',opening_resume49));END IF;
 IF opening_claim_resume6 IS NOT NULL THEN uf_progress_key:=public.combat_v2_sha256(jsonb_build_object('base',uf_progress_key,'opening_claim_resume',opening_claim_resume6));END IF;
 IF staff AND participant AND p_location='0b85f354-9cdb-47e1-baf9-3d266bb7e06b'::uuid THEN
  SELECT proof.x INTO combat_recovery FROM mission_generic_owner.work_items cw CROSS JOIN LATERAL(SELECT mission_generic_owner.combat_narration_reissue_proof_v1(cw.id,uid) x) proof
  WHERE cw.master_session_id=m.id AND cw.kind='narration' AND cw.state='failed' AND cw.payload->>'schema_version'='mission-generic-narration/3' AND proof.x IS NOT NULL AND proof.x->>'published'='false' ORDER BY cw.created_at DESC,cw.id DESC LIMIT 1;
  IF combat_recovery IS NOT NULL THEN combat_recovery:=jsonb_build_object('schema_version','mission-combat-narration-recovery/1','master_session_id',m.id,'failed_work_id',combat_recovery->'failed_work_id','batch_id',combat_recovery->'batch_id','report_id',combat_recovery->'report_id','payload_sha256',combat_recovery->'payload_sha256','owned_by_me',combat_recovery->'owned_by_me','can_reissue',combat_recovery->'can_reissue','successor_work_id',combat_recovery->'successor_work_id','successor_request',combat_recovery->'successor_request','can_resume',combat_recovery->'can_resume');END IF;
 END IF;
 -- Nonterminal paid-Director adoption handoff. It delegates only the exact
 -- failed parent observer to its existing canonical Writer; it attests no Fato.
 IF staff AND participant AND p_location='0b85f354-9cdb-47e1-baf9-3d266bb7e06b'::uuid
  AND EXISTS(SELECT 1 FROM public.master_v2_participants rhparticipant
   JOIN public.characters rhcharacter ON rhcharacter.id=rhparticipant.character_id AND rhcharacter.user_id=uid
   WHERE rhparticipant.session_id=m.id AND rhparticipant.user_id_snapshot=uid
    AND rhparticipant.left_at IS NULL AND rhparticipant.engagement_state='attivo') THEN
  WITH retained_candidates AS MATERIALIZED(
   SELECT rhparent.id,rhparent.definition_sha256 FROM mission_generic_owner.work_items rhparent
   WHERE rhparent.master_session_id=m.id AND rhparent.kind='director' AND rhparent.state='failed'
    AND rhparent.result->'failure_codes' ? 'MISSION_PROVIDER_OUTPUT_RETENTION_FAILED'
    AND EXISTS(SELECT 1 FROM mission_narrative_internal.dispatch_audit rhadoption
     WHERE rhadoption.receipt_id=rhparent.dispatch_receipt_id AND rhadoption.event_code='retained_director_adopted')
  ), retained_proofs AS MATERIALIZED(
   SELECT rhcandidate.id,rhcandidate.definition_sha256,mission_generic_owner.retained_director_adoption_v1(rhcandidate.id,false) proof
   FROM retained_candidates rhcandidate
  ), retained_bound AS MATERIALIZED(
   SELECT rhproof.proof,rhchild.id child_id,rhchild.state child_state,rhchild.finalized_at child_finalized,
    rhchild.receipt_id child_receipt,rhchild.message_id child_message,rhchild.result child_result,
    rhchild.lease_id child_lease,rhchild.authorization_id child_authorization,rhchild.dispatch_id child_dispatch,
    rhchild.dispatch_receipt_id child_dispatch_receipt,
    jsonb_build_object('schema_version','mission-generic-request/1','master_session_id',rhchild.master_session_id,
     'event_id',rhchild.event_id,'request_key',rhchild.request_key,'expected_revision',rhchild.revision) child_request
   FROM retained_proofs rhproof JOIN mission_generic_owner.work_items rhchild
    ON rhchild.id=(rhproof.proof#>>'{applied,child_work_id}')::uuid
   WHERE rhproof.proof->'published'='false'::jsonb AND rhproof.proof->'applied' IS DISTINCT FROM 'null'::jsonb
    AND rhchild.master_session_id=m.id AND rhchild.kind='narration'
    AND rhchild.run_control_version=r.control_version
    AND rhchild.definition_sha256=rhproof.definition_sha256
    AND rhchild.step_key=r.current_step_key
    AND rhproof.proof#>'{applied,child_request}'=jsonb_build_object('schema_version','mission-generic-request/1',
     'master_session_id',rhchild.master_session_id,'event_id',rhchild.event_id,'request_key',rhchild.request_key,'expected_revision',rhchild.revision)
  ) SELECT rhbound.*,count(*) OVER() match_count INTO retained_row FROM retained_bound rhbound LIMIT 1;
  IF FOUND AND retained_row.match_count=1 THEN
   retained_handoff:=jsonb_build_object('schema_version','mission-retained-director-handoff/1','master_session_id',m.id,
    'parent_work_id',(retained_row.proof->>'work_id')::uuid,'parent_request',retained_row.proof->'request',
    'child_work_id',retained_row.child_id,'child_request',retained_row.proof#>'{applied,child_request}',
    'adoption_sha256',public.combat_v2_sha256(retained_row.proof->'applied'),
    'owned_by_me',retained_row.proof->>'owner_user_id'=uid::text,
    'can_resume',coalesce(active AND NOT uf_review AND m.stato='in_corso' AND r.run_phase='in_corso'
     AND retained_row.proof->>'owner_user_id'=uid::text AND retained_row.child_state='ready'
     AND retained_row.child_finalized IS NULL AND retained_row.child_receipt IS NULL AND retained_row.child_message IS NULL
     AND retained_row.child_result IS NULL AND retained_row.child_lease IS NULL AND retained_row.child_authorization IS NULL
     AND retained_row.child_dispatch IS NULL AND retained_row.child_dispatch_receipt IS NULL
     AND NOT EXISTS(SELECT 1 FROM mission_generic_owner.work_items rhother
      WHERE rhother.master_session_id=m.id AND rhother.id<>retained_row.child_id
       AND rhother.state IN('ready','claimed','authorized','provider_started','uncertain')),false));
  END IF;
 END IF;
 IF staff AND m.location_id='0b85f354-9cdb-47e1-baf9-3d266bb7e06b'::uuid
  AND EXISTS(SELECT 1 FROM public.locations rp37_loc WHERE rp37_loc.id=m.location_id AND rp37_loc.is_test)
  AND EXISTS(SELECT 1 FROM mission_generic_owner.role_window_cursors rp37_cursor WHERE rp37_cursor.master_session_id=m.id)
 THEN
  SELECT coalesce(rr37.canonical_preimage::jsonb#>'{config,c1266_role_command_v2}'=
    jsonb_build_object('schema_version','mission-role-command-policy/1','enabled',true),false)
    INTO role_command_enabled FROM mission_factory_owner.editor_release_readiness rr37
    WHERE rr37.singleton AND rr37.state='enabled' AND rr37.scope='staff';
  SELECT jsonb_build_object('schema_version','mission-role-submit-capability/2','enabled',coalesce(role_command_enabled,false),
    'contexts',coalesce(jsonb_agg(jsonb_build_object('character_id',rp37_character.character_id,
      'window_epoch',rp37_cursor.window_epoch,'own_latest_message_id',rp37_latest.message_id)
      ORDER BY rp37_character.character_id),'[]'::jsonb)) INTO role_command_capability
   FROM (SELECT DISTINCT rp37_part.character_id FROM public.master_v2_participants rp37_part
      JOIN public.characters rp37_char ON rp37_char.id=rp37_part.character_id AND rp37_char.user_id=uid
      WHERE rp37_part.session_id=m.id AND rp37_part.user_id_snapshot=uid AND rp37_part.left_at IS NULL
        AND rp37_part.engagement_state='attivo') rp37_character
   JOIN mission_generic_owner.role_window_cursors rp37_cursor ON rp37_cursor.master_session_id=m.id
   LEFT JOIN LATERAL(SELECT rp37_own.message_id FROM mission_generic_owner.role_submissions rp37_own
     WHERE rp37_own.master_session_id=m.id AND rp37_own.window_epoch=rp37_cursor.window_epoch
       AND rp37_own.user_id=uid AND rp37_own.character_id=rp37_character.character_id
     ORDER BY rp37_own.accepted_at DESC,rp37_own.message_id DESC LIMIT 1) rp37_latest ON true;
 END IF;
 IF event42_mode THEN
 IF uf_processing IS NOT NULL THEN uf_processing:=jsonb_set(uf_processing,'{request}','null'::jsonb,false);END IF;
 END IF;
 return jsonb_build_object('session_id',m.id,'step_key',coalesce(private_source_step,r.current_step_key),'objective',objective,
 'server_event_mode',CASE WHEN event42_mode THEN 'server_event_v1' ELSE NULL END,
 'server_event_status',(SELECT jsonb_build_object('event_key',es.event_key,'event_version',es.event_version,'state',es.state,
 'can_recover',coalesce(es.root_principal=uid AND active AND (EXISTS(SELECT 1 FROM mission_generic_owner.work_items eh_done
 WHERE eh_done.id=es.work_id AND eh_done.master_session_id=es.master_session_id
 AND eh_done.state='completed' AND eh_done.result->'ok'='true'::jsonb
 AND eh_done.receipt_id IS NOT NULL AND eh_done.finalized_at IS NOT NULL
 AND es.canonical_request=jsonb_build_object('schema_version','mission-generic-request/1',
 'master_session_id',eh_done.master_session_id,'event_id',eh_done.event_id,
 'request_key',eh_done.request_key,'expected_revision',eh_done.revision)
 AND (eh_done.result_sha256=public.combat_v2_sha256(eh_done.result) OR EXISTS(
 SELECT 1 FROM mission_narrative_internal.dispatch_audit hp_finalized
 WHERE hp_finalized.receipt_id=eh_done.dispatch_receipt_id AND hp_finalized.event_code='generic_finalized'
 AND hp_finalized.details->>'work_id'=eh_done.id::text
 AND hp_finalized.details->>'receipt_id'=eh_done.receipt_id::text
 AND hp_finalized.details->>'state'=eh_done.state
 AND hp_finalized.details->'message_id' IS NOT DISTINCT FROM coalesce(to_jsonb(eh_done.message_id),'null'::jsonb)
 AND hp_finalized.details->>'result_sha256'=eh_done.result_sha256
 AND hp_finalized.details->>'result_jsonb_sha256'=public.combat_v2_sha256(eh_done.result)))) OR((es.state<>'running' OR es.claim_expires_at<=clock_timestamp())
 AND (es.work_id IS NULL OR EXISTS(SELECT 1 FROM mission_generic_owner.work_items ew WHERE ew.id=es.work_id
 AND(ew.state='ready' AND ew.lease_id IS NULL OR ew.state='claimed' AND ew.lease_expires_at<=clock_timestamp() OR ew.state='failed')
 AND(((mission_generic_owner.director_incomplete_reissue_proof_v1(ew.id,uid)->'can_reissue'='true'::jsonb) IS TRUE)
 OR(mission_generic_owner.writer_count_reissue_proof_v1(ew.id,uid) IS NOT NULL)
 OR(ew.authorization_id IS NULL AND ew.dispatch_id IS NULL AND ew.result IS NULL
 AND(NOT EXISTS(SELECT 1 FROM mission_narrative_internal.dispatch_audit ea WHERE ea.receipt_id=ew.dispatch_receipt_id AND ea.event_code='c8_count_started')
  OR EXISTS(SELECT 1 FROM mission_narrative_internal.dispatch_audit ea WHERE ea.receipt_id=ew.dispatch_receipt_id AND ea.event_code='c8_count_success' AND ea.details->'generation_allowed'='true'::jsonb)))
 OR(ew.state='failed' AND((ew.kind='director' AND ew.result->'failure_codes' ? 'MISSION_PROVIDER_OUTPUT_RETENTION_FAILED')
  OR(ew.kind='narration' AND ew.result->'ok'='true'::jsonb AND ew.result->>'provider_calls'='1')))))))),false))
 FROM mission_generic_owner.event_outbox_v1 es WHERE es.master_session_id=m.id AND (
 es.state NOT IN('terminal','waiting') OR (es.state='terminal' AND es.root_principal=uid AND active AND es.work_id IS NOT NULL
 AND (mission_generic_owner.director_incomplete_reissue_proof_v1(es.work_id,uid)->'can_reissue'='true'::jsonb) IS TRUE) OR (
 -- Re-expose only the latest waiting role-window whose sole old Count blocker has a real successor publication.
 es.state='waiting' AND es.event_domain='role_window' AND es.root_principal=uid AND active AND staff AND participant
 AND es.work_id IS NULL AND es.canonical_request IS NULL
 AND NOT EXISTS(SELECT 1 FROM mission_generic_owner.event_outbox_v1 later49 WHERE later49.event_key=es.event_key AND later49.event_version>es.event_version)
 AND EXISTS(SELECT 1 FROM mission_generic_owner.role_submissions src49 JOIN mission_generic_owner.role_window_cursors cur49
  ON cur49.master_session_id=src49.master_session_id AND cur49.window_epoch=src49.window_epoch
  WHERE src49.master_session_id=m.id AND src49.message_id=es.source_id AND src49.valid
   AND public.combat_v2_sha256(to_jsonb(src49))=es.source_sha256)
 AND EXISTS(SELECT 1 FROM mission_factory_owner.editor_release_readiness rr49
  JOIN mission_generic_owner.work_items old49 ON old49.id::text=rr49.canonical_preimage::jsonb#>>'{config,c1266_writer_count_reissue46,old_work_id}'
  JOIN mission_generic_owner.manual_staff_admissions_v1 ma49 ON ma49.master_session_id=old49.master_session_id
  JOIN LATERAL(SELECT mission_generic_owner.writer_count_reissue_proof_v1(old49.id,uid) proof) solved49
   ON solved49.proof->>'schema_version'='mission-writer-count-reissue-proof/1'
    AND solved49.proof->>'old_work_id'=old49.id::text AND solved49.proof->>'master_session_id'=m.id::text
    AND solved49.proof->'published'='true'::jsonb
  WHERE rr49.singleton AND rr49.scope='staff' AND rr49.state='enabled' AND rr49.revision_sha256=rr49.observed_revision_sha256
   AND old49.master_session_id=m.id AND old49.step_key=r.current_step_key AND old49.run_control_version=r.control_version
   AND old49.state='failed' AND old49.kind='narration' AND old49.result->>'failure_code'='MISSION_INPUT_COUNT_OVERFLOW'
   AND rr49.canonical_preimage::jsonb#>>'{config,c1266_writer_count_reissue46,master_session_id}'=m.id::text
   AND rr49.canonical_preimage::jsonb#>>'{config,c1266_writer_count_reissue46,payload_sha256}'=old49.payload_sha256
   AND ma49.admission_sha256=public.combat_v2_sha256(ma49.admission)
   AND (ma49.admission#>>'{source_scope,PG_count}')::integer>0
   AND (SELECT count(DISTINCT mp49.user_id_snapshot) FROM public.master_v2_participants mp49
    JOIN public.characters ch49 ON ch49.id=mp49.character_id AND ch49.user_id=mp49.user_id_snapshot
    WHERE mp49.session_id=m.id AND mp49.left_at IS NULL AND mp49.engagement_state='attivo')=(ma49.admission#>>'{source_scope,PG_count}')::integer
   AND NOT EXISTS(SELECT 1 FROM mission_generic_owner.work_items bad49 WHERE bad49.master_session_id=m.id
    AND bad49.step_key=r.current_step_key AND bad49.run_control_version=r.control_version AND bad49.state='failed' AND bad49.id<>old49.id))
 AND NOT EXISTS(SELECT 1 FROM public.master_v2_participants mp49 JOIN public.characters ch49 ON ch49.id=mp49.character_id AND ch49.user_id=mp49.user_id_snapshot
  LEFT JOIN LATERAL(SELECT rs49.valid FROM mission_generic_owner.role_submissions rs49 JOIN mission_generic_owner.role_window_cursors cur49
   ON cur49.master_session_id=rs49.master_session_id AND cur49.window_epoch=rs49.window_epoch
   WHERE rs49.master_session_id=m.id AND rs49.user_id=mp49.user_id_snapshot AND rs49.character_id=mp49.character_id
   ORDER BY rs49.accepted_at DESC,rs49.message_id DESC LIMIT 1) own49 ON true
  WHERE mp49.session_id=m.id AND mp49.left_at IS NULL AND mp49.engagement_state='attivo' AND own49.valid IS DISTINCT FROM true)
 AND NOT EXISTS(SELECT 1 FROM mission_generic_owner.work_items pending49 WHERE pending49.master_session_id=m.id AND pending49.state IN('ready','claimed','authorized','provider_started','uncertain'))
 AND NOT EXISTS(SELECT 1 FROM mission_generic_owner.unified_source_windows pending49 WHERE pending49.master_session_id=m.id AND pending49.consumed_message_id IS NULL AND pending49.superseded_at IS NULL)
 AND NOT EXISTS(SELECT 1 FROM mission_generic_owner.unified_batches pending49 WHERE pending49.master_session_id=m.id AND pending49.retired_at IS NULL AND pending49.state IN('preparing','ready'))
 AND NOT EXISTS(SELECT 1 FROM public.combat_v2_sessions combat49 WHERE combat49.master_session_id=m.id AND combat49.state<>'chiuso')
 ))
 -- Event43: only causally consumed native inputs in the qualified Staff path.
 AND NOT COALESCE((
 es.event_domain='native_input' AND es.state IN('pending','uncertain')
 AND EXISTS(SELECT 1 FROM public.locations event43_place WHERE event43_place.id=m.location_id
  AND event43_place.is_active AND event43_place.is_test)
 AND EXISTS(SELECT 1 FROM mission_factory_owner.editor_release_readiness event43_release
  WHERE event43_release.singleton AND event43_release.state='enabled' AND event43_release.scope='staff'
  AND event43_release.revision_sha256=event43_release.observed_revision_sha256
  AND event43_release.canonical_preimage::jsonb#>>'{config,c1266_server_events,schema_version}'='c1266-server-events/1'
  AND event43_release.canonical_preimage::jsonb#>'{config,c1266_server_events,enabled}'='true'::jsonb)
 AND EXISTS(SELECT 1 FROM public.profiles event43_actor
  WHERE event43_actor.id=es.root_principal AND event43_actor.role IN('admin','master'))
 AND EXISTS(SELECT 1 FROM mission_generic_owner.start_claims event43_start
  JOIN mission_generic_owner.board_starts event43_board ON event43_board.request_key=event43_start.request_key
  WHERE event43_start.request_key=es.root_request_key AND event43_start.actor_user_id=es.root_principal
  AND event43_start.session_id=es.master_session_id AND event43_board.master_session_id=es.master_session_id
  AND public.combat_v2_sha256(event43_board.result)=es.root_receipt_sha256)
 AND EXISTS(
 WITH event43_sources AS MATERIALIZED (SELECT src.round_id,src.declaration_id,src.coverage_id,src.source_kind
 FROM (
 SELECT dc.round_id,dc.defense_declaration_id AS declaration_id,dc.id AS coverage_id,'coverage'::text AS source_kind
 FROM public.combat_v2_defense_coverages dc
 JOIN public.combat_v2_declarations dd ON dd.id=dc.defense_declaration_id AND dd.round_id=dc.round_id
 JOIN public.combat_v2_actors aa ON aa.id=dd.actor_id AND aa.actor_kind='pg'
 WHERE dc.id=es.source_id AND es.source_sha256 IN(
 public.combat_v2_sha256(to_jsonb(dc)),
 public.combat_v2_sha256(jsonb_set(to_jsonb(dc),'{state}','"dichiarata"'::jsonb)))
 UNION ALL
 SELECT rt.round_id,rt.declaration_id,NULL::uuid,'rating'::text
 FROM public.combat_v2_ratings rt
 JOIN public.combat_v2_declarations dd ON dd.id=rt.declaration_id AND dd.round_id=rt.round_id
 WHERE rt.id=es.source_id AND rt.is_active
 AND es.source_sha256 IN(public.combat_v2_sha256(to_jsonb(rt)),
 public.combat_v2_sha256(jsonb_set(to_jsonb(rt),'{frozen_at}','null'::jsonb)))
 UNION ALL
 SELECT dd.round_id,dd.id,NULL::uuid,'declaration'::text
 FROM public.combat_v2_declarations dd JOIN public.combat_v2_actors aa ON aa.id=dd.actor_id AND aa.actor_kind='pg'
 WHERE dd.id=es.source_id AND es.source_sha256=public.combat_v2_sha256(to_jsonb(dd))
 ) src)
 SELECT 1 FROM event43_sources event43_src
 JOIN public.combat_v2_rounds event43_round ON event43_round.id=event43_src.round_id
 JOIN public.combat_v2_round_reports event43_report
  ON event43_report.id=event43_round.report_id AND event43_report.round_id=event43_round.id
 JOIN public.combat_v2_sessions event43_enc ON event43_enc.id=event43_round.session_id
  AND event43_enc.master_session_id=es.master_session_id AND event43_enc.location_id=m.location_id
 JOIN mission_generic_owner.unified_batches event43_batch
  ON event43_batch.master_session_id=es.master_session_id AND event43_batch.encounter_id=event43_enc.id
  AND event43_batch.source_round_id=event43_round.id AND event43_batch.source_report_id=event43_report.id
 JOIN mission_generic_owner.work_items event43_w ON event43_w.id=event43_batch.writer_work_id
  AND event43_w.event_id=event43_batch.id AND event43_w.authority_receipt_id=event43_batch.id
  AND event43_w.master_session_id=es.master_session_id AND event43_w.encounter_id=event43_enc.id
 JOIN public.messages event43_msg ON event43_msg.id=event43_w.message_id AND event43_msg.location_id=m.location_id
 WHERE (SELECT count(*) FROM event43_sources)=1
 AND es.event_key=mission_ai_service_owner.uuid5(event43_round.id,'server-event:native-input')
 AND es.created_at<=event43_batch.created_at
 AND ((es.work_id IS NULL AND es.canonical_request IS NULL) OR (es.work_id=event43_w.id
  AND es.canonical_request=jsonb_build_object('schema_version','mission-generic-request/1',
  'master_session_id',event43_w.master_session_id,'event_id',event43_w.event_id,
  'request_key',event43_w.request_key,'expected_revision',event43_w.revision)))
 AND event43_w.kind='narration' AND event43_w.state='completed' AND event43_w.result->'ok'='true'::jsonb
 AND event43_w.receipt_id IS NOT NULL AND event43_w.finalized_at IS NOT NULL
 AND event43_batch.state='published' AND event43_batch.published_at IS NOT NULL AND event43_batch.retired_at IS NULL
 AND event43_report.narration_state='pubblicata' AND event43_report.message_id=event43_msg.id
 AND event43_batch.message_id=event43_msg.id AND event43_msg.kind='fato' AND event43_msg.recipient_user IS NULL
 AND event43_report.mechanics_sha256=public.combat_v2_sha256(event43_report.mechanics)
 AND EXISTS(SELECT 1 FROM jsonb_array_elements(event43_report.mechanics->'declarations') event43_dec
  WHERE event43_dec->>'id'=event43_src.declaration_id::text)
 AND (event43_src.coverage_id IS NULL OR EXISTS(
  SELECT 1 FROM jsonb_array_elements(event43_report.mechanics->'defense_coverages') event43_cov
  WHERE event43_cov->>'id'=event43_src.coverage_id::text))
 AND EXISTS(SELECT 1 FROM mission_generic_owner.event_outbox_v1 event43_done
  WHERE event43_done.master_session_id=es.master_session_id AND event43_done.event_key=es.event_key
  AND event43_done.event_domain='native_input' AND event43_done.state='terminal'
  AND event43_done.root_event_key=es.root_event_key AND event43_done.root_event_version=es.root_event_version
  AND event43_done.root_request_key=es.root_request_key AND event43_done.root_principal=es.root_principal
  AND event43_done.root_receipt_sha256=es.root_receipt_sha256
  AND event43_done.work_id=event43_w.id
  AND event43_done.canonical_request=jsonb_build_object('schema_version','mission-generic-request/1',
  'master_session_id',event43_w.master_session_id,'event_id',event43_w.event_id,
  'request_key',event43_w.request_key,'expected_revision',event43_w.revision))
 AND (event43_w.result_sha256=public.combat_v2_sha256(event43_w.result) OR EXISTS(
  SELECT 1 FROM mission_narrative_internal.dispatch_audit event43_final
  WHERE event43_final.receipt_id=event43_w.dispatch_receipt_id AND event43_final.event_code='generic_finalized'
  AND event43_final.details->>'work_id'=event43_w.id::text
  AND event43_final.details->>'receipt_id'=event43_w.receipt_id::text
  AND event43_final.details->>'state'=event43_w.state
  AND event43_final.details->'message_id'=to_jsonb(event43_msg.id)
  AND event43_final.details->>'result_sha256'=event43_w.result_sha256
  AND event43_final.details->>'result_jsonb_sha256'=public.combat_v2_sha256(event43_w.result)))
 )
 ),FALSE)

 ORDER BY es.created_at DESC,es.event_key DESC,es.event_version DESC LIMIT 1),
 'retained_director_handoff',retained_handoff,'combat_narration_recovery',combat_recovery,'staff_finish',mission_generic_owner.staff_finish_status_v1(m.id,uid),'processing',uf_processing,'progress_key',uf_progress_key,'review_required',uf_review,
 'flow_state',flow_state,'flow_publication_id',flow_publication,
 'choices',case when uf_review or academy then '[]'::jsonb else vchoices->'choices' end,
 'choice_context',vchoices-'choices','state',m.stato,'can_tick',active and not uf_review AND NOT event42_mode
    and m.id<>'b70b23cf-bad8-475d-a56a-d9c549e35d84'::uuid,
 'request',case when active and not uf_review AND NOT event42_mode
    and m.id<>'b70b23cf-bad8-475d-a56a-d9c549e35d84'::uuid and not exists(
    select 1 from mission_generic_owner.role_window_cursors c where c.master_session_id=m.id)
    then jsonb_build_object('schema_version','mission-generic-tick/1','master_session_id',m.id) else null end)||coalesce(role_diag,'{}'::jsonb)||CASE WHEN staff_tick_view IS NOT NULL THEN jsonb_build_object('staff_tick_status',staff_tick_view) ELSE '{}'::jsonb END||CASE WHEN c26_driver IS NOT NULL THEN jsonb_build_object('driver_state',c26_driver) ELSE '{}'::jsonb END||CASE WHEN c26_count_view IS NOT NULL THEN jsonb_build_object('count_reconciliation',c26_count_view) ELSE '{}'::jsonb END||CASE WHEN opening_resume49 IS NOT NULL THEN jsonb_build_object('opening_ready_resume',opening_resume49) ELSE '{}'::jsonb END||CASE WHEN opening_claim_resume6 IS NOT NULL THEN jsonb_build_object('opening_claim_resume',opening_claim_resume6) ELSE '{}'::jsonb END||CASE WHEN journal_settlements IS NOT NULL THEN jsonb_build_object('journal_settlements',journal_settlements) ELSE '{}'::jsonb END||CASE WHEN role_command_capability IS NOT NULL THEN jsonb_build_object('role_submit_capability',role_command_capability) ELSE '{}'::jsonb END||CASE WHEN public56 IS NOT NULL THEN jsonb_build_object('narrative_scene',public56,'combat_surface',surface56) ELSE '{}'::jsonb END;
end;
$$;
CREATE OR REPLACE FUNCTION public.mission_generic_staff_finish_v1(p_session uuid, p_user uuid, p_source_revision text, p_expected_publication uuid, p_request uuid) RETURNS jsonb LANGUAGE plpgsql SECURITY DEFINER SET search_path TO '' AS $$
DECLARE old mission_generic_owner.staff_finish_receipts_v1;v jsonb;j jsonb;h text;root_sha text;res jsonb;receipt_sha text;native_result jsonb;
BEGIN
 PERFORM mission_ai_board_owner.service_only();
 IF p_session IS NULL OR p_user IS NULL OR p_source_revision IS NULL OR p_source_revision!~'^[0-9a-f]{64}$' OR p_expected_publication IS NULL OR p_request IS NULL THEN RAISE EXCEPTION 'MGS_FINISH_INPUT' USING ERRCODE='22023';END IF;
 IF NOT EXISTS(SELECT 1 FROM public.profiles pr JOIN public.master_v2_participants mp ON mp.user_id_snapshot=pr.id
 JOIN public.characters ch ON ch.id=mp.character_id AND ch.user_id=pr.id WHERE pr.id=p_user AND pr.role IN('admin','master') AND mp.session_id=p_session)
 THEN RAISE EXCEPTION 'MGS_FINISH_STAFF_AUTH' USING ERRCODE='42501';END IF;
 PERFORM mission_ai_service_owner.lock_request(p_request);
 SELECT * INTO old FROM mission_generic_owner.staff_finish_receipts_v1 WHERE request_key=p_request;
 IF FOUND THEN
  IF old.master_session_id IS DISTINCT FROM p_session OR old.actor_user_id IS DISTINCT FROM p_user OR old.source_revision IS DISTINCT FROM p_source_revision
   OR old.publication_id IS DISTINCT FROM p_expected_publication OR old.state IS DISTINCT FROM 'completed'
   OR old.result_sha256 IS DISTINCT FROM public.combat_v2_sha256(old.result)
  THEN RAISE EXCEPTION 'MGS_FINISH_REPLAY_CONFLICT' USING ERRCODE='40001';END IF;
  RETURN old.result||jsonb_build_object('replayed',true);
 END IF;
 PERFORM pg_advisory_xact_lock_shared(hashtextextended('C1266:GENERIC-AI:AVAILABILITY',0));
 IF EXISTS(SELECT 1 FROM mission_narrative_internal.scene_runtime_v1 WHERE master_session_id=p_session AND is_active) THEN PERFORM 1 FROM public.locations WHERE id=(SELECT location_id FROM public.master_v2_sessions WHERE id=p_session) FOR UPDATE;END IF;
 PERFORM 1 FROM mission_generic_owner.role_window_cursors WHERE master_session_id=p_session FOR UPDATE;
 PERFORM public.master_v2_lock_scope(p_session);
 PERFORM mission_generic_owner.dispatch_user(p_session,p_user);
 v:=mission_generic_owner.staff_finish_status_v1(p_session,p_user);
 IF v IS NULL OR v->'can_finish' IS DISTINCT FROM 'true'::jsonb OR v->>'source_revision' IS DISTINCT FROM p_source_revision
 OR v->>'expected_publication_id' IS DISTINCT FROM p_expected_publication::text OR v->>'request_key' IS DISTINCT FROM p_request::text
 THEN RAISE EXCEPTION 'MGS_FINISH_NOT_READY' USING ERRCODE='55000';END IF;
 IF EXISTS(SELECT 1 FROM mission_narrative_internal.scene_runtime_v1 WHERE master_session_id=p_session AND is_active) THEN
  j:=jsonb_build_object('items',mission_narrative_internal.scene_finish_proof_v1(p_session,p_user)->'history_items');
 ELSE
 j:=mission_generic_owner.staff_journal_settlements_v1(p_session,p_user);
 END IF;
 SELECT public.combat_v2_sha256(coalesce(jsonb_agg(to_jsonb(w) ORDER BY w.id),'[]'::jsonb)) INTO h FROM mission_generic_owner.work_items w WHERE w.master_session_id=p_session;
 SELECT revision_sha256 INTO root_sha FROM mission_factory_owner.editor_release_readiness WHERE singleton;
 INSERT INTO mission_generic_owner.staff_finish_receipts_v1(request_key,master_session_id,actor_user_id,source_revision,publication_id,state,transaction_id,release_sha256,work_snapshot_sha256,history_proof,history_proof_sha256)
 VALUES(p_request,p_session,p_user,p_source_revision,p_expected_publication,'preparing',txid_current(),root_sha,h,j->'items',public.combat_v2_sha256(j->'items'));
 native_result:=mission_generic_owner.finish_mission(p_session,'success');
 IF NOT EXISTS(SELECT 1 FROM public.master_v2_sessions m JOIN public.mission_run_state r ON r.master_session_id=m.id WHERE m.id=p_session AND m.stato='chiusa' AND m.closed_at IS NOT NULL AND m.close_reason='completata' AND r.run_phase='conclusa')
 OR NOT EXISTS(SELECT 1 FROM mission_ai_service_owner.capabilities c WHERE c.master_session_id=p_session AND c.state='terminal' AND c.terminal_mode='normal')
 THEN RAISE EXCEPTION 'MGS_FINISH_NATIVE_INCOMPLETE' USING ERRCODE='55000';END IF;
 receipt_sha:=public.combat_v2_sha256(jsonb_build_object('schema_version','mission-staff-finish-receipt/1','master_session_id',p_session,'actor_user_id',p_user,'source_revision',p_source_revision,'publication_id',p_expected_publication,'request_key',p_request,'work_snapshot_sha256',h,'history_proof_sha256',public.combat_v2_sha256(j->'items'),'native_result',native_result,'effects','simulation_only'));
 res:=jsonb_build_object('schema_version','mission-generic-staff-finish-result/1','master_session_id',p_session,'state','closed','source_revision',p_source_revision,'publication_id',p_expected_publication,'request_key',p_request,'outcome','success','receipt_sha256',receipt_sha,'replayed',false);
 UPDATE mission_generic_owner.staff_finish_receipts_v1 SET state='completed',result=res,result_sha256=public.combat_v2_sha256(res),completed_at=clock_timestamp() WHERE request_key=p_request AND state='preparing' AND transaction_id=txid_current();
 IF NOT FOUND THEN RAISE EXCEPTION 'MGS_FINISH_RECEIPT_CAS' USING ERRCODE='40001';END IF;
 RETURN res;
END $$;
CREATE OR REPLACE FUNCTION mission_generic_owner.staff_finish_status_v1(p_session uuid, p_user uuid) RETURNS jsonb LANGUAGE plpgsql STABLE SECURITY DEFINER SET search_path TO '' AS $$
DECLARE m public.master_v2_sessions;r public.mission_run_state;c mission_generic_owner.role_window_cursors;
 b mission_generic_owner.unified_batches;w mission_generic_owner.work_items;sw mission_generic_owner.unified_source_windows;
 pp mission_generic_owner.unified_segment_publications_v4;j jsonb;q jsonb;k uuid;reason text:='scope_closed';
 outcome text;rev text;
BEGIN
 IF EXISTS(SELECT 1 FROM mission_narrative_internal.scene_runtime_v1 WHERE master_session_id=p_session AND is_active) THEN
  j:=mission_narrative_internal.scene_finish_proof_v1(p_session,p_user);
  IF j IS NULL THEN RETURN NULL;END IF;
  RETURN jsonb_build_object('schema_version','mission-generic-staff-finish-status/1','master_session_id',p_session,
   'state',CASE WHEN j->'can_finish'='true'::jsonb THEN 'ready' ELSE 'blocked' END,'can_finish',j->'can_finish',
   'source_revision',j->'source_revision','expected_publication_id',CASE WHEN j->'can_finish'='true'::jsonb THEN j->'publication_id' ELSE 'null'::jsonb END,
   'request_key',j->'request_key','outcome',CASE WHEN j->'can_finish'='true'::jsonb THEN 'success' ELSE NULL END,'reason',j->>'reason');
 END IF;
 IF p_session IS NULL OR p_user IS NULL OR mission_generic_owner.staff_finish_policy_v1(p_session) IS DISTINCT FROM true THEN RETURN NULL;END IF;
 SELECT * INTO m FROM public.master_v2_sessions WHERE id=p_session;
 SELECT * INTO r FROM public.mission_run_state WHERE master_session_id=p_session;
 SELECT * INTO c FROM mission_generic_owner.role_window_cursors WHERE master_session_id=p_session;
 IF m.id IS NULL OR m.owner_kind IS DISTINCT FROM 'ai_service' OR m.master_user IS NOT NULL
 OR m.location_id IS DISTINCT FROM '0b85f354-9cdb-47e1-baf9-3d266bb7e06b'::uuid
 OR m.stato IS DISTINCT FROM 'in_corso' OR m.closed_at IS NOT NULL OR m.suspended_at IS NOT NULL
 OR r.run_phase IS DISTINCT FROM 'in_corso'
 OR NOT EXISTS(SELECT 1 FROM public.locations l WHERE l.id=m.location_id AND l.is_test AND l.is_active)
 OR NOT EXISTS(SELECT 1 FROM public.profiles pr JOIN public.master_v2_participants mp ON mp.user_id_snapshot=pr.id
 JOIN public.characters ch ON ch.id=mp.character_id AND ch.user_id=pr.id WHERE pr.id=p_user AND pr.role IN('admin','master')
 AND mp.session_id=p_session AND mp.left_at IS NULL AND mp.engagement_state='attivo')
 THEN RETURN NULL;END IF;
 SELECT t->>'outcome' INTO outcome FROM jsonb_array_elements(mission_generic_owner.run_plan_settings(p_session)->'terminal_steps')t WHERE t->>'step_key'=r.current_step_key;
 IF outcome IS DISTINCT FROM 'success' THEN RETURN NULL;END IF;
 q:=mission_generic_owner.manual_staff_scope_v1(p_session);
 IF EXISTS(SELECT 1 FROM mission_generic_owner.work_items x WHERE x.master_session_id=p_session AND x.state IN('ready','claimed','authorized','provider_started','uncertain'))
 OR EXISTS(SELECT 1 FROM mission_narrative_internal.dispatch_attempts d JOIN mission_generic_owner.work_items x ON x.dispatch_receipt_id=d.receipt_id
 WHERE x.master_session_id=p_session AND d.status IN('reserved','authorized','provider_started'))
 OR EXISTS(SELECT 1 FROM public.mission_run_outbox ob WHERE ob.master_session_id=p_session AND ob.state IN('pending','human_directed'))
 OR EXISTS(SELECT 1 FROM mission_generic_owner.unified_batches ub WHERE ub.master_session_id=p_session AND ub.retired_at IS NULL AND ub.state IN('preparing','ready'))
 OR EXISTS(SELECT 1 FROM mission_generic_owner.unified_source_windows s WHERE s.master_session_id=p_session AND s.consumed_message_id IS NULL AND s.superseded_at IS NULL)
 THEN reason:='work_pending';
 ELSIF EXISTS(SELECT 1 FROM public.combat_v2_sessions cs WHERE cs.master_session_id=p_session AND (cs.state<>'chiuso' OR cs.closed_at IS NULL)) THEN reason:='combat_pending';
 ELSIF EXISTS(SELECT 1 FROM mission_generic_owner.role_submissions rs WHERE rs.master_session_id=p_session AND rs.window_epoch=c.window_epoch) THEN reason:='roles_pending';
 ELSE
  SELECT ub.* INTO b FROM mission_generic_owner.unified_batches ub WHERE ub.master_session_id=p_session AND ub.state='published'
   AND ub.retired_at IS NULL AND ub.step_key=r.current_step_key AND ub.run_control_version=r.control_version
   AND ub.message_id=c.last_published_fato_id ORDER BY ub.published_at DESC,ub.id DESC LIMIT 1;
  SELECT * INTO w FROM mission_generic_owner.work_items WHERE id=b.writer_work_id;
  SELECT * INTO sw FROM mission_generic_owner.unified_source_windows WHERE id=b.source_window_id;
  SELECT * INTO pp FROM mission_generic_owner.unified_segment_publications_v4 WHERE work_id=w.id AND batch_id=b.id AND message_id=b.message_id;
  rev:=sw.context->>'source_revision';
  IF b.id IS NULL OR b.message_id IS NULL OR b.published_at IS NULL OR w.id IS NULL OR w.kind IS DISTINCT FROM 'narration'
   OR w.state IS DISTINCT FROM 'completed' OR w.message_id IS DISTINCT FROM b.message_id OR w.authority_receipt_id IS DISTINCT FROM b.id
   OR w.master_session_id IS DISTINCT FROM p_session OR w.step_key IS DISTINCT FROM r.current_step_key OR w.run_control_version IS DISTINCT FROM r.control_version
   OR w.payload_sha256 IS DISTINCT FROM b.payload_sha256 OR w.payload IS DISTINCT FROM b.payload
   OR sw.master_session_id IS DISTINCT FROM p_session OR sw.step_key IS DISTINCT FROM r.current_step_key OR sw.run_control_version IS DISTINCT FROM r.control_version
   OR sw.consumed_message_id IS DISTINCT FROM b.message_id OR sw.superseded_at IS NOT NULL OR rev IS NULL OR rev!~'^[0-9a-f]{64}$'
   OR pp.work_id IS NULL OR pp.source_revision IS DISTINCT FROM rev
   OR cardinality(sw.role_ids) IS DISTINCT FROM jsonb_array_length(q->'roster_character_ids')
   OR (SELECT count(DISTINCT rs.character_id) FROM mission_generic_owner.role_submissions rs WHERE rs.master_session_id=p_session AND rs.message_id=ANY(sw.role_ids) AND rs.valid
    AND q->'roster_character_ids' @> jsonb_build_array(rs.character_id::text)) IS DISTINCT FROM jsonb_array_length(q->'roster_character_ids')::bigint
   OR NOT EXISTS(SELECT 1 FROM public.messages msg WHERE msg.id=b.message_id AND msg.location_id=m.location_id AND msg.kind='fato' AND msg.character_id IS NULL
    AND msg.recipient_user IS NULL AND msg.body=w.result->>'text'
    AND encode(extensions.digest(convert_to(msg.body,'UTF8'),'sha256'),'hex')=pp.final_text_sha256)
   THEN reason:='waiting_final_publication';
  ELSE
   j:=mission_generic_owner.staff_journal_settlements_v1(p_session,p_user);
   IF j IS NULL OR EXISTS(SELECT 1 FROM mission_generic_owner.work_items x WHERE x.master_session_id=p_session AND x.state<>'completed'
    AND (x.state<>'failed' OR x.finalized_at IS NULL OR NOT EXISTS(SELECT 1 FROM jsonb_array_elements(j->'items')i
      WHERE i->>'work_id'=x.id::text AND i->>'receipt_id'=x.receipt_id::text AND i->>'result_sha256'=x.result_sha256
       AND i->'selector'->>'kind'='request' AND (jsonb_typeof(i->'publication')='object' OR jsonb_typeof(i->'release')='object'))))
    THEN reason:='history_unreconciled';
   ELSE reason:='ready';k:=mission_ai_service_owner.uuid5(p_session,'mission-staff-finish/1:'||rev||':'||b.message_id::text);END IF;
  END IF;
 END IF;
 RETURN jsonb_build_object('schema_version','mission-generic-staff-finish-status/1','master_session_id',p_session,
 'state',CASE WHEN reason='ready' THEN 'ready' ELSE 'blocked' END,'can_finish',reason='ready',
 'source_revision',CASE WHEN reason='ready' THEN rev ELSE NULL END,'expected_publication_id',CASE WHEN reason='ready' THEN b.message_id ELSE NULL END,
 'request_key',k,'outcome',CASE WHEN reason='ready' THEN 'success' ELSE NULL END,'reason',reason);
END $$;
CREATE OR REPLACE FUNCTION mission_generic_owner.work_assert(w mission_generic_owner.work_items) RETURNS void LANGUAGE plpgsql SECURITY DEFINER SET search_path TO '' AS $$
declare r public.mission_run_state;b mission_generic_owner.run_bindings;m public.master_v2_sessions;q mission_factory_owner.quest_run_sources;
begin
 perform mission_generic_owner.assert_runtime(w.master_session_id);
 select * into strict m from public.master_v2_sessions where id=w.master_session_id for share;
 select * into strict r from public.mission_run_state where master_session_id=w.master_session_id for share;
 select * into strict b from mission_generic_owner.run_bindings where master_session_id=w.master_session_id;
 IF w.kind='narration' AND w.payload->>'schema_version'='mission-narrative-scene/1' AND w.payload->>'mode'='narrative_scene' THEN
  IF m.owner_kind<>'ai_service' OR m.closed_at IS NOT NULL OR m.suspended_at IS NOT NULL
   OR r.current_step_key IS DISTINCT FROM w.step_key OR r.control_version IS DISTINCT FROM w.run_control_version
   OR b.snapshot_sha256 IS DISTINCT FROM w.definition_sha256 OR b.snapshot_sha256 IS DISTINCT FROM mission_internal.fingerprint(b.snapshot)
   OR w.payload_sha256 IS DISTINCT FROM public.combat_v2_sha256(w.payload)
   OR NOT EXISTS(SELECT 1 FROM mission_narrative_internal.scene_sources_v1 src
    JOIN mission_narrative_internal.scene_runtime_v1 runtime ON runtime.id=src.scene_id
    WHERE src.work_id=w.id AND src.id=w.authority_receipt_id AND runtime.master_session_id=m.id
    AND runtime.is_active AND runtime.mode='narrative' AND src.retired_at IS NULL
    AND ((src.request_kind='narration' AND m.stato='in_corso' AND r.run_phase='in_corso')
     OR(src.request_kind='initial_opening' AND m.stato='preparazione' AND r.run_phase='preparazione'
      AND EXISTS(SELECT 1 FROM mission_generic_owner.board_starts bs WHERE bs.id=src.board_start_receipt_id
       AND bs.master_session_id=m.id AND bs.simulation AND bs.state='prepared'))))
  THEN RAISE EXCEPTION 'SCENE56_WORK_STALE' USING ERRCODE='PT409';END IF;
  RETURN;
 END IF;
 if exists(select 1 from mission_factory_owner.quest_run_sources where session_id=w.master_session_id) then
   perform mission_factory_owner.quest_run_source_assert_v1(w.master_session_id);
   select * into strict q from mission_factory_owner.quest_run_sources
     where session_id=w.master_session_id for share;
   if m.tipo<>'quest' or m.mission_id is not null or m.owner_kind<>'ai_service'
      or m.master_user is not null or m.closed_at is not null
      or r.source_kind<>'quest' or r.quest_episode_id is distinct from q.episode_id
      or r.current_step_key is distinct from w.step_key
      or r.control_version is distinct from w.run_control_version
      or b.snapshot_sha256 is distinct from w.definition_sha256
      or w.payload->>'source_kind' is distinct from 'quest'
      or w.payload->'quest_source' is distinct from
           mission_factory_owner.quest_work_source_v1(w.master_session_id)
      or w.payload_sha256 is distinct from public.combat_v2_sha256(w.payload)
      or (w.payload ? 'opening_start_receipt_id')
      or (w.payload ? 'quest_start_event_id')
   then raise exception 'MF_QUEST_WORK_STALE' using errcode='40001'; end if;
   perform mission_factory_owner.quest_lifecycle_assert_v1(w);
   return;
 end if;
 if m.owner_kind<>'ai_service' or m.closed_at is not null
 or (w.payload ? 'opening_start_receipt_id' and (m.stato<>'preparazione' or r.run_phase<>'preparazione'
  or not exists(select 1 from mission_generic_owner.board_starts bs where bs.id=(w.payload->>'opening_start_receipt_id')::uuid
   and bs.master_session_id=w.master_session_id and bs.state='prepared')))
 or (not(w.payload ? 'opening_start_receipt_id') and m.stato<>'in_corso')
 or r.current_step_key<>w.step_key or r.control_version<>w.run_control_version
 or b.snapshot_sha256<>w.definition_sha256 or b.snapshot_sha256<>mission_internal.fingerprint(b.snapshot)
 or w.payload_sha256<>public.combat_v2_sha256(w.payload)
 then raise exception 'MGD_WORK_STALE' using errcode='40001';end if;
end;
$$;
CREATE OR REPLACE FUNCTION mission_public_owner.work_contract_issue_v1(p_work uuid) RETURNS jsonb LANGUAGE plpgsql SECURITY DEFINER SET search_path TO '' AS $$
declare w mission_generic_owner.work_items;b mission_generic_owner.run_bindings;
 a mission_public_owner.session_admissions_v1;q mission_factory_owner.quest_run_sources;
 pub mission_factory_owner.publications;source_scope text;release_sha text;profile text;
 q49 jsonb;source_attestation jsonb;payload_version text;features jsonb:='[]'::jsonb;doc jsonb;old jsonb;ignored jsonb;c5_proof jsonb;c5_native jsonb;c5_stamp jsonb;template_policy jsonb;
begin
 select * into strict w from mission_generic_owner.work_items where id=p_work for update;
 old:=mission_public_owner.work_contract_v1(w.id);
 if old is not null then return old;end if;
 IF w.kind='narration' AND w.payload->>'schema_version'='mission-narrative-scene/1'
  AND w.payload->>'mode'='narrative_scene' THEN
  IF w.state<>'ready' THEN RAISE EXCEPTION 'SCENE56_CONTRACT_WORK_STATE' USING ERRCODE='PT409';END IF;
  ignored:=mission_narrative_internal.scene_source_assert_v1(w.id);
  c5_proof:=mission_generic_owner.c1266_execution_authority_v1(w.master_session_id,false,true);
  q49:=mission_generic_owner.manual_staff_scope_v1(w.master_session_id);
  c5_native:=mission_generic_owner.manual_staff_native_v1(w.master_session_id,false,true);
  IF c5_proof IS NULL OR q49 IS NULL OR c5_native IS NULL
   OR c5_proof->>'execution_context'<>'staff_mission' THEN
   RAISE EXCEPTION 'SCENE56_ADMISSION_CLOSED' USING ERRCODE='42501';END IF;
  release_sha:=c5_proof->>'release_sha256';
  c5_stamp:=jsonb_build_object('schema_version','c1266-work-execution-attestation/3',
   'execution_context',c5_proof->>'execution_context','admission',c5_proof->'admission',
   'release_sha256',release_sha,'binding_sha256',c5_proof->>'binding_sha256',
   'financial_qualification_sha256',c5_proof->>'financial_qualification_sha256',
   'c7_budget_qualification_sha256',c5_proof->>'c7_budget_qualification_sha256',
   'start_receipt_id',c5_native->>'start_receipt_id',
   'start_snapshot_sha256',c5_native#>>'{eligibility,board_snapshot_sha256}',
   'source_scope',q49->'source_scope','source_qualification',q49,
   'source_qualification_sha256',public.combat_v2_sha256(q49));
  source_attestation:=jsonb_build_object('schema_version','mission-narrative-scene-attestation/1',
   'work_id',w.id,'authority_receipt_id',w.authority_receipt_id,'payload_sha256',w.payload_sha256,
   'master_session_id',w.master_session_id,'definition_sha256',w.definition_sha256,
   'release_sha256',release_sha,'execution_authority',c5_stamp,'scene',ignored);
  doc:=jsonb_build_object('schema_version','mission-narrative-admission/3','scope','staff_mission',
   'release_sha256',release_sha,'work_id',w.id,'master_session_id',w.master_session_id,
   'definition_sha256',w.definition_sha256,'payload_sha256',w.payload_sha256,
   'payload_schema_version','mission-narrative-scene/1','editorial_profile','cinematic_master_1',
   'features',jsonb_build_array('execution_authority_v1','provider_output_retention_v1','direct_scene_narration_v1'),
   'source_attestation',source_attestation);
  INSERT INTO mission_public_owner.work_contracts_v1(work_id,master_session_id,scope,release_sha256,
   definition_sha256,payload_sha256,contract,contract_sha256)
  VALUES(w.id,w.master_session_id,'staff_mission',release_sha,w.definition_sha256,w.payload_sha256,doc,public.combat_v2_sha256(doc));
  RETURN doc;
 END IF;

  template_policy:=mission_generic_owner.manual_staff_template_policy_v1(w.master_session_id);
 IF mission_generic_owner.c1266_opening_named_v1(w.master_session_id) THEN
  c5_proof:=mission_generic_owner.c1266_execution_authority_v1(w.master_session_id,false,true);
  c5_native:=mission_generic_owner.c1266_native_start_v1(w.master_session_id,false,true);
  IF c5_proof IS NULL OR c5_native IS NULL THEN RAISE EXCEPTION 'C1266_NARRATIVE5_ISSUE_CLOSED' USING ERRCODE='42501';END IF;
  release_sha:=c5_proof->>'release_sha256';source_scope:=CASE WHEN c5_proof#>>'{admission,resource_scope}'='world' THEN 'public_mission' ELSE 'staff_mission' END;
  c5_stamp:=jsonb_build_object('schema_version','c1266-work-execution-attestation/1','execution_context',c5_proof->>'execution_context',
   'admission',c5_proof->'admission','release_sha256',release_sha,'binding_sha256',c5_proof->>'binding_sha256',
   'financial_qualification_sha256',c5_proof->>'financial_qualification_sha256','c7_budget_qualification_sha256',c5_proof->>'c7_budget_qualification_sha256',
   'start_receipt_id',c5_native->>'start_receipt_id','start_snapshot_sha256',c5_native#>>'{eligibility,board_snapshot_sha256}',
   'source_scope',(SELECT canonical_preimage::jsonb#>'{config,c1266_opening,source_scope}' FROM mission_factory_owner.editor_release_readiness WHERE singleton));
 q49:=mission_generic_owner.c1266_staff_source_scope_v1(w.master_session_id);
 IF q49 IS NOT NULL THEN
 c5_stamp:=c5_stamp||jsonb_build_object('schema_version','c1266-work-execution-attestation/2','source_scope',q49->'source_scope','source_qualification',q49,'source_qualification_sha256',public.combat_v2_sha256(q49));
 END IF;
 q49:=mission_generic_owner.manual_staff_scope_v1(w.master_session_id);
 IF q49 IS NOT NULL THEN
  c5_stamp:=c5_stamp||jsonb_build_object('schema_version','c1266-work-execution-attestation/3','source_scope',q49->'source_scope','source_qualification',q49,'source_qualification_sha256',public.combat_v2_sha256(q49));
 END IF;
 ELSIF mission_generic_owner.c1266_role_scope_v1(w.master_session_id,true) THEN
  ignored:=mission_generic_owner.c1266_clean_staff_admission_v1(w.master_session_id,true,true);
  release_sha:=ignored->>'release_sha256';source_scope:='staff_mission';
 ELSIF exists(select 1 from mission_factory_owner.quest_run_sources qs where qs.session_id=w.master_session_id and qs.availability_scope='public' and qs.state in('prepared','opening_pending','uncertain','started')) then
  ignored:=mission_factory_owner.quest_run_source_assert_v1(w.master_session_id);
  select * into strict q from mission_factory_owner.quest_run_sources where session_id=w.master_session_id;
  release_sha:=q.public_release_sha256;source_scope:='public_quest';
 elsif mission_public_owner.role_session_allowed_v1(w.master_session_id) then
  select * into strict a from mission_public_owner.session_admissions_v1 where master_session_id=w.master_session_id;
  release_sha:=a.release_sha256;source_scope:='public_mission';
 elsif exists(select 1 from mission_launch_owner.dual_decisions d
  join mission_launch_owner.dual_scopes s on s.mission_id=d.mission_id and s.activation_id=d.activation_id
  where d.master_session_id=w.master_session_id) then
  ignored:=mission_public_owner.launch_provenance_v1(w.master_session_id);
  if ignored->>'availability_scope' is distinct from 'staff'
  then raise exception 'NARRATIVE_STAFF_LAUNCH_PROVENANCE' using errcode='42501';end if;
  release_sha:=ignored->>'release_sha256';source_scope:='staff_mission';
 elsif exists(select 1 from mission_factory_owner.quest_run_sources qs
  join public.master_v2_sessions ms on ms.id=qs.session_id
  join public.locations l on l.id=ms.location_id
  where qs.session_id=w.master_session_id and l.id='0b85f354-9cdb-47e1-baf9-3d266bb7e06b'::uuid
   and l.is_active and l.is_test and ms.owner_kind='ai_service' and ms.mission_id is null
   and ms.closed_at is null and ms.suspended_at is null
   and qs.state in('prepared','opening_pending','uncertain','started')) then
  -- Same authoritative Factory assertion, not a second Quest engine.
  ignored:=mission_factory_owner.quest_run_source_assert_v1(w.master_session_id);
  select * into strict q from mission_factory_owner.quest_run_sources where session_id=w.master_session_id;
  select p.* into strict pub from mission_public_owner.publications_v2 p
   join mission_factory_owner.quest_arcs arc on arc.publication_request=p.request_key where arc.id=q.arc_id;
  if pub.target<>'staff' or pub.state<>'staff' or pub.quest_arc_id is distinct from q.arc_id
  then raise exception 'NARRATIVE_QUEST_PUBLICATION_SCOPE' using errcode='42501';end if;
  release_sha:=pub.release_revision_sha256;source_scope:='staff_quest';
 else return null;end if;
 if w.state<>'ready' or w.kind not in('director','narration','choice')
 or w.payload_sha256 is distinct from public.combat_v2_sha256(w.payload)
 then raise exception 'NARRATIVE_WORK_CONTRACT_SOURCE' using errcode='40001';end if;
 select * into strict b from mission_generic_owner.run_bindings where master_session_id=w.master_session_id;
 if b.snapshot_sha256 is distinct from w.definition_sha256
 or b.snapshot_sha256 is distinct from mission_internal.fingerprint(b.snapshot)
 then raise exception 'NARRATIVE_WORK_CONTRACT_BINDING' using errcode='40001';end if;
 payload_version:=w.payload->>'schema_version';
 profile:=case when w.kind in('narration','director') then 'cinematic_master_1' else 'legacy' end;
 if w.kind='director' and (payload_version in('mission-director-work/1','mission-director-work/2','mission-director-work/3') OR(payload_version='mission-director-work/4' AND mission_generic_owner.c1266_role_scope_v2(w.master_session_id,true) AND mission_generic_owner.c1266_role_work_attest_v2(w.id) IS NOT NULL)) then
  if not exists(select 1 from mission_generic_owner.unified_source_windows sw
   where sw.id=w.authority_receipt_id and sw.master_session_id=w.master_session_id
    and sw.work_id=w.id and sw.definition_sha256=w.definition_sha256
    and sw.step_key=w.step_key and sw.run_control_version=w.run_control_version)
  then raise exception 'NARRATIVE_DIRECTOR_SOURCE_RECEIPT' using errcode='40001';end if;
  features:=jsonb_build_array('director_progression','speech_intent');
 elsif w.kind='narration' and payload_version in('mission-generic-narration/3','mission-generic-narration/4') then
  if not exists(select 1 from mission_generic_owner.unified_batches ub
   where ub.id=w.authority_receipt_id and ub.master_session_id=w.master_session_id
    and ub.writer_work_id=w.id and ub.payload_sha256=w.payload_sha256
    and ub.state='ready')
  then raise exception 'NARRATIVE_WRITER_BATCH_RECEIPT' using errcode='40001';end if;
  features:=jsonb_build_array(case payload_version when 'mission-generic-narration/3'
    then 'unified_narration_v3' else 'segmented_narration_v4' end);
 elsif w.kind='narration' and payload_version in('mission-generic-narration/1','mission-generic-narration/2') then
  if jsonb_array_length(coalesce(w.payload->'roleless_declarations','[]'::jsonb))>0 then
   raise exception 'NARRATIVE_ROLELESS_REQUIRES_NATIVE_UNIFIED_ROUTE' using errcode='55000';end if;
 elsif w.kind<>'choice' then
  raise exception 'NARRATIVE_WORK_PROFILE_UNSUPPORTED' using errcode='55000';
 end if;
 source_attestation:=mission_public_owner.narrative_source_attest_v1(w.id)||jsonb_build_object('master_session_id',w.master_session_id,'definition_sha256',w.definition_sha256,'release_sha256',release_sha);
 IF source_attestation#>>'{role_intents,schema_version}' IN('mission-role-intent-attestation/2','mission-role-intent-attestation/3','mission-role-intent-attestation/4') THEN
  IF source_attestation#>>'{role_intents,schema_version}'='mission-role-intent-attestation/4' AND(source_scope IS DISTINCT FROM 'staff_mission' OR source_attestation#>>'{role_intents,temporal_contract_sha256}' IS DISTINCT FROM '0603ab23e76750b5babeb41421bc84b551b959945f21267ffd7169140732f1e8' OR source_attestation#>>'{role_intents,peer_confirmation,schema_version}' IS DISTINCT FROM 'mission-peer-confirmation-contract/2') THEN RAISE EXCEPTION 'C1266_PEER_FEATURE_SCOPE' USING ERRCODE='42501';END IF;
  IF source_attestation#>>'{role_intents,schema_version}'='mission-role-intent-attestation/3' AND (source_scope IS DISTINCT FROM 'staff_mission' OR source_attestation#>>'{role_intents,temporal_contract_sha256}' IS DISTINCT FROM '3fdeaa942bcf3ba217a976f7b0896f4594721fa45cde9ff8ed7bddf15391feda' OR source_attestation#>>'{role_intents,peer_confirmation,schema_version}' IS DISTINCT FROM 'mission-peer-confirmation-contract/1') THEN RAISE EXCEPTION 'C1266_PEER_FEATURE_SCOPE' USING ERRCODE='42501';END IF;
  IF NOT mission_generic_owner.c1266_role_scope_v2(w.master_session_id,true) OR (source_scope IS DISTINCT FROM 'staff_mission' AND c5_proof IS NULL) THEN RAISE EXCEPTION 'C1266_TEMPORAL_FEATURE_SCOPE' USING ERRCODE='42501';END IF;
  features:=features||jsonb_build_array('role_intents_v2');
 ELSIF source_attestation->'role_intents' IS NOT NULL THEN
  IF NOT mission_generic_owner.c1266_role_scope_v1(w.master_session_id,true)
   OR (source_scope IS DISTINCT FROM 'staff_mission' AND c5_proof IS NULL)
  THEN RAISE EXCEPTION 'C1266_ROLE_FEATURE_SCOPE' USING ERRCODE='42501';END IF;
  features:=features||jsonb_build_array('role_intents_v1');
 END IF;
 if jsonb_typeof(source_attestation->'peaceful_exit')='object' then features:=features||jsonb_build_array('peaceful_exit_v1');end if;
 if jsonb_array_length(source_attestation->'continuity_sources')>0 then
  features:=features||jsonb_build_array('continuity_sources_v1');
 end if;
 -- peaceful_exit is not inferred from the profile, caller or an arbitrary UUID.
 -- It requires a separate native legal capability; none is minted here.
 IF c5_stamp IS NOT NULL THEN source_attestation:=source_attestation||jsonb_build_object('execution_authority',c5_stamp);features:=features||jsonb_build_array('execution_authority_v1');END IF;
 IF source_scope='staff_mission' AND c5_stamp IS NOT NULL
  AND mission_generic_owner.manual_staff_scope_v1(w.master_session_id) IS NOT NULL
  AND EXISTS(SELECT 1 FROM mission_factory_owner.editor_release_readiness r WHERE r.singleton AND r.state='enabled'
    AND r.revision_sha256=r.observed_revision_sha256
    AND r.canonical_preimage::jsonb#>>'{config,c1266_free_narrative,enabled}'='true'
    AND (r.canonical_preimage::jsonb#>>'{config,c1266_free_narrative,master_session_id}'=w.master_session_id::text OR template_policy IS NOT NULL))
  AND (w.kind='director' OR(w.kind='narration' AND payload_version='mission-generic-narration/4')) THEN
  features:=features||jsonb_build_array('provider_output_retention_v1');
  IF w.kind='narration' THEN features:=features||jsonb_build_array('free_narrative_v1');END IF;
 END IF;
 IF source_scope='staff_mission' AND c5_stamp IS NOT NULL AND mission_generic_owner.native_intent_policy_v1(w.master_session_id) IS NOT NULL
  AND ((w.kind='director' AND payload_version IN('mission-director-work/3','mission-director-work/4'))
   OR(w.kind='narration' AND payload_version='mission-generic-narration/4' AND features?'free_narrative_v1' AND features?'provider_output_retention_v1')) THEN
  features:=features||jsonb_build_array('native_intent_resolution_v1');
 END IF;
 IF source_scope='staff_mission' AND c5_stamp IS NOT NULL AND w.kind='narration' AND payload_version='mission-generic-narration/3'
  AND w.payload->>'composition_kind' IN('combat_defense_resolved','combat_resolved_no_pending','combat_resolved_then_png_offensive','combat_exit')
  AND mission_generic_owner.manual_staff_scope_v1(w.master_session_id) IS NOT NULL
  AND (template_policy IS NOT NULL OR EXISTS(SELECT 1 FROM mission_factory_owner.editor_release_readiness rr WHERE rr.singleton AND rr.state='enabled' AND rr.revision_sha256=rr.observed_revision_sha256
   AND rr.canonical_preimage::jsonb#>>'{config,c1266_combat_snapshot_recovery,enabled}'='true' AND rr.canonical_preimage::jsonb#>>'{config,c1266_combat_snapshot_recovery,master_session_id}'=w.master_session_id::text
   AND rr.canonical_preimage::jsonb#>>'{config,c1266_combat_snapshot_recovery,ordinary_public_enabled}'='false')) THEN
  features:=features||jsonb_build_array('combat_snapshot_origin_budget_v1');
 END IF;
 -- Independently scoped speech is a frozen future-work capability, never a reinterpretation of old contracts.
 IF source_scope='staff_mission' AND c5_stamp IS NOT NULL AND template_policy IS NOT NULL
  AND source_attestation#>>'{role_intents,schema_version}'='mission-role-intent-attestation/4'
  AND source_attestation#>>'{role_intents,peer_confirmation,schema_version}'='mission-peer-confirmation-contract/2'
  AND EXISTS(SELECT 1 FROM mission_factory_owner.editor_release_readiness sp27_root WHERE sp27_root.singleton AND sp27_root.state='enabled'
   AND sp27_root.revision_sha256=sp27_root.observed_revision_sha256 AND sp27_root.revision_sha256=release_sha
   AND sp27_root.canonical_preimage::jsonb#>>'{config,c1266_npc_speech_context,schema_version}'='c1266-npc-speech-context-policy/1'
   AND sp27_root.canonical_preimage::jsonb#>'{config,c1266_npc_speech_context,enabled}'='true'::jsonb)
  AND ((w.kind='director' AND payload_version='mission-director-work/4')
   OR(w.kind='narration' AND payload_version='mission-generic-narration/4' AND features?'free_narrative_v1'
    AND EXISTS(SELECT 1 FROM mission_public_owner.work_contracts_v1 sp27_parent_contract
     JOIN mission_generic_owner.work_items sp27_parent ON sp27_parent.id=sp27_parent_contract.work_id
     WHERE sp27_parent.id=(source_attestation#>>'{role_intents,decision_work_id}')::uuid
      AND sp27_parent.master_session_id=w.master_session_id AND sp27_parent.kind='director'
      AND sp27_parent_contract.scope='staff_mission' AND sp27_parent_contract.payload_sha256=sp27_parent.payload_sha256
      AND sp27_parent_contract.contract_sha256=public.combat_v2_sha256(sp27_parent_contract.contract)
      AND sp27_parent_contract.contract->'features'?'npc_speech_context_v1'))) THEN
  features:=features||jsonb_build_array('npc_speech_context_v1');
 END IF;
 -- Wire opt-in is frozen ONLY in new contracts; existing contracts return above unchanged.
 IF w.kind='director' AND payload_version='mission-director-work/4' AND source_scope='staff_mission'
  AND c5_stamp IS NOT NULL AND template_policy IS NOT NULL
  AND source_attestation#>>'{role_intents,schema_version}'='mission-role-intent-attestation/4'
  AND EXISTS(SELECT 1 FROM mission_factory_owner.editor_release_readiness np39_root
   WHERE np39_root.singleton AND np39_root.state='enabled'
   AND np39_root.revision_sha256=np39_root.observed_revision_sha256 AND np39_root.revision_sha256=release_sha
   AND np39_root.canonical_preimage::jsonb#>>'{config,c1266_numeric_peer_wire,schema_version}'='c1266-numeric-peer-wire-policy/1'
   AND np39_root.canonical_preimage::jsonb#>'{config,c1266_numeric_peer_wire,enabled}'='true'::jsonb
   AND np39_root.canonical_preimage::jsonb#>>'{config,c1266_numeric_peer_wire,wire_version}'='mission-director-peer-confirmation/3') THEN
  features:=features||jsonb_build_array('numeric_peer3_wire_v1');
 END IF;
 -- A distinct provider-output capability for the one approved paid incomplete successor.
 -- Source financial attestation remains sealed and unchanged; no proof getter is called while issuing this contract.
 IF w.id='4fb5ea83-f90a-4b76-a6f5-722641d9da43'::uuid AND w.master_session_id='4c7b05e0-b5b7-4586-9aa9-2a77ae03deb4'::uuid
 AND w.kind='director' AND payload_version='mission-director-work/4' AND source_scope='staff_mission'
 AND template_policy IS NOT NULL AND source_attestation#>>'{execution_authority,schema_version}'='c1266-work-execution-attestation/3'
 AND EXISTS(SELECT 1 FROM mission_factory_owner.editor_release_readiness rr50
 WHERE rr50.singleton AND rr50.scope='staff' AND rr50.state='enabled'
 AND rr50.revision_sha256=rr50.observed_revision_sha256 AND rr50.revision_sha256=release_sha
 AND rr50.revision_sha256=encode(extensions.digest(convert_to(rr50.canonical_preimage,'UTF8'),'sha256'),'hex')
 AND rr50.canonical_preimage::jsonb#>'{config,c1266_director_incomplete_recovery}'='{"schema_version":"c1266-director-incomplete-recovery/1","enabled":true,"master_session_id":"4c7b05e0-b5b7-4586-9aa9-2a77ae03deb4","old_work_id":"48df8786-3b66-4b44-a1bd-c92473ee5e55","old_payload_sha256":"58d06c515d3ea564a71075b69596d9823e4453688e50b64d7c061ca3f7a648ca","raw_sha256":"f2918095e64fabbd6910ec8566b2e2ccb8193be4ac5d6c0fc3fa8b1477d55c88","successor_work_id":"4fb5ea83-f90a-4b76-a6f5-722641d9da43","max_successors":1,"target_output_tokens":32000}'::jsonb)
 AND EXISTS(SELECT 1 FROM mission_generic_owner.work_items parent50
 JOIN mission_generic_owner.unified_source_windows src50 ON src50.id=parent50.authority_receipt_id AND src50.work_id=parent50.id
 JOIN mission_generic_owner.unified_source_windows child50 ON child50.id=w.authority_receipt_id AND child50.work_id=w.id
 JOIN mission_narrative_internal.dispatch_audit prepared50 ON prepared50.receipt_id=parent50.dispatch_receipt_id AND prepared50.event_code='staff_director_incomplete_prepared_v1'
 JOIN mission_narrative_internal.dispatch_audit issued50 ON issued50.receipt_id=parent50.dispatch_receipt_id AND issued50.event_code='staff_director_incomplete_reissued_v1'
 WHERE parent50.id='48df8786-3b66-4b44-a1bd-c92473ee5e55'::uuid AND parent50.master_session_id=w.master_session_id
 AND parent50.kind='director' AND parent50.state='failed' AND parent50.result->'failure_codes'='["MISSION_PROVIDER_INCOMPLETE"]'::jsonb
 AND parent50.payload_sha256='58d06c515d3ea564a71075b69596d9823e4453688e50b64d7c061ca3f7a648ca'
 AND src50.superseded_at IS NOT NULL AND src50.superseded_reason='staff_failed_director_incomplete_retry' AND src50.consumed_message_id IS NULL
 AND child50.role_ids=src50.role_ids AND child50.context->>'source_revision'=src50.context->>'source_revision'
 AND child50.master_session_id=w.master_session_id AND child50.step_key=src50.step_key AND child50.run_control_version=src50.run_control_version
 AND child50.source_sha256=w.payload_sha256 AND child50.context=w.payload->'context'
 AND prepared50.details->>'old_work_id'=parent50.id::text AND prepared50.details->>'successor_work_id'=w.id::text
 AND issued50.details->>'prepared_sha256'=public.combat_v2_sha256(prepared50.details)
 AND issued50.details->>'successor_work_id'=w.id::text AND issued50.details->>'successor_payload_sha256'=w.payload_sha256)
 THEN features:=features||jsonb_build_array('director_output_32k_v1');END IF;
 doc:=jsonb_build_object('schema_version',case when c5_proof IS NOT NULL OR source_scope='public_quest' then 'mission-narrative-admission/3' else 'mission-narrative-admission/2' end,'scope',source_scope,
  'release_sha256',release_sha,'work_id',w.id,'master_session_id',w.master_session_id,
  'definition_sha256',w.definition_sha256,'payload_sha256',w.payload_sha256,
  'payload_schema_version',payload_version,'editorial_profile',profile,'features',features,'source_attestation',source_attestation);
 insert into mission_public_owner.work_contracts_v1(work_id,master_session_id,scope,release_sha256,
 definition_sha256,payload_sha256,contract,contract_sha256)
 values(w.id,w.master_session_id,source_scope,release_sha,w.definition_sha256,w.payload_sha256,doc,public.combat_v2_sha256(doc));
 return doc;
end $$;
CREATE OR REPLACE FUNCTION mission_narrative_internal.scene_entry_surface_v1(p_session uuid, p_user uuid) RETURNS jsonb LANGUAGE plpgsql STABLE SECURITY DEFINER SET search_path TO '' AS $$
DECLARE r mission_narrative_internal.scene_runtime_v1%ROWTYPE; m public.master_v2_sessions;
 operative boolean:=false; entitled boolean:=false; legal boolean:=false; rev bigint;
BEGIN
 SELECT * INTO r FROM mission_narrative_internal.scene_runtime_v1 WHERE master_session_id=p_session AND is_active;
 SELECT * INTO m FROM public.master_v2_sessions WHERE id=p_session;
 entitled:=p_user IS NOT NULL AND EXISTS(SELECT 1 FROM public.master_v2_participants p
  JOIN public.characters c ON c.id=p.character_id AND c.user_id=p.user_id_snapshot
  WHERE p.session_id=p_session AND p.user_id_snapshot=p_user AND p.left_at IS NULL AND p.engagement_state='attivo');
 operative:=coalesce(entitled AND m.owner_kind='ai_service' AND m.stato='in_corso'
  AND m.closed_at IS NULL AND m.suspended_at IS NULL AND r.id IS NOT NULL
  AND r.arena_phase_key=r.current_phase_key
  AND r.arena_receipt->>'schema_version'='universal-arena-state/1'
  AND r.arena_receipt->>'status'='ready'
  AND r.arena_receipt->>'master_session_id'=p_session::text
  AND r.arena_receipt_sha256=public.combat_v2_sha256(r.arena_receipt)
  AND nullif(r.encounter_key,'') IS NOT NULL,false);
 IF operative THEN
  rev:=('x'||substr(public.combat_v2_sha256(jsonb_build_object('scene_id',r.id,
   'state_version',r.state_version,'current_phase_key',r.current_phase_key,'turn_owner',r.turn_owner,
   'arena_receipt_sha256',r.arena_receipt_sha256,'last_publication_id',r.last_publication_id)),1,13))::bit(52)::bigint;
 END IF;
 legal:=operative AND r.mode='narrative' AND r.turn_owner='players'
  AND r.last_publication_id IS NOT NULL AND EXISTS(SELECT 1 FROM public.messages msg
   WHERE msg.id=r.last_publication_id AND msg.location_id=m.location_id
   AND encode(extensions.digest(convert_to(msg.body,'UTF8'),'sha256'),'hex')=r.last_publication_sha256)
  AND NOT EXISTS(SELECT 1 FROM mission_narrative_internal.scene_sources_v1 src
   WHERE src.scene_id=r.id AND src.published_message_id IS NULL AND src.technical_receipt IS NULL AND src.retired_at IS NULL);
 RETURN jsonb_build_object('schema_version','mission-narrative-combat-surface/1',
  'map_operational',operative,'can_open',operative AND r.mode='combat','can_prepare',coalesce(legal,false),'entry_revision',rev);
END $$;
REVOKE ALL PRIVILEGES ON FUNCTION mission_narrative_internal.scene_entry_surface_v1 (uuid, uuid) FROM PUBLIC, anon, authenticated;
GRANT EXECUTE ON FUNCTION mission_narrative_internal.scene_entry_surface_v1 (uuid, uuid) TO service_role;
CREATE OR REPLACE FUNCTION mission_narrative_internal.scene_entry_state_v1(p_session uuid, p_user uuid, p_request uuid = NULL) RETURNS jsonb LANGUAGE plpgsql STABLE SECURITY DEFINER SET search_path TO '' AS $$
DECLARE r mission_narrative_internal.scene_runtime_v1%ROWTYPE; src mission_narrative_internal.scene_sources_v1%ROWTYPE;
 surface jsonb; state text; why text; ready boolean:=false; receipt jsonb; run public.mission_run_state;
BEGIN
 IF p_user IS NULL OR p_user IS DISTINCT FROM auth.uid() THEN RAISE EXCEPTION 'REGIA_ACCESS_DENIED' USING ERRCODE='42501';END IF;
 surface:=mission_narrative_internal.scene_entry_surface_v1(p_session,p_user);
 SELECT * INTO STRICT r FROM mission_narrative_internal.scene_runtime_v1 WHERE master_session_id=p_session AND is_active;
 IF NOT EXISTS(SELECT 1 FROM public.master_v2_participants p JOIN public.characters c ON c.id=p.character_id AND c.user_id=p.user_id_snapshot
  WHERE p.session_id=p_session AND p.user_id_snapshot=p_user AND p.left_at IS NULL AND p.engagement_state='attivo')
 THEN RAISE EXCEPTION 'REGIA_ACCESS_DENIED' USING ERRCODE='42501';END IF;
 SELECT * INTO run FROM public.mission_run_state WHERE master_session_id=p_session;
 IF p_request IS NOT NULL THEN
  SELECT * INTO src FROM mission_narrative_internal.scene_sources_v1
   WHERE id=mission_ai_service_owner.uuid5(r.id,'combat-entry:'||p_request::text) AND scene_id=r.id AND request_kind='combat_entry';
  IF src.id IS NOT NULL AND src.actor_user_id IS DISTINCT FROM p_user THEN RAISE EXCEPTION 'REGIA_REQUEST_CONFLICT' USING ERRCODE='22023';END IF;
 END IF;
 receipt:=src.technical_receipt;
 IF receipt IS NOT NULL AND r.mode='combat' THEN RETURN jsonb_set(public.regia_combat_entry_state_v1(p_session),'{request_key}',to_jsonb(p_request),true);END IF;
 IF src.id IS NOT NULL AND receipt IS NULL AND src.retired_at IS NULL THEN state:='preparing';why:=NULL;
 ELSIF src.retired_at IS NOT NULL THEN state:='unavailable';why:=src.retired_reason;
 ELSIF receipt IS NOT NULL THEN state:='prepared';why:='REGIA_TURN_AUTHORITY_REQUIRED';
 ELSIF p_request IS NOT NULL AND src.id IS NULL THEN state:='not_found';why:='REGIA_OPERATION_NOT_FOUND';
 ELSIF (surface->>'can_prepare')::boolean THEN state:='ready';
 ELSE state:='unavailable';why:=CASE WHEN r.turn_owner='fato' OR EXISTS(SELECT 1 FROM mission_narrative_internal.scene_sources_v1 s
  WHERE s.scene_id=r.id AND s.request_kind='narration' AND s.published_message_id IS NULL AND s.technical_receipt IS NULL AND s.retired_at IS NULL)
  THEN 'fato_turn' ELSE 'not_player_turn' END;END IF;
 RETURN jsonb_build_object('schema','regia-combat-entry/1','status',state,'master_session_id',p_session,
  'step_key',r.current_phase_key,'run_control_version',run.control_version,'entry_revision',surface->'entry_revision',
  'request_key',CASE WHEN state='not_found' THEN NULL ELSE p_request END,'can_prepare',state='ready','can_open_panel',false,'reason_code',why,
  'encounter_id',NULL,'opening_round_id',NULL,'public_round_id',NULL,'publication_id',NULL,
  'permissions',jsonb_build_object('main',false,'defense',false,'reaction',false));
END $$;
REVOKE ALL PRIVILEGES ON FUNCTION mission_narrative_internal.scene_entry_state_v1 (uuid, uuid, uuid) FROM PUBLIC, anon, authenticated, service_role;
CREATE OR REPLACE FUNCTION mission_narrative_internal.scene_player_entry_prepare_v1(p_session uuid, p_expected bigint, p_request uuid) RETURNS jsonb LANGUAGE plpgsql SECURITY DEFINER SET search_path TO '' AS $$
DECLARE r mission_narrative_internal.scene_runtime_v1%ROWTYPE; src mission_narrative_internal.scene_sources_v1%ROWTYPE;
 rootrow mission_generic_owner.event_outbox_v1%ROWTYPE; run public.mission_run_state; m public.master_v2_sessions;
 surface jsonb; command jsonb; source_sha text; sid uuid; ek uuid; cfg jsonb; request_id bigint;
BEGIN
 IF auth.uid() IS NULL OR p_session IS NULL OR p_expected IS NULL OR p_request IS NULL THEN RAISE EXCEPTION 'REGIA_ENTRY_INPUT_INVALID' USING ERRCODE='22023';END IF;
 -- Whole-source order: location -> cursor -> cache -> Master/run. No Fato is retired.
 SELECT * INTO STRICT m FROM public.master_v2_sessions WHERE id=p_session;
 PERFORM 1 FROM public.locations WHERE id=m.location_id FOR UPDATE;
 PERFORM 1 FROM mission_generic_owner.role_window_cursors WHERE master_session_id=p_session FOR UPDATE;
 SELECT * INTO STRICT r FROM mission_narrative_internal.scene_runtime_v1 WHERE master_session_id=p_session AND is_active FOR UPDATE;
 PERFORM public.master_v2_lock_scope(p_session);
 SELECT * INTO STRICT run FROM public.mission_run_state WHERE master_session_id=p_session FOR UPDATE;
 sid:=mission_ai_service_owner.uuid5(r.id,'combat-entry:'||p_request::text);
 SELECT * INTO src FROM mission_narrative_internal.scene_sources_v1 WHERE id=sid FOR UPDATE;
 IF src.id IS NOT NULL THEN
  IF src.actor_user_id IS DISTINCT FROM auth.uid() OR src.request_kind<>'combat_entry'
   OR src.technical_request->>'expected_entry_revision' IS DISTINCT FROM p_expected::text
  THEN RAISE EXCEPTION 'REGIA_REQUEST_CONFLICT' USING ERRCODE='22023';END IF;
  RETURN mission_narrative_internal.scene_entry_state_v1(p_session,auth.uid(),p_request);
 END IF;
 surface:=mission_narrative_internal.scene_entry_surface_v1(p_session,auth.uid());
 IF coalesce((surface->>'can_prepare')::boolean,false) IS NOT TRUE THEN
  RETURN jsonb_set(jsonb_set(mission_narrative_internal.scene_entry_state_v1(p_session,auth.uid(),NULL),'{request_key}',to_jsonb(p_request),true),'{can_open_panel}',surface->'can_open',true);
 END IF;
 IF (surface->>'entry_revision')::bigint IS DISTINCT FROM p_expected OR run.current_step_key<>r.current_phase_key OR run.run_phase<>'in_corso'
 THEN RAISE EXCEPTION 'REGIA_ENTRY_STALE' USING ERRCODE='40001';END IF;
 SELECT * INTO rootrow FROM mission_generic_owner.event_outbox_v1 WHERE master_session_id=p_session AND event_domain='start' AND event_key=root_event_key AND event_version=1;
 SELECT rr.canonical_preimage::jsonb#>'{config,c1266_server_events}' INTO cfg FROM mission_factory_owner.editor_release_readiness rr
  WHERE rr.singleton AND rr.state='enabled' AND rr.scope='staff' AND rr.revision_sha256=rr.observed_revision_sha256;
 IF rootrow.event_key IS NULL OR cfg->>'schema_version' IS DISTINCT FROM 'c1266-server-events/1' OR cfg->'enabled' IS DISTINCT FROM 'true'::jsonb
  OR cfg->>'endpoint' IS DISTINCT FROM 'https://tyhyxkslteigibktluml.supabase.co/functions/v1/mission_generic_ai'
  OR mission_generic_owner.manual_staff_scope_v1(p_session) IS NULL
 THEN RAISE EXCEPTION 'REGIA_ENTRY_UNAVAILABLE' USING ERRCODE='42501';END IF;
 command:=jsonb_build_object('schema_version','scene-player-combat-command/1','master_session_id',p_session,'scene_id',r.id,
  'actor_user_id',auth.uid(),'request_key',p_request,'expected_entry_revision',p_expected,'run_control_version',run.control_version,
  'encounter_key',r.encounter_key,'arena_receipt_sha256',r.arena_receipt_sha256,'phase_key',r.current_phase_key);
 source_sha:=public.combat_v2_sha256(command);
 INSERT INTO mission_narrative_internal.scene_sources_v1(id,scene_id,request_kind,work_id,actor_user_id,state_version,source_revision,
  snapshot_sha256,accepted_role_ids,accepted_roles_sha256,last_publication_id,last_publication_sha256,current_phase_key,
  scene_memory_sha256,payload_sha256,technical_request)
 VALUES(sid,r.id,'combat_entry',NULL,auth.uid(),r.state_version,source_sha,r.snapshot_sha256,ARRAY[]::uuid[],public.combat_v2_sha256('[]'::jsonb),
  r.last_publication_id,r.last_publication_sha256,r.current_phase_key,public.combat_v2_sha256(coalesce(r.scene_memory,'null'::jsonb)),source_sha,command);
 ek:=mission_ai_service_owner.uuid5(sid,'server-event:native-input');
 INSERT INTO mission_generic_owner.event_outbox_v1(event_key,event_version,master_session_id,event_domain,source_id,source_sha256,
  root_event_key,root_request_key,root_principal,root_receipt_sha256)
 VALUES(ek,1,p_session,'native_input',sid,source_sha,rootrow.root_event_key,rootrow.root_request_key,rootrow.root_principal,rootrow.root_receipt_sha256);
 UPDATE mission_narrative_internal.scene_runtime_v1 SET mode='combat_pending',updated_at=clock_timestamp() WHERE id=r.id;
 request_id:=net.http_post(cfg->>'endpoint',jsonb_build_object('schema_version','mission-event-wake/2','event_key',ek,'event_version',1),
  '{}'::jsonb,jsonb_build_object('Content-Type','application/json','x-tus-server-event','event42'),5000);
 UPDATE mission_generic_owner.event_outbox_v1 SET wake_request_id=request_id WHERE event_key=ek AND event_version=1;
 RETURN mission_narrative_internal.scene_entry_state_v1(p_session,auth.uid(),p_request);
END $$;
REVOKE ALL PRIVILEGES ON FUNCTION mission_narrative_internal.scene_player_entry_prepare_v1 (uuid, bigint, uuid) FROM PUBLIC, anon, authenticated, service_role;
CREATE OR REPLACE FUNCTION mission_narrative_internal.scene_open_current_v1(p_source uuid, p_request uuid) RETURNS jsonb LANGUAGE plpgsql SECURITY DEFINER SET search_path TO '' AS $$
DECLARE r mission_narrative_internal.scene_runtime_v1%ROWTYPE; src mission_narrative_internal.scene_sources_v1%ROWTYPE;
 run public.mission_run_state; m public.master_v2_sessions; native jsonb; receipt jsonb; enc uuid; rid uuid; expected_schema text;
BEGIN
 PERFORM mission_ai_board_owner.service_only();
 SELECT * INTO STRICT src FROM mission_narrative_internal.scene_sources_v1 WHERE id=p_source;
 SELECT * INTO STRICT r FROM mission_narrative_internal.scene_runtime_v1 WHERE id=src.scene_id;
 SELECT * INTO STRICT m FROM public.master_v2_sessions WHERE id=r.master_session_id;
 PERFORM 1 FROM public.locations WHERE id=m.location_id FOR UPDATE;
 PERFORM 1 FROM mission_generic_owner.role_window_cursors WHERE master_session_id=m.id FOR UPDATE;
 SELECT * INTO STRICT r FROM mission_narrative_internal.scene_runtime_v1 WHERE id=src.scene_id FOR UPDATE;
 PERFORM public.master_v2_lock_scope(m.id);
 SELECT * INTO STRICT src FROM mission_narrative_internal.scene_sources_v1 WHERE id=p_source FOR UPDATE;
 SELECT * INTO STRICT run FROM public.mission_run_state WHERE master_session_id=m.id FOR UPDATE;
 IF src.technical_receipt IS NOT NULL THEN
  IF src.technical_receipt->>'request_key' IS DISTINCT FROM p_request::text THEN RAISE EXCEPTION 'SCENE56_ENTRY_REPLAY_CONFLICT' USING ERRCODE='PT409';END IF;
  RETURN src.technical_receipt;
 END IF;
 IF p_request IS NULL OR NOT r.is_active OR m.owner_kind<>'ai_service' OR m.master_user IS NOT NULL OR m.stato<>'in_corso'
  OR m.closed_at IS NOT NULL OR m.suspended_at IS NOT NULL OR run.run_phase<>'in_corso'
  OR public.combat_v2_sha256(r.snapshot) IS DISTINCT FROM r.snapshot_sha256
  OR r.current_phase_key<>run.current_step_key OR r.arena_phase_key IS DISTINCT FROM r.current_phase_key
  OR r.arena_receipt->>'schema_version' IS DISTINCT FROM 'universal-arena-state/1'
  OR r.arena_receipt->>'status' IS DISTINCT FROM 'ready' OR r.arena_receipt->>'master_session_id' IS DISTINCT FROM m.id::text
  OR r.arena_receipt_sha256 IS DISTINCT FROM public.combat_v2_sha256(r.arena_receipt)
  OR nullif(r.encounter_key,'') IS NULL OR src.retired_at IS NOT NULL
  OR r.last_publication_id IS NULL OR NOT EXISTS(SELECT 1 FROM public.messages msg WHERE msg.id=r.last_publication_id
   AND msg.location_id=m.location_id AND encode(extensions.digest(convert_to(msg.body,'UTF8'),'sha256'),'hex')=r.last_publication_sha256)
 THEN RAISE EXCEPTION 'SCENE56_ENTRY_CONTEXT_CHANGED' USING ERRCODE='PT409';END IF;
 IF src.request_kind='combat_entry' THEN
  IF r.mode<>'combat_pending' OR r.turn_owner<>'players' OR src.work_id IS NOT NULL
   OR src.state_version<>r.state_version OR src.current_phase_key<>r.current_phase_key
   OR src.snapshot_sha256<>r.snapshot_sha256 OR src.last_publication_id IS DISTINCT FROM r.last_publication_id
   OR src.last_publication_sha256 IS DISTINCT FROM r.last_publication_sha256
   OR src.scene_memory_sha256<>public.combat_v2_sha256(coalesce(r.scene_memory,'null'::jsonb))
   OR src.technical_request->>'request_key' IS DISTINCT FROM p_request::text
   OR src.technical_request->>'actor_user_id' IS DISTINCT FROM src.actor_user_id::text
   OR src.technical_request->>'run_control_version' IS DISTINCT FROM run.control_version::text
   OR src.technical_request->>'arena_receipt_sha256' IS DISTINCT FROM r.arena_receipt_sha256
   OR src.source_revision<>public.combat_v2_sha256(src.technical_request) OR src.payload_sha256<>src.source_revision
   OR EXISTS(SELECT 1 FROM mission_narrative_internal.scene_sources_v1 other WHERE other.scene_id=r.id
    AND other.id<>src.id AND other.published_message_id IS NULL AND other.technical_receipt IS NULL AND other.retired_at IS NULL)
   OR NOT EXISTS(SELECT 1 FROM public.master_v2_participants p JOIN public.characters ch ON ch.id=p.character_id AND ch.user_id=p.user_id_snapshot
    WHERE p.session_id=m.id AND p.user_id_snapshot=src.actor_user_id AND p.left_at IS NULL AND p.engagement_state='attivo')
  THEN RAISE EXCEPTION 'SCENE56_ENTRY_ACTOR_OR_TURN_CHANGED' USING ERRCODE='42501';END IF;
 ELSIF src.request_kind IN('narration','initial_opening') THEN
  IF r.turn_owner<>'fato' OR src.work_id IS NULL
   OR src.publication_next_step IS DISTINCT FROM 'combat:'||r.current_phase_key
   OR src.message_permit_txid IS DISTINCT FROM txid_current() OR src.message_permit_backend IS DISTINCT FROM pg_backend_pid()
   OR r.last_publication_id IS DISTINCT FROM src.message_permit_id OR r.last_publication_sha256 IS DISTINCT FROM src.message_permit_sha256
   OR src.published_message_id IS DISTINCT FROM r.last_publication_id OR NOT EXISTS(SELECT 1 FROM mission_generic_owner.work_items w
   WHERE w.id=src.work_id AND w.master_session_id=m.id AND w.kind='narration' AND w.state='provider_started'
    AND w.authority_receipt_id=src.id AND w.payload->>'schema_version'='mission-narrative-scene/1')
  THEN RAISE EXCEPTION 'SCENE56_ENTRY_NARRATION_AUTHORITY' USING ERRCODE='42501';END IF;
 ELSE RAISE EXCEPTION 'SCENE56_ENTRY_SOURCE_KIND' USING ERRCODE='22023';END IF;
 -- Genuine service capability, real initializer, actual arena and simulated pools. No auth impersonation.
 native:=public.mission_generic_combat_open_v1(m.id,r.encounter_key,run.control_version,p_request);
 enc:=(native->>'encounter_id')::uuid;rid:=(native#>>'{combat,data,round_id}')::uuid;
 expected_schema:=CASE WHEN run.source_kind='quest' THEN 'mission-factory-quest-encounter/1' ELSE 'mission-generic-encounter/1' END;
 IF native->>'schema_version' IS DISTINCT FROM expected_schema OR enc IS NULL OR rid IS NULL
  OR NOT EXISTS(SELECT 1 FROM public.combat_v2_sessions cs JOIN public.combat_v2_rounds rr ON rr.session_id=cs.id
   WHERE cs.id=enc AND rr.id=rid AND cs.master_session_id=m.id AND cs.state='in_corso' AND NOT cs.lesiva)
  OR NOT combat_panel_private.uses_simulated_pools(enc) OR public.combat_v2_values_written(enc)
  OR NOT EXISTS(SELECT 1 FROM mission_generic_owner.encounters e WHERE e.encounter_id=enc AND e.master_session_id=m.id
   AND e.request_key=p_request AND e.open_receipt=native)
 THEN RAISE EXCEPTION 'SCENE56_ENTRY_NATIVE_UNPROTECTED' USING ERRCODE='42501';END IF;
 receipt:=jsonb_build_object('schema_version','mission-narrative-combat-opening/1','source_id',src.id,'scene_id',r.id,
  'actor_user_id',src.actor_user_id,'request_key',p_request,'encounter_id',enc,'opening_round_id',rid,
  'publication_id',r.last_publication_id,'publication_sha256',r.last_publication_sha256,
  'state_version_before',r.state_version,'state_version_after',r.state_version+1,'phase_key',r.current_phase_key,
  'arena_receipt_sha256',r.arena_receipt_sha256,'native_open_sha256',public.combat_v2_sha256(native));
 UPDATE mission_narrative_internal.scene_sources_v1 SET technical_receipt=receipt,
  published_message_id=CASE WHEN request_kind='combat_entry' THEN r.last_publication_id ELSE published_message_id END WHERE id=src.id;
 UPDATE mission_narrative_internal.scene_runtime_v1 SET mode='combat',turn_owner='combat',state_version=state_version+1,
  updated_at=clock_timestamp() WHERE id=r.id;
 RETURN receipt;
END $$;
REVOKE ALL PRIVILEGES ON FUNCTION mission_narrative_internal.scene_open_current_v1 (uuid, uuid) FROM PUBLIC, anon, authenticated;
GRANT EXECUTE ON FUNCTION mission_narrative_internal.scene_open_current_v1 (uuid, uuid) TO service_role;
CREATE OR REPLACE FUNCTION mission_narrative_internal.scene_player_entry_event_v1(p_event_key uuid, p_event_version bigint, p_claim_id uuid) RETURNS jsonb LANGUAGE plpgsql SECURITY DEFINER SET search_path TO '' AS $$
DECLARE e mission_generic_owner.event_outbox_v1%ROWTYPE; src mission_narrative_internal.scene_sources_v1%ROWTYPE; receipt jsonb;
BEGIN
 PERFORM mission_ai_board_owner.service_only();
 SELECT * INTO STRICT e FROM mission_generic_owner.event_outbox_v1 WHERE event_key=p_event_key AND event_version=p_event_version FOR UPDATE;
 IF e.event_domain<>'native_input' THEN RETURN NULL;END IF;
 SELECT * INTO src FROM mission_narrative_internal.scene_sources_v1 WHERE id=e.source_id AND request_kind='combat_entry';
 IF src.id IS NULL THEN RETURN NULL;END IF;
 IF e.claim_id IS DISTINCT FROM p_claim_id OR p_claim_id IS NULL OR e.state<>'running' OR e.claim_expires_at<=clock_timestamp()
  OR e.event_version<>1 OR e.event_key<>mission_ai_service_owner.uuid5(src.id,'server-event:native-input')
  OR e.source_sha256<>src.source_revision OR e.source_sha256<>public.combat_v2_sha256(src.technical_request)
  OR src.technical_request->>'master_session_id' IS DISTINCT FROM e.master_session_id::text
  OR src.actor_user_id::text IS DISTINCT FROM src.technical_request->>'actor_user_id'
 THEN RAISE EXCEPTION 'SCENE56_ENTRY_EVENT_AUTHORITY' USING ERRCODE='42501';END IF;
 receipt:=mission_narrative_internal.scene_open_current_v1(src.id,(src.technical_request->>'request_key')::uuid);
 -- Existing deferred event_outbox hint/settle publishes receipt readiness after commit.
 RETURN jsonb_build_object('schema_version','mission-event-next/1','event_key',e.event_key,'event_version',e.event_version,
  'claim_id',e.claim_id,'master_session_id',e.master_session_id,'state','terminal','request',NULL,'native_claim',NULL);
END $$;
REVOKE ALL PRIVILEGES ON FUNCTION mission_narrative_internal.scene_player_entry_event_v1 (uuid, bigint, uuid) FROM PUBLIC, anon, authenticated;
GRANT EXECUTE ON FUNCTION mission_narrative_internal.scene_player_entry_event_v1 (uuid, bigint, uuid) TO service_role;
CREATE OR REPLACE FUNCTION mission_narrative_internal.scene_opening_receipt_v1(p_round uuid) RETURNS jsonb LANGUAGE plpgsql STABLE SECURITY DEFINER SET search_path TO '' AS $$
DECLARE r mission_narrative_internal.scene_runtime_v1%ROWTYPE; src mission_narrative_internal.scene_sources_v1%ROWTYPE; proof jsonb;
BEGIN
 SELECT cache.* INTO r FROM public.combat_v2_rounds rr JOIN public.combat_v2_sessions cs ON cs.id=rr.session_id
  JOIN mission_narrative_internal.scene_runtime_v1 cache ON cache.master_session_id=cs.master_session_id AND cache.is_active WHERE rr.id=p_round;
 IF r.id IS NULL THEN RETURN NULL;END IF;
 SELECT s.* INTO src FROM mission_narrative_internal.scene_sources_v1 s WHERE s.scene_id=r.id
  AND s.technical_receipt->>'opening_round_id'=p_round::text
  AND s.technical_receipt->>'schema_version'='mission-narrative-combat-opening/1' AND s.retired_at IS NULL;
 -- A later genuine Native round is governed by its existing Unified Window.
 -- No opening source for this round means this scoped adapter has no authority.
 IF src.id IS NULL THEN RETURN NULL;END IF;
 IF EXISTS(SELECT 1 FROM public.combat_v2_rounds original_round
  JOIN public.combat_v2_rounds later_round ON later_round.session_id=original_round.session_id AND later_round.round_no>original_round.round_no
  JOIN public.combat_v2_sessions cs ON cs.id=later_round.session_id AND cs.master_session_id=r.master_session_id
  JOIN mission_generic_owner.unified_round_windows uw ON uw.round_id=later_round.id AND uw.master_session_id=r.master_session_id
  JOIN mission_generic_owner.unified_batches batch ON batch.id=uw.batch_id AND batch.master_session_id=r.master_session_id
   AND batch.encounter_id=cs.id AND batch.state='published' AND batch.message_id=uw.publication_id
  JOIN public.messages msg ON msg.id=uw.publication_id AND msg.location_id=cs.location_id
  WHERE original_round.id=p_round AND uw.publication_id IS NOT NULL)
 THEN RETURN NULL;END IF;
 proof:=src.technical_receipt;
 IF proof IS NULL OR r.mode<>'combat' 
  OR proof->>'scene_id' IS DISTINCT FROM r.id::text OR proof->>'source_id' IS DISTINCT FROM src.id::text
  OR proof->>'actor_user_id' IS DISTINCT FROM src.actor_user_id::text
  OR proof->>'state_version_after' IS DISTINCT FROM r.state_version::text
  OR proof->>'phase_key' IS DISTINCT FROM r.current_phase_key
  OR proof->>'publication_id' IS DISTINCT FROM r.last_publication_id::text
  OR proof->>'publication_sha256' IS DISTINCT FROM r.last_publication_sha256
  OR proof->>'arena_receipt_sha256' IS DISTINCT FROM r.arena_receipt_sha256
  OR NOT EXISTS(SELECT 1 FROM public.combat_v2_rounds rr JOIN public.combat_v2_sessions cs ON cs.id=rr.session_id
   JOIN mission_generic_owner.encounters enc ON enc.encounter_id=cs.id AND enc.master_session_id=cs.master_session_id
   JOIN public.messages msg ON msg.id=r.last_publication_id AND msg.location_id=cs.location_id
   WHERE rr.id=p_round AND rr.session_id=(proof->>'encounter_id')::uuid AND cs.master_session_id=r.master_session_id
    AND cs.state='in_corso' AND NOT cs.lesiva AND enc.request_key=(proof->>'request_key')::uuid
    AND public.combat_v2_sha256(enc.open_receipt)=proof->>'native_open_sha256'
    AND encode(extensions.digest(convert_to(msg.body,'UTF8'),'sha256'),'hex')=r.last_publication_sha256)
  OR NOT combat_panel_private.uses_simulated_pools((proof->>'encounter_id')::uuid)
  OR public.combat_v2_values_written((proof->>'encounter_id')::uuid)
 THEN RAISE EXCEPTION 'SCENE56_OPENING_RECEIPT_OR_TURN_INVALID' USING ERRCODE='42501';END IF;
 RETURN proof;
END $$;
REVOKE ALL PRIVILEGES ON FUNCTION mission_narrative_internal.scene_opening_receipt_v1 (uuid) FROM PUBLIC, anon, authenticated, service_role;
CREATE OR REPLACE FUNCTION public.regia_combat_entry_prepare_v1(p_master_session uuid, p_expected_revision bigint, p_request_key uuid) RETURNS jsonb LANGUAGE plpgsql SECURITY DEFINER SET search_path TO '' AS $$
DECLARE m public.master_v2_sessions%ROWTYPE; run public.mission_run_state%ROWTYPE;
 he mission_creation_owner.human_encounters%ROWTYPE;
 e exam_human_private.requests%ROWTYPE; exam_open exam_human_private.combat_openings%ROWTYPE;
 cs public.combat_v2_sessions%ROWTYPE;
 old mission_generic_owner.regia_entry_requests_v1%ROWTYPE;
 state jsonb; opened jsonb; enc uuid; rid uuid;
BEGIN
 IF EXISTS(SELECT 1 FROM mission_narrative_internal.scene_runtime_v1 cache JOIN public.master_v2_sessions cm ON cm.id=cache.master_session_id WHERE cache.master_session_id=p_master_session AND cache.is_active AND cm.owner_kind='ai_service') THEN RETURN mission_narrative_internal.scene_player_entry_prepare_v1(p_master_session,p_expected_revision,p_request_key);END IF;
 IF p_request_key IS NULL OR p_expected_revision IS NULL OR p_master_session IS NULL
 THEN RAISE EXCEPTION 'REGIA_ENTRY_INPUT_INVALID' USING ERRCODE='22023'; END IF;
 state:=public.regia_combat_entry_state_v1(p_master_session);
 SELECT * INTO m FROM public.master_v2_sessions WHERE id=p_master_session FOR UPDATE;
 SELECT * INTO run FROM public.mission_run_state WHERE master_session_id=m.id FOR UPDATE;
 state:=public.regia_combat_entry_state_v1(m.id);
 SELECT * INTO old FROM mission_generic_owner.regia_entry_requests_v1
  WHERE master_session_id=m.id AND request_key=p_request_key FOR UPDATE;
 IF old.request_key IS NOT NULL THEN
  IF old.principal_id IS DISTINCT FROM auth.uid()
    OR old.expected_revision IS DISTINCT FROM p_expected_revision THEN
   RAISE EXCEPTION 'REGIA_REQUEST_CONFLICT' USING ERRCODE='22023'; END IF;
  IF old.step_key IS DISTINCT FROM state->>'step_key'
    OR old.run_control_version IS DISTINCT FROM (state->>'run_control_version')::bigint
  THEN RAISE EXCEPTION 'REGIA_ENTRY_STALE' USING ERRCODE='40001'; END IF;
  state:=public.regia_combat_entry_state_v1(m.id);
  RETURN jsonb_set(state,'{request_key}',to_jsonb(p_request_key),true);
 END IF;
 IF (state->>'entry_revision')::bigint IS DISTINCT FROM p_expected_revision
  OR state->>'status' NOT IN ('ready','prepared','open')
  OR coalesce((state->>'can_prepare')::boolean,false) IS NOT TRUE
 THEN RAISE EXCEPTION 'REGIA_ENTRY_STALE' USING ERRCODE='40001'; END IF;
 SELECT req.* INTO e FROM exam_human_private.requests AS req
  WHERE req.master_session_id=m.id AND req.owner_user=auth.uid() AND req.state='combat'
  ORDER BY req.created_at DESC LIMIT 1 FOR UPDATE;
 IF e.id IS NOT NULL THEN
  SELECT * INTO exam_open FROM exam_human_private.combat_openings WHERE exam_id=e.id FOR UPDATE;
  enc:=exam_open.encounter_id; rid:=exam_open.round_id;
 ELSIF m.owner_kind='human' AND EXISTS(SELECT 1
    FROM mission_generic_owner.regia_human_session_optins_v1 opt
    WHERE opt.master_session_id=m.id AND opt.actor_user=m.master_user) THEN
  SELECT * INTO he FROM mission_creation_owner.human_encounters
   WHERE master_session_id=m.id AND step_key=run.current_step_key
     AND run_control_version=run.control_version FOR UPDATE;
  IF he.encounter_id IS NULL THEN
   INSERT INTO mission_generic_owner.regia_entry_permits_v1
    (master_session_id,request_key,principal_id,step_key,run_control_version,master_control_version)
   VALUES(m.id,p_request_key,auth.uid(),run.current_step_key,run.control_version,m.control_version);
   opened:=mission_creation_owner.human_open(m.id,p_request_key);
   enc:=(opened->>'encounter_id')::uuid;
   rid:=(opened#>>'{combat,data,round_id}')::uuid;
  ELSE
   enc:=he.encounter_id;
  END IF;
 ELSIF m.owner_kind='ai_service'
   AND EXISTS(SELECT 1 FROM mission_generic_owner.flow_staff_sessions fs
     WHERE fs.master_session_id=m.id AND fs.enabled)
   AND EXISTS(SELECT 1 FROM mission_generic_owner.run_bindings b
     WHERE b.master_session_id=m.id) THEN
  SELECT * INTO cs FROM public.combat_v2_sessions s
    WHERE s.master_session_id=m.id AND s.state='in_corso'
    ORDER BY s.created_at DESC LIMIT 1 FOR UPDATE;
  enc:=cs.id;
 ELSE RAISE EXCEPTION 'REGIA_ENTRY_UNAVAILABLE' USING ERRCODE='42501'; END IF;
 IF rid IS NULL AND enc IS NOT NULL THEN
  SELECT r.id INTO rid FROM public.combat_v2_rounds r WHERE r.session_id=enc
   ORDER BY r.round_no LIMIT 1;
 END IF;
 IF enc IS NULL OR rid IS NULL OR NOT combat_panel_private.uses_simulated_pools(enc)
   OR public.combat_v2_values_written(enc)
   OR NOT EXISTS(SELECT 1 FROM public.combat_v2_sessions s
      JOIN public.combat_v2_actors a ON a.session_id=s.id
      JOIN public.characters ch ON ch.id=a.character_id AND ch.user_id=auth.uid()
      WHERE s.id=enc AND s.master_session_id=m.id AND s.state='in_corso'
        AND NOT s.lesiva AND a.actor_kind='pg' AND a.state='attivo'
        AND a.controller_user=auth.uid())
 THEN RAISE EXCEPTION 'REGIA_ENTRY_UNPROTECTED' USING ERRCODE='42501'; END IF;
 INSERT INTO mission_generic_owner.regia_entry_requests_v1
  (master_session_id,request_key,principal_id,expected_revision,step_key,run_control_version,encounter_id,opening_round_id)
 VALUES(m.id,p_request_key,auth.uid(),p_expected_revision,state->>'step_key',
   (state->>'run_control_version')::bigint,enc,rid);
 state:=public.regia_combat_entry_state_v1(m.id);
 RETURN jsonb_set(state,'{request_key}',to_jsonb(p_request_key),true);
END $$;
CREATE OR REPLACE FUNCTION public.regia_combat_entry_state_v1(p_master_session uuid) RETURNS jsonb LANGUAGE plpgsql SECURITY DEFINER SET search_path TO '' AS $$
DECLARE m public.master_v2_sessions%ROWTYPE; run public.mission_run_state%ROWTYPE;
 e exam_human_private.requests%ROWTYPE; opening exam_human_private.combat_openings%ROWTYPE;
 he mission_creation_owner.human_encounters%ROWTYPE; cs public.combat_v2_sessions%ROWTYPE;
 actor uuid; publication jsonb; public_part jsonb;
 perms jsonb:=jsonb_build_object('main',false,'defense',false,'reaction',false);
 step text; rev bigint; status text:='unavailable'; reason text:='REGIA_ENTRY_UNAVAILABLE';
 can_prepare boolean:=false; can_open boolean:=false; eligible boolean:=false;
 round_id uuid; enc uuid;
BEGIN
 IF EXISTS(SELECT 1 FROM mission_narrative_internal.scene_runtime_v1 cache JOIN public.master_v2_sessions cm ON cm.id=cache.master_session_id WHERE cache.master_session_id=p_master_session AND cache.is_active AND cm.owner_kind='ai_service') AND EXISTS(SELECT 1 FROM mission_narrative_internal.scene_runtime_v1 cache WHERE cache.master_session_id=p_master_session AND cache.mode<>'combat') THEN RETURN mission_narrative_internal.scene_entry_state_v1(p_master_session,auth.uid(),NULL);END IF;
 IF auth.uid() IS NULL OR p_master_session IS NULL
 THEN RAISE EXCEPTION 'REGIA_ACCESS_DENIED' USING ERRCODE='42501'; END IF;
 SELECT * INTO m FROM public.master_v2_sessions WHERE id=p_master_session;
 IF m.id IS NULL THEN RAISE EXCEPTION 'REGIA_ACCESS_DENIED' USING ERRCODE='42501'; END IF;
 SELECT * INTO e FROM exam_human_private.requests
   WHERE master_session_id=m.id AND owner_user=auth.uid()
   ORDER BY created_at DESC LIMIT 1;
 IF e.id IS NULL AND NOT EXISTS(SELECT 1 FROM public.master_v2_participants p
   JOIN public.characters ch ON ch.id=p.character_id AND ch.user_id=p.user_id_snapshot
   WHERE p.session_id=m.id AND p.user_id_snapshot=auth.uid() AND p.left_at IS NULL
    AND p.engagement_state='attivo')
 THEN RAISE EXCEPTION 'REGIA_ACCESS_DENIED' USING ERRCODE='42501'; END IF;
 SELECT * INTO run FROM public.mission_run_state WHERE master_session_id=m.id;
 step:=CASE WHEN e.id IS NOT NULL THEN 'exam:'||e.id::text ELSE run.current_step_key END;
 rev:=mission_generic_owner.regia_entry_revision_v1(m.id);
 eligible:=m.stato='in_corso' AND m.closed_at IS NULL AND m.suspended_at IS NULL
   AND EXISTS(SELECT 1 FROM public.locations loc WHERE loc.id=m.location_id
      AND loc.id='0b85f354-9cdb-47e1-baf9-3d266bb7e06b'::uuid
      AND loc.is_active AND loc.is_test)
   AND combat_consumer_private.staff_test_allowed(m.location_id,
     CASE WHEN m.owner_kind='ai_service' THEN ARRAY[auth.uid()]::uuid[]
       ELSE ARRAY[auth.uid(),m.master_user]::uuid[] END,false)=true OR (e.id IS NULL AND m.stato='in_corso' AND mission_public_owner.human_session_allowed_v1(m.id));
 IF mission_public_owner.role_session_allowed_v1(m.id) THEN eligible:=m.stato='in_corso' AND m.closed_at IS NULL AND m.suspended_at IS NULL; END IF;
 IF eligible AND e.id IS NOT NULL AND e.state='combat'
   AND exam_human_private.execution_location_v1(e.location_id) THEN
  SELECT * INTO opening FROM exam_human_private.combat_openings WHERE exam_id=e.id;
  IF opening.encounter_id IS NOT NULL THEN
   enc:=opening.encounter_id; round_id:=opening.round_id;
   status:='prepared'; reason:='REGIA_FATO_PENDING'; can_prepare:=true;
  END IF;
 ELSIF eligible AND m.owner_kind='human' AND run.run_phase='in_corso'
  AND EXISTS(SELECT 1 FROM mission_generic_owner.regia_human_session_optins_v1 opt
      WHERE opt.master_session_id=m.id AND opt.actor_user=m.master_user) THEN
  SELECT * INTO he FROM mission_creation_owner.human_encounters
   WHERE master_session_id=m.id AND step_key=step AND run_control_version=run.control_version;
  IF he.encounter_id IS NULL THEN
   IF jsonb_array_length(mission_generic_owner.scene(m.id,step)->'encounters')=1
    AND NOT EXISTS(SELECT 1 FROM public.combat_v2_sessions s
       WHERE s.master_session_id=m.id AND s.state NOT IN ('chiuso','annullato'))
   THEN status:='ready'; reason:=NULL; can_prepare:=true; END IF;
  ELSE
   enc:=he.encounter_id; status:='prepared'; reason:='REGIA_TURN_AUTHORITY_REQUIRED';
   can_prepare:=true;
  END IF;
 ELSIF eligible AND m.owner_kind='ai_service' AND run.run_phase='in_corso'
  AND (EXISTS(SELECT 1 FROM mission_generic_owner.flow_staff_sessions fs
      WHERE fs.master_session_id=m.id AND fs.enabled) OR mission_public_owner.role_session_allowed_v1(m.id))
  AND EXISTS(SELECT 1 FROM mission_generic_owner.run_bindings b WHERE b.master_session_id=m.id)
 THEN
  SELECT * INTO cs FROM public.combat_v2_sessions s WHERE s.master_session_id=m.id
    AND s.state='in_corso' ORDER BY s.created_at DESC LIMIT 1;
  IF cs.id IS NOT NULL THEN
   enc:=cs.id;
   status:='prepared'; reason:='REGIA_FATO_PENDING'; can_prepare:=true;
  END IF;
 END IF;
 IF enc IS NOT NULL THEN
  SELECT * INTO cs FROM public.combat_v2_sessions WHERE id=enc;
  IF cs.state<>'in_corso' OR NOT ((m.owner_kind='human' AND mission_public_owner.human_resource_scope_v1(m.id,cs.id,true))
    OR (m.owner_kind='ai_service' AND mission_public_owner.ai_resource_scope_v1(m.id,cs.id))
    OR (e.id IS NOT NULL AND NOT cs.lesiva AND combat_panel_private.uses_simulated_pools(cs.id) AND NOT public.combat_v2_values_written(cs.id)))
  THEN status:='unavailable'; reason:='REGIA_ENTRY_UNAVAILABLE'; can_prepare:=false;
       enc:=NULL;
  ELSE
   IF round_id IS NULL THEN
    SELECT r.id INTO round_id FROM public.combat_v2_rounds r WHERE r.session_id=cs.id
     ORDER BY r.round_no LIMIT 1;
   END IF;
   SELECT a.id INTO actor FROM public.combat_v2_actors a
    JOIN public.characters ch ON ch.id=a.character_id AND ch.user_id=auth.uid()
    WHERE a.session_id=cs.id AND a.actor_kind='pg' AND a.controller_user=auth.uid()
      AND a.state='attivo' ORDER BY a.id LIMIT 1;
   IF actor IS NULL OR round_id IS NULL
   THEN status:='unavailable'; reason:='REGIA_ENTRY_UNAVAILABLE'; can_prepare:=false;
   ELSE
    publication:=public.regia_round_publication_state_v1(m.id,actor);
    public_part:=publication->'public';
    IF publication->>'status'='ready' AND public_part->>'reason_code' IS NULL
      AND public_part->>'publication_id' IS NOT NULL
      AND public_part->>'public_round_id' IS NOT NULL
    THEN
     status:='open'; reason:=NULL; can_open:=true;
     perms:=jsonb_build_object('main',coalesce((public_part#>>'{permissions,main}')::boolean,false),
       'defense',coalesce((public_part#>>'{permissions,defense}')::boolean,false),
       'reaction',coalesce((public_part#>>'{permissions,reaction}')::boolean,false));
     IF NOT coalesce((perms->>'main')::boolean,false)
       AND NOT coalesce((perms->>'defense')::boolean,false)
       AND NOT coalesce((perms->>'reaction')::boolean,false)
     THEN reason:='REGIA_NOT_YOUR_TURN'; END IF;
    END IF;
   END IF;
  END IF;
 END IF;
 RETURN jsonb_build_object('schema','regia-combat-entry/1','status',status,
  'master_session_id',m.id,'step_key',step,'run_control_version',run.control_version,
  'entry_revision',rev,'request_key',NULL,'can_prepare',can_prepare,
  'can_open_panel',can_open,'reason_code',reason,
  'encounter_id',CASE WHEN can_open THEN cs.id ELSE NULL END,
  'opening_round_id',CASE WHEN can_open THEN round_id ELSE NULL END,
  'public_round_id',CASE WHEN can_open THEN (public_part->>'public_round_id')::uuid ELSE NULL END,
  'publication_id',CASE WHEN can_open THEN (public_part->>'publication_id')::uuid ELSE NULL END,
  'permissions',perms);
END $$;
CREATE OR REPLACE FUNCTION public.regia_combat_entry_receipt_v1(p_master_session uuid, p_request_key uuid) RETURNS jsonb LANGUAGE plpgsql SECURITY DEFINER SET search_path TO '' AS $$
DECLARE prior mission_generic_owner.regia_entry_requests_v1%ROWTYPE; state jsonb;
BEGIN
 IF EXISTS(SELECT 1 FROM mission_narrative_internal.scene_runtime_v1 cache JOIN public.master_v2_sessions cm ON cm.id=cache.master_session_id WHERE cache.master_session_id=p_master_session AND cache.is_active AND cm.owner_kind='ai_service') THEN IF p_request_key IS NULL THEN RAISE EXCEPTION 'REGIA_ENTRY_INPUT_INVALID' USING ERRCODE='22023';END IF;RETURN mission_narrative_internal.scene_entry_state_v1(p_master_session,auth.uid(),p_request_key);END IF;
 IF p_request_key IS NULL OR p_master_session IS NULL OR auth.uid() IS NULL
 THEN RAISE EXCEPTION 'REGIA_ENTRY_INPUT_INVALID' USING ERRCODE='22023'; END IF;
 state:=public.regia_combat_entry_state_v1(p_master_session);
 SELECT * INTO prior FROM mission_generic_owner.regia_entry_requests_v1
  WHERE master_session_id=p_master_session AND request_key=p_request_key
   AND principal_id=auth.uid();
 IF prior.request_key IS NULL THEN
  RETURN jsonb_set(jsonb_set(state,'{status}','"not_found"'::jsonb,true),
   '{reason_code}','"REGIA_OPERATION_NOT_FOUND"'::jsonb,true);
 END IF;
 IF prior.step_key IS DISTINCT FROM state->>'step_key'
   OR prior.run_control_version IS DISTINCT FROM (state->>'run_control_version')::bigint
 THEN RAISE EXCEPTION 'REGIA_ENTRY_STALE' USING ERRCODE='40001';
 END IF;
 RETURN jsonb_set(state,'{request_key}',to_jsonb(p_request_key),true);
END $$;
CREATE OR REPLACE FUNCTION public.regia_round_publication_state_v1(p_master_session uuid, p_actor uuid = CAST(NULL AS uuid)) RETURNS jsonb LANGUAGE plpgsql STABLE SECURITY DEFINER SET search_path TO '' AS $$
DECLARE m public.master_v2_sessions%ROWTYPE;
 s public.combat_v2_sessions%ROWTYPE;
 r public.combat_v2_rounds%ROWTYPE;
 w mission_generic_owner.unified_round_windows%ROWTYPE;
 pw mission_generic_owner.unified_round_windows%ROWTYPE;
 b mission_generic_owner.unified_batches%ROWTYPE;
 hw mission_generic_owner.regia_human_windows_v1%ROWTYPE;
 report public.combat_v2_round_reports%ROWTYPE;
 is_master boolean; can_main boolean:=false; can_defend boolean:=false;
 slots jsonb:='[]'::jsonb;
 private_hw boolean:=false;
 scene56_receipt jsonb;scene56_round public.combat_v2_rounds;
BEGIN
 IF auth.uid() IS NULL THEN RAISE EXCEPTION 'REGIA_ACCESS_DENIED' USING ERRCODE='42501'; END IF;
 SELECT * INTO m FROM public.master_v2_sessions WHERE id=p_master_session;
 IF EXISTS(SELECT 1 FROM exam_human_private.requests e
   WHERE e.master_session_id=m.id AND e.state='combat')
 THEN RETURN exam_human_private.round_publication_state_v1(m.id,p_actor); END IF;
 IF m.id IS NULL OR NOT EXISTS(SELECT 1 FROM public.locations l
    WHERE l.id=m.location_id AND l.id='0b85f354-9cdb-47e1-baf9-3d266bb7e06b'::uuid
      AND l.is_active AND l.is_test)
   AND NOT mission_public_owner.role_session_allowed_v1(m.id)
   AND NOT mission_public_owner.human_session_allowed_v1(m.id)
 THEN RETURN jsonb_build_object('schema_version','regia-round-publication-state/1',
    'status','unavailable','reason_code','not_opted_in','public',null,'master',null); END IF;
 is_master:=coalesce(m.master_user=auth.uid() AND public.master_v2_is_master(auth.uid()),false);
 IF NOT is_master
   AND mission_generic_owner.principal_in_session(m.id,auth.uid()) IS NOT TRUE
   AND NOT EXISTS(SELECT 1 FROM public.master_v2_participants p
      JOIN public.characters c ON c.id=p.character_id AND c.user_id=p.user_id_snapshot
      WHERE p.session_id=m.id AND p.user_id_snapshot=auth.uid()
        AND p.left_at IS NULL AND p.engagement_state='attivo')
 THEN RAISE EXCEPTION 'REGIA_ACCESS_DENIED' USING ERRCODE='42501'; END IF;
 IF p_actor IS NOT NULL AND NOT EXISTS(SELECT 1 FROM public.combat_v2_actors a
   JOIN public.combat_v2_sessions cs ON cs.id=a.session_id
   WHERE a.id=p_actor AND cs.master_session_id=m.id
     AND a.controller_user=auth.uid())
 THEN RAISE EXCEPTION 'REGIA_ACCESS_DENIED' USING ERRCODE='42501'; END IF;
 SELECT * INTO s FROM public.combat_v2_sessions
   WHERE master_session_id=m.id AND state NOT IN('chiuso','annullato')
   ORDER BY created_at DESC LIMIT 1;
 IF s.id IS NULL THEN RETURN jsonb_build_object('schema_version','regia-round-publication-state/1',
   'status',CASE WHEN is_master THEN 'ready' ELSE 'unavailable' END,
   'activity_id',m.id,'actor_id',p_actor,
   'reason_code','REGIA_ENTRY_STAGING_REQUIRED',
   'public',jsonb_build_object('schema_version','regia-round-public/1',
     'window_id',null,'public_round_id',null,'publication_id',null,
     'publication_revision',m.control_version,'context_version',m.control_version,
     'permissions',jsonb_build_object('main',false,'defense',false,'reaction',false),
     'reason_code','regia_fato_pending'),
   'master',CASE WHEN is_master THEN jsonb_build_object(
     'schema_version','regia-round-preparation/1','window_id',null,
     'source_round_id',null,'source_report_id',null,'source_report_sha256',null,
     'next_round_id',null,'preparation_revision',m.control_version,
     'control_version',m.control_version,'side',null,'legal_png_slots','[]'::jsonb,
     'state','entry_staging_required','can_prepare',false,'can_publish',false,
     'direction_context',mission_generic_owner.regia_human_direction_context_v1(m.id))
     ELSE NULL END); END IF;
 IF NOT (SELECT l.is_test FROM public.locations l WHERE l.id=m.location_id)
  AND NOT ((m.owner_kind='ai_service' AND mission_public_owner.ai_resource_scope_v1(m.id,s.id))
    OR (m.owner_kind='human' AND mission_public_owner.human_resource_scope_v1(m.id,s.id,false)))
 THEN RAISE EXCEPTION 'REGIA_RESOURCE_POLICY_DRIFT' USING ERRCODE='42501'; END IF;
 IF m.owner_kind='ai_service' AND EXISTS(SELECT 1 FROM mission_narrative_internal.scene_runtime_v1 cache WHERE cache.master_session_id=m.id AND cache.is_active)
  AND NOT EXISTS(SELECT 1 FROM mission_generic_owner.unified_round_windows uw JOIN public.combat_v2_rounds rr ON rr.id=uw.round_id WHERE rr.session_id=s.id) THEN
  SELECT * INTO scene56_round FROM public.combat_v2_rounds rr WHERE rr.session_id=s.id ORDER BY rr.round_no LIMIT 1;
  scene56_receipt:=mission_narrative_internal.scene_opening_receipt_v1(scene56_round.id);
  IF scene56_receipt IS NOT NULL THEN
   can_main:=p_actor IS NOT NULL AND scene56_round.phase='raccolta_azioni' AND EXISTS(SELECT 1 FROM public.combat_v2_actors a
    WHERE a.id=p_actor AND a.session_id=s.id AND a.actor_kind='pg' AND a.state='attivo' AND a.controller_user=auth.uid()
    AND NOT EXISTS(SELECT 1 FROM public.combat_v2_declarations d WHERE d.round_id=scene56_round.id AND d.actor_id=a.id AND d.kind IN('attacco','movimento','utilita','passa')));
   can_defend:=p_actor IS NOT NULL AND scene56_round.phase='raccolta_difese' AND EXISTS(SELECT 1 FROM public.combat_v2_attack_targets t WHERE t.round_id=scene56_round.id AND t.target_actor_id=p_actor AND t.state='attesa_difesa') AND NOT EXISTS(SELECT 1 FROM public.combat_v2_declarations d WHERE d.round_id=scene56_round.id AND d.actor_id=p_actor AND d.kind IN('difesa','nessuna'));
   IF NOT EXISTS(SELECT 1 FROM mission_narrative_internal.scene_runtime_v1 cache WHERE cache.master_session_id=m.id AND cache.turn_owner='combat') THEN can_main:=false;can_defend:=false;END IF;
   RETURN jsonb_build_object('schema_version','regia-round-publication-state/1','status','ready','activity_id',m.id,'actor_id',p_actor,
    'public',jsonb_build_object('schema_version','regia-round-public/1','window_id',scene56_round.id,'public_round_id',scene56_round.id,
    'publication_id',scene56_receipt->'publication_id','publication_revision',(scene56_receipt->>'state_version_after')::bigint,
    'context_version',m.control_version,'permissions',jsonb_build_object('main',can_main,'defense',can_defend,'reaction',can_defend),
    'reason_code',null),'master',null);
  END IF;
 END IF;
 SELECT * INTO hw FROM mission_generic_owner.regia_human_windows_v1 h
  WHERE h.encounter_id=s.id AND h.side='terminal' AND h.state='private'
  ORDER BY h.created_at DESC LIMIT 1;
 IF hw.id IS NOT NULL THEN
  SELECT * INTO report FROM public.combat_v2_round_reports WHERE id=hw.source_report_id;
  RETURN jsonb_build_object('schema_version','regia-round-publication-state/1',
    'status','ready','activity_id',m.id,'actor_id',p_actor,
    'public',jsonb_build_object('schema_version','regia-round-public/1',
      'window_id',null,'public_round_id',null,'publication_id',null,
      'publication_revision',m.control_version,'context_version',m.control_version,
      'permissions',jsonb_build_object('main',false,'defense',false,'reaction',false),
      'reason_code','regia_fato_pending'),
    'master',CASE WHEN NOT is_master THEN NULL ELSE jsonb_build_object(
      'schema_version','regia-round-preparation/1',
      'window_id',hw.id,'source_round_id',hw.source_round_id,
      'source_report_id',hw.source_report_id,
      'source_report_sha256',hw.source_report_sha256,'next_round_id',null,
      'preparation_revision',hw.preparation_revision,
      'control_version',m.control_version,'side','terminal',
      'legal_png_slots','[]'::jsonb,'state','terminal',
      'can_prepare',false,'can_publish',true,
      'direction_context',mission_generic_owner.regia_human_direction_context_v1(m.id)) END);
 END IF;
 -- C1244 AGG5: prima apertura Native privata attestata anche ai PG.
 -- Nessuna proiezione Master viene consegnata; il ramo Master admitted resta invariato.
 IF m.owner_kind='human' AND m.closed_at IS NULL
   AND m.stato IN ('in_corso','sospesa')
   AND m.location_id='0b85f354-9cdb-47e1-baf9-3d266bb7e06b'::uuid
   AND EXISTS(SELECT 1 FROM public.locations loc
     WHERE loc.id=m.location_id AND loc.is_active AND loc.is_test)
   AND (NOT is_master OR NOT EXISTS(
     SELECT 1 FROM mission_generic_owner.regia_human_admissions_v1 adm
      WHERE adm.master_session_id=m.id AND adm.encounter_id=s.id))
   AND (EXISTS(SELECT 1 FROM mission_generic_owner.regia_human_session_optins_v1 opt
      WHERE opt.master_session_id=m.id AND opt.actor_user=m.master_user)
     OR EXISTS(SELECT 1 FROM mission_generic_owner.regia_human_admissions_v1 adm
      WHERE adm.master_session_id=m.id AND adm.encounter_id=s.id))
   AND NOT EXISTS(SELECT 1 FROM mission_generic_owner.unified_round_windows uw
     JOIN public.combat_v2_rounds ur ON ur.id=uw.round_id
     WHERE uw.master_session_id=m.id AND ur.session_id=s.id)
 THEN RETURN jsonb_build_object('schema_version','regia-round-publication-state/1',
   'status','ready','activity_id',m.id,'actor_id',p_actor,
   'reason_code','REGIA_OPENING_STAGED',
   'public',jsonb_build_object('schema_version','regia-round-public/1',
     'window_id',null,'public_round_id',null,'publication_id',null,
     'publication_revision',m.control_version,'context_version',m.control_version,
     'permissions',jsonb_build_object('main',false,'defense',false,'reaction',false),
     'reason_code','regia_fato_pending'),
   'master',null); END IF;
 IF is_master AND EXISTS(SELECT 1 FROM mission_generic_owner.regia_human_admissions_v1 h
      WHERE h.encounter_id=s.id AND h.master_session_id=m.id)
   AND NOT EXISTS(SELECT 1 FROM mission_generic_owner.unified_round_windows uw
      WHERE uw.master_session_id=m.id AND uw.round_id IN
       (SELECT id FROM public.combat_v2_rounds WHERE session_id=s.id))
 THEN
  SELECT * INTO r FROM public.combat_v2_rounds WHERE session_id=s.id
    ORDER BY round_no DESC LIMIT 1;
  IF r.state<>'risolto' THEN
   RETURN jsonb_build_object('schema_version','regia-round-publication-state/1',
     'status','ready','activity_id',m.id,'actor_id',p_actor,
     'reason_code','REGIA_OPENING_STAGED',
     'public',jsonb_build_object('schema_version','regia-round-public/1',
       'window_id',null,'public_round_id',null,'publication_id',null,
       'publication_revision',m.control_version,'context_version',m.control_version,
       'permissions',jsonb_build_object('main',false,'defense',false,'reaction',false),
       'reason_code','regia_fato_pending'),
     'master',jsonb_build_object(
       'schema_version','regia-round-preparation/1','window_id',null,
       'source_round_id',null,'source_report_id',null,'source_report_sha256',null,
       'next_round_id',r.id,'preparation_revision',m.control_version,
       'control_version',m.control_version,'side',null,'legal_png_slots','[]'::jsonb,
       'state','entry_staged',
       'can_prepare',coalesce((mission_generic_owner.regia_human_direction_context_v1(m.id)->>'can_direct')::boolean,false),
       'can_publish',false,
       'direction_context',mission_generic_owner.regia_human_direction_context_v1(m.id)));
  END IF;
  SELECT * INTO report FROM public.combat_v2_round_reports WHERE round_id=r.id;
  RETURN jsonb_build_object('schema_version','regia-round-publication-state/1',
   'status','ready','activity_id',m.id,'actor_id',p_actor,
   'public',jsonb_build_object('schema_version','regia-round-public/1',
     'window_id',r.id,'public_round_id',r.id,'publication_id',report.message_id,
     'publication_revision',m.control_version,'context_version',m.control_version,
     'permissions',jsonb_build_object('main',false,'defense',false,'reaction',false),
     'reason_code',null),
   'master',jsonb_build_object('schema_version','regia-round-preparation/1',
     'window_id',null,'source_round_id',r.id,'source_report_id',report.id,
     'source_report_sha256',report.mechanics_sha256,'next_round_id',null,
     'preparation_revision',m.control_version,'control_version',m.control_version,
     'side',null,'legal_png_slots','[]'::jsonb,'state','resolved',
     'can_prepare',r.state='risolto' AND report.narration_state='attesa',
     'can_publish',false,
     'direction_context',mission_generic_owner.regia_human_direction_context_v1(m.id)));
 END IF;
 SELECT x.* INTO r FROM public.combat_v2_rounds x
   JOIN mission_generic_owner.unified_round_windows uw ON uw.round_id=x.id
   WHERE x.session_id=s.id AND uw.master_session_id=m.id
   ORDER BY x.round_no DESC LIMIT 1;
 IF r.id IS NULL THEN RETURN jsonb_build_object('schema_version','regia-round-publication-state/1',
   'status','unavailable','reason_code','not_opted_in','public',null,'master',null); END IF;
 SELECT * INTO STRICT w FROM mission_generic_owner.unified_round_windows WHERE round_id=r.id;
 SELECT * INTO b FROM mission_generic_owner.unified_batches WHERE id=w.batch_id;
 SELECT * INTO hw FROM mission_generic_owner.regia_human_windows_v1
   WHERE next_round_id=w.round_id AND batch_id=b.id;
 -- C1244 AGG6: la finestra privata conserva il referto precedente e la propria revisione.
 private_hw:=hw.id IS NOT NULL AND hw.state='private'
   AND m.owner_kind='human'
   AND m.location_id='0b85f354-9cdb-47e1-baf9-3d266bb7e06b'::uuid
   AND w.publication_id IS NULL;
 SELECT q.* INTO report FROM public.combat_v2_round_reports q
  WHERE (private_hw AND q.id=hw.source_report_id)
     OR (NOT private_hw AND ((r.state='risolto' AND q.round_id=r.id)
       OR (r.state<>'risolto' AND q.id=b.source_report_id)))
  ORDER BY CASE WHEN q.round_id=r.id THEN 0 ELSE 1 END LIMIT 1;
 SELECT uw.* INTO pw FROM mission_generic_owner.unified_round_windows uw
   JOIN public.combat_v2_rounds rr ON rr.id=uw.round_id
   WHERE rr.session_id=s.id AND uw.publication_id IS NOT NULL
   ORDER BY rr.round_no DESC LIMIT 1;
 IF p_actor IS NOT NULL AND NOT EXISTS(SELECT 1 FROM public.combat_v2_actors a
   WHERE a.id=p_actor AND a.session_id=s.id AND a.controller_user=auth.uid())
 THEN RAISE EXCEPTION 'REGIA_ACCESS_DENIED' USING ERRCODE='42501'; END IF;
 IF w.publication_id IS NOT NULL AND p_actor IS NOT NULL THEN
   can_main:=r.phase='raccolta_azioni' AND p_actor=ANY(w.expected_actor_ids)
     AND NOT EXISTS(SELECT 1 FROM public.combat_v2_declarations d
       WHERE d.round_id=r.id AND d.actor_id=p_actor AND d.kind IN('attacco','movimento','utilita','passa'));
   can_defend:=r.phase='raccolta_difese' AND EXISTS(SELECT 1 FROM public.combat_v2_attack_targets t
       WHERE t.round_id=r.id AND t.target_actor_id=p_actor AND t.state='attesa_difesa')
     AND NOT EXISTS(SELECT 1 FROM public.combat_v2_declarations d
       WHERE d.round_id=r.id AND d.actor_id=p_actor AND d.kind IN('difesa','nessuna'));
 END IF;
 IF is_master THEN
   SELECT coalesce(jsonb_agg(jsonb_build_object('actor_id',a.id,
      'action_due',NOT EXISTS(SELECT 1 FROM public.combat_v2_declarations d
         WHERE d.round_id=r.id AND d.actor_id=a.id AND d.kind IN('attacco','movimento','utilita','passa')))
      ORDER BY a.initiative_snapshot DESC,a.id),'[]'::jsonb) INTO slots
   FROM public.combat_v2_actors a
   WHERE a.id=ANY(w.expected_actor_ids) AND a.session_id=s.id
     AND a.actor_kind='png' AND a.state='attivo';
 END IF;
 RETURN jsonb_build_object('schema_version','regia-round-publication-state/1',
   'status','ready','activity_id',m.id,'actor_id',p_actor,
   'public',jsonb_build_object('schema_version','regia-round-public/1',
      'window_id',pw.round_id,'public_round_id',pw.round_id,
      'publication_id',pw.publication_id,
      'publication_revision',coalesce(b.run_control_version,m.control_version),
      'context_version',m.control_version,
      'permissions',jsonb_build_object('main',can_main,'defense',can_defend,'reaction',can_defend),
      'reason_code',CASE WHEN w.publication_id IS NULL THEN 'regia_fato_pending' ELSE NULL END),
   'master',CASE WHEN NOT is_master THEN NULL ELSE jsonb_build_object(
      'schema_version','regia-round-preparation/1',
      'window_id',coalesce(hw.id,w.round_id),
      'source_round_id',CASE WHEN private_hw THEN hw.source_round_id
         WHEN r.state='risolto' THEN r.id ELSE b.source_round_id END,
      'source_report_id',CASE WHEN private_hw THEN hw.source_report_id
         WHEN r.state='risolto' THEN
         (SELECT id FROM public.combat_v2_round_reports WHERE round_id=r.id)
         ELSE b.source_report_id END,
      'source_report_sha256',CASE WHEN private_hw THEN hw.source_report_sha256
         ELSE report.mechanics_sha256 END,'next_round_id',w.round_id,
      'preparation_revision',CASE WHEN private_hw THEN hw.preparation_revision
         WHEN r.state='risolto'
         THEN m.control_version ELSE coalesce(hw.preparation_revision,m.control_version) END,
      'control_version',m.control_version,
      'side',w.side,'legal_png_slots',slots,
      'state',CASE WHEN w.publication_id IS NOT NULL THEN 'published' ELSE 'private' END,
      'can_prepare',hw.id IS NOT NULL AND w.publication_id IS NOT NULL
        AND r.state='risolto' AND EXISTS(SELECT 1 FROM public.combat_v2_round_reports qr
          WHERE qr.round_id=r.id AND qr.narration_state='attesa'),
      'direction_context',mission_generic_owner.regia_human_direction_context_v1(m.id),
      'can_publish',hw.id IS NOT NULL AND hw.state='private'
       AND (hw.side='pg' OR NOT EXISTS(SELECT 1 FROM unnest(w.expected_actor_ids) actor(id)
         WHERE NOT EXISTS(SELECT 1 FROM combat_panel_private.actor_turns turn_row
          WHERE turn_row.round_id=r.id AND turn_row.actor_id=actor.id
            AND turn_row.main_declaration_id IS NOT NULL)))) END);
END $$;
CREATE OR REPLACE FUNCTION mission_generic_owner.unified_assert_command(p_round uuid, p_operation text) RETURNS void LANGUAGE plpgsql SECURITY DEFINER SET search_path TO '' AS $$
DECLARE w mission_generic_owner.unified_round_windows%ROWTYPE; staging boolean; actor uuid; human_stage boolean;
 scene56_receipt jsonb;
BEGIN
 IF p_operation IN('declare','defend') AND EXISTS(SELECT 1 FROM public.combat_v2_rounds rr
  JOIN public.combat_v2_sessions cs ON cs.id=rr.session_id
  JOIN mission_narrative_internal.scene_runtime_v1 cache ON cache.master_session_id=cs.master_session_id AND cache.is_active
  WHERE rr.id=p_round AND (cache.turn_owner='fato' OR cache.mode<>'combat'))
 THEN RAISE EXCEPTION 'SCENE56_FATO_OWNS_TURN' USING ERRCODE='42501';END IF;
 IF NOT EXISTS(SELECT 1 FROM mission_generic_owner.unified_round_windows uw WHERE uw.round_id=p_round) THEN
  scene56_receipt:=mission_narrative_internal.scene_opening_receipt_v1(p_round);
  IF scene56_receipt IS NOT NULL THEN
   IF p_operation NOT IN('declare','defend','resolve') THEN RAISE EXCEPTION 'MUF_COMMAND_INVALID' USING ERRCODE='42501';END IF;
   IF p_operation='resolve' AND auth.uid() IS NULL AND public.combat_v2_is_service() THEN RETURN;END IF;
   -- Only a genuine Native PNG defense commit may pass without a player JWT.
   -- The permit is private, unconsumed and local to this transaction/backend.
   IF p_operation='defend' AND auth.uid() IS NULL AND public.combat_v2_is_service() AND EXISTS(
    SELECT 1 FROM mission_generic_owner.panel_permits pp
    JOIN mission_generic_owner.panel_choices pc ON pc.work_id=pp.work_id AND pc.actor_id=pp.actor_id
     AND pc.request_key=pp.request_key AND pc.master_session_id=pp.master_session_id AND pc.encounter_id=pp.encounter_id
     AND pc.principal_id=pp.principal_id
    JOIN mission_generic_owner.work_items wi ON wi.id=pp.work_id AND wi.master_session_id=pp.master_session_id
     AND wi.encounter_id=pp.encounter_id AND wi.kind='choice' AND wi.state='provider_started'
     AND wi.payload->>'schema_version'='mission-generic-choice/1' AND wi.payload->>'round_id'=p_round::text
     AND wi.payload->>'actor_id'=pp.actor_id::text AND wi.payload->>'command_request_key'=pp.request_key::text
     AND wi.payload->'legal_options'=pc.legal_options AND wi.payload->>'context_version'=pc.context_version::text
    JOIN mission_generic_owner.encounters source_enc ON source_enc.encounter_id=pp.encounter_id AND source_enc.master_session_id=pp.master_session_id
    JOIN mission_ai_service_owner.capabilities cap ON cap.id=source_enc.capability_id AND cap.master_session_id=pp.master_session_id
     AND cap.state='active'
     AND wi.payload->>'capability_id'=pc.id::text
    JOIN public.combat_v2_rounds rr ON rr.id=p_round AND rr.session_id=pp.encounter_id AND rr.phase='raccolta_difese'
    JOIN public.combat_v2_actors npc ON npc.id=pp.actor_id AND npc.session_id=rr.session_id
     AND npc.actor_kind='png' AND npc.state='attivo' AND npc.companion_id IS NULL AND npc.controller_user IS NULL
    WHERE pp.encounter_id=(scene56_receipt->>'encounter_id')::uuid
     AND EXISTS(SELECT 1 FROM mission_narrative_internal.scene_runtime_v1 cache
      WHERE cache.id=(scene56_receipt->>'scene_id')::uuid AND cache.master_session_id=pp.master_session_id
       AND cache.mode='combat' AND cache.turn_owner='combat' AND cache.is_active)
     AND pp.transaction_id=txid_current() AND pp.backend_pid=pg_backend_pid() AND pp.consumed_at IS NULL AND pp.operation='commit'
     AND pp.created_at>clock_timestamp()-interval '150 seconds'
     AND pc.consumed_at IS NULL AND pc.expires_at>clock_timestamp() AND pc.controller_version=npc.controller_version
     AND pc.options_sha256=public.combat_v2_sha256(pc.legal_options)
     AND pc.legal_options#>>'{context,round_id}'=p_round::text
     AND pc.legal_options#>>'{context,activity_id}'=pp.encounter_id::text
     AND pc.legal_options#>>'{context,version}'=pc.context_version::text
     AND pc.legal_options#>>'{viewer,command_actor_id}'=npc.id::text
     AND pp.principal_id=mission_generic_owner.current_principal()
     AND pp.principal_id=mission_generic_owner.actor_principal(npc.id)
     AND EXISTS(SELECT 1 FROM public.combat_v2_attack_targets target
      JOIN public.combat_v2_declarations attack ON attack.id=target.attack_declaration_id AND attack.round_id=target.round_id
      WHERE target.round_id=rr.id AND target.target_actor_id=npc.id AND target.state='attesa_difesa'
       AND attack.kind='attacco' AND attack.state NOT IN('annullata','superflua')
       AND NOT combat_panel_private.multiplication_no_defense(target.id)))
   THEN RETURN;END IF;

   IF auth.uid() IS NULL OR NOT EXISTS(SELECT 1 FROM public.combat_v2_actors a JOIN public.combat_v2_rounds rr ON rr.session_id=a.session_id
    JOIN public.characters ch ON ch.id=a.character_id AND ch.user_id=a.controller_user
    WHERE rr.id=p_round AND a.actor_kind='pg' AND a.state='attivo' AND a.companion_id IS NULL AND a.controller_user=auth.uid())
   THEN RAISE EXCEPTION 'REGIA_ACCESS_DENIED' USING ERRCODE='42501';END IF;
   RETURN;
  END IF;
 END IF;
 SELECT * INTO w FROM mission_generic_owner.unified_round_windows WHERE round_id=p_round;
 IF w.round_id IS NULL THEN
  IF EXISTS(SELECT 1 FROM mission_generic_owner.regia_human_admissions_v1 adm
    JOIN public.combat_v2_rounds rr ON rr.session_id=adm.encounter_id
    WHERE rr.id=p_round) THEN RAISE EXCEPTION 'REGIA_TURN_AUTHORITY_REQUIRED' USING ERRCODE='42501'; END IF;
  RETURN;
 END IF;
 human_stage:=EXISTS(SELECT 1 FROM mission_generic_owner.regia_human_stage_permits_v1 hp
  JOIN mission_generic_owner.regia_human_windows_v1 hw ON hw.next_round_id=hp.round_id
  WHERE hp.round_id=p_round AND hp.master_session_id=w.master_session_id
   AND hp.principal_id=auth.uid() AND hp.transaction_id=txid_current()
   AND hp.backend_pid=pg_backend_pid());
 staging:=mission_generic_owner.unified_service_staging(p_round) OR human_stage;
 PERFORM mission_generic_owner.assert_runtime(w.master_session_id);
 IF p_operation='resolve' THEN
  IF w.publication_id IS NOT NULL THEN RETURN; END IF;
  IF auth.uid() IS NULL AND public.combat_v2_is_service() AND w.side='png' AND EXISTS(
   SELECT 1 FROM mission_generic_owner.unified_preparation_permits pp
   JOIN mission_generic_owner.unified_batches ub ON ub.id=pp.batch_id AND ub.id=w.batch_id
   JOIN public.combat_v2_rounds rr ON rr.id=pp.round_id AND rr.session_id=ub.encounter_id
   WHERE pp.round_id=p_round AND pp.transaction_id=txid_current() AND pp.backend_pid=pg_backend_pid()
   AND ub.master_session_id=w.master_session_id AND ub.state='preparing'
   AND NOT EXISTS(SELECT 1 FROM public.combat_v2_attack_targets atg WHERE atg.round_id=p_round)
   AND NOT EXISTS(SELECT 1 FROM unnest(w.expected_actor_ids) expected(id) WHERE NOT EXISTS(
    SELECT 1 FROM combat_panel_private.actor_turns atn JOIN public.combat_v2_declarations dd ON dd.id=atn.main_declaration_id
    WHERE atn.round_id=p_round AND atn.actor_id=expected.id AND dd.round_id=p_round AND dd.actor_id=expected.id))) THEN RETURN; END IF;
  RAISE EXCEPTION 'MUF_PUBLICATION_PENDING' USING ERRCODE='42501';
 END IF;
 IF w.publication_id IS NULL AND NOT staging THEN RAISE EXCEPTION 'MUF_PUBLICATION_PENDING' USING ERRCODE='42501'; END IF;
 IF p_operation NOT IN('declare','defend') THEN RAISE EXCEPTION 'MUF_COMMAND_INVALID' USING ERRCODE='42501'; END IF;
 IF staging AND human_stage THEN
  SELECT hp.actor_id INTO STRICT actor FROM mission_generic_owner.regia_human_stage_permits_v1 hp
   WHERE hp.round_id=p_round AND hp.master_session_id=w.master_session_id
    AND hp.principal_id=auth.uid() AND hp.transaction_id=txid_current()
    AND hp.backend_pid=pg_backend_pid() ORDER BY hp.id DESC LIMIT 1;
 ELSIF staging THEN
  SELECT pp.actor_id INTO STRICT actor FROM mission_generic_owner.panel_permits pp
  JOIN mission_generic_owner.panel_choices pc ON pc.work_id=pp.work_id AND pc.actor_id=pp.actor_id AND pc.request_key=pp.request_key
  JOIN mission_generic_owner.work_items wi ON wi.id=pp.work_id AND wi.master_session_id=pp.master_session_id
  JOIN public.combat_v2_rounds rr ON rr.id=p_round AND rr.session_id=pp.encounter_id
  WHERE pp.transaction_id=txid_current() AND pp.backend_pid=pg_backend_pid() AND pp.consumed_at IS NULL
  AND pp.operation='commit' AND pp.principal_id=mission_generic_owner.current_principal()
  AND wi.kind='choice' AND pc.consumed_at IS NULL
  AND (wi.state='provider_started' OR (wi.state='failed' AND EXISTS (
    SELECT 1 FROM mission_generic_owner.cached_choice_recovery_permits recovery
    WHERE recovery.work_id=wi.id AND recovery.choice_id=pc.id
      AND recovery.master_session_id=w.master_session_id AND recovery.round_id=p_round
      AND recovery.transaction_id=txid_current() AND recovery.backend_pid=pg_backend_pid()
      AND recovery.consumed_at IS NULL)));
 ELSE
  SELECT a.id INTO STRICT actor FROM public.combat_v2_actors a JOIN public.combat_v2_rounds rr ON rr.session_id=a.session_id
  WHERE rr.id=p_round AND a.actor_kind='pg' AND a.companion_id IS NULL AND a.state='attivo'
  AND a.controller_user=auth.uid();
 END IF;
 IF p_operation='declare' AND NOT actor=ANY(w.expected_actor_ids) THEN RAISE EXCEPTION 'MUF_COHORT_NOT_ACTIVE' USING ERRCODE='42501'; END IF;
 IF w.publication_id IS NULL AND (w.side<>'png' OR p_operation<>'declare') THEN RAISE EXCEPTION 'MUF_STAGING_OPERATION_INVALID' USING ERRCODE='42501'; END IF;
END $$;
CREATE OR REPLACE FUNCTION combat_consumer_private.expected_main_count(p_round uuid) RETURNS integer LANGUAGE sql STABLE SECURITY DEFINER SET search_path TO '' AS $$
 select case when EXISTS(SELECT 1 FROM mission_narrative_internal.scene_sources_v1 src
 WHERE src.technical_receipt->>'schema_version'='mission-narrative-combat-opening/1'
  AND src.technical_receipt->>'opening_round_id'=p_round::text AND src.retired_at IS NULL)
  AND mission_narrative_internal.scene_opening_receipt_v1(p_round) IS NOT NULL THEN
 (SELECT count(*)::integer FROM public.combat_v2_actors a JOIN public.combat_v2_rounds rr ON rr.session_id=a.session_id
  WHERE rr.id=p_round AND a.actor_kind='pg' AND a.companion_id IS NULL AND a.state='attivo' AND clan_marionettisti_private.can_declare(a.id))
 when combat_panel_private.human_duel_round(p_round) then 1
 when EXISTS(SELECT 1 FROM exam_human_private.round_publication_windows_v1 w WHERE w.next_round_id=p_round AND w.state IN ('private','published')) THEN 1
 when EXISTS(SELECT 1 FROM mission_generic_owner.unified_round_windows w WHERE w.round_id=p_round) THEN
 (SELECT count(*)::integer FROM public.combat_v2_actors a JOIN public.combat_v2_rounds r ON r.session_id=a.session_id
 JOIN mission_generic_owner.unified_round_windows w ON w.round_id=r.id
 WHERE r.id=p_round AND a.id=ANY(w.expected_actor_ids) AND a.state='attivo' AND clan_marionettisti_private.can_declare(a.id))
 when exam_regia_private.is_bound((select session_id from public.combat_v2_rounds where id=p_round)) OR combat_consumer_private.owns_round(p_round) then 1 else
   (select count(*)::integer from public.combat_v2_actors a join public.combat_v2_rounds r
     on r.session_id=a.session_id where r.id=p_round and a.state='attivo' and clan_marionettisti_private.can_declare(a.id)) end
$$;
REVOKE ALL PRIVILEGES ON FUNCTION public.regia_combat_entry_prepare_v1 (uuid, bigint, uuid) FROM PUBLIC, anon;
GRANT EXECUTE ON FUNCTION public.regia_combat_entry_prepare_v1 (uuid, bigint, uuid) TO authenticated;
REVOKE ALL PRIVILEGES ON FUNCTION public.regia_combat_entry_state_v1 (uuid) FROM PUBLIC, anon;
GRANT EXECUTE ON FUNCTION public.regia_combat_entry_state_v1 (uuid) TO authenticated;
REVOKE ALL PRIVILEGES ON FUNCTION public.regia_combat_entry_receipt_v1 (uuid, uuid) FROM PUBLIC, anon;
GRANT EXECUTE ON FUNCTION public.regia_combat_entry_receipt_v1 (uuid, uuid) TO authenticated;
REVOKE ALL PRIVILEGES ON FUNCTION public.regia_round_publication_state_v1 (uuid, uuid) FROM PUBLIC, anon;
GRANT EXECUTE ON FUNCTION public.regia_round_publication_state_v1 (uuid, uuid) TO authenticated;
CREATE OR REPLACE FUNCTION mission_public_owner.work_contract_v1(p_work uuid) RETURNS jsonb LANGUAGE plpgsql STABLE SECURITY DEFINER SET search_path TO '' AS $$
DECLARE wc mission_public_owner.work_contracts_v1;w mission_generic_owner.work_items;
 scene56_source mission_narrative_internal.scene_sources_v1;scene56_doc jsonb;scene56_history jsonb;scene56_descriptor jsonb;scene56_ids jsonb;
 a jsonb;descriptor jsonb;path text[];actual jsonb;node jsonb;seen text[]:='{}'::text[];
BEGIN
 SELECT * INTO wc FROM mission_public_owner.work_contracts_v1 WHERE work_id=p_work;
 IF NOT FOUND THEN RETURN NULL; END IF;
 SELECT * INTO STRICT w FROM mission_generic_owner.work_items WHERE id=p_work;
 -- Typed Scene contracts have immutable historical authority, not legacy Director grammar.
 IF w.payload->>'schema_version'='mission-narrative-scene/1'
  OR wc.contract->>'payload_schema_version'='mission-narrative-scene/1'
  OR wc.contract#>>'{source_attestation,schema_version}'='mission-narrative-scene-attestation/1'
  OR wc.contract->'features' ? 'direct_scene_narration_v1' THEN
  scene56_doc:=wc.contract;a:=scene56_doc->'source_attestation';
  IF (wc.master_session_id,wc.definition_sha256,wc.payload_sha256)
    IS DISTINCT FROM (w.master_session_id,w.definition_sha256,w.payload_sha256)
   OR wc.contract_sha256 IS DISTINCT FROM public.combat_v2_sha256(scene56_doc)
   OR w.payload_sha256 IS DISTINCT FROM public.combat_v2_sha256(w.payload)
   OR w.kind IS DISTINCT FROM 'narration' OR w.payload->>'schema_version' IS DISTINCT FROM 'mission-narrative-scene/1'
   OR w.payload->>'mode' IS DISTINCT FROM 'narrative_scene' OR wc.scope IS DISTINCT FROM 'staff_mission'
   OR NOT mission_factory_owner.keys_exact_v2(scene56_doc,ARRAY['schema_version','scope','release_sha256','work_id','master_session_id','definition_sha256','payload_sha256','payload_schema_version','editorial_profile','features','source_attestation'])
   OR scene56_doc->>'schema_version' IS DISTINCT FROM 'mission-narrative-admission/3'
   OR scene56_doc->>'scope' IS DISTINCT FROM 'staff_mission'
   OR scene56_doc->>'editorial_profile' IS DISTINCT FROM 'cinematic_master_1'
   OR scene56_doc->>'payload_schema_version' IS DISTINCT FROM 'mission-narrative-scene/1'
   OR (scene56_doc->>'work_id',scene56_doc->>'master_session_id',scene56_doc->>'definition_sha256',scene56_doc->>'payload_sha256',scene56_doc->>'release_sha256')
    IS DISTINCT FROM (w.id::text,w.master_session_id::text,w.definition_sha256,w.payload_sha256,wc.release_sha256)
   OR coalesce(wc.release_sha256,'')!~'^[a-f0-9]{64}$'
   OR scene56_doc->'features' IS DISTINCT FROM '["execution_authority_v1","provider_output_retention_v1","direct_scene_narration_v1"]'::jsonb
   OR NOT mission_factory_owner.keys_exact_v2(a,ARRAY['schema_version','work_id','authority_receipt_id','payload_sha256','master_session_id','definition_sha256','release_sha256','execution_authority','scene'])
   OR a->>'schema_version' IS DISTINCT FROM 'mission-narrative-scene-attestation/1'
   OR (a->>'work_id',a->>'master_session_id',a->>'definition_sha256',a->>'payload_sha256',a->>'release_sha256',a->>'authority_receipt_id')
    IS DISTINCT FROM (w.id::text,w.master_session_id::text,w.definition_sha256,w.payload_sha256,wc.release_sha256,w.authority_receipt_id::text)
   OR NOT mission_factory_owner.keys_exact_v2(a->'scene',ARRAY['schema_version','scene_id','snapshot_sha256','state_version','source_revision','accepted_role_ids','accepted_roles_sha256','last_publication_id','last_publication_sha256','current_phase_key','scene_memory_sha256'])
   OR a#>>'{scene,schema_version}' IS DISTINCT FROM 'mission-narrative-scene-source/1'
  THEN RAISE EXCEPTION 'SCENE56_READER_TYPED_CONTRACT_BINDING' USING ERRCODE='PT409';END IF;
  scene56_history:=mission_generic_owner.c1266_historical_work_v1(w.id);
  IF scene56_history IS NULL OR scene56_history->>'schema_version' IS DISTINCT FROM 'c1266-work-execution-attestation/3'
   OR a->'execution_authority' IS DISTINCT FROM scene56_history
  THEN RAISE EXCEPTION 'SCENE56_READER_HISTORICAL_AUTHORITY' USING ERRCODE='PT409';END IF;
  SELECT * INTO scene56_source FROM mission_narrative_internal.scene_sources_v1
   WHERE work_id=w.id AND id=w.authority_receipt_id;
  IF NOT FOUND THEN RAISE EXCEPTION 'SCENE56_READER_SOURCE_MISSING' USING ERRCODE='PT409';END IF;
  scene56_descriptor:=jsonb_build_object('schema_version','mission-narrative-scene-source/1','scene_id',scene56_source.scene_id,
   'snapshot_sha256',scene56_source.snapshot_sha256,'state_version',scene56_source.state_version,'source_revision',scene56_source.source_revision,
   'accepted_role_ids',to_jsonb(scene56_source.accepted_role_ids),'accepted_roles_sha256',scene56_source.accepted_roles_sha256,
   'last_publication_id',scene56_source.last_publication_id,'last_publication_sha256',scene56_source.last_publication_sha256,
   'current_phase_key',scene56_source.current_phase_key,'scene_memory_sha256',scene56_source.scene_memory_sha256);
  IF a->'scene' IS DISTINCT FROM scene56_descriptor
   OR NOT mission_factory_owner.keys_exact_v2(w.payload,ARRAY['schema_version','mode','scene_id','source_window_id','source_revision','state_version','snapshot_sha256','snapshot','current_phase_key','scene_memory','accepted_roles','last_publication','last_fati'])
   OR w.payload->>'scene_id' IS DISTINCT FROM scene56_source.scene_id::text
   OR w.payload->>'source_window_id' IS DISTINCT FROM scene56_source.id::text
   OR w.payload->>'source_revision' IS DISTINCT FROM scene56_source.source_revision
   OR w.payload->'state_version' IS DISTINCT FROM to_jsonb(scene56_source.state_version)
   OR w.payload->>'snapshot_sha256' IS DISTINCT FROM scene56_source.snapshot_sha256
   OR w.payload->>'current_phase_key' IS DISTINCT FROM scene56_source.current_phase_key
   OR scene56_source.payload_sha256 IS DISTINCT FROM w.payload_sha256
   OR jsonb_typeof(w.payload->'snapshot') IS DISTINCT FROM 'object'
   OR public.combat_v2_sha256(w.payload->'snapshot') IS DISTINCT FROM scene56_source.snapshot_sha256
   OR jsonb_typeof(w.payload->'accepted_roles') IS DISTINCT FROM 'array'
   OR jsonb_typeof(w.payload->'last_fati') IS DISTINCT FROM 'array'
   OR (w.payload->'scene_memory' IS DISTINCT FROM 'null'::jsonb AND jsonb_typeof(w.payload->'scene_memory') IS DISTINCT FROM 'object')
   OR public.combat_v2_sha256(coalesce(w.payload->'scene_memory','null'::jsonb)) IS DISTINCT FROM scene56_source.scene_memory_sha256
  THEN RAISE EXCEPTION 'SCENE56_READER_IMMUTABLE_SOURCE_BINDING' USING ERRCODE='PT409';END IF;
  SELECT coalesce(jsonb_agg(role.value->'message_id' ORDER BY role.ordinality),'[]'::jsonb)
   INTO scene56_ids FROM jsonb_array_elements(w.payload->'accepted_roles') WITH ORDINALITY role(value,ordinality);
  IF scene56_ids IS DISTINCT FROM to_jsonb(scene56_source.accepted_role_ids)
   OR public.combat_v2_sha256(w.payload->'accepted_roles') IS DISTINCT FROM scene56_source.accepted_roles_sha256
   OR w.payload->'last_publication' IS DISTINCT FROM (CASE WHEN scene56_source.last_publication_id IS NULL THEN 'null'::jsonb
    ELSE jsonb_build_object('message_id',scene56_source.last_publication_id,'body_sha256',scene56_source.last_publication_sha256) END)
   OR (scene56_source.request_kind='initial_opening' AND (cardinality(scene56_source.accepted_role_ids)<>0 OR scene56_source.last_publication_id IS NOT NULL OR scene56_source.board_start_receipt_id IS NULL))
   OR (scene56_source.request_kind='narration' AND cardinality(scene56_source.accepted_role_ids)<1)
   OR scene56_source.request_kind NOT IN('initial_opening','narration')
  THEN RAISE EXCEPTION 'SCENE56_READER_FROZEN_ROLES_OR_PUBLICATION' USING ERRCODE='PT409';END IF;
  RETURN scene56_doc;
 END IF;
 IF (wc.master_session_id,wc.definition_sha256,wc.payload_sha256)
  IS DISTINCT FROM (w.master_session_id,w.definition_sha256,w.payload_sha256)
 OR wc.contract_sha256 IS DISTINCT FROM public.combat_v2_sha256(wc.contract)
 OR w.payload_sha256 IS DISTINCT FROM public.combat_v2_sha256(w.payload)
 THEN RAISE EXCEPTION 'NARRATIVE_WORK_CONTRACT_DRIFT' USING ERRCODE='40001'; END IF;
 IF NOT(wc.contract->'features' ? 'execution_authority_v1') AND (wc.scope='public_quest') IS DISTINCT FROM (wc.contract->>'schema_version'='mission-narrative-admission/3') THEN RAISE EXCEPTION 'NARRATIVE_ADMISSION_SCOPE_VERSION' USING ERRCODE='40001';END IF;
 IF wc.contract->>'schema_version' IN('mission-narrative-admission/2','mission-narrative-admission/3') THEN
  a:=wc.contract->'source_attestation';
  IF jsonb_typeof(a) IS DISTINCT FROM 'object'
   OR a->>'schema_version' IS DISTINCT FROM 'mission-narrative-source-attestation/1'
   OR (a->>'work_id',a->>'master_session_id',a->>'definition_sha256',a->>'payload_sha256',a->>'release_sha256',a->>'authority_receipt_id')
    IS DISTINCT FROM (w.id::text,w.master_session_id::text,w.definition_sha256,w.payload_sha256,wc.release_sha256,w.authority_receipt_id::text)
   OR jsonb_typeof(a->'continuity_sources') IS DISTINCT FROM 'array'
   OR jsonb_typeof(a->'director_progression_sources') IS DISTINCT FROM 'array'
  THEN RAISE EXCEPTION 'NARRATIVE_ATTESTATION_BINDING' USING ERRCODE='40001'; END IF;
  FOR descriptor IN SELECT value FROM jsonb_array_elements(a->'continuity_sources') LOOP
   IF jsonb_typeof(descriptor->'path') IS DISTINCT FROM 'array'
   THEN RAISE EXCEPTION 'NARRATIVE_CONTINUITY_PATH_SHAPE'; END IF;
   SELECT coalesce(array_agg(value ORDER BY ordinality),'{}'::text[]) INTO path
    FROM jsonb_array_elements_text(descriptor->'path') WITH ORDINALITY;
   IF w.kind<>'narration' OR NOT (
    (cardinality(path)=0 AND w.payload->>'schema_version' IN ('mission-generic-narration/1','mission-generic-narration/2'))
    OR (w.payload->>'schema_version' IN ('mission-generic-narration/3','mission-generic-narration/4') AND (
      (cardinality(path)=1 AND path[1] IN ('mission_context','source_context'))
      OR (cardinality(path) IN (2,3) AND path[1]='resolved_scenes' AND path[2]~'^[0-9]+$'
        AND (cardinality(path)=2 OR path[3]='native_scene')))))
   OR path::text=ANY(seen)
   THEN RAISE EXCEPTION 'NARRATIVE_CONTINUITY_PATH_FORBIDDEN' USING ERRCODE='42501'; END IF;
   seen:=array_append(seen,path::text);node:=w.payload#>path;
   actual:=mission_public_owner.continuity_node_attest_v1(node,path,descriptor->>'shape');
   IF actual IS NULL OR actual IS DISTINCT FROM descriptor
   THEN RAISE EXCEPTION 'NARRATIVE_CONTINUITY_NODE_DRIFT' USING ERRCODE='40001'; END IF;
  END LOOP;
  IF (jsonb_array_length(a->'continuity_sources')>0) IS DISTINCT FROM (wc.contract->'features' ? 'continuity_sources_v1')
  THEN RAISE EXCEPTION 'NARRATIVE_CONTINUITY_FEATURE_DRIFT'; END IF;
  FOR descriptor IN SELECT value FROM jsonb_array_elements(a->'director_progression_sources') LOOP
   IF w.kind<>'director' OR descriptor->'path' IS DISTINCT FROM '["context","prior_progression"]'::jsonb
    OR descriptor->>'node_sha256' IS DISTINCT FROM public.combat_v2_sha256(w.payload#>'{context,prior_progression}')
   THEN RAISE EXCEPTION 'NARRATIVE_DIRECTOR_PROGRESSION_DRIFT' USING ERRCODE='40001'; END IF;
  END LOOP;
  IF jsonb_array_length(a->'director_progression_sources')>1
  THEN RAISE EXCEPTION 'NARRATIVE_DIRECTOR_PROGRESSION_MULTIPLE'; END IF;
  IF (jsonb_typeof(a->'peaceful_exit')='object') IS DISTINCT FROM (wc.contract->'features' ? 'peaceful_exit_v1')
  THEN RAISE EXCEPTION 'NARRATIVE_PEACEFUL_FEATURE_DRIFT'; END IF;
 END IF;
 IF wc.contract->'features' ? 'execution_authority_v1' THEN
  IF mission_generic_owner.c1266_historical_work_v1(w.id) IS NULL OR wc.scope NOT IN('staff_mission','public_mission') THEN RAISE EXCEPTION 'C1266_NARRATIVE5_HISTORY_BINDING' USING ERRCODE='40001';END IF;
 END IF;
 IF wc.contract->'features' ? 'role_intents_v2' THEN
  IF wc.contract->'features' ? 'role_intents_v1' OR (wc.scope IS DISTINCT FROM 'staff_mission' AND mission_generic_owner.c1266_historical_work_v1(w.id) IS NULL) OR wc.contract#>'{source_attestation,role_intents}' IS DISTINCT FROM mission_generic_owner.c1266_role_work_attest_v2(w.id) THEN RAISE EXCEPTION 'C1266_TEMPORAL_FEATURE_ATTESTATION_DRIFT' USING ERRCODE='40001';END IF;
 ELSIF wc.contract->'features' ? 'role_intents_v1' THEN
  IF (wc.scope IS DISTINCT FROM 'staff_mission' AND NOT(wc.contract->'features' ? 'execution_authority_v1'))
   OR wc.contract#>'{source_attestation,role_intents}' IS DISTINCT FROM mission_generic_owner.c1266_role_work_attest_v1(w.id)
  THEN RAISE EXCEPTION 'C1266_ROLE_FEATURE_ATTESTATION_DRIFT' USING ERRCODE='40001';END IF;
 ELSIF w.payload->>'schema_version' IN('mission-director-work/3','mission-director-work/4') OR w.payload ? 'role_interpretation' THEN
  RAISE EXCEPTION 'C1266_ROLE_FEATURE_REQUIRED' USING ERRCODE='42501';
 END IF;
 RETURN wc.contract;
END $$;
COMMIT;

CREATE OR REPLACE FUNCTION mission_generic_owner.close_core(p_session uuid, p_mission_outcome text, p_mission_note text, p_close_role boolean, p_expected_control_version bigint, p_request_key uuid, p_capability uuid)
 RETURNS jsonb
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO ''
AS $function$
declare v_uid uuid:=null::uuid; v_cap uuid:=p_capability; v_m public.master_v2_sessions%rowtype; v_step public.master_v2_closure_steps%rowtype;
  v_event jsonb; v_event_id uuid; v_result jsonb; v_role uuid; v_done int; v_sim boolean;
  scene56 mission_narrative_internal.scene_runtime_v1; finish56 mission_generic_owner.staff_finish_receipts_v1; proof56 jsonb; run56 public.mission_run_state;
begin
  perform public.master_v2_lock_scope(p_session);
  v_sim:=mission_generic_owner.finish_scope(p_session,p_capability,case when p_mission_outcome='successo' then 'success' else 'failure' end);
  select * into v_m from public.master_v2_sessions where id=p_session for update;
  if v_m.id is null then perform public.combat_v2_fail('sessione_inesistente','Sessione inesistente.',404,p_request_key,'{}'); end if;
  if (v_m.owner_kind<>'ai_service' or v_m.master_user is not null or v_cap is null) then perform public.combat_v2_fail('master_non_proprietario','Chiusura non consentita.',403,p_request_key,'{}'); end if;
  if v_m.control_version<>p_expected_control_version then perform public.combat_v2_fail('versione_controllo_obsoleta','Versione controllo obsoleta.',409,p_request_key,'{}'); end if;
  if v_m.tipo='quest' and v_m.mission_id is not null and p_mission_outcome not in ('successo','fallimento') then perform public.combat_v2_fail('missione_non_finalizzabile','Esito missione non valido.',422,p_request_key,'{}'); end if;
  v_event:=public.combat_v2_event_begin_ai_service(p_session,p_request_key,'mission_generic_close',jsonb_build_object('outcome',p_mission_outcome,'note',p_mission_note,'close_role',p_close_role,'expected',p_expected_control_version),p_expected_control_version,v_cap);
  if (v_event->>'replay')::boolean then return v_event->'result'; end if; v_event_id:=(v_event->>'event_id')::uuid;
  if v_m.stato not in ('chiusura','chiusa') then update public.master_v2_sessions set stato='chiusura' where id=p_session; end if;
  select * into v_step from public.master_v2_closure_steps where session_id=p_session and state<>'completato' order by position limit 1 for update;
  if v_step.id is null then
    v_result:=public.combat_v2_envelope(p_request_key,jsonb_build_object('state','chiusa','completed_steps',(select count(*) from public.master_v2_closure_steps where session_id=p_session)));
    return public.combat_v2_event_complete(v_event_id,v_result);
  end if;
  update public.master_v2_closure_steps set state='in_corso',attempts=attempts+1,started_at=coalesce(started_at,clock_timestamp()),request_key=p_request_key where id=v_step.id;
  if v_step.step_name='encounter_resolved' then
    if exists(select 1 from public.combat_v2_sessions where master_session_id=p_session and state not in ('risolto','chiuso','annullato')) then perform public.combat_v2_fail('referto_non_completo','Encounter non terminale.',409,p_request_key,'{}'); end if;
  elsif v_step.step_name='final_report_published' then
    if exists(select 1 from public.combat_v2_sessions s join public.combat_v2_rounds r on r.session_id=s.id where s.master_session_id=p_session and r.state<>'narrato') then perform public.combat_v2_fail('referto_non_completo','Esiste un round non narrato.',409,p_request_key,'{}'); end if;
  elsif v_step.step_name='mission_run_terminalized' then
    IF EXISTS(SELECT 1 FROM mission_narrative_internal.scene_runtime_v1 WHERE master_session_id=p_session AND is_active) THEN
      SELECT * INTO STRICT scene56 FROM mission_narrative_internal.scene_runtime_v1 WHERE master_session_id=p_session AND is_active FOR UPDATE;
      SELECT * INTO STRICT run56 FROM public.mission_run_state WHERE master_session_id=p_session FOR UPDATE;
      SELECT * INTO STRICT finish56 FROM mission_generic_owner.staff_finish_receipts_v1 WHERE master_session_id=p_session AND state='preparing' AND transaction_id=txid_current() FOR UPDATE;
      proof56:=mission_narrative_internal.scene_finish_proof_v1(p_session,finish56.actor_user_id);
      IF v_sim IS DISTINCT FROM true OR p_mission_outcome IS DISTINCT FROM 'successo'
       OR run56.run_phase IS DISTINCT FROM 'conclusa' OR scene56.mode IS DISTINCT FROM 'closed' OR scene56.turn_owner IS DISTINCT FROM 'closed'
       OR scene56.current_phase_key IS DISTINCT FROM run56.current_step_key OR scene56.state_version<1
       OR proof56->'can_finish' IS DISTINCT FROM 'true'::jsonb
       OR finish56.source_revision IS DISTINCT FROM proof56->>'source_revision'
       OR finish56.publication_id::text IS DISTINCT FROM proof56->>'publication_id'
       OR finish56.request_key::text IS DISTINCT FROM proof56->>'request_key'
       OR finish56.history_proof IS DISTINCT FROM proof56->'history_items'
       OR finish56.history_proof_sha256 IS DISTINCT FROM public.combat_v2_sha256(proof56->'history_items')
       OR finish56.release_sha256 IS DISTINCT FROM (SELECT revision_sha256 FROM mission_factory_owner.editor_release_readiness WHERE singleton)
       OR finish56.work_snapshot_sha256 IS DISTINCT FROM (SELECT public.combat_v2_sha256(coalesce(jsonb_agg(to_jsonb(work56) ORDER BY work56.id),'[]'::jsonb)) FROM mission_generic_owner.work_items work56 WHERE work56.master_session_id=p_session)
      THEN RAISE EXCEPTION 'N56_FINISH_TERMINAL_PROOF_CONFLICT' USING ERRCODE='PT409';END IF;
      -- The published Scene already terminalized this run. The normal closure step below records completion without a second run event.
    ELSE
    perform mission_internal.close_from_master(
      p_session,p_request_key,p_expected_control_version,
      case when p_mission_outcome='successo' then 'success' else 'failure' end,
      encode(extensions.digest(coalesce(p_mission_note,''),'sha256'),'hex')
    );
    END IF;
  elsif v_step.step_name='mission_finalized' then
    if not v_sim and v_m.tipo='quest' and v_m.mission_id is not null then
      if exists(select 1 from public.missions x where x.id=v_m.mission_id and x.status in ('aperta','programmata')) then
        perform mission_generic_owner.mission_result(p_session,p_capability,v_m.mission_id,p_mission_outcome='successo',p_mission_note);
      elsif not exists(select 1 from public.missions x where x.id=v_m.mission_id and x.status=case when p_mission_outcome='successo' then 'completata' else 'fallita' end) then
        perform public.combat_v2_fail('missione_non_finalizzabile','Missione terminale con esito diverso.',409,p_request_key,'{}');
      end if;
    end if;
  elsif v_step.step_name='role_segment_finalized' then
    if p_close_role and not v_sim then
      for v_role in select role_session_id from public.master_v2_mechanical_role_segments where master_session_id=p_session and closed_at is null order by segment_no loop
        perform public._role_finalize(v_role,'master_v2');
        update public.master_v2_mechanical_role_segments set closed_at=(select closed_at from public.role_sessions where id=v_role) where role_session_id=v_role;
      end loop;
    end if;
  elsif v_step.step_name='master_session_closed' then
    update public.combat_v2_sessions set state='chiuso',closed_at=coalesce(closed_at,clock_timestamp()) where master_session_id=p_session and state in ('risolto','annullato');
    PERFORM combat_effects_private.lifecycle_session_end(s.id) FROM public.combat_v2_sessions s WHERE s.master_session_id=p_session AND s.closed_at IS NOT NULL;
    update public.master_v2_participants set engagement_state='concluso',left_at=coalesce(left_at,clock_timestamp()) where session_id=p_session;
    update public.master_v2_sessions set stato='chiusa',closed_at=clock_timestamp(),close_reason='completata' where id=p_session;
  end if;
  update public.master_v2_closure_steps set state='completato',completed_at=clock_timestamp(),result=jsonb_build_object('ok',true) where id=v_step.id;
  select count(*) into v_done from public.master_v2_closure_steps where session_id=p_session and state='completato';
  if v_done=(select count(*) from public.master_v2_closure_steps where session_id=p_session) then
    v_result:=public.combat_v2_envelope(p_request_key,jsonb_build_object('state','chiusa','completed_steps',(select count(*) from public.master_v2_closure_steps where session_id=p_session)));
    return public.combat_v2_event_complete(v_event_id,v_result);
  end if;
  -- Evento volutamente in_corso: il retry con la stessa chiave avanza un solo passo atomico.
  return public.combat_v2_envelope(p_request_key,jsonb_build_object('state','chiusura','completed_steps',v_done,'next_retry_same_key',true));
end $function$
;
