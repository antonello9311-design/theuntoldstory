-- Recupero della stessa prova Staff. Nessuna chiamata provider e nessuna apertura Land.
BEGIN;
SET LOCAL lock_timeout='3s';
SET LOCAL statement_timeout='65s';

DO $exact_readback$
BEGIN
  IF md5(pg_get_functiondef('public.mission_generic_room_state_v1(uuid)'::regprocedure))
      IS DISTINCT FROM 'f7bec2a8ab500459ac216b851d134fc4'
  THEN RAISE EXCEPTION 'FILI_STAFF_SCENE_ROOM_DRIFT' USING ERRCODE='40001'; END IF;
  IF md5(pg_get_functiondef('public.mission_generic_event_next_v1(uuid,bigint,uuid)'::regprocedure))
      IS DISTINCT FROM '234d8822c54ee363f7d3d0110b77850f'
  THEN RAISE EXCEPTION 'FILI_STAFF_EVENT_NEXT_DRIFT' USING ERRCODE='40001'; END IF;
  IF EXISTS (
    SELECT 1 FROM clan_marionettisti_private.mission_companion_release_v1
    WHERE singleton AND land_enabled
  ) OR NOT EXISTS (
    SELECT 1 FROM mission_generic_owner.work_items work
    JOIN public.master_v2_sessions master ON master.id=work.master_session_id
    WHERE work.id='2df46bec-3ab1-91dd-7ce5-05a33e68ef2a'::uuid
      AND master.id='57a79d9b-6b70-4e4a-95dc-e1e14ec63aa2'::uuid
      AND master.location_id='0b85f354-9cdb-47e1-baf9-3d266bb7e06b'::uuid
      AND master.closed_at IS NULL AND master.owner_kind='ai_service'
      AND work.state='failed' AND work.message_id IS NULL
      AND work.result_sha256='ff39c75d1789a44a22b1cc523a890a8015bf53716f64afebf5caf7a828d79b30'
      AND public.combat_v2_sha256(work.result)='4b03021377311b4e798297f61c26aa836cedc66617055367486ccbb725a085f8'
  ) THEN RAISE EXCEPTION 'FILI_STAFF_SAVED_RESULT_DRIFT' USING ERRCODE='40001'; END IF;
END;
$exact_readback$;


DO $staff_npc_pin_preflight$
BEGIN
  IF md5(pg_get_functiondef('mission_generic_owner.binding_is_pinned(uuid,uuid)'::regprocedure)) IS DISTINCT FROM '5cb5da0215215ca28f29a492db270e74' THEN
    RAISE EXCEPTION 'Baseline non corrispondente per mission_generic_owner.binding_is_pinned(uuid,uuid)' USING ERRCODE='40001';
  END IF;
  IF md5(pg_get_functiondef('mission_factory_owner.npc_custom_combat_runtime_assert_v1(uuid,uuid,uuid,uuid)'::regprocedure)) IS DISTINCT FROM 'ba6acb0a77c0c76317df49291f6871eb' THEN
    RAISE EXCEPTION 'Baseline non corrispondente per mission_factory_owner.npc_custom_combat_runtime_assert_v1(uuid,uuid,uuid,uuid)' USING ERRCODE='40001';
  END IF;
  IF md5(pg_get_functiondef('png_builder_internal.npc_custom_combat_attest_assert_v1(uuid,uuid,uuid)'::regprocedure)) IS DISTINCT FROM '9682652b8b60dba7e161c6a592017791' THEN
    RAISE EXCEPTION 'Baseline non corrispondente per png_builder_internal.npc_custom_combat_attest_assert_v1(uuid,uuid,uuid)' USING ERRCODE='40001';
  END IF;
END;
$staff_npc_pin_preflight$;
CREATE FUNCTION clan_marionettisti_private.staff_companion_npc_bundle_valid_v1(
  p_master uuid,p_binding uuid,p_bundle uuid
)
RETURNS boolean
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path=''
AS $function$
DECLARE certified png_builder_internal.bundles%ROWTYPE;
BEGIN
  -- Questo è il riferimento al certificato esistente del solo run Staff sigillato.
  IF p_master IS DISTINCT FROM '57a79d9b-6b70-4e4a-95dc-e1e14ec63aa2'::uuid
    OR p_binding IS DISTINCT FROM 'dec31d7d-5314-4f41-b68b-8f7b1f8fb002'::uuid
    OR p_bundle IS DISTINCT FROM '26164714-6aa3-4d7c-8833-0d1cc9d8b860'::uuid
  THEN RETURN false; END IF;

  SELECT bundle.* INTO certified
  FROM public.master_v2_sessions master
  JOIN public.locations room ON room.id=master.location_id AND room.is_active AND room.is_test
  JOIN mission_generic_owner.simulation_sources lineage ON lineage.carrier_mission_id=master.mission_id
  JOIN mission_creation_owner.h3_staff_source_requests author ON author.mission_id=lineage.source_mission_id
    AND author.request_key='14136a56-0f58-41b2-ae24-8f7f3acbb4b2'::uuid
    AND author.document_sha256='6a1c785a06464fcc3310727bc700f767c77fbf411982ba87090e009ec470210f'
    AND author.result->>'mission_id'=lineage.source_mission_id::text
    AND author.result->>'plan_version_id'=lineage.source_plan_version_id::text
  JOIN mission_generic_owner.plan_revisions source_revision ON source_revision.plan_version_id=lineage.source_plan_version_id
    AND source_revision.mission_id=lineage.source_mission_id
  JOIN mission_creation_owner.revisions source_document ON source_document.plan_version_id=source_revision.plan_version_id
    AND source_document.mission_id=source_revision.mission_id AND source_document.direction_mode='ai'
    AND source_document.document_sha256=author.document_sha256
    AND source_document.document_sha256=mission_internal.fingerprint(source_document.document)
  JOIN mission_generic_owner.definitions source_definition ON source_definition.id=source_revision.definition_id
    AND source_definition.plan_version_id=source_revision.plan_version_id
    AND source_definition.definition=source_document.document#>'{plan,definition}'
    AND source_definition.definition_sha256=mission_internal.fingerprint(source_definition.definition)
  JOIN mission_generic_owner.run_bindings frozen ON frozen.master_session_id=master.id
    AND frozen.snapshot_sha256=mission_internal.fingerprint(frozen.snapshot)
    AND frozen.snapshot->'definition'=source_definition.definition
    AND frozen.snapshot->>'definition_sha256'=source_definition.definition_sha256
  JOIN mission_generic_owner.definitions carrier_definition ON carrier_definition.id=frozen.definition_id
    AND carrier_definition.definition=source_definition.definition
    AND carrier_definition.definition_sha256=source_definition.definition_sha256
  JOIN public.mission_run_state run ON run.master_session_id=master.id
    AND run.mission_id=master.mission_id AND run.source_kind='mission'
    AND run.run_phase='in_corso' AND run.current_step_key='inizio'
    AND run.plan_version_id=carrier_definition.plan_version_id
    AND run.plan_version_id::text=frozen.snapshot->>'plan_version_id'
    AND run.plan_sha256=carrier_definition.plan_sha256
    AND run.plan_sha256=frozen.snapshot->>'plan_sha256'
  JOIN mission_generic_owner.board_starts start_receipt ON start_receipt.master_session_id=master.id
    AND start_receipt.request_key=lineage.request_key AND start_receipt.simulation AND start_receipt.state='published'
  JOIN mission_ai_service_owner.capabilities capability ON capability.id=start_receipt.capability_id
    AND capability.master_session_id=master.id AND capability.state='active'
  JOIN clan_marionettisti_private.mission_companion_entitlements_v1 entitlement
    ON entitlement.definition_id=source_definition.id AND entitlement.step_key=run.current_step_key
    AND entitlement.encounter_key='enc_inizio' AND entitlement.actor_key='png_1'
    AND entitlement.mechanical_binding_id=p_binding AND entitlement.staff_enabled AND NOT entitlement.land_enabled
  JOIN png_builder_internal.bundles bundle ON bundle.id=p_bundle AND bundle.mechanical_binding_id=p_binding
    AND bundle.bundle_sha256='c0257dd5219d23dde880e9f8cc9e867988a21a1008aa59ca6f0b63e7844210e6'
    AND bundle.status='certified' AND bundle.ownership_mode='adopted'
    AND bundle.bundle_kind='combat' AND bundle.disabled_at IS NULL
  WHERE master.id=p_master AND master.mission_id='b57f79f8-32d4-498d-b398-ffdbb682f32a'::uuid
    AND master.location_id='0b85f354-9cdb-47e1-baf9-3d266bb7e06b'::uuid
    AND master.owner_kind='ai_service' AND master.master_user IS NULL
    AND master.closed_at IS NULL AND master.suspended_at IS NULL
    AND frozen.snapshot_sha256='8c9192be2f3e562965b2ff73a0ce4cdcbf70972d9ef2a1a865fe9f447b784854'
    AND NOT (frozen.snapshot ? 'npc_bundle_pins')
    AND NOT EXISTS (SELECT 1 FROM mission_factory_owner.quest_run_sources quest WHERE quest.session_id=master.id)
    AND EXISTS (
      SELECT 1 FROM jsonb_array_elements(source_definition.definition->'scenes') AS phase(value)
      CROSS JOIN LATERAL jsonb_array_elements(phase.value->'encounters') AS encounter(value)
      CROSS JOIN LATERAL jsonb_array_elements(encounter.value->'actors') AS actor(value)
      WHERE phase.value->>'step_key'=entitlement.step_key
        AND encounter.value->>'encounter_key'=entitlement.encounter_key
        AND actor.value->>'actor_key'=entitlement.actor_key
        AND actor.value->>'mechanical_binding_id'=p_binding::text
        AND actor.value->>'narrative_template_id'=bundle.template_id::text
        AND actor.value->>'narrative_version_id'=bundle.narrative_version_id::text
    )
  FOR SHARE OF bundle,entitlement;

  IF NOT FOUND THEN RETURN false; END IF;
  RETURN png_builder_internal.npc_custom_combat_attest_assert_v1(
    certified.template_id,certified.narrative_version_id,certified.id
  )->>'bundle_sha256' IS NOT DISTINCT FROM certified.bundle_sha256;
END;
$function$;
REVOKE ALL ON FUNCTION clan_marionettisti_private.staff_companion_npc_bundle_valid_v1(uuid,uuid,uuid)
  FROM PUBLIC,anon,authenticated,service_role;
CREATE OR REPLACE FUNCTION mission_generic_owner.binding_is_pinned(p_master uuid, p_binding uuid)
 RETURNS boolean
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO ''
AS $function$
declare q mission_factory_owner.quest_run_sources%rowtype;
  r public.mission_run_state%rowtype;
  v_run_binding mission_generic_owner.run_bindings%rowtype;
  sc jsonb; pinned boolean;
begin
 if exists(select 1 from mission_factory_owner.quest_run_sources where session_id=p_master) then
   perform mission_factory_owner.quest_run_source_assert_v1(p_master);
   select * into strict q from mission_factory_owner.quest_run_sources where session_id=p_master for share;
   select * into strict r from public.mission_run_state where master_session_id=p_master for share;
   if q.state<>'started' or r.source_kind<>'quest' or r.quest_episode_id is distinct from q.episode_id
      or r.run_phase<>'in_corso' then return false; end if;
   sc:=mission_factory_owner.quest_scene_v1(p_master,r.current_step_key);
   return exists(select 1 from jsonb_array_elements(sc->'encounters') en,
     lateral jsonb_array_elements(en.value->'actors') a
     where a.value->>'combat'='true'
       and a.value->>'mechanical_binding_id'=p_binding::text
       and (case when exists(select 1 from png_builder_internal.bundles z
             join public.nb_mechanical_versions x on x.id=z.mechanical_version_id
             where z.id=(a.value->>'npc_version_id')::uuid and x.profile_kind='npc_custom')
           then exists(select 1 from png_builder_internal.bundles z
             where z.id=(a.value->>'npc_version_id')::uuid
               and z.template_id=(a.value->>'npc_id')::uuid
               and z.mechanical_binding_id=p_binding
               and png_builder_internal.npc_custom_combat_attest_assert_v1(
                 z.template_id,z.narrative_version_id,z.id)->>'bundle_sha256'
                   =a.value->>'npc_bundle_sha256')
           else mission_factory_owner.npc_reference(
             (a.value->>'npc_id')::uuid,(a.value->>'npc_version_id')::uuid,true)
               ->>'bundle_sha256'=a.value->>'npc_bundle_sha256' end)
       and exists(select 1 from public.nb_mechanical_bindings b
         join public.nb_template_versions nv on nv.id=b.narrative_version_id
         join public.nb_mechanical_versions mv on mv.id=b.mechanical_version_id
         where b.id=p_binding and b.active and b.lifecycle_state='approved'
           and b.narrative_template_id=(a.value->>'narrative_template_id')::uuid
           and b.narrative_version_id=(a.value->>'narrative_version_id')::uuid
           and b.control_version=(a.value->>'binding_control_version')::bigint
           and nv.content_sha256=a.value->>'narrative_content_sha256'
           and mv.content_sha256=a.value->>'mechanical_content_sha256'));
 end if;
 select exists(select 1 from mission_generic_owner.run_bindings rb,
 lateral jsonb_array_elements(rb.snapshot->'binding_pins') p
 join public.nb_mechanical_bindings b on b.id=(p->>'mechanical_binding_id')::uuid
 join public.nb_templates nt on nt.id=b.narrative_template_id
 join public.nb_template_versions nv on nv.id=b.narrative_version_id
 join public.nb_mechanical_templates mt on mt.id=b.mechanical_template_id
 join public.nb_mechanical_versions mv on mv.id=b.mechanical_version_id
 where rb.master_session_id=p_master and b.id=p_binding and b.control_version=(p->>'control_version')::bigint
 and nt.id=(p->>'narrative_template_id')::uuid and nv.id=(p->>'narrative_version_id')::uuid
 and mt.id=(p->>'mechanical_template_id')::uuid and mv.id=(p->>'mechanical_version_id')::uuid
 and ((nt.control_version=(p->>'narrative_template_control_version')::bigint
   and nv.control_version=(p->>'narrative_version_control_version')::bigint)
  OR (b.active AND b.lifecycle_state='approved' AND nt.lifecycle_state='approved'
   AND nt.control_version>=(p->>'narrative_template_control_version')::bigint
   AND rb.snapshot_sha256=mission_internal.fingerprint(rb.snapshot)
   AND rb.snapshot->>'definition_sha256'=mission_internal.fingerprint(rb.snapshot->'definition')
   AND nv.content_sha256=ninja_book_internal.json_hash(jsonb_build_object(
    'schema_version',nv.schema_version,'skeleton',nv.skeleton,'knowledge_boundary',nv.knowledge_boundary,
    'fallback_profile',nv.fallback_profile,'mechanical_template_id',nv.mechanical_template_id))
   AND EXISTS(SELECT 1 FROM public.master_v2_sessions frozen_master
    JOIN public.mission_run_state frozen_run ON frozen_run.master_session_id=frozen_master.id
    JOIN public.combat_v2_sessions frozen_encounter ON frozen_encounter.master_session_id=frozen_master.id
    JOIN public.combat_v2_provider_instances_v1 frozen_instance ON frozen_instance.session_id=frozen_encounter.id
    JOIN public.combat_v2_actors frozen_actor ON frozen_actor.session_id=frozen_encounter.id
     AND frozen_actor.provider_instance_v1_id=frozen_instance.id AND frozen_actor.actor_kind='png'
    WHERE frozen_master.id=p_master AND frozen_run.run_phase='in_corso'
     AND frozen_run.plan_version_id::text=rb.snapshot->>'plan_version_id'
     AND frozen_run.plan_sha256=rb.snapshot->>'plan_sha256'
     AND frozen_encounter.closed_at IS NULL
     AND frozen_instance.narrative_template_ref=nt.id AND frozen_instance.narrative_version_ref=nv.id
     AND frozen_instance.mechanical_template_ref=mt.id AND frozen_instance.mechanical_version_ref=mv.id
     AND frozen_instance.snapshot_sha256=ninja_book_internal.json_hash(frozen_instance.snapshot)
     AND nv.approved_at IS NOT NULL AND nv.approved_at<=frozen_master.created_at
     AND ((nv.review_state='approved' AND nv.control_version=(p->>'narrative_version_control_version')::bigint)
      OR (nv.review_state='inactive' AND nv.control_version>(p->>'narrative_version_control_version')::bigint
       AND EXISTS(SELECT 1 FROM public.nb_template_versions successor
        WHERE successor.template_id=nv.template_id AND successor.supersedes_version_id=nv.id
         AND successor.approved_at>nv.approved_at AND successor.review_state IN('approved','inactive')))))))
 and mt.control_version=(p->>'mechanical_template_control_version')::bigint
 and mv.control_version=(p->>'mechanical_version_control_version')::bigint
 and nv.content_sha256=p->>'narrative_content_sha256' and mv.content_sha256=p->>'mechanical_content_sha256') into pinned;
 if not pinned then return false; end if;
 if not exists(select 1 from public.nb_mechanical_bindings x
   join public.nb_mechanical_versions v on v.id=x.mechanical_version_id
   where x.id=p_binding and v.profile_kind='npc_custom') then return true; end if;
 select * into r from public.mission_run_state where master_session_id=p_master for share;
 select * into v_run_binding from mission_generic_owner.run_bindings where master_session_id=p_master for share;
 if r.master_session_id is null or v_run_binding.master_session_id is null
    or r.source_kind<>'mission' or r.run_phase<>'in_corso'
    or r.current_step_key is null
    or v_run_binding.snapshot_sha256 is distinct from mission_internal.fingerprint(v_run_binding.snapshot)
    or v_run_binding.snapshot->>'plan_version_id' is distinct from r.plan_version_id::text
 then return false; end if;
 return exists(select 1 from jsonb_array_elements(coalesce(v_run_binding.snapshot->'npc_bundle_pins','[]'::jsonb)) pin
   join png_builder_internal.bundles z on z.id=(pin.value->>'npc_version_id')::uuid
   where pin.value->>'mechanical_binding_id'=p_binding::text
     and pin.value->>'plan_version_id'=r.plan_version_id::text
     and pin.value->'phase_keys' ? r.current_step_key
     and pin.value->>'npc_id'=z.template_id::text
     and pin.value->>'bundle_sha256'=z.bundle_sha256
     and z.mechanical_binding_id=p_binding
     and z.bundle_kind='combat' and z.status='certified'
     and z.ownership_mode='adopted' and z.disabled_at is null
     and png_builder_internal.npc_custom_combat_attest_assert_v1(
       z.template_id,z.narrative_version_id,z.id)->>'bundle_sha256'=pin.value->>'bundle_sha256')
   or clan_marionettisti_private.staff_companion_npc_bundle_valid_v1(
     p_master,p_binding,'26164714-6aa3-4d7c-8833-0d1cc9d8b860'::uuid
   );
end $function$;

CREATE OR REPLACE FUNCTION mission_factory_owner.npc_custom_combat_runtime_assert_v1(p_master_session uuid, p_capability uuid, p_offer_ref uuid, p_bundle_version uuid)
 RETURNS void
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO ''
AS $function$
declare m public.master_v2_sessions%rowtype;
  o public.master_v2_nb_actor_offers_v1%rowtype;
  bn png_builder_internal.bundles%rowtype; mv public.nb_mechanical_versions%rowtype;
  q mission_factory_owner.quest_run_sources%rowtype;
  r public.mission_run_state%rowtype;
  rb mission_generic_owner.run_bindings%rowtype;
  scene jsonb; att jsonb; k text; n bigint;
begin

  -- New capability: normal Human Native Staff only. Existing AI branch below is byte-exact.
  IF p_capability IS NULL AND EXISTS(SELECT 1 FROM mission_factory_owner.quest_run_sources oc WHERE oc.session_id=p_master_session AND oc.availability_scope='public') THEN
   DECLARE v_human_actor uuid:=auth.uid();v_human_allowed_auth_ids uuid[];
   BEGIN
    IF v_human_actor IS NULL OR auth.role() IS DISTINCT FROM 'authenticated'
    OR public.is_staff() IS DISTINCT FROM true OR public.master_v2_is_master(v_human_actor) IS DISTINCT FROM true
    OR p_master_session IS NULL OR p_offer_ref IS NULL OR p_bundle_version IS NULL
    THEN RAISE EXCEPTION 'HUMAN_CUSTOM_STAFF_AUTH_REQUIRED' USING ERRCODE='42501';END IF;
    SELECT * INTO STRICT m FROM public.master_v2_sessions WHERE id=p_master_session FOR SHARE;
    SELECT * INTO STRICT q FROM mission_factory_owner.quest_run_sources WHERE session_id=p_master_session FOR SHARE;
    SELECT * INTO STRICT r FROM public.mission_run_state WHERE master_session_id=p_master_session FOR SHARE;
    IF m.owner_kind IS DISTINCT FROM 'human' OR m.master_user IS DISTINCT FROM v_human_actor OR m.tipo IS DISTINCT FROM 'quest' OR m.mission_id IS NOT NULL OR m.closed_at IS NOT NULL OR m.suspended_at IS NOT NULL OR m.stato NOT IN('preparazione','in_corso')
    OR q.state IS DISTINCT FROM 'started' OR q.availability_scope IS DISTINCT FROM 'public' OR q.execution_context NOT IN('staff_simulation','public_real') OR q.location_id IS DISTINCT FROM m.location_id
    OR r.source_kind IS DISTINCT FROM 'quest' OR r.quest_episode_id IS DISTINCT FROM q.episode_id OR r.run_phase IS DISTINCT FROM 'in_corso' OR r.current_step_key IS NULL
    OR mission_factory_owner.human_ordinary_source_v1(p_master_session,true) IS NULL
    OR NOT EXISTS(SELECT 1 FROM mission_creation_owner.human_open_admissions admission WHERE admission.master_session_id=p_master_session AND admission.transaction_id=txid_current() AND admission.backend_pid=pg_backend_pid() AND admission.actor_user=v_human_actor)
    THEN RAISE EXCEPTION 'HUMAN_CUSTOM_ORDINARY_SCOPE_REQUIRED' USING ERRCODE='42501';END IF;
    PERFORM mission_factory_owner.human_custom_source_assert_v1((SELECT ca.draft_id FROM mission_factory_owner.quest_arcs ca WHERE ca.id=q.arc_id),true);
    PERFORM mission_factory_owner.c407_active_v1(p_master_session,'admission');
    PERFORM mission_factory_owner.quest_run_source_assert_v1(p_master_session);
    SELECT * INTO STRICT o FROM public.master_v2_nb_actor_offers_v1 WHERE offer_ref=p_offer_ref FOR SHARE;
    SELECT * INTO STRICT bn FROM png_builder_internal.bundles WHERE id=p_bundle_version FOR SHARE;
    IF bn.bundle_kind IS DISTINCT FROM 'combat' OR bn.status IS DISTINCT FROM 'certified' OR bn.ownership_mode IS DISTINCT FROM 'adopted' OR bn.disabled_at IS NOT NULL
    OR o.master_session_id IS DISTINCT FROM p_master_session OR o.mission_id IS NOT NULL OR o.source_kind IS DISTINCT FROM 'quest'
    OR o.quest_episode_id IS DISTINCT FROM q.episode_id OR o.quest_source_sha256 IS DISTINCT FROM q.source_sha256
    OR o.recipient_kind IS DISTINCT FROM 'human' OR o.recipient_user IS DISTINCT FROM v_human_actor
    OR o.recipient_service_capability IS NOT NULL OR o.created_by_service_capability IS NOT NULL OR o.created_by IS DISTINCT FROM v_human_actor
    OR o.lifecycle_state IS DISTINCT FROM 'offerta' OR o.expires_at IS NULL OR o.expires_at<=clock_timestamp()
    OR o.expected_master_control_version IS DISTINCT FROM m.control_version
    OR o.narrative_template_id IS DISTINCT FROM bn.template_id OR o.narrative_version_id IS DISTINCT FROM bn.narrative_version_id
    OR o.mechanical_template_id IS DISTINCT FROM bn.mechanical_template_id OR o.mechanical_version_id IS DISTINCT FROM bn.mechanical_version_id
    THEN RAISE EXCEPTION 'HUMAN_CUSTOM_OFFER_BUNDLE_STALE' USING ERRCODE='55000';END IF;
    att:=png_builder_internal.npc_custom_combat_attest_assert_v1(bn.template_id,bn.narrative_version_id,bn.id);
    IF att->>'bundle_sha256' IS DISTINCT FROM bn.bundle_sha256 THEN RAISE EXCEPTION 'HUMAN_CUSTOM_ATTEST_STALE' USING ERRCODE='55000';END IF;
    SELECT * INTO STRICT mv FROM public.nb_mechanical_versions WHERE id=bn.mechanical_version_id AND template_id=bn.mechanical_template_id FOR SHARE;
    IF mv.profile_kind IS DISTINCT FROM 'npc_custom' OR mv.review_state IS DISTINCT FROM 'approved' OR mv.content_sha256 IS DISTINCT FROM o.expected_mechanical_sha256
    OR mv.vita_max IS NULL OR mv.vita_max<=0 OR mv.chakra_max IS NULL OR mv.chakra_max<0 OR mv.abilities IS DISTINCT FROM '[]'::jsonb
    OR png_builder_internal.npc_combat_stats_safe(mv.stats) IS DISTINCT FROM true
    THEN RAISE EXCEPTION 'HUMAN_CUSTOM_MECHANICS_STALE' USING ERRCODE='55000';END IF;
    scene:=mission_factory_owner.quest_scene_v1(p_master_session,r.current_step_key);
    IF NOT EXISTS(SELECT 1 FROM jsonb_array_elements(coalesce(scene->'encounters','[]'::jsonb)) encounter_row,
       LATERAL jsonb_array_elements(coalesce(encounter_row.value->'actors','[]'::jsonb)) actor_row
       WHERE actor_row.value->>'combat'='true' AND actor_row.value->>'npc_id'=bn.template_id::text
       AND actor_row.value->>'npc_version_id'=bn.id::text AND actor_row.value->>'npc_bundle_sha256'=bn.bundle_sha256
       AND actor_row.value->>'mechanical_binding_id'=bn.mechanical_binding_id::text)
    THEN RAISE EXCEPTION 'HUMAN_CUSTOM_SOURCE_ACTOR_STALE' USING ERRCODE='55000';END IF;
    RETURN;
   END;
  END IF;
  IF p_capability IS NULL THEN
   DECLARE v_human_actor uuid:=auth.uid();v_human_allowed_auth_ids uuid[];
   BEGIN
    IF v_human_actor IS NULL OR auth.role() IS DISTINCT FROM 'authenticated'
    OR public.is_staff() IS DISTINCT FROM true OR public.master_v2_is_master(v_human_actor) IS DISTINCT FROM true
    OR p_master_session IS NULL OR p_offer_ref IS NULL OR p_bundle_version IS NULL
    THEN RAISE EXCEPTION 'HUMAN_CUSTOM_STAFF_AUTH_REQUIRED' USING ERRCODE='42501';END IF;
    SELECT * INTO STRICT m FROM public.master_v2_sessions WHERE id=p_master_session FOR SHARE;
    SELECT * INTO STRICT q FROM mission_factory_owner.quest_run_sources WHERE session_id=p_master_session FOR SHARE;
    SELECT * INTO STRICT r FROM public.mission_run_state WHERE master_session_id=p_master_session FOR SHARE;
    SELECT allowed_auth_ids INTO STRICT v_human_allowed_auth_ids FROM mission_factory_owner.c416_kind_admission WHERE singleton FOR SHARE;
    IF m.owner_kind IS DISTINCT FROM 'human' OR m.master_user IS DISTINCT FROM v_human_actor OR m.tipo IS DISTINCT FROM 'quest' OR m.mission_id IS NOT NULL
    OR m.stato IS NULL OR m.stato NOT IN('preparazione','in_corso') OR m.closed_at IS NOT NULL OR m.suspended_at IS NOT NULL
    OR m.location_id IS DISTINCT FROM '0b85f354-9cdb-47e1-baf9-3d266bb7e06b'::uuid
    OR NOT EXISTS(SELECT 1 FROM public.locations location WHERE location.id=m.location_id AND location.is_active AND location.is_test)
    OR q.state IS DISTINCT FROM 'started' OR q.availability_scope IS DISTINCT FROM 'staff' OR q.execution_context IS DISTINCT FROM 'staff_simulation'
    OR q.public_release_sha256 IS NOT NULL OR q.location_id IS DISTINCT FROM m.location_id
    OR (q.staff_release_sha256 IS DISTINCT FROM mission_factory_owner.staff_release_sha_v1()
        AND q.staff_release_sha256 IS DISTINCT FROM mission_factory_owner.quest_v8_human_publication_root_v1(q.episode_id))
    OR r.source_kind IS DISTINCT FROM 'quest' OR r.quest_episode_id IS DISTINCT FROM q.episode_id OR r.run_phase IS DISTINCT FROM 'in_corso' OR r.current_step_key IS NULL
    OR mission_factory_owner.c395_human_mode_v1(p_master_session) IS DISTINCT FROM true
    OR mission_factory_owner.c416_kind_live_v1() IS DISTINCT FROM true
    OR (CASE WHEN EXISTS (SELECT 1 FROM mission_factory_owner.quest_arcs v8_arc
      WHERE v8_arc.id=q.arc_id AND v8_arc.draft_version=1 AND (
      (v8_arc.draft_id='97bce5e4-26e5-53e9-95d8-a17fbd8a36eb'::uuid AND v8_arc.source_sha256='6c85976b2e817158a11290df5469a83bccc439d7adb9073c9cb6d7f622d83b89')
      OR (v8_arc.id='9fe3188f-faae-59c1-94e4-b1b71e1942d6'::uuid AND v8_arc.draft_id='d5721a7f-c232-5eee-bfc2-3b7fc2f1fde0'::uuid AND q.episode_id='c8248aa7-c8cf-53c0-bb3a-c116b8505386'::uuid))
        AND v8_arc.availability_scope='staff' AND v8_arc.execution_context='staff_simulation'
        AND v8_arc.public_release_sha256 IS NULL) THEN
      q.source_sha256 IS DISTINCT FROM '64ad58d8953cf2d5199a1150902c7ea59417232da5e6b387467877d1c470585b'
      OR q.episode_ordinal IS DISTINCT FROM 1 OR r.current_step_key IS DISTINCT FROM 'fase_2'
      OR p_bundle_version IS DISTINCT FROM '26164714-6aa3-4d7c-8833-0d1cc9d8b860'::uuid
      OR mission_factory_owner.quest_v8_human_runtime_scope_v1(q.episode_id,true,true) IS DISTINCT FROM true
     ELSE mission_factory_owner.c444_enabled_v1() IS DISTINCT FROM true END)
    OR cardinality(v_human_allowed_auth_ids) IS DISTINCT FROM 2 OR array_position(v_human_allowed_auth_ids,NULL) IS NOT NULL
    OR NOT(v_human_actor=ANY(v_human_allowed_auth_ids)) OR cardinality(q.roster_character_ids) IS DISTINCT FROM 2
    OR EXISTS(SELECT 1 FROM unnest(q.roster_character_ids) member(id) LEFT JOIN public.characters character_row ON character_row.id=member.id
       WHERE character_row.id IS NULL OR character_row.user_id IS NULL OR NOT(character_row.user_id=ANY(v_human_allowed_auth_ids)))
    OR NOT EXISTS(SELECT 1 FROM mission_creation_owner.human_open_admissions admission WHERE admission.master_session_id=p_master_session
       AND admission.transaction_id=txid_current() AND admission.backend_pid=pg_backend_pid() AND admission.actor_user=v_human_actor)
    THEN RAISE EXCEPTION 'HUMAN_CUSTOM_NATIVE_STAFF_SCOPE_REQUIRED' USING ERRCODE='42501';END IF;
    PERFORM mission_factory_owner.c407_active_v1(p_master_session,'admission');
    PERFORM mission_factory_owner.quest_run_source_assert_v1(p_master_session);
    SELECT * INTO STRICT o FROM public.master_v2_nb_actor_offers_v1 WHERE offer_ref=p_offer_ref FOR SHARE;
    SELECT * INTO STRICT bn FROM png_builder_internal.bundles WHERE id=p_bundle_version FOR SHARE;
    IF bn.bundle_kind IS DISTINCT FROM 'combat' OR bn.status IS DISTINCT FROM 'certified' OR bn.ownership_mode IS DISTINCT FROM 'adopted' OR bn.disabled_at IS NOT NULL
    OR o.master_session_id IS DISTINCT FROM p_master_session OR o.mission_id IS NOT NULL OR o.source_kind IS DISTINCT FROM 'quest'
    OR o.quest_episode_id IS DISTINCT FROM q.episode_id OR o.quest_source_sha256 IS DISTINCT FROM q.source_sha256
    OR o.recipient_kind IS DISTINCT FROM 'human' OR o.recipient_user IS DISTINCT FROM v_human_actor
    OR o.recipient_service_capability IS NOT NULL OR o.created_by_service_capability IS NOT NULL OR o.created_by IS DISTINCT FROM v_human_actor
    OR o.lifecycle_state IS DISTINCT FROM 'offerta' OR o.expires_at IS NULL OR o.expires_at<=clock_timestamp()
    OR o.expected_master_control_version IS DISTINCT FROM m.control_version
    OR o.narrative_template_id IS DISTINCT FROM bn.template_id OR o.narrative_version_id IS DISTINCT FROM bn.narrative_version_id
    OR o.mechanical_template_id IS DISTINCT FROM bn.mechanical_template_id OR o.mechanical_version_id IS DISTINCT FROM bn.mechanical_version_id
    THEN RAISE EXCEPTION 'HUMAN_CUSTOM_OFFER_BUNDLE_STALE' USING ERRCODE='55000';END IF;
    att:=png_builder_internal.npc_custom_combat_attest_assert_v1(bn.template_id,bn.narrative_version_id,bn.id);
    IF att->>'bundle_sha256' IS DISTINCT FROM bn.bundle_sha256 THEN RAISE EXCEPTION 'HUMAN_CUSTOM_ATTEST_STALE' USING ERRCODE='55000';END IF;
    SELECT * INTO STRICT mv FROM public.nb_mechanical_versions WHERE id=bn.mechanical_version_id AND template_id=bn.mechanical_template_id FOR SHARE;
    IF mv.profile_kind IS DISTINCT FROM 'npc_custom' OR mv.review_state IS DISTINCT FROM 'approved' OR mv.content_sha256 IS DISTINCT FROM o.expected_mechanical_sha256
    OR mv.vita_max IS NULL OR mv.vita_max<=0 OR mv.chakra_max IS NULL OR mv.chakra_max<0 OR mv.abilities IS DISTINCT FROM '[]'::jsonb
    OR png_builder_internal.npc_combat_stats_safe(mv.stats) IS DISTINCT FROM true
    THEN RAISE EXCEPTION 'HUMAN_CUSTOM_MECHANICS_STALE' USING ERRCODE='55000';END IF;
    scene:=mission_factory_owner.quest_scene_v1(p_master_session,r.current_step_key);
    IF NOT EXISTS(SELECT 1 FROM jsonb_array_elements(coalesce(scene->'encounters','[]'::jsonb)) encounter_row,
       LATERAL jsonb_array_elements(coalesce(encounter_row.value->'actors','[]'::jsonb)) actor_row
       WHERE actor_row.value->>'combat'='true' AND actor_row.value->>'npc_id'=bn.template_id::text
       AND actor_row.value->>'npc_version_id'=bn.id::text AND actor_row.value->>'npc_bundle_sha256'=bn.bundle_sha256
       AND actor_row.value->>'mechanical_binding_id'=bn.mechanical_binding_id::text)
    THEN RAISE EXCEPTION 'HUMAN_CUSTOM_SOURCE_ACTOR_STALE' USING ERRCODE='55000';END IF;
    RETURN;
   END;
  END IF;
  if p_master_session is null or p_capability is null
     or p_offer_ref is null or p_bundle_version is null then
    raise exception 'MF_NPC_CUSTOM_RUNTIME_INPUT' using errcode='22023'; end if;
  perform mission_generic_owner.assert_combat_scope(p_master_session,p_capability);
  select * into m from public.master_v2_sessions where id=p_master_session for share;
  if m.id is null or m.stato not in('preparazione','in_corso') or m.closed_at is not null
     or m.suspended_at is not null
     or not exists(select 1 from public.locations l where l.id=m.location_id
       and l.id='0b85f354-9cdb-47e1-baf9-3d266bb7e06b'::uuid
       and l.is_active and l.is_test) then
    raise exception 'MF_NPC_CUSTOM_RUNTIME_STAFF_ONLY' using errcode='42501'; end if;
  select * into o from public.master_v2_nb_actor_offers_v1
    where offer_ref=p_offer_ref for share;
  select * into bn from png_builder_internal.bundles where id=p_bundle_version for share;
  if o.offer_ref is null or bn.id is null or bn.bundle_kind<>'combat'
     or o.master_session_id is distinct from p_master_session
     or o.recipient_kind<>'ai_service' or o.recipient_service_capability is distinct from p_capability
     or o.lifecycle_state<>'offerta' or o.expires_at<=clock_timestamp()
     or o.narrative_template_id is distinct from bn.template_id
     or o.narrative_version_id is distinct from bn.narrative_version_id
     or o.mechanical_template_id is distinct from bn.mechanical_template_id
     or o.mechanical_version_id is distinct from bn.mechanical_version_id then
    raise exception 'MF_NPC_CUSTOM_RUNTIME_OFFER_STALE' using errcode='55000'; end if;
  att:=png_builder_internal.npc_custom_combat_attest_assert_v1(
    bn.template_id,bn.narrative_version_id,bn.id);
  if att->>'bundle_sha256' is distinct from bn.bundle_sha256 then
    raise exception 'MF_NPC_CUSTOM_RUNTIME_BUNDLE_STALE' using errcode='55000'; end if;
  select * into mv from public.nb_mechanical_versions
    where id=bn.mechanical_version_id and template_id=bn.mechanical_template_id for share;
  if mv.id is null or mv.profile_kind<>'npc_custom' or mv.review_state<>'approved'
     or mv.content_sha256 is distinct from o.expected_mechanical_sha256
     or mv.vita_max<=0 or mv.chakra_max<0 or mv.abilities is distinct from '[]'::jsonb
     or jsonb_typeof(mv.stats) is distinct from 'object' then
    raise exception 'MF_NPC_CUSTOM_RUNTIME_MECHANICS_STALE' using errcode='55000'; end if;
  foreach k in array array['taijutsu','ninjutsu','genjutsu','forza','velocita','mente','resistenza','fuuinjutsu'] loop
    if coalesce(mv.stats->>k,'') !~ '^[0-9]{1,10}$' then
      raise exception 'MF_NPC_CUSTOM_RUNTIME_STATS' using errcode='55000'; end if;
    n:=(mv.stats->>k)::bigint;
    if n>2147483647 then
      raise exception 'MF_NPC_CUSTOM_RUNTIME_STATS' using errcode='55000'; end if;
  end loop;
  select * into q from mission_factory_owner.quest_run_sources
    where session_id=p_master_session for share;
  if q.session_id is not null then
    select * into r from public.mission_run_state
      where master_session_id=p_master_session for share;
    if q.state<>'started' or r.source_kind<>'quest'
       or r.quest_episode_id is distinct from q.episode_id
       or r.run_phase<>'in_corso' or r.current_step_key is null
       or o.source_kind<>'quest' or o.quest_episode_id is distinct from q.episode_id
       or o.quest_source_sha256 is distinct from q.source_sha256 then
      raise exception 'MF_NPC_CUSTOM_RUNTIME_SOURCE_STALE' using errcode='55000'; end if;
    scene:=mission_factory_owner.quest_scene_v1(p_master_session,r.current_step_key);
    if not exists(select 1 from jsonb_array_elements(coalesce(scene->'encounters','[]'::jsonb)) en,
      lateral jsonb_array_elements(coalesce(en.value->'actors','[]'::jsonb)) a
      where a.value->>'combat'='true'
        and a.value->>'npc_id'=bn.template_id::text
        and a.value->>'npc_version_id'=bn.id::text
        and a.value->>'npc_bundle_sha256'=bn.bundle_sha256
        and a.value->>'mechanical_binding_id'=bn.mechanical_binding_id::text) then
      raise exception 'MF_NPC_CUSTOM_RUNTIME_SOURCE_STALE' using errcode='55000'; end if;
  else
    select * into rb from mission_generic_owner.run_bindings
      where master_session_id=p_master_session for share;
    select * into r from public.mission_run_state
      where master_session_id=p_master_session for share;
    if rb.master_session_id is null or r.master_session_id is null
       or r.source_kind<>'mission' or r.run_phase<>'in_corso'
       or r.current_step_key is null or o.source_kind<>'mission'
       or o.mission_id is distinct from m.mission_id
       or rb.snapshot_sha256 is distinct from mission_internal.fingerprint(rb.snapshot)
       or rb.snapshot->>'plan_version_id' is distinct from r.plan_version_id::text
       or not (exists(select 1 from jsonb_array_elements(
           coalesce(rb.snapshot->'npc_bundle_pins','[]'::jsonb)) p
           where p.value->>'npc_id'=bn.template_id::text
             and p.value->>'npc_version_id'=bn.id::text
             and p.value->>'plan_version_id'=r.plan_version_id::text
             and p.value->'phase_keys' ? r.current_step_key
             and p.value->>'bundle_sha256'=bn.bundle_sha256
             and p.value->>'mechanical_binding_id'=bn.mechanical_binding_id::text)
         or clan_marionettisti_private.staff_companion_npc_bundle_valid_v1(
           p_master_session,bn.mechanical_binding_id,p_bundle_version)) then
      -- Existing Mission run snapshots do not yet carry this new pin.
      raise exception 'MF_NPC_CUSTOM_RUNTIME_SOURCE_STALE' using errcode='55000'; end if;
  end if;
end $function$;

DO $preflight$
BEGIN
 IF (SELECT md5(prosrc) FROM pg_proc WHERE oid=to_regprocedure('mission_generic_owner.staff_fato_regen_scope(uuid,uuid)')) IS DISTINCT FROM '1605a364be47de9ae90f719e896b1552' THEN
   RAISE EXCEPTION 'MCR_SCENE_RECOVERY_BASELINE_CHANGED';
 END IF;
 IF (SELECT md5(prosrc) FROM pg_proc WHERE oid=to_regprocedure('public.mission_generic_staff_republish_failed_v1(uuid,uuid,uuid)')) IS DISTINCT FROM 'b718f0f920e7169065b0fef492b85d67' THEN
   RAISE EXCEPTION 'MCR_SCENE_RECOVERY_BASELINE_CHANGED';
 END IF;
 IF (SELECT md5(prosrc) FROM pg_proc WHERE oid=to_regprocedure('public.mission_generic_event_settle_v1(uuid,bigint,uuid,jsonb)')) IS DISTINCT FROM 'd36a742e380fbcb23cd42532eb679c9a' THEN
   RAISE EXCEPTION 'MCR_SCENE_RECOVERY_BASELINE_CHANGED';
 END IF;
 IF (SELECT md5(prosrc) FROM pg_proc WHERE oid=to_regprocedure('mission_generic_owner.event_capture_v1()')) IS DISTINCT FROM 'e467eaa738c30a39877d3c3aebd43b62' THEN
   RAISE EXCEPTION 'MCR_SCENE_RECOVERY_BASELINE_CHANGED';
 END IF;
 IF (SELECT md5(prosrc) FROM pg_proc WHERE oid=to_regprocedure('mission_narrative_internal.scene_message_permitted_v1(public.messages)')) IS DISTINCT FROM '37d3c7cd5fc16e5763cf4cb2878a6bcc' THEN
   RAISE EXCEPTION 'MCR_SCENE_RECOVERY_BASELINE_CHANGED';
 END IF;
 IF (SELECT md5(prosrc) FROM pg_proc WHERE oid=to_regprocedure('mission_narrative_internal.scene_publish_v1(uuid,jsonb)')) IS DISTINCT FROM '2380ca0654f9b915992d2f0cb3530a2f' THEN
   RAISE EXCEPTION 'MCR_SCENE_RECOVERY_BASELINE_CHANGED';
 END IF;
 IF (SELECT md5(prosrc) FROM pg_proc WHERE oid=to_regprocedure('mission_narrative_internal.scene_open_current_v1(uuid,uuid)')) IS DISTINCT FROM '5a17b3f8ea971b56b2619fde7b430482' THEN
   RAISE EXCEPTION 'MCR_SCENE_RECOVERY_BASELINE_CHANGED';
 END IF;
 IF to_regprocedure('mission_generic_owner.staff_paid_scene_recovery_allowed_v1(uuid,uuid,uuid)') IS NOT NULL
  OR to_regprocedure('mission_generic_owner.staff_paid_scene_recovery_publish_v1(uuid,uuid,uuid)') IS NOT NULL
 THEN RAISE EXCEPTION 'MCR_SCENE_RECOVERY_ALREADY_PRESENT'; END IF;
END
$preflight$;

CREATE FUNCTION mission_generic_owner.staff_paid_scene_recovery_allowed_v1(p_session uuid,p_work uuid,p_staff uuid)
RETURNS boolean
LANGUAGE sql STABLE SECURITY DEFINER SET search_path TO ''
AS $function$
 SELECT EXISTS(
  SELECT 1
  FROM mission_generic_owner.work_items w
  JOIN public.master_v2_sessions m ON m.id=w.master_session_id
  JOIN public.locations loc ON loc.id=m.location_id AND loc.is_test AND loc.is_active
  JOIN public.mission_run_state run ON run.master_session_id=m.id
  JOIN mission_narrative_internal.scene_sources_v1 src ON src.work_id=w.id AND src.id=w.authority_receipt_id
  JOIN mission_narrative_internal.scene_runtime_v1 scene ON scene.id=src.scene_id AND scene.master_session_id=m.id
  JOIN mission_generic_owner.event_outbox_v1 ev ON ev.work_id=w.id AND ev.master_session_id=m.id
  JOIN mission_narrative_internal.dispatch_receipts dr ON dr.id=w.dispatch_receipt_id
  JOIN mission_narrative_internal.provider_outputs_v1 retained ON retained.work_id=w.id
    AND retained.dispatch_receipt_id=dr.id AND retained.authorization_id=w.authorization_id
    AND retained.dispatch_id=w.dispatch_id
  JOIN mission_narrative_internal.dispatch_attempts attempt ON attempt.receipt_id=dr.id AND attempt.attempt_no=1
  JOIN staff_ai_quota_private.calls quota ON quota.producer='mission_generic_ai' AND quota.source_id=dr.id
    AND quota.scope_id=m.id AND quota.call_no=1
  WHERE p_session='57a79d9b-6b70-4e4a-95dc-e1e14ec63aa2'::uuid
    AND p_work='2df46bec-3ab1-91dd-7ce5-05a33e68ef2a'::uuid
    AND p_staff IS NOT NULL
    AND (auth.uid()=p_staff OR (auth.uid() IS NULL AND public.combat_v2_is_service()))
    AND w.id=p_work AND m.id=p_session AND m.location_id='0b85f354-9cdb-47e1-baf9-3d266bb7e06b'::uuid
    AND m.owner_kind='ai_service' AND m.master_user IS NULL AND m.stato='in_corso'
    AND m.closed_at IS NULL AND m.suspended_at IS NULL
    AND run.run_phase='in_corso' AND run.current_step_key=w.step_key AND run.control_version=w.run_control_version
    AND mission_academy_owner.staff_carrier_runtime(p_session)
    AND mission_generic_owner.flow_scope_enabled(p_session)
    AND EXISTS(SELECT 1 FROM public.profiles p WHERE p.id=p_staff AND p.role IN ('admin','master'))
    AND EXISTS(SELECT 1 FROM public.master_v2_participants p JOIN public.characters c ON c.id=p.character_id
      AND c.user_id=p_staff WHERE p.session_id=m.id AND p.user_id_snapshot=p_staff
      AND p.left_at IS NULL AND p.engagement_state='attivo')
    AND combat_consumer_private.staff_test_allowed(m.location_id,ARRAY[p_staff],false)
    AND src.id='7badc6f7-91bb-935a-3835-b9b07aa8e48c'::uuid AND w.event_id=src.id
    AND src.actor_user_id=p_staff AND src.request_kind='narration' AND src.retired_at IS NULL
    AND src.published_message_id IS NULL AND src.technical_receipt IS NULL
    AND scene.is_active AND scene.mode='narrative' AND scene.turn_owner='fato'
    AND scene.state_version=src.state_version AND scene.current_phase_key=src.current_phase_key
    AND scene.last_publication_id IS NOT DISTINCT FROM src.last_publication_id
    AND scene.last_publication_sha256 IS NOT DISTINCT FROM src.last_publication_sha256
    AND ev.event_key='1d070dd4-0d02-4734-884b-70d2727ffcc7'::uuid AND ev.event_version=223
    AND ev.event_domain='role_window' AND ev.root_principal=p_staff AND ev.claim_id IS NOT NULL
    AND ev.state IN ('uncertain','running')
    AND ev.canonical_request=jsonb_build_object('schema_version','mission-generic-request/1',
      'master_session_id',m.id,'event_id',w.event_id,'request_key',w.request_key,'expected_revision',w.revision)
    AND w.kind='narration' AND w.state='failed' AND w.message_id IS NULL AND w.finalized_at IS NOT NULL
    AND w.payload->>'schema_version'='mission-narrative-scene/1' AND w.payload->>'mode'='narrative_scene'
    AND w.payload_sha256='22bf6782ace110eddcb52e4ff9556b46e2862e75b2a0e47fcdc847e5b0a3035b'
    AND w.payload_sha256=src.payload_sha256 AND w.payload_sha256=public.combat_v2_sha256(w.payload)
    AND w.result_sha256='ff39c75d1789a44a22b1cc523a890a8015bf53716f64afebf5caf7a828d79b30'
    AND public.combat_v2_sha256(w.result)='4b03021377311b4e798297f61c26aa836cedc66617055367486ccbb725a085f8'
    AND w.result->'ok'='true'::jsonb AND w.result->>'provider_status'='completed' AND w.result->>'provider_calls'='1'
    AND w.result->'outcome_uncertain'='false'::jsonb AND w.result#>>'{scene_update,next_step}'='combat:inizio'
    AND w.receipt_id='5b050a15-10f5-4576-b861-e62c16fb5996'::uuid
    AND dr.id='491d1dbe-f8ac-4307-acb4-9429b8815cbf'::uuid
    AND dr.master_session_id=m.id AND dr.authority_receipt_id=w.id AND dr.request_key=w.request_key
    AND dr.status='success' AND dr.dispatch_count=1 AND dr.finalized_at IS NOT NULL
    AND retained.provider_status='completed'
    AND retained.raw_sha256='1ca538367407dfbaf15e0a90d842dd714f828015a125c2459bda5da7c6e55739'
    AND retained.raw_sha256=encode(extensions.digest(convert_to(retained.raw_output,'UTF8'),'sha256'),'hex')
    AND attempt.status='success' AND attempt.cost_basis='exact' AND attempt.finalized_at IS NOT NULL
    AND quota.state='settled' AND quota.charged_usd=dr.charged_cost_usd
    AND attempt.actual_cost_usd=dr.charged_cost_usd AND dr.charged_cost_usd=0.00103690
    AND EXISTS(SELECT 1 FROM mission_narrative_internal.dispatch_audit fail
      WHERE fail.receipt_id=dr.id AND fail.event_code='generic_finalized'
      AND fail.details @> jsonb_build_object('work_id',w.id,'receipt_id',w.receipt_id,'state','failed',
       'message_id',NULL,'stale',false,'outcome_uncertain',false,'application_error_sqlstate','40001',
       'result_sha256',w.result_sha256,'result_jsonb_sha256',public.combat_v2_sha256(w.result)))
    AND NOT EXISTS(SELECT 1 FROM mission_generic_owner.work_items other WHERE other.master_session_id=m.id
      AND other.id<>w.id AND (other.created_at>w.created_at OR other.state IN ('ready','claimed','authorized','provider_started','uncertain')))
    AND NOT EXISTS(SELECT 1 FROM public.combat_v2_sessions other WHERE other.master_session_id=m.id AND other.closed_at IS NULL)
 )
$function$;
REVOKE ALL ON FUNCTION mission_generic_owner.staff_paid_scene_recovery_allowed_v1(uuid,uuid,uuid)
 FROM PUBLIC,anon,authenticated,service_role;

CREATE FUNCTION mission_generic_owner.staff_paid_scene_recovery_publish_v1(p_session uuid,p_work uuid,p_staff uuid)
RETURNS jsonb
LANGUAGE plpgsql SECURITY DEFINER SET search_path TO ''
AS $function$
DECLARE
 w mission_generic_owner.work_items;
 e mission_generic_owner.event_outbox_v1;
 source mission_narrative_internal.scene_sources_v1;
 native_claim jsonb;
 published jsonb;
 mid uuid;
 error_state text;
 error_message text;
 safe_code text;
 error_context text;
 safe_frames jsonb;
BEGIN
 PERFORM mission_ai_board_owner.service_only();
 IF p_session IS DISTINCT FROM '57a79d9b-6b70-4e4a-95dc-e1e14ec63aa2'::uuid
   OR p_work IS DISTINCT FROM '2df46bec-3ab1-91dd-7ce5-05a33e68ef2a'::uuid OR p_staff IS NULL
 THEN RAISE EXCEPTION 'MCR_SCENE_RECOVERY_SCOPE' USING ERRCODE='42501'; END IF;
 PERFORM pg_advisory_xact_lock_shared(hashtextextended('C1266:GENERIC-AI:AVAILABILITY',0));
 PERFORM 1 FROM public.locations WHERE id='0b85f354-9cdb-47e1-baf9-3d266bb7e06b'::uuid FOR UPDATE;
 PERFORM 1 FROM mission_generic_owner.role_window_cursors WHERE master_session_id=p_session FOR UPDATE;
 PERFORM public.master_v2_lock_scope(p_session);
 PERFORM mission_generic_owner.dispatch_user(p_session,p_staff);
 SELECT * INTO STRICT w FROM mission_generic_owner.work_items WHERE id=p_work AND master_session_id=p_session FOR UPDATE;
 SELECT * INTO STRICT e FROM mission_generic_owner.event_outbox_v1
   WHERE event_key='1d070dd4-0d02-4734-884b-70d2727ffcc7'::uuid AND event_version=223
    AND work_id=w.id AND master_session_id=p_session AND root_principal=p_staff FOR UPDATE;
 SELECT * INTO STRICT source FROM mission_narrative_internal.scene_sources_v1
   WHERE id=w.authority_receipt_id AND work_id=w.id AND actor_user_id=p_staff;
 IF w.state='completed' AND w.message_id IS NOT NULL
  AND EXISTS(SELECT 1 FROM mission_narrative_internal.dispatch_audit proof
    JOIN public.messages msg ON msg.id=w.message_id AND msg.kind='fato' AND msg.recipient_user IS NULL
    WHERE proof.receipt_id=w.dispatch_receipt_id AND proof.event_code='staff_cached_publication_completed'
     AND source.published_message_id=w.message_id AND source.technical_receipt->>'publication_id'=msg.id::text
     AND msg.body=w.result->>'text'
     AND proof.details @> jsonb_build_object('schema_version','mission-native-scene-saved-publication/1',
      'work_id',w.id,'master_session_id',w.master_session_id,'message_id',msg.id,'actor_user_id',p_staff))
 THEN RETURN jsonb_build_object('schema_version','mission-generic-staff-cached-publication/1',
   'status','published','message_id',w.message_id,'replayed',true);
 END IF;
 native_claim:=jsonb_build_object('mode','cached_publication','body',jsonb_build_object(
   'schema_version','mission-generic-staff-cached-publication/1','master_session_id',p_session,'work_id',p_work));
 IF NOT mission_generic_owner.staff_paid_scene_recovery_allowed_v1(p_session,p_work,p_staff)
  OR e.state<>'running' OR e.recovery_request_key IS NULL OR e.claim_expires_at IS NULL
  OR e.claim_expires_at<=clock_timestamp()
  OR e.next_result->>'state' IS DISTINCT FROM 'dispatch'
  OR e.next_result->>'claim_id' IS DISTINCT FROM e.claim_id::text
  OR e.next_result->'request' IS DISTINCT FROM e.canonical_request
  OR e.native_claim_sha256 IS DISTINCT FROM public.combat_v2_sha256(native_claim)
 THEN RAISE EXCEPTION 'MCR_SCENE_RECOVERY_PROOF' USING ERRCODE='42501';END IF;
 BEGIN
   -- Same transactional adapter already used for a paid cached Combat publication.
   -- No lease, claim, provider authorization, quota, or dispatch row is issued or changed.
   UPDATE mission_generic_owner.work_items SET state='provider_started',finalized_at=NULL
     WHERE id=w.id AND state='failed';
   IF NOT FOUND THEN RAISE EXCEPTION 'MCR_SCENE_RECOVERY_CAS' USING ERRCODE='40001'; END IF;
   published:=mission_narrative_internal.scene_publish_v1(w.id,w.result);
   mid:=(published->>'message_id')::uuid;
   IF mid IS NULL OR published->>'next_step' IS DISTINCT FROM 'combat:inizio'
      OR NOT EXISTS(SELECT 1 FROM mission_narrative_internal.scene_sources_v1 src
        JOIN mission_narrative_internal.scene_runtime_v1 scene ON scene.id=src.scene_id
        JOIN public.messages msg ON msg.id=src.published_message_id AND msg.id=mid
          AND msg.location_id='0b85f354-9cdb-47e1-baf9-3d266bb7e06b'::uuid
          AND msg.kind='fato' AND msg.character_id IS NULL AND msg.sender_user IS NULL AND msg.recipient_user IS NULL
        JOIN public.combat_v2_sessions fight ON fight.id::text=src.technical_receipt->>'encounter_id'
          AND fight.master_session_id=w.master_session_id AND fight.closed_at IS NULL
        WHERE src.id=source.id AND src.work_id=w.id AND src.technical_receipt=published->'combat_open'
          AND scene.last_publication_id=mid AND scene.mode='combat' AND scene.turn_owner='combat'
          AND msg.body=w.result->>'text'
          AND combat_panel_private.uses_simulated_pools(fight.id) AND NOT public.combat_v2_values_written(fight.id))
   THEN RAISE EXCEPTION 'MCR_SCENE_RECOVERY_PUBLICATION' USING ERRCODE='40001'; END IF;
   UPDATE mission_generic_owner.work_items SET state='completed',message_id=mid,finalized_at=clock_timestamp()
    WHERE id=w.id AND state='provider_started' AND dispatch_receipt_id=w.dispatch_receipt_id
      AND receipt_id=w.receipt_id AND result_sha256=w.result_sha256 AND result=w.result;
   IF NOT FOUND THEN RAISE EXCEPTION 'MCR_SCENE_RECOVERY_CHANGED' USING ERRCODE='40001'; END IF;
   INSERT INTO mission_narrative_internal.dispatch_audit(receipt_id,event_code,details)
   VALUES(w.dispatch_receipt_id,'staff_cached_publication_completed',jsonb_build_object(
     'schema_version','mission-native-scene-saved-publication/1','work_id',w.id,'master_session_id',p_session,
     'message_id',mid,'actor_user_id',p_staff,'saved_result_sha256',w.result_sha256,'generation_http_calls',0)),
    (w.dispatch_receipt_id,'generic_finalized',jsonb_build_object(
     'work_id',w.id,'receipt_id',w.receipt_id,'message_id',mid,'result_sha256',w.result_sha256,
     'result_jsonb_sha256',public.combat_v2_sha256(w.result),'command_receipt',published,
     'state','completed','stale',false,'outcome_uncertain',false,'cost_basis','exact',
     'application_error_sqlstate',NULL,'application_error_code',NULL,'recovered_cached_result',true));
 EXCEPTION WHEN OTHERS THEN
   GET STACKED DIAGNOSTICS error_state=RETURNED_SQLSTATE,error_message=MESSAGE_TEXT,error_context=PG_EXCEPTION_CONTEXT;
   SELECT coalesce(jsonb_agg(jsonb_build_object('function',parts[1],'line',parts[2]::int) ORDER BY ordinal),'[]'::jsonb)
    INTO safe_frames
    FROM (SELECT parts,ordinal FROM regexp_matches(error_context,
      'PL/pgSQL function ([A-Za-z_][A-Za-z0-9_.]*)[(][^)]*[)] line ([0-9]{1,6})','g')
      WITH ORDINALITY matches(parts,ordinal) LIMIT 8) frames;
   safe_code:=CASE WHEN upper(error_message) ~ '^[A-Z][A-Z0-9_]{1,79}$'
    THEN upper(error_message) ELSE 'SQLSTATE_'||error_state END;
 END;
 IF safe_code IS NOT NULL THEN
  INSERT INTO mission_narrative_internal.dispatch_audit(receipt_id,event_code,details)
   VALUES(w.dispatch_receipt_id,'staff_cached_publication_rejected',jsonb_build_object(
     'schema_version','mission-native-scene-saved-publication/1','work_id',w.id,'master_session_id',p_session,
     'sqlstate',error_state,'error_code',safe_code,'frames',safe_frames,'generation_http_calls',0));
  RETURN jsonb_build_object('schema_version','mission-generic-staff-cached-publication/1','status','failed','error_code',safe_code);
 END IF;
 -- The owner of the running event claim reconciles it using mission_generic_event_settle_v1.
 RETURN jsonb_build_object('schema_version','mission-generic-staff-cached-publication/1',
  'status','published','message_id',mid,'replayed',false);
END
$function$;
REVOKE ALL ON FUNCTION mission_generic_owner.staff_paid_scene_recovery_publish_v1(uuid,uuid,uuid)
 FROM PUBLIC,anon,authenticated,service_role;

CREATE OR REPLACE FUNCTION public.mission_generic_staff_republish_failed_v1(p_session uuid, p_work uuid, p_staff uuid)
 RETURNS jsonb
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO ''
 SET statement_timeout TO '30s'
AS $function$
declare
 native_root17 mission_generic_owner.event_outbox_v1;native_cfg17 jsonb;native_req17 jsonb;native_event17 uuid;native_wake17 bigint;
  w mission_generic_owner.work_items;
  b mission_generic_owner.unified_batches;
  source_row mission_generic_owner.unified_source_windows;
  m public.master_v2_sessions;
  run_row public.mission_run_state;
  receipt mission_narrative_internal.dispatch_receipts;
  result_row jsonb;recovery_combat jsonb;
  error_state text;
  error_message text;
  error_constraint text;
  error_table text;
  error_schema text;
  safe_code text;
  message_ref uuid;
  factory_cached boolean:=false; saved_manual jsonb; saved_request jsonb;
  diagnostic_column text;
  diagnostic_context text;
  diagnostic_frames jsonb;
  native_selection_detail text;native_selection_diagnostic jsonb;
  successor mission_generic_owner.work_items;
  successor_id uuid;
  successor_event uuid;
  successor_key uuid; old_director mission_generic_owner.work_items; recovery_progress mission_generic_owner.progress_receipts; recovery_root jsonb;
begin
  perform mission_ai_board_owner.service_only();
  if p_session is null or p_work is null or p_staff is null then
    raise exception 'MCR_INPUT' using errcode='22023';
  end if;
  IF p_work='2df46bec-3ab1-91dd-7ce5-05a33e68ef2a'::uuid THEN
    RETURN mission_generic_owner.staff_paid_scene_recovery_publish_v1(p_session,p_work,p_staff);
  END IF;
  select * into strict m from public.master_v2_sessions where id=p_session;

 -- Native scene Combat /2 owns a real report, never a Unified batch.
 IF EXISTS(SELECT 1 FROM mission_generic_owner.work_items x WHERE x.id=p_work AND x.master_session_id=p_session
  AND x.kind='narration' AND x.payload->>'schema_version'='mission-generic-narration/2' AND x.payload->>'mode'='combat'
  AND((x.result->>'schema_version'='mission-generic-pre-provider-failure/1' AND x.result->>'failure_code'='request_validation_failed')
   OR(x.result->>'schema_version'='mission-generic-result/1' AND x.result->'failure_codes'='["below_required_minimum"]'::jsonb
    AND x.result->>'provider_status'='completed' AND x.result->>'outcome_uncertain'='false'))) THEN
  PERFORM 1 FROM mission_generic_owner.role_window_cursors WHERE master_session_id=p_session FOR UPDATE;
  PERFORM public.master_v2_lock_scope(p_session);
  SELECT * INTO STRICT w FROM mission_generic_owner.work_items WHERE id=p_work AND master_session_id=p_session FOR UPDATE;
  PERFORM public.combat_v2_lock_round((w.payload#>>'{scene_binding,round_id}')::uuid);
  recovery_combat:=mission_generic_owner.native_combat_writer_reissue_proof_v1(w.id,p_staff);
  IF recovery_combat IS NULL OR recovery_combat->>'owned_by_me' IS DISTINCT FROM 'true' THEN
   RAISE EXCEPTION 'MCR_NATIVE_WRITER_PROOF' USING ERRCODE='42501';END IF;
  IF recovery_combat->>'successor_work_id' IS NOT NULL THEN
   IF recovery_combat->>'published'='true' THEN
    message_ref:=(recovery_combat->>'successor_publication_id')::uuid;
    IF message_ref IS NULL THEN RAISE EXCEPTION 'MCR_NATIVE_WRITER_PUBLICATION_PROOF' USING ERRCODE='40001';END IF;
    RETURN jsonb_build_object('schema_version','mission-generic-staff-cached-publication/1',
     'status','published','message_id',message_ref,'replayed',true);
   END IF;
   RETURN jsonb_build_object('schema_version','mission-generic-staff-cached-publication/1',
    'status','recovered','master_session_id',p_session,
    'work_id',(recovery_combat->>'successor_work_id')::uuid,'replayed',true);
  END IF;
  IF recovery_combat->>'can_reissue' IS DISTINCT FROM 'true' OR EXISTS(SELECT 1 FROM mission_generic_owner.work_items x
   WHERE x.master_session_id=p_session AND x.state IN('ready','claimed','authorized','provider_started','uncertain')) THEN
   RAISE EXCEPTION 'MCR_NATIVE_WRITER_PENDING' USING ERRCODE='40001';END IF;
  PERFORM mission_generic_owner.dispatch_user(p_session,p_staff);
  PERFORM mission_generic_owner.work_assert(w);
  IF mission_generic_owner.role_native_combat_work_class_v4(w.id) IS DISTINCT FROM 'native_combat_narration'
   OR (mission_generic_owner.combat_narrative_source(p_session,w.authority_receipt_id)->'payload') IS DISTINCT FROM w.payload
  THEN RAISE EXCEPTION 'MCR_NATIVE_WRITER_SOURCE_CHANGED' USING ERRCODE='40001';END IF;
  successor_id:=mission_ai_service_owner.uuid5(w.id,'native-combat-writer-reissue/1:work');
  successor_event:=mission_ai_service_owner.uuid5(w.id,'native-combat-writer-reissue/1:event');
  successor_key:=mission_ai_service_owner.uuid5(w.id,'native-combat-writer-reissue/1:request');
  INSERT INTO mission_generic_owner.work_items(id,master_session_id,event_id,request_key,dedupe_key,step_key,
   run_control_version,definition_sha256,encounter_id,authority_receipt_id,kind,revision,payload,payload_sha256)
   VALUES(successor_id,p_session,successor_event,successor_key,'native-combat-writer-reissue:'||w.id::text,
    w.step_key,w.run_control_version,w.definition_sha256,w.encounter_id,w.authority_receipt_id,'narration',w.revision,w.payload,w.payload_sha256)
   RETURNING * INTO successor;
  INSERT INTO mission_narrative_internal.dispatch_audit(receipt_id,event_code,details)
   VALUES(w.dispatch_receipt_id,CASE WHEN recovery_combat->>'failure_class'='completed_minimum_rejected' THEN 'native_combat_writer_technical_reissued_v1' ELSE 'native_combat_writer_preprovider_reissued_v1' END,jsonb_build_object(
    'schema_version','mission-native-combat-writer-reissue/1','master_session_id',p_session,'failed_work_id',w.id,
    'old_receipt_id',w.receipt_id,'old_result_sha256',w.result_sha256,'successor_work_id',successor.id,
    'successor_request_key',successor.request_key,'report_id',w.authority_receipt_id,
    'report_sha256',recovery_combat->>'report_sha256','payload_sha256',w.payload_sha256,
    'actor_user_id',p_staff,'provider_calls',0,'old_failure_preserved',true)
    ||CASE WHEN recovery_combat->>'failure_class'='completed_minimum_rejected' THEN jsonb_build_object(
     'technical_failure_code','below_required_minimum','old_provider_calls',1,'old_charged_cost_usd',recovery_combat->'old_charged_cost_usd') ELSE '{}'::jsonb END);
  result_row:=mission_public_owner.work_contract_issue_v1(successor.id);
  IF (result_row->'features'?'combat_snapshot_origin_budget_v1') IS DISTINCT FROM true THEN
   RAISE EXCEPTION 'MCR_NATIVE_WRITER_CONTRACT' USING ERRCODE='40001';END IF;
  SELECT * INTO STRICT native_root17 FROM mission_generic_owner.event_outbox_v1
   WHERE master_session_id=p_session AND event_domain='start' AND event_version=1;
  SELECT rr.canonical_preimage::jsonb#>'{config,c1266_server_events}' INTO native_cfg17
   FROM mission_factory_owner.editor_release_readiness rr WHERE rr.singleton AND rr.state='enabled'
    AND rr.scope='staff' AND rr.revision_sha256=rr.observed_revision_sha256;
  IF native_root17.root_principal IS DISTINCT FROM p_staff OR native_cfg17->>'schema_version' IS DISTINCT FROM 'c1266-server-events/1'
   OR native_cfg17->'enabled' IS DISTINCT FROM 'true'::jsonb THEN
   RAISE EXCEPTION 'MCR_NATIVE_WRITER_WAKE_SCOPE' USING ERRCODE='42501';END IF;
  native_req17:=jsonb_build_object('schema_version','mission-generic-request/1','master_session_id',p_session,
   'event_id',successor.event_id,'request_key',successor.request_key,'expected_revision',successor.revision);
  native_event17:=mission_ai_service_owner.uuid5(successor.id,'server-event:writer-ready');
  INSERT INTO mission_generic_owner.event_outbox_v1(event_key,event_version,master_session_id,event_domain,source_id,
   source_sha256,root_event_key,root_request_key,root_principal,root_receipt_sha256,work_id,canonical_request)
   VALUES(native_event17,1,p_session,'writer_ready',successor.id,successor.payload_sha256,
    native_root17.root_event_key,native_root17.root_request_key,native_root17.root_principal,
    native_root17.root_receipt_sha256,successor.id,native_req17);
  native_wake17:=net.http_post(native_cfg17->>'endpoint',jsonb_build_object('schema_version','mission-event-wake/2',
   'event_key',native_event17,'event_version',1),'{}'::jsonb,
   jsonb_build_object('Content-Type','application/json','x-tus-server-event','event42'),5000);
  UPDATE mission_generic_owner.event_outbox_v1 SET wake_request_id=native_wake17 WHERE event_key=native_event17 AND event_version=1;
  IF mission_generic_owner.native_combat_writer_reissue_proof_v1(w.id,p_staff) IS NULL THEN
   RAISE EXCEPTION 'MCR_NATIVE_WRITER_ATTESTATION' USING ERRCODE='40001';END IF;
  RETURN jsonb_build_object('schema_version','mission-generic-staff-cached-publication/1','status','recovered',
   'master_session_id',p_session,'work_id',successor.id,'replayed',false);
 END IF;

 -- Saved-success native narration/3: publication only, no provider operation.
 IF EXISTS(SELECT 1 FROM mission_generic_owner.work_items x
   WHERE x.id=p_work AND x.master_session_id=p_session AND x.kind='narration'
    AND x.payload->>'schema_version'='mission-generic-narration/3'
    AND x.payload->>'mode'='unified' AND x.state IN('failed','completed')
    AND x.result->>'ok'='true' AND x.result->>'provider_calls'='1'
    AND x.result->>'outcome_uncertain'='false') THEN
  saved_manual:=mission_generic_owner.manual_staff_scope_v1(p_session);
  IF NOT EXISTS(SELECT 1 FROM public.profiles WHERE id=p_staff AND role IN('admin','master'))
   OR saved_manual IS NULL OR m.owner_kind IS DISTINCT FROM 'ai_service' OR m.master_user IS NOT NULL
   OR m.location_id IS DISTINCT FROM '0b85f354-9cdb-47e1-baf9-3d266bb7e06b'::uuid
   OR NOT EXISTS(SELECT 1 FROM public.locations loc WHERE loc.id=m.location_id AND loc.is_test AND loc.is_active)
   THEN RAISE EXCEPTION 'MCR_NATIVE_SAVED_SCOPE' USING ERRCODE='42501';END IF;
  PERFORM 1 FROM mission_generic_owner.role_window_cursors WHERE master_session_id=p_session FOR UPDATE;
  IF NOT FOUND THEN RAISE EXCEPTION 'MCR_CURSOR_MISSING' USING ERRCODE='55000';END IF;
  PERFORM public.master_v2_lock_scope(p_session);
  SELECT * INTO STRICT w FROM mission_generic_owner.work_items WHERE id=p_work AND master_session_id=p_session FOR UPDATE;
  SELECT * INTO STRICT b FROM mission_generic_owner.unified_batches WHERE id=w.authority_receipt_id
    AND master_session_id=p_session AND writer_work_id=w.id FOR UPDATE;
  SELECT * INTO STRICT receipt FROM mission_narrative_internal.dispatch_receipts WHERE id=w.dispatch_receipt_id FOR SHARE;
  saved_request:=jsonb_build_object('schema_version','mission-generic-request/1',
    'master_session_id',w.master_session_id,'event_id',w.event_id,'request_key',w.request_key,'expected_revision',w.revision);
  IF mission_generic_owner.c1266_historical_work_manual_v1(w.id,saved_manual)->>'execution_context' IS DISTINCT FROM 'staff_mission'
   OR w.result_sha256 !~ '^[a-f0-9]{64}$' OR w.result->>'raw_sha256' !~ '^[a-f0-9]{64}$'
   OR w.payload_sha256 IS DISTINCT FROM public.combat_v2_sha256(w.payload)
   OR w.result->>'work_id' IS DISTINCT FROM w.id::text
   OR w.result->>'master_session_id' IS DISTINCT FROM p_session::text
   OR w.result->>'request_key' IS DISTINCT FROM w.request_key::text
   OR w.result->>'payload_sha256' IS DISTINCT FROM w.payload_sha256
   OR w.result->>'authorization_id' IS DISTINCT FROM w.authorization_id::text
   OR w.result->>'dispatch_id' IS DISTINCT FROM w.dispatch_id::text
   OR receipt.master_session_id IS DISTINCT FROM p_session OR receipt.authority_receipt_id IS DISTINCT FROM w.id
   OR receipt.request_key IS DISTINCT FROM w.request_key OR receipt.status IS DISTINCT FROM 'success'
   OR receipt.dispatch_count IS DISTINCT FROM 1 OR receipt.finalized_at IS NULL
   OR receipt.event_kind IS DISTINCT FROM 'mission_generic_event' OR receipt.renderer_version IS DISTINCT FROM 'mission-generic-runtime/1'
   OR receipt.request_fingerprint IS DISTINCT FROM mission_internal.fingerprint(saved_request)
   OR receipt.envelope_sha256 IS DISTINCT FROM public.combat_v2_sha256(receipt.envelope)
   OR receipt.authority_sha256 IS DISTINCT FROM receipt.envelope_sha256
   OR receipt.envelope->>'work_id' IS DISTINCT FROM w.id::text
   OR receipt.envelope->>'master_session_id' IS DISTINCT FROM p_session::text
   OR receipt.envelope->>'event_id' IS DISTINCT FROM w.event_id::text
   OR receipt.envelope->>'authority_receipt_id' IS DISTINCT FROM w.authority_receipt_id::text
   OR receipt.envelope->>'payload_sha256' IS DISTINCT FROM w.payload_sha256
   OR receipt.envelope->>'definition_sha256' IS DISTINCT FROM w.definition_sha256
   OR receipt.envelope->'revision' IS DISTINCT FROM to_jsonb(w.revision)
   OR (SELECT count(*) FROM mission_narrative_internal.dispatch_audit own_a
       WHERE own_a.receipt_id=receipt.id AND own_a.event_code='c1266_async_owner_v1')<>1
   OR NOT EXISTS(SELECT 1 FROM mission_narrative_internal.dispatch_audit own_a
     WHERE own_a.receipt_id=receipt.id AND own_a.event_code='c1266_async_owner_v1'
       AND mission_factory_owner.keys_exact_v2(own_a.details,ARRAY['schema_version','actor_user_id','work_id','request_sha256','envelope_sha256','provider_timeout_ms'])
       AND own_a.details->>'schema_version'='mission-generic-async-owner/1'
       AND own_a.details->>'actor_user_id'=p_staff::text AND own_a.details->>'work_id'=w.id::text
       AND own_a.details->>'request_sha256'=public.combat_v2_sha256(saved_request)
       AND own_a.details->>'envelope_sha256'=receipt.envelope_sha256 AND own_a.details->'provider_timeout_ms'='240000'::jsonb)
   OR NOT EXISTS(SELECT 1 FROM mission_narrative_internal.dispatch_audit ga
     WHERE ga.receipt_id=receipt.id AND ga.event_code='generic_finalized'
       AND ga.details->>'work_id'=w.id::text AND ga.details->>'receipt_id'=w.receipt_id::text
       AND ga.details->>'result_sha256'=w.result_sha256 AND ga.details->>'result_jsonb_sha256'=public.combat_v2_sha256(w.result)
       AND ga.details->>'state'='failed' AND ga.details->>'stale'='false'
       AND ga.details->>'outcome_uncertain'='false' AND ga.details->>'application_error_sqlstate' IS NOT NULL)
   OR NOT EXISTS(SELECT 1 FROM mission_narrative_internal.provider_authorizations pa
       JOIN mission_narrative_internal.dispatch_attempts da ON da.id=pa.attempt_id AND da.receipt_id=pa.receipt_id
       WHERE pa.id=w.authorization_id AND pa.receipt_id=receipt.id AND da.status='success'
         AND da.finalized_at IS NOT NULL AND da.cost_basis='exact' AND da.actual_cost_usd=receipt.charged_cost_usd)
   OR NOT EXISTS(SELECT 1 FROM mission_narrative_internal.dispatch_audit count_a
     WHERE count_a.receipt_id=receipt.id AND count_a.event_code='c8_count_success'
       AND count_a.details->>'work_id'=w.id::text AND count_a.details->>'state'='success'
       AND count_a.details->>'generation_allowed'='true')
   OR (SELECT count(*) FROM staff_ai_quota_private.calls q WHERE q.producer='mission_generic_ai' AND q.source_id=receipt.id)<>2
   OR EXISTS(SELECT 1 FROM staff_ai_quota_private.calls q WHERE q.producer='mission_generic_ai' AND q.source_id=receipt.id
       AND (q.scope_id IS DISTINCT FROM p_session OR q.call_no NOT IN(1,2) OR q.state NOT IN('settled','unknown_billable')
         OR (q.state='settled' AND (q.charged_usd IS NULL OR q.charged_usd<0))
         OR (q.state='unknown_billable' AND (q.reserved_usd IS NULL OR q.reserved_usd<receipt.upper_bound_cost_usd))))
   OR NOT EXISTS(SELECT 1 FROM staff_ai_quota_private.calls q WHERE q.producer='mission_generic_ai' AND q.source_id=receipt.id
       AND q.scope_id=p_session AND q.state='settled' AND q.charged_usd=receipt.charged_cost_usd)
   OR b.retired_at IS NOT NULL OR b.source_window_id IS NOT NULL OR b.decision_work_id IS NOT NULL OR b.decision IS NOT NULL
   OR b.encounter_id IS DISTINCT FROM w.encounter_id OR b.step_key IS DISTINCT FROM w.step_key
   OR b.run_control_version IS DISTINCT FROM w.run_control_version OR b.payload IS DISTINCT FROM w.payload
   OR b.payload_sha256 IS DISTINCT FROM w.payload_sha256 OR w.payload->>'batch_id' IS DISTINCT FROM b.id::text
   OR w.payload->>'composition_kind' IS DISTINCT FROM b.composition_kind OR w.payload->'source_windows' IS DISTINCT FROM '[]'::jsonb
   OR w.payload#>>'{publication_barrier,closed}' IS DISTINCT FROM 'true'
   OR w.payload#>'{publication_barrier,receipt_ids}' IS DISTINCT FROM w.payload#>'{publication_barrier,required_receipt_ids}'
   OR (w.payload#>'{publication_barrier,receipt_ids}' @> jsonb_build_array(b.id,b.source_report_id)) IS DISTINCT FROM TRUE
   OR NOT EXISTS(SELECT 1 FROM public.combat_v2_round_reports rr JOIN public.combat_v2_rounds rnd ON rnd.id=rr.round_id
     JOIN mission_generic_owner.encounters enc ON enc.encounter_id=rnd.session_id AND enc.master_session_id=p_session
     WHERE rr.id=b.source_report_id AND rnd.id=b.source_round_id AND rnd.session_id=b.encounter_id
       AND rr.values_written IS FALSE AND rr.mechanics_sha256=public.combat_v2_sha256(rr.mechanics)
       AND EXISTS(SELECT 1 FROM jsonb_array_elements(w.payload->'resolved_scenes') rs
         WHERE rs#>>'{scene_binding,round_id}'=rnd.id::text AND rs#>>'{scene_binding,session_id}'=b.encounter_id::text
           AND rs#>>'{scene_binding,report_sha256}'=rr.mechanics_sha256
           AND rs#>'{barrier,required_receipt_ids}' @> jsonb_build_array(rr.id)))
   OR (b.secondary_report_id IS NOT NULL AND NOT EXISTS(
     SELECT 1 FROM public.combat_v2_round_reports rr JOIN public.combat_v2_rounds rnd ON rnd.id=rr.round_id
     WHERE rr.id=b.secondary_report_id AND rnd.session_id=b.encounter_id AND rr.values_written IS FALSE
       AND rr.mechanics_sha256=public.combat_v2_sha256(rr.mechanics)
       AND w.payload#>'{publication_barrier,receipt_ids}' @> jsonb_build_array(rr.id)
       AND EXISTS(SELECT 1 FROM jsonb_array_elements(w.payload->'resolved_scenes') rs
         WHERE rs#>>'{scene_binding,round_id}'=rnd.id::text AND rs#>>'{scene_binding,report_sha256}'=rr.mechanics_sha256)))
   THEN RAISE EXCEPTION 'MCR_NATIVE_SAVED_PROOF' USING ERRCODE='42501';END IF;
  -- Replay requires real publication, never terminal work state alone.
  IF w.state='completed' AND w.message_id IS NOT NULL AND b.state='published'
    AND b.message_id=w.message_id AND b.published_at IS NOT NULL
    AND EXISTS(SELECT 1 FROM public.messages mm WHERE mm.id=w.message_id AND mm.body=w.result->>'text'
      AND mm.kind='fato' AND mm.recipient_user IS NULL AND mm.location_id=m.location_id)
    AND EXISTS(SELECT 1 FROM mission_generic_owner.unified_report_publications up
      JOIN public.combat_v2_round_reports rr ON rr.id=up.report_id AND rr.message_id=up.message_id
      JOIN public.combat_v2_rounds rnd ON rnd.id=rr.round_id AND rnd.state='narrato'
      WHERE up.batch_id=b.id AND up.report_id=b.source_report_id AND up.primary_report
       AND up.message_id=w.message_id AND rr.narration_state='pubblicata')
    AND (b.secondary_report_id IS NULL OR EXISTS(SELECT 1 FROM mission_generic_owner.unified_report_publications up
      JOIN public.combat_v2_round_reports rr ON rr.id=up.report_id AND rr.narration_state='pubblicata' AND rr.message_id IS NULL
      JOIN public.combat_v2_rounds rnd ON rnd.id=rr.round_id AND rnd.state='narrato'
      WHERE up.batch_id=b.id AND up.report_id=b.secondary_report_id AND NOT up.primary_report AND up.message_id=w.message_id)) THEN
   RETURN jsonb_build_object('schema_version','mission-generic-staff-cached-publication/1',
      'status','published','message_id',w.message_id,'replayed',true);
  END IF;
  PERFORM mission_generic_owner.dispatch_user(p_session,p_staff);
  IF w.state IS DISTINCT FROM 'failed' OR w.message_id IS NOT NULL OR w.finalized_at IS NULL
    OR b.state IS DISTINCT FROM 'ready' OR b.message_id IS NOT NULL OR b.retired_at IS NOT NULL
    OR b.source_window_id IS NOT NULL OR b.decision_work_id IS NOT NULL
    OR b.source_round_id IS NULL OR b.source_report_id IS NULL
    OR w.payload IS DISTINCT FROM b.payload OR w.payload_sha256 IS DISTINCT FROM b.payload_sha256
    OR w.payload_sha256 IS DISTINCT FROM public.combat_v2_sha256(w.payload)
    OR w.result->>'text' IS DISTINCT FROM btrim(w.result->>'text')
    OR length(coalesce(w.result->>'text','')) NOT BETWEEN 1 AND 5000
    OR receipt.status IS DISTINCT FROM 'success' OR receipt.dispatch_count IS DISTINCT FROM 1
    OR receipt.authority_receipt_id IS DISTINCT FROM w.id OR receipt.master_session_id IS DISTINCT FROM p_session
    OR receipt.request_key IS DISTINCT FROM w.request_key OR receipt.finalized_at IS NULL
    OR EXISTS(SELECT 1 FROM mission_generic_owner.work_items other WHERE other.master_session_id=p_session
      AND other.id<>w.id AND other.state IN('ready','claimed','authorized','provider_started','uncertain'))
   THEN RAISE EXCEPTION 'MCR_NATIVE_SAVED_BINDING' USING ERRCODE='P0001';END IF;
  PERFORM mission_generic_owner.work_assert(w);
  BEGIN
   -- No authorization, Count, Generation or provider dispatch is issued by this branch.
   UPDATE mission_generic_owner.work_items SET state='provider_started',finalized_at=NULL,
      lease_expires_at=greatest(lease_expires_at,clock_timestamp()+interval '60 seconds')
    WHERE id=w.id AND state='failed';
   IF NOT FOUND THEN RAISE EXCEPTION 'MCR_NATIVE_SAVED_CAS' USING ERRCODE='P0001';END IF;
   result_row:=mission_generic_owner.unified_publish(w.id,w.result->>'text',w.request_key);
   message_ref:=(result_row->>'message_id')::uuid;
   IF message_ref IS NULL OR NOT EXISTS(SELECT 1 FROM mission_generic_owner.unified_batches ub
      JOIN public.messages mm ON mm.id=ub.message_id WHERE ub.id=b.id AND ub.state='published'
      AND ub.writer_work_id=w.id AND ub.message_id=message_ref AND mm.body=w.result->>'text')
     THEN RAISE EXCEPTION 'MCR_NATIVE_SAVED_PUBLICATION' USING ERRCODE='P0001';END IF;
   UPDATE mission_generic_owner.work_items SET state='completed',message_id=message_ref,
      finalized_at=clock_timestamp(),lease_expires_at=w.lease_expires_at
    WHERE id=w.id AND state='provider_started' AND result IS NOT DISTINCT FROM w.result
      AND result_sha256 IS NOT DISTINCT FROM w.result_sha256;
   IF NOT FOUND THEN RAISE EXCEPTION 'MCR_NATIVE_SAVED_RESULT_CHANGED' USING ERRCODE='P0001';END IF;
  EXCEPTION WHEN OTHERS THEN
   GET STACKED DIAGNOSTICS error_state=returned_sqlstate,error_message=message_text,
      diagnostic_context=pg_exception_context;
   safe_code:=CASE WHEN error_message ~ '^[A-Z][A-Z0-9_]{1,79}$' THEN error_message ELSE NULL END;
   IF safe_code IS NULL AND octet_length(error_message)<=8192 THEN
    BEGIN
     native_selection_diagnostic:=error_message::jsonb;
     safe_code:=coalesce(native_selection_diagnostic->>'code',native_selection_diagnostic->>'error_code');
     IF safe_code !~ '^[A-Z][A-Z0-9_]{1,79}$' THEN safe_code:=NULL;END IF;
    EXCEPTION WHEN invalid_text_representation THEN safe_code:=NULL;END;
   END IF;
   safe_code:=coalesce(safe_code,'SQLSTATE_'||error_state);
   SELECT coalesce(jsonb_agg(jsonb_build_object('function',parts[1],'line',parts[2]::integer)
      ORDER BY ordinal),'[]'::jsonb) INTO diagnostic_frames FROM
      (SELECT parts,ordinal FROM regexp_matches(diagnostic_context,
       'PL/pgSQL function ([A-Za-z_][A-Za-z0-9_.]*)\([^)]*\) line ([0-9]{1,6})','g')
       WITH ORDINALITY f(parts,ordinal) LIMIT 8) frames;
  END;
  IF safe_code IS NOT NULL THEN
   INSERT INTO mission_narrative_internal.dispatch_audit(receipt_id,event_code,details)
    VALUES(receipt.id,'staff_cached_publication_rejected',jsonb_build_object(
      'schema_version','mission-native-saved-publication-diagnostic/1','work_id',w.id,
      'master_session_id',p_session,'sqlstate',error_state,'error_code',safe_code,
      'frames',diagnostic_frames,'generation_http_calls',0));
   RETURN jsonb_build_object('schema_version','mission-generic-staff-cached-publication/1',
     'status','failed','error_code',safe_code);
  END IF;
  INSERT INTO mission_narrative_internal.dispatch_audit(receipt_id,event_code,details)
   VALUES(receipt.id,'staff_cached_publication_completed',jsonb_build_object(
     'schema_version','mission-native-saved-publication/1','work_id',w.id,'master_session_id',p_session,
     'message_id',message_ref,'saved_result_sha256',w.result_sha256,'generation_http_calls',0));
  RETURN jsonb_build_object('schema_version','mission-generic-staff-cached-publication/1',
    'status','published','message_id',message_ref,'replayed',false);
 END IF;

 -- A failed Combat Writer before any Count/Generation is immutable. Reissue its same sealed report in a distinct work.
 IF EXISTS(SELECT 1 FROM mission_generic_owner.work_items x WHERE x.id=p_work AND x.master_session_id=p_session AND x.kind='narration' AND x.payload->>'schema_version'='mission-generic-narration/3' AND x.result->>'schema_version'='mission-generic-pre-provider-failure/1' AND x.result->>'failure_code'='request_validation_failed') THEN
  recovery_combat:=mission_generic_owner.combat_narration_reissue_proof_v1(p_work,p_staff);
  IF recovery_combat IS NULL OR recovery_combat->>'owned_by_me' IS DISTINCT FROM 'true' THEN RAISE EXCEPTION 'MCR_COMBAT_REISSUE_PROOF' USING ERRCODE='42501';END IF;
  PERFORM 1 FROM mission_generic_owner.role_window_cursors WHERE master_session_id=p_session FOR UPDATE;
  PERFORM public.master_v2_lock_scope(p_session);
  SELECT * INTO STRICT w FROM mission_generic_owner.work_items WHERE id=p_work AND master_session_id=p_session FOR UPDATE;
  SELECT * INTO STRICT b FROM mission_generic_owner.unified_batches WHERE id=w.authority_receipt_id AND master_session_id=p_session FOR UPDATE;
  PERFORM 1 FROM public.combat_v2_rounds WHERE id=b.source_round_id FOR UPDATE;
  PERFORM 1 FROM public.combat_v2_round_reports WHERE id=b.source_report_id FOR UPDATE;
  recovery_combat:=mission_generic_owner.combat_narration_reissue_proof_v1(p_work,p_staff);
  IF recovery_combat IS NULL OR recovery_combat->>'owned_by_me' IS DISTINCT FROM 'true' THEN RAISE EXCEPTION 'MCR_COMBAT_REISSUE_CHANGED' USING ERRCODE='40001';END IF;
  IF recovery_combat->>'published'='true' THEN RETURN jsonb_build_object('schema_version','mission-generic-staff-cached-publication/1','status','published','message_id',b.message_id,'replayed',true);END IF;
  IF recovery_combat->>'successor_work_id' IS NOT NULL THEN RETURN jsonb_build_object('schema_version','mission-generic-staff-cached-publication/1','status','recovered','master_session_id',p_session,'work_id',(recovery_combat->>'successor_work_id')::uuid,'replayed',true);END IF;
  IF recovery_combat->>'can_reissue' IS DISTINCT FROM 'true' OR EXISTS(SELECT 1 FROM mission_generic_owner.work_items nw WHERE nw.master_session_id=p_session AND nw.state IN('ready','claimed','authorized','provider_started','uncertain')) THEN RAISE EXCEPTION 'MCR_COMBAT_REISSUE_PENDING' USING ERRCODE='40001';END IF;
  PERFORM mission_generic_owner.dispatch_user(p_session,p_staff);
  PERFORM mission_generic_owner.work_assert(w);
  successor_id:=mission_ai_service_owner.uuid5(w.id,'mission-combat-narration-reissue/1:work');
  successor_event:=mission_ai_service_owner.uuid5(w.id,'mission-combat-narration-reissue/1:event');
  successor_key:=mission_ai_service_owner.uuid5(w.id,'mission-combat-narration-reissue/1:request');
  INSERT INTO mission_generic_owner.work_items(id,master_session_id,event_id,request_key,dedupe_key,step_key,run_control_version,definition_sha256,encounter_id,authority_receipt_id,kind,revision,payload,payload_sha256)
   VALUES(successor_id,p_session,successor_event,successor_key,'combat-narration-reissue:'||w.id::text,w.step_key,w.run_control_version,w.definition_sha256,w.encounter_id,b.id,'narration',w.revision,w.payload,w.payload_sha256) RETURNING * INTO successor;
  UPDATE mission_generic_owner.unified_batches SET writer_work_id=successor.id WHERE id=b.id AND writer_work_id=w.id AND state='ready' AND message_id IS NULL AND retired_at IS NULL;
  IF NOT FOUND THEN RAISE EXCEPTION 'MCR_COMBAT_REISSUE_CAS' USING ERRCODE='40001';END IF;
  INSERT INTO mission_narrative_internal.dispatch_audit(receipt_id,event_code,details) VALUES(w.dispatch_receipt_id,'staff_combat_narration_preprovider_reissued',jsonb_build_object('schema_version','mission-combat-narration-reissue/1','master_session_id',p_session,'failed_work_id',w.id,'old_receipt_id',w.receipt_id,'old_result_sha256',w.result_sha256,'successor_work_id',successor.id,'successor_request_key',successor.request_key,'batch_id',b.id,'report_id',b.source_report_id,'report_sha256',recovery_combat->>'report_sha256','payload_sha256',w.payload_sha256,'actor_user_id',p_staff,'provider_calls',0,'old_failure_preserved',true));
  result_row:=mission_public_owner.work_contract_issue_v1(successor.id);
  IF (result_row->'features'?'combat_snapshot_origin_budget_v1') IS DISTINCT FROM TRUE THEN RAISE EXCEPTION 'MCR_COMBAT_REISSUE_CONTRACT' USING ERRCODE='40001';END IF;
  IF mission_generic_owner.combat_narration_reissue_proof_v1(w.id,p_staff) IS NULL THEN RAISE EXCEPTION 'MCR_COMBAT_REISSUE_ATTESTATION';END IF;
  RETURN jsonb_build_object('schema_version','mission-generic-staff-cached-publication/1','status','recovered','master_session_id',p_session,'work_id',successor.id,'replayed',false);
 END IF;



 IF p_session='44078c5f-7001-4129-9506-e2f34e68c8ac'::uuid AND p_work='310493d3-92d2-4645-ba85-ab42f57dbf9d'::uuid THEN
  PERFORM mission_generic_owner.dispatch_user(p_session,p_staff);
  IF p_staff<>'b4952ed5-5ce0-49c0-9f2b-8fd5dcd89b4b'::uuid OR NOT EXISTS(SELECT 1 FROM public.profiles WHERE id=p_staff AND role IN('admin','master'))
   OR m.location_id<>'0b85f354-9cdb-47e1-baf9-3d266bb7e06b'::uuid OR m.owner_kind<>'ai_service' OR m.closed_at IS NOT NULL OR m.suspended_at IS NOT NULL
   OR mission_generic_owner.manual_staff_scope_v1(p_session) IS NULL THEN RAISE EXCEPTION 'FREE_RECOVERY_SCOPE' USING ERRCODE='42501';END IF;
  PERFORM 1 FROM mission_generic_owner.role_window_cursors WHERE master_session_id=p_session FOR UPDATE;
  PERFORM public.master_v2_lock_scope(p_session);
  successor_key:=mission_ai_service_owner.uuid5('310493d3-92d2-4645-ba85-ab42f57dbf9d'::uuid,'mission-staff-unpublished-reinterpretation/1:ac9aedbd59dcb835d717f4ddb6ce195e3c2a9d640df576667290fa38b7e6cbbb');
  SELECT * INTO recovery_progress FROM mission_generic_owner.progress_receipts WHERE request_key=successor_key;
  IF FOUND THEN
   IF recovery_progress.master_session_id<>p_session OR recovery_progress.actor_user_id<>p_staff OR recovery_progress.result_sha256<>public.combat_v2_sha256(recovery_progress.result)
    OR NOT mission_generic_owner.role_source_released_v4('433ace05-5265-4aad-96a3-5567b6e3480a'::uuid) THEN RAISE EXCEPTION 'FREE_RECOVERY_REPLAY_CONFLICT';END IF;
   SELECT * INTO STRICT successor FROM mission_generic_owner.work_items WHERE id=(recovery_progress.result#>>'{dispatch,event_id}')::uuid AND master_session_id=p_session;
   RETURN jsonb_build_object('schema_version','mission-generic-staff-cached-publication/1','status','recovered','master_session_id',p_session,'work_id',successor.id,'replayed',true);
  END IF;
  SELECT * INTO STRICT w FROM mission_generic_owner.work_items WHERE id=p_work AND master_session_id=p_session FOR UPDATE;
  SELECT * INTO STRICT old_director FROM mission_generic_owner.work_items WHERE id='433ace05-5265-4aad-96a3-5567b6e3480a'::uuid AND master_session_id=p_session FOR UPDATE;
  SELECT * INTO STRICT b FROM mission_generic_owner.unified_batches WHERE id='0adc85b5-7a66-4d13-a919-4233b1d41857'::uuid AND writer_work_id=w.id AND decision_work_id=old_director.id AND source_window_id=old_director.id FOR UPDATE;
  SELECT * INTO STRICT source_row FROM mission_generic_owner.unified_source_windows WHERE id=old_director.id AND work_id=old_director.id AND master_session_id=p_session FOR UPDATE;
  SELECT canonical_preimage::jsonb INTO STRICT recovery_root FROM mission_factory_owner.editor_release_readiness WHERE singleton AND state='enabled' AND revision_sha256=observed_revision_sha256;
  IF recovery_root#>>'{config,c1266_free_narrative,enabled}' IS DISTINCT FROM 'true' OR recovery_root#>>'{config,c1266_free_narrative,master_session_id}' IS DISTINCT FROM p_session::text
    OR recovery_root#>>'{config,c1266_free_narrative,recovery_writer_id}' IS DISTINCT FROM w.id::text THEN RAISE EXCEPTION 'FREE_RECOVERY_RELEASE';END IF;
  IF w.kind<>'narration' OR w.state<>'failed' OR (w.result->'failure_codes' ? 'MISSION_SEGMENTED_SLOT_COVERAGE_INVALID') IS NOT TRUE
   OR w.result_sha256<>'3a86177027166f250966eeeceb844e1de5efe3efc6caaab42b6832f72428c275'
   OR public.combat_v2_sha256(w.result)<>'01866a3b46c797b430dd4a1d4430176899b0c37dc80e23515d621d2a59f38508'
   OR public.combat_v2_sha256(old_director.result)<>'e68c2eb57650d7a33fa1069565b686fe3db33e8b1309ffc98dfd60fa6fdcb766'
   OR w.payload_sha256<>'5fe7195653506a31f5d263d2a14af8793c1fdbcf5bf54a2d305d9724937d8523'
   OR old_director.kind<>'director' OR old_director.state<>'completed' OR old_director.result_sha256<>'b8f03c42eb2f531897b04e0b21905784843e20c039fd6a3a3627f3202cb08ace'
   OR old_director.payload_sha256<>'e1c8499e6907024d340cfadb28f880895061c5f5ffbca8f9372945f510c9ef4e'
   OR w.message_id IS NOT NULL OR old_director.message_id IS NOT NULL OR b.state<>'ready' OR b.message_id IS NOT NULL OR b.encounter_id IS NOT NULL OR b.next_round_id IS NOT NULL
   OR source_row.superseded_at IS NOT NULL OR source_row.consumed_message_id IS NOT NULL
   OR source_row.context->>'source_revision'<>'ac9aedbd59dcb835d717f4ddb6ce195e3c2a9d640df576667290fa38b7e6cbbb' OR mission_generic_owner.role_source_revision_v1(p_session)<>'ac9aedbd59dcb835d717f4ddb6ce195e3c2a9d640df576667290fa38b7e6cbbb'
   OR source_row.role_ids<>ARRAY['d59bf486-65b8-4a93-8b60-6cb516bb9481'::uuid,'73f030ea-4b37-423a-93bb-f991ded79e35'::uuid]
   OR EXISTS(SELECT 1 FROM unnest(source_row.role_ids) rid WHERE NOT EXISTS(SELECT 1 FROM mission_generic_owner.role_latest_v1(p_session) lr WHERE lr.message_id=rid AND lr.valid))
   OR EXISTS(SELECT 1 FROM public.combat_v2_sessions WHERE master_session_id=p_session AND closed_at IS NULL)
   OR EXISTS(SELECT 1 FROM mission_generic_owner.work_items nw WHERE nw.master_session_id=p_session AND nw.created_at>w.created_at)
   OR EXISTS(SELECT 1 FROM mission_generic_owner.unified_segment_publications_v4 WHERE work_id=w.id)
   OR EXISTS(SELECT 1 FROM mission_generic_owner.work_items x WHERE x.id IN(w.id,old_director.id) AND(x.finalized_at IS NULL OR x.payload_sha256<>public.combat_v2_sha256(x.payload)))
   OR (SELECT count(*) FROM mission_generic_owner.work_items x JOIN mission_narrative_internal.dispatch_receipts dr ON dr.id=x.dispatch_receipt_id AND dr.master_session_id=p_session AND dr.authority_receipt_id=x.id AND dr.request_key=x.request_key AND dr.dispatch_count=1 AND dr.finalized_at IS NOT NULL
      JOIN staff_ai_quota_private.calls q ON q.producer='mission_generic_ai' AND q.source_id=dr.id AND q.call_no=1 AND q.scope_id=p_session AND q.state='settled' AND q.charged_usd=dr.charged_cost_usd WHERE x.id IN(w.id,old_director.id))<>2
  THEN RAISE EXCEPTION 'FREE_RECOVERY_SOURCE_PROOF' USING ERRCODE='40001';END IF;
  UPDATE mission_generic_owner.unified_source_windows SET superseded_at=clock_timestamp(),superseded_reason='staff_unpublished_reinterpretation' WHERE id=source_row.id;
  INSERT INTO mission_narrative_internal.dispatch_audit(receipt_id,event_code,details)VALUES(old_director.dispatch_receipt_id,'staff_unpublished_reinterpretation',jsonb_build_object('schema_version','mission-unpublished-reinterpretation/1','master_session_id',p_session,'source_window_id',source_row.id,'source_revision','ac9aedbd59dcb835d717f4ddb6ce195e3c2a9d640df576667290fa38b7e6cbbb','director_result_sha256',old_director.result_sha256,'writer_result_sha256',w.result_sha256,'successor_progress_key',successor_key,'actor_user',p_staff,'old_work_preserved',true,'generation_http_calls',0));
  result_row:=mission_generic_owner.progress_step(p_session,p_staff,successor_key);
  INSERT INTO mission_generic_owner.progress_receipts(request_key,master_session_id,actor_user_id,result,result_sha256)VALUES(successor_key,p_session,p_staff,result_row,public.combat_v2_sha256(result_row));
  SELECT * INTO STRICT successor FROM mission_generic_owner.work_items WHERE id=(result_row#>>'{dispatch,event_id}')::uuid AND kind='director' AND state='ready' AND master_session_id=p_session;
  result_row:=mission_public_owner.work_contract_issue_v1(successor.id);
  IF (result_row->'features' ? 'provider_output_retention_v1') IS DISTINCT FROM TRUE THEN RAISE EXCEPTION 'FREE_RECOVERY_NEW_CONTRACT';END IF;
  RETURN jsonb_build_object('schema_version','mission-generic-staff-cached-publication/1','status','recovered','master_session_id',p_session,'work_id',successor.id,'replayed',false);
 END IF;


 IF p_session='44078c5f-7001-4129-9506-e2f34e68c8ac'::uuid AND p_work='e76f31f2-eded-495e-9c5f-f03461c5cc3a'::uuid THEN
  PERFORM mission_generic_owner.dispatch_user(p_session,p_staff);
  IF p_staff<>'b4952ed5-5ce0-49c0-9f2b-8fd5dcd89b4b'::uuid OR NOT EXISTS(SELECT 1 FROM public.profiles WHERE id=p_staff AND role IN('admin','master')) OR m.location_id<>'0b85f354-9cdb-47e1-baf9-3d266bb7e06b'::uuid OR m.owner_kind<>'ai_service' OR m.closed_at IS NOT NULL OR m.suspended_at IS NOT NULL OR mission_generic_owner.manual_staff_scope_v1(p_session) IS NULL THEN RAISE EXCEPTION 'SAVED_CONTEXT_RECOVERY_SCOPE';END IF;
  PERFORM 1 FROM mission_generic_owner.role_window_cursors WHERE master_session_id=p_session FOR UPDATE;
  PERFORM public.master_v2_lock_scope(p_session);
  SELECT * INTO STRICT w FROM mission_generic_owner.work_items WHERE id=p_work AND master_session_id=p_session FOR UPDATE;
  IF ((w.id='e76f31f2-eded-495e-9c5f-f03461c5cc3a'::uuid AND w.master_session_id='44078c5f-7001-4129-9506-e2f34e68c8ac'::uuid AND w.kind='director' AND w.state='failed' AND w.message_id IS NULL
 AND w.payload_sha256='f962403b87a5c6bf6930818e4d5655e57451d1adebbd404702f4a75ae7bcf03a' AND w.payload_sha256=public.combat_v2_sha256(w.payload)
 AND w.result_sha256='73c3158fe44061c34b1dc410daec3fda85cd98ee3fadbbc063bbfdea5982571d' AND public.combat_v2_sha256(w.result)='cee81d0c273baaf64705be7b53c884778f063bcd739461c777666cdcbd440ad4'
 AND w.result->>'ok'='true' AND w.result->>'provider_calls'='1' AND w.result->>'outcome_uncertain'='false'
 AND EXISTS(SELECT 1 FROM mission_public_owner.work_contracts_v1 wc WHERE wc.work_id=w.id AND wc.contract_sha256='ad13df1382af67d4af779f9f16790085468f3c14a9dd9c2c16d145477038f302' AND wc.contract_sha256=public.combat_v2_sha256(wc.contract) AND wc.release_sha256='feaf314957d5dab65a2420748e935015e5aa2e16fb2aed996e38e11e57189243' AND wc.contract->'features'?'provider_output_retention_v1')
 AND EXISTS(SELECT 1 FROM mission_narrative_internal.provider_outputs_v1 raw WHERE raw.id=(w.result->>'output_receipt_id')::uuid AND raw.work_id=w.id AND raw.authorization_id=w.authorization_id AND raw.dispatch_id=w.dispatch_id AND raw.dispatch_receipt_id=w.dispatch_receipt_id AND raw.raw_sha256=w.result->>'raw_sha256' AND raw.raw_sha256=encode(extensions.digest(convert_to(raw.raw_output,'UTF8'),'sha256'),'hex'))
 AND EXISTS(SELECT 1 FROM mission_narrative_internal.dispatch_receipts dr JOIN mission_narrative_internal.dispatch_audit fa ON fa.receipt_id=dr.id AND fa.event_code='generic_finalized'
  JOIN staff_ai_quota_private.calls q ON q.producer='mission_generic_ai' AND q.source_id=dr.id AND q.scope_id=w.master_session_id AND q.call_no=1 AND q.state='settled' AND q.charged_usd=dr.charged_cost_usd
 WHERE dr.id=w.dispatch_receipt_id AND dr.master_session_id=w.master_session_id AND dr.authority_receipt_id=w.id AND dr.request_key=w.request_key AND dr.status='success' AND dr.dispatch_count=1 AND dr.finalized_at IS NOT NULL
 AND fa.details->>'work_id'=w.id::text AND fa.details->>'receipt_id'=w.receipt_id::text AND fa.details->>'result_sha256'=w.result_sha256 AND fa.details->>'result_jsonb_sha256'=public.combat_v2_sha256(w.result)
 AND fa.details->>'application_error_sqlstate'='23505' AND fa.details->'command_receipt'='null'::jsonb AND fa.details->>'stale'='false' AND fa.details->>'outcome_uncertain'='false'))) IS DISTINCT FROM TRUE THEN RAISE EXCEPTION 'SAVED_CONTEXT_RECOVERY_RESULT_PROOF';END IF;
  SELECT * INTO b FROM mission_generic_owner.unified_batches WHERE decision_work_id=w.id;
  IF b.id IS NOT NULL AND (((w.id='e76f31f2-eded-495e-9c5f-f03461c5cc3a'::uuid AND w.master_session_id='44078c5f-7001-4129-9506-e2f34e68c8ac'::uuid AND w.kind='director' AND w.state='failed' AND w.message_id IS NULL
 AND w.payload_sha256='f962403b87a5c6bf6930818e4d5655e57451d1adebbd404702f4a75ae7bcf03a' AND w.payload_sha256=public.combat_v2_sha256(w.payload)
 AND w.result_sha256='73c3158fe44061c34b1dc410daec3fda85cd98ee3fadbbc063bbfdea5982571d' AND public.combat_v2_sha256(w.result)='cee81d0c273baaf64705be7b53c884778f063bcd739461c777666cdcbd440ad4'
 AND w.result->>'ok'='true' AND w.result->>'provider_calls'='1' AND w.result->>'outcome_uncertain'='false'
 AND EXISTS(SELECT 1 FROM mission_public_owner.work_contracts_v1 wc WHERE wc.work_id=w.id AND wc.contract_sha256='ad13df1382af67d4af779f9f16790085468f3c14a9dd9c2c16d145477038f302' AND wc.contract_sha256=public.combat_v2_sha256(wc.contract) AND wc.release_sha256='feaf314957d5dab65a2420748e935015e5aa2e16fb2aed996e38e11e57189243' AND wc.contract->'features'?'provider_output_retention_v1')
 AND EXISTS(SELECT 1 FROM mission_narrative_internal.provider_outputs_v1 raw WHERE raw.id=(w.result->>'output_receipt_id')::uuid AND raw.work_id=w.id AND raw.authorization_id=w.authorization_id AND raw.dispatch_id=w.dispatch_id AND raw.dispatch_receipt_id=w.dispatch_receipt_id AND raw.raw_sha256=w.result->>'raw_sha256' AND raw.raw_sha256=encode(extensions.digest(convert_to(raw.raw_output,'UTF8'),'sha256'),'hex'))
 AND EXISTS(SELECT 1 FROM mission_narrative_internal.dispatch_receipts dr JOIN mission_narrative_internal.dispatch_audit fa ON fa.receipt_id=dr.id AND fa.event_code='generic_finalized'
  JOIN staff_ai_quota_private.calls q ON q.producer='mission_generic_ai' AND q.source_id=dr.id AND q.scope_id=w.master_session_id AND q.call_no=1 AND q.state='settled' AND q.charged_usd=dr.charged_cost_usd
 WHERE dr.id=w.dispatch_receipt_id AND dr.master_session_id=w.master_session_id AND dr.authority_receipt_id=w.id AND dr.request_key=w.request_key AND dr.status='success' AND dr.dispatch_count=1 AND dr.finalized_at IS NOT NULL
 AND fa.details->>'work_id'=w.id::text AND fa.details->>'receipt_id'=w.receipt_id::text AND fa.details->>'result_sha256'=w.result_sha256 AND fa.details->>'result_jsonb_sha256'=public.combat_v2_sha256(w.result)
 AND fa.details->>'application_error_sqlstate'='23505' AND fa.details->'command_receipt'='null'::jsonb AND fa.details->>'stale'='false' AND fa.details->>'outcome_uncertain'='false')) AND EXISTS(SELECT 1 FROM mission_narrative_internal.dispatch_audit ap JOIN mission_generic_owner.unified_batches ab ON ab.decision_work_id=w.id AND ab.master_session_id=w.master_session_id
 JOIN mission_generic_owner.work_items aw ON aw.id=ab.writer_work_id AND aw.master_session_id=w.master_session_id AND aw.authority_receipt_id=ab.id AND aw.kind='narration'
 WHERE ap.receipt_id=w.dispatch_receipt_id AND ap.event_code='c1266_saved_director_applied' AND ap.details->>'schema_version'='c1266-saved-director-application/1'
 AND ap.details->>'master_session_id'=w.master_session_id::text AND ap.details->>'work_id'=w.id::text AND ap.details->>'result_sha256'=w.result_sha256 AND ap.details->>'batch_id'=ab.id::text AND ap.details->>'writer_work_id'=aw.id::text AND ap.details->>'generation_http_calls'='0' AND ap.details->>'failed_work_preserved'='true'
 AND ab.retired_at IS NULL AND ab.state='ready' AND aw.state='ready' AND ab.message_id IS NULL AND aw.message_id IS NULL)) OR ((w.id='e76f31f2-eded-495e-9c5f-f03461c5cc3a'::uuid AND w.master_session_id='44078c5f-7001-4129-9506-e2f34e68c8ac'::uuid AND w.kind='director' AND w.state='failed' AND w.message_id IS NULL
 AND w.payload_sha256='f962403b87a5c6bf6930818e4d5655e57451d1adebbd404702f4a75ae7bcf03a' AND w.payload_sha256=public.combat_v2_sha256(w.payload)
 AND w.result_sha256='73c3158fe44061c34b1dc410daec3fda85cd98ee3fadbbc063bbfdea5982571d' AND public.combat_v2_sha256(w.result)='cee81d0c273baaf64705be7b53c884778f063bcd739461c777666cdcbd440ad4'
 AND w.result->>'ok'='true' AND w.result->>'provider_calls'='1' AND w.result->>'outcome_uncertain'='false'
 AND EXISTS(SELECT 1 FROM mission_public_owner.work_contracts_v1 wc WHERE wc.work_id=w.id AND wc.contract_sha256='ad13df1382af67d4af779f9f16790085468f3c14a9dd9c2c16d145477038f302' AND wc.contract_sha256=public.combat_v2_sha256(wc.contract) AND wc.release_sha256='feaf314957d5dab65a2420748e935015e5aa2e16fb2aed996e38e11e57189243' AND wc.contract->'features'?'provider_output_retention_v1')
 AND EXISTS(SELECT 1 FROM mission_narrative_internal.provider_outputs_v1 raw WHERE raw.id=(w.result->>'output_receipt_id')::uuid AND raw.work_id=w.id AND raw.authorization_id=w.authorization_id AND raw.dispatch_id=w.dispatch_id AND raw.dispatch_receipt_id=w.dispatch_receipt_id AND raw.raw_sha256=w.result->>'raw_sha256' AND raw.raw_sha256=encode(extensions.digest(convert_to(raw.raw_output,'UTF8'),'sha256'),'hex'))
 AND EXISTS(SELECT 1 FROM mission_narrative_internal.dispatch_receipts dr JOIN mission_narrative_internal.dispatch_audit fa ON fa.receipt_id=dr.id AND fa.event_code='generic_finalized'
  JOIN staff_ai_quota_private.calls q ON q.producer='mission_generic_ai' AND q.source_id=dr.id AND q.scope_id=w.master_session_id AND q.call_no=1 AND q.state='settled' AND q.charged_usd=dr.charged_cost_usd
 WHERE dr.id=w.dispatch_receipt_id AND dr.master_session_id=w.master_session_id AND dr.authority_receipt_id=w.id AND dr.request_key=w.request_key AND dr.status='success' AND dr.dispatch_count=1 AND dr.finalized_at IS NOT NULL
 AND fa.details->>'work_id'=w.id::text AND fa.details->>'receipt_id'=w.receipt_id::text AND fa.details->>'result_sha256'=w.result_sha256 AND fa.details->>'result_jsonb_sha256'=public.combat_v2_sha256(w.result)
 AND fa.details->>'application_error_sqlstate'='23505' AND fa.details->'command_receipt'='null'::jsonb AND fa.details->>'stale'='false' AND fa.details->>'outcome_uncertain'='false')) AND EXISTS(SELECT 1 FROM mission_narrative_internal.dispatch_audit ap JOIN mission_generic_owner.unified_batches ab ON ab.decision_work_id=w.id AND ab.master_session_id=w.master_session_id
 JOIN mission_generic_owner.work_items aw ON aw.id=ab.writer_work_id AND aw.master_session_id=w.master_session_id AND aw.authority_receipt_id=ab.id AND aw.kind='narration'
 WHERE ap.receipt_id=w.dispatch_receipt_id AND ap.event_code='c1266_saved_director_applied' AND ap.details->>'schema_version'='c1266-saved-director-application/1'
 AND ap.details->>'master_session_id'=w.master_session_id::text AND ap.details->>'work_id'=w.id::text AND ap.details->>'result_sha256'=w.result_sha256 AND ap.details->>'batch_id'=ab.id::text AND ap.details->>'writer_work_id'=aw.id::text AND ap.details->>'generation_http_calls'='0' AND ap.details->>'failed_work_preserved'='true'
 AND ab.retired_at IS NULL AND ab.state='published' AND aw.state='completed' AND ab.message_id=aw.message_id AND EXISTS(SELECT 1 FROM public.messages pm JOIN mission_generic_owner.unified_source_windows ps ON ps.id=ab.source_window_id AND ps.consumed_message_id=pm.id JOIN mission_generic_owner.unified_segment_publications_v4 pp ON pp.work_id=aw.id AND pp.message_id=pm.id WHERE pm.id=aw.message_id AND pm.kind='fato' AND pm.recipient_user IS NULL AND pm.body=aw.result->>'text')))) THEN RETURN jsonb_build_object('schema_version','mission-generic-staff-cached-publication/1','status','recovered','master_session_id',p_session,'work_id',b.writer_work_id,'replayed',true);END IF;
  IF b.id IS NOT NULL OR EXISTS(SELECT 1 FROM mission_generic_owner.work_items newer WHERE newer.master_session_id=p_session AND newer.created_at>w.created_at) OR EXISTS(SELECT 1 FROM public.combat_v2_sessions WHERE master_session_id=p_session AND closed_at IS NULL) THEN RAISE EXCEPTION 'SAVED_CONTEXT_RECOVERY_NEWER';END IF;
  SELECT * INTO STRICT source_row FROM mission_generic_owner.unified_source_windows WHERE id=w.authority_receipt_id AND work_id=w.id AND master_session_id=p_session FOR UPDATE;
  IF source_row.superseded_at IS NOT NULL OR source_row.consumed_message_id IS NOT NULL OR source_row.context->>'source_revision' IS DISTINCT FROM 'ac9aedbd59dcb835d717f4ddb6ce195e3c2a9d640df576667290fa38b7e6cbbb' OR mission_generic_owner.role_source_revision_v1(p_session) IS DISTINCT FROM 'ac9aedbd59dcb835d717f4ddb6ce195e3c2a9d640df576667290fa38b7e6cbbb'
   OR source_row.role_ids IS DISTINCT FROM ARRAY['d59bf486-65b8-4a93-8b60-6cb516bb9481'::uuid,'73f030ea-4b37-423a-93bb-f991ded79e35'::uuid]
   OR EXISTS(SELECT 1 FROM unnest(source_row.role_ids) rid WHERE NOT EXISTS(SELECT 1 FROM mission_generic_owner.role_latest_v1(p_session) lr WHERE lr.message_id=rid AND lr.valid)) THEN RAISE EXCEPTION 'SAVED_CONTEXT_RECOVERY_SOURCE';END IF;
  PERFORM 1 FROM mission_generic_owner.unified_batches oldb WHERE oldb.id='0adc85b5-7a66-4d13-a919-4233b1d41857'::uuid AND oldb.master_session_id=p_session AND oldb.state='ready' AND oldb.message_id IS NULL AND oldb.encounter_id IS NULL AND oldb.next_round_id IS NULL AND oldb.source_window_id='433ace05-5265-4aad-96a3-5567b6e3480a'::uuid AND mission_generic_owner.role_source_released_v4(oldb.source_window_id) FOR UPDATE;
  IF NOT FOUND THEN RAISE EXCEPTION 'SAVED_CONTEXT_OLD_PREPARATION_PROOF';END IF;
  UPDATE mission_generic_owner.unified_batches SET retired_at=clock_timestamp() WHERE id='0adc85b5-7a66-4d13-a919-4233b1d41857'::uuid AND retired_at IS NULL;
  IF FOUND THEN INSERT INTO mission_narrative_internal.dispatch_audit(receipt_id,event_code,details)VALUES(w.dispatch_receipt_id,'staff_unpublished_preparation_retired',jsonb_build_object('schema_version','mission-unpublished-preparation-retirement/1','master_session_id',p_session,'old_batch_id','0adc85b5-7a66-4d13-a919-4233b1d41857','old_source_window_id','433ace05-5265-4aad-96a3-5567b6e3480a','work_id',w.id,'generation_http_calls',0,'old_fields_preserved',true));END IF;
  result_row:=mission_generic_owner.unified_director_commit(w.id,w.result->'decision');
  SELECT * INTO STRICT b FROM mission_generic_owner.unified_batches WHERE decision_work_id=w.id AND master_session_id=p_session;
  SELECT * INTO STRICT successor FROM mission_generic_owner.work_items WHERE id=b.writer_work_id AND master_session_id=p_session AND kind='narration' AND state='ready';
  IF b.state<>'ready' OR b.message_id IS NOT NULL OR b.retired_at IS NOT NULL THEN RAISE EXCEPTION 'SAVED_CONTEXT_WRITER_NOT_READY';END IF;
  result_row:=mission_public_owner.work_contract_issue_v1(successor.id);
  IF (result_row->'features' ?& ARRAY['provider_output_retention_v1','free_narrative_v1']) IS DISTINCT FROM TRUE THEN RAISE EXCEPTION 'SAVED_CONTEXT_WRITER_CONTRACT';END IF;
  INSERT INTO mission_narrative_internal.dispatch_audit(receipt_id,event_code,details)VALUES(w.dispatch_receipt_id,'c1266_saved_director_applied',jsonb_build_object('schema_version','c1266-saved-director-application/1','master_session_id',p_session,'work_id',w.id,'result_sha256',w.result_sha256,'batch_id',b.id,'writer_work_id',successor.id,'actor_user',p_staff,'generation_http_calls',0,'failed_work_preserved',true));
  RETURN jsonb_build_object('schema_version','mission-generic-staff-cached-publication/1','status','recovered','master_session_id',p_session,'work_id',successor.id,'replayed',false);
 END IF;

  -- Named application recovery of an already charged successful Director.
  IF p_session='44078c5f-7001-4129-9506-e2f34e68c8ac'::uuid AND p_work='e366b9fa-54dc-4abd-8ba6-9ceee83be9a4'::uuid THEN
   PERFORM mission_generic_owner.dispatch_user(p_session,p_staff);
   IF p_staff<>'b4952ed5-5ce0-49c0-9f2b-8fd5dcd89b4b'::uuid OR NOT EXISTS(SELECT 1 FROM public.profiles WHERE id=p_staff AND role IN('admin','master'))
    OR m.location_id<>'0b85f354-9cdb-47e1-baf9-3d266bb7e06b'::uuid OR m.owner_kind<>'ai_service' OR m.closed_at IS NOT NULL OR m.suspended_at IS NOT NULL
   THEN RAISE EXCEPTION 'RAW_RECOVERY_STAFF_SCOPE' USING ERRCODE='42501';END IF;
   PERFORM 1 FROM mission_generic_owner.role_window_cursors WHERE master_session_id=p_session FOR UPDATE;
   PERFORM public.master_v2_lock_scope(p_session);
   SELECT * INTO STRICT w FROM mission_generic_owner.work_items WHERE id=p_work AND master_session_id=p_session FOR UPDATE;
   IF NOT (w.id='e366b9fa-54dc-4abd-8ba6-9ceee83be9a4'::uuid AND w.master_session_id='44078c5f-7001-4129-9506-e2f34e68c8ac'::uuid
 AND w.kind='director' AND w.state='failed' AND w.receipt_id='07366817-3bf6-4bad-8387-0a4c0d1804f7'::uuid
 AND w.dispatch_receipt_id='e9524086-1e03-42d8-866b-1c12eb77840a'::uuid
 AND w.payload_sha256='52ae7392cc038543f01c3a9d07532a292c6f9b7cf044d52b2ce2d0a9a7b77754'
 AND w.result_sha256='d0a4266f89198307e8c9020af67b4d2b099edc1cbf20e0aea5b38d1b78fc8ea9'
 AND public.combat_v2_sha256(w.result)='674c8253e511750022b6d9b477383aed5743ffb2c9ceee7b35a0125c10ac6201'
 AND w.result->>'ok'='true' AND w.result->>'provider_calls'='1' AND w.result->>'outcome_uncertain'='false'
 AND EXISTS(SELECT 1 FROM mission_public_owner.work_contracts_v1 wc WHERE wc.work_id=w.id AND wc.master_session_id=w.master_session_id
  AND wc.contract_sha256='0c4e3f0016df29ed7b740336e90ba58d6b1e8d72ac21ed144b9796d32073ecce'
  AND wc.contract_sha256=public.combat_v2_sha256(wc.contract) AND wc.release_sha256='e58e2e460469dced1c6efb98858b23f043fe8976988ae15bcb25525becc70cd8')
 AND EXISTS(SELECT 1 FROM mission_narrative_internal.dispatch_receipts dr JOIN mission_narrative_internal.dispatch_audit ga ON ga.receipt_id=dr.id AND ga.event_code='generic_finalized'
  JOIN staff_ai_quota_private.calls q ON q.source_id=dr.id AND q.producer='mission_generic_ai' AND q.call_no=1 AND q.scope_id=w.master_session_id AND q.state='settled' AND q.charged_usd=dr.charged_cost_usd
  WHERE dr.id=w.dispatch_receipt_id AND dr.status='success' AND dr.dispatch_count=1 AND dr.finalized_at IS NOT NULL
   AND dr.master_session_id=w.master_session_id AND dr.authority_receipt_id=w.id AND dr.request_key=w.request_key
   AND ga.details->>'work_id'=w.id::text AND ga.details->>'receipt_id'=w.receipt_id::text
   AND ga.details->>'application_error_sqlstate'='54000' AND ga.details->'command_receipt'='null'::jsonb
   AND ga.details->>'stale'='false' AND ga.details->>'outcome_uncertain'='false'
   AND ga.details->>'result_sha256'=w.result_sha256 AND ga.details->>'result_jsonb_sha256'=public.combat_v2_sha256(w.result))
 AND EXISTS(SELECT 1 FROM mission_factory_owner.editor_release_readiness rr WHERE rr.singleton AND rr.state='enabled'
  AND rr.revision_sha256=rr.observed_revision_sha256 AND rr.revision_sha256=encode(extensions.digest(convert_to(rr.canonical_preimage,'UTF8'),'sha256'),'hex')
  AND rr.canonical_preimage::jsonb#>>'{config,c1266_raw_input_recovery,schema_version}'='c1266-raw-input-recovery/1'
  AND rr.canonical_preimage::jsonb#>>'{config,c1266_raw_input_recovery,failed_work_id}'=w.id::text
  AND rr.canonical_preimage::jsonb#>>'{config,c1266_raw_input_recovery,result_sha256}'=w.result_sha256
  AND rr.canonical_preimage::jsonb#>>'{config,c1266_raw_input_recovery,commit_source_md5}'=(SELECT md5(p.prosrc)FROM pg_proc p WHERE p.oid='mission_generic_owner.unified_director_commit(uuid,jsonb)'::regprocedure)
  AND rr.canonical_preimage::jsonb#>>'{config,c1266_raw_input_recovery,cached_source_md5}'=(SELECT md5(p.prosrc)FROM pg_proc p WHERE p.oid='public.mission_generic_staff_republish_failed_v1(uuid,uuid,uuid)'::regprocedure))) THEN RAISE EXCEPTION 'RAW_RECOVERY_RESULT_PROOF' USING ERRCODE='40001';END IF;
   SELECT * INTO b FROM mission_generic_owner.unified_batches WHERE decision_work_id=w.id;
   IF b.id IS NOT NULL AND EXISTS(SELECT 1 FROM mission_narrative_internal.dispatch_audit ra WHERE ra.receipt_id=w.dispatch_receipt_id AND ra.event_code='c1266_saved_director_applied' AND ra.details->>'batch_id'=b.id::text AND ra.details->>'writer_work_id'=b.writer_work_id::text AND ra.details->>'result_sha256'=w.result_sha256) THEN
    RETURN jsonb_build_object('schema_version','mission-generic-staff-cached-publication/1','status','recovered','master_session_id',p_session,'work_id',b.writer_work_id,'replayed',true);
   END IF;
   IF b.id IS NOT NULL OR EXISTS(SELECT 1 FROM mission_generic_owner.work_items newer WHERE newer.master_session_id=p_session AND newer.created_at>w.created_at)
    OR EXISTS(SELECT 1 FROM public.combat_v2_sessions WHERE master_session_id=p_session AND closed_at IS NULL)
   THEN RAISE EXCEPTION 'RAW_RECOVERY_NEWER_WORK' USING ERRCODE='40001';END IF;
   SELECT * INTO STRICT source_row FROM mission_generic_owner.unified_source_windows WHERE id=w.authority_receipt_id AND work_id=w.id AND master_session_id=p_session FOR UPDATE;
   IF source_row.superseded_at IS NOT NULL OR source_row.consumed_message_id IS NOT NULL
    OR source_row.context->>'source_revision' IS DISTINCT FROM 'a0ba47902e6746a13c24ebae4e360db2e56dd64abad23483c09ba64411e11e51'
    OR source_row.context->>'source_revision' IS DISTINCT FROM mission_generic_owner.role_source_revision_v1(p_session)
    OR source_row.role_ids IS DISTINCT FROM ARRAY['cc335f44-c921-4b63-931d-464a59592db2'::uuid,'458c16cc-e747-49f7-9303-c81dd43cfb82'::uuid]
    OR EXISTS(SELECT 1 FROM unnest(source_row.role_ids) rid WHERE NOT EXISTS(SELECT 1 FROM mission_generic_owner.role_latest_v1(p_session) lr WHERE lr.message_id=rid AND lr.valid))
   THEN RAISE EXCEPTION 'RAW_RECOVERY_SOURCE_CHANGED' USING ERRCODE='40001';END IF;
   result_row:=mission_generic_owner.unified_director_commit(w.id,w.result->'decision');
   SELECT * INTO STRICT b FROM mission_generic_owner.unified_batches WHERE decision_work_id=w.id AND master_session_id=p_session;
   SELECT * INTO STRICT successor FROM mission_generic_owner.work_items WHERE id=b.writer_work_id AND kind='narration' AND state='ready' AND master_session_id=p_session AND authority_receipt_id=b.id;
   IF b.state<>'ready' OR b.message_id IS NOT NULL THEN RAISE EXCEPTION 'RAW_RECOVERY_WRITER_NOT_READY' USING ERRCODE='55000';END IF;
   INSERT INTO mission_narrative_internal.dispatch_audit(receipt_id,event_code,details)VALUES(w.dispatch_receipt_id,'c1266_saved_director_applied',jsonb_build_object('schema_version','c1266-saved-director-application/1','master_session_id',p_session,'work_id',w.id,'result_sha256',w.result_sha256,'batch_id',b.id,'writer_work_id',successor.id,'actor_user',p_staff,'generation_http_calls',0,'failed_work_preserved',true));
   RETURN jsonb_build_object('schema_version','mission-generic-staff-cached-publication/1','status','recovered','master_session_id',p_session,'work_id',successor.id,'replayed',false);
  END IF;
  -- Count-overflow reissue is distinct from cached successful generation publication.

 if p_session='ce7bc0e0-c8ed-48dd-a9ec-58c02022a7b9'::uuid AND p_work='c88958e7-8983-4332-a14e-095076f967f4'::uuid THEN
  PERFORM mission_generic_owner.dispatch_user(p_session,p_staff);
  IF p_staff NOT IN('f0856d53-83a6-4de0-bc0c-12c87916e665'::uuid,'b4952ed5-5ce0-49c0-9f2b-8fd5dcd89b4b'::uuid)
  OR NOT EXISTS(SELECT 1 FROM public.profiles WHERE id=p_staff AND role IN('admin','master'))
  OR m.owner_kind<>'ai_service' OR m.location_id<>'0b85f354-9cdb-47e1-baf9-3d266bb7e06b'::uuid OR m.closed_at IS NOT NULL OR m.suspended_at IS NOT NULL
  OR mission_generic_owner.c726_factory_staff_runtime_v1(p_session) IS DISTINCT FROM TRUE
  OR mission_staff_abort_private.quiescent_v1(p_session) IS DISTINCT FROM TRUE
  THEN RAISE EXCEPTION 'C889_RECOVERY_SCOPE' USING ERRCODE='42501';END IF;
  PERFORM 1 FROM public.master_v2_sessions WHERE id=p_session FOR UPDATE;
  SELECT * INTO STRICT w FROM mission_generic_owner.work_items WHERE id=p_work AND master_session_id=p_session FOR UPDATE;
  successor_id:=md5('C889:work:'||w.id::text)::uuid;successor_event:=md5('C889:event:'||w.id::text)::uuid;successor_key:=md5('C889:request:'||w.id::text)::uuid;
  SELECT * INTO STRICT b FROM mission_generic_owner.unified_batches WHERE id=w.authority_receipt_id FOR UPDATE;
  IF b.writer_work_id=successor_id THEN
   SELECT * INTO STRICT successor FROM mission_generic_owner.work_items WHERE id=successor_id AND master_session_id=p_session AND authority_receipt_id=b.id AND payload=w.payload AND payload_sha256=w.payload_sha256 AND kind='narration' AND event_id=successor_event AND request_key=successor_key;
   RETURN jsonb_build_object('schema_version','mission-generic-staff-cached-publication/1','status','recovered','master_session_id',p_session,'work_id',successor_id,'replayed',true);
  END IF;
  IF w.state<>'failed' OR w.result->>'schema_version'<>'mission-count-overflow-failure/1' OR w.result->>'provider_calls'<>'0' OR w.result->>'outcome_uncertain'<>'false'
  OR w.result_sha256<>public.combat_v2_sha256(w.result) OR w.authorization_id IS NOT NULL OR w.dispatch_id IS NOT NULL OR w.message_id IS NOT NULL
  OR NOT  EXISTS(SELECT 1 FROM mission_generic_owner.unified_batches native_batch_check
 WHERE native_batch_check.id=w.authority_receipt_id AND native_batch_check.id='32e674f6-f1b8-4273-973e-7da88ed2c5b9'::uuid
 AND native_batch_check.master_session_id=w.master_session_id AND native_batch_check.writer_work_id=w.id AND native_batch_check.state='ready' AND native_batch_check.message_id IS NULL
 AND native_batch_check.composition_kind='combat_resolved_no_pending' AND native_batch_check.source_window_id IS NULL AND native_batch_check.next_round_id IS NULL
 AND native_batch_check.encounter_id='28af57fd-aaea-4036-8881-e3df39e23092'::uuid AND native_batch_check.run_control_version=4
 AND native_batch_check.source_report_id='5b5f46db-c1e2-4ad6-b0f1-dc9563e81eb0'::uuid AND native_batch_check.secondary_report_id='a5355e32-d780-490d-97fa-2767af05db7f'::uuid
 AND native_batch_check.source_round_id='f7e9fdaf-8681-4034-ab96-3e668a176956'::uuid
 AND native_batch_check.payload=w.payload AND native_batch_check.payload_sha256=w.payload_sha256 AND w.payload_sha256=public.combat_v2_sha256(w.payload)
 AND w.payload->>'schema_version'='mission-generic-narration/3' AND w.payload->>'mode'='unified'
 AND w.payload->>'composition_kind'=native_batch_check.composition_kind AND w.payload->>'batch_id'=native_batch_check.id::text
 AND w.payload->>'preparation_receipt_id'=native_batch_check.id::text AND w.payload->>'next_state_receipt_id'=native_batch_check.id::text
 AND w.payload->'publication_barrier'=jsonb_build_object('closed',true,'required_receipt_ids',jsonb_build_array(native_batch_check.id,native_batch_check.source_report_id,native_batch_check.secondary_report_id),'receipt_ids',jsonb_build_array(native_batch_check.id,native_batch_check.source_report_id,native_batch_check.secondary_report_id))
 AND public.combat_v2_sha256(w.payload#>'{resolved_scenes,0}')='8ffc1e7abc84f8db7da30e3af234ab6e574106464cb760fa4204891291af3f53' AND public.combat_v2_sha256(w.payload#>'{resolved_scenes,1}')='37de1843c7c1967d25a564e2cd682bc2e4baae20d996aac647365529e0ae06bb' AND jsonb_array_length(w.payload->'resolved_scenes')=2 AND w.payload->'pending_offensives'='[]'::jsonb AND w.payload->'source_windows'='[]'::jsonb
 AND NOT EXISTS(SELECT 1 FROM jsonb_array_elements(w.payload->'resolved_scenes') item
 WHERE NOT EXISTS(SELECT 1 FROM public.combat_v2_round_reports rp JOIN public.combat_v2_rounds cr ON cr.id=rp.round_id
 WHERE rp.id=CASE WHEN (item#>>'{scene_binding,report_sha256}')=(SELECT mechanics_sha256 FROM public.combat_v2_round_reports WHERE id=native_batch_check.source_report_id) THEN native_batch_check.source_report_id ELSE native_batch_check.secondary_report_id END
 AND item->>'schema_version'='mission-generic-narration/2' AND item->>'mode'='combat'
 AND item#>>'{scene_binding,session_id}'=native_batch_check.encounter_id::text AND item#>>'{scene_binding,control_version}'=native_batch_check.run_control_version::text
 AND item#>>'{scene_binding,round_id}'=cr.id::text AND item#>>'{scene_binding,report_sha256}'=rp.mechanics_sha256
 AND item#>>'{scene,snapshot_sha256}'=public.combat_v2_sha256(item#>'{scene,snapshot}')
 AND item#>>'{scene_binding,scene_sha256}'=item#>>'{scene,snapshot_sha256}'
 AND item->'barrier'=jsonb_build_object('closed',true,'required_receipt_ids',jsonb_build_array(rp.id),'receipt_ids',jsonb_build_array(rp.id))
 AND cr.session_id=native_batch_check.encounter_id AND cr.report_id=rp.id AND cr.state='risolto' AND cr.resolved_at IS NOT NULL
 AND rp.narration_state='attesa' AND rp.mechanics_sha256=public.combat_v2_sha256(rp.mechanics) AND rp.values_written IS FALSE))
 AND NOT EXISTS(SELECT 1 FROM mission_generic_owner.unified_report_publications pub WHERE pub.report_id IN(native_batch_check.source_report_id,native_batch_check.secondary_report_id))
 AND public.combat_v2_values_written(native_batch_check.encounter_id) IS FALSE AND combat_panel_private.uses_simulated_pools(native_batch_check.encounter_id) IS TRUE
 AND EXISTS(SELECT 1 FROM public.mission_run_state r WHERE r.master_session_id=w.master_session_id AND r.run_phase='in_corso' AND r.current_step_key=native_batch_check.step_key AND r.control_version=native_batch_check.run_control_version)
 )
  OR NOT EXISTS(SELECT 1 FROM mission_narrative_internal.dispatch_receipts d JOIN mission_narrative_internal.dispatch_audit a ON a.receipt_id=d.id AND a.event_code='generic_count_overflow_terminal'
   WHERE d.id=w.dispatch_receipt_id AND d.status='failed' AND d.dispatch_count=0 AND d.charged_cost_usd=0 AND d.finalized_at IS NOT NULL
   AND a.details->>'work_id'=w.id::text AND a.details->>'receipt_id'=w.receipt_id::text AND a.details->>'result_sha256'=w.result_sha256 AND a.details->>'payload_sha256'=w.payload_sha256)
  THEN RAISE EXCEPTION 'C889_RECOVERY_BINDING' USING ERRCODE='40001';END IF;
  INSERT INTO mission_generic_owner.work_items(id,master_session_id,event_id,request_key,dedupe_key,step_key,run_control_version,definition_sha256,encounter_id,authority_receipt_id,kind,revision,payload,payload_sha256)
  VALUES(successor_id,p_session,successor_event,successor_key,'c889-count-reissue:'||w.id::text,w.step_key,w.run_control_version,w.definition_sha256,w.encounter_id,b.id,'narration',w.revision,w.payload,w.payload_sha256) RETURNING * INTO successor;
  UPDATE mission_generic_owner.unified_batches SET writer_work_id=successor_id WHERE id=b.id AND writer_work_id=w.id;
  IF NOT FOUND THEN RAISE EXCEPTION 'C889_WRITER_CAS' USING ERRCODE='40001';END IF;
  INSERT INTO mission_narrative_internal.dispatch_audit(receipt_id,event_code,details) VALUES(w.dispatch_receipt_id,'c889_count_narration_reissued',jsonb_build_object('schema_version','c889-native-report-reissue/1','old_work_id',w.id,'work_id',successor_id,'batch_id',b.id,'payload_sha256',w.payload_sha256,'generation_http_calls',0));
  RETURN jsonb_build_object('schema_version','mission-generic-staff-cached-publication/1','status','recovered','master_session_id',p_session,'work_id',successor_id,'replayed',false);
 END IF;
  if p_session='ce7bc0e0-c8ed-48dd-a9ec-58c02022a7b9'::uuid
    and p_work='42341080-7f78-494e-9adf-85de7cfce038'::uuid and exists(
    select 1 from mission_generic_owner.work_items ow where ow.id=p_work and ow.master_session_id=p_session
      and ow.kind='narration' and ow.state='failed'
      and ow.result->>'schema_version'='mission-count-overflow-failure/1') then
    perform mission_generic_owner.dispatch_user(p_session,p_staff);
    if p_staff not in('f0856d53-83a6-4de0-bc0c-12c87916e665'::uuid,'b4952ed5-5ce0-49c0-9f2b-8fd5dcd89b4b'::uuid)
    or m.location_id<>'0b85f354-9cdb-47e1-baf9-3d266bb7e06b'::uuid or m.owner_kind<>'ai_service'
    or m.closed_at is not null or m.suspended_at is not null
    or not exists(select 1 from public.profiles where id=p_staff and role in('admin','master'))
    or mission_generic_owner.c726_factory_staff_runtime_v1(p_session) is distinct from true
    or mission_staff_abort_private.quiescent_v1(p_session) is distinct from true
    or (mission_generic_owner.c7_run_budget_v1(p_session,true,null)->>'allowed') is distinct from 'true'
    then raise exception 'MCR_COUNT_SCOPE' using errcode='42501';end if;
    perform 1 from mission_generic_owner.role_window_cursors where master_session_id=p_session for update;
    if not found then raise exception 'MCR_CURSOR_MISSING' using errcode='55000';end if;
    perform 1 from public.master_v2_sessions where id=p_session for update;
    select * into strict w from mission_generic_owner.work_items where id=p_work and master_session_id=p_session for update;
    if w.payload_sha256<>public.combat_v2_sha256(w.payload) or w.result_sha256<>public.combat_v2_sha256(w.result)
    or w.authorization_id is not null or w.dispatch_id is not null or w.message_id is not null
    or w.finalized_at is null or w.receipt_id is null or w.result->>'provider_calls'<>'0'
    or w.result->>'outcome_uncertain'<>'false' or w.result->>'failure_code'<>'MISSION_INPUT_COUNT_OVERFLOW'
    or not exists(select 1 from mission_narrative_internal.dispatch_receipts d
       join mission_narrative_internal.dispatch_audit a on a.receipt_id=d.id and a.event_code='generic_count_overflow_terminal'
       where d.id=w.dispatch_receipt_id and d.authority_receipt_id=w.id and d.master_session_id=p_session
        and d.status='failed' and d.dispatch_count=0 and d.finalized_at is not null and d.charged_cost_usd=0
        and a.details->>'work_id'=w.id::text and a.details->>'receipt_id'=w.receipt_id::text
        and a.details->>'payload_sha256'=w.payload_sha256 and a.details->>'result_sha256'=w.result_sha256
        and a.details->>'generation_http_calls'='0')
    then raise exception 'MCR_COUNT_PROOF' using errcode='40001';end if;
    select * into strict b from mission_generic_owner.unified_batches where id=w.authority_receipt_id and master_session_id=p_session for update;
    select * into strict source_row from mission_generic_owner.unified_source_windows where id=b.source_window_id and master_session_id=p_session for update;
    select * into strict run_row from public.mission_run_state where master_session_id=p_session for update;
    successor_id:=md5('C1264:NARRATION:work:'||w.id::text)::uuid;
    successor_event:=md5('C1264:NARRATION:event:'||w.id::text)::uuid;
    successor_key:=md5('C1264:NARRATION:request:'||w.id::text)::uuid;
    if b.state<>'ready' or b.message_id is not null or source_row.superseded_at is not null or source_row.consumed_message_id is not null
    or b.payload is distinct from w.payload or b.payload_sha256<>w.payload_sha256
    or b.step_key<>w.step_key or b.run_control_version<>w.run_control_version
    or run_row.current_step_key<>w.step_key or run_row.control_version<>w.run_control_version or run_row.run_phase<>'in_corso'
    or w.payload->>'source_revision' is distinct from mission_generic_owner.role_source_revision_v1(p_session)
    or w.payload#>>'{publication_barrier,closed}' is distinct from 'true'
    or w.payload#>'{publication_barrier,required_receipt_ids}' is distinct from w.payload#>'{publication_barrier,receipt_ids}'
    or (w.payload#>'{publication_barrier,receipt_ids}' @> jsonb_build_array(b.id)) is distinct from true
    or exists(select 1 from mission_generic_owner.unified_segment_publications_v4 where work_id=w.id)
    or not exists(select 1 from mission_generic_owner.work_items dw where dw.id=b.decision_work_id and dw.kind='director'
      and dw.state='completed' and dw.result->>'ok'='true' and dw.result->'decision'=b.decision
      and b.decision_sha256=public.combat_v2_sha256(b.decision) and source_row.work_id=dw.id
      and source_row.source_sha256=dw.payload_sha256 and source_row.definition_sha256=w.definition_sha256)
    then raise exception 'MCR_COUNT_SOURCE_CHANGED' using errcode='40001';end if;
    if b.writer_work_id=successor_id then
      select * into strict successor from mission_generic_owner.work_items where id=successor_id;
      if successor.master_session_id<>p_session or successor.authority_receipt_id<>b.id or successor.kind<>'narration'
      or successor.event_id<>successor_event or successor.request_key<>successor_key
      or successor.payload is distinct from w.payload or successor.payload_sha256<>w.payload_sha256
      then raise exception 'MCR_COUNT_REPLAY_CHANGED' using errcode='40001';end if;
      return jsonb_build_object('schema_version','mission-generic-staff-cached-publication/1','status','recovered','master_session_id',p_session,'work_id',successor.id,'replayed',true);
    end if;
    if b.writer_work_id<>w.id then raise exception 'MCR_COUNT_WRITER_CHANGED' using errcode='40001';end if;
    insert into mission_generic_owner.work_items(id,master_session_id,event_id,request_key,dedupe_key,step_key,run_control_version,definition_sha256,encounter_id,authority_receipt_id,kind,revision,payload,payload_sha256)
    values(successor_id,p_session,successor_event,successor_key,'count-narration-reissue:'||w.id::text,w.step_key,w.run_control_version,w.definition_sha256,w.encounter_id,b.id,'narration',w.revision,w.payload,w.payload_sha256) returning * into successor;
    update mission_generic_owner.unified_batches set writer_work_id=successor.id where id=b.id and writer_work_id=w.id;
    if not found then raise exception 'MCR_COUNT_WRITER_CAS' using errcode='40001';end if;
    insert into mission_narrative_internal.dispatch_audit(receipt_id,event_code,details) values(w.dispatch_receipt_id,'generic_count_narration_reissued',jsonb_build_object('schema_version','c1264-count-narration-reissue/1','old_work_id',w.id,'work_id',successor.id,'batch_id',b.id,'source_window_id',b.source_window_id,'payload_sha256',w.payload_sha256,'actor_user',p_staff,'generation_http_calls',0));
    return jsonb_build_object('schema_version','mission-generic-staff-cached-publication/1','status','recovered','master_session_id',p_session,'work_id',successor.id,'replayed',false);
  end if;

  factory_cached:=p_session='ce7bc0e0-c8ed-48dd-a9ec-58c02022a7b9'::uuid
   and p_work='86e5b361-9d82-aee8-a840-b09a83126fc0'::uuid
   and p_staff in('f0856d53-83a6-4de0-bc0c-12c87916e665'::uuid,'b4952ed5-5ce0-49c0-9f2b-8fd5dcd89b4b'::uuid)
   and mission_generic_owner.c726_factory_staff_runtime_v1(p_session) is true
   and (select count(*) from public.master_v2_participants where session_id=p_session and engagement_state='attivo' and left_at is null)=2
   and not exists(select 1 from public.master_v2_participants mp join public.characters ch on ch.id=mp.character_id
     where mp.session_id=p_session and mp.engagement_state='attivo' and mp.left_at is null
      and (ch.user_id is distinct from mp.user_id_snapshot or ch.user_id not in('f0856d53-83a6-4de0-bc0c-12c87916e665'::uuid,'b4952ed5-5ce0-49c0-9f2b-8fd5dcd89b4b'::uuid)))
   and exists(select 1 from mission_generic_owner.run_bindings rb where rb.master_session_id=p_session
     and rb.snapshot_sha256='49817335c60ce9d4b47bc5d81c6950f622635c7fb232264ab54736349124f567'
     and rb.snapshot_sha256=mission_internal.fingerprint(rb.snapshot));
  if factory_cached then perform mission_generic_owner.dispatch_user(p_session,p_staff);end if;
  if m.location_id is distinct from '0b85f354-9cdb-47e1-baf9-3d266bb7e06b'::uuid
    or m.owner_kind <> 'ai_service' or m.closed_at is not null
    or not (mission_academy_owner.staff_carrier_runtime(p_session) or factory_cached)
    or not mission_generic_owner.flow_scope_enabled(p_session)
    or not exists(select 1 from public.profiles where id=p_staff and role in ('admin','master'))
    or combat_consumer_private.staff_test_allowed(m.location_id,array[p_staff],false) is distinct from true
  then raise exception 'MCR_STAFF_SCOPE' using errcode='42501'; end if;

  perform 1 from mission_generic_owner.role_window_cursors
    where master_session_id=p_session for update;
  if not found then raise exception 'MCR_CURSOR_MISSING' using errcode='55000'; end if;
  perform 1 from public.master_v2_sessions where id=p_session for update;
  select * into strict w from mission_generic_owner.work_items
    where id=p_work and master_session_id=p_session for update;
  if w.state='completed' and w.message_id is not null and exists(
    select 1 from mission_generic_owner.unified_segment_publications_v4
    where work_id=w.id and message_id=w.message_id) then
    return jsonb_build_object('schema_version','mission-generic-staff-cached-publication/1',
      'status','published','message_id',w.message_id,'replayed',true);
  end if;
  if w.kind<>'narration' or w.payload->>'schema_version'<>'mission-generic-narration/4'
    or w.state<>'failed' or w.result->>'ok'<>'true'
    or w.result->>'provider_calls'<>'1' or w.result->>'outcome_uncertain'<>'false'
    or w.result_sha256 !~ '^[0-9a-f]{64}$' or w.message_id is not null
  then return jsonb_build_object('schema_version','mission-generic-staff-cached-publication/1',
    'status','not_applicable'); end if;
  select * into strict b from mission_generic_owner.unified_batches
    where id=w.authority_receipt_id and master_session_id=p_session and writer_work_id=w.id for update;
  select * into strict source_row from mission_generic_owner.unified_source_windows
    where id=b.source_window_id and master_session_id=p_session for update;
  select * into strict run_row from public.mission_run_state
    where master_session_id=p_session for update;
  select * into strict receipt from mission_narrative_internal.dispatch_receipts
    where id=w.dispatch_receipt_id for share;
  if b.state<>'ready' or b.message_id is not null
    or source_row.superseded_at is not null or source_row.consumed_message_id is not null
    or run_row.run_phase<>'in_corso' or run_row.current_step_key<>w.step_key
    or run_row.control_version<>w.run_control_version
    or w.payload->>'source_revision' is distinct from mission_generic_owner.role_source_revision_v1(p_session)
    or w.payload is distinct from b.payload or w.payload_sha256<>b.payload_sha256
    or w.result->>'work_id' is distinct from w.id::text
    or w.result->>'master_session_id' is distinct from p_session::text
    or w.result->>'request_key' is distinct from w.request_key::text
    or w.result->>'payload_sha256' is distinct from w.payload_sha256
    or receipt.status<>'success' or receipt.finalized_at is null
    or receipt.charged_cost_usd is null
    or exists(select 1 from mission_generic_owner.unified_segment_publications_v4
      where work_id=w.id)
  then raise exception 'MCR_SOURCE_CHANGED' using errcode='40001'; end if;

  if factory_cached and not exists(
   select 1 from mission_narrative_internal.dispatch_receipts nd
   join mission_narrative_internal.dispatch_audit ga on ga.receipt_id=nd.id and ga.event_code='generic_finalized'
   join mission_narrative_internal.dispatch_audit cp on cp.receipt_id=nd.id and cp.event_code='c8_count_success'
   join mission_narrative_internal.provider_authorizations pa on pa.id=w.authorization_id and pa.receipt_id=nd.id
   join mission_narrative_internal.dispatch_attempts na on na.receipt_id=nd.id and na.id=pa.attempt_id
   join staff_ai_quota_private.calls qc on qc.source_id=nd.id and qc.producer='mission_generic_ai' and qc.call_no=1
   where nd.id=w.dispatch_receipt_id and nd.authority_receipt_id=w.id and nd.master_session_id=p_session
    and nd.request_key=w.request_key and nd.status='success' and nd.dispatch_count=1 and nd.finalized_at is not null
    and nd.charged_cost_usd is not null and nd.lease_token_sha256 is null and nd.lease_expires_at is null
    and na.status='success' and na.finalized_at is not null and na.cost_basis='exact'
    and na.actual_cost_usd=nd.charged_cost_usd and qc.scope_id=p_session and qc.state='settled' and qc.charged_usd=nd.charged_cost_usd
    and ga.details->>'work_id'=w.id::text and ga.details->>'receipt_id'=w.receipt_id::text
    and ga.details->>'state'='failed' and ga.details->>'outcome_uncertain'='false'
    and ga.details->>'application_error_sqlstate'='42703'
    and ga.details->>'result_sha256'=w.result_sha256
    and ga.details->>'result_jsonb_sha256'=public.combat_v2_sha256(w.result)
    and cp.details->>'work_id'=w.id::text and cp.details->>'state'='success'
    and cp.details->>'generation_allowed'='true' and cp.details->>'input_tokens'='10066'
    and cp.details->>'max_input_tokens'='12000'
    and w.authority_receipt_id='08512119-3bfd-4df7-adbc-0686f5edf5b7'::uuid
    and w.definition_sha256='49817335c60ce9d4b47bc5d81c6950f622635c7fb232264ab54736349124f567'
    and w.result->>'schema_version'='mission-generic-result/2' and jsonb_typeof(w.result->'segments')='array'
    and w.result->'text'='null'::jsonb
    and not exists(select 1 from mission_generic_owner.work_items other where other.master_session_id=p_session and other.state in('claimed','authorized','provider_started','uncertain'))
    and not exists(select 1 from mission_narrative_internal.dispatch_attempts pending join mission_narrative_internal.dispatch_receipts pd on pd.id=pending.receipt_id where pd.master_session_id=p_session and pending.finalized_at is null)
  ) then raise exception 'MCR_FACTORY_CACHED_RECEIPT' using errcode='40001';end if;
  perform mission_generic_owner.work_assert(w);

  begin
    update mission_generic_owner.work_items set state='provider_started',finalized_at=null
      where id=w.id and state='failed';
    result_row:=mission_generic_owner.unified_publish_v4(
      w.id,w.result,w.request_key,w.result_sha256);
    message_ref:=(result_row->>'message_id')::uuid;
    if message_ref is null then raise exception 'MCR_PUBLICATION_MISSING'; end if;
    update mission_generic_owner.work_items
      set state='completed',finalized_at=clock_timestamp(),message_id=message_ref,
        result=result||jsonb_build_object('text',result_row->>'text','continuity',result_row->'continuity'),
        result_sha256=public.combat_v2_sha256(result||jsonb_build_object(
          'text',result_row->>'text','continuity',result_row->'continuity'))
      where id=w.id and state='provider_started';
    if not found then raise exception 'MCR_WORK_CAS'; end if;
  exception when others then
    get stacked diagnostics error_state=returned_sqlstate,error_message=message_text,
      error_constraint=constraint_name,error_table=table_name,error_schema=schema_name,
      diagnostic_column=column_name,diagnostic_context=pg_exception_context,native_selection_detail=pg_exception_detail;
    IF error_state='55000' AND error_message='MRS_V4_NO_LEGAL_NATIVE_ATTACK' AND octet_length(native_selection_detail)<=8192 THEN
      BEGIN
        native_selection_diagnostic:=native_selection_detail::jsonb;
        IF mission_factory_owner.keys_exact_v2(native_selection_diagnostic,ARRAY['schema_version','actor_key','round_phase','counts','producer_counts','producer_called']) IS DISTINCT FROM true
          OR native_selection_diagnostic->>'schema_version' IS DISTINCT FROM 'mission-native-attack-selection-diagnostic/2'
          OR coalesce(native_selection_diagnostic->>'actor_key','')!~'^[a-z][a-z0-9_]{0,63}$'
          OR coalesce(native_selection_diagnostic->>'round_phase','') NOT IN('raccolta_azioni','raccolta_difese','risoluzione','risolto','narrazione','narrato','other')
          OR mission_factory_owner.keys_exact_v2(native_selection_diagnostic->'counts',ARRAY['actor_offers','principal_match','offered','action','master_adapter','action_dispatch','attack','mano','in_projection','no_required_inputs','supported_groups','candidate_count','shape_rejected','pg_target_count','multiple_move_groups','move_shape_rejected','move_option_missing','extra_dependency_rejected']) IS DISTINCT FROM true
          OR jsonb_typeof(native_selection_diagnostic->'producer_called') IS DISTINCT FROM 'boolean'
          OR mission_factory_owner.keys_exact_v2(native_selection_diagnostic->'producer_counts',ARRAY['targets_total','targets_seen','mano_seen','geometry_stay','endpoint_count','pending_count','rejected_geometry','label_present','legal_total','action_entered']) IS DISTINCT FROM true
          OR EXISTS(SELECT 1 FROM jsonb_each(native_selection_diagnostic->'producer_counts') x WHERE jsonb_typeof(x.value) IS DISTINCT FROM 'number' OR (x.value#>>'{}')!~'^[0-9]{1,6}$')
          OR EXISTS(SELECT 1 FROM jsonb_each(native_selection_diagnostic->'counts') x WHERE jsonb_typeof(x.value) IS DISTINCT FROM 'number' OR (x.value#>>'{}')!~'^[0-9]{1,6}$')
        THEN native_selection_diagnostic:=NULL;END IF;
      EXCEPTION WHEN invalid_text_representation OR invalid_parameter_value THEN native_selection_diagnostic:=NULL;END;
    END IF;
    if factory_cached then
      if diagnostic_column !~ '^[A-Za-z_][A-Za-z0-9_]{0,62}$' then diagnostic_column:=null;end if;
      if diagnostic_column is null and error_state='42703' then
        diagnostic_column:=coalesce(
          substring(error_message from '^column "([A-Za-z_][A-Za-z0-9_]{0,62})" does not exist$'),
          substring(error_message from '^record "[A-Za-z_][A-Za-z0-9_]{0,62}" has no field "([A-Za-z_][A-Za-z0-9_]{0,62})"$'),
          substring(error_message from '^column [A-Za-z_][A-Za-z0-9_]{0,62}\.([A-Za-z_][A-Za-z0-9_]{0,62}) does not exist$'));
      end if;
      if error_table !~ '^[A-Za-z_][A-Za-z0-9_]{0,62}$' then error_table:=null;end if;
      if error_schema !~ '^[A-Za-z_][A-Za-z0-9_]{0,62}$' then error_schema:=null;end if;
      select coalesce(jsonb_agg(jsonb_build_object('function',parts[1],'line',parts[2]::integer) order by ordinal),'[]'::jsonb) into diagnostic_frames
        from (select parts,ordinal from regexp_matches(diagnostic_context,'PL/pgSQL function ([A-Za-z_][A-Za-z0-9_.]*)\([^)]*\) line ([0-9]{1,6})','g') with ordinality f(parts,ordinal) limit 8) frames;
    end if;
    safe_code:=case when error_message ~ '^[A-Z][A-Z0-9_]{1,79}$'
      then error_message else 'SQLSTATE_'||error_state end;
  end;
  if safe_code is not null then
    insert into mission_narrative_internal.dispatch_audit(receipt_id,event_code,details)
      values(receipt.id,'staff_cached_publication_rejected',jsonb_build_object(
        'work_id',w.id,'master_session_id',p_session,
        'sqlstate',error_state,'error_code',safe_code,
        'constraint_name',nullif(error_constraint,''),
        'table_name',nullif(error_table,''),
        'schema_name',nullif(error_schema,'')) || CASE WHEN native_selection_diagnostic IS NOT NULL THEN jsonb_build_object('private_native_attack_selection',native_selection_diagnostic) ELSE '{}'::jsonb END || case when factory_cached then jsonb_build_object('private_diagnostics',jsonb_build_object('schema_version','c1264-cached-private-error/1','column',diagnostic_column,'table',error_table,'schema',error_schema,'frames',diagnostic_frames)) else '{}'::jsonb end);
    return jsonb_build_object('schema_version','mission-generic-staff-cached-publication/1',
      'status','failed','error_code',safe_code);
  end if;
  insert into mission_narrative_internal.dispatch_audit(receipt_id,event_code,details)
    values(receipt.id,'staff_cached_publication_completed',jsonb_build_object(
      'work_id',w.id,'master_session_id',p_session,'message_id',message_ref));
  return jsonb_build_object('schema_version','mission-generic-staff-cached-publication/1',
    'status','published','message_id',message_ref,'replayed',false);
end
$function$;

CREATE OR REPLACE FUNCTION public.mission_generic_room_state_v1(p_location uuid)
 RETURNS jsonb
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO ''
AS $function$
declare scene56 mission_narrative_internal.scene_runtime_v1;surface56 jsonb;public56 jsonb;event56 jsonb;caps56 jsonb;
 uid uuid:=auth.uid();m public.master_v2_sessions;r public.mission_run_state;vchoices jsonb;
 staff boolean;participant boolean;objective text;active boolean; uf_work mission_generic_owner.work_items;uf_processing jsonb;uf_rounds jsonb;uf_progress_key text;uf_state text;uf_marker jsonb;uf_review boolean;
 academy boolean;flow_state text;flow_publication uuid;role_diag jsonb;
 private_source_step text;private_pending boolean:=false;combat_recovery jsonb;
 staff_tick_view jsonb:=NULL;st_revision text;st_tick mission_generic_owner.staff_progress_ticks_v1;st_receipt mission_generic_owner.progress_receipts;
 st_work record;st_source record;st_dispatch jsonb;st_next_key uuid;st_original_key uuid;st_owner boolean:=false;
 st_valid boolean:=false;st_released boolean:=false;st_blocked boolean:=false;st_resume boolean:=false;
 st_ack_predecessor uuid:=NULL;st_candidate_predecessor uuid:=NULL;
 st_depth integer:=0;st_state text;st_public_state text;st_recovery uuid;st_effective_id uuid;
 st_budget_a mission_generic_owner.dispatch_admissions;st_budget_g mission_generic_owner.provider_policy;st_budget_p record;
 mb_read_recovery boolean:=false;mb_mode boolean:=false; st_spent numeric;st_http bigint;st_bound numeric;st_cap_cost numeric;st_cap_http integer;st_budget_ok boolean:=false;
 opening_resume49 jsonb:=NULL;opening_claim_resume6 jsonb:=NULL;
 journal_settlements jsonb:=NULL;
 retained_handoff jsonb:=NULL;retained_row record;
 c26_count_view jsonb:=NULL;c26_driver jsonb:=NULL;c26_proof jsonb;c26_kind text;c26_revision text;c26_phase_kind text;
  nw_original_sha text;nw_original_key uuid;nw_mode boolean:=false;
 budget1_effective numeric;budget1_policy numeric;
 s40_terminal_proof jsonb;
  quest_staff_v9_kind text;quest_staff_v9_work uuid;
 role_command_capability jsonb:=NULL;role_command_enabled boolean:=false;event42_mode boolean:=false;quest_command_scope boolean:=false;
begin
 if uid is null then raise exception 'authentication_required' using errcode='28000';end if;
 staff:=exists(select 1 from public.profiles where id=uid and role in('admin','master'));
 select s.* into m from public.master_v2_sessions s join mission_generic_owner.run_bindings b on b.master_session_id=s.id
 where s.location_id=p_location and s.closed_at is null and s.owner_kind='ai_service'
 and (staff or exists(select 1 from public.master_v2_participants p join public.characters c on c.id=p.character_id and c.user_id=uid
  where p.session_id=s.id and p.user_id_snapshot=uid and p.left_at is null)) order by s.created_at desc limit 1;
 if m.id is null then return null;end if;
 -- A read of sealed final history remains available under runtime off; never starts work.
 SELECT * INTO scene56 FROM mission_narrative_internal.scene_runtime_v1 WHERE master_session_id=m.id AND is_active;
 IF scene56.id IS NOT NULL AND scene56.mode='closed' AND scene56.turn_owner='closed' THEN
  s40_terminal_proof:=mission_narrative_internal.scene_finish_proof_v1(m.id,uid);
  IF s40_terminal_proof->>'schema_version'='mission-narrative-scene-finish-proof/2'
   AND s40_terminal_proof->'can_finish'='true'::jsonb THEN
   RETURN jsonb_build_object('session_id',m.id,'step_key',scene56.current_phase_key,
    'objective',(SELECT phase40->>'objective' FROM jsonb_array_elements(scene56.snapshot->'phases')phase40 WHERE phase40->>'phase_key'=scene56.current_phase_key),
    'narrative_scene',jsonb_build_object('schema_version','mission-narrative-scene-public/2','scene_id',scene56.id,'state_version',scene56.state_version,
     'mode','closed','last_publication_id',scene56.last_publication_id,'execution_context',CASE WHEN s40_terminal_proof->>'execution_context'='ordinary_mission' THEN 'world' ELSE 'staff_simulation' END,
     'participant_commands',jsonb_build_object('role',false,'combat',false,'peaceful',false),'completion_mode','server'),
    'role_submit_capability',jsonb_build_object('schema_version','mission-role-submit-capability/2','enabled',false,'contexts','[]'::jsonb),
    'server_event_mode','server_event_v1','server_event_status',jsonb_build_object('event_key',s40_terminal_proof->>'final_work_id','event_version',scene56.state_version,'state','pending','can_recover',true),
    'combat_surface',NULL,'staff_finish',NULL);
  END IF;
 END IF;
 perform mission_generic_owner.assert_runtime(m.id);
 select * into strict r from public.mission_run_state where master_session_id=m.id;
 SELECT * INTO scene56 FROM mission_narrative_internal.scene_runtime_v1 WHERE master_session_id=m.id AND is_active;

 IF FOUND AND ((mission_generic_owner.manual_staff_scope_v1(m.id)->'source_scope')=(SELECT rr87.canonical_preimage::jsonb#>'{config,c1266_manual_template,source_scope}' FROM mission_factory_owner.editor_release_readiness rr87 WHERE rr87.singleton) OR EXISTS(SELECT 1 FROM mission_public_owner.session_admissions_v1 s87_ad WHERE s87_ad.master_session_id=m.id AND mission_public_owner.c1266_regia_public_qualification_v1(s87_ad.mission_id,s87_ad.release_sha256,false)->>'schema_version'='mission-scene-public-qualification/1' AND mission_public_owner.launch_provenance_v1(s87_ad.master_session_id) IS NOT NULL)) THEN
  DECLARE s87_entitled boolean;s87_pending boolean;s87_combat boolean;s87_role boolean;s87_proof jsonb;s87_world boolean;s87_active boolean;s87_peaceful boolean:=false;
  BEGIN
   s87_world:=EXISTS(SELECT 1 FROM mission_public_owner.session_admissions_v1 a87 WHERE a87.master_session_id=m.id AND a87.mode='ai');
   s87_entitled:=EXISTS(SELECT 1 FROM public.master_v2_participants p87 JOIN public.characters c87 ON c87.id=p87.character_id AND c87.user_id=uid
    WHERE p87.session_id=m.id AND p87.user_id_snapshot=uid AND p87.engagement_state='attivo' AND p87.left_at IS NULL);
   s87_pending:=EXISTS(SELECT 1 FROM mission_generic_owner.work_items w87 WHERE w87.master_session_id=m.id AND w87.state NOT IN('completed','failed'));
   surface56:=mission_narrative_internal.scene_entry_surface_v1(m.id,uid);
   s87_active:=CASE WHEN s87_world THEN mission_public_owner.role_session_allowed_v1(m.id) ELSE EXISTS(SELECT 1 FROM mission_factory_owner.editor_release_readiness rr87 WHERE rr87.singleton AND rr87.state='enabled' AND rr87.staff_guards_verified AND rr87.published_assets_verified) END;
   surface56:=jsonb_set(surface56,'{can_prepare}',to_jsonb(coalesce(surface56->'can_prepare'='true'::jsonb AND s87_active,false)));
   s87_role:=s87_entitled AND s87_active AND scene56.mode='narrative' AND scene56.turn_owner='players' AND NOT s87_pending;
   s87_combat:=s87_entitled AND s87_active AND NOT s87_pending AND (surface56->'can_prepare'='true'::jsonb OR (scene56.mode='combat' AND scene56.turn_owner='combat' AND surface56->'map_operational'='true'::jsonb));
s87_peaceful:=s87_entitled AND s87_active AND NOT s87_pending AND scene56.mode='combat' AND scene56.turn_owner='combat'
 AND m.closed_at IS NULL AND m.suspended_at IS NULL AND EXISTS(
 WITH live87 AS(
  SELECT cr87.*,cs87.id AS combat_id,en87.actor_map,en87.encounter_key,en87.step_key
  FROM public.combat_v2_sessions cs87 JOIN mission_generic_owner.encounters en87 ON en87.encounter_id=cs87.id AND en87.master_session_id=m.id
  JOIN public.combat_v2_rounds cr87 ON cr87.session_id=cs87.id
  WHERE cs87.master_session_id=m.id AND cs87.location_id=m.location_id AND cs87.closed_at IS NULL AND cs87.state NOT IN('chiuso','risolto')
   AND combat_panel_private.uses_simulated_pools(cs87.id) IS NOT DISTINCT FROM NOT s87_world
   AND (s87_world OR NOT public.combat_v2_values_written(cs87.id))
   AND scene56.current_phase_key=r.current_step_key AND (en87.step_key,en87.run_control_version) IS NOT DISTINCT FROM(r.current_step_key,r.control_version)
   AND cr87.phase='raccolta_azioni' AND cr87.state='raccolta_azioni'
   AND NOT EXISTS(SELECT 1 FROM public.combat_v2_rounds later87 WHERE later87.session_id=cs87.id AND later87.round_no>cr87.round_no)
   AND NOT EXISTS(SELECT 1 FROM public.combat_v2_declarations d87 WHERE d87.round_id=cr87.id)
   AND NOT EXISTS(SELECT 1 FROM public.combat_v2_attack_targets t87 WHERE t87.round_id=cr87.id)
 ), previous87 AS(
  SELECT live87.*,pr87.id AS previous_id,rep87.id AS report_id
  FROM live87 JOIN public.combat_v2_rounds pr87 ON pr87.session_id=live87.combat_id AND pr87.round_no=live87.round_no-1
  JOIN public.combat_v2_round_reports rep87 ON rep87.id=pr87.report_id AND rep87.round_id=pr87.id
  WHERE pr87.state='narrato' AND rep87.narration_state='pubblicata' AND rep87.message_id IS NOT NULL
   AND (s87_world OR NOT rep87.values_written) AND rep87.mechanics_sha256=public.combat_v2_sha256(rep87.mechanics)
   AND scene56.last_publication_id=rep87.message_id AND mission_narrative_internal.scene_native_round_bound_v1(m.id,pr87.id)
   AND NOT EXISTS(SELECT 1 FROM public.combat_v2_attack_targets t87 WHERE t87.round_id=pr87.id)
   AND NOT EXISTS(SELECT 1 FROM public.combat_v2_declarations d87 WHERE d87.round_id=pr87.id AND d87.kind IN('attacco','difesa'))
 )
 SELECT 1 FROM previous87 pe87
 WHERE (SELECT count(*) FROM public.combat_v2_actors pa87 WHERE pa87.session_id=pe87.combat_id AND pa87.actor_kind='pg' AND pa87.state='attivo')>0
 AND (SELECT count(*) FROM public.combat_v2_actors pa87 WHERE pa87.session_id=pe87.combat_id AND pa87.actor_kind='pg' AND pa87.state='attivo')=
  (SELECT count(DISTINCT pa87.id) FROM public.combat_v2_declarations pd87 JOIN public.combat_v2_actors pa87 ON pa87.id=pd87.actor_id
   JOIN combat_consumer_private.declaration_messages dm87 ON dm87.declaration_id=pd87.id
   JOIN public.messages pm87 ON pm87.id=dm87.message_id
   JOIN combat_panel_private.request_receipts pq87 ON pq87.principal_user=pa87.controller_user AND pq87.request_key=pd87.request_key AND pq87.viewer_envelope#>>'{receipt,declaration_id}'=pd87.id::text
   WHERE pd87.round_id=pe87.previous_id AND pa87.session_id=pe87.combat_id AND pa87.actor_kind='pg' AND pa87.state='attivo'
    AND pd87.kind IN('passa','utilita','movimento') AND pd87.state='risolta'
    AND pd87.controller_version_snapshot=pa87.controller_version AND pd87.controller_user_snapshot=pa87.controller_user
    AND pm87.location_id=m.location_id AND pm87.character_id=pa87.character_id AND pm87.recipient_user IS NULL
    AND (pm87.sender_user=pa87.controller_user OR pm87.sender_user IS NULL)
    AND pm87.body=pd87.declaration_text AND nullif(btrim(pm87.body),'') IS NOT NULL AND dm87.message_sha256=public._combat_narrative_sha(pm87.id))
 AND (SELECT count(*) FROM public.combat_v2_actors na87 WHERE na87.session_id=pe87.combat_id AND na87.actor_kind='png' AND na87.state='attivo')=
  (SELECT count(*) FROM public.combat_v2_actors na87 JOIN LATERAL jsonb_array_elements(pe87.actor_map) nm87 ON nm87->>'actor_id'=na87.id::text
   JOIN LATERAL jsonb_array_elements(scene56.snapshot->'npcs') np87 ON np87->>'actor_key'=nm87->>'actor_key'
   WHERE na87.session_id=pe87.combat_id AND na87.actor_kind='png' AND na87.state='attivo')
 AND (SELECT count(*) FROM jsonb_array_elements(mission_generic_owner.scene(m.id,pe87.step_key)->'triggers') tr87
   WHERE tr87->>'source_kind'='combat_terminal' AND tr87->>'encounter_key'=pe87.encounter_key AND tr87->>'combat_outcome'='peaceful')=1
 AND (SELECT count(*) FROM jsonb_array_elements(mission_generic_owner.scene(m.id,pe87.step_key)->'triggers') tr87
   JOIN public.mission_plan_transitions mt87 ON mt87.plan_version_id=r.plan_version_id AND mt87.from_step_key=r.current_step_key AND mt87.transition_key=tr87->>'transition_key'
   WHERE tr87->>'source_kind'='combat_terminal' AND tr87->>'encounter_key'=pe87.encounter_key AND tr87->>'combat_outcome'='peaceful'
    AND EXISTS(SELECT 1 FROM jsonb_array_elements(scene56.snapshot->'phases') ph87 WHERE ph87->>'phase_key'=scene56.current_phase_key AND ph87->'next_steps'?('scene:'||mt87.to_step_key)))=1
 );

   SELECT jsonb_build_object('schema_version','mission-role-submit-capability/2','enabled',coalesce(s87_role,false),
    'contexts',coalesce(jsonb_agg(jsonb_build_object('character_id',p87.character_id,'window_epoch',cur87.window_epoch,
      'own_latest_message_id',(SELECT rs87.message_id FROM mission_generic_owner.role_submissions rs87 WHERE rs87.master_session_id=m.id AND rs87.window_epoch=cur87.window_epoch AND rs87.user_id=uid AND rs87.character_id=p87.character_id ORDER BY rs87.accepted_at DESC,rs87.message_id DESC LIMIT 1)) ORDER BY p87.character_id),'[]'::jsonb))
    INTO caps56 FROM public.master_v2_participants p87 JOIN public.characters c87 ON c87.id=p87.character_id AND c87.user_id=uid
    JOIN mission_generic_owner.role_window_cursors cur87 ON cur87.master_session_id=p87.session_id
    WHERE p87.session_id=m.id AND p87.user_id_snapshot=uid AND p87.left_at IS NULL AND p87.engagement_state='attivo';
   public56:=jsonb_build_object('schema_version','mission-narrative-scene-public/2','scene_id',scene56.id,'state_version',scene56.state_version,'mode',scene56.mode,'last_publication_id',scene56.last_publication_id,
    'execution_context',CASE WHEN s87_world THEN 'world' ELSE 'staff_simulation' END,
    'participant_commands',jsonb_build_object('role',coalesce(s87_role,false),'combat',coalesce(s87_combat,false),'peaceful',coalesce(s87_peaceful,false)),
    'completion_mode','server');
   SELECT jsonb_build_object('event_key',es87.event_key,'event_version',es87.event_version,'state',es87.state,'can_recover',s87_entitled AND es87.root_principal=uid AND scene56.mode<>'closed' AND (es87.state<>'running' OR es87.claim_expires_at<=clock_timestamp()) AND (w87.state='ready' AND w87.lease_id IS NULL OR (
      NOT s87_world AND s87_entitled AND public.is_staff()
      AND m.location_id='0b85f354-9cdb-47e1-baf9-3d266bb7e06b'::uuid
      AND EXISTS(SELECT 1 FROM public.locations sr10_location WHERE sr10_location.id=m.location_id AND sr10_location.is_active AND sr10_location.is_test)
      AND w87.state='claimed' AND w87.lease_expires_at<=clock_timestamp()
      AND w87.authorization_id IS NULL AND w87.dispatch_id IS NULL AND w87.result IS NULL AND w87.receipt_id IS NULL
      AND (NOT EXISTS(SELECT 1 FROM mission_narrative_internal.dispatch_audit sr10_audit WHERE sr10_audit.receipt_id=w87.dispatch_receipt_id AND sr10_audit.event_code='c8_count_started') OR (EXISTS(SELECT 1 FROM mission_narrative_internal.dispatch_audit cache14_pf WHERE cache14_pf.receipt_id=w87.dispatch_receipt_id
 AND cache14_pf.event_code='c8_count_success'AND cache14_pf.details->'generation_allowed'='true'::jsonb
 AND cache14_pf.details->'count_http_calls'='1'::jsonb AND cache14_pf.details->'generation_http_calls'='0'::jsonb)
 AND w87.kind='narration'AND w87.payload->>'schema_version'='mission-narrative-scene/1'
 AND(mission_public_owner.work_contract_v1(w87.id))->>'schema_version'='mission-narrative-admission/4'
 AND(mission_public_owner.work_contract_v1(w87.id))->>'scope'='staff_mission'
 AND (SELECT count(*) FROM mission_narrative_internal.dispatch_audit cache14_h WHERE cache14_h.receipt_id=w87.dispatch_receipt_id AND cache14_h.event_code='manual_counted_resume_v1')<2))
      AND NOT EXISTS(SELECT 1 FROM mission_narrative_internal.provider_authorizations sr10_auth WHERE sr10_auth.receipt_id=w87.dispatch_receipt_id)
      AND NOT EXISTS(SELECT 1 FROM mission_narrative_internal.dispatch_attempts sr10_attempt WHERE sr10_attempt.receipt_id=w87.dispatch_receipt_id)))) INTO event56
    FROM mission_generic_owner.event_outbox_v1 es87 JOIN mission_generic_owner.work_items w87 ON w87.id=es87.work_id
    WHERE es87.master_session_id=m.id AND w87.state NOT IN('completed','failed')
     AND es87.state IN('pending','running','uncertain') ORDER BY es87.created_at DESC,es87.event_version DESC LIMIT 1;
   -- Exact Staff noWork recovery: normal event recovery RPC owns claim/work selection.
   IF event56 IS NULL AND NOT s87_world AND s87_entitled AND public.is_staff()
    AND m.location_id='0b85f354-9cdb-47e1-baf9-3d266bb7e06b'::uuid
    AND EXISTS(SELECT 1 FROM public.locations sr8_location WHERE sr8_location.id=m.location_id AND sr8_location.is_active AND sr8_location.is_test)
   THEN
    SELECT jsonb_build_object('event_key',sr8_event.event_key,'event_version',sr8_event.event_version,'state',sr8_event.state,
     'can_recover',sr8_event.root_principal=uid AND scene56.mode<>'closed'
      AND(sr8_event.state<>'running'OR sr8_event.claim_expires_at<=clock_timestamp()))INTO event56
    FROM mission_generic_owner.event_outbox_v1 sr8_event
    WHERE sr8_event.master_session_id=m.id AND sr8_event.work_id IS NULL AND sr8_event.root_principal=uid
     AND sr8_event.state IN('pending','running','uncertain')
    ORDER BY sr8_event.created_at DESC,sr8_event.event_version DESC LIMIT 1;
   END IF;
   -- Terminal recovery is projected once, before ACTIVE/runtime gates.
   RETURN jsonb_build_object('session_id',m.id,'step_key',scene56.current_phase_key,
    'objective',(SELECT x87->>'objective' FROM jsonb_array_elements(scene56.snapshot->'phases')x87 WHERE x87->>'phase_key'=scene56.current_phase_key),
    'narrative_scene',public56,'role_submit_capability',caps56,'server_event_mode','server_event_v1','server_event_status',event56,'combat_surface',surface56,'staff_finish',NULL);
  END;
 END IF;
 IF FOUND THEN
  public56:=jsonb_build_object('schema_version','mission-narrative-scene-public/1','scene_id',scene56.id,
   'state_version',scene56.state_version,'mode',scene56.mode,'last_publication_id',scene56.last_publication_id);
  surface56:=mission_narrative_internal.scene_entry_surface_v1(m.id,uid);
  IF scene56.mode<>'combat' THEN
   SELECT proof.x INTO combat_recovery FROM mission_generic_owner.work_items cw
    CROSS JOIN LATERAL(SELECT mission_generic_owner.native_combat_writer_reissue_proof_v1(cw.id,uid) x) proof
    WHERE cw.master_session_id=m.id AND cw.kind='narration' AND cw.state='failed' AND proof.x IS NOT NULL
    ORDER BY cw.created_at DESC,cw.id DESC LIMIT 1;
   IF combat_recovery IS NOT NULL THEN combat_recovery:=jsonb_build_object('schema_version','mission-combat-narration-recovery/2','master_session_id',m.id,'failed_work_id',combat_recovery->'failed_work_id','authority_receipt_id',combat_recovery->'authority_receipt_id','report_id',combat_recovery->'report_id','payload_sha256',combat_recovery->'payload_sha256','owned_by_me',combat_recovery->'owned_by_me','can_reissue',combat_recovery->'can_reissue','successor_work_id',combat_recovery->'successor_work_id','successor_request',combat_recovery->'successor_request','can_resume',false,'successor_publication_id',combat_recovery->'successor_publication_id');END IF;
   SELECT jsonb_build_object('schema_version','mission-role-submit-capability/2',
    'enabled',scene56.mode='narrative' AND scene56.turn_owner='players',
    'contexts',coalesce(jsonb_agg(jsonb_build_object('character_id',p.character_id,'window_epoch',cur.window_epoch,
     'own_latest_message_id',(SELECT rs.message_id FROM mission_generic_owner.role_submissions rs
      WHERE rs.master_session_id=m.id AND rs.window_epoch=cur.window_epoch AND rs.user_id=uid
       AND rs.character_id=p.character_id ORDER BY rs.accepted_at DESC,rs.message_id DESC LIMIT 1)) ORDER BY p.character_id),'[]'::jsonb))
   INTO caps56 FROM public.master_v2_participants p JOIN public.characters ch ON ch.id=p.character_id AND ch.user_id=uid
   JOIN mission_generic_owner.role_window_cursors cur ON cur.master_session_id=p.session_id
   WHERE p.session_id=m.id AND p.user_id_snapshot=uid AND p.left_at IS NULL AND p.engagement_state='attivo';
   SELECT jsonb_build_object('event_key',es.event_key,'event_version',es.event_version,'state',es.state,
    'can_recover',es.root_principal=uid AND scene56.mode<>'closed'
     AND (es.state<>'running' OR es.claim_expires_at<=clock_timestamp())
     AND (es.work_id IS NULL OR EXISTS(SELECT 1 FROM mission_generic_owner.work_items ew
      WHERE ew.id=es.work_id AND ew.state='ready' AND ew.lease_id IS NULL)
      OR (es.state='uncertain' AND mission_generic_owner.staff_paid_scene_recovery_allowed_v1(m.id,es.work_id,uid) IS TRUE))) INTO event56
   FROM mission_generic_owner.event_outbox_v1 es WHERE es.master_session_id=m.id
   ORDER BY es.created_at DESC,es.event_key DESC,es.event_version DESC LIMIT 1;
   RETURN jsonb_build_object('session_id',m.id,'step_key',scene56.current_phase_key,
    'objective',(SELECT x->>'objective' FROM jsonb_array_elements(scene56.snapshot->'phases')x WHERE x->>'phase_key'=scene56.current_phase_key),
    'narrative_scene',public56,'role_submit_capability',caps56,'server_event_mode','server_event_v1',
    'server_event_status',event56,'combat_surface',surface56,'staff_finish',mission_generic_owner.staff_finish_status_v1(m.id,uid))
    ||CASE WHEN combat_recovery IS NULL THEN '{}'::jsonb ELSE jsonb_build_object('combat_narration_recovery',combat_recovery) END;
  END IF;
 END IF;
 select sw.step_key into private_source_step from mission_generic_owner.unified_batches pending_batch
 join mission_generic_owner.unified_source_windows sw on sw.id=pending_batch.source_window_id
 where pending_batch.master_session_id=m.id AND pending_batch.composition_kind='entry_png'
   AND pending_batch.state IN('preparing','ready') AND pending_batch.retired_at IS NULL AND pending_batch.message_id IS NULL
   AND pending_batch.encounter_id IS NOT NULL
 order by pending_batch.created_at desc,pending_batch.id desc limit 1;
 private_pending:=private_source_step IS NOT NULL;
 participant:=exists(select 1 from public.master_v2_participants p join public.characters c on c.id=p.character_id and c.user_id=uid
 where p.session_id=m.id and p.user_id_snapshot=uid and p.left_at is null);
 event42_mode:=EXISTS(SELECT 1 FROM mission_generic_owner.event_outbox_v1 mode42 WHERE mode42.master_session_id=m.id AND mode42.event_domain='start');
 -- Quest uses its own native source (mission_id is NULL). No private context is emitted.
 academy:=mission_creation_owner.director_context(m.id,r.current_step_key) is not null
 or exists(select 1 from mission_factory_owner.quest_run_sources qs
   join public.mission_plan_versions pv on pv.id=qs.plan_version_id
   join public.mission_plans qp on qp.id=pv.plan_id
   join mission_generic_owner.run_bindings qb on qb.master_session_id=qs.session_id
   join mission_generic_owner.definitions qd on qd.id=qb.definition_id
   join public.locations ql on ql.id=qs.location_id
   where qs.session_id=m.id and qs.state in('prepared','opening_pending','uncertain','started')
    and m.mission_id is null and m.tipo='quest' and qs.location_id=m.location_id
    and qs.plan_version_id=r.plan_version_id and qp.source_kind='quest'
    and qp.quest_episode_id=qs.episode_id and qp.quest_source_sha256=qs.source_sha256
    and qd.id=qs.definition_id and qd.plan_version_id=qs.plan_version_id
    and qd.plan_sha256=r.plan_sha256 and qb.snapshot_sha256=mission_internal.fingerprint(qb.snapshot)
    and qd.definition_sha256=mission_internal.fingerprint(qd.definition)
    and ql.id='0b85f354-9cdb-47e1-baf9-3d266bb7e06b'::uuid and ql.is_active and ql.is_test);
 select public_objective into objective from public.mission_plan_steps where plan_version_id=r.plan_version_id
   and step_key=coalesce(private_source_step,r.current_step_key);
 if participant and not academy then vchoices:=public.mission_generic_choices_v1(m.id);
 else vchoices:=jsonb_build_object('choices','[]'::jsonb);end if;
 active:=m.stato in('preparazione','in_corso') and m.suspended_at is null and r.run_phase in('preparazione','in_corso');
 -- Public metadata only; no work payload, private intent, role or provider configuration.
 WITH room_session_source_rows AS MATERIALIZED (
  SELECT room_source.id,room_source.work_id
  FROM mission_generic_owner.unified_source_windows room_source
  WHERE room_source.master_session_id=m.id
 ), room_released_sources AS MATERIALIZED (
  SELECT room_source_row.id,room_source_row.work_id
  FROM room_session_source_rows room_source_row
  WHERE mission_generic_owner.role_source_released_v4(room_source_row.id)
 )
 select uf_candidate.* into uf_work from mission_generic_owner.work_items uf_candidate
where uf_candidate.master_session_id=m.id
 and not exists(
   select 1 from room_released_sources superseded_role
   left join mission_generic_owner.unified_batches superseded_batch
     on superseded_batch.source_window_id=superseded_role.id
   where (superseded_role.work_id=uf_candidate.id
       or superseded_batch.writer_work_id=uf_candidate.id))
 and not (m.id='b70b23cf-bad8-475d-a56a-d9c549e35d84'::uuid
   and mission_generic_owner.flow_scope_enabled(m.id)
   and exists(select 1 from mission_generic_owner.unified_source_windows superseded
     where superseded.id=uf_candidate.id and superseded.superseded_at is not null))
 and not (
  m.id='93d78313-abde-4087-9eb7-7b96bc0fa089'::uuid
  and m.location_id='6c737082-8fc7-4fd8-b246-30297a1ed1af'::uuid
  and uf_candidate.id='3076c471-37c5-438e-8f50-0a790b787e05'::uuid
  and uf_candidate.kind='choice' and uf_candidate.state='failed'
  and uf_candidate.encounter_id='deadfef6-5b16-4921-aa86-b86ffad6f2f2'::uuid
  and uf_candidate.step_key=r.current_step_key
  and uf_candidate.run_control_version=r.control_version
  and uf_candidate.payload->>'actor_id'='1f662f89-447a-4cd3-9873-a5953a0e0d91'
  and uf_candidate.payload->>'round_id'='44061137-17a3-43fa-9225-d29aaa26e58a'
  and uf_candidate.payload_sha256=public.combat_v2_sha256(uf_candidate.payload)
  and uf_candidate.result_sha256=public.combat_v2_sha256(uf_candidate.result)
  and uf_candidate.result->>'schema_version'='mission-generic-pre-provider-failure/1'
  and uf_candidate.result->>'failure_code'='request_validation_failed'
  and uf_candidate.result->>'provider_calls'='0'
  and uf_candidate.result->>'charged_cost_usd'='0'
  and (select md5(prosrc) from pg_proc where oid='mission_generic_owner.enqueue_choice(uuid,uuid,uuid)'::regprocedure)
      ='76a88f0e93752e1456c90d160a7a855d'
  and exists (
    select 1 from mission_generic_owner.unified_batches ub
    where ub.id='fbfc8e29-8724-4241-b2fe-22dbc17eb9e7'::uuid
      and ub.master_session_id=m.id and ub.encounter_id=uf_candidate.encounter_id
      and ub.state='preparing' and ub.entry_side='png'
      and ub.next_round_id='44061137-17a3-43fa-9225-d29aaa26e58a'::uuid
  )
  and not exists (
    select 1 from mission_generic_owner.work_items rw
    where rw.master_session_id=m.id
      and rw.dedupe_key=uf_candidate.dedupe_key||':recovery:'||uf_candidate.id::text
  )
  and not exists (
    select 1 from public.combat_v2_declarations d
    where d.round_id='44061137-17a3-43fa-9225-d29aaa26e58a'::uuid
      and d.actor_id='1f662f89-447a-4cd3-9873-a5953a0e0d91'::uuid
  )
 )
 order by (uf_candidate.state not in('completed','failed')) desc,
  case when uf_candidate.state not in('completed','failed') then uf_candidate.created_at end asc,
  uf_candidate.created_at desc,uf_candidate.id limit 1;
 if uf_work.id is not null then
  uf_state:=case when uf_work.state in('claimed','authorized','provider_started')
    and uf_work.lease_expires_at<=statement_timestamp() then 'uncertain' else uf_work.state end;
  uf_processing:=jsonb_build_object('schema_version','mission-generic-processing/1',
   'work_id',uf_work.id,'event_id',uf_work.event_id,'request_key',uf_work.request_key,
   'revision',uf_work.revision,'state',uf_state,'created_at',uf_work.created_at,
   'finalized_at',uf_work.finalized_at,'message_id',uf_work.message_id,
   'request',jsonb_build_object('schema_version','mission-generic-request/1',
    'master_session_id',m.id,'event_id',uf_work.event_id,'request_key',uf_work.request_key,
    'expected_revision',uf_work.revision));
 end if;
 -- Freeze only identities/states needed to wake progress, never the clock. Include
 -- declarations because a completed defense may advance mechanics without a run transition.
 select coalesce(jsonb_agg(jsonb_build_object('encounter_id',uf_enc.id,'state',uf_enc.state,
  'rounds',coalesce((select jsonb_agg(jsonb_build_object('round_id',uf_r.id,'phase',uf_r.phase,
    'state',uf_r.state,'report_id',uf_r.report_id,'narrated_at',uf_r.narrated_at,
    'declarations',coalesce((select jsonb_agg(jsonb_build_array(uf_d.id,uf_d.state) order by uf_d.id)
       from public.combat_v2_declarations uf_d where uf_d.round_id=uf_r.id),'[]'::jsonb)) order by uf_r.round_no)
   from (select uf_round.* from public.combat_v2_rounds uf_round where uf_round.session_id=uf_enc.id
     order by uf_round.round_no desc limit 2) uf_r),'[]'::jsonb)) order by uf_enc.id),'[]'::jsonb)
 into uf_rounds from public.combat_v2_sessions uf_enc
 where uf_enc.master_session_id=m.id and uf_enc.closed_at is null
 and not exists(select 1 from mission_generic_owner.unified_batches hidden_batch
   where hidden_batch.encounter_id=uf_enc.id and hidden_batch.source_window_id is not null
     and hidden_batch.composition_kind='entry_png' AND hidden_batch.retired_at IS NULL and hidden_batch.state in('preparing','ready')
     and hidden_batch.message_id is null);
 uf_marker:=mission_generic_owner.unified_progress_marker(m.id);
 if private_pending then uf_marker:=jsonb_set(uf_marker,'{batch}','null'::jsonb,false);end if;
 uf_review:=coalesce((uf_marker->>'review_required')::boolean,false);
 if academy and m.stato='in_corso' and r.run_phase='in_corso' then
  select rw.publication_id into flow_publication
  from mission_generic_owner.unified_round_windows rw
  join public.combat_v2_rounds cr on cr.id=rw.round_id
  join public.combat_v2_sessions cs on cs.id=cr.session_id
  where rw.master_session_id=m.id and rw.publication_id is not null
   and cs.closed_at is null and cs.state='in_corso'
  order by cr.round_no desc,rw.round_id desc limit 1;
  if flow_publication is not null then flow_state:='combat_started';
  else
   select ub.message_id into flow_publication
   from mission_generic_owner.unified_batches ub
   where ub.master_session_id=m.id and ub.step_key=r.current_step_key
    and ub.run_control_version=r.control_version and ub.state='published'
    and ub.route is not null and ub.encounter_id is null
   order by ub.published_at desc,ub.id desc limit 1;
   if uf_work.state in('claimed','authorized','provider_started')
or exists(select 1 from mission_generic_owner.unified_batches ub
     where ub.master_session_id=m.id AND ub.retired_at IS NULL and ub.state in('preparing','ready','needs_review')
       and not mission_generic_owner.role_source_released_v4(ub.source_window_id))
    or exists(select 1 from mission_generic_owner.unified_source_windows sw
     where sw.master_session_id=m.id and sw.consumed_message_id is null
      AND NOT(sw.superseded_at IS NOT NULL AND mission_generic_owner.role_source_released_v4(sw.id))
      and (m.id<>'b70b23cf-bad8-475d-a56a-d9c549e35d84'::uuid
        or not mission_generic_owner.flow_scope_enabled(m.id) or sw.superseded_at is null))
   then flow_state:='evaluating';flow_publication:=null;
   elsif flow_publication is not null and not exists(
    select 1 from public.messages role_msg
    where role_msg.location_id=m.location_id and role_msg.kind='say'
     and role_msg.recipient_user is null
     and role_msg.created_at>(select scene_msg.created_at from public.messages scene_msg where scene_msg.id=flow_publication)
     and exists(select 1 from public.master_v2_participants mp
      join public.characters c on c.id=mp.character_id and c.user_id=mp.user_id_snapshot
      where mp.session_id=m.id and mp.character_id=role_msg.character_id
       and mp.joined_at<=role_msg.created_at and (mp.left_at is null or mp.left_at>role_msg.created_at)))
   then flow_state:='new_scene';
   else flow_state:='waiting_roles';flow_publication:=null;end if;
  end if;
 end if;
 if private_pending then
  flow_state:='evaluating';flow_publication:=null;
  vchoices:=jsonb_build_object('choices','[]'::jsonb);
 end if;
 mb_read_recovery:=staff AND participant AND academy AND active
  AND p_location='0b85f354-9cdb-47e1-baf9-3d266bb7e06b'::uuid AND m.id='44078c5f-7001-4129-9506-e2f34e68c8ac'::uuid
  AND m.stato='in_corso' AND r.run_phase='in_corso'
  AND mission_generic_owner.manual_staff_count_limit_v1(m.id)='none'
  AND mission_generic_owner.role_source_revision_v1(m.id)='24db5db8da7ede254e6d719b587c4fa04dce6b9d1c920396251adb85d0f6294c'
  AND EXISTS(SELECT 1 FROM mission_generic_owner.staff_progress_ticks_v1 pt JOIN mission_generic_owner.progress_receipts pp
   ON pp.request_key=pt.request_key AND pp.master_session_id=pt.master_session_id AND pp.actor_user_id=pt.actor_user_id AND pp.result_sha256=pt.result_sha256 AND pp.result_sha256=public.combat_v2_sha256(pp.result)
   WHERE pt.master_session_id=m.id AND pt.request_key='9e48a416-9261-4399-9e4e-a82b8a3d3a48'::uuid
    AND pt.source_revision='24db5db8da7ede254e6d719b587c4fa04dce6b9d1c920396251adb85d0f6294c'
    AND pt.actor_user_id='b4952ed5-5ce0-49c0-9f2b-8fd5dcd89b4b'::uuid AND pt.staff_user_id=pt.actor_user_id
    AND pt.result_sha256='b27ed0db18a45d371931f015be0cd0fa060ed3f99b8d5843e8cbef45ecfbb2f8'
    AND mission_factory_owner.keys_exact_v2(pp.result,ARRAY['schema_version','master_session_id','state','dispatch','reason_code'])
    AND pp.result->>'schema_version'='mission-generic-progress/1' AND pp.result->>'master_session_id'=m.id::text
    AND pp.result->>'state'='paused' AND pp.result->>'reason_code'='MGPG_C7_RUN_BUDGET_STOP' AND pp.result->'dispatch'='null'::jsonb);
 IF academy AND (mission_public_owner.role_capture_scope_v1(m.id) OR mb_read_recovery)
 
THEN
  IF EXISTS(SELECT 1 FROM mission_generic_owner.role_window_cursors c
    WHERE c.master_session_id=m.id) THEN
    role_diag:=mission_generic_owner.role_flow_status_v1(m.id,uid);
  ELSE
    role_diag:=mission_generic_owner.role_status_snapshot_v1(m.id,uid,flow_state,uf_processing,uf_review);
  END IF;
  IF m.id='b70b23cf-bad8-475d-a56a-d9c549e35d84'::uuid
    AND role_diag IS NOT NULL THEN
    role_diag:=role_diag||jsonb_build_object('flow_reason','review_required',
      'next_actor','staff','flow_detail',null);
  END IF;
END IF;
  -- C1266: new finite source opt-in, proved from server start/admission, not a client state heuristic.
  IF staff AND participant AND p_location='0b85f354-9cdb-47e1-baf9-3d266bb7e06b'::uuid THEN
   c26_proof:=CASE WHEN EXISTS(SELECT 1 FROM mission_generic_owner.manual_staff_admissions_v1 ma WHERE ma.master_session_id=m.id) THEN mission_generic_owner.manual_staff_scope_v1(m.id) ELSE mission_generic_owner.c1266_clean_staff_admission_v1(m.id,true,false) END;
  END IF;
  IF c26_proof IS NOT NULL THEN
   c26_revision:=mission_generic_owner.role_source_revision_v1(m.id);
   SELECT st.kind INTO c26_phase_kind FROM public.mission_plan_steps st
    WHERE st.plan_version_id=r.plan_version_id AND st.step_key=coalesce(private_source_step,r.current_step_key);
   c26_kind:='none';
   IF EXISTS(SELECT 1 FROM mission_generic_owner.manual_staff_admissions_v1 ma WHERE ma.master_session_id=m.id) AND role_diag IS NULL THEN c26_revision:=NULL;END IF;
   -- Native is the currently bound mechanical FSM with a published native entry/window.
   -- No work is required: this includes gathering PG declarations/defenses after a Fato.
   IF NOT private_pending AND EXISTS(
    SELECT 1 FROM mission_generic_owner.encounters ee
    JOIN public.combat_v2_sessions cs ON cs.id=ee.encounter_id AND cs.master_session_id=m.id
    JOIN public.mission_plan_steps ps ON ps.plan_version_id=r.plan_version_id AND ps.step_key=ee.step_key AND ps.kind='mechanical'
    JOIN public.combat_v2_rounds cr ON cr.session_id=cs.id
    JOIN mission_generic_owner.unified_round_windows rw ON rw.round_id=cr.id AND rw.master_session_id=m.id
    JOIN mission_generic_owner.unified_batches ub ON ub.id=rw.batch_id AND ub.master_session_id=m.id
    JOIN public.messages pubmsg ON pubmsg.id=rw.publication_id AND pubmsg.id=ub.message_id
     AND pubmsg.kind='fato' AND pubmsg.recipient_user IS NULL AND pubmsg.location_id=p_location
    WHERE ee.master_session_id=m.id AND ee.step_key=r.current_step_key AND ee.run_control_version=r.control_version
     AND cs.closed_at IS NULL AND cs.state NOT IN('chiuso','annullato') AND ub.state='published') THEN
    -- Native progress does not capture narrative role submissions. Reuse the canonical
    -- read-only snapshot only after this sealed scene and published mechanical FSM proof.
    IF role_diag IS NULL AND EXISTS(SELECT 1 FROM mission_generic_owner.manual_staff_admissions_v1 ma WHERE ma.master_session_id=m.id) THEN
     role_diag:=mission_generic_owner.role_status_snapshot_v1(m.id,uid,flow_state,uf_processing,uf_review);
     IF mission_factory_owner.keys_exact_v2(role_diag,ARRAY['flow_reason','next_actor','roles_received','roles_required','source_revision','flow_detail'])
      AND jsonb_typeof(role_diag->'flow_reason')='string' AND role_diag->>'flow_reason'='published'
      AND jsonb_typeof(role_diag->'next_actor')='string' AND role_diag->>'next_actor'='none'
      AND jsonb_typeof(role_diag->'roles_received')='number' AND role_diag->>'roles_received' ~ '^[0-4]$'
      AND jsonb_typeof(role_diag->'roles_required')='number' AND role_diag->>'roles_required' ~ '^[1-4]$'
      AND (role_diag->>'roles_received')::integer<=(role_diag->>'roles_required')::integer
      AND jsonb_typeof(role_diag->'source_revision')='string' AND role_diag->>'source_revision' ~ '^[0-9a-f]{64}$'
      AND role_diag->'flow_detail'='null'::jsonb THEN
      c26_revision:=role_diag->>'source_revision';c26_kind:='native';
     ELSE
      -- No partial role/driver contract and no generic tick when the snapshot is invalid.
      role_diag:=NULL;c26_revision:=NULL;c26_kind:='none';uf_review:=true;
     END IF;
    ELSE c26_kind:='native';END IF;
   ELSIF c26_phase_kind='narrative' AND active
    AND c26_revision ~ '^[0-9a-f]{64}$'
    AND role_diag->>'source_revision'=c26_revision
    AND (mission_public_owner.role_capture_scope_v1(m.id) OR mb_read_recovery) THEN
    -- Includes legitimate ready_to_evaluate with no work: kind follows the narrative FSM, not absence of a job.
    c26_kind:='tick';
   END IF;
   -- A qualified manual scene without a role cursor keeps the existing
   -- read-only fallback revision. This does not grant a tick or create a cursor.
   IF c26_kind='none' AND c26_revision IS NULL
    AND EXISTS(SELECT 1 FROM mission_generic_owner.manual_staff_admissions_v1 ma WHERE ma.master_session_id=m.id)
    AND role_diag->>'source_revision' ~ '^[0-9a-f]{64}$' THEN
    c26_revision:=role_diag->>'source_revision';
   END IF;
  END IF;
 -- C1264 AGG2: read-only receipt summary, confined to the existing protected scene.
 IF (m.id='ce7bc0e0-c8ed-48dd-a9ec-58c02022a7b9'::uuid OR (c26_proof IS NOT NULL AND c26_kind='tick'))
  AND p_location='0b85f354-9cdb-47e1-baf9-3d266bb7e06b'::uuid AND staff AND participant
  AND (EXISTS(SELECT 1 FROM mission_generic_owner.manual_staff_admissions_v1 ma WHERE ma.master_session_id=m.id) OR uid IN('f0856d53-83a6-4de0-bc0c-12c87916e665'::uuid,'b4952ed5-5ce0-49c0-9f2b-8fd5dcd89b4b'::uuid))
  AND (EXISTS(SELECT 1 FROM mission_generic_owner.flow_staff_sessions f WHERE f.master_session_id=m.id AND f.enabled) OR (m.id='44078c5f-7001-4129-9506-e2f34e68c8ac'::uuid AND mission_generic_owner.manual_staff_count_limit_v1(m.id)='none'
 AND EXISTS(SELECT 1 FROM mission_generic_owner.staff_progress_ticks_v1 bt JOIN mission_generic_owner.progress_receipts bp ON bp.request_key=bt.request_key AND bp.master_session_id=bt.master_session_id AND bp.actor_user_id=bt.actor_user_id AND bp.result_sha256=bt.result_sha256 AND bp.result_sha256=public.combat_v2_sha256(bp.result)
 WHERE bt.master_session_id=m.id AND bt.request_key='9e48a416-9261-4399-9e4e-a82b8a3d3a48'::uuid AND bt.source_revision='24db5db8da7ede254e6d719b587c4fa04dce6b9d1c920396251adb85d0f6294c' AND bt.actor_user_id='b4952ed5-5ce0-49c0-9f2b-8fd5dcd89b4b'::uuid AND bt.staff_user_id=bt.actor_user_id AND bt.result_sha256='b27ed0db18a45d371931f015be0cd0fa060ed3f99b8d5843e8cbef45ecfbb2f8'
 AND mission_factory_owner.keys_exact_v2(bp.result,ARRAY['schema_version','master_session_id','state','dispatch','reason_code']) AND bp.result->>'schema_version'='mission-generic-progress/1' AND bp.result->>'master_session_id'=m.id::text AND bp.result->>'state'='paused' AND bp.result->>'reason_code'='MGPG_C7_RUN_BUDGET_STOP' AND bp.result->'dispatch'='null'::jsonb)))
  AND EXISTS(SELECT 1 FROM public.locations l WHERE l.id=p_location AND l.is_test AND l.is_active)
  AND role_diag->>'source_revision' ~ '^[0-9a-f]{64}$'
  AND role_diag->>'source_revision'=mission_generic_owner.role_source_revision_v1(m.id) THEN
  st_revision:=role_diag->>'source_revision';st_state:='absent';
  SELECT * INTO st_tick FROM mission_generic_owner.staff_progress_ticks_v1 t
    WHERE t.master_session_id=m.id AND t.source_revision=st_revision;
  IF FOUND THEN
   st_original_key:=st_tick.request_key;st_owner:=coalesce(st_tick.actor_user_id=uid,false);st_state:='blocked';
   IF st_original_key IS NOT NULL AND st_tick.result_sha256 ~ '^[0-9a-f]{64}$'
    AND EXISTS(SELECT 1 FROM public.master_v2_participants mp JOIN public.characters ch ON ch.id=mp.character_id AND ch.user_id=mp.user_id_snapshot
      JOIN public.profiles tp ON tp.id=mp.user_id_snapshot AND tp.role IN('admin','master')
      WHERE mp.session_id=m.id AND mp.user_id_snapshot=st_tick.actor_user_id AND mp.left_at IS NULL)
    AND EXISTS(SELECT 1 FROM public.profiles sp WHERE sp.id=st_tick.staff_user_id AND sp.role IN('admin','master')) THEN
    SELECT * INTO st_receipt FROM mission_generic_owner.progress_receipts pr
     WHERE pr.request_key=st_original_key AND pr.master_session_id=m.id AND pr.actor_user_id=st_tick.actor_user_id
      AND pr.result_sha256=st_tick.result_sha256 AND pr.result_sha256=public.combat_v2_sha256(pr.result);
    st_valid:=FOUND;
    IF st_valid AND st_tick.request_key='9e48a416-9261-4399-9e4e-a82b8a3d3a48'::uuid AND st_revision='24db5db8da7ede254e6d719b587c4fa04dce6b9d1c920396251adb85d0f6294c' AND (m.id='44078c5f-7001-4129-9506-e2f34e68c8ac'::uuid AND mission_generic_owner.manual_staff_count_limit_v1(m.id)='none'
 AND EXISTS(SELECT 1 FROM mission_generic_owner.staff_progress_ticks_v1 bt JOIN mission_generic_owner.progress_receipts bp ON bp.request_key=bt.request_key AND bp.master_session_id=bt.master_session_id AND bp.actor_user_id=bt.actor_user_id AND bp.result_sha256=bt.result_sha256 AND bp.result_sha256=public.combat_v2_sha256(bp.result)
 WHERE bt.master_session_id=m.id AND bt.request_key='9e48a416-9261-4399-9e4e-a82b8a3d3a48'::uuid AND bt.source_revision='24db5db8da7ede254e6d719b587c4fa04dce6b9d1c920396251adb85d0f6294c' AND bt.actor_user_id='b4952ed5-5ce0-49c0-9f2b-8fd5dcd89b4b'::uuid AND bt.staff_user_id=bt.actor_user_id AND bt.result_sha256='b27ed0db18a45d371931f015be0cd0fa060ed3f99b8d5843e8cbef45ecfbb2f8'
 AND mission_factory_owner.keys_exact_v2(bp.result,ARRAY['schema_version','master_session_id','state','dispatch','reason_code']) AND bp.result->>'schema_version'='mission-generic-progress/1' AND bp.result->>'master_session_id'=m.id::text AND bp.result->>'state'='paused' AND bp.result->>'reason_code'='MGPG_C7_RUN_BUDGET_STOP' AND bp.result->'dispatch'='null'::jsonb)) THEN
     mb_mode:=true;nw_mode:=true;nw_original_sha:=st_receipt.result_sha256;nw_original_key:=st_tick.request_key;st_recovery:=nw_original_key;st_next_key:=mission_ai_service_owner.uuid5(st_tick.request_key,'mission-staff-budget-only-resume/1:'||st_revision);
     IF EXISTS(SELECT 1 FROM mission_generic_owner.progress_receipts nr WHERE nr.request_key=st_next_key) THEN
      SELECT * INTO st_receipt FROM mission_generic_owner.progress_receipts nr WHERE nr.request_key=st_next_key AND nr.master_session_id=m.id AND nr.actor_user_id=st_tick.actor_user_id AND nr.result_sha256=public.combat_v2_sha256(nr.result);
      st_valid:=FOUND;IF NOT st_valid THEN st_blocked:=true;END IF;
     ELSE st_state:='no_work_released';st_valid:=false;END IF;
    END IF;
    IF st_valid AND NOT mb_mode AND (mission_factory_owner.keys_exact_v2(st_receipt.result,ARRAY['schema_version','master_session_id','state','dispatch'])
 AND st_receipt.result->>'schema_version'='mission-generic-progress/1' AND st_receipt.result->>'master_session_id'=m.id::text
 AND st_receipt.result->>'state'='needs_attention' AND st_receipt.result->'dispatch'='null'::jsonb
 AND EXISTS(SELECT 1 FROM mission_generic_owner.work_items healed 
 WHERE healed.master_session_id=m.id AND healed.created_at<st_tick.created_at AND (healed.kind='director' AND healed.state='failed' AND healed.result->>'ok'='true'
 AND healed.payload_sha256=public.combat_v2_sha256(healed.payload)
 AND EXISTS(SELECT 1 FROM mission_narrative_internal.dispatch_receipts healed_dr
  JOIN mission_narrative_internal.dispatch_audit healed_a ON healed_a.receipt_id=healed_dr.id AND healed_a.event_code='c1266_saved_director_applied'
  JOIN mission_narrative_internal.dispatch_audit healed_f ON healed_f.receipt_id=healed_dr.id AND healed_f.event_code='generic_finalized'
  JOIN mission_generic_owner.unified_batches healed_b ON healed_b.decision_work_id=healed.id AND healed_b.master_session_id=m.id
  JOIN mission_generic_owner.unified_source_windows healed_s ON healed_s.id=healed_b.source_window_id AND healed_s.work_id=healed.id AND healed_s.master_session_id=m.id
  JOIN mission_generic_owner.work_items healed_writer ON healed_writer.id=healed_b.writer_work_id AND healed_writer.master_session_id=m.id AND healed_writer.authority_receipt_id=healed_b.id
  JOIN public.messages healed_msg ON healed_msg.id=healed_writer.message_id AND healed_msg.kind='fato' AND healed_msg.recipient_user IS NULL AND healed_msg.body=healed_writer.result->>'text'
  WHERE healed_dr.id=healed.dispatch_receipt_id AND healed_dr.master_session_id=m.id AND healed_dr.authority_receipt_id=healed.id AND healed_dr.request_key=healed.request_key
   AND healed_dr.status='success' AND healed_dr.dispatch_count=1 AND healed_dr.finalized_at IS NOT NULL
   AND healed_a.details->>'schema_version'='c1266-saved-director-application/1' AND healed_a.details->>'master_session_id'=m.id::text
   AND healed_a.details->>'work_id'=healed.id::text AND healed_a.details->>'result_sha256'=healed.result_sha256
   AND healed_a.details->>'batch_id'=healed_b.id::text AND healed_a.details->>'writer_work_id'=healed_writer.id::text
   AND healed_a.details->>'generation_http_calls'='0' AND healed_a.details->>'failed_work_preserved'='true'
   AND healed_f.details->>'work_id'=healed.id::text AND healed_f.details->>'receipt_id'=healed.receipt_id::text
   AND healed_f.details->>'result_sha256'=healed.result_sha256 AND healed_f.details->>'result_jsonb_sha256'=public.combat_v2_sha256(healed.result)
   AND healed_b.state='published' AND healed_b.published_at IS NOT NULL AND healed_b.message_id=healed_writer.message_id
   AND healed_s.consumed_message_id=healed_b.message_id AND healed_s.superseded_at IS NULL
   AND healed_s.source_sha256=healed.payload_sha256 AND healed_writer.kind='narration' AND healed_writer.state='completed'
   AND healed_writer.payload=healed_b.payload AND healed_writer.payload_sha256=healed_b.payload_sha256
   AND healed_writer.payload_sha256=public.combat_v2_sha256(healed_writer.payload)
   AND EXISTS(SELECT 1 FROM mission_generic_owner.unified_segment_publications_v4 healed_pub WHERE healed_pub.work_id=healed_writer.id AND healed_pub.message_id=healed_msg.id)
   AND EXISTS(SELECT 1 FROM staff_ai_quota_private.calls healed_q WHERE healed_q.producer='mission_generic_ai' AND healed_q.scope_id=m.id AND healed_q.source_id=healed_dr.id AND healed_q.call_no=1 AND healed_q.state='settled' AND healed_q.charged_usd=healed_dr.charged_cost_usd))))) THEN
     nw_mode:=true;nw_original_sha:=st_receipt.result_sha256;nw_original_key:=st_tick.request_key;
     st_next_key:=mission_ai_service_owner.uuid5(st_tick.request_key,'mission-staff-no-dispatch-resume/1:'||st_revision);st_recovery:=nw_original_key;
     IF m.id='44078c5f-7001-4129-9506-e2f34e68c8ac'::uuid AND st_revision='ac9aedbd59dcb835d717f4ddb6ce195e3c2a9d640df576667290fa38b7e6cbbb' AND mission_generic_owner.role_source_released_v4('433ace05-5265-4aad-96a3-5567b6e3480a'::uuid)
      AND EXISTS(SELECT 1 FROM mission_generic_owner.progress_receipts rr WHERE rr.request_key=mission_ai_service_owner.uuid5('310493d3-92d2-4645-ba85-ab42f57dbf9d'::uuid,'mission-staff-unpublished-reinterpretation/1:ac9aedbd59dcb835d717f4ddb6ce195e3c2a9d640df576667290fa38b7e6cbbb') AND rr.master_session_id=m.id AND rr.actor_user_id=st_tick.actor_user_id AND rr.result_sha256=public.combat_v2_sha256(rr.result)) THEN st_next_key:=mission_ai_service_owner.uuid5('310493d3-92d2-4645-ba85-ab42f57dbf9d'::uuid,'mission-staff-unpublished-reinterpretation/1:ac9aedbd59dcb835d717f4ddb6ce195e3c2a9d640df576667290fa38b7e6cbbb');END IF;
     IF EXISTS(SELECT 1 FROM mission_generic_owner.progress_receipts nr WHERE nr.request_key=st_next_key) THEN
      SELECT * INTO st_receipt FROM mission_generic_owner.progress_receipts nr WHERE nr.request_key=st_next_key AND nr.master_session_id=m.id AND nr.actor_user_id=st_tick.actor_user_id AND nr.result_sha256=public.combat_v2_sha256(nr.result);
      st_valid:=FOUND;IF NOT st_valid THEN st_blocked:=true;END IF;
     ELSE st_state:='no_work_released';st_valid:=false;
     END IF;
    END IF;
    WHILE st_valid LOOP
     st_dispatch:=st_receipt.result->'dispatch';
     IF st_receipt.result->>'schema_version' IS DISTINCT FROM 'mission-generic-progress/1'
      OR jsonb_typeof(st_dispatch) IS DISTINCT FROM 'object'
      OR NOT(st_dispatch ?& ARRAY['schema_version','master_session_id','event_id','request_key','expected_revision'])
      OR st_dispatch-'schema_version'-'master_session_id'-'event_id'-'request_key'-'expected_revision'<>'{}'::jsonb
      OR st_dispatch->>'schema_version' IS DISTINCT FROM 'mission-generic-request/1'
      OR st_dispatch->>'master_session_id' IS DISTINCT FROM m.id::text
      OR (st_dispatch->>'event_id' ~ '^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$') IS DISTINCT FROM TRUE
      OR (st_dispatch->>'request_key' ~ '^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$') IS DISTINCT FROM TRUE
      OR jsonb_typeof(st_dispatch->'expected_revision') IS DISTINCT FROM 'number'
      OR (st_dispatch->>'expected_revision' ~ '^[1-9][0-9]*$') IS DISTINCT FROM TRUE THEN st_blocked:=true;EXIT;END IF;
     IF (st_dispatch->>'expected_revision')::numeric>9223372036854775807 THEN st_blocked:=true;EXIT;END IF;
     SELECT w.id,w.master_session_id,w.event_id,w.request_key,w.revision,w.kind,w.state,w.authority_receipt_id,w.finalized_at,w.created_at,w.lease_expires_at,w.step_key,w.run_control_version,w.definition_sha256 INTO st_work
      FROM mission_generic_owner.work_items w WHERE w.event_id=(st_dispatch->>'event_id')::uuid
       AND w.master_session_id=m.id AND w.request_key=(st_dispatch->>'request_key')::uuid AND w.revision=(st_dispatch->>'expected_revision')::bigint;
     IF NOT FOUND THEN st_blocked:=true;EXIT;END IF;
     -- ACK belongs only to this effective validated successor, never to a computed next key.
     st_ack_predecessor:=st_candidate_predecessor;
     st_effective_id:=st_work.id;st_public_state:=CASE WHEN st_work.state IN('claimed','authorized','provider_started') AND st_work.lease_expires_at<=statement_timestamp() THEN 'uncertain' ELSE st_work.state END;
     st_state:='attested';st_released:=false;st_next_key:=NULL;st_recovery:=NULL;
     IF st_work.kind='director' AND st_work.id=(st_dispatch->>'event_id')::uuid AND st_work.state='failed' AND st_work.finalized_at IS NOT NULL THEN
      SELECT sw.id,sw.master_session_id,sw.work_id,sw.superseded_reason,sw.consumed_message_id,sw.context->>'source_revision' AS source_revision,sw.step_key,sw.run_control_version,sw.definition_sha256 INTO st_source
       FROM mission_generic_owner.unified_source_windows sw WHERE sw.id=st_work.authority_receipt_id AND sw.work_id=st_work.id AND sw.master_session_id=m.id;
      IF FOUND AND st_source.source_revision=st_revision AND (st_source.superseded_reason IN('staff_failed_director_validation_retry','staff_failed_director_count_overflow_retry') OR (st_source.id IN('d460a7be-a3a2-4ad8-9d3b-d2e929f2947e'::uuid,'f4f7185e-4aae-4edd-ac24-65f8dcfa36f5'::uuid) AND st_source.master_session_id='44078c5f-7001-4129-9506-e2f34e68c8ac'::uuid AND st_source.superseded_reason='staff_preprovider_request_retry'))
       AND st_source.consumed_message_id IS NULL AND mission_generic_owner.role_source_released_v4(st_source.id) THEN
       st_released:=true;st_state:='released';st_recovery:=st_work.id;
       IF st_source.superseded_reason='staff_failed_director_count_overflow_retry' THEN st_next_key:=mission_ai_service_owner.uuid5(st_work.id,'mission-staff-count-overflow-retry/1:'||st_revision);
       ELSIF st_depth=0 THEN st_next_key:=mission_ai_service_owner.uuid5(st_work.id,'mission-staff-released-director-retry/1:'||st_revision);
       ELSIF st_depth=1 THEN st_next_key:=mission_ai_service_owner.uuid5(st_work.id,'mission-staff-db-context-retry/2:'||st_revision);END IF;
      END IF;
     END IF;
     IF st_next_key IS NULL THEN EXIT;END IF;
     SELECT * INTO st_receipt FROM mission_generic_owner.progress_receipts pr WHERE pr.request_key=st_next_key;
     IF NOT FOUND THEN EXIT;END IF;
     IF st_receipt.master_session_id IS DISTINCT FROM m.id OR st_receipt.actor_user_id IS DISTINCT FROM st_tick.actor_user_id
      OR st_receipt.result_sha256 IS DISTINCT FROM public.combat_v2_sha256(st_receipt.result) THEN st_blocked:=true;EXIT;END IF;
     st_candidate_predecessor:=st_work.id;
     st_depth:=st_depth+1;
    END LOOP;
    IF st_blocked OR (NOT st_valid AND st_state<>'no_work_released') THEN st_state:='blocked';st_effective_id:=NULL;st_public_state:=NULL;st_next_key:=NULL;st_recovery:=NULL;st_released:=false;st_ack_predecessor:=NULL;END IF;
   END IF;
  END IF;
  -- Own admission plus the same runtime gates: closure never disables the receipt read itself.
  IF st_state='released' THEN
  IF st_owner AND st_next_key IS NOT NULL AND active AND NOT uf_review
   AND m.stato='in_corso' AND r.run_phase='in_corso' AND role_diag->>'flow_reason'='ready_to_evaluate'
   AND st_work.step_key=r.current_step_key AND st_source.step_key=r.current_step_key
   AND st_work.run_control_version=r.control_version AND st_source.run_control_version=r.control_version
   AND st_work.definition_sha256=st_source.definition_sha256
   AND mission_generic_owner.c726_factory_staff_runtime_v1(m.id) IS TRUE
   AND mission_generic_owner.flow_scope_enabled(m.id) IS TRUE
   AND EXISTS(SELECT 1 FROM mission_factory_owner.provider_authoring_admissions fa
     JOIN mission_factory_owner.editor_release_readiness rr ON rr.singleton
     WHERE fa.actor_user=uid AND fa.location_id=m.location_id AND fa.enabled
      AND ((EXISTS(SELECT 1 FROM mission_generic_owner.manual_staff_admissions_v1 ma WHERE ma.master_session_id=m.id AND m.id='44078c5f-7001-4129-9506-e2f34e68c8ac'::uuid AND st_source.id IN('d460a7be-a3a2-4ad8-9d3b-d2e929f2947e'::uuid,'f4f7185e-4aae-4edd-ac24-65f8dcfa36f5'::uuid) AND st_source.superseded_reason='staff_preprovider_request_retry' AND mission_generic_owner.c1266_execution_authority_v1(m.id,false,true)#>>'{admission,schema_version}'='c1266-staff-admission-authority/3' AND mission_generic_owner.c1266_execution_authority_v1(m.id,false,true)->>'release_sha256'=rr.revision_sha256 AND mission_generic_owner.c1266_execution_authority_v1(m.id,false,true)->>'binding_sha256'=st_work.definition_sha256) OR mission_generic_owner.manual_staff_template_policy_v1(m.id) IS NOT NULL OR fa.expires_at>statement_timestamp() OR (mission_generic_owner.c1266_staff_source_scope_v1(m.id) IS NOT NULL AND mission_generic_owner.c1266_staff_source_scope_v1(m.id)#>>'{campaign_snapshot,time_policy,mode}'='budget_or_explicit_stop')) OR ((rr.canonical_preimage::jsonb#>'{config,c1266_staff_campaign}'='{"maxGen":17,"maxUSD":"0.4216","maxHTTP":34,"grant_id":"b925043a-c1b3-434b-8fb4-f335903b2af0","maxCount":17,"residual":{"gen":17,"usd":"0.4395760","http":34,"count":17},"max_pairs":17,"expires_at":"2026-10-20T15:12:18.393948+00:00","not_before":"2026-10-20T14:12:18.393948+00:00","campaign_id":"b2fc5e28-072b-41f2-8dd8-cb5a35a13092","location_id":"0b85f354-9cdb-47e1-baf9-3d266bb7e06b","work_seconds":360,"schema_version":"c1266-staff-campaign/2","cleanup_seconds":360,"history_baseline":{"gen":33,"usd":"0.5524240","http":69,"count":36},"history_scope_ids":["0b1fa6b5-d9c4-4ea3-9ec8-76b1b21e0a0a","21fb8bf3-1df9-4bbf-b2d6-cf7b003b8f30","a853d33f-eecf-484b-b85c-5dc12c25d080","d25d886e-e4f8-4cfe-b8f2-729e96f355d7","c21baa1a-cdac-4401-9131-493eef208a21","780bc131-229e-4142-b1f9-4c6a39b6d070","ef12969b-0958-473c-9016-53052af9d579","2067ace7-c975-4e6c-a621-f82ac23ed18d","6c8d9647-b0de-4c2c-a7e0-6c4a6239ee86","41ec7f9e-9c2c-4476-be14-3ba57a573bc5","8b814fa7-fcdb-4035-9ddb-5bea247aeb36"],"time_policy":{"mode":"budget_or_explicit_stop","expires_at_role":"historical_provenance"}}'::jsonb AND rr.canonical_preimage::jsonb#>'{config,c1266_clean_staff}'='{"grant_id":"b925043a-c1b3-434b-8fb4-f335903b2af0","expires_at":"2026-10-20T15:12:18.393948+00:00","not_before":"2026-10-20T14:12:18.393948+00:00","location_id":"0b85f354-9cdb-47e1-baf9-3d266bb7e06b","source_sha256":"eca0639f48346ed0c1fac786c136f557920b61310c38d85f22a5e6a7837231bd","schema_version":"c1266-clean-staff-admission-policy/2","source_mission_id":"5878822d-dc03-4ac2-ad0b-1547f0ab3fc0","source_plan_version_id":"24b1e44a-5597-4fb0-95bd-fb13647764b2","c7_budget_qualification":{"model":"gpt-6-luna","store":false,"http_limit":28,"schema_version":"c1266-clean-staff-budget-qualification/1","generation_limit":14,"reasoning_effort":"high","input_usd_million":0.1,"input_tokens_limit":24000,"output_usd_million":0.5,"output_tokens_limit":20000,"count_upper_cost_usd":"0.0124","scene_cost_budget_usd":"0.3136","generation_upper_cost_usd":"0.0124","count_qualification_sha256":"d8da6486b29f5e6b57272eb9d21660518cdcb57f12ed69209e12f32c37e2d5c0","count_reserve_contract_sha256":"13421de48d6dddbb8c6628fd6a294b90746b3d2b79e56bf617456a5d3cc8e090"},"c7_budget_qualification_sha256":"39af421ce9035831c695f0c8d8bc8157cdfd09918b8b81072433e9031b248959","campaign_id":"b2fc5e28-072b-41f2-8dd8-cb5a35a13092","time_policy":{"mode":"budget_or_explicit_stop","expires_at_role":"historical_provenance"}}'::jsonb) AND fa.expires_at=(rr.canonical_preimage::jsonb#>>'{config,c1266_staff_campaign,expires_at}')::timestamptz AND ((mission_factory_owner.keys_exact_v2(mission_generic_owner.c1266_execution_authority_v1(m.id,false,true)->'admission',ARRAY['schema_version','kind','resource_scope','finite_admission_sha256','grant_id','not_before','expires_at','location_id','campaign_id','time_policy']) AND mission_generic_owner.c1266_execution_authority_v1(m.id,false,true)->'admission'->>'schema_version'='c1266-staff-admission-authority/2' AND mission_generic_owner.c1266_execution_authority_v1(m.id,false,true)->'admission'->>'kind'='staff_finite' AND mission_generic_owner.c1266_execution_authority_v1(m.id,false,true)->'admission'->>'resource_scope'='staff_simulation' AND mission_generic_owner.c1266_execution_authority_v1(m.id,false,true)->'admission'->>'campaign_id'='b2fc5e28-072b-41f2-8dd8-cb5a35a13092' AND mission_generic_owner.c1266_execution_authority_v1(m.id,false,true)->'admission'->>'grant_id'='b925043a-c1b3-434b-8fb4-f335903b2af0' AND mission_generic_owner.c1266_execution_authority_v1(m.id,false,true)->'admission'->>'not_before'='2026-10-20T14:12:18.393948+00:00' AND mission_generic_owner.c1266_execution_authority_v1(m.id,false,true)->'admission'->>'expires_at'='2026-10-20T15:12:18.393948+00:00' AND mission_generic_owner.c1266_execution_authority_v1(m.id,false,true)->'admission'->>'location_id'='0b85f354-9cdb-47e1-baf9-3d266bb7e06b' AND mission_generic_owner.c1266_execution_authority_v1(m.id,false,true)->'admission'->'time_policy'='{"mode":"budget_or_explicit_stop","expires_at_role":"historical_provenance"}'::jsonb AND (mission_generic_owner.c1266_execution_authority_v1(m.id,false,true)->'admission'->>'finite_admission_sha256' ~ '^[a-f0-9]{64}$') IS TRUE) IS TRUE))) AND fa.release_sha256=rr.revision_sha256)
   AND mission_staff_abort_private.quiescent_v1(m.id) IS TRUE
   AND NOT EXISTS(SELECT 1 FROM mission_generic_owner.work_items newer WHERE newer.master_session_id=m.id AND newer.created_at>st_work.created_at)
   AND NOT EXISTS(SELECT 1 FROM mission_generic_owner.work_items w WHERE w.master_session_id=m.id AND w.state IN('ready','claimed','authorized','provider_started','uncertain'))
   AND NOT EXISTS(SELECT 1 FROM mission_generic_owner.unified_source_windows sw WHERE sw.master_session_id=m.id AND sw.consumed_message_id IS NULL AND sw.superseded_at IS NULL)
   AND NOT EXISTS(SELECT 1 FROM public.combat_v2_sessions cs WHERE cs.master_session_id=m.id AND cs.closed_at IS NULL)
   AND NOT EXISTS(SELECT 1 FROM jsonb_array_elements(mission_generic_owner.run_plan_settings(m.id)->'terminal_steps') term WHERE term->>'step_key'=r.current_step_key) THEN
   -- Read-only Native C7 arithmetic; never invoke a service-only reserve/consume helper from this reader.
   SELECT * INTO STRICT st_budget_a FROM mission_generic_owner.dispatch_admissions WHERE master_session_id=m.id;
   SELECT * INTO STRICT st_budget_g FROM mission_generic_owner.provider_policy WHERE singleton;
   SELECT pol.max_input_tokens,pol.max_output_tokens,pol.input_usd_million,pol.output_usd_million,pol.run_budget_usd INTO STRICT st_budget_p FROM mission_narrative_internal.runtime_policy pol WHERE singleton;
   st_bound:=(st_budget_p.max_input_tokens*st_budget_p.input_usd_million+st_budget_p.max_output_tokens*st_budget_p.output_usd_million)/1000000;
   budget1_effective:=mission_generic_owner.effective_admission_usd_cap_v1(m.id);
 budget1_policy:=CASE WHEN m.id='44078c5f-7001-4129-9506-e2f34e68c8ac'::uuid AND st_budget_a.cost_budget_usd=0.3136::numeric AND budget1_effective=1.00::numeric THEN greatest(st_budget_g.run_budget_usd,budget1_effective) ELSE st_budget_g.run_budget_usd END;
 st_cap_cost:=least(budget1_policy,budget1_effective,coalesce(st_budget_p.run_budget_usd,budget1_policy));
   st_cap_http:=2*least(st_budget_g.max_run_calls,st_budget_a.call_limit);
   SELECT coalesce(sum(CASE WHEN d.status IN('success','fallback','unknown_billable') THEN coalesce(d.charged_cost_usd,d.upper_bound_cost_usd,0)
    WHEN wi.state IN('claimed','authorized','provider_started') THEN greatest(coalesce(d.upper_bound_cost_usd,0),st_bound) ELSE coalesce(d.upper_bound_cost_usd,0) END
    + CASE WHEN ca.details IS NOT NULL THEN (ca.details->>'count_upper_cost_usd')::numeric WHEN wi.state IN('claimed','authorized','provider_started') THEN coalesce(st_budget_a.c8_count_upper_cost_usd,0) ELSE 0 END),0),
    coalesce(sum(CASE WHEN wi.state IN('claimed','authorized','provider_started') THEN 2 ELSE (CASE WHEN ca.details IS NOT NULL THEN 1 ELSE 0 END)+(CASE WHEN d.upper_bound_cost_usd IS NOT NULL OR EXISTS(SELECT 1 FROM mission_narrative_internal.dispatch_attempts da WHERE da.receipt_id=d.id) THEN 1 ELSE 0 END) END),0)
   INTO st_spent,st_http FROM mission_generic_owner.work_items wi LEFT JOIN mission_narrative_internal.dispatch_receipts d ON d.id=wi.dispatch_receipt_id
    LEFT JOIN mission_narrative_internal.dispatch_audit ca ON ca.receipt_id=d.id AND ca.event_code='c8_count_started'
    WHERE wi.master_session_id=m.id AND (wi.dispatch_receipt_id IS NOT NULL OR wi.state IN('claimed','authorized','provider_started'));
   st_http:=greatest(st_http,st_budget_a.calls_authorized);
   st_budget_ok:=st_budget_a.enabled AND st_budget_g.enabled AND st_budget_a.c7_budget_enforced
    AND st_budget_a.c7_budget_qualification_sha256 IS NOT NULL AND st_budget_a.c8_count_qualification_sha256 IS NOT NULL
    AND st_budget_a.c8_count_upper_cost_usd IS NOT NULL AND st_bound>=0 AND st_bound<'Infinity'::numeric AND st_cap_cost>0 AND (mission_generic_owner.manual_staff_count_limit_v1(m.id)='none' OR st_cap_http>0)
    AND (mission_generic_owner.c1266_staff_scene_policy_v1(m.id) IS NOT NULL OR (st_spent+st_bound+st_budget_a.c8_count_upper_cost_usd<=st_cap_cost AND (mission_generic_owner.manual_staff_count_limit_v1(m.id)='none' OR st_http+2<=st_cap_http)));
   st_resume:=st_budget_ok IS TRUE;
  END IF;
  END IF;
  IF nw_mode AND st_state='no_work_released' THEN
   st_resume:=st_owner AND active AND NOT uf_review AND m.stato='in_corso' AND r.run_phase='in_corso'
    AND role_diag->>'flow_reason'='ready_to_evaluate' AND mission_generic_owner.flow_scope_enabled(m.id)
    AND EXISTS(SELECT 1 FROM mission_generic_owner.manual_staff_admissions_v1 ma WHERE ma.master_session_id=m.id)
    AND mission_generic_owner.c1266_execution_authority_v1(m.id,false,true)->>'runtime_authorized'='true'
    AND NOT EXISTS(SELECT 1 FROM mission_generic_owner.work_items aw WHERE aw.master_session_id=m.id AND aw.state IN('ready','claimed','authorized','provider_started','uncertain'))
    AND NOT EXISTS(SELECT 1 FROM mission_generic_owner.unified_source_windows aw WHERE aw.master_session_id=m.id AND aw.superseded_at IS NULL AND aw.consumed_message_id IS NULL)
    AND NOT EXISTS(SELECT 1 FROM public.combat_v2_sessions ac WHERE ac.master_session_id=m.id AND ac.closed_at IS NULL);
  END IF;
  IF mb_mode AND st_state='no_work_released' THEN
   SELECT * INTO STRICT st_budget_a FROM mission_generic_owner.dispatch_admissions WHERE master_session_id=m.id;
   SELECT * INTO STRICT st_budget_g FROM mission_generic_owner.provider_policy WHERE singleton;
   SELECT pol.max_input_tokens,pol.max_output_tokens,pol.input_usd_million,pol.output_usd_million,pol.run_budget_usd INTO STRICT st_budget_p FROM mission_narrative_internal.runtime_policy pol WHERE singleton;
   st_bound:=(24000*st_budget_p.input_usd_million+20000*st_budget_p.output_usd_million)/1000000;
   budget1_effective:=mission_generic_owner.effective_admission_usd_cap_v1(m.id);
 budget1_policy:=CASE WHEN m.id='44078c5f-7001-4129-9506-e2f34e68c8ac'::uuid AND st_budget_a.cost_budget_usd=0.3136::numeric AND budget1_effective=1.00::numeric THEN greatest(st_budget_g.run_budget_usd,budget1_effective) ELSE st_budget_g.run_budget_usd END;
 st_cap_cost:=least(budget1_policy,budget1_effective,coalesce(st_budget_p.run_budget_usd,budget1_policy));
   SELECT coalesce(sum(CASE WHEN d.status IN('success','fallback','unknown_billable') THEN coalesce(d.charged_cost_usd,d.upper_bound_cost_usd,0) ELSE coalesce(d.upper_bound_cost_usd,0) END+CASE WHEN ca.details IS NOT NULL THEN (ca.details->>'count_upper_cost_usd')::numeric ELSE 0 END),0),coalesce(sum((CASE WHEN ca.details IS NOT NULL THEN 1 ELSE 0 END)+(CASE WHEN d.upper_bound_cost_usd IS NOT NULL OR EXISTS(SELECT 1 FROM mission_narrative_internal.dispatch_attempts da WHERE da.receipt_id=d.id) THEN 1 ELSE 0 END)),0) INTO st_spent,st_http
   FROM mission_generic_owner.work_items wi LEFT JOIN mission_narrative_internal.dispatch_receipts d ON d.id=wi.dispatch_receipt_id LEFT JOIN mission_narrative_internal.dispatch_audit ca ON ca.receipt_id=d.id AND ca.event_code='c8_count_started' WHERE wi.master_session_id=m.id;
   st_resume:=st_owner AND active AND NOT uf_review AND m.stato='in_corso' AND r.run_phase='in_corso' AND st_budget_g.enabled AND role_diag->>'flow_reason'='ready_to_evaluate'
    AND st_budget_a.c7_budget_enforced AND st_budget_a.call_limit=14 AND st_budget_a.calls_authorized=0 AND st_http=28 AND st_budget_a.cost_budget_usd=0.3136
    AND st_spent+st_bound+st_budget_a.c8_count_upper_cost_usd<=st_cap_cost
    AND NOT EXISTS(SELECT 1 FROM mission_generic_owner.work_items aw WHERE aw.master_session_id=m.id AND aw.state IN('ready','claimed','authorized','provider_started','uncertain'))
    AND NOT EXISTS(SELECT 1 FROM mission_generic_owner.unified_source_windows aw WHERE aw.master_session_id=m.id AND aw.superseded_at IS NULL AND aw.consumed_message_id IS NULL)
    AND NOT EXISTS(SELECT 1 FROM public.combat_v2_sessions aw WHERE aw.master_session_id=m.id AND aw.closed_at IS NULL);
  END IF;
  staff_tick_view:=jsonb_build_object('schema_version','mission-generic-staff-tick-status/2','master_session_id',m.id,
   'source_revision',st_revision,'request_key',st_original_key,'owned_by_me',st_owner,'state',st_state,
   'work_id',st_effective_id,'work_state',st_public_state,'retry_request_key',st_next_key,
   'can_resume',st_resume,'recovery_key',st_recovery,
   'acknowledged_retry_from_work_id',st_ack_predecessor);
  IF nw_mode THEN
   staff_tick_view:=staff_tick_view||jsonb_build_object('schema_version','mission-generic-staff-tick-status/3','recovery_kind','no_work_progress_receipt','original_result_sha256',nw_original_sha,
    'recovery_key',nw_original_key,'retry_request_key',CASE WHEN mb_mode THEN mission_ai_service_owner.uuid5(st_tick.request_key,'mission-staff-budget-only-resume/1:'||st_revision) ELSE mission_ai_service_owner.uuid5(st_tick.request_key,'mission-staff-no-dispatch-resume/1:'||st_revision) END,'acknowledged_recovery_key',CASE WHEN st_state='attested' AND NOT st_blocked AND st_effective_id IS NOT NULL THEN nw_original_key ELSE NULL END,
    'can_resume',CASE WHEN st_state='no_work_released' THEN st_resume ELSE false END);
  END IF;

 END IF;


 IF NOT event42_mode AND staff AND participant AND p_location='0b85f354-9cdb-47e1-baf9-3d266bb7e06b'::uuid THEN
  journal_settlements:=mission_generic_owner.staff_journal_settlements_v1(m.id,uid);
 END IF;
 IF NOT event42_mode AND uf_work.id IS NOT NULL THEN opening_resume49:=mission_generic_owner.opening_ready_resume_proof_v1(uf_work.id,uid);END IF;
 IF NOT event42_mode AND uf_work.id IS NOT NULL THEN opening_claim_resume6:=mission_generic_owner.opening_claim_resume_proof_v1(uf_work.id,uid);END IF;
 IF NOT event42_mode AND uf_work.id IS NOT NULL THEN c26_count_view:=mission_generic_owner.c1266_count_reconciliation_v1(uf_work.id,uid,false);END IF;
 uf_progress_key:=public.combat_v2_sha256(jsonb_build_object('session_id',m.id,
  'master_version',m.control_version,'master_state',m.stato,'run_version',r.control_version,
  'run_phase',r.run_phase,'step_key',coalesce(private_source_step,r.current_step_key),'processing',uf_processing,
  'choice_context',vchoices,'mechanical_state',uf_rounds,'unified',uf_marker,
  'flow_state',flow_state,'flow_publication_id',flow_publication));
 IF role_diag IS NOT NULL THEN uf_progress_key:=public.combat_v2_sha256(jsonb_build_object('base',uf_progress_key,'source_revision',role_diag->>'source_revision')); END IF;
  IF c26_proof IS NOT NULL THEN
   c26_driver:=jsonb_build_object('schema_version','mission-driver-state/1','master_session_id',m.id,
    'source_revision',c26_revision,'kind',c26_kind,
    'tick_status',CASE WHEN c26_kind='tick' THEN staff_tick_view ELSE NULL END);
   uf_progress_key:=public.combat_v2_sha256(jsonb_build_object('base',uf_progress_key,'driver_state',c26_driver));
  END IF;
 IF c26_count_view IS NOT NULL THEN uf_progress_key:=public.combat_v2_sha256(jsonb_build_object('base',uf_progress_key,'count_reconciliation',c26_count_view));END IF;
 IF opening_resume49 IS NOT NULL THEN uf_progress_key:=public.combat_v2_sha256(jsonb_build_object('base',uf_progress_key,'opening_ready_resume',opening_resume49));END IF;
 IF opening_claim_resume6 IS NOT NULL THEN uf_progress_key:=public.combat_v2_sha256(jsonb_build_object('base',uf_progress_key,'opening_claim_resume',opening_claim_resume6));END IF;
 IF staff AND participant AND p_location='0b85f354-9cdb-47e1-baf9-3d266bb7e06b'::uuid THEN
  SELECT proof.x INTO combat_recovery FROM mission_generic_owner.work_items cw CROSS JOIN LATERAL(SELECT mission_generic_owner.combat_narration_reissue_proof_v1(cw.id,uid) x) proof
  WHERE cw.master_session_id=m.id AND cw.kind='narration' AND cw.state='failed' AND cw.payload->>'schema_version' IN('mission-generic-narration/2','mission-generic-narration/3') AND proof.x IS NOT NULL AND (proof.x->>'published'='false' OR proof.x->>'schema_version'='mission-native-combat-writer-reissue-proof/1') ORDER BY cw.created_at DESC,cw.id DESC LIMIT 1;
  IF combat_recovery->>'schema_version'='mission-native-combat-writer-reissue-proof/1' THEN combat_recovery:=jsonb_build_object('schema_version','mission-combat-narration-recovery/2','master_session_id',m.id,'failed_work_id',combat_recovery->'failed_work_id','authority_receipt_id',combat_recovery->'authority_receipt_id','report_id',combat_recovery->'report_id','payload_sha256',combat_recovery->'payload_sha256','owned_by_me',combat_recovery->'owned_by_me','can_reissue',combat_recovery->'can_reissue','successor_work_id',combat_recovery->'successor_work_id','successor_request',combat_recovery->'successor_request','can_resume',false,'successor_publication_id',combat_recovery->'successor_publication_id');
  ELSIF combat_recovery IS NOT NULL THEN combat_recovery:=jsonb_build_object('schema_version','mission-combat-narration-recovery/1','master_session_id',m.id,'failed_work_id',combat_recovery->'failed_work_id','batch_id',combat_recovery->'batch_id','report_id',combat_recovery->'report_id','payload_sha256',combat_recovery->'payload_sha256','owned_by_me',combat_recovery->'owned_by_me','can_reissue',combat_recovery->'can_reissue','successor_work_id',combat_recovery->'successor_work_id','successor_request',combat_recovery->'successor_request','can_resume',combat_recovery->'can_resume');END IF;
 END IF;
 -- Nonterminal paid-Director adoption handoff. It delegates only the exact
 -- failed parent observer to its existing canonical Writer; it attests no Fato.
 IF staff AND participant AND p_location='0b85f354-9cdb-47e1-baf9-3d266bb7e06b'::uuid
  AND EXISTS(SELECT 1 FROM public.master_v2_participants rhparticipant
   JOIN public.characters rhcharacter ON rhcharacter.id=rhparticipant.character_id AND rhcharacter.user_id=uid
   WHERE rhparticipant.session_id=m.id AND rhparticipant.user_id_snapshot=uid
    AND rhparticipant.left_at IS NULL AND rhparticipant.engagement_state='attivo') THEN
  WITH retained_candidates AS MATERIALIZED(
   SELECT rhparent.id,rhparent.definition_sha256 FROM mission_generic_owner.work_items rhparent
   WHERE rhparent.master_session_id=m.id AND rhparent.kind='director' AND rhparent.state='failed'
    AND rhparent.result->'failure_codes' ? 'MISSION_PROVIDER_OUTPUT_RETENTION_FAILED'
    AND EXISTS(SELECT 1 FROM mission_narrative_internal.dispatch_audit rhadoption
     WHERE rhadoption.receipt_id=rhparent.dispatch_receipt_id AND rhadoption.event_code='retained_director_adopted')
  ), retained_proofs AS MATERIALIZED(
   SELECT rhcandidate.id,rhcandidate.definition_sha256,mission_generic_owner.retained_director_adoption_v1(rhcandidate.id,false) proof
   FROM retained_candidates rhcandidate
  ), retained_bound AS MATERIALIZED(
   SELECT rhproof.proof,rhchild.id child_id,rhchild.state child_state,rhchild.finalized_at child_finalized,
    rhchild.receipt_id child_receipt,rhchild.message_id child_message,rhchild.result child_result,
    rhchild.lease_id child_lease,rhchild.authorization_id child_authorization,rhchild.dispatch_id child_dispatch,
    rhchild.dispatch_receipt_id child_dispatch_receipt,
    jsonb_build_object('schema_version','mission-generic-request/1','master_session_id',rhchild.master_session_id,
     'event_id',rhchild.event_id,'request_key',rhchild.request_key,'expected_revision',rhchild.revision) child_request
   FROM retained_proofs rhproof JOIN mission_generic_owner.work_items rhchild
    ON rhchild.id=(rhproof.proof#>>'{applied,child_work_id}')::uuid
   WHERE rhproof.proof->'published'='false'::jsonb AND rhproof.proof->'applied' IS DISTINCT FROM 'null'::jsonb
    AND rhchild.master_session_id=m.id AND rhchild.kind='narration'
    AND rhchild.run_control_version=r.control_version
    AND rhchild.definition_sha256=rhproof.definition_sha256
    AND rhchild.step_key=r.current_step_key
    AND rhproof.proof#>'{applied,child_request}'=jsonb_build_object('schema_version','mission-generic-request/1',
     'master_session_id',rhchild.master_session_id,'event_id',rhchild.event_id,'request_key',rhchild.request_key,'expected_revision',rhchild.revision)
  ) SELECT rhbound.*,count(*) OVER() match_count INTO retained_row FROM retained_bound rhbound LIMIT 1;
  IF FOUND AND retained_row.match_count=1 THEN
   retained_handoff:=jsonb_build_object('schema_version','mission-retained-director-handoff/1','master_session_id',m.id,
    'parent_work_id',(retained_row.proof->>'work_id')::uuid,'parent_request',retained_row.proof->'request',
    'child_work_id',retained_row.child_id,'child_request',retained_row.proof#>'{applied,child_request}',
    'adoption_sha256',public.combat_v2_sha256(retained_row.proof->'applied'),
    'owned_by_me',retained_row.proof->>'owner_user_id'=uid::text,
    'can_resume',coalesce(active AND NOT uf_review AND m.stato='in_corso' AND r.run_phase='in_corso'
     AND retained_row.proof->>'owner_user_id'=uid::text AND retained_row.child_state='ready'
     AND retained_row.child_finalized IS NULL AND retained_row.child_receipt IS NULL AND retained_row.child_message IS NULL
     AND retained_row.child_result IS NULL AND retained_row.child_lease IS NULL AND retained_row.child_authorization IS NULL
     AND retained_row.child_dispatch IS NULL AND retained_row.child_dispatch_receipt IS NULL
     AND NOT EXISTS(SELECT 1 FROM mission_generic_owner.work_items rhother
      WHERE rhother.master_session_id=m.id AND rhother.id<>retained_row.child_id
       AND rhother.state IN('ready','claimed','authorized','provider_started','uncertain')),false));
  END IF;
 END IF;
 IF staff AND m.location_id='0b85f354-9cdb-47e1-baf9-3d266bb7e06b'::uuid
  AND EXISTS(SELECT 1 FROM public.locations rp37_loc WHERE rp37_loc.id=m.location_id AND rp37_loc.is_test)
  AND EXISTS(SELECT 1 FROM mission_generic_owner.role_window_cursors rp37_cursor WHERE rp37_cursor.master_session_id=m.id)
 THEN
  SELECT coalesce(rr37.canonical_preimage::jsonb#>'{config,c1266_role_command_v2}'=
    jsonb_build_object('schema_version','mission-role-command-policy/1','enabled',true),false)
    INTO role_command_enabled FROM mission_factory_owner.editor_release_readiness rr37
    WHERE rr37.singleton AND rr37.state='enabled' AND rr37.scope='staff';
  SELECT jsonb_build_object('schema_version','mission-role-submit-capability/2','enabled',coalesce(role_command_enabled,false),
    'contexts',coalesce(jsonb_agg(jsonb_build_object('character_id',rp37_character.character_id,
      'window_epoch',rp37_cursor.window_epoch,'own_latest_message_id',rp37_latest.message_id)
      ORDER BY rp37_character.character_id),'[]'::jsonb)) INTO role_command_capability
   FROM (SELECT DISTINCT rp37_part.character_id FROM public.master_v2_participants rp37_part
      JOIN public.characters rp37_char ON rp37_char.id=rp37_part.character_id AND rp37_char.user_id=uid
      WHERE rp37_part.session_id=m.id AND rp37_part.user_id_snapshot=uid AND rp37_part.left_at IS NULL
        AND rp37_part.engagement_state='attivo') rp37_character
   JOIN mission_generic_owner.role_window_cursors rp37_cursor ON rp37_cursor.master_session_id=m.id
   LEFT JOIN LATERAL(SELECT rp37_own.message_id FROM mission_generic_owner.role_submissions rp37_own
     WHERE rp37_own.master_session_id=m.id AND rp37_own.window_epoch=rp37_cursor.window_epoch
       AND rp37_own.user_id=uid AND rp37_own.character_id=rp37_character.character_id
     ORDER BY rp37_own.accepted_at DESC,rp37_own.message_id DESC LIMIT 1) rp37_latest ON true;
 ELSIF EXISTS(SELECT 1 FROM clan_innata_narrative_private.gate_v1 WHERE singleton AND public_enabled)
   AND EXISTS(SELECT 1 FROM mission_factory_owner.quest_run_sources q
      JOIN public.locations ql ON ql.id=q.location_id AND ql.is_active AND NOT ql.is_test AND NOT ql.is_exam_room
      WHERE q.session_id=m.id AND q.execution_context='public_real')
 THEN
   SELECT jsonb_agg(jsonb_build_object('character_id',mp.character_id,'window_epoch',cur.window_epoch,
      'own_latest_message_id',(SELECT sub.message_id FROM mission_generic_owner.role_submissions sub
        WHERE sub.master_session_id=m.id AND sub.window_epoch=cur.window_epoch
          AND sub.user_id=uid AND sub.character_id=mp.character_id
        ORDER BY sub.accepted_at DESC,sub.message_id DESC LIMIT 1)) ORDER BY mp.character_id)
   INTO role_command_capability
   FROM public.master_v2_participants mp
   JOIN mission_generic_owner.role_window_cursors cur ON cur.master_session_id=mp.session_id
   WHERE mp.session_id=m.id AND mp.user_id_snapshot=uid AND mp.left_at IS NULL AND mp.engagement_state='attivo'
     AND clan_innata_narrative_private.quest_maintained_authority_v1(m.id,mp.character_id)->>'owner_kind'='ai_service';
   IF role_command_capability IS NOT NULL THEN
    quest_command_scope:=true;
    role_command_capability:=jsonb_build_object('schema_version','mission-role-submit-capability/2',
      'enabled',true,'contexts',role_command_capability);
   END IF;
 END IF;
 IF event42_mode THEN
 IF uf_processing IS NOT NULL THEN uf_processing:=jsonb_set(uf_processing,'{request}','null'::jsonb,false);END IF;
 END IF;
  -- The named Quest uses the finite Staff tick explicitly, with no automatic claim.
  IF uid='f0856d53-83a6-4de0-bc0c-12c87916e665'::uuid AND auth.role()='authenticated'
   AND staff AND participant AND academy AND active AND NOT event42_mode AND NOT uf_review
   AND p_location='0b85f354-9cdb-47e1-baf9-3d266bb7e06b'::uuid AND m.location_id=p_location
   AND m.owner_kind='ai_service' AND m.mission_id IS NULL AND m.tipo='quest' AND m.master_user IS NULL
   AND m.stato='in_corso' AND r.run_phase='in_corso' AND r.source_kind='quest'
   AND role_diag->>'source_revision' ~ '^[0-9a-f]{64}$'
   AND role_diag->>'source_revision'=mission_generic_owner.role_source_revision_v1(m.id)
   AND EXISTS(SELECT 1 FROM mission_generic_owner.flow_staff_sessions f
     WHERE f.master_session_id=m.id AND f.enabled)
   AND EXISTS(SELECT 1 FROM mission_factory_owner.quest_run_sources q9
     WHERE q9.session_id=m.id AND q9.location_id=p_location AND q9.state='started'
     AND q9.episode_id=r.quest_episode_id AND q9.arc_id=r.quest_arc_id
     AND q9.availability_scope='staff' AND q9.execution_context='staff_simulation' AND q9.public_release_sha256 IS NULL)
   AND mission_generic_owner.quest_v8_budget_target_v1(m.id) IS TRUE
   AND mission_generic_owner.quest_v8_budget_attested_v1(m.id,true) IS TRUE
  THEN
   IF role_diag->>'flow_reason'='ready_to_evaluate' AND NOT private_pending
    AND EXISTS(SELECT 1 FROM public.mission_plan_steps ps9 WHERE ps9.plan_version_id=r.plan_version_id
      AND ps9.step_key=r.current_step_key AND ps9.kind='narrative')
    AND NOT EXISTS(SELECT 1 FROM mission_generic_owner.staff_progress_ticks_v1 tick9
      WHERE tick9.master_session_id=m.id AND tick9.source_revision=role_diag->>'source_revision')
    AND NOT EXISTS(SELECT 1 FROM mission_generic_owner.work_items work9 WHERE work9.master_session_id=m.id
      AND work9.state IN('ready','claimed','authorized','provider_started','uncertain'))
    AND NOT EXISTS(SELECT 1 FROM mission_generic_owner.unified_source_windows source9
      WHERE source9.master_session_id=m.id AND source9.consumed_message_id IS NULL AND source9.superseded_at IS NULL)
    AND NOT EXISTS(SELECT 1 FROM public.combat_v2_sessions combat9
      WHERE combat9.master_session_id=m.id AND combat9.closed_at IS NULL)
   THEN
    quest_staff_v9_kind:='initial_tick';
   ELSIF role_diag->>'flow_reason'='recoverable_not_started' AND uf_work.id::text=role_diag->>'work_id'
    AND uf_processing->>'work_id'=uf_work.id::text AND jsonb_typeof(uf_processing->'request')='object'
    AND EXISTS(
     SELECT 1 FROM mission_generic_owner.unified_batches batch9
     JOIN mission_generic_owner.unified_source_windows source9 ON source9.id=batch9.source_window_id
     JOIN mission_generic_owner.work_items director9 ON director9.id=batch9.decision_work_id
     JOIN mission_narrative_internal.dispatch_receipts receipt9 ON receipt9.id=director9.dispatch_receipt_id
     JOIN mission_generic_owner.staff_progress_ticks_v1 tick9 ON tick9.master_session_id=m.id
       AND tick9.source_revision=role_diag->>'source_revision' AND tick9.actor_user_id=uid AND tick9.staff_user_id=uid
     JOIN mission_generic_owner.progress_receipts progress9 ON progress9.request_key=tick9.request_key
       AND progress9.master_session_id=m.id AND progress9.actor_user_id=uid
       AND progress9.result_sha256=tick9.result_sha256 AND progress9.result_sha256=public.combat_v2_sha256(progress9.result)
     WHERE batch9.master_session_id=m.id AND batch9.writer_work_id=uf_work.id AND batch9.state='ready'
      AND batch9.retired_at IS NULL AND batch9.message_id IS NULL
      AND director9.master_session_id=m.id AND director9.kind='director' AND director9.state='completed'
      AND director9.finalized_at IS NOT NULL AND director9.receipt_id IS NOT NULL AND director9.result->>'ok'='true'
      AND director9.result#>>'{decision,schema_version}'='mission-director-proposal/2'
      AND director9.payload_sha256=public.combat_v2_sha256(director9.payload)
      AND progress9.result->'dispatch'=jsonb_build_object('schema_version','mission-generic-request/1',
       'master_session_id',m.id,'event_id',director9.event_id,'request_key',director9.request_key,'expected_revision',director9.revision)
      AND receipt9.authority_receipt_id=director9.id AND receipt9.master_session_id=m.id
      AND receipt9.request_key=director9.request_key AND receipt9.status='success' AND receipt9.finalized_at IS NOT NULL
      AND receipt9.event_kind='mission_generic_event' AND receipt9.renderer_version='mission-generic-runtime/1'
      AND receipt9.dispatch_count=1
      AND batch9.decision=director9.result->'decision' AND batch9.decision_sha256=public.combat_v2_sha256(batch9.decision)
      AND source9.id=director9.authority_receipt_id AND source9.master_session_id=m.id AND source9.work_id=director9.id
      AND source9.context->>'source_revision'=role_diag->>'source_revision'
      AND source9.definition_sha256=director9.definition_sha256 AND source9.source_sha256=director9.payload_sha256
      AND source9.step_key=director9.step_key AND source9.run_control_version=director9.run_control_version
      AND source9.superseded_at IS NULL AND source9.consumed_message_id IS NULL
      AND uf_work.master_session_id=m.id AND uf_work.kind='narration' AND uf_work.state='ready'
      AND uf_work.authority_receipt_id=batch9.id AND uf_work.step_key=batch9.step_key
      AND uf_work.run_control_version=batch9.run_control_version AND uf_work.definition_sha256=director9.definition_sha256
      AND uf_work.payload_sha256=batch9.payload_sha256 AND uf_work.payload_sha256=public.combat_v2_sha256(uf_work.payload)
      AND uf_work.lease_id IS NULL AND uf_work.authorization_id IS NULL AND uf_work.dispatch_id IS NULL
      AND uf_work.dispatch_receipt_id IS NULL AND uf_work.finalized_at IS NULL AND uf_work.receipt_id IS NULL
      AND uf_work.event_id<>director9.event_id AND uf_work.request_key<>director9.request_key
      AND uf_work.revision BETWEEN 1 AND 9007199254740991)
    AND NOT EXISTS(SELECT 1 FROM mission_generic_owner.work_items other9 WHERE other9.master_session_id=m.id
      AND other9.id<>uf_work.id AND other9.state IN('ready','claimed','authorized','provider_started','uncertain'))
   THEN
    quest_staff_v9_kind:='ready_work';
    quest_staff_v9_work:=uf_work.id;
   END IF;
  END IF;
 return jsonb_build_object('session_id',m.id,'step_key',coalesce(private_source_step,r.current_step_key),'objective',objective,
 'server_event_mode',CASE WHEN event42_mode THEN 'server_event_v1' ELSE NULL END,
 'server_event_status',(SELECT jsonb_build_object('event_key',es.event_key,'event_version',es.event_version,'state',es.state,
 'can_recover',coalesce(es.root_principal=uid AND active AND (EXISTS(SELECT 1 FROM mission_generic_owner.work_items eh_done
 WHERE eh_done.id=es.work_id AND eh_done.master_session_id=es.master_session_id
 AND eh_done.state='completed' AND eh_done.result->'ok'='true'::jsonb
 AND eh_done.receipt_id IS NOT NULL AND eh_done.finalized_at IS NOT NULL
 AND es.canonical_request=jsonb_build_object('schema_version','mission-generic-request/1',
 'master_session_id',eh_done.master_session_id,'event_id',eh_done.event_id,
 'request_key',eh_done.request_key,'expected_revision',eh_done.revision)
 AND (eh_done.result_sha256=public.combat_v2_sha256(eh_done.result) OR EXISTS(
 SELECT 1 FROM mission_narrative_internal.dispatch_audit hp_finalized
 WHERE hp_finalized.receipt_id=eh_done.dispatch_receipt_id AND hp_finalized.event_code='generic_finalized'
 AND hp_finalized.details->>'work_id'=eh_done.id::text
 AND hp_finalized.details->>'receipt_id'=eh_done.receipt_id::text
 AND hp_finalized.details->>'state'=eh_done.state
 AND hp_finalized.details->'message_id' IS NOT DISTINCT FROM coalesce(to_jsonb(eh_done.message_id),'null'::jsonb)
 AND hp_finalized.details->>'result_sha256'=eh_done.result_sha256
 AND hp_finalized.details->>'result_jsonb_sha256'=public.combat_v2_sha256(eh_done.result)))) OR((es.state<>'running' OR es.claim_expires_at<=clock_timestamp())
 AND (es.work_id IS NULL OR EXISTS(SELECT 1 FROM mission_generic_owner.work_items ew WHERE ew.id=es.work_id
 AND(ew.state='ready' AND ew.lease_id IS NULL OR ew.state='claimed' AND ew.lease_expires_at<=clock_timestamp() OR ew.state='failed')
 AND(((mission_generic_owner.director_incomplete_reissue_proof_v1(ew.id,uid)->'can_reissue'='true'::jsonb) IS TRUE)
 OR(mission_generic_owner.writer_count_reissue_proof_v1(ew.id,uid) IS NOT NULL)
 OR(ew.authorization_id IS NULL AND ew.dispatch_id IS NULL AND ew.result IS NULL
 AND(NOT EXISTS(SELECT 1 FROM mission_narrative_internal.dispatch_audit ea WHERE ea.receipt_id=ew.dispatch_receipt_id AND ea.event_code='c8_count_started')
  OR EXISTS(SELECT 1 FROM mission_narrative_internal.dispatch_audit ea WHERE ea.receipt_id=ew.dispatch_receipt_id AND ea.event_code='c8_count_success' AND ea.details->'generation_allowed'='true'::jsonb)))
 OR(ew.state='failed' AND((ew.kind='director' AND ew.result->'failure_codes' ? 'MISSION_PROVIDER_OUTPUT_RETENTION_FAILED')
  OR(ew.kind='narration' AND ew.result->'ok'='true'::jsonb AND ew.result->>'provider_calls'='1')))))))),false))
 FROM mission_generic_owner.event_outbox_v1 es WHERE es.master_session_id=m.id AND (
 es.state NOT IN('terminal','waiting') OR (es.state='terminal' AND es.root_principal=uid AND active AND es.work_id IS NOT NULL
 AND (mission_generic_owner.director_incomplete_reissue_proof_v1(es.work_id,uid)->'can_reissue'='true'::jsonb) IS TRUE) OR (
 -- Re-expose only the latest waiting role-window whose sole old Count blocker has a real successor publication.
 es.state='waiting' AND es.event_domain='role_window' AND es.root_principal=uid AND active AND staff AND participant
 AND es.work_id IS NULL AND es.canonical_request IS NULL
 AND NOT EXISTS(SELECT 1 FROM mission_generic_owner.event_outbox_v1 later49 WHERE later49.event_key=es.event_key AND later49.event_version>es.event_version)
 AND EXISTS(SELECT 1 FROM mission_generic_owner.role_submissions src49 JOIN mission_generic_owner.role_window_cursors cur49
  ON cur49.master_session_id=src49.master_session_id AND cur49.window_epoch=src49.window_epoch
  WHERE src49.master_session_id=m.id AND src49.message_id=es.source_id AND src49.valid
   AND public.combat_v2_sha256(to_jsonb(src49))=es.source_sha256)
 AND EXISTS(SELECT 1 FROM mission_factory_owner.editor_release_readiness rr49
  JOIN mission_generic_owner.work_items old49 ON old49.id::text=rr49.canonical_preimage::jsonb#>>'{config,c1266_writer_count_reissue46,old_work_id}'
  JOIN mission_generic_owner.manual_staff_admissions_v1 ma49 ON ma49.master_session_id=old49.master_session_id
  JOIN LATERAL(SELECT mission_generic_owner.writer_count_reissue_proof_v1(old49.id,uid) proof) solved49
   ON solved49.proof->>'schema_version'='mission-writer-count-reissue-proof/1'
    AND solved49.proof->>'old_work_id'=old49.id::text AND solved49.proof->>'master_session_id'=m.id::text
    AND solved49.proof->'published'='true'::jsonb
  WHERE rr49.singleton AND rr49.scope='staff' AND rr49.state='enabled' AND rr49.revision_sha256=rr49.observed_revision_sha256
   AND old49.master_session_id=m.id AND old49.step_key=r.current_step_key AND old49.run_control_version=r.control_version
   AND old49.state='failed' AND old49.kind='narration' AND old49.result->>'failure_code'='MISSION_INPUT_COUNT_OVERFLOW'
   AND rr49.canonical_preimage::jsonb#>>'{config,c1266_writer_count_reissue46,master_session_id}'=m.id::text
   AND rr49.canonical_preimage::jsonb#>>'{config,c1266_writer_count_reissue46,payload_sha256}'=old49.payload_sha256
   AND ma49.admission_sha256=public.combat_v2_sha256(ma49.admission)
   AND (ma49.admission#>>'{source_scope,PG_count}')::integer>0
   AND (SELECT count(DISTINCT mp49.user_id_snapshot) FROM public.master_v2_participants mp49
    JOIN public.characters ch49 ON ch49.id=mp49.character_id AND ch49.user_id=mp49.user_id_snapshot
    WHERE mp49.session_id=m.id AND mp49.left_at IS NULL AND mp49.engagement_state='attivo')=(ma49.admission#>>'{source_scope,PG_count}')::integer
   AND NOT EXISTS(SELECT 1 FROM mission_generic_owner.work_items bad49 WHERE bad49.master_session_id=m.id
    AND bad49.step_key=r.current_step_key AND bad49.run_control_version=r.control_version AND bad49.state='failed' AND bad49.id<>old49.id))
 AND NOT EXISTS(SELECT 1 FROM public.master_v2_participants mp49 JOIN public.characters ch49 ON ch49.id=mp49.character_id AND ch49.user_id=mp49.user_id_snapshot
  LEFT JOIN LATERAL(SELECT rs49.valid FROM mission_generic_owner.role_submissions rs49 JOIN mission_generic_owner.role_window_cursors cur49
   ON cur49.master_session_id=rs49.master_session_id AND cur49.window_epoch=rs49.window_epoch
   WHERE rs49.master_session_id=m.id AND rs49.user_id=mp49.user_id_snapshot AND rs49.character_id=mp49.character_id
   ORDER BY rs49.accepted_at DESC,rs49.message_id DESC LIMIT 1) own49 ON true
  WHERE mp49.session_id=m.id AND mp49.left_at IS NULL AND mp49.engagement_state='attivo' AND own49.valid IS DISTINCT FROM true)
 AND NOT EXISTS(SELECT 1 FROM mission_generic_owner.work_items pending49 WHERE pending49.master_session_id=m.id AND pending49.state IN('ready','claimed','authorized','provider_started','uncertain'))
 AND NOT EXISTS(SELECT 1 FROM mission_generic_owner.unified_source_windows pending49 WHERE pending49.master_session_id=m.id AND pending49.consumed_message_id IS NULL AND pending49.superseded_at IS NULL)
 AND NOT EXISTS(SELECT 1 FROM mission_generic_owner.unified_batches pending49 WHERE pending49.master_session_id=m.id AND pending49.retired_at IS NULL AND pending49.state IN('preparing','ready'))
 AND NOT EXISTS(SELECT 1 FROM public.combat_v2_sessions combat49 WHERE combat49.master_session_id=m.id AND combat49.state<>'chiuso')
 ))
 -- Event43: only causally consumed native inputs in the qualified Staff path.
 AND NOT COALESCE((
 es.event_domain='native_input' AND es.state IN('pending','uncertain')
 AND EXISTS(SELECT 1 FROM public.locations event43_place WHERE event43_place.id=m.location_id
  AND event43_place.is_active AND event43_place.is_test)
 AND EXISTS(SELECT 1 FROM mission_factory_owner.editor_release_readiness event43_release
  WHERE event43_release.singleton AND event43_release.state='enabled' AND event43_release.scope='staff'
  AND event43_release.revision_sha256=event43_release.observed_revision_sha256
  AND event43_release.canonical_preimage::jsonb#>>'{config,c1266_server_events,schema_version}'='c1266-server-events/1'
  AND event43_release.canonical_preimage::jsonb#>'{config,c1266_server_events,enabled}'='true'::jsonb)
 AND EXISTS(SELECT 1 FROM public.profiles event43_actor
  WHERE event43_actor.id=es.root_principal AND event43_actor.role IN('admin','master'))
 AND EXISTS(SELECT 1 FROM mission_generic_owner.start_claims event43_start
  JOIN mission_generic_owner.board_starts event43_board ON event43_board.request_key=event43_start.request_key
  WHERE event43_start.request_key=es.root_request_key AND event43_start.actor_user_id=es.root_principal
  AND event43_start.session_id=es.master_session_id AND event43_board.master_session_id=es.master_session_id
  AND public.combat_v2_sha256(event43_board.result)=es.root_receipt_sha256)
 AND EXISTS(
 WITH event43_sources AS MATERIALIZED (SELECT src.round_id,src.declaration_id,src.coverage_id,src.source_kind
 FROM (
 SELECT dc.round_id,dc.defense_declaration_id AS declaration_id,dc.id AS coverage_id,'coverage'::text AS source_kind
 FROM public.combat_v2_defense_coverages dc
 JOIN public.combat_v2_declarations dd ON dd.id=dc.defense_declaration_id AND dd.round_id=dc.round_id
 JOIN public.combat_v2_actors aa ON aa.id=dd.actor_id AND aa.actor_kind='pg'
 WHERE dc.id=es.source_id AND es.source_sha256 IN(
 public.combat_v2_sha256(to_jsonb(dc)),
 public.combat_v2_sha256(jsonb_set(to_jsonb(dc),'{state}','"dichiarata"'::jsonb)))
 UNION ALL
 SELECT rt.round_id,rt.declaration_id,NULL::uuid,'rating'::text
 FROM public.combat_v2_ratings rt
 JOIN public.combat_v2_declarations dd ON dd.id=rt.declaration_id AND dd.round_id=rt.round_id
 WHERE rt.id=es.source_id AND rt.is_active
 AND es.source_sha256 IN(public.combat_v2_sha256(to_jsonb(rt)),
 public.combat_v2_sha256(jsonb_set(to_jsonb(rt),'{frozen_at}','null'::jsonb)))
 UNION ALL
 SELECT dd.round_id,dd.id,NULL::uuid,'declaration'::text
 FROM public.combat_v2_declarations dd JOIN public.combat_v2_actors aa ON aa.id=dd.actor_id AND aa.actor_kind='pg'
 WHERE dd.id=es.source_id AND es.source_sha256=public.combat_v2_sha256(to_jsonb(dd))
 ) src)
 SELECT 1 FROM event43_sources event43_src
 JOIN public.combat_v2_rounds event43_round ON event43_round.id=event43_src.round_id
 JOIN public.combat_v2_round_reports event43_report
  ON event43_report.id=event43_round.report_id AND event43_report.round_id=event43_round.id
 JOIN public.combat_v2_sessions event43_enc ON event43_enc.id=event43_round.session_id
  AND event43_enc.master_session_id=es.master_session_id AND event43_enc.location_id=m.location_id
 JOIN mission_generic_owner.unified_batches event43_batch
  ON event43_batch.master_session_id=es.master_session_id AND event43_batch.encounter_id=event43_enc.id
  AND event43_batch.source_round_id=event43_round.id AND event43_batch.source_report_id=event43_report.id
 JOIN mission_generic_owner.work_items event43_w ON event43_w.id=event43_batch.writer_work_id
  AND event43_w.event_id=event43_batch.id AND event43_w.authority_receipt_id=event43_batch.id
  AND event43_w.master_session_id=es.master_session_id AND event43_w.encounter_id=event43_enc.id
 JOIN public.messages event43_msg ON event43_msg.id=event43_w.message_id AND event43_msg.location_id=m.location_id
 WHERE (SELECT count(*) FROM event43_sources)=1
 AND es.event_key=mission_ai_service_owner.uuid5(event43_round.id,'server-event:native-input')
 AND es.created_at<=event43_batch.created_at
 AND ((es.work_id IS NULL AND es.canonical_request IS NULL) OR (es.work_id=event43_w.id
  AND es.canonical_request=jsonb_build_object('schema_version','mission-generic-request/1',
  'master_session_id',event43_w.master_session_id,'event_id',event43_w.event_id,
  'request_key',event43_w.request_key,'expected_revision',event43_w.revision)))
 AND event43_w.kind='narration' AND event43_w.state='completed' AND event43_w.result->'ok'='true'::jsonb
 AND event43_w.receipt_id IS NOT NULL AND event43_w.finalized_at IS NOT NULL
 AND event43_batch.state='published' AND event43_batch.published_at IS NOT NULL AND event43_batch.retired_at IS NULL
 AND event43_report.narration_state='pubblicata' AND event43_report.message_id=event43_msg.id
 AND event43_batch.message_id=event43_msg.id AND event43_msg.kind='fato' AND event43_msg.recipient_user IS NULL
 AND event43_report.mechanics_sha256=public.combat_v2_sha256(event43_report.mechanics)
 AND EXISTS(SELECT 1 FROM jsonb_array_elements(event43_report.mechanics->'declarations') event43_dec
  WHERE event43_dec->>'id'=event43_src.declaration_id::text)
 AND (event43_src.coverage_id IS NULL OR EXISTS(
  SELECT 1 FROM jsonb_array_elements(event43_report.mechanics->'defense_coverages') event43_cov
  WHERE event43_cov->>'id'=event43_src.coverage_id::text))
 AND EXISTS(SELECT 1 FROM mission_generic_owner.event_outbox_v1 event43_done
  WHERE event43_done.master_session_id=es.master_session_id AND event43_done.event_key=es.event_key
  AND event43_done.event_domain='native_input' AND event43_done.state='terminal'
  AND event43_done.root_event_key=es.root_event_key AND event43_done.root_event_version=es.root_event_version
  AND event43_done.root_request_key=es.root_request_key AND event43_done.root_principal=es.root_principal
  AND event43_done.root_receipt_sha256=es.root_receipt_sha256
  AND event43_done.work_id=event43_w.id
  AND event43_done.canonical_request=jsonb_build_object('schema_version','mission-generic-request/1',
  'master_session_id',event43_w.master_session_id,'event_id',event43_w.event_id,
  'request_key',event43_w.request_key,'expected_revision',event43_w.revision))
 AND (event43_w.result_sha256=public.combat_v2_sha256(event43_w.result) OR EXISTS(
  SELECT 1 FROM mission_narrative_internal.dispatch_audit event43_final
  WHERE event43_final.receipt_id=event43_w.dispatch_receipt_id AND event43_final.event_code='generic_finalized'
  AND event43_final.details->>'work_id'=event43_w.id::text
  AND event43_final.details->>'receipt_id'=event43_w.receipt_id::text
  AND event43_final.details->>'state'=event43_w.state
  AND event43_final.details->'message_id'=to_jsonb(event43_msg.id)
  AND event43_final.details->>'result_sha256'=event43_w.result_sha256
  AND event43_final.details->>'result_jsonb_sha256'=public.combat_v2_sha256(event43_w.result)))
 )
 ),FALSE)

 ORDER BY es.created_at DESC,es.event_key DESC,es.event_version DESC LIMIT 1),
 'retained_director_handoff',retained_handoff,'combat_narration_recovery',combat_recovery,'staff_finish',mission_generic_owner.staff_finish_status_v1(m.id,uid),'processing',uf_processing,'progress_key',uf_progress_key,'review_required',uf_review,
 'flow_state',flow_state,'flow_publication_id',flow_publication,
 'choices',case when uf_review or academy then '[]'::jsonb else vchoices->'choices' end,
 'choice_context',vchoices-'choices','state',m.stato,'can_tick',active and not uf_review AND NOT event42_mode
    and m.id<>'b70b23cf-bad8-475d-a56a-d9c549e35d84'::uuid,
 'request',case when active and not uf_review AND NOT event42_mode
    and m.id<>'b70b23cf-bad8-475d-a56a-d9c549e35d84'::uuid and not exists(
    select 1 from mission_generic_owner.role_window_cursors c where c.master_session_id=m.id)
    then jsonb_build_object('schema_version','mission-generic-tick/1','master_session_id',m.id) else null end)||coalesce(role_diag,'{}'::jsonb)||CASE WHEN staff_tick_view IS NOT NULL THEN jsonb_build_object('staff_tick_status',staff_tick_view) ELSE '{}'::jsonb END||CASE WHEN c26_driver IS NOT NULL THEN jsonb_build_object('driver_state',c26_driver) ELSE '{}'::jsonb END||CASE WHEN c26_count_view IS NOT NULL THEN jsonb_build_object('count_reconciliation',c26_count_view) ELSE '{}'::jsonb END||CASE WHEN opening_resume49 IS NOT NULL THEN jsonb_build_object('opening_ready_resume',opening_resume49) ELSE '{}'::jsonb END||CASE WHEN opening_claim_resume6 IS NOT NULL THEN jsonb_build_object('opening_claim_resume',opening_claim_resume6) ELSE '{}'::jsonb END||CASE WHEN journal_settlements IS NOT NULL THEN jsonb_build_object('journal_settlements',journal_settlements) ELSE '{}'::jsonb END||CASE WHEN role_command_capability IS NOT NULL THEN jsonb_build_object('role_submit_capability',role_command_capability) ELSE '{}'::jsonb END||CASE WHEN quest_command_scope THEN jsonb_build_object('quest_role_authority','quest-native-role/1') ELSE '{}'::jsonb END||CASE WHEN public56 IS NOT NULL THEN jsonb_build_object('narrative_scene',public56,'combat_surface',surface56) ELSE '{}'::jsonb END
  ||CASE WHEN quest_staff_v9_kind IS NOT NULL THEN jsonb_build_object('quest_staff_v9_progress',
    jsonb_build_object('schema_version','quest-staff-v9-progress/1','session_id',m.id,
      'location_id',m.location_id,'episode_id',r.quest_episode_id,'source_revision',role_diag->>'source_revision',
      'kind',quest_staff_v9_kind,'work_id',quest_staff_v9_work)) ELSE '{}'::jsonb END;
 end;
$function$;

CREATE OR REPLACE FUNCTION public.mission_generic_event_next_v1(p_event_key uuid, p_event_version bigint, p_claim_id uuid)
 RETURNS jsonb
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO ''
 SET statement_timeout TO '20s'
AS $function$
DECLARE scene56_entry_progress jsonb;scene56_runtime mission_narrative_internal.scene_runtime_v1;scene56_prepared jsonb;
 e mission_generic_owner.event_outbox_v1;cfg jsonb;progress jsonb;candidate jsonb;flow jsonb;writer46 jsonb;
 event43_observed_work uuid:=NULL;event43_observed_request jsonb:=NULL;
 writer48_source_work mission_generic_owner.work_items;writer48_terminal_event mission_generic_owner.event_outbox_v1;
 writer48_source_request jsonb;writer48_event_after jsonb;writer48_child_request jsonb:=NULL;writer48_child_id uuid:=NULL;
 w mission_generic_owner.work_items;req uuid;outcome text;native_claim jsonb;role_source_user uuid;native_mode text;paid_action boolean:=false;
BEGIN
 PERFORM mission_ai_board_owner.service_only();
 PERFORM pg_advisory_xact_lock_shared(hashtextextended('C1266:GENERIC-AI:AVAILABILITY',0));
 SELECT * INTO e FROM mission_generic_owner.event_outbox_v1 WHERE event_key=p_event_key AND event_version=p_event_version FOR UPDATE;
 IF NOT FOUND OR e.claim_id IS DISTINCT FROM p_claim_id OR p_claim_id IS NULL OR e.claimed_at IS NULL
 THEN RAISE EXCEPTION 'EVENT42_CLAIM_REJECTED' USING ERRCODE='42501'; END IF;
 IF e.next_result IS NOT NULL THEN RETURN jsonb_set(jsonb_set(jsonb_set(e.next_result,'{state}','"uncertain"'::jsonb),'{request}','null'::jsonb),'{native_claim}','null'::jsonb); END IF;
 IF e.state<>'running' OR e.claim_expires_at<=clock_timestamp() THEN RAISE EXCEPTION 'EVENT42_CLAIM_EXPIRED' USING ERRCODE='42501';END IF;
 SELECT rr.canonical_preimage::jsonb#>'{config,c1266_server_events}' INTO cfg
 FROM mission_factory_owner.editor_release_readiness rr
 WHERE rr.singleton AND rr.state='enabled' AND rr.scope='staff' AND rr.staff_guards_verified AND rr.published_assets_verified
 AND rr.revision_sha256=rr.observed_revision_sha256;
 IF cfg->>'schema_version' IS DISTINCT FROM 'c1266-server-events/1'
 OR cfg->'enabled' IS DISTINCT FROM 'true'::jsonb THEN
 RAISE EXCEPTION 'EVENT42_MODE_DISABLED' USING ERRCODE='42501'; END IF;

 IF EXISTS(SELECT 1 FROM mission_public_owner.session_admissions_v1 s87_ad WHERE s87_ad.master_session_id=e.master_session_id AND mission_public_owner.c1266_regia_public_qualification_v1(s87_ad.mission_id,s87_ad.release_sha256,false)->>'schema_version'='mission-scene-public-qualification/1' AND mission_public_owner.role_session_allowed_v1(s87_ad.master_session_id)) THEN
 IF NOT EXISTS(SELECT 1 FROM public.master_v2_sessions ms87 JOIN public.locations l87 ON l87.id=ms87.location_id WHERE ms87.id=e.master_session_id AND ms87.owner_kind='ai_service' AND ms87.master_user IS NULL AND l87.is_active AND NOT l87.is_test AND NOT l87.is_exam_room) OR NOT EXISTS(SELECT 1 FROM public.master_v2_participants mp87 JOIN public.characters ch87 ON ch87.id=mp87.character_id AND ch87.user_id=mp87.user_id_snapshot WHERE mp87.session_id=e.master_session_id AND mp87.user_id_snapshot=e.root_principal) OR NOT EXISTS(SELECT 1 FROM mission_generic_owner.start_claims sc87 JOIN mission_generic_owner.board_starts bs87 ON bs87.request_key=sc87.request_key JOIN mission_public_owner.session_admissions_v1 ad87 ON ad87.master_session_id=sc87.session_id AND ad87.start_request=sc87.request_key WHERE sc87.request_key=e.root_request_key AND sc87.actor_user_id=e.root_principal AND sc87.session_id=e.master_session_id AND bs87.master_session_id=e.master_session_id AND NOT bs87.simulation AND public.combat_v2_sha256(bs87.result)=e.root_receipt_sha256) THEN RAISE EXCEPTION 'SCENE87_EVENT_NEXT_WORLD_SCOPE' USING ERRCODE='42501';END IF;
 ELSE
 IF NOT EXISTS(SELECT 1 FROM public.master_v2_sessions m JOIN public.locations l ON l.id=m.location_id
 WHERE m.id=e.master_session_id AND m.owner_kind='ai_service' AND m.master_user IS NULL
 AND m.closed_at IS NULL AND m.suspended_at IS NULL AND m.stato IN('preparazione','in_corso')
 AND l.id='0b85f354-9cdb-47e1-baf9-3d266bb7e06b'::uuid AND l.is_test AND l.is_active)
 OR NOT EXISTS(SELECT 1 FROM public.profiles p WHERE p.id=e.root_principal AND p.role IN('admin','master'))
 OR NOT EXISTS(SELECT 1 FROM mission_generic_owner.start_claims sc
 JOIN mission_generic_owner.board_starts bs ON bs.request_key=sc.request_key
 WHERE sc.request_key=e.root_request_key AND sc.actor_user_id=e.root_principal
 AND sc.session_id=e.master_session_id AND bs.master_session_id=e.master_session_id
 AND public.combat_v2_sha256(bs.result)=e.root_receipt_sha256)
 OR mission_generic_owner.manual_staff_scope_v1(e.master_session_id) IS NULL
 THEN RAISE EXCEPTION 'EVENT42_SCOPE_REJECTED' USING ERRCODE='42501'; END IF;
 END IF;


 IF EXISTS(SELECT 1 FROM mission_narrative_internal.scene_runtime_v1 WHERE master_session_id=e.master_session_id AND is_active) THEN
  PERFORM 1 FROM public.locations WHERE id=(SELECT location_id FROM public.master_v2_sessions WHERE id=e.master_session_id) FOR UPDATE;
 END IF;
 PERFORM 1 FROM mission_generic_owner.role_window_cursors WHERE master_session_id=e.master_session_id FOR UPDATE;
 -- New Scene lanes retain service/cfg/root/principal scope above and take their own
 -- cursor→scene→master/run locks. Do not enter legacy progression for narrative.
 SELECT * INTO scene56_runtime FROM mission_narrative_internal.scene_runtime_v1 WHERE master_session_id=e.master_session_id AND is_active;
 IF FOUND THEN
  scene56_entry_progress:=mission_narrative_internal.scene_player_entry_event_v1(p_event_key,p_event_version,p_claim_id);
  IF scene56_entry_progress IS NOT NULL THEN
   UPDATE mission_generic_owner.event_outbox_v1 SET next_result=scene56_entry_progress,updated_at=clock_timestamp()
    WHERE event_key=p_event_key AND event_version=p_event_version;
   RETURN scene56_entry_progress;
  END IF;
  IF scene56_runtime.mode IN('narrative','closed','combat_pending') THEN
   outcome:='waiting';candidate:=NULL;native_claim:=NULL;
   IF scene56_runtime.mode='narrative' AND e.event_domain IN('start','role_window') THEN
    IF e.event_domain='role_window' AND NOT EXISTS(SELECT 1 FROM mission_generic_owner.role_submissions sub
     JOIN mission_generic_owner.role_window_cursors cur ON cur.master_session_id=sub.master_session_id AND cur.window_epoch=sub.window_epoch
     WHERE sub.master_session_id=e.master_session_id AND sub.message_id=e.source_id
      AND public.combat_v2_sha256(to_jsonb(sub))=e.source_sha256) THEN
     RAISE EXCEPTION 'SCENE56_ROLE_EVENT_SOURCE' USING ERRCODE='42501';END IF;
    IF e.event_domain='start' THEN
     SELECT wi.* INTO w FROM mission_generic_owner.work_items wi JOIN mission_narrative_internal.scene_sources_v1 src ON src.work_id=wi.id
      WHERE src.scene_id=scene56_runtime.id AND src.request_kind='initial_opening' AND src.retired_at IS NULL;
    ELSE
     scene56_prepared:=mission_narrative_internal.scene_prepare_v1(e.master_session_id,e.root_principal,
      mission_ai_service_owner.uuid5(e.event_key,'server-event/1:'||e.event_version::text));
     IF scene56_prepared->>'work_id' IS NOT NULL THEN
      SELECT * INTO STRICT w FROM mission_generic_owner.work_items WHERE id=(scene56_prepared->>'work_id')::uuid;
     END IF;
    END IF;
    IF w.id IS NOT NULL THEN
     candidate:=jsonb_build_object('schema_version','mission-generic-request/1','master_session_id',w.master_session_id,
      'event_id',w.event_id,'request_key',w.request_key,'expected_revision',w.revision);
     IF e.work_id IS NOT NULL AND (e.work_id IS DISTINCT FROM w.id OR e.canonical_request IS DISTINCT FROM candidate) THEN
      RAISE EXCEPTION 'SCENE56_EVENT_WORK_REBIND_FORBIDDEN' USING ERRCODE='42501';END IF;
     IF (w.state='ready' AND w.lease_id IS NULL OR (
      w.state='claimed' AND w.lease_expires_at<=clock_timestamp()
      AND w.authorization_id IS NULL AND w.dispatch_id IS NULL AND w.result IS NULL AND w.receipt_id IS NULL
      AND (NOT EXISTS(SELECT 1 FROM mission_narrative_internal.dispatch_audit sc11_a WHERE sc11_a.receipt_id=w.dispatch_receipt_id AND sc11_a.event_code='c8_count_started') OR (EXISTS(SELECT 1 FROM mission_narrative_internal.dispatch_audit cache14_pf WHERE cache14_pf.receipt_id=w.dispatch_receipt_id
 AND cache14_pf.event_code='c8_count_success'AND cache14_pf.details->'generation_allowed'='true'::jsonb
 AND cache14_pf.details->'count_http_calls'='1'::jsonb AND cache14_pf.details->'generation_http_calls'='0'::jsonb)
 AND w.kind='narration'AND w.payload->>'schema_version'='mission-narrative-scene/1'
 AND(mission_public_owner.work_contract_v1(w.id))->>'schema_version'='mission-narrative-admission/4'
 AND(mission_public_owner.work_contract_v1(w.id))->>'scope'='staff_mission'
 AND (SELECT count(*) FROM mission_narrative_internal.dispatch_audit cache14_h WHERE cache14_h.receipt_id=w.dispatch_receipt_id AND cache14_h.event_code='manual_counted_resume_v1')<2))
      AND NOT EXISTS(SELECT 1 FROM mission_narrative_internal.provider_authorizations sc11_pa WHERE sc11_pa.receipt_id=w.dispatch_receipt_id)
      AND NOT EXISTS(SELECT 1 FROM mission_narrative_internal.dispatch_attempts sc11_da WHERE sc11_da.receipt_id=w.dispatch_receipt_id)
      AND EXISTS(SELECT 1 FROM public.master_v2_sessions sc11_s JOIN public.locations sc11_l ON sc11_l.id=sc11_s.location_id
       WHERE sc11_s.id=w.master_session_id AND sc11_s.owner_kind='ai_service' AND sc11_s.master_user IS NULL
        AND sc11_s.closed_at IS NULL AND sc11_s.suspended_at IS NULL
        AND sc11_l.id='0b85f354-9cdb-47e1-baf9-3d266bb7e06b'::uuid AND sc11_l.is_active AND sc11_l.is_test)
      AND mission_generic_owner.manual_staff_scope_v1(w.master_session_id)IS NOT NULL)) THEN
      -- The unchanged dispatcher requires this current-transaction event permit.
      -- Bind only the locked current claim and never overwrite a partial/different pair.
      UPDATE mission_generic_owner.event_outbox_v1 bound_event
       SET work_id=w.id,canonical_request=candidate,claim_txid=txid_current(),claim_backend=pg_backend_pid(),
        updated_at=clock_timestamp()
       WHERE bound_event.event_key=e.event_key AND bound_event.event_version=e.event_version
        AND bound_event.master_session_id=e.master_session_id AND bound_event.master_session_id=w.master_session_id
        AND bound_event.claim_id=p_claim_id AND bound_event.claim_id=e.claim_id
        AND bound_event.state='running' AND bound_event.claim_expires_at>clock_timestamp()
        AND bound_event.root_principal=e.root_principal AND bound_event.root_request_key=e.root_request_key
        AND bound_event.root_receipt_sha256=e.root_receipt_sha256
        AND ((bound_event.work_id IS NULL AND bound_event.canonical_request IS NULL)
         OR (bound_event.work_id=w.id AND bound_event.canonical_request=candidate))
       RETURNING bound_event.* INTO e;
      IF NOT FOUND THEN RAISE EXCEPTION 'SCENE56_EVENT_BIND_CAS_CONFLICT' USING ERRCODE='PT409';END IF;
      IF (EXISTS(SELECT 1 FROM mission_narrative_internal.dispatch_audit cache14_pf WHERE cache14_pf.receipt_id=w.dispatch_receipt_id
 AND cache14_pf.event_code='c8_count_success'AND cache14_pf.details->'generation_allowed'='true'::jsonb
 AND cache14_pf.details->'count_http_calls'='1'::jsonb AND cache14_pf.details->'generation_http_calls'='0'::jsonb)
 AND w.kind='narration'AND w.payload->>'schema_version'='mission-narrative-scene/1'
 AND(mission_public_owner.work_contract_v1(w.id))->>'schema_version'='mission-narrative-admission/4'
 AND(mission_public_owner.work_contract_v1(w.id))->>'scope'='staff_mission'
 AND (SELECT count(*) FROM mission_narrative_internal.dispatch_audit cache14_h WHERE cache14_h.receipt_id=w.dispatch_receipt_id AND cache14_h.event_code='manual_counted_resume_v1')<2) THEN
       native_claim:=public.mission_generic_counted_resume_v1(e.root_principal,candidate);native_mode:='counted_resume';
      ELSE
      native_claim:=public.mission_generic_dispatch_claim_v1(e.root_principal,candidate);native_mode:='normal';
      END IF;
      IF native_claim->>'state'='claimed' AND native_claim->'granted_now'='true'::jsonb THEN
       native_claim:=jsonb_build_object('mode',native_mode,'body',native_claim);outcome:='dispatch';
      ELSE outcome:='uncertain';candidate:=NULL;native_claim:=NULL;END IF;
     ELSIF e.recovery_request_key IS NOT NULL
      AND mission_generic_owner.staff_paid_scene_recovery_allowed_v1(e.master_session_id,w.id,e.root_principal) IS TRUE THEN
      native_claim:=jsonb_build_object('mode','cached_publication','body',jsonb_build_object(
        'schema_version','mission-generic-staff-cached-publication/1','master_session_id',w.master_session_id,'work_id',w.id));
      outcome:='dispatch';
     ELSIF w.state IN('claimed','authorized','provider_started','failed') THEN
      outcome:='uncertain';candidate:=NULL;
     ELSE outcome:='waiting';candidate:=NULL;END IF;
    END IF;
   END IF;
   progress:=jsonb_build_object('schema_version','mission-event-next/1','event_key',e.event_key,'event_version',e.event_version,
    'claim_id',e.claim_id,'master_session_id',e.master_session_id,'state',outcome,'request',candidate,'native_claim',native_claim);
   UPDATE mission_generic_owner.event_outbox_v1 SET next_result=jsonb_set(progress,'{native_claim}','null'::jsonb),
    native_claim_sha256=CASE WHEN native_claim IS NOT NULL THEN public.combat_v2_sha256(native_claim) ELSE native_claim_sha256 END,
    work_id=CASE WHEN outcome='dispatch' THEN w.id ELSE work_id END,
    canonical_request=CASE WHEN outcome='dispatch' THEN candidate ELSE canonical_request END,updated_at=clock_timestamp()
    WHERE event_key=e.event_key AND event_version=e.event_version;
   RETURN progress;
  END IF;
 END IF;
 PERFORM public.master_v2_lock_scope(e.master_session_id);
 IF EXISTS(SELECT 1 FROM public.mission_run_state r WHERE r.master_session_id=e.master_session_id AND r.run_phase NOT IN('preparazione','in_corso'))
 OR EXISTS(SELECT 1 FROM mission_generic_owner.unified_batches b WHERE b.master_session_id=e.master_session_id AND b.state='needs_review') THEN
 outcome:='waiting';
 ELSE
 IF EXISTS(SELECT 1 FROM mission_generic_owner.event_outbox_v1 newer WHERE newer.event_key=e.event_key AND newer.event_version>e.event_version) THEN outcome:='waiting';END IF;
 IF e.event_domain='role_window' THEN
 IF NOT EXISTS(SELECT 1 FROM mission_generic_owner.role_submissions c JOIN mission_generic_owner.role_window_cursors rc
 ON rc.master_session_id=c.master_session_id AND rc.window_epoch=c.window_epoch
 WHERE c.master_session_id=e.master_session_id AND c.message_id=e.source_id
 AND public.combat_v2_sha256(to_jsonb(c))=e.source_sha256) THEN outcome:='waiting';END IF;
 SELECT user_id INTO role_source_user FROM mission_generic_owner.role_submissions WHERE master_session_id=e.master_session_id AND message_id=e.source_id;
 IF e.work_id IS NULL THEN flow:=mission_generic_owner.role_flow_status_v1(e.master_session_id,role_source_user); ELSE flow:=jsonb_build_object('flow_reason','ready_to_evaluate');END IF;
 IF flow->>'flow_reason' IS DISTINCT FROM 'ready_to_evaluate' THEN outcome:='waiting';END IF;
 END IF;
 IF e.event_domain='phase' AND NOT EXISTS(SELECT 1 FROM public.mission_run_state fresh
 WHERE fresh.master_session_id=e.master_session_id AND fresh.control_version=e.event_version
 AND public.combat_v2_sha256(jsonb_build_object('step',fresh.current_step_key,'control',fresh.control_version,'plan',fresh.plan_sha256))=e.source_sha256) THEN outcome:='waiting';END IF;
 IF outcome IS NULL THEN
 req:=mission_ai_service_owner.uuid5(e.event_key,'server-event/1:'||e.event_version::text);
 -- A writer_ready event caused by this exact reissue observes its own source child, including after publication.
 -- It never uses an unrelated current work or invokes progression to manufacture another turn.
 IF e.event_domain='writer_ready' AND e.work_id IS NULL AND e.canonical_request IS NULL THEN
 SELECT cw.id,jsonb_build_object('schema_version','mission-generic-request/1','master_session_id',cw.master_session_id,
  'event_id',cw.event_id,'request_key',cw.request_key,'expected_revision',cw.revision)
 INTO writer48_child_id,writer48_child_request
 FROM mission_generic_owner.work_items cw JOIN mission_narrative_internal.dispatch_audit ca
  ON ca.details->>'successor_work_id'=cw.id::text AND ca.event_code='staff_writer_count_overflow_reissued_v1'
 JOIN LATERAL(SELECT mission_generic_owner.writer_count_reissue_proof_v1((ca.details->>'old_work_id')::uuid,NULL) proof) lp
  ON lp.proof->>'successor_work_id'=cw.id::text AND lp.proof->>'master_session_id'=cw.master_session_id::text
 WHERE cw.id=e.source_id AND cw.master_session_id=e.master_session_id AND cw.payload_sha256=e.source_sha256
  AND cw.kind='narration' AND ca.details->>'owner_user_id'=e.root_principal::text;
 END IF;
 -- Existing producer owns every wait/choice/report/transition rule. No client booleans.
 IF writer48_child_request IS NOT NULL THEN candidate:=writer48_child_request;
 ELSIF e.work_id IS NOT NULL AND e.canonical_request IS NOT NULL THEN
 candidate:=e.canonical_request;
 ELSE
 candidate:=public.mission_generic_dispatch_next_v1(e.master_session_id,e.root_principal)->'request';
 IF candidate IS NULL OR candidate='null'::jsonb THEN
 candidate:=NULL;progress:=mission_generic_owner.progress_step(e.master_session_id,e.root_principal,req);
 END IF;
 END IF;
 IF candidate IS NULL THEN candidate:=progress->'dispatch';END IF;
 IF candidate IS NULL OR candidate='null'::jsonb THEN
 candidate:=public.mission_generic_dispatch_next_v1(e.master_session_id,e.root_principal)->'request';
 END IF;
 IF candidate IS NOT NULL AND candidate<>'null'::jsonb THEN
 IF NOT mission_factory_owner.keys_exact_v2(candidate,ARRAY['schema_version','master_session_id','event_id','request_key','expected_revision'])
 OR candidate->>'schema_version'<>'mission-generic-request/1' OR candidate->>'master_session_id'<>e.master_session_id::text THEN
 RAISE EXCEPTION 'EVENT42_REQUEST_REJECTED' USING ERRCODE='42501';END IF;
 SELECT * INTO STRICT w FROM mission_generic_owner.work_items WHERE master_session_id=e.master_session_id
 AND event_id=(candidate->>'event_id')::uuid AND request_key=(candidate->>'request_key')::uuid
 AND revision=(candidate->>'expected_revision')::integer;
 IF e.recovery_request_key IS NOT NULL AND (mission_generic_owner.director_incomplete_reissue_proof_v1(w.id,e.root_principal)->'can_reissue'='true'::jsonb) IS TRUE THEN
 writer48_source_work:=w;writer48_source_request:=candidate;
 IF e.work_id IS DISTINCT FROM w.id OR e.canonical_request IS DISTINCT FROM candidate OR e.settle_result IS NOT NULL THEN
  RAISE EXCEPTION 'EVENT50_REISSUE_SOURCE_DRIFT' USING ERRCODE='42501';END IF;
 writer46:=mission_generic_owner.director_incomplete_reissue_v1(w.id,e.root_principal);candidate:=writer46->'request';
 IF writer46->>'schema_version' IS DISTINCT FROM 'mission-director-incomplete-reissue-result/1'
 OR NOT mission_factory_owner.keys_exact_v2(candidate,ARRAY['schema_version','master_session_id','event_id','request_key','expected_revision'])
 OR candidate->>'schema_version' IS DISTINCT FROM 'mission-generic-request/1' OR candidate->>'master_session_id' IS DISTINCT FROM e.master_session_id::text
 THEN RAISE EXCEPTION 'EVENT50_REISSUE_REQUEST' USING ERRCODE='42501';END IF;
 SELECT * INTO STRICT w FROM mission_generic_owner.work_items WHERE id=(writer46->>'successor_work_id')::uuid
  AND master_session_id=e.master_session_id AND event_id=(candidate->>'event_id')::uuid
  AND request_key=(candidate->>'request_key')::uuid AND revision=(candidate->>'expected_revision')::bigint;
 UPDATE mission_generic_owner.event_outbox_v1 ev50 SET work_id=w.id,canonical_request=candidate,
 claim_txid=txid_current(),claim_backend=pg_backend_pid(),updated_at=clock_timestamp()
 WHERE ev50.event_key=e.event_key AND ev50.event_version=e.event_version AND to_jsonb(ev50)=to_jsonb(e)
  AND ev50.state='running' AND ev50.claim_id=p_claim_id AND ev50.claim_expires_at>clock_timestamp()
 RETURNING to_jsonb(ev50) INTO writer48_event_after;
 IF NOT FOUND THEN RAISE EXCEPTION 'EVENT50_REISSUE_FENCE_CAS' USING ERRCODE='40001';END IF;
 INSERT INTO mission_narrative_internal.dispatch_audit(receipt_id,event_code,details)
 VALUES(writer48_source_work.dispatch_receipt_id,'staff_director_incomplete_event_rebound_v1',jsonb_build_object(
  'schema_version','mission-director-incomplete-event-rebind/1','event_key',e.event_key,'event_version',e.event_version,
  'claim_id',e.claim_id,'recovery_request_key',e.recovery_request_key,'root_principal',e.root_principal,
  'old_work_id',writer48_source_work.id,'old_request_sha256',public.combat_v2_sha256(writer48_source_request),
  'successor_work_id',w.id,'successor_request_sha256',public.combat_v2_sha256(candidate),
  'reissue_audit_sha256',writer46->>'audit_sha256','source_event_snapshot',to_jsonb(e),
  'source_event_sha256',public.combat_v2_sha256(to_jsonb(e)),'rebound_event_sha256',public.combat_v2_sha256(writer48_event_after)));
 native_claim:=public.mission_generic_dispatch_claim_v1(e.root_principal,candidate);native_mode:='normal';
 ELSIF e.recovery_request_key IS NOT NULL AND mission_generic_owner.writer_count_reissue_proof_v1(w.id,e.root_principal) IS NOT NULL THEN
 writer48_source_work:=w;writer48_source_request:=candidate;
 IF e.work_id IS DISTINCT FROM w.id OR e.canonical_request IS DISTINCT FROM candidate OR e.settle_result IS NOT NULL THEN
  RAISE EXCEPTION 'EVENT48_REISSUE_SOURCE_DRIFT' USING ERRCODE='42501';END IF;
 writer46:=mission_generic_owner.writer_count_reissue_v1(w.id,e.root_principal);candidate:=writer46->'request';
 IF writer46->>'schema_version' IS DISTINCT FROM 'mission-writer-count-reissue-result/1'
 OR NOT mission_factory_owner.keys_exact_v2(candidate,ARRAY['schema_version','master_session_id','event_id','request_key','expected_revision'])
 OR candidate->>'schema_version' IS DISTINCT FROM 'mission-generic-request/1' OR candidate->>'master_session_id' IS DISTINCT FROM e.master_session_id::text
 THEN RAISE EXCEPTION 'EVENT46_WRITER_REISSUE_REJECTED' USING ERRCODE='42501';END IF;
 SELECT * INTO STRICT w FROM mission_generic_owner.work_items WHERE id=(writer46->>'successor_work_id')::uuid
  AND master_session_id=e.master_session_id AND event_id=(candidate->>'event_id')::uuid
  AND request_key=(candidate->>'request_key')::uuid AND revision=(candidate->>'expected_revision')::bigint;
 -- Count terminalization legitimately closes the old event via event_capture. Transfer only this still-live explicit claim.
 SELECT * INTO STRICT writer48_terminal_event FROM mission_generic_owner.event_outbox_v1
  WHERE event_key=e.event_key AND event_version=e.event_version FOR UPDATE;
 IF writer48_terminal_event.state NOT IN('running','terminal')
 OR (writer48_source_work.state='claimed' AND writer48_terminal_event.state IS DISTINCT FROM 'terminal')
 OR to_jsonb(writer48_terminal_event)-ARRAY['state','updated_at'] IS DISTINCT FROM to_jsonb(e)-ARRAY['state','updated_at']
 OR writer48_terminal_event.claim_id IS DISTINCT FROM p_claim_id OR writer48_terminal_event.claim_expires_at<=clock_timestamp()
 OR writer48_terminal_event.recovery_request_key IS NULL
 OR writer46->>'old_work_id' IS DISTINCT FROM writer48_source_work.id::text
 OR writer46->>'audit_sha256' IS DISTINCT FROM mission_generic_owner.writer_count_reissue_proof_v1(writer48_source_work.id,NULL)->>'audit_sha256'
 THEN RAISE EXCEPTION 'EVENT48_REISSUE_FENCE_DRIFT' USING ERRCODE='42501';END IF;
 UPDATE mission_generic_owner.event_outbox_v1 ev48 SET state='running',claim_txid=txid_current(),claim_backend=pg_backend_pid(),
  claim_history=ev48.claim_history||jsonb_build_array(jsonb_build_object('claim_id',ev48.claim_id,'expires_at',ev48.claim_expires_at,
   'state',ev48.state,'recovery_request_key',ev48.recovery_request_key,'settle_result',ev48.settle_result,
   'next_result_sha256',CASE WHEN ev48.next_result IS NULL THEN NULL ELSE public.combat_v2_sha256(ev48.next_result) END)),
  work_id=w.id,canonical_request=candidate,updated_at=clock_timestamp()
 WHERE ev48.event_key=e.event_key AND ev48.event_version=e.event_version AND to_jsonb(ev48)=to_jsonb(writer48_terminal_event)
  AND ev48.claim_id=p_claim_id AND ev48.claim_expires_at>clock_timestamp()
 RETURNING to_jsonb(ev48) INTO writer48_event_after;
 IF NOT FOUND THEN RAISE EXCEPTION 'EVENT48_REISSUE_FENCE_CAS_LOST' USING ERRCODE='40001';END IF;
 INSERT INTO mission_narrative_internal.dispatch_audit(receipt_id,event_code,details)
 VALUES(writer48_source_work.dispatch_receipt_id,'staff_writer_count_event_rebound_v1',jsonb_build_object(
  'schema_version','mission-writer-count-event-rebind/1','event_key',e.event_key,'event_version',e.event_version,
  'claim_id',e.claim_id,'recovery_request_key',e.recovery_request_key,'root_principal',e.root_principal,
  'root_receipt_sha256',e.root_receipt_sha256,'source_id',e.source_id,'source_sha256',e.source_sha256,
  'old_work_id',writer48_source_work.id,'old_request_sha256',public.combat_v2_sha256(writer48_source_request),
  'successor_work_id',w.id,'successor_request_sha256',public.combat_v2_sha256(candidate),
  'reissue_audit_sha256',writer46->>'audit_sha256','terminal_event_snapshot',to_jsonb(writer48_terminal_event),
  'terminal_event_sha256',public.combat_v2_sha256(to_jsonb(writer48_terminal_event)),
  'rebound_event_sha256',public.combat_v2_sha256(writer48_event_after)));
 -- The ordinary dispatcher still requires running state, same principal, live nonce/lease and this transaction/backend.
 native_claim:=public.mission_generic_dispatch_claim_v1(e.root_principal,candidate);native_mode:='normal';
 ELSIF e.recovery_request_key IS NOT NULL AND w.state='failed' AND w.kind='director'
 AND(mission_generic_owner.retained_director_adoption_v1(w.id,false)->>'owner_user_id'=e.root_principal::text) IS TRUE THEN
 native_claim:=jsonb_build_object('mode','retained_director','body',jsonb_build_object('schema_version','mission-retained-director-recovery/1',
 'mode','prepare','master_session_id',w.master_session_id,'work_id',w.id));outcome:='dispatch';paid_action:=true;
 ELSIF e.recovery_request_key IS NOT NULL AND w.state='failed' AND w.kind='narration'
 AND w.result->'ok'='true'::jsonb AND w.result->>'provider_calls'='1' AND w.result->'outcome_uncertain'='false'::jsonb
 AND (w.result_sha256=public.combat_v2_sha256(w.result) OR EXISTS(
 SELECT 1 FROM mission_narrative_internal.dispatch_audit hp_finalized
 WHERE hp_finalized.receipt_id=w.dispatch_receipt_id AND hp_finalized.event_code='generic_finalized'
 AND hp_finalized.details->>'work_id'=w.id::text
 AND hp_finalized.details->>'receipt_id'=w.receipt_id::text
 AND hp_finalized.details->>'state'=w.state
 AND hp_finalized.details->'message_id' IS NOT DISTINCT FROM coalesce(to_jsonb(w.message_id),'null'::jsonb)
 AND hp_finalized.details->>'result_sha256'=w.result_sha256
 AND hp_finalized.details->>'result_jsonb_sha256'=public.combat_v2_sha256(w.result))) THEN
 native_claim:=jsonb_build_object('mode','cached_publication','body',jsonb_build_object('schema_version','mission-generic-staff-cached-publication/1',
 'master_session_id',w.master_session_id,'work_id',w.id));outcome:='dispatch';paid_action:=true;
 ELSIF e.recovery_request_key IS NOT NULL AND w.state='claimed' AND w.lease_expires_at<=clock_timestamp()
 AND EXISTS(SELECT 1 FROM mission_narrative_internal.dispatch_audit a WHERE a.receipt_id=w.dispatch_receipt_id AND a.event_code='c8_count_success'
  AND a.details->'generation_allowed'='true'::jsonb AND a.details->'generation_http_calls'='0'::jsonb)
 AND w.authorization_id IS NULL AND w.dispatch_id IS NULL AND w.result IS NULL
 AND NOT EXISTS(SELECT 1 FROM mission_narrative_internal.dispatch_attempts da WHERE da.receipt_id=w.dispatch_receipt_id)
 AND NOT EXISTS(SELECT 1 FROM mission_narrative_internal.provider_authorizations pa WHERE pa.receipt_id=w.dispatch_receipt_id)
 AND NOT EXISTS(SELECT 1 FROM mission_narrative_internal.dispatch_audit a WHERE a.receipt_id=w.dispatch_receipt_id AND a.event_code='c8_count_unknown') THEN
 -- Existing RPC owns all Count/source/request/prices/ticket/current-authority checks and grants the real replacement lease.
 native_claim:=public.mission_generic_counted_resume_v1(e.root_principal,candidate);native_mode:='counted_resume';
 ELSIF(w.state='ready' AND w.lease_id IS NULL OR w.state='claimed' AND w.lease_expires_at<=clock_timestamp())
 AND w.authorization_id IS NULL AND w.dispatch_id IS NULL AND w.result IS NULL AND w.receipt_id IS NULL
 AND NOT EXISTS(SELECT 1 FROM mission_narrative_internal.dispatch_audit a WHERE a.receipt_id=w.dispatch_receipt_id AND a.event_code='c8_count_started')
 AND NOT EXISTS(SELECT 1 FROM mission_narrative_internal.provider_authorizations pa WHERE pa.receipt_id=w.dispatch_receipt_id)
 AND NOT EXISTS(SELECT 1 FROM mission_narrative_internal.dispatch_attempts da WHERE da.receipt_id=w.dispatch_receipt_id) THEN
 UPDATE mission_generic_owner.event_outbox_v1 SET claim_txid=txid_current(),claim_backend=pg_backend_pid(),
 work_id=w.id,canonical_request=candidate WHERE event_key=e.event_key AND event_version=e.event_version;
 native_claim:=public.mission_generic_dispatch_claim_v1(e.root_principal,candidate);native_mode:='normal';
 ELSE
  -- Observe existing in-flight work only; no lease, claim, dispatch or replay is granted.
  IF writer48_child_id IS NOT NULL AND w.id=writer48_child_id AND candidate=writer48_child_request THEN
   event43_observed_work:=w.id;event43_observed_request:=candidate;
   IF w.state IN('completed','failed') AND w.receipt_id IS NOT NULL AND w.finalized_at IS NOT NULL
    AND(w.result_sha256=public.combat_v2_sha256(w.result) OR EXISTS(SELECT 1 FROM mission_narrative_internal.dispatch_audit wf
     WHERE wf.receipt_id=w.dispatch_receipt_id AND wf.event_code='generic_finalized' AND wf.details->>'work_id'=w.id::text
      AND wf.details->>'receipt_id'=w.receipt_id::text AND wf.details->>'state'=w.state
      AND wf.details->>'result_sha256'=w.result_sha256 AND wf.details->>'result_jsonb_sha256'=public.combat_v2_sha256(w.result)))
   THEN outcome:='terminal';ELSE outcome:='uncertain';END IF;
  ELSIF e.event_domain='native_input' AND e.work_id IS NULL AND e.canonical_request IS NULL
   AND w.kind='narration' AND w.state IN('claimed','authorized','provider_started')
   AND candidate=jsonb_build_object('schema_version','mission-generic-request/1',
   'master_session_id',w.master_session_id,'event_id',w.event_id,
   'request_key',w.request_key,'expected_revision',w.revision)
   AND EXISTS(
   WITH event43_sources AS MATERIALIZED (SELECT src.round_id,src.declaration_id,src.coverage_id,src.source_kind
 FROM (
 SELECT dc.round_id,dc.defense_declaration_id AS declaration_id,dc.id AS coverage_id,'coverage'::text AS source_kind
 FROM public.combat_v2_defense_coverages dc
 JOIN public.combat_v2_declarations dd ON dd.id=dc.defense_declaration_id AND dd.round_id=dc.round_id
 JOIN public.combat_v2_actors aa ON aa.id=dd.actor_id AND aa.actor_kind='pg'
 WHERE dc.id=e.source_id AND e.source_sha256 IN(
 public.combat_v2_sha256(to_jsonb(dc)),
 public.combat_v2_sha256(jsonb_set(to_jsonb(dc),'{state}','"dichiarata"'::jsonb)))
 UNION ALL
 SELECT rt.round_id,rt.declaration_id,NULL::uuid,'rating'::text
 FROM public.combat_v2_ratings rt
 JOIN public.combat_v2_declarations dd ON dd.id=rt.declaration_id AND dd.round_id=rt.round_id
 WHERE rt.id=e.source_id AND rt.is_active
 AND e.source_sha256 IN(public.combat_v2_sha256(to_jsonb(rt)),
 public.combat_v2_sha256(jsonb_set(to_jsonb(rt),'{frozen_at}','null'::jsonb)))
 UNION ALL
 SELECT dd.round_id,dd.id,NULL::uuid,'declaration'::text
 FROM public.combat_v2_declarations dd JOIN public.combat_v2_actors aa ON aa.id=dd.actor_id AND aa.actor_kind='pg'
 WHERE dd.id=e.source_id AND e.source_sha256=public.combat_v2_sha256(to_jsonb(dd))
 ) src)
   SELECT 1 FROM event43_sources event43_src
   JOIN public.combat_v2_rounds event43_round ON event43_round.id=event43_src.round_id
   JOIN public.combat_v2_sessions event43_enc ON event43_enc.id=event43_round.session_id
    AND event43_enc.master_session_id=e.master_session_id
   JOIN public.master_v2_sessions event43_master ON event43_master.id=e.master_session_id
    AND event43_master.location_id=event43_enc.location_id
   JOIN mission_generic_owner.work_items event43_observed
    ON event43_observed.id=w.id AND event43_observed.master_session_id=e.master_session_id
    AND event43_observed.kind='narration' AND event43_observed.state IN('claimed','authorized','provider_started')
    AND event43_observed.event_id=w.event_id AND event43_observed.request_key=w.request_key
    AND event43_observed.revision=w.revision AND event43_observed.authority_receipt_id=w.authority_receipt_id
    AND event43_observed.encounter_id=event43_enc.id
   JOIN mission_generic_owner.unified_batches event43_batch
    ON event43_batch.master_session_id=e.master_session_id AND event43_batch.encounter_id=event43_enc.id
    AND event43_batch.source_round_id=event43_round.id
    AND event43_batch.source_report_id=event43_round.report_id
   WHERE (SELECT count(*) FROM event43_sources)=1
   AND e.event_key=mission_ai_service_owner.uuid5(event43_round.id,'server-event:native-input')
   AND e.created_at<=event43_batch.created_at
   AND event43_batch.id=w.event_id AND event43_batch.id=w.authority_receipt_id
   AND event43_batch.writer_work_id=w.id AND event43_batch.encounter_id=w.encounter_id
   AND event43_batch.state IN('preparing','ready') AND event43_batch.retired_at IS NULL
   AND event43_batch.message_id IS NULL
   AND NOT EXISTS(SELECT 1 FROM mission_generic_owner.unified_batches event43_other
    WHERE event43_other.master_session_id=e.master_session_id
    AND event43_other.source_round_id=event43_round.id AND event43_other.id<>event43_batch.id
    AND event43_other.retired_at IS NULL AND event43_other.state IN('preparing','ready','published'))
   ) THEN event43_observed_work:=w.id;event43_observed_request:=candidate;END IF;
  IF outcome IS NULL THEN outcome:='uncertain';END IF;candidate:=NULL;
 END IF;
 IF NOT paid_action AND native_mode IS NOT NULL THEN
 IF native_claim->>'state'='claimed' AND native_claim->'granted_now'='true'::jsonb THEN
 native_claim:=jsonb_build_object('mode',native_mode,'body',native_claim);outcome:='dispatch';
 ELSE outcome:='uncertain';candidate:=NULL;native_claim:=NULL;END IF;
 END IF;
 ELSE outcome:='waiting';candidate:=NULL; END IF;
 END IF;
 END IF;
 progress:=jsonb_build_object('schema_version','mission-event-next/1','event_key',e.event_key,'event_version',e.event_version,
 'claim_id',e.claim_id,'master_session_id',e.master_session_id,'state',outcome,'request',candidate,'native_claim',native_claim);
 UPDATE mission_generic_owner.event_outbox_v1 SET next_result=jsonb_set(progress,'{native_claim}','null'::jsonb),native_claim_sha256=CASE WHEN native_claim IS NOT NULL THEN public.combat_v2_sha256(native_claim) ELSE native_claim_sha256 END,
 work_id=CASE WHEN outcome='dispatch' THEN w.id
 WHEN event43_observed_work IS NOT NULL AND work_id IS NULL AND canonical_request IS NULL THEN event43_observed_work ELSE work_id END,
 canonical_request=CASE WHEN outcome='dispatch' THEN candidate
 WHEN event43_observed_work IS NOT NULL AND work_id IS NULL AND canonical_request IS NULL THEN event43_observed_request ELSE canonical_request END,updated_at=clock_timestamp()
 WHERE event_key=e.event_key AND event_version=e.event_version;
 RETURN progress;
END $function$;

SELECT clan_innata_private.eligibility_release_assert();
COMMIT;
