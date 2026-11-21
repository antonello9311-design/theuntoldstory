-- I commit omogenei qui sotto sono segnaposto rifiutati dal renderer e dall'Entry.
-- Il genitore post-apply è una proiezione della Root viva, nessuna scrittura.
BEGIN READ ONLY;
SET LOCAL search_path='';
SET LOCAL statement_timeout='45s';
SET LOCAL timezone='UTC';

WITH origin AS (
 SELECT r.revision_sha256 AS sha, r.canonical_preimage::jsonb AS doc,r.canonical_preimage AS raw,
  public.combat_v2_sha256(to_jsonb(r)) AS row_sha,
  clan_innata_private.catalogo_eligibility_release_v1() IS TRUE AS e52,
  clan_innata_private.runtime_release_assert()::text='' AS common,
  clan_aburame_private.verme_release_v1() IS TRUE AS verme,
  mission_public_owner.engine_qualification_v1(r.revision_sha256,true) IS NOT NULL AS qualified,
  (SELECT to_jsonb(p) FROM mission_public_owner.party_launch_runtime_v1 p WHERE p.singleton) AS party
 FROM mission_factory_owner.editor_release_readiness r WHERE r.singleton
), staged AS (
 SELECT o.*,
  jsonb_set(jsonb_set(jsonb_set(jsonb_set(o.doc,
   '{ui,files,land.html,sha256}',to_jsonb('adb9b0a62369e6ea4ab8d139934c9e8293d1506e51ff9bc3847508e4b32559e6'::text),false),
   '{ui,files,land.html,bytes}','2472602'::jsonb,false),
   '{ui,build}',to_jsonb('staff-common-presence-20261120-2'::text),false),
   '{ui,git_head}',to_jsonb(repeat('b',40)),false) AS r2_doc
 FROM origin o
), transitions AS (
 SELECT s.*,v.mode,v.parent,v.target,v.expected_size,v.expected_paths
 FROM staged s CROSS JOIN LATERAL (VALUES
   ('install',s.doc,s.r2_doc,524224,ARRAY['build','bytes','git_head','sha256']),
   ('recovery_forward',s.r2_doc,jsonb_set(s.doc,'{ui,git_head}',to_jsonb(repeat('c',40)),false),524230,ARRAY['build','bytes','git_head','sha256']),
   ('publication_abort',s.doc,jsonb_set(s.doc,'{ui,git_head}',to_jsonb(repeat('d',40)),false),524230,ARRAY['git_head'])
 ) v(mode,parent,target,expected_size,expected_paths)
), preimages AS (
 SELECT t.*,
  regexp_replace(t.doc::text,$rx$("(?:[^"\\]|\\.)*")|[[:space:]]+$rx$,$b$\1$b$,'g') AS origin_rt,
  regexp_replace(t.r2_doc::text,$rx$("(?:[^"\\]|\\.)*")|[[:space:]]+$rx$,$b$\1$b$,'g') AS r2_raw,
  regexp_replace(t.parent::text,$rx$("(?:[^"\\]|\\.)*")|[[:space:]]+$rx$,$b$\1$b$,'g') AS parent_raw,
  regexp_replace(t.target::text,$rx$("(?:[^"\\]|\\.)*")|[[:space:]]+$rx$,$b$\1$b$,'g') AS target_raw
 FROM transitions t
), identity AS (
 SELECT p.*,
   encode(extensions.digest(convert_to(p.r2_raw,'UTF8'),'sha256'),'hex') AS r2_sha,
   encode(extensions.digest(convert_to(p.parent_raw,'UTF8'),'sha256'),'hex') AS parent_sha,
   encode(extensions.digest(convert_to(p.target_raw,'UTF8'),'sha256'),'hex') AS target_sha,
   public.combat_v2_sha256(p.target->'ui') AS target_client,
   octet_length(p.target_raw) AS target_bytes,
   (SELECT array_agg(x.path ORDER BY x.path) FROM (VALUES
    ('build',p.parent#>'{ui,build}',p.target#>'{ui,build}'),
    ('bytes',p.parent#>'{ui,files,land.html,bytes}',p.target#>'{ui,files,land.html,bytes}'),
    ('git_head',p.parent#>'{ui,git_head}',p.target#>'{ui,git_head}'),
    ('sha256',p.parent#>'{ui,files,land.html,sha256}',p.target#>'{ui,files,land.html,sha256}')
   ) x(path,before,after) WHERE x.before IS DISTINCT FROM x.after) AS changed
 FROM preimages p
), checks AS (
 SELECT i.*,
  (i.origin_rt=i.raw AND i.sha='7fbaf84839f038ab7dc99747bae12bee140cb935547175ab06b2271c3578cdd1'
   AND i.row_sha='5b6fe3ddb8090da1423ddc83e21cac670ff605bf69a15d0fb53ecad8e12e9221'
   AND i.sha=encode(extensions.digest(convert_to(i.raw,'UTF8'),'sha256'),'hex') AND i.target_raw::jsonb=i.target) AS canonical_roundtrip,
  ((i.parent #- '{ui,files,land.html,sha256}' #- '{ui,files,land.html,bytes}' #- '{ui,build}' #- '{ui,git_head}')
  = (i.target #- '{ui,files,land.html,sha256}' #- '{ui,files,land.html,bytes}' #- '{ui,build}' #- '{ui,git_head}')
   AND (i.mode<>'publication_abort' OR i.target #- '{ui,git_head}'=i.parent #- '{ui,git_head}')) AS outside_paths_unchanged,
  (i.mode='install' OR jsonb_set(i.target,'{ui,git_head}',i.doc#>'{ui,git_head}',false)=i.doc) AS original_asset_restored,
  (NOT EXISTS (SELECT 1 FROM mission_public_owner.release_admissions_v1 WHERE release_sha256=i.r2_sha)
   AND NOT EXISTS (SELECT 1 FROM mission_public_owner.public_qualification_attestations_v1 WHERE release_sha256=i.r2_sha)
   AND NOT EXISTS (SELECT 1 FROM mission_public_owner.engine_profile_events_v1 WHERE engine_release_sha256=i.r2_sha)
   AND NOT EXISTS (SELECT 1 FROM mission_public_owner.mission_content_admissions_v1 WHERE engine_release_sha256=i.r2_sha)) AS r2_unallocated,
  (SELECT count(*) FROM mission_public_owner.mission_content_admissions_v1 c WHERE c.engine_release_sha256=i.sha
    AND mission_public_owner.content_admission_v1(c.mission_id,i.sha,c.publication_request,true) IS NOT NULL) AS origin_missions_active,
  (SELECT count(DISTINCT extensions.uuid_generate_v5(
    CASE WHEN i.mode='recovery_forward'
      THEN extensions.uuid_generate_v5(c.request_key,i.r2_sha||':catalogo-compatible-adoption')
      ELSE c.request_key END,i.target_sha||':catalogo-compatible-adoption'))
   FROM mission_public_owner.mission_content_admissions_v1 c WHERE c.engine_release_sha256=i.sha) AS target_request_count,
  (i.party=jsonb_build_object('singleton',true,'release_sha256',i.sha,'staff_enabled',true,'public_enabled',true)
    AND jsonb_set(i.party,'{release_sha256}',to_jsonb(i.target_sha),false)-'release_sha256'=i.party-'release_sha256') AS party_pins
 FROM identity i
)
SELECT jsonb_build_object(
 'state','MODEL_ONLY_NOT_INSTALLABLE','mode',c.mode,'parent_is_modeled',c.mode='recovery_forward',
 'current_root',c.sha,'current_row_sha256',c.row_sha,'parent',c.parent_sha,
 'model_target',c.target_sha,'model_target_client',c.target_client,'model_r2',c.r2_sha,
 'bytes',c.target_bytes,'cap_headroom',524288-c.target_bytes,'changed_fields',c.changed,
 'outside_paths_unchanged',c.outside_paths_unchanged,'restored_original_asset',c.original_asset_restored,
 'model_r2_unallocated_in_four_tables',c.r2_unallocated,'origins_admitted',c.origin_missions_active,
 'target_request_count',c.target_request_count,'party_pins',c.party_pins,
 'e52_common_verme_current',c.e52 AND c.common AND c.verme,
 'model_pass',coalesce(c.canonical_roundtrip AND c.changed=c.expected_paths AND c.target_bytes=c.expected_size
  AND c.target_bytes<=524288 AND c.outside_paths_unchanged AND c.original_asset_restored
  AND c.r2_unallocated AND c.origin_missions_active=2 AND c.target_request_count=2 AND c.party_pins
  AND c.e52 AND c.common AND c.verme AND c.qualified AND c.target_sha<>c.parent_sha
  AND c.target_client<>public.combat_v2_sha256(c.parent->'ui')
  AND (c.mode<>'publication_abort' OR c.target_sha<>c.r2_sha),false)
) AS model
FROM checks c ORDER BY CASE c.mode WHEN 'install' THEN 1 WHEN 'recovery_forward' THEN 2 ELSE 3 END;
ROLLBACK;
