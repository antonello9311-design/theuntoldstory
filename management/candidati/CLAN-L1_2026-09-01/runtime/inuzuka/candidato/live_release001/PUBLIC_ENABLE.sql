-- Eseguire solo dopo LIVE_QA_RESULT verde nella Staff Test Room.
BEGIN;
SET LOCAL lock_timeout='5s';
SET LOCAL statement_timeout='60s';
DO $gate$
BEGIN
 IF NOT EXISTS(SELECT 1 FROM clan_inuzuka_private.release_gate WHERE singleton AND staff_enabled AND NOT public_enabled)
 THEN RAISE EXCEPTION 'inuzuka_staff_gate_invalid';END IF;
 IF NOT EXISTS(SELECT 1 FROM clan_inuzuka_private.ninken_profiles WHERE taglia='baby' AND profile_version='ninken-profile/1')
 THEN RAISE EXCEPTION 'inuzuka_baby_profile_missing';END IF;
 IF NOT EXISTS(SELECT 1 FROM public.clan_techniques WHERE id='c11ecd52-43cd-479b-8d5d-08187beba56e'
  AND is_active AND uso='rapida' AND chakra_cost=5 AND grado='D') THEN RAISE EXCEPTION 'inuzuka_quattro_catalog_not_final';END IF;
 IF NOT EXISTS(SELECT 1 FROM public.clan_techniques WHERE id='b076a976-c75b-4b5a-8813-b0e8e2c3af03'
  AND is_active AND name='Zanna Perforante' AND uso='principale' AND chakra_cost=5 AND grado='D')
 THEN RAISE EXCEPTION 'inuzuka_zanna_catalog_not_final';END IF;
 LOCK TABLE public.combat_v2_sessions IN SHARE MODE;
 IF EXISTS(SELECT 1 FROM public.combat_v2_sessions WHERE closed_at IS NULL) THEN RAISE EXCEPTION 'inuzuka_open_combat_sessions';END IF;
 UPDATE clan_inuzuka_private.release_gate SET public_enabled=true,version=2
  WHERE singleton AND staff_enabled AND NOT public_enabled AND version=1;
 IF NOT FOUND THEN RAISE EXCEPTION 'inuzuka_public_gate_version_changed';END IF;
 IF NOT EXISTS(SELECT 1 FROM clan_inuzuka_private.release_gate WHERE singleton AND staff_enabled AND public_enabled AND version=2)
 THEN RAISE EXCEPTION 'inuzuka_public_gate_failed';END IF;
END;
$gate$;
COMMIT;
