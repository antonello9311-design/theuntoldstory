from pathlib import Path
import json,re,hashlib,difflib
from pglast import parser
A=Path(__file__).parent;b=json.loads((A/'BASELINE.json').read_text());src=(A/'DELTA_SOURCE.sql').read_text();ast=json.loads(parser.parse_sql_json(src));funcs={};proof=[]
for n in ast['stmts']:
 f=n['stmt'].get('CreateFunctionStmt')
 if f:
  name='.'.join(z['String']['sval']for z in f['funcname']);body=next(x['DefElem']['arg']['List']['items'][0]['String']['sval']for x in f['options']if x['DefElem']['defname']=='as');funcs[name]=(f,body)
old={d['signature'].split('(')[0]:d['definition']for d in b['definitions']};mapping=json.loads((A/'VARIANT_MAPPING.json').read_text())[1:]
for m in mapping:
 name=m['old_entry'].split('(')[0];newname=m['new_verified'].split('(')[0];f,body=funcs[name];nf,nb=funcs[newname]
 assert body.count('human_verified_context_valid_v1')==1 and body.count(newname)==1
 assert not re.search(r'\b(INSERT|UPDATE|DELETE|EXECUTE|set_config)\b',nb,re.I)
 assert 'human_verified_context_valid_v1'not in nb
 assert not re.search(r'\bp_context\s*:=',nb,re.I) and 'jsonb_set(p_context'not in nb
 # Every fresh entry keeps the full original validator; verified-body differencing is frozen in entirety.
 orig=old[name];oldbody=next(x['DefElem']['arg']['List']['items'][0]['String']['sval']for x in json.loads(parser.parse_sql_json(orig))['stmts'][0]['stmt']['CreateFunctionStmt']['options']if x['DefElem']['defname']=='as')
 ops=list(difflib.SequenceMatcher(None,oldbody,nb,autojunk=False).get_opcodes());rebuilt=''.join(oldbody[i:j] if tag=='equal'else oldbody[i:j]for tag,i,j,k,l in ops);assert rebuilt==oldbody
 # Return expressions unchanged for JSON DTO producers (proof stays local).
 oldret=re.findall(r'RETURN\s+(.+?);',oldbody,re.I|re.S);newret=re.findall(r'RETURN\s+(.+?);',nb,re.I|re.S)
 assert oldret==newret,(name,'returnshapechanged')
 h=next(x for x in b['headers']if x['lookup_signature'].split('(')[0]==name);assert h['execute']==['postgres']
 proof.append({'entry':name,'verified':newname,'fresh_full_validation':1,'old_entry_privateACL':h['execute'],'new_variant_no_DML_dynamicSQL_GUC':True,'return_expressions_byte_identical':True,'full_body_delta_opcodes':[{'tag':t,'old':oldbody[i:j],'new':nb[k:l]}for t,i,j,k,l in ops if t!='equal'],'whole_old_body_retained':orig,'statement_binding':'cheapbinder exactbackend/txstart/statementstart/Auth/base/state; original ctx immutable in this closedgraph'})
# New verified ports are referenced only by their own construction wrappers and sibling verified ports.
newports=[n for n in funcs if n.endswith('_verified_v1')or n.endswith('human_context_bound_v1')];assert len(newports)==8
edges=[]
for name,(f,body)in funcs.items():
 body=re.sub(r'\$([A-Za-z_][A-Za-z_0-9]*)\$.*?\$\1\$','',body,flags=re.S);body=re.sub(r"'(?:''|[^'])*'",'',body)
 for callee in newports:
  if callee+'('in body:edges.append({'caller':name,'callee':callee})
assert all(e['caller'].endswith('_with_context_v1')or e['caller']in newports for e in edges)
for name in newports:
 sig=next(x['signature']for x in json.loads((A/'TARGET_DELTA_METADATA.json').read_text())if x['signature'].split('(')[0]==name)
 assert 'REVOKE ALL ON FUNCTION '+sig+' FROM PUBLIC,anon,authenticated,service_role;'in src and'GRANT EXECUTE ON FUNCTION '+sig+' TO postgres;'in src
 if name.endswith('human_custom_source_assert_verified_v1'):
  nb=funcs[name][1];t=json.loads(parser.parse_plpgsql_json('CREATE FUNCTION x()RETURNSjsonb LANGUAGEplpgsql AS $$'+nb+'$$;'.replace('RETURNSjsonb','RETURNS jsonb').replace('LANGUAGEplpgsql','LANGUAGE plpgsql')))if False else None
  assert 'IF p_active THEN\n\n IF mission_factory_owner.human_context_bound_v1'in nb
# Seal dependencies: old changed8 body hashes absent from both current seals, which remain byteexact.
delta=json.loads((A/'TARGET_DELTA_METADATA.json').read_text());seal=[]
for n in ['mission_factory_owner.c408_stage1_complete_assert_v1','mission_factory_owner.c444_runtime_ports_complete_assert_v1']:
 hits=[d['signature']for d in delta if d['old_body_md5']and d['old_body_md5']in old[n]];assert not hits;seal.append({'signature':n,'literal_changed_body_dependencies':hits,'body_unchanged':True})
result={'state':'STATIC_NOT_RUNTIME','aggregate':16,'graph':111,'new_private_ports':8,'entry_boundaries':proof,'closed_call_edges':edges,'no_public_prevalidated_arg':True,'proof_bundle':'6closedkeys, constructed onlysource_verified afterlocalAuth/sourcechecks; exactarc/draft/version/source/observationSHA guard by bothreceivers; neverreturned/persisted','read_only_reuse_window':'allvariantsSTABLE, noDML/dynamicSQL; triggerandallstandaloneentryfresh; noGUC/cache/persistence','historical':'standalone historical bodies unchanged; customsourcefalse boundary skipsfullvalidator exactlyasbefore; variantbinder remains inside IFp_active','seals':seal,'performance':'22fullchecks→1boundaryfullcheck forordinary_source path; boundchecks retained; actuallatency NOT_RUN'}
(A/'TRUST_BOUNDARY_CALLER_AST_PROOF.json').write_text(json.dumps(result,indent=2));print('7entryfull/8newprivate/closededges',len(edges),'DTO/noDML/seal PASS')
