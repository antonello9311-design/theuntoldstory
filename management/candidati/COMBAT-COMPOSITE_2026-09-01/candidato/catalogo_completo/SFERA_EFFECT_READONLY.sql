BEGIN READ ONLY;
SET LOCAL search_path='';
SELECT public.combat_v2_sha256(to_jsonb(t)) AS effect_row_sha256,
       to_jsonb(t)->>'danno_effetto' AS effect,
       public.combat_v2_sha256(to_jsonb(t)-'danno_effetto') AS untouched_fields_sha256,
       (SELECT public.combat_v2_sha256(jsonb_agg(to_jsonb(e) ORDER BY e.id)) FROM public.clan_techniques e WHERE e.id<>t.id) AS other_rows_sha256,
       (SELECT revision_sha256 FROM mission_factory_owner.editor_release_readiness WHERE singleton) AS root,
       (SELECT public.combat_v2_sha256(to_jsonb(r)) FROM mission_factory_owner.editor_release_readiness r WHERE singleton) AS root_row_sha256,
       (SELECT to_jsonb(g) FROM clan_aburame_private.sfera_staff_gate_v1 g WHERE singleton) AS staff_gate,
       clan_innata_private.catalogo_eligibility_release_v1() AS catalog_attested,
       (SELECT count(*) FROM mission_public_owner.mission_content_admissions_v1 c
        JOIN mission_factory_owner.editor_release_readiness r ON r.singleton AND c.engine_release_sha256=r.revision_sha256
        WHERE mission_public_owner.content_admission_v1(c.mission_id,r.revision_sha256,c.publication_request,true) IS NOT NULL) AS qualified_missions,
       (SELECT count(*) FROM pg_trigger WHERE tgrelid='public.clan_techniques'::regclass AND NOT tgisinternal) AS user_triggers
FROM public.clan_techniques t WHERE t.id='07a93dee-a483-4a7b-b3e0-43146c2ce227';
ROLLBACK;
