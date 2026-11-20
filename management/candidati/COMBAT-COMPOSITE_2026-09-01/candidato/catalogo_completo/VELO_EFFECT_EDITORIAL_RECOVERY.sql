-- Velo del Cercoterio. Ripristino condizionato del campo Effetto.
BEGIN;
SET LOCAL search_path = '';
SET LOCAL lock_timeout = '2s';
LOCK TABLE public.clan_techniques IN SHARE ROW EXCLUSIVE MODE;
DO $velo_editorial$
DECLARE
    before_row jsonb;
    after_row jsonb;
    expected_before constant text := '0d7f6c82fe80c2d6cfc5c9c4ac2a587a59af75a8b45964dec03ffc91d69533c6';
    expected_after constant text := 'a79a36d47fe260c0db0d965703cef3b41d98c39530605382d6a8c68109d78229';
    expected_other_rows constant text := '79d5f10763014b5fee70f04208869117d25c778e50178048a65634b7035993ab';
    expected_root constant text := '5b6fe3ddb8090da1423ddc83e21cac670ff605bf69a15d0fb53ecad8e12e9221';
    technique constant uuid := 'c9b261da-c9cd-40bb-8189-7b65ab5a1605'::uuid;
    canonical_effect constant text := $effect$Il Velo conferisce +5 Forza e +5 Velocità finché resta attivo. Si attiva come azione rapida con 5 chakra e ne consuma altri 5 all’inizio di ogni turno personale successivo. Il personaggio può disattivarlo gratuitamente. Il Velo è la forma senza code e contraccolpi.$effect$;
    previous_effect constant text := canonical_effect;
    new_effect constant text := NULL;
BEGIN
    IF current_user <> 'postgres' OR session_user <> 'postgres' OR auth.uid() IS NOT NULL THEN
        RAISE EXCEPTION 'VELO_EDITORIAL_OPERATOR';
    END IF;
    IF EXISTS (SELECT 1 FROM pg_trigger WHERE tgrelid = 'public.clan_techniques'::regclass AND NOT tgisinternal)
       OR EXISTS (SELECT 1 FROM public.combat_v2_sessions WHERE closed_at IS NULL)
       OR EXISTS (SELECT 1 FROM public.master_v2_sessions WHERE closed_at IS NULL AND stato NOT IN ('chiusa', 'annullata'))
       OR (SELECT public.combat_v2_sha256(to_jsonb(r)) FROM mission_factory_owner.editor_release_readiness r WHERE r.singleton)
          IS DISTINCT FROM expected_root
       OR NOT coalesce(clan_innata_private.catalogo_eligibility_release_v1(), false) THEN
        RAISE EXCEPTION 'VELO_EDITORIAL_BASELINE';
    END IF;

    SELECT to_jsonb(t) INTO STRICT before_row
    FROM public.clan_techniques t
    WHERE t.id = technique AND t.is_active
    FOR UPDATE;

    IF public.combat_v2_sha256(before_row) IS DISTINCT FROM expected_before
       OR before_row->>'danno_effetto' IS DISTINCT FROM previous_effect
       OR (SELECT public.combat_v2_sha256(jsonb_agg(to_jsonb(o) ORDER BY id))
           FROM public.clan_techniques o WHERE o.id <> technique) IS DISTINCT FROM expected_other_rows THEN
        RAISE EXCEPTION 'VELO_EDITORIAL_CATALOGUE_PREIMAGE';
    END IF;

    UPDATE public.clan_techniques t
    SET danno_effetto = new_effect
    WHERE t.id = technique
    RETURNING to_jsonb(t) INTO STRICT after_row;

    IF public.combat_v2_sha256(after_row) IS DISTINCT FROM expected_after
       OR after_row - 'danno_effetto' IS DISTINCT FROM before_row - 'danno_effetto'
       OR (SELECT public.combat_v2_sha256(jsonb_agg(to_jsonb(o) ORDER BY id))
           FROM public.clan_techniques o WHERE o.id <> technique) IS DISTINCT FROM expected_other_rows
       OR (SELECT public.combat_v2_sha256(to_jsonb(r)) FROM mission_factory_owner.editor_release_readiness r WHERE r.singleton)
          IS DISTINCT FROM expected_root
       OR NOT coalesce(clan_innata_private.catalogo_eligibility_release_v1(), false) THEN
        RAISE EXCEPTION 'VELO_EDITORIAL_POSTIMAGE';
    END IF;
END;
$velo_editorial$;
COMMIT;
