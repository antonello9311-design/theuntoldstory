BEGIN;
SET LOCAL lock_timeout='4s';
DO $stop$ BEGIN
 IF current_user<>'postgres' OR auth.uid() IS NOT NULL THEN RAISE EXCEPTION 'FACING_PUBLIC_OPERATOR'; END IF;
 UPDATE combat_facing_private.release_gate SET public_enabled=false, revision=revision+1
 WHERE singleton AND revision=3 AND public_enabled AND contract_version='byakugan-facing/1';
 IF NOT FOUND THEN RAISE EXCEPTION 'FACING_PUBLIC_GATE_DRIFT'; END IF;
END $stop$;
COMMIT;
