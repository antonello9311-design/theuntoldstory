-- Candidata editoriale Verme Staff. Apply solo dopo review e mandato del PM.
BEGIN;
SET LOCAL search_path='';
SET LOCAL lock_timeout='2s';
DO $verme_metadata$
DECLARE
  target_id constant uuid := '2f06b6f8-341f-472b-be04-ad48fcf2c412';
  expected_before constant text := '36880dbfcce77d76af0412aac7f927a92efcb657578e2ab87d194477ee3a9ddf';
  expected_after constant text := '757a5232e4a72e009fb1b5e8e8964660beccdda062013f28fcaba68f3941c77b';
  effect_text constant text := $verme_effect$Combat V2: in prova nella Staff Test Room. Il profilo in prova usa l’azione principale, costa 10 chakra per lancio e impegna 5 unità di Colonia per un colpo a contatto entro 2 metri. Il colpo ha danno base 10. Un successo pieno con danno effettivo inietta una tossina se il bersaglio è ancora operativo. La tossina ha danno base 5, ridotto dalla Resistenza, all’inizio di ciascuno dei due turni personali successivi del bersaglio. Le iniezioni successive possono rinnovarne la durata senza sommare gli effetti. Gli insetti superstiti rientrano nella Colonia dopo la risoluzione.$verme_effect$;
  before_row jsonb;
  after_row jsonb;
  other_rows_sha text;
  root_sha text;
  gate_before jsonb;
  manifest_before jsonb;
BEGIN
  IF current_user<>'postgres' OR session_user<>'postgres' OR auth.uid() IS NOT NULL THEN
    RAISE EXCEPTION 'VERME_METADATA_OPERATOR_REQUIRED';
  END IF;
  LOCK TABLE public.clan_techniques IN SHARE ROW EXCLUSIVE MODE NOWAIT;
  IF EXISTS (
    SELECT 1 FROM pg_trigger g WHERE g.tgrelid='public.clan_techniques'::regclass AND NOT g.tgisinternal
  ) THEN RAISE EXCEPTION 'VERME_METADATA_TRIGGER_DRIFT'; END IF;

  SELECT to_jsonb(t) INTO STRICT before_row FROM public.clan_techniques t WHERE t.id=target_id FOR UPDATE NOWAIT;
  IF public.combat_v2_sha256(before_row) IS DISTINCT FROM expected_before
     OR before_row->>'danno_effetto' IS DISTINCT FROM NULL
     OR before_row->'is_active' IS DISTINCT FROM 'true'::jsonb
  THEN RAISE EXCEPTION 'VERME_METADATA_BEFORE_DRIFT'; END IF;

  SELECT r.revision_sha256 INTO STRICT root_sha FROM mission_factory_owner.editor_release_readiness r WHERE r.singleton;
  SELECT to_jsonb(g) INTO STRICT gate_before FROM clan_aburame_private.verme_gate_v1 g WHERE g.singleton;
  IF gate_before->'staff_enabled' IS DISTINCT FROM 'true'::jsonb
     OR gate_before->'public_enabled' IS DISTINCT FROM 'false'::jsonb
     OR gate_before->>'contract_version' IS DISTINCT FROM 'aburame-verme/1'
     OR clan_innata_private.catalogo_eligibility_release_v1() IS DISTINCT FROM true
     OR clan_aburame_private.verme_release_v1() IS DISTINCT FROM true
  THEN RAISE EXCEPTION 'VERME_METADATA_STAFF_BASELINE_DRIFT'; END IF;
  manifest_before:=clan_aburame_private.verme_manifest_v1();
  SELECT public.combat_v2_sha256(coalesce(jsonb_agg(to_jsonb(t) ORDER BY t.id),'[]'::jsonb))
  INTO other_rows_sha FROM public.clan_techniques t WHERE t.id<>target_id;

  UPDATE public.clan_techniques t SET danno_effetto=effect_text
  WHERE t.id=target_id AND public.combat_v2_sha256(to_jsonb(t))=expected_before
  RETURNING to_jsonb(t) INTO STRICT after_row;
  IF public.combat_v2_sha256(after_row) IS DISTINCT FROM expected_after
     OR after_row-'danno_effetto' IS DISTINCT FROM before_row-'danno_effetto'
     OR after_row->>'danno_effetto' IS DISTINCT FROM effect_text
  THEN RAISE EXCEPTION 'VERME_METADATA_AFTER_DRIFT'; END IF;

  IF root_sha IS DISTINCT FROM (SELECT r.revision_sha256 FROM mission_factory_owner.editor_release_readiness r WHERE r.singleton)
     OR gate_before IS DISTINCT FROM (SELECT to_jsonb(g) FROM clan_aburame_private.verme_gate_v1 g WHERE g.singleton)
     OR manifest_before IS DISTINCT FROM clan_aburame_private.verme_manifest_v1()
     OR clan_innata_private.catalogo_eligibility_release_v1() IS DISTINCT FROM true
     OR clan_aburame_private.verme_release_v1() IS DISTINCT FROM true
     OR other_rows_sha IS DISTINCT FROM (
       SELECT public.combat_v2_sha256(coalesce(jsonb_agg(to_jsonb(t) ORDER BY t.id),'[]'::jsonb))
       FROM public.clan_techniques t WHERE t.id<>target_id
     )
  THEN RAISE EXCEPTION 'VERME_METADATA_POSTGUARD_DRIFT'; END IF;
END
$verme_metadata$;
COMMIT;
