BEGIN;
SET LOCAL lock_timeout='5s';
LOCK TABLE public.combat_v2_sessions IN SHARE MODE;
DO $gate$
BEGIN
 IF EXISTS(SELECT 1 FROM public.combat_v2_sessions WHERE closed_at IS NULL)
 THEN RAISE EXCEPTION 'inuzuka_open_combat_sessions';END IF;
 UPDATE clan_inuzuka_private.release_gate SET public_enabled=false,version=3
  WHERE singleton AND staff_enabled AND public_enabled AND version=2;
 IF NOT FOUND THEN RAISE EXCEPTION 'inuzuka_public_gate_version_changed';END IF;
 IF NOT EXISTS(SELECT 1 FROM clan_inuzuka_private.release_gate WHERE singleton AND staff_enabled AND NOT public_enabled AND version=3)
 THEN RAISE EXCEPTION 'inuzuka_public_recovery_failed';END IF;
END;
$gate$;
COMMIT;
