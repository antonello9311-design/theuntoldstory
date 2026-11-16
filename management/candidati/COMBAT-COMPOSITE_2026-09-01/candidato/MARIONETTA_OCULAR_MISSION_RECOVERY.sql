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
 IF f IS NULL OR md5(pg_get_functiondef(f)) NOT IN ('0a55e640f29e34221aa5cf26d64a5c84','ecf5d7d74d746f437ca8bfe12cc25a56','42defbaa8b19fa9c6ceabdeeaa109b4b','cfb21e1d97c34d6193a79e1c2c84410a')
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

DO $start_baseline$
DECLARE fingerprint text:=md5(pg_get_functiondef('public.mission_generic_staff_test_start_v1(uuid,uuid,uuid[],uuid)'::regprocedure));
BEGIN
 IF fingerprint IS NULL OR fingerprint NOT IN ('e4e35c865abe20aa2556767a77c27d6c','235c0d81fc464a020ee36b6a1dd881d8') THEN
   RAISE EXCEPTION 'FILI_STAFF_START_RESTORE_DRIFT' USING ERRCODE='40001';
 END IF;
END;
$start_baseline$;

CREATE OR REPLACE FUNCTION public.mission_generic_staff_test_start_v1(p_source_mission uuid, p_location uuid, p_roster uuid[], p_request uuid)
 RETURNS jsonb
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO ''
AS $function$
declare src public.missions;sel jsonb;arena jsonb;doc jsonb;sealed jsonb;def jsonb;
 carrier uuid:=gen_random_uuid();aid uuid;fp text;r jsonb;old mission_generic_owner.simulation_sources;sha text;
begin
 perform mission_ai_board_owner.staff_only();
 -- C1266_AVAILABILITY_COORD: shared before mutation locks; xact lifetime.
 PERFORM pg_catalog.pg_advisory_xact_lock_shared(pg_catalog.hashtextextended('C1266:GENERIC-AI:AVAILABILITY',0));
 perform mission_ai_board_owner.lock_request(p_request);
 fp:=mission_internal.fingerprint(jsonb_build_object('source_mission',p_source_mission,'location',p_location,'roster',to_jsonb(p_roster)));
 IF EXISTS(SELECT 1 FROM mission_generic_owner.manual_staff_start_rejections_v1 denied WHERE denied.request_key=p_request) THEN RAISE EXCEPTION 'MANUAL_STAFF_START_REQUEST_REJECTED' USING ERRCODE='40001';END IF;
 select * into old from mission_generic_owner.simulation_sources where request_key=p_request;
 if found then
  if old.request_fingerprint<>fp then raise exception 'MGB_TEST_REQUEST_CONFLICT' using errcode='40001';end if;
  select s.result into strict r from mission_generic_owner.board_starts s join public.master_v2_sessions m on m.id=s.master_session_id
   where m.mission_id=old.carrier_mission_id;
  IF NOT EXISTS(SELECT 1 FROM mission_generic_owner.start_claims sc WHERE sc.request_key=p_request AND sc.actor_user_id=auth.uid()) THEN RAISE EXCEPTION 'MANUAL_STAFF_START_REPLAY_OWNER' USING ERRCODE='42501';END IF;
  return r||jsonb_build_object('source_mission_id',old.source_mission_id,'replay',true);
 end if;
 perform mission_generic_owner.location_runtime(p_location,true);
 select * into strict src from public.missions where id=p_source_mission for share;
 if exists(select 1 from mission_generic_owner.simulation_sources where carrier_mission_id=src.id)
 then raise exception 'MGB_TEST_SOURCE_MUST_BE_ORIGINAL' using errcode='22023';end if;
 -- Validate all principals before creating even the carrier/pinned copy.
 perform mission_generic_owner.staff_roster_assert(p_location,p_roster);
 sel:=mission_generic_owner.historical_plan(src.id);
 select definition into strict def from mission_generic_owner.definitions where id=(sel->>'definition_id')::uuid;
 arena:=mission_generic_owner.arena_source(src.id,p_location);
 insert into public.missions(id,title,village,grado,briefing,tag_trama,xp_reward,ryo_reward,team_min,team_max,location_hint,status,created_by)
 values(carrier,'Prova · '||src.title,src.village,src.grado,src.briefing,src.tag_trama,0,0,src.team_min,src.team_max,src.location_hint,'annullata',auth.uid());
 doc:=jsonb_build_object('schema_version','mission-generic-plan-document/1','base_plan_version_id',null,
  'initial_step_key',(select initial_step_key from public.mission_plan_versions where id=(sel->>'plan_version_id')::uuid),
  'steps',(select jsonb_agg(jsonb_build_object('step_key',step_key,'kind',kind,'public_objective',public_objective) order by ordinal)
   from public.mission_plan_steps where plan_version_id=(sel->>'plan_version_id')::uuid),
  'transitions',(select coalesce(jsonb_agg(jsonb_build_object('transition_key',transition_key,'from_step_key',from_step_key,'to_step_key',to_step_key,'event_kind',event_kind,'priority',priority) order by transition_key),'[]'::jsonb)
   from public.mission_plan_transitions where plan_version_id=(sel->>'plan_version_id')::uuid),
  'definition',def,'terminal_steps',sel#>'{settings,terminal_steps}');
 sha:=mission_internal.fingerprint(mission_generic_owner.mission_editor_snapshot(carrier));
 sealed:=public.mission_generic_plan_seal_v1(carrier,gen_random_uuid(),sha,doc);
 perform mission_creation_owner.copy_revision((sel->>'plan_version_id')::uuid,(sealed->>'plan_version_id')::uuid,carrier);
 perform public.mission_generic_plan_select_v1(carrier,(sealed->>'plan_version_id')::uuid,0,gen_random_uuid());
 insert into mission_generic_owner.simulation_sources(carrier_mission_id,source_mission_id,source_plan_version_id,source_sha256,request_key,request_fingerprint)
 values(carrier,src.id,(sel->>'plan_version_id')::uuid,mission_internal.fingerprint(sel),p_request,fp);

 if mission_academy_owner.is_academy(src.id) then
  insert into mission_academy_owner.policies
   (mission_id,policy_key,display_grade,village,min_rank,max_rank,xp_reward,ryo_reward,always_complete,context_only,rescue_before_ko,active)
  select carrier,policy_key||':staff:'||carrier::text,display_grade,village,min_rank,max_rank,xp_reward,ryo_reward,always_complete,context_only,rescue_before_ko,active
   from mission_academy_owner.policies where mission_id=src.id and active;
  if not found then raise exception 'ACADEMY_STAFF_SOURCE_POLICY_MISSING' using errcode='22023';end if;
  insert into mission_academy_owner.roster_actor_rules(mission_id,actor_key,min_roster,active)
   select carrier,actor_key,min_roster,active from mission_academy_owner.roster_actor_rules where mission_id=src.id;
  insert into mission_academy_owner.d100_challenges
   (mission_id,step_key,ordinal,challenge_key,threshold,support_threshold,success_fact,complication_fact,active)
   select carrier,step_key,ordinal,challenge_key,threshold,support_threshold,success_fact,complication_fact,active
   from mission_academy_owner.d100_challenges where mission_id=src.id;
 end if;
 if arena->>'template_key' is not null then perform public.universal_arena_configure_v1('mission',carrier,arena->>'template_key',(arena->>'template_version')::integer,arena->>'zone_key',0);end if;
 insert into mission_ai_board_owner.activations(mission_id,package_id,generic_plan_version_id,location_id,mission_seal_sha256,state)
 values(carrier,null,(sealed->>'plan_version_id')::uuid,p_location,sha,'enrollment_open') returning id into aid;
 r:=mission_generic_owner.prepare_start(aid,p_roster,p_request,fp,true);
 -- Event42: only this newly accepted AI Staff start creates a server root. No replay/backfill.
 DECLARE cfg jsonb;sid uuid;ek uuid;ev bigint:=1;domain text:='start';source_id uuid:=p_request;
 source_sha text;rootrow mission_generic_owner.event_outbox_v1;request_id bigint;affected integer;
 BEGIN
 SELECT rr.canonical_preimage::jsonb#>'{config,c1266_server_events}' INTO cfg
 FROM mission_factory_owner.editor_release_readiness rr WHERE rr.singleton AND rr.state='enabled' AND rr.scope='staff';
 IF cfg->>'schema_version'='c1266-server-events/1' AND cfg->'enabled'='true'::jsonb THEN
 sid:=(r->>'master_session_id')::uuid;
 IF p_location IS DISTINCT FROM '0b85f354-9cdb-47e1-baf9-3d266bb7e06b'::uuid
 OR sid IS NULL OR auth.uid() IS NULL OR NOT EXISTS(SELECT 1 FROM mission_generic_owner.start_claims sc
 JOIN mission_generic_owner.board_starts bs ON bs.request_key=sc.request_key
 WHERE sc.request_key=p_request AND sc.actor_user_id=auth.uid() AND sc.session_id=sid AND bs.master_session_id=sid
 AND bs.result=r) THEN RAISE EXCEPTION 'EVENT42_START_PROOF' USING ERRCODE='42501';END IF;
 ek:=mission_ai_service_owner.uuid5(sid,'server-event:start:'||p_request::text);source_sha:=public.combat_v2_sha256(r);
 rootrow.root_event_key:=ek;rootrow.root_request_key:=p_request;rootrow.root_principal:=auth.uid();rootrow.root_receipt_sha256:=source_sha;
 IF cfg->>'endpoint' IS DISTINCT FROM 'https://tyhyxkslteigibktluml.supabase.co/functions/v1/mission_generic_ai'
 THEN RAISE EXCEPTION 'EVENT42_ENDPOINT_REJECTED' USING ERRCODE='42501'; END IF;
 INSERT INTO mission_generic_owner.event_outbox_v1(event_key,event_version,master_session_id,event_domain,
 source_id,source_sha256,root_event_key,root_request_key,root_principal,root_receipt_sha256)
 VALUES(ek,ev,sid,domain,source_id,source_sha,rootrow.root_event_key,rootrow.root_request_key,
 rootrow.root_principal,rootrow.root_receipt_sha256)
 ON CONFLICT(event_key,event_version) DO NOTHING;
 GET DIAGNOSTICS affected=ROW_COUNT;
 IF affected=1 THEN
 IF cfg->'enabled'='true'::jsonb THEN
 request_id:=net.http_post(cfg->>'endpoint',jsonb_build_object('schema_version','mission-event-wake/2',
 'event_key',ek,'event_version',ev),'{}'::jsonb,
 jsonb_build_object('Content-Type','application/json','x-tus-server-event','event42'),5000);
 UPDATE mission_generic_owner.event_outbox_v1 SET wake_request_id=request_id
 WHERE event_key=ek AND event_version=ev;
 END IF;
 END IF;
 -- Public display hint is emitted only by deferred source/outbox hook.
 END IF;
 END;

 return r||jsonb_build_object('source_mission_id',src.id,'replay',false);
end;
$function$;

COMMIT;
