"""Materializza solo file dopo la review indipendente. Non esegue SQL e non emette il mandato umano."""
import argparse,pathlib,json,hashlib,datetime
from pglast import parser
ap=argparse.ArgumentParser();ap.add_argument('--review',required=True);ap.add_argument('--out',required=True);ap.add_argument('--minutes',type=int,default=8);args=ap.parse_args()
P=pathlib.Path('/private/tmp/tus-human-custom-ordinary');A=P/'backend/aggregate16';out=pathlib.Path(args.out);out.mkdir(parents=True,exist_ok=True)
sha=lambda p:hashlib.sha256(p.read_bytes()).hexdigest();review=pathlib.Path(args.review);r=json.loads(review.read_text());find=r.get('findings');assert find in ([0,0,0],{'P0':0,'P1':0,'P2':0}) and r.get('status','').startswith(('GREEN','PASS','QUALIFIED'))
f=json.loads((A/'INSTALL_MANIFEST.json').read_text())
for x in f['files']:assert sha(pathlib.Path(x['path']))==x['sha256'],x['path']
authority=P/'AUTHORITY_AGG16.json';assert sha(authority)=='ab3deda0149c49ad44eca9a3d7767f896816d9c38e6f3527a91330c23d3ef800'
# Root supplies the real final whole review; do not reuse any earlier countercheck.
assert '16' in review.name;assert sha(A/'DELTA_SOURCE.sql') in review.read_text() or sha(A/'INSTALL_MANIFEST.json') in review.read_text(),'review must bind frozen source/manifest'
b=json.loads((A/'BASELINE.json').read_text());assert 0<args.minutes<=10
now=datetime.datetime.now(datetime.timezone.utc);ev={'operation':'install_exact_human_custom_ordinary_C','authority_sha256':sha(authority),'expires_at':(now+datetime.timedelta(minutes=args.minutes)).isoformat(),'source_sha256':sha(A/'DELTA_SOURCE.sql'),'review_ref':'management/candidati/NARRATORE-UNIFICATO_2026-09-02/candidato/exam_human_master/HUMAN_CUSTOM_ORDINARY_REVIEW.json','review_sha256':sha(review),'review_findings':{'P0':0,'P1':0,'P2':0},'expected_kind':b['kind'],'expected_runtime':b['runtime'],'expected_fixed30':b['fixed30']}
t=(A/'INSTALL_TEMPLATE.sql').read_text();marker='-- __ROOT_FINITE_ENVELOPE__';assert t.count(marker)==1
v=json.dumps(ev,ensure_ascii=False,separators=(',',':'));assert '$rootpermit$'not in v;replacement="SELECT set_config('tus.human_custom_install',$rootpermit$"+v+"$rootpermit$,true);";material=t.replace(marker,replacement);assert material.replace(replacement,marker)==t
parser.parse_sql_json(material);parser.parse_plpgsql_json(material)
request={'project_id':'tyhyxkslteigibktluml','name':'human_custom_ordinary_aggregate16_staff','query':material}
transport_sizes={'SQL_bytes':len(material.encode()),'JSON_bytes':len(json.dumps(request).encode()),'double_JSON_bytes':len(json.dumps(json.dumps(request)).encode())}
assert transport_sizes['SQL_bytes']<=1200000 and transport_sizes['JSON_bytes']<=1500000 and transport_sizes['double_JSON_bytes']<1800000,transport_sizes
(out/'AGG16_ENVELOPE.json').write_text(json.dumps(ev,indent=2)+'\n');(out/'AGG16_MATERIAL.sql').write_text(material)
proof={'schema_version':'human-custom-aggregate16-exact-binding/1','issued_at':now.isoformat(),'expiry':ev['expires_at'],'source_sha256':ev['source_sha256'],'template_sha256':sha(A/'INSTALL_TEMPLATE.sql'),'material_sha256':sha(out/'AGG16_MATERIAL.sql'),'envelope_sha256':sha(out/'AGG16_ENVELOPE.json'),'authority_sha256':ev['authority_sha256'],'review_sha256':ev['review_sha256'],'only_replacement':marker,'closed_keys':sorted(ev),'inverse_exact':True,'SQL_PL_parser':'PASS','lease_effective':'authorized command start statement_timestamp(); +120min exact','QA30':'Root measures from successful commit; not from this permit','state':'MATERIAL_PENDING_INDEPENDENT_BINDING_REVIEW_NO_APPLY','provider_calls':0,'transport_sizes':transport_sizes,'transport_limit_provenance':'conservative below accepted aggregate9; no threshold probe'}
(out/'AGG16_BINDING.json').write_text(json.dumps(proof,indent=2)+'\n');print(json.dumps(proof,indent=2))
