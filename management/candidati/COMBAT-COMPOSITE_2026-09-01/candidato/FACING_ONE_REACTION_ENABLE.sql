BEGIN;
SET LOCAL lock_timeout='4s';
DO $enable$
DECLARE
  test_session constant uuid := 'a447bc60-9088-469f-9732-23f4a5c1bdd2';
  test_round constant uuid := 'e23a7764-f6b4-44dd-9358-2ee053a52682';
BEGIN
 IF current_user<>'postgres' OR auth.uid() IS NOT NULL
 OR NOT EXISTS(SELECT 1 FROM mission_factory_owner.editor_release_readiness
   WHERE singleton AND revision_sha256='f9ad89a82dfc1912f042907a6ad7a6b7196370abbf288f1fdd3e52f31de664f1'
     AND observed_revision_sha256=revision_sha256 FOR UPDATE)
 OR NOT EXISTS(SELECT 1 FROM combat_panel_private.multiplication_tactics_release_gate
   WHERE singleton AND NOT ordinary_enabled AND NOT master_enabled AND NOT generic_enabled FOR SHARE)
 OR EXISTS(SELECT 1 FROM public.combat_v2_sessions WHERE closed_at IS NULL)
 OR EXISTS(SELECT 1 FROM public.master_v2_sessions WHERE closed_at IS NULL
   AND stato IN ('preparazione','in_corso','sospesa','chiusura'))
 OR NOT EXISTS(SELECT 1 FROM public.combat_v2_sessions s JOIN public.combat_v2_rounds r ON r.session_id=s.id
   WHERE s.id=test_session AND r.id=test_round AND r.phase='narrato' AND s.closed_at IS NOT NULL
     AND s.location_id='0b85f354-9cdb-47e1-baf9-3d266bb7e06b' AND public.combat_v2_values_written(s.id) IS FALSE)
 OR NOT EXISTS(SELECT 1 FROM combat_facing_private.defense_receipts f
   WHERE f.id='7068f8af-e417-44c8-bf42-ac9c3688f3c9' AND f.round_id=test_round
     AND f.session_id=test_session AND f.level=1 AND f.rear AND f.deduction=3
     AND f.geometry->'dot'='-4'::jsonb)
 OR (SELECT count(*) FROM combat_facing_private.defense_receipts f WHERE f.round_id=test_round)<>1
 OR (SELECT count(*) FROM public.combat_v2_attack_targets t WHERE t.round_id=test_round AND t.state='risolta')<>2
 OR NOT EXISTS(SELECT 1 FROM public.combat_v2_attack_targets t
   JOIN public.combat_v2_declarations atk ON atk.id=t.attack_declaration_id
   JOIN public.combat_v2_declarations d ON d.parent_attack_id=atk.id AND d.actor_id=t.target_actor_id
   JOIN combat_facing_private.defense_receipts f ON f.round_id=t.round_id AND f.defender_actor_id=t.target_actor_id
   JOIN public.combat_v2_declarations defended ON defended.id=f.attack_declaration_id
   WHERE t.round_id=test_round AND d.kind='nessuna' AND atk.actor_id<>defended.actor_id)
 THEN RAISE EXCEPTION 'FACING_PUBLIC_PRECONDITIONS'; END IF;
 PERFORM clan_innata_private.runtime_release_assert();
 UPDATE combat_facing_private.release_gate SET public_enabled=true, revision=revision+1
 WHERE singleton AND revision=2 AND staff_enabled AND NOT public_enabled AND contract_version='byakugan-facing/1';
 IF NOT FOUND THEN RAISE EXCEPTION 'FACING_PUBLIC_GATE_DRIFT'; END IF;
 PERFORM clan_innata_private.runtime_release_assert();
END $enable$;
COMMIT;
