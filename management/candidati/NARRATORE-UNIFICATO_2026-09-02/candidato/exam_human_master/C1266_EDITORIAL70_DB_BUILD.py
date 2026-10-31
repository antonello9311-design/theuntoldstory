"""Pure E70 Root metadata compiler. Does not execute database/provider operations."""
from pathlib import Path
import json,hashlib,re,copy,sys,ast,argparse
j=lambda x:json.dumps(x,ensure_ascii=False,separators=(',',':'))
sha=lambda x:hashlib.sha256(x.encode()).hexdigest()
dq=lambda x,t:'$'+t+'$'+x+'$'+t+'$'
a=argparse.ArgumentParser();a.add_argument('--packet',required=True);a.add_argument('--edge-package',required=True);a.add_argument('--ui-manifest',required=True);a.add_argument('--material');a.add_argument('--out',required=True);o=a.parse_args();P=Path(o.out);P.mkdir(parents=True,exist_ok=True);p=json.loads(Path(o.packet).read_text())
base=p['baseline_canonical_preimage'];root=json.loads(base);assert sha(base)==p['baseline_root'];assert len(root['db_core']['all_function_headers'])==246
assert sha(Path(o.edge_package).read_text())==p['edge_package_sha256']
edge=json.loads(Path(o.edge_package).read_text());assert edge['name']=='mission_generic_ai'and edge['verify_jwt']is False and len(edge['files'])==16
files=[{'name':f['name'],'bytes':len(f['content'].encode()),'sha256':sha(f['content'])}for f in edge['files']];assert len(set(f['name']for f in files))==16
semantic=sha(j({'schema':'editorial70-root-metadata/1','baseline':sha(base),'Edge':files,'plan_sha256':p['plan_sha256'],'contract_sha256':p['contract_sha256'],'cases_sha256':p['cases_sha256'],'DB_source_md5':p['function']['source_md5'],'seed_policy_sha256':p['config']['policy_sha256'],'UI_manifest_sha256':sha(Path(o.ui_manifest).read_text())}))
params={'schema':'editorial70-material/1','semantic':semantic,'review_ref':'C1266_EDITORIAL70_REVIEW.json','review_sha':'__E70_REVIEW_SHA__','p0':0,'p1':0,'p2':0,'edge_verified':False,'edge_version':'__E70_EDGE_VERSION__','edge_ezbr_sha256':'__E70_EDGE_SHA__','ui_git_head':'__E70_UI_HEAD__','assets_verified':False}
if o.material:params=json.loads(Path(o.material).read_text())
f=p['function'];cfg=p['config'];ui=json.loads(Path(o.ui_manifest).read_text());uifiles={}
uipath=lambda uf:Path(uf['candidate_path'])if Path(uf['candidate_path']).is_absolute()else Path(o.ui_manifest).parent/uf['candidate_path']
for uf in ui['files']:
 ub=uipath(uf).read_bytes();assert len(ub)==uf['candidate_bytes']and hashlib.sha256(ub).hexdigest()==uf['candidate_sha256'];uifiles[Path(uf['path']).name]={'bytes':len(ub),'sha256':uf['candidate_sha256']}
c=copy.deepcopy(root)
def rewrite(v):
 if isinstance(v,dict):
  if v.get('signature')==f['signature']:
   if 'source_md5'in v:v['source_md5']=f['source_md5']
   if 'ddl_md5'in v:v['ddl_md5']='__E70_DDL__'
  for x in v.values():rewrite(x)
 elif isinstance(v,list):
  for x in v:rewrite(x)
rewrite(c['db_core'])
c['config']['c1266_editorial68']={'campaign_id':cfg['campaign_id'],'policy_sha256':cfg['policy_sha256'],'active_variants':['director','writer']}
c['ui']['git_head']=params['ui_git_head'];c['ui']['narrative_scene_version']=re.search(r"export const VERSION=['\"]([^'\"]+)",uipath(next(uf for uf in ui['files']if uf['path'].endswith('mission-generic-ui.mjs'))).read_text()).group(1);c['ui']['module_pin']='editorial70-'+uifiles['mission-generic-ui.mjs']['sha256'][:16]
for name,meta in uifiles.items():c['ui']['files'][name]=meta
c['contract']['code_identity_sha256']=semantic;c['recovery']['semantic_identity_sha256']=semantic;c['recovery']['editorial70']={'semantic':semantic,'review_ref':params['review_ref'],'review_sha256':params['review_sha'],'previous_root_sha256':sha(base)};c['edge_bundles'][0].update(version=params['edge_version'],ezbr_sha256=params['edge_ezbr_sha256'],files=files)
assert (c['config']|{'c1266_editorial68':root['config']['c1266_editorial68']})==root['config'];assert 'editorial70'not in root['recovery'];ct=j(c);assert len(ct.encode())<=262144
frag=Path('/private/tmp/tus-c1266-combat64-20261030/release30/HEADER_CAPTURE_FRAGMENT.sql').read_text();header=frag.replace('INTO actual','INTO e70_actual').replace('to_regprocedure(sig)','to_regprocedure(e70_sig)').replace("'signature',sig","'signature',e70_sig")
tree=ast.parse(Path('/private/tmp/tus-c1266-combat64-20261030/release30/build_release30.py').read_text());abi=next(ast.literal_eval(n.value)for n in tree.body if isinstance(n,ast.Assign)and any(isinstance(t,ast.Name)and t.id=='abi_sql'for t in n.targets));abi=abi.replace('INTO abi','INTO e70_abi').replace('to_regprocedure(sig)','to_regprocedure(e70_sig)')
capture='SELECT to_jsonb(e70_capture_row)-\'root\' INTO e70_data FROM ('+p['preservation_query'].strip().removesuffix(';')+') e70_capture_row;'
guards="""FOR e70_item IN SELECT value FROM jsonb_array_elements(e70_headers)LOOP e70_sig:=e70_item->>'signature';HEADER
IF e70_actual IS DISTINCT FROM e70_item THEN RAISE EXCEPTION 'E70_HEADER_DRIFT %',e70_sig;END IF;END LOOP;
FOR e70_item IN SELECT value FROM jsonb_array_elements(e70_abis)LOOP e70_sig:=e70_item->>'signature';ABI
IF e70_abi IS DISTINCT FROM e70_item->'abi'THEN RAISE EXCEPTION 'E70_ABI_DRIFT %',e70_sig;END IF;END LOOP;
FOR e70_item IN SELECT value FROM jsonb_array_elements(e70_constraints)LOOP
SELECT jsonb_build_object('relation',conrelid::regclass::text,'name',conname,'definition',pg_get_constraintdef(oid),'validated',convalidated,'type',contype::text)INTO e70_actual FROM pg_constraint WHERE conrelid=(e70_item->>'relation')::regclass AND conname=e70_item->>'name';
IF e70_actual IS DISTINCT FROM e70_item THEN RAISE EXCEPTION 'E70_CONSTRAINT_DRIFT';END IF;END LOOP;
IF(SELECT count(*)FROM pg_constraint WHERE conrelid IN(SELECT DISTINCT(value->>'relation')::regclass FROM jsonb_array_elements(e70_constraints)))<>jsonb_array_length(e70_constraints)THEN RAISE EXCEPTION 'E70_CONSTRAINT_SET_DRIFT';END IF;
FOR e70_item IN SELECT value FROM jsonb_array_elements(e70_tables)LOOP
SELECT jsonb_build_object('relation',ec.oid::regclass::text,'owner',pg_get_userbyid(ec.relowner),'rls',ec.relrowsecurity,'acl',ec.relacl::text,'columns',(SELECT jsonb_agg(jsonb_build_object('name',ea.attname,'type',format_type(ea.atttypid,ea.atttypmod),'notnull',ea.attnotnull,'default',pg_get_expr(ed.adbin,ed.adrelid))ORDER BY ea.attnum)FROM pg_attribute ea LEFT JOIN pg_attrdef ed ON ed.adrelid=ea.attrelid AND ed.adnum=ea.attnum WHERE ea.attrelid=ec.oid AND ea.attnum>0 AND NOT ea.attisdropped))INTO e70_actual FROM pg_class ec WHERE ec.oid=to_regclass(e70_item->>'relation');
IF e70_actual IS DISTINCT FROM e70_item THEN RAISE EXCEPTION 'E70_TABLE_DRIFT';END IF;END LOOP;
CAPTURE
IF e70_data IS DISTINCT FROM e70_preserved THEN RAISE EXCEPTION 'E70_PROTECTED_HISTORY_DRIFT';END IF;"""
guards=re.sub(r'\b(HEADER|ABI|CAPTURE)\b',lambda m:{'HEADER':header,'ABI':abi,'CAPTURE':capture}[m.group(0)],guards)
decl='\n'.join(k+' text:='+dq(v,k)+';'for k,v in {'e70_base':base,'e70_new':ct}.items())+'\n'+'\n'.join(k+' jsonb:='+dq(j(v),k)+'::jsonb;'for k,v in {'e70_params':params,'e70_preserved':p['preservation'],'e70_abis':p['abis'],'e70_constraints':p['constraints'],'e70_tables':p['tables'],'e70_seed_policy':cfg['policy'],'e70_seed_refs':cfg['source_refs'],'e70_beforeheader':f['before_header'],'e70_headers':root['db_core']['all_function_headers']}.items())

source_auth="IF EXISTS(SELECT 1 FROM mission_narrative_internal.editorial_campaigns_v1 WHERE id='CAMPAIGN')THEN RAISE EXCEPTION 'E70_CAMPAIGN_EXISTS';END IF;\n FOR e70_item IN SELECT value FROM jsonb_array_elements(e70_seed_refs)LOOP\n IF NOT EXISTS(SELECT 1 FROM mission_creation_owner.revisions r JOIN mission_generic_owner.definitions d ON d.plan_version_id=r.plan_version_id JOIN public.mission_plan_versions v ON v.id=d.plan_version_id WHERE r.plan_version_id=(e70_item#>>'{source,plan_version_id}')::uuid AND v.stato='approvata'AND v.plan_sha256=e70_item#>>'{source,plan_sha256}'AND r.document_sha256=e70_item#>>'{source,snapshot,document_sha256}'AND r.document_sha256=mission_internal.fingerprint(r.document)AND d.id=(e70_item#>>'{source,snapshot,definition_id}')::uuid AND d.definition_sha256=e70_item#>>'{source,snapshot,definition_sha256}'AND d.definition_sha256=mission_internal.fingerprint(d.definition)AND r.document#>'{editorial,setting}'=e70_item#>'{source,snapshot,scene,setting}') THEN RAISE EXCEPTION 'E68_VERSIONED_SOURCE_DRIFT';END IF;\n IF EXISTS(SELECT 1 FROM jsonb_array_elements(e70_item#>'{source,npc_refs}')nr WHERE NOT EXISTS(SELECT 1 FROM public.nb_template_versions nv JOIN public.nb_mechanical_bindings nb ON nb.narrative_version_id=nv.id WHERE nv.id=(nr->>'version_id')::uuid AND nv.template_id=(nr->>'template_id')::uuid AND nv.review_state='approved'AND nv.content_sha256=nr->>'content_sha256'AND nb.id=(nr->>'binding_id')::uuid AND nb.lifecycle_state='approved'AND NOT nb.active AND EXISTS(SELECT 1 FROM jsonb_array_elements(e70_item#>'{source,snapshot,scene,npcs}')np WHERE np->>'actor_key'=nr->>'actor_key'AND np->>'narrative_version_id'=nv.id::text AND np->'profile'=nv.skeleton AND np->'knowledge'=nv.knowledge_boundary))) THEN RAISE EXCEPTION 'E68_PROFILE_SOURCE_DRIFT';END IF;\n IF EXISTS(SELECT 1 FROM jsonb_array_elements(e70_item#>'{source,last_fati}')hf WHERE NOT EXISTS(SELECT 1 FROM public.messages m WHERE m.id=(hf->>'message_id')::uuid AND m.kind='fato'AND m.recipient_user IS NULL AND m.location_id='0b85f354-9cdb-47e1-baf9-3d266bb7e06b'AND m.body=hf->>'body'AND encode(extensions.digest(convert_to(m.body,'UTF8'),'sha256'),'hex')=hf->>'body_sha256')) OR EXISTS(SELECT 1 FROM jsonb_array_elements(e70_item#>'{source,questions}')q WHERE encode(extensions.digest(convert_to(q->>'body','UTF8'),'sha256'),'hex')IS DISTINCT FROM q->>'body_sha256') THEN RAISE EXCEPTION 'E68_REAL_HISTORY_QUESTION_DRIFT';END IF;END LOOP;\n"
mutations="EXECUTE DDL;\ne70_sig:='SIGNATURE';HEADER\nIF(e70_actual-'ddl_md5'-'source_md5')IS DISTINCT FROM(e70_beforeheader-'ddl_md5'-'source_md5')OR e70_actual->>'source_md5'<>'NEWMD5'THEN RAISE EXCEPTION 'E70_CHANGED_FUNCTION_DRIFT';END IF;\ne70_new:=replace(e70_new,to_jsonb('__E70_DDL__'::text)::text,to_jsonb(e70_actual->>'ddl_md5')::text);\ne70_headers:=e70_new::jsonb#>'{db_core,all_function_headers}';\nINSERT INTO mission_narrative_internal.editorial_campaigns_v1(id,policy,source_refs,policy_sha256,enabled)VALUES('CAMPAIGN',e70_seed_policy,e70_seed_refs,'POLICY_SHA',false);\nIF NOT EXISTS(SELECT 1 FROM mission_narrative_internal.editorial_campaigns_v1 ec WHERE ec.id='CAMPAIGN'AND NOT ec.enabled AND ec.policy=e70_seed_policy AND ec.source_refs=e70_seed_refs AND ec.policy_sha256='POLICY_SHA'AND ec.policy_sha256=public.combat_v2_sha256(jsonb_build_object('policy',ec.policy,'source_refs',ec.source_refs)))OR EXISTS(SELECT 1 FROM mission_narrative_internal.editorial_runs_v1 WHERE campaign_id='CAMPAIGN')OR EXISTS(SELECT 1 FROM staff_ai_quota_private.calls WHERE scope_id='CAMPAIGN')THEN RAISE EXCEPTION 'E70_SEED_DRIFT';END IF;"
mutations=re.sub(r'\b(DDL|SIGNATURE|HEADER|NEWMD5|CAMPAIGN|POLICY_SHA)\b',lambda m:{'DDL':dq(f['source'],'e70ddl'),'SIGNATURE':f['signature'],'HEADER':header,'NEWMD5':f['source_md5'],'CAMPAIGN':cfg['campaign_id'],'POLICY_SHA':cfg['policy_sha256']}[m.group(0)],mutations)
source_auth=re.sub(r'\bCAMPAIGN\b',lambda _:cfg['campaign_id'],source_auth)
sql="""BEGIN;DO $e70_root$
DECLARE DECL
e70_item jsonb;e70_actual jsonb;e70_abi jsonb;e70_sig text;e70_data jsonb;e70_rr mission_factory_owner.editor_release_readiness;e70_sha text;
BEGIN
IF e70_params->>'schema'<>'editorial70-material/1'OR e70_params->>'semantic'<>'SEMANTIC'OR e70_params->>'review_ref'<>'C1266_EDITORIAL70_REVIEW.json'OR coalesce(e70_params->>'review_sha','')!~'^[a-f0-9]{64}$'OR e70_params->'p0'IS DISTINCT FROM'0'::jsonb OR e70_params->'p1'IS DISTINCT FROM'0'::jsonb OR e70_params->'p2'IS DISTINCT FROM'0'::jsonb OR e70_params->'edge_verified'IS DISTINCT FROM'true'::jsonb OR jsonb_typeof(e70_params->'edge_version')IS DISTINCT FROM'number'OR(e70_params->>'edge_version')::integer<=134 OR e70_params->'assets_verified'IS DISTINCT FROM'true'::jsonb OR coalesce(e70_params->>'ui_git_head','')!~'^[a-f0-9]{40}$'OR coalesce(e70_params->>'edge_ezbr_sha256','')!~'^[a-f0-9]{64}$'THEN RAISE EXCEPTION 'E70_MATERIAL_UNQUALIFIED';END IF;
IF current_user<>'postgres'THEN RAISE EXCEPTION 'E70_OPERATOR_REQUIRED';END IF;
IF NOT pg_try_advisory_xact_lock(hashtextextended('C1266:GENERIC-AI:AVAILABILITY',0))THEN RAISE EXCEPTION 'E70_RELEASE_BUSY';END IF;
SELECT * INTO STRICT e70_rr FROM mission_factory_owner.editor_release_readiness WHERE singleton FOR UPDATE NOWAIT;
IF e70_rr.canonical_preimage IS DISTINCT FROM e70_base OR e70_rr.revision_sha256<>'BASESHA'OR e70_rr.observed_revision_sha256<>e70_rr.revision_sha256 OR e70_rr.state<>'enabled'OR e70_rr.scope<>'staff'OR NOT e70_rr.staff_guards_verified OR NOT e70_rr.published_assets_verified THEN RAISE EXCEPTION 'E70_ROOT_DRIFT';END IF;
GUARDS
SOURCE_AUTH
INSTALL_MUTATIONS
IF octet_length(e70_new)>262144 OR strpos(e70_new,'__E70_')>0 THEN RAISE EXCEPTION 'E70_UNMATERIAL';END IF;
e70_sha:=encode(extensions.digest(convert_to(e70_new,'UTF8'),'sha256'),'hex');
UPDATE mission_factory_owner.editor_release_readiness SET canonical_preimage=e70_new,revision_sha256=e70_sha,observed_revision_sha256=e70_sha,client_build='mission-factory-admin/2:'||e70_sha,independent_review_ref='C1266_EDITORIAL70_REVIEW.json',updated_at=clock_timestamp()WHERE singleton AND revision_sha256='BASESHA';
IF NOT FOUND THEN RAISE EXCEPTION 'E70_CAS_LOST';END IF;
GUARDS
IF NOT EXISTS(SELECT 1 FROM mission_factory_owner.editor_release_readiness WHERE singleton AND canonical_preimage=e70_new AND revision_sha256=e70_sha AND observed_revision_sha256=e70_sha AND state='enabled'AND scope='staff'AND staff_guards_verified AND published_assets_verified)THEN RAISE EXCEPTION 'E70_FINAL_ROOT_DRIFT';END IF;
END;$e70_root$;COMMIT;
"""
vals={'DECL':decl,'SEMANTIC':semantic,'BASESHA':sha(base),'GUARDS':guards,'INSTALL_MUTATIONS':mutations,'SOURCE_AUTH':source_auth};sql=re.sub(r'\b('+'|'.join(vals)+r')\b',lambda m:vals[m.group(0)],sql)
sys.path.insert(0,'/private/tmp/tus-c1266-recover46-20261027/output50/parse_tools312');from pglast import parse_sql,parse_plpgsql
nodes=parse_sql(sql);parse_plpgsql(sql.replace('e70_rr mission_factory_owner.editor_release_readiness','e70_rr record'));assert len(nodes)==3
wire=max(len(json.dumps({'project_id':'tyhyxkslteigibktluml','query':sql},ensure_ascii=a).encode())for a in [False,True]);assert wire<900000
(P/'INSTALL.sql').write_text(sql);(P/'ROOT_TEMPLATE.json').write_text(ct);(P/'MATERIAL_TEMPLATE.json').write_text(json.dumps(params,indent=2));manifest={'schema':'editorial70-root-release/1','semantic':semantic,'baseline_root':sha(base),'baseline_canonical_preimage':base,'Root_bytes':len(ct.encode()),'SQL_sha256':sha(sql),'SQL_bytes':len(sql.encode()),'wire_bytes_max':wire,'SQL_PL_parse':'PASS','headers':246,'10_ABIs_unchanged':True,'old_campaigns_unchanged':True,'function_DDL':1,'new_campaign_rows':1,'provider_calls':0,'new_quality_tests':'NOT_RUN','Edge_files':files};(P/'MANIFEST.json').write_text(json.dumps(manifest,indent=2));print(j({k:manifest[k]for k in ['semantic','Root_bytes','SQL_sha256','wire_bytes_max']}))


# A separate one-shot operation starts the real finite campaign clock after review.
enable="""BEGIN;DO $e70_enable$
DECLARE DECL
e70_item jsonb;e70_actual jsonb;e70_abi jsonb;e70_sig text;e70_data jsonb;e70_rr mission_factory_owner.editor_release_readiness;e70_sha text;
e70_campaign mission_narrative_internal.editorial_campaigns_v1;e70_now timestamptz;e70_policy jsonb;e70_policy_sha text;
BEGIN
MATERIAL_GUARD
IF current_user<>'postgres'THEN RAISE EXCEPTION 'E70_ENABLE_OPERATOR_REQUIRED';END IF;
IF NOT pg_try_advisory_xact_lock(hashtextextended('C1266:GENERIC-AI:AVAILABILITY',0))THEN RAISE EXCEPTION 'E70_ENABLE_BUSY';END IF;
SELECT * INTO STRICT e70_rr FROM mission_factory_owner.editor_release_readiness WHERE singleton FOR UPDATE NOWAIT;
e70_sig:='SIGNATURE';HEADER
IF(e70_actual-'ddl_md5'-'source_md5')IS DISTINCT FROM(e70_beforeheader-'ddl_md5'-'source_md5')OR e70_actual->>'source_md5'<>'NEWMD5' THEN RAISE EXCEPTION 'E70_ENABLE_FUNCTION_DRIFT';END IF;
e70_new:=replace(e70_new,to_jsonb('__E70_DDL__'::text)::text,to_jsonb(e70_actual->>'ddl_md5')::text);
e70_headers:=e70_new::jsonb#>'{db_core,all_function_headers}';
IF e70_rr.canonical_preimage IS DISTINCT FROM e70_new OR e70_rr.revision_sha256 IS DISTINCT FROM encode(extensions.digest(convert_to(e70_new,'UTF8'),'sha256'),'hex')OR e70_rr.observed_revision_sha256<>e70_rr.revision_sha256 OR e70_rr.state<>'enabled'OR e70_rr.scope<>'staff'OR NOT e70_rr.staff_guards_verified OR NOT e70_rr.published_assets_verified THEN RAISE EXCEPTION 'E70_ENABLE_ROOT_DRIFT';END IF;
GUARDS
SOURCE_RECHECK
SELECT * INTO STRICT e70_campaign FROM mission_narrative_internal.editorial_campaigns_v1 WHERE id='CAMPAIGN'FOR UPDATE;
IF e70_campaign.enabled OR e70_campaign.policy_sha256<>'POLICY_SHA'OR e70_campaign.policy_sha256<>public.combat_v2_sha256(jsonb_build_object('policy',e70_campaign.policy,'source_refs',e70_campaign.source_refs))OR e70_campaign.policy IS DISTINCT FROM e70_seed_policy OR e70_campaign.source_refs IS DISTINCT FROM e70_seed_refs OR e70_campaign.policy->'provider_deadline'IS DISTINCT FROM'null'::jsonb OR e70_campaign.policy->'close_deadline'IS DISTINCT FROM'null'::jsonb OR EXISTS(SELECT 1 FROM mission_narrative_internal.editorial_runs_v1 WHERE campaign_id=e70_campaign.id)OR EXISTS(SELECT 1 FROM staff_ai_quota_private.calls WHERE scope_id=e70_campaign.id)THEN RAISE EXCEPTION 'E70_ENABLE_NOT_PRISTINE';END IF;
IF NOT EXISTS(SELECT 1 FROM public.profiles pr JOIN public.presence pp ON pp.user_id=pr.id WHERE pr.id=(e70_campaign.source_refs#>>'{0,source,author_user_id}')::uuid AND pr.role IN('admin','master')AND pp.location_id='0b85f354-9cdb-47e1-baf9-3d266bb7e06b')THEN RAISE EXCEPTION 'E70_ENABLE_STAFF_NOT_PRESENT';END IF;
IF NOT EXISTS(SELECT 1 FROM mission_narrative_internal.runtime_policy np WHERE np.singleton AND np.policy_version=(e70_campaign.policy->>'native_policy_version')::bigint AND np.model=e70_campaign.policy->>'model'AND np.reasoning_effort=e70_campaign.policy->>'reasoning_effort'AND NOT np.store AND np.input_usd_million=(e70_campaign.policy->>'input_usd_million')::numeric AND np.output_usd_million=(e70_campaign.policy->>'output_usd_million')::numeric)THEN RAISE EXCEPTION 'E70_ENABLE_PROVIDER_POLICY_DRIFT';END IF;
e70_now:=clock_timestamp();e70_policy:=jsonb_set(jsonb_set(e70_campaign.policy,'{provider_deadline}',to_jsonb(e70_now+interval '75 minutes')),'{close_deadline}',to_jsonb(e70_now+interval '90 minutes'));
e70_policy_sha:=public.combat_v2_sha256(jsonb_build_object('policy',e70_policy,'source_refs',e70_campaign.source_refs));
IF length(e70_new)-length(replace(e70_new,'POLICY_SHA',''))<>64 THEN RAISE EXCEPTION 'E70_ENABLE_POLICY_PIN_AMBIGUOUS';END IF;
e70_new:=replace(e70_new,to_jsonb('POLICY_SHA'::text)::text,to_jsonb(e70_policy_sha)::text);
IF(e70_new::jsonb#-'{config,c1266_editorial68,policy_sha256}')IS DISTINCT FROM(e70_rr.canonical_preimage::jsonb#-'{config,c1266_editorial68,policy_sha256}')OR octet_length(e70_new)>262144 THEN RAISE EXCEPTION 'E70_ENABLE_ROOT_EXTRA_MUTATION';END IF;
UPDATE mission_narrative_internal.editorial_campaigns_v1 SET policy=e70_policy,policy_sha256=e70_policy_sha,enabled=true WHERE id=e70_campaign.id AND NOT enabled AND policy_sha256='POLICY_SHA';
IF NOT FOUND THEN RAISE EXCEPTION 'E70_ENABLE_CAMPAIGN_CAS_LOST';END IF;
e70_sha:=encode(extensions.digest(convert_to(e70_new,'UTF8'),'sha256'),'hex');
UPDATE mission_factory_owner.editor_release_readiness SET canonical_preimage=e70_new,revision_sha256=e70_sha,observed_revision_sha256=e70_sha,client_build='mission-factory-admin/2:'||e70_sha,updated_at=e70_now WHERE singleton AND revision_sha256=e70_rr.revision_sha256;
IF NOT FOUND THEN RAISE EXCEPTION 'E70_ENABLE_ROOT_CAS_LOST';END IF;
GUARDS
IF NOT EXISTS(SELECT 1 FROM mission_narrative_internal.editorial_campaigns_v1 ec WHERE ec.id='CAMPAIGN'AND ec.enabled AND ec.policy=e70_policy AND ec.policy_sha256=e70_policy_sha AND ec.source_refs=e70_seed_refs)OR EXISTS(SELECT 1 FROM mission_narrative_internal.editorial_runs_v1 WHERE campaign_id='CAMPAIGN')OR EXISTS(SELECT 1 FROM staff_ai_quota_private.calls WHERE scope_id='CAMPAIGN')THEN RAISE EXCEPTION 'E70_ENABLE_EXCESS_MUTATION';END IF;
END;$e70_enable$;COMMIT;
"""
# Reuse exactly the same material qualification expression as the installer.
material_guard=re.search(r"IF e70_params->>'schema'[\s\S]*?END IF;",sql).group(0)
evalues={'DECL':decl,'MATERIAL_GUARD':material_guard,'HEADER':header,'GUARDS':guards,'SOURCE_RECHECK':source_auth.split('\n',1)[1],'SIGNATURE':f['signature'],'NEWMD5':f['source_md5'],'CAMPAIGN':cfg['campaign_id'],'POLICY_SHA':cfg['policy_sha256']}
enable=re.sub(r'\b('+'|'.join(evalues)+r')\b',lambda m:evalues[m.group(0)],enable)
assert len(parse_sql(enable))==3
parse_plpgsql(enable.replace('e70_rr mission_factory_owner.editor_release_readiness','e70_rr record').replace('e70_campaign mission_narrative_internal.editorial_campaigns_v1','e70_campaign record'))
ewire=max(len(json.dumps({'project_id':'tyhyxkslteigibktluml','query':enable},ensure_ascii=a).encode())for a in [False,True]);assert ewire<900000
(P/'ENABLE.sql').write_text(enable)
manifest.update(ENABLE_sha256=sha(enable),ENABLE_wire_bytes_max=ewire,ENABLE_SQL_PL_parse='PASS',campaign_initially_disabled=True,clock_start='Separate one-shot enable, 75 provider + 15 closing minutes',new_budget_usd='0.264',old_E68_closing_budget_usd='1',history_scopes=9)
(P/'MANIFEST.json').write_text(json.dumps(manifest,indent=2))
