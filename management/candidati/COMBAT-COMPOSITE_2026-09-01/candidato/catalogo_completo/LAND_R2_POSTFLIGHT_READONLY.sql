BEGIN READ ONLY;
SET LOCAL search_path='';
SET LOCAL statement_timeout='45s';
SET LOCAL timezone='UTC';

WITH expected AS (
 SELECT NULL::jsonb AS evidence -- LAND_R2_POSTFLIGHT_BINDING
), observed AS (
 SELECT e.evidence,r.revision_sha256,r.observed_revision_sha256,r.scope,r.state,r.independent_review_ref,r.client_build,
        r.staff_guards_verified,r.published_assets_verified,r.canonical_preimage::jsonb AS doc,
        encode(extensions.digest(convert_to(r.canonical_preimage,'UTF8'),'sha256'),'hex') AS digest,
        octet_length(r.canonical_preimage) AS root_bytes,
        jsonb_build_object(
         'root_sha256',r.revision_sha256,'row_sha256',public.combat_v2_sha256(to_jsonb(r)),
         'admission_row_sha256',public.combat_v2_sha256(to_jsonb(a)),
         'qualification_row_sha256',public.combat_v2_sha256(to_jsonb(q)),
         'profile_row_sha256',(SELECT public.combat_v2_sha256(to_jsonb(p))
          FROM mission_public_owner.engine_profile_events_v1 p WHERE p.engine_release_sha256=r.revision_sha256
          AND p.profile_key='mission-ai-authoring/1' ORDER BY p.control_version DESC LIMIT 1),
         'content_rows_sha256',(SELECT public.combat_v2_sha256(jsonb_agg(to_jsonb(c) ORDER BY c.mission_id))
          FROM mission_public_owner.mission_content_admissions_v1 c WHERE c.engine_release_sha256=r.revision_sha256),
         'party_row_sha256',public.combat_v2_sha256(to_jsonb(x))) AS active,
        a.client_sha256,a.public_enabled,q.payload,to_jsonb(x) AS party,
        (SELECT count(*) FROM mission_public_owner.mission_content_admissions_v1 c WHERE c.engine_release_sha256=r.revision_sha256
         AND mission_public_owner.content_admission_v1(c.mission_id,r.revision_sha256,c.publication_request,true) IS NOT NULL) AS admissions,
        (SELECT count(*) FROM mission_public_owner.mission_content_admissions_v1 c WHERE c.engine_release_sha256=r.revision_sha256) AS admission_rows,
        mission_public_owner.engine_qualification_v1(r.revision_sha256,true) IS NOT NULL AS qualification_live,
        clan_innata_private.catalogo_eligibility_release_v1() IS TRUE AS e52,
        clan_innata_private.runtime_release_assert()::text='' AS common,
        clan_aburame_private.verme_release_v1() IS TRUE AS verme
 FROM expected e CROSS JOIN mission_factory_owner.editor_release_readiness r
 JOIN mission_public_owner.release_admissions_v1 a ON a.release_sha256=r.revision_sha256
 JOIN mission_public_owner.public_qualification_attestations_v1 q ON q.release_sha256=r.revision_sha256
 JOIN mission_public_owner.party_launch_runtime_v1 x ON x.singleton
 WHERE r.singleton AND e.evidence IS NOT NULL
), historical AS (
 SELECT o.*,
  jsonb_build_object(
   'admission_row_sha256',public.combat_v2_sha256(to_jsonb(a)),
   'qualification_row_sha256',public.combat_v2_sha256(to_jsonb(q)),
   'profile_row_sha256',(SELECT public.combat_v2_sha256(to_jsonb(p))
    FROM mission_public_owner.engine_profile_events_v1 p WHERE p.engine_release_sha256=a.release_sha256
    AND p.profile_key='mission-ai-authoring/1' ORDER BY p.control_version DESC LIMIT 1),
   'content_rows_sha256',(SELECT public.combat_v2_sha256(jsonb_agg(to_jsonb(c) ORDER BY c.mission_id))
    FROM mission_public_owner.mission_content_admissions_v1 c WHERE c.engine_release_sha256=a.release_sha256)) AS archived
 FROM observed o
 JOIN mission_public_owner.release_admissions_v1 a ON a.release_sha256=o.evidence#>>'{parent,root_sha256}'
 JOIN mission_public_owner.public_qualification_attestations_v1 q ON q.release_sha256=a.release_sha256
)
SELECT jsonb_build_object(
 'schema_version','staff-land-r2-root-postflight/2','active',o.active,'root_bytes',o.root_bytes,
 'mode',o.evidence->>'mode','aborted_release_sha256',o.evidence->>'aborted_release_sha256',
 'client_sha256',o.client_sha256,'party',o.party,'mission_admissions',o.admissions,'git_commit',o.doc#>>'{ui,git_head}',
 'seals',jsonb_build_object('E52',o.e52,'Common',o.common,'Verme',o.verme),
 'parent_records_preserved',o.archived=(o.evidence->'parent')-ARRAY['root_sha256','row_sha256','party_row_sha256'],
 'postflight_pass',coalesce(
  o.e52 AND o.common AND o.verme AND o.qualification_live
  AND o.revision_sha256=o.digest AND o.observed_revision_sha256=o.revision_sha256
  AND o.root_bytes=(o.evidence->>'root_bytes')::int AND o.root_bytes<=524288
  AND o.active=o.evidence->'active' AND o.client_sha256=o.evidence->>'client_sha256'
  AND o.scope='staff' AND o.state='enabled' AND o.staff_guards_verified AND o.published_assets_verified AND o.public_enabled
  AND o.independent_review_ref=o.evidence->>'review_ref' AND o.client_build='mission-factory-admin/2:'||o.revision_sha256
  AND o.doc#>>'{ui,git_head}'=o.evidence->>'git_commit'
  AND o.admissions=2 AND o.admission_rows=2
  AND o.party=jsonb_build_object('singleton',true,'release_sha256',o.revision_sha256,'staff_enabled',true,'public_enabled',true)
  AND o.payload#>>'{reuse_evidence,catalogo_compatibility,parent_root}'=o.evidence->>'previous_root_sha256'
  AND o.payload#>>'{reuse_evidence,catalogo_compatibility,sha256}'=o.evidence->>'binding_sha256'
  AND o.payload#>'{reuse_evidence,new_mission_QA_claim}'='false'::jsonb
  AND (o.evidence->>'mode'<>'publication_abort' AND o.evidence->'aborted_release_sha256'='null'::jsonb
       OR o.evidence->>'mode'='publication_abort'
        AND coalesce(o.evidence->>'aborted_release_sha256','') ~ '^[a-f0-9]{64}$'
        AND NOT EXISTS(SELECT 1 FROM mission_public_owner.release_admissions_v1 x
                       WHERE x.release_sha256=o.evidence->>'aborted_release_sha256')
        AND NOT EXISTS(SELECT 1 FROM mission_public_owner.public_qualification_attestations_v1 x
                       WHERE x.release_sha256=o.evidence->>'aborted_release_sha256')
        AND NOT EXISTS(SELECT 1 FROM mission_public_owner.engine_profile_events_v1 x
                       WHERE x.engine_release_sha256=o.evidence->>'aborted_release_sha256')
        AND NOT EXISTS(SELECT 1 FROM mission_public_owner.mission_content_admissions_v1 x
                       WHERE x.engine_release_sha256=o.evidence->>'aborted_release_sha256'))
  AND o.archived=(o.evidence->'parent')-ARRAY['root_sha256','row_sha256','party_row_sha256'],false)
) AS postflight FROM historical o;
ROLLBACK;
