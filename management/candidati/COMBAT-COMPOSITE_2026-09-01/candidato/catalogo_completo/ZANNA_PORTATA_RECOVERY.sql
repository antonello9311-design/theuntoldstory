-- Ripristino della portata descrittiva di Zanna Perforante.
BEGIN;
DO $metadata$
#variable_conflict error
DECLARE
    v_id constant uuid := 'b076a976-c75b-4b5a-8813-b0e8e2c3af03';
    v_before_sha constant text := '158c6a3051c267eeb123dfc537560c5b1ae34962e4d556b7d55ef7b5ce6b6e90';
    v_after_sha constant text := 'a637815c68abe10648b9d6d0b076ae0c4523ff02141bbf83eb3fc1f5bb675c60';
    v_portata constant text := $portata$Corto$portata$;
    v_before jsonb;
    v_after jsonb;
BEGIN
    LOCK TABLE public.clan_techniques IN ROW EXCLUSIVE MODE;

    IF EXISTS (
        SELECT FROM pg_catalog.pg_trigger AS tr
        WHERE tr.tgrelid = 'public.clan_techniques'::regclass
          AND NOT tr.tgisinternal AND tr.tgenabled <> 'D'
    ) THEN
        RAISE EXCEPTION 'ZANNA_PORTATA_TRIGGER_DRIFT';
    END IF;

    SELECT to_jsonb(ct) INTO STRICT v_before
    FROM public.clan_techniques AS ct
    WHERE ct.id = v_id AND ct.is_active
    FOR UPDATE;

    IF public.combat_v2_sha256(v_before) IS DISTINCT FROM v_before_sha THEN
        RAISE EXCEPTION 'ZANNA_PORTATA_ROW_DRIFT';
    END IF;

    UPDATE public.clan_techniques AS ct
    SET portata = v_portata
    WHERE ct.id = v_id AND ct.is_active;

    SELECT to_jsonb(ct) INTO STRICT v_after
    FROM public.clan_techniques AS ct
    WHERE ct.id = v_id;

    IF v_after IS DISTINCT FROM (v_before || jsonb_build_object('portata', v_portata))
        OR public.combat_v2_sha256(v_after) IS DISTINCT FROM v_after_sha THEN
        RAISE EXCEPTION 'ZANNA_PORTATA_UNEXPECTED_DELTA';
    END IF;
END
$metadata$;
COMMIT;
