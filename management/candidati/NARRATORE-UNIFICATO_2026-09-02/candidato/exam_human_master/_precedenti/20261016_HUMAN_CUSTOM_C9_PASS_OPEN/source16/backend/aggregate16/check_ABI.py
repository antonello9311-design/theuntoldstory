import json,pathlib,hashlib,re,datetime
from pglast import parser
P=pathlib.Path('/private/tmp/tus-human-custom-ordinary');A=P/'backend/aggregate16';sha=lambda p:hashlib.sha256(p.read_bytes()).hexdigest();source=(A/'DELTA_SOURCE.sql').read_text();whole=(A/'INSTALL_TEMPLATE.sql').read_text();post=json.loads((A/'EXPECTED_POST_ABI.json').read_text());bodymeta=[]
def typ(t):
 n=[x['String']['sval']for x in t['names']];n=['pg_catalog']+n if len(n)==1 else n
 if t.get('arrayBounds'):n[-1]='_'+n[-1]
 return '.'.join(n)
for n in json.loads(parser.parse_sql_json(source))['stmts']:
 f=n['stmt'].get('CreateFunctionStmt')
 if not f:continue
 name='.'.join(x['String']['sval']for x in f['funcname']);h=next(x for x in post if x['lookup_signature'].split('(')[0]==name);o={x['DefElem']['defname']:x['DefElem'].get('arg')for x in f['options']};pars=[x['FunctionParameter']for x in f.get('parameters',[])];assert f['replace'] and [typ(x['argType'])for x in pars]==h['input_arg_types'];assert ([x.get('name')for x in pars]or None)==h['arg_names'];assert typ(f['returnType'])==h['return_type'];assert not any('defexpr'in x for x in pars)
 for key,val in [('language',o['language']['String']['sval']),('security_definer',o['security']['Boolean']['boolval']),('volatility',o.get('volatility',{}).get('String',{}).get('sval','volatile')[0]),('parallel',o.get('parallel',{}).get('String',{}).get('sval','unsafe')[0]),('strict',o.get('strict',{}).get('Boolean',{}).get('boolval',False))]:assert val==h[key],(name,key,val,h[key])
 md=hashlib.md5(o['as']['List']['items'][0]['String']['sval'].encode()).hexdigest();assert md==h['body_md5'];bodymeta.append({'signature':h['lookup_signature'],'body_md5':md,'ABI_AST_matches':True})
assert len(bodymeta)==16 and len(post)==111
(A/'AST_ABI_PROOF.json').write_text(json.dumps(bodymeta,indent=2))
for f in ['INSTALL_TEMPLATE.sql','DELTA_SOURCE.sql','OPEN_AFTER_STAFF_PASS_TEMPLATE.sql','RECOVERY_GATE_ONLY_TEMPLATE.sql','BUSINESS_RECOVERY.sql']:
 s=(A/f).read_text();parser.parse_sql_json(s);parser.parse_plpgsql_json(s)
