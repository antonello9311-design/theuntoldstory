"""Pure E69 Root metadata compiler. Does not execute database/provider operations."""
from pathlib import Path
import json,hashlib,re,copy,sys,ast,argparse
j=lambda x:json.dumps(x,ensure_ascii=False,separators=(',',':'))
sha=lambda x:hashlib.sha256(x.encode()).hexdigest()
dq=lambda x,t:'$'+t+'$'+x+'$'+t+'$'
a=argparse.ArgumentParser();a.add_argument('--packet',required=True);a.add_argument('--edge-package',required=True);a.add_argument('--material');a.add_argument('--out',required=True);o=a.parse_args();P=Path(o.out);P.mkdir(parents=True,exist_ok=True);p=json.loads(Path(o.packet).read_text())
base=p['baseline_canonical_preimage'];root=json.loads(base);assert sha(base)==p['baseline_root'];assert len(root['db_core']['all_function_headers'])==246
assert sha(Path(o.edge_package).read_text())==p['edge_package_sha256']
edge=json.loads(Path(o.edge_package).read_text());assert edge['name']=='mission_generic_ai'and edge['verify_jwt']is False and len(edge['files'])==16
files=[{'name':f['name'],'bytes':len(f['content'].encode()),'sha256':sha(f['content'])}for f in edge['files']];assert len(set(f['name']for f in files))==16
semantic=sha(j({'schema':'editorial69-root-metadata/1','baseline':sha(base),'Edge':files,'plan_sha256':p['plan_sha256'],'report_sha256':p['report_sha256'],'analysis_sha256':p['analysis_sha256']}))
params={'schema':'editorial69-material/1','semantic':semantic,'review_ref':'C1266_EDITORIAL69_REVIEW.json','review_sha':'__E69_REVIEW_SHA__','p0':0,'p1':0,'p2':0,'edge_verified':False,'edge_version':'__E69_EDGE_VERSION__','edge_ezbr_sha256':'__E69_EDGE_SHA__'}
if o.material:params=json.loads(Path(o.material).read_text())
c=copy.deepcopy(root);c['contract']['code_identity_sha256']=semantic;c['recovery']['semantic_identity_sha256']=semantic;c['recovery']['editorial69']={'semantic':semantic,'review_ref':params['review_ref'],'review_sha256':params['review_sha'],'previous_root_sha256':sha(base)};c['edge_bundles'][0].update(version=params['edge_version'],ezbr_sha256=params['edge_ezbr_sha256'],files=files)
assert c['config']==root['config']and c['ui']==root['ui']and c['db_core']==root['db_core'];assert 'editorial69'not in root['recovery'];ct=j(c);assert len(ct.encode())<=262144
frag=Path('/private/tmp/tus-c1266-combat64-20261030/release30/HEADER_CAPTURE_FRAGMENT.sql').read_text();header=frag.replace('INTO actual','INTO e69_actual').replace('to_regprocedure(sig)','to_regprocedure(e69_sig)').replace("'signature',sig","'signature',e69_sig")
tree=ast.parse(Path('/private/tmp/tus-c1266-combat64-20261030/release30/build_release30.py').read_text());abi=next(ast.literal_eval(n.value)for n in tree.body if isinstance(n,ast.Assign)and any(isinstance(t,ast.Name)and t.id=='abi_sql'for t in n.targets));abi=abi.replace('INTO abi','INTO e69_abi').replace('to_regprocedure(sig)','to_regprocedure(e69_sig)')
capture='SELECT to_jsonb(e69_capture_row)-\'root\' INTO e69_data FROM ('+p['preservation_query'].strip().removesuffix(';')+') e69_capture_row;'
guards="""FOR e69_item IN SELECT value FROM jsonb_array_elements(e69_base::jsonb#>'{db_core,all_function_headers}')LOOP e69_sig:=e69_item->>'signature';HEADER
IF e69_actual IS DISTINCT FROM e69_item THEN RAISE EXCEPTION 'E69_HEADER_DRIFT %',e69_sig;END IF;END LOOP;
FOR e69_item IN SELECT value FROM jsonb_array_elements(e69_abis)LOOP e69_sig:=e69_item->>'signature';ABI
IF e69_abi IS DISTINCT FROM e69_item->'abi'THEN RAISE EXCEPTION 'E69_ABI_DRIFT %',e69_sig;END IF;END LOOP;
FOR e69_item IN SELECT value FROM jsonb_array_elements(e69_constraints)LOOP
SELECT jsonb_build_object('relation',conrelid::regclass::text,'name',conname,'definition',pg_get_constraintdef(oid),'validated',convalidated,'type',contype::text)INTO e69_actual FROM pg_constraint WHERE conrelid=(e69_item->>'relation')::regclass AND conname=e69_item->>'name';
IF e69_actual IS DISTINCT FROM e69_item THEN RAISE EXCEPTION 'E69_CONSTRAINT_DRIFT';END IF;END LOOP;
IF(SELECT count(*)FROM pg_constraint WHERE conrelid IN(SELECT DISTINCT(value->>'relation')::regclass FROM jsonb_array_elements(e69_constraints)))<>jsonb_array_length(e69_constraints)THEN RAISE EXCEPTION 'E69_CONSTRAINT_SET_DRIFT';END IF;
FOR e69_item IN SELECT value FROM jsonb_array_elements(e69_tables)LOOP
SELECT jsonb_build_object('relation',ec.oid::regclass::text,'owner',pg_get_userbyid(ec.relowner),'rls',ec.relrowsecurity,'acl',ec.relacl::text,'columns',(SELECT jsonb_agg(jsonb_build_object('name',ea.attname,'type',format_type(ea.atttypid,ea.atttypmod),'notnull',ea.attnotnull,'default',pg_get_expr(ed.adbin,ed.adrelid))ORDER BY ea.attnum)FROM pg_attribute ea LEFT JOIN pg_attrdef ed ON ed.adrelid=ea.attrelid AND ed.adnum=ea.attnum WHERE ea.attrelid=ec.oid AND ea.attnum>0 AND NOT ea.attisdropped))INTO e69_actual FROM pg_class ec WHERE ec.oid=to_regclass(e69_item->>'relation');
IF e69_actual IS DISTINCT FROM e69_item THEN RAISE EXCEPTION 'E69_TABLE_DRIFT';END IF;END LOOP;
CAPTURE
IF e69_data IS DISTINCT FROM e69_preserved THEN RAISE EXCEPTION 'E69_PROTECTED_HISTORY_DRIFT';END IF;"""
guards=re.sub(r'\b(HEADER|ABI|CAPTURE)\b',lambda m:{'HEADER':header,'ABI':abi,'CAPTURE':capture}[m.group(0)],guards)
decl='\n'.join(k+' text:='+dq(v,k)+';'for k,v in {'e69_base':base,'e69_new':ct}.items())+'\n'+'\n'.join(k+' jsonb:='+dq(j(v),k)+'::jsonb;'for k,v in {'e69_params':params,'e69_preserved':p['preservation'],'e69_abis':p['abis'],'e69_constraints':p['constraints'],'e69_tables':p['tables']}.items())
sql="""BEGIN;DO $e69_root$
DECLARE DECL
e69_item jsonb;e69_actual jsonb;e69_abi jsonb;e69_sig text;e69_data jsonb;e69_rr mission_factory_owner.editor_release_readiness;e69_sha text;
BEGIN
IF e69_params->>'schema'<>'editorial69-material/1'OR e69_params->>'semantic'<>'SEMANTIC'OR e69_params->>'review_ref'<>'C1266_EDITORIAL69_REVIEW.json'OR coalesce(e69_params->>'review_sha','')!~'^[a-f0-9]{64}$'OR e69_params->'p0'IS DISTINCT FROM'0'::jsonb OR e69_params->'p1'IS DISTINCT FROM'0'::jsonb OR e69_params->'p2'IS DISTINCT FROM'0'::jsonb OR e69_params->'edge_verified'IS DISTINCT FROM'true'::jsonb OR jsonb_typeof(e69_params->'edge_version')IS DISTINCT FROM'number'OR(e69_params->>'edge_version')::integer<=133 OR coalesce(e69_params->>'edge_ezbr_sha256','')!~'^[a-f0-9]{64}$'THEN RAISE EXCEPTION 'E69_MATERIAL_UNQUALIFIED';END IF;
IF current_user<>'postgres'THEN RAISE EXCEPTION 'E69_OPERATOR_REQUIRED';END IF;
IF NOT pg_try_advisory_xact_lock(hashtextextended('C1266:GENERIC-AI:AVAILABILITY',0))THEN RAISE EXCEPTION 'E69_RELEASE_BUSY';END IF;
SELECT * INTO STRICT e69_rr FROM mission_factory_owner.editor_release_readiness WHERE singleton FOR UPDATE NOWAIT;
IF e69_rr.canonical_preimage IS DISTINCT FROM e69_base OR e69_rr.revision_sha256<>'BASESHA'OR e69_rr.observed_revision_sha256<>e69_rr.revision_sha256 OR e69_rr.state<>'enabled'OR e69_rr.scope<>'staff'OR NOT e69_rr.staff_guards_verified OR NOT e69_rr.published_assets_verified THEN RAISE EXCEPTION 'E69_ROOT_DRIFT';END IF;
GUARDS
IF octet_length(e69_new)>262144 OR strpos(e69_new,'__E69_')>0 THEN RAISE EXCEPTION 'E69_UNMATERIAL';END IF;
IF e69_new::jsonb->'config'IS DISTINCT FROM e69_base::jsonb->'config'OR e69_new::jsonb->'db_core'IS DISTINCT FROM e69_base::jsonb->'db_core'OR e69_new::jsonb->'ui'IS DISTINCT FROM e69_base::jsonb->'ui'THEN RAISE EXCEPTION 'E69_SCOPE_DRIFT';END IF;
e69_sha:=encode(extensions.digest(convert_to(e69_new,'UTF8'),'sha256'),'hex');
UPDATE mission_factory_owner.editor_release_readiness SET canonical_preimage=e69_new,revision_sha256=e69_sha,observed_revision_sha256=e69_sha,client_build='mission-factory-admin/2:'||e69_sha,independent_review_ref='C1266_EDITORIAL69_REVIEW.json',updated_at=clock_timestamp()WHERE singleton AND revision_sha256='BASESHA';
IF NOT FOUND THEN RAISE EXCEPTION 'E69_CAS_LOST';END IF;
GUARDS
IF NOT EXISTS(SELECT 1 FROM mission_factory_owner.editor_release_readiness WHERE singleton AND canonical_preimage=e69_new AND revision_sha256=e69_sha AND observed_revision_sha256=e69_sha AND state='enabled'AND scope='staff'AND staff_guards_verified AND published_assets_verified)THEN RAISE EXCEPTION 'E69_FINAL_ROOT_DRIFT';END IF;
END;$e69_root$;COMMIT;
"""
vals={'DECL':decl,'SEMANTIC':semantic,'BASESHA':sha(base),'GUARDS':guards};sql=re.sub(r'\b('+'|'.join(vals)+r')\b',lambda m:vals[m.group(0)],sql)
sys.path.insert(0,'/private/tmp/tus-c1266-recover46-20261027/output50/parse_tools312');from pglast import parse_sql,parse_plpgsql
nodes=parse_sql(sql);parse_plpgsql(sql.replace('e69_rr mission_factory_owner.editor_release_readiness','e69_rr record'));assert len(nodes)==3
wire=max(len(json.dumps({'project_id':'tyhyxkslteigibktluml','query':sql},ensure_ascii=a).encode())for a in [False,True]);assert wire<900000
(P/'INSTALL.sql').write_text(sql);(P/'ROOT_TEMPLATE.json').write_text(ct);(P/'MATERIAL_TEMPLATE.json').write_text(json.dumps(params,indent=2));manifest={'schema':'editorial69-root-release/1','semantic':semantic,'baseline_root':sha(base),'baseline_canonical_preimage':base,'Root_bytes':len(ct.encode()),'SQL_sha256':sha(sql),'SQL_bytes':len(sql.encode()),'wire_bytes_max':wire,'SQL_PL_parse':'PASS','246_headers_unchanged':True,'10_ABIs_unchanged':True,'config_UI_dbcore_campaigns_unchanged':True,'DDL':False,'provider_calls':0,'new_quality_tests':'NOT_RUN','Edge_files':files};(P/'MANIFEST.json').write_text(json.dumps(manifest,indent=2));print(j({k:manifest[k]for k in ['semantic','Root_bytes','SQL_sha256','wire_bytes_max']}))
