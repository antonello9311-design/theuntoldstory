BEGIN;
DO $pin$ BEGIN
 IF NOT EXISTS(SELECT 1 FROM information_schema.columns WHERE table_schema='combat_v2_elemental_internal' AND table_name='other_gates' AND column_name='public_enabled') THEN RAISE EXCEPTION 'grande_sfondamento_public025_recovery_drift'; END IF;
END $pin$;
UPDATE combat_v2_elemental_internal.other_gates
 SET public_enabled=false
WHERE technique_id='d5605069-b381-41ad-8e6a-9c24a314c58f'::uuid;
DO $post$ BEGIN
 IF EXISTS(SELECT 1 FROM combat_v2_elemental_internal.other_gates WHERE technique_id='d5605069-b381-41ad-8e6a-9c24a314c58f'::uuid AND public_enabled) THEN RAISE EXCEPTION 'grande_sfondamento_public025_recovery_failed'; END IF;
END $post$;
COMMIT;
