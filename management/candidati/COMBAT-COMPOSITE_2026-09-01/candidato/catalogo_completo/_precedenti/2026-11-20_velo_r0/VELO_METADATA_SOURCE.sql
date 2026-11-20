-- Il Velo è classificato secondo il regolamento pubblicato §8.9, punto 4.
BEGIN;
DO $velo_metadata$
DECLARE
  technique_id constant uuid := 'c9b261da-c9cd-40bb-8189-7b65ab5a1605';
  expected_before constant text := '6901226f7517ec24417ae07bd795e1b83221c82f2dd570355065af10a5159710';
  expected_after constant text := 'a79a36d47fe260c0db0d965703cef3b41d98c39530605382d6a8c68109d78229';
  row_before jsonb;
  row_after jsonb;
  other_rows_before text;
  other_rows_after text;
  changed_rows integer;
BEGIN
  IF current_user <> 'postgres' OR session_user <> 'postgres' OR auth.uid() IS NOT NULL THEN
    RAISE EXCEPTION 'VELO_METADATA_OPERATOR_REQUIRED';
  END IF;

  LOCK TABLE public.clan_techniques IN SHARE ROW EXCLUSIVE MODE NOWAIT;
  SELECT to_jsonb(t) INTO STRICT row_before
  FROM public.clan_techniques t
  WHERE t.id = technique_id
  FOR UPDATE NOWAIT;

  IF row_before->>'uso' IS DISTINCT FROM 'principale'
     OR public.combat_v2_sha256(row_before) IS DISTINCT FROM expected_before THEN
    RAISE EXCEPTION 'VELO_METADATA_TARGET_DRIFT';
  END IF;

  IF EXISTS (
    SELECT 1 FROM public.character_abilities a WHERE a.technique_id = technique_id
  ) OR EXISTS (
    SELECT 1
    FROM public.combat_v2_actors a
    JOIN public.combat_v2_sessions s ON s.id = a.session_id
    WHERE s.closed_at IS NULL
      AND a.mechanics_snapshot->'abilities' @> jsonb_build_array(jsonb_build_object('id', technique_id))
  ) THEN
    RAISE EXCEPTION 'VELO_METADATA_ACTIVE_CONSUMER_REVIEW_REQUIRED';
  END IF;

  SELECT public.combat_v2_sha256(coalesce(jsonb_agg(to_jsonb(t) ORDER BY t.id), '[]'::jsonb))
  INTO other_rows_before
  FROM public.clan_techniques t
  WHERE t.id <> technique_id;

  UPDATE public.clan_techniques t
  SET uso = 'rapida'
  WHERE t.id = technique_id
    AND public.combat_v2_sha256(to_jsonb(t)) = expected_before;
  GET DIAGNOSTICS changed_rows = ROW_COUNT;
  IF changed_rows <> 1 THEN
    RAISE EXCEPTION 'VELO_METADATA_ROW_COUNT';
  END IF;

  SELECT to_jsonb(t) INTO STRICT row_after
  FROM public.clan_techniques t
  WHERE t.id = technique_id;

  IF row_after IS DISTINCT FROM jsonb_set(row_before, '{uso}', to_jsonb('rapida'::text), false)
     OR public.combat_v2_sha256(row_after) IS DISTINCT FROM expected_after THEN
    RAISE EXCEPTION 'VELO_METADATA_AFTER_IMAGE';
  END IF;

  SELECT public.combat_v2_sha256(coalesce(jsonb_agg(to_jsonb(t) ORDER BY t.id), '[]'::jsonb))
  INTO other_rows_after
  FROM public.clan_techniques t
  WHERE t.id <> technique_id;
  IF other_rows_after IS DISTINCT FROM other_rows_before THEN
    RAISE EXCEPTION 'VELO_METADATA_OTHER_ROWS_CHANGED';
  END IF;
END
$velo_metadata$;
COMMIT;
