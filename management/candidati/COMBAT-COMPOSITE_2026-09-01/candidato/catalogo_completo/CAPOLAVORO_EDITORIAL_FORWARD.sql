-- Sorgente candidata. Richiede review indipendente e mandato di apply del PM.
BEGIN;
SET LOCAL search_path='';
SET LOCAL lock_timeout='2s';
DO $capolavoro_editoriale$
DECLARE
    before_row jsonb;
    after_row jsonb;
BEGIN
    IF current_user<>'postgres' OR session_user<>'postgres' OR auth.uid() IS NOT NULL THEN
      RAISE EXCEPTION 'CAPOLAVORO_EDITORIAL_OPERATOR';
    END IF;
    IF EXISTS(
      SELECT 1 FROM pg_trigger t WHERE t.tgrelid='public.clan_techniques'::regclass AND NOT t.tgisinternal
    ) THEN RAISE EXCEPTION 'CAPOLAVORO_CATALOG_TRIGGER_DRIFT';END IF;
    SELECT to_jsonb(t) INTO STRICT before_row FROM public.clan_techniques t
      WHERE t.id='efcc0c8e-9f60-4906-9730-86f6fa2d9b05'::uuid FOR UPDATE;
    IF public.combat_v2_sha256(before_row) IS DISTINCT FROM '2872c91e2779f3529c06b25a9b6748da65c4f737ff38ca7f568cc351b83e0997'
       OR before_row->>'danno_effetto' IS DISTINCT FROM 'Una marionetta unica con statistiche proprie, che agisce nel turno del marionettista senza consumarne l''azione principale: 45 di danno base a portata Media e una tecnica del suo proprietario originale, scelta con lo staff alla concessione. Se viene distrutta non si ricostruisce.'
       OR before_row->'is_active' IS DISTINCT FROM 'true'::jsonb
    THEN RAISE EXCEPTION 'CAPOLAVORO_EDITORIAL_CATALOG_DRIFT';END IF;
    IF EXISTS(SELECT 1 FROM public.clan_genin_catalog_function_map_v1 x WHERE x.catalog_technique_id='efcc0c8e-9f60-4906-9730-86f6fa2d9b05'::uuid)
       OR EXISTS(SELECT 1 FROM public.character_abilities a WHERE a.technique_id='efcc0c8e-9f60-4906-9730-86f6fa2d9b05'::uuid)
       OR EXISTS(SELECT 1 FROM public.combat_v2_declarations d WHERE d.sanitized_intent->>'ability_id'='efcc0c8e-9f60-4906-9730-86f6fa2d9b05')
    THEN RAISE EXCEPTION 'CAPOLAVORO_EDITORIAL_SURFACE_CHANGED';END IF;
    UPDATE public.clan_techniques t
       SET danno_effetto='Una marionetta unica con statistiche proprie, il cui attacco, quando disponibile in Combat V2, usa l''azione principale condivisa del controllore: 45 di danno base a portata Media e una tecnica del suo proprietario originale, scelta con lo staff alla concessione. Se viene distrutta non si ricostruisce.'
       WHERE t.id='efcc0c8e-9f60-4906-9730-86f6fa2d9b05'::uuid AND public.combat_v2_sha256(to_jsonb(t))='2872c91e2779f3529c06b25a9b6748da65c4f737ff38ca7f568cc351b83e0997'
       RETURNING to_jsonb(t) INTO STRICT after_row;
    IF public.combat_v2_sha256(after_row) IS DISTINCT FROM 'f29c7089902f56d757f0c7c83271a3943dd318ef70a386093baadc50e6c5bfb2'
       OR after_row-'danno_effetto' IS DISTINCT FROM before_row-'danno_effetto'
    THEN RAISE EXCEPTION 'CAPOLAVORO_EDITORIAL_POSTIMAGE_DRIFT';END IF;
END;
$capolavoro_editoriale$;
SELECT t.id,public.combat_v2_sha256(to_jsonb(t)) AS row_sha256
FROM public.clan_techniques t WHERE t.id='efcc0c8e-9f60-4906-9730-86f6fa2d9b05'::uuid;
COMMIT;
