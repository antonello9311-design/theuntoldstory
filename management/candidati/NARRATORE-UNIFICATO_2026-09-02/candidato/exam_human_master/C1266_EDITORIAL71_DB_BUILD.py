"""Pure E71 Root metadata compiler. Does not execute database/provider operations."""
from pathlib import Path
import json,hashlib,re,copy,sys,ast,argparse
REVIEW_REF='C1266_EDITORIAL71_REVIEW.json'
j=lambda x:json.dumps(x,ensure_ascii=False,separators=(',',':'))
sha=lambda x:hashlib.sha256(x.encode()).hexdigest()
def dq(x,t):
 tag='$'+t+'$';assert tag not in x;return tag+x+tag
a=argparse.ArgumentParser();a.add_argument('--packet',required=True);a.add_argument('--edge-package',required=True);a.add_argument('--material');a.add_argument('--out',required=True);o=a.parse_args();P=Path(o.out);P.mkdir(parents=True,exist_ok=True);p=json.loads(Path(o.packet).read_text())
base=p['baseline_canonical_preimage'];root=json.loads(base);assert sha(base)==p['baseline_root'];assert len(root['db_core']['all_function_headers'])==246
assert sha(Path(o.edge_package).read_text())==p['edge_package_sha256']
edge=json.loads(Path(o.edge_package).read_text());assert edge['name']=='mission_generic_ai'and edge['verify_jwt']is False and len(edge['files'])==16
files=[{'name':f['name'],'bytes':len(f['content'].encode()),'sha256':sha(f['content'])}for f in edge['files']];assert len(set(f['name']for f in files))==16
semantic=sha(j({'schema':'editorial71-root-metadata/1','baseline':sha(base),'Edge':files,'plan_sha256':p['plan_sha256'],'report_sha256':p['report_sha256'],'analysis_sha256':p['analysis_sha256']}))
params={'schema':'editorial71-material/1','semantic':semantic,'review_ref':REVIEW_REF,'review_sha':'0'*64,'p0':0,'p1':0,'p2':0,'edge_verified':False,'edge_version':'__E71_EDGE_VERSION__','edge_ezbr_sha256':'0'*64}
if o.material:
 params=json.loads(Path(o.material).read_text());assert params['schema']=='editorial71-material/1' and params['semantic']==semantic and params['review_ref']==REVIEW_REF
 assert params['p0']==params['p1']==params['p2']==0 and params['edge_verified'] is True and isinstance(params['edge_version'],int) and params['edge_version']>135
 assert all(re.fullmatch('[a-f0-9]{64}',params[k])for k in ['review_sha','edge_ezbr_sha256'])
c=copy.deepcopy(root);c['contract']['code_identity_sha256']=semantic;c['recovery']['semantic_identity_sha256']=semantic;c['recovery']['editorial71']={'semantic':semantic,'review_sha256':params['review_sha'],'previous_root_sha256':sha(base)};c['edge_bundles'][0].update(version=params['edge_version'],ezbr_sha256=params['edge_ezbr_sha256'],files=files)
assert c['config']==root['config']and c['ui']==root['ui']and c['db_core']==root['db_core'];assert 'editorial71'not in root['recovery'];assert {k:v for k,v in c['recovery'].items()if k not in ['semantic_identity_sha256','editorial71']}=={k:v for k,v in root['recovery'].items()if k!='semantic_identity_sha256'};ct=j(c);assert len(ct.encode())<=262144
frag="SELECT jsonb_build_object('signature',sig,'oid',p.oid::bigint,'owner',pg_catalog.pg_get_userbyid(p.proowner),\n 'acl',p.proacl::text,'config',to_jsonb(p.proconfig),'secdef',p.prosecdef,'language',l.lanname,\n 'volatility',p.provolatile::text,'source_md5',pg_catalog.md5(p.prosrc),'ddl_md5',pg_catalog.md5(pg_catalog.pg_get_functiondef(p.oid)))\n INTO actual FROM pg_catalog.pg_proc p JOIN pg_catalog.pg_language l ON l.oid=p.prolang WHERE p.oid=pg_catalog.to_regprocedure(sig);";header=frag.replace('INTO actual','INTO e71_actual').replace('to_regprocedure(sig)','to_regprocedure(e71_sig)').replace("'signature',sig","'signature',e71_sig")
abi='SELECT jsonb_build_object(\'return_type\',p.prorettype::regtype::text,\'retset\',p.proretset,\'kind\',p.prokind::text,\'strict\',p.proisstrict,\'parallel\',p.proparallel::text,\'leakproof\',p.proleakproof,\'argument_names\',coalesce(to_jsonb(p.proargnames),\'[]\'::jsonb),\'argument_defaults_count\',p.pronargdefaults,\'argument_defaults_sql\',pg_catalog.pg_get_expr(p.proargdefaults,0),\'argument_modes\',to_jsonb(coalesce(p.proargmodes,array_fill(\'i\'::"char",ARRAY[p.pronargs::integer]))),\'argument_count\',p.pronargs,\'variadic_type\',p.provariadic::bigint,\'cost\',p.procost,\'rows\',p.prorows,\'support_oid\',p.prosupport::bigint) INTO abi FROM pg_proc p WHERE p.oid=to_regprocedure(sig);';abi=abi.replace('INTO abi','INTO e71_abi').replace('to_regprocedure(sig)','to_regprocedure(e71_sig)')
capture='SELECT preservation INTO e71_data FROM ('+p['preservation_query'].strip().removesuffix(';')+') e71_capture_row;'
guards="""FOR e71_item IN SELECT value FROM jsonb_array_elements(e71_base::jsonb#>'{db_core,all_function_headers}')LOOP e71_sig:=e71_item->>'signature';HEADER
IF e71_actual IS DISTINCT FROM e71_item THEN RAISE EXCEPTION 'E71_HEADER_DRIFT %',e71_sig;END IF;END LOOP;
FOR e71_item IN SELECT value FROM jsonb_array_elements(e71_abis)LOOP e71_sig:=e71_item->>'signature';ABI
IF e71_abi IS DISTINCT FROM e71_item->'abi'THEN RAISE EXCEPTION 'E71_ABI_DRIFT %',e71_sig;END IF;END LOOP;
FOR e71_item IN SELECT value FROM jsonb_array_elements(e71_constraints)LOOP
SELECT jsonb_build_object('relation',conrelid::regclass::text,'name',conname,'definition',pg_get_constraintdef(oid),'validated',convalidated,'type',contype::text)INTO e71_actual FROM pg_constraint WHERE conrelid=(e71_item->>'relation')::regclass AND conname=e71_item->>'name';
IF e71_actual IS DISTINCT FROM e71_item THEN RAISE EXCEPTION 'E71_CONSTRAINT_DRIFT';END IF;END LOOP;
IF(SELECT count(*)FROM pg_constraint WHERE conrelid IN(SELECT DISTINCT(value->>'relation')::regclass FROM jsonb_array_elements(e71_constraints)))<>jsonb_array_length(e71_constraints)THEN RAISE EXCEPTION 'E71_CONSTRAINT_SET_DRIFT';END IF;
FOR e71_item IN SELECT value FROM jsonb_array_elements(e71_tables)LOOP
SELECT jsonb_build_object('relation',ec.oid::regclass::text,'owner',pg_get_userbyid(ec.relowner),'rls',ec.relrowsecurity,'acl',ec.relacl::text,'columns',(SELECT jsonb_agg(jsonb_build_object('name',ea.attname,'type',format_type(ea.atttypid,ea.atttypmod),'notnull',ea.attnotnull,'default',pg_get_expr(ed.adbin,ed.adrelid))ORDER BY ea.attnum)FROM pg_attribute ea LEFT JOIN pg_attrdef ed ON ed.adrelid=ea.attrelid AND ed.adnum=ea.attnum WHERE ea.attrelid=ec.oid AND ea.attnum>0 AND NOT ea.attisdropped))INTO e71_actual FROM pg_class ec WHERE ec.oid=to_regclass(e71_item->>'relation');
IF e71_actual IS DISTINCT FROM e71_item THEN RAISE EXCEPTION 'E71_TABLE_DRIFT';END IF;END LOOP;
CAPTURE
IF e71_data IS DISTINCT FROM e71_preserved THEN RAISE EXCEPTION 'E71_PROTECTED_HISTORY_DRIFT';END IF;"""
guards=re.sub(r'\b(HEADER|ABI|CAPTURE)\b',lambda m:{'HEADER':header,'ABI':abi,'CAPTURE':capture}[m.group(0)],guards)
decl='\n'.join(k+' text:='+dq(v,k)+';'for k,v in {'e71_base':base,'e71_new':ct}.items())+'\n'+'\n'.join(k+' jsonb:='+dq(j(v),k)+'::jsonb;'for k,v in {'e71_params':params,'e71_preserved':p['preservation'],'e71_abis':p['abis'],'e71_constraints':p['constraints'],'e71_tables':p['tables']}.items())
sql="""BEGIN;DO $e71_root$
DECLARE DECL
e71_item jsonb;e71_actual jsonb;e71_abi jsonb;e71_sig text;e71_data jsonb;e71_rr mission_factory_owner.editor_release_readiness;e71_sha text;
BEGIN
IF e71_params->>'schema'<>'editorial71-material/1'OR e71_params->>'semantic'<>'SEMANTIC'OR e71_params->>'review_ref'<>'REVIEW_REF_TOKEN'OR coalesce(e71_params->>'review_sha','')!~'^[a-f0-9]{64}$'OR e71_params->'p0'IS DISTINCT FROM'0'::jsonb OR e71_params->'p1'IS DISTINCT FROM'0'::jsonb OR e71_params->'p2'IS DISTINCT FROM'0'::jsonb OR e71_params->'edge_verified'IS DISTINCT FROM'true'::jsonb OR jsonb_typeof(e71_params->'edge_version')IS DISTINCT FROM'number'OR(e71_params->>'edge_version')::integer<=135 OR coalesce(e71_params->>'edge_ezbr_sha256','')!~'^[a-f0-9]{64}$'THEN RAISE EXCEPTION 'E71_MATERIAL_UNQUALIFIED';END IF;
IF current_user<>'postgres'THEN RAISE EXCEPTION 'E71_OPERATOR_REQUIRED';END IF;
IF NOT pg_try_advisory_xact_lock(hashtextextended('C1266:GENERIC-AI:AVAILABILITY',0))THEN RAISE EXCEPTION 'E71_RELEASE_BUSY';END IF;
SELECT * INTO STRICT e71_rr FROM mission_factory_owner.editor_release_readiness WHERE singleton FOR UPDATE NOWAIT;
IF e71_rr.canonical_preimage IS DISTINCT FROM e71_base OR e71_rr.revision_sha256<>'BASESHA'OR e71_rr.observed_revision_sha256<>e71_rr.revision_sha256 OR e71_rr.state<>'enabled'OR e71_rr.scope<>'staff'OR NOT e71_rr.staff_guards_verified OR NOT e71_rr.published_assets_verified THEN RAISE EXCEPTION 'E71_ROOT_DRIFT';END IF;
IF public.combat_v2_sha256(to_jsonb(e71_rr))<>'BASEROWSHA'THEN RAISE EXCEPTION 'E71_ROOT_ROW_DRIFT';END IF;
GUARDS
IF octet_length(e71_new)>262144 OR strpos(e71_new,'__E71_')>0 THEN RAISE EXCEPTION 'E71_UNMATERIAL';END IF;
IF e71_new::jsonb->'config'IS DISTINCT FROM e71_base::jsonb->'config'OR e71_new::jsonb->'db_core'IS DISTINCT FROM e71_base::jsonb->'db_core'OR e71_new::jsonb->'ui'IS DISTINCT FROM e71_base::jsonb->'ui'THEN RAISE EXCEPTION 'E71_SCOPE_DRIFT';END IF;
e71_sha:=encode(extensions.digest(convert_to(e71_new,'UTF8'),'sha256'),'hex');
UPDATE mission_factory_owner.editor_release_readiness SET canonical_preimage=e71_new,revision_sha256=e71_sha,observed_revision_sha256=e71_sha,client_build='mission-factory-admin/2:'||e71_sha,independent_review_ref='REVIEW_REF_TOKEN',updated_at=clock_timestamp()WHERE singleton AND revision_sha256='BASESHA';
IF NOT FOUND THEN RAISE EXCEPTION 'E71_CAS_LOST';END IF;
GUARDS
IF NOT EXISTS(SELECT 1 FROM mission_factory_owner.editor_release_readiness WHERE singleton AND canonical_preimage=e71_new AND revision_sha256=e71_sha AND observed_revision_sha256=e71_sha AND state='enabled'AND scope='staff'AND staff_guards_verified AND published_assets_verified)THEN RAISE EXCEPTION 'E71_FINAL_ROOT_DRIFT';END IF;
END;$e71_root$;COMMIT;
"""
vals={'DECL':decl,'SEMANTIC':semantic,'BASESHA':sha(base),'BASEROWSHA':p['baseline_root_row_sha256'],'GUARDS':guards,'REVIEW_REF_TOKEN':REVIEW_REF};sql=re.sub(r'\b('+'|'.join(vals)+r')\b',lambda m:vals[m.group(0)],sql)
sys.path.insert(0,'/private/tmp/tus-c1266-recover46-20261027/output50/parse_tools312');from pglast import parse_sql,parse_plpgsql
nodes=parse_sql(sql);parse_plpgsql(sql.replace('e71_rr mission_factory_owner.editor_release_readiness','e71_rr record'));assert len(nodes)==3
wire=max(len(json.dumps({'project_id':'tyhyxkslteigibktluml','query':sql},ensure_ascii=a).encode())for a in [False,True]);assert wire<900000
(P/'INSTALL.sql').write_text(sql);(P/'ROOT_TEMPLATE.json').write_text(ct);(P/'MATERIAL_TEMPLATE.json').write_text(json.dumps(params,indent=2));manifest={'schema':'editorial71-root-release/1','semantic':semantic,'baseline_root':sha(base),'baseline_canonical_preimage':base,'Root_bytes':len(ct.encode()),'SQL_sha256':sha(sql),'SQL_bytes':len(sql.encode()),'wire_bytes_max':wire,'SQL_PL_parse':'PASS','246_headers_unchanged':True,'10_ABIs_unchanged':True,'config_UI_dbcore_campaigns_unchanged':True,'DDL':False,'provider_calls':0,'new_quality_tests':'NOT_RUN','Edge_files':files}
# The read-only postflight is expanded once from a template: inserted data is never searched or replaced.
hquery=frag.replace(' INTO actual','').replace("'signature',sig","'signature',eh.value->>'signature'").replace('to_regprocedure(sig)',"to_regprocedure(eh.value->>'signature')").strip().removesuffix(';')
aquery=abi.replace(' INTO e71_abi','').replace('to_regprocedure(e71_sig)',"to_regprocedure(ea.value->>'signature')").strip().removesuffix(';')
post="""WITH e71_expected AS(SELECT ROOT_TEXT::text AS root,ABIS::jsonb AS abis,TABLES::jsonb AS tables,CONSTRAINTS::jsonb AS constraints,PRESERVED::jsonb AS preserved),
e71_headers AS(SELECT eh.value expected,(HEADER_QUERY)actual FROM e71_expected er CROSS JOIN LATERAL jsonb_array_elements(er.root::jsonb#>'{db_core,all_function_headers}')eh(value)),
e71_abis AS(SELECT ea.value expected,(ABI_QUERY)actual FROM e71_expected er CROSS JOIN LATERAL jsonb_array_elements(er.abis)ea(value)),
e71_tables AS(SELECT et.value expected,(SELECT jsonb_build_object('relation',ec.oid::regclass::text,'owner',pg_get_userbyid(ec.relowner),'rls',ec.relrowsecurity,'acl',ec.relacl::text,'columns',(SELECT jsonb_agg(jsonb_build_object('name',ea.attname,'type',format_type(ea.atttypid,ea.atttypmod),'notnull',ea.attnotnull,'default',pg_get_expr(ed.adbin,ed.adrelid))ORDER BY ea.attnum)FROM pg_attribute ea LEFT JOIN pg_attrdef ed ON ed.adrelid=ea.attrelid AND ed.adnum=ea.attnum WHERE ea.attrelid=ec.oid AND ea.attnum>0 AND NOT ea.attisdropped))FROM pg_class ec WHERE ec.oid=to_regclass(et.value->>'relation'))actual FROM e71_expected er CROSS JOIN LATERAL jsonb_array_elements(er.tables)et(value)),
e71_constraints AS(SELECT ei.value expected,(SELECT jsonb_build_object('relation',conrelid::regclass::text,'name',conname,'definition',pg_get_constraintdef(oid),'validated',convalidated,'type',contype::text)FROM pg_constraint WHERE conrelid=(ei.value->>'relation')::regclass AND conname=ei.value->>'name')actual FROM e71_expected er CROSS JOIN LATERAL jsonb_array_elements(er.constraints)ei(value)),
e71_preservation AS(PRESERVATION_QUERY)
SELECT (SELECT jsonb_build_object('revision',rr.revision_sha256,'observed',rr.observed_revision_sha256,'state',rr.state,'scope',rr.scope,'bytes',octet_length(rr.canonical_preimage),'canonical_sha_valid',encode(extensions.digest(convert_to(rr.canonical_preimage,'UTF8'),'sha256'),'hex')=rr.revision_sha256,'exact_material',rr.canonical_preimage=er.root,'staff_guards_verified',rr.staff_guards_verified,'published_assets_verified',rr.published_assets_verified)FROM mission_factory_owner.editor_release_readiness rr CROSS JOIN e71_expected er WHERE rr.singleton)root,
(SELECT count(*)FROM e71_headers)headers_checked,(SELECT count(*)FROM e71_headers WHERE actual IS DISTINCT FROM expected)header_mismatch,
(SELECT count(*)FROM e71_abis)abis_checked,(SELECT count(*)FROM e71_abis WHERE actual IS DISTINCT FROM expected->'abi')abi_mismatch,
(SELECT count(*)FROM e71_tables)tables_checked,(SELECT count(*)FROM e71_tables WHERE actual IS DISTINCT FROM expected)table_mismatch,
(SELECT count(*)FROM e71_constraints)constraints_checked,(SELECT count(*)FROM e71_constraints WHERE actual IS DISTINCT FROM expected)constraint_mismatch,
(SELECT count(*)FROM pg_constraint WHERE conrelid IN(SELECT to_regclass(value->>'relation')FROM e71_expected er CROSS JOIN LATERAL jsonb_array_elements(er.constraints)))=(SELECT jsonb_array_length(constraints)FROM e71_expected)constraint_set_exact,
(SELECT preservation=preserved FROM e71_preservation CROSS JOIN e71_expected)preservation_exact;
"""
postvals={'ROOT_TEXT':dq(ct,'e71postroot'),'ABIS':dq(j(p['abis']),'e71postabis'),'TABLES':dq(j(p['tables']),'e71posttables'),'CONSTRAINTS':dq(j(p['constraints']),'e71postconstraints'),'PRESERVED':dq(j(p['preservation']),'e71postpreserved'),'HEADER_QUERY':hquery,'ABI_QUERY':aquery,'PRESERVATION_QUERY':p['preservation_query'].strip().removesuffix(';')}
post=re.sub(r'\b('+'|'.join(postvals)+r')\b',lambda m:postvals[m.group(0)],post)
assert len(parse_sql(post))==1
(P/'POSTFLIGHT_QUERY.sql').write_text(post)
manifest.update({'postflight_query_sha256':sha(post),'postflight_query_bytes':len(post.encode()),'builder_sha256':hashlib.sha256(Path(__file__).read_bytes()).hexdigest(),'metadata_row_only':True,'baseline_readiness_row_sha256':p['baseline_root_row_sha256'],'recovery_prior_entries_preserved':True,'root_capacity_remaining':262144-len(ct.encode()),'review_ref':REVIEW_REF})
(P/'MANIFEST.json').write_text(json.dumps(manifest,ensure_ascii=False,indent=2)+'\n');print(j({k:manifest[k]for k in ['semantic','Root_bytes','SQL_sha256','wire_bytes_max','root_capacity_remaining']}))
