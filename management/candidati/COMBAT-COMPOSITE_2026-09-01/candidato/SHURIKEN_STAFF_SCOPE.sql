DO $hotfix$
DECLARE v_definition text:=pg_get_functiondef('combat_panel_private.shuriken_pool_v1(uuid)'::regprocedure);
BEGIN
  IF md5(v_definition)<>'723a42d887128327be7f01970d048ce6' THEN
    RAISE EXCEPTION 'Shuriken pool baseline drift';
  END IF;
  EXECUTE replace(replace(replace(v_definition,
    'AND combat_panel_private.uses_simulated_pools(s.id) THEN ''staff''',
    $staff$AND CASE s.source_kind
        WHEN 'master' THEN EXISTS (
          SELECT 1 FROM combat_panel_private.master_scene_claims claim
          JOIN combat_spatial.arena_instances arena ON arena.panel_claim_id=claim.id
            AND arena.encounter_id=s.id AND arena.state='open'
          WHERE claim.encounter_id=s.id AND claim.master_session_id=s.master_session_id
            AND claim.policy_id='staff_test_no_persistent_resources_v1'
        )
        WHEN 'ordinary' THEN EXISTS (
          SELECT 1 FROM combat_consumer_private.activities act
          WHERE act.session_id=s.id AND act.policy_id='staff_test_no_persistent_resources_v1'
            AND act.closed_at IS NULL AND act.phase<>'closed'
        )
        ELSE false END
      AND NOT EXISTS (SELECT 1 FROM exam_regia_private.bindings b WHERE b.combat_session_id=s.id)
      AND NOT EXISTS (SELECT 1 FROM exam_human_private.native_bindings b WHERE b.master_session_id=s.master_session_id)
      AND combat_panel_private.uses_simulated_pools(s.id) THEN 'staff'$staff$),
    'l.is_test IS FALSE AND combat_panel_private.shuriken_public_enabled_v1()',
    'l.is_test IS FALSE AND l.is_exam_room IS NOT TRUE AND combat_panel_private.shuriken_public_enabled_v1()'),
    'l.is_active AND l.is_exam_room IS NOT TRUE','l.is_active');
END
$hotfix$;
