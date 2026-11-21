BEGIN READ ONLY;
SET LOCAL search_path='';
SET LOCAL statement_timeout='45s';
SET LOCAL timezone='UTC';

WITH
parameters AS (
 SELECT NULL::jsonb AS binding -- LAND_R2_READONLY_BINDING
),
observation AS (
 SELECT p.binding,p.binding->>'mode' AS mode,p.binding->'publication' AS publication,
        p.binding->'publication_abort_evidence' AS abort_evidence,
        r.revision_sha256,r.observed_revision_sha256,r.canonical_preimage,r.canonical_preimage::jsonb AS doc,
        public.combat_v2_sha256(to_jsonb(r)) AS row_sha,r.state,r.scope,r.published_assets_verified,r.staff_guards_verified,
        a.payload AS qualification,rel.client_sha256 AS parent_client_sha256,
        jsonb_build_object(
         'root_sha256',r.revision_sha256,'row_sha256',public.combat_v2_sha256(to_jsonb(r)),
         'admission_row_sha256',public.combat_v2_sha256(to_jsonb(rel)),
         'qualification_row_sha256',public.combat_v2_sha256(to_jsonb(a)),
         'profile_row_sha256',(SELECT public.combat_v2_sha256(to_jsonb(x))
          FROM mission_public_owner.engine_profile_events_v1 x WHERE x.engine_release_sha256=r.revision_sha256
          AND x.profile_key='mission-ai-authoring/1' ORDER BY x.control_version DESC LIMIT 1),
         'content_rows_sha256',(SELECT public.combat_v2_sha256(jsonb_agg(to_jsonb(x) ORDER BY x.mission_id))
          FROM mission_public_owner.mission_content_admissions_v1 x WHERE x.engine_release_sha256=r.revision_sha256),
         'party_row_sha256',public.combat_v2_sha256(to_jsonb(y))) AS parent,
        to_jsonb(y) AS party,
        (SELECT count(*) FROM mission_public_owner.mission_content_admissions_v1 x WHERE x.engine_release_sha256=r.revision_sha256
         AND mission_public_owner.content_admission_v1(x.mission_id,r.revision_sha256,x.publication_request,true) IS NOT NULL) AS admissions,
        (SELECT count(*) FROM mission_public_owner.mission_content_admissions_v1 x WHERE x.engine_release_sha256=r.revision_sha256) AS admission_rows,
        (SELECT count(DISTINCT profile_key) FROM mission_public_owner.engine_profile_events_v1 WHERE engine_release_sha256=r.revision_sha256) AS profiles,
        mission_public_owner.engine_profile_state_v1(r.revision_sha256,'mission-ai-authoring/1') AS profile_state,
        mission_public_owner.engine_qualification_v1(r.revision_sha256,true) IS NOT NULL AS qualification_live,
        clan_innata_private.catalogo_eligibility_release_v1() IS TRUE AS e52,
        clan_innata_private.runtime_release_assert()::text='' AS common,
        clan_aburame_private.verme_release_v1() IS TRUE AS verme,
        jsonb_build_object(
          'combat',(SELECT count(*) FROM public.combat_v2_sessions WHERE closed_at IS NULL AND state IN ('preparazione','in_corso','sospeso')),
          'master',(SELECT count(*) FROM public.master_v2_sessions WHERE closed_at IS NULL AND stato NOT IN ('chiusa','annullata')),
          'staff_invites',(SELECT count(*) FROM combat_consumer_private.invitations WHERE state='pending' AND location_id='0b85f354-9cdb-47e1-baf9-3d266bb7e06b'),
          'sfera',(SELECT count(*) FROM clan_aburame_private.sfera_sources_v1 WHERE state IN ('reserved','active'))) AS in_flight
 FROM parameters p CROSS JOIN mission_factory_owner.editor_release_readiness r
 JOIN mission_public_owner.release_admissions_v1 rel ON rel.release_sha256=r.revision_sha256
 JOIN mission_public_owner.public_qualification_attestations_v1 a ON a.release_sha256=r.revision_sha256
 JOIN mission_public_owner.party_launch_runtime_v1 y ON y.singleton
 WHERE r.singleton AND p.binding IS NOT NULL
),
delta AS (
 SELECT o.*,
        jsonb_set(jsonb_set(jsonb_set(jsonb_set(o.doc,
         '{ui,files,land.html,sha256}',o.publication->'sha256',false),
         '{ui,files,land.html,bytes}',o.publication->'bytes',false),
         '{ui,build}',o.publication->'build',false),
         '{ui,git_head}',o.publication->'git_commit',false) AS target_doc,
        o.abort_evidence->'published_r2' AS aborted_publication
 FROM observation o
),
preimages AS (
 SELECT d.*,
        regexp_replace(d.doc::text,$rx$("(?:[^"\\]|\\.)*")|[[:space:]]+$rx$,$b$\1$b$,'g') AS current_text,
        regexp_replace(d.target_doc::text,$rx$("(?:[^"\\]|\\.)*")|[[:space:]]+$rx$,$b$\1$b$,'g') AS target_text,
        regexp_replace(jsonb_set(d.target_doc,'{ui,git_head}',to_jsonb('6e5f283f13950bf89584fa2b50ca1a7cf1a83e14'::text),false)::text,
          $rx$("(?:[^"\\]|\\.)*")|[[:space:]]+$rx$,$b$\1$b$,'g') AS recovery_origin,
        regexp_replace(jsonb_set(jsonb_set(jsonb_set(jsonb_set(d.doc,
          '{ui,files,land.html,sha256}',d.aborted_publication->'sha256',false),
          '{ui,files,land.html,bytes}',d.aborted_publication->'bytes',false),
          '{ui,build}',d.aborted_publication->'build',false),
          '{ui,git_head}',d.aborted_publication->'git_commit',false)::text,
          $rx$("(?:[^"\\]|\\.)*")|[[:space:]]+$rx$,$b$\1$b$,'g') AS aborted_text
 FROM delta d
),
identity AS (
 SELECT f.*,
        public.combat_v2_sha256(f.target_doc->'ui') AS target_client_sha256,
        encode(extensions.digest(convert_to(f.target_text,'UTF8'),'sha256'),'hex') AS target_root_sha256,
        octet_length(f.target_text) AS target_root_bytes,
        encode(extensions.digest(convert_to(f.aborted_text,'UTF8'),'sha256'),'hex') AS aborted_release_sha256,
        (f.doc#>'{ui,git_head}' IS DISTINCT FROM f.target_doc#>'{ui,git_head}'
         AND (f.mode='publication_abort' AND f.target_doc =
              jsonb_set(f.doc,'{ui,git_head}',f.publication->'git_commit',false)
             OR f.mode<>'publication_abort'
              AND f.doc#>'{ui,files,land.html,sha256}' IS DISTINCT FROM f.target_doc#>'{ui,files,land.html,sha256}'
              AND f.doc#>'{ui,files,land.html,bytes}' IS DISTINCT FROM f.target_doc#>'{ui,files,land.html,bytes}'
              AND f.doc#>'{ui,build}' IS DISTINCT FROM f.target_doc#>'{ui,build}'
              AND (f.doc #- '{ui,files,land.html,sha256}' #- '{ui,files,land.html,bytes}' #- '{ui,build}' #- '{ui,git_head}')
               = (f.target_doc #- '{ui,files,land.html,sha256}' #- '{ui,files,land.html,bytes}' #- '{ui,build}' #- '{ui,git_head}'))
         AND f.target_text::jsonb=f.target_doc) AS exact_delta
 FROM preimages f
)
SELECT jsonb_build_object(
 'schema_version','staff-land-r2-root-preflight/2','mode',i.mode,'subject_sha256',i.binding->>'subject_sha256',
 'publication',i.publication,'parent',i.parent,
 'publication_abort_evidence',i.abort_evidence,'aborted_release_sha256',i.aborted_release_sha256,
 'target',jsonb_build_object('root_sha256',i.target_root_sha256,'client_sha256',i.target_client_sha256,'root_bytes',i.target_root_bytes),
 'observed_parent_git_head',i.doc#>>'{ui,git_head}','parent_client_sha256',i.parent_client_sha256,
 'quiescence',i.in_flight,'mission_admissions',i.admissions,'party',i.party,'seals',jsonb_build_object('E52',i.e52,'Common',i.common,'Verme',i.verme),
 'projection_pass',coalesce(
  i.e52 AND i.common AND i.verme AND i.qualification_live AND i.current_text=i.canonical_preimage
  AND i.observed_revision_sha256=i.revision_sha256
  AND encode(extensions.digest(convert_to(i.current_text,'UTF8'),'sha256'),'hex')=i.revision_sha256
  AND i.state='enabled' AND i.scope='staff' AND i.staff_guards_verified AND i.published_assets_verified
  AND i.parent=i.binding->'expected_parent'
  AND i.in_flight='{"combat":0,"master":0,"staff_invites":0,"sfera":0}'::jsonb
  AND i.exact_delta AND i.target_root_bytes<=524288 AND i.target_client_sha256<>i.parent_client_sha256
  AND i.publication->>'git_commit' ~ '^[a-f0-9]{40}$'
  AND i.publication->>'git_commit'<>repeat(left(i.publication->>'git_commit',1),40)
  AND i.parent_client_sha256=public.combat_v2_sha256(i.doc->'ui')
  AND i.admissions=2 AND i.admission_rows=2 AND i.profiles=1
  AND i.profile_state->'authoring_enabled'='true'::jsonb AND i.profile_state->'runtime_enabled'='true'::jsonb
  AND i.party=jsonb_build_object('singleton',true,'release_sha256',i.revision_sha256,'staff_enabled',true,'public_enabled',true)
  AND public.combat_v2_sha256(i.qualification->'capabilities')='49fe134f561273f28e8071b63c45886341371b67d028f06e6b7d8f8d4108e817'
  AND i.target_root_sha256 NOT IN (i.revision_sha256,'7fbaf84839f038ab7dc99747bae12bee140cb935547175ab06b2271c3578cdd1')
  AND NOT EXISTS(SELECT 1 FROM mission_public_owner.release_admissions_v1 x WHERE x.release_sha256=i.target_root_sha256)
  AND NOT EXISTS(SELECT 1 FROM mission_public_owner.public_qualification_attestations_v1 x WHERE x.release_sha256=i.target_root_sha256)
  AND NOT EXISTS(SELECT 1 FROM mission_public_owner.engine_profile_events_v1 x WHERE x.engine_release_sha256=i.target_root_sha256)
  AND NOT EXISTS(SELECT 1 FROM mission_public_owner.mission_content_admissions_v1 x WHERE x.engine_release_sha256=i.target_root_sha256)
  AND (i.mode IN ('install','publication_abort')
        AND i.target_root_bytes=(CASE WHEN i.mode='install' THEN 524224 ELSE 524230 END)
        AND i.revision_sha256='7fbaf84839f038ab7dc99747bae12bee140cb935547175ab06b2271c3578cdd1'
        AND i.row_sha='5b6fe3ddb8090da1423ddc83e21cac670ff605bf69a15d0fb53ecad8e12e9221'
       OR i.mode='recovery_forward' AND i.target_root_bytes=524230
        AND encode(extensions.digest(convert_to(i.recovery_origin,'UTF8'),'sha256'),'hex')='7fbaf84839f038ab7dc99747bae12bee140cb935547175ab06b2271c3578cdd1')
  AND (i.mode<>'publication_abort' AND i.abort_evidence='null'::jsonb AND i.aborted_release_sha256 IS NULL
       OR i.mode='publication_abort'
        AND i.aborted_release_sha256 NOT IN (i.revision_sha256,i.target_root_sha256)
        AND i.aborted_publication->>'git_commit' ~ '^[a-f0-9]{40}$'
        AND i.aborted_publication->>'git_commit'<>repeat(left(i.aborted_publication->>'git_commit',1),40)
        AND i.aborted_publication->>'git_commit' NOT IN (i.doc#>>'{ui,git_head}',i.publication->>'git_commit')
        AND i.abort_evidence#>>'{git_advance,head}'=i.publication->>'git_commit'
        AND i.abort_evidence#>>'{git_advance,base}'=i.aborted_publication->>'git_commit'
        AND i.abort_evidence#>>'{git_advance,merge_base_commit}'=i.aborted_publication->>'git_commit'
        AND i.abort_evidence#>>'{git_advance,status}'='ahead'
        AND i.abort_evidence#>>'{git_advance,ahead_by}' ~ '^[1-9][0-9]*$'
        AND i.abort_evidence#>'{git_advance,behind_by}'='0'::jsonb
        AND i.publication->'pages_run_id' IS DISTINCT FROM i.aborted_publication->'pages_run_id'
        AND NOT EXISTS(SELECT 1 FROM mission_public_owner.release_admissions_v1 x WHERE x.release_sha256=i.aborted_release_sha256)
        AND NOT EXISTS(SELECT 1 FROM mission_public_owner.public_qualification_attestations_v1 x WHERE x.release_sha256=i.aborted_release_sha256)
        AND NOT EXISTS(SELECT 1 FROM mission_public_owner.engine_profile_events_v1 x WHERE x.engine_release_sha256=i.aborted_release_sha256)
        AND NOT EXISTS(SELECT 1 FROM mission_public_owner.mission_content_admissions_v1 x WHERE x.engine_release_sha256=i.aborted_release_sha256))
 ,false)
) AS projection
FROM identity i;
ROLLBACK;
