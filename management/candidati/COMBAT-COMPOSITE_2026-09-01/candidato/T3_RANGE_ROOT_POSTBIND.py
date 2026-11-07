from pathlib import Path
import copy,decimal,hashlib,json,sys
B=Path(__file__).resolve().parent
P='T3_RANGE_ROOT_'
def pg(x):
 if isinstance(x,dict):return '{'+', '.join(json.dumps(k,ensure_ascii=False)+': '+pg(x[k])for k in sorted(x,key=lambda k:(len(k.encode()),k.encode())))+'}'
 if isinstance(x,list):return '['+', '.join(map(pg,x))+']'
 if isinstance(x,decimal.Decimal):return str(x)
 return json.dumps(x,ensure_ascii=False)
sha=lambda x:hashlib.sha256(x if isinstance(x,bytes)else x.encode()).hexdigest()
m=json.loads((B/(P+'MANIFEST.json')).read_text());r=json.loads(Path(sys.argv[1]).read_text(),parse_float=decimal.Decimal)
if isinstance(r,list):r=r[0]
r=r.get('integrated_postddl_capture',r)
assert r['parent_revision']==m['parent_root'] and r['source_sha256']==m['source_sha256']
full=r['full_header_manifest'];assert set(full)=={'schema_version','functions','dependencies','indexes','triggers','constraints'} and full['schema_version']==m['full_manifest_schema']
assert full['functions']==m['functions_after'] and full['dependencies']==m['dependencies'] and full['triggers']==[m['trigger']]
assert full['indexes']==[m['index_before']]
assert len(full['constraints'])==1 and {k:v for k,v in full['constraints'][0].items()if k!='oid'}==m['constraint_after_without_oid'] and full['constraints'][0]['oid']!=m['constraint_before']['oid']
assert r['compact']=={'sha256':sha(pg(r['full_header_manifest'])),'source_sha256':m['source_sha256']}
base=json.loads(json.loads((B/(P+'BASELINE.json')).read_text())['root_canonical_preimage'],parse_float=decimal.Decimal)
assert sha(pg(base))==m['parent_root'];expected=copy.deepcopy(base)
for u in m['root_alias_updates']:
 at=expected
 for k in u['path'][:-1]:at=at[int(k)] if isinstance(at,list)else at[k]
 key=u['path'][-1];assert at[key]==u['old'];at[key]=r['target_bodies_after'][u['signature']][u['field']]
expected['db_core']['tactics_staff']=r['compact'];expected['db_core']['sha256']=sha(pg({k:v for k,v in expected['db_core'].items()if k!='sha256'}))
assert r['successor']==expected and pg(expected)==r['canonical_preimage'] and sha(pg(expected))==r['revision_sha256'] and len(pg(expected).encode())==r['root_bytes']==m['root_bytes']
template=(B/(P+'ADMIN_TEMPLATE.html')).read_bytes();assert sha(template)==m['admin_template_sha256']
old=("mfRevision='"+m['parent_root']+"'").encode();new=("mfRevision='"+r['revision_sha256']+"'").encode();assert template.count(old)==1
changed=template.replace(old,new,1);assert len(changed)==len(template)and changed.replace(new,old,1)==template
(B/(P+'ADMIN_BOUND.html')).write_bytes(changed);(B/(P+'ROOT_BOUND.canonical.json')).write_text(pg(expected));(B/(P+'FULL_HEADER_BOUND.json')).write_text(pg(r['full_header_manifest']))
print(json.dumps({'root':r['revision_sha256'],'admin_sha256':sha(changed),'admin_bytes':len(changed),'source_sha256':m['source_sha256']}))
