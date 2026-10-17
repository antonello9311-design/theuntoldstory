from pathlib import Path
import json,re,hashlib,copy,ast,difflib
from pglast.parser import parse_sql_json,parse_plpgsql_json
D=Path('/private/tmp/c1266-composition13-staff-20261017/recovery');D12=Path('/private/tmp/c1266-composition12-staff-20261017/recovery');P=Path('/Users/antonello/Desktop/theuntoldstory/management/candidati/NARRATORE-UNIFICATO_2026-09-02/candidato/exam_human_master');D9=Path('/private/tmp/c1266-prerequisites9-20261017/recovery');D8=Path('/private/tmp/c1266-temporal8-20261017')
read=lambda p:json.loads(p.read_text());sha=lambda x:hashlib.sha256(x.encode() if isinstance(x,str) else x).hexdigest();md5=lambda x:hashlib.md5(x.encode()).hexdigest();q=lambda s:"'"+s.replace("'","''")+"'";jq=lambda x:q(json.dumps(x,ensure_ascii=False,separators=(',',':')))+'::jsonb';body=lambda s:re.search(r'AS (\$[^$]*\$)(.*?)\1',s,re.S)[2]
def ref(p):return {'path':str(p),'sha256':sha(p.read_bytes()),'bytes':p.stat().st_size}
def save(n,x):(D/n).write_text(json.dumps(x,ensure_ascii=False,indent=2)+'\n')
sig='mission_staff_abort_private.quiescent_v1(uuid)';live=read(D.parent/'BASE_LIVE.json');captured=read(D12/'LIVE_SOURCE_ACTUAL.json');before=live['headers'];header=next(x for x in before if x['signature']==sig);old=captured['definition']
assert len(before)==113 and header==captured['header'] and md5(body(old))==header['source_md5']=='08c1a65ed539396e9934b4e769f44304' and md5(old)==header['ddl_md5']
assert old==(P/'C1266_PREREQ9_RECOVERY_SOURCE.sql').read_text() and old==(D/'SOURCE_BEFORE.sql').read_text()
assert all(live[k]==0 for k in ['active_ai','staff_open','active_provider','combat_open'])
human=read(D.parent/'BASE_HUMAN.json');assert len(human['headers112'])==112 and len(human['identity_and_transitive'])==7
assert not any('mission_staff_abort_private.quiescent_v1' in json.dumps(x) for x in human['headers112']+human['identity_and_transitive'])
bundle11path=P/'C1266_COUNT_SCHEMA11_EDGE_BUNDLE.json';assert sha(bundle11path.read_bytes())=='5ce944010e857d09cbe0f7b85e2c1dd1548e0defb6c2f8febc3753960742c911'
bundle8=read(D8/'C1266_TEMPORAL_AGG8_EDGE_BUNDLE.json');bundle11=read(bundle11path)
def files(bundle):
 result=sorted([{'name':x['name'],'bytes':len(x['content'].encode()),'sha256':sha(x['content'])} for x in bundle],key=lambda x:x['name']);assert len(result)==14 and len({x['name'] for x in result})==14;return result
files8=files(bundle8);files11=files(bundle11);assert files8!=files11
# One literal expression in LIVE source. Retain old complete tuple and add a complete independently reviewed tuple.
needle='='+jq(files8);replacement=' IN ('+jq(files8)+','+jq(files11)+')';assert old.count(needle)==1
new=old.replace(needle,replacement,1);assert new.replace(replacement,needle,1)==old
(D/'SOURCE.sql').write_text(new);(D/'SOURCE.diff').write_text(''.join(difflib.unified_diff(old.splitlines(True),new.splitlines(True),fromfile='LIVE9/quiescent.sql',tofile='COMPOSITION13/quiescent.sql')))
after=copy.deepcopy(before)
for h in after:
 if h['signature']==sig:h.update(source_md5=md5(body(new)),ddl_md5=md5(new))
changed=[(a,b) for a,b in zip(before,after) if a!=b];assert len(changed)==1 and {k for k in changed[0][0] if changed[0][0][k]!=changed[0][1][k]}=={'source_md5','ddl_md5'}
base={'schema_version':'c1266-composition13-recovery-baseline/1','headers_before':before,'headers_after_expected':after,'schema7':live['configuration_schema'],'rows7_before':live['rows'],'source_before_md5':md5(body(old)),'source_after_md5':md5(body(new)),'definition_after_md5_expected':md5(new),'definition_file':str(D/'SOURCE.sql'),'definition_sha256':sha(new),'live_capture':ref(D12/'LIVE_SOURCE_RAW.json'),'parent_baseline':ref(D.parent/'BASE_LIVE.json'),'accepted_edge_file_tuples':[{'candidate':8,'files':files8},{'candidate':11,'files':files11}],'Human112_and7_unchanged':True,'Human_capture':ref(D.parent/'BASE_HUMAN.json')}
save('BASELINE.json',base);save('PLANNED_ROOT113.json',base)
tables={'readiness':'mission_factory_owner.editor_release_readiness','g2':'mission_factory_owner.c464_control','authoring':'mission_factory_owner.provider_authoring_runtime','admissions':'mission_factory_owner.provider_authoring_admissions','runtime':'mission_generic_owner.runtime_policy','provider':'mission_generic_owner.provider_policy','flow':'mission_generic_owner.flow_runtime_gate'}
actors="'b4952ed5-5ce0-49c0-9f2b-8fd5dcd89b4b'::uuid,'f0856d53-83a6-4de0-bc0c-12c87916e665'::uuid"
# Evaluate only isolated SQL text renderer functions via AST. No application module is imported/executed.
root_tree=ast.parse((P/'C1266_PREREQ9_ROOT_SOURCE.py').read_text());schema_fn=next(n for n in root_tree.body if isinstance(n,ast.FunctionDef) and n.name=='schema_query');env={'TABLES':tables,'q':q};exec(compile(ast.Module(body=[schema_fn],type_ignores=[]),'<schema_sql_renderer>','exec'),env);schema_sql=env['schema_query']()
prior_tree=ast.parse((D9/'build_recovery.py').read_text());guard_fn=next(n for n in prior_tree.body if isinstance(n,ast.FunctionDef) and n.name=='guard')
# Change only known exception-label templates BEFORE runtime baseline JSON is rendered.
# No replacement is applied to rendered SQL or any baseline string.
class ExceptionLabelTemplate(ast.NodeTransformer):
 def visit_Constant(self,node):
  if isinstance(node.value,str) and "RAISE EXCEPTION 'C1266_PREREQ9_" in node.value:
   node.value=node.value.replace("RAISE EXCEPTION 'C1266_PREREQ9_","RAISE EXCEPTION 'C1266_COMPOSITION12_")
  if isinstance(node.value,str):node.value=node.value.replace("$prerequisite9$","$composition12$")
  return node
guard_fn=ast.fix_missing_locations(ExceptionLabelTemplate().visit(guard_fn))
genv={'tables':tables,'actors':actors,'live':live,'schema_sql':schema_sql,'jq':jq};exec(compile(ast.Module(body=[guard_fn],type_ignores=[]),'<guard_sql_renderer>','exec'),genv)
human112=[{'oid':int(x['oid']),'signature':x['lookup_signature'],'owner':x['owner'],'secdef':x['security_definer'],'volatility':x['volatility'],'config':x['configuration'],'language':x['language'],'acl':x['acl'],'source_md5':x['body_md5'],'ddl_md5':x['definition_md5']} for x in human['headers112']]
helper7=[{'signature':x['signature'],'owner':x['owner'],'secdef':x['security_definer'],'volatility':x['volatility'],'config':x['configuration'],'acl':x['acl'],'source_md5':x['body_md5'],'ddl_md5':x['definition_md5']} for x in human['identity_and_transitive']]
def human_guard():
 sql='FOR item IN SELECT value FROM jsonb_array_elements('+jq(human112)+") LOOP\n SELECT jsonb_build_object('oid',p.oid::bigint,'signature',item->>'signature','owner',pg_get_userbyid(p.proowner),'secdef',p.prosecdef,'volatility',p.provolatile::text,'config',p.proconfig,'language',l.lanname,'acl',p.proacl::text,'source_md5',md5(p.prosrc),'ddl_md5',md5(pg_get_functiondef(p.oid))) INTO actual FROM pg_proc p JOIN pg_language l ON l.oid=p.prolang WHERE p.oid=to_regprocedure(item->>'signature');\n IF actual IS DISTINCT FROM item THEN RAISE EXCEPTION 'C1266_COMPOSITION12_HUMAN112_DRIFT %',item->>'signature'; END IF;\nEND LOOP;\n"
 sql+='FOR item IN SELECT value FROM jsonb_array_elements('+jq(helper7)+") LOOP\n SELECT jsonb_build_object('signature',item->>'signature','owner',pg_get_userbyid(p.proowner),'secdef',p.prosecdef,'volatility',p.provolatile::text,'config',p.proconfig,'acl',p.proacl::text,'source_md5',md5(p.prosrc),'ddl_md5',md5(pg_get_functiondef(p.oid))) INTO actual FROM pg_proc p WHERE p.oid=to_regprocedure(item->>'signature');\n IF actual IS DISTINCT FROM item THEN RAISE EXCEPTION 'C1266_COMPOSITION12_HUMAN_HELPER_DRIFT %',item->>'signature'; END IF;\nEND LOOP;\n"
 return sql
def guard(headers,lock=False,recovery=False):
 sql=genv['guard'](headers,lock,recovery)
 assert sql.count('END\n$composition12$;')==1
 return sql.replace('END\n$composition12$;',human_guard()+'END\n$composition12$;',1)
prefix="BEGIN;\nSET LOCAL lock_timeout='5s';\nSET LOCAL statement_timeout='45s';\n"
install='-- COMPOSITION13 only: coherent bundle11 admission added beside8 in live own-abort proof.\n-- Fresh full113/schema7/config7/Human/48 and independent composed review are prerequisites.\n'+prefix+guard(before,True)+new+';\nALTER FUNCTION '+sig+' OWNER TO postgres;\nGRANT EXECUTE ON FUNCTION '+sig+' TO postgres;\n'+guard(after)+'COMMIT;\n'
recovery='-- FORWARD VERIFICATION ONLY after ordinary authenticated own closure and reviewed current Root HOLD.\n-- Preserves this function, all scene/accounting history, current/future Root canonical preimage and clock.\n-- No rollback to prior function, no forced closure, no refunds, no configuration DML.\n'+prefix+guard(after,True,True)+'COMMIT;\n'
(D/'INSTALL.sql').write_text(install);(D/'RECOVERY.sql').write_text(recovery)
checks=[]
for name in ['SOURCE_BEFORE.sql','SOURCE.sql','INSTALL.sql','RECOVERY.sql']:
 text=(D/name).read_text();sql=json.loads(parse_sql_json(text));pl=json.loads(parse_plpgsql_json(text));checks.append({'file':name,'sha256':sha(text),'sql_statements':len(sql['stmts']),'node_kinds':[next(iter(x['stmt'])) for x in sql['stmts']],'PL_blocks':len(pl),'SQL_grammar':'PASS','PL_grammar':'PASS'})
for text in [old,new]:assert len(json.loads(parse_sql_json(body(text)))['stmts'])==1
assert "'oid',p.oid," not in install+recovery
# Compare ASTs after normalizing location-only fields and replacing just the one allowed-tuple expression.
old_ast=json.loads(parse_sql_json(body(old)));new_ast=json.loads(parse_sql_json(body(new)))
def find_expr(node,predicate):
 found=[]
 def visit(n):
  if isinstance(n,dict):
   if 'A_Expr' in n and predicate(n['A_Expr']):found.append(n)
   for v in n.values():visit(v)
  elif isinstance(n,list):
   for v in n:visit(v)
 visit(node);return found
oldexpr=find_expr(old_ast,lambda n:json.dumps(files8,ensure_ascii=False,separators=(',',':')) in json.dumps(n.get('rexpr',{}),ensure_ascii=False).replace('\\"','"'))
# Literal inclusion is better tested against recursively collected scalar strings (no regex parser).
def strings(node):
 if isinstance(node,str):yield node
 elif isinstance(node,dict):
  for v in node.values():yield from strings(v)
 elif isinstance(node,list):
  for v in node:yield from strings(v)
file8str=json.dumps(files8,ensure_ascii=False,separators=(',',':'));file11str=json.dumps(files11,ensure_ascii=False,separators=(',',':'))
oldexpr=find_expr(old_ast,lambda n:n.get('kind')=='AEXPR_OP' and file8str in list(strings(n.get('rexpr',{}))))
newexpr=find_expr(new_ast,lambda n:n.get('kind')=='AEXPR_IN' and file8str in list(strings(n.get('rexpr',{}))) and file11str in list(strings(n.get('rexpr',{}))))
assert len(oldexpr)==len(newexpr)==1
newexpr[0].clear();newexpr[0].update(copy.deepcopy(oldexpr[0]))
def clean(x):
 if isinstance(x,dict):return {k:clean(v) for k,v in x.items() if k not in ['location','stmt_len','stmt_location','rexpr_list_start','rexpr_list_end']}
 if isinstance(x,list):return [clean(v) for v in x]
 return x
assert clean(old_ast)==clean(new_ast)
# Parse every rendered JSON CAS value: baseline data must survive code-generation exactly.
def parse_json_literal(literal):
 node=json.loads(parse_sql_json('SELECT '+literal+'::jsonb;'))['stmts'][0]['stmt']['SelectStmt']['targetList'][0]['ResTarget']['val']['TypeCast']['arg']['A_Const']
 return json.loads(node['sval']['sval'])
cas_checks=[]
for line_no,line in enumerate(install.splitlines(),1):
 if 'C1266_COMPOSITION12_CONFIG_CAS_DRIFT ' not in line:continue
 key=re.search(r"CONFIG_CAS_DRIFT ([a-z0-9]+)'",line)[1]
 literal=re.search(r'IS DISTINCT FROM (.*)::jsonb THEN RAISE EXCEPTION',line)[1]
 value=parse_json_literal(literal);assert value==live['rows'][key]
 item={'installer_line':line_no,'configuration':key,'equal_genuine_baseline':True}
 if key=='readiness':
  assert value['canonical_preimage'].encode()==live['rows']['readiness']['canonical_preimage'].encode()
  assert value['independent_review_ref']==live['rows']['readiness']['independent_review_ref']
  assert sha(value['canonical_preimage'])==value['revision_sha256']==value['observed_revision_sha256']
  item.update(canonical_preimage_byteexact=True,preimage_sha_matches_revision=True,independent_review_ref_byteexact=True)
 cas_checks.append(item)
assert len(cas_checks)==14 and all(sum(x['configuration']==k for x in cas_checks)==2 for k in tables)
schema_checks=[];header_checks=[]
for line_no,line in enumerate(install.splitlines(),1):
 if 'C1266_COMPOSITION12_SCHEMA7_CAS_DRIFT' in line:
  literal=re.search(r'IS DISTINCT FROM (.*)::jsonb THEN RAISE EXCEPTION',line)[1]
  assert parse_json_literal(literal)==live['configuration_schema'];schema_checks.append(line_no)
 if line.startswith('DECLARE expected jsonb := '):
  literal=re.search(r'DECLARE expected jsonb := (.*)::jsonb; item',line)[1]
  value=parse_json_literal(literal);assert value==(before if not header_checks else after)
  assert all(isinstance(x['oid'],int) for x in value);header_checks.append(line_no)
assert len(schema_checks)==len(header_checks)==2
human_checks=[]
for artifact,sql_text in [('INSTALL.sql',install),('RECOVERY.sql',recovery)]:
 for line_no,line in enumerate(sql_text.splitlines(),1):
  if not line.startswith('FOR item IN SELECT value FROM jsonb_array_elements('):continue
  literal=line[len('FOR item IN SELECT value FROM jsonb_array_elements('):].removesuffix('::jsonb) LOOP')
  if not literal.startswith(chr(39)):continue
  value=parse_json_literal(literal)
  assert value in [human112,helper7]
  human_checks.append({'artifact':artifact,'line':line_no,'count':len(value),'equals_genuine_human_baseline13':True})
assert len(human_checks)==6
old_lines=(D12/'INSTALL.sql').read_text().splitlines();new_lines=install.splitlines();assert len(old_lines)==len(new_lines)
changed_lines=[i+1 for i,(a,b) in enumerate(zip(old_lines,new_lines)) if a!=b]
assert changed_lines==[1,17,447]
assert len(ast.parse((D/'GENERATOR.py').read_text()).body)>0
assert new==(D12/'SOURCE.sql').read_text()
assert recovery==(D12/'RECOVERY.sql').read_text()
cas_proof={'schema_version':'c1266-composition13-rendered-cas-proof/1','classification':'AST_JSON_LITERAL_COMPARISON_NO_SQL_EXECUTION','genuine_baseline':ref(D.parent/'BASE_LIVE.json'),'checks14':cas_checks,'Human112_plus7_CAS':human_checks,'installer_changed_lines_from12':changed_lines,'all_other_installer_lines_byteexact12':True,'generator_python_AST':'PASS','schema7_exact_lines':schema_checks,'header113_exact_lines':header_checks,'source_byteexact12':ref(D12/'SOURCE.sql'),'recovery_byteexact12':ref(D12/'RECOVERY.sql'),'label_strategy':'Known RAISE EXCEPTION label templates are renamed on generator AST before rendering. Rendered SQL baseline values are never replaced. Dollar tags also change only in template AST before rendering; all14CAS are parsed and compared.','old_generator':ref(D12/'build_composition12.py'),'old_rejection':ref(D12.parent/'INSTALL_REJECTION_DIAGNOSIS.json'),'fresh_header_matches_captured_body12':True,'review13':'PENDING'}
save('CAS_PROOF.json',cas_proof)
proof={'schema_version':'c1266-composition13-recovery-source-proof/1','before':ref(D/'SOURCE_BEFORE.sql'),'after':ref(D/'SOURCE.sql'),'genuine_capture':ref(D12/'LIVE_SOURCE_RAW.json'),'capture_at':captured['captured_at'],'live_header_matches_parent113':True,'canonical9_matches_live_but_not_assumed':True,'delta':'One A_Expr equality of full fourteen-file tuple changed into IN with [original8, independently reviewed11]. No individual file mixing.','AST_after_restoring_single_expression_equals_before':True,'byteexact_after_reversing_single_replacement':True,'old_tuple_preserved':True,'old_historical_named_branches_preserved':True,'other_failure_scope_unchanged':True,'binding_guards_unchanged':['historical work release equals readiness revision/observed hash and canonical hash','original own authenticated Staff source/simulation authorization','all kind-specific capability/report/role/batch barriers','exact paid failure and separately finalized timeout accounting','Count unknown reservation retained and immutable request/audit binding','no stale/application error/current-work publication/command effects','no active/unfinalized closure'],'codecs':ref(D/'CODEC_STATIC.json')}
save('SOURCE_PROOF.json',proof)
contract={'schema_version':'c1266-composition13-recovery-contract/1','status':'PRIVATE_SOURCE_READY_PENDING_COMPOSED_REVIEW13','target':sig,'authority':'User mandate: compose Root/recovery from live baseline, independent review, then parent-authorized installation and Staff within cumulative residuals. This branch prepares sources only.','delta':proof['delta'],'accepted_bundles':[{'candidate':8,'file_tuple':files8,'role':'preserved original compositional authority'},{'candidate':11,'file_tuple':files11,'bundle_ref':ref(bundle11path),'review_ref':ref(P/'C1266_COUNT_SCHEMA11_REVIEW.json'),'role':'new coherent literal-ID codec + Count11 diagnostic transport; DTO4 and joint semantics remain unchanged'}],'source_proof':ref(D/'SOURCE_PROOF.json'),'compatibility':{'codec_error':'Invalid declared literal IDs remain MISSION_C1266_JOINT_WIRE_INVALID, already finite-listed. Existing same-work attestation checks retained.','unexpected_decoder_error':'Existing fixed provider_or_validation_failed path; no SQL prefix/unknown acceptance added.','semantic_validators':'Joint materializer, directorDecision, role/temporal validators, writer/audit/continuity functions byte-exact8→11.','billing_and_finalizer':'Generation through finalization suffix byte-exact except insertion of decoder before unchanged joint materializer. No raw SHA fabricated for absent provider text.','Count':'Count index11 diagnostics do not authorize Generation or alter result/Count proof. Unknown/overflow still uses existing Count terminal proof/reconciliation; paid branch still binds exact Count request/snapshot.','proof_ref':ref(D/'CODEC_STATIC.json')},'preserved_terminal_scope':'All characterized recovery9 kinds unchanged: incipit2, Director4, unified writer3/4, choice1 and combat narrator2; exact paid pre-effect failures and distinct finalized timeout retaining full unknown-billable bound.','excluded_unchanged':['active or unfinalized provider work','unknown states without the specific finalized timeout proof','stale/superseded/application-error outcomes','publication or native command effects for this work','foreign source/room/Root or mixed/unknown file tuple'],'constraints_changed':['Add exactly the full tuple11 as an alternative to full tuple8; all other conditions unchanged.'],'ACL_owner_signature_searchpath_changes':[],'new_RPC_or_helpers':0,'table_data_writes':0,'installer':'CAS full current113/schema7/config7, Human112+7 metadata, all gates OFF and activity0; sole CREATE OR REPLACE with explicit postgres grant/owner unchanged, then exact after113/schema/config/Human postcheck. Whole transaction fails atomically on mismatch.','rollback':'Failure before COMMIT rolls back the transaction. No rollback deployment or old-source reinstall is prepared.','recovery':'Forward verification only after original normal own abort/closure and reviewed Root HOLD. Verify after113/schema7/Human and sixOFF/zero activity; do not require an old readiness row because future Root admission is legitimate. No changes to Root bytes/clock, reservations, receipts or histories.','Root_requirements':'Compose actual post-install113 with genuine deployed bundle11 readback; no invented future Edge version/Root hash. Cleanup must occur while historical work remains bound to its own current Root before replacing it.','history':{'Count':10,'Gen':7,'HTTP':17,'USD':'0.1392557','historical_counters_not_reset':True,'provider_calls_this_branch':0,'DB_mutations_this_branch':0},'parent_preflight':['Review13 composition0/0/0','Fresh matching113/schema7/config7/HOLD/activity0','Human public rows+112+7 and protected48 unchanged','Current resource/task owner and ledger unchanged','Distinct authorized install/deploy/Root/Staff operations with fresh readback']}
contract['aggregate13_scope']={'authorization':'One explicit additional aggregate13 and independent review13 after rejected aggregate12 installer. Private source preparation only here.','corrected_defect':'Rendered baseline JSON was accidentally changed by global diagnostic-label replacement; transform only literal templates before rendering and verify all14 rendered CAS against genuine baseline13.','unchanged_source12':ref(D12/'SOURCE.sql'),'unchanged_recovery12':ref(D12/'RECOVERY.sql'),'prior_install_rejection':ref(D12.parent/'INSTALL_REJECTION_DIAGNOSIS.json'),'historical_exception_labels':'COMPOSITION12 labels deliberately preserved; candidate identity is in manifest/contract/hash, not exception labels.','rendered_CAS_proof':ref(D/'CAS_PROOF.json')}
save('CONTRACT.json',contract)
static={'schema_version':'c1266-composition13-recovery-static/1','classification':'STATIC_ONLY_NO_GAMEPLAY_DBEXECUTION_OR_PROVIDER','checks':checks,'SQL_function_body_grammar':'PASS_BEFORE_AFTER','AST_one_expression_delta':'PASS','source_before_md5':md5(body(old)),'source_after_md5':md5(body(new)),'definition_after_md5':md5(new),'source_after_sha256':sha(new),'single_function_delta':True,'unchanged112_headers':True,'quiescent_changed_fields_only':['source_md5','ddl_md5'],'Human112_plus7_target_absent':True,'Human_metadata_guarded_before_after_recovery':True,'grant':'postgres only, preserved','OID_serialization':'p.oid::bigint in every metadata guard','read_only_catalog_queries':0,'SQL_apply':0,'application_import':0,'functional_or_fixture_execution':0,'provider_calls':0,'source_proof':ref(D/'SOURCE_PROOF.json'),'rendered_CAS_proof':ref(D/'CAS_PROOF.json'),'codec_static':ref(D/'CODEC_STATIC.json'),'rollback':'Atomic installer transaction only; no oldbody recovery','limitations':['Static grammar/AST do not prove runtime behavior','Parent independent composed review and fresh preflight required','Future exact bundle11 deploy/readback/Root remain pending; no version/hash invented','Existing uncertain/noeffect boundaries not widened']}
save('STATIC.json',static)
(D/'GENERATOR.diff').write_text(''.join(difflib.unified_diff((D12/'build_composition12.py').read_text().splitlines(True),(D/'GENERATOR.py').read_text().splitlines(True),fromfile='COMPOSITION12/build_composition12.py',tofile='COMPOSITION13/GENERATOR.py')))
(D/'INSTALL.diff').write_text(''.join(difflib.unified_diff((D12/'INSTALL.sql').read_text().splitlines(True),install.splitlines(True),fromfile='COMPOSITION12/INSTALL.sql',tofile='COMPOSITION13/INSTALL.sql')))
leaves=['GENERATOR.diff','INSTALL.diff','SOURCE_BEFORE.sql','SOURCE.sql','SOURCE.diff','INSTALL.sql','RECOVERY.sql','BASELINE.json','PLANNED_ROOT113.json','CONTRACT.json','STATIC.json','SOURCE_PROOF.json','CODEC_STATIC.json','CAS_PROOF.json','GENERATOR.py']
save('READY_MAP.json',{'schema_version':'c1266-composition13-recovery-ready/1','status':'READY_FOR_PARENT_SINGLE_FREEZE_NO_MICROCORRECTIONS','leaf_refs':[ref(D/n) for n in leaves],'source_after_md5':md5(body(new)),'definition_after_md5_expected':md5(new),'source_after_sha256':sha(new),'canonical_source_target':str(P/'C1266_COMPOSITION13_RECOVERY_SOURCE.sql'),'canonical_installer_target':str(P/'C1266_COMPOSITION13_INSTALL.sql'),'canonical_recovery_target':str(P/'C1266_COMPOSITION13_RECOVERY.sql'),'read_only_capture':ref(D12/'LIVE_SOURCE_RAW.json'),'fresh_baseline13':ref(D.parent/'BASE_LIVE.json'),'operations':{'readonly_catalog':0,'DB_mutations':0,'provider_calls':0,'repo_mutations':0,'Git_mutations':0}})
print(json.dumps({'source_md5':md5(body(new)),'ddl_md5':md5(new),'source_sha256':sha(new),'ready':ref(D/'READY_MAP.json'),'checks':checks}))
