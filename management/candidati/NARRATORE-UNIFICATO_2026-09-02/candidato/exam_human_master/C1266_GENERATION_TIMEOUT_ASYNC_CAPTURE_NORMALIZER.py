"""Closed SOURCE MCP capture decoder. No network, SQL, gameplay or app imports.
Outputs preserve decoded native facts; provenance is not execution qualification.
"""
import argparse,datetime,hashlib,json,pathlib,re
HEADER_KEYS={'signature','oid','owner','acl','config','secdef','volatility','language','source_md5','ddl_md5'}
DOC_KEYS={'schema_version','captured_at','headers','configuration_schema','rows','staff_open','combat_open','active_ai','active_provider'}
ROW_ALIASES={'readiness','g2','authoring','admissions','runtime','provider','flow'}
SCHEMA_TABLES={'mission_factory_owner.editor_release_readiness','mission_factory_owner.c464_control','mission_factory_owner.provider_authoring_runtime','mission_factory_owner.provider_authoring_admissions','mission_generic_owner.runtime_policy','mission_generic_owner.provider_policy','mission_generic_owner.flow_runtime_gate'}
STATUS='public.mission_generic_dispatch_async_status_v1(uuid,jsonb)'
FORBIDDEN_KEYS={'password','secret','api_key','apikey','service_role_key','authorization','cookie','jwt','access_token','refresh_token','connection_string','credential_url'}
def fail(code):raise ValueError(code)
def sha(b):return hashlib.sha256(b).hexdigest()
def read_ref(ref):
 p=pathlib.Path(ref['path']).resolve();name=p.name.lower()
 if p.suffix!='.json'and p.suffix!='.sql':fail('INPUT_TYPE_DENIED')
 if name.startswith('.env')or 'credential'in name or 'secret'in name:fail('SENSITIVE_INPUT_DENIED')
 if pathlib.Path(ref['path']).is_symlink()or not p.is_file():fail('INPUT_NOT_REGULAR')
 b=p.read_bytes()
 if len(b)>4*1024*1024 or sha(b)!=ref['sha256']:fail('INPUT_SIZE_OR_HASH_DRIFT')
 return b

def unique_object(pairs):
 result={}
 for k,v in pairs:
  if k in result:fail('DUPLICATE_JSON_KEY_DENIED')
  result[k]=v
 return result
def closed_json(text):return json.loads(text,object_pairs_hook=unique_object)
def decode_mcp(raw):
 if not isinstance(raw,dict)or raw.get('isError')is True:fail('MCP_ERROR_OR_FORMAT')
 content=raw.get('content')
 if not isinstance(content,list)or len(content)!=1 or content[0].get('type')!='text':fail('MCP_CONTENT_FORMAT')
 text=content[0].get('text')
 if not isinstance(text,str):fail('MCP_TEXT_REQUIRED')
 wrapper=closed_json(text)
 if not isinstance(wrapper,dict)or set(wrapper)!={'result'}or not isinstance(wrapper['result'],str):fail('MCP_RESULT_FORMAT')
 result=wrapper['result']
 # Match only the actual line-delimited data block, never the introductory warning mention.
 blocks=re.findall(r'\n<untrusted-data-([a-fA-F0-9-]+)>[ \t]*\n(.*?)\n</untrusted-data-\1>',result,re.S)
 if len(blocks)!=1:fail('MCP_UNTRUSTED_BOUNDARY_AMBIGUOUS')
 identifier,body=blocks[0];rows=closed_json(body)
 if not isinstance(rows,list):fail('MCP_ROWS_ARRAY_REQUIRED')
 return rows,identifier,body

def no_secrets(value):
 if isinstance(value,dict):
  if any(str(k).lower()in FORBIDDEN_KEYS for k in value):fail('SENSITIVE_FIELD_DENIED')
  for v in value.values():no_secrets(v)
 elif isinstance(value,list):
  for v in value:no_secrets(v)
 elif isinstance(value,str):
  if re.search(r'https?://[^/\s:@]+:[^/\s@]+@',value):fail('CREDENTIAL_URL_DENIED')
  # Canonical preimage is itself JSON; inspect it without changing its exact bytes.
  if value.startswith('{'):
   try:nested=json.loads(value)
   except json.JSONDecodeError:return
   no_secrets(nested)

def validate_doc(doc):
 if not isinstance(doc,dict)or set(doc)!=DOC_KEYS or doc['schema_version']!='c1266-timeout-root-live/1':fail('CLOSED_ROOT_CAPTURE_SHAPE')
 if not isinstance(doc['captured_at'],str):fail('SERVER_CAPTURE_TIME_REQUIRED')
 t=datetime.datetime.fromisoformat(doc['captured_at'].replace('Z','+00:00'))
 if t.tzinfo is None:fail('SERVER_CAPTURE_TIME_ZONE_REQUIRED')
 if not isinstance(doc['rows'],dict)or set(doc['rows'])!=ROW_ALIASES:fail('NATIVE_ROW_ALIASES_MISMATCH')
 if any(not isinstance(doc['rows'][k],dict)for k in ROW_ALIASES-{'admissions'}):fail('NATIVE_SINGLETON_MISSING')
 if not isinstance(doc['rows']['admissions'],list)or len(doc['rows']['admissions'])!=2:fail('NATIVE_ACTOR_ROWS_MISSING')
 schema=doc['configuration_schema']
 if not isinstance(schema,list)or len(schema)!=7 or {r['name']for r in schema}!=SCHEMA_TABLES:fail('SCHEMA7_NATIVE_CAPTURE_REQUIRED')
 if any(not isinstance(r['oid'],int)or r['oid']<=0 or not r.get('columns')for r in schema):fail('SCHEMA7_CATALOG_MISSING')
 headers=doc['headers']
 if not isinstance(headers,list)or len(headers)!=113:fail('HEADERS113_NATIVE_CAPTURE_REQUIRED')
 if any(not isinstance(h,dict)or set(h)!=HEADER_KEYS for h in headers):fail('CLOSED_HEADER_SHAPE')
 if len({h['signature']for h in headers})!=113:fail('DUPLICATE_NATIVE_SIGNATURE')
 missing=[]
 for h in headers:
  if not isinstance(h['signature'],str):fail('NATIVE_SIGNATURE_TYPE')
  if h['oid']is None:
   if any(v is not None for k,v in h.items()if k!='signature'):fail('MIXED_MISSING_HEADER_CAPTURE')
   missing.append(h['signature']);continue
  if not isinstance(h['oid'],int)or h['oid']<=0 or not isinstance(h['secdef'],bool):fail('NATIVE_HEADER_TYPES')
  if any(not isinstance(h[k],str)or re.fullmatch('[a-f0-9]{32}',h[k])is None for k in ['source_md5','ddl_md5']):fail('NATIVE_HASH_TYPES')
 if missing and missing!=[STATUS]:fail('UNEXPECTED_MISSING_NATIVE_FUNCTION')
 for k in ['staff_open','combat_open','active_ai','active_provider']:
  if type(doc[k])is not int or doc[k]<0:fail('NATIVE_COUNTER_TYPE')
 no_secrets(doc)
 return 'CURRENT112_H0_ONLY_STATUS_ABSENT'if missing else'CURRENT113_STRUCTURAL_ONLY_NOT_QUALIFIED'

def normalize(raw_ref,query_ref,source_static_ref,execution_ref):
 raw=closed_json(read_ref(raw_ref));query=read_ref(query_ref);source=json.loads(read_ref(source_static_ref));execution=json.loads(read_ref(execution_ref))
 if query.decode('utf-8')!=source['query_sql']or sha(query)!=source['query_sha256']:fail('EXACT_SOURCE_QUERY_DRIFT')
 if execution['raw_ref']!=raw_ref or execution['query_ref']!=query_ref or execution['read_only']is not True or execution['operation']!='execute_query':fail('EXECUTION_QUERY_RAW_LINK_REQUIRED')
 rows,identifier,body=decode_mcp(raw)
 if len(rows)!=1 or not isinstance(rows[0],dict)or set(rows[0])!={'timeout_root_live'}:fail('EXPECTED_QUERY_SINGLE_ROW_ALIAS')
 doc=rows[0]['timeout_root_live'];classification=validate_doc(doc)
 payload=re.fullmatch(r'\s*\[\s*\{\s*"timeout_root_live"\s*:\s*(.*?)\s*\}\s*\]\s*',body,re.S)
 if payload is None:fail('NATIVE_PAYLOAD_LEXEME_BOUNDARY')
 native_text=payload.group(1)
 if closed_json(native_text)!=doc:fail('NATIVE_PAYLOAD_LEXEME_MISMATCH')
 query_text=query.decode('utf-8');prefix=query_text.split(')SELECT jsonb_build_object',1)[0]
 expected=set(re.findall(r"\('([^']+)'\)",prefix))
 if len(expected)!=113 or {h['signature']for h in doc['headers']}!=expected:fail('EXACT_QUERY_NATIVE_SIGNATURE_SET_DRIFT')
 # No pin, boolean, sourceMD5, OID, UUID, row or timestamp is recomputed or repaired.
 return native_text,{'schema_version':'c1266-capture-normalization-provenance/1','classification':classification,'original_raw_ref':raw_ref,'query_ref':query_ref,'source_static_ref':source_static_ref,'execution_receipt_ref':execution_ref,'untrusted_boundary_id':identifier,'captured_at_server':doc['captured_at'],'fields_preserved':True,'Source_qualification':False,'runtime_eligibility':'INDEPENDENT_ACTUAL_REVIEW_REQUIRED'}

def main():
 p=argparse.ArgumentParser();p.add_argument('--input',required=True);p.add_argument('--out',required=True);p.add_argument('--inspect-history',action='store_true');a=p.parse_args();x=json.loads(pathlib.Path(a.input).read_text());out=pathlib.Path(a.out).resolve()
 if not str(out).startswith('/private/tmp/')or out.is_symlink():fail('OUTPUT_PRIVATE_STAGE_REQUIRED')
 out.mkdir(parents=True,exist_ok=True)
 if a.inspect_history:
  rows,boundary,_=decode_mcp(json.loads(read_ref(x['raw_ref'])))
  report={'classification':'HISTORICAL_FORMAT_ONLY_NOT_ROOT113_INPUT','original_raw_ref':x['raw_ref'],'row_count':len(rows),'row_keys':[sorted(r)for r in rows if isinstance(r,dict)],'untrusted_boundary_id':boundary,'qualified':False}
  (out/'HISTORY_FORMAT.json').write_text(json.dumps(report,indent=2)+'\n');return
 native_text,receipt=normalize(x['raw_ref'],x['query_ref'],x['source_static_ref'],x['execution_ref']);file=out/'NORMALIZED.json';file.write_text(native_text+'\n')
 # This alias matches Rootfresh().receipt.raw_ref; original bytes remain separately bound.
 receipt['raw_ref']={'path':str(file),'sha256':sha(file.read_bytes())};receipt['normalized_ref']=receipt['raw_ref']
 (out/'PROVENANCE.json').write_text(json.dumps(receipt,ensure_ascii=False,indent=2)+'\n')
if __name__=='__main__':main()
