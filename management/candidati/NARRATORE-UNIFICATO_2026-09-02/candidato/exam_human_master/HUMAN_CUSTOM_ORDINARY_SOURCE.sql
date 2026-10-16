CREATE OR REPLACE FUNCTION mission_factory_owner.human_context_bound_v1(p_context jsonb, p_base text)
 RETURNS boolean
 LANGUAGE plpgsql
 STABLE SECURITY DEFINER
 SET search_path TO ''
AS $function$
BEGIN
 RETURN p_base='5ab4234b32294cc26472855447e6230f62c5e07308768816ae0c2ea304d94366'
 AND p_context->>'schema_version'='human-server-command-context/1' AND (p_context->>'backend_pid')::integer=pg_backend_pid()
 AND (p_context->>'transaction_started_at')::timestamptz=transaction_timestamp() AND (p_context->>'statement_started_at')::timestamptz=statement_timestamp()
 AND (p_context->>'principal') IS NOT DISTINCT FROM auth.uid()::text AND (p_context->>'auth_role') IS NOT DISTINCT FROM auth.role()
 AND p_context->>'base_release_sha256'=p_base
 AND p_context#>>'{observation,schema_version}'='human-compatible-release-identity/1' AND p_context#>>'{observation,provenance_release_sha256}'=p_base
 AND p_context#>>'{observation,revision_sha256}'=p_base AND p_context#>>'{observation,state}'='enabled'
 AND p_context#>>'{observation,scope}'='staff' AND p_context#>'{observation,staff_guards_verified}'='true'::jsonb AND p_context#>'{observation,published_assets_verified}'='true'::jsonb
 AND p_context#>>'{observation,canonical_preimage}' IS NOT NULL
 AND p_context#>>'{observation,observed_revision_sha256}' IS NOT NULL;
EXCEPTION WHEN invalid_text_representation OR datetime_field_overflow THEN RETURN false;
END;
$function$;

CREATE OR REPLACE FUNCTION mission_factory_owner.human_ordinary_authority_verified_v1(p_draft uuid, p_version bigint, p_source text, p_context jsonb)
 RETURNS jsonb
 LANGUAGE plpgsql
 STABLE SECURITY DEFINER
 SET search_path TO ''
AS $function$
DECLARE observation jsonb;g mission_factory_owner.quest_fixed30_admission;d mission_factory_owner.drafts;
 ready mission_factory_owner.editor_release_readiness;rel mission_public_owner.release_admissions_v1;
 roster mission_factory_owner.quest_roster_assignments;policy mission_factory_owner.quest_reward_policy_versions;
 n integer;policy_text text;expected_qual text;
BEGIN
 IF mission_factory_owner.human_context_bound_v1(p_context,'5ab4234b32294cc26472855447e6230f62c5e07308768816ae0c2ea304d94366') IS DISTINCT FROM true THEN RAISE EXCEPTION 'HUMAN_SERVER_COMMAND_CONTEXT_INVALID' USING ERRCODE='42501';END IF;

 IF p_draft IS NULL OR p_version IS NULL OR p_source IS NULL THEN RETURN NULL;END IF;
 SELECT * INTO d FROM mission_factory_owner.drafts WHERE id=p_draft;
 SELECT * INTO g FROM mission_factory_owner.quest_fixed30_admission WHERE singleton;
 observation:=(p_context->'observation');IF mission_factory_owner.human_context_bound_v1(p_context,CASE WHEN g.public_staff_draft_id=p_draft THEN g.public_staff_release_sha256 ELSE g.public_release_sha256 END) IS DISTINCT FROM true THEN RETURN NULL;END IF;
 SELECT * INTO ready FROM jsonb_populate_record(NULL::mission_factory_owner.editor_release_readiness,observation);
 IF d.id IS NULL OR g.singleton IS NULL OR ready.singleton IS NULL
 OR d.control_version IS DISTINCT FROM p_version OR d.document_sha256 IS DISTINCT FROM p_source
 OR mission_factory_owner.sha(d.document) IS DISTINCT FROM p_source
 OR d.document->>'schema_version' IS DISTINCT FROM 'mission-factory-draft/3'
 OR d.document->>'content_kind' IS DISTINCT FROM 'quest_human' OR d.state NOT IN('draft','previewed','published')
 OR ready.state<>'enabled' OR ready.scope<>'staff' OR mission_factory_owner.human_context_bound_v1(p_context,ready.revision_sha256) IS DISTINCT FROM true
 OR NOT ready.staff_guards_verified OR NOT ready.published_assets_verified
 OR encode(extensions.digest(convert_to(ready.canonical_preimage,'UTF8'),'sha256'),'hex') IS DISTINCT FROM ready.revision_sha256
 OR jsonb_typeof(d.document#>'{quest,episodes}') IS DISTINCT FROM 'array'
 THEN RETURN NULL;END IF;
 n:=jsonb_array_length(d.document#>'{quest,episodes}');IF n<1 THEN RETURN NULL;END IF;
 policy_text:=d.document#>>ARRAY['quest','episodes',(n-1)::text,'terminal_rules','reward_policy_id'];
 SELECT * INTO policy FROM mission_factory_owner.quest_reward_policy_versions WHERE id::text=policy_text AND qualified AND scope='staff';
 SELECT * INTO roster FROM mission_factory_owner.quest_roster_assignments
 WHERE id::text=d.document#>>'{quest,roster_assignment_id}' AND draft_id=d.id AND active;
 IF policy.id IS NULL OR roster.id IS NULL OR mission_factory_owner.sha(policy.document) IS DISTINCT FROM policy.document_sha256
 OR policy.document IS DISTINCT FROM mission_factory_owner.quest_reward_fixed30_document_v2()
 THEN RETURN NULL;END IF;
 IF g.public_staff_draft_id=p_draft THEN
  SELECT * INTO rel FROM mission_public_owner.release_admissions_v1 WHERE release_sha256=CASE WHEN observation->>'schema_version'='human-compatible-release-identity/1' THEN observation->>'observed_revision_sha256' ELSE g.public_staff_release_sha256 END;
  IF NOT g.public_staff_enabled OR mission_factory_owner.c416_kind_live_v1() IS DISTINCT FROM true OR mission_factory_owner.c444_enabled_v1() IS DISTINCT FROM true
  OR g.public_staff_draft_version IS DISTINCT FROM p_version OR g.public_staff_source_sha256 IS DISTINCT FROM p_source
  OR g.public_staff_release_sha256 IS DISTINCT FROM ready.revision_sha256 OR rel.release_sha256 IS NULL
  OR rel.contract_version<>'mission-public-admission/1' OR rel.independent_review_ref IS DISTINCT FROM (CASE WHEN observation->>'schema_version'='human-compatible-release-identity/1' THEN observation->>'observed_independent_review_ref' ELSE ready.independent_review_ref END)
  OR rel.staff_evidence_ref IS DISTINCT FROM 'AUTHORIZED_TEST_MANIFEST:'||g.public_staff_test_manifest_ref
  OR g.allowed_auth_ids IS DISTINCT FROM (SELECT allowed_auth_ids FROM mission_factory_owner.c416_kind_admission WHERE singleton) OR cardinality(g.allowed_auth_ids) IS DISTINCT FROM 2 OR array_position(g.allowed_auth_ids,NULL) IS NOT NULL
  OR NOT(g.allowed_auth_ids @> ARRAY['f0856d53-83a6-4de0-bc0c-12c87916e665'::uuid,'b4952ed5-5ce0-49c0-9f2b-8fd5dcd89b4b'::uuid])
  OR NOT(d.author_user=ANY(g.allowed_auth_ids))
  OR NOT EXISTS(SELECT 1 FROM public.locations WHERE id='0b85f354-9cdb-47e1-baf9-3d266bb7e06b'::uuid AND is_active AND is_test)
  OR EXISTS(SELECT 1 FROM unnest(roster.member_character_ids)x(id) LEFT JOIN public.characters c ON c.id=x.id
   WHERE c.id IS NULL OR NOT(c.user_id=ANY(g.allowed_auth_ids)))
  OR NOT EXISTS(SELECT 1 FROM mission_factory_owner.quest_fixed30_policy_requests qr
   JOIN mission_factory_owner.catalog_versions cv ON cv.version=d.catalog_version AND cv.active AND cv.qualified
   WHERE qr.policy_id=policy.id AND qr.document_sha256=policy.document_sha256
   AND qr.catalog_version=cv.version AND qr.catalog_sha256=cv.document_sha256)
  THEN RETURN NULL;END IF;
  IF observation->>'schema_version'='human-compatible-release-identity/1' THEN
  expected_qual:=mission_factory_owner.sha(jsonb_build_object('schema_version','quest-human-public-staff-compatible-context/1','release_sha256',ready.revision_sha256,'observed_release_sha256',observation->>'observed_revision_sha256','compatibility_sha256',observation->>'compatibility_sha256',
   'db_sha256',rel.db_sha256,'edge_sha256',rel.edge_sha256,'client_sha256',rel.client_sha256,'config_sha256',rel.configuration_sha256,
   'independent_review_ref',rel.independent_review_ref,'authorized_test_manifest_ref',g.public_staff_test_manifest_ref,
   'draft_id',p_draft,'draft_version',p_version,'source_sha256',p_source,'allowed_auth_ids',g.allowed_auth_ids,
   'human_kind_request',(SELECT request_key FROM mission_factory_owner.c416_kind_admission WHERE singleton),'human_kind_review_sha256',(SELECT review_sha256 FROM mission_factory_owner.c416_kind_admission WHERE singleton),'location_id','0b85f354-9cdb-47e1-baf9-3d266bb7e06b'));
  ELSE
  expected_qual:=mission_factory_owner.sha(jsonb_build_object('schema_version','quest-human-public-staff-context/1','release_sha256',rel.release_sha256,
   'db_sha256',rel.db_sha256,'edge_sha256',rel.edge_sha256,'client_sha256',rel.client_sha256,'config_sha256',rel.configuration_sha256,
   'independent_review_ref',rel.independent_review_ref,'authorized_test_manifest_ref',g.public_staff_test_manifest_ref,
   'draft_id',p_draft,'draft_version',p_version,'source_sha256',p_source,'allowed_auth_ids',g.allowed_auth_ids,
   'human_kind_request',(SELECT request_key FROM mission_factory_owner.c416_kind_admission WHERE singleton),'human_kind_review_sha256',(SELECT review_sha256 FROM mission_factory_owner.c416_kind_admission WHERE singleton),'location_id','0b85f354-9cdb-47e1-baf9-3d266bb7e06b'));
  END IF;
  IF g.public_staff_qualification_sha256 IS DISTINCT FROM expected_qual THEN
   IF EXISTS(SELECT 1 FROM mission_factory_owner.quest_arcs hc_existing WHERE hc_existing.draft_id=p_draft AND hc_existing.draft_version=p_version AND hc_existing.source_sha256=p_source AND (mission_factory_owner.human_staff_context_records_v1(observation,observation->>'observed_revision_sha256',hc_existing.id,'legacy_current',g) OR mission_factory_owner.human_staff_lease_valid_verified_v1(observation,hc_existing.id,true,p_context))) THEN
    expected_qual:=g.public_staff_qualification_sha256;
   ELSE RETURN NULL;END IF;
  END IF;
  RETURN jsonb_build_object('execution_context','staff_simulation','target','staff','revision_sha256',CASE WHEN observation->>'schema_version'='human-compatible-release-identity/1' THEN ready.revision_sha256 ELSE rel.release_sha256 END,
   'qualification_sha256',expected_qual,'allowed_auth_ids',to_jsonb(g.allowed_auth_ids),'location_id','0b85f354-9cdb-47e1-baf9-3d266bb7e06b');
 END IF;
 IF (NOT g.public_enabled AND (mission_public_owner.human_positive_qualification_v1(g.public_release_sha256,true)->>'schema_version' IS NOT DISTINCT FROM 'human-owner-accepted-release/1') IS DISTINCT FROM true) OR g.public_release_sha256 IS DISTINCT FROM ready.revision_sha256
 OR (g.public_policy_id IS DISTINCT FROM policy.id AND NOT(EXISTS(SELECT 1 FROM mission_factory_owner.quest_reward_policy_versions hp_new JOIN mission_factory_owner.quest_reward_policy_versions hp_old ON hp_old.id=g.public_policy_id
 WHERE hp_new.id=policy.id AND hp_new.qualified AND hp_old.qualified AND hp_new.scope='staff' AND hp_old.scope='staff' AND hp_new.document_sha256='34197acc065af70dc89ac15d54c19044f4e5af07c91b5869eb0b360a0fcfef19' AND hp_old.document_sha256=hp_new.document_sha256 AND hp_new.document IS NOT DISTINCT FROM hp_old.document AND hp_new.document IS NOT DISTINCT FROM mission_factory_owner.quest_reward_fixed30_document_v2() AND mission_factory_owner.sha(hp_new.document)=hp_new.document_sha256 AND mission_factory_owner.sha(hp_old.document)=hp_old.document_sha256
 AND EXISTS(SELECT 1 FROM mission_factory_owner.quest_fixed30_policy_requests hp_q JOIN mission_factory_owner.catalog_versions hp_cv ON hp_cv.version=hp_q.catalog_version AND hp_cv.active AND hp_cv.qualified AND hp_cv.document_sha256=hp_q.catalog_sha256 AND hp_cv.document_sha256=mission_factory_owner.sha(hp_cv.document) WHERE hp_q.policy_id=hp_new.id AND hp_q.document_sha256=hp_new.document_sha256 AND hp_q.catalog_version=d.catalog_version)))) OR g.public_qualification_sha256 IS NULL
 OR mission_public_owner.human_positive_qualification_v1(g.public_release_sha256,true) IS NULL THEN RETURN NULL;END IF;
 RETURN jsonb_build_object('execution_context','public_real','target','public','revision_sha256',g.public_release_sha256,
 'qualification_sha256',g.public_qualification_sha256,'allowed_auth_ids','[]'::jsonb,'location_id',NULL);
END $function$;

CREATE OR REPLACE FUNCTION mission_factory_owner.human_ordinary_authority_with_context_v1(p_draft uuid, p_version bigint, p_source text, p_context jsonb)
 RETURNS jsonb
 LANGUAGE plpgsql
 STABLE SECURITY DEFINER
 SET search_path TO ''
AS $function$
BEGIN
 IF mission_factory_owner.human_verified_context_valid_v1(p_context,'5ab4234b32294cc26472855447e6230f62c5e07308768816ae0c2ea304d94366') IS DISTINCT FROM true THEN RAISE EXCEPTION 'HUMAN_SERVER_COMMAND_CONTEXT_INVALID' USING ERRCODE='42501';END IF;
 RETURN mission_factory_owner.human_ordinary_authority_verified_v1(p_draft,p_version,p_source,p_context);
END;
$function$;

CREATE OR REPLACE FUNCTION mission_factory_owner.human_custom_ordinary_capability_verified_v1(p_draft uuid, p_public boolean, p_context jsonb)
 RETURNS jsonb
 LANGUAGE plpgsql
 STABLE SECURITY DEFINER
 SET search_path TO ''
AS $function$
DECLARE observed jsonb;ct jsonb;ad mission_public_owner.release_admissions_v1;g mission_factory_owner.quest_fixed30_admission;
 pos mission_public_owner.public_qualification_attestations_v1;src mission_factory_owner.quest_run_sources;ar mission_factory_owner.quest_arcs;tr mission_factory_owner.quest_terminal_receipts;
 csha text;keysha text;own_draft uuid;mode text;force_staff boolean:=false;
BEGIN
 IF mission_factory_owner.human_context_bound_v1(p_context,'5ab4234b32294cc26472855447e6230f62c5e07308768816ae0c2ea304d94366') IS DISTINCT FROM true THEN RAISE EXCEPTION 'HUMAN_SERVER_COMMAND_CONTEXT_INVALID' USING ERRCODE='42501';END IF;

 IF p_public IS NULL OR auth.uid() IS NULL OR auth.role() IS DISTINCT FROM 'authenticated' THEN RETURN NULL;END IF;
 observed:=(p_context->'observation');
 IF observed->>'schema_version' IS DISTINCT FROM 'human-compatible-release-identity/1' OR observed->>'provenance_release_sha256' IS DISTINCT FROM '5ab4234b32294cc26472855447e6230f62c5e07308768816ae0c2ea304d94366' OR observed->>'observed_revision_sha256' IS NULL OR observed->>'observed_revision_sha256'='5ab4234b32294cc26472855447e6230f62c5e07308768816ae0c2ea304d94366' THEN RETURN NULL;END IF;
 csha:=observed->>'observed_revision_sha256';ct:=observed->'observed_canonical_tuple';
 SELECT * INTO STRICT g FROM mission_factory_owner.quest_fixed30_admission WHERE singleton;
 SELECT * INTO ad FROM mission_public_owner.release_admissions_v1 WHERE release_sha256=csha;
 IF ad.release_sha256 IS NULL THEN RETURN NULL;END IF;
 own_draft:=coalesce(p_draft,CASE WHEN g.public_staff_enabled THEN g.public_staff_draft_id END,nullif(ct#>>'{config,policy,custom_native_draft_id}','')::uuid);
 force_staff:=(g.public_staff_enabled AND own_draft=g.public_staff_draft_id) OR EXISTS(SELECT 1 FROM mission_factory_owner.quest_arcs sa WHERE sa.draft_id=own_draft AND sa.availability_scope='public' AND sa.execution_context='staff_simulation' AND sa.source_document->>'content_kind'='quest_human');
 keysha:=mission_factory_owner.sha(jsonb_build_object('schema_version','human-custom-positive-key/1','capability_sha256',csha));
 SELECT * INTO pos FROM mission_public_owner.public_qualification_attestations_v1 WHERE release_sha256=keysha;
 IF NOT coalesce(force_staff,false) AND ad.public_enabled AND pos.created_by='postgres'::name AND pos.payload_sha256=mission_factory_owner.sha(pos.payload)
 AND mission_factory_owner.keys_exact_v2(pos.payload,ARRAY['schema_version','capability_sha256','session_id','terminal_receipt_id','encounter_id','report_id','protected_before_md5','protected_after_md5','provider_calls'])
 AND pos.payload->>'schema_version'='human-custom-positive-staff/1' AND pos.payload->>'capability_sha256'=csha AND pos.payload->'provider_calls'='0'::jsonb
 AND coalesce(pos.payload->>'protected_before_md5','')~'^[0-9a-f]{32}$' AND pos.payload->>'protected_before_md5'=pos.payload->>'protected_after_md5' THEN
 SELECT * INTO src FROM mission_factory_owner.quest_run_sources WHERE session_id=(pos.payload->>'session_id')::uuid;
 SELECT * INTO ar FROM mission_factory_owner.quest_arcs WHERE id=src.arc_id;
 SELECT * INTO tr FROM mission_factory_owner.quest_terminal_receipts WHERE id=(pos.payload->>'terminal_receipt_id')::uuid;
 IF src.state='terminal' AND src.availability_scope='public' AND src.execution_context='staff_simulation' AND src.public_release_sha256='5ab4234b32294cc26472855447e6230f62c5e07308768816ae0c2ea304d94366' AND src.location_id='0b85f354-9cdb-47e1-baf9-3d266bb7e06b'::uuid
 AND src.terminal_receipt_id=tr.id AND tr.session_id=src.session_id AND tr.source_sha256=src.source_sha256 AND tr.outcome='success' AND tr.publication_id IS NOT NULL AND ar.state='completed' AND cardinality(ar.execution_auth_ids)=2 AND cardinality(ar.member_character_ids)=2
 AND EXISTS(SELECT 1 FROM mission_public_owner.public_qualification_attestations_v1 sp WHERE sp.release_sha256=mission_factory_owner.sha(jsonb_build_object('schema_version','human-custom-source-key/1','publication_request',ar.publication_request)) AND sp.created_by='postgres'::name AND sp.payload->>'schema_version'='human-custom-source/1' AND (sp.payload->>'capability_sha256'=csha OR (sp.payload->>'capability_sha256' IS DISTINCT FROM csha AND (mission_factory_owner.human_staff_context_records_v1(observed,csha,ar.id,'continuity_historical',g) OR mission_factory_owner.human_staff_lease_valid_verified_v1(observed,ar.id,false,p_context)))) AND sp.payload->>'source_sha256'=ar.source_sha256 AND sp.payload->>'arc_id'=ar.id::text AND sp.payload_sha256=mission_factory_owner.sha(sp.payload))
 AND EXISTS(SELECT 1 FROM public.master_v2_sessions mm WHERE mm.id=src.session_id AND mm.owner_kind='human' AND mm.stato='chiusa' AND mm.closed_at IS NOT NULL)
 AND EXISTS(SELECT 1 FROM public.mission_run_outbox ox WHERE ox.event_id=tr.close_event_id AND ox.master_session_id=src.session_id AND ox.state='published' AND ox.publication_id=tr.publication_id)
 AND EXISTS(SELECT 1 FROM public.combat_v2_sessions cs JOIN public.combat_v2_rounds cr ON cr.session_id=cs.id JOIN public.combat_v2_round_reports rp ON rp.round_id=cr.id JOIN mission_generic_owner.regia_human_windows_v1 hw ON hw.master_session_id=src.session_id AND hw.encounter_id=cs.id AND hw.source_report_id=rp.id AND hw.source_report_sha256=rp.mechanics_sha256 AND hw.message_id=rp.message_id WHERE cs.id=(pos.payload->>'encounter_id')::uuid AND cs.master_session_id=src.session_id AND cs.state='chiuso' AND cs.closed_at IS NOT NULL AND rp.id=(pos.payload->>'report_id')::uuid AND rp.narration_state='pubblicata' AND rp.values_written=false AND hw.state='published' AND (SELECT count(*) FROM public.combat_v2_narratives nn WHERE nn.report_id=rp.id AND nn.kind='fato_umano')=1)
 AND EXISTS(SELECT 1 FROM public.combat_v2_provider_instances_v1 pi JOIN public.nb_mechanical_versions cv ON cv.id=pi.mechanical_version_ref WHERE pi.session_id=(pos.payload->>'encounter_id')::uuid AND pi.provider='ninja_book' AND cv.profile_kind='npc_custom' AND cv.review_state='approved' AND pi.source_sha256=cv.content_sha256 AND pi.snapshot_sha256=public.combat_v2_sha256(pi.snapshot))
 AND EXISTS(SELECT 1 FROM mission_factory_owner.quest_reward_decisions_v2 rd WHERE rd.arc_id=ar.id AND rd.terminal_receipt_id=tr.id AND rd.effect_mode='simulation' AND rd.receipt->>'state'='simulated' AND rd.receipt->>'computed_xp_per_recipient'='30' AND rd.receipt->>'effective_xp_per_recipient'='0' AND rd.receipt->>'ryo_per_recipient'='0' AND rd.receipt->'items'='[]'::jsonb)
 AND NOT EXISTS(SELECT 1 FROM public.combat_v2_resource_ledger rl WHERE rl.session_id=(pos.payload->>'encounter_id')::uuid AND rl.is_simulated IS DISTINCT FROM true)
 AND NOT EXISTS(SELECT 1 FROM mission_narrative_internal.dispatch_receipts zpd WHERE zpd.master_session_id=src.session_id)
 AND NOT EXISTS(SELECT 1 FROM mission_narrative_internal.dispatch_attempts zpa JOIN mission_narrative_internal.dispatch_receipts zpr ON zpr.id=zpa.receipt_id WHERE zpr.master_session_id=src.session_id)
 AND NOT EXISTS(SELECT 1 FROM mission_generic_owner.work_items zpw WHERE zpw.master_session_id=src.session_id)
 THEN mode:='public_real';END IF;
 END IF;
 IF mode IS NULL AND NOT p_public AND own_draft::text=ct#>>'{config,policy,custom_native_draft_id}'
 AND coalesce(ct#>>'{config,policy,custom_staff_expires_at}','')<>'' AND clock_timestamp()<(ct#>>'{config,policy,custom_staff_expires_at}')::timestamptz
 AND mission_factory_owner.c416_kind_live_v1() IS TRUE AND mission_factory_owner.c444_enabled_v1() IS TRUE
 AND cardinality((SELECT allowed_auth_ids FROM mission_factory_owner.c416_kind_admission WHERE singleton))=2
 AND EXISTS(SELECT 1 FROM mission_factory_owner.c416_kind_admission nk WHERE nk.singleton AND auth.uid()=ANY(nk.allowed_auth_ids))
 AND EXISTS(SELECT 1 FROM mission_factory_owner.drafts nd WHERE nd.id=own_draft AND nd.author_user=auth.uid() AND nd.state IN('draft','previewed') AND nd.document->>'schema_version'='mission-factory-draft/2' AND nd.document->>'content_kind'='quest_ai' AND nd.document_sha256=mission_factory_owner.sha(nd.document))
 THEN mode:='staff_simulation';END IF;
 IF mode IS NULL AND NOT p_public AND g.public_staff_enabled AND own_draft=g.public_staff_draft_id
 AND g.public_staff_release_sha256='5ab4234b32294cc26472855447e6230f62c5e07308768816ae0c2ea304d94366' AND g.public_staff_test_manifest_ref=ct#>>'{config,policy,custom_staff_manifest_ref}'
 AND (coalesce(ct#>>'{config,policy,custom_staff_expires_at}','')<>'' AND clock_timestamp()<(ct#>>'{config,policy,custom_staff_expires_at}')::timestamptz OR EXISTS(SELECT 1 FROM mission_factory_owner.quest_arcs lease_cap_arc WHERE lease_cap_arc.draft_id=own_draft AND mission_factory_owner.human_staff_lease_valid_verified_v1(observed,lease_cap_arc.id,true,p_context)))
 AND mission_factory_owner.c416_kind_live_v1() IS TRUE AND mission_factory_owner.c444_enabled_v1() IS TRUE
 AND cardinality(g.allowed_auth_ids)=2 AND auth.uid()=ANY(g.allowed_auth_ids)
 AND mission_factory_owner.human_ordinary_authority_verified_v1(own_draft,g.public_staff_draft_version,g.public_staff_source_sha256,p_context)->>'execution_context'='staff_simulation'
 THEN mode:='staff_simulation';END IF;
 IF mode IS NULL THEN RETURN NULL;END IF;
 RETURN jsonb_build_object('schema_version','human-custom-capability/1','capability_sha256',csha,'base_release_sha256','5ab4234b32294cc26472855447e6230f62c5e07308768816ae0c2ea304d94366','execution_context',mode,'staff_manifest_ref',ct#>>'{config,policy,custom_staff_manifest_ref}','draft_id',own_draft);
END
$function$;

CREATE OR REPLACE FUNCTION mission_factory_owner.human_custom_ordinary_capability_with_context_v1(p_draft uuid, p_public boolean, p_context jsonb)
 RETURNS jsonb
 LANGUAGE plpgsql
 STABLE SECURITY DEFINER
 SET search_path TO ''
AS $function$
BEGIN
 IF mission_factory_owner.human_verified_context_valid_v1(p_context,'5ab4234b32294cc26472855447e6230f62c5e07308768816ae0c2ea304d94366') IS DISTINCT FROM true THEN RAISE EXCEPTION 'HUMAN_SERVER_COMMAND_CONTEXT_INVALID' USING ERRCODE='42501';END IF;
 RETURN mission_factory_owner.human_custom_ordinary_capability_verified_v1(p_draft,p_public,p_context);
END;
$function$;

CREATE OR REPLACE FUNCTION mission_factory_owner.human_staff_lease_valid_verified_v1(p_observation jsonb, p_arc uuid, p_active boolean, p_context jsonb)
 RETURNS boolean
 LANGUAGE plpgsql
 STABLE SECURITY DEFINER
 SET search_path TO ''
AS $function$
DECLARE lease_record mission_public_owner.public_qualification_attestations_v1;lease_payload jsonb;lease_parent mission_public_owner.release_admissions_v1;lease_oldcp mission_public_owner.public_qualification_attestations_v1;lease_oldctx mission_public_owner.public_qualification_attestations_v1;lease_historical jsonb;g mission_factory_owner.quest_fixed30_admission;lease_arc mission_factory_owner.quest_arcs;lease_q mission_factory_owner.quest_run_sources;lease_episode mission_factory_owner.quest_episodes;lease_m public.master_v2_sessions;lease_from timestamptz;lease_until timestamptz;lease_matches integer:=0;
BEGIN
 IF mission_factory_owner.human_context_bound_v1(p_context,'5ab4234b32294cc26472855447e6230f62c5e07308768816ae0c2ea304d94366') IS DISTINCT FROM true THEN RAISE EXCEPTION 'HUMAN_SERVER_COMMAND_CONTEXT_INVALID' USING ERRCODE='42501';END IF;
 IF p_observation IS DISTINCT FROM (p_context->'observation') THEN RETURN false;END IF;

 IF p_active IS NULL OR p_arc IS NULL OR mission_factory_owner.human_context_bound_v1(p_context,'5ab4234b32294cc26472855447e6230f62c5e07308768816ae0c2ea304d94366') IS DISTINCT FROM true THEN RETURN false;END IF;
 SELECT * INTO lease_arc FROM mission_factory_owner.quest_arcs WHERE id=p_arc;
 IF lease_arc.id IS NULL OR lease_arc.availability_scope IS DISTINCT FROM 'public' OR lease_arc.execution_context IS DISTINCT FROM 'staff_simulation' OR lease_arc.source_document->>'content_kind' IS DISTINCT FROM 'quest_human' THEN RETURN false;END IF;
 FOR lease_record IN SELECT * FROM mission_public_owner.public_qualification_attestations_v1 WHERE payload->>'schema_version'='human-custom-staff-lease-renewal/1' AND payload->>'current_release_sha256'=p_observation->>'observed_revision_sha256' AND payload->>'arc_id'=p_arc::text LOOP
  lease_payload:=lease_record.payload;
  SELECT * INTO lease_oldctx FROM mission_public_owner.public_qualification_attestations_v1 WHERE payload_sha256=lease_payload->>'predecessor_context_sha256' AND payload->>'current_release_sha256'=lease_payload->>'predecessor_release_sha256' AND payload->>'arc_id'=p_arc::text;
  IF p_active THEN
   SELECT * INTO g FROM mission_factory_owner.quest_fixed30_admission WHERE singleton;
  ELSE
   -- History is proved by the immutable predecessor context, never by current mutable gates.
   SELECT * INTO g FROM jsonb_populate_record(NULL::mission_factory_owner.quest_fixed30_admission,lease_oldctx.payload->'predecessor_fixed30');
  END IF;
  SELECT * INTO lease_parent FROM mission_public_owner.release_admissions_v1 WHERE release_sha256=lease_record.release_sha256;
  IF lease_record.created_by IS DISTINCT FROM 'postgres'::name OR lease_record.payload_sha256 IS DISTINCT FROM mission_factory_owner.sha(lease_payload) OR mission_factory_owner.keys_exact_v2(lease_payload,ARRAY['schema_version', 'renewal_id', 'base_release_sha256', 'predecessor_release_sha256', 'current_release_sha256', 'current_db_sha256', 'predecessor_context_sha256', 'predecessor_source_payload_sha256', 'arc_id', 'draft_id', 'draft_version', 'source_sha256', 'session_id', 'assigned_master', 'allowed_auth_ids', 'location_id', 'allowed_operations', 'effective_from', 'expires_at', 'root_authority_sha256', 'independent_review_ref', 'review_sha256', 'semantic_manifest_sha256']) IS DISTINCT FROM true
  OR lease_record.request_key::text IS DISTINCT FROM lease_payload->>'renewal_id'
  OR lease_record.release_sha256 IS DISTINCT FROM mission_factory_owner.sha(jsonb_build_object('schema_version','human-custom-staff-lease-renewal-key/1','arc_id',p_arc,'current_release_sha256',p_observation->>'observed_revision_sha256','renewal_id',lease_payload->>'renewal_id'))
  OR lease_parent.public_enabled IS DISTINCT FROM false OR lease_parent.staff_evidence_ref IS DISTINCT FROM 'SOURCE_RECORD_ONLY:HUMAN_CUSTOM_STAFF_LEASE_RENEWAL' OR lease_parent.db_sha256 IS DISTINCT FROM p_observation#>>'{observed_canonical_tuple,db_core,sha256}'
  OR NOT EXISTS(SELECT 1 FROM mission_public_owner.release_admissions_v1 lease_current_ad WHERE release_sha256=p_observation->>'observed_revision_sha256' AND (to_jsonb(lease_parent)-'release_sha256'-'created_at'-'staff_evidence_ref'-'public_enabled') IS NOT DISTINCT FROM (to_jsonb(lease_current_ad)-'release_sha256'-'created_at'-'staff_evidence_ref'-'public_enabled'))
  OR NOT EXISTS(SELECT 1 FROM mission_public_owner.public_qualification_attestations_v1 lease_current_cp WHERE payload_sha256=p_observation->>'compatibility_sha256' AND created_by='postgres'::name AND payload_sha256=mission_factory_owner.sha(payload) AND payload->>'current_release_sha256'=p_observation->>'observed_revision_sha256' AND payload->>'review_sha256'=lease_payload->>'review_sha256' AND payload->>'semantic_manifest_sha256'=lease_payload->>'semantic_manifest_sha256')
  OR lease_payload->>'base_release_sha256' IS DISTINCT FROM '5ab4234b32294cc26472855447e6230f62c5e07308768816ae0c2ea304d94366' OR lease_payload->>'current_db_sha256' IS DISTINCT FROM p_observation#>>'{observed_canonical_tuple,db_core,sha256}'
  OR lease_payload->>'independent_review_ref' IS DISTINCT FROM p_observation->>'observed_independent_review_ref' OR lease_record.positive_staff_evidence_ref IS DISTINCT FROM 'SOURCE_REVIEW_ONLY:'||(lease_payload->>'independent_review_ref') OR lease_record.authorized_test_manifest_ref IS DISTINCT FROM g.public_staff_test_manifest_ref
  OR coalesce(lease_payload->>'root_authority_sha256','')!~'^[0-9a-f]{64}$' OR coalesce(lease_payload->>'review_sha256','')!~'^[0-9a-f]{64}$' OR coalesce(lease_payload->>'semantic_manifest_sha256','')!~'^[0-9a-f]{64}$'
  OR lease_payload->>'draft_id' IS DISTINCT FROM lease_arc.draft_id::text OR lease_payload->>'draft_version' IS DISTINCT FROM lease_arc.draft_version::text OR lease_payload->>'source_sha256' IS DISTINCT FROM lease_arc.source_sha256
  OR lease_payload->'allowed_auth_ids' IS DISTINCT FROM to_jsonb(lease_arc.execution_auth_ids) OR lease_payload->'allowed_auth_ids' IS DISTINCT FROM to_jsonb(g.allowed_auth_ids) OR cardinality(g.allowed_auth_ids) IS DISTINCT FROM 2
  OR lease_payload->'allowed_operations' IS DISTINCT FROM '["prepare_receipt","optin_receipt","start","fato","combat","phase_action","terminal","reward_simulation","close"]'::jsonb OR lease_payload->>'location_id' IS DISTINCT FROM '0b85f354-9cdb-47e1-baf9-3d266bb7e06b'
  THEN CONTINUE;END IF;
  SELECT * INTO lease_q FROM mission_factory_owner.quest_run_sources WHERE session_id=(lease_payload->>'session_id')::uuid;
  SELECT * INTO lease_m FROM public.master_v2_sessions WHERE id=lease_q.session_id;
  SELECT * INTO lease_episode FROM mission_factory_owner.quest_episodes WHERE id=lease_q.episode_id;
  IF lease_q.session_id IS NULL OR lease_q.arc_id IS DISTINCT FROM p_arc OR lease_episode.id IS NULL OR lease_episode.arc_id IS DISTINCT FROM p_arc OR lease_q.source_sha256 IS DISTINCT FROM lease_episode.source_sha256 OR lease_q.execution_qualification_sha256 IS DISTINCT FROM lease_arc.execution_qualification_sha256 OR lease_q.roster_character_ids IS DISTINCT FROM lease_arc.member_character_ids OR lease_q.location_id::text IS DISTINCT FROM lease_payload->>'location_id' OR lease_m.location_id IS DISTINCT FROM lease_q.location_id OR lease_m.master_user::text IS DISTINCT FROM lease_payload->>'assigned_master' OR NOT(lease_m.master_user=ANY(g.allowed_auth_ids)) OR lease_m.owner_kind IS DISTINCT FROM 'human' OR lease_m.tipo IS DISTINCT FROM 'quest' OR lease_m.mission_id IS NOT NULL THEN CONTINUE;END IF;
  SELECT * INTO lease_oldcp FROM mission_public_owner.public_qualification_attestations_v1 WHERE payload->>'schema_version'='human-release-compatibility/1' AND payload->>'current_release_sha256'=lease_payload->>'predecessor_release_sha256';
  SELECT * INTO lease_oldctx FROM mission_public_owner.public_qualification_attestations_v1 WHERE payload_sha256=lease_payload->>'predecessor_context_sha256' AND payload->>'current_release_sha256'=lease_payload->>'predecessor_release_sha256' AND payload->>'arc_id'=p_arc::text;
  IF lease_oldcp.created_by IS DISTINCT FROM 'postgres'::name OR lease_oldcp.payload_sha256 IS DISTINCT FROM mission_factory_owner.sha(lease_oldcp.payload) OR lease_oldctx.created_by IS DISTINCT FROM 'postgres'::name OR lease_oldctx.payload_sha256 IS DISTINCT FROM mission_factory_owner.sha(lease_oldctx.payload) OR lease_oldctx.payload->>'source_payload_sha256' IS DISTINCT FROM lease_payload->>'predecessor_source_payload_sha256' OR lease_oldcp.payload->'current_canonical_tuple' IS NULL OR mission_factory_owner.sha(lease_oldcp.payload->'current_canonical_tuple') IS DISTINCT FROM lease_payload->>'predecessor_release_sha256' THEN CONTINUE;END IF;
  -- Historical input below is derived from the immutable predecessor proof, never returned as the current observation.
  lease_historical:=p_observation||jsonb_build_object('observed_revision_sha256',lease_payload->>'predecessor_release_sha256','observed_canonical_tuple',lease_oldcp.payload->'current_canonical_tuple','observed_independent_review_ref',lease_oldcp.payload->>'independent_review_ref','compatibility_sha256',lease_oldcp.payload_sha256);
  IF (mission_factory_owner.human_staff_context_records_v1(lease_historical,lease_historical->>'observed_revision_sha256',p_arc,CASE WHEN p_active THEN 'lease_active' ELSE 'lease_historical' END,g)) IS DISTINCT FROM true THEN CONTINUE;END IF;
  lease_from:=(lease_payload->>'effective_from')::timestamptz;lease_until:=(lease_payload->>'expires_at')::timestamptz;
  IF lease_from IS NULL OR lease_until IS NULL OR lease_until IS DISTINCT FROM lease_from+interval '2 hours' OR lease_record.created_at<lease_from OR lease_record.created_at>lease_from+interval '5 minutes' THEN CONTINUE;END IF;
  IF p_active AND (clock_timestamp()<lease_from OR clock_timestamp()>=lease_until OR mission_factory_owner.c416_kind_live_v1() IS DISTINCT FROM true OR mission_factory_owner.c444_enabled_v1() IS DISTINCT FROM true OR NOT EXISTS(SELECT 1 FROM mission_factory_owner.c416_kind_admission lease_k WHERE singleton AND bound_at=lease_from AND expires_at=lease_until AND to_jsonb(allowed_auth_ids)=lease_payload->'allowed_auth_ids') OR NOT EXISTS(SELECT 1 FROM mission_factory_owner.c444_runtime_control lease_r WHERE singleton AND bound_at=lease_from AND expires_at=lease_until)) THEN CONTINUE;END IF;
  lease_matches:=lease_matches+1;
 END LOOP;
 RETURN CASE WHEN p_active THEN lease_matches=1 ELSE lease_matches>0 END;
EXCEPTION WHEN invalid_text_representation OR invalid_datetime_format OR datetime_field_overflow OR invalid_parameter_value THEN RETURN false;
END $function$;

CREATE OR REPLACE FUNCTION mission_factory_owner.human_staff_lease_valid_with_context_v1(p_observation jsonb, p_arc uuid, p_active boolean, p_context jsonb)
 RETURNS boolean
 LANGUAGE plpgsql
 STABLE SECURITY DEFINER
 SET search_path TO ''
AS $function$
BEGIN
 IF mission_factory_owner.human_verified_context_valid_v1(p_context,'5ab4234b32294cc26472855447e6230f62c5e07308768816ae0c2ea304d94366') IS DISTINCT FROM true THEN RAISE EXCEPTION 'HUMAN_SERVER_COMMAND_CONTEXT_INVALID' USING ERRCODE='42501';END IF;
 RETURN mission_factory_owner.human_staff_lease_valid_verified_v1(p_observation,p_arc,p_active,p_context);
END;
$function$;

CREATE OR REPLACE FUNCTION mission_factory_owner.human_ordinary_source_verified_v1(p_session uuid, p_master boolean, p_context jsonb)
 RETURNS jsonb
 LANGUAGE plpgsql
 STABLE SECURITY DEFINER
 SET search_path TO ''
AS $function$
DECLARE q mission_factory_owner.quest_run_sources;a mission_factory_owner.quest_arcs;m public.master_v2_sessions;
 b mission_factory_owner.c384_human_bindings;loc public.locations;u uuid:=auth.uid();proof jsonb;authority_bundle jsonb;policy mission_factory_owner.quest_reward_policy_versions;
BEGIN
 IF mission_factory_owner.human_context_bound_v1(p_context,'5ab4234b32294cc26472855447e6230f62c5e07308768816ae0c2ea304d94366') IS DISTINCT FROM true THEN RAISE EXCEPTION 'HUMAN_SERVER_COMMAND_CONTEXT_INVALID' USING ERRCODE='42501';END IF;

 IF u IS NULL OR auth.role() IS DISTINCT FROM 'authenticated' OR p_session IS NULL OR p_master IS NULL THEN RETURN NULL;END IF;
 SELECT * INTO q FROM mission_factory_owner.quest_run_sources WHERE session_id=p_session;
 SELECT * INTO a FROM mission_factory_owner.quest_arcs WHERE id=q.arc_id;
 SELECT * INTO m FROM public.master_v2_sessions WHERE id=p_session;
 SELECT * INTO b FROM mission_factory_owner.c384_human_bindings WHERE session_id=p_session;
 SELECT * INTO loc FROM public.locations WHERE id=q.location_id;
 IF q.session_id IS NULL OR a.id IS NULL OR m.id IS NULL OR b.session_id IS NULL OR loc.id IS NULL
 OR q.availability_scope IS DISTINCT FROM 'public' OR a.availability_scope IS DISTINCT FROM 'public'
 OR q.execution_context IS DISTINCT FROM a.execution_context OR a.execution_context NOT IN('public_real','staff_simulation')
 OR q.public_release_sha256 IS DISTINCT FROM a.public_release_sha256 OR q.public_release_sha256 IS NULL
 OR m.owner_kind IS DISTINCT FROM 'human' OR m.tipo IS DISTINCT FROM 'quest' OR m.mission_id IS NOT NULL
 OR b.assigned_master IS DISTINCT FROM m.master_user OR q.location_id IS DISTINCT FROM m.location_id
 OR loc.is_active IS DISTINCT FROM true OR loc.is_test IS DISTINCT FROM (a.execution_context='staff_simulation') OR (a.execution_context='public_real' AND coalesce(loc.is_exam_room,false)) OR (a.execution_context='staff_simulation' AND loc.id IS DISTINCT FROM '0b85f354-9cdb-47e1-baf9-3d266bb7e06b'::uuid)
 OR q.source_sha256 IS DISTINCT FROM b.source_sha256 OR q.roster_character_ids IS DISTINCT FROM a.member_character_ids
 OR (p_master AND (u IS DISTINCT FROM m.master_user OR public.master_v2_is_master(u) IS DISTINCT FROM true))
 OR (NOT p_master AND u IS DISTINCT FROM m.master_user AND NOT EXISTS(SELECT 1 FROM public.characters c WHERE c.id=ANY(q.roster_character_ids) AND c.user_id=u))
 THEN RETURN NULL;END IF;
 IF q.state NOT IN('terminal','cancelled') THEN
  proof:=mission_factory_owner.human_ordinary_authority_verified_v1(a.draft_id,a.draft_version,a.source_sha256,p_context);
  IF proof IS NOT NULL THEN authority_bundle:=jsonb_build_object('arc_id',a.id,'draft_id',a.draft_id,'draft_version',a.draft_version,'source_sha256',a.source_sha256,'observation_sha256',p_context->>'observation_sha256','authority',proof);END IF;
 END IF;
 IF mission_factory_owner.human_ordinary_arc_scope_verified_v1(a.id,q.state NOT IN('terminal','cancelled'),p_context,authority_bundle) IS DISTINCT FROM true THEN RETURN NULL;END IF;
 IF EXISTS(SELECT 1 FROM jsonb_array_elements(a.source_document->'npc_bindings') ca JOIN png_builder_internal.bundles cb ON cb.id=(ca->>'npc_version_id')::uuid JOIN public.nb_mechanical_versions cm ON cm.id=cb.mechanical_version_id WHERE cm.profile_kind='npc_custom') THEN PERFORM mission_factory_owner.human_custom_source_assert_verified_v1(a.draft_id,q.state NOT IN('terminal','cancelled'),p_context,authority_bundle);END IF;
 SELECT * INTO policy FROM mission_factory_owner.quest_reward_policy_versions WHERE id=a.reward_policy_id;
 IF policy.id IS NULL OR policy.document_sha256 IS DISTINCT FROM a.reward_policy_sha256
 OR policy.document_sha256 IS DISTINCT FROM mission_factory_owner.sha(policy.document)
 OR policy.document IS DISTINCT FROM mission_factory_owner.quest_reward_fixed30_document_v2()
 OR (a.execution_context='public_real' AND q.state NOT IN('terminal','cancelled') AND NOT EXISTS(SELECT 1 FROM mission_factory_owner.quest_fixed30_admission g WHERE g.singleton AND (g.public_enabled OR (mission_public_owner.human_positive_qualification_v1(a.public_release_sha256,true)->>'schema_version' IS NOT DISTINCT FROM 'human-owner-accepted-release/1')) AND g.public_release_sha256=a.public_release_sha256 AND (g.public_policy_id=a.reward_policy_id OR EXISTS(SELECT 1 FROM mission_factory_owner.quest_reward_policy_versions hp_new JOIN mission_factory_owner.quest_reward_policy_versions hp_old ON hp_old.id=g.public_policy_id
 WHERE hp_new.id=a.reward_policy_id AND hp_new.qualified AND hp_old.qualified AND hp_new.scope='staff' AND hp_old.scope='staff' AND hp_new.document_sha256='34197acc065af70dc89ac15d54c19044f4e5af07c91b5869eb0b360a0fcfef19' AND hp_old.document_sha256=hp_new.document_sha256 AND hp_new.document IS NOT DISTINCT FROM hp_old.document AND hp_new.document IS NOT DISTINCT FROM mission_factory_owner.quest_reward_fixed30_document_v2() AND mission_factory_owner.sha(hp_new.document)=hp_new.document_sha256 AND mission_factory_owner.sha(hp_old.document)=hp_old.document_sha256
 AND EXISTS(SELECT 1 FROM mission_factory_owner.quest_fixed30_policy_requests hp_q JOIN mission_factory_owner.catalog_versions hp_cv ON hp_cv.version=hp_q.catalog_version AND hp_cv.active AND hp_cv.qualified AND hp_cv.document_sha256=hp_q.catalog_sha256 AND hp_cv.document_sha256=mission_factory_owner.sha(hp_cv.document) WHERE hp_q.policy_id=hp_new.id AND hp_q.document_sha256=hp_new.document_sha256 AND hp_q.catalog_version=a.source_document->>'catalog_version'))) AND g.public_qualification_sha256 IS NOT NULL))
 THEN RETURN NULL;END IF;
 RETURN jsonb_build_object('schema_version','human-ordinary-source/1','native_session_id',p_session,'quest_arc_id',q.arc_id,'quest_episode_id',q.episode_id,'source_sha256',q.source_sha256,'release_sha256',a.public_release_sha256,'execution_context',a.execution_context,'location_id',q.location_id,'assigned_master',m.master_user,'roster_character_ids',q.roster_character_ids,'effect_mode',CASE WHEN a.execution_context='public_real' THEN 'real' ELSE 'simulation' END,'reward_policy_id',a.reward_policy_id,'reward_policy_sha256',a.reward_policy_sha256);
END $function$;

CREATE OR REPLACE FUNCTION mission_factory_owner.human_ordinary_source_with_context_v1(p_session uuid, p_master boolean, p_context jsonb)
 RETURNS jsonb
 LANGUAGE plpgsql
 STABLE SECURITY DEFINER
 SET search_path TO ''
AS $function$
BEGIN
 IF mission_factory_owner.human_verified_context_valid_v1(p_context,'5ab4234b32294cc26472855447e6230f62c5e07308768816ae0c2ea304d94366') IS DISTINCT FROM true THEN RAISE EXCEPTION 'HUMAN_SERVER_COMMAND_CONTEXT_INVALID' USING ERRCODE='42501';END IF;
 RETURN mission_factory_owner.human_ordinary_source_verified_v1(p_session,p_master,p_context);
END;
$function$;

CREATE OR REPLACE FUNCTION mission_factory_owner.human_ordinary_arc_scope_verified_v1(p_arc uuid, p_live boolean, p_context jsonb, p_authority_bundle jsonb)
 RETURNS boolean
 LANGUAGE plpgsql
 STABLE SECURITY DEFINER
 SET search_path TO ''
AS $function$
DECLARE a mission_factory_owner.quest_arcs;pub mission_factory_owner.publications;d mission_factory_owner.drafts;h mission_factory_owner.c416_human_draft_sources;
BEGIN
 IF mission_factory_owner.human_context_bound_v1(p_context,'5ab4234b32294cc26472855447e6230f62c5e07308768816ae0c2ea304d94366') IS DISTINCT FROM true THEN RAISE EXCEPTION 'HUMAN_SERVER_COMMAND_CONTEXT_INVALID' USING ERRCODE='42501';END IF;

 IF auth.uid() IS NULL OR auth.role() IS DISTINCT FROM 'authenticated' OR p_arc IS NULL OR p_live IS NULL THEN RETURN false;END IF;
 SELECT * INTO a FROM mission_factory_owner.quest_arcs WHERE id=p_arc;
 SELECT * INTO pub FROM mission_factory_owner.publications WHERE request_key=a.publication_request;
 SELECT * INTO d FROM mission_factory_owner.drafts WHERE id=a.draft_id;
 SELECT * INTO h FROM mission_factory_owner.c416_human_draft_sources WHERE draft_id=d.id;
 IF a.id IS NULL OR pub.request_key IS NULL OR d.id IS NULL OR h.draft_id IS NULL
 OR a.availability_scope IS DISTINCT FROM 'public' OR a.public_release_sha256 IS NULL
 OR a.source_document->>'content_kind' IS DISTINCT FROM 'quest_human' OR pub.content_kind IS DISTINCT FROM 'quest_human'
 OR a.source_sha256 IS DISTINCT FROM mission_factory_owner.sha(a.source_document)
 OR a.source_document IS DISTINCT FROM d.document OR a.source_sha256 IS DISTINCT FROM d.document_sha256
 OR a.draft_version IS DISTINCT FROM d.control_version OR a.draft_version IS DISTINCT FROM h.authoring_version
 OR a.source_sha256 IS DISTINCT FROM h.human_document_sha256 OR d.author_user IS DISTINCT FROM h.author_user
 OR pub.quest_arc_id IS DISTINCT FROM a.id OR pub.source_sha256 IS DISTINCT FROM a.source_sha256
 OR pub.release_revision_sha256 IS DISTINCT FROM a.public_release_sha256
 OR a.execution_context NOT IN('public_real','staff_simulation') THEN RETURN false;END IF;
 IF a.execution_context='public_real' THEN
  IF pub.target IS DISTINCT FROM 'public' OR pub.state NOT IN('open','scheduled')
  OR mission_public_owner.human_positive_qualification_v1(a.public_release_sha256,p_live) IS NULL THEN RETURN false;END IF;
 ELSE
  IF pub.target IS DISTINCT FROM 'staff' OR pub.state IS DISTINCT FROM 'staff' OR cardinality(a.execution_auth_ids) IS DISTINCT FROM 2 OR NOT coalesce(auth.uid()=ANY(a.execution_auth_ids),false) THEN RETURN false;END IF;
 END IF;
 -- Existing exact public-Staff manifest or real release+reward binding; no new flag or actor list.
 PERFORM mission_factory_owner.human_ordinary_execution_read_assert_verified_v1(a.id,p_live,p_context,p_authority_bundle);
 RETURN true;
END $function$;

CREATE OR REPLACE FUNCTION mission_factory_owner.human_ordinary_arc_scope_with_context_v1(p_arc uuid, p_live boolean, p_context jsonb)
 RETURNS boolean
 LANGUAGE plpgsql
 STABLE SECURITY DEFINER
 SET search_path TO ''
AS $function$
BEGIN
 IF mission_factory_owner.human_verified_context_valid_v1(p_context,'5ab4234b32294cc26472855447e6230f62c5e07308768816ae0c2ea304d94366') IS DISTINCT FROM true THEN RAISE EXCEPTION 'HUMAN_SERVER_COMMAND_CONTEXT_INVALID' USING ERRCODE='42501';END IF;
 RETURN mission_factory_owner.human_ordinary_arc_scope_verified_v1(p_arc,p_live,p_context,NULL::jsonb);
END;
$function$;

CREATE OR REPLACE FUNCTION mission_factory_owner.human_ordinary_execution_read_assert_verified_v1(p_arc uuid, p_active boolean, p_context jsonb, p_authority_bundle jsonb)
 RETURNS void
 LANGUAGE plpgsql
 STABLE SECURITY DEFINER
 SET search_path TO ''
AS $function$
declare a mission_factory_owner.quest_arcs;g mission_factory_owner.quest_fixed30_admission;rel mission_public_owner.release_admissions_v1;proof jsonb;
begin
 IF mission_factory_owner.human_context_bound_v1(p_context,'5ab4234b32294cc26472855447e6230f62c5e07308768816ae0c2ea304d94366') IS DISTINCT FROM true THEN RAISE EXCEPTION 'HUMAN_SERVER_COMMAND_CONTEXT_INVALID' USING ERRCODE='42501';END IF;

 select * into strict a from mission_factory_owner.quest_arcs where id=p_arc;
 IF a.availability_scope IS DISTINCT FROM 'public' OR a.source_document->>'content_kind' IS DISTINCT FROM 'quest_human' THEN RAISE EXCEPTION 'HUMAN_ORDINARY_EXECUTION_KIND_REQUIRED' USING ERRCODE='42501';END IF;
 IF p_authority_bundle IS NOT NULL AND (mission_factory_owner.keys_exact_v2(p_authority_bundle,ARRAY['arc_id','draft_id','draft_version','source_sha256','observation_sha256','authority']) IS DISTINCT FROM true OR p_authority_bundle->>'arc_id' IS DISTINCT FROM a.id::text OR p_authority_bundle->>'draft_id' IS DISTINCT FROM a.draft_id::text OR p_authority_bundle->>'draft_version' IS DISTINCT FROM a.draft_version::text OR p_authority_bundle->>'source_sha256' IS DISTINCT FROM a.source_sha256 OR p_authority_bundle->>'observation_sha256' IS DISTINCT FROM p_context->>'observation_sha256' OR jsonb_typeof(p_authority_bundle->'authority') IS DISTINCT FROM 'object') THEN RAISE EXCEPTION 'HUMAN_PRIVATE_AUTHORITY_BINDING_INVALID' USING ERRCODE='42501';END IF;
 if p_active then
  IF p_authority_bundle IS NULL THEN proof:=mission_factory_owner.human_ordinary_authority_verified_v1(a.draft_id,a.draft_version,a.source_sha256,p_context);ELSE proof:=p_authority_bundle->'authority';END IF;
  if proof is null or proof->>'execution_context' is distinct from a.execution_context or proof->>'revision_sha256' is distinct from a.public_release_sha256
  or(a.execution_context='staff_simulation' and (proof->>'qualification_sha256' is distinct from a.execution_qualification_sha256 or proof->'allowed_auth_ids' is distinct from to_jsonb(a.execution_auth_ids)))
  then raise exception 'MF_QUEST_EXECUTION_AUTHORITY_DRIFT' using errcode='55000';end if;
 end if;
 if a.execution_context='public_real' then perform mission_factory_owner.human_ordinary_release_read_assert_v1(a.public_release_sha256,a.reward_policy_id,p_active);return;end if;
 if a.execution_qualification_sha256 is null or cardinality(a.execution_auth_ids)<>2 or array_position(a.execution_auth_ids,null) is not null
 or(select count(distinct x) from unnest(a.execution_auth_ids)x)<>2
 or a.source_sha256<>mission_factory_owner.sha(a.source_document)
 then raise exception 'MF_QUEST_STAFF_CONTEXT_SOURCE_DRIFT' using errcode='40001';end if;
 select * into strict rel from mission_public_owner.release_admissions_v1 where release_sha256=a.public_release_sha256;
 if rel.contract_version<>'mission-public-admission/1' or nullif(btrim(rel.independent_review_ref),'') is null
 then raise exception 'MF_QUEST_STAFF_CONTEXT_RELEASE_UNQUALIFIED' using errcode='55000';end if;
 if p_active then
  select * into strict g from mission_factory_owner.quest_fixed30_admission where singleton;
  if not g.public_staff_enabled or mission_factory_owner.c416_kind_live_v1() IS DISTINCT FROM true or mission_factory_owner.c444_enabled_v1() IS DISTINCT FROM true
  or g.public_staff_qualification_sha256 is distinct from a.execution_qualification_sha256
  or g.public_staff_release_sha256 is distinct from a.public_release_sha256 or g.allowed_auth_ids is distinct from a.execution_auth_ids
  or g.public_staff_draft_id<>a.draft_id or g.public_staff_draft_version<>a.draft_version or g.public_staff_source_sha256<>a.source_sha256
  then raise exception 'MF_QUEST_STAFF_CONTEXT_UNQUALIFIED' using errcode='55000';end if;
 end if;
 if exists(select 1 from unnest(a.member_character_ids)x(id) left join public.characters c on c.id=x.id
 where c.id is null or not(c.user_id=any(a.execution_auth_ids)))
 then raise exception 'MF_QUEST_STAFF_CONTEXT_ACTOR_SCOPE' using errcode='42501';end if;
end $function$;

CREATE OR REPLACE FUNCTION mission_factory_owner.human_ordinary_execution_read_assert_with_context_v1(p_arc uuid, p_active boolean, p_context jsonb)
 RETURNS void
 LANGUAGE plpgsql
 STABLE SECURITY DEFINER
 SET search_path TO ''
AS $function$
BEGIN
 IF mission_factory_owner.human_verified_context_valid_v1(p_context,'5ab4234b32294cc26472855447e6230f62c5e07308768816ae0c2ea304d94366') IS DISTINCT FROM true THEN RAISE EXCEPTION 'HUMAN_SERVER_COMMAND_CONTEXT_INVALID' USING ERRCODE='42501';END IF;
 PERFORM mission_factory_owner.human_ordinary_execution_read_assert_verified_v1(p_arc,p_active,p_context,NULL::jsonb);
 RETURN;
END;
$function$;

CREATE OR REPLACE FUNCTION mission_factory_owner.human_custom_source_assert_verified_v1(p_draft uuid, p_active boolean, p_context jsonb, p_authority_bundle jsonb)
 RETURNS jsonb
 LANGUAGE plpgsql
 STABLE SECURITY DEFINER
 SET search_path TO ''
AS $function$
DECLARE d mission_factory_owner.drafts;ar mission_factory_owner.quest_arcs;sp mission_public_owner.public_qualification_attestations_v1;cap jsonb;observed jsonb;continuity_authorized boolean:=false;verified_authority jsonb;
BEGIN
 IF p_active THEN

 IF mission_factory_owner.human_context_bound_v1(p_context,'5ab4234b32294cc26472855447e6230f62c5e07308768816ae0c2ea304d94366') IS DISTINCT FROM true THEN RAISE EXCEPTION 'HUMAN_SERVER_COMMAND_CONTEXT_INVALID' USING ERRCODE='42501';END IF;
 END IF;

 IF p_active IS NULL OR p_draft IS NULL OR auth.uid() IS NULL OR auth.role() IS DISTINCT FROM 'authenticated' THEN RAISE EXCEPTION 'HUMAN_CUSTOM_SOURCE_AUTH' USING ERRCODE='42501';END IF;
 SELECT * INTO STRICT d FROM mission_factory_owner.drafts WHERE id=p_draft;
 SELECT * INTO STRICT ar FROM mission_factory_owner.quest_arcs WHERE draft_id=d.id AND source_sha256=d.document_sha256;
 SELECT * INTO sp FROM mission_public_owner.public_qualification_attestations_v1 WHERE release_sha256=mission_factory_owner.sha(jsonb_build_object('schema_version','human-custom-source-key/1','publication_request',ar.publication_request));
 IF NOT mission_factory_owner.keys_exact_v2(sp.payload,ARRAY['schema_version','capability_sha256','base_release_sha256','publication_request','draft_id','draft_version','source_sha256','arc_id','actor_user']) OR sp.created_by IS DISTINCT FROM 'postgres'::name OR sp.payload_sha256 IS DISTINCT FROM mission_factory_owner.sha(sp.payload)
 OR sp.payload->>'schema_version' IS DISTINCT FROM 'human-custom-source/1' OR sp.payload->>'base_release_sha256' IS DISTINCT FROM '5ab4234b32294cc26472855447e6230f62c5e07308768816ae0c2ea304d94366'
 OR sp.payload->>'publication_request' IS DISTINCT FROM ar.publication_request::text OR sp.payload->>'draft_id' IS DISTINCT FROM d.id::text OR sp.payload->>'draft_version' IS DISTINCT FROM ar.draft_version::text
 OR sp.payload->>'source_sha256' IS DISTINCT FROM ar.source_sha256 OR sp.payload->>'arc_id' IS DISTINCT FROM ar.id::text OR sp.payload->>'actor_user' IS DISTINCT FROM ar.created_by::text
 OR ar.public_release_sha256 IS DISTINCT FROM '5ab4234b32294cc26472855447e6230f62c5e07308768816ae0c2ea304d94366' OR ar.availability_scope IS DISTINCT FROM 'public' OR ar.source_document IS DISTINCT FROM d.document OR ar.source_sha256 IS DISTINCT FROM mission_factory_owner.sha(d.document)
 THEN RAISE EXCEPTION 'HUMAN_CUSTOM_SOURCE_PROVENANCE_DRIFT' USING ERRCODE='40001';END IF;
 IF NOT EXISTS(SELECT 1 FROM mission_public_owner.release_admissions_v1 cr WHERE cr.release_sha256=sp.payload->>'capability_sha256' AND cr.contract_version='mission-public-admission/1') THEN RAISE EXCEPTION 'HUMAN_CUSTOM_SOURCE_RELEASE_HISTORY_MISSING' USING ERRCODE='40001';END IF;
 IF p_authority_bundle IS NOT NULL AND (mission_factory_owner.keys_exact_v2(p_authority_bundle,ARRAY['arc_id','draft_id','draft_version','source_sha256','observation_sha256','authority']) IS DISTINCT FROM true OR p_authority_bundle->>'arc_id' IS DISTINCT FROM ar.id::text OR p_authority_bundle->>'draft_id' IS DISTINCT FROM ar.draft_id::text OR p_authority_bundle->>'draft_version' IS DISTINCT FROM ar.draft_version::text OR p_authority_bundle->>'source_sha256' IS DISTINCT FROM ar.source_sha256 OR p_authority_bundle->>'observation_sha256' IS DISTINCT FROM p_context->>'observation_sha256' OR jsonb_typeof(p_authority_bundle->'authority') IS DISTINCT FROM 'object') THEN RAISE EXCEPTION 'HUMAN_PRIVATE_AUTHORITY_BINDING_INVALID' USING ERRCODE='42501';END IF;
 IF p_active THEN
 observed:=(p_context->'observation');
 IF sp.payload->>'capability_sha256' IS DISTINCT FROM observed->>'observed_revision_sha256' THEN
  IF ar.execution_context='staff_simulation' THEN IF p_authority_bundle IS NULL THEN verified_authority:=mission_factory_owner.human_ordinary_authority_verified_v1(ar.draft_id,ar.draft_version,ar.source_sha256,p_context);ELSE verified_authority:=p_authority_bundle->'authority';END IF;END IF;
  IF ar.execution_context='staff_simulation' AND (verified_authority->>'qualification_sha256') IS NOT DISTINCT FROM ar.execution_qualification_sha256 THEN continuity_authorized:=true;
  ELSE RAISE EXCEPTION 'HUMAN_CUSTOM_SOURCE_CURRENT_RELEASE_DRIFT' USING ERRCODE='40001';END IF;
 END IF;
 cap:=mission_factory_owner.human_custom_ordinary_capability_verified_v1(p_draft,ar.execution_context='public_real',p_context);
 IF cap IS NULL OR (cap->>'capability_sha256' IS DISTINCT FROM sp.payload->>'capability_sha256' AND NOT(continuity_authorized AND cap->>'capability_sha256'=observed->>'observed_revision_sha256')) OR cap->>'execution_context' IS DISTINCT FROM ar.execution_context THEN RAISE EXCEPTION 'HUMAN_CUSTOM_SOURCE_NOT_QUALIFIED' USING ERRCODE='55000';END IF;END IF;
 RETURN sp.payload;
END
$function$;

CREATE OR REPLACE FUNCTION mission_factory_owner.human_custom_source_assert_with_context_v1(p_draft uuid, p_active boolean, p_context jsonb)
 RETURNS jsonb
 LANGUAGE plpgsql
 STABLE SECURITY DEFINER
 SET search_path TO ''
AS $function$
BEGIN
 IF p_active THEN
 IF mission_factory_owner.human_verified_context_valid_v1(p_context,'5ab4234b32294cc26472855447e6230f62c5e07308768816ae0c2ea304d94366') IS DISTINCT FROM true THEN RAISE EXCEPTION 'HUMAN_SERVER_COMMAND_CONTEXT_INVALID' USING ERRCODE='42501';END IF;
 END IF;
 RETURN mission_factory_owner.human_custom_source_assert_verified_v1(p_draft,p_active,p_context,NULL::jsonb);
END;
$function$;

CREATE OR REPLACE FUNCTION mission_factory_owner.human_compatibility_identity_v1(p_release text, p_active boolean)
 RETURNS jsonb
 LANGUAGE plpgsql
 STABLE SECURITY DEFINER
 SET search_path TO ''
AS $function$
DECLARE old_identity mission_public_owner.public_qualification_attestations_v1;old_release mission_public_owner.release_admissions_v1;
 current_release mission_public_owner.release_admissions_v1;proof mission_public_owner.public_qualification_attestations_v1;
 base_tuple jsonb;v jsonb;result jsonb;graph jsonb;actual jsonb;historical jsonb;records integer:=0;key text;
BEGIN
 IF p_release IS DISTINCT FROM '5ab4234b32294cc26472855447e6230f62c5e07308768816ae0c2ea304d94366' OR p_active IS NULL THEN RETURN NULL;END IF;
 -- Literal false uses the unchanged full historical identity checks, never active compatibility.
 historical:=mission_factory_owner.human_ordinary_release_identity_v1(p_release,false);
 IF historical IS NULL OR historical->>'revision_sha256' IS DISTINCT FROM p_release OR historical->>'observed_revision_sha256' IS DISTINCT FROM p_release THEN RETURN NULL;END IF;
 SELECT * INTO old_release FROM mission_public_owner.release_admissions_v1 WHERE release_sha256=p_release;
 key:=mission_factory_owner.sha(jsonb_build_object('schema_version','human-release-identity-key/1','human_release_sha256',p_release));
 SELECT * INTO old_identity FROM mission_public_owner.public_qualification_attestations_v1 WHERE release_sha256=key;
 IF old_release.release_sha256 IS NULL OR old_identity.release_sha256 IS NULL OR old_identity.created_by IS DISTINCT FROM 'postgres'::name
 OR old_identity.payload_sha256 IS DISTINCT FROM mission_factory_owner.sha(old_identity.payload)
 OR old_identity.payload->>'schema_version' IS DISTINCT FROM 'human-ordinary-release-identity/1'
 OR old_identity.payload->>'human_release_sha256' IS DISTINCT FROM p_release
 OR old_identity.payload->>'canonical_preimage' IS NULL
 OR encode(extensions.digest(convert_to(old_identity.payload->>'canonical_preimage','UTF8'),'sha256'),'hex') IS DISTINCT FROM p_release
 OR old_identity.payload->'canonical_tuple' IS DISTINCT FROM (old_identity.payload->>'canonical_preimage')::jsonb
 OR old_identity.payload->>'source_review_ref' IS DISTINCT FROM old_release.independent_review_ref THEN RETURN NULL;END IF;
 base_tuple:=old_identity.payload->'canonical_tuple';
 FOR proof IN SELECT * FROM mission_public_owner.public_qualification_attestations_v1 WHERE payload->>'schema_version'='human-release-compatibility/1' AND payload->>'base_release_sha256'=p_release LOOP
  IF proof.created_by IS DISTINCT FROM 'postgres'::name OR proof.payload_sha256 IS DISTINCT FROM mission_factory_owner.sha(proof.payload)
  OR NOT mission_factory_owner.keys_exact_v2(proof.payload,ARRAY['schema_version','base_release_sha256','base_canonical_tuple_sha256','current_release_sha256','current_canonical_tuple','independent_review_ref','review_sha256','review_findings','semantic_manifest_sha256','compatible_scope','ordinary_custom_runtime_qa'])
  OR proof.payload->>'base_canonical_tuple_sha256' IS DISTINCT FROM p_release
  OR proof.payload->>'compatible_scope' IS DISTINCT FROM 'legacy-human-ordinary'
  OR proof.payload->>'ordinary_custom_runtime_qa' IS DISTINCT FROM 'NOT_RUN'
  OR proof.payload->'review_findings' IS DISTINCT FROM '{"P0":0,"P1":0,"P2":0}'::jsonb
  OR coalesce(proof.payload->>'review_sha256','')!~'^[0-9a-f]{64}$' OR coalesce(proof.payload->>'semantic_manifest_sha256','')!~'^[0-9a-f]{64}$'
  OR nullif(btrim(proof.payload->>'independent_review_ref'),'') IS NULL THEN CONTINUE;END IF;
  v:=proof.payload->'current_canonical_tuple';
  IF NOT mission_factory_owner.keys_exact_v2(v,ARRAY['schema_version','base_release_sha256','db_core','client','edge','config'])
  OR v->>'schema_version' IS DISTINCT FROM 'human-custom-ordinary-release-tuple/1'
  OR v->>'base_release_sha256' IS DISTINCT FROM p_release
  OR proof.payload->>'current_release_sha256' IS DISTINCT FROM mission_factory_owner.sha(v)
  OR proof.release_sha256 IS DISTINCT FROM mission_factory_owner.sha(jsonb_build_object('schema_version','human-release-compatibility-key/1','base_release_sha256',p_release,'current_release_sha256',mission_factory_owner.sha(v)))
  OR v#>>'{db_core,sha256}' IS DISTINCT FROM mission_factory_owner.sha(v#>'{db_core,functions}')
  OR v#>>'{client,sha256}' IS DISTINCT FROM mission_factory_owner.sha(v#>'{client,bindings}')
  OR v#>'{client,bindings}' IS DISTINCT FROM base_tuple#>'{client,bindings}'
  OR v#>>'{edge,sha256}' IS DISTINCT FROM mission_factory_owner.sha(v#>'{edge,bindings}')
  OR v#>>'{edge,bindings,npc_media_attest,sha256}' IS DISTINCT FROM '135e95a86cd357fa7badf29eb62418e058589a4c2bec9c164f850dcfda1bf266'
  OR v#>'{edge,bindings,npc_media_attest,version}' IS DISTINCT FROM '2'::jsonb
  OR v#>'{edge,bindings,npc_media_attest,verify_jwt}' IS DISTINCT FROM 'true'::jsonb
  OR v#>>'{config,sha256}' IS DISTINCT FROM mission_factory_owner.sha(v#>'{config,policy}') THEN CONTINUE;END IF;
  SELECT * INTO current_release FROM mission_public_owner.release_admissions_v1 WHERE release_sha256=mission_factory_owner.sha(v);
  IF current_release.release_sha256 IS NULL OR current_release.contract_version IS DISTINCT FROM 'mission-public-admission/1'
  OR current_release.db_sha256 IS DISTINCT FROM v#>>'{db_core,sha256}' OR current_release.client_sha256 IS DISTINCT FROM v#>>'{client,sha256}'
  OR current_release.edge_sha256 IS DISTINCT FROM v#>>'{edge,sha256}' OR current_release.configuration_sha256 IS DISTINCT FROM v#>>'{config,sha256}'
  OR current_release.independent_review_ref IS DISTINCT FROM proof.payload->>'independent_review_ref'
  OR proof.positive_staff_evidence_ref IS DISTINCT FROM 'SOURCE_REVIEW_ONLY:'||current_release.independent_review_ref
  OR current_release.staff_evidence_ref IS DISTINCT FROM 'AUTHORIZED_TEST_MANIFEST:'||proof.authorized_test_manifest_ref THEN CONTINUE;END IF;
  graph:=v#>'{db_core,functions}';
  IF jsonb_typeof(graph) IS DISTINCT FROM 'array' OR jsonb_array_length(graph)<>111
  OR (SELECT jsonb_agg(to_jsonb(z->>'lookup_signature') ORDER BY z->>'lookup_signature') FROM jsonb_array_elements(graph)z) IS DISTINCT FROM (SELECT jsonb_agg(to_jsonb(value) ORDER BY value) FROM jsonb_array_elements_text($closed$["mission_factory_owner.c384_human_bind_seal_v1(uuid,uuid,bigint,uuid,uuid,uuid)","mission_factory_owner.c395_active_human_assert_v1(pg_catalog.uuid)","mission_factory_owner.c395_binding_insert_assert_v1(uuid,uuid,jsonb,text)","mission_factory_owner.c395_prepare_assert_v1(pg_catalog.uuid,pg_catalog.int8,pg_catalog.uuid,pg_catalog.uuid)","mission_factory_owner.c395_revision_issue_v1(uuid,bigint,uuid,uuid,uuid)","mission_factory_owner.c407_identity_v1(pg_catalog.uuid)","mission_factory_owner.c408_stage1_complete_assert_v1()","mission_factory_owner.c412_read_identity_v1(pg_catalog.uuid)","mission_factory_owner.c416_arc_assert_v1(pg_catalog.uuid,pg_catalog.bool)","mission_factory_owner.c416_draft_assert_v1(pg_catalog.uuid,pg_catalog.bool)","mission_factory_owner.c444_action_scope_v1(pg_catalog.uuid)","mission_factory_owner.c444_enrollment_open_v1(pg_catalog.uuid)","mission_factory_owner.c444_enrollment_v1(pg_catalog.uuid,pg_catalog.text,pg_catalog.bool,pg_catalog.int8,pg_catalog.uuid)","mission_factory_owner.c444_peaceful_boundary_v1(pg_catalog.uuid,pg_catalog.uuid)","mission_factory_owner.c444_peaceful_complete_v1(pg_catalog.uuid,pg_catalog.uuid)","mission_factory_owner.c444_peaceful_history_complete_v1(pg_catalog.uuid,pg_catalog.uuid)","mission_factory_owner.c444_read_identity_v1(pg_catalog.uuid)","mission_factory_owner.c444_runtime_ports_complete_assert_v1()","mission_factory_owner.c444_source_read_assert_v1(pg_catalog.uuid)","mission_factory_owner.c444_terminal_participants_finish_v1(pg_catalog.uuid,pg_catalog.uuid)","mission_factory_owner.c463_optin_complete_assert_v1()","mission_factory_owner.c463_optin_identity_v1(pg_catalog.uuid)","mission_factory_owner.human_compatibility_identity_v1(text,boolean)","mission_factory_owner.human_context_bound_v1(jsonb,text)","mission_factory_owner.human_custom_ordinary_capability_v1(uuid,boolean)","mission_factory_owner.human_custom_ordinary_capability_verified_v1(uuid,boolean,jsonb)","mission_factory_owner.human_custom_ordinary_capability_with_context_v1(uuid,boolean,jsonb)","mission_factory_owner.human_custom_source_assert_v1(uuid,boolean)","mission_factory_owner.human_custom_source_assert_verified_v1(uuid,boolean,jsonb,jsonb)","mission_factory_owner.human_custom_source_assert_with_context_v1(uuid,boolean,jsonb)","mission_factory_owner.human_existing_legacy_media_pair_v1(pg_catalog.uuid,pg_catalog.uuid)","mission_factory_owner.human_ordinary_arc_scope_v1(pg_catalog.uuid,pg_catalog.bool)","mission_factory_owner.human_ordinary_arc_scope_verified_v1(uuid,boolean,jsonb,jsonb)","mission_factory_owner.human_ordinary_arc_scope_with_context_v1(uuid,boolean,jsonb)","mission_factory_owner.human_ordinary_authoring_qualification_v1(pg_catalog.text)","mission_factory_owner.human_ordinary_authority_v1(pg_catalog.uuid,pg_catalog.int8,pg_catalog.text)","mission_factory_owner.human_ordinary_authority_verified_v1(uuid,bigint,text,jsonb)","mission_factory_owner.human_ordinary_authority_with_context_v1(uuid,bigint,text,jsonb)","mission_factory_owner.human_ordinary_deep_validate_v1(pg_catalog.uuid,pg_catalog.jsonb)","mission_factory_owner.human_ordinary_enrollment_open_v1(pg_catalog.uuid)","mission_factory_owner.human_ordinary_execution_read_assert_v1(pg_catalog.uuid,pg_catalog.bool)","mission_factory_owner.human_ordinary_execution_read_assert_verified_v1(uuid,boolean,jsonb,jsonb)","mission_factory_owner.human_ordinary_execution_read_assert_with_context_v1(uuid,boolean,jsonb)","mission_factory_owner.human_ordinary_final_terminal_v1(pg_catalog.uuid)","mission_factory_owner.human_ordinary_npc_bundle_assert_v1(pg_catalog.uuid)","mission_factory_owner.human_ordinary_participants_finish_v1(pg_catalog.uuid,pg_catalog.uuid)","mission_factory_owner.human_ordinary_peaceful_boundary_v1(pg_catalog.uuid,pg_catalog.uuid)","mission_factory_owner.human_ordinary_peaceful_complete_v1(pg_catalog.uuid,pg_catalog.uuid)","mission_factory_owner.human_ordinary_peaceful_history_complete_v1(pg_catalog.uuid,pg_catalog.uuid)","mission_factory_owner.human_ordinary_preview_basis_v1(pg_catalog.uuid,pg_catalog.int8,pg_catalog.bool)","mission_factory_owner.human_ordinary_release_identity_v1(pg_catalog.text,pg_catalog.bool)","mission_factory_owner.human_ordinary_release_read_assert_v1(pg_catalog.text,pg_catalog.uuid,pg_catalog.bool)","mission_factory_owner.human_ordinary_reward_apply_v1(pg_catalog.uuid,pg_catalog.uuid,pg_catalog.text,pg_catalog.text,pg_catalog.uuid)","mission_factory_owner.human_ordinary_reward_authority_v1(pg_catalog.uuid,pg_catalog.uuid)","mission_factory_owner.human_ordinary_source_v1(pg_catalog.uuid,pg_catalog.bool)","mission_factory_owner.human_ordinary_source_verified_v1(uuid,boolean,jsonb)","mission_factory_owner.human_ordinary_source_with_context_v1(uuid,boolean,jsonb)","mission_factory_owner.human_ordinary_terminal_core_v1(pg_catalog.uuid,pg_catalog.uuid,pg_catalog.text,pg_catalog.uuid)","mission_factory_owner.human_release_observation_valid_v1(jsonb,text,boolean)","mission_factory_owner.human_staff_context_records_v1(jsonb,text,uuid,text,mission_factory_owner.quest_fixed30_admission)","mission_factory_owner.human_staff_lease_valid_v1(jsonb,uuid,boolean)","mission_factory_owner.human_staff_lease_valid_verified_v1(jsonb,uuid,boolean,jsonb)","mission_factory_owner.human_staff_lease_valid_with_context_v1(jsonb,uuid,boolean,jsonb)","mission_factory_owner.human_verified_context_v1(text)","mission_factory_owner.human_verified_context_valid_v1(jsonb,text)","mission_factory_owner.npc_custom_authoring_check_v1(uuid,bigint,text,boolean)","mission_factory_owner.npc_custom_combat_runtime_assert_v1(uuid,uuid,uuid,uuid)","mission_factory_owner.npc_item_v2(uuid,uuid,text,boolean)","mission_factory_owner.npc_reference(uuid,uuid,boolean)","mission_factory_owner.quest_combat_insert_guard_v1()","mission_factory_owner.quest_compile_check_v1(pg_catalog.uuid)","mission_factory_owner.quest_compile_v1(pg_catalog.uuid)","mission_factory_owner.quest_deep_validate_v2(uuid,jsonb)","mission_factory_owner.quest_execution_assert_v4(pg_catalog.uuid,pg_catalog.bool)","mission_factory_owner.quest_public_open_v3(uuid)","mission_factory_owner.quest_publication_scope_v3(pg_catalog.uuid,pg_catalog.bool)","mission_generic_owner.regia_human_direction_context_v1(uuid)","mission_public_owner.human_positive_qualification_attest_v1(pg_catalog.text,pg_catalog.uuid,pg_catalog.text,pg_catalog.text,pg_catalog.jsonb)","mission_public_owner.human_positive_qualification_v1(pg_catalog.text,pg_catalog.bool)","mission_public_owner.human_session_allowed_v1(pg_catalog.uuid)","png_builder_internal.npc_custom_combat_attest_assert_v1(uuid,uuid,uuid)","png_builder_internal.npc_custom_combat_source_v1(uuid,uuid)","png_builder_internal.npc_media_pair_resolve_v1(uuid,uuid)","public.master_v2_encounter_open_ninja_book_v1_human_ai_core(uuid,uuid[],jsonb,jsonb,uuid)","public.mission_factory_create_v1(uuid,jsonb,text)","public.mission_factory_npc_certify_combat_v1(uuid,uuid,uuid)","public.mission_factory_npc_certify_existing_combat_receipt_v1(pg_catalog.uuid,pg_catalog.uuid,pg_catalog.uuid)","public.mission_factory_npc_certify_existing_combat_v1(pg_catalog.uuid,pg_catalog.uuid,pg_catalog.int8,pg_catalog.uuid)","public.mission_factory_quest_d100_bind_v1(pg_catalog.uuid,pg_catalog.uuid,pg_catalog.text,pg_catalog.text,pg_catalog.uuid,pg_catalog.uuid,pg_catalog.text,pg_catalog.text,pg_catalog.int8,pg_catalog.uuid)","public.mission_factory_quest_d100_binding_scope_v1(pg_catalog.uuid)","public.mission_factory_quest_episode_state_v2(uuid)","public.mission_factory_quest_human_d100_consume_v1(pg_catalog.uuid,pg_catalog.uuid,pg_catalog.text)","public.mission_factory_quest_human_ordinary_authoring_receipt_v1(pg_catalog.uuid,pg_catalog.text)","public.mission_factory_quest_human_ordinary_control_receipt_v1(pg_catalog.uuid,pg_catalog.uuid,pg_catalog.text)","public.mission_factory_quest_human_ordinary_create_v1(pg_catalog.uuid,pg_catalog.int8,pg_catalog.jsonb,pg_catalog._uuid,pg_catalog.uuid)","public.mission_factory_quest_human_ordinary_episode_context_v1(pg_catalog.uuid)","public.mission_factory_quest_human_ordinary_import_v1(pg_catalog.uuid,pg_catalog.int8,pg_catalog.jsonb,pg_catalog._uuid,pg_catalog.uuid,pg_catalog.int8,pg_catalog.uuid)","public.mission_factory_quest_human_ordinary_lifecycle_receipt_v1(pg_catalog.uuid,pg_catalog.uuid,pg_catalog.text)","public.mission_factory_quest_human_ordinary_participant_state_v1(pg_catalog.uuid)","public.mission_factory_quest_human_ordinary_preview_v1(pg_catalog.uuid,pg_catalog.int8)","public.mission_factory_quest_human_ordinary_publish_v1(pg_catalog.uuid,pg_catalog.int8,pg_catalog.text,pg_catalog.uuid,pg_catalog.text,pg_catalog.timestamptz)","public.mission_factory_quest_human_ordinary_runtime_state_v1(pg_catalog.uuid)","public.mission_factory_quest_human_ordinary_terminal_publish_v1(pg_catalog.uuid,pg_catalog.uuid,pg_catalog.text,pg_catalog.uuid)","public.mission_factory_quest_human_regia_optin_v1(pg_catalog.uuid,pg_catalog.int8,pg_catalog.text,pg_catalog.uuid)","public.mission_factory_quest_human_route_v1(pg_catalog.uuid)","public.mission_factory_quest_human_runtime_state_v1(pg_catalog.uuid)","public.mission_factory_quest_human_successor_scope_v1(pg_catalog.uuid)","public.mission_factory_save_v1(uuid,bigint,jsonb,uuid)","public.npc_combat_approve_v1(uuid,uuid,bigint,uuid)","public.npc_combat_save_v1(uuid,uuid,bigint,uuid,jsonb)","public.npc_combat_submit_review_v1(uuid,uuid,bigint,uuid)"]$closed$::jsonb))
  OR EXISTS(SELECT 1 FROM jsonb_array_elements(graph)x WHERE x->>'oid' IS NULL OR coalesce(x->>'oid','')!~'^[1-9][0-9]*$') THEN CONTINUE;END IF;
  IF p_active THEN
   SELECT jsonb_agg(jsonb_build_object('lookup_signature',x->>'lookup_signature','oid',proc.oid::text,'body_md5',md5(proc.prosrc),'input_arg_types',(SELECT coalesce(jsonb_agg(format('%I.%I',n.nspname,t.typname) ORDER BY z.ord),'[]'::jsonb) FROM unnest(proc.proargtypes::oid[])WITH ORDINALITY z(id,ord) JOIN pg_type t ON t.oid=z.id JOIN pg_namespace n ON n.oid=t.typnamespace),'all_arg_types',(SELECT coalesce(jsonb_agg(format('%I.%I',n.nspname,t.typname) ORDER BY z.ord),'[]'::jsonb) FROM unnest(coalesce(proc.proallargtypes,proc.proargtypes::oid[]))WITH ORDINALITY z(id,ord) JOIN pg_type t ON t.oid=z.id JOIN pg_namespace n ON n.oid=t.typnamespace),'arg_names',coalesce(to_jsonb(proc.proargnames),'null'::jsonb),'arg_modes',to_jsonb(coalesce(proc.proargmodes,array_fill('i'::"char",ARRAY[proc.pronargs]))),'return_type',(SELECT format('%I.%I',n.nspname,t.typname) FROM pg_type t JOIN pg_namespace n ON n.oid=t.typnamespace WHERE t.oid=proc.prorettype),'returns_set',proc.proretset,'default_arg_count',proc.pronargdefaults,'defaults',pg_get_expr(proc.proargdefaults,0),'variadic_type',CASE WHEN proc.provariadic=0 THEN NULL ELSE (SELECT format('%I.%I',n.nspname,t.typname) FROM pg_type t JOIN pg_namespace n ON n.oid=t.typnamespace WHERE t.oid=proc.provariadic) END,'strict',proc.proisstrict,'volatility',proc.provolatile::text,'parallel',proc.proparallel::text,'security_definer',proc.prosecdef,'language',(SELECT lanname FROM pg_language WHERE oid=proc.prolang),'configuration',proc.proconfig,'owner',pg_get_userbyid(proc.proowner),'execute',(SELECT coalesce(jsonb_agg(CASE WHEN acl.grantee=0 THEN 'PUBLIC' ELSE pg_get_userbyid(acl.grantee) END ORDER BY CASE WHEN acl.grantee=0 THEN 'PUBLIC' ELSE pg_get_userbyid(acl.grantee) END),'[]'::jsonb) FROM aclexplode(coalesce(proc.proacl,acldefault('f',proc.proowner)))acl WHERE acl.privilege_type='EXECUTE')) ORDER BY x->>'lookup_signature') INTO actual FROM jsonb_array_elements(graph)x JOIN pg_proc proc ON proc.oid=to_regprocedure(x->>'lookup_signature');
   IF actual IS DISTINCT FROM (SELECT jsonb_agg(x ORDER BY x->>'lookup_signature') FROM jsonb_array_elements(graph)x)
   OR EXISTS(SELECT 1 FROM jsonb_array_elements(graph)x JOIN pg_proc proc ON proc.oid=to_regprocedure(x->>'lookup_signature') WHERE proc.proleakproof OR EXISTS(SELECT 1 FROM aclexplode(coalesce(proc.proacl,acldefault('f',proc.proowner)))a WHERE a.is_grantable)) THEN CONTINUE;END IF;
  END IF;
  records:=records+1;
  result:=jsonb_build_object('schema_version','human-compatible-release-identity/1','singleton',true,'provenance_release_sha256',p_release,'revision_sha256',p_release,'observed_revision_sha256',current_release.release_sha256,'canonical_preimage',old_identity.payload->>'canonical_preimage','client_build','human-ordinary/1:'||p_release,'state','enabled','scope','staff','independent_review_ref',old_release.independent_review_ref,'observed_independent_review_ref',current_release.independent_review_ref,'staff_guards_verified',true,'published_assets_verified',true,'observed_canonical_tuple',v,'compatibility_sha256',proof.payload_sha256);
 END LOOP;
 IF records<>1 THEN RETURN NULL;END IF;RETURN result;
EXCEPTION WHEN invalid_text_representation OR invalid_parameter_value THEN RETURN NULL;
END $function$;

REVOKE ALL ON FUNCTION mission_factory_owner.human_context_bound_v1(jsonb,text) FROM PUBLIC,anon,authenticated,service_role;
GRANT EXECUTE ON FUNCTION mission_factory_owner.human_context_bound_v1(jsonb,text) TO postgres;

REVOKE ALL ON FUNCTION mission_factory_owner.human_ordinary_authority_verified_v1(uuid,bigint,text,jsonb) FROM PUBLIC,anon,authenticated,service_role;
GRANT EXECUTE ON FUNCTION mission_factory_owner.human_ordinary_authority_verified_v1(uuid,bigint,text,jsonb) TO postgres;

REVOKE ALL ON FUNCTION mission_factory_owner.human_custom_ordinary_capability_verified_v1(uuid,boolean,jsonb) FROM PUBLIC,anon,authenticated,service_role;
GRANT EXECUTE ON FUNCTION mission_factory_owner.human_custom_ordinary_capability_verified_v1(uuid,boolean,jsonb) TO postgres;

REVOKE ALL ON FUNCTION mission_factory_owner.human_staff_lease_valid_verified_v1(jsonb,uuid,boolean,jsonb) FROM PUBLIC,anon,authenticated,service_role;
GRANT EXECUTE ON FUNCTION mission_factory_owner.human_staff_lease_valid_verified_v1(jsonb,uuid,boolean,jsonb) TO postgres;

REVOKE ALL ON FUNCTION mission_factory_owner.human_ordinary_source_verified_v1(uuid,boolean,jsonb) FROM PUBLIC,anon,authenticated,service_role;
GRANT EXECUTE ON FUNCTION mission_factory_owner.human_ordinary_source_verified_v1(uuid,boolean,jsonb) TO postgres;

REVOKE ALL ON FUNCTION mission_factory_owner.human_ordinary_arc_scope_verified_v1(uuid,boolean,jsonb,jsonb) FROM PUBLIC,anon,authenticated,service_role;
GRANT EXECUTE ON FUNCTION mission_factory_owner.human_ordinary_arc_scope_verified_v1(uuid,boolean,jsonb,jsonb) TO postgres;

REVOKE ALL ON FUNCTION mission_factory_owner.human_ordinary_execution_read_assert_verified_v1(uuid,boolean,jsonb,jsonb) FROM PUBLIC,anon,authenticated,service_role;
GRANT EXECUTE ON FUNCTION mission_factory_owner.human_ordinary_execution_read_assert_verified_v1(uuid,boolean,jsonb,jsonb) TO postgres;

REVOKE ALL ON FUNCTION mission_factory_owner.human_custom_source_assert_verified_v1(uuid,boolean,jsonb,jsonb) FROM PUBLIC,anon,authenticated,service_role;
GRANT EXECUTE ON FUNCTION mission_factory_owner.human_custom_source_assert_verified_v1(uuid,boolean,jsonb,jsonb) TO postgres;
