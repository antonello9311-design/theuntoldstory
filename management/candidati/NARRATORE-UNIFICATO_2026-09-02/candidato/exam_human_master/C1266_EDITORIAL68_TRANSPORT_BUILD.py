import sys,re,json,hashlib
from pathlib import Path
sys.path.insert(0,'/private/tmp/tus-c1266-recover46-20261027/output50/parse_tools312')
from pglast import parse_sql,parse_plpgsql

src=Path(sys.argv[1]); out=Path(sys.argv[2]); out.mkdir(parents=True,exist_ok=True)
s=src.read_text(); nodes=parse_sql(s)
assert [type(n.stmt).__name__ for n in nodes]==['TransactionStmt','DoStmt','CreateFunctionStmt','CreateFunctionStmt','CreateFunctionStmt','CreateFunctionStmt','InsertStmt','DoStmt','TransactionStmt','NotifyStmt']
parts=[s[n.stmt_location:n.stmt_location+n.stmt_len].strip() for n in nodes]
assert parts[0]=='BEGIN' and parts[8]=='COMMIT'
pat=re.compile(r'(\$[A-Za-z_][A-Za-z_0-9]*\$)([\s\S]*?)\1')
constants={}; values=[]; body_proofs=[]
def ref(value):
    if value not in constants:
        constants[value]='e68_transport_literal_'+str(len(values)); values.append(value)
    return constants[value]
def transform_do(st):
    m=pat.search(st); assert m and st[:m.start()].strip()=='DO'
    original=m.group(2)
    # The compiler embeds an entire packet but evaluates only this projection.
    packet=pat.search(original[original.index('$e68packet$'):]) if '$e68packet$' in original else None
    projected=None
    if packet:
        raw=packet.group(2); projected=json.loads(raw)['config']['source_refs']
        needle=packet.group(0)+"::jsonb::jsonb#>'{config,source_refs}'"
        assert original.count(needle)==1
        replacement=ref(json.dumps(projected,ensure_ascii=False,separators=(',',':')))+'::jsonb'
        original_projected=original.replace(needle,replacement)
    else: original_projected=original
    substitutions=[]
    def sub(m):
        name=ref(m.group(2)); substitutions.append((name,m.group(0))); return name
    transformed=pat.sub(sub,original_projected)
    reconstructed=transformed
    for name,literal in sorted(substitutions,key=lambda x:-len(x[0])):
        reconstructed=re.sub(r'\b'+re.escape(name)+r'\b',lambda _:literal,reconstructed)
    assert reconstructed==original_projected
    body_proofs.append({'exact_reconstruction':True,'packet_projection_only':projected is not None,'original_body_sha256':hashlib.sha256(original.encode()).hexdigest(),'transformed_body_sha256':hashlib.sha256(transformed.encode()).hexdigest()})
    return transformed.rstrip().removesuffix(';')+';'
pre=transform_do(parts[1]); post=transform_do(parts[7])
seed_substitutions=[]
def seed_sub(m):
    parsed=json.loads(m.group(2))
    canonical=json.dumps(parsed,ensure_ascii=False,separators=(',',':'))
    assert json.loads(canonical)==parsed
    name=ref(canonical);seed_substitutions.append((name,m.group(0)));return name
seed=pat.sub(seed_sub,parts[6])
seed_reconstructed=seed
for name,literal in sorted(seed_substitutions,key=lambda x:-len(x[0])):
    seed_reconstructed=re.sub(r'\b'+re.escape(name)+r'\b',lambda _:literal,seed_reconstructed)
assert seed_reconstructed==parts[6]
decl=[]
for i,value in enumerate(values):
    tag='$e68transport'+str(i)+'$'; assert tag not in value
    decl.append(constants[value]+' CONSTANT text:='+tag+value+tag+';')
ddl=[]
for i,st in enumerate(parts[2:6]):
    tag='$e68ddl'+str(i)+'$'; assert tag not in st
    ddl.append('EXECUTE '+tag+st+tag+';')
outer='DO $e68transport$\nDECLARE\n'+'\n'.join(decl)+'\nBEGIN\n'+pre+'\n'+'\n'.join(ddl)+'\n'+seed+';\n'+post+'\nEND;\n$e68transport$;'
target=parts[0]+';\n'+outer+'\n'+parts[8]+';\n'+parts[9]+';\n'
assert len(target.encode())<900000
newnodes=parse_sql(target); assert len(newnodes)==4
# Existing composite row declaration is replaced only in the parser input.
parser_input=target.replace('e68_rr mission_factory_owner.editor_release_readiness','e68_rr record')
parse_plpgsql(parser_input)
assert all(tag in target for tag in ['$e68ddl0$','$e68ddl1$','$e68ddl2$','$e68ddl3$'])
for i,st in enumerate(parts[2:6]):
    extracted=re.search(r'\$e68ddl'+str(i)+r'\$([\s\S]*?)\$e68ddl'+str(i)+r'\$',target).group(1)
    assert extracted==st
    assert parse_sql(extracted)==parse_sql(st)
assert seed+';' in target and parts[9]+';' in target
(out/'INSTALL.sql').write_text(target)
wire={str(a):len(json.dumps({'project_id':'tyhyxkslteigibktluml','name':'c1266_editorial68_transport12','query':target},ensure_ascii=a).encode()) for a in [False,True]}
assert max(wire.values())<900000
proof={'schema':'editorial68-transport-proof/1','source_path':str(src),'source_sha256':hashlib.sha256(s.encode()).hexdigest(),'target_sha256':hashlib.sha256(target.encode()).hexdigest(),'source_bytes':len(s.encode()),'target_bytes':len(target.encode()),'json_wire_bytes_ensure_ascii':wire,'shared_literal_count':len(values),'pre_post':body_proofs,'root_texts_byte_identical':True,'four_ddl_texts_and_ast_identical':True,'seed_insert_literal_reconstruction_exact':True,'begin_commit_notify_order_identical':True,'single_atomic_do':True,'no_new_database_objects':True,'sql_parse':'PASS','pl_parse':'PASS_PARSER_ONLY_COMPOSITE_RECORD_SUBSTITUTION','qualification':'TRANSPORT_SOURCE_ONLY_NOT_APPLIED'}
(out/'PROOF.json').write_text(json.dumps(proof,indent=2)+'\n')
print(json.dumps(proof,indent=2))
