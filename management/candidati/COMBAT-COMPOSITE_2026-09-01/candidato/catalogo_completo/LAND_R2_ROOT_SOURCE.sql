BEGIN;
SET LOCAL search_path='';
SET LOCAL statement_timeout='45s';
SET LOCAL lock_timeout='2s';
SET LOCAL timezone='UTC';

DO $land_r2_root$
DECLARE
 -- The binder changes these two declarations only. Unbound source stops before a lock.
 bound_text constant text := NULL; -- LAND_R2_BINDING_TEXT
 bound_sha constant text := NULL; -- LAND_R2_BINDING_SHA256
 origin_root constant text := '7fbaf84839f038ab7dc99747bae12bee140cb935547175ab06b2271c3578cdd1';
 origin_row constant text := '5b6fe3ddb8090da1423ddc83e21cac670ff605bf69a15d0fb53ecad8e12e9221';
 origin_commit constant text := '6e5f283f13950bf89584fa2b50ca1a7cf1a83e14';
 origin_land_sha constant text := '7d48cd18580ae4fd84d35ae566a8c26fd8b380b0f4b4bb80def3d346f50b7d68';
 origin_land_blob constant text := 'ebbe0d60e763c590780cbbeb34adbe17cba07dee';
 origin_land_build constant text := 'staff-ninjabook-preparation-20261120-2';
 r2_land_sha constant text := 'adb9b0a62369e6ea4ab8d139934c9e8293d1506e51ff9bc3847508e4b32559e6';
 r2_land_blob constant text := 'f4eabdf14a463338f129ab3af8a3fcb5ab5741ac';
 r2_land_build constant text := 'staff-common-presence-20261120-2';
 r2_freeze constant text := 'c90fceb7e2b8803eee88badb2c2b2736b9be86607e8d750fc33b0f8d0f53bfe4';
 generic_ezbr constant text := '9a6889802cfa17c99a556538cccd4ad7ef75274d32adccbc192c23d257aa3e76';
 capability_sha constant text := '49fe134f561273f28e8071b63c45886341371b67d028f06e6b7d8f8d4108e817';
 namespace_uuid constant uuid := '5d20915b-9e97-5eca-8851-fd9f7f4c842a';
 origin_business_pins constant jsonb := '{
  "admission_row_sha256":"bd6eaa276575215e469c1e4a8da31a52e7f5aa7bbfcff979fa0e39b626130ae5",
  "profile_row_sha256":"e1eab01f40cc61da213b530dd9dc67ee6ef241cf0da8b372c2e41b8c1db9bd36",
  "qualification_row_sha256":"5df22e3621424450394b973e473d970daa36dda374f7a1640778f66e9bc4194e",
  "content_rows_sha256":"f64b767a326b06919d961df2461d1ee27514d741096a41cb73930ccd176688ec",
  "party_row_sha256":"5ab8a1d63a29d9d44b0debf9629d50a3c7acebab41fa578ba3cb8fa72f670b02"
 }'::jsonb;
 binding jsonb;
 publication jsonb;
 checked_publication jsonb;
 abort_evidence jsonb;
 aborted_publication jsonb;
 git_advance jsonb;
 checked_commit text;
 aborted_revision text;
 aborted_doc jsonb;
 review_record jsonb;
 parent_expected jsonb;
 target_expected jsonb;
 parent_business jsonb;
 after_business jsonb;
 mode text;
 predecessor_commit text;
 candidate_commit text;
 digest_value text;
 parent_revision text;
 parent_row_sha text;
 party_before jsonb;
 confirmed_publication boolean;
 old_doc jsonb;
 candidate_doc jsonb;
 origin_doc jsonb;
 candidate_text text;
 candidate_revision text;
 candidate_client text;
 next_bindings jsonb;
 next_qualification jsonb;
 content_payload jsonb;
 content_request uuid;
 affected integer;
 resources_before jsonb;
 resources_after jsonb;
 rr mission_factory_owner.editor_release_readiness%ROWTYPE;
 rr_after mission_factory_owner.editor_release_readiness%ROWTYPE;
 prior_release mission_public_owner.release_admissions_v1%ROWTYPE;
 prior_qualification mission_public_owner.public_qualification_attestations_v1%ROWTYPE;
 prior_profile mission_public_owner.engine_profile_events_v1%ROWTYPE;
 content_row mission_public_owner.mission_content_admissions_v1%ROWTYPE;
BEGIN
 IF bound_text IS NULL OR bound_sha IS NULL THEN
  RAISE EXCEPTION 'LAND_R2_FINAL_ENTRY_BINDING_REQUIRED';
 END IF;
 IF encode(extensions.digest(convert_to(bound_text,'UTF8'),'sha256'),'hex') IS DISTINCT FROM bound_sha THEN
  RAISE EXCEPTION 'LAND_R2_BINDING_DIGEST_DRIFT';
 END IF;
 binding:=bound_text::jsonb;
 publication:=binding->'publication';
 review_record:=binding->'independent_review';
 parent_expected:=binding->'parent';
 target_expected:=binding->'target';
 mode:=binding->>'mode';
 abort_evidence:=binding->'publication_abort_evidence';
 aborted_publication:=abort_evidence->'published_r2';
 git_advance:=abort_evidence->'git_advance';

 IF mission_factory_owner.keys_exact_v2(binding,ARRAY[
  'schema_version','mode','r2_freeze_sha256','source_subject_sha256','independent_review',
  'publication','parent','target','projection_sha256','install_receipt_sha256',
  'publication_abort_evidence','aborted_release_sha256']) IS DISTINCT FROM true
 OR binding->>'schema_version' IS DISTINCT FROM 'staff-land-r2-root-entry/2'
 OR coalesce(mode,'') NOT IN ('install','recovery_forward','publication_abort')
 OR binding->>'r2_freeze_sha256' IS DISTINCT FROM r2_freeze
 OR mission_factory_owner.keys_exact_v2(review_record,ARRAY['ref','sha256','P0','P1','P2']) IS DISTINCT FROM true
 OR coalesce(review_record->>'ref','') !~ '^[A-Za-z0-9_.#-]{1,40}$'
 OR review_record->'P0' IS DISTINCT FROM '0'::jsonb
 OR review_record->'P1' IS DISTINCT FROM '0'::jsonb
 OR review_record->'P2' IS DISTINCT FROM '0'::jsonb
 OR mission_factory_owner.keys_exact_v2(parent_expected,ARRAY[
  'root_sha256','row_sha256','admission_row_sha256','profile_row_sha256','qualification_row_sha256',
  'content_rows_sha256','party_row_sha256']) IS DISTINCT FROM true
 OR mission_factory_owner.keys_exact_v2(target_expected,ARRAY['root_sha256','client_sha256','root_bytes']) IS DISTINCT FROM true
 THEN RAISE EXCEPTION 'LAND_R2_BINDING_SHAPE_OR_REVIEW'; END IF;

 FOREACH digest_value IN ARRAY ARRAY[
  bound_sha,binding->>'source_subject_sha256',binding->>'projection_sha256',review_record->>'sha256',
  publication->>'sha256',parent_expected->>'root_sha256',parent_expected->>'row_sha256',
  parent_expected->>'admission_row_sha256',parent_expected->>'profile_row_sha256',
  parent_expected->>'qualification_row_sha256',parent_expected->>'content_rows_sha256',
  parent_expected->>'party_row_sha256',target_expected->>'root_sha256',target_expected->>'client_sha256']
 LOOP
  IF coalesce(digest_value,'') !~ '^[a-f0-9]{64}$'
   OR digest_value=repeat(left(digest_value,1),64)
  THEN RAISE EXCEPTION 'LAND_R2_BINDING_SHA_OR_PLACEHOLDER'; END IF;
 END LOOP;

 candidate_commit:=publication->>'git_commit';
 IF mode='publication_abort' THEN
  IF mission_factory_owner.keys_exact_v2(abort_evidence,ARRAY['published_r2','git_advance']) IS DISTINCT FROM true
  OR mission_factory_owner.keys_exact_v2(git_advance,ARRAY[
   'base','head','status','ahead_by','behind_by','merge_base_commit','evidence_sha256']) IS DISTINCT FROM true
  OR git_advance->>'base' IS DISTINCT FROM aborted_publication->>'git_commit'
  OR git_advance->>'merge_base_commit' IS DISTINCT FROM aborted_publication->>'git_commit'
  OR git_advance->>'head' IS DISTINCT FROM candidate_commit
  OR git_advance->>'status' IS DISTINCT FROM 'ahead'
  OR coalesce(git_advance->>'ahead_by','') !~ '^[1-9][0-9]*$'
  OR git_advance->'behind_by' IS DISTINCT FROM '0'::jsonb
  OR candidate_commit IS NOT DISTINCT FROM aborted_publication->>'git_commit'
  OR publication->'pages_run_id' IS NOT DISTINCT FROM aborted_publication->'pages_run_id'
  OR (aborted_publication->>'sha256',aborted_publication->>'git_blob',aborted_publication->>'build',aborted_publication->'bytes')
    IS DISTINCT FROM (r2_land_sha,r2_land_blob,r2_land_build,'2472602'::jsonb)
  OR aborted_publication->>'domain_marker' IS DISTINCT FROM 'tus-staff-common-presence-build'
  THEN RAISE EXCEPTION 'LAND_R2_ABORT_PUBLICATION_CHAIN_REQUIRED'; END IF;
  FOREACH digest_value IN ARRAY ARRAY[git_advance->>'evidence_sha256',binding->>'aborted_release_sha256'] LOOP
   IF coalesce(digest_value,'') !~ '^[a-f0-9]{64}$' OR digest_value=repeat(left(digest_value,1),64)
   THEN RAISE EXCEPTION 'LAND_R2_ABORT_EVIDENCE_SHA_OR_PLACEHOLDER'; END IF;
  END LOOP;
 ELSIF abort_evidence IS DISTINCT FROM 'null'::jsonb OR binding->'aborted_release_sha256' IS DISTINCT FROM 'null'::jsonb THEN
  RAISE EXCEPTION 'LAND_R2_ABORT_EVIDENCE_OUTSIDE_MODE';
 END IF;
 FOREACH checked_publication IN ARRAY (CASE WHEN mode='publication_abort'
  THEN ARRAY[aborted_publication,publication] ELSE ARRAY[publication] END) LOOP
  IF mission_factory_owner.keys_exact_v2(checked_publication,ARRAY[
  'schema_version','repo','filename','git_commit','git_blob','sha256','bytes','build',
  'pages_run_id','pages_commit','pages_conclusion','deployment_success','domain_url','domain_status',
  'domain_sha256','domain_bytes','domain_build','domain_method','domain_marker','domain_body_verified',
  'domain_after_pages','domain_pages_run_id','client_review_sha256','publication_receipt_sha256','domain_evidence_sha256']) IS DISTINCT FROM true
  THEN RAISE EXCEPTION 'LAND_R2_PUBLICATION_EVIDENCE_SHAPE'; END IF;
  FOREACH digest_value IN ARRAY ARRAY[checked_publication->>'client_review_sha256',
   checked_publication->>'publication_receipt_sha256',checked_publication->>'domain_evidence_sha256'] LOOP
   IF coalesce(digest_value,'') !~ '^[a-f0-9]{64}$' OR digest_value=repeat(left(digest_value,1),64)
   THEN RAISE EXCEPTION 'LAND_R2_PUBLICATION_SHA_OR_PLACEHOLDER'; END IF;
  END LOOP;
  checked_commit:=checked_publication->>'git_commit';
  confirmed_publication:=(
   checked_publication->>'schema_version'='staff-land-published-evidence/1'
   AND checked_publication->>'repo'='antonello9311-design/theuntoldstory'
   AND checked_publication->>'filename'='land.html'
   AND checked_commit ~ '^[a-f0-9]{40}$'
   AND checked_commit<>repeat(left(checked_commit,1),40)
   AND checked_commit<>origin_commit
   AND checked_publication->>'pages_commit'=checked_commit
   AND coalesce(checked_publication->>'pages_run_id','') ~ '^[1-9][0-9]{0,19}$'
   AND checked_publication->>'pages_conclusion'='success'
   AND checked_publication->'deployment_success'='true'::jsonb
   AND checked_publication->>'domain_url'='https://theuntoldstory.it/land.html'
   AND checked_publication->>'domain_build'=checked_publication->>'build'
   AND checked_publication->'domain_after_pages'='true'::jsonb AND checked_publication->'domain_pages_run_id'=checked_publication->'pages_run_id'
   AND ((checked_publication->>'domain_method'='response_body_sha256'
     AND checked_publication->'domain_body_verified'='true'::jsonb AND checked_publication->'domain_status'='200'::jsonb
     AND checked_publication->>'domain_sha256'=checked_publication->>'sha256' AND checked_publication->'domain_bytes'=checked_publication->'bytes')
    OR (checked_publication->>'domain_method'='git_blob_pages_commit_domain_build'
     AND checked_publication->'domain_body_verified'='false'::jsonb AND checked_publication->'domain_status' IN ('200'::jsonb,'null'::jsonb)
     AND checked_publication->'domain_sha256'='null'::jsonb AND checked_publication->'domain_bytes'='null'::jsonb))
  );
  IF confirmed_publication IS DISTINCT FROM true THEN
   RAISE EXCEPTION 'LAND_R2_GIT_PAGES_DOMAIN_RECEIPT_REQUIRED';
  END IF;
 END LOOP;
 IF mode IN ('install','publication_abort') THEN
  IF parent_expected->>'root_sha256' IS DISTINCT FROM origin_root
  OR parent_expected->>'row_sha256' IS DISTINCT FROM origin_row
  OR parent_expected-ARRAY['root_sha256','row_sha256'] IS DISTINCT FROM origin_business_pins
  OR binding->'install_receipt_sha256' IS DISTINCT FROM 'null'::jsonb
  THEN RAISE EXCEPTION 'LAND_R2_EXACT_UNAPPLIED_ORIGIN_REQUIRED'; END IF;
 ELSE
  digest_value:=binding->>'install_receipt_sha256';
  IF parent_expected->>'root_sha256'=origin_root OR parent_expected->>'row_sha256'=origin_row
  OR coalesce(digest_value,'') !~ '^[a-f0-9]{64}$'
  OR digest_value=repeat(left(digest_value,1),64)
  THEN RAISE EXCEPTION 'LAND_R2_RECOVERY_FORWARD_RECEIPT_REQUIRED'; END IF;
 END IF;
 IF mode='install' THEN
  IF (publication->>'sha256',publication->>'git_blob',publication->>'build',publication->'bytes')
    IS DISTINCT FROM (r2_land_sha,r2_land_blob,r2_land_build,'2472602'::jsonb)
  OR publication->>'domain_marker' IS DISTINCT FROM 'tus-staff-common-presence-build'
  OR target_expected->'root_bytes' IS DISTINCT FROM '524224'::jsonb
  THEN RAISE EXCEPTION 'LAND_R2_INSTALL_ASSET_FREEZE_DRIFT'; END IF;
 ELSE
  IF (publication->>'sha256',publication->>'git_blob',publication->>'build',publication->'bytes')
    IS DISTINCT FROM (origin_land_sha,origin_land_blob,origin_land_build,'2469945'::jsonb)
  OR publication->>'domain_marker' IS DISTINCT FROM 'tus-staff-ninjabook-preparation-build'
  OR target_expected->'root_bytes' IS DISTINCT FROM '524230'::jsonb
  THEN RAISE EXCEPTION 'LAND_R2_RESTORED_ASSET_FREEZE_DRIFT'; END IF;
 END IF;

 IF current_user<>'postgres' OR session_user<>'postgres' OR auth.uid() IS NOT NULL
 OR (SELECT rolbypassrls FROM pg_roles WHERE rolname='postgres') IS DISTINCT FROM true
 THEN RAISE EXCEPTION 'LAND_R2_OPERATION_ROLE_REQUIRED'; END IF;
 IF NOT pg_try_advisory_xact_lock(hashtextextended('C1266:GENERIC-AI:AVAILABILITY',0))
 THEN RAISE EXCEPTION 'LAND_R2_AVAILABILITY_BUSY'; END IF;

 SELECT r.* INTO STRICT rr FROM mission_factory_owner.editor_release_readiness r
 WHERE r.singleton FOR UPDATE NOWAIT;
 LOCK TABLE public.master_v2_sessions,public.combat_v2_sessions,
    combat_consumer_private.invitations,clan_aburame_private.sfera_sources_v1,
    mission_public_owner.party_launch_runtime_v1,mission_public_owner.release_admissions_v1,
    mission_public_owner.public_qualification_attestations_v1,mission_public_owner.engine_profile_events_v1,
    mission_public_owner.mission_content_admissions_v1 IN SHARE ROW EXCLUSIVE MODE NOWAIT;

 IF EXISTS(SELECT 1 FROM public.combat_v2_sessions WHERE closed_at IS NULL AND state IN ('preparazione','in_corso','sospeso'))
 OR EXISTS(SELECT 1 FROM public.master_v2_sessions WHERE closed_at IS NULL AND stato NOT IN ('chiusa','annullata'))
 OR EXISTS(SELECT 1 FROM combat_consumer_private.invitations
  WHERE state='pending' AND location_id='0b85f354-9cdb-47e1-baf9-3d266bb7e06b')
 OR EXISTS(SELECT 1 FROM clan_aburame_private.sfera_sources_v1 WHERE state IN ('reserved','active'))
 THEN RAISE EXCEPTION 'LAND_R2_QUIESCENCE_REQUIRED'; END IF;
 IF EXISTS(
  WITH expected(name,ddl_md5) AS (VALUES
   ('engine_profile_events_immutable','35fc429bf65f7873fbe1193cde9752b7'),
   ('mission_content_admissions_immutable','7f3c9792cfd39b23fa13c46712a20113'),
   ('public_attestation_immutable','e36de3cc0086a28dbb8968a7b455ddf2'),
   ('public_release_identity_immutable','cb7a9db00c3ce783e44493b950b9fcfd')),
  actual AS (
   SELECT tgname::text AS name,md5(pg_get_triggerdef(oid)) AS ddl_md5,tgenabled
   FROM pg_trigger WHERE NOT tgisinternal AND tgrelid IN(
    'mission_factory_owner.editor_release_readiness'::regclass,
    'mission_public_owner.party_launch_runtime_v1'::regclass,
    'mission_public_owner.engine_profile_events_v1'::regclass,
    'mission_public_owner.mission_content_admissions_v1'::regclass,
    'mission_public_owner.public_qualification_attestations_v1'::regclass,
    'mission_public_owner.release_admissions_v1'::regclass))
  SELECT 1 FROM expected e FULL JOIN actual a USING(name)
  WHERE a.tgenabled IS DISTINCT FROM 'O' OR a.ddl_md5 IS DISTINCT FROM e.ddl_md5)
 THEN RAISE EXCEPTION 'LAND_R2_UNREVIEWED_TRIGGER'; END IF;
 IF EXISTS(
  WITH expected(sig,source_md5) AS (VALUES
   ('clan_innata_private.catalogo_eligibility_release_v1()','0b75f13a83afd5cdb24f29f94a7568d8'),
   ('clan_innata_private.runtime_release_assert()','6b9ed7edc3ea365017e1f5e84200ed79'),
   ('clan_aburame_private.verme_release_v1()','1df436e50d123cfaf302edec8f72baea'),
   ('mission_public_owner.engine_qualification_v1(text,boolean)','4a47e67e505e0e002f8d1d24ea4aba2c'),
   ('mission_public_owner.content_admission_v1(uuid,text,uuid,boolean)','755ea461db058d1c313ce7aa0598a3bc'),
   ('mission_public_owner.party_execution_context_v1(uuid)','636f257687bb83f3633123058adde20f'),
   ('public.mission_party_staff_prepare_v1(uuid,uuid,uuid[],uuid)','2c378254bf307f38726ed21a8eba93b6'))
  SELECT 1 FROM expected e LEFT JOIN pg_proc p ON p.oid=to_regprocedure(e.sig)
  WHERE md5(p.prosrc) IS DISTINCT FROM e.source_md5)
 THEN RAISE EXCEPTION 'LAND_R2_CONSUMER_DRIFT'; END IF;

 parent_revision:=rr.revision_sha256;
 parent_row_sha:=public.combat_v2_sha256(to_jsonb(rr));
 IF parent_revision IS DISTINCT FROM parent_expected->>'root_sha256'
 OR parent_row_sha IS DISTINCT FROM parent_expected->>'row_sha256'
 OR rr.observed_revision_sha256 IS DISTINCT FROM parent_revision
 OR encode(extensions.digest(convert_to(rr.canonical_preimage,'UTF8'),'sha256'),'hex') IS DISTINCT FROM parent_revision
 OR octet_length(rr.canonical_preimage) IS DISTINCT FROM (CASE WHEN mode='recovery_forward' THEN 524224 ELSE 524230 END)
 OR rr.scope IS DISTINCT FROM 'staff' OR rr.state IS DISTINCT FROM 'enabled'
 OR rr.staff_guards_verified IS DISTINCT FROM true OR rr.published_assets_verified IS DISTINCT FROM true
 OR clan_innata_private.catalogo_eligibility_release_v1() IS DISTINCT FROM true
 OR clan_aburame_private.verme_release_v1() IS DISTINCT FROM true
 THEN RAISE EXCEPTION 'LAND_R2_PARENT_CAS_OR_RUNTIME_DRIFT'; END IF;
 PERFORM clan_innata_private.runtime_release_assert();

 old_doc:=rr.canonical_preimage::jsonb;
 predecessor_commit:=old_doc#>>'{ui,git_head}';
 IF candidate_commit=predecessor_commit
 OR regexp_replace(old_doc::text,$rx$("(?:[^"\\]|\\.)*")|[[:space:]]+$rx$,$b$\1$b$,'g') IS DISTINCT FROM rr.canonical_preimage
 OR (mode='recovery_forward' AND (
  (old_doc#>>'{ui,build}',old_doc#>>'{ui,files,land.html,sha256}',old_doc#>'{ui,files,land.html,bytes}')
   IS DISTINCT FROM (r2_land_build,r2_land_sha,'2472602'::jsonb)
  OR coalesce(predecessor_commit,'') !~ '^[a-f0-9]{40}$'
  OR predecessor_commit=repeat(left(predecessor_commit,1),40)
  OR predecessor_commit=origin_commit))
 THEN RAISE EXCEPTION 'LAND_R2_PREDECESSOR_ASSET_DRIFT'; END IF;

 candidate_doc:=jsonb_set(jsonb_set(jsonb_set(jsonb_set(old_doc,
  ARRAY['ui','files','land.html','sha256'],publication->'sha256',false),
  ARRAY['ui','files','land.html','bytes'],publication->'bytes',false),
  ARRAY['ui','build'],publication->'build',false),
  ARRAY['ui','git_head'],to_jsonb(candidate_commit),false);
 candidate_text:=regexp_replace(candidate_doc::text,$rx$("(?:[^"\\]|\\.)*")|[[:space:]]+$rx$,$b$\1$b$,'g');
 candidate_revision:=encode(extensions.digest(convert_to(candidate_text,'UTF8'),'sha256'),'hex');
 candidate_client:=public.combat_v2_sha256(candidate_doc->'ui');

 IF ((mode='publication_abort' AND candidate_doc IS NOT DISTINCT FROM
      jsonb_set(old_doc,'{ui,git_head}',to_jsonb(candidate_commit),false))
   OR (mode<>'publication_abort'
     AND old_doc#>'{ui,files,land.html,sha256}' IS DISTINCT FROM candidate_doc#>'{ui,files,land.html,sha256}'
     AND old_doc#>'{ui,files,land.html,bytes}' IS DISTINCT FROM candidate_doc#>'{ui,files,land.html,bytes}'
     AND old_doc#>'{ui,build}' IS DISTINCT FROM candidate_doc#>'{ui,build}'
     AND (candidate_doc #- '{ui,files,land.html,sha256}' #- '{ui,files,land.html,bytes}' #- '{ui,build}' #- '{ui,git_head}')
       IS NOT DISTINCT FROM (old_doc #- '{ui,files,land.html,sha256}' #- '{ui,files,land.html,bytes}' #- '{ui,build}' #- '{ui,git_head}')))
   IS DISTINCT FROM true
 OR octet_length(candidate_text)>524288
 OR (candidate_revision,candidate_client,to_jsonb(octet_length(candidate_text))) IS DISTINCT FROM
    (target_expected->>'root_sha256',target_expected->>'client_sha256',target_expected->'root_bytes')
 OR candidate_text::jsonb IS DISTINCT FROM candidate_doc
 OR candidate_revision IN (origin_root,parent_revision)
 THEN RAISE EXCEPTION 'LAND_R2_CANDIDATE_PROJECTION_OR_BYTE_BUDGET'; END IF;
 IF mode='publication_abort' THEN
  aborted_doc:=jsonb_set(jsonb_set(jsonb_set(jsonb_set(old_doc,
   '{ui,files,land.html,sha256}',aborted_publication->'sha256',false),
   '{ui,files,land.html,bytes}',aborted_publication->'bytes',false),
   '{ui,build}',aborted_publication->'build',false),
   '{ui,git_head}',aborted_publication->'git_commit',false);
  aborted_revision:=encode(extensions.digest(convert_to(
   regexp_replace(aborted_doc::text,$rx$("(?:[^"\\]|\\.)*")|[[:space:]]+$rx$,$b$\1$b$,'g'),'UTF8'),'sha256'),'hex');
  IF aborted_revision IS DISTINCT FROM binding->>'aborted_release_sha256'
  OR aborted_revision IN (origin_root,candidate_revision)
  OR EXISTS(SELECT 1 FROM mission_public_owner.release_admissions_v1 WHERE release_sha256=aborted_revision)
  OR EXISTS(SELECT 1 FROM mission_public_owner.public_qualification_attestations_v1 WHERE release_sha256=aborted_revision)
  OR EXISTS(SELECT 1 FROM mission_public_owner.engine_profile_events_v1 WHERE engine_release_sha256=aborted_revision)
  OR EXISTS(SELECT 1 FROM mission_public_owner.mission_content_admissions_v1 WHERE engine_release_sha256=aborted_revision)
  THEN RAISE EXCEPTION 'LAND_R2_ABORT_R2_APPLIED_OR_IDENTITY_DRIFT'; END IF;
 END IF;
 IF mode IN ('recovery_forward','publication_abort') THEN
  origin_doc:=jsonb_set(candidate_doc,'{ui,git_head}',to_jsonb(origin_commit),false);
  IF encode(extensions.digest(convert_to(
    regexp_replace(origin_doc::text,$rx$("(?:[^"\\]|\\.)*")|[[:space:]]+$rx$,$b$\1$b$,'g'),'UTF8'),'sha256'),'hex')
    IS DISTINCT FROM origin_root
  THEN RAISE EXCEPTION 'LAND_R2_RECOVERY_DELTA_NOT_ORIGINAL_PLUS_NEW_COMMIT'; END IF;
 END IF;

 SELECT a.* INTO STRICT prior_release FROM mission_public_owner.release_admissions_v1 a
 WHERE a.release_sha256=parent_revision;
 SELECT a.* INTO STRICT prior_qualification FROM mission_public_owner.public_qualification_attestations_v1 a
 WHERE a.release_sha256=parent_revision;
 SELECT p.* INTO STRICT prior_profile FROM mission_public_owner.engine_profile_events_v1 p
 WHERE p.engine_release_sha256=parent_revision AND p.profile_key='mission-ai-authoring/1'
 ORDER BY p.control_version DESC LIMIT 1;
 SELECT to_jsonb(p) INTO STRICT party_before FROM mission_public_owner.party_launch_runtime_v1 p
 WHERE p.singleton FOR UPDATE;

 parent_business:=jsonb_build_object(
  'admission_row_sha256',public.combat_v2_sha256(to_jsonb(prior_release)),
  'qualification_row_sha256',public.combat_v2_sha256(to_jsonb(prior_qualification)),
  'profile_row_sha256',public.combat_v2_sha256(to_jsonb(prior_profile)),
  'party_row_sha256',public.combat_v2_sha256(party_before),
  'content_rows_sha256',(SELECT public.combat_v2_sha256(jsonb_agg(to_jsonb(c) ORDER BY c.mission_id))
   FROM mission_public_owner.mission_content_admissions_v1 c WHERE c.engine_release_sha256=parent_revision));
 IF parent_business IS DISTINCT FROM parent_expected-ARRAY['root_sha256','row_sha256']
 OR prior_release.edge_sha256 IS DISTINCT FROM generic_ezbr
 OR prior_release.client_sha256 IS DISTINCT FROM public.combat_v2_sha256(old_doc->'ui')
 OR prior_release.db_sha256 IS DISTINCT FROM old_doc#>>'{db_core,sha256}'
 OR prior_release.configuration_sha256 IS DISTINCT FROM old_doc#>>'{config,sha256}'
 OR prior_release.public_enabled IS DISTINCT FROM true
 OR mission_public_owner.engine_qualification_v1(parent_revision,true) IS NULL
 OR public.combat_v2_sha256(prior_qualification.payload->'capabilities') IS DISTINCT FROM capability_sha
 OR NOT prior_profile.authoring_enabled OR NOT prior_profile.runtime_enabled
 OR (SELECT count(DISTINCT profile_key) FROM mission_public_owner.engine_profile_events_v1
    WHERE engine_release_sha256=parent_revision) IS DISTINCT FROM 1
 OR party_before IS DISTINCT FROM jsonb_build_object(
    'singleton',true,'release_sha256',parent_revision,'staff_enabled',true,'public_enabled',true)
 OR (SELECT count(*) FROM mission_public_owner.mission_content_admissions_v1 c
    WHERE c.engine_release_sha256=parent_revision) IS DISTINCT FROM 2
 OR (SELECT count(*) FROM mission_public_owner.mission_content_admissions_v1 c
    WHERE c.engine_release_sha256=parent_revision AND
    mission_public_owner.content_admission_v1(c.mission_id,parent_revision,c.publication_request,true) IS NOT NULL) IS DISTINCT FROM 2
 OR EXISTS (SELECT 1 FROM mission_public_owner.release_admissions_v1 WHERE release_sha256=candidate_revision)
 OR EXISTS (SELECT 1 FROM mission_public_owner.public_qualification_attestations_v1 WHERE release_sha256=candidate_revision)
 OR EXISTS (SELECT 1 FROM mission_public_owner.engine_profile_events_v1 WHERE engine_release_sha256=candidate_revision)
 OR EXISTS (SELECT 1 FROM mission_public_owner.mission_content_admissions_v1 WHERE engine_release_sha256=candidate_revision)
 THEN RAISE EXCEPTION 'LAND_R2_PARENT_MISSIONS_OR_PARTY_DRIFT'; END IF;

 resources_before:=jsonb_build_object(
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
'combat_v2_staff_nb_internal.gate', (SELECT public.combat_v2_sha256(to_jsonb(g)) FROM combat_v2_staff_nb_internal.gate g WHERE g.singleton));

 IF resources_before->>'pill_staff_initial_two' IS DISTINCT FROM 'fbfbf747adeff748786676a6634315902f2475767fbbec67c1002b76bcdb38ed' THEN
  RAISE EXCEPTION 'LAND_R2_HISTORICAL_PILL_LEDGER_DRIFT';
 END IF;

 next_bindings:=jsonb_build_object('db_sha256',prior_release.db_sha256,'edge_sha256',prior_release.edge_sha256,
  'client_sha256',candidate_client,'configuration_sha256',prior_release.configuration_sha256);
 next_qualification:=prior_qualification.payload||jsonb_build_object(
  'revision_sha256',candidate_revision,'bindings',next_bindings,'independent_review',review_record,
  'reuse_evidence',(prior_qualification.payload->'reuse_evidence')||jsonb_build_object(
   'new_mission_QA_claim',false,'catalogo_compatibility',jsonb_build_object(
    'parent_root',parent_revision,'ref',review_record->>'ref','sha256',bound_sha,
    'scope','existing_mission_capabilities_only','new_techniques_staff_pass',false)));

 UPDATE mission_factory_owner.editor_release_readiness r
 SET canonical_preimage=candidate_text,revision_sha256=candidate_revision,observed_revision_sha256=candidate_revision,
     client_build='mission-factory-admin/2:'||candidate_revision,independent_review_ref=review_record->>'ref',
     published_assets_verified=confirmed_publication,updated_at=clock_timestamp()
 WHERE r.singleton AND r.revision_sha256=parent_revision AND public.combat_v2_sha256(to_jsonb(r))=parent_row_sha;
 GET DIAGNOSTICS affected=ROW_COUNT;
 IF affected<>1 THEN RAISE EXCEPTION 'LAND_R2_ROOT_WRITE_CAS'; END IF;

 INSERT INTO mission_public_owner.release_admissions_v1(
  release_sha256,db_sha256,edge_sha256,client_sha256,configuration_sha256,
  contract_version,independent_review_ref,staff_evidence_ref,qualified_at,public_enabled)
 VALUES(candidate_revision,prior_release.db_sha256,prior_release.edge_sha256,candidate_client,prior_release.configuration_sha256,
  prior_release.contract_version,review_record->>'ref',prior_release.staff_evidence_ref,prior_release.qualified_at,prior_release.public_enabled);
 INSERT INTO mission_public_owner.engine_profile_events_v1(
  event_id,engine_release_sha256,profile_key,expected_control_version,control_version,authoring_enabled,runtime_enabled,actor_user,reason)
 VALUES(extensions.uuid_generate_v5(namespace_uuid,candidate_revision||':profile:'||prior_profile.profile_key),
  candidate_revision,prior_profile.profile_key,0,1,prior_profile.authoring_enabled,prior_profile.runtime_enabled,prior_profile.actor_user,
  'Carryforward of existing mission profile after verified Land asset pin update');
 INSERT INTO mission_public_owner.public_qualification_attestations_v1(
  release_sha256,request_key,payload,payload_sha256,positive_staff_evidence_ref,authorized_test_manifest_ref,created_by)
 VALUES(candidate_revision,extensions.uuid_generate_v5(namespace_uuid,candidate_revision||':qualification'),
  next_qualification,mission_factory_owner.sha(next_qualification),prior_qualification.positive_staff_evidence_ref,
  prior_qualification.authorized_test_manifest_ref,prior_qualification.created_by);
 IF mission_public_owner.engine_qualification_v1(candidate_revision,true) IS DISTINCT FROM next_qualification THEN
  RAISE EXCEPTION 'LAND_R2_NEW_MISSION_QUALIFICATION_INVALID';
 END IF;

 FOR content_row IN SELECT c.* FROM mission_public_owner.mission_content_admissions_v1 c
   WHERE c.engine_release_sha256=parent_revision ORDER BY c.mission_id LOOP
  content_request:=extensions.uuid_generate_v5(content_row.request_key,candidate_revision||':catalogo-compatible-adoption');
  content_payload:=content_row.payload||jsonb_build_object(
   'request_key',content_request,'engine_release_sha256',candidate_revision,'created_at',clock_timestamp());
  INSERT INTO mission_public_owner.mission_content_admissions_v1(
   request_key,mission_id,config_version,engine_release_sha256,publication_request,payload,payload_sha256)
  VALUES(content_request,content_row.mission_id,content_row.config_version,candidate_revision,
   content_row.publication_request,content_payload,mission_factory_owner.sha(content_payload));
  IF mission_public_owner.content_admission_v1(content_row.mission_id,candidate_revision,content_row.publication_request,true) IS NULL THEN
   RAISE EXCEPTION 'LAND_R2_NEW_MISSION_ADMISSION_INVALID';
  END IF;
 END LOOP;

 UPDATE mission_public_owner.party_launch_runtime_v1 p SET release_sha256=candidate_revision
 WHERE p.singleton AND to_jsonb(p)=party_before;
 GET DIAGNOSTICS affected=ROW_COUNT;
 IF affected<>1 THEN RAISE EXCEPTION 'LAND_R2_PARTY_WRITE_CAS'; END IF;
 SELECT r.* INTO STRICT rr_after FROM mission_factory_owner.editor_release_readiness r WHERE r.singleton;
 IF rr_after.canonical_preimage IS DISTINCT FROM candidate_text
 OR (rr_after.revision_sha256,rr_after.observed_revision_sha256,rr_after.independent_review_ref,rr_after.client_build)
   IS DISTINCT FROM (candidate_revision,candidate_revision,review_record->>'ref','mission-factory-admin/2:'||candidate_revision)
 OR to_jsonb(rr_after)-ARRAY['canonical_preimage','revision_sha256','observed_revision_sha256','client_build','independent_review_ref','updated_at']
   IS DISTINCT FROM to_jsonb(rr)-ARRAY['canonical_preimage','revision_sha256','observed_revision_sha256','client_build','independent_review_ref','updated_at']
 OR clan_innata_private.catalogo_eligibility_release_v1() IS DISTINCT FROM true
 OR clan_aburame_private.verme_release_v1() IS DISTINCT FROM true
 OR (SELECT to_jsonb(p) FROM mission_public_owner.party_launch_runtime_v1 p WHERE p.singleton)
    IS DISTINCT FROM jsonb_set(party_before,'{release_sha256}',to_jsonb(candidate_revision),false)
 OR (SELECT count(*) FROM mission_public_owner.mission_content_admissions_v1 c
     WHERE c.engine_release_sha256=candidate_revision) IS DISTINCT FROM 2
 OR (SELECT count(*) FROM mission_public_owner.mission_content_admissions_v1 old
   JOIN mission_public_owner.mission_content_admissions_v1 new ON new.engine_release_sha256=candidate_revision
    AND new.mission_id=old.mission_id AND new.config_version=old.config_version
    AND new.publication_request=old.publication_request
   WHERE old.engine_release_sha256=parent_revision
    AND new.request_key=extensions.uuid_generate_v5(old.request_key,candidate_revision||':catalogo-compatible-adoption')
    AND new.payload-ARRAY['request_key','engine_release_sha256','created_at']
     =old.payload-ARRAY['request_key','engine_release_sha256','created_at']) IS DISTINCT FROM 2
 THEN RAISE EXCEPTION 'LAND_R2_FINAL_MISSIONS_PARTY_ROOT_OR_SEAL'; END IF;
 PERFORM clan_innata_private.runtime_release_assert();

 resources_after:=jsonb_build_object(
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
'combat_v2_staff_nb_internal.gate', (SELECT public.combat_v2_sha256(to_jsonb(g)) FROM combat_v2_staff_nb_internal.gate g WHERE g.singleton));
 IF resources_before IS DISTINCT FROM resources_after THEN
  RAISE EXCEPTION 'LAND_R2_PROTECTED_STATE_DRIFT';
 END IF;

 after_business:=jsonb_build_object(
  'admission_row_sha256',(SELECT public.combat_v2_sha256(to_jsonb(a)) FROM mission_public_owner.release_admissions_v1 a
   WHERE a.release_sha256=candidate_revision),
  'qualification_row_sha256',(SELECT public.combat_v2_sha256(to_jsonb(a)) FROM mission_public_owner.public_qualification_attestations_v1 a
   WHERE a.release_sha256=candidate_revision),
  'profile_row_sha256',(SELECT public.combat_v2_sha256(to_jsonb(p)) FROM mission_public_owner.engine_profile_events_v1 p
   WHERE p.engine_release_sha256=candidate_revision AND p.profile_key='mission-ai-authoring/1'),
  'party_row_sha256',(SELECT public.combat_v2_sha256(to_jsonb(p)) FROM mission_public_owner.party_launch_runtime_v1 p WHERE p.singleton),
  'content_rows_sha256',(SELECT public.combat_v2_sha256(jsonb_agg(to_jsonb(c) ORDER BY c.mission_id))
   FROM mission_public_owner.mission_content_admissions_v1 c WHERE c.engine_release_sha256=candidate_revision));
 PERFORM set_config('app.staff_land_r2_entry_result',jsonb_build_object(
  'schema_version','staff-land-r2-root-apply-receipt/2','mode',mode,'binding_sha256',bound_sha,
  'source_subject_sha256',binding->>'source_subject_sha256','projection_sha256',binding->>'projection_sha256',
  'review_ref',review_record->>'ref','previous_root_sha256',parent_revision,'previous_row_sha256',parent_row_sha,
  'parent',parent_expected,
  'active',after_business||jsonb_build_object('root_sha256',candidate_revision,'row_sha256',public.combat_v2_sha256(to_jsonb(rr_after))),
  'client_sha256',candidate_client,'root_bytes',octet_length(candidate_text),'git_commit',candidate_commit,
  'previous_git_commit',predecessor_commit,'publication_receipt_sha256',publication->>'publication_receipt_sha256',
  'aborted_release_sha256',aborted_revision,'abort_evidence_sha256',git_advance->>'evidence_sha256',
  'two_mission_admissions',true,'party_flags_preserved',true,'e52_common_verme',true,
  'protected_state_sha256',public.combat_v2_sha256(resources_after),'runtime_staff','NOT_RUN','provider_calls',0)::text,true);
END;
$land_r2_root$;

SELECT current_setting('app.staff_land_r2_entry_result',true)::jsonb AS release_receipt;
COMMIT;
