BEGIN;
SET LOCAL lock_timeout = '4s';
DO $archive$
DECLARE room constant uuid := '0b85f354-9cdb-47e1-baf9-3d266bb7e06b';
BEGIN
  IF current_user <> 'postgres' OR auth.uid() IS NOT NULL
  THEN RAISE EXCEPTION 'STAFF_ARCHIVE_OWNER_ONLY'; END IF;
  PERFORM 1 FROM public.locations WHERE id = room AND is_test AND is_active FOR UPDATE;
  IF NOT FOUND
    OR EXISTS (SELECT 1 FROM public.role_sessions WHERE location_id = room AND closed_at IS NULL)
    OR EXISTS (SELECT 1 FROM public.combat_v2_sessions WHERE location_id = room AND closed_at IS NULL)
    OR EXISTS (SELECT 1 FROM public.master_v2_sessions WHERE location_id = room AND closed_at IS NULL)
    OR EXISTS (SELECT 1 FROM public.combat_sessions WHERE location_id = room AND closed_at IS NULL)
    OR EXISTS (SELECT 1 FROM public.esame_prove e JOIN public.academy_class_sessions c ON c.id = e.class_session_id
      WHERE c.location_id = room AND e.closed_at IS NULL AND e.stato = 'aperta')
  THEN RAISE EXCEPTION 'STAFF_ARCHIVE_ACTIVE_OR_WRONG_ROOM'; END IF;

  WITH completed_combat AS (
    SELECT r.id FROM public.combat_v2_rounds r JOIN public.combat_v2_sessions s ON s.id = r.session_id
    WHERE s.location_id = room AND s.closed_at IS NOT NULL
      AND (s.master_session_id IS NULL OR EXISTS (
        SELECT 1 FROM public.master_v2_sessions m WHERE m.id = s.master_session_id AND m.closed_at IS NOT NULL))
  ), completed_master AS (
    SELECT id FROM public.master_v2_sessions WHERE location_id = room AND closed_at IS NOT NULL
  ), linked_messages AS (
    SELECT dm.message_id FROM combat_consumer_private.declaration_messages dm
    JOIN public.combat_v2_declarations d ON d.id = dm.declaration_id JOIN completed_combat c ON c.id = d.round_id
    UNION
    SELECT r.message_id FROM public.combat_v2_round_reports r JOIN completed_combat c ON c.id = r.round_id
    UNION
    SELECT r.message_id FROM mission_generic_owner.role_submissions r JOIN completed_master m ON m.id = r.master_session_id
    UNION
    SELECT w.publication_id FROM mission_generic_owner.unified_round_windows w JOIN completed_master m ON m.id = w.master_session_id
  )
  INSERT INTO combat_panel_private.staff_archived_messages (message_id)
  SELECT m.id FROM linked_messages l JOIN public.messages m ON m.id = l.message_id
  WHERE m.location_id = room
  ON CONFLICT (message_id) DO NOTHING;
END
$archive$;
COMMIT;
