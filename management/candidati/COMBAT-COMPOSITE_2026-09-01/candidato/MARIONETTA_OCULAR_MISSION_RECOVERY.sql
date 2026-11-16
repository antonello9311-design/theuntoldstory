-- Interrompe solo le nuove emissioni. Le marionette già attestate restano leggibili da Combat e dal Fato.
BEGIN;
SET LOCAL lock_timeout = '3s';
SET LOCAL statement_timeout = '30s';
UPDATE clan_marionettisti_private.mission_companion_release_v1
SET land_enabled=false,updated_at=clock_timestamp()
WHERE singleton AND land_enabled;

UPDATE clan_marionettisti_private.mission_companion_entitlements_v1 entitlement
SET staff_enabled=false
FROM mission_creation_owner.h3_staff_source_requests source
JOIN mission_generic_owner.plan_revisions revision
  ON revision.plan_version_id=(source.result->>'plan_version_id')::uuid
 AND revision.mission_id=source.mission_id
WHERE source.request_key='14136a56-0f58-41b2-ae24-8f7f3acbb4b2'::uuid
  AND entitlement.definition_id=revision.definition_id
  AND entitlement.staff_enabled AND NOT entitlement.land_enabled;
DO $pin$
DECLARE f regprocedure:=to_regprocedure('public.mission_human_staff_source_create_v1(uuid,jsonb,uuid)');
BEGIN
 IF f IS NULL OR md5(pg_get_functiondef(f)) NOT IN ('0a55e640f29e34221aa5cf26d64a5c84','ecf5d7d74d746f437ca8bfe12cc25a56')
 THEN RAISE EXCEPTION 'FILI_STAFF_AUTHORING_RESTORE_DRIFT' USING ERRCODE='40001'; END IF;
END $pin$;

CREATE OR REPLACE FUNCTION public.mission_human_staff_source_create_v1(p_request uuid, p_document jsonb, p_location uuid)
 RETURNS jsonb
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO ''
AS $function$
DECLARE old record;pf jsonb;validation jsonb;m jsonb;
 mid uuid;doc_sha text;result jsonb;scene jsonb;enc jsonb;actor jsonb;enc_count integer:=0;
 named_ai boolean:=false;expected_xp integer:=30;pin record;reference jsonb;
BEGIN
 IF auth.uid() IS NULL OR auth.role() IS DISTINCT FROM 'authenticated' OR p_request IS NULL
 OR p_location IS DISTINCT FROM '0b85f354-9cdb-47e1-baf9-3d266bb7e06b'::uuid
 THEN RAISE EXCEPTION 'H3_STAFF_SOURCE_AUTHORITY' USING ERRCODE='42501'; END IF;
 PERFORM mission_ai_board_owner.staff_only();
 PERFORM 1 FROM public.locations WHERE id=p_location AND is_active AND is_test FOR SHARE;
 IF NOT FOUND OR NOT public.master_v2_is_master(auth.uid())
 OR combat_consumer_private.staff_test_allowed(p_location,ARRAY[auth.uid()],false) IS DISTINCT FROM true
 THEN RAISE EXCEPTION 'H3_STAFF_SOURCE_AUTHORITY' USING ERRCODE='42501'; END IF;
 doc_sha:=mission_internal.fingerprint(p_document);
 -- Named authoring only. This creates neither an admission nor a Service session.
 named_ai:=doc_sha='e7c1cfc8ea3fdf59753fc8457718f34ca119dce0f24368c00d34ef8a5298b028';
 IF named_ai THEN
  IF auth.uid() NOT IN ('f0856d53-83a6-4de0-bc0c-12c87916e665'::uuid,'15448f47-3b43-416f-a703-dbe7a74d36ce'::uuid)
   OR NOT EXISTS(SELECT 1 FROM public.characters ch WHERE ch.id='6bceee99-974f-426b-8d92-38b43b4a4267'::uuid AND ch.user_id='f0856d53-83a6-4de0-bc0c-12c87916e665'::uuid)
   OR NOT EXISTS(SELECT 1 FROM public.characters ch WHERE ch.id='2a877f02-4993-4e65-9172-7d29f08c5b86'::uuid AND ch.user_id='15448f47-3b43-416f-a703-dbe7a74d36ce'::uuid)
  THEN RAISE EXCEPTION 'H3_STAFF_SOURCE_TACTICS_PRINCIPALS' USING ERRCODE='42501';END IF;
  expected_xp:=0;
 END IF;
 PERFORM pg_advisory_xact_lock(hashtextextended('mission-create:'||p_request::text,611));
 SELECT * INTO old FROM mission_creation_owner.h3_staff_source_requests WHERE request_key=p_request;
 IF FOUND THEN
  IF old.actor_user IS DISTINCT FROM auth.uid() OR old.document_sha256 IS DISTINCT FROM doc_sha
  THEN RAISE EXCEPTION 'H3_STAFF_SOURCE_REPLAY_CONFLICT' USING ERRCODE='40001'; END IF;
  RETURN old.result;
 END IF;
 IF EXISTS(SELECT 1 FROM mission_creation_owner.requests WHERE request_key=p_request)
 THEN RAISE EXCEPTION 'H3_STAFF_SOURCE_REQUEST_CONFLICT' USING ERRCODE='40001'; END IF;
 IF named_ai THEN
  -- Serialize different request keys for this one frozen authoring input.
  PERFORM pg_advisory_xact_lock(hashtextextended('mission-create-document:'||doc_sha,611));
  IF EXISTS(SELECT 1 FROM mission_creation_owner.h3_staff_source_requests r WHERE r.document_sha256=doc_sha)
  THEN RAISE EXCEPTION 'H3_STAFF_SOURCE_TACTICS_ALREADY_CREATED' USING ERRCODE='40001';END IF;
  FOR pin IN SELECT * FROM (VALUES
   ('31da0000-0000-4000-8000-000000000201'::uuid,'31da0000-0000-4000-8000-000000000211'::uuid,'31da0000-0000-4000-8000-000000000301'::uuid,'31da0000-0000-4000-8000-000000000101'::uuid,'31da0000-0000-4000-8000-000000000111'::uuid,'5581b06099e588b27361cdf75e0e6265475c330802f61034c6ad67ca3d381ad2','c67d27b6-3e2d-4e91-beeb-e8c5cd1590f8'::uuid,'901a6a8b17fa8e2038ce5230f835ac95135688631ddd0816ec40f0333e9f0d5a'),
   ('31da0000-0000-4000-8000-000000000202'::uuid,'31da0000-0000-4000-8000-000000000212'::uuid,'31da0000-0000-4000-8000-000000000302'::uuid,'31da0000-0000-4000-8000-000000000102'::uuid,'31da0000-0000-4000-8000-000000000112'::uuid,'bbe92ed1b3dd171c6498f1a1541ad6b391c80e015956ae748c1eeece17f99fac','628d7118-a9e3-43d2-8dbd-2cbac0736205'::uuid,'45592ba1e150f55230d6429f7cf6ef02bebc510118301bcf93c37c0d07635e84')
  ) AS pins(nt,nv,binding,mt,mv,mechanical_sha,bundle,bundle_sha) LOOP
   PERFORM 1 FROM public.nb_mechanical_bindings mb
    JOIN public.nb_mechanical_versions mv ON mv.id=mb.mechanical_version_id AND mv.template_id=mb.mechanical_template_id
    JOIN public.nb_template_versions nv ON nv.id=mb.narrative_version_id AND nv.template_id=mb.narrative_template_id
    JOIN public.nb_templates nt ON nt.id=nv.template_id
    JOIN png_builder_internal.bundles b ON b.id=pin.bundle AND b.template_id=nt.id
   WHERE mb.id=pin.binding AND mb.narrative_template_id=pin.nt AND mb.narrative_version_id=pin.nv
    AND mb.mechanical_template_id=pin.mt AND mb.mechanical_version_id=pin.mv
    AND mv.content_sha256=pin.mechanical_sha AND b.bundle_sha256=pin.bundle_sha
   FOR SHARE OF mb,mv,nv,nt,b;
   IF NOT FOUND THEN RAISE EXCEPTION 'H3_STAFF_SOURCE_TACTICS_PROFILE_DRIFT' USING ERRCODE='40001';END IF;
   reference:=mission_factory_owner.npc_reference(pin.nt,pin.bundle,true);
   IF reference->>'bundle_sha256' IS DISTINCT FROM pin.bundle_sha
    OR reference->>'narrative_version_id' IS DISTINCT FROM pin.nv::text
    OR reference->>'mechanical_binding_id' IS DISTINCT FROM pin.binding::text
    OR reference->>'mechanical_version_id' IS DISTINCT FROM pin.mv::text
    OR reference->'combat' IS DISTINCT FROM 'true'::jsonb
   THEN RAISE EXCEPTION 'H3_STAFF_SOURCE_TACTICS_PROFILE_DRIFT' USING ERRCODE='40001';END IF;
  END LOOP;
 END IF;
 pf:=mission_creation_owner.preflight_document_v2(p_document);
 IF (pf->>'ok')::boolean IS DISTINCT FROM true
 THEN RAISE EXCEPTION 'H3_STAFF_SOURCE_PREFLIGHT:%',pf->'errors' USING ERRCODE='22023'; END IF;
 m:=p_document->'mission';
 IF (NOT named_ai AND m->>'direction_mode' IS DISTINCT FROM 'human')
 OR (named_ai AND (m->>'direction_mode' IS DISTINCT FROM 'ai' OR m->>'team_min' IS DISTINCT FROM '2' OR m->>'team_max' IS DISTINCT FROM '2'))
 OR (m->>'team_min' IN ('1','2','3','4')) IS NOT TRUE
 OR (m->>'team_max' IN ('1','2','3','4')) IS NOT TRUE
 OR (m->>'team_min')::integer > (m->>'team_max')::integer
 OR p_document#>>'{plan,base_plan_version_id}' IS NOT NULL
 THEN RAISE EXCEPTION 'H3_STAFF_SOURCE_SCOPE' USING ERRCODE='22023'; END IF;
 FOR scene IN SELECT value FROM jsonb_array_elements(p_document#>'{plan,definition,scenes}') LOOP
  FOR enc IN SELECT value FROM jsonb_array_elements(coalesce(scene->'encounters','[]'::jsonb)) LOOP
   enc_count:=enc_count+1;
   IF (jsonb_array_length(enc->'actors') BETWEEN 1 AND 4) IS NOT TRUE
   THEN RAISE EXCEPTION 'H4_STAFF_SOURCE_PNG_COUNT' USING ERRCODE='22023'; END IF;
   IF EXISTS(SELECT 1 FROM jsonb_array_elements(enc->'actors') a WHERE nullif(a->>'actor_key','') IS NULL)
    OR (SELECT count(DISTINCT a->>'actor_key') FROM jsonb_array_elements(enc->'actors') a) <> jsonb_array_length(enc->'actors')
   THEN RAISE EXCEPTION 'H4_STAFF_SOURCE_DISTINCT_ACTORS' USING ERRCODE='22023'; END IF;
   FOR actor IN SELECT value FROM jsonb_array_elements(enc->'actors') LOOP
    IF (NOT named_ai AND actor->>'mechanical_binding_id' IS DISTINCT FROM '66a6628d-d465-4103-b74b-2184f4b07d04')
     OR (named_ai AND actor->>'mechanical_binding_id' NOT IN ('31da0000-0000-4000-8000-000000000301','31da0000-0000-4000-8000-000000000302'))
    THEN RAISE EXCEPTION 'H3_STAFF_SOURCE_APPROVED_PROFILE_REQUIRED' USING ERRCODE='42501'; END IF;
   END LOOP;
  END LOOP;
 END LOOP;
 IF enc_count<>1 THEN RAISE EXCEPTION 'H3_STAFF_SOURCE_ONE_ENCOUNTER' USING ERRCODE='22023'; END IF;
 validation:=mission_creation_owner.map_binding_guard_mission_publish_v1(p_document,mission_creation_owner.validate_document(p_document));
 mid:=public.missione_crea(m->>'title',m->>'grado',m->>'briefing',nullif(m->>'village',''),m->>'tag_trama',(m->>'team_min')::integer,(m->>'team_max')::integer,validation->>'gathering_name',expected_xp,0);
 -- La stessa transazione non espone mai la fonte aperta alla bacheca o alle iscrizioni.
 UPDATE public.missions SET status='annullata' WHERE id=mid AND status='aperta';
 IF NOT FOUND THEN RAISE EXCEPTION 'H3_STAFF_SOURCE_RESERVATION_FAILED'; END IF;
 result:=mission_creation_owner.save_complete(mid,p_request,mission_internal.fingerprint(mission_generic_owner.mission_editor_snapshot(mid)),0,p_document);
 IF result->>'schema_version' IS DISTINCT FROM 'mission-creation-result/1'
 OR result->>'mission_id' IS DISTINCT FROM mid::text OR result->>'state' IS DISTINCT FROM 'configured'
 OR NOT EXISTS(SELECT 1 FROM public.missions WHERE id=mid AND status='annullata' AND xp_reward=expected_xp AND ryo_reward=0
 AND team_min=(m->>'team_min')::integer AND team_max=(m->>'team_max')::integer)
 THEN RAISE EXCEPTION 'H3_STAFF_SOURCE_POSTCONDITION'; END IF;
 INSERT INTO mission_creation_owner.h3_staff_source_requests(request_key,actor_user,document_sha256,mission_id,result)
 VALUES(p_request,auth.uid(),doc_sha,mid,result);
 RETURN result;
END $function$;

COMMIT;
