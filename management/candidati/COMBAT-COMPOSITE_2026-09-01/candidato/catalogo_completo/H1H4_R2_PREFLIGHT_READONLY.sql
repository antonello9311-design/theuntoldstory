-- Read-only attestation of actual H4 preconditions for source or recovery.
WITH live AS (
 SELECT rr.revision_sha256, rr.canonical_preimage::jsonb AS root,
        octet_length(rr.canonical_preimage) AS bytes,
        public.combat_v2_sha256(to_jsonb(rr)) AS row_sha256
 FROM mission_factory_owner.editor_release_readiness rr WHERE rr.singleton
), facts AS (
 SELECT l.*,
        mission_public_owner.engine_qualification_v1(l.revision_sha256,true) AS eligibility,
        to_jsonb(a) AS release_admission,to_jsonb(q) AS attestation,
        q.payload->'capabilities' AS capabilities
 FROM live l
 JOIN mission_public_owner.release_admissions_v1 a ON a.release_sha256=l.revision_sha256
 JOIN mission_public_owner.public_qualification_attestations_v1 q ON q.release_sha256=l.revision_sha256
)
SELECT jsonb_build_object(
 'expected_current',jsonb_build_object(
  'root_sha256',f.revision_sha256,'root_row_sha256',f.row_sha256,'root_bytes',f.bytes,
  'db_sha256',f.root#>>'{db_core,sha256}','config_sha256',f.root#>>'{config,sha256}',
  'ui_sha256',public.combat_v2_sha256(f.root->'ui'),'ui_graph_sha256',f.root#>>'{ui,import_graph_sha256}'),
 'expected_mission_qualification_sha256',public.combat_v2_sha256(f.eligibility),
 'expected_attestation_sha256',public.combat_v2_sha256(f.attestation),
 'expected_release_admission_sha256',public.combat_v2_sha256(f.release_admission),
 'expected_mission_capabilities_sha256',public.combat_v2_sha256(f.capabilities),
 'expected_content_admission_rows_sha256',
 (SELECT public.combat_v2_sha256(jsonb_agg(to_jsonb(c) ORDER BY c.mission_id,c.request_key))
  FROM mission_public_owner.mission_content_admissions_v1 c WHERE c.engine_release_sha256=f.revision_sha256),
 'expected_profile_rows_sha256',
 (SELECT public.combat_v2_sha256(jsonb_agg(to_jsonb(e) ORDER BY e.profile_key))
  FROM (SELECT DISTINCT ON(z.profile_key) * FROM mission_public_owner.engine_profile_events_v1 z
        WHERE z.engine_release_sha256=f.revision_sha256 ORDER BY z.profile_key,z.control_version DESC) e),
 'qualified',f.eligibility IS NOT NULL,
 'qualified_contents',(SELECT count(*) FROM mission_public_owner.mission_content_admissions_v1 c
  WHERE c.engine_release_sha256=f.revision_sha256
    AND mission_public_owner.content_admission_v1(c.mission_id,f.revision_sha256,c.publication_request,true) IS NOT NULL),
 'open_master',(SELECT count(*) FROM public.master_v2_sessions
  WHERE closed_at IS NULL AND stato NOT IN('chiusa','annullata')),
 'open_combat',(SELECT count(*) FROM public.combat_v2_sessions
  WHERE closed_at IS NULL AND state IN('preparazione','in_corso','sospeso')),
 'pending_staff',(SELECT count(*) FROM combat_consumer_private.invitations
  WHERE state='pending' AND location_id='0b85f354-9cdb-47e1-baf9-3d266bb7e06b'::uuid),
 'code_identity_sha256',f.root#>>'{contract,code_identity_sha256}',
 'roster_ddl_sha256',encode(extensions.digest(pg_get_functiondef('combat_v2_staff_nb_internal.commit_roster(jsonb)'::regprocedure),'sha256'),'hex'),
 'e52_ddl_sha256',encode(extensions.digest(pg_get_functiondef('clan_innata_private.catalogo_eligibility_release_v1()'::regprocedure),'sha256'),'hex'),
 'publisher_ddl_sha256',encode(extensions.digest(pg_get_functiondef(
  'combat_panel_private.publish_master_declaration(uuid,text)'::regprocedure),'sha256'),'hex')
) AS preflight FROM facts f;
