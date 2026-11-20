BEGIN READ ONLY;
SET LOCAL search_path='';
SET LOCAL statement_timeout='45s';

WITH obs AS (
 SELECT t.revision_sha256 AS root,public.combat_v2_sha256(to_jsonb(t)) AS row_sha,t.canonical_preimage::jsonb AS doc,
 octet_length(t.canonical_preimage) AS bytes,
 encode(extensions.digest(convert_to(t.canonical_preimage,'UTF8'),'sha256'),'hex')=t.revision_sha256
 AND t.observed_revision_sha256=t.revision_sha256 AS root_exact,
 (SELECT count(*) FROM public.combat_v2_sessions c WHERE c.closed_at IS NULL AND c.state IN ('preparazione','in_corso','sospeso')) AS open_combat,
 (SELECT count(*) FROM public.master_v2_sessions m WHERE m.closed_at IS NULL AND m.stato NOT IN ('chiusa','annullata')) AS open_master,
 (SELECT count(*) FROM combat_consumer_private.invitations i WHERE i.state='pending' AND i.location_id='0b85f354-9cdb-47e1-baf9-3d266bb7e06b') AS pending_staff,
 (SELECT count(*) FROM clan_aburame_private.sfera_sources_v1 s WHERE s.state IN ('reserved','active')) AS pending_sfera,
 (SELECT count(*) FROM mission_public_owner.mission_content_admissions_v1 c WHERE c.engine_release_sha256=t.revision_sha256
 AND mission_public_owner.content_admission_v1(c.mission_id,t.revision_sha256,c.publication_request,true) IS NOT NULL) AS mission_admissions,
 (SELECT to_jsonb(p) FROM mission_public_owner.party_launch_runtime_v1 p WHERE p.singleton) AS party,
 (SELECT public.combat_v2_sha256(q.payload->'capabilities') FROM mission_public_owner.public_qualification_attestations_v1 q
  WHERE q.release_sha256=t.revision_sha256) AS mission_cap_sha,
 mission_public_owner.engine_qualification_v1(t.revision_sha256,true) IS NOT NULL AS mission_qualified,
 (SELECT public.combat_v2_sha256(coalesce(jsonb_agg(to_jsonb(u) ORDER BY u.session_id,u.actor_id),'[]'::jsonb))
 FROM combat_panel_private.chakra_pill_staff_uses_v1 u) AS pill_ledger_sha,
 (SELECT public.combat_v2_sha256(coalesce(jsonb_agg(to_jsonb(u) ORDER BY u.session_id,u.actor_id),'[]'::jsonb))
 FROM combat_panel_private.chakra_pill_staff_uses_v1 u WHERE u.receipt_id IN ('bf314349-3316-453e-9d6d-30bcdffbd646'::uuid,'da68cef2-4ef2-4c84-b550-c1053d99955a'::uuid)) AS historical_pill_two_sha,
 (SELECT count(*) FROM combat_panel_private.chakra_pill_staff_uses_v1) AS pill_uses,
 public.combat_v2_sha256(jsonb_build_object(
'characters', (SELECT public.combat_v2_sha256(coalesce(jsonb_agg(to_jsonb(row_data) ORDER BY to_jsonb(row_data)::text),'[]'::jsonb)) FROM public.characters row_data WHERE row_data.id IN ('2a877f02-4993-4e65-9172-7d29f08c5b86'::uuid,'6bceee99-974f-426b-8d92-38b43b4a4267'::uuid)),
'character_inventory', (SELECT public.combat_v2_sha256(coalesce(jsonb_agg(to_jsonb(row_data) ORDER BY to_jsonb(row_data)::text),'[]'::jsonb)) FROM public.character_inventory row_data WHERE row_data.character_id IN ('2a877f02-4993-4e65-9172-7d29f08c5b86'::uuid,'6bceee99-974f-426b-8d92-38b43b4a4267'::uuid)),
'character_equipment', (SELECT public.combat_v2_sha256(coalesce(jsonb_agg(to_jsonb(row_data) ORDER BY to_jsonb(row_data)::text),'[]'::jsonb)) FROM public.character_equipment row_data WHERE row_data.character_id IN ('2a877f02-4993-4e65-9172-7d29f08c5b86'::uuid,'6bceee99-974f-426b-8d92-38b43b4a4267'::uuid)),
'character_abilities', (SELECT public.combat_v2_sha256(coalesce(jsonb_agg(to_jsonb(row_data) ORDER BY to_jsonb(row_data)::text),'[]'::jsonb)) FROM public.character_abilities row_data WHERE row_data.character_id IN ('2a877f02-4993-4e65-9172-7d29f08c5b86'::uuid,'6bceee99-974f-426b-8d92-38b43b4a4267'::uuid)),
'character_jutsu', (SELECT public.combat_v2_sha256(coalesce(jsonb_agg(to_jsonb(row_data) ORDER BY to_jsonb(row_data)::text),'[]'::jsonb)) FROM public.character_jutsu row_data JOIN public.characters owner ON owner.user_id=row_data.user_id WHERE owner.id IN ('2a877f02-4993-4e65-9172-7d29f08c5b86'::uuid,'6bceee99-974f-426b-8d92-38b43b4a4267'::uuid)),
'pill_staff_ledger',(SELECT public.combat_v2_sha256(coalesce(jsonb_agg(to_jsonb(u) ORDER BY u.session_id,u.actor_id),'[]'::jsonb))
 FROM combat_panel_private.chakra_pill_staff_uses_v1 u),
'pill_staff_initial_two',(SELECT public.combat_v2_sha256(coalesce(jsonb_agg(to_jsonb(u) ORDER BY u.session_id,u.actor_id),'[]'::jsonb))
 FROM combat_panel_private.chakra_pill_staff_uses_v1 u WHERE u.receipt_id IN ('bf314349-3316-453e-9d6d-30bcdffbd646'::uuid,'da68cef2-4ef2-4c84-b550-c1053d99955a'::uuid)),
'clan_aburame_private.sfera_staff_gate_v1', (SELECT public.combat_v2_sha256(to_jsonb(g)) FROM clan_aburame_private.sfera_staff_gate_v1 g WHERE g.singleton),
'clan_aburame_private.verme_gate_v1', (SELECT public.combat_v2_sha256(to_jsonb(g)) FROM clan_aburame_private.verme_gate_v1 g WHERE g.singleton),
'clan_akimichi_private.common_gate_v1', (SELECT public.combat_v2_sha256(to_jsonb(g)) FROM clan_akimichi_private.common_gate_v1 g WHERE g.singleton),
'clan_innata_combat_private.velo_staff_gate_v1', (SELECT public.combat_v2_sha256(to_jsonb(g)) FROM clan_innata_combat_private.velo_staff_gate_v1 g WHERE g.singleton),
'combat_panel_private.chakra_pill_staff_gate_v1', (SELECT public.combat_v2_sha256(to_jsonb(g)) FROM combat_panel_private.chakra_pill_staff_gate_v1 g WHERE g.singleton),
'combat_panel_private.cure_gate_v1', (SELECT public.combat_v2_sha256(to_jsonb(g)) FROM combat_panel_private.cure_gate_v1 g WHERE g.singleton),
'combat_panel_private.nara_adv_gate_v1', (SELECT public.combat_v2_sha256(to_jsonb(g)) FROM combat_panel_private.nara_adv_gate_v1 g WHERE g.singleton),
'combat_v2_genjutsu_internal.gate', (SELECT public.combat_v2_sha256(to_jsonb(g)) FROM combat_v2_genjutsu_internal.gate g WHERE g.singleton),
'combat_v2_staff_nb_internal.gate', (SELECT public.combat_v2_sha256(to_jsonb(g)) FROM combat_v2_staff_nb_internal.gate g WHERE g.singleton))) AS protected_state_sha,
 clan_innata_private.catalogo_eligibility_release_v1() AS e52,
 clan_aburame_private.verme_release_v1() AS verme,
 encode(extensions.digest(convert_to(pg_get_functiondef('clan_innata_private.catalogo_eligibility_release_v1()'::regprocedure),'UTF8'),'sha256'),'hex') AS ddl
 FROM mission_factory_owner.editor_release_readiness t WHERE t.singleton
)
SELECT o.root,o.row_sha,o.bytes,o.e52,o.verme,o.mission_qualified,o.mission_admissions,o.party,
 o.open_combat,o.open_master,o.pending_staff,o.pending_sfera,o.pill_ledger_sha,o.historical_pill_two_sha,o.pill_uses,o.protected_state_sha,
 o.open_combat=0 AND o.open_master=0 AND o.pending_staff=0 AND o.pending_sfera=0 AS quiescent,
 coalesce(o.root='7fbaf84839f038ab7dc99747bae12bee140cb935547175ab06b2271c3578cdd1' AND o.row_sha='5b6fe3ddb8090da1423ddc83e21cac670ff605bf69a15d0fb53ecad8e12e9221' AND o.root_exact AND o.bytes=524230
 AND o.e52 AND o.verme AND o.mission_qualified AND o.mission_admissions=2 AND o.party='{"public_enabled":true,"release_sha256":"7fbaf84839f038ab7dc99747bae12bee140cb935547175ab06b2271c3578cdd1","singleton":true,"staff_enabled":true}'::jsonb
 AND o.mission_cap_sha='49fe134f561273f28e8071b63c45886341371b67d028f06e6b7d8f8d4108e817' AND o.historical_pill_two_sha='fbfbf747adeff748786676a6634315902f2475767fbbec67c1002b76bcdb38ed'
 AND o.ddl='e6d65882395b68ad8eb20a98cac7f27410d41f2755f6a845d70e732235057e60',false) AS baseline_exact
FROM obs o;
ROLLBACK;
