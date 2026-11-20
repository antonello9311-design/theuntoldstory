BEGIN;
SET LOCAL search_path='';
SET LOCAL lock_timeout='2s';
DO $pill_pre$
#variable_conflict error
DECLARE 
 rr mission_factory_owner.editor_release_readiness%ROWTYPE;
 prior_release mission_public_owner.release_admissions_v1%ROWTYPE;
 prior_qualification mission_public_owner.public_qualification_attestations_v1%ROWTYPE;
 runtime_before jsonb; review jsonb; root_text text; candidate_root jsonb; resources_before jsonb;
 db_sha text; config_sha text; new_root_sha text; old_root_sha text; old_row_sha text;
 bindings jsonb; qualification jsonb; content_payload jsonb; content_request uuid;
 content_row mission_public_owner.mission_content_admissions_v1%ROWTYPE; profile_row record;
 params jsonb; affected integer;
 namespace_uuid constant uuid:='5d20915b-9e97-5eca-8851-fd9f7f4c842a';
 generic_ezbr constant text:='9a6889802cfa17c99a556538cccd4ad7ef75274d32adccbc192c23d257aa3e76';
BEGIN
 review:=$pill_review${"ref":"PILL-R3-CHECK-INSTALL","sha256":"710671cc2ff00b1c51fb02a12c9d5e8f91532be288a8a917e0b52589d546354e","P0":0,"P1":0,"P2":0}$pill_review$::jsonb;
 IF NOT mission_factory_owner.keys_exact_v2(review,ARRAY['ref','sha256','P0','P1','P2'])
    OR coalesce(review->>'ref','')!~'^[A-Za-z0-9_.#-]{1,40}$'
    OR coalesce(review->>'sha256','')!~'^[a-f0-9]{64}$'
    OR review->'P0' IS DISTINCT FROM '0'::jsonb
    OR review->'P1' IS DISTINCT FROM '0'::jsonb
    OR review->'P2' IS DISTINCT FROM '0'::jsonb THEN RAISE EXCEPTION 'PILL_INDEPENDENT_REVIEW_REQUIRED'; END IF;
 
 IF current_user<>'postgres' OR session_user<>'postgres' OR auth.uid() IS NOT NULL
    OR (SELECT rolbypassrls FROM pg_roles WHERE rolname='postgres') IS DISTINCT FROM true
 THEN RAISE EXCEPTION 'PILL_OPERATION_ROLE_REQUIRED'; END IF;
 IF NOT pg_try_advisory_xact_lock(hashtextextended('C1266:GENERIC-AI:AVAILABILITY',0))
 THEN RAISE EXCEPTION 'PILL_AVAILABILITY_BUSY'; END IF;
 SELECT * INTO STRICT rr FROM mission_factory_owner.editor_release_readiness WHERE singleton FOR UPDATE NOWAIT;
 LOCK TABLE public.master_v2_sessions,public.combat_v2_sessions,combat_consumer_private.invitations,
            mission_public_owner.party_launch_runtime_v1 IN SHARE ROW EXCLUSIVE MODE NOWAIT;
 IF EXISTS(SELECT 1 FROM public.combat_v2_sessions WHERE closed_at IS NULL AND state IN ('preparazione','in_corso','sospeso'))
    OR EXISTS(SELECT 1 FROM public.master_v2_sessions WHERE closed_at IS NULL AND stato NOT IN ('chiusa','annullata'))
    OR EXISTS(SELECT 1 FROM combat_consumer_private.invitations
              WHERE state='pending' AND location_id='0b85f354-9cdb-47e1-baf9-3d266bb7e06b')
    OR EXISTS(SELECT 1 FROM clan_aburame_private.sfera_sources_v1 WHERE state IN ('reserved','active'))
 THEN RAISE EXCEPTION 'PILL_QUIESCENCE_REQUIRED'; END IF;
 IF rr.scope IS DISTINCT FROM 'staff' OR rr.state IS DISTINCT FROM 'enabled'
    OR NOT rr.staff_guards_verified OR NOT rr.published_assets_verified
    OR rr.revision_sha256 IS DISTINCT FROM rr.observed_revision_sha256
    OR encode(extensions.digest(convert_to(rr.canonical_preimage,'UTF8'),'sha256'),'hex') IS DISTINCT FROM rr.revision_sha256
    OR NOT clan_innata_private.catalogo_eligibility_release_v1()
 THEN RAISE EXCEPTION 'PILL_PARENT_RELEASE_UNQUALIFIED'; END IF;
 PERFORM clan_innata_private.runtime_release_assert();
 IF rr.revision_sha256 IS DISTINCT FROM '799e64f09637b5a7d331c3faf931ccab0c114cf33565c78b1cb40feefec82967'
   OR public.combat_v2_sha256(to_jsonb(rr)) IS DISTINCT FROM 'c9fbedb4c16ffb8fca6e31b6f6c4d2792fe72131c6f7d8bc6c5ccf7d7ab55b8c'
   OR to_regclass('combat_panel_private.chakra_pill_staff_gate_v1') IS NOT NULL
   OR to_regclass('combat_panel_private.chakra_pill_staff_uses_v1') IS NOT NULL
   OR to_regprocedure('combat_panel_private.chakra_pill_staff_commit_v1(jsonb)') IS NOT NULL
   OR (SELECT public.combat_v2_sha256(to_jsonb(i)) FROM public.items i
       WHERE i.id='916d3fab-ba73-4cdb-99ea-7da14a03c284') IS DISTINCT FROM 'c27fe14a885c5426746f6092b2db60e72df7fcee4480cd395aa7bade8888ff6c'
 THEN RAISE EXCEPTION 'PILL_EXACT_PARENT_OR_ITEM_REQUIRED'; END IF;
 IF EXISTS(SELECT 1 FROM jsonb_to_recordset('[{"acl":"{postgres=X/postgres}","ddl_md5":"6273f7d573951ae327a062c9d2f37099","ddl_sha256":"50e37d3c5d1ec147b55c576ba33d3565bbf7b1d0dab143d46f11a92fba61dd10","oid":"44940","owner":"postgres","sig":"combat_panel_private.master_options(uuid,uuid,bigint)","source_md5":"c3ae5fff837af5db1779970e73a414bd"},{"acl":"{postgres=X/postgres}","ddl_md5":"46424781b6fd6d34a0415090df6703f1","ddl_sha256":"fd38e02203a115949f47babb317ac999fd1af3fd3da1379b423d718baa7fb99b","oid":"44669","owner":"postgres","sig":"combat_panel_private.ordinary_options(uuid,uuid,bigint)","source_md5":"e1e6cd169797dc97d13aee366489d338"},{"acl":"{postgres=X/postgres,authenticated=X/postgres}","ddl_md5":"274c9e4d68f91524e6a5f8904beea48e","ddl_sha256":"bd6c5f84f3858f716e8578b856b226e4674fa8acc99493db4c9aa8589825bc23","oid":"44808","owner":"postgres","sig":"public.combat_panel_commit_v1(jsonb)","source_md5":"0b5a0ca3366bb6a302fcdfcddd306f48"},{"acl":"{postgres=X/postgres}","ddl_md5":"711a1b58f810c00651d816cc8147e33b","ddl_sha256":"89f41ba5949a9f4e48d34e978657f033da6f8c047513a371a8622639ca982617","oid":"684829","owner":"postgres","sig":"clan_innata_private.catalogo_eligibility_release_v1()","source_md5":"84a7a8b6bdbbd5c8e33144d93444eec9"}]'::jsonb)
   AS e(sig text, oid text, owner text, acl text, source_md5 text, ddl_sha256 text)
   LEFT JOIN pg_proc p ON p.oid=to_regprocedure(e.sig)
   WHERE p.oid::text IS DISTINCT FROM e.oid OR p.proowner::regrole::text IS DISTINCT FROM e.owner
      OR p.proacl::text IS DISTINCT FROM e.acl OR md5(p.prosrc) IS DISTINCT FROM e.source_md5
      OR encode(extensions.digest(convert_to(pg_get_functiondef(p.oid),'UTF8'),'sha256'),'hex') IS DISTINCT FROM e.ddl_sha256)
   THEN RAISE EXCEPTION 'PILL_BEFORE_FUNCTION_DRIFT'; END IF;
 SELECT * INTO STRICT prior_release FROM mission_public_owner.release_admissions_v1
 WHERE release_sha256=rr.revision_sha256 FOR SHARE;
 SELECT * INTO STRICT prior_qualification FROM mission_public_owner.public_qualification_attestations_v1
 WHERE release_sha256=rr.revision_sha256 FOR SHARE;
 SELECT to_jsonb(x) INTO STRICT runtime_before FROM mission_public_owner.party_launch_runtime_v1 x WHERE singleton FOR UPDATE;
 IF prior_release.edge_sha256 IS DISTINCT FROM generic_ezbr
 OR public.combat_v2_sha256(prior_qualification.payload->'capabilities') IS DISTINCT FROM '49fe134f561273f28e8071b63c45886341371b67d028f06e6b7d8f8d4108e817'
 OR runtime_before IS DISTINCT FROM jsonb_set('{"public_enabled":true,"release_sha256":"799e64f09637b5a7d331c3faf931ccab0c114cf33565c78b1cb40feefec82967","singleton":true,"staff_enabled":true}'::jsonb,'{release_sha256}',to_jsonb(rr.revision_sha256),false)
 OR (SELECT count(*) FROM mission_public_owner.mission_content_admissions_v1 c
   WHERE c.engine_release_sha256=rr.revision_sha256 AND mission_public_owner.content_admission_v1(c.mission_id,rr.revision_sha256,c.publication_request,true) IS NOT NULL) IS DISTINCT FROM 2
 OR (SELECT count(DISTINCT profile_key) FROM mission_public_owner.engine_profile_events_v1
     WHERE engine_release_sha256=rr.revision_sha256) IS DISTINCT FROM 1
 
  OR public.combat_v2_sha256(to_jsonb(prior_release)) IS DISTINCT FROM 'e2ae6fdf1e7e3a72b3f1fdc76cc063ec607bb5ca9e0d96f6909dfdda9bdf7942'
  OR public.combat_v2_sha256(to_jsonb(prior_qualification)) IS DISTINCT FROM 'eb08ac35bfeab131ded260da2d80ed2633b7106cd98a5b47840cb57c9b57b343'
  OR (SELECT public.combat_v2_sha256(jsonb_agg(to_jsonb(c) ORDER BY c.mission_id,c.request_key))
    FROM mission_public_owner.mission_content_admissions_v1 c WHERE c.engine_release_sha256=rr.revision_sha256)
    IS DISTINCT FROM 'a01dbcdf8d7c79b9419110c19f1c73f21efa08fd71df1f179126540f50442cec'
  OR (SELECT public.combat_v2_sha256(jsonb_agg(to_jsonb(p) ORDER BY p.profile_key)) FROM (
    SELECT DISTINCT ON (z.profile_key) * FROM mission_public_owner.engine_profile_events_v1 z
    WHERE z.engine_release_sha256=rr.revision_sha256 ORDER BY z.profile_key,z.control_version DESC) p)
    IS DISTINCT FROM '1efc7804236a53fd3b2a42c7843f439196433e35b085d304ce5eef49486fff88'

 OR mission_public_owner.engine_qualification_v1(rr.revision_sha256,true) IS NULL
 THEN RAISE EXCEPTION 'PILL_PARENT_MISSION_BOUNDARY'; END IF;
 
WITH p AS MATERIALIZED (
 SELECT r.revision_sha256 AS root_sha,r.canonical_preimage::jsonb AS j
 FROM mission_factory_owner.editor_release_readiness r WHERE r.singleton AND r.revision_sha256='799e64f09637b5a7d331c3faf931ccab0c114cf33565c78b1cb40feefec82967' AND public.combat_v2_sha256(to_jsonb(r))='c9fbedb4c16ffb8fca6e31b6f6c4d2792fe72131c6f7d8bc6c5ccf7d7ab55b8c' AND r.canonical_preimage::jsonb#>'{db_core,pill_staff}' IS NULL AND r.canonical_preimage::jsonb#>'{config,pill_staff}' IS NULL
), peer_rows AS MATERIALIZED (
 SELECT p.oid::regprocedure::text AS sig,
 jsonb_build_object('signature',p.oid::regprocedure::text,
  'source_md5',md5(p.prosrc),'ddl_md5',md5(pg_get_functiondef(p.oid)),
  'owner',pg_get_userbyid(p.proowner),'secdef',p.prosecdef,'config',p.proconfig,
  'acl',p.proacl::text,'volatility',p.provolatile::text) AS metadata
 FROM pg_proc p WHERE p.oid IN ('combat_panel_private.round_options_authoritative(uuid,uuid)'::regprocedure,'public.combat_v2_substitution_options_v1(uuid)'::regprocedure,'public.combat_v2_substitution_round_offers_v1(uuid,uuid)'::regprocedure,'public.combat_v2_substitution_select_v1(uuid,uuid)'::regprocedure,'clan_innata_private.catalogo_eligibility_release_v1()'::regprocedure,'combat_panel_private.publish_master_declaration(uuid,text)'::regprocedure)
), peer AS MATERIALIZED (
 SELECT count(*) AS n,public.combat_v2_sha256(jsonb_agg(
      CASE WHEN sig='clan_innata_private.catalogo_eligibility_release_v1()'
      THEN metadata||jsonb_build_object('source_md5','0b45f09f8f4d1257fb50461bde8a7c11',
                                         'ddl_md5','385cfe6490299ce6694d31d307acf36d')
      ELSE metadata END ORDER BY sig)) AS digest
 FROM peer_rows
), patched AS MATERIALIZED (
 SELECT p.*,peer.digest AS peer_sha,jsonb_set(jsonb_set(jsonb_set(jsonb_set(jsonb_set(jsonb_set(jsonb_set(jsonb_set(jsonb_set(jsonb_set(jsonb_set(jsonb_set(jsonb_set(jsonb_set(jsonb_set(jsonb_set(jsonb_set(jsonb_set(jsonb_set(p.j,'{db_core,pill_staff}',to_jsonb('cf9238856c043a3e4cb20890293af8dc3be58e751141589c04c54bd7ca147c45'::text),true),'{db_core,catalogo_eligibility_compat,shared_manifest_sha256}',to_jsonb('9720e93192c9f54839ecd08e02948b012efcd69c653ad4a3227cbaa811257a25'::text),false),'{db_core,catalogo_eligibility_compat,functions}','[{"acl":"{postgres=X/postgres}","config":["search_path=\"\""],"ddl_md5":"385cfe6490299ce6694d31d307acf36d","owner":"postgres","secdef":true,"signature":"clan_innata_private.catalogo_eligibility_release_v1()","source_md5":"0b45f09f8f4d1257fb50461bde8a7c11","volatility":"s"},{"acl":"{postgres=X/postgres}","config":["search_path=pg_catalog, public, clan_innata_private"],"ddl_md5":"c853342118edc3e2d886aef09661da1b","owner":"postgres","secdef":true,"signature":"clan_innata_private.eligibility_release_assert()","source_md5":"d12a616a859cd2b497004d0f17395437","volatility":"s"}]'::jsonb,false),'{db_core,catalogo_eligibility_compat,functions_manifest_sha256}',to_jsonb(public.combat_v2_sha256('[{"acl":"{postgres=X/postgres}","config":["search_path=\"\""],"ddl_md5":"385cfe6490299ce6694d31d307acf36d","owner":"postgres","secdef":true,"signature":"clan_innata_private.catalogo_eligibility_release_v1()","source_md5":"0b45f09f8f4d1257fb50461bde8a7c11","volatility":"s"},{"acl":"{postgres=X/postgres}","config":["search_path=pg_catalog, public, clan_innata_private"],"ddl_md5":"c853342118edc3e2d886aef09661da1b","owner":"postgres","secdef":true,"signature":"clan_innata_private.eligibility_release_assert()","source_md5":"d12a616a859cd2b497004d0f17395437","volatility":"s"}]'::jsonb)),false),'{db_core,catalogo_eligibility_compat,helper_source_md5}',to_jsonb('0b45f09f8f4d1257fb50461bde8a7c11'::text),false),'{db_core,cure_command_amendment,shared_manifest_sha256}',to_jsonb('9720e93192c9f54839ecd08e02948b012efcd69c653ad4a3227cbaa811257a25'::text),false),'{db_core,cure_command_amendment,helper_source_md5}',to_jsonb('0b45f09f8f4d1257fb50461bde8a7c11'::text),false),'{db_core,cure_command_amendment,functions_manifest_sha256}',to_jsonb(peer.digest),false),'{config,pill_staff}',to_jsonb('cf9238856c043a3e4cb20890293af8dc3be58e751141589c04c54bd7ca147c45'::text),true),'{config,catalogo_eligibility_compat,shared_manifest_sha256}',to_jsonb('9720e93192c9f54839ecd08e02948b012efcd69c653ad4a3227cbaa811257a25'::text),false),'{config,catalogo_eligibility_compat,functions}','[{"acl":"{postgres=X/postgres}","config":["search_path=\"\""],"ddl_md5":"385cfe6490299ce6694d31d307acf36d","owner":"postgres","secdef":true,"signature":"clan_innata_private.catalogo_eligibility_release_v1()","source_md5":"0b45f09f8f4d1257fb50461bde8a7c11","volatility":"s"},{"acl":"{postgres=X/postgres}","config":["search_path=pg_catalog, public, clan_innata_private"],"ddl_md5":"c853342118edc3e2d886aef09661da1b","owner":"postgres","secdef":true,"signature":"clan_innata_private.eligibility_release_assert()","source_md5":"d12a616a859cd2b497004d0f17395437","volatility":"s"}]'::jsonb,false),'{config,catalogo_eligibility_compat,functions_manifest_sha256}',to_jsonb(public.combat_v2_sha256('[{"acl":"{postgres=X/postgres}","config":["search_path=\"\""],"ddl_md5":"385cfe6490299ce6694d31d307acf36d","owner":"postgres","secdef":true,"signature":"clan_innata_private.catalogo_eligibility_release_v1()","source_md5":"0b45f09f8f4d1257fb50461bde8a7c11","volatility":"s"},{"acl":"{postgres=X/postgres}","config":["search_path=pg_catalog, public, clan_innata_private"],"ddl_md5":"c853342118edc3e2d886aef09661da1b","owner":"postgres","secdef":true,"signature":"clan_innata_private.eligibility_release_assert()","source_md5":"d12a616a859cd2b497004d0f17395437","volatility":"s"}]'::jsonb)),false),'{config,catalogo_eligibility_compat,helper_source_md5}',to_jsonb('0b45f09f8f4d1257fb50461bde8a7c11'::text),false),'{config,cure_command_amendment,shared_manifest_sha256}',to_jsonb('9720e93192c9f54839ecd08e02948b012efcd69c653ad4a3227cbaa811257a25'::text),false),'{config,cure_command_amendment,helper_source_md5}',to_jsonb('0b45f09f8f4d1257fb50461bde8a7c11'::text),false),'{config,cure_command_amendment,functions_manifest_sha256}',to_jsonb(peer.digest),false),'{db_core,catalogo_families,2}','["5b8cc87dc91085b066f32e32ca70ca5d72d3643d337a6531777390e7749fc98d","329838b340bb6a92e56253c5f3980d9df6623ac0ae2add83082b11f078160bd7","fd740654e1f3a83eb84c5634bd8da7f6895022bf2ee200deca3032ebfc83f78e"]'::jsonb,false),'{db_core,all_function_headers,228,source_md5}',to_jsonb('ad3cec069a1a0c5ab4a4a804de12bbec'::text),false),'{db_core,all_function_headers,228,ddl_md5}',to_jsonb('19c0226969fc069225a14c65a5d563e9'::text),false) AS stage_doc
 FROM p CROSS JOIN peer WHERE peer.n=6
 AND p.j#>>'{db_core,all_function_headers,228,oid}'='44940'
 AND p.j#>>'{db_core,sfera_staff}'='d2f38943c31031ee0fa051e57add33095908eed0806382d93984fb44d111a2eb'
 AND p.j#>>'{db_core,velo_staff}'='35d754465f1c19509822e9728ade3e23c3d2aefe63f441aff01908e774dfcef6'
), mirrors AS MATERIALIZED (
 SELECT *,jsonb_set(stage_doc,'{config,catalogo_families}',
               to_jsonb(public.combat_v2_sha256(stage_doc#>'{db_core,catalogo_families}')),false) AS parts
 FROM patched
), digests AS MATERIALIZED (
 SELECT *,public.combat_v2_sha256((parts->'db_core')-'sha256') AS db_sha,
          public.combat_v2_sha256((parts->'config')-'sha256') AS config_sha
 FROM mirrors
), identities AS MATERIALIZED (
 SELECT d.*,public.combat_v2_sha256(jsonb_build_object(
  'contract','staff-chakra-pill/1','mode','staff','parent',d.root_sha,
  'prior_code_identity',d.j#>'{contract,code_identity_sha256}','leaf','cf9238856c043a3e4cb20890293af8dc3be58e751141589c04c54bd7ca147c45',
  'db',d.db_sha,'config',d.config_sha,'edge',d.j->'edge_bundles')) AS code_sha
 FROM digests d
), combined AS MATERIALIZED (
 SELECT i.*,jsonb_set(jsonb_set(jsonb_set(jsonb_set(i.parts,'{db_core,sha256}',to_jsonb(i.db_sha),false),
  '{config,sha256}',to_jsonb(i.config_sha),false),'{contract,code_identity_sha256}',to_jsonb(i.code_sha),false),
  '{recovery,semantic_identity_sha256}',to_jsonb(i.code_sha),false) AS root_document
 FROM identities i
), candidate AS MATERIALIZED (
 SELECT *,regexp_replace(root_document::text,$rx$("(?:[^"\\]|\\.)*")|[[:space:]]+$rx$,$b$\1$b$,'g') AS root_text FROM combined
)

 SELECT c.root_text INTO STRICT root_text FROM candidate c
 WHERE c.root_text::jsonb=c.root_document AND octet_length(c.root_text)<=524288;
 IF encode(extensions.digest(convert_to(root_text,'UTF8'),'sha256'),'hex') IS DISTINCT FROM 'de34836ca073cda7dcf5d5920ff39d131d0da200a4100ac7589fea6f33663c3f'
 THEN RAISE EXCEPTION 'PILL_PROJECTED_ACTIVE_ROOT_DRIFT'; END IF;
 PERFORM set_config('app.pill_release_root',root_text,true);
 PERFORM set_config('app.pill_release_review',review::text,true);
 PERFORM set_config('app.pill_release_resources',jsonb_build_object(
'characters', (SELECT public.combat_v2_sha256(coalesce(jsonb_agg(to_jsonb(row_data) ORDER BY to_jsonb(row_data)::text),'[]'::jsonb)) FROM public.characters row_data WHERE row_data.id IN ('2a877f02-4993-4e65-9172-7d29f08c5b86'::uuid,'6bceee99-974f-426b-8d92-38b43b4a4267'::uuid)),
'character_inventory', (SELECT public.combat_v2_sha256(coalesce(jsonb_agg(to_jsonb(row_data) ORDER BY to_jsonb(row_data)::text),'[]'::jsonb)) FROM public.character_inventory row_data WHERE row_data.character_id IN ('2a877f02-4993-4e65-9172-7d29f08c5b86'::uuid,'6bceee99-974f-426b-8d92-38b43b4a4267'::uuid)),
'character_equipment', (SELECT public.combat_v2_sha256(coalesce(jsonb_agg(to_jsonb(row_data) ORDER BY to_jsonb(row_data)::text),'[]'::jsonb)) FROM public.character_equipment row_data WHERE row_data.character_id IN ('2a877f02-4993-4e65-9172-7d29f08c5b86'::uuid,'6bceee99-974f-426b-8d92-38b43b4a4267'::uuid)),
'character_abilities', (SELECT public.combat_v2_sha256(coalesce(jsonb_agg(to_jsonb(row_data) ORDER BY to_jsonb(row_data)::text),'[]'::jsonb)) FROM public.character_abilities row_data WHERE row_data.character_id IN ('2a877f02-4993-4e65-9172-7d29f08c5b86'::uuid,'6bceee99-974f-426b-8d92-38b43b4a4267'::uuid)),
'character_jutsu', (SELECT public.combat_v2_sha256(coalesce(jsonb_agg(to_jsonb(row_data) ORDER BY to_jsonb(row_data)::text),'[]'::jsonb)) FROM public.character_jutsu row_data JOIN public.characters owner ON owner.user_id=row_data.user_id WHERE owner.id IN ('2a877f02-4993-4e65-9172-7d29f08c5b86'::uuid,'6bceee99-974f-426b-8d92-38b43b4a4267'::uuid)))::text,true);
END;
$pill_pre$;
-- Componente isolato, con gate Staff spento fino al rilascio composto.
CREATE TABLE combat_panel_private.chakra_pill_staff_gate_v1 (
    singleton boolean PRIMARY KEY DEFAULT true CHECK (singleton),
    staff_enabled boolean NOT NULL DEFAULT false
);
ALTER TABLE combat_panel_private.chakra_pill_staff_gate_v1 ENABLE ROW LEVEL SECURITY;
REVOKE ALL ON TABLE combat_panel_private.chakra_pill_staff_gate_v1 FROM PUBLIC, anon, authenticated, service_role;
GRANT SELECT, INSERT, UPDATE ON TABLE combat_panel_private.chakra_pill_staff_gate_v1 TO postgres;
INSERT INTO combat_panel_private.chakra_pill_staff_gate_v1 (singleton) VALUES (true);

CREATE TABLE combat_panel_private.chakra_pill_staff_uses_v1 (
    session_id uuid NOT NULL REFERENCES public.combat_v2_sessions(id),
    round_id uuid NOT NULL REFERENCES public.combat_v2_rounds(id),
    actor_id uuid NOT NULL REFERENCES public.combat_v2_actors(id),
    personal_turn_id uuid NOT NULL,
    principal_user uuid NOT NULL,
    request_key uuid NOT NULL,
    receipt_id uuid NOT NULL UNIQUE,
    item_id uuid NOT NULL REFERENCES public.items(id)
        CHECK (item_id='916d3fab-ba73-4cdb-99ea-7da14a03c284'::uuid),
    chakra_before integer NOT NULL CHECK (chakra_before>=0),
    chakra_after integer NOT NULL,
    chakra_max integer NOT NULL,
    simulated boolean NOT NULL DEFAULT true CHECK (simulated),
    values_written boolean NOT NULL DEFAULT false CHECK (NOT values_written),
    charge_spent integer NOT NULL DEFAULT 1 CHECK (charge_spent=1),
    created_at timestamptz NOT NULL DEFAULT clock_timestamp(),
    PRIMARY KEY (session_id,actor_id),
    UNIQUE (principal_user,request_key),
    CHECK (chakra_before<chakra_after AND chakra_after<=chakra_max),
    CHECK (chakra_after-chakra_before=least(30,chakra_max-chakra_before))
);
ALTER TABLE combat_panel_private.chakra_pill_staff_uses_v1 ENABLE ROW LEVEL SECURITY;
REVOKE ALL ON TABLE combat_panel_private.chakra_pill_staff_uses_v1 FROM PUBLIC, anon, authenticated, service_role;
GRANT SELECT, INSERT ON TABLE combat_panel_private.chakra_pill_staff_uses_v1 TO postgres;

-- Le tre filiere rapide native trasmettono round o turno personale.
CREATE FUNCTION combat_panel_private.chakra_pill_rapid_claimed_v1(p_actor uuid, p_round uuid, p_turn uuid)
RETURNS boolean
LANGUAGE sql STABLE SECURITY DEFINER SET search_path TO ''
AS $function$
    SELECT EXISTS (
        SELECT 1 FROM combat_panel_private.chakra_pill_staff_uses_v1 use_row
        WHERE use_row.actor_id=p_actor
          AND ((p_round IS NOT NULL AND use_row.round_id=p_round)
               OR (p_turn IS NOT NULL AND use_row.personal_turn_id=p_turn))
    );
$function$;
REVOKE ALL ON FUNCTION combat_panel_private.chakra_pill_rapid_claimed_v1(uuid,uuid,uuid) FROM PUBLIC, anon, authenticated, service_role;
GRANT EXECUTE ON FUNCTION combat_panel_private.chakra_pill_rapid_claimed_v1(uuid,uuid,uuid) TO postgres;

CREATE FUNCTION combat_panel_private.chakra_pill_other_rapid_v1(p_actor uuid, p_round uuid, p_turn uuid)
RETURNS boolean
LANGUAGE sql STABLE SECURITY DEFINER SET search_path TO ''
AS $function$
    SELECT EXISTS (
        SELECT 1 FROM clan_innata_combat_private.combat_receipts receipt
        WHERE receipt.actor_id=p_actor AND receipt.round_id=p_round
          AND receipt.is_test AND receipt.operation IN ('activate','transport') AND receipt.chakra_spent>0
    ) OR EXISTS (
        SELECT 1 FROM clan_akimichi_private.common_form_commands_v1 form
        WHERE form.actor_id=p_actor AND form.form_kind='super' AND form.result->>'turn'=p_turn::text
    ) OR EXISTS (
        SELECT 1 FROM public.combat_v2_declarations declaration
        WHERE declaration.actor_id=p_actor AND declaration.round_id=p_round
          AND declaration.kind IN ('attacco','utilita')
          AND declaration.sanitized_intent#>>'{server_ability,usage}'='rapida'
    );
$function$;
REVOKE ALL ON FUNCTION combat_panel_private.chakra_pill_other_rapid_v1(uuid,uuid,uuid) FROM PUBLIC, anon, authenticated, service_role;
GRANT EXECUTE ON FUNCTION combat_panel_private.chakra_pill_other_rapid_v1(uuid,uuid,uuid) TO postgres;

CREATE FUNCTION combat_panel_private.chakra_pill_staff_rapid_guard_v1()
RETURNS trigger
LANGUAGE plpgsql SECURITY DEFINER SET search_path TO ''
AS $function$
DECLARE
    fact jsonb := to_jsonb(NEW);
    round_id uuid;
    personal_turn_id uuid;
BEGIN
    IF TG_TABLE_SCHEMA='clan_innata_combat_private' AND TG_TABLE_NAME='combat_receipts' THEN
        IF fact->>'operation' NOT IN ('activate','transport') OR (fact->>'chakra_spent')::integer<=0
           OR fact->'is_test' IS DISTINCT FROM 'true'::jsonb THEN RETURN NEW; END IF;
        round_id := (fact->>'round_id')::uuid;
    ELSIF TG_TABLE_SCHEMA='clan_akimichi_private' AND TG_TABLE_NAME='common_form_commands_v1' THEN
        IF fact->>'form_kind' IS DISTINCT FROM 'super' THEN RETURN NEW; END IF;
        personal_turn_id := (fact#>>'{result,turn}')::uuid;
    ELSIF TG_TABLE_SCHEMA='public' AND TG_TABLE_NAME='combat_v2_declarations' THEN
        IF fact->>'kind' NOT IN ('attacco','utilita')
           OR fact#>>'{sanitized_intent,server_ability,usage}' IS DISTINCT FROM 'rapida' THEN RETURN NEW; END IF;
        round_id := (fact->>'round_id')::uuid;
    ELSE
        RAISE EXCEPTION 'chakra_pill_unknown_rapid_producer';
    END IF;
    IF combat_panel_private.chakra_pill_rapid_claimed_v1((fact->>'actor_id')::uuid,round_id,personal_turn_id) THEN
        RAISE EXCEPTION 'chakra_pill_rapid_already_consumed' USING ERRCODE='55000';
    END IF;
    RETURN NEW;
END
$function$;
REVOKE ALL ON FUNCTION combat_panel_private.chakra_pill_staff_rapid_guard_v1() FROM PUBLIC, anon, authenticated, service_role;
GRANT EXECUTE ON FUNCTION combat_panel_private.chakra_pill_staff_rapid_guard_v1() TO postgres;

CREATE TRIGGER chakra_pill_rapid_guard_v1 BEFORE INSERT ON clan_innata_combat_private.combat_receipts
    FOR EACH ROW EXECUTE FUNCTION combat_panel_private.chakra_pill_staff_rapid_guard_v1();
CREATE TRIGGER chakra_pill_rapid_guard_v1 BEFORE INSERT ON clan_akimichi_private.common_form_commands_v1
    FOR EACH ROW EXECUTE FUNCTION combat_panel_private.chakra_pill_staff_rapid_guard_v1();
CREATE TRIGGER chakra_pill_rapid_guard_v1 BEFORE INSERT ON public.combat_v2_declarations
    FOR EACH ROW EXECUTE FUNCTION combat_panel_private.chakra_pill_staff_rapid_guard_v1();

CREATE FUNCTION combat_panel_private.chakra_pill_staff_turn_v1(p_actor uuid, p_round uuid)
RETURNS uuid
LANGUAGE plpgsql STABLE SECURITY DEFINER SET search_path TO ''
AS $function$
DECLARE
    actor public.combat_v2_actors%ROWTYPE;
    turn_context jsonb;
    turn_id uuid;
BEGIN
    IF auth.uid() IS NULL OR public.is_staff() IS NOT TRUE OR p_round IS NULL
       OR NOT EXISTS (
           SELECT 1 FROM combat_panel_private.chakra_pill_staff_gate_v1 gate
           WHERE gate.singleton AND gate.staff_enabled
       ) OR NOT combat_panel_private.cure_staff_execution_scope_v1(p_actor) THEN RETURN NULL; END IF;
    SELECT a.* INTO actor FROM public.combat_v2_actors a
    JOIN public.characters ch ON ch.id=a.character_id AND ch.user_id=a.controller_user
    JOIN public.combat_v2_sessions s ON s.id=a.session_id
    LEFT JOIN public.master_v2_sessions m ON m.id=s.master_session_id
    WHERE a.id=p_actor AND a.actor_kind='pg' AND a.companion_id IS NULL
      AND a.state='attivo' AND a.controller_user=auth.uid()
      AND combat_panel_private.uses_simulated_pools(s.id) IS TRUE
      AND public.combat_v2_values_written(s.id) IS FALSE
      AND (SELECT count(*) FROM public.combat_v2_actors roster WHERE roster.session_id=s.id)=2
      AND EXISTS (
          SELECT 1 FROM public.combat_v2_actors opponent
          JOIN public.characters owner ON owner.id=opponent.character_id AND owner.user_id=opponent.controller_user
          WHERE opponent.session_id=s.id AND opponent.id<>a.id AND opponent.actor_kind='pg'
            AND opponent.companion_id IS NULL AND opponent.character_id<>a.character_id
            AND opponent.controller_user<>a.controller_user AND opponent.team_key<>a.team_key
      )
      AND EXISTS (SELECT 1 FROM public.presence p WHERE p.user_id=a.controller_user AND p.location_id=s.location_id)
      AND (s.source_kind='ordinary' OR (m.stato='in_corso' AND m.quest_kind IS NULL
          AND NOT EXISTS (SELECT 1 FROM mission_generic_owner.run_bindings q WHERE q.master_session_id=m.id)
          AND NOT EXISTS (SELECT 1 FROM mission_narrative_internal.scene_runtime_v1 q
                          WHERE q.master_session_id=m.id AND q.is_active)
          AND NOT EXISTS (SELECT 1 FROM mission_factory_owner.quest_run_sources q WHERE q.session_id=m.id)));
    IF NOT FOUND THEN RETURN NULL; END IF;
    IF NOT (actor.mechanics_snapshot ?& ARRAY['vita','chakra','chakra_max'])
       OR jsonb_typeof(actor.mechanics_snapshot->'vita') IS DISTINCT FROM 'number'
       OR jsonb_typeof(actor.mechanics_snapshot->'chakra') IS DISTINCT FROM 'number'
       OR jsonb_typeof(actor.mechanics_snapshot->'chakra_max') IS DISTINCT FROM 'number' THEN RETURN NULL; END IF;
    IF (actor.mechanics_snapshot->>'vita')::numeric<=0
       OR (actor.mechanics_snapshot->>'chakra')::numeric<0
       OR (actor.mechanics_snapshot->>'chakra')::numeric>=(actor.mechanics_snapshot->>'chakra_max')::numeric
       OR (actor.mechanics_snapshot->>'chakra_max')::numeric>2147483647
       OR (actor.mechanics_snapshot->>'chakra')::numeric<>trunc((actor.mechanics_snapshot->>'chakra')::numeric)
       OR (actor.mechanics_snapshot->>'chakra_max')::numeric<>trunc((actor.mechanics_snapshot->>'chakra_max')::numeric)
       THEN RETURN NULL; END IF;
    IF NOT EXISTS (
        SELECT 1 FROM public.items i
        WHERE i.id='916d3fab-ba73-4cdb-99ea-7da14a03c284'::uuid
          AND i.is_active AND i.category='oggetto_generico' AND i.heal_chakra=30 AND i.heal_vita=0
    ) OR EXISTS (
        SELECT 1 FROM combat_panel_private.chakra_pill_staff_uses_v1 use_row
        WHERE use_row.session_id=actor.session_id AND use_row.actor_id=actor.id
    ) OR combat_panel_private.cure_turn_used_v1(p_round,actor.id) THEN RETURN NULL; END IF;
    turn_context := combat_panel_private.owner_turn_context(actor.id);
    IF turn_context->'can_move' IS DISTINCT FROM 'true'::jsonb
       OR turn_context->>'round_id' IS DISTINCT FROM p_round::text
       OR turn_context->>'session_id' IS DISTINCT FROM actor.session_id::text THEN RETURN NULL; END IF;
    IF turn_context->>'activity_kind'='master_v2'
       AND (NOT combat_panel_private.human_duel_round(p_round)
            OR combat_panel_private.human_duel_turn_allowed(p_round,actor.id) IS DISTINCT FROM true)
       THEN RETURN NULL; END IF;
    turn_id := (turn_context->>'personal_turn_id')::uuid;
    IF turn_id IS NULL OR combat_panel_private.chakra_pill_other_rapid_v1(actor.id,p_round,turn_id) THEN RETURN NULL; END IF;
    RETURN turn_id;
END
$function$;
REVOKE ALL ON FUNCTION combat_panel_private.chakra_pill_staff_turn_v1(uuid,uuid) FROM PUBLIC, anon, authenticated, service_role;
GRANT EXECUTE ON FUNCTION combat_panel_private.chakra_pill_staff_turn_v1(uuid,uuid) TO postgres;

CREATE FUNCTION combat_panel_private.chakra_pill_staff_offers_v1(p_context uuid, p_expected bigint)
RETURNS void
LANGUAGE plpgsql SECURITY DEFINER SET search_path TO ''
AS $function$
DECLARE
    context_row combat_panel_private.contexts%ROWTYPE;
    turn_id uuid;
BEGIN
    context_row := combat_panel_private.owned_context(p_context,p_expected);
    IF context_row.activity_kind NOT IN ('ordinary_v2','master_v2') OR context_row.command_actor_id IS NULL
       THEN RETURN; END IF;
    turn_id := combat_panel_private.chakra_pill_staff_turn_v1(context_row.command_actor_id,context_row.round_id);
    IF turn_id IS NULL OR EXISTS (
        SELECT 1 FROM combat_panel_private.offers offer
        WHERE offer.context_id=context_row.id AND offer.context_version=context_row.context_version
          AND offer.state='offered' AND offer.source_payload->>'dispatch'='staff_chakra_pill'
          AND offer.source_payload->>'personal_turn_id'=turn_id::text
    ) THEN RETURN; END IF;
    PERFORM combat_panel_private.create_offer(
        context_row.id,context_row.context_version,'control','control',
        'Usa Pillola del chakra · azione rapida',false,
        jsonb_build_object('adapter',context_row.activity_kind,'dispatch','staff_chakra_pill',
                           'contract','staff-chakra-pill/1','personal_turn_id',turn_id)
    );
END
$function$;
REVOKE ALL ON FUNCTION combat_panel_private.chakra_pill_staff_offers_v1(uuid,bigint) FROM PUBLIC, anon, authenticated, service_role;
GRANT EXECUTE ON FUNCTION combat_panel_private.chakra_pill_staff_offers_v1(uuid,bigint) TO postgres;

CREATE FUNCTION combat_panel_private.chakra_pill_hide_control_v1(p_source jsonb, p_round uuid, p_actor uuid)
RETURNS boolean
LANGUAGE sql STABLE SECURITY DEFINER SET search_path TO ''
AS $function$
    SELECT CASE WHEN NOT combat_panel_private.chakra_pill_rapid_claimed_v1(p_actor,p_round,NULL) THEN false
      ELSE coalesce(
           (p_source->>'dispatch'='velo_staff_control' AND p_source->>'velo_action'='activate')
        OR (p_source->>'dispatch'='akimichi_common_form' AND p_source->>'form'='super')
        OR p_source->>'hyuga_operation'='activate'
        OR p_source->>'sharingan_operation'='activate'
        OR p_source->>'inuzuka_operation'='activate'
        OR p_source->>'sabaku_operation' IN ('activate','transport')
        OR EXISTS (
            SELECT 1 FROM combat_consumer_private.offers native
            WHERE native.id=(p_source->>'source_offer_id')::uuid AND native.exchange_id=p_round
              AND native.operation='control'
              AND (
                   native.source_payload->>'hyuga_operation'='activate'
                OR native.source_payload->>'sharingan_operation'='activate'
                OR native.source_payload->>'inuzuka_operation'='activate'
                OR native.source_payload->>'sabaku_operation' IN ('activate','transport')
              )
        ),false)
    END;
$function$;
REVOKE ALL ON FUNCTION combat_panel_private.chakra_pill_hide_control_v1(jsonb,uuid,uuid) FROM PUBLIC, anon, authenticated, service_role;
GRANT EXECUTE ON FUNCTION combat_panel_private.chakra_pill_hide_control_v1(jsonb,uuid,uuid) TO postgres;

-- Appartiene al componente Pillola. Applicare solo nella futura integrazione firmata.
ALTER TABLE combat_panel_private.chakra_pill_staff_gate_v1 FORCE ROW LEVEL SECURITY;
ALTER TABLE combat_panel_private.chakra_pill_staff_uses_v1 FORCE ROW LEVEL SECURITY;

CREATE FUNCTION combat_panel_private.chakra_pill_staff_commit_v1(p_command jsonb)
RETURNS jsonb
LANGUAGE plpgsql SECURITY DEFINER SET search_path TO ''
AS $function$
#variable_conflict error
DECLARE
    principal uuid := auth.uid();
    command jsonb;
    request_id uuid;
    fingerprint text;
    previous combat_panel_private.request_receipts%ROWTYPE;
    offer_row combat_panel_private.offers%ROWTYPE;
    context_row combat_panel_private.contexts%ROWTYPE;
    actor_row public.combat_v2_actors%ROWTYPE;
    turn_id uuid;
    balance_before integer;
    balance_after integer;
    balance_maximum integer;
    receipt_id uuid := gen_random_uuid();
    envelope jsonb;
    display_label text;
    display_event jsonb;
    changed integer;
BEGIN
    IF principal IS NULL OR public.is_staff() IS NOT TRUE THEN
        RAISE EXCEPTION 'chakra_pill_staff_auth_required' USING ERRCODE='42501';
    END IF;
    command := combat_panel_private.validate_command(p_command);
    request_id := (command->>'request_key')::uuid;
    fingerprint := public.combat_v2_sha256(command);
    PERFORM pg_advisory_xact_lock(hashtextextended('panel-request:'||principal::text||':'||request_id::text,731));
    SELECT r.* INTO previous FROM combat_panel_private.request_receipts r
    WHERE r.principal_user=principal AND r.request_key=request_id;
    IF FOUND THEN
        IF previous.command_fingerprint IS DISTINCT FROM fingerprint THEN
            RAISE EXCEPTION 'panel_request_key_conflict' USING ERRCODE='22023';
        END IF;
        RETURN jsonb_set(previous.viewer_envelope,'{receipt,replayed}','true',false);
    END IF;
    IF command->>'operation' IS DISTINCT FROM 'control'
       OR command->'selected_option_ids' IS DISTINCT FROM '[]'::jsonb
       OR command->'inputs' IS DISTINCT FROM '[]'::jsonb
       OR command->'companion_id' IS DISTINCT FROM 'null'::jsonb
       OR command->>'companion_body' IS DISTINCT FROM ''
       OR trim(command->>'narrative_text') IS DISTINCT FROM '' THEN
        RAISE EXCEPTION 'chakra_pill_command_shape_invalid' USING ERRCODE='22023';
    END IF;
    SELECT o.* INTO offer_row FROM combat_panel_private.offers o
    WHERE o.id=(command->>'offer_id')::uuid AND o.principal_user=principal
      AND o.kind='control' AND o.operation='control' AND NOT o.requires_role
      AND o.source_payload->>'dispatch'='staff_chakra_pill'
      AND o.source_payload->>'contract'='staff-chakra-pill/1';
    IF NOT FOUND THEN RAISE EXCEPTION 'panel_offer_not_available' USING ERRCODE='42501'; END IF;
    SELECT c.* INTO STRICT context_row FROM combat_panel_private.contexts c
    WHERE c.id=offer_row.context_id AND c.principal_user=principal;
    IF context_row.round_id IS NULL OR context_row.activity_kind NOT IN ('ordinary_v2','master_v2')
       OR context_row.activity_kind IS DISTINCT FROM offer_row.source_payload->>'adapter'
       OR context_row.location_id IS DISTINCT FROM (command->>'location_id')::uuid
       OR context_row.activity_id IS DISTINCT FROM (command->>'activity_id')::uuid THEN
        RAISE EXCEPTION 'panel_activity_scope_invalid' USING ERRCODE='22023';
    END IF;

    PERFORM public.combat_v2_lock_round(context_row.round_id);
    PERFORM 1 FROM public.combat_v2_sessions s WHERE s.id=context_row.activity_id FOR UPDATE;
    PERFORM 1 FROM combat_consumer_private.activities act WHERE act.session_id=context_row.activity_id FOR UPDATE;
    IF context_row.activity_kind='ordinary_v2' THEN
        envelope := combat_panel_private.ordinary_projection(context_row.location_id,context_row.command_actor_id);
    ELSE
        envelope := combat_panel_private.master_projection(context_row.location_id,context_row.command_actor_id);
    END IF;
    IF envelope->>'status' IS DISTINCT FROM 'ready' THEN
        RAISE EXCEPTION 'panel_source_not_ready' USING ERRCODE='40001';
    END IF;
    context_row := combat_panel_private.owned_context(context_row.id,(command->>'context_version')::bigint);
    SELECT o.* INTO STRICT offer_row FROM combat_panel_private.offers o WHERE o.id=offer_row.id FOR UPDATE;
    IF offer_row.state IS DISTINCT FROM 'offered'
       OR offer_row.context_version IS DISTINCT FROM context_row.context_version
       OR offer_row.scene_version IS DISTINCT FROM context_row.scene_version
       OR offer_row.source_fingerprint IS DISTINCT FROM context_row.source_fingerprint
       OR offer_row.actor_id IS DISTINCT FROM context_row.command_actor_id THEN
        RAISE EXCEPTION 'panel_offer_not_available' USING ERRCODE='40001';
    END IF;
    SELECT a.* INTO STRICT actor_row FROM public.combat_v2_actors a
    WHERE a.id=offer_row.actor_id AND a.session_id=context_row.activity_id AND a.controller_user=principal
      AND a.actor_kind='pg' AND a.companion_id IS NULL AND a.state='attivo' FOR UPDATE;
    turn_id := combat_panel_private.chakra_pill_staff_turn_v1(actor_row.id,context_row.round_id);
    IF turn_id IS NULL OR turn_id::text IS DISTINCT FROM offer_row.source_payload->>'personal_turn_id' THEN
        RAISE EXCEPTION 'chakra_pill_offer_stale' USING ERRCODE='40001';
    END IF;

    balance_before := (actor_row.mechanics_snapshot->>'chakra')::integer;
    balance_maximum := (actor_row.mechanics_snapshot->>'chakra_max')::integer;
    balance_after := balance_before+least(30,balance_maximum-balance_before);
    INSERT INTO combat_panel_private.chakra_pill_staff_uses_v1(
        session_id,round_id,actor_id,personal_turn_id,principal_user,request_key,receipt_id,item_id,
        chakra_before,chakra_after,chakra_max
    ) VALUES (actor_row.session_id,context_row.round_id,actor_row.id,turn_id,principal,request_id,receipt_id,
        '916d3fab-ba73-4cdb-99ea-7da14a03c284'::uuid,balance_before,balance_after,balance_maximum
    );
    UPDATE public.combat_v2_actors a
    SET mechanics_snapshot=jsonb_set(a.mechanics_snapshot,'{chakra}',to_jsonb(balance_after),false)
    WHERE a.id=actor_row.id AND a.session_id=context_row.activity_id
      AND a.mechanics_snapshot IS NOT DISTINCT FROM actor_row.mechanics_snapshot
      AND public.combat_v2_values_written(a.session_id) IS FALSE
      AND combat_panel_private.uses_simulated_pools(a.session_id) IS TRUE;
    GET DIAGNOSTICS changed=ROW_COUNT;
    IF changed<>1 THEN RAISE EXCEPTION 'chakra_pill_simulated_pool_cas' USING ERRCODE='40001'; END IF;

    UPDATE combat_panel_private.offers o SET state='consumed',consumed_request_key=request_id
    WHERE o.id=offer_row.id AND o.state='offered';
    GET DIAGNOSTICS changed=ROW_COUNT;
    IF changed<>1 THEN RAISE EXCEPTION 'chakra_pill_offer_cas' USING ERRCODE='40001'; END IF;
    IF context_row.activity_kind='ordinary_v2' THEN
        UPDATE combat_consumer_private.activities act
        SET context_version=act.context_version+1,last_action_at=clock_timestamp()
        WHERE act.session_id=context_row.activity_id AND act.exchange_id=context_row.round_id
          AND act.policy_id='staff_test_no_persistent_resources_v1' AND act.phase='action'
          AND act.turn_actor_id=actor_row.id AND act.closed_at IS NULL;
        GET DIAGNOSTICS changed=ROW_COUNT;
        IF changed<>1 THEN RAISE EXCEPTION 'chakra_pill_ordinary_cas' USING ERRCODE='40001'; END IF;
    END IF;
    UPDATE combat_panel_private.contexts c
    SET context_version=c.context_version+1,updated_at=clock_timestamp()
    WHERE c.id=context_row.id AND c.context_version=context_row.context_version;
    GET DIAGNOSTICS changed=ROW_COUNT;
    IF changed<>1 THEN RAISE EXCEPTION 'chakra_pill_context_cas' USING ERRCODE='40001'; END IF;

    IF context_row.activity_kind='ordinary_v2' THEN
        envelope := combat_panel_private.ordinary_projection(context_row.location_id,actor_row.id);
    ELSE
        envelope := combat_panel_private.master_projection(context_row.location_id,actor_row.id);
    END IF;
    IF envelope->>'status' IS DISTINCT FROM 'ready' THEN RAISE EXCEPTION 'chakra_pill_envelope_invalid'; END IF;
    SELECT item->>'display_name' INTO STRICT display_label
    FROM jsonb_array_elements(envelope->'actors') AS viewer(item)
    WHERE item->>'actor_id'=actor_row.id::text;
    display_event := combat_consumer_private.validate_display_event(jsonb_build_object(
        'event_id',receipt_id,'event_kind','control_changed','actor_id',actor_row.id,
        'display_name',display_label,'label_version',context_row.context_version,
        'target_actor_id',NULL,'target_display_name',NULL,'target_label_version',NULL,
        'summary',format('Pillola del chakra: +%s chakra di prova. Una carica simulata consumata.',
                         balance_after-balance_before)
    ));
    envelope := jsonb_set(envelope,'{receipt}',jsonb_build_object(
        'receipt_id',receipt_id,'request_key',request_id,'operation','control','replayed',false,
        'activity_id',context_row.activity_id,'round_id',context_row.round_id,
        'context_version_before',offer_row.context_version,'context_version_after',envelope#>'{context,version}',
        'declaration_id',NULL,'report_id',NULL,'values_written',false,
        'display_events',jsonb_build_array(display_event)
    ));
    INSERT INTO combat_panel_private.request_receipts(principal_user,request_key,command_fingerprint,offer_id,event_id,viewer_envelope)
    VALUES (principal,request_id,fingerprint,offer_row.id,receipt_id,envelope);
    RETURN envelope;
END
$function$;
REVOKE ALL ON FUNCTION combat_panel_private.chakra_pill_staff_commit_v1(jsonb) FROM PUBLIC, anon, authenticated, service_role;
GRANT EXECUTE ON FUNCTION combat_panel_private.chakra_pill_staff_commit_v1(jsonb) TO postgres;

-- Comporre solo una volta, dopo i due componenti privati.
CREATE OR REPLACE FUNCTION combat_panel_private.master_options(p_location uuid, p_actor uuid, p_expected bigint)
 RETURNS jsonb
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO ''
AS $function$
DECLARE env jsonb; source jsonb; c combat_panel_private.contexts%ROWTYPE; rid uuid; offers jsonb;
BEGIN
 IF exam_regia_private.current_principal() IS NULL THEN RAISE EXCEPTION 'panel_authentication_required' USING ERRCODE='28000'; END IF;
 SELECT r.id INTO rid FROM public.master_v2_sessions m JOIN public.combat_v2_sessions s ON s.master_session_id=m.id
   JOIN public.combat_v2_rounds r ON r.session_id=s.id WHERE m.location_id=p_location
     AND m.stato NOT IN ('chiusa','annullata') AND s.state NOT IN ('chiuso','annullato') ORDER BY r.round_no DESC LIMIT 1;
 IF rid IS NOT NULL THEN PERFORM public.combat_v2_lock_round(rid);
 ELSE PERFORM 1 FROM public.locations WHERE id=p_location FOR UPDATE; END IF;
 env:=combat_panel_private.master_projection(p_location,p_actor);
 IF env#>>'{context,version}' IS DISTINCT FROM p_expected::text THEN
   RAISE EXCEPTION 'panel_context_stale' USING ERRCODE='40001'; END IF;
 SELECT * INTO STRICT c FROM combat_panel_private.contexts WHERE location_id=p_location AND principal_user=exam_regia_private.current_principal()
   AND command_actor_id IS NOT DISTINCT FROM (env#>>'{viewer,command_actor_id}')::uuid FOR UPDATE;
 -- Il controllo prepara Movimento senza revocare attacco e tecnica già offerti.
 IF NOT EXISTS(SELECT 1 FROM combat_panel_private.offers WHERE context_id=c.id AND context_version=c.context_version AND state='offered') THEN
   IF c.command_actor_id IS NOT NULL AND c.round_id IS NOT NULL THEN
     -- La versione richiesta e gia validata sotto lock del round.
     -- Upkeep e inizializzazione autorizzati precedono il catalogo delle azioni.
     PERFORM clan_sabaku_private.prepare_master_owner(c.command_actor_id);
     PERFORM combat_panel_private.prepare_master_companion(c.command_actor_id);
     source:=public.combat_v2_round_options(c.round_id,c.command_actor_id)->'data';
     -- Controllo is activated by master_control_offers. Its attack is only the attested Flow producer.
     -- Exclude exactly that identity from generic attacks; preserve every other native ability.
     source:=jsonb_set(source,'{abilities}',coalesce((SELECT jsonb_agg(value ORDER BY ordinal)
       FROM jsonb_array_elements(coalesce(source->'abilities','[]')) WITH ORDINALITY AS abilities(value,ordinal)
       WHERE NOT coalesce(value->>'source'='clan' AND value->>'id' IN ('001f907c-8f32-4758-8a16-ad1730e72c59','f5e9af24-70f1-49f6-a7ca-74f59256336e','b9195ceb-74de-4251-95af-fe5c1bdaf485','2f06b6f8-341f-472b-be04-ad48fcf2c412','0a15282f-d6b5-4ee3-ad52-7fac2525444d'),false)
       -- Byakugan is an innate control; native Master activation is produced separately.
       AND NOT(c.location_id='0b85f354-9cdb-47e1-baf9-3d266bb7e06b'::uuid
         AND coalesce(combat_panel_private.uses_simulated_pools(c.activity_id),false)
         AND EXISTS(SELECT 1 FROM clan_innata_narrative_private.byakugan_catalog_v1 byakugan
         JOIN public.clan_techniques technique ON technique.id=byakugan.technique_id AND technique.is_innata
         WHERE value->>'source'='clan' AND value->>'id'=byakugan.technique_id::text))),'[]'::jsonb));
     env:=combat_panel_private.master_projection(p_location,c.command_actor_id);
     SELECT * INTO STRICT c FROM combat_panel_private.contexts WHERE id=c.id
       AND principal_user=exam_regia_private.current_principal() FOR UPDATE;
     PERFORM set_config('application_name','TUS_PERF master_actor',true); RAISE WARNING 'TUS_PERF stage=master_actor_begin context=%',c.id; PERFORM combat_panel_private.master_actor_offers(c.id,c.context_version,env,source); RAISE WARNING 'TUS_PERF stage=master_actor_end context=%',c.id; PERFORM set_config('application_name','TUS_PERF after_actor',true);
     PERFORM clan_aburame_private.master_offers(c.id,c.context_version,env);
     PERFORM combat_panel_private.master_companion_bind_offers(c.id,c.context_version);
     PERFORM combat_panel_private.master_companion_control_offers(c.id,c.context_version,source); PERFORM set_config('application_name','TUS_PERF inuzuka_control',true); RAISE WARNING 'TUS_PERF stage=inuzuka_control_begin context=%',c.id; PERFORM clan_inuzuka_private.master_control_offers(c.id,c.context_version); RAISE WARNING 'TUS_PERF stage=inuzuka_control_end context=%',c.id; PERFORM set_config('application_name','TUS_PERF done',true);
   END IF;
   PERFORM clan_hoki_private.master_body_offer(c.id,c.context_version);
   PERFORM clan_akimichi_private.master_form_offers(c.id,c.context_version);
   PERFORM clan_sabaku_private.master_control_offers(c.id,c.context_version);
   PERFORM clan_hyuga_private.master_control_offers(c.id,c.context_version);
   PERFORM clan_innata_private.sharingan_master_control_offers(c.id,c.context_version);
   IF NOT exam_regia_private.is_bound(c.activity_id) THEN PERFORM combat_panel_private.master_admin_offers(c.id,c.context_version,public.master_v2_ui_state(p_location)->'data'); END IF;
 END IF;
 PERFORM combat_panel_private.master_movement_control_offers(c.id,c.context_version);
 PERFORM combat_panel_private.multiplication_offers(c.id,c.context_version,env);
 PERFORM combat_panel_private.immobilization_escape_offers(c.id,c.context_version,env);
 PERFORM combat_panel_private.nara_control_offers_v1(c.id,c.context_version,env);
 PERFORM combat_panel_private.cure_offers_v1(c.id,c.context_version,env);
 PERFORM clan_akimichi_private.common_panel_offers_v1(c.id,c.context_version,env);
 PERFORM clan_innata_combat_private.velo_control_offers_v1(c.id,c.context_version);
 PERFORM combat_panel_private.chakra_pill_staff_offers_v1(c.id,c.context_version);
 PERFORM clan_sabaku_private.clone_offers(c.id,c.context_version,env);
 PERFORM clan_sabaku_private.flow_master_offers(c.id,c.context_version,env);
 PERFORM clan_hyuga_private.rotation_panel_offers(c.id,c.context_version);
 PERFORM combat_panel_private.master_open_offers(c.id,c.context_version);
 PERFORM combat_v2_elemental_internal.suiton_master_options(c.id,c.context_version);
 PERFORM combat_v2_elemental_internal.scudo_master_options(c.id,c.context_version);
 PERFORM combat_v2_elemental_internal.other_master_options(c.id,c.context_version);
 IF EXISTS(SELECT 1 FROM public.combat_v2_actors a JOIN public.combat_v2_sessions s ON s.id=a.session_id
  JOIN public.master_v2_sessions master ON master.id=s.master_session_id AND master.owner_kind='ai_service'
  JOIN public.locations loc ON loc.id=master.location_id AND loc.id=p_location AND loc.is_test AND loc.is_active
  JOIN mission_narrative_internal.scene_runtime_v1 scene ON scene.master_session_id=master.id AND scene.is_active AND scene.mode='combat'
  WHERE a.id=c.command_actor_id AND a.actor_kind='pg' AND a.character_id IS NOT NULL
   AND a.controller_user=exam_regia_private.current_principal() AND s.id=c.activity_id AND NOT s.lesiva
   AND combat_panel_private.uses_simulated_pools(s.id) AND NOT public.combat_v2_values_written(s.id)) THEN
  UPDATE combat_panel_private.offers SET requires_role=true
   WHERE context_id=c.id AND context_version=c.context_version AND state='offered' AND kind='action'
    AND source_payload->>'kind'='passa' AND NOT requires_role;
 END IF;
   PERFORM combat_v2_genjutsu_internal.panel_options(c.id,c.context_version);
  PERFORM combat_panel_private.nara_adv_offers_v1(c.id,c.context_version,env);
 SELECT coalesce(jsonb_agg(combat_panel_private.offer_projection(id) ORDER BY created_at,id),'[]') INTO offers
   FROM combat_panel_private.offers WHERE context_id=c.id AND context_version=c.context_version AND state='offered'
     AND (kind<>'control' OR NOT combat_panel_private.chakra_pill_hide_control_v1(source_payload,c.round_id,c.command_actor_id));
 RETURN clan_aburame_private.consumer_projection(jsonb_set(combat_panel_private.attach_rating_offers(jsonb_set(env,'{offers}',offers),c.id),
   '{movement_explanations}',coalesce(combat_panel_private.movement_explanations(c.id,c.context_version),'null'::jsonb)));
END $function$;

CREATE OR REPLACE FUNCTION combat_panel_private.ordinary_options(p_location uuid, p_actor uuid, p_expected bigint)
 RETURNS jsonb
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO ''
AS $function$
DECLARE env jsonb; src jsonb; c combat_panel_private.contexts%ROWTYPE; rid uuid;
 item jsonb; companion_moves jsonb:='[]'; rendered jsonb; ignored uuid;
BEGIN
 -- Ordine coerente con il commit del motore: round/sessione prima del
 -- contesto del nuovo pannello. Non si blocca il POV prima delle risorse.
 SELECT exchange_id INTO rid FROM combat_consumer_private.activities
   WHERE location_id=p_location AND phase<>'closed' AND
    ((user_testroom_common_private.bound_context(p_location) IS NULL AND user_test_context_id IS NULL)
     OR session_id=user_testroom_common_private.bound_context(p_location));
 IF rid IS NOT NULL THEN PERFORM public.combat_v2_lock_round(rid);
 ELSE PERFORM 1 FROM public.locations WHERE id=p_location FOR UPDATE; END IF;
 PERFORM set_config('application_name','TUS_PERF ordinary_projection_initial',true); -- INUZUKA-ORDINARY-DIAG018
 env:=combat_panel_private.ordinary_projection(p_location,p_actor);
 PERFORM set_config('application_name','TUS_PERF ordinary_context_initial',true); -- INUZUKA-ORDINARY-DIAG018
 IF env->>'status' IS DISTINCT FROM 'ready' THEN RETURN env; END IF;
 SELECT * INTO STRICT c FROM combat_panel_private.contexts WHERE location_id=p_location
   AND principal_user=auth.uid() AND command_actor_id IS NOT DISTINCT FROM (env#>>'{viewer,command_actor_id}')::uuid;
 IF c.context_version IS DISTINCT FROM p_expected THEN
   RAISE EXCEPTION 'panel_context_stale' USING ERRCODE='40001'; END IF;
 IF NOT EXISTS(SELECT 1 FROM combat_panel_private.offers WHERE context_id=c.id
   AND context_version=c.context_version AND state='offered'
   AND source_payload->>'adapter'='ordinary_v2') THEN -- INUZUKA-ORDINARY-SOURCE-OFFER-GATE-20260922-010
 PERFORM set_config('application_name','TUS_PERF consumer_state',true); -- INUZUKA-ORDINARY-DIAG018
   src:=combat_panel_private.consumer_state_authoritative(p_location);
 PERFORM set_config('application_name','TUS_PERF consumer_options',true); -- INUZUKA-ORDINARY-DIAG018
   -- INUZUKA-EXACT-STAFF-DIRECT-CONSUMER-20260922-028
   IF p_location='0b85f354-9cdb-47e1-baf9-3d266bb7e06b'::uuid
    AND p_actor='c5865d83-3651-4815-a7e2-de484c3f5481'::uuid
    AND auth.uid()='15448f47-3b43-416f-a703-dbe7a74d36ce'::uuid
    AND c.activity_id='0e35db27-29a7-49fc-a496-12ae663edb77'::uuid
    AND c.round_id='fc5be64f-5023-4f7d-a2ce-89797ea09061'::uuid
    AND c.location_id=p_location AND c.command_actor_id=p_actor
    AND c.context_version=p_expected
    AND EXISTS(
      SELECT 1 FROM combat_consumer_private.activities qa_ctx
      JOIN public.combat_v2_actors qa ON qa.id=p_actor AND qa.session_id=qa_ctx.session_id
      JOIN public.characters pg ON pg.id=qa.character_id
      WHERE qa_ctx.session_id=c.activity_id AND qa_ctx.exchange_id=c.round_id
       AND qa_ctx.location_id=p_location AND qa_ctx.phase='action'
       AND qa_ctx.turn_actor_id=p_actor
       AND qa_ctx.policy_id='staff_test_no_persistent_resources_v1'
       AND qa.controller_user=auth.uid() AND qa.actor_kind='pg'
       AND qa.companion_id IS NULL AND qa.state='attivo'
       AND pg.id='2a877f02-4993-4e65-9172-7d29f08c5b86'::uuid
       AND pg.clan='Nessuno'
       AND NOT public.combat_v2_values_written(qa_ctx.session_id)
       AND (SELECT count(DISTINCT a->>'id') FROM jsonb_array_elements(
         CASE WHEN jsonb_typeof(qa.mechanics_snapshot->'abilities')='array'
          THEN qa.mechanics_snapshot->'abilities' ELSE '[]'::jsonb END) a
        WHERE a->>'source'='clan' AND a->>'id' IN(
         '6d7c0804-1ba9-4e49-8697-1a550f3608b2','b0748ef4-bea8-4d85-95a1-7d9db1b4381c',
         'b076a976-c75b-4b5a-8813-b0e8e2c3af03','c11ecd52-43cd-479b-8d5d-08187beba56e'))=4
       AND NOT EXISTS(SELECT 1 FROM jsonb_array_elements(
         CASE WHEN jsonb_typeof(qa.mechanics_snapshot->'abilities')='array'
          THEN qa.mechanics_snapshot->'abilities' ELSE '[]'::jsonb END) a
        WHERE a->>'source'='clan' AND (a->>'id' IS NULL OR a->>'id' NOT IN(
         '6d7c0804-1ba9-4e49-8697-1a550f3608b2','b0748ef4-bea8-4d85-95a1-7d9db1b4381c',
         'b076a976-c75b-4b5a-8813-b0e8e2c3af03','c11ecd52-43cd-479b-8d5d-08187beba56e')))
    ) THEN
     src:=clan_inuzuka_private.consumer_options(src);
   ELSE
     src:=combat_panel_private.consumer_options_authoritative(p_location,(src#>>'{context,version}')::bigint);
   END IF;
 PERFORM set_config('application_name','TUS_PERF consumer_ready',true); -- INUZUKA-ORDINARY-DIAG018
   IF src->>'status' IS DISTINCT FROM 'ready' THEN
     RAISE EXCEPTION 'panel_source_options_not_ready' USING ERRCODE='40001'; END IF;
   -- I producer gia rilasciati possono preparare il link iniziale. Riprendere
   -- la projection autorizzata e la nuova versione prima di importare offerte.
 PERFORM set_config('application_name','TUS_PERF ordinary_projection_refresh',true); -- INUZUKA-ORDINARY-DIAG018
 -- INUZUKA-EXACT-STAFF-SKIP-PROJECTION-REFRESH-20260922-026
 IF NOT (
   p_location='0b85f354-9cdb-47e1-baf9-3d266bb7e06b'::uuid
   AND p_actor='c5865d83-3651-4815-a7e2-de484c3f5481'::uuid
   AND auth.uid()='15448f47-3b43-416f-a703-dbe7a74d36ce'::uuid
   AND EXISTS(
     SELECT 1 FROM combat_consumer_private.activities qa_ctx
     JOIN public.combat_v2_actors qa ON qa.id=p_actor
     JOIN public.characters pg ON pg.id=qa.character_id
     WHERE qa_ctx.session_id='0e35db27-29a7-49fc-a496-12ae663edb77'::uuid
       AND qa_ctx.exchange_id='fc5be64f-5023-4f7d-a2ce-89797ea09061'::uuid
       AND qa_ctx.location_id=p_location
       AND qa_ctx.phase='action'
       AND qa_ctx.turn_actor_id=p_actor
       AND qa_ctx.policy_id='staff_test_no_persistent_resources_v1'
       AND qa.session_id=qa_ctx.session_id
       AND c.activity_id=qa_ctx.session_id
       AND c.round_id=qa_ctx.exchange_id
       AND c.location_id=qa_ctx.location_id
       AND c.command_actor_id=p_actor
       AND c.context_version=p_expected
       -- INUZUKA-EXACT-STAFF-CONTEXT-GUARD-20260922-027
       -- Il contesto e' gia vincolato lato server da c, qa_ctx, attore, utente,
       -- sessione, scambio, stanza Staff, versione e policy della fixture.
       AND qa.controller_user=auth.uid()
       AND qa.actor_kind='pg'
       AND qa.companion_id IS NULL
       AND qa.state='attivo'
       AND pg.id='2a877f02-4993-4e65-9172-7d29f08c5b86'::uuid
       AND pg.clan='Nessuno'
       AND NOT public.combat_v2_values_written(qa_ctx.session_id)
       AND (SELECT count(DISTINCT a->>'id') FROM jsonb_array_elements(
         CASE WHEN jsonb_typeof(qa.mechanics_snapshot->'abilities')='array' THEN qa.mechanics_snapshot->'abilities' ELSE '[]'::jsonb END) a
         WHERE a->>'source'='clan' AND a->>'id' IN (
           '6d7c0804-1ba9-4e49-8697-1a550f3608b2','b0748ef4-bea8-4d85-95a1-7d9db1b4381c',
           'b076a976-c75b-4b5a-8813-b0e8e2c3af03','c11ecd52-43cd-479b-8d5d-08187beba56e'))=4
       AND NOT EXISTS(SELECT 1 FROM jsonb_array_elements(
         CASE WHEN jsonb_typeof(qa.mechanics_snapshot->'abilities')='array' THEN qa.mechanics_snapshot->'abilities' ELSE '[]'::jsonb END) a
         WHERE a->>'source'='clan' AND (a->>'id' IS NULL OR a->>'id' NOT IN (
           '6d7c0804-1ba9-4e49-8697-1a550f3608b2','b0748ef4-bea8-4d85-95a1-7d9db1b4381c',
           'b076a976-c75b-4b5a-8813-b0e8e2c3af03','c11ecd52-43cd-479b-8d5d-08187beba56e')))
   )
 ) THEN
   env:=combat_panel_private.ordinary_projection(p_location,p_actor);
 END IF;
 PERFORM set_config('application_name','TUS_PERF import_prepare',true); -- INUZUKA-ORDINARY-DIAG018
   SELECT * INTO STRICT c FROM combat_panel_private.contexts WHERE location_id=p_location
     AND principal_user=auth.uid() AND command_actor_id IS NOT DISTINCT FROM (env#>>'{viewer,command_actor_id}')::uuid;
 PERFORM set_config('application_name','TUS_PERF import_offers',true); -- INUZUKA-ORDINARY-DIAG018
   FOR item IN SELECT value FROM jsonb_array_elements(src->'offers') LOOP
     IF jsonb_typeof(item->'companion_movement')='object' THEN
       companion_moves:=companion_moves||jsonb_build_array(item);
     ELSE
       ignored:=combat_panel_private.import_ordinary_offer(c.id,c.context_version,item,(src#>>'{context,version}')::bigint);
     END IF;
   END LOOP;
   IF jsonb_array_length(companion_moves)>0 THEN
     ignored:=combat_panel_private.import_companion_moves(c.id,c.context_version,companion_moves,(src#>>'{context,version}')::bigint);
   END IF;
 END IF;
 PERFORM set_config('application_name','TUS_PERF helpers_attack',true); -- INUZUKA-ORDINARY-DIAG018
 -- INUZUKA-STAFF-QA-SKIP-UNRELATED-HELPERS-20260922-022
 IF NOT (
   p_location='0b85f354-9cdb-47e1-baf9-3d266bb7e06b'::uuid
   AND p_actor='c5865d83-3651-4815-a7e2-de484c3f5481'::uuid
   AND auth.uid()='15448f47-3b43-416f-a703-dbe7a74d36ce'::uuid
   AND EXISTS(
     SELECT 1 FROM combat_consumer_private.activities qa_session
     JOIN public.combat_v2_actors qa_actor ON qa_actor.id=p_actor
     JOIN public.characters qa_character ON qa_character.id=qa_actor.character_id
     WHERE qa_session.location_id=p_location
       AND qa_session.session_id=c.activity_id
       AND qa_session.exchange_id=c.round_id
       AND qa_session.phase<>'closed'
       AND qa_session.turn_actor_id=p_actor
       AND qa_session.policy_id='staff_test_no_persistent_resources_v1'
       AND qa_actor.session_id=qa_session.session_id
       AND qa_actor.controller_user=auth.uid()
       AND qa_actor.actor_kind='pg'
       AND qa_actor.companion_id IS NULL
       AND qa_actor.state='attivo'
       AND qa_character.id='2a877f02-4993-4e65-9172-7d29f08c5b86'::uuid
       AND qa_character.clan='Nessuno'
       AND NOT public.combat_v2_values_written(qa_session.session_id)
   )
 ) THEN
 PERFORM combat_panel_private.multiplication_ordinary_attack_offers(c.id,c.context_version,env);
 PERFORM combat_v2_elemental_internal.suiton_ordinary_copy_offers(c.id,c.context_version,env);
 PERFORM combat_v2_elemental_internal.other_ordinary_copy_offers(c.id,c.context_version,env);
 IF c.location_id='0b85f354-9cdb-47e1-baf9-3d266bb7e06b'::uuid THEN PERFORM set_config('application_name','TUS_PERF helper_companion_attack',true); END IF; -- INUZUKA-DISPATCH-DIAG020
 PERFORM combat_panel_private.multiplication_companion_ordinary_offers(c.id,c.context_version,env);
 IF c.location_id='0b85f354-9cdb-47e1-baf9-3d266bb7e06b'::uuid THEN PERFORM set_config('application_name','TUS_PERF helper_multiplication',true); END IF; -- INUZUKA-DISPATCH-DIAG020
  -- INUZUKA-STAFF-QA-SKIP-UNRELATED-MULTIPLICATION-20260922-021
  IF NOT (
    p_location='0b85f354-9cdb-47e1-baf9-3d266bb7e06b'::uuid
    AND p_actor='c5865d83-3651-4815-a7e2-de484c3f5481'::uuid
    AND auth.uid()='15448f47-3b43-416f-a703-dbe7a74d36ce'::uuid
    AND EXISTS(
      SELECT 1
      FROM combat_consumer_private.activities qa_session
      JOIN public.combat_v2_actors qa_actor ON qa_actor.id=p_actor
      JOIN public.characters qa_character ON qa_character.id=qa_actor.character_id
      WHERE qa_session.location_id=p_location
        AND qa_session.session_id=c.activity_id
        AND qa_session.exchange_id=c.round_id
        AND qa_session.phase<>'closed'
        AND qa_session.turn_actor_id=p_actor
        AND qa_session.policy_id='staff_test_no_persistent_resources_v1'
        AND qa_actor.session_id=qa_session.session_id
        AND qa_actor.controller_user=auth.uid()
        AND qa_actor.actor_kind='pg'
        AND qa_actor.companion_id IS NULL
        AND qa_actor.state='attivo'
        AND qa_character.id='2a877f02-4993-4e65-9172-7d29f08c5b86'::uuid
        AND qa_character.clan='Nessuno'
        AND NOT public.combat_v2_values_written(qa_session.session_id)
    )
  ) THEN
    PERFORM combat_panel_private.multiplication_offers(c.id,c.context_version,env);
  END IF;
 IF c.location_id='0b85f354-9cdb-47e1-baf9-3d266bb7e06b'::uuid THEN PERFORM set_config('application_name','TUS_PERF helper_immobilization',true); END IF; -- INUZUKA-DISPATCH-DIAG020
 PERFORM combat_panel_private.immobilization_escape_offers(c.id,c.context_version,env);
 PERFORM combat_panel_private.nara_control_offers_v1(c.id,c.context_version,env);
 PERFORM combat_panel_private.cure_offers_v1(c.id,c.context_version,env);
 PERFORM clan_akimichi_private.common_panel_offers_v1(c.id,c.context_version,env);
 PERFORM clan_innata_combat_private.velo_control_offers_v1(c.id,c.context_version);
 PERFORM combat_panel_private.chakra_pill_staff_offers_v1(c.id,c.context_version);
 IF c.location_id='0b85f354-9cdb-47e1-baf9-3d266bb7e06b'::uuid THEN PERFORM set_config('application_name','TUS_PERF helper_clone',true); END IF; -- INUZUKA-DISPATCH-DIAG020
 PERFORM clan_sabaku_private.clone_offers(c.id,c.context_version,env);
 PERFORM clan_sabaku_private.flow_ordinary_figure_offers(c.id,c.context_version,env);
 END IF;
 PERFORM set_config('application_name','TUS_PERF helpers_movement',true); -- INUZUKA-ORDINARY-DIAG018
 -- INUZUKA-STAFF-QA-SKIP-PG-MOVEMENT-20260922-023
 IF NOT (
   p_location='0b85f354-9cdb-47e1-baf9-3d266bb7e06b'::uuid
   AND p_actor='c5865d83-3651-4815-a7e2-de484c3f5481'::uuid
   AND auth.uid()='15448f47-3b43-416f-a703-dbe7a74d36ce'::uuid
   AND EXISTS(
     SELECT 1 FROM combat_consumer_private.activities qa_session
     JOIN public.combat_v2_actors qa_actor ON qa_actor.id=p_actor
     JOIN public.characters qa_character ON qa_character.id=qa_actor.character_id
     WHERE qa_session.location_id=p_location
       AND qa_session.session_id=c.activity_id
       AND qa_session.exchange_id=c.round_id
       AND qa_session.phase<>'closed'
       AND qa_session.turn_actor_id=p_actor
       AND qa_session.policy_id='staff_test_no_persistent_resources_v1'
       AND qa_actor.session_id=qa_session.session_id
       AND qa_actor.controller_user=auth.uid()
       AND qa_actor.actor_kind='pg'
       AND qa_actor.companion_id IS NULL
       AND qa_actor.state='attivo'
       AND qa_character.id='2a877f02-4993-4e65-9172-7d29f08c5b86'::uuid
       AND qa_character.clan='Nessuno'
       AND NOT public.combat_v2_values_written(qa_session.session_id)
   )
 ) THEN
   PERFORM combat_panel_private.pg_movement_offers(c.id,c.context_version);
 END IF;
 IF user_testroom_common_private.bound_context(p_location) IS NULL THEN
  PERFORM combat_panel_private.master_open_offers(c.id,c.context_version);
 END IF;
 PERFORM set_config('application_name','TUS_PERF render_offers',true); -- INUZUKA-ORDINARY-DIAG018
   PERFORM combat_v2_genjutsu_internal.panel_options(c.id,c.context_version);
 PERFORM combat_panel_private.nara_adv_offers_v1(c.id,c.context_version,env);
  SELECT coalesce(jsonb_agg(combat_panel_private.offer_projection(id) ORDER BY created_at,id),'[]'::jsonb)
   INTO rendered FROM combat_panel_private.offers WHERE context_id=c.id
     AND context_version=c.context_version AND state='offered'
     AND (kind<>'control' OR NOT combat_panel_private.chakra_pill_hide_control_v1(source_payload,c.round_id,c.command_actor_id));
 PERFORM set_config('application_name','TUS_PERF movement_explanations',true); -- INUZUKA-ORDINARY-DIAG018
 RETURN jsonb_set(jsonb_set(env,'{offers}',rendered),'{movement_explanations}',
   coalesce(combat_panel_private.movement_explanations(c.id,c.context_version),'null'::jsonb));
END $function$;

CREATE OR REPLACE FUNCTION public.combat_panel_commit_v1(p_command jsonb)
 RETURNS jsonb
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO ''
AS $function$
DECLARE p jsonb; uid uuid:=auth.uid(); key uuid; fp text; adapter text; reason text;
 prior combat_panel_private.request_receipts%ROWTYPE; offer combat_panel_private.offers%ROWTYPE;
 code text; message text; recovery text;
 diag_context text; diag_state text; diag_frames jsonb;
 diag35_binding jsonb; diag35_scope uuid; diag35_frames jsonb; diag35_data jsonb;
 diag35_key uuid; diag35_fingerprint text; diag35_adapter text; diag35_offer combat_panel_private.offers%ROWTYPE;
BEGIN
 IF uid IS NULL THEN RAISE EXCEPTION 'panel_authentication_required' USING ERRCODE='28000'; END IF;
 p:=combat_panel_private.validate_command(p_command);
 PERFORM exam_human_private.assert_panel_command_v1(p); key:=(p->>'request_key')::uuid; fp:=public.combat_v2_sha256(p);
 PERFORM pg_advisory_xact_lock(hashtextextended('panel-request:'||uid::text||':'||key::text,731));
 SELECT * INTO prior FROM combat_panel_private.request_receipts WHERE principal_user=uid AND request_key=key;
 IF prior.request_key IS NOT NULL THEN
   IF prior.command_fingerprint<>fp THEN RAISE EXCEPTION 'panel_request_key_conflict' USING ERRCODE='22023'; END IF;
   IF prior.viewer_envelope#>'{receipt,inuzuka}' IS NOT NULL AND EXISTS(
     SELECT 1 FROM combat_panel_private.offers saved_offer WHERE saved_offer.id=prior.offer_id
       AND saved_offer.principal_user=uid AND saved_offer.kind='control'
       AND saved_offer.source_payload->>'adapter'='master_v2'
       AND saved_offer.source_payload->>'dispatch'='inuzuka_control'
   ) THEN
     RETURN jsonb_set(prior.viewer_envelope,'{receipt,replayed}','true',false) #- '{receipt,inuzuka}';
   END IF;
   RETURN jsonb_set(prior.viewer_envelope,'{receipt,replayed}','true',false);
 END IF;
 SELECT * INTO offer FROM combat_panel_private.offers WHERE id=(p->>'offer_id')::uuid AND principal_user=uid;
 IF offer.id IS NULL THEN RAISE EXCEPTION 'panel_offer_not_available' USING ERRCODE='42501'; END IF;
 IF EXISTS(SELECT 1 FROM combat_panel_private.contexts ctx
   JOIN mission_generic_owner.unified_batches ub ON ub.encounter_id=ctx.activity_id
   WHERE ctx.id=offer.context_id AND ctx.principal_user=uid
     AND ub.source_window_id IS NOT NULL AND ub.composition_kind='entry_png'
     AND ub.state IN('preparing','ready') AND ub.message_id IS NULL)
 THEN RAISE EXCEPTION 'MUF_PUBLICATION_PENDING' USING ERRCODE='42501'; END IF;
 adapter:=offer.source_payload->>'adapter';
 reason:=combat_panel_private.access_reason((p->>'location_id')::uuid,adapter);
 IF reason IS NOT NULL THEN RAISE EXCEPTION 'panel_access_rejected' USING ERRCODE='42501'; END IF;
 IF adapter IS DISTINCT FROM combat_panel_private.location_adapter((p->>'location_id')::uuid) THEN
   RAISE EXCEPTION 'panel_context_stale' USING ERRCODE='40001'; END IF;
 IF adapter='master_v2' AND offer.kind='administration' AND offer.operation='administration'
   AND offer.source_payload->>'dispatch'='staff_native_roster' THEN
   RETURN combat_v2_staff_nb_internal.commit_roster(p);
 END IF;
 IF adapter IN ('ordinary_v2','master_v2') AND offer.kind='control' AND offer.operation='control'
   AND offer.source_payload->>'dispatch'='staff_chakra_pill' THEN
   RETURN combat_panel_private.chakra_pill_staff_commit_v1(p);
 END IF;
 IF adapter IN ('ordinary_v2','master_v2') AND offer.kind = 'control'
   AND offer.operation = 'control' AND offer.source_payload->>'dispatch' = 'velo_staff_control' THEN
   RETURN clan_innata_combat_private.velo_control_commit_v1(p);
 END IF;
 IF offer.source_payload->>'dispatch' IN('akimichi_common_profile','akimichi_common_form','akimichi_cellular') THEN
   RETURN clan_akimichi_private.common_panel_commit_v1(p);
 END IF;
 IF offer.source_payload->>'dispatch' IN('nara_adv_prepare','nara_strangle') THEN RETURN combat_panel_private.nara_adv_commit_v1(p);END IF;
 IF offer.source_payload->>'dispatch' IN('cure_staff_profile','cure_action') THEN
   RETURN combat_panel_private.cure_commit_v1(p);
 END IF;
 IF offer.kind='administration' AND offer.operation='open'
   AND offer.source_payload->>'dispatch'='master_session_open' THEN
   RETURN combat_panel_private.commit_master_open(p); END IF;
 IF offer.kind='action' AND offer.operation='declare' AND offer.source_payload->>'dispatch'='sabaku_clone' THEN
   RETURN clan_sabaku_private.commit_clone(p); END IF;
 IF offer.kind='action' AND offer.operation='declare' AND offer.source_payload->>'dispatch'='immobilization_escape' THEN
   RETURN combat_panel_private.commit_immobilization_escape(p); END IF;
 IF offer.kind='action' AND offer.operation='declare' AND offer.source_payload->>'dispatch'='multiplication' THEN
   RETURN combat_panel_private.commit_multiplication(p); END IF;
 IF adapter IN ('ordinary_v2','master_v2') AND offer.kind='control' AND offer.operation='control'
   AND offer.source_payload->>'dispatch'='nara_possession_control' THEN
   RETURN combat_panel_private.nara_commit_control_v1(p); END IF;
 IF adapter='ordinary_v2' AND offer.kind='control' AND offer.operation='control' AND offer.source_payload->>'dispatch'='pg_movement' THEN
   RETURN combat_panel_private.commit_pg_movement(p); END IF;
 IF adapter='ordinary_v2' THEN RETURN combat_panel_private.commit_ordinary(p); END IF;
 IF adapter='master_v2' AND offer.kind='control' AND offer.operation='control' AND offer.source_payload->>'dispatch'='master_movement_control' THEN
   RETURN combat_panel_private.commit_master_movement_control(p); END IF;
 IF adapter='master_v2' THEN
   IF offer.kind='control' AND offer.source_payload->>'dispatch'='hoki_control' THEN
     RETURN clan_hoki_private.commit_master_body(p); END IF;
   IF offer.kind='control' AND offer.source_payload->>'dispatch'='aburame_control' THEN
     RETURN clan_aburame_private.commit_master_stop(p); END IF;
   IF offer.kind='control' AND offer.source_payload->>'dispatch'='scudo_control' THEN
     RETURN combat_v2_elemental_internal.scudo_commit_master_control(p); END IF;
   IF offer.kind='control' AND offer.source_payload->>'dispatch'='suiton_control' THEN
     RETURN combat_v2_elemental_internal.suiton_commit_master_control(p); END IF;
   IF offer.kind='control' AND offer.source_payload->>'dispatch'='other_control' THEN
     RETURN combat_v2_elemental_internal.other_commit_master_control(p); END IF;
   IF offer.kind='control' AND offer.source_payload->>'dispatch'='hyuga_control' THEN
     RETURN clan_hyuga_private.commit_master_control(p); END IF;
   IF offer.kind='control' AND offer.source_payload->>'dispatch'='sharingan_control' THEN
     RETURN clan_innata_private.sharingan_commit_master_control(p); END IF;
   IF offer.kind='control' AND offer.source_payload->>'dispatch'='sabaku_control' THEN
     RETURN clan_sabaku_private.commit_master_control(p); END IF;
   IF offer.kind='control' AND offer.source_payload->>'dispatch'='akimichi_form' THEN
     RETURN clan_akimichi_private.commit_master_form(p);
   END IF;
   IF offer.kind='control' AND offer.source_payload->>'dispatch'='inuzuka_control' THEN RETURN clan_inuzuka_private.commit_master_control(p) #- '{receipt,inuzuka}'; END IF; IF offer.kind='control' AND offer.source_payload->>'dispatch'='companion_control' THEN
     RETURN combat_panel_private.commit_master_companion(p); END IF;
   IF offer.kind='administration' THEN RETURN combat_panel_private.commit_master_admin(p); END IF;
   RETURN combat_panel_private.commit_master_actor(p);
 END IF;
 RAISE EXCEPTION 'panel_dispatch_not_available' USING ERRCODE='22023';
EXCEPTION WHEN OTHERS THEN
 -- Questo ramo viene raggiunto dopo il rollback dell'intera sottotransazione
 -- della richiesta. Non comprende timeout/disconnessioni senza risposta DB.
 code:=CASE WHEN SQLSTATE='28000' THEN 'authentication_required'
   WHEN SQLERRM='panel_request_key_conflict' THEN 'request_key_conflict'
   WHEN SQLSTATE='42501' THEN 'not_authorized'
   WHEN SQLSTATE='40001' THEN 'context_changed'
   WHEN SQLSTATE LIKE '22%' THEN 'selection_rejected' ELSE 'operation_rejected' END;
 message:=CASE code WHEN 'authentication_required' THEN 'Accedi nuovamente per continuare.'
   WHEN 'request_key_conflict' THEN 'Questa richiesta è già associata a un altro invio. Verifica lo stato prima di continuare.'
   WHEN 'not_authorized' THEN 'Questa operazione non è disponibile per il tuo accesso.'
   WHEN 'context_changed' THEN 'Lo scontro è cambiato. Rileggi lo stato e scegli di nuovo.'
   WHEN 'selection_rejected' THEN CASE SQLERRM
     WHEN 'panel_command_shape_invalid' THEN 'La richiesta non ha il formato previsto. Riapri il pannello prima di inviare.'
     WHEN 'panel_command_keys_invalid' THEN 'La richiesta non ha il formato previsto. Riapri il pannello prima di inviare.'
     WHEN 'panel_contract_version_invalid' THEN 'La richiesta non ha il formato previsto. Riapri il pannello prima di inviare.'
     WHEN 'panel_command_values_invalid' THEN 'La richiesta non ha il formato previsto. Riapri il pannello prima di inviare.'
     WHEN 'panel_identifier_invalid' THEN 'La richiesta non identifica correttamente il contesto o le scelte. Rileggi il pannello.'
     WHEN 'panel_option_identifier_invalid' THEN 'La richiesta non identifica correttamente il contesto o le scelte. Rileggi il pannello.'
     WHEN 'panel_context_version_invalid' THEN 'La richiesta non identifica correttamente il contesto o le scelte. Rileggi il pannello.'
     WHEN 'panel_duplicate_selection' THEN 'La selezione contiene elementi ripetuti o non validi. Rileggi le opzioni e scegli nuovamente.'
     WHEN 'panel_selection_invalid' THEN 'La selezione contiene elementi ripetuti o non validi. Rileggi le opzioni e scegli nuovamente.'
     WHEN 'panel_selection_not_offered' THEN 'Una delle scelte inviate non appartiene alle opzioni disponibili. Rileggi le opzioni.'
     WHEN 'panel_choice_cardinality_or_dependency_invalid' THEN 'Manca una scelta richiesta, sono selezionate troppe opzioni oppure alcune scelte sono incompatibili. Rileggi le opzioni e correggi la selezione.'
     WHEN 'panel_input_shape_invalid' THEN 'Uno dei campi richiesti è mancante, ripetuto o non valido. Controlla i campi prima di inviare.'
     WHEN 'panel_duplicate_input' THEN 'Uno dei campi richiesti è mancante, ripetuto o non valido. Controlla i campi prima di inviare.'
     WHEN 'panel_input_cardinality_invalid' THEN 'Uno dei campi richiesti è mancante, ripetuto o non valido. Controlla i campi prima di inviare.'
     WHEN 'panel_input_value_invalid' THEN 'Uno dei campi richiesti è mancante, ripetuto o non valido. Controlla i campi prima di inviare.'
     WHEN 'panel_input_not_offered' THEN 'La richiesta contiene un campo non previsto per questa azione. Rileggi le opzioni.'
     WHEN 'panel_activity_scope_invalid' THEN 'La richiesta non appartiene allo scontro o al luogo selezionato. Riapri il pannello.'
     WHEN 'panel_role_required' THEN 'Questa dichiarazione richiede un testo di azione valido prima della conferma.'
     WHEN 'panel_multiplication_selection_incomplete' THEN 'Completa le scelte di copie, modalità, disposizione e originale prima di confermare.'
     WHEN 'panel_multiplication_selection_conflict' THEN 'Le scelte di modalità, copie, disposizione o bersaglio della Moltiplicazione sono incompatibili.'
     WHEN 'panel_multiplication_mode_invalid' THEN 'La modalità scelta e la presenza del bersaglio non sono compatibili.'
     WHEN 'panel_multiplication_formation_invalid' THEN 'Il numero di copie o la disposizione non rispettano i limiti disponibili della Moltiplicazione.'
     WHEN 'panel_multiplication_figure_outside_arena' THEN 'La disposizione porta almeno una figura fuori dai confini dell’arena.'
     WHEN 'panel_multiplication_single_movement_required' THEN 'Lo spostamento dell’originale non è disponibile. Controlla il movimento residuo e gli impedimenti.'
     WHEN 'panel_multiplication_zero_movement_capability' THEN 'È stato richiesto uno spostamento, ma l’originale è nella posizione di partenza. Rileggi le opzioni.'
     WHEN 'panel_multiplication_target_invalid' THEN 'Il bersaglio dell’assalto non è un avversario attivo in questo scontro.'
     WHEN 'panel_multiplication_target_choice_required' THEN 'Per questo bersaglio occorre selezionare una figura tra quelle offerte.'
     WHEN 'panel_multiplication_target_selection_conflict' THEN 'La selezione della figura per il bersaglio non è completa o contiene scelte incompatibili.'
     WHEN 'panel_multiplication_target_selection_invalid' THEN 'La selezione della figura per il bersaglio non è completa o contiene scelte incompatibili.'
     WHEN 'panel_attack_origin_invalid' THEN 'L’origine scelta per l’attacco non è consentita.'
     WHEN 'panel_multiplication_assault_contact_invalid' THEN 'L’assalto non può raggiungere il bersaglio dalla posizione scelta: verifica visibilità, contatto, direzione e percorso.'
     WHEN 'panel_multiplication_catalog_changed' THEN 'La tecnica non è utilizzabile con la configurazione attuale. Segnala il rifiuto allo staff.'
     WHEN 'panel_multiplication_rank_unavailable' THEN 'Non è possibile determinare le copie disponibili per il rango del personaggio. Contatta lo staff.'
     WHEN 'panel_multiplication_resources_invalid' THEN 'Non è possibile verificare le risorse disponibili per la Moltiplicazione. Contatta lo staff.'
     WHEN 'panel_multiplication_cost_snapshot_invalid' THEN 'Non è possibile verificare le risorse disponibili per la Moltiplicazione. Contatta lo staff.'
     WHEN 'panel_multiplication_npc_source_unavailable' THEN 'Questo attore non dispone di una fonte valida per usare la Moltiplicazione.'
     WHEN 'panel_multiplication_actor_kind_invalid' THEN 'Questo attore non dispone di una fonte valida per usare la Moltiplicazione.'
     WHEN 'immobilization_escape_action_conflict' THEN 'La stessa dichiarazione contiene azioni speciali incompatibili. Rileggi le opzioni e scegli una sola azione.'
     WHEN 'sabaku_clone_action_conflict' THEN 'La stessa dichiarazione contiene azioni speciali incompatibili. Rileggi le opzioni e scegli una sola azione.'
     WHEN 'panel_dispatch_not_available' THEN 'Questa azione non ha un percorso disponibile nel pannello. Segnala il rifiuto allo staff.'
     ELSE 'Le scelte non sono più valide. Rileggi le opzioni.' END
   ELSE 'Il server ha rifiutato l’operazione. Rileggi lo stato; se il problema resta, informa lo staff.' END;
 recovery:=CASE WHEN code='authentication_required' THEN 'authenticate'
   WHEN code='request_key_conflict' THEN 'contact_staff' ELSE 'refresh' END;
 -- Diagnostica privata della sola sessione Staff autorizzata. Nessun testo della richiesta.
 GET STACKED DIAGNOSTICS diag_context = PG_EXCEPTION_CONTEXT, diag_state = RETURNED_SQLSTATE;
 BEGIN
  IF uid IS NOT NULL AND key IS NOT NULL AND offer.id IS NOT NULL
   AND offer.principal_user=uid AND public.is_staff()
   AND ((offer.kind='action' AND offer.operation='declare')
    OR (offer.kind='control' AND offer.operation='control' AND adapter='ordinary_v2'
     AND EXISTS (SELECT 1 FROM combat_consumer_private.offers diagnostic_source
       WHERE diagnostic_source.id=(offer.source_payload->>'source_offer_id')::uuid
        AND diagnostic_source.session_id=(offer.source_payload->>'source_activity_id')::uuid
        AND diagnostic_source.operation='control'
        AND diagnostic_source.source_payload->>'aburame_operation'='release_stop'))
    OR (offer.kind='defense' AND offer.operation='defend' AND adapter='ordinary_v2'
     AND EXISTS (
      SELECT 1 FROM combat_consumer_private.offers src
      JOIN public.combat_v2_actors defender ON defender.id=offer.actor_id
      WHERE src.id=(offer.source_payload->>'source_offer_id')::uuid
       AND src.offer_kind='defense' AND src.operation='defend'
       AND (src.source_payload#>>'{intent,reaction}' IN ('parata','schivata','nessuna')
        OR (src.source_payload->>'aburame_clone'='aburame-clone/1'
         AND src.source_payload#>>'{intent,reaction}'='tecnica'
         AND src.source_payload#>>'{intent,ability_source}'='clan'
         AND src.source_payload#>>'{intent,ability_id}'='b9195ceb-74de-4251-95af-fe5c1bdaf485'))
       AND src.session_id=defender.session_id
       AND src.principal_character_id=defender.character_id
       AND src.location_id='0b85f354-9cdb-47e1-baf9-3d266bb7e06b'::uuid)))
   AND adapter IN ('ordinary_v2','master_v2')
   AND EXISTS (
    SELECT 1 FROM combat_panel_private.contexts c
    JOIN public.combat_v2_actors a ON a.id=offer.actor_id AND a.controller_user=uid
    JOIN public.combat_v2_sessions s ON s.id=a.session_id
    WHERE c.id=offer.context_id AND c.principal_user=uid AND c.command_actor_id=a.id
     AND s.id='bff182d1-7027-4519-a546-65e28d991716'::uuid
     AND c.activity_id=s.id
     AND c.id='8b72e8cf-c522-4b88-bc64-a51c83bddcb4'::uuid
     AND c.round_id='c880d549-179d-414d-ad25-a987c999af87'::uuid
     AND c.location_id='0b85f354-9cdb-47e1-baf9-3d266bb7e06b'::uuid
     AND s.location_id=c.location_id
     AND c.activity_kind=adapter
     AND a.id IN ('ff130a12-d6df-4e11-8add-b3087b42aab8'::uuid,'da8eebcd-2d79-49c2-b5ec-c7ea4fbc02d8'::uuid)
     AND NOT public.combat_v2_values_written(s.id))
   AND combat_panel_private.access_reason('0b85f354-9cdb-47e1-baf9-3d266bb7e06b'::uuid,adapter) IS NULL
  THEN
   SELECT coalesce(jsonb_agg(jsonb_build_object('function',x.parts[1],'line',x.parts[2]::integer) ORDER BY x.ord),'[]'::jsonb)
    INTO diag_frames
    FROM (SELECT m.parts,m.ord FROM regexp_matches(diag_context,
     'PL/pgSQL function ([a-z_][a-z0-9_]*(?:[.][a-z_][a-z0-9_]*)?)[(][^\n]*[)] line ([0-9]+)',
     'g') WITH ORDINALITY AS m(parts,ord) LIMIT 16) x;
   INSERT INTO public.combat_v2_events(scope_id,request_key,operation_kind,request_fingerprint,
    caller,status,error_sanitized,completed_at)
   VALUES('36651303-0795-4b3e-832d-e2ae6d070b0c'::uuid,key,'staff_panel_rejection_diagnostic',
    public.combat_v2_sha256(jsonb_build_object('request_key',key,'sqlstate',diag_state,'frames',diag_frames)),
    NULL,'fallita',jsonb_build_object('schema','staff-panel-diagnostic/1','sqlstate',diag_state,'frames',diag_frames),clock_timestamp())
   ON CONFLICT (scope_id,request_key) DO NOTHING;
  END IF;
 EXCEPTION WHEN OTHERS THEN
  -- Un errore del solo audit non sostituisce il rifiuto pubblico originale.
  NULL;
 END;
 BEGIN
  -- Audit35: letture e scrittura diagnostiche isolate, dopo il rollback della richiesta.
  -- Il guard costante racchiude TUTTO il nuovo audit; la recovery lo disattiva integralmente.
  IF TRUE THEN
   IF uid IS NOT NULL AND p IS NOT NULL AND jsonb_typeof(p)='object' AND public.is_staff() THEN
    diag35_key:=(p->>'request_key')::uuid;
    diag35_fingerprint:=public.combat_v2_sha256(p);
    SELECT * INTO diag35_offer FROM combat_panel_private.offers
     WHERE id=(p->>'offer_id')::uuid AND principal_user=uid;
    diag35_adapter:=diag35_offer.source_payload->>'adapter';
    IF diag35_key IS NOT NULL AND diag35_offer.id IS NOT NULL
     AND diag35_offer.principal_user=uid AND diag35_fingerprint~'^[0-9a-f]{64}$'
     AND diag35_adapter IN ('ordinary_v2','master_v2')
     AND combat_panel_private.access_reason('0b85f354-9cdb-47e1-baf9-3d266bb7e06b'::uuid,diag35_adapter) IS NULL
     AND combat_consumer_private.staff_test_allowed('0b85f354-9cdb-47e1-baf9-3d266bb7e06b'::uuid,ARRAY[uid]::uuid[],false)
    THEN
     SELECT jsonb_build_object('master_session_id',ds.master_session_id,'encounter_id',ds.id,
       'context_id',dc.id,'round_id',dc.round_id,'actor_id',da.id,'context_version',dc.context_version)
     INTO diag35_binding
     FROM combat_panel_private.contexts dc
     JOIN public.combat_v2_actors da ON da.id=diag35_offer.actor_id AND da.controller_user=uid
     JOIN public.combat_v2_sessions ds ON ds.id=da.session_id
     JOIN public.combat_v2_rounds dr ON dr.id=dc.round_id AND dr.session_id=ds.id
     JOIN public.locations dl ON dl.id=ds.location_id AND dl.is_active AND dl.is_test
     WHERE dc.id=diag35_offer.context_id AND dc.principal_user=uid AND dc.command_actor_id=da.id
      AND dc.activity_id=ds.id AND dc.activity_kind=diag35_adapter
      AND dc.location_id='0b85f354-9cdb-47e1-baf9-3d266bb7e06b'::uuid
      AND dl.id=dc.location_id
      AND combat_panel_private.uses_simulated_pools(ds.id) IS TRUE
      AND public.combat_v2_values_written(ds.id) IS FALSE;
     IF diag35_binding IS NOT NULL THEN
      SELECT coalesce(jsonb_agg(jsonb_build_object('function',df.parts[1],'line',df.parts[2]::integer) ORDER BY df.ord),'[]'::jsonb)
      INTO diag35_frames
      FROM (SELECT dm.parts,dm.ord FROM regexp_matches(diag_context,
       'PL/pgSQL function ([a-z_][a-z0-9_]*(?:[.][a-z_][a-z0-9_]*)?)[(][^\n]*[)] line ([0-9]+)',
       'g') WITH ORDINALITY AS dm(parts,ord) LIMIT 16) df;
      diag35_scope:=mission_ai_service_owner.uuid5((diag35_binding->>'encounter_id')::uuid,'staff-panel-rejection-diagnostic/2');
      diag35_data:=jsonb_build_object('schema','staff-panel-diagnostic/2','sqlstate',diag_state,
        'frames',diag35_frames,'binding',diag35_binding,'command_sha256',diag35_fingerprint);
      INSERT INTO public.combat_v2_events(scope_id,request_key,operation_kind,request_fingerprint,
       caller,control_version,status,error_sanitized,completed_at)
      VALUES(diag35_scope,diag35_key,'staff_panel_rejection_diagnostic',public.combat_v2_sha256(diag35_data),
       uid,(diag35_binding->>'context_version')::bigint,'fallita',diag35_data,clock_timestamp())
      ON CONFLICT (scope_id,request_key) DO NOTHING;
     END IF;
    END IF;
   END IF;
  END IF;
 EXCEPTION WHEN OTHERS THEN
  -- Un errore dell'audit corrente non altera né il rifiuto originale né l'audit storico.
  NULL;
 END;
 RETURN jsonb_build_object('schema_version','combat-panel-error/1','status','rejected','request_key',key,
   'code',code,'message',message,'recovery',recovery);
END $function$;

CREATE OR REPLACE FUNCTION clan_innata_private.catalogo_eligibility_release_v1()
 RETURNS boolean
 LANGUAGE plpgsql
 STABLE SECURITY DEFINER
 SET search_path TO ''
AS $function$
DECLARE
 rr mission_factory_owner.editor_release_readiness%ROWTYPE;root jsonb;binding jsonb;amendment jsonb;
 params constant jsonb:=$compat_metadata${"expected_alias_count":7,"shared_functions":[{"oid":"42942","signature":"combat_consumer_private.narrative_context(uuid)","source_md5":"7cb3411ca6ec879112227533b51c48a0","ddl_md5":"50dcb79fba3e3a93a97bf957daef26b9","abi":{"acl":"{postgres=X/postgres}","oid":"42942","kind":"f","owner":"postgres","config":["search_path=\"\""],"secdef":true,"strict":false,"nspname":"combat_consumer_private","proname":"narrative_context","returns":"jsonb","language":"plpgsql","parallel":"u","arg_modes":null,"arg_names":["p_round"],"arg_types":"2950","leakproof":false,"signature":"combat_consumer_private.narrative_context(uuid)","volatility":"s"}},{"oid":"46723","signature":"combat_consumer_private.narrative_declaration_supported(uuid)","source_md5":"14b40aca0b52866462e92c86ba214250","ddl_md5":"733fab475974d4393412069bc62f63c2","abi":{"acl":"{postgres=X/postgres}","oid":"46723","kind":"f","owner":"postgres","config":["search_path=\"\""],"secdef":true,"strict":false,"nspname":"combat_consumer_private","proname":"narrative_declaration_supported","returns":"boolean","language":"plpgsql","parallel":"u","arg_modes":null,"arg_names":["p_declaration"],"arg_types":"2950","leakproof":false,"signature":"combat_consumer_private.narrative_declaration_supported(uuid)","volatility":"s"}},{"oid":"42968","signature":"combat_consumer_private.validate_narrative_result(jsonb)","source_md5":"5445a1ce4c8ef497402c8bfe6061dcf5","ddl_md5":"3a865e21ea2104faf7598b0fffd3bfeb","abi":{"acl":"{postgres=X/postgres}","oid":"42968","kind":"f","owner":"postgres","config":["search_path=\"\""],"secdef":false,"strict":false,"nspname":"combat_consumer_private","proname":"validate_narrative_result","returns":"void","language":"plpgsql","parallel":"u","arg_modes":null,"arg_names":["p"],"arg_types":"3802","leakproof":false,"signature":"combat_consumer_private.validate_narrative_result(jsonb)","volatility":"i"}},{"oid":"52137","signature":"combat_effects_private.lifecycle_before_report(uuid)","source_md5":"bc4009af6a274d51e6b96fc51f7a7a78","ddl_md5":"ee929b8e4bb4efcd584e7755aa5df682","abi":{"acl":"{postgres=X/postgres}","oid":"52137","kind":"f","owner":"postgres","config":["search_path=\"\""],"secdef":true,"strict":false,"nspname":"combat_effects_private","proname":"lifecycle_before_report","returns":"jsonb","language":"plpgsql","parallel":"u","arg_modes":null,"arg_names":["p_round"],"arg_types":"2950","leakproof":false,"signature":"combat_effects_private.lifecycle_before_report(uuid)","volatility":"v"}},{"oid":"52136","signature":"combat_effects_private.lifecycle_main_end(uuid)","source_md5":"a1948e8ce4fc505fc23e4e4089958507","ddl_md5":"0b743c53cb23a3402542468dc3096430","abi":{"acl":"{postgres=X/postgres}","oid":"52136","kind":"f","owner":"postgres","config":["search_path=\"\""],"secdef":true,"strict":false,"nspname":"combat_effects_private","proname":"lifecycle_main_end","returns":"jsonb","language":"plpgsql","parallel":"u","arg_modes":null,"arg_names":["p_declaration"],"arg_types":"2950","leakproof":false,"signature":"combat_effects_private.lifecycle_main_end(uuid)","volatility":"v"}},{"oid":"52133","signature":"combat_effects_private.lifecycle_open(uuid,uuid)","source_md5":"3f77d8b6698bc4d6c4b3f454c91b104b","ddl_md5":"ccaa8626e04edc3573771689e1401046","abi":{"acl":"{postgres=X/postgres}","oid":"52133","kind":"f","owner":"postgres","config":["search_path=\"\""],"secdef":true,"strict":false,"nspname":"combat_effects_private","proname":"lifecycle_open","returns":"void","language":"plpgsql","parallel":"u","arg_modes":null,"arg_names":["p_session","p_actor"],"arg_types":"2950 2950","leakproof":false,"signature":"combat_effects_private.lifecycle_open(uuid,uuid)","volatility":"v"}},{"oid":"51910","signature":"combat_effects_private.personal_turn_end(uuid,uuid,uuid,text)","source_md5":"29f0a8df88c6bed279f650d49a706699","ddl_md5":"9e8138c513fa0c8824ca9c5d48aa3d54","abi":{"acl":"{postgres=X/postgres}","oid":"51910","kind":"f","owner":"postgres","config":["search_path=\"\""],"secdef":true,"strict":false,"nspname":"combat_effects_private","proname":"personal_turn_end","returns":"jsonb","language":"plpgsql","parallel":"u","arg_modes":null,"arg_names":["p_session","p_actor","p_turn","p_adapter"],"arg_types":"2950 2950 2950 25","leakproof":false,"signature":"combat_effects_private.personal_turn_end(uuid,uuid,uuid,text)","volatility":"v"}},{"oid":"51906","signature":"combat_effects_private.personal_turn_start(uuid,uuid,uuid,text)","source_md5":"e7ec43224a4640d00c53bad72ac0132d","ddl_md5":"d023d8a651a5e8ef8fdb1cc834b93391","abi":{"acl":"{postgres=X/postgres}","oid":"51906","kind":"f","owner":"postgres","config":["search_path=\"\""],"secdef":true,"strict":false,"nspname":"combat_effects_private","proname":"personal_turn_start","returns":"void","language":"plpgsql","parallel":"u","arg_modes":null,"arg_names":["p_session","p_actor","p_turn","p_adapter"],"arg_types":"2950 2950 2950 25","leakproof":false,"signature":"combat_effects_private.personal_turn_start(uuid,uuid,uuid,text)","volatility":"v"}},{"oid":"44942","signature":"combat_panel_private.commit_master_actor(jsonb)","source_md5":"0c39121bcbd32a49608e4d925560ba41","ddl_md5":"b531bb7f50d4346a09e822b2f2e95144","abi":{"acl":"{postgres=X/postgres}","oid":"44942","kind":"f","owner":"postgres","config":["search_path=\"\""],"secdef":true,"strict":false,"nspname":"combat_panel_private","proname":"commit_master_actor","returns":"jsonb","language":"plpgsql","parallel":"u","arg_modes":null,"arg_names":["p_command"],"arg_types":"3802","leakproof":false,"signature":"combat_panel_private.commit_master_actor(jsonb)","volatility":"v"}},{"oid":"45916","signature":"combat_panel_private.immobilization_actor_lifecycle()","source_md5":"5244a1f635ad7d7336d24140d288b82a","ddl_md5":"f8677e282d09ca9015c01de07391f1bc","abi":{"acl":"{postgres=X/postgres}","oid":"45916","kind":"f","owner":"postgres","config":["search_path=\"\""],"secdef":true,"strict":false,"nspname":"combat_panel_private","proname":"immobilization_actor_lifecycle","returns":"trigger","language":"plpgsql","parallel":"u","arg_modes":null,"arg_names":null,"arg_types":"","leakproof":false,"signature":"combat_panel_private.immobilization_actor_lifecycle()","volatility":"v"}},{"oid":"45918","signature":"combat_panel_private.immobilization_session_lifecycle()","source_md5":"a4671931aa6e908a94af2ad2d788d933","ddl_md5":"38bc9bc060bc1af88cf087f5e4a687bb","abi":{"acl":"{postgres=X/postgres}","oid":"45918","kind":"f","owner":"postgres","config":["search_path=\"\""],"secdef":true,"strict":false,"nspname":"combat_panel_private","proname":"immobilization_session_lifecycle","returns":"trigger","language":"plpgsql","parallel":"u","arg_modes":null,"arg_names":null,"arg_types":"","leakproof":false,"signature":"combat_panel_private.immobilization_session_lifecycle()","volatility":"v"}},{"oid":"44940","signature":"combat_panel_private.master_options(uuid,uuid,bigint)","source_md5":"ad3cec069a1a0c5ab4a4a804de12bbec","ddl_md5":"19c0226969fc069225a14c65a5d563e9","abi":{"acl":"{postgres=X/postgres}","oid":"44940","kind":"f","owner":"postgres","config":["search_path=\"\""],"secdef":true,"strict":false,"nspname":"combat_panel_private","proname":"master_options","returns":"jsonb","language":"plpgsql","parallel":"u","arg_modes":null,"arg_names":["p_location","p_actor","p_expected"],"arg_types":"2950 2950 20","leakproof":false,"signature":"combat_panel_private.master_options(uuid,uuid,bigint)","volatility":"v"}},{"oid":"45000","signature":"combat_panel_private.movement_block_reason(uuid)","source_md5":"2522ebb08015c0a1342e63c5f3f40c3a","ddl_md5":"02f80418c4b3e6b762aa06dcb743588d","abi":{"acl":"{postgres=X/postgres}","oid":"45000","kind":"f","owner":"postgres","config":["search_path=\"\""],"secdef":true,"strict":false,"nspname":"combat_panel_private","proname":"movement_block_reason","returns":"text","language":"plpgsql","parallel":"u","arg_modes":null,"arg_names":["p_body"],"arg_types":"2950","leakproof":false,"signature":"combat_panel_private.movement_block_reason(uuid)","volatility":"s"}},{"oid":"46019","signature":"combat_panel_private.narrative_declaration_facts(uuid)","source_md5":"6411b500dfb47e2bd30b3fab1cca9d41","ddl_md5":"3e0bc85ed0d20d893b779a482f0799bb","abi":{"acl":"{postgres=X/postgres}","oid":"46019","kind":"f","owner":"postgres","config":["search_path=\"\""],"secdef":true,"strict":false,"nspname":"combat_panel_private","proname":"narrative_declaration_facts","returns":"jsonb","language":"plpgsql","parallel":"u","arg_modes":null,"arg_names":["p_declaration"],"arg_types":"2950","leakproof":false,"signature":"combat_panel_private.narrative_declaration_facts(uuid)","volatility":"s"}},{"oid":"46020","signature":"combat_panel_private.narrative_ordinary_context(uuid)","source_md5":"e7c2a225b3f4432ba16fc96221f08653","ddl_md5":"31b06a04a966582b028e43525d98a411","abi":{"acl":"{postgres=X/postgres}","oid":"46020","kind":"f","owner":"postgres","config":["search_path=\"\""],"secdef":true,"strict":false,"nspname":"combat_panel_private","proname":"narrative_ordinary_context","returns":"jsonb","language":"plpgsql","parallel":"u","arg_modes":null,"arg_names":["p_round"],"arg_types":"2950","leakproof":false,"signature":"combat_panel_private.narrative_ordinary_context(uuid)","volatility":"s"}},{"oid":"46018","signature":"combat_panel_private.narrative_outcome_facts(jsonb)","source_md5":"988cc3b61d0ebf41effda90d32e173b5","ddl_md5":"a4d973f30fbd64ace5540ea3438c8e26","abi":{"acl":"{postgres=X/postgres}","oid":"46018","kind":"f","owner":"postgres","config":["search_path=\"\""],"secdef":false,"strict":false,"nspname":"combat_panel_private","proname":"narrative_outcome_facts","returns":"jsonb","language":"plpgsql","parallel":"u","arg_modes":null,"arg_names":["p_outcome"],"arg_types":"3802","leakproof":false,"signature":"combat_panel_private.narrative_outcome_facts(jsonb)","volatility":"s"}},{"oid":"44669","signature":"combat_panel_private.ordinary_options(uuid,uuid,bigint)","source_md5":"0e0226a9138c221d59a073d161d7a759","ddl_md5":"ff85a0b898d7635043ba47df4a304afd","abi":{"acl":"{postgres=X/postgres}","oid":"44669","kind":"f","owner":"postgres","config":["search_path=\"\""],"secdef":true,"strict":false,"nspname":"combat_panel_private","proname":"ordinary_options","returns":"jsonb","language":"plpgsql","parallel":"u","arg_modes":null,"arg_names":["p_location","p_actor","p_expected"],"arg_types":"2950 2950 20","leakproof":false,"signature":"combat_panel_private.ordinary_options(uuid,uuid,bigint)","volatility":"v"}},{"oid":"44955","signature":"combat_panel_private.round_details_from_source(jsonb,jsonb,jsonb)","source_md5":"23722822d09c8d2a12a5121d04c141a6","ddl_md5":"883d64a10bb28250187b01e96e2dcf5e","abi":{"acl":"{postgres=X/postgres}","oid":"44955","kind":"f","owner":"postgres","config":["search_path=\"\""],"secdef":false,"strict":false,"nspname":"combat_panel_private","proname":"round_details_from_source","returns":"jsonb","language":"plpgsql","parallel":"u","arg_modes":null,"arg_names":["p_source","p_roster","p_offers"],"arg_types":"3802 3802 3802","leakproof":false,"signature":"combat_panel_private.round_details_from_source(jsonb,jsonb,jsonb)","volatility":"i"}},{"oid":"46316","signature":"combat_panel_private.round_options_authoritative(uuid,uuid)","source_md5":"7cf9d8be18c9dab5f75b62c74a5e9e37","ddl_md5":"7758a51d9039673ab98462102c44f888","abi":{"acl":"{postgres=X/postgres}","oid":"46316","kind":"f","owner":"postgres","config":["search_path=\"\""],"secdef":true,"strict":false,"nspname":"combat_panel_private","proname":"round_options_authoritative","returns":"jsonb","language":"plpgsql","parallel":"u","arg_modes":null,"arg_names":["p_round","p_actor"],"arg_types":"2950 2950","leakproof":false,"signature":"combat_panel_private.round_options_authoritative(uuid,uuid)","volatility":"v"}},{"oid":"61967","signature":"combat_v2_elemental_internal.other_consumer_options(jsonb)","source_md5":"8423c49ce8a83f2b19361b82a53fa9f4","ddl_md5":"0d57fa274c2b6b63dc5ed1ef0a7c8ca9","abi":{"acl":"{postgres=X/postgres}","oid":"61967","kind":"f","owner":"postgres","config":["search_path=\"\""],"secdef":true,"strict":false,"nspname":"combat_v2_elemental_internal","proname":"other_consumer_options","returns":"jsonb","language":"plpgsql","parallel":"u","arg_modes":null,"arg_names":["p"],"arg_types":"3802","leakproof":false,"signature":"combat_v2_elemental_internal.other_consumer_options(jsonb)","volatility":"v"}},{"oid":"61972","signature":"combat_v2_elemental_internal.other_control_apply(text,uuid,uuid,uuid)","source_md5":"4cf97ca72ff52f1bd33445ba54c8dd16","ddl_md5":"9066a8a35e086727ed0240ea05fce684","abi":{"acl":"{postgres=X/postgres}","oid":"61972","kind":"f","owner":"postgres","config":["search_path=\"\""],"secdef":true,"strict":false,"nspname":"combat_v2_elemental_internal","proname":"other_control_apply","returns":"jsonb","language":"plpgsql","parallel":"u","arg_modes":null,"arg_names":["p_adapter","p_offer","p_actor","p_request"],"arg_types":"25 2950 2950 2950","leakproof":false,"signature":"combat_v2_elemental_internal.other_control_apply(text,uuid,uuid,uuid)","volatility":"v"}},{"oid":"61971","signature":"combat_v2_elemental_internal.other_control_target(text,uuid,uuid)","source_md5":"b1af00f3eab38ed9e74836c5441616d7","ddl_md5":"03724449dfc52ef8fcf4f89ae6eabb34","abi":{"acl":"{postgres=X/postgres}","oid":"61971","kind":"f","owner":"postgres","config":["search_path=\"\""],"secdef":true,"strict":false,"nspname":"combat_v2_elemental_internal","proname":"other_control_target","returns":"uuid","language":"plpgsql","parallel":"u","arg_modes":null,"arg_names":["p_adapter","p_offer","p_actor"],"arg_types":"25 2950 2950","leakproof":false,"signature":"combat_v2_elemental_internal.other_control_target(text,uuid,uuid)","volatility":"v"}},{"oid":"61970","signature":"combat_v2_elemental_internal.other_master_options(uuid,bigint)","source_md5":"0c79a6a78b76b9e9ef8028d75e514af7","ddl_md5":"38e2e92e5566275950c270ef5a8fe3d6","abi":{"acl":"{postgres=X/postgres}","oid":"61970","kind":"f","owner":"postgres","config":["search_path=\"\""],"secdef":true,"strict":false,"nspname":"combat_v2_elemental_internal","proname":"other_master_options","returns":"void","language":"plpgsql","parallel":"u","arg_modes":null,"arg_names":["p_context","p_expected"],"arg_types":"2950 20","leakproof":false,"signature":"combat_v2_elemental_internal.other_master_options(uuid,bigint)","volatility":"v"}},{"oid":"61954","signature":"combat_v2_elemental_internal.other_prepare_native(uuid,uuid,uuid,jsonb,boolean,jsonb)","source_md5":"6e54b476b36ca716cf8c14f33ef9667e","ddl_md5":"98acc6f2f9fcb26b47f3e6e830763e42","abi":{"acl":"{postgres=X/postgres}","oid":"61954","kind":"f","owner":"postgres","config":["search_path=\"\""],"secdef":true,"strict":false,"nspname":"combat_v2_elemental_internal","proname":"other_prepare_native","returns":"jsonb","language":"plpgsql","parallel":"u","arg_modes":null,"arg_names":["p_round","p_actor","p_request","p_intent","p_push","p_native_ref"],"arg_types":"2950 2950 2950 3802 16 3802","leakproof":false,"signature":"combat_v2_elemental_internal.other_prepare_native(uuid,uuid,uuid,jsonb,boolean,jsonb)","volatility":"v"}},{"oid":"61950","signature":"combat_v2_elemental_internal.other_profile(uuid,uuid)","source_md5":"dd1e62e9052469fae4c98fed245c730a","ddl_md5":"0959ae18dc9357f65d8d8169e39b0cb2","abi":{"acl":"{postgres=X/postgres}","oid":"61950","kind":"f","owner":"postgres","config":["search_path=\"\""],"secdef":true,"strict":false,"nspname":"combat_v2_elemental_internal","proname":"other_profile","returns":"jsonb","language":"plpgsql","parallel":"u","arg_modes":null,"arg_names":["p_actor","p_technique"],"arg_types":"2950 2950","leakproof":false,"signature":"combat_v2_elemental_internal.other_profile(uuid,uuid)","volatility":"s"}},{"oid":"39291","signature":"combat_v2_multitarget_internal.resolve_parent(uuid,uuid,uuid,boolean)","source_md5":"4f89aa40d49971d2a74c04b85cd70f09","ddl_md5":"0f1b28887b56ece0e48b3238b3fb92dd","abi":{"acl":"{postgres=X/postgres}","oid":"39291","kind":"f","owner":"postgres","config":["search_path=\"\""],"secdef":true,"strict":false,"nspname":"combat_v2_multitarget_internal","proname":"resolve_parent","returns":"jsonb","language":"plpgsql","parallel":"u","arg_modes":null,"arg_names":["p_session","p_round","p_attack","p_values"],"arg_types":"2950 2950 2950 16","leakproof":false,"signature":"combat_v2_multitarget_internal.resolve_parent(uuid,uuid,uuid,boolean)","volatility":"v"}},{"oid":"42947","signature":"public.combat_consumer_narrative_claim_v1(uuid,text,uuid)","source_md5":"60fce00fae9119dd6b1c8906ef2ea7e8","ddl_md5":"d0a2ae1909d03454dace2f6e3b994ece","abi":{"acl":"{postgres=X/postgres,service_role=X/postgres}","oid":"42947","kind":"f","owner":"postgres","config":["search_path=\"\""],"secdef":true,"strict":false,"nspname":"public","proname":"combat_consumer_narrative_claim_v1","returns":"jsonb","language":"plpgsql","parallel":"u","arg_modes":null,"arg_names":["p_round","p_report_sha256","p_request_key"],"arg_types":"2950 25 2950","leakproof":false,"signature":"public.combat_consumer_narrative_claim_v1(uuid,text,uuid)","volatility":"v"}},{"oid":"42969","signature":"public.combat_consumer_narrative_complete_v1(uuid,jsonb,uuid)","source_md5":"1468dab936825b51e0f802f117a9dd0d","ddl_md5":"e7dc5d07a611fbfa165f2185fa01f8c3","abi":{"acl":"{postgres=X/postgres,service_role=X/postgres}","oid":"42969","kind":"f","owner":"postgres","config":["search_path=\"\""],"secdef":true,"strict":false,"nspname":"public","proname":"combat_consumer_narrative_complete_v1","returns":"jsonb","language":"plpgsql","parallel":"u","arg_modes":null,"arg_names":["p_claim","p_result","p_request_key"],"arg_types":"2950 3802 2950","leakproof":false,"signature":"public.combat_consumer_narrative_complete_v1(uuid,jsonb,uuid)","volatility":"v"}},{"oid":"44808","signature":"public.combat_panel_commit_v1(jsonb)","source_md5":"427e6ecda3eeb2c2a141aa077ea7f0a9","ddl_md5":"83b8cd6b6c06835579d573a08eaacd4b","abi":{"acl":"{postgres=X/postgres,authenticated=X/postgres}","oid":"44808","kind":"f","owner":"postgres","config":["search_path=\"\""],"secdef":true,"strict":false,"nspname":"public","proname":"combat_panel_commit_v1","returns":"jsonb","language":"plpgsql","parallel":"u","arg_modes":null,"arg_names":["p_command"],"arg_types":"3802","leakproof":false,"signature":"public.combat_panel_commit_v1(jsonb)","volatility":"v"}},{"oid":"31324","signature":"public.combat_v2_action_declare(uuid,uuid,jsonb,text,uuid)","source_md5":"6c23e94b38f8f252c3e49a1d389e588c","ddl_md5":"18cf15dcb36e3fe52b799a70882a77cf","abi":{"acl":"{postgres=X/postgres,authenticated=X/postgres,service_role=X/postgres}","oid":"31324","kind":"f","owner":"postgres","config":["search_path=\"\""],"secdef":true,"strict":false,"nspname":"public","proname":"combat_v2_action_declare","returns":"jsonb","language":"plpgsql","parallel":"u","arg_modes":null,"arg_names":["p_round","p_actor","p_intent","p_text","p_request_key"],"arg_types":"2950 2950 3802 25 2950","leakproof":false,"signature":"public.combat_v2_action_declare(uuid,uuid,jsonb,text,uuid)","volatility":"v"}},{"oid":"31311","signature":"public.combat_v2_actor_ability(uuid,text,uuid,boolean)","source_md5":"2ec5e6a87514a1997100990dde420a62","ddl_md5":"847221b518ed740a64afdcd00f7cd763","abi":{"acl":"{postgres=X/postgres,service_role=X/postgres}","oid":"31311","kind":"f","owner":"postgres","config":["search_path=\"\""],"secdef":true,"strict":false,"nspname":"public","proname":"combat_v2_actor_ability","returns":"jsonb","language":"sql","parallel":"u","arg_modes":null,"arg_names":["p_actor","p_source","p_ability","p_defense"],"arg_types":"2950 25 2950 16","leakproof":false,"signature":"public.combat_v2_actor_ability(uuid,text,uuid,boolean)","volatility":"s"}},{"oid":"31326","signature":"public.combat_v2_defense_declare(uuid,uuid,uuid,jsonb,text,uuid)","source_md5":"446494ad3becd44a65b241967810e589","ddl_md5":"5a97231f154dab9e97c2a03b0cc142ac","abi":{"acl":"{postgres=X/postgres,authenticated=X/postgres,service_role=X/postgres}","oid":"31326","kind":"f","owner":"postgres","config":["search_path=\"\""],"secdef":true,"strict":false,"nspname":"public","proname":"combat_v2_defense_declare","returns":"jsonb","language":"plpgsql","parallel":"u","arg_modes":null,"arg_names":["p_round","p_attack_declaration","p_actor","p_intent","p_text","p_request_key"],"arg_types":"2950 2950 2950 3802 25 2950","leakproof":false,"signature":"public.combat_v2_defense_declare(uuid,uuid,uuid,jsonb,text,uuid)","volatility":"v"}},{"oid":"31331","signature":"public.combat_v2_round_resolve(uuid,uuid)","source_md5":"ea91dd6deeaf06dc059adadfaafd9e95","ddl_md5":"8a9ec59917bb8802f796cc125e9d1e06","abi":{"acl":"{postgres=X/postgres,service_role=X/postgres,authenticated=X/postgres}","oid":"31331","kind":"f","owner":"postgres","config":["search_path=\"\""],"secdef":true,"strict":false,"nspname":"public","proname":"combat_v2_round_resolve","returns":"jsonb","language":"plpgsql","parallel":"u","arg_modes":null,"arg_names":["p_round","p_request_key"],"arg_types":"2950 2950","leakproof":false,"signature":"public.combat_v2_round_resolve(uuid,uuid)","volatility":"v"}},{"oid":"19700","signature":"public.post_heal(uuid,uuid)","source_md5":"dcde447ee079472efa4fd41c1c911633","ddl_md5":"9fb236d5f72312f6fb33587a2981e427","abi":{"acl":"{postgres=X/postgres,service_role=X/postgres,authenticated=X/postgres}","oid":"19700","kind":"f","owner":"postgres","config":["search_path=public"],"secdef":true,"strict":false,"nspname":"public","proname":"post_heal","returns":"text","language":"plpgsql","parallel":"u","arg_modes":null,"arg_names":["p_location","p_target_user"],"arg_types":"2950 2950","leakproof":false,"signature":"public.post_heal(uuid,uuid)","volatility":"v"}}],"private_functions":[{"signature":"combat_panel_private.catalog_lifecycle_lines_v1(jsonb,jsonb)","source_md5":"8a472424ef8d1bc4d04283d18a0d049e"},{"signature":"combat_panel_private.catalog_result_label_v1(jsonb)","source_md5":"eb0798e0d80f5b1215949f4d6d6445bd"},{"signature":"combat_panel_private.cure_bind_v1(uuid)","source_md5":"a9c1bde3a9b0de30c44312b12be60eff"},{"signature":"combat_panel_private.cure_commit_v1(jsonb)","source_md5":"61532836e90ed32ae807b92ee6632b71"},{"signature":"combat_panel_private.cure_contact_v1(uuid,uuid)","source_md5":"21de7dd5e62b5403b50065d2635e20bf"},{"signature":"combat_panel_private.cure_declaration_meta_v1(uuid,uuid,uuid,jsonb)","source_md5":"9fdec7a42f67372bc1f2e2f408f16ba1"},{"signature":"combat_panel_private.cure_defense_guard_v1()","source_md5":"72b7362b50720f93672dfa1ab96338bc"},{"signature":"combat_panel_private.cure_frozen_turn_valid_v1(uuid,uuid)","source_md5":"7785ea336dd4a1deb9dd19487756d638"},{"signature":"combat_panel_private.cure_narrative_facts_v1(uuid)","source_md5":"a32f97cddb31ccf9581ba328f1e94e49"},{"signature":"combat_panel_private.cure_neutral_preset_v1(uuid,uuid,uuid,jsonb)","source_md5":"dd236ae4c47770d25fd79cb2e9707d1f"},{"signature":"combat_panel_private.cure_note_voluntary_v1(uuid,uuid,text,text)","source_md5":"669353b795c5f327bdcd338c9990716d"},{"signature":"combat_panel_private.cure_offers_v1(uuid,bigint,jsonb)","source_md5":"db137b63815164ffd8435bcf87ce245c"},{"signature":"combat_panel_private.cure_persistent_execution_scope_v1(uuid)","source_md5":"ea6a91fa5940c0d3680a36c4ee962880"},{"signature":"combat_panel_private.cure_persistent_scope_v1(uuid)","source_md5":"4fdb37eb54e15b3da2845a41809ccc57"},{"signature":"combat_panel_private.cure_prepare_v1(uuid,uuid,uuid,uuid)","source_md5":"bf7f19036a2846412374c68950126ac5"},{"signature":"combat_panel_private.cure_profile_v1(uuid)","source_md5":"88ec3750ea8aa0661eaa573747325e87"},{"signature":"combat_panel_private.cure_resolve_v1(uuid)","source_md5":"d385538828e19526af5e59dc8d18f167"},{"signature":"combat_panel_private.cure_staff_execution_scope_v1(uuid)","source_md5":"9adc4dfa74e700f54ba58d8691fb8f76"},{"signature":"combat_panel_private.cure_staff_scope_v1(uuid)","source_md5":"343140ae23ba4787fa511d1e6f27092e"},{"signature":"combat_panel_private.cure_turn_clear_v1(uuid,uuid)","source_md5":"ff5fac17361830d01e19aeba05430328"},{"signature":"combat_panel_private.cure_turn_used_v1(uuid,uuid)","source_md5":"11badbd523e79faba44fa282150be54b"},{"signature":"combat_panel_private.cure_voluntary_receipt_guard_v1()","source_md5":"08bacb86944bec00bc213eddf9815dca"},{"signature":"combat_v2_genjutsu_internal.actor_meta(uuid)","source_md5":"df3798ced5e32f7cb5aef4283fd88a00"},{"signature":"combat_v2_genjutsu_internal.ally_contact(uuid,uuid)","source_md5":"32dcc6e95e61d7e9fe2389a398a07334"},{"signature":"combat_v2_genjutsu_internal.bind_release(uuid)","source_md5":"1c6bfe3e32950c77afbb8c7b91a21078"},{"signature":"combat_v2_genjutsu_internal.bind_source(uuid)","source_md5":"80c79fc14b48e386b5920d021d537ba7"},{"signature":"combat_v2_genjutsu_internal.binding(uuid)","source_md5":"404fc795700a7fbe3334464c97a5058b"},{"signature":"combat_v2_genjutsu_internal.comparison(uuid,uuid,jsonb)","source_md5":"e63a4943d52d01b719d9693039c18d6c"},{"signature":"combat_v2_genjutsu_internal.consumer_options(jsonb)","source_md5":"c8daec5fcb19dc88267f7ceab87a2be8"},{"signature":"combat_v2_genjutsu_internal.declaration_events(uuid)","source_md5":"194b5c80d8e4779c66f0fdb8c50f1de3"},{"signature":"combat_v2_genjutsu_internal.declaration_meta(uuid,uuid,uuid,jsonb)","source_md5":"1dadbb12c0a1965b0461133ca0efc5d3"},{"signature":"combat_v2_genjutsu_internal.decorate_outcome(uuid,uuid,jsonb)","source_md5":"d0160238be06fafb4ce521553d4e745a"},{"signature":"combat_v2_genjutsu_internal.defense_intent_allowed(uuid,jsonb)","source_md5":"bf261ee2a0f55a52a8bb9462333058bd"},{"signature":"combat_v2_genjutsu_internal.end_context(uuid,uuid)","source_md5":"9d931f4ac19d9170e6119458d4825b23"},{"signature":"combat_v2_genjutsu_internal.event_binding(uuid,jsonb)","source_md5":"8b3b23a81afc7c2092902373cedbe0d2"},{"signature":"combat_v2_genjutsu_internal.event_public(text)","source_md5":"ecaea9744e8960072a32e7908856f9c0"},{"signature":"combat_v2_genjutsu_internal.kai_defense_valid(uuid,uuid)","source_md5":"1ab8564f473d8a008ba29e8095a4a6de"},{"signature":"combat_v2_genjutsu_internal.master_options(uuid,bigint)","source_md5":"c9fbd722ccef5bc57cbabb67651a788f"},{"signature":"combat_v2_genjutsu_internal.movement_blocked(uuid)","source_md5":"8a243e907877525d58c71429cfbb8f98"},{"signature":"combat_v2_genjutsu_internal.narrative_facts(uuid)","source_md5":"de22bbd83e9ab8edb6a025e5131edde0"},{"signature":"combat_v2_genjutsu_internal.narrative_supported(uuid)","source_md5":"8c498c00f438621c617ae6132318ab66"},{"signature":"combat_v2_genjutsu_internal.open_turn(uuid,uuid)","source_md5":"701defaed0c81b0a6f4ccef2857a4a42"},{"signature":"combat_v2_genjutsu_internal.panel_options(uuid,bigint)","source_md5":"cb344a077d919955ef0f570ba9313d35"},{"signature":"combat_v2_genjutsu_internal.prepare(uuid,uuid,uuid,jsonb)","source_md5":"7275b845d7140c81fd2ec2ac48d3cd91"},{"signature":"combat_v2_genjutsu_internal.preset_ready(uuid)","source_md5":"b087938ff9bdc51ee5518c72beb88c04"},{"signature":"combat_v2_genjutsu_internal.profile()","source_md5":"87cf137eefa6f81cd178c039859c1c45"},{"signature":"combat_v2_genjutsu_internal.quote(uuid)","source_md5":"28ff62253407034032035e6acd8a2b6b"},{"signature":"combat_v2_genjutsu_internal.raw_attack_facts(uuid)","source_md5":"da147cc5595cac875224cbbebfe82ef8"},{"signature":"combat_v2_genjutsu_internal.real_owned(uuid)","source_md5":"f6e8ecb85aeb3c938cdc71eb0cbf80cd"},{"signature":"combat_v2_genjutsu_internal.record_event(text,uuid,jsonb)","source_md5":"9ba46dc99acb5e3063e0d813b55d0f3f"},{"signature":"combat_v2_genjutsu_internal.release_intents(uuid)","source_md5":"269945acde9a25aa53dc34e473366430"},{"signature":"combat_v2_genjutsu_internal.release_meta(uuid,uuid,uuid,jsonb)","source_md5":"9ebfc24d33a07eeb5b9a59eb85fd694e"},{"signature":"combat_v2_genjutsu_internal.report_facts(uuid)","source_md5":"03c90f3dd07812d1061c7037216304d9"},{"signature":"combat_v2_genjutsu_internal.report_projection(uuid)","source_md5":"d3c2e36c0248730650a6c6c4b34d1e47"},{"signature":"combat_v2_genjutsu_internal.resolution_enter(uuid,uuid)","source_md5":"c45574805f3171628ef99392fa255eb2"},{"signature":"combat_v2_genjutsu_internal.resolution_leave()","source_md5":"612f97c08785e572226423ed5c1f68ed"},{"signature":"combat_v2_genjutsu_internal.resolve_release(uuid)","source_md5":"0e5d351b87010bb3eaa271cb63099661"},{"signature":"combat_v2_genjutsu_internal.runtime_allowed(uuid)","source_md5":"8512b2d982094a3b339de4ec3bfd3327"},{"signature":"combat_v2_genjutsu_internal.scope(uuid)","source_md5":"ca9d5c5a82c1eeb64af358016ac50c1f"},{"signature":"combat_v2_genjutsu_internal.source_valid(uuid)","source_md5":"84ca595cfd34b8467b69c0256e94e254"},{"signature":"combat_v2_genjutsu_internal.staff_bind(uuid,uuid)","source_md5":"b8b6261b5c8f7df3c91400d5969d8eae"},{"signature":"combat_v2_genjutsu_internal.success(jsonb,integer,boolean)","source_md5":"90faca8a42e9f7f54726276f5a1e94bf"},{"signature":"combat_v2_genjutsu_internal.turn_end(uuid,uuid,uuid,text)","source_md5":"5130f380992a3585b502934e2833e716"},{"signature":"combat_v2_genjutsu_internal.turn_start(uuid,uuid,uuid,text)","source_md5":"b1781f3637f8c3414a9dd2c4038869c2"},{"signature":"combat_v2_genjutsu_internal.validate_attack_facts(jsonb)","source_md5":"0c6434b64a325213dbf8d18c603ed061"},{"signature":"combat_v2_genjutsu_internal.validate_release_facts(jsonb)","source_md5":"a46a047fa733321603e24a6102d7183d"}],"relations":[{"name":"combat_panel_private.cure_gate_v1","columns":[{"name":"singleton","type":"boolean","not_null":true,"default":"true"},{"name":"staff_enabled","type":"boolean","not_null":true,"default":"false"},{"name":"public_enabled","type":"boolean","not_null":true,"default":"false"},{"name":"contract_version","type":"text","not_null":true,"default":"'palmo-curativo/1'::text"}]},{"name":"combat_panel_private.cure_ledger_v1","columns":[{"name":"declaration_id","type":"uuid","not_null":true,"default":null},{"name":"session_id","type":"uuid","not_null":true,"default":null},{"name":"round_id","type":"uuid","not_null":true,"default":null},{"name":"actor_id","type":"uuid","not_null":true,"default":null},{"name":"target_actor_id","type":"uuid","not_null":true,"default":null},{"name":"hp_before","type":"integer","not_null":true,"default":null},{"name":"hp_after","type":"integer","not_null":true,"default":null},{"name":"hp_max","type":"integer","not_null":true,"default":null},{"name":"expected_gain","type":"integer","not_null":true,"default":null},{"name":"committed_gain","type":"integer","not_null":true,"default":null},{"name":"applied_real_gain","type":"integer","not_null":true,"default":"0"},{"name":"is_simulated","type":"boolean","not_null":true,"default":null},{"name":"facts","type":"jsonb","not_null":true,"default":null},{"name":"created_at","type":"timestamp with time zone","not_null":true,"default":"clock_timestamp()"}]},{"name":"combat_panel_private.cure_preparations_v1","columns":[{"name":"request_key","type":"uuid","not_null":true,"default":null},{"name":"transaction_id","type":"bigint","not_null":true,"default":null},{"name":"session_id","type":"uuid","not_null":true,"default":null},{"name":"round_id","type":"uuid","not_null":true,"default":null},{"name":"actor_id","type":"uuid","not_null":true,"default":null},{"name":"target_actor_id","type":"uuid","not_null":true,"default":null},{"name":"controller_user","type":"uuid","not_null":true,"default":null},{"name":"controller_version","type":"bigint","not_null":true,"default":null},{"name":"source","type":"jsonb","not_null":true,"default":null},{"name":"source_sha256","type":"text","not_null":true,"default":null},{"name":"declaration_id","type":"uuid","not_null":false,"default":null},{"name":"created_at","type":"timestamp with time zone","not_null":true,"default":"clock_timestamp()"}]},{"name":"combat_panel_private.cure_staff_profiles_v1","columns":[{"name":"actor_id","type":"uuid","not_null":true,"default":null},{"name":"session_id","type":"uuid","not_null":true,"default":null},{"name":"context_id","type":"uuid","not_null":true,"default":null},{"name":"controller_user","type":"uuid","not_null":true,"default":null},{"name":"controller_version","type":"bigint","not_null":true,"default":null},{"name":"ability","type":"jsonb","not_null":true,"default":null},{"name":"proof_sha256","type":"text","not_null":true,"default":null},{"name":"request_key","type":"uuid","not_null":true,"default":null},{"name":"created_at","type":"timestamp with time zone","not_null":true,"default":"clock_timestamp()"}]},{"name":"combat_panel_private.cure_voluntary_actions_v1","columns":[{"name":"actor_id","type":"uuid","not_null":true,"default":null},{"name":"round_id","type":"uuid","not_null":true,"default":null},{"name":"source_kind","type":"text","not_null":true,"default":null},{"name":"source_key","type":"text","not_null":true,"default":null},{"name":"created_at","type":"timestamp with time zone","not_null":true,"default":"clock_timestamp()"}]},{"name":"combat_v2_genjutsu_internal.effects","columns":[{"name":"id","type":"uuid","not_null":true,"default":"gen_random_uuid()"},{"name":"session_id","type":"uuid","not_null":true,"default":null},{"name":"source_declaration_id","type":"uuid","not_null":true,"default":null},{"name":"source_attack_target_id","type":"uuid","not_null":true,"default":null},{"name":"source_actor_id","type":"uuid","not_null":true,"default":null},{"name":"target_actor_id","type":"uuid","not_null":true,"default":null},{"name":"profile","type":"jsonb","not_null":true,"default":null},{"name":"source_outcome_sha256","type":"text","not_null":true,"default":null},{"name":"adapter","type":"text","not_null":true,"default":null},{"name":"excluded_turn_id","type":"uuid","not_null":false,"default":null},{"name":"due_turn_id","type":"uuid","not_null":false,"default":null},{"name":"state","type":"text","not_null":true,"default":null},{"name":"state_version","type":"bigint","not_null":true,"default":"1"},{"name":"created_at","type":"timestamp with time zone","not_null":true,"default":"clock_timestamp()"},{"name":"ended_at","type":"timestamp with time zone","not_null":false,"default":null},{"name":"end_reason","type":"text","not_null":false,"default":null}]},{"name":"combat_v2_genjutsu_internal.events","columns":[{"name":"event_key","type":"text","not_null":true,"default":null},{"name":"effect_id","type":"uuid","not_null":false,"default":null},{"name":"result","type":"jsonb","not_null":true,"default":null},{"name":"result_sha256","type":"text","not_null":true,"default":null},{"name":"binding","type":"jsonb","not_null":true,"default":null},{"name":"binding_sha256","type":"text","not_null":true,"default":null},{"name":"created_at","type":"timestamp with time zone","not_null":true,"default":"clock_timestamp()"}]},{"name":"combat_v2_genjutsu_internal.gate","columns":[{"name":"singleton","type":"boolean","not_null":true,"default":null},{"name":"enabled","type":"boolean","not_null":true,"default":null},{"name":"staff_enabled","type":"boolean","not_null":true,"default":null},{"name":"public_enabled","type":"boolean","not_null":true,"default":null},{"name":"version","type":"integer","not_null":true,"default":null}]},{"name":"combat_v2_genjutsu_internal.preparations","columns":[{"name":"actor_id","type":"uuid","not_null":true,"default":null},{"name":"round_id","type":"uuid","not_null":true,"default":null},{"name":"request_id","type":"uuid","not_null":true,"default":null},{"name":"transaction_id","type":"bigint","not_null":true,"default":null},{"name":"source","type":"jsonb","not_null":true,"default":null},{"name":"source_sha256","type":"text","not_null":true,"default":null}]},{"name":"combat_v2_genjutsu_internal.release_plans","columns":[{"name":"actor_id","type":"uuid","not_null":true,"default":null},{"name":"round_id","type":"uuid","not_null":true,"default":null},{"name":"request_id","type":"uuid","not_null":true,"default":null},{"name":"effect_id","type":"uuid","not_null":true,"default":null},{"name":"source","type":"jsonb","not_null":true,"default":null},{"name":"source_sha256","type":"text","not_null":true,"default":null},{"name":"transaction_id","type":"bigint","not_null":true,"default":null},{"name":"declaration_id","type":"uuid","not_null":false,"default":null},{"name":"declaration_sha256","type":"text","not_null":false,"default":null},{"name":"result","type":"jsonb","not_null":false,"default":null},{"name":"result_sha256","type":"text","not_null":false,"default":null}]},{"name":"combat_v2_genjutsu_internal.sources","columns":[{"name":"declaration_id","type":"uuid","not_null":true,"default":null},{"name":"session_id","type":"uuid","not_null":true,"default":null},{"name":"source","type":"jsonb","not_null":true,"default":null},{"name":"declaration_sha256","type":"text","not_null":true,"default":null},{"name":"source_sha256","type":"text","not_null":true,"default":null}]},{"name":"combat_v2_genjutsu_internal.staff_receipts","columns":[{"name":"actor_id","type":"uuid","not_null":true,"default":null},{"name":"session_id","type":"uuid","not_null":true,"default":null},{"name":"controller_user","type":"uuid","not_null":true,"default":null},{"name":"controller_version","type":"bigint","not_null":true,"default":null},{"name":"request_id","type":"uuid","not_null":true,"default":null},{"name":"receipt","type":"jsonb","not_null":true,"default":null},{"name":"receipt_sha256","type":"text","not_null":true,"default":null}]}],"triggers":[{"table":"clan_akimichi_private.form_commands","name":"cure_voluntary_receipt_v1","function":"combat_panel_private.cure_voluntary_receipt_guard_v1()","type":7},{"table":"clan_hoki_private.combat_events","name":"cure_voluntary_receipt_v1","function":"combat_panel_private.cure_voluntary_receipt_guard_v1()","type":7},{"table":"clan_innata_combat_private.combat_receipts","name":"cure_voluntary_receipt_v1","function":"combat_panel_private.cure_voluntary_receipt_guard_v1()","type":7},{"table":"clan_inuzuka_private.movement_receipts","name":"cure_voluntary_receipt_v1","function":"combat_panel_private.cure_voluntary_receipt_guard_v1()","type":7},{"table":"clan_marionettisti_private.control_events","name":"cure_voluntary_receipt_v1","function":"combat_panel_private.cure_voluntary_receipt_guard_v1()","type":7},{"table":"clan_marionettisti_private.movement_receipts","name":"cure_voluntary_receipt_v1","function":"combat_panel_private.cure_voluntary_receipt_guard_v1()","type":7},{"table":"clan_sabaku_private.armor_events","name":"cure_voluntary_receipt_v1","function":"combat_panel_private.cure_voluntary_receipt_guard_v1()","type":7},{"table":"combat_panel_private.master_movement_receipts","name":"cure_voluntary_receipt_v1","function":"combat_panel_private.cure_voluntary_receipt_guard_v1()","type":7},{"table":"combat_panel_private.request_receipts","name":"cure_voluntary_receipt_v1","function":"combat_panel_private.cure_voluntary_receipt_guard_v1()","type":7},{"table":"public.combat_v2_declarations","name":"cure_turn_defense_guard_v1","function":"combat_panel_private.cure_defense_guard_v1()","type":7}],"native_functions":[{"signature":"public.combat_v2_substitution_options_v1(uuid)","source_md5":"913cfd7a596794334b9b3ec8baa103a2","owner":"postgres","acl":"{postgres=X/postgres,authenticated=X/postgres}","config":["search_path=\"\""],"secdef":true,"volatility":"v","strict":false,"parallel":"u","language":"plpgsql","returns":"jsonb","arg_names":["p_attack_declaration"],"arg_modes":null,"arg_types":"2950","ddl_md5":"1dc4d3088d39991411d875ec662c5123"},{"signature":"public.combat_v2_substitution_round_offers_v1(uuid,uuid)","source_md5":"7f3c2e198105d066aceb762872f51a3d","owner":"postgres","acl":"{postgres=X/postgres,authenticated=X/postgres}","config":["search_path=\"\""],"secdef":true,"volatility":"v","strict":false,"parallel":"u","language":"plpgsql","returns":"jsonb","arg_names":["p_round","p_actor"],"arg_modes":null,"arg_types":"2950 2950","ddl_md5":"3a2b1781cc15da44f69cb940e527e864"},{"signature":"public.combat_v2_substitution_select_v1(uuid,uuid)","source_md5":"209648a06d537ad5b8870bdf8fe5c4cb","owner":"postgres","acl":"{postgres=X/postgres,authenticated=X/postgres}","config":["search_path=\"\""],"secdef":true,"volatility":"v","strict":false,"parallel":"u","language":"plpgsql","returns":"jsonb","arg_names":["p_substitution_option_id","p_request_key"],"arg_modes":null,"arg_types":"2950 2950","ddl_md5":"f2f454ef2248e5f310fdfade6e868657"}]}$compat_metadata$::jsonb;
 shared_manifest jsonb:='[]';private_manifest jsonb:='[]';relation_manifest jsonb:='[]';trigger_manifest jsonb:='[]';
 native_manifest jsonb:='[]';changed_manifest jsonb;item jsonb;h jsonb;abi jsonb;cols jsonb;descriptor jsonb;next_descriptor jsonb;kv record;
 relation_oid oid;function_oid oid;actual_count integer;aliases integer:=0;
 shared_sha text;private_sha text;relations_sha text;
 pending_paths text[]:=ARRAY['["db_core"]'];current_path text[];stack_size integer;
BEGIN
 SELECT * INTO STRICT rr FROM mission_factory_owner.editor_release_readiness WHERE singleton;
 root:=rr.canonical_preimage::jsonb;binding:=root#>'{db_core,catalogo_eligibility_compat}';
 -- Legacy/recovery non acquisisce un PASS dal nuovo ramo: resta il sigillo storico completo.
 IF binding IS NULL OR binding->>'state'='inert_recovery' THEN RETURN false;END IF;
 IF binding->>'schema_version'IS DISTINCT FROM 'catalogo-eligibility-compat/1'
 OR binding->>'state'IS DISTINCT FROM 'active_compatibility'
 OR binding->>'parent_root'IS DISTINCT FROM 'f460be0a321e1640d7993a15285cf1b6352166cda41e991f0c644f29bd6a3658'
 OR binding->>'base_catalogo_source_bundle_sha256'IS DISTINCT FROM '825a1c14a59281fb3168430a993e9f2dbbbc41042f5169638d2e9c1e8e9868a5'
 OR coalesce(binding->>'source_bundle_sha256','')!~'^[0-9a-f]{64}$'
 OR coalesce(binding#>>'{review,sha256}','')!~'^[0-9a-f]{64}$'OR nullif(binding#>>'{review,ref}','')IS NULL
 OR binding#>'{review,P0}'IS DISTINCT FROM '0'::jsonb OR binding#>'{review,P1}'IS DISTINCT FROM '0'::jsonb OR binding#>'{review,P2}'IS DISTINCT FROM '0'::jsonb
 OR rr.state NOT IN('enabled','prepared')OR rr.scope<>'staff'OR NOT rr.staff_guards_verified OR NOT rr.published_assets_verified
 OR rr.observed_revision_sha256 IS DISTINCT FROM rr.revision_sha256
 OR encode(extensions.digest(convert_to(rr.canonical_preimage,'UTF8'),'sha256'),'hex')IS DISTINCT FROM rr.revision_sha256
 OR octet_length(rr.canonical_preimage)>524288
 OR root#>>'{db_core,sha256}'IS DISTINCT FROM public.combat_v2_sha256((root->'db_core')-'sha256')
 OR root#>>'{config,sha256}'IS DISTINCT FROM public.combat_v2_sha256((root->'config')-'sha256')
 OR root#>>'{db_core,catalogo_completo,source_bundle_sha256}'IS DISTINCT FROM binding->>'base_catalogo_source_bundle_sha256'
 OR root#>'{config,catalogo_eligibility_compat}'IS DISTINCT FROM binding
 THEN RAISE EXCEPTION 'catalogo_eligibility_root_admission_drift';END IF;
 IF binding->>'normalized_source_identity_sha256'IS DISTINCT FROM '17fd985dfe72c4c6ad3638c01ad019a1f3deb1c21f587a6a0e98c39458e6550f'
 OR public.combat_v2_sha256(binding->'normalized_source_identity')IS DISTINCT FROM binding->>'normalized_source_identity_sha256'
 THEN RAISE EXCEPTION 'catalogo_eligibility_peer_identity_drift';END IF;
 IF EXISTS(WITH expected(sig,sha,acl)AS(VALUES ('combat_panel_private.mask_native_state(jsonb)','1d2f6ad44b2ff1e9c15d897e38fee54b67c744411081f906bc33a26a42600dac','postgres:EXECUTE:false'),('combat_v2_elemental_internal.other_ability_meta(uuid,jsonb)','15fab8ec94575b4a0e163cfbdcc46272b02d47d772daa262de5483a43b18f5ac','postgres:EXECUTE:false'),('combat_panel_private.round_options_authoritative(uuid,uuid)','22bd8c8faf60ba44a644bf9ccd0f69ab8a5715383c79ff6014509dfd02290554','postgres:EXECUTE:false'),('combat_v2_elemental_internal.eligible_v1(uuid,uuid,boolean)','a5161f2993a4e0ce51864ac67ea88ba3fa6966457da1caf4ca390f17c2b1d8e9','postgres:EXECUTE:false,service_role:EXECUTE:false'),('combat_v2_elemental_internal.is_target_v1(uuid)','8af6bdfc87b76ed118b596f7c7885c6de849c5d89140f61cdd1845047cbd5724','postgres:EXECUTE:false,service_role:EXECUTE:false'),('public.combat_v2_actor_ability(uuid,text,uuid,boolean)','31512f4525275b901ce810f8d23d15a3221091ae6a0f062c40a8d4232c038748','postgres:EXECUTE:false,service_role:EXECUTE:false'),('public.combat_v2_character_snapshot(uuid)','9d97f3d6acd6f723f82b51723be91d0a185ee1be1b8060f5bd9d41379d65ea1d','postgres:EXECUTE:false,service_role:EXECUTE:false'),('public.combat_v2_round_options(uuid,uuid)','0b3acc15933027fa840ca03c0d02f082aecf6f2ccedcdefd737127bed1d853d1','authenticated:EXECUTE:false,postgres:EXECUTE:false,service_role:EXECUTE:false'))SELECT 1 FROM expected e LEFT JOIN pg_proc p ON p.oid=to_regprocedure(e.sig)
 WHERE p.oid IS NULL OR encode(extensions.digest(convert_to(pg_get_functiondef(p.oid),'UTF8'),'sha256'),'hex')IS DISTINCT FROM e.sha
 OR p.proowner IS DISTINCT FROM 'postgres'::regrole OR p.prosecdef IS DISTINCT FROM true OR p.proconfig IS DISTINCT FROM ARRAY['search_path=""']
 OR(SELECT string_agg(coalesce(r.rolname,'PUBLIC')||':'||x.privilege_type||':'||x.is_grantable,','ORDER BY coalesce(r.rolname,'PUBLIC'),x.privilege_type,x.is_grantable)
 FROM aclexplode(coalesce(p.proacl,acldefault('f',p.proowner)))x LEFT JOIN pg_roles r ON r.oid=x.grantee)IS DISTINCT FROM e.acl)
 THEN RAISE EXCEPTION 'catalogo_eligibility_owning_port_drift';END IF;
 amendment:=root#>'{db_core,cure_command_amendment}';
 IF amendment->>'schema_version'IS DISTINCT FROM 'cure-command-amendment/1'OR coalesce(amendment->>'state','')NOT IN('active_amendment','inert_recovery')
 OR amendment->>'active_repair_kind'IS DISTINCT FROM 'paralisi-label-dispatch/1'
 OR amendment->>'commit_source_md5'IS DISTINCT FROM '61532836e90ed32ae807b92ee6632b71'
 OR amendment->>'neutral_source_md5'IS DISTINCT FROM 'dd236ae4c47770d25fd79cb2e9707d1f'
 OR amendment->>'normalized_source_identity_sha256'IS DISTINCT FROM 'e15919762cc27a609fa6938653354e0e1e328c0cabfa4914378fb03d908c7338'
 OR public.combat_v2_sha256(amendment->'normalized_source_identity')IS DISTINCT FROM amendment->>'normalized_source_identity_sha256'
 OR amendment->>'base_catalogo_source_bundle_sha256'IS DISTINCT FROM '825a1c14a59281fb3168430a993e9f2dbbbc41042f5169638d2e9c1e8e9868a5'
 OR amendment->>'base_compat_source_bundle_sha256'IS DISTINCT FROM binding->>'source_bundle_sha256'
 OR amendment->>'base_compat_source_bundle_sha256'IS DISTINCT FROM '654f8fff2f42019ffc4b3ccc6c467fff443ba81f00c7aa020fbd6d7950e2445e'
 OR amendment->>'base_private_functions_manifest_sha256'IS DISTINCT FROM root#>>'{db_core,catalogo_completo,private_functions_manifest_sha256}'
 OR coalesce(amendment->>'source_bundle_sha256','')!~'^[0-9a-f]{64}$'
 OR binding->>'active_amendment_source_bundle_sha256'IS DISTINCT FROM amendment->>'source_bundle_sha256'
 OR root#>'{config,cure_command_amendment}'IS DISTINCT FROM amendment
 OR coalesce(amendment#>>'{review,sha256}','')!~'^[0-9a-f]{64}$'OR nullif(amendment#>>'{review,ref}','')IS NULL
 OR amendment#>'{review,P0}'IS DISTINCT FROM '0'::jsonb OR amendment#>'{review,P1}'IS DISTINCT FROM '0'::jsonb OR amendment#>'{review,P2}'IS DISTINCT FROM '0'::jsonb
 THEN RAISE EXCEPTION 'cure_command_active_amendment_drift';END IF;
 IF amendment->>'state'='inert_recovery'AND NOT EXISTS(SELECT 1 FROM combat_panel_private.cure_gate_v1 WHERE singleton AND NOT staff_enabled AND NOT public_enabled)THEN RAISE EXCEPTION 'cure_neutral_inert_requires_cure_off';END IF;
 -- The label formatter is outside the historic34/66 domains: its exact
 -- DDL/ACL is covered by the owning-port pins above, not a generic grant.
 IF root#>>'{db_core,paralisi_label,schema_version}' IS DISTINCT FROM 'paralisi-label/1'
 OR root#>'{config,paralisi_label}' IS DISTINCT FROM root#>'{db_core,paralisi_label}'
 OR root#>>'{db_core,paralisi_label,leaf_sha256}' IS DISTINCT FROM '0705927fad1de34d8422b68fb4eda5c96fc7b000a77367a3a8ec0e9d15cfa02f'
 OR root#>>'{db_core,paralisi_label,source_bundle_sha256}' IS DISTINCT FROM amendment->>'source_bundle_sha256'
 OR root#>'{db_core,paralisi_label,review}' IS DISTINCT FROM amendment->'review'
 THEN RAISE EXCEPTION 'paralisi_label_root_binding_drift';END IF;
 -- Snapshot condiviso DOPO i delta PM. Nessuna esecuzione di corpi storici.
 FOR item IN SELECT value FROM jsonb_array_elements(params->'shared_functions') ORDER BY value->>'signature' LOOP
  SELECT jsonb_build_object('oid',p.oid::text,'signature',p.oid::regprocedure::text,
   'source_md5',md5(p.prosrc),'ddl_md5',md5(pg_get_functiondef(p.oid)),
   'owner',pg_get_userbyid(p.proowner),'acl',p.proacl::text,'config',p.proconfig,'secdef',p.prosecdef,
   'volatility',p.provolatile::text,'language',l.lanname,'strict',p.proisstrict,'parallel',p.proparallel::text,
   'kind',p.prokind::text,'returns',pg_get_function_result(p.oid),'arg_names',p.proargnames,'arg_modes',p.proargmodes,
   'arg_types',p.proargtypes::text,'leakproof',p.proleakproof,'nspname',n.nspname,'proname',p.proname)
   INTO h FROM pg_proc p JOIN pg_namespace n ON n.oid=p.pronamespace JOIN pg_language l ON l.oid=p.prolang
   WHERE p.oid=to_regprocedure(item->>'signature') AND p.prokind='f';
  IF h IS NULL OR h->>'oid' IS DISTINCT FROM item->>'oid'
  OR h->>'source_md5' IS DISTINCT FROM item->>'source_md5' OR h->>'ddl_md5' IS DISTINCT FROM item->>'ddl_md5'
  OR h-ARRAY['source_md5','ddl_md5'] IS DISTINCT FROM item->'abi' THEN
   RAISE EXCEPTION 'CATALOGO_ROOT_SHARED_ABI_OR_BODY_DRIFT:%',item->>'signature';END IF;
  shared_manifest:=shared_manifest||jsonb_build_array(h);
 END LOOP;
 IF (SELECT count(DISTINCT value->>'oid') FROM jsonb_array_elements(shared_manifest))<>jsonb_array_length(shared_manifest) THEN
  RAISE EXCEPTION 'CATALOGO_ROOT_DUPLICATE_SHARED_OID';END IF;
 -- Stack di soli percorsi: non replica l'intera Root in righe o gruppi SQL.
 WHILE coalesce(cardinality(pending_paths),0)>0 LOOP
  stack_size:=cardinality(pending_paths);
  SELECT ARRAY(SELECT jsonb_array_elements_text(pending_paths[stack_size]::jsonb)) INTO current_path;
  pending_paths:=pending_paths[1:stack_size-1];descriptor:=root#>current_path;
  IF jsonb_typeof(descriptor)='object' THEN
   SELECT value INTO h FROM jsonb_array_elements(shared_manifest) WHERE value->>'oid'=descriptor->>'oid';
   IF descriptor ? 'oid' AND h IS NOT NULL THEN
    FOR kv IN SELECT key,value FROM jsonb_each(descriptor) WHERE key=ANY(ARRAY['owner','acl','config','secdef','strict','language','parallel','arg_modes','arg_names','arg_types','leakproof','returns','volatility','kind','signature','nspname','proname']) LOOP
     IF kv.value IS DISTINCT FROM h->kv.key THEN RAISE EXCEPTION 'CATALOGO_ROOT_ALIAS_ABI_DRIFT:%',array_to_string(current_path,'.');END IF;
    END LOOP;
    next_descriptor:=descriptor;
    IF descriptor ? 'source_md5' THEN next_descriptor:=jsonb_set(next_descriptor,'{source_md5}',h->'source_md5',false);END IF;
    IF descriptor ? 'ddl_md5' THEN next_descriptor:=jsonb_set(next_descriptor,'{ddl_md5}',h->'ddl_md5',false);END IF;
    IF next_descriptor IS DISTINCT FROM descriptor THEN RAISE EXCEPTION 'catalogo_eligibility_root_alias_drift';END IF;
    root:=jsonb_set(root,current_path,next_descriptor,false);aliases:=aliases+1;
   ELSE
    FOR kv IN SELECT key,value FROM jsonb_each(descriptor) WHERE jsonb_typeof(value)IN('object','array') LOOP
     pending_paths:=array_append(pending_paths,to_jsonb(array_append(current_path,kv.key))::text);
    END LOOP;
   END IF;
  ELSIF jsonb_typeof(descriptor)='array' THEN
   FOR kv IN SELECT(ord-1)::text AS key,value FROM jsonb_array_elements(descriptor)WITH ORDINALITY x(value,ord)
    WHERE jsonb_typeof(value)IN('object','array') LOOP
    pending_paths:=array_append(pending_paths,to_jsonb(array_append(current_path,kv.key))::text);
   END LOOP;
  END IF;
 END LOOP;
 IF aliases IS DISTINCT FROM(params->>'expected_alias_count')::integer THEN RAISE EXCEPTION 'CATALOGO_ROOT_ALIAS_COUNT';END IF;
 shared_sha:=public.combat_v2_sha256(shared_manifest);

 FOR item IN SELECT value FROM jsonb_array_elements(params->'private_functions') ORDER BY value->>'signature' LOOP
  function_oid:=to_regprocedure(item->>'signature');
  SELECT jsonb_build_object('signature',p.oid::regprocedure::text,'source_md5',md5(p.prosrc),'ddl_md5',md5(pg_get_functiondef(p.oid)),
   'owner',pg_get_userbyid(p.proowner),'acl',p.proacl::text,'config',p.proconfig,'secdef',p.prosecdef,
   'volatility',p.provolatile::text,'language',l.lanname,'strict',p.proisstrict,'parallel',p.proparallel::text,
   'returns',pg_get_function_result(p.oid),'arg_names',p.proargnames,'arg_modes',p.proargmodes,'arg_types',p.proargtypes::text)
   INTO h FROM pg_proc p JOIN pg_namespace n ON n.oid=p.pronamespace JOIN pg_language l ON l.oid=p.prolang
   WHERE p.oid=function_oid AND p.prokind='f' AND(n.nspname='combat_v2_genjutsu_internal' OR(n.nspname='combat_panel_private' AND(p.proname LIKE 'cure\_%' ESCAPE '\' OR p.proname IN('catalog_result_label_v1','catalog_lifecycle_lines_v1'))));
  IF h IS NULL OR h->>'source_md5' IS DISTINCT FROM item->>'source_md5' OR h->>'owner'<>'postgres'
   OR has_function_privilege('anon',function_oid,'EXECUTE') OR has_function_privilege('authenticated',function_oid,'EXECUTE') THEN
   RAISE EXCEPTION 'CATALOGO_ROOT_PRIVATE_BODY_OR_PRIVILEGE:%',item->>'signature';END IF;
  private_manifest:=private_manifest||jsonb_build_array(h);
 END LOOP;
 SELECT count(*) INTO actual_count FROM pg_proc p JOIN pg_namespace n ON n.oid=p.pronamespace
  WHERE p.prokind='f' AND(n.nspname='combat_v2_genjutsu_internal' OR(n.nspname='combat_panel_private' AND(p.proname LIKE 'cure\_%' ESCAPE '\' OR p.proname IN('catalog_result_label_v1','catalog_lifecycle_lines_v1'))));
 IF actual_count<>jsonb_array_length(private_manifest)
 OR actual_count<>(SELECT count(DISTINCT value->>'signature')FROM jsonb_array_elements(private_manifest)) THEN
  RAISE EXCEPTION 'CATALOGO_ROOT_PRIVATE_MANIFEST_COVERAGE';END IF;
 private_sha:=public.combat_v2_sha256(private_manifest);

 FOR item IN SELECT value FROM jsonb_array_elements(params->'relations') ORDER BY value->>'name' LOOP
  relation_oid:=to_regclass(item->>'name');
  SELECT jsonb_agg(jsonb_build_object('name',a.attname,'type',format_type(a.atttypid,a.atttypmod),
   'not_null',a.attnotnull,'default',pg_get_expr(d.adbin,d.adrelid))ORDER BY a.attnum) INTO cols
   FROM pg_attribute a LEFT JOIN pg_attrdef d ON d.adrelid=a.attrelid AND d.adnum=a.attnum
   WHERE a.attrelid=relation_oid AND a.attnum>0 AND NOT a.attisdropped;
  SELECT jsonb_build_object('name',n.nspname||'.'||c.relname,'owner',pg_get_userbyid(c.relowner),'acl',c.relacl::text,
   'rls',c.relrowsecurity,'force_rls',c.relforcerowsecurity,'persistence',c.relpersistence::text,'columns',cols,
   'constraints',(SELECT coalesce(jsonb_agg(jsonb_build_object('name',k.conname,'definition',pg_get_constraintdef(k.oid),'validated',k.convalidated)ORDER BY k.conname),'[]')FROM pg_constraint k WHERE k.conrelid=c.oid),
   'indexes',(SELECT coalesce(jsonb_agg(jsonb_build_object('name',ic.relname,'definition',pg_get_indexdef(i.indexrelid),'valid',i.indisvalid)ORDER BY ic.relname),'[]')FROM pg_index i JOIN pg_class ic ON ic.oid=i.indexrelid WHERE i.indrelid=c.oid),
   'policies',(SELECT coalesce(jsonb_agg(jsonb_build_object('name',p.polname,'command',p.polcmd,'roles',p.polroles::text,'using',pg_get_expr(p.polqual,p.polrelid),'check',pg_get_expr(p.polwithcheck,p.polrelid))ORDER BY p.polname),'[]')FROM pg_policy p WHERE p.polrelid=c.oid))
   INTO h FROM pg_class c JOIN pg_namespace n ON n.oid=c.relnamespace WHERE c.oid=relation_oid AND c.relkind IN('r','p')
    AND(n.nspname='combat_v2_genjutsu_internal' OR(n.nspname='combat_panel_private' AND c.relname LIKE 'cure\_%' ESCAPE '\'));
  IF h IS NULL OR h->'rls' IS DISTINCT FROM 'true'::jsonb OR h->>'owner'<>'postgres' OR cols IS DISTINCT FROM item->'columns'
   OR has_table_privilege('anon',relation_oid,'SELECT,INSERT,UPDATE,DELETE,TRUNCATE,REFERENCES,TRIGGER')
   OR has_table_privilege('authenticated',relation_oid,'SELECT,INSERT,UPDATE,DELETE,TRUNCATE,REFERENCES,TRIGGER') THEN
   RAISE EXCEPTION 'CATALOGO_ROOT_RELATION_SCHEMA_OR_PRIVILEGE:%',item->>'name';END IF;
  relation_manifest:=relation_manifest||jsonb_build_array(h);
 END LOOP;
 SELECT count(*) INTO actual_count FROM pg_class c JOIN pg_namespace n ON n.oid=c.relnamespace
  WHERE c.relkind IN('r','p')AND(n.nspname='combat_v2_genjutsu_internal' OR(n.nspname='combat_panel_private' AND c.relname LIKE 'cure\_%' ESCAPE '\'));
 IF actual_count<>jsonb_array_length(relation_manifest)
 OR actual_count<>(SELECT count(DISTINCT value->>'name')FROM jsonb_array_elements(relation_manifest))THEN RAISE EXCEPTION 'CATALOGO_ROOT_RELATION_COVERAGE';END IF;
 FOR item IN SELECT value FROM jsonb_array_elements(params->'triggers') ORDER BY value->>'table',value->>'name' LOOP
  SELECT jsonb_build_object('table',item->'table','name',t.tgname,'function',t.tgfoid::regprocedure::text,
   'type',t.tgtype,'enabled',t.tgenabled::text,'definition',pg_get_triggerdef(t.oid),'arguments_sha256',encode(extensions.digest(t.tgargs,'sha256'),'hex'))
   INTO h FROM pg_trigger t JOIN pg_proc tf ON tf.oid=t.tgfoid JOIN pg_namespace tn ON tn.oid=tf.pronamespace
   WHERE t.tgrelid=to_regclass(item->>'table')AND t.tgname=item->>'name'AND NOT t.tgisinternal
    AND tn.nspname='combat_panel_private'AND tf.proname LIKE 'cure\_%' ESCAPE '\';
  IF h IS NULL OR h->>'function' IS DISTINCT FROM item->>'function' OR h->'type' IS DISTINCT FROM item->'type'
   OR h->>'enabled' IS DISTINCT FROM 'O' THEN RAISE EXCEPTION 'CATALOGO_ROOT_TRIGGER_PIN:%',item->>'name';END IF;
  trigger_manifest:=trigger_manifest||jsonb_build_array(h);
 END LOOP;
 IF (SELECT count(DISTINCT jsonb_build_array(value->'table',value->'name'))FROM jsonb_array_elements(trigger_manifest))<>10
 OR (SELECT count(*)FROM pg_trigger t JOIN pg_proc f ON f.oid=t.tgfoid JOIN pg_namespace n ON n.oid=f.pronamespace
  WHERE NOT t.tgisinternal AND n.nspname='combat_panel_private' AND f.proname LIKE 'cure\_%' ESCAPE '\')<>10 THEN
  RAISE EXCEPTION 'CATALOGO_ROOT_TRIGGER_COVERAGE';END IF;
 relations_sha:=public.combat_v2_sha256(jsonb_build_object('relations',relation_manifest,'triggers',trigger_manifest));

 IF shared_sha IS DISTINCT FROM amendment->>'shared_manifest_sha256'
 OR private_sha IS DISTINCT FROM amendment->>'private_functions_manifest_sha256'
 OR relations_sha IS DISTINCT FROM root#>>'{db_core,catalogo_completo,relations_manifest_sha256}'
 OR shared_sha IS DISTINCT FROM binding->>'shared_manifest_sha256'
 OR private_sha IS DISTINCT FROM binding->>'private_functions_manifest_sha256'
 OR relations_sha IS DISTINCT FROM binding->>'relations_manifest_sha256'
 THEN RAISE EXCEPTION 'catalogo_eligibility_integrated_manifest_drift';END IF;

 -- Three owning substitution ports, exact bodies/ABI; authority stays native.
 FOR item IN SELECT value FROM jsonb_array_elements(params->'native_functions')ORDER BY value->>'signature'LOOP
  SELECT jsonb_build_object('signature',p.oid::regprocedure::text,'source_md5',md5(p.prosrc),'ddl_md5',md5(pg_get_functiondef(p.oid)),
   'owner',pg_get_userbyid(p.proowner),'acl',p.proacl::text,'config',p.proconfig,'secdef',p.prosecdef,'volatility',p.provolatile::text,
   'language',l.lanname,'strict',p.proisstrict,'parallel',p.proparallel::text,'returns',pg_get_function_result(p.oid),
   'arg_names',p.proargnames,'arg_modes',p.proargmodes,'arg_types',p.proargtypes::text)INTO h
   FROM pg_proc p JOIN pg_language l ON l.oid=p.prolang WHERE p.oid=to_regprocedure(item->>'signature')AND p.prokind='f';
  IF h IS DISTINCT FROM item THEN RAISE EXCEPTION 'cure_reaction_native_body_or_abi_drift:%',item->>'signature';END IF;
  native_manifest:=native_manifest||jsonb_build_array(h);
 END LOOP;
 IF jsonb_array_length(native_manifest)<>3 OR public.combat_v2_sha256(native_manifest)IS DISTINCT FROM amendment->>'native_functions_manifest_sha256'
 THEN RAISE EXCEPTION 'cure_reaction_native_manifest_drift';END IF;
 -- Own helper metadata is bound externally by the reviewed Root, never a literal self hash.
 SELECT jsonb_agg(jsonb_build_object('signature',p.oid::regprocedure::text,'source_md5',md5(p.prosrc),'ddl_md5',md5(pg_get_functiondef(p.oid)),
  'owner',pg_get_userbyid(p.proowner),'secdef',p.prosecdef,'config',p.proconfig,'acl',p.proacl::text,'volatility',p.provolatile::text)
  ORDER BY p.oid::regprocedure::text)INTO changed_manifest FROM pg_proc p WHERE p.oid IN(
  'combat_panel_private.round_options_authoritative(uuid,uuid)'::regprocedure,
  'public.combat_v2_substitution_options_v1(uuid)'::regprocedure,'public.combat_v2_substitution_round_offers_v1(uuid,uuid)'::regprocedure,
  'public.combat_v2_substitution_select_v1(uuid,uuid)'::regprocedure,'clan_innata_private.catalogo_eligibility_release_v1()'::regprocedure,'combat_panel_private.publish_master_declaration(uuid,text)'::regprocedure);
 IF jsonb_array_length(changed_manifest)<>6 OR public.combat_v2_sha256(changed_manifest)IS DISTINCT FROM amendment->>'functions_manifest_sha256'
 THEN RAISE EXCEPTION 'cure_reaction_changed_manifest_drift';END IF;

 IF jsonb_typeof(root#>'{db_core,catalogo_families}')IS DISTINCT FROM 'array'
 OR jsonb_array_length(root#>'{db_core,catalogo_families}')<>5
 OR root#>'{db_core,catalogo_families,0}'IS DISTINCT FROM '1'::jsonb
 OR root#>>'{db_core,catalogo_families,1}'IS DISTINCT FROM amendment->>'source_bundle_sha256'
 OR root#>'{db_core,catalogo_families,2}'IS DISTINCT FROM (SELECT jsonb_build_array(public.combat_v2_sha256((SELECT coalesce(jsonb_agg(jsonb_build_object('signature',n.nspname||'.'||p.proname||'('||oidvectortypes(p.proargtypes)||')','source_md5',md5(p.prosrc),'ddl_md5',md5(pg_get_functiondef(p.oid)),'owner',pg_get_userbyid(p.proowner),'acl',p.proacl::text,'config',p.proconfig,'secdef',p.prosecdef,'strict',p.proisstrict,'parallel',p.proparallel::text,'volatility',p.provolatile::text,'returns',pg_get_function_result(p.oid),'language',l.lanname)ORDER BY n.nspname,p.proname,oidvectortypes(p.proargtypes)),'[]'::jsonb)FROM pg_proc p JOIN pg_namespace n ON n.oid=p.pronamespace JOIN pg_language l ON l.oid=p.prolang WHERE p.oid IN(to_regprocedure('combat_v2_staff_nb_internal.origin_guard()'),to_regprocedure('combat_v2_staff_nb_internal.preparation_allowed(uuid)'),to_regprocedure('combat_v2_staff_nb_internal.choice(uuid)'),to_regprocedure('combat_v2_staff_nb_internal.roster_offers(uuid,bigint,uuid)'),to_regprocedure('combat_v2_staff_nb_internal.native_construct(uuid,uuid[],jsonb,jsonb,uuid,uuid)'),to_regprocedure('combat_v2_staff_nb_internal.mechanics_ready(uuid)'),to_regprocedure('combat_v2_staff_nb_internal.setup_protected(uuid,uuid)'),to_regprocedure('combat_v2_staff_nb_internal.commit_roster(jsonb)'),to_regprocedure('combat_v2_staff_nb_internal.roster_receipt(uuid)'),to_regprocedure('combat_v2_staff_nb_internal.pg_scope(uuid)'),to_regprocedure('combat_v2_staff_nb_internal.kai_frozen_authority(uuid)'),to_regprocedure('combat_v2_staff_nb_internal.kai_authority(uuid)'),to_regprocedure('combat_v2_staff_nb_internal.kai_contact(uuid,uuid)'),to_regprocedure('clan_aburame_private.verme_manifest_v1()'),to_regprocedure('clan_aburame_private.verme_release_v1()'),to_regprocedure('clan_aburame_private.verme_staff_scope_v1(uuid)'),to_regprocedure('clan_aburame_private.verme_scope_v1(uuid)'),to_regprocedure('clan_aburame_private.verme_event_v1(text,uuid,uuid,uuid,uuid,uuid,text,jsonb)'),to_regprocedure('clan_aburame_private.verme_staff_prepare_v1(uuid,uuid)'),to_regprocedure('clan_aburame_private.verme_meta_v1(uuid,boolean)'),to_regprocedure('clan_aburame_private.verme_bind_v1(uuid)'),to_regprocedure('clan_aburame_private.verme_frozen_v1(uuid)'),to_regprocedure('clan_aburame_private.verme_finish_v1(uuid,uuid,boolean,integer)'),to_regprocedure('clan_aburame_private.verme_tick_v1(uuid,uuid,uuid,text)'),to_regprocedure('clan_aburame_private.verme_end_context_v1()'),to_regprocedure('clan_aburame_private.verme_report_v1(uuid,uuid)'),to_regprocedure('clan_aburame_private.verme_reserve_round_v1(uuid)'),to_regprocedure('clan_aburame_private.verme_settle_round_v1(uuid)'),to_regprocedure('clan_aburame_private.verme_narrative_v1(uuid,uuid)'),to_regprocedure('clan_akimichi_private.common_staff_scope_v1(uuid)'),to_regprocedure('clan_akimichi_private.common_scope_v1(uuid,uuid)'),to_regprocedure('clan_akimichi_private.common_prepare_staff_v1(uuid,uuid,uuid)'),to_regprocedure('clan_akimichi_private.common_modifiers_v1(text,integer,integer,integer)'),to_regprocedure('clan_akimichi_private.common_set_form_v1(uuid,uuid,text)'),to_regprocedure('clan_akimichi_private.common_defer_upkeep_v1(uuid,uuid)'),to_regprocedure('clan_akimichi_private.common_flush_upkeep_v1(uuid)'),to_regprocedure('clan_akimichi_private.cellular_meta_v1(uuid)'),to_regprocedure('clan_akimichi_private.cellular_attack_eligible_v1(uuid,uuid)'),to_regprocedure('clan_akimichi_private.cellular_bind_v1(uuid)'),to_regprocedure('clan_akimichi_private.cellular_source_valid_v1(uuid)'),to_regprocedure('clan_akimichi_private.cellular_pay_v1(uuid)'),to_regprocedure('clan_akimichi_private.cellular_snapshot_v1(uuid,jsonb)'),to_regprocedure('clan_akimichi_private.cellular_mark_v1(uuid,jsonb)'),to_regprocedure('clan_akimichi_private.cellular_calculate_v1(uuid,jsonb,integer,integer)'),to_regprocedure('clan_akimichi_private.common_calorie_balance_v1(uuid,uuid,uuid,uuid)'),to_regprocedure('clan_akimichi_private.common_admit_calories_v1(uuid)'),to_regprocedure('clan_akimichi_private.common_preflight_calories_v1(uuid)'),to_regprocedure('clan_akimichi_private.super_direct_visible_v1(uuid,uuid)'),to_regprocedure('clan_akimichi_private.common_attack_power_freeze_v1(uuid)'),to_regprocedure('clan_akimichi_private.common_panel_offers_v1(uuid,bigint,jsonb)'),to_regprocedure('clan_akimichi_private.common_panel_commit_v1(jsonb)'),to_regprocedure('clan_akimichi_private.common_result_label_v1(jsonb)'),to_regprocedure('clan_akimichi_private.common_source_root_v1()'),to_regprocedure('clan_sabaku_private.armor_absorb_packet_v1(uuid,uuid,uuid,uuid,integer)'),to_regprocedure('combat_panel_private.nara_adv_pool_v1(uuid)'),to_regprocedure('combat_panel_private.nara_adv_protected_v1(uuid)'),to_regprocedure('combat_panel_private.nara_adv_scope_v1(uuid)'),to_regprocedure('combat_panel_private.nara_adv_prepare_v1(uuid,uuid)'),to_regprocedure('combat_panel_private.nara_strangle_meta_v1(uuid)'),to_regprocedure('combat_panel_private.nara_strangle_action_meta_v1(uuid,uuid,jsonb)'),to_regprocedure('combat_panel_private.nara_strangle_bind_v1(uuid)'),to_regprocedure('combat_panel_private.nara_strangle_parent_valid_v1(uuid)'),to_regprocedure('combat_panel_private.nara_strangle_lifecycle_v1(uuid)'),to_regprocedure('combat_panel_private.nara_strangle_packet_v1(uuid,uuid,uuid,text)'),to_regprocedure('combat_panel_private.nara_strangle_resolve_v1(uuid)'),to_regprocedure('combat_panel_private.nara_strangle_turn_v1(uuid,uuid,uuid,text)'),to_regprocedure('combat_panel_private.nara_strangle_facts_revision_v1(jsonb)'),to_regprocedure('combat_panel_private.nara_strangle_facts_v1(uuid,uuid)'),to_regprocedure('combat_panel_private.nara_adv_history_guard_v1()'),to_regprocedure('combat_panel_private.nara_strangle_end_event_v1()'),to_regprocedure('combat_panel_private.nara_strangle_terminal_report_v1(uuid)'),to_regprocedure('combat_panel_private.nara_strangle_lifecycle_context_v1(uuid)'),to_regprocedure('combat_panel_private.nara_adv_offers_v1(uuid,bigint,jsonb)'),to_regprocedure('combat_panel_private.nara_adv_commit_v1(jsonb)'),to_regprocedure('combat_panel_private.nara_strangle_lifecycle_trigger_v1()')))),public.combat_v2_sha256((SELECT coalesce(jsonb_agg(jsonb_build_object('signature',n.nspname||'.'||p.proname||'('||oidvectortypes(p.proargtypes)||')','source_md5',md5(p.prosrc),'ddl_md5',md5(pg_get_functiondef(p.oid)),'owner',pg_get_userbyid(p.proowner),'acl',p.proacl::text,'config',p.proconfig,'secdef',p.prosecdef,'strict',p.proisstrict,'parallel',p.proparallel::text,'volatility',p.provolatile::text,'returns',pg_get_function_result(p.oid),'language',l.lanname)ORDER BY n.nspname,p.proname,oidvectortypes(p.proargtypes)),'[]'::jsonb)FROM pg_proc p JOIN pg_namespace n ON n.oid=p.pronamespace JOIN pg_language l ON l.oid=p.prolang WHERE p.oid IN(to_regprocedure('clan_aburame_private.actor_ability(uuid,text,uuid,boolean,jsonb)'),to_regprocedure('clan_aburame_private.attack_power_source(uuid,uuid)'),to_regprocedure('clan_aburame_private.commit_control(jsonb,jsonb,combat_consumer_private.activities,combat_consumer_private.offers,uuid)'),to_regprocedure('clan_aburame_private.commit_master_stop(jsonb)'),to_regprocedure('clan_aburame_private.consumer_options(jsonb)'),to_regprocedure('clan_aburame_private.master_offers(uuid,bigint,jsonb)'),to_regprocedure('clan_akimichi_private.apply_calorie_event(uuid,uuid,boolean,uuid,text,integer,integer,uuid,timestamp with time zone)'),to_regprocedure('clan_akimichi_private.begin_personal_turn(uuid,uuid)'),to_regprocedure('clan_akimichi_private.bind_partial(uuid)'),to_regprocedure('clan_akimichi_private.end_form(uuid,uuid,text)'),to_regprocedure('clan_akimichi_private.form_change_offer(uuid)'),to_regprocedure('clan_akimichi_private.form_impact(uuid,uuid,uuid,text,text,text,jsonb)'),to_regprocedure('clan_akimichi_private.movement_maximum(uuid,numeric)'),to_regprocedure('clan_akimichi_private.partial_meta(uuid,jsonb)'),to_regprocedure('clan_akimichi_private.set_form(uuid,uuid,boolean)'),to_regprocedure('clan_sabaku_private.armor_absorb(uuid,integer)'),to_regprocedure('clan_sabaku_private.armor_narrative_round(uuid)'),to_regprocedure('clan_sabaku_private.armor_round_facts(uuid)'),to_regprocedure('combat_consumer_private.after_publish(uuid,uuid)'),to_regprocedure('combat_consumer_private.commit_exchange(jsonb,jsonb)'),to_regprocedure('combat_consumer_private.narrative_context(uuid)'),to_regprocedure('combat_consumer_private.narrative_declaration_supported(uuid)'),to_regprocedure('combat_consumer_private.validate_narrative_result(jsonb)'),to_regprocedure('combat_effects_private.lifecycle_actor_end(uuid)'),to_regprocedure('combat_effects_private.lifecycle_open(uuid,uuid)'),to_regprocedure('combat_effects_private.lifecycle_session_end(uuid)'),to_regprocedure('combat_effects_private.personal_turn_end(uuid,uuid,uuid,text)'),to_regprocedure('combat_panel_private.catalog_result_label_v1(jsonb)'),to_regprocedure('combat_panel_private.consumer_commit_authoritative(jsonb)'),to_regprocedure('combat_panel_private.master_admin_offers(uuid,bigint,jsonb)'),to_regprocedure('combat_panel_private.master_options(uuid,uuid,bigint)'),to_regprocedure('combat_panel_private.nara_shadow_level_v1(uuid)'),to_regprocedure('combat_panel_private.narrative_declaration_facts(uuid)'),to_regprocedure('combat_panel_private.narrative_ordinary_context(uuid)'),to_regprocedure('combat_panel_private.ordinary_options(uuid,uuid,bigint)'),to_regprocedure('combat_spatial.movement_commit(uuid,uuid,uuid)'),to_regprocedure('combat_v2_genjutsu_internal.ally_contact(uuid,uuid)'),to_regprocedure('combat_v2_genjutsu_internal.master_options(uuid,bigint)'),to_regprocedure('combat_v2_genjutsu_internal.release_intents(uuid)'),to_regprocedure('combat_v2_genjutsu_internal.release_meta(uuid,uuid,uuid,jsonb)'),to_regprocedure('combat_v2_genjutsu_internal.resolve_release(uuid)'),to_regprocedure('combat_v2_genjutsu_internal.scope(uuid)'),to_regprocedure('combat_v2_multitarget_internal.resolve_parent(uuid,uuid,uuid,boolean)'),to_regprocedure('mission_factory_owner.quest_combat_offer_source_guard_v1()'),to_regprocedure('public._combat_calcola(text,jsonb,jsonb,text,text,integer,text,integer,integer,integer,integer,boolean)'),to_regprocedure('public.combat_consumer_narrative_claim_v1(uuid,text,uuid)'),to_regprocedure('public.combat_consumer_narrative_complete_v1(uuid,jsonb,uuid)'),to_regprocedure('public.combat_panel_commit_v1(jsonb)'),to_regprocedure('public.combat_v2_action_declare(uuid,uuid,jsonb,text,uuid)'),to_regprocedure('public.combat_v2_actor_ability(uuid,text,uuid,boolean)'),to_regprocedure('public.combat_v2_defense_declare(uuid,uuid,uuid,jsonb,text,uuid)'),to_regprocedure('public.combat_v2_round_resolve(uuid,uuid)'),to_regprocedure('public.master_v2_encounter_open_ninja_book_v1_human_ai_core(uuid,uuid[],jsonb,jsonb,uuid)'),to_regprocedure('combat_panel_private.publish_master_declaration(uuid,text)'),to_regprocedure('clan_innata_private.eligibility_release_assert()'),to_regprocedure('combat_panel_private.cure_neutral_preset_v1(uuid,uuid,uuid,jsonb)'),to_regprocedure('combat_panel_private.master_actor_offers(uuid,bigint,jsonb,jsonb)')))),public.combat_v2_sha256((SELECT jsonb_build_object('tables',(SELECT jsonb_agg(jsonb_build_object('schema',n.nspname,'name',c.relname,'owner',pg_get_userbyid(c.relowner),'acl',c.relacl::text,'rls',c.relrowsecurity,'force_rls',c.relforcerowsecurity,'columns',(SELECT jsonb_agg(jsonb_build_object('name',a.attname,'type',format_type(a.atttypid,a.atttypmod),'notnull',a.attnotnull,'default',pg_get_expr(d.adbin,d.adrelid),'identity',a.attidentity,'generated',a.attgenerated)ORDER BY a.attnum)FROM pg_attribute a LEFT JOIN pg_attrdef d ON d.adrelid=a.attrelid AND d.adnum=a.attnum WHERE a.attrelid=c.oid AND a.attnum>0 AND NOT a.attisdropped),'constraints',(SELECT coalesce(jsonb_agg(jsonb_build_object('name',q.conname,'definition',pg_get_constraintdef(q.oid),'validated',q.convalidated,'deferrable',q.condeferrable,'deferred',q.condeferred)ORDER BY q.conname),'[]'::jsonb)FROM pg_constraint q WHERE q.conrelid=c.oid),'indexes',(SELECT coalesce(jsonb_agg(jsonb_build_object('name',ci.relname,'definition',pg_get_indexdef(i.indexrelid),'valid',i.indisvalid,'ready',i.indisready,'live',i.indislive)ORDER BY ci.relname),'[]'::jsonb)FROM pg_index i JOIN pg_class ci ON ci.oid=i.indexrelid WHERE i.indrelid=c.oid),'triggers',(SELECT coalesce(jsonb_agg(pg_get_triggerdef(t.oid)ORDER BY t.tgname),'[]'::jsonb)FROM pg_trigger t WHERE t.tgrelid=c.oid AND NOT t.tgisinternal),'policies',(SELECT coalesce(jsonb_agg(jsonb_build_object('name',p.polname,'cmd',p.polcmd,'roles',p.polroles,'using',pg_get_expr(p.polqual,p.polrelid),'check',pg_get_expr(p.polwithcheck,p.polrelid))ORDER BY p.polname),'[]'::jsonb)FROM pg_policy p WHERE p.polrelid=c.oid))ORDER BY n.nspname,c.relname)FROM pg_class c JOIN pg_namespace n ON n.oid=c.relnamespace WHERE c.oid IN(to_regclass('combat_v2_staff_nb_internal.gate'),to_regclass('combat_v2_staff_nb_internal.roster_sources'),to_regclass('combat_v2_staff_nb_internal.admissions'),to_regclass('clan_aburame_private.verme_gate_v1'),to_regclass('clan_aburame_private.verme_staff_profiles_v1'),to_regclass('clan_aburame_private.verme_sources_v1'),to_regclass('clan_aburame_private.verme_poison_v1'),to_regclass('clan_aburame_private.verme_events_v1'),to_regclass('clan_akimichi_private.common_gate_v1'),to_regclass('clan_akimichi_private.common_staff_profiles_v1'),to_regclass('clan_akimichi_private.common_form_commands_v1'),to_regclass('clan_akimichi_private.common_attack_powers_v1'),to_regclass('clan_akimichi_private.common_pending_upkeep_v1'),to_regclass('clan_akimichi_private.cellular_sources_v1'),to_regclass('combat_panel_private.nara_adv_gate_v1'),to_regclass('combat_panel_private.nara_adv_staff_v1'),to_regclass('combat_panel_private.nara_strangle_sources_v1'),to_regclass('combat_panel_private.nara_strangle_events_v1'),to_regclass('public.master_v2_nb_actor_offers_v1'),to_regclass('clan_akimichi_private.forms'))),'catalog',(SELECT jsonb_agg(jsonb_build_object('id',t.id,'sha256',public.combat_v2_sha256(to_jsonb(t)))ORDER BY t.id)FROM public.clan_techniques t WHERE id IN('0a15282f-d6b5-4ee3-ad52-7fac2525444d','f5f26cb5-9b6f-44b3-94bc-c329a0a88b93','687b058a-807d-4cf7-8bcf-21147931b0f6')),'NBtuples',(SELECT jsonb_build_object('mechanical',(SELECT jsonb_agg(jsonb_build_object('id',v.id,'template_id',v.template_id,'content_sha256',v.content_sha256)ORDER BY v.id)FROM public.nb_mechanical_versions v WHERE v.id IN('31da0000-0000-4000-8000-000000000111','31da0000-0000-4000-8000-000000000112')),'narrative',(SELECT jsonb_agg(jsonb_build_object('id',v.id,'template_id',v.template_id,'content_sha256',v.content_sha256)ORDER BY v.id)FROM public.nb_template_versions v WHERE v.id IN('31da0000-0000-4000-8000-000000000211','31da0000-0000-4000-8000-000000000212')))),'new_triggers',(SELECT jsonb_agg(jsonb_build_object('table',e->>'table','name',t.tgname,'function',t.tgfoid::regprocedure::text,'enabled',t.tgenabled::text,'type',t.tgtype,'definition',pg_get_triggerdef(t.oid),'args_sha256',encode(extensions.digest(t.tgargs,'sha256'),'hex'))ORDER BY e->>'table',e->>'name')FROM jsonb_array_elements($joint_triggers$[{"table":"combat_v2_staff_nb_internal.roster_sources","name":"staff_nb_origin_immutable"},{"table":"public.combat_v2_sessions","name":"aburame_verme_end_session_v1"},{"table":"public.combat_v2_actors","name":"aburame_verme_end_actor_v1"},{"table":"combat_panel_private.nara_strangle_sources_v1","name":"nara_strangle_snapshot_guard_v1"},{"table":"combat_panel_private.nara_strangle_events_v1","name":"nara_strangle_events_guard_v1"},{"table":"combat_panel_private.nara_adv_staff_v1","name":"nara_strangle_staff_guard_v1"},{"table":"combat_panel_private.nara_strangle_sources_v1","name":"nara_strangle_ended_event_v1"},{"table":"combat_panel_private.immobilizations","name":"nara_strangle_parent_end_v1"},{"table":"combat_spatial.actor_states","name":"nara_strangle_geometry_end_v1"}]$joint_triggers$::jsonb)e JOIN pg_trigger t ON t.tgrelid=to_regclass(e->>'table')AND t.tgname=e->>'name'AND NOT t.tgisinternal),'NBnamespace',(SELECT jsonb_build_object('owner',pg_get_userbyid(nspowner),'acl',nspacl::text)FROM pg_namespace WHERE nspname='combat_v2_staff_nb_internal'))))))
 OR root#>'{config,catalogo_families}'IS DISTINCT FROM to_jsonb(public.combat_v2_sha256(root#>'{db_core,catalogo_families}'))
 OR root#>>'{db_core,catalogo_families,3}'IS DISTINCT FROM 'cd22449d2aacf38bbf7b919678b58b256c4b89a47b6ccd16a69b6f3a75047bd9'
 OR NOT EXISTS(SELECT 1 FROM jsonb_array_elements(root->'edge_bundles')b CROSS JOIN LATERAL jsonb_array_elements(b->'files')f WHERE b->>'name'='combat_narratore_ai'AND f->>'name'='facts.ts'AND f->>'sha256'='cd22449d2aacf38bbf7b919678b58b256c4b89a47b6ccd16a69b6f3a75047bd9')
 OR coalesce(root#>'{db_core,catalogo_families,4}','null'::jsonb)NOT IN('[1,1,1,1]'::jsonb,'[0,0,0,0]'::jsonb)
 OR jsonb_typeof(root#>'{db_core,catalogo_families,4}')IS DISTINCT FROM 'array'
 OR EXISTS(SELECT 1 FROM combat_v2_staff_nb_internal.gate WHERE public_enabled)
 OR EXISTS(SELECT 1 FROM clan_aburame_private.verme_gate_v1 WHERE public_enabled)
 OR EXISTS(SELECT 1 FROM clan_akimichi_private.common_gate_v1 WHERE public_enabled OR super_public_enabled OR cellular_public_enabled)
 OR EXISTS(SELECT 1 FROM combat_panel_private.nara_adv_gate_v1 WHERE public_enabled)
 THEN RAISE EXCEPTION 'JOINT_CATALOG_MANIFEST_OR_SCOPE_DRIFT';END IF;
 IF EXISTS(SELECT 1 FROM jsonb_array_elements($joint_expected$[{"signature":"combat_v2_staff_nb_internal.origin_guard()","source_md5":"1140049388497d2060a5559fbdcdfd1f","security_definer":true},{"signature":"combat_v2_staff_nb_internal.preparation_allowed(uuid)","source_md5":"48d0ce9a5a617b90a8d8b7484ff846c5","security_definer":true},{"signature":"combat_v2_staff_nb_internal.choice(uuid)","source_md5":"e0a9c9957b9f831a44e956fc1faa8000","security_definer":true},{"signature":"combat_v2_staff_nb_internal.roster_offers(uuid,bigint,uuid)","source_md5":"2d4f9396d3f6f3acb29d4b57dee65347","security_definer":true},{"signature":"combat_v2_staff_nb_internal.native_construct(uuid,uuid[],jsonb,jsonb,uuid,uuid)","source_md5":"9f45926f70f911af516c1a3f6899ed81","security_definer":true},{"signature":"combat_v2_staff_nb_internal.mechanics_ready(uuid)","source_md5":"d0be038e05e3baea60270c52050db778","security_definer":true},{"signature":"combat_v2_staff_nb_internal.setup_protected(uuid,uuid)","source_md5":"7543230450e0d5b9c985823fe0740b51","security_definer":true},{"signature":"combat_v2_staff_nb_internal.commit_roster(jsonb)","source_md5":"ce1f9682474b4d550c9584206093b872","security_definer":true},{"signature":"combat_v2_staff_nb_internal.roster_receipt(uuid)","source_md5":"4bf43be7f3ed838c3a2fdc64a5e2b85b","security_definer":true},{"signature":"combat_v2_staff_nb_internal.pg_scope(uuid)","source_md5":"3df42b0dd768a6291bd9096a58bf5d08","security_definer":true},{"signature":"combat_v2_staff_nb_internal.kai_frozen_authority(uuid)","source_md5":"95dd90e5eb49840c142d52ffe452a9a8","security_definer":true},{"signature":"combat_v2_staff_nb_internal.kai_authority(uuid)","source_md5":"ccff2cd6a0b988da8f62fcd63a1056e9","security_definer":true},{"signature":"combat_v2_staff_nb_internal.kai_contact(uuid,uuid)","source_md5":"ef2313c0fd4eb2ad78579b8ee0981a6e","security_definer":true},{"signature":"clan_aburame_private.verme_manifest_v1()","source_md5":"d959e35164cb3b91dae5af370e202f10","security_definer":true},{"signature":"clan_aburame_private.verme_release_v1()","source_md5":"1df436e50d123cfaf302edec8f72baea","security_definer":true},{"signature":"clan_aburame_private.verme_staff_scope_v1(uuid)","source_md5":"d4a8c0421eb673be663d716e9a4beab4","security_definer":true},{"signature":"clan_aburame_private.verme_scope_v1(uuid)","source_md5":"6e513c685ae41e3f932bf12601ef5949","security_definer":true},{"signature":"clan_aburame_private.verme_event_v1(text,uuid,uuid,uuid,uuid,uuid,text,jsonb)","source_md5":"b4c4a3c168d647e4607e526ee8808c08","security_definer":true},{"signature":"clan_aburame_private.verme_staff_prepare_v1(uuid,uuid)","source_md5":"4288e5eed6eb7b949746d4972bd7c6ff","security_definer":true},{"signature":"clan_aburame_private.verme_meta_v1(uuid,boolean)","source_md5":"03b0d2b2fe63168c4989cc7a733fa3d8","security_definer":true},{"signature":"clan_aburame_private.verme_bind_v1(uuid)","source_md5":"374b96652f29e70732937dee4e9edb7d","security_definer":true},{"signature":"clan_aburame_private.verme_frozen_v1(uuid)","source_md5":"60b6d1187a64c8afe1c7182fab1366ab","security_definer":true},{"signature":"clan_aburame_private.verme_finish_v1(uuid,uuid,boolean,integer)","source_md5":"15522dc52e63348477b2066bd48aae57","security_definer":true},{"signature":"clan_aburame_private.verme_tick_v1(uuid,uuid,uuid,text)","source_md5":"e383a9cb056c4f39f7d22480970149ee","security_definer":true},{"signature":"clan_aburame_private.verme_end_context_v1()","source_md5":"349317d7764d5ca425c7eb588d257ae1","security_definer":true},{"signature":"clan_aburame_private.verme_report_v1(uuid,uuid)","source_md5":"87e095eb88e29760a8678756d28e39ab","security_definer":true},{"signature":"clan_aburame_private.verme_reserve_round_v1(uuid)","source_md5":"85c89cf0d8b8f55e1db50073c17b5f93","security_definer":true},{"signature":"clan_aburame_private.verme_settle_round_v1(uuid)","source_md5":"53a6b0101059a9cfc462e9327e7c395a","security_definer":true},{"signature":"clan_aburame_private.verme_narrative_v1(uuid,uuid)","source_md5":"d31a97fbe8289c33e32546e1381fb9dd","security_definer":true},{"signature":"clan_akimichi_private.common_staff_scope_v1(uuid)","source_md5":"5b99799e661c5192445ed8c3c80e3315","security_definer":true},{"signature":"clan_akimichi_private.common_scope_v1(uuid,uuid)","source_md5":"b96176036ce4a9e56041ba0ea13a8b12","security_definer":true},{"signature":"clan_akimichi_private.common_prepare_staff_v1(uuid,uuid,uuid)","source_md5":"dce7a5ef3b37dbeb5cd48edf0546c254","security_definer":true},{"signature":"clan_akimichi_private.common_modifiers_v1(text,integer,integer,integer)","source_md5":"5bb71bbae1cc67857e73daa0d790a6cd","security_definer":false},{"signature":"clan_akimichi_private.common_set_form_v1(uuid,uuid,text)","source_md5":"446f6580947bc1a6b7be66ad7559ec5c","security_definer":true},{"signature":"clan_akimichi_private.common_defer_upkeep_v1(uuid,uuid)","source_md5":"cfc4c1f9fdad1ce6da9acef0e9adb23d","security_definer":true},{"signature":"clan_akimichi_private.common_flush_upkeep_v1(uuid)","source_md5":"8fe8dda8a8aafb08e8aa4b5f9bc919a2","security_definer":true},{"signature":"clan_akimichi_private.cellular_meta_v1(uuid)","source_md5":"c7b3f3fce412a1ac01ccfd188e94fe7a","security_definer":true},{"signature":"clan_akimichi_private.cellular_attack_eligible_v1(uuid,uuid)","source_md5":"1b365e150fb330c54c3094c07bb8874a","security_definer":true},{"signature":"clan_akimichi_private.cellular_bind_v1(uuid)","source_md5":"621f9037c8b7c1d575b4d9635085d706","security_definer":true},{"signature":"clan_akimichi_private.cellular_source_valid_v1(uuid)","source_md5":"ad9eac644c136fcde991a93633902b0d","security_definer":true},{"signature":"clan_akimichi_private.cellular_pay_v1(uuid)","source_md5":"843a172c962fe592f00172d8cfed7aef","security_definer":true},{"signature":"clan_akimichi_private.cellular_snapshot_v1(uuid,jsonb)","source_md5":"953342a7d013006a4cf812682285b6b0","security_definer":true},{"signature":"clan_akimichi_private.cellular_mark_v1(uuid,jsonb)","source_md5":"0fb789ae313a680dd4e83eb0e51444e2","security_definer":true},{"signature":"clan_akimichi_private.cellular_calculate_v1(uuid,jsonb,integer,integer)","source_md5":"0ea4f400225ddeef1c231ce879965c53","security_definer":true},{"signature":"clan_akimichi_private.common_calorie_balance_v1(uuid,uuid,uuid,uuid)","source_md5":"8d61faeead0597de3a87adfd548c16ff","security_definer":true},{"signature":"clan_akimichi_private.common_admit_calories_v1(uuid)","source_md5":"798c20833ceffaa85e36c0ef3bf47561","security_definer":true},{"signature":"clan_akimichi_private.common_preflight_calories_v1(uuid)","source_md5":"1960fb6064b16c1dbf91ef88161e93f6","security_definer":true},{"signature":"clan_akimichi_private.super_direct_visible_v1(uuid,uuid)","source_md5":"8fe89b774ef59f9ac66e27be00861d42","security_definer":true},{"signature":"clan_akimichi_private.common_attack_power_freeze_v1(uuid)","source_md5":"58ee8836c59cc9f28ff9f3ff94299153","security_definer":true},{"signature":"clan_akimichi_private.common_panel_offers_v1(uuid,bigint,jsonb)","source_md5":"289d91af1d8f0e84b4948edc3141edc6","security_definer":true},{"signature":"clan_akimichi_private.common_panel_commit_v1(jsonb)","source_md5":"91e55c736eefba25100199b9c05e9fc5","security_definer":true},{"signature":"clan_akimichi_private.common_result_label_v1(jsonb)","source_md5":"49598647a5f77b06747d266e8ae57f28","security_definer":false},{"signature":"clan_akimichi_private.common_source_root_v1()","source_md5":"219f76417a82622471b6d5689e3cd5fd","security_definer":true},{"signature":"clan_sabaku_private.armor_absorb_packet_v1(uuid,uuid,uuid,uuid,integer)","source_md5":"bce137fc38ae8f4d2333944a0bf081f7","security_definer":true},{"signature":"combat_panel_private.nara_adv_pool_v1(uuid)","source_md5":"e299333ced84428fb1f927ab42066a5b","security_definer":true},{"signature":"combat_panel_private.nara_adv_protected_v1(uuid)","source_md5":"13073c7a30b26f5a913c0149821e79ac","security_definer":true},{"signature":"combat_panel_private.nara_adv_scope_v1(uuid)","source_md5":"879b81f9d619ba3ab9253539c931874d","security_definer":true},{"signature":"combat_panel_private.nara_adv_prepare_v1(uuid,uuid)","source_md5":"bd29ec1a52a65e7c7efed66a41fc2125","security_definer":true},{"signature":"combat_panel_private.nara_strangle_meta_v1(uuid)","source_md5":"fe6d88539668bd145ea61525f35e2afa","security_definer":true},{"signature":"combat_panel_private.nara_strangle_action_meta_v1(uuid,uuid,jsonb)","source_md5":"15336a6189c6ede2f2240a03d9b10575","security_definer":true},{"signature":"combat_panel_private.nara_strangle_bind_v1(uuid)","source_md5":"5599670a3de573542f1fc5033d03db99","security_definer":true},{"signature":"combat_panel_private.nara_strangle_parent_valid_v1(uuid)","source_md5":"c73c8de463dbdee906910324c0302e94","security_definer":true},{"signature":"combat_panel_private.nara_strangle_lifecycle_v1(uuid)","source_md5":"99263809c05247500fad36e74b6c0643","security_definer":true},{"signature":"combat_panel_private.nara_strangle_packet_v1(uuid,uuid,uuid,text)","source_md5":"8c36b78f9f7c70bcbafec66edd29da80","security_definer":true},{"signature":"combat_panel_private.nara_strangle_resolve_v1(uuid)","source_md5":"8a966d5cafecd1245c155d69a88b3e9b","security_definer":true},{"signature":"combat_panel_private.nara_strangle_turn_v1(uuid,uuid,uuid,text)","source_md5":"6855e493411aa494c1166d985d965363","security_definer":true},{"signature":"combat_panel_private.nara_strangle_facts_revision_v1(jsonb)","source_md5":"b1949dfaa702714a3b72df2a94265c4d","security_definer":true},{"signature":"combat_panel_private.nara_strangle_facts_v1(uuid,uuid)","source_md5":"537f2221e2a89b5e7f10ef09640d2d2b","security_definer":true},{"signature":"combat_panel_private.nara_adv_history_guard_v1()","source_md5":"69b1e8d5b246aed2234dc1247a5d0e27","security_definer":true},{"signature":"combat_panel_private.nara_strangle_end_event_v1()","source_md5":"1e2ae345ecfa2150a12f607677102ecc","security_definer":true},{"signature":"combat_panel_private.nara_strangle_terminal_report_v1(uuid)","source_md5":"e23e524a71d5a3ef9fb6a89df0d72193","security_definer":true},{"signature":"combat_panel_private.nara_strangle_lifecycle_context_v1(uuid)","source_md5":"b3be34f23b3a6f6fc4d3a6709e1b041d","security_definer":true},{"signature":"combat_panel_private.nara_adv_offers_v1(uuid,bigint,jsonb)","source_md5":"6b25543eea4b107627050aef23f11c0f","security_definer":true},{"signature":"combat_panel_private.nara_adv_commit_v1(jsonb)","source_md5":"b57fd70e77171c807a44e5834acdfb86","security_definer":true},{"signature":"combat_panel_private.nara_strangle_lifecycle_trigger_v1()","source_md5":"15b727456c2551117972133a24862a25","security_definer":true}]$joint_expected$::jsonb)e LEFT JOIN pg_proc p ON p.oid=to_regprocedure(e->>'signature')WHERE p.oid IS NULL OR md5(p.prosrc)IS DISTINCT FROM e->>'source_md5'OR p.proowner<>'postgres'::regrole OR p.prosecdef IS DISTINCT FROM(e->>'security_definer')::boolean OR p.proconfig IS DISTINCT FROM ARRAY['search_path=""']OR has_function_privilege('anon',p.oid,'EXECUTE')OR has_function_privilege('authenticated',p.oid,'EXECUTE')OR has_function_privilege('service_role',p.oid,'EXECUTE'))THEN RAISE EXCEPTION 'JOINT_CATALOG_PRIVATE_BODY_OR_ACL_DRIFT';END IF;
 IF(SELECT count(*)FROM pg_proc p JOIN pg_namespace n ON n.oid=p.pronamespace WHERE n.nspname='clan_aburame_private'AND p.proname LIKE 'verme\_%'ESCAPE'\')<>16
 OR(SELECT count(*)FROM pg_class c JOIN pg_namespace n ON n.oid=c.relnamespace WHERE n.nspname='clan_aburame_private'AND c.relkind='r'AND c.relname LIKE 'verme\_%'ESCAPE'\')<>5
 OR(SELECT count(*)FROM pg_trigger WHERE NOT tgisinternal AND tgname IN('aburame_verme_end_session_v1','aburame_verme_end_actor_v1'))<>2
 OR(SELECT count(*)FROM pg_proc WHERE pronamespace='combat_v2_staff_nb_internal'::regnamespace AND prokind='f')<>13
 OR(SELECT count(*)FROM pg_class WHERE relnamespace='combat_v2_staff_nb_internal'::regnamespace AND relkind='r')<>3
 OR(SELECT count(*)FROM pg_class WHERE oid IN(to_regclass('combat_v2_staff_nb_internal.gate'),to_regclass('combat_v2_staff_nb_internal.roster_sources'),to_regclass('combat_v2_staff_nb_internal.admissions'),to_regclass('clan_aburame_private.verme_gate_v1'),to_regclass('clan_aburame_private.verme_staff_profiles_v1'),to_regclass('clan_aburame_private.verme_sources_v1'),to_regclass('clan_aburame_private.verme_poison_v1'),to_regclass('clan_aburame_private.verme_events_v1'),to_regclass('clan_akimichi_private.common_gate_v1'),to_regclass('clan_akimichi_private.common_staff_profiles_v1'),to_regclass('clan_akimichi_private.common_form_commands_v1'),to_regclass('clan_akimichi_private.common_attack_powers_v1'),to_regclass('clan_akimichi_private.common_pending_upkeep_v1'),to_regclass('clan_akimichi_private.cellular_sources_v1'),to_regclass('combat_panel_private.nara_adv_gate_v1'),to_regclass('combat_panel_private.nara_adv_staff_v1'),to_regclass('combat_panel_private.nara_strangle_sources_v1'),to_regclass('combat_panel_private.nara_strangle_events_v1'),to_regclass('public.master_v2_nb_actor_offers_v1'),to_regclass('clan_akimichi_private.forms')))<>20
 OR(SELECT count(*)FROM jsonb_array_elements($joint_triggers$[{"table":"combat_v2_staff_nb_internal.roster_sources","name":"staff_nb_origin_immutable"},{"table":"public.combat_v2_sessions","name":"aburame_verme_end_session_v1"},{"table":"public.combat_v2_actors","name":"aburame_verme_end_actor_v1"},{"table":"combat_panel_private.nara_strangle_sources_v1","name":"nara_strangle_snapshot_guard_v1"},{"table":"combat_panel_private.nara_strangle_events_v1","name":"nara_strangle_events_guard_v1"},{"table":"combat_panel_private.nara_adv_staff_v1","name":"nara_strangle_staff_guard_v1"},{"table":"combat_panel_private.nara_strangle_sources_v1","name":"nara_strangle_ended_event_v1"},{"table":"combat_panel_private.immobilizations","name":"nara_strangle_parent_end_v1"},{"table":"combat_spatial.actor_states","name":"nara_strangle_geometry_end_v1"}]$joint_triggers$::jsonb)e JOIN pg_trigger t ON t.tgrelid=to_regclass(e->>'table')AND t.tgname=e->>'name'AND NOT t.tgisinternal AND t.tgenabled='O')<>9
 THEN RAISE EXCEPTION 'JOINT_CATALOG_COMPONENT_COVERAGE';END IF;

 -- Attestazione Velo iniziale solo Staff. I tre registri e la capability non sono grant pubblici.
 IF coalesce(root#>>'{db_core,velo_staff}','') NOT IN ('35d754465f1c19509822e9728ade3e23c3d2aefe63f441aff01908e774dfcef6','a44f53e09a8d361eb634f261acec19f8070ea942c8325c14892d643873fb101b')
  OR root#>'{config,velo_staff}' IS DISTINCT FROM root#>'{db_core,velo_staff}'
  OR (SELECT staff_enabled FROM clan_innata_combat_private.velo_staff_gate_v1 WHERE singleton)
      IS DISTINCT FROM (root#>>'{db_core,velo_staff}' = '35d754465f1c19509822e9728ade3e23c3d2aefe63f441aff01908e774dfcef6')
  OR EXISTS(SELECT 1 FROM jsonb_to_recordset($velo_leaf_functions$[{"signature":"clan_innata_combat_private.velo_action_turn_v1(uuid,uuid)","md5":"c98a0dbdf0b54c4b240bc16d3331c666"},{"signature":"clan_innata_combat_private.velo_control_choice_v1(uuid,uuid)","md5":"40db9b6876cdc5c357644f7c4886e0a3"},{"signature":"clan_innata_combat_private.velo_control_commit_v1(jsonb)","md5":"a41d2d4cc5cb6a8e7aa6b35542ec3337"},{"signature":"clan_innata_combat_private.velo_control_offers_v1(uuid,bigint)","md5":"4619836b461198a4f2feeb3557ca0d78"},{"signature":"clan_innata_combat_private.velo_freeze_declaration_v1(uuid)","md5":"ad92aeda67371814120c53a445b38dfa"},{"signature":"clan_innata_combat_private.velo_frozen_snapshot_v1(jsonb,uuid,uuid)","md5":"4fbfa40058b21ac6bf23bf31284892ad"},{"signature":"clan_innata_combat_private.velo_innata_scope_v1(uuid)","md5":"8f3d134a673d13dc640ebe33aa2e10b6"},{"signature":"clan_innata_combat_private.velo_profile_bound_v1(uuid)","md5":"43f8511dc5e87cb8069953212d5452e0"},{"signature":"clan_innata_combat_private.velo_staff_scope_v1(uuid)","md5":"3bb31269a7662aaf16169f76bccd6348"},{"signature":"clan_innata_combat_private.velo_stat_delta_v1(uuid)","md5":"119f87ef4dc7481a07cce29b3ddca241"}]$velo_leaf_functions$::jsonb) AS e(signature text,md5 text)
    LEFT JOIN pg_proc p ON p.oid=to_regprocedure(e.signature)
    WHERE p.oid IS NULL OR md5(p.prosrc) IS DISTINCT FROM e.md5 OR p.prokind IS DISTINCT FROM 'f'
      OR NOT p.prosecdef OR p.proowner IS DISTINCT FROM 'postgres'::regrole
      OR p.proconfig IS DISTINCT FROM ARRAY['search_path=""']
      OR has_function_privilege('anon',p.oid,'EXECUTE')
      OR has_function_privilege('authenticated',p.oid,'EXECUTE')
      OR has_function_privilege('service_role',p.oid,'EXECUTE'))
  OR (SELECT count(*) FROM pg_class c
      WHERE c.relnamespace='clan_innata_combat_private'::regnamespace AND c.relname IN ('velo_staff_gate_v1','velo_staff_profiles_v1','velo_rapid_turn_receipts_v1','velo_declaration_stats_v1')
        AND c.relkind='r' AND c.relowner='postgres'::regrole AND c.relrowsecurity AND c.relforcerowsecurity
        AND NOT has_table_privilege('anon',c.oid,'SELECT,INSERT,UPDATE,DELETE,TRUNCATE,REFERENCES,TRIGGER')
        AND NOT has_table_privilege('authenticated',c.oid,'SELECT,INSERT,UPDATE,DELETE,TRUNCATE,REFERENCES,TRIGGER')
        AND NOT has_table_privilege('service_role',c.oid,'SELECT,INSERT,UPDATE,DELETE,TRUNCATE,REFERENCES,TRIGGER')) IS DISTINCT FROM 4
  OR EXISTS(SELECT 1 FROM clan_innata_combat_private.combat_state
      WHERE technique_id='c9b261da-c9cd-40bb-8189-7b65ab5a1605'::uuid AND is_test IS DISTINCT FROM true)
 THEN RAISE EXCEPTION 'VELO_STAFF_ROOT_CAPABILITY_DRIFT'; END IF;

 IF root#>>'{db_core,sfera_staff}' NOT IN ('d2f38943c31031ee0fa051e57add33095908eed0806382d93984fb44d111a2eb','de77cc1b529bf5f6f3cd7420aa6f315521a89bbb713f0dd9af4b9713a46defd1')
  OR root#>'{db_core,sfera_staff}' IS NULL
  OR root#>'{config,sfera_staff}' IS DISTINCT FROM root#>'{db_core,sfera_staff}'
  OR (SELECT enabled FROM clan_aburame_private.sfera_staff_gate_v1 WHERE singleton)
       IS DISTINCT FROM (root#>>'{db_core,sfera_staff}'='d2f38943c31031ee0fa051e57add33095908eed0806382d93984fb44d111a2eb')
  OR EXISTS(SELECT 1 FROM jsonb_to_recordset($sfera_expected$[{"sig":"clan_aburame_private.sfera_clear_arena_distance_v1(uuid,uuid,uuid)","src":"eb0baae14293899634255d12a254a5d2","secdef":true,"vol":"s","lang":"sql"},{"sig":"clan_aburame_private.sfera_crosses_prison_v1(uuid,uuid,uuid)","src":"fc740b7a30426a88fb7bd5d6bfb74119","secdef":true,"vol":"s","lang":"sql"},{"sig":"clan_aburame_private.sfera_defense_power_v1(uuid)","src":"37104a0476806913da988fec817933df","secdef":true,"vol":"s","lang":"plpgsql"},{"sig":"clan_aburame_private.sfera_end_v1(uuid,text)","src":"c1dfa1d61fce21fdcd5ae4487423dff7","secdef":true,"vol":"v","lang":"plpgsql"},{"sig":"clan_aburame_private.sfera_escape_meta_v1(uuid,jsonb)","src":"cede426e3aac765237cc11bdbd223c08","secdef":true,"vol":"s","lang":"plpgsql"},{"sig":"clan_aburame_private.sfera_finish_v1(uuid,uuid,boolean)","src":"cf2dcc5892839faa871fdea87704c1e5","secdef":true,"vol":"v","lang":"plpgsql"},{"sig":"clan_aburame_private.sfera_frozen_v1(uuid)","src":"49e26aecd1e6e8900a45ae08257daf22","secdef":true,"vol":"s","lang":"plpgsql"},{"sig":"clan_aburame_private.sfera_hits_v1(integer,text,boolean,jsonb,jsonb,jsonb)","src":"fdc1ee7ce46344a4fad4d95f9995a2f9","secdef":false,"vol":"i","lang":"sql"},{"sig":"clan_aburame_private.sfera_meta_v1(uuid,boolean)","src":"cef273b4908809d65ee217dfcf250490","secdef":true,"vol":"s","lang":"plpgsql"},{"sig":"clan_aburame_private.sfera_narrative_revision_v1(jsonb)","src":"1a189a0a5d39ac47745553f017bdfa7b","secdef":false,"vol":"i","lang":"plpgsql"},{"sig":"clan_aburame_private.sfera_narrative_v1(uuid,uuid)","src":"b0106668578462f3ca5ab2ee3ee6d23e","secdef":true,"vol":"s","lang":"sql"},{"sig":"clan_aburame_private.sfera_prepare_offer_v1(uuid)","src":"1f4fa63f2d2b40411c66622034730686","secdef":true,"vol":"s","lang":"sql"},{"sig":"clan_aburame_private.sfera_prison_active_v1(uuid,uuid)","src":"708d1f175973c3e2c7d76e74ccda47e1","secdef":true,"vol":"s","lang":"sql"},{"sig":"clan_aburame_private.sfera_report_v1(uuid)","src":"9508b6f8309ada672ba8fc5109fa064a","secdef":true,"vol":"s","lang":"sql"},{"sig":"clan_aburame_private.sfera_reserve_v1(uuid)","src":"37a3e13a9f6ab336d2e6f9b653c9c646","secdef":true,"vol":"v","lang":"plpgsql"},{"sig":"clan_aburame_private.sfera_resolve_escape_v1(uuid)","src":"c02719639f1142f995072ca3c0959659","secdef":true,"vol":"v","lang":"plpgsql"},{"sig":"clan_aburame_private.sfera_settle_round_v1(uuid)","src":"5ad3c0d6c98de683c6adc107ef9e5987","secdef":true,"vol":"v","lang":"plpgsql"},{"sig":"clan_aburame_private.sfera_staff_prepare_v1(uuid,uuid)","src":"2fd4f161bb1d30a025d8453838487c99","secdef":true,"vol":"v","lang":"plpgsql"},{"sig":"clan_aburame_private.sfera_staff_scope_v1(uuid,uuid,uuid)","src":"d3a5a5c986f4dd52d6384389b4e5ce35","secdef":true,"vol":"s","lang":"sql"},{"sig":"clan_aburame_private.sfera_staff_target_v1(uuid,uuid)","src":"df09d5c724779b527af0489175df0aee","secdef":true,"vol":"s","lang":"sql"},{"sig":"clan_aburame_private.sfera_upkeep_turn_v1(uuid,uuid)","src":"2f9dfbd32aae9416441774d7854532ca","secdef":true,"vol":"v","lang":"plpgsql"}]$sfera_expected$::jsonb)
       AS e(sig text,src text,secdef boolean,vol text,lang text)
      LEFT JOIN pg_proc p ON p.oid=to_regprocedure(e.sig) LEFT JOIN pg_language l ON l.oid=p.prolang
      WHERE p.oid IS NULL OR p.prokind<>'f' OR md5(p.prosrc) IS DISTINCT FROM e.src
       OR p.prosecdef IS DISTINCT FROM e.secdef OR p.provolatile::text IS DISTINCT FROM e.vol
       OR l.lanname IS DISTINCT FROM e.lang OR p.proowner IS DISTINCT FROM 'postgres'::regrole
       OR p.proconfig IS DISTINCT FROM ARRAY['search_path=""']
       OR has_function_privilege('anon',p.oid,'EXECUTE')
       OR has_function_privilege('authenticated',p.oid,'EXECUTE')
       OR has_function_privilege('service_role',p.oid,'EXECUTE'))
  OR (SELECT count(*) FROM pg_class c WHERE c.oid IN (to_regclass('clan_aburame_private.sfera_staff_gate_v1'),to_regclass('clan_aburame_private.sfera_sources_v1'),to_regclass('clan_aburame_private.sfera_upkeep_v1'))
     AND c.relkind='r' AND c.relrowsecurity AND c.relforcerowsecurity AND c.relowner='postgres'::regrole
     AND NOT has_table_privilege('anon',c.oid,'SELECT,INSERT,UPDATE,DELETE,TRUNCATE,REFERENCES,TRIGGER')
     AND NOT has_table_privilege('authenticated',c.oid,'SELECT,INSERT,UPDATE,DELETE,TRUNCATE,REFERENCES,TRIGGER')
     AND NOT has_table_privilege('service_role',c.oid,'SELECT,INSERT,UPDATE,DELETE,TRUNCATE,REFERENCES,TRIGGER'))<>3
  OR to_regclass('clan_aburame_private.sfera_active_source_per_actor_v1') IS NULL
  THEN RAISE EXCEPTION 'SFERA_STAFF_CAPABILITY_OR_OBJECT_DRIFT'; END IF;
-- Frammento per la composizione dopo osservazione di Sfera viva.
-- I marcatori sono deliberatamente inutilizzabili prima del bind della review.
 IF root#>>'{db_core,pill_staff}' IS NULL
 OR root#>>'{db_core,pill_staff}' NOT IN ('cf9238856c043a3e4cb20890293af8dc3be58e751141589c04c54bd7ca147c45','86c7b40969d82d5f6f0d885cfc7ab0d3fa89887f61ab901e586c2787a62e3386')
 OR root#>'{config,pill_staff}' IS DISTINCT FROM root#>'{db_core,pill_staff}'
 OR (SELECT g.staff_enabled FROM combat_panel_private.chakra_pill_staff_gate_v1 g WHERE g.singleton)
      IS DISTINCT FROM (root#>>'{db_core,pill_staff}'='cf9238856c043a3e4cb20890293af8dc3be58e751141589c04c54bd7ca147c45')
 OR (SELECT count(*) FROM combat_panel_private.chakra_pill_staff_gate_v1) IS DISTINCT FROM 1
 OR EXISTS (
     SELECT 1
     FROM jsonb_to_recordset($pill_expected$[{"lang":"sql","sig":"combat_panel_private.chakra_pill_rapid_claimed_v1(uuid,uuid,uuid)","src":"eb4303ec1c1f5d65e9b7f4600dfb55e6","vol":"s"},{"lang":"sql","sig":"combat_panel_private.chakra_pill_other_rapid_v1(uuid,uuid,uuid)","src":"cb5c7eb4aa9990c1d42eeb6e8aa1bb30","vol":"s"},{"lang":"plpgsql","sig":"combat_panel_private.chakra_pill_staff_rapid_guard_v1()","src":"ebf0ebc83a5d98ade4e878ede137d04c","vol":"v"},{"lang":"plpgsql","sig":"combat_panel_private.chakra_pill_staff_turn_v1(uuid,uuid)","src":"42070cb0fd44724b4bda361b4952e416","vol":"s"},{"lang":"plpgsql","sig":"combat_panel_private.chakra_pill_staff_offers_v1(uuid,bigint)","src":"3075cde465ea0e9e30c5ad4a7120dad2","vol":"v"},{"lang":"sql","sig":"combat_panel_private.chakra_pill_hide_control_v1(jsonb,uuid,uuid)","src":"c1d26e3a0e157441b82a3d6de80d9259","vol":"s"},{"lang":"plpgsql","sig":"combat_panel_private.chakra_pill_staff_commit_v1(jsonb)","src":"1db72307bb63e177da9a7cac2bb648d5","vol":"v"}]$pill_expected$::jsonb)
            AS e(sig text,src text,vol text,lang text)
     LEFT JOIN pg_proc p ON p.oid=to_regprocedure(e.sig)
     LEFT JOIN pg_language l ON l.oid=p.prolang
     WHERE p.oid IS NULL OR p.prokind<>'f' OR md5(p.prosrc) IS DISTINCT FROM e.src
        OR l.lanname IS DISTINCT FROM e.lang OR p.provolatile::text IS DISTINCT FROM e.vol
        OR p.proowner IS DISTINCT FROM 'postgres'::regrole OR p.prosecdef IS DISTINCT FROM true
        OR p.proconfig IS DISTINCT FROM ARRAY['search_path=""']
        OR p.proacl::text IS DISTINCT FROM '{postgres=X/postgres}'
        OR has_function_privilege('anon',p.oid,'EXECUTE')
        OR has_function_privilege('authenticated',p.oid,'EXECUTE')
        OR has_function_privilege('service_role',p.oid,'EXECUTE')
 )
 OR (SELECT count(*) FROM pg_class c
     WHERE c.oid IN (to_regclass('combat_panel_private.chakra_pill_staff_gate_v1'),
                     to_regclass('combat_panel_private.chakra_pill_staff_uses_v1'))
       AND c.relkind='r' AND c.relpersistence='p' AND c.relowner='postgres'::regrole
       AND c.relrowsecurity AND c.relforcerowsecurity
       AND NOT EXISTS (SELECT 1 FROM aclexplode(coalesce(c.relacl,acldefault('r',c.relowner))) a WHERE a.grantee<>c.relowner)
       AND NOT has_table_privilege('anon',c.oid,'SELECT,INSERT,UPDATE,DELETE,TRUNCATE,REFERENCES,TRIGGER')
       AND NOT has_table_privilege('authenticated',c.oid,'SELECT,INSERT,UPDATE,DELETE,TRUNCATE,REFERENCES,TRIGGER')
       AND NOT has_table_privilege('service_role',c.oid,'SELECT,INSERT,UPDATE,DELETE,TRUNCATE,REFERENCES,TRIGGER')) IS DISTINCT FROM 2
 OR (SELECT count(*) FROM pg_trigger t
     WHERE t.tgrelid IN (to_regclass('clan_innata_combat_private.combat_receipts'),
                         to_regclass('clan_akimichi_private.common_form_commands_v1'),
                         to_regclass('public.combat_v2_declarations'))
      AND t.tgname='chakra_pill_rapid_guard_v1' AND t.tgenabled='O' AND t.tgtype=7 AND NOT t.tgisinternal
      AND t.tgfoid=to_regprocedure('combat_panel_private.chakra_pill_staff_rapid_guard_v1()')
      AND t.tgqual IS NULL AND octet_length(t.tgargs)=0) IS DISTINCT FROM 3
 -- Il confronto canonico di colonne, vincoli e indici resta un predicato obbligatorio.
 OR public.combat_v2_sha256((SELECT jsonb_agg(jsonb_build_object('schema',n.nspname,'table',c.relname,
   'columns',(SELECT jsonb_agg(jsonb_build_array(a.attname,format_type(a.atttypid,a.atttypmod),
     a.attnotnull,pg_get_expr(d.adbin,d.adrelid)) ORDER BY a.attnum)
     FROM pg_attribute a LEFT JOIN pg_attrdef d ON d.adrelid=a.attrelid AND d.adnum=a.attnum
     WHERE a.attrelid=c.oid AND a.attnum>0 AND NOT a.attisdropped AND a.attidentity='' AND a.attgenerated=''),
   'constraints',(SELECT jsonb_agg(k.description ORDER BY k.description COLLATE "C")
      FROM (SELECT lower(regexp_replace(pg_get_constraintdef(v.oid),'[[:space:]()"]+','','g')) description
       FROM pg_constraint v WHERE v.conrelid=c.oid AND v.convalidated AND NOT v.condeferrable AND NOT v.condeferred) k),
   'indexes',(SELECT jsonb_agg(jsonb_build_array(i.indkey::text,i.indisprimary,i.indisunique,
       i.indisvalid,i.indisready,i.indislive) ORDER BY i.indkey::text COLLATE "C")
      FROM pg_index i WHERE i.indrelid=c.oid AND i.indpred IS NULL AND i.indexprs IS NULL
        AND i.indnatts=i.indnkeyatts AND i.indimmediate AND NOT i.indnullsnotdistinct)) ORDER BY n.nspname,c.relname)
 FROM pg_class c JOIN pg_namespace n ON n.oid=c.relnamespace
 WHERE c.oid IN (to_regclass('combat_panel_private.chakra_pill_staff_gate_v1'),to_regclass('combat_panel_private.chakra_pill_staff_uses_v1')))) IS DISTINCT FROM public.combat_v2_sha256('[{"columns":[["singleton","boolean",true,"true"],["staff_enabled","boolean",true,"false"]],"constraints":["checksingleton","primarykeysingleton"],"indexes":[["1",true,true,true,true,true]],"schema":"combat_panel_private","table":"chakra_pill_staff_gate_v1"},{"columns":[["session_id","uuid",true,null],["round_id","uuid",true,null],["actor_id","uuid",true,null],["personal_turn_id","uuid",true,null],["principal_user","uuid",true,null],["request_key","uuid",true,null],["receipt_id","uuid",true,null],["item_id","uuid",true,null],["chakra_before","integer",true,null],["chakra_after","integer",true,null],["chakra_max","integer",true,null],["simulated","boolean",true,"true"],["values_written","boolean",true,"false"],["charge_spent","integer",true,"1"],["created_at","timestamp with time zone",true,"clock_timestamp()"]],"constraints":["checkchakra_after-chakra_before=least30,chakra_max-chakra_before","checkchakra_before<chakra_afterandchakra_after<=chakra_max","checkchakra_before>=0","checkcharge_spent=1","checkitem_id=''916d3fab-ba73-4cdb-99ea-7da14a03c284''::uuid","checknotvalues_written","checksimulated","foreignkeyactor_idreferencespublic.combat_v2_actorsid","foreignkeyitem_idreferencespublic.itemsid","foreignkeyround_idreferencespublic.combat_v2_roundsid","foreignkeysession_idreferencespublic.combat_v2_sessionsid","primarykeysession_id,actor_id","uniqueprincipal_user,request_key","uniquereceipt_id"],"indexes":[["1 3",true,true,true,true,true],["5 6",false,true,true,true,true],["7",false,true,true,true,true]],"schema":"combat_panel_private","table":"chakra_pill_staff_uses_v1"}]'::jsonb)
 THEN RAISE EXCEPTION 'PILL_STAFF_CAPABILITY_OR_OBJECT_DRIFT'; END IF;
 RETURN true;
END $function$;
DO $pill_post$
#variable_conflict error
DECLARE 
 rr mission_factory_owner.editor_release_readiness%ROWTYPE;
 prior_release mission_public_owner.release_admissions_v1%ROWTYPE;
 prior_qualification mission_public_owner.public_qualification_attestations_v1%ROWTYPE;
 runtime_before jsonb; review jsonb; root_text text; candidate_root jsonb; resources_before jsonb;
 db_sha text; config_sha text; new_root_sha text; old_root_sha text; old_row_sha text;
 bindings jsonb; qualification jsonb; content_payload jsonb; content_request uuid;
 content_row mission_public_owner.mission_content_admissions_v1%ROWTYPE; profile_row record;
 params jsonb; affected integer;
 namespace_uuid constant uuid:='5d20915b-9e97-5eca-8851-fd9f7f4c842a';
 generic_ezbr constant text:='9a6889802cfa17c99a556538cccd4ad7ef75274d32adccbc192c23d257aa3e76';
BEGIN
 SELECT * INTO STRICT rr FROM mission_factory_owner.editor_release_readiness WHERE singleton FOR UPDATE;
 IF rr.revision_sha256 IS DISTINCT FROM '799e64f09637b5a7d331c3faf931ccab0c114cf33565c78b1cb40feefec82967'
   OR public.combat_v2_sha256(to_jsonb(rr)) IS DISTINCT FROM 'c9fbedb4c16ffb8fca6e31b6f6c4d2792fe72131c6f7d8bc6c5ccf7d7ab55b8c'
   OR (SELECT staff_enabled FROM combat_panel_private.chakra_pill_staff_gate_v1 WHERE singleton) IS DISTINCT FROM false
   OR EXISTS(SELECT 1 FROM combat_panel_private.chakra_pill_staff_uses_v1)
 THEN RAISE EXCEPTION 'PILL_STAGED_OBJECT_DRIFT'; END IF;
 IF EXISTS(SELECT 1 FROM jsonb_to_recordset('[{"acl":"{postgres=X/postgres}","ddl_md5":"19c0226969fc069225a14c65a5d563e9","ddl_sha256":"a3d468831fa5a16a3dc0ef1bab71a4b39245292d5dd9983f2589320a3f1d7358","oid":"44940","owner":"postgres","sig":"combat_panel_private.master_options(uuid,uuid,bigint)","source_md5":"ad3cec069a1a0c5ab4a4a804de12bbec"},{"acl":"{postgres=X/postgres}","ddl_md5":"ff85a0b898d7635043ba47df4a304afd","ddl_sha256":"8055222d421ed9b07446ac66124172bc40de466b50c8b62765afcf08b265807d","oid":"44669","owner":"postgres","sig":"combat_panel_private.ordinary_options(uuid,uuid,bigint)","source_md5":"0e0226a9138c221d59a073d161d7a759"},{"acl":"{postgres=X/postgres,authenticated=X/postgres}","ddl_md5":"83b8cd6b6c06835579d573a08eaacd4b","ddl_sha256":"547eb53046d06f4947903862d69473a15364e45be294d6435b00e285b560d2b6","oid":"44808","owner":"postgres","sig":"public.combat_panel_commit_v1(jsonb)","source_md5":"427e6ecda3eeb2c2a141aa077ea7f0a9"},{"acl":"{postgres=X/postgres}","ddl_md5":"385cfe6490299ce6694d31d307acf36d","ddl_sha256":"85d1d252592ebb9baf654e64e61007089713d6f689ec01ac4c6ce5b72a510ca5","oid":"684829","owner":"postgres","sig":"clan_innata_private.catalogo_eligibility_release_v1()","source_md5":"0b45f09f8f4d1257fb50461bde8a7c11"}]'::jsonb)
   AS e(sig text, oid text, owner text, acl text, source_md5 text, ddl_sha256 text)
   LEFT JOIN pg_proc p ON p.oid=to_regprocedure(e.sig)
   WHERE p.oid::text IS DISTINCT FROM e.oid OR p.proowner::regrole::text IS DISTINCT FROM e.owner
      OR p.proacl::text IS DISTINCT FROM e.acl OR md5(p.prosrc) IS DISTINCT FROM e.source_md5
      OR encode(extensions.digest(convert_to(pg_get_functiondef(p.oid),'UTF8'),'sha256'),'hex') IS DISTINCT FROM e.ddl_sha256)
   THEN RAISE EXCEPTION 'PILL_AFTER_FUNCTION_DRIFT'; END IF;
 SELECT * INTO STRICT prior_release FROM mission_public_owner.release_admissions_v1
 WHERE release_sha256=rr.revision_sha256 FOR SHARE;
 SELECT * INTO STRICT prior_qualification FROM mission_public_owner.public_qualification_attestations_v1
 WHERE release_sha256=rr.revision_sha256 FOR SHARE;
 SELECT to_jsonb(x) INTO STRICT runtime_before FROM mission_public_owner.party_launch_runtime_v1 x WHERE singleton FOR UPDATE;
 IF prior_release.edge_sha256 IS DISTINCT FROM generic_ezbr
 OR public.combat_v2_sha256(prior_qualification.payload->'capabilities') IS DISTINCT FROM '49fe134f561273f28e8071b63c45886341371b67d028f06e6b7d8f8d4108e817'
 OR runtime_before IS DISTINCT FROM jsonb_set('{"public_enabled":true,"release_sha256":"799e64f09637b5a7d331c3faf931ccab0c114cf33565c78b1cb40feefec82967","singleton":true,"staff_enabled":true}'::jsonb,'{release_sha256}',to_jsonb(rr.revision_sha256),false)
 OR (SELECT count(*) FROM mission_public_owner.mission_content_admissions_v1 c
   WHERE c.engine_release_sha256=rr.revision_sha256 ) IS DISTINCT FROM 2
 OR (SELECT count(DISTINCT profile_key) FROM mission_public_owner.engine_profile_events_v1
     WHERE engine_release_sha256=rr.revision_sha256) IS DISTINCT FROM 1
 
  OR public.combat_v2_sha256(to_jsonb(prior_release)) IS DISTINCT FROM 'e2ae6fdf1e7e3a72b3f1fdc76cc063ec607bb5ca9e0d96f6909dfdda9bdf7942'
  OR public.combat_v2_sha256(to_jsonb(prior_qualification)) IS DISTINCT FROM 'eb08ac35bfeab131ded260da2d80ed2633b7106cd98a5b47840cb57c9b57b343'
  OR (SELECT public.combat_v2_sha256(jsonb_agg(to_jsonb(c) ORDER BY c.mission_id,c.request_key))
    FROM mission_public_owner.mission_content_admissions_v1 c WHERE c.engine_release_sha256=rr.revision_sha256)
    IS DISTINCT FROM 'a01dbcdf8d7c79b9419110c19f1c73f21efa08fd71df1f179126540f50442cec'
  OR (SELECT public.combat_v2_sha256(jsonb_agg(to_jsonb(p) ORDER BY p.profile_key)) FROM (
    SELECT DISTINCT ON (z.profile_key) * FROM mission_public_owner.engine_profile_events_v1 z
    WHERE z.engine_release_sha256=rr.revision_sha256 ORDER BY z.profile_key,z.control_version DESC) p)
    IS DISTINCT FROM '1efc7804236a53fd3b2a42c7843f439196433e35b085d304ce5eef49486fff88'

 
 THEN RAISE EXCEPTION 'PILL_PARENT_MISSION_BOUNDARY'; END IF;
 root_text:=current_setting('app.pill_release_root');
 review:=current_setting('app.pill_release_review')::jsonb;
 resources_before:=current_setting('app.pill_release_resources')::jsonb;
 old_root_sha:=rr.revision_sha256;
 old_row_sha:=public.combat_v2_sha256(to_jsonb(rr));
 candidate_root:=root_text::jsonb;
 db_sha:=candidate_root#>>'{db_core,sha256}'; config_sha:=candidate_root#>>'{config,sha256}';
 new_root_sha:=encode(extensions.digest(convert_to(root_text,'UTF8'),'sha256'),'hex');
 IF new_root_sha IS DISTINCT FROM 'de34836ca073cda7dcf5d5920ff39d131d0da200a4100ac7589fea6f33663c3f'
   OR octet_length(root_text) IS DISTINCT FROM 524230 OR octet_length(root_text)>524288
   OR db_sha IS DISTINCT FROM public.combat_v2_sha256((candidate_root->'db_core')-'sha256')
   OR config_sha IS DISTINCT FROM public.combat_v2_sha256((candidate_root->'config')-'sha256')
   OR candidate_root#>>'{db_core,pill_staff}' IS DISTINCT FROM 'cf9238856c043a3e4cb20890293af8dc3be58e751141589c04c54bd7ca147c45'
   OR candidate_root#>>'{config,pill_staff}' IS DISTINCT FROM 'cf9238856c043a3e4cb20890293af8dc3be58e751141589c04c54bd7ca147c45'
   OR candidate_root#>>'{db_core,sfera_staff}' IS DISTINCT FROM 'd2f38943c31031ee0fa051e57add33095908eed0806382d93984fb44d111a2eb'
   OR candidate_root#>>'{db_core,velo_staff}' IS DISTINCT FROM '35d754465f1c19509822e9728ade3e23c3d2aefe63f441aff01908e774dfcef6'
   OR public.combat_v2_sha256(candidate_root->'ui') IS DISTINCT FROM 'b62cac808730c14ff1558ac666b3a76c3cc264e4716b858205acada9efadefc9'
   OR public.combat_v2_sha256(candidate_root->'edge_bundles') IS DISTINCT FROM '67ee310b994f65492aa094f6f3f6e435aa2faf95d98246bbc6b00b90afc9c783'
 THEN RAISE EXCEPTION 'PILL_FINAL_ROOT_BINDING'; END IF;
 params:='{"compatibility":{"ref":"pillola-staff-staff-existing-missions","sha256":"cf9238856c043a3e4cb20890293af8dc3be58e751141589c04c54bd7ca147c45"},"expected_mission_capabilities_sha256":"49fe134f561273f28e8071b63c45886341371b67d028f06e6b7d8f8d4108e817"}'::jsonb;
 bindings:=jsonb_build_object('db_sha256',db_sha,'edge_sha256',generic_ezbr,
   'client_sha256',public.combat_v2_sha256(candidate_root->'ui'),'configuration_sha256',config_sha);
 UPDATE mission_factory_owner.editor_release_readiness
 SET canonical_preimage=root_text,revision_sha256=new_root_sha,observed_revision_sha256=new_root_sha,
   client_build='mission-factory-admin/2:'||new_root_sha,independent_review_ref=review->>'ref',updated_at=clock_timestamp()
 WHERE singleton AND revision_sha256=old_root_sha AND public.combat_v2_sha256(to_jsonb(editor_release_readiness))=old_row_sha;
 GET DIAGNOSTICS affected=ROW_COUNT;
 IF affected<>1 THEN RAISE EXCEPTION 'PILL_ROOT_CAS'; END IF;
 UPDATE combat_panel_private.chakra_pill_staff_gate_v1 SET staff_enabled=true
 WHERE singleton AND staff_enabled IS NOT DISTINCT FROM false;
 GET DIAGNOSTICS affected=ROW_COUNT;
 IF affected<>1 THEN RAISE EXCEPTION 'PILL_GATE_CAS'; END IF;
 IF NOT clan_innata_private.catalogo_eligibility_release_v1() THEN RAISE EXCEPTION 'PILL_POST_CAS_E52'; END IF;
 PERFORM clan_innata_private.runtime_release_assert();
  INSERT INTO mission_public_owner.release_admissions_v1(release_sha256,db_sha256,edge_sha256,client_sha256,configuration_sha256,
  contract_version,independent_review_ref,staff_evidence_ref,qualified_at,public_enabled)
 VALUES(new_root_sha,db_sha,generic_ezbr,bindings->>'client_sha256',config_sha,prior_release.contract_version,
  review->>'ref',prior_release.staff_evidence_ref,prior_release.qualified_at,prior_release.public_enabled);
 FOR profile_row IN SELECT DISTINCT ON(profile_key)* FROM mission_public_owner.engine_profile_events_v1
  WHERE engine_release_sha256=old_root_sha ORDER BY profile_key,control_version DESC LOOP
  IF profile_row.profile_key IS DISTINCT FROM prior_qualification.payload->>'authoring_profile' THEN
   RAISE EXCEPTION 'PILL_ROOT_UNQUALIFIED_PROFILE_CARRYFORWARD';END IF;
  INSERT INTO mission_public_owner.engine_profile_events_v1(event_id,engine_release_sha256,profile_key,expected_control_version,
   control_version,authoring_enabled,runtime_enabled,actor_user,reason)
  VALUES(extensions.uuid_generate_v5(namespace_uuid,new_root_sha||':profile:'||profile_row.profile_key),new_root_sha,profile_row.profile_key,
   0,1,profile_row.authoring_enabled,profile_row.runtime_enabled,profile_row.actor_user,
   'Compatible carryforward of existing mission profile only; new catalog techniques have no Staff PASS');
 END LOOP;
 qualification:=prior_qualification.payload||jsonb_build_object('revision_sha256',new_root_sha,'bindings',bindings,'independent_review',review,
  'reuse_evidence',(prior_qualification.payload->'reuse_evidence')||jsonb_build_object('new_mission_QA_claim',false,
   'catalogo_compatibility',jsonb_build_object('parent_root',old_root_sha,'ref',params#>'{compatibility,ref}',
    'sha256',params#>'{compatibility,sha256}','scope','existing_mission_capabilities_only','new_techniques_staff_pass',false)));
 INSERT INTO mission_public_owner.public_qualification_attestations_v1(release_sha256,request_key,payload,payload_sha256,
  positive_staff_evidence_ref,authorized_test_manifest_ref,created_by)
 VALUES(new_root_sha,extensions.uuid_generate_v5(namespace_uuid,new_root_sha||':qualification'),qualification,mission_factory_owner.sha(qualification),
  prior_qualification.positive_staff_evidence_ref,prior_qualification.authorized_test_manifest_ref,prior_qualification.created_by);
 IF qualification->'capabilities' IS DISTINCT FROM prior_qualification.payload->'capabilities'
 OR public.combat_v2_sha256(qualification->'capabilities') IS DISTINCT FROM params->>'expected_mission_capabilities_sha256'
 OR mission_public_owner.engine_qualification_v1(new_root_sha,true)IS NULL THEN RAISE EXCEPTION 'PILL_ROOT_MISSION_CARRYFORWARD_INVALID';END IF;
 FOR content_row IN SELECT * FROM mission_public_owner.mission_content_admissions_v1 WHERE engine_release_sha256=old_root_sha ORDER BY mission_id LOOP
  content_request:=extensions.uuid_generate_v5(content_row.request_key,new_root_sha||':catalogo-compatible-adoption');
  content_payload:=content_row.payload||jsonb_build_object('request_key',content_request,'engine_release_sha256',new_root_sha,'created_at',clock_timestamp());
  INSERT INTO mission_public_owner.mission_content_admissions_v1(request_key,mission_id,config_version,engine_release_sha256,publication_request,payload,payload_sha256)
  VALUES(content_request,content_row.mission_id,content_row.config_version,new_root_sha,content_row.publication_request,content_payload,mission_factory_owner.sha(content_payload));
  IF mission_public_owner.content_admission_v1(content_row.mission_id,new_root_sha,content_row.publication_request,true)IS NULL THEN
   RAISE EXCEPTION 'PILL_ROOT_CONTENT_CARRYFORWARD_INVALID';END IF;
 END LOOP;
 UPDATE mission_public_owner.party_launch_runtime_v1 x SET release_sha256=new_root_sha WHERE singleton AND to_jsonb(x)=runtime_before;
 GET DIAGNOSTICS affected=ROW_COUNT;IF affected<>1 THEN RAISE EXCEPTION 'PILL_ROOT_PARTY_RUNTIME_CAS';END IF;

 IF (SELECT count(*) FROM mission_public_owner.mission_content_admissions_v1 c
     WHERE c.engine_release_sha256=new_root_sha
       AND mission_public_owner.content_admission_v1(c.mission_id,new_root_sha,c.publication_request,true) IS NOT NULL) IS DISTINCT FROM 2
   OR (SELECT to_jsonb(x) FROM mission_public_owner.party_launch_runtime_v1 x WHERE singleton)
      IS DISTINCT FROM jsonb_set(runtime_before,'{release_sha256}',to_jsonb(new_root_sha),false)
   OR resources_before IS DISTINCT FROM jsonb_build_object(
'characters', (SELECT public.combat_v2_sha256(coalesce(jsonb_agg(to_jsonb(row_data) ORDER BY to_jsonb(row_data)::text),'[]'::jsonb)) FROM public.characters row_data WHERE row_data.id IN ('2a877f02-4993-4e65-9172-7d29f08c5b86'::uuid,'6bceee99-974f-426b-8d92-38b43b4a4267'::uuid)),
'character_inventory', (SELECT public.combat_v2_sha256(coalesce(jsonb_agg(to_jsonb(row_data) ORDER BY to_jsonb(row_data)::text),'[]'::jsonb)) FROM public.character_inventory row_data WHERE row_data.character_id IN ('2a877f02-4993-4e65-9172-7d29f08c5b86'::uuid,'6bceee99-974f-426b-8d92-38b43b4a4267'::uuid)),
'character_equipment', (SELECT public.combat_v2_sha256(coalesce(jsonb_agg(to_jsonb(row_data) ORDER BY to_jsonb(row_data)::text),'[]'::jsonb)) FROM public.character_equipment row_data WHERE row_data.character_id IN ('2a877f02-4993-4e65-9172-7d29f08c5b86'::uuid,'6bceee99-974f-426b-8d92-38b43b4a4267'::uuid)),
'character_abilities', (SELECT public.combat_v2_sha256(coalesce(jsonb_agg(to_jsonb(row_data) ORDER BY to_jsonb(row_data)::text),'[]'::jsonb)) FROM public.character_abilities row_data WHERE row_data.character_id IN ('2a877f02-4993-4e65-9172-7d29f08c5b86'::uuid,'6bceee99-974f-426b-8d92-38b43b4a4267'::uuid)),
'character_jutsu', (SELECT public.combat_v2_sha256(coalesce(jsonb_agg(to_jsonb(row_data) ORDER BY to_jsonb(row_data)::text),'[]'::jsonb)) FROM public.character_jutsu row_data JOIN public.characters owner ON owner.user_id=row_data.user_id WHERE owner.id IN ('2a877f02-4993-4e65-9172-7d29f08c5b86'::uuid,'6bceee99-974f-426b-8d92-38b43b4a4267'::uuid)))
 THEN RAISE EXCEPTION 'PILL_FINAL_MISSION_OR_RESOURCES_BOUNDARY'; END IF;
 PERFORM set_config('app.pill_release_result',jsonb_build_object('previous_root',old_root_sha,'root',new_root_sha,
  'root_bytes',octet_length(root_text),'staff_enabled',true,'public_enabled',false,'provider_calls',0,
  'staff_gameplay','NOT_RUN','two_mission_admissions',true,'protected_resources_identical',true)::text,true);

END;
$pill_post$;

SELECT current_setting('app.pill_release_result',true)::jsonb AS release_receipt;
COMMIT;
