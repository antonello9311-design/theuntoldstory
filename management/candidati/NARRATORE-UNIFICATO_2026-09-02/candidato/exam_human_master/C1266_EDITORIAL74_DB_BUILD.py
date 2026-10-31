"""Pure E74 Root metadata compiler. Does not execute database/provider operations."""
from pathlib import Path
REVIEW_REF='C1266_EDITORIAL74_REVIEW.json'
import json,hashlib,re,copy,sys,ast,argparse
from decimal import Decimal
j=lambda x:json.dumps(x,ensure_ascii=False,separators=(',',':'))
sha=lambda x:hashlib.sha256(x.encode()).hexdigest()
def dq(x,t):
 tag='$'+t+'$';assert tag not in x;return tag+x+tag
def native_capture_query(packet):
 """One readonly snapshot: native preservation plus current catalog metadata."""
 full_query=packet['preservation_full_query'].strip().removesuffix(';')
 reference=j(packet['preservation_semantic_reference'])
 abi_refs=[{'signature':x['signature']}for x in packet['catalog_reference_abis']]
 table_refs=[x['relation']for x in packet['catalog_reference_tables']]
 query="""WITH e73_preserved AS MATERIALIZED(FULL_QUERY),
e73_root AS MATERIALIZED(SELECT rr.*,rr.canonical_preimage::jsonb root_value FROM mission_factory_owner.editor_release_readiness rr WHERE singleton),
e73_headers AS(SELECT eh.value expected,(SELECT jsonb_build_object('signature',eh.value->>'signature','oid',p.oid::bigint,'owner',pg_catalog.pg_get_userbyid(p.proowner),'acl',p.proacl::text,'config',to_jsonb(p.proconfig),'secdef',p.prosecdef,'language',l.lanname,'volatility',p.provolatile::text,'source_md5',pg_catalog.md5(p.prosrc),'ddl_md5',pg_catalog.md5(pg_catalog.pg_get_functiondef(p.oid)))FROM pg_catalog.pg_proc p JOIN pg_catalog.pg_language l ON l.oid=p.prolang WHERE p.oid=pg_catalog.to_regprocedure(eh.value->>'signature'))actual FROM e73_root rr CROSS JOIN LATERAL jsonb_array_elements(rr.root_value#>'{db_core,all_function_headers}')eh(value)),
e73_abis AS(SELECT ea.value->>'signature' AS signature,(SELECT jsonb_build_object('return_type',p.prorettype::regtype::text,'retset',p.proretset,'kind',p.prokind::text,'strict',p.proisstrict,'parallel',p.proparallel::text,'leakproof',p.proleakproof,'argument_names',coalesce(to_jsonb(p.proargnames),'[]'::jsonb),'argument_defaults_count',p.pronargdefaults,'argument_defaults_sql',pg_catalog.pg_get_expr(p.proargdefaults,0),'argument_modes',to_jsonb(coalesce(p.proargmodes,array_fill('i'::"char",ARRAY[p.pronargs::integer]))),'argument_count',p.pronargs,'variadic_type',p.provariadic::bigint,'cost',p.procost,'rows',p.prorows,'support_oid',p.prosupport::bigint)FROM pg_proc p WHERE p.oid=to_regprocedure(ea.value->>'signature'))AS abi FROM jsonb_array_elements(ABI_REFS::jsonb)ea(value)),
e73_tables AS(SELECT jsonb_build_object('relation',ec.oid::regclass::text,'owner',pg_get_userbyid(ec.relowner),'rls',ec.relrowsecurity,'acl',ec.relacl::text,'columns',(SELECT jsonb_agg(jsonb_build_object('name',ea.attname,'type',format_type(ea.atttypid,ea.atttypmod),'notnull',ea.attnotnull,'default',pg_get_expr(ed.adbin,ed.adrelid))ORDER BY ea.attnum)FROM pg_attribute ea LEFT JOIN pg_attrdef ed ON ed.adrelid=ea.attrelid AND ed.adnum=ea.attnum WHERE ea.attrelid=ec.oid AND ea.attnum>0 AND NOT ea.attisdropped))meta FROM pg_class ec WHERE ec.oid IN(SELECT to_regclass(value)FROM jsonb_array_elements_text(TABLE_REFS::jsonb)))
SELECT p.preservation::text AS preservation_native_text,public.combat_v2_sha256(p.preservation)AS preservation_native_sha256,p.preservation=SEMANTIC_REFERENCE::jsonb AS semantic_jsonb_equal,octet_length(p.preservation::text)AS native_text_bytes,
(SELECT jsonb_build_object('revision',rr.revision_sha256,'observed',rr.observed_revision_sha256,'state',rr.state,'scope',rr.scope,'row_sha256',public.combat_v2_sha256(to_jsonb(rr)-'root_value'),'guards_verified',rr.staff_guards_verified AND rr.published_assets_verified)FROM e73_root rr)AS root_meta,
(SELECT jsonb_agg(actual ORDER BY actual->>'signature')FROM e73_headers)AS headers,
(SELECT coalesce(jsonb_agg(expected->>'signature'ORDER BY expected->>'signature'),'[]'::jsonb)FROM e73_headers WHERE actual IS DISTINCT FROM expected)AS header_mismatches,
(SELECT jsonb_agg(to_jsonb(a)ORDER BY signature)FROM e73_abis a)AS abis,
(SELECT jsonb_agg(meta ORDER BY meta->>'relation')FROM e73_tables)AS tables,
(SELECT jsonb_agg(jsonb_build_object('relation',conrelid::regclass::text,'name',conname,'definition',pg_get_constraintdef(oid),'validated',convalidated,'type',contype::text)ORDER BY conrelid::regclass::text,conname)FROM pg_constraint WHERE conrelid IN(SELECT to_regclass(value)FROM jsonb_array_elements_text(TABLE_REFS::jsonb)))AS constraints
FROM e73_preserved p;"""
 values={'FULL_QUERY':full_query,'SEMANTIC_REFERENCE':dq(reference,'e73semanticref'),'ABI_REFS':dq(j(abi_refs),'e73abirefs'),'TABLE_REFS':dq(j(table_refs),'e73tablerefs')}
 q=re.sub(r'\b('+'|'.join(values)+r')\b',lambda m:values[m.group(0)],query)
 return q.replace('\nFROM e73_preserved p;', ",\npg_get_functiondef('mission_narrative_internal.editorial_authority_v1(uuid,uuid,uuid,boolean)'::regprocedure) AS authority_source,\n(SELECT to_jsonb(ec) FROM mission_narrative_internal.editorial_campaigns_v1 ec WHERE id='ff79949a-06cb-5749-a33f-3d632d78f3a5')AS source_campaign,\n(SELECT count(*)FROM mission_narrative_internal.editorial_campaigns_v1 WHERE id='beabfc88-ae45-53b1-b081-d137cd8eac41')AS new_campaign_rows\nFROM e73_preserved p;")

def verify_native_capture(packet):
 capture=packet['native_capture'];query=native_capture_query(packet)
 assert capture['schema']=='editorial74-native-preservation-capture/1'
 assert sha(query)==capture['query_sha256']
 row=capture['row'];native_text=row['preservation_native_text']
 assert sha(native_text)==row['preservation_native_sha256']
 assert len(native_text.encode('UTF8'))==row['native_text_bytes']
 assert json.loads(native_text,parse_float=Decimal)==json.loads(j(packet['preservation_semantic_reference']),parse_float=Decimal)
 assert row['semantic_jsonb_equal']is True
 meta=row['root_meta'];assert meta['revision']==meta['observed']==packet['baseline_root']
 assert meta['row_sha256']==packet['baseline_root_row_sha256']
 assert meta['state']=='enabled'and meta['scope']=='staff'and meta['guards_verified']is True
 expected=json.loads(packet['baseline_canonical_preimage'])['db_core']['all_function_headers']
 assert len(row['headers'])==246 and row['header_mismatches']==[]
 assert sorted(row['headers'],key=lambda x:x['signature'])==sorted(expected,key=lambda x:x['signature'])
 assert row['abis']==packet['catalog_reference_abis']==packet['abis']
 assert row['tables']==packet['catalog_reference_tables']==packet['tables']
 assert row['constraints']==packet['catalog_reference_constraints']==packet['constraints']
 assert row['new_campaign_rows']==0 and row['source_campaign']['enabled']is False
 assert row['source_campaign']['id']==packet['controlled_reuse']['source_campaign']
 before=row['authority_source'];assert hashlib.md5(before.encode()).hexdigest()==packet['function']['before_header']['ddl_md5']
 after=packet['function']['source']
 for change in reversed(packet['controlled_reuse']['actual_live_authority_three_predicate_delta']):after=after.replace(change['after'],change['before'])
 assert after==before
 assert packet['preservation']=={'sha256':row['preservation_native_sha256']}
 return {'native_text_sha256':row['preservation_native_sha256'],'query_sha256':capture['query_sha256'],'receipt_sha256':capture['receipt_sha256'],'native_text_bytes':row['native_text_bytes'],'semantic_equal_Decimal':True,'headers_246_abis_10_tables_5_constraints_68_exact':True,'client_numeric_roundtrip_used_for_identity':False}

a=argparse.ArgumentParser();a.add_argument('--packet',required=True);a.add_argument('--edge-package');a.add_argument('--ui-manifest');a.add_argument('--material');a.add_argument('--out');a.add_argument('--capture-query-output');o=a.parse_args();p=json.loads(Path(o.packet).read_text())
if o.capture_query_output:
 q=native_capture_query(p);sys.path.insert(0,'/private/tmp/tus-c1266-recover46-20261027/output50/parse_tools312');from pglast import parse_sql
 assert len(parse_sql(q))==1;Path(o.capture_query_output).write_text(q);print(json.dumps({'native_capture_query_sha256':sha(q),'bytes':len(q.encode()),'readonly_only':True}));sys.exit(0)
assert o.out and o.edge_package and o.ui_manifest
P=Path(o.out);P.mkdir(parents=True,exist_ok=True)
native_capture_proof=verify_native_capture(p)
base=p['baseline_canonical_preimage'];root=json.loads(base);assert sha(base)==p['baseline_root'];assert len(root['db_core']['all_function_headers'])==246
assert sha(Path(o.edge_package).read_text())==p['edge_package_sha256']
edge=json.loads(Path(o.edge_package).read_text());assert edge['name']=='mission_generic_ai'and edge['verify_jwt']is False and len(edge['files'])==16
files=[{'name':f['name'],'bytes':len(f['content'].encode()),'sha256':sha(f['content'])}for f in edge['files']];assert len(set(f['name']for f in files))==16
semantic=sha(j({'schema':'editorial74-root-metadata/1','baseline':sha(base),'Edge':files,'plan_sha256':p['plan_sha256'],'contract_sha256':p['contract_sha256'],'cases_sha256':p['cases_sha256'],'DB_source_md5':p['function']['source_md5'],'seed_policy_sha256':p['config']['policy_sha256'],'UI_manifest_sha256':sha(Path(o.ui_manifest).read_text()),'native_preservation_capture':native_capture_proof}))
params={'schema':'editorial74-material/1','semantic':semantic,'review_ref':REVIEW_REF,'review_sha':'0'*64,'p0':0,'p1':0,'p2':0,'edge_verified':False,'edge_version':'__E74_EDGE_VERSION__','edge_ezbr_sha256':'0'*64,'ui_git_head':'0'*40,'assets_verified':False}
if o.material:
 params=json.loads(Path(o.material).read_text());assert params['schema']=='editorial74-material/1'and params['semantic']==semantic and params['review_ref']==REVIEW_REF
 assert params['p0']==params['p1']==params['p2']==0 and params['edge_verified']is True and params['assets_verified']is True and isinstance(params['edge_version'],int)and params['edge_version']>138
 assert all(re.fullmatch('[a-f0-9]{64}',params[k])for k in ['review_sha','edge_ezbr_sha256'])and re.fullmatch('[a-f0-9]{40}',params['ui_git_head'])
f=p['function'];cfg=p['config'];ui=json.loads(Path(o.ui_manifest).read_text());uifiles={}
uipath=lambda uf:Path(uf['candidate_path'])if Path(uf['candidate_path']).is_absolute()else Path(o.ui_manifest).parent/uf['candidate_path']
for uf in ui['files']:
 ub=uipath(uf).read_bytes();assert len(ub)==uf['candidate_bytes']and hashlib.sha256(ub).hexdigest()==uf['candidate_sha256'];uifiles[Path(uf['path']).name]={'bytes':len(ub),'sha256':uf['candidate_sha256']}
c=copy.deepcopy(root)
def rewrite(v):
 if isinstance(v,dict):
  if v.get('signature')==f['signature']:
   if 'source_md5'in v:v['source_md5']=f['source_md5']
   if 'ddl_md5'in v:v['ddl_md5']='__E74_DDL__'
  for x in v.values():rewrite(x)
 elif isinstance(v,list):
  for x in v:rewrite(x)
rewrite(c['db_core'])
c['config']['c1266_editorial68']={'campaign_id':cfg['campaign_id'],'policy_sha256':cfg['policy_sha256'],'active_variants':['director','writer']}
c['ui']['git_head']=params['ui_git_head'];c['ui']['narrative_scene_version']=re.search(r"export const VERSION=['\"]([^'\"]+)",uipath(next(uf for uf in ui['files']if uf['path'].endswith('mission-generic-ui.mjs'))).read_text()).group(1);c['ui']['module_pin']='editorial74-'+uifiles['mission-generic-ui.mjs']['sha256'][:16]
for name,meta in uifiles.items():c['ui']['files'][name]=meta
c['contract']['code_identity_sha256']=semantic;c['recovery']['semantic_identity_sha256']=semantic;c['edge_bundles'][0].update(version=params['edge_version'],ezbr_sha256=params['edge_ezbr_sha256'],files=files)
assert (c['config']|{'c1266_editorial68':root['config']['c1266_editorial68']})==root['config'];assert {k:v for k,v in c['recovery'].items()if k!='semantic_identity_sha256'}=={k:v for k,v in root['recovery'].items()if k!='semantic_identity_sha256'};ct=j(c);assert len(ct.encode())<=262144
frag=Path('/private/tmp/tus-c1266-combat64-20261030/release30/HEADER_CAPTURE_FRAGMENT.sql').read_text();header=frag.replace('INTO actual','INTO e74_actual').replace('to_regprocedure(sig)','to_regprocedure(e74_sig)').replace("'signature',sig","'signature',e74_sig")
tree=ast.parse(Path('/private/tmp/tus-c1266-combat64-20261030/release30/build_release30.py').read_text());abi=next(ast.literal_eval(n.value)for n in tree.body if isinstance(n,ast.Assign)and any(isinstance(t,ast.Name)and t.id=='abi_sql'for t in n.targets));abi=abi.replace('INTO abi','INTO e74_abi').replace('to_regprocedure(sig)','to_regprocedure(e74_sig)')
capture='SELECT preservation INTO e74_data FROM ('+p['preservation_query'].strip().removesuffix(';')+') e74_capture_row;'
guards="""FOR e74_item IN SELECT value FROM jsonb_array_elements(e74_headers)LOOP e74_sig:=e74_item->>'signature';HEADER
IF e74_actual IS DISTINCT FROM e74_item THEN RAISE EXCEPTION 'E74_HEADER_DRIFT %',e74_sig;END IF;END LOOP;
FOR e74_item IN SELECT value FROM jsonb_array_elements(e74_abis)LOOP e74_sig:=e74_item->>'signature';ABI
IF e74_abi IS DISTINCT FROM e74_item->'abi'THEN RAISE EXCEPTION 'E74_ABI_DRIFT %',e74_sig;END IF;END LOOP;
FOR e74_item IN SELECT value FROM jsonb_array_elements(e74_constraints)LOOP
SELECT jsonb_build_object('relation',conrelid::regclass::text,'name',conname,'definition',pg_get_constraintdef(oid),'validated',convalidated,'type',contype::text)INTO e74_actual FROM pg_constraint WHERE conrelid=(e74_item->>'relation')::regclass AND conname=e74_item->>'name';
IF e74_actual IS DISTINCT FROM e74_item THEN RAISE EXCEPTION 'E74_CONSTRAINT_DRIFT';END IF;END LOOP;
IF(SELECT count(*)FROM pg_constraint WHERE conrelid IN(SELECT DISTINCT(value->>'relation')::regclass FROM jsonb_array_elements(e74_constraints)))<>jsonb_array_length(e74_constraints)THEN RAISE EXCEPTION 'E74_CONSTRAINT_SET_DRIFT';END IF;
FOR e74_item IN SELECT value FROM jsonb_array_elements(e74_tables)LOOP
SELECT jsonb_build_object('relation',ec.oid::regclass::text,'owner',pg_get_userbyid(ec.relowner),'rls',ec.relrowsecurity,'acl',ec.relacl::text,'columns',(SELECT jsonb_agg(jsonb_build_object('name',ea.attname,'type',format_type(ea.atttypid,ea.atttypmod),'notnull',ea.attnotnull,'default',pg_get_expr(ed.adbin,ed.adrelid))ORDER BY ea.attnum)FROM pg_attribute ea LEFT JOIN pg_attrdef ed ON ed.adrelid=ea.attrelid AND ed.adnum=ea.attnum WHERE ea.attrelid=ec.oid AND ea.attnum>0 AND NOT ea.attisdropped))INTO e74_actual FROM pg_class ec WHERE ec.oid=to_regclass(e74_item->>'relation');
IF e74_actual IS DISTINCT FROM e74_item THEN RAISE EXCEPTION 'E74_TABLE_DRIFT';END IF;END LOOP;
CAPTURE
IF e74_data IS DISTINCT FROM e74_preserved THEN RAISE EXCEPTION 'E74_PROTECTED_HISTORY_DRIFT';END IF;"""
guards=re.sub(r'\b(HEADER|ABI|CAPTURE)\b',lambda m:{'HEADER':header,'ABI':abi,'CAPTURE':capture}[m.group(0)],guards)
decl='\n'.join(k+' text:='+dq(v,k)+';'for k,v in {'e74_base':base,'e74_new':ct}.items())+'\n'+'\n'.join(k+' jsonb:='+dq(j(v),k)+'::jsonb;'for k,v in {'e74_params':params,'e74_preserved':p['preservation'],'e74_abis':p['abis'],'e74_constraints':p['constraints'],'e74_tables':p['tables'],'e74_seed_policy':cfg['policy'],'e74_seed_refs':cfg['source_refs'],'e74_beforeheader':f['before_header'],'e74_headers':root['db_core']['all_function_headers']}.items())

source_auth="IF EXISTS(SELECT 1 FROM mission_narrative_internal.editorial_campaigns_v1 WHERE id='CAMPAIGN')THEN RAISE EXCEPTION 'E74_CAMPAIGN_EXISTS';END IF;\n FOR e74_item IN SELECT value FROM jsonb_array_elements(e74_seed_refs)LOOP\n IF NOT EXISTS(SELECT 1 FROM mission_creation_owner.revisions r JOIN mission_generic_owner.definitions d ON d.plan_version_id=r.plan_version_id JOIN public.mission_plan_versions v ON v.id=d.plan_version_id WHERE r.plan_version_id=(e74_item#>>'{source,plan_version_id}')::uuid AND v.stato='approvata'AND v.plan_sha256=e74_item#>>'{source,plan_sha256}'AND r.document_sha256=e74_item#>>'{source,snapshot,document_sha256}'AND r.document_sha256=mission_internal.fingerprint(r.document)AND d.id=(e74_item#>>'{source,snapshot,definition_id}')::uuid AND d.definition_sha256=e74_item#>>'{source,snapshot,definition_sha256}'AND d.definition_sha256=mission_internal.fingerprint(d.definition)AND r.document#>'{editorial,setting}'=e74_item#>'{source,snapshot,scene,setting}') THEN RAISE EXCEPTION 'E68_VERSIONED_SOURCE_DRIFT';END IF;\n IF EXISTS(SELECT 1 FROM jsonb_array_elements(e74_item#>'{source,npc_refs}')nr WHERE NOT EXISTS(SELECT 1 FROM public.nb_template_versions nv JOIN public.nb_mechanical_bindings nb ON nb.narrative_version_id=nv.id WHERE nv.id=(nr->>'version_id')::uuid AND nv.template_id=(nr->>'template_id')::uuid AND nv.review_state='approved'AND nv.content_sha256=nr->>'content_sha256'AND nb.id=(nr->>'binding_id')::uuid AND nb.lifecycle_state='approved'AND NOT nb.active AND EXISTS(SELECT 1 FROM jsonb_array_elements(e74_item#>'{source,snapshot,scene,npcs}')np WHERE np->>'actor_key'=nr->>'actor_key'AND np->>'narrative_version_id'=nv.id::text AND np->'profile'=nv.skeleton AND np->'knowledge'=nv.knowledge_boundary))) THEN RAISE EXCEPTION 'E68_PROFILE_SOURCE_DRIFT';END IF;\n IF EXISTS(SELECT 1 FROM jsonb_array_elements(e74_item#>'{source,last_fati}')hf WHERE NOT EXISTS(SELECT 1 FROM public.messages m WHERE m.id=(hf->>'message_id')::uuid AND m.kind='fato'AND m.recipient_user IS NULL AND m.location_id='0b85f354-9cdb-47e1-baf9-3d266bb7e06b'AND m.body=hf->>'body'AND encode(extensions.digest(convert_to(m.body,'UTF8'),'sha256'),'hex')=hf->>'body_sha256')) OR EXISTS(SELECT 1 FROM jsonb_array_elements(e74_item#>'{source,questions}')q WHERE encode(extensions.digest(convert_to(q->>'body','UTF8'),'sha256'),'hex')IS DISTINCT FROM q->>'body_sha256') THEN RAISE EXCEPTION 'E68_REAL_HISTORY_QUESTION_DRIFT';END IF;END LOOP;\n"
mutations="EXECUTE DDL;\ne74_sig:='SIGNATURE';HEADER\nIF(e74_actual-'ddl_md5'-'source_md5')IS DISTINCT FROM(e74_beforeheader-'ddl_md5'-'source_md5')OR e74_actual->>'source_md5'<>'NEWMD5'THEN RAISE EXCEPTION 'E74_CHANGED_FUNCTION_DRIFT';END IF;\ne74_new:=replace(e74_new,to_jsonb('__E74_DDL__'::text)::text,to_jsonb(e74_actual->>'ddl_md5')::text);\ne74_headers:=e74_new::jsonb#>'{db_core,all_function_headers}';\nINSERT INTO mission_narrative_internal.editorial_campaigns_v1(id,policy,source_refs,policy_sha256,enabled)VALUES('CAMPAIGN',e74_seed_policy,e74_seed_refs,'POLICY_SHA',false);\nIF NOT EXISTS(SELECT 1 FROM mission_narrative_internal.editorial_campaigns_v1 ec WHERE ec.id='CAMPAIGN'AND NOT ec.enabled AND ec.policy=e74_seed_policy AND ec.source_refs=e74_seed_refs AND ec.policy_sha256='POLICY_SHA'AND ec.policy_sha256=public.combat_v2_sha256(jsonb_build_object('policy',ec.policy,'source_refs',ec.source_refs)))OR EXISTS(SELECT 1 FROM mission_narrative_internal.editorial_runs_v1 WHERE campaign_id='CAMPAIGN')OR EXISTS(SELECT 1 FROM staff_ai_quota_private.calls WHERE scope_id='CAMPAIGN')THEN RAISE EXCEPTION 'E74_SEED_DRIFT';END IF;"
mutations=re.sub(r'\b(DDL|SIGNATURE|HEADER|NEWMD5|CAMPAIGN|POLICY_SHA)\b',lambda m:{'DDL':dq(f['source'],'e74ddl'),'SIGNATURE':f['signature'],'HEADER':header,'NEWMD5':f['source_md5'],'CAMPAIGN':cfg['campaign_id'],'POLICY_SHA':cfg['policy_sha256']}[m.group(0)],mutations)
source_auth=re.sub(r'\bCAMPAIGN\b',lambda _:cfg['campaign_id'],source_auth)
sql="""BEGIN;DO $e74_root$
DECLARE DECL
e74_item jsonb;e74_actual jsonb;e74_abi jsonb;e74_sig text;e74_data jsonb;e74_rr mission_factory_owner.editor_release_readiness;e74_sha text;
BEGIN
IF e74_params->>'schema'<>'editorial74-material/1'OR e74_params->>'semantic'<>'SEMANTIC'OR e74_params->>'review_ref'<>'REVIEW_REF_TOKEN'OR coalesce(e74_params->>'review_sha','')!~'^[a-f0-9]{64}$'OR e74_params->'p0'IS DISTINCT FROM'0'::jsonb OR e74_params->'p1'IS DISTINCT FROM'0'::jsonb OR e74_params->'p2'IS DISTINCT FROM'0'::jsonb OR e74_params->'edge_verified'IS DISTINCT FROM'true'::jsonb OR jsonb_typeof(e74_params->'edge_version')IS DISTINCT FROM'number'OR(e74_params->>'edge_version')::integer<=138 OR e74_params->'assets_verified'IS DISTINCT FROM'true'::jsonb OR coalesce(e74_params->>'ui_git_head','')!~'^[a-f0-9]{40}$'OR coalesce(e74_params->>'edge_ezbr_sha256','')!~'^[a-f0-9]{64}$'THEN RAISE EXCEPTION 'E74_MATERIAL_UNQUALIFIED';END IF;
IF current_user<>'postgres'THEN RAISE EXCEPTION 'E74_OPERATOR_REQUIRED';END IF;
IF NOT pg_try_advisory_xact_lock(hashtextextended('C1266:GENERIC-AI:AVAILABILITY',0))THEN RAISE EXCEPTION 'E74_RELEASE_BUSY';END IF;
SELECT * INTO STRICT e74_rr FROM mission_factory_owner.editor_release_readiness WHERE singleton FOR UPDATE NOWAIT;
IF e74_rr.canonical_preimage IS DISTINCT FROM e74_base OR e74_rr.revision_sha256<>'BASESHA'OR e74_rr.observed_revision_sha256<>e74_rr.revision_sha256 OR e74_rr.state<>'enabled'OR e74_rr.scope<>'staff'OR NOT e74_rr.staff_guards_verified OR NOT e74_rr.published_assets_verified THEN RAISE EXCEPTION 'E74_ROOT_DRIFT';END IF;
IF public.combat_v2_sha256(to_jsonb(e74_rr))<>'BASEROWSHA'THEN RAISE EXCEPTION 'E74_ROOT_ROW_DRIFT';END IF;
GUARDS
SOURCE_AUTH
INSTALL_MUTATIONS
IF octet_length(e74_new)>262144 OR strpos(e74_new,'__E74_')>0 THEN RAISE EXCEPTION 'E74_UNMATERIAL';END IF;
e74_sha:=encode(extensions.digest(convert_to(e74_new,'UTF8'),'sha256'),'hex');
UPDATE mission_factory_owner.editor_release_readiness SET canonical_preimage=e74_new,revision_sha256=e74_sha,observed_revision_sha256=e74_sha,client_build='mission-factory-admin/2:'||e74_sha,independent_review_ref='REVIEW_REF_TOKEN',updated_at=clock_timestamp()WHERE singleton AND revision_sha256='BASESHA';
IF NOT FOUND THEN RAISE EXCEPTION 'E74_CAS_LOST';END IF;
GUARDS
IF NOT EXISTS(SELECT 1 FROM mission_factory_owner.editor_release_readiness WHERE singleton AND canonical_preimage=e74_new AND revision_sha256=e74_sha AND observed_revision_sha256=e74_sha AND state='enabled'AND scope='staff'AND staff_guards_verified AND published_assets_verified)THEN RAISE EXCEPTION 'E74_FINAL_ROOT_DRIFT';END IF;
END;$e74_root$;COMMIT;
"""
vals={'DECL':decl,'SEMANTIC':semantic,'BASESHA':sha(base),'BASEROWSHA':p['baseline_root_row_sha256'],'GUARDS':guards,'INSTALL_MUTATIONS':mutations,'SOURCE_AUTH':source_auth,'REVIEW_REF_TOKEN':REVIEW_REF};sql=re.sub(r'\b('+'|'.join(vals)+r')\b',lambda m:vals[m.group(0)],sql)
sys.path.insert(0,'/private/tmp/tus-c1266-recover46-20261027/output50/parse_tools312');from pglast import parse_sql,parse_plpgsql
nodes=parse_sql(sql);parse_plpgsql(sql.replace('e74_rr mission_factory_owner.editor_release_readiness','e74_rr record'));assert len(nodes)==3
wire=max(len(json.dumps({'project_id':'tyhyxkslteigibktluml','query':sql},ensure_ascii=a).encode())for a in [False,True]);assert wire<900000
(P/'INSTALL.sql').write_text(sql);(P/'ROOT_TEMPLATE.json').write_text(ct);(P/'MATERIAL_TEMPLATE.json').write_text(json.dumps(params,indent=2));manifest={'schema':'editorial74-root-release/1','semantic':semantic,'baseline_root':sha(base),'baseline_canonical_preimage':base,'Root_bytes':len(ct.encode()),'SQL_sha256':sha(sql),'SQL_bytes':len(sql.encode()),'wire_bytes_max':wire,'SQL_PL_parse':'PASS','headers':246,'10_ABIs_unchanged':True,'old_campaigns_unchanged':True,'function_DDL':1,'new_campaign_rows':1,'provider_calls':0,'new_quality_tests':'NOT_RUN','Edge_files':files,'builder_sha256':hashlib.sha256(Path(__file__).read_bytes()).hexdigest(),'review_ref':REVIEW_REF,'recovery_entries_preserved':True,'baseline_readiness_row_sha256':p['baseline_root_row_sha256'],'preservation_mode':'native_text_and_server_sha_same_snapshot_no_client_float_roundtrip','native_capture_proof':native_capture_proof,'predicted_actual_Root_bytes':len(ct.replace('__E74_DDL__',f['canonical_ddl_md5_expected']).replace(j('__E74_EDGE_VERSION__'),'139').encode())};(P/'MANIFEST.json').write_text(json.dumps(manifest,indent=2));print(j({k:manifest[k]for k in ['semantic','Root_bytes','SQL_sha256','wire_bytes_max']}))


# A separate one-shot operation starts the real finite campaign clock after review.
enable="""BEGIN;DO $e74_enable$
DECLARE DECL
e74_item jsonb;e74_actual jsonb;e74_abi jsonb;e74_sig text;e74_data jsonb;e74_rr mission_factory_owner.editor_release_readiness;e74_sha text;
e74_campaign mission_narrative_internal.editorial_campaigns_v1;e74_now timestamptz;e74_policy jsonb;e74_policy_sha text;
BEGIN
MATERIAL_GUARD
IF current_user<>'postgres'THEN RAISE EXCEPTION 'E74_ENABLE_OPERATOR_REQUIRED';END IF;
IF NOT pg_try_advisory_xact_lock(hashtextextended('C1266:GENERIC-AI:AVAILABILITY',0))THEN RAISE EXCEPTION 'E74_ENABLE_BUSY';END IF;
SELECT * INTO STRICT e74_rr FROM mission_factory_owner.editor_release_readiness WHERE singleton FOR UPDATE NOWAIT;
e74_sig:='SIGNATURE';HEADER
IF(e74_actual-'ddl_md5'-'source_md5')IS DISTINCT FROM(e74_beforeheader-'ddl_md5'-'source_md5')OR e74_actual->>'source_md5'<>'NEWMD5' THEN RAISE EXCEPTION 'E74_ENABLE_FUNCTION_DRIFT';END IF;
e74_new:=replace(e74_new,to_jsonb('__E74_DDL__'::text)::text,to_jsonb(e74_actual->>'ddl_md5')::text);
e74_headers:=e74_new::jsonb#>'{db_core,all_function_headers}';
IF e74_rr.canonical_preimage IS DISTINCT FROM e74_new OR e74_rr.revision_sha256 IS DISTINCT FROM encode(extensions.digest(convert_to(e74_new,'UTF8'),'sha256'),'hex')OR e74_rr.observed_revision_sha256<>e74_rr.revision_sha256 OR e74_rr.state<>'enabled'OR e74_rr.scope<>'staff'OR NOT e74_rr.staff_guards_verified OR NOT e74_rr.published_assets_verified THEN RAISE EXCEPTION 'E74_ENABLE_ROOT_DRIFT';END IF;
GUARDS
SOURCE_RECHECK
SELECT * INTO STRICT e74_campaign FROM mission_narrative_internal.editorial_campaigns_v1 WHERE id='CAMPAIGN'FOR UPDATE;
IF e74_campaign.enabled OR e74_campaign.policy_sha256<>'POLICY_SHA'OR e74_campaign.policy_sha256<>public.combat_v2_sha256(jsonb_build_object('policy',e74_campaign.policy,'source_refs',e74_campaign.source_refs))OR e74_campaign.policy IS DISTINCT FROM e74_seed_policy OR e74_campaign.source_refs IS DISTINCT FROM e74_seed_refs OR e74_campaign.policy->'provider_deadline'IS DISTINCT FROM'null'::jsonb OR e74_campaign.policy->'close_deadline'IS DISTINCT FROM'null'::jsonb OR EXISTS(SELECT 1 FROM mission_narrative_internal.editorial_runs_v1 WHERE campaign_id=e74_campaign.id)OR EXISTS(SELECT 1 FROM staff_ai_quota_private.calls WHERE scope_id=e74_campaign.id)THEN RAISE EXCEPTION 'E74_ENABLE_NOT_PRISTINE';END IF;
IF NOT EXISTS(SELECT 1 FROM public.profiles pr JOIN public.presence pp ON pp.user_id=pr.id WHERE pr.id=(e74_campaign.source_refs#>>'{0,source,author_user_id}')::uuid AND pr.role IN('admin','master')AND pp.location_id='0b85f354-9cdb-47e1-baf9-3d266bb7e06b')THEN RAISE EXCEPTION 'E74_ENABLE_STAFF_NOT_PRESENT';END IF;
IF NOT EXISTS(SELECT 1 FROM mission_narrative_internal.runtime_policy np WHERE np.singleton AND np.policy_version=(e74_campaign.policy->>'native_policy_version')::bigint AND np.model=e74_campaign.policy->>'model'AND np.reasoning_effort=e74_campaign.policy->>'reasoning_effort'AND NOT np.store AND np.input_usd_million=(e74_campaign.policy->>'input_usd_million')::numeric AND np.output_usd_million=(e74_campaign.policy->>'output_usd_million')::numeric)THEN RAISE EXCEPTION 'E74_ENABLE_PROVIDER_POLICY_DRIFT';END IF;
e74_now:=clock_timestamp();e74_policy:=jsonb_set(jsonb_set(e74_campaign.policy,'{provider_deadline}',to_jsonb(e74_now+interval '75 minutes')),'{close_deadline}',to_jsonb(e74_now+interval '90 minutes'));
e74_policy_sha:=public.combat_v2_sha256(jsonb_build_object('policy',e74_policy,'source_refs',e74_campaign.source_refs));
IF length(e74_new)-length(replace(e74_new,'POLICY_SHA',''))<>64 THEN RAISE EXCEPTION 'E74_ENABLE_POLICY_PIN_AMBIGUOUS';END IF;
e74_new:=replace(e74_new,to_jsonb('POLICY_SHA'::text)::text,to_jsonb(e74_policy_sha)::text);
IF(e74_new::jsonb#-'{config,c1266_editorial68,policy_sha256}')IS DISTINCT FROM(e74_rr.canonical_preimage::jsonb#-'{config,c1266_editorial68,policy_sha256}')OR octet_length(e74_new)>262144 THEN RAISE EXCEPTION 'E74_ENABLE_ROOT_EXTRA_MUTATION';END IF;
UPDATE mission_narrative_internal.editorial_campaigns_v1 SET policy=e74_policy,policy_sha256=e74_policy_sha,enabled=true WHERE id=e74_campaign.id AND NOT enabled AND policy_sha256='POLICY_SHA';
IF NOT FOUND THEN RAISE EXCEPTION 'E74_ENABLE_CAMPAIGN_CAS_LOST';END IF;
e74_sha:=encode(extensions.digest(convert_to(e74_new,'UTF8'),'sha256'),'hex');
UPDATE mission_factory_owner.editor_release_readiness SET canonical_preimage=e74_new,revision_sha256=e74_sha,observed_revision_sha256=e74_sha,client_build='mission-factory-admin/2:'||e74_sha,updated_at=e74_now WHERE singleton AND revision_sha256=e74_rr.revision_sha256;
IF NOT FOUND THEN RAISE EXCEPTION 'E74_ENABLE_ROOT_CAS_LOST';END IF;
GUARDS
IF NOT EXISTS(SELECT 1 FROM mission_narrative_internal.editorial_campaigns_v1 ec WHERE ec.id='CAMPAIGN'AND ec.enabled AND ec.policy=e74_policy AND ec.policy_sha256=e74_policy_sha AND ec.source_refs=e74_seed_refs)OR EXISTS(SELECT 1 FROM mission_narrative_internal.editorial_runs_v1 WHERE campaign_id='CAMPAIGN')OR EXISTS(SELECT 1 FROM staff_ai_quota_private.calls WHERE scope_id='CAMPAIGN')THEN RAISE EXCEPTION 'E74_ENABLE_EXCESS_MUTATION';END IF;
END;$e74_enable$;COMMIT;
"""
# Reuse exactly the same material qualification expression as the installer.
material_guard=re.search(r"IF e74_params->>'schema'[\s\S]*?END IF;",sql).group(0)
evalues={'DECL':decl,'MATERIAL_GUARD':material_guard,'HEADER':header,'GUARDS':guards,'SOURCE_RECHECK':source_auth.split('\n',1)[1],'SIGNATURE':f['signature'],'NEWMD5':f['source_md5'],'CAMPAIGN':cfg['campaign_id'],'POLICY_SHA':cfg['policy_sha256']}
enable=re.sub(r'\b('+'|'.join(evalues)+r')\b',lambda m:evalues[m.group(0)],enable)
assert len(parse_sql(enable))==3
parse_plpgsql(enable.replace('e74_rr mission_factory_owner.editor_release_readiness','e74_rr record').replace('e74_campaign mission_narrative_internal.editorial_campaigns_v1','e74_campaign record'))
ewire=max(len(json.dumps({'project_id':'tyhyxkslteigibktluml','query':enable},ensure_ascii=a).encode())for a in [False,True]);assert ewire<900000
(P/'ENABLE.sql').write_text(enable)
manifest.update(ENABLE_sha256=sha(enable),ENABLE_wire_bytes_max=ewire,ENABLE_SQL_PL_parse='PASS',campaign_initially_disabled=True,clock_start='Separate one-shot enable, 75 provider + 15 closing minutes',new_budget_usd='0.264',old_E68_closing_budget_usd='1',history_scopes=11,actual_prompt_versions={'director_authority':'staff-editorial-dialogue-director/2','writer_authority':'staff-editorial-dialogue-writer/3','director_content':'mission-dialogue-director/4','response':'mission-editorial-response/11','memory':'mission-scene-memory/3'},aggregate_review=22,prior_aggregates_preserved='1-21',live_authority_inverse_delta=p['controlled_reuse']['actual_live_authority_three_predicate_delta'])
(P/'MANIFEST.json').write_text(json.dumps(manifest,indent=2))


# The same compiler emits readonly install/enable checks. Stage substitution happens
# on the template before inserting any historical JSON or Root text.
header_query=frag.replace(' INTO actual','').replace("'signature',sig","'signature',eh.value->>'signature'").replace('to_regprocedure(sig)',"to_regprocedure(eh.value->>'signature')").strip().removesuffix(';')
abi_query=abi.replace(' INTO e74_abi','').replace('to_regprocedure(e74_sig)',"to_regprocedure(ea.value->>'signature')").strip().removesuffix(';')
post_template="WITH e74_root AS(SELECT rr.*,rr.canonical_preimage::jsonb root_value FROM mission_factory_owner.editor_release_readiness rr WHERE singleton),\ne74_campaign AS(SELECT * FROM mission_narrative_internal.editorial_campaigns_v1 WHERE id='CAMPAIGN'),\ne74_frame AS(SELECT replace(ROOTFRAME,to_jsonb('__E74_DDL__'::text)::text,to_jsonb(md5(pg_get_functiondef('SIGNATURE'::regprocedure)))::text)expected_root),\ne74_expected AS(SELECT CASE WHEN 'STAGE'='enabled'THEN replace(ef.expected_root,to_jsonb('SEEDPOLICYHASH'::text)::text,to_jsonb(ec.policy_sha256)::text)ELSE ef.expected_root END expected_root FROM e74_frame ef CROSS JOIN e74_campaign ec),\ne74_headers AS(SELECT eh.value expected,(HEADER)actual FROM e74_expected er CROSS JOIN LATERAL jsonb_array_elements(er.expected_root::jsonb#>'{db_core,all_function_headers}')eh(value)),\ne74_abis AS(SELECT ea.value expected,(ABI)actual FROM jsonb_array_elements(ABIS::jsonb)ea(value)),\ne74_tables AS(SELECT et.value expected,(SELECT jsonb_build_object('relation',ec.oid::regclass::text,'owner',pg_get_userbyid(ec.relowner),'rls',ec.relrowsecurity,'acl',ec.relacl::text,'columns',(SELECT jsonb_agg(jsonb_build_object('name',ea.attname,'type',format_type(ea.atttypid,ea.atttypmod),'notnull',ea.attnotnull,'default',pg_get_expr(ed.adbin,ed.adrelid))ORDER BY ea.attnum)FROM pg_attribute ea LEFT JOIN pg_attrdef ed ON ed.adrelid=ea.attrelid AND ed.adnum=ea.attnum WHERE ea.attrelid=ec.oid AND ea.attnum>0 AND NOT ea.attisdropped))FROM pg_class ec WHERE ec.oid=to_regclass(et.value->>'relation'))actual FROM jsonb_array_elements(TABLES::jsonb)et(value)),\ne74_constraints AS(SELECT ei.value expected,(SELECT jsonb_build_object('relation',conrelid::regclass::text,'name',conname,'definition',pg_get_constraintdef(oid),'validated',convalidated,'type',contype::text)FROM pg_constraint WHERE conrelid=(ei.value->>'relation')::regclass AND conname=ei.value->>'name')actual FROM jsonb_array_elements(CONSTRAINTS::jsonb)ei(value)),\ne74_old AS(SELECT preservation actual FROM(PRESERVATION_QUERY)e74_snapshot)\nSELECT jsonb_build_object('schema','editorial74-postflight/1','stage','STAGE',\n'Root',(SELECT jsonb_build_object('revision',rr.revision_sha256,'observed',rr.observed_revision_sha256,'canonical_sha256',encode(extensions.digest(convert_to(rr.canonical_preimage,'UTF8'),'sha256'),'hex'),'exact_material_frame_matches',rr.canonical_preimage=er.expected_root AND rr.revision_sha256=rr.observed_revision_sha256 AND rr.revision_sha256=encode(extensions.digest(convert_to(er.expected_root,'UTF8'),'sha256'),'hex'),'state',rr.state,'scope',rr.scope,'staff_guards_verified',rr.staff_guards_verified,'published_assets_verified',rr.published_assets_verified,'Edge',rr.root_value#>'{edge_bundles,0,version}','EZBR',rr.root_value#>'{edge_bundles,0,ezbr_sha256}','UI_git',rr.root_value#>'{ui,git_head}','legacy_port_campaign',rr.root_value#>'{config,c1266_editorial68,campaign_id}','legacy_port_policy_hash',rr.root_value#>'{config,c1266_editorial68,policy_sha256}')FROM e74_root rr CROSS JOIN e74_expected er),\n'header_count',(SELECT count(*)FROM e74_headers),'header_mismatch',(SELECT coalesce(jsonb_agg(expected->>'signature'),'[]'::jsonb)FROM e74_headers WHERE actual IS DISTINCT FROM expected),\n'ABI_count',(SELECT count(*)FROM e74_abis),'ABI_mismatch',(SELECT coalesce(jsonb_agg(expected->>'signature'),'[]'::jsonb)FROM e74_abis WHERE actual IS DISTINCT FROM expected->'abi'),\n'table_count',(SELECT count(*)FROM e74_tables),'table_mismatch',(SELECT coalesce(jsonb_agg(expected->>'relation'),'[]'::jsonb)FROM e74_tables WHERE actual IS DISTINCT FROM expected),\n'constraint_count',(SELECT count(*)FROM e74_constraints),'constraint_mismatch',(SELECT coalesce(jsonb_agg(expected->>'name'),'[]'::jsonb)FROM e74_constraints WHERE actual IS DISTINCT FROM expected),\n'constraint_set_exact',(SELECT count(*)FROM pg_constraint WHERE conrelid IN(SELECT to_regclass(value->>'relation')FROM jsonb_array_elements(CONSTRAINTS::jsonb)))=jsonb_array_length(CONSTRAINTS::jsonb),\n'old43_E65_E66_E68_E70_E72_equal',(SELECT actual IS NOT DISTINCT FROM EXPECTED_PRESERVATION::jsonb FROM e74_old),\n'new_campaign',(SELECT jsonb_build_object('id',ec.id,'enabled',ec.enabled,'enabled_expected',ec.enabled=('STAGE'='enabled'),'policy_sha256',ec.policy_sha256,'policy_hash_valid',ec.policy_sha256=public.combat_v2_sha256(jsonb_build_object('policy',ec.policy,'source_refs',ec.source_refs)),'source_refs_exact',ec.source_refs=SEEDREFS::jsonb,'policy_exact_except_clock',(ec.policy-'provider_deadline'-'close_deadline')=(SEEDPOLICY::jsonb-'provider_deadline'-'close_deadline'),'clock_valid',CASE WHEN'STAGE'='installed'THEN ec.policy->'provider_deadline'='null'::jsonb AND ec.policy->'close_deadline'='null'::jsonb ELSE(ec.policy->>'provider_deadline')::timestamptz=rr.updated_at+interval'75 minutes'AND(ec.policy->>'close_deadline')::timestamptz=rr.updated_at+interval'90 minutes'END,'budget_usd',ec.policy->'budget_usd','history_scope_count',jsonb_array_length(ec.policy->'history_scope_ids'),'history_scope_ids',ec.policy->'history_scope_ids','max_pairs',ec.policy->'max_pairs','max_http',ec.policy->'max_http','upper_call_usd',ec.policy->'upper_call_usd','runs',(SELECT count(*)FROM mission_narrative_internal.editorial_runs_v1 er WHERE er.campaign_id=ec.id),'calls',(SELECT count(*)FROM staff_ai_quota_private.calls eq WHERE eq.scope_id=ec.id),'provider_deadline',ec.policy->>'provider_deadline','close_deadline',ec.policy->>'close_deadline')FROM e74_campaign ec CROSS JOIN e74_root rr),\n'controlled_narrative_reuse','SourceRefs exact frozen source whose inverse technical-ID map equals E70; V8/V7/F1/F2/questions/memory unchanged','provider_calls_from_postflight',0,'new_editorial_quality','NOT_RUN')AS metadata;\n"
post_values={'ROOTFRAME':dq(ct,'e74rootframe'),'CAMPAIGN':cfg['campaign_id'],'SIGNATURE':f['signature'],'SEEDPOLICYHASH':cfg['policy_sha256'],'HEADER':header_query,'ABI':abi_query,'ABIS':dq(j(p['abis']),'e74expectedabis'),'TABLES':dq(j(p['tables']),'e74expectedtables'),'CONSTRAINTS':dq(j(p['constraints']),'e74expectedconstraints'),'PRESERVATION_QUERY':p['preservation_query'].strip().removesuffix(';'),'EXPECTED_PRESERVATION':dq(j(p['preservation']),'e74oldexpected'),'SEEDREFS':dq(j(cfg['source_refs']),'e74seedrefs'),'SEEDPOLICY':dq(j(cfg['policy']),'e74seedpolicy')}
post_files=[]
for post_stage in ['installed','enabled']:
 query=re.sub(r"\b("+"|".join(post_values)+r")\b",lambda m:post_values[m.group(0)],post_template.replace("'STAGE'", "'"+post_stage+"'"));assert len(parse_sql(query))==1
 pf=P/('POST_'+post_stage.upper()+'_QUERY.sql');pf.write_text(query);post_files.append({'stage':post_stage,'sha256':sha(query),'bytes':len(query.encode())})
manifest.update(postflight_queries=post_files,template_expansion='STAGE_before_data_nonrecursive')
(P/'NATIVE_CAPTURE_QUERY.sql').write_text(native_capture_query(p))
(P/'MANIFEST.json').write_text(json.dumps(manifest,indent=2)+'\n')
