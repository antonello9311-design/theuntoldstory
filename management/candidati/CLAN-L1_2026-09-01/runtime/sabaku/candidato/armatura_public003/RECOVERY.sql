BEGIN;

DO $pre$
BEGIN
  IF NOT EXISTS (
    SELECT 1
    FROM clan_sabaku_private.armor_release_gate
    WHERE singleton AND staff_enabled AND public_enabled
  ) THEN
    RAISE EXCEPTION 'armor_public_recovery_preflight_failed';
  END IF;
END $pre$;

UPDATE clan_sabaku_private.armor_release_gate
SET public_enabled = false
WHERE singleton AND staff_enabled AND public_enabled;

DO $post$
BEGIN
  IF NOT EXISTS (
    SELECT 1
    FROM clan_sabaku_private.armor_release_gate
    WHERE singleton AND staff_enabled AND NOT public_enabled
  ) THEN
    RAISE EXCEPTION 'armor_public_recovery_failed';
  END IF;
END $post$;

COMMIT;
