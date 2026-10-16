import pathlib,json,hashlib
from pglast import parser
A=pathlib.Path(__file__).parent;P=A.parent.parent
template=(A/'INSTALL_TEMPLATE.sql').read_text();old=json.loads((P/'material_agg11/AGG11_ENVELOPE.json').read_text());sample=dict(old)
# In-memory invalid sizing data only: no Root permit or executable material emitted.
sample.update(operation='NO_AUTHORITY_SIZE_ONLY_NOT_EXECUTABLE',authority_sha256='0'*64,review_sha256='0'*64,expires_at='1970-01-01T00:00:00.000000+00:00')
marker='-- __ROOT_FINITE_ENVELOPE__';assert template.count(marker)==1
replacement="SELECT set_config('tus.human_custom_install',$rootpermit$"+json.dumps(sample,ensure_ascii=False,separators=(',',':'))+"$rootpermit$,true);"
material=template.replace(marker,replacement);assert material.replace(replacement,marker)==template
parser.parse_sql_json(material);parser.parse_plpgsql_json(material)
args=dict(project_id='tyhyxkslteigibktluml',name='human_custom_ordinary_aggregate16_staff',query=material)
sizes=dict(SQL_bytes=len(material.encode()),JSON_bytes=len(json.dumps(args).encode()),double_JSON_bytes=len(json.dumps(json.dumps(args)).encode()))
assert sizes['SQL_bytes']<=1200000 and sizes['JSON_bytes']<=1500000 and sizes['double_JSON_bytes']<1800000
proof=dict(schema_version='human-MCP-transport-sizing/1',state='PURE_FILE_STATIC_NO_AUTHORITY_NO_APPLY',source_sha256=hashlib.sha256((A/'DELTA_SOURCE.sql').read_bytes()).hexdigest(),template_sha256=hashlib.sha256(template.encode()).hexdigest(),template_bytes=len(template.encode()),sizing_payload='In-memory deliberately invalid operation, zero authority/review hashes, 1970 expiry; no SQL material or envelope file emitted',request_fields=list(args),serializer='Python json.dumps default for first and second serialization; UTF8 byte lengths',sizes=sizes,limits=dict(SQL_max=1200000,JSON_max=1500000,double_JSON_strict_less=1800000),headroom_vs_limits={k:lim-sizes[k]for k,lim in [('SQL_bytes',1200000),('JSON_bytes',1500000),('double_JSON_bytes',1800000)]},accepted_aggregate9_reference=dict(SQL=1344645,JSON=1499627,double_JSON=1808848),rejected_aggregate11_reference=dict(SQL=1545484,JSON=1719379,double_JSON=2066030),no_exact_API_limit_claim=True,no_apply_threshold_probe=True,real_binding='materialize_root.py recalculates actual future Root material and both serialization lengths before emitting its files',one_atomic_transaction=True)
(A/'TRANSPORT_SIZE_PROOF.json').write_text(json.dumps(proof,indent=2));print(sizes)
