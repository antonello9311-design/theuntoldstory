-- Solo il campo Effetto della Sfera d’Insetti. Nessun aggiornamento delle regole.
BEGIN;
SET LOCAL search_path='';
SET LOCAL lock_timeout='2s';
DO $sfera_catalogue$
DECLARE
  technique_id constant uuid := '07a93dee-a483-4a7b-b3e0-43146c2ce227';
  expected_before constant text := '36fe93e336e9e4ae5eb0c6103b7a8ead5b5fe0658c16b64a2bec25d562ea7542';
  expected_after constant text := 'ed59c81a0dc7d1c0d3aa3cacdc0b5ec9f4cf72280215a831658451a4b0f1b13b';
  expected_root constant text := '7fbaf84839f038ab7dc99747bae12bee140cb935547175ab06b2271c3578cdd1';
  effect_text constant text := $sfera_effect$Avvolge e divora il chakra del bersaglio in una sfera d'insetti$sfera_effect$;
  prior_effect constant text := $sfera_effect$Avvolge il bersaglio in una sfera d’insetti che ne assorbe il chakra. Profilo Combat V2 riservato alla Staff Test Room. Usa l’azione principale contro un bersaglio entro 10 metri. Il lancio valido costa 20 chakra e impegna 15 unità di Colonia. Il profilo infligge 0 PV. Solo un successo pieno sottrae fino a 10 chakra e blocca il movimento. Il bersaglio conserva l’azione principale e può usarla per tentare la fuga. Nei turni successivi dell’Aburame il mantenimento costa 10 chakra e sottrae fino a 10 chakra al bersaglio se la Sfera è ancora valida. Quando l’effetto termina, le unità superstiti tornano disponibili.$sfera_effect$;
  before_row jsonb;
  after_row jsonb;
BEGIN
  IF current_user<>'postgres' OR session_user<>'postgres' OR auth.uid() IS NOT NULL THEN
    RAISE EXCEPTION 'SFERA_EFFECT_OPERATOR_REQUIRED';
  END IF;
  LOCK TABLE public.clan_techniques IN SHARE ROW EXCLUSIVE MODE NOWAIT;
  IF EXISTS (
    SELECT 1 FROM pg_trigger WHERE tgrelid='public.clan_techniques'::regclass AND NOT tgisinternal
  ) THEN RAISE EXCEPTION 'SFERA_EFFECT_TRIGGER_DRIFT'; END IF;
  IF (SELECT revision_sha256 FROM mission_factory_owner.editor_release_readiness WHERE singleton) IS DISTINCT FROM expected_root
     OR (SELECT to_jsonb(g) FROM clan_aburame_private.sfera_staff_gate_v1 g WHERE singleton)
        IS DISTINCT FROM '{"enabled":true,"singleton":true}'::jsonb
     OR clan_innata_private.catalogo_eligibility_release_v1() IS DISTINCT FROM true
     OR mission_public_owner.engine_qualification_v1(expected_root,true) IS NULL
  THEN RAISE EXCEPTION 'SFERA_EFFECT_STAFF_BASELINE_DRIFT'; END IF;

  SELECT to_jsonb(t) INTO STRICT before_row FROM public.clan_techniques t
  WHERE t.id=technique_id FOR UPDATE NOWAIT;
  IF public.combat_v2_sha256(before_row) IS DISTINCT FROM expected_before
     OR before_row->>'danno_effetto' IS DISTINCT FROM prior_effect
     OR before_row->'is_active' IS DISTINCT FROM 'true'::jsonb
  THEN RAISE EXCEPTION 'SFERA_EFFECT_BEFORE_DRIFT'; END IF;

  UPDATE public.clan_techniques t SET danno_effetto=effect_text
  WHERE t.id=technique_id AND public.combat_v2_sha256(to_jsonb(t))=expected_before
  RETURNING to_jsonb(t) INTO STRICT after_row;
  IF public.combat_v2_sha256(after_row) IS DISTINCT FROM expected_after
     OR after_row-'danno_effetto' IS DISTINCT FROM before_row-'danno_effetto'
     OR after_row->>'danno_effetto' IS DISTINCT FROM effect_text
     OR clan_innata_private.catalogo_eligibility_release_v1() IS DISTINCT FROM true
     OR mission_public_owner.engine_qualification_v1(expected_root,true) IS NULL
  THEN RAISE EXCEPTION 'SFERA_EFFECT_AFTER_DRIFT'; END IF;
END
$sfera_catalogue$;
COMMIT;
