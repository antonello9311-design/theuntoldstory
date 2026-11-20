WITH expected AS (
 SELECT 'c9b261da-c9cd-40bb-8189-7b65ab5a1605'::uuid AS id
) SELECT jsonb_build_object(
 'root',r.revision_sha256,'root_row',public.combat_v2_sha256(to_jsonb(r)),
 'e52',clan_innata_private.catalogo_eligibility_release_v1(),
 'missions',(SELECT count(*) FROM mission_public_owner.mission_content_admissions_v1 a WHERE a.engine_release_sha256=r.revision_sha256 AND mission_public_owner.content_admission_v1(a.mission_id,r.revision_sha256,a.publication_request,true) IS NOT NULL),
 'gate',(SELECT public.combat_v2_sha256(to_jsonb(g)) FROM clan_innata_combat_private.velo_staff_gate_v1 g WHERE singleton),
 'velo_rows',(SELECT count(*) FROM clan_innata_combat_private.combat_state WHERE technique_id=t.id),
 'velo_receipts',(SELECT count(*) FROM clan_innata_combat_private.combat_receipts WHERE technique_id=t.id),
 'velo_row',public.combat_v2_sha256(to_jsonb(t)),'effect',t.danno_effetto,
 'other_catalog_rows',(SELECT public.combat_v2_sha256(jsonb_agg(to_jsonb(o) ORDER BY o.id)) FROM public.clan_techniques o WHERE o.id<>t.id),
 'jutsu_rows',(SELECT public.combat_v2_sha256(jsonb_agg(to_jsonb(j) ORDER BY j.id)) FROM public.jutsu j),
 'open',jsonb_build_array((SELECT count(*) FROM public.combat_v2_sessions WHERE closed_at IS NULL),(SELECT count(*) FROM public.master_v2_sessions WHERE closed_at IS NULL AND stato NOT IN ('chiusa','annullata')),(SELECT count(*) FROM combat_consumer_private.invitations WHERE state='pending' AND location_id='0b85f354-9cdb-47e1-baf9-3d266bb7e06b'))
 ) AS evidence
FROM expected e JOIN public.clan_techniques t USING(id)
CROSS JOIN mission_factory_owner.editor_release_readiness r WHERE r.singleton;
