"""Build reviewed E66 delta installer. No database or provider execution."""
from pathlib import Path
import argparse,json,hashlib,copy,re,ast,sys
j=lambda x:json.dumps(x,ensure_ascii=False,separators=(',',':'))
sha=lambda x:hashlib.sha256(x.encode()).hexdigest()
dq=lambda x,t:'$'+t+'$'+x+'$'+t+'$'
a=argparse.ArgumentParser();a.add_argument('--packet',default=str(Path(__file__).with_name('DB_PACKET.json')));a.add_argument('--baseline-json',required=True);a.add_argument('--edge-package',required=True);a.add_argument('--ui-manifest',required=True);a.add_argument('--preservation-json',required=True);a.add_argument('--preservation-query',required=True);a.add_argument('--constraints-json',required=True);a.add_argument('--tables-json',required=True);a.add_argument('--material');a.add_argument('--out',required=True);o=a.parse_args();P=Path(o.out);P.mkdir(parents=True,exist_ok=True)
p=json.loads(Path(o.packet).read_text());r=json.loads(Path(o.baseline_json).read_text());r=r[0] if isinstance(r,list) else r;base=r['canonical_preimage'];root=json.loads(base);assert sha(base)==r['revision_sha256']==r['observed_revision_sha256']==p['baseline_root'];assert len(root['db_core']['all_function_headers'])==245
cfg=p['config'];fs=p['functions'];edge=json.loads(Path(o.edge_package).read_text());ui=json.loads(Path(o.ui_manifest).read_text());assert edge['name']=='mission_generic_ai' and edge['verify_jwt'] is False
files=[{'name':f['name'],'bytes':len(f['content'].encode()),'sha256':sha(f['content'])} for f in edge['files']];uifiles={}
for f in ui['files']:
 b=Path(f['candidate_path']).read_bytes();assert len(b)==f['candidate_bytes'] and hashlib.sha256(b).hexdigest()==f['candidate_sha256'];uifiles[Path(f['path']).name]={'bytes':len(b),'sha256':f['candidate_sha256']}
cons=json.loads(Path(o.constraints_json).read_text());tables=json.loads(Path(o.tables_json).read_text());aftercons=copy.deepcopy(cons)
for c in aftercons:
 if c['relation']=='mission_narrative_internal.editorial_runs_v1' and c['name']=='editorial_runs_v1_variant_check':c['definition']=c['definition'].replace("'canary'::text]","'canary'::text, 'director'::text, 'writer'::text]")
assert cons!=aftercons
sem=sha(j({'schema':'editorial66-integrated/1','baseline':sha(base),'packet':sha(Path(o.packet).read_text()),'Edge':files,'UI':uifiles}))
params={'schema':'editorial66-material/1','semantic':sem,'review_ref':'C1266_EDITORIAL66_REVIEW.json','review_sha':'__E66_REVIEW_SHA__','p0':0,'p1':0,'p2':0,'ui_git_head':'__E66_UI_HEAD__','assets_verified':False,'edge_verified':False,'edge_version':'__E66_EDGE_VERSION__','edge_ezbr_sha256':'__E66_EDGE_SHA__'}
if o.material:params=json.loads(Path(o.material).read_text())
expected=[];updates={}
for i,f in enumerate(fs):
 old=f['before']['header'] if f['before'] else None;h=copy.deepcopy(old or f['expected_header']);h.update(signature=f['signature'],source_md5=f['source_md5'],ddl_md5='__E66_DDL_'+str(i)+'__')
 if old is None:h['oid']='__E66_OID_'+str(i)+'__'
 expected.append({'signature':f['signature'],'before':old,'header':h,'abi':f['before']['abi'] if f['before'] else f['expected_abi']});updates[f['signature']]=h
c=copy.deepcopy(root)
def rewrite(v):
 if isinstance(v,dict):
  if v.get('signature') in updates:
   for k in ('source_md5','ddl_md5'):
    if k in v:v[k]=updates[v['signature']][k]
  for x in v.values():rewrite(x)
 elif isinstance(v,list):
  for x in v:rewrite(x)
rewrite(c['db_core']);known={x['signature'] for x in c['db_core']['all_function_headers']}
for sig,h in updates.items():
 if sig not in known:c['db_core']['all_function_headers'].append(h)
c['contract']['code_identity_sha256']=sem;c['recovery']['semantic_identity_sha256']=sem;c['recovery']['editorial66']={'semantic':sem,'review_ref':params['review_ref'],'review_sha256':params['review_sha'],'previous_root_sha256':sha(base)}
c['config']['c1266_editorial66']={'campaign_id':cfg['campaign_id'],'policy_sha256':cfg['policy_sha256'],'active_variants':['director','writer']}
c['edge_bundles'][0].update(version=params['edge_version'],ezbr_sha256=params['edge_ezbr_sha256'],files=files)
c['ui']['git_head']=params['ui_git_head'];c['ui']['narrative_scene_version']='mission-combat64-ui/5-editorial66-pair';c['ui']['module_pin']='editorial66-'+uifiles['mission-generic-ui.mjs']['sha256'][:16]
for name,f in uifiles.items():c['ui']['files'][name]=f
ct=j(c);assert len(ct.encode())<=262144,len(ct.encode())
# Frozen capture expressions from the previously reviewed compiler; no DB execution.
oldtree=ast.parse(Path('/private/tmp/tus-c1266-combat64-20261030/release30/build_release30.py').read_text());abi=next(ast.literal_eval(n.value) for n in oldtree.body if isinstance(n,ast.Assign) and any(isinstance(t,ast.Name) and t.id=='abi_sql' for t in n.targets))
header=Path('/private/tmp/tus-c1266-combat64-20261030/release30/HEADER_CAPTURE_FRAGMENT.sql').read_text()
header=header.replace('INTO actual','INTO e66_actual').replace('to_regprocedure(sig)','to_regprocedure(e66_sig)').replace("'signature',sig","'signature',e66_sig");abi=abi.replace('INTO abi','INTO e66_abi').replace('to_regprocedure(sig)','to_regprocedure(e66_sig)')
preserve=Path(o.preservation_query).read_text();assert preserve.count(' evidence;')==1;capture=preserve.replace(' evidence;',' INTO e66_data;');preserved=json.loads(Path(o.preservation_json).read_text())
common="""FOR e66_item IN SELECT value FROM jsonb_array_elements(e66_preserved_abis) LOOP e66_sig:=e66_item->>'signature';ABI
 IF e66_abi IS DISTINCT FROM e66_item->'abi' THEN RAISE EXCEPTION 'E66_PRESERVED_ABI_DRIFT %',e66_sig;END IF;END LOOP;
 FOR e66_item IN SELECT value FROM jsonb_array_elements(e66_constraints) LOOP
 SELECT jsonb_build_object('relation',conrelid::regclass::text,'name',conname,'definition',pg_get_constraintdef(oid),'validated',convalidated,'type',contype::text) INTO e66_actual FROM pg_constraint WHERE conrelid=(e66_item->>'relation')::regclass AND conname=e66_item->>'name';
 IF e66_actual IS DISTINCT FROM e66_item THEN RAISE EXCEPTION 'E66_CONSTRAINT_DRIFT';END IF;END LOOP;
 IF (SELECT count(*) FROM pg_constraint WHERE conrelid IN(SELECT DISTINCT(value->>'relation')::regclass FROM jsonb_array_elements(e66_constraints)))<>jsonb_array_length(e66_constraints) THEN RAISE EXCEPTION 'E66_CONSTRAINT_SET_DRIFT';END IF;
 FOR e66_item IN SELECT value FROM jsonb_array_elements(e66_tables) LOOP
 SELECT jsonb_build_object('relation',ec.oid::regclass::text,'owner',pg_get_userbyid(ec.relowner),'rls',ec.relrowsecurity,'acl',ec.relacl::text,'columns',(SELECT jsonb_agg(jsonb_build_object('name',ea.attname,'type',format_type(ea.atttypid,ea.atttypmod),'notnull',ea.attnotnull,'default',pg_get_expr(ed.adbin,ed.adrelid)) ORDER BY ea.attnum) FROM pg_attribute ea LEFT JOIN pg_attrdef ed ON ed.adrelid=ea.attrelid AND ed.adnum=ea.attnum WHERE ea.attrelid=ec.oid AND ea.attnum>0 AND NOT ea.attisdropped)) INTO e66_actual FROM pg_class ec WHERE ec.oid=to_regclass(e66_item->>'relation');
 IF e66_actual IS DISTINCT FROM e66_item THEN RAISE EXCEPTION 'E66_TABLE_DRIFT';END IF;END LOOP;
 CAPTURE
 IF e66_data IS DISTINCT FROM PRESERVATION THEN RAISE EXCEPTION 'E66_HISTORY_DRIFT';END IF;"""
mat="""IF e66_params->>'schema'<>'editorial66-material/1' OR e66_params->>'semantic'<>'SEMANTIC' OR e66_params->>'review_ref'<>'C1266_EDITORIAL66_REVIEW.json' OR e66_params->'p0'<>'0'::jsonb OR e66_params->'p1'<>'0'::jsonb OR e66_params->'p2'<>'0'::jsonb OR coalesce(e66_params->>'review_sha','')!~'^[a-f0-9]{64}$' OR coalesce(e66_params->>'ui_git_head','')!~'^[a-f0-9]{40}$' OR e66_params->'assets_verified' IS DISTINCT FROM 'true'::jsonb OR e66_params->'edge_verified' IS DISTINCT FROM 'true'::jsonb OR coalesce(e66_params->>'edge_ezbr_sha256','')!~'^[a-f0-9]{64}$' OR jsonb_typeof(e66_params->'edge_version')<>'number' OR(e66_params->>'edge_version')::integer<=130 THEN RAISE EXCEPTION 'E66_MATERIAL_UNQUALIFIED';END IF;""".replace('SEMANTIC',sem)
decl="DECLARE e66_params jsonb:=PARAMS;e66_base text:=BASELINE;e66_new text:=CANDIDATE;e66_expected jsonb:=EXPECTED;e66_constraints jsonb:=CONSTRAINTS;e66_tables jsonb:=TABLES;e66_preserved_abis jsonb:=PRESERVED_ABIS;e66_item jsonb;e66_actual jsonb;e66_abi jsonb;e66_sig text;e66_token text;e66_data jsonb;e66_rr mission_factory_owner.editor_release_readiness;e66_sha text;"
pre="""BEGIN;DO $e66pre$
DECL
BEGIN
 MAT
 IF current_user<>'postgres' THEN RAISE EXCEPTION 'E66_OPERATOR_REQUIRED';END IF;
 IF NOT pg_try_advisory_xact_lock(hashtextextended('C1266:GENERIC-AI:AVAILABILITY',0)) THEN RAISE EXCEPTION 'E66_RELEASE_BUSY';END IF;
 SELECT * INTO STRICT e66_rr FROM mission_factory_owner.editor_release_readiness WHERE singleton FOR UPDATE NOWAIT;
 IF e66_rr.canonical_preimage IS DISTINCT FROM e66_base OR e66_rr.revision_sha256<>'BEFORE_SHA' OR e66_rr.observed_revision_sha256<>e66_rr.revision_sha256 OR e66_rr.state<>'enabled' OR e66_rr.scope<>'staff' OR NOT e66_rr.staff_guards_verified OR NOT e66_rr.published_assets_verified THEN RAISE EXCEPTION 'E66_ROOT_BASELINE_DRIFT';END IF;
 IF EXISTS(SELECT 1 FROM mission_narrative_internal.editorial_campaigns_v1 WHERE id='CAMPAIGN') THEN RAISE EXCEPTION 'E66_CAMPAIGN_EXISTS';END IF;
 FOR e66_item IN SELECT value FROM jsonb_array_elements(e66_base::jsonb#>'{db_core,all_function_headers}') LOOP e66_sig:=e66_item->>'signature';HEADER
 IF e66_actual IS DISTINCT FROM e66_item THEN RAISE EXCEPTION 'E66_BASELINE_HEADER_DRIFT %',e66_sig;END IF;END LOOP;
 FOR e66_item IN SELECT value FROM jsonb_array_elements(e66_expected) LOOP e66_sig:=e66_item->>'signature';HEADER
 IF e66_actual IS DISTINCT FROM nullif(e66_item->'before','null'::jsonb) THEN RAISE EXCEPTION 'E66_TARGET_HEADER_DRIFT %',e66_sig;END IF;
 IF e66_actual IS NOT NULL THEN ABI
 IF e66_abi IS DISTINCT FROM e66_item->'abi' THEN RAISE EXCEPTION 'E66_ABI_DRIFT %',e66_sig;END IF;END IF;END LOOP;
 COMMON
END $e66pre$;
"""
post="""DO $e66post$
DECL
BEGIN
 MAT
 FOR e66_item IN SELECT value FROM jsonb_array_elements(e66_expected) LOOP e66_sig:=e66_item->>'signature';HEADER
 IF e66_actual IS NULL OR(e66_actual-'oid'-'ddl_md5') IS DISTINCT FROM ((e66_item->'header')-'oid'-'ddl_md5') OR(e66_item->'before'<>'null'::jsonb AND e66_actual->'oid' IS DISTINCT FROM e66_item#>'{before,oid}') THEN RAISE EXCEPTION 'E66_POST_FUNCTION_DRIFT %',e66_sig;END IF;
 ABI
 IF e66_abi IS DISTINCT FROM e66_item->'abi' THEN RAISE EXCEPTION 'E66_POST_ABI_DRIFT %',e66_sig;END IF;
 e66_token:=e66_item#>>'{header,ddl_md5}';e66_new:=replace(e66_new,to_jsonb(e66_token)::text,to_jsonb(e66_actual->>'ddl_md5')::text);
 IF e66_item->'before'='null'::jsonb THEN e66_token:=e66_item#>>'{header,oid}';e66_new:=replace(e66_new,to_jsonb(e66_token)::text,e66_actual->>'oid');END IF;END LOOP;
 FOR e66_item IN SELECT value FROM jsonb_array_elements(e66_new::jsonb#>'{db_core,all_function_headers}') LOOP e66_sig:=e66_item->>'signature';HEADER
 IF e66_actual IS DISTINCT FROM e66_item THEN RAISE EXCEPTION 'E66_FINAL_HEADER_DRIFT %',e66_sig;END IF;END LOOP;
 COMMON
 IF NOT EXISTS(SELECT 1 FROM mission_narrative_internal.editorial_campaigns_v1 WHERE id='CAMPAIGN' AND enabled AND policy_sha256='POLICY_SHA' AND policy_sha256=public.combat_v2_sha256(jsonb_build_object('policy',policy,'source_refs',source_refs))) OR EXISTS(SELECT 1 FROM mission_narrative_internal.editorial_runs_v1 WHERE campaign_id='CAMPAIGN') OR EXISTS(SELECT 1 FROM staff_ai_quota_private.calls WHERE scope_id='CAMPAIGN') THEN RAISE EXCEPTION 'E66_SEED_PROVIDER_EFFECT';END IF;
 IF octet_length(e66_new)>262144 OR strpos(e66_new,'__E66_')>0 THEN RAISE EXCEPTION 'E66_UNMATERIAL';END IF;
 e66_sha:=encode(extensions.digest(convert_to(e66_new,'UTF8'),'sha256'),'hex');
 UPDATE mission_factory_owner.editor_release_readiness SET canonical_preimage=e66_new,revision_sha256=e66_sha,observed_revision_sha256=e66_sha,client_build='mission-factory-admin/2:'||e66_sha,independent_review_ref='C1266_EDITORIAL66_REVIEW.json',updated_at=clock_timestamp() WHERE singleton AND revision_sha256='BEFORE_SHA';
 IF NOT FOUND THEN RAISE EXCEPTION 'E66_CAS_LOST';END IF;
END $e66post$;COMMIT;NOTIFY pgrst,'reload schema';
"""
def expand(s,after=False):
 vals={'DECL':decl,'MAT':mat,'COMMON':common,'HEADER':header,'ABI':abi,'CAPTURE':capture,'BASELINE':dq(base,'e66base'),'CANDIDATE':dq(ct,'e66root'),'PARAMS':dq(j(params),'e66params')+'::jsonb','EXPECTED':dq(j(expected),'e66expected')+'::jsonb','CONSTRAINTS':dq(j(aftercons if after else cons),'e66constraints')+'::jsonb','TABLES':dq(j(tables),'e66tables')+'::jsonb','PRESERVED_ABIS':dq(j(p['preserved_abis']),'e66preservedabis')+'::jsonb','PRESERVATION':dq(j(preserved),'e66preserve')+'::jsonb','BEFORE_SHA':sha(base),'CAMPAIGN':cfg['campaign_id'],'POLICY_SHA':cfg['policy_sha256']}
 for _ in range(3):s=re.sub(r'\b('+'|'.join(vals)+r')\b',lambda m:vals[m.group(0)],s)
 return s
sql=expand(pre)+p['constraint_sql']+'\n'+'\n\n'.join(f['source'].rstrip(';')+';' for f in fs)+'\n'+p['acl_sql']+p['seed_sql']+'\n'+expand(post,True)
sys.path.insert(0,'/private/tmp/tus-c1266-recover46-20261027/output50/parse_tools312');from pglast import parse_sql,parse_plpgsql
nodes=parse_sql(sql)
for n in nodes:
 if type(n.stmt).__name__=='DoStmt':parse_plpgsql('DO '+dq(n.stmt.args[0].arg.sval,'e66parse'))
(P/'INSTALL.sql').write_text(sql);(P/'ROOT_TEMPLATE.json').write_text(ct);(P/'MATERIAL_TEMPLATE.json').write_text(json.dumps(params,indent=2));(P/'MANIFEST.json').write_text(json.dumps({'schema':'editorial66-release/1','semantic':sem,'baseline_root':sha(base),'baseline_canonical_preimage':base,'Root_bytes':len(ct.encode()),'headers_before':245,'headers_after':246,'functions':len(fs),'sql_sha256':sha(sql),'sql_bytes':len(sql.encode()),'SQL_nodes':len(nodes),'SQL_parse':True,'PL_DO_parse':True,'function_static':p['static'],'Edge_files':files,'UI_files':uifiles,'campaign':cfg,'preservation':preserved},indent=2));print(json.dumps({'semantic':sem,'root_bytes':len(ct.encode()),'SQL_sha256':sha(sql),'SQL_nodes':len(nodes)}))
