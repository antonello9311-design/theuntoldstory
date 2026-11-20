-- Allineamento delle portate di Scudo di terra, Palla di Fuoco e Armatura di Sabbia.
BEGIN;
DO $metadata$
#variable_conflict error
DECLARE
    v_delta record;
    v_before_row jsonb;
    v_expected_row jsonb;
    v_after_row jsonb;
BEGIN
    LOCK TABLE public.clan_techniques IN ROW EXCLUSIVE MODE;
    IF EXISTS (
        SELECT FROM pg_catalog.pg_trigger AS tr
        WHERE tr.tgrelid = 'public.clan_techniques'::regclass
          AND NOT tr.tgisinternal AND tr.tgenabled <> 'D'
    ) THEN
        RAISE EXCEPTION 'CATALOG_3_PORTATE_TRIGGER_DRIFT';
    END IF;

    FOR v_delta IN
        SELECT d.*
        FROM (VALUES
            ('1260dbc8-ab0c-4b2b-9b94-909d39b7ffbe'::uuid, '027062db39d087c5246ad3109d6d8f976ee52e652e0ec1595c13badf4558c1f0', 'e606236407c43d226aee96187067ea5c88fc9cbdc9665ce7f20ab638056fa1d2', $val$Fino a 20 m$val$, NULL::text, false),
            ('9061c022-ca82-4d2b-8102-e208fcc6c1a2'::uuid, 'b6977b3558fd632d8b806b352c01f0ad058b3628b47fd300269a91194978f082', '5b289cceaff25e33486bac9dd4d67aefbd50ef2b2528453256313d0105f6db4d', $val$Sé stesso (difesa personale)$val$, $val$Lo scudo protegge l’utilizzatore da un singolo attacco. Costa 5 chakra, anche in assenza di una fonte di terra, e segue il normale confronto difensivo. Può attenuare o arrestare l’attacco assorbendone l’urto prima di sfaldarsi. Si usa nella difesa senza spendere un’azione principale aggiuntiva. L’esito dipende dal confronto e lo scudo non infligge danno né resta come muro o copertura.$val$, true),
            ('bb9bd1d4-e0b2-4e20-9bd4-48d14fe8344d'::uuid, 'f39333fa6a648cc7a7138d071c3df1da732658eb5c5a93e689f6f1b8dccf40d2', '5f6d1a9f64eb9e6650935c74d1bc051d68b67c6cd2584e66544759a9017db145', $val$Sé stesso$val$, NULL::text, false)
        ) AS d(row_uuid, hash_before, hash_after, portata_value, effect_value, change_effect)
        ORDER BY d.row_uuid
    LOOP
        SELECT to_jsonb(ct) INTO STRICT v_before_row
        FROM public.clan_techniques AS ct
        WHERE ct.id = v_delta.row_uuid AND ct.is_active
        FOR UPDATE;

        IF public.combat_v2_sha256(v_before_row) IS DISTINCT FROM v_delta.hash_before THEN
            RAISE EXCEPTION 'CATALOG_3_PORTATE_ROW_DRIFT %', v_delta.row_uuid;
        END IF;
        v_expected_row := v_before_row || jsonb_build_object('portata', v_delta.portata_value);

        IF v_delta.change_effect THEN
            v_expected_row := v_expected_row || jsonb_build_object('danno_effetto', v_delta.effect_value);
            UPDATE public.clan_techniques AS ct
            SET portata = v_delta.portata_value, danno_effetto = v_delta.effect_value
            WHERE ct.id = v_delta.row_uuid AND ct.is_active;
        ELSE
            UPDATE public.clan_techniques AS ct
            SET portata = v_delta.portata_value
            WHERE ct.id = v_delta.row_uuid AND ct.is_active;
        END IF;

        SELECT to_jsonb(ct) INTO STRICT v_after_row
        FROM public.clan_techniques AS ct
        WHERE ct.id = v_delta.row_uuid;

        IF v_after_row IS DISTINCT FROM v_expected_row
            OR public.combat_v2_sha256(v_after_row) IS DISTINCT FROM v_delta.hash_after THEN
            RAISE EXCEPTION 'CATALOG_3_PORTATE_UNEXPECTED_DELTA %', v_delta.row_uuid;
        END IF;
    END LOOP;
END
$metadata$;
COMMIT;
