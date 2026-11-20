-- Zanna Perforante · correzione esclusiva del testo requisiti.
BEGIN;
DO $zanna_editorial$
#variable_conflict error
DECLARE
    v_row_id constant uuid := 'b076a976-c75b-4b5a-8813-b0e8e2c3af03';
    v_row jsonb;
    v_expected jsonb;
    v_result jsonb;
BEGIN
    LOCK TABLE public.clan_techniques IN ROW EXCLUSIVE MODE;
    IF EXISTS (
        SELECT FROM pg_catalog.pg_trigger AS tr
        WHERE tr.tgrelid = 'public.clan_techniques'::regclass
          AND NOT tr.tgisinternal AND tr.tgenabled <> 'D'
    ) THEN
        RAISE EXCEPTION 'ZANNA_REQUIREMENTS_TRIGGER_DRIFT';
    END IF;

    SELECT to_jsonb(ct) INTO STRICT v_row
    FROM public.clan_techniques AS ct
    WHERE ct.id = v_row_id AND ct.is_active
    FOR UPDATE;

    IF public.combat_v2_sha256(v_row) IS DISTINCT FROM '158c6a3051c267eeb123dfc537560c5b1ae34962e4d556b7d55ef7b5ce6b6e90'
        OR v_row->>'requirements' IS DISTINCT FROM $req$Quattro Zampe · grado Genin · Kekkei Genkai ≥ 40$req$
        OR v_row->'req_stat_value' IS DISTINCT FROM '30'::jsonb THEN
        RAISE EXCEPTION 'ZANNA_REQUIREMENTS_BASELINE_DRIFT';
    END IF;

    v_expected := v_row || jsonb_build_object('requirements', $req$Quattro Zampe · grado Genin · Kekkei Genkai ≥ 30$req$::text);

    UPDATE public.clan_techniques AS ct
    SET requirements = $req$Quattro Zampe · grado Genin · Kekkei Genkai ≥ 30$req$
    WHERE ct.id = v_row_id AND ct.is_active
    RETURNING to_jsonb(ct) INTO STRICT v_result;

    IF v_result IS DISTINCT FROM v_expected
        OR public.combat_v2_sha256(v_result) IS DISTINCT FROM 'd4d3dfad272c109ca83ea6fee380f8b6ffa453f332d04268514b13a579132da3' THEN
        RAISE EXCEPTION 'ZANNA_REQUIREMENTS_UNEXPECTED_DELTA';
    END IF;
END
$zanna_editorial$;
COMMIT;
