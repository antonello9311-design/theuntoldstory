-- Ritiro esplicito Antonello: soltanto il doppione Attivazione Sigilli.
BEGIN;
DO $sigilli_retire$
DECLARE row_before jsonb;row_after jsonb;others_before text;others_after text;n integer;
BEGIN
 IF current_user<>'postgres' OR session_user<>'postgres' OR auth.uid() IS NOT NULL THEN
  RAISE EXCEPTION 'SIGILLI_RETIRE_OPERATOR_REQUIRED';END IF;
 LOCK TABLE public.clan_techniques IN SHARE ROW EXCLUSIVE MODE NOWAIT;
 SELECT to_jsonb(t) INTO STRICT row_before FROM public.clan_techniques t
 WHERE id='29ecdd97-c224-4bca-8bf9-efb17ebe70f3' FOR UPDATE;
 IF row_before->>'name' IS DISTINCT FROM 'Attivazione Sigilli'
 OR row_before->'is_active' IS DISTINCT FROM 'true'::jsonb
 OR public.combat_v2_sha256(row_before) IS DISTINCT FROM '6134750ccdbc5a31d9bd53145d38f11e21677fee2c999dfa4173f998f62400a6' THEN
  RAISE EXCEPTION 'SIGILLI_RETIRE_TARGET_DRIFT';END IF;
 SELECT public.combat_v2_sha256(coalesce(jsonb_agg(to_jsonb(t)ORDER BY t.id),'[]'::jsonb))
 INTO others_before FROM public.clan_techniques t WHERE id<>'29ecdd97-c224-4bca-8bf9-efb17ebe70f3';
 UPDATE public.clan_techniques t SET is_active=false
 WHERE id='29ecdd97-c224-4bca-8bf9-efb17ebe70f3'
 AND public.combat_v2_sha256(to_jsonb(t))='6134750ccdbc5a31d9bd53145d38f11e21677fee2c999dfa4173f998f62400a6';
 GET DIAGNOSTICS n=ROW_COUNT;
 IF n<>1 THEN RAISE EXCEPTION 'SIGILLI_RETIRE_ROW_COUNT';END IF;
 SELECT to_jsonb(t) INTO STRICT row_after FROM public.clan_techniques t WHERE id='29ecdd97-c224-4bca-8bf9-efb17ebe70f3';
 IF row_after IS DISTINCT FROM jsonb_set(row_before,'{is_active}','false'::jsonb,false)
 OR public.combat_v2_sha256(row_after) IS DISTINCT FROM 'b3a9cab178fa9507d1c718bca95c0944c6f80ac9d102fd5de57f8931a1ab0b93' THEN
  RAISE EXCEPTION 'SIGILLI_RETIRE_AFTER_IMAGE';END IF;
 SELECT public.combat_v2_sha256(coalesce(jsonb_agg(to_jsonb(t)ORDER BY t.id),'[]'::jsonb))
 INTO others_after FROM public.clan_techniques t WHERE id<>'29ecdd97-c224-4bca-8bf9-efb17ebe70f3';
 IF others_after IS DISTINCT FROM others_before THEN RAISE EXCEPTION 'SIGILLI_RETIRE_OTHER_ROWS_CHANGED';END IF;
END $sigilli_retire$;
COMMIT;
