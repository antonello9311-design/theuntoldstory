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
), expected AS (SELECT value AS spec FROM jsonb_each('{"inert":{"config":"e0ba12179d4615115034c08941681e5c782abeb8fa8791ffb0510e1b18764215","db":"0256bbb2d5130ae978fd1be5f712d0476e90523a640f3ade1a737dd2612a7f3c","e52_sha":"e6d65882395b68ad8eb20a98cac7f27410d41f2755f6a845d70e732235057e60","parent":"a0ac2326d2e99f2c357558fb3652c775fbc78b5c66255636a404e8f88e3c38c9","root":"3edb8a20e2c40c78d9d84aa28f18f9aa8d0e8cc930023207d31ac8ea354df081","size":524230},"staff":{"config":"0b56ae75b62a19b5883e6b648c8e5cd95f1853cf7c125656ab09dea78fb85615","db":"08375c711e1fcc2b39743a1333e085c6e2f7d8f8616bc59a06c8b4eee09e9ba4","e52_sha":"9a4cac91b7185c076c6279c3a4ffe6b89fe5c18244e9767483c9b74d3a445d5e","parent":"7fbaf84839f038ab7dc99747bae12bee140cb935547175ab06b2271c3578cdd1","root":"a0ac2326d2e99f2c357558fb3652c775fbc78b5c66255636a404e8f88e3c38c9","size":519379}}'::jsonb))
SELECT o.root,o.row_sha,o.bytes,o.e52,o.verme,o.mission_admissions,o.party,o.pill_uses,o.pill_ledger_sha,
 o.historical_pill_two_sha,o.protected_state_sha,
 o.open_combat,o.open_master,o.pending_staff,o.pending_sfera,
 coalesce(o.root_exact AND o.bytes=(e.spec->>'size')::int
  AND o.doc#>>'{db_core,sha256}'=e.spec->>'db' AND o.doc#>>'{config,sha256}'=e.spec->>'config'
  AND public.combat_v2_sha256(o.doc->'edge_bundles')='67ee310b994f65492aa094f6f3f6e435aa2faf95d98246bbc6b00b90afc9c783'
  AND public.combat_v2_sha256(o.doc->'ui')='b62cac808730c14ff1558ac666b3a76c3cc264e4716b858205acada9efadefc9'
  AND o.e52 AND o.verme AND o.mission_qualified AND o.mission_admissions=2
  AND o.party=jsonb_set('{"public_enabled":true,"release_sha256":"7fbaf84839f038ab7dc99747bae12bee140cb935547175ab06b2271c3578cdd1","singleton":true,"staff_enabled":true}'::jsonb,'{release_sha256}',to_jsonb(o.root),false)
  AND o.mission_cap_sha='49fe134f561273f28e8071b63c45886341371b67d028f06e6b7d8f8d4108e817' AND o.historical_pill_two_sha='fbfbf747adeff748786676a6634315902f2475767fbbec67c1002b76bcdb38ed'
  AND o.ddl=e.spec->>'e52_sha'
  AND EXISTS (SELECT 1 FROM mission_public_owner.public_qualification_attestations_v1 a
      JOIN mission_public_owner.public_qualification_attestations_v1 p ON p.release_sha256=e.spec->>'parent'
      WHERE a.release_sha256=o.root AND (a.positive_staff_evidence_ref,a.authorized_test_manifest_ref,a.created_by)
      IS NOT DISTINCT FROM (p.positive_staff_evidence_ref,p.authorized_test_manifest_ref,p.created_by)
      AND a.payload#>>'{reuse_evidence,catalogo_compatibility,parent_root}'=p.release_sha256
      AND a.payload->'capabilities'=p.payload->'capabilities'),false) AS target_verified
FROM obs o LEFT JOIN expected e ON e.spec->>'root'=o.root;
ROLLBACK;
