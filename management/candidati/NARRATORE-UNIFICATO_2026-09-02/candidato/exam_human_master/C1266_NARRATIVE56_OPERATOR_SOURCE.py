from pathlib import Path
import json,hashlib,sys,re,copy,ast,argparse
D=Path('/private/tmp/tus-c1266-narrative56-20261029');A=D/'_precedenti/aggregate6_before';sha=lambda b:hashlib.sha256(b).hexdigest();js=lambda x:json.dumps(x,ensure_ascii=False,separators=(',',':'));dollar=lambda x,t:'$'+t+'$'+x+'$'+t+'$'
ap=argparse.ArgumentParser();ap.add_argument('--review-sha256');args=ap.parse_args();review=args.review_sha256 or '__N56_AGG6_REVIEW_SHA256__'
if args.review_sha256:assert re.fullmatch('[a-f0-9]{64}',review)
sys.path.insert(0,'/private/tmp/tus-c1266-recover46-20261027/output50/parse_tools312')
from pglast import parse_sql,parse_plpgsql
from pglast.stream import RawStream
before=(D/'ACTUAL_ACTIVE_ROOT_BEFORE_AGG6.txt').read_text();assert sha(before.encode())=='c2a47a4b8cc7887ea2533f6935a73ee8340b33fe0204e27662bc7ee3f44cd9a5';base=json.loads(before);oldsem=base['contract']['code_identity_sha256'];assert oldsem=='c7220744290c856258ac848d85702fe56e28525f486734d079e2dc55edb92df1'
source=(D/'DB_INTEGRATED_INSTALL_CANDIDATE.sql').read_text();oldsource=(A/'DB_INTEGRATED_INSTALL_CANDIDATE.sql').read_text()+'\n'+next(r['ddl'] for r in json.loads((D/'NARRATIVE_READER_ACTUAL_PARSED.json').read_text()) if r['signature'].startswith('mission_public_owner.work_contract_v1'))
def functions(s):
 out={};pl=0
 for raw in parse_sql(s):
  n=raw.stmt
  if type(n).__name__!='CreateFunctionStmt':continue
  sql=RawStream()(raw);body=next(o.arg[0].sval for o in n.options if o.defname=='as');name='.'.join(x.sval for x in n.funcname);ts=[]
  for a in n.parameters or []:
   if getattr(a,'mode',None) in ('o','t'):continue
   t='.'.join(x.sval for x in a.argType.names).removeprefix('pg_catalog.');t={'bool':'boolean','int4':'integer','int8':'bigint'}.get(t,t);ts.append(t+('[]' if a.argType.arrayBounds else ''))
  sig=name+'('+','.join(ts)+')'
  if 'LANGUAGE plpgsql' in sql:parse_plpgsql(sql);pl+=1
  out[sig]={'sql':sql,'body':body,'source_md5':hashlib.md5(body.encode()).hexdigest(),'source_sha256':sha(body.encode())}
 return out,pl
fs,pl=functions(source);oldfs,_=functions(oldsource);assert len(fs)==len(oldfs)==41;changed={k:v for k,v in fs.items() if v['body']!=oldfs[k]['body']};assert len(changed)==1,len(changed)
sig='mission_public_owner.work_contract_v1(uuid)'
assert list(changed)==[sig]
old_reader=oldfs[sig]['body'];new_reader=fs[sig]['body']
# Removing the new typed branch and added declarations leaves the exact original body.
a=new_reader.index(' -- Typed Scene contracts');b=new_reader.index(' IF (wc.master_session_id,wc.definition_sha256,wc.payload_sha256)',new_reader.index('RETURN scene56_doc;',a))
original=new_reader[:a]+new_reader[b:]
original=original.replace(' scene56_source mission_narrative_internal.scene_sources_v1;scene56_doc jsonb;scene56_history jsonb;scene56_descriptor jsonb;scene56_ids jsonb;\n','')
assert original==old_reader
assert 'scene_source_assert_v1' not in new_reader and 'scene_runtime_v1' not in new_reader
# Check actual producer top-level fields without evaluating a database or a fabricated work.
from pglast import ast as pgast
issuer=(D/'db_candidate/work_contract_issue.sql').read_text()
def builder_keys(var,source):
 expr=re.search(r'(?m)^  '+var+r':=(jsonb_build_object\(.*?);',source,re.S).group(1)
 node=parse_sql('SELECT '+expr)[0].stmt.targetList[0].val
 return [arg.val.sval for arg in node.args[::2]]
assert builder_keys('doc',issuer)==['schema_version','scope','release_sha256','work_id','master_session_id','definition_sha256','payload_sha256','payload_schema_version','editorial_profile','features','source_attestation']
assert builder_keys('source_attestation',issuer)==['schema_version','work_id','authority_receipt_id','payload_sha256','master_session_id','definition_sha256','release_sha256','execution_authority','scene']
headers={h['signature']:h for h in base['db_core']['all_function_headers']}
for sig,f in oldfs.items():assert headers[sig]['source_md5']==f['source_md5']
seedsha=sha((D/'C4_CACHE_SEED_CANDIDATE.sql').read_bytes());assert seedsha=='6d3c7dc818da04688bfc613f1b91e29a083463dc9347f3e933998cbfcb1ab60d'
semproof={'schema_version':'narrative56-product-delta/1','predecessor_semantic_identity_sha256':oldsem,'predecessor_root_sha256':sha(before.encode()),'whole_db_source_sha256':sha(source.encode()),'changed_sources':{k:{'source_md5':v['source_md5'],'source_sha256':v['source_sha256']} for k,v in sorted(changed.items())},'unchanged_edge_content_sha256':sha(js(base['edge_bundles']).encode()),'unchanged_UI_content_sha256':sha(js(base['ui']).encode()),'unchanged_seed_source_sha256':seedsha,'scope':'Strict typed Scene historical contract reader; no current runtime or rule queries; no fourth trial.'}
sem=sha(js(semproof).encode());candidate=copy.deepcopy(base);expected=[]
for i,(sig,f) in enumerate(sorted(changed.items())):
 h=copy.deepcopy(headers[sig]);h['source_md5']=f['source_md5'];h['ddl_md5']='__N56_AGG6_DDL_%02d__'%i;expected.append({'signature':sig,'before':headers[sig],'after':h})
newheaders={x['signature']:x['after'] for x in expected};updated=[]
def rewrite(v,path=''):
 if isinstance(v,dict):
  sig=v.get('signature')
  if sig in newheaders and 'source_md5' in v:
   assert v==headers[sig];v.update(copy.deepcopy(newheaders[sig]));updated.append(path)
  for k,z in v.items():rewrite(z,path+'/'+k)
 elif isinstance(v,list):
  for i,z in enumerate(v):rewrite(z,path+'/'+str(i))
rewrite(candidate['db_core'],'/db_core');candidate['contract']['code_identity_sha256']=sem;candidate['recovery']['semantic_identity_sha256']=sem;candidate['recovery']['evidence']['review_sha256']=review
assert candidate['config']==base['config'] and candidate['ui']==base['ui'] and candidate['edge_bundles']==base['edge_bundles'];assert len(candidate['db_core']['all_function_headers'])==226;assert [x['signature'] for x in candidate['db_core']['c1266_functions']]==[x['signature'] for x in base['db_core']['c1266_functions']]
# Reuse the existing technical preserve/header projection source as text, without executing its builder.
module=ast.parse((D/'build_root_release.py').read_text());strings={}
for n in module.body:
 if isinstance(n,ast.Assign) and isinstance(n.value,ast.Constant) and isinstance(n.value.value,str):
  for t in n.targets:
   if isinstance(t,ast.Name):strings[t.id]=n.value.value
header_sql=strings['header_sql'];preserve=strings['preserve'];preserve=preserve.replace(' INTO PRESERVE_VAR;'," || jsonb_build_object('scene_runtime',(SELECT public.combat_v2_sha256(coalesce(jsonb_agg(to_jsonb(z) ORDER BY id),'[]'::jsonb)) FROM mission_narrative_internal.scene_runtime_v1 z WHERE master_session_id=ANY(scope_ids)), 'scene_sources',(SELECT public.combat_v2_sha256(coalesce(jsonb_agg(to_jsonb(z) ORDER BY id),'[]'::jsonb)) FROM mission_narrative_internal.scene_sources_v1 z WHERE scene_id IN(SELECT id FROM mission_narrative_internal.scene_runtime_v1 WHERE master_session_id=ANY(scope_ids))), 'events',(SELECT public.combat_v2_sha256(coalesce(jsonb_agg(to_jsonb(z) ORDER BY event_key,event_version),'[]'::jsonb)) FROM mission_generic_owner.event_outbox_v1 z WHERE master_session_id=ANY(scope_ids))) INTO PRESERVE_VAR;")
# Existing event_outbox columns must be verified against the supplied metadata.
cols=json.loads((D/'RELATION_COLUMNS_LIVE.json').read_text());ec=next((r for r in cols if r['relation']=='mission_generic_owner.event_outbox_v1'),None)
assert ec and {'event_key','event_version','master_session_id'}<={x['name'] for x in ec['columns']}
# Existing function ABI proof is retained for all40, not merely11source changes.
oldop=(D/'root_release/ACTIVATE_TEMPLATE.sql').read_text();start=oldop.index(" SELECT jsonb_build_object('return_type'");end=oldop.index(" token:=item#>>'{template_header,ddl_md5}'",start);abi=oldop[start:end]
abi40=json.loads((D/'root_release/EXPECTED_AFTER_HEADERS.json').read_text());assert len(abi40)==40
abi40.append(dict(abi40[0],header=headers['mission_public_owner.work_contract_v1(uuid)'],return_type='jsonb',retset=False,kind='f',strict=False,parallel='u',leakproof=False,argument_names=['p_work'],argument_defaults_count=0,argument_defaults_sql=None,argument_modes=['i'],argument_count=1,variadic_type=0,cost=100,rows=0,support_oid=0))
assert len(abi40)==41
upper=js(candidate)
for item in expected:upper=upper.replace(json.dumps(item['after']['ddl_md5']),json.dumps('f'*32))
upper=upper.replace(review,'f'*64);assert len(upper.encode())<=262144
params={'review_ref':'C1266_NARRATIVE56_REVIEW.json','review_sha256':review,'p0':0,'p1':0,'p2':0,'semantic_identity_sha256':sem,'provider_calls_during_release':0}
ddl='\n'.join(f['sql']+';' for sig,f in sorted(changed.items()))
checkheaders=lambda obj:"FOR h IN SELECT value FROM jsonb_array_elements("+obj+"#>'{db_core,all_function_headers}') LOOP sig:=h->>'signature';\n"+header_sql+"\nIF actual IS DISTINCT FROM h THEN RAISE EXCEPTION 'N56_AGG6_HEADER_DRIFT %',sig USING ERRCODE='40001';END IF;END LOOP;\n"
sql='BEGIN;\nDO $agg6$\nDECLARE params jsonb:='+dollar(js(params),'agg6params')+'::jsonb; baseline_text text:='+dollar(before,'agg6baseline')+'; candidate text:='+dollar(js(candidate),'agg6candidate')+'; expected jsonb:='+dollar(js(expected),'agg6expected')+'::jsonb; abi40 jsonb:='+dollar(js(abi40),'agg6abi')+'''::jsonb;
 rr mission_factory_owner.editor_release_readiness; h jsonb;item jsonb;actual jsonb;abi jsonb;sig text;before_data jsonb;after_data jsonb;new_sha text;
 scope_ids uuid[]:=ARRAY['7c301c10-5a0e-42d8-92b3-cee6fc4171e6']::uuid[];
BEGIN
 IF current_user<>'postgres' THEN RAISE EXCEPTION 'N56_RELEASE_OWNER_REQUIRED' USING ERRCODE='42501';END IF;
 IF NOT pg_try_advisory_xact_lock(hashtextextended('C1266:GENERIC-AI:AVAILABILITY',0)) THEN RAISE EXCEPTION 'N56_RELEASE_BUSY';END IF;
 SELECT * INTO STRICT rr FROM mission_factory_owner.editor_release_readiness WHERE singleton FOR UPDATE NOWAIT;
 IF rr.canonical_preimage IS DISTINCT FROM baseline_text OR rr.revision_sha256 IS DISTINCT FROM 'c2a47a4b8cc7887ea2533f6935a73ee8340b33fe0204e27662bc7ee3f44cd9a5'
 OR rr.observed_revision_sha256 IS DISTINCT FROM rr.revision_sha256 OR rr.revision_sha256 IS DISTINCT FROM encode(extensions.digest(convert_to(baseline_text,'UTF8'),'sha256'),'hex')
 OR rr.state IS DISTINCT FROM 'enabled' OR rr.scope IS DISTINCT FROM 'staff' OR rr.staff_guards_verified IS DISTINCT FROM true OR rr.published_assets_verified IS DISTINCT FROM true
 THEN RAISE EXCEPTION 'N56_AGG6_BASELINE_DRIFT' USING ERRCODE='40001';END IF;
 IF params->>'review_ref' IS DISTINCT FROM 'C1266_NARRATIVE56_REVIEW.json' OR coalesce(params->>'review_sha256','')!~'^[a-f0-9]{64}$'
 OR params->>'semantic_identity_sha256' IS DISTINCT FROM 'SEMANTIC' OR params->'p0' IS DISTINCT FROM '0'::jsonb OR params->'p1' IS DISTINCT FROM '0'::jsonb OR params->'p2' IS DISTINCT FROM '0'::jsonb
 OR params->'provider_calls_during_release' IS DISTINCT FROM '0'::jsonb THEN RAISE EXCEPTION 'N56_AGG6_FULL_REVIEW_REQUIRED' USING ERRCODE='42501';END IF;
 IF EXISTS(SELECT 1 FROM mission_generic_owner.work_items WHERE master_session_id=ANY(scope_ids) AND state IN('claimed','authorized','provider_started'))
 THEN RAISE EXCEPTION 'N56_AGG6_WORK_IN_FLIGHT';END IF;
'''.replace('SEMANTIC',sem)+checkheaders('baseline_text::jsonb')+'FOR item IN SELECT value FROM jsonb_array_elements(abi40) LOOP sig:=item#>>\'{header,signature}\';\n'+abi+'END LOOP;\n'+preserve.replace('PRESERVE_VAR','before_data')+'\nEXECUTE '+dollar(ddl,'agg6ddl')+''';
FOR item IN SELECT value FROM jsonb_array_elements(expected) LOOP
 sig:=item->>'signature';
'''+header_sql+'''
 IF actual IS NULL OR (actual-'ddl_md5') IS DISTINCT FROM ((item->'after')-'ddl_md5') THEN RAISE EXCEPTION 'N56_AGG6_CHANGED_BODY_OR_ATTR_DRIFT %',sig USING ERRCODE='40001';END IF;
 candidate:=replace(candidate,to_jsonb(item#>>'{after,ddl_md5}')::text,to_jsonb(actual->>'ddl_md5')::text);
END LOOP;
'''+checkheaders('candidate::jsonb')+'FOR item IN SELECT value FROM jsonb_array_elements(abi40) LOOP sig:=item#>>\'{header,signature}\';\n'+abi+'''END LOOP;
IF octet_length(candidate)>262144 OR strpos(candidate,'__N56_')>0 OR candidate::jsonb->'config' IS DISTINCT FROM baseline_text::jsonb->'config'
 OR candidate::jsonb->'ui' IS DISTINCT FROM baseline_text::jsonb->'ui' OR candidate::jsonb->'edge_bundles' IS DISTINCT FROM baseline_text::jsonb->'edge_bundles'
 THEN RAISE EXCEPTION 'N56_AGG6_CONFIG_ASSET_OR_CAP_DRIFT';END IF;
'''+preserve.replace('PRESERVE_VAR','after_data')+'''
IF before_data IS DISTINCT FROM after_data THEN RAISE EXCEPTION 'N56_AGG6_RUNTIME_OR_LEDGER_MUTATED';END IF;
new_sha:=encode(extensions.digest(convert_to(candidate,'UTF8'),'sha256'),'hex');
UPDATE mission_factory_owner.editor_release_readiness SET canonical_preimage=candidate,revision_sha256=new_sha,observed_revision_sha256=new_sha,
 client_build='mission-factory-admin/2:'||new_sha,independent_review_ref='C1266_NARRATIVE56_REVIEW.json',updated_at=clock_timestamp()
 WHERE singleton AND revision_sha256=rr.revision_sha256 AND canonical_preimage=rr.canonical_preimage;
IF NOT FOUND THEN RAISE EXCEPTION 'N56_ROOT_CAS_LOST' USING ERRCODE='40001';END IF;
END $agg6$;
COMMIT;
'''
after_proof=preserve.replace('PRESERVE_VAR','after_data')+"\nIF before_data IS DISTINCT FROM after_data THEN RAISE EXCEPTION 'N56_AGG6_RUNTIME_OR_LEDGER_MUTATED';END IF;\n"
assert sql.count(after_proof)==1
sql=sql.replace(after_proof,'')
needle="IF NOT FOUND THEN RAISE EXCEPTION 'N56_ROOT_CAS_LOST' USING ERRCODE='40001';END IF;\nEND $agg6$;"
assert sql.count(needle)==1
sql=sql.replace(needle,needle.replace('\nEND $agg6$;', '\n'+after_proof+'END $agg6$;'))
asts=parse_sql(sql);do=0
for raw in asts:
 if type(raw.stmt).__name__=='DoStmt':parse_plpgsql(RawStream()(raw));do+=1
# Whole source inventory is refreshed while release operator executes ONLY11 changed functions.
m=json.loads((D/'DB_INTEGRATED_MANIFEST.json').read_text());m['installer'].update(sha256=sha(source.encode()),bytes=len(source.encode()));m.update(aggregate=6,sql_ast_statements=len(parse_sql(source)),plpgsql_create_functions_parsed=pl)
readerrow={'identity_signature':'mission_public_owner.work_contract_v1(uuid)','name':'mission_public_owner.work_contract_v1'}
if not any(r['identity_signature']==readerrow['identity_signature'] for r in m['functions']):m['functions'].append(readerrow)
m['function_count']=41
for row in m['functions']:
 sig=row['identity_signature'].replace('pg_catalog.','');sig=re.sub(r'\b(bool|int4|int8)\b',lambda m:{'bool':'boolean','int4':'integer','int8':'bigint'}[m.group(1)],sig);f=fs[sig];row.update(source_md5=f['source_md5'],source_sha256=f['source_sha256'],statement_sha256=sha(f['sql'].encode()),statement_bytes=len(f['sql'].encode()))
if not any(r['path']==str(D/'db_candidate/work_contract_reader.sql') for r in m['input_files']):m['input_files'].append({'path':str(D/'db_candidate/work_contract_reader.sql')})
for row in m['input_files']:
 p=Path(row['path']);row.update(sha256=sha(p.read_bytes()),bytes=p.stat().st_size)
(D/'DB_INTEGRATED_MANIFEST.json').write_text(json.dumps(m,indent=2)+'\n')
(D/'AGGREGATE6_INSTALL_CANDIDATE.sql').write_text(sql);(D/'AGGREGATE6_ROOT_TEMPLATE.txt').write_text(js(candidate));(D/'AGGREGATE6_SEMANTIC_PROOF.json').write_text(json.dumps(semproof,indent=2)+'\n')
proof={'schema_version':'narrative56-aggregate6-handoff/1','aggregate':6,'status':'FROZEN_FOR_SINGLE_INDEPENDENT_COUNTERREVIEW_NO_APPLY','archive':str(A),'predecessor_root_sha256':sha(before.encode()),'predecessor_semantic':oldsem,'semantic_identity_sha256':sem,'builder_sha256':sha(Path(__file__).read_bytes()),'source_scope_frozen_sha256':{str(p.relative_to(D)):sha(p.read_bytes()) for p in [D/'db_candidate/work_contract_reader.sql']},'changed_functions':list(changed),'DDL_count':len(changed),'whole_source_functions':41,'all_headers':226,'foundation_members':149,'header_paths_updated':updated,'new_PT409_exact_count':5,'review_materialization':'python build_aggregate6.py --review-sha256 <final wrapper SHA>; unresolved placeholder rejects before DDL','reader_static_DTO_proof':{'actual_issuer_AST_key_fields_match_reader':True,'doc_exact_keys':11,'features_exact_unique_ordered_count':3,'attestation_exact_keys':9,'scene_descriptor_exact_keys':11,'payload_exact_keys':13,'legacy_body_byte_equivalent_after_removing_new_branch_and_declarations':True,'generic_stored_row_hash_checks_preserved_in_new_branch':True,'historical_stamp3_equal_and_nonNULL':True,'source_payload_immutable_SHA_role_order_memory_last_publication':True,'initial_opening_zero_roles_and_normal_narration_distinct':True,'no_currentScene_mode_version_Root_clock_characters_messages_or_source_assert_queries':True,'no_historical_helper_edit_or_recursion':True,'reader_existing_registered_OID':276266,'no_fixture_gameplay':True},'static_proof':{'SQL_statements':len(asts),'outer_PLpgSQL_DO':do,'changed_PLpgSQL_bodies_parsed':len(changed),'full_PLpgSQL_bodies_parsed':pl,'result':'PASS_STATIC_ONLY','root_materialized_upper_bound_bytes':len(upper.encode()),'root_cap':262144},'config_finance_assets_seed_unchanged':True,'runtime_cache_roles_fati_quota_events_preservation_checked_same_transaction':True,'old_provider_raw_and_saved_fati_untouched':True,'new_functions':0,'release_scope':'Only1existing CREATE OR REPLACE reader body and currentRootCAS; no full40 reinstall or a9 regeneration','source_only':'No API/provider/browser/apply/Git/canonical or fourth trial. Counters/stories/history retained.'}
for n in ['AGGREGATE6_INSTALL_CANDIDATE.sql','AGGREGATE6_ROOT_TEMPLATE.txt','AGGREGATE6_SEMANTIC_PROOF.json','DB_INTEGRATED_INSTALL_CANDIDATE.sql','DB_INTEGRATED_MANIFEST.json']:
 proof.setdefault('files',{})[n]={'sha256':sha((D/n).read_bytes()),'bytes':(D/n).stat().st_size}
(D/'AGGREGATE6_HANDOFF.json').write_text(json.dumps(proof,ensure_ascii=False,indent=2)+'\n');print(json.dumps({'semantic':sem,'changed':len(changed),'files':proof['files'],'handoff_sha256':sha((D/'AGGREGATE6_HANDOFF.json').read_bytes())}))
