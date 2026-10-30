"""E67 explicit versioned-content migration compiler. Static only; never executes SQL."""
from pathlib import Path
import json,hashlib,copy,re,ast,argparse,sys
j=lambda x:json.dumps(x,ensure_ascii=False,separators=(',',':'));sha=lambda x:hashlib.sha256(x.encode()).hexdigest();dq=lambda x,t:'$'+t+'$'+x+'$'+t+'$'
a=argparse.ArgumentParser();a.add_argument('--packet',default=str(Path(__file__).with_name('CONTENT_PACKET.json')));a.add_argument('--baseline-json',required=True);a.add_argument('--edge-package',required=True);a.add_argument('--material');a.add_argument('--out',required=True);o=a.parse_args();P=Path(o.out);P.mkdir(parents=True,exist_ok=True);b=Path(o.packet).parent.parent
p=json.loads(Path(o.packet).read_text());r=json.loads(Path(o.baseline_json).read_text());r=r[0]if isinstance(r,list)else r;baseline=r['canonical_preimage'];root=json.loads(baseline);assert sha(baseline)==r['revision_sha256']==r['observed_revision_sha256']=='e54fb7cf055ff0d5a41948218f52b3db5e4622314b037e9b001f8ef8fabdb176';assert len(root['db_core']['all_function_headers'])==246
edge=json.loads(Path(o.edge_package).read_text());assert edge['name']=='mission_generic_ai'and edge['verify_jwt']is False;ef=[{'name':f['name'],'bytes':len(f['content'].encode()),'sha256':sha(f['content'])}for f in edge['files']];assert len(ef)==16
semantic=sha(j({'schema':'editorial67-integrated/1','baseline':sha(baseline),'packet_sha256':sha(Path(o.packet).read_text()),'edge':ef,'UI_unchanged':root['ui']}));params={'schema':'editorial67-material/1','semantic':semantic,'review_ref':'C1266_EDITORIAL67_REVIEW.json','review_sha':'__E67_REVIEW_SHA__','p0':0,'p1':0,'p2':0,'edge_verified':False,'edge_version':'__E67_EDGE_VERSION__','edge_ezbr_sha256':'__E67_EDGE_SHA__'}
if o.material:params=json.loads(Path(o.material).read_text())
c=copy.deepcopy(root);c['contract']['code_identity_sha256']=semantic;c['recovery']['semantic_identity_sha256']=semantic;c['recovery']['editorial67']={'semantic':semantic,'review_ref':params['review_ref'],'review_sha256':params['review_sha'],'previous_root_sha256':sha(baseline),'method':'explicit_postgres_migration'}
c['edge_bundles'][0].update(version=params['edge_version'],ezbr_sha256=params['edge_ezbr_sha256'],files=ef);c['config']['c1266_manual_template']['source_scope']=p['expected_source_scope'];c['config']['editorial67']={'scope':'staff_future_starts','packet_sha256':sha(Path(o.packet).read_text()),'document_sha256':p['document_sha256'],'plan_version_id':p['new_ids']['plan_version_id'],'npc_versions':[x['version']['id']for x in p['cards']]}
ct=j(c);assert len(ct.encode())<=262144,len(ct.encode());assert c['db_core']==root['db_core']and c['ui']==root['ui']
# Reuse exact canonical capture expressions and reviewed ABI expectations; no function DDL.
head=Path('/private/tmp/tus-c1266-combat64-20261030/release30/HEADER_CAPTURE_FRAGMENT.sql').read_text();head=head.replace('INTO actual','INTO e67_actual').replace('to_regprocedure(sig)','to_regprocedure(e67_sig)').replace("'signature',sig","'signature',e67_sig")
tree=ast.parse(Path('/private/tmp/tus-c1266-combat64-20261030/release30/build_release30.py').read_text());abi=next(ast.literal_eval(n.value)for n in tree.body if isinstance(n,ast.Assign)and any(isinstance(t,ast.Name)and t.id=='abi_sql'for t in n.targets));abi=abi.replace('INTO abi','INTO e67_abi').replace('to_regprocedure(sig)','to_regprocedure(e67_sig)')
f66=json.loads(Path('/private/tmp/tus-c1266-editorial66-20261030/release9/DB_PACKET.json').read_text());abis=[{'signature':f['signature'],'abi':f['before']['abi']if f['before']else f['expected_abi']}for f in f66['functions']]+f66['preserved_abis']
preserve=Path('/private/tmp/tus-c1266-editorial66-20261030/postflight/PRESERVATION_QUERY.sql').read_text();old_expected=json.loads((b/'PRESERVATION_BASELINE.json').read_text());old_expected=old_expected[0]if isinstance(old_expected,list)else old_expected
if 'evidence'in old_expected:old_expected=old_expected['evidence']
ledger=Path('/private/tmp/tus-c1266-editorial66-20261030/postflight/LEDGER_QUERY.sql').read_text();e66_expected=json.loads((b/'E66_LEDGER_BASELINE.json').read_text());e66_expected=e66_expected[0]if isinstance(e66_expected,list)else e66_expected
if 'metadata'in e66_expected:e66_expected=e66_expected['metadata']
mat="""IF e67_params->>'schema'<>'editorial67-material/1'OR e67_params->>'semantic'<>'SEMANTIC'OR e67_params->>'review_ref'<>'C1266_EDITORIAL67_REVIEW.json'OR e67_params->'p0'<>'0'::jsonb OR e67_params->'p1'<>'0'::jsonb OR e67_params->'p2'<>'0'::jsonb OR coalesce(e67_params->>'review_sha','')!~'^[a-f0-9]{64}$'OR e67_params->'edge_verified'IS DISTINCT FROM'true'::jsonb OR jsonb_typeof(e67_params->'edge_version')<>'number'OR(e67_params->>'edge_version')::integer<=131 OR coalesce(e67_params->>'edge_ezbr_sha256','')!~'^[a-f0-9]{64}$'THEN RAISE EXCEPTION 'E67_MATERIAL_UNQUALIFIED';END IF;""".replace('SEMANTIC',semantic)
checks="""SELECT jsonb_build_object('public_launch',mission_public_owner.is_public_launch_v1((e67_packet#>>'{before,selection,mission_id}')::uuid),'generic_mode',(SELECT mode FROM mission_generic_owner.runtime_policy WHERE singleton),'capabilities',(SELECT jsonb_agg(jsonb_build_object('state',state,'config_version',config_version))FROM mission_launch_owner.capabilities WHERE mission_id=(e67_packet#>>'{before,selection,mission_id}')::uuid),'dual_scopes',(SELECT count(*)FROM mission_launch_owner.dual_scopes WHERE mission_id=(e67_packet#>>'{before,selection,mission_id}')::uuid),'activations',(SELECT count(*)FROM mission_ai_board_owner.activations WHERE mission_id=(e67_packet#>>'{before,selection,mission_id}')::uuid),'open_publication',(SELECT count(*)FROM mission_public_owner.publications_v2 WHERE mission_id=(e67_packet#>>'{before,selection,mission_id}')::uuid AND target='public'AND visibility='open'AND state='open'))INTO e67_actual;
 IF e67_actual IS DISTINCT FROM e67_packet->'availability_before'THEN RAISE EXCEPTION 'E67_AVAILABILITY_DRIFT';END IF;
 FOR e67_item IN SELECT value FROM jsonb_array_elements(e67_packet->'dependency_ddl_md5')LOOP
 IF md5(pg_get_functiondef(to_regprocedure(e67_item->>'signature')))IS DISTINCT FROM e67_item->>'ddl_md5'THEN RAISE EXCEPTION 'E67_HELPER_DEPENDENCY_DRIFT %',e67_item->>'signature';END IF;END LOOP;
 FOR e67_item IN SELECT value FROM jsonb_array_elements(e67_packet->'authoring_metadata')LOOP
 SELECT jsonb_build_object('relation',n.nspname||'.'||c.relname,'owner',pg_get_userbyid(c.relowner),'acl',c.relacl::text,'rls',c.relrowsecurity,'columns',(SELECT jsonb_agg(jsonb_build_object('name',a.attname,'type',format_type(a.atttypid,a.atttypmod),'notnull',a.attnotnull,'default',pg_get_expr(d.adbin,d.adrelid))ORDER BY a.attnum)FROM pg_attribute a LEFT JOIN pg_attrdef d ON d.adrelid=a.attrelid AND d.adnum=a.attnum WHERE a.attrelid=c.oid AND a.attnum>0 AND NOT a.attisdropped),'constraints',(SELECT jsonb_agg(jsonb_build_object('name',conname,'definition',pg_get_constraintdef(oid),'validated',convalidated)ORDER BY conname)FROM pg_constraint WHERE conrelid=c.oid),'indexes',(SELECT jsonb_agg(pg_get_indexdef(indexrelid)ORDER BY indexrelid::regclass::text)FROM pg_index WHERE indrelid=c.oid),'triggers',(SELECT jsonb_agg(jsonb_build_object('name',t.tgname,'definition',pg_get_triggerdef(t.oid),'enabled',t.tgenabled)ORDER BY t.tgname)FROM pg_trigger t WHERE t.tgrelid=c.oid AND NOT t.tgisinternal))INTO e67_actual FROM pg_class c JOIN pg_namespace n ON n.oid=c.relnamespace WHERE c.oid=to_regclass(e67_item->>'relation');
 IF e67_actual IS DISTINCT FROM e67_item THEN RAISE EXCEPTION 'E67_AUTHORING_SCHEMA_DRIFT %',e67_item->>'relation';END IF;END LOOP;
 FOR e67_item IN SELECT value FROM jsonb_array_elements(e67_base::jsonb#>'{db_core,all_function_headers}')LOOP e67_sig:=e67_item->>'signature';HEADER
 IF e67_actual IS DISTINCT FROM e67_item THEN RAISE EXCEPTION 'E67_HEADER_DRIFT %',e67_sig;END IF;END LOOP;
 FOR e67_item IN SELECT value FROM jsonb_array_elements(e67_abis)LOOP e67_sig:=e67_item->>'signature';ABI
 IF e67_abi IS DISTINCT FROM e67_item->'abi'THEN RAISE EXCEPTION 'E67_ABI_DRIFT %',e67_sig;END IF;END LOOP;
 PRESERVE
 IF e67_data IS DISTINCT FROM OLD_EXPECTED THEN RAISE EXCEPTION 'E67_OLD_HISTORY_DRIFT';END IF;
 LEDGER
 IF e67_data IS DISTINCT FROM E66_EXPECTED THEN RAISE EXCEPTION 'E67_E66_HISTORY_DRIFT';END IF;"""
decl="""DECLARE e67_base text:=BASELINE;e67_new text:=CANDIDATE;e67_params jsonb:=PARAMS;e67_packet jsonb:=PACKET;e67_abis jsonb:=ABIS;e67_item jsonb;e67_actual jsonb;e67_abi jsonb;e67_sig text;e67_data jsonb;e67_rr mission_factory_owner.editor_release_readiness;e67_card jsonb;e67_old jsonb;e67_newv jsonb;e67_binding jsonb;e67_doc jsonb;e67_plan jsonb;e67_before jsonb;e67_now timestamptz:=clock_timestamp();e67_source jsonb;e67_sha text;e67_receipt jsonb;e67_n integer;"""
pre="""BEGIN;DO $e67install$
DECL
BEGIN
 MAT
 IF current_user<>'postgres'THEN RAISE EXCEPTION 'E67_OPERATOR_REQUIRED';END IF;
 IF NOT pg_try_advisory_xact_lock(hashtextextended('C1266:GENERIC-AI:AVAILABILITY',0))THEN RAISE EXCEPTION 'E67_RELEASE_BUSY';END IF;
 SELECT * INTO STRICT e67_rr FROM mission_factory_owner.editor_release_readiness WHERE singleton FOR UPDATE NOWAIT;
 IF e67_rr.canonical_preimage IS DISTINCT FROM e67_base OR e67_rr.revision_sha256<>'BEFORE_SHA'OR e67_rr.observed_revision_sha256<>e67_rr.revision_sha256 OR e67_rr.state<>'enabled'OR e67_rr.scope<>'staff'OR NOT e67_rr.staff_guards_verified OR NOT e67_rr.published_assets_verified THEN RAISE EXCEPTION 'E67_ROOT_BASELINE_DRIFT';END IF;
 CHECKS
 IF NOT EXISTS(SELECT 1 FROM public.profiles pr JOIN public.characters ch ON ch.user_id=pr.id WHERE pr.id=(e67_packet->>'approval_user_id')::uuid AND pr.role='admin'AND ch.id=(e67_packet->>'approval_character_id')::uuid)THEN RAISE EXCEPTION 'E67_APPROVAL_PRINCIPAL_DRIFT';END IF;
 PERFORM 1 FROM public.missions WHERE id=(e67_packet#>>'{before,selection,mission_id}')::uuid FOR UPDATE;
 IF mission_generic_owner.mission_editor_snapshot((e67_packet#>>'{before,selection,mission_id}')::uuid)IS DISTINCT FROM e67_packet#>'{before,mission_snapshot}'
 OR EXISTS(SELECT 1 FROM public.master_v2_sessions WHERE mission_id=(e67_packet#>>'{before,selection,mission_id}')::uuid AND closed_at IS NULL)
 OR EXISTS(SELECT 1 FROM mission_ai_board_owner.activations WHERE mission_id=(e67_packet#>>'{before,selection,mission_id}')::uuid AND state NOT IN('closed','cancelled','completed','failed'))THEN RAISE EXCEPTION 'E67_FUTURE_SOURCE_ACTIVE_OR_DRIFT';END IF;
 SELECT to_jsonb(s)INTO e67_actual FROM mission_generic_owner.plan_selections s WHERE mission_id=(e67_packet#>>'{before,selection,mission_id}')::uuid FOR UPDATE;
 IF e67_actual IS DISTINCT FROM e67_packet#>'{before,selection}'THEN RAISE EXCEPTION 'E67_SELECTION_CAS_DRIFT';END IF;
 IF EXISTS(SELECT 1 FROM public.mission_plan_versions WHERE id=(e67_packet#>>'{new_ids,plan_version_id}')::uuid) OR EXISTS(SELECT 1 FROM mission_generic_owner.definitions WHERE id=(e67_packet#>>'{new_ids,definition_id}')::uuid) THEN RAISE EXCEPTION 'E67_PLANNED_ID_ALREADY_PRESENT';END IF;
 IF EXISTS(SELECT 1 FROM public.mission_plan_versions WHERE plan_id=(e67_packet#>>'{before,plan_version,plan_id}')::uuid AND versione>7)
 OR EXISTS(SELECT 1 FROM mission_generic_owner.plan_revisions WHERE request_key=(e67_packet#>>'{new_ids,request_id}')::uuid)
 THEN RAISE EXCEPTION 'E67_VERSION_TARGET_EXISTS';END IF;
 FOR e67_item IN SELECT value FROM jsonb_array_elements(e67_packet#>'{before,templates}')LOOP
 SELECT to_jsonb(t)INTO e67_actual FROM public.nb_templates t WHERE id=(e67_item->>'id')::uuid FOR UPDATE;
 IF e67_actual IS DISTINCT FROM e67_item THEN RAISE EXCEPTION 'E67_TEMPLATE_DRIFT';END IF;END LOOP;
 FOR e67_card IN SELECT value FROM jsonb_array_elements(e67_packet->'cards')LOOP
 e67_old:=e67_card->'before';e67_newv:=e67_card->'version';e67_binding:=e67_card->'binding';
 IF EXISTS(SELECT 1 FROM public.nb_template_versions WHERE id=(e67_newv->>'id')::uuid) OR EXISTS(SELECT 1 FROM public.nb_mechanical_bindings WHERE id=(e67_binding->>'id')::uuid OR narrative_version_id=(e67_newv->>'id')::uuid) OR EXISTS(SELECT 1 FROM ninja_book_internal.legacy_media_adoptions_v1 WHERE narrative_version_id=(e67_newv->>'id')::uuid)THEN RAISE EXCEPTION 'E67_PLANNED_PROFILE_BINDING_ALREADY_PRESENT';END IF;
 SELECT to_jsonb(v)INTO e67_actual FROM public.nb_template_versions v WHERE id=(e67_old->>'id')::uuid FOR UPDATE;
 IF e67_actual IS DISTINCT FROM e67_old OR EXISTS(SELECT 1 FROM public.nb_template_versions WHERE template_id=(e67_old->>'template_id')::uuid AND version_no>6)THEN RAISE EXCEPTION 'E67_PROFILE_CAS_DRIFT';END IF;
 SELECT to_jsonb(v)INTO e67_actual FROM public.nb_mechanical_bindings v WHERE id=(e67_card#>>'{binding_before,id}')::uuid FOR SHARE;
 IF e67_actual IS DISTINCT FROM e67_card->'binding_before'THEN RAISE EXCEPTION 'E67_BINDING_DRIFT';END IF;
 IF e67_newv->'knowledge_boundary'IS DISTINCT FROM e67_old->'knowledge_boundary'OR e67_newv#>'{skeleton,knowledge_limits}'IS DISTINCT FROM e67_old#>'{skeleton,knowledge_limits}'OR e67_newv->'mechanical_template_id'IS DISTINCT FROM e67_old->'mechanical_template_id'THEN RAISE EXCEPTION 'E67_KNOWLEDGE_MECHANICS_DELTA_FORBIDDEN';END IF;
 INSERT INTO public.nb_template_versions(id,template_id,version_no,schema_version,supersedes_version_id,mechanical_template_id,skeleton,knowledge_boundary,fallback_profile,content_sha256,review_state,approved_by,approved_at,created_by,created_at,control_version,updated_at)
 VALUES((e67_newv->>'id')::uuid,(e67_newv->>'template_id')::uuid,7,e67_newv->>'schema_version',(e67_old->>'id')::uuid,(e67_newv->>'mechanical_template_id')::uuid,e67_newv->'skeleton',e67_newv->'knowledge_boundary',e67_newv->'fallback_profile',e67_newv->>'content_sha256','approved',(e67_packet->>'approval_user_id')::uuid,e67_now,(e67_packet->>'approval_user_id')::uuid,e67_now,1,e67_now);
 IF NOT EXISTS(SELECT 1 FROM public.nb_template_versions WHERE id=(e67_newv->>'id')::uuid AND content_sha256=e67_newv->>'content_sha256')THEN RAISE EXCEPTION 'E67_NEW_PROFILE_HASH';END IF;
 UPDATE public.nb_template_versions SET review_state='inactive',control_version=control_version+1,updated_at=e67_now WHERE id=(e67_old->>'id')::uuid AND review_state='approved'AND control_version=(e67_old->>'control_version')::bigint;
 IF NOT FOUND THEN RAISE EXCEPTION 'E67_OLD_PROFILE_LIFECYCLE_CAS';END IF;
 UPDATE public.nb_templates SET current_version_id=(e67_newv->>'id')::uuid,control_version=control_version+1,updated_at=e67_now WHERE id=(e67_old->>'template_id')::uuid AND current_version_id=(e67_old->>'id')::uuid;
 IF NOT FOUND THEN RAISE EXCEPTION 'E67_TEMPLATE_SUCCESSOR_CAS';END IF;
 INSERT INTO public.nb_mechanical_bindings(id,narrative_template_id,narrative_version_id,mechanical_template_id,mechanical_version_id,lifecycle_state,active,control_version,created_at,updated_at)
 VALUES((e67_binding->>'id')::uuid,(e67_binding->>'narrative_template_id')::uuid,(e67_binding->>'narrative_version_id')::uuid,(e67_binding->>'mechanical_template_id')::uuid,(e67_binding->>'mechanical_version_id')::uuid,'approved',false,1,e67_now,e67_now);
 e67_receipt:=ninja_book_internal.append_legacy_narrative_binding_v1((e67_newv->>'template_id')::uuid,(e67_newv->>'id')::uuid);
 IF e67_receipt->>'binding_id'IS DISTINCT FROM e67_binding->>'id'OR e67_receipt->'active'IS DISTINCT FROM'false'::jsonb THEN RAISE EXCEPTION 'E67_LEGACY_BINDING_RECEIPT';END IF;
 e67_receipt:=ninja_book_internal.append_legacy_media_adoption_v1((e67_newv->>'template_id')::uuid,(e67_newv->>'id')::uuid,NULL,NULL);
 IF e67_receipt IS NULL OR e67_receipt->>'approval_kind'<>'system_migration' OR e67_receipt->>'narrative_version_id'<>e67_newv->>'id' THEN RAISE EXCEPTION 'E67_MEDIA_SUCCESSOR_RECEIPT';END IF;
 END LOOP;
 e67_doc:=e67_packet->'document';e67_plan:=e67_doc->'plan';
 INSERT INTO public.mission_plan_versions(id,plan_id,versione,stato,initial_step_key)VALUES((e67_packet#>>'{new_ids,plan_version_id}')::uuid,(e67_packet#>>'{before,plan_version,plan_id}')::uuid,8,'bozza',e67_plan->>'initial_step_key');
 INSERT INTO public.mission_plan_steps(plan_version_id,step_key,kind,public_objective,ordinal)SELECT(e67_packet#>>'{new_ids,plan_version_id}')::uuid,step_key,kind,public_objective,ordinal FROM public.mission_plan_steps WHERE plan_version_id=(e67_packet#>>'{before,plan_version,id}')::uuid;
 INSERT INTO public.mission_plan_transitions(plan_version_id,transition_key,from_step_key,to_step_key,event_kind,priority)SELECT(e67_packet#>>'{new_ids,plan_version_id}')::uuid,transition_key,from_step_key,to_step_key,event_kind,priority FROM public.mission_plan_transitions WHERE plan_version_id=(e67_packet#>>'{before,plan_version,id}')::uuid;
 INSERT INTO public.mission_plan_requirements(plan_version_id,transition_key,ordinal,step_kind,provider_owner,domain,source_kind,capability_key,feature_version,provider_contract_version,projection_version,fact_code,max_age_ms)SELECT(e67_packet#>>'{new_ids,plan_version_id}')::uuid,transition_key,ordinal,step_kind,provider_owner,domain,source_kind,capability_key,feature_version,provider_contract_version,projection_version,fact_code,max_age_ms FROM public.mission_plan_requirements WHERE plan_version_id=(e67_packet#>>'{before,plan_version,id}')::uuid;
 IF mission_internal.plan_snapshot((e67_packet#>>'{new_ids,plan_version_id}')::uuid)IS DISTINCT FROM e67_packet->'expected_plan_snapshot'THEN RAISE EXCEPTION 'E67_PLAN_MECHANICS_SNAPSHOT_DRIFT';END IF;
 PERFORM mission_generic_owner.validate_definition((e67_packet#>>'{new_ids,plan_version_id}')::uuid,e67_packet->'definition');
 PERFORM mission_internal.plan_approve((e67_packet#>>'{new_ids,plan_version_id}')::uuid,e67_packet->>'plan_sha256');
 IF mission_internal.fingerprint(e67_packet->'definition')<>e67_packet->>'definition_sha256'OR mission_internal.fingerprint(e67_doc)<>e67_packet->>'document_sha256'THEN RAISE EXCEPTION 'E67_CONTENT_HASH_DRIFT';END IF;
 INSERT INTO mission_generic_owner.definitions(id,plan_version_id,version,definition,definition_sha256,plan_sha256)VALUES((e67_packet#>>'{new_ids,definition_id}')::uuid,(e67_packet#>>'{new_ids,plan_version_id}')::uuid,1,e67_packet->'definition',e67_packet->>'definition_sha256',e67_packet->>'plan_sha256');
 e67_receipt:=jsonb_build_object('schema_version','mission-generic-plan-seal/1','mission_id',e67_packet#>>'{before,selection,mission_id}','plan_id',e67_packet#>>'{before,plan_version,plan_id}','plan_version_id',e67_packet#>>'{new_ids,plan_version_id}','version',8,'plan_sha256',e67_packet->>'plan_sha256','definition_id',e67_packet#>>'{new_ids,definition_id}','definition_sha256',e67_packet->>'definition_sha256','settings_sha256',e67_packet->>'settings_sha256','selected',false,'state','sealed');
 INSERT INTO mission_generic_owner.plan_revisions(plan_version_id,definition_id,mission_id,request_key,request_fingerprint,source_mission_sha256,settings,settings_sha256,result)
 VALUES((e67_packet#>>'{new_ids,plan_version_id}')::uuid,(e67_packet#>>'{new_ids,definition_id}')::uuid,(e67_packet#>>'{before,selection,mission_id}')::uuid,(e67_packet#>>'{new_ids,request_id}')::uuid,mission_internal.fingerprint(jsonb_build_object('mission',e67_packet#>>'{before,selection,mission_id}','request',e67_packet#>>'{new_ids,request_id}','expected_mission_sha256',e67_packet->>'source_mission_sha256','document',e67_plan)),e67_packet->>'source_mission_sha256',e67_packet->'settings',e67_packet->>'settings_sha256',e67_receipt);
 INSERT INTO mission_creation_owner.revisions(plan_version_id,mission_id,direction_mode,gathering_location_id,document,document_sha256,arena_sources,created_by)
 VALUES((e67_packet#>>'{new_ids,plan_version_id}')::uuid,(e67_packet#>>'{before,selection,mission_id}')::uuid,e67_packet#>>'{before,creation,direction_mode}',(e67_packet#>>'{before,creation,gathering_location_id}')::uuid,e67_doc,e67_packet->>'document_sha256',e67_packet#>'{before,creation,arena_sources}',(e67_packet->>'approval_user_id')::uuid);
 UPDATE mission_generic_owner.plan_selections SET plan_version_id=(e67_packet#>>'{new_ids,plan_version_id}')::uuid,control_version=control_version+1,selected_at=e67_now WHERE mission_id=(e67_packet#>>'{before,selection,mission_id}')::uuid AND plan_version_id=(e67_packet#>>'{before,selection,plan_version_id}')::uuid AND control_version=(e67_packet#>>'{before,selection,control_version}')::bigint;
 IF NOT FOUND THEN RAISE EXCEPTION 'E67_NEW_SELECTION_CAS';END IF;
 IF mission_generic_owner.historical_plan((e67_packet#>>'{before,selection,mission_id}')::uuid)IS DISTINCT FROM e67_packet->'expected_selection'THEN RAISE EXCEPTION 'E67_NEW_SELECTION_PROOF';END IF;
 FOR e67_card IN SELECT value FROM jsonb_array_elements(e67_packet->'cards')LOOP
 SELECT to_jsonb(v)INTO e67_actual FROM public.nb_template_versions v WHERE id=(e67_card#>>'{before,id}')::uuid;
 IF(e67_actual-ARRAY['review_state','control_version','updated_at'])IS DISTINCT FROM((e67_card->'before')-ARRAY['review_state','control_version','updated_at'])OR e67_actual->>'review_state'<>'inactive'OR(e67_actual->>'control_version')::bigint<>(e67_card#>>'{before,control_version}')::bigint+1 THEN RAISE EXCEPTION 'E67_V6_CONTENT_OR_PROVENANCE_MUTATED';END IF;
 SELECT to_jsonb(v)INTO e67_actual FROM public.nb_mechanical_bindings v WHERE id=(e67_card#>>'{binding_before,id}')::uuid;
 IF e67_actual IS DISTINCT FROM e67_card->'binding_before'THEN RAISE EXCEPTION 'E67_OLD_BINDING_MUTATED';END IF;
 END LOOP;
 FOR e67_item IN SELECT value FROM jsonb_array_elements(e67_packet#>'{before,templates}')LOOP
 SELECT to_jsonb(t)INTO e67_actual FROM public.nb_templates t WHERE id=(e67_item->>'id')::uuid;
 IF(e67_actual-ARRAY['current_version_id','control_version','updated_at'])IS DISTINCT FROM(e67_item-ARRAY['current_version_id','control_version','updated_at']) OR(e67_actual->>'control_version')::bigint<>(e67_item->>'control_version')::bigint+1 THEN RAISE EXCEPTION 'E67_TEMPLATE_EXTRA_MUTATION';END IF;END LOOP;
 SELECT to_jsonb(v)INTO e67_actual FROM public.mission_plan_versions v WHERE id=(e67_packet#>>'{before,plan_version,id}')::uuid;
 IF e67_actual IS DISTINCT FROM e67_packet#>'{before,plan_version}'THEN RAISE EXCEPTION 'E67_OLD_PLAN_MUTATED';END IF;
 SELECT to_jsonb(v)INTO e67_actual FROM mission_generic_owner.definitions v WHERE id=(e67_packet#>>'{before,definition,id}')::uuid;
 IF e67_actual IS DISTINCT FROM e67_packet#>'{before,definition}'THEN RAISE EXCEPTION 'E67_OLD_DEFINITION_MUTATED';END IF;
 SELECT to_jsonb(v)INTO e67_actual FROM mission_generic_owner.plan_revisions v WHERE plan_version_id=(e67_packet#>>'{before,plan_revision,plan_version_id}')::uuid;
 IF e67_actual IS DISTINCT FROM e67_packet#>'{before,plan_revision}'THEN RAISE EXCEPTION 'E67_OLD_SEAL_RECEIPT_MUTATED';END IF;
 SELECT jsonb_agg(to_jsonb(v)ORDER BY narrative_version_id)INTO e67_actual FROM ninja_book_internal.legacy_media_adoptions_v1 v WHERE narrative_version_id IN(SELECT(value#>>'{before,id}')::uuid FROM jsonb_array_elements(e67_packet->'cards'));
 IF e67_actual IS DISTINCT FROM e67_packet#>'{before,media_adoptions}'THEN RAISE EXCEPTION 'E67_OLD_MEDIA_RECEIPT_MUTATED';END IF;
 SELECT to_jsonb(v)INTO e67_actual FROM mission_creation_owner.revisions v WHERE plan_version_id=(e67_packet#>>'{before,creation,plan_version_id}')::uuid;
 IF e67_actual IS DISTINCT FROM e67_packet#>'{before,creation}'THEN RAISE EXCEPTION 'E67_OLD_AUTHORING_MUTATED';END IF;
 CHECKS
 IF octet_length(e67_new)>262144 OR strpos(e67_new,'__E67_')>0 THEN RAISE EXCEPTION 'E67_UNMATERIAL_ROOT';END IF;
 e67_sha:=encode(extensions.digest(convert_to(e67_new,'UTF8'),'sha256'),'hex');
 UPDATE mission_factory_owner.editor_release_readiness SET canonical_preimage=e67_new,revision_sha256=e67_sha,observed_revision_sha256=e67_sha,client_build='mission-factory-admin/2:'||e67_sha,independent_review_ref='C1266_EDITORIAL67_REVIEW.json',updated_at=e67_now WHERE singleton AND revision_sha256='BEFORE_SHA';
 IF NOT FOUND THEN RAISE EXCEPTION 'E67_ROOT_CAS_LOST';END IF;
END $e67install$;COMMIT;
"""
vals={'DECL':decl,'MAT':mat,'CHECKS':checks,'HEADER':head,'ABI':abi,'PRESERVE':preserve.replace(' evidence;',' INTO e67_data;'),'LEDGER':ledger.replace('metadata;','INTO e67_data;'),'BASELINE':dq(baseline,'e67base'),'CANDIDATE':dq(ct,'e67root'),'PARAMS':dq(j(params),'e67params')+'::jsonb','PACKET':dq(j(p),'e67packet')+'::jsonb','ABIS':dq(j(abis),'e67abis')+'::jsonb','OLD_EXPECTED':dq(j(old_expected),'e67old')+'::jsonb','E66_EXPECTED':dq(j(e66_expected),'e67e66')+'::jsonb','BEFORE_SHA':sha(baseline)}
sql=pre
for _ in range(4):sql=re.sub(r'\b('+'|'.join(vals)+r')\b',lambda m:vals[m.group(0)],sql)
sys.path.insert(0,'/private/tmp/tus-c1266-recover46-20261027/output50/parse_tools312');from pglast import parse_sql,parse_plpgsql
nodes=parse_sql(sql)
for n in nodes:
 if type(n.stmt).__name__=='DoStmt':parse_plpgsql('DO '+dq(n.stmt.args[0].arg.sval,'e67parse'))
(P/'INSTALL.sql').write_text(sql);(P/'ROOT_TEMPLATE.json').write_text(ct);(P/'MATERIAL_TEMPLATE.json').write_text(json.dumps(params,indent=2));(P/'MANIFEST.json').write_text(json.dumps({'schema':'editorial67-release/1','semantic':semantic,'baseline_root':sha(baseline),'baseline_canonical_preimage':baseline,'root_bytes':len(ct.encode()),'all246headers_unchanged':True,'approval_user_id':p['approval_user_id'],'new_rows':{'nb_template_versions':2,'nb_mechanical_bindings':2,'legacy_media_adoptions':2,'mission_plan_versions':1,'mission_plan_steps':4,'mission_plan_transitions':4,'mission_plan_requirements':4,'definitions':1,'plan_revisions':1,'creation_revisions':1},'existing_rows_changed_only':'2V6lifecyclemetadata+2templatecurrentpointers+1selectedfutureplan+RootCAS; no Fati/session/provider changes','all10ABIs_unchanged':True,'UI_unchanged':True,'new_functions':0,'new_constraints':0,'SQL_sha256':sha(sql),'SQL_bytes':len(sql.encode()),'SQL_nodes':len(nodes),'SQL_parse':True,'PL_parse':True,'new_source_scope':p['expected_source_scope'],'approval_provenance':p['approval_provenance'],'provider_calls':0,'runtime_quality':'NOT_TESTED_NO_NEW_GENERATION','edge_files':ef},indent=2));print(j({'semantic':semantic,'root_bytes':len(ct.encode()),'SQL_sha256':sha(sql),'SQL_nodes':len(nodes)}))
# Readonly postflight: metadata and hashes only. No scene-state getter or provider request.
reverse='d.definition::text'
for x in p['cards']:
 for field,oldf,newf in [('version','before','version'),('binding','binding_before','binding')]:reverse="replace("+reverse+",'"+x[newf]['id']+"','"+x[oldf]['id']+"')"
sourceq="""WITH packet AS(SELECT PACKET AS p),cards AS(SELECT x.value c FROM packet CROSS JOIN LATERAL jsonb_array_elements(p->'cards')x),cardproof AS(
 SELECT nv.id,nv.template_id,nv.version_no,nv.review_state,nv.content_sha256,
 nv.content_sha256=c#>>'{version,content_sha256}'AS new_profile_hash_valid,
 nv.knowledge_boundary=ov.knowledge_boundary AND nv.skeleton->'knowledge_limits'=ov.skeleton->'knowledge_limits'AS knowledge_unchanged,
 ov.content_sha256=c#>>'{before,content_sha256}'AS old_V6_content_hash_unchanged,
 (to_jsonb(ov)-ARRAY['review_state','control_version','updated_at'])=((c->'before')-ARRAY['review_state','control_version','updated_at'])AND ov.review_state='inactive'AND ov.control_version=(c#>>'{before,control_version}')::bigint+1 AS old_V6_only_lifecycle_metadata_changed,
 t.current_version_id=nv.id AND t.lifecycle_state='approved'AS current_V7_selected,
 b.narrative_version_id=nv.id AND b.mechanical_template_id=(c#>>'{binding_before,mechanical_template_id}')::uuid AND b.mechanical_version_id=(c#>>'{binding_before,mechanical_version_id}')::uuid AND b.lifecycle_state='approved'AND NOT b.active AS same_mechanics_inactive_binding,
 to_jsonb(ob)=c->'binding_before'AS old_binding_unchanged,
 a.receipt->>'approval_kind'='system_migration'AND a.receipt->'actor_id'='null'::jsonb AND a.new_content_sha256=nv.content_sha256 AND a.previous_content_sha256=ov.content_sha256 AND a.receipt_sha256=ninja_book_internal.json_hash(a.receipt) AS real_migration_media_receipt,
 a.media_id=(SELECT (value->>'media_id')::uuid FROM packet CROSS JOIN LATERAL jsonb_array_elements(p#>'{before,media_adoptions}')value WHERE value->>'narrative_version_id'=ov.id::text)AS same_media_asset,
 nv.created_by=(SELECT(p->>'approval_user_id')::uuid FROM packet)AND nv.approved_by=nv.created_by AS explicit_mandate_author
 FROM cards JOIN public.nb_template_versions nv ON nv.id=(c#>>'{version,id}')::uuid JOIN public.nb_template_versions ov ON ov.id=(c#>>'{before,id}')::uuid JOIN public.nb_templates t ON t.id=nv.template_id JOIN public.nb_mechanical_bindings b ON b.id=(c#>>'{binding,id}')::uuid JOIN public.nb_mechanical_bindings ob ON ob.id=(c#>>'{binding_before,id}')::uuid JOIN ninja_book_internal.legacy_media_adoptions_v1 a ON a.narrative_version_id=nv.id),planproof AS(
 SELECT v.id,v.versione,v.stato,v.plan_sha256,v.plan_sha256=mission_internal.plan_fingerprint(v.id)AND v.plan_sha256=p->>'plan_sha256'AS plan_hash_valid,
 d.id AS definition_id,d.definition_sha256=mission_internal.fingerprint(d.definition)AND d.definition_sha256=p->>'definition_sha256'AS definition_hash_valid,
 r.document_sha256=mission_internal.fingerprint(r.document)AND r.document_sha256=p->>'document_sha256'AS document_hash_valid,
 r.document->'arenas'=p#>'{before,creation,document,arenas}'AS arenas_unchanged,
 REVERSE::jsonb=p#>'{before,definition,definition}'AS definition_mechanics_unchanged_except_narrative_binding_ids,
 mission_internal.plan_snapshot(v.id)=p->'expected_plan_snapshot'AS steps_transitions_requirements_unchanged,
 mission_generic_owner.historical_plan((p#>>'{before,selection,mission_id}')::uuid)=p->'expected_selection'AS selection_CAS_source_valid,
 mission_internal.fingerprint(mission_generic_owner.historical_plan((p#>>'{before,selection,mission_id}')::uuid))=p#>>'{expected_source_scope,source_sha256}'AS source_hash_valid,
 (SELECT canonical_preimage::jsonb#>'{config,c1266_manual_template,source_scope}'FROM mission_factory_owner.editor_release_readiness WHERE singleton)=p->'expected_source_scope'AS future_Staff_Root_scope_matches,
 mission_generic_owner.mission_editor_snapshot((p#>>'{before,selection,mission_id}')::uuid)=p#>'{before,mission_snapshot}'AS mission_metadata_unchanged,
 to_jsonb(ov)=p#>'{before,plan_version}'AND to_jsonb(od)=p#>'{before,definition}'AND to_jsonb(orv)=p#>'{before,creation}'AND to_jsonb(opr)=p#>'{before,plan_revision}'AS old_V7_plan_definition_document_receipt_unchanged
 FROM packet JOIN public.mission_plan_versions v ON v.id=(p#>>'{new_ids,plan_version_id}')::uuid JOIN mission_generic_owner.definitions d ON d.id=(p#>>'{new_ids,definition_id}')::uuid JOIN mission_creation_owner.revisions r ON r.plan_version_id=v.id JOIN public.mission_plan_versions ov ON ov.id=(p#>>'{before,plan_version,id}')::uuid JOIN mission_generic_owner.definitions od ON od.id=(p#>>'{before,definition,id}')::uuid JOIN mission_creation_owner.revisions orv ON orv.plan_version_id=ov.id JOIN mission_generic_owner.plan_revisions opr ON opr.plan_version_id=ov.id)
 SELECT jsonb_build_object('cards',(SELECT jsonb_agg(to_jsonb(x)ORDER BY id)FROM cardproof x),'plan',(SELECT to_jsonb(x)FROM planproof x),'availability',jsonb_build_object('public_launch',mission_public_owner.is_public_launch_v1((p#>>'{before,selection,mission_id}')::uuid),'generic_mode',(SELECT mode FROM mission_generic_owner.runtime_policy WHERE singleton),'capabilities',(SELECT jsonb_agg(jsonb_build_object('state',state,'config_version',config_version))FROM mission_launch_owner.capabilities WHERE mission_id=(p#>>'{before,selection,mission_id}')::uuid),'dual_scopes',(SELECT count(*)FROM mission_launch_owner.dual_scopes WHERE mission_id=(p#>>'{before,selection,mission_id}')::uuid),'activations',(SELECT count(*)FROM mission_ai_board_owner.activations WHERE mission_id=(p#>>'{before,selection,mission_id}')::uuid),'open_publication',(SELECT count(*)FROM mission_public_owner.publications_v2 WHERE mission_id=(p#>>'{before,selection,mission_id}')::uuid AND target='public'AND visibility='open'AND state='open')),'expected_availability',p->'availability_before','providers_new',0,'quality','NOT_RUN_NO_NEW_TEST')metadata FROM packet;"""
sourceq=re.sub(r'\bPACKET\b',lambda _:dq(j(p),'e67postpacket')+'::jsonb',sourceq);sourceq=re.sub(r'\bREVERSE\b',lambda _:reverse,sourceq)
postqueries={'POSTFLIGHT_SOURCE_QUERY.sql':sourceq,'POSTFLIGHT_ROOT_QUERY.sql':Path('/private/tmp/tus-c1266-editorial66-20261030/postflight/ROOT_QUERY.sql').read_text(),'POSTFLIGHT_PRESERVATION_QUERY.sql':preserve,'POSTFLIGHT_E66_QUERY.sql':ledger}
for n,q in postqueries.items():parse_sql(q);(P/n).write_text(q)
m=json.loads((P/'MANIFEST.json').read_text());m['postflight_queries']={n:{'sha256':sha(q),'bytes':len(q.encode()),'readonly':True,'SQL_parse':True}for n,q in postqueries.items()};(P/'MANIFEST.json').write_text(json.dumps(m,indent=2))
