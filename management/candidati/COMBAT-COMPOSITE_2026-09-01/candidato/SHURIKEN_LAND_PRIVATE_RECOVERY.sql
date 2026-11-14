BEGIN;
DO $recovery$
DECLARE v_room uuid:=combat_panel_private.shuriken_qa_location_v1();
BEGIN
  PERFORM 1 FROM public.locations WHERE id=v_room FOR UPDATE;
  IF EXISTS(SELECT 1 FROM public.combat_v2_sessions
    WHERE location_id=v_room AND state NOT IN ('chiuso','annullato')) THEN
    RAISE EXCEPTION 'Close the protected encounter with the normal panel first';
  END IF;
  IF EXISTS(SELECT 1 FROM combat_consumer_private.invitations
    WHERE location_id=v_room AND state='pending') THEN
    RAISE EXCEPTION 'Close the pending protected invitation first';
  END IF;
  UPDATE public.locations SET is_active=false WHERE id=v_room;
  UPDATE combat_consumer_private.scene_profiles SET enabled=false WHERE location_id=v_room;
END
$recovery$;
REVOKE EXECUTE ON FUNCTION public.shuriken_qa_prepare_stock_v1() FROM authenticated;
REVOKE EXECUTE ON FUNCTION public.shuriken_qa_replay_v1() FROM authenticated;
-- Leave location and message access policies in place for retained evidence.
COMMIT;
