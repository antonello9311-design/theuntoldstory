from pathlib import Path
import json,hashlib,copy,ast,argparse,sys,re
D=Path('/private/tmp/tus-c1266-editorial57-20261029');sha=lambda b:hashlib.sha256(b).hexdigest();js=lambda x:json.dumps(x,ensure_ascii=False,separators=(',',':'));lit=lambda s,t:'$'+t+'$'+s+'$'+t+'$'
p=argparse.ArgumentParser();p.add_argument('--materialization');args=p.parse_args();base=(D/'BASELINE_ROOT.txt').read_text();assert sha(base.encode())=='8f29e4dee0edf936380f42f855f109aa7819daa99ab505adffa013aeb3761568';root=json.loads(base)
ui_version=re.search(r"export const VERSION='([^']+)';",(D/'ui/mission-generic-ui.mjs').read_text()).group(1)
ui=json.loads((D/'ui/MANIFEST.json').read_text());edge=json.loads((D/'EDGE_PACKAGE.json').read_text());content=json.loads((D/'content/CONTENT_MANIFEST.json').read_text());cmsha=sha((D/'content/CONTENT_MANIFEST.json').read_bytes())
# Actual system inputs, not a string version label, define the new editorial semantics.
semproof={'schema_version':'editorial57-integrated-semantics/1','predecessor_root':sha(base.encode()),'predecessor_semantic':root['contract']['code_identity_sha256'],'DB_source42_sha256':sha(Path('/Users/antonello/Desktop/theuntoldstory/management/candidati/NARRATORE-UNIFICATO_2026-09-02/candidato/exam_human_master/C1266_NARRATIVE56_DB_SOURCE.sql').read_bytes()),'Edge_files':[{'name':f['name'],'sha256':sha(f['content'].encode())} for f in edge['files']],'UI_files':ui['files'],'UI_module_version':ui_version,'Root_import_graph_policy':'unchanged legacy baseline field; exact new UI files/pin/build carry current attestation','Root_evidence_path':'management/candidati/NARRATORE-UNIFICATO_2026-09-02/candidato/exam_human_master/C1266_NARRATIVE56_EVIDENCE.json','NPC_candidate_sha256':sha((D/'content/NPC_V5_CANDIDATE.json').read_bytes()),'mission_document_candidate_sha256':sha((D/'content/MISSION_DOCUMENT_V5_CANDIDATE.json').read_bytes()),'content_manifest_sha256':cmsha,'scope':'Editorial instructions, future versioned cards/phases, complete N56 renderer and publication read. No fourth start, no provider, no old Fato edit.'};semantic=sha(js(semproof).encode())
M={'schema_version':'editorial57-materialization/1','review_sha256':'__REVIEW_SHA256__','UI_git_head':'__UI_GIT_HEAD__','Edge_version':119,'Edge_ezbr_sha256':'__EDGE_EZBR_SHA256__','source_scope':{'mission_id':'6d6c216a-222d-4cba-b2fc-f3e0c199c195','plan_version_id':'__NEW_PLAN_UUID__','definition_id':'__NEW_DEFINITION_UUID__','definition_sha256':'__NEW_DEFINITION_SHA256__','plan_sha256':'__NEW_PLAN_SHA256__','source_sha256':'__NEW_SOURCE_SHA256__','PG_count':2,'PNG_count':2},'materialized_document_sha256':'__DOCUMENT_SHA256__','approval_version_ids':['__DAICHI_VERSION_UUID__','__KEITA_VERSION_UUID__'],'approval_content_sha256':['__DAICHI_CONTENT_SHA256__','__KEITA_CONTENT_SHA256__'],'authoring_readback_verified':False,'assets_full_readback_verified':False,'domain_build_verified':False}
if args.materialization:M=json.loads(Path(args.materialization).read_text())
c=copy.deepcopy(root);c['contract']['code_identity_sha256']=semantic;c['recovery']['semantic_identity_sha256']=semantic;c['recovery']['evidence']={'path':'management/candidati/NARRATORE-UNIFICATO_2026-09-02/candidato/exam_human_master/C1266_NARRATIVE56_EVIDENCE.json','review_ref':'C1266_NARRATIVE56_REVIEW.json','review_sha256':M['review_sha256']}
c['ui'].update(build=ui['build'],narrative_scene_build=ui['build'],narrative_scene_version=ui_version,git_head=M['UI_git_head'],verified=True,module_pin=ui['import_pin'])
for name,meta in ui['files'].items():c['ui']['files'][name]={'bytes':meta['bytes'],'sha256':meta['sha256'],'git_blob':meta['git_blob']}
assert c['ui']['import_graph_sha256']==root['ui']['import_graph_sha256'] # Historical baseline field, not a new graph attestation.
c['edge_bundles']=[{'name':'mission_generic_ai','status':'ACTIVE','version':M['Edge_version'],'verify_jwt':False,'ezbr_sha256':M['Edge_ezbr_sha256'],'files':[{'name':f['name'],'bytes':len(f['content'].encode()),'sha256':sha(f['content'].encode())} for f in edge['files']]}]
c['config']['c1266_manual_template']['source_scope']=M['source_scope'];c['config']['editorial57']={'schema_version':'editorial57-source/1','content_manifest_sha256':cmsha,'document_sha256':M['materialized_document_sha256'],'instructions':'response4-direction4-directScene','import_graph_field':'historical baseline unchanged; current UI files/pin/build are attested separately','scope':'staff_future_starts','fourth_started':False}
assert c['db_core']==root['db_core'];allowed={'c1266_manual_template','editorial57'};assert {k:v for k,v in c['config'].items() if k not in allowed}=={k:v for k,v in root['config'].items() if k not in allowed};assert {k:v for k,v in c['config']['c1266_manual_template'].items() if k!='source_scope'}=={k:v for k,v in root['config']['c1266_manual_template'].items() if k!='source_scope'}
cs=js(c);assert len(cs.encode())<262144
# Reuse the exact catalog reader; no SQL function is installed or repinned.
mod=ast.parse(Path('/private/tmp/tus-c1266-narrative56-20261029/build_root_release.py').read_text());strings={}
for n in mod.body:
 if isinstance(n,ast.Assign) and isinstance(n.value,ast.Constant) and isinstance(n.value.value,str):
  for t in n.targets:
   if isinstance(t,ast.Name):strings[t.id]=n.value.value
headers=strings['header_sql'];preserve=(D/'PRESERVATION_QUERY.sql').read_text();assert preserve.count(' AS preservation;')==1
capture=lambda var:preserve.replace(' AS preservation;',' INTO '+var+';')
# Content verification is a readonly query generated from the real authoring catalog contract.
checkfile=D/'content/ROOT_CONTENT_CHECK.sql';checks=checkfile.read_text() if checkfile.exists() else "RAISE EXCEPTION 'EDITOR57_CONTENT_CHECK_NOT_COMPOSED' USING ERRCODE='PT409';"
sql='BEGIN;\nDO $editor57$\nDECLARE rr mission_factory_owner.editor_release_readiness; p jsonb:='+lit(js(M),'editor57params')+'::jsonb; baseline text:='+lit(base,'editor57before')+'; candidate text:='+lit(cs,'editor57after')+"; before_data jsonb;after_data jsonb;content_source jsonb;h jsonb;sig text;actual jsonb;new_sha text;\nBEGIN\n"+''' IF current_user<>'postgres' THEN RAISE EXCEPTION 'EDITOR57_OPERATOR_REQUIRED' USING ERRCODE='42501';END IF;
 IF NOT pg_try_advisory_xact_lock(hashtextextended('C1266:GENERIC-AI:AVAILABILITY',0)) THEN RAISE EXCEPTION 'EDITOR57_RELEASE_BUSY' USING ERRCODE='PT409';END IF;
 SELECT * INTO STRICT rr FROM mission_factory_owner.editor_release_readiness WHERE singleton FOR UPDATE NOWAIT;
 IF rr.canonical_preimage IS DISTINCT FROM baseline OR rr.revision_sha256 IS DISTINCT FROM encode(extensions.digest(convert_to(baseline,'UTF8'),'sha256'),'hex')
 OR rr.observed_revision_sha256 IS DISTINCT FROM rr.revision_sha256 OR rr.state IS DISTINCT FROM 'enabled' OR rr.scope IS DISTINCT FROM 'staff'
 OR rr.staff_guards_verified IS DISTINCT FROM true OR rr.published_assets_verified IS DISTINCT FROM true THEN RAISE EXCEPTION 'EDITOR57_BASELINE_DRIFT' USING ERRCODE='PT409';END IF;
 IF EXISTS(SELECT 1 FROM public.master_v2_sessions WHERE location_id='0b85f354-9cdb-47e1-baf9-3d266bb7e06b' AND closed_at IS NULL AND stato IS DISTINCT FROM 'chiusa') THEN RAISE EXCEPTION 'EDITOR57_STAFF_ACTIVE' USING ERRCODE='PT409';END IF;
 IF NOT mission_factory_owner.keys_exact_v2(p,ARRAY['schema_version','review_sha256','UI_git_head','Edge_version','Edge_ezbr_sha256','source_scope','materialized_document_sha256','approval_version_ids','approval_content_sha256','authoring_readback_verified','assets_full_readback_verified','domain_build_verified']) OR p->>'schema_version' IS DISTINCT FROM 'editorial57-materialization/1' OR coalesce(p->>'review_sha256','')!~'^[a-f0-9]{64}$' OR coalesce(p->>'UI_git_head','')!~'^[a-f0-9]{40}$' OR coalesce(p->>'Edge_ezbr_sha256','')!~'^[a-f0-9]{64}$'
 OR p->>'Edge_version'<>'119' OR coalesce(p->>'materialized_document_sha256','')!~'^[a-f0-9]{64}$'
 OR p->'authoring_readback_verified' IS DISTINCT FROM 'true'::jsonb OR p->'assets_full_readback_verified' IS DISTINCT FROM 'true'::jsonb OR p->'domain_build_verified' IS DISTINCT FROM 'true'::jsonb
 OR strpos(p::text,'__')>0 THEN RAISE EXCEPTION 'EDITOR57_MATERIAL_PROOF_REQUIRED' USING ERRCODE='42501';END IF;
 FOR h IN SELECT value FROM jsonb_array_elements(baseline::jsonb#>'{db_core,all_function_headers}') LOOP sig:=h->>'signature';
'''+headers+"\n IF actual IS DISTINCT FROM h THEN RAISE EXCEPTION 'EDITOR57_FUNCTION_DRIFT %',sig USING ERRCODE='PT409';END IF;END LOOP;\n"+checks+'\n'+capture('before_data')+'''
 new_sha:=encode(extensions.digest(convert_to(candidate,'UTF8'),'sha256'),'hex');
 IF octet_length(candidate)>262144 OR candidate::jsonb->'db_core' IS DISTINCT FROM baseline::jsonb->'db_core'
 THEN RAISE EXCEPTION 'EDITOR57_ROOT_CONTRACT_DRIFT';END IF;
 UPDATE mission_factory_owner.editor_release_readiness SET canonical_preimage=candidate,revision_sha256=new_sha,observed_revision_sha256=new_sha,
 client_build='mission-factory-admin/2:'||new_sha,independent_review_ref='C1266_NARRATIVE56_REVIEW.json',updated_at=clock_timestamp()
 WHERE singleton AND revision_sha256=rr.revision_sha256 AND canonical_preimage=rr.canonical_preimage;
 IF NOT FOUND THEN RAISE EXCEPTION 'EDITOR57_ROOT_CAS_LOST' USING ERRCODE='PT409';END IF;
'''+capture('after_data')+''' IF before_data IS DISTINCT FROM after_data THEN RAISE EXCEPTION 'EDITOR57_HISTORY_OR_GAMEPLAY_MUTATED';END IF;
END $editor57$;
COMMIT;
'''
sys.path.insert(0,'/private/tmp/tus-c1266-recover46-20261027/output50/parse_tools312');from pglast import parse_sql,parse_plpgsql
nodes=parse_sql(sql);parsed=0
for raw in nodes:
 if type(raw.stmt).__name__=='DoStmt':parse_plpgsql('DO '+lit(raw.stmt.args[0].arg.sval,'parse57'));parsed+=1
assert parsed==1
(D/'ROOT_INSTALL_CANDIDATE.sql').write_text(sql);(D/'ROOT_CANDIDATE.json').write_text(cs);(D/'SEMANTIC_PROOF.json').write_text(json.dumps(semproof,indent=2)+'\n');(D/'MATERIALIZATION_TEMPLATE.json').write_text(json.dumps(M,indent=2)+'\n');(D/'RELEASE_MANIFEST.json').write_text(json.dumps({'status':'MATERIALIZED_READY_FOR_REVIEW' if args.materialization else 'REVIEW_TEMPLATE_NO_APPLY','aggregate':11,'prior_aggregates':10,'semantic':semantic,'root_candidate_sha256':sha(cs.encode()),'root_bytes':len(cs.encode()),'operator_sha256':sha(sql.encode()),'operator_bytes':len(sql.encode()),'DB_functions_unchanged':226,'new_DB_functions':0,'new_grants_constraints':0,'new_provider_calls':0,'fourth_started':False,'content_check_composed':checkfile.exists()},indent=2)+'\n');print((D/'RELEASE_MANIFEST.json').read_text())
